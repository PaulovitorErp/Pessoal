#INCLUDE	"Protheus.ch"
#INCLUDE	"NGIND010.ch"
#INCLUDE	"FWBrowse.ch"
#INCLUDE	"FWMVCDEF.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND010
Consulta Gerencial do Histórico de Indicadores.

@author Wagner Sobral de Lacerda
@since 19/09/2012

@return lExecute
/*/
//---------------------------------------------------------------------
Function NGIND010()

	//------------------------------
	// Armazena as variáveis
	//------------------------------
	Local aNGBEGINPRM := NGBEGINPRM()

	Local lExecute := .T. // Variável para identificar se pode ou não executar esta rotina

	//-------------------------------
	// Valida a execução do programa
	//-------------------------------
	lExecute := NGIND007OP()

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
Monta a Tela Principal.

@author Wagner Sobral de Lacerda
@since 20/09/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fMain()

	Local aNGColor := aClone( NGCOLOR() )

	// Variáveis da Tela
	Private oDlg010
	Private cDlg010 := OemToAnsi(STR0001) //"Consulta Gerencial do Histórico de Indicadores"
	Private lDlg010 := .T.

	Private aSize := MsAdvSize(.F.) // .T./.F. - Possui/Não Possui EnchoiceBar

	Private nClrText := aNGColor[1]
	Private nClrBack := aNGColor[2]

	Private oLayer010
	Private oGetWinBrw
	Private oGetWinCon

	Private lConsulta := .F. // Variável que indica se a Consulta está criada (objetos criados e tela inicializada)
	Private lMontando := .F. // Variável que indica se a Consulta está sendo montada

	Private oToolbar // Barra de Ferramentas

	// Variáveis da Window do Browse
	Private oBrwHist

	// Variáveis da Window da Consulta
	Private oGetData
	Private oGetHora
	Private oGetCodInd, oGetNomInd
	Private oGetResNum, oGetResHor
	Private oSayMeta, oSayRexMe, oSayDiff
	Private oGetFormul

	Private oPaiVariav, oWinVariav, aWinVariav := {}, aBtnVariav := {}
	Private oWinCalc
	Private oPaiDados , oWinDados , aWinDados  := {}, aBtnDados  := {}, aBkpDados  := {}
	Private oPaiParams, oWinParams, aWinParams := {}
	Private oPaiRegist, oWinRegist, aBtnRegist := {}
	Private oWinBrwReg, aWinBrwReg := {}, aBkpBrwReg  := {}

	/* Variáveis das Posições dos Arrays principais (Variáveis, Dados, Parâmetros, Registros e Botões) */
	// Variáveis e Botões
	Private nVarVARIAV := 1
	Private nVarNOME   := 2
	Private nVarRESULT := 3

	Private nBVaOBJETO := 1
	Private nBVaESTADO := 2
	Private nBVaVARIAV := 3

	// Dados e Botões
	Private nDadVARIAV := 1
	Private nDadSEQUEN := 2
	Private nDadTABELA := 3
	Private nDadCAMPO  := 4
	Private nDadTITULO := 5
	Private nDadTIPDAD := 6
	Private nDadCONTEU := 7
	Private nDadPICTUR := 8
	Private nDadTAMANH := 9
	Private nDadDECIMA := 10

	Private nBDaOBJETO := 1
	Private nBDaESTADO := 2
	Private nBDaTABELA := 3

	// Parâmetros
	Private nParVARIAV := 1
	Private nParORDEM  := 2
	Private nParCODIGO := 3
	Private nParTITULO := 4
	Private nParTIPDAD := 5
	Private nParCONTEU := 6
	Private nParPICTUR := 7
	Private nParTAMANH := 8
	Private nParDECIMA := 9

	// Registros
	Private nBReOBJETO := 1
	Private nBReESTADO := 2
	Private nBReTABELA := 3
	/**/

	// Fontes
	Private oFntNorm14 := TFont():New(/*cName*/, /*uPar2*/, 14/*nHeight*/, /*uPar4*/, .F./*lBold*/, ;
									/*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, /*lUnderline*/, /*lItalic*/)
	Private oFntBold14 := TFont():New(/*cName*/, /*uPar2*/, 14/*nHeight*/, /*uPar4*/, .T./*lBold*/, ;
									/*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, /*lUnderline*/, /*lItalic*/)
	Private oFntNorm16 := TFont():New(/*cName*/, /*uPar2*/, 16/*nHeight*/, /*uPar4*/, .F./*lBold*/, ;
									/*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, /*lUnderline*/, /*lItalic*/)
	Private oFntBold16 := TFont():New(/*cName*/, /*uPar2*/, 16/*nHeight*/, /*uPar4*/, .T./*lBold*/, ;
									/*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, /*lUnderline*/, /*lItalic*/)

	// Variáveis de estilos de CSS
	Private nCSSVarEsp := 0
	Private nCSSVarSel := 1
	Private nCSSTblEsp := 2
	Private nCSSTblSel := 3
	Private nCSSRegEsp := 4
	Private nCSSRegSel := 5
	Private nCSSTipEsp := 6
	Private nCSSTipSel := 7
	Private nCSSLink   := 8
	Private nCSSCarreg := 9

	// Variáveis de Parâmetros/Perguntas
	Private cPerg := "NGIN10"
	Private nMV_Modo  := 1
	Private lMV_Consu := .F.
	Private lMV_Selec := .F.
	Private nMV_Ident := 1

	// Painel Preto (meio transparente)
	Private oBlackPnl

	fAskSX1()

	//----------
	// Monta
	//----------
	While lDlg010
		lConsulta := .F.

		lDlg010 := .F.
		DEFINE MSDIALOG oDlg010 TITLE cDlg010 FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL

			// FWLayer
			oLayer010 := FWLayer():New()
			oLayer010:Init(oDlg010, .F.)
			fLayout() // Cria o Layout da Tela

			// Cria as visões na tela
			fWinBrowse()
			fWinConsul()

			// Inicializa as teclas de atalho
			SETKEY(VK_F4, {|| fAskSX1(.T.) }) //F4: Parâmetros da Consulta
			SETKEY(VK_F6, {|| fReport() }) //F6: Relatório da Consulta

			// Inicializa o Browse no registro posicionado
		ACTIVATE MSDIALOG oDlg010 ON INIT (Eval(oBrwHist:bChange)) CENTERED
	End

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fLayout
Monta o Layout da Tela Principal.

@author Wagner Sobral de Lacerda
@since 20/09/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fLayout()

	//-- Layout
	If nMV_Modo == 1
		//--------------------
		// Divisão Vertical
		//--------------------

		// Linhas
		oLayer010:AddLine("Linha_Consulta"/*cId*/, 100/*nPercHeight*/, .F./*lFixed*/)

			// Colunas
			oLayer010:AddCollumn("Coluna_Browse"/*cId*/  , 030/*nPercWidth*/, .F./*lFixed*/, "Linha_Consulta"/*cIDLine*/)
			oLayer010:AddCollumn("Coluna_Consulta"/*cId*/, 070/*nPercWidth*/, .F./*lFixed*/, "Linha_Consulta"/*cIDLine*/)

				// Janela do Browse
				oLayer010:AddWindow("Coluna_Browse"/*cIDCollumn*/, "Janela_Browse"/*cIDWindow*/, OemToAnsi(STR0002)/*cTitle*/, 100/*nPercHeight*/, ; //"Histórico"
									.F./*lEnable*/, .F./*lFixed*/, /*bAction*/, "Linha_Consulta"/*cIDLine*/, /*bGotFocus*/)
				// Janela da Consulta
				oLayer010:AddWindow("Coluna_Consulta"/*cIDCollumn*/, "Janela_Consulta"/*cIDWindow*/, OemToAnsi(STR0003)/*cTitle*/, 100/*nPercHeight*/, ; //"Consulta Gerencial"
									.F./*lEnable*/, .F./*lFixed*/, /*bAction*/, "Linha_Consulta"/*cIDLine*/, /*bGotFocus*/)

			// Split entre Colunas
			oLayer010:SetColSplit("Coluna_Browse", CONTROL_ALIGN_RIGHT, "Linha_Consulta", {|| })

		//-- Objetos
		oGetWinBrw := oLayer010:GetWinPanel("Coluna_Browse"/*cIDCollumn*/  , "Janela_Browse"  /*cIDWindow*/, "Linha_Consulta"/*cIDLine*/)
		oGetWinCon := oLayer010:GetWinPanel("Coluna_Consulta"/*cIDCollumn*/, "Janela_Consulta"/*cIDWindow*/, "Linha_Consulta"/*cIDLine*/)
	ElseIf nMV_Modo == 2
		//--------------------
		// Divisão Horizontal
		//--------------------

		// Linhas
		oLayer010:AddLine("Linha_Consulta"/*cId*/, 100/*nPercHeight*/, .F./*lFixed*/)

			// Colunas
			oLayer010:AddCollumn("Coluna_Consulta"/*cId*/, 100/*nPercWidth*/, .F./*lFixed*/, "Linha_Consulta"/*cIDLine*/)

				// Janela do Browse
				oLayer010:AddWindow("Coluna_Consulta"/*cIDCollumn*/, "Janela_Browse"/*cIDWindow*/, OemToAnsi(STR0002)/*cTitle*/, 030/*nPercHeight*/, ; //"Histórico"
									.T./*lEnable*/, .F./*lFixed*/, /*bAction*/, "Linha_Consulta"/*cIDLine*/, /*bGotFocus*/)
				// Janela da Consulta
				oLayer010:AddWindow("Coluna_Consulta"/*cIDCollumn*/, "Janela_Consulta"/*cIDWindow*/, OemToAnsi(STR0003)/*cTitle*/, 070/*nPercHeight*/, ; //"Consulta Gerencial"
									.F./*lEnable*/, .F./*lFixed*/, /*bAction*/, "Linha_Consulta"/*cIDLine*/, /*bGotFocus*/)

		//-- Objetos
		oGetWinBrw := oLayer010:GetWinPanel("Coluna_Consulta"/*cIDCollumn*/, "Janela_Browse"  /*cIDWindow*/, "Linha_Consulta"/*cIDLine*/)
		oGetWinCon := oLayer010:GetWinPanel("Coluna_Consulta"/*cIDCollumn*/, "Janela_Consulta"/*cIDWindow*/, "Linha_Consulta"/*cIDLine*/)
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fBlackPnl
Monta um Painel preto (meio transparente) para cobrir o Dialog.

@author Wagner Sobral de Lacerda
@since 27/09/2012

@param lVisible
	Indica se o Painel deve ser visível * Opcional
	   .T. - Visível
	   .F. - Invisível
	Default: .T.

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fBlackPnl(lVisible)

	Default lVisible := .T.

	If Type("oBlackPnl") <> "O"
		oBlackPnl := TPanel():New(0, 0, , oDlg010, , , , , SetTransparentColor(CLR_BLACK,70), aSize[6], aSize[5], .F., .F.)
		oBlackPnl:Hide()
	EndIf

	If lVisible
		oBlackPnl:Show()
	Else
		oBlackPnl:Hide()
	EndIf

Return .T.

/*/
############################################################################################
##                                                                                        ##
## FUNÇÕES: PARÂMETROS/PERGUNTAS                                                          ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} fAskSX1
Define as perguntas.

@author Wagner Sobral de Lacerda
@since 24/09/2012

@param lPerg
	Indica se deve abrir a tela de perguntas * Opcinoal
	   .T. - Abre a tela de pergunta
	   .F. - Apenas carrega as perguntas
	Default: .F.

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fAskSX1(lPerg)

	// Variáveis auxiliares
	Local nOldModo  := nMV_Modo
	Local nOldIdent := nMV_Ident

	// Defaults
	Default lPerg := .F.

	// Executa a Pergunta
	If lPerg
		// Mostra Painel Preto
		fBlackPnl()
	EndIf
	Pergunte(cPerg, lPerg)
	If lPerg
		// Esconde Painel Preto
		fBlackPnl(.F.)
	EndIf

	nMV_Modo  := ( MV_PAR01 ) // 1=Divisão Vertical ; 2=Divisão Horizontal
	lMV_Consu := ( MV_PAR02 == 1 ) // Sim?
	lMV_Selec := ( MV_PAR03 == 1 ) // Sim?
	nMV_Ident := ( MV_PAR04 ) // 1=Código da Tabela ; 2=Nome da Tabela ; 3=Ambos

	// Se a resposta da pergunta for diferente da anterior, então atualiza
	If lPerg
		If nMV_Modo <> nOldModo
			lDlg010 := .T.
			oDlg010:End()
			Return .T.
		EndIf
		If nMV_Ident <> nOldIdent
			// Atualiza os Dados
			fAtuDados()
		EndIf
	EndIf

Return .T.

/*/
############################################################################################
##                                                                                        ##
## FUNÇÕES: WINDOW DO BROWSE                                                              ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} fWinBrowse
Monta a Window do Browse.

@author Wagner Sobral de Lacerda
@since 20/09/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fWinBrowse()

	// Variáveis do Painel
	Local oPnlPai
	Local oPnlButtons, oBtnVisual
	Local oPnlBrowse

	Local oPnlAux

	Local aNGColor := aClone( NGCOLOR() )

	//----------
	// Monta
	//----------
	//--- Painel Principal
	oPnlPai := TPanel():New(01, 01, , oGetWinBrw, , , , CLR_BLACK, CLR_WHITE, 100, 100)
	oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

		// Painel dos Botões Laterais
		oPnlButtons := TPanel():New(01, 01, , oPnlPai, , , , aNGColor[1], aNGColor[2], 012, 100)
		oPnlButtons:Align := CONTROL_ALIGN_LEFT

			// Panel auxiliar para dar um espaço do topo (alinhando com o browse)
			oPnlAux := TPanel():New(01, 01, , oPnlButtons, , , , aNGColor[1], aNGColor[2], 100, 012)
			oPnlAux:Align := CONTROL_ALIGN_TOP

			// Botão: Visualizar Registro de Histórico
			oBtnVisual := TBtnBmp2():New(01, 01, 030, 030, "ng_ico_visual", , , , {|| fBtnBrw(1) }, oPnlButtons, "")
			oBtnVisual:Align := CONTROL_ALIGN_TOP

		// Painel do Browse
		oPnlBrowse := TPanel():New(01, 01, , oPnlPai, , , , CLR_BLACK, CLR_WHITE, 100, 100)
		oPnlBrowse:Align := CONTROL_ALIGN_ALLCLIENT

			//--------------------
			// Browse do Histórico
			//--------------------
			oBrwHist := fMontaBrowse(@oPnlBrowse, , , "NGIND010_HIST")
			oBrwHist:Refresh()
			oBrwHist:GoTop()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fMontaBrowse
Monta a Window do Browse.

@author Wagner Sobral de Lacerda
@since 20/09/2012

@param oParent
	Objeto Pai do Browse * Obrigatório

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fMontaBrowse(oParent, aMark, aHeader, aHeadClick, cProfID)

	// Salva áreas atuais
	Local aAreaSX3 := SX3->( GetArea() )

	// Variável do Browse
	Local oFWBrowse
	Local aColunas, oColuna
	Local cSetData

	Local oGrid
	Local cGridCSS

	// Variáveis da tela
	Local aScreen := aClone( GetScreenRes() )
	Local nAltura := aScreen[1]
	Local nPixHeight := If(nAltura >= 1000, 25, 20)

	// Variáveis auxiliares
	Local lDefault := .F. // Indica se deve montar o Browse default ou um específico
	Local nHeader := 0
	Local nTamTot := 0
	Local nInd    := 0
	Local aNgHeader := {}

	// Defaults
	Default aMark      := {}
	Default aHeader    := {}
	Default aHeadClick := {}
	Default cProfID    := ""

	//-- Define se é o browse Default
	If Len(aHeader) == 0
		lDefault := .T. // Browse da tabela TZE
	Else
		//-- Definições do 'aHeader'
		// 1      ; 2                ; 3       ; 4       ; 5
		// Título ; Tipo de Conteúdo ; Tamanho ; Picture ; Posição do Array de 'Data' (conteúdo)
	EndIf

	//--------------------
	// Cria Browse
	//--------------------
	// Instancia a Classe
	oFWBrowse := FWBrowse():New(oParent)
	If !Empty(cProfID)
		oFWBrowse:SetProfileID(cProfID)
	EndIf

	If lDefault
		// Definições Básicas do Objeto
		oFWBrowse:SetDataTable()
		oFWBrowse:SetAlias("TZE")
		oFWBrowse:SetInsert(.F.) // Desabilita a Inserção de registros

		// Habilita/Desabilita opções de Salvar, Imprimir, etc.
		oFWBrowse:SetUseFilter() // Habilita a utilização do Filtro de registros
		oFWBrowse:SetLocate() // Habilita a Localização de registros
		oFWBrowse:SetSeek() // Habilita a Pesquisa de registros

		// Define as Colunas
		aColunas := {}

		aNgHeader := NGHeader("TZE")
		nTamTot := Len(aNgHeader)
		For nInd := 1 To nTamTot
			If X3Uso(aNgHeader[nInd,7]) .And. Posicione("SX3",2,aNgHeader[nInd,2],"X3_BROWSE") == "S"
				// Instancia a Classe
				oColuna := FWBrwColumn():New()

				// Definições Básicas do Objeto
				oColuna:SetAlign(If(aNgHeader[nInd,8] == "N", CONTROL_ALIGN_RIGHT, CONTROL_ALIGN_LEFT))
				oColuna:SetEdit(.F.)

				// Definições do Dado apresentado
				oColuna:SetSize(aNgHeader[nInd,4] + aNgHeader[nInd,5])
				oColuna:SetTitle(aNgHeader[nInd,1])
				oColuna:SetType(aNgHeader[nInd,8])
				oColuna:SetPicture(PesqPict(Posicione("SX3",2,aNgHeader[nInd,2],"X3_ARQUIVO"), aNgHeader[nInd,2], ))

				If aNgHeader[nInd,10] == "R" // REAL
					If Empty(Posicione("SX3",2,aNgHeader[nInd,2],"X3_INIBRW"))
						cSetData := AllTrim(Posicione("SX3",2,aNgHeader[nInd,2],"X3_ARQUIVO")) + "->" + AllTrim(aNgHeader[nInd,2])
					Else
						cSetData := "'" + AllTrim(Posicione("SX3",2,aNgHeader[nInd,2],"X3_INIBRW")) + "'"
					EndIf
				ElseIf aNgHeader[nInd,10] == "V" .And. !Empty(Posicione("SX3",2,aNgHeader[nInd,2],"X3_INIBRW")) // VIRTUAL
					cSetData := AllTrim(Posicione("SX3",2,aNgHeader[nInd,2],"X3_INIBRW"))
				Else
					cSetData := "'NULL'"
				EndIf
				cSetData := "{|| " + cSetData + " }" // Transforma em Bloco de Código
				oColuna:SetData(&(cSetData))

				aAdd(aColunas, oColuna)
			EndIf
		Next nInd
		oFWBrowse:SetColumns(aColunas)

		// Define ação na troca de linha (Change)
		oFWBrowse:SetChange({|| fBrwChange() })
	Else
		// Definições Básicas do Objeto
		oFWBrowse:SetDataArray()
		oFWBrowse:SetInsert(.F.) // Desabilita a Inserção de registros

		// Habilita/Desabilita opções de Salvar, Imprimir, etc.
		oFWBrowse:DisableConfig() // Desabilita a Configuração do browse
		oFWBrowse:DisableFilter() // Desabilita o Filtro
		oFWBrowse:DisableLocate() // Desabilita a Localização
		oFWBrowse:DisableReport() // Desabilita o Relatório
		oFWBrowse:DisableSeek() // Desabilita a Pesquisa

		// Colunas de Status
		For nHeader := 1 To Len(aMark)
			oFWBrowse:AddMarkColumns(aMark[nHeader][1]/*bMark*/, aMark[nHeader][2]/*bLDblClick*/, aMark[nHeader][3]/*bHeaderClick*/)
		Next nHeader

		// Define as Colunas
		aColunas := {}
		For nHeader := 1 To Len(aHeader)
			// Instancia a Classe
			oColuna := FWBrwColumn():New()

			// Definições Básicas do Objeto
			oColuna:SetAlign(If(aHeader[nHeader][2] == "N", CONTROL_ALIGN_RIGHT, If(aHeader[nHeader][2] == "X", CONTROL_ALIGN_NONE, CONTROL_ALIGN_LEFT)))
			oColuna:SetEdit(.F.)

			// Definições do Dado apresentado
			oColuna:SetSize(aHeader[nHeader][3])
			oColuna:SetTitle(aHeader[nHeader][1])
			oColuna:SetType(aHeader[nHeader][2])
			oColuna:SetPicture(aHeader[nHeader][4])

			cSetData := "{|oFWBrowse| oFWBrowse:Data():GetArray()[oFWBrowse:AT()][" + cValToChar(aHeader[nHeader][5]) + "] }"
			oColuna:SetData(&(cSetData))

			aAdd(aColunas, oColuna)
		Next nHeader
		oFWBrowse:SetColumns(aColunas)
	EndIf

	// Ativa o Objeto
	oFWBrowse:Activate()
	oFWBrowse:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	If lDefault
		oFWBrowse:SetDoubleClick({|| fBrwChange(.T.) })
	Else
		//--- CSS do Grid
		cGridCSS := "QTableView { "+;
							"background-color: #FFFFFF; "+; // Branco
							"color: #4D4D4D; "+; // Cinza Escuro
							"alternate-background-color: #FAFAFA; "+; // Cinza Claro
							"selection-background-color: #E5F5FF; "+; // Cinza Claro
							"selection-color: #000000; "+; // Preto
							"border: 1px solid #D3D3D3; "+; // Branco
							"font: bold 12px Arial; "+;
						"} "
		cGridCSS += "QHeaderView::Section { "+;
							"background-color: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #FFFFFF, stop:0.3 #F2F2F2, stop:1 #D9D9D9); "+; // Cinza
							"color: #000000; "+; // Preto
							"border: 1px solid #D3D3D3; "+;
							"font: 12px Arial; "+;
							"font-weight: bold; "+;
							"height: " + cValToChar(nPixHeight) + "px; "+;
						" } "

		oGrid := oFWBrowse:Browse()
		oGrid:SetCSS(cGridCSS)
		oGrid:SetHeaderClick({|oGrid, nColumn| fBrwHeaClk(oGrid, nColumn, aHeadClick) })

		oFWBrowse:SetLineHeight(nPixHeight)
		For nHeader := 1 To ( Len(aHeader) + Len(aMark))
			oFWBrowse:SetHeaderImage(nHeader, "") // Limpa a Imagem do Header
		Next nHeader
	EndIf

	// Devolve as Áreas
	RestArea(aAreaSX3)

Return oFWBrowse

//---------------------------------------------------------------------
/*/{Protheus.doc} fBrwHeaClk
Executa o Clique do Header do browse.

@author Wagner Sobral de Lacerda
@since 24/10/2012

@param oGrid
	Objeto do Grid * Obrigatório
@param nColumn
	Coluna do Header acionada * Obrigatório
@param aHeadClick
	Array com as ações dos cliques nas colunas * Obrigatório

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fBrwHeaClk(oGrid, nColumn, aHeadClick)

	// Executa
	If nColumn <= Len(aHeadClick) .And. ValType(aHeadClick[nColumn]) == "B"
		Eval(aHeadClick[nColumn])
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fBrwChange
Executa o Change da linha do browse.

@author Wagner Sobral de Lacerda
@since 20/09/2012

@param lClick
	Indica se a chamada foi feita pelo clique no item * Opcional
	   .T. - Chamada feita pelo clique
	   .F. - Chamada pelo change
	Default: .F.

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fBrwChange(lClick)

	// Variáveis auxiliares
	Local nX := 0

	//----------
	// Executa
	//----------

	// Limpa todos os BackUps quando troca de registro de histórico (TZE)
	aBkpDados := {}
	For nX := 1 To Len(aBkpBrwReg)
		If ValType(aBkpBrwReg[nX][5]) == "O"
			aBkpBrwReg[nX][6]:DeActivate()
			aBkpBrwReg[nX][5]:FreeChildren()
			MsFreeObj(aBkpBrwReg[nX][5])
		EndIf
	Next nX
	aBkpBrwReg := {}

	// Atualiza a Consulta
	If lConsulta
		// Se puder processar Automaticamente OU for uma chamada pelo Duplo Clique no browse, atualiza a consulta
		If lMV_Consu .Or. lClick
			// Mostra Painel Preto
			fBlackPnl()

			// Monta a Consulta
			lMontando := .T.
			MsgRun(STR0021, STR0022, {|| fAtuConsul() }) //"Montando a Consulta..." ## "Por favor, aguarde..."
			lMontando := .F.

			// Esconde Painel Preto
			fBlackPnl(.F.)
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fBtnBrw
Executa um Botão do Browse do Histórico.

@author Wagner Sobral de Lacerda
@since 19/10/2012

@param nButton
	Indica qual é o botão a executar:
	   1 - Visualização do Registro de Histórico

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fBtnBrw(nButton)

	// Salva as áreas atuais
	Local aAreaOld := GetArea()
	Local aAreaTZE := TZE->( GetArea() )

	// Mostra Painel Preto
	fBlackPnl()

	//----------
	// Executa
	//----------
	If nButton == 1 // Visualização do Registro de Histórico
		// Declara as Variáveis PRIVATE
		NGIND009VR()

		dbSelectArea("TZE")
		//--- Executa a View
		FWExecView(/*cTitulo*/, "NGIND009"/*cPrograma*/, MODEL_OPERATION_VIEW/*nOperation*/, /*oDlg*/, /*bCloseOnOk*/, ;
					/*bOk*/, /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/)
	EndIf

	// Esconde Painel Preto
	fBlackPnl(.F.)

	// Devolve as áreas
	RestArea(aAreaTZE)
	RestArea(aAreaOld)

Return .T.

/*/
############################################################################################
##                                                                                        ##
## FUNÇÕES: WINDOW DA CONSULTA                                                            ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} fWinConsul
Monta a Window da Consulta.

@author Wagner Sobral de Lacerda
@since 20/09/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fWinConsul()

	// Salva áreas atuais
	Local aAreaSX3 := SX3->( GetArea() )

	// Variáveis do Painel
	Local oPnlPai
	Local oPnlCabec
	Local oPnlCalc
	Local oPnlConsu, oPnlCon02
	Local oTitulo
	Local oSepBarra, oSepCabCon, oSepVarCab, oSepParDad, oSepDadReg, nSeparaT := 002
	Local oTmpPnl, oTmpBtn, oTmpSep

	// Variáveis auxiliares
	Local cPictNum := PesqPict("TZE", "TZE_RESULT", )
	Local cPictHor := ""

	Local nFldRESULT := 0

	Local cImgMinimi := "fwstd_lyr_minimize"
	Local cImgReload := "fwstd_lyr_restore"

	//-- Calcula tamanho de campos
	dbSelectArea("SX3")
	dbSetOrder(2)
	dbSeek("TZE_RESULT")
	nFldRESULT := CalcFieldSize( AllTrim(Posicione("SX3",2,"TZE_RESULT","X3_TIPO")),;
					TAMSX3("TZE_RESULT")[1], Posicione("SX3",2,"TZE_RESULT","X3_DECIMAL"),;
					AllTrim(Posicione("SX3",2,"TZE_RESULT","X3_PICTURE")), X3Titulo() )
	//----------
	// Monta
	//----------
	//--- Painel Principal
	oPnlPai := TPanel():New(01, 01, , oGetWinCon, , , , CLR_BLACK, CLR_WHITE, 100, 100)
	oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

		// Separador entre o Cabeçalho e a Consulta em si
		oSepCabCon := TSplitter():New(01, 01, oPnlPai, 10, 10)
		oSepCabCon:SetOrient(1) // Barra Horizontal
		oSepCabCon:Align := CONTROL_ALIGN_ALLCLIENT

			// Separador entre cabeçalho e Parâmetros
			oSepCabPar := TSplitter():New(01, 01, oSepCabCon, 100, 120)
			oSepCabPar:SetOrient(0) // Barra Vertical
			oSepCabPar:Align := CONTROL_ALIGN_TOP

				//--------------------
				// Cabeçalho
				//--------------------
				// Painel do Cabeçalho
				oPnlCabec := TPanel():New(01, 01, , oSepCabPar, , , , nClrText, nClrBack, 250, 120)
				oPnlCabec:Align := CONTROL_ALIGN_LEFT

					//--------------------
					// Informações
					//--------------------

					//-- Indicador --
					TSay():New(005, 010, {|| AllTrim(RetTitle("TZE_INDIC")) + ":" }, oPnlCabec, , oFntBold16, , ;
												, , .T., nClrText, nClrBack, 100, 015)
					oGetCodInd := TGet():New(004, 045, {|| TZE->TZE_INDIC }, oPnlCabec, 050, 008, PesqPict("TZE", "TZE_INDIC", ), {|| .T. }, nClrText, nClrBack, oFntBold16,;
									.F., , .T./*lPixel*/, , .F., {|| .T. }/*bWhen*/, .F., .F., , .T./*lReadOnly*/, .F., "", "", , , , .T./*lHasButton*/)
					oGetCodInd:bHelp := &("{|| ShowHelpCpo('TZE_INDIC', {'" + GetHlpSoluc("TZE_INDIC")[1] + "'},2, {},2)}")
					oGetNomInd := TGet():New(004, 95, {|| Posicione("TZ5", 1, TZE->TZE_FILIAL+TZE->TZE_MODULO+TZE->TZE_INDIC, "TZ5_NOME") }, oPnlCabec, 120, 008, PesqPict("TZE", "TZE_NOMFOR", ), {|| .T. }, nClrText, nClrBack, oFntNorm16,;
									.F., , .T./*lPixel*/, , .F., {|| .T. }/*bWhen*/, .F., .F., , .T./*lReadOnly*/, .F., "", "", , , , .T./*lHasButton*/)
					oGetNomInd:bHelp := &("{|| ShowHelpCpo('TZE_NOMFOR', {'" + GetHlpSoluc("TZE_NOMFOR")[1] + "'},2, {},2)}")

					//-- Data --
					TSay():New(020, 010, {|| AllTrim(RetTitle("TZE_DATA")) + ":" }, oPnlCabec, , oFntBold16, , ;
												, , .T., nClrText, nClrBack, 100, 015)
					oGetData := TGet():New(019, 045, {|| TZE->TZE_DATA }, oPnlCabec, 050, 008, "99/99/99", {|| .T. }, nClrText, nClrBack, oFntBold16,;
					 				.F., , .T./*lPixel*/, , .F., {|| .T. }/*bWhen*/, .F., .F., , .T./*lReadOnly*/, .F., "", "", , , , .T./*lHasButton*/)
					oGetData:bHelp := &("{|| ShowHelpCpo('TZE_DATA', {'" + GetHlpSoluc("TZE_DATA")[1] + "'},2, {},2)}")

					//-- Hora --
					TSay():New(020, 140, {|| AllTrim(RetTitle("TZE_HORA")) + ":" }, oPnlCabec, , oFntBold16, , ;
												, , .T., nClrText, nClrBack, 100, 015)
					oGetHora := TGet():New(019, 160, {|| TZE->TZE_HORA }, oPnlCabec, 040, 008, "99:99", {|| .T. }, nClrText, nClrBack, oFntBold16,;
					 				.F., , .T./*lPixel*/, , .F., {|| .T. }/*bWhen*/, .F., .F., , .T./*lReadOnly*/, .F., "", "", , , , .T./*lHasButton*/)
					oGetHora:bHelp := &("{|| ShowHelpCpo('TZE_HORA', {'" + GetHlpSoluc("TZE_HORA")[1] + "'},2, {},2)}")

					//-- Resultado --
					TSay():New(035, 010, {|| AllTrim(RetTitle("TZE_RESULT")) + ":" }, oPnlCabec, , oFntBold16, , ;
												, , .T., nClrText, nClrBack, 100, 015)
					// Numérico
					oGetResNum := TGet():New(034, 045, {|| 0 }, oPnlCabec, nFldRESULT, 008, cPictNum, {|| .T. }, nClrText, nClrBack, oFntBold16,;
									.F., , .T./*lPixel*/, , .F., {|| .T. }/*bWhen*/, .F., .F., , .T./*lReadOnly*/, .F., "", "", , , , .T./*lHasButton*/)
					oGetResNum:bHelp := &("{|| ShowHelpCpo('TZE_RESULT', {'" + GetHlpSoluc("TZE_RESULT")[1] + "'},2, {},2)}")
					oGetResNum:Hide()
					// Hora
					oGetResHor := TGet():New(034, 075, {|| "00:00" }, oPnlCabec, nFldRESULT, 008, cPictHor, {|| .T. }, nClrText, nClrBack, oFntBold16,;
									.F., , .T./*lPixel*/, , .F., {|| .T. }/*bWhen*/, .F., .F., , .T./*lReadOnly*/, .F., "", "", , , , .T./*lHasButton*/)
					oGetResHor:bHelp := &("{|| ShowHelpCpo('TZE_RESULT', {'" + GetHlpSoluc("TZE_RESULT")[1] + "'},2, {},2)}")
					oGetResHor:Hide()

					//-- Meta --
					TSay():New(035, 140, {|| AllTrim(RetTitle("TZE_META")) + ":" }, oPnlCabec, , oFntBold16, , ;
												, , .T., nClrText, nClrBack, 100, 015)
					oSayRexMe := TSay():New(035, 160, {|| "" }, oPnlCabec, , oFntBold16, , ;
												, , .T., nClrText, nClrBack, 100, 015)
					oSayMeta := TSay():New(035, 200, {|| "" }, oPnlCabec, , oFntNorm16, , ;
												, , .T., nClrText, nClrBack, 150, 015)
					oSayDiff := TSay():New(045, 160, {|| "" }, oPnlCabec, , oFntNorm14, , ;
												, , .T., nClrText, nClrBack, 100, 015)

					//-- Fórmula --
					TSay():New(050, 010, {|| AllTrim(RetTitle("TZE_FORMUL")) + ":" }, oPnlCabec, , oFntBold16, , ;
												, , .T., nClrText, nClrBack, 100, 015)
					oGetFormul := TMultiGet():New(049/*nRow*/, 045/*nCol*/, {|| AllTrim(TZE->TZE_FORMUL) }/*bSetGet*/, oPnlCabec/*oWnd*/, ;
									165/*nWidth*/, 030/*nHeight*/, oFntBold14/*oFont*/, .F./*lHScroll*/, /*uParam9*/, /*uParam10*/, ;
									/*uParam11*/, .T./*lPixel*/, /*uParam13*/, /*uParam14*/, /*bWhen*/, /*uParam16*/, /*uParam17*/, ;
									.T./*lReadOnly*/, /*bValid*/, /*uParam20*/, /*uParam21*/, /*lNoBorder*/, .T./*lVScroll*/, ;
									/*cLabelText*/ ,/*nLabelPos*/, /*oLabelFont*/, /*nLabelColor*/)
					oGetFormul:bHelp := &("{|| ShowHelpCpo('TZE_FORMUL', {'" + GetHlpSoluc("TZE_FORMUL")[1] + "'},2, {},2)}")

					//--------------------
					// Parâmetros
					//--------------------
					oPaiParams := TPanel():New(01, 01, , oSepCabPar, , , , CLR_BLACK, CLR_WHITE, 100, 100)
					oPaiParams:Align := CONTROL_ALIGN_ALLCLIENT

						// Título
						oTitulo := TPanel():New(01, 01, STR0029, oPaiParams, oFntBold14, .T., , nClrText, nClrBack, 100, 012) //"Parâmetros"
						oTitulo:Align := CONTROL_ALIGN_TOP

							// Botão: Redimensionar
							oTmpBtn := TBtnBmp2():New(001, 001, 30, 30, cImgReload, , , , {|| fExecReload(1) }, oTitulo, OemToAnsi(STR0031)) //"Redimensionar"
							oTmpBtn:lCanGotFocus := .F.
							oTmpBtn:Align := CONTROL_ALIGN_RIGHT

						// Painel PRINCIPAL de Parâmetros
						oWinParams := TPanel():New(01, 01, , oPaiParams, , , , CLR_BLACK, CLR_WHITE, 100, 100)
						oWinParams:Align := CONTROL_ALIGN_ALLCLIENT

						// Separador (Esquerda)
						oTmpSep := TPanel():New(01, 01, , oPaiParams, , , , nClrBack, nClrBack, 002, 002)
						oTmpSep:Align := CONTROL_ALIGN_LEFT

						// Separador (abaixo)
						oTmpSep := TPanel():New(01, 01, , oPaiParams, , , , nClrBack, nClrBack, 002, 002)
						oTmpSep:Align := CONTROL_ALIGN_BOTTOM

			//--------------------
			// Consulta
			//--------------------
			// Painel da Consulta
			oPnlConsu := TPanel():New(01, 01, , oSepCabCon, , , , CLR_BLACK, CLR_WHITE, 100, 100)
			oPnlConsu:Align := CONTROL_ALIGN_ALLCLIENT

				// Painel auxiliar do Painel da Consulta
				oPnlCon02 := TPanel():New(01, 01, , oPnlConsu, , , , CLR_BLACK, CLR_WHITE, 100, 100)
				oPnlCon02:Align := CONTROL_ALIGN_ALLCLIENT

					// Barra de Ferramentas
					oToolbar := TPanel():New(01, 01, , oPnlCon02, , , , nClrText, nClrBack, 100, 015)
					oToolbar:Align := CONTROL_ALIGN_BOTTOM

							// Separador
							oTmpSep := TPanel():New(01, 01, , oToolbar, , , , nClrBack, nClrBack, 002, 002)
							oTmpSep:Align := CONTROL_ALIGN_LEFT

						// Botão: Parâmetros
						oTmpBtn := TBtnBmp2():New(001, 001, 30, 30, "poscli", , , , {|| fAskSX1(.T.) }, oToolbar, OemToAnsi(STR0025)) //"Parâmetros Consulta Gerencial (tecla de atalho: F4)"
						oTmpBtn:lCanGotFocus := .F.
						oTmpBtn:Align := CONTROL_ALIGN_LEFT

							// Separador
							oTmpSep := TPanel():New(01, 01, , oToolbar, , , , nClrBack, nClrBack, 002, 002)
							oTmpSep:Align := CONTROL_ALIGN_LEFT

						// Botão: Gráfico Evolutivo
						oTmpBtn := TBtnBmp2():New(001, 001, 30, 30, "graf3d", , , , {|| NGIND013(TZE->TZE_FILIAL, TZE->TZE_INDIC) }, oToolbar, OemToAnsi(STR0026)) //"Gráfico Evolutivo do Indicador"
						oTmpBtn:lCanGotFocus := .F.
						oTmpBtn:Align := CONTROL_ALIGN_LEFT

							// Separador
							oTmpSep := TPanel():New(01, 01, , oToolbar, , , , nClrBack, nClrBack, 002, 002)
							oTmpSep:Align := CONTROL_ALIGN_LEFT

						// Botão: Imprimir
						oTmpBtn := TBtnBmp2():New(001, 001, 30, 30, "impressao", , , , {|| fReport() }, oToolbar, OemToAnsi(STR0027)) //"Imprimir a Consulta Gerencial (tecla de atalho: F6)"
						oTmpBtn:lCanGotFocus := .F.
						oTmpBtn:Align := CONTROL_ALIGN_LEFT

							// Separador
							oTmpSep := TPanel():New(01, 01, , oToolbar, , , , nClrBack, nClrBack, 002, 002)
							oTmpSep:Align := CONTROL_ALIGN_RIGHT

						// Botão: Sair
						oTmpBtn := TBtnBmp2():New(001, 001, 30, 30, "ng_ico_final", , , , {|| oDlg010:End() }, oToolbar, OemToAnsi("Sair")) //"Sair"
						oTmpBtn:lCanGotFocus := .F.
						oTmpBtn:Align := CONTROL_ALIGN_LEFT

							// Separador
							oTmpSep := TPanel():New(01, 01, , oToolbar, , , , nClrBack, nClrBack, 002, 002)
							oTmpSep:Align := CONTROL_ALIGN_RIGHT

					// Separador entre a Barra de Ferramentas e o resto da Consulta
					oSepBarra := TBtnBmp2():New(01, 01, 01, 010, "", , , , {|| fExecSplit(0, oSepBarra) }, oPnlCon02, "")
					oSepBarra:Align := CONTROL_ALIGN_BOTTOM
					// Inicia o Painel escondido e executa o split, para já mostrar o Painel e carregar o bitmap
					oToolbar:Hide()
					oSepBarra:Click()
					// Painel auxiliar para destacar o separador (acima)
					oTmpPnl := TPanel():New(01, 01, , oPnlCon02, , , , nClrText, nClrBack, 100, nSeparaT)
					oTmpPnl:Align := CONTROL_ALIGN_BOTTOM

							// Painel Temporário para ser um Container
							oPaiRegist := TPanel():New(01, 01, , oPnlCon02, , , , CLR_BLACK, CLR_WHITE, 100, 040)
							oPaiRegist:Align := CONTROL_ALIGN_ALLCLIENT

								// Título
								oTitulo := TPanel():New(01, 01, STR0033, oPaiRegist, oFntBold14, .T., , nClrText, nClrBack, 100, 012) //"Registros das Tabelas"
								oTitulo:Align := CONTROL_ALIGN_TOP

								// Painel de Registros de Variáveis x Tabelas
								oWinRegist := TPanel():New(01, 01, , oPaiRegist, , , , CLR_BLACK, CLR_WHITE, 100, 027)
								oWinRegist:Align := CONTROL_ALIGN_TOP

								// Painel do Browse de Registros de Variáveis x Tabelas
								oWinBrwReg := TPanel():New(01, 01, , oPaiRegist, , , , CLR_BLACK, CLR_WHITE, 100, 100)
								oWinBrwReg:Align := CONTROL_ALIGN_ALLCLIENT
								oWinBrwReg:Hide() // Inicia escondido

						// Define se PODE OU NÃO fechar completamentos os objeto do Splitter
						oSepCabPar:SetCollapse(oPaiParams, .F.)

	// Indica que a Consulta está criada
	lConsulta := .T.

	// Devolve as Áreas
	RestArea(aAreaSX3)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fPnlParams
Monta o Painel de Parãmetros.

@author Wagner Sobral de Lacerda
@since 21/09/2012

@param oParent
	Objeto Pai do Browse * Obrigatório

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fPnlParams(oParent)

	// Variáveis Auxiliares
	Local oPnlPai
	Local oScroll

	Local aGetParams := fGetParams()
	Local aAuxPars := {}
	Local nVar := 0, nPar := 0

	Local cSay     := ""
	Local cSetGet  := ""
	Local cPicture := ""
	Local nSize    := 0

	Local nWidthPai   := 0
	Local nWidthGroup := 250
	Local nGrpPorLin  := 0, nGrpLinAtu := 0

	Local nLinIni := 0, nColIni := 0
	Local nLinAtu := 0, nColAtu := 0
	Local nMaxLin := 0

	//----------
	// Monta
	//----------
	// Painel Pai
	oPnlPai := TPanel():New(01, 01, , oParent, , , , CLR_BLACK, CLR_WHITE, 100, 100)
	oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT
	oPnlPai:CoorsUpdate()
	nWidthPai := ( oPnlPai:nClientWidth * 0.50 ) // Largura do Pai
	nGrpPorLin := Int( nWidthPai / nWidthGroup ) // Quantidade de Grupos (Variáveis) por Linha
	nGrpPorLin := If(nGrpPorLin > 0, nGrpPorLin, 1) // No mínimo 1

		// Scroll dos Parâmetros
		oScroll := TScrollBox():New(oPnlPai, 0, 0, 0, 0, .T., .T., .F.)
		oScroll:Align := CONTROL_ALIGN_ALLCLIENT
		oScroll:CoorsUpdate()

			// Monta os parâmetros
			nLinIni := 010
			nColIni := 005
			nLinAtu := nLinIni
			nColAtu := nColIni
			If Len(aGetParams) == 0
				TSay():New(nLinIni, nColIni, {|| STR0035 }, oScroll, , , , ; //"Não há Parâmetros para exibir."
								, , .T., CLR_BLACK, CLR_WHITE, 100, 015)
			Else
				// Variáveis
				nGrpLinAtu := 0
				For nVar := 1 To Len(aGetParams)

					// Quantidade de variáveis na mesma linha
					nGrpLinAtu++
					If nGrpLinAtu > nGrpPorLin
						nGrpLinAtu := 0
						// Recebe a última linha
						If nMaxLin > nLinAtu
							nLinAtu := nMaxLin
						EndIf
						// Incrementa a linha
						nLinAtu += 15

						nLinIni := nLinAtu
						nColIni := 005
					Else
						nLinAtu := nLinIni
						nColIni := nColAtu + If(nGrpLinAtu > 1, nWidthGroup + 010, 0)
						nColAtu := nColIni
					EndIf

					// SAY da Variável
					cSay := "{|| '" + aGetParams[nVar][1] + " - " + aGetParams[nVar][2] + "' }"
					TSay():New(nLinAtu, nColAtu, &(cSay), oScroll, , oFntBold14, , ;
								, , .T., CLR_BLACK, CLR_WHITE, 250, 015)

					// Incrementa a linha
					nLinAtu += 10

					// Parâmetros da Variável
					nLinAtu += 005
					nColAtu += 005
					aAuxPars := aClone(aGetParams[nVar][3])
					For nPar := 1 To Len(aAuxPars)
						// SAY do Parâmetro
						cSay := "{|| '" + aAuxPars[nPar][3] + "' }"
						TSay():New(nLinAtu, nColAtu, &(cSay), oScroll, , , , ;
									, , .T., CLR_BLACK, CLR_WHITE, 100, 015)

						// GET do Parâmetro
						cSetGet  := "{|| '" + NGI6CONVER(aAuxPars[nPar][5],"C",aAuxPars[nPar][7],aAuxPars[nPar][8],.T.) + "' }"
						cPicture := "'" + AllTrim(aAuxPars[nPar][6]) + "'"
						nSize    := CalcFieldSize( aAuxPars[nPar][4], aAuxPars[nPar][7], aAuxPars[nPar][8], aAuxPars[nPar][6], aAuxPars[nPar][3] )
						TGet():New(nLinAtu-001, nColAtu+085, &(cSetGet), oScroll, nSize, 008, &(cPicture), {|| .T. }, CLR_BLACK, CLR_WHITE, ,;
										.F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "", , , , .T./*lHasButton*/)

						// Incrementa a linha
						nLinAtu += 15
					Next nPar

					// Coluna inicial
					nColAtu := nColIni
					// Monta um GroupBox para "separar" as variáveis
					TGroup():New(nLinIni+010, nColAtu, nLinAtu, nColAtu+nWidthGroup, , oScroll, , , .T.)

					// Recebe a maior Linha onde os parâmetros foram montados
					If nLinAtu > nMaxLin
						nMaxLin := nLinAtu
					EndIf

				Next nVar
			EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetParams
Recebe um Array com os Parâmetros do Histórico.

@author Wagner Sobral de Lacerda
@since 21/09/2012

@return aParams
/*/
//---------------------------------------------------------------------
Static Function fGetParams()

	// Variável do Retorno
	Local aParams := {}

	// Variáveis auxiliares
	Local nBtn := 0, nAdd := 0, nPar := 0
	Local nScanVar := 0, nScanPar := 0

	//----------
	// Executa
	//----------
	For nBtn := 1 To Len(aBtnVariav)
		// Apenas considera os parâmetros dos Botões Selecionados
		If aBtnVariav[nBtn][nBVaESTADO]

			// Busca de acordo com a Variável selecionada
			nScanVar := aScan(aWinVariav, {|x| x[nVarVARIAV] == aBtnVariav[nBtn][nBVaVARIAV] })
			nScanPar := aScan(aWinParams, {|x| x[nParVARIAV] == aBtnVariav[nBtn][nBVaVARIAV] })
			If nScanVar > 0 .And. nScanPar > 0
				For nPar := nScanPar To Len(aWinParams)
					// Apenas enquanto for a mesma Variável
					If aWinParams[nPar][nParVARIAV] <> aBtnVariav[nBtn][nBVaVARIAV]
						Exit
					EndIf

					// Adiciona
					nAdd := aScan(aParams, {|x| AllTrim(x[1]) == AllTrim(aBtnVariav[nBtn][nBVaVARIAV]) })
					If nAdd == 0
						aAdd(aParams, {AllTrim(aBtnVariav[nBtn][nBVaVARIAV]), AllTrim(aWinVariav[nScanVar][nVarNOME]), {}})
						nAdd := Len(aParams)
					EndIf

					// Armazena no Array
					aAdd(aParams[nAdd][3], {	aWinParams[nPar][nParORDEM] , ; // [1] - Sequência
												aWinParams[nPar][nParCODIGO], ; // [2] - Código do Parâmetro
												aWinParams[nPar][nParTITULO], ; // [3] - Título
												aWinParams[nPar][nParTIPDAD], ; // [4] - Tipo de Dado
												aWinParams[nPar][nParCONTEU], ; // [5] - Conteúdo
												aWinParams[nPar][nParPICTUR], ; // [6] - Picture
												aWinParams[nPar][nParTAMANH], ; // [7] - Tamanho
												aWinParams[nPar][nParDECIMA]}) // [8] - Decimal
				Next nPar
			EndIf

		EndIf
	Next

Return aParams

//---------------------------------------------------------------------
/*/{Protheus.doc} fPnlDados
Monta o Painel de Dados.

@author Wagner Sobral de Lacerda
@since 21/09/2012

@param oParent
	Objeto Pai do Browse * Obrigatório

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fPnlDados(oParent)

	// Variáveis Auxiliares
	Local oPnlPai
	Local oScroll

	Local aGetDados := fGetDados()
	Local aAuxDads := {}
	Local nVar := 0, nDad := 0
	Local lBackUp := .F.

	Local cTitulo  := ""
	Local cAction  := ""
	Local cHint    := ""

	Local nWidthPai   := 0
	Local nWidthGroup := 240
	Local nGrpPorLin  := 0, nGrpLinAtu := 0
	Local nWidthTbl   := 0, nHeightTbl := 0, nSpaceTbl := 0
	Local nTblPorLin  := 0, nTblLinAtu := 0

	Local nLinIni := 0, nColIni := 0
	Local nLinAtu := 0, nColAtu := 0
	Local nMaxLin := 0

	//-- Definições específicas dos Dados (Tabelas)
	If nMV_Ident == 1 // Código da Tabela
		nWidthTbl  := 030
	ElseIf nMV_Ident == 2 // Nome da Tabela
		nWidthTbl  := 110
	ElseIf nMV_Ident == 3 // Ambos
		nWidthTbl  := 110
	EndIf
	nHeightTbl := 025
	nSpaceTbl  := 010

	//----------
	// Monta
	//----------
	// Painel Pai
	oPnlPai := TPanel():New(01, 01, , oParent, , , , CLR_BLACK, CLR_WHITE, 100, 100)
	oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT
	oPnlPai:CoorsUpdate()
	nWidthPai := ( oPnlPai:nClientWidth * 0.50 ) // Largura do Pai
	nGrpPorLin := Int( nWidthPai / nWidthGroup ) // Quantidade de Grupos (Variáveis) por Linha
	nGrpPorLin := If(nGrpPorLin > 0, nGrpPorLin, 1) // No mínimo 1
	nTblPorLin := Int( nWidthGroup / (nWidthTbl+nSpaceTbl) ) // Quantidade de Tabelas por Linha
	nTblPorLin := If(nTblPorLin > 0, nTblPorLin, 1) // No mínimo 1

		// Scroll dos Parâmetros
		oScroll := TScrollBox():New(oPnlPai, 0, 0, 0, 0, .T., .T., .F.)
		oScroll:Align := CONTROL_ALIGN_ALLCLIENT
		oScroll:CoorsUpdate()

			// Monta os Dados (tabelas)
			aBtnDados := {}

			nLinIni := 010
			nColIni := 005
			nLinAtu := nLinIni
			nColAtu := nColIni
			If Len(aGetDados) == 0
				TSay():New(nLinIni, nColIni, {|| STR0036 }, oScroll, , , , ; //"Não há Tabelas para exibir."
								, , .T., CLR_BLACK, CLR_WHITE, 100, 015)
			Else
				// Variáveis
				nGrpLinAtu := 0
				For nVar := 1 To Len(aGetDados)

					// Quantidade de variáveis na mesma linha
					nGrpLinAtu++
					If nGrpLinAtu > nGrpPorLin
						nGrpLinAtu := 0
						// Recebe a última linha
						If nMaxLin > nLinAtu
							nLinAtu := nMaxLin
						EndIf
						// Incrementa a linha
						nLinAtu += 10

						nLinIni := nLinAtu
						nColIni := 005
					Else
						nLinAtu := nLinIni
						nColIni := nColAtu + If(nGrpLinAtu > 1, nWidthGroup + 010, 0)
						nColAtu := nColIni
					EndIf

					// SAY da Variável
					cSay := "{|| '" + aGetDados[nVar][1] + " - " + aGetDados[nVar][2] + "' }"
					TSay():New(nLinAtu, nColAtu, &(cSay), oScroll, , oFntBold14, , ;
								, , .T., CLR_BLACK, CLR_WHITE, 250, 015)
					// Prepara Botão
					aAdd(aBtnDados, {aGetDados[nVar][1], {}}) // 1=Código da Variável ; 2=Objetos de Botões

					// Incrementa a linha
					nLinAtu += 10

					// Parâmetros da Variável
					nLinAtu += 005
					nColAtu += 005
					nTblLinAtu := 0
					aAuxDads := aClone(aGetDados[nVar][3])
					For nDad := 1 To Len(aAuxDads)

						// Botão
						aAdd(aBtnDados[nVar][2], Array(3)) // 1=Objeto do Botão ; 2=Estado do Botão ; 3=Código da Tabela

						// Quantidade de tabelas na mesma linha
						nTblLinAtu++
						If nTblLinAtu > nTblPorLin
							nTblLinAtu := 1
							nColAtu := ( nColIni + 005 )
							// Incrementa a linha
							nLinAtu += ( nHeightTbl + nSpaceTbl )
						ElseIf nTblLinAtu > 1
							nColAtu += ( nWidthTbl + nSpaceTbl )
						EndIf

						// BUTTON da Tabela
						If nMV_Ident == 1 // Código da Tabela
							cTitulo := "'" + AllTrim(aAuxDads[nDad][1]) + "'"
							cHint   := "'" + AllTrim(aAuxDads[nDad][2]) + "'"
						ElseIf nMV_Ident == 2 // Nome da Tabela
							cTitulo := "'" + AllTrim(aAuxDads[nDad][2]) + "'"
							cHint   := "'" + AllTrim(aAuxDads[nDad][1]) + "'"
						ElseIf nMV_Ident == 3 // Ambos
							cTitulo := "'" + AllTrim(aAuxDads[nDad][1]) + " (" + AllTrim(aAuxDads[nDad][2]) + ")'"
							cHint   := cTitulo
						EndIf
						cAction := "{|| fSelectTbl('" + aGetDados[nVar][1] + "', '" + aAuxDads[nDad][1] + "') }"
						aBtnDados[nVar][2][nDad][nBDaOBJETO] := TButton():New(nLinAtu, nColAtu, &(cTitulo), oScroll, &(cAction),;
								  										nWidthTbl, nHeightTbl, , , .F., .T., .F., , .F., , , .F.)
						aBtnDados[nVar][2][nDad][nBDaOBJETO]:lCanGotFocus := .F.
						aBtnDados[nVar][2][nDad][nBDaOBJETO]:cTooltip := &(cHint)
						aBtnDados[nVar][2][nDad][nBDaTABELA] := aAuxDads[nDad][1]
						// CSS do Botão "Tabela em Espera" ou "Tabela Selecionada"
						lBackUp := ( aScan(aBkpDados, {|x| AllTrim(x[1]) == AllTrim(aGetDados[nVar][1]) .And. AllTrim(x[2]) == AllTrim(aAuxDads[nDad][1]) }) > 0 )
						fSetCSS(If(lBackUp,nCSSTblSel,nCSSTblEsp), aBtnDados[nVar][2][nDad][nBVaOBJETO])
						aBtnDados[nVar][2][nDad][nBDaESTADO] := lBackUp

					Next nDad
					// Incrementa a linha
					nLinAtu += ( nHeightTbl + (nSpaceTbl/2) )

					// Coluna inicial
					nColAtu := nColIni
					// Monta um GroupBox para "separar" as variáveis
					TGroup():New(nLinIni+010, nColAtu, nLinAtu, nColAtu+nWidthGroup, , oScroll, , , .T.)

					// Recebe a maior Linha onde os parâmetros foram montados
					If nLinAtu > nMaxLin
						nMaxLin := nLinAtu
					EndIf

				Next nVar
			EndIf

	// Inicializa as tabelas selecionadas
	If !IsInCallStack(Upper("fExecReload"))
		fSelectTbl(If(lMV_Selec .And. lMontando,"ALL",Nil), If(lMV_Selec .And. lMontando,"ALL",Nil))
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetDados
Recebe um Array com os Parâmetros do Histórico.

@author Wagner Sobral de Lacerda
@since 21/09/2012

@return aDados
/*/
//---------------------------------------------------------------------
Static Function fGetDados()

	// Variável do Retorno
	Local aDados := {}

	// Variáveis auxiliares
	Local nBtn := 0, nAdd := 0, nDad := 0
	Local nScanVar := 0, nScanDad := 0

	//----------
	// Executa
	//----------
	For nBtn := 1 To Len(aBtnVariav)
		// Apenas considera os parâmetros dos Botões Selecionados
		If aBtnVariav[nBtn][nBVaESTADO]

			// Busca de acordo com a Variável selecionada
			nScanVar := aScan(aWinVariav, {|x| x[nVarVARIAV] == aBtnVariav[nBtn][nBVaVARIAV] })
			nScanDad := aScan(aWinDados , {|x| x[nDadVARIAV] == aBtnVariav[nBtn][nBVaVARIAV] })
			If nScanVar > 0 .And. nScanDad > 0
				For nDad := nScanDad To Len(aWinDados)
					// Apenas enquanto for a mesma Variável
					If aWinDados[nDad][nDadVARIAV] <> aBtnVariav[nBtn][nBVaVARIAV]
						Exit
					EndIf

					// Adiciona
					nAdd := aScan(aDados, {|x| AllTrim(x[1]) == AllTrim(aBtnVariav[nBtn][nBVaVARIAV]) })
					If nAdd == 0
						aAdd(aDados, {AllTrim(aBtnVariav[nBtn][nBVaVARIAV]), AllTrim(aWinVariav[nScanVar][nVarNOME]), {}})
						nAdd := Len(aDados)
					EndIf

					// Armazena no Array
					If aScan(aDados[nAdd][3], {|x| x[1] == aWinDados[nDad][nDadTABELA] }) == 0
						aAdd(aDados[nAdd][3], {	aWinDados[nDad][nDadTABELA], ; // [1] - Tabela
												FWX2Nome(aWinDados[nDad][nDadTABELA])}) // [2] - Nome da Tabela
					EndIf
				Next nVar
			EndIf

		EndIf
	Next

Return aDados

//---------------------------------------------------------------------
/*/{Protheus.doc} fPnlRegis
Monta o Painel de Dados.

@author Wagner Sobral de Lacerda
@since 21/09/2012

@param oParent
	Objeto Pai do Browse * Obrigatório

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fPnlRegis(oParent)

	// Variáveis Auxiliares
	Local oPnlPai
	Local oContainer
	Local oFoldVars, oFoldTbls
	Local oPnlTmp

	Local aFoldVars := {}, aTabelas := {}, aFoldTbls := {}
	Local nScanVar := 0, nScanFol := 0
	Local nVar := 0, nDad := 0, nFold := 0, nTbl := 0

	Local oPnlTbl, oBtnTbl
	Local oPnlReg

	Local cTitulo := ""
	Local cAction := ""

	Local nRGBVersao := 0

	//-- Define o RGB adequado para a versão do Protheus
	If "10" $ cVersao // Versão 10 do Protheus
		nRGBVersao := RGB(250,250,250)
	Else // Versão 11 do Protheus
		nRGBVersao := RGB(70,130,180)
	EndIf

	//-- Define como será o Folder de acordo com as Variáveis
	For nVar := 1 To Len(aBtnDados)
		// Percorre todas as tabelas da variável, buscando as selecionadas
		For nDad := 1 To Len(aBtnDados[nVar][2])
			// Verifica a tabela está selecionada para a Variável
			If aBtnDados[nVar][2][nDad][nBDaESTADO]
				// Verifica se a variável é válida (existe)
				nScanVar := aScan(aWinVariav, {|x| AllTrim(x[nVarVARIAV]) == AllTrim(aBtnDados[nVar][1]) })

				// Se a variável existe
				If nScanVar > 0
					// Verifica se já não foi adicionada a variável no folder
					nScanFol := aScan(aFoldVars, {|x| x == AllTrim(aBtnDados[nVar][1]) })

					// Adiciona no Folder
					If nScanFol == 0
						aAdd(aFoldVars, AllTrim(aBtnDados[nVar][1]))
						nScanFol := Len(aFoldVars)
						aAdd(aTabelas, {}) // o Array 'aFoldVars' e 'aTabelas' são idênticos em tamanho, porque o 'aTabelas' apenas contém uma posição a mais para representar as tabelas do folder
					EndIf

					// Armazena as tabelas para montar subpastas
					aAdd(aTabelas[nScanFol], aBtnDados[nVar][2][nDad][nBDaTABELA])
				EndIf
			EndIf
		Next nDad
	Next nVar

	//----------
	// Monta
	//----------
	// Painel Pai
	oPnlPai := TPanel():New(01, 01, , oParent, , , , CLR_BLACK, CLR_WHITE, 100, 100)
	oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT
	oPnlPai:CoorsUpdate()

		// Painel temporário container do folder principal (das variáveis)
		oContainer := TPanel():New(01, 01, , oPnlPai, , , , CLR_BLACK, CLR_WHITE, 100, 100)
		oContainer:Align := CONTROL_ALIGN_ALLCLIENT

			// Folder das Variáveis
			If Len(aFoldVars) == 0
				TSay():New(010, 005, {|| STR0037 }, oContainer, , , , ; //"Não há Registros para exibir.
								, , .T., CLR_BLACK, CLR_WHITE, 100, 015)
				// Esconde o Painel do Browse
				oWinBrwReg:Hide()
			Else
				// Mostra o Painel do Browse
				oWinBrwReg:Show()
				// Monta o Folder
				oFoldVars := TFolder():New(01, 01, aFoldVars, aFoldVars, oContainer, 1, CLR_BLACK, CLR_WHITE, .T., , 100, 025)
				oFoldVars:bChange := {|| fPnlBrwFol(oFoldVars:nOption) }
				oFoldVars:Align := CONTROL_ALIGN_TOP

					// Monta as Tabelas com os Registros (subpastas)
					aBtnRegist := {} // Botão das Tabelas (por Variável)
					For nFold := 1 To Len(oFoldVars:aDialogs)
						// Cria Botão de Registro por Variável
						aAdd(aBtnRegist, {aFoldVars[nFold], {}}) // 1=Código da Variável ; 2=Botões

						// Define as tabelas
						aFoldTbls := {}
						For nTbl := 1 To Len(aTabelas[nFold])
							aAdd(aFoldTbls, aTabelas[nFold][nTbl])
						Next nTbl

						// Painel para as selecionar a Tabela
						oPnlTbl := TPanel():New(01, 01, , oFoldVars:aDialogs[nFold], , , , CLR_BLACK, RGB(250,250,250), 100, 100)
						oPnlTbl:Align := CONTROL_ALIGN_ALLCLIENT

							// Monta os Botões, em formato de abas
							For nTbl := 1 To Len(aFoldTbls)
								// Botão
								aAdd(aBtnRegist[nFold][2], Array(3)) // 1=Objeto do Botão ; 2=Estado do Botão ; 3=Código da Tabela

								cTitulo := "'" + AllTrim(aFoldTbls[nTbl]) + "'"
								cAction := "{|| fPnlBrwReg('" + aFoldVars[nFold] + "', '" + aFoldTbls[nTbl] + "') }"
								aBtnRegist[nFold][2][nTbl][nBReOBJETO] := TButton():New(001, 001, &(cTitulo), oPnlTbl, &(cAction),;
											  											030, 012, , , .F., .T., .F., , .F., , , .F.)
					  			aBtnRegist[nFold][2][nTbl][nBReOBJETO]:lCanGotFocus := .F.
							  	aBtnRegist[nFold][2][nTbl][nBReOBJETO]:Align := CONTROL_ALIGN_LEFT
							  	aBtnRegist[nFold][2][nTbl][nBReTABELA] := aFoldTbls[nTbl]
							  	// CSS do Botão "Tabela de Registros em Espera"
								fSetCSS(nCSSRegEsp, aBtnRegist[nFold][2][nTbl][nBReOBJETO])
								aBtnRegist[nFold][2][nTbl][nBReESTADO] := .F.
							Next nTbl

					Next nFold

				// Painel da Cor do BOTÃO SELECIONADO, para que seja um separador entre a "Aba" e o "Browse"
				oPnlTmp := TPanel():New(01, 01, , oContainer, , , , CLR_BLACK, nRGBVersao, 100, 002)
				oPnlTmp:Align := CONTROL_ALIGN_ALLCLIENT

				// Inicializa o folder selecionado
				Eval(oFoldVars:bChange)
			EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fPnlBrwFol
Executa a Seleção do Folder.

@author Wagner Sobral de Lacerda
@since 26/09/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fPnlBrwFol(nFoldOption)

	// Variáveis auxiliares
	Local nAtivo := 0

	//----------
	// Executa
	//----------
	// Verifica se o Folder é válida (sempre deveria ser, mas estamos validando aqui só pra garantir... rsrs)
	If Len(aBtnRegist) >= nFoldOption
		// Busca algum botão ativo
		nAtivo := aScan(aBtnRegist[nFoldOption][2], {|x| x[nBReESTADO] })
		If nAtivo == 0
			// Caso não tenha nenhum ativo, ativa o primeiro botão, recarregando o browse
			nAtivo := 1
		EndIf
		// Executa a Ação do Botão
		If Len(aBtnRegist[nFoldOption][2]) >= nAtivo
			// Cursor em Espera
			CursorWait()
			// Executa
			aBtnRegist[nFoldOption][2][nAtivo][nBReOBJETO]:Click()
			// Cursor Noraml
			CursorArrow()
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fPnlBrwReg
Monta o Painel do browse dos registros da tabela.

@author Wagner Sobral de Lacerda
@since 25/09/2012

@param cCodVariav
	Código da Variável * Obrigatório
@param cCodTabela
	Código da Tabela * Obrigatório

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fPnlBrwReg(cCodVariav, cCodTabela)

	// Salva as áreas atuais
	Local aAreaSX3 := SX3->( GetArea() )
	Local aAreaTZF := TZF->( GetArea() )

	// Variáveis auxiliares
	Local nScanVar := 0, nScanBtn := 0, nScanSel := 0

	Local oTmpPaiBrw
	Local oFWBrw
	Local cSeekVar := "", cSeekTbl := ""
	Local aHeader := {}, nHead := 0, cOrdemCpo := ""
	Local aMark := {}, aHeadClick := {}
	Local aCampos := {}, nCampo := 0
	Local aGetRegis := {}
	Local nScan := 0

	Local cIDCampo := ""
	Local cTipDado := ""
	Local cTitulo  := ""
	Local cPicture := ""
	Local nTamanho := 0
	Local nDecimal := 0
	Local cSetData := ""

	Local nBackUp := 0, nNewBackUp := 0
	Local nX := 0

	Local aNao := {}

	// Defaults
	Default cCodVariav := ""
	Default cCodTabela := ""

	//----------
	// Executa
	//----------
	// Verifica o Estado do Botão
	nScanVar := aScan(aBtnRegist, {|x| AllTrim(x[1]) == AllTrim(cCodVariav) })
	If nScanVar > 0
		nScanBtn := aScan(aBtnRegist[nScanVar][2], {|x| AllTrim(x[nBReTABELA]) == AllTrim(cCodTabela) })
		If nScanBtn > 0

			// Se já estiver marcado, então é o botão atual e não precisa fazer nada (já que só pode ser selecionado um botão de cada vez)
			// Mas, caso seja uma chamada pela troca de folder, então é obrigatório atualizar o browse
			If aBtnRegist[nScanVar][2][nScanBtn][nBReESTADO] .And. !IsInCallStack(Upper("fPnlBrwFol"))
				Return .T.
			Else
				// Senão, desmarca o que etá marcado e seleciona (marca) este
				nScanSel := aScan(aBtnRegist[nScanVar][2], {|x| x[nBReESTADO] })
				If nScanSel > 0
					// CSS do Botão "Tabela de Registros em Espera"
					fSetCSS(nCSSRegEsp, aBtnRegist[nScanVar][2][nScanSel][nBReOBJETO])
					aBtnRegist[nScanVar][2][nScanSel][nBReESTADO] := .F.
				EndIf

				// Atualiza o Atual
				// CSS do Botão "Tabela de Registros Selecionada"
				fSetCSS(nCSSRegSel, aBtnRegist[nScanVar][2][nScanBtn][nBReOBJETO])
				aBtnRegist[nScanVar][2][nScanBtn][nBReESTADO] := .T.
			EndIf

		EndIf
	EndIf

	//--------------------
	// Monta a Estrutura
	//--------------------
	// Esconde todos os browses
	For nX := 1 To Len(aBkpBrwReg)
		If ValType(aBkpBrwReg[nX][5]) == "O"
			aBkpBrwReg[nX][5]:Hide()
		EndIf
	Next nX

	// Se já tiver sido montado o browse, este fica no BackUp, e então, apenas recebe o que já existe (para não ter que ficar montando tudo de novo)
	nBackUp := aScan(aBkpBrwReg, {|x| AllTrim(x[1]) == AllTrim(cCodVariav) .And. AllTrim(x[2]) == AllTrim(cCodTabela) })
	If nBackUp > 0
		aHeader    := aClone(aBkpBrwReg[nBackUp][3]) // Cabeçalho do Browse
		aWinBrwReg := aClone(aBkpBrwReg[nBackUp][4]) // Conteúdo do Browse
	Else
		// Define os campos para o Seek
		cSeekVar := PADR(cCodVariav, TAMSX3("TZF_VARIAV")[1], " ")
		cSeekTbl := PADR(cCodTabela, TAMSX3("TZF_TABELA")[1], " ")

		// Recebe os Registros
		aNao := NGCAMPNSX3(cSeekTbl, , .T., , .T.) // Apenas campos do Brwose
		aNao := NGCAMPNSX3(cSeekTbl, aNao, , , .T.)

		aGetRegis  := fGetRegis(cSeekVar, cSeekTbl, aNao)
		aHeader    := aClone( aGetRegis[1] )
		aWinBrwReg := aClone( aGetRegis[2] )

		// Armazena no BackUp
		aAdd(aBkpBrwReg, {cCodVariav, cCodTabela, aClone(aHeader), aClone(aWinBrwReg), Nil, Nil})
		nNewBackUp := Len(aBkpBrwReg)
	EndIf

	//--------------------
	// Monta o Browse
	//--------------------
	// Se já existir BackUp, usa o BackUp
	If nBackUp > 0
		aBkpBrwReg[nBackUp][5]:Show()
	Else // Caso contrário, cria o browse e armazena no backup
		//-- Painel Container
		oTmpPaiBrw := TPanel():New(01, 01, , oWinBrwReg, , , , CLR_BLACK, CLR_WHITE, 100, 100)
		oTmpPaiBrw:Align := CONTROL_ALIGN_ALLCLIENT

		//-- Browse
		oFWBrw := FWBrowse():New(oTmpPaiBrw)

		oFWBrw:SetDataArray()
		oFWBrw:SetInsert(.F.) // Desabilita a Inserção de registros
		oFWBrw:SetLocate() // Habilita o Localizar
		oFWBrw:DisableSaveConfig()  // Desabilita Salvar as Configurações (porque o browse é diferente a cada momento)

		aColunas := {}
		For nHead := 1 To Len(aHeader)
			cIDCampo := aHeader[nHead][1]
			cTipDado := aHeader[nHead][2]
			cTitulo  := aHeader[nHead][3]
			cPicture := aHeader[nHead][6]
			nTamanho := aHeader[nHead][4]
			nDecimal := aHeader[nHead][5]

			// Cria Coluna
			oColuna := FWBrwColumn():New()
			oColuna:SetAlign(If(cTipDado == "N", CONTROL_ALIGN_RIGHT, CONTROL_ALIGN_LEFT))
			oColuna:SetEdit(.F.)
			oColuna:SetSize(nTamanho+nDecimal)
			oColuna:SetTitle(cTitulo)
			oColuna:SetType(cTipDado)

			cSetData := "{|| aWinBrwReg[oFWBrw:AT()][" + cValToChar(nHead) + "] }"
			oColuna:SetData(&(cSetData))

			aAdd(aColunas, oColuna)
		Next nHead
		oFWBrw:SetColumns(aColunas)
		oFWBrw:SetArray(aWinBrwReg)

		oFWBrw:Activate()
		oFWBrw:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oFWBrw:GoTop()

		// Armazena no BackUp
		If nNewBackUp > 0
			aBkpBrwReg[nNewBackUp][5] := oTmpPaiBrw
			aBkpBrwReg[nNewBackUp][6] := oFWBrw
		EndIf
	EndIf

	// Devolve as Áreas
	RestArea(aAreaSX3)
	RestArea(aAreaTZF)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetRegis
Recebe um Array com os Registros da Tabela do Histórico.

@author Wagner Sobral de Lacerda
@since 25/09/2012

@param cCodVariav
	Código da Variável * Obrigatório
@param cCodTabela
	Código da Tabela * Obrigatório

@return aRetorno
/*/
//---------------------------------------------------------------------
Static Function fGetRegis(cCodVariav, cCodTabela, aNaoCpos)

	// Variável do Retorno
	Local aRetorno := {}

	// Variáveis do Seek
	Local cSeekFil := ""
	Local cSeekHis := ""
	Local cSeekVar := ""
	Local cSeekTbl := ""

	// Variáveis auxiliares
	Local aSequencs := {}
	Local cSequenc := ""

	Local aRegist := {}
	Local aCampos := {}
	Local nCampo := 0

	Local aHeader := {}
	Local aCols   := {}
	Local nReg := 0, nHead := 0
	Local nScan := 0

	Local aVirtuais := {}
	Local nVirtual := 0

	Local cIDCampo := ""
	Local cTipDado := ""
	Local cTitulo  := ""
	Local cPicture := ""
	Local nTamanho := 0
	Local nDecimal := 0
	Local cSetData := ""
	Local lReal    := .F.
	Local cInitBrw := ""

	// Defaults
	Default aNaoCpos := {}

	//----------
	// Executa
	//----------
	//-- Busca os Campos da TZF
	aRegist := {}

	cSeekFil := xFilial("TZF",TZE->TZE_FILIAL)
	cSeekHis := TZE->TZE_CODIGO
	cSeekVar := PADR(cCodVariav, TAMSX3("TZF_VARIAV")[1], " ")
	cSeekTbl := PADR(cCodTabela, TAMSX3("TZF_TABELA")[1], " ")
	dbSelectArea("TZF")
	dbSetOrder(2)
	dbSeek(cSeekFil + cSeekHis + cSeekVar + cSeekTbl, .T.)
	While !Eof() .And. TZF->TZF_FILIAL == cSeekFil .And. TZF->TZF_CODIGO == cSeekHis .And. ;
		TZF->TZF_VARIAV == cSeekVar .And. TZF->TZF_TABELA == cSeekTbl .And. Len(aSequencs) < 100 // aSequencs = quantidade máxima de registros para não dar estouro de memória

		// Recebe a primeira sequeência (o cabeçalho/colunas só precisa da primeira sequência)
		cSequenc := TZF->TZF_SEQUEN
		If !Empty(cSequenc) .And. cSequenc == TZF->TZF_SEQUEN
			// Array utilizado para o Cabeçalho posteriormente
			If aScan(aCampos, {|x| x[1] == TZF->TZF_CAMPO }) == 0
				// 1           ; 2            ; 3      ; 4       ; 5       ; 6       ; 7              ; 8     ; 9
				// ID do Campo ; Tipo de Dado ; Título ; Tamanho ; Decimal ; Picture ; Ordem do Campo ; Real? ; Inicializador do conteúdo virtual
				aAdd(aCampos, {TZF->TZF_CAMPO, TZF->TZF_TIPDAD, TZF->TZF_AUXTIT, TZF->TZF_AUXTAM, TZF->TZF_AUXDEC, TZF->TZF_AUXPIC, TZF->TZF_ORDEM, .T., Nil})
			EndIf
		EndIf

		// Array com os registros
		// 1                     ; 2           ; 3
		// Sequência do Registro ; ID do Campo ; Conteúdo do
		aAdd(aRegist, {Val(cSequenc), TZF->TZF_CAMPO, NGI6CONVER(TZF->TZF_CONTEU,TZF->TZF_TIPDAD,,,.T.)})

		// Quantidade de Registros
		If aScan(aSequencs, {|x| x == cSequenc }) == 0
			aAdd(aSequencs, cSequenc)
		EndIf

		dbSelectArea("TZF")
		dbSkip()
	End

	//-- Define o Cabeçaljo
	For nCampo := 1 To Len(aCampos)
		cIDCampo  := aCampos[nCampo][1]
		cOrdemCpo := aCampos[nCampo][7]

		// Se não for para carregar o campos, pula
		If Len(aNaoCpos) > 0
			If aScan(aNaoCpos, {|x| AllTrim(x) == AllTrim(cIDCampo) }) > 0
				Loop
			EndIf
		EndIf

		// Recebe dados do campos
		dbSelectArea("SX3")
		dbSetOrder(2)
		If dbSeek(cIDCampo)
			// Recebe conteúdo do SX3
			cTipDado := Posicione("SX3",2,cIDCampo,"X3_TIPO")
			cTitulo  := AllTrim(X3Titulo())
			cPicture := PesqPict(Posicione("SX3",2,cIDCampo,"X3_ARQUIVO"), cIDCampo, )
			nTamanho := TAMSX3(cIDCampo)[1]
			nDecimal := Posicione("SX3",2,cIDCampo,"X3_DECIMAL")
		Else
			// Recebe conteúdo do Histórico (TZF)
			cTipDado := aCampos[nCampo][2]
			cTitulo  := AllTrim(aCampos[nCampo][3])
			cPicture := AllTrim(aCampos[nCampo][6])
			nTamanho := aCampos[nCampo][4]
			nDecimal := aCampos[nCampo][5]

			// Se mesmo assima ainda não possuir título, define um padrão
			If Empty(cTitulo)
				cTitulo := cIDCampo
			EndIf
		EndIf
		lReal    := aCampos[nCampo][8]
		cInitBrw := aCampos[nCampo][9]

		// Adiciona no Cabeçalho
		// 1           ; 2            ; 3      ; 4       ; 5       ; 6       ; 7                 ; 8     ; 9
		// ID do Campo ; Tipo de Dado ; Título ; Tamanho ; Decimal ; Picture ; Ordem (sequência) ; Real? ; Inicializador do conteído virtual
		aAdd(aHeader, {cIDCampo, cTipDado, cTitulo, nTamanho, nDecimal, cPicture, cOrdemCpo, lReal, cInitBrw})
	Next nCampo
	aSort(aHeader, , , {|x,y| x[7]+x[1] < y[7]+y[1] }) // Ordena por Sequência + ID

	// Define o Conteúdo dos registros, em sqeuÊncia, de acordo com a coluna
	aSort(aRegist, , , {|x,y| x[1] < y[1] }) // Ordena por Sequência
	aCols := Array(Len(aSequencs)) // Cria quantidade de Registros
	// Percorre todos os registros
	For nReg := 1 To Len(aCols)
		// Define todas as colunas
		aCols[nReg] := Array(Len(aHeader))
		For nHead := 1 To Len(aHeader)
			If aHeader[nHead][8]
				nScan := aScan(aRegist, {|x| x[1] == nReg .And. AllTrim(x[2]) == AllTrim(aHeader[nHead][1]) })
				If nScan > 0
					// Contexto REAL
					aCols[nReg][nHead] := aRegist[nScan][3]
				EndIf
			ElseIf ValType(aHeader[nHead][9]) == "C" .And. !Empty(aHeader[nHead][9])
				// Contexto VIRTUAL
				cTemp := aHeader[nHead][9]
				aCols[nReg][nHead] := &(aHeader[nHead][9])
			EndIf
		Next nHead
	Next nReg

	// Define o Retorno
	aRetorno := {aClone(aHeader), aClone(aCols)}

Return aRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} fAtuConsul
Atualiza os Objetos da Consulta.

@author Wagner Sobral de Lacerda
@since 20/09/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fAtuConsul()

	// Variáveis auxiliares
	Local lTemMeta := !Empty(TZE->TZE_TIPMET)
	Local cAuxSayMeta := ""

	Local cSetGet := ""
	Local nResult := TZE->TZE_RESULT, cResult := ""
	Local nMeta   := TZE->TZE_META  , cMeta   := ""
	Local nMeta2  := TZE->TZE_META2 , cMeta2  := ""
	Local nDiff   := 0

	Local aClrRexMe := {}

	Local cMetDentro := STR0038 //"Dentro da Meta"
	Local cMetFora   := STR0039 //"Fora da Meta"
	Local lMetDentro := .F.
	Local cMetDiff   := ""

	//-- Define as cores da Meta
	aAdd(aClrRexMe, RGB(0,179,0)) // Bom
	aAdd(aClrRexMe, RGB(179,0,0)) // Ruim

	//----------
	// Executa
	//----------
	If lConsulta

		//-- Data
		oGetData:CtrlRefresh()
		//-- Hora
		oGetHora:CtrlRefresh()
		//-- Indicador
		oGetCodInd:CtrlRefresh()
		oGetNomInd:CtrlRefresh()
		//-- Fórmula
		oGetFormul:Refresh()
		//-- Resultado
		If TZE->TZE_TIPVAL == "1" // Numérico
			// Transforma
			cMeta  := AllTrim( Transform(nMeta,PesqPict("TZE","TZE_META",)) )
			cMeta2 := AllTrim( Transform(nMeta2,PesqPict("TZE","TZE_META2",)) )

			// Esconde o TGet em Hora
			oGetResHor:Hide()
			// Mostra e Atualiza o TGet em Numérico
			oGetResNum:Show()
			oGetResNum:bSetGet := {|| nResult }
			oGetResNum:CtrlRefresh()
		ElseIf TZE->TZE_TIPVAL == "2" // Hora
			// Transforma
			cResult := NTOH(nResult)
			cMeta   := NTOH(nMeta)
			cMeta2  := NTOH(nMeta2)

			// Esconde o TGet em Numérico
			oGetResNum:Hide()
			// Mostra e Atualiza o TGet em Hora
			oGetResHor:Show()
			oGetResHor:bSetGet := {|| cResult }
			oGetResHor:CtrlRefresh()
		EndIf
		//-- Meta
		If lTemMeta
			cAuxSayMeta := NGIND010X3("TZE_TIPMET",TZE->TZE_TIPMET) + " " + cMeta
			If TZE->TZE_TIPMET $ "5/6"
				cAuxSayMeta += " a " + cMeta2
			EndIf
			oSayMeta:SetText("(" + cAuxSayMeta + ")")

			// Cor da META
			// - Porcentagem de diferença positiva indicará que o indicador está dentro da meta em X%
			// - Porcentagem de diferença negativa indicará que o indicador está fora da meta em X%
			lMetDentro := NGIND010MT(TZE->TZE_TIPMET, nMeta, nMeta2, nResult)
			// Resultado x Meta
			If lMetDentro
				oSayRexMe:SetText(cMetDentro)
				oSayRexMe:SetColor(aClrRexMe[1], nClrBack) // Bom
				oSayDiff:SetText(cMetDiff)
			Else
				oSayRexMe:SetText(cMetFora)
				oSayRexMe:SetColor(aClrRexMe[2], nClrBack) // Ruim
				oSayDiff:SetText(cMetDiff)
			EndIf
			// Meta
			oSayMeta:Show()
			oSayMeta:Refresh()

			// Diferença
			nDiff := ( nResult / nMeta ) * 100
			cMetDiff := cValToChar(nDiff) + "% " + STR0040 //"em relação à meta inicial"
			oSayDiff:SetText(cMetDiff)
			oSayDiff:Show()
			oSayDiff:Refresh()
		Else
			// Resultado x Meta
			oSayRexMe:SetText("---")
			oSayRexMe:SetColor(nClrText, nClrBack) // Ruim
			// Meta
			oSayMeta:Hide()
			// Diferença
			oSayDiff:Hide()
		EndIf

		// Processa os Dados da Consulta nos Arrays
		fProcConsul()

		fAtuVar()
		// Atualiza as Variáveis
		//oWinVariav:FreeChildren()
		//fPnlVariav(@oWinVariav)
		//oWinCalc:FreeChildren()
		//fPnlCalc(@oWinCalc)

		// Atualiza a Seleção das Variáveis, que consequentemente atualiza o resto da consulta (Parâmetros, Dados (Tabelas) e Registros)
		fSelectVar(If(lMV_Selec .And. lMontando,"ALL",Nil))

	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fSelectVar
Executa a Seleção de uma Variável para consultar, e atualiza a cosulta
de Parâmetros e de Dados.

@author Wagner Sobral de Lacerda
@since 24/09/2012

@param cCodVar
	Código da Variável para carregar os Parâmetros e os Dados * Opcional
	-> "ALL" para selecinoar todas as variáveis
@param nOnlyAtu
	Indica se deve apenas atualizar o Painel * Opcional
	   0 - Executa o processo normal
	   1 - Apenas atualiza o Painel de Parâmetros
	   2 - Apenas atualiza o Painel de Dados (Tabelas)
	Default: 0

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fSelectVar(cCodVar, nOnlyAtu)

	// Variáveis auxiliares
	Local nVar := 0
	Local lEstado := .F.

	Local lAllVars := .F.
	Local nScanVar := 0

	// Defaults
	Default cCodVar  := ""
	Default nOnlyAtu := 0

	//----------
	// Executa
	//----------
	// Seleciona tudo?
	lAllVars := AllTrim(cCodVar) == "ALL" // Variáveis
	If lAllVars
		nScanVar := 1
	Else
		nScanVar := aScan(aBtnVariav, {|x| AllTrim(x[nBVaVARIAV]) == AllTrim(cCodVar) })
	EndIf
	// Atualiza o Estado dos Botões
	If nScanVar > 0
		For nVar := nScanVar To Len(aBtnVariav)
			// Se for um botão (uma Variável) diferente, quando não for selecionado TODOS, então sai do laço
			If !lAllVars .And. AllTrim(aBtnVariav[nVar][nBVaVARIAV]) <> AllTrim(cCodVar)
				Exit
			EndIf

			// Atualiza Estado
			lEstado := !aBtnVariav[nVar][nBVaESTADO]
			aBtnVariav[nVar][nBVaESTADO] := lEstado
			// CSS do Botão "Variável em Espera" ou "Variável Selecionada"
			//fSetCSS(If(lEstado,nCSSVarSel,nCSSVarEsp), aBtnVariav[nVar][nBVaOBJETO])
		Next nVar
	EndIf

	//----------
	// Atualiza
	//----------
	// Atualiza os Parâmetros, Dados (Tabelas) e, consequentemente, os Registros
	If nOnlyAtu == 0 // Tudo (normal)
		oWinParams:FreeChildren()
		//oWinDados:FreeChildren()

		MsgRun(STR0041, STR0042, {|| fPnlParams(@oWinParams), fAtuDados()/*, fPnlDados(@oWinDados)*/ }) //"Carregando a Consulta..." ## "Por favor, aguarde..."
	ElseIf nOnlyAtu == 1 // Parâmetros
		oWinParams:FreeChildren()
		fPnlParams(@oWinParams)
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fSelectTbl
Executa a Seleção de uma Tabela para consultar os registros.

@author Wagner Sobral de Lacerda
@since 24/09/2012

@param cCodVar
	Código da Variável para carregar as Tabelas * Opcional
	-> "ALL" para selecinoar todas as variáveis
	Default: "" (não atualiza)
@param cCodVar
	Código da Tabela para carregar * Opcional
	-> "ALL" para selecinoar todas as tabelas
	Default: "" (não atualiza)

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fSelectTbl(cCodVar, cCodTbl)

	// Variáveis auxiliares
	Local nVar := 0, nTbl := 0
	Local lEstado := .F.

	Local lAllVars := .F.
	Local lAllTbls := .F.
	Local nScanVar := 0, nScanTbl := 0

	Local nBackUp := 0

	// Defaults
	Default cCodVar := ""
	Default cCodTbl := ""

	//----------
	// Executa
	//----------
	// Seleciona tudo?
	lAllVars := AllTrim(cCodVar) == "ALL" // Variáveis
	lAllTbls := AllTrim(cCodTbl) == "ALL" // Tabelas
	If lAllVars
		nScanVar := 1
	Else
		nScanVar := aScan(aBtnDados, {|x| AllTrim(x[1]) == AllTrim(cCodVar) })
	EndIf
	// Atualiza o Estado dos Botões
	If nScanVar > 0
		For nVar := nScanVar To Len(aBtnDados)
			// Se for um botão (uma Variável) diferente, quando não for selecionado TODOS, então sai do laço
			If !lAllVars .And. AllTrim(aBtnDados[nVar][1]) <> AllTrim(cCodVar)
				Exit
			EndIf

			If lAllTbls
				nScanTbl := 1
			Else
				nScanTbl := aScan(aBtnDados[nVar][2], {|x| AllTrim(x[nBDaTABELA]) == AllTrim(cCodTbl) })
			EndIf
			If nScanTbl > 0
				For nTbl := nScanTbl To Len(aBtnDados[nVar][2])
					// Se for um botão (uma Tabela) diferente, quando não for selecionado TODOS, então sai do laço
					If !lAllTbls .And. AllTrim(aBtnDados[nVar][2][nTbl][nBDaTABELA]) <> AllTrim(cCodTbl)
						Exit
					EndIf

					// Atualiza Estado
					lEstado := !aBtnDados[nVar][2][nTbl][nBDaESTADO]
					aBtnDados[nVar][2][nTbl][nBDaESTADO] := lEstado
					// CSS do Botão "Variável em Espera" ou "Variável Selecionada"
					//fSetCSS(If(lEstado,nCSSTblSel,nCSSTblEsp), aBtnDados[nVar][2][nTbl][nBDaOBJETO])

					// Verifica se possui BackUp
					nBackUp := aScan(aBkpDados, {|x| AllTrim(x[1]) == AllTrim(aBtnDados[nVar][1]) .And. AllTrim(x[2]) == AllTrim(aBtnDados[nVar][2][nTbl][nBDaTABELA]) })
					If nBackUp > 0
						// Se possuir e não estiver selecionada, deleta
						If !lEstado
							aDel(aBkpDados, nBackUp)
							aSize(aBkpDados, (Len(aBkpDados)-1))
						EndIf
					Else
						// Se não possuir e estiver selecionada, salva
						If lEstado
							aAdd(aBkpDados, {aBtnDados[nVar][1], aBtnDados[nVar][2][nTbl][nBDaTABELA]})
						EndIf
					EndIf
				Next nTbl
			EndIf
		Next nVar
	EndIf

	//--------------------
	// Mostra Registros
	//--------------------
	oWinRegist:FreeChildren()
	If IsInCallStack("__PTWAITRUN")
		fPnlRegis(oWinRegist)
	Else
		MsgRun(STR0043, STR0042, {|| fPnlRegis(oWinRegist) }) //"Carregando os Registros..." ## "Por favor, aguarde..."
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND010X3
Função para retornar o conteúdo de uma String no ComboBox

@author Wagner Sobral de Lacerda
@since 21/09/2012

@return cComboBox
/*/
//---------------------------------------------------------------------
Function NGIND010X3(cCampo, cConteudo)

	// Salva as áreas atuais
	Local aAreaSX3 := SX3->( GetArea() )

	// Variável do Retorno
	Local cString := ""

	// Variáveis auxiliares
	Local aCBox := {}
	Local cCBox := ""
	Local nX := 0, nAT := 0

	//----------
	// Executa
	//----------
	dbSelectArea("SX3")
	dbSetOrder(2)
	If dbSeek(cCampo)
		// Recebe o ComboBox
		cCBox := AllTrim(X3CBox())
		// Transforma o Combo num Array
		aCBox := StrTokArr(cCBox, ";")

		// Busca o Coteúdo passado como parâmetro
		For nX := 1 To Len(aCBox)
			nAT := AT("=",aCBox[nx])
			If SubStr(aCBox[nx],1,(nAT-1)) == cConteudo
				cString := SubStr(aCBox[nX],(nAT+1))
				Exit
			EndIf
		Next nX
	EndIf

	// Devolve as áreas
	RestArea(aAreaSX3)

Return cString

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND010MT
Função para verificar tipo de Meta (TZE_TIPMET)

@author Wagner Sobral de Lacerda
@since 21/09/2012

@return lMeta
/*/
//---------------------------------------------------------------------
Function NGIND010MT(cTipoMeta, nMeta1, nMeta2, nResult)

	// Variáveis auxiliares
	Local lMeta := .F.

	//--------------------
	// Verifica Meta
	//--------------------
	If cTipoMeta == "1" // 1=Maior que
		If nResult > nMeta1
			lMeta := .T.
		EndIf
	ElseIf cTipoMeta == "2" // 2=Maior que ou igual a
		If nResult >= nMeta1
			lMeta := .T.
		EndIf
	ElseIf cTipoMeta == "3" // 3=Menor que
		If nResult < nMeta1
			lMeta := .T.
		EndIf
	ElseIf cTipoMeta == "4" // 4=Menor que ou igual a
		If nResult <= nMeta1
			lMeta := .T.
		EndIf
	ElseIf cTipoMeta == "5" // 5=Dentro do intervalo
		If nResult >= nMeta1 .And. nResult <= nMeta2
			lMeta := .T.
		EndIf
	ElseIf cTipoMeta == "6" // 6=Fora do intervalo
		If nResult < nMeta1 .Or. nResult > nMeta2
			lMeta := .T.
		EndIf
	ElseIf cTipoMeta == "7" // 7=Igual a
		If nResult == nMeta1
			lMeta := .T.
		EndIf
	ElseIf cTipoMeta == "8" // 8=Diferente de
		If nResult <> nMeta1
			lMeta := .T.
		EndIf
	Endif

Return lMeta

//---------------------------------------------------------------------
/*/{Protheus.doc} fSetCSS
Define um CSS para um botão.

@author Wagner Sobral de Lacerda
@since 24/09/2012

@param nEstilo
	Indica o estilo do CSS de acordo com o botão: * Obrigatório
	   nCSSVarEsp - Botão de Variável em Espera
	   nCSSVarSel - Botão de Variável Selecionada
	   nCSSTblEsp - Botão de Tabela em Espera
	   nCSSTblSel - Botão de Tabela Selecionada
	   nCSSRegEsp - Botão de Tabela de Registros em Espera
	   nCSSRegSel - Botão de Tabela de Registros Selecionada
	   nCSSTipEsp - Botão de Tipo de Impressão em Espera
	   nCSSTipSel - Botão de Tipo de Impressão Selecionado
	   nCSSLink   - Botão de Link
	   nCSSCarreg - Botão de Carregar alguma coisa
@param oObjBtn
	Referencia o Objeto do Botão (TButton) * Obrigatório

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fSetCSS(nEstilo, oObjBtn)

	// Variáveis das Cores em Hexadecimal a serem aplicadas
	Local cUsaBack1 := "", cUsaBack2 := "", cUsaBack3 := ""
	Local cUsaFore1 := "", cUsaFore2 := "", cUsaFore3 := ""
	Local cUsaBord1 := "", cUsaBord2 := "", cUsaBord3 := ""
	Local cUsaGrad1 := "", cUsaGrad2 := "", cUsaGrad3 := ""

	Local cAuxBord1 := "", cAuxBord2 := "", cAuxBord3 := ""

	// Variáveis da Fonte
	Local cFontFamily := ""
	Local cFontSize   := ""
	Local cFontWeight := ""
	Local cFontAlign  := ""
	Local cBordRadius := ""

	// Variável de Decorações da Fonte
	Local lUnderline := .F.

	// Variável de Bordas Arredondadas específicas
	Local lRadiusTOP := ( nEstilo == nCSSRegEsp .Or. nEstilo == nCSSRegSel )
	Local cAuxRadius := ""

	// Fonte Padrão
	cFontFamily := "'Segoe UI', Tahoma, sans-serif"
	cFontSize   := "12"
	cFontWeight := "bold"
	cBordRadius := "3"

	//-- Gradiente padrão
	cUsaGrad1 := "#FAFAFA" // Cinza Claro -  Personalizado (RGB: 250,250,250)
	cUsaGrad2 := "#FDFDFD" // Cinza Claro -  Personalizado (RGB: 253,253,253)
	cUsaGrad3 := "#FDFDFD" // Cinza Claro -  Personalizado (RGB: 253,253,253)

	//----------------------------------------
	// Define as cores a serem utilizadas
	//----------------------------------------
	If nEstilo == nCSSVarEsp

		//----------------------------------------
		// Botão de Variáveis "em Espera"
		//----------------------------------------

		cFontWeight := "normal"
		cBordRadius := "2"

		cUsaBack1 := "#E9F0F6" // Azul Claro -  Personalizado(RGB: 233,240,246)
		cUsaBack2 := "#E9F0F6" // Azul Claro -  Personalizado(RGB: 233,240,246)
		cUsaBack3 := "#E9F0F6" // Azul Claro -  Personalizado(RGB: 233,240,246)

		cUsaFore1 := "#4682B4" // Azul Escuro -  Personalizado(RGB: 70,130,180)
		cUsaFore2 := "#4682B4" // Azul Escuro -  Personalizado(RGB: 255,255,255)
		cUsaFore3 := "#4682B4" // Azul Escuro -  Personalizado(RGB: 255,255,255)

		cUsaBord1 := "#B0C4DE" // LightSteelBlue
		cUsaBord2 := "#6495ED" // CornflowerBlue
		cUsaBord3 := "#4682B4" // SteelBlue

	ElseIf nEstilo == nCSSVarSel

		//----------------------------------------
		// Botão de Variáveis "Selecionado"
		//----------------------------------------

		cBordRadius := "2"

		cUsaBack1 := "#4682B4" // Azul Escuro -  Personalizado(RGB: 70,130,180)
		cUsaBack2 := "#4682B4" // Azul Escuro -  Personalizado(RGB: 70,130,180)
		cUsaBack3 := "#4682B4" // Azul Escuro -  Personalizado(RGB: 70,130,180)

		cUsaFore1 := "#FFFFFF" // Branco -  Personalizado(RGB: 255,255,255)
		cUsaFore2 := "#FFFFFF" // Branco -  Personalizado(RGB: 255,255,255)
		cUsaFore3 := "#FFFFFF" // Branco -  Personalizado(RGB: 255,255,255)

		cUsaBord1 := "#4682B4" // Azul Escuro -  Personalizado(RGB: 70,130,180)
		cUsaBord2 := "#4682B4" // Azul Escuro -  Personalizado(RGB: 70,130,180)
		cUsaBord3 := "#4682B4" // Azul Escuro -  Personalizado(RGB: 70,130,180)

	ElseIf nEstilo == nCSSTblEsp

		//----------------------------------------
		// Botão de Tabelas "em Espera"
		//----------------------------------------

		If nMV_Ident == 3 // Ambos
			cFontSize := "11" // Diminui a fonte para caber no botão
		EndIf

		cUsaBack1 := "#E9F0F6" // Azul Claro -  Personalizado(RGB: 233,240,246)
		cUsaBack2 := "#E9F0F6" // Azul Claro -  Personalizado(RGB: 233,240,246)
		cUsaBack3 := "#E9F0F6" // Azul Claro -  Personalizado(RGB: 233,240,246)

		cUsaFore1 := "#4682B4" // Azul Escuro -  Personalizado(RGB: 70,130,180)
		cUsaFore2 := "#4682B4" // Azul Escuro -  Personalizado(RGB: 255,255,255)
		cUsaFore3 := "#4682B4" // Azul Escuro -  Personalizado(RGB: 255,255,255)

		cUsaBord1 := "#B0C4DE" // LightSteelBlue
		cUsaBord2 := "#6495ED" // CornflowerBlue
		cUsaBord3 := "#4682B4" // SteelBlue

	ElseIf nEstilo == nCSSTblSel

		//----------------------------------------
		// Botão de Tabelas "Selecionado"
		//----------------------------------------

		If nMV_Ident == 3 // Ambos
			cFontSize := "11"
		EndIf

		cUsaBack1 := "#4682B4" // Azul Escuro -  Personalizado(RGB: 70,130,180)
		cUsaBack2 := "#4682B4" // Azul Escuro -  Personalizado(RGB: 70,130,180)
		cUsaBack3 := "#4682B4" // Azul Escuro -  Personalizado(RGB: 70,130,180)

		cUsaFore1 := "#FFFFFF" // Branco -  Personalizado(RGB: 255,255,255)
		cUsaFore2 := "#FFFFFF" // Branco -  Personalizado(RGB: 255,255,255)
		cUsaFore3 := "#FFFFFF" // Branco -  Personalizado(RGB: 255,255,255)

		cUsaBord1 := "#4682B4" // Azul Escuro -  Personalizado(RGB: 70,130,180)
		cUsaBord2 := "#4682B4" // Azul Escuro -  Personalizado(RGB: 70,130,180)
		cUsaBord3 := "#4682B4" // Azul Escuro -  Personalizado(RGB: 70,130,180)

	ElseIf nEstilo == nCSSRegEsp

		//----------------------------------------
		// Botão de Tabelas de Registros "em Espera"
		//----------------------------------------

		cBordRadius := "5"

		If "10" $ cVersao // Versão 10 do Protheus
			cUsaBack1 := "#F3F3F3" // Cinza Claro -  Personalizado(RGB: 243,243,243)
			cUsaBack2 := "#E6E6E6" // Cinza Claro -  Personalizado(RGB: 230,230,230)
			cUsaBack3 := "#E6E6E6" // Cinza Claro -  Personalizado(RGB: 230,230,230)

			cUsaFore1 := "#999999" // Cinza Escuro -  Personalizado(RGB: 153,153,153)
			cUsaFore2 := "#787878" // Cinza Escuro -  Personalizado(RGB: 120,120,120)
			cUsaFore3 := "#787878" // Cinza Escuro -  Personalizado(RGB: 120,120,120)

			cUsaBord1 := "#D3D3D3" // LightGray
			cUsaBord2 := "#BEBEBE" // Grey
			cUsaBord3 := "#828282" // Grey51
		Else // Versão 11 do Protheus
			cUsaBack1 := "#E9F0F6" // Azul Claro -  Personalizado(RGB: 233,240,246)
			cUsaBack2 := "#E9F0F6" // Azul Claro -  Personalizado(RGB: 233,240,246)
			cUsaBack3 := "#E9F0F6" // Azul Claro -  Personalizado(RGB: 233,240,246)

			cUsaFore1 := "#4682B4" // Azul Escuro -  Personalizado(RGB: 70,130,180)
			cUsaFore2 := "#4682B4" // Azul Escuro -  Personalizado(RGB: 255,255,255)
			cUsaFore3 := "#4682B4" // Azul Escuro -  Personalizado(RGB: 255,255,255)

			cUsaBord1 := "#B0C4DE" // LightSteelBlue
			cUsaBord2 := "#6495ED" // CornflowerBlue
			cUsaBord3 := "#4682B4" // SteelBlue
		EndIf

	ElseIf nEstilo == nCSSRegSel

		//----------------------------------------
		// Botão de Tabelas de Registros "Selecionado"
		//----------------------------------------

		cBordRadius := "5"

		If "10" $ cVersao // Versão 10 do Protheus
			cUsaBack1 := "#808080" // Cinza Escuro -  Personalizado(RGB: 128,128,128)
			cUsaBack2 := "#808080" // Cinza Escuro -  Personalizado(RGB: 128,128,128)
			cUsaBack3 := "#808080" // Cinza Escuro -  Personalizado(RGB: 128,128,128)

			cUsaFore1 := "#FFFFFF" // Branco -  Personalizado(RGB: 255,255,255)
			cUsaFore2 := "#FFFFFF" // Branco -  Personalizado(RGB: 255,255,255)
			cUsaFore3 := "#FFFFFF" // Branco -  Personalizado(RGB: 255,255,255)

			cUsaBord1 := "#808080" // Cinza Escuro -  Personalizado(RGB: 128,128,128)
			cUsaBord2 := "#808080" // Cinza Escuro -  Personalizado(RGB: 128,128,128)
			cUsaBord3 := "#808080" // Cinza Escuro -  Personalizado(RGB: 128,128,128)
		Else // Versão 11 do Protheus
			cUsaBack1 := "#4682B4" // Azul Escuro -  Personalizado(RGB: 70,130,180)
			cUsaBack2 := "#4682B4" // Azul Escuro -  Personalizado(RGB: 70,130,180)
			cUsaBack3 := "#4682B4" // Azul Escuro -  Personalizado(RGB: 70,130,180)

			cUsaFore1 := "#FFFFFF" // Branco -  Personalizado(RGB: 255,255,255)
			cUsaFore2 := "#FFFFFF" // Branco -  Personalizado(RGB: 255,255,255)
			cUsaFore3 := "#FFFFFF" // Branco -  Personalizado(RGB: 255,255,255)

			cUsaBord1 := "#4682B4" // Azul Escuro -  Personalizado(RGB: 70,130,180)
			cUsaBord2 := "#4682B4" // Azul Escuro -  Personalizado(RGB: 70,130,180)
			cUsaBord3 := "#4682B4" // Azul Escuro -  Personalizado(RGB: 70,130,180)
		EndIf

	ElseIf nEstilo == nCSSTipEsp

		//----------------------------------------
		// Botão de Tipo de Impressão "em Espera"
		//----------------------------------------

		cFontWeight := "normal"
		cFontAlign  := "padding-left: 10px; text-align: left; "
		cBordRadius := "0"

		cUsaBack1 := "#FFFFFF" // Branco
		cUsaBack2 := "#A4C0D2" // Azul Claro -  Personalizado(RGB: 164,192,210)
		cUsaBack3 := "#A4C0D2" // Azul Claro -  Personalizado(RGB: 164,192,210)

		cUsaGrad1 := cUsaBack1
		cUsaGrad2 := cUsaBack2
		cUsaGrad3 := cUsaBack3

		cUsaFore1 := "#004A77" // Azul Médio -  Personalizado(RGB: 0,74,119)
		cUsaFore2 := "#004A77" // Azul Médio -  Personalizado(RGB: 0,74,119)
		cUsaFore3 := "#004A77" // Azul Médio -  Personalizado(RGB: 0,74,119)

		cUsaBord1 := cUsaBack1
		cUsaBord2 := cUsaBack2
		cUsaBord3 := cUsaBack3

	ElseIf nEstilo == nCSSTipSel

		//----------------------------------------
		// Botão de Tipo de Impressão "Selecionado"
		//----------------------------------------

		cFontAlign := "padding-left: 10px; text-align: left; "
		cBordRadius := "0"

		cUsaBack1 := "#8AAEC5" // Azul Médio -  Personalizado(RGB: 138,174,197)
		cUsaBack2 := "#8AAEC5" // Azul Médio -  Personalizado(RGB: 138,174,197)
		cUsaBack3 := "#8AAEC5" // Azul Médio -  Personalizado(RGB: 138,174,197)

		cUsaGrad1 := cUsaBack1
		cUsaGrad2 := cUsaBack2
		cUsaGrad3 := cUsaBack3

		cUsaFore1 := "#FFFFFF" // Branco
		cUsaFore2 := "#FFFFFF" // Branco
		cUsaFore3 := "#FFFFFF" // Branco

		cUsaBord1 := cUsaBack1
		cUsaBord2 := cUsaBack2
		cUsaBord3 := cUsaBack3

	ElseIf nEstilo == nCSSLink

		//----------------------------------------
		// Botão de Link
		//----------------------------------------

		lUnderline := .T.

		cFontSize   := "11"
		cFontWeight := "normal"
		cFontAlign  := "padding-left: 1px; text-align: left; "
		cBordRadius := "0"

		cUsaBack1 := "#FFFFFF" // Branco
		cUsaBack2 := "#FFFFFF" // Branco
		cUsaBack3 := "#FFFFFF" // Branco

		cUsaGrad1 := cUsaBack1
		cUsaGrad2 := cUsaBack2
		cUsaGrad3 := cUsaBack3

		cUsaFore1 := "#5C5C5C" // Cinza
		cUsaFore2 := "#000000" // Preto
		cUsaFore3 := "#000000" // Preto

		cUsaBord1 := cUsaBack1
		cUsaBord2 := cUsaBack2
		cUsaBord3 := cUsaBack3

	ElseIf nEstilo == nCSSCarreg

		//----------------------------------------
		// Botão de Carregar alguma coisa
		//----------------------------------------

		cBordRadius := "2"

		cUsaBack1 := "#F5F5F5" // WhiteSmoke
		cUsaBack2 := "#E8E8E8" // Cinza Claro
		cUsaBack3 := "#E8E8E8" // Cinza Claro

		cUsaGrad1 := cUsaBack1
		cUsaGrad2 := cUsaBack2
		cUsaGrad3 := cUsaBack3

		cUsaFore1 := "#9C9C9C" // Cinza
		cUsaFore2 := "#000000" // Preto
		cUsaFore3 := "#000000" // Preto

		cUsaBord1 := "#D3D3D3" // LightGray
		cUsaBord2 := "#BEBEBE" // Grey
		cUsaBord3 := "#BEBEBE" // Grey

	EndIf

	//--------------------
	// Seta o CSS
	//--------------------
	// Famíla da Fonte
	If !Empty(cFontFamily)
		cFontFamily := "font-family: " + cFontFamily + "; "
	EndIf
	// Borda
	cAuxBord1 := "border: " + If(!Empty(cUsaBord1), "1px solid " + cUsaBord1, "0px") + "; "
	cAuxBord2 := "border: " + If(!Empty(cUsaBord2), "1px solid " + cUsaBord2, "0px") + "; "
	cAuxBord3 := "border: " + If(!Empty(cUsaBord3), "1px solid " + cUsaBord3, "0px") + "; "
	// Borda Arredondada
	If lRadiusTOP
		cAuxRadius := "border-top-left-radius: " + cBordRadius + "px; border-top-right-radius: " + cBordRadius + "px; "
	Else
		cAuxRadius := "border-radius: " + cBordRadius + "px; "
	EndIf
	// Seta o CSS
	oObjBtn:SetCSS("QPushButton{ background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1 stop: 0 " + cUsaGrad1 + ", stop: 0.4 " + cUsaBack1 + "); color: " + cUsaFore1 + "; " + cFontFamily + "font-size: " + cFontSize + "px; font-weight: " + cFontWeight + "; " + cFontAlign + cAuxBord1 + cAuxRadius + If(lUnderline, "text-decoration: underline;", "") + " } " + ;
					"QPushButton:Hover{ background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1 stop: 0 " + cUsaGrad2 + ", stop: 0.4 " + cUsaBack2 + "); color: " + cUsaFore2 + "; " + cAuxBord2 + If(lUnderline, "text-decoration: underline;", "") + " } " + ;
					"QPushButton:Pressed{ background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1 stop: 0 " + cUsaGrad3 + ", stop: 0.4 " + cUsaBack3 + "); color: " + cUsaFore3 + "; " + cAuxBord3 + If(lUnderline, "text-decoration: underline;", "") + " } ")

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fExecSplit
Executa o SPLIT (separador) entre painéis.

@author Wagner Sobral de Lacerda
@since 27/09/2012

@param nSplit
	Indica qual é o Split a executar * Obrigatório
	   0 - Separador da Barra de Ferramentas
	   1 - Separador das Variáveis
@param oButton
	Objeto do Botão do Split * Obrigatório

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fExecSplit(nSplit, oButton)

	//----------
	// Executa
	//----------
	If nSplit == 0 // Barra de Ferramentas
		If oToolbar:lVisible
			oToolbar:Hide()
			oButton:LoadBitmaps("fw_arrow_top")
			oButton:cTooltip := OemToAnsi(STR0044) //"Mostrar Variáveis"
		Else
			oToolbar:Show()
			oButton:LoadBitmaps("fw_arrow_down")
			oButton:cTooltip := OemToAnsi(STR0045) //"Esconder Variáveis"
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fExecReload
Executa o recarregamento (RELOAD) de um Painel.

@author Wagner Sobral de Lacerda
@since 27/09/2012

@param nPainel
	Indica qual é o Painel para recarregar * Obrigatório
	   1 - Parâmetros
	   2 - Dados (Tabelas)
	   3 - Registros

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fExecReload(nPainel)

	//----------
	// Executa
	//----------
	fSelectVar(, nPainel)

Return .T.

/*/
############################################################################################
##                                                                                        ##
## FUNÇÕES: FUNÇÕES PARA DADOS DA CONSULTA                                                ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} fProcConsul
Função para receber os dados da Consulta.
(Carrega Variáveis, Dados e Parâmetros)

@author Wagner Sobral de Lacerda
@since 24/09/2012

@return cComboBox
/*/
//---------------------------------------------------------------------
Static Function fProcConsul()

	// Salva áreas atuais
	Local aAreaSX3 := SX3->( GetArea() )
	Local aAreaTZ4 := TZ4->( GetArea() )
	Local aAreaTZF := TZF->( GetArea() )
	Local aAreaTZG := TZG->( GetArea() )
	Local aAreaTZI := TZI->( GetArea() )

	// Variáveis auxiliares
	Local cVariavel := ""
	Local cOrdem    := ""
	Local cTabela   := ""
	Local cCampo    := ""
	Local cCodigo   := ""
	Local cTipoDado := ""
	Local uConteudo := ""
	Local cTitulo   := ""
	Local cPicture  := ""
	Local nTamanho  := 0
	Local nDecimal  := 0
	Local aCBox     := {}, cCBox := ""

	Local nScan := 0

	//------------------------------
	// Processa DADOS
	//------------------------------
	aWinDados := {}

	dbSelectArea("TZF")
	dbSetOrder(1)
	dbSeek(xFilial("TZF",TZE->TZE_FILIAL) + TZE->TZE_CODIGO, .T.)
	While !Eof() .And. TZF->TZF_FILIAL == xFilial("TZF",TZE->TZE_FILIAL) .And. TZF->TZF_CODIGO == TZE->TZE_CODIGO

		cVariavel := TZF->TZF_VARIAV
		cOrdem    := TZF->TZF_SEQUEN
		cTabela   := TZF->TZF_TABELA
		cCampo    := TZF->TZF_CAMPO
		cTipoDado := TZF->TZF_TIPDAD
		uConteudo := NGI6CONVER(TZF->TZF_CONTEU,cTipoDado)
		cTitulo   := fNoChar(TZF->TZF_AUXTIT)
		cPicture  := TZF->TZF_AUXPIC
		nTamanho  := TZF->TZF_AUXTAM
		nDecimal  := TZF->TZF_AUXDEC
		cCBox     := TZF->TZF_AUXOPC
		If !Empty(cCBox)
			aCBox := StrTokArr(AllTrim(cCBox), ";")
			nScan := aScan(aCBox, {|x| SubStr(x,1,AT("=",x)-1) == AllTrim(uConteudo) })
			If nScan > 0
				uConteudo := aCBox[nScan]
				nTamanho := Len(uConteudo)
			EndIf
		EndIf

		// 1                 ; 2         ; 3      ; 4           ; 5      ; 6            ; 7        ; 8       ; 9       ; 10
		// Variável (Função) ; Sequência ; Tabela ; ID do Campo ; Título ; Tipo de Dado ; Conteúdo ; Picture ; Tamanho ; Decimal
		aAdd(aWinDados, {cVariavel, cOrdem, cTabela, cCampo, cTitulo, cTipoDado, uConteudo, cPicture, nTamanho, nDecimal})

		dbSelectArea("TZF")
		dbSkip()
	End

	// Ordena os parâmetros
	aSort(aWinDados, , , {|x,y| x[nDadVARIAV]+x[nDadSEQUEN]+x[nDadTABELA]+x[nDadCAMPO] < y[nDadVARIAV]+y[nDadSEQUEN]+y[nDadTABELA]+y[nDadCAMPO] })

	//------------------------------
	// Processa PARÂMETROS
	//------------------------------
	aWinParams := {}

	dbSelectArea("TZG")
	dbSetOrder(1)
	dbSeek(xFilial("TZG",TZE->TZE_FILIAL) + TZE->TZE_CODIGO, .T.)
	While !Eof() .And. TZG->TZG_FILIAL == xFilial("TZG",TZE->TZE_FILIAL) .And. TZG->TZG_CODIGO == TZE->TZE_CODIGO

		cVariavel := TZG->TZG_VARIAV
		cOrdem    := TZG->TZG_ORDEM
		cCodigo   := TZG->TZG_PARAM
		cTipoDado := TZG->TZG_TIPDAD
		uConteudo := NGI6CONVER(TZG->TZG_CONTEU,cTipoDado)
		cTitulo   := fNoChar(TZG->TZG_AUXTIT)
		cPicture  := TZG->TZG_AUXPIC
		nTamanho  := TZG->TZG_AUXTAM
		nDecimal  := TZG->TZG_AUXDEC
		cCBox     := TZG->TZG_AUXOPC
		If !Empty(cCBox)
			aCBox := StrTokArr(AllTrim(cCBox), ";")
			nScan := aScan(aCBox, {|x| SubStr(x,1,AT("=",x)-1) == AllTrim(uConteudo) })
			If nScan > 0
				uConteudo := aCBox[nScan]
				nTamanho := Len(uConteudo)
			EndIf
		EndIf

		// 1                 ; 2         ; 3                   ; 4      ; 5            ; 6        ; 7       ; 8       ; 9
		// Variável (Função) ; Sequência ; Código do Parâmetro ; Título ; Tipo de Dado ; Conteúdo ; Picture ; Tamanho ; Decimal
		aAdd(aWinParams, {cVariavel, cOrdem, cCodigo, cTitulo, cTipoDado, uConteudo, cPicture, nTamanho, nDecimal})

		dbSelectArea("TZG")
		dbSkip()
	End

	// Ordena os parâmetros
	aSort(aWinParams, , , {|x,y| x[nParVARIAV]+x[nParORDEM] < y[nParVARIAV]+y[nParORDEM] })

	//------------------------------
	// Processa DADOS
	//------------------------------
	aWinVariav := {}

	// Agrupa as Variáveis
	dbSelectArea("TZI")
	dbSetOrder(1)
	dbSeek(xFilial("TZI",TZE->TZE_FILIAL) + TZE->TZE_CODIGO)
	While !Eof() .And. TZI->TZI_FILIAL == xFilial("TZI",TZE->TZE_FILIAL) .And. TZI->TZI_CODIGO == TZE->TZE_CODIGO
		If aScan(aWinVariav, {|x| x[nVarVARIAV] == TZI->TZI_VARIAV }) == 0
			aAdd(aWinVariav, {TZI->TZI_VARIAV, fNoChar(TZI->TZI_VARNOM), TZI->TZI_RESULT})
		EndIf
		dbSelectArea("TZI")
		dbSkip()
	End

	// Devolve as Áreas
	RestArea(aAreaSX3)
	RestArea(aAreaTZ4)
	RestArea(aAreaTZF)
	RestArea(aAreaTZG)
	RestArea(aAreaTZI)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fNoChar
Função para retirar as aspas de uma string.

@author Wagner Sobral de Lacerda
@since 02/01/2013

@param cString
	String para ser avaliada * Obrigatório

@return cRetStr
/*/
//---------------------------------------------------------------------
Static Function fNoChar(cString)

	// Variável do Retorno
	Local cRetStr := cString

	// Converte
	cRetStr := StrTran(cRetStr, "'", "")
	cRetStr := StrTran(cRetStr, '"', "")

Return cRetStr

//---------------------------------------------------------------------
/*/{Protheus.doc} fReport
Função para Imprimir a Consulta.

@author Wagner Sobral de Lacerda
@since 31/10/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fReport()

	// Mostra Painel Preto
	fBlackPnl(.T.)

	// Chamada rotina de Impressão
	NGIND011(TZE->TZE_FILIAL, TZE->TZE_CODIGO)

	// Esconde Painel Preto
	fBlackPnl(.F.)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fAtuDados
Atualiza as tabelas de dados

@author Bruno Lobo de Souza
@since 21/05/2015

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fAtuDados()

	Local aGetDados	:= fGetDados()
	Local aAuxDads	:= {}

	//variaveis de contador (For)
	Local nVar := 0, nDad := 0

	Local cTitulo  := ""
	Local cAction  := ""
	Local cHint    := ""

	// Monta os Dados (tabelas)
	aBtnDados := {}
	If Len(aGetDados) <> 0
		For nVar := 1 To Len(aGetDados)
			aAdd(aBtnDados, {aGetDados[nVar][1], {}}) // 1=Código da Variável ; 2=Objetos de Botões
			aAuxDads := aClone(aGetDados[nVar][3])
			For nDad := 1 To Len(aAuxDads)
				aAdd(aBtnDados[nVar][2], Array(3)) // 1=Objeto do Botão ; 2=Estado do Botão ; 3=Código da Tabela
				If nMV_Ident == 1 // Código da Tabela
					cTitulo := "'" + AllTrim(aAuxDads[nDad][1]) + "'"
					cHint   := "'" + AllTrim(aAuxDads[nDad][2]) + "'"
				ElseIf nMV_Ident == 2 // Nome da Tabela
					cTitulo := "'" + AllTrim(aAuxDads[nDad][2]) + "'"
					cHint   := "'" + AllTrim(aAuxDads[nDad][1]) + "'"
				ElseIf nMV_Ident == 3 // Ambos
					cTitulo := "'" + AllTrim(aAuxDads[nDad][1]) + " (" + AllTrim(aAuxDads[nDad][2]) + ")'"
					cHint   := cTitulo
				EndIf
				cAction := "{|| fSelectTbl('" + aGetDados[nVar][1] + "', '" + aAuxDads[nDad][1] + "') }"
				aBtnDados[nVar][2][nDad][nBDaOBJETO] := TButton():New(0, 0, &(cTitulo), /*oScroll*/, &(cAction),;
						  										0, 0, , , .F., .T., .F., , .F., , , .F.)
				aBtnDados[nVar][2][nDad][nBDaOBJETO]:lCanGotFocus := .F.
				aBtnDados[nVar][2][nDad][nBDaOBJETO]:cTooltip := &(cHint)
				aBtnDados[nVar][2][nDad][nBDaTABELA] := aAuxDads[nDad][1]
			Next nDad
		Next Var
	EndIf

	// Inicializa as tabelas selecionadas
	If !IsInCallStack(Upper("fExecReload"))
		fSelectTbl(If(lMV_Selec .And. lMontando,"ALL",Nil), If(lMV_Selec .And. lMontando,"ALL",Nil))
	EndIf

	Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fAtuVar
Atualiza as variaveis do indicador selecionado

@author Bruno Lobo de Souza
@since 21/05/2015

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fAtuVar()

	Local aVariaveis := aClone(aWinVariav)
	Local nVar := 0

	aBtnVariav := {}
	For nVar := 1 To Len(aVariaveis)
		aAdd(aBtnVariav, Array(3)) // 1=Objeto do Botão ; 2=Estado do Botão ; 3=Código da Variável
		aBtnVariav[nVar][nBVaVARIAV] := aVariaveis[nVar][nVarVARIAV]
	Next nVar

	Return .T.
