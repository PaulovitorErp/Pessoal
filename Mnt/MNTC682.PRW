#INCLUDE "MNTC682.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "RWMAKE.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC682
Consulta de Planejamentos de Mobilizacao e Desmobilizacao de Equipamentos (Bens).

@author Wagner S. de Lacerda
@since 08/08/2011
@return
/*/
//---------------------------------------------------------------------
Function MNTC682()

	Local aNGBeginPrm := NGBeginPrm()

	Private aRotina   := aClone( MenuDef() )
	Private cCadastro := OemToAnsi(STR0001) //"Consulta de Planejamentos de Obras"
	Private cPrograma := "MNTC682"
	Private cPerg     := "MNTC682"
	Private cGrupo    := ""

	Private c200EmpOri := cEmpAnt //Armazena a Empresa Original
	Private c200FilOri := cFilAnt //Armazena a Filial Original

	Private nSMOCODIGO  := Len(SM0->M0_CODIGO)
	Private nSM0SIZEFIL := FWSizeFilial()

	Private aSize      := MsAdvSize()
	Private nLargura   := aSize[5]
	Private nAltura    := aSize[6]
	Private aZEMPS := {}

	If !MntCheckCC(cPrograma)
		Return .F.
	EndIf

	Inclui := .F.
	Altera := .F.

	//-------------------------------------------------------------------------
	// Parametrizacao da Consulta:
	//
	// MV_PAR01 - De Empresa/Filial ?
	// MV_PAR02 - Ate Empresa/Filial ?
	// MV_PAR03 - De Familia ?
	// MV_PAR04 - Ate Familia ?
	// MV_PAR05 - De Modelo ?
	// MV_PAR06 - Ate Modelo ?
	// MV_PAR07 - De Data ?
	// MV_PAR08 - Ate Data ?
	// MV_PAR09 - Linha Base ?
	//-------------------------------------------------------------------------

	If Pergunte(cPerg,.T.)
		MNTC682DO()
	EndIf

	NGReturnPrm( aNGBeginPrm )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de Menu Funcional.
@Param do array a Rotina:
	1. Nome a aparecer no cabecalho
	2. Nome da Rotina associada
	3. Reservado
	4. Tipo de Transacao a ser efetuada:
		1 - Pesquisa e Posiciona em um Banco de Dados
		2 - Simplesmente Mostra os Campos
		3 - Inclui registros no Bancos de Dados
		4 - Altera o registro corrente
		5 - Remove o registro corrente do Banco de Dados
	5. Nivel de acesso
	6. Habilita Menu Funcional

@author Wagner S. de Lacerda
@since 08/08/2011
@return Array com opcoes da rotina.
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina

	aRotina := { { STR0002, "AxPesqui", 0 , 1 },; //"Pesquisar"
					{ STR0003, "NGCAD01", 0 , 2 },; //"Visualizar"
					{ STR0004, "NGCAD01", 0 , 3 },; //"Incluir"
					{ STR0005, "NGCAD01", 0 , 4 },; //"Alterar"
					{ STR0006, "NGCAD01", 0 , 5, 3 } } //"Excluir"

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC682DO
Efetua o Processamento da Consulta.

@author Wagner S. de Lacerda
@since 09/08/2011
@return
/*/
//---------------------------------------------------------------------
Function MNTC682DO()

	Private aDados200  := {}
	Private nFWDISPTOT := 1
	Private nFWBRANCA1 := 2
	Private nFWLINBASE := 0
	Private nFWPLANEJA := 3
	Private nFWPROPRIO := 4
	Private nFWTERCEIR := 5
	Private nFWBRANCA2 := 6
	Private nFWSALDATU := 7

	Processa( {|| fProcDados() }, STR0008) //"Processando os Dados..."

	MNTC682CG()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fProcDados
Processa os Dados de Cada Empresa e Filial.

@author Wagner S. de Lacerda
@since 09/08/2011
@return
/*/
//---------------------------------------------------------------------
Static Function fProcDados()

	Local aArea		:= {}
	Local aTabelas	:= {}
	Local aAuxiliar	:= {}
	Local cOldEmpAtu	:= {}
	Local cOldFilAtu	:= {}

	/* Variaveis de Verificacao de Empresa e Filial */
	Local cVerEmp		:= ""
	Local cVerFil		:= ""
	Local lCompST6	:= .F.
	Local lCompST9	:= .F.
	Local lCompTQR	:= .F.

	/* Dados */
	Local lNova		:= .T.

	//Local aDSListEmps	:= {}
	Local aDadosTemp	:= {}

	Local nCapMod		:= 0
	Local nQtdeLB		:= 0

	Local cNomeFam	:= ""
	Local cNomeMod	:= ""
	Local cUniCapMod	:= ""
	/**/

	/* Contadores e Posicoes */
	Local nEmpFil  := 0
	Local nExstDad := 0
	Local nMeses   := 0

	Local nPos := 0, nX := 0, nY := 0
	/**/

	cOldEmpAtu := cEmpAnt
	cOldFilAtu := cFilAnt
	dbSelectArea("SM0")
	aArea := GetArea()

	//--------------------------------------------------------------
	// Processa os Dados
	//--------------------------------------------------------------
	aDados200 := {}
	aTabelas  := { {"ST6"}, {"ST9"}, {"TQR"},{"TVY"} }

	aZEMPS := NGDeAteEmp(MV_PAR01, MV_PAR02)

	ProcRegua( Len(aZEMPS) )
	For nEmpFil := 1 To Len(aZEMPS) //Ja filtrando pelas Empresas e Filiais

		cVerEmp := aZEMPS[nEmpFil, 1]
		cVerFil := aZEMPS[nEmpFil, 2]

		If Len( aAuxiliar := NGSEEKSM0(cVerEmp + cVerFil, {"M0_NOME", "M0_FILIAL"}) ) == 0
			Loop
		EndIf

		IncProc(STR0009 + cVerEmp + STR0010 + cVerFil) //"Processando Empresa "###" / Filial "

		NGPrepTbl(aTabelas,cVerEmp)

		aDadosTemp := {}

		lCompST6 := ( NGSX2MODO("ST6") == "C" )
		lCompST9 := ( NGSX2MODO("ST9") == "C" )
		lCompTQR := ( NGSX2MODO("TQR") == "C" )

		dbSelectArea("TVY")
		dbSetOrder(4)
		dbGoTop()
		dbSeek(cVerFil + MV_PAR03, .T.)
		While !EoF() .And. TVY->TVY_FILIAL == cVerFil .And. TVY->TVY_CODFAM <= MV_PAR04 //Ja filtrando pela Familia

			//Filtro pelo Modelo
			If TVY->TVY_TIPMOD < MV_PAR05 .Or. TVY->TVY_TIPMOD > MV_PAR06
				dbSelectArea("TVY")
				dbSkip()
				Loop
			EndIf

			//Filtro pela Data Inicio
			If !Empty(MV_PAR07) .And. TVY->TVY_DTINIC < MV_PAR07
				dbSelectArea("TVY")
				dbSkip()
				Loop
			EndIf

			If !Empty(MV_PAR08) .And.  TVY->TVY_DTINIC > MV_PAR08
				dbSelectArea("TVY")
				dbSkip()
				Loop
			EndIf

			//-------------------------------------------------------------------------
			//Recebe a Quantidade Prevista da Linha Base
			//-------------------------------------------------------------------------
			nQtdeLB := 0//TVY->TVY_QUANTB

			//-------------------------------------------------------------------------
			//Recebe o Nome da Familia
			//-------------------------------------------------------------------------
			cNomeFam := NGSeek('ST6', TVY->TVY_CODFAM, 1, 'ST6->T6_NOME', IIf(!lCompST6, cVerFil, Nil))

			//-------------------------------------------------------------------------
			//Recebe o Nome do Modelo, Capacidade Produtiva e Unidade desta Capacidade
			//-------------------------------------------------------------------------
			nCapMod    := 0
			cNomeMod   := ""
			cUniCapMod := ""

			dbSelectArea("TQR")
			dbSetOrder(1)
			If dbSeek( IIf(lCompTQR, xFilial("TQR"), cVerFil ) + TVY->TVY_TIPMOD )
				cNomeMod	 := TQR->TQR_DESMOD
				nCapMod	 := TQR->TQR_CPPROD
				cUniCapMod	 := TQR->TQR_UNPROD
			EndIf

			//Adiciona ao Array de Dados
			lNova := .F.

			If ( nExstDad := aScan(aDadosTemp, {|x| x[1] + x[3] == TVY->TVY_CODFAM+TVY->TVY_TIPMOD }) ) == 0
				lNova := .T.

				aAdd(aDadosTemp, { TVY->TVY_CODFAM, cNomeFam, TVY->TVY_TIPMOD, cNomeMod, nCapMod, cUniCapMod, {}, {}, {} } )

				nExstDad := Len(aDadosTemp)

				/* Dados do Array aDadosTemp:

				Codigo da Familia					| Nome da Familia							1, 2
				Codigo do Modelo					| Nome do Modelo							3, 4
				Capacidade Produtiva (Modelo)	| Unidade da Capacidade (Modelo)		5, 6
				{Planejamentos}					| {Datas de Compra dos Bens}			7, 8
				{Transferencias dos Bens}													9     */
			EndIf

			If lNova
				aAuxiliar := aClone( fBuscaDads(cVerEmp,cVerFil,TVY->TVY_CODFAM,TVY->TVY_TIPMOD) )
				aDadosTemp[nExstDad][8] := aClone( aAuxiliar[5] )
				aDadosTemp[nExstDad][9] := aClone( aAuxiliar[6] )
			EndIf

			/* Dados do Array aDadosTemp[nExstDad][7]:

			Data Inicio				| Data Fim										1, 2
			Disponibilidade Total	| Planejado									3, 4
			Proprio					| Terceiros									5, 6
			Saldo Atual				| Quantidade Linha Base						7, 8
			Datas de Desmobiiliazcao do Planejamento/Bem no Planejamento}		9     */

			aAdd(aDadosTemp[nExstDad][7], { TVY->TVY_DTINIC, TVY->TVY_DTFIM, aAuxiliar[1],;
												 TVY->TVY_QUANT, aAuxiliar[2], aAuxiliar[3], aAuxiliar[4], nQtdeLB, aClone( fMobDesmob(cVerFil,;
												 TVY->TVY_CODFAM, TVY->TVY_TIPMOD, TVY->TVY_DTINIC, TVY->TVY_DTFIM, TVY->TVY_QUANT) ) } )

			dbSelectArea("TVY")
			dbSkip()
		EndDo

		If Len(aDadosTemp) > 0
			aAuxiliar := NGSEEKSM0(cVerEmp + cVerFil, {"M0_NOME","M0_FILIAL"})

			aAdd(aDados200, {cVerEmp, aAuxiliar[1], cVerFil, aAuxiliar[2], aDadosTemp})
		EndIf

	Next nEmpFil

	NGPrepTbl(aTabelas,c200EmpOri)

	RestArea(aArea)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fProcDados
Processa os Dados de Cada Empresa e Filial.

@author Wagner S. de Lacerda
@since 11/08/2011
@Param 		cVerEmp [Obrig] - Define a Empresa para buscar os dados.
		 	cVerFil [Obrig] - Define a Filial para buscar os dados.
 			cVerFam [Obrig] - Define a Familia para buscar os dados.
 			cVerMod [Obrig] - Define o Modelo para buscar os dados.

@return aRet - Array contendo:
 					[1] - Disponibilidade Total
 					[2] - Proprio
 					[3] - Terceiros
 					[4] - Saldo Atual
/*/
//---------------------------------------------------------------------
Static Function fBuscaDads(cVerEmp, cVerFil, cVerFam, cVerMod)

	Local aRet := {}

	Local nDisponib  := 0
	Local nProprios  := 0
	Local nTerceiros := 0
	Local nSaldoAtu  := 0

	Local aCompra := {}
	Local nCompra := 0

	Local aZBTs := {}
	Local nZBTs := 0
	Local aTransfs := {}

	//---------------------------------------------------------------------
	//Verifica os Bens
	//---------------------------------------------------------------------
	If NGCADICBASE("T9_PROPRIE", "A", "ST9",.F.)

		dbSelectArea("ST9")
		dbSetOrder(4)
		dbGoTop()
		While !EoF()
			If ST9->T9_CODFAMI == cVerFam .And. ST9->T9_TIPMOD == cVerMod .And.;
				ST9->T9_CATBEM == "4" .And. ST9->T9_SITBEM <> "I"

				//---------------------------------------------------------------------
				//Atualiza contador de bens disponíveis
				//---------------------------------------------------------------------
				If ST9->T9_SITBEM == "A"
					nDisponib++
				EndIf

				//---------------------------------------------------------------------
				//Data de Compra do Bem
				//---------------------------------------------------------------------
				If !Empty(ST9->T9_DTCOMPR)

					//Verifica data da compra e proprietário do bem.
					If ( nCompra := aScan(aCompra, {|x| x[1] == ST9->T9_DTCOMPR .And. x[3] == ST9->T9_PROPRIE }) )== 0

						//Adiciona unidade do bem no array aCompra.
						aAdd(aCompra, {ST9->T9_DTCOMPR, 1, ST9->T9_PROPRIE}) //Data de Compra; Quantidade; Proprietario
					Else

						//Caso encontre a mesma data e proprietário do bem, adiciona 1 à quantidade.
						aCompra[nCompra][2] += 1
					EndIf

				EndIf

				//---------------------------------------------------------------------
				//Transferencias do Bem
				//---------------------------------------------------------------------
				//Veririfica se há transferências não verificadas
				If aScan(aTransfs, {|x| AllTrim( x[2] ) == AllTrim( ST9->T9_CODBEM ) }) == 0

					//Verifica se houveram transferências para o bem.
					If Len( aZBTs := aClone( fTransBem(ST9->T9_CODBEM) ) ) > 0

						//Caso tenha, adiciona todas as transferências no array aTransfs.
						For nZBTs := 1 To Len(aZBTs)
							aAdd(aTransfs, {aZBTs[nZBTs], ST9->T9_CODBEM, ST9->T9_PROPRIE}) //Transferencias; Codigo do Bem; Proprietario
						Next nZBTs

					EndIf
				EndIf

				//---------------------------------------------------------------------
				//Atualiza contador de bens Próprios e Terceiros.
				//---------------------------------------------------------------------
				If ST9->T9_FILIAL == cVerFil
					IIf( ST9->T9_PROPRIE == "1", nProprios++, Nil ) 	//Proprios da Filial
					IIf( ST9->T9_PROPRIE == "2", nTerceiros++, Nil )	//Terceiros da Filial
				EndIf

			EndIf

			dbSelectArea("ST9")
			dbSkip()
		EndDo

		nSaldoAtu := nProprios + nTerceiros
	EndIf

	aSort(aCompra, , , {|x,y| x[1] < y[1] })

	aRet := {nDisponib,nProprios,nTerceiros,nSaldoAtu,aCompra,aTransfs}

Return aRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fMobDesmob
Busca as Datas de Mobilizacao e Desmobilizacao.

@author Wagner S. de Lacerda
@since 11/08/2011
@Param 	cVerFil	[Obrig] Define a Filial para buscar os dados.
 		cVerFam	[Obrig] Define a Familia para buscar os dados.
 		cVerMod	[Obrig] Define o Modelo para buscar os dados.
		dDtIniPlan	[Obrig] Indica a Data Inicial do Planejamento.
 		dDtFimPlan	[Obrig] Indica a Data Final do Planejamento.
 		nQtdePlan	[Obrig] Indica a Quantidade de Equipamentos planejados.

@return aRet - Array contendo as Desmobilizacoes dos Bens.
/*/
//---------------------------------------------------------------------
Static Function fMobDesmob(cVerFil, cVerFam, cVerMod, dDtIniPlan, dDtFimPlan, nQtdePlan)

	Local nJaDesmob, nDesmobFim, nPos, dData, nData

	Local aDesmob		:= {}
	Local lAddDesmob	:= .T.

	Store 0 To nJaDesmob, nDesmobFim, nPos, dData, nData

	dbSelectArea("ST9")
	dbSetOrder(4)
	dbGoTop()
	While !EoF()
		If ST9->T9_CODFAMI == cVerFam .And. ST9->T9_TIPMOD == cVerMod .And. ST9->T9_CATBEM == "4" .And. ST9->T9_SITBEM == "A"

			//Desmobilizacoes
			If ST9->T9_FILIAL == cVerFil

				For nData := 1 To 2

					lAddDesmob := .T.

					If Empty( dData := IIf( nData == 1, ST9->T9_DTBAIXA, ST9->T9_DTDESMO ) )
						Loop
					EndIf

					If lAddDesmob

						//Verifica data de desmobilidação e proprietário do bem.
						If ( nPos := aScan(aDesmob, {|x| x[1] == dData .And. x[4] == ST9->T9_PROPRIE }) ) == 0

							//Adiciona unidade do bem no array aCompra.
							aAdd(aDesmob, {dData, 1, "B", ST9->T9_PROPRIE} ) //{ Data, Qtde, Cad. Desmob. ["B" (Bem); "P" (Planejamento] ; Proprietario
						Else

							//Caso encontre a mesma data e proprietário do bem, adiciona 1 à quantidade.
							aDesmob[nPos][2] += 1
						EndIf

						nJaDesmob++
					EndIf
				Next nData
			EndIf

		EndIf

		dbSelectArea("ST9")
		dbSkip()
	EndDo

	aSort(aDesmob, , , {|x,y| x[1] < y[1] })

	//Adiciona por ultimo quantos equipamentos serao desmobilizados ao fim do planejamento, contando com os que foram desmbilizados durante ele
	nDesmobFim := (nQtdePlan - nJaDesmob)
	nDesmobFim := IIf(nDesmobFim < 0, 0, nDesmobFim)

	aAdd(aDesmob, { dDtFimPlan, nDesmobFim, "P" } )

Return aDesmob

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC682CG
Monta a Consulta Gerencial dos Planejamentos.

@author Wagner S. de Lacerda
@since 10/08/2011
@return 	.T. -> Consulta OK.
			.F. -> Nao foi possivel montar a consulta.
@Param
/*/
//---------------------------------------------------------------------
Function MNTC682CG()

	Local aTemp	 := {}
	Local aHeadST6 := {}

	Local oObjTemp := Nil
	Local nX, nPos

	Local oPanelTot

	Private nCorBack := NGCOLOR()[2] //RGB(0,0,80)
	Private nCorFore := NGCOLOR()[1] //RGB(0,0,80)

	/* Objetos da Tela */
	Private oDlgC200
	Private oNormFont, oBoldFont
	Private nTamTOP, nTamALL

	Private oPnlTop

	Private oPnlLTop
	Private oLTopBtn, lLTopBtn
	Private oLTopGet1, cLTopGet1
	Private oLTopGet2, nLTopGet2

	Private oPnlMTop
	Private oLTopBrw, bLTopBrwLn

	Private oPnlRTop
	Private oRTopBrw, bRTopBrwLn

	Private oPnlAll
	Private oBlackPnl

	Private oPnlTAll

	Private oPnlTLAll
	Private oTLAllBtn
	Private oTLAllGet1, cTLAllGet1
	Private oTLAllGet2, cTLAllGet2

	Private oPnlTRAll
	Private oTRAllBrw, bTRAllBrwL

	Private oPnlAAll
	Private oPnlAAllDt
	Private oAAllDtIni, dAAllDtIni
	Private oAAllDtFim, dAAllDtFim
	Private oAAllAno01
	Private oAAllAno, cAAllAno
	Private oAAllAno02
	Private oAAllFWBrw
	/**/

	/* Variaveis de Controle de Dados */
	Private aTopEmps   := {}
	Private aTopFilis  := {}
	Private aAllFWPlan := {}, aAllFWPBra := {}
	Private aAllFWCols := {}, aAllFWCBra := {}
	/**/

	If Len(aDados200) == 0
		ApMsgAlert(STR0011) //"Não foi possível montar a Consulta com os parâmetros selecionados."
		Return .F.
	EndIf

	//Carrega as Variaveis Em Branco
	fCarArrays(0)

	SetKEY(VK_F6,{|| fTrvEmpFil()})

	//Monta a Tela
	nTamTOP := 070 + If(nAltura > 750,20,0)
	nTamAll := 1000

	Define MsDialog oDlgC200 TITLE cCadastro FROM aSize[7],0 TO nAltura,nLargura COLOR CLR_BLACK, CLR_WHITE OF oMainWnd PIXEL

	oDlgC200:lMaximized := .T.

	oNormFont := TFont():New("Verdana", , 14, , .F., , , , , , .F.)
	oBoldFont := TFont():New("Verdana", , 14, , .T., , , , , , .F.)

	//------------------------------------
	//Cria Painel para adequação da tela.
	//------------------------------------
	oPanelTot := TPanel():New(0,0,,oDlgC200,,,,,,0,0,.F.,.F.)
	oPanelTot:Align := CONTROL_ALIGN_ALLCLIENT

	//----------------------------------
	//Painel TOP
	//----------------------------------
	oPnlTop := TPanel():New(01, 01, , oPanelTot, , , , CLR_BLACK, CLR_WHITE, 50, nTamTOP, .T., .T.)
	oPnlTop:Align := CONTROL_ALIGN_TOP

	//----------------------------------
	//Painel TOP LEFT
	//----------------------------------
	oPnlLTop := TPanel():New(01, 01, , oPnlTop, , , , CLR_BLACK, CLR_WHITE, 150, nTamTOP, .T., .T.)
	oPnlLTop:Align := CONTROL_ALIGN_LEFT

	//Titulo
	oObjTemp := TPanel():New(01, 01, , oPnlLTop, , , , CLR_WHITE, nCorBack, 50, 10, .T., .T.)
	oObjTemp:Align := CONTROL_ALIGN_TOP

	//Botao
	lLTopBtn := .T. //Inicia Habilitado
	oLTopBtn := TButton():New(015, 025, STR0012, oPnlLTop, {|| fTrvEmpFil()},; //"Travar Empresa/Filial"
	100, 10, , , .F., .T., .F., , .F., , , .F. )

	//Empresa
	@ 035, 010 SAY OemToAnsi(STR0013) FONT oBoldFont COLOR nCorFore OF oPnlLTop PIXEL //"Empresa:"

	cLTopGet1 := ""
	oLTopGet1 := TGet():New(034, 050, {|u| If(PCount() > 0, cLTopGet1 := u, cLTopGet1)},;
								oPnlLTop, 060, 008, "@!", {|| .T.}, nCorFore, CLR_WHITE, oNormFont,;
								.F., , .T., , .F., {|| .T. }, .F., .F., , .T., .F., "", "cLTopGet1", , , , .F.)

	oLTopGet1:bHelp := {|| ShowHelpCpo(STR0014,; //"Empresa"
											{ STR0015 }, 2,; //"Empresa selecionada para consultar os planejamentos."
											{}, 2)}

	//Filial
	@ 050, 010 SAY OemToAnsi(STR0016) FONT oBoldFont COLOR nCorFore OF oPnlLTop PIXEL //"Filial:"

	cLTopGet2 := ""
	oLTopGet2 := TGet():New(049, 050, {|u| If(PCount() > 0, cLTopGet2 := u, cLTopGet2)},;
								oPnlLTop, 060, 008, "@!", {|| .T.}, nCorFore, CLR_WHITE, oNormFont,;
								.F., , .T., , .F., {|| .T. }, .F., .F., , .T., .F., "", "cLTopGet2", , , , .F.)

	oLTopGet2:bHelp := {|| ShowHelpCpo(STR0017,; //"Filial"
											{ STR0018 }, 2,; //"Filial selecionada para consultar os planejamentos."
											{} ,2)}


	//----------------------------------
	//Painel TOP-MID
	//----------------------------------
	oPnlMTop := TPanel():New(01, 01, , oPnlTop, , , , CLR_BLACK, CLR_WHITE, (nLargura*0.19), nTamTOP, .T., .T.)
	oPnlMTop:Align := CONTROL_ALIGN_LEFT

	//Titulo
	oObjTemp := TPanel():New(01, 01, , oPnlMTop, , , , CLR_WHITE, nCorBack, 50, 10, .T., .T.)
	oObjTemp:Align := CONTROL_ALIGN_TOP

	TSay():New(02, 05, {|| OemToAnsi(STR0013)}, oObjTemp, , oBoldFont, , ; //"Empresa:"
					, ,.T., nCorFore, nCorBack, 150, 010)

	//Browse de Empresas
	oLTopBrw := TWBrowse():New(001, 001, 1000, 1000,, {STR0014, STR0019},, oPnlMTop,,,,, {|| },,,,,,, .F.,, .T.,, .F.,,,)

		oLTopBrw:SetArray(aTopEmps)
		oLTopBrw:bChange := {|| fChgEmp()}
		oLTopBrw:Align := CONTROL_ALIGN_ALLCLIENT

	bLTopBrwLn := {|| { PadR(aTopEmps[oLTopBrw:nAt,01], 20, " "),;
							PadR(aTopEmps[oLTopBrw:nAt,02], 60, " ")} }

	oLTopBrw:bLine := bLTopBrwLn

	//----------------------------------
	//Painel TOP-RIGHT
	//----------------------------------
	oPnlRTop := TPanel():New(01, 01, , oPnlTop, , , , CLR_BLACK, CLR_WHITE, (nLargura*0.19), nTamTOP, .T., .T.)
		oPnlRTop:Align := CONTROL_ALIGN_ALLCLIENT

	//Titulo
	oObjTemp := TPanel():New(01, 01, , oPnlRTop, , , , CLR_WHITE, nCorBack, 50, 10, .T., .T.)
		oObjTemp:Align := CONTROL_ALIGN_TOP

	TSay():New(02, 05, {|| OemToAnsi(STR0016)}, oObjTemp,, oBoldFont,,,,.T., nCorFore, nCorBack, 150, 010) //"Filial:"

	//Browse de Filiais
	oRTopBrw := TWBrowse():New(001, 001, 1000, 1000,, { STR0017, STR0019 },, oPnlRTop,,,,, {|| },,,,,,, .F.,, .T.,, .F.,,,)

	oRTopBrw:SetArray(aTopFilis)
	oRTopBrw:bChange := {|| fChgFil()}

	bRTopBrwLn := {|| { PadR(aTopFilis[oRTopBrw:nAt,01],20," "),;
							PadR(aTopFilis[oRTopBrw:nAt,02],60," ")} }
	oRTopBrw:bLine := bRTopBrwLn
	oRTopBrw:Align := CONTROL_ALIGN_ALLCLIENT

	//----------------------------------
	//Painel ALL
	//----------------------------------
	oPnlAll := TPanel():New(01, 01, , oPanelTot, , , , CLR_BLACK, CLR_WHITE, 50, nTamALL, .T., .T.)
	oPnlAll:Align := CONTROL_ALIGN_ALLCLIENT

	//----------------------------------
	//Painel ALL-TOP
	//----------------------------------
	oPnlTAll := TPanel():New(01, 01, , oPnlAll, , , , CLR_BLACK, CLR_WHITE, 80, nTamTOP, .T., .T.)
	oPnlTAll:Align := CONTROL_ALIGN_TOP

	//----------------------------------
	//Painel ALL-TOP-LEFT
	//----------------------------------
	oPnlTLAll := TPanel():New(01, 01, , oPnlTAll, , , , CLR_BLACK, CLR_WHITE, 150, nTamTOP, .T., .T.)
	oPnlTLAll:Align := CONTROL_ALIGN_LEFT

	//Titulo
	oObjTemp := TPanel():New(01, 01, , oPnlTLAll, , , , CLR_WHITE, nCorBack, 50, 10, .T., .T.)
	oObjTemp:Align := CONTROL_ALIGN_TOP

	//Botao
	oTLAllBtn := TButton():New(015, 025, STR0020, oPnlTLAll, {|| fConPlans()},; //"Consultar Planejamentos"
									100, 10, , , .F., .T., .F., , .F., , , .F. )

	//Familia
	@ 035, 010 SAY OemToAnsi(STR0021) FONT oBoldFont COLOR nCorFore OF oPnlTLAll PIXEL //"Família:"

	cTLAllGet1 := ""
	oTLAllGet1 := TGet():New(034, 050, {|u| If(PCount() > 0, cTLAllGet1 := u, cTLAllGet1)},;
									oPnlTLAll, 060, 008, "@!", {|| .T.}, nCorFore, CLR_WHITE, oNormFont,;
									.F., , .T., , .F., {|| .T. }, .F., .F., , .T., .F., "", "cTLAllGet1", , , , .F.)

	oTLAllGet1:bHelp := {|| ShowHelpCpo(STR0022,; //"Familia"
												{ STR0023 }, 2,; //"Família dos planejamentos."
												{}, 2)}

	//Modelo
	@ 050, 010 SAY OemToAnsi(STR0024) FONT oBoldFont COLOR nCorFore OF oPnlTLAll PIXEL //"Modelo:"
	cTLAllGet2 := ""
	oTLAllGet2 := TGet():New(049, 050, {|u| If(PCount() > 0, cTLAllGet2 := u, cTLAllGet2)},;
									oPnlTLAll, 060, 008, "@!", {|| .T.}, nCorFore, CLR_WHITE, oNormFont,;
									.F., , .T., , .F., {|| .T. }, .F., .F., , .T., .F., "", "cTLAllGet2", , , , .F.)

	oTLAllGet2:bHelp := {|| ShowHelpCpo(STR0025,; //"Modelo"
									{ STR0026 }, 2,; //"Modelo dos planejamentos."
									{} ,2)}

	//----------------------------------
	//Painel ALL-TOP-RIGHT
	//----------------------------------
	oPnlTRAll := TPanel():New(01, 01, , oPnlTAll, , , , CLR_BLACK, CLR_WHITE, 100, nTamTOP, .T., .T.)
	oPnlTRAll:Align := CONTROL_ALIGN_ALLCLIENT

	//Titulo
	oObjTemp := TPanel():New(01, 01, OemToAnsi(STR0027), oPnlTRAll, oBoldFont, .T., ,nCorFore, nCorBack, 50, 10, .T., .T.) //"Planejamentos"
	oObjTemp:Align := CONTROL_ALIGN_TOP

	//Browse de Família

	aHeadST6 := { RetTitle("T6_CODFAMI"), RetTitle("T6_NOME"),;
					RetTitle("TQR_TIPMOD"), RetTitle("TQR_DESMOD"),;
					RetTitle("TQR_CPPROD"), RetTitle("TQR_UNPROD") }

	oTRAllBrw := TWBrowse():New(001, 001, 1000, 1000, ,aHeadST6,, oPnlTRAll,,,,, {|| },,,,,,, .F.,, .T.,, .F.,,,)

	oTRAllBrw:SetArray(aAllFWPlan)
	oTRAllBrw:bChange := {|| fChgPlan() }

	bTRAllBrwL := {|| {	PADR(aAllFWPlan[oTRAllBrw:nAt,01],20," "),;
		PADR(aAllFWPlan[oTRAllBrw:nAt,02],60," "),;
		PADR(aAllFWPlan[oTRAllBrw:nAt,03],20," "),;
		PADR(aAllFWPlan[oTRAllBrw:nAt,04],60," "),;
		PADL(Transform(aAllFWPlan[oTRAllBrw:nAt,05],"@E 999,999.99"),20," "),;
		PADR(aAllFWPlan[oTRAllBrw:nAt,06],20," ")} }

	oTRAllBrw:bLine := bTRAllBrwL
	oTRAllBrw:Align := CONTROL_ALIGN_ALLCLIENT

		//----------------------------------
		//³ Painel ALL-ALL              ³
		//----------------------------------
	oPnlAAll := TPanel():New(01, 01, , oPnlAll, , , , /*CLR_BLACK*/, CLR_WHITE, 100, nTamALL, .T., .T.)
	oPnlAAll:Align := CONTROL_ALIGN_ALLCLIENT

			//Titulo
	oObjTemp := TPanel():New(01, 01, OemToAnsi(STR0028),; //"Equipamentos Disponíveis x Planejados"
		oPnlAAll, oBoldFont, .T., ,nCorFore, nCorBack, 50, 10, .T., .T.)

	oObjTemp:Align := CONTROL_ALIGN_TOP

			//----------------------------------
			//³ Painel ALL-DATA             ³
			//----------------------------------
	oPnlAAllDt := TPanel():New(01, 01, , oPnlAAll, , , , CLR_BLACK, CLR_WHITE, 50, 012)
	oPnlAAllDt:Align := CONTROL_ALIGN_TOP

				//Data Inicial
	@ 003, 010 Say OemToAnsi(STR0029) FONT oBoldFont COLOR nCorFore OF oPnlAAllDt PIXEL //"Data Inicial:"

	dAAllDtIni := CToD("")
	oAAllDtIni := TGet():New(002, 060, {|u| If(PCount() > 0, dAAllDtIni := u, dAAllDtIni)},;
							oPnlAAllDt, 060, 008, "@!", {|| .T.}, nCorFore, CLR_WHITE, oNormFont,;
							.F., , .T., , .F., {|| .T. }, .F., .F., , .T., .F., "", "dAAllDtIni", , , , .F.)

	oAAllDtIni:bHelp := {|| ShowHelpCpo(STR0030,; //"Data Inicio"
							{ STR0031 }, 2, {}, 2) } //"Data Inicial dos Planejamentos para a Família e o Modelo selecionados."

	//Data Final
	@ 003, 130 Say OemToAnsi(STR0032) FONT oBoldFont COLOR nCorFore OF oPnlAAllDt PIXEL //"Data Final:"
	oAAllDtFim := TGet():New(002, 180, {|u| If(PCount() > 0, dAAllDtFim := u, dAAllDtFim)},;
									oPnlAAllDt, 060, 008, "@!", {|| .T.}, nCorFore, CLR_WHITE, oNormFont,;
									.F., , .T., , .F., {|| .T. }, .F., .F., , .T., .F., "", "dAAllDtFim", , , , .F.)

	oAAllDtFim:bHelp := {|| ShowHelpCpo(STR0030,; //"Data Inicio"
												{ STR0033 }, 2,; //"Data Final dos Planejamentos para a Família e o Modelo selecinoados."
												{}, 2)}

	//Botao de Avancar o Ano
	oAAllAno01 := TBtnBmp2():New(01, 01, 40, 26, "right", , , , {|| fGoAno(1)}, oPnlAAllDt, OemToAnsi(STR0034)) //"Avançar"
	oAAllAno01:Align := CONTROL_ALIGN_RIGHT

	//Ano Atual da Consulta
	cAAllAno := "    "
	oAAllAno := TGet():New(002, 010, {|u| If(PCount() > 0, cAAllAno := u, cAAllAno)},;
								oPnlAAllDt, 020, 008, "@!", {|| .T.}, nCorFore, CLR_WHITE, oNormFont,;
								.F., , .T., , .F., {|| .T. }, .F., .F., , .T., .F., "", "cAAllAno", , , , .F.)

	oAAllAno:bHelp := {|| ShowHelpCpo(STR0035,;	//"Ano"
							{ STR0036 }, 2,;			//"Ano atual da consulta abaixo."
							{}, 2)}

	oAAllAno:Align := CONTROL_ALIGN_RIGHT

	//Botao de Retroceder o Ano
	oAAllAno02 := TBtnBmp2():New(01, 01, 40, 26, "left", , , , {|| fGoAno(-1)}, oPnlAAllDt, OemToAnsi(STR0037)) //"Retroceder"
	oAAllAno02:Align := CONTROL_ALIGN_RIGHT

	//----------------------------------
	//Browse da Consulta
	//----------------------------------
	fMontaCG()

	//----------------------------------
	//Inicializa os Dados
	//----------------------------------
	fInitDados()

	ACTIVATE MSDIALOG oDlgC200 ON INIT EnchoiceBar(oDlgC200, {|| oDlgC200:End() }, {|| oDlgC200:End() })

	SetKEY(VK_F6,{|| })

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fInitDados
Carrega o Estado Inicial das Variaveis.

@author Wagner S. de Lacerda
@since 11/08/2011
@return 	.T.
@Param nParam -> Obrigatorio;
        Indica qual dos tipos de array deve carregar:
        	1 - Empresas
            2 - Filiais

/*/
//---------------------------------------------------------------------

Static Function fInitDados()

	dAAllDtIni	 := CToD("")	//Data Inicial
	dAAllDtFim	 := CToD("")	//Data Final
	cAAllAno	 := "    "			//Ano Atual da Consulta

	//------------------------------------------------------------------------
	//Empresas
	//------------------------------------------------------------------------
	Processa({|| fCarArrays(1) }, STR0038) //"Processando..."

	//------------------------------------------------------------------------
	//Filiais
	//------------------------------------------------------------------------
	Processa({|| fCarArrays(2) }, STR0038) //"Processando..."

	//------------------------------------------------------------------------
	//Travar Empresa/Filial
	//------------------------------------------------------------------------
	lLTopBtn := .F.
	fTrvEmpFil()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fCarArrays
Carrega os Arrays.

@author Wagner S. de Lacerda
@since 10/08/2011
@return 	.T.
@Param nParam -> Obrigatorio;
        Indica qual dos tipos de array deve carregar:
        	1 - Empresas
            2 - Filiais

/*/
//---------------------------------------------------------------------
Static Function fCarArrays(nParam)

	Local aAuxiliar
	Local cAuxiliar
	Local nX, nY, nPos, nEmpFil

	Default nParam := 0

	If nParam == 0

		If Len(aTopEmps) == 0
			aTopEmps := { Array(2) }
		EndIf

		If Len(aTopFilis) == 0
			aTopFilis := { Array(2) }
		EndIf

		aAllFWPBra := {0,0,0,0,0,0}
		If Len(aAllFWPlan) == 0
			aAllFWPlan := { aAllFWPBra }
		EndIf

		aAllFWCBra := Array(14)
		If Len(aAllFWCols) == 0
			aAllFWCols := { aAllFWCBra }
		EndIf

	ElseIf nParam == 1

		ProcRegua(Len(aDados200))

		//Carrega as Empresas
		aTopEmps := {}

		For nX := 1 To Len(aDados200)
			IncProc(STR0039) //"Carregando Empresas..."

			If ( nPos := aScan(aTopEmps, {|x| x[1] == aDados200[nX][1] }) )== 0
				aAdd(aTopEmps, {aDados200[nX][1], aDados200[nX][2]}) // {Empresa, Nome}
			EndIf
		Next nX

	ElseIf nParam == 2

		//Carrega as Filiais
		cAuxiliar := cLTopGet1
		aTopFilis := {}

		ProcRegua(Len(aDados200))

		For nX := 1 To Len(aDados200)
			If aDados200[nX][1] == cAuxiliar
				IncProc(STR0040) //"Carregando Filiais..."

				If ( nPos := aScan(aTopFilis, {|x| x[1] == aDados200[nX][3] }) )== 0
					aAdd(aTopFilis, {aDados200[nX][3], aDados200[nX][4]}) // { Filial, Nome }
				EndIf
			EndIf
		Next nX

		If Len(aTopFilis) == 0
			fCarArrays(0)
		EndIf

	ElseIf nParam == 3

		//Carrega os Planejamentos por Familia e Modelo
		cAuxiliar  := cLTopGet1 + cLTopGet2
		aAllFWPlan := {}

		ProcRegua( Len(aDados200) )

		If ( nEmpFil := aScan(aDados200, {|x| x[1]+x[3] == cAuxiliar }) ) > 0

			aAuxiliar := aDados200[nEmpFil][5]

			For nY := 1 To Len(aAuxiliar)
				IncProc(STR0041) //"Carregando Planejamentos..."

				If ( nPos := aScan(aAllFWPlan, {|x| x[1] + x[3] == aAuxiliar[nY, 1] + aAuxiliar[nY, 3] }) ) == 0

					//Array Struct:   Familia;          Nome;             Modelo;           Nome;             Cap. Produtiva;   Und. da Capacidade
					aAdd(aAllFWPlan, {aAuxiliar[nY][1], aAuxiliar[nY][2], aAuxiliar[nY][3], aAuxiliar[nY][4], aAuxiliar[nY][5], aAuxiliar[nY][6]})
				EndIf
			Next nY
		EndIf

		If Len(aAllFWPlan) == 0
			fCarArrays(0)
		EndIf
	EndIf

	If nParam == 0 .Or. nParam == 1
		If Type("oLTopBrw") == "O"
			oLTopBrw:SetArray(aTopEmps)
			oLTopBrw:bLine := bLTopBrwLn
			oLTopBrw:GoTop()
			oLTopBrw:Refresh()
		EndIf
	EndIf

	If nParam == 0 .Or. nParam == 2
		If Type("oRTopBrw") == "O"
			oRTopBrw:SetArray(aTopFilis)
			oRTopBrw:bLine := bRTopBrwLn
			oRTopBrw:GoTop()
			oRTopBrw:Refresh()
		EndIf
	EndIf

	If nParam == 0 .Or. nParam == 3
		If Type("oLTopBrw") == "O"
			oTRAllBrw:SetArray(aAllFWPlan)
			oTRAllBrw:bLine := bTRAllBrwL
			oTRAllBrw:GoTop()
			oTRAllBrw:Refresh()
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fCarArrays
Executa o Change do Browse das Empresas.

@author Wagner S. de Lacerda
@since 10/08/2011
@return 	.T.

/*/
//---------------------------------------------------------------------
Static Function fChgEmp()

	If IsInCallStack("fTrvEmpFil")
		Return .T.
	EndIf

	cLTopGet1 := aTopEmps[oLTopBrw:nAt][1]
	oLTopGet1:CtrlRefresh()

	Processa({|| fCarArrays(2) }, STR0038) //"Processando..."
	fChgFil()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fChgFil
Executa o Change do Browse das Filiais.

@author Wagner S. de Lacerda
@since 10/08/2011
@return 	.T.
@Param nParam -> Obrigatorio;
        Indica qual dos tipos de array deve carregar:
        	1 - Empresas
            2 - Filiais

/*/
//---------------------------------------------------------------------
Static Function fChgFil()

	If IsInCallStack("fTrvEmpFil")
		Return .T.
	EndIf

	cLTopGet2 := aTopFilis[oRTopBrw:nAt][1]
	oLTopGet2:CtrlRefresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fChgPlan
Executa o Change do Browse dos Planejamentos.

@author Wagner S. de Lacerda
@since 11/08/2011
@return

/*/
//---------------------------------------------------------------------
Static Function fChgPlan()

	cTLAllGet1 := aAllFWPlan[oTRAllBrw:nAt][1]
	oTLAllGet1:CtrlRefresh()

	cTLAllGet2 := aAllFWPlan[oTRAllBrw:nAt][3]
	oTLAllGet2:CtrlRefresh()

	MsgRun(STR0042, STR0043, {|| fCarFWCols() }) //"Carregando a Consulta..."###"Aguarde..."

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fTrvEmpFil
Trava a selecao das Empresas e Filiais.

@author Wagner S. de Lacerda
@since 11/08/2011
@return
/*/
//---------------------------------------------------------------------
Static Function fTrvEmpFil()

	fChgEmp()
	fChgFil()

	If Empty(cLTopGet1) .Or. Empty(cLTopGet2)
		ApMsgInfo(STR0044,STR0045) //"Favor selecionar a Empresa e Filial."###"Atenção"
		Return .F.
	EndIf

	If !( lLTopBtn := !lLTopBtn )
		Processa({|| fCarArrays(3) }, STR0038) //"Processando..."


		oLTopBtn:SetText(STR0046) //"Selecionar Empresa/Filial"
		oLTopBtn:Refresh()

		oLTopBrw:Disable()
		oRTopBrw:Disable()

		oTLAllBtn:Enable()
		oTLAllGet1:Enable()
		oTLAllGet2:Enable()
		oTRAllBrw:Enable()

		oAAllFWBrw:Enable()

		fBlackPnl(.F.)
	Else
		oLTopBtn:SetText(STR0012) //"Travar Empresa/Filial"
		oLTopBtn:Refresh()

		oLTopBrw:Enable()
		oRTopBrw:Enable()

		oTLAllBtn:Disable()
		oTLAllGet1:Disable()
		oTLAllGet2:Disable()
		oTRAllBrw:Disable()

		oAAllFWBrw:Disable()

		fBlackPnl(.T.)
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fConPlans
Consulta os Planejamentos da Familia e Modelo selecionados.

@author Wagner S. de Lacerda
@since 15/08/2011
@return .t.
/*/
//---------------------------------------------------------------------
Static Function fConPlans()

	Local aArea     := {}
	Local aTabelas  := {}
	Local aHeadPlan := {}

	/* Objetos da Tela */
	Local oDlgPlans := Nil
	Local oPlansTOP := Nil
	Local oPlansALL := Nil
	Local oPlansBOT := Nil

	Private oPlansBrw := Nil
	Private aPlanejas := {}
	/**/

	If Empty(cLTopGet1) .Or. Empty(cLTopGet2)
		ApMsgInfo(STR0044,STR0045) //"Favor selecionar a Empresa e Filial."###"Atenção"
		Return .F.
	EndIf

	If Empty(cTLAllGet1) .Or. Empty(cTLAllGet2)
		ApMsgInfo(STR0047,STR0045) //"Favor selecionar a Família e Modelo dos Planejamentos."###"Atenção"
		Return .F.
	EndIf

	aArea := GetArea()

	//Consulta os Planejamentos
	aTabelas  := { {"ST6"}, {"ST9"}, {"TQR"}, {"TVY"} }

	NGPrepTbl(aTabelas,cLTopGet1)

	aPlanejas := {}

	MsgRun(STR0048, STR0043, {|| fCarPlans() }) //"Carregando os Planejamentos..."###"Aguarde..."

	If Len(aPlanejas) == 0
		ApMsgAlert(STR0049) //"Os planejamentos desta Família e Modelo não foram encontrados!"
		Return .F.
	EndIf

	SetKEY(VK_F6,{|| })

	//Monta o Browse
	Define MsDialog oDlgPlans TITLE OemToAnsi(STR0027) FROM 0,0 TO 350,600 COLOR CLR_BLACK, CLR_WHITE OF oMainWnd PIXEL //"Planejamentos"

	//Painel TOP
	oPlansTOP := TPanel():New(01, 01, , oDlgPlans, , , , CLR_BLACK, CLR_WHITE, 50, 20, .T., .T.)
	oPlansTOP:Align := CONTROL_ALIGN_TOP

	//Quantidade de Planejamentos
	TSay():New(005, 010, {|| OemToAnsi(STR0050)}, oPlansTOP, , oBoldFont, , ; //"Planejamentos: "
					, ,.T., CLR_BLACK, CLR_WHITE, 080, 010)

	TSay():New(005, 080, {|| Transform(Len(aPlanejas),"@E 999,999")}, oPlansTOP, , oNormFont, , ;
					, ,.T., CLR_BLACK, CLR_WHITE, 080, 010)

	//Painel ALL
	oPlansALL := TPanel():New(01, 01, , oDlgPlans, , , , CLR_BLACK, CLR_WHITE, 50, 50, .F., .F.)
	oPlansALL:Align := CONTROL_ALIGN_ALLCLIENT

	//Browse de Planejamentos

	aHeadPlan := {"ID", STR0051, STR0025, STR0052, STR0053, STR0054, STR0055}

	/* STR0051 - "Família"
	   STR0025 - "Modelo"
	   STR0052 - "Data Início"
	   STR0053 - "Data Fim"
	   STR0054 - "Qtde. Prevista"
	   STR0055 - "Responsável" */

	oPlansBrw := TWBrowse():New(001, 001, 1000, 1000,, aHeadPlan,, oPlansALL,,,,, {|| },,,,,,, .F.,, .T.,, .F.,,,)

	oPlansBrw:SetArray(aPlanejas)
	oPlansBrw:bLine := {|| {	PadR(aPlanejas[oPlansBrw:nAt,03]  , 15, " "),;
								 PadR( aPlanejas[oPlansBrw:nAt,04], 20, " "),;
								 PadR( aPlanejas[oPlansBrw:nAt,05], 20, " "),;
								 PadR( aPlanejas[oPlansBrw:nAt,06], 20, " "),;
								 PadR( aPlanejas[oPlansBrw:nAt,07], 20, " "),;
								 PadL( Transform(aPlanejas[oPlansBrw:nAt,08], "@E 999,999"), 20, " "),;
								 PadR( UsrFullName(aPlanejas[oPlansBrw:nAt,09]), 80, " ")} }

	oPlansBrw:Align := CONTROL_ALIGN_ALLCLIENT

	//Painel BOT
	oPlansBOT := TPanel():New(01, 01, , oDlgPlans, , , , CLR_BLACK, CLR_WHITE, 50, 15, .T., .T.)
	oPlansBOT:Align := CONTROL_ALIGN_BOTTOM

	//Visualizar
	TButton():New(002, 010, STR0003, oPlansBOT, {|| fVisPlans() },; //"Visualizar"
						40, 10, , , .F., .T., .F., , .F., , , .F. )

	//Sair
	TButton():New(002, 253, STR0056, oPlansBOT, {|| oDlgPlans:End()},; //"Sair"
						40, 10, , , .F., .T., .F., , .F., , , .F. )

	Activate MsDialog oDlgPlans Centered

	//Devolve as condicoes anteriores das tabelas
	NGPrepTbl(aTabelas, c200EmpOri)

	RestArea(aArea)

	SetKey(VK_F6, {|| fTrvEmpFil() })

	oTRAllBrw:SetFocus()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fCarPlans
Carregaa os Planejamentos da Familia e Modelo selecionados.

@author Wagner S. de Lacerda
@since 15/08/2011
@return .t.
/*/
//---------------------------------------------------------------------
Static Function fCarPlans()

	dbSelectArea("TVY")
	dbSetOrder(4)
	dbGoTop()
	dbSeek( cLTopGet2 + cTLAllGet1, .T.)
	While !Eof() .And. TVY->TVY_FILIAL == cLTopGet2 .And. TVY->TVY_CODFAM == cTLAllGet1 //Ja filtrando pela Familia

		//Filtro pelo Modelo
		If TVY->TVY_TIPMOD <> AllTrim(cTLAllGet2)
			dbSelectArea("TVY")
			dbSkip()
			Loop
		EndIf

		//Filtro pela Data Inicio - mesmo filtro da funcao fProcDados()
		If !Empty(MV_PAR07) .And. TVY->TVY_DTINIC < MV_PAR07
			dbSelectArea("TVY")
			dbSkip()
			Loop
		EndIf

		If !Empty(MV_PAR08) .And.  TVY->TVY_DTINIC > MV_PAR08
			dbSelectArea("TVY")
			dbSkip()
			Loop
		EndIf

		aAdd(aPlanejas, { cLTopGet1		 , TVY->TVY_FILIAL, TVY->TVY_ID,;
							TVY->TVY_CODFAM, TVY->TVY_TIPMOD, TVY->TVY_DTINIC,;
							TVY->TVY_DTFIM , TVY->TVY_QUANT , TVY->TVY_CODUSU, RecNo()})

		dbSelectArea("TVY")
		dbSkip()
	End

	aSort(aPlanejas, , , {|x,y| DTOS(x[6]) < DTOS(y[6]) })

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fVisPlans
Visualiza o Planejamento.

@author Wagner S. de Lacerda
@since 15/08/2011
@return .t.

/*/
//---------------------------------------------------------------------
Static Function fVisPlans()

	Local nReg := aPlanejas[oPlansBrw:nAt,10]

	dbSelectArea("TVY")
	dbGoTo(nReg)

	FWExecView( "Planejamento de Obras", 'MNTA692',,, { || .T. } )

	oPlansBrw:SetFocus()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fMontaCG
Monta os Periodos em Tela da Consulta Gerencial.

@author Wagner S. de Lacerda
@since 10/08/2011
@return .t.

/*/
//---------------------------------------------------------------------
Static Function fMontaCG()

	Local aColumns := {}
	Local cGridCSS := ""
	Local oPaiGrid := Nil

	Local oColDesc  := Nil
	Local oColAno   := Nil
	Local oColMes01 := Nil
	Local oColMes02 := Nil
	Local oColMes03 := Nil
	Local oColMes04 := Nil
	Local oColMes05 := Nil
	Local oColMes06 := Nil
	Local oColMes07 := Nil
	Local oColMes08 := Nil
	Local oColMes09 := Nil
	Local oColMes10 := Nil
	Local oColMes11 := Nil
	Local oColMes12 := Nil

	//----------------------------------
	//Inicializa o Browse
	//----------------------------------
	oAAllFWBrw := FWBrowse():New()
	oAAllFWBrw:SetOwner(oPnlAAll)
	oAAllFWBrw:SetDataArray()
	oAAllFWBrw:SetInsert(.F.)

	oAAllFWBrw:SetLineHeight(If(nAltura > 750,25,16))

	oAAllFWBrw:DisableConfig()
	oAAllFWBrw:DisableReport()
	oAAllFWBrw:DisableSaveConfig()

	//----------------------------------
	//Monta o Browse
	//----------------------------------

	//Coluna: Descricao
	oColDesc := FWBrwColumn():New()
	oColDesc:SetAlign(CONTROL_ALIGN_RIGHT)
	oColDesc:SetData({|| aAllFWCols[oAAllFWBrw:AT(),13] })
	oColDesc:SetEdit(.F.)
	oColDesc:SetPicture("")
	oColDesc:SetSize(12)
	oColDesc:SetTitle(" ")
	oColDesc:SetType("C")

	//Coluna: Descricao
	oColAno := FWBrwColumn():New()
	oColAno:SetAlign(CONTROL_ALIGN_RIGHT)
	oColAno:SetData({|| aAllFWCols[oAAllFWBrw:AT(),14] })
	oColAno:SetEdit(.F.)
	oColAno:SetPicture("@E 9,999,999")
	oColAno:SetSize(10)
	oColAno:SetTitle(STR0057) //"Total Ano"
	oColAno:SetType("N")

	//Coluna: Janeiro
	oColMes01 := FWBrwColumn():New()
	oColMes01:SetAlign(CONTROL_ALIGN_RIGHT)
	oColMes01:SetData({|| aAllFWCols[oAAllFWBrw:AT(),01] })
	oColMes01:SetEdit(.F.)
	oColMes01:SetPicture("@E 999,999")
	oColMes01:SetSize(08)
	oColMes01:SetTitle(STR0058) //"Janeiro"
	oColMes01:SetType("N")

	//Coluna: Fevereiro
	oColMes02 := FWBrwColumn():New()
	oColMes02:SetAlign(CONTROL_ALIGN_RIGHT)
	oColMes02:SetData({|| aAllFWCols[oAAllFWBrw:AT(),02] })
	oColMes02:SetEdit(.F.)
	oColMes02:SetPicture("@E 999,999")
	oColMes02:SetSize(08)
	oColMes02:SetTitle(STR0059) //"Fevereiro"
	oColMes02:SetType("N")

	//Coluna: Marco
	oColMes03 := FWBrwColumn():New()
	oColMes03:SetAlign(CONTROL_ALIGN_RIGHT)
	oColMes03:SetData({|| aAllFWCols[oAAllFWBrw:AT(),03] })
	oColMes03:SetEdit(.F.)
	oColMes03:SetPicture("@E 999,999")
	oColMes03:SetSize(08)
	oColMes03:SetTitle(STR0060) //"Março"
	oColMes03:SetType("N")

	//Coluna: Abril
	oColMes04 := FWBrwColumn():New()
	oColMes04:SetAlign(CONTROL_ALIGN_RIGHT)
	oColMes04:SetData({|| aAllFWCols[oAAllFWBrw:AT(),04] })
	oColMes04:SetEdit(.F.)
	oColMes04:SetPicture("@E 999,999")
	oColMes04:SetSize(08)
	oColMes04:SetTitle(STR0061) //"Abril"
	oColMes04:SetType("N")

	//Coluna: Maio
	oColMes05 := FWBrwColumn():New()
	oColMes05:SetAlign(CONTROL_ALIGN_RIGHT)
	oColMes05:SetData({|| aAllFWCols[oAAllFWBrw:AT(),05] })
	oColMes05:SetEdit(.F.)
	oColMes05:SetPicture("@E 999,999")
	oColMes05:SetSize(08)
	oColMes05:SetTitle(STR0062) //"Maio"
	oColMes05:SetType("N")

	//Coluna: Junho
	oColMes06 := FWBrwColumn():New()
	oColMes06:SetAlign(CONTROL_ALIGN_RIGHT)
	oColMes06:SetData({|| aAllFWCols[oAAllFWBrw:AT(),06] })
	oColMes06:SetEdit(.F.)
	oColMes06:SetPicture("@E 999,999")
	oColMes06:SetSize(08)
	oColMes06:SetTitle(STR0063) //"Junho"
	oColMes06:SetType("N")

	//Coluna: Julho
	oColMes07 := FWBrwColumn():New()
	oColMes07:SetAlign(CONTROL_ALIGN_RIGHT)
	oColMes07:SetData({|| aAllFWCols[oAAllFWBrw:AT(),07] })
	oColMes07:SetEdit(.F.)
	oColMes07:SetPicture("@E 999,999")
	oColMes07:SetSize(08)
	oColMes07:SetTitle(STR0064) //"Julho"
	oColMes07:SetType("N")

	//Coluna: Agosto
	oColMes08 := FWBrwColumn():New()
	oColMes08:SetAlign(CONTROL_ALIGN_RIGHT)
	oColMes08:SetData({|| aAllFWCols[oAAllFWBrw:AT(),08] })
	oColMes08:SetEdit(.F.)
	oColMes08:SetPicture("@E 999,999")
	oColMes08:SetSize(08)
	oColMes08:SetTitle(STR0065) //"Agosto"
	oColMes08:SetType("N")

	//Coluna: Setembro
	oColMes09 := FWBrwColumn():New()
	oColMes09:SetAlign(CONTROL_ALIGN_RIGHT)
	oColMes09:SetData({|| aAllFWCols[oAAllFWBrw:AT(),09] })
	oColMes09:SetEdit(.F.)
	oColMes09:SetPicture("@E 999,999")
	oColMes09:SetSize(08)
	oColMes09:SetTitle(STR0066) //"Setembro"
	oColMes09:SetType("N")

	//Coluna: Outubro
	oColMes10 := FWBrwColumn():New()
	oColMes10:SetAlign(CONTROL_ALIGN_RIGHT)
	oColMes10:SetData({|| aAllFWCols[oAAllFWBrw:AT(),10] })
	oColMes10:SetEdit(.F.)
	oColMes10:SetPicture("@E 999,999")
	oColMes10:SetSize(08)
	oColMes10:SetTitle(STR0067) //"Outubro"
	oColMes10:SetType("N")

	//Coluna: Novembro
	oColMes11 := FWBrwColumn():New()
	oColMes11:SetAlign(CONTROL_ALIGN_RIGHT)
	oColMes11:SetData({|| aAllFWCols[oAAllFWBrw:AT(),11] })
	oColMes11:SetEdit(.F.)
	oColMes11:SetPicture("@E 999,999")
	oColMes11:SetSize(08)
	oColMes11:SetTitle(STR0068) //"Novembro"
	oColMes11:SetType("N")

	//Coluna: Dezembro
	oColMes12 := FWBrwColumn():New()
	oColMes12:SetAlign(CONTROL_ALIGN_RIGHT)
	oColMes12:SetData({|| aAllFWCols[oAAllFWBrw:AT(),12] })
	oColMes12:SetEdit(.F.)
	oColMes12:SetPicture("@E 999,999")
	oColMes12:SetSize(08)
	oColMes12:SetTitle(STR0069) //"Dezembro"
	oColMes12:SetType("N")

	//----------------------------------
	//Ativa o Browse
	//----------------------------------

	aAllFWCols := {}

	MsgRun(STR0042, STR0043, {|| fCarFWCols() }) //"Carregando a Consulta..."###"Aguarde..."

	aAdd(aColumns,oColDesc)
	aAdd(aColumns,oColMes01)
	aAdd(aColumns,oColMes02)
	aAdd(aColumns,oColMes03)
	aAdd(aColumns,oColMes04)
	aAdd(aColumns,oColMes05)
	aAdd(aColumns,oColMes06)
	aAdd(aColumns,oColMes07)
	aAdd(aColumns,oColMes08)
	aAdd(aColumns,oColMes09)
	aAdd(aColumns,oColMes10)
	aAdd(aColumns,oColMes11)
	aAdd(aColumns,oColMes12)
	aAdd(aColumns,oColAno)

	oAAllFWBrw:SetColumns(aColumns)
	oAAllFWBrw:SetArray(aAllFWCols)

	oAAllFWBrw:Activate()
	oAAllFWBrw:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	//CSS do Grid
	cGridCSS := "QTableView { "+;
					"background-color: #FFFFFF; "+; //Branco
					"color: #FFFFFF; "+; //Branco (antigo - #000080 NavyBlue)
					"alternate-background-color: #FFFFFF; "+; //Branco (antigo - #F0FFFF AliceBlue)
					"selection-background-color: #6495ED; "+; //CornflowerBlue
					"selection-color: #FFFFFF; "+; //Branco
					"border: 1px solid #FFFFFF; "+; //Branco
					"font: bold 12px Arial; } "

	oPaiGrid := oAAllFWBrw:Browse()
	oPaiGrid:SetCSS(cGridCSS)
	oPaiGrid:SetHeaderClick({|| })

	//Para as Linhas do Grid, deve-se subtrair sempre 1, pois o Grid inicia na linha 0 (zero)
	oPaiGrid:SetRowColor(nFWDISPTOT-1, CLR_WHITE, RGB(47,79,79)) //DarkSlateGray
	oPaiGrid:SetRowColor(nFWPLANEJA - 1, CLR_WHITE, RGB(104,34,139)) //DarkOrchid4
	oPaiGrid:SetRowColor(nFWPROPRIO - 1, CLR_WHITE, CLR_BLACK) //Preto
	oPaiGrid:SetRowColor(nFWTERCEIR - 1, CLR_WHITE, CLR_BLACK) //Preto
	oPaiGrid:SetRowColor(nFWSALDATU - 1, CLR_WHITE, RGB(0,0,139)) //DarkBlue

	oAAllFWBrw:GoTop()
	oAAllFWBrw:Refresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fGoAno
Troca o Ano visualizado da consulta.

@author Wagner S. de Lacerda
@since 12/08/2011
@return .t.
/*/
//---------------------------------------------------------------------
Static Function fGoAno(nGo)

	Local nAnoAtu	:= IIf( Empty(cAAllAno), 0, Val(cAAllAno) )

	If Empty(dAAllDtIni) .Or. Empty(dAAllDtFim)

		ApMsgStop(STR0070 + CRLF +;	//"Ação inválida!"
					STR0071, STR0045)	//"Primeiro selecione um planejamento que possua dados."###"Atenção"

		Return .F.
	EndIf

	nAnoAtu += nGo

	If ( nGo == 1 .And. nAnoAtu > Year(dAAllDtFim) ) .Or.;//Avanca
		( nGo == -1 .And. nAnoAtu < Year(dAAllDtIni) ) //Retrocede

		Return .F.

	EndIf

	cAAllAno := cValToChar(nAnoAtu)
	oAAllAno:CtrlRefresh()

	MsgRun(STR0042, STR0043, {|| fCarFWCols(.F.) }) //"Carregando a Consulta..." ## "Aguarde..."

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fCarFWCols
Carrega a Array cos Periodos para a Consulta dos Planejamentos.

@author Wagner S. de Lacerda
@since 12/08/2011
@return .t.
@Param lInit -> Opcional;
			Define se deve carregar o estado inicial dos periodos.
 				.T. - Carrega (data, ano)
 				.F. - Nao carrega, monta direto
				Default: .T.
/*/
//---------------------------------------------------------------------
Static Function fCarFWCols(lInit)

	Local cFiltraEmp := IIf(Type("cLTopGet1")  == "C", cLTopGet1,  " ")
	Local cFiltraFil := IIf(Type("cLTopGet2")  == "C", cLTopGet2,  " ")
	Local cFiltraFam := IIf(Type("cTLAllGet1") == "C", cTLAllGet1, " ")
	Local cFiltraMod := IIf(Type("cTLAllGet2") == "C", cTLAllGet2, " ")

	Local aPlanejs := {}
	Local aDesmobs := {}
	Local aTransfs := {}
	Local lLoading := .F.
	Local nLoadMes := 0
	Local nLoadAno := 0

	Local nRemove := 0

	Local nEmpFil   := 0
	Local nFamMod   := 0
	Local nX, nY, nPos

	Default lInit := .T.

	aAllFWCols := {}

	If lInit
		dAAllDtIni	 := CTOD("")
		dAAllDtFim	 := CTOD("")
	EndIf

	If ( nEmpFil := aScan(aDados200, {|x| x[1]+x[3] == cFiltraEmp + cFiltraFil }) ) == 0

		aAllFWCols := { aAllFWCBra }

	Else

		If ( nFamMod := aScan(aDados200[nEmpFil][5], {|x| x[1] + x[3] == cFiltraFam + cFiltraMod }) ) == 0

			aAllFWCols := { aAllFWCBra }

		Else

			aAdd(aAllFWCols, {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, STR0072, 0} ) //"Disp. Total"
			aAdd(aAllFWCols, aAllFWCBra )
			aAdd(aAllFWCols, {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, STR0074, 0} ) //"Planejado"
			aAdd(aAllFWCols, {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, STR0075, 0} ) //"Próprios"
			aAdd(aAllFWCols, {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, STR0076, 0} ) //"Terceiros"
			aAdd(aAllFWCols, aAllFWCBra )
			aAdd(aAllFWCols, {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, STR0077, 0} ) //"Saldo Atual"

			aPlanejs := aDados200[nEmpFil, 5, nFamMod, 7]
			aDesmobs := aDados200[nEmpFil, 5, nFamMod, 8]
			aTransfs := aDados200[nEmpFil, 5, nFamMod, 9]

			If lInit
				For nX := 1 To Len(aPlanejs)

					//Data Inicial
					If Empty(dAAllDtIni) .Or. dAAllDtIni > aPlanejs[nX][1]
						dAAllDtIni := aPlanejs[nX, 1]
					EndIf

					//Data Final
					If Empty(dAAllDtFim) .Or. dAAllDtFim < aPlanejs[nX][2]
						dAAllDtFim := aPlanejs[nX, 2]
					EndIf

				Next nX

				//Ano Atual da Consulta
				cAAllAno := cValToChar( Year(dAAllDtIni) )
			EndIf

			For nX := 1 To Len(aPlanejs)
				lLoading := .T.

				nLoadMes := Month(aPlanejs[nX][1])
				nLoadAno := Year(aPlanejs[nX][1])

				While lLoading

					If nLoadAno == Val(cAAllAno)
						//Disponibilidade Total
						aAllFWCols[nFWDISPTOT][nLoadMes] := aPlanejs[nX][3]

						//Planejado
						aAllFWCols[nFWPLANEJA][nLoadMes] += aPlanejs[nX][4]

						//Próprios
						If aAllFWCols[nFWPROPRIO][nLoadMes] < aPlanejs[nX][5]
							aAllFWCols[nFWPROPRIO][nLoadMes] := aPlanejs[nX][5]
						EndIf

						//Terceiros
						If aAllFWCols[nFWTERCEIR][nLoadMes] < aPlanejs[nX][6]
							aAllFWCols[nFWTERCEIR][nLoadMes] := aPlanejs[nX][6]
						EndIf

						//Verifica as Desmobilizacoes do Planejamento
						For nRemove := 1 To Len(aPlanejs[nX][9])
							If nLoadAno > Year(aPlanejs[nX][9][nRemove][1]) .Or. ;
									( nLoadMes > Month(aPlanejs[nX][9][nRemove][1]) .And. nLoadAno == Year(aPlanejs[nX][9][nRemove][1]) )

								aAllFWCols[nFWDISPTOT][nLoadMes] -= aPlanejs[nX][9][nRemove][2]

								If aPlanejs[nX][9][nRemove][4] == "1" //Proprios da Filial
									aAllFWCols[nFWPROPRIO][nLoadMes] -= aPlanejs[nX][9][nRemove][2]
								EndIf

								If aPlanejs[nX][9][nRemove][4] == "2" //Terceiros da Filial
									aAllFWCols[nFWTERCEIR][nLoadMes] -= aPlanejs[nX][9][nRemove][2]
								EndIf
							EndIf
						Next nRemove

						//Ajusta as Quantidades com as Datas de Compra dos Bens
						For nRemove := 1 To Len(aDesmobs)
							If aDesmobs[nRemove][1] >= aPlanejs[nX][1] .And. aDesmobs[nRemove][1] <= aPlanejs[nX][2]
								If nLoadAno < Year(aDesmobs[nRemove][1]) .Or. ;
										( nLoadMes < Month(aDesmobs[nRemove][1]) .And. Year(aDesmobs[nRemove][1]) == nLoadAno )

									aAllFWCols[nFWDISPTOT][nLoadMes] -= aDesmobs[nRemove][2]

									If aDesmobs[nRemove][3] == "1" //Proprios da Filial
										aAllFWCols[nFWPROPRIO][nLoadMes] -= aDesmobs[nRemove][2]
									EndIf

									If aDesmobs[nRemove][3] == "2" //Terceiros da Filial
										aAllFWCols[nFWTERCEIR][nLoadMes] -= aDesmobs[nRemove][2]
									EndIf
								EndIf
							EndIf
						Next nRemove

						//Ajusta as Quantidades de acordo com as Transferencias dos Bens
						nPos := 0

						For nRemove := 1 To Len(aTransfs)
							If nPos > 0
								nPos := 0
							EndIf
							If aTransfs[nRemove][1][1]+aTransfs[nRemove][1][2] <> cFiltraEmp+cFiltraFil //Se estava em uma Empresa/Filial diferente
								//Busca ENTRADAS em branco
								//ENTRADA em branco significa que o Bem estava originalmente na outra Empresa/Filial
								If Empty(aTransfs[nRemove][1][3]) .And. ;
										( nLoadAno < Year(aTransfs[nRemove][1][5]) .Or. ;
										(nLoadAno == Year(aTransfs[nRemove][1][5]) .And. nLoadMes <= Month(aTransfs[nRemove][1][5])) )

									//Se a proxmia transferencia do Bem for uma SAIDA em branco para a Empresa/Filial em questao, verirfica a data
									If Len(aTransfs) >= (nRemove+1)
										If aTransfs[nRemove+1][3] == aTransfs[nRemove][3] .And. ;
												aTransfs[nRemove+1][1][1]+aTransfs[nRemove+1][1][2] == cFiltraEmp+cFiltraFil .And. ;
												Empty(aTransfs[nRemove+1][1][5]) .And. ( nLoadAno > Year(aTransfs[nRemove+1][1][3]) .Or. ;
												(nLoadAno == Year(aTransfs[nRemove+1][1][3]) .And. nLoadMes > Month(aTransfs[nRemove+1][1][3])) )

											//Se a data de ENTRADA na Empresa/Filial em questao for MAIOR do que a que esta sendo carregada, remove
											nPos := nRemove
										EndIf
									EndIF
								EndIf

								If nPos == 0
									//Busca SAIDAS em branco
									//SAIDA em branco siginifica que o Bem ainda se encontra na outra Empresa/Filial
									If Empty(aTransfs[nRemove][1][5]) .And. ;
											( nLoadAno > Year(aTransfs[nRemove][1][3]) .Or. ;
											(nLoadAno == Year(aTransfs[nRemove][1][3]) .And. nLoadMes > Month(aTransfs[nRemove][1][3])) )

										nPos := nRemove
									EndIf
								EndIf

								If nPos == 0 .And. !Empty(aTransfs[nRemove][1][3]) .And. !Empty(aTransfs[nRemove][1][5])

									//Busca o PERIODO em que o Bem estava na outra Empresa/Filial
									If ( nLoadAno > Year(aTransfs[nRemove][1][3]) .And. nLoadAno < Year(aTransfs[nRemove][1][5]) )

										nPos := nRemove

									ElseIf nLoadAno == Year(aTransfs[nRemove][1][3]) .And. nLoadMes > Month(aTransfs[nRemove][1][3]) .And. ;
											nLoadAno <= Year(aTransfs[nRemove][1][5]) .And. nLoadMes <= Month(aTransfs[nRemove][1][5])

										nPos := nRemove

									ElseIf nLoadAno == Year(aTransfs[nRemove][1][5]) .And. nLoadMes <= Month(aTransfs[nRemove][1][5]) .And. ;
											nLoadAno >= Year(aTransfs[nRemove][1][3]) .And. nLoadMes > Month(aTransfs[nRemove][1][3])

										nPos := nRemove

									EndIf
								EndIf
							EndIf

							//Remove
							If nPos > 0
								aAllFWCols[nFWDISPTOT][nLoadMes] -= 1

								If aTransfs[nPos][3] == "1" //Proprios da Filial
									aAllFWCols[nFWPROPRIO][nLoadMes] -= 1
								EndIf
								If aTransfs[nPos][3] == "2" //Terceiros da Filial
									aAllFWCols[nFWTERCEIR][nLoadMes] -= 1
								EndIf
							EndIf
						Next nRemove

						//Ajusta para nao ser negativo
						If aAllFWCols[nFWDISPTOT][nLoadMes] < 0
							aAllFWCols[nFWDISPTOT][nLoadMes] := 0
						EndIf

						If aAllFWCols[nFWPROPRIO][nLoadMes] < 0
							aAllFWCols[nFWPROPRIO][nLoadMes] := 0
						EndIf

						If aAllFWCols[nFWTERCEIR][nLoadMes] < 0
							aAllFWCols[nFWTERCEIR][nLoadMes] := 0
						EndIf

						//Saldo Atual
						aAllFWCols[nFWSALDATU][nLoadMes] := ( aAllFWCols[nFWPLANEJA][nLoadMes] -;
							(aAllFWCols[nFWPROPRIO][nLoadMes] + aAllFWCols[nFWTERCEIR][nLoadMes]) ) //Planejados - (Proprio+Terceiros)
					EndIf

					nLoadMes++

					If nLoadMes > 12
						nLoadMes := 1
						nLoadAno++
					EndIf

					If ( nLoadAno > Year(aPlanejs[nX][2]) ) .Or.;
						( nLoadMes > Month(aPlanejs[nX][2]) .And. nLoadAno >= Year(aPlanejs[nX][2]) )

						lLoading := .F.
					EndIf
				End
			Next nX

			//Calcula os Totais
			For nX := 1 To Len(aAllFWCols)

				If nX <> nFWBRANCA1 .And. nX <> nFWBRANCA2

					For nY := 1 To Len( aAllFWCols[nX] )

						If nY <= 12
							aAllFWCols[nX][14] += aAllFWCols[nX][nY]
						EndIf

					Next nY
				EndIf

			Next nX
		EndIf
	EndIf

	//Atualiza objetos
	IIf( Type("oAAllDtIni") == "O", oAAllDtIni:CtrlRefresh(), Nil )
	IIf( Type("oAAllDtFim") == "O", oAAllDtFim:CtrlRefresh(), Nil )
	IIf( Type("oAAllAno")   == "O", oAAllAno:CtrlRefresh()  , Nil )

	//FWBrowse Ativado
	If Type("oAAllFWBrw:oBrowse") == "O"
		oAAllFWBrw:SetArray(aAllFWCols)
		oAAllFWBrw:GoTop()
		oAAllFWBrw:Refresh()
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fBlackPnl
Coloca um Painel sobre a Tela

@author Wagner S. de Lacerda
@since 11/08/2011
@return .t.
/*/
//---------------------------------------------------------------------
Static Function fBlackPnl(lVisible)

	Default lVisible := .T.

	If Type("oBlackPnl") <> "O"
		oBlackPnl := TPanel():New(0, 0, , oPnlAAll, , , , , SetTransparentColor(CLR_BLACK,70), nLargura, nAltura, .F., .F.)
		oBlackPnl:Hide()
	EndIf

	IIf(lVisible, oBlackPnl:Show(), oBlackPnl:Hide() )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC682FA
Validaca da Pergunta: De/Ate Familia

@author Wagner S. de Lacerda
@since 09/08/2011
@Param nParam -> Obrigatorio;
		Indica qual dos tipos de pergunta sera validado:
            1 - De
            2 - Ate

@return 	.T. -> Familia OK.
			.F. -> Familia Invalida.
/*/
//---------------------------------------------------------------------

Function MNTC682FA(nParam)

	Local lRet := .T.

	If nParam == 1
		lRet := Empty(MV_PAR03) .Or. ExistCpo("ST6",MV_PAR03,1)
	Else
		lRet := NaoVazio() .And. AteCodigo("ST6",MV_PAR03,MV_PAR04)
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC682MO
Validaca da Pergunta: De/Ate Modelo

@author Wagner S. de Lacerda
@since 09/08/2011
@Param nParam -> Obrigatorio;
		Indica qual dos tipos de pergunta sera validado:
            1 - De
            2 - Ate

@return 	.T. -> Modelo OK.
			.F. -> Modelo Invalida.
/*/
//---------------------------------------------------------------------
Function MNTC682MO(nParam)

	Local lRet := .T.

	If nParam == 1
		lRet := Empty(MV_PAR05) .Or. ExistCpo("TQR", MV_PAR05, 1)
	Else
		lRet := NaoVazio() .And. AteCodigo("TQR",MV_PAR05,MV_PAR06)
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC682MO
Validaca da Pergunta: De/Ate Data

@author Wagner S. de Lacerda
@since 09/08/2011
@Param nParam -> Obrigatorio;
		Indica qual dos tipos de pergunta sera validado:
            1 - De
            2 - Ate

@return lRet
/*/
//---------------------------------------------------------------------
Function MNTC682DT(nParam)

	Local lRet := .T.

	If ( lRet := NaoVazio() )
		If nParam == 1
			If !Empty(MV_PAR08) .And. MV_PAR07 > MV_PAR08

				ShowHelpDlg(STR0045, ; //"Atenção"
								{STR0080}, 2,; //"A data inicial não pode ser maior que a final."
								{STR0081}, 2) //"Insira uma data menor ou igual a final."

				lRet := .F.
			EndIf
		Else
			If !Empty(MV_PAR07) .And. MV_PAR08 < MV_PAR07

				ShowHelpDlg(STR0045,; //"Atenção"
								{STR0082}, 2,; //"A data final não pode ser menor que a inicial."
								{STR0083}, 2) //"Insira uma data maior ou igual a inicial."
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fTransBem
Busca as Transferencias do bem ate a data estipulada.

@author Wagner S. de Lacerda
@since 09/08/2011
@return aTrs -> Vetor com as Transferencias do Bem.
	       	[x][1] - Empresa
    	   	[x][2] - Filial
       		[x][3] - Data Inicial do bem na empresa/filial
       		[x][4] - Hora Inicial do bem na empresa/filial
       		[x][5] - Data Final do bem na empresa/filial
       		[x][6] - Hora Final do bem na empresa/filial
/*/
//---------------------------------------------------------------------
Static Function fTransBem(cCodBem)

	Local cOldEmp  := cEmpAnt
	Local nPos, nX, nY, nLen

	//Utilizada como parâmetro na função NGRetEmp
	Local nTipo := IIf( NGSX2Modo("TQ2") <> 'C', 1, 2 )

	Local aAreaAtu := GetArea()
	Local aAreaTQ2 := TQ2->( GetArea() )

	Local cEmprOrig, cEmprDest, cFiliOrig, cFiliDest
	Local dDataTrsf, cHoraTrsf, cEmpresaX, cFilialX

	Local aTrs			:= {}, aDestino	:= {}, aEmpFil := {}
	Local aOrigem		:= {}, aPeriodos	:= {}

	Local aTabelas	:= { {"TQ2"} }

	//---------------------------------------------------------------------
	//Busca as transferencias do Bem em todas as empresas
	//---------------------------------------------------------------------
	aEmpFil := NGRetEmp( nTipo )

	For nX := 1 To Len(aEmpFil)

		NGPrepTbl(aTabelas,aEmpFil[nX][1])

		For nY := 1 To Len(aEmpFil[nX][2])

			dDataTrsf := CToD("  /  /    ")
			cHoraTrsf := ""

			cEmprOrig := ""
			cFiliOrig := ""

			cEmprDest := ""
			cFiliDest := ""

			//---------------------------------------------------------------------
			//Transferências Confirmadas
			//---------------------------------------------------------------------
			dbSelectArea("TQ2")
			dbSetOrder(4)
			If dbSeek(aEmpFil[nX,2,nY] + cCodBem + "3")
				While !EoF() .And. TQ2->TQ2_FILIAL == aEmpFil[nX,2,nY] .And. TQ2->TQ2_CODBEM == cCodBem .And. TQ2->TQ2_STATUS == "3"

					If TQ2->TQ2_DATATR <= dDataBase //Considera Transferencias ate e data informada

						dDataTrsf := TQ2->TQ2_DATATR
						cHoraTrsf := TQ2->TQ2_HORATR

						cEmprOrig := TQ2->TQ2_EMPORI
						cFiliOrig := TQ2->TQ2_FILORI

						cEmprDest := TQ2->TQ2_EMPDES
						cFiliDest := TQ2->TQ2_FILDES

						//Empresa Origem; Filial Origem; Empresa Destino; Filial Destino; Data da Transferencia; Hora da Transferencia
						aAdd(aTrs, {cEmprOrig, cFiliOrig, cEmprDest, cFiliDest, dDataTrsf, cHoraTrsf})
					EndIf

					dbSelectArea("TQ2")
					dbSkip()
				EndDo
			EndIf
		Next nY

	Next nX

	//---------------------------------------------------------------------
	//Busca os periodos
	//---------------------------------------------------------------------
	aSort(aTrs, , , {|x,y| DToC( x[5] ) + x[6] < DToC( y[5] ) + y[6] })

	For nX := 1 To Len(aTrs)
		aAdd(aOrigem , {aTrs[nX][1], aTrs[nX][2], aTrs[nX][5], aTrs[nX][6]}) //Saídas
		aAdd(aDestino, {aTrs[nX][3], aTrs[nX][4], aTrs[nX][5], aTrs[nX][6]}) //Entradas
	Next nX

	//---------------------------------------------------------------------
	//Organiza os Periodos
	//---------------------------------------------------------------------
	//aOrigem  ( cEmprOrig | cFiliOrig | dDataTrsf | cHoraTrsf )
	//aDestino ( cEmprDest | cFiliDest | dDataTrsf | cHoraTrsf )
	If Len(aOrigem) > 0

		//A primeira saída identifica o proprietario original do Bem
		//aPeriodos: Empresa; Filial; Data Inicio; Hora Inicio; Data Fim; Hora Fim;

		//Adiciona empresa, filial origem, data VAZIA, hora VAZIA, data transf. e hora transf.
		aAdd(aPeriodos, { aOrigem[1][1], aOrigem[1][2], CToD("  /  /    "), "", aOrigem[1][3], aOrigem[1][4] })

		For nX := 1 To Len(aDestino)

			// Carrega empresa e filial destino
			cEmpresaX := aDestino[nX][1]
			cFilialX  := aDestino[nX][2]

			//Adiciona empresa destino, filial destino, data transferência, hora transferência, data VAZIA e hora VAZIA
			aAdd(aPeriodos, {cEmpresaX, cFilialX, aDestino[nX][3], aDestino[nX][4], CTOD("  /  /    "), ""})
			nLen := Len(aPeriodos)

			//SE achar no aOrigem uma empresa e filial igual a DESTINO e ( data de transferência for MAIOR que ÚLTIMA DT. OU
			//																		( data de transferência for IGUAL a   ÚLTIMA DT. E
			//																		hora da tranferência MAIOR OU IGUAL a  ÚLTIMA ))

			// ENTÃO, CARREGA aPeriodo com data e hora da transferência
			If (nPos := aScan(aOrigem, {|x| x[1] + x[2] == cEmpresaX + cFilialX .And. (x[3] > aPeriodos[nLen, 3] .Or.;
					(x[3] == aPeriodos[nLen, 3] .And. x[4] >= aPeriodos[nLen, 4])) })) > 0

				aPeriodos[nLen][5] := aOrigem[nPos][3]
				aPeriodos[nLen][6] := aOrigem[nPos][4]
			EndIf
		Next nX
	EndIf

	//---------------------------------------------------------------------
	//Devolve as tabelas para a Empresa Original
	//---------------------------------------------------------------------
	NGPrepTbl(aTabelas,cOldEmp)

	//---------------------------------------------------------------------
	//Restaura areas iniciais
	//---------------------------------------------------------------------
	RestArea(aAreaTQ2)
	RestArea(aAreaAtu)

Return aPeriodos