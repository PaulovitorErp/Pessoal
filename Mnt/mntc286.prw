#INCLUDE	"Protheus.ch"
#INCLUDE	"MNTC286.ch"
#INCLUDE	"FWBrowse.ch"
#INCLUDE	"FWMVCDEF.CH"

#DEFINE _nVERSAO 8 //Versao do fonte

// DEFINES da classe FWCalendar
#DEFINE ID         1 // Id do Celula
#DEFINE OBJETO     2 // Objeto de Tela
#DEFINE DATADIA    3 // Data Completa da Celula
#DEFINE DIA        4 // Dia Ref. Data da Celula
#DEFINE MES        5 // Mes Ref. Data da Celula
#DEFINE ANO        6 // Ano Ref. Data da Celula
#DEFINE NSEMANO    7 // Semana do Ano Ref. Data da Celula
#DEFINE NSEMMES    8 // Semana do Mes Ref. Data da Celula
#DEFINE ATIVO      9 // É celula referente a um dia ativo
#DEFINE FOOTER    10 // É celula referente ao rodape
#DEFINE HEADER    11 // É celula referente ao Header
#DEFINE SEMANA    12 // É celula referente a semana
#DEFINE BGDefault 13 // Cod de BackGround da Celula

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC286
Consulta Gerencial de S.S.

@author Wagner Sobral de Lacerda
@since 20/11/2012

@return lExecute
/*/
//---------------------------------------------------------------------
Function MNTC286()

	//------------------------------
	// Armazena as variáveis
	//------------------------------
	Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)

	Local lExecute := .T. // Variável para identificar se pode ou não executar esta rotina

	Private aSize := MsAdvSize(.F.) // .T. - Tem EnchoiceBar ; .F. - Não tem EnchoiceBar
	Private INCLUI := .F.
	Private ALTERA := .F.

	//Verifica se o update de facilities foi aplicado
	lExecute := FindFunction("MNTUPDFAC") .and. MNTUPDFAC()

	If lExecute
		// Função principal
		fMain()
	EndIf

	//------------------------------
	// Devolve as variáveis armazenadas
	//------------------------------
	NGRETURNPRM(aNGBEGINPRM)

Return lExecute

//---------------------------------------------------------------------
/*/{Protheus.doc} fMain
Função Principal.

@author Wagner Sobral de Lacerda
@since 20/11/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fMain()

	// Variáveis do Dialog
	Local oDlgMain
	Local cDlgMain := OemToAnsi(STR0001) //"Consulta Gerencial de Solicitações de Serviço"

	//Objeto FWLayer
	Private oMainLayer
	//--- Variáveis GERAIS
	Private oFntPDBold := TFont():New(/*cName*/, /*uPar2*/, /*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/,/*lUnderline*/, /*lItalic*/)
	Private oFnt18Bold := TFont():New(/*cName*/, /*uPar2*/, 18/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/,/*lUnderline*/, /*lItalic*/)
	Private oFnt26Bold := TFont():New(/*cName*/, /*uPar2*/, 26/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/,/*lUnderline*/, /*lItalic*/)
	Private lConsulta  := .F. // Indica se já foi Gerada a Consulta
	Private lDetalhes  := .F. // Indica se já foram Montados os Detalhes
	Private oBlackPnl
	// Tipos de Análise de S.S.'s
	Private aTipAnalis := {}
	Private nTipAnalis := 0
	// Formas de Visualização da Consulta
	Private aTipVisual := {}
	Private cTipVisual := ""
	Private oBrwVisual
	Private aDadosConsulta := {}
	// Detalhes
	Private oBrwDetalh, aHeaDetalh
	Private oDetPeriod, oDetTipAna, oDetForVis
	//--- Variáveis de PARÂMETROS
	Private dDeData  := CTOD("")
	Private dAteData := CTOD("")

	Private cFilterTQB := ""

	//--------------------
	// Monta o Dialog
	//--------------------
	DEFINE MSDIALOG oDlgMain TITLE cDlgMain FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL

		// FWLayer
		oMainLayer := FWLayer():New()
		oMainLayer:Init(oDlgMain, .F.)
		fLayout()

		// Painel Preto
		oBlackPnl := TPanel():New(0, 0, , oDlgMain, , , , , SetTransparentColor(CLR_BLACK,70), aSize[5], aSize[6], .F., .F.)
		oBlackPnl:Hide()

	ACTIVATE MSDIALOG oDlgMain CENTERED

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fLayout
Função de Layout da Tela Principal.

@author Wagner Sobral de Lacerda
@since 20/11/2012

@param oMainLayer
	Objeto do FWLayer * Obrigatório

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fLayout()

	// Variáveis da Tela
	Local nPixMenu := 430
	Local nPerMenu := ( nPixMenu * 100 ) / aSize[5]

	// Variáveis dos Objetos dos Paineis das Janelas
	Local oPnlParams
	Local oPnlConsul
	Local oPnlDetalh

	// Linhas
	oMainLayer:AddLine("Linha_Main"/*cId*/, 100/*nPercHeight*/, .F./*lFixed*/)

		// Colunas
		oMainLayer:AddCollumn("Coluna_Menu"/*cId*/, nPerMenu/*nPercWidth*/, .F./*lFixed*/, "Linha_Main"/*cIDLine*/)
		oMainLayer:SetColSplit("Coluna_Menu"/*cIDCollumn*/, CONTROL_ALIGN_RIGHT/*nAlign*/, "Linha_Main"/*cIDLine*/, /*bAction*/)

			// Janela de Parâmetros
			oMainLayer:AddWindow("Coluna_Menu"/*cIDCollumn*/, "Janela_Params"/*cIDWindow*/, OemToAnsi(STR0002)/*cTitle*/, 100/*nPercHeight*/, ; //"Parâmetros"
								.F./*lEnable*/, .F./*lFixed*/, /*bAction*/, "Linha_Main"/*cIDLine*/, /*bGotFocus*/)

		// Colunas
		oMainLayer:AddCollumn("Coluna_Consulta"/*cId*/, (100-nPerMenu)/*nPercWidth*/, .F./*lFixed*/, "Linha_Main"/*cIDLine*/)

			// Janela da Consulta
			oMainLayer:AddWindow("Coluna_Consulta"/*cIDCollumn*/, "Janela_Consulta"/*cIDWindow*/, OemToAnsi(STR0003)/*cTitle*/, 45/*nPercHeight*/, ; //"Consulta"
								.T./*lEnable*/, .F./*lFixed*/, /*bAction*/, "Linha_Main"/*cIDLine*/, /*bGotFocus*/)
			// Janela dos Detalhes da Consulta
			oMainLayer:AddWindow("Coluna_Consulta"/*cIDCollumn*/, "Janela_Detalhes"/*cIDWindow*/, OemToAnsi(STR0004)/*cTitle*/, 55/*nPercHeight*/, ; //"Detalhes"
								.T./*lEnable*/, .F./*lFixed*/, /*bAction*/, "Linha_Main"/*cIDLine*/, /*bGotFocus*/)

								//Inicializa Detalhes da Consulta fechado
								If oMainLayer:winOpen("Coluna_Consulta", "Janela_Detalhes", "Linha_Main")
									oMainLayer:winChgState("Coluna_Consulta", "Janela_Detalhes", "Linha_Main")
								EndIf


	// Objetos
	oPnlParams := oMainLayer:GetWinPanel("Coluna_Menu", "Janela_Params", "Linha_Main")
	oPnlConsul := oMainLayer:GetWinPanel("Coluna_Consulta", "Janela_Consulta", "Linha_Main")
	oPnlDetalh := oMainLayer:GetWinPanel("Coluna_Consulta", "Janela_Detalhes", "Linha_Main")

	// Monta os Paineis
	fPnlParams(oPnlParams) // Parâmetros
	fPnlConsul(oPnlConsul) // Consulta
	fPnlDetalh(oPnlDetalh) // Detalhes da Consulta

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fPnlParams
Monta Painel de Parâmetros.

@author Wagner Sobral de Lacerda
@since 21/11/2012

@param oObjPai
	Objeto Pai * Obrigatório

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fPnlParams(oObjPai)

	// Variáveis de montagem
	Local oScroll, oFilter, oDeData, oAteData
	Local nLin, nLinOld, nCol, nIniCol, nItemLinOld
	Local nWidth, nHeight, nSpace
	Local nItemPorLin, nItemLinAtu

	// Variáveis auxiliares
	Local nX
	Local cTitulo
	Local cImgRPO
	Local bAction

	Local oContainer, oPnlInside

	//------------------------------
	// Scroll
	//------------------------------
	oScroll := TScrollBox():New(oObjPai, 0, 0, 0, 0, .T., .T., .T.)
	oScroll:Align := CONTROL_ALIGN_ALLCLIENT
	oScroll:CoorsUpdate()

		//------------------------------
		// Parâmetros de Pesquisa
		//------------------------------
		// Grupo
		TGroup():New(005, 005, 045, (oScroll:nClientWidth*0.50)-010, STR0005, oScroll, CLR_GREEN, , .T.) //"Parâmetros da Pesquisa"

			//-- De Data
			@ 015,010 SAY OemToAnsi(STR0006+":") FONT oFntPDBold OF oScroll PIXEL //"De Data:"
			oDeData := TGet():New(014, 040, {|u| If(PCount() > 0, dDeData := u, dDeData)}, oScroll, 060, 008, "99/99/9999", {|| fParVldPes(1) }/*bValid*/, , , ,;
						.F., , .T./*lPixel*/, , .F., {|| .T. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F./*lPassword*/, "", "dDeData", , , , .T./*lHasButton*/)
			oDeData:bHelp := {|| ShowHelpCpo(STR0006,; //"De Data:"
				{STR0082},2,; //"Informe até qual data de abertura as solicitações devem ser consideradas"
				{},2)}

			//-- Até Data
			@ 030,010 SAY OemToAnsi(STR0007+":") FONT oFntPDBold OF oScroll PIXEL //"Até Data:"
			oAteData := TGet():New(029, 040, {|u| If(PCount() > 0, dAteData := u, dAteData)}, oScroll, 060, 008, "99/99/9999", {|| fParVldPes(2) }/*bValid*/, , , ,;
						.F., , .T./*lPixel*/, , .F., {|| .T. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F./*lPassword*/, "", "dAteData", , , , .T./*lHasButton*/)
			oAteData:bHelp := {|| ShowHelpCpo(STR0007,; //"Até Data:"
				{STR0083},2,; //"Informe a partir de qual data de abertura as solicitações devem ser consideradas"
				{},2)}

			//TODO Implementação futura, adequar o botão de filtro com os demais botões da prate esquerda da tela
			/*
			oPnlFilter := TPanel():New(010, 150, , oScroll, , , , , , 30, 30, .F., .F.)
			oPnlT := TPanel():New(0, 0, , oPnlFilter, , , , CLR_HGRAY, CLR_HGRAY, 1, 1, .F., .F.)
				oPnlT:Align := CONTROL_ALIGN_TOP
			oPnlL := TPanel():New(0, 0, , oPnlFilter, , , , CLR_HGRAY, CLR_HGRAY, 1, 1, .F., .F.)
				oPnlL:Align := CONTROL_ALIGN_LEFT
			oPnlR := TPanel():New(0, 0, , oPnlFilter, , , , CLR_HGRAY, CLR_HGRAY, 1, 1, .F., .F.)
				oPnlR:Align := CONTROL_ALIGN_RIGHT
			oPnlB := TPanel():New(0, 0, , oPnlFilter, , , , CLR_HGRAY, CLR_HGRAY, 1, 1, .F., .F.)
				oPnlB:Align := CONTROL_ALIGN_BOTTOM
			oFilter := TBtnBmp2():New(040, 150, 120, 44, "filtro", , , , {|| Alert("Filtro")}, oPnlFilter, "Filtro")
				oFilter:Align := CONTROL_ALIGN_ALLCLIENT
			*/

			oFilter := TButton():New(017, 120, "Filtro", oScroll, {|| cFilterTQB := BuildExpr('TQB',,cFilterTQB,.F.)}, 50, 20,,,.F.,.T.,.F.,,.F.,,,.F. )

		//------------------------------
		// Tipos de Análise de S.S.
		//------------------------------
		If Len(aTipAnalis) == 0
			// Define os Tipos de Análise
			// 1      ; 2      ; 3                 ; 4                     ; 5                    ; 6                  ; 7            ; 8
			// Título ; Imagem ; Objeto Borda Topo ; Objeto Borda Esquerda ; Objeto Borda Direita ; Objeto Borda Baixo ; Objeto Botão ; Objeto Título
			aAdd(aTipAnalis, {STR0008, "ng_ico_ss_todas", Nil, Nil, Nil, Nil, Nil, Nil}) //"Todas"
			aAdd(aTipAnalis, {STR0009, "ng_ico_ss_pendente", Nil, Nil, Nil, Nil, Nil, Nil}) //"Pendentes"
			aAdd(aTipAnalis, {STR0010, "ng_ico_ss_ematendimento", Nil, Nil, Nil, Nil, Nil, Nil}) //"Em Atendimento"
			aAdd(aTipAnalis, {STR0011, "ng_ico_ss_encerrada", Nil, Nil, Nil, Nil, Nil, Nil}) //"Encerradas"
			aAdd(aTipAnalis, {STR0012, "ng_ico_ss_cancelada", Nil, Nil, Nil, Nil, Nil, Nil}) //"Canceladas"
			aAdd(aTipAnalis, {STR0013, "ng_ico_ss_ossgeradas", Nil, Nil, Nil, Nil, Nil, Nil}) //"O.S.'s Geradas"
			aAdd(aTipAnalis, {STR0014, "ng_ico_ss_satisfacao", Nil, Nil, Nil, Nil, Nil, Nil}) //"Satisfação"
		EndIf

		// Monta os Tipos de Análise
		nWidth  := 050
		nHeight := 050
		nSpace  := 010
		nItemPorLin := Int( ( (oScroll:nClientWidth*0.50)-010-005) / (nWidth+nSpace) )
			nItemPorLin := If(nItemPorLin  < 1, 1, nItemPorLin)
		nItemLinAtu := 0
		nBrdTam := 1

		nLin := 075
		nIniCol := 005 + ( ( ((oScroll:nClientWidth*0.50)-010) - (nItemPorLin*(nWidth+nSpace)) ) / 2)

		//Calcula area para group box
		nLinOld := nLin
		nItemLinOld := nItemLinAtu
		For nX := 1 To Len(aTipAnalis)
			nItemLinAtu++
			If nItemLinAtu > nItemPorLin
				nItemLinAtu := 1
				nLin += ( nHeight + nSpace )
			EndIf
		Next nX
		nLin += ( nHeight + nSpace )

		// Grupo
		TGroup():New(060, 005, nLin, (oScroll:nClientWidth*0.50)-010, STR0015, oScroll, CLR_GREEN, , .T.) //"Tipo de Análise de Solicitações de Serviço"

		nLin := nLinOld
		nItemLinAtu := nItemLinOld
		For nX := 1 To Len(aTipAnalis)
			nItemLinAtu++
			If nItemLinAtu > nItemPorLin
				nItemLinAtu := 1
				nLin += ( nHeight + nSpace )
			EndIf
			If nItemLinAtu == 1
				nCol := nIniCol
			Else
				nCol += ( nWidth + nSpace )
			EndIf

			// Dados
			cTitulo := aTipAnalis[nX][1]
			cImgRPO := aTipAnalis[nX][2]
			bAction := "{|| fParSelTip("+cValToChar(nX)+") }"

			// Container
			oContainer := TPanel():New(nLin, nCol, , oScroll, , , , , , nWidth, nHeight, .F., .F.)

				// Bordas
				aTipAnalis[nX][3] := TPanel():New(0, 0, , oContainer, , , , CLR_HGRAY, CLR_HGRAY, nBrdTam, nBrdTam, .F., .F.)
				aTipAnalis[nX][3]:Align := CONTROL_ALIGN_TOP
				aTipAnalis[nX][4] := TPanel():New(0, 0, , oContainer, , , , CLR_HGRAY, CLR_HGRAY, nBrdTam, nBrdTam, .F., .F.)
				aTipAnalis[nX][4]:Align := CONTROL_ALIGN_LEFT
				aTipAnalis[nX][5] := TPanel():New(0, 0, , oContainer, , , , CLR_HGRAY, CLR_HGRAY, nBrdTam, nBrdTam, .F., .F.)
				aTipAnalis[nX][5]:Align := CONTROL_ALIGN_RIGHT
				aTipAnalis[nX][6] := TPanel():New(0, 0, , oContainer, , , , CLR_HGRAY, CLR_HGRAY, nBrdTam, nBrdTam, .F., .F.)
				aTipAnalis[nX][6]:Align := CONTROL_ALIGN_BOTTOM

				// Painel de Dentro do Container
				oPnlInside := TPanel():New(0, 0, , oContainer, , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
				oPnlInside:Align := CONTROL_ALIGN_ALLCLIENT

					// Botão
					aTipAnalis[nX][7] := TBtnBmp2():New(001, 001, 30, 30, cImgRPO, , , , &(bAction), oPnlInside, cTitulo)
					aTipAnalis[nX][7]:Align := CONTROL_ALIGN_ALLCLIENT

					// Título
					aTipAnalis[nX][8] := TPanel():New(0, 0, cTitulo, oPnlInside, , .T., , CLR_GRAY, CLR_WHITE, 100, 008, .F., .F.)
					aTipAnalis[nX][8]:Align := CONTROL_ALIGN_BOTTOM
		Next nX
		nLin += ( nHeight + nSpace )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fParVldPes
Valida os Parâmetros de Pesquisa.

@author Wagner Sobral de Lacerda
@since 21/11/2012

@param nValid
	Indica a Validação que deve ser feita * Obrigatório
	   0 - Tudo
	   1 - De Data
	   2 - Até Data

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fParVldPes(nValid)

	// Variáveis auxiliares
	Local lValidAll := .F.

	// Defaults
	Default nValid := 0
	lValidAll := ( nValid == 0 )

	//----------
	// Valida
	//----------
	// Data Inicial
	If lValidAll .Or. nValid == 1
		If !Empty(dDeData) .And. !Empty(dAteData) .And. dDeData > dAteData
			Help(Nil, Nil, STR0016, Nil, STR0017, 1, 0) //"Atenção" ## "A Data Inicial deve ser igual ou inferior a Data Final."
			Return .F.
		EndIf
	EndIf
	// Data Final
	If lValidAll .Or. nValid == 2
		If !Empty(dDeData) .And. !Empty(dAteData) .And. dAteData < dDeData
			Help(Nil, Nil, STR0016, Nil, STR0018, 1, 0) //"Atenção" ## "A Data Final deve ser igual ou superior a Data Inicial."
			Return .F.
		EndIf
	EndIf
	// Tipo de Análise
	If lValidAll
		If Empty(nTipAnalis)
			Help(Nil, Nil, STR0016, Nil, STR0019, 1, 0) //"Atenção" ## "Por favor, selecione um Tipo de Análise."
			Return .F.
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fParSelTip
Seleciona um Tipo de Análise.

@author Wagner Sobral de Lacerda
@since 21/11/2012

@param nPosicao
	Posição do Array 'aTipAnalis' do Botão selecionado * Obrigatório

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fParSelTip(nPosicao)

	// Variáveis auxiliares
	Local nX
	Local nClrFore, nClrBack

	// Seta Seleção dos Botões
	For nX := 1 To Len(aTipAnalis)
		If nX == nPosicao
			nClrFore := RGB(70,130,180)
			nClrBack := nClrFore
		Else
			nClrFore := CLR_GRAY
			nClrBack := CLR_HGRAY
		EndIf
		aTipAnalis[nX][3]:SetColor(nClrBack, nClrBack)
		aTipAnalis[nX][4]:SetColor(nClrBack, nClrBack)
		aTipAnalis[nX][5]:SetColor(nClrBack, nClrBack)
		aTipAnalis[nX][6]:SetColor(nClrBack, nClrBack)
		aTipAnalis[nX][8]:SetColor(nClrFore, CLR_WHITE)
	Next nX

	// Seta o Botão Selecionado
	nTipAnalis := nPosicao

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fPnlConsul
Monta Painel de Parâmetros.

@author Wagner Sobral de Lacerda
@since 21/11/2012

@param oObjPai
	Objeto Pai * Obrigatório

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fPnlConsul(oObjPai)

	// Variáveis de montagem
	Local oPnlFormas

	Local oPnlBrowse
	Local aHeader, aCols, aMark

	Local oPnlBtns
	Local oBtnGerar, oBtnDetal, oBtnGrafi

	//------------------------------
	// Formas de Visualização
	//------------------------------
	oPnlFormas := TPanel():New(0, 0, , oObjPai, , , , , , 100, 021, .F., .F.)
	oPnlFormas:Align := CONTROL_ALIGN_TOP

		// Botão: Gerar Consulta
		oBtnGerar := TButton():New(007/*nRow*/, 005/*nCol*/, STR0020/*cCaption*/, oPnlFormas/*oWnd*/, {|| If(fParVldPes(), MsgRun(STR0021, STR0022, {|| fGeraConsulta() }), ) }/*bAction*/, ; //"Gerar Consulta" ## "Gerando a Consulta..." ## "Por favor, aguarde..."
									050/*nWidth*/, 013/*nHeight*/, /*uParam8*/, /*oFont*/, /*uParam10*/, ;
									.T./*lPixel*/, /*uParam12*/, /*uParam13*/, /*uParam14*/, /*bWhen*/, ;
									/*uParam16*/, /*uParam17*/)

		//-- Formas de Visualização
		If Len(aTipVisual) == 0
			aAdd(aTipVisual, STR0023) //"1=Solicitação"
			aAdd(aTipVisual, STR0024) //"2=Prioridade"
			aAdd(aTipVisual, STR0025) //"3=Serviço"
			aAdd(aTipVisual, STR0026) //"4=Executante"
			aAdd(aTipVisual, STR0027) //"5=Criticidade"
			aAdd(aTipVisual, STR0028) //"6=Satisfação"
			cTipVisual := aTipVisual[1]
		EndIf
		// Grupo
		TGroup():New(000, 065, 021, 155, STR0029, oPnlFormas, CLR_GREEN, , .T.) //"Forma de Visualização"
		// ComboBox
		TComboBox():New(008/*nRow*/, 070/*nCol*/, {|u| If(PCount() > 0, cTipVisual := u, cTipVisual) }/*bSetGet*/, aTipVisual/*aItens*/, 080/*nWidth*/, 010/*nHeight*/, oPnlFormas/*oWnd*/, ;
						/*uParam8*/, {|| fFormVisualiz() }/*bChange*/, /*bValid*/, /*nClrBack*/, /*nClrText*/, .T./*lPixel*/, /*oFont*/, ;
						/*uParam15*/, /*uParam16*/, /*bWhen*/, /*uParam18*/, /*uParam19*/, /*uParam20*/, /*uParam21*/, ;
						/*cReadVar*/, /*cLabelText*/, /*nLabelPos*/, /*oLabelFont*/, /*nLabelColor*/)

	//------------------------------
	// Painel do Browse
	//------------------------------
	oPnlBrowse := TPanel():New(0, 0, , oObjPai, , , , , , 100, 100, .F., .F.)
	oPnlBrowse:Align := CONTROL_ALIGN_ALLCLIENT

		// Monta o Browse
		aHeader := {}
		aAdd(aHeader, {STR0081, "C", TAMSX3("TQB_FILIAL")[1], ""}) //"Filial"
		aAdd(aHeader, {STR0030, "C", 05, ""}) //"ID"
		aAdd(aHeader, {STR0031, "C", 20, ""}) //"Descrição"
		aAdd(aHeader, {STR0032, "N", 06, "@E 999,999"}) //"Quantidade de S.S.'s"
		aAdd(aHeader, {STR0033, "C", 05, ""}) //"Tempo de Execução"
		aAdd(aHeader, {STR0034, "C", 05, ""}) //"Tempo para Atendimento"

		aMark := {{|| fBrwMrkImg() }, {|| fBrwMrkClk() }, {|| fBrwMrkClk(.T.) }}

		oBrwVisual := fMontaBrowse(oPnlBrowse, Nil, aHeader, aMark)

		aCols := { Array(Len(oBrwVisual:aColumns)+1) }
		oBrwVisual:SetArray(aCols)
		oBrwVisual:SetDoubleClick(&(GetCBSource(aMark[2])))
		oBrwVisual:Disable() // Inicia Desabilitado

	//------------------------------
	// Painel de Botões
	//------------------------------
	oPnlBtns := TPanel():New(0, 0, , oObjPai, , , , , RGB(250,250,250), 100, 015, .F., .F.)
	oPnlBtns:Align := CONTROL_ALIGN_BOTTOM

		// Botão: Detalhes
		oBtnDetal := TButton():New(001/*nRow*/, 005/*nCol*/, STR0004/*cCaption*/, oPnlBtns/*oWnd*/, {|| MsgRun(STR0035, STR0022, {|| fGeraDetalhes() }) }/*bAction*/, ; //"Detalhes" ## "Carregando os Detalhes..." ## "Por favor, aguarde..."
									035/*nWidth*/, 013/*nHeight*/, /*uParam8*/, /*oFont*/, /*uParam10*/, ;
									.T./*lPixel*/, /*uParam12*/, /*uParam13*/, /*uParam14*/, {|| lConsulta }/*bWhen*/, ;
									/*uParam16*/, /*uParam17*/)

		// Botão: Gráfico
		oBtnGrafi := TButton():New(001/*nRow*/, 050/*nCol*/, STR0036/*cCaption*/, oPnlBtns/*oWnd*/, {|| fGrafico() }/*bAction*/, ; //"Gráfico"
									035/*nWidth*/, 013/*nHeight*/, /*uParam8*/, /*oFont*/, /*uParam10*/, ;
									.T./*lPixel*/, /*uParam12*/, /*uParam13*/, /*uParam14*/, {|| lConsulta }/*bWhen*/, ;
									/*uParam16*/, /*uParam17*/)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fPnlConsul
Monta Painel de Parâmetros.

@author Wagner Sobral de Lacerda
@since 21/11/2012

@param oObjPai
	Objeto Pai * Obrigatório

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fPnlDetalh(oObjPai)

	// Variáveis de montagem
	Local oPnlCabec
	Local oPnlConteud
	Local oPnlBrowse
	Local oPnlBtns

	Local oTmpBtn

	Local aNGColor := aClone(NGColor())

	//------------------------------
	// Período Consultado
	//------------------------------
	oDetPeriod := TPanel():New(0, 0, "", oObjPai, oFnt18Bold, .T., , RGB(70,130,180), CLR_WHITE, 100, 012, .F., .F.)
	oDetPeriod:Align := CONTROL_ALIGN_TOP

	//------------------------------
	// Painel do Cabeçalho
	//------------------------------
	oPnlCabec := TPanel():New(0, 0, , oObjPai, , , , , , 100, 015, .F., .F.)
	oPnlCabec:Align := CONTROL_ALIGN_TOP

		@ 005,005 SAY OemToAnsi(STR0037) FONT oFntPDBold COLOR CLR_BLACK,CLR_WHITE OF oPnlCabec PIXEL //"Tipo de Análise:"
		oDetTipAna := TSay():New(005, 052, {|| "" }, oPnlCabec, , oFntPDBold, , ;
									, ,.T., RGB(70,130,180), CLR_WHITE, 150, 015)
		@ 005,100 SAY OemToAnsi(STR0038) FONT oFntPDBold COLOR CLR_BLACK,CLR_WHITE OF oPnlCabec PIXEL //"Forma de Visualização:"
		oDetForVis := TSay():New(005, 165, {|| "" }, oPnlCabec, , oFntPDBold, , ;
									, ,.T., RGB(70,130,180), CLR_WHITE, 150, 015)

	//------------------------------
	// Painel do Conteúdo
	//------------------------------
	// Painel do Browse
	oPnlConteud := TPanel():New(0, 0, , oObjPai, , , , , , 100, 100, .F., .F.)
	oPnlConteud:Align := CONTROL_ALIGN_ALLCLIENT

		// Painel dos Botões Laterias
		oPnlBtns := TPanel():New(0, 0, , oPnlConteud, , , , aNGColor[1], aNGColor[2], 012, 012, .F., .F.)
		oPnlBtns:Align := CONTROL_ALIGN_LEFT

			// Espaço
			oTmpBtn := TPanel():New(0, 0, , oPnlBtns, , , , aNGColor[1], aNGColor[2], 012, 012, .F., .F.)
			oTmpBtn:Align := CONTROL_ALIGN_TOP

			// Botão: Questionário da S.S.
			oTmpBtn := TBtnBmp2():New(001, 001, 30, 30, "ng_ico_questionario", , , , {|| fViewDetail(1) }, oPnlBtns, STR0039, {|| lDetalhes }) //"Questionário de Sintomas"
			oTmpBtn:Align := CONTROL_ALIGN_TOP

			// Botão: Detalhamento da S.S.
			oTmpBtn := TBtnBmp2():New(001, 001, 30, 30, "ng_ico_tarefas", , , , {|| fViewDetail(2) }, oPnlBtns, STR0041, {|| lDetalhes }) //"Detalhamento da Solicitação"
			oTmpBtn:Align := CONTROL_ALIGN_TOP

			// Botão: Informações do Solicitante
			oTmpBtn := TBtnBmp2():New(001, 001, 30, 30, "ng_ico_info", , , , {|| fViewDetail(3) }, oPnlBtns, STR0042, {|| lDetalhes }) //"Informações do Solicitante"
			oTmpBtn:Align := CONTROL_ALIGN_TOP

			// Botão: Orderns de Serviço
			oTmpBtn := TBtnBmp2():New(001, 001, 30, 30, "ng_ico_detalhesos", , , , {|| fViewDetail(4) }, oPnlBtns, STR0043, {|| lDetalhes }) //"Ordens de Serviço"
			oTmpBtn:Align := CONTROL_ALIGN_TOP

			// Botão: Conhecimento
			oTmpBtn := TBtnBmp2():New(001, 001, 30, 30, "ng_ico_conhecimento", , , , {|| fViewDetail(5) }, oPnlBtns, STR0044, {|| lDetalhes }) //"Conhecimento"
			oTmpBtn:Align := CONTROL_ALIGN_TOP

			// Botão: Pesquisa de Satisfação
			oTmpBtn := TBtnBmp2():New(001, 001, 30, 30, "ng_ico_pesqsat", , , , {|| fViewDetail(6) }, oPnlBtns, STR0044, {|| lDetalhes }) //"Conhecimento"
			oTmpBtn:Align := CONTROL_ALIGN_TOP

			// Botão: Calendário
			oTmpBtn := TBtnBmp2():New(001, 001, 30, 30, "fwstd_calend", , , , {|| fViewDetail(7) }, oPnlBtns, STR0045, {|| lDetalhes }) //"Calendário da Solicitação"
			oTmpBtn:Align := CONTROL_ALIGN_TOP

			// Botão: Indicadores
			oTmpBtn := TBtnBmp2():New(001, 001, 30, 30, "ng_ico_grafpizza", , , , {|| fViewDetail(8) }, oPnlBtns, STR0046, {|| lDetalhes }) //"Indicadores"
			oTmpBtn:Align := CONTROL_ALIGN_TOP

		// Painel do Browse
		oPnlBrowse := TPanel():New(0, 0, , oPnlConteud, , , , , , 100, 100, .F., .F.)
		oPnlBrowse:Align := CONTROL_ALIGN_ALLCLIENT

			// Monta o Browse
			oBrwDetalh := fMontaBrowse(oPnlBrowse, "TQB", @aHeaDetalh, Nil)
			oBrwDetalh:SetDoubleClick({|| fViewDetail(2) })
			aCols := { Array(Len(oBrwDetalh:aColumns)) }
			oBrwDetalh:SetArray(aCols)
			oBrwDetalh:Disable() // Inicia Desabilitado

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fMontaBrowse
Monta um FWBrowse.

@author Wagner Sobral de Lacerda
@since 21/11/2012

@param oObjPai
	Objeto do FWLayer * Obrigatório
@param cAlias
	ID da Tabela * Opcional
@param aHeader
	Cabeçalho do Browse * Opcional
@param aMark
	Cabeçalho de Marks * Opcional

@return oFWBrw
/*/
//---------------------------------------------------------------------
Static Function fMontaBrowse(oObjPai, cAlias, aHeader, aMark)

	// Salva as áreas atuais
	Local aAreaOld := GetArea()
	Local aAreaSX3 := SX3->( GetArea() )

	// Variáveis auxiliares
	Local oFWBrw, oGrid
	Local nHeader

	Local aColunas, oColuna
	Local bSetData
	Local bHeadClick

	Local oFilter
	Local aFields := {}

	Local aNGHeader := {}
	Local nTamTot   := 0
	Local nInd      := 0
	Local cCampoSX3 := ""
	Local cUsadSX3  := ""
	Local cBrowSX3  := ""
	Local cTipoSX3  := ""
	Local cTitSX3   := ""
	Local nTamanSX3 := 0
	Local nDecimSX3 := 0
	Local cArqSX3   := ""

	// Defaults
	Default cAlias  := ""
	Default aHeader := {}
	Default aMark   := {}

	//-- Monta Cabeçalho
	If !Empty(cAlias)
		aHeader := {}
		aNgHeader := NGHeader( cAlias ) // Buscar os campos das tabela.
		nTamTot := Len(aNgHeader)
		For nInd := 1 To nTamTot
			cCampoSX3 := aNgHeader[nInd, 2]
			cUsadSX3  := aNgHeader[nInd, 7]
			cBrowSX3  := Posicione("SX3", 2, aNgHeader[nInd, 2], "X3_BROWSE")
			cTipoSX3  := aNgHeader[nInd, 8]
			cTitSX3   := Posicione("SX3", 2, aNgHeader[nInd, 2], "X3Titulo()")
			nTamanSX3 := aNgHeader[nInd, 4]
			nDecimSX3 := aNgHeader[nInd, 5]
			cArqSX3   := Posicione("SX3", 2, aNgHeader[nInd, 2], "X3_ARQUIVO")

			If "_FILIAL" $ cCampoSX3 .Or. ( X3Uso(cUsadSX3) .And. cBrowSX3 == "S" .And. cTipoSX3 <> "M" )
				aAdd(aHeader, { cTitSX3 , cTipoSX3, nTamanSX3 + nDecimSX3, PesqPict(cArqSX3, cCampoSX3, ), cCampoSX3})
			EndIf
		Next nInd
	EndIf

	//--------------------
	// Monta Browse
	//--------------------
	// Instancia a Classe
	oFWBrw := FWBrowse():New(oObjPai)
	// Definições Básicas do Objeto
	oFWBrw:SetDataArray()
	oFWBrw:SetInsert(.F.)	// Habilita a Inserção de registros
	oFWBrw:SetLocate()		// Habilita a Localização de registros
	oFWBrw:DisableConfig()	// Desabilita a Configuração do browse
	oFWBrw:DisableFilter()	// Desabilita o Filtro
	oFWBrw:DisableSeek()	// Desabilita a Pesquisa
	// Define as Colunas
	aColunas := {}
	If Len(aMark) > 0 // Apenas UMA coluna de Marcação
		oFWBrw:AddMarkColumns(&(GetCBSource(aMark[1]))/*bMark*/, &(GetCBSource(aMark[2]))/*bLDblClick*/, &(GetCBSource(aMark[3]))/*bHeaderClick*/)
	EndIf
	For nHeader := 1 To Len(aHeader)
		// Instancia a Classe
		oColuna := FWBrwColumn():New()
		// Definições Básicas do Objeto
		oColuna:SetAlign(If(aHeader[nHeader][2] == "N", CONTROL_ALIGN_RIGHT, CONTROL_ALIGN_LEFT))
		oColuna:SetEdit(.F.)
		// Definições do Dado apresentado
		oColuna:SetTitle(aHeader[nHeader][1])
		oColuna:SetType(aHeader[nHeader][2])
		oColuna:SetSize(aHeader[nHeader][3])
		If !Empty(aHeader[nHeader][4])
			oColuna:SetPicture(aHeader[nHeader][4])
		EndIf

		bSetData := "{|| oFWBrw:Data():GetArray()[oFWBrw:AT()][" + cValToChar(nHeader) + "] }"
		oColuna:SetData(&(bSetData))

		oColuna:bHeaderClick := {|| Nil }

		aAdd(aColunas, oColuna)
	Next nHeader
	oFWBrw:SetColumns(aColunas)

	// Ativa a Classe do FWBrowse
	oFWBrw:Activate()
	oFWBrw:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	// Devolve as áreas
	RestArea(aAreaSX3)
	RestArea(aAreaOld)

Return oFWBrw

//---------------------------------------------------------------------
/*/{Protheus.doc} fBrwMrkImg
Executa a Marcação do FWBrowse.

@author Wagner Sobral de Lacerda
@since 22/11/2012

@return cImgRPO
/*/
//---------------------------------------------------------------------
Static Function fBrwMrkImg()

	// Variável do Retorno
	Local cImgRPO := ""

	// Variáveis auxiliares
	Local aLinha := aClone( oBrwVisual:Data():GetArray()[oBrwVisual:AT()] )
	Local lHasMark := If(ValType(aTail(aLinha)) == "L", aTail(aLinha), .F.)

	// Define imagem
	If lHasMark
		cImgRPO := "LBOK"
	Else
		cImgRPO := "LBNO"
	EndIf

Return cImgRPO

//---------------------------------------------------------------------
/*/{Protheus.doc} fBrwMrkClk
Executa o Clique de Marcação do FWBrowse.

@author Wagner Sobral de Lacerda
@since 22/11/2012

@param lHeaderClick
	Indica se foi um Clique no Cabeçalho (.T.) * Obrigatório
	Default: .F.

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fBrwMrkClk(lHeaderClick)

	// Variáveis auxiliares
	Local aCols := oBrwVisual:Data():GetArray()
	Local nFrom := 0, nTo := 0
	Local nX := 0
	Local lPutMark

	// Defaults
	Default lHeaderClick := .F.

	// Executa o Clique
	If lHeaderClick
		oBrwVisual:GoTop(.T.)

		nFrom := 1
		nTo   := Len(aCols)

		lPutMark := ( aScan(aCols, {|x| !aTail(x) }) > 0 )
	Else
		nFrom := oBrwVisual:AT()
		nTo   := nFrom
	EndIf
	For nX := nFrom To nTo
		If !lHeaderClick
			lPutMark := !aTail(aCols[nX])
		EndIf
		aTail(aCols[nX]) := lPutMark
	Next nX
	If lHeaderClick
		oBrwVisual:GoTop(.T.)
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fGeraConsulta
Processa dados da Consulta.

@author Wagner Sobral de Lacerda
@since 21/11/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fGeraConsulta()

	// Salva as áreas atuais
	Local aAreaOld := GetArea()
	Local aAreaTQB := TQB->( GetArea() )
	Local aAreaTQ3 := TQ3->( GetArea() )
	Local aAreaTUR := TUR->( GetArea() )
	Local aAreaST1 := ST1->( GetArea() )
	Local aAreaTUW := TUW->( GetArea() )

	// Arrays auxiliares para as Formas de Visualização
	Local aSolicit := {}, nSolicit := 0
	Local aPriorid := {}, nPriorid := 0
	Local aServico := {}, nServico := 0
	Local aExecuta := {}, nExecuta := 0
	Local aCritici := {}, nCritici := 0
	Local aSatisfa := {}, nSatisfa := 0
	Local aAuxSS := {}
	Local aCriAux := ()
	Local cCritic

	Local aAtendimentos := {}, aHeadAtend := {}, aColsAtend := {}
	Local nTURTIPO := 0, nTURFILATE := 0, nTURCODATE := 0
	Local nX := 0, nTip := 0, nVis := 0, nSS := 0
	Local cTempoExec := "", nTempoExec := 0, cTempoAten := "", nTempoAten := 0
	Local cAuxID := "", cAuxDesc := ""
	Local i

	// Cursos em Espera
	CursorWait()

	//------------------------------
	// Processa a Consulta
	//------------------------------
	aDadosConsulta := Array(Len(aTipVisual))
	/* Descrição do Array:
		{[Filial], [Identificador], [Descrição], [Novo Array com as S.S.'s], [Tempo Médio de Execução], [Tempo Médio para Atendimento]}
	*/
	dbSelectArea("TQB")
	dbSetOrder(1)
	dbGoTop()
	While !Eof()
		// Limpa posições
		Store 0 To nSolicit, nPriorid, nServico, nExecuta, nCritici

		// Filtro
		If !fFiltConsulta()
			dbSelectArea("TQB")
			dbSkip()
			Loop
		EndIf

		//-- Solicitações
		nSolicit := aScan(aSolicit, {|x| x[1] == TQB->TQB_FILIAL .And. x[2] == "ALL" })
		If nSolicit == 0
			aAdd(aSolicit, {TQB->TQB_FILIAL,"ALL", STR0080+" "+TQB->TQB_FILIAL, {}, 0, 0}) //"Todas"
			nSolicit := Len(aSolicit)
		EndIf

		//-- Prioridade
		nPriorid := aScan(aPriorid, {|x| x[1] == TQB->TQB_FILIAL .And. x[2] == TQB->TQB_PRIORI })
		If nPriorid == 0
			aAdd(aPriorid, {TQB->TQB_FILIAL,TQB->TQB_PRIORI, AllTrim(NGRetSX3Box("TQB_PRIORI", TQB->TQB_PRIORI)), {}, 0, 0})
			nPriorid := Len(aPriorid)
		EndIf

		//-- Serviço
		nServico := aScan(aServico, {|x| x[1] == TQB->TQB_FILIAL .And. x[2] == TQB->TQB_CDSERV })
		If nServico == 0
			aAdd(aServico, {TQB->TQB_FILIAL,TQB->TQB_CDSERV, Posicione("TQ3", 1, xFilial("TQ3",TQB->TQB_FILIAL) + TQB->TQB_CDSERV, "TQ3_NMSERV"), {}, 0, 0})
			nServico := Len(aServico)
		EndIf

		//-- Executante (2=Atendente)
		aAtendimentos := aClone( MNT280RAT(TQB->TQB_SOLICI, , TQB->TQB_FILIAL) )
		aHeadAtend := aClone( aAtendimentos[1] )
		aColsAtend := aClone( aAtendimentos[2] )
		nTURTIPO   := aScan(aHeadAtend, {|x| AllTrim(x[2]) == "TUR_TIPO" })
		nTURFILATE := aScan(aHeadAtend, {|x| AllTrim(x[2]) == "TUR_FILATE" })
		nTURCODATE := aScan(aHeadAtend, {|x| AllTrim(x[2]) == "TUR_CODATE" })
		For nX := 1 To Len(aColsAtend)
			If aColsAtend[nX][nTURTIPO] == "2"// .And. AllTrim(aColsAtend[nX][nTURFILATE]) == AllTrim(xFilial("ST1",TQB->TQB_FILIAL))
				nExecuta := aScan(aExecuta, {|x| x[1] == TQB->TQB_FILIAL .And. x[2] == aColsAtend[nX][nTURCODATE] })
				If nExecuta == 0
					aAdd(aExecuta, {TQB->TQB_FILIAL, aColsAtend[nX][nTURCODATE], Posicione("ST1", 1, xFilial("ST1",TQB->TQB_FILIAL) + aColsAtend[nX][nTURCODATE], "T1_NOME"), {}, 0, 0})
					nExecuta := Len(aExecuta)
				EndIf
			EndIf
		Next nX

		//-- Criticidade
		nCritici := aScan(aCritici, {|x| x[1] == TQB->TQB_FILIAL .And. x[2] == TQB->TQB_CRITIC })
		aCriAux := MNT293CRI()
		For i:=1 to Len(aCriAux)
				If TQB->TQB_CRITIC >= aCriAux[i][3] .And. TQB->TQB_CRITIC <= aCriAux[i][4]
					cCritic := aCriAux[i][2]
				EndIf
		Next i

		If nCritici == 0
			aAdd(aCritici, {TQB->TQB_FILIAL, TQB->TQB_CRITIC, AllTrim(cCritic), {}, 0, 0})
			nCritici := Len(aCritici)
		EndIf

		//-- Satisfação da S.S.
		cAuxID := fLimiarSS(TQB->TQB_FILIAL, TQB->TQB_SOLICI)
		nSatisfa := aScan(aSatisfa, {|x| x[1] == TQB->TQB_FILIAL .And. x[2] == cAuxID })
		If nSatisfa == 0
			If Empty(cAuxID)
				cAuxDesc := STR0047 //"Sem Limiar definido"
			Else
				cAuxDesc := Posicione("TUW", 1, xFilial("TUW",TQB->TQB_FILIAL) + cAuxID, "TUW_DESCRI")
			EndIf
			aAdd(aSatisfa, {TQB->TQB_FILIAL, cAuxID, cAuxDesc, {}, 0, 0})
			nSatisfa := Len(aSatisfa)
		EndIf

		//-- Armazena Solicitações
		aAuxSS := {TQB->TQB_FILIAL, TQB->TQB_SOLICI}
		If nSolicit > 0
			aAdd(aSolicit[nSolicit][4], aClone(aAuxSS))
		EndIf
		If nPriorid > 0
			aAdd(aPriorid[nPriorid][4], aClone(aAuxSS))
		EndIf
		If nServico > 0
			aAdd(aServico[nServico][4], aClone(aAuxSS))
		EndIf
		If nExecuta > 0
			aAdd(aExecuta[nExecuta][4], aClone(aAuxSS))
		EndIf
		If nCritici > 0
			aAdd(aCritici[nCritici][4], aClone(aAuxSS))
		EndIf
		If nSatisfa > 0
			aAdd(aSatisfa[nSatisfa][4], aClone(aAuxSS))
		EndIf

		dbSelectArea("TQB")
		dbSkip()
	End
	aDadosConsulta[1] := aClone(aSolicit)
	aDadosConsulta[2] := aClone(aPriorid)
	aDadosConsulta[3] := aClone(aServico)
	aDadosConsulta[4] := aClone(aExecuta)
	aDadosConsulta[5] := aClone(aCritici)
	aDadosConsulta[6] := aClone(aSatisfa)
	aEval(aDadosConsulta, {|aDet| aSort(aDet, , , {|x,y| x[1] < y[1] .And. x[2] < y[2] })}) // Ordena pelo [Identificador]
	// Calcula os Tempos de Execução e Atendimento
	For nTip := 1 To Len(aDadosConsulta)
		For nVis := 1 To Len(aDadosConsulta[nTip])
			nTempoExec := 0
			nTempoAten := 0
			For nSS := 1 To Len(aDadosConsulta[nTip][nVis][4])
				dbSelectArea("TQB")
				dbSetOrder(1)
				If dbSeek(aDadosConsulta[nTip][nVis][4][nSS][1] + aDadosConsulta[nTip][nVis][4][nSS][2])
					nTempoExec += HTON(TQB->TQB_TEMPO)
					dbSelectArea("TUM")
					dbSetOrder(2) //TUM_FILIAL+TUM_CODFOL+TUM_SOLICI
					If dbSeek(xFilial("TUM",TQB->TQB_FILIAL) + PADR("09", TAMSX3("TUM_CODFOL")[1], " ") + TQB->TQB_SOLICI)
						nTempoAten += HTON( NGCALCHCAR(TQB->TQB_DTABER, TQB->TQB_HOABER, TUM->TUM_DTINIC, SubStr(TUM->TUM_HRINIC,1,5)) )
					EndIf
				EndIf
			Next nSS
			cTempoExec := NTOH( (nTempoExec/Len(aDadosConsulta[nTip][nVis][4])) )
			cTempoAten := NTOH( (nTempoAten/Len(aDadosConsulta[nTip][nVis][4])) )
			aDadosConsulta[nTip][nVis][5] := cTempoExec
			aDadosConsulta[nTip][nVis][6] := cTempoAten
		Next nVis
	Next nTip

	// Cursos Normal
	CursorArrow()

	// Define estado da consulta
	lConsulta := ( Len(aDadosConsulta[1]) > 0 ) // // Indica que a consulta foi ou não gerada
	lDetalhes := .F. // Indica que os detalhes não foram gerados
	If lConsulta
		// Habilita o Browse da Consulta
		oBrwVisual:Enable()

		If !Empty(dDeData) .And. !Empty(dAteData)
			oDetPeriod:SetText(STR0048 + " " + DTOC(dDeData) + " " + STR0049 + " " + DTOC(dAteData)) //"Período de" ## "a"
		ElseIf !Empty(dDeData)
			oDetPeriod:SetText(STR0050 + " " + DTOC(dDeData)) //"Período desde"
		ElseIf !Empty(dAteData)
			oDetPeriod:SetText(STR0051 + " " + DTOC(dAteData)) //"Período até"
		Else
			oDetPeriod:SetText(STR0052) //"Qualquer Período"
		EndIf
		oDetTipAna:SetText(aTipAnalis[nTipAnalis][1])

		// Executa Forma de Visualização
		fFormVisualiz()
	Else
		// Desabilita o Browse da Consulta
		aCols := { Array(Len(oBrwVisual:aColumns)+1) }
		oBrwVisual:SetArray(aCols)
		oBrwVisual:GoTop(.T.)
		oBrwVisual:Disable()

		oDetPeriod:SetText("")
		oDetTipAna:SetText("")
	EndIf
	aCols := { Array(Len(oBrwDetalh:aColumns)) }
	oBrwDetalh:SetArray(aCols)
	oBrwDetalh:GoTop(.T.)
	oBrwDetalh:Disable()
	oBrwDetalh:DisableFilter()
	oDetForVis:SetText("")


	// Foco no Browse da Consulta
	oBrwVisual:oBrowse:SetFocus()

	// Devolve as áreas
	RestArea(aAreaTUW)
	RestArea(aAreaST1)
	RestArea(aAreaTUR)
	RestArea(aAreaTQ3)
	RestArea(aAreaTQB)
	RestArea(aAreaOld)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fFiltConsulta
Filtro do Processamento dos Dados da Consulta.
* ATENÇÃO: O registro da tabela TQB deve estar posicionado corretamente.

@author Wagner Sobral de Lacerda
@since 21/11/2012

@return lFiltOk
/*/
//---------------------------------------------------------------------
Static Function fFiltConsulta()

	// Salva as áreas atuais
	Local aAreaTQB := TQB->( GetArea() )

	// Variáveis de parâmetro SX6
	Local lNGMulOS := ( SuperGetMV("MV_NGMULOS", .F., "N") == "S" )

	// Variável do Filtro
	Local lFiltOk := .T.

	//----------
	// Filtro
	//----------
	//-- Parâmetros Globais
	If !Empty(dDeData) .And. TQB->TQB_DTABER < dDeData
		lFiltOk := .F.
	EndIf
	If !Empty(dAteData) .And. TQB->TQB_DTABER > dAteData
		lFiltOk := .F.
	EndIf

	If !Empty(cFilterTQB)
		If !&(cFilterTQB)
			lFiltOk := .F.
		EndIf
	EndIf

	//-- Filtro de acordo com o Tipo de Análise
	If nTipAnalis == 1 // Todas
		// Não filtra...
	ElseIf nTipAnalis == 2 // Pendentes
		If AllTrim(TQB->TQB_SOLUCA) <> "A" ; lFiltOk := .F. ; EndIf
	ElseIf nTipAnalis == 3 // Em Atendimento
		If AllTrim(TQB->TQB_SOLUCA) <> "D" ; lFiltOk := .F. ; EndIf
	ElseIf nTipAnalis == 4 // Encerradas
		If AllTrim(TQB->TQB_SOLUCA) <> "E" ; lFiltOk := .F. ; EndIf
	ElseIf nTipAnalis == 5 // Canceladas
		If AllTrim(TQB->TQB_SOLUCA) <> "C" ; lFiltOk := .F. ; EndIf
	ElseIf nTipAnalis == 6 // O.S.s Geradas
		If !lNGMulOS
			If Empty(TQB->TQB_ORDEM) ; lFiltOk := .F. ; EndIf
		Else
			dbSelectArea("TT7")
			dbSetOrder(1)
			If !dbSeek(xFilial("TT7",TQB->TQB_FILIAL) + TQB->TQB_SOLICI) ; lFiltOk := .F. ; EndIf
		EndIf
	ElseIf nTipAnalis == 7 // Satisfação
		If !(TQB->TQB_SOLUCA == "E" .And. !Empty(TQB->TQB_SEQQUE) .And. TQB->TQB_SATISF == "1") ; lFiltOk := .F. ; EndIf
	EndIf

	// Devolve as áreas
	RestArea(aAreaTQB)

Return lFiltOk

//---------------------------------------------------------------------
/*/{Protheus.doc} fLimiarSS
Retorna o Código do Limiar do Questionário da S.S.

@author Wagner Sobral de Lacerda
@since 28/11/2012

@return cCodLimiar
/*/
//---------------------------------------------------------------------
Static Function fLimiarSS(cFilSS, cCodSS)

	// Salva as áreas atuas
	Local aAreaTQB := TQB->( GetArea() )
	Local aAreaTUQ := TUP->( GetArea() )
	Local aAreaTUP := TUQ->( GetArea() )
	Local aAreaTUY := TUY->( GetArea() )

	// Variável do Retorno
	Local cCodLimiar := Space( TAMSX3("TUW_CODIGO")[1] )

	// Variáveis Auxiliares
	Local cTipQuest := "", cCodQuest := "", cLojQuest := ""
	Local aSatis := {}, aResps := {}, aQuest := {}, aValor := {}

	Local nX := 0, nAT := 0
	Local nResp := 0, cResp := ""
	Local nValor := 0, cValor := ""
	Local nPontuacao := 0

	//-- Busca Questinário de Satisfação
	dbSelectArea("TQB")
	dbSetOrder(1)
	If dbSeek(cFilSS + cCodSS)
		If !Empty(TQB->TQB_SEQQUE)
			dbSelectArea("TUQ")
			dbSetOrder(1)
			If dbSeek(xFilial("TUQ",TQB->TQB_FILIAL) + TQB->TQB_SEQQUE)
				cTipQuest := TUQ->TUQ_TIPO
				cCodQuest := TUQ->TUQ_QUESTI
				cLojQuest := TUQ->TUQ_LOJA
				aQuest := {}
				aValor := {}
				While !Eof() .And. TUQ->TUQ_FILIAL == xFilial("TUQ",TQB->TQB_FILIAL) .And. TUQ->TUQ_SEQUEN == TQB->TQB_SEQQUE
					aResps := StrTokArr(AllTrim(TUQ->TUQ_RESPOS), ";")
					dbSelectArea("TUP")
					dbSetOrder(1)
					If dbSeek(xFilial("TUP",TUQ->TUQ_FILIAL) + cTipQuest + cCodQuest + cLojQuest + TUQ->TUQ_QUESTA)
						aQuest := StrTokArr(AllTrim(TUP->TUP_PERGUT), ";")
						aValor := StrTokArr(AllTrim(TUP->TUP_VALORE), ";")
					EndIf
					aAdd(aSatis, {aClone(aResps), aClone(aQuest), aClone(aValor)})
					dbSelectArea("TUQ")
					dbSkip()
				End
			EndIf
		EndIf
	EndIf
	//-- Calcula a Pontuação do Questionário
	If Len(aSatis) > 0
		For nX := 1 To Len(aSatis)
			For nResp := 1 To Len(aSatis[nX][1])
				nAT := AT("=", aSatis[nX][1][nResp])
				If nAT > 0
					cResp := SubStr(aSatis[nX][1][nResp],1,nAT-1)
					nValor := aScan(aSatis[nX][3], {|x| SubStr(x,1,nAT-1) == cResp })
					If nValor > 0
						cValor := SubStr(aSatis[nX][3][nValor],nAT+1)
						nPontuacao += Val(cValor)
					EndIf
				EndIf
			Next nResp
		next nX
	EndIf
	//-- Busca o Código do Limiar em que se enquadra a S.S.
	If !Empty(cCodQuest)
		dbSelectArea("TUY")
		dbSetOrder(1)
		dbSeek(xFilial("TUY",cFilSS) + cTipQuest + cCodQuest + cLojQuest, .T.)
		While !Eof() .And. TUY->TUY_FILIAL == xFilial("TUY",cFilSS) .And. TUY->TUY_TIPO == cTipQuest .And. TUY->TUY_QUESTI == cCodQuest .And. TUY->TUY_LOJA == cLojQuest
			If nPontuacao >= TUY->TUY_LIMDE .And. nPontuacao <= TUY->TUY_LIMATE
				cCodLimiar := TUY->TUY_LIMIAR
				Exit
			EndIf
			dbSelectArea("TUY")
			dbSkip()
		End
	EndIf

	// Devolve as áreas
	RestArea(aAreaTUY)
	RestArea(aAreaTUQ)
	RestArea(aAreaTUP)
	RestArea(aAreaTQB)

Return cCodLimiar

//---------------------------------------------------------------------
/*/{Protheus.doc} fFormVisualiz
Gera a Consulta de acordo com a Forma de Visualização.

@author Wagner Sobral de Lacerda
@since 21/11/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fFormVisualiz()

	// Variáveis para a Montagem
	Local aCols := {}
	Local aAuxDet := {}
	Local nX := 0

	/* Descrição do Array:
		{[Filial], [Identificador], [Descrição], [Quantidade de S.S.'s], [Tempo Médio de Execução], [Tempo Médio para Atendimento], [Marcado?(sempre deve ser a última posição)]}
	*/
	// Verifica se pode Gerar
	If Len(aDadosConsulta) > 0 .And. Len(aTipVisual) > 0 .And. !Empty(cTipVisual)
		If cTipVisual == "1" // Solicitação
			aAuxDet := aClone(aDadosConsulta[1])
		ElseIf cTipVisual == "2" // Prioridade
			aAuxDet := aClone(aDadosConsulta[2])
		ElseIf cTipVisual == "3" // Serviço
			aAuxDet := aClone(aDadosConsulta[3])
		ElseIf cTipVisual == "4" // Executante
			aAuxDet := aClone(aDadosConsulta[4])
		ElseIf cTipVisual == "5" // Criticidade
			aAuxDet := aClone(aDadosConsulta[5])
		ElseIf cTipVisual == "6" // Satisfação
			aAuxDet := aClone(aDadosConsulta[6])
		EndIf

		For nX := 1 To Len(aAuxDet)
			aAdd(aCols, {aAuxDet[nX][1], aAuxDet[nX][2], aAuxDet[nX][3], Len(aAuxDet[nX][4]), aAuxDet[nX][5], aAuxDet[nX][6], (cTipVisual == "1")})
		Next nX
	EndIf

	// Conteúdo em Branco
	If Len(aCols) == 0
		aCols := { Array(Len(oBrwVisual:aColumns)+1) }
	EndIf

	// Seta o Array do Browse da Forma de Visualização
	oBrwVisual:SetArray(aCols)
	oBrwVisual:GoTop(.T.)

	// Limpa Detalhes
	oBrwDetalh:SetArray({ Array(Len(oBrwDetalh:aColumns)) })
	oBrwDetalh:GoTop(.T.)
	oBrwDetalh:Disable()
	lDetalhes := .F. // Indica que os detalhes não foram gerados

	// Fecha a janela de detalhes
	If oMainLayer:winOpen("Coluna_Consulta", "Janela_Detalhes", "Linha_Main")
		oMainLayer:winChgState("Coluna_Consulta", "Janela_Detalhes", "Linha_Main")
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fGeraDetalhes
Monta os Detalhes da Consulta.

@author Wagner Sobral de Lacerda
@since 22/11/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fGeraDetalhes(cFiltAdvPL)

	// Salva as áreas atuais
	Local aAreaOld := GetArea()
	Local aAreaTQB := TQB->( GetArea() )
	Local aAreaSX3 := SX3->( GetArea() )

	// Variáveis auxiliares
	Local aAuxDet := {}
	Local nVis := 0, nSS := 0
	Local aAuxSS := {}

	Local aHeader := aClone(aHeaDetalh), aCols := {}
	Local nHeader, nCols
	Local uSetData

	// Defaults
	Default cFiltAdvPL := ".T."
	If Empty(cFiltAdvPL)
		cFiltAdvPL := ".T."
	EndIf

	// Verifica se pode Gerar
	If Len(aDadosConsulta) > 0 .And. Len(aTipVisual) > 0 .And. !Empty(cTipVisual)
		If cTipVisual == "1" // Solicitação
			aAuxDet := aClone(aDadosConsulta[1])
		ElseIf cTipVisual == "2" // Prioridade
			aAuxDet := aClone(aDadosConsulta[2])
		ElseIf cTipVisual == "3" // Serviço
			aAuxDet := aClone(aDadosConsulta[3])
		ElseIf cTipVisual == "4" // Executante
			aAuxDet := aClone(aDadosConsulta[4])
		ElseIf cTipVisual == "5" // Criticidade
			aAuxDet := aClone(aDadosConsulta[5])
		ElseIf cTipVisual == "6" // Satisfação
			aAuxDet := aClone(aDadosConsulta[6])
		EndIf

		If Len(aAuxDet) > 0
			For nVis := 1 To Len(aAuxDet)
				If aScan(oBrwVisual:Data():GetArray(), {|x| x[1] == aAuxDet[nVis][1] .And. x[2] == aAuxDet[nVis][2] .And. aTail(x) }) > 0 // Apenas se a estiver marcado
					For nSS := 1 To Len(aAuxDet[nVis][4])
						aAdd(aAuxSS, aClone(aAuxDet[nVis][4][nSS]))
					Next nSS
				EndIf
			Next nVis

			For nSS := 1 To Len(aAuxSS)
				dbSelectArea("TQB")
				dbSetOrder(1)
				If dbSeek(aAuxSS[nSS][1] + aAuxSS[nSS][2])
					If &(cFiltAdvPL) // Filtro personalizado
						aAdd(aCols, Array(Len(aHeader)))
						nCols := Len(aCols)
						For nHeader := 1 To Len(aHeader)
							uSetData := "NULL"
							If Posicione("SX3",2, aHeader[nHeader][5], "X3_CONTEXT") <> "V" // REAL
								uSetData := &("TQB->"+aHeader[nHeader][5])
								If !Empty(X3CBox())
									uSetData := NGRetSX3Box(aHeader[nHeader][5], uSetData)
								EndIf
							ElseIf Posicione("SX3",2, aHeader[nHeader][5], "X3_CONTEXT") == "V" .And. !Empty(Posicione("SX3",2, aHeader[nHeader][5], "X3_INIBRW")) // VIRTUAL COM INICIALIZADOR
								uSetData := &(Posicione("SX3",2, aHeader[nHeader][5], "X3_INIBRW"))
							EndIf
							aCols[nCols][nHeader] := uSetData
						Next nHeader
					EndIf
				EndIf
			Next nSS
		EndIf
	EndIf
	If Len(aCols) == 0
		aCols := { Array(Len(oBrwDetalh:aColumns)) }
	EndIf

	// Habilita o Browse de Detalhes
	oBrwDetalh:SetArray(aCols)
	oBrwDetalh:Enable()
	oBrwDetalh:GoTop(.T.)
	oDetForVis:SetText(SubStr(aTipVisual[Val(cTipVisual)],3))

	// Indica que os detalhes foram montados
	lDetalhes := .T.

	// Foco no Browse da Consulta
	oBrwDetalh:oBrowse:SetFocus()

	// Abre a janela de detalhes
	If !oMainLayer:winOpen("Coluna_Consulta", "Janela_Detalhes", "Linha_Main")
		oMainLayer:winChgState("Coluna_Consulta", "Janela_Detalhes", "Linha_Main")
	EndIf

	// Devolve as áreas
	RestArea(aAreaSX3)
	RestArea(aAreaTQB)
	RestArea(aAreaOld)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fViewDetail
Executa o Clique dos botões dos Detalhes.

@author Wagner Sobral de Lacerda
@since 22/11/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fViewDetail(nOpcao)

	// Salva as áreas atuais
	Local aAreaOld := GetArea()
	Local aAreaTQB := TQB->( GetArea() )

	// Armazena Variáveis
	Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)
	Local aMemory  := NGGetMemory("TQB")
	Local cOldFil := cFilAnt
	// Variávies da S.S.
	Local aLinha := aClone( oBrwDetalh:Data():GetArray()[oBrwDetalh:AT()] )
	Local cFilSS := "", nFilSS := aScan(aHeaDetalh, {|x| Upper(AllTrim(x[5])) == "TQB_FILIAL" })
	Local cCodSS := "", nCodSS := aScan(aHeaDetalh, {|x| Upper(AllTrim(x[5])) == "TQB_SOLICI" })
	// Variáveis Private necessárias
	Private cCadastro
	Private aRotina := {	{"", "PesqBrw" , 0, 1}, ;
							{"", "AxVisual", 0, 2}, ;
							{"", "AxVisual", 0, 3}, ;
							{"", "AxVisual", 0, 4}, ;
							{"", "AxVisual", 0, 5, 3} }

	// Recebe dados da S.S.
	If nFilSS > 0
		cFilSS := aLinha[nFilSS]
	EndIf
	If nCodSS > 0
		cCodSS := aLinha[nCodSS]
	EndIf

	//----------
	// Executa
	//----------
	If !Empty(cCodSS)
		oBlackPnl:Show() // Mostra Painel Preto
		If !Empty(cFilSS)
			cFilAnt := cFilSS
		EndIf
		If nOpcao >= 1 .And. nOpcao <= 7
			dbSelectArea("TQB")
			dbSetOrder(1)
			If dbSeek(xFilial("TQB",cFilSS) + cCodSS)
				// Carrega Variáveis da S.S.
				MNT280CPO(2,2)
				MNT280REG(2, a280Relac, a280Memos)
				If nOpcao == 1 // Questionário
					cCadastro := STR0053 //"Questionário"
					MNT280DIAG(.F., .F., Nil)
				ElseIf nOpcao == 2 // Detalhamento
					cCadastro := STR0041 //"Detalhamento da Solicitação"
					MNTA280IN(2,1)
				ElseIf nOpcao == 3 // Informações do Solicitante
					dbSelectArea("TUF")
					dbSetOrder(1)
					If dbSeek(xFilial("TUF")+TQB->TQB_CDSOLI)
						cCadastro := STR0042 //"Informações do Solicitante"
						FWExecView( cCadastro , 'MNTA909' , MODEL_OPERATION_VIEW , , { || .T. } )
					Endif
				ElseIf nOpcao == 4 // Ordens de Serviço
					MNT291OS(TQB->TQB_FILIAL, TQB->TQB_SOLICI, .T.)
				ElseIf nOpcao == 5 // Conhecimento
					cCadastro := STR0044 //"Conhecimento"
					MsDocument("TQB",TQB->(Recno()),2)
				ElseIf nOpcao == 6 // Pesquisa de Satisfação
					MNT307QUE(.T., TQB->TQB_SOLICI)
				ElseIf nOpcao == 7 // Calendário
					fCalendario(TQB->TQB_FILIAL, TQB->TQB_SOLICI)
				EndIf
			EndIf
		ElseIf nOpcao == 8
			fIndicadores()
		EndIf
		oBlackPnl:Hide() // Esconde Painel Preto
	EndIf

	// Devolve Variáveis
	cFilAnt := cOldFil
	NGRETURNPRM(aNGBEGINPRM)
	NGRestMemory(aMemory)
	RestArea(aAreaTQB)
	RestArea(aAreaOld)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fGrafico
Executa o Clique dos botões dos Detalhes.

@author Wagner Sobral de Lacerda
@since 22/11/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fGrafico()

	// Salva as áreas atuais
	Local aAreaOld := GetArea()
	Local aAreaTQB := TQB->( GetArea() )

	// Armazena Variáveis
	Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)
	Local aMemory  := NGGetMemory("TQB")
	Local cOldFil := cFilAnt

	// Variáveis para o Gráfico
	Local oDlgGraf
	Local cDlgGraf	:= OemToAnsi(STR0054) //"Gráfico da Consulta Gerencial"

	Local aAuxGraf	:= {}
	Local aCols		:= {}
	Local aDados	:= {}
	Local nX		:= 0
	Local nVis		:= 0

	If Len(aDadosConsulta) > 0 .And. Len(aTipVisual) > 0 .And. !Empty(cTipVisual)
		aAuxGraf := aClone(aDadosConsulta[Val(cTipVisual)])
	EndIf
	If Len(aAuxGraf) > 0
		For nVis := 1 To Len(aAuxGraf)
			If aScan(oBrwVisual:Data():GetArray(), {|x| x[1] == aAuxGraf[nVis][1] .And. aTail(x) }) > 0 // Apenas se a estiver marcado
				aAdd(aCols, oBrwVisual:Data():GetArray()[nVis])
			EndIf
		Next nVis
	EndIf

	//----------
	// Executa
	//----------
	If Len(acols) == 0
		Help(Nil, Nil, STR0055, Nil, STR0056, 1, 0) //"Atenção" ## "Não há dados para montar o Gráfico."
	Else
		//-- Recebe os dados para gerar o gráfico
		For nX := 1 To Len(aCols)
			// {[Identificador], [Descrição], [Quantidade de S.S.'s], [Tempo Médio de Execução], [Tempo Médio para Atendimento]}
			aAdd(aDados, {aCols[nX][2], aCols[nX][3], aCols[nX][4], HTON(aCols[nX][5]), HTON(aCols[nX][6])})
		Next nX

		oBlackPnl:Show() // Mostra Painel Preto

		//--------------------
		// Monta o Dialog
		//--------------------
		DEFINE MSDIALOG oDlgGraf TITLE cDlgGraf FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL
		ACTIVATE MSDIALOG oDlgGraf ON INIT fGrafFold(oDlgGraf, aDados) CENTERED

		oBlackPnl:Hide() // Esconde Painel Preto
	EndIf

	// Devolve Variáveis
	NGRETURNPRM(aNGBEGINPRM)
	NGRestMemory(aMemory)
	RestArea(aAreaTQB)
	RestArea(aAreaOld)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fGrafFold
Monta os Gráficos dentro de um Folder.

@author Wagner Sobral de Lacerda
@since 22/11/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fGrafFold(oObjPai, aDados)

	// Variáveis para a Montagem
	Local oFolder, aFolder, nFolder
	Local nX := 0

	Local aGrafico := {}
	Local oTmpPnl, oTmpBtn
	Local oTmpGrafs

	Local aNGColor := aClone(NGColor())
	Local nPosValor := 0

	//----------
	// Monta
	//----------
	// Folder dos Gráficos
	aFolder := {STR0057, STR0058, STR0059} //"Quantidade de Solicitações" ## "Tempo Médio de Execução" ## "Tempo Médio para Atendimento"
	oFolder := TFolder():New(01, 01, aFolder, aFolder, oObjPai, 1, CLR_BLACK, CLR_WHITE, .T., , aSize[6]/2, aSize[5]/2)
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT
	For nFolder := 1 To Len(oFolder:aDialogs)
		// Monta Painel para o Gráfico
		aAdd(aGrafico, Array(4))
		Do Case
			Case nFolder == 1
				nPosValor := 3
			Case nFolder == 2
				nPosValor := 4
			Case nFolder == 3
				nPosValor := 5
		EndCase

		// Cabeçalho
		oTmpPnl := TPanel():New(0, 0, , oFolder:aDialogs[nFolder], , , , aNGColor[1], aNGColor[2], 100, 030, .F., .F.)
		oTmpPnl:Align := CONTROL_ALIGN_TOP

			// Forma de Visualização
			@ 008,010 SAY OemToAnsi(STR0060) + SubStr(aTipVisual[Val(cTipVisual)],3) FONT oFnt26Bold COLOR aNGColor[1],aNGColor[2] OF oTmpPnl PIXEL //"Visualização das Solicitações por: "

			// Botão: Gráfico Pizza
			oTmpBtn := TBtnBmp2():New(001, 001, 60, 60, "fw_piechart_1", , , , &("{|| aGrafico["+cValToChar(nFolder)+"][1]:Hide(), aGrafico["+cValToChar(nFolder)+"][3]:Show() }"), oTmpPnl, STR0061, {|| .T. }) //"Gráfico em Barras"
			oTmpBtn:Align := CONTROL_ALIGN_RIGHT

			// Botão: Gráfico em Barras
			oTmpBtn := TBtnBmp2():New(001, 001, 60, 60, "fw_barchart_1", , , , &("{|| aGrafico["+cValToChar(nFolder)+"][3]:Hide(), aGrafico["+cValToChar(nFolder)+"][1]:Show() }"), oTmpPnl, STR0061, {|| .T. }) //"Gráfico em Barras"
			oTmpBtn:Align := CONTROL_ALIGN_RIGHT

		// Painel do Gráfico em Barras
		aGrafico[nFolder][1] := TPanel():New(0, 0, , oFolder:aDialogs[nFolder], , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
		aGrafico[nFolder][1]:Align := CONTROL_ALIGN_ALLCLIENT

			//-- Gráfico: Em Barras
			aGrafico[nFolder][2] := FWChartFactory():New()
			aGrafico[nFolder][2] := aGrafico[nFolder][2]:GetInstance(BARCHART) // Cria objeto FWChartBar
			aGrafico[nFolder][2]:Init(aGrafico[nFolder][1], .T.)
			aGrafico[nFolder][2]:SetTitle(oFolder:aPrompts[nFolder], CONTROL_ALIGN_CENTER)
			aGrafico[nFolder][2]:SetLegend(CONTROL_ALIGN_RIGHT)
			For nX := 1 To Len(aDados)
				aGrafico[nFolder][2]:AddSerie(AllTrim(aDados[nX][1])+" - "+AllTrim(aDados[nX][2]), aDados[nX][nPosValor])
			Next nX
			aGrafico[nFolder][2]:nTAlign := CONTROL_ALIGN_ALLCLIENT
			aGrafico[nFolder][2]:Build()
		aGrafico[nFolder][1]:Hide()

		// Painel do Gráfico Pizza
		aGrafico[nFolder][3] := TPanel():New(0, 0, , oFolder:aDialogs[nFolder], , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
		aGrafico[nFolder][3]:Align := CONTROL_ALIGN_ALLCLIENT

			//-- Gráfico: Pizza (ou Torta)
			aGrafico[nFolder][4] := FWChartFactory():New()
			aGrafico[nFolder][4] := aGrafico[nFolder][4]:GetInstance(PIECHART) // Cria objeto FWChartPie
			aGrafico[nFolder][4]:Init(aGrafico[nFolder][3], .T.)
			aGrafico[nFolder][4]:SetTitle(oFolder:aPrompts[nFolder], CONTROL_ALIGN_CENTER)
			aGrafico[nFolder][4]:SetLegend(CONTROL_ALIGN_RIGHT)
			For nX := 1 To Len(aDados)
				aGrafico[nFolder][4]:AddSerie(AllTrim(aDados[nX][1])+" - "+AllTrim(aDados[nX][2]), aDados[nX][nPosValor])
			Next nX
			aGrafico[nFolder][4]:nTAlign := CONTROL_ALIGN_ALLCLIENT
			aGrafico[nFolder][4]:Build()
		aGrafico[nFolder][3]:Hide()
		aGrafico[nFolder][1]:Show()
	Next nFolder

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fIndicadores
Monta os Indicadores.

@author Wagner Sobral de Lacerda
@since 23/11/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fIndicadores()

	// Salva as áreas atuais
	Local aAreaOld := GetArea()

	// Armazena Variáveis
	Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)

	// Variáveis para os Indicadores Gráficos
	Local oDlgInds
	Local cDlgInds := OemToAnsi(STR0054) //"Gráfico da Consulta Gerencial"

	//--------------------
	// Monta o Dialog
	//--------------------
	If !FindFunction("NGI8TNGPnl")
		Help(Nil, Nil, STR0055, Nil, STR0062, 1, 0) //"Atenção" ## "O ambiente atual do Protheus não está atualizado com a Suíte de Indicadores Gráficos, portanto esta operação será abortada."
	Else
		DEFINE MSDIALOG oDlgInds TITLE cDlgInds FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL

			NGI8TNGPnl(oDlgInds)

		ACTIVATE MSDIALOG oDlgInds CENTERED
	EndIf

	// Devolve Variáveis
	NGRETURNPRM(aNGBEGINPRM)
	RestArea(aAreaOld)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fCalendario
Monta os Calendário.

@author Wagner Sobral de Lacerda
@since 23/11/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fCalendario(cFilSS, cCodSS)

	// Salva as áreas atuais
	Local aAreaOld := GetArea()
	Local aAreaTQB := TQB->( GetArea() )
	Local aAreaTUM := TUM->( GetArea() )

	// Armazena Variáveis
	Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)

	// Variáveis para o Calendário
	Local oDlgCalend
	Local cDlgCalend := OemToAnsi(STR0063) //"Calendário da S.S."
	Local oPnlCabec
	Local oPnlSelec
	Local oTmpPnl, oTmpBtn

	Local cIDHeader, nPercHead := (060 * 100) / aSize[6]
	Local cIDCalend, nPercCale := 96 - (nPercHead)

	Local aNGColor := NGColor()

	// Variáveis da S.S.
	Local cCodBemLoc := ""
	Local cNomBemLoc := ""
	Local dAuxData
	Local nX

	Private aSSDados := {}
	Private oCalendar
	Private oTelaHead
	Private oTelaCalen
	Private oSeleAtual, dDataAtual

	// Defaults
	Default cFilSS := ""
	Default cCodSS := ""

	//--------------------
	// Recebe dados da S.S.
	//--------------------
	dbSelectArea("TQB")
	dbSetOrder(1)
	If dbSeek(cFilSS + cCodSS)
		cCodBemLoc := TQB->TQB_CODBEM
		cNomBemLoc := MNT280REL("TQB_NOMBEM", .T.)

		/* Definição do Array 'aSSDados':
			[1] - Data
			[2] - Hora
			[3] - Dia
			[4] - Mês
			[5] - Ano
			[6] - Descrição
			[7] - Código da Tabela
			[8] - RecNo da Tabela
		*/
		// Follow-Up
		dbSelectArea("TUM")
		dbSetOrder(3)
		dbSeek(xFilial("TUM",TQB->TQB_FILIAL) + TQB->TQB_SOLICI, .T.)
		While !Eof() .And. TUM->TUM_FILIAL == xFilial("TUM",TQB->TQB_FILIAL) .And. TUM->TUM_SOLICI == TQB->TQB_SOLICI
			dAuxData := TUM->TUM_DTINIC
			dbSelectArea("SX5")
			dbSetOrder(1)
			dbSeek(xFilial("SX5") + "RQ" + TUM->TUM_CODFOL)
			If aScan(aSSDados, {|x| x[1] == dAuxData .And. x[6] == X5Descri() }) == 0
				aAdd(aSSDados, {dAuxData, TUM->TUM_HRINIC, Day(dAuxData), Month(dAuxData), Year(dAuxData), X5Descri(), "TUM", TUM->(RecNo())})
			EndIf
			dbSelectArea("TUM")
			dbSkip()
		End
	EndIf
	// Ordena por Data + Hora + RecNo
	aSort(aSSDados, , , {|x,y| DTOS(x[1])+x[2]+StrZero(x[8],10) < DTOS(y[1])+y[2]+StrZero(y[8],10) })

	//--------------------
	// Monta o Dialog
	//--------------------
	If Len(aSSDados) == 0
		Help(Nil, Nil, STR0055, Nil, STR0065, 1, 0) //"Atenção" ## "Não há dados para exibir."
	Else
		dDataAtual := aSSDados[1][1]
		DEFINE MSDIALOG oDlgCalend TITLE cDlgCalend FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL

			// Cria Container
			oContainer := FWFormContainer():New(oDlgCalend)
			cIDHeader := oContainer:CreateHorizontalBox(nPercHead)
			cIDCalend := oContainer:CreateHorizontalBox(nPercCale)
			oContainer:Activate(oDlgCalend, .F.)

				oTelaHead  := oContainer:GetPanel(cIDHeader)
				oTelaCalen := oContainer:GetPanel(cIDCalend)

			//------------------------------
			// Monta Cabeçalho
			//------------------------------
			oPnlCabec := TPanel():New(0, 0, , oTelaHead, , , , aNGColor[1], aNGColor[2], 100, 100, .F., .F.)
			oPnlCabec:Align := CONTROL_ALIGN_ALLCLIENT
				// Filial
				@ 005,005 SAY OemToAnsi(STR0066 + cFilSS + " - " + AllTrim(FWFilialName(cEmpAnt, cFilSS, 2))) FONT oFnt18Bold COLOR aNGColor[1],aNGColor[2] OF oPnlCabec PIXEL //"Filial: "
				// Código da S.S.
				@ 018,005 SAY OemToAnsi(STR0067 + cCodSS) + ; //"Solicitação de Serviço: "
								Space(10) + OemToAnsi(STR0068 + AllTrim(cCodBemLoc) + " - " + AllTrim(cNomBemLoc)); //"Bem/Localização: "
								FONT oFnt18Bold COLOR aNGColor[1],aNGColor[2] OF oPnlCabec PIXEL

			oPnlSelec := TPanel():New(0, 0, , oTelaHead, , , , aNGColor[1], aNGColor[2], 100, 100, .F., .F.)
			oPnlSelec:Align := CONTROL_ALIGN_RIGHT
				// Mês/Ano atualmente selecionado
				oSeleAtual := TPanel():New(0, 0, MesExtenso(dDataAtual) + "/" + cValToChar(Year(dDataAtual)), oPnlSelec, oFnt18Bold, .T., , aNGColor[1], aNGColor[2], 100, 010, .F., .F.)
				oSeleAtual:Align := CONTROL_ALIGN_ALLCLIENT
				// Anterior
				oTmpBtn := TBtnBmp2():New(001, 001, 30, 30, "fw_arrow_left", , , , {|| fCalChgSet("PREVIOUS") }, oPnlSelec, STR0069, {|| .T. }) //"Anterior"
				oTmpBtn:Align := CONTROL_ALIGN_LEFT
				// Próximo
				oTmpBtn := TBtnBmp2():New(001, 001, 30, 30, "fw_arrow_right", , , , {|| fCalChgSet("NEXT") }, oPnlSelec, STR0070, {|| .T. }) //"Próximo"
				oTmpBtn:Align := CONTROL_ALIGN_RIGHT

			oTmpPnl := TPanel():New(0, 0, , oTelaHead, , , , aNGColor[1], aNGColor[1], 002, 100, .F., .F.)
			oTmpPnl:Align := CONTROL_ALIGN_RIGHT

			//------------------------------
			// Monta Calendário
			//------------------------------
			oCalendar := FWCalendar():New(Month(dDataBase)/*nMes*/, Year(dDataBase)/*nAno*/)
			oCalendar:blDblClick  := {|aInfo| fCalDblClk(oDlgCalend, oTelaCalen, oCalendar, aInfo) }
			//oCalendar:bRClicked   := {|aInfo, oObj, nRow, nCol| fCalRigClk(aInfo, oObj, nRow, nCol) }
			oCalendar:aNomeCol    := {STR0071, STR0072, STR0073, STR0074, STR0075, STR0076, STR0077, STR0078} //"Domingo" ## "Segunda" ## "Terça" ## "Quarta" ## "Quinta" ## "Sexta" ## "Sábado" ## "Semana"
			oCalendar:lWeekColumn := .F. // Exibe ou não a coluna de semana
			oCalendar:lFooterLine := .F. // Exibe ou não o rodapé
			oCalendar:Activate(oTelaCalen)

		ACTIVATE MSDIALOG oDlgCalend ON INIT fSetCalendar(Month(dDataAtual), Year(dDataAtual)) CENTERED
	EndIf

	// Devolve Variáveis
	NGRETURNPRM(aNGBEGINPRM)
	RestArea(aAreaTUM)
	RestArea(aAreaTQB)
	RestArea(aAreaOld)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fSetCalendar
Seta o Conteúdo do Calendário.

@author Wagner Sobral de Lacerda
@since 23/11/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fSetCalendar(nMontaMes, nMontaAno)

	// Variáveis auxiliares
	Local nCell
	Local nDia, nMes, nAno
	Local nScan
	Local aItens, nItem

	//------------------------------
	// Seta o Mês e o Ano
	//------------------------------
	oCalendar:SetCalendar(oTelaCalen, nMontaMes, nMontaAno)

	//------------------------------
	// Carrega Conteúdo das Células
	//------------------------------
	For nCell := 1 To Len(oCalendar:aCell)
		nDia := oCalendar:aCell[nCell][DIA] // Dia
		nMes := oCalendar:aCell[nCell][MES] // Mês
		nAno := oCalendar:aCell[nCell][ANO] // Ano
		aItens := {}
		If oCalendar:aCell[nCell][ATIVO]
			// Busca se Há dados para exibir na célula
			nScan := aScan(aSSDados, {|x| x[3] == nDia .And. x[4] == nMes .And. x[5] == nAno })
			If nScan > 0
				// Define os Itens
				For nItem := nScan To Len(aSSDados)
					If aSSDados[nItem][3] <> nDia .Or. aSSDados[nItem][4] <> nMes .Or. aSSDados[nItem][5] <> nAno
						Exit
					EndIf
					aAdd(aItens, AllTrim(aSSDados[nItem][6]))
				Next nItem
			EndIf
			// Seta a Informação da Célula
			oCalendar:SetInfo(oCalendar:aCell[nCell][ID], aClone(aItens))
		ElseIf oCalendar:aCell[nCell][SEMANA]
			// Semana não é exibida...
		ElseIf oCalendar:aCell[nCell][FOOTER]
			// Rodapé não é exibido...
		EndIf
	Next nCell

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fCalDblClk
Executa o Duplo Clique sobre um Item do Calendário.

@author Wagner Sobral de Lacerda
@since 23/11/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fCalDblClk(oDialog, oTela, oFWCalend, aInfo)

	// Variáveis auxiliares
	Local nDia := aInfo[DIA]
	Local nMes := aInfo[MES]
	Local nAno := aInfo[ANO]

	//----------
	// Executa
	//----------
	fCalClkDes(nDia, nMes, nAno)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fCalRigClk
Executa o Clique da Direita sobre um Item do Calendário.

@author Wagner Sobral de Lacerda
@since 23/11/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fCalRigClk(aInfo, oObj, nRow, nCol)

	// Variáveis auxiliares
	Local cClassName := oObj:ClassName()
	Local nDia := aInfo[DIA]
	Local nMes := aInfo[MES]
	Local nAno := aInfo[ANO]

	//----------
	// Executa
	//----------
	If cClassName == "TSAY" .Or. cClassName == "TLISTBOX"
		fCalClkDes(nDia, nMes, nAno)
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fCalRigClk
Mostra a Descrição dos Intens sobre o Dia clicado no Calendário.

@author Wagner Sobral de Lacerda
@since 26/11/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fCalClkDes(nDia, nMes, nAno)

	// Variáveis do Dialog
	Local dData := CTOD( cValToChar(nDia) + "/" + cValToChar(nMes) + "/" + cValToChar(nAno) )

	Local oDlgClk
	Local cDlgClk := STR0079 + " " + DTOC(dData) //"Acompanhamento em"
	Local oGetDados

	Local aHeader := {}, aNao := {}
	Local aDesc := {}
	Local nX, nScan

	// Recebe os Dados
	nScan := aScan(aSSDados, {|x| x[1] == dData })
	If nScan == 0
		Return .F.
	EndIf
	aNao := NGCAMPNSX3("TUM", {"TUM_NOMFOL", "TUM_DTINIC", "TUM_HRINIC"}, , , .T.)
	nX := 0 ; aEval(aNao, {|x| nX++, aNao[nX] := AllTrim(aNao[nX]) })
	aHeader := aClone( CABECGETD("TUM", aNao, 2) )
	For nX := nScan To Len(aSSDados)
		If aSSDados[nX][1] <> dData
			Exit
		EndIf
		aAdd(aDesc, {aSSDados[nX][6], aSSDados[nX][1], aSSDados[nX][2], .F.})
	Next nX

	//--------------------
	// Monta o Dialog
	//--------------------
	DEFINE MSDIALOG oDlgClk TITLE cDlgClk FROM 0,0 TO 300,400 OF oMainWnd PIXEL

		oGetDados := MsNewGetDados():New(0/*nTop*/, 0/*nLeft*/, 10/*nBottom*/, 10/*nRight */, 0/*nStyle*/, ;
											"AllwaysTrue()"/*cLinhaOk*/, "AllwaysTrue()"/*cTudoOk*/, /*cIniCpos*/, /*aAlter*/, /*nFreeze*/, ;
											99/*nMax*/, /*cFieldOk*/, /*cSuperDel*/, /*cDelOk*/, oDlgClk/*oWnd*/, ;
											aHeader/*aPartHeader*/, aDesc/*aParCols*/, /*uChange*/, /*cTela*/)
		oGetDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE MSDIALOG oDlgClk ON INIT EnchoiceBar(oDlgClk, {|| oDlgClk:End() }, {|| oDlgClk:End() }) CENTERED

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fCalChgSet
Executa a Troca do Mês/Ano do Calendário.

@author Wagner Sobral de Lacerda
@since 23/11/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fCalChgSet(cTipo)

	// Variáveis auxiliares
	Local dSetData   := CTOD("")
	Local nX := 0

	//----------
	// Executa
	//----------
	If cTipo == "PREVIOUS"
		For nX := Len(aSSDados) To 1 Step -1
			dSetData := aSSDados[nX][1]
			If Month(dSetData) < Month(dDataAtual) .Or. Year(dSetData) < Year(dDataAtual)
				Exit
			EndIf
		Next nX
	ElseIf cTipo == "NEXT"
		For nX := 1 To Len(aSSDados)
			dSetData := aSSDados[nX][1]
			If Month(dSetData) > Month(dDataAtual) .Or. Year(dSetData) > Year(dDataAtual)
				Exit
			EndIf
		Next nX
	EndIf
	dDataAtual := dSetData
	oSeleAtual:SetText( MesExtenso(dDataAtual) + "/" + cValToChar(Year(dDataAtual)) )

	// Atualiza o Calendário
	fSetCalendar(Month(dDataAtual), Year(dDataAtual))

Return .T.
