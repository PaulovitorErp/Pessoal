#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA852
Rotina de acerto do registro de controle diário importado com erro.

Tabelas relacionadas:

TV0 - Cadastro de Atividades
TV1 - Cabecalho da Parte Diaria
TV2 - Atividades da Parte Diaria

@author Wagner S. de Lacerda.
@author Passado para padrão: André.
@since 05/07/2011
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Function MNTA852()

	//------------------------------------------------
	// Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	//------------------------------------------------
	Local aNGBEGINPRM := NGBEGINPRM()

	Local oTempTable
	Local oDlg101
	Local oSay
	Local oPnlLEFT
	Local oBtnAltera
	Local oBtnExclui
	Local oBtnFiltra
	Local oBtnSair
	Local oPnlALL
	Local oPnlALLTOP
	Local oPnlALLBRW

	Local lIncluiOld := IIf( Type("Inclui") == "L", Inclui, .F. )
	Local lAlteraOld := IIf( Type("Altera") == "L", Altera, .F. )

	Local nAcesso

	//nRecnoTV1: Armazena Recno da tabela TV1 correpondente com o registro posicionado na TRB
	Local nRecnoTV1

	Local aStruct		:= {}	//Utilizada para armazenar a estrutura da tabela temporária
	Local cQuery		:= ""	//Utilizada para armazenar a query de filtro de registros da tabela TV1
	Local aExpDel		:= { "DTOS", "STR", "NIVEL" }
	Local oTempTable
	Local nPosDel
	Local nPosLoc
	Local _ix

	Private cPrograma := "MNTA852"
	Private cCadastro := OemToAnsi("Acerto de Parte Diária")
	Private aZEMPS    := {} //Variavel obrigatoria para as Perguntas De/Ate Empresa/Filial
	Private lZEMPS    := .T. //Variavel obrigatoria para selecionar apenas UMA Empresa e UMA Filial

	Private oBrwGet, oVisEnc
	Private aRegTV1 := {0}, aRegTV2 := {}
	Private cFiltroDef := "", cFiltroUsr := "" //Filtros Padrão e do Usuário

	Private oFontBold := TFont():New("Verdana", , 14, .T., .T.)
	Private nCorBack  := RGB(67,70,87)

	//Armazena Empresa e Filial Originais
	Private cOrigEmp := cEmpAnt
	Private cOrigFil := cFilAnt

	//Armazane a Restricao de Acesso do Usuario
	Private c101Acs    := ""
	Private l101AcsAll := .F.

	/* Variaveis utilizadas nas validacoes do OAS1A003 */
	Private nCODATI, nCODFRE, nHRINI, nHRFIM

	/* Variaveis utilizadas no Reprocessamento - somente alterar nome e estrutura se a rotina OAS1A100 for considerar tal alteracao */
	Private cPrepEmp  := cEmpAnt
	Private cPrepFil  := cFilAnt

	Private aDadosXML  := {} //Variavel utilizada para o Reprocessamento
	Private cEmpComp   := "" //Armazena a Empresa na qual as tabelas TV1 e ZBN foram compartilhada
	Private aPrepTbls  := { {"CTT"}, {"SH7"}, {"SRA"}, {"ST9"}, {"STP"}, {"TPE"}, {"TPP"}, {"TV0"}, {"TV1"}, {"TV2"} }
	Private lModManual := ( Type("oMainWnd") == "O" )

	Private nTotTV1, nTotTV1New, nTotTV2, nTotTV2New
	Private nParTV1, nParTV1New, nParTV2, nParTV2New

	Private oPnlALLVIS // Panel da msmget de visualização

	Private aSize := MsAdvSize()

	//Variável utilizada para armazenar o código do alias temporário
	Private c852TRB := GetNextAlias()

	//Define Altura e Largura
	If !(Alltrim(GetTheme()) == "FLAT") .And. !SetMdiChild()
		aSize[7] -= 50
		aSize[6] -= 30
	ElseIf SetMdiChild()
		aSize[5] -= 03
	EndIf

	//Apenas abre as tabelas para validacoes entre as Importacoes e as informacoes Definitivas
	dbSelectArea("ST9") // Bens
	dbSelectArea("TV1") // Parte Diária
	dbSelectArea("TV2") // Atividades da Parte Diária

	MNT851PVAR()
	SetVisual()

	//Define o Acesso do Usuario
	a101Acesso := aClone( fRetEFUAcces( ,.T. ) ) // aClone( OASRETEF(,.T.) )
	l101AcsAll := ( aScan(a101Acesso, {|x| x[1] == "ALL" }) > 0 )
	l101AcsAll := .T.
	c101Acs := ""

	For nAcesso := 1 To Len(a101Acesso)
		If !(a101Acesso[nAcesso][1] + a101Acesso[nAcesso][2] $ c101Acs)
			c101Acs += a101Acesso[nAcesso][1] + a101Acesso[nAcesso][2] + "/"
			l101AcsAll := .F.
		EndIf
	Next nAcesso

	//---------------------------------------------------------------------
	// Início -> Criação de tab. temporária para registros da tabela TV1
	//---------------------------------------------------------------------
	dbSelectArea("TV1")

	aAdd(aStruct, {"TV1_EMPRES", "C", TamSX3('TV1_EMPRES')[1], 0})
	aAdd(aStruct, {"TV1_FILIAL", "C", TamSX3('TV1_FILIAL')[1], 0})
	aAdd(aStruct, {"TV1_CODBEM", "C", TamSX3('TV1_CODBEM')[1], 0})
	aAdd(aStruct, {"TV1_PLACA" , "C", TamSX3('TV1_PLACA' )[1], 0})
	aAdd(aStruct, {"TV1_TURNO" , "C", TamSX3('TV1_TURNO' )[1], 0})
	aAdd(aStruct, {"TV1_DTSERV", "D", TamSX3('TV1_DTSERV')[1], 0})
	aAdd(aStruct, {"TV1_HREXI" , "C", TamSX3('TV1_HREXI' )[1], 0})
	aAdd(aStruct, {"TV1_HREXF" , "C", TamSX3('TV1_HREXF' )[1], 0})
	aAdd(aStruct, {"TV1_HRINI" , "C", TamSX3('TV1_HRINI' )[1], 0})
	aAdd(aStruct, {"TV1_CONINI", "N", TamSX3('TV1_CONINI')[1], 0})
	aAdd(aStruct, {"TV1_HRFIM" , "C", TamSX3('TV1_HRFIM' )[1], 0})
	aAdd(aStruct, {"TV1_CONFIM", "N", TamSX3('TV1_CONFIM')[1], 0})
	aAdd(aStruct, {"TV1_OPERAD", "C", TamSX3('TV1_OPERAD')[1], 0})

	//Criação de Indice Tabela Temporária
	aIND := StrTokArr( OrdKey(1), "+" )
	For _ix := 1 To Len( aIND )
		If ( nPosDel := aScan( aExpDel , { | x | AllTrim( Upper( x ) ) $ Upper( aIND[ _ix ] ) } ) ) > 0
			If ( nPosLoc := AT( "(" , aIND[ _ix ] ) ) > 0
				aIND[ _ix ] := SubStr( aIND[ _ix ] , nPosLoc + 1 )
			EndIf
			If ( nPosLoc := AT( "," , aIND[ _ix ] ) ) > 0
				aIND[ _ix ] := SubStr( aIND[ _ix ] , 1 , nPosLoc - 1 )
			EndIf
			If ( nPosLoc := AT( ")" , aIND[ _ix ] ) ) > 0
				aIND[ _ix ] := SubStr( aIND[ _ix ] , 1 , nPosLoc - 1 )
			EndIf
		EndIf
		aIND[ _ix ] := AllTrim(aIND[ _ix ])
	Next _ix

	//Criação Tabela Temporária
	oTempTable := NGFwTmpTbl(c852TRB,aStruct,{aIND})

	cQuery := "SELECT TV1.TV1_EMPRES, TV1.TV1_FILIAL, TV1.TV1_CODBEM, TV1.TV1_PLACA, TV1.TV1_TURNO,"
	cQuery += "  TV1.TV1_DTSERV, TV1.TV1_HREXI, TV1.TV1_HREXF, TV1.TV1_HRINI,  "
	cQuery += "  TV1.TV1_CONINI, TV1.TV1_HRFIM, TV1.TV1_CONFIM, TV1.TV1_OPERAD "
	cQuery += "    FROM " + RetSqlName("TV1") + " TV1 "
	cQuery += "    WHERE TV1_INDERR = '1'"
	cQuery += "      AND TV1.D_E_L_E_T_ <> '*'"

	If !l101AcsAll .And. !("ALL" $ c101Acs )
		cQuery += " AND TV1_EMPRES || TV1_FILIAL IN " + FormatIn(c101Acs, '/')
	EndIf

	SqlToTrb(cQuery, aStruct, c852TRB)
	//---------------------------------------------------------------------
	// Fim -> Criação de tab. temporária para registros da tabela TV1
	//---------------------------------------------------------------------

 	cFiltroUsr := ""

	//---------------------------------------------------------------------
	// Browse inicial do Acerto de Partes Diarias
	//---------------------------------------------------------------------
	DEFINE MSDIALOG oDlg101 TITLE cCadastro FROM aSize[7],0 TO aSize[6],aSize[5] COLOR CLR_BLACK,CLR_WHITE OF oMainWnd PIXEL // cCadastro: "Acerto de Parte Diária"

		oDlg101:lEscClose := .F.

		oDlg101:lMaximized := .T.

		oSay := TPanel():New(01, 01, , oDlg101, , , , CLR_WHITE, nCorBack, 15, 10)
		oSay:Align := CONTROL_ALIGN_TOP
		TSay():New(02, 10, {|| OemToAnsi("Importações de Partes Diárias com Erros")}, oSay, , oFontBold, , ;
										, ,.T., CLR_WHITE, nCorBack, 150, 010)

		//--- Menu Lateral
		oPnlLEFT := TPanel():New(01, 01, , oDlg101, , , , CLR_BLACK, RGB(245,245,245), (aSize[5]*0.08), 35, .T., .T.)
		oPnlLEFT:Align := CONTROL_ALIGN_LEFT

			//Busca Recno da tabela TV1 a partir dos dados da TRB. (Obs: os recnos da TV1 e TRB não são iguais)
			nRecnoTV1 := fRecnoTV1()

			//Alterar
			oBtnAltera := TButton():New(001, 001, OemToAnsi("Alterar"), oPnlLEFT, {|| SetAltera(), nRecnoTV1 := TV1->( Recno() ), nOpca := MNTA851CAD( "TV1", nRecnoTV1,4 ),If( nOpca == 1,( (c852TRB)->( DbGoTop()), fUpdateTRB(nRecnoTV1, .F.) ), Nil ),RegToMemory( "TV1",.F. ),fAtualizar() },;
													40, 11, , , .F., .T., .F., , .F., , , .F.)
			oBtnAltera:Align := CONTROL_ALIGN_TOP

			//Excluir
			oBtnExclui := TButton():New(001, 001, OemToAnsi("Excluir"), oPnlLEFT, {|| SetExclui(), nRecnoTV1 := TV1->( Recno() ), nOpca := MNTA851CAD( "TV1", nRecnoTV1,5 ),If( nOpca == 1,( (c852TRB)->( DbGoTop()), fUpdateTRB(nRecnoTV1, .T.) ), Nil ),RegToMemory( "TV1",.F. ),fAtualizar() },;
													40, 11, , , .F., .T., .F., , .F., , , .F.)
			oBtnExclui:Align := CONTROL_ALIGN_TOP

			//Sair
			oBtnSair := TButton():New(001, 001, OemToAnsi("Sair"), oPnlLEFT, {|| oDlg101:End()},;
													40, 11, , , .F., .T., .F., , .F., , , .F.)
			oBtnSair:Align := CONTROL_ALIGN_TOP

			//--- ALL
			oPnlALL := TPanel():New(01, 01, , oDlg101, , , , CLR_BLACK, CLR_WHITE, 50, 50, .T., .T.)
			oPnlALL:Align := CONTROL_ALIGN_ALLCLIENT

			//--- Botões do Brwose
			oPnlALLTOP := TPanel():New(01, 01, , oPnlALL, , , , CLR_BLACK, CLR_WHITE, 50, 015, .T., .T.)
			oPnlALLTOP:Align := CONTROL_ALIGN_TOP

			//Filtrar
			oBtnFiltra := TButton():New(003, 010, OemToAnsi("Filtrar Registros"), oPnlALLTOP, {|| fFiltrar(), RegToMemory("TV1",.F.), fAtualizar()},;
														060, 010, , , .F., .T., .F., , .F., , , .F.)

			//--- Browse
			oPnlALLBRW := TPanel():New(01, 01, , oPnlALL, , , , CLR_BLACK, CLR_WHITE, 50, (aSize[6]*0.20), .T., .T.)
			oPnlALLBRW:Align := CONTROL_ALIGN_TOP


				Mnt852SALI() //Seta o Alias para o Browse

				oBrwGet := BrGetDDB():New(01, 01, 1000, 1000, , , , oPnlALLBRW, , , , , , , , , , , , .F., (c852TRB), .T., , .F., , ,)
				oBrwGet:AddColumn(TCColumn():New(RetTitle("TV1_EMPRES"), {|| (c852TRB)->TV1_EMPRES }, , , , "LEFT" , 60, .F., .F., , , , .F.,))
				oBrwGet:AddColumn(TCColumn():New(RetTitle("TV1_FILIAL"), {|| (c852TRB)->TV1_FILIAL }, , , , "LEFT" , 60, .F., .F., , , , .F.,))
				oBrwGet:AddColumn(TCColumn():New(RetTitle("TV1_CODBEM"), {|| (c852TRB)->TV1_CODBEM }, , , , "LEFT" , 60, .F., .F., , , , .F.,))
				oBrwGet:AddColumn(TCColumn():New(RetTitle("TV1_PLACA" ), {|| (c852TRB)->TV1_PLACA  }, , , , "LEFT" , 60, .F., .F., , , , .F.,))
				oBrwGet:AddColumn(TCColumn():New(RetTitle("TV1_TURNO" ), {|| (c852TRB)->TV1_TURNO  }, , , , "LEFT" , 60, .F., .F., , , , .F.,))
				oBrwGet:AddColumn(TCColumn():New(RetTitle("TV1_DTSERV"), {|| (c852TRB)->TV1_DTSERV }, , , , "LEFT" , 60, .F., .F., , , , .F.,))
				oBrwGet:AddColumn(TCColumn():New(RetTitle("TV1_HREXI" ), {|| (c852TRB)->TV1_HREXI  }, , , , "LEFT" , 60, .F., .F., , , , .F.,))
				oBrwGet:AddColumn(TCColumn():New(RetTitle("TV1_HREXF" ), {|| (c852TRB)->TV1_HREXF  }, , , , "LEFT" , 60, .F., .F., , , , .F.,))
				oBrwGet:AddColumn(TCColumn():New(RetTitle("TV1_HRINI" ), {|| (c852TRB)->TV1_HRINI  }, , , , "LEFT" , 60, .F., .F., , , , .F.,))
				oBrwGet:AddColumn(TCColumn():New(RetTitle("TV1_CONINI"), {|| (c852TRB)->TV1_CONINI }, , , , "RIGHT", 60, .F., .F., , , , .F.,))
				oBrwGet:AddColumn(TCColumn():New(RetTitle("TV1_HRFIM" ), {|| (c852TRB)->TV1_HRFIM  }, , , , "LEFT" , 60, .F., .F., , , , .F.,))
				oBrwGet:AddColumn(TCColumn():New(RetTitle("TV1_CONFIM"), {|| (c852TRB)->TV1_CONFIM }, , , , "RIGHT", 60, .F., .F., , , , .F.,))
				oBrwGet:AddColumn(TCColumn():New(RetTitle("TV1_OPERAD"), {|| (c852TRB)->TV1_OPERAD }, , , , "LEFT" , 60, .F., .F., , , , .F.,))

				oBrwGet:bDelOK         := {|| .F.} //Nao permite deletar o registro do BrGetDDB()
				oBrwGet:bSuperDel      := {|| .F.} //Nao permite deletar o registro do BrGetDDB()
				oBrwGet:bCustomEditCol := {|| .F.} //Nao permite a alteracao das colunas do BrGetDDB()

				oBrwGet:bChange    := {|| MNT852BCGH(), RegToMemory("TV1",.F.), fAtualizar()}
				oBrwGet:bLDblClick := {|| MNTA851CAD( "TV1", nRecnoTV1, 2 ), fAtualizar()}

				oBrwGet:Align := CONTROL_ALIGN_ALLCLIENT

				Mnt852SALI(.T.) //Seta o Alias para o Browse

				//--- Breve Visualizacao
				oPnlALLVIS := TPanel():New(01, 01, , oPnlALL, , , , CLR_BLACK, CLR_WHITE, 50, 50, .T., .T.)
				oPnlALLVIS:Align := CONTROL_ALIGN_ALLCLIENT

				oSay := TPanel():New(01, 01, , oPnlALLVIS, , , , CLR_WHITE, nCorBack, 15, 10)
				oSay:Align := CONTROL_ALIGN_TOP
				TSay():New(02, 10, {|| OemToAnsi("Visualização")}, oSay, , oFontBold, , ;
												, ,.T., CLR_WHITE, nCorBack, 150, 010)

				//-------------------------------------------------
				// Define msmget de pre visualização do registro
				//-------------------------------------------------
				DbSelectArea( "TV1" )
				RegToMemory( "TV1",.F. )

				// Gera enchoice para visualização da parte diária.
				oVisEnc := MsMGet():New( "TV1",Recno(),2,/*aCRA*/,/*cLetras*/,/*cTexto*/,/*aChoice*/,{001,001,400,200}/*aPos*/,/*aCpos*/,;
				     				     3/*nModelo*/,/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oPnlALLVIS/*oDlg*/,/*lI3*/,.T./*lMemoria*/,.F./*lColumn*/,;
										 /*caTela*/,/*lNoFolder*/,/*lProperty*/, /*aField*/ )

				oVisEnc:oBox:Align := CONTROL_ALIGN_ALLCLIENT

			//--- Recebe a inicializacao do registro no Browse
			MNT852BCGH()

	ACTIVATE MSDIALOG oDlg101 ON INIT ( If(fInitDlg(),.T.,oDlg101:End()) ) CENTERED

	Inclui := lIncluiOld
	Altera := lAlteraOld

	//----------------------------------------------
	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	//----------------------------------------------
	NGRETURNPRM(aNGBEGINPRM)

	oTempTable:Delete()

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fInitDlg
Efetua uma validacao ao iniciar o Dialog.

@author Wagner S. de Lacerda
@since 09/07/2011
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Static Function fInitDlg()

	If oBrwGet:nLen == 0
		MsgInfo("Não há dados para efetuar o acerto.","Atenção")
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} Mnt852SALI
Seta o alias para o Browse

@param Boolean lSetFilter: Opcional;
Define se deve setar o filtro para o browse.
.T. -> Seta o filtro
.F. -> Nao seta
Default: .F. - nao seta.

@author Wagner S. de Lacerda
@since 09/07/2011
@version P11
@return .T.
/*/
//---------------------------------------------------------------------
Function Mnt852SALI(lSetFilter,lAtuBrw)

	Local cFiltro := If(!Empty(cFiltroUsr), cFiltroUsr, "")

	Default lSetFilter 	:= .F.
	Default lAtuBrw		:= .T.

	dbSelectArea(c852TRB)
	dbSetOrder(1)
	If lSetFilter
		Set Filter To &(cFiltro)
		If lAtuBrw
			dbGoTop()
			oBrwGet:GoTop()
			oBrwGet:SetFocus()
			oBrwGet:CallRefresh()
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT852BCGH
Atualiza os dados necessarios na troca de linha do Browse.

@author Wagner S. de Lacerda
@since 06/07/2011
@version P11
@return .T.
/*/
//---------------------------------------------------------------------
Function MNT852BCGH()

	Local nChgRecNo := fRecnoTV1()

	//Posiciona na tabela TV1 o mesmo registro posicionado na TRB.
	dbSelectArea("TV1")
	dbGoTo(nChgRecNo)

	aRegTV1 := { nChgRecNo }

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fAtualizar
Atualiza a rotina.

@author Wagner S. de Lacerda
@since 06/07/2011
@version P11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fAtualizar()

	If Type("oVisEnc") == "O"
		oVisEnc:Refresh()
	EndIf

	If Type("oBrwGet") == "O"
		oBrwGet:Refresh()
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fFiltrar
Carrega o filtro do usuário no Browse.

@author Wagner S. de Lacerda
@since 10/02/2012
@version P11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fFiltrar()

	dbSelectArea(c852TRB)
	dbClearFilter()

	cFiltroUsr := BuildExpr("TV1", , @cFiltroUsr)

	Mnt852SALI(.T.)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fRetEFUAcces
Recebe as empresas e filiais que o usuario possui acesso e retorna
de forma mais organizada.

Essa função é a implementação para o padrão, da função OASRETEF que
se encontra no fonte OAS1UTIL (OAS).
André Felipe Joriatti

@param String cVerCodUsr: Opcional;
Indica um usuario em especifico para
pesquisar.
Default: Usuario Atual.

@param Boolean lShowMsg: Opcional;
Indica se deve mostrar a mensagem.
.T. - Mostra a mensagem
.F. - Nao mostra a mensagem
Default: .F.

@param String cFiltEmp1: Opcional;
Indice a empresa DE para o filtro.
Default: "  "

@param String cFiltFil1: Opcional;
Indice a filial DE para o filtro.
Default: "  "

@param String cFiltEmp2: Opcional;
Indice a empresa ATE para o filtro.
Default: "ZZ"

@param String cFiltFil2: Opcional;
Indice a filial ATE para o filtro.
Default: "ZZ"

@author Wagner S. de Lacerda
@since 23/08/2011
@version P11
@return Array aEmpsFils: array com as empresas/filiais que o usuário
	posssui acesso
/*/
//---------------------------------------------------------------------
Static Function fRetEFUAcces( cVerCodUsr,lShowMsg,cFiltEmp1,cFiltFil1,cFiltEmp2,cFiltFil2 )

	Local aArea      := {}
	Local aUsrAccess := {}
	Local aEmpsFils  := {}

	Local lTemAcesso := .F.
	Local nTodas     := 0

	Local nTAMCODIGO := Len(SM0->M0_CODIGO)
	Local nTAMFILIAL := If(FindFunction("FWSizeFilial"),FWSizeFilial(),2)

	Local cVerCodEmp := ""
	Local cVerCodFil := ""

	Default cVerCodUsr := RetCodUsr()
	Default lShowMsg   := .F.
	Default cFiltEmp1  := Space(nTAMCODIGO)
	Default cFiltFil1  := Space(nTAMFILIAL)
	Default cFiltEmp2  := Replicate("Z",nTAMCODIGO)
	Default cFiltFil2  := Replicate("Z",nTAMFILIAL)

	aUsrAccess := aClone( fAccesEFUSR(cVerCodUsr,lShowMsg) )

	dbSelectArea("SM0")
	aArea := GetArea()

	nTodas := aScan(aUsrAccess, {|x| AllTrim(x) == "@@@@" })

	CursorWait()
	aEmpsFils := {}

	dbSelectArea("SM0")
	dbSetOrder(1)
	dbGoTop()

	While !Eof()

		cVerCodEmp := PADR(SM0->M0_CODIGO,nTAMCODIGO," ")
		cVerCodFil := PADR(SM0->M0_CODFIL,nTAMFILIAL," ")

		If cVerCodEmp < cFiltEmp1 .Or. cVerCodEmp > cFiltEmp2
			dbSelectArea("SM0")
			dbSkip()
			Loop
		ElseIf cVerCodEmp == cFiltEmp1 .And. cVerCodFil < cFiltFil1
			dbSelectArea("SM0")
			dbSkip()
			Loop
		ElseIf cVerCodEmp == cFiltEmp2 .And. cVerCodFil > cFiltFil2
			dbSelectArea("SM0")
			dbSkip()
			Loop
		EndIf

		If nTodas > 0
			lTemAcesso := .T.
		Else
			lTemAcesso := ( aScan(aUsrAccess, {|x| AllTrim(x) == Alltrim(cVerCodEmp+cVerCodFil) }) > 0 )
		EndIf

		If lTemAcesso
			aAdd(aEmpsFils, {cVerCodEmp, cVerCodFil})
		EndIf

		dbSelectArea("SM0")
		dbSkip()

	End While

	If nTodas > 0
		aAdd(aEmpsFils, {"ALL","ALL"})
	EndIf

	If Len(aEmpsFils) > 0
		aSort(aEmpsFils, , , {|x,y| x[1]+x[2] < y[1]+y[2] })
	EndIf

	CursorArrow()

	RestArea(aArea)

Return aEmpsFils

//---------------------------------------------------------------------
/*/{Protheus.doc} fAccesEFUSR
Função para buscar as empresas e filiais as quais um determinado
usuario possui acesso.

Essa função é a implementação para o padrão, da função OASACESS que
se encontra no fonte OAS1UTIL (OAS).
André Felipe Joriatti

@param String cVerCodUsr: Opcional;
Indica um usuario em especifico para
pesquisar.
Default: Usuario Atual.

@param Boolean lShowMsg: Opcional;
Indica se deve mostrar a mensagem.
.T. - Mostra a mensagem
.F. - Nao mostra a mensagem
Default: .F.

@author Wagner S. de Lacerda
@since 23/08/2011
@version P11
@return Array aUsrAccess: Array com as empresas/filiais as
	quais o usuario possui acesso.

/*/
//---------------------------------------------------------------------
Static Function fAccesEFUSR( cVerCodUsr,lShowMsg )

	Local aArea      := GetArea()
	Local aUsrAccess := {}
	Local aGroups    := {}
	Local nGroup, nEmpFil
	Local nTotal := 0

	Default cVerCodUsr := RetCodUsr()
	Default lShowMsg   := .F.

	PswOrder(1)
	If PswSeek(cVerCodUsr,.T.)
		dbSelectArea("SM0")
		aArea := GetArea()

		//Verifica se a restrição será pelo grupo de usuários
		If Len(PswRet(0)[1][10]) > 0 //.And. PswRet()[2][11]
			aGroups := PswRet(0)[1][10]

			//Adiciona as Empresas e Filiais de todos os Grupos do usuário
			For nGroup := 1 To Len(aGroups)
				//Seta no Grupo para buscar informações
				If PswSeek(aGroups[nGroup],.F.)

					//Veifica e adiciona Empresa e Filial permitida para o grupo
					aEmpFil := FWGrpEmp(aGroups[nGroup])
					For nEmpFil := 1 To Len(aEmpFil)
						//Verifica se já não foi adicionado na array
						If aScan(aUsrAccess,aEmpFil[nEmpFil]) == 0
							aAdd(aUsrAccess,aEmpFil[nEmpFil])
						EndIf
					Next nEmpFil
				EndIf
			Next nGroup
		Else
			//Utiliza as restrições direto do usuário
			aUsrAccess := PswRet(0)[2][6]
		EndIf

		//Verifica se array contem todas as empresas e filiais
		dbSelectArea("SM0")
		dbGoTop()
		dbEval({|| nTotal++},,{ || aScan( aUsrAccess,{ SM0->M0_CODIGO + SM0->M0_CODFIL } ) == 0 } )

		//Se todas as empresas e filiais estiverem na array, troca-se para @@@@
		//Reduzindo a lentidao e nao ocorrendo erro de overflow
		If nTotal == 0
			aUsrAccess := {"@@@@"}
		EndIf
	EndIf

	If lShowMsg .And. Len(aUsrAccess) == 0
		ApMsgAlert("Usuário não encontrado no cadastro do sistema.")//"Usuário não encontrado no cadastro do sistema."
		Return aUsrAccess
	EndIf


	RestArea(aArea)

Return aUsrAccess

//---------------------------------------------------------------------
/*/{Protheus.doc} fRecnoTV1
Função utilizada para buscar numa tabela específica o Recno correspondente
a um registro a partir da chave.

@author Pedro Henrique Soares de Souza
@since 24/12/2014
@version P11
@return nRecno Recno do registro na tabela especificada

@obs Esta função foi criada pois o registro armazenado na TRB não possui
o mesmo Recno armazenado da tabela.
/*/
//---------------------------------------------------------------------
Static Function fRecnoTV1()

	Local nRecno := 0

	dbSelectArea("TV1")
	dbSetOrder(1)
	If dbSeek( (c852TRB)->TV1_FILIAL + (c852TRB)->TV1_EMPRES + (c852TRB)->TV1_CODBEM +;
		DToS((c852TRB)->TV1_DTSERV) + (c852TRB)->TV1_TURNO + (c852TRB)->TV1_HRINI + (c852TRB)->TV1_HRFIM )

		nRecno := Recno()
	EndIf

Return nRecno

//---------------------------------------------------------------------
/*/{Protheus.doc} fUpdateTRB
Função utilizada para atualizar os registros da tabela temporária caso
o usuário tenha feito alguma alteração/exclusão

@author Pedro Henrique Soares de Souza
@since 24/12/2014
@version P11
@return Nil Nulo

@obs Esta função foi criada pois o registro armazenado na TRB não possui
o mesmo Recno armazenado da tabela.
/*/
//---------------------------------------------------------------------
Static Function fUpdateTRB( nRecnoTV1, lExclui )

	Local aAreaOld := GetArea()

	dbSelectArea("TV1")
	dbGoTo(nRecnoTV1)		//Posiciona no registro alterado/excluído

	dbSelectArea(c852TRB)
	dbSetOrder(1)
	If dbSeek( TV1->TV1_FILIAL + TV1->TV1_EMPRES + TV1->TV1_CODBEM + DToS(TV1->TV1_DTSERV) +;
			TV1->TV1_TURNO + TV1->TV1_HRINI + TV1->TV1_HRFIM )

		If lExclui
			RecLock(c852TRB, .F.)
			(c852TRB)->( dbDelete() )
			MsUnlock(c852TRB)
		Else
			BEGIN TRANSACTION

				RecLock(c852TRB, .F.)

				(c852TRB)->TV1_EMPRES	:= TV1->TV1_EMPRES
				(c852TRB)->TV1_FILIAL	:= TV1->TV1_FILIAL
				(c852TRB)->TV1_CODBEM	:= TV1->TV1_CODBEM
				(c852TRB)->TV1_PLACA		:= TV1->TV1_PLACA
				(c852TRB)->TV1_TURNO		:= TV1->TV1_TURNO
				(c852TRB)->TV1_DTSERV	:= TV1->TV1_DTSERV
				(c852TRB)->TV1_HREXI		:= TV1->TV1_HREXI
				(c852TRB)->TV1_HREXF		:= TV1->TV1_HREXF
				(c852TRB)->TV1_HRINI		:= TV1->TV1_HRINI
				(c852TRB)->TV1_CONINI	:= TV1->TV1_CONINI
				(c852TRB)->TV1_HRFIM		:= TV1->TV1_HRFIM
				(c852TRB)->TV1_CONFIM	:= TV1->TV1_CONFIM
				(c852TRB)->TV1_OPERAD	:= TV1->TV1_OPERAD

				MsUnlock(c852TRB)

			END TRANSACTION
		EndIf
	EndIf

	RestArea(aAreaOld)

Return Nil