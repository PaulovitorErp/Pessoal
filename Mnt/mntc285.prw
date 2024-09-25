#INCLUDE "Protheus.ch"
#INCLUDE "FwMBrowse.CH"
#INCLUDE "MNTC285.ch"
#INCLUDE 'FWMVCDEF.CH'

#DEFINE __OPC_TQB__ 1

#DEFINE __POS_OBJ__ 1
#DEFINE __POS_FIELDS__ 2
#DEFINE __POS_DBF__ 3
#DEFINE __POS_IND__ 4
#DEFINE __POS_VIR__ 5
#DEFINE __POS_ARQ__ 6
#DEFINE __POS_ALIAS__ 7
#DEFINE __POS_LEG__ 8
#DEFINE __POS_ALIDIC__ 9
#DEFINE __POS_FILTER__ 10
#DEFINE __POS_DESIND__ 11
#DEFINE __POS_ORDEM__ 12
#DEFINE __POS_LEG2__ 13

#DEFINE __LEN_MARK__ 1
#DEFINE __LEN_PROP__ 13

#DEFINE __POS_FILSS__ 1
#DEFINE __POS_CODSS__ 2

// Variável do Índice principal das Solicitações de Serviço
Static __nIndTQB := 0

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC285
Consulta de Solicitacoes de Servico

@author Roger Rodrigues
@since 10/10/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Function MNTC285()
	//Guarda variaveis padrao
	Local aNGBEGINPRM := NGBEGINPRM()
	Local i

	//Variaveis da tela
	Local oDlg285
	Local cTitulo := STR0001 //"Consulta de Solicitações de Serviço"

	//Variaveis do combo
	Local oGetSearch, oCBoxSearch, oBtnSearch, cCombo, cGetSearch := Space(100)

	//Variaveis de tamanho de tela e objetos
	Local aSize := {}, aObjects := {}, aInfo := {}, aPosObj := {}

	//Variaveis do MarkBrowse
	Local cMarca   := GetMark()

	//Objetos principais
	Local oSplitVert, oPanelLeft, oPanelRight

	//Botoes para esconder paineis
	Local oHideLeft, oHideRight

	//Parte Esquerda
	Local oPanelT1, oPanelLBtn, oPanelMark, oPanelPesq, oPanelLCont

	//Parte Direita
	Local oSplitHor, oPanelRUp, oPanelT2, oPanelEnc, oPanelR1Btn

	//Botoes da tela
	Local oBtnFil, oBtnImp, oBtnHis, oBtnLeg, oBtnOS
	Local oBtnQuest, oBtnVis, oBtnUser, oBtnDet

	// Botões da EnchoiceBar
	Local aEncBtns := {}

	//Titulo da tela
	Private cCadastro := cTitulo

	//Variaveis da Enchoice
	Private oEncSS
	Private aTela := {}, aGets := {}
	Private aRotina := {{"", "PesqBrw",0, 1},;
	{"", "NGCAD01",0, 2},;
	{"", "NGCAD01",0, 3},;
	{"", "NGCAD01",0, 4},;
	{"", "NGCAD01",0, 5,3}}

	Private aObj285 := Array(__LEN_MARK__,__LEN_PROP__)

	// Variável das cores da tela
	Private aNGColor := aClone( NGCOLOR("10") )

	//Verifica se o update de facilities foi aplicado
	If !FindFunction("MNTUPDFAC") .or. !MNTUPDFAC()
		NGRETURNPRM(aNGBEGINPRM)
		Return .F.
	Endif

	SetVisual(.T.)//Utilizado caso exista algum Ini. Browse

	//Cria estrutura de arquivo temporario e markbrowse
	fCreateTRB(__OPC_TQB__)

	//Carrega Arquivo temporario
	Processa({|| fLoadTRB(__OPC_TQB__)},STR0002,STR0003) //"Aguarde..." ## "Processando Solicitações..."

	// Definição de Botões adicionais na EnchoiceBar
	aAdd(aEncBtns,{"graf3d", {|| MNTC285Ind() }, STR0004, STR0004}) //"Indicadores"

	//Definicao de tamanho de tela e objetos
	aSize := MsAdvSize(,.f.,430)
	Aadd(aObjects,{030,030,.t.,.t.})
	Aadd(aObjects,{100,100,.t.,.t.})
	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObjects,.t.)

	Define MsDialog oDlg285 Title OemToAnsi(cTitulo) From aSize[7],0 To aSize[6],aSize[5] Of oMainWnd Pixel
	oDlg285:lMaximized := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Estrutura da Tela            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSplitVert := TSplitter():New(01,01,oDlg285,10,10)
	oSplitVert:SetOrient(0)
	oSplitVert:Align := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Parte Esquerda - Browse SS   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPanelLeft := TPanel():New(0,0,,oSplitVert,,,,,,10,10,.F.,.F.)
	oPanelLeft:nWidth := (aSize[5]/2)
	oPanelLeft:Align := CONTROL_ALIGN_ALLCLIENT

	oPanelLCont := TPanel():New(0,0,,oPanelLeft,,,,,,10,10,.F.,.F.)
	oPanelLCont:nWidth := (aSize[5]/2)
	oPanelLCont:Align := CONTROL_ALIGN_ALLCLIENT
	oPanelLCont:CoorsUpdate()

	oPanelT1:=TPanel():New(00,00,,oPanelLCont,,,,aNGColor[1],aNGColor[2],200,200,.F.,.F.)
	oPanelT1:nHeight := 25
	oPanelT1:Align := CONTROL_ALIGN_TOP

	@ 003,013 Say OemToAnsi(STR0005) Of oPanelT1 Color aNGColor[1] Pixel //"Solicitações"

	oPanelLBtn:=TPanel():New(00,00,,oPanelLCont,,,,aNGColor[1],aNGColor[2],12,12,.F.,.F.)
	oPanelLBtn:Align := CONTROL_ALIGN_LEFT

	oBtnFil  := TBtnBmp():NewBar("ng_ico_filtro","ng_ico_filtro",,,,{|| fSetFilter(__OPC_TQB__)},,oPanelLBtn,,,STR0006,,,,,"") //"Filtro"
	oBtnFil:Align  := CONTROL_ALIGN_TOP

	oBtnImp  := TBtnBmp():NewBar("ng_ico_imp","ng_ico_imp",,,,{|| fImpSS()},,oPanelLBtn,,,STR0007,,,,,"") //"Imprimir"
	oBtnImp:Align  := CONTROL_ALIGN_TOP

	oBtnHis  := TBtnBmp():NewBar("ng_ico_hist","ng_ico_hist",,,,;
	{|| MNT296HIST(Substr((aObj285[__OPC_TQB__][__POS_ALIAS__])->TQB_TIPOSS,1,1),(aObj285[__OPC_TQB__][__POS_ALIAS__])->TQB_CODBEM)};
	,,oPanelLBtn,,,STR0008,,,,,"") //"Histórico"
	oBtnHis:Align  := CONTROL_ALIGN_TOP

	oBtnOS  := TBtnBmp():NewBar("ng_ico_detalhesos","ng_ico_detalhesos",,,,{|| MNT291OS((aObj285[__OPC_TQB__][__POS_ALIAS__])->TQB_FILIAL,;
	(aObj285[__OPC_TQB__][__POS_ALIAS__])->TQB_SOLICI, .T.)},,oPanelLBtn,,,STR0009,,,,,"") //"Ordens de Serviço"
	oBtnOS:Align  := CONTROL_ALIGN_TOP

	oBtnLeg  := TBtnBmp():NewBar("ng_ico_lgndos","ng_ico_lgndos",,,,{|| A291LEGEND(1,,,{1,3})},,oPanelLBtn,,,STR0010,,,,,"") //"Legenda"
	oBtnLeg:Align	:= CONTROL_ALIGN_TOP

	oPanelMark := TPanel():New(0,0,,oPanelLCont,,,,,,10,10,.F.,.F.)
	oPanelMark:Align := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria Panel com opcoes de pesquisa no MsSelect³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPanelPesq := TPanel():New(0,0,,oPanelMark,,,,,CLR_WHITE,0,15,.f.,.f.)
	oPanelPesq:Align := CONTROL_ALIGN_TOP

	oCBoxSearch := TComboBox():New(02,02,{|u| If(PCount()>0,cCombo:=u,cCombo)},aObj285[__OPC_TQB__][__POS_DESIND__],100,20,oPanelPesq,,;
	{|| fSeekReg(__OPC_TQB__,oCBoxSearch:nAt,@cGetSearch,.F.)},,,,.T.,,,,,,,,,"cCombo")
	oGetSearch  := TGet():New( 02,105,{|u| If(PCount()>0,cGetSearch:=u,cGetSearch)}, oPanelPesq,096,008,,,;
	0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cGetSearch,,,, )
	oBtnSearch  := TButton():New( 002, 202, STR0011,oPanelPesq,{|| fSeekReg(__OPC_TQB__,oCBoxSearch:nAt,Trim(cGetSearch))},; //"Buscar"
	35,11,,,.F.,.T.,.F.,,.F.,,,.F. )
	oCBoxSearch:Select((aObj285[__OPC_TQB__][__POS_ALIAS__])->(IndexOrd()))

	aObj285[__OPC_TQB__][__POS_OBJ__] := TCBrowse():New(0,0,1500,1500,,,,oPanelMark,,,,,,,,,,,,,aObj285[__OPC_TQB__][__POS_ALIAS__],.T.,,,,.T.,.T.)

	aObj285[__OPC_TQB__][__POS_OBJ__]:Align := CONTROL_ALIGN_ALLCLIENT
	aObj285[__OPC_TQB__][__POS_OBJ__]:bChange := {|| fAtuEnc(__OPC_TQB__)}
	aObj285[__OPC_TQB__][__POS_OBJ__]:bLDblClick := {|| fMarkBrw(__OPC_TQB__,cMarca) }
	aObj285[__OPC_TQB__][__POS_OBJ__]:bHeaderClick := { |oObj,nPos| fMrkAll(__OPC_TQB__,nPos,cMarca)}

	//Adiciona Colunas
	//Marcacao
	aObj285[__OPC_TQB__][__POS_OBJ__]:AddColumn(TCColumn():New( " " , {|| fImgLeg(0,__OPC_TQB__) } ,,,,,,.T.,.F.,,,,.T.,))
	//Legenda Situação
	aObj285[__OPC_TQB__][__POS_OBJ__]:AddColumn(TCColumn():New( STR0012 , {|| fImgLeg(1,__OPC_TQB__) } ,,,,,30,.T.,.F.,,,,.T.,)) //"Situação"
	//Legenda Prioridade
	aObj285[__OPC_TQB__][__POS_OBJ__]:AddColumn(TCColumn():New( STR0013 , {|| fImgLeg(2,__OPC_TQB__) } ,,,,,30,.T.,.F.,,,,.T.,)) //"Prioridade"

	//Adiciona Colunas
	For i := 1 to Len(aObj285[__OPC_TQB__][__POS_FIELDS__])
		If aObj285[__OPC_TQB__][__POS_FIELDS__][i][1] != "OK"
			aObj285[__OPC_TQB__][__POS_OBJ__]:AddColumn( TCColumn():New(aObj285[__OPC_TQB__][__POS_FIELDS__][i][3],;
			&("{|| ('"+aObj285[__OPC_TQB__][__POS_ALIAS__]+"')->"+aObj285[__OPC_TQB__][__POS_FIELDS__][i][1]+" }"),;
			aObj285[__OPC_TQB__][__POS_FIELDS__][i][4],,,"LEFT",;
			If(aObj285[__OPC_TQB__][__POS_FIELDS__][i][2] <= 8,35,Nil),.F. ))
		Endif
	Next i

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Botao para esconder parte dir.     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oHideRight := TBtnBmp2():New(01, 01, 05, 05, "fw_arrow_right", , , , {|| fShowHide(1,oPanelRight,oHideRight)}, oPanelLeft, OemToAnsi(STR0014), , .T.) //"Expandir Browse"
	oHideRight:Align := CONTROL_ALIGN_RIGHT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Parte Direita                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPanelRight := TPanel():New(0,0,,oSplitVert,,,,,,10,10,.F.,.F.)
	oPanelRight:nWidth := (aSize[5]/2)
	oPanelRight:Align  := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Botao para esconder parte esq.     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oHideLeft := TBtnBmp2():New(01, 01, 05, 05, "fw_arrow_left", , , , {|| fShowHide(2,oPanelLeft,oHideLeft)}, oPanelRight, OemToAnsi(STR0015), , .T.) //"Esconder Browse"
	oHideLeft:Align := CONTROL_ALIGN_LEFT

	oSplitHor := TSplitter():New(01,01,oPanelRight,10,10)
	oSplitHor:SetOrient(1)
	oSplitHor:Align := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Direita/Cima - Detalhes SS   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPanelRUp := TPanel():New(0,0,,oSplitHor,,,,,,10,10,.F.,.F.)
	oPanelRUp:nHeight := ((aSize[7]-aSize[6])/2)
	oPanelRUp:Align   := CONTROL_ALIGN_TOP

	oPanelT2:=TPanel():New(00,00,,oPanelRUp,,,,aNGColor[2],aNGColor[2],200,200,.F.,.F.)
	oPanelT2:nHeight := 25
	oPanelT2:Align := CONTROL_ALIGN_TOP

	@ 003,013 Say OemToAnsi(STR0016) Of oPanelT2 Color aNGColor[1] Pixel //"Detalhes da Solicitação"

	oPanelR1Btn:=TPanel():New(00,00,,oPanelRUp,,,,aNGColor[1],aNGColor[2],12,12,.F.,.F.)
	oPanelR1Btn:Align := CONTROL_ALIGN_LEFT

	oBtnQuest  := TBtnBmp():NewBar("ng_ico_questionario","ng_ico_questionario",,,,{|| fQuestiSS(__OPC_TQB__)},,oPanelR1Btn,,,STR0017,,,,,"") //"Questionário"
	oBtnQuest:Align  := CONTROL_ALIGN_TOP

	oBtnDet := TBtnBmp():NewBar("ng_ico_tarefas","ng_ico_tarefas",,,,{|| fVisualSS(__OPC_TQB__)},,oPanelR1Btn,,,STR0018,,,,,"") //"Detalhamento Solicitação"
	oBtnDet:Align  := CONTROL_ALIGN_TOP

	oBtnUser  := TBtnBmp():NewBar("ng_ico_info","ng_ico_info",,,,{|| fUserSS(__OPC_TQB__)},,oPanelR1Btn,,,STR0019,,,,,"") //"Informações do Solicitante"
	oBtnUser:Align  := CONTROL_ALIGN_TOP

	oBtnVis  := TBtnBmp():NewBar("ng_ico_conhecimento","ng_ico_conhecimento",,,,{|| fMsDocSS(__OPC_TQB__)},,oPanelR1Btn,,,STR0020,,,,,"") //"Conhecimento"
	oBtnVis:Align  := CONTROL_ALIGN_TOP

	oBtnSatisf  := TBtnBmp():NewBar("ng_ico_pesqsat","ng_ico_pesqsat",,,,{|| fSatisfSS(__OPC_TQB__)},,oPanelR1Btn,,,STR0021,,,,,"") //"Pesquisa de Satisfação"
	oBtnSatisf:Align  := CONTROL_ALIGN_TOP

	oPanelEnc:=TPanel():New(00,00,,oPanelRUp,,,,,,200,200,.F.,.F.)
	oPanelEnc:Align := CONTROL_ALIGN_ALLCLIENT

	//Criacao das Variaveis da Enchoice
	dbSelectArea("TQB")
	dbSetOrder(1)
	dbSeek(xFilial("TQB"))
	MNT280CPO(4,2)
	MNT280REG(0, a280Relac, a280Memos)

	oEncSS := MsMGet():New("TQB",TQB->(Recno()),4,,,,a280Choice,{0,0,500,500},,3,,,,oPanelEnc)
	oEncSS:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	// Carrega Teclas de Atalho
	SetKey(VK_F6, {|| MNTC285Ind() }) // Indicadores

	// Colca o Foco no Browse de Solicitações de Serviço
	aObj285[__OPC_TQB__][__POS_OBJ__]:SetFocus()
	Activate MsDialog oDlg285 On Init (EnchoiceBar(oDlg285,{|| oDlg285:End()},{|| oDlg285:End()},,aEncBtns)) Centered

	//Deleta Arquivo temporario
	NGDELETRB(aObj285[__OPC_TQB__][__POS_ALIAS__],aObj285[__OPC_TQB__][__POS_ARQ__])

	//Retorna variaveis padrao
	NGRETURNPRM(aNGBEGINPRM)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fCreateTRB
Realiza a criacao das estruturas dos arquivos temporarios

@param nOpcao Opcao de alias a ser criado

@author Roger Rodrigues
@since 12/03/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fCreateTRB(nOpcao)

	Local i
	Local oTmpMark
	Local cAliasDic
	Local nPosDel
	Local nPosLoc
	Local nIdx
	Local cAliasTRB := GetNextAlias()
	Local aExpDel	:= { "DTOS" , "DESCEND", "STR" }
	Local cAliasTmp
	Local aDBF 		:= {}
	Local aVirtual 	:= {}
	Local aFields 	:= {}
	Local aLegenda 	:= {}
	Local aLeg2 	:= {}
	Local vInd 		:= {}
	Local vDesInd 	:= {}
	Local nTamTot	:= 0
	Local nInd		:= 0
	Local cCampo	:= ""
	Local cTipo		:= ""
	Local nTamanho	:= 0
	Local nDecimal	:= 0
	Local cBrowse	:= ""
	Local cContext	:= ""
	Local cIniBrw	:= ""
	Local cCBox		:= ""
	Local cRelacao	:= ""

	Private aHeadTQB := {}

	// Montagem do Markbrowse e arquivo temporario
	If nOpcao == __OPC_TQB__
		aADD(aDBF,{"OK"			, "C", 2	,0	})
		aADD(aDBF,{"TQB_FILIAL"	, "C", TAMSX3("TQB_FILIAL")[1], TAMSX3("TQB_FILIAL")[2]	})
		aADD(aDBF,{"TQB_SOLICI"	, "C", TAMSX3("TQB_SOLICI")[1], TAMSX3("TQB_SOLICI")[2]	})
		aADD(aDBF,{"CRITICID"	, "C", TAMSX3("TQB_CRITIC")[1], 0	})

		aADD(aFields, {"OK"		  		, 0, "", "" })
		aADD(aFields, {"TQB_SOLICI"	, TAMSX3("TQB_SOLICI")[1], RetTitle("TQB_SOLICI"), PesqPict("TQB", "TQB_SOLICI")	})

		//Carrega os campos do TRB e do Browse
		aHeadTQB := NGHeader("TQB")
		nTamTot := Len(aHeadTQB)

		For nInd := 1 to nTamTot
			cCampo 		:= aHeadTQB[nInd,2]
			cTipo		:= aHeadTQB[nInd,8]
			cCBox		:= Posicione("SX3",2,cCampo,"X3CBox()")
			nTamanho	:= aHeadTQB[nInd,4]
			nDecimal	:= aHeadTQB[nInd,5]
			cBrowse		:= Posicione("SX3",2,cCampo,"X3_BROWSE")
			cContext	:= aHeadTQB[nInd,10]
			cIniBrw		:= Posicione("SX3",2,cCampo,"X3_INIBRW")
			cRelacao	:= Posicione("SX3",2,cCampo,"X3_RELACAO")

			If (aScan(aDBF,{|x| Trim(Upper(x[1])) == Trim(Upper(cCampo))}) ) == 0 .and. AllTrim(cTipo) != "M"
				aADD(aDBF, {AllTrim(cCampo), AllTrim(cTipo),If(!Empty(cCBox),20,nTamanho) , nDecimal })//TRB
				//Se for do Browse
				If AllTrim(Upper(cBrowse)) == "S"
					If (aScan(aFields,{|x| Trim(Upper(x[1])) == Trim(Upper(cCampo))}) ) == 0
						aADD(aFields, {AllTrim(cCampo), If(!Empty(cCBox),20,nTamanho), RetTitle(AllTrim(cCampo)),;
						PesqPict("TQB", AllTrim(cCampo))})//Tela
						//Se o campo for virtual guarda o Ini. Browse
						If !Empty(cCBox)
							aADD(aVirtual, {AllTrim(cCampo), "COMBO"})
						ElseIf cContext == "V"
							aADD(aVirtual, {AllTrim(cCampo), AllTrim(cIniBrw)})
						Endif
					Endif
				ElseIf !Empty(cCBox)
					aADD(aVirtual, {AllTrim(cCampo), "COMBO"})
				ElseIf cContext == "V"
					aADD(aVirtual, {AllTrim(cCampo), AllTrim(cRelacao)})
				Endif
			Endif
		Next nInd

		aAdd(vInd, { "TQB_FILIAL","TQB_SOLICI" } )
		aAdd(vDesInd, RetTitle("TQB_SOLICI"))

		aAdd(vInd, {"TQB_FILIAL","TQB_TPSERV","TQB_PRIORI","CRITICID","TQB_DTABER"})
		aAdd(vDesInd, Trim(RetTitle("TQB_TPSERV"))+"+"+Trim(RetTitle("TQB_PRIORI"))+"+"+Trim(RetTitle("TQB_CRITIC"))+"+"+Trim(RetTitle("TQB_DTABER")))
		//Carrega indices
		dbSelectArea("SIX")
		dbSetOrder(1)
		dbSeek("TQB")
		While !Eof() .and. SIX->INDICE == "TQB"
			If !("TQB_CDSERV" $ SIX->CHAVE) .and. !("TQB_CDEXEC" $ SIX->CHAVE) .and. !("TQB_FUNEXE" $ SIX->CHAVE) .and.;
			aScan(vInd, {|x| fVldIdx(x) == AllTrim(SIX->CHAVE)}) == 0
				aAdd(vInd, StrTokArr( AllTrim(SIX->CHAVE), "+"))
				aAdd(vDesInd, AllTrim(SixDescricao()))
				// Recebe o Índice inicial
				If __nIndTQB == 0
					If "TQB_SOLUCA+TQB_SOLICI" $ StrTran(SIX->CHAVE," ","")
						__nIndTQB := Len(vInd)
					EndIf
				EndIf
			EndIf
			dbSelectArea("SIX")
			dbSkip()
		End
		// Se não conseguiu definir o Índice, define por padrão o primeiro
		If __nIndTQB == 0
			__nIndTQB := 1
		EndIf

		//Definicao da Legenda do MarkBrowse
		cAliasTmp := "aObj285["+cValToChar(nOpcao)+"]["+cValToChar(__POS_ALIAS__)+"]"
		// Legenda 1 (Situação)
		aAdd(aLegenda, {"Substr(("+cAliasTmp+")->TQB_SOLUCA,1,1) == 'A'","BR_VERMELHO"})
		aAdd(aLegenda, {"Substr(("+cAliasTmp+")->TQB_SOLUCA,1,1) == 'D'","BR_VERDE"})
		aAdd(aLegenda, {"Substr(("+cAliasTmp+")->TQB_SOLUCA,1,1) == 'E'","BR_AZUL"})
		aAdd(aLegenda, {"Substr(("+cAliasTmp+")->TQB_SOLUCA,1,1) == 'C'","BR_PRETO"})
		// Legenda 2 (Prioridade)
		aAdd(aLeg2, {"Empty(("+cAliasTmp+")->TQB_PRIORI)","BR_PRETO"})
		aAdd(aLeg2, {"Substr(("+cAliasTmp+")->TQB_PRIORI,1,1) == '1'","BR_VERMELHO"})
		aAdd(aLeg2, {"Substr(("+cAliasTmp+")->TQB_PRIORI,1,1) == '2'","BR_AMARELO"})
		aAdd(aLeg2, {"Substr(("+cAliasTmp+")->TQB_PRIORI,1,1) == '3'","BR_AZUL"})

		cAliasDic := "TQB"
	Endif

	oTmpMark := FWTemporaryTable():New(cAliasTRB, aDBF)
	For nIdx := 1 To Len(vInd)
		For i := 1 To Len(vInd[nIdx])
			If ( nPosDel := aScan( aExpDel , { | x | AllTrim( Upper( x ) ) $ Upper( vIND[ nIdx,i ] ) } ) ) > 0
				If ( nPosLoc := AT( "(" , vIND[ nIdx,i ] ) ) > 0
					vIND[ nIdx,i ] := SubStr( vIND[ nIdx,i ] , nPosLoc + 1 )
				EndIf
				If ( nPosLoc := AT( "," , vIND[ nIdx,i ] ) ) > 0
					vIND[ nIdx,i ] := SubStr( vIND[ nIdx,i ] , 1 , nPosLoc - 1 )
				EndIf
				If ( nPosLoc := AT( ")" , vIND[ nIdx,i ] ) ) > 0
					vIND[ nIdx,i ] := SubStr( vIND[ nIdx,i ] , 1 , nPosLoc - 1 )
				EndIf
			EndIf
			vIND[ nIdx,i ] := AllTrim(vIND[ nIdx,i ])
		Next i
		oTmpMark:AddIndex( "Ind" + cValToChar(nIdx) , vInd[nIdx] )
	Next nIdx

	oTmpMark:Create()

	//Preenche array do markbrowse
	aObj285[nOpcao][__POS_OBJ__]   := Nil
	aObj285[nOpcao][__POS_FIELDS__]:= aFields
	aObj285[nOpcao][__POS_DBF__]   := aDBF
	aObj285[nOpcao][__POS_IND__]   := vInd
	aObj285[nOpcao][__POS_VIR__]   := aVirtual
	aObj285[nOpcao][__POS_ARQ__]   := oTmpMark
	aObj285[nOpcao][__POS_ALIAS__] := cAliasTRB
	aObj285[nOpcao][__POS_LEG__]   := aLegenda
	aObj285[nOpcao][__POS_ALIDIC__]:= cAliasDic
	aObj285[nOpcao][__POS_FILTER__]:= ""
	aObj285[nOpcao][__POS_DESIND__]:= vDesInd
	aObj285[nOpcao][__POS_LEG2__]  := aLeg2

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fLoadTRB
Carrega arquivo temporario com solicitacoes de servico

@param nOpcao Opcao de alias a ser carregado
@param cFiltro Filtro a ser aplicado no alias a ser carregado

@author Roger Rodrigues
@since 07/06/2011
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fLoadTRB(nOpcao, cFiltro)
	Local i, j, nPos
	Local cCampo := ""
	Local cValor := Nil
	Local cAliasMark := aObj285[nOpcao][__POS_ALIAS__]
	Default cFiltro := ""

	//Limpa Arquivo temporario
	dbSelectArea(cAliasMark)
	Zap

	//Carrega solicitacao
	If nOpcao == __OPC_TQB__
		dbSelectArea("TQB")
		dbSetOrder(1)
		dbSeek(xFilial("TQB"))
		ProcRegua(TQB->(RecCount()))
		While !Eof() .and. xFilial("TQB") == TQB->TQB_FILIAL
			IncProc()

			If !Empty(cFiltro) .and. !Eval( &("{||"+cFiltro+"}") )
				dbSelectArea("TQB")
				dbSkip()
				Loop
			Endif

			dbSelectArea(cAliasMark)
			RecLock(cAliasMark,.T.)
			For i:=1 to FCount()
				cCampo := Upper(Trim(FieldName(i)))
				cValor := Nil
				If cCampo == "OK"
					cValor := Space(2)
				ElseIf cCampo == "CRITICID"
					cValor := StrZero(TQB->TQB_CRITIC, 3)
				ElseIf (nPos := aScan(aObj285[nOpcao][__POS_VIR__],{|x| Trim(Upper(x[1])) == cCampo}) ) > 0//Verifica se o campo tem Inicializador
					//Executa Combo
					If aObj285[nOpcao][__POS_VIR__][nPos][2] == "COMBO"
						If !Empty(&("TQB->"+cCampo))
							cValor := &("TQB->"+cCampo)+"="+NGRETSX3BOX(cCampo,&("TQB->"+cCampo))
						Endif
					ElseIf !Empty(aObj285[nOpcao][__POS_VIR__][nPos][2])//Executa Inicializador
						cValor := &(aObj285[nOpcao][__POS_VIR__][nPos][2])
					Endif
				Else//Grava normalmente
					cValor := &("TQB->"+cCampo)
				Endif
				If ValType(cValor) != "U"
					dbSelectArea(cAliasMark)
					FieldPut(i, cValor)
				Endif
			Next i
			MsUnlock(cAliasMark)

			dbSelectArea("TQB")
			dbSkip()
		End
		dbSelectArea(cAliasMark)
		dbSetOrder(__nIndTQB)
		dbGoTop()
	Endif

	dbSelectArea(cAliasMark)
	dbGoTop()
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fShowHide
Mostra/Esconde Painel

@param nPanel Painel a ser escondido/mostrado
@param oPanel Objeto do painel a ser escondido/mostrado
@param oBotao Objeto do botao que deve ter sua label alterada

@author Roger Rodrigues
@since 13/03/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fShowHide(nPanel,oPanel,oBotao)

	If oPanel:lVisible
		oPanel:Hide()
		If nPanel == 1
			oBotao:LoadBitmaps("fw_arrow_left")
			oBotao:cTooltip := OemToAnsi(STR0015) //"Esconder Browse"
		ElseIf nPanel == 2
			oBotao:LoadBitmaps("fw_arrow_right")
			oBotao:cTooltip := OemToAnsi(STR0014) //"Expandir Browse"
		ElseIf nPanel == 3
			oBotao:LoadBitmaps("fw_arrow_top")
			oBotao:cTooltip := OemToAnsi(STR0022) //"Expandir Browse Follow-Up"
		ElseIf nPanel == 4
			oBotao:LoadBitmaps("fw_arrow_down")
			oBotao:cTooltip := OemToAnsi(STR0023) //"Expandir Detalhes da S.S."
		Endif
	Else
		oPanel:Show()
		If nPanel == 1
			oBotao:LoadBitmaps("fw_arrow_right")
			oBotao:cTooltip := OemToAnsi(STR0014) //"Expandir Browse"
		ElseIf nPanel == 2
			oBotao:LoadBitmaps("fw_arrow_left")
			oBotao:cTooltip := OemToAnsi(STR0015) //"Esconder Browse"
		ElseIf nPanel == 3
			oBotao:LoadBitmaps("fw_arrow_down")
			oBotao:cTooltip := OemToAnsi(STR0023) //"Expandir Detalhes da S.S."
		ElseIf nPanel == 4
			oBotao:LoadBitmaps("fw_arrow_top")
			oBotao:cTooltip := OemToAnsi(STR0022) //"Expandir Browse Follow-Up"
		EndIf
	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fQuestiSS
Carrega questionario da solicitacao

@author Roger Rodrigues
@since 24/04/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fQuestiSS(nOpcao)
	Local aNGBEGINPRM := NGBEGINPRM()
	Local cOldFil := cFilAnt
	Local cFilSS := (aObj285[nOpcao][__POS_ALIAS__])->TQB_FILIAL
	Local cCodSS := (aObj285[nOpcao][__POS_ALIAS__])->TQB_SOLICI

	dbSelectArea("TQB")
	dbSetOrder(1)
	If dbSeek(xFilial("TQB",cFilSS)+cCodSS)
		If !Empty(cFilSS)
			cFilAnt := cFilSS
		Endif
		MNT280DIAG(.F., .F., Nil)
	Endif

	cFilAnt := cOldFil
	NGRETURNPRM(aNGBEGINPRM)
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fVisualSS
Carrega visualizacao da solicitacao

@author Roger Rodrigues
@since 18/09/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fVisualSS(nOpcao)
	Local aNGBEGINPRM := NGBEGINPRM()
	Local aMemory  := NGGetMemory("TQB")
	Local cOldFil := cFilAnt
	Local cFilSS := (aObj285[nOpcao][__POS_ALIAS__])->TQB_FILIAL
	Local cCodSS := (aObj285[nOpcao][__POS_ALIAS__])->TQB_SOLICI

	dbSelectArea("TQB")
	dbSetOrder(1)
	If dbSeek(xFilial("TQB",cFilSS)+cCodSS)
		If !Empty(cFilSS)
			cFilAnt := cFilSS
		Endif
		MNTA280IN(2)
	Endif

	cFilAnt := cOldFil
	NgRestMemory(aMemory)
	NGRETURNPRM(aNGBEGINPRM)
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fUserSS
Mostra informacoes do solicitante da SS

@author Roger Rodrigues
@since 04/03/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fUserSS(nOpcao)
	Local aNGBEGINPRM := NGBEGINPRM()
	Local cOldFil := cFilAnt
	Local cFilSS := (aObj285[nOpcao][__POS_ALIAS__])->TQB_FILIAL
	Local cCodSS := (aObj285[nOpcao][__POS_ALIAS__])->TQB_SOLICI

	dbSelectArea("TQB")
	dbSetOrder(1)
	If dbSeek(xFilial("TQB",cFilSS)+cCodSS)
		If !Empty(cFilSS)
			cFilAnt := cFilSS
		Endif
		dbSelectArea("TUF")
		dbSetOrder(1)
		If dbSeek(xFilial("TUF",cFilSS)+TQB->TQB_CDSOLI)
			FWExecView( STR0019 , 'MNTA909' , MODEL_OPERATION_VIEW , , { || .T. } ) //"Informações do Solicitante"
		Endif
	Endif

	cFilAnt := cOldFil
	NGRETURNPRM(aNGBEGINPRM)
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fMsDocSS
Realiza chamada do conhecimento das solicitacoes

@author Roger Rodrigues
@since 04/03/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fMsDocSS(nOpcao)
	Local aNGBEGINPRM := NGBEGINPRM()
	Local cOldFil := cFilAnt
	Local cFilSS := (aObj285[nOpcao][__POS_ALIAS__])->TQB_FILIAL
	Local cCodSS := (aObj285[nOpcao][__POS_ALIAS__])->TQB_SOLICI

	dbSelectArea("TQB")
	dbSetOrder(1)
	If dbSeek(xFilial("TQB",cFilSS)+cCodSS)
		If !Empty(cFilSS)
			cFilAnt := cFilSS
		Endif
		MsDocument("TQB",TQB->(Recno()),4)
	Endif

	cFilAnt := cOldFil
	NGRETURNPRM(aNGBEGINPRM)
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fSatisfSS
Realiza chamada da pesquisa de satisfacao das solicitacoes

@author Roger Rodrigues
@since 11/10/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fSatisfSS(nOpcao)
	Local aNGBEGINPRM := NGBEGINPRM()
	Local cOldFil := cFilAnt
	Local cFilSS := (aObj285[nOpcao][__POS_ALIAS__])->TQB_FILIAL
	Local cCodSS := (aObj285[nOpcao][__POS_ALIAS__])->TQB_SOLICI

	dbSelectArea("TQB")
	dbSetOrder(1)
	If dbSeek(xFilial("TQB",cFilSS)+cCodSS)
		If !Empty(cFilSS)
			cFilAnt := cFilSS
		Endif
		MNT307QUE(.T.,TQB->TQB_SOLICI)
	Endif

	cFilAnt := cOldFil
	NGRETURNPRM(aNGBEGINPRM)
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fImpSS
Realiza chamada da impressao das solicitacoes marcadas

@author Roger Rodrigues
@since 03/04/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fImpSS()
	Local aGetArea := fGetArea(aObj285[__OPC_TQB__][__POS_ALIAS__])
	Local aListaSS := fRetSSMrk()

	If Len(aListaSS) > 0
		MNTR120(aListaSS)
	Else
		ShowHelpDlg(STR0024,{STR0025},1,{STR0026}) //"Atenção" ## "Deve ser selecionada pelo menos uma Solicitação de Serviço para impressão." ## "Marque uma Solicitação de Serviço."
	Endif

	fRestArea(aGetArea)
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fRetSSMrk
Retorna array com as SS's marcadas

@author Roger Rodrigues
@since 04/04/2012
@version MP10/MP11
@return aSSMark
/*/
//---------------------------------------------------------------------
Static Function fRetSSMrk()
	Local aSSMark := {}
	Local cAliasMrk := aObj285[__OPC_TQB__][__POS_ALIAS__]
	Local aGetArea := fGetArea(cAliasMrk)

	dbSelectArea(cAliasMrk)
	dbSetOrder(1)
	dbGoTop()
	While !Eof()
		If !Empty((cAliasMrk)->OK)
			aAdd(aSSMark, {(cAliasMrk)->TQB_FILIAL, (cAliasMrk)->TQB_SOLICI})
		Endif
		dbSelectArea(cAliasMrk)
		dbSkip()
	End

	fRestArea(aGetArea)
Return aSSMark
//---------------------------------------------------------------------
/*/{Protheus.doc} fGetArea
Salva posicao de alias selecionado e filtro

@param cAliasTmp Alias que devera ter salvo sua posicao e filtro

@author Roger Rodrigues
@since 04/04/2012
@version MP10/MP11
@return aGetArea
/*/
//---------------------------------------------------------------------
Static Function fGetArea(cAliasTmp)
	Local aGetArea := {}

	aAdd(aGetArea, cAliasTmp)
	aAdd(aGetArea, (cAliasTmp)->(IndexOrd()))
	aAdd(aGetArea, (cAliasTmp)->(Recno()))
	aAdd(aGetArea, (cAliasTmp)->(dbFilter()))

Return aGetArea
//---------------------------------------------------------------------
/*/{Protheus.doc} fRestArea
Retorna posicao de alias selecionado e filtro

@param aGetArea Array com parametros do alias salvo

@author Roger Rodrigues
@since 04/04/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fRestArea(aGetArea)

	dbSelectArea(aGetArea[1])
	dbSetOrder(aGetArea[2])
	dbGoTo(aGetArea[3])
	Set Filter To &(aGetArea[4])

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fMrkAll
Marca todos os itens do Markbrowse

@param nOpcao Opcao de markbrowse a ser marcado
@param cMarca Variavel de marcacao do browse

@author Roger Rodrigues
@since 04/04/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fMrkAll(nOpcao,nPosHead,cMarca)
	Local lMarca:= .F.
	Local cAliasMrk := aObj285[nOpcao][__POS_ALIAS__]
	Local aGetArea := fGetArea(cAliasMrk)
	Default nPosHead := 1

	If nPosHead <> 1
		Return .F.
	Endif

	//Verifica se existe item desmarcado
	dbSelectArea(cAliasMrk)
	dbSetOrder(1)
	dbGoTop()
	While !eof()
		If Empty((cAliasMrk)->OK)
			lMarca := .T.
			Exit
		Endif
		dbSelectArea(cAliasMrk)
		dbSkip()
	End
	//Marca ou desmarca todos
	dbSelectArea(cAliasMrk)
	dbSetOrder(1)
	dbGoTop()
	While !eof()
		RecLock(cAliasMrk,.F.)
		(cAliasMrk)->OK := If(lMarca, cMarca, Space(2))
		MsUnlock(cAliasMrk)
		dbSelectArea(cAliasMrk)
		dbSkip()
	End

	//Restaura tabela e atualiza browse
	fRestArea(aGetArea)
	aObj285[nOpcao][__POS_OBJ__]:Refresh(.T.)

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fSetFilter
Troca filtro de markbrowse

@param nOpcao Opcao de markbrowse a ser filtrado

@author Roger Rodrigues
@since 10/04/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fSetFilter(nOpcao)
	Local cOldFilt := aObj285[nOpcao][__POS_FILTER__]
	aObj285[nOpcao][__POS_FILTER__] := BuildExpr(aObj285[nOpcao][__POS_ALIDIC__],,aObj285[nOpcao][__POS_FILTER__])
	// Apenas atualiza se o Filtro for diferente
	If AllTrim(aObj285[nOpcao][__POS_FILTER__]) <> cOldFilt
		Processa({|| fLoadTRB(nOpcao, aObj285[nOpcao][__POS_FILTER__]) },STR0002,STR0027) //"Aguarde..." ## "Recarregando..."
		Eval( aObj285[nOpcao][__POS_OBJ__]:bChange )
	EndIf
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fAtuEnc
Cria e recria enchoice da solicitacao

@author Roger Rodrigues
@since 08/06/2011
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fAtuEnc(nOpcao)
	Local i
	Local aGetArea := fGetArea("TQB")
	Local cFilSS := (aObj285[nOpcao][__POS_ALIAS__])->TQB_FILIAL
	Local cCodSS := (aObj285[nOpcao][__POS_ALIAS__])->TQB_SOLICI
	Local nOpcx := 2

	If Empty(cCodSS)
		nOpcx := 0
	Endif
	If nOpcx > 0
		dbSelectArea("TQB")
		dbSetOrder(1)
		If dbSeek(xFilial("TQB",cFilSS)+cCodSS)
			If !Empty(cFilSS)
				cFilAnt := cFilSS
			Endif
			MNT280CPO(4,2)
			MNT280REG(nOpcx, a280Relac, a280Memos)
		Endif
	Else
		MNT280CPO(4,2)
		MNT280REG(nOpcx, a280Relac, a280Memos)
	Endif

	//Coloca campo no modo de visualizacao
	For i:=1 to Len(oEncSS:aGets)
		oEncSS:aEntryCtrls[i]:lReadOnly := .T.
		oEncSS:aEntryCtrls[i]:lActive := .T.
	Next i

	oEncSS:EnchRefreshAll()

	fRestArea(aGetArea)
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fSeekReg
Procura registro na tabela

@param nOpcao Opcao do markbrowse a ser pesquisado
@param nIndex Indice da tabela a ser utilizado para pesquisa
@param cPesquisa Chave de Pesquisa
@param lSeek Indica se procura registro ou apenas muda indice

@author Roger Rodrigues
@since 12/04/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fSeekReg(nOpcao, nIndex, cPesquisa, lSeek)
	Local nInd := 0
	Local cChave := ""
	Default lSeek := .T.

	nInd := nIndex
	__nIndTQB := nInd

	dbSelectArea(aObj285[nOpcao][__POS_ALIAS__])
	dbSetOrder(nInd)

	If !lSeek
		cPesquisa := Space(100)
	Else
		cChave := cPesquisa
		If aScan(aObj285[nOpcao][__POS_IND__][nIndex],{|x| "_FILIAL" $ x }) > 0
			cChave := xFilial(aObj285[nOpcao][__POS_ALIDIC__])+cChave
		Endif
		dbSeek(cChave,.T.)
	Endif

	If !Empty(aObj285[nOpcao][__POS_OBJ__])
		If lSeek
			Eval( aObj285[nOpcao][__POS_OBJ__]:bChange )
		EndIf
		aObj285[nOpcao][__POS_OBJ__]:Refresh(.T.)
	Endif

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fMarkBrw
Marca o registro no browse

@author Roger Rodrigues
@since 23/08/2012
@version MP10/MP11
@return lRet
/*/
//---------------------------------------------------------------------
Static Function fMarkBrw(nOpcao,cMarca)
	Local cAliasMark := aObj285[nOpcao][__POS_ALIAS__]

	dbSelectArea(cAliasMark)
	RecLock(cAliasMark, .F.)
	(cAliasMark)->OK := If(Empty((cAliasMark)->OK),cMarca,Space(Len((cAliasMark)->OK)))
	MsUnlock(cAliasMark)

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fImgLeg
Retorna qual imagem deve ser mostrada na coluna

@author Roger Rodrigues
@since 23/08/2012
@version MP10/MP11
@return cImagem
/*/
//---------------------------------------------------------------------
Static Function fImgLeg(nLegPos, nOpcao)
	Local i
	Local cImagem := "NG_SEM_INFO"
	Local aArrLeg := {}
	Local cAliasMark := aObj285[nOpcao][__POS_ALIAS__]

	//Marcacao
	If !(cAliasMark)->(Eof())
		If nLegPos == 0
			cImagem := If(Empty((cAliasMark)->OK) , "LBNO" , "LBOK")
		Else
			If nLegPos == 1
				aArrLeg := aObj285[nOpcao][__POS_LEG__]
			ElseIf nLegPos == 2
				aArrLeg := aObj285[nOpcao][__POS_LEG2__]
			Endif
			For i:=1 To Len(aArrLeg)
				If Eval({|| &(aArrLeg[i][1])})
					cImagem := aArrLeg[i][2]
					Exit
				Endif
			Next i
		Endif
	Endif

Return cImagem

/*/
############################################################################################
##                                                                                        ##
## FUNÇÕES PARA OS INDICADORES DA CONSULTA                                                ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC285Ind
Indicadores da Consulta de Solicitação de Serviço.

@author Wagner Sobral de Lacerda
@since 15/10/2012
@version MP10/MP11
@return lDlgInd
/*/
//---------------------------------------------------------------------
Function MNTC285Ind()

	// Variáveis do Dialog
	Local oDlgInd
	Local cDlgInd := OemToAnsi(STR0028) //"Indicadores da Consulta de Ordem de Serviço"
	Local lDlgInd := .F.
	Local oPnlInd

	//Variaveis de tamanho de tela e objetos
	Local aSize := {}, aObjects := {}, aInfo := {}, aPosObj := {}

	//Definicao de tamanho de tela e objetos
	aSize := MsAdvSize(,.f.,430)
	aAdd(aObjects,{100,100,.t.,.t.})
	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObjects,.t.)

	//--------------------
	// Monta o Dialog
	//--------------------
	DEFINE MSDIALOG oDlgInd TITLE cDlgInd FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL

	// Painél Principal do Dialog
	oPnlInd := TPanel():New(01, 01, , oDlgInd, , , , CLR_BLACK, CLR_WHITE, 100, 030)
	oPnlInd:Align := CONTROL_ALIGN_ALLCLIENT

	// Painél de Indicadores
	oTNGPanel := NGI8TNGPnl(oPnlInd)

	ACTIVATE MSDIALOG oDlgInd ON INIT EnchoiceBar(oDlgInd, {|| lDlgInd := .T., oDlgInd:End()}, {|| lDlgInd := .F., oDlgInd:End()}) CENTERED

Return lDlgInd

//---------------------------------------------------------------------
/*/{Protheus.doc} fVldIdx
Concatena todas as posições do indice da tabela temporaria retiradas do SX3
@author douglas.constancio
@since 12/04/2017
@version undefined
@param x, numerica, posição do array
@type function
/*/
//---------------------------------------------------------------------
Static Function fVldIdx(x)

	Local nIdx
	Local cIndex := ""

	For nIdx := 1 To Len( x )
		If !Empty( cIndex )
			cIndex += "+"
		EndIf
		cIndex += x[ nIdx ]
	Next nIdx

Return cIndex