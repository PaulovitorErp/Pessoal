#INCLUDE "MNTA681.ch"
#INCLUDE "PROTHEUS.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA681()
Controle Diario de Abastecimento e Lubrificacao

@author Marcos Wagner Junior
@since 13/05/2010
/*/
//---------------------------------------------------------------------
Function MNTA681( cFolha )

	Local aNGBeginPrm := {}
	Local oBrowse

	If MNTAmIIn( 95 )
		
		aNGBeginPrm := NGBeginPrm()

		//Alias temporários utilizados em tela
		Private cAliasLub, cAliasCmp, cAliasDet

		//Objetos utilizados para construção da MsNewGetDados
		Private oGLubrif, oGProdPrc, oGItensCmp, oGProdCmp

		//Variável utilizada no filtro da consulta ST3
		Private lCorret := .T.

		Private nPOSFROTA, nPOSDESFR, nPOSHORAB, nPOSCONT2, nPOSHODOM, nPOSQUANT, nPOSPLACA, nPosMotor :=0, nPosNomMo :=0
		Private nPosCodPrc, nPosQtdPrc, nPosUniPrc, nPosLocPrc, nPosDesPrc, nPosCusPrc
		Private nPosIndic, /*nPosItens,*/ nPosTotal, nPosMoePrc
		Private nPosBemCmp, nPosHodCmp, nPosNomCmp, nPosQtdCmp,nPosUniCmp, nPosLocCmp, nPosCodCmp, nPosDesCmp, nPosCusCmp, nPosMoeCmp

		Private nLanca   := STR0001 //"Lubrificante"
		Private lRastr   := .F.
		Private nPOSLOTE := 0

		//Variaveis usadas no MNTA655 e MNTA656
		Private lNaoAlt656 	:= .t.
		Private TIPOACOM 	:= .f.
		Private TipoAcom2   := .F.
		Private lTpLub	 	:= .f.
		Private cTabCC   	:= If(CtbInUse(), "CTT", "SI3")
		Private cModoCC  	:= NGSX2MODO(cTabCC)
		Private cModoDA4 	:= NGSX2MODO("DA4")
		Private cModoSB1 	:= NGSX2MODO("SB1")
		Private cModoSB2 	:= NGSX2MODO("SB2")
		Private cModoSD3 	:= NGSX2MODO("SD3")
		Private cModoST9 	:= NGSX2MODO("ST9")
		Private cModoSTC 	:= NGSX2MODO("STC")
		Private cModoSTZ 	:= NGSX2MODO("STZ")
		Private cModoTQS 	:= NGSX2MODO("TQS")
		Private cModoTT8 	:= NGSX2MODO("TT8")
		Private cModoTQI 	:= NGSX2MODO("TQI")
		Private cModoTQJ 	:= NGSX2MODO("TQJ")
		Private cModoTQN 	:= NGSX2MODO("TQN")
		Private lSegCont 	:= NGCADICBASE("TQN_POSCO2","A","TQN",.F.)
		Private cFilBem
		Private lPrev 		:= .t.
		Private cUsaInt3	:= AllTrim(GetMv("MV_NGMNTES"))
		Private cConEst 	:= AllTrim(GetMv("MV_ESTHOME"))
		Private cIntMntEst 	:= AllTrim(GetMv("MV_NGMNTES"))
		Private lEstNega	:= SuperGetMV("MV_ESTNEG") == "S" //³ Variavel usada para identificar se usuario permite que o estoque fique negativo. Se permitir, a variavel vale .T. ³
		Private nCapTan   	:= 0
		Private cCodCom		:= ""
		Private cTTAComb	:= ""
		Private cFilBens	:= ""
		Private cTanqueAnt	:= ""
		Private cBemAnt		:= ""

		Private dDataAbast 	:= dDataBase

		Private cCadastro   := OemToAnsi(STR0002) //"Controle Diário de Abastecimento e Lubrificação"
		Private aVETINR 	:= {}

		Private cMotorista  := ''
		Private lCUSTO 		:= ( cUsaInt3=='N' )
		Private lMMoeda 	:= NGCADICBASE("TL_MOEDA","A","STL",.F.) // Multi-Moeda

		Private aApenasLub 	:= {} // Array com os registros que são apenas lubrifica
		Private aOldInfo01 	:= {} // Array com o estado anterior dos parâmetros aInfo da GetDados
		Private cCombust	:= ""
		Private cFiliST9 	:= xFilial("ST9")	//Variável utilizada em chamadas de função do MNTA655

		If !MntCheckCC("MNTA682") .Or. !fValInit()
			Return .F.
		EndIf

		If !Empty(cFolha)
			SetInclui()
			MNT681INC4(,, 3,cFolha)
		Else

			oBrowse := FWMBrowse():New()

				oBrowse:SetChgAll(.F.)				// Não exibe tela de seleção de filial
				oBrowse:SetAlias( "TTA" )			// Alias da tabela utilizada
				oBrowse:SetMenuDef( "MNTA681" )		// Nome do fonte onde está a função MenuDef
				oBrowse:SetDescription( STR0002 )	// Descrição do browse

				oBrowse:Activate()
		EndIf

		NGReturnPrm( aNGBeginPrm )

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Opções de menu

@return aRotina - Estrutura;
@obs[n,1] Nome a aparecer no cabecalho
	[n,2] Nome da Rotina associada
	[n,3] Reservado
	[n,4] Tipo de Transação a ser efetuada:
		1 - Pesquisa e Posiciona em um Banco de Dados
		2 - Simplesmente Mostra os Campos
		3 - Inclui registros no Bancos de Dados
		4 - Altera o registro corrente
		5 - Remove o registro corrente do Banco de Dados
		6 - Alteração sem inclusão de registros
		7 - Cópia
		8 - Imprimir
	[n,5] Nivel de acesso
	[n,6] Habilita Menu Funcional

@author Ricardo Dal Ponte
@since Data 29/11/2006
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {	{ STR0073, "AxPesqui"  , 0, 1},;//"Pesquisar"
						{ STR0074, "MNT681INC4", 0, 2},;//"Visualizar"
						{ STR0075, "MNT681INC4", 0, 3},;//"Incluir"
						{ STR0076, "MNT681INC4", 0, 4},;//"Alterar"
						{ STR0122, "MNT681INC4", 0, 5}} //"Excluir"

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT681INC4()
Foco na linha da GetDados

@author Marcos Wagner Junior
@since 21/05/2010
/*/
//---------------------------------------------------------------------
Function MNT681INC4(cAlias, nReg, nOpcx, _cFolha)

	Local oDlg, oPanelScr, oPnlCab, oPnlTop, oPnlBottom

	Local oFont14 := TFont():New("Arial",, 14, .T., .T.)
	Local oFont16 := TFont():New("Arial",, 16, .T., .T.)

	Local a656Info   := GetApoInfo( 'MNTA656.PRW' )
	Local aStructLub := {}
	Local aStructCmp := {}
	Local aStructDet := {}
	Local oArqTrbLub
	Local oArqTrbCmp
	Local oArqTrbDet

	Local lRet := .T.

	Local cOldFil := cFilAnt

	//Variaveis de Largura/Altura da Janela
	Local nAltura    := ( GetScreenRes()[2] - 85 )
	Local nLargura   := ( GetScreenRes()[1] - 7  )
	Local lGrava     := .F.

	Local dDtUlMes	:= SuperGetMv("MV_ULMES", .F., SToD(""))
	Local dDtBlqMov	:= SuperGetMV("MV_DBLQMOV", .F., SToD("") )

	//Alias Tabelas Temporárias
	Private cAliasLub  := GetNextAlias()
	Private cAliasCmp  := GetNextAlias()
	Private cAliasDet  := GetNextAlias()

	//Variáveis utilizadas para controle da MsGetDados
	Private aCols		:= {}, aHeader		:= {}, aOldCols		:= {}
	Private aColsLuPai	:= {}, aHeadLuPai	:= {}, aOldCols02	:= {}
	Private aColsLuComp	:= {}, aHeadLuComp	:= {}, aOldCols03	:= {}
	Private aColsResumo	:= {}, aHeadResum	:= {}, aOldCols04	:= {}
	Private aAlterGCmp	:= {}, aAlterGDet	:= {}

	Private nCombDif := 0
	Private nCombAnt := 0
	Private nCombAtu := 0
	Private nCombDig := IIf(Inclui, 0, TTA->TTA_TOTCOM)
	Private nCombTot := IIf(Inclui, 0, TTA->TTA_TOTCOM)

	Private aNgButton:= {}

	Private cMotGer		:= AllTrim( GetNewPar("MV_NGMOTGE", " ") )
	Private cGeraPrev	:= AllTrim( GetNewPar("MV_NGGERPR", " ") )
	Private lEstNeg		:= AllTrim( GetNewPar("MV_ESTNEG" , "N") ) == "S"
	Private lGravaTQJ	:= .F.
	Private lGeraOSAut	:= .F.
	Private lWhen		:= .T.

	Private cCodObra	:= cFilAnt
	Private cDesObra	:= Space(40)
	Private cPosto		:= Space( TamSx3("A2_COD")[1] ) //Space(06)
	Private cFolha		:= Space( TamSX3('TVJ_FOLHA')[1] )
	Private cDesPosto	:= Space(40)
	Private cTroca		:= Space(06), cReposicao := Space(06)
	Private cDesRepo, cDesTroca
	Private cLoja := '  ', cTanque := '  ', cBomba := '   '
	Private cHrAb656	:= SubStr(TIME(),1,5)
	Private lFirstTime	:= .T.

	Private nLinGet01 := 1  //posicao corrente (nAt) no Get01

	cTTAComb := IIF(Inclui,Space(Len(TQN->TQN_CODCOM)),MNT656CMB())

	dbSelectArea("TQF")
	dbSetOrder(1)
	If !Inclui
		cCodObra   := TTA->TTA_FILIAL
		cFolha     := TTA->TTA_FOLHA
		cPosto     := TTA->TTA_POSTO
		cLoja      := TTA->TTA_LOJA
		cDesPosto  := NGSeek('TQF', cPosto + cLoja, 1, 'TQF->TQF_NREDUZ')
		cTanque    := TTA->TTA_TANQUE
		cBomba     := TTA->TTA_BOMBA
		dDataAbast := TTA->TTA_DTABAS
		cHrAb656   := TTA->TTA_HRABAS
		cTroca     := TTA->TTA_SERTRO
		cReposicao := TTA->TTA_SERREP
		cDesTroca  := Trim( NGSEEK('ST4', cTroca, 1, 'ST4->T4_NOME') )
		cDesRepo   := Trim( NGSEEK('ST4', cReposicao, 1, 'ST4->T4_NOME') )
		nCombAnt := TTA->TTA_CONBOM - TTA->TTA_TOTCOM
		nCombAtu := TTA->TTA_CONBOM

	EndIf

	//Carrega descricao da Obra
	LoadDesc(1)

	If nOpcx == 5
		// Verifica se o fonte MNTA656 está atualizado, assim podendo executar a deleção do abastecimento
		If DtoS( a656Info[4] ) + a656Info[5]  >= '2019032909:13:00'
			//Validações para exclusão da folha
			lRet := MNTA656DEL(cAlias,nReg,nOpcx, 2, cCodObra)

			If lRet .And. cUsaInt3 == "S" // Se integrado ao estoque
				If dDtUlMes > TTA->TTA_DTABAS
					// "ATENCAO" ## "Exclusão não permitida!" ## " no dia " ##
					// "Somente é permitido excluir resgistros com data superior a data do fechamento de estoque."
					// "Verifique o parâmetro: "
					ShowHelpDlg( STR0007, { STR0124 + CRLF + STR0125 }, 1, { STR0127 + "MV_ULMES" }, 1 )
					lRet := .F.
				EndIf

				If lRet .And. !Empty(dDtBlqMov) .And. dDtBlqMov > TTA->TTA_DTABAS
					// "ATENCAO" ## "Exclusão não permitida!" ## " no dia " ##
					// "Somente é permitido excluir resgistros com data superior a data do fechamento de estoque."
					// "Verifique o parâmetro: "
					ShowHelpDlg( STR0007, { STR0124 + CRLF + STR0126 }, 1, { STR0127 + 'MV_DBLQMOV' }, 1 )
					lRet := .F.
				EndIf
			EndIf
		Else
			// "Para utilzar a opção de Exclusão será necessário atualizar a rotina MNTA656" ## "ATENÇÃO"
			MsgInfo( STR0131, STR0007 )
			lRet := .F.
		EndIf
	EndIf

	If lRet

		//---------------------------------------------------------------------
		// Lubrificação do equipamento principal
		//---------------------------------------------------------------------
		aAdd(aStructLub, {"CODBEM", "C", TamSX3( "T9_CODBEM" )[1], 0})
		aAdd(aStructLub, {"PRODUT", "C", TamSX3( "B1_COD" )[1]   , 0})
		aAdd(aStructLub, {"QUANTI", "N", 09,2})
		aAdd(aStructLub, {"UNIDAD", "C", 02,0})
		aAdd(aStructLub, {"DESTIN", "C", 01,0})
		aAdd(aStructLub, {"HORABA", "C", 05,0})
		aAdd(aStructLub, {"ALMOXA", "C", TamSX3( "NNR_CODIGO" )[1], 0})
		aAdd(aStructLub, {"CUSTO" , "N", 10,2})

		If lMMoeda
			aAdd(aStructLub, {"MOEDA", "C", 01, 0})
		EndIf

		//Criação Tabela Temporária
		oArqTrbLub := NGFwTmpTbl(cAliasLub,aStructLub,{{"CODBEM","PRODUT","HORABA"},{"CODBEM","HORABA"}})

		//---------------------------------------------------------------------
		// Lubrificação de componentes
		//---------------------------------------------------------------------
		aAdd(aStructCmp,{"CODBEM", "C", 16, 0})
		aAdd(aStructCmp,{"HORABA", "C", 05, 0})
		aAdd(aStructCmp,{"INDICA", "C", 01, 0})
		aAdd(aStructCmp,{"TOTITE", "N", 03, 0})
		aAdd(aStructCmp,{"QTDTOT", "N", 09, 0})

		//Criação Tabela Temporária
		oArqTrbCmp := NGFwTmpTbl(cAliasCmp,aStructCmp,{{"CODBEM","HORABA"}})

		//---------------------------------------------------------------------
		// Detalhes dos componentes dos equipamentos
		//---------------------------------------------------------------------
		aAdd(aStructDet, {"CODBEM", "C", TamSX3( "T9_CODBEM" )[1], 0})
		aAdd(aStructDet, {"COMPON", "C", 16, 0})
		aAdd(aStructDet, {"DESCOM", "C", 40, 0})
		aAdd(aStructDet, {"HODOM",  "N", 09, 0})
		aAdd(aStructDet, {"QUANTI", "N", 09, 2})
		aAdd(aStructDet, {"UNIDAD", "C", 02, 0})
		aAdd(aStructDet, {"PRODUT", "C", TamSX3( "B1_COD" )[1],0})
		aAdd(aStructDet, {"DESTIN", "C", 01, 0})
		aAdd(aStructDet, {"HORPAI", "C", 05, 0})
		aAdd(aStructDet, {"ALMOXA", "C", TamSX3( "NNR_CODIGO" )[1],0})
		aAdd(aStructDet, {"CUSTO" , "N", 10, 2})

		If lMMoeda
			aAdd(aStructDet,{"MOEDA" , "C", 01,0})
		EndIf

		//Criação Tabela Temporária
		oArqTrbDet := NGFwTmpTbl(cAliasDet,aStructDet,{{"CODBEM","COMPON","HORPAI"},{"CODBEM","HORPAI"}})

		Define MsDialog oDlg From 120,0 To nAltura, nLargura Title cCadastro Of oMainWnd COLOR CLR_BLACK,CLR_WHITE Pixel

			oDlg:lMaximized := .T.
			oDlg:lEscClose  := .F.

			nAltCab := 54
			nAltPnl := ( nAltura / 2 ) - nAltCab - 40

			//Panel Allclient na dialog, para que fique posicionada de forma correta a Enchoice.
			oPanelScr := TPanel():New( 0, 0,, oDlg,,,,,, 10, 10, .F., .F. )
				oPanelScr:Align := CONTROL_ALIGN_ALLCLIENT

			oPnlCab := TPanel():New(0,0,,oPanelScr,,,,,,nLargura,nAltCab,.F.,.F.)
				oPnlCab:Align := CONTROL_ALIGN_TOP

			lPode := Inclui .Or. Altera

			//+--------------------------------------------------------------------+
			//| Box - Folha                                                        |
			//+--------------------------------------------------------------------+
			TGroup():New(002, 002, 37, 200, STR0133, oPnlCab,,, .T.) //"Folha"
			@ 010,005 Say OemToAnsi(STR0010) Of oPnlCab Pixel COLOR CLR_HBLUE FONT oFont14 //"Folha:"
			@ 009,025 MsGet oFolha Var cFolha Of oPnlCab Valid NaoVazio(cFolha) .And. fVldFolha() Picture Replicate("9",Len(TTA->TTA_FOLHA)) Size 58,08 HASBUTTON F3 'TVJ' Pixel When Inclui .And. lWhen

			@ 010,083 Say OemToAnsi(STR0013) Of oPnlCab Pixel COLOR CLR_HBLUE FONT oFont14 //"Data:"
			@ 009,101 MsGet dDataAbast Of oPnlCab Valid VALDT(dDataAbast) .And. LoadDesc(2) Picture '@!' Size 45,08 HASBUTTON Pixel When Inclui .And. lWhen

			@ 010,148 Say OemToAnsi(STR0014) Of oPnlCab Pixel COLOR CLR_HBLUE FONT oFont14 //"Hora:"
			@ 009,166 MsGet cHrAb656 Of oPnlCab Valid NGVALHORA(cHrAb656) .And. LoadDesc(2) Picture '99:99' Size 16,08 HASBUTTON Pixel When Inclui
			@ 023,005 Say OemToAnsi(STR0011) Of oPnlCab Pixel COLOR CLR_HBLUE FONT oFont14 //"Filial:"
			@ 022,025 MsGet cCodObra Of oPnlCab Valid NaoVazio(cCodObra) .And. ExistCpo('SM0',SM0->M0_CODIGO+cCodObra) .And. LoadDesc(1) Picture '@!' Size 24,08 HASBUTTON F3 "XM0" Pixel When Inclui .And. lWhen
			@ 022,072 MsGet cDesObra Of oPnlCab Picture '@!' Size 123,08 Pixel When .F.

			//+--------------------------------------------------------------------+
			//| Box - Bomba                                                        |
			//+--------------------------------------------------------------------+
			TGroup():New(002, 205, 37, 435, STR0047, oPnlCab,,, .T.) //"Bomba"
			@ 010,208 Say OemToAnsi(STR0012) Of oPnlCab Pixel COLOR CLR_HBLUE FONT oFont14 //"Comboio:"
			@ 009,240 MsGet cPosto Of oPnlCab Valid If(!Empty(cPosto), ExistCpo("TQF",cPosto),.T.) .And. LoadDesc(2) .And. MNTA656FOL( cPosto, cLoja, cFolha) Picture '@!' Size 80,08 HASBUTTON F3 "NGN" Pixel When Inclui .And. lWhen
			@ 009,323 MsGet cDesPosto Of oPnlCab Picture '@!' Size 98,08 Pixel When .F.

			@ 023,208 Say OemToAnsi(STR0123) Of oPnlCab Pixel COLOR CLR_HBLUE FONT oFont14 //"Início:"
			@ 022,240 MsGet nCombAnt Of oPnlCab Valid NaoVazio(nCombAnt) Picture '@E 9,999,999.99' Size 50,08 HASBUTTON Pixel When .F.

			@ 023,295 Say OemToAnsi(STR0016) Of oPnlCab Pixel COLOR CLR_HBLUE FONT oFont14 //"Fim:"
			@ 022,312 MsGet nCombAtu Of oPnlCab Valid NaoVazio(nCombAtu) .And. Positivo() .And. MNT656CTOT() Picture '@E 9,999,999.99' Size 48,08 HASBUTTON Pixel When lPode//Inclui

			@ 023,360 Say OemToAnsi(STR0017) Of oPnlCab Pixel FONT oFont14 //"Diferença:"
			@ 022,391 MsGet nCombTot Of oPnlCab Picture '@E 9,999,999.99' Size 40,08 HASBUTTON Pixel When .F.

			//+--------------------------------------------------------------------+
			//| Box - Serviço                                                      |
			//+--------------------------------------------------------------------+
			TGroup():New(002, 440, 37, 633, STR0132, oPnlCab,,, .T.) //"Serviço"
			@ 010,445 Say OemToAnsi(STR0018) Of oPnlCab Pixel FONT oFont14 //"Troca:"
			@ 009,480 MsGet cTroca Of oPnlCab Valid IIf(!Empty(cTroca), MNTA656SEC(cTroca) .And. MNTA656SER(1, .T.),MNTA656SER(1, .T.)) Picture '@!' Size 40,08 HASBUTTON F3 "ST3" Pixel When Inclui .Or. (Altera .And. Empty(TTA->TTA_SERTRO))
			@ 009,523 MsGet cDesTroca Of oPnlCab Picture '@!' Size 105,08 Pixel When .f.

			@ 023,445 Say OemToAnsi(STR0019) Of oPnlCab Pixel FONT oFont14 //"Reposição:"
			@ 022,480 MsGet cReposicao Of oPnlCab Valid IIf(!Empty(cReposicao),MNTA656SEC(cReposicao) .And. MNTA656SER(2, .T.),MNTA656SER(2, .T.)) Picture '@!' Size 40,08 HASBUTTON F3 "ST3" Pixel When Inclui .Or. (Altera .And. Empty(TTA->TTA_SERREP))
			@ 022,523 MsGet cDesRepo Of oPnlCab Picture '@!' Size 105,08 Pixel When .F.
			//---------------------------------------------------------------------
			//Cria Panel principal
			//---------------------------------------------------------------------
			oPanelAll := TPanel():New(0, 0, '', oPanelScr, oFont14, .T.,,, RGB(214, 214, 214), 10, 10, .F., .F.)
				oPanelAll:Align := CONTROL_ALIGN_ALLCLIENT

			//---------------------------------------------------------------------
			//Cria Splitter na horizontal
			//---------------------------------------------------------------------
			oSplitter := tSplitter():New(01, 01, oPanelAll, nLargura, nAltPnl *0.60, 0)
				oSplitter:Align := CONTROL_ALIGN_BOTTOM
				oSplitter:SetChildCollapse(.F.)
				oSplitter:nHeight := nAltPnl * 0.60

			//---------------------------------------------------------------------
			//Cria cabecalho superior
			//---------------------------------------------------------------------
			oPanelTop := TPanel():New(0, 0, '', oPanelAll, oFont14, .T.,,, RGB(214, 214, 214), 10, 10, .F., .F.)
				oPanelTop:Align := CONTROL_ALIGN_TOP

			//Panel de cabeçalho GetDados abastecimento
			oPnlLub := TPanel():New(0, 0, STR0020, oPanelTop, oFont14, .T.,,, RGB(214, 214, 214), nLargura * 0.42, 10) //'Abastecimento'
				oPnlLub:Align := CONTROL_ALIGN_LEFT
				oPnlLub:nWidth := nLargura*0.42

			//Panel de cabeçalho GetDados aplicação de produto no componente principal
			oPnlCmp := TPanel():New(0,0,STR0021,oPanelTop,oFont14,.t.,,,RGB(214,214,214),nLargura*0.38,10) //"Aplicação produto equipamento principal"
				oPnlCmp:Align := CONTROL_ALIGN_LEFT
				oPnlCmp:nWidth := nLargura*0.38

			//---------------------------------------------------------------------
			//Carrega campos dos aHeaders para utilizar no MsNewGetDados
			//---------------------------------------------------------------------
			fLoadHeads()

			//GetDados abastecimento
			oGLubrif := MsNewGetDados():New(30,0,nAltPnl*0.60,nLargura*0.30,If(lPode,GD_INSERT+GD_UPDATE+GD_DELETE,),'MNT681OK1(1)','MNT681OK1(2)',,,,9999,,,'MNT681LIDE(1)',oPanelAll,aHeader,aCols)
				oGLubrif:oBrowse:bChange := { || ChangeGet1(.t.) }
				oGLubrif:oBrowse:bGotFocus := { || ChangeGet1(.t.)}
				oGLubrif:oBrowse:Align := CONTROL_ALIGN_LEFT
				oGLubrif:aCols := BlankGetD(oGLubrif:aHeader)
				oGLubrif:oBrowse:nWidth := nLargura*0.42
				oGLubrif:oBrowse:lUseDefaultColors := .F.
				oGLubrif:oBrowse:SetBlkBackColor({ || f681ACor()})
				oGLubrif:lEditLine := .F.		// Desabilita a Edição por Linha (abre uma nova tela)
				oGLubrif:lCanEditLine := .F.	// Desabilita a Edição por Linha (abre uma nova tela)

			aOldInfo01 := aClone( oGLubrif:aInfo )

			//GetDados aplicação de produto no componente principal
			oGProdPrc := MsNewGetDados():New(30,nLargura*0.30,nAltPnl*0.60,nLargura*0.60,If(lPode,GD_INSERT+GD_UPDATE+GD_DELETE,),'MNT681OK3(2)','MNT681OK3(2)',,aAlterGCmp,,9999,,,'MNT681LIDE(2)',oPanelAll,aHeadLuPai,aColsLuPai)
				oGProdPrc:oBrowse:bChange := { || ChangeGet2() }
				oGProdPrc:oBrowse:bGotFocus := { || ChangeGet2()}
				oGProdPrc:oBrowse:bLostFocus := { || fLostFLub() }
				oGProdPrc:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
				oGProdPrc:aCols := BlankGetD(oGProdPrc:aHeader)
				oGProdPrc:oBrowse:nWidth := nLargura*0.38
				oGProdPrc:lEditLine := .F.		// Desabilita a Edição por Linha (abre uma nova tela)
				oGProdPrc:lCanEditLine := .F. // Desabilita a Edição por Linha (abre uma nova tela)

			//---------------------------------------------------------------------
			//Cria cabecalho inferior
			//---------------------------------------------------------------------
			oPnlBottom := TPanel():New(0,0,,oSplitter,,,,,,nLargura,nAltPnl*0.20,.F.,.F.)
			oPnlBottom:Align := CONTROL_ALIGN_BOTTOM

			oPnlCabe4 := TPanel():New(0,0,,oPnlBottom,oFont14,.t.,,,RGB(214,214,214),10,10,.F.,.F.)
				oPnlCabe4:Align := CONTROL_ALIGN_TOP

			//Panel de cabeçalho 'GetDados de Itens'
			oPnlItens := TPanel():New(0,0,STR0022,oPnlCabe4,oFont14,.t.,,,RGB(214,214,214),nLargura*0.20,10) //"Aplicação produto componentes"
				oPnlItens:Align := CONTROL_ALIGN_LEFT
				oPnlItens:nWidth := nLargura*0.25

			//Panel de cabeçalho 'GetDados Aplicação de produtos em componentes'
			oPnlDet := TPanel():New(0,0,STR0023,oPnlCabe4,oFont14,.t.,,,RGB(214,214,214),nLargura*0.20,10) //"Detalhamento aplicação de produto dos componentes do equipamento"
				oPnlDet:Align := CONTROL_ALIGN_ALLCLIENT

			//GetDados de Itens
			oGItensCmp := MsNewGetDados():New(30,nLargura*0.60,nAltPnl*0.60,nLargura,If(lPode,GD_INSERT+GD_UPDATE,),'MNT681OK2()','MNT681OK2()',,,,1,,,,oPnlBottom,aHeadResum,aColsResum)
				oGItensCmp:oBrowse:Align := CONTROL_ALIGN_LEFT
				oGItensCmp:aCols := BlankGetD(oGItensCmp:aHeader)
				oGItensCmp:oBrowse:nWidth := nLargura*0.25
				oGItensCmp:lEditLine := .F.		// Desabilita a Edição por Linha (abre uma nova tela)
				oGItensCmp:lCanEditLine := .F.	// Desabilita a Edição por Linha (abre uma nova tela)

			//GetDados Aplicação de produtos em componentes
			oGProdCmp := MsNewGetDados():New(0,0,10,50,If(lPode,GD_UPDATE,),'MNT681OK3(4)','MNT681OK3(4,.T.)',,aAlterGDet,,9999,,,'MNT681LIDE(3)',oPnlBottom,aHeadLuComp,aColsLuComp)
				oGProdCmp:oBrowse:bChange := { || ChangeGet4()}
				oGProdCmp:oBrowse:bGotFocus := { || ChangeGet4()}
				oGProdCmp:oBrowse:bLostFocus := { || fLostFLub()}
				oGProdCmp:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
				oGProdCmp:aCols := BlankGetD(oGProdCmp:aHeader)
				oGProdCmp:lEditLine := .F.		// Desabilita a Edição por Linha (abre uma nova tela)
				oGProdCmp:lCanEditLine := .F.	// Desabilita a Edição por Linha (abre uma nova tela)

			If !Inclui
				oGProdPrc:oBrowse:aAlter := {}
				oGProdCmp:oBrowse:aAlter := {}
			EndIf

			CarregaGets()

			aAdd(aNgButton,{"TANQUE" ,{||MNT681COMB(1)},STR0024,STR0024}) //"Comboio"###"Comboio"

			If ValType(_cFolha) == "C" //IsInCallStack("MNTABAA018")
				cFolha := _cFolha
				oFolha:SetFocus()
				oGLubrif:oBrowse:SetFocus()
			EndIf

		Activate MsDialog oDlg On Init EnchoiceBar(@oDlg, {|| IIf( lGrava := IIf( nOpcx == 3 .Or. nOpcx == 4, TudoOk(), .T. ), oDlg:End(),) },;
														{|| lGrava := .F.,oDlg:End()},, aNgButton) Centered

		If lGrava
			
			If nOpcx == 3 .Or. nOpcx == 4

				MNT681GRAV( lGrava )

			ElseIf nOpcx == 5

				MNT681Del( TTA->( RecNo() ) )

			EndIf

		EndIf

		//Deleção Tabelas Temporárias.
		oArqTrbLub:Delete()
		oArqTrbCmp:Delete()
		oArqTrbDet:Delete()

		cFilAnt := cOldFil
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} LoadDesc()
Carrega Descricao da filial e do Comboio/Centro de Custo

@author Marcos Wagner Junior
@since 14/05/2010
/*/
//---------------------------------------------------------------------
Function LoadDesc(_nOpc)

	Local aOldArea := GetArea()

	Local lDiferente := .F.
	Local lOldCont1	 := Nil

	If _nOpc == 1

		dbSelectArea("SM0")
		dbSetOrder(01)
		If MsSeek(SM0->M0_CODIGO + cCodObra)
			cDesObra := SM0->M0_FILIAL//SM0->M0_NOME

			//Limpa código do posto caso código não exista na filial selecionada
			If !NGExisteReg('TQF', cPosto + cLoja, 1, .F., cCodObra)[1]
				cPosto		:= Space( TamSX3('TTA_POSTO')[1] )
				cDesPosto	:= Space( TamSX3('TQF_NREDUZ')[1] )
			EndIf
		EndIf

		cFilAnt := cCodObra

	ElseIf _nOpc == 2

		If !Empty( cPosto )

			cLoja := IIf( TQF->TQF_CODIGO == cPosto .And. Empty(cLoja), TQF->TQF_LOJA, cLoja )

			If !MNT681COMB(2)
				Return .F.
			Else

				dbSelectArea("TQF")
				dbSetOrder(01)
				If dbSeek(xFilial("TQF") + cPosto + TQF->TQF_LOJA)

					dbSelectArea("SA2")
					dbSetOrder(1)
					If dbSeek(xFilial("SA2") + TQF->TQF_CODIGO + TQF->TQF_LOJA)
						cDesPosto := SA2->A2_NREDUZ
					EndIf

				EndIf

				dbSelectArea("TQG")
				dbSetOrder(01)
				dbSeek(xFilial("TQF") + cPosto + TQF->TQF_LOJA)
			EndIf
		EndIf

	ElseIf _nOpc == 3

		If ReadVar() == "M->TQN_FROTA"

			lDiferente := ( ValType(oGLubrif:aCols[oGLubrif:nAT][nPOSFROTA]) == "U" .Or.;
								( oGLubrif:aCols[oGLubrif:nAT][nPOSFROTA] <> M->TQN_FROTA ) )

			dbSelectArea("ST9")
			dbSetOrder(16)
			dbSeek(M->TQN_FROTA) //Para chegar nesta função, o Código do Bem já deve ser válido

			oGLubrif:aCols[oGLubrif:nAt][nPOSDESFR] := ST9->T9_NOME
			oGLubrif:aCols[oGLubrif:nAt][nPOSPLACA] := ST9->T9_PLACA

		ElseIf ReadVar() == "M->TQN_PLACA"

			lDiferente := IIf( Empty(M->TQN_PLACA), .F., ( ValType(oGLubrif:aCols[oGLubrif:nAT][nPOSPLACA]) == "U" .Or.;
									(oGLubrif:aCols[oGLubrif:nAT][nPOSPLACA] <> M->TQN_PLACA) ) )

			If lDiferente

				dbSelectArea("ST9")
				dbSetOrder(14)
				dbSeek(M->TQN_PLACA) //Para chegar nesta função, a Placa já deve ser válida

				oGLubrif:aCols[oGLubrif:nAt][nPOSFROTA] := ST9->T9_CODBEM
				oGLubrif:aCols[oGLubrif:nAt][nPOSDESFR] := ST9->T9_NOME

			EndIf

		EndIf

		ChangeGet1(.F.) //Carrega Getdados 2, 3 e 4 se o bem ja foi informado no abastecimento

		If lDiferente
			lOldCont1 := TIPOACOM

			oGLubrif:aCols[oGLubrif:nAt][nPOSHODOM] := 0 //Zera o contador para obrigar o usuário a informar
			oGProdCmp:aCols := BlankGetD(oGProdCmp:aHeader)	 //Limpa os componentes

			LoadComp(2) //Recarrega os componentes

			TipoAcom := lOldCont1
		EndIf

	ElseIf (_nOpc == 4 .Or. _nOpc == 5)

		dbSelectArea("SB1")
		dbSetOrder(01)
		If dbSeek(xFilial("SB1")+M->TL_CODIGO)

			dbSelectArea("SAH")
			dbSetOrder(01)
			If dbSeek(xFilial("SAH")+SB1->B1_UM)

				If _nOpc == 4

					oGProdPrc:aCols[oGProdPrc:nAt][nPosUniPrc] := SAH->AH_UNIMED
					oGProdPrc:aCols[oGProdPrc:nAt][nPosLocPrc] := cTanque
					oGProdPrc:Refresh()

				Elseif _nOpc == 5

					oGProdCmp:aCols[oGProdCmp:nAt][nPosUniCmp] := SAH->AH_UNIMED
					oGProdCmp:aCols[oGProdCmp:nAt][nPosLocCmp] := SB1->B1_LOCPAD

					oGProdCmp:Refresh()

				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aOldArea)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT681COMB()
Monta tela para o usuario digitar o complemento do comboio

@author Marcos Wagner Junior
@since 17/05/2010
/*/
//---------------------------------------------------------------------
Function MNT681COMB(nPar)

	Local aOldArea := GetArea()

	Local oDlgCmb, oPanelCmb
	Local oFont14 := TFont():New("Arial",,14,.T.,.T.)

	Local nOpca := 0, lRet := .T.//, lFound := !MNTA656FOL(cPosto, cLoja, cFolha)

	Private nTotalTQN //NAO RETIRAR ESSAS VARIAVEIS

	dbSelectArea("TV4")
	dbSetOrder(01)
	If !dbSeek(xFilial("TV4") + cPosto + cLoja) .Or. nPar == 1// .Or. lFound

		If Inclui
			//Quando posto do tipo comboio, carrega automaticamente loja, tanque e bomba (como sugestao)
			aArea := GetArea(); aAreaTQF := TQF->(GetArea()); aAreaTQJ := TQJ->(GetArea())

			dbSelectArea("TQF")
			dbSetOrder(01)
			If dbSeek(xFilial("TQF") + cPosto + cLoja)
				If TQF->TQF_TIPPOS == '2'

					dbSelectArea("TQJ")
					dbSetOrder(01)
					If dbSeek(xFilial("TQJ") + cPosto + cLoja)
						cTanque	 := TQJ->TQJ_TANQUE
						cBomba	 := TQJ->TQJ_BOMBA
						cTTAComb := Posicione("TQI", 1,xFilial("TQI") + cPosto + cLoja , "TQI_CODCOM")
					EndIf
				EndIf
			EndIf

			RestArea(aAreaTQJ); RestArea(aAreaTQF); RestArea(aArea)
		EndIf

		Define MsDialog oDlgCmb Title STR0043 From 90,0 To 320,370 Pixel //"Dados do Comboio"

			oDlgCmb:lEscClose := .F.

			oPanelCmb := TPanel():New( 0, 0,, oDlgCmb,,,,,, 10, 10, .F., .F. )
			oPanelCmb:Align := CONTROL_ALIGN_ALLCLIENT

			@ 10,8 Say OemToAnsi(STR0044) Size 150,07 Of oPanelCmb Pixel COLOR CLR_HRED FONT oFont14 //"Informe os dados abaixo referentes ao Comboio:"

			@ 25,12 Say STR0045 Size 47,07 Of oPanelCmb Pixel COLOR CLR_HBLUE FONT oFont14 //"Loja"
			@ 23,50 MsGet cLoja Size 30,08 Of oPanelCmb Pixel Valid NaoVazio() .And. ExistCpo("TQF",cPosto + cLoja)

			@ 38,12 Say STR0046 Size 47,07 Of oPanelCmb Pixel COLOR CLR_HBLUE FONT oFont14 //"Tanque"
			@ 36,50 MsGet cTanque Size 30,08 Of oPanelCmb Pixel HASBUTTON F3 "NGMTNQ" Valid NaoVazio() .And. MNT656TABO(1)

			@ 51,12 Say STR0128 Size 47,07 Of oPanelCmb Pixel COLOR CLR_HBLUE FONT oFont14 //"Combustível"
			@ 49,50 MsGet cTTAComb Size 30,08 Of oPanelCmb Pixel HASBUTTON F3 "NGMCOM" Valid Vazio() .Or. MNT656COMB(oGLubrif) .And. MNT656CTOT()

			@ 64,12 Say STR0047 Size 47,07 Of oPanelCmb Pixel COLOR CLR_HBLUE FONT oFont14 //"Bomba"
			@ 62,50 MsGet cBomba Size 30,08 Of oPanelCmb Pixel HASBUTTON F3 "TQJ" Valid NaoVazio() .And. MNT656TABO(2)

		Activate MsDialog oDlgCmb On Init EnchoiceBar(oDlgCmb, {|| (nOpca := 1, oDlgCmb:End())}, {|| oDlgCmb:End()},,,,,,, .F.) Centered

		If !( lRet := nOpca == 1 )
			cLoja    := Space(Len(TQF->TQF_LOJA))
			cBomba   := Space(Len(TQJ->TQJ_BOMBA))
			cTanque  := Space(Len(TQJ->TQJ_TANQUE))
			cTTAComb := Space(Len(TQI->TQI_CODCOM))
		Else
			If !Empty(cPosto) .And. !Empty(cLoja) .And. !Empty(cTanque) .And. !Empty(cBomba)
				MNT656TABO(2)
			EndIf
		EndIf
	Else

		cLoja   := TV4->TV4_LOJA
		cBomba  := TV4->TV4_BOMBA
		cTanque := TV4->TV4_TANQUE

		MNT656TABO(1)
		MNT656TABO(2)

		cDesPosto	:= NGSeek("TQF", TV4->TV4_COMBOI + TV4->TV4_LOJA, 1, 'TQF->TQF_NREDUZ')
		cCodCom		:= NGSeek("TQI", cPosto + cLoja + cTanque, 1, "TQI->TQI_CODCOM")
		cTTAComb    := cCodCom //variavel utilizada no MNTA656 para verificar saldo do produto
	EndIf

	RestArea(aOldArea)

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} fLoadHeads
Inicializa variáveis aHeader das MsNewGetDados

@author Pedro Henrique Soares de Souza
@since 21/08/2015
/*/
//-----------------------------------------------------------------------
Static Function fLoadHeads()

	Local cValidTQN := ""
	Local lSegCont  := NGCADICBASE("TQN_POSCO2","A","TQN",.F.)
	Local aCampo    := {"TQN_FROTA","TQN_PLACA","TQN_DESFRO","TQN_HRABAS","TQN_HODOM","TQN_POSCO2","TQQ_QUANT","TQN_CODMOT","TQN_NOMMOT"}
	Local nInd      := 0
	Local nTamTot   := 0
	Local cTitulo   := ""
	Local cPicture  := ""
	Local cValid    := ""
	Local cUso      := ""
	Local cTipo     := ""
	Local cF3       := ""
	Local cContext  := ""
	Local cRelac    := Nil
	Local cWhen     := Nil
	Local cCBox     := ""
	Local nTam      := 0
	Local nDec      := 0
	Local cValidAdc := "" //Valid adicional

	nTamTot := Len(aCampo)
	For nInd := 1 To nTamTot

		cCampo  := aCampo[nInd]
		cTitulo := Posicione("SX3",2,cCampo,"X3Titulo()")
		If !Empty(cTitulo)

			cPicture  := X3Picture(cCampo)
			cValid    := Posicione("SX3",2,cCampo,"X3_VALID")
			cUso      := Posicione("SX3",2,cCampo,"X3_USADO")
			cTipo     := Posicione("SX3",2,cCampo,"X3_TIPO")
			cF3       := Posicione("SX3",2,cCampo,"X3_F3")
			cContext  := Posicione("SX3",2,cCampo,"X3_CONTEXT")
			cRelac    := Nil
			cWhen     := Nil
			cCBox     := X3CBOX(cCampo)
			nTam      := TAMSX3(cCampo)[1]
			nDec      := TAMSX3(cCampo)[2]
			cValidAdc := ""

			If cCampo == "TQN_FROTA"

				cValidAdc := "MNT681DUPL(1) .And. MNT656COM( oGLubrif )"
				If !Empty(cValid)
					cValidAdc += " .And. " + AllTrim(cValid) + ".And. LoadDesc(3)"
				EndIf
				cValid := cValidAdc
				cF3    := "ST9BVE"

			ElseIf cCampo == "TQN_PLACA"
				cValid := "MNT681PLAC() .And. LoadDesc(3)"
			ElseIf cCampo == "TQN_HRABAS"
				cValid := "MNTA681VAL()"
			ElseIf cCampo == "TQN_HODOM"

				cValid += IIf( !Empty(cValid), ' .And. MNT655HOD()', 'MNT655HOD()' )
				cRelac := Posicione("SX3",2,cCampo,"X3_RELACAO")
				cWhen  := "MNTA681WHD()"

			ElseIf cCampo == "TQQ_QUANT"

				cCampo := "TQN_QUANT"
				cValid := "MNTA656CAP() .And. NZERABAS()"
				cRelac := Posicione("SX3",2,cCampo,"X3_RELACAO")
				cWhen  := "MNTA681WHD()"
			ElseIf cCampo == "TQN_CODMOT"
				cValid := " MNA655MO()"
			ElseIf cCampo == "TQN_NOMMOT"
				cContext := "V"
			ElseIf cCampo == "TQN_POSCO2"
				cValid := "MNA655HO(2) .And. MNT655HOD(2)"
			EndIf

			aAdd(aHeader, {cTitulo, cCampo, cPicture, nTam, nDec, cValid, cUso, cTipo, cF3, cContext, cCBox, cRelac, cWhen})

		EndIf

	Next nInd

	aCampo  := {"TT_CODIGO","TPE_AJUSCO","TCI_UNIMED","TL_LOCAL","TL_DESTINO","TL_CUSTO","TL_MOEDA"}
	nTamTot := Len(aCampo)
	For nInd := 1 To nTamTot

		cCampo  := aCampo[nInd]
		cTitulo := Posicione("SX3",2,cCampo,"X3Titulo()")
		If !Empty(cTitulo)

			cPicture  := X3Picture(cCampo)
			nTam      := TAMSX3(cCampo)[1]
			nDec      := TAMSX3(cCampo)[2]
			cValid    := Posicione("SX3",2,cCampo,"X3_VALID")
			cUso      := Posicione("SX3",2,cCampo,"X3_USADO")
			cTipo     := Posicione("SX3",2,cCampo,"X3_TIPO")
			cF3       := Posicione("SX3",2,cCampo,"X3_F3")
			cContext  := Posicione("SX3",2,cCampo,"X3_CONTEXT")
			cCBox     := X3CBOX(cCampo)
			cRelac    := Posicione("SX3",2,cCampo,"X3_RELACAO")
			cWhen     := Posicione("SX3",2,cCampo,"X3_WHEN")

			If cCampo == "TT_CODIGO"

				cCampo  := "TL_CODIGO"
				cTitulo := STR0030 //"Produto"
				cValid  := "MNT681VALD()"
				cF3     := "SB1
				cWhen   := "MNTA681WHD()"
			ElseIf cCampo == "TPE_AJUSCO"

				cCampo   := "TL_QUANTID"
				cTitulo  := Posicione( 'SX3', 2, cCampo, 'X3Titulo()' )
				cPicture := "999,999.99"
				nTam     := 9
				nDec     := 2
				cValid   := "Positivo()"
				cWhen    := "MNTA681WHD()"
			ElseIf cCampo == "TCI_UNIMED"

				cCampo  := "TL_UNIDADE"
				cTitulo := Posicione("SX3",2,cCampo,"X3Titulo()")
			ElseIf cCampo == "TL_LOCAL"

				cValid := "NGValAlmox('P')"
				cF3    := "NNR"
				cWhen  := ".T."
			ElseIf cCampo == "TL_DESTINO"

				nTam   := 1
				cValid := "Pertence('12')"
				cCBox  := STR0035 // "1=Troca;2=Reposicao"
				cWhen  := "MNTA681WHD()"
			ElseIf cCampo == "TL_CUSTO"

				cValid := "Positivo()"
			EndIf

			aAdd(aHeadLuPai, {cTitulo, cCampo, cPicture, nTam, nDec, cValid, cUso, cTipo, cF3, cContext, cCBox, cRelac, cWhen})

		EndIf

	Next nInd

	aCampo  := {"TT_CODIGO","TPE_AJUSCO"}
	nTamTot := Len(aCampo)
	For nInd := 1 To nTamTot

		cCampo  := aCampo[nInd]
		cTitulo := Posicione("SX3",2,cCampo,"X3Titulo()")
		If !Empty(cTitulo)

			cPicture  := X3Picture(cCampo)
			nTam      := TAMSX3(cCampo)[1]
			nDec      := TAMSX3(cCampo)[2]
			cValid    := Posicione("SX3",2,cCampo,"X3_VALID")
			cUso      := Posicione("SX3",2,cCampo,"X3_USADO")
			cTipo     := Posicione("SX3",2,cCampo,"X3_TIPO")
			cF3       := Posicione("SX3",2,cCampo,"X3_F3")
			cContext  := Posicione("SX3",2,cCampo,"X3_CONTEXT")
			cCBox     := X3CBOX(cCampo)
			cRelac    := Posicione("SX3",2,cCampo,"X3_RELACAO")
			cWhen     := Nil

			If cCampo == "TT_CODIGO"

				cTitulo := STR0037 // "Indicação"
				cCampo  := "INDICA"
				nTam    := 1
				cValid  := "Pertence('12') .And. MNT681INDI() .And. LoadComp(1)"
				cCBox   := STR0038 // "1=Sim;2=Nao"
				cWhen   := Posicione("SX3",2,cCampo,"X3_WHEN")
			ElseIf cCampo == "TPE_AJUSCO"

				cTitulo  := STR0040 // "Qtde Total"
				cCampo   := "QUANTID"
				cPicture := "999,999.99"
				nTam     := 9
				nDec     := 2
				cValid   := "Positivo()"
			EndIf

			aAdd(aHeadResum, {cTitulo, cCampo, cPicture, nTam, nDec, cValid, cUso, cTipo, cF3, cContext, cCBox, cRelac, cWhen})

		EndIf

	Next nInd


	aCampo  := {"T9_CODBEM","T9_NOME","TJ_POSCONT","TT_CODIGO","TPE_AJUSCO","TCI_UNIMED","TL_LOCAL","TL_DESTINO","TL_CUSTO","TL_MOEDA"}
	nTamTot := Len(aCampo)
	For nInd := 1 To nTamTot

		cCampo  := aCampo[nInd]
		cTitulo := Posicione("SX3",2,cCampo,"X3Titulo()")
		If !Empty(cTitulo)

			cPicture  := X3Picture(cCampo)
			nTam      := TAMSX3(cCampo)[1]
			nDec      := TAMSX3(cCampo)[2]
			cValid    := Posicione("SX3",2,cCampo,"X3_VALID")
			cUso      := Posicione("SX3",2,cCampo,"X3_USADO")
			cTipo     := Posicione("SX3",2,cCampo,"X3_TIPO")
			cF3       := Posicione("SX3",2,cCampo,"X3_F3")
			cContext  := Posicione("SX3",2,cCampo,"X3_CONTEXT")
			cCBox     := X3CBOX(cCampo)
			cRelac    := Posicione("SX3",2,cCampo,"X3_RELACAO")
			cWhen     := Posicione("SX3",2,cCampo,"X3_WHEN")

			If cCampo == "T9_CODBEM"
				cTitulo := STR0041 // "Componente"
			ElseIf cCampo == "T9_NOME"
				cTitulo := STR0026 // "Nome"
			ElseIf cCampo == "TJ_POSCONT"
				cTitulo := STR0028 // "Contador"
				cValid  := "MNT681CONT()"
				cRelac  := Nil
			ElseIf cCampo == "TT_CODIGO"
				cCampo  := "TL_CODIGO"
				cTitulo := STR0030 // "Produto"
				cValid  := "ExistCpo('SB1', M->TL_CODIGO) .And. LoadDesc(5)"
				cF3     := "SB1"
				cWhen   := "MNTA681WHD()"
			ElseIf cCampo == "TPE_AJUSCO"
				cCampo   := "TL_QUANTID"
				cPicture := "999,999.99"
				nTam     := 9
				nDec     := 2
				cValid   := "Positivo()"
				cWhen    := "MNTA681WHD()"
			ElseIf cCampo == "TCI_UNIMED"
				cCampo  := "TL_UNIDADE"
				cTitulo := Posicione("SX3",2,cCampo,"X3Titulo()")
			ElseIf cCampo == "TL_LOCAL"
				cValid := "NGValAlmox('P')"
				cF3    := "NNR"
				cWhen  := ".T."
			ElseIf cCampo == "TL_DESTINO"

				nTam   := 1
				cValid := "Pertence('12')"
				cCBox  := STR0035 // "1=Troca;2=Reposicao"
				cWhen  := "MNTA681WHD()"
			ElseIf cCampo == "TL_CUSTO"

				cTitulo := STR0036 // "Custo"
				cValid  := "Positivo()"
			ElseIf cCampo == "TL_MOEDA"

				cTitulo := STR0107 // "Moeda"
			EndIf

			aAdd(aHeadLuComp, {cTitulo, cCampo, cPicture, nTam, nDec, cValid, cUso, cTipo, cF3, cContext, cCBox, cRelac, cWhen})

		EndIf

	Next nInd

	aAlterGCmp := { "TL_CODIGO" , "TL_QUANTID", "TL_LOCAL" , "TL_DESTINO"}
	aAlterGDet := { "TJ_POSCONT", "TL_QUANTID", "TL_CODIGO", "TL_DESTINO", "TL_LOCAL" }

	If cUsaInt3 == 'N'
		aAdd(aAlterGCmp, "TL_CUSTO")
		aAdd(aAlterGDet, "TL_CUSTO")

		If lMMoeda
			aAdd(aAlterGCmp, "TL_MOEDA")
			aAdd(aAlterGDet, "TL_MOEDA")
		EndIf
	EndIf

	nPosFrota	 := aScan(aHeader, {|x| Trim( Upper(x[2]) ) == "TQN_FROTA" })
	nPosPlaca	 := aScan(aHeader, {|x| Trim( Upper(x[2]) ) == "TQN_PLACA" })
	nPosDesfr	 := aScan(aHeader, {|x| Trim( Upper(x[2]) ) == "TQN_DESFRO"})
	nPosHoraB	 := aScan(aHeader, {|x| Trim( Upper(x[2]) ) == "TQN_HRABAS"})
	nPosHodom	 := aScan(aHeader, {|x| Trim( Upper(x[2]) ) == "TQN_HODOM" })
	nPosQuant	 := aScan(aHeader, {|x| Trim( Upper(x[2]) ) == "TQN_QUANT" })
	nPosMotor	 := aScan(aHeader, {|x| Trim( Upper(x[2]) ) == "TQN_CODMOT"})
	nPosNomMo	 := aScan(aHeader, {|x| Trim( Upper(x[2]) ) == "TQN_NOMMOT"})

	nPosCodPrc	 := aScan(aHeadLuPai, {|x| Trim( Upper(x[2]) ) == "TL_CODIGO" })
	nPosQtdPrc	 := aScan(aHeadLuPai, {|x| Trim( Upper(x[2]) ) == "TL_QUANTID"})
	nPosUniPrc	 := aScan(aHeadLuPai, {|x| Trim( Upper(x[2]) ) == "TL_UNIDADE"})
	nPosLocPrc	 := aScan(aHeadLuPai, {|x| Trim( Upper(x[2]) ) == "TL_LOCAL"  })
	nPosDesPrc	 := aScan(aHeadLuPai, {|x| Trim( Upper(x[2]) ) == "TL_DESTINO"})
	nPosCusPrc	 := aScan(aHeadLuPai, {|x| Trim( Upper(x[2]) ) == "TL_CUSTO"  })
	nPosMoePrc	 := aScan(aHeadLuPai, {|x| Trim( Upper(x[2]) ) == "TL_MOEDA"  })

	nPosIndic	 := aScan(aHeadResum, {|x| Trim( Upper(x[2]) ) == "INDICA"})
	nPosTotal	 := aScan(aHeadResum, {|x| Trim( Upper(x[2]) ) == "QUANTID"})

	nPosBemCmp	 := aScan(aHeadLuComp, {|x| Trim( Upper(x[2]) ) == "T9_CODBEM" })
	nPosNomCmp	 := aScan(aHeadLuComp, {|x| Trim( Upper(x[2]) ) == "T9_NOME"   })
	nPosHodCmp	 := aScan(aHeadLuComp, {|x| Trim( Upper(x[2]) ) == "TJ_POSCONT"})
	nPosQtdCmp	 := aScan(aHeadLuComp, {|x| Trim( Upper(x[2]) ) == "TL_QUANTID"})
	nPosUniCmp	 := aScan(aHeadLuComp, {|x| Trim( Upper(x[2]) ) == "TL_UNIDADE"})
	nPosCodCmp	 := aScan(aHeadLuComp, {|x| Trim( Upper(x[2]) ) == "TL_CODIGO" })
	nPosLocCmp	 := aScan(aHeadLuComp, {|x| Trim( Upper(x[2]) ) == "TL_LOCAL"  })
	nPosDesCmp	 := aScan(aHeadLuComp, {|x| Trim( Upper(x[2]) ) == "TL_DESTINO"})
	nPosCusCmp	 := aScan(aHeadLuComp, {|x| Trim( Upper(x[2]) ) == "TL_CUSTO"  })
	nPosMoeCmp	 := aScan(aHeadLuComp, {|x| Trim( Upper(x[2]) ) == "TL_MOEDA"  })

	If lSegCont
		nPOSCONT2 := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TQN_POSCO2"})
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT681OK1()
LinhaOK e TudoOK da oGLubrif

@author Marcos Wagner Junior
@since 15/10/2008
/*/
//---------------------------------------------------------------------
Function MNT681OK1(nPar)
	Local nI

	Local lRetorno := .T.
	Local aValAbast := {}

	dbSelectArea("ST9")
	dbSetOrder(16)
	dbSeek(aCols[n][nPOSFROTA])
	cFilbem := ST9->T9_FILIAL

	For nI := 1 to Len(aHeader)
		If Empty( aCols[n, nPosHoraB] ) .Or. aCols[n, nPosHoraB] == '  :  '
			Help( '', 1, 'OBRIGAT',, aHeader[nPosHoraB, 1], 5)
			Return .f.
		EndIf

		If Empty(aCols[n][nPOSHODOM]) .And. ST9->T9_TEMCONT == "S"
			HELP(" ",1,"OBRIGAT",,aHeader[nPOSHODOM][1],05)
			Return .f.
		EndIf

		If (nI = nPOSHODOM) .Or. nI == nPOSPLACA
			Loop
		EndIf

		If Empty(aCols[n][nI]) .And. nI != nPOSQUANT
			If nI == nPOSHODOM
				If ST9->T9_TEMCONT = "S"
					HELP(" ",1,"OBRIGAT",,aHeader[nI][1],05)
					Return .f.
				EndIf
			EndIf
		EndIf

		If nI == nPOSCONT2
			dbSelectArea("TPE")
			dbSetOrder(1)
			If ( lCont2 := dbSeek(xFilial("TPE", cCodObra) + aCols[n][nPOSFROTA]) .And. TPE->TPE_SITUAC == '1' ) .And. Empty( aCols[ n, nI ] )
				HELP(" ",1,"OBRIGAT",,aHeader[nI][1],05)
				Return .f.
			EndIf
		EndIf

	Next nI

	/*
	MNT659VAL - Função que valida abastecimento de acordo com parâmetro MV_NGABAVL
	Se tiver algum retorno falso a partir da segunda posição, mostra divergencia.
	Retorno MNT659VAL :
	1 - cMensagem (mensagem que será apresentada para usuário - não utilizada para importação)
	2 - Validação de Esquema Padrão (.t. está ok , .f. com erro)
	3 - Validação de Estrutura Padrão (.t. está ok , .f. com erro)
	4 - Validação de Manutenção Padrão (.t. está ok , .f. com erro)
	5 - Validação de Manutenção (.t. está ok , .f. com erro)
	*/

	If FindFunction("MNT659VAL") .And.  nPar == 1
		aValAbast:= MNT659VAL(aCols[n][nPOSFROTA], cFilBem ,dDataAbast,aCols[n][nPOSHORAB])
		If ascan(aValAbast,.f.) > 0
			MsgInfo(aValAbast[1])
			Return .f.
		EndIf
	EndIf

	If nPar == 1 .And. ST9->T9_TEMCONT == "S"
	//validacoes de contador
		lVirada := .F.
		cUM := " "
		cNumSeqD := " "
		cFil := MNTA656FIL(aCols[n][nPOSFROTA],dDataAbast,aCols[n][nPOSHORAB],aCols[n][nPOSPLACA])

		If (!aCols[n][Len(aHeader)+1] .And. Inclui) .Or. (Altera .And. aScan(aOldCols,{|x| x[nPOSHORAB]+x[nPOSFROTA] == aCols[n][nPOSHORAB]+aCols[n][nPOSFROTA] }) == 0)
			If !MNT655HOD()
				Return .F.
			EndIf
			If !lVIRADA  //se houve virada de contador com mesma dt e hr de abast. nao faz reporte de contador
				lRetorno := .T.
				If Altera
					BEGIN TRANSACTION
					// POG -> Deleta o Contador para fazer a validação, mas não iremos gravar essa exclusão

					aRetTPN := NgFilTPN(aCols[n][nPOSFROTA],dDataAbast,aCols[n][nPOSHORAB])
					If !Empty(aRetTPN[1])
						cFilBem := aRetTPN[1]
					EndIf

					nDifCont := 0
					nAcum655 := 0
					nAcu6552 := 0
					aARALTC  := {'STP','STP->TP_FILIAL','STP->TP_CODBEM',;
								 'STP->TP_DTLEITU','STP->TP_HORA','STP->TP_POSCONT',;
								 'STP->TP_ACUMCON','STP->TP_VARDIA','STP->TP_VIRACON'}

					aARABEM := {'ST9','ST9->T9_POSCONT','ST9->T9_CONTACU',;
								'ST9->T9_DTULTAC','ST9->T9_VARDIA'}

					dbSelectArea("STP")
					dbSetOrder(5)
					If dbSeek(xFilial("STP",cFilBem)+aCols[n][nPOSFROTA]+DTOS(dDataAbast)+aCols[n][nPOSHORAB])
						nDifCont := aCols[n][nPOSHODOM] - STP->TP_POSCONT
						nAcum655 := (stp->tp_acumcon - STP->TP_POSCONT) + aCols[n][nPOSHODOM]

						nRECNSTP := Recno()
						lULTIMOP := .T.
						nACUMFIP := 0
						nCONTAFP := 0
						nVARDIFP := 0
						dDTACUFP := StoD('')
						dbSkip(-1)
						If !Eof() .And. !Bof() .And. &(aARALTC[2]) == xFilial(aARALTC[1],cFilBem) .And.;
													 &(aARALTC[3]) == aCols[n][nPOSFROTA]
							nACUMFIP := &(aARALTC[7])
							dDTACUFP := &(aARALTC[4])
							nCONTAFP := &(aARALTC[6])
							nVARDIFP := &(aARALTC[8])
						EndIf
						dbGoTo(nRECNSTP)
						nACUMDEL := stp->tp_acumcon
						RecLock("STP",.f.)
						dbDelete()
						STP->(MsUnlock())
						STP->(dbSkip())
						If Eof() .Or. STP->TP_CODBEM <> aCols[n][nPOSFROTA]
							dbSkip(-1)
							If aCols[n][nPOSFROTA] == STP->TP_CODBEM
								RecLock("ST9",.f.)
								ST9->T9_POSCONT += nDifCont
								ST9->T9_CONTACU += nDifCont
								MsUnLock("ST9")
							EndIf
						EndIf
						MNTA875ADEL(aCols[n][nPOSFROTA],dDataAbast,aCols[n][nPOSHORAB],1,cFilBem,cFilBem)
					EndIf

					If lCont2
						dbSelectArea('TPP')
						dbsetorder(5)
						If dbSeek(xFilial('TPP',cFilBem)+aCols[n][nPOSFROTA]+DtoS(dDataAbast)+aCols[n][nPOSHORAB])
							aARALTC := {'TPP','tpp->tpp_filial','tpp->tpp_codbem',;
											'tpp->tpp_dtleit','tpp->tpp_hora','tpp->tpp_poscon',;
											'tpp->tpp_acumco','tpp->tpp_vardia','tpp->tpp_viraco'}
							aARABEM := {'TPE','tpe->tpe_poscon','tpe->tpe_contac',;
											'tpe->tpe_dtulta','tpe->tpe_vardia'}
							nAcu6552 := (&(aARALTC[7]) - &(aARALTC[6])) + aCols[n][nPOSCONT2]
							nRECNSTP := Recno()
							lULTIMOP := .T.
							nACUMFIP := 0
							nCONTAFP := 0
							nVARDIFP := 0
							dDTACUFP := StoD('')
							dbSkip(-1)
							If !EoF() .And. !BoF() .And. &(aARALTC[2]) == xFilial(aARALTC[1],cFilBem) .And.;
								&(aARALTC[3]) == aCols[n][nPOSFROTA]
								nACUMFIP := &(aARALTC[7])
								dDTACUFP := &(aARALTC[4])
								nCONTAFP := &(aARALTC[6])
								nVARDIFP := &(aARALTC[8])
							EndIf
							dbGoTo(nRECNSTP)
							nACUMDEL := TPP->TPP_ACUMCO
							RecLock('TPP',.F.)
							dbDelete()
							TPE->(MsUnlock())
							MNTA875ADEL(aCols[n][nPOSFROTA],dDataAbast,aCols[n][nPOSHORAB],2,cFilBem,cFilBem)
						EndIf
					EndIf
					END TRANSACTION
				EndIf
				If !NGCHKHISTO(aCols[n][nPOSFROTA],dDataAbast,aCols[n][nPOSHODOM],aCols[n][nPOSHORAB],1,,.t.,cFil,cCodCom)
					lRetorno := .F.
				EndIf
				If lRetorno .And. !NGVALIVARD(aCols[n][nPOSFROTA],aCols[n][nPOSHODOM],dDataAbast,aCols[n][nPOSHORAB],1,.t.,,cFil)
					lRetorno := .F.
				EndIf
				If lCont2 .And. lRetorno
					If !NGCHKHISTO(aCols[n][nPOSFROTA],dDataAbast,aCols[n][nPOSCONT2],aCols[n][nPOSHORAB],2,,.t.,cFil,cCodCom)
						lRetorno := .F.
					EndIf
					If lRetorno .And. !NGVALIVARD(aCols[n][nPOSFROTA],aCols[n][nPOSCONT2],dDataAbast,aCols[n][nPOSHORAB],2,.t.,,cFil)
						lRetorno := .F.
					EndIf
				EndIf
				If Altera
					DisarmTransaction()
				EndIf
				If !lRetorno
					Return .F.
				EndIf
			EndIf
		EndIf
	EndIf

	cMensag := ''

	For nI := 1 to Len(aCols)
		If nI == 1
			cPlacaCols := aCols[n][nPOSFROTA]
			dDataCols  := dDataAbast
			cHoraCols  := aCols[n][nPOSHORAB]
			cDataHora  := DTOS(dDataAbast)+aCols[nI][nPOSHORAB]
		EndIf

		If !aCols[n][Len(aCols[n])]
			If ST9->T9_TEMCONT = "S"
				If cPlacaCols == aCols[nI][nPOSFROTA] .And. nI != n .And. !aCols[nI][Len(aCols[nI])] .And. !aCols[n][Len(aCols[n])]
					If DTOS(dDataAbast)+aCols[nI][nPOSHORAB] >= DTOS(dDataCols)+cHoraCols .And.;
							( aCols[nI][nPOSHODOM] < aCols[n][nPOSHODOM] .Or. aCols[nI][nPOSCONT2] < aCols[n][nPOSCONT2] )
						If cDataHora <= DTOS(dDataAbast)+aCols[nI][nPOSHORAB]
							If !MNT656QV(cPlacaCols,DTOS(dDataAbast),aCols[nI][nPOSHORAB]) //checa se nao houve quebra ou virada
								cMensag:= STR0048+Chr(10)+Chr(10)+; //"Contador informado é inválido!"
								STR0049+Chr(13)+; //"Abastecimento Informado: "
								STR0050+".................: "+DTOC(dDataCols)+Chr(13)+; //"Data"
								STR0027+".................: "+cHoraCols+Chr(13) //"Hora"
								If aCols[nI][nPOSHODOM] < aCols[n][nPOSHODOM]
									cMensag += STR0028+"..........: "+AllTrim(Str(aCols[n][nPOSHODOM]))+Chr(10)+Chr(10)+; //"Contador"
											STR0051+Chr(13)+; //"Abastecimento Posterior: "
											STR0050+".................: "+DTOC(dDataAbast)+Chr(13)+; //"Data"
											STR0027+".................: "+aCols[nI][nPOSHORAB]+Chr(13)+; //"Hora"
											STR0028+"..........: "+AllTrim(Str(aCols[nI][nPOSHODOM]))+Chr(13) //"Contador"
								Else
									cMensag += STR0028+"..........: "+AllTrim(Str(aCols[n][nPOSCONT2]))+Chr(10)+Chr(10)+; //"Contador"
											STR0051+Chr(13)+; //"Abastecimento Posterior: "
											STR0050+".................: "+DTOC(dDataAbast)+Chr(13)+; //"Data"
											STR0027+".................: "+aCols[nI][nPOSHORAB]+Chr(13)+; //"Hora"
											STR0028+"..........: "+AllTrim(Str(aCols[nI][nPOSCONT2]))+Chr(13) //"Contador"
								EndIf

								cDataHora := DTOS(dDataAbast)+aCols[nI][nPOSHORAB]
							EndIf
						EndIf
					ElseIf DTOS(dDataAbast)+aCols[nI][nPOSHORAB] <= DTOS(dDataCols)+cHoraCols .And.;
							( aCols[nI][nPOSHODOM] > aCols[n][nPOSHODOM] .Or. aCols[nI][nPOSCONT2] > aCols[n][nPOSCONT2] )
						If cDataHora <= DTOS(dDataAbast)+aCols[nI][nPOSHORAB]
							If !MNT656QV(cPlacaCols,DTOS(dDataCols),cHoraCols) //checa se nao houve quebra ou virada
								cMensag:= STR0048+Chr(10)+Chr(10)+; //"Contador informado é inválido!"
								STR0052+Chr(13)+; //"Abastecimento Anterior: "
								STR0050+".................: "+DTOC(dDataAbast)+Chr(13)+; //"Data"
								STR0027+".................: "+aCols[nI][nPOSHORAB]+Chr(13) //"Hora"
								If aCols[nI][nPOSHODOM] > aCols[n][nPOSHODOM]
									cMensag += STR0028+"..........: "+AllTrim(Str(aCols[nI][nPOSHODOM]))+Chr(10)+Chr(10)+; //"Contador"
											STR0049+Chr(13)+; //"Abastecimento Informado: "
											STR0050+".................: "+DTOC(dDataCols)+Chr(13)+; //"Data"
											STR0027+".................: "+cHoraCols+Chr(13)+; //"Hora"
											STR0028+"..........: "+AllTrim(Str(aCols[n][nPOSHODOM]))+Chr(13) //"Contador"
								Else
									cMensag += STR0028+"..........: "+AllTrim(Str(aCols[nI][nPOSCONT2]))+Chr(10)+Chr(10)+; //"Contador"
											STR0049+Chr(13)+; //"Abastecimento Informado: "
											STR0050+".................: "+DTOC(dDataCols)+Chr(13)+; //"Data"
											STR0027+".................: "+cHoraCols+Chr(13)+; //"Hora"
											STR0028+"..........: "+AllTrim(Str(aCols[n][nPOSCONT2]))+Chr(13) //"Contador"
								EndIf

								cDataHora := DTOS(dDataAbast)+aCols[nI][nPOSHORAB]
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	Next
	If !Empty(cMensag)
		MsgInfo(cMensag,STR0053) //"NAO CONFORMIDADE"
		Return .f.
	Else //Se o pai nao teve nenhum problema, verifica agora se os componentes estao validos, retornando falso no caso de alguma nao conformidade
//Caso esteja sendo chamada pela validacao do cadastro -> funcao 'TUDOOK', valida todo o aCols da GetDados, sem precisar validar a linha
		If IsInCallStack("TUDOOK")
			If nPar == 2 .And. !fVldCompon(,,,,.T.)[1]
				Return .F.
			EndIf
		Else //Se nao for o TUDOOK do cadastro, valida a linha (ou todo o aCols, dependendo da parametrizacao desta funcao)
			If !fVldCompon(,,,,(nPar == 2))[1]
				Return .F.
			EndIf
		EndIf
	EndIf
	If nPar == 1
		cCodCom := NGSEEK('TQI',cPosto+cLoja+cTanque,1,'TQI->TQI_CODCOM')
		If !MNTA656AUT( aCols[n, nPosFrota], dDataAbast, aCols[n, nPosHoraB], aCols[n, nPosHodom], .T., cCodCom, oGLubrif)
			Return .f.
		EndIf
	EndIf

	GravaAcols()

	TIPOACOM := .f. //Para a Getdados dos lubrificantes abaixo, nao ficar fechada
	PutFileInEof( 'TQN' )

Return .t.
//---------------------------------------------------------------------
/*/{Protheus.doc} ChangeGet1()
Foco na linha da GetDados

@author Marcos Wagner Junior
@since 15/10/2008
/*/
//---------------------------------------------------------------------
Static Function ChangeGet1(lBloqCols)

	Local _cFrota := oGLubrif:aCols[oGLubrif:nAt][nPOSFROTA]
	Local _cHora  := oGLubrif:aCols[oGLubrif:nAt][nPOSHORAB]
	Local nX
	Local cReadVar := ReadVar()

	//Verifica se o Registro é apenas uma lubrificação (se for, não permite alterar)
	If aScan(aApenasLub, {|x| x[1] + x[2] == oGLubrif:aCols[oGLubrif:nAt][nPOSFROTA] + oGLubrif:aCols[oGLubrif:nAt][nPOSHORAB]	}) > 0
		For nX := 1 To Len(oGLubrif:aInfo)
			oGLubrif:aInfo[nX][4] := ".F."
		Next nX
	Else
		oGLubrif:aInfo := aClone( aOldInfo01 )
	EndIf

	//Primeira vez?
	If lFirstTime
		lFirstTime := .f.
		Return .t.
	EndIf

	If Inclui .Or. Altera
		If cReadVar == "M->TQN_FROTA"
			_cFrota := M->TQN_FROTA
		ElseIf cReadVar == "M->TQN_HRABAS"
			_cHora := M->TQN_HRABAS
		EndIf
	EndIf

	If Altera .And. lBloqCols
		If aScan(aOldCols,{|x| x[nPOSFROTA]+x[nPOSHORAB] == _cFrota+_cHora }) > 0
			oGLubrif:aInfo[nPOSFROTA][4] := '.F.'
			oGLubrif:aInfo[nPOSHORAB][4] := '.F.'
		Else
			oGLubrif:aInfo[nPOSFROTA][4] := '.T.'
			oGLubrif:aInfo[nPOSHORAB][4] := '.T.'
		EndIf
	EndIf

	dbSelectArea("ST9")
	dbSetOrder(16)
	TipoAcom := IIf( dbSeek(_cFrota), ST9->T9_TEMCONT == 'S', .F.)

	//FindFunction remover na release GetRPORelease() >= '12.1.027'
	If FindFunction("MNTCont2")
		TIPOACOM2 := MNTCont2(xFilial("TPE"), _cFrota )
	Else
		dbSelectArea("TPE")
		dbSetOrder(1)
		TIPOACOM2 := ( dbSeek(xFilial("TPE")+_cFrota) .And. TPE->TPE_SITUAC == "1" )
	EndIf

	If Len(oGLubrif:aCols) > 0 .And. !Empty(_cFrota)

		//Lubrificação do Pai
		oGProdPrc:aCols := {}

		dbSelectArea(cAliasLub)
		dbSetOrder(02)
		If dbSeek(_cFrota+_cHora)
			While !Eof() .And. (cAliasLub)->CODBEM == _cFrota .And. (cAliasLub)->HORABA == _cHora

				aAdd(oGProdPrc:aCols,{(cAliasLub)->PRODUT,(cAliasLub)->QUANTI,(cAliasLub)->UNIDAD,(cAliasLub)->ALMOXA,(cAliasLub)->DESTIN,(cAliasLub)->CUSTO})
				If lMMoeda
					aAdd(oGProdPrc:aCols[Len(oGProdPrc:aCols)], (cAliasLub)->MOEDA)
				EndIf
				aAdd(oGProdPrc:aCols[Len(oGProdPrc:aCols)],.F.)

				dbSkip()
			EndDo
		EndIf

		If Len(oGProdPrc:aCols) == 0
			oGProdPrc:aCols := BLANKGETD(oGProdPrc:aHeader)
		EndIf

		oGProdPrc:Refresh()

		// Indicação
		oGItensCmp:aCols[oGItensCmp:nAt][nPosIndic] := "2"
		//oGItensCmp:aCols[oGItensCmp:nAt][nPosItens] := 0
		oGItensCmp:aCols[oGItensCmp:nAt][nPosTotal] := 0

		dbSelectArea(cAliasCmp)
		dbSetOrder(01)
		If dbSeek(_cFrota + _cHora)
			oGItensCmp:aCols[oGItensCmp:nAt][nPosIndic] := (cAliasCmp)->INDICA
			//oGItensCmp:aCols[oGItensCmp:nAt][nPosItens] := (cAliasCmp)->TOTITE
			oGItensCmp:aCols[oGItensCmp:nAt][nPosTotal] := (cAliasCmp)->QTDTOT
		EndIf

		oGItensCmp:Refresh()

		LoadComp(2,.t.)

	EndIf

	// Atualiza
	nLinGet01 := oGLubrif:nAt
	oGLubrif:Refresh()

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} ChangeGet2()
Foco na linha da GetDados

@author Marcos Wagner Junior
@since 15/10/2008
/*/
//---------------------------------------------------------------------
Static Function ChangeGet2()

	Local _cFrota := oGLubrif:aCols[oGLubrif:nAt][nPOSFROTA]
	Local _cProduto := IIF(Len(oGProdPrc:aCols)>0,oGProdPrc:aCols[oGProdPrc:nAt][nPosCodPrc],Space(Len(SB1->B1_COD)))

	If !Inclui .And. aScan(aOldCols02,{|x| x[1]+x[2] == _cFrota+_cProduto }) > 0
		oGProdPrc:oBrowse:aAlter := {}
	Else
		oGProdPrc:oBrowse:aAlter := aAlterGCmp
	EndIf

Return .t.
//---------------------------------------------------------------------
/*/{Protheus.doc} ChangeGet4()
Foco na linha da GetDados

@author Marcos Wagner Junior
@since 15/10/2008
/*/
//---------------------------------------------------------------------
Static Function ChangeGet4()
	Local _cPai := oGLubrif:aCols[oGLubrif:nAt][nPOSFROTA]
	Local _cFilho := IIF(Len(oGProdCmp:aCols)>0,oGProdCmp:aCols[oGProdCmp:nAt][nPosBemCmp],Space(Len(ST9->T9_CODBEM)))
	Local _cHoraPai := oGLubrif:aCols[oGLubrif:nAt][nPOSHORAB]

	dbSelectArea("ST9")
	dbSetOrder(16)
	TipoAcom := IIf( dbSeek(_cFilho), ST9->T9_TEMCONT == 'S', .F. )

	//FindFunction remover na release GetRPORelease() >= '12.1.027'
	If FindFunction("MNTCont2")
		TipoAcom2 := MNTCont2(xFilial("TPE",cFilBem), _cPai )
	Else
		dbSelectArea("TPE")
		dbSetOrder(1)
		TipoAcom2 := ( dbSeek(xFilial("TPE",cFilBem) + _cPai ) .And. TPE->TPE_SITUAC == "1" )
	EndIf

	If !Inclui .And. aScan(aOldCols04,{|x| x[1]+x[2]+x[4] == _cPai+_cFilho+_cHoraPai }) > 0
		oGProdCmp:oBrowse:aAlter := {}
	Else
		oGProdCmp:oBrowse:aAlter := aAlterGDet
	EndIf

Return .t.
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT681OK2()
LinhaOK e TudoOK

@author Marcos Wagner Junior
@since 15/10/2008
/*/
//---------------------------------------------------------------------
Function MNT681OK2(nPar)

	If Inclui
		ChangeGet1(.f.)
	EndIf

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT681OK3()
 LinhaOK das getDados 2 e 4

@param 	_nGet 2 - getDados2(lub. Bem Pai )
		_nGet 4 - getDados4(lub. componentes )

@author Marcos Wagner Junior
@since 14/03/2011
/*/
//---------------------------------------------------------------------
Function MNT681OK3(_nGet, lTOk )

	Local nQtdProd, nSomaQtd, nQtdComp, nSomaComb
	Local nAt, nI

	Default lTOk := .F.

	Store 0 To nQtdProd, nSomaQtd, nQtdComp

	If _nGet == 2

		nAt := oGProdPrc:nAt

		For nI := 1 To Len( oGProdPrc:aCols )

			If nI == nAt .Or. lTOk

				//Se a linha não estiver deletada
				If !ATail( oGProdPrc:aCols[nI] )
					//verifica se possui alguma coluna em branco
					If ( !Empty( oGProdPrc:aCols[nI][nPosCodPrc] ) .Or. !Empty( oGProdPrc:aCols[nI][nPosQtdPrc] ) .Or.;
						!Empty( oGProdPrc:aCols[nI][nPosDesPrc] ) .Or. !Empty( oGProdPrc:aCols[nI][nPosLocPrc] ) ) .And.;
						( Empty( oGProdPrc:aCols[nI][nPosCodPrc] ) .Or. Empty( oGProdPrc:aCols[nI][nPosQtdPrc] ) .Or.;
						Empty( oGProdPrc:aCols[nI][nPosDesPrc] ) .Or. Empty( oGProdPrc:aCols[nI][nPosLocPrc] ) )
						MsgStop( STR0066, STR0007 ) //"Deverão ser preenchidos todos os campos referentes à 'Lubrificação equipamento principal'!"
						Return .F.
					EndIf

					If oGProdPrc:aCols[nI][nPosDesPrc] == '1' .And. Empty(cTroca)
						MsgStop( STR0067, STR0007 ) //"Para Troca de lubrificante, deverá ser informado o seu respectivo serviço."
						Return .F.
					ElseIf oGProdPrc:aCols[nI][nPosDesPrc] == '2' .And. Empty(cReposicao)
						MsgStop( STR0068, STR0007 ) //"Para Reposição de lubrificante, deverá ser informado o seu respectivo serviço."
						Return .F.
					EndIf

					If cUsaInt3 == 'N' .And. !Empty(oGProdPrc:aCols[nI][nPosQtdPrc]) .And. oGProdPrc:aCols[nI][nPosCusPrc] == 0
						MsgStop( STR0054, STR0007 ) //"'Custo' deverá ser informado!"
						Return .F.
					EndIf

					If cUsaInt3 == 'S'
						If !Empty( oGProdPrc:aCols[nI][nPosCodPrc] ) .And. oGProdPrc:aCols[nI][nPosQtdPrc] > 0
							If !lESTNEGA
								If !NGSALSB2( oGProdPrc:aCols[nI][nPosCodPrc], oGProdPrc:aCols[nI][nPosLocPrc],;
												oGProdPrc:aCols[nI][nPosQtdPrc],,, dDataAbast, .T. )
									Return .F.
								EndIf
							EndIf
						EndIf
					Else //Não integrado ao estoque
						If oGProdPrc:aCols[nI][nPosQtdPrc] != 0 .And. oGProdPrc:aCols[oGProdPrc:nAt][nPosCusPrc] == 0
							MsgStop( STR0054, STR0007 ) //"'Custo' deverá ser informado!"###"ATENÇÃO"
							Return .F.
						EndIf
					EndIf
				EndIf
			EndIf
		Next nI

	ElseIf _nGet == 4

		nAt := oGProdCmp:nAt

		For nI := 1 To Len( oGProdCmp:aCols )

			If nI == nAt .Or. lTOk

				lShowMsg := .F.

				If !ATail( oGProdCmp:aCols[nI] )//Se a linha não estiver deletada

					dbSelectArea( "ST9" )
					dbSetOrder( 16 )
					If dbSeek( oGProdCmp:aCols[nI][nPosBemCmp] )
						If ST9->T9_TEMCONT == 'S' .And. ( oGProdCmp:aCols[nI][nPosHodCmp] == 0 )
							lShowMsg := .T.
						EndIf
					EndIf
					//Se alguma coluna foi informada e tem alguma coluna em branco.
					If ( !Empty( oGProdCmp:aCols[nI][nPosQtdCmp] ) .Or. !Empty( oGProdCmp:aCols[nI][nPosCodCmp] ) .Or.;
						!Empty( oGProdCmp:aCols[nI][nPosDesCmp] ) .Or. !Empty( oGProdCmp:aCols[nI][nPosLocCmp] ) ) .And.;
						( ( Empty( oGProdCmp:aCols[nI][nPosQtdCmp] ) .Or. Empty( oGProdCmp:aCols[nI][nPosCodCmp] ) .Or.;
							Empty( oGProdCmp:aCols[nI][nPosDesCmp] ) .Or. Empty(oGProdCmp:aCols[nI][nPosLocCmp] )) .Or.;
							lShowMsg )// Ou tem contador e este está zerado.
						MsgStop( STR0070, STR0007 ) //"Deverão ser preenchidos todos os campos referentes à 'Lubrificação - Detalhes dos componentes do equipamento'!"
						Return .T.
					EndIf

					If oGProdCmp:aCols[nI][nPosDesCmp] == '1' .And. Empty( cTroca )
						MsgStop( STR0067, STR0007 ) //"Para Troca de lubrificante, deverá ser informado o seu respectivo serviço."
						Return .f.
					ElseIf oGProdCmp:aCols[nI][nPosDesCmp] == '2' .And. Empty( cReposicao )
						MsgStop( STR0068, STR0007 ) //"Para Reposição de lubrificante, deverá ser informado o seu respectivo serviço."
						Return .f.
					EndIf

					nSomaQtd += oGProdCmp:aCols[nI][nPosQtdCmp]

					If !Empty( oGProdCmp:aCols[nI][nPosQtdCmp] ) .And. !Empty( oGProdCmp:aCols[nI][nPosCodCmp] ) .And.;
							!Empty( oGProdCmp:aCols[nI][nPosDesCmp] ) .And. !Empty( oGProdCmp:aCols[nI][nPosLocCmp] ) .And.;
							!lShowMsg
						nQtdComp += 1
					EndIf
				EndIf

				If cUsaInt3 == 'S' //Integrado ao estoque
					If !Empty( oGProdCmp:aCols[nI][nPosCodCmp] ) .And. oGProdCmp:aCols[nI][nPosQtdCmp] > 0
						If !lESTNEGA
							If aScan( oGProdPrc:aCols, { |x| x[1] == oGProdCmp:aCols[nI][nPosCodCmp] }  ) > 0
								nQtdProd := oGProdPrc:aCols[nI][nPosQtdPrc] + oGProdCmp:aCols[nI][nPosQtdCmp]
							EndIf
							If !NGSALSB2( oGProdCmp:aCols[nI][nPosCodCmp], oGProdCmp:aCols[nI][nPosLocCmp],;
											nQtdProd,,, dDataAbast, .T. )
								Return .F.
							EndIf
						EndIf
					EndIf
				Else //Não integrado ao estoque
					If oGProdCmp:aCols[nAt][nPosQtdCmp] != 0 .And. oGProdCmp:aCols[oGProdCmp:nAt][nPosCusCmp] == 0
						MsgStop( STR0054, STR0007 ) //"'Custo' deverá ser informado!"###"ATENÇÃO"
						Return .F.
					EndIf
				EndIf
			EndIf
		Next nI

		If oGItensCmp:aCols[1][nPosTotal] <> nSomaQtd .And. lTOk
			MsgStop( STR0072, STR0007 ) //"A soma da 'Qtde Aplicada' para os componentes diverge da 'Qtde Total' !"
			Return .F.
		EndIf
	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} LoadComp()
 Carrega os filhos do bem pai

@author Marcos Wagner Junior
@since 15/10/08
/*/
//---------------------------------------------------------------------
Function LoadComp(nPar,lMemoria)
	Local aOldArea := GetArea()
	Local cFlag
	Local lJaGravou4 := .f.
	Local _cFrota
	Local lMMoeda := NGCADICBASE("TL_MOEDA","A","STL",.F.) // Multi-Moeda

	Default lMemoria := .f.

	If nPar == 1
		If M->INDICA <> oGItensCmp:aCols[oGItensCmp:nAt][nPosIndic]
			oGProdCmp:aCols := BLANKGETD(oGProdCmp:aHeader)
			oGProdCmp:Refresh()
		EndIf
		cFlag := M->INDICA
	Else
		cFlag := oGItensCmp:aCols[oGItensCmp:nAt][nPosIndic]
	EndIf

	If ReadVar() == "M->TQN_FROTA"
		_cFrota := M->TQN_FROTA
		_cHoraPai := oGLubrif:aCols[oGLubrif:nAt][nPOSHORAB]
	ElseIf ReadVar() == "M->TQN_HRABAS"
		_cFrota := oGLubrif:aCols[oGLubrif:nAt][nPOSFROTA]
		_cHoraPai := M->TQN_HRABAS
	Else
		_cFrota := oGLubrif:aCols[oGLubrif:nAt][nPOSFROTA]
		_cHoraPai := oGLubrif:aCols[oGLubrif:nAt][nPOSHORAB]
	EndIf

	If cFlag == '1' .And. !ATail(oGItensCmp:aCols[oGItensCmp:nAt]) .And. Empty(oGProdCmp:aCols[oGProdCmp:nAt][nPosBemCmp])

		oGProdCmp:aCols := {}
		dbSelectArea(cAliasDet)
		dbSetOrder(02)
		If dbSeek(_cFrota+_cHoraPai)
			While !Eof() .And. (cAliasDet)->CODBEM == _cFrota .And. (cAliasDet)->HORPAI == _cHoraPai
				aAdd(oGProdCmp:aCols,{(cAliasDet)->COMPON,(cAliasDet)->DESCOM,(cAliasDet)->HODOM,(cAliasDet)->PRODUT,;
					(cAliasDet)->QUANTI,(cAliasDet)->UNIDAD,(cAliasDet)->ALMOXA,(cAliasDet)->DESTIN,(cAliasDet)->CUSTO})
				If lMMoeda
					aAdd(oGProdCmp:aCols[Len(oGProdCmp:aCols)],(cAliasDet)->MOEDA)
				EndIf
				aAdd(oGProdCmp:aCols[Len(oGProdCmp:aCols)],.f.)
				dbSkip()
			End
			lJaGravou4 := .t.
		EndIf
		If Len(oGProdCmp:aCols) == 0
			oGProdCmp:aCols := BLANKGETD(oGProdCmp:aHeader)
		EndIf

		If !lJaGravou4
			LoadEstru(.f.,_cFrota)
		EndIf

		If (Len(oGProdCmp:aCols) == 0) .Or. (Len(oGProdCmp:aCols) > 0 .And. Empty(oGProdCmp:aCols[1][1]))
			oGProdCmp:aCols := BLANKGETD(oGProdCmp:aHeader)
		EndIf

		oGProdCmp:GoTop()
	EndIf

	If (Len(oGProdCmp:aCols) == 0) .Or. (Len(oGProdCmp:aCols) > 0 .And. Empty(oGProdCmp:aCols[1][1]))
		oGProdCmp:aCols := BLANKGETD(oGProdCmp:aHeader)
	EndIf

	oGProdCmp:Refresh()

	RestArea(aOldArea)

Return .t.
//---------------------------------------------------------------------
/*/{Protheus.doc} TUDOOK()
Validacoes finais da enchoice e das Getdados

@author Marcos Wagner Junior
@since 15/10/2008
/*/
//---------------------------------------------------------------------
Static Function TUDOOK()

	Local nI, nSomaQtd, nQtdComp, nSomaComb, nDif

	Local aLubQ		:= {}
	Local lTemAbast	:= .F.

	Store 0 To nSomaQtd, nQtdComp, nSomaComb, nDif

	If Empty(cCodObra)
		MsgStop(STR0055,STR0007) //"'Filial' deverá ser informada!"###"ATENÇÃO"
		Return .f.
	EndIf

	If Empty(cPosto)
		MsgStop(STR0056,STR0007) //"'Comboio' deverá ser informado!"###"ATENÇÃO"
		Return .f.
	EndIf

	If Empty(cFolha)
		MsgStop(STR0057,STR0007) //"'Folha' deverá ser informada!"###"ATENÇÃO"
		Return .f.
	EndIf

	If Empty(dDataAbast)
		MsgStop(STR0058,STR0007) //"'Data' deverá ser informada!"###"ATENÇÃO"
		Return .f.
	EndIf

	If Empty(cHrAb656)
		MsgStop(STR0059,STR0007) //"'Hora' deverá ser informada!"###"ATENÇÃO"
		Return .f.
	EndIf

	If nCombAtu == 0
		MsgStop(STR0060,STR0007) //"'Fim' deverá ser informado!"###"ATENÇÃO"
		Return .f.
	EndIf

	If Empty(cLoja) .Or. Empty(cTanque) .Or. Empty(cBomba)
		MsgStop(STR0061,STR0007) //"Loja, Tanque e Bomba deverão ser informados!"###"ATENÇÃO"
		Return .f.
	EndIf

	If !oGLubrif:LinhaOk() .Or. !oGLubrif:TudoOk()
		Return .F.
	EndIf

	If !oGProdPrc:LinhaOk() .Or. !oGProdPrc:TudoOk()
		Return .F.
	EndIf

	//GetDados 1
	For nI := 1 to Len(oGLubrif:aCols)
		If !ATail( oGLubrif:aCols[nI] )

			If (Empty(oGLubrif:aCols[nI][nPOSFROTA]) .Or. Empty(oGLubrif:aCols[nI][nPOSHORAB]) .Or. AllTrim(oGLubrif:aCols[nI][nPOSHORAB]) == ':') .Or.;
					(NGSEEK("ST9",oGLubrif:aCols[nI][nPOSFROTA],1,"T9_TEMCONT")=='S' .And. Empty(oGLubrif:aCols[nI][nPOSHODOM]))

				MsgStop(STR0062,"ATENÇÃO") //"Deverão ser preenchidos todos os campos referentes à 'Abastecimento'"
				Return .f.

			Else
				If !Empty(oGLubrif:aCols[nI][nPOSQUANT])
					lTemAbast := .t.
					nSomaComb += oGLubrif:aCols[nI][nPOSQUANT]
				EndIf
			EndIf
		EndIf
	Next

	If !lTemAbast .And. nCombTot != 0
		MsgStop( 'A soma das quantidades informadas nos registros de abastecimento deve totalizar a mesma quantidade ' +;
					'contida  no campo "Dif."' + CRLF + CRLF +;
					'Quantidade prevista (Dif.): ' + cValToChar(nCombTot) + CRLF +;
					'Quantidade informada: ' + cValToChar(nSomaComb), "ATENÇÃO" )

		//MsgStop(STR0063,"ATENÇÃO") //"Deverá ser digitado pelo menos um 'Abastecimento'!"
		Return .f.
	Else
		If nCombTot <> nSomaComb
			nDif := nSomaComb - nCombTot
			MsgStop(STR0064+CRLF+CRLF+;
				STR0108+cValToChar(nCombTot)+CRLF+;
				STR0109+cValToChar(nSomaComb)+CRLF+;
				STR0110+cValToChar(nDif),"ATENÇÃO") //"A soma da 'Qtde Diesel' diverge da 'Dif.' !"
			Return .f.
		EndIf
	EndIf

	If !lTemAbast
		lNaoLubri := .t.

		For nI := 1 to Len(oGProdPrc:aCols)
			If !oGProdPrc:aCols[nI][Len(oGProdPrc:aCols[nI])]
				If (!Empty(oGProdPrc:aCols[nI][nPosCodPrc]) .And. !Empty(oGProdPrc:aCols[nI][nPosQtdPrc]) .And.; //Todas colunas da GET2 estao preenchidas?
					!Empty(oGProdPrc:aCols[nI][nPosDesPrc]) .And. !Empty(oGProdPrc:aCols[nI][nPosLocPrc]))
					lNaoLubri := .f.
					Exit
				EndIf
			EndIf
		Next

		dbSelectArea(cAliasLub)
		dbGoTop()
		While !Eof() .And. lNaoLubri
			If (!Empty((cAliasLub)->PRODUT) .And. !Empty((cAliasLub)->QUANTI) .And.; //Todas colunas da GET2 estao preenchidas?
				!Empty((cAliasLub)->DESTIN) .And. !Empty((cAliasLub)->ALMOXA))
				lNaoLubri := .f.
			EndIf
			dbSkip()
		End

		If lNaoLubri
			MsgStop(STR0065,"ATENÇÃO") //"Deverá ser informado pelo menos um Abastecimento ou uma Lubrificação!"
			Return .f.
		EndIf
	EndIf

	MNT681OK3( 3, .T. )

	//GetDados 3
	If !ATail(oGItensCmp:aCols[1]) .And. oGItensCmp:aCols[1,nPosIndic] == '1' .And. Empty(oGItensCmp:aCols[1, nPosTotal])
			//( Empty(oGItensCmp:aCols[1, nPosItens]) .Or. Empty(oGItensCmp:aCols[1, nPosTotal]))

		MsgStop(STR0069,"ATENÇÃO") //"Deverão ser preenchidos todos os campos referentes à 'Lubrificação componentes'!"
		Return .f.
	EndIf

	//GetDados 4
	If !MNT681OK3( 4, .T. )
		Return .F.
	EndIf

	// Verifica saldo de lubrificantes -
	If cUsaInt3 == 'S'
		//verifica produtos da getDados2
		dbSelectArea(cAliasLub)
		dbGoTop()
		While !Eof()

			nLub := aScan(aLubQ,{|x| x[1]+x[2] == (cAliasLub)->PRODUT + (cAliasLub)->ALMOXA})
			If nLub == 0
				aAdd(aLubQ, {(cAliasLub)->PRODUT , (cAliasLub)->ALMOXA, (cAliasLub)->QUANTI} )
			Else
				aLubQ[nLub][3] += (cAliasLub)->QUANTI
			EndIf

			dbSelectArea(cAliasLub)
			dbSkip()
		EndDo

		//verifica produtos da getDados4
		dbSelectArea(cAliasDet)
		dbGoTop()
		While !Eof()
			nLub := aScan(aLubQ,{|x| x[1]+x[2] == (cAliasDet)->PRODUT + (cAliasDet)->ALMOXA})

			If nLub == 0
				aAdd(aLubQ, { (cAliasDet)->PRODUT, (cAliasDet)->ALMOXA, (cAliasDet)->QUANTI } )
			Else
				aLubQ[nLub][3] += (cAliasDet)->QUANTI
			EndIf

			dbSelectArea(cAliasDet)
			dbSkip()
		EndDo

		//verifica saldo
		For nI := 1 to Len(aLubQ)

			If !Empty(aLubQ[1])
				If !lESTNEGA
					If !NGSALSB2(aLubQ[nI][1],aLubQ[nI][2],aLubQ[nI][3],,,dDataAbast)
						Return .F.
					EndIf
				EndIf
			EndIf
		Next
	EndIf

	GravaaCols()

	//Validação Saldo Get01
	If !MNT656CTOT()
		Return .f.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT681GRAV()
ravacao dos abastecimentos e insumos (Identico MNTA656)

@author Marcos Wagner Junior
@since 21/05/2010
/*/
//---------------------------------------------------------------------
Static Function MNT681GRAV(_lGrava)

	Local lMMoeda 	  := NGCADICBASE("TL_MOEDA","A","STL",.F.) // Multi-Moeda
	Local lMNT655D3CC := ExistBlock("MNT655D3CC")
	Local lMNTA6810   := ExistBlock( 'MNTA6810' )
	Local nI, cResp

	Local aAreaOld 	:= {}

	Private cMotorista, cMoedaOpr := "1"

	If _lGrava .And. (Inclui .Or. Altera)

		dbSelectArea("TVJ")
		dbSetOrder(1)
		If dbSeek(xFilial("TVJ") + cFolha) .And. TVJ->TVJ_STATUS = '1'

			TVJ->( RecLock("TVJ",.F.) )
			TVJ->TVJ_STATUS := '2'
			TVJ->( MsUnLock() )

		EndIf

		dbSelectArea("TV4")
		dbSetOrder(01)
		If !dbSeek(xFilial("TV4") + cPosto + cLoja)

			RecLock("TV4",.T.)

			TV4->TV4_FILIAL := xFilial("TV4")
			TV4->TV4_COMBOI := cPosto
		Else
			RecLock("TV4",.F.)
		EndIf

		TV4->TV4_LOJA   := cLoja
		TV4->TV4_BOMBA  := cBomba
		TV4->TV4_TANQUE := cTanque

		TV4->( MsUnlock() )

		If lGravaTQJ
			dbSelectArea("TQJ")
			dbSetOrder(01)
			If dbSeek(xFilial("TQJ") + cPosto + cLoja + cTanque + cBomba)

				TQJ->( RecLock("TQJ",.F.) )
				TQJ->TQJ_MOTIVO := '1'
				TQJ->( MsUnlock() )

			EndIf
		EndIf

		If !Empty(cMotGer)
			dbSelectArea("DA4")
			dbSetOrder(03)
			If dbSeek(xFilial("DA4") + cMotGer)
				cMotorista := DA4->DA4_COD
			EndIf
		EndIf

		dbSelectArea("TTA")
		dbSetOrder(1)
		If !dbSeek(xFilial("TTA",cCodObra) + cPosto + cLoja + cFolha)

			RecLock("TTA",.T.)

			TTA->TTA_FILIAL := xFilial("TTA",cCodObra)
			TTA->TTA_FOLHA  := cFolha
			TTA->TTA_POSTO  := cPosto
			TTA->TTA_LOJA   := cLoja
			TTA->TTA_TANQUE := cTanque
			TTA->TTA_BOMBA  := cBomba
			TTA->TTA_DTABAS := dDataAbast
			TTA->TTA_HRABAS := cHrAb656
			TTA->TTA_TOTCOM := nCombTot
			TTA->TTA_SERTRO := cTroca
			TTA->TTA_SERREP := cReposicao
			TTA->TTA_RESPON := cMotorista

		Else
			RecLock("TTA",.F.)
		EndIf

		TTA->TTA_ORIGEM := FunName()
		TTA->TTA_CONBOM := nCombAtu
		TTA->TTA_TOTCOM := nCombTot
		TTA->TTA_SERTRO := cTroca
		TTA->TTA_SERREP := cReposicao

		TTA->(MsUnlock())

		nRecTTA := Recno()

		For nI := 1 to Len( aCols := aClone(oGLubrif:aCols) )

			If Inclui .Or. (Altera .And. aScan(aOldCols,{|x| x[nPOSHORAB]+x[nPOSFROTA] == aCols[nI][nPOSHORAB]+aCols[nI][nPOSFROTA] }) == 0)
				
				If !aCols[nI][Len(aHeader)+1]

					cFil := xFilial("TQN", cCodObra)

					//Validações de contador
					lVirada  := .F.
					n		  := nI
					cUM		  := " "
					cNumSeqD := " "

					If !Empty(aCols[nI][nPOSQUANT])

						dbSelectArea("ST9")
						dbSetOrder(16)
						dbSeek(aCols[nI,nPOSFROTA])

						//Chamada da função para debitar estoque
						If cConEst == "S"

							cUM := NGSEEK('TQM', cCodCom, 1, 'TQM->TQM_UM')
							dbSelectArea("TQI")
							dbSetOrder(1)
							If dbSeek(xFilial("TQI") + cPosto + cLoja + cTanque)
								cComb := TQI->TQI_PRODUT
							EndIf

							//Verifica se o MV_DOCSEQ está certo antes de entrar em execução automática, para mostrar mensagem de erro e finalizar
							If Empty( ProxNum() )
								Return .F.
							EndIf

							cDocumSD3 := NextNumero("SD3", 2, "D3_DOC", .T.)
							cNumSeqD  := MntMovEst('RE0', cTANQUE, cComb,aCols[nI][nPOSQUANT], dDataAbast, cDocumSD3,ST9->T9_FILIAL,ST9->T9_CCUSTO,,TQN->TQN_NUMSEQ)

							//P.E. para alteções finais no SD3
							If lMNT655D3CC
								ExecBlock("MNT655D3CC", .F. , .F. , {'RE0', ST9->T9_CODBEM, ST9->T9_CCUSTO, ST9->T9_FILIAL })
							EndIf
						EndIf

						cAbast := GetSXENum('TQN','TQN_NABAST')

						dbSelectArea("TQN")
						dbSetOrder(1)
						If !dbSeek(xFilial("TQN",cFil)+aCols[nI][nPOSFROTA]+DtoS(dDataAbast)+aCols[nI][nPOSHORAB])

							RecLock("TQN", .T.)

							TQN->TQN_FILIAL := IIf( NGSX2MODO("TQN")=="C", xFilial("TQN"), cFil )
							TQN->TQN_PLACA  := ST9->T9_PLACA
							TQN->TQN_FROTA  := aCols[nI][nPOSFROTA]
							TQN->TQN_CNPJ   := NGSEEK('TQF',cPosto+cLoja,1,'TQF->TQF_CNPJ')
							TQN->TQN_POSTO  := cPosto
							TQN->TQN_LOJA   := cLoja
							TQN->TQN_NOTFIS := cFolha
							TQN->TQN_DTABAS := dDataAbast
							TQN->TQN_HRABAS := aCols[nI][nPOSHORAB]
							TQN->TQN_QUANT  := aCols[nI][nPOSQUANT]
							TQN->TQN_CODCOM := cTTAComb
							TQN->TQN_VALUNI := MNT656VALU(dDataAbast,aCols[nI][nPOSHORAB],TQN->TQN_CODCOM)

							// Grava valor unitário de acordo com a moeda em questão
							If lMMoeda
								TQN->TQN_MOEDA := '1'
							EndIf

							TQN->TQN_VALTOT := aCols[nI][nPOSQUANT] * TQN->TQN_VALUNI
							TQN->TQN_HODOM  := aCols[nI][nPOSHODOM]
							TQN->TQN_POSCO2 := aCols[nI][nPOSCONT2]
							TQN->TQN_CODVIA := " "
							TQN->TQN_ESCALA := " "
							TQN->TQN_TANQUE := cTanque
							TQN->TQN_BOMBA  := cBomba
							TQN->TQN_NABAST := cAbast
							//Se o código do motorista estiver em branco utiliza o MOTGEN, caso contrário
							//	utiliza o motorista informado no abastecimento.
							TQN->TQN_CODMOT := If(Empty(aCols[nI][nPosMotor]),cMotorista, aCols[nI][nPosMotor])
							TQN->TQN_USUARI := If(Len(TQN->TQN_USUARI) > 15,cUsername,Substr(cUsuario,7,15))
							TQN->TQN_AUTO   := "2"
							TQN->TQN_NUMSEQ := cNumSeqD
							TQN->TQN_DTEMIS := dDataAbast
							TQN->TQN_DTPGMT := MNT635DTPG(cPosto,cLoja,dDataAbast,aCols[nI][nPOSHORAB])
							TQN->TQN_CCUSTO := ST9->T9_CCUSTO
							TQN->TQN_CENTRA := ST9->T9_CENTRAB
							TQN->TQN_ORDENA := INVERTE(dDataAbast)
							TQN->TQN_NUMSGC := MN655NUMSGC()
							TQN->TQN_DTDIGI := dDatabase

							TQN->(MsUnlock())

							If lMNTA6810

								ExecBlock( 'MNTA6810', .F. , .F. , { TQN->TQN_FROTA, TQN->TQN_DTABAS, TQN->TQN_HRABAS, .T. } )

							EndIf

							dbSelectArea("TQN")

							//---------------------------------------------------------------------
							//Inclui historico do contador da Bomba
							//---------------------------------------------------------------------
							NGIncTTV(TQN->TQN_POSTO,TQN->TQN_LOJA,TQN->TQN_TANQUE,TQN->TQN_BOMBA,TQN->TQN_DTABAS,TQN->TQN_HRABAS,"2",,TQN->TQN_QUANT,TQN->TQN_NABAST) //,TTA->TTA_RESPON)
						
						EndIf

					EndIf

					//Grava STP
					If !lVirada
						If Altera

							//POG -> Deleta o Contador para fazer a validação, mas não iremos gravar essa exclusão
							aRetTPN := NgFilTPN(aCols[nI][nPOSFROTA],dDataAbast,aCols[nI][nPOSHORAB])

							If !Empty(aRetTPN[1])
								cFilBem := aRetTPN[1]
							EndIf

							nDifCont := 0
							nAcum655 := 0
							nAcu6552 := 0
							aARALTC  :=  { 'STP', 'STP->TP_FILIAL','STP->TP_CODBEM',;
												'STP->TP_DTLEITU','STP->TP_HORA','STP->TP_POSCONT',;
												'STP->TP_ACUMCON','STP->TP_VARDIA','STP->TP_VIRACON' }

							aARABEM  := { 'ST9', 'ST9->T9_POSCONT','ST9->T9_CONTACU',;
												'ST9->T9_DTULTAC','ST9->T9_VARDIA'}

							dbSelectArea("STP")
							dbSetOrder(5)
							If dbSeek(xFilial("STP", cFilBem) + aCols[nI, nPOSFROTA] + DToS(dDataAbast) + aCols[nI, nPOSHORAB])

								nDifCont := aCols[nI][nPOSHODOM] - STP->TP_POSCONT
								nAcum655 := (stp->tp_acumcon - STP->TP_POSCONT) + aCols[nI][nPOSHODOM]

								nRECNSTP := Recno()
								lULTIMOP := .T.
								nACUMFIP := 0
								nCONTAFP := 0
								nVARDIFP := 0
								dDTACUFP := StoD('')

								dbSkip(-1)

								If !Eof() .And. !BoF() .And. &(aARALTC[2]) = xFilial(aARALTC[1],cFilBem) .And.;
										&(aARALTC[3]) == aCols[nI][nPOSFROTA]

									nACUMFIP := &(aARALTC[7])
									dDTACUFP := &(aARALTC[4])
									nCONTAFP := &(aARALTC[6])
									nVARDIFP := &(aARALTC[8])
								EndIf

								dbGoTo(nRECNSTP)
								nACUMDEL := stp->tp_acumcon

								RecLock("STP",.F.)
								dbDelete()
								STP->(MsUnlock())

								STP->( dbSkip() )

								If Eof() .Or. STP->TP_CODBEM <> aCols[nI][nPOSFROTA]
									dbSkip(-1)

									If aCols[nI][nPOSFROTA] == STP->TP_CODBEM
										RecLock("ST9",.f.)
										ST9->T9_POSCONT += nDifCont
										ST9->T9_CONTACU += nDifCont
										MsUnLock("ST9")
									EndIf
								EndIf

								MNTA875ADEL(aCols[nI][nPOSFROTA],dDataAbast,aCols[nI][nPOSHORAB],1,cFilBem,cFilBem)
							EndIf
						EndIf

						NGTRETCON(aCols[nI][nPOSFROTA],dDataAbast,aCols[nI][nPOSHODOM],aCols[nI][nPOSHORAB],1,,,IIF(!Empty(aCols[nI][nPOSQUANT]),"A","C"),cFil)

	 					//GERAR O.S AUTOMATICA POR CONTADOR
						If !lGeraOSAut
							If nI == 1
								If (cGeraPrev = "S" .Or. cGeraPrev = "C" .Or. cGeraPrev = "A") .And. !Empty(aCols[nI][nPOSHODOM])
									If cGeraPrev = "C"
										If MsgYesNo(STR0078+chr(13)+chr(13); //"Deseja que seja verificado a existência de o.s automática por contador?"
												+STR0079,STR0007) //"Confirma (Sim/Não)" ## "ATENÇÃO"
											NGGEROSAUT(aCols[nI][nPOSFROTA],aCols[nI][nPOSHODOM],cFil)
											lGeraOSAut := .t.
										EndIf
									Else
										NGGEROSAUT(aCols[nI][nPOSFROTA],aCols[nI][nPOSHODOM],cFil)
										lGeraOSAut := .t.
									EndIf
								EndIf
							EndIf
						ElseIf !Empty(aCols[nI][nPOSHODOM])
							NGGEROSAUT(aCols[nI][nPOSFROTA],aCols[nI][nPOSHODOM],cFil)
						EndIf

						//Grava o Contador dos Componentes (Filhos do Bem Pai)
						aAreaOld := GetArea()

						dbSelectArea(cAliasDet)
						dbSetOrder(1)
						If dbSeek(aCols[nI][nPOSFROTA])

							While !EoF() .And. AllTrim((cAliasDet)->CODBEM) == AllTrim(aCols[nI][nPOSFROTA])

								If (cAliasDet)->HORPAI == aCols[nI][nPOSHORAB]
									If NGIFDBSEEK("ST9",(cAliasDet)->COMPON,1) .And. AllTrim(ST9->T9_TEMCONT) == "S"
										NGTRETCON((cAliasDet)->COMPON,dDataAbast,(cAliasDet)->HODOM,(cAliasDet)->HORPAI,1,,,If(!Empty(aCols[nI][nPOSQUANT]),"A","C"),cFil)
									EndIf
								EndIf

								dbSelectArea(cAliasDet)
								dbSkip()
							EndDo
						EndIf
						RestArea(aAreaOld)

						//gravacao contador 2
						//FindFunction remover na release GetRPORelease() >= '12.1.027'
						If FindFunction("MNTCont2")
							TIPOACOM2 := MNTCont2(xFilial("TPE",cFilBem), aCols[nI][nPOSFROTA] )
						Else
							dbSelectArea("TPE")
							dbSetOrder(1)
							TipoAcom2 := ( dbSeek(xFilial("TPE",cFilBem) + aCols[nI][nPOSFROTA]) .And. TPE->TPE_SITUAC == "1" )
						EndIf

						If TIPOACOM2
							n := nI
							If !lVirada
								NGTRETCON(aCols[nI][nPOSFROTA],dDataAbast,aCols[nI][nPOSCONT2],aCols[nI][nPOSHORAB],2,,,IIF(!Empty(aCols[nI][nPOSQUANT]),"A","C"),cFil)
								//GERAR O.S AUTOMATICA POR CONTADOR
								If !lGeraOSAut
									If nI == 1
										If (cGeraPrev = "S" .Or. cGeraPrev = "C" .Or. cGeraPrev = "A") .And. !Empty(aCols[nI][nPOSCONT2])
											If cGeraPrev = "C"
												If MsgYesNo(STR0078+chr(13)+chr(13); //"Deseja que seja verificado a existência de o.s automática por contador?"
													+STR0079,STR0007) //"Confirma (Sim/Não)"###"ATENÇÃO"
													NGGEROSAUT(aCols[nI][nPOSFROTA],aCols[nI][nPOSCONT2],cFil)
													lGeraOSAut := .T.
												EndIf
											Else
												NGGEROSAUT(aCols[nI][nPOSFROTA],aCols[nI][nPOSCONT2],cFil)
												lGeraOSAut := .T.
											EndIf
										EndIf
									EndIf
								ElseIf !Empty(aCols[nI][nPOSCONT2])
									NGGEROSAUT(aCols[nI][nPOSFROTA],aCols[nI][nPOSCONT2],cFil)
								EndIf
							Else
								dbSelectArea("TPP")
								dbSetOrder(5)
								dbSeek(xFilial("TPP",cFil)+aCols[nI][nPOSFROTA]+DTOS(dDataAbast)+aCols[nI][nPOSHORAB])
								If TPP->TPP_POSCON == aCols[nI][nPOSCONT2]  .And. (TPP->TPP_TIPOLA $ 'CM')
									RecLock("TPP",.F.)
									TPP->TPP_TIPOLA := "A"
									MsUnLock("TPP")
								EndIf
							EndIf
						EndIf
					EndIf

				Else
					n := nI
					MNT656EXJG(aCols[nI][nPOSFROTA],nI, dDataAbast, .T.,oGLubrif:aCols) //Exclui Abastecimentos ja gravados
				EndIf

			ElseIf Altera

				dbSelectArea("ST9")
				dbSetOrder(16)
				dbSeek(aCols[nI][nPOSFROTA])
				cFilBem := ST9->T9_FILIAL
				cCodBem := ST9->T9_CODBEM
				If !aCols[nI][Len(aHeader)+1]

					//Refaz o primeiro contador
					If	aOldCols[nI][nPOSHODOM] != aCols[nI][nPOSHODOM]

						aRetTPN := NgFilTPN(cCodBem,dDataAbast,aCols[nI][nPOSHORAB])
						If !Empty(aRetTPN[1])
							cFilBem  := aRetTPN[1]
						EndIf

						nDifCont := 0
						nAcum655 := 0
						nAcu6552 := 0
						aARALTC :=  {'STP','stp->tp_filial','stp->tp_codbem',;
							'stp->tp_dtleitu','stp->tp_hora','stp->tp_poscont',;
							'stp->tp_acumcon','stp->tp_vardia','stp->tp_viracon'}

						aARABEM := {'ST9','st9->t9_poscont','st9->t9_contacu',;
							'st9->t9_dtultac','st9->t9_vardia'}

						dbSelectArea("STP")
						dbSetOrder(5)
						If dbSeek(xFilial("STP",cFilBem)+cCodBem+DTOS(dDataAbast)+aCols[nI][nPOSHORAB])

							nDifCont := aCols[nI][nPOSHODOM] - STP->TP_POSCONT
							nAcum655 := (stp->tp_acumcon - STP->TP_POSCONT) + aCols[nI][nPOSHODOM]

							nRECNSTP := Recno()
							lULTIMOP := .T.
							nACUMFIP := 0
							nCONTAFP := 0
							nVARDIFP := 0
							dDTACUFP := StoD('')

							dbSkip(-1)

							If !Eof() .And. !Bof() .And. &(aARALTC[2]) = xFilial(aARALTC[1],cFilBem) .And.;
									&(aARALTC[3]) == cCodBem
								nACUMFIP := &(aARALTC[7])
								dDTACUFP := &(aARALTC[4])
								nCONTAFP := &(aARALTC[6])
								nVARDIFP := &(aARALTC[8])
							EndIf

							dbGoTo(nRECNSTP)

							nACUMDEL := stp->tp_acumcon

							RecLock("STP",.f.)
							dbDelete()
							STP->(MsUnlock())
							STP->(dbSkip())

							If Eof() .Or. STP->TP_CODBEM <> cCodBem
								dbSkip(-1)
								If cCodBem == STP->TP_CODBEM
									RecLock("ST9",.f.)
									ST9->T9_POSCONT += nDifCont
									ST9->T9_CONTACU += nDifCont
									MsUnLock("ST9")
								EndIf
							EndIf

							MNTA875ADEL(cCodBem,dDataAbast,aCols[nI][nPOSHORAB],1,cFilBem,cFilBem)
						EndIf

						dbSelectArea("TPP")
						dbSetOrder(5)
						If dbSeek(xFilial("TPP",cFilBem)+cCodBem+DTOS(dDataAbast)+aCols[nI][nPOSHORAB])

							aARALTC := {'TPP','tpp->tpp_filial','tpp->tpp_codbem',;
								'tpp->tpp_dtleit','tpp->tpp_hora','tpp->tpp_poscon',;
								'tpp->tpp_acumco','tpp->tpp_vardia','tpp->tpp_viraco'}

							aARABEM := {'TPE','tpe->tpe_poscon','tpe->tpe_contac',;
								'tpe->tpe_dtulta','tpe->tpe_vardia'}

							nAcu6552 := (&(aARALTC[7]) - &(aARALTC[6])) + aCols[nI][nPOSCONT2]
							nRECNSTP := Recno()
							lULTIMOP := .T.
							nACUMFIP := 0
							nCONTAFP := 0
							nVARDIFP := 0
							dDTACUFP := StoD('')

							dbSkip(-1)

							If !Eof() .And. !Bof() .And. &(aARALTC[2]) = xFilial(aARALTC[1],cFilBem) .And.;
									&(aARALTC[3]) == cCodBem
								nACUMFIP := &(aARALTC[7])
								dDTACUFP := &(aARALTC[4])
								nCONTAFP := &(aARALTC[6])
								nVARDIFP := &(aARALTC[8])
							EndIf

							dbGoTo(nRECNSTP)

							nACUMDEL := TPP->TPP_ACUMCO

							RecLock("TPP",.f.)
							dbDelete()
							TPE->(MsUnlock())
							MNTA875ADEL(cCodBem,dDataAbast,aCols[nI][nPOSHORAB],2,cFilBem,cFilBem)
						EndIf

						n := nI
						NGTRETCON(cCodBem,dDataAbast,aCols[nI][nPOSHODOM],aCols[nI][nPOSHORAB],1,,,IIF(!Empty(aCols[nI][nPOSQUANT]),"A","C"),cFilbem)

						dbSelectArea("TQN")
						dbSetOrder(01)
						If dbSeek(xFilial("TQN",cFilBem)+cCodBem+DTOS(dDataAbast)+aCols[nI][nPOSHORAB])

							RecLock( 'TQN', .F. )

								TQN->TQN_HODOM := aCols[nI][nPOSHODOM]
							
							TQN->( MsUnlock() )

							If lMNTA6810

								ExecBlock( 'MNTA6810', .F. , .F. , { TQN->TQN_FROTA, TQN->TQN_DTABAS, TQN->TQN_HRABAS, .F. } )

							EndIf

						EndIf

					EndIf

					//Refaz o segundo contador
					If aOldCols[nI][nPOSCONT2] != aCols[nI][nPOSCONT2]
						dbSelectArea("TPP")
						dbsetorder(5)
						If dbSeek(xFilial("TPP",cFilBem)+cCodBem+DTOS(dDataAbast)+aCols[nI][nPOSHORAB])
							aARALTC := {'TPP','tpp->tpp_filial','tpp->tpp_codbem',;
											'tpp->tpp_dtleit','tpp->tpp_hora','tpp->tpp_poscon',;
											'tpp->tpp_acumco','tpp->tpp_vardia','tpp->tpp_viraco'}
							aARABEM := {'TPE','tpe->tpe_poscon','tpe->tpe_contac',;
											'tpe->tpe_dtulta','tpe->tpe_vardia'}
							nAcu6552 := (&(aARALTC[7]) - &(aARALTC[6])) + aCols[nI][nPOSCONT2]
							nRECNSTP := Recno()
							lULTIMOP := .T.
							nACUMFIP := 0
							nCONTAFP := 0
							nVARDIFP := 0
							dDTACUFP := StoD('')
							dbSkip(-1)
							If !EoF() .And. !BoF() .And. &(aARALTC[2]) = xFilial(aARALTC[1],cFilBem) .And.;
								&(aARALTC[3]) == cCodBem
								nACUMFIP := &(aARALTC[7])
								dDTACUFP := &(aARALTC[4])
								nCONTAFP := &(aARALTC[6])
								nVARDIFP := &(aARALTC[8])
							EndIf
							dbGoTo(nRECNSTP)
							nACUMDEL := TPP->TPP_ACUMCO
							RecLock("TPP",.F.)
							dbDelete()
							TPE->(MsUnlock())
							MNTA875ADEL(cCodBem,dDataAbast,aCols[nI][nPOSHORAB],2,cFilBem,cFilBem)
						EndIf

						NGTRETCON(aCols[nI][nPOSFROTA],dDataAbast,aCols[nI][nPOSCONT2],aCols[nI][nPOSHORAB],2,,,IIF(!Empty(aCols[nI][nPOSQUANT]),"A","C"),cFilBem)

						dbSelectArea("TQN")
						dbSetOrder(01)
						If dbSeek(xFilial("TQN",cFilBem)+cCodBem+DTOS(dDataAbast)+aCols[nI][nPOSHORAB])
							RecLock("TQN",.F.)
							If lSegCont
								TQN->TQN_POSCO2 := aCols[nI][nPOSCONT2]
							EndIf
							TQN->(MsUnlock())
						EndIf
					EndIf

					cNumSeqD := ''

					dbSelectArea("TQN")
					dbSetOrder(01)
					If dbSeek(xFilial("TQN",cFilBem)+cCodBem+DTOS(dDataAbast)+aCols[nI][nPOSHORAB])

						If !Empty(aCols[nI][nPOSQUANT]) .And. (aCols[nI][nPOSQUANT] != aOldCols[nI][nPOSQUANT])

							If aOldCols[nI][nPOSQUANT] <> aCols[nI][nPOSQUANT] .And. !Empty(TQN->TQN_NUMSEQ)

								cFilTQF := MNT655FTQF( dDataAbast , TQN->TQN_NUMSEQ , aOldCols[nI][nPOSQUANT] ) //Data / Numseq / Quantidade

								cCodComb := NGSEEK('TQI',cPosto+cLoja+cTanque,1,'TQI->TQI_CODCOM',cFilTQF)
								dbSelectArea("TQI")
								dbSetOrder(1)
								If dbSeek(xFilial("TQI",cFilTQF)+cPosto+cLoja+cTanque+cCodComb)
									cComb := TQI->TQI_PRODUT
								EndIf
								cUM := NGSEEK('TQM',cCodComb,1,'TQM->TQM_UM',cFilTQF)

								cDocumSD3 := ""
								dbSelectArea("SD3")
								dbSetOrder(04)
								If dbSeek(xFilial("SD3",cFilTQF)+TQN->TQN_NUMSEQ+"E0")
									cDocumSD3 := SD3->D3_DOC
								EndIf

								nRecTQN := TQN->(RECNO())

								MntMovEst('DE0',cTanque,cComb,aOldCols[nI][nPOSQUANT],dDataAbast,cDocumSD3,cFilTQF,TQN->TQN_CCUSTO,,TQN->TQN_NUMSEQ)

								TQN->(dbGoTo(nRecTQN))

								If lMNT655D3CC
									ExecBlock("MNT655D3CC", .F. , .F. , {'DE0', TQN->TQN_FROTA, TQN->TQN_CCUSTO, cFilTQF })
								EndIf

								cNumSeqD := MntMovEst('RE0',cTanque,cComb,aCols[nI][nPOSQUANT],dDataAbast,cDocumSD3,cFilTQF,TQN->TQN_CCUSTO,,TQN->TQN_NUMSEQ)
								TQN->(dbGoTo(nRecTQN))

								//Ponto de Entrada para altecoes finais no SD3
								If lMNT655D3CC
									ExecBlock("MNT655D3CC", .F. , .F. , {'RE0', TQN->TQN_FROTA, TQN->TQN_CCUSTO, cFilTQF })
								EndIf
							EndIf

							RecLock("TQN", .F.)
							TQN->TQN_QUANT  := aCols[nI][nPOSQUANT]
							TQN->TQN_VALTOT := aCols[nI][nPOSQUANT] * TQN->TQN_VALUNI

							If !Empty(cNumSeqD)
								TQN->TQN_NUMSEQ := cNumSeqD
							EndIf

							TQN->( MsUnlock() )

							//---------------------------------------------------------------------
							//Altera historico do contador da Bomba
							//---------------------------------------------------------------------
							NGAltTTVQnt(TQN->TQN_POSTO,TQN->TQN_LOJA,TQN->TQN_TANQUE,TQN->TQN_BOMBA,TQN->TQN_DTABAS,TQN->TQN_HRABAS,'2',TQN->TQN_QUANT)

							ElseIF !Empty(aCols[nI][nPosMotor]) .And. (aCols[nI][nPosMotor] != aOldCols[nI][nPosMotor])

								RecLock("TQN", .F.)
								TQN->TQN_CODMOT := aCols[nI][nPosMotor]
								TQN->( MsUnlock() )

						EndIf

					EndIf
				Else
					n := nI
					MNT656EXJG(cCodBem, nI, dDataAbast, .T.,oGLubrif:aCols) //Exclui Abastecimentos ja gravados
				EndIf
			EndIf

		Next

	EndIf



	//Inicio Gravacao Lubrificantes
	If Inclui .Or. Altera
		cOSLub := " "
		nTotLub := 0
		dbSelectArea(cAliasLub)
		dbGoTop()
		While !Eof()
			If !Empty((cAliasLub)->PRODUT)
				nScan := aScan(oGLubrif:aCols,{|x| x[nPOSFROTA]+x[nPOSHORAB] == (cAliasLub)->CODBEM+(cAliasLub)->HORABA })

				If nScan > 0
					If aScan(aOldCols02,{|x| x[1]+x[2]+x[3] == (cAliasLub)->CODBEM+(cAliasLub)->PRODUT+(cAliasLub)->HORABA }) == 0
						cOSLub := MNT681LUB((cAliasLub)->CODBEM,If((cAliasLub)->DESTIN == "1",cTroca,cReposicao),;
							(cAliasLub)->PRODUT,(cAliasLub)->QUANTI,dDataAbast,(cAliasLub)->HORABA,;
							oGLubrif:aCols[nScan][nPOSHODOM],,(cAliasLub)->ALMOXA,;
							IIF(cUsaInt3=='S',,(cAliasLub)->CUSTO))
					EndIf
				EndIf
				nTotLub += (cAliasLub)->QUANTI
			EndIf
			dbSelectArea(cAliasLub)
			dbSkip()
		End

		cOSLub := " "
		dbSelectArea(cAliasDet)
		dbGoTop()
		While !Eof()
			If !Empty((cAliasDet)->PRODUT)
				nScan := aScan(oGLubrif:aCols,{|x| x[nPOSFROTA] == (cAliasDet)->CODBEM })

				If nScan > 0
					If aScan(aOldCols04,{|x| x[1]+x[2]+x[4] == oGLubrif:aCols[nScan][nPOSFROTA]+(cAliasDet)->COMPON+(cAliasDet)->HORPAI }) == 0
						cOSLub := MNT681LUB((cAliasDet)->COMPON,If((cAliasDet)->DESTIN == "1",cTroca,cReposicao),;
							(cAliasDet)->PRODUT,(cAliasDet)->QUANTI,dDataAbast,(cAliasDet)->HORPAI,;
							IIF((cAliasDet)->HODOM==0,oGLubrif:aCols[nScan][nPOSHODOM],(cAliasDet)->HODOM),,;
							(cAliasDet)->ALMOXA,IIF(cUsaInt3=='S',,(cAliasDet)->CUSTO))
					EndIf
				EndIf
				nTotLub += (cAliasDet)->QUANTI
			EndIf
			dbSelectArea(cAliasDet)
			dbSkip()
		End

		dbSelectArea("TTA")
		dbSetOrder(1)
		If dbSeek(xFilial("TTA")+cPosto+cLoja+cFolha)
			RecLock("TTA",.f.)
			TTA->TTA_TOTLUB := nTotLub
			TTA->(MsUnlock())
		EndIf
	EndIf
	//Fim Gravacao Lubrificantes

Return .t.

//---------------------------------------------------------------------
/*/{Protheus.doc} GravaAcols()
Gravacao das Acols

@author Marcos Wagner Junior
@since 24/05/2014
/*/
//---------------------------------------------------------------------
Static Function GravaAcols()
	Local nI

	If Len(oGProdPrc:aCols) > 0
		For nI := 1 to Len(oGProdPrc:aCols)
			If !Empty(oGProdPrc:aCols[oGProdPrc:nAt][nPosCodPrc]) .And. !oGProdPrc:aCols[nI][Len(oGProdPrc:aCols[nI])]
				dbSelectArea((cAliasLub))
				dbSetOrder(01)
				If dbSeek(oGLubrif:aCols[oGLubrif:nAt][nPOSFROTA]+oGProdPrc:aCols[nI][nPosCodPrc]+oGLubrif:aCols[oGLubrif:nAt][nPOSHORAB])
					RecLock((cAliasLub),.f.)
				Else
					RecLock((cAliasLub),.t.)
					(cAliasLub)->CODBEM := oGLubrif:aCols[oGLubrif:nAt][nPOSFROTA]
					(cAliasLub)->PRODUT := oGProdPrc:aCols[nI][nPosCodPrc]
					(cAliasLub)->HORABA := oGLubrif:aCols[oGLubrif:nAt][nPOSHORAB]
				EndIf
				(cAliasLub)->QUANTI := oGProdPrc:aCols[nI][nPosQtdPrc]
				(cAliasLub)->UNIDAD := oGProdPrc:aCols[nI][nPosUniPrc]
				(cAliasLub)->ALMOXA := oGProdPrc:aCols[nI][nPosLocPrc]
				(cAliasLub)->DESTIN := oGProdPrc:aCols[nI][nPosDesPrc]
				(cAliasLub)->CUSTO  := oGProdPrc:aCols[nI][nPosCusPrc]
				(cAliasLub)->(MsUnlock())
			EndIf
		Next

		oGProdPrc:Refresh()
	EndIf

	If Len(oGItensCmp:aCols) > 0
		If !Empty(oGItensCmp:aCols[oGItensCmp:nAt][nPosIndic]) .And. !ATail(oGItensCmp:aCols[oGItensCmp:nAt])
			dbSelectArea((cAliasCmp))
			dbSetOrder(01)
			If dbSeek(oGLubrif:aCols[oGLubrif:nAt][nPOSFROTA]+oGLubrif:aCols[oGLubrif:nAt][nPOSHORAB])
				RecLock((cAliasCmp),.f.)
			Else
				RecLock((cAliasCmp),.t.)
				(cAliasCmp)->CODBEM := oGLubrif:aCols[oGLubrif:nAt][nPOSFROTA]
				(cAliasCmp)->HORABA := oGLubrif:aCols[oGLubrif:nAt][nPOSHORAB]
			EndIf
			(cAliasCmp)->INDICA := oGItensCmp:aCols[oGItensCmp:nAt][nPosIndic]
			//(cAliasCmp)->TOTITE := oGItensCmp:aCols[oGItensCmp:nAt][nPosItens]
			(cAliasCmp)->QTDTOT := oGItensCmp:aCols[oGItensCmp:nAt][nPosTotal]
			(cAliasCmp)->(MsUnlock())

			//Limpa a getdados somente se estiver "trocando" o equipamento principal
			If IsInCallStack("MNT681OK1") .And. !IsInCallStack("TUDOOK")
				oGItensCmp:aCols := BLANKGETD(oGItensCmp:aHeader)
				oGItensCmp:Refresh()
			EndIf

		EndIf
	EndIf

	If Len(oGProdCmp:aCols) > 0
		For nI := 1 to Len(oGProdCmp:aCols)
			If !Empty(oGProdCmp:aCols[nI][nPosBemCmp]) .And. !oGProdCmp:aCols[nI][Len(oGProdCmp:aCols[nI])]
				dbSelectArea((cAliasDet))
				dbSetOrder(01)
				If dbSeek(oGLubrif:aCols[oGLubrif:nAt][nPOSFROTA]+oGProdCmp:aCols[nI][nPosBemCmp]+oGLubrif:aCols[oGLubrif:nAt][nPOSHORAB])
					RecLock((cAliasDet),.f.)
				Else
					RecLock((cAliasDet),.t.)
					(cAliasDet)->CODBEM := oGLubrif:aCols[oGLubrif:nAt][nPOSFROTA]
					(cAliasDet)->COMPON := oGProdCmp:aCols[nI][nPosBemCmp]
					(cAliasDet)->HORPAI := oGLubrif:aCols[oGLubrif:nAt][nPOSHORAB]
				EndIf
				(cAliasDet)->DESCOM := oGProdCmp:aCols[nI][nPosNomCmp]
				(cAliasDet)->HODOM  := oGProdCmp:aCols[nI][nPosHodCmp]
				(cAliasDet)->QUANTI := oGProdCmp:aCols[nI][nPosQtdCmp]
				(cAliasDet)->UNIDAD := oGProdCmp:aCols[nI][nPosUniCmp]
				(cAliasDet)->PRODUT := oGProdCmp:aCols[nI][nPosCodCmp]
				(cAliasDet)->ALMOXA := oGProdCmp:aCols[nI][nPosLocCmp]
				(cAliasDet)->DESTIN := oGProdCmp:aCols[nI][nPosDesCmp]
				(cAliasDet)->CUSTO  := oGProdCmp:aCols[nI][nPosCusCmp]
				(cAliasDet)->(MsUnlock())
			EndIf
		Next
		//Limpa a getdados somente se estiver "trocando" o equipamento principal
		If IsInCallStack("MNT681OK1") .And. !IsInCallStack("TUDOOK")
			oGProdCmp:aCols := BLANKGETD(oGProdCmp:aHeader)
			oGProdCmp:Refresh()
		EndIf
	EndIf

Return .t.
//---------------------------------------------------------------------
/*/{Protheus.doc} CarregaGets()
Validacao do contador do bem (filho)

@author Marcos Wagner Junior
@since 24/05/2014
/*/
//---------------------------------------------------------------------
Static Function CarregaGets()

	Local aOldArea := GetArea()

	Local lJaGravou2 := .F.
	Local lJaGravou4 := .F.

	Local cBemPai

	If !Inclui

		oGLubrif:aCols	:= {}
		aApenasLub		:= {}

		//---------------------------------------------------------------------
		//Carrega dados de abastecimento já cadastrados
		//---------------------------------------------------------------------
		cAliasTQN := GetNextAlias()

		cQuery := " SELECT TQN.TQN_FROTA, TQN.TQN_PLACA, ST9.T9_NOME, TQN.TQN_HRABAS, "
		cQuery += "   TQN.TQN_HODOM, TQN.TQN_POSCO2, TQN.TQN_QUANT, TQN.TQN_CODMOT"
		cQuery += " FROM " + RetSqlName("TQN") + " TQN"
		cQuery += " INNER JOIN " + RetSqlName("ST9") + " ST9 ON ( TQN.TQN_FROTA = ST9.T9_CODBEM AND "
		cQuery += "   ST9.T9_FILIAL = '" + xFilial("ST9") + "' AND ST9.D_E_L_E_T_ <> '*' ) "
		cQuery += " WHERE TQN.TQN_POSTO    = '" + TTA->TTA_POSTO  + "'"
		cQuery += "   AND TQN.TQN_LOJA     = '" + TTA->TTA_LOJA   + "'"
		cQuery += "   AND TQN.TQN_TANQUE   = '" + TTA->TTA_TANQUE + "'"
		cQuery += "   AND TQN.TQN_BOMBA    = '" + TTA->TTA_BOMBA  + "'"
		cQuery += "   AND TQN.TQN_NOTFIS   = '" + TTA->TTA_FOLHA  + "'"
		cQuery += "   AND TQN.D_E_L_E_T_  <> '*' "

		If xFilial('TTA') == xFilial('TQN')
			cQuery += " AND TQN.TQN_FILIAL = " + ValToSql( xFilial("TTA") )
		EndIf

		cQuery += "   ORDER BY TQN.TQN_FROTA, TQN.TQN_HRABAS "

		cQuery := ChangeQuery(cQuery)

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTQN, .F., .F.)

		If (cAliasTQN)->( !EoF() )

			While (cAliasTQN)->( !EoF() )

				aAdd( oGLubrif:aCols, { (cAliasTQN)->TQN_FROTA ,;
										(cAliasTQN)->TQN_PLACA ,;
										(cAliasTQN)->T9_NOME   ,;
										(cAliasTQN)->TQN_HRABAS,;
										(cAliasTQN)->TQN_HODOM ,;
										(cAliasTQN)->TQN_POSCO2,;
										(cAliasTQN)->TQN_QUANT ,;
										(cAliasTQN)->TQN_CODMOT,;
										Trim( NGSEEK('DA4', (cAliasTQN)->TQN_CODMOT, 1, 'DA4->DA4_NOME') ),.F.} )

				(cAliasTQN)->( dbSkip() )
			EndDo

			oGLubrif:Refresh()
		EndIf

		(cAliasTQN)->( dbCloseArea() )

		//---------------------------------------------------------------------
		//Carrega registros  de abastecimentos já efetuados
		//---------------------------------------------------------------------
		cAliasSTL := GetNextAlias()

		cQuery := " SELECT STJ.TJ_CODBEM, STJ.TJ_CONTINI, STL.TL_CODIGO, STL.TL_QUANTID,"
		cQuery += "         STL.TL_UNIDADE, STL.TL_HOINICI, STL.TL_LOCAL, STJ.TJ_SERVICO,"
		cQuery += "         ST9.T9_NOME, STJ.TJ_POSCONT, STL.TL_CUSTO, STL.TL_DTINICI "

		If lMMoeda
			cQuery += ", STL.TL_MOEDA "
		EndIf

		cQuery += " FROM " + RetSqlName("STL") + " STL, "  + RetSqlName("STJ") + " STJ "
		cQuery += " INNER JOIN " + RetSqlName("ST9") + " ST9 ON STJ.TJ_CODBEM = ST9.T9_CODBEM "
		cQuery += "     AND '" + xFilial("ST9") + "' = ST9.T9_FILIAL"
		cQuery += "     AND ST9.D_E_L_E_T_ <> '*' "
		cQuery += " WHERE "

		If NGCADICBASE("TL_FORNEC", "A", "STL", .F.)

			cQuery += " STL.TL_FORNEC     = " + ValToSql(cPosto)
			cQuery += "   AND STL.TL_LOJA   = " + ValToSql(cLoja)
			cQuery += "   AND STL.TL_NOTFIS = " + ValToSql(cFolha) + " AND"

		EndIf

		cQuery += " STJ.TJ_FILIAL  = STL.TL_FILIAL "
		cQuery += "   AND   STJ.TJ_ORDEM  = STL.TL_ORDEM "
		cQuery += "   AND   STJ.TJ_PLANO  = STL.TL_PLANO "
		cQuery += "   AND   STJ.D_E_L_E_T_ <> '*' "
		cQuery += "   AND   STL.D_E_L_E_T_ <> '*' "

		If xFilial('TTA') == xFilial('STJ')
			cQuery += " AND STJ.TJ_FILIAL = " + ValToSql( xFilial("TTA") )
		EndIf

		cQuery += " ORDER BY STL.TL_CODIGO, STL.TL_DTINICI, STL.TL_HOINICI "

		cQuery := ChangeQuery(cQuery)

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasSTL, .F., .T.)

		If (cAliasSTL)->( !EoF() )
			While (cAliasSTL)->( !EoF () )

				Do Case
					Case (cAliasSTL)->TJ_SERVICO == cTroca
						cDestino := "1"

					Case (cAliasSTL)->TJ_SERVICO == cReposicao
						cDestino := "2"

					OtherWise
						cDestino := " "
				EndCase

				If Empty(cDestino)
					dbSelectArea(cAliasSTL)
					dbSkip()
					Loop
				EndIf

				If ( aScan(oGLubrif:aCols, {|x| DToS( dDataAbast ) + x[nPosHoraB] + x[nPosFrota] == (cAliasSTL)->( TL_DTINICI + TL_HOINICI + TJ_CODBEM) }) == 0 );
					.And. ( NGSEEK( "ST9",(cAliasSTL)->TJ_CODBEM, 1, "T9_CATBEM" ) == "4" );
					.And. ( Empty( NGSEEK( "STC",(cAliasSTL)->TJ_CODBEM, 3, "TC_CODBEM" ) ) ) //Se for apenas pai de alguma estrutura

					aAdd(oGLubrif:aCols,{ (cAliasSTL)->TJ_CODBEM,;
												NGSEEK('ST9',(cAliasSTL)->TJ_CODBEM, 1,'ST9->T9_PLACA'),;
												NGSEEK('ST9',(cAliasSTL)->TJ_CODBEM, 1,'ST9->T9_NOME'),;
												(cAliasSTL)->TL_HOINICI,;
												(cAliasSTL)->TJ_POSCONT,;
												0,'','', .F. })

					// Adiciona no Array de 'Apenas Lubrificação' para controlar esses registros, porque eles não podem ser alterados
					aAdd(aApenasLub, {(cAliasSTL)->TJ_CODBEM, (cAliasSTL)->TL_HOINICI})
				EndIf

				If aScan(oGLubrif:aCols,{|x| x[nPosFrota] + x[nPosHoraB] == (cAliasSTL)->( TJ_CODBEM + TL_HOINICI ) }) > 0 //Se existe na Get01

					RecLock((cAliasLub), .T.)

					(cAliasLub)->CODBEM := (cAliasSTL)->TJ_CODBEM
					(cAliasLub)->HORABA := (cAliasSTL)->TL_HOINICI
					(cAliasLub)->PRODUT := (cAliasSTL)->TL_CODIGO
					(cAliasLub)->QUANTI := (cAliasSTL)->TL_QUANTID
					(cAliasLub)->UNIDAD := (cAliasSTL)->TL_UNIDADE
					(cAliasLub)->ALMOXA := (cAliasSTL)->TL_LOCAL
					(cAliasLub)->DESTIN := cDestino
					(cAliasLub)->CUSTO  := (cAliasSTL)->TL_CUSTO

					If lMMoeda
						(cAliasLub)->MOEDA  := (cAliasSTL)->TL_MOEDA
					EndIf

					(cAliasLub)->(MsUnlock())

					aAdd(aOldCols02, { (cAliasSTL)->TJ_CODBEM,;
											(cAliasSTL)->TL_CODIGO,;
											(cAliasSTL)->TL_HOINICI,;
											(cAliasSTL)->TL_QUANTID,;
											(cAliasSTL)->TL_UNIDADE,;
											(cAliasSTL)->TL_LOCAL,;
											cDestino,;
											(cAliasSTL)->TL_CUSTO})

					If lMMoeda
						aAdd(aOldCols02[ Len(aOldCols02) ], (cAliasSTL)->TL_MOEDA)
					EndIf

					If oGLubrif:aCols[oGLubrif:nAt,nPosFrota] + oGLubrif:aCols[oGLubrif:nAt][nPosHoraB] == (cAliasSTL)->TJ_CODBEM + (cAliasSTL)->TL_HOINICI

						If !lJaGravou2
							oGProdPrc:aCols := {}
							lJaGravou2 := .T.
						EndIf

						aAdd(oGProdPrc:aCols, { (cAliasSTL)->TL_CODIGO,;
													(cAliasSTL)->TL_QUANTID,;
													(cAliasSTL)->TL_UNIDADE,;
													(cAliasSTL)->TL_LOCAL,;
													cDestino,;
													(cAliasSTL)->TL_CUSTO})

						If lMMoeda
							aAdd(oGProdPrc:aCols[Len(oGProdPrc:aCols)], (cAliasSTL)->TL_MOEDA) // Multi-Moeda
						EndIf

						// Coluna default de verificação de exclusão
						aAdd(oGProdPrc:aCols[ Len(oGProdPrc:aCols) ], .F.)
					EndIf
				Else

					If !lJaGravou4
						LoadEstru(.T., oGLubrif:aCols[oGLubrif:nAt, nPosFrota])
						lJaGravou4 := .T.
					EndIf

					dbSelectArea("ST9") //Seek para achar o T9_TEMCONT
					dbSetOrder(16)
					dbSeek( (cAliasSTL)->TJ_CODBEM )

					GravAlias4((cAliasSTL)->TJ_CODBEM,(cAliasSTL)->T9_NOME,(cAliasSTL)->TJ_CONTINI,(cAliasSTL)->TL_QUANTID,(cAliasSTL)->TL_UNIDADE,(cAliasSTL)->TL_CODIGO,;
						cDestino,(cAliasSTL)->TL_HOINICI,(cAliasSTL)->TL_LOCAL,(cAliasSTL)->TL_CUSTO, If(lMMoeda,(cAliasSTL)->TL_MOEDA,"") )

					aAdd(aOldCols04,{NGBEMPAI((cAliasSTL)->TJ_CODBEM),;
						(cAliasSTL)->TJ_CODBEM,;
						(cAliasSTL)->T9_NOME,;
						(cAliasSTL)->TL_HOINICI,;
						(cAliasSTL)->TJ_CONTINI,;
						(cAliasSTL)->TL_CODIGO,;
						(cAliasSTL)->TL_QUANTID,;
						(cAliasSTL)->TL_UNIDADE,;
						(cAliasSTL)->TL_LOCAL,;
						cDestino,;
						(cAliasSTL)->TL_CUSTO})

					If lMMoeda
						aAdd(aOldCols04[Len(aOldCols04)], (cAliasSTL)->TL_MOEDA)
					EndIf

					cBemPai := NGBemPai( (cAliasSTL)->TJ_CODBEM )

					GRAVALIAS3(cBemPai,(cAliasSTL)->TL_HOINICI,(cAliasSTL)->TL_QUANTID)

					If oGLubrif:aCols[oGLubrif:nAt][nPOSFROTA]+oGLubrif:aCols[oGLubrif:nAt][nPOSHORAB] == cBemPai+(cAliasSTL)->TL_HOINICI

						If (nPOS := aScan(oGProdCmp:aCols,{|x| x[1] == (cAliasSTL)->TJ_CODBEM })) > 0
							oGProdCmp:aCols[nPOS][nPosHodCmp] := IIF(ST9->T9_TEMCONT=='S',(cAliasSTL)->TJ_CONTINI,0)
							oGProdCmp:aCols[nPOS][nPosCodCmp] := (cAliasSTL)->TL_CODIGO
							oGProdCmp:aCols[nPOS][nPosQtdCmp] := (cAliasSTL)->TL_QUANTID
							oGProdCmp:aCols[nPOS][nPosUniCmp] := (cAliasSTL)->TL_UNIDADE
							oGProdCmp:aCols[nPOS][nPosLocCmp] := (cAliasSTL)->TL_LOCAL
							oGProdCmp:aCols[nPOS][nPosDesCmp] := cDestino
							oGProdCmp:aCols[nPOS][nPosCusCmp] := (cAliasSTL)->TL_CUSTO

							If lMMoeda .And. nPosMoeCmp > 0
								oGProdCmp:aCols[nPOS][nPosMoeCmp] := (cAliasSTL)->TL_MOEDA
							EndIf
						EndIf

						If Empty(oGProdPrc:aCols[oGProdPrc:nAt][nPosIndic])

							oGItensCmp:aCols := {}

							aAdd(oGItensCmp:aCols, {'1', 1, (cAliasSTL)->TL_QUANTID, .F.} )

						Else
							//oGItensCmp:aCols[oGItensCmp:nAt][nPosItens] += 1
							oGItensCmp:aCols[oGItensCmp:nAt][nPosTotal] += (cAliasSTL)->TL_QUANTID
							oGItensCmp:aCols[oGItensCmp:nAt][Len(oGItensCmp:aCols[oGItensCmp:nAt])] := .F.
						EndIf
					EndIf
				EndIf

				dbSelectArea(cAliasSTL)
				dbSkip()
			End

			IIf( !Inclui, fLostFLub(), Nil)

			oGLubrif:Refresh()
			oGProdPrc:Refresh()
			oGProdCmp:Refresh()
			oGItensCmp:Refresh()
		EndIf

		aOldCols := aClone(oGLubrif:aCols)

		(cAliasSTL)->( dbCloseArea() )
	EndIf

	RestArea(aOldArea)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} LoadEstru()
Carrega a estrutura do bem pai

@author Marcos Wagner Junior
@since 24/05/2010
/*/
//---------------------------------------------------------------------
Static Function LoadEstru(lZera,_cFrota)
	Local aOldArea
	Local lMMoeda := NGCADICBASE("TL_MOEDA","A","STL",.F.) // Multi-Moeda

	dbSelectArea("STC")
	dbSetOrder(01)
	If dbSeek(xFilial("STC")+_cFrota)
		If lZera .Or. Empty(oGProdCmp:aCols[oGProdCmp:nAt][nPosBemCmp])
			oGProdCmp:aCols := {}
		EndIf
		While !Eof() .And. STC->TC_CODBEM == _cFrota
			aOldArea := GetArea()
			dbSelectArea("ST9")
			dbSetOrder(16)
			If dbSeek(STC->TC_COMPONE) .And. ST9->T9_LUBRIFI == '1'
				If aScan(oGProdCmp:aCols,{|x| x[1] == STC->TC_COMPONE }) == 0
					aAdd(oGProdCmp:aCols,{STC->TC_COMPONE,;
						ST9->T9_NOME,;
						0,;
						Space(Len(STT->TT_CODIGO)),;
						0,;
						Space(Len(TCI->TCI_UNIMED)),;
						Space(Len(STQ->TQ_OK)),;
						Space(Len(TQG->TQG_ORDENA)),;
						0})
					If lMMoeda
						aAdd(oGProdCmp:aCols[Len(oGProdCmp:aCols)],"1")
					EndIf
					aAdd(oGProdCmp:aCols[Len(oGProdCmp:aCols)],.f.)

					GRAVALIAS4(STC->TC_COMPONE,ST9->T9_NOME,0,0,Space(Len(TCI->TCI_UNIMED)),Space(Len(STT->TT_CODIGO)),;
						Space(Len(TQG->TQG_ORDENA)),'  :  ',Space(Len(STQ->TQ_OK)),0)
				EndIf
			EndIf
			RestArea(aOldArea)
			dbSelectArea("STC")
			dbSkip()
		End
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} GRAVALIAS3()
Grava o cAliasCmp dos

@author Marcos Wagner Junior
@since 24/05/2014
/*/
//---------------------------------------------------------------------
Static Function GRAVALIAS3(_cCodBem,_cHora,_nQtdTot)
	Local aOldArea := GetArea()
	_cHora := IIF(_cHora=='  :  ',oGLubrif:aCols[oGLubrif:nAt][nPOSHORAB],_cHora)

	If !Empty(_cCodBem)
		dbSelectArea(cAliasCmp)
		dbSetOrder(01)
		If dbSeek(_cCodBem+_cHora)
			RecLock((cAliasCmp),.f.)
		Else
			RecLock((cAliasCmp),.t.)
			(cAliasCmp)->CODBEM := _cCodBem
			(cAliasCmp)->HORABA := _cHora
		EndIf
		(cAliasCmp)->INDICA := '2'
		//(cAliasCmp)->TOTITE += 1
		(cAliasCmp)->QTDTOT += _nQtdTot
		If (cAliasCmp)->QTDTOT > 0
			(cAliasCmp)->INDICA := '1'
		EndIf
		(cAliasCmp)->(MsUnlock())
	EndIf

	RestArea(aOldArea)

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} GRAVALIAS4()
Grava o cAliasDet

@author Marcos Wagner Junior
@since 24/05/2014
/*/
//---------------------------------------------------------------------
Static Function GRAVALIAS4(_cCodBem,_cNome,_nContador,_nQuantid,_cUnidade,_cProduto,_cDestino,_cHora,_cAlmoxa,_nCusto,_cMoeda)
	Local aOldArea := GetArea()
	Local _cBemPai := NGBEMPAI(_cCodBem)
	_cHora := IIF(_cHora=='  :  ',oGLubrif:aCols[oGLubrif:nAt][nPOSHORAB],_cHora)

	Default _cMoeda := ""

	If !Empty(_cCodBem)
		dbSelectArea(cAliasDet)
		dbSetOrder(01)
		If dbSeek(_cBemPai+_cCodBem+_cHora)
			RecLock((cAliasDet),.f.)
		Else
			RecLock((cAliasDet),.t.)
			(cAliasDet)->CODBEM := _cBemPai
			(cAliasDet)->COMPON := _cCodBem
			(cAliasDet)->HORPAI := _cHora
		EndIf
		(cAliasDet)->DESCOM := _cNome
		(cAliasDet)->HODOM  := IIF(ST9->T9_TEMCONT=='S',_nContador,0)
		(cAliasDet)->QUANTI := _nQuantid
		(cAliasDet)->UNIDAD := _cUnidade
		(cAliasDet)->PRODUT := _cProduto
		(cAliasDet)->DESTIN := _cDestino
		(cAliasDet)->ALMOXA := _cAlmoxa
		(cAliasDet)->CUSTO  := _nCusto
		If lMMoeda
			(cAliasDet)->MOEDA  := _cMoeda
		EndIf
		(cAliasDet)->(MsUnlock())
	EndIf

	RestArea(aOldArea)

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT681INDI()
Nao permite alterar a indicacao para 'Nao' caso ja gravada

@author Marcos Wagner Junior
@since 24/05/2014
/*/
//---------------------------------------------------------------------
Function MNT681INDI()

	If Altera .And. oGItensCmp:aCols[oGItensCmp:nAt][nPosIndic] == '1' .And. M->INDICA == '2' .And.;
			aScan(aOldCols04,{|x| x[1]+x[4] == oGLubrif:aCols[oGLubrif:nAt][nPOSFROTA]+oGLubrif:aCols[oGLubrif:nAt][nPOSHORAB] }) > 0
		MsgStop(STR0080,STR0007) //"Alteração não permitida pois já foram lançados lubrificantes para os componentes!"###"ATENÇÃO"
		Return .f.
	EndIf

Return .t.
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT681LIDE()
Validacao da delecao dos abastecimentos

@author Marcos Wagner Junior
@since 22/10/2008
/*/
//---------------------------------------------------------------------
Function MNT681LIDE(nPar)

	If nPar == 1
		If ATail( aCols[n])  .And. !MNT681DUPL(2)
			Return .F.
		EndIf
	ElseIf nPar == 2

		dbSelectArea(cAliasLub)
		dbSetOrder(01)
		If dbSeek(oGLubrif:aCols[oGLubrif:nAt, nPosFrota] + oGProdPrc:aCols[n, nPosCodPrc] + oGLubrif:aCols[oGLubrif:nAt, nPosHoraB])
			RecLock((cAliasLub),.f.)
			dbDelete()
			(cAliasLub)->(MsUnlock())
		EndIf
	EndIf

	//Se o registro for apenas uma lubrificação, não pode deletar
	If aScan(aApenasLub, {|x| x[1] + x[2] == oGLubrif:aCols[oGLubrif:nAt, nPosFrota] + oGLubrif:aCols[oGLubrif:nAt, nPosHoraB] }) > 0
		MsgInfo(STR0101, STR0007)//"Este registro é apenas indicativo de uma Lubrificação e não poderá ser deletado, pois a Ordem de Serviço já foi finalizada."###"Atenção"
		Return .F.
	EndIf

	If Altera
		If nPar == 1

			//Verifica se abastecimento ja foi conciliado
			If Len(aOldCols) >= oGLubrif:nAt

				cAliasQry := GetNextAlias()

				cQuery := " SELECT TQN.TQN_DTCON FROM " + RetSqlName("TQN") + " TQN "
				cQuery += " WHERE TQN.TQN_FROTA  = " + ValToSql( oGLubrif:aCols[oGLubrif:nAt, nPosFrota] )
				cQuery += " AND   TQN.TQN_DTABAS = " + ValToSql( DTOS(dDataAbast) )
				cQuery += " AND   TQN.TQN_HRABAS = " + ValToSql( oGLubrif:aCols[oGLubrif:nAt, nPosHoraB] )
				cQuery += " AND   TQN.D_E_L_E_T_ <> '*' "

				cQuery := ChangeQuery(cQuery)

				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

				If !Empty( (cAliasQry)->TQN_DTCON )
					(cAliasQry)->( dbCloseArea() )

					If !MsgYesNo(STR0081) //"Abastecimento já foi conciliado! Deseja continuar?"
						Return .F.
					EndIf
				Else
					(cAliasQry)->( dbCloseArea() )
				EndIf
			EndIf

			If Len(oGProdPrc:aCols) > 0
				If !Empty( oGProdPrc:aCols[oGProdPrc:nAt][nPosCodPrc] ) //Se nao permite alteracao, nao permite exclusao também
					MsgInfo(STR0121, STR0007)//"Este abastecimento está relacionado à uma OS já finalizada e não poderá ser excluído."###"Atenção"
					Return .F.
				EndIf
			EndIf

			If Len(oGProdCmp:aCols) > 0
				If !Empty( oGProdCmp:aCols[oGProdCmp:nAt][nPosBemCmp] ) //Se nao permite alteracao, nao permite exclusao também
					MsgInfo(STR0121, STR0007)//"Este abastecimento está relacionado à uma OS já finalizada e não poderá ser excluído."###"Atenção"
					Return .F.
				EndIf
			EndIf

		ElseIf nPar == 2

			If Len(oGProdPrc:oBrowse:aAlter) == 0 //Se nao permite alteracao, nao permite exclusao tambem
				MsgInfo(STR0120, STR0007)//"A aplicação desse produto está relacionada à uma OS já finalizada e não poderá ser excluído."###"Atenção"
				Return .F.
			EndIf

		EndIf
	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT681VALD()
Validacao da digitacao do lubrificante

@author Marcos Wagner Junior
@since 26/05/10
/*/
//---------------------------------------------------------------------
Function MNT681VALD()

	Local nX, lRet
	Local cProdCmp := M->TL_CODIGO

	If ( lRet := ExistCpo('SB1', M->TL_CODIGO) )

		For nX := 1 To Len( oGProdPrc:aCols )

			If nX <> oGProdPrc:nAt .And. !ATail( oGProdPrc:aCols[nX] ) .And. oGProdPrc:aCols[nX][1] == cProdCmp

				MsgStop(STR0082 + AllTrim( cProdCmp ) + STR0083 +;//"O lubrificante "###" já foi lançado para o bem "
					oGLubrif:aCols[oGLubrif:nAt, nPOSFROTA] + STR0084 + AllTrim(oGLubrif:aCols[oGLubrif:nAt][nPOSHORAB]) + '!',STR0007)//" às "###"ATENÇÃO"

				lRet := .F.
			EndIf
		Next nX
	EndIf

	IIf( lRet, LoadDesc(4), Nil )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT681CONT()
Validacao do contador do bem (filho)

@author Marcos Wagner Junior
@since 24/05/2014
/*/
//---------------------------------------------------------------------
Function MNT681CONT()

	Local lRet		 := .T.
	Local aOldArea := GetArea()

	lRet := IIf(M->TJ_POSCONT > 0, ChkPosLim( oGProdCmp:aCols[oGProdCmp:nAt, nPosBemCmp], M->TJ_POSCONT, 1), Positivo() )

	If !NGChkHisto( oGProdCmp:aCols[oGProdCmp:nAt, nPosBemCmp], dDataAbast, M->TJ_POSCONT, oGLubrif:aCols[oGLubrif:nAt, nPosHoraB], 1,, .T. )
		Return .F.
	EndIf

	If !NGValiVarD( oGProdCmp:aCols[oGProdCmp:nAt, nPosBemCmp], M->TJ_POSCONT, dDataAbast, oGLubrif:aCols[oGLubrif:nAt, nPOSHORAB], 1, .T. )
		Return .F.
	EndIf

	RestArea(aOldArea)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT681DUPL()
Nao permite abastecimentos para o mesmo bem com mesma hora

@author Marcos Wagner Junior
@since 01/07/2014
/*/
//---------------------------------------------------------------------
Function MNT681DUPL(nPar)
	Local cChaveCols := ''
	Local nI

	If nPar == 1
		If oGLubrif:aCols[oGLubrif:nAt][Len(oGLubrif:aCols[oGLubrif:nAt])]
			Return .t.
		EndIf

		If ReadVar() == "M->TQN_FROTA"
			If !Empty(M->TQN_FROTA) .And. !Empty(oGLubrif:aCols[oGLubrif:nAt][nPOSHORAB])
				cChaveCols := M->TQN_FROTA+oGLubrif:aCols[oGLubrif:nAt][nPOSHORAB]
			EndIf
		ElseIf ReadVar() == "M->TQN_HRABAS"
			If !Empty(M->TQN_HRABAS) .And. !Empty(oGLubrif:aCols[oGLubrif:nAt][nPOSFROTA])
				cChaveCols := oGLubrif:aCols[oGLubrif:nAt][nPOSFROTA]+M->TQN_HRABAS
			EndIf
		EndIf
	ElseIf nPar == 2
		cChaveCols := oGLubrif:aCols[oGLubrif:nAt][nPOSFROTA]+oGLubrif:aCols[oGLubrif:nAt][nPOSHORAB]
	EndIf

	If Inclui
		For nI := 1 To Len(oGLubrif:aCols)
			If nI <> n .And. !oGLubrif:aCols[nI][Len(oGLubrif:aCols[nI])] .And. cChaveCols == oGLubrif:aCols[nI][nPOSFROTA]+oGLubrif:aCols[nI][nPOSHORAB]
				MsgStop(STR0085,STR0007) //"Já existe um abastecimento para a mesma frota no mesmo horário!"###"ATENÇÃO"
				Return .f.
			EndIf
		Next
	EndIf

Return .t.
//---------------------------------------------------------------------
/*/{Protheus.doc} fVldFolha()
Foco na linha da GetDados

@author Felipe Nathan Welter
@since  10/08/10
/*/
//---------------------------------------------------------------------
Static Function fVldFolha()

	Local lRet := .T.
	Local aArea := GetArea()

	nPosFrota := aScan(aHeader, {|x| Trim( Upper(x[2]) ) == "TQN_FROTA" })
	nPosPlaca := aScan(aHeader, {|x| Trim( Upper(x[2]) ) == "TQN_PLACA" })
	nPosDesfr := aScan(aHeader, {|x| Trim( Upper(x[2]) ) == "TQN_DESFRO"})
	nPosHoraB := aScan(aHeader, {|x| Trim( Upper(x[2]) ) == "TQN_HRABAS"})
	nPosHodom := aScan(aHeader, {|x| Trim( Upper(x[2]) ) == "TQN_HODOM" })
	nPosQuant := aScan(aHeader, {|x| Trim( Upper(x[2]) ) == "TQN_QUANT" })

	lWhen := .T.

	dbSelectArea("TVJ")
	dbSetOrder(1)
	If dbSeek(xFilial("TVJ") + cFolha) .And. TVJ->TVJ_STATUS == '1'

		cCodObra   := TVJ->TVJ_OBRA
		cDesObra   := NGSEEKDIC("SM0", cEmpAnt + cCodObra, 1, "SM0->M0_NOME")
		cPosto     := TVJ->TVJ_POSTO
		cLoja      := TVJ->TVJ_LOJA
		cDesPosto  := NGSEEK('TQF', cPosto + cLoja, 1, 'TQF->TQF_NREDUZ')
		dDataAbast := TVJ->TVJ_DTABAS

		If LoadDesc(2)

			lWhen	:= .F.

			aBlank	:= BlankGetD(oGLubrif:aHeader)
			aCols	:= {}

			dbSelectArea("TVP")
			dbSetOrder(1)
			dbSeek(xFilial("TVP") + cFolha)
			While !EoF() .And. TVP->TVP_FOLHA == cFolha

				aAdd(aCols, aClone(aBlank[1]))

				ATail(aCols)[nPOSFROTA] := TVP->TVP_CODBEM
				ATail(aCols)[nPOSPLACA] := NGSEEK("ST9",TVP->TVP_CODBEM,1,"ST9->T9_PLACA")
				ATail(aCols)[nPOSDESFR] := NGSEEK("ST9",TVP->TVP_CODBEM,1,"ST9->T9_NOME")
				ATail(aCols)[nPOSHORAB] := '  :  '
				ATail(aCols)[nPOSHODOM] := 0
				ATail(aCols)[nPOSQUANT] := 0

				dbSelectArea("TVP")
				dbSkip()
			EndDo

			oGLubrif:SetArray(aCols,.T.)
			oGLubrif:ForceRefresh()

			Return .T.
		Else
			Return .F.
		EndIf
	EndIf

	If  At('-',cFolha) > 0
		ShowHelpDlg(STR0088, { STR0089, "" }, 2,; //"INVALIDO"###"Numero da Folha inválido."
						{STR0111, ""}, 2) //"O campo Folha só poderá conter números"
		lRet := .F.
	EndIf

	If lRet
		lRet := MNTA656FOL( cPosto, cLoja, cFolha)
	EndIf

	RestArea(aArea)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} f681ACor()
Foco na linha da GetDados

@author Marcos Wagner Junior
@since 10/08/2010
/*/
//---------------------------------------------------------------------
Static Function f681ACor()

	Local cColor

	Do Case

		Case ATail( oGLubrif:aCols[oGLubrif:nAt] )
			cColor := CLR_HGRAY

		Case oGLubrif:nAt == nLinGet01
			cColor := CLR_YELLOW

		OtherWise
			cColor := CLR_WHITE

	EndCase

Return cColor

//---------------------------------------------------------------------
/*/{Protheus.doc} fVldCompon()
Foco na linha da GetDados

@param cVerBemPai (Obrigatorio): quando na chamada recursiva;
			Indica o codigo do Bem Pai.

@param cVerCompon (Obrigatório): quando na chamada recursiva;
			Indica o codigo do Componente analisado.

@param cVerHora (Obrigatório): quando na chamada recursiva;
			Indica a Hora do contador analisado.

@param nVerContad (Obrigatório): quando na chamada recursiva;
			Indica o Contador do componente analisado.

@param lBloqueia (Opcional) - Default: .T.;
			Define se quando tiver inconsistenca deve retornar .F.,
			impedindo o cadastro, sendo utilizado .T. para bloquear.

@return Lógico Indica se contador é ou não válido sendo .T. p/ válido.

@author Wagner S. de Lacerda
@since 13/01/2012
/*/
//---------------------------------------------------------------------
Static Function fVldCompon(cVerBemPai, cVerCompon, cVerHora, nVerContad, lBloqueia)

	Local aArea4 := {}

	Local aCols    := aClone( oGLubrif:aCols )
	Local aBensPai := {}, aComponent := {}
	Local cBemPai  := "", cBemCompon := ""
	Local aRet := {.T., "", "", "", 0, "", 0}
	Local nPai := 0, nComp := 0

	Local cMsgErro := ""

	Default cVerBemPai := ""
	Default cVerCompon := ""
	Default cVerHora   := ""
	Default nVerContad := 0
	Default lBloqueia  := .T.

	dbSelectArea(cAliasDet)

	aArea4 := GetArea()

	//Apenas altera o cursor na primeira chamada da funcao (se for recursiva, nao altera)
	If Empty(cVerBemPai)
		CursorWait()
	EndIf

	//------------------------------------------------------------
	//Recebe os Bens Pai
	//------------------------------------------------------------
	If Empty(cVerBemPai)

		//------------------------------------------------------------
		//Recebe os Bens Pais (veiculos)
		//------------------------------------------------------------
		For nPai := 1 To Len(aCols)
			If !ATail(aCols[nPai]) .And. !Empty(aCols[nPai][nPOSFROTA]) .And. aScan(aBensPai, {|x| x[1] == aCols[nPai][nPOSFROTA] }) == 0
				cBemPai    := aCols[nPai][nPOSFROTA]
				aComponent := {}

				dbSelectArea(cAliasDet)
				dbSetOrder(1)
				If dbSeek(cBemPai)
					While !Eof() .And. AllTrim((cAliasDet)->CODBEM) == AllTrim(cBemPai)

						If aScan(aComponent, {|x| x == (cAliasDet)->COMPON }) == 0
							aAdd(aComponent, (cAliasDet)->COMPON)
						EndIf

						dbSelectArea(cAliasDet)
						dbSkip()
					EndDo
				EndIf

				aAdd(aBensPai, {cBemPai, aComponent})
			EndIf
		Next nPai
	Else
		aBensPai := { {cVerBemPai, {cVerCompon}} }
	EndIf

	//------------------------------------------------------------
	// Valida Componentes
	//------------------------------------------------------------
	For nPai := 1 To Len(aBensPai)

		cBemPai := aBensPai[nPai, 1]

		If !aRet[1]
			Exit
		EndIf

		For nComp := 1 To Len( aBensPai[nPai, 2] )

			cBemCompon := aBensPai[nPai][2][nComp]

			If !aRet[1]
				Exit
			EndIf

			dbSelectArea("ST9")
			dbSetOrder(1)
			If dbSeek(cBemCompon) .And. ST9->T9_TEMCONT <> "P"

				dbSelectArea(cAliasDet)
				dbSetOrder(1)
				If dbSeek(cBemPai + cBemCompon)

					If Empty(cVerBemPai)

						//------------------------------------------------------------
						//Verifica o contador com outros reportes para o mesmo bem
						//------------------------------------------------------------
						aRet := aClone( fVldCompon((cAliasDet)->CODBEM, (cAliasDet)->COMPON, (cAliasDet)->HORPAI, (cAliasDet)->HODOM) )

					Else

						While !EoF() .And. aRet[1] .And. AllTrim((cAliasDet)->CODBEM) == AllTrim(cBemPai) .And. AllTrim((cAliasDet)->COMPON) == AllTrim(cVerCompon)

							dbSelectArea("ST9")
							dbSetOrder(1)
							If dbSeek(cBemCompon) .And. ST9->T9_TEMCONT <> "P"

								//Se a hora analisada for MENOR, o contador tambem deve ser menor
								If cVerHora < (cAliasDet)->HORPAI

									If nVerContad >= (cAliasDet)->HODOM
										aRet[1] := .F.
									EndIf

								ElseIf cVerHora > (cAliasDet)->HORPAI //Se a hora analisada for MAIOR, o contador tambem deve ser maior

									If nVerContad <= (cAliasDet)->HODOM
										aRet[1] := .F.
									EndIf

								Else //Se a hora analisada for IGUAL (pode ate ser o mesmo registro), o contador tambem deve ser igual

									If nVerContad <> (cAliasDet)->HODOM
										aRet[1] := .F.
									EndIf

								EndIf
							EndIf

							//-----------------------------------------------------
							//Adiciona onde o erro foi encontrado
							//-----------------------------------------------------
							If !aRet[1]
								aRet[2] := cVerBemPai
								aRet[3] := cVerCompon
								aRet[4] := cVerHora
								aRet[5] := nVerContad
								aRet[6] := (cAliasDet)->HORPAI
								aRet[7] := (cAliasDet)->HODOM
							EndIf

							dbSelectArea(cAliasDet)
							dbSkip()
						EndDo
					EndIf
				EndIf
			EndIf
		Next nComp
	Next nPai

	//--------------------------------------------------------------------------------------------
	//Apenas altera o cursor na primeira chamada da funcao (se for recursiva, nao altera)
	//Tambem mostra a mensagem caso haja
	//--------------------------------------------------------------------------------------------
	If Empty(cVerBemPai)

		CursorArrow()

		If !aRet[1]

			cMsgErro := STR0104+" '" + AllTrim(aRet[2]) + "'."//"Não confirmidade para o componente do Bem"
			cMsgErro += CRLF + CRLF + STR0041+": " + AllTrim(aRet[3])//"Componente"
			cMsgErro += CRLF + " "+STR0027+": " + aRet[4] + " | "+STR0028+": " + Transform(aRet[5], X3Picture("TQN_HODOM"))//"Hora"###"Contador"
			cMsgErro += CRLF + " "+STR0027+": " + aRet[6] + " | "+STR0028+": " + Transform(aRet[7], X3Picture("TQN_HODOM"))//"Hora"###"Contador"

			If lBloqueia

				ShowHelpDlg(STR0007, { cMsgErro }, 6, { STR0102 }, 3)

				//"ATENÇÃO" -> "Favor alterar o contador do componente citado para o veículo, ou então retirar a Indicação de componentes."
			Else

				aRet[1] := .T.
				MsgInfo(cMsgErro + CRLF + CRLF + STR0103, STR0007)

				//"ATENÇÃO" -> "Esta divergência deverá ser corrigida para que o cadastro possa ser efetuado!"
			EndIf

			oGLubrif:oBrowse:SetFocus()
			&( oGLubrif:oBrowse:bGotFocus )
		EndIf
	EndIf

	RestArea(aArea4)

Return aRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT681PLAC()
Verifica se a placa informada é válida.

@return lRet Indica se a placa é válida ou não.

@author Marcos Wagner Junior
@since  30/01/2012
/*/
//---------------------------------------------------------------------
Function MNT681PLAC()

	Local lRet

	//---------------------------------------------------------------------
	// Se a placa (TQN) estiver em branco, verifica se a placa do bem está
	// preenchida e limpa-a.
	//---------------------------------------------------------------------
	If !( lRet := !Empty(M->TQN_PLACA) )

		If !Empty( oGLubrif:aCols[oGLubrif:nAt, nPosFrota] )

			dbSelectArea("ST9")
			dbSetOrder(16)
			If dbSeek( oGLubrif:aCols[oGLubrif:nAt, nPosFrota] ) .And. !Empty(ST9->T9_PLACA)

				oGLubrif:aCols[oGLubrif:nAt, nPosPlaca] := M->TQN_PLACA := ST9->T9_PLACA

			EndIf
		EndIf
	Else
		//---------------------------------------------------------------------
		// Se a placa (TQN) estiver preenchida, verifica se a placa informada
		//  existe no cadastro do bem.
		//---------------------------------------------------------------------
		dbSelectArea("ST9")
		dbSetOrder(14)
		If !( lRet := dbSeek(M->TQN_PLACA) )

			oGLubrif:aCols[oGLubrif:nAt, nPosFrota] := Space( TAMSX3("T9_CODBEM")[1] )
			oGLubrif:aCols[oGLubrif:nAt, nPosDesFr] := Space( TAMSX3("T9_NOME")[1] )

			Help(" ", 1, STR0007, Nil, STR0105, 1, 0) //"ATENÇÃO" ## "A Placa selecionada é inválida."
		EndIf
	EndIf
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} NZERABAS()
Nao permite que seja zerado(Qtd) um registro que ja gravado

@author Marcos Wagner Junior
@since 01/07/2010
/*/
//---------------------------------------------------------------------
Function NZERABAS()
	Local lRet := .t.
	Local nPOSOLD := aScan(aOldCols,{|x| x[nPOSHORAB]+x[nPOSFROTA] == aCols[n][nPOSHORAB]+aCols[n][nPOSFROTA] })

	dbSelectArea("ST9")
	dbSetOrder(16)
	DbSeek(aCols[n][nPOSFROTA])
	If !Empty(M->TQN_QUANT)
		If M->TQN_QUANT > If(nCapTan <> 0 ,nCapTan,ST9->T9_CAPMAX)
			HELP(" ",1,STR0007,,STR0096+Chr(10)+Chr(13)+STR0097+STR0098+AllTrim(Str(IIf(nCapTan <> 0 ,nCapTan,ST9->T9_CAPMAX)))+STR0099,3,1) //"ATENÇÃO"###"Quantidade de combustivel supera a Capaci-"###"dade maxima "###"("###")."
			lRet := .f.
		EndIf
	EndIf

	If lRet .And. Altera .And. nPOSOLD > 0
		If aOldCols[nPOSOLD][nPOSQUANT] > 0 .And. M->TQN_QUANT == 0
			MsgStop(STR0100,STR0007) //"A quantidade não pode ser igual a zero, pois o abastecimento já foi gravado!"###"ATENÇÃO"
			Return .F.
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fLostFLub
Efetua gravação do aCols para perda de foco da get dados de
lubrificação do bem pai

@author André Felipe Joriatti
@since 16/12/2013
/*/
//---------------------------------------------------------------------
Static Function fLostFLub()

	// Grava aCols das get dados do cadastro
	GravaaCols()
	ChangeGet1(.F.)

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT681LUB()
Gera O.S. corretiva do lubrificante

@author Marcos Wagner Junior
@since 20/10/08
/*/
//---------------------------------------------------------------------
Static Function MNT681LUB(cFrota, cServ, cProdLub, nQtdLub, dDtLub, cHrLub, nPosCont, nX,  cAlmoxarifado, _nCusto, cFil, cMoeda)

	Local lMMoeda  	:= NGCADICBASE("TL_MOEDA","A","STL",.F.)
	Local _cAlmoxa
	Local cRetOk 	:= " "

	Default cFil	 := xFilial( "ST9" )
	Default cMoeda := "1"

	Private cVerific := IIf( NGVerify("STJ"), "0", 0 )

	_cAlmoxa := IIf( FunName() == "MNTA656", oBrw1:aCols[nX, nPosAlmox], cAlmoxarifado )

	aRetornoOS := NGGeraOS('C', dDtLub, cFrota, cServ, cVerific, 'N', 'N', 'N')

	If aRetornoOS[1, 1] == 'N'

		MsgStop(aRetornoOS[1, 2], STR0007) //"ATENÇÃO"

	Else
		If lRastr
			NGRetIns( aRetornoOS[1, 3], "000000", "C", " ", " ", " ", "0", "P", cProdLub, nQtdLub, NGSEEK('SB1', cProdLub, 1, 'SB1->B1_UM'),;
				"T", STR0051, dDtLub, cHrLub, "F", _cAlmoxa, oBrw1:aCols[nX, nPosLote],; //"Consumo Lubrificante"
				oBrw1:aCols[nX, nPosSubLo], oBrw1:aCols[nX, nPosDtVal], oBrw1:aCols[nX, nPosLocal])
		Else
			NGRetIns( aRetornoOS[1, 3], "000000", "C", " ", " ", " ", "0", "P", cProdLub, nQtdLub, NGSEEK('SB1', cProdLub, 1, 'SB1->B1_UM'),;
				"T", STR0051, dDtLub, cHrLub, 'F', _cAlmoxa,,,,)  //"Consumo Lubrificante"
		EndIf

		dbSelectArea("STJ")
		dbSetOrder(1)
		If dbSeek( xFilial("STJ") + aRetornoOS[1, 3] + "000000" )
			RecLock("STJ", .F.)
			STJ->TJ_SEQRELA := '000'
			STJ->TJ_DTORIGI := dDtLub
			STJ->TJ_HORACO1 := cHrLub
			STJ->TJ_POSCONT := nPosCont
			STJ->TJ_USUARIO := IIf( Len(STJ->TJ_USUARIO) > 15, cUsername, Substr(cUsuario, 7, 15) )
			STJ->TJ_DTMPINI := dDtLub
			STJ->TJ_HOMPINI := cHrLub
			STJ->TJ_DTMPFIM := dDtLub
			STJ->TJ_HOMPFIM := cHrLub
			STJ->TJ_CONTINI := nPosCont
			STJ->TJ_USUAINI := STJ->TJ_USUARIO
			STJ->( MsUnlock() )
		EndIf

		//----------------------------------------------------------------------------
		// Deve estar posicionado no SD3 ( Movimentação Interna ), para que usuário
		// possa manipular o registro, este é o objetivo do PE.
		//----------------------------------------------------------------------------
		If cIntMntEst == "S" // Apenas caso esteja integrado com estoque

			dbSelectArea( "SD3" )

			If ExistBlock( "MNT655D3CC" )
				ExecBlock( "MNT655D3CC" , .F., .F., { 'RE0', cFrota, STJ->TJ_CCUSTO, cFil } )
			EndIf
		EndIf

		dbSelectArea("STL")
		dbSetOrder(1)
		If dbSeek(xFilial("STL") + aRetornoOS[1, 3] + "000000")
			While !EoF() .And. STL->TL_FILIAL == xFilial("STL") .And. STL->TL_ORDEM == aRetornoOS[1, 3] .And. STL->TL_PLANO == "000000"

				If AllTrim(STL->TL_CODIGO) == AllTrim(cProdLub)

					Reclock("STL", .F.)

					STL->TL_USACALE := "N"
					STL->TL_GARANTI := "N"

					If cIntMntEst == 'S'

						STL->TL_NUMSEQ  := SD3->D3_NUMSEQ
						STL->TL_CUSTO   := SD3->D3_CUSTO1

						If lMMoeda
							STL->TL_MOEDA  := "1"
						EndIf
					Else
						STL->TL_CUSTO   := IIf( ValType(_nCusto) == 'N', _nCusto, STL->TL_CUSTO)

						If lMMoeda
							STL->TL_MOEDA  := IIf( ValType(_nCusto) == 'N', cMoeda, STL->TL_MOEDA)
						EndIf
					EndIf

					STL->TL_NOTFIS  := cFolha
					STL->TL_LOCAL   := _cAlmoxa

					If nPosLote > 0
						STL->TL_LOTECTL := aCols[nX, nPOSLOTE]
						STL->TL_NUMLOTE := aCols[nX, nPOSSUBLO]
						STL->TL_DTVALID := aCols[nX, nPOSDTVAL]
						STL->TL_LOCALIZ := aCols[nX, nPOSLOCAL]
						STL->TL_NUMSERI := aCols[nX, nPOSNUMSE]
					EndIf

					If NGCADICBASE("TL_FORNEC", "A", "STL", .F.)
						STL->TL_FORNEC := cPosto
						STL->TL_LOJA   := cLoja
					EndIf

					STL->( MsUnlock() )
				EndIf

				dbSelectArea("STL")
				dbSkip()
			EndDo
		EndIf

		NGFinal( STJ->TJ_ORDEM, STJ->TJ_PLANO, STJ->TJ_DTPRINI, STJ->TJ_HOPRINI,;
			STJ->TJ_DTPRFIM, STJ->TJ_HOPRFIM, 0, 0, cFrota, STJ->TJ_HORACO1, STJ->TJ_HORACO2 )

		cRetOk := aRetornoOS[1,3]
	EndIf

Return cRetOk

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTABASTENC()
Valida os abastecimentos com relacao a data e hora da folha

@author Marcos Wagner Junior
@since 05/12/2018
/*/
//---------------------------------------------------------------------
Function MNTABASTENC(nPar)

	Local i, nPosReg, cHora, dData

	Local lAbastLote := .F. //Lote
	Local lAferSaida := .F. //Aferição/Saída
	Local lRegDupl   := .F.

	If nPar == 2

		If M->TQN_HRABAS > cHrAb656
			MsgStop(STR0112,STR0007) //"Hora do Abastecimento não pode ser maior que a hora de encerramento da folha."###"ATENÇÃO"
			Return .f.
		EndIf

		//---------------------------------------------------------------------
		//Verifica se há mais de um abastecimento no mesmo horário
		//---------------------------------------------------------------------
		If (nPosReg := aScan(oGLubrif:aCols, {|x| !ATail(x) .And. x[nPosHoraB] == M->TQN_HRABAS })) > 0
			If ( lRegDupl := IIf( nPosReg <> oGLubrif:nAt, .T., ;
										aScan(oGLubrif:aCols, {|x| !ATail(x) .And. x[nPosHoraB] == M->TQN_HRABAS}, nPosReg + 1) > 0 ) )

				MsgStop(STR0113,STR0007) //"Hora do Abastecimento não pode ser igual ao já existente na folha." ## "ATENÇÃO"
				Return .f.
			EndIf
		EndIf

		dData := dDataAbast
		cHora := M->TQN_HRABAS

	EndIf

	If !Empty(cPosto) .And. !Empty(cLoja) .And. !Empty(cTanque) .And. ;
			!Empty(cBomba) .And. !Empty(dData) .And. !Empty(CHora)

		If Inclui

			Inclui := .F.

			//Verifica se há reporte de contador de abastecimento em lote após data
			If NGVDHBomba(cPosto,cLoja,cTanque,cBomba,dData,cHora,"'2'")
				lAbastLote := .T.
			EndIf

			//Verifica se há reporte de contador de aferição/saída após data
			If NGVDHBomba(cPosto,cLoja,cTanque,cBomba,dData,cHora,"'3'")
				lAferSaida := .T.
			EndIf

			//Verifica se houve algum reporte após a data do abastecimento
			If lAbastLote .Or. lAferSaida

				Do Case
					// Verifica se existe tanto um abastecimento em lote quanto uma aferição/saída após a data do abastecimento
					Case lAbastLote .And. lAferSaida

						ShowHelpDlg(STR0007, { STR0114 }, 3, { STR0115 }, 3)

						//"Já existe um Abastecimento em Lote e Aferição(ões) de Bomba(s)/Saída(s) de Combustível com data/hora superior a informada."
						//"Exclua os Abastecimento em Lote e as Aferições/Saídas cadastradas com data/hora superior ou altere a data/hora deste abastecimento."

					//Verifica se há um abastecimento em lote após a data do abastecimento
					Case lAbastLote

						ShowHelpDlg(STR0007, { STR0116 }, 3, { STR0117 }, 3)

						//"Já existe um Abastecimento(s) em Lote de Combustível com data/hora superior a informada."
						//"Exclua os Abastecimento em Lote cadastrados com data/hora superior ou altere a data/hora deste abastecimento."

					//Se for aferição/saída
					Case lAferSaida

						ShowHelpDlg(STR0007, { STR0118 }, 3, {STR0119}, 3)

						//"Já existe Aferição(ões) de Bomba(s)/Saída(s) de Combustível com data/hora superior a informada."
						//"Exclua as Aferições/Saídas cadastradas com data/hora superior ou altere a data/hora deste abastecimento."
				EndCase

				Inclui := .T.

				Return .F.
			EndIf

			Inclui := .T.
		EndIf
	EndIf

Return .T.

//-----------------------------------------------------------------------
/*/{Protheus.doc} fValInit
Verifica se os requisitos iniciais para utilização da rotina são atendidos

@return lRet Indica se a rotina pode ou não ser utilizada

@author Pedro Henrique Soares de Souza
@since 21/08/2015
/*/
//-----------------------------------------------------------------------
Static Function fValInit()

	Local lRet		:= .F.
	Local cCpfMot	:= GetNewPar("MV_NGMOTGE", "")

	Do Case

		Case NGSX2Modo("TTA") == 'C'

			MsgStop(STR0006,STR0007) //"Para funcionamento da rotina a tabela TTA deverá ser exclusiva!" ## "ATENÇÃO"

		Case Empty(cCpfMot)

			MsgStop(STR0008, STR0007) //"Para funcionamento da rotina o parâmetro MV_NGMOTGE deverá estar preenchido!" ## "ATENÇÃO"

		OtherWise

			dbSelectArea("DA4")
			dbSetOrder(03)
			If !( lRet := dbSeek(xFilial("DA4") + cCpfMot) )
				MsgStop(STR0009 + AllTrim(cCpfMot) + '!', STR0007) //"Para funcionamento da rotina deverá ser cadastrado um motorista com o CPF: "###"ATENÇÃO"
			EndIf

	EndCase

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} MNTA681WHD
Carrega when padrão dos campos de abastecimento

@return lRet Indica se o campo deve será ou não bloqueado

@author Pedro Henrique Soares de Souza
@since 09/09/2015
/*/
//-----------------------------------------------------------------------
Function MNTA681WHD()

	Local lRet

	Do Case

		Case ReadVar() == 'M->TQN_QUANT'
			lRet := IIF(FunName()=='MNTA656',!lTpLub,.t.) .AND. MNT656CONC()

		Case ReadVar() == 'M->TQN_HODOM'
			lRet := !( Empty( aCols[n, nPosHoraB] ) .Or. aCols[n, nPosHoraB] == '  :  ' )

		OtherWise
			lRet := IIf( FunName() == 'MNTA656', lTrava656, .T. )

	EndCase

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} MNTA681VAL
Carrega valid padrão dos campos de abastecimento

@return lRet Indica se a conteúdo do campo é ou não válido.

@author Pedro Henrique Soares de Souza
@since 10/09/2015
/*/
//-----------------------------------------------------------------------
Function MNTA681VAL()

	Local lRet
	Local cValidFld, cValid := '.T.'

	Do Case

		Case ReadVar() == 'M->TQN_HRABAS'

			If !Empty( cValidFld := NGSeekDic('SX3', 'TQN_HRABAS', 2, 'X3_VALID') )
				cValid := AllTrim(cValidFld) + " .And. MNT681DUPL(1) .And. MNTABASTENC(2)"
				cValid := StrTran(cValid, "MNA655CV('HR')", "MNA655CV('HR',.F.)")
			EndIf

			lRet := M->TQN_HRABAS == '  :  ' .Or. &(cValid)

			//Limpa campo contador caso a hora seja alterada
			If ( M->TQN_HRABAS == '  :  ' .Or. Empty(M->TQN_HRABAS) )
				aCols[n, nPosHodom] := 0
			Else
				// Habilita reporte de segundo contador
				//FindFunction remover na release GetRPORelease() >= '12.1.027'
				If FindFunction("MNTCont2")
					TIPOACOM2 := MNTCont2(xFilial('TPE', cCodObra ), oGLubrif:aCols[ oGLubrif:nAt, nPOSFROTA ] )
				Else
					TIPOACOM2 := Posicione( 'TPE', 1, xFilial('TPE', cCodObra ) + oGLubrif:aCols[ oGLubrif:nAt, nPOSFROTA ], 'TPE_SITUAC' ) == '1' //dbSeek( xFilial('TPE', cCodObra ) + M->TQN_FROTA ) .And. TPE->TPE_SITUAC == "1"
				EndIf
			EndIf

			If lRet
				dbSelectArea("TTV")
				dbSetOrder(1) //TTV_FILIAL+TTV_POSTO+TTV_LOJA+TTV_TANQUE+TTV_BOMBA+DTOS(TTV_DATA)+TTV_HORA+TTV_NABAST
				If dbSeek( cCodObra + cPosto + cLoja + cTanque + cBomba + DtoS(dDataAbast) + M->TQN_HRABAS )
					ShowHelpDlg(STR0007, { STR0129 }, 1,;//"ATENCAO" ## "Já existe lançamento para este posto, loja, tanque, bomba, data e hora do abastecimento."
							{ STR0130}, 1)  //"Informar o lançamento que não possua registro já gravado para o posto, loja, bomba, data e hora do abastecimento."
					lRet := .F.
				EndIf
			EndIf

		OtherWise
			lRet := .T.

	EndCase

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} MNT681Del
Deleta a folha de abastecimento

@param 	nRecno, Numérico, Recno da TTA que será deletada
@author Tainã Alberto Cardoso
@since 26/02/2019
/*/
//-----------------------------------------------------------------------
Static Function MNT681Del( nRecno )

	Local cNumSeqD  := ''
	Local cFilTQF   := ''
	Local cUM       := ''
	Local cComb     := ''
	Local cDocumSD3 := ''
	Local lRet      := .T.
	Local nI        := 0
	Local lMNT655D3 := ExistBlock("MNT655D3CC")
	Local lNGUTIL4C := ExistBlock("NGUTIL4C")

	Begin Transaction
		//Primeiro é deletado as movimentações de estoque para ter controle de transação
		For nI := 1 to Len(oGLubrif:aCols)

			dbSelectArea("TQN")
			dbSetOrder(01)
			If dbSeek(xFilial("TQN", cCodObra) + oGLubrif:aCols[nI][nPOSFROTA] + DToS(dDataAbast) + oGLubrif:aCols[nI, nPosHoraB])

				cFilTQF := MNT655FTQF(TQN->TQN_DTABAS,TQN->TQN_NUMSEQ,TQN->TQN_QUANT)

				If !Empty(TQN->TQN_NUMSEQ)
					cUM       := NGSEEK('TQM', TQN->TQN_CODCOM,1,'TQM->TQM_UM',cFilTQF)
					cComb	  := NGSEEK('TQI', TQN->TQN_POSTO + TQN->TQN_LOJA+ TQN->TQN_TANQUE + TQN->TQN_CODCOM, 1,'TQI->TQI_PRODUT', cFilTQF)
					cDocumSD3 := NGSEEK('SD3', TQN->TQN_NUMSEQ + 'E0', 4,'SD3->D3_DOC', cFilTQF)

					cNumSeqD := NgMovEstoque('DE0',TQN->TQN_TANQUE,cComb,TQN->TQN_NUMSEQ,cUM,TQN->TQN_QUANT,TQN->TQN_DTABAS,cDocumSD3,;
											 TQN->TQN_CCUSTO,cFilTQF,TQN->TQN_FROTA)

					If Empty(cNumSeqD)
						DisarmTransaction()
						lRet := .F.
						Exit
					EndIf

					dbSelectArea("ST9")
					dbSetOrder(16)
					dbSeek(oGLubrif:aCols[nI,nPOSFROTA])
					//P.E. para alteções finais no SD3
					If lRet .And. lMNT655D3
						ExecBlock("MNT655D3CC", .F. , .F. , {'DE0', ST9->T9_CODBEM, ST9->T9_CCUSTO, ST9->T9_FILIAL })
					EndIf

				EndIf
			EndIf

		Next

		If lRet
			//Deleta por ultimo os contadores pois é criado tabela temporária que confirma o controle de transação
			For nI := 1 to Len(oGLubrif:aCols)

				dbSelectArea("TQN")
				dbSetOrder(01)
				If dbSeek(xFilial("TQN", cCodObra) + oGLubrif:aCols[nI][nPOSFROTA] + DToS(dDataAbast) + oGLubrif:aCols[nI, nPosHoraB])

					dbSelectArea("STP")
					dbsetorder(5)
					If dbSeek(xFilial("STP",cCodObra) + TQN->TQN_FROTA + DToS(TQN->TQN_DTABAS) + TQN->TQN_HRABAS)

						nRECNSTP := Recno()
						lULTIMOP := .T.
						nACUMFIP := 0
						nCONTAFP := 0
						nVARDIFP := 0
						dDTACUFP := StoD('')
						cHRACU   := "  :  "

						dbSkip(-1)

						If !EoF() .And. !BoF() .And. STP->TP_CODBEM == xFilial("STP",cCodObra) .And. STP->TP_DTLEITU == TQN->TQN_FROTA
							nACUMFIP := STP->TP_ACUMCON
							dDTACUFP := STP->TP_DTLEITU
							nCONTAFP := STP->TP_POSCONT
							nVARDIFP := STP->TP_VARDIA
							cHRACU	 := STP->TP_HORA
						EndIf
						dbGoTo(nRECNSTP)

						nACUMDEL := STP->TP_ACUMCON

						dbSelectArea("STP")

						RecLock("STP",.F.)
						dbDelete()
						MsUnlock()

						//Arrays utilizados na função MNTA875ADEL
						aARALTC :=  {'STP','STP->TP_FILIAL','STP->TP_CODBEM',;
										'STP->TP_DTLEITU','STP->TP_HORA','STP->TP_POSCONT',;
										'STP->TP_ACUMCON','STP->TP_VARDIA','STP->TP_VIRACON'}

						aARABEM := {'ST9','ST9->T9_POSCONT', 'ST9->T9_CONTACU',;
										'ST9->T9_DTULTAC', 'ST9->T9_VARDIA'}

						MNTA875ADEL(TQN->TQN_FROTA,TQN->TQN_DTABAS,TQN->TQN_HRABAS,1,cCodObra,cCodObra)

						If lNGUTIL4C
							ExecBlock("NGUTIL4C", .F., .F., {TQN->TQN_FROTA, dDTACUFP, cHRACU, nCONTAFP, nACUMFIP})
						EndIf
					EndIf

					//Referentes ao segundo contador
					If lSegCont
						dbSelectArea("TPE")
						dbSetOrder(1)
						If dbSeek(xFilial("TPE",cCodObra) + TQN->TQN_FROTA)
							If TPE->TPE_SITUAC == "1"

								dbSelectArea('TPP')
								dbSetOrder(5)
								If dbSeek(xFilial('TPP', cCodObra) + TQN->TQN_FROTA + DToS(TQN->TQN_DTABAS) + TQN->TQN_HRABAS)

									nRECNSTP := Recno()
									lULTIMOP := .T.
									nACUMFIP := 0
									nCONTAFP := 0
									nVARDIFP := 0
									dDTACUFP := StoD('')
									cHRACU   := "  :  "

									dbSkip(-1)

									If !EoF() .And. !BoF() .And. TPP->TPP_FILIAL == xFilial('TPP',cCodObra) .And.;
											TPP->TPP_CODBEM == TQN->TQN_FROTA
										nACUMFIP := TPP->TPP_ACUMCO
										dDTACUFP := TPP->TPP_DTLEIT
										nCONTAFP := TPP->TPP_POSCON
										nVARDIFP := TPP->TPP_VARDIA
										cHRACU	 := TPP->TPP_HORA
									EndIf

									dbGoTo(nRECNSTP)

									nACUMDEL := TPP->TPP_ACUMCO

									dbSelectArea('TPP')

									RecLock('TPP',.F.)
									dbdelete()
									MsUnlock()

									//Arrays utilizados na função MNTA875ADEL
									aARALTC := {'TPP','TPP->TPP_FILIAL','TPP->TPP_CODBEM','TPP->TPP_DTLEIT','TPP->TPP_HORA',;
												'TPP->TPP_POSCON','TPP->TPP_ACUMCO','TPP->TPP_VARDIA','TPP->TPP_VIRACO'}

									aARABEM := {'TPE','TPE->TPE_POSCON','TPE->TPE_CONTAC','TPE->TPE_DTULTA','TPE->TPE_VARDIA'}

									MNTA875ADEL(TQN->TQN_FROTA,TQN->TQN_DTABAS,TQN->TQN_HRABAS,2,cCodObra,cCodObra)

									If lNGUTIL4C
										ExecBlock("NGUTIL4C",.F.,.F.,{TQN->TQN_FROTA,dDTACUFP,cHRACU,nCONTAFP,nACUMFIP})
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf

					//----------------------------------------
					//Deleta historico do contador da Bomba
					//----------------------------------------
					NGDelTTVAba(TQN->TQN_NABAST)

					dbSelectArea("TQN")

					TQN->( RecLock("TQN", .F.) )
					TQN->( dbDelete() )
					TQN->( MsUnlock() )
				EndIf
			Next

			dbSelectArea("TTA")
			dbGoTo(nRecno)
			TTA->( RecLock("TTA",.F.) )
			TTA->( dbDelete() )
			TTA->( MsUnlock())

		EndIf

	End Transaction

Return
