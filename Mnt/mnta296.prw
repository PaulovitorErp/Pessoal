#INCLUDE "Protheus.ch"
#INCLUDE "FwMBrowse.CH"
#INCLUDE "MNTA296.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWCSS.CH"

#DEFINE __OPC_TQB__ 1
#DEFINE __OPC_TP4__ 2
#DEFINE __OPC_ST1__ 3
#DEFINE __OPC_SA2__ 4
#DEFINE __OPC_TUR__ 5

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
#DEFINE __POS_FILIAL__ 12

#DEFINE __LEN_MARK__ 5
#DEFINE __LEN_PROP__ 12

#DEFINE MIN_BUILD_VERSION "7.00.131227A-20170511"

// Variáveis de Totalizadores
Static __aTotal := Array(1)
Static __nTotSS := 1

// Variáveis de Chamada de Função
Static __cCallAtend := "ATENDIMENTO" // Chamada pela rotina de Atendimento de S.S.
Static __cCallDistr := "DISTRIBUICAO" // Chamada pela rotina de Distribuição de S.S.

// Variável do Filtro
Static __cFilt296 := ""

// Variável do Índice principal das Solicitações de Serviço
Static __nIndTQB := 0

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA296
Tela de Distribuicao de Servicos

@author Roger Rodrigues
@since 06/06/2011
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Function MNTA296(cParFilial, cParSolici, cParTipoSS, cParCodBem)

	//Guarda variaveis padrao
	Local aNGBEGINPRM := NGBEGINPRM()

	//Variaveis da tela
	Local oDlg296
	Local cTitulo := STR0001 //"Distribuição de Solicitações de Serviço"
	Local bGravaEnc := {||}

	//Variaveis do combo
	Local oGetSearch, oCBoxSearch, oBtnSearch, cCombo, cGetSearch := Space(100)

	//Variaveis de tamanho de tela e objetos
	Local aSize := {}, aObjects := {}, aInfo := {}, aPosObj := {}

	//Variaveis do MarkBrowse
	Local cMarca   := GetMark()
	Local lInverte := .F.

	//Objetos principais
	Local oSplitVert, oPanelLeft, oPanelRight

	//Botoes para esconder paineis
	Local oHideLeft, oHideRight, oHideTop, oHideBottom

	//Parte Esquerda
	Local oPanelT1, oPanelLBtn, oPanelMark, oPanelPesq

	//Parte Direita
	Local oSplitHor, oPanelRUp, oPanelRDown, oPanelT2, oPanelEnc, oPanelR1Btn

	//Atendentes
	Local oPanelD1

	// Objetos do Totalizador
	Local oPanelTot

	// Utilizado no P.E. MNTA2960 e MNTA2961
	Local xRetFil
	Local nIndex       := 0
	Local cFilterPE    := ''
	Local nRetFil      := 1
	

	Local aSMenuPE      := {}
	Local aButtons      := {}
	Local aButtons1     := {}
	Local aButtons2     := {}
	Local nX            := 1

	// Defaults
	Default cParFilial := ""
	Default cParSolici := ""
	Default cParTipoSS := ""
	Default cParCodBem := ""

	//Objetos que serao desabilitados
	Private oPanelLCont, oPanelRDCont
	Private oBtnAltSS, oBtnConf, oBtnCanc, oBtnQuest, oBtnVis, oBtnUser, oBtnDet
	Private oPanelBar
	Private oPanelBtn
	Private oBtnFechar
	Private oBtnDist

	// Utilizado para carregar os dados do Funcionário na função MNTA280REL.
	Private oHashSol  := HmNew()
	Private oHashResp := HmNew()
	
	//Titulo da tela
	Private cCadastro := cTitulo

	//Variavel de objetos de markbrowse
	Private aMark296 := Array(__LEN_MARK__,__LEN_PROP__)

	//Variaveis da Enchoice
	Private oEncSS
	Private aTela   := {}
	Private aGets   := {}
	Private aRotina := {{"", "PesqBrw",0, 1},;
	{"", "NGCAD01",0, 2},;
	{"", "NGCAD01",0, 3},;
	{"", "NGCAD01",0, 4},;
	{"", "NGCAD01",0, 5,3}}

	// Variável das cores da tela
	Private aNGColor := aClone( NGCOLOR("10") )

	//Filtros para melhorar a performance
	Private cPar10dias   := "dToS(TQB_DTABER) >= dToS(dDatabase - 10)"
	Private cPar30dias   := "dToS(TQB_DTABER) >= dToS(dDatabase - 30)"
	Private cParTodas    := ".T."
	Private oMenuFil
	Private aSMenu1      := { { STR0089, 'MNT296TRB( 1, cPar10dias )' },; // Mostrar todas as S.S. abertas nos últimos 10 dias
							  { STR0090, 'MNT296TRB( 1, cPar30dias )' },; // Mostrar todas as S.S. abertas nos últimos 30 dias
							  { STR0091, 'MNT296TRB( 1, cParTodas )'  };  // Mostrar todas as S.S. abertas
							}

	aAdd(aSMenuPE, cPar10dias)
	aAdd(aSMenuPE, cPar30dias)
	aAdd(aSMenuPE, cParTodas)

	// P.E. que permite adicionar novas opções ao filtro referente as S.S.
	If ExistBlock( 'MNTA2960' )

		xRetFil  := ExecBlock( 'MNTA2960', .F., .F. )

		If ValType( xRetFil ) == 'A'

			For nIndex := 1 To Len( xRetFil )

				If ValType( xRetFil[nIndex] ) == 'A'

					// Adiciona a expressão retornada pelo P.E. na função que monta a TRB de S.S.
					cFilterPE := "MNT296TRB( 1, '" + xRetFil[nIndex, 2] + "' )"

					// Inclui o novo filtro na lista de filtros disponiveis.
					aAdd( aSMenu1, { xRetFil[nIndex, 1], cFilterPE } )
					aAdd( aSMenuPE, xRetFil[nIndex, 2] )

				EndIf

			Next nIndex

		EndIf

	EndIf

	//Verifica se o update de facilities foi aplicado
	If !FindFunction("MNTUPDFAC") .or. !MNTUPDFAC()
		NGRETURNPRM(aNGBEGINPRM)
		Return .F.
	EndIf

	SetAltera(.T.)//Utilizado caso exista algum Ini. Browse

	//Cria estrutura de arquivo temporario e markbrowse
	fCreateTRB(__OPC_TQB__)

	// Define o Filtro pricipal da TQB da rotina MNTA296
	__cFilt296 := ""
	If !Empty(cParFilial)
		cParFilial := PADR(cParFilial, TAMSX3("TQB_FILIAL")[1], " ")
		__cFilt296 += If(!Empty(__cFilt296), " .And. ", "") + "AllTrim(TQB->TQB_FILIAL) == '" + AllTrim(cParFilial) + "' "
	EndIf

	If !Empty(cParSolici)
		cParSolici := PADR(cParSolici, TAMSX3("TQB_SOLICI")[1], " ")
		__cFilt296 += If(!Empty(__cFilt296), " .And. ", "") + "AllTrim(TQB->TQB_SOLICI) == '" + AllTrim(cParSolici) + "' "
	EndIf

	If !Empty(cParTipoSS)
		cParTipoSS := PADR(cParTipoSS, TAMSX3("TQB_TIPOSS")[1], " ")
		__cFilt296 += If(!Empty(__cFilt296), " .And. ", "") + "AllTrim(TQB->TQB_TIPOSS) == '" + AllTrim(cParTipoSS) + "' "
	EndIf

	If !Empty(cParCodBem)
		cParCodBem := PADR(cParCodBem, TAMSX3("TQB_CODBEM")[1], " ")
		__cFilt296 += If(!Empty(__cFilt296), " .And. ", "") + "AllTrim(TQB->TQB_CODBEM) == '" + AllTrim(cParCodBem) + "' "
	EndIf 

	// P.E. que permite escolher qual o filtro vai ser aplicado na abertura do browse
	If ExistBlock( 'MNTA2961' )

		nRetFil  := ExecBlock( 'MNTA2961', .F., .F., aSMenuPE )

	EndIf

	//Carrega Arquivo temporario
	Processa({|| MNT296TRB(__OPC_TQB__,aSMenuPE[nRetFil])},STR0002,STR0003) //"Aguarde..." ## "Processando Solicitações..."

	//Definicao de tamanho de tela e objetos
	aSize := MsAdvSize(,.F.,430)

	Aadd(aObjects,{030,030,.T.,.T.})
	Aadd(aObjects,{100,100,.T.,.T.})

	aInfo   := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObjects,.T.)

	Define MsDialog oDlg296 Title OemToAnsi(cTitulo) From aSize[7],0 To aSize[6],aSize[5] Of oMainWnd Pixel
	oDlg296:lMaximized := .T.

	//Pop up para filtrar a entrada à rotina, permitindo melhora na performance
	NGPOPUP(aSMenu1,@oMenuFil)
	@ 016, 340 Button oPanelLBtn Prompt STR0092 Of oDlg296 Size 37,11 Pixel Action { |o,x,y| oMenuFil:Activate(523,54,oPanelLBtn) } //"Filtrar S.S"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Estrutura da Tela            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSplitVert       := TSplitter():New(01,01,oDlg296,10,10)
	oSplitVert:SetOrient(0)
	oSplitVert:Align := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Parte Esquerda - Browse SS   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPanelLeft        := TPanel():New(0,0,,oSplitVert,,,,,,10,10,.F.,.F.)
	oPanelLeft:nWidth := (aSize[5]/2)
	oPanelLeft:Align  := CONTROL_ALIGN_ALLCLIENT

	oPanelLCont        := TPanel():New(0,0,,oPanelLeft,,,,,,10,10,.F.,.F.)
	oPanelLCont:nWidth := (aSize[5]/2)
	oPanelLCont:Align  := CONTROL_ALIGN_ALLCLIENT
	oPanelLCont:CoorsUpdate()

	oPanelT1         := TPanel():New(00,00,,oPanelLCont,,,,aNGColor[1],aNGColor[2],200,200,.F.,.F.)
	oPanelT1:nHeight := 25
	oPanelT1:Align   := CONTROL_ALIGN_TOP

	@ 003,013 Say OemToAnsi(STR0004) Of oPanelT1 Color aNGColor[1] Pixel //"Solicitações"

	oPanelLBtn       := TPanel():New(00,00,,oPanelLCont,,,,aNGColor[1],aNGColor[2],12,12,.F.,.F.)
	oPanelLBtn:Align := CONTROL_ALIGN_LEFT

	oPanelMark       := TPanel():New(0,0,,oPanelLCont,,,,,,10,10,.F.,.F.)
	oPanelMark:Align := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria Panel com opcoes de pesquisa no MsSelect³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPanelPesq := TPanel():New(0,0,,oPanelMark,,,,,CLR_WHITE,0,15,.F.,.F.)
	oPanelPesq:Align := CONTROL_ALIGN_TOP

	oCBoxSearch := TComboBox():New(02,02,{|u| If(PCount()>0,cCombo:=u,cCombo)},aMark296[__OPC_TQB__][__POS_DESIND__],100,20,oPanelPesq,,;
	{|| fSeekReg(__OPC_TQB__,oCBoxSearch:nAt,@cGetSearch,.F.)},,,,.T.,,,,,,,,,"cCombo")
	oGetSearch  := TGet():New( 02,105,{|u| If(PCount()>0,cGetSearch:=u,cGetSearch)}, oPanelPesq,096,008,,,;
	0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cGetSearch,,,, )
	oBtnSearch  := TButton():New( 002, 202, STR0010,oPanelPesq,{|| fSeekReg(__OPC_TQB__,oCBoxSearch:nAt,Trim(cGetSearch))},;
	35,11,,,.F.,.T.,.F.,,.F.,,,.F. )	//"Buscar"
	oCBoxSearch:Select((aMark296[__OPC_TQB__][__POS_ALIAS__])->(IndexOrd()))

	aMark296[__OPC_TQB__][__POS_OBJ__] := MsSelect():New(aMark296[__OPC_TQB__][__POS_ALIAS__],"OK",,aMark296[__OPC_TQB__][__POS_FIELDS__],;
	@lInverte,@cMarca,{0,0,1500,1500},,,oPanelMark,,aMark296[__OPC_TQB__][__POS_LEG__])
	aMark296[__OPC_TQB__][__POS_OBJ__]:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	aMark296[__OPC_TQB__][__POS_OBJ__]:oBrowse:bChange := {|| fbChange()}
	aMark296[__OPC_TQB__][__POS_OBJ__]:oBrowse:lCanAllMark := .T.
	aMark296[__OPC_TQB__][__POS_OBJ__]:oBrowse:bAllMark := { || fMrkAll(__OPC_TQB__,cMarca)}

	oPanelTot       := TPanel():New(0,0,,oPanelLCont,,,,aNGColor[1],aNGColor[2],0,012,.F.,.F.)
	oPanelTot:Align := CONTROL_ALIGN_BOTTOM

	__aTotal[__nTotSS] := TSay():New(02, 12, {|| A296TotTRB(aMark296[__OPC_TQB__][__POS_ALIAS__], .T.) },oPanelTot,,TFont():New(,,,,.T.),,,,.T.,aNGColor[1],,200,20)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Botao para esconder parte dir.     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oHideRight       := TBtnBmp2():New(01, 01, 05, 05, "fw_arrow_right", , , , {|| fShowHide(1,oPanelRight,oHideRight)}, oPanelLeft, OemToAnsi(STR0011), , .T.) //"Expandir Browse"
	oHideRight:Align := CONTROL_ALIGN_RIGHT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Parte Direita                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPanelRight        := TPanel():New(0,0,,oSplitVert,,,,,,10,10,.F.,.F.)
	oPanelRight:nWidth := (aSize[5]/2)
	oPanelRight:Align  := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Botao para esconder parte esq.     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oHideLeft       := TBtnBmp2():New(01, 01, 05, 05, "fw_arrow_left", , , , {|| fShowHide(2,oPanelLeft,oHideLeft)}, oPanelRight, OemToAnsi(STR0012), , .T.) //"Esconder Browse"
	oHideLeft:Align := CONTROL_ALIGN_LEFT

	oSplitHor       := TSplitter():New(01,01,oPanelRight,10,10)
	oSplitHor:SetOrient(1)
	oSplitHor:Align := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Direita/Cima - Detalhes SS   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPanelRUp         := TPanel():New(0,0,,oSplitHor,,,,,,10,10,.F.,.F.)
	oPanelRUp:nHeight := ((aSize[7]-aSize[6])/2)
	oPanelRUp:Align   := CONTROL_ALIGN_TOP

	oPanelT2         := TPanel():New(00,00,,oPanelRUp,,,,aNGColor[1],aNGColor[2],200,200,.F.,.F.)
	oPanelT2:nHeight := 25
	oPanelT2:Align   := CONTROL_ALIGN_TOP

	@ 003,013 Say OemToAnsi(STR0013) Of oPanelT2 Color aNGColor[1] Pixel //"Detalhes da Solicitação"

	oPanelR1Btn       := TPanel():New(00,00,,oPanelRUp,,,,aNGColor[1],aNGColor[2],12,12,.F.,.F.)
	oPanelR1Btn:Align := CONTROL_ALIGN_LEFT

	oBtnAltSS         := TBtnBmp():NewBar("ng_ico_altss","ng_ico_altss",,,,{|| fAtuEnc(,.T.,4)},,oPanelR1Btn,,,STR0014,,,,,"") //"Alterar Solicitação"
	oBtnAltSS:Align   := CONTROL_ALIGN_TOP

	bGravaEnc         := {|| fGravaEnc()}

	oPanelEnc       := TPanel():New(00,00,,oPanelRUp,,,,,,200,200,.F.,.F.)
	oPanelEnc:Align := CONTROL_ALIGN_ALLCLIENT

	//Criacao das Variaveis da Enchoice
	dbSelectArea("TQB")
	dbSetOrder(1)
	dbSeek(xFilial("TQB") + (aMark296[__OPC_TQB__][__POS_ALIAS__])->TQB_SOLICI)
	MNT280CPO(2,2)
	MNT280REG(2, a280Relac, a280Memos)

	oEncSS            := MsMGet():New("TQB",TQB->(Recno()),4,,,,a280Choice,{0,0,500,500},,3,,,,oPanelEnc)
	oEncSS:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Botao para esconder parte de baixo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oHideBottom       := TBtnBmp2():New(01, 01, 05, 05, "fw_arrow_down", , , , {|| fShowHide(3,oPanelRDown,oHideBottom)}, oPanelRUp, OemToAnsi(STR0021), , .T.) //"Expandir Detalhes da S.S."
	oHideBottom:Align := CONTROL_ALIGN_BOTTOM

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Direita/Baixo - Atendentes   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPanelRDown         := TPanel():New(0,0,,oSplitHor,,,,,,10,10,.F.,.F.)
	oPanelRDown:nHeight := ((aSize[7]-aSize[6])/2)
	oPanelRDown:Align   := CONTROL_ALIGN_BOTTOM

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Botao para esconder parte de cima  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oHideTop       := TBtnBmp2():New(01, 01, 05, 05, "fw_arrow_top", , , , {|| fShowHide(4,oPanelRUp,oHideTop)}, oPanelRDown, OemToAnsi(STR0022), , .T.) //"Expandir Browse Atendentes"
	oHideTop:Align := CONTROL_ALIGN_TOP

	oPanelRDCont         := TPanel():New(0,0,,oPanelRDown,,,,,,10,10,.F.,.F.)
	oPanelRDCont:nHeight := ((aSize[7]-aSize[6])/2)
	oPanelRDCont:Align   := CONTROL_ALIGN_ALLCLIENT
	oPanelRDCont:CoorsUpdate()

	oPanelD1:=TPanel():New(00,00,,oPanelRDCont,,,,aNGColor[1],aNGColor[2],200,200,.F.,.F.)
	oPanelD1:nHeight := 25
	oPanelD1:Align   := CONTROL_ALIGN_TOP

	@ 003,013 Say OemToAnsi(STR0023) Of oPanelD1 Color aNGColor[1] Pixel //"Atendentes"

	aButtons1 := {{'ng_ico_filtro', {|o,x,y| oMenuFil:Activate(23,54,oDlg296)}, STR0005, 'oBtnFil', .T.},;
				  {'ng_ico_imp', {|| fImpSS()}, STR0006, 'oBtnImp', .T.},;
				  {'ng_ico_hist', {|| MNT296HIST(Substr((aMark296[__OPC_TQB__][__POS_ALIAS__])->TQB_TIPOSS,1,1),(aMark296[__OPC_TQB__][__POS_ALIAS__])->TQB_CODBEM)}, STR0007, 'oBtnHis', .T.},;
				  {'ng_ico_lgndos', {|| A296LEGEND(1)}, STR0009, 'oBtnLeg', .T.}}
	
	If MNT280REST('TUA_CANCSS')
		aAdd(aButtons1, {'ng_ico_excss', {|| A291Cancel((aMark296[__OPC_TQB__][__POS_ALIAS__])->TQB_FILIAL,(aMark296[__OPC_TQB__][__POS_ALIAS__])->TQB_SOLICI,__cCallDistr)}, STR0008, 'oBtnCancel', .T.})
	EndIf
	
	aButtons2 := {{'ng_ico_questionario', {|| fQuestiSS((aMark296[__OPC_TQB__][__POS_ALIAS__])->TQB_SOLICI)}, STR0017, 'oBtnQuest', .T.},;
				  {'ng_ico_tarefas', {|| fVisualSS((aMark296[__OPC_TQB__][__POS_ALIAS__])->TQB_SOLICI)}, STR0018, 'oBtnDet', .T.},;
				  {'ng_ico_info', {|| fUserSS((aMark296[__OPC_TQB__][__POS_ALIAS__])->TQB_SOLICI)}, STR0019, 'oBtnUser', .T.},;
				  {'ng_ico_conhecimento', {|| fMsDocSS((aMark296[__OPC_TQB__][__POS_ALIAS__])->TQB_SOLICI)}, STR0020, 'oBtnVis', .T.},;
				  {'ng_ico_confirmar', bGravaEnc, STR0015, 'oBtnConf', .F.},;
				  {'ng_ico_cancelar', {|| fDisable(.F.) }, STR0016, 'oBtnCanc', .F.}}


	//Cria folders de atendentes
	fCreateFolder(oPanelRDCont, aSize, @lInverte, @cMarca)

	// Ponto de Entrada para alteração dos Botões no menu
	If ExistBlock('MNTA296A')
		aButtons  := ExecBlock('MNTA296A',.F.,.F., {aButtons1, aButtons2, {}, .F.})
		aButtons1 := aClone(aButtons[1])
		aButtons2 := aClone(aButtons[2])
	EndIf

	For nX := 1 To Len(aButtons1)

		//Define propriedades de cada botão informado no aButtons1
		DEFINE BUTTON &(aButtons1[nX, 4]) RESOURCE aButtons1[nX, 1] OF oPanelLBtn PROMPT "" TOOLTIP aButtons1[nX, 3]
		&(aButtons1[nX, 4]):bLClicked := aButtons1[nX, 2]
		&(aButtons1[nX, 4]):Align := CONTROL_ALIGN_TOP
		&(aButtons1[nX, 4]):lVisible := aButtons1[nX, 5]

	Next nX

	For nX := 1 To Len(aButtons2)

		//Define propriedades de cada botão informado no aButtons2
		DEFINE BUTTON &(aButtons2[nX, 4]) RESOURCE aButtons2[nX,1] OF oPanelR1Btn PROMPT "" TOOLTIP aButtons2[nX,3]
		&(aButtons2[nX, 4]):bLClicked := aButtons2[nX, 2]
		&(aButtons2[nX, 4]):Align := CONTROL_ALIGN_TOP
		&(aButtons2[nX, 4]):lVisible := aButtons2[nX, 5]

	Next nX

	// Carrega Teclas de Atalho
	SetKey(VK_F4, {|| fDistSS() }) // Distribuição de S.S.
	SetKey(VK_F5, {|| A291RfshSS(__cCallDistr) }) // Refresh do Browse de S.S.

	// Colca o Foco no Browse de Distribuição
	aMark296[__OPC_TQB__][__POS_OBJ__]:oBrowse:SetFocus()
	Activate MsDialog oDlg296 On Init (fCreateBar(oDlg296)) Centered

	//Deleta Arquivo temporario
	aMark296[__OPC_TQB__][__POS_ARQ__]:Delete()
	aMark296[__OPC_TP4__][__POS_ARQ__]:Delete()
	aMark296[__OPC_ST1__][__POS_ARQ__]:Delete()
	aMark296[__OPC_SA2__][__POS_ARQ__]:Delete()

	// Limpa variáveis estáticas
	__cFilt296 := ""

	//Retorna variaveis padrao
	NGRETURNPRM(aNGBEGINPRM)

	If !Empty(cParSolici)
		dbSelectArea("TQB")
		dbSetOrder(1)
		dbSeek(xFilial("TQB")+cParSolici)
	EndIf

	FWFreeArray(aButtons)
	FWFreeArray(aButtons1)
	FWFreeArray(aButtons2)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fCreateFolder
Realiza a criacao dos folders de atendentes

@author Roger Rodrigues
@since 12/03/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fCreateFolder(oObjPai, aSize, lInverte, cMarca, cCodSS, lTransfAtend)

	Local oPanelR2Btn
	Local oBtnTrcAte, oBtnLisTer
	Local oFolderAtend
	Local aFoldAtend := {}

	Local cFiltDispo := ""
	Local cFiltEquip := ""
	Local cFiltAtend := "ST1->T1_DISPONI == 'S'"
	Local cFiltTerce := ""
	Local aButtons3  := {}
	Local nX         := 1

	Default lTransfAtend := .F.

	oPanelR2Btn         := TPanel():New(00,00,,oObjPai,,,,aNGColor[1],aNGColor[2],12,12,.F.,.F.)
	oPanelR2Btn:Align   := CONTROL_ALIGN_LEFT
		
	aAdd(aButtons3, {'ng_ico_filtro', {|| fSetFilter((oFolderAtend:nOption+1))}, STR0005, 'oBtnFilAte', .T.})
	aAdd(aButtons3, {'ng_os_troca', {|| fChangeFil((oFolderAtend:nOption+1),cCodSS)}, STR0024, 'oBtnTrcAte', .T.})
	aAdd(aButtons3, {'ng_ico_visualizar', {|| fVisualizar((oFolderAtend:nOption+1))}, STR0025, 'oBtnVisAte', .T.})
	aAdd(aButtons3, {'ng_ico_atendimento', {|| fCallCarga((oFolderAtend:nOption+1))}, STR0026, 'oBtnCarga', .T.})
	aAdd(aButtons3, {'ng_ico_lgndos', {|| A296LEGEND(2)}, STR0027, 'oBtnLegAte', .T.})

	// Ponto de Entrada para alteração dos Botões no menu
	If ExistBlock('MNTA296A')
		aButtons3 := ExecBlock('MNTA296A',.F.,.F., { {}, {}, aButtons3, lTransfAtend })
		aButtons3 := aClone(aButtons3[3])
	EndIf

	For nX := 1 To Len(aButtons3)

		//Define propriedades de cada botão informado no aButtons3
		
		DEFINE BUTTON &(aButtons3[nX, 4]) RESOURCE aButtons3[nX,1] OF oPanelR2Btn PROMPT "" TOOLTIP aButtons3[nX,3]
		&(aButtons3[nX, 4]):bLClicked := aButtons3[nX, 2]
		&(aButtons3[nX, 4]):Align := CONTROL_ALIGN_TOP
		&(aButtons3[nX, 4]):lVisible := aButtons3[nX, 5]

	Next nX


	aAdd(aFoldAtend, STR0028) //"Equipes"
	aAdd(aFoldAtend, STR0023) //"Atendentes"
	aAdd(aFoldAtend, STR0029) //"Terceiros"

	//Cria estrutura de arquivo temporario e markbrowse
	fCreateTRB(__OPC_TP4__)
	fCreateTRB(__OPC_ST1__)
	fCreateTRB(__OPC_SA2__)

	//Carrega Arquivo temporario
	If lTransfAtend

		// Filtro
		cFiltDispo := "fAtendFiltro('"+ cCodSS + "', TIPO_ATEND, COD_FILIAL, COD_ATEND, COD_LOJA)"

		// Tipo de Atendente 1=Equipe
		cFiltEquip := StrTran(cFiltDispo, "TIPO_ATEND", "'1'")
		cFiltEquip := StrTran(cFiltEquip, "COD_FILIAL", "TP4->TP4_FILIAL")
		cFiltEquip := StrTran(cFiltEquip, "COD_ATEND" , "TP4->TP4_CODIGO")
		cFiltEquip := StrTran(cFiltEquip, "COD_LOJA"  , "''")

		// Tipo de Atendente 2=Atendente
		cFiltAtend := StrTran(cFiltDispo, "TIPO_ATEND", "'2'")
		cFiltAtend := StrTran(cFiltAtend, "COD_FILIAL", "ST1->T1_FILIAL")
		cFiltAtend := StrTran(cFiltAtend, "COD_ATEND" , "ST1->T1_CODFUNC")
		cFiltAtend := StrTran(cFiltAtend, "COD_LOJA"  , "''")

		// Tipo de Atendente 3=Terceiro
		cFiltTerce := StrTran(cFiltDispo, "TIPO_ATEND", "'3'")
		cFiltTerce := StrTran(cFiltTerce, "COD_FILIAL", "SA2->A2_FILIAL")
		cFiltTerce := StrTran(cFiltTerce, "COD_ATEND" , "SA2->A2_COD")
		cFiltTerce := StrTran(cFiltTerce, "COD_LOJA"  , "SA2->A2_LOJA")
	EndIf
	Processa({|| MNT296TRB(__OPC_TP4__,cFiltEquip)},STR0002,STR0030) //"Aguarde..." ## "Processando Equipes..."

	oFolderAtend            := TFolder():New( 0,0,aFoldAtend,,oObjPai,,,,.T.,,0,((aSize[7]-aSize[6])/2) )
	oFolderAtend:bSetOption := {|nOption| fChangeFolder(nOption+1, oBtnTrcAte, oBtnLisTer)}
	oFolderAtend:Align      := CONTROL_ALIGN_ALLCLIENT

	//EQUIPES
	aMark296[__OPC_TP4__][__POS_OBJ__] := MsSelect():New(aMark296[__OPC_TP4__][__POS_ALIAS__],"OK",,aMark296[__OPC_TP4__][__POS_FIELDS__],;
	@lInverte,@cMarca,{0,0,1500,1500},,,oFolderAtend:aDialogs[1],,aMark296[__OPC_TP4__][__POS_LEG__])
	aMark296[__OPC_TP4__][__POS_OBJ__]:oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT
	aMark296[__OPC_TP4__][__POS_OBJ__]:oBrowse:lCanAllMark := .F.
	aMark296[__OPC_TP4__][__POS_OBJ__]:bMark               := {|| fMarkBrw(__OPC_TP4__,lTransfAtend,@cMarca)}
	aMark296[__OPC_TP4__][__POS_OBJ__]:oBrowse:Refresh(.T.)

	//ATENDENTES
	aMark296[__OPC_ST1__][__POS_OBJ__] := MsSelect():New(aMark296[__OPC_ST1__][__POS_ALIAS__],"OK",,aMark296[__OPC_ST1__][__POS_FIELDS__],;
	@lInverte,@cMarca,{0,0,1500,1500},,,oFolderAtend:aDialogs[2],,aMark296[__OPC_ST1__][__POS_LEG__])
	aMark296[__OPC_ST1__][__POS_OBJ__]:oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT
	aMark296[__OPC_ST1__][__POS_OBJ__]:oBrowse:lCanAllMark := .F.
	aMark296[__OPC_ST1__][__POS_OBJ__]:bMark               := {|| fMarkBrw(__OPC_ST1__,lTransfAtend,@cMarca)}
	aMark296[__OPC_ST1__][__POS_OBJ__]:oBrowse:Refresh(.T.)

	//TERCEIROS
	aMark296[__OPC_SA2__][__POS_OBJ__] := MsSelect():New(aMark296[__OPC_SA2__][__POS_ALIAS__],"OK",,aMark296[__OPC_SA2__][__POS_FIELDS__],;
	@lInverte,@cMarca,{0,0,1500,1500},,,oFolderAtend:aDialogs[3],,aMark296[__OPC_SA2__][__POS_LEG__])
	aMark296[__OPC_SA2__][__POS_OBJ__]:oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT
	aMark296[__OPC_SA2__][__POS_OBJ__]:oBrowse:lCanAllMark := .F.
	aMark296[__OPC_SA2__][__POS_OBJ__]:bMark               := {|| fMarkBrw(__OPC_SA2__,lTransfAtend,@cMarca)}
	aMark296[__OPC_SA2__][__POS_OBJ__]:oBrowse:Refresh(.T.)

	//Atualiza markbrowses
	fChgStatus(__OPC_TP4__,cCodSS)
	fChgStatus(__OPC_ST1__,cCodSS)
	fChgStatus(__OPC_SA2__,cCodSS)

	FWFreeArray(aButtons3)

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
	Local nIndx
	Local nFld
	Local nPosDel
	Local oTmpMark
	Local cAliasDic
	Local cAliasTRB := GetNextAlias()
	Local cAliasTmp := "aMark296["+cValToChar(nOpcao)+"]["+cValToChar(__POS_ALIAS__)+"]"
	Local aCritic 	:= {}
	Local aDBF 		:= {}
	Local aVirtual 	:= {}
	Local aFields 	:= {}
	Local aLegenda 	:= {}
	Local vInd 		:= {}
	Local vDesInd 	:= {}
	Local aFldIdx 	:= {}
	Local aExpDel 	:= { "DTOS" , "DESCEND" }
	Local aHeadTQB	:= {}
	Local aHeadTUR	:= {}

	Local nTamTot 	:= 0
	Local nInd		:= 0
	Local cCampo	:= ""
	Local cTipo		:= ""
	Local cCBox		:= ""
	Local nTamanho	:= 0
	Local nDecimal	:= 0
	Local cBrowse	:= ""
	Local cContext	:= ""
	Local cIniBrw	:= ""
	Local cRelacao	:= ""

	// Montagem do Markbrowse e arquivo temporario
	If nOpcao == __OPC_TQB__
		aADD(aDBF,{"OK"			, "C", 2	,0	})
		aADD(aDBF,{"TQB_SOLICI"	, "C", TAMSX3("TQB_SOLICI")[1], TAMSX3("TQB_SOLICI")[2]	})
		aADD(aDBF,{"CRITICID"	, "N", TAMSX3("TQB_CRITIC")[1], 0	})

		aADD(aFields, {"OK"			, Nil, "", "" })
		aADD(aFields, {"TQB_SOLICI"	, Nil, RetTitle("TQB_SOLICI"), PesqPict("TQB", "TQB_SOLICI")	})

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

			If (aScan(aDBF,{|x| Trim(Upper(x[1])) == Trim(Upper(cCampo))}) ) == 0 .And. AllTrim(cTipo) != "M"
				aADD(aDBF, {AllTrim(cCampo), AllTrim(cTipo),If(!Empty(cCBox),20,nTamanho) , nDecimal })//TRB
				//Se for do Browse
				If AllTrim(Upper(cBrowse)) == "S"
					If (aScan(aFields,{|x| Trim(Upper(x[1])) == Trim(Upper(cCampo))}) ) == 0
						aADD(aFields, {AllTrim(cCampo), Nil, RetTitle(AllTrim(cCampo)), PesqPict("TQB", AllTrim(cCampo))})//Tela
						//Se o campo for virtual guarda o Ini. Browse
						If !Empty(cCBox)
							aADD(aVirtual, {AllTrim(cCampo), "COMBO"})
						ElseIf cContext == "V"
							aADD(aVirtual, {AllTrim(cCampo), AllTrim(cIniBrw)})
						EndIf
					EndIf
				ElseIf !Empty(cCBox)
					aADD(aVirtual, {AllTrim(cCampo), "COMBO"})
				ElseIf cContext == "V"
					aADD(aVirtual, {AllTrim(cCampo), AllTrim(cRelacao)})
				EndIf
			EndIf
		Next nInd

		aAdd(vInd, "TQB_FILIAL+TQB_SOLICI")
		aAdd(vDesInd, RetTitle("TQB_SOLICI"))

		// Recebe o Índice inicial
		If __nIndTQB == 0
			__nIndTQB := Len(vInd)
		EndIf
		//Carrega indices
		dbSelectArea("SIX")
		dbSetOrder(1)
		dbSeek("TQB")
		While !EoF() .And. SIX->INDICE == "TQB"
			If !("TQB_CDSERV" $ SIX->CHAVE) .And. !("TQB_CDEXEC" $ SIX->CHAVE) .And. !("TQB_FUNEXE" $ SIX->CHAVE) .And.;
			aScan(vInd, {|x| AllTrim(x) == AllTrim(SIX->CHAVE)}) == 0
				aAdd(vInd, AllTrim(SIX->CHAVE))
				aAdd(vDesInd, AllTrim(SixDescricao()))
			EndIf
			dbSelectArea("SIX")
			dbSkip()
		End

		//Definicao da Legenda do MarkBrowse
		aCritic := MNT293CRI()
		For i:=1 to Len(aCritic)
			If aCritic[i][3] == 0
				aAdd(aLegenda, {"Substr(("+cAliasTmp+")->TQB_TPSERV,1,1) == '1'",aCritic[i][1]})
			ElseIf aCritic[i][3] == 0.5
				aAdd(aLegenda, {"Substr(("+cAliasTmp+")->TQB_TPSERV,1,1) == '2'",aCritic[i][1]})
			Else
				aAdd(aLegenda, {"("+cAliasTmp+")->TQB_CRITIC >= "+cValToChar(aCritic[i][3])+" .And. ("+cAliasTmp+")->TQB_CRITIC <= "+cValToChar(aCritic[i][4]),aCritic[i][1]})
			EndIf
		Next i

		cAliasDic := "TQB"
	ElseIf nOpcao == __OPC_TP4__
		aADD(aDBF,{"OK"		, "C", 2	,0	})
		aADD(aDBF,{"FILATE"	, "C", TAMSX3("TUH_FILATE")[1], TAMSX3("TUH_FILATE")[2]	})
		aADD(aDBF,{"CODATE"	, "C", TAMSX3("TUH_CODATE")[1], TAMSX3("TUH_CODATE")[2]	})
		aADD(aDBF,{"LOJATE"	, "C", TAMSX3("TUH_LOJATE")[1], TAMSX3("TUH_LOJATE")[2]	})
		aADD(aDBF,{"DESATE"	, "C", TAMSX3("TUH_DESATE")[1], TAMSX3("TUH_DESATE")[2]	})
		aADD(aDBF,{"STATATE"	, "C", 1	,0	})

		aADD(aFields, {"OK"	  	, Nil, "", "" })
		aADD(aFields, {"FILATE"	, Nil, STR0033 , PesqPict("TUH", "TUH_FILATE")	}) //"Filial"
		aADD(aFields, {"CODATE"	, Nil, STR0034 , PesqPict("TUH", "TUH_CODATE")	}) //"Equipe"
		aADD(aFields, {"DESATE"	, Nil, STR0035 , PesqPict("TUH", "TUH_DESATE")	}) //"Descrição"

		//Carrega indices
		aAdd(vInd, "FILATE+CODATE")
		aAdd(vInd, "DESATE")
		aAdd(vInd, "STATATE")
		aAdd(vInd, "OK")

		//Definicao da Legenda do MarkBrowse
		aAdd(aLegenda, {"("+cAliasTmp+")->STATATE == '0'","BR_VERMELHO"})
		aAdd(aLegenda, {"("+cAliasTmp+")->STATATE == '1'","BR_VERDE"})

		cAliasDic := "TP4"

	ElseIf nOpcao == __OPC_ST1__
		aADD(aDBF,{"OK"		, "C", 2	,0	})
		aADD(aDBF,{"FILATE"	, "C", TAMSX3("TUH_FILATE")[1], TAMSX3("TUH_FILATE")[2]	})
		aADD(aDBF,{"CODATE"	, "C", TAMSX3("TUH_CODATE")[1], TAMSX3("TUH_CODATE")[2]	})
		aADD(aDBF,{"LOJATE"	, "C", TAMSX3("TUH_LOJATE")[1], TAMSX3("TUH_LOJATE")[2]	})
		aADD(aDBF,{"DESATE"	, "C", TAMSX3("TUH_DESATE")[1], TAMSX3("TUH_DESATE")[2]	})
		aADD(aDBF,{"STATATE"	, "C", 1	,0	})

		aADD(aFields, {"OK"		, Nil, "", "" })
		aADD(aFields, {"FILATE"	, Nil, STR0033 , PesqPict("TUH", "TUH_FILATE")	}) //"Filial"
		aADD(aFields, {"CODATE"	, Nil, STR0037 , PesqPict("TUH", "TUH_CODATE")	}) //"Atendente"
		aADD(aFields, {"DESATE"	, Nil, STR0038 , PesqPict("TUH", "TUH_DESATE")	}) //"Nome"

		//Carrega indices
		aAdd(vInd, "FILATE+CODATE")
		aAdd(vInd, "DESATE")
		aAdd(vInd, "STATATE")
		aAdd(vInd, "OK")

		//Definicao da Legenda do MarkBrowse
		aAdd(aLegenda, {"("+cAliasTmp+")->STATATE == '0'","BR_VERMELHO"})
		aAdd(aLegenda, {"("+cAliasTmp+")->STATATE == '1'","BR_VERDE"})

		cAliasDic := "ST1"

	ElseIf nOpcao == __OPC_SA2__
		aADD(aDBF,{"OK"		, "C", 2	,0	})
		aADD(aDBF,{"FILATE"	, "C", TAMSX3("TUH_FILATE")[1], TAMSX3("TUH_FILATE")[2]	})
		aADD(aDBF,{"CODATE"	, "C", TAMSX3("A2_COD")[1], TAMSX3("A2_COD")[2]	})
		aADD(aDBF,{"LOJATE"	, "C", TAMSX3("A2_LOJA")[1], TAMSX3("A2_LOJA")[2]	})
		aADD(aDBF,{"DESATE"	, "C", TAMSX3("TUH_DESATE")[1], TAMSX3("TUH_DESATE")[2]	})
		aADD(aDBF,{"STATATE"	, "C", 1	,0	})

		aADD(aFields, {"OK"		, Nil, "", "" })
		aADD(aFields, {"CODATE"	, Nil, STR0039 , PesqPict("SA2", "A2_COD")	}) //"Fornecedor"
		aADD(aFields, {"LOJATE"	, Nil, STR0040 , PesqPict("SA2", "A2_LOJA")	}) //"Loja"
		aADD(aFields, {"DESATE"	, Nil, STR0035 , PesqPict("SA2", "TUH_DESATE")	}) //"Descrição"

		//Carrega indices
		aAdd(vInd, "CODATE+LOJATE")
		aAdd(vInd, "DESATE")
		aAdd(vInd, "STATATE")
		aAdd(vInd, "OK")

		//Definicao da Legenda do MarkBrowse
		aAdd(aLegenda, {"("+cAliasTmp+")->STATATE == '0'","BR_VERMELHO"})
		aAdd(aLegenda, {"("+cAliasTmp+")->STATATE == '1'","BR_VERDE"})

		cAliasDic := "SA2"
	ElseIf nOpcao == __OPC_TUR__
		aADD(aDBF,{"OK"		, "C", 2	,0	})
		aADD(aDBF,{"STATATE"	, "C", 1	,0	})

		aADD(aFields, {"OK"		, Nil, "", "" })

		//Carrega os campos do TRB e do Browse
		aHeadTUR := NGHeader("TUR")
		nTamTot := Len(aHeadTUR)

		For nInd := 1 to nTamTot
			cCampo 		:= aHeadTUR[nInd,2]
			cTipo		:= aHeadTUR[nInd,8]
			cCBox		:= Posicione("SX3",2,cCampo,"X3CBox()")
			nTamanho	:= aHeadTUR[nInd,4]
			nDecimal	:= aHeadTUR[nInd,5]
			cBrowse		:= Posicione("SX3",2,cCampo,"X3_BROWSE")
			cContext	:= aHeadTUR[nInd,10]
			cIniBrw		:= Posicione("SX3",2,cCampo,"X3_INIBRW")
			cRelacao	:= Posicione("SX3",2,cCampo,"X3_RELACAO")

			If (aScan(aDBF,{|x| Trim(Upper(x[1])) == Trim(Upper(cCampo))}) ) == 0 .And. AllTrim(cTipo) != "M"
				aADD(aDBF, {AllTrim(cCampo), AllTrim(cTipo),If(!Empty(cCBox),20,nTamanho) , nDecimal })//TRB
				//Se for do Browse
				If AllTrim(Upper(cBrowse)) == "S" .And. Trim(cCampo) != "TUR_SOLICI"
					If (aScan(aFields,{|x| Trim(Upper(x[1])) == Trim(Upper(cCampo))}) ) == 0
						aADD(aFields, {AllTrim(cCampo), Nil, RetTitle(AllTrim(cCampo)), PesqPict("TUR", AllTrim(cCampo))})//Tela
						//Se o campo for virtual guarda o Ini. Browse
						If !Empty(cCBox)
							aADD(aVirtual, {AllTrim(cCampo), "COMBO"})
						ElseIf cContext == "V"
							aADD(aVirtual, {AllTrim(cCampo), AllTrim(cIniBrw)})
						EndIf
					EndIf
				ElseIf !Empty(cCBox)
					aADD(aVirtual, {AllTrim(cCampo), "COMBO"})
				ElseIf cContext == "V"
					aADD(aVirtual, {AllTrim(cCampo), AllTrim(cRelacao)})
				EndIf
			EndIf
		Next nInd

		//Carrega indices
		dbSelectArea("SIX")
		dbSetOrder(1)
		dbSeek("TUR")
		While !EoF() .And. SIX->INDICE == "TUR"
			If aScan(vInd, {|x| AllTrim(x) == AllTrim(SIX->CHAVE)}) == 0
				aAdd(vInd, AllTrim(SIX->CHAVE))
				aAdd(vDesInd, AllTrim(SixDescricao()))
			EndIf
			dbSelectArea("SIX")
			dbSkip()
		End

		//Definicao da Legenda do MarkBrowse
		aAdd(aLegenda, {"("+cAliasTmp+")->STATATE == '0'", "BR_AZUL"   , STR0041 }) // Registro Original da TUR ## "Atendente Original da S.S."
		aAdd(aLegenda, {"("+cAliasTmp+")->STATATE == '1'", "BR_LARANJA", STR0042 }) // Novo Registro de Atendente (Alocando um novo atendente - temporário) ## "Novo Atendente para a S.S."

		cAliasDic := "TUR"
	EndIf

	oTmpMark := FWTemporaryTable():New(cAliasTRB, aDBF)
	For nIndx := 1 To Len(vInd)
		aFldIdx := StrTokArr( vInd[nIndx], "+" )

		For nFld := 1 To Len( aFldIdx )
			If ( nPosDel := aScan( aExpDel , { | x | AllTrim( Upper( x ) ) $ Upper( aFldIdx[ nFld ] ) } ) ) > 0
				aFldIdx[ nFld ] := SubStr( aFldIdx[ nFld ] , Len( aExpDel[ nPosDel ] ) + 2 )
				aFldIdx[ nFld ] := SubStr( aFldIdx[ nFld ] , 1 , Len( aFldIdx[ nFld ] ) - 1 )
			EndIf
		Next nFld
		oTmpMark:AddIndex( "Ind" + cValToChar( nIndx ) , aFldIdx )
	Next nIndx
	oTmpMark:Create()

	//Preenche array do markbrowse
	aMark296[nOpcao][__POS_OBJ__]   := Nil
	aMark296[nOpcao][__POS_FIELDS__]:= aFields
	aMark296[nOpcao][__POS_DBF__]   := aDBF
	aMark296[nOpcao][__POS_IND__]   := vInd
	aMark296[nOpcao][__POS_VIR__]   := aVirtual
	aMark296[nOpcao][__POS_ARQ__]   := oTmpMark
	aMark296[nOpcao][__POS_ALIAS__] := cAliasTRB
	aMark296[nOpcao][__POS_LEG__]   := aLegenda
	aMark296[nOpcao][__POS_ALIDIC__]:= cAliasDic
	aMark296[nOpcao][__POS_FILTER__]:= ""
	aMark296[nOpcao][__POS_DESIND__]:= vDesInd
	aMark296[nOpcao][__POS_FILIAL__]:= xFilial(cAliasDic)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT296TRB
Carrega arquivo temporario com solicitacoes de servico

@param nOpcao Opcao de alias a ser carregado
@param cFiltro Filtro a ser aplicado no alias a ser carregado

@author Roger Rodrigues
@since 07/06/2011
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Function MNT296TRB(nOpcao, cFiltro, cMarca)

	Local i, nPos
	Local cCampo     := ""
	Local cValor     := Nil
	Local cAliasMark := aMark296[nOpcao][__POS_ALIAS__]
	Local cCodFil    := xFilial(aMark296[nOpcao][__POS_ALIDIC__], aMark296[nOpcao][__POS_FILIAL__])
	Local aFuncio    := {}
	Local lFilST1TP4 := ( xFilial("ST1") == xFilial("TP4") )
	// [LGPD] Se as funcionalidades, referentes à LGPD, podem ser utilizadas	
	Local lLgpd := FindFunction( 'FWPDCanUse' ) .And. FwPdCanUse( .T. )
	Local lNomeFun := .F. 
	Local lNomeFor := .F. 
	Local aOfusc := {} 	
	Local aUsrTQB := {}	
				
	Default cFiltro  := ""

	If lLgpd
		// [LGPD] Caso o usuário não possua acesso ao(s) campo(s), deve-se ofuscá-lo(s)
		aOfusc := FwProtectedDataUtil():UsrAccessPDField( __CUSERID, { 'T1_NOME', 'A2_NREDUZ' } )
		lNomeFun := Ascan( aOfusc, { |x|  AllTrim(x) == 'T1_NOME' } ) == 0
		lNomeFor := Ascan( aOfusc, { |x|  AllTrim(x) == 'A2_NREDUZ' } ) == 0
	EndIf

	//Limpa Arquivo temporario
	dbSelectArea(cAliasMark)
	If nOpcao != __OPC_ST1__ .And. !Empty(cFiltro)
		Zap
	EndIf

	//Carrega solicitacao
	If nOpcao == __OPC_TQB__
		dbSelectArea("TQB")
		dbSetOrder(1)
		dbSeek(cCodFil)
		ProcRegua(TQB->(RecCount()))
		While !Eof() .And. cCodFil == TQB->TQB_FILIAL
			IncProc()

			// Filtro Obrigatório de S.S.'s A=Aguardando Análise
			If TQB->TQB_SOLUCA != "A"
				dbSelectArea("TQB")
				dbSkip()
				Loop
			EndIf
			// Filtro Personalizado
			If !Empty(cFiltro) .And. !Eval( &("{||"+cFiltro+"}") )
				dbSelectArea("TQB")
				dbSkip()
				Loop
			EndIf

			// Filtro Padrão da Rotina
			If !Empty(__cFilt296) .And. !Eval( &("{||"+__cFilt296+"}") )
				dbSelectArea("TQB")
				dbSkip()
				Loop
			EndIf
			aUsrTQB := {}
			If !HmGet( oHashSol, TQB->TQB_CDSOLI, @aUsrTQB ) 
				aUsrTQB := FWSFLoadUser( TQB_CDSOLI,,,3 ) // Quarto parâmetro busca pelo Id do usuário
				If Len(aUsrTQB) > 0
					HmAdd( oHashSol, { TQB->TQB_CDSOLI, aUsrTQB[ 4 ], aUsrTQB[ 5 ] } )
				EndIf
			EndIf

			aUsrTQB := {}
			If !Empty( cCodResp := Posicione('TQ3', 1, xFilial( 'TQ3' ) + TQB->TQB_CDSERV, 'TQ3_CDRESP') ) .And.;
				!HmGet( oHashResp, cCodResp, @aUsrTQB ) 
				aUsrTQB := FWSFLoadUser( cCodResp,,,1 ) // Quarto parâmetro busca pelo Id do usuário
				If Len(aUsrTQB) > 0
					HmAdd( oHashResp, { cCodResp, aUsrTQB[ 4 ], aUsrTQB[ 5 ] } )
				EndIf
			EndIf
			// Adiciona
			dbSelectArea(cAliasMark)
			RecLock(cAliasMark,.T.)
			For i:=1 to FCount()
				cCampo := Upper(Trim(FieldName(i)))
				cValor := Nil
				If cCampo == "OK"
					cValor := Space(2)
				ElseIf cCampo == "CRITICID"
					cValor := TQB->TQB_CRITIC
				ElseIf (nPos := aScan(aMark296[nOpcao][__POS_VIR__],{|x| Trim(Upper(x[1])) == cCampo}) ) > 0//Verifica se o campo tem Inicializador
					//Executa Combo
					If aMark296[nOpcao][__POS_VIR__][nPos][2] == "COMBO"
						If !Empty(&("TQB->"+cCampo))
							cValor := &("TQB->"+cCampo)+"="+NGRETSX3BOX(cCampo,&("TQB->"+cCampo))
						EndIf
					ElseIf !Empty(aMark296[nOpcao][__POS_VIR__][nPos][2])//Executa Inicializador
						cValor := &(aMark296[nOpcao][__POS_VIR__][nPos][2])
					EndIf
				Else//Grava normalmente
					cValor := &("TQB->"+cCampo)
				EndIf
				If ValType(cValor) != "U"
					dbSelectArea(cAliasMark)
					FieldPut(i, cValor)
				EndIf
			Next i
			MsUnlock(cAliasMark)

			dbSelectArea("TQB")
			dbSkip()
		End
		dbSelectArea(cAliasMark)
		dbSetOrder(__nIndTQB)
		dbGoTop()
		//Refresh das informações em tela após a execução do filtro
		If Type("aMark296["+cValToChar(__OPC_TQB__)+"]["+cValToChar(__POS_OBJ__)+"]") <> "U"
			aMark296[__OPC_TQB__][__POS_OBJ__]:oBrowse:Refresh(.T.)
			Eval( aMark296[__OPC_TQB__][__POS_OBJ__]:oBrowse:bChange := {|| fAtuEnc(,.F.,2)})
			__aTotal[__nTotSS]:Refresh()
		EndIf

	ElseIf nOpcao == __OPC_TP4__
		dbSelectArea("TP4")
		dbSetOrder(1)
		dbSeek(cCodFil)
		While !EoF() .And. cCodFil == TP4->TP4_FILIAL
			// Filtro Obrigatório de Responsáveis da Equipe (ST1) que atendem 2=Facilities ou 3=Ambos
			dbSelectArea("ST1")
			dbSetOrder(1)
			If dbSeek(If(lFilST1TP4, cCodFil, xFilial("ST1")) + TP4->TP4_CODRES) .And. !(ST1->T1_TIPATE $ "2/3")
				dbSelectArea("TP4")
				dbSkip()
				Loop
			EndIf
			dbSelectArea("TP4")
			// Filtro personalizado
			If !Empty(cFiltro) .And. !Eval( &("{||"+cFiltro+"}") )
				dbSelectArea("TP4")
				dbSkip()
				Loop
			EndIf
			// Adiciona
			dbSelectArea(cAliasMark)
			dbSetOrder(1)
			If !dbSeek(TP4->TP4_FILIAL+TP4->TP4_CODIGO)
				RecLock(cAliasMark,.T.)
				(cAliasMark)->FILATE := TP4->TP4_FILIAL
				(cAliasMark)->CODATE := TP4->TP4_CODIGO
				(cAliasMark)->DESATE := TP4->TP4_DESCRI
				MsUnlock(cAliasMark)
			ElseIf Empty(cFiltro)
				Exit
			EndIf
			dbSelectArea("TP4")
			dbSkip()
		End
	ElseIf nOpcao == __OPC_ST1__
		aFuncio  := fRetATMrk(__OPC_ST1__)
		dbSelectArea(cAliasMark)
		dbSetOrder(1)
		dbGoTop()
		While !Eof()
			If aScan(aFuncio, {|x| x[2]+x[3] == (cAliasMark)->FILATE+(cAliasMark)->CODATE}) == 0
				RecLock(cAliasMark,.F.)
				dbDelete()
				MsUnlock(cAliasMark)
			EndIf
			dbSelectArea(cAliasMark)
			dbSkip()
		End
		dbSelectArea("ST1")
		dbSetOrder(1)
		dbSeek(cCodFil)
		While !Eof() .And. cCodFil == ST1->T1_FILIAL
			// Filtro Obrigatório de Funcionários (ST1) que atendem 2=Facilities ou 3=Ambos
			If !(ST1->T1_TIPATE $ "2/3")
				dbSelectArea("ST1")
				dbSkip()
				Loop
			EndIf
			// Filtro personalizado
			If !Empty(cFiltro) .And. !Eval( &("{||"+cFiltro+"}") )
				dbSelectArea("ST1")
				dbSkip()
				Loop
			EndIf
			// Adiciona
			dbSelectArea(cAliasMark)
			dbSetOrder(1)
			If !dbSeek(ST1->T1_FILIAL+ST1->T1_CODFUNC)
				RecLock(cAliasMark,.T.)
				(cAliasMark)->FILATE := ST1->T1_FILIAL
				(cAliasMark)->CODATE := ST1->T1_CODFUNC
				(cAliasMark)->DESATE := IIf( lNomeFun, FwProtectedDataUtil():ValueAsteriskToAnonymize( ST1->T1_NOME ), ST1->T1_NOME )  
				MsUnlock(cAliasMark)
			ElseIf Empty(cFiltro)
				Exit
			EndIf
			dbSelectArea("ST1")
			dbSkip()
		End
	ElseIf nOpcao == __OPC_SA2__

		dbSelectArea("SA2")
		dbSetOrder(1)
		dbSeek(cCodFil)
		ProcRegua(SA2->(RecCount()))

		While !eof() .and. cCodFil == SA2->A2_FILIAL
			IncProc()

			// Filtro personalizado
			If !Empty(cFiltro) .and. !Eval( &("{||"+cFiltro+"}") )
				dbSelectArea("SA2")
				dbSkip()
				Loop
			Endif

			// Adiciona
			dbSelectArea(cAliasMark)
			dbSetOrder(1)
			If !dbSeek(SA2->A2_COD+SA2->A2_LOJA)
				RecLock(cAliasMark,.T.)
				(cAliasMark)->CODATE := SA2->A2_COD
				(cAliasMark)->LOJATE := SA2->A2_LOJA
				(cAliasMark)->DESATE := IIf( lNomeFor, FwProtectedDataUtil():ValueAsteriskToAnonymize( SA2->A2_NREDUZ ), SA2->A2_NREDUZ )   
				MsUnlock(cAliasMark)
			ElseIf Empty(cFiltro)
				Exit
			Endif
			dbSelectArea("SA2")
			dbSkip()
		End

	ElseIf nOpcao == __OPC_TUR__
		dbSelectArea("TUR")
		dbSetOrder(1)
		dbSeek(cCodFil+cFiltro)
		While !EoF() .And. TUR->TUR_FILIAL+TUR->TUR_SOLICI == cCodFil+cFiltro
			If Empty(TUR->TUR_DTFINA) // Não considera atendentes com Data/Hora Final já preenchidas, pos quer dizer que sua participação na S.S. já se encerrou
				// Adiciona
				dbSelectArea(cAliasMark)
				RecLock(cAliasMark,.T.)
				For i:=1 to FCount()
					cCampo := Upper(Trim(FieldName(i)))
					cValor := Nil
					If cCampo == "OK"
						cValor := cMarca // Sempre iniciam MARCADOS os Atendentes da S.S. (TUR)
					ElseIf cCampo == "STATATE"
						cValor := "0"
					ElseIf (nPos := aScan(aMark296[nOpcao][__POS_VIR__],{|x| Trim(Upper(x[1])) == cCampo}) ) > 0//Verifica se o campo tem Inicializador
						//Executa Combo
						If aMark296[nOpcao][__POS_VIR__][nPos][2] == "COMBO"
							If !Empty(&("TUR->"+cCampo))
								cValor := &("TUR->"+cCampo)+"="+NGRETSX3BOX(cCampo,&("TUR->"+cCampo))
							EndIf
						ElseIf !Empty(aMark296[nOpcao][__POS_VIR__][nPos][2])//Executa Inicializador
							cValor := &(aMark296[nOpcao][__POS_VIR__][nPos][2])
						EndIf
					Else//Grava normalmente
						cValor := &("TUR->"+cCampo)
					EndIf
					If ValType(cValor) != "U"
						dbSelectArea(cAliasMark)
						FieldPut(i, cValor)
					EndIf
				Next i
				MsUnlock(cAliasMark)
			EndIf

			dbSelectArea("TUR")
			dbSkip()
		End
	EndIf

	dbSelectArea(cAliasMark)
	dbGoTop()

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fChgStatus
Atualiza status dos executantes

@param nOpcao Markbrowse a ser atualizado
@param cCodSS SS posicionada no browse - Nao Obrigatorio

@author Roger Rodrigues
@since 03/05/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fChgStatus(nOpcao, cCodSS)
	Local cAliasMark := aMark296[nOpcao][__POS_ALIAS__]
	Local aGetArea := fGetArea(cAliasMark)
	Local cStatus := cCodFam := cCdServ := cTipAte := cCusto := ""
	Default cCodSS := (aMark296[__OPC_TQB__][__POS_ALIAS__])->TQB_SOLICI

	CursorWait()
	cTipAte := StrZero(nOpcao-1,1)

	dbSelectArea("TQB")
	dbSetOrder(1)
	If dbSeek(xFilial("TQB")+cCodSS)
		cCdServ := TQB->TQB_CDSERV
		If TQB->TQB_TIPOSS == "B"
			cCodFam := NGSEEK("ST9",TQB->TQB_CODBEM,1,"ST9->T9_CODFAMI")
			cCusto  := NGSEEK("ST9",TQB->TQB_CODBEM,1,"ST9->T9_CCUSTO")
		Else
			cCodFam := NGSEEK("TAF","X2"+Substr(M->TQB_CODBEM,1,3),7,"TAF->TAF_CODFAM")
			cCusto  := NGSEEK("TAF","X2"+Substr(M->TQB_CODBEM,1,3),7,"TAF->TAF_CCUSTO")
		EndIf
	EndIf

	dbSelectArea(cAliasMark)
	dbSetOrder(1)
	dbGoTop()
	While !Eof()
		cStatus := "0"
		If !Empty(cCodFam)
			dbSelectArea("TUH")
			dbSetOrder(1)
			If !Empty(cCdServ)
				cStatus := If(dbSeek(xFilial("TUH")+cCodFam+cCdServ+cTipAte+(cAliasMark)->FILATE+(cAliasMark)->CODATE+(cAliasMark)->LOJATE+cCusto) .or.;
				dbSeek(xFilial("TUH")+cCodFam+cCdServ+cTipAte+(cAliasMark)->FILATE+(cAliasMark)->CODATE+(cAliasMark)->LOJATE+Space(TAMSX3("TUH_CCUSTO")[1])),;
				"1", "0")
			EndIf
			If cStatus == "0"
				cCdServ := Space(TAMSX3("TUH_CDSERV")[1])
				cStatus := If(dbSeek(xFilial("TUH")+cCodFam+cCdServ+cTipAte+(cAliasMark)->FILATE+(cAliasMark)->CODATE+(cAliasMark)->LOJATE+cCusto) .or.;
				dbSeek(xFilial("TUH")+cCodFam+cCdServ+cTipAte+(cAliasMark)->FILATE+(cAliasMark)->CODATE+(cAliasMark)->LOJATE+Space(TAMSX3("TUH_CCUSTO")[1])),;
				"1", "0")
			EndIf
		EndIf

		dbSelectArea(cAliasMark)
		RecLock(cAliasMark, .F.)
		(cAliasMark)->STATATE := cStatus
		MsUnlock(cAliasMark)

		dbSelectArea(cAliasMark)
		dbSkip()
	End

	//Restaura Alias e atualiza mark
	fRestArea(aGetArea)
	aMark296[nOpcao][__POS_OBJ__]:oBrowse:Refresh(.T.)

	CursorArrow()

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
			oBotao:cTooltip := OemToAnsi(STR0012) //"Esconder Browse"
		ElseIf nPanel == 2
			oBotao:LoadBitmaps("fw_arrow_right")
			oBotao:cTooltip := OemToAnsi(STR0011) //"Expandir Browse"
		ElseIf nPanel == 3
			oBotao:LoadBitmaps("fw_arrow_top")
			oBotao:cTooltip := OemToAnsi(STR0022) //"Expandir Browse Atendentes"
		ElseIf nPanel == 4
			oBotao:LoadBitmaps("fw_arrow_down")
			oBotao:cTooltip := OemToAnsi(STR0021) //"Expandir Detalhes da S.S."
		EndIf
	Else
		oPanel:Show()
		If nPanel == 1
			oBotao:LoadBitmaps("fw_arrow_right")
			oBotao:cTooltip := OemToAnsi(STR0011) //"Expandir Browse"
		ElseIf nPanel == 2
			oBotao:LoadBitmaps("fw_arrow_left")
			oBotao:cTooltip := OemToAnsi(STR0012) //"Esconder Browse"
		ElseIf nPanel == 3
			oBotao:LoadBitmaps("fw_arrow_down")
			oBotao:cTooltip := OemToAnsi(STR0021) //"Expandir Detalhes da S.S."
		ElseIf nPanel == 4
			oBotao:LoadBitmaps("fw_arrow_top")
			oBotao:cTooltip := OemToAnsi(STR0022) //"Expandir Browse Atendentes"
		EndIf
	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fQuestiSS
Carrega questionario da solicitacao

@param cCodSS Codigo da SS que sera visualizada a informacao

@author Roger Rodrigues
@since 24/04/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fQuestiSS(cCodSS)
	Local aNGBEGINPRM := NGBEGINPRM()

	dbSelectArea("TQB")
	dbSetOrder(1)
	If !Empty(cCodSS) .And. dbSeek(xFilial("TQB")+cCodSS)
		MNT280DIAG(.F., .F., Nil)
	EndIf

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
Static Function fVisualSS(cCodSS)

	Local aNGBEGINPRM := NGBEGINPRM()
	Local aMemory  := NGGetMemory("TQB")

	dbSelectArea("TQB")
	dbSetOrder(1)
	If !Empty(cCodSS) .And. dbSeek(xFilial("TQB")+cCodSS)
		MNTA280IN(2,1)
	EndIf

	NgRestMemory(aMemory)
	NGRETURNPRM(aNGBEGINPRM)

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fUserSS
Mostra informacoes do solicitante da SS

@param cCodSS Codigo da SS que sera visualizada a informacao

@author Roger Rodrigues
@since 04/03/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fUserSS(cCodSS)
	Local aNGBEGINPRM := NGBEGINPRM()

	dbSelectArea("TQB")
	dbSetOrder(1)
	If !Empty(cCodSS) .And. dbSeek(xFilial("TQB")+cCodSS)
		dbSelectArea("TUF")
		dbSetOrder(1)
		If dbSeek(xFilial("TUF")+TQB->TQB_CDSOLI)
			FWExecView( STR0019 , 'MNTA909' , MODEL_OPERATION_VIEW , , { || .T. } ) //"Informações do Solicitante"
		EndIf
	EndIf

	NGRETURNPRM(aNGBEGINPRM)
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fMsDocSS
Realiza chamada do conhecimento das solicitacoes

@param cCodSS Codigo da SS que sera visualizada a informacao

@author Roger Rodrigues
@since 04/03/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fMsDocSS(cCodSS)
	Local aNGBEGINPRM := NGBEGINPRM()

	dbSelectArea("TQB")
	dbSetOrder(1)
	If !Empty(cCodSS) .And. dbSeek(xFilial("TQB")+cCodSS)
		MsDocument("TQB",TQB->(Recno()),4)
	EndIf

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
	Local aGetArea := fGetArea(aMark296[__OPC_TQB__][__POS_ALIAS__])
	Local aListaSS := fRetSSMrk()

	If Len(aListaSS) > 0
		MNTR120(aListaSS)
	Else
		ShowHelpDlg(STR0043,{STR0044},1,; //"Atenção" ## "Deve ser selecionada pelo menos uma Solicitação de Serviço para impressão."
		{STR0045}) //"Marque uma Solicitação de Serviço."
	EndIf

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
	Local cAliasMrk := aMark296[__OPC_TQB__][__POS_ALIAS__]
	Local aGetArea := fGetArea(cAliasMrk)

	dbSelectArea(cAliasMrk)
	dbSetOrder(1)
	dbGoTop()
	While !Eof()
		If !Empty((cAliasMrk)->OK)
			aAdd(aSSMark, {(cAliasMrk)->TQB_FILIAL, (cAliasMrk)->TQB_SOLICI})
		EndIf
		dbSelectArea(cAliasMrk)
		dbSkip()
	End

	fRestArea(aGetArea)
Return aSSMark
//---------------------------------------------------------------------
/*/{Protheus.doc} fRetATMrk
Retorna array com os atendentes marcados

@param nOpcao Opcao do markbrowse que sera percorrido, no caso de nenhum todos serao - Opcional
@param nRecno Registro que deve ser desconsiderado - Opcional

@author Roger Rodrigues
@since 27/04/2012
@version MP10/MP11
@return aATMark
/*/
//---------------------------------------------------------------------
Static Function fRetATMrk(nOpcao, nRecno)
	Local i
	Local cAliasMrk
	Local aATMark := {}, aGetArea := {}
	Local aOpcAtend := {__OPC_TP4__, __OPC_ST1__, __OPC_SA2__}//Array com possiveis atendentes
	Default nOpcao  := 0
	Default nRecno  := -1

	For i:=1 to Len(aOpcAtend)
		//Verifica se eh a opcao desejada
		If aOpcAtend[i] == nOpcao .or. nOpcao == 0
			cAliasMrk := aMark296[aOpcAtend[i]][__POS_ALIAS__]
			aGetArea := fGetArea(cAliasMrk)
			dbSelectArea(cAliasMrk)
			dbSetOrder(1)
			dbGoTop()
			While !Eof()
				If !Empty((cAliasMrk)->OK) .And. (cAliasMrk)->(Recno()) != nRecno
					aAdd(aATMark, {StrZero(aOpcAtend[i]-1,1), (cAliasMrk)->FILATE, (cAliasMrk)->CODATE, (cAliasMrk)->LOJATE})
				EndIf
				dbSelectArea(cAliasMrk)
				dbSkip()
			End
			fRestArea(aGetArea)
		EndIf
	Next i

Return aATMark
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

	Local cFilterGen := aGetArea[4]

	dbSelectArea(aGetArea[1])
	dbSetOrder(aGetArea[2])
	dbGoTo(aGetArea[3])
	Set Filter To &(cFilterGen)

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
Static Function fMrkAll(nOpcao,cMarca)
	Local lMarca:= .F.
	Local cAliasMrk := aMark296[nOpcao][__POS_ALIAS__]
	Local aGetArea := fGetArea(cAliasMrk)

	//Verifica se existe item desmarcado
	dbSelectArea(cAliasMrk)
	dbSetOrder(1)
	dbGoTop()
	While !EoF()
		If Empty((cAliasMrk)->OK)
			lMarca := .T.
			Exit
		EndIf
		dbSelectArea(cAliasMrk)
		dbSkip()
	End
	//Marca ou desmarca todos
	dbSelectArea(cAliasMrk)
	dbSetOrder(1)
	dbGoTop()
	While !EoF()
		RecLock(cAliasMrk,.F.)
		(cAliasMrk)->OK := If(lMarca, cMarca, Space(2))
		MsUnlock(cAliasMrk)
		dbSelectArea(cAliasMrk)
		dbSkip()
	End

	//Restaura tabela e atualiza browse
	fRestArea(aGetArea)
	aMark296[nOpcao][__POS_OBJ__]:oBrowse:Refresh(.T.)

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
	Local cOldFilt := aMark296[nOpcao][__POS_FILTER__]
	aMark296[nOpcao][__POS_FILTER__] := BuildExpr(aMark296[nOpcao][__POS_ALIDIC__],,aMark296[nOpcao][__POS_FILTER__])
	// Apenas atualiza se o Filtro for diferente
	If AllTrim(aMark296[nOpcao][__POS_FILTER__]) <> cOldFilt
		Processa({|| MNT296TRB(nOpcao, aMark296[nOpcao][__POS_FILTER__]) },STR0002,STR0046) //"Aguarde..." ## "Recarregando..."
		Eval( aMark296[nOpcao][__POS_OBJ__]:oBrowse:bChange  := {|| fbChange()})
	EndIf
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT296HIST
Mostra historico de reincidencia do bem

@param cTipoSS Tipo da SS posicionada
@param cBemLoc Bem/Localizacao da SS posicionada

@author Roger Rodrigues
@since 10/04/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Function MNT296HIST(cTipoSS,cBemLoc)
	Local aGetArea := fGetArea("TQB")
	Local aMemory  := NGGetMemory("TQB")
	Local aNGBEGINPRM := NGBEGINPRM(,"MNTA296")
	Private oBrowse
	Private aRotina := {{STR0047 , "MNTA280IN(2,3)",0, 2},; //"Visualizar"
	{STR0020 , "MsDocument"  ,0, 4},; //"Conhecimento"
	{STR0027 , "A296LEGEND(3)"  ,0, 7}} //"Legenda"

	oBrowse := FwMBrowse():New()
	oBrowse:SetAlias("TQB")
	oBrowse:SetDescription(STR0048) //"Histórico das Solicitações de Serviço"

	//Aplica Filtro
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetFilterDefault("TQB->TQB_FILIAL == '"+xFilial("TQB")+"' .And. TQB->TQB_TIPOSS == '"+cTipoSS+"' .And. TQB->TQB_CODBEM == '"+cBemLoc+"'")

	//Legendas
	oBrowse:AddLegend( "TQB->TQB_SOLUCA == 'A'"	,	"BR_VERMELHO"	,	OemToAnsi(STR0049)) //"Aguardando Análise"
	oBrowse:AddLegend( "TQB->TQB_SOLUCA == 'D'"	,	"BR_VERDE"		,	OemToAnsi(STR0050)) //"Distribuída"
	oBrowse:AddLegend( "MNTA280Atr()"			,	'BR_AMARELO'	,	OemToAnsi(STR0051)) //"Com Atraso Cadastrado"
	oBrowse:AddLegend( "TQB->TQB_SOLUCA == 'E'"	,	'BR_AZUL'		,	OemToAnsi(STR0052)) //"Encerrada"
	oBrowse:AddLegend( "TQB->TQB_SOLUCA == 'C'"	,	'BR_PRETO'		,	OemToAnsi(STR0053)) //"Cancelada"

	oBrowse:AddStatusColumns({ || If(A296REINC(TQB->TQB_TIPOSS, TQB->TQB_CODBEM, TQB->TQB_DTABER, TQB->TQB_CDSERV, TQB->TQB_SOLICI),"BR_PRETO", "BR_BRANCO" ) },{||})

	oBrowse:Activate()

	NGRETURNPRM(aNGBEGINPRM)
	NgRestMemory(aMemory)
	fRestArea(aGetArea)
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} A296LEGEND
Monta tela de Legenda de acordo com os arrays

@param nOpcao Opcao de tela de legenda a ser montada

@author Roger Rodrigues
@since 12/04/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Function A296LEGEND(nOpcao, nOpcTabela, nOpcLegend)
	Local aLegenda := {}, nLeg := 0
	Local cTitulo  := ""
	If nOpcao == 1//Legenda da Criticidade
		MNT293LEG(.F.,.T.,.F.,.F.)
	ElseIf nOpcao == 2 // Legenda do Folder
		aLegenda := {{"BR_VERMELHO"	,STR0054},; //"Não Habilitado"
		{"BR_VERDE"	,STR0055}}  //"Habilitado"
		cTitulo += STR0058 //"Status do Atendente"
	ElseIf nOpcao == 3//Legenda do historico de SS
		aLegenda := {	{"BR_VERMELHO",STR0049},; //"Aguardando Análise"
		{"BR_VERDE"   ,STR0050},; //"Distribuída"
		{"BR_AMARELO" ,STR0051},; //"Com Atraso Cadastrado"
		{"BR_AZUL"    ,STR0052},; //"Encerrada"
		{"BR_PRETO"   ,STR0056},; //"Reincidente"
		{"BR_BRANCO"  ,STR0057}}  //"Não Reincidente"
		cTitulo += STR0059 //"Status da Solicitação"
	ElseIf nOpcao == 4 // Legenda de acordo com os Arrays
		cTitulo := STR0009 //"Legenda"
		For nLeg := 1 To Len(aMark296[nOpcTabela][nOpcLegend])
			If Len(aMark296[nOpcTabela][nOpcLegend][nLeg]) >= 3
				// 1      ; 2
				// Imagem ; Descrição
				aAdd(aLegenda, {aMark296[nOpcTabela][nOpcLegend][nLeg][2], aMark296[nOpcTabela][nOpcLegend][nLeg][3]})
			EndIf
		Next nLeg
	EndIf
	If Len(aLegenda) > 0
		BrwLegenda(cCadastro,cTitulo,aLegenda)
	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fbChange
Executa rotinas ao trocar de SS

@author Roger Rodrigues
@since 03/05/2011
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fbChange()

	Local cCodSS := (aMark296[__OPC_TQB__][__POS_ALIAS__])->TQB_SOLICI

	//Atualiza Enchoice
	fAtuEnc(cCodSS)
	//Atualiza markbrowses
	fChgStatus(__OPC_TP4__,cCodSS)
	fChgStatus(__OPC_ST1__,cCodSS)
	fChgStatus(__OPC_SA2__,cCodSS)

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fAtuEnc
Cria e recria enchoice da solicitacao

@param cCodSS Codigo da SS
@param lDisable Indica se deve desabilitar campos
@param nOpcx Opcao de alteracao da SS

@author Roger Rodrigues
@since 08/06/2011
@version MP10/MP11
@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fAtuEnc(cCodSS, lDisable, nOpcx)

	Local i
	Local aGetArea := fGetArea( 'TQB' )
	Local lRet := .T.

	Default cCodSS := ( aMark296[__OPC_TQB__][__POS_ALIAS__] )->TQB_SOLICI
	Default lDisable := .F.
	Default nOpcx := 2

	// Só permite interação caso não seja alteração, ou se for alteração se estiver psocionado em uma SS
	If ( ( nOpcx == 4 .And. !Empty( cCodSS ) ) .Or. nOpcx != 4 )

		If lDisable
			If !fDisable( .T., .F. )
				lRet := .F.
			EndIf
		EndIf

		If lRet

			dbSelectArea( 'TQB' )
			dbSetOrder( 1 )
			If dbSeek( xFilial( 'TQB' ) + cCodSS )
				MNT280CPO( 2, nOpcx )
				MNT280REG( nOpcx, a280Relac, a280Memos )
			Else
				MNT280CPO( 2, 2 )
				MNT280REG( 0, a280Relac, a280Memos )
			EndIf

			If GetBuild() >= MIN_BUILD_VERSION
				oEncSS:UpdBMP( TQB->TQB_BITMAP )
			EndIf

			//Coloca campo no modo de visualizacao
			For i:=1 to Len(oEncSS:aGets)
				oEncSS:aEntryCtrls[i]:lReadOnly := (nOpcx == 2)
				oEncSS:aEntryCtrls[i]:lActive := (nOpcx == 2)
			Next i

			oEncSS:EnchRefreshAll()

		EndIf

	EndIf

	fRestArea(aGetArea)

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fDisable
Desabilita/Habilita objetos da tela

@param lDisable Indica se deve desabilitar campos
@param lAtuEnc Indica se atualiza enchoice

@author Roger Rodrigues
@since 11/04/2012
@version MP10/MP11
@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fDisable(lDisable,lAtuEnc)
	Local cCodSS := (aMark296[__OPC_TQB__][__POS_ALIAS__])->TQB_SOLICI
	Default lDisable := .T.
	Default lAtuEnc  := .T.

	If lDisable
		// Semáforo para utilização da Alteração de S.S.
		If !LockByName("MNTALTSS"+cCodSS, .T., .T., .F.)
			MsgInfo(STR0060 + " " + cCodSS + " " + STR0061 + CRLF + CRLF + ; //"A Solicitação de Serviço" ## "já está sendo manipulada por outro processo ou usuário."
			STR0062, STR0043 ) //"Por favor, tente novamente mais tarde." ## "Atenção"
			Return .F.
		EndIf

		oPanelLCont:Disable()
		oPanelRDCont:Disable()
		oBtnAltSS:lVisible := .F.
		oBtnConf:lVisible  := .T.
		oBtnCanc:lVisible  := .T.
		oBtnDist:Disable() //Deixa o botão Distrubir desabilitado enquanto está alterando a SS
	Else
		If lAtuEnc
			fAtuEnc()
		EndIf
		oPanelLCont:Enable()
		oPanelRDCont:Enable()
		oBtnAltSS:lVisible := .T.
		oBtnConf:lVisible  := .F.
		oBtnCanc:lVisible  := .F.
		oBtnDist:Enable() //Habilita o botão Distribuir após alterar a SS

		// Libera Semáforo
		UnLockByName("MNTALTSS"+cCodSS, .T., .T., .F.)
	EndIf
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

	dbSelectArea(aMark296[nOpcao][__POS_ALIAS__])
	dbSetOrder(nInd)

	If !lSeek
		cPesquisa := Space(100)
	Else
		cChave := cPesquisa
		If "_FILIAL"$Substr(aMark296[nOpcao][__POS_IND__][nIndex],1,10)
			cChave := xFilial(aMark296[nOpcao][__POS_ALIDIC__])+cChave
		EndIf
		dbSeek(cChave,.T.)
	EndIf

	If !Empty(aMark296[nOpcao][__POS_OBJ__])
		If lSeek
			Eval( aMark296[nOpcao][__POS_OBJ__]:oBrowse:bChange )
		EndIf
		aMark296[nOpcao][__POS_OBJ__]:oBrowse:Refresh(.T.)
	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} A296REINC
Verifica se a SS eh reincidente ou nao

@param cTipo Tipo da SS
@param cBemLoc Bem/Localizacao da SS
@param dDataSS Data da SS
@param cCdServSS Area da SS
@param cCodSS SS a ser excluida da verificacao

@author Roger Rodrigues
@since 12/04/2012
@version MP10/MP11
@return lRet
/*/
//---------------------------------------------------------------------
Function A296REINC(cTipo, cBemLoc, dDataSS, cCdServSS, cCodSS)
	Local aGetArea := fGetArea("TQB")
	Local nDias:= -1
	Local lRet := .F.
	Local cFamilia := Space(TAMSX3("T6_CODFAMI")[1]), cAliasQry, cQuery
	Local dDataUlt := CTOD("")
	Default dDataSS := dDatabase
	Default cCdServSS := Space(TAMSX3("TQ3_CDSERV")[1])
	Default cCodSS  := ""

	If cTipo == "L"
		dbSelectArea("TAF")
		dbSetOrder(2)
		If dbSeek(xFilial("TAF")+"001"+Substr(cBemLoc,1,3))
			cFamilia := TAF->TAF_CODFAM
		EndIf
	Else
		dbSelectArea("ST9")
		dbSetOrder(1)
		If dbSeek(xFilial("ST9")+cBemLoc)
			cFamilia := ST9->T9_CODFAMI
		EndIf
	EndIf

	If !Empty(cFamilia)
		If !Empty(cCdServSS)
			dbSelectArea("TUG")
			dbSetOrder(1)
			If dbSeek(xFilial("TUG")+cFamilia+cCdServSS)
				If TUG->TUG_QTDREI > 0
					If TUG->TUG_UNIREI == "3"//Ano
						nDias := TUG->TUG_QTDREI*365
					ElseIf TUG->TUG_UNIREI == "2"//Mes
						nDias := TUG->TUG_QTDREI*30
					Else
						nDias := TUG->TUG_QTDREI
					EndIf
				EndIf
			Else
				cCdServSS := Space(TAMSX3("TQ3_CDSERV")[1])
			EndIf
		EndIf
		If nDias < 1
			dbSelectArea("TUG")
			dbSetOrder(1)
			If dbSeek(xFilial("TUG")+cFamilia+cCdServSS) .And. TUG->TUG_QTDREI > 0
				If TUG->TUG_UNIREI == "3"//Ano
					nDias := TUG->TUG_QTDREI*365
				ElseIf TUG->TUG_UNIREI == "2"//Mes
					nDias := TUG->TUG_QTDREI*30
				Else
					nDias := TUG->TUG_QTDREI
				EndIf
			EndIf
		EndIf
	EndIf

	//Calcula diferenca
	If nDias > 0
		#IFNDEF TOP
		dbSelectArea("TQB")
		Set Filter To
		dbSetOrder(13)
		dbSeek(xFilial("TQB")+cTipo+cBemLoc)
		While !Eof() .And. xFilial("TQB")+cTipo+cBemLoc == TQB->TQB_FILIAL+TQB->TQB_TIPOSS+TQB->TQB_CODBEM
			If TQB->TQB_DTABER <= dDataSS .And. TQB->TQB_DTABER > dDataUlt .And. TQB->TQB_SOLICI != cCodSS
				dDataUlt := TQB->TQB_DTABER
			EndIf
			dbSelectArea("TQB")
			dbSkip()
		End
		#ELSE
		cAliasQry := GetNextAlias()
		cQuery := " SELECT MAX(TQB.TQB_DTABER) AS dData FROM "+RetSqlName("TQB")+" TQB "
		cQuery += " WHERE TQB.TQB_FILIAL = '"+xFilial("TQB")+"' AND TQB.D_E_L_E_T_ <> '*' "
		cQuery += " AND TQB.TQB_TIPOSS = '"+cTipo+"' AND TQB.TQB_CODBEM = '"+cBemLoc+"' "
		cQuery += " AND TQB.TQB_DTABER <= '"+DTOS(dDataSS)+"' "
		If !Empty(cCodSS)
			cQuery += " AND TQB.TQB_SOLICI <> '"+cCodSS+"' "
		EndIf
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

		dbSelectArea(cAliasQry)
		dbGoTop()
		If !Eof()
			dDataUlt := STOD((cAliasQry)->dData)
		EndIf
		(cAliasQry)->(dbCloseArea())
		#ENDIF
		If !Empty(dDataSS)
			lRet := nDias > (dDataSS-dDataUlt)
		EndIf
	EndIf

	fRestArea(aGetArea)
Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fGravaEnc
Realiza validacao e gravacao da solicitacao

@author Roger Rodrigues
@since 16/04/2012
@version MP10/MP11
@return lRet
/*/
//---------------------------------------------------------------------
Static Function fGravaEnc()
	Local i
	Local cAliasMark := aMark296[__OPC_TQB__][__POS_ALIAS__]
	Local aGetArea := fGetArea(cAliasMark)
	Local cCodSS, cValor, cCampo
	Local lRet := .T.
	Local aAreaTQB := {}
	Local lDistAuto := .F.

	/*
	If lRet
	lRet := MNT280TOK(2, 4)
	EndIf
	*/

	//Atualiza tabela e tela
	If lRet
		cCodSS := MNT280GRV(0,4,.T.,a280Memos)//Grava campos da tela

		dbSelectArea("TQB")
		dbSetOrder(1)
		If dbSeek(xFilial("TQB")+cCodSS)
			aAreaTQB := GetArea()
			If !Empty(aMark296[__OPC_TQB__][__POS_FILTER__]) .And. !Eval( &("{||"+aMark296[__OPC_TQB__][__POS_FILTER__]+"}") )
				dbSelectArea(cAliasMark)
				dbSetOrder(1)
				If dbSeek(xFilial("TQB")+cCodSS)
					RecLock(cAliasMark, .F.)
					dbDelete()
					MsUnlock(cAliasMark)
				EndIf
			Else
				dbSelectArea(cAliasMark)
				dbSetOrder(1)
				If dbSeek(xFilial("TQB")+cCodSS)
					RecLock(cAliasMark,.F.)
					For i:=1 to FCount()
						cCampo := Upper(Trim(FieldName(i)))
						cValor := Nil
						If cCampo == "OK" .or. cCampo == "CRITICID"
							Loop
						ElseIf (nPos := aScan(aMark296[__OPC_TQB__][__POS_VIR__],{|x| Trim(Upper(x[1])) == cCampo}) ) > 0//Verifica se o campo tem Inicializador
							//Executa Combo
							If aMark296[__OPC_TQB__][__POS_VIR__][nPos][2] == "COMBO"
								If !Empty(&("TQB->"+cCampo))
									cValor := &("TQB->"+cCampo)+"="+NGRETSX3BOX(cCampo,&("TQB->"+cCampo))
								EndIf
							ElseIf !Empty(aMark296[__OPC_TQB__][__POS_VIR__][nPos][2])//Executa Inicializador
								cValor := &(aMark296[__OPC_TQB__][__POS_VIR__][nPos][2])
							EndIf
						Else//Grava normalmente
							cValor := &("TQB->"+cCampo)
						EndIf
						If ValType(cValor) != "U"
							dbSelectArea(cAliasMark)
							FieldPut(i, cValor)
						EndIf
					Next i
					MsUnlock(cAliasMark)
				EndIf
			EndIf
			aMark296[__OPC_TQB__][__POS_OBJ__]:oBrowse:Refresh(.T.)
		EndIf
		fDisable(.F.,.T.)
		//Verifica se distribui automaticamente
		If Len(aAreaTQB) > 0
			RestArea(aAreaTQB)
			If TQB->TQB_SOLUCA == "A" .And. FindFunction("MNT298AUT")
				lDistAuto := MNT298AUT(TQB->TQB_SOLICI,TQB->TQB_TIPOSS,TQB->TQB_CODBEM,TQB->TQB_CDSERV,TQB->TQB_DTABER)
			EndIf
		EndIf
	EndIf

	If lDistAuto
		MsgInfo(STR0060 + " " + TQB->TQB_SOLICI + " " + STR0063, STR0043) //"A Solicitação de Serviço" ##
		A291RfshSS(__cCallDistr) // Refresh do Browse de S.S.
	Else
		fRestArea(aGetArea)
	EndIf
Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fChangeFolder
Realiza processamento ao trocar de folder

@param nOpcao Folder que esta sendo selecionado
@param oButton Botao que sera escondido

@author Roger Rodrigues
@since 26/04/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fChangeFolder(nOpcao, oButton, oButton2)

	Local cFiltAtend := "ST1->T1_DISPONI == 'S'"

	If NGCADICBASE("T1_MSBLQL","A","ST1",.F.)
		cFiltAtend += " .And. ST1->T1_MSBLQL != '1'""
	EndIf

	// Define a visibilidade do botão de troca de filial
	If nOpcao == __OPC_SA2__
		oButton:lVisible  := .F.
	Else
		oButton:lVisible  := .T.
	EndIf

	// Coloca o Foco no Browse na troca de folder
	If nOpcao == __OPC_TP4__ .Or. nOpcao == __OPC_ST1__ .Or. nOpcao == __OPC_SA2__
		aMark296[nOpcao][__POS_OBJ__]:oBrowse:SetFocus()
	EndIf

	If nOpcao == __OPC_ST1__
		Processa({|| MNT296TRB(__OPC_ST1__,cFiltAtend)},STR0002,STR0031) //"Aguarde..." ## "Processando Atendentes..."
		aMark296[__OPC_ST1__][__POS_OBJ__]:oBrowse:Refresh(.T.)
	ElseIf nOpcao == __OPC_SA2__
		Processa({|| MNT296TRB(__OPC_SA2__,"")},STR0002,STR0032) //"Aguarde..." ## "Processando Fornecedores..."
		aMark296[__OPC_SA2__][__POS_OBJ__]:oBrowse:Refresh(.T.)
	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fChangeFil
Carrega equipes e atendentes de outra filial

@author Roger Rodrigues
@since 26/04/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fChangeFil(nOpcao,cCodSS)
	Local oDlgFil, oCodFil, oNomFil
	Local cCodFil := Space(If(FindFunction("FwSizeFilial"),FwSizeFilial(),2))
	Local cNomFil := Space(40)
	Local lOk := .F.

	Define MsDialog oDlgFil Title OemToAnsi(STR0024) From 0,0 To 80,345 OF oMainWnd Pixel //"Trocar Filial"

	@ 010,004 Say OemToAnsi(STR0064) Of oDlgFil Pixel //"Filial:"

	@ 008,018 MsGet oCodFil Var cCodFil Picture "@!" F3 "XM0" Size 055,008 Of oDlgFil Pixel;
	Valid (FilChkNew(cEmpAnt,cCodFil) .And. Eval({|| cNomFil := NGSEEKSM0(cEmpAnt+cCodFil,{"M0_NOME"})[1]})) HasButton

	@ 008,080 MsGet oNomFil Var cNomFil Picture "@!" Size 090,008 Of oDlgFil Pixel ReadOnly HasButton

	Define sButton From 025,113 Type 1 Enable Of oDlgFil Action (lOk:= .T.,oDlgFil:End())

	Define sButton From 025,143 Type 2 Enable Of oDlgFil Action oDlgFil:End()

	Activate MsDialog oDlgFil Centered

	If lOk
		//Altera filiais
		aMark296[nOpcao][__POS_FILIAL__]	:= cCodFil
		aMark296[nOpcao][__POS_FILTER__]	:= ""
		//Recarrega browses
		Processa({|| MNT296TRB(nOpcao)},STR0002,If(nOpcao == __OPC_TP4__,STR0030,STR0031)) //"Aguarde..." ## "Processando Equipes..." ## "Processando Atendentes..."
		fChgStatus(nOpcao,cCodSS)
		//Atualiza objetos
		aMark296[nOpcao][__POS_OBJ__]:oBrowse:Refresh(.T.)
	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fMarkBrw
Marca o registro no browse

@param nOpcao Indicacao do browse que esta sendo marcado

@author Roger Rodrigues
@since 03/05/2012
@version MP10/MP11
@return lRet
/*/
//---------------------------------------------------------------------
Static Function fMarkBrw(nOpcao, lTransfAtend, cMarca)
	Local lRet := .T.
	Local aEquipes := {}, aFuncio := {}, aTercei := {}
	Local aGetArea := fGetArea(aMark296[nOpcao][__POS_ALIAS__])
	Local cAliasMark := aMark296[nOpcao][__POS_ALIAS__]
	Default lTransfAtend := .F.

	If nOpcao == __OPC_TP4__ .or. nOpcao == __OPC_ST1__ .or. nOpcao == __OPC_SA2__
		aEquipes := fRetATMrk(__OPC_TP4__, If(nOpcao == __OPC_TP4__, (cAliasMark)->(Recno()), Nil))
		aFuncio  := fRetATMrk(__OPC_ST1__, If(nOpcao == __OPC_ST1__, (cAliasMark)->(Recno()), Nil))
		aTercei  := fRetATMrk(__OPC_SA2__, If(nOpcao == __OPC_SA2__, (cAliasMark)->(Recno()), Nil))
	EndIf

	If nOpcao == __OPC_TP4__
		If Len(aEquipes) > 0
			lRet := .F.
		ElseIf Len(aFuncio) > 0
			lRet := .F.
		ElseIf Len(aTercei) > 0
			lRet := .F.
		EndIf
	ElseIf nOpcao == __OPC_ST1__
		If Len(aEquipes) > 0
			lRet := .F.
		EndIf
	ElseIf nOpcao == __OPC_TUR__

	EndIf

	//Restaura alias
	fRestArea(aGetArea)
	//Se nao pode ser marcado, retorna
	If !lRet
		dbSelectArea(cAliasMark)
		If !Eof() .Or. !Bof()
			If !Empty(cAliasMark)
				RecLock(cAliasMark, .F.)
				(cAliasMark)->OK := Space(Len((cAliasMark)->OK))
				MsUnlock(cAliasMark)
			EndIf
		EndIf
	EndIf

	// Ser pode marcar/desmarcar, então atribui o atendente (Equipe, Atendene, Fornecedor) aos Novos Atendentes da S.S.
	If lTransfAtend .And. lRet
		// Se for uma Atendente Novo (Equipe, Atendente ou Terceiro), então transfere paraa TUR
		If nOpcao <> __OPC_TUR__
			fMarkNewAtend(nOpcao, @cMarca)
		EndIf
		//Restaura alias
		fRestArea(aGetArea)
	EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fDistSS
Distribui as solicitacoes marcadas

@author Roger Rodrigues
@since 27/04/2012
@version MP10/MP11
@return lRet
/*/
//---------------------------------------------------------------------
Static Function fDistSS()
	Local lRet := .T.
	Local i
	Local cAliasMrk := aMark296[__OPC_TQB__][__POS_ALIAS__]
	Local aGetArea := fGetArea(cAliasMrk)
	Local aListaSS := fRetSSMrk()
	Local aListaAT := fRetATMrk()
	Local aEquipes := fRetATMrk(__OPC_TP4__)
	Local aFuncio  := fRetATMrk(__OPC_ST1__)
	Local aTercei  := fRetATMrk(__OPC_SA2__)

	Local cAliasAte := ""
	Local aTmpArea := {}
	Local nAtend := 0

	lRet := fVldSolAte(aListaSS, aListaAT, aEquipes, aFuncio, aTercei)

	If lRet
		//Distribui SS
		If MNT296DIST(aListaSS, aListaAT)
			//Tira SS do Browse
			For i:=1 to Len(aListaSS)
				dbSelectArea(cAliasMrk)
				dbSetOrder(1)
				If dbSeek(xFilial("TQB",aListaSS[i][1])+aListaSS[i][2])
					RecLock(cAliasMrk, .F.)
					dbDelete()
					MsUnlock(cAliasMrk)
				EndIf
			Next i
			aMark296[__OPC_TQB__][__POS_OBJ__]:oBrowse:Refresh(.T.)
			aMark296[__OPC_TQB__][__POS_OBJ__]:oBrowse:GoTop()
			// Desmarca Atendentes
			For nAtend := 1 To 3
				Do Case
					Case nAtend == 1
					cAliasAte := aMark296[__OPC_TP4__][__POS_ALIAS__]
					Case nAtend == 2
					cAliasAte := aMark296[__OPC_ST1__][__POS_ALIAS__]
					Case nAtend == 3
					cAliasAte := aMark296[__OPC_SA2__][__POS_ALIAS__]
				EndCase
				dbSelectArea(cAliasAte)
				aTmpArea := GetArea()
				dbGoTop()
				While !Eof()
					RecLock(cAliasAte, .F.)
					(cAliasAte)->OK := Space( Len((cAliasAte)->OK) )
					MsUnlock(cAliasAte)

					dbSelectArea(cAliasAte)
					dbSkip()
				End
				RestArea(aTmpArea)
			Next nAtend
			// Atulializa Totalizadores
			If ValType(__aTotal[__nTotSS]) == "O"
				__aTotal[__nTotSS]:Refresh()
			EndIf
			MsgInfo(STR0065) //"Solicitações distribuídas com sucesso!"
			dbSelectArea(aGetArea[1])
			dbSetOrder(aGetArea[2])
			Set Filter To &(aGetArea[4])
		Else
			fRestArea(aGetArea)
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT296DIST
Realiza a distribuicao das solicitacoes

@param aSS Lista de SS a serem distribuidas
@param aAtend Lista de atendentes que atenderao a SS

@author Roger Rodrigues
@since 30/04/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Function MNT296DIST(aSS, aAtend, cUsuario, cObs, cTrb40)
	Local i, k
	Local cHora 	:= Time()
	Local lDist 	:= .F.
	Local lWF040 	:= .T.//Variavel para verificar se Workflow esta configurado
	Local cCodOP   	:= ""
	Local aCodFunc 	:= {}
	Local lDistAut 	:= IsInCallStack("MNT298AUT")
	Local cNGSSWRK	:= AllTrim(SuperGetMv("MV_NGSSWRK",.F.,""))
	Local lRet		:= .T.

	Local cFilAtend := ""
	Local cCodAtend := ""

	Default aAtend := {}
	Default cTrb40 := GetNextAlias()

	If !lDistAut //Preenche os funcionários marcados se não for distribuição automática
		aCodFunc := fRetATMrk()
	EndIf

	If Len(aSS) == 0 .or. Len(aAtend) == 0
		Return .F.
	EndIf

	//Condição para garantir a obrigatoriedade dos campos conforme dicionário
	If lRet
		dbSelectArea("TQB")
		dbSetOrder(1)
		If dbSeek(xFilial("TQB",TQB->TQB_FILIAL) + TQB->TQB_SOLICI)
			If X3Obrigat('TQB_PRIORI') .And. Empty(TQB->TQB_PRIORI)
				Help( " ",1, "NÃO CONFORMIDADE",, "O campo " + Alltrim(Posicione("SX3",2,"TQB_PRIORI","X3Titulo()")) + " (TQB_PRIORI)" + " não foi preenchido",3,1 )
				lRet := .F.
			EndIf
		EndIf
	EndIf

	If lRet
		For i:=1 to Len(aSS)
			// Passa a S.S. para Distribuída
			lDist := .F.
			dbSelectArea("TQB")
			dbSetOrder(1)
			If dbSeek(xFilial("TQB",aSS[i][1]) + aSS[i][2])
				If TQB->TQB_SOLUCA <> "D"
					RecLock("TQB",.F.)
					TQB->TQB_SOLUCA := "D"
					//grava o cod. e nome do atendente marcado
					//Se não for distribuição automática
					If !lDistAut
						TQB->TQB_CDEXEC := aCodFunc[1][3]
					EndIf
					MsUnlock("TQB")
					lDist := .T.
				Else
					Help(Nil, Nil,STR0043, Nil, STR0060 + " " + aSS[i][2] + " " + STR0066, 1, 0) //"Atenção" ## "A Solicitação de Serviço" ## "já foi distribuída."
				EndIf
			EndIf
			// Se distribuiu a S.S.
			If lDist
				// Grava Follow-up
				If Len(aAtend) > 0
					cFilAtend := aAtend[1][2]
					cCodAtend := aAtend[1][3]
				EndIf
				MNT280GFU(aSS[i][2],"04",cObs,,,,,cUsuario,cCodAtend,cFilAtend)//Distribuicao
				// Relaciona atendentes
				For k:=1 to Len(aAtend)
					MNT280GAT(aSS[i][2]/*cCodSS*/, aAtend[k][1]/*cTipoAtend*/, aAtend[k][2]/*cFilAtend*/, aAtend[k][3]/*cCodAtend*/, aAtend[k][4]/*cLojAtend*/, ;
					dDataBase/*dDtReceb*/, cHora/*cHrReceb*/, /*dDtFinal*/, /*cHrFinal*/, /*cHrRealiz*/)

					//Dispara Workflow para o atendente
					If lWF040
						If cNGSSWRK == "S"
							lWF040 := MNTW040(aSS[i,2], aAtend[k,3],,cTrb40)
						EndIf
					EndIf
				Next k
			EndIf
		Next i
	EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fCallCarga
Realiza a chamada da tela de Carga de SS

@author Roger Rodrigues
@since 19/09/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fCallCarga(nOpcao)
	Local cOldFil := cFilAnt
	Local cFilPos := cFilAnt
	Local cAliasMark := aMark296[nOpcao][__POS_ALIAS__]

	//----------
	// Executa
	//----------
	If !Empty((cAliasMark)->FILATE)
		cFilPos := (cAliasMark)->FILATE
	EndIf

	// Chama a Carga de S.S.
	If nOpcao == __OPC_TP4__
		A291CARGA(cFilPos, {{Substr((cAliasMark)->CODATE,1,TAMSX3("TP4_CODIGO")[1]), (cAliasMark)->DESATE}})
	ElseIf nOpcao == __OPC_ST1__
		A291CARGA(cFilPos,,Substr((cAliasMark)->CODATE,1,TAMSX3("T1_CODFUNC")[1]))
	ElseIf nOpcao == __OPC_SA2__
		A291CARGA(cFilPos,,,Trim((cAliasMark)->CODATE)+"/"+Trim((cAliasMark)->LOJATE))
	EndIf

	cFilAnt := cOldFil
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fVisualizar
Carrega visualizacao do funcionario

@author Roger Rodrigues
@since 18/09/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fVisualizar(nOpcao)
	Local aNGBEGINPRM := NGBEGINPRM()
	Local cOldFil := cFilAnt
	Local cAliasMark := aMark296[nOpcao][__POS_ALIAS__]
	Private cCadastro := ""

	If !Empty((cAliasMark)->FILATE)
		cFilAnt := (cAliasMark)->FILATE
	EndIf

	If nOpcao == __OPC_TP4__
		cCadastro := STR0067 //"Cadastro de Equipes"
		dbSelectArea("TP4")
		dbSetOrder(1)
		If dbSeek(xFilial("TP4")+Substr((cAliasMark)->CODATE,1,TAMSX3("TP4_CODIGO")[1]))
			NGCAD01("TP4", TP4->(Recno()), 2)
		EndIf
	ElseIf nOpcao == __OPC_ST1__
		cCadastro := STR0068 //"Cadastro de Funcionários"
		dbSelectArea("ST1")
		dbSetOrder(1)
		If dbSeek(xFilial("ST1")+Substr((cAliasMark)->CODATE,1,TAMSX3("T1_CODFUNC")[1]))
			FWExecView( cCadastro , 'MNTA020' , MODEL_OPERATION_VIEW , , { || .T. } )
		EndIf
	Else
		cCadastro := STR0069 //"Cadastro de Fornecedores"
		dbSelectArea("SA2")
		dbSetOrder(1)
		If dbSeek(xFilial("SA2")+Padr((cAliasMark)->CODATE,TAMSX3("A2_COD")[1])+Padr((cAliasMark)->LOJATE,TAMSX3("A2_LOJA")[1]))
			AxInclui("SA2", SA2->(Recno()), 2)
		EndIf
	EndIf

	cFilAnt := cOldFil
	NGRETURNPRM(aNGBEGINPRM)
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} A296TRANSF
Realiza a transferencia de atendimento da SS

@author Roger Rodrigues
@since 10/09/2012
@version MP10/MP11
@return lOk
/*/
//---------------------------------------------------------------------
Function A296TRANSF(cFilPos, cCodSS)
	Local aGetArea := TQB->(GetArea())
	Local aMemory  := NGGetMemory("TQB")
	Local aNGBEGINPRM := NGBEGINPRM(,"MNTA296")
	Local i
	Local cOldFil := cFilAnt

	//Variaveis de tamanho de tela e objetos
	Local aSize := {}, aObjects := {}, aInfo := {}, aPosObj := {}
	Local lOk   := .F.

	//Variaveis do MarkBrowse
	Local cMarca   := GetMark()
	Local lInverte := .F.

	//Objetos principais
	Local oDlgTransf, oPanel
	Local oSplitHor, oPnlTop, oPnlBot
	Local oSplitVert, oPanelLeft, oPanelRight

	//Objetos do Topo
	Local oPanelLCont, oPanelT1, oPanelTBtn, oPanelEnc
	Local oBtnQuest, oBtnVis, oBtnUser, oBtnDet

	//Botoes para esconder paineis
	Local oHideBottom, oHideTop, oHideLeft, oHideRight

	//Objetos do Rodape
	//Parte Esquerda
	Local oPanelBCont, oPanelT2, oPanelLBtn, oBtnTransf
	Local oBtnReset

	//Parte Direita
	Local oPanelRCont, oPanelT3, oPanelRBtn

	// Variáveis para a Gravação
	Local cTblTUR    := ""
	Local cTipoAtend := ""
	Local cHoraTUR   := ""
	Local lIsMark    := .F.
	Local lSeekTUR   := .F.

	// Defaults
	Default cFilPos  := ""

	//Objetos que serao desabilitados
	Private oBtnAltSS, oBtnConf, oBtnCanc

	//Titulo da tela
	Private cCadastro := STR0070 //"Transferência de Atendimento"

	//Variavel de objetos de markbrowse
	Private aMark296 := Array(__LEN_MARK__,__LEN_PROP__)

	//Variaveis da Enchoice
	Private oEncSS
	Private aTela := {}, aGets := {}
	Private aRotina := {{"", "PesqBrw",0, 1},;
	{"", "NGCAD01",0, 2},;
	{"", "NGCAD01",0, 3},;
	{"", "NGCAD01",0, 4},;
	{"", "NGCAD01",0, 5,3}}

	If Empty(cCodSS)
		NGRETURNPRM(aNGBEGINPRM)
		NgRestMemory(aMemory)
		RestArea(aGetArea)
		Return .F.
	EndIf

	If !Empty(cFilPos)
		cFilAnt := cFilPos
	EndIf

	// Semáforo para utilização da Transferência de S.S.
	If !LockByName("MNTALTSS"+cCodSS, .T., .T., .F.)
		MsgInfo(STR0060 + " " + cCodSS + " " + STR0061 + CRLF + CRLF + ; //"A Solicitação de Serviço" ## "já está sendo manipulada por outro processo ou usuário."
		STR0062, STR0043) //"Por favor, tente novamente mais tarde." ## "Atenção"
		NGRETURNPRM(aNGBEGINPRM)
		NgRestMemory(aMemory)
		RestArea(aGetArea)
		Return .F.
	EndIf

	//Definicao de tamanho de tela e objetos
	aSize := MsAdvSize(,.F.,430)
	Aadd(aObjects,{065,065,.T.,.T.})
	Aadd(aObjects,{035,035,.T.,.T.})
	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObjects,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta tela de Transferencia         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Define MsDialog oDlgTransf Title OemToAnsi(cCadastro) From aSize[7],0 To aSize[6],aSize[5] Of oMainWnd Pixel
	oDlgTransf:lMaximized := .T.

	//Define painel principal
	oPanel := TPanel():New(0,0,,oDlgTransf,,,,,,aSize[5],aSize[6],.F.,.F.)
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT

	oSplitHor := TSplitter():New(100,01,oPanel,10,10)
	oSplitHor:SetOrient(1)
	oSplitHor:Align := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta estrutura de cima             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPnlTop := TPanel():New(,,,oSplitHor,,,,,,, aPosObj[1,3], .F., .F. )
	oPnlTop:Align := CONTROL_ALIGN_TOP

	oSplitVert := TSplitter():New(01,01,oPnlTop,10,10)
	oSplitVert:SetOrient(0)
	oSplitVert:Align := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Parte Direita                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPanelLeft := TPanel():New(0,0,,oSplitVert,,,,,,10,10,.F.,.F.)
	oPanelLeft:nHeight := (aSize[5]/2)
	oPanelLeft:Align   := CONTROL_ALIGN_ALLCLIENT

	oPanelLCont := TPanel():New(,,,oPanelLeft,,,,,,, aPosObj[1,3],.F.,.F.)
	oPanelLCont:nWidth := (aSize[5]/2)
	oPanelLCont:Align := CONTROL_ALIGN_ALLCLIENT
	oPanelLCont:CoorsUpdate()

	oPanelT1:=TPanel():New(00,00,,oPanelLCont,,,,aNGColor[1],aNGColor[2],200,200,.F.,.F.)
	oPanelT1:nHeight := 25
	oPanelT1:Align := CONTROL_ALIGN_TOP

	@ 003,013 Say OemToAnsi(STR0013) Of oPanelT1 Color aNGColor[1] Pixel //"Detalhes da Solicitação"

	oPanelTBtn:=TPanel():New(00,00,,oPanelLCont,,,,aNGColor[1],aNGColor[2],12,12,.F.,.F.)
	oPanelTBtn:Align := CONTROL_ALIGN_LEFT

	bGravaEnc := {|| fGravaEnc()}
	oBtnConf  := TBtnBmp():NewBar("ng_ico_confirmar","ng_ico_confirmar",,,,bGravaEnc,,oPanelTBtn,,,STR0015,,,,,"") //"Confirmar"
	oBtnConf:Align  := CONTROL_ALIGN_TOP
	oBtnConf:lVisible := .F.

	oBtnCanc  := TBtnBmp():NewBar("ng_ico_cancelar","ng_ico_cancelar",,,,{|| fDisable(.F.) },,oPanelTBtn,,,STR0016,,,,,"") //"Cancelar"
	oBtnCanc:Align  := CONTROL_ALIGN_TOP
	oBtnCanc:lVisible := .F.

	oBtnQuest  := TBtnBmp():NewBar("ng_ico_questionario","ng_ico_questionario",,,,{|| fQuestiSS(cCodSS)},,oPanelTBtn,,,STR0017,,,,,"") //"Questionário de Sintomas"
	oBtnQuest:Align  := CONTROL_ALIGN_TOP

	oBtnDet := TBtnBmp():NewBar("ng_ico_tarefas","ng_ico_tarefas",,,,{|| fVisualSS(cCodSS)},,oPanelTBtn,,,STR0018,,,,,"") //"Detalhamento Solicitação"
	oBtnDet:Align  := CONTROL_ALIGN_TOP

	oBtnUser  := TBtnBmp():NewBar("ng_ico_info","ng_ico_info",,,,{|| fUserSS(cCodSS)},,oPanelTBtn,,,STR0019,,,,,"") //"Informações do Solicitante"
	oBtnUser:Align  := CONTROL_ALIGN_TOP

	oBtnVis  := TBtnBmp():NewBar("ng_ico_conhecimento","ng_ico_conhecimento",,,,{|| fMsDocSS(cCodSS)},,oPanelTBtn,,,STR0020,,,,,"") //"Conhecimento"
	oBtnVis:Align  := CONTROL_ALIGN_TOP

	oPanelEnc:=TPanel():New(00,00,,oPanelLCont,,,,,,200,200,.F.,.F.)
	oPanelEnc:Align := CONTROL_ALIGN_ALLCLIENT

	//Criacao das Variaveis da Enchoice
	dbSelectArea("TQB")
	dbSetOrder(1)
	dbSeek(xFilial("TQB")+cCodSS)
	MNT280CPO(2,2)
	MNT280REG(2, a280Relac, a280Memos)

	oEncSS := MsMGet():New("TQB",TQB->(Recno()),4,,,,a280Choice,{0,0,500,500},,3,,,,oPanelEnc)
	oEncSS:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	//Atualiza Enchoice
	fAtuEnc(cCodSS)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Botao para esconder parte dir.     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oHideRight := TBtnBmp2():New(01, 01, 05, 05, "fw_arrow_right", , , , {|| fShowHide(1,oPanelRight,oHideRight)}, oPanelLeft, OemToAnsi(STR0011), , .T.) //"Expandir Browse"
	oHideRight:Align := CONTROL_ALIGN_RIGHT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Parte Direita                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPanelRight := TPanel():New(0,0,,oSplitVert,,,,,,10,10,.F.,.F.)
	oPanelRight:nHeight := (aSize[5]/2)
	oPanelRight:Align   := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Botao para esconder parte esq.     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oHideLeft := TBtnBmp2():New(01, 01, 05, 05, "fw_arrow_left", , , , {|| fShowHide(2,oPanelLeft,oHideLeft)}, oPanelRight, OemToAnsi(STR0012), , .T.) //"Esconder Browse"
	oHideLeft:Align := CONTROL_ALIGN_LEFT

	oPanelRCont := TPanel():New(0,0,,oPanelRight,,,,,,10,10,.F.,.F.)
	oPanelRCont:nWidth := (aSize[5]/2)
	oPanelRCont:Align := CONTROL_ALIGN_ALLCLIENT
	oPanelRCont:CoorsUpdate()

	oPanelT3:=TPanel():New(00,00,,oPanelRCont,,,,aNGColor[1],aNGColor[2],200,200,.F.,.F.)
	oPanelT3:nHeight := 25
	oPanelT3:Align := CONTROL_ALIGN_TOP

	@ 003,013 Say OemToAnsi(STR0071) Of oPanelT3 Color aNGColor[1] Pixel //"Atendentes Disponíveis"

	//Cria folders de atendentes
	fCreateFolder(oPanelRCont, aSize, @lInverte, @cMarca, cCodSS, .T./*lTransfAtend*/)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Botao para esconder parte de baixo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oHideBottom := TBtnBmp2():New(01, 01, 05, 05, "fw_arrow_down", , , , {|| fShowHide(3,oPnlBot,oHideBottom)}, oPnlTop, OemToAnsi(STR0021), , .T.) //"Expandir Detalhes da S.S."
	oHideBottom:Align := CONTROL_ALIGN_BOTTOM

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta parte de baixo                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPnlBot := TPanel():New(,,,oSplitHor,,,,,CLR_WHITE,CLR_WHITE, aPosObj[2,3], .F., .F. )
	oPnlBot:Align := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Botao para esconder parte de cima  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oHideTop := TBtnBmp2():New(01, 01, 05, 05, "fw_arrow_top", , , , {|| fShowHide(4,oPnlTop,oHideTop)}, oPnlBot, OemToAnsi(STR0022), , .T.) //"Expandir Browse Atendentes"
	oHideTop:Align := CONTROL_ALIGN_TOP

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Parte De Baixo - Atend. SS   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPanelBCont := TPanel():New(0,0,,oPnlBot,,,,,,10,10,.F.,.F.)
	oPanelBCont:nWidth := (aSize[5]/2)
	oPanelBCont:Align := CONTROL_ALIGN_ALLCLIENT

	oPanelT2:=TPanel():New(00,00,,oPanelBCont,,,,aNGColor[1],aNGColor[2],200,200,.F.,.F.)
	oPanelT2:nHeight := 25
	oPanelT2:Align := CONTROL_ALIGN_TOP

	@ 003,013 Say OemToAnsi(STR0072) Of oPanelT2 Color aNGColor[1] Pixel //"Atendentes da Solicitação"

	oPanelLBtn:=TPanel():New(00,00,,oPanelBCont,,,,aNGColor[1],aNGColor[2],12,12,.F.,.F.)
	oPanelLBtn:Align := CONTROL_ALIGN_LEFT

	// Botão: Resetar (recarregua apenas os Atendentes da S.S., retirando então qualquer novo atendente marcado)
	oBtnReset := TBtnBmp2():New(001, 001, 30, 30, "ng_ico_refresh", , , , {|| fResetNewAtend(cCodSS,@cMarca) }, oPanelLBtn, OemToAnsi(STR0073)) //"Recarregar"
	oBtnReset:Align := CONTROL_ALIGN_TOP
	// Botão: Legenda
	oBtnLeg  := TBtnBmp2():New(001, 001, 30, 30, "ng_ico_lgndos", , , , {|| A296LEGEND(4, __OPC_TUR__, __POS_LEG__) }, oPanelLBtn, OemToAnsi(STR0027)) //"Legenda"
	oBtnLeg:Align	:= CONTROL_ALIGN_TOP

	//Cria estrutura de arquivo temporario e markbrowse
	fCreateTRB(__OPC_TUR__)

	//Carrega Arquivo temporario
	Processa({|| MNT296TRB(__OPC_TUR__,cCodSS,@cMarca)},STR0002,STR0074) //"Aguarde..." ## "Processando Atendentes da Solicitacao..."

	//Atendentes da SS
	aMark296[__OPC_TUR__][__POS_OBJ__] := MsSelect():New(aMark296[__OPC_TUR__][__POS_ALIAS__],"OK",,aMark296[__OPC_TUR__][__POS_FIELDS__],;
	@lInverte,@cMarca,{0,0,1500,1500},,,oPanelBCont,,aMark296[__OPC_TUR__][__POS_LEG__])
	aMark296[__OPC_TUR__][__POS_OBJ__]:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	aMark296[__OPC_TUR__][__POS_OBJ__]:oBrowse:lCanAllMark := .F.
	aMark296[__OPC_TUR__][__POS_OBJ__]:bMark := {|| fMarkBrw(__OPC_TUR__,.T.,@cMarca)}
	aMark296[__OPC_TUR__][__POS_OBJ__]:oBrowse:Refresh(.T.)

	Activate MsDialog oDlgTransf On Init (EnchoiceBar(oDlgTransf,{|| (lOk := .T., If(fVldTransf(), oDlgTransf:End(), lOk := .F.))},{|| (lOk := .F., oDlgTransf:End())})) Centered

	//Se confirmou realiza gravacao
	If lOk
		cTblTUR := aMark296[__OPC_TUR__][__POS_ALIAS__]
		cHoraTUR := Time()

		dbSelectArea(cTblTUR)
		dbSetOrder(1)
		dbGoTop()
		While !Eof()

			// Verifica Marcação
			lIsMark := !Empty( (cTblTUR)->OK )
			// Recebe o Tipo de Atendente
			cTipoAtend := (cTblTUR)->TUR_TIPO
			cTipoAtend := SubStr(cTipoAtend, 1, AT("=",cTipoAtend)-1)

			// Busca o Registro na TUR
			dbSelectArea("TUR")
			dbSetOrder(1)
			lSeekTUR := dbSeek((cTblTUR)->TUR_FILIAL + (cTblTUR)->TUR_SOLICI + cTipoAtend + (cTblTUR)->TUR_FILATE + (cTblTUR)->TUR_CODATE + (cTblTUR)->TUR_LOJATE + DTOS((cTblTUR)->TUR_DTRECE) + (cTblTUR)->TUR_HRRECE)

			// Se for um atendente que já existe
			If (cTblTUR)->STATATE == "0"
				// Caso esteja marcado, então ele ainda é um atendente, e como já está na TUR, não precisa fazer nada
				// Porém, caso tenha sido desmarcado, então vamos encerrar o atendimento dele na S.S.
				If !lIsMark .And. lSeekTUR
					MNT280GAT((cTblTUR)->TUR_SOLICI/*cCodSS*/, cTipoAtend/*cTipoAtend*/, (cTblTUR)->TUR_FILATE/*cFilAtend*/, (cTblTUR)->TUR_CODATE/*cCodAtend*/, (cTblTUR)->TUR_LOJATE/*cLojAtend*/, ;
					(cTblTUR)->TUR_DTRECE/*dDtReceb*/, (cTblTUR)->TUR_HRRECE/*cHrReceb*/, dDataBase/*dDtFinal*/, cHoraTUR/*cHrFinal*/, /*cHrRealiz*/, (cTblTUR)->TUR_FILIAL/*cCodFilTUR*/)
					//TUR->TUR_HRREAL := TQB->TQB_TEMPO // Pegar do REPORTE DE HORAS
				EndIf
			ElseIf (cTblTUR)->STATATE == "1" // Se for um Atendente Novo (não existe ainda na TUR
				// Se estiver Marcado, então grava o novo atendente na TUR
				If lIsMark .And. !lSeekTUR
					MNT280GAT((cTblTUR)->TUR_SOLICI/*cCodSS*/, cTipoAtend/*cTipoAtend*/, (cTblTUR)->TUR_FILATE/*cFilAtend*/, (cTblTUR)->TUR_CODATE/*cCodAtend*/, (cTblTUR)->TUR_LOJATE/*cLojAtend*/, ;
					dDataBase/*dDtReceb*/, cHoraTUR/*cHrReceb*/, /*dDtFinal*/, /*cHrFinal*/, /*cHrRealiz*/, (cTblTUR)->TUR_FILIAL/*cCodFilTUR*/)
				EndIf
			EndIf

			dbSelectArea(cTblTUR)
			dbSkip()
		End
		MNT280GFU(cCodSS/*cCodSS*/, "05"/*cCodFlwUp*/, /*cObservacao*/, dDatabase/*dDtIFlwUp*/, cHoraTUR/*cHrIFlwUp*/, ;
		dDatabase/*dDtFFlwUp*/, cHoraTUR/*cHrFFlwUp*/, /*cUsuFlwUp*/, /*cCodFun*/, /*cCodFilAte*/)
	EndIf

	aMark296[__OPC_TP4__][__POS_ARQ__]:Delete()
	aMark296[__OPC_ST1__][__POS_ARQ__]:Delete()
	aMark296[__OPC_SA2__][__POS_ARQ__]:Delete()
	aMark296[__OPC_TUR__][__POS_ARQ__]:Delete()

	cFilAnt := cOldFil
	NGRETURNPRM(aNGBEGINPRM)
	NgRestMemory(aMemory)
	RestArea(aGetArea)

	// Libera Semáforo
	UnLockByName("MNTALTSS"+cCodSS, .T., .T., .F.)

Return lOk

//---------------------------------------------------------------------
/*/{Protheus.doc} fMarkNewAtend
Adiciona um Novo Atendente do browse de Atendentes Disponíveis para o
browse de Atendentes da S.S., como um atendente temporário.
(também pode remover um atentende da s.s. quando for desmarcado de
atendentes disponíveis).

@author Wagner Sobral de Lacerda
@since 28/09/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fMarkNewAtend(nOpcao, cMarca)

	// Variáveis auxiliares
	Local cAliasMark := aMark296[nOpcao][__POS_ALIAS__]
	Local lIsMark := !Empty( (cAliasMark)->OK )
	Local cAliasAtend := aMark296[__OPC_TUR__][__POS_ALIAS__]
	Local cSeekAtend := "", lSeekAtend := .F.
	Local cTipoAtend := "", cTipoDescr := ""

	// Variáveis de Memória utilizadas para o Inicializador dos campos no Dicionário
	Local cM_FILATE := If(Type("M->TUR_FILATE") <> "U", M->TUR_FILATE, Nil)
	Local cM_TIPO   := If(Type("M->TUR_TIPO")   <> "U", M->TUR_TIPO  , Nil)
	Local cM_CODATE := If(Type("M->TUR_CODATE") <> "U", M->TUR_CODATE, Nil)

	//----------
	// Executa
	//----------
	If nOpcao == __OPC_TP4__
		cTipoAtend := "1" // 1=Equipe
	ElseIf nOpcao == __OPC_ST1__
		cTipoAtend := "2" // 2=Atendente
	ElseIf nOpcao == __OPC_SA2__
		cTipoAtend := "3" // 3=Terceiro
	EndIf
	//-- Define novo conteúdo (temporário)
	M->TUR_FILATE := (cAliasMark)->FILATE
	M->TUR_TIPO   := cTipoAtend
	M->TUR_CODATE := (cAliasMark)->CODATE
	// Define Descrição completa (utilizado para amostragem no browse)
	cTipoDescr := PADR(cTipoAtend + "=" + NGRETSX3BOX("TUR_TIPO",cTipoAtend), Len( (cAliasAtend)->TUR_TIPO ), " ")

	// Busca o registro no Browse (Alias) de Atendentes de S.S., para já preparar para inclusão, ou exclusão do registro
	dbSelectArea(cAliasAtend)
	dbSetOrder(1)
	cSeekAtend := xFilial("TUR") + TQB->TQB_SOLICI + cTipoDescr + (cAliasMark)->FILATE + (cAliasMark)->CODATE + (cAliasMark)->LOJATE
	lSeekAtend := dbSeek(cSeekAtend)

	// Se estiver MARCADO, adiciona no Browse de Atendentes de S.S.
	If lIsMark
		If !lSeekAtend
			dbSelectArea(cAliasAtend)
			RecLock(cAliasAtend,.T.)
			(cAliasAtend)->OK         := cMarca // Sempre inicia Marcado nos Atendentes da S.S.
			(cAliasAtend)->STATATE    := "1"
			(cAliasAtend)->TUR_FILIAL := xFilial("TUR")
			(cAliasAtend)->TUR_SOLICI := TQB->TQB_SOLICI
			(cAliasAtend)->TUR_TIPO   := cTipoDescr
			(cAliasAtend)->TUR_FILATE := (cAliasMark)->FILATE
			(cAliasAtend)->TUR_CODATE := (cAliasMark)->CODATE
			(cAliasAtend)->TUR_LOJATE := (cAliasMark)->LOJATE
			(cAliasAtend)->TUR_DESATE := MNT280REL("TUR_DESATE", .F.)
			MsUnlock(cAliasAtend)
		EndIf
	Else // Se estiver DESMARCADO, remove do Browse de Atendentes de S.S.
		If lSeekAtend
			dbSelectArea(cAliasAtend)
			RecLock(cAliasAtend,.F.)
			dbDelete()
			MsUnlock(cAliasAtend)
		EndIf
	EndIf
	aMark296[__OPC_TUR__][__POS_OBJ__]:oBrowse:Refresh(.T.)
	aMark296[__OPC_TUR__][__POS_OBJ__]:oBrowse:GoTop()

	// Devolve variáveis de memória
	If Type("cM_FILATE") <> "U"
		M->TUR_FILATE := cM_FILATE
	EndIf
	If Type("cM_TIPO") <> "U"
		M->TUR_TIPO := cM_TIPO
	EndIf
	If Type("cM_CODATE") <> "U"
		M->TUR_CODATE := cM_CODATE
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fResetNewAtend
Reseta a Transferência de Atendentes, recarregando os Atendentes da S.S.
para mostrar apenas os originais, e desmarcando todos os novos atendentes
selecionados.

@author Wagner Sobral de Lacerda
@since 02/10/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fResetNewAtend(cCodSS, cMarca)

	// Variáveis auxiliares
	Local aAreaOld := {}

	Local aTabelas := {}
	Local cTabela := ""
	Local nTbl := 0

	Local aDesmarca := {}
	Local nDes := 0

	Local aBrowses := {}
	Local nPosBrw := 0
	Local nBrw := 0

	//----------
	// Reseta
	//----------
	// Armazena as Tabelas para Resetar
	aTabelas := {aMark296[__OPC_TP4__][__POS_ALIAS__], aMark296[__OPC_ST1__][__POS_ALIAS__], aMark296[__OPC_SA2__][__POS_ALIAS__]}
	// Armazena os Browses para Atualizar
	aBrowses := {__OPC_TP4__, __OPC_ST1__, __OPC_SA2__, __OPC_TUR__}

	// Reseta as Tabelas (desmarca todos os registros marcados)
	For nTbl := 1 To Len(aTabelas)
		cTabela := aTabelas[nTbl]
		aDesmarca := {}

		// Armazena os Registros para desmarcar (pois como estamos alterando um campo do chave do índice (campo "OK"), os registros se perdem, então vamos alterar somente depois)
		dbSelectArea(cTabela)
		aAreaOld := GetArea()
		dbSetOrder(4)
		dbSeek(cMarca, .T.)
		While !Eof() .And. (cTabela)->OK == cMarca
			aAdd(aDesmarca, RecNo())

			dbSelectArea(cTabela)
			dbSkip()
		End

		// Deleta os Registros
		For nDes := 1 To Len(aDesmarca)
			dbSelectArea(cTabela)
			dbGoTo(aDesmarca[nDes])
			RecLock(cTabela,.F.)
			(cTabela)->OK := Space( Len((cTabela)->OK) )
			MsUnlock(cTabela)
		Next nDes
		RestArea(aAreaOld)

	Next nTbl

	//Carrega Arquivo temporario
	Processa({|| MNT296TRB(__OPC_TUR__,cCodSS,@cMarca)},STR0002,STR0074) //"Aguarde..." ## "Processando Atendentes da Solicitacao..."

	// Atualiza os Browses
	For nBrw := 1 To Len(aBrowses)
		nPosBrw := aBrowses[nBrw]

		aMark296[nPosBrw][__POS_OBJ__]:oBrowse:Refresh(.T.)
		//aMark296[nPosBrw][__POS_OBJ__]:oBrowse:GoTop()
	Next nBrw

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fVldTransf
Valida a Tela de Transferência de Atendentes de S.S.

@author Wagner Sobral de Lacerda
@since 02/10/2012
@version MP10/MP11
@return lRetorno
/*/
//---------------------------------------------------------------------
Static Function fVldTransf()

	// Salva as áreas atuais
	Local aAreaTUR := {}

	// Variável do Retorno
	Local lRetorno := .T.

	// Variáveis auxiliares
	Local cTblTUR := aMark296[__OPC_TUR__][__POS_ALIAS__]
	Local cTipoAtend := ""

	// Variáveis para a Validação
	Local aSS     := { {TQB->TQB_FILIAL, TQB->TQB_SOLICI} }
	Local aAtends := {}, aEquipes := {}, aFuncs := {}, aTercs := {}
	Local aAuxAtend := {}

	//------------------------------
	// Busca os Atendentes
	//------------------------------
	dbSelectArea(cTblTUR)
	aAreaTUR := GetArea()
	dbSetOrder(1)
	dbGoTop()
	While !Eof()
		// Verifica Marcação
		lIsMark := !Empty( (cTblTUR)->OK )
		// Recebe o Tipo de Atendente
		cTipoAtend := (cTblTUR)->TUR_TIPO
		cTipoAtend := SubStr(cTipoAtend, 1, AT("=",cTipoAtend)-1)

		// Armazena o Atendente
		If lIsMark
			aAuxAtend := {cTipoAtend, (cTblTUR)->TUR_FILATE, (cTblTUR)->TUR_CODATE, (cTblTUR)->TUR_LOJATE}
			aAdd(aAtends, aClone(aAuxAtend))
			If cTipoAtend == "1" // Equipe
				aAdd(aEquipes, aClone(aAuxAtend))
			ElseIf cTipoAtend == "2" // 2=Atendente
				aAdd(aFuncs, aClone(aAuxAtend))
			ElseIf cTipoAtend == "3" // 3=Terceiro
				aAdd(aTercs, aClone(aAuxAtend))
			EndIf
		EndIf

		dbSelectArea(cTblTUR)
		dbSkip()
	End
	RestArea(aAreaTUR)

	//------------------------------
	// Valida os Atendentes
	//------------------------------
	lRetorno := fVldSolAte(aSS, aAtends, aEquipes, aFuncs, aTercs)

Return lRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} fVldSolAte
Valida a Solicitação de Serviço, com relação aos Atendentes.

@author Wagner Sobral de Lacerda
@since 02/10/2012
@version MP10/MP11
@return lRetorno
/*/
//---------------------------------------------------------------------
Static Function fVldSolAte(aListaSS, aListaAT, aEquipes, aFuncio, aTercei)

	// Variável do Retorno
	Local lRetorno := .T.

	//------------------------------
	// Valida S.S. x Atendentes
	//------------------------------
	If Len(aListaSS) == 0
		lRetorno := .F.
		ShowHelpDlg(STR0043,{STR0075},1,{STR0045}) //"Atenção" ## "Deve ser selecionada pelo menos uma Solicitação de Serviço para distribuição." ## "Marque uma Solicitação de Serviço."
	ElseIf Len(aListaAT) == 0
		lRetorno := .F.
		ShowHelpDlg(STR0043,{STR0076},; //"Atenção" ## "Deve ser selecionado pelo menos uma Equipe ou um Atendente ou um Terceiro para distribuição."
		1,{STR0077}) //"Marque uma Equipe ou um Atendente ou um Terceiro."
	ElseIf Len(aEquipes) == 0 .And. Len(aFuncio) == 0 .And. Len(aTercei) > 0
		lRetorno := .F.
		ShowHelpDlg(STR0043,{STR0078},; //"Atenção" ## "Quando a distribuição envolver terceiros deve ser selecionado pelo menos uma Equipe ou Atendente para acompanhamento."
		1,{STR0079}) //"Marque uma Equipe ou um Atendente."
	ElseIf Len(aEquipes) > 1
		lRetorno := .F.
		ShowHelpDlg(STR0043,{STR0081},; //"Atenção" ## "Não é possível efetuar a distribuição para mais de uma Equipe."
		1,{STR0082}) //"Marque somente uma Equipe."
	ElseIf Len(aEquipes) > 0 .And. Len(aFuncio) > 0
		lRetorno := .F.
		ShowHelpDlg(STR0043,{STR0083},; //"Atenção" ## "Não é possível efetuar a distribuição para uma Equipe e ao mesmo tempo para um Atendente."
		1,{STR0084}) //"Marque somente a Equipe ou somente o(s) Atendente(s)."
	EndIf

Return lRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} fAtendFiltro
Executa o Filtro dos Atendentes na Transferência de S.S.

@author Wagner Sobral de Lacerda
@since 02/10/2012
@version MP10/MP11
@return lAtendOK
/*/
//---------------------------------------------------------------------
Static Function fAtendFiltro(cCodSS, cTipoAtend, cFilAtend, cCodAtend, cLojAtend)

	// Salva as áreas atuais
	Local aAreaTUR := TUR->( GetArea() )

	// Variável do Retorno
	Local lAtendOK := .F.

	// Variáveis auxiliares
	Local aAtendimentos := {}

	//-- Define conteúdo dos campos de acorda com a Tabela
	cCodSS     := PADR(cCodSS    , TAMSX3("TUR_SOLICI")[1], " ")
	cTipoAtend := PADR(cTipoAtend, TAMSX3("TUR_TIPO")[1], " ")
	cFilAtend  := PADR(cFilAtend , TAMSX3("TUR_FILATE")[1], " ")
	cCodAtend  := PADR(cCodAtend , TAMSX3("TUR_CODATE")[1], " ")
	cLojAtend  := PADR(cLojAtend , TAMSX3("TUR_LOJATE")[1], " ")

	//----------
	// Executa
	//----------
	dbSelectArea("TUR")
	dbSetOrder(1)
	dbSeek(xFilial("TUR") + cCodSS + cTipoAtend + cFilAtend + cCodAtend + cLojAtend, .T.)
	While !Eof() .And. TUR->TUR_FILIAL == xFilial("TUR") .And. TUR->TUR_SOLICI == cCodSS .And. TUR->TUR_TIPO == cTipoAtend .And. ;
	TUR->TUR_FILATE == cFilAtend .And. TUR->TUR_CODATE == cCodAtend .And. TUR->TUR_LOJATE == cLojAtend

		// Armazena os Atendimentos do atendente
		// 1          ; 2
		// Data Final ; Hora Final
		aAdd(aAtendimentos, {TUR->TUR_DTFINA, TUR->TUR_HRFINA})

		dbSelectArea("TUR")
		dbSkip()
	End
	// Ordena os atendimentos por Data + Hora
	aSort(aAtendimentos, , , {|x,y| DTOS(x[1])+x[2] < DTOS(y[1])+y[2] })

	// Se não houve atendimento ainda, então este Atendente pode ser carregado normalmente
	If Len(aAtendimentos) == 0
		lAtendOK := .T.
	Else
		// Se existir um atendimento em aberto (data/hora final em branco), então o atendente já está atendendo a S.S., e não precisa ser carregado no browse de atendentes disponíveis
		// Caso contrário, ele não faz mais parte dos atendentes da S.S. Logo, ele pode ser selecionado para atender a S.S. novamente, pois ele está disponível para esta S.S.
		If aScan(aAtendimentos, {|x| Empty(x[1]) }) == 0
			lAtendOK := .T. // Se não houver então um atendimento em aberto, deve ser carregado no browse de Atendentes da S.S. Disponíveis
		EndIf
	EndIf

	// Devolve as áreas
	RestArea(aAreaTUR)

Return lAtendOK

//---------------------------------------------------------------------
/*/{Protheus.doc} A296QtdSS
Retorna a Quantidade de S.S. em Aberto para um Atendente (Equipe,
Atendente ou Terceiro), buscando da tabela TUR.

@author Wagner Sobral de Lacerda
@since 03/10/2012
@version MP10/MP11
@return nQtdSS
/*/
//---------------------------------------------------------------------
Function A296QtdSS(cTipoAtend, cFilAtend, cCodAtend, cLojAtend)

	// Salva as áreas atuais
	Local aAreaST1 := fGetArea("ST1")
	Local aAreaTP4 := fGetArea("TP4")
	Local aAreaTUR := fGetArea("TUR")

	// Variável do Retorno
	Local nQtdSS := 0

	// Variáveis auxiliares
	Local aAtendentes := {}
	Local nAtend := 0

	Local cSeekTipo  := ""
	Local cSeekAtend := ""
	Local cSeekLoja  := ""
	Local cFiltro := ""

	// Defaults
	Default cTipoAtend := ""
	Default cFilAtend  := ""
	Default cCodAtend  := ""
	Default cLojAtend  := ""

	//-- Define conteúdo dos campos de acorda com a Tabela
	cTipoAtend := PADR(cTipoAtend, TAMSX3("TUR_TIPO")[1]  , " ") // 1=Equipe; 2=Atendente; 3=Terceiro
	cFilAtend  := PADR(cFilAtend , TAMSX3("TUR_FILATE")[1], " ")
	cCodAtend  := PADR(cCodAtend , TAMSX3("TUR_CODATE")[1], " ")
	cLojAtend  := PADR(cLojAtend , TAMSX3("TUR_LOJATE")[1], " ")

	//-- Define quais serão os atendentes a pesquisar
	aAdd(aAtendentes, {cTipoAtend, cCodAtend, cLojAtend}) // Atendente Principal

	// Quando for uma Equipe, devem ser quantificadas as S.S.'s da Equipe e de seus Membros
	If cTipoAtend == "1"
		cSeekAtend := PADR(cCodAtend, TAMSX3("TP4_CODIGO")[1], " ")

		dbSelectArea("TP4")
		dbSetOrder(1)
		If dbSeek(xFilial("TP4",cFilAtend) + cSeekAtend)
			cSeekTipo := "2"

			dbSelectArea("ST1")
			cFiltro := "ST1->T1_FILIAL == '" + xFilial("TP4",TP4->TP4_FILIAL) + "' .And. ST1->T1_EQUIPE == '" + cSeekAtend + "'"
			Set Filter To &(cFiltro)
			dbGoTop()
			While !Eof()
				If aScan(aAtendentes, {|x| x[1] == cSeekTipo .And. AllTrim(x[2]) == AllTrim(ST1->T1_CODFUNC) }) == 0
					aAdd(aAtendentes, {cSeekTipo, PADR(ST1->T1_CODFUNC, TAMSX3("TUR_CODATE")[1], " "), cLojAtend}) // Atendentes da Equipe
				EndIf

				dbSelectArea("ST1")
				dbSkip()
			End
		EndIf
	ElseIf cTipoAtend == "2"
		// Quando for um Atendente, deve ser verificado se ele é Responsável por um Equipe, e se for, deve considerar as S.S.'s da Equipe também
		cSeekAtend := PADR(cCodAtend, TAMSX3("T1_CODFUNC")[1], " ")

		dbSelectArea("ST1")
		dbSetOrder(1)
		If dbSeek(xFilial("ST1",cFilAtend) + cSeekAtend) .And. !Empty(ST1->T1_EQUIPE)
			dbSelectArea("TP4")
			dbSetOrder(1)
			If dbSeek(xFilial("TP4",ST1->T1_FILIAL) + ST1->T1_EQUIPE) .And. TP4->TP4_CODRES == ST1->T1_CODFUNC
				cSeekTipo := "1"

				If aScan(aAtendentes, {|x| x[1] == cSeekTipo .And. AllTrim(x[2]) == AllTrim(TP4->TP4_CODIGO) }) == 0
					aAdd(aAtendentes, {cSeekTipo, PADR(TP4->TP4_CODIGO, TAMSX3("TUR_CODATE")[1], " "), cLojAtend}) // Equipe
				EndIf
			EndIf
		EndIf
	EndIf

	//----------
	// Executa
	//----------
	For nAtend := 1 To Len(aAtendentes)
		cSeekTipo  := aAtendentes[nAtend][1]
		cSeekAtend := aAtendentes[nAtend][2]
		cSeekLoja  := aAtendentes[nAtend][3]

		// Busca Apenas atendimentos abertos em S.S.
		dbSelectArea("TUR")
		dbSetOrder(3)
		dbSeek(cSeekTipo + cFilAtend + cSeekAtend + cSeekLoja + DTOS(CTOD("")), .T.)
		While !Eof() .And. TUR->TUR_TIPO == cSeekTipo .And. TUR->TUR_FILATE == cFilAtend .And. ;
		TUR->TUR_CODATE == cSeekAtend .And. TUR->TUR_LOJATE == cSeekLoja .And. Empty(TUR->TUR_DTFINA)

			dbSelectArea("TQB")
			dbSetOrder(1)
			If dbSeek(xFilial("TQB",TUR->TUR_FILIAL) + TUR->TUR_SOLICI) .And. !( AllTrim(TQB->TQB_SOLUCA) $ "E/C" )
				nQtdSS++
			EndIf

			dbSelectArea("TUR")
			dbSkip()
		End
	Next nAtend

	// Devolve as áreas
	fRestArea(aAreaST1)
	fRestArea(aAreaTP4)
	fRestArea(aAreaTUR)

Return nQtdSS

//---------------------------------------------------------------------
/*/{Protheus.doc} A296TotTRB
Retorna a Quantidade Total de de S.S. numa tabela temporária para um
objeto TSay.

@author Wagner Sobral de Lacerda
@since 03/10/2012
@version MP10/MP11
@return cSay
/*/
//---------------------------------------------------------------------
Function A296TotTRB(cAlias, lOnlyCount)

	// Salva as áreas atuais
	Local aAreaMark := {}

	// Variável do Retorno
	Local cSay := ""

	// Variáveis auxiliares
	Local nTotSS := 0

	// Defaults
	Default lOnlyCount := .F.

	//----------
	// Executa
	//----------
	dbSelectArea(cAlias)
	aAreaMark := GetArea()
	dbGoTop()
	While !Eof()

		If lOnlyCount
			nTotSS++
		Else
			nTotSS += (cAlias)->QTDSS
		EndIf

		dbSelectArea(cAlias)
		dbSkip()
	End
	RestArea(aAreaMark)

	cSay := STR0085 + Transform(nTotSS,"@E 999,999")

Return cSay

//---------------------------------------------------------------------
/*/{Protheus.doc} fCreateBar
Cria EnchoiceBar
@type function

@author Roger Rodrigues
@since 09/11/2012

@sample fCreateBar( oObj )

@param oDialog, Objeto, MsDialog principal.
@return
/*/
//---------------------------------------------------------------------
Static Function fCreateBar( oDialog )

	oPanelBar := TPanel():New( 0, 0, , oDialog, , , , NGCOLOR( '11' )[1], NGCOLOR( '11' )[2], 0, 012, .F., .F. )
	oPanelBar:Align := CONTROL_ALIGN_TOP

		oPanelBtn := TPanel():New( 0, 0, , oPanelBar, , , , NGCOLOR( '11')[1], NGCOLOR( '11')[2], 100, 012, .F., .F. )
		oPanelBtn:Align := CONTROL_ALIGN_RIGHT

			@ 001,005 Button oBtnDist Prompt STR0086 Message STR0086 Size 38,10 Action ( fDistSS() ) Of oPanelBtn Pixel // Distribuir
			oBtnDist:SetCss( FWGetCSS( oBtnDist, CSS_BUTTON_FOCAL ) )

			If !MNT280REST( 'TUA_DISTSS' )
				oBtnDist:Disable()
			EndIf

			@ 001,050 Button oBtnFechar Prompt STR0087 Message STR0087 Size 38,10 Action ( oDialog:End() ) Of oPanelBtn Pixel // Fechar
			oBtnFechar:SetCss( FWGetCSS( oBtnDist, CSS_BUTTON ) )

Return


//---------------------------------------------------------------------
/*/{Protheus.doc} fCreateBar
Cria Enchoice bar de acordo com a versao

@author Roger Rodrigues
@since 09/11/2012
@version MP10/MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function f296BscSA2(nOpcao)

	Local lRet       := .F.
	Local cAliasMark := aMark296[nOpcao][__POS_ALIAS__]

	lRet := CONPAD1(NIL,NIL,NIL,"SA2",NIL,NIL,.F.)
	If lRet

		RecLock(cAliasMark,.T.)
		(cAliasMark)->CODATE := SA2->A2_COD
		(cAliasMark)->LOJATE := SA2->A2_LOJA
		(cAliasMark)->DESATE := SA2->A2_NREDUZ
		MsUnlock(cAliasMark)

	EndIf

Return .T.
