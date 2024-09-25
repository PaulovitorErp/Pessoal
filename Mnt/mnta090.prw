#INCLUDE "MNTA090.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "DBTREE.CH"
#Include "FWADAPTEREAI.CH" // Integração via Mensagem Única

#DEFINE _POS_PAI_ 1
#DEFINE _POS_FIL_ 2
#DEFINE _POS_SEQ_ 3

Static aNGFilTemp := {} // variavel para armazenamento de filtro da funcao NGFilTemp
Static lRel12133  := GetRPORelease() >= '12.1.033'

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA090

Estrutura de Bem

@author	Paulo Pego
@version MP11 e MP12
@since 28/08/01
@source MNTA090
/*/
//---------------------------------------------------------------------
Function MNTA090(_cBem, _nOpc)

	Local nRECNO
	Local aNGBEGINPRM
	Local nIndx, nFld, nPosDel
	Local aFldIdx := {}
	Local aExpDel := {"STR"}
	Local oBrowse

	Default _nOpc := 4

	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 19, 95 )

		aNGBEGINPRM := NGBEGINPRM() //Armazena variaveis p/ devolucao (NGRIGHTCLICK)

		Private lCorret,lALTURA1,lALTURA2,lALTURA3,lMENU
		Private cCODFAM,cModelo
		Private nOpcai,nOpcae
		Private lGFrota    := MNTA090FR()
		Private aRotina    := MenuDef(lGFrota)
		Private lTipMod    := lRel12133 .Or. lGFrota
		Private lSH1       := .F.
		Private aGETS      := {}
		Private aTrocaF3   := {}
		Private aArrFilter := {}
		Private cPrograma  := "MNTA090"

		Private oMenu
		Private cCADASTRO := OEMTOANSI(STR0001) //"Estruturas"

		// Declaracao obrigatoria.. usada no dicion rio e fun‡oes que sao chamadas
		Private cBEMRET := Space(Len(stj->tj_codbem))
		Private lStatus := NGCADICBASE('TQY_STATUS','A','TQY',.F.)
		Private cStatus := If(lStatus,Space(Len(ST9->T9_STATUS)),Space(2))

		//Alias da TRB para montagem do browse
		Private oTmpTbl1
		Private cAliasSTC
		Private aDBFSTC   := {}
		Private lSequeSTC := NGCADICBASE( "TC_SEQUEN","A","STC",.F. ) //Verifica se existe o campo TC_SEQUEN no dicionário ou base dados.

		cAliasSTC := GetNextAlias()

		aAdd(aDBFSTC,{"TC_FILIAL","C", TAMSX3("TC_FILIAL")[1] ,0})
		aAdd(aDBFSTC,{"TC_CODBEM","C", TAMSX3("TC_CODBEM")[1] ,0})
		aAdd(aDBFSTC,{"TC_NOME"	 ,"C", TAMSX3("T9_NOME")[1]	,0})

		oTmpTbl1  := FWTemporaryTable():New( cAliasSTC, aDBFSTC )
		oTmpTbl1:AddIndex("1", {"TC_FILIAL", "TC_CODBEM"})
		oTmpTbl1:Create()

		Store .T. To lCorret,lMENU
		Store 0 To nOpcai,nOpcae

		M->TC_TIPOEST := "B"
		Dbselectarea("SX3")
		Dbsetorder(2)
		lALTURA1 := If(Dbseek("TC_ALTURA"),.T.,.F.)
		lALTURA2 := IF(Dbseek("TZ_ALTENT"),.T.,.F.)
		lALTURA3 := If(Dbseek("TZ_ALTSAI"),.T.,.F.)
		Dbsetorder(1)

		Dbselectarea("STC")
		nRECNO := RECNO()
		Dbsetorder(1)

		fLoadFiltro()
		dbselectarea(cAliasSTC)
		dbseek(xFILIAL('STC'))

		//Endereca a funcao de BROWSE
		aFIELD := {{STR0007,"TC_CODBEM","C", TAMSX3("TC_CODBEM")[1] , 0, "@!"},; //"Bem"
				{STR0008,"TC_NOME"  ,"C", TAMSX3("T9_NOME")[1]	, 0,"@!"}}  //"Nome"


		//Restaura Area de trabalho.
		If _cBem <> Nil
			If STC->(Dbseek(xFilial("STC")+_cBem))
				NG090PROCES('STC',STC->(Recno()), _nOpc,, _cBem)
			Else
				MsgInfo( STR0109, STR0037 )//"Este bem não possui estrutura." ##ATENÇÂO
			EndIf
			Dbselectarea("STC")
			Dbsetorder(1)
			Return NIL
		EndIf

		//Realiza montagem do browser.
		oBrowse:= FWMBrowse():New()
		oBrowse:SetDescription(cCadastro) //Descrição do Browser.
		oBrowse:SetTemporary(.T.) //Determina que o Browser é criada sobre uma TRB.
		oBrowse:SetUseFilter(.F.) //Desabilitada a opção de filtro do Browser.
		oBrowse:SetAlias(cAliasSTC) //Alias da tabela.
		oBrowse:SetFields(aFIELD) //Campos que serão apresentados no Browser.
		oBrowse:Activate() //Ativação do Browser.

		Dbselectarea("STC")
		Dbsetorder(1)
		oTmpTbl1:Delete()
		dbCloseArea()

		//Devolve variaveis armazenadas (NGRIGHTCLICK)
		NGRETURNPRM(aNGBEGINPRM)

	EndIf

Return NIL

//---------------------------------------------------------------------
/*/{Protheus.doc} fLoadFiltro

Funcao que carrega vetor com itens para aplicar no filtro

@author	Felipe Nathan Welter
@since 08/04/11
@source MNTA090 (relacionada a NG090FILTRA)
/*/
//---------------------------------------------------------------------
Static Function fLoadFiltro()

	Local cQrySTC := ""
	Local aArea   := STC->(GetArea())

	If Select(cAliasSTC) > 0
		dbSelectArea(cAliasSTC)
		ZAP
	EndIf

	// Não mostra estrutura no browse caso ela também seja PARTE de outra estrutura
	cQrySTC := "INSERT INTO " + oTmpTbl1:GetRealName() + "(TC_CODBEM, TC_FILIAL, TC_NOME)"
	cQrySTC += " SELECT DISTINCT STC.TC_CODBEM, STC.TC_FILIAL, ST9.T9_NOME FROM "+RetSqlName("STC")+" STC "
	cQrySTC += " JOIN "+RetSqlName("ST9")+" ST9 ON ST9.T9_CODBEM = STC.TC_CODBEM "
	If NGSX2MODO("ST9") == NGSX2MODO("STC")
		cQrySTC += " AND ST9.T9_FILIAL = STC.TC_FILIAL"
	Else
		cQrySTC += " AND ST9.T9_FILIAL = " + ValToSql(xFilial("ST9"))
	EndIf
	cQrySTC += " WHERE STC.TC_TIPOEST = 'B' AND STC.TC_FILIAL = " + ValToSql(xFilial("STC"))
	cQrySTC += " AND STC.TC_CODBEM NOT IN ( SELECT TC_COMPONE FROM " + RetSQLName( "STC" )
	cQrySTC += " WHERE TC_FILIAL = "+ ValToSql(xFilial("STC")) + " AND D_E_L_E_T_ <> '*' )"
	cQrySTC += " AND STC.D_E_L_E_T_ <> '*' AND ST9.D_E_L_E_T_ <> '*'"
	cQrySTC += " GROUP BY STC.TC_FILIAL, STC.TC_CODBEM, ST9.T9_NOME"
	cQrySTC += " ORDER BY STC.TC_FILIAL, STC.TC_CODBEM"

	TcSQLExec(cQrySTC)

	dbSelectArea("STC")
	Set Filter To
	STC->(RestArea(aArea))

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NG090FILTRA ³ Autor ³ Felipe Nathan Welter³ Data ³ 08/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Filtro para apresentacao dos pais das estruturas            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MNTA090 (dependente de fLoadFiltro())                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NG090FILTRA()
	Local aArea := GetArea()
	Local lOk
	lOk := UniqueKey({'TC_FILIAL','TC_CODBEM'},'STC') .And.;
	STC->TC_FILIAL = xFilial('STC') .And. TC_TIPOEST = 'B' .And.;
	(aSCan(aArrFilter,{|x| x == STC->TC_CODBEM}) > 0)
	//a alternativa de utilizar um vetor (fLoadFiltro) eh devido a impossibilidade
	//de se fazer uma busca dentro da propria STC dentro do filtro
	//por causa de um problema que ocorre no browse com duplicidades de registro
	RestArea(aArea)
Return lOk
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NG090PESQUI ³ Autor ³ Elisangela Costa    ³ Data ³ 19/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Faz pesquisa                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NG090PESQUI()

	Local oDlgPesq, oOrdem, oChave, oBtOk, oBtCan, oBtPar
	Local cOrdem
	Local cChave := Space(255)
	Local cAlias := "STC"
	Local nOrdem := 1
	Local nOpca
	Local aOrdens :={}

	//Pega Indice da tabela indicada.
	dbSelectArea("SIX")
	dbSetOrder(1)
	dbSeek(cAlias)
	While !Eof() .AND. SIX->INDICE == cAlias
		aAdd(aOrdens,Alltrim(SIX->DESCRICAO))
		dbSelectArea("SIX")
		dbSkip()
	End
	//Monta tela de pesquisa
	Define MsDialog oDlgPesq Title STR0010 From 00,00 To 100,500 PIXEL //"Pesquisa"

	@ 005, 005 ComboBox oOrdem Var cOrdem Items aOrdens Size 210,08 PIXEL OF oDlgPesq ON CHANGE nOrdem := oOrdem:nAt
	@ 020, 005 MsGet oChave Var cChave Size 210,08 of oDlgPesq PIXEL

	Define sButton oBtOk  from 05,218 Type 1 Action (nOpcA := 1, oDlgPesq:End()) Enable of oDlgPesq PIXEL
	Define sButton oBtCan from 20,218 Type 2 Action (nOpcA := 0, oDlgPesq:End()) Enable of oDlgPesq PIXEL
	Define sButton oBtPar from 35,218 Type 5 When .F. of oDlgPesq pixel

	Activate MsDialog oDlgPesq Center

	//Se confirma verifica a existencia da chave na tabela
	If nOpca == 1
		dbSelectArea(cAlias)//STC
		dbSetOrder(nOrdem)
		If dbSeek(xFilial("STC") + Alltrim(cChave)) .Or. dbSeek(Alltrim(cChave))
			dbSelectArea(cAliasSTC)//TRB
			dbGoTop()
			//Posiciona na tabela temporaria
			dbSeek((cAliasSTC)->(TC_FILIAL + (STC->TC_CODBEM)))
		EndIf
		If !Found()
			Help(" ",1,"PESQ01")
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} NG090PROCES

Programa de Processamento de Estrutura

@author	Paulo Pego
@since 28/05/98
@return boolean, se operação pode prosseguir
/*/
//---------------------------------------------------------------------
Function NG090PROCES(cALIAS,nRECNO,nOPC, oObjPai, _cBem)

	Local nREC,lRET,i
	Local oMenu
	Local cF3Bem    := Posicione( 'SX3', 2, 'TC_CODBEM', 'X3_F3' )
	Local cGERAPREV := AllTrim(GETMv("MV_NGGERPR"))
	Local nSizeCod  := If((TAMSX3("B1_COD")[1]) < 1,15,(TAMSX3("B1_COD")[1]))
	Local lObjPai   := ( ValType(oObjPai) == "O" )
	Local oTmpTbl2
	Local oTmpTbl3
	Local oTmpTbl4
	Local aSUB      := {OEMTOANSI(STR0010),; //"Pesquisa"
	OEMTOANSI(STR0011),; //"Visualização"
	OEMTOANSI(STR0012),; //"Inclusão"
	OEMTOANSI(STR0013),; //"Alteração"
	OEMTOANSI(STR0014)}  //"Exclusão"

	Local lValCont2 := .F.

	Default _cBem := ""

	Private cBEM2,cLOC1,cLOC2,cLOC3,cCCUSTO,cCCTRAB,cCALEND,cPROD,cNOMLOCA,;
	cCOMP,cALI,cRET,cSEQ                                             //strings
	Private dDATA1,dDATA2,dULTACOM,dOLDACOM,dDTIMPL                          //datas
	Private cHORALE1,cHORALE2                                                //horas
	Private TIPOACOM2,lTRB,lTREE                                             //logicos
	Private oTREE,ODlgStru, oLOC1, oLOC2, oLOC3 							 //objeto
	Private nCONTE1,nCONTE2,nPOSCONT,nPOSCONT2,nOLDCONT2,nOLDCONT,nFECHA     //Numeric
	Private cPAI
	Private nINIC
	Private oBtni
	Private aOrdStruct := {}
	Private cFIRST     := ""
	Private bFAMI      := {|x| ST9->(Dbseek(xFILIAL('ST9') + x)), ST9->T9_CODFAMI}
	Private nOPCAO     := nOPC
	Private aULTPECASR := {}
	Private aVETINR    := {}
	Private lEstPecR   := .T.
	Private AHEADER    := {}
	Private cPRODESC   := ""
	Private lCatBem    := NGCADICBASE('T9_CATBEM','A','ST9',.F.)

	Private cTRBSTC   := GetNextAlias() //Alias do oTmpTbl2
	Private cTRB2	  := GetNextAlias() //Alias do oTmpTbl3
	Private cTRBTPY	  := GetNextAlias() //Alias do oTmpTbl4
	Private lWhenCount:= .F. //Determina se campos de contador do bem serão habilitados para preenchimento

	Store .F. To TIPOACOM2,lTRB

	If Trim( cF3Bem ) == 'ST9' .Or. Empty( cF3Bem )

		/*---------------------------------------------------------+
		| Garante uso da consulta padrão atualizada para TC_CODBEM |
		+---------------------------------------------------------*/
		cF3Bem := 'ST9BVE'

	EndIf

	dbSelectArea("STC")
	dbSetOrder(1)
	If !Empty( _cBem ) //Caso chamdo pelo click da direita posiciona de acordo com o bem selecionado.
		dbSeek( xFilial( "STC" ) + _cBem )
	Else
		dbSeek((cAliasSTC)->(TC_FILIAL+TC_CODBEM))
	EndIf

	cPAI   := STC->TC_CODBEM
	cFIRST := STC->TC_CODBEM
	nINIC  := RECNO()

	If nOPC == 4
		If !NGOSREFORM( STC->TC_CODBEM )
			Return .F.
		Endif

		//---------------------------------------------------------------------------------
		// verifica se há pneus na estrutura com status aguardando marcação de fogo
		//---------------------------------------------------------------------------------
		If FindFunction( 'MNTAGFOGO' ) .And. !Empty( MNTAGFOGO( STC->TC_CODBEM ) )
			Return .F.
		EndIf

	ElseIf nOPC == 5
		If !NGOSREFORM( STC->TC_CODBEM ) .Or. !f090ValMr( STC->TC_CODBEM )
			Return .F.
		Endif
	EndIf

	Store 0 To nCONTE1,nCONTE2,nFECHA
	Store 0 TO nPOSCONT,nPOSCONT2,nOLDCONT2,nCONTE2,nOLDCONT
	Store Ctod("  /  /  ") To dDATA1,dDATA2,dULTACOM,dOLDACOM
	Store '  :  '          To cHORALE1,cHORALE2

	cSeq          := Space(Len(stc->tc_seqrela))
	M->TC_COMPONE := Space(Len(STC->TC_COMPONE))
	M->TC_LOCALIZ := Space(Len(STC->TC_LOCALIZ))

	cALI    := "ST9"
	cRET    := "ST9->T9_NOME"
	cTITULO := STR0015 + aSUB[nOPC] //"Cadastro de Estrutura de Bens "
	cDESC   := SPACE(40)

	Dbselectarea("ST9")
	Dbsetorder(1)
	If Dbseek(xFILIAL('ST9')+cFIRST) .And. (nOPC!= 3)
		cDESC   := ST9->T9_NOME
		dDTIMPL := ST9->T9_DTCOMPR
	Endif
	Dbselectarea("STC")

	//Define as colunas (Niveis) da estrutura
	//AHEADER := {}
	aCOLTAM := {}

	For I := 1 TO 50
		Aadd(aCOLTAM,16)
	Next

	//Cria Arquivo de Trabalho
	nTAM := Len(STC->TC_CODBEM)
	aDBF := STC->(DbStruct())
	Aadd(aDBF,{"TC_FAMBEM" ,"C",nTAM,0})
	Aadd(aDBF,{"TC_FAMCOMP","C",nTAM,0})
	Aadd(aDBF,{"TC_LOCBEM" ,"C",06  , 0})  //localizaao do bem (pai)
	Aadd(aDBF,{"TC_OK"     ,"C",01  ,0})
	Aadd(aDBF,{"TC_CCUSTO" ,"C",Len(SI3->I3_CUSTO),0})
	Aadd(aDBF,{"TC_CENTRAB","C",06  ,0})
	Aadd(aDBF,{"TC_CALENDA","C",03  ,0})
	Aadd(aDBF,{"TC_CONTAD1","N",09  ,0})
	Aadd(aDBF,{"TC_CONTAD2","N",09  ,0})
	Aadd(aDBF,{"TC_COMPNOV","C",01  ,0})
	Aadd(aDBF,{"TC_HORAIMP","C",05  ,0})
	Aadd(aDBF,{"TC_HORASAI","C",05  ,0})
	Aadd(aDBF,{"TC_CONT1AT","N",09  ,0})
	Aadd(aDBF,{"TC_CONT2AT","N",09  ,0})
	aAdd( aDbf, { 'TC_DATETPN', 'D', 08, 0 } )
	aAdd( aDbf, { 'NIVEL'     , 'N', 03, 0 } )
	If lStatus
		Aadd(aDBF,{"TC_STATUS","C",02,0})
	Endif

	//Intancia classe FWTemporaryTable
	oTmpTbl2  := FWTemporaryTable():New( cTRBSTC, aDBF )
	//Cria indices
	oTmpTbl2:AddIndex( "Ind01" , {"TC_CODBEM","TC_COMPONE","TC_SEQRELA"} )
	oTmpTbl2:AddIndex( "Ind02" , {"TC_COMPONE","TC_CODBEM","TC_SEQRELA"} )
	oTmpTbl2:AddIndex( "Ind03" , {"TC_FAMBEM","TC_FAMCOMP"} )
	oTmpTbl2:AddIndex( '04'    , { 'NIVEL' } )
	//Cria a tabela temporaria
	oTmpTbl2:Create()

	//Intancia classe FWTemporaryTable
	oTmpTbl3  := FWTemporaryTable():New( cTRB2, aDBF )
	//Cria indices
	oTmpTbl3:AddIndex( "Ind01" , {"TC_CODBEM","TC_COMPONE"} )
	//Cria a tabela temporaria
	oTmpTbl3:Create()

	aDBFRTPY := {{"CODBEM"  ,"C",16, 0 },;
	{"COMPONE" ,"C",16, 0 },;
	{"TIPOEST" ,"C",1 , 0 },;
	{"CODINSU" ,"C",nSizeCod,0 },;
	{"DESCPEC" ,"C",20, 0 },;
	{"DATAULT" ,"D",08, 0 },;
	{"HORAULT" ,"C",05, 0 }}

	//Intancia classe FWTemporaryTable
	oTmpTbl4  := FWTemporaryTable():New( cTRBTPY, aDBFRTPY )
	//Cria indices
	oTmpTbl4:AddIndex( "Ind01" , {"CODBEM","COMPONE"} )
	//Cria a tabela temporaria
	oTmpTbl4:Create()

	lOPT2 := (nOPC != 2)

	If nOPC == 3
		lTRB   := .F.
		cFIRST := SPACE(16)
		cPAI   := SPACE(16)
		lWhenCount := .F.
	Else
		lDTPAI := .F.
		//--------------------------------------------------------------------
		//Para retornar hora exata do último acompanhamento foi passado
		//como parâmetros a hora '23:59' do dia pesquisado e "E-exato ou anterior"
		//--------------------------------------------------------------------------------
		//FindFunction remover na release GetRPORelease() >= '12.1.027'
		If FindFunction("MNTCont2")
			lValCont2 := MNTCont2(xFilial("TPE"), cPai)
		Else
			Dbselectarea("TPE")
			Dbsetorder(1)
			lValCont2 :=  Dbseek(xFILIAL("TPE")+cPai)
		EndIf

		If lValCont2
			cHORALE2 := NGACUMEHIS( cPai, TPE->TPE_DTULTA, "23:59", 2, "E" )[4]
			Store NGSEEK('TPE',cPai,1,'TPE_POSCON')  To nPOSCONT2,nOLDCONT2,nCONTE2
			Store NGSEEK('TPE',cPai,1,'TPE_DTULTA') To dDATA1,dDATA2
			Store .T.             To lDTPAI,TIPOACOM2
		EndIf

		ST9->(Dbseek(xFILIAL('ST9')+cPAI))
		cCODFAM  := ST9->T9_CODFAMI

		If lTipMod
			cModelo := ST9->T9_TIPMOD
		Endif

		cCCUSTO  := ST9->T9_CCUSTO
		cCCTRAB  := ST9->T9_CENTRAB
		cCALEND  := ST9->T9_CALENDA
		lOPT2    := ((ST9->T9_TEMCONT != "N") .And. (nOPC != 2))
		lWhenCount := ST9->T9_TEMCONT != "N" .And. nOpc == 4

		Store ST9->T9_DTULTAC To dULTACOM,dOLDACOM
		Store ST9->T9_POSCONT To nPOSCONT,nOLDCONT //,nCONTE1

		If ST9->T9_TEMCONT != "N"
			//--------------------------------------------------------------------
			//Para retornar hora exata do último acompanhamento foi passado
			//como parâmetros a hora '23:59' do dia pesquisado e "E-exato ou anterior"
			//--------------------------------------------------------------------------------
			cHORALE1 := NGACUMEHIS( cPai, ST9->T9_DTULTAC, "23:59", 1, "E" )[4]
		EndIf

		Dbselectarea("STC")
		Dbseek(xFILIAL('STC')+cPAI)
		While !Eof() .And.  STC->TC_FILIAL == xFILIAL('STC') .And.;
		STC->TC_CODBEM == cPAI

			If !lDTPAI
				Store STC->TC_DATAINI To dDATA1,dDATA2
				lDTPAI := .T.
			Endif

			nREC   := RECNO()
			cCOMP  := STC->TC_COMPONE
			lTRB   := .T.
			(cTRB2)->(DbAppend())
			For i := 1 TO FCOUNT()
				(cTRB2)->(FieldPut(i,STC->(FIELDGET(i))))
			Next i
			(cTRBSTC)->(DbAppend())
			For i := 1 TO FCOUNT()
				(cTRBSTC)->(FieldPut(i, STC->(FIELDGET(i)) ))
			Next i

			(cTRBSTC)->TC_FAMBEM	:= EVAL(bFAMI, STC->TC_CODBEM)
			(cTRBSTC)->TC_FAMCOMP	:= EVAL(bFAMI, STC->TC_COMPONE)
			(cTRBSTC)->TC_LOCBEM	:= ""
			(cTRBSTC)->TC_OK		:= "N"
			(cTRBSTC)->TC_COMPNOV	:= "N"
			(cTRBSTC)->NIVEL        := 0

			Dbselectarea("ST9")
			Dbsetorder(01)
			If Dbseek(xFILIAL("ST9")+cCOMP)
				(cTRBSTC)->TC_CONT1AT := ST9->T9_POSCONT
				(cTRBSTC)->TC_CCUSTO  := ST9->T9_CCUSTO
				(cTRBSTC)->TC_CENTRAB := ST9->T9_CENTRAB
				If lStatus .AND. cPrograma == "MNTA090"
					(cTRBSTC)->TC_STATUS := ST9->T9_STATUS
				Endif
			EndIf

			Dbselectarea("TPE")
			Dbsetorder(01)
			If Dbseek(xFILIAL("TPE")+cCOMP)
				(cTRBSTC)->TC_CONT2AT := TPE->TPE_POSCON
			EndIf

			// BUSCA O VALOR DOS CONTADORES NO HISTORICO
			Dbselectarea("STZ")
			Dbsetorder(1)
			If Dbseek(xFILIAL('STZ')+cCOMP)
				While !Eof() .And. STZ->TZ_FILIAL = Xfilial('STZ') .And. STZ->TZ_CODBEM == cCOMP
					If STZ->TZ_TIPOMOV = 'E'
						(cTRBSTC)->TC_CONTAD1 := STZ->TZ_POSCONT
						(cTRBSTC)->TC_CONTAD2 := STZ->TZ_POSCON2
						(cTRBSTC)->TC_HORAIMP := STZ->TZ_HORAENT
						Exit
					Endif
					Dbselectarea("STZ")
					Dbskip()
				End
			Endif

			If lSequeSTC //Verifica se existe o campo TC_SEQUEN no dicionário ou base dados.
				(cTRBSTC)->TC_SEQUEN := STC->TC_SEQUEN
				Mnt090AdFi( STC->TC_CODBEM,STC->TC_COMPONE,STC->TC_SEQUEN )
			EndIf

			Dbselectarea("STC")
			cLoc := (cTRBSTC)->TC_LOCALIZ
			If Dbseek(xFILIAL('STC')+cCOMP)
				NGMAKTRB090(cCOMP,cLoc)
			Endif

			Dbgoto(nREC)
			Dbskip()
		End
	Endif

	Store " " To cBEM2,cLOC1,cLOC2,cLOC3
	Store .F. To lRET,lTREE

	If lObjPai
		NGGENTRE090(oObjPai)
	Else

		ST9->(Dbseek(xFILIAL('ST9')))
		DEFINE FONT NgFont NAME "Courier New" SIZE 6, 0
		DEFINE MSDIALOG ODlgStru FROM  03.5,6 TO 370,580 TITLE cTITULO COLOR CLR_BLACK,CLR_WHITE PIXEL

		lOPT := (nOPC == 3)
		ODlgStru:lEscClose := .F. //Nao permite sair ao se pressionar a tecla ESC.

		@ 09,008 SAY OEMTOANSI(STR0016) SIZE 037,07 OF ODlgStru PIXEL COLOR CLR_HBLUE //"Codigo:"
		@ 07,037 MSGET cPAI SIZE 100,08 OF ODlgStru PIXEL Picture '@!' WHEN lOpt ;
			VALID NGCHKPAI090( cPai ) F3 cF3Bem HASBUTTON

		@ 07,140 MSGET oDESC VAR SubStr(cDESC,1,32) SIZE 145,08 OF ODlgStru PIXEL WHEN .F.

		@ 24,008 SAY OEMTOANSI(STR0018) SIZE 37,7 OF ODlgStru PIXEL //"Data Leitura.:"
		@ 22,037 MSGET dULTACOM SIZE 48, 08 OF ODlgStru PIXEL WHEN lWhenCount ;
			VALID (dULTACOM >= dOLDACOM) .And. CHKCONT() HASBUTTON

		@ 24,100 SAY OEMTOANSI(STR0057) SIZE 37,7 OF ODlgStru PIXEL //"Hora Leitura"
		@ 22,135 MSGET cHORALE1 SIZE 10, 08 OF ODlgStru PIXEL Picture "99:99";
			WHEN lWhenCount VALID NGVALHORA(cHORALE1,.T.) .And. MNTA090CCB(cPAI, dULTACOM, cHORALE1)

		@ 24,200 SAY OEMTOANSI(STR0017) SIZE 37,7 OF ODlgStru PIXEL //"Contador.:"
		@ 22,235 MSGET nPOSCONT SIZE 48, 08 OF ODlgStru PIXEL PICTURE "@E 999,999,999";
				WHEN lWhenCount .And. (!FindFunction("NGBlCont") .Or. NGBlCont( cPAI )) VALID Positivo(nPOSCONT) .And. Naovazio(nPOSCONT)

		@ 39,008 SAY OEMTOANSI(STR0018) SIZE 37,7 OF ODlgStru PIXEL //"Data Leitura.:"
		@ 37,037 MSGET If(TIPOACOM2,dDATA1,CTOD("  /  /  ")) SIZE 48, 08 OF ODlgStru PIXEL ;
			WHEN TIPOACOM2 .And. lWhenCount ;
			VALID (dDATA1 >= dDATA2) .And. CHKVARIACAO() HASBUTTON

		@ 39,100 SAY OEMTOANSI(STR0057) SIZE 37,7 OF ODlgStru PIXEL //"Hora Leitura"
		@ 37,135 MSGET cHORALE2 SIZE 10, 08 OF ODlgStru PIXEL Picture "99:99" ;
			WHEN TIPOACOM2 .And. lWhenCount ;
			VALID NGVALHORA(cHORALE2,.T.).And.;
			NGCHKHISTO(cPAI,dDATA1,nPOSCONT2,cHORALE2,2,,.T.) .And. NGVALIVARD(cPAI,nPOSCONT2,dDATA1,cHORALE2,2,.t.)

		@ 39,200 SAY OEMTOANSI(STR0023) SIZE 37,7 OF ODlgStru PIXEL  //"Contador 2"
		@ 37,235 MSGET nPOSCONT2 SIZE 48, 08 OF ODlgStru PIXEL PICTURE "@E 999,999,999";
				WHEN TIPOACOM2 .And. lWhenCount VALID Positivo(nPOSCONT2) .And. Naovazio(nPOSCONT2);
				.And. CHKPOSLIM(cPAI,nPOSCONT2,2)

		@ 172,12 SAY oLOC1 VAR cLOC1 SIZE 048, 08 OF ODlgStru PIXEL
		@ 172,46 SAY oLOC2 VAR cLOC2 SIZE 048, 08 OF ODlgStru PIXEL
		@ 172,80 SAY oLOC3 VAR cLOC3 SIZE 348, 08 OF ODlgStru PIXEL

		@ 155,12 BUTTON STR0087 SIZE 55,11 PIXEL WHEN !Empty( cPai ) ACTION MNT090ETPR()//"Estrutura Peças Rep."

		If STR(nOPC,1) $ "3/4"
			@ 155,70 BUTTON oBtni Prompt STR0119 SIZE 52,11 PIXEL WHEN !Empty( cPai ) ACTION NGINCFIL090(3) OF ODlgStru //"Entrada componente"
			@ 155,125 BUTTON STR0120 SIZE 28,11 PIXEL WHEN .F. OF ODlgStru //"Editar"
			@ 155,156 BUTTON STR0121 SIZE 52,11 PIXEL WHEN .F. OF ODlgStru //"Saída componente"
		Endif

		//-------------------------------------------------------------------------
		//Botão Ok
		//será habilitado somente após o preenchimento do campo bem e validações
		//-------------------------------------------------------------------------
		If STR(nOPC,1) $ "2/3/4/5"
			@ 155,211 BUTTON STR0118 SIZE 28,11 PIXEL WHEN !Empty( cPai ) OF ODlgStru ;
				ACTION lRet := fActionOk( cPai, nOpc, ODlgStru )
		EndIf

		@ 155,242 BUTTON STR0122 SIZE 30,11 PIXEL WHEN .T. OF ODlgStru ACTION EVAL({|| ODlgStru:END()}) //"Cancelar"

		NGGENTRE090()
		NGPOPUP(aSMenu,@oMenu)
		ODlgStru:bRClicked:= { |o,x,y| oMenu:Activate(x,y,ODlgStru)}

		ACTIVATE MSDIALOG ODlgStru CENTERED

		If STR(nOPC,1) $ "5" .And. lRET
			Dbselectarea(cTRBSTC)
			Dbgotop()
			While !Eof()
				DbDelete()
				Dbskip()
			End
			//SEGUNDO CONTADOR
			//FindFunction remover na release GetRPORelease() >= '12.1.027'
			If FindFunction("MNTCont2")
				TIPOACOM2 := MNTCont2( xFilial("TPE"), cPAI )
			Else
				Dbselectarea("TPE")
				TIPOACOM2 := Dbseek( xFilial('TPE') + cPAI )
			EndIf
		Endif

		If lRET .And. nOPC <> 2
			NGATUES090(cPAI,nOPC)
			If nOPC == 5
				f090DelMr( cPAI )
			EndIf
		EndIf

		If STR(nOPC,1) $ "3/4/5" .And. lRET
			fLoadFiltro()
			If STR(nOPC,1) == "3"
				dbSelectArea(cAliasSTC)
				dbSetOrder(1)
				dbSeek(xFilial("STC")+cPAI)
			Elseif STR(nOPC,1) == "4"
				dbSelectArea(cAliasSTC)
				dbSetOrder(1)
				If !dbSeek(xFilial("STC")+cPAI)
					dbSelectArea("STC")
					dbGoTop()
					dbSelectArea(cAliasSTC)
					dbGoTop()
				Endif
			Else
				dbSelectArea("STC")
				dbGoTop()
				dbSelectArea(cAliasSTC)
				dbGoTop()
			Endif
		EndIf
	EndIf

	oTmpTbl2:Delete()
	oTmpTbl3:Delete()

	//Deleta o arquivo temporario fisicamente
	oTmpTbl4:Delete()

	If !lObjPai
		//GERA O.S AUTOMATICA POR CONTADOR
		DbSelectArea("ST9")
		cFilBem := ST9->T9_FILIAL
		If lGFrota
			DbSetOrder(16)
			If DbSeek(cPai)
				cFilBem := ST9->T9_FILIAL
			Else
				cFilBem := " "
			EndIf
		Endif
		DbsetOrder(1)

		If lRET
			If cGERAPREV $ "SC" .And. (!Empty(nPOSCONT) .Or. !Empty(nPOSCONT2))
				If NGCONFOSAUT(cGERAPREV)
					NGGEROSAUT(cPAI,If(!Empty(nPOSCONT),nPOSCONT,nPOSCONT2),cFilBem)
				EndIf
			EndIf
		EndIf
		Dbselectarea("STC")
		If nOPC == 5
			Dbseek(xFILIAL('STC'))
		Else
			Dbgoto(nINIC)
		Endif
	EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGGENTRE090 ³ Autor ³ Paulo Pego          ³ Data ³ 28/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³CRIA O OBJETO oTREE QUE GERENCIA OS NIVEIS                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGGENTRE090(oObjPai)
	Local cDESC := SPACE(40), cDESC2
	Local lObjPai := ( ValType(oObjPai) == "O" )

	Local aItensOrdem := {}
	Local aItens      := {}
	Local nI          := 0
	lTRB := .F.

	If lTREE
		oTREE:END()
		lTREE := .F.
	Endif

	If nOpcao == 3 .OR. nOpcao == 4
		asMenu := {{STR0056,"MNT90OSCOR()"},;               //"O.S.Corretiva"
		{STR0029,"NGC090((cTRBSTC)->TC_COMPONE)"}}   //"Consulta de O.S"
	Else
		asMenu := { {STR0029,"NGC090((cTRBSTC)->TC_COMPONE)"} } //"Consulta de O.S"
	EndIf

	oTREE  := DbTree():NEW(055,012,150,272,If(!lObjPai,ODlgStru,oObjPai),If(!lObjPai,{|| NGMOVE090(oTREE:GETCARGO())},Nil),,.T.)
	If lObjPai
		oTREE:Align := CONTROL_ALIGN_ALLCLIENT
	EndIf
	lTREE  := .T.

	Dbselectarea("ST9")
	Dbsetorder(1)
	cDESC := If(Dbseek(xFILIAL('ST9')+cFIRST) .And. !Empty(cFIRST),ST9->T9_NOME,cDESC)

	Dbselectarea(cTRBSTC)
	Dbsetorder(1)

	lTRB := Dbseek(cFIRST)

	If lTRB
		cDESC2   := cFIRST+REPLICATE(" ",25-Len(RTRIM(cFIRST)))
		cPRODESC := cDESC2 + ' - ' + cDESC
		DBADDTREE oTREE PROMPT cPRODESC OPENED RESOURCE "FOLDER5", "FOLDER6" CARGO cFIRST

		If lSequeSTC //Verifica se existe o campo TC_SEQUEN no dicionário ou base dados.

			While !EoF() .And. Alltrim((cTRBSTC)->TC_CODBEM) == Alltrim(cFIRST)

				nREC  := RECNO()
				cCOMP := (cTRBSTC)->TC_COMPONE
				cITEM := If(ST9->(Dbseek(xFILIAL('ST9')+cCOMP)),ST9->T9_NOME," ")

				aAdd( aItens,{ cCOMP,cITEM,(cTRBSTC)->TC_SEQUEN } )

				Dbgoto(nREC)
				Dbskip()

			End While

			// Ordena itens antes de exibir na árvore
			aItens := aSort( aItens,,,{ |x,y| x[3] < y[3] } )

			For nI := 1 To Len( aItens )

				cCOMP := aItens[nI][1]
				cITEM := aItens[nI][2]

				Dbselectarea(cTRBSTC)
				If Dbseek(cCOMP)
					NGMAKTRE090(cCOMP, cITEM)
				Else
					cDESC2   := cCOMP+REPLICATE(" ",25-Len(RTRIM(cCOMP)))
					cPRODESC := cDESC2 + ' - ' + cITEM

					DBADDITEM oTREE PROMPT cPRODESC RESOURCE "FOLDER5" CARGO cCOMP

				Endif

			Next nI

		Else

			While !Eof() .And. Alltrim((cTRBSTC)->TC_CODBEM) == Alltrim(cFIRST)

				nREC  := RECNO()
				cCOMP := (cTRBSTC)->TC_COMPONE
				cITEM := If(ST9->(Dbseek(xFILIAL('ST9')+cCOMP)),ST9->T9_NOME," ")
				Dbselectarea(cTRBSTC)
				If Dbseek(cCOMP)
					NGMAKTRE090(cCOMP, cITEM	)
				Else
					cDESC2   := cCOMP+REPLICATE(" ",25-Len(RTRIM(cCOMP)))
					cPRODESC := cDESC2+' - '+cITEM
					DBADDITEM oTREE PROMPT cPRODESC RESOURCE "FOLDER5" CARGO cCOMP
				Endif
				Dbgoto(nREC)
				Dbskip()
			End
		EndIf

		DBENDTREE oTREE
	Endif
	oTREE:REFRESH()
	oTREE:TREESEEK(cFIRST)
	If !lObjPai
		ODlgStru:REFRESH()
	EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGMAKTRE090 ³ Autor ³ Paulo Pego          ³ Data ³ 28/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Busca Itens filhos na estrutura - Funcao Recursiva         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGMAKTRE090(cPAI,cDESCPAI)
	Local nREC,cDESC2

	Local aItens      := {}
	Local nI          := 0

	cDESCPAI := If(ST9->(Dbseek(xFILIAL('ST9')+cPAI)),ST9->T9_NOME," ")
	cDESC2   := cPAI+REPLICATE(" ",25-Len(RTRIM(cPAI)))
	cPRODESC := cDESC2+' - '+cDESCPAI
	DBADDTREE oTREE PROMPT cPRODESC OPENED RESOURCE "FOLDER5", "FOLDER6" CARGO cPAI

	If lSequeSTC //Verifica se existe o campo TC_SEQUEN no dicionário ou base dados.

		While (cTRBSTC)->TC_CODBEM == cPAI .And. !(cTRBSTC)->( Eof() )
			nREC  := RECNO()
			cCOMP := (cTRBSTC)->TC_COMPONE
			cITEM := If(ST9->(Dbseek(xFILIAL('ST9')+cCOMP)),ST9->T9_NOME," ")

			aAdd( aItens,{ (cTRBSTC)->TC_COMPONE,cITEM,(cTRBSTC)->TC_SEQUEN } )

			Dbgoto(nREC)
			Dbskip()
		End While

		aItens := aSort( aItens,,,{ |x,y| x[3] < y[3] } )

		For nI := 1 To Len( aItens )

			cCOMP := aItens[nI][1]
			cITEM := aItens[nI][2]

			If Dbseek(cCOMP)
				NGMAKTRE090(cCOMP)
			Else
				cDESC2   := cCOMP+REPLICATE(" ",25-Len(RTRIM(cCOMP)))
				cPRODESC := cDESC2+' - '+cITEM
				DBADDITEM oTREE PROMPT cPRODESC RESOURCE "FOLDER5" CARGO cCOMP

			EndIf

		Next nI

	Else

		While (cTRBSTC)->TC_CODBEM == cPAI .And. !(cTRBSTC)->(Eof())
			nREC  := RECNO()
			cCOMP := (cTRBSTC)->TC_COMPONE
			cITEM := If(ST9->(Dbseek(xFILIAL('ST9')+cCOMP)),ST9->T9_NOME," ")
			Dbselectarea(cTRBSTC)
			If Dbseek(cCOMP)
				NGMAKTRE090(cCOMP)
			Else
				cDESC2   := cCOMP+REPLICATE(" ",25-Len(RTRIM(cCOMP)))
				cPRODESC := cDESC2+' - '+cITEM
				DBADDITEM oTREE PROMPT cPRODESC RESOURCE "FOLDER5" CARGO cCOMP
			Endif
			Dbgoto(nREC)
			Dbskip()
		End

	EndIf

	DBENDTREE oTREE
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGMAKTRB090 ³ Autor ³ Paulo Pego          ³ Data ³ 28/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclui no arquivo de trabalho os itens filhos              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGMAKTRB090( cPAI, cLocPai, cHour, dDate )
	Local nREC,ng1

	Default cHour := ''
	Default dDate := cToD( '' )

	DbSelectArea( "STC" )
	While !Eof() .And. STC->TC_FILIAL == xFILIAL('STC') .And.;
	STC->TC_CODBEM == cPAI

		nREC  := RECNO()
		cCOMP := STC->TC_COMPONE
		(cTRBSTC)->(DbAppend())
		For ng1 := 1 TO FCOUNT()
			(cTRBSTC)->(FieldPut(ng1,STC->(FIELDGET(ng1))))
		Next ng1
		(cTRBSTC)->TC_FAMBEM  := EVAL(bFAMI, STC->TC_CODBEM)
		(cTRBSTC)->TC_FAMCOMP := EVAL(bFAMI, STC->TC_COMPONE)
		(cTRBSTC)->TC_LOCBEM  := cLocPai
		(cTRBSTC)->TC_OK      := "N"
		(cTRBSTC)->TC_COMPNOV := "N"
		(cTRBSTC)->NIVEL      := fNivel( STC->TC_CODBEM )

		// CENTRO DE CUSTO,TRABALHO E CALENDARIO DO COMPONENTE
		Dbselectarea("ST9")
		If Dbseek(xFILIAL('ST9')+STC->TC_COMPONE)
			(cTRBSTC)->TC_CCUSTO  := ST9->T9_CCUSTO
			(cTRBSTC)->TC_CENTRAB := ST9->T9_CENTRAB
			(cTRBSTC)->TC_CALENDA := ST9->T9_CALENDA
			(cTRBSTC)->TC_CONT1AT := ST9->T9_POSCONT
			If lStatus .AND. cPrograma == "MNTA090"
				(cTRBSTC)->TC_STATUS := ST9->T9_STATUS
			Endif
		Endif

		Dbselectarea("TPE")
		Dbsetorder(01)
		If Dbseek(xFILIAL("TPE")+cCOMP)
			(cTRBSTC)->TC_CONT2AT := TPE->TPE_POSCON
		EndIf

		If Empty( cHour )

			// BUSCA O VALOR DOS CONTADORES NO HISTORICO
			Dbselectarea("STZ")
			Dbsetorder(1)
			If Dbseek(xFILIAL('STZ')+cCOMP)
				While !Eof() .And. STZ->TZ_FILIAL = Xfilial('STZ') .And. STZ->TZ_CODBEM == cCOMP
					If STZ->TZ_TIPOMOV = 'E'
						(cTRBSTC)->TC_CONTAD1 := STZ->TZ_POSCONT
						(cTRBSTC)->TC_CONTAD2 := STZ->TZ_POSCON2
						(cTRBSTC)->TC_HORAIMP := STZ->TZ_HORAENT
						Exit
					Endif
					Dbselectarea("STZ")
					Dbskip()
				End
			Endif

		Else

			(cTRBSTC)->TC_HORAIMP := cHour

		EndIf

		If !Empty( dDate )

			(cTRBSTC)->TC_DATETPN := dDate

		EndIf

		If lSequeSTC
			(cTRBSTC)->TC_SEQUEN := STC->TC_SEQUEN
			Mnt090AdFi( STC->TC_CODBEM,STC->TC_COMPONE,STC->TC_SEQUEN )
		EndIf

		MsUnlock()

		Dbselectarea("STC")
		cLoc := (cTRBSTC)->TC_LOCALIZ

		If dbseek( xFilial( 'STC' ) + cCOMP )

			NGMAKTRB090( cCOMP, cLoc, cHour, dDate )

		EndIf

		Dbgoto(nREC)
		Dbskip()
	End
Return NIL

//----------------------------------------------------------------------------------------
/*/{Protheus.doc} NGCHKPAI090
Validalições do campo código do bem

@type function

@author Paulo Pego
@since 28/05/98

@param cPAI, string, código do bem
@return boolean, se o processo pode ser executado
/*/
//----------------------------------------------------------------------------------------
Function NGCHKPAI090(cPAI)
	Local cDESC2
	Local lValCont2 := .F.

	If !Empty( cPAI )

		If !ST9->(Dbseek(xFILIAL('ST9')+cPAI))
			HELP(" ",1,"CODNEXIST")
			Return .F.
		Endif
		If ST9->T9_SITBEM == 'I'
			HELP(" ",1,"BEMINATIV")
			Return .F.
		EndIf
		If ST9->T9_SITBEM == 'T'
			Help(" ",1,"BEMTRANSF",,STR0100,3,1) //"Bem informado foi TRANSFERIDO, portanto não pode fazer parte da estrutura."
			Return .F.
		EndIf

		Dbselectarea("STC")
		lFOUND := Dbseek(xFILIAL('STC')+cPAI)
		Dbselectarea(cTRBSTC)
		If lFOUND
			HELP(" ",1,"A090JAEPAI")
			Return .F.
		Endif

		//---------------------------------------------------------------------------------
		// verifica se há pneus na estrutura com status aguardando marcação de fogo
		//---------------------------------------------------------------------------------
		If FindFunction( 'MNTAGFOGO' ) .And. !Empty( MNTAGFOGO( cPai ) )
			Return .F.
		EndIf

		lOPT2 := ST9->T9_TEMCONT != "N"
		lWhenCount := ST9->T9_TEMCONT != "N"
		//FindFunction remover na release GetRPORelease() >= '12.1.027'
		If FindFunction("MNTCont2")
			lValCont2 := MNTCont2(xFilial('TPE'), cPAI)
		Else
			Dbselectarea("TPE")
			Dbsetorder(1)
			lValCont2 := Dbseek(xFILIAL("TPE")+cPAI)
		EndIf

		If lValCont2
			TIPOACOM2 := .T.
			nPOSCONT2 := NGSEEK('TPE',cPai,1,'TPE_POSCON')
			dDATA1    := NGSEEK('TPE',cPai,1,'TPE_DTULTA')
			dDATA2    := NGSEEK('TPE',cPai,1,'TPE_DTULTA')
			//Passado como parâmetros a hora '23:59' do dia pesquisado e "E-exato ou anterior"
			cHORALE2  := NGACUMEHIS( cPai, TPE->TPE_DTULTA, "23:59", 2, "E" )[4]
		Endif

		dULTACOM := ST9->T9_DTULTAC
		dOLDACOM := ST9->T9_DTULTAC
		nOLDCONT := ST9->T9_POSCONT
		nPOSCONT := ST9->T9_POSCONT

		If ST9->T9_TEMCONT != "N"
			//Passado como parâmetros a hora '23:59' do dia pesquisado e "E-exato ou anterior"
			cHORALE1 := NGACUMEHIS( cPai, ST9->T9_DTULTAC, "23:59", 1, "E" )[4]
		EndIf

		cDESC    := ST9->T9_NOME
		cFIRST   := cPAI

		oDESC:REFRESH()

		cDESC2   := cPAI+REPLICATE(" ",25-Len(RTRIM(cPAI)))
		cPRODESC := cDESC2+' - '+cDESC
		DBADDTREE oTREE PROMPT cPRODESC OPENED RESOURCE "FOLDER5", "FOLDER6" CARGO cPAI
		DBENDTREE oTREE
		oTREE:REFRESH()
		oTREE:SETFOCUS()
		lOPT := .F.

		cCODFAM := ST9->T9_CODFAMI
		If lTipMod
			cModelo := ST9->T9_TIPMOD
		Endif

		cCCUSTO := ST9->T9_CCUSTO
		cCCTRAB := ST9->T9_CENTRAB
		cCALEND := ST9->T9_CALENDA
		oBtni:Enable()

	EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGINCFIL090 ³ Autor ³ Paulo Pego          ³ Data ³ 28/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inclusao dos elementos da estrutura                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGINCFIL090(nOPC)

	Local cCOD,ng2,xy
	Local cF3Compon := Posicione( 'SX3', 2, 'TC_COMPONE', 'X3_F3' )
	Local oMenu
	Local lCOMPNOVO := .F.
	Local aSUB      := {OEMTOANSI(STR0010),; //"Pesquisa"
	OEMTOANSI(STR0011),; //"Visualiza‡Æo"
	OEMTOANSI(STR0012),; //"InclusÆo"
	OEMTOANSI(STR0013),; //"Altera‡Æo"
	OEMTOANSI(STR0014)}  //"ExclusÆo"


	Private oDLG2,oCOD
	Private LECOMPONE,LELOCALIZ,LECCUSTO,LECENTRAB,LECALENDA,LEDATAINI
	Private LECONTEUM,LECONTEDO,LEHORASAI,l090DS,l090HS,l090DTVAL,l090HI
	Private aTELA[0][0],aGETS[0],aHEADER[0],CONTINUA
	Private aCONTADO,aCOMPONE,aOBRIGAT,dDATASAI,cHORAUX
	Private cLOCALINI
	Private nUSADO       := 0
	Private lRET         := .F.
	Private cHORSAIDA    := '  :  '
	Private M->T9_CATBEM := Space(1)
	Private lFrota       :=  GetNewPar('MV_NGMNTFR','N') == 'S' // Variavel utilizada na construção da tela de inclusão de Status através do F3.

	bCAMPO        := {|nCPO| Field(nCPO)}

	M->TC_COMPONE := Space(Len(stc->tc_compone))
	M->TC_LOCALIZ := Space(Len(stc->tc_localiz))
	M->TC_CCUSTO  := Space(Len(si3->i3_custo))
	M->TC_CENTRAB := Space(Len(shb->hb_cod))
	M->TC_CALENDA := Space(Len(sh7->h7_codigo))
	M->TC_DATAINI := dDATABASE
	M->H7_DESCRI  := Space(40)
	M->HB_NOME    := Space(40)
	M->I3_DESC    := Space(40)
	If lStatus
		cStatus := Space(Len(cStatus))
	Endif

	vOPCAO        := nOPC
	cCOD          := oTREE:GETCARGO()

	Store {"S","N"} To aCONTADO,aCOMPONE,aOBRIGAT
	Store Space(40) To cPROD,cNOMLOCA
	Store .T. To LECOMPONE,LELOCALIZ,LECCUSTO,LECENTRAB,LECALENDA,LEDATAINI,LECONTEUM,LECONTEDO,LESTATUS
	Store .F. To l090DS,l090HS,l090DTVAL,l090HI

	nCONTE2 := 0

	LEHORASAI := .F.
	If STR(nOPC,1) $ "2/4/5" .And. cCOD == cPAI
		Return .T.
	Endif

	If Trim( cF3Compon ) == 'ST9' .Or. Empty( cF3Compon )

		/*----------------------------------------------------------+
		| Garante uso da consulta padrão atualizada para TC_COMPONE |
		+----------------------------------------------------------*/
		cF3Compon := 'ST9BVE'

	EndIf

	If nOPC == 3
		For ng2 := 1 TO FCount()
			M->&(EVAL(bCampo,ng2)) := &(EVAL(bCampo,ng2))
			If ValType(M->&(EVAL(bCampo,ng2))) == "C"
				M->&(EVAL(bCampo,ng2)) := SPACE(Len(M->&(EVAL(bCampo,ng2))))
			Elseif ValType(M->&(EVAL(bCampo,ng2))) == "N"
				M->&(EVAL(bCampo,ng2)) := 0
			Elseif ValType(M->&(EVAL(bCampo,ng2))) == "D"
				M->&(EVAL(bCampo,ng2)) := cTod("  /  /  ")
			Elseif ValType(M->&(EVAL(bCampo,ng2))) == "L"
				M->&(EVAL(bCampo,ng2)) := .F.
			Endif
		Next ng2

		M->TC_DATAINI := DDATABASE
		cHORSAIDA     := SubStr( Time(), 1, 5 )
		M->TC_CCUSTO  := cCCUSTO
		M->TC_CENTRAB := cCCTRAB
		M->TC_CALENDA := cCALEND
		M->I3_DESC    := NGSEEK('SI3',M->TC_CCUSTO,1,'I3_DESC')
		M->HB_NOME    := NGSEEK('SHB',M->TC_CENTRAB,1,'HB_NOME')
		M->H7_DESCRI  := NGSEEK('SH7',M->TC_CALENDA,1,'H7_DESCRI')
		lREFRESH      := .T.
		lCOMPNOVO     := .T.

	Else
		dbSelectArea(cTRBSTC)
		dbSetOrder(2)
		dbSeek(cCOD)
		LECOMPONE := .F.
		If nOPC = 5  // DELETA COMPONENTE DA ESTRUTURA

			Store .F. To LECOMPONE,LELOCALIZ,LECCUSTO,LECENTRAB,LECALENDA,LEDATAINI,LECONTEUM,LECONTEDO

			If lGFrota
				dbSelectArea("TQS")
				dbSetOrder(01)
				If dbSeek(xFilial("ST9")+(cTRBSTC)->TC_COMPONE)
					MsgInfo(STR0097+chr(13)+STR0095+" "+STR0092+chr(13)+STR0098,STR0063) //"Nao e permitido excluir um bem de categoria pneu na estrutura."###" da Rotina de O.S. Corretiva."
					Return .F.
				Endif
				Dbselectarea(cTRBSTC)
			Endif

			dbSelectArea("STZ")
			dbSetOrder(1)
			If dbSeek(xFILIAL('STZ')+(cTRBSTC)->tc_compone+"E")
				LEHORASAI := .T.
			Endif

		Elseif nOPC = 2   // BOTAO DA DIREITA CLICADO ( VISUALIZACAO )
			Store .F. To LELOCALIZ,LECCUSTO,LECENTRAB,LECALENDA,LEDATAINI,LECONTEUM,LECONTEDO
		Endif

		cLOCALINI     := (cTRBSTC)->tc_localiz //Localizacao inicial do bem
		cHORSAIDA     := (cTRBSTC)->tc_horaimp
		M->TC_COMPONE := (cTRBSTC)->tc_compone
		M->TC_LOCALIZ := (cTRBSTC)->tc_localiz
		M->TC_CCUSTO  := (cTRBSTC)->tc_ccusto
		M->TC_CENTRAB := (cTRBSTC)->tc_centrab
		M->TC_CALENDA := (cTRBSTC)->tc_calenda
		nCONTE1       := (cTRBSTC)->tc_contad1
		nCONTE2       := (cTRBSTC)->tc_contad2
		M->TC_DATAINI := (cTRBSTC)->tc_dataini

		If lStatus .AND. cPrograma == "MNTA090"
			cStatus := (cTRBSTC)->tc_Status
		Endif

		If !Empty(M->TC_COMPONE) .And. ST9->(Dbseek(xFILIAL('ST9')+M->TC_COMPONE))
			cPROD := ST9->T9_NOME
		Endif

		If !Empty(M->TC_LOCALIZ) .And. TPS->(Dbseek(xFILIAL("TPS")+M->TC_LOCALIZ))
			cNOMLOCA := TPS->TPS_NOME
		Endif

		If ST9->(FOUND())
			M->TC_CCUSTO  := ST9->T9_CCUSTO
			M->TC_CENTRAB := ST9->T9_CENTRAB
			M->TC_CALENDA := ST9->T9_CALENDA
			M->I3_DESC    := NGSEEK('SI3',M->TC_CCUSTO,1,'I3_DESC')
			M->HB_NOME    := NGSEEK('SHB',M->TC_CENTRAB,1,'HB_NOME')
			M->H7_DESCRI  := NGSEEK('SH7',M->TC_CALENDA,1,'H7_DESCRI')

			If lCatBem
				M->t9_CATBEM  := If(lStatus,ST9->T9_CATBEM,Space(1))
				If ST9->T9_CATBEM == '3'
					LELOCALIZ := .F.
					If lStatus
						LESTATUS  := .F.
					EndIf
				EndIf
			EndIf
		Endif

		LECONTEUM := If(st9->t9_temcont = "S",.T.,.F.)
		LECONTEDO := If(st9->t9_temcont = "S" .And. TPE->(Dbseek(xFILIAL('TPE')+M->TC_COMPONE)),.T.,.F.)
		lREFRESH  := .T.
		Dbsetorder(1)
		lCOMPNOVO := If((cTRBSTC)->TC_COMPNOV == "S", .T.,.F.)
	Endif


	cTITULO := STR0019+aSUB[nOPC]+STR0020 //"Estrutura - "###"Componente"
	DEFINE MSDIALOG oDLG2 FROM 18,20 TO 33.5,120 TITLE OEMTOANSI(cTITULO) COLOR CLR_BLACK,CLR_WHITE STYLE DS_MODALFRAME

	oDLG2:lEscClose := .F.

	@ 05,008 SAY OEMTOANSI(STR0009) SIZE 47,07  OF oDLG2 PIXEL COLOR CLR_HBLUE //"Componente"
	@ 05,045 MSGET M->TC_COMPONE    SIZE 100,07 OF oDLG2 PIXEL PICTURE '@!' F3 cF3Compon;
		VALID Vazio() .Or. ( EXISTCPO("ST9",M->TC_COMPONE) .And. CHKFILHO( M->TC_COMPONE, M->TC_DATAINI, cHORSAIDA ) .And. ;
		MOSCENCALE()) WHEN LECOMPONE HASBUTTON

	@ 05,145 MSGET SubStr(cPROD,1,34) SIZE 150,07 OF oDLG2 PIXEL PICTURE '@!' WHEN .F.

	@ 18,008 SAY OEMTOANSI(STR0022) SIZE 47,07 OF oDLG2 PIXEL //"Localizacao"
	@ 18,045 MSGET M->TC_LOCALIZ    SIZE 40,07 OF oDLG2 PIXEL PICTURE '@!' F3 "TPS";
	VALID NG090CHK1() .And. CHKLOCA(M->TC_LOCALIZ,M->TC_COMPONE) ;
		WHEN !Empty( M->TC_COMPONE ) .And. LELOCALIZ HASBUTTON

	@ 18,145 MSGET cNOMLOCA SIZE 120,07 OF oDLG2 PIXEL PICTURE '@!' WHEN .F.

	@ 30,008 SAY OEMTOANSI(STR0040) SIZE 47,07 OF oDLG2 PIXEL COLOR CLR_HBLUE //Centro Custo
	@ 30,045 MSGET M->TC_CCUSTO     SIZE 100,07 OF oDLG2 PIXEL PICTURE '@!' F3 "SI3";
	VALID Existcpo("SI3",M->TC_CCUSTO) .And. NG090CHK2() WHEN .F. HASBUTTON

	@ 30,145 MSGET M->I3_DESC SIZE 120,07 OF oDLG2 PIXEL PICTURE '@!' WHEN .F.

	@ 43,008 SAY OEMTOANSI(STR0042) SIZE 47,07 OF oDLG2 PIXEL //"C.Trabalho"
	@ 43,045 MSGET M->TC_CENTRAB    SIZE 40,07 OF oDLG2 PIXEL PICTURE '@!' F3 "SHB";
	VALID NG090CHK3() WHEN .F. HASBUTTON

	@ 43,145 MSGET M->HB_NOME SIZE 120,07 OF oDLG2 PIXEL PICTURE '@!' WHEN .F.

	@ 56,008 SAY OEMTOANSI(STR0044) SIZE 47,07 OF oDLG2 PIXEL COLOR CLR_HBLUE //"Calendario"
	@ 56,045 MSGET M->TC_CALENDA    SIZE 25,07 OF oDLG2 PIXEL PICTURE '@!' F3 "SH7";
		VALID Existcpo("SH7",M->TC_CALENDA) .And. NG090CHK4();
		WHEN !Empty( M->TC_COMPONE ) .And. LECALENDA HASBUTTON

	@ 56,145 MSGET M->H7_DESCRI SIZE 120,07 OF oDLG2 PIXEL PICTURE '@!' WHEN .F.

	If nOPC = 5

		LEDATAINI := .T.
		LECONTEUM := If(lOPT2    ,.T.,.F.)
		LECONTEDO := If(TIPOACOM2,.T.,.F.)
		dDATASAI  := M->TC_DATAINI
		cHORAUX   := cHORSAIDA

		If LEHORASAI
			@ 69,008 SAY OEMTOANSI(STR0054) SIZE 48,08 OF oDLG2 PIXEL //"Data Saida
			@ 69,100 SAY OEMTOANSI(STR0059) SIZE 35,08 OF oDLG2 PIXEL //"Hora Saida
			@ 69,045 MSGET M->TC_DATAINI SIZE 45,08 OF oDLG2 PIXEL VALID MNTA090DS() HASBUTTON
			@ 69,145 MSGET cHORSAIDA SIZE 10,08 OF oDLG2 PIXEL Picture "99:99" VALID MNTA090HS()
		Else
			@ 69,008 SAY OEMTOANSI(STR0046) SIZE 47,07 OF oDLG2 PIXEL //"Data Implant"
			@ 69,100 SAY OEMTOANSI(STR0060) SIZE 35,08 OF oDLG2 PIXEL //"Hora Implant
			@ 69,045 MSGET M->TC_DATAINI SIZE 45,08 OF oDLG2 PIXEL When .F. HASBUTTON
			@ 69,145 MSGET cHORSAIDA SIZE 10,08 OF oDLG2 PIXEL Picture "99:99" When .F.
			Store .F. To LECONTEUM,LECONTEDO
		Endif

	Else
		@ 69,008 SAY OEMTOANSI(STR0046) SIZE 47,07 OF oDLG2 PIXEL //"Data Implant"
		@ 69,100 SAY OEMTOANSI(STR0060) SIZE 35,08 OF oDLG2 PIXEL //"Hora Implant
		@ 69,045 MSGET M->TC_DATAINI SIZE 45,08 OF oDLG2 PIXEL VALID NG90DTVAL() .And. ;
			MNTA090CCB( M->TC_COMPONE, M->TC_DATAINI, cHORSAIDA, .T. ) WHEN !Empty( M->TC_COMPONE ) .And. lCOMPNOVO HASBUTTON
		@ 69,145 MSGET cHORSAIDA SIZE 10,08 OF oDLG2 PIXEL Picture "99:99" VALID MNTA090HI() .And.;
			MNTA090CCB( M->TC_COMPONE, M->TC_DATAINI, cHORSAIDA, .T. ) WHEN !Empty( M->TC_COMPONE ) .And. lCOMPNOVO
	Endif

	@ 69,180 SAY OEMTOANSI(STR0047) SIZE 47,07 OF oDLG2 PIXEL //"Contador 1"
	@ 69,215 MSGET nCONTE1 SIZE 40,07 OF oDLG2 PIXEL PICTURE "@E 999,999,999" ;
		WHEN !Empty( M->TC_COMPONE ) .And. NGBlCont( M->TC_COMPONE ) .And. lOPT2 .And. LECONTEUM .And. lCOMPNOVO

	@ 82,008 SAY OEMTOANSI(STR0023) SIZE 47,07 OF oDLG2 PIXEL  //"Contador 2"
	@ 82,045 MSGET nCONTE2 SIZE 40,07 OF oDLG2 PIXEL PICTURE "@E 999,999,999";
		WHEN !Empty( M->TC_COMPONE ) .And. If(lOPT2 .And. LECONTEDO .And. lCOMPNOVO,.T.,.F.)

	If lStatus
		@ 82,100 SAY OEMTOANSI(STR0093) SIZE 30,07 OF oDLG2 PIXEL  //"Status"
		@ 82,145 MSGET cStatus SIZE 5,07 OF oDLG2 PIXEL PICTURE "@!" Valid MNTA090STA(cStatus) F3 "TQYFIL" ;
			WHEN !Empty( M->TC_COMPONE ) .And. LESTATUS .And. (vOPCAO = 3 .Or. vOPCAO = 4 .Or. vOPCAO = 5) HASBUTTON
	Endif

	//Botão ok
	If STR(nOPC,1) $ "3/4"
		DEFINE SBUTTON FROM 93,198 TYPE 1 ENABLE OF oDlg2 WHEN !Empty( M->TC_COMPONE );
			ACTION MNTA090IM(nOPC,nCONTE1,nCONTE2,cHORSAIDA,LECONTEUM,LECONTEDO,lCOMPNOVO,lOPT2)
	ElseIf STR(nOPC,1) == "5"
		DEFINE SBUTTON FROM 93,198 TYPE 1 ENABLE OF oDlg2 ACTION MNTA090DC()
	Endif

	DEFINE SBUTTON FROM 93,169 TYPE 15 WHEN !Empty( M->TC_COMPONE ) ENABLE OF oDlg2 ACTION (NGVIEWE090()) //visualizar
	DEFINE SBUTTON FROM 93,227 TYPE 2  ENABLE OF oDLG2 ACTION (lRET := .F.,oDLG2:END())

	NGPOPUP(aSMenu,@oMenu)
	oDlg2:bRClicked:= { |o,x,y| oMenu:Activate(x,y,oDlg2)}

	ACTIVATE MSDIALOG oDLG2

	If nOPC == 2
		Return .T.
	Endif

	If lRET .And. (STR(nOPC,1) $ "3/4")
		If nOPC == 3

			M->TC_CODBEM := oTREE:GETCARGO()
			If Empty(M->TC_CODBEM)
				M->TC_CODBEM := oTREE:GETCARGO()
			Endif
			aAreaTRB := (cTRBSTC)->(GetArea())
			dbSelectArea(cTRBSTC)
			dbSetOrder( 02 )
			cLocBem := ''
			If dbSeek(M->TC_CODBEM)
				cLocBem := (cTRBSTC)->TC_LOCALIZ
			EndIf
			RestArea(aAreaTRB)

			(cTRBSTC)->(dbAppend())
			(cTRBSTC)->TC_TIPOEST := 'B'
			(cTRBSTC)->TC_CODBEM  := M->TC_CODBEM
			(cTRBSTC)->TC_COMPONE := M->TC_COMPONE
			(cTRBSTC)->TC_SEQRELA := cSEQ
			(cTRBSTC)->TC_FAMBEM  := EVAL(bFAMI, (cTRBSTC)->TC_CODBEM)
			(cTRBSTC)->TC_FAMCOMP := EVAL(bFAMI, M->TC_COMPONE)
			(cTRBSTC)->TC_LOCBEM  := cLocBem
			(cTRBSTC)->TC_OK      := "N"
			(cTRBSTC)->TC_COMPNOV := "S"
			(cTRBSTC)->TC_CONTAD1 := nCONTE1
			(cTRBSTC)->TC_CONTAD2 := nCONTE2
			(cTRBSTC)->TC_CONT1AT := nCONTE1
			(cTRBSTC)->TC_CONT2AT := nCONTE2

			If lStatus .AND. cPrograma == "MNTA090"
				(cTRBSTC)->tc_Status := cStatus
			Endif

			If lSequeSTC .And. lCOMPNOVO
				Mnt090AdFi( M->TC_CODBEM,M->TC_COMPONE )
			EndIf

			NGSEGTRE90((cTRBSTC)->TC_COMPONE)

			dbSelectArea(cTRBTPY)
			(cTRBTPY)->(DbAppend())
			(cTRBTPY)->CODBEM  := (cTRBSTC)->TC_CODBEM
			(cTRBTPY)->COMPONE := (cTRBSTC)->TC_COMPONE
			(cTRBTPY)->TIPOEST := "B"

			//Busca as pecas de reposicao do componente
			aULTPECASR := NGPEUTIL((cTRBSTC)->TC_COMPONE)

			For xy := 1 To Len(aULTPECASR)
				dbSelectArea(cTRBTPY)
				(cTRBTPY)->(DbAppend())
				(cTRBTPY)->CODBEM  := (cTRBSTC)->TC_COMPONE
				(cTRBTPY)->COMPONE := (cTRBSTC)->TC_COMPONE
				(cTRBTPY)->TIPOEST := "P"
				(cTRBTPY)->CODINSU := aULTPECASR[xy][1]
				(cTRBTPY)->DESCPEC := NGSEEK("SB1",aULTPECASR[xy][1],1,'SubStr(B1_DESC,1,20)')
				(cTRBTPY)->DATAULT := aULTPECASR[xy][2]
				(cTRBTPY)->HORAULT := aULTPECASR[xy][3]
			Next xy

		Else

			cSEQ := Space(Len(stc->tc_seqrela))
			cCOD := M->TC_COMPONE
			Dbselectarea(cTRBSTC)
			dbSetOrder(01)
			dbSeek(cCOD)
			While (cTRBSTC)->TC_CODBEM == cCOD
				RecLock(cTRBSTC,.F.)
				(cTRBSTC)->TC_LOCBEM := M->TC_LOCALIZ
				MsUnLock(cTRBSTC)
				(cTRBSTC)->(dbSkip())
			EndDo
			dbSetOrder(2)
			dbSeek(cCOD)

		Endif

		dbSelectArea(cTRBSTC)
		(cTRBSTC)->TC_LOCALIZ := M->TC_LOCALIZ
		(cTRBSTC)->TC_DATAINI := M->TC_DATAINI
		(cTRBSTC)->TC_DATETPN := M->TC_DATAINI
		(cTRBSTC)->TC_CCUSTO  := M->TC_CCUSTO
		(cTRBSTC)->TC_CENTRAB := M->TC_CENTRAB
		(cTRBSTC)->TC_CALENDA := M->TC_CALENDA
		(cTRBSTC)->TC_HORAIMP := cHORSAIDA
		(cTRBSTC)->TC_CONTAD1 := nCONTE1
		(cTRBSTC)->TC_CONTAD2 := nCONTE2
		(cTRBSTC)->NIVEL      := fNivel( M->TC_CODBEM )

		If lStatus .And. cPrograma == "MNTA090"
			(cTRBSTC)->tc_Status := cStatus
		Endif

		MsUnLock( cTRBSTC )
		dbSelectArea("STC")
		cLoc := (cTRBSTC)->TC_LOCALIZ

		If dbSeek( xFilial( 'STC' ) + (cTRBSTC)->TC_COMPONE )

			NGMAKTRB090( (cTRBSTC)->TC_COMPONE, cLoc, cHORSAIDA, M->TC_DATAINI )

		EndIf

	Elseif lRET .And. (STR(nOPC,1) $ "5")

		oTREE:DELITEM()
		oTREE:REFRESH()
		dbSelectArea(cTRBSTC)
		RecLock(cTRBSTC,.F.)
		(cTRBSTC)->TC_CCUSTO  := M->TC_CCUSTO
		(cTRBSTC)->TC_CENTRAB := M->TC_CENTRAB
		(cTRBSTC)->TC_CALENDA := M->TC_CALENDA
		(cTRBSTC)->TC_DATAINI := M->TC_DATAINI
		(cTRBSTC)->TC_CONTAD1 := nCONTE1
		(cTRBSTC)->TC_CONTAD2 := nCONTE2
		(cTRBSTC)->TC_HORASAI := cHORSAIDA

		If lStatus .AND. cPrograma == "MNTA090"
			(cTRBSTC)->tc_Status := cStatus
		Endif

		MSUNLOCK()
		(cTRBSTC)->(DBDELETE())
	Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CHKFILHO    ³ Autor ³                     ³ Data ³ 28/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consiste se o bem FILHO esta cadastro em outra estrutura   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CHKFILHO( cITEM, dDataEnt, cHoraEnt )

	Local lFOUND   := .F., cPAI
	Local lCatBem  := NGCADICBASE('T9_CATBEM','A','ST9',.F.)

	Default dDataEnt := Ctod(' / / ')
	Default cHoraEnt := ""

	cPAI := oTREE:GETCARGO()
	LECONTEDO := .F.

	If Empty(cPAI)
		cPAI := oTREE:GETCARGO()
	Endif

	cPAI := Alltrim(cPAI)
	ST9->(Dbseek(xFILIAL('ST9')+cPAI))
	If !ST9->(Dbseek(xFILIAL('ST9')+cITEM))
		HELP(" ",1,"CODNEXIST")
		Return .F.
	Endif
	If ST9->T9_SITBEM == 'I'
		HELP(" ",1,"BEMINATIV")
		Return .F.
	Endif
	If ST9->T9_SITBEM == 'T'
		Help(" ",1,"BEMTRANSF",,STR0100,3,1) //"Bem informado foi TRANSFERIDO, portanto não pode fazer parte da estrutura."
		Return .F.
	EndIf

	If lGFrota
		If NGIFDBSEEK("TQS",cITEM,1,.F.)
			MsgInfo(STR0094+chr(13)+STR0095+" "+STR0092+" da Rotina de"+chr(13)+"Ordem de Serviço Corretiva.",STR0063)
			Return .F.
		Endif
	Endif

	dDTIMPL := ST9->T9_DTCOMPR
	M->T9_CATBEM := If(lCatBem,ST9->T9_CATBEM,Space(1))

	// Verifica se o item já é componente da estrutura.
	dbSelectArea( cTRBSTC )
	dbSetOrder( 2 ) // TC_COMPONE + TC_CODBEM + TC_SEQRELA
	lFound := dbSeek( cITEM )

	// Verifica se o item é o pai da estrutura.
	dbSetOrder(1) // TC_CODBEM + TC_COMPONE + TC_SEQRELA
	If dbSeek( cItem ) .Or. ( cPai == AllTrim( cItem ) )

		HELP( '', 1, 'A090CODPAI' )
		Return .F.

	EndIf

	If !lFound

		// Verifica se o item já é componente em outra estrutura.
		dbSelectArea( 'STC' )
		dbSetOrder( 3 ) // TC_FILIAL + TC_COMPONE + TC_CODBEM
		lFound := dbSeek( xFilial( 'STC' ) + cItem )

		// Verifica se o item já é pai em outra estrutura em que possui como componenete o pai desta nova estrutura.
		dbSetOrder( 1 ) // TC_FILIAL + TC_CODBEM + TC_COMPONE + TC_TIPOEST + TC_LOCALIZ + TC_SEQRELA
		If dbSeek( xFilial( 'STC' ) + cItem + cPai )

			/*
				Atenção ## Este componente já encontra-se como pai em uma outra estrutura. ##
				Altere o pai desta estrutura, pois um bem não pode ser componente
				em estrutura de seus próprios componentes.
			*/
			Help( , , STR0037, , STR0123, 2, 1, , , , , , { STR0124 } )
			Return .F.

		EndIf

	EndIf

	If !lFOUND
		Dbselectarea(cTRBSTC)
		Dbgotop()
		While !Eof()
			If (cTRBSTC)->TC_CODBEM == cITEM
				lFOUND := .T.
				nCONTE1 := (cTRBSTC)->TC_CONTAD1
				nCONTE2 := (cTRBSTC)->TC_CONTAD2
				Exit
			Endif
			Dbskip()
		End
		xx := cPAI
		Dbselectarea("STC")
		Dbsetorder(2)
		While .T.
			If Dbseek(xFILIAL('STC')+xx)
				If STC->TC_CODBEM == cITEM
					lFOUND := .T.
					Exit
				Endif
			Else
				Exit
			Endif
			If XX == STC->TC_COMPONE
				Exit
			Endif
			xx := STC->TC_COMPONE
		End
		Dbsetorder(1)
	Endif

	If lFOUND
		HELP(" ",1,"A090NODES2",,cITEM,2,26)
		Return .F.
	Endif

	Dbselectarea(cTRBSTC)
	cPROD := ST9->T9_NOME

	LECONTEUM := st9->t9_temcont = "S"
	LECONTEDO := st9->t9_temcont = "S" .And. TPE->(Dbseek(xFILIAL('TPE')+M->TC_COMPONE))

	nCONTE1  := st9->t9_poscont
	 // carrega campo contador caso esteja bloqueado
	MNTA090CCB( cITEM, dDataEnt, cHoraEnt, .T. )
	nCONTE2  := If(TPE->(Dbseek(xFILIAL("TPE")+M->TC_COMPONE)),TPE->TPE_POSCON,0)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CHKLOCA     ³ Autor ³                     ³ Data ³ 28/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consistˆncia da localizacao                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CHKLOCA(cLOCA,cComp)

	If Empty(cLOCA)
		cNOMLOCA := SPACE(40)
		Return .T.
	Endif

	dbSelectArea("ST9")
	dbSetOrder(1)
	If dbSeek(xFilial("ST9")+cComp)

		dbSelectArea("ST6")
		dbSetOrder(1)
		If dbSeek(xFilial("ST6")+ST9->T9_CODFAMI)

			If ST6->T6_PERLOCA == "2"

				If !TPS->(Dbseek(xFILIAL("TPS")+cLOCA))
					HELP(" ",1,"REGNOIS")
					Return .F.
					lMENU := .F.
				Endif

				(cTRBSTC)->(Dbgotop())
				While !(cTRBSTC)->(Eof())
					If Alltrim(cLOCA) == Alltrim((cTRBSTC)->TC_LOCALIZ)
						HELP(" ",1,"LOCALJAEXI")
						Return .F.
					Endif
					(cTRBSTC)->(Dbskip())
				End
			EndIf
		EndIf
	EndIf

	cNOMLOCA := TPS->TPS_NOME

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGATUES090  ³ Autor ³ Paulo Pego          ³ Data ³ 28/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza o arquivo de Estrutura (STC) baseado no arquivo de ³±±
±±³          ³           de Trabalho (TRBSTC)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGATUES090(cPAI,nOPC)
	
	Local lFIRST := .T., OLDSEQ, ze, yg, gg, mm, iy, xE := 0,i
	Local aVETPAIDIF 	:= {}
	Local oTmpTbl5
	Local lPIMSINT 		:= SuperGetMV("MV_PIMSINT",.F.,.F.)
	Local lNGIntPIMS	:= FindFunction("NGIntPIMS")
	Local lMain 		:= Type( "oMainWnd" ) == "O"

	Private cTRBXC	  := GetNextAlias() //Alias do oTmpTbl5
	nDIF  := 0
	nDIF2 := 0

	DbSelectArea("STC")
	Set Filter To
	Set Filter To STC->TC_FILIAL = xFilial("STC") .And. STC->TC_TIPOEST == "F"

	DbSelectArea("ST9")
	DbSetOrder(01)
	Dbseek(xfilial("ST9")+cPAI)

	cCODFAM09 := ST9->T9_CODFAMI+Space(Len(ST9->T9_CODBEM)-Len(ST9->T9_CODFAMI))
	aESTFAM09 := NGCOMPEST(cCODFAM09,"F",.T.,.F.,.T.,Nil,Nil,ST9->T9_TIPMOD)

	DbSelectArea("STC")
	Set Filter To STC->TC_FILIAL = xFilial("STC") .And. STC->TC_TIPOEST == "B"

	DbSelectArea(cTRBSTC)
	aDBF  := DbStruct()

	//Intancia classe FWTemporaryTable
	oTmpTbl5  := FWTemporaryTable():New( cTRBXC, aDBF )
	//Cria indices
	oTmpTbl5:AddIndex( "Ind01" , {"TC_COMPONE","TC_CODBEM"} )
	//Criaa tabela temporaria
	oTmpTbl5:Create()

	SET DELETE OFF
	DbSelectArea(cTRBSTC)
	DbSetOrder(01)
	nREGSTC := Recno()
	DbGotop()
	While !Eof()

		DbSelectArea(cTRBXC)
		DbAppend()
		For iy := 1 To (cTRBSTC)->(FCount())
			x := "(cTRBSTC)->"+FieldName(iy)
			y := "(cTRBXC)->"+FieldName(iy)
			Replace &y. with &x.
		Next iy

		DbSelectArea(cTRBSTC)
		DbSkip()
	End
	DbGoto(nREGSTC)
	SET DELETE ON

	Dbselectarea("STC")
	Set Filter To
	Dbsetorder(1)

	Dbselectarea("ST9")
	Dbsetorder(1)

	If Dbseek(xFILIAL("ST9")+cPAI)
		If ST9->T9_TEMCONT <> "N"

			If nPOSCONT > 0
				NGTRETCON(cPAI,dULTACOM,nPOSCONT,cHORALE1,1,,.T.)
			Endif
			Dbselectarea("TPE")
			Dbsetorder(1)
			If Dbseek(xFILIAL("TPE")+cPAI)
				If nPOSCONT2 > 0
					NGTRETCON(cPAI,dDATA1,nPOSCONT2,cHORALE2,2,,.F.)
				Endif
			Endif
		Endif
	Endif

	Dbselectarea("ST9")
	Dbseek(xFILIAL('ST9')+cPAI)
	nCONTPAI := ST9->T9_POSCONT

	//SEGUNDO CONTADOR
	Dbselectarea("TPE")
	Dbseek(xFILIAL("TPE")+cPAI)
	nCONTPAI2 := TPE->TPE_POSCON
	dUTLPAI   := TPE->TPE_DTULTA
	
	SET DELETE OFF

	aCOMPNOVO := {}
	aBEMTCONT := {}
	
	dbSelectArea( cTRBSTC )
	dbSetOrder( 4 ) // NIVEL
	dBGoTop()

	While (cTRBSTC)->( !EoF() )

		OLDSEQ := (cTRBSTC)->TC_SEQRELA

		If DELETED()

			SET DELETE ON
		
			If (cTRBSTC)->TC_COMPNOV = 'N'

				cBEMPESTC := (cTRBSTC)->TC_CODBEM+(cTRBSTC)->TC_COMPONE
				// Deleta o pai/filho
				// BLOCO NOVO

				MNTA090ASTZ((cTRBSTC)->TC_COMPONE,nOPC)

				Dbselectarea("ST9")
				dbSetOrder(1)
				If Dbseek(xFILIAL('ST9')+(cTRBSTC)->TC_COMPONE)
					RecLock("ST9",.F.)
					ST9->T9_ESTRUTU := "N"
					If lStatus .AND. cPrograma == "MNTA090"
						st9->t9_Status := (cTRBSTC)->TC_STATUS
					Endif
					MsUnLock("ST9")
				Endif

				//Procura o bem pai do componente
				cVBEMPAI := NGTBEMPTE((cTRBSTC)->TC_COMPONE,cTRBXC)
				nCONT1  := (cTRBSTC)->TC_CONTAD1
				nCONT2  := (cTRBSTC)->TC_CONTAD2

				lREPAS090 := .T.
				dbSelectArea("ST9")
				dbSetOrder(01)
				If dbseek(xFILIAL("ST9")+(cTRBSTC)->TC_COMPONE)

					//Verifica pela estrutura padrao se o contador do bem pai deve repassado para o comp.
					//na nova localizacao
					If Len(aESTFAM09) > 0
						cCODF09 := ST9->T9_CODFAMI+Space(Len(ST9->T9_CODBEM)-Len(ST9->T9_CODFAMI))
						nPOSF09 := aSCAN(aESTFAM09,{|x| x[1]+x[2] = cCODF09+(cTRBSTC)->TC_LOCALIZ})
						If nPOSF09 > 0 .And. aESTFAM09[nPOSF09,3] = "N"
							lREPAS090 := .F.
						EndIf
					EndIf

					//Carrrega o contador do pai do componente
					If ST9->T9_TEMCONT = "S"

						aCONTACUM := NGACUMEHIS((cTRBSTC)->TC_COMPONE,STZ->TZ_DATASAI,STZ->TZ_HORASAI,1,"E")
						nCONT1 := aCONTACUM[1]
						dbselectarea("TPE")
						dbsetorder(01)
						If dbseek(xFILIAL("TPE")+(cTRBSTC)->TC_COMPONE)
							aCONTACUM2 := NGACUMEHIS((cTRBSTC)->TC_COMPONE,STZ->TZ_DATASAI,STZ->TZ_HORASAI,2,"E")
							nCONT2 := aCONTACUM2[1]
						EndIf

					ElseIf ST9->T9_TEMCONT = "P" .Or. ST9->T9_TEMCONT = "I"

						If lREPAS090
							If !Empty(cVBEMPAI)
								aCONTACUM  := NGACUMEHIS(cVBEMPAI,STZ->TZ_DATASAI,STZ->TZ_HORASAI,1,"E")
								nCONT1 := aCONTACUM[1]
								dbselectarea("TPE")
								dbsetorder(01)
								If dbseek(xFILIAL("TPE")+(cTRBSTC)->TC_COMPONE)
									aCONTACUM2 := NGACUMEHIS(cVBEMPAI,STZ->TZ_DATASAI,STZ->TZ_HORASAI,2,"E")
									nCONT2 := aCONTACUM2[1]
								EndIf
							EndIf
						Else
							aCONTACUM  := NGACUMEHIS((cTRBSTC)->TC_COMPONE,STZ->TZ_DATASAI,STZ->TZ_HORASAI,1,"E")
							nCONT1 := aCONTACUM[1]
							dbselectarea("TPE")
							dbsetorder(01)
							If dbseek(xFILIAL("TPE")+(cTRBSTC)->TC_COMPONE)
								aCONTACUM2 := NGACUMEHIS((cTRBSTC)->TC_COMPONE,STZ->TZ_DATASAI,STZ->TZ_HORASAI,2,"E")
								nCONT2 := aCONTACUM2[1]
							EndIf
						EndIf
					EndIf
					Dbselectarea( 'STZ' )
					Dbsetorder( 1 )
					If Dbseek( xFilial( 'STZ' ) + (cTRBSTC)->TC_COMPONE + 'S' )
						RecLock( 'STZ', .F. )
						STZ->TZ_CONTSAI := nCONT1
						STZ->TZ_CONTSA2 := nCONT2
						STZ->( MsUnLock() )
					EndIf
				EndIf

				Dbselectarea("STC")
				Dbsetorder(1)
				If Dbseek(xFILIAL('STC')+cBEMPESTC)
					RecLock("STC",.F.)
					DbDelete()
					MsUnLock()
				Endif
			Endif

			If lFIRST
				nINIC  := RECNO()
				lFIRST := .F.
			Endif

		Else

			SET DELETE ON
			
			//Procura o bem pai do componente
			cVBEMPAI  := NGTBEMPTE((cTRBSTC)->TC_COMPONE,cTRBXC)
			lBPAIDIF1 := .F.
			lBPAIDIF2 := .F.
			Dbselectarea("ST9")
			If Dbseek(xFILIAL('ST9')+(cTRBSTC)->TC_COMPONE)
				RecLock("ST9",.F.)
				ST9->T9_ESTRUTU := "S"
				If lStatus .AND. cPrograma == "MNTA090"
					st9->t9_Status := (cTRBSTC)->TC_STATUS
				Endif
				MsUnlock("ST9")
				nOLDCONT  := ST9->T9_POSCONT
				nOLDDAT   := ST9->T9_DTULTAC
				nACUMUL1  := ST9->T9_CONTACU
				nVIRADA1  := ST9->T9_VIRADAS

				If ST9->T9_TEMCONT <> "N" .And. (cTRBSTC)->TC_COMPNOV = "S"

					If ST9->T9_TEMCONT == "S" .And. (cTRBSTC)->TC_CONTAD1 > 0
						NGTRETCON((cTRBSTC)->TC_COMPONE,(cTRBSTC)->TC_DATAINI,(cTRBSTC)->TC_CONTAD1,(cTRBSTC)->TC_HORAIMP,1,,.T.)
					Else

						//Verifica pela estrutura padrao se o contador do bem pai deve repassado para o comp.
						lREPAS090 := .T.
						If Len(aESTFAM09) > 0
							cCODF09 := ST9->T9_CODFAMI+Space(Len(ST9->T9_CODBEM)-Len(ST9->T9_CODFAMI))
							nPOSF09 := aSCAN(aESTFAM09,{|x| x[1]+x[2] = cCODF09+(cTRBSTC)->TC_LOCALIZ})
							If nPOSF09 > 0 .And. aESTFAM09[nPOSF09,3] = "N"
								lREPAS090 := .F.
							EndIf
						EndIf

						nPOSCPAI1 := 0
						If cVBEMPAI == cPAI
							If lREPAS090
								If !Empty(cVBEMPAI)

									aCONTACUM := NGACUMEHIS(cVBEMPAI,(cTRBSTC)->TC_DATAINI,(cTRBSTC)->TC_HORAIMP,1,"E")
									nPOSCPAI1 := aCONTACUM[1]

									If nPOSCPAI1 > 0
										(cTRBSTC)->TC_CONTAD1 := nPOSCPAI1
									EndIf

									If nPOSCPAI1 > 0
										//Inclui contador para componente controlado por Pai da estrutura ou Imediato
										NGINREGEST((cTRBSTC)->TC_COMPONE,(cTRBSTC)->TC_DATAINI,(cTRBSTC)->TC_HORAIMP,1,nPOSCPAI1,nACUMUL1,nVIRADA1)

										//Repassa o contador para o pai
										NGTRETCON(cVBEMPAI,(cTRBSTC)->TC_DATAINI,nPOSCPAI1,(cTRBSTC)->TC_HORAIMP,1,,.T.)
									EndIf
								EndIf
							EndIf
						ElseIf lREPAS090
							lBPAIDIF1 := .T.
						EndIf
					EndIf
				EndIf
			EndIf
			Dbselectarea("STC")
			Dbsetorder(1)
			If Dbseek(xFILIAL('STC')+(cTRBSTC)->TC_CODBEM+(cTRBSTC)->TC_COMPONE)
				RecLock("STC",.F.)
			Else
				RecLock("STC",.T.)
				STC->TC_FILIAL  := xFILIAL('STC')
				STC->TC_TIPOEST := (cTRBSTC)->TC_TIPOEST
				STC->TC_CODBEM  := (cTRBSTC)->TC_CODBEM
				STC->TC_COMPONE := (cTRBSTC)->TC_COMPONE
			Endif
			STC->TC_LOCALIZ := (cTRBSTC)->TC_LOCALIZ
			STC->TC_DATAINI := (cTRBSTC)->TC_DATAINI
			STC->TC_MANUATI := (cTRBSTC)->TC_MANUATI
			STC->TC_OBRIGAT := (cTRBSTC)->TC_OBRIGAT

			If lSequeSTC
				STC->TC_SEQUEN := Mnt090RtSq( (cTRBSTC)->TC_CODBEM,(cTRBSTC)->TC_COMPONE )
			EndIf

			If NGCADICBASE("TC_TIPMOD","D","STC",.F.)
				Dbselectarea("ST9")
				Dbsetorder(16)
				If Dbseek(STC->TC_CODBEM)
					STC->TC_TIPMOD := ST9->T9_TIPMOD
				EndIf
			EndIf

			If lALTURA1
				STC->TC_ALTURA := (cTRBSTC)->TC_ALTURA
			Endif
			MsUnlock('STC')

			Dbselectarea("STZ")
			Dbsetorder(1)
			If Dbseek(xFILIAL("STZ")+(cTRBSTC)->TC_COMPONE+'E')
				If STZ->TZ_DATAMOV <> (cTRBSTC)->TC_DATAINI
					RecLock("STZ",.F.)
					STZ->TZ_DATAMOV := (cTRBSTC)->TC_DATAINI
					STZ->(MsUnlock())
				Endif
			Endif

			//SEGUNDO CONTADOR
			Dbselectarea("ST9")
			Dbsetorder(1)
			If Dbseek(xFILIAL('ST9')+(cTRBSTC)->TC_COMPONE)
				Dbselectarea("TPE")
				Dbsetorder(1)
				If Dbseek(xFILIAL("TPE")+(cTRBSTC)->TC_COMPONE)
					nOLDCONT2 := TPE->TPE_POSCON
					nDATA2    := TPE->TPE_DTULTA
					nACUMUL2  := TPE->TPE_CONTAC
					nVIRADA2  := TPE->TPE_VIRADA

					If ST9->T9_CODBEM = (cTRBSTC)->TC_COMPONE .And. ST9->T9_TEMCONT <> "N" .And. (cTRBSTC)->TC_COMPNOV = "S"

						If ST9->T9_TEMCONT == "S" .And. (cTRBSTC)->TC_CONTAD2 > 0
							NGTRETCON((cTRBSTC)->TC_COMPONE,(cTRBSTC)->TC_DATAINI,(cTRBSTC)->TC_CONTAD2,(cTRBSTC)->TC_HORAIMP,2,,.T.)
						Else
							//Verifica pela estrutura padrao se o contador do bem pai deve repassado para o comp.
							lREPAS090 := .T.
							If Len(aESTFAM09) > 0
								cCODF09 := ST9->T9_CODFAMI+Space(Len(ST9->T9_CODBEM)-Len(ST9->T9_CODFAMI))
								nPOSF09 := aSCAN(aESTFAM09,{|x| x[1]+x[2] = cCODF09+(cTRBSTC)->TC_LOCALIZ})
								If nPOSF09 > 0 .And. aESTFAM09[nPOSF09,3] = "N"
									lREPAS090 := .F.
								EndIf
							EndIf

							nPOSCPAI2 := 0
							If cVBEMPAI == cPAI
								If lREPAS090
									If !Empty(cVBEMPAI)

										aCONTACUM2 := NGACUMEHIS(cVBEMPAI,(cTRBSTC)->TC_DATAINI,(cTRBSTC)->TC_HORAIMP,2,"E")
										nPOSCPAI2 := aCONTACUM2[1]

										If nPOSCPAI2 > 0
											(cTRBSTC)->TC_CONTAD2 := nPOSCPAI2
										EndIf

										If nPOSCPAI2 > 0
											//Inclui contador para componente controlado por Pai da estrutura ou Imediato
											NGINREGEST((cTRBSTC)->TC_COMPONE,(cTRBSTC)->TC_DATAINI,(cTRBSTC)->TC_HORAIMP,2,nPOSCPAI2,nACUMUL2,nVIRADA2)

											//Repasse de contador para o pai
											NGTRETCON(cVBEMPAI,(cTRBSTC)->TC_DATAINI,nPOSCPAI2,(cTRBSTC)->TC_HORAIMP,2,,.T.)
										EndIf
									EndIf
								EndIf
							ElseIf lREPAS090
								lBPAIDIF2 := .T.
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf

			nRecSTZ := 0
			Dbselectarea("STZ")
			Dbsetorder(1)
			If !Dbseek(xFILIAL("STZ")+(cTRBSTC)->TC_COMPONE+'E')
				MNTA090NSTZ((cTRBSTC)->TC_DATAINI,(cTRBSTC)->TC_CONTAD1,;
				(cTRBSTC)->TC_CONTAD2)
				nRecSTZ := Recno()
			Else
				If STZ->TZ_LOCALIZ != (cTRBSTC)->TC_LOCALIZ

					nCONT1  := (cTRBSTC)->TC_CONTAD1
					nCONT2  := (cTRBSTC)->TC_CONTAD2
					nCONTS1 := (cTRBSTC)->TC_CONTAD1
					nCONTS2 := (cTRBSTC)->TC_CONTAD2

					lREPAS090 := .T.
					Dbselectarea("ST9")
					Dbsetorder(01)
					If Dbseek(xFILIAL("ST9")+(cTRBSTC)->TC_COMPONE)

						//Verifica pela estrutura padrao se o contador do bem pai deve repassado para o comp.
						//na nova localizacao
						If Len(aESTFAM09) > 0
							cCODF09 := ST9->T9_CODFAMI+Space(Len(ST9->T9_CODBEM)-Len(ST9->T9_CODFAMI))
							nPOSF09 := aSCAN(aESTFAM09,{|x| x[1]+x[2] = cCODF09+(cTRBSTC)->TC_LOCALIZ})
							If nPOSF09 > 0 .And. aESTFAM09[nPOSF09,3] = "N"
								lREPAS090 := .F.
							EndIf
						EndIf

						//Carrrega o contador do pai do componente
						If ST9->T9_TEMCONT = "S"

							aCONTACUM := NGACUMEHIS((cTRBSTC)->TC_COMPONE,(cTRBSTC)->TC_DATAINI,(cTRBSTC)->TC_HORAIMP,1,"E")
							nCONT1 :=  aCONTACUM[1]

							Dbselectarea("TPE")
							Dbsetorder(01)
							If Dbseek(xFILIAL("TPE")+(cTRBSTC)->TC_COMPONE)
								aCONTACUM2 := NGACUMEHIS((cTRBSTC)->TC_COMPONE,(cTRBSTC)->TC_DATAINI,(cTRBSTC)->TC_HORAIMP,2,"E")
								nCONT2 := aCONTACUM2[1]
							EndIf

						ElseIf ST9->T9_TEMCONT = "P" .Or. ST9->T9_TEMCONT = "I"

							If lREPAS090

								If !Empty(cVBEMPAI)

									aCONTACUM := NGACUMEHIS(cVBEMPAI,(cTRBSTC)->TC_DATAINI,(cTRBSTC)->TC_HORAIMP,1,"E")
									nCONT1 :=  aCONTACUM[1]

									Dbselectarea("TPE")
									Dbsetorder(01)
									If Dbseek(xFILIAL("TPE")+(cTRBSTC)->TC_COMPONE)
										aCONTACUM2 := NGACUMEHIS(cVBEMPAI,(cTRBSTC)->TC_DATAINI,(cTRBSTC)->TC_HORAIMP,2,"E")
										nCONT2 := aCONTACUM2[2]
									EndIf

								EndIf
							Else
								aCONTACUM := NGACUMEHIS((cTRBSTC)->TC_COMPONE,(cTRBSTC)->TC_DATAINI,(cTRBSTC)->TC_HORAIMP,1,"E")
								nCONT1 :=  aCONTACUM[1]

								Dbselectarea("TPE")
								Dbsetorder(01)
								If Dbseek(xFILIAL("TPE")+(cTRBSTC)->TC_COMPONE)
									aCONTACUM2 := NGACUMEHIS((cTRBSTC)->TC_COMPONE,(cTRBSTC)->TC_DATAINI,(cTRBSTC)->TC_HORAIMP,2,"E")
									nCONT2 := aCONTACUM2[2]
								EndIf
							EndIf

							lREPASL090 := .T.
							//Verifica pela estrutura padrao se o contador do bem pai deve repassado para o comp.
							//na localizacao anterior
							If Len(aESTFAM09) > 0
								cCODF09 := ST9->T9_CODFAMI+Space(Len(ST9->T9_CODBEM)-Len(ST9->T9_CODFAMI))
								nPOSF09 := aSCAN(aESTFAM09,{|x| x[1]+x[2] = cCODF09+STZ->TZ_LOCALIZ})
								If nPOSF09 > 0 .And. aESTFAM09[nPOSF09,3] = "N"
									lREPASL090 := .F.
								EndIf
							EndIf

							If lREPASL090
								nCONTS1 := nCONT1
								nCONTS2 := nCONT2
							EndIf

						EndIf
					EndIf

					//Faz a saida o componente na localizacao
					DbSelectArea("STZ")
					RecLock("STZ",.F.)
					STZ->TZ_TIPOMOV := 'S'
					STZ->TZ_DATASAI := (cTRBSTC)->TC_DATAINI
					STZ->TZ_CONTSAI := nCONTS1
					STZ->TZ_CONTSA2 := nCONTS2
					STZ->TZ_HORASAI := (cTRBSTC)->TC_HORAIMP

					If lALTURA3
						ST9->(Dbseek(xFILIAL('ST9')+(cTRBSTC)->TC_COMPONE))
						STZ->TZ_ALTSAI := (cTRBSTC)->TC_ALTURA
						STZ->TZ_POSSAI := ST9->T9_POSCONT
					Endif
					MsUnLock('STZ')

					DbSelectArea("ST9")
					nREGST9 := Recno()

					//Grava o registro de entrada do componente na outra localizacao
					MNTA090NSTZ((cTRBSTC)->TC_DATAINI,nCONT1,nCONT2,"TL")

					DbSelectArea("ST9")
					DbGoto(nREGST9)

					//Grava registro de entrada na estrutura no historico do bem
					If ST9->T9_TEMCONT == "S"

						aCONTACUM := NGACUMEHIS((cTRBSTC)->TC_COMPONE,(cTRBSTC)->TC_DATAINI,(cTRBSTC)->TC_HORAIMP,1,"E")
						nCONT1   := aCONTACUM[1]

						NGTRETCON((cTRBSTC)->TC_COMPONE,STZ->TZ_DATAMOV,nCONT1,STZ->TZ_HORAENT,1,,.T.)

						Dbselectarea("TPE")
						Dbsetorder(01)
						If Dbseek(xFILIAL("TPE")+(cTRBSTC)->TC_COMPONE)

							aCONTACUM2 := NGACUMEHIS((cTRBSTC)->TC_COMPONE,STZ->TZ_DATAMOV,STZ->TZ_HORAENT,2,"E")
							nCONT2   := aCONTACUM2[1]

							NGTRETCON((cTRBSTC)->TC_COMPONE,STZ->TZ_DATAMOV,nCONT2,STZ->TZ_HORAENT,2,,.T.)

						EndIf

					ElseIf ST9->T9_TEMCONT == "P" .Or. ST9->T9_TEMCONT == "I"
						If lREPAS090
							aCONTACUM := NGACUMEHIS(cVBEMPAI,STZ->TZ_DATAMOV,STZ->TZ_HORAENT,1,"E")
							nCONT1   := aCONTACUM[1]

							If nCONT1 > 0
								//Inclui contador para componente controlado por Pai da estrutura ou Imediato
								NGINREGEST((cTRBSTC)->TC_COMPONE,STZ->TZ_DATAMOV,STZ->TZ_HORAENT,1,nCONT1,nACUMUL1,nVIRADA1)

								//Repasse de contador para o pai
								NGTRETCON(cVBEMPAI,STZ->TZ_DATAMOV,nCONT1,STZ->TZ_HORAENT,1,,.T.)
							EndIf

							Dbselectarea("TPE")
							Dbsetorder(01)
							If Dbseek(xFILIAL("TPE")+(cTRBSTC)->TC_COMPONE)

								aCONTACUM2 := NGACUMEHIS(cVBEMPAI,STZ->TZ_DATAMOV,STZ->TZ_HORAENT,2,"E")
								nCONT2   := aCONTACUM2[1]

								If nCONT2 > 0
									//Inclui contador para componente controlado por Pai da estrutura ou Imediato
									NGINREGEST((cTRBSTC)->TC_COMPONE,(cTRBSTC)->TC_DATAINI,(cTRBSTC)->TC_HORAIMP,2,nCONT2,nACUMUL2,nVIRADA2)

									//Repasse de contador para o pai
									NGTRETCON(cVBEMPAI,STZ->TZ_DATAMOV,nCONT2,STZ->TZ_HORAENT,2,,.T.)
								EndIf
							EndIf
						EndIf
					EndIf
				Endif
			Endif

			Dbselectarea("ST9")
			Dbsetorder(1)
			If Dbseek(xFILIAL("ST9")+(cTRBSTC)->TC_COMPONE)
				If ST9->T9_TEMCONT = "S"
					If Ascan(aBEMTCONT,{|x| (x[1]) == (cTRBSTC)->TC_CODBEM}) = 0
						Aadd(aBEMTCONT,{(cTRBSTC)->TC_COMPONE,(cTRBSTC)->TC_DATAINI,;
						(cTRBSTC)->TC_HORAIMP,(cTRBSTC)->TC_CONTAD1,;
						(cTRBSTC)->TC_CONTAD2})
					Endif
				Endif
			Endif

			If (cTRBSTC)->TC_COMPNOV = 'S'
				Aadd(aCOMPNOVO,{(cTRBSTC)->TC_COMPONE,(cTRBSTC)->TC_DATAINI})
				Dbselectarea("ST9")
				Dbsetorder(1)
				If Dbseek(xFILIAL("ST9")+(cTRBSTC)->TC_COMPONE)
					If ST9->T9_TEMCONT = "S"

						If (cTRBSTC)->TC_DATAINI > st9->t9_dtultac .Or.;
						((cTRBSTC)->TC_DATAINI = st9->t9_dtultac .And.;
						(cTRBSTC)->TC_CONTAD1 > st9->t9_poscont)

							RecLock("ST9",.F.)
							ST9->T9_POSCONT := (cTRBSTC)->TC_CONTAD1
							ST9->T9_DTULTAC := (cTRBSTC)->TC_DATAINI
							MsUnlock("ST9")
						Endif
					Endif
				Endif
				If ST9->T9_TEMCONT = "S"
					Dbselectarea("TPE")
					Dbsetorder(1)
					If Dbseek(xFILIAL("TPE")+(cTRBSTC)->TC_COMPONE)
						If (cTRBSTC)->TC_DATAINI > tpe->tpe_dtulta .Or.;
						((cTRBSTC)->TC_DATAINI = tpe->tpe_dtulta .And.;
						(cTRBSTC)->TC_CONTAD2 > tpe->tpe_poscon)

							RecLock("TPE",.F.)
							TPE->TPE_POSCON := (cTRBSTC)->TC_CONTAD2
							TPE->TPE_DTULTA := (cTRBSTC)->TC_DATAINI
							MsUnlock("TPE")
						Endif
					Endif
				Endif
			Endif

			// ALTERA OS CENTROS DE (CUSTO E TRABALHO) E CALENDARIO
			nRecTPN		:= 0
			cCusto		:= ""
			cCenTrab	:= ""
			cCalenda	:= ""

			// CASO MOVIMENTE C.C. DEVE CONSIDERAR SEMPRE O DO PAI IMEDIATO NA ESTRUTURA.
			dbSelectArea( 'ST9' )
			dbSetOrder( 1 )
			If dbSeek( xFilial( 'ST9') + (cTRBSTC)->TC_CODBEM )
				cCusto	 := ST9->T9_CCUSTO
				cCenTrab := ST9->T9_CENTRAB
				cCalenda := ST9->T9_CALENDA
			EndIf

			dbSelectArea( 'ST9' )
			dbSetOrder( 1 )
			If dbSeek( xFilial( 'ST9') + (cTRBSTC)->TC_COMPONE )

				If ST9->T9_MOVIBEM == 'S' .And. ( ST9->T9_CCUSTO != cCusto .Or. ST9->T9_CENTRAB != cCenTrab )

					RecLock( 'ST9', .F. )

						ST9->T9_CCUSTO  := cCusto
						ST9->T9_CENTRAB := cCenTrab

					ST9->( MsUnlock() )

					//Atualiza o centro de custo no ativo fixo
					If !NGATUATF( ST9->T9_CODIMOB,ST9->T9_CCUSTO ) //Se não foi atualizado o Centro de Custo do bem via SIGAATF
						RecLock( "ST9",.F. )
						ST9->T9_CCUSTO := If( Empty(cCusto),(cTRBSTC)->TC_CCUSTO,cCusto )
						MsUnLock( "ST9" )
					EndIf

					Dbselectarea("TPN")
					Dbsetorder(1)
					RecLock("TPN",.T.)
						TPN->TPN_FILIAL := xFILIAL("TPN")
						TPN->TPN_CODBEM := (cTRBSTC)->TC_COMPONE
						TPN->TPN_DTINIC := (cTRBSTC)->TC_DATETPN
						TPN->TPN_HRINIC := (cTRBSTC)->TC_HORAIMP
						TPN->TPN_CCUSTO := cCusto
						TPN->TPN_CTRAB  := cCenTrab
						TPN->TPN_UTILIZ := "U"
						TPN->TPN_POSCON := (cTRBSTC)->TC_CONTAD1
						TPN->TPN_POSCO2 := (cTRBSTC)->TC_CONTAD2
					TPN->( MsUnLock() )
					nRecTPN := Recno()
				Endif

				RecLock("ST9",.F.)
				If ST9->T9_CALENDA <> If(Empty(cCalenda),(cTRBSTC)->TC_CALENDA,cCalenda) .And. !Empty((cTRBSTC)->TC_CALENDA)
					ST9->T9_CALENDA := If(Empty(cCalenda),(cTRBSTC)->TC_CALENDA,cCalenda)
				Endif
				MsUnLock()

				//----------------------------------------------------
				// Integração via mensagem única do cadastro de Bem
				//----------------------------------------------------
				If FindFunction("MN080INTMB") .And. MN080INTMB(ST9->T9_CODFAMI)

					DbSelectArea( "ST9" )

					// Define array private que será usado dentro da integração
					aParamMensUn    := Array( 4 )
					aParamMensUn[1] := Recno() // Indica numero do registro
					aParamMensUn[2] := 4       // Indica tipo de operação que esta invocando a mensagem unica
					aParamMensUn[3] := .F.     // Indica que se deve recuperar dados da memória
					aParamMensUn[4] := 1       // Indica se deve inativar o bem (1 ativo,2 - inativo)

					lMuEquip := .F.
					bBlock := { || FWIntegDef( "MNTA080",EAI_MESSAGE_BUSINESS,TRANS_SEND,Nil ) }

					If lMain
						MsgRun( "Aguarde integração com backoffice...","Equipment",bBlock )
					Else
						Eval( bBlock )
					EndIf

				EndIf

				//Funcao de integracao com o PIMS atraves do EAI
				If lPIMSINT .And. lNGIntPIMS .And. nRecTPN > 0
					NGIntPIMS("TPN",nRecTPN,3)
				EndIf

			Endif

			dbselectarea(cTRBSTC)
			If lBPAIDIF1
				Aadd(aVETPAIDIF,{cVBEMPAI,(cTRBSTC)->TC_COMPONE,(cTRBSTC)->TC_DATAINI,(cTRBSTC)->TC_HORAIMP,;
				nPOSCPAI1,nACUMUL1,nVIRADA1,1,Recno(),nRecTPN,nRecSTZ})
			EndIf

			If lBPAIDIF2
				Aadd(aVETPAIDIF,{cVBEMPAI,(cTRBSTC)->TC_COMPONE,(cTRBSTC)->TC_DATAINI,(cTRBSTC)->TC_HORAIMP,;
				nPOSCPAI2,nACUMUL2,nVIRADA2,2,Recno(),nRecTPN,nRecSTZ})
			EndIf

		Endif

		dbSelectArea( cTRBSTC )
		
		SET DELETE OFF
		
		dbSkip()
	
	End

	//Processa e atualiza os contadores do componentes imediatos
	Dbselectarea(cTRBSTC)
	For i := 1 TO Len(aVETPAIDIF)

		aCONTACUM := NGACUMEHIS(aVETPAIDIF[i][1],aVETPAIDIF[i][3],aVETPAIDIF[i][4],aVETPAIDIF[i][8],"E")
		nPOSCPAI  := aCONTACUM[1]

		If nPOSCPAI > 0
			//Inclui registro de entrada na estrutura para componente controlado pai Imediato
			NGINREGEST(aVETPAIDIF[i][2],aVETPAIDIF[i][3],aVETPAIDIF[i][4],1,nPOSCPAI,aVETPAIDIF[i][6],;
			aVETPAIDIF[i][7])
			//Atualiza STZ com contador de entrada
			If aVETPAIDIF[i][11] >  0
				dbSelectArea("STZ")
				dbGoto(aVETPAIDIF[i][11])
				RecLock("STZ",.F.)
				If aVETPAIDIF[i][8] == 1
					STZ->TZ_POSCONT :=  nPOSCPAI
				ElseIf aVETPAIDIF[i][8] == 2
					STZ->TZ_POSCON2 :=  nPOSCPAI
				EndIf
				STZ->(MsUnLock())
			EndIf

			//Atualiza TPN com contador de entrada
			If aVETPAIDIF[i][10] >  0
				dbSelectArea("TPN")
				dbGoto(aVETPAIDIF[i][10])
				RecLock("TPN",.F.)
				If aVETPAIDIF[i][8] == 1
					TPN->TPN_POSCON :=  nPOSCPAI
				ElseIf aVETPAIDIF[i][8] == 2
					TPN->TPN_POSCO2 :=  nPOSCPAI
				EndIf
				TPN->(MsUnLock())

				//Funcao de integracao com o PIMS atraves do EAI
				If lPIMSINT .And. lNGIntPIMS
					NGIntPIMS("TPN",TPN->(RecNo()),4)
				EndIf

			EndIf
		EndIf
	Next i

	SET DELETE ON
	lREFRESH := .T.

	Dbselectarea("STC")
	Set Filter To

	oTmpTbl5:Delete()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTA090ASTZ ³ Autor ³In cio Luiz Kolling  ³ Data ³13/08/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza a movimenta‡Æo da estrutura ( STZ )                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MNTA090ASTZ(vBEMSTZ,nOPCV)
	Dbselectarea("STZ")
	Dbsetorder(1)
	If Dbseek(xFILIAL("STZ")+vBEMSTZ+'E')
		RecLock("STZ",.F.)
		STZ->TZ_TIPOMOV := 'S'
		STZ->TZ_DATASAI := If(nOPCV <> 5,(cTRBSTC)->TC_DATAINI, IIf( !Empty(dULTACOM), dULTACOM,dDataBase) )
		STZ->TZ_CONTSAI := (cTRBSTC)->TC_CONTAD1
		STZ->TZ_CONTSA2 := (cTRBSTC)->TC_CONTAD2
		STZ->TZ_HORASAI := IIf(nOPCV <> 5,(cTRBSTC)->TC_HORASAI,IIf(!Empty(cHORALE1),cHORALE1, SubStr(Time(),1,5) ) )
		MsUnLock("STZ")
	Endif
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTA090NSTZ ³ Autor ³In cio Luiz Kolling  ³ Data ³13/08/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera nova movimenta‡Æo da estrutura ( STZ )                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MNTA090NSTZ(dVDTMOV,nCONT1STZ,nCONT2STZ,cTROLOC)
	cTEMCOMP := NGSEEK("ST9",(cTRBSTC)->TC_COMPONE,1,"T9_TEMCONT")
	cTEMCPAI := NGSEEK("ST9",(cTRBSTC)->TC_CODBEM,1,"T9_TEMCONT")

	//Verifica se existe uma saida no mesmo minuto
	Dbselectarea("STZ")
	dbSetOrder(2) ////TZ_CODBEM+DTOS(TZ_DATAMOV)+TZ_TIPOMOV+TZ_HORAENT
	dbSeek(xFilial("STZ") + (cTRBSTC)->TC_COMPONE + DtoS(dVDTMOV) +  "S" + SubStr(Time(),1,5))
	While !Eof() .And. xFilial("STZ") == STZ->TZ_FILIAL .And. (cTRBSTC)->TC_COMPONE == STZ->TZ_CODBEM .And. ;
	DtoS(STZ->TZ_DATAMOV) == DtoS(dVDTMOV) .And.  STZ->TZ_TIPOMOV == "S" .And. STZ->TZ_HORAENT == SubStr(Time(),1,5)
		Sleep(5000)
	End

	//Verifica se existe uma entrada no mesmo minuto
	Dbselectarea("STZ")
	dbSetOrder(2) ////TZ_CODBEM+DTOS(TZ_DATAMOV)+TZ_TIPOMOV+TZ_HORAENT
	dbSeek(xFilial("STZ") + (cTRBSTC)->TC_COMPONE + DtoS(dVDTMOV) +  "E" + SubStr(Time(),1,5))
	While !Eof() .And. xFilial("STZ") == STZ->TZ_FILIAL .And. (cTRBSTC)->TC_COMPONE == STZ->TZ_CODBEM .And. ;
	DtoS(STZ->TZ_DATAMOV) == DtoS(dVDTMOV) .And.  STZ->TZ_TIPOMOV == "E" .And. STZ->TZ_HORAENT == SubStr(Time(),1,5)
		Sleep(5000)
	End

	Dbselectarea("STZ")
	RecLock("STZ",.T.)
	STZ->TZ_FILIAL  := xFILIAL("STZ")
	STZ->TZ_CODBEM  := (cTRBSTC)->TC_COMPONE
	STZ->TZ_BEMPAI  := (cTRBSTC)->TC_CODBEM
	STZ->TZ_LOCALIZ := (cTRBSTC)->TC_LOCALIZ
	STZ->TZ_DATAMOV := dVDTMOV
	STZ->TZ_POSCONT := nCONT1STZ
	STZ->TZ_TIPOMOV := "E"
	STZ->TZ_POSCON2 := nCONT2STZ
	//Verificar se o bem tem 1º contador
	If cTEMCOMP <> "N"
		STZ->TZ_HORACO1 := If(nPOSCONT > 0,cHORALE1,STZ->TZ_HORACO1)
	EndIf
	//Verificar se o bem tem 2º contador
	If NGIFDBSEEK('TPE',(cTRBSTC)->TC_COMPONE,1)
		STZ->TZ_HORACO2 := If(nPOSCONT2 > 0,cHORALE2,STZ->TZ_HORACO2)
	EndIf
	STZ->TZ_HORAENT := (cTRBSTC)->TC_HORAIMP
	STZ->TZ_TEMCONT := cTEMCOMP
	STZ->TZ_TEMCPAI := cTEMCPAI
	If lALTURA2
		STZ->TZ_ALTENT := (cTRBSTC)->TC_ALTURA
		STZ->TZ_POSENT := ST9->T9_POSCONT
	Endif

	//Entrada do componente na nova localizacao
	If cTROLOC <> Nil .And. cTROLOC = "TL"
		STZ->TZ_HORAENT := MTOH(HTOM(SubStr((cTRBSTC)->TC_HORAIMP,1,5))+1)
		If STZ->TZ_HORAENT = "24:00"
			STZ->TZ_HORAENT := "00:00"
		EndIf
		If STZ->TZ_HORAENT = "00:00"
			STZ->TZ_DATAMOV := dVDTMOV + 1
			Dbselectarea("STC")
			Dbsetorder(1)
			If Dbseek(xFILIAL("STC")+(cTRBSTC)->TC_CODBEM+(cTRBSTC)->TC_COMPONE)
				RecLock("STC",.F.)
				STC->TC_DATAINI := STZ->TZ_DATAMOV
				MsUnLock("STC")
			EndIf
		EndIf
	EndIf

	DbSelectArea("STZ")
	MsUnLock('STZ')
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGPADR090  ³ Autor ³ Paulo Pego          ³ Data ³ 28/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consiste a estrutura com a estrutura padrao                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGPADR090(cPAI)

	Local cFami    := ''
	Local cChave   := ''
	Local lRET     := .F.
	Local lTESTCON := .F.
	Local lTemPad  := .F.
	Local oTmpTbl6
	Local nIndSTC := IIf( lSequeSTC,NGRETORDEM( "STC","TC_FILIAL+TC_CODBEM+TC_TIPMOD+TC_COMPONE+TC_TIPOEST+TC_LOCALIZ+TC_SEQRELA",.T. ),1 )

	Private cFAM := GetNextAlias() //Alias do oTmpTbl6

	Dbselectarea(cTRBSTC)
	lTESTCON := If(Reccount() > 0,.T.,.F.)

	ST9->(Dbseek(xFILIAL('ST9')+cPAI))

	If ST9->T9_TEMCONT = 'S' .And. lTESTCON
		If !Positivo(nPOSCONT) .Or. !Naovazio(nPOSCONT) .Or. !CHKPOSLIM(cPAI,nPOSCONT,1);
		.Or. !NGVALHORA(cHORALE1,.T.)
			Return .F.
		Endif
		If !NGCHKHISTO(cPAI,dULTACOM,nPOSCONT,cHORALE1,1,,.T.)
			Return .F.
		Endif
		If !NGVALIVARD(cPAI,nPOSCONT,dULTACOM,cHORALE1,1,.T.)
			Return .F.
		Endif
	Endif
	If TIPOACOM2
		If !Positivo(nPOSCONT2) .Or. !Naovazio(nPOSCONT2) .Or. !CHKPOSLIM(cPAI,nPOSCONT2,2);
		.Or. !NGVALHORA(cHORALE2,.T.)
			Return .F.
		Endif
		If !NGCHKHISTO(cPAI,dDATA1,nPOSCONT2,cHORALE2,2,,.T.)
			Return .F.
		Endif
		If !NGVALIVARD(cPAI,nPOSCONT2,dDATA1,cHORALE2,2,.T.)
			Return .F.
		Endif
	Endif

	cFami := ST9->T9_CODFAMI+Space(16-Len(ST9->T9_CODFAMI))

	If lTipMod
		cModelo := ST9->T9_TIPMOD
	Endif

	// ---------------------------------------------
	// Realiza busca da estrutura padrão (STC / TC_TIPOEST = 'F')
	// ---------------------------------------------
	DbSelectArea("STC")
	DbSetOrder(1) // TC_FILIAL, TC_CODBEM, TC_COMPONE, TC_TIPOEST, TC_LOCALIZ, TC_SEQRELA

	// Filtra apenas os registros da filial corrente e de tipo 'F' (Estrutura padrão)
	Set Filter To STC->TC_FILIAL = xFilial("STC") .And. STC->TC_TIPOEST == "F"
	dbseek(xFILIAL('STC'))

	// A partir do release 12.1.33, o tipo modelo será utilizado
	// na busca de estrutura padrão, mesmo em ambientes sem Gestão de Frotas
	If lRel12133

		// Busca e posiciona na estrutura padrão
		lTemPad := MNTSeekPad( 'STC', ;
								nIndSTC, ; // TC_FILIAL+TC_CODBEM+TC_TIPMOD+TC_COMPONE+TC_TIPOEST+TC_LOCALIZ+TC_SEQRELA
								Padr( ST9->T9_CODFAMI, Len( STC->TC_CODBEM ) ), ;
								ST9->T9_TIPMOD )

	Else

		If lTipMod

			STC->(DbSetOrder( nIndSTC ))
			lTemPad := dbSeek(xFILIAL('STC')+cFAMI+cModelo)

		Else

			STC->(DbSetOrder(1))
			lTemPad := dbSeek( xFILIAL('STC') + cFAMI )

		EndIf

	EndIf

	// Caso não seja encontrado uma estrutura padrão
	If !lTemPad
		dbselectarea("STC")
		Set Filter To
		Return .T.
	Endif

	//+-------------------------------------------------------------------+
	//| Cria Arquivo de Estrutura Padrao                                  |
	//+-------------------------------------------------------------------+
	aDBF  := STC->(DbStruct())
	aAdd(aDBF,{"TC_OK","C" ,01, 0})

	//Intancia classe FWTemporaryTable
	oTmpTbl6  := FWTemporaryTable():New( cFAM, aDBF )
	//Cria indices
	oTmpTbl6:AddIndex( "Ind01" , {"TC_CODBEM","TC_COMPONE","TC_LOCALIZ"} )
	//Cria a tabela temporaria
	oTmpTbl6:Create()

	Dbselectarea("STC")
	If lTipMod
		DbSetOrder(5) // TC_FILIAL+TC_CODBEM+TC_TIPMOD+TC_COMPONE+TC_TIPOEST+TC_LOCALIZ+TC_SEQRELA
		// Alimenta a tabela temporária 'cFAM' com a estrutura padrão completa (Pai + Filhos)
		NGMAKEF090( STC->TC_CODBEM, STC->TC_TIPMOD )
	Else
		DbSetOrder(1)
		Dbseek(xFILIAL('STC') + cFami)
		NGMAKEF090(cFami)
	Endif

	Dbselectarea(cFAM)
	Dbgotop()
	lRET := NGCHFAM090((cFAM)->TC_CODBEM,(cFAM)->TC_COMPONE)

	oTmpTbl6:Delete()

	Dbselectarea("STC")
	Set Filter To

Return lRET

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGMAKEF090  ³ Autor ³ Paulo Pego          ³ Data ³ 28/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ CRIA ARRAY MULTIDIMENSIONAL COM A ESTRUTURA PADRAO         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function NGMAKEF090(cPAI, cModelo)

    Local nREC, ng3

	DbSelectArea("STC")

	If lTipMod

		While !Eof()                                 .And. ;
			Alltrim(STC->TC_CODBEM) == Alltrim(cPAI) .And. ;
			STC->TC_FILIAL == xFILIAL('STC')         .And. ;
			STC->TC_TIPMOD == cModelo

			nREC  := RECNO()
			cCOMP := STC->TC_COMPONE
			Dbselectarea(cFAM)
			If !Dbseek(stc->tc_codbem+stc->tc_compone+stc->tc_localiz)
				(cFAM)->(DbAppend())
				For ng3 := 1 TO 10
					(cFAM)->(FieldPut(ng3, STC->(FIELDGET(ng3)) ))
				Next ng3
				MsUnlock()
			Endif

			Dbselectarea("STC")
			If Dbseek(xFILIAL('STC')+cCOMP)
				NGMAKEF090(cCOMP)
			Endif

			Dbgoto(nREC)
			Dbskip()
		End

	Else
		While !Eof() .And. Alltrim(STC->TC_CODBEM) == Alltrim(cPAI) .And.;
		STC->TC_FILIAL == xFILIAL('STC')
			nREC  := RECNO()
			cCOMP := STC->TC_COMPONE
			Dbselectarea(cFAM)
			If !Dbseek(stc->tc_codbem+stc->tc_compone+stc->tc_localiz)
				(cFAM)->(DbAppend())
				For ng3 := 1 TO 10
					(cFAM)->(FieldPut(ng3, STC->(FIELDGET(ng3)) ))
				Next ng3
				MsUnlock()
			Endif

			Dbselectarea("STC")
			If Dbseek(xFILIAL('STC')+cCOMP)
				NGMAKEF090(cCOMP)
			Endif

			Dbgoto(nREC)
			Dbskip()
		End
	Endif

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGCHFAM090  ³ Autor ³ Paulo Pego          ³ Data ³ 28/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ CRIA ARRAY MULTIDIMECIONAL COM A ESTRUTURA PADRAO          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGCHFAM090(cPai,cFilho)
	Local lRet:=.T.,lFound:=.T.

	Dbselectarea(cTRBSTC)
	Dbsetorder(3)
	Dbselectarea(cFAM)
	DbGotop()
	While !Eof()

		lFound := .T.
		Dbselectarea(cTRBSTC)
		If !Dbseek((cFAM)->TC_CODBEM+(cFAM)->TC_COMPONE)
			lFound := .F.
		Else
			If !Empty((cFAM)->TC_LOCALIZ)
				lFound := .F.
				While !Eof() .And. Alltrim((cTRBSTC)->TC_FAMBEM) == Alltrim((cFAM)->TC_CODBEM) .And.;
				Alltrim((cTRBSTC)->TC_FAMCOMP) == Alltrim((cFAM)->TC_COMPONE)

					If (cFAM)->TC_OK  <> "S"
						If (cTRBSTC)->TC_LOCALIZ == (cFAM)->TC_LOCALIZ
							lFound := .T.
							(cFAM)->TC_OK := 'S'
							Exit
						Endif
					Endif
					(cTRBSTC)->(Dbskip())
				End
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Checagem da localizacao na Estrutura Padrao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If !lFound
			If (cFAM)->TC_OBRIGAT == "S"
				If ST6->(Dbseek(xFilial('ST6')+Alltrim((cFAM)->TC_COMPONE)))
					If TPS->(Dbseek(xFILIAL("TPS")+(cFAM)->TC_LOCALIZ))
						cError := STR0082 + CHR(10)+CHR(10); //"Nao foi informado componente obrigatorio para: "
						+ STR0083 + Alltrim((cFAM)->TC_COMPONE)+" - "+Alltrim(ST6->T6_NOME) + CHR(10);//" Familia........: "
						+ STR0084 + Alltrim((cFAM)->TC_LOCALIZ)+" - "+Alltrim(TPS->TPS_NOME)  //" Localizacao: "
					Else
						cError := STR0082  + CHR(10)+CHR(10); //"Nao foi informado componente obrigatorio para: "
						+STR0083 + Alltrim((cFAM)->TC_COMPONE)+" - "+Alltrim(ST6->T6_NOME) //" Familia........: "
					EndIf

				Else
					cError := " "
				Endif
				Help(" ",1,"FORAPADRA",,cError,5,1)
				lRet := .F.
				Exit
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Checagem do contador na Estrutura Padrao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If !Empty((cTRBSTC)->TC_COMPONE)
			Dbselectarea("ST9")
			Dbsetorder(1)
			Dbseek(xFilial('ST9')+(cTRBSTC)->TC_COMPONE)
			If (cFAM)->TC_CONTADO == "S"
				If ST9->T9_TEMCONT == 'N'
					cError := Alltrim(ST9->T9_CODBEM) + "-" + Alltrim(ST9->T9_NOME)
					Help(" ",1,"CONTAPADRA",,cError,5,1)
					lRet := .F.
					Exit
				Endif
			EndIf
		Endif

		Dbselectarea(cFAM)
		Dbskip()
	End
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGVIEWE090  ³ Autor ³ Paulo Pego          ³ Data ³ 28/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Visualiza a estrutura Padrao                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGVIEWE090()

	Local lTemPad := .T.
	Local nIndSTC := IIf( lSequeSTC,NGRETORDEM( "STC","TC_FILIAL+TC_CODBEM+TC_TIPMOD+TC_COMPONE+TC_TIPOEST+TC_LOCALIZ+TC_SEQRELA",.T. ),1 )

	M->TC_TIPOEST := "F"

	//--------------------------------------------------------------------------------
	// Filtra apenas os registros da filial corrente e de tipo 'F' (Estrutura padrão)
	//--------------------------------------------------------------------------------
	Dbselectarea("STC")

	// A partir do release 12.1.33, o tipo modelo será utilizado
	// na busca de estrutura padrão, mesmo em ambientes sem Gestão de Frotas
	If lRel12133

		// Busca e posiciona na estrutura padrão
		lTemPad := MNTSeekPad( 'STC', ;
								5, ; // TC_FILIAL+TC_CODBEM+TC_TIPMOD+TC_COMPONE+TC_TIPOEST+TC_LOCALIZ+TC_SEQRELA
								Padr( cCodFam, Len( STC->TC_CODBEM ) ), ;
								cModelo )

	Else

		If lTipMod
			dbSetOrder( nIndSTC )
			Set Filter To STC->TC_FILIAL = xFilial("STC") .And. STC->TC_TIPOEST == "F"
			lTemPad := Dbseek(xFILIAL('STC')+cFamEst+cModelo)
		Else
			dbSetOrder(1)
			Set Filter To STC->TC_FILIAL = xFilial("STC") .And. STC->TC_TIPOEST == "F"
			lTemPad := Dbseek(xFILIAL('STC') + cFamEst)
		EndIf

	EndIf

	If lTemPad
		// ESTA FUNÇÃO ESTÁ NO MNTA095.PRW
		NG095PROCES("STC",1,2)
	Else
		MsgInfo(STR0101,STR0037) // "Não há estrutura padrão cadastrada para o componente selecionado."##ATENCAO
	EndIf

	M->TC_TIPOEST := "B"
	Dbselectarea("STC")
	Set Filter To
	Dbsetorder(1)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MOSCENCALE  ³ Autor ³                     ³ Data ³ 28/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Mostra os nomes dos centro e calendario                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MOSCENCALE() // ESTA FUNCAO NAO PODERµ SER RENOMIADA PORQUE E CHAMADA DO SX3
	Local ARQ := Alias(), cBEMOSCEN := If(VOPCAO = 5,(cTRBSTC)->TC_COMPONE,cFIRST)
	Dbselectarea("ST9")
	If Dbseek(xFILIAL('ST9')+M->TC_COMPONE)
		If ST9->T9_MOVIBEM == "N"
			M->TC_CCUSTO  := ST9->T9_CCUSTO
			M->TC_CENTRAB := ST9->T9_CENTRAB
			M->TC_CALENDA := ST9->T9_CALENDA
			M->TC_DCUSTO  := NGSEEK('SI3',M->TC_CCUSTO ,1,"Substr(I3_DESC,1,20)")
			M->TC_DTRAB   := NGSEEK('SHB',M->TC_CENTRAB,1,"Substr(HB_NOME,1,20)")
			M->TC_DCUSTO  := NGSEEK('SI3',M->TC_CCUSTO ,1,"Substr(I3_DESC,1,20)")
			M->TC_NOMCALE := NGSEEK('SH7',M->TC_CALENDA,1,"Substr(H7_DESCRI,1,20)")
		Else
			dbSelectArea("ST9")
			dbsetOrder(1)
			If dbSeek(xFilial("ST9")+cBEMOSCEN)
				M->TC_CCUSTO  := ST9->T9_CCUSTO
				M->TC_CENTRAB := ST9->T9_CENTRAB
				M->TC_CALENDA := ST9->T9_CALENDA
				M->TC_DCUSTO  := NGSEEK('SI3',M->TC_CCUSTO ,1,"Substr(I3_DESC,1,20)")
				M->TC_DTRAB   := NGSEEK('SHB',M->TC_CENTRAB,1,"Substr(HB_NOME,1,20)")
				M->TC_DCUSTO  := NGSEEK('SI3',M->TC_CCUSTO ,1,"Substr(I3_DESC,1,20)")
				M->TC_NOMCALE := NGSEEK('SH7',M->TC_CALENDA,1,"Substr(H7_DESCRI,1,20)")
			EndIf
		EndIf
	Endif
	lREFRESH := .T.
	Dbselectarea(ARQ)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGMOVE090   ³ Autor ³ Deivys Joenck       ³ Data ³ 28/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Navega‡Æo nos elementos da estrutura ( localiza‡Æo )        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGMOVE090(cCOD)

	Local oMenu

	(cTRBSTC)->(Dbsetorder(2))

	If cCOD == cPAI
		oTREE:BRCLICKED := {||}
		oTree:blDblClick := { || MNT090VILB(cCOD)}

		If STR(nOPCAO,1) $ "3/4"
			@ 155,125 BUTTON STR0120 SIZE 28,11 PIXEL WHEN .F. OF ODlgStru //"Editar"
			@ 155,156 BUTTON STR0121 SIZE 52,11 PIXEL WHEN .F. OF ODlgStru //"Saída componente"
		Endif
	Else
		NGPOPUP(aSMenu,@oMenu)
		oTree:bRClicked:= { |o,x,y| oMenu:Activate(x-350,y-350,ODlgStru)}
		oTree:blDblClick := { || MNT090VILB(cCOD)}

		If STR(nOPCAO,1) $ "3/4"
			@ 155,125 BUTTON STR0120 SIZE 28,11 PIXEL WHEN .T. OF ODlgStru ACTION NGINCFIL090(4) //"Editar"
			@ 155,156 BUTTON STR0121 SIZE 52,11 PIXEL WHEN .T. OF ODlgStru ACTION NGINCFIL090(5) //"Saída componente"
		Endif
	Endif

	Store " " To cBEM2,cLOC1,cLOC2,cLOC3

	If (cTRBSTC)->(Dbseek(cCOD))     // .And. oLbx:Cargo:nLevel > 1
		ST9->(Dbseek(xFILIAL('ST9')+(cTRBSTC)->TC_COMPONE))
		If !Empty((cTRBSTC)->TC_LOCALIZ)
			If TPS->(Dbseek(xFILIAL("TPS")+(cTRBSTC)->TC_LOCALIZ))
				cLOC1 := STR0022
				cLOC2 := (cTRBSTC)->TC_LOCALIZ
				cLOC3 := Alltrim(TPS->TPS_NOME)
				cBEM2 := (cTRBSTC)->TC_COMPONE
			Endif
		Endif
	Endif

	oLOC1:Refresh()
	oLOC2:Refresh()
	oLOC3:Refresh()

	(cTRBSTC)->(Dbsetorder(1))
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CHKCONT     ³ Autor ³                     ³ Data ³ 28/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CHKCONT()
	If dOLDACOM < dULTACOM
		If !CHKPOSLIM(cPAI,nPOSCONT,1)
			Return .F.
		Endif
	Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CHKVARIACAO ³ Autor ³                     ³ Data ³ 28/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CHKVARIACAO()
	If DDATA1 > dDATA2
		If !CHKPOSLIM(cPAI,nPOSCONT2,2)
			Return .F.
		Endif
	Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CHKSEGCON   ³ Autor ³                     ³ Data ³ 28/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CHKSEGCON(cPAI)
	Dbselectarea("TPE")
	Dbsetorder(1)
	TIPOACOM2 := If(Dbseek(xFILIAL("TPE")+cPAI),.T.,.F.)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGC090    ³ Autor ³ Thiago Olis Machado   ³ Data ³ 05/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta um browse com as ordens de Manutencao do Bem         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Mnta090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGC090(cBEM2)
	Local OLDDETALHE,cCONDICAO
	Private cORDEM
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Salva a integridade dos dados                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private cCADASTRO := OEMTOANSI(STR0031) //"Ordem de Servico"
	OLDDETALHE := aCLONE(aROTINA)
	aROTINA    := {{STR0003,"NGCAD01" , 0, 2},;   //"Visual."
	{STR0030,"MNT090TAR", 0, 3, 0}} //"Tarefas"

	aNgButton := {{,,},;
		{,{ || !NGCALLSTACK('NGC090',.T.) .And. NGC090((cTRBSTC)->TC_COMPONE)}, 'Consulta de O.s                         '}}

	Dbselectarea("STJ")
	Dbsetorder(2)

	cKEY   := "B"+cBEM2
	bWHILE := {|| !Eof() .And. STJ->TJ_TIPOOS = "B" .AND. STJ->TJ_CODBEM  == cBEM2}
	bFOR   := {|| TJ_FILIAL  == xFILIAL("STJ") }
	cORDEM := STJ->TJ_ORDEM

	NGCONSULTA("TRBJ",cKEY,bWHILE,bFOR,aROTINA,{})
	Dbselectarea("STJ")
	Dbsetorder(1)

	aROTINA := aCLONE(OLDDETALHE)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNT090TAR ³ Autor ³ Thiago Olis Machado   ³ Data ³ 05/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta um browse com as ordens de Manutencao do Bem         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Mnta090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNT090TAR()
	Dbselectarea("STJ")
	If Empty(STJ->TJ_ORDEM)
		Return NIL
	Endif
	cORDEM := STJ->TJ_ORDEM
	OLDROT := aCLONE(aROTINA)
	cKEY   := cORDEM

	Private aROTINA := {{STR0003,"NGCAD01", 0, 2}} //"Visualizar"

	aPOS1     := {15,1,95,315}
	cCADASTRO := OEMTOANSI(STR0030) //"Tarefas"

	Dbselectarea("STL")
	Dbsetorder(01)
	Dbseek(xFILIAL("STL")+cORDEM)

	bWHILE := {|| !Eof() .And. STL->TL_ORDEM == cORDEM}
	bFOR   := {|| STL->TL_FILIAL  == xFILIAL("STL") .And. STL->TL_ORDEM == cORDEM}

	NGCONSULTA("TRB9",cORDEM,bWHILE,bFOR,aROTINA,{})
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGOSREFORM³ Autor ³In cio Luiz Kolling    ³ Data ³31/07/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se Ha ordem de reforma para a estrutura (Bem Pai ) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Mnta090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGOSREFORM(cCODBEM)
	Local lOSREFOR := .T.
	Local aArea:= GetArea()

	Dbselectarea("STJ")
	Dbsetorder(14)
	If Dbseek(xFILIAL("STJ")+cCODBEM+'P'+'N')
		lOSREFOR := .F.
	Else
		cBEMAUX := SPACE(Len(ST9->T9_CODBEM))
		cBEMAUX := NGBEMPAI(cCODBEM)
		If !Empty(cBEMAUX)
			Dbselectarea("STJ")
			Dbsetorder(14)
			If Dbseek(xFILIAL("STJ")+cBEMAUX+'P'+'N')
				lOSREFOR := .F.
			Endif
		Endif
	Endif

	If !lOSREFOR
		Dbselectarea("ST9")
		Dbsetorder(1)
		Dbseek(xFILIAL("ST9")+STJ->TJ_BEMPAI)
		MSGINFO(STR0033+chr(13)+chr(13);        // "A Estrutura Nao Podera Ser Alterada ou Excluida Porque"
		+STR0034+chr(13)+chr(13);        // "Existe Ordem de Reforma Pendentes..."
		+STR0035+Alltrim(STJ->TJ_BEMPAI)+" - "+SUBSTR(ST9->T9_NOME,1,30)+chr(13)+chr(13); // "Bem Pai Da Ordem  -> "
		+STR0036+STJ->TJ_ORDEPAI,STR0037)  // "Ordem Reforma Pai -> "###"ATENCAO"
	Endif
	//Dbselectarea(cALISOLD)
	//Dbsetorder(nINDIOLD)
	RestArea(aArea)
Return lOSREFOR

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGSEGTRE90  ³ Autor ³ Deivys Joenck       ³ Data ³ 21/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Busca Itens filhos na estrutura - Funcao Recursiva         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGSEGTRE90(cCOMPONE)
	Local nREC2,cCARGO
	Local nIndSTC := IIf( lSequeSTC,NGRETORDEM( "STC","TC_FILIAL+TC_CODBEM+STR(TC_SEQUEN,6)+TC_COMPONE",.T. ),1 )

	cDESC2 := cCOMPONE+REPLICATE(" ",25-Len(RTRIM(cCOMPONE)))
	Dbselectarea("ST9")
	Dbsetorder(1)
	If Dbseek(xFILIAL("ST9")+cCOMPONE)
		cPRODESC := cDESC2+' - '+SUBSTR(ST9->T9_NOME,1,40)
	Endif

	cCARGO := cCOMPONE
	oTREE:ADDITEM(cPRODESC,cCARGO,"FOLDER5","FOLDER6",,, 2)
	oTREE:TREESEEK(cCARGO)
	Dbselectarea("STC")
	Dbsetorder( nIndSTC )
	Dbseek(xFILIAL("STC")+cCOMPONE)
	While !Eof() .And. STC->TC_FILIAL == xFILIAL("STC") .And.;
	STC->TC_CODBEM == cCOMPONE

		nREC2 := RECNO()
		cCOMP := STC->TC_COMPONE
		cITEM := If(ST9->(Dbseek(xFILIAL("ST9")+cCOMP)),ST9->T9_NOME, " " )
		Dbselectarea("STC")
		Dbsetorder( nIndSTC )
		If Dbseek(xFILIAL("STC")+cCOMP)
			NGSEGTRE90(cCOMP)
			oTREE:TREESEEK(cCARGO)
		Else
			cCARGO   := cCOMP
			cCOMP    := cCOMP+REPLICATE(" ",25-Len(RTRIM(cCOMP)))
			cPRODESC := cCOMP+' - '+cITEM
			oTREE:ADDITEM(cPRODESC,cCARGO,"FOLDER5","FOLDER6",,, 2)
		Endif
		Dbselectarea("STC")
		Dbgoto(nREC2)
		Dbskip()
	End
	DBENDTREE oTREE
	oTREE:REFRESH()
	oTREE:SETFOCUS()
	ODlgStru:REFRESH()
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NG090CHK1 ³ Autor ³Deivys Joenck          ³ Data ³30/01/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NG090CHK1()
	If !Empty(M->TC_LOCALIZ)
		cNOMLOCA := NGSEEK('TPS',M->TC_LOCALIZ,1,'TPS_NOME')
		If Empty(cNOMLOCA)
			HELP(" ",1,"REGNOIS")
			Return .F.
		Endif
	Endif
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NG090CHK2 ³ Autor ³Deivys Joenck          ³ Data ³30/01/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NG090CHK2()
	M->I3_DESC := NGSEEK('SI3',M->TC_CCUSTO,1,'I3_DESC')
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NG090CHK3 ³ Autor ³Deivys Joenck          ³ Data ³30/01/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NG090CHK3()
	If !Empty(M->TC_CENTRAB)
		M->HB_NOME := NGSEEK('SHB',M->TC_CENTRAB,1,'HB_NOME')
		If Empty(M->HB_NOME)
			HELP(" ",1,"REGNOIS")
			Return .F.
		Endif
		If !CHKCENTRAB(M->TC_CENTRAB,M->TC_CCUSTO)
			Return .F.
		Endif
	Endif
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NG090CHK4 ³ Autor ³Deivys Joenck          ³ Data ³30/01/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NG090CHK4()
	M->H7_DESCRI := NGSEEK('SH7',M->TC_CALENDA,1,'H7_DESCRI')
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NG90DTVAL ³ Autor ³Deivys Joenck          ³ Data ³30/01/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NG90DTVAL()
	l090DTVAL := .F.
	If M->TC_DATAINI < dDTIMPL
		MSGINFO(STR0049+chr(13)+chr(13);
		+STR0061+Dtoc(M->TC_DATAINI)+chr(13); //"Data Informada.: "
		+STR0062+Dtoc(dDTIMPL),STR0063) //"Data Aquisicao.: "###"NAO CONFORMIDADE"
		Return .F.
	Endif
	If M->TC_DATAINI < dDATABASE
		If !MSGYESNO(STR0048+chr(13)+chr(13);
		+STR0061+Dtoc(M->TC_DATAINI)+chr(13); //"Data Informada.: "
		+STR0064+Dtoc(dDataBase)+chr(13)+chr(13); //"Data Atual.........: "
		+STR0065,STR0037) //"Confirma (Sim/Nao)"
			Return .F.
		Endif
	Endif
	If M->TC_DATAINI > dDATABASE
		MsgInfo(STR0066+chr(13); //"Data de implantacao devera ser menor ou igual"
		+STR0067+chr(13)+chr(13); //"a data atual.."
		+STR0061+Dtoc(M->TC_DATAINI)+chr(13); //"Data Informada.: "
		+STR0064+Dtoc(dDataBase),STR0063) //"Data Atual.........: "###"NAO CONFORMIDADE"
		Return .F.
	Endif
	l090DTVAL := .T.
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTA090DS ³ Autor ³In cio Luiz Kolling    ³ Data ³24/09/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consistencia da data de saida do componente                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTA090DS()
	Local cMENSA1 := Space(10)
	l090DS := .F.
	If !Naovazio(M->TC_DATAINI)
		Return .F.
	Endif
	If M->TC_DATAINI < dDATASAI
		cMENSA1 := STR0068+chr(13); //"Data de saida devera ser maior ou igual"
		+STR0069+chr(13)+chr(13); //"a data de implantacao."
		+STR0070+Dtoc(M->TC_DATAINI)+chr(13); //"Data Informada..........: "
		+STR0071+Dtoc(dDATASAI) //"Data da Implantacao.: "
	Endif
	If Empty(cMENSA1)
		If M->TC_DATAINI > dDataBase
			cMENSA1 := STR0072+chr(13); //"Data de saida devera ser menor ou igual"
			+STR0067+chr(13)+chr(13); //"a data atual.."
			+STR0061+Dtoc(M->TC_DATAINI)+chr(13); //"Data Informada.: "
			+STR0064+Dtoc(dDataBase) //"Data Atual.........: "
		Endif
	Endif

	If !Empty(cMENSA1)
		MsgInfo(cMENSA1,STR0063) //"NAO CONFORMIDADE"
		Return .F.
	Endif
	l090DS := .T.
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTA090HS ³ Autor ³In cio Luiz Kolling    ³ Data ³24/09/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consistencia da hora de saida do componente                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTA090HS()
	Local cMENSA1 := Space(10)
	l090HS := .F.
	If !NGVALHORA(cHORSAIDA,.T.)
		Return .F.
	Endif
	If M->TC_DATAINI = dDATASAI
		If cHORSAIDA <= cHORAUX
			cMENSA1 := STR0073+chr(13); //"A hora de saida devera ser maior do que"
			+STR0074+chr(13)+chr(13); //"a hora de implantacao."
			+STR0075+ cHORSAIDA+chr(13); //"Hora informada..........: "
			+STR0076+ cHORAUX //"Hora da implantacao.: "
		Endif
	Endif

	If Empty(cMENSA1)
		If M->TC_DATAINI = dDataBase
			If cHORSAIDA > Substr(TIME(),1,5)
				cMENSA1 := STR0077+chr(13); //"A hora de saida devera ser menor do que"
				+STR0078+chr(13)+chr(13); //"a hora atual."
				+STR0079+ cHORSAIDA+chr(13); //"Hora informada.: "
				+STR0080+ Substr(time(),1,5) //"Hora atual.........: "
			Endif
		Endif
	Endif

	If !Empty(cMENSA1)
		MsgInfo(cMENSA1,STR0063) //"NAO CONFORMIDADE"
		Return .F.
	Endif
	l090HS := .T.
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTA090DC ³ Autor ³In cio Luiz Kolling    ³ Data ³24/09/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consistencia final da saida do componente                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTA090DC()

	Local lNgLanCon := .T.

	If LEHORASAI
		If !l090DS
			If !MNTA090DS()
				Return .F.
			Endif
		Endif

		If !l090HS
			If !MNTA090HS()
				Return .F.
			Endif
		Endif

		//Consiste a movimentacao do componente valida
		If !NGCONSTZ(M->TC_COMPONE,M->TC_DATAINI,cHORSAIDA, ,M->TC_LOCALIZ)
			Return .F.
		EndIf

		//PE destinado a inibir a validação que impede lançamentos futuros para compomentes.
		If ExistBlock("MNTA0902")
			lNgLanCon := ExecBlock("MNTA0902", .F., .F.)
		EndIf

		If lNgLanCon
			If !NGLANCON(M->TC_COMPONE,M->TC_DATAINI,cHORSAIDA,CPAI)
				Return .F.
			EndIf
		EndIf

	Endif
	lRET := .T.
	oDLG2:END()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTA090HI ³ Autor ³In cio Luiz Kolling    ³ Data ³24/09/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consistencia da hora da implantacao do componente           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTA090HI()

	l090HI := .F.

	If !Empty( StrTran( cHORSAIDA , ':' , '' ) )

		If !NGVALHORA(cHORSAIDA,.T.)
			Return .F.
		Endif
		If M->TC_DATAINI = dDataBase
			If cHORSAIDA > Substr(TIME(),1,5)
				MsgInfo(STR0081+chr(13); //"A hora da implantacao devera ser menor do que"
				+STR0078+chr(13)+chr(13); //"a hora atual."
				+STR0079+ cHORSAIDA+chr(13); //"Hora informada.: "
				+STR0080+ Substr(time(),1,5),STR0063) //"Hora atual.........: "###"NAO CONFORMIDADE"
				Return .F.
			Endif
		Endif
	Else

		Help( '', 1, 'HORAINVA' ) // A Hora não pode estar vazia.
		Return .F.

	EndIf

	l090HI := .T.

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTA090IM ³ Autor ³In cio Luiz Kolling    ³ Data ³24/09/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consistencia final da implantacao do componente             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTA090IM(cOPCCADAS,nCONTE1,nCONTE2,cHORSAIDA,LECONTEUM,LECONTEDO,lCOMPNOVO)

	Local cHORAENL,dDTENTLO

	If !l090DTVAL
		If !NG90DTVAL()
			Return .F.
		Endif
	Endif
	If !l090HI
		If !MNTA090HI()
			Return .F.
		Endif
	Endif

	If cOPCCADAS = 3 .Or. cOPCCADAS = 4 //Consiste a movimentacao do componente valida
		If !NGCONSTZ(M->TC_COMPONE,M->TC_DATAINI,cHORSAIDA,"E",M->TC_LOCALIZ)
			Return .F.
		EndIf
	Else
		//Verifica se houve troca de localizacao
		If cLOCALINI <> M->TC_LOCALIZ

			//Consiste a Saida da localizacao inicial
			If !NGCONSTZ(M->TC_COMPONE,M->TC_DATAINI,cHORSAIDA, ,cLOCALINI)
				Return .F.
			EndIf

			//Consiste a entrada na localizacao final
			cHORAENL := MTOH(HTOM(SubStr(cHORSAIDA,1,5))+1)  //Hora da entrada para o comp que trocou de localizacao
			If cHORAENL = "24:00"
				cHORAENL := "00:00"
			EndIf
			dDTENTLO := If(Alltrim(cHORAENL) = "00:00",M->TC_DATAINI+1,M->TC_DATAINI) //Data da entrada para o comp que trocou de localizacao

			If !NGCONSTZ(M->TC_COMPONE,dDTENTLO,cHORAENL,"E",M->TC_LOCALIZ)
				Return .F.
			EndIf

		EndIf

	EndIf

	//Valida contador 1 do bem que tem contador proprio
	If lCOMPNOVO .And. lOPT2

		//Valida contador 1
		If LECONTEUM
			If nCONTE1 > 0
				If !MNT90VCON(cPAI,M->TC_COMPONE,M->TC_DATAINI,nCONTE1,cHORSAIDA,1)
					Return .F.
				EndIf
			Else
				MsgInfo(STR0090,STR0037)//"Informe um contador 1 valido para o componente." # ATENCAO
				Return .F.
			EndIf
		EndIf

		//Valida contador 2
		If LECONTEDO
			If nCONTE2 > 0
				If !MNT90VCON(cPAI,M->TC_COMPONE,M->TC_DATAINI,nCONTE2,cHORSAIDA,2)
					Return .F.
				EndIf
			Else
				MsgInfo(STR0091,STR0037) //"Informe um contador 2 valido para o componente." # ATENCAO
				Return .F.
			EndIf
		EndIf

	EndIf

	If ExistBlock("MNTA0901")
		If !ExecBlock("MNTA0901",.F.,.F.)
			Return .F.
		EndIf
	EndIf

	lRET := .T.
	oDLG2:END()
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGTBEMPTE ³ Autor ³Elisangela Costa       ³ Data ³06/09/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica e retorna o codigo do bem pai de determinado comp. ³±±
±±³          ³da estrutura (Componente cont. pelo Pai da Estrutura ou     ³±±
±±³          ³imediato                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cVBEM    - C¢digo do bem                      - Obrigatorio ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³cBEMRET  - Codigo do bem pai do componente da estrutura de  ³±±
±±³          ³           bens.                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGTBEMPTE(cVBEM,TRBXY)
	Local ccalias := Alias(),nvordem := INDEXORD(),cVBEMAU := cVBEM

	TIPOACOM  := .F.
	TIPOACOM2 := .F.
	cBEMRET   := " "

	cARCAMP090 := TRBXY+"->TC_CODBEM"

	DbSelectArea("ST9")
	DbSetOrder(01)
	If DbSeek(xFilial("ST9")+cVBEMAU)

		cTIPOCON := ST9->T9_TEMCONT
		DbSelectArea(TRBXY)
		If DbSeek(cVBEMAU)
			If ST9->T9_TEMCONT = "P"
				While .T.
					If DbSeek(cVBEMAU)
						cVBEMAU :=  &(cARCAMP090)
					Else
						Exit
					EndIf
				End
				If !Empty(cVBEMAU)
					DbSelectArea("ST9")
					DbSetOrder(01)
					If DbSeek(xFilial("ST9")+cVBEMAU)
						If ST9->T9_TEMCONT = "S"
							cBEMRET := NGTBEMCON(cVBEMAU)
						EndIf
					EndIf
				EndIf
			ElseIf ST9->T9_TEMCONT = "I"
				While .T.
					DbSelectArea("ST9")
					DbSetOrder(01)
					If DbSeek(xFilial("ST9")+cVBEMAU)
						If ST9->T9_TEMCONT = "S"
							cBEMRET := NGTBEMCON(cVBEMAU)
							If cTIPOCON = "I"
								Exit
							EndIf
						EndIf
					EndIf

					DbSelectArea(TRBXY)
					If DbSeek(cVBEMAU)
						cVBEMAU := &(cARCAMP090)
					Else
						DbSelectArea("ST9")
						DbSetOrder(01)
						If DbSeek(xFilial("ST9")+cVBEMAU)
							If ST9->T9_TEMCONT = "S"
								cBEMRET := NGTBEMCON(cVBEMAU)
							EndIf
						Else
							TIPOACOM  := .F.
							TIPOACOM2 := .F.
							cBEMRET   := Space(Len(cVBEM))
						EndIf
						Exit
					EndIf
				End
			EndIf
		EndIf
	EndIf
	DbSelectArea(ccalias)
	DbSetOrder(nvordem)

Return cBEMRET

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGRETCPAI ³ Autor ³Elisangela Costa       ³ Data ³20/10/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o contador do bem pai para o componente             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cVBEMPAI  - C¢digo do Bem Pai                  - Obrigatorio³±±
±±³          ³nTIPOCONT - Tipo do Contador                   - Obrigatorio³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³nPOSCPAI - Contador do bem pai para componentes controlados ³±±
±±³          ³           pelo pai da estrutura e pai imediato             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGRETCPAI(cVBEMPAI,nTIPOCONT)

	Local vARQHIS := If(nTIPOCONT = 1,{'ST9','st9->t9_poscont','(cTRBXC)->TC_CONT1AT'},;
	{'TPE','tpe->tpe_poscon','(cTRBXC)->TC_CONT2AT'})

	nPOSCPAI := 0
	If cVBEMPAI = cPAI
		If nTIPOCONT = 1
			nPOSCPAI := nCONTPAI
		Else
			nPOSCPAI := nCONTPAI2
		EndIf
	Else
		DbSelectArea(cTRBXC)
		If DbSeek(cVBEMPAI)

			nPOSCPAI := &(vARQHIS[3])
			DbSelectArea(vARQHIS[1])
			nREGCONT := Recno()

			DbSelectArea(vARQHIS[1])
			DbSetOrder(01)
			If DbSeek(xFilial(vARQHIS[1])+cVBEMPAI)
				If &(vARQHIS[2]) > nPOSCPAI
					nPOSCPAI := &(vARQHIS[2])
				EndIf
			EndIf
			DbSelectArea(vARQHIS[1])
			DbGoto(nREGCONT)

		EndIf
	EndIf

Return nPOSCPAI

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNT090VILB³ Autor ³Elisangela Costa       ³ Data ³18/10/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Faz a chamada da tela do cadastro do bem no duplo click     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCODBEM090 - Codigo do comp. da estrutura selec.-obrigatorio³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT090VILB(cCODBEM090)

	Local aOldMenu1	:= ACLONE(asMenu)

	Private lCopia	:= .F. //Na rotina Estrutura de Bens, não contém a opção 'cópia'.
	Private lContEs	:= NGCADICBASE("TQZ_PRODUT","D","TQZ",.F.) //Indica que controla hist. do estoque dos pneus

	asMenu := {}
	DbSelectArea( "ST9" )
	DbSetOrder( 01 )
	DbSeek( xFilial( "ST9" )+cCODBEM090 )
	NG080FOLD( "ST9", Recno(), 2 )

	asMenu := ACLONE( aOldMenu1 )

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ricardo Dal Ponte     ³ Data ³29/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³      1 - Pesquisa e Posiciona em um Banco de Dados         ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef(lGFrota)
	Local lPyme   := Iif(Type("__lPyme") <> "U",__lPyme,.F.)
	Local aROTINA := {{STR0002,"NG090PESQUI", 0 , 1},;    //"Pesquisar"
	{STR0003,"NG090PROCES", 0 , 2},;    //"Visualizar"
	{STR0004,"NG090PROCES", 0 , 3},;    //"Incluir"
	{STR0005,"NG090PROCES", 0 , 4, 0},; //"Alterar"
	{STR0006,"NG090PROCES", 0 , 4, 3},;  //"Excluir"
	{STR0103,"MNT090FIL(cAliasSTC,aFIELD)", 0 , 3, 0}}//Filtro -> Alias e array de campos da TRB

	Default lGFrota := If(Select("SX2") > 0, MNTA090FR(),.F.)

	If !lPyme
		AAdd( aRotina, {STR0058, "NG090DOCUM", 0, 4 } )  //"Conhecimento"
	EndIf

	If lGFrota
		Aadd (aRotina,{STR0092,"NG090RODAD",0,6,0}) //"Rodados
	Endif

Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³NG090RODAD³ Autor ³ Felipe Nathan Welter  ³ Data ³ 04/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Chamada da consulta de rodados                              ³±±
±±³ÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³±±
±±³Parametros³cBem - Codigo do bem pai da estrutura                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NG090RODAD()
	Local aArea := GetArea()
	dbSelectArea("STC")
	dbSeek((cAliasSTC)->(TC_FILIAL+TC_CODBEM))
	MNTC820( STC->TC_CODBEM )
	dbSelectArea("STC")
	RestArea(aArea)
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MNT090ETPR³ Autor ³ Elisangela Costa      ³ Data ³27/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta a estrutura com as pecas de reposicao dos componentes ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT090ETPR()

	Local xy, nRECTRBTC, cCOMP
	Private oTREE090,ODLG090 //objeto

	//Carrega o arquivo temporario com as pecas de reposicao
	If lEstPecR
		lEstPecR := .F.

		//Busca as pecas de reposicao do bem pai
		aULTPECASR := NGPEUTIL(cPAI)

		For xy := 1 To Len(aULTPECASR)
			dbSelectArea(cTRBTPY)
			(cTRBTPY)->(DbAppend())
			(cTRBTPY)->CODBEM  := cPAI
			(cTRBTPY)->COMPONE := cPAI
			(cTRBTPY)->TIPOEST := "P"
			(cTRBTPY)->CODINSU := aULTPECASR[xy][1]
			(cTRBTPY)->DESCPEC := NGSEEK("SB1",aULTPECASR[xy][1],1,'SubStr(B1_DESC,1,20)')
			(cTRBTPY)->DATAULT := aULTPECASR[xy][2]
			(cTRBTPY)->HORAULT := aULTPECASR[xy][3]
		Next xy

		dbSelectArea(cTRBSTC)
		dbSetOrder(1)
		dbSeek(cPAI)
		While !Eof() .And. (cTRBSTC)->TC_CODBEM == cPAI

			If (cTRBSTC)->TC_COMPNOV == "S"
				dbSelectArea(cTRBSTC)
				dbSkip()
				Loop
			EndIf

			nRECTRBTC := Recno()
			cCOMP  := (cTRBSTC)->TC_COMPONE

			dbSelectArea(cTRBTPY)
			(cTRBTPY)->(DbAppend())
			(cTRBTPY)->CODBEM  := (cTRBSTC)->TC_CODBEM
			(cTRBTPY)->COMPONE := cCOMP
			(cTRBTPY)->TIPOEST := "B"

			//Busca as pecas de reposicao do bem pai
			aULTPECASR := NGPEUTIL(cCOMP)

			For xy := 1 To Len(aULTPECASR)
				dbSelectArea(cTRBTPY)
				(cTRBTPY)->(DbAppend())
				(cTRBTPY)->CODBEM  := cCOMP
				(cTRBTPY)->COMPONE := cCOMP
				(cTRBTPY)->TIPOEST := "P"
				(cTRBTPY)->CODINSU := aULTPECASR[xy][1]
				(cTRBTPY)->DESCPEC := NGSEEK("SB1",aULTPECASR[xy][1],1,'SubStr(B1_DESC,1,20)')
				(cTRBTPY)->DATAULT := aULTPECASR[xy][2]
				(cTRBTPY)->HORAULT := aULTPECASR[xy][3]
			Next xy

			dbSelectArea(cTRBSTC)
			If dbSeek(cCOMP)
				NG090PRTRE(cCOMP)
			EndIf

			dbSelectArea(cTRBSTC)
			dbgoto(nRECTRBTC)
			dbskip()
		End
	EndIf

	Define FONT NgFont NAME "Courier New" Size 6, 0
	Define MsDialog ODLG090 From  03.5,6 To 390,567 Title STR0088 COLOR CLR_BLACK,CLR_WHITE Pixel //"Peças de reposição dos bens da estrutura"

	@ 170,160 BITMAP oBmp1 Resource "FOLDER7" Size 10,10 Pixel Of ODLG090 NOBORDER When .F.
	@ 173,172 Say OemToAnsi(STR0089) Size 60,7 Of ODLG090 Pixel //"Peça de Reposição"
	Define sButton From 170,240 Type 1 Enable Of ODLG090 Action ODLG090:End()
	Activate MsDialog ODLG090 Centered On Init NGCARTRE090()

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³NG090PRTRE³ Autor ³ Elisangela Costa      ³ Data ³27/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava no temporario as pecas de reposicao dos componente    ³±±
±±³ÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³±±
±±³Parametros³cCODBEMPR  - Codigo do componente                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NG090PRTRE(cCODBEMPR)

	Local nREC, xy
	While !Eof() .And. (cTRBSTC)->TC_CODBEM == cCODBEMPR

		If (cTRBSTC)->TC_COMPNOV == "S"
			dbSelectArea(cTRBSTC)
			dbSkip()
			Loop
		EndIf

		nREC  := Recno()
		cCOMP := (cTRBSTC)->TC_COMPONE

		dbSelectArea(cTRBTPY)
		(cTRBTPY)->(DbAppend())
		(cTRBTPY)->CODBEM  := (cTRBSTC)->TC_CODBEM
		(cTRBTPY)->COMPONE := cCOMP
		(cTRBTPY)->TIPOEST := "B"

		//Busca as pecas de reposicao do componente
		aULTPECASR := NGPEUTIL(cCOMP)

		For xy := 1 To Len(aULTPECASR)
			dbSelectArea(cTRBTPY)
			(cTRBTPY)->(DbAppend())
			(cTRBTPY)->CODBEM  := cCOMP
			(cTRBTPY)->COMPONE := cCOMP
			(cTRBTPY)->TIPOEST := "P"
			(cTRBTPY)->CODINSU := aULTPECASR[xy][1]
			(cTRBTPY)->DESCPEC := NGSEEK("SB1",aULTPECASR[xy][1],1,'SubStr(B1_DESC,1,20)')
			(cTRBTPY)->DATAULT := aULTPECASR[xy][2]
			(cTRBTPY)->HORAULT := aULTPECASR[xy][3]
		Next xy

		dbSelectArea(cTRBSTC)
		If dbSeek(cCOMP)
			NG090PRTRE(cCOMP)
		Endif

		dbSelectArea(cTRBSTC)
		dbGoto(nREC)
		dbskip()
	End

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGCARTRE090 ³ Autor ³ Elisagela Costa     ³ Data ³ 27/07/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Carrega a estrutura com os componentes e pecas de reposicao ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGCARTRE090()
	Local cDESC := Space(40), cDESC2

	oTREE090 := DbTree():NEW(012,012,155,272,ODLG090,,,.T.)

	dbSelectArea("ST9")
	dbSetOrder(1)
	cDESC := If(dbSeek(xFILIAL("ST9")+cFIRST) .And. !Empty(cFIRST),ST9->T9_NOME,cDESC)

	dbSelectArea(cTRBTPY)
	lTRB := dbSeek(cFIRST)

	If lTRB
		cDESC2   := cFIRST+Replicate(" ",25-Len(RTrim(cFIRST)))
		cPRODESC := cDESC2+' - '+cDESC
		DBADDTREE oTREE090 PROMPT cPRODESC OPENED Resource "FOLDER5", "FOLDER6" CARGO cFIRST

		dbSelectArea(cTRBTPY)
		If dbSeek(cFIRST+cFIRST)
			While !Eof() .And. (cTRBTPY)->CODBEM == cFIRST .And. (cTRBTPY)->COMPONE == cFIRST

				cDESC2   := (cTRBTPY)->CODINSU+Replicate(" ",25-Len(RTrim((cTRBTPY)->CODINSU)))
				cPRODESC := cDESC2+'   - '+(cTRBTPY)->DESCPEC+"  "+DtoC((cTRBTPY)->DATAULT)+"  "+(cTRBTPY)->HORAULT
				DbAddItem oTREE090 Prompt cPRODESC Resource "FOLDER7" Cargo "-"+(cTRBTPY)->CODINSU

				dbSelectArea(cTRBTPY)
				dbSkip()
			End
		EndIf

		dbSelectArea(cTRBTPY)
		dbSeek(cFIRST)
		While !Eof() .And. (cTRBTPY)->CODBEM == cFIRST

			If (cTRBTPY)->COMPONE == cFIRST .Or. (cTRBTPY)->TIPOEST == "P"
				dbSelectArea(cTRBTPY)
				dbSkip()
				Loop
			EndIf

			nREC  := Recno()
			cCOMP := (cTRBTPY)->COMPONE
			cITEM := If(ST9->(dbSeek(xFILIAL("ST9")+cCOMP)),ST9->T9_NOME," ")
			dbSelectArea(cTRBTPY)
			If dbSeek(cCOMP)
				NGMAKPECR(cCOMP)
			Else
				cDESC2   := cCOMP+Replicate(" ",25-Len(RTrim(cCOMP)))
				cPRODESC := cDESC2+' - '+cITEM
				DBADDITEM oTREE090 PROMPT cPRODESC Resource "FOLDER5" CARGO cCOMP
			EndIf
			dbSelectArea(cTRBTPY)
			dbGoto(nREC)
			dbSkip()
		End
		DBENDTREE oTREE090
	Endif

	oTREE090:REFRESH()
	oTREE090:TREESEEK(cFIRST)
	oTREE090:REFRESH()

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGMAKPECR   ³ Autor ³ Elisagela Costa     ³ Data ³ 27/07/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Carrega os demais filhos da estrutura com pecas de reposicao³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGMAKPECR(cPAI)
	Local nREC,cDESC2

	cDESCPAI := If(ST9->(dbSeek(xFILIAL('ST9')+cPAI)),ST9->T9_NOME," ")
	cDESC2   := cPAI+Replicate(" ",25-Len(RTrim(cPAI)))
	cPRODESC := cDESC2+' - '+cDESCPAI
	DBADDTREE oTREE090 PROMPT cPRODESC OPENED Resource "FOLDER5", "FOLDER6" CARGO cPAI

	dbSelectArea(cTRBTPY)
	nREC := Recno()

	dbSelectArea(cTRBTPY)
	dbSeek(cPAI+cPAI)
	While !Eof() .And. (cTRBTPY)->CODBEM == cPAI .And. (cTRBTPY)->COMPONE == cPAI

		cDESC2   := (cTRBTPY)->CODINSU+Replicate(" ",25-Len(RTrim((cTRBTPY)->CODINSU)))
		cPRODESC := cDESC2+'   - '+(cTRBTPY)->DESCPEC+"  "+DtoC((cTRBTPY)->DATAULT)+"  "+(cTRBTPY)->HORAULT
		DbAddItem oTREE090 Prompt cPRODESC Resource "FOLDER7" Cargo "-"+(cTRBTPY)->CODINSU

		dbSelectArea(cTRBTPY)
		dbSkip()
	End
	dbSelectArea(cTRBTPY)
	dbGoto(nREC)

	dbSelectArea(cTRBTPY)
	While (cTRBTPY)->CODBEM == cPAI .And. !(cTRBTPY)->(Eof())

		If (cTRBTPY)->TIPOEST == "P" .Or. (cTRBTPY)->COMPONE == cPAI
			dbSelectArea(cTRBTPY)
			dbSkip()
			Loop
		EndIf

		nREC  := Recno()
		cCOMP := (cTRBTPY)->COMPONE
		cITEM := If(ST9->(dbSeek(xFILIAL('ST9')+cCOMP)),ST9->T9_NOME," ")

		dbSelectArea(cTRBTPY)
		If dbSeek(cCOMP)
			NGMAKPECR(cCOMP)
		Else
			dbSelectArea(cTRBTPY)
			cDESC2   := cCOMP+Replicate(" ",25-Len(RTrim(cCOMP)))
			cPRODESC := cDESC2+' - '+cITEM
			DBADDITEM oTREE090 PROMPT cPRODESC Resource "FOLDER5" CARGO cCOMP
		Endif
		dbSelectArea(cTRBTPY)
		dbGoto(nREC)
		dbSkip()
	End
	DBENDTREE oTREE090

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNT90VCON ³ Autor ³Elisangela Costa       ³ Data ³28/08/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Faz a validacao de contador para componentes com contador   ³±±
±±³          ³proprio                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cPAI - Codigo do bem pai da estrutura.         -obrigatorio ³±±
±±³          ³cCOMPON - Codigo do componente da estrutura.   -obrigatorio |±±
±±³          ³dDATAIN - Data de entrada/Saida na estutura.   -obrigatorio ³±±
±±³          ³nCONTAD - Contador entrada/saida na estrutura. -obrigatorio ³±±
±±³          ³cHORALE - Hora de entrada/saida na estrutura.  -obrigatorio ³±±
±±³          ³cTIPOCONT - Tipo de contador 1-Contador 1  e 2-Contador 2   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT90VCON(cPAI,cCOMPON,dDATAIN,nCONTAD,cHORALE,cTIPOCONT)

	If !CHKPOSLIM(cCOMPON,nCONTAD,cTIPOCONT)
		Return .F.
	EndIf

	If !NGCHKHISTO(cCOMPON,dDATAIN,nCONTAD,cHORALE,cTIPOCONT,,.T.)
		Return .F.
	EndIf

	If !NGVALIVARD(cCOMPON,nCONTAD,dDATAIN,cHORALE,cTIPOCONT,.T.)
		Return .F.
	EndIf

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNT90OSCOR  ³ Autor ³ Elisagela Costa     ³ Data ³ 29/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Chama a rotina para inclusao de os corretiva                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNT90OSCOR()

	Local aHEADEROLD := aCLONE(aHEADER)
	Local aSMENOLD   := aCLONE(aSMENU)
	Private TIPOACOM, TIPOACOM2

	NG420INC('STJ',1,3,(cTRBSTC)->TC_COMPONE)

	aHEADER := aCLONE(aHEADEROLD)
	aSMENU  := aCLONE(aSMENOLD)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTA090FR ³ Autor ³In cio Luiz Kolling    ³ Data ³14/02/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se usa frota                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNTA090FR()

    Local lRetS := IIf(FindFunction('MNTFrotas'), MNTFrotas(), SuperGetMv("MV_NGMNTFR",.F.," ") == 'S')
    Local vRetS := {}

	If lRetS .And. !lRel12133

		If lRetS
			lRetS := SuperGetMv("MV_NGPNEUS",.F.," ") == 'S'
		Endif

		If lRetS
			vRetS := NGCADICBASE('T9_TIPMOD','A','ST9')
			lRetS := If(!vRetS[1],.F.,.T.)
		Endif

		If lRetS
			vRetS := NGCADICBASE('TC_TIPMOD','A','STC')
			lRetS := If(!vRetS[1],.F.,.T.)
		Endif

		If lRetS
			lRetS := If(NGRETORDEM("STC","TC_FILIAL+TC_CODBEM+TC_TIPMOD+TC_COMPONE+TC_TIPOEST+TC_LOCALIZ+TC_SEQRELA",.T.) = 0,.F.,.T.)
		Endif

		If lRetS
			lRetS := If(NGRETORDEM("ST9","T9_CODBEM+T9_SITBEM",.T.) = 0,.F.,.T.)
		Endif

	Endif

Return lRetS

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTA090STA³ Autor ³In cio Luiz Kolling    ³ Data ³29/09/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica o status do bem                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNTA090STA(cVsTa)
	Local aArea := GetArea(), lRet := .T.

	If Empty(cVsTa)
		Return .T.
	EndIf

	If !ExistCpo("TQY",cVsTa)
		Return .F.
	EndIf
	If !Empty(NGSEEK("TQY",cVsTa,1,"TQY_CATBEM"))
		If NGSEEK("TQY",cVsTa,1,"TQY_CATBEM") <> M->T9_CATBEM
			MsgInfo(STR0096,STR0063)
			lRet := .F.
		Endif
	Endif
	RestArea(aArea)
RetuRn lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNT090PNEU³ Autor ³Vitor Emanuel Batista  ³ Data ³16/02/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se existem algum pneu na estrutura                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MNT090PNEU(cPAI)

	If lGFrota
		dbSelectArea("STC")
		dbSeek(xFilial('STC')+cPAI)
		While !Eof() .And.  STC->TC_FILIAL == xFilial('STC') .And.;
		STC->TC_CODBEM == cPAI

			dbSelectArea("TQS")
			dbSetOrder(1)
			If dbSeek(xFilial("TQS")+STC->TC_COMPONE)
				MsgStop(STR0099,STR0063) // "Existem Bem da Categoria Pneus aplicados na Estrutura, para excluir esta estrutura deverá retirar o Bem ( Pneu ) atraves da Rotina OS Corretiva. "
				Return .T.
			EndIf

			dbSelectArea("STC")
			dbSkip()
		EndDo
	EndIf

Return .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NG090DOCUMºAutor  ³Jackson Machado     º Data ³  23/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Posiciona e chama o MsDocument                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 	                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NG090DOCUM(cAlias,nRec,nOpc)
	dbSelectArea("STC")
	dbSetOrder(1)
	dbSeek((cAliasSTC)->(TC_FILIAL+TC_CODBEM))

	MsDocument('STC',STC->(RecNo()),nOpc)

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} Mnt090AdFi
Adiciona filhos no array para controle da árvore ordenada

@param String cPai: indica pai do componente na árvore
@param String cFilho: indica filho(componente)
@param Integer nSequencial: indica sequencia do componente
@author Elynton Fellipe Bazzo
@since 13/08/2014
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function Mnt090AdFi( cPai,cFilho,nSequencial )

	Local aStructSel := {}
	Local nI         := 0
	Local nNext      := 1

	Default nSequencial := 0

	If aScan( aOrdStruct,{ |x| ( AllTrim( x[_POS_PAI_] ) + AllTrim( x[_POS_FIL_] ) ) ==;
	( AllTrim( cPai ) + AllTrim( cFilho ) ) } ) == 0

		If aScan( aOrdStruct,{ |x| AllTrim( x[_POS_PAI_] ) == AllTrim( cPai ) } ) != 0

			For nI := 1 To Len( aOrdStruct )
				If AllTrim( aOrdStruct[nI][_POS_PAI_] ) == AllTrim( cPai )
					aAdd( aStructSel,aOrdStruct[nI] )
				EndIf
			Next nI

			aStructSel := aSort( aStructSel,,,{ |x,y| x[_POS_SEQ_] < y[_POS_SEQ_] } )

			nNext := ( aStructSel[Len( aStructSel )][_POS_SEQ_] + 1 )

			If nSequencial == 0
				aAdd( aOrdStruct,{ cPai,cFilho,nNext } )
			Else
				aAdd( aOrdStruct,{ cPai,cFilho,nSequencial } )
			EndIf

		Else
			If nSequencial == 0
				aAdd( aOrdStruct,{ cPai,cFilho,nNext } )
			Else
				aAdd( aOrdStruct,{ cPai,cFilho,nSequencial } )
			EndIf
		EndIf

	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} Mnt090RtSq
Retorna sequencial do componente na estrutura

@param String cPai: indica pai do componente na árvore
@param String cFilho: indica filho(componente)
@author Elynton Fellipe Bazzo
@since 13/08/2014
@version MP11
@return Integer Sequencia do componente
/*/
//---------------------------------------------------------------------
Function Mnt090RtSq( cPai,cFilho )

	Local nPos := aScan( aOrdStruct,{ |x| AllTrim( x[_POS_PAI_] ) + AllTrim( x[_POS_FIL_] ) == AllTrim( cPai ) + AllTrim( cFilho ) } )

Return aOrdStruct[nPos][_POS_SEQ_]

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT090FIL
Cria Opcao de filtro para tabelas temporarias
- cAlias - Alias da tabela temporaria
- aCampos - Array contendo as informacoes dos campos da tabela

@return Nil

@sample
MNT090FIL(cAlias,aCampos)

@author Guilherme Benkendorf
@since 16/01/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function MNT090FIL(cAlias,aCampos)

	Local aAux       := {}
	Local cFiltroBrw := ""
	Local nPosAlias	 := 0

	Default cAlias 	:= Alias()

	aAux := fNGAltAr(aCampos)//Altera array da tabela temporaria para funcao da BuildExpr

	nPosAlias	:= aScan( aNGFilTemp, {|x| x[1] == cAlias })
	If nPosAlias > 0
		cFiltroBrw := aNGFilTemp[nPosAlias][2]
	EndIf

	cFiltroBrw	:= BuildExpr(,,cFiltroBrw,,{|| &('cAlias->( DBGoTop() )')  } ,,,,,,aAux)

	If nPosAlias == 0
		aAdd(aNGFilTemp,{cAlias,cFiltroBrw})
	Else
		aNGFilTemp[nPosAlias][2] := cFiltroBrw
	EndIf

	//Filtra com a condicao escolhida
	dbSelectArea(cAlias)

	Set Filter to
	Set Filter to &(cFiltroBrw)
	dbGoTop()
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fNGAltAr
Cria novo array alterando array dos campos da tabela
temporaria, para poder utilizar na BuildExpr

- aCampos - Array contendo as informacoes dos campos da tabela

@return Nil

@sample
fNGAltAr(aCampos)

@author Guilherme Benkendorf
@since 16/01/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fNGAltAr(aCampos)
	Local nX
	Local aAux := {}
	/*Formato do array:
	// X3_CAMPO,X3Titulo(),If(!x3Uso(X3_USADO),.F.,.T.),X3_ORDEM,X3_TAMANHO,Trim(X3_PICTURE),X3_TIPO,X3_DECIMAL*/
	For nX := 1 to Len(aCampos)
		aAdd(aAux,{aCampos[nX][2],aCampos[nX][1],.T.,nX,aCampos[nX][4],aCampos[nX][6],aCampos[nX][3],0})
	Next nX

Return aAux

//---------------------------------------------------------------------
/*/{Protheus.doc} f090ValMr
Valida deleção da estrutura quando bem possui material rodante.

@param cBem - Codigo do bem
@return Lógico
@sample f090ValMr( STC->TC_CODBEM )
@author Bruno Lobo de Souza
@since 22/09/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function f090ValMr( cBem )

	Local lRet := .T.
	Local cMsg := ""

	If NGCHKDIC( 1, "TV5" )
		dbSelectArea( "TV5" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "TV5" ) + cBem )
			cMsg += STR0110 + CRLF + STR0111
			dbSelectArea( "TV9" )
			dbSetOrder( 1 )
			If dbSeek ( xFilial( "TV9" ) + cBem )
				cMsg += CRLF + STR0112
			EndIf
			dbSelectArea( "TVH" )
			dbSetOrder( 1 )
			If dbSeek ( xFilial( "TVH" ) + NGSEEK( "ST9", cBem, 1, "T9_CODFAMI" ) )
				cMsg += CRLF + STR0113
			EndIf
			cMsg += CRLF + STR0114
		EndIf
		If !Empty( cMsg )
			lRet := MsgYesNo( cMsg, STR0037 )
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} f090DelMr
Deleta o Material Rodante e seus relacionamentos

@param cBem - Codigo do bem
@return Lógico
@sample f090DelMr( STC->TC_CODBEM )
@author Bruno Lobo de Souza
@since 22/09/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function f090DelMr( cBem )

	//Deleta TV5 - Especific. Material Rodante
	dbSelectArea( "TV5" )
	dbSetOrder( 1 )
	If dbSeek( xFilial( "TV5" ) + cBem )
		RecLock( "TV5", .F. )
		dbDelete()
		MsUnlock( "TV5" )
	EndIf

	//Deleta TV9 - Medições Material Rodante
	dbSelectArea( "TV9" )
	dbSetOrder( 1 )
	If dbSeek ( xFilial( "TV9" ) + cBem )
		RecLock( "TV9", .F. )
		dbDelete()
		MsUnlock( "TV9" )
	EndIf

	//Deleta TVH - Material Rodante - Bem Padrão
	dbSelectArea( "TVH" )
	dbSetOrder( 1 )
	If dbSeek ( xFilial( "TVH" ) + NGSEEK( "ST9", cBem, 1, "T9_CODFAMI" ) )
		RecLock( "TVH", .F. )
		dbDelete()
		MsUnlock( "TVH" )
	EndIf
Return
//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA090CCB
Carrega o valor do contador do bem se o campo estiver bloqueado pelo
parâmetro NGLANEX

@param cCobBem: Código do bem
@param dData: Data
@param cHora: Hora
@author Wexlei Silveira
@since 13/11/2017
@return True
/*/
//---------------------------------------------------------------------
Static Function MNTA090CCB(cCobBem, dData, cHora, lComponente)

	Default lComponente := .F.

	If FindFunction("NGBlCont") .And. !NGBlCont( cCobBem )
		If !lComponente
			nPOSCONT := NGTpCont(cCobBem, dData, cHora)
		Else
			nCONTE1 := NGTpCont(cCobBem, dData, cHora)
		EndIf
	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fValCont
Valida contador do bem no botão OK

@author Wexlei Silveira
@since 13/11/2017
@return lRet, Lógico, Determina que a verificação foi concluída.
/*/
//---------------------------------------------------------------------
Static Function fValCont()

Local lRet  := .T.
Local aAreaST9:= ST9->(GetArea()) //Salva área posicionada.

dbSelectArea("ST9")
dbSetOrder(01) //T9_FILIAL+T9_CODBEM
If DbSeek(xFilial("ST9")+cPAI)
	If ST9->T9_TEMCONT <> 'N'
		//Realiza a validação do contador.
		lRet	:= NGCHKHISTO(cPAI,dULTACOM,nPOSCONT,cHORALE1,1,,.T.) .And. ;
				   NGVALIVARD(cPAI,nPOSCONT,dULTACOM,cHORALE1,1,.T.) .And. ;
				   CHKPOSLIM(cPAI,nPOSCONT,1)
	EndIf
EndIf

RestArea(aAreaST9)//Retorna área posicionada.

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fActionOk
Ações do botão ok

@author Maria Elisandra de Paula
@since 23/05/2019
@param, cPai, string, campo código do bem
@param, nOpc, numérico, operação corrente
@param, ODlgStru, objeto, dialog do botão ok
/*/
//---------------------------------------------------------------------
Static Function fActionOk( cPai, nOpc, ODlgStru )

	Local lRetOk := .F.
	Local lClose := .F.

	//-----------------------------------------------------------------
	//Na visualização, somente fechará a tela, retorno deve ser falso
	//-----------------------------------------------------------------
	If !( lClose := nOpc == 2 )

		//------------------------------------------------------------------------------------------
		//Na exclusão, somente fechará a tela e retorno ok se passar pelas validações
		//------------------------------------------------------------------------------------------
		If nOpc == 5 .And. !MNT090PNEU( cPai )
			lRetOk := .T.
			lClose := .T.
		EndIf

		//------------------------------------------------------------------------------------------
		//Na inclusão e alteração, somente fechará a tela e retorno ok se passar pelas validações
		//------------------------------------------------------------------------------------------
		If nOpc == 3 .Or. nOpc == 4
			If oTree:Total() < 2
				MsgStop( STR0102 ) //"Não foi adicionado nenhum componente à estrutura."
			ElseIf NGPADR090( cPai ) .And. fValCont()
				lRetOk := .T.
				lClose := .T.
			EndIf
		EndIf
	EndIf

	If lClose
		ODlgStru:End()
	EndIf

Return lRetOk

//---------------------------------------------------------------------
/*/{Protheus.doc} fNivel
Recupera o nível na estrutura para o componente filho.
@type function

@author Alexandre Santos
@since 07/10/2021

@param, cCodBem, string, Código do pai imediado do componente.
@return numeric, Nível em que o compoenente se encontra.
/*/
//---------------------------------------------------------------------
Static Function fNivel( cCodBem )
  
	Local aArea  := (cTRBSTC)->( GetArea() )
	Local nNivel := 1

	dbSelectArea( cTRBSTC )
	dbSetOrder( 2 ) // TC_COMPONE + TC_CODBEM + TC_SEQRELA
	If dbSeek( cCodBem )

		/*-----------------------------------------+
		| Incrementa o nivel do pai do componente. |
		+-----------------------------------------*/
		nNivel += (cTRBSTC)->NIVEL

	EndIf

	RestArea( aArea )
	
Return nNivel
