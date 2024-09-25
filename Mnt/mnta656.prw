#INCLUDE "MNTA656.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'

Static cDescResp
Static cDescPost
Static cCNPJPost
Static cDescComb
Static lMMoeda

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA656

Programa de digitação de abastecimentos em Lote de posto interno

@author Evaldo Cevinscki Jr.
@since 17/10/2008
@version 1.0
@sample MNTFrota
@return True
/*/
//---------------------------------------------------------------------
Function MNTA656()

	Local aNGBEGINPRM  := {}

	If FindFunction( 'MNTAmIIn' ) .And. !MNTAmIIn( 95 )
		Return .F.
	EndIf

	aNGBEGINPRM  := NGBEGINPRM()

	//Parametros SX6 utilizados
	Private cConEst    := AllTrim(GetMv("MV_ESTHOME"))
	Private lRastr     := Alltrim(GetMv("MV_RASTRO")) == "S" .And. Alltrim(GetMv("MV_NGMNTES")) == "S"
	Private cIntMntEst := AllTrim(GetMv("MV_NGMNTES"))
	Private cGeraPrev  := AllTrim(GETMv("MV_NGGERPR"))
	Private cUsaInt3   := AllTrim(GetMv("MV_NGMNTES"))
	Private lESTNEGA   := AllTrim(GetMv("MV_ESTNEG")) == "S"
	Private cTipMot    := GetNewPar("MV_NGMOTAB","1")
	Private lUtiFrota  := GetNewPar("MV_NGMNTFR","N") == "S"
	Private cContab    := GetMv("MV_MCONTAB")
	Private cTabCC     := If(CtbInUse(), "CTT", "SI3")

	Private aCamposU := {}
	Private oDlg1
	Private nCapTan  := 0
	Private cCodCom  := " "
	Private cFilBem  := "  "
	Private lCORRET  := .T.
	Private aOldCols := {}
	Private aIndTTA  := {}
	Private cRetPar  := " "

	Private lRotAbast  := .T.
	Private lConciliad := .T.
	Private lNaoAlt656 := .T.
	Private lRegVir    := .F.
	Private nDifVir    := 0

	//Modo das tabelas utilizadas
	Private cModoCC  := NGSX2MODO(cTabCC)
	Private cModoDA4 := NGSX2MODO("DA4")
	Private cModoSB1 := NGSX2MODO("SB1")
	Private cModoSB2 := NGSX2MODO("SB2")
	Private cModoSD3 := NGSX2MODO("SD3")
	Private cModoST9 := NGSX2MODO("ST9")
	Private cModoSTC := NGSX2MODO("STC")
	Private cModoSTZ := NGSX2MODO("STZ")
	Private cModoTQS := NGSX2MODO("TQS")
	Private cModoTT8 := NGSX2MODO("TT8")
	Private cModoTQI := NGSX2MODO("TQI")
	Private cModoTQJ := NGSX2MODO("TQJ")
	Private cModoTQN := NGSX2MODO("TQN")
	Private nTamTable  := Len(cArqTab)

	Private aFilEmp := {}

	Private cMotGer    := AllTrim(GetMv("MV_NGMOTGE"))  //CPF do motorista generico
	Private cMotorista := Space(06)

	//Define o cabecalho da tela de atualizacoes
	Private cCadastro := OemtoAnsi(STR0001) //"Abastecimento de Posto Interno em Lote"
	Private aChkDel   := {}
	Private aRotina   := MenuDef()
	Private cProComb  := ""
	Private lChkLote  := .F.
	Private aRastro	  := {}
	Private aQtdRas	  := {}

	Private aBensLocks := {}
	Private cFilBens   := ""
	Private cFilMBrw   := ""
	Private nSizeFil   := If(FindFunction("FWSizeFilial"),FwSizeFilial(),Len(TMY->TMY_FILIAL))

	Private cMV_Lanex := SuperGetMv("MV_NGLANEX",.F.,"-1",Space(nSizeFil)) //Se nao existir, retorna "-1"

	fLoadQDAB()

	If !Empty(cMotGer)
		dbSelectArea("DA4")
		dbSetOrder(3)
		If dbSeek(xFilial("DA4")+cMotGer)
			cMotorista := DA4->DA4_COD
		EndIf
	EndIf

	//Endereca a funcao de BROWSE
	dbSelectArea("TTA")//Nome da tabela usada
	dbSetOrder(1)

	If NGCADICBASE("TTA_ORIGEM", "A", "TTA", .F.)
		cFilMBrw := "TTA_ORIGEM <> 'MNTA681'"
	EndIf

	mBrowse(6,1,22,75,"TTA",,,,,,,,,,,,,,cFilMBrw)

	//Retorna conteudo de variaveis padroes
	NGRETURNPRM(aNGBEGINPRM)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MNTA656INC³ Autor ³ Evaldo Cevinscki Jr.  ³ Data ³ 17/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de inclusao,alteracao e exclusao de abastecimento em³±±
±±³          ³ lote                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias - Alias                                             ³±±
±±³          ³ nRecno - Recno do registro                                 ³±±
±±³          ³ nOpcx  - Opcao selecionada no menu                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA656                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
 Function MNTA656INC(cAlias,nRecno,nOpcx)

	Local cOldEmp   	:= cEmpAnt
	Local cOldFil   	:= cFilAnt
	Local cBlKDesc  	:= "{|| MNTA656WHD()}"
	Local cBlKWhen  	:= "{|| MNTA656WHE(,nOpcx)}"
	Local cBlKTudo  	:= "{|| MNTA656BLO()}"
	Local cBlKWIA   	:= "{|| MNTA656WIA()}"
	Local cBlkLub   	:= "{|| MNT656LAN()}"
	Local cBlkTq    	:= "{|| MNT656TPLUB()}"
	Local cCondHod		:= ""
	Local cComb     	:= ""
	Local cNGMNTES		:= AllTrim(GetMV("MV_NGMNTES"))
	Local cRASTRO		:= AllTrim(GetMV("MV_RASTRO"))
	Local cLOCALIZ		:= AllTrim(GetMV("MV_LOCALIZ"))
	Local cF3Respon 	:= IIF(( AllTrim( NGSEEKDIC( "SX3", "TTA_RESPON", 2, "SX3->X3_F3" )) $ "SRA-ST1"), AllTrim( NGSEEKDIC( "SX3", "TTA_RESPON", 2, "SX3->X3_F3" )), "SRA" )
	Local lMNT656VL		:= ExistBlock("MNT656VL")
	Local lMNT655D3CC 	:= ExistBlock("MNT655D3CC")
	Local lEndTran      := .F.
	Local aCstMoeda 	:= {}
	Local aArea         := {}
	Local aActiveArea   := {}
	Local aAreaTQN      := {}
	Local dDtBlqMov 	:= SuperGetMV( "MV_DBLQMOV",.F.,STOD("") ) //data de bloqueio de movimentações no
	Local oSize     	:= FwDefSize():New(.T.)
	Local nLinIniTl 	:= oSize:aWindSize[1] // Linha  inicial da tela
	Local nColIniTl 	:= oSize:aWindSize[2] // Coluna inicial da tela
	Local nLinFimTl 	:= oSize:aWindSize[3] // Linha  final   da tela
	Local nColFimTl 	:= oSize:aWindSize[4] // Coluna final   da tela
	Local nOpca     	:= 0
	Local nI			:= 0
	Local nOpc      	:= GD_INSERT+GD_DELETE+GD_UPDATE
	Local nX        	:= 0
	Local nRecTTA		:= 0
	Local xAferiHod 	:= {}
	Local nVar 			:= 0
	Local LQuitTrans	:= .F. // Verifica se deve continuar a transação (Begin/End transaction)
	Local cRelacao      := ""
	Local lCompT9TQN    := Len( AllTrim( xFilial( 'ST9' ) ) ) == Len( AllTrim( xFilial( 'TQN' ) ) )
	Local cFilTqn       := ''

	Private aCoBrw1    := {}
	Private aHoBrw1    := {}
	Private cFolha     := ""
	Private cPosto     := IIF(Inclui,Space(Len(TTA->TTA_POSTO)),TTA->TTA_POSTO)
	Private cOldPosto  := IIF(Inclui,Space(Len(TTA->TTA_POSTO)),TTA->TTA_POSTO)
	Private cLoja      := IIF(Inclui,Space(Len(TTA->TTA_LOJA)),TTA->TTA_LOJA)
	Private cOldLoja   := IIF(Inclui,Space(Len(TTA->TTA_LOJA)),TTA->TTA_LOJA)
	Private cTanque    := IIF(Inclui,Space(Len(TTA->TTA_TANQUE)),TTA->TTA_TANQUE)
	Private cBomba     := IIF(Inclui,Space(Len(TTA->TTA_BOMBA)),TTA->TTA_BOMBA)
	Private cFolhaWhen := ""
	Private cFolValid  := ""
	Private cFolVldUsr := ""
	Private cDesRepo, cDesTroca
	Private nPOSDATAB, nPOSHORAB, nPOSQUANT, nPOSFROTA, nPOSHODOM, nPOSMOTOR, nPOSLUBRI, nPOSTRREP, nPOSMARCA, nPOSQUALU, nPOSPLACA, nPOSCUSTO
	Private nPOSLOTE, nPOSSUBLO, nPOSDTVAL, nPOSLOCAL, nPOSNUMSE, nPOSALMOX, nPOSCONT2, nPOSMOEDA, nPOSNABAS, nPosDesLub, nPosNomMot, nPosDesFro
	Private lTrava656  := .F.
	Private nW         := 0
	Private lGravaTQJ  := .F.
	Private lVIRADA    := .F.
	Private lPrev      := .T.
	Private lPosIntAlt := .T.
	Private TIPOACOM   := .T.
	Private TipoAcom2  := .F.
	Private lSegCont   := NGCADICBASE("TQN_POSCO2","A","TQN",.F.)
	Private lDtvSgCnt  := NGCADICBASE("TPE_SITUAC","A","TPE",.F.) //Indica se permite desativar segundo contador
	Private lLub       := .F.
	Private nCombAnt   := 0
	Private nTotalTQN  := 0
	Private nCombAtu   := 0
	Private nCombDif   := 0
	Private nCombDig   := IIF(Inclui,0,TTA->TTA_TOTCOM)
	Private nCombTot   := IIF(Inclui,0,TTA->TTA_TOTCOM)
	Private nDigTTH    := 0
	Private nLubDif    := 0
	Private nLubDig    := IIF(Inclui,0,TTA->TTA_TOTLUB)
	Private nLubInf    := IIF(Inclui,0,TTA->TTA_TOTLUB)
	Private cTroca     := IIF(Inclui,Space(Len(ST4->T4_SERVICO)),TTA->TTA_SERTRO)
	Private cReposicao := IIF(Inclui,Space(Len(ST4->T4_SERVICO)),TTA->TTA_SERREP)
	Private dDataAbast := IIF(Inclui,dDATABASE-1,TTA->TTA_DTABAS)
	Private cHrAb656   := IIF(Inclui,SubStr(TIME(),1,5),TTA->TTA_HRABAS)
	Private nLanca
	Private cResp := IIF(Inclui,Space(Len(SRA->RA_MAT)),TTA->TTA_RESPON), lObrigResp := .F.
	Private noBrw1  := 0
	Private cOSLub := " "
	Private _oDlg				// Dialog Principal
	Private oScrollBox
	Private aSize := MsAdvSize(,.F.,430), aObjects := {},a656Button := {}
	Private aCols656 := {}
	Private lTpLub := .F.
	Private lGeraOSAut := .F.
	Private lAferTTH := .F.
	Private aAferTTH := {}
	Private aHeadTTH := {}
	Private nDigiTTH := 0
	Private aGravaLog := {}
	Private lTemTTX := NGCADICBASE("TTX_MOTTTH","A","TTX",.F.)
	Private nSomaCols := 0
	Private nDifCont := 0,nAcum655 := 0,nAcu6552 := 0
	Private oMenu,oPanel
	Private nICond
	Private lCUSTO := IIF(cUsaInt3=='N',.T.,.F.)
	Private aOSLub := {}
	Private cFil
	Private cFiliST9   := xFilial("ST9")	//Variável utilizada em chamadas de função do MNTA655
	Private cCombust   := ""

	Default cDescResp := ''
	Default cDescPost := ''
	Default cCNPJPost := ''

	dbSelectArea("TTA")
	nRecTTA := Recno()

	// Carrega obrigatoriedade dos campo em tela montados na mão
	fObrigCpos()

	//ponto de entrada para carregar variaveis
	If ExistBlock("MNTA6561")
		ExecBlock("MNTA6561", .F. , .F. )
	EndIf

	lMMoeda   	:= NGCADICBASE("TL_MOEDA","A","STL",.F.)
	cFolha     := IIF(Inclui,IIF("GETSXENUM" $ Alltrim(Posicione("SX3",2, "TTA_FOLHA", "X3_RELACAO")),GETSXENUM('TTA','TTA_FOLHA'),Space(Len(TTA->TTA_FOLHA))),TTA->TTA_FOLHA)
	cFolhaWhen := IIF(Empty(Posicione("SX3",2, "TTA_FOLHA", "X3_WHEN")), cBlKWhen, Posicione("SX3",2, "TTA_FOLHA", "X3_WHEN"))
	cFolValid  := Posicione("SX3",2, "TTA_FOLHA", "X3_VALID")
	cFolVldUsr := Posicione("SX3",2, "TTA_FOLHA", "X3_VLDUSER")

	If Inclui
		
		cTTAComb   := Space( FwTamSX3( 'TQN_CODCOM' )[1] )
		cDescResp  := Space( FwTamSX3( 'RA_NOME' )[1] )
		cDescPost  := Space( FwTamSX3( 'TQF_NREDUZ' )[1] )
		cCNPJPost  := Space( FwTamSX3( 'TQF_CNPJ' )[1] )
		cDescComb  := Space( FwTamSX3( 'TQM_NOMCOM' )[1] )

	Else

		cTTAComb   := MNT656CMB()
		cDescPost  := NgSeek( 'TQF', cPosto + cLoja, 1, 'TQF_NREDUZ' )
		cCNPJPost  := Transform( NgSeek( 'TQF', cPosto + cLoja, 1, 'TQF_CNPJ' ), X3Picture( 'TQF_CNPJ' ) )

		If !Empty( cResp )

			cDescResp  := NgSeek( 'SRA', cResp, 1, 'RA_NOME' )

		EndIf
		
		If !Empty( cTTAComb )

			cDescComb  := NgSeek( 'TQM', cTTAComb, 1, 'TQM_NOMCOM' )

		EndIf

	EndIf

	If NGCADICBASE("TTH_FOLHA","A","TTH",.F.)
		Aadd( a656Button , { "TANQUE" , {|| MNT656AFER(nOpcx) } , STR0127 , STR0128 } ) //"Saídas de Combustíveis"###"Saídas"
		lAferTTH := .T.
		If !Inclui
			dbSelectArea("TTH")
			dbSetOrder(2)
			dbSeek(xFilial("TTH")+cPosto+cLoja+cFolha)
			While !EoF() .And. TTH->(TTH_FILIAL+TTH_POSTO+TTH_LOJA+TTH_FOLHA) == xFilial("TTH")+cPosto+cLoja+cFolha
				If TTH->TTH_MOTIVO $ "4-5"
					If !lTemTTX
						aAdd(aAferTTH, { TTH->TTH_CODCOM, TTH->TTH_DTABAS, TTH->TTH_HRABAS, TTH->TTH_MOTIVO, TTH->TTH_QUANT, TTH->TTH_MATRIC, TTH->TTH_CCUSTO, .F. } )
					Else
						aAdd(aAferTTH, { TTH->TTH_CODCOM, TTH->TTH_DTABAS, TTH->TTH_HRABAS, TTH->TTH_MOTIV2, NGSEEK('TTX',TTH->TTH_MOTIV2,1,'TTX->TTX_DESCRI'), TTH->TTH_QUANT, TTH->TTH_MATRIC, TTH->TTH_CCUSTO, .F. } )
					EndIf
					nDigiTTH += TTH->TTH_QUANT
				EndIf
				dbSkip()
			End
		EndIf
		aHeadTTH := {}
		aHeadTTH := fAddHead(aHeadTTH)
	EndIf
	//Declaração de variaveis private utilizadas na validação de alguns campos de data e hora de abastecimento.
	Private nPDtAbas := aSCAN(aHeadTTH,{|x| Trim(Upper(x[2])) == "TTH_DTABAS"})
	Private nPHrAbas := aSCAN(aHeadTTH,{|x| Trim(Upper(x[2])) == "TTH_HRABAS"})

	//Declaração de Variaveis Private dos Objetos                            SetPrvt("oDlg1","oGrp1","oSay1","oSay2","oLanca","oData","oGrp2","oSay3","oSay4","oSay5","oSay6","oSay13","oSay18","oHora")
	SetPrvt("oSay15","oSay16","oSay17","oSay18","oPosto","oTanque","oBomba","oFolha","oCombAnt","oCombAtu")
	SetPrvt("oCombDig","oCombDif","oGrp3","oSay7","oSay8","oSay9","oSay10","oSay11","oSay12","oTroca","oReposicao")
	SetPrvt("oLubDig","oLubDif","oDesTroca","oDesRepo","oGrp4","oBrw1","oSay19","oResp","oBrwSaid")

	Define MsDialog oDlg1 Title STR0001 From nLinIniTl,nColIniTl TO nLinFimTl,nColFimTl Of oMainWnd Pixel COLOR CLR_BLACK,CLR_WHITE STYLE nOR(WS_VISIBLE,WS_POPUP)  //"Abastecimento de Posto Interno em Lote"

		oPanelTot       := TPanel():Create(oDlg1,0,0,,,.F.,,,CLR_WHITE,0,0)
		oPanelTot:Align := CONTROL_ALIGN_ALLCLIENT

		oDlg1:lMaximized := .T.

		oPanel := TPanel():New(0, 0, Nil, oPanelTot, Nil, .T., .F., Nil, Nil, 0, 0 , .T., .F. )
		oPanel:Align := CONTROL_ALIGN_TOP
		oPanel:nHeight := 310.3

		Aadd(aObjects,{150,10,.T.,.T.}) // Indica dimensoes x e y e indica que redimensiona x e y
		Aadd(aObjects,{200,30,.T.,.T.}) // Indica dimensoes x e y e indica que redimensiona x e y e assume que retorno sera em linha final coluna final (.F.)

		NGPOPUP(aSMenu,@oMenu,oPanel)
		oPanel:bRClicked := { |o,x,y| oMenu:Activate(x,y,oPanel)}

		aSize:=MsAdvSize()
		aInfo:={aSize[1],aSize[2],aSize[3],aSize[4],3,3}
		aPosObj:=MsObjSize(aInfo,aObjects,.T.)


		/*-------------------+
		| Data Abastecimento |
		+-------------------*/
		oSay1  := TSay():New( 005, 006, { || STR0002 }, oPanel, , , .F., .F., .F., .T., CLR_HBLUE, CLR_WHITE, 020, 008 ) // Data
		bValid := { || VALDT( dDataAbast ) .And. MNTA656DAT() }
		
		If Inclui
			
			cRelacao := Posicione("SX3",2,"TTA_DTABAS","X3_RELACAO")
			
			If !Empty(cRelacao)
				yy         := Trim(cRelacao)
				dDataAbast := &yy.
			EndIf
				
			oData := TGet():New( 005, 025, { |u| If( PCount() > 0, dDataAbast := u, dDataAbast ) }, oPanel, 048, 008, '', bValid, CLR_BLACK, CLR_WHITE, , , , .T.,;
				'', , { || nVar := 1, MNTA656WHE( nVar, nOpcx ) }, .F., .F., , .F., .F., '', 'TTA_DTABAS', , , , .T. )

		Else

			oData := TGet():New( 005, 025, { |u| If( PCount() > 0, dDataAbast :=u, dDataAbast ) }, oPanel, 048, 008, '', bValid, CLR_BLACK, CLR_WHITE, , , , .T.,;
				 '', , { || nVar := 1, MNTA656WHE( nVar, nOpcx ) }, .F., .F., , .F., .F., '', 'dDataAbast', , , , .T. )
			oData:bHelp := { || ShowHelpCpo( 'TTA_DTABAS', { STR0186 }, 1, {}, 1 ) } // Data do Lançamento da folha de abastecimento em lote.

		EndIf

		/*-------------------+
		| Hora Abastecimento |
		+-------------------*/
		oSay18 := TSay():New( 005, 080, { || STR0003 }, oPanel, , , .F., .F., .F., .T., CLR_HBLUE, CLR_WHITE, 020, 008 ) // Hora

		bValid := { || NGVALHORA( cHrAb656, .T. ) .And. If( dDataAbast == dDATABASE, NGCPHORAATU(cHrAb656,'<=',,.T.),.T.) .And. MNT656ENC(4) }
		
		oHora       := TGet():New( 005, 100,{|u| If(PCount()>0,cHrAb656:=u,cHrAb656)},oPanel,024,008,'99:99',bValid,CLR_BLACK,CLR_WHITE,,,,.T.,"",,{||nVar := 2, MNTA656WHE(nVar,nOpcx)},.F.,.F.,,.F.,.F.,"","cHrAb656",,,,.T.)
		oHora:bHelp := {|| ShowHelpCpo("TTA_HRABAS", { STR0187 }, 1, {}, 1)} //"Hora do Lançamento da folha de abastecimento em lote."

		/*----------------+
		| Tipo Lançamento |
		+----------------*/
		oSay2       := TSay():New( 005, 135,{||STR0004},oPanel,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,044,008) //"Tipo Lançamento"
		bValid      := {|| MNT656LISE()}
		oLanca      := TComboBox():New( 005, 185, { |u| IIf( PCount() > 0, nLanca := u, nLanca ) }, { STR0005,;   // Abastecimento
		                                STR0006, STR0018 }, 078, 010, oPanel, , , bValid, CLR_BLACK, CLR_WHITE, .T., , '',; // Abastecimento+Produto ### Produto
										, { ||nVar := 3, MNTA656WHE( nVar, nOpcx ) }, , , , , 'nLanca' )
						 oLanca:bHelp := {|| ShowHelpCpo("nLanca", { STR0188 }, 1, {}, 1)} //"Tipo de lançamento, podendo ser Abastecimento, Abastecimento + Produto, Produto."
		oLanca:Disable()

		/*------------+
		| Responsável |
		+------------*/
		oSay19      := TSay():New( 005, 270,{||STR0160},oPanel,,,.F.,.F.,.F.,.T.,If(lObrigResp,CLR_HBLUE,CLR_BLACK),CLR_WHITE,044,008) //"Responsável"
		
		bValid      := { || IIf( lObrigResp .Or. !Empty( cResp ), NaoVazio() .And. ExistCPO( cF3Respon, cResp, 1 ) .And. MNTA656SER( 3 ), MNTA656SER( 3 ) ) }
		
		oResp       := TGet():New( 005, 310,{|u| If(PCount()>0,cResp:=u,cResp)},oPanel,048,008,'@!',bValid,CLR_BLACK,CLR_WHITE,,,,.T.,"",,{||nVar := 4, MNTA656WHE(nVar,nOpcx)},.F.,.F.,{||.F.},.F.,.F.,cF3Respon,"cResp",,,,.T.)
		oResp:bHelp := {|| ShowHelpCpo("TTA_RESPON", { STR0189 }, 1, {}, 1)} // "Matrícula do funcionário do abastecimento/lubrificação. Pressione as teclas [Enter]+[F3] para selecionar um funcionário."
		
		oDescResp   := TGet():New( 005, 360, { |u| IIf( PCount() > 0, cDescResp := u, cDescResp ) }, oPanel, 125, 008, '@!', , CLR_BLACK, CLR_LIGHTGRAY, , , , .T.,;
			'', , &( cBlKDesc ), .F., .F., , .F., .F., '', 'cDescResp', , , , .T. )
		

		oGrp2       := TGroup():New( C(15),aPosObj[1,2]-1,C(75),aPosObj[1,4],STR0005,oPanel,CLR_BLACK,CLR_WHITE,.T.,.F. ) //"Abastecimento"

		/*-----------------------+
		| Folha de Abastecimento |
		+-----------------------*/
		oSay3        := TSay():New( 028, 006,{ || STR0007 }, oGrp2, , , .F., .F., .F., .T., CLR_HBLUE, CLR_WHITE, 016, 008 ) // Folha
		
		bValid       := { || MNT656ValF() }

		oFolha       := TGet():New( 028, 030, { |u| IIf( PCount() > 0, cFolha := u, cFolha ) }, oGrp2, 060, 008, Replicate( '9', Len( TTA->TTA_FOLHA ) ),;
			bValid, CLR_BLACK, CLR_WHITE, , , , .T., '', , &( cFolhaWhen ), .F., .F., , .F., .F., '', 'cFolha', , , , .T. )
		oFolha:bHelp := {|| ShowHelpCpo("TTA_FOLHA", { STR0190 }, 1, {}, 1)} //"Código da folha de abastecimentos."

		/*------+
		| Posto |
		+------*/
		oSay5        := TSay():New( 028, 095, {||STR0008},oGrp2,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,020,008) //"Posto"

		bValid       := { || IIf( NaoVazio(), MNT656LTB( 1 ) .And. MNTA656SER( 4 ), MNTA656SER( 4 ) ) }

		oPosto       := TGet():New( 028, 115,{ |u| IIf( PCount() > 0, cPosto := u, cPosto ) }, oGrp2, 100, 008, '@!', bValid, CLR_BLACK, CLR_WHITE, , , , .T.,;
			'', , &( cBlKTudo ), .F., .F., , .F., .F., 'NGN', 'cPosto', , , , .T. )
		oPosto:bHelp := {|| ShowHelpCpo("TTA_POSTO", { STR0191 }, 1, {}, 1)} //"Código do posto interno dos abstecimentos. Pressione as teclas [Enter]+[F3] para selecionar um Posto."

		/*-----+
		| Loja |
		+-----*/
		oSay21       := TSay():New( 028, 217,{ || STR0009 }, oGrp2, , , .F., .F., .F., .T., CLR_HBLUE, CLR_WHITE, 020, 008 ) //"Loja"
		
		bValid       := { || IIf( NaoVazio(), MNT656LTB( 2 ) .And. MNT655POIN() .And. MNTA656SER( 4 ), MNTA656SER( 4 ) ) }

		oLoja        := TGet():New( 028, 233,{ |u| IIf( PCount() > 0, cLoja := u, cLoja ) }, oGrp2, 023, 008, '@!', bValid, CLR_BLACK, CLR_WHITE, , , , .T.,;
			'', , &( cBlKTudo ), .F., .F., , .F., .F., '', 'cLoja', , , , .T. )
		oLoja:bHelp  := {|| ShowHelpCpo("TTA_LOJA", { STR0192 }, 1, {}, 1)} //"Código identificador de cada uma das unidades (lojas) de um posto."

		/*-------------------+
		| Descrição do Posto |
		+-------------------*/
		oSay22         := TSay():New( 040, 006, { || STR0245 }, oGrp2, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 020, 008 ) // Desc.
		oDescPost      := TGet():New( 040, 030, { |u| IIf( PCount() > 0, cDescPost := u, cDescPost ) }, oGrp2, 125, 008, '@!', , CLR_BLACK, CLR_LIGHTGRAY, , , , .T.,;
			'', , &( cBlKDesc ), .F., .F., , .F., .F., '', 'cDescPost', , , , .T. )

		/*--------------+
		| CNPJ do Posto |
		+--------------*/
		oSay23         := TSay():New( 040, 160, { || STR0246 }, oGrp2, , , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 015, 008 ) // CNPJ
		oPostCNPJ      := TGet():New( 040, 180, { |u| IIf( PCount() > 0, cCNPJPost := u, cCNPJPost ) }, oGrp2, 076, 008, '@!', , CLR_BLACK, CLR_LIGHTGRAY, , , , .T.,;
			'', , &( cBlKDesc ), .F., .F., , .F., .F., '', 'cCNPJPost', , , , .T. )

		/*-------+
		| Tanque |
		+-------*/
		oSay4          := TSay():New( 052, 006,{||STR0010},oGrp2,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,020,008) //"Tanque"
		bValid         := {||If(VAZIO(),.T.,MNT656TABO(1))}
		oTanque        := TGet():New( 052, 030,{|u| If(PCount()>0,cTanque:=u,cTanque)},oGrp2,020,008,'',bValid,CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cBlkTq),.F.,.F.,,.F.,.F.,"NGMTNQ","cTanque",,,,.T.)
		oTanque:bHelp  := {|| ShowHelpCpo("TTA_TANQUE", { STR0193 }, 1, {}, 1)} //"Tanque de combustíveis dos abastecimentos. Pressione as teclas [Enter]+[F3] para selecionar um Tanque."

		/*------------+
		| Combustível |
		+------------*/
		oSay20         := TSay():New( 052, 058,{|| STR0247 },oGrp2,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,030,008) // Comb.
		
		bValid         := { || IIf( NaoVazio(), MNT656COMB() .And. MNTA656SER( 5 ), MNTA656SER( 5 ) )}
		
		oCombst        := TGet():New( 052, 080,{|u| If(PCount()>0,cTTAComb:=u,cTTAComb)},oGrp2,020,008,'@!',bValid,CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cBlkTq),.F.,.F.,,.F.,.F.,"NGMCOM","cTTAComb" ,,,,.T.)
		oCombst:bHelp  := {|| ShowHelpCpo("cTTAComb", {STR0210}, 1, {}, 1)} //"Informe o código do combustível do abastecimento. Pressione as teclas [Enter]+[F3] para selecionar um Combustível."
		
		oDescComb      := TGet():New( 052, 115, { |u| IIf( PCount() > 0, cDescComb := u, cDescComb ) }, oGrp2, 090, 008, '@!', , CLR_BLACK, CLR_LIGHTGRAY, , , , .T.,;
			'', , &( cBlKDesc ), .F., .F., , .F., .F., '', 'cDescComb', , , , .T. )

		/*------+
		| Bomba |
		+------*/
		oSay6          := TSay():New( 052, 210,{||STR0011},oGrp2,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,020,008) //"Bomba"
		
		bValid         := {||If(VAZIO(),.T.,MNT656TABO(2))}
		
		oBomba         := TGet():New( 052, 233, { |u| IIf( PCount() > 0, cBomba := u, cBomba ) }, oGrp2, 025, 008, '', bValid, CLR_BLACK, CLR_WHITE, , , , .T.,;
			'', , &( cBlkTq ), .F., .F., , .F., .F., 'TQJ', 'cBomba', , , , .T. )
		oBomba:bHelp   := {|| ShowHelpCpo("TTA_BOMBA", { STR0194 }, 1, {}, 1)} //"Bomba de combustíveis dos abastecimentos. Pressione as teclas [Enter]+[F3] para selecionar uma Bomba."

		oSay13     := TSay():New( C(023),C(240),{||STR0012},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,300,008) //"____________________ Combustivel ____________________"
		oSay14     := TSay():New( C(033),C(245),{||STR0013},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,020,008) //"Anterior"
		oSay15     := TSay():New( C(033),C(317),{||STR0014},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,016,008) //"Atual"
		oSay16     := TSay():New( C(033),C(390),{||STR0015},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,016,008) //"Total"
		oSay17     := TSay():New( C(051),C(280),{||STR0016},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,020,008) //"Digitado"
		oSay18     := TSay():New( C(051),C(353),{||STR0017},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008) //"Diferença"
		
		oCombAnt       := TGet():New( C(040),C(245),{|u| If(PCount()>0,nCombAnt:=u,nCombAnt)},oGrp2,070,008,'@E 9,999,999.999',,CLR_BLACK,CLR_HGRAY,,,,.T.,"",,&(cBlKDesc),.F.,.F.,,.F.,.F.,"","nCombAnt",,,,.T.)
		oCombAnt:bHelp := {|| ShowHelpCpo("nCombAnt", { STR0195 }, 1, {}, 1)} //"Quantidade de combustível já utilizado em abastecimentos anteriores."

		bValid         := {|| MNT656CTOT() }
		oCombAtu       := TGet():New( C(040),C(317),{|u| If(PCount()>0,nCombAtu:=u,nCombAtu)},oGrp2,070,008,'@E 9,999,999.999',bValid,CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cBlKWIA),.F.,.F.,,.F.,.F.,"","nCombAtu",,,,.T.)
		oCombAtu:bHelp := {|| ShowHelpCpo("TTA_CONBOM", { STR0196 }, 1, {}, 1)} //"Quantidade de combustível abastecido na presente folha somada a quantidade do campo Anterior."

		oCombTot       := TGet():New( C(040),C(390),{|u| If(PCount()>0,nCombTot:=u,nCombTot)},oGrp2,070,008,'@E 9,999,999.999',,CLR_BLACK,CLR_LIGHTGRAY,,,,.T.,"",,&(cBlKDesc),.F.,.F.,,.F.,.F.,"","nCombTot",,,,.T.)
		oCombTot:bHelp := {|| ShowHelpCpo("TTA_TOTCOM", { STR0197 }, 1, {}, 1)} //"Quantidade de combustível total abastecido na presente folha."

		oCombDig       := TGet():New( C(059),C(280),{|u| If(PCount()>0,nCombDig:=u,nCombDig)},oGrp2,070,008,'@E 9,999,999.999',,CLR_BLACK,CLR_LIGHTGRAY,,,,.T.,"",,&(cBlKDesc),.F.,.F.,,.F.,.F.,"","nCombDig",,,,.T.)
		oCombDig:bHelp := {|| ShowHelpCpo("nCombDig", { STR0198 }, 1, {}, 1)} //"Quantidade de combustível abastecido na presente folha conforme soma das Quantidades (TQQ_QUANT) dos registros inclusos."

		oCombDif       := TGet():New( C(059),C(353),{|u| If(PCount()>0,nCombDif:=u,nCombDif)},oGrp2,070,008,'@E 9,999,999.999',,CLR_BLACK,CLR_LIGHTGRAY,,,,.T.,"",,&(cBlKDesc),.F.,.F.,,.F.,.F.,"","nCombDif",,,,.T.)
		oCombDif:bHelp := {|| ShowHelpCpo("nCombDif", { STR0199 }, 1, {}, 1)} //"Quantidade de combustível que falta para completar a presente folha conforme soma das Quantidades (TQQ_QUANT) dos registros inclusos."

		oGrp3      := TGroup():New( C(77),aPosObj[2,2]-1,C(115),aPosObj[2,4],STR0018,oPanel,CLR_BLACK,CLR_WHITE,.T.,.F. ) //"Produto"
		oSay7      := TSay():New( C(092),C(006),{||STR0019},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,040,008) //"Serviço 1-Troca"
		oSay8      := TSay():New( C(105),C(006),{||STR0020},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008) //"Serviço 2-Reposição"
		oSay9      := TSay():New( C(087),C(240),{||STR0021},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,152,008) //"_______________________Produto_______________________"
		oSay10     := TSay():New( C(096),C(249),{||STR0022},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008) //"Informado"
		oSay11     := TSay():New( C(096),C(295),{||STR0016},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,020,008) //"Digitado"
		oSay12     := TSay():New( C(096),C(329),{||STR0017},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008) //"Diferença"

		// Serviço 1 - Troca
		bValid    := { || IIf( !Empty( cTroca ), MNTA656SEC( cTroca ) .And. MNTA656SER( 1 ), MNTA656SER( 1 ) ) }
		oTroca    := TGet():New( c( 091 ), c( 064 ), { |u| IIf( PCount() > 0, cTroca := u, cTroca ) }, oGrp3, 050, 008,;
		                         '', bValid, CLR_BLACK, CLR_WHITE, , , , .T., '', , &( cBlkLub ), .F., .F., , .F., .F.,;
								 'ST3', 'cTroca', , , , .T. )
		oDesTroca := TGet():New( c( 091 ), c( 110 ), { |u| IIf( PCount() > 0, cDesTroca := u, cDesTroca ) }, oGrp3, 125,;
		                         008, '@!', , CLR_BLACK, CLR_LIGHTGRAY, , , , .T., "", , &( cBlKDesc ), .F., .F., , .F.,;
								 .F., '', 'cDesTroca', , , , .T. )
		oTroca:bHelp := {|| ShowHelpCpo("TTA_SERTRO", { STR0200 }, 1, {}, 1)} //"Serviço utilizado para troca de produto (Lubrificante). Pressione as teclas [Enter]+[F3] para selecionar um Serviço."

		// Serviço 2 - Reposição
		bValid     := {|| IIF(!Empty(cReposicao),MNTA656SEC(cReposicao) .AND. MNTA656SER(2),MNTA656SER(2))}
		oReposicao := TGet():New( c( 103 ), c( 064 ), { |u| IIf( PCount() > 0, cReposicao := u, cReposicao ) }, oGrp3,;
		                          050, 008, '', bValid, CLR_BLACK, CLR_WHITE, , , , .T., '', , &( cBlkLub ), .F., .F., ,;
							      .F., .F., 'ST3', 'cReposicao', , , , .T. )
		oDesRepo   := TGet():New( c( 103 ), c( 110 ), { |u| IIf( PCount() > 0, cDesRepo := u, cDesRepo ) }, oGrp3, 125,;
		                          008, '@!', , CLR_BLACK, CLR_LIGHTGRAY, , , , .T., '', , &( cBlKDesc ), .F., .F., , .F.,;
								  .F., '', 'cDesRepo', , , , .T. )
		oReposicao:bHelp := {|| ShowHelpCpo("TTA_SERREP", { STR0201 }, 1, {}, 1)} //"Serviço utilizado para reposição de produto (Lubrificante). Pressione as teclas [Enter]+[F3] para selecionar um Serviço."

		bValid        := {|| MNT656CLUB() }
		oLubInf       := TGet():New( C(105),C(245),{|u| If(PCount()>0,nLubInf:=u,nLubInf)},oGrp3,040,008,'@E 999,999.999',bValid,CLR_BLACK,CLR_WHITE,,,,.T.,"",,&(cBlkLub),.F.,.F.,,.F.,.F.,"","nLubInf",,,,.T.)
		oLubInf:bHelp := {|| ShowHelpCpo("nLubInf", { STR0202 }, 1, {}, 1)} //"Quantidade de produto (Lubrificante) utilizado em toda a folha."

		oLubDig       := TGet():New( C(105),C(287),{|u| If(PCount()>0,nLubDig:=u,nLubDig)},oGrp3,040,008,'@E 999,999.999',,CLR_BLACK,CLR_LIGHTGRAY,,,,.T.,"",,&(cBlKDesc),.F.,.F.,,.F.,.F.,"","nLubDig",,,,.T.)
		oLubDig:bHelp := {|| ShowHelpCpo("TTA_TOTLUB", { STR0203 }, 1, {}, 1)} //"Quantida de produto (Lubrificante) digitado nos registros inclusos através do campo Qtde Lub.(TPE_AJUSCO)."

		oLubDif       := TGet():New( C(105),	C(325),{|u| If(PCount()>0,nLubDif:=u,nLubDif)},oGrp3,040,008,'@E 999,999.999',,CLR_BLACK,CLR_LIGHTGRAY,,,,.T.,"",,&(cBlKDesc),.F.,.F.,,.F.,.F.,"","nLubDif",,,,.T.)
		oLubDif:bHelp := {|| ShowHelpCpo("nLubDif", { STR0204 }, 1, {}, 1)} //"Quantidade de produto (Lubrificante) no qual não foi digitado nos registros inclusos."

		aHeader := {}
		aCols   := {}
		MNT655Head(nOpcx)

		If Inclui
			MNT655Brw()
			lPrev := .T.
		Else
			MNT656VIS()
			If !Altera
				lPrev := .F.
				TIPOACOM := .F.
				TIPOACOM2 := .F.
			EndIf

			aAreaTQN := getArea()

			lPrimeiro	:= .T.
			lReturn	:= .T.

			If Altera //Se for alteração
				//Verifica se há integração entre os módulos Manutenção de Ativos (SIGAMNT) e Estoque (SIGAEST).
				//Indica o momento que o estoque sera debitado, ou seja, na 'Conciliação'.
				//Há abastecimentos conciliados para a folha.
				If cUsaInt3 == "S" .And. cConEst == "C"

					For nX := 1 To Len( aCols )
						If lPrimeiro
							dbSelectArea( "TQN" )
							dbSetOrder( 01 ) //TQN_FILIAL+TQN_FROTA+DTOS(TQN_DTABAS)+TQN_HRABAS
							If dbSeek( xFilial( "TQN" ) + aCols[nX][nPOSFROTA] + DTOS( aCols[nX][nPOSDATAB] ) + aCols[nX][nPOSHORAB] )
								If !Empty( TQN->TQN_DTCON )
									If TQN->TQN_DTABAS <= dDtBlqMov //Se a data do abastecimento for menor/igual que a data de bloqueio de abastecimento (MV_DBLQMOV);
										//"A folha de abastecimento 'x' não pode ser alterada porque a data de abastecimento do veículo 'x' é menor ou igual que a data de bloqueio de movimentações 'y'. Conforme parâmetro (MV_DBLQMOV)."
										MsgAlert( STR0172 + AllTrim( TTA->TTA_FOLHA ) + STR0176 + AllTrim( TQN->TQN_FROTA ) + STR0177 + DTOC( dDtBlqMov ) + "." + STR0175 )
										lReturn	:= .F.
										lPrimeiro	:= .F.
										Exit
									EndIf
								Else
									If TQN->TQN_DTABAS <= dDtBlqMov //Se a data do abastecimento for menor/igual que a data de bloqueio de abastecimento (MV_DBLQMOV);
										lReturn	:= MsgYesNo( STR0172 + AllTrim( TTA->TTA_FOLHA ) + STR0207 + DTOC( dDtBlqMov ) + STR0175 + STR0208 ) //" tem data menor ou igual ao bloqueio de movimentações " ## " Deseja prosseguir? "
										lPrimeiro	:= .F.
										Exit
									EndIf
								EndIf
							EndIf
						EndIf
					Next nX

					If !lReturn
						Return .F.
					EndIf

				EndIf
			EndIf

			RestArea( aAreaTQN )

		EndIf

		aAlterCols := {}
		nObjAltura := fPosObjet() //C(265)==339
		nObjAltura := If(Valtype(nObjAltura)<>"N",339,nObjAltura)
		If nOpcx==2 .Or. nOpcx==5
			nOpcxOld := nOpcx
			nOpcx    := 2
			oBrw1 := MsNewGetDados():New(C(155),aPosObj[2,2],nObjAltura,aPosObj[2,4],nOpcx,'AllwaysTrue()','AllwaysTrue()','',aAlterCols,0,Len(aCols),'AllwaysTrue()','','AllwaysTrue()',oPanelTot,aHeader,aCols)
			oBrw1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
			Activate MsDialog oDlg1 Centered On Init EnchoiceBar(oDlg1,{||nOpca:=1,oDlg1:End()},{||nOpca:=0,oDlg1:End()})
			nOpcx := nOpcxOld
		Else
			aAlterCols := {"TQN_DTABAS","TQN_HRABAS","TQN_FROTA","TQN_HODOM","TQQ_QUANT","TT_CODIGO","TPE_AJUSCO","TQG_ORDENA","TQN_CODMOT","TL_LOCAL","TQN_PLACA"}

			//Inclui campos de usuario no Array de campos alteraveis
			If Len(aCamposU) > 0
				For nX:= 1 to Len(aCamposU)
					aAdd(aAlterCols, aCamposU[nX][1])
				Next nX
			EndIf

			If nOpcx == 3
				If cUsaInt3 == 'N'
					aAdd(aAlterCols,"TTA_CONBOM")
					If lMMoeda
						aAdd(aAlterCols,"TL_MOEDA")
					EndIf
				EndIf
				If lRastr
					aAdd(aAlterCols,"TL_LOTECTL")
					aAdd(aAlterCols,"TL_NUMLOTE")
					aAdd(aAlterCols,"TL_DTVALID")
					aAdd(aAlterCols,"TL_NUMSERI")
					aAdd(aAlterCols,"TL_LOCALIZ")
				EndIf
			EndIf
			If nOpcx == 3 .Or. nOpcx == 4
				If lSegCont
					aAdd(aAlterCols,"TQN_POSCO2")
				EndIf
			EndIf

			nDigTTH := fLoadTTHC()

			oBrw1 := MsNewGetDados():New(C(155),aPosObj[2,2],nObjAltura,aPosObj[2,4],nOpc,"MNT656OK(1) .And. PutFileInEof('STT')","MNT656OK(2)",'',aAlterCols,,2000,'AllwaysTrue()','','MNT656LIDE()',oPanelTot,aHeader,aCols)
			oBrw1:oBrowse:bChange := { || f656Change() }
			oBrw1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
			aOldCols := aClone(oBrw1:aCols)
			aCols656 := aClone(oBrw1:aCols) //Valida data/hora de fechamento dos registros de abastecimento
			Activate MsDialog oDlg1 Centered On Init EnchoiceBar( oDlg1, { || nOpca := fValidBrw( @oDlg1, oBrw1, nOpcx ) },;
			                                                             { || nOpca := 0, oDlg1:End() }, , a656Button )

		EndIf

	Begin Transaction

		//Verifica se cancelou a tela e se está na inclusão para "reutilizar" o código quando utilizando GETSXENUM().
		If nOpcx == 3
			If nOpca == 0
				RollBackSX8()
			Else
				ConfirmSX8()
			EndIf

		/* Atualmente a rotina não encontra-se preparada para o processo de alteração
	   	   quando utilizado apenas o lançamento de produtos, desta forma validações e gravações
	       serão inibidas do processo. */
		ElseIf nOpcX == 4 .And. nLanca == STR0018 // Produto

			lEndTran := .T.

		EndIf

		If !lEndTran
			aCols := aClone(oBrw1:aCols)
			If nOpca == 1 .And. (Inclui .Or. Altera)

				If lGravaTQJ
					dbSelectArea("TQJ")
					dbSetOrder(01)
					If dbSeek(xFilial("TQJ")+cPosto+cLoja+cTanque+cBomba)
						RecLock("TQJ",.F.)
						TQJ->TQJ_MOTIVO := '1'
						TQJ->(MsUnlock())
					EndIf
				EndIf
				dbSelectArea("TTA")
				dbSetOrder(1)
				If !dbSeek(xFilial("TTA")+cPosto+cLoja+cFolha)
					RecLock("TTA",.T.)
					TTA->TTA_FILIAL := xFilial("TTA")
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
					TTA->TTA_TOTLUB := nLubDig

					If NGCADICBASE("TTA_ORIGEM", "A", "TTA", .F.)
						TTA->TTA_ORIGEM := FunName()
					EndIf

				Else
					RecLock("TTA",.F.)
				EndIf
				TTA->TTA_RESPON := cResp
				TTA->TTA_CONBOM := nCombAtu
				TTA->(MsUnlock())
				nRecTTA := Recno()

				If lAferTTH
					If lTemTTX
						nSomaCols := 1
					EndIf
					dbSelectArea("TTH")
					dbSetOrder(2)
					dbSeek(xFilial("TTH")+cPosto+cLoja+cFolha)
					While !EoF() .And. TTH->(TTH_FILIAL+TTH_POSTO+TTH_LOJA+TTH_FOLHA) == xFilial("TTH")+cPosto+cLoja+cFolha
						If aSCAN(aAferTTH,{|x| !x[Len(x)] .And. x[1] == TTH->TTH_CODCOM .And. x[2] == TTH->TTH_DTABAS .And. x[3] == TTH->TTH_HRABAS .And. ;
							x[4] == IIF(lTemTTX,TTH->TTH_MOTIV2,TTH->TTH_MOTIVO) .And. x[5+nSomaCols] == TTH->TTH_QUANT .And.;
							x[6+nSomaCols] == TTH->TTH_MATRIC }) == 0
							RecLock("TTH",.F.)
							dbDelete()
							TTH->(MsUnLock())

							If AliasInDic("TTV")
								If NGIFDBSEEK("TTV",TTH->TTH_POSTO+TTH->TTH_LOJA+TTH->TTH_TANQUE+TTH->TTH_BOMBA+;
									DTOS(TTH->TTH_DTABAS)+TTH->TTH_HRABAS+Space(Len(TTV->TTV_NABAST)),1)
									NGDelTTV()
								EndIf
							EndIf

							dbSelectArea("TTH")
						EndIf
						dbSkip()
					End
					For nI := 1 To Len(aAferTTH)
						If !aAferTTH[nI][Len(aAferTTH[nI])]
							lAlteraTTH := .F.
							cTTH_Comb := aAferTTH[nI,1]
							dTTH_Data := aAferTTH[nI,2]
							cTTH_Hora := aAferTTH[nI,3]
							dbSelectArea("TTH")
							dbSetOrder(1)
							If dbSeek(xFilial("TTH")+cPosto+cLoja+cTanque+cTTH_Comb+cBomba+DtoS(dTTH_Data)+cTTH_Hora)
								RecLock("TTH",.F.)
								lAlteraTTH := .T.
							Else
								RecLock("TTH",.T.)
								TTH->TTH_FILIAL := xFilial("TTH")
								TTH->TTH_POSTO  := cPosto
								TTH->TTH_LOJA   := cLoja
								TTH->TTH_TANQUE := cTanque
								TTH->TTH_CODCOM := cTTH_Comb
								TTH->TTH_BOMBA  := cBomba
								TTH->TTH_DTABAS := dTTH_Data
								TTH->TTH_HRABAS := cTTH_Hora
							EndIf
							TTH->TTH_TIPO   := "1"
							If !lTemTTX
								TTH->TTH_MOTIVO := aAferTTH[nI,4]
							Else
								TTH->TTH_MOTIV2 := aAferTTH[nI,4]
								TTH->TTH_MOTIVO := NGSEEK('TTX',aAferTTH[nI,4],1,'TTX->TTX_MOTTTH')
							EndIf
							TTH->TTH_QUANT  := aAferTTH[nI,5+nSomaCols]
							TTH->TTH_MATRIC := aAferTTH[nI,6+nSomaCols]
							TTH->TTH_FOLHA  := cFolha
							TTH->TTH_CCUSTO := aAferTTH[nI,7+nSomaCols]
							TTH->(MsUnLock())

								If lAlteraTTH
									NGAltTTVQnt(TTH->TTH_POSTO,TTH->TTH_LOJA,TTH->TTH_TANQUE,TTH->TTH_BOMBA,TTH->TTH_DTABAS,TTH->TTH_HRABAS,'3',TTH->TTH_QUANT)
								Else
									NGIncTTV(TTH->TTH_POSTO,TTH->TTH_LOJA,TTH->TTH_TANQUE,TTH->TTH_BOMBA,TTH->TTH_DTABAS,TTH->TTH_HRABAS,'3',,TTH->TTH_QUANT)

									// GERA SD3
									If cUsaInt3  = "S" .And. NGSEEK("TTX",TTH->TTH_MOTIV2,1,'TTX_ATUEST') = "1"
										NGIFDBSEEK("TQI",TTH->TTH_POSTO+TTH->TTH_LOJA+TTH->TTH_TANQUE+TTH->TTH_CODCOM+cCombust,1)
										cDocumSD3 := NextNumero("SD3",2,"D3_DOC",.T.)
										aActiveArea := TTH->(GetArea())
										cNumSeqD := MntMovEst("RE0",TTH->TTH_TANQUE,TQI->TQI_PRODUT,TTH->TTH_QUANT,TTH->TTH_DTABAS,cDocumSD3,,TTH->TTH_CCUSTO)
										RestArea(aActiveArea)
										dbSelectArea("TTH")
										RecLock("TTH",.F.)
										TTH->TTH_NUMSEQ  := cNumSeqD
										TTH->(MsUnLock())
									EndIf
								EndIf

							EndIf

					Next nI
				EndIf

				For nI := 1 to Len(aCols) //Exclui Abastecimentos ja gravados

					If Altera .And. aCols[nI][Len(aCols[nI])] .And. (aScan(aOldCols,{|x| DTOS(x[nPOSDATAB])+x[nPOSHORAB]+;
						x[nPOSFROTA] == DTOS(aCols[nI][nPOSDATAB])+aCols[nI][nPOSHORAB]+aCols[nI][nPOSFROTA]}) > 0)

						dbSelectArea("ST9")
						dbSetOrder(1)
						dbSeek(xFilial("ST9") + aCols[nI][nPOSFROTA])
						If Empty(cFilBem)
							cFilBem := ST9->T9_FILIAL
						EndIf
						cCodBem := ST9->T9_CODBEM

						n := nI
						MNT656EXJG(cCodBem,nI)
					EndIf
				Next

				For nI := 1 to Len(aCols)

					nW       := nI
					lNao_SD3 := .F.
					If lMNT656VL //Verifica se nao deve atualizar estoque e hodometro
						xAferiHod := ExecBlock("MNT656VL",.F.,.F.,{aCols[nI][nPOSFROTA]})
						lNao_SD3 := IIf( ValType(xAferiHod) == "A", xAferiHod[1], xAferiHod)
					EndIf

					//FindFunction remover na release GetRPORelease() >= '12.1.027'
					If FindFunction("MNTCont2")
						TipoAcom2 := MNTCont2(cFiliST9, aCols[nI][nPOSFROTA])
					Else
						dbSelectArea("TPE")
						dbSetOrder(1)
						If dbSeek(xFilial("TPE",cFiliST9) + aCols[nI][nPOSFROTA])
							TipoAcom2 := IIf(lDtvSgCnt, TPE->TPE_SITUAC == "1", .T.)
						Else
							TipoAcom2 := .F.
						EndIf
					EndIf

					If Inclui
						If !aCols[nI][Len(aHeader)+1]

							cFil := MNTA656FIL(aCols[nI][nPOSFROTA],aCols[nI][nPOSDATAB],aCols[nI][nPOSHORAB],aCols[nI][nPOSPLACA])

							//-------------------------------------------------
							// Define a filial usada para o abastecimento
							//-------------------------------------------------
							If lCompT9TQN
								cFilTqn := cFil
							Else
								cFilTqn := xFilial('TQN')
							EndIf

							//verifica se foi reportado Produto
							cOSLub := " "
							If !Empty(aCols[nI][nPOSLUBRI])
								cOSLub := aOSLub[nI]
							EndIf

							//validacoes de contador
							lVirada := .F.
							n := nI
							cUM := " "
							cNumSeqD := " "

							If !Empty(aCols[nI][nPOSQUANT])

								cCCusto := ""

								If Empty(oBrw1:aCols[nI][nPOSPLACA])
									dbSelectArea("ST9")
									dbSetOrder(1)
									If dbSeek(cFiliST9 + oBrw1:aCols[nI][nPOSFROTA])
										cCCusto  := ST9->T9_CCUSTO
									EndIf
								Else
									dbSelectArea("ST9")
									dbSetOrder(14)
									If dbSeek(oBrw1:aCols[nI][nPOSPLACA])
										cCCusto  := ST9->T9_CCUSTO
									EndIf
								EndIf

								//chamada da funcao para debitar do estoque
								If cNGMNTES == 'S' .And. cConEst == "S" .And. !lNao_SD3

									cUM := NGSEEK('TQM',cCodCom,1,'TQM->TQM_UM')
									dbSelectArea("TQI")
									dbSetOrder(1)
									If dbSeek(xFilial("TQI")+cPosto+cLoja+cTanque+cTTAComb)
										cComb := TQI->TQI_PRODUT
									EndIf
									//Verifica se o MV_DOCSEQ está certo antes de entrar em execução automática, para mostrar mensagem de erro e finalizar
									If Empty(ProxNum())
										cEmpAnt := cOldEmp
										cFilAnt := cOldFil
									EndIf

									lChkLote := .F.
									If !Empty(cComb) .And. cRASTRO == 'S' .And. NGSEEK('SB1',cComb,1,"B1_RASTRO") <> "N";
										.Or. cLOCALIZ == 'S' .And. NGSEEK('SB1',cComb,1,"B1_LOCALIZ") == "S"
										lChkLote := .T.
									EndIf

									dbSelectArea("TQN")
									dbSetOrder(1)
									If !dbSeek( cFilTqn + aCols[nI][nPOSFROTA]+DtoS(aCols[nI][nPOSDATAB])+aCols[nI][nPOSHORAB])
										aAreaTQN := TQN->(GetArea())
										cDocumSD3 := NextNumero("SD3",2,"D3_DOC",.T.)
										cNumSeqD  := MntMovEst('RE0',cTANQUE,cComb,aCols[nI][nPOSQUANT],aCols[nI][nPOSDATAB],cDocumSD3,,cCCusto)
									Else
										If TQN->TQN_QUANT <> aCols[nI][nPOSQUANT]
											aAreaTQN := TQN->(GetArea())
											cNumSeqD  := MntMovEst('DE0',cTANQUE,cComb,TQN->TQN_QUANT,TQN->TQN_DTABAS,"",,"",.T.,TQN->TQN_NUMSEQ)
											cDocumSD3 := NextNumero("SD3",2,"D3_DOC",.T.)
											cNumSeqD  := MntMovEst('RE0',cTANQUE,cComb,aCols[nI][nPOSQUANT],aCols[nI][nPOSDATAB],cDocumSD3,,cCCusto)
										EndIf
									EndIf
									RestArea(aAreaTQN)

									If Empty(cNumSeqD) .And. INCLUI
										DisarmTransaction()
										LQuitTrans := .T.
									EndIf

									//Ponto de Entrada para altecoes finais no SD3
									If lMNT655D3CC .And. !LQuitTrans
										ExecBlock("MNT655D3CC", .F. , .F. , {'RE0', ST9->T9_CODBEM, cCCusto, ST9->T9_FILIAL })
									EndIf
								EndIf

								If !LQuitTrans
									cAbast := GETSXENUM('TQN','TQN_NABAST')
									dbSelectArea("TQN")
									dbSetOrder(1)
									If !dbSeek( cFilTqn + aCols[nI][nPOSFROTA] + DtoS(aCols[nI][nPOSDATAB]) + aCols[nI][nPOSHORAB] )
										RecLock("TQN",.T.)
										TQN->TQN_FILIAL 	:= cFilTqn
										TQN->TQN_PLACA  	:= ST9->T9_PLACA
										TQN->TQN_FROTA  	:= aCols[nI][nPOSFROTA]
										TQN->TQN_CNPJ   	:= NGSEEK('TQF',cPosto+cLoja,1,'TQF->TQF_CNPJ')
										TQN->TQN_POSTO  	:= cPosto
										TQN->TQN_LOJA   	:= cLoja
										TQN->TQN_NOTFIS 	:= cFolha
										TQN->TQN_DTABAS 	:= aCols[nI][nPOSDATAB]
										TQN->TQN_HRABAS 	:= aCols[nI][nPOSHORAB]
										TQN->TQN_QUANT  	:= aCols[nI][nPOSQUANT]
										TQN->TQN_CODCOM 	:= cCombust //Código do combustível.

										If lMMoeda .And. FindFunction("NGCALCUSMD")
											aCstMoeda       := MNT656VUMD(aCols[nI][nPOSDATAB],aCols[nI][nPOSHORAB],TQN->TQN_CODCOM,If(lMMoeda,aCols[nI][nPOSMOEDA],""))
											TQN->TQN_VALUNI := aCstMoeda[1]
											TQN->TQN_MOEDA  := aCstMoeda[2]
										Else
											TQN->TQN_VALUNI := MNT656VALU(aCols[nI][nPOSDATAB],aCols[nI][nPOSHORAB],TQN->TQN_CODCOM,If(lMMoeda,aCols[nI][nPOSMOEDA],""))
											If lMMoeda
												TQN->TQN_MOEDA := "1"
											EndIf
										EndIf

										TQN->TQN_VALTOT := aCols[nI][nPOSQUANT] * TQN->TQN_VALUNI
										TQN->TQN_HODOM  := aCols[nI][nPOSHODOM]
										TQN->TQN_CODVIA := " "
										TQN->TQN_ESCALA := " "
										TQN->TQN_TANQUE := cTanque
										TQN->TQN_BOMBA  := cBomba
										TQN->TQN_NABAST := cAbast
										If !Empty(aCols[nI][nPOSMOTOR])
											TQN->TQN_CODMOT := aCols[nI][nPOSMOTOR]
										Else
											TQN->TQN_CODMOT := cMotorista
										EndIf
										TQN->TQN_USUARI := If(Len(TQN->TQN_USUARI) > 15,cUsername,Substr(cUsuario,7,15))
										TQN->TQN_AUTO   := "2"
										TQN->TQN_NUMSEQ := cNumSeqD
										TQN->TQN_DTEMIS := aCols[nI][nPOSDATAB]
										TQN->TQN_DTPGMT := MNT635DTPG(cPosto,cLoja,aCols[nI][nPOSDATAB],aCols[nI][nPOSHORAB])
										TQN->TQN_CCUSTO := cCCusto
										TQN->TQN_CENTRA := ST9->T9_CENTRAB
										TQN->TQN_ORDENA := INVERTE(aCols[nI][nPOSDATAB])
										TQN->TQN_NUMSGC := MN655NUMSGC()
										TQN->TQN_DTDIGI := dDatabase
										TQN->TQN_OSLUBR := cOSLub
										TQN->TQN_FILORI := cOldFil

										If lSegCont
											TQN->TQN_POSCO2 := aCols[nI][nPOSCONT2]
										EndIf

										//Grava campos de usuario
										If Len(aCamposU) > 0
											For nX:= 1 to Len(aCamposU)
												TQN->&(aCamposU[nX][1]) := aCols[nI][aCamposU[nX][2]]
											Next nX
										EndIf

										TQN->(MsUnlock())
										dbSelectArea("TQN")
										ConfirmSX8()
										aAdd(aGravaLog,{SubStr(cUsuario,7,15),DTOC(dDATABASE),Time(),"INCLUSAO",AllTrim(Str(Recno())),TQN->TQN_NOTFIS,TQN->TQN_FILIAL,SM0->M0_CODIGO})

										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³Inclui historico do contador da Bomba ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										NGIncTTV(TQN->TQN_POSTO,TQN->TQN_LOJA,TQN->TQN_TANQUE,TQN->TQN_BOMBA,TQN->TQN_DTABAS,TQN->TQN_HRABAS,"2",,TQN->TQN_QUANT,TQN->TQN_NABAST) //,TTA->TTA_RESPON)
									EndIf
								EndIf
							EndIf
							//GRAVA STP
							If !lNao_SD3 .And. !LQuitTrans
								If !lVirada
									n := nI
									NGTRETCON(aCols[nI][nPOSFROTA],aCols[nI][nPOSDATAB],aCols[nI][nPOSHODOM],aCols[nI][nPOSHORAB],1,,,IIF(!Empty(aCols[nI][nPOSQUANT]),"A","C"),cFil)
									//GERAR O.S AUTOMATICA POR CONTADOR
									If !lGeraOSAut
										If nI == 1
											If (cGeraPrev = "S" .Or. cGeraPrev = "C" .Or. cGeraPrev = "A") .And. !Empty(aCols[nI][nPOSHODOM])
												If cGeraPrev = "C"
													If MsgYesNo(STR0123+chr(13)+chr(13); //"Deseja que seja verificado a existência de o.s automática por contador?"
														+STR0122,STR0037) //"Confirma (Sim/Não)"###"ATENÇÃO"
														NGGEROSAUT(aCols[nI][nPOSFROTA],aCols[nI][nPOSHODOM],cFil)
														lGeraOSAut := .T.
													EndIf
												Else
													NGGEROSAUT(aCols[nI][nPOSFROTA],aCols[nI][nPOSHODOM],cFil)
													lGeraOSAut := .T.
												EndIf
											EndIf
										EndIf
									ElseIf !Empty(aCols[nI][nPOSHODOM])
										NGGEROSAUT(aCols[nI][nPOSFROTA],aCols[nI][nPOSHODOM],cFil)
									EndIf
								Else
									dbSelectArea("STP")
									dbSetOrder(5)
									dbSeek(xFilial("STP",cFil)+aCols[nI][nPOSFROTA]+DTOS(aCols[nI][nPOSDATAB])+aCols[nI][nPOSHORAB])
									If STP->TP_POSCONT == aCols[nI][nPOSHODOM]  .And. (STP->TP_TIPOLAN $ 'CM')
										RecLock("STP",.F.)
										STP->TP_TIPOLAN := IIF(!Empty(aCols[nI][nPOSQUANT]),"A","C")
										STP->(MsUnlock())
									EndIf
								EndIf
								//gravacao contador 2
								If lSegCont
									If TIPOACOM2
										If !MNT655HOD(2)
											cEmpAnt := cOldEmp
											cFilAnt := cOldFil
										EndIf

										n := nI
										If !lVirada
											NGTRETCON(aCols[nI][nPOSFROTA],aCols[nI][nPOSDATAB],aCols[nI][nPOSCONT2],aCols[nI][nPOSHORAB],2,,,IIF(!Empty(aCols[nI][nPOSQUANT]),"A","C"),cFil)
											//GERAR O.S AUTOMATICA POR CONTADOR
											If !lGeraOSAut
												If nI == 1
													If (cGeraPrev = "S" .Or. cGeraPrev = "C" .Or. cGeraPrev = "A") .And. !Empty(aCols[nI][nPOSCONT2])
														If cGeraPrev = "C"
															If MsgYesNo(STR0123+chr(13)+chr(13); //"Deseja que seja verificado a existência de o.s automática por contador?"
																+STR0122,STR0037) //"Confirma (Sim/Não)"###"ATENÇÃO"
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
											dbSeek(xFilial("TPP",cFil)+aCols[nI][nPOSFROTA]+DTOS(aCols[nI][nPOSDATAB])+aCols[nI][nPOSHORAB])
											If TPP->TPP_POSCON == aCols[nI][nPOSCONT2]  .And. (TPP->TPP_TIPOLA $ 'CM')
												RecLock("TPP",.F.)
												TPP->TPP_TIPOLA := "A"
												MsUnLock("TPP")
											EndIf
										EndIf
									EndIf
								EndIf
							EndIf
						EndIf
					ElseIf Altera

						If !LQuitTrans
							dbSelectArea("ST9")
							dbSetOrder(1)
							dbSeek(xFilial("ST9") + aCols[nI][nPOSFROTA])

							If Empty(cFilBem)
								cFilBem := ST9->T9_FILIAL
							EndIf

							If Empty(cFilBem)
								cFilBem := xFilial("TQN")
							EndIf

							//-------------------------------------------------
							// Define a filial usada para o abastecimento
							//-------------------------------------------------
							If lCompT9TQN
								cFilTqn := cFilBem
							Else
								cFilTqn := xFilial('TQN')
							EndIf

							cCodBem := ST9->T9_CODBEM
							If !aCols[nI][Len(aHeader)+1]

								nICond := nI
								If lSegCont
									cCondHod := "Len(aOldCols) < nICond .Or. aOldCols[nICond][nPOSHODOM] != aCols[nICond][nPOSHODOM] .Or. aOldCols[nICond][nPOSCONT2] != aCols[nICond][nPOSCONT2]"
								Else
									cCondHod := "Len(aOldCols) < nICond .Or. aOldCols[nICond][nPOSHODOM] != aCols[nICond][nPOSHODOM]"
								EndIf

								If	&(cCondHod)

									aRetTPN := NgFilTPN(cCodBem,aCols[nI][nPOSDATAB],aCols[nI][nPOSHORAB])
									If !Empty(aRetTPN[1])
										cFilBem  := aRetTPN[1]
									EndIf

									If !lNao_SD3
										nDifCont := 0
										nAcum655 := 0
										nAcu6552 := 0
										aARALTC :=  {'STP','stp->tp_filial','stp->tp_codbem',;
														'stp->tp_dtleitu','stp->tp_hora','stp->tp_poscont',;
														'stp->tp_acumcon','stp->tp_vardia','stp->tp_viracon'}
										aARABEM := {'ST9','st9->t9_poscont','st9->t9_contacu',;
														'st9->t9_dtultac','st9->t9_vardia'}
										dbSelectArea("STP")
										dbsetorder(5)
										If dbSeek(xFilial("STP",cFilBem)+cCodBem+DTOS(aCols[nI][nPOSDATAB])+aCols[nI][nPOSHORAB])
											nDifCont := aCols[nI][nPOSHODOM] - STP->TP_POSCONT
											nAcum655 := (stp->tp_acumcon - STP->TP_POSCONT) + aCols[nI][nPOSHODOM]

											nRECNSTP := Recno()
											lULTIMOP := .T.
											nACUMFIP := 0
											nCONTAFP := 0
											nVARDIFP := 0
											dDTACUFP := Ctod('  /  /  ')
											dbSkip(-1)
											If !EoF() .And. !BoF() .And. &(aARALTC[2]) = xFilial(aARALTC[1],cFilBem) .And.;
												&(aARALTC[3]) == cCodBem
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
											STP->(dbSkip())
											If EoF() .Or. STP->TP_CODBEM <> cCodBem
												dbSkip(-1)
												If cCodBem == STP->TP_CODBEM
													aArea := GetArea() //Restaura o ambiente ativo.

													dbSelectArea( "ST9" )
													dbSetOrder( 01 )
													RecLock( "ST9",.F. )
													ST9->T9_POSCONT += nDifCont
													ST9->T9_CONTACU += nDifCont
													MsUnLock( "ST9" )

													RestArea( aArea ) //Retorno o ambiente salvo.
												EndIf
											EndIf
											MNTA875ADEL(cCodBem,aCols[nI][nPOSDATAB],aCols[nI][nPOSHORAB],1,cFilBem,cFilBem)
										EndIf
										dbSelectArea("TPP")
										dbsetorder(5)
										If dbSeek(xFilial("TPP",cFilBem)+cCodBem+DTOS(aCols[nI][nPOSDATAB])+aCols[nI][nPOSHORAB])
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
											dDTACUFP := Ctod('  /  /  ')
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
											MNTA875ADEL(cCodBem,aCols[nI][nPOSDATAB],aCols[nI][nPOSHORAB],2,cFilBem,cFilBem)
										EndIf

										If !lVIRADA
											n := nI
											NGTRETCON(cCodBem,aCols[nI][nPOSDATAB],aCols[nI][nPOSHODOM],aCols[nI][nPOSHORAB],1,,,IIF(!Empty(aCols[nI][nPOSQUANT]),"A","C"),cFilbem)
										Else
											dbSelectArea("STP")
											dbSetOrder(5)
											dbSeek(xFilial("STP",cFilbem)+cCodBem+DTOS(aCols[nI][nPOSDATAB])+aCols[nI][nPOSHORAB])
											If STP->TP_POSCONT == aCols[nI][nPOSHODOM] .And. (STP->TP_TIPOLAN $ 'CM')
												RecLock("STP",.F.)
												STP->TP_TIPOLAN := IIF(!Empty(aCols[nI][nPOSQUANT]),"A","C")
												STP->(MsUnlock())
											EndIf
										EndIf
										//gravacao contador 2
										If lSegCont
											If TIPOACOM2
												If !MNT655HOD(2)
													cEmpAnt := cOldEmp
													cFilAnt := cOldFil
												EndIf

												n := nI
												If !lVirada
													NGTRETCON(aCols[nI][nPOSFROTA],aCols[nI][nPOSDATAB],aCols[nI][nPOSCONT2],aCols[nI][nPOSHORAB],2,,,IIF(!Empty(aCols[nI][nPOSQUANT]),"A","C"),cFilBem)
												Else
													dbSelectArea("TPP")
													dbSetOrder(5)
													dbSeek(xFilial("TPP",cFilBem)+aCols[nI][nPOSFROTA]+DTOS(aCols[nI][nPOSDATAB])+aCols[nI][nPOSHORAB])
													If TPP->TPP_POSCON == aCols[nI][nPOSCONT2]  .And. (TPP->TPP_TIPOLA $ 'CM')
														RecLock("TPP",.F.)
														TPP->TPP_TIPOLA := "A"
														MsUnLock("TPP")
													EndIf
												EndIf
											EndIf
										EndIf
									EndIf

									dbSelectArea("TQN")
									dbSetOrder(01)
									If dbSeek( cFilTqn +cCodBem+DTOS(aCols[nI][nPOSDATAB])+aCols[nI][nPOSHORAB])
										RecLock("TQN",.F.)
										TQN->TQN_HODOM := aCols[nI][nPOSHODOM]
										If lSegCont
											TQN->TQN_POSCO2 := aCols[nI][nPOSCONT2]
										EndIf
										TQN->(MsUnlock())
										aAdd(aGravaLog,{SubStr(cUsuario,7,15),DTOC(dDATABASE),Time(),"ALTERACAO",AllTrim(Str(Recno())),TQN->TQN_NOTFIS,TQN->TQN_FILIAL,SM0->M0_CODIGO})
									EndIf
								EndIf

								cNumSeqD := ''
								dbSelectArea("TQN")
								dbSetOrder(01)
								If dbSeek( cFilTqn + cCodBem+DTOS(aCols[nI][nPOSDATAB])+aCols[nI][nPOSHORAB]) .And. !Empty(aCols[nI][nPOSQUANT]) .And. Len( aCols ) > nI .And.;
									( aCols[nI][nPOSMOTOR] != aOldCols[nI][nPOSMOTOR] .Or. aCols[nI][nPOSQUANT] != aOldCols[nI][nPOSQUANT] .Or. Len(aCamposU) > 0)

									If cNGMNTES == 'S' .And. aOldCols[nI][nPOSQUANT] <> aCols[nI][nPOSQUANT] .And. !Empty(TQN->TQN_NUMSEQ) .And. !lNao_SD3

										cFilTQF := MNT655FTQF( aCols[nI][nPOSDATAB] , TQN->TQN_NUMSEQ , aOldCols[nI][nPOSQUANT] ) //Data / Numseq / Quantidade

										cCodComb := NGSEEK('TQI',cPosto+cLoja+cTanque+cTTAComb,1,'TQI->TQI_CODCOM',cFilTQF)
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
										//lD3CCAbas := If(ExistBlock("MNT655D3CC"),.T.,.F.) //Verifica se existe ponto de entrada para gravar informacao no campo D3_CC
										aActiveArea := TQN->(GetArea())
										MntMovEst('DE0',cTanque,cComb,aOldCols[nI][nPOSQUANT],aCols[nI][nPOSDATAB],cDocumSD3,cFilTQF,TQN->TQN_CCUSTO,.T.,TQN->TQN_NUMSEQ)
										TQN->(dbGoTo(nRecTQN))

										//Ponto de Entrada para altecoes finais no SD3
										If lMNT655D3CC
											ExecBlock("MNT655D3CC", .F. , .F. , {'DE0', TQN->TQN_FROTA, TQN->TQN_CCUSTO, cFilTQF })
										EndIf

										cDocumSD3 := NextNumero("SD3",2,"D3_DOC",.T.)
										If FindFunction("MNTMOVTM") .And. FindFunction("NGREGRAEST") // Remover na versão 12.1.25
											cNumSeqD := MntMovEst('RE0',cTanque,cComb,aCols[nI][nPOSQUANT],aCols[nI][nPOSDATAB],cDocumSD3,cFilTQF,TQN->TQN_CCUSTO,,cDocumSD3,,,,,,If(Len(aRastro)>0,aRastro[nI],{}))
										Else
											cNumSeqD := NgMovEstoque('RE0',cTanque,cComb,"TQN->TQN_NUMSEQ",cUM,aCols[nI][nPOSQUANT],aCols[nI][nPOSDATAB],/*cFolha*/cDocumSD3,TQN->TQN_CCUSTO,cFilTQF,TQN->TQN_FROTA,,,If(Len(aRastro)>0,aRastro[nI],{}))
										EndIf
										TQN->(dbGoTo(nRecTQN))
										RestArea(aActiveArea)

										//Ponto de Entrada para altecoes finais no SD3
										If lMNT655D3CC
											ExecBlock("MNT655D3CC", .F. , .F. , {'RE0', TQN->TQN_FROTA, TQN->TQN_CCUSTO, cFilTQF })
										EndIf
									EndIf

									RecLock("TQN",.F.)
									If !Empty(aCols[nI][nPOSMOTOR])
										TQN->TQN_CODMOT := aCols[nI][nPOSMOTOR]
									Else
										TQN->TQN_CODMOT := cMotorista
									EndIf
									TQN->TQN_QUANT  := aCols[nI][nPOSQUANT]
									TQN->TQN_VALTOT := aCols[nI][nPOSQUANT] * TQN->TQN_VALUNI
									If !Empty(cNumSeqD)
										TQN->TQN_NUMSEQ := cNumSeqD
									EndIf
									If Empty(TQN->TQN_FILORI)
										TQN->TQN_FILORI := cOldFil
									EndIf
									For nX:= 1 to Len(aCamposU)
										TQN->&(aCamposU[nX][1]) := aCols[nI][aCamposU[nX][2]]
									Next nX
									TQN->(MsUnlock())
									aAdd(aGravaLog,{SubStr(cUsuario,7,15),DTOC(dDATABASE),Time(),"ALTERACAO",AllTrim(Str(Recno())),TQN->TQN_NOTFIS,TQN->TQN_FILIAL,SM0->M0_CODIGO})

									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Altera historico do contador da Bomba ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									NGAltTTVQnt(TQN->TQN_POSTO,TQN->TQN_LOJA,TQN->TQN_TANQUE,TQN->TQN_BOMBA,TQN->TQN_DTABAS,TQN->TQN_HRABAS,'2',TQN->TQN_QUANT)

								Else

									cCCusto := ""

									If Empty(oBrw1:aCols[nI][nPOSPLACA])
										dbSelectArea("ST9")
										dbSetOrder(1)
										If dbSeek(cFiliST9 + oBrw1:aCols[nI][nPOSFROTA])
											cCCusto  := ST9->T9_CCUSTO
										EndIf
									Else
										dbSelectArea("ST9")
										dbSetOrder(14)
										If dbSeek(oBrw1:aCols[nI][nPOSPLACA])
											cCCusto  := ST9->T9_CCUSTO
										EndIf
									EndIf

									//chamada da funcao para debitar do estoque
									If cNGMNTES == 'S' .And. cConEst == "S" .And. !lNao_SD3

										cUM := NGSEEK('TQM',cCodCom,1,'TQM->TQM_UM')
										dbSelectArea("TQI")
										dbSetOrder(1)
										If dbSeek(xFilial("TQI")+cPosto+cLoja+cTanque+cCombust)
											cComb := TQI->TQI_PRODUT
										EndIf
										//Verifica se o MV_DOCSEQ está certo antes de entrar em execução automática, para mostrar mensagem de erro e finalizar
										If Empty(ProxNum())
											cEmpAnt := cOldEmp
											cFilAnt := cOldFil
										EndIf

										lChkLote := .F.
										If !Empty(cComb) .And. cRASTRO == "S" .And. NGSEEK('SB1',cComb,1,"B1_RASTRO") <> "N";
											.Or. cLOCALIZ == "S" .And. NGSEEK('SB1',cComb,1,"B1_LOCALIZ") == "S"
											lChkLote := .T.
										EndIf

										dbSelectArea("TQN")
										dbSetOrder(1)
										If !dbSeek(xFilial("TQN",cFil)+aCols[nI][nPOSFROTA]+DtoS(aCols[nI][nPOSDATAB])+aCols[nI][nPOSHORAB])
											aActiveArea := TQN->(GetArea())
											cDocumSD3 := NextNumero("SD3",2,"D3_DOC",.T.)
											cNumSeqD  := MntMovEst('RE0',cTANQUE,cComb,aCols[nI][nPOSQUANT],aCols[nI][nPOSDATAB],cDocumSD3,,cCCusto)
										Else
											aActiveArea := TQN->(GetArea())
											If TQN->TQN_QUANT <> aCols[nI][nPOSQUANT]
												cNumSeqD  := MntMovEst('DE0',cTANQUE,cComb,TQN->TQN_QUANT,TQN->TQN_DTABAS,"",,"",.T.,TQN->TQN_NUMSEQ)
												cDocumSD3 := NextNumero("SD3",2,"D3_DOC",.T.)
												cNumSeqD  := MntMovEst('RE0',cTANQUE,cComb,aCols[nI][nPOSQUANT],aCols[nI][nPOSDATAB],cDocumSD3,,cCCusto)
											EndIf
										EndIf

										RestArea(aActiveArea)

										//Ponto de Entrada para altecoes finais no SD3
										If lMNT655D3CC
											ExecBlock("MNT655D3CC", .F. , .F. , {'RE0', ST9->T9_CODBEM, cCCusto, ST9->T9_FILIAL })
										EndIf
									EndIf

									dbSelectArea("TQN")
									dbSetOrder(01)
									If !dbSeek( cFilTqn +aCols[nI][nPOSFROTA]+DtoS(aCols[nI][nPOSDATAB])+aCols[nI][nPOSHORAB])
										cAbast := GETSXENUM('TQN','TQN_NABAST')
										RecLock("TQN",.T.)
										TQN->TQN_FILIAL 	:= cFilTqn
										TQN->TQN_PLACA  	:= aCols[nI][nPOSPLACA]
										TQN->TQN_FROTA  	:= aCols[nI][nPOSFROTA]
										TQN->TQN_CNPJ   	:= NGSEEK('TQF',cPosto+cLoja,1,'TQF->TQF_CNPJ')
										TQN->TQN_POSTO  	:= cPosto
										TQN->TQN_LOJA   	:= cLoja
										TQN->TQN_NOTFIS 	:= cFolha
										TQN->TQN_DTABAS 	:= aCols[nI][nPOSDATAB]
										TQN->TQN_HRABAS 	:= aCols[nI][nPOSHORAB]
										TQN->TQN_QUANT  	:= aCols[nI][nPOSQUANT]
										TQN->TQN_CODCOM 	:= cCombust //Código do combustível.

										If lMMoeda .And. FindFunction("NGCALCUSMD")
											aCstMoeda := MNT656VUMD(aCols[nI][nPOSDATAB],aCols[nI][nPOSHORAB],TQN->TQN_CODCOM,If(lMMoeda,aCols[nI][nPOSMOEDA],""))
											TQN->TQN_VALUNI := aCstMoeda[1]
											TQN->TQN_MOEDA  := aCstMoeda[2]
										Else
											TQN->TQN_VALUNI := MNT656VALU(aCols[nI][nPOSDATAB],aCols[nI][nPOSHORAB],TQN->TQN_CODCOM,If(lMMoeda,aCols[nI][nPOSMOEDA],""))
											If lMMoeda
												TQN->TQN_MOEDA := "1"
											EndIf
										EndIf

										TQN->TQN_VALTOT := aCols[nI][nPOSQUANT] * TQN->TQN_VALUNI
										TQN->TQN_HODOM  := aCols[nI][nPOSHODOM]
										TQN->TQN_CODVIA := " "
										TQN->TQN_ESCALA := " "
										TQN->TQN_TANQUE := cTanque
										TQN->TQN_BOMBA  := cBomba
										TQN->TQN_NABAST := cAbast
										If !Empty(aCols[nI][nPOSMOTOR])
											TQN->TQN_CODMOT := aCols[nI][nPOSMOTOR]
										Else
											TQN->TQN_CODMOT := cMotorista
										EndIf
										TQN->TQN_USUARI := If(Len(TQN->TQN_USUARI) > 15,cUsername,Substr(cUsuario,7,15))
										TQN->TQN_AUTO   := "2"
										TQN->TQN_NUMSEQ := cNumSeqD
										TQN->TQN_DTEMIS := aCols[nI][nPOSDATAB]
										TQN->TQN_DTPGMT := MNT635DTPG(cPosto,cLoja,aCols[nI][nPOSDATAB],aCols[nI][nPOSHORAB])
										TQN->TQN_CCUSTO := cCCusto
										TQN->TQN_CENTRA := ST9->T9_CENTRAB
										TQN->TQN_ORDENA := INVERTE(aCols[nI][nPOSDATAB])
										TQN->TQN_NUMSGC := MN655NUMSGC()
										TQN->TQN_DTDIGI := dDatabase
										TQN->TQN_OSLUBR := cOSLub
										TQN->TQN_FILORI := cOldFil
										If lSegCont
											TQN->TQN_POSCO2 := aCols[nI][nPOSCONT2]
										EndIf

										If Len(aCamposU) > 0
											For nX:= 1 to Len(aCamposU)
												TQN->&(aCamposU[nX][1]) := aCols[nI][aCamposU[nX][2]]
											Next nX
										EndIf
										TQN->(MsUnlock())
										dbSelectArea("TQN")
										ConfirmSX8()
										aAdd(aGravaLog,{SubStr(cUsuario,7,15),DTOC(dDATABASE),Time(),"INCLUSAO",AllTrim(Str(Recno())),TQN->TQN_NOTFIS,TQN->TQN_FILIAL,SM0->M0_CODIGO})

										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³Inclui historico do contador da Bomba ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										NGIncTTV(TQN->TQN_POSTO,TQN->TQN_LOJA,TQN->TQN_TANQUE,TQN->TQN_BOMBA,TQN->TQN_DTABAS,TQN->TQN_HRABAS,"2",,TQN->TQN_QUANT,TQN->TQN_NABAST) //,TTA->TTA_RESPON)
									EndIf
								EndIf
							Else
								n := nI
								MNT656EXJG(cCodBem,nI) //Exclui Abastecimentos ja gravados
							EndIf
						EndIf
					EndIf
				Next
				aRastro := {}
				aQtdRas := {}

			ElseIf nOpca == 1 .And. nOpcx == 5 .And. !LQuitTrans

				For nI := 1 to Len(aCols)
					dbSelectArea("ST9")
					dbSetOrder(1)
					dbSeek(xFilial("ST9") + aCols[nI][nPOSFROTA])
					cCodBem := ST9->T9_CODBEM
					n := nI
					MNT656EXJG(cCodBem,nI) //Exclui Abastecimentos ja gravados
				Next

				dbSelectArea("TTA")
				dbGoTo(nRecno)
				RecLock("TTA",.F.)
				dbDelete()
				TTA->(MsUnlock())

				If lAferTTH
					dbSelectArea("TTH")
					dbSetOrder(2)
					dbSeek(xFilial("TTH")+cPosto+cLoja+cFolha)
					While !EoF() .And. TTH->(TTH_FILIAL+TTH_POSTO+TTH_LOJA+TTH_FOLHA) == xFilial("TTH")+cPosto+cLoja+cFolha

							If NGIFDBSEEK("TTV",TTH->TTH_POSTO+TTH->TTH_LOJA+TTH->TTH_TANQUE+TTH->TTH_BOMBA+;
								DTOS(TTH->TTH_DTABAS)+TTH->TTH_HRABAS+Space(Len(TTV->TTV_NABAST)),1)
								NGDelTTV()
							EndIf

						If cUsaInt3  = "S" .And. NGSEEK("TTX",TTH->TTH_MOTIV2,1,'TTX_ATUEST') = "1"
							NGIFDBSEEK("TQI",TTH->TTH_POSTO+TTH->TTH_LOJA+TTH->TTH_TANQUE+TTH->TTH_CODCOM,1)
							aActiveArea := TTH->(GetArea())
							MntMovEst("DE0",TTH->TTH_TANQUE,TQI->TQI_PRODUT,TTH->TTH_QUANT,TTH->TTH_DTABAS,"",Nil,Nil,.T.,TTH->TTH_NUMSEQ)
							RestArea(aActiveArea)
						EndIf

						dbSelectArea("TTH")
						RecLock("TTH",.F.)
						dbDelete()
						TTH->(MsUnLock())
						dbSkip()
					End
				EndIf
			EndIf

		If !LQuitTrans
				If Len(aGravaLog) != 0
					If ExistBlock("LOGABAST")
						ExecBlock("LOGABAST",.F.,.F.,{aGravaLog})
					EndIf
				EndIf

				cEmpAnt := cOldEmp
				cFilAnt := cOldFil

				For nI := 1 To Len( aBensLocks )
					UnLockByName( aBensLocks[nI] )
				Next nI
			EndIf

			dbSelectArea("TTA")
			dbSetOrder(1)
			dbGoTo(nRecTTA)

		EndIf

	End Transaction

 Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |MNT655Head³ Autor ³ Marcos Wagner Junior  ³ Data ³ 15/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta aHeader da MsNewGetDados para o Alias: TQN           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA656                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNT655Head(nOpcx)


	Local nX        := 0
	Local nInd      := 0
	Local nTamTot   := 0
	Local aHeadOld  := {}
	Local aCampos   := {}

	If lSegCont
		
		aCampos := { 'TQN_DTABAS', 'TQN_HRABAS', 'TQN_FROTA', 'TQN_PLACA', 'TQN_DESFRO', 'TQN_HODOM', 'TQN_POSCO2',;
			'TQQ_QUANT', 'TT_CODIGO', 'TT_NOMCODI', 'TPE_AJUSCO', 'TQG_ORDENA', 'TQN_CODMOT', 'TQN_NOMMOT', 'TL_LOCAL' }

	Else

		aCampos := { 'TQN_DTABAS', 'TQN_HRABAS', 'TQN_FROTA', 'TQN_PLACA', 'TQN_DESFRO', 'TQN_HODOM', 'TQQ_QUANT',;
			'TT_CODIGO', 'TT_NOMCODI', 'TPE_AJUSCO', 'TQG_ORDENA', 'TQN_CODMOT', 'TQN_NOMMOT', 'TL_LOCAL' }

	EndIf

	If lRastr
		aAdd(aCampos,"TL_LOTECTL")
		aAdd(aCampos,"TL_NUMLOTE")
		aAdd(aCampos,"TL_DTVALID")
		aAdd(aCampos,"TL_LOCALIZ")
		aAdd(aCampos,"TL_NUMSERI")
	EndIf

	aAdd(aCampos,"TTA_CONBOM")
	aAdd(aCampos,"TL_MOEDA")
	aAdd(aCampos,"TP9_VALANO")
	aAdd( aCampos, 'TQN_NABAST' )

	nTamTot := Len(aCampos)
	For nInd := 1 To nTamTot

		cCampo := aCampos[nInd]
		If !Empty(Posicione("SX3",2,cCampo,"X3_CAMPO"))

			aValores := fValidHead(cCampo)
			noBrw1++
			aAdd(aHeader,{aValores[1],aValores[2] ,aValores[3] ,aValores[4] ,aValores[5],aValores[6],aValores[7],aValores[8],;
						  aValores[9],aValores[10],aValores[11],aValores[12],aValores[13]})

		EndIf

	Next nInd

	//Ponto de Entrada que possibilita mudar ordenação ou adicionar um campo de usuario no aHeader
	aHeadOld := aClone(aHeader)

	If ExistBlock("MNTA656H")
		ExecBlock("MNTA656H", .F. , .F.,{aHeader})
	EndIf

	//Identifica se foi adicionado alguma campo de usuario
	For nX:= 1 to Len(aHeader)
		nPosCampo := aSCAN(aHeadOld,{|x| Trim(Upper(x[2])) == AllTrim(aHeader[nX][2])})
		If nPosCampo == 0
			nPos := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == AllTrim(aHeader[nX][2])})
			aAdd(aCamposU, {aHeader[nX][2], nPos})
			noBrw1++
		EndIf
	Next nX

	// Carrega Tecla de Atalho F6 no campo Produto
	SetKey(VK_F6, {|| MNT656F6() }) // Lubrificantes

	nPOSDATAB  := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TQN_DTABAS"})
	nPOSHORAB  := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TQN_HRABAS"})
	nPOSFROTA  := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TQN_FROTA"})
	nPOSHODOM  := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TQN_HODOM"})
	nPOSQUANT  := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TQQ_QUANT"})
	nPOSPLACA  := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TQN_PLACA"})
	nPosDesFro := GDFieldPos( 'TQN_DESFRO' )
	nPosDesLub := GDFieldPos( 'TT_NOMCODI' )
	nPosNomMot := GDFieldPos( 'TQN_NOMMOT' )
	If lSegCont
		nPOSCONT2 := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TQN_POSCO2"})
	EndIf
	nPOSLUBRI := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TT_CODIGO"})
	nPOSQUALU := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TPE_AJUSCO"})
	nPOSTRREP := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TQG_ORDENA"})
	nPOSMOTOR := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TQN_CODMOT"})
	nPOSALMOX := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TL_LOCAL"})
	nPOSLOTE  := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TL_LOTECTL"})
	nPOSSUBLO := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TL_NUMLOTE"})
	nPOSDTVAL := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TL_DTVALID"})
	nPOSLOCAL := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TL_LOCALIZ"})
	nPOSNUMSE := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TL_NUMSERI"})
	nPOSCUSTO := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TTA_CONBOM"})
	nPOSMARCA := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TP9_VALANO"})
	nPOSMOEDA := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TL_MOEDA"  })

	nPOSNABAS := aScan( aHeader, { |x| Trim( Upper( x[2] ) ) == 'TQN_NABAST' } )

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |MNT655Brw ³ Autor ³ Marcos Wagner Junior  ³ Data ³ 15/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta aCols da MsNewGetDados para o Alias: TQN             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA656                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNT655Brw()
	Local nI

	aAdd( aCols, Array( noBrw1 + 1 ) )
	
	For nI := 1 To noBrw1
		
		If nI == 1
			
			aCols[1,nPOSDATAB] := dDataAbast
			
			Loop

		EndIf

		If nI == nPosDesLub

			aCols[1,nPosDesLub] := CriaVar( aHeader[nI,2], .F. )

			Loop

		EndIf

		aCols[1][nI] := CriaVar( aHeader[nI][2] )
		
	Next
	
	aCols[1][noBrw1+1] := .F.

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MenuDef  ³ Autor ³ Rafael Diogo Richter  ³ Data ³02/02/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Utilizacao de Menu Funcional.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaMNT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ F.O  ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

	Local aRotTmp
	Local aRotina := {{STR0033,"AxPesqui"  ,0,1},;  //"Pesquisar"
					  {STR0034,"MNTA656INC",0,2},;  //"Visualizar"
					  {STR0035,"MNTA656INC",0,3},;  //"Incluir"
					  {STR0056,"MNTA656INC",0,4},;  //"Alterar"
					  {STR0057,"MNTA656DEL",0,5,3}} //"Excluir"

	dbSelectArea("SX6")
	dbSetOrder(1)
	If dbSeek(xFilial("SX6")+"MV_MNTQDAB")
		aAdd(aRotina,{STR0101,"fParam",0,2}) //"Parâmetro"
	EndIf

	If ExistBlock("MNTA656B")
		aRotTmp := ExecBlock("MNTA656B", .F. , .F.,{aRotina} )
		If ValType(aRotTmp) == "A"
			aRotina := aRotTmp
		EndIf
	EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA656WHD

Fecha os campos descritivos

@author Marcos Wagner Junior
@since 15/10/2008
@sample MNTA656
/*/
//-------------------------------------------------------------------
Function MNTA656WHD()
Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA656WHE

Fecha os campos quando nao se esta incluindo

@author Marcos Wagner Junior
@since 15/10/2008
@sample MNTA656
/*/
//-------------------------------------------------------------------
Function MNTA656WHE(nVar,nOpcx)

	Local 	lRet := INCLUI
	Default nVar := 0

	//-------------------------------------------------------------------------------
	// Ponto de Entrada que possibilita alterar o when do campo passado em parâmentro
	//-------------------------------------------------------------------------------
	If ExistBlock("MNTA6566")
		lRet := ExecBlock("MNTA6566",.F.,.F.,{nVar,lRet,nOpcx})
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA656WIA

Fecha o campo Combustivel Atual

@author Marcos Wagner Junior
@since 15/10/2008
@sample MNTA656
/*/
//-------------------------------------------------------------------
Function MNTA656WIA()

	If Inclui .And. !lTpLub .And. !Empty(cTanque) .And. !Empty(cBomba) .And. !Empty(cTTAComb)
		Return .T.
	EndIf
/*
	nCombAtu  := 0
	nCombTot  := 0
	nCombDign := 0
	CombDif   := 0
*/
Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA656SEC

Validacao dos campos "Servico"

@author Marcos Wagner Junior
@since 20/11/2008
@sample MNTA656
/*/
//-------------------------------------------------------------------
Function MNTA656SEC(cSERVICO)
Local lRet := .T.
Local aOldArea := GetArea()

dbSelectArea('ST4')
dbSetOrder(1)
If !dbSeek(xFilial('ST4')+cSERVICO)
	Help(" ",1,"SERVNAOEXI")
	RestArea(aOldArea)
	lRet := .F.
Else
    If NGFUNCRPO("NGSERVBLOQ",.F.) .And. !NGSERVBLOQ(cSERVICO)
      lRet := .F.
   Else
	   dbSelectArea('STE')
      dbSetOrder(01)
   	If dbSeek(xFilial('STE')+ST4->T4_TIPOMAN)
	   	If STE->TE_CARACTE != 'C'
		   	MsgStop(STR0079,STR0037) //"Serviço deverá ser do tipo Corretivo!"###"ATENÇÃO"
			   lRet := .F.
		   EndIf
	   EndIf
   EndIf
EndIf

RestArea(aOldArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTA656SER³ Autor ³ Marcos Wagner Junior  ³ Data ³ 15/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gatilho dos campos referentes a "Servico"                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA656                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTA656SER(nPar)

	Do Case
		
		Case nPar == 1
			cDesTroca := IIF(!Empty(cTroca),ST4->T4_NOME,Space(Len(ST4->T4_SERVICO)))

		Case nPar == 2
			cDesRepo  := IIF(!Empty(cReposicao),ST4->T4_NOME,Space(Len(ST4->T4_SERVICO)))

		Case nPar == 3

			If !Empty( cResp )
				
				cDescResp := NGSeek( "SRA", cResp, 1, "RA_NOME" )

			Else

				cDescResp := Space( FwTamSX3( 'RA_NOME' )[1] )

			EndIf

		Case nPar == 4

			If !Empty( cPosto ) .And. !Empty( cLoja )
				
				cDescPost := TQF->TQF_NREDUZ
				cCNPJPost := Transform( TQF->TQF_CNPJ, X3Picture( 'TQF_CNPJ' ) )

			EndIf

		Case nPar == 5

			If !Empty( cTTAComb )

				cDescComb := NgSeek( 'TQM', cTTAComb, 1, 'TQM_NOMCOM' )

			EndIf

		Case nPar == 6

			GDFieldPut( 'TT_NOMCODI', NgSeek( 'SB1', M->TT_CODIGO, 1, 'B1_DESC' ), oBrw1:nAt )

	End Case

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA656VAL
Validacao do botao OK

@return

@sample
MNTA656VAL()

@author Marcos Wagner Junior
@since 15/10/08
@version 1.0
/*/
//---------------------------------------------------------------------
Function MNTA656VAL()

	Local nI		:= 0
	Local nJ		:= 0
	Local lMNT656VL	:= ExistBlock("MNT656VL")

	If Empty(dDataAbast)
		MsgStop(STR0036,STR0037) //"Campo 'Data' deverá ser informado!"###"ATENÇÃO"
		Return .F.
	ElseIf Empty(cResp) .And. lObrigResp
		MsgStop(STR0087,STR0037) //"Campo 'Responsável' deverá ser informado!"###"ATENÇÃO"
		Return .F.
	ElseIf Empty(cFolha)
		MsgStop(STR0038,STR0037) //"Campo 'Folha' deverá ser informado!"###"ATENÇÃO"
		Return .F.
	ElseIf Empty(cPosto)
		MsgStop(STR0039,STR0037) //"Campo 'Posto' deverá ser informado!"###"ATENÇÃO"
		Return .F.
	ElseIf Empty(cLoja)
		MsgStop(STR0040,STR0037) //"Campo 'Loja' deverá ser informado!"###"ATENÇÃO"
		Return .F.
	ElseIf Empty(cTanque) .And. !lTpLub
		MsgStop(STR0041,STR0037) //"Campo 'Tanque' deverá ser informado!"###"ATENÇÃO"
		Return .F.
	ElseIf Empty(cBomba) .And. !lTpLub
		MsgStop(STR0042,STR0037) //"Campo 'Bomba' deverá ser informado!"###"ATENÇÃO"
		Return .F.
	ElseIf Empty(cTTAComb) .And. !lTpLub
		MsgStop(STR0211,STR0037) //"Código do combustível do abastecimento não foi informado"###"ATENÇÃO"
		Return .F.
	EndIf

	aCols := aClone(oBrw1:aCols)
	If Inclui .Or. Altera

		aOSLub := {}
		For nI := 1 to Len(aCols)
			nW := nI

			Aadd(aOSLub,'')

			lNao_SD3 := .F.
			If lMNT656VL //Verifica se nao deve atualizar estoque e hodometro
				xAferiHod := ExecBlock("MNT656VL",.F.,.F.,{aCols[nI][nPOSFROTA]})
				lNao_SD3 := IIf( ValType(xAferiHod) == "A", xAferiHod[1], xAferiHod)
			EndIf
			If Inclui .OR. (Altera .And. aScan(aOldCols,{|x| DtoS(x[nPOSDATAB])+x[nPOSHORAB]+x[nPOSFROTA] == DtoS(aCols[nI][nPOSDATAB])+aCols[nI][nPOSHORAB]+aCols[nI][nPOSFROTA] }) == 0)
				If !aCols[nI][Len(aHeader)+1]
					/*cFil := MNTA656FIL(aCols[nI][nPOSFROTA],aCols[nI][nPOSDATAB],aCols[nI][nPOSHORAB],aCols[nI][nPOSPLACA])
					 Substituido função pela filial corrente da STJ, para que a OS de lubrificação ao ser incluida utilize
					 a filial logada no momento, pois a ST9 pode não seguir o mesmo compartilhamento que a STJ*/
					//verifica se foi reportado Produto
					cOSLub := " "
					If !Empty(aCols[nI][nPOSLUBRI])
						cOSLub := MNT656LUB(aCols[nI][nPOSFROTA],If(aCols[nI][nPOSTRREP] == "1",cTroca,cReposicao),aCols[nI][nPOSLUBRI],aCols[nI][nPOSQUALU],;
						aCols[nI][nPOSDATAB],aCols[nI][nPOSHORAB],aCols[nI][nPOSHODOM],nI,,aCols[nI][nPOSCUSTO], xFilial("STJ"))
						If Empty(cOSLub)
							For nJ := 1 to Len(aOSLub)
								If !Empty(aOSLub[nJ])
									NGDELETOS(aOSLub[nJ],'000000')
								EndIf
							Next nJ
							Return .F.
						Else
							aOSLub[nI] := cOSLub
						EndIf
					EndIf
				EndIf
			EndIf
		Next
	EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNT656LTB ³ Autor ³ Marcos Wagner Junior  ³ Data ³ 15/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Limpa campos Loja, Tanque e Bomba quando informado Posto   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA656                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT656LTB(nPar)

	Local aOldArea := GetArea()
	Local lRet := .T.
	Local cChaveTQF

	If ReadVar() == 'CPOSTO'
			cChaveTQF := cPosto
	ElseIf ReadVar() == 'CLOJA'
		cChaveTQF := cPosto + cLoja
	EndIf

	lRet := ExistCpo('TQF', cChaveTQF, 1)

	If ( nPar == 1 .And. cPosto != cOldPosto .And. !Empty(cOldPosto) ) .Or.;
		( nPar == 2 .And. cLoja != cOldLoja .And. !Empty(cOldLoja) )

		cTanque := Space( TamSX3('TTA_TANQUE')[1] )
		cBomba  := Space( TamSX3('TTA_BOMBA' )[1] )
	EndIf

	cOldPosto := cPosto
	cOldLoja  := cLoja

	If nPar == 2
		lRet := MNTA656FOL( cPosto, cLoja, cFolha )
	EndIf

	RestArea(aOldArea)

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |MNT655POIN³ Autor ³ Marcos Wagner Junior  ³ Data ³ 15/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o Posto/Loja digitado(a) e um Posto Interno    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA656                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT655POIN()
Local aOldArea := GetArea()
Local lRet := .T.

dbSelectArea("TQF")
dbSetOrder(01)
If dbSeek(xFilial("TQF")+cPosto+cLoja) .And. !Empty(cPosto) .And. !Empty(cLoja)
	If TQF->TQF_TIPPOS != '2'
		MsgStop(STR0044,STR0037) //"Posto informado não é um Posto Interno!"###"ATENÇÃO"
		lRet := .F.
	EndIf
EndIf

RestArea(aOldArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MNT656TABO
Verifica o Tanque ou Bomba digitada

@author  Marcos Wagner Junior
@since   15/10/08
@version P11/P12
@param	 nPar	  , Numérico, 1 - Tanque / 2 - Bomba
@param	 dDataAbs , Data	, Data do Abastecimento
@param	 cHrAbas  , Caracter, Hora do Abastecimento
/*/
//-------------------------------------------------------------------
Function MNT656TABO(nPar, dDataAbs, cHrAbas)

	Local aOldArea  := GetArea()
	Local lNaoEntra := .T.
	Local lRet		:= .T.
	Local lCamp		:= Type("cTTAComb") == "C"
	Local cTTAComb1 := IIF(Inclui,IIF(lCamp, cTTAComb, Space(Len(TQN->TQN_CODCOM))),MNT656CMB())
	Local cCombBKP  := IIf(Empty(cTTAComb1),"",cTTAComb1)

	Default dDataAbs := IIf( Empty(dDataAbs), CToD('  \  \   '), dDataAbs )
	Default cHrAbas	 := IIf( Empty(cHrAbas), '  :  ', cHrAbas )

	If Empty( cCombust )
		dbSelectArea("TQI")
		dbSetOrder(1)
		If dbSeek(xFilial("TQI") + cPosto + cLoja + cTanque + cCombBKP)
			cCombust := TQI->TQI_CODCOM //Código do combustível.
		EndIf
	EndIf

	dbSelectArea("TQJ")
	dbSetOrder(01)
	If nPar == 1

		If !dbSeek(xFilial("TQJ")+cPosto+cLoja+cTanque)
			MsgStop(STR0045,STR0037) //"Tanque informado não pertence ao Posto!"###"ATENÇÃO"
			lRet := .F.
		EndIf

		cCodCom  := NGSEEK('TQI',cPosto+cLoja+cTanque+cCombBKP,1,'TQI->TQI_CODCOM')
		cProComb := NGSEEK('TQI',cPosto+cLoja+cTanque+cCombBKP,1,'TQI->TQI_PRODUT')

		If Empty(cTTAComb1)
			// Caso o combustível esteja vazio, pega o primeiro combustível do tanque, visto que em geral, só haverá um combustível por tanque.
			cTTAComb1 := cCodCom
		EndIf

		lChkLote   := .F.

		//Validação para que não permita selecionar um produto com controle de Rastro
		If GetNewPar("MV_RASTRO","N") == "S" .And. NGSEEK('SB1',cProComb,1,"B1_RASTRO") <> "N"
			If !EXISTCPO('SB1',cProComb)
				lRet := .F.
			Else
				If SB1->B1_RASTRO <> "N" .And. !Empty(SB1->B1_RASTRO)
					MsgStop(STR0206) //"Não é possivel infomar um produto que utiliza rastro ou lote/sublote."
					Return .F.
				EndIf
			EndIf
		EndIf

		If AllTrim(GetMV("MV_NGMNTES")) == 'S' .And. !Empty(cProComb) .And. ;
					( (AllTrim( GetMV("MV_RASTRO") ) == 'S' .And. NGSEEK('SB1', cProComb, 1, "B1_RASTRO") <> "N") .Or.;
						(AllTrim( GetMV("MV_LOCALIZ") ) == 'S' .And. NGSEEK('SB1',cProComb,1,"B1_LOCALIZ") == "S") )

				lChkLote := .T.
	  	EndIf
	Else

		If Inclui .And. !dbSeek(xFilial("TQJ")+cPosto+cLoja+cTanque+cBomba) .And. ((!Empty(cTanque) .And. !Empty(cBomba)) .Or. (Empty(cTanque)))
			MsgStop(STR0046,STR0037) //"Bomba informada não pertence ao Tanque!"###"ATENÇÃO"
			lRet := .F.
		Else
			If TQJ->TQJ_MOTIVO == '3'
				lNaoEntra := .F.
				nCombAnt := TQJ->TQJ_CONINI
			EndIf
		EndIf
	EndIf

	If lNaoEntra
		MNT656CABO(nPar, dDataAbs, cHrAbas)
	EndIf

	nTotalTQN := nCombAnt

	RestArea(aOldArea)

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |MNTA656MAR³ Autor ³ Marcos Wagner Junior  ³ Data ³ 15/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Alimenta o campo Marcador											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA656                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTA656MAR(nPar)
Local nX
Local nTotalTQN := nCombAnt
Local nSomaComb := 0

If !aCols[n][Len(aCols[n])] .Or. ReadVar() == 'NCOMBATU' .Or. ReadVar() == 'NLUBINF'
	If nPar == 1
		For nX := 1 to Len(aCols)
			If !aCols[nX][Len(aCols[nX])]
				If nX == n
					nTotalTQN := nTotalTQN + If(ReadVar()=='M->TQQ_QUANT',M->TQQ_QUANT,aCols[n][nPOSQUANT])
				Else
			  		nTotalTQN := nTotalTQN + aCols[nX][nPOSQUANT]
			  		nSomaComb += aCols[nX][nPOSQUANT]
			 	EndIf
				aCols[nX][nPOSMARCA] := nTotalTQN
			EndIf
		Next

		If aCols[n][nPOSQUANT] <> 0 .And. !Altera
			nCombDig -= aCols[n][nPOSQUANT]
			nCombDif += aCols[n][nPOSQUANT]
			nCombDig += M->TQQ_QUANT
			//Inserção de NoRound, paliativamente, devido à inconsistência de Framework TOTVS
			nCombDif := NoRound(nCombTot - nCombDig,3)
		ElseIf Altera
			nCombDig := nSomaComb + M->TQQ_QUANT + fLoadTTHC()
			nCombDif := nCombTot - nCombDig
		Else
			nCombDig += M->TQQ_QUANT + nDigTTH
			//Inserção de NoRound, paliativamente, devido à inconsistência de Framework TOTVS
			nCombDif := NoRound(nCombTot - nCombDig,3)
		EndIf
		oCombDig:Refresh()
		oCombDif:Refresh()

	ElseIf nPar == 2
		If aCols[n][nPOSQUALU] <> 0
			nLubDig -= aCols[n][nPOSQUALU]
			nLubDif += aCols[n][nPOSQUALU]
			nLubDig += M->TPE_AJUSCO
			nLubDif := nLubInf - nLubDig
		Else
			nLubDig += M->TPE_AJUSCO
			nLubDif := nLubInf - nLubDig
		EndIf
		oLubDig:Refresh()
		oLubDif:Refresh()
	EndIf
EndIf

Return .T.

//----------------------------------------------------------------------------
/*/{Protheus.doc} MNT656OK
LinhaOK e TudoOK.
@type function

@author Marcos Wagner Junior
@since 15/10/2008

@sample MNT656OK( 1 )

@param 	nPar  , Númerico, 1 - LinhaOK / 2 - TudoOK
@return Lógico, Define se a folha de abastecimento pode ser salva.
/*/
//----------------------------------------------------------------------------
Function MNT656OK(nPar)

	Local lNaoValid		:= .F. //Variavel para nao validar os campos ODOMETRO e COD MOTORISTA
	Local lDtAbsIgual	:= .F. //Indica se todos os abastecimentos deverao ter a mesma data
	Local lInformLub	:= .F.
	Local lInformAba	:= .F.
	Local lTemAfer		:= .F.//Indica se tem afericao
	Local lRet			:= .T.
	Local lMNTA6565		:= ExistBlock("MNTA6565")
	Local cAbast656		:= AllTrim(STR0005) //"Abastecimento"
	Local cLubri656		:= AllTrim(STR0018) //"Produto"
	Local cCombustiv	:= NGSEEK("TQI",cPosto+cLoja+cTanque+cTTAComb,1,"TQI->TQI_CODCOM")
	Local nPosRastro	:= 0
	Local nI			:= 0
	Local nInd			:= 0
	Local nPosR			:= 0
	Local nLinha		:= n
	Local aValAbast		:= {}
	Local xAferiHod   	:= {}
	Local lValCont2     := .F.

	Private lAfericao	:= If(SuperGetMv("MV_NGMNTAF",.F.,"2") == "1",.T.,.F.)//Verifica parametro que indica se deve validar com afericao

	// No processo de validação de linha, caso esteja deletado não realiza a validação.
	If oBrw1:aCols[n, Len( oBrw1:aCols[n] )] .And. nPar == 1
		Return .T.
	EndIf

	If Inclui .And. !NG656ALM(n)
		Return .F.
	EndIf

	If ExistBlock("MNT656VL")
		xAferiHod := ExecBlock("MNT656VL",.F.,.F.,{aCols[n][nPOSFROTA]})
		lNaoValid := IIf( ValType(xAferiHod) == "A", xAferiHod[1], xAferiHod)
	EndIf
	If ExistBlock("MNT656DTIG")
		lDtAbsIgual := .T.
	EndIf

	MNT656CABO(3)
	If !MNT656CTOT() //Verifica senao vai passar o limite do contador da bomba
		Return .F.
	EndIf

	If Empty(oBrw1:aCols[n][nPOSPLACA])
		dbSelectArea("ST9")
		dbSetOrder(1)
		dbSeek(cFiliST9 + oBrw1:aCols[n][nPOSFROTA])
	Else
		dbSelectArea("ST9")
		dbSetOrder(14)
		dbSeek(oBrw1:aCols[n][nPOSPLACA])
	EndIf

	For nI := 1 to Len(aHeader)

		If Len(nLanca) == Len(cLubri656) //Se Lancamento for igual a "Produto"
			If Empty(oBrw1:aCols[n][nPOSLUBRI])
				HELP(" ",1,"OBRIGAT",,aHeader[nPOSLUBRI][1],05)
				Return .F.
			ElseIf Empty(oBrw1:aCols[n][nPOSQUALU])
				HELP(" ",1,"OBRIGAT",,aHeader[nPOSQUALU][1],05)
				Return .F.
			ElseIf Empty(oBrw1:aCols[n][nPOSTRREP])
				HELP(" ",1,"OBRIGAT",,aHeader[nPOSTRREP][1],05)
				Return .F.
			ElseIf Empty(oBrw1:aCols[n][nPOSCUSTO]) .And. cUsaInt3 == 'N'
				HELP(" ",1,"OBRIGAT",,aHeader[nPOSCUSTO][1],05)
				Return .F.
			EndIf
			If lRastr
				If !MNTA656TU(n)
					Return .F.
				EndIf
			EndIf
		ElseIf Len(nLanca) == Len(cAbast656) //Se Lancamento for igual a "Abastecimento"

			If Empty(oBrw1:aCols[n][nPOSHODOM]) .And. ST9->T9_TEMCONT = "S"
				HELP(" ",1,"OBRIGAT",,aHeader[nPOSHODOM][1],05)
				Return .F.
			ElseIf Empty(oBrw1:aCols[n][nPOSQUANT])
				HELP(" ",1,"OBRIGAT",,aHeader[nPOSQUANT][1],05)
				Return .F.
			ElseIf Empty(oBrw1:aCols[n][nPOSMOTOR]) .And. ST9->T9_TEMCONT = "S"
				If Empty(cMotGer) .Or. Empty(cMotorista)
					HELP(" ",1,"OBRIGAT",,aHeader[nPOSMOTOR][1],05)
					Return .F.
				EndIf
			EndIf
		ElseIf !( ( !Empty( oBrw1:aCols[n, nPOSLUBRI] ) .And. !Empty( oBrw1:aCols[n, nPOSQUALU]) .And.;
		            !Empty( oBrw1:aCols[n, nPOSTRREP] ) ) .Or. ( !Empty( oBrw1:aCols[n, nPOSQUANT] ) ) )
					ApMsgStop(STR0105,STR0037) //"Deverá ser lançado um Produto ou um abastecimento!"###"ATENÇÃO"
					Return .F.
		Else

			If lRastr .And. !MNTA656TU( n )

				Return .F.

			EndIf

		EndIf

		If nI == nPOSHORAB

			If AllTrim( oBrw1:aCols[n, nPOSHORAB] ) == ':' .Or. Empty( oBrw1:aCols[n, nPOSHORAB] )

				Help( '', 1, 'OBRIGAT', , aHeader[nPOSHORAB,1], 05 )
				Return .F.

			EndIf

		ElseIf nI == nPOSLUBRI
			If Empty(oBrw1:aCols[n][nPOSQUALU]) .And. !Empty(oBrw1:aCols[n][nPOSLUBRI])
				HELP(" ",1,"OBRIGAT",,aHeader[nPOSQUALU][1],05)
				Return .F.
			ElseIf Empty(oBrw1:aCols[n][nPOSTRREP]) .And. !Empty(oBrw1:aCols[n][nPOSLUBRI])
				HELP(" ",1,"OBRIGAT",,aHeader[nPOSTRREP][1],05)
				Return .F.
			ElseIf Empty(oBrw1:aCols[n][nPOSALMOX]) .And. !Empty(oBrw1:aCols[n][nPOSLUBRI])
				HELP(" ",1,"OBRIGAT",,aHeader[nPOSALMOX][1],05)
				Return .F.
			ElseIf Empty(oBrw1:aCols[n][nPOSCUSTO]) .And. !Empty(oBrw1:aCols[n][nPOSLUBRI]) .And. cUsaInt3 == 'N'
				HELP(" ",1,"OBRIGAT",,aHeader[nPOSCUSTO][1],05)
				Return .F.
			EndIf
		ElseIf nI = nPOSQUALU
			If Empty(oBrw1:aCols[n][nPOSLUBRI]) .And. !Empty(oBrw1:aCols[n][nPOSQUALU])
				HELP(" ",1,"OBRIGAT",,aHeader[nPOSLUBRI][1],05)
				Return .F.
			ElseIf Empty(oBrw1:aCols[n][nPOSTRREP]) .And. !Empty(oBrw1:aCols[n][nPOSQUALU])
				HELP(" ",1,"OBRIGAT",,aHeader[nPOSTRREP][1],05)
				Return .F.
			ElseIf Empty(oBrw1:aCols[n][nPOSCUSTO]) .And. !Empty(oBrw1:aCols[n][nPOSQUALU]) .And. cUsaInt3 == 'N'
				HELP(" ",1,"OBRIGAT",,aHeader[nPOSCUSTO][1],05)
				Return .F.
			EndIf
		ElseIf nI = nPOSTRREP
			If Empty(oBrw1:aCols[n][nPOSLUBRI]) .And. !Empty(oBrw1:aCols[n][nPOSTRREP])
				HELP(" ",1,"OBRIGAT",,aHeader[nPOSLUBRI][1],05)
				Return .F.
			ElseIf Empty(oBrw1:aCols[n][nPOSQUALU]) .And. !Empty(oBrw1:aCols[n][nPOSTRREP])
				HELP(" ",1,"OBRIGAT",,aHeader[nPOSQUALU][1],05)
				Return .F.
			ElseIf Empty(oBrw1:aCols[n][nPOSCUSTO]) .And. !Empty(oBrw1:aCols[n][nPOSTRREP]) .And. cUsaInt3 == 'N'
				HELP(" ",1,"OBRIGAT",,aHeader[nPOSCUSTO][1],05)
				Return .F.
			EndIf
		ElseIf nI = nPOSCUSTO
			If Empty(oBrw1:aCols[n][nPOSLUBRI]) .And. !Empty(oBrw1:aCols[n][nPOSCUSTO])
				HELP(" ",1,"OBRIGAT",,aHeader[nPOSLUBRI][1],05)
				Return .F.
			ElseIf Empty(oBrw1:aCols[n][nPOSQUALU]) .And. !Empty(oBrw1:aCols[n][nPOSCUSTO])
				HELP(" ",1,"OBRIGAT",,aHeader[nPOSQUALU][1],05)
				Return .F.
			ElseIf Empty(oBrw1:aCols[n][nPOSTRREP]) .And. !Empty(oBrw1:aCols[n][nPOSCUSTO])
				HELP(" ",1,"OBRIGAT",,aHeader[nPOSTRREP][1],05)
				Return .F.
			EndIf
		ElseIf nI = nPOSLOTE .or. nI = nPOSSUBLO .or. nI = nPOSDTVAL .or. nI = nPOSLOCAL .or. nI = nPOSNUMSE
			Loop
		Else
			If (nI = nPOSHODOM .or. nI = nPOSMOTOR) .And. lNaoValid
				Loop
			EndIf
			If Empty(oBrw1:aCols[n][nI]) .And. nI != nPOSQUANT
				If nI == nPOSMARCA

				ElseIf nI == nPOSMOTOR
					If !Empty(oBrw1:aCols[n][nPOSQUANT]) .And. nI == nPOSMOTOR .And. !lTpLub .And. ST9->T9_TEMCONT == "S" //Se Quantidade preenchida e motorista em branco e não for somente Produto
						If Empty(cMotGer) .Or. Empty(cMotorista)
							HELP(" ",1,"OBRIGAT",,aHeader[nPOSMOTOR][1],05)
							Return .F.
						EndIf
					EndIf
				ElseIf nI == nPOSHODOM
					If ST9->T9_TEMCONT = "S"
						HELP(" ",1,"OBRIGAT",,aHeader[nI][1],05)
						Return .F.
					EndIf
				ElseIf nI == nPOSCONT2
					//FindFunction remover na release GetRPORelease() >= '12.1.027'
					If FindFunction("MNTCont2")
						lValCont2 := MNTCont2(cFiliST9, oBrw1:aCols[n][nPOSFROTA])
					Else
						If !Empty(TPE->TPE_CODBEM)
							If !lDtvSgCnt .Or. (lDtvSgCnt .And. TPE->TPE_SITUAC == "1")
								lValCont2 := .F.
							EndIf
						EndIf
					EndIf
					If lValCont2
						HELP(" ",1,"OBRIGAT",,aHeader[nI][1],05)
						Return .F.
					EndIf
				EndIf
			EndIf
		EndIf
		/*
		MNT659VAL - Função que valida abastecimento de acordo com parâmetro MV_NGABAVL
		Se tiver algum retorno falso no segundo vetor mostra divergencia/erro.
		ex.:Retorno:
		{{"Mensagem"}- Mensagem que será apresentada no abastecimento manual
		{{.F.," 47"} - Validação de Esquema Padrão	 - código da inconsistencia pela importação
		{.F.," 48"}  - Validação de Estrutura Padrão - código da inconsistencia pela importação
		{.F.," 49"}  - Validação de Manutenção Padrão- código da inconsistencia pela importação
		{.F.," 50"}}}- Validação de Manutenção		 - código da inconsistencia pela importação
		*/

		If FindFunction("MNT659VAL")
			aValAbast:= MNT659VAL(aCols[n][nPOSFROTA], cFiliST9 ,aCols[n][nPOSDATAB],aCols[n][nPOSHORAB])
			If aScan(aValAbast[2], {|x| x[1] == .F. }) > 0
				MsgInfo(aValAbast[1][1])
				Return .F.
			EndIf
		EndIf

		//Validação da quantidade de Produto (Aditivo) para o tanque do bem.
		//Verifica se é Produto Aditivo (para o tanque do bem) ou Produto Lubrificante
		dbSelectArea("TT8")
		dbSetOrder(2) // - TT8_FILIAL+TT8_CODBEM+TT8_TIPO+TT8_CODCOM
		If DbSeek(xFilial("TT8")+aCols[n][nPOSFROTA]+"2"+aCols[n][nPOSLUBRI])
			If TT8->TT8_CAPMAX < aCols[n][nPOSQUALU]
				ApMsgStop(STR0184,STR0037)		//"A quantidade de Produto (Aditivo) supera a capacidade máxima permitida."###"ATENÇÃO"
				Return .F.
			EndIf
		EndIf
	Next

	//Verifica se Data/Hora do abastecimento é valida, de acordo com o parametro MV_MNTQDAB, que indica a data/hora limite para digitação de abastecimento.
	lUpdaCols := .F.
	If !oBrw1:aCols[n,Len(oBrw1:aCols[n])] .And. Type("aCols656") == "A"
		If Len(oBrw1:aCols) >= n .And. Len(aCols656) >= n
			lUpdaCols := .F.
			For nInd := 1 To Len(oBrw1:aCols[n])
				If oBrw1:aCols[n,nInd] <> aCols656[n,nInd]
					lUpdaCols := .T.
					Exit
				EndIf
			Next nInd
		Else
			lUpdaCols := .T.
		EndIf
	EndIf


	If lUpdaCols
		aRetDtPar := NgDtAbas()
		If aRetDtPar[3]
			If ValType(aRetDtPar[2]) == "C"
				If DtoS(oBrw1:aCols[n][nPOSDATAB])+oBrw1:aCols[n][nPOSHORAB] <  DtoS(aRetDtPar[1])+aRetDtPar[2]
					ApMsgStop(STR0090+; //"Nenhuma movimentação de abastecimento poderá ser processada antes da data/hora: "
								DtoC(aRetDtPar[1])+" "+aRetDtPar[2]+".",STR0037) //"ATENÇÃO"
					Return .F.
				EndIf
			Else
				If oBrw1:aCols[n][nPOSDATAB] <  aRetDtPar[1]
					ApMsgStop(STR0091+; //"Nenhuma movimentação de abastecimento poderá ser processada antes da data: "
								DtoC(aRetDtPar[1])+".",STR0037) //"ATENÇÃO"
					Return .F.
				EndIf
			EndIf
		EndIf
	EndIf


	If lAfericao  .And. Inclui .And. nLanca <> STR0018 //Verificar se o Tipo Lançamento é diferente de Produto
		lTemAfer := .F.
		//Verifica a aferição da bomba
		dbSelectArea("TQL")
		dbSetOrder(1)
		If dbSeek(xFilial("TQL")+cPosto+cLoja+cTanque+cBomba+DTOS(oBrw1:aCols[n][nPOSDATAB]))
			While !Eof() .And. ;
				TQL->TQL_FILIAL+TQL->TQL_POSTO+TQL->TQL_LOJA+TQL->TQL_TANQUE+TQL->TQL_BOMBA+DTOS(TQL->TQL_DTCOLE) == xFilial("TQL")+cPosto+cLoja+cTanque+cBomba+DTOS(oBrw1:aCols[n][nPOSDATAB])
				If oBrw1:aCols[n][nPOSHORAB] > TQL->TQL_HRINIC .And. Empty(TQL->TQL_HRFIM)
					lTemAfer := .T.
				Elseif oBrw1:aCols[n][nPOSHORAB] > TQL->TQL_HRINIC .And. !Empty(TQL->TQL_HRFIM) .And. oBrw1:aCols[n][nPOSHORAB] < TQL->TQL_HRFIM
					lTemAfer := .T.
				EndIf
				TQL->(dbSkip())
			End
		EndIf

		If !lTemAfer
			ShowHelpDlg("ATENÇÃO",{STR0154},2,{STR0155},2)//"ATENCAO"###"Tanque/Bomba não possui aferição para data do abastecimento."###"Inclua uma aferição para a mesma data e com hora infeior ao abastecimento ou selecione um Tanque/Bomba aferido."
			Return .F.
		EndIf
	EndIf

	If nPar == 2 //  Validação TUDOOK

		If nCombDif <> 0
			ApMsgStop(STR0047+AllTrim(Str(nCombDig))+chr(13)+; //"A quantidade de combustivel digitado: "
						STR0048+AllTrim(Str(nCombTot))+".",STR0037) //"esta diferente do total informado: "###"ATENÇÃO"
		Return .F.
		EndIf
		If nLubDif <> 0
			ApMsgStop(STR0049+AllTrim(Str(nLubDig))+chr(13)+; //"A quantidade de Produto digitado:"
					STR0048+AllTrim(Str(nLubInf))+".",STR0037) //"esta diferente do total informado: "###"ATENÇÃO"
		Return .F.
		EndIf

		dTmpDtIni := StoD("")
		lDatasOK := .T.
		For nI := 1 to Len(oBrw1:aCols)
			If !oBrw1:aCols[nI][Len(oBrw1:aCols[nI])]

				If AllTrim( oBrw1:aCols[nI, nPOSHORAB] ) == ':' .Or. Empty( oBrw1:aCols[n, nPOSHORAB] )

					Help( '', 1, 'OBRIGAT', , oBrw1:aHeader[nPOSHORAB,1], 05 )
					Return .F.

				EndIf

				If (nLanca == STR0006 .OR. nLanca == STR0018) //"Abastecimento+Produto"###"Produto"

					If !Empty(oBrw1:aCols[n][nPOSPLACA])
						dbSelectArea("ST9")
						dbSetOrder(14)
						If dbSeek(oBrw1:aCols[n][nPOSPLACA] + "A")
							If xFilial("ST9",cFilAnt) <> ST9->T9_FILIAL .And. !Empty(ST9->T9_FILIAL)
								MsgStop(STR0130+Chr(13)+Chr(10)+; //"Para Folha com opção de lançamento de Produtos somente poderão ser digitados veículos da filial em uso."
								STR0132+ST9->T9_FILIAL+Chr(13)+Chr(10)+; //"Filial do Veículo: "
								STR0133+cFilAnt) //"Filial Em Uso: "
								Return .F.
							Endif
						EndIf
					Else
						dbSelectArea("ST9")
						dbSetOrder(1)
						If dbSeek(xFilial("ST9") + oBrw1:aCols[nI][nPOSFROTA])
							While !Eof() .And. ST9->T9_CODBEM == oBrw1:aCols[nI][nPOSFROTA]
								If xFilial("ST9",cFilAnt) <> ST9->T9_FILIAL .And. !Empty(ST9->T9_FILIAL)
									lRet := .F.
								Else
									lRet := .T.
									Exit
								EndIf

								dbSelectArea("ST9")
								dbSkip()
							End
							If !lRet
								MsgStop(STR0130+Chr(13)+Chr(10)+; //"Para Folha com opção de lançamento de Produtos somente poderão ser digitados veículos da filial em uso."
									STR0131+oBrw1:aCols[nI][nPOSFROTA]+Chr(13)+Chr(10)+; //"Veículo: "
									STR0132+ST9->T9_FILIAL+Chr(13)+Chr(10)+; //"Filial do Veículo: "
									STR0133+cFilAnt) //"Filial Em Uso: "
								Return .F.
							EndIf
						EndIf
					EndIf
				EndIf

				If Empty(dTmpDtIni)
					dTmpDtIni := oBrw1:aCols[nI][nPOSDATAB]
				Else
					If dTmpDtIni <> oBrw1:aCols[nI][nPOSDATAB]
						lDatasOK := .F.
					EndIf
				EndIf

				If !Empty(oBrw1:aCols[nI][nPOSQUANT])
					lInformAba := .T.
				EndIf

				If !Empty(oBrw1:aCols[nI][nPOSLUBRI]) .And. !Empty(oBrw1:aCols[nI][nPOSQUALU]) .And. !Empty(oBrw1:aCols[nI][nPOSTRREP])
					lInformLub := .T.
				EndIf

				If lInformLub .And. lRastr
					If !MNTA656TU()
						Return .F.
					EndIf
				EndIf
			EndIf

			If lAfericao .And. Inclui .And. nLanca <> STR0018 //Verificar se o Tipo Lançamento é diferente de Produto
				lTemAfer := .F.
				//Verifica a aferição da bomba
				dbSelectArea("TQL")
				dbSetOrder(1)
				If dbSeek(xFilial("TQL")+cPosto+cLoja+cTanque+cBomba+DTOS(oBrw1:aCols[nI][nPOSDATAB]))
					While !Eof() .And. ;
						TQL->TQL_FILIAL+TQL->TQL_POSTO+TQL->TQL_LOJA+TQL->TQL_TANQUE+TQL->TQL_BOMBA+DTOS(TQL->TQL_DTCOLE) == xFilial("TQL")+cPosto+cLoja+cTanque+cBomba+DTOS(oBrw1:aCols[nI][nPOSDATAB])
						If oBrw1:aCols[nI][nPOSHORAB] > TQL->TQL_HRINIC .And. Empty(TQL->TQL_HRFIM)
							lTemAfer := .T.
						Elseif oBrw1:aCols[n][nPOSHORAB] > TQL->TQL_HRINIC .And. !Empty(TQL->TQL_HRFIM) .And. oBrw1:aCols[n][nPOSHORAB] < TQL->TQL_HRFIM
							lTemAfer := .T.
						EndIf
						TQL->(dbSkip())
					End
				EndIf

				If !lTemAfer
					ShowHelpDlg("ATENÇÃO",{STR0154},2,{STR0155},2)//"ATENCAO"###"Tanque/Bomba não possui aferição para data do abastecimento."###"Inclua uma aferição para a mesma data e com hora infeior ao abastecimento ou selecione um Tanque/Bomba aferido."
					Return .F.
				EndIf
			EndIf
		Next nI

		If lDtAbsIgual //Somente se existir ponto de entrada
			If !lDatasOK
				ApMsgStop(STR0097,STR0037) //"Todos os registros de abastecimentos devem ter a mesma data."###"ATENÇÃO"
				Return .F.
			EndIf
		EndIf
		If Len(nLanca) != Len(cAbast656) //Se Lancamento diferente de "Abastecimento"
			If !lInformLub
				ApMsgStop(STR0098,STR0037) //"Deverá existir pelo menos 1 lançamento de produto!"###"ATENÇÃO"
				Return .F.
			EndIf
		EndIf
		If Len(nLanca) != Len(cLubri656) //Se Lancamento diferente de "Produto"
			If	!lInformAba
				ApMsgStop(STR0099,STR0037) //"Deverá existir pelo menos 1 lançamento de abastecimento!"###"ATENÇÃO"
				Return .F.
			EndIf
		EndIf
	EndIf

	If nPar == 1 .And. !lNaoValid .And. ST9->T9_TEMCONT = "S"

		//Valida o contador informado quando ativado o parametro MV_NGLANEX
		MNT656WC(.F.)
		//validacoes de contador
		lVirada := .F.
		cUM := " "
		cNumSeqD := " "
		cFil := MNTA656FIL(oBrw1:aCols[n][nPOSFROTA],oBrw1:aCols[n][nPOSDATAB],oBrw1:aCols[n][nPOSHORAB],aCols[n][nPOSPLACA])

		lTesta := .F.

		If !aCols[n][Len(aHeader)+1]
			If Inclui
				lTesta := .T.
			ElseIf Altera
				If aScan(aOldCols,{|x| DtoS(x[nPOSDATAB])+x[nPOSHORAB]+x[nPOSFROTA] == DtoS(oBrw1:aCols[n][nPOSDATAB])+oBrw1:aCols[n][nPOSHORAB]+oBrw1:aCols[n][nPOSFROTA] }) == 0
					lTesta := .T.
				Else
					nPosX := aScan(aOldCols,{|x| DtoS(x[nPOSDATAB])+x[nPOSHORAB]+x[nPOSFROTA] == DtoS(oBrw1:aCols[n][nPOSDATAB])+oBrw1:aCols[n][nPOSHORAB]+oBrw1:aCols[n][nPOSFROTA] })
					If !Empty(nPosX)
						If oBrw1:aCols[n][nPOSHODOM] <> aOldCols[nPosX,nPOSHODOM] .Or. (lSegCont .And. oBrw1:aCols[n][nPOSCONT2] <> aOldCols[nPosX,nPOSCONT2])
							lTesta := .T.
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

		If lTesta
			nW := n
			//Caso o campo quantidade for vazio será realizado um reporte de contador do tipo "C"
			If !MNT655HOD(1,!Empty(oBrw1:aCols[n][nPOSQUANT]))
				Return .F.
			EndIf

			If !lVIRADA .And. !Altera //se houve virada de contador com mesma dt e hr de abast. nao faz reporte de contador
				If !NGCHKHISTO(oBrw1:aCols[n][nPOSFROTA],oBrw1:aCols[n][nPOSDATAB],oBrw1:aCols[n][nPOSHODOM],oBrw1:aCols[n][nPOSHORAB],1,,.T.,cFil,cCodCom)
					Return .F.
				EndIf
				If !NGVALIVARD(oBrw1:aCols[n][nPOSFROTA],oBrw1:aCols[n][nPOSHODOM],oBrw1:aCols[n][nPOSDATAB],oBrw1:aCols[n][nPOSHORAB],1,.T.,,cFil)
					Return .F.
				EndIf
			EndIf
			If TipoAcom2
				lVirada := .F.
			IF lSegCont
				If !MNT655HOD(2)
					Return .F.
				EndIf
				If !lVIRADA .And. !Altera //se houve virada de contador com mesma dt e hr de abast. nao faz reporte de contador
					If !NGCHKHISTO(oBrw1:aCols[n][nPOSFROTA],oBrw1:aCols[n][nPOSDATAB],oBrw1:aCols[n][nPOSCONT2],oBrw1:aCols[n][nPOSHORAB],2,,.T.,cFil,cCodCom)
						Return .F.
					EndIf
					If !NGVALIVARD(oBrw1:aCols[n][nPOSFROTA],oBrw1:aCols[n][nPOSCONT2],oBrw1:aCols[n][nPOSDATAB],oBrw1:aCols[n][nPOSHORAB],2,.T.,,cFil)
						Return .F.
					EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	cMensag := ''

	If lChkLote .And. nPar == 1
		cNComb	:= NGSEEK('TQM',cCodCom,1,'TQM->TQM_NOMCOM')
		cPComb 	:= NGSEEK('TQI',cPosto+cLoja+cTanque+cTTAComb,1,'TQI->TQI_PRODUT')
		nPosR 	:= aScan(aRastro,{|x| x[8] == n })

		//se altera a qtd de combustivel faz os acertos nas arrays
		If nPosR > 0 .And. Len(aRastro[nPosR]) == 9
			If aRastro[nPosR][9] <> oBrw1:aCols[n][nPOSQUANT]
				nPOSX := Ascan(aQtdRas,{|x| x[1]+x[2]+x[3] == aRastro[nPosR][1]+aRastro[nPosR][3]+aRastro[nPosR][2]})
				If nPOSX > 0
					aQtdRas[nPOSX][4] -= aRastro[nPosR][9]
					aQtdRas[nPOSX][4] += oBrw1:aCols[nPosR][nPOSQUANT]
				EndIf
				aRastro[nPosR][9] := oBrw1:aCols[n][nPOSQUANT]
			EndIf
		EndIf

		If nPosR <> n	//grava as informacoes de rastreabilidade numa array
			If(nPosR == 0)
				aAdd(aRastro,NGINFRASTRO(cNComb,cPComb,oBrw1:aCols[n][nPOSDATAB],n,oBrw1:aCols[n][nPOSQUANT]))
				nPosRastro := Len(aRastro)
				If nPosRastro > 0
					aAdd(aRastro[nPosRastro],n)
					aAdd(aRastro[nPosRastro],oBrw1:aCols[n][nPOSQUANT])
				EndIf
			Else
				nPosRastro := nPosR
			EndIf

			//delete registro da array
			If !aRastro[nPosRastro][7]
				aDel(aRastro,nPosRastro)
				aSize(aRastro,Len(aRastro) - 1 )
				Return .F.
			EndIf

			//aglutina as qtds dos lotes/localizaçoes iguais
			nPOSX := Ascan(aQtdRas,{|x| x[1]+x[2]+x[3] == aRastro[nPosRastro][1]+aRastro[nPosRastro][3]+aRastro[nPosRastro][2]})
			If nPOSX = 0
				Aadd(aQtdRas,{aRastro[nPosRastro][1],aRastro[nPosRastro][3],aRastro[nPosRastro][2],oBrw1:aCols[nPosRastro][nPOSQUANT]})
			Else
			aQtdRas[nPOSX][4] += oBrw1:aCols[nPosRastro][nPOSQUANT]
			EndIf
			If !NGCHKFRASTO(cPComb,oBrw1:aCols[nPosRastro][nPOSDATAB],aRastro[nPosRastro][2],aRastro[nPosRastro][3],aRastro[nPosRastro][1],aRastro[nPosRastro][4],aRastro[nPosRastro][5],If(nPOSX > 0,aQtdRas[nPOSX][4],oBrw1:aCols[nPosRastro][nPOSQUANT]))
				Return .F.
			EndIf

		Else
			//checa se total por lotes/localizaçoes existe saldo...
			nPOSX := Ascan(aQtdRas,{|x| x[1]+x[2]+x[3] == aRastro[nPosR][1]+aRastro[nPosR][3]+aRastro[nPosR][2]})
			If nPOSX = 0
				nQtdTot := oBrw1:aCols[nPosR][nPOSQUANT]
			Else
			nQtdTot := aQtdRas[nPOSX][4]
			EndIf
			If !NGCHKFRASTO(cPComb,oBrw1:aCols[nPosR][nPOSDATAB],aRastro[nPosR][2],aRastro[nPosR][3],aRastro[nPosR][1],aRastro[nPosR][4],aRastro[nPosR][5],nQtdTot)
				Return .F.
			EndIf
		EndIf
	EndIf

	For nI := 1 To If(nPar == 1, 1, Len(oBrw1:aCols))
		If nPar == 1
			nLinha := n
		Else
			nLinha := nI
		EndIf

		//Valida duplicidade de abastecimento
		If !MNA655HR()
			Return .F.
		EndIf

		//---------------------------------------------------
		//Ponto de Entrada - Validacao Personalizada da Linha
		//---------------------------------------------------
		If lMNTA6565
			If !ExecBlock("MNTA6565",.F.,.F.,{nPar,cPosto,cLoja,cTanque,cCombustiv,oBrw1:aCols,nLinha})
				Return .F.
			EndIf
		EndIf
	Next nI

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT656VUMD
Retorna valor unitario do combustivel, conforme moeda informada.

@param dDtAbas Data do Abastecimento
@param cHrAbas Hora do Abastecimento
@param cCdCom  Codigo do Combustivel
@param cMoeda  Moeda utilizada para conversao

@author Hugo R. Pereira
@since 28/05/2012
@version MP10
@return nValor Valor conforme a moeda repassada
/*/
//---------------------------------------------------------------------
Function MNT656VUMD(dDtAbas, cHrAbas, cCdCom, cMoeda)

	Local nCusto     := 0
	Private cMdCusto := "1"

	nCusto := MNT656VALU(dDtAbas, cHrAbas, cCdCom, cMoeda)

Return {nCusto, cMdCusto}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |MNT656VALU³ Autor ³ Marcos Wagner Junior  ³ Data ³ 17/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Busca o valor unitario do combustivel							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA656                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT656VALU(dDtAbas,cHrAbas,cCdCom, cMoeda)
Local nRecno := 0, nVALUNI := 0
Local cProdCom := Space(Len(SB2->B2_COD))
Local lMMoeda  := NGCADICBASE("TL_MOEDA","A","STL",.F.)

Default cMoeda := ""

If GetNewPar("MV_NGPRSB2","N") == "S"
	cProdCom := NGSEEK('TQI',cPosto+cLoja+cTanque+cTTAComb,1,'TQI->TQI_PRODUT')
	dbSelectArea("SB2")
	dbSetOrder(1)
	If dbSeek(xFilial("SB2")+cProdCom+Space(Len(SB2->B2_COD)-Len(cProdCom))+cTanque)

		If lMMoeda .And. Type("cMdCusto") == "C"
			cMdCusto := "1"
		EndIf

		Return SB2->B2_CM1
	EndIf
Else
	dbSelectArea("TQH")
	dbSetOrder(1)
	dbSeek(xFilial("TQH")+cPosto+cLoja+cCdCom)
	cUltDtH := DTOS(TQH->TQH_DTNEG)+TQH->TQH_HRNEG
	Do While !EoF() .And. xFilial("TQH") == TQH->TQH_FILIAL .And. TQH->TQH_CODPOS == cPosto .And.;
																						 TQH->TQH_LOJA == cLoja .And.;
																						 TQH->TQH_CODCOM == cCdCom

		IF cUltDtH > DTOS(TQH->TQH_DTNEG)+TQH->TQH_HRNEG .Or. DTOS(TQH->TQH_DTNEG)+TQH->TQH_HRNEG > DTOS(dDtAbas)+cHrAbas
		   dbSelectArea("TQH")
		   dbSkip()
		   Loop
		EndIf

		cUltDtH := DTOS(TQH->TQH_DTNEG)+TQH->TQH_HRNEG
		nRecno := Recno()
		dbSelectArea("TQH")
		dbSkip()
	EndDo
EndIf

dbSelectArea("TQH")
If !Empty(nRecno)
	  dbGoTo(nRecno)
	nVALUNI := If(lMMoeda .And. !Empty(cMoeda),xMoeda(TQH->TQH_PRENEG,Val(TQH->TQH_MOEDA),Val(cMoeda),TQH->TQH_DTNEG,TAMSX3("TQH_PRENEG")[2]),TQH->TQH_PRENEG)
	If lMMoeda .And. Empty(cMoeda) .And. Type("cMdCusto") == "C"
		cMdCusto := TQH->TQH_MOEDA
	EndIf
EndIf

Return nVALUNI

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT656CTOT

Checa o contador da bomba

@author Evaldo Cecinscki Jr.
@since 17/10/08
@version MP12
@sample MNTA656
@Return True
/*/
//---------------------------------------------------------------------
Function MNT656CTOT()

	Local cCombTQI := ' '
	Local nCombVld := 0

	If nCombAtu > 0

		dbSelectArea("TQJ")
		dbSetOrder(01)
		If dbSeek(xFilial("TQJ")+cPosto+cLoja+cTanque+cBomba)
			If TQJ->TQJ_LIMCON < nCombAtu
				ApMsgInfo(STR0061) //"Quantidade atual não poderá superar o Limite de Contador da Bomba!"
				Return .F.
			EndIf

			If AliasInDic("TTV")
				//Inserção de NoRound, paliativamente, devido à inconsistência de Framework TOTVS
				nCombTot := NoRound(nCombAtu - nCombAnt,3) //nCombAtu - nCombAnt
				If nCombAtu < nCombAnt
					lGravaTQJ := .T.
					//Cálculo para evitar que a variável nCombTot fique negativa (situação de quebra de contador de bomba)
					nCombTot  := TQJ->TQJ_LIMCON + nCombTot
				EndIf
			Else
				If TQJ->TQJ_MOTIVO == '2' .Or. TQJ->TQJ_MOTIVO == '3'
					If TQJ->TQJ_MOTIVO == '2'
						If nCombAtu < nCombAnt
							lGravaTQJ := .T.
							nCombTot  := TQJ->TQJ_LIMCON - nCombAnt + nCombAtu + 0.01
						EndIf
					ElseIf TQJ->TQJ_MOTIVO == '3'
						lGravaTQJ := .T.
						dbSelectArea("TQJ")
						dbSetOrder(01)
						If dbSeek(xFilial("TQJ")+cPosto+cLoja+cTanque+cBomba)
							//nCombAnt := TQJ->TQJ_CONINI
							If nCombAtu < nCombAnt
								ApMsgInfo(STR0126) //"Quantidade atual deve ser maior que anterior!"
								Return .F.
							EndIf
							nCombTot := nCombAtu - nCombAnt
						EndIf
					EndIf
				Else
					If nCombAtu < nCombAnt
						ApMsgInfo(STR0050) //"Quantidade atual deve ser maior que anterior, ou deverá ser informada uma virada/quebra de contador da bomba!"
						Return .F.
					EndIf
					nCombTot := nCombAtu - nCombAnt
				EndIf
			EndIf
		EndIf

		//Inserção de NoRound, paliativamente, devido à inconsistência de Framework TOTVS
		nCombDif := NoRound( nCombTot - nCombDig, 3 )
		cCombTQI := NGSEEK('TQI',cPosto+cLoja+cTanque+cTTAComb,1,'TQI->TQI_PRODUT')

		If !Empty(cCombTQI) .And. cUsaInt3 == 'S' .And. !lESTNEGA .And. cConEst == 'S'

			If Empty( nCombDif )

				nCombVld := nCombDig

			Else

				nCombVld := nCombDif

			EndIf

			If !NGSALSB2( cCombTQI, cTanque, nCombVld, , , dDataAbast )

				Return .F.
			
			EndIf
		
		EndIf

	Else

		nCombTot  := 0
		nCombDign := 0
		CombDif   := 0

	EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |MNT656CLUB³ Autor ³Marcos Wagner Junior   ³ Data ³ 29/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Checa o contador do Produto.        						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA656                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNT656CLUB()

nLubDif := nLubInf - nLubDig

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT656LUB
Gera O.S. corretiva do Produto

@return
@param  cFrota       , Caracter, Veiculo a ser utilizado para OS de Lubr.
        cServ        , Caracter, Serviço realizado na OS de Lubr.
		cProdLub     , Caracter, Produto utilizado na OS de Lubr.
		nQtdLub      , Numerico, Quantidade do produto lubrificante.
		dDtLub       , Data    , Data de utilização do produto.
		cHrLub       , Caracter, Hora de utilização do produto.
		nPosCont     , Numerico, Posição do contador ao utilizar o produto.
		nX           , Numerico, Numero da linha referente ao aCols.
		cAlmoxarifado, Caracter, Almoxarifado de onde obteu-se o produto.
		_nCusto      , Numerico, Custo gerado com a lubrificação.
		cFil         , Caracter, Filial corrente da STJ para inclusão da OS
		cMoeda       , Caracter, Moeda utilizada no calculo do custo

@sample
MNT656LUB()

@author Evaldo Cecinscki Jr.
@since 20/10/08
@version 1.0
/*/
//---------------------------------------------------------------------
Function MNT656LUB(cFrota,cServ,cProdLub,nQtdLub,dDtLub,cHrLub,nPosCont,nX,cAlmoxarifado,_nCusto, cFil, cMoeda)
	Local lMMoeda  := NGCADICBASE("TL_MOEDA","A","STL",.F.)
	Local _cAlmoxa := ""
	Local cRetOk   := " "

	Default cFil   := xFilial( "STJ" )
	Default cMoeda := "1"

	Private cVerific := If(NGVERIFY("STJ"),"0",0)

	If FunName() == "MNTA656"
		_cAlmoxa := oBrw1:aCols[nX][nPOSALMOX]
	Else
		_cAlmoxa := cAlmoxarifado
	EndIf

	aRetornoOS := NGGERAOS('C',dDtLub,cFrota,cServ,cVerific,'N','N','N',cFil)
	If aRetornoOS[1][1] == 'N'
		MsgStop(aRetornoOS[1][2],STR0037)//"ATENÇÃO"
	Else
	If lRastr
		NGRETINS(aRetornoOS[1][3],"000000",'C'," "," "," ",'0','P',cProdLub,nQtdLub,NGSEEK('SB1',cProdLub,1,'SB1->B1_UM'),;
				"T",STR0051,dDtLub,cHrLub,'F',_cAlmoxa,oBrw1:aCols[nX][nPOSLOTE],; //"Consumo Produto"
				oBrw1:aCols[nX][nPOSSUBLO],oBrw1:aCols[nX][nPOSDTVAL],oBrw1:aCols[nX][nPOSLOCAL])
	Else
		NGRETINS(aRetornoOS[1][3],"000000",'C'," "," "," ",'0','P',cProdLub,nQtdLub,NGSEEK('SB1',cProdLub,1,'SB1->B1_UM'),;
				"T",STR0051,dDtLub,cHrLub,'F',_cAlmoxa,,,,)  //"Consumo Produto"
	EndIf

	dbSelectArea("STJ")
	dbSetOrder(1)
	IF dbSeek(xFilial("STJ")+aRetornoOS[1][3]+"000000")
		RecLock("STJ",.F.)
	STJ->TJ_SEQRELA := '000'
	STJ->TJ_DTORIGI := dDtLub
	STJ->TJ_HORACO1 := cHrLub
	STJ->TJ_POSCONT := nPosCont
	STJ->TJ_USUARIO := If(Len(STJ->TJ_USUARIO) > 15,cUsername,Substr(cUsuario,7,15))
	STJ->TJ_DTMPINI := dDtLub
	STJ->TJ_HOMPINI := cHrLub
	STJ->TJ_DTMPFIM := dDtLub
	STJ->TJ_HOMPFIM := cHrLub
	STJ->TJ_DTMRINI := dDtLub
	STJ->TJ_HOMRINI := cHrLub
	STJ->TJ_DTMRFIM := dDtLub
	STJ->TJ_HOMRFIM := cHrLub
	STJ->TJ_CONTINI := nPosCont
	STJ->TJ_USUAINI := STJ->TJ_USUARIO
	STJ->(MsUnlock())
	EndIf

	//----------------------------------------------------------------------------
	// Deve estar posicionado no SD3 ( Movimentação Interna ), para que usuário
	// possa manipular o registro, este é o objetivo do PE.
	//----------------------------------------------------------------------------
	If cIntMntEst == "S" // Apenas caso esteja integrado com estoque
		dbSelectArea( "SD3" )
		If ExistBlock( "MNT655D3CC" )
			ExecBlock( "MNT655D3CC" , .F. , .F. , { 'RE0' , cFrota , STJ->TJ_CCUSTO , cFil } )
		EndIf
	EndIf

	dbSelectArea("STL")
	dbSetOrder(1)
	dbSeek(xFilial("STL")+aRetornoOS[1][3]+"000000")
	While !EoF() .And. STL->TL_FILIAL == xFilial("STL") .And. STL->TL_ORDEM == aRetornoOS[1][3] .And. STL->TL_PLANO == "000000"
		If STL->TL_CODIGO == cProdLub
		Reclock("STL",.F.)
		STL->TL_USACALE := "N"
		STL->TL_GARANTI := "N"
			If cIntMntEst == 'S'
				STL->TL_NUMSEQ  := SD3->D3_NUMSEQ
				STL->TL_CUSTO   := SD3->D3_CUSTO1
				If lMMoeda
					STL->TL_MOEDA  := "1"
				EndIf
			Else
				STL->TL_CUSTO   := IIF(ValType(_nCusto)=='N',_nCusto,STL->TL_CUSTO)
				If lMMoeda
					STL->TL_MOEDA  := IIF(ValType(_nCusto) == 'N',cMoeda,STL->TL_MOEDA)
			EndIf
			EndIf
			STL->TL_NOTFIS  := cFolha
			STL->TL_LOCAL   := _cAlmoxa
			If nPOSLOTE > 0
				STL->TL_LOTECTL := aCols[nX][nPOSLOTE]
				STL->TL_NUMLOTE := aCols[nX][nPOSSUBLO]
				STL->TL_DTVALID := aCols[nX][nPOSDTVAL]
				STL->TL_LOCALIZ := aCols[nX][nPOSLOCAL]
				STL->TL_NUMSERI := aCols[nX][nPOSNUMSE]
			EndIf
			If NGCADICBASE("TL_FORNEC","A","STL",.F.)
				STL->TL_FORNEC := cPosto
				STL->TL_LOJA   := cLoja
			EndIf
		STL->(MsUnlock())
		EndIf

		dbSkip()
	End

	NGFINAL(STJ->TJ_ORDEM,STJ->TJ_PLANO,STJ->TJ_DTPRINI,STJ->TJ_HOPRINI,;
			STJ->TJ_DTPRFIM,STJ->TJ_HOPRFIM,0,0,;
			cFrota,STJ->TJ_HORACO1,STJ->TJ_HORACO2)

		cRetOk := aRetornoOS[1][3]
	EndIf

Return cRetOk
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |MNT656VLUB³ Autor ³Evaldo Cecinscki Jr.   ³ Data ³ 21/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Checa se os servicos de Produto foram informados           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA656                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT656VLUB()

If !Empty(aCols[n][nPOSQUALU])
	NaoVazio()
EndIf

If M->TQG_ORDENA == "1" .And. Empty(cTroca)
	MsgStop(STR0052,STR0037) //"Para Troca de Produto, deve ser informado o seu respectivo serviço."###"ATENÇÃO"
	M->TQG_ORDENA := " "
	Return .F.
ElseIf M->TQG_ORDENA == "2" .And. Empty(cReposicao)
	MsgStop(STR0053,STR0037) //"Para Reposição de Produto, deve ser informado o seu respectivo serviço."###"ATENÇÃO"
	M->TQG_ORDENA := " "
	Return .F.
EndIf

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |MNT656VIS ³ Autor ³Evaldo Cecinscki Jr.   ³ Data ³ 22/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega os campos na Visualizacao                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA656                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT656VIS()

	Local cDescLub  := ''
	Local lTemLub   := .F.
	Local lTemAbast := .F.
	Local nX        := 0

	Local nI

	MNT656TABO(2)

	If nCombAtu >= nCombAnt .Or. nCombAtu == 0 //Senao foi quebra de contador
		nCombAtu  := 	nCombTot + nCombAnt
	EndIf

	nMarc := nCombAnt

	nCombDig := 0

	cAliasQry := GetNextAlias()

	cQuery := " SELECT TQN_FILIAL, TQN_OSLUBR, TQN_QUANT, TQN_DTABAS, TQN_HRABAS, TQN_FROTA, TQN_PLACA, "
	cQuery += " TQN_HODOM, TQN_NABAST, TQN_POSCO2, TQN_CODMOT"

	If Len(aCamposU) > 0

		For nX:= 1 to Len(aCamposU)
			cQuery += ", " + aCamposU[nX][1]
		Next nX

	EndIf
	
	If lMMoeda

		cQuery += ", TQN_MOEDA"

	EndIf

	cQuery += "   FROM " + RetSqlName("TQN")
	cQuery += "  WHERE TQN_FILIAL 	= " + ValToSql(FwxFilial("TQN"))
	cQuery += "    AND TQN_POSTO	= " + ValToSql(cPosto)
	cQuery += "    AND TQN_LOJA 	= " + ValToSql(cLoja)
	cQuery += "    AND TQN_NOTFIS 	= " + ValToSql(cFolha)
	cQuery += "    AND D_E_L_E_T_ = ' ' "
	cQuery += "  ORDER BY TQN_FILIAL,TQN_POSTO,TQN_LOJA,TQN_DTABAS,TQN_HRABAS"

	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	While (cAliasQry)->( !EoF() )

		nQtdLub  := 0
		cLub	 := Space( TamSX3('B1_COD')[1] )
		cAlmo	 := Space( TamSX3('TL_LOCAL')[1] )
		cDescLub := ''
		cTR      := " "

		If !Empty((cAliasQry)->TQN_OSLUBR)

			dbSelectArea("STJ")
			dbSetOrder(1)
			If dbSeek( xFilial("STJ") + (cAliasQry)->TQN_OSLUBR + "000000" )
				If STJ->TJ_SERVICO == cTroca
					cTR := "1"
				ElseIf STJ->TJ_SERVICO == cReposicao
					cTR := "2"
				EndIf
			EndIf

			dbSelectArea("STL")
			dbSetOrder(1)
			If dbSeek( xFilial("STL") + (cAliasQry)->TQN_OSLUBR + "000000" )
				
				cLub     := STL->TL_CODIGO
				cAlmo    := STL->TL_LOCAL
			   	nQtdLub  := STL->TL_QUANTID
				cDescLub := NgSeek( 'SB1', STL->TL_CODIGO, 1, 'B1_DESC' )

			EndIf

			lTemLub := .T.

		EndIf

		nCombDig += (cAliasQry)->TQN_QUANT
		nMarc += (cAliasQry)->TQN_QUANT

		aAdd(aCols,Array(Len(aHeader)+1))
		nPosTQN := Len(aCols)

		aCols[nPosTQN][nPOSDATAB] := StoD((cAliasQry)->TQN_DTABAS)
		aCols[nPosTQN][nPOSHORAB] := (cAliasQry)->TQN_HRABAS
		aCols[nPosTQN][nPOSFROTA] := (cAliasQry)->TQN_FROTA
		aCols[nPosTQN][nPOSPLACA] := (cAliasQry)->TQN_PLACA

		If Empty( (cAliasQry)->TQN_PLACA )

			aCols[nPosTQN,nPosDesFro] := NgSeek( 'ST9', (cAliasQry)->TQN_FROTA, 1 , 'T9_NOME' )

		Else

			aCols[nPosTQN,nPosDesFro] := Posicione( 'ST9', 14, (cAliasQry)->TQN_PLACA, 'T9_NOME' )

		EndIf

		aCols[nPosTQN][nPOSHODOM] := (cAliasQry)->TQN_HODOM
		aCols[nPosTQN][nPOSNABAS] := (cAliasQry)->TQN_NABAST

		If lSegCont
			aCols[nPosTQN][nPOSCONT2] := (cAliasQry)->TQN_POSCO2
		EndIf

		//Grava no aCols os campos de usuario
		If Len(aCamposU) > 0
			For nX:= 1 to Len(aCamposU)
				If aHeader[aCamposU[nX][2]][10] == 'R'
					//Tratativa realizada para busca de campos de usuários quando são do Tipo MEMO, pois o mesmo não é trazido no resultado da Query.
					If aHeader[aCamposU[nX][2]][8] == "M"
						aCols[nPosTQN][aCamposU[nX][2]] := Posicione("TQN",1,(cAliasQry)->TQN_FILIAL + (cAliasQry)->TQN_FROTA + (cAliasQry)->TQN_DTABAS + (cAliasQry)->TQN_HRABAS,aCamposU[nX][1])
					ElseIf aHeader[aCamposU[nX][2]][8] == "D"
						aCols[nPosTQN][aCamposU[nX][2]] := StoD( (cAliasQry)->&(aCamposU[nX][1]) )
					Else
						aCols[nPosTQN][aCamposU[nX][2]] := (cAliasQry)->&(aCamposU[nX][1])
					EndIf
				Else
					aCols[nPosTQN][aCamposU[nX][2]] := CriaVar(aCamposU[nX][1],.T.)
				EndIf
			Next nX
		EndIf

		aCols[nPosTQN][nPOSQUANT] := (cAliasQry)->TQN_QUANT
		aCols[nPosTQN][nPOSLUBRI] := cLub
		aCols[nPosTQN,nPosDesLub] := cDescLub
		aCols[nPosTQN][nPOSQUALU] := nQtdLub
		aCols[nPosTQN][nPOSTRREP] := cTR
		aCols[nPosTQN][nPOSMOTOR] := (cAliasQry)->TQN_CODMOT
		aCols[nPosTQN,nPosNomMot] := NgSeek( 'DA4', (cAliasQry)->TQN_CODMOT, 1, 'DA4_NOME' )

		If lRastr
			aCols[nPosTQN][nPOSALMOX] := Space(Len(STL->TL_LOCAL))
			aCols[nPosTQN][nPOSLOTE]  := Space(Len(STL->TL_LOTECTL))
			aCols[nPosTQN][nPOSSUBLO] := Space(Len(STL->TL_NUMLOTE))
			aCols[nPosTQN][nPOSDTVAL] := CtoD("  /  /  ")
			aCols[nPosTQN][nPOSLOCAL] := Space(Len(STL->TL_LOCALIZ))
			aCols[nPosTQN][nPOSNUMSE] := Space(Len(STL->TL_NUMSERI))
		Else
			aCols[nPosTQN][nPOSALMOX] := cAlmo
		EndIf

		aCols[nPosTQN][nPOSCUSTO] := 0
		aCols[nPosTQN][nPOSMARCA] := nMarc

		If nPOSMOEDA > 0
			aCols[nPosTQN][nPOSMOEDA] := (cAliasQry)->TQN_MOEDA
		EndIf

		aTail(aCols[nPosTQN]) := .F.

		lTemAbast := .T.

		dbSelectArea(cAliasQry)
		dbSkip()
	EndDo

	(cAliasQry)->( dbCloseArea() )


	nCombDig += nDigiTTH
	nCombDif := nCombTot - nCombDig

	cAliasQry := GetNextAlias()

	cQuery := " SELECT TL_CODIGO, TL_DTINICI, TL_HOINICI, TL_QUANTID, TL_LOCAL, TL_LOTECTL, TL_NUMLOTE, TL_DTVALID,"
	cQuery += " TL_LOCALIZ, TL_NUMSERI, TL_CUSTO, TJ_SERVICO, TJ_DTMPFIM, TJ_HOMPFIM, TJ_CODBEM, TJ_POSCONT, TJ_POSCON2 "
	
	If lMMoeda
		cQuery += ", TL_MOEDA "
	EndIf

	cQuery += "FROM " + RetSqlName("STL") + " STL, "  + RetSqlName("STJ") + " STJ "
	cQuery += " WHERE "

	If NGCADICBASE("TL_FORNEC","A","STL",.F.)
		cQuery += " STL.TL_FORNEC = " + ValToSql(cPosto)
		cQuery += " AND STL.TL_LOJA   = " + ValToSql(cLoja)
		cQuery += " AND STL.TL_NOTFIS = " + ValToSql(cFolha) + " AND"
	EndIf

	cQuery += " STJ.TJ_ORDEM  = STL.TL_ORDEM "
	cQuery += " AND   STJ.TJ_PLANO  = STL.TL_PLANO "
	cQuery += " AND   STJ.TJ_TERMINO = 'S' "
	cQuery += " AND   STJ.D_E_L_E_T_ = ' ' AND STJ.TJ_FILIAL = "+ValToSql(FwxFilial("STJ"))
	cQuery += " AND   STL.D_E_L_E_T_ = ' ' AND STL.TL_FILIAL = "+ValToSql(FwxFilial("STL"))
	cQuery += " ORDER BY STL.TL_FILIAL, STL.TL_DTINICI, STL.TL_HOINICI "

	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	If (cAliasQry)->( !EoF() )
		While (cAliasQry)->( !EoF() )

			cTR := " "

			If (cAliasQry)->TJ_SERVICO == cTroca
				cTR := "1"
			ElseIf (cAliasQry)->TJ_SERVICO == cReposicao
				cTR := "2"
			Else
				dbSelectArea(cAliasQry)
				dbSkip()
				Loop
			EndIf

			If ((cAliasQry)->TJ_DTMPFIM + (cAliasQry)->TJ_HOMPFIM) > DtoS(TTA->TTA_DTABAS) + TTA->TTA_HRABAS
				dbSelectArea(cAliasQry)
				dbSkip()
				Loop
			EndIf

			nPos := (aScan(aCOLS,{|x| DtoS(x[nPOSDATAB])+x[nPOSHORAB]+x[nPOSFROTA] == (cAliasQry)->TL_DTINICI+(cAliasQry)->TL_HOINICI+(cAliasQry)->TJ_CODBEM }))

			If nPos == 0
				
				aAdd(aCols,Array(Len(aHeader)+1))
				
				nPosTQN := Len(aCols)

				aCols[nPosTQN][nPOSDATAB] := StoD((cAliasQry)->TL_DTINICI)
				aCols[nPosTQN][nPOSHORAB] := (cAliasQry)->TL_HOINICI
				aCols[nPosTQN][nPOSFROTA] := (cAliasQry)->TJ_CODBEM
				aCols[nPosTQN][nPOSPLACA] := NGSEEK( 'ST9', (cAliasQry)->TJ_CODBEM, 1, 'ST9->T9_PLACA')
				aCols[nPosTQN,nPosDesFro] := NgSeek( 'ST9', (cAliasQry)->TJ_CODBEM, 1, 'T9_NOME' )
				aCols[nPosTQN][nPOSHODOM] := (cAliasQry)->TJ_POSCONT

				If lSegCont
					aCols[nPosTQN][nPOSCONT2] := (cAliasQry)->TJ_POSCON2
				EndIf

				aCols[nPosTQN][nPOSQUANT] := 0
				aCols[nPosTQN][nPOSLUBRI] := (cAliasQry)->TL_CODIGO
				aCols[nPosTQN,nPosDesLub] := NgSeek( 'SB1', (cAliasQry)->TL_CODIGO, 1, 'B1_DESC' )
				aCols[nPosTQN][nPOSQUALU] := (cAliasQry)->TL_QUANTID
				aCols[nPosTQN][nPOSTRREP] := cTR
				aCols[nPosTQN][nPOSMOTOR] := Space(Len(TQN->TQN_CODMOT))
				aCols[nPosTQN][nPOSALMOX] := (cAliasQry)->TL_LOCAL

				If lRastr
					aCols[nPosTQN][nPOSLOTE]  := (cAliasQry)->TL_LOTECTL
					aCols[nPosTQN][nPOSSUBLO] := (cAliasQry)->TL_NUMLOTE
					aCols[nPosTQN][nPOSDTVAL] := StoD((cAliasQry)->TL_DTVALID)
					aCols[nPosTQN][nPOSLOCAL] := (cAliasQry)->TL_LOCALIZ
					aCols[nPosTQN][nPOSNUMSE] := (cAliasQry)->TL_NUMSERI
				EndIf

				aCols[nPosTQN][nPOSCUSTO] := (cAliasQry)->TL_CUSTO
				aCols[nPosTQN][nPOSMARCA] := 0

				If nPOSMOEDA > 0
					aCols[nPosTQN][nPOSMOEDA] := (cAliasQry)->TL_MOEDA
				EndIf

				aTail(aCols[nPosTQN]) := .F.

			Else
				// Continua com o contador encontrado na TQN (Contador 1 e 2)

				aCols[nPos][nPOSLUBRI] := (cAliasQry)->TL_CODIGO
				aCols[nPos,nPosDesLub] := NgSeek( 'SB1', (cAliasQry)->TL_CODIGO, 1, 'B1_DESC' )
				aCols[nPos][nPOSQUALU] := (cAliasQry)->TL_QUANTID
				aCols[nPos][nPOSTRREP] := cTR
				aCols[nPos][nPOSALMOX] := (cAliasQry)->TL_LOCAL

				If lRastr
					aCols[nPos][nPOSLOTE]  := (cAliasQry)->TL_LOTECTL
					aCols[nPos][nPOSSUBLO] := (cAliasQry)->TL_NUMLOTE
					aCols[nPos][nPOSDTVAL] := StoD((cAliasQry)->TL_DTVALID)
					aCols[nPos][nPOSLOCAL] := (cAliasQry)->TL_LOCALIZ
					aCols[nPos][nPOSNUMSE] := (cAliasQry)->TL_NUMSERI
				EndIf

				aCols[nPos][nPOSCUSTO] := (cAliasQry)->TL_CUSTO

				If nPOSMOEDA > 0
					aCols[nPosTQN][nPOSMOEDA] := (cAliasQry)->TL_MOEDA
				EndIf

			EndIf

	   		dbSelectArea(cAliasQry)
			dbSkip()
		EndDo

		aSort( aCols,,, { |x,y| DTOS(x[1])+x[2]+x[3] < DTOS(y[1])+y[2]+y[3] } )
		nMarc := nCombAnt

		For nI := 1 to Len(aCols)
			nMarc += aCols[nI][nPOSQUANT]
			aCols[nI][nPOSMARCA] := nMarc
		Next nI

		lTemLub := .T.
	EndIf

	(cAliasQry)->( dbCloseArea() )

	cDesTroca := NGSEEK('ST4',cTroca,1,'ST4->T4_NOME')
	cDesRepo  := NGSEEK('ST4',cReposicao,1,'ST4->T4_NOME')

	If lTemLub .And. lTemAbast

		nLanca := STR0006 //"Abastecimento+Produto"

		ElseIf lTemLub .And. !lTemAbast
		nLanca := STR0018 //"Produto"
			lTpLub		:= .T.
		TIPOACOM := .F.
		TIPOACOM2 := .F.
	EndIf

	If !lTpLub
		MNT656TABO(2)
	EndIf

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |MNT656LAN ³ Autor ³Evaldo Cecinscki Jr.   ³ Data ³ 22/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Checa o tipo de lancamento para habilitar/desabilitar campo³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA656                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT656LAN()
Local lRet := .F.

If (nLanca == STR0006 .Or. nLanca == STR0018) .And. Inclui //"Abastecimento+Produto"###"Produto"
	lRet := .T.
	lTrava656 := .T.
EndIf

If ExistBlock("MNTA6563")
	lRet := ExecBlock("MNTA6563",.F.,.F.)
EndIf

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} MNT656COM
Valida se o combustivel do tanque do posto eh = ao do bem

@param oGetBrw, Objeto, Objeto de montagem da tela.
@param nPos, Numérico, Posicionamento do campo.

@author Evaldo Cevinscki Jr
@since 22/10/08

@return lRet, Lógico, Retorna verdadeiro caso não entre em nenhuma situação.
/*/
//-----------------------------------------------------------------------
Function MNT656COM(oGetBrw,nPos)

	Local aArea := {}
	Local lRet  := .T.
	Local cFilB
	Local cPlac
	Local cFilAtuSt9 := xFilial("ST9")
	Local nQuantSoma := 0
	Local nI
	Local lDtvSgCnt  := NGCADICBASE("TPE_SITUAC","A","TPE",.F.) //Indica se permite desativar segundo contador

	Default oGetBrw := oBrw1
	Default nPos    := 0

	If nPos > 0
		n := nPos
	EndIf

	Store '' To cFilB, cPlac

	nQuant    := oGetBrw:aCols[n, nPosQuant]

	If FunName() == "MNTA656" .And. ReadVar() == "M->TQN_PLACA"
		cFrota := M->TQN_FROTA

		cPlac  := M->TQN_PLACA
	Else
		cFrota := oGetBrw:aCols[n, nPosFrota]
		cPlac  := oGetBrw:aCols[n, nPOSPlaca]

	EndIf

	//-------------------------------------------------------------------------------------
	// Controle de semáforo para o código do bem
	// Faz lock do código do bem, para que seja possível apenas um reporte de combustível
	// para o mesmo bem por vez, esse ajuste foi feito para controlar a integridade de
	// registro do contador, pois ocorria inconsistência na base quando dois usuários
	// confirmavam a rotina ao mesmo tempo caso fosse abastecimento para o mesmo bem
	//-------------------------------------------------------------------------------------
	If lRet .And. FunName() == "MNTA656" .And. ReadVar() == "M->TQN_FROTA"
		If !LockByName( "MNTA656" + M->TQN_FROTA ) // STR0168
			ShowHelpDlg(STR0037,{STR0168 + M->TQN_FROTA},3,; // "Já existe um reporte de abastecimento sendo feito para o veículo ";
				{STR0169},3) // "Aguarde um instante e tente novamente."
			Return .F.
		Else
			// Adiciona no array para fazer a liberação dos códigos quando sair da rotina
			If aScan( aBensLocks,{ |x| AllTrim( x ) == AllTrim( "MNTA656" + M->TQN_FROTA ) } ) == 0
				aAdd( aBensLocks,"MNTA656" + M->TQN_FROTA )
			EndIf
		EndIf
	EndIf

	cCodCom := NGSEEK('TQI',cPosto+cLoja+cTanque+cTTAComb,1,'TQI_CODCOM')

	If (nLanca == STR0006 .Or. nLanca == STR0018) //"Abastecimento+Produto"###"Produto"
		If !Empty(cPlac)
			dbSelectArea("ST9")
			dbSetOrder(14)
			If dbSeek(cPlac + "A")
				If xFilial("ST9",cFilAtuSt9) <> ST9->T9_FILIAL .And. !Empty(ST9->T9_FILIAL)
					MsgStop(STR0130+Chr(13)+Chr(10)+; //"Para Folha com opção de lançamento de Produtos somente poderão ser digitados veículos da filial em uso."
					STR0132+ST9->T9_FILIAL+Chr(13)+Chr(10)+; //"Filial do Veículo: "
					STR0133+cFilAnt) //"Filial Em Uso: "
					lRet := .F.
				EndIf
			EndIf
		Else
			dbSelectArea("ST9")
			dbSetOrder(1)
			If dbSeek(xFilial("ST9") + If(ReadVar()=='M->TQN_FROTA',M->TQN_FROTA,cFrota))
				While !EoF() .And. ST9->T9_CODBEM == If(ReadVar()=='M->TQN_FROTA',M->TQN_FROTA,cFrota)
					If xFilial("ST9",cFilAtuSt9) <> ST9->T9_FILIAL .And. !Empty(ST9->T9_FILIAL)

						lRet := .F.
					Else
						lRet := .T.
						Exit
					EndIf

					dbSelectarea("ST9")
					dbSkip()
				End
				If !lRet
					MsgStop(STR0130+Chr(13)+Chr(10)+; //"Para Folha com opção de lançamento de Produtos somente poderão ser digitados veículos da filial em uso."
						STR0132+ST9->T9_FILIAL+Chr(13)+Chr(10)+; //"Filial do Veículo: "
						STR0133+cFilAnt) //"Filial Em Uso: "
				EndIf
			EndIf
		EndIf
	EndIf

	If lRet .And. !MNTA656CAP()
		lRet := .F.
	EndIf

	If FunName() == "MNTA656"
		nPos := aScan(aCOLS,{|x| DtoS(x[nPOSDATAB])+x[nPOSHORAB]+x[nPOSHORAB] == DtoS(aCols[n][nPOSDATAB])+aCols[n][nPOSHORAB]+M->TQN_FROTA })
	Else
			nPos := aScan(oGetBrw:aCols, {|x| x[nPosFrota] + x[nPosHoraB] == M->TQN_FROTA + oGetBrw:aCols[n, nPosHoraB] })
	EndIf

	If lRet .And. nPos > 0 .And. nPos != n .And. !aCols[nPos][Len(aCols[nPos])]
		MsgStop(STR0055)  //"Já existe um lançamento para esse bem com mesma data e hora!."
		lRet := .F.
	EndIf

	If lRet .And. FunName() == "MNTA656"
		If Altera .And. M->TQN_FROTA != aCols[n][nPOSFROTA] .And. !Empty(aCols[n][nPOSLUBRI])
			MsgStop(STR0062) //"Bem não poderá ser alterado, pois o abastecimento relacionado possui O.S. de Lubrificação"
			lRet := .F.
		EndIf
	EndIf

	nCombDig := 0
	For nI := 1 To Len(aCols)
		If !aCols[nI][Len(aCols[nI])]
			nCombDig += aCols[nI][nPOSQUANT]
		EndIf
	Next nI

	If M->TQN_FROTA != cFrota .And. Inclui .And. !Empty(cFrota) .And. nCombDig > 0
		nCombDif := nCombTot - nCombDig

		oGetBrw:aCols[n, nPosHodom] := 0

		If FunName() == "MNTA656" .And. lSegCont
			oGetBrw:aCols[n, nPosCont2] := 0
		EndIf
	EndIf

	If Altera

		If M->TQN_FROTA != aCols[n][nPOSFROTA] .And. !Empty(aCols[n][nPOSFROTA])

			For nI := 1 to Len(aCols656)

				nQuantSoma += aCols656[nI][nPOSQUANT]

			Next

			If nQuantSoma != nCombTot .And. nCombDig > 0
				nCombDig -= aCols[n][nPOSQUANT]
				nCombDif := nCombDig - aCols[n][nPOSQUANT]
			EndIf

			If FunName() == "MNTA656" .And. lSegCont
				oGetBrw:aCols[n, nPosCont2] := 0
			EndIf
		EndIf

		nCombDig += fLoadTTHC()
	EndIf

	//ponto de entrada para carregar variaveis
	If ExistBlock("MNTA6562")
			oGetBrw:aCols[n][nPOSMOTOR] := ExecBlock("MNTA6562", .F. , .F. )
			M->TQN_CODMOT := oGetBrw:aCols[n][nPOSMOTOR]
		lRefresh := .T.
	EndIf

	aArea := GetArea()
	If NGSX2MODO("ST9") == "E" .And. !(ReadVar() == "M->TQN_PLACA")
		dbSelectArea("ST9")
		dbSetOrder(16)
		If dbSeek(If(ReadVar()=='M->TQN_FROTA',M->TQN_FROTA,cFrota)) .And. cPlac <> ST9->T9_PLACA
			If ST9->T9_FILIAL <> cFilAnt .And. !Empty(ST9->T9_FILIAL)
				cFilB := ST9->T9_FILIAL
			Else
				If NGSX2MODO("ST9") == NGSX2MODO("TPE")
					cFilB := xFilial("ST9")
				Else
					cFilB := xFilial("TPE")
				EndIf
			EndIf
		Else
			dbSelectArea("ST9")
			dbSetOrder(14)
			If dbSeek(If(ReadVar()=='M->TQN_PLACA',M->TQN_PLACA,cPlac))
				If ST9->T9_FILIAL <> cFilAnt .And. !Empty(ST9->T9_FILIAL)
					cFilB := ST9->T9_FILIAL
				Else
					If NGSX2MODO("ST9") == NGSX2MODO("TPE")
						cFilB := xFilial("ST9")
					Else
						cFilB := xFilial("TPE")
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		dbSelectArea("ST9")
		dbSetOrder(14)
		If dbSeek(If(ReadVar()=='M->TQN_PLACA',M->TQN_PLACA,cPlac))
			If ST9->T9_FILIAL <> cFilAnt .And. !Empty(ST9->T9_FILIAL)
				cFilB := ST9->T9_FILIAL
			Else
				If NGSX2MODO("ST9") == NGSX2MODO("TPE")
					cFilB := xFilial("ST9")
				Else
					cFilB := xFilial("TPE")
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aArea)
	//FindFunction remover na release GetRPORelease() >= '12.1.027'
	If FindFunction("MNTCont2")
		TipoAcom2 := MNTCont2(cFilB, If(ReadVar()=='M->TQN_FROTA',M->TQN_FROTA,cFrota))
	Else
		dbSelectArea("TPE")
		dbSetOrder(1)
		If dbSeek(xFilial("TPE",cFilB)+If(ReadVar()=='M->TQN_FROTA',M->TQN_FROTA,cFrota))
			TipoAcom2 := IIf(lDtvSgCnt, TPE->TPE_SITUAC == "1", .T.)
		Else
			TIPOACOM2 := .F.
		EndIf
	EndIf

	If FunName() == "MNTA656"
		oCombDig:Refresh()
		oCombDif:Refresh()
			oGetBrw:oBrowse:Refresh()
	EndIf

	// Caso a validação do campo tenha retornado falso, então libera o código que havia lockado
	If !lRet .And. FunName() == "MNTA656" .And. ReadVar() == "M->TQN_FROTA"
		UnLockByName( "MNTA656" + M->TQN_FROTA )
	EndIf

Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |C         ³ Autor ³Evaldo Cecinscki Jr.   ³ Data ³ 22/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica a resolucao do monitor e o tema p/ montar tela    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA656                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function C(nTam)
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
nTamRet := nTam

If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
	nTamRet := nTam * 0.8
ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
	nTamRet := nTam * 1
Else	//Resolucao 1024x768 e acima
	nTamRet := nTam * 1.28
EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para tema "Flat"³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If "P10" $ oApp:cVersion
	If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
		nTamRet := nTam * 0.9
	EndIf
EndIf

Return Int(nTamRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTA656AUT³ Autor ³ Marcos Wagner Junior  ³ Data ³27/10/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa para calcular a autonomia do veiculo.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaMNT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametro³cBem  = Bem para verificar contador;                        ³±±
±±³          ³dData = Data do Contador;                                   ³±±
±±³          ³cHora = Hora Contador;                                      ³±±
±±³          ³nPosCont = Posicao do contador                              ³±±
±±³          ³lGetVar = .T. retorna .T. ou .F.                            ³±±
±±³          ³          .F. retorna array                                 ³±±
±±³          ³cCombus = Codigo do Combustivel                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTA656AUT(cBem, dData, cHora, nPosCont, lGetVar, cCombus, oGetBrw, cTipoCom)

	Local nKmA      := 0
	Local nKmB      := 0
	Local aKmsR     := {}
	Local aVETRE    := {}
	Local cMensag   := " "
	Local lReturn   := .T.
	Local aArea     := GetArea()
	Local lMsg      := .F.
	Local lMsgAuton := .F.
	Local nPercAuto := IIF(Empty(GetNewPar("MV_NGPRAUT"," ")),0,GetNewPar("MV_NGPRAUT"," "))
	Local cComb     := If(cCombus == Nil," ",cCombus)
	Local nI
	Local cMsgAuto  := ''
	Local lBloqAut  := AllTrim(GetNewPar("MV_NGBLQAU","N")) == "1"
	Local cChaveTT8	:= ""
	Local nOrder

	Default oGetBrw  := oBrw1
	Default cTipoCom := "1"

	aCols656 := aClone(oGetBrw:aCols)
	cData    := SubStr(DTOS(dData),7,2)+"/"+SubStr(DTOS(dData),5,2)+"/"+SubStr(DTOS(dData),3,2)
	aVETRE   := {.T.,cMensag}
	cBem     := cBem+(Space(Len(ST9->T9_CODBEM) - Len(cBem)))

	dbSelectArea("SIX")
	dbSetOrder(1)
	If dbSeek("ST9G")
		dbSelectArea("ST9")
		dbSetOrder(16)
		If dbSeek(cBem+"A")
			If FieldPos('T9_MEDIA') > 0 .And. FieldPos('T9_CAPMAX') > 0

				aKmsR    := NGRETSTP(ST9->T9_FILIAL,cBem,DTOS(dData),cHora)
				aColsSTP := {}
				For nI := 1 to Len(aCols656)
					If !aCols656[n][Len(aCols656[n])]
						Aadd(aColsSTP,aCols656[nI])
					EndIf
				Next

				If Len(aColsSTP) > 1
					If FunName() == "MNTA656"
						aSort( aColsSTP,,, { |x,y| x[nPOSFROTA]+DTOS(x[nPOSDATAB])+x[nPOSHORAB] < y[nPOSFROTA]+DTOS(y[nPOSDATAB])+y[nPOSHORAB] } )
					Else
						aSort( aColsSTP,,, { |x,y| x[nPOSFROTA]+x[nPOSHORAB] < y[nPOSFROTA]+y[nPOSHORAB] } )
					EndIf
					For nI := 1 to Len(aColsSTP)
						If FunName() == "MNTA656"
							_dData := aColsSTP[nI][nPOSDATAB]
							_dDataCorr := aCols656[n][nPOSDATAB]
						Else
							_dData := dDataAbast
							_dDataCorr := dDataAbast
						EndIf
						If DTOS(_dData)+aColsSTP[nI][nPOSHORAB] <= DTOS(_dDataCorr)+aCols656[n][nPOSHORAB] .And.;
								aColsSTP[nI][nPOSFROTA] == aCols656[n][nPOSFROTA] .And. !aCols656[n][Len(aCols656[n])] .And.; //Nao deletado
							aColsSTP[nI] != aCols656[n]
							If DTOS(_dData)+aColsSTP[nI][nPOSHORAB] >= DTOS(aKmsR[9])+aKmsR[10]
								aKmsR[1]  := aColsSTP[nI][nPOSHODOM]
								aKmsR[9]  := _dData
								aKmsR[10] := aColsSTP[nI][nPOSHORAB]
							EndIf
						EndIf
					Next
				EndIf

				If AliasInDic("TT8")

					cChaveTT8	:= ST9->T9_FILIAL+ST9->T9_CODBEM+cTipoCom+If(!Empty(cComb),cComb,"")
					nOrder		:= 2

					dbSelectArea("TT8")
					dbSetOrder(nOrder)
					If dbSeek(cChaveTT8)
						If TT8->TT8_MEDIA > 0 .And. TT8->TT8_CAPMAX > 0
							nKmB := TT8->TT8_MEDIA * TT8->TT8_CAPMAX
						EndIf
					Else
						If ST9->T9_MEDIA > 0 .And. ST9->T9_CAPMAX > 0
							nKmB := ST9->T9_MEDIA * ST9->T9_CAPMAX
						EndIf
					EndIf
				Else
					If ST9->T9_MEDIA > 0 .And. ST9->T9_CAPMAX > 0
						nKmB := ST9->T9_MEDIA * ST9->T9_CAPMAX
					EndIf
				EndIf
				If nKmB > 0

					nKmA := nPosCont - aKmsR[1]
					If nKmA >= (nKmB-(nKmB*(nPercAuto/100))) .And. nKmA <= (nKmB+(nKmB*(nPercAuto/100))) .And. nPercAuto != 0
						lMsgAuton := .T.
					EndIf
					If nKmA > nKmB  .And. aKmsR[1] <> 0
						If !aKmsR[8] .And. lGetVar .And. FunName() $ "MNTA656"
							If MsgYesNo(STR0063,STR0037) //"Essa posição do contador superou a autonomia, porém é o primeiro lançamento de contador. Confirma?"###"ATENÇÃO"
								lMsg := .T.
							EndIf
						EndIf
						If !lMsg
							If lMsgAuton
								cMensag:= STR0064+Chr(13)+; //"Essa posição do contador superou a autonomia do veículo."
								STR0065+"("+AllTrim(Str(nPercAuto))+"%)."+Chr(13)+; //"Entretanto está dentro do percentual tolerável "
								STR0066+Chr(10)+Chr(10)+; //"Deseja confirmar?"
								STR0067+".........: "+AllTrim((cBem))+Chr(10)+; //"Veículo"
								STR0002+"..............: "+(cData)+Chr(13)+; //"Data"
								STR0003+"..............: "+(cHora)+Chr(13)+; //"Hora"
								STR0026+".......: "+AllTrim(Str(nPosCont))+Chr(10)+Chr(10)+; //"Contador"
								AllTrim(STR0068)+' '+AllTrim(Str(nKmA))+Chr(13)+; //"Km Percorrido:   "
								STR0069+"......:"+' '+AllTrim(Str(nKmB))+Chr(13)+; //"Autonomia"
								STR0070+AllTrim(Str((nKmB+(nKmB*(nPercAuto/100)))))+Chr(13) //"Aut. Permitida : "
							Else
								If !lBloqAut
									cMsgAuto := STR0066+Chr(10)+Chr(10) //"Deseja confirmar?"
								EndIf
								cMensag:= STR0064+Chr(13)+; //"Essa posição do contador superou a autonomia do veículo."
								cMsgAuto+;
									STR0067+".........: "+AllTrim((cBem))+Chr(10)+; //"Veículo"
								STR0002+"..............: "+(cData)+Chr(13)+; //"Data"
								STR0003+"..............: "+(cHora)+Chr(13)+; //"Hora"
								STR0026+".......: "+AllTrim(Str(nPosCont))+Chr(10)+Chr(10)+; //"Contador"
								AllTrim(STR0068)+' '+AllTrim(Str(nKmA))+Chr(13)+; //"Km Percorrido:   "
								STR0069+"......:"+' '+AllTrim(Str(nKmB)) //"Autonomia"
							EndIf
							aVETRE := {.F.,cMensag} //Return .F.
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

		If lGETVAR
			If !aVETRE[1]
				lLimiteAut := .F.
				If (!lBloqAut .And. !lMsgAuton) .Or. lMsgAuton
					If !MsgYesNo(aVETRE[2],STR0037) //"ATENÇÃO"
						lRETURN := .F.
					EndIf
				Else
					MsgInfo(aVETRE[2],STR0037) //"ATENÇÃO"
					lRETURN := .F.
				EndIf
			EndIf
			RestArea(aArea)
			Return lRETURN
		EndIf
	EndIf
	RestArea(aArea)

Return If(lGetVar,lReturn,aVETRE)

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA656DEL
Função que irá deletar a Folha de Abastecimento

@param   cAlias, Caracter, Tabela do registro.
@param   nRecno, Numérico, Numeração do registro em base.
@param   nOpcx , Numérico, Operação realizada (5-deleção).
@param   nProgram, Numérico, 1 - Rotina MNTA656
							 2 - Rotina MNTA681
@param  cFilProc, Caracter, Informa qual filial fará as validaçoes
@author  Marcos Wagner Junior
@since   29/10/08
@return  .T.
@version P12
/*/
//-------------------------------------------------------------------
 Function MNTA656DEL(cAlias,nRecno,nOpcx,nProgram,cFilProc)

	Local lRet       := .T.
	Local cMensag    := STR0074+Chr(13)+Chr(10) //"Operação não permitida. Para exclusão da Folha deve-se:"
	Local lExitTQN   := .F.
	Local aRetDtPar  := NgDtAbas()
	Local i          := 0
	Local aEMPFIL    := {}
	Local dDtBlqMov  := SuperGetMV( "MV_DBLQMOV",.F.,STOD("") ) //data de bloqueio de movimentações no estoque.
	Local aValAbast  := {}
	Local lPrimeiro  := .T.
	Local cOrdens    := ""
	Local cAlsTQN    := GetNextAlias()

	Default nProgram := 1
	Default cFilProc := xFilial("ST9")

	Private cFiliST9 := cFilProc	//Variável utilizada em chamadas de função do MNTA655

	cMDataHora := DTOS(TTA->TTA_DTABAS)+TTA->TTA_HRABAS
	cAliasQry  := GetNextAlias()
	cQuery     := " SELECT TTA_DTABAS, TTA_HRABAS "
	cQuery     += "   FROM " + RetSqlName("TTA")
	cQuery     += "  WHERE TTA_FILIAL = '" + TTA->TTA_FILIAL + "'"
	cQuery     += "    AND TTA_POSTO  = '" + TTA->TTA_POSTO  + "'"
	cQuery     += "    AND TTA_LOJA   = '" + TTA->TTA_LOJA   + "'"
	cQuery     += "    AND TTA_TANQUE = '" + TTA->TTA_TANQUE + "'"
	cQuery     += "    AND TTA_BOMBA  = '" + TTA->TTA_BOMBA  + "'"
	cQuery     += "    AND D_E_L_E_T_ = ' ' "
	cQuery     := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	dbGoTop()
	While !EoF()
		If cMDataHora < (cAliasQry)->TTA_DTABAS+(cAliasQry)->TTA_HRABAS
			cMensag := STR0125 //"Deleção permitida apenas para a última folha lançada."
			MsgInfo(cMensag,STR0078) //"NAO CONFORMIDADE"
			(cAliasQry)->(dbCloseArea())
			Return .F.
		EndIf
		dbSkip()
	End

	aAdd(aEMPFIL,SM0->M0_CODIGO)
	For i:=1 to Len(aEMPFIL)
		cAliasQry := GetNextAlias()
		cQuery := " SELECT TQN_FILIAL, TQN_DTABAS, TQN_HRABAS, TQN_FROTA, TQN_DTCON "
		cQuery += "   FROM " + RetSqlName("TQN")
		cQuery += "   WHERE TQN_FILIAL = '"+FwxFilial("TQN")+"'"
		cQuery += "    AND TQN_POSTO  = '"+TTA->TTA_POSTO+"'"
		cQuery += "    AND TQN_LOJA   = '"+TTA->TTA_LOJA+"'"
		cQuery += "    AND TQN_NOTFIS = '"+TTA->TTA_FOLHA+"'"
		cQuery += "    AND TQN_TANQUE = '"+TTA->TTA_TANQUE+"'"
		cQuery += "    AND TQN_BOMBA  = '"+TTA->TTA_BOMBA+"'"
		cQuery += "    AND D_E_L_E_T_ = ' ' "
		//Deve ser avaliado na SS 033890 se deve ser mantido por conta da implementação no padrão.
		//cQuery += "    AND TQN_FILORI = '"+cFilAnt+"'"
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		If aRetDtPar[3]
			dbGoTop()
			If !EoF()
				While !EoF()
					If ValType(aRetDtPar[2]) == "C"
						If (cAliasQry)->TQN_DTABAS+(cAliasQry)->TQN_HRABAS <  DtoS(aRetDtPar[1])+aRetDtPar[2]
							ApMsgStop(STR0090+; //"Nenhuma movimentação de abastecimento poderá ser processada antes da data/hora: "
										DtoC(aRetDtPar[1])+" "+aRetDtPar[2]+".",STR0037) //"ATENÇÃO"
							(cAliasQry)->(dbCloseArea())
							Return .F.
						EndIf
					Else
						If StoD((cAliasQry)->TQN_DTABAS) <  aRetDtPar[1]
							ApMsgStop(STR0091+; //"Nenhuma movimentação de abastecimento poderá ser processada antes da data: "
										DtoC(aRetDtPar[1])+".",STR0037) //"ATENÇÃO"
							(cAliasQry)->(dbCloseArea())
							Return .F.
						EndIf
					EndIf
					(cAliasQry)->(dbSkip())
				End
			EndIf
		EndIf
		If FindFunction("MNT659VAL")
			dbSelectArea(cAliasQry)
			dbGoTop()
			While !EoF()
				/*
				MNT659VAL - Função que valida abastecimento de acordo com parâmetro MV_NGABAVL
				Se tiver algum retorno falso no segundo vetor mostra divergencia/erro.
				ex.:Retorno:
				{{"Mensagem"}- Mensagem que será apresentada no abastecimento manual
				{{.F.," 47"} - Validação de Esquema Padrão	 - código da inconsistencia pela importação
				{.F.," 48"}  - Validação de Estrutura Padrão - código da inconsistencia pela importação
				{.F.," 49"}  - Validação de Manutenção Padrão- código da inconsistencia pela importação
				{.F.," 50"}}}- Validação de Manutenção		 - código da inconsistencia pela importação
				*/
				aValAbast:= MNT659VAL((cAliasQry)->TQN_FROTA,(cAliasQry)->TQN_FILIAL,StoD((cAliasQry)->TQN_DTABAS),(cAliasQry)->TQN_HRABAS)
				If aScan(aValAbast[2], {|x| x[1] == .F. }) > 0
					MsgInfo(aValAbast[1][1])
					Return .F.
				EndIf

				dbSelectArea(cAliasQry)
				dbSkip()
			EndDo
		EndIf

		dbSelectArea(cAliasQry)
		dbGoTop()
		If !EoF()
			While !EoF() .And. !lExitTQN
				If !Empty((cAliasQry)->TQN_DTCON)
					If !MsgYesNo(STR0075) //"Há abastecimento(s) conciliado(s) para a folha. Deseja prosseguir?"
						Return .F.
					Else
						lExitTQN := .T.
					EndIf
				EndIf
				dbSkip()
			End
		EndIf

		//Verifica se há integração entre os módulos Manutenção de Ativos (SIGAMNT) e Estoque (SIGAEST).
		//Indica o momento que o estoque sera debitado, ou seja, na 'Conciliação'.
		//Há abastecimentos conciliados para a folha.
		If cUsaInt3 == "S" .And. cConEst == "C"

			dbSelectArea( cAliasQry )
			dbGoTop()
			While !EoF()

				If lPrimeiro
					If !Empty( (cAliasQry)->TQN_DTCON )
						If STOD( (cAliasQry)->TQN_DTABAS ) <= dDtBlqMov //Se a data do abastecimento for menor/igual que a data de bloqueio de abastecimento (MV_DBLQMOV);
							//"A folha de abastecimento 'x' não pode ser excluída porque a data de abastecimento do veículo 'x' é menor ou igual que a data de bloqueio de movimentações 'y'. Conforme parâmetro (MV_DBLQMOV)."
							MsgAlert( STR0172 + AllTrim( TTA->TTA_FOLHA ) + STR0173 + AllTrim( (cAliasQry)->TQN_FROTA ) + STR0174 + DTOC( dDtBlqMov ) + STR0175 )
							Return .F.
						EndIf
					Else
						If STOD( (cAliasQry)->TQN_DTABAS ) <= dDtBlqMov //Se a data do abastecimento for menor/igual que a data de bloqueio de abastecimento (MV_DBLQMOV);
							lReturn	:= MsgYesNo( STR0172 + AllTrim( TTA->TTA_FOLHA ) + STR0207 + DTOC( dDtBlqMov ) + STR0175 + STR0208 ) //" tem data menor ou igual ao bloqueio de movimentações " ## " Deseja prosseguir? "
							lPrimeiro	:= .F.
							If !lReturn
								Return .F.
							EndIf
						EndIf
					EndIf
				EndIf

				(cAliasQry)->(dbSkip())
			End While

		EndIf

		(cAliasQry)->(dbCloseArea())
	Next i

	BeginSQL Alias cAlsTQN

		SELECT // Seleciona registros exclusivos de produtos, os quais não geram TQN.
			STJ.TJ_ORDEM,
			STJ.TJ_PLANO,
			STJ.TJ_CODBEM
		FROM
			%table:STL% STL
		RIGHT JOIN
			%table:STJ% STJ ON
				STJ.TJ_ORDEM  = STL.TL_ORDEM  AND
				STJ.TJ_PLANO  = STL.TL_PLANO  AND
				STJ.TJ_FILIAL = %xFilial:STJ% AND
				STJ.TJ_SITUACA <> 'C'         AND
				STJ.%NotDel%
		WHERE
			STL.TL_NOTFIS = %exp:TTA->TTA_FOLHA% AND
			STL.TL_FORNEC = %exp:TTA->TTA_POSTO% AND
			STL.TL_LOJA   = %exp:TTA->TTA_LOJA%  AND
			STL.TL_FILIAL = %xFilial:STL%        AND
			STL.%NotDel%
		ORDER BY
			STJ.TJ_ORDEM,
			STJ.TJ_PLANO,
			STJ.TJ_CODBEM

	EndSQL

	If (cAlsTQN)->( !EoF() )

		cOrdens += STR0242 + Space( 19 + Len( STJ->TJ_ORDEM ) ) +  STR0243 + Space( 17 + Len( STJ->TJ_PLANO ) ) +;
			STR0244 + CRLF // Ordem ## Plano ## Código Bem

		Do While (cAlsTQN)->( !EoF() )

			cOrdens += (cAlsTQN)->TJ_ORDEM + Space( 18 + Len( STJ->TJ_ORDEM ) ) + (cAlsTQN)->TJ_PLANO +;
				Space( 14 + Len( STJ->TJ_PLANO ) ) + (cAlsTQN)->TJ_CODBEM + CRLF

			(cAlsTQN)->( dbSkip() )

		EndDo

		/*
			- Reabrir a(s) O.S. de lubrificação através da rotina de Reabertura de O.S. (MNTA880)
			- Cancelar as O.S. reabertas através de uma das rotinas de Retorno O.S.
			As ordens de serviços relacionadas aos abastecimentos são:
		*/
		cMensag += STR0240 + CRLF + STR0076 + CRLF + CRLF +	STR0239 + CRLF + cOrdens

		lRet    := .F.

	EndIf

	(cAlsTQN)->( dbCloseArea() )

	If !lRet
		DEFINE FONT oFont NAME "Courier New" SIZE 5,0
		DEFINE MSDIALOG oDlgl TITLE STR0237 From 3,0 TO 340,417 COLOR CLR_BLACK,CLR_WHITE PIXEL // "Verificar Ordem de Serviço"
		@ 5,5 GET oMemo  VAR cMensag MEMO SIZE 200,145 OF oDlgl PIXEL
		oMemo:bRClicked := {||AllwaysTrue()}
		oMemo:oFont 	:= oFont
		oMemo:lReadOnly := .T.

		DEFINE SBUTTON FROM 153,175 TYPE 1  ACTION oDlgl:End() 						  ENABLE OF oDlgl PIXEL // Ok
		DEFINE SBUTTON FROM 153,145 TYPE 13  ACTION ( cFile := cGetFile( STR0238, OemToAnsi( STR0238 )),;
				If( Empty(cFile), .T., MemoWrite( cFile, cMensag )),) 	ENABLE OF oDlgl PIXEL  //"Salvar Como..."

		ACTIVATE MSDIALOG oDlgl CENTERED
		Return .F.
	EndIf

	If nProgram == 1
		MNTA656INC(cAlias,nRecno,nOpcx)
	EndIf

 Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNT656LISE³ Autor ³ Marcos Wagner Junior  ³ Data ³ 26/11/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Limpa os campos referentes a Servico 					        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA656                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNT656LISE()
Local lMMoeda := NGCADICBASE("TL_MOEDA","A","STL",.F.) // Multi-Moeda
Local nI

If nLanca == STR0005 //"Abastecimento"
	cTroca     := Space(Len(ST4->T4_SERVICO))
	cReposicao := Space(Len(ST4->T4_SERVICO))
	cDesRepo   := ''
	cDesTroca  := ''
	nLubDif    := 0
 	nLubDig    := 0
 	nLubInf    := 0
	oLubDif:Refresh()
	oLubDig:Refresh()
	oLubInf:Refresh()
	For nI := 1 to Len(oBrw1:aCols)
		oBrw1:aCols[nI][nPOSLUBRI] := Space(Len(SB1->B1_COD))
		oBrw1:aCols[nI][nPOSQUALU] := 0
		oBrw1:aCols[nI][nPOSTRREP] := ' '
		oBrw1:aCols[nI][nPOSCUSTO] := 0
		If lMMoeda
			oBrw1:aCols[nI][nPOSMOEDA] := "1"
		EndIf
	Next
	lTrava656 := .F.
ElseIf nLanca == STR0018 //"Produto"
	nCombAtu   := 0
	nCombDif   := 0
	nCombDig   := 0
	nCombTot   := 0
	cTanque    := "  "
	cBomba     := "   "
	oCombAtu:Refresh()
	oCombTot:Refresh()
	oCombDig:Refresh()
	oCombDif:Refresh()
	For nI := 1 to Len(oBrw1:aCols)
		oBrw1:aCols[nI][nPOSQUANT] := 0
		oBrw1:aCols[nI][nPOSMOTOR] := Space(Len(TQN->TQN_CODMOT))
		If lRastr
			oBrw1:aCols[nI][nPOSLOTE]  := Space(Len(STL->TL_LOTECTL))
		EndIf
	Next
EndIf
oBrw1:oBrowse:Refresh()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNT656LIDE³ Autor ³ Marcos Wagner Junior  ³ Data ³ 05/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Limpa os campos referentes a Servico 					        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA656                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT656LIDE()
Local nX, nTotalTQN := nCombAnt
Local lUpdaCols := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica os abastecimentos do mesmo Posto/Loja/Tanque/Bomba ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !NGVALABAST(cPosto,cLoja,cTanque,cBomba,aCols[n][nPOSDATAB],aCols[n][nPOSHORAB],.T.,.T.)
	Return .F.
EndIf

//Ao deletar uma linha do acols libera o registro do controle de semafaro
If !aCols[n][Len(aCols[n])]
	UnLockByName( "MNTA656" + aCols[n][nPOSFROTA] )
ElseIf aCols[n][Len(aCols[n])]

	//Verifica se esse registro estra preso no controle de semafaro
	If !LockByName( "MNTA656" + aCols[n][nPOSFROTA] ) // STR0168
		ShowHelpDlg(STR0037,{STR0168 + aCols[n][nPOSFROTA]},3,; // "Já existe um reporte de abastecimento sendo feito para o veículo ";
			{STR0169},3) // "Aguarde um instante e tente novamente."
		Return .F.
	EndIf

	//Adiciona o registro ao controle de semafaro
	LockByName( "MNTA656" + aCols[n][nPOSFROTA] )

EndIf

If Altera
	//Verifica se abastecimento ja foi conciliado
	If Len(aOldCols) >= n
		If !MNT656CONC()
			If !MsgYesNo(STR0124) //"Abastecimento já foi conciliado! Deseja continuar?"
				Return .F.
			EndIf
		EndIf
	EndIf

	//Verifica se a data/hora limite para movimentar abastecimento foi ultrapassada
	If !oBrw1:aCols[n,Len(oBrw1:aCols[n])] .And. Type("aCols656") == "A"
		If Len(oBrw1:aCols) >= n .And. Len(aCols656) >= n
			lUpdaCols := .T.
		EndIf
	EndIf
	If lUpdaCols
		aRetDtPar := NgDtAbas()
		If aRetDtPar[3]
			If ValType(aRetDtPar[2]) == "C"
				If DtoS(oBrw1:aCols[n][nPOSDATAB])+oBrw1:aCols[n][nPOSHORAB] <  DtoS(aRetDtPar[1])+aRetDtPar[2]
					ApMsgStop(STR0090+; //"Nenhuma movimentação de abastecimento poderá ser processada antes da data/hora: "
								DtoC(aRetDtPar[1])+" "+aRetDtPar[2]+".",STR0037) //"ATENÇÃO"
					Return .F.
				EndIf
			Else
				If oBrw1:aCols[n][nPOSDATAB] <  aRetDtPar[1]
					ApMsgStop(STR0091+; //"Nenhuma movimentação de abastecimento poderá ser processada antes da data: "
								DtoC(aRetDtPar[1])+".",STR0037) //"ATENÇÃO"
					Return .F.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If !aCols[n][Len(aCols[n])]
	nCombDig -= If(ReadVar()=='M->TQQ_QUANT',M->TQQ_QUANT,aCols[n][nPOSQUANT])
	nLubDig  -= If(ReadVar()=='M->TPE_AJUSCO',M->TPE_AJUSCO,aCols[n][nPOSQUALU])
	If lChkLote
		nPosR	:= aScan(aRastro,{|x| x[8] == n })
		If nPosR > 0
			nPOSX := Ascan(aQtdRas,{|x| x[1]+x[2]+x[3] == aRastro[nPosR][1]+aRastro[nPosR][3]+aRastro[nPosR][2]})
     		If nPOSX > 0
     			aQtdRas[nPOSX][4] -= aCols[n][nPOSQUANT]
     		EndIf
	   EndIf
	EndIf
Else
	nCombDig += If(ReadVar()=='M->TQQ_QUANT',M->TQQ_QUANT,aCols[n][nPOSQUANT])
	nLubDig  += If(ReadVar()=='M->TPE_AJUSCO',M->TPE_AJUSCO,aCols[n][nPOSQUALU])
	If lChkLote
		nPosR	:= aScan(aRastro,{|x| x[8] == n })
		If nPosR > 0
			nPOSX := Ascan(aQtdRas,{|x| x[1]+x[2]+x[3] == aRastro[nPosR][1]+aRastro[nPosR][3]+aRastro[nPosR][2]})
     		If nPOSX > 0
     			aQtdRas[nPOSX][4] += aCols[n][nPOSQUANT]
     		EndIf
	   EndIf
	EndIf
EndIf

For nX := 1 to Len(aCols)
	If nX == n
		If aCols[nX][Len(aCols[nX])]
			nTotalTQN := nTotalTQN + aCols[nX][nPOSQUANT]
			aCols[nX][nPOSMARCA] := nTotalTQN
		EndIf
	Else
		If !aCols[nX][Len(aCols[nX])]
			nTotalTQN := nTotalTQN + aCols[nX][nPOSQUANT]
			aCols[nX][nPOSMARCA] := nTotalTQN
		EndIf
	EndIf
Next

oBrw1:oBrowse:Refresh()

nCombDif := nCombTot - nCombDig
nLubDif  := nLubInf  - nLubDig

oCombDig:Refresh()
oCombDif:Refresh()
oLubDig:Refresh()
oLubDif:Refresh()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA656DAT
Altera a data do abastecimento caso ainda nao foi digitado
@author  Marcos Wagner Junior
@since   15/12/08
@version P12
@use MNTA656
/*/
//-------------------------------------------------------------------
Function MNTA656DAT()

    Local nI
    Local lDigitado := .F.

    If Len(oBrw1:aCols) == 1 .And. Inclui
        For nI := 1 to Len(aHeader)
            If nI <> nPOSDATAB .And. nI <> nPOSALMOX
                If Empty(aHeader[nI,Len(aHeader[nI])])
                    If !Empty(oBrw1:aCols[1][nI])
                        lDigitado := .T.
                    EndIf
                EndIf
            EndIf
        Next

        If !lDigitado
            oBrw1:aCols := BLANKGETD(aHEADER)
            oBrw1:aCols[1][nPOSDATAB] := dDataAbast
            oBrw1:oBrowse:Refresh()
        EndIf
    EndIf

Return MNT656ENC(3)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNT656CABO³ Autor ³ Marcos Wagner Junior  ³ Data ³ 15/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega o campo referente ao abastecimento anterior		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA656                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT656CABO(nPar, dDtAbas, cHoraAbas)

	Local nTotalAnt, i

	Local aOldArea, aEmpFil := {}
	Local cNAbast := ''

	Local dDtAbasTQN	:= IIf( Empty(dDtAbas), CToD('  \  \   '), dDtAbas )
	Local cHrAbTQN	:= IIf( Empty(cHoraAbas), '  :  ', cHoraAbas )

	If nPar == 2

		nCombAnt := 0

		dbSelectArea("TQJ")
		dbSetOrder(01)
		If dbSeek(xFilial("TQJ")+cPosto+cLoja+cTanque+cBomba)
			nCombAnt := TQJ->TQJ_CONINI
		EndIf

		If FWAliasInDic("TTV")

			If !Inclui
				aAdd(aEmpFil, SM0->M0_CODIGO)
				For i := 1 To Len(aEmpFil)

					cAliasQry := GetNextAlias()

					cQuery := " SELECT TQN_DTABAS, TQN_HRABAS,  TQN_NABAST"
					cQuery += "   FROM " + RetSqlName("TQN")
					cQuery += "  WHERE TQN_POSTO = " + ValToSql(cPosto)
					cQuery += "     AND TQN_LOJA = " + ValToSql(cLoja)
					cQuery += "     AND TQN_NOTFIS = " + ValToSql(cFolha)
					cQuery += "     AND D_E_L_E_T_ = ' ' "
					//Deve ser avaliado na SS 033890 se deve ser mantido por conta da implementação no padrão.
					//cQuery += "    AND TQN_FILORI = '"+cFilAnt+"'"
					cQuery += "  ORDER BY TQN_DTABAS,TQN_HRABAS"
					cQuery := ChangeQuery(cQuery)

					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

					While (cAliasQry)->( !EoF() )

						If ( dDtAbasTQN > SToD( (cAliasQry)->TQN_DTABAS) ) .Or. Empty(dDtAbasTQN)
							dDtAbasTQN := SToD((cAliasQry)->TQN_DTABAS)
						EndIf

						If ( HToM(cHrAbTQn) > HToM( (cAliasQry)->TQN_HRABAS) .And. (cAliasQry)->TQN_DTABAS == DtoS(dDtAbasTQN) ) .Or. cHrAbTQn == "  :  "
							cHrAbTQn := (cAliasQry)->TQN_HRABAS
						EndIf

						cNABAST += IIf(!Empty(cNAbast), ",","") + ValToSql( (cAliasQry)->TQN_NABAST )

						dbSelectArea(cAliasQry)
						dbSkip()
					EndDo

					(cAliasQry)->(dbCloseArea())
				Next i

			Else
				dDtAbasTQN := dDataAbast
				cHrAbTQn := cHrAb656
			EndIf

			nCombAnt := NGUltConBom(cPosto, cLoja, cTanque, cBomba, dDtAbasTQN, cHrAbTQn, IIf(!Empty(cNABAST), cNABAST, ))

		Else

			dbSelectArea("TTA")
			dbSetOrder(02)

			aOldArea := GetArea()

			If dbSeek(xFilial("TTA")+cPosto+cLoja+cTanque+cBomba)
				While !EoF() .And. TTA->TTA_FILIAL == xFilial("TTA") .And. TTA->TTA_POSTO == cPosto .And. TTA->TTA_LOJA == cLoja;
						.And. TTA->TTA_TANQUE == cTanque .And. TTA->TTA_BOMBA == cBomba

					If DToS(TTA->TTA_DTABAS) + TTA->TTA_HRABAS <= DToS(dDataAbast) + cHrAb656

						nCombAnt := TTA->TTA_CONBOM - IIf(!Inclui, TTA->TTA_TOTCOM, 0)

						//Se foi quebrado o contador, entao pega o contador da bomba da folha anterior
						If nCombAnt < 0
							nCombAnt := nTotalAnt
							nCombAtu := IIf(nCombAtu==0 .Or. TTA->TTA_CONBOM < nCombAnt .And. !Inclui,TTA->TTA_CONBOM,nCombAtu) //Para
						Else
							nCombAtu := IIf(Inclui, nCombAtu, TTA->TTA_CONBOM)
						EndIf

						nTotalAnt := TTA->TTA_CONBOM
					EndIf

					dbSelectArea('TTA')
					dbSkip()
				EndDo
			EndIf

			RestArea(aOldArea)
		EndIf
	EndIf

	If Inclui .And. FunName() == "MNTA656"
		oBrw1:aCols[1, nPosMarca] := IIf(!Empty(oBrw1:aCols[1, nPosMarca]),oBrw1:aCols[1][nPOSMARCA],nCombAnt)
		oBrw1:oBrowse:Refresh()
	EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNT656ENC ³ Autor ³ Marcos Wagner Junior  ³ Data ³ 05/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida os abastecimentos com relacao a data e hora da folha³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA656                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT656ENC(nPar)
Local i
Local cHora, dData
Local lAbastLote := .F. //Lote
Local lAferSaida := .F. //Aferição/Saída

If nPar == 1
	If M->TQN_DTABAS > dDataAbast
		MsgStop(STR0083,STR0037) //"Data do Abastecimento não pode ser maior que a data de encerramento da folha."###"ATENÇÃO"
		Return .F.
	EndIf
	dData := M->TQN_DTABAS
	cHora := oBrw1:aCols[n][nPOSHORAB]
ElseIf nPar == 2
	If oBrw1:aCols[n][nPOSDATAB] == dDataAbast .And. M->TQN_HRABAS > cHrAb656
		MsgStop(STR0084,STR0037) //"Hora do Abastecimento não pode ser maior que a hora de encerramento da folha."###"ATENÇÃO"
		Return .F.
	EndIf
	dData := oBrw1:aCols[n][nPOSDATAB]
	cHora := M->TQN_HRABAS
ElseIf nPar == 3
	If Len(oBrw1:aCols) > 0
		lDtEnc := .F.
		For i:= 1 to Len(oBrw1:aCols)
			If dDataAbast < oBrw1:aCols[i][nPOSDATAB] .And. !Empty(oBrw1:aCols[i][nPOSDATAB])
				lDtEnc := .T.
			EndIf
		Next i
		If lDtEnc
			MsgStop(STR0085,STR0037) //"Já existe abastecimento informado com data maior!"###"ATENÇÃO"
			Return .F.
		EndIf
	EndIf
	dData := dDataAbast
	cHora := cHrAb656
ElseIf nPar == 4
	If Len(oBrw1:aCols) > 0
		lHrEnc := .F.
		For i:= 1 to Len(oBrw1:aCols)
			If dDataAbast == oBrw1:aCols[i][nPOSDATAB] .And.;
				!Empty(oBrw1:aCols[i][nPOSDATAB]) .And.;
				cHrAb656 < oBrw1:aCols[i][nPOSHORAB]
				lHrEnc := .T.
			EndIf
		Next i
		If lHrEnc
			MsgStop(STR0086,STR0037) //"Já existe abastecimento informado com hora maior!"###"ATENÇÃO"
			Return .F.
		EndIf
	EndIf
	dData := dDataAbast
	cHora := cHrAb656
EndIf

If !Empty(cPosto) .And. !Empty(cLoja) .And. !Empty(cTanque) .And. ;
	!Empty(cBomba) .And. !Empty(dData) .And. !Empty(CHora)

	If nPar == 1 .Or. nPar == 2
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica os abastecimentos do mesmo Posto/Loja/Tanque/Bomba ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !NGVALABAST(cPosto,cLoja,cTanque,cBomba,dData,CHora,.T.,.F.)
			Return .F.
		EndIf
	EndIf

	If Inclui

		Inclui := .F.

		//Verifica se há reporte de contador de abastecimento em lote após data
		If NGVDHBomba(cPosto,cLoja,cTanque,cBomba,dData,cHora,"'2'")
			lAbastLote := .T.
		End
		//Verifica se há reporte de contador de aferição/saída após data
		If NGVDHBomba(cPosto,cLoja,cTanque,cBomba,dData,cHora,"'3'")
			lAferSaida := .T.
		EndIf
		//Verifica se houve algum reporte após a data do abastecimento
		If lAbastLote .Or. lAferSaida
			// Verifica se existe tanto um abastecimento em lote quanto uma aferição/saída após a data do abastecimento
			If lAbastLote .And. lAferSaida
				ShowHelpDlg(STR0037,{STR0162},3,; //"Já existe um Abastecimento em Lote e Aferição(ões) de Bomba(s)/Saída(s) de Combustível com data/hora superior a informada."
										{STR0163},3) //"Exclua os Abastecimento em Lote e as Aferições/Saídas cadastradas com data/hora superior ou altere a data/hora deste abastecimento."
			//Verifica se há um abastecimento em lote após a data do abastecimento
			ElseIf lAbastLote
				ShowHelpDlg(STR0037,{STR0164},3,; //"Já existe um Abastecimento(s) em Lote de Combustível com data/hora superior a informada."
										{STR0165},3) //"Exclua os Abastecimento em Lote cadastrados com data/hora superior ou altere a data/hora deste abastecimento."
			//Se for aferição/saída
			ElseIf lAferSaida
				ShowHelpDlg(STR0037,{STR0166},3,; //"Já existe Aferição(ões) de Bomba(s)/Saída(s) de Combustível com data/hora superior a informada."
										{STR0167},3) //"Exclua as Aferições/Saídas cadastradas com data/hora superior ou altere a data/hora deste abastecimento."
			EndIf
			Inclui := .T.
			Return .F.
		EndIf
		Inclui := .T.
	EndIf

EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTA656CAP³ Autor ³ Marcos Wagner Junior  ³ Data ³ 18/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega a capacidade maxima do tanque do veiculo           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA656                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
 Function MNTA656CAP()

	Local lComb    := .F.
	Local lRet     := .T.
	Local cPlaca   := If( ReadVar() == 'M->TQN_PLACA', M->TQN_PLACA, aCols[n][nPOSPLACA] )

	If !Empty(cPlaca)
		dbSelectArea("ST9")
		dbSetOrder(14)
		If dbSeek(cPlaca)
			cFilBens := ST9->T9_FILIAL
		Else
			cFilBens := cFiliST9
		EndIf
	EndIf

	cCodCom := NGSEEK('TQI',cPosto+cLoja+cTanque+cTTAComb,1,'TQI_CODCOM')

	If FunName() == "MNTA656"
		cFrota656 := oBrw1:aCols[n][nPOSFROTA]
	Else
		cFrota656 := aCols[n][nPOSFROTA]
	EndIf

	If !lTpLub //nao valida quando for somente Produto
		lComb := MNT656VDTC(cCodCom) // Válida compatibilidade do tanque X bem.
		If !lComb
			MsgStop(STR0054)  //"Combustível do tanque do posto é incompatível com o combustível do bem."
			lRet := .F.
		EndIf
	EndIf

Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTA656FIL³ Autor ³ Marcos Wagner Junior  ³ Data ³ 20/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega a filial do bem                         	        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA656                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTA656FIL(cFrotaFIL,dDataFIL,cHoraFil,cPlacaBem)

Local cPlaca := ''
Default cPlacaBem := ''

If Empty(cPlacaBem)
	dbSelectArea("ST9")
	dbSetOrder(1)
	If dbSeek(cFiliST9+cFrotaFIL)
		cPLACA   := ST9->T9_PLACA
		cFIL     := ST9->T9_FILIAL
		cCCusto  := ST9->T9_CCUSTO
		cCentrab := ST9->T9_CENTRAB
	EndIf
Else
	dbSelectArea("ST9")
	dbSetOrder(14)
	If dbSeek(cPlacaBem)
		cPLACA   := ST9->T9_PLACA
		cFIL     := ST9->T9_FILIAL
		cCCusto  := ST9->T9_CCUSTO
		cCentrab := ST9->T9_CENTRAB
	EndIf
EndIf

aRetTPN := MNT655TPN( cFrotaFIL,dDataFIL,cHoraFil,cPLACA,xFilial( "ST9" ) )

If !Empty(aRetTPN[1]) .And. !Empty(aRetTPN[2])
	cFIL     := aRetTPN[1]
	cCCusto  := aRetTPN[2]
	cCentrab := aRetTPN[3]
EndIf
If NGSX2MODO("TQN") == "E"
	cFil := ST9->T9_FILIAL
	If Empty(cFil) .And. !Empty(aRetTPN[1])
		cFil := aRetTPN[1]
	ElseIf Empty(cFil) .And. Empty(aRetTPN[1])
		cFil := xFilial("TQN")
	EndIf
EndIf

Return cFil
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNT656FIL  ³ Autor ³Marcos Wagner Junior  ³ Data ³20/12/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Filtra os abastecimentos em lote.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA656 / UTILIZADO POR PONTOS DE ENTRADA                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT656FIL()

ENDFILBRW("TTA",aIndTTA)
cRetPar := BuildExpr("TTA",,cRetPar,.F.)

If !Empty(cRetPar)
   set filter to
   bFiltraBrw := {|| FilBrowse("TTA",@aIndTTA,@cRetPar) }
   Eval(bFiltraBrw)
EndIf

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fPosObjet ³ Autor ³Denis Hyroshi de Souza ³ Data ³ 01/06/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Define posicionamento da getdados                           |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fPosObjet()
Local nIReAltu := 339
Local nPorcVert := 1 //% em relação a resolucao maxima

//Verifica resolução Vertical
If aSize[6] >= 934
	nPorcVert := 1
ElseIf aSize[6] >= 870
	nPorcVert := 0.93
ElseIf aSize[6] >= 774
	nPorcVert := 0.82
ElseIf aSize[6] >= 720
	nPorcVert := 0.77
ElseIf aSize[6] >= 678
	nPorcVert := 0.70 //678/934
ElseIf aSize[6] >= 620
	nPorcVert := 0.65
Else	//If aSize[6] >= 510
	nPorcVert := 0.54
EndIf

nIReAltu := 450 * nPorcVert //Altura

Return nIReAltu

Function MNT656AFE()
Local aArea := GetArea()
lPosto := .T.

dbSelectArea("TQL")
dbSetOrder(1)
NgCad01("TQL",Recno(),3)

RestArea(aArea)

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} fLoadQDAB
Carrega as variáveis de data e hora limite do abastecimentocom o
valor do parâmetro MV_MNTQDAB no SX6.

@author Wexlei Silveira
@since 01/08/2017
@return vazio
/*/
//-------------------------------------------------------------------
Static Function fLoadQDAB()

Local cParamAf := GetMv("MV_MNTQDAB") // Manter o GetMV já que este comando pega o valor sempre atualizado. Ver Task #14852

dDtQDAB := CToD(SubStr(cParamAf,1,10))
cHQDAB := SubStr(cParamAf,12,5)

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fParam
Popup do parâmetro MV_MNTQDAB

@sample
fParam()

@author Wexlei Silveira
@since 01/08/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Function fParam()

	Local oDlgPar
	Local oPnlTop
	Local oPnlCenter
	Local oPnlBottom
	Local cParam := ""
	Local oData
	Local oHora
	Local dData := CToD("  /  /    ")
	Local cHora := "  :  "
	Local lOK := .F.

	cParam := GetMv("MV_MNTQDAB") // Manter o GetMV já que este comando pega o valor sempre atualizado. Ver Task #14852

	dData := IIF(Empty(cParam), CToD("  /  /    "), CToD(SubStr(cParam,1,10)))
	cHora := IIF(Empty(cParam), "  :  ", SubStr(cParam,12,5))

	Define MsDialog oDlgPar From 0,0 To 200,420 Title "Parâmetros" Pixel Style DS_MODALFRAME

		oPnlTop := TPanel():New(0, 0,, oDlgPar,,,,,, 200, 20, .F., .F.)
		oPnlCenter := TPanel():New(20, 0,, oDlgPar,,,,,, 200, 100, .F., .F.)
		oPnlBottom := TPanel():New(200, 400,, oDlgPar,,,,,CLR_HGRAY, 200, 15, .F., .F.)
		oPnlTop:Align := CONTROL_ALIGN_TOP
		oPnlBottom:Align := CONTROL_ALIGN_BOTTOM
		oPnlCenter:Align := CONTROL_ALIGN_ALLCLIENT

		@ 05, 05 Say OemToAnsi(STR0226);
		Size 180, 60 Of oPnlTop Pixel

		@ 12, 12 Say OemToAnsi(STR0227) Size 30, 30 Of oPnlCenter Pixel
		@ 10, 26 MSGET oData VAR dData SIZE 45,05 Pixel OF oPnlCenter HasButton

		@ 32, 12 Say OemToAnsi(STR0228) Size 30, 30 Of oPnlCenter Pixel
		@ 30, 26 MSGET oHora VAR cHora SIZE 06,05 Pixel OF oPnlCenter Picture "99:99" Valid NGVALHORA(cHora, .T.)

		/*Barra inferior com os botões OK/Cancelar*/
		@ 2,130 BUTTON OemToAnsi(STR0229) SIZE 036,012 Pixel OF oPnlBottom ACTION(lOK := .T., fSalvaPar(dData, cHora), oDlgPar:End())
		@ 2,170 BUTTON OemToAnsi(STR0230) SIZE 036,012 Pixel OF oPnlBottom ACTION(lOK := .F., oDlgPar:End())

	Activate MsDialog oDlgPar Centered

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fSalvaPar
Efetiva os valores salvos no parâmetro MV_MNTQDAB na função fParam

@sample
fSalvaPar(dData, cHora)

@param dData: Data limite para abastecimento
@param cHora: Hora limite para abastecimento
@author Wexlei Silveira
@since 10/12/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fSalvaPar(dData, cHora)

	Local cConteudo := DtoC(dData) + " " + cHora

	PutMV("MV_MNTQDAB",cConteudo)

	dDtQDAB := dData
	cHQDAB := cHora

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³f656Change³ Autor ³ Marcos Wagner Junior  ³ Data ³20/12/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao chamada ao trocar a linha da aCols                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA990                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function f656Change()
Local aOldArea := GetArea()
Local nI 		:= oBrw1:nAt
Local lDtvSgCnt  := NGCADICBASE("TPE_SITUAC","A","TPE",.F.) //Indica se permite desativar segundo contador

lNaoAlt656 := .T.
TIPOACOM := .F.

If ValType(nI) == 'N'
	If nI <= Len(oBrw1:aCols)
		dbSelectArea("ST9")
		dbSetOrder(16)
		If dbSeek(oBrw1:aCols[nI][nPOSFROTA])
			TIPOACOM := If(ST9->T9_TEMCONT = "S",.T.,.F.)
		EndIf
		If Altera
			If aScan(aOldCols,{|x| DtoS(x[nPOSDATAB])+x[nPOSHORAB]+x[nPOSFROTA] == DtoS(oBrw1:aCols[nI][nPOSDATAB])+oBrw1:aCols[nI][nPOSHORAB]+oBrw1:aCols[nI][nPOSFROTA] }) != 0
				lNaoAlt656 := .F.
			EndIf
		EndIf

		//FindFunction remover na release GetRPORelease() >= '12.1.027'
		If FindFunction("MNTCont2")
			lValCont2 := MNTCont2(xFilial("TPE"), oBrw1:aCols[nI][nPOSFROTA])
		Else
			dbSelectArea("TPE")
			dbSetOrder(1)
			If dbSeek(xFilial("TPE")+oBrw1:aCols[nI][nPOSFROTA])
				TIPOACOM2 := IIf(lDtvSgCnt, TPE->TPE_SITUAC == "1", .T.)
			else
				TIPOACOM2 := .F.
			EndIf
		EndIf
	Else
		lNaoAlt656 := .T.
	EndIf
Else
	If Altera
		lNaoAlt656 := .F.
	EndIf
EndIf

oBrw1:oBrowse:Refresh()

RestArea(aOldArea)

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MNT656TPLUB³ Autor ³ Evaldo Cevinscki Jr.  ³ Data ³ 12/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Checa se lancamento da folha eh somente de Produto           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT656TPLUB()
lTpLub := .F.

If nLanca == STR0018 //"Produto"
	lTpLub := .T.
	Return .F.
EndIf

Return Inclui

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNTA656BLO³ Autor ³ Marcos Wagner Junior  ³ Data ³13/01/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Bloqueia Posto, Loja							                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTA990                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTA656BLO()

If ExistBlock("MNTA6564")
	Return ExecBlock("MNTA6564",.F.,.F.)
EndIf

Return Inclui
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³NG656LOTCT³ Autor ³ Evaldo Cevinscki Jr.  ³ Data ³ 16/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida o campo TL_LOTECTL                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NG656LOTCT()
Return If(!Empty(M->TL_LOTECTL),NGVRASTSB8(oBrw1:aCols[n][nPOSLUBRI],oBrw1:aCols[n][nPOSALMOX],M->TL_LOTECTL,oBrw1:aCols[n][nPOSSUBLO]),.T.)

//---------------------------------------------------------------------
/*/{Protheus.doc} NG656ALM
Verifica se insumo no almoxarifado possui saldo positivo e testa se
existe insumo gravado com o local informado.

@author Evaldo Cevinscki Jr.
@since  16.01.09
@return .T.
/*/
//---------------------------------------------------------------------
Function NG656ALM( nITE )

	Local nX 			:= 0
	Local nQtdLubr	:= 0
	Local nCodigo		:= aSCAN(oBrw1:aHeader,{|x| Trim(Upper(x[2])) == "TT_CODIGO"}) //Pesquisa o valor do produto no aHeader.
	Local nLubrif		:= aSCAN(oBrw1:aHeader,{|x| Trim(Upper(x[2])) == "TPE_AJUSCO"}) //Pesquisa o valor da Qtd de Lub. no aHeader.
	Local nITEM		:= If(nITE <> NIL,nITE,n)
	Local cLOCA		:= If(nITE <> NIL,oBrw1:aCols[nITEM][nPOSALMOX],M->TL_LOCAL)
	cCodLubri			:= oBrw1:aCOLS[nITEM,nPOSLUBRI]

	For nX := 1 To Len( aCols ) //Percorre o Acols.
		If cCodLubri == oBrw1:aCols[nX][nCodigo] //Verifica se o produto que está sendo incluso é o mesmo que contém no Acols.
			If !aCols[nX][Len(aCols[nX])] //E se a linha não estiver deletada.
				nQtdLubr += aCols[nX][nLubrif] //Atribui a quantidade de saldo para a variável que será passada como parâmetro para a função NGSALSB2().
			EndIf
		EndIf
	Next nX

	If cUsaInt3 == 'S' .And.  !Empty( cCodLubri ) .And. !Empty( cLOCA )
		NGPROALM(oBrw1:aCOLS[nITEM][nPOSLUBRI],cLOCA,nITEM)//Verifica se existe o produto do SB2 com o local informado, se nao tiver cria o produto no al.
		If !lESTNEGA //Testa poder ter saldo negativo se retornar .T.(Prossegue e nao testa o saldo em estoque)se .F.(Testa se o Saldo esta negativo)
			If !NGSALSB2(oBrw1:aCols[nITEM][nPOSLUBRI],cLOCA,nQtdLubr,,,oBrw1:aCols[nITEM][nPOSDATAB])//Testa se o saldo esta negativo
				Return .F.
			EndIf
		EndIf
	EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³NG656NUMLO³ Autor ³ Evaldo Cevinscki Jr.  ³ Data ³ 16/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida o campo TL_NUMLOTE                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NG656NUMLO()
Return If(!Empty(M->TL_NUMLOTE),NGVRASTSB8(oBrw1:aCols[n][nPOSLUBRI],oBrw1:aCols[n][nPOSALMOX],oBrw1:aCols[n][nPOSLOTE],M->TL_NUMLOTE),.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³NG656LOCAL³ Autor ³ Evaldo Cevinscki Jr.  ³ Data ³ 16/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida o campo TL_LOCALIZ                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NG656LOCAL()
Return If(!Empty(M->TL_LOCALIZ),ExistCpo('SBE',oBrw1:aCols[n][nPOSALMOX]+M->TL_LOCALIZ),.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MNTA656TU ³ Autor ³ Evaldo Cevinscki Jr.  ³ Data ³ 19.01.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica campos obrigatorios                               ³±±
±±³          ³ Mesma funcionalidade da funcao MNTA415TU do MNTA415()      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRETOR                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTA656TU(nN)
Local cMENSA    := Space(1)
Local lRETOR    := .T.
Local nININC    := If(nN = NIL,1,nN)
Local nVEZIN    := If(nN = NIL,Len(aCols),nN),xx
Local aINSALMOX := {}, aINSALRAST := {}, nF := 0,aLocFi := {}

For xx := nININC to nVEZIN
	If !aCOLS[xx][LEN(aCOLS[xx])] .And. !Empty(aCOLS[xx][nPOSLUBRI])

		If Empty(aCOLS[xx][nPOSQUALU]) .And. !Empty(aCols[xx][nPOSTRREP])
			cMENSA := STR0107+str(xx,3) //"'Qtde Lub.' nao informada no item  "
         Exit
      EndIf
      If Empty(aCOLS[xx][nPOSALMOX]) .And. !Empty(aCols[xx][nPOSTRREP])
	   	cMENSA := STR0110+str(xx,3) //"Almoxarifado nao informado no item  "
         Exit
     	EndIf

      If Empty(cMENSA) .And. nN <> nil .And. !Empty(aCols[xx][nPOSTRREP]) //Checagem na linha do acols
      	If !NG656ALM(xx)
         	Return .F.
       	EndIf
      EndIf

      //Alimenta a array para checar o saldo dos produtos de toda
      //a acols
      If Empty(cMENSA) .And. nN = nil
      	If cIntMntEst = "S" .And. !lESTNEGA
         	nPOS656 := Ascan(aINSALMOX,{|x| x[1]+x[2] == aCOLS[xx][nPOSLUBRI]+aCOLS[xx][nPOSALMOX]})
            If nPOS656 = 0
            	Aadd(aINSALMOX,{aCOLS[xx][nPOSLUBRI],aCOLS[xx][nPOSALMOX],aCOLS[xx][nPOSQUALU],aCOLS[xx][nPOSDATAB]})
            Else
            	aINSALMOX[nPOS656][3] += aCOLS[xx][nPOSQUALU]
            EndIf
       	EndIf
		EndIf

      If Empty(cMENSA)

            //Valida saldo(SB8) de controle de rastreabilidade por lote do produto
      	If cIntMntEst = "S" .And. Rastro(aCOLS[xx][nPOSLUBRI])

         	If Rastro(aCOLS[xx][nPOSLUBRI],"S") //Valida o sub-lote
            	If Empty(aCOLS[xx][nPOSSUBLO])
   	         	Help(" ",1,"NGATENCAO",,STR0111+Str(xx,3),3,1)  //"Numero do sub-lote não informado item "
	               Return .F.
	            Else
	            	If nN = nil
	               	nPOS656X := Ascan(aINSALRAST,{|x| x[1]+x[2]+x[3]+x[4] == aCOLS[xx][nPOSLUBRI]+aCOLS[xx][nPOSALMOX]+aCOLS[xx][nPOSLOTE]+aCOLS[xx][nPOSSUBLO]})
	                  If nPOS656X = 0
                     	Aadd(aINSALRAST,{aCOLS[xx][nPOSLUBRI],aCOLS[xx][nPOSALMOX],aCOLS[xx][nPOSLOTE],aCOLS[xx][nPOSSUBLO],aCOLS[xx][nPOSQUALU],aCOLS[xx][nPOSDATAB],"S"})
                   	Else
                     	aINSALRAST[nPOS656X][5] += aCOLS[xx][nPOSQUALU]
                        aINSALRAST[nPOS656X][6] := Min(aINSALRAST[nPOS656X][6],aCOLS[xx][nPOSDATAB])
                    	EndIf
	             	Else
	               	dbSelectArea("SB8")
                     dbSetOrder(02)
                     If dbSeek(xFilial("SB8")+aCOLS[xx][nPOSSUBLO]+aCOLS[xx][nPOSLOTE]+aCOLS[xx][nPOSLUBRI]+aCOLS[xx][nPOSALMOX])
			            	nSaldoLote := SB8Saldo(.F.,!Empty(aCOLS[xx][nPOSLOTE]+aCOLS[xx][nPOSSUBLO]),NIL,NIL,NIL,NIL,NIL,aCOLS[xx][nPOSDATAB])
   			           	If QtdComp(nSaldoLote) < QtdComp(aCOLS[xx][nPOSQUALU])
			                 	cHelp:=OemToAnsi(STR0112)+AllTrim(aCOLS[xx][nPOSLUBRI])+OemToAnsi(STR0113)+aCOLS[xx][nPOSALMOX]+OemToAnsi(STR0114); //"Produto "#" Local "#" Saldo Disponivel "
			                    	    +Alltrim(Transform(nSaldoLote,PesqPictQt("B8_SALDO", 14)))+OemToAnsi(STR0115)+Alltrim(aCOLS[xx][nPOSLOTE]); //" Lote "
			                       	 +OemToAnsi(STR0116)+Alltrim(aCOLS[xx][nPOSSUBLO]) //Sub-lote
 			                 	Help(" ",1,"A240LOTENE",,cHelp,4,1)
			                 	Return .F.
			              	EndIf
			            Else
			               Help(" ",1,"NGATENCAO",,STR0117+Chr(13)+Chr(10)+; //"Numero do sub-lote não corresponde ao produto que foi "
			                    STR0118,3,1) //" informado. Digite um sub-lote correspondente."
		                   Return .F.
	   	            EndIf
	   	         EndIf
					EndIf
				Else//Valida o lote
            	If Empty(aCOLS[xx][nPOSLOTE])
   	         	Help(" ",1,"NGATENCAO",,STR0119+Str(xx,3),3,1)  //"Numero do lote não informado item "
	               Return .F.
	            Else
	            	If nN = nil
	               	nPOS656X := Ascan(aINSALRAST,{|x| x[1]+x[2]+x[3] == aCOLS[xx][nPOSLUBRI]+aCOLS[xx][nPOSALMOX]+aCOLS[xx][nPOSLOTE]})
	                  If nPOS656X = 0
                     	Aadd(aINSALRAST,{aCOLS[xx][nPOSLUBRI],aCOLS[xx][nPOSALMOX],aCOLS[xx][nPOSLOTE],aCOLS[xx][nPOSSUBLO],aCOLS[xx][nPOSQUALU],aCOLS[xx][nPOSDATAB],"L"})
                   	Else
                     	aINSALRAST[nPOS656X][5] += aCOLS[xx][nPOSQUALU]
                        aINSALRAST[nPOS656X][6] := Min(aINSALRAST[nPOS656X][6],aCOLS[xx][nPOSDATAB])
                    	EndIf
						Else
	               	dbSelectArea("SB8")
                     dbSetOrder(03)
                     If dbSeek(xFilial("SB8")+aCOLS[xx][nPOSLUBRI]+aCOLS[xx][nPOSALMOX]+aCOLS[xx][nPOSLOTE])
		               	nSaldo:=SaldoLote(aCOLS[xx][nPOSLUBRI],aCOLS[xx][nPOSALMOX],aCOLS[xx][nPOSLOTE],NIL,.F.,!Empty(aCOLS[xx][nPOSLOTE]+aCOLS[xx][nPOSSUBLO]),NIL,aCOLS[xx][nPOSDATAB])
		                  cHelp:=OemToAnsi(STR0112)+AllTrim(aCOLS[xx][nPOSLUBRI])+OemToAnsi(STR0113)+aCOLS[xx][nPOSALMOX]+OemToAnsi(STR0114);//"Produto "#" Local "#" Saldo Disponivel "
		                  	    +Alltrim(Transform(nSaldo,PesqPictQt("B8_SALDO", 14)))+OemToAnsi(STR0115)+Alltrim(aCOLS[xx][nPOSLOTE]) //" Lote "
			            	If QtdComp(nSaldo) < QtdComp(aCOLS[xx][nPOSQUALU])
	   		            	Help(" ",1,"A240LOTENE",,cHelp,4,1)
			                  Return .F.
			               EndIf
		               Else
			            	Help(" ",1,"NGATENCAO",,STR0120+Chr(13)+Chr(10)+; //"Numero do lote não corresponde ao produto que foi "
  			               	  STR0121,3,1)  //" informado. Digite um lote correspondente."
		                  Return .F.
		              	EndIf
						EndIf
					EndIf
				EndIf
			EndIf
   	EndIf

      If Empty(cMENSA)
      	If nN <> nil
         	If cIntMntEst = "S"
            	If LOCALIZA(Trim(ACOLS[xx,nPOSLUBRI]))
               	//Valida a obrigatoriedade de informar o enderecamento fisico se o produto
                  //tem o controle
                  If Empty(ACOLS[xx,nPOSLOCAL]) .And. Empty(ACOLS[xx,nPOSNUMSE])
                  	Help(" ",1,"LOCALIZOBR")
                     Return .F.
                  ElseIf Empty(ACOLS[xx,nPOSLOCAL])
                  	Help(" ",1,"LOCALIZOBR")
                   	Return .F.
                  EndIf

                  //Verifica a obrigatoriedade da quantidade do insumo quando informado a serie
                  If !MtAvlNSer(ACOLS[xx,nPOSLUBRI],ACOLS[xx,nPOSNUMSE],ACOLS[xx,nPOSQUALU])
                  	Return .F.
                  EndIf

                  cLOC := aCols[xx][nPOSALMOX]  // Local/almoxarifado
                  cLOL := aCols[xx][nPOSLOCAL]  // Localizacao fisica
                  cCOD := aCols[xx][nPOSLUBRI]  // Codigo
                  cNUS := aCols[xx][nPOSNUMSE]  // Numero da serie
                  cSBL := aCols[xx][nPOSSUBLO]  // Numero do lote
                  nQTD := aCols[xx][nPOSQUALU]  // Quantidade
                  cLOT := aCols[xx][nPOSLOTE]  // lotectla

                  For nf := 1 To Len(acols)
                  	If nf <> nN
                     	If !aCOLS[nf][LEN(aCOLS[nf])]
                        	If aCols[nf][nPOSALMOX]+aCols[nf][nPOSLOCAL]+aCols[nf][nPOSLUBRI]+;
                           	aCols[nf][nPOSNUMSE]+aCols[nf][nPOSLOTE]+aCols[nf][nPOSSUBLO] = cLOC+cLOL+cCOD+cNUS+cLOT+cSBL
                              nQTD += aCols[nf][nPOSQUALU]
                         	EndIf
                      	EndIf
                   	EndIf
						Next nf

                  If (!Empty(cLOC) .Or. !Empty(cNUS)) .And.;
                  	QtdComp(SaldoSBF(cLOC,cLOL,cCOD,cNUS,cLOT,cSBL,.F.)) < QtdComp(nQTD)
                     Help(" ",1,"SALDOLOCLZ")
                     Return .F.
                  EndIf

					EndIf
				EndIf
    		Else
         	If cIntMntEst = "S"
            	cLOC := aCols[xx][nPOSALMOX]  // Local/almoxarifado
               cLOL := aCols[xx][nPOSLOCAL]  // Localizacao fisica
               cCOD := aCols[xx][nPOSLUBRI]  // Codigo
               cNUS := aCols[xx][nPOSNUMSE]  // Numero da serie
               cSBL := aCols[xx][nPOSSUBLO]  // Numero do lote
               nQTD := aCols[xx][nPOSQUALU]  // Quantidade
               cLOT := aCols[xx][nPOSLOTE]  // lotectla

               nPosLF := Ascan(aLocFi,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6] == cLOC+cLOL+cCOD+cNUS+cLOT+cSBL})
               If nPosLF = 0
               	Aadd(aLocFi,{cLOC,cLOL,cCOD,cNUS,cLOT,cSBL,nQTD})
               Else
               	aLocFi[nPosLF,7] += nQTD
               EndIf
				EndIf
			EndIf
		EndIf
   EndIf
Next xx

If nN = nil .And. Empty(cMENSA)
   //Valida estoque negativo
	If Len(aINSALMOX) >  0
   	For xx := 1 To Len(aINSALMOX)
   	   If cUsaInt3 == 'S'
		      If !lESTNEGA
		      	If !NGSALSB2(aINSALMOX[xx][1],aINSALMOX[xx][2],aINSALMOX[xx][3],,,aINSALMOX[xx][4])
		         	Return .F.
		       	EndIf
		     	EndIf
			EndIf
      Next
   EndIf

   //Checa Saldos por Lote
	If Len(aINSALRAST) > 0
   	For xx := 1 To Len(aINSALRAST)
      	If aINSALRAST[xx][7] = "S" //Sub-lote
         	dbSelectArea("SB8")
            dbSetOrder(02)
            If dbSeek(xFilial("SB8")+aINSALRAST[xx][4]+aINSALRAST[xx][3]+aINSALRAST[xx][1]+aINSALRAST[xx][2])
            	nSaldoLote := SB8Saldo(.F.,!Empty(aINSALRAST[xx][3]+aINSALRAST[xx][4]),NIL,NIL,NIL,NIL,NIL,aINSALRAST[xx][6])
   			   If QtdComp(nSaldoLote) < QtdComp(aINSALRAST[xx][5])
			      	cHelp := OemToAnsi(STR0112)+AllTrim(aINSALRAST[xx][1])+OemToAnsi(STR0113)+aINSALRAST[xx][2]+OemToAnsi(STR0114); //"Produto "#" Local "#" Saldo Disponivel "
			         	      +Alltrim(Transform(nSaldoLote,PesqPictQt("B8_SALDO", 14)))+OemToAnsi(STR0115)+Alltrim(aINSALRAST[xx][3]); //" Lote "
			           		   +OemToAnsi(STR0116)+Alltrim(aINSALRAST[xx][4]) //Sub-lote
 			       	Help(" ",1,"A240LOTENE",,cHelp,4,1)
			       	Return .F.
			    	EndIf
			 	Else
			   	Help(" ",1,"NGATENCAO",,STR0117+Chr(13)+Chr(10)+; //"Numero do sub-lote não corresponde ao produto que foi "
			      	   STR0118,3,1) //" informado. Digite um sub-lote correspondente."
		        	Return .F.
			 	EndIf
			Else //Lote
         	dbSelectArea("SB8")
            dbSetOrder(03)
            If dbSeek(xFilial("SB8")+aINSALRAST[xx][1]+aINSALRAST[xx][2]+aINSALRAST[xx][3])
            	nSaldo := SaldoLote(aINSALRAST[xx][1],aINSALRAST[xx][2],aINSALRAST[xx][3],NIL,.F.,!Empty(aINSALRAST[xx][3]+aINSALRAST[xx][4]),NIL,aINSALRAST[xx][6])
		        	cHelp  := OemToAnsi(STR0112)+AllTrim(aINSALRAST[xx][1])+OemToAnsi(STR0113)+aINSALRAST[xx][2]+OemToAnsi(STR0114);//"Produto "#" Local "#" Saldo Disponivel "
		         	         +Alltrim(Transform(nSaldo,PesqPictQt("B8_SALDO", 14)))+OemToAnsi(STR0115)+Alltrim(aINSALRAST[xx][3]) //" Lote "
			   	If QtdComp(nSaldo) < QtdComp(aINSALRAST[xx][5])
	   		   	Help(" ",1,"A240LOTENE",,cHelp,4,1)
			       	Return .F.
			    	EndIf
			 	Else
			   	Help(" ",1,"NGATENCAO",,STR0120+Chr(13)+Chr(10)+; //"Numero do lote não corresponde ao produto que foi "
  			      	  STR0121,3,1)  //" informado. Digite um lote correspondente."
		        	Return .F.
			 	EndIf
			EndIf
		Next
   EndIf
EndIf

If Len(aLocFi) > 0 .And. cIntMntEst = "S"
   For nf := 1 To Len(aLocFi)
      If LOCALIZA(Trim(aLocFi[nf,3]))

         //Valida a obrigatoriedade de informar o enderecamento fisico se o produto
         //tem o controle
      	If Empty(aLocFi[nf,2]) .And. Empty(aLocFi[nf,4])
         	Help(" ",1,"LOCALIZOBR")
            Return .F.
         ElseIf Empty(aLocFi[nf,2])
            Help(" ",1,"LOCALIZOBR")
            Return .F.
         EndIf

         //Verifica a obrigatoriedade da quantidade do insumo quando informado a serie
         If !MtAvlNSer(aLocFi[nf,3],aLocFi[nf,4],aLocFi[nf,7])
            Return .F.
         EndIf
         If (!Empty(aLocFi[nf,1]) .Or. !Empty(aLocFi[nf,4])) .And.;
            QtdComp(SaldoSBF(aLocFi[nf,1],aLocFi[nf,2],aLocFi[nf,3],aLocFi[nf,4],aLocFi[nf,5],aLocFi[nf,6],.F.)) < QtdComp(aLocFi[nf,7])
            Help(" ",1,"SALDOLOCLZ",,STR0061+" "+aLocFi[nf,3],5,1)
           Return .F.
         EndIf
      EndIf
   Next nf
EndIf

If !Empty(cMENSA)
   MsgInfo(cMENSA,STR0037)//'ATENCAO'
   lRETOR := .F.
EndIf

Return lRETOR

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MNT656CONC³ Autor ³ Evaldo Cevinscki Jr.  ³ Data ³ 21/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ X3_WHEN dos campos Quantidade, Motorista, Contador         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT656CONC()
Local aArea := GetArea()
Local cAliasQry
Local i, aEMPFIL := {}
lConciliad  := .T.

If FunName() == "MNTA656"

	aAdd(aEMPFIL,SM0->M0_CODIGO)
	For i:=1 to Len(aEMPFIL)
		cAliasQry := GetNextAlias()
		cQuery := " SELECT TQN.TQN_DTCON "
		cQuery += "   FROM " + RetSqlName("TQN") + " TQN"
		cQuery += "  WHERE TQN.TQN_FROTA  = '"+oBrw1:aCols[n][nPOSFROTA]+"'"
		cQuery += "    AND TQN.TQN_DTABAS = '"+DTOS(oBrw1:aCols[n][nPOSDATAB])+"'"
		cQuery += "    AND TQN.TQN_HRABAS = '"+oBrw1:aCols[n][nPOSHORAB]+"'"
		cQuery += "    AND TQN.D_E_L_E_T_ = ' ' "
		//Deve ser avaliado na SS 033890 se deve ser mantido por conta da implementação no padrão.
		//cQuery += "    AND TQN.TQN_FILORI = '"+cFilAnt+"'"
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		dbGoTop()
		If !Empty((cAliasQry)->TQN_DTCON)
			lConciliad := .F.
		EndIf
		(cAliasQry)->(dbCloseArea())
	Next i
EndIf

RestArea(aArea)
Return lConciliad

//-------------------------------------------------------------------
/*/{Protheus.doc} MNT656EXJG
Exclui abastecimentos gravados (Copia da funcao do MNTA655)

@author  Marcos Wagner Junior
@since   28/01/09
@version P11/P12
@param   cCodbem   , Caracter, Código do Bem
@param   nI        , Numérico, Linha aCols
@param   dDtabas   , Data    , Data do abastecimento
@param   lCCivil   , Lógico  , Define se é do Construção Civil
@param   aColsAbast, Array   , aCols referente ao abastecimento
/*/
//-------------------------------------------------------------------
Function MNT656EXJG( cCodBem, nI, dDtAbas, lCCivil, aColsAbast )

	Local lIncluiOld
	Local lDtvSgCnt    := NGCADICBASE("TPE_SITUAC","A","TPE",.F.) //Indica se permite desativar segundo contador
	Local lCompT9TQN   := Len( AllTrim( xFilial( 'ST9' ) ) ) == Len( AllTrim( xFilial( 'TQN' ) ) )
	Local lIntegEST    := SuperGetMV( 'MV_NGMNTES', .F., 'N' ) == 'S'
	Local cFilTqn      := xFilial('TQN')

	Default aColsAbast := aClone(aCols)
	Default dDtAbas    := aColsAbast[nI, nPosDataB]
	Default lCCivil    := .F.

	aRetTPN := NgFilTPN(cCodBem, dDtAbas,aColsAbast[nI][nPOSHORAB])
	cFilTPN := IIf( Empty( cFilTPN := aRetTPN[1]), TQN->TQN_FILIAL, cFilTPN )

	//-------------------------------------------------
	// Verifica a filial usada para o abastecimento
	//-------------------------------------------------
	If lCompT9TQN
		cFilTqn := cFilTPN
	EndIf

	dbSelectArea("TQN")
	dbSetOrder(01)
	If dbSeek( cFilTqn + cCodBem + DToS(dDtAbas) + aColsAbast[nI, nPosHoraB])

		vVDadoE := {TQN->TQN_FROTA,TQN->TQN_DTABAS,TQN->TQN_HRABAS,TQN->TQN_NUMSEQ,;
					TQN->TQN_TANQUE,TQN->TQN_CODCOM,TQN->TQN_QUANT,TQN->TQN_POSTO,;
					TQN->TQN_LOJA,TQN->TQN_NOTFIS,TQN->TQN_CCUSTO,TQN->TQN_CNPJ}

		If lIntegEST

			cFilTQF := MNT655FTQF(vVDadoE[2],vVDadoE[4],vVDadoE[7]) //Data / Numseq / Quantidade

			If !Empty(vVDadoE[4])
				cUM := NGSEEK('TQM',vVDadoE[6],1,'TQM->TQM_UM',cFilTQF)
				cComb		:= NGSEEK('TQI', vVDadoE[8] + vVDadoE[9] + vVDadoE[5] + vVDadoE[6], 1,'TQI->TQI_PRODUT', cFilTQF)
				cDocumSD3	:= NGSEEK('SD3', vVDadoE[4] + 'E0', 4,'SD3->D3_DOC', cFilTQF)

				lIncluiOld	:= Inclui
				Inclui		:= .T.   //Para validar a A241QTDGRA()

				aActiveArea := TQN->(GetArea())
				MntMovEst('DE0',vVDadoE[5],cComb,vVDadoE[7],vVDadoE[2],cDocumSD3,cFilTQF,vVDadoE[11],.T.,vVDadoE[4])
				RestArea(aActiveArea)

				//Ponto de Entrada para altecoes finais no SD3
				If ExistBlock("MNT655D3CC")
					ExecBlock("MNT655D3CC", .F. , .F. , {'DE0', TQN->TQN_FROTA, vVDadoE[11], cFilTQF })
				EndIf

				Inclui := lIncluiOld   //Para validar a A241QTDGRA()
				
			EndIf

		EndIf

		//Referentes ao primeiro contador
		aARALTC :=  {'STP','STP->TP_FILIAL','STP->TP_CODBEM',;
						'STP->TP_DTLEITU','STP->TP_HORA','STP->TP_POSCONT',;
						'STP->TP_ACUMCON','STP->TP_VARDIA','STP->TP_VIRACON'}

		aARABEM := {'ST9','ST9->T9_POSCONT', 'ST9->T9_CONTACU',;
						'ST9->T9_DTULTAC', 'ST9->T9_VARDIA'}

		dbSelectArea(aARALTC[1])
		dbsetorder(5)
		If dbSeek(xFilial(aARALTC[1],cFilTPN) + vVDadoE[1] + DToS(vVDadoE[2]) + vVDadoE[3])

			nRECNSTP := Recno()
			lULTIMOP := .T.
			nACUMFIP := 0
			nCONTAFP := 0
	      	nVARDIFP := 0
	      	dDTACUFP := Ctod('  /  /  ')
	      	cHRACU   := "  :  "

			dbSkip(-1)

      		If !EoF() .And. !BoF() .And. &(aARALTC[2]) = xFilial(aARALTC[1],cFilTPN) .And.;
				&(aARALTC[3]) = vVDadoE[1]
	         	nACUMFIP := &(aARALTC[7])
	         	dDTACUFP := &(aARALTC[4])
	         	nCONTAFP := &(aARALTC[6])
	         	nVARDIFP := &(aARALTC[8])
	         	cHRACU	:= &(aARALTC[5])
			EndIf
			dbGoTo(nRECNSTP)

      		nACUMDEL := stp->tp_acumcon

			dbSelectArea(aARALTC[1])

      		RecLock(aARALTC[1],.F.)
			dbDelete()
      		MsUnlock(aARALTC[1])

      		MNTA875ADEL(vVDadoE[1],vVDadoE[2],vVDadoE[3],1,cFilTPN,cFilTPN)

	      If ExistBlock("NGUTIL4C")
				ExecBlock("NGUTIL4C", .F., .F., {vVDadoE[1], dDTACUFP, cHRACU, nCONTAFP, nACUMFIP})
			EndIf
   		EndIf

   		//Referentes ao segundo contador
		If lSegCont
			dbSelectArea("TPE")
			dbSetOrder(1)
			If dbSeek(If(NGSX2MODO("TPE")="E",cFilTPN,xFilial("TPE"))+vVDadoE[1])
				If !lDtvSgCnt .Or. (lDtvSgCnt .And. TPE->TPE_SITUAC == "1")

					aARALTC := {'TPP','TPP->TPP_FILIAL','TPP->TPP_CODBEM','TPP->TPP_DTLEIT','TPP->TPP_HORA',;
						              'TPP->TPP_POSCON','TPP->TPP_ACUMCO','TPP->TPP_VARDIA','TPP->TPP_VIRACO'}

					aARABEM := {'TPE','TPE->TPE_POSCON','TPE->TPE_CONTAC','TPE->TPE_DTULTA','TPE->TPE_VARDIA'}

					dbSelectArea(aARALTC[1])
					dbSetOrder(5)
					If dbSeek(xFilial(aARALTC[1], cFilTPN) + vVDadoE[1] + DToS(vVDadoE[2]) + vVDadoE[3])

			      		nRECNSTP := Recno()
						lULTIMOP := .T.
						nACUMFIP := 0
				     	nCONTAFP := 0
				      	nVARDIFP := 0
				      	dDTACUFP := Ctod('  /  /  ')
				      	cHRACU   := "  :  "

						dbSkip(-1)

			      		If !EoF() .And. !BoF() .And. &(aARALTC[2]) = xFilial(aARALTC[1],cFilTPN) .And.;
			         		&(aARALTC[3]) = vVDadoE[1]
				         	nACUMFIP := &(aARALTC[7])
				         	dDTACUFP := &(aARALTC[4])
				         	nCONTAFP := &(aARALTC[6])
				         	nVARDIFP := &(aARALTC[8])
				         	cHRACU	:= &(aARALTC[5])
			      		EndIf

						dbGoTo(nRECNSTP)

			      		nACUMDEL := TPP->TPP_ACUMCO

						dbSelectArea(aARALTC[1])

			      		RecLock(aARALTC[1],.F.)
						dbdelete()
			      		MsUnlock(aARALTC[1])

			      		MNTA875ADEL(vVDadoE[1],vVDadoE[2],vVDadoE[3],2,cFilTPN,cFilTPN)

			      		If ExistBlock("NGUTIL4C")
							ExecBlock("NGUTIL4C",.F.,.F.,{vVDadoE[1],dDTACUFP,cHRACU,nCONTAFP,nACUMFIP})
						EndIf
					EndIf
		   		EndIf
			EndIf
		EndIf

		//----------------------------------------
		//Deleta historico do contador da Bomba
		//----------------------------------------
   		NGDelTTVAba(TQN->TQN_NABAST)

		If !lCCivil
			aAdd(aGravaLog, { SubStr(cUsuario, 7, 15), DToC(dDATABASE), Time(), "EXCLUSAO", AllTrim( Str(Recno()) ), TQN->TQN_NOTFIS, TQN->TQN_FILIAL, SM0->M0_CODIGO })
		EndIf

   		dbSelectArea("TQN")

		TQN->( RecLock("TQN", .F.) )
		TQN->( dbDelete() )
		TQN->( MsUnlock() )
	EndIf

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MNT656AFER³ Autor ³Denis Hyroshi de Souza ³ Data ³ 01/06/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ1ÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Abre tela para informar registro de afericao               |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNT656AFER(nOpcx)
Local oDlg, nX
Local nOpcTLW := 0
Local aOldHea := aClone(aHeader)
Local aOldCol := aClone(aCols)

Local nOldTTH := 0

Private nPCodCom := aSCAN(aHeadTTH,{|x| Trim(Upper(x[2])) == "TTH_CODCOM"})
Private nPMotivo := aSCAN(aHeadTTH,{|x| Trim(Upper(x[2])) == IIF(lTemTTX,"TTH_MOTIV2","TTH_MOTIVO")})
Private nDesMoti := aSCAN(aHeadTTH,{|x| Trim(Upper(x[2])) == "TTH_DESCRI"})
Private nPQuant  := aSCAN(aHeadTTH,{|x| Trim(Upper(x[2])) == "TTH_QUANT"})
Private nPMatric := aSCAN(aHeadTTH,{|x| Trim(Upper(x[2])) == "TTH_MATRIC"})

Private M->TTH_TIPO   := "1"
Private M->TTH_POSTO  := cPosto
Private M->TTH_LOJA   := cLoja
Private M->TTH_TANQUE := cTanque
Private M->TTH_BOMBA  := cBomba
Private M->TTH_MOTIVO := "5"
Private aColsSaid := {}

If Len(aHeadTTH) == 0
	MsgStop(STR0134) //"Não foram encontrados campos na tabela TTH"
	Return .F.
EndIf

nOldTTH := 0
For nX := 1 To Len(aAferTTH)
	If !aAferTTH[nX][Len(aAferTTH[nX])]
		nOldTTH += aAferTTH[nX,nPQuant]
	EndIf
Next nX

aHeader := aClone(aHeadTTH)
cVldTemp := Alltrim(aHeader[nPDtAbas, 06])
aHeader[nPDtAbas, 06] := cVldTemp+If(!Empty(cVldTemp)," .And. ","")+"Val656DTHR(M->TTH_DTABAS,1,.F.)"
cVldTemp := Alltrim(aHeader[nPHrAbas, 06])
aHeader[nPHrAbas, 06] := cVldTemp+If(!Empty(cVldTemp)," .And. ","")+"Val656DTHR(M->TTH_HRABAS,2,.F.)"
If SuperGetMv( 'MV_NGMNTRH', .F., 'S' ) == 'N'
	aHeader[nPMatric, 9] := 'ST1'
EndIf
aCols  := {}
n := 1

If Len(aAferTTH) == 0
	aCols := BLANKGETD(aHeader)
Else
	aCols := aClone(aAferTTH)
EndIf

DEFINE MSDIALOG oDlg TITLE STR0135 From 0,0 To 420,620 OF oMainWnd PIXEL //"Registro de saída de combustível na bomba"

	dbSelectArea("TTH")
	oBrwSaid := MsNewGetDados():New( 35, 5, 195, 310, GD_INSERT + GD_UPDATE + GD_DELETE, 'MNTTHLINOK', 'MNTTHALLOK', '', , ,;
	                                 2000, 'AllwaysTrue()', , , oDlg, aHeader, aCols )
	oBrwSaid:oBrowse:bChange := { || fSaiChange() }
	oBrwSaid:oBrowse:Refresh()
	aColsSaid:= aClone(oBrwSaid:aCols)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcTLW:=1,if(oBrwSaid:TudoOk(),oDlg:End(),nOpcTLW := 0)},{||oDlg:End(),nOpcTLW := 0}) CENTERED

If nOpcTLW == 1
	aTemp := {}
	nDigTTH := 0
	For nX := 1 To Len(oBrwSaid:aCols)
		If !oBrwSaid:aCols[nX][Len(oBrwSaid:aCols[nX])]
			aAdd( aTemp , aClone(oBrwSaid:aCols[nX]) )
			nDigTTH += oBrwSaid:aCols[nX,nPQuant]
		EndIf
	Next nX

	aAferTTH := aClone(aTemp)

	//Ordenando por data+hora devolucao
	aSort( aAferTTH , , , { |x,y| DTOS(x[nPDtAbas]) + x[nPHrAbas] < DTOS(y[nPDtAbas]) + y[nPHrAbas] } )

	nCombDig -= nOldTTH
	nCombDig += nDigTTH
	nCombDif := nCombTot - nCombDig
EndIf

aHeader := aClone(aOldHea)
aCols := aClone(aOldCol)
n := 1

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTTHALLOK ³ Autor ³ Denis Hyroshi de Souza³ Data ³ 15/01/09³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida confirmacao da tela de Devolucao Parcial            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTTHALLOK()
Local nX
Local cMsg := STR0137 //"A quantidade utilizada na aferição não pode ser maior que o total informado."
Local nTotalDig := 0
Local dDtUlMes := SuperGetMv("MV_ULMES", .F., "")

If Empty(dDtUlMes)
	dDtUlmes := CtoD("  /  /    ")
EndIf

//Tratamento adicionado para considerar da data de fechamento do estoque.
For nX := 1 To Len(oBrwSaid:aCols)
	If oBrwSaid:aCols[nX][nPDtAbas] <= dDtUlMes
		MsgStop(STR0180,STR0037) //"Data de abastecimento não pode ser menor ou igual a data do fechamento de estoque."###"ATENÇÃO"
		Return .F.
	EndIf
Next nX

For nX := 1 To Len(oBrwSaid:aCols)
	If !oBrwSaid:aCols[nX][Len(oBrwSaid:aCols[nX])]
		nTotalDig += oBrwSaid:aCols[nX][nPQuant]
	EndIf
Next nX

If nTotalDig > nCombTot
	HELP(" ",1,STR0138,STR0138,Alltrim(Memoline(cMsg,43,1))+CHR(13)+CHR(10)+Memoline(cMsg,43,2),3,4) //"ATENCAO"###"ATENCAO"
	Return .F.
EndIf
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTTHLINOK³ Autor ³ Denis Hyroshi de Souza³ Data ³ 15/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida confirmacao da linha de Devolucao Parcial           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTTHLINOK()
Local nX,nInd ,nAc := oBrwSaid:nAt
Local cMsg := STR0139 //"Já existe registro com a mesma Data/Hora Aferição."
Local lTemAfer := .F.
Local dDtUlMes := SuperGetMv("MV_ULMES", .F., "")	//Data fechamento do estoque
Private lAfericao := If(SuperGetMv("MV_NGMNTAF",.F.,"2") == "1",.T.,.F.)//Verifica parametro que indica se deve validar com afericao

If Empty(dDtUlMes)
	dDtUlMes := CtoD("  /  /    ")
EndIf

If oBrwSaid:aCols[nAc][Len(oBrwSaid:aCols[nAc])]
	Return .T.
EndIf

For nX := 1 To Len(oBrwSaid:aCols)
	If !oBrwSaid:aCols[nX][Len(oBrwSaid:aCols[nX])] .And. nX <> n
		If oBrwSaid:aCols[nAc][nPDtAbas] == oBrwSaid:aCols[nX][nPDtAbas] .And. oBrwSaid:aCols[nAc][nPHrAbas] == oBrwSaid:aCols[nX][nPHrAbas]
			HELP(" ",1,STR0138,STR0138,Alltrim(Memoline(cMsg,40,1))+CHR(13)+CHR(10)+Memoline(cMsg,40,2),3,4) //"ATENCAO"###"ATENCAO"
			Return .F.
		EndIf
	EndIf
Next nX

If Empty(oBrwSaid:aCols[nAc][nPDtAbas])
	HELP(" ",1,STR0138,STR0138,STR0140,3,4) //"ATENCAO"###"ATENCAO"###"O campo Data é obrigatório."
	Return .F.
EndIf

If Empty(oBrwSaid:aCols[nAc][nPHrAbas]) .Or. Alltrim(oBrwSaid:aCols[nAc][nPHrAbas]) == ":"
	HELP(" ",1,STR0138,STR0138,STR0141,3,4) //"ATENCAO"###"ATENCAO"###"O campo Hora é obrigatório."
	Return .F.
EndIf

If Empty(oBrwSaid:aCols[nAc][nPCodCom])
	HELP(" ",1,STR0138,STR0138,STR0142,3,4) //"ATENCAO"###"ATENCAO"###"O campo Combustivel é obrigatório."
	Return .F.
EndIf

If Empty(oBrwSaid:aCols[nAc][nPQuant])
	HELP(" ",1,STR0138,STR0138,STR0143,3,4) //"ATENCAO"###"ATENCAO"###"O campo Quantidade é obrigatório."
	Return .F.
EndIf

If Empty(oBrwSaid:aCols[nAc][nPMotivo])
	HELP(" ",1,STR0138,STR0138,STR0144,3,4) //"ATENCAO"###"ATENCAO"###"O campo Motivo é obrigatório."
	Return .F.
EndIf

If Empty(oBrwSaid:aCols[nAc][nPMatric])
	HELP(" ",1,STR0138,STR0138,STR0145,3,4) //"ATENCAO"###"ATENCAO"###"O campo Matricula é obrigatório."
	Return .F.
EndIf

If oBrwSaid:aCols[nAc][nPDtAbas] > dDataAbast
	MsgStop(STR0146,STR0037) //"Data da Aferição não pode ser maior que a data de encerramento da folha."###"ATENÇÃO"
	Return .F.
EndIf
If oBrwSaid:aCols[nAc][nPDtAbas] == dDataAbast .And. oBrwSaid:aCols[nAc][nPHrAbas] > cHrAb656
	MsgStop(STR0147,STR0037) //"Hora da Aferição não pode ser maior que a hora de encerramento da folha."###"ATENÇÃO"
	Return .F.
EndIf

//Tratamento adicionado para considerar da data de fechamento do estoque.
If oBrwSaid:aCols[nAc][nPDtAbas] <= dDtUlMes
	MsgStop(STR0180,STR0037) //"Data de abastecimento não pode ser menor ou igual a data do fechamento de estoque."###"ATENÇÃO"
	Return .F.
EndIf

If lAfericao .And. Inclui .And. nLanca <> STR0018 //Verificar se o Tipo Lançamento é diferente de Produto
	//Verifica a aferição da bomba
	dbSelectArea("TQL")
	dbSetOrder(1)
	If dbSeek(xFilial("TQL")+M->TTH_POSTO+M->TTH_LOJA+M->TTH_TANQUE+M->TTH_BOMBA+DTOS(oBrwSaid:aCols[nAc][nPDtAbas]))
		While !EoF() .And. ;
			TQL->TQL_FILIAL+TQL->TQL_POSTO+TQL->TQL_LOJA+TQL->TQL_TANQUE+TQL->TQL_BOMBA+DTOS(TQL->TQL_DTCOLE) == xFilial("TQL")+M->TTH_POSTO+M->TQL_LOJA+M->TTH_TANQUE+M->TTH_BOMBA+DTOS(oBrwSaid:aCols[nAc][nPDtAbas])
			If aCols[nAc][nPHrAbas] > TQL->TQL_HRINIC .And. Empty(TQL->TQL_HRFIM)
				lTemAfer := .T.
			ElseIf oBrwSaid:aCols[nAc][nPHrAbas] > TQL->TQL_HRINIC .And. !Empty(TQL->TQL_HRFIM) .And. oBrwSaid:aColsoBrwSaid:aCols[nAc][nPHrAbas] < TQL->TQL_HRFIM
				lTemAfer := .T.
			EndIf
			TQL->(dbSkip())
		End
	EndIf

	If !lTemAfer
		ShowHelpDlg(STR0138,{STR0154},2,{STR0155},2)//"ATENCAO"###"Tanque/Bomba não possui aferição para data do abastecimento."###"Inclua uma aferição para a mesma data e com hora infeior ao abastecimento ou selecione um Tanque/Bomba aferido."
		Return .F.
	EndIf
EndIf

lUpdaCols := .F.
If !oBrwSaid:aCols[nAc,Len(oBrwSaid:aCols[nAc])] .And. Type("aColsSaid") == "A"
	If Len(oBrwSaid:aCols) >= nAc .And. Len(aColsSaid) >= nAc
		lUpdaCols := .F.
		For nInd := 1 To Len(oBrwSaid:aCols[nAc])
			If oBrwSaid:aCols[nAc,nInd] <> aColsSaid[nAc,nInd]
				lUpdaCols := .T.
				Exit
			EndIf
		Next nInd
	Else
		lUpdaCols := .T.
	EndIf
EndIf
If lUpdaCols
	aRetDtPar := NgDtAbas()
	If aRetDtPar[3]
		If ValType(aRetDtPar[2]) == "C"
			If DtoS(oBrwSaid:aCols[nAc][nPDtAbas])+oBrwSaid:aCols[nAc][nPHrAbas] <  DtoS(aRetDtPar[1])+aRetDtPar[2]
				ApMsgStop(STR0090+; //"Nenhuma movimentação de abastecimento poderá ser processada antes da data/hora: "
							DtoC(aRetDtPar[1])+" "+aRetDtPar[2]+".",STR0037) //"ATENÇÃO"
				Return .F.
			EndIf
		Else
			If oBrwSaid:aCols[nAc][nPDtAbas] <  aRetDtPar[1]
				ApMsgStop(STR0091+; //"Nenhuma movimentação de abastecimento poderá ser processada antes da data: "
							DtoC(aRetDtPar[1])+".",STR0037) //"ATENÇÃO"
				Return .F.
			EndIf
		EndIf
	EndIf
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MNT656QV  ³ Autor ³ Evaldo Cevinscki Jr.  ³ Data ³ 03/06/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Checa se houve quebra/virada de contador e permite lancamen³±±
±±³          ³ to com contador menor que anterior                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT656QV(cFrt,cDtAba,cHrAba)
Local lRetQV := .F.
Local aArea := GetArea()
cFil := MNTA656FIL(cFrt,StoD(cDtAba),cHrAba)

dbSelectArea("STP")
dbSetOrder(5)
dbSeek(xFilial("STP",cFil)+cFrt+cDtAba+cHrAba,.T.)
If !Found()
	dbSkip(-1)
	If !EoF() .And. !BoF() .And. STP->TP_FILIAL = xFilial("STP",cFil) .And.;
		STP->TP_CODBEM == cFrt
		If STP->TP_TIPOLAN $ "QV"
			lRetQV := .T.
		EndIf
	EndIf
Else
	lRetQV := .T.
EndIf
RestArea(aArea)
Return lRetQV

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MNT656GAT ³ Autor ³ Marcos Wagner Junior  ³ Data ³02/09/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz alteracoes no dicionario                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT656GAT()

If lTemTTX
	aCols[n][nDesMoti] := NGSEEK('TTX',M->TTH_MOTIV2,1,'TTX->TTX_DESCRI')
EndIf

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNA656EXIST³ Autor ³Heverson Vitoreti      ³ Data ³ 15/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao da Frota                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA656                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT656EXIST()
Local lATIVO := .F.

If FunName() == "MNTA656"
	cFrota655 := If(ReadVar()=='M->TQN_FROTA',M->TQN_FROTA,oBrw1:aCols[n][nPOSFROTA])
	dbSelectArea("ST9")
	dbSetOrder(1)
	dbSeek(cFiliST9+cFrota655)
	cPlaca655 := ST9->T9_PLACA
	cFILBEM := ST9->T9_FILIAL
ElseIf FunName() == "MNTA655"
	cFrota655 := M->TQN_FROTA
	cPlaca655 := M->TQN_PLACA
Else
	cFrota655 := If(ReadVar()=='M->TQN_FROTA',M->TQN_FROTA,aCols[n][nPOSFROTA])
	dbSelectArea("ST9")
	dbSetOrder(16)
	dbSeek(cFrota655)
	cPlaca655 := ST9->T9_PLACA
EndIf

If Inclui
	M->TQN_AUTO   := "2"
	M->TQN_USUARI := SubStr(cUsuario,7,15)
EndIf
If !(FunName() == "MNTA656")
	dbSelectArea("ST9")
	dbSetOrder(16)
	IF dbSeek(cFrota655)
		cFILBEM := ST9->T9_FILIAL
	Else
		HELP(" ",1,STR0037,,STR0151,3,1) //"ATENÇÃO"###"Veiculo não cadastrado."
		Return .F.
	EndIf
EndIf

dbSelectArea("ST9")
dbSetOrder(1)
If !dbSeek(cFilBem+cFrota655)
	HELP(" ",1,STR0037,,STR0151,3,1) //"ATENÇÃO"###"Veiculo não cadastrado."
	Return .F.
Else
	
	aCols[n,nPOSPLACA]  := ST9->T9_PLACA
	aCols[n,nPosDesFro] := ST9->T9_NOME
	M->TQN_DESFRO		:= ST9->T9_NOME
	Store 0 To M->TQN_HODOM,M->TQN_HODANT,M->TQN_KMROD,M->TQN_VARDIA
	M->TQN_DTAANT		:= Ctod("  /  /    ")
	M->TQN_HRAANT		:= "  :  "
	M->TQN_MEDIA		:= 0.00
	TIPOACOM := If(st9->t9_temcont = "S",.T.,.F.)

	If M->TQN_FROTA != aCols[n][nPOSFROTA]
		aCols[n][nPOSLUBRI]	:= Space(Len(SB1->B1_COD))
		nLubDig				:= nLubDig - aCols[n][nPOSQUALU] //M->TPE_AJUSCO
		aCols[n][nPOSQUALU]	:= 0.00
		//Atualiza os campos Digitado e Diferença quando alterado o bem
		oLubDig:Refresh()
		oLubDif:Refresh()
	EndIf

	If FunName() == "MNTA655"
		If TIPOACOM .And. lSegCont //Verifica se o campo existe (UPDITA02)
			M->TQN_DTAAN2 := STOD("  /  /  ")
			M->TQN_HRAAN2 := "  :  "
			Store 0 To M->TQN_HODAN2,M->TQN_VARDI2,M->TQN_KMROD2,M->TQN_MEDI2,M->TQN_POSCO2
			MNT655ANT(0)

			MNT655AN2()
			oPanel2:Show()
		Else
			M->TQN_HODOM := 0
			oPanel2:Hide()
		EndIf
	EndIf
EndIf

If ST9->T9_SITBEM != 'A'
	While !EoF() .And. ST9->T9_PLACA == cPlaca655
		If ST9->T9_SITBEM = 'A'
			lATIVO := .T.
		EndIf
		dbSkip()
	End
Else
	lATIVO := .T.
EndIf
If !lATIVO
	HELP(" ",1,STR0037,,STR0152,3,1) //"ATENÇÃO"###"Veículo Inativo!"
	Return .F.
EndIf

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNA656PLACA³ Autor ³Heverson Vitoreti      ³ Data ³ 15/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao da placa                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA656                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT656PLACA()
Local lRETVH := .T.
LOcal lAtivo := .F.
Local aOldArea := GetArea()
Local lDtvSgCnt  := NGCADICBASE("TPE_SITUAC","A","TPE",.F.) //Indica se permite desativar segundo contador

cPlaca655 := M->TQN_PLACA

dbSelectArea("ST9")
dbSetOrder(14)
dbSeek(cPlaca655)

cFilBem := ST9->T9_FILIAL

If cPlaca655 <> ST9->T9_PLACA
	HELP(" ",1,STR0037,,STR0150,3,1) //"ATENÇÃO"###"Placa Invalida."
	lRETVH := .F.
EndIf

If ST9->T9_SITBEM != 'A'
	While !EoF() .And. ST9->T9_PLACA == cPlaca655
		If ST9->T9_SITBEM = 'A'
			cFilBem := ST9->T9_FILIAL
			M->TQN_FROTA := ST9->T9_CODBEM
			lATIVO := .T.
		EndIf
		dbSkip()
	End
Else
	M->TQN_FROTA := ST9->T9_CODBEM
	lATIVO := .T.
EndIf
If Inclui
	M->TQN_AUTO   := "2"
	M->TQN_USUARI := SubStr(cUsuario,7,15)
EndIf

If ST9->T9_TEMCONT == "S"
	TIPOACOM := .T.
EndIf

//FindFunction remover na release GetRPORelease() >= '12.1.027'
If FindFunction("MNTCont2")
	TIPOACOM2 := MNTCont2(cFilBem, ST9->T9_CODBEM)
Else
	dbSelectArea("TPE")
	dbSetOrder(1)
	If dbSeek(xFilial("TPE",cFilBem)+ST9->T9_CODBEM)
		TIPOACOM2 := IIf(lDtvSgCnt, TPE->TPE_SITUAC == "1", .T.)
	Else
		TIPOACOM2 := .F.
	EndIf
EndIf

RestArea(aOldArea)

If lRETVH
	lRETVH := MNT656COM()
EndIf

Return lRETVH

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNT656BLOK ³ Autor ³ Marcos Wagner Junior  ³ Data ³ 28/03/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Bloqueia o campo caso o Produto nao seja preenchido          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA656                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT656BLOK()

	Local lCanAplPrd := .T.

	If GetNewPar("MV_NGMNTCC","N") == "S"

		If !( lCanAplPrd := ( NGSeek('ST9', oBrw1:aCols[n, nPosFrota], 1,'ST9->T9_LUBRIFI') == '1' ) )

			ShowHelpDlg(STR0037, { STR0181 }, 1, { STR0182 + NGRetTitulo('T9_LUBRIFI') + STR0183 })

			//"Atenção" ## "Este bem não permite aplicação de produto."
			//"Verifique o campo " ## " no cadastro de bens."
		EndIf
	EndIf

	lLub := !Empty(M->TT_CODIGO) .And. lCanAplPrd

Return lCanAplPrd

//---------------------------------------------------------------------
/*/{Protheus.doc} fObrigCpos
Carrega variáveis PRIVATE que indicam se o campo montado na mão em tela
é obrigatório ou não.

@author Wagner Sobral de Lacerda
@since 17/07/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fObrigCpos()

	// Salve a área atual
	Local aArea     := GetArea()
	Local cCampoSX3 := ""

	lObrigResp := .F.
	cCampoSX3  := Posicione("SX3",2, "TTA_RESPON", "X3_CAMPO")
	If !Empty( cCampoSX3 )
		lObrigResp := X3Obrigat(cCampoSX3)
	EndIf

	// Devolve a área
	RestArea(aArea)

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fSaiChange
Carrega campo data do abastecimento no getdados da tela de saída de combutível.

@author Cezar Augusto Padilha
@since 04/12/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fSaiChange()
Local aOldArea := GetArea()
Local nT := oBrwSaid:nAt

If oBrwSaid:aCols[nT][nPDtAbas] > dDataAbast .Or. Empty(oBrwSaid:aCols[nT][nPDtAbas])
	oBrwSaid:aCols[nT][nPDtAbas] := dDataAbast
EndIf

oBrwSaid:oBrowse:Refresh()
RestArea(aOldArea)
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} Val656DTHR
Valida data e hora informada para verficicar se já não há abastecimentos ou saídas para
o mesmo momento da bomba.

@Param cVar  = conteúdo a ser validado
	   nOpcv = opção da validação (1=Data, 2=Hora)
	   lTQN  = indica qual array deve consistir, se for abastecimento (TQN) lTQN = .T.
@author Cezar Augusto Padilha
@since 05/12/2012

@return .T.
/*/
//---------------------------------------------------------------------
Function Val656DTHR(cVar,nOpcv,lTQN)
Local nAc
Local nPHrPAc := aSCAN(oBrw1:aHeader,{|x| Trim(Upper(x[2])) == "TQN_HRABAS"})
Local nPDtPAc := aSCAN(oBrw1:aHeader,{|x| Trim(Upper(x[2])) == "TQN_DTABAS"})
Local aSaiCols := {}
Local lRet := .T.

If Type("oBrwSaid") == "O" // Verifica e carrega se houver informações da tela de saídas
	aSaiCols := oBrwSaid:aCols
Else
	aSaiCols := aAferTTH
EndIf

If nOpcv == 1
	If cVar > dDataAbast
		MsgStop(STR0083,STR0037) //"Data do Abastecimento não pode ser maior que a data de encerramento da folha."###"ATENÇÃO"
		Return .F.
	EndIf
EndIf
If lTQN // Validações dos campos data e hora da primeira tela (tabela TQN)
	nAc := oBrw1:nAt
	If nOpcv == 1 // Valida Data
		nPos := aScan(aSaiCols,{|x| DtoS(x[nPDtAbas])+x[nPHrAbas] == DtoS(cVar)+oBrw1:aCols[nAc][nPHrPAc]})
		If !Empty(oBrw1:aCols[nAc][nPDtPAc])
			If nPos > 0 .And. !aSaiCols[nPos][Len(aSaiCols[nPos])]
				lRet := .F.
			EndIf
		EndIf
		nPos := aScan(oBrw1:aCols,{|x| DtoS(x[nPDtPAc])+x[nPHrPAc] == DtoS(cVar)+oBrw1:aCols[nAc][nPHrPAc]})
		If nPos > 0 .And. nPos != nAc .And. !oBrw1:aCols[nPos][Len(oBrw1:aCols[nPos])]
			lRet:= .F.
		EndIf
	ElseIf nOpcv == 2 // Valida Hora
		If oBrw1:aCols[nAc][nPDtPAc] == dDataAbast .And. cVar > cHrAb656
			MsgStop(STR0084,STR0037) //"Hora do Abastecimento não pode ser maior que a hora de encerramento da folha."###"ATENÇÃO"
			Return .F.
		EndIf
		nPos := aScan(aSaiCols,{|x| DtoS(x[nPDtAbas])+x[nPHrAbas] == DtoS(oBrw1:aCols[nAc][nPDtPAc])+cVar})
		If nPos > 0 .And. !aSaiCols[nPos][Len(aSaiCols[nPos])]
			lRet:= .F.
		EndIf
		nPos := aScan(oBrw1:aCols,{|x| DtoS(x[nPDtPAc])+x[nPHrPAc] == DtoS(oBrw1:aCols[nAc][nPDtPAc])+cVar})
		If nPos > 0 .And. nPos != nAc .And. !oBrw1:aCols[nPos][Len(oBrw1:aCols[nPos])]
			lRet:= .F.
		EndIf
	EndIf
Else // Validações para os campas de Data e Hora da tela de saídas (TTH)
	nAc := oBrwSaid:nAt
	If nOpcv == 1 // Valida Data
		nPos := aScan(oBrw1:aCols,{|x| DtoS(x[nPDtPAc])+x[nPHrPAc] == DtoS(cVar)+aSaiCols[nAc][nPHrAbas]})
		If !Empty(aSaiCols[nAc][nPHrAbas])
			If nPos > 0 .And. !oBrw1:aCols[nPos][Len(oBrw1:aCols[nPos])]
				lRet := .F.
			EndIf
		EndIf
		nPos := aScan(aSaiCols,{|x| DtoS(x[nPDtAbas])+x[nPHrAbas] == DtoS(cVar)+aSaiCols[nAc][nPHrAbas]})
		If nPos > 0 .And. nPos != nAc .And. !aSaiCols[nPos][Len(aSaiCols[nPos])]
			lRet:= .F.
		EndIf
	ElseIf nOpcv == 2 // Valida Hora
		If aSaiCols[nAc][nPDtAbas] == dDataAbast .And. cVar > cHrAb656
			MsgStop(STR0084,STR0037) //"Hora do Abastecimento não pode ser maior que a hora de encerramento da folha."###"ATENÇÃO"
			Return .F.
		EndIf
		If (!f656VBomba(cPosto,cLoja,cTanque,cBomba,aSaiCols[nAc][nPDtAbas],cVar))// Consiste se há saídas para a data e hora já gravadas na base de dados (TTV)
			MsgStop(STR0161) //"Já existe um lançamento para essa bomba com mesma data e hora."
			Return .F.
		EndIf
		nPos := aScan(oBrw1:aCols,{|x| DtoS(x[nPDtPAc])+x[nPHrPAc] == DtoS(aSaiCols[nAc][nPDtAbas])+cVar})
		If nPos > 0 .And. !oBrw1:aCols[nPos][Len(oBrw1:aCols[nPos])]
			lRet:= .F.
		EndIf
		nPos := aScan(aSaiCols,{|x| DtoS(x[nPDtAbas])+x[nPHrAbas] == DtoS(aSaiCols[nAc][nPDtAbas])+cVar})
		If nPos > 0 .And. nPos != nAc .And. !aSaiCols[nPos][Len(aSaiCols[nPos])]
			lRet:= .F.
		EndIf
	EndIf
EndIf
aSaiCols := {}

If !lRet
	MsgStop(STR0161)  //"Já existe um lançamento para essa bomba com mesma data e hora."
	Return lRet
EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} f656VBomba
Valida há algum abastecimento ou saída superior ou igual a data e hora
que esta sendo reportada.

@Param cPosto = Código do Posto
	   cLoja = Código da Loja
	   cTanque = Código do tanque do posto
	   cBomba = Código da bomba do tanque
	   dData = Data a ser verificada
	   cHora = Hora a ser verificada
	   cEmp = Código da empresa
	   cFil = Código da filial
@author Cezar Augusto Padilha
@since 06/12/2012

@return .T.
/*/
//---------------------------------------------------------------------
Function f656VBomba(cPosto,cLoja,cTanque,cBomba,dData,cHora,cEmp,cFil)
Local lRet := .T.
Local cAliasQry, cQuery
Local aArea := GetArea()

cAliasQry := GetNextAlias()
cQuery := " SELECT COUNT(*) AS TTV_COUNT FROM " + NGRetX2("TTV",cEmp) + " TTV "
cQuery += " WHERE TTV.TTV_POSTO = " + ValToSql(cPosto)
cQuery += "		AND TTV.TTV_LOJA = " + ValToSql(cLoja)
cQuery += "		AND TTV.TTV_TANQUE = " + ValToSql(cTanque)
cQuery += "		AND TTV.TTV_BOMBA = " + ValToSql(cBomba)
cQuery += "		AND TTV.TTV_DATA||TTV.TTV_HORA = " + ValToSql(DTOS(dData)+cHora)
cQuery += "		AND TTV.TTV_FILIAL = " + ValToSql(NGTROCAFILI("TTV",cFil,cEmp)) + " AND TTV.D_E_L_E_T_ = '' "
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

dbSelectArea(cAliasQry)
dbGoTop()
If !EoF() .And. (cAliasQry)->TTV_COUNT > 0
	lRet := .F.
EndIf
(cAliasQry)->(dbCloseArea())

RestArea(aArea)
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} f656VBomba
Valida se o gatilho do campo TQN_VNPJ deve ser disparado


@author Cezar Augusto Padilha
@since 06/12/2012

@return .T.
/*/
//---------------------------------------------------------------------
Function MNT656CNPJ()

	Local cTQFCnpj := ""

	//Verifica se o CNPJ ja foi informado para este posto
	If !Empty(M->TQN_POSTO) .And. !Empty(M->TQN_LOJA)
		cTQFCnpj := NGSEEK("TQF",M->TQN_POSTO+M->TQN_LOJA,1,"TQF_CNPJ",xFilial("TQF"))
		If cTQFCnpj == M->TQN_CNPJ
			Return .F.
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA656FOL
Verifica chave única da tabela TTA

@author Pedro Henrique Soares de Souza
@since 15/09/2015
/*/
//---------------------------------------------------------------------
Function MNTA656FOL( cPostoVal, cLojaVal, cFolhaVal )

	Local aOldArea := GetArea()
	Local aEmpFil	 := {}

	Local nI, lRet := .T.

	If !Empty(cPostoVal) .And. !Empty(cLojaVal) .And. !Empty(cFolhaVal)

		dbSelectArea("TTA")
		dbSetOrder(1)
		If !( lRet := !dbSeek(xFilial("TTA") + cPostoVal + cLojaVal + cFolhaVal) )

			ShowHelpDlg(STR0037, { STR0156 }, 1, { STR0157 })

			//"Atenção" ## "Esta Folha já foi informada em outro abastecimento para este posto e loja."
			//"Altere o numero da Folha."
		EndIf

		//Verifica se já existe abastecimento na TQN com mesma nota fiscal
		If lRet .And. STR0005 $ nLanca //"Abastecimento"

			aAdd(aEmpFil, SM0->M0_CODIGO)
			For nI := 1 To Len(aEmpFil)

				cAliasQry := GetNextAlias()

				cQuery := " SELECT 1 "
				cQuery += "   FROM " + RetSqlName("TQN")
				cQuery += "  WHERE TQN_FILIAL  = '" + FwxFilial("TQN") + "' "
				cQuery += "    AND TQN_POSTO   = " + ValToSql(cPosto)
				cQuery += "    AND TQN_LOJA    = " + ValToSql(cLoja)
				cQuery += "    AND TQN_NOTFIS  = " + ValToSql(cFolha)
				//Deve ser avaliado na SS 033890 se deve ser mantido por conta da implementação no padrão.
				//cQuery += "    AND TQN_FILORI = '" + cFilAnt + "'"
				cQuery += "    AND D_E_L_E_T_ = ' ' "
				cQuery += "  ORDER BY TQN_FILIAL,TQN_POSTO,TQN_LOJA,TQN_DTABAS,TQN_HRABAS"
				cQuery := ChangeQuery(cQuery)

				dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery),cAliasQry, .F., .T.)

				If !( lRet := (cAliasQry)->( EoF() ) )

					ShowHelpDlg(STR0037, { STR0156 }, 1, { STR0157 })

					//"Atenção"###"Esta Folha já foi informada em outro abastecimento para este posto e loja."
					//"Altere o numero da Folha."
				EndIf

				(cAliasQry)->( dbCloseArea() )
			Next nI
		EndIf
	EndIf

	RestArea(aOldArea)
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT656ValF()
Utiliza o X3_VALID e/ou X3_VLDUSER do campo TTA_FOLHA se estiverem preenchidos

@author Rodrigo Luan Backes
@since 01/02/2015
/*/
//---------------------------------------------------------------------
Function MNT656ValF()

If (Empty(cFolValid) .And. Empty(cFolVldUsr))
	If (!Empty(cPosto) .And. !Empty(cLoja))
		Return MNT656LTB(2)
	Else
		Return .T.
	EndIf
Else
	If(Empty(cFolValid))
		Return &(cFolVldUsr) //Executa o conteúdo do ValidUser
	Else
		If(Empty(cFolVldUsr))
			Return &(cFolValid) //Executa o conteúdo do Valid
		Else
			Return &(cFolValid + " .And. " + cFolVldUsr) //Executa o conteúdo do Valid e do ValidUser
		EndIf
	EndIf
EndIf

Return .T.

//----------------------------------------------------------------------------
/*/{Protheus.doc} MNT656VDTC()
Válida tanque de Combustivel. Verificando se o Combustível do tanque do posto
é incompatível com o combustível do bem.

Essa função foi feita para facilitar o entendimento das condições utilizada
na validação.

@param  cCodCom -> Código do Combustivel.

@author Maicon André Pinheiro
@since 25/02/2016
@return lComb   -> Compatibilidade do combustivel do Tanque X Bem

/*/
//-----------------------------------------------------------------------------
 Function MNT656VDTC(cCodCom)

	Local lComb   := .F.
	Local cFilEmp  := ""

	If Type('cFilBens') == 'U'
		cFilBens := ""
	EndIf

	cFilEmp := IIf(Empty(cFilBens),xFilial("ST9"),cFilBens)

    If ReadVar() == 'M->TQN_PLACA' .And. !Empty(M->TQN_PLACA)
    	lComb := MNT656BSPL(cFilEmp,cCodCom)
    Else
    	lComb := MNT656BSFR(cFilEmp,cCodCom,"1")
	EndIf

 Return lComb

//------------------------------------------------------------------------
/*/{Protheus.doc} MNT656BSFR
Busca a capacidade do tanque de combustivel utilizando o campo frota.

@param cFilEmp -> Filial do Bem/Placa que está executando o abastecimento.
       cCodCom -> Código do Combustivel.
       cTipCom -> Tipo do Produto (1=Combustível/2=Aditivo)

@author Maicon André Pinheiro
@since 25/02/2016
@return lComb   -> Compatibilidade do combustivel do Tanque X Bem

/*/
//------------------------------------------------------------------------
Function MNT656BSFR(cFilEmp, cCodCom, cTipCom)

	Local cFrota 	:= If( ReadVar() == 'M->TQN_FROTA' , M->TQN_FROTA , aCols[n][nPOSFROTA])
	Local lComb  	:= .F.
	Local cChaveTT8	:= ""
	Local nOrder


	dbSelectArea("ST9")
	dbSetOrder(1)
	If dbSeek( cFilEmp + cFrota )


		cChaveTT8	:= cFilEmp + cFrota + cTipCom + IIf(Empty(cCodCom),"",cCodCom)
		nOrder		:= 2 //TT8_FILIAL+TT8_CODBEM+TT8_TIPO+TT8_CODCOM

		dbSelectArea("TT8")
		dbSetOrder(nOrder)
		If dbSeek( cChaveTT8 )
			lComb   := .T.
			nCapTan := TT8->TT8_CAPMAX
		EndIf

	EndIf

Return lComb

//-------------------------------------------------------------------
/*/{Protheus.doc} MNT656BSPL
Busca a capacidade do tanque de combustivel utilizando o campo Placa.

@param cFilEmp -> Filial do Bem/Placa que está executando o abastecimento.
       cCodCom -> Código do Combustivel.

@author Maicon André Pinheiro
@since 25/02/2016
@return lComb   -> Compatibilidade do combustivel do Tanque X Bem
/*/
//-------------------------------------------------------------------
Function MNT656BSPL(cFilEmp, cCodCom)

	Local lComb  	:= .F.
	Local cPlaca 	:= If( ReadVar() == 'M->TQN_PLACA', M->TQN_PLACA, aCols[n][nPOSPLACA] )
	Local cChaveTT8	:= ""
	Local nOrder

	dbSelectArea("ST9")
	dbSetOrder(14)

	If dbSeek( cPlaca )

		cChaveTT8	:= cFilEmp + ST9->T9_CODBEM + "1" + cCodCom
		nOrder		:= 2

		dbSelectArea("TT8")
		dbSetOrder(nOrder)
		If dbSeek( cChaveTT8 )
			lComb   := .T.
			nCapTan := TT8->TT8_CAPMAX
		EndIf

	EndIf
Return lComb

//-------------------------------------------------------------------
/*/{Protheus.doc} MNT656F6
Consulta específica F6 do campo TT_CODIGO para trazer os lubrificantes da tabela TZZ.

@author Rodrigo Luan Backes
@since 31/05/2016
@return nil
/*/
//-------------------------------------------------------------------
Static Function MNT656F6()

	Local bF6		:= SetKey(VK_F6)
	Local lCONDP	:= .T.
	Local lUsouF6	:= .F.
	Local lComb		:= .F.

	If ReadVar() == "M->TT_CODIGO"
		//Consulta padrão sobre a TZZ (F6)
		lCONDP := CONPAD1(NIL,NIL,NIL,"TZZ   ",NIL,NIL,.F.)
		If lCONDP //Se confirmou a consulta

			lComb := MNT656BSFR(cFiliST9,TZZ->TZZ_PRODUT,"2")
			If lComb
				If  nLubInf < nLubDig
					ApMsgStop(STR0049+AllTrim(Str(nLubDig))+chr(13)+;		//"A quantidade de Produto digitado:"
							STR0048+AllTrim(Str(nLubInf))+".",STR0037)		//"esta diferente do total informado: "###"ATENÇÃO"
				ElseIf nCapTan < aCols[n][nPOSQUALU]
					ApMsgStop(STR0184,STR0037)		//"A quantidade de aditivo supera a capacidade máxima permitida."###"ATENÇÃO"
				Else
					M->TT_CODIGO := TZZ->TZZ_PRODUT
					lUsouF6 := .T.
				EndIf
			Else
				ApMsgStop(STR0185,STR0037)			//"Produto (Aditivo) é incompatível com o tanque do bem."###"ATENÇÃO"
				M->TT_CODIGO := Space( TamSX3('TT_CODIGO')[1] )
			EndIf
		EndIf
	EndIf
	SetKey(VK_F6, bF6)

Return .T.

//------------------------------------------------------------------------
/*/{Protheus.doc} MNT656BCAD
Busca a capacidade do tanque de combustivel (Aditivo) utilizando o
campo frota.

@author Rodrigo Luan Backes
@since 28/07/2016
@return lComb   -> Compatibilidade do combustivel do Tanque X Bem

/*/
//------------------------------------------------------------------------
Function MNT656BCAD()

	Local cFrota 	:= aCols[n][nPOSFROTA]
	Local lComb  	:= .T.
	Local cChaveTT8	:= ""
	Local nCodCom	:= aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TT_CODIGO"})
	Local cTipCom	:= "2"	// É chumbado "2" pois valida apenas Produto/Aditivo

	dbSelectArea("ST9")
	dbSetOrder(1)
	If dbSeek( xFilial("ST9") + cFrota )

		dbSelectArea("TT8")
		dbSetOrder(2)

		cCodCom := aCols[n][nCodCom]
		cChaveTT8	:= xFilial("TT8") + cFrota + cTipCom + cCodCom

		If dbSeek( cChaveTT8 )
			nCapTan := TT8->TT8_CAPMAX
			If nCapTan < M->TPE_AJUSCO
				ApMsgStop(STR0184,STR0037)		//"A quantidade de aditivo supera a capacidade máxima permitida."###"ATENÇÃO"
				lComb := .F.
			EndIf
		EndIf
	EndIf

Return lComb

//-------------------------------------------------------------------
/*/{Protheus.doc} MNT656CMB

Função para buscar o combustível utilizado no abastecimento do folha.
Utilizada quando Não estiver em uma inclusão.

@author Maicon André Pinheiro
@since 24/10/2016
@return cComb
/*/
//-------------------------------------------------------------------
Function MNT656CMB()

	Local cComb     := ""
	Local cQuery    := ""
	Local cAliasQry := GetNextAlias()

	cQuery := " SELECT TQN_CODCOM "
	cQuery += "   FROM " + RetSqlName("TQN")
	cQuery += "  WHERE TQN_FILIAL  = " + ValToSql(xFilial("TQN"))
	cQuery += "    AND TQN_POSTO   = " + ValToSql(cPosto)
	cQuery += "    AND TQN_LOJA    = " + ValToSql(cLoja)
	cQuery += "    AND TQN_NOTFIS  = " + ValToSql(cFolha)
	//Deve ser avaliado na SS 033890 se deve ser mantido por conta da implementação no padrão.
	//cQuery += "    AND TQN_FILORI = " + ValToSql(cFilAnt)
	cQuery += "    AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	dbGoTop()
	If !EoF()
		cComb := (cAliasQry)->TQN_CODCOM
	EndIf
	(cAliasQry)->(dbCloseArea())

Return cComb

//-------------------------------------------------------------------
/*/{Protheus.doc} MNT656COMB

Verifica o combustível digitado.

@author Maicon André Pinheiro
@since 24/10/2016
@return cComb
/*/
//-------------------------------------------------------------------
Function MNT656COMB(oOwner)

	Local aArea    := getArea()
	Local aAreaTQI := TQI->(GetArea())
	Local aAreaTT8 := TT8->(GetArea())

	Default oOwner := oBrw1

	If Empty(NGSEEK('TQI',cPosto+cLoja+cTanque+cTTAComb,1,'TQI->TQI_CODCOM')) // Valida Combustível x Tanque posto
		MsgStop(STR0212,STR0037) //"Combustível do abastecimento incompatível com o tanque do posto."###"ATENÇÃO"
		Return .F.
	EndIf

	//Valida novamente o tanque
	cCombust := ""
	If !MNT656TABO(1)
		Return .F.
	EndIf

	If !Empty(oOwner:aCols[1][nPOSFROTA]) // Verifica se está alterando o combustível depois de informado o bem.
		cChaveTT8 := xFilial("TT8") + oOwner:aCols[1][nPOSFROTA] + "1" + cTTAComb
		dbSelectArea("TT8")
		dbSetOrder(2)
		If !dbSeek( cChaveTT8 )
			MsgStop(STR0054,STR0037) //"Combustível do tanque do posto é incompatível com o combustível do bem."###"ATENÇÃO"
			Return .F.
		EndIf
	EndIf

	RestArea(aAreaTQI)
	RestArea(aAreaTT8)
	RestArea(aArea)

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} fLoadTTHC
Soma todas as saídas de combustível da folha editada

@author Wexlei Silveira
@since 06/04/2017
@return nSomaComb, Total de combustível de saída da folha
/*/
//-------------------------------------------------------------------
Static Function fLoadTTHC()

	Local aArea     := GetArea()
	Local nSaida
	Local nSomaComb := 0
	Local nSaiQnt   := 0
	
	If Type( 'aAferTTH' ) == 'A' .And. Type( 'aHeadTTH' ) == 'A'
		
		nSaiQnt := aSCAN( aHeadTTH, { |x| Trim( Upper( x[ 2 ] ) ) == 'TTH_QUANT' } )
		
		If nSaiQnt > 0
			
			For nSaida := 1 To Len( aAferTTH )

				nSomaComb += aAferTTH[ nSaida, nSaiQnt ]

			Next nSaida

		EndIf
		
	EndIf

	RestArea( aArea )

Return nSomaComb

//-------------------------------------------------------------------
/*/{Protheus.doc} MNT656CONT
Valida a sobreposição de contadores na folha de abastecimento.
@author Tainã Alberto Cardoso
@since 28/02/2018
@return lRet
/*/
//-------------------------------------------------------------------
Function MNT656CONT()
	Local lRet := .T.
	Local nX   :=  0
	Local nSegCont  := 0 //Usado para validar segundo contador na getdados
	Local nPriCont  := 0 //Usado para validar primeira contador na getdados
	Local cCodBem := IIf(ReadVar()='M->TQN_FROTA',M->TQN_FROTA,oBrw1:aCols[oBrw1:nAt][nPOSFROTA])
	Local dDataAb := IIf(ReadVar()='M->TQN_DTABAS',M->TQN_DTABAS,oBrw1:aCols[oBrw1:nAt][nPOSDATAB])
	Local cHoraAb := IIf(ReadVar()='M->TQN_HRABAS',M->TQN_HRABAS,oBrw1:aCols[oBrw1:nAt][nPOSHORAB])

	//Busca a posição atual dos contadores digitados.
	If TIPOACOM
		nPriCont  := IIf(ReadVar()='M->TQN_HODOM',M->TQN_HODOM,oBrw1:aCols[oBrw1:nAt][nPOSHODOM])
	EndIf
	If TIPOACOM2
		nSegCont  := IIf(ReadVar()='M->TQN_POSCO2',M->TQN_POSCO2,oBrw1:aCols[oBrw1:nAt][nPOSCONT2])
	EndIf
	For nX := 1 To Len(oBrw1:aCols)

		If oBrw1:nAt == nX .Or. aTail(oBrw1:aCols[nX])
			Loop
		EndIf
		If oBrw1:aCols[nX][nPOSFROTA] == cCodBem

			If oBrw1:aCols[nX][nPOSDATAB] == dDataAb
				If TIPOACOM2 .And. nSegCont > 0
					If oBrw1:aCols[nX][nPOSHORAB] > cHoraAb .And. oBrw1:aCols[nX][nPOSCONT2] < nSegCont
						MsgAlert(STR0235, STR0138) //Contador menor a um abastecimento posterior. ## Atenção
						lRet := .F.
					ElseIf  oBrw1:aCols[nX][nPOSHORAB] < cHoraAb .And. oBrw1:aCols[nX][nPOSCONT2] > nSegCont
						MsgAlert(STR0236, STR0138) //Contador maior a um abastecimento anterior. ## Atenção
						lRet := .F.
					EndIf
				EndIf
				If TIPOACOM .And. nPriCont > 0
					If oBrw1:aCols[nX][nPOSHORAB] > cHoraAb .And. oBrw1:aCols[nX][nPOSHODOM] < nPriCont
						MsgAlert(STR0235, STR0138) //Contador menor a um abastecimento posterior. ## Atenção
						lRet := .F.
					ElseIf oBrw1:aCols[nX][nPOSHORAB] < cHoraAb .And. oBrw1:aCols[nX][nPOSHODOM] > nPriCont
						MsgAlert(STR0236, STR0138) //Contador maior a um abastecimento anterior. ## Atenção
						lRet := .F.
					EndIf
				EndIf

			ElseIf oBrw1:aCols[nX][nPOSDATAB] > dDataAb
				If TIPOACOM2
					If oBrw1:aCols[nX][nPOSCONT2] < nSegCont
						MsgAlert(STR0235, STR0138) //Contador maior a um abastecimento anterior. ## Atenção
						lRet := .F.
					EndIf
				EndIf
				If TIPOACOM
					If oBrw1:aCols[nX][nPOSHODOM] < nPriCont
						MsgAlert(STR0235, STR0138) //Contador maior a um abastecimento anterior. ## Atenção
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
		If !lRet
			Exit
		EndIf

	Next nX

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fAddHead
Adiciona campos no array.

@author  Maicon André Pinheiro
@since   18/04/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function fAddHead(aCabec)

	Local aCampos   := {}
	Local nInd      := 0
	Local nTamTot   := 0
	Local nTam      := 0
	Local nDec      := 0
	Local cTitulo   := ""
	Local cCampo    := ""
	Local cPicture  := ""
	Local cValid    := ""
	Local cUsado    := ""
	Local cTipo     := ""
	Local cF3       := ""
	Local cContexto := ""
	Local cCBox     := ""
	Local cRelac    := ""

	If !lTemTTX
		aCampos := {"TTH_CODCOM","TTH_DTABAS","TTH_HRABAS","TTH_MOTIVO","TTH_QUANT","TTH_MATRIC","TTH_CCUSTO"}
	Else
		aCampos := {"TTH_CODCOM","TTH_DTABAS","TTH_HRABAS","TTH_MOTIV2","TTH_DESCRI","TTH_QUANT","TTH_MATRIC","TTH_CCUSTO"}
	EndIf

	nTamTot := Len(aCampos)
	For nInd := 1 To nTamTot

		cCampo    := aCampos[nInd]
		cTitulo   := Posicione("SX3",2,cCampo,"X3Titulo()")
		cPicture  := X3Picture(cCampo)
		nTam      := TAMSX3(cCampo)[1]
		nDec      := TAMSX3(cCampo)[2]
		cValid    := Posicione("SX3",2,cCampo,"X3_VALID")
		cUsado    := Posicione("SX3",2,cCampo,"X3_USADO")
		cTipo     := Posicione("SX3",2,cCampo,"X3_TIPO")
		cF3       := Posicione("SX3",2,cCampo,"X3_F3")
		cContexto := Posicione("SX3",2,cCampo,"X3_CONTEXT")
		cCBox     := X3CBOX(cCampo)
		cRelac    := Posicione("SX3",2,cCampo,"X3_RELACAO")

		If cCampo == "TTH_MOTIVO"
			cValid := "MNTMOTTH('1',M->TTH_MOTIVO)"
		ElseIf cCampo == "TTH_MOTIV2"
			cValid += " .And. MNT656GAT()"
		EndIf

		aAdd(aCabec,{cTitulo,cCampo,cPicture,nTam,nDec,cValid,cUsado,cTipo,cF3,cContexto,cCBox,cRelac})

	Next nInd

Return aCabec

//-------------------------------------------------------------------
/*/{Protheus.doc} fValidHead
Faz as validações dos dados que irão compor o cabeçalho

@author  Maicon André Pinheiro
@since   18/04/2018
@param   cCampo, C, Coluna da tabela a ser pesquisada no SX3
@return  aArray, a, Array contendo as posições do aHeader
		 Pos, nome, desc, tipo
		 1, cTitulo, Titulo do campo, C
		 2, cCampo, Coluna da tabela, C
		 3, cPicture, Formato do campo, C
		 4, nTam, Tamanho do campo, N
		 5, nDec, Decimal do campo, N
		 6, cValid, Validação do campo, C
		 7, cUsado, Campo usado, C
		 8, cTipo, Tipo do campo, C
		 9, cF3, Consulta padrão, C
		 10,cContexto, Contexto do campo, C
		 11,cCBox, Opções do ComboBox, C
		 12,cRelac, Relação do Campo, C
		 13,cWhen, When do Campo, C
@version P12
/*/
//-------------------------------------------------------------------
Static Function fValidHead(cCampo)

	Local cCstWhen  := ""
	Local cValidAdd := "" // Validação adicional
	Local cTitulo   := Posicione("SX3",2,cCampo,"X3Titulo()")
	Local cPicture  := X3Picture(cCampo)
	Local nTam      := TAMSX3(cCampo)[1]
	Local nDec      := TAMSX3(cCampo)[2]
	Local cValid    := Posicione("SX3",2,cCampo,"X3_VALID")
	Local cUsado    := Posicione("SX3",2,cCampo,"X3_USADO")
	Local cTipo     := Posicione("SX3",2,cCampo,"X3_TIPO")
	Local cF3       := Posicione("SX3",2,cCampo,"X3_F3")
	Local cContexto := Posicione("SX3",2,cCampo,"X3_CONTEXT")
	Local cCBox     := X3CBOX(cCampo)
	Local cRelac    := Posicione("SX3",2,cCampo,"X3_RELACAO")
	Local cWhen     := Alltrim(Posicione("SX3",2,cCampo,"X3_WHEN"))

	If cCampo == "TQN_DTABAS"
		cValidAdd := "MNT656ENC(1) .And. VAL656DTHR(M->TQN_DTABAS,1,.T.) .And. MNT656CONT()"
		If !Empty(cValid)
			cValidAdd += " .And. " + Alltrim(cValid)
		EndIf
		cValid  := cValidAdd
		cTitulo := STR0023 // "Data Abast."
		cRelac  := "dDataAbast"
	ElseIf cCampo == "TQN_HRABAS"
		If !Empty(cValid)
			cValid := Alltrim(cValid) + " .And. MNT656ENC(2) .And. VAL656DTHR(M->TQN_HRABAS,2,.T.) .And. MNT656CONT()"
		EndIf
		cTitulo := STR0024 // "Hora Abast."
	ElseIf cCampo == "TQN_FROTA"
		If !Empty(cValid)
			cValid := Alltrim(cValid) + " .And. MNT656COM() .And. MNT656CONT() .And. MNT656EXIST()"
			cValid += " .And. MNT656WC(.F.)"
		EndIf
		cTitulo := STR0025 // "Veículo"
	ElseIf cCampo == "TQN_PLACA"
		cValid := "MNT656PLACA() .And. MNT656CONT() .And. MNT656WC(.F.)"
	ElseIf cCampo == "TQN_HODOM"
		If !Empty(cValid)
			cValid += " .And. "
		EndIf
		cValid  += "MNT655HOD() .And. MNT656CONT()"
		cTitulo := STR0026 // "Contador"
		cWhen += " .And. MNT656WC(.T.)"
	ElseIf cCampo == "TQN_POSCO2"
		If !Empty(cValid)
			cValid += " .And. "
		EndIf
		cValid +=  "MNT655HOD(2) .And. MNT656CONT() "
	ElseIf cCampo == "TQQ_QUANT"

		cValid := Posicione("SX3",2,"TQN_QUANT","X3_VALID")
		If Inclui
			cValidAdd := StrTran(cValid,'NGMAQUEZERO(M->TQN_QUANT,"TQN_QUANT",.T.)','IF(!Empty(M->TQQ_QUANT),NGMAQUEZERO(M->TQQ_QUANT,"TQQ_QUANT",.T.),.T.)')
		Else
			cValidAdd := StrTran(cValid,'NGMAQUEZERO(M->TQN_QUANT,"TQN_QUANT",.T.)','NGMAQUEZERO(M->TQQ_QUANT,"TQQ_QUANT",.T.)')
		EndIf

		cValid := "MNTA656CAP()"
		If !Empty(cValidAdd)
			cValid += " .And. " + Alltrim(cValidAdd)
		EndIf

		cValid  += " .And. MNTA656MAR(1)"
		cTitulo := STR0027 // "Quantidade"

	ElseIf cCampo == "TT_CODIGO"

		cValid  := "EXISTCPO( 'SB1', M->TT_CODIGO ) .And. MNT656BLOK() .And. MNTA656SER( 6 )"
		cF3     := "SB1"
		cTitulo := STR0018 // Produto

	ElseIf cCampo == "TPE_AJUSCO"
		cValid := "MNT656BCAD() .And. "
		cValid   += "POSITIVO() .And. MNTA656MAR(2)"
		cPicture := "@E 999,999.999"
		nTam     := 9
		nDec     := 3
		cTitulo  := STR0028 // "Qtde Prod."
	ElseIf cCampo == "TQG_ORDENA"
		cTitulo := STR0029 // "T/R"
		nTam    := 1
		cValid  := "MNT656VLUB()"
		cCBox   := STR0030 // "1=Troca;2=Reposicao"
	ElseIf cCampo == "TQN_CODMOT"
		cTitulo := STR0031 // "Motorista"
		cF3     := "DA4"
	ElseIf cCampo == "TL_LOCAL"
		cValid := "NG656ALM()"
	ElseIf cCampo == "TL_LOTECTL"
		cValid := "NG656LOTCT()"
	ElseIf cCampo == "TL_NUMLOTE"
		cValid := "NG656NUMLO()"
	ElseIf cCampo == "TL_LOCALIZ"
		cValid := "NG656LOCAL()"
	ElseIf cCampo == "TTA_CONBOM"
		cTitulo  := STR0153 // "Custo"
		cValid   := "Positivo()"
		cCstWhen := Posicione("SX3",2,cCampo,"X3_WHEN")
	ElseIf cCampo == "TL_MOEDA"
		cWhen := cCstWhen
	ElseIf cCampo == "TP9_VALANO"
		cValid   := STR0032 // "Marcador"
		cPicture := "@E 9,999,999.999"
		nTam     := 11
		nDec     := 3

	ElseIf cCampo == 'TQN_DESFRO'
	
		cTitulo := STR0248 // Desc. Veículo
		cRelac  := ''
	
	ElseIf cCampo == 'TQN_NOMMOT'

		cTitulo := STR0249 // Nome Motorista
		cRelac  := ''

	ElseIf cCampo == 'TT_NOMCODI'
		
		cTitulo := STR0250 // Desc. Produto
		cRelac  := ''

	EndIf

Return {cTitulo,cCampo,cPicture,nTam,nDec,cValid,cUsado,cTipo,cF3,cContexto,cCBox,cRelac,cWhen}

//-------------------------------------------------------------------
/*/{Protheus.doc} MNT656WC
Habilita edição de contador e traz o ultimo registro do historico

@param   lWhen, lógico, Verifica se é chamado pelo When do campo.

@author  Tainã Alberto Cardoso
@since   18/09/2018
@version P12
/*/
//-------------------------------------------------------------------
Function MNT656WC(lWhen)

	Local lRet := .T.
	Local cLubri656		:= AllTrim(STR0018) //"Produto"
	Local cCodVeic := ""
	Local lLanex := cMV_Lanex $ "A"
	Default lWhen := .F.

	If lLanex
		If Len(nLanca) == Len(cLubri656) //Se Lancamento for igual a "Produto"
			lRet := .F.
		EndIf
	EndIf

	If lWhen
		If Type("TIPOACOM") != "U"
			lRet := lRet .And. TIPOACOM
		EndIf
	ElseIf lLanex
		If ReadVar() == "M->TQN_PLACA"
			cCodVeic := ST9->T9_CODBEM
		ElseIf ReadVar() == "M->TQN_FROTA"
			cCodVeic := M->TQN_FROTA
		Else
			cCodVeic := aCols[n][nPOSFROTA]
		EndIf
		If !Empty(cCodVeic)	.And. !Empty(aCols[n][nPOSDATAB]) .And. !Empty(aCols[n][nPOSHORAB])
			If !lRet .Or. ( (nLanca == STR0006 .OR. nLanca == STR0018) .And. Empty(aCols[n][nPOSQUANT]) ) //"Abastecimento+Produto" ## "Produto"
				aCols[n][nPOSHODOM] := NGACUMEHIS(cCodVeic,aCols[n][nPOSDATAB],aCols[n][nPOSHORAB],1,"A")[1]
			EndIf
		EndIf
		lRet := .T.
	EndIf

Return lRet

//----------------------------------------------------------------------------
/*/{Protheus.doc} fValidBrw
Função que agrupa validações realizadas ao salvar a tela de abastecimentos.
@type static

@author Alexandre Santos
@since 30/05/2019

@param 	oDlg1   , Objeto  , Dialog de abastecimentos.
@param  oBrowse , Objeto  , Browse de abastecimentos.
@param  nOpcX   , Númerico, Indica operação realizada.
@return Númerico, Indica se oprocesso foi realizado con êxito.
/*/
//----------------------------------------------------------------------------
Static Function fValidBrw( oDlg1, oBrowse, nOpcX )

	Local nOption := 0

	/* Atualmente a rotina não encontra-se preparada para o processo de alteração
	   quando utilizado apenas o lançamento de produtos, desta forma validações e gravações
	   serão inibidas do processo. */
	If !( nOpcX == 4 .And. nLanca == STR0018 )

		If oBrowse:TudoOk() .And. MNTA656VAL()
			nOption := 1
			oDlg1:End()
		EndIf

	Else

		oDlg1:End()

	EndIf

Return nOption
