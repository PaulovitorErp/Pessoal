#INCLUDE "MNTC400.ch"
#INCLUDE "PROTHEUS.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC400
Consulta Gerencial de M„o-de-Obra.

@author Vitor Emanuel Batista
@since	01/09/2009
/*/
//---------------------------------------------------------------------
Function MNTC400()

	Local aNGBeginPrm := {}
	Local oDlg, oPnlCab, oPnlBtn1, oPnlBtn2, oPnlCen, oPnlRod

	Local aButton := {{"DESTINOS" 	  ,{|| oSplitter:SetOrient(If(nOrientation == 0,nOrientation := 1,nOrientation := 0)) },STR0162,STR0163}}//"Inverter PosiÁ„o"###"Inverter"
	Local oFont12 := TFont():New("Arial",,18,.T.,.T.)

	//Variaveis que controla justificacao de objetos
	Local nLargMDI := 0
	Local nAltMDI  := 0
	Local nAltura  := 0
	Local nLargura := 0

	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 19, 95 )

		aNGBeginPrm := NGBeginPrm( , , , , .T. )
		nAltura     := ( GetScreenRes()[2] - 85 )
		nLargura    := ( GetScreenRes()[1] - 7 )

		Private oPnlBrow1, oPnlBrow2
		Private oOK   := LoadBitmap(GetResources(),'br_verde')
		Private oNO   := LoadBitmap(GetResources(),'br_vermelho')
		Private lDetalhado := .F.
		Private nP         := 0

		//Botoes para geracao do grafico---Alterados para private para utilizaÁ„o de hide/show
		Private oBtnHoras1, oBtnCusto1 //Botoes do primeiro menu
		Private oBtnHoras2, oBtnCusto2 //Botoes do segundo menu
		Private oBtnRela1 //Botoes do primeiro menu
		Private oBtnRela2 //Botoes do segundo menu
		Private oBtnVoltar
		//Vari·veis de pesquisa
		Private oTpAnalise
		Private oPeriodo
		Private oVisualiz
		Private oTpCusto
		Private oVisualiDe
		Private oVisualiAte
		Private oTpAnaliDe
		//Vari·veis de botıes
		Private oNovaCons
		Private oGeraCons

		//Ociosidade
		Private oBrowseRO1, oBrowseCO1, oBrowsDRO1, oBrowsDCO1
		Private oBrowseRO2, oBrowseCO2, oBrowsDRO2, oBrowsDCO2
		Private oBrowseRO3, oBrowseCO3, oBrowsDRO3, oBrowsDCO3
		//Eficiencia
		Private oBrowseRE1, oBrowseCE1, oBrowsDRE1, oBrowsDCE1
		Private oBrowseRE2, oBrowseCE2, oBrowsDRE2, oBrowsDCE2
		Private oBrowseRE3, oBrowseCE3, oBrowsDRE3, oBrowsDCE3
		//Distribuicao
		Private oBrowseRD1, oBrowseCD1, oBrowsDRD1, oBrowsDCD1
		Private oBrowseRD2, oBrowseCD2, oBrowsDRD2, oBrowsDCD2
		Private oBrowseRD3, oBrowseCD3, oBrowsDRD3, oBrowsDCD3
		Private oBrowseRU1, oBrowseCU1, oBrowsDRU1, oBrowsDCU1
		Private oBrowseRU2, oBrowseCU2, oBrowsDRU2, oBrowsDCU2
		Private oBrowseRU3, oBrowseCU3, oBrowsDRU3, oBrowsDCU3
		Private oBrowsePai, oBrowseFil

		Private oCabSup1, oCabSup2, oCabInf1, oCabInf2
		Private lGerarCons  := .F.
		Private lPcthrex    := (NGCADICBASE("TL_PCTHREX","A","STL",.F.) .And. NGCADICBASE("TT_PCTHREX","A","STT",.F.))
		Private lDuploClick := .F.
		Private cCCDuplo    := ""
		Private cEspDuplo   := ""
		Private cCCFDuplo   := ""
		Private cMatDuplo   := ""
		Private cPrioDuplo  := ""
		Private cOrdeDuplo  := ""
		Private cPerDuplo   := ""
		Private cOldF3      := ""
		Private cChavePai   := ""

		//--- PRIMEIRA LINHA
		//Combo de Tipo de Analise
		Private aTpAnalise := {"O="+STR0003,"E="+STR0004,"D="+STR0005,"U="+STR0006} //"Ociosidade"###"EficiÍncia"###"DistribuiÁ„o"###"UtilizaÁ„o"
		Private cTpAnalise := "O", cTpAnalOld := "O"
		Private dTpAnaliDe := CTOD("  /  /  ")
		Private dTpAnaliAte:= CTOD("  /  /  ")

		//Combo do PerÌodo
		Private aPeriodo := {"U="+STR0007,"D="+STR0008} //"⁄nico"###"Detalhado"
		Private cPerCons := "U"
		//--- FIM PRIMEIRA LINHA

		//--- SEGUNDA LINHA
		//Combo de Visualizar por
		Private aVisualiz  := {"C="+STR0009,"E="+STR0010,"F="+STR0011} //"Centro de Custo"###"Especialidade"###"Funcion·rio"
		Private cVisualiz  := "C", cOLDVisual := "C"

		//Descricao dos Graficos
		Private cGrafDesc1  := ""
		Private cGrafDesc2  := ""
		Private aGrafico400 := {}

		//Campos Data do Visualizar
		Private cVisualiDe := Space(6)
		Private cVisualiAte:= Space(6)
		Private aTrocaF3 := {}

		Private aColsInfer := {}
		Private aColsCab   := {}
		Private aColsRod   := {}
		Private aColsFunci := {}
		Private aPosEspCal := {}
		Private aTurnoST1  := {}
		Private aFunxEspe  := {}
		Private aFunxHras  := {}
		Private aEspecHora := {}
		Private aColsOSxFu := {}
		Private aColsRel   := {}
		Private aMesAno    := {}

		Private aTpCusto  := {"M="+STR0012,"S="+STR0013} //"MÈdio"###"Standard"
		Private cTpCusto  := "M"
		//--- FIM SEGUNDA LINHA

		//Variaveis de Total (Im)Produtivas
		Private nTotProd1 := 0
		Private nTotImp1  := 0

		Private nTotProd2 := 0
		Private nTotImp2  := 0

		//Numero do acesso (Clique nos TcBrowse)
		Private nAcesso    := 0
		Private nAcessoGC  := 0
		Private cDescMDO   := ""
		Private cCadastro  := OemToAnsi(STR0014)  //"Gerencial de M„o de Obra"
		Private aHeader1   := {}
		Private aHeader2   := {}
		Private aCols1     := {}
		Private aCols2     := {}
		Private aOldHeader := {{{},{}},{{},{}},{{},{}}}
		Private aOldCols   := {{{},{},{}},{{},{},{}},{{},{},{}},{{},{},{}},{{},{},{}},{{},{},{}},{{},{},{}},{{},{},{}}}
		Private lCCFun     := .F.
		Private lValWhen   := .F.
		Private aColsUp	   := {}
		Private aColsDown  := {}

		Private oFont14B    := TFont():New("Arial",,14,.T.,.T.)
		Private nMV_TpHr    := Alltrim(GetMv("MV_NGUNIDT"))
		Private lCpoTrab    := .F.
		Private lCpoFamB    := .F.
		Private lCpoTipM    := .F.
		Private lCpoAreM    := .F.
		Private lCpoServ    := .F.
		Private lCpoOrde    := .F.
		Private lCpoPlan    := .F.
		Private lCpoTT2Dt   := .F.
		Private lCpoVerOs   := .F.
		Private lCpoEvent   := .F.
		Private lTurnoFlut  := Alltrim(SuperGetMv("MV_NGFLUT",.F.,"-1")) == "S"
		Private lRelease12  := NGCADICBASE("TJ_STFOLUP","A","STJ",.F.)
		Private lVoltaNivel := .F.
		Private lNovaCons	:= .F.
		Private lPrimeira   := .T.

		#IFNDEF TOP
			Final(STR0156) //"Esta rotina n„o esta homologada para ambiente em CodeBase!"
		#ENDIF

		SetVisual()

		//Indica a orientacao do Splitter
		nOrientation := 1

		DEFINE DIALOG oDlg FROM 120,0 To nAltura,nLargura TITLE cCadastro Of oMainWnd COLOR CLR_BLACK,CLR_WHITE Pixel

			oDlg:lMaximized := .T.
			oDlg:lEscClose  := .F.

			//Justifica GetDados e MsSelect de acordo com o Tema
			If PtGetTheme() = "MDI"
				nLargMDI := 10
				nAltMDI  := 20
			EndIf

			oPnlAllCl       := TPanel():New(0,0,,oDlg,,,,,,,,.F.,.F.)
			oPnlAllCl:Align := CONTROL_ALIGN_ALLCLIENT

			nAltCab       := 60
			nAltPnl       := nAltura/2 - nAltMDI - nAltCab - 40
			oPnlCab       := TPanel():New(0,0,,oPnlAllCl,,,,,,nLargura/4,nAltCab,.F.,.F.)
			oPnlCab:Align := CONTROL_ALIGN_TOP

			//---- PRIMEIRA LINHA
			@ 001,015 Say Oemtoansi(STR0015) Of oPnlCab Pixel FONT oFont12 //"Tipo de An·lise:"
			@ 011,015 Combobox oTpAnalise Var cTpAnalise Items aTpAnalise Size 65,50 Of oPnlCab Pixel VALID NaoVazio(cTpAnalise) ON CHANGE ChangeVisual(oVisualiz,.T.)

			@ 001,085 Say Oemtoansi(STR0016) Of oPnlCab Pixel FONT oFont12 //"Pesquisar entre:"
			@ 013,085 MsGet oTpAnaliDe Var dTpAnaliDe  Of oPnlCab Valid If(Empty(dTpAnaliAte),.T.,VALDATA(dTpAnaliDe,dTpAnaliAte,"DATAMAIOR")) Picture '99/99/9999' Size 50,08 HASBUTTON Pixel

			@ 015,140 Say Oemtoansi(STR0017) Of oPnlCab Pixel //"AtÈ"
			@ 013,155 MsGet oTpAnaliAte Var dTpAnaliAte Of oPnlCab Valid If(Empty(dTpAnaliAte),.T.,VALDATA(dTpAnaliDe,dTpAnaliAte,"DATAMENOR")) Picture '99/99/9999' Size 50,08 HASBUTTON Pixel

			@ 001,210 Say Oemtoansi(STR0018) Of oPnlCab Pixel FONT oFont12 //"PerÌodo:"
			@ 011,210 Combobox oPeriodo Var cPerCons Items aPeriodo Size 50,50 Of oPnlCab Pixel VALID NaoVazio(cPerCons) ON CHANGE ChangeVisual(oVisualiz,.F.)

			oNovaCons := TButton():New( 020, 280, STR0173,oPnlCab,,40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Nova COnsulta"
			oNovaCons:bAction := {|| NovaConsulta() }
			oNovaCons:Disable()
			//---- FIM PRIMEIRA LINHA

			//---- SEGUNDA LINHA
			@ 030,015 Say Oemtoansi(STR0019) Of oPnlCab Pixel FONT oFont12 //"Visualizar por:"
			@ 040,015 Combobox oVisualiz Var cVisualiz Items aVisualiz Size 65,50 Of oPnlCab Pixel VALID NaoVazio(cVisualiz) ON CHANGE LimpaDeAte()

			@ 033,085 Say Oemtoansi(STR0016) Of oPnlCab Pixel FONT oFont12 //"Pesquisar entre:"
			@ 043,085 MsGet oVisualiDe Var cVisualiDe  Of oPnlCab Valid NGValid400(1) Picture '@!' Size 50,08 HASBUTTON F3 "CTT" WHEN NGTrocaF3() Pixel

			@ 045,140 Say Oemtoansi(STR0017) Of oPnlCab Pixel //"AtÈ"
			@ 043,155 MsGet oVisualiAte Var cVisualiAte Of oPnlCab Valid NGValid400(2) Picture '@!' Size 50,08 HASBUTTON F3 "CTT" WHEN NGTrocaF3() Pixel

			cVisualiAte := 'ZZZZZZ'
			@ 030,210 Say Oemtoansi(STR0020) Of oPnlCab Pixel FONT oFont12 //"Tipo de Custo:"
			@ 040,210 Combobox oTpCusto Var cTpCusto Items aTpCusto Size 50,50 Of oPnlCab Pixel VALID NaoVazio(cTpCusto) //ON CHANGE

			oGeraCons := TButton():New( 035, 280, STR0021,oPnlCab,,40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Gerar Consulta"
			oGeraCons:bAction := {|| GerarConsulta() }
			//---- FIM SEGUNDA LINHA

			//Cria Splitter na horizontal
			oSplitter       := tSplitter():New( 01,01,oPnlAllCl,260,184,nOrientation)
			oSplitter:Align := CONTROL_ALIGN_ALLCLIENT
			oSplitter:SetChildCollapse(.F.)

			oPnlCen := TPanel():New(0,0,,oSplitter,,,,,,nLargura/4,nAltPnl*0.5,.F.,.F.)
			oPnlCen:Align := CONTROL_ALIGN_TOP

			//Menu lateral esquerdo
			oPnlBtn1 := TPanel():New(0,0,,oPnlCen,,,,,RGB(67,70,87),13,0,.F.,.F.)
			oPnlBtn1:Align := CONTROL_ALIGN_LEFT

			oBtnHoras1  := TBtnBmp():NewBar("ng_icografhora2","ng_icografhora2",,,,{|| Grafico400(1,'S')},,oPnlBtn1)
			oBtnHoras1:cToolTip := STR0022 //"Gr·fico de Horas"
			oBtnHoras1:Align    := CONTROL_ALIGN_TOP
			oBtnHoras1:Disable()

			oBtnCusto1  := TBtnBmp():NewBar("ng_icografcusto","ng_icografcusto",,,,{|| Grafico400(2,'S') },,oPnlBtn1)
			oBtnCusto1:cToolTip := STR0023 //"Gr·fico de Custo"
			oBtnCusto1:Align    := CONTROL_ALIGN_TOP
			oBtnCusto1:Disable()

			oBtnRela1  := TBtnBmp():NewBar("ng_ico_imp","ng_ico_imp",,,,{||RelatoC400(1)},,oPnlBtn1)
			oBtnRela1:cToolTip := STR0024 //"RelatÛrio"
			oBtnRela1:Align    := CONTROL_ALIGN_TOP
			oBtnRela1:Disable()

			oBtnVoltar  := TBtnBmp():NewBar("ng_ico_voltaniv","ng_ico_voltaniv",,,,{|| VoltaNivel()},,oPnlBtn1)
			oBtnVoltar:cToolTip := "Retorna NÌvel"
			oBtnVoltar:Align    := CONTROL_ALIGN_TOP
			oBtnVoltar:Disable()

			oPnlBrow1       := TPanel():New(0,0,,oPnlCen,,,,,,,,.F.,.F.)
			oPnlBrow1:Align := CONTROL_ALIGN_ALLCLIENT

			//Cria Browse Central
			CriaBrowse(1,@oPnlBrow1,@oBrowseCO1)

			//Cria Rodape Central
			oPnlCenRod := TPanel():New(0,0,,oPnlBrow1,,,,,RGB(67,70,87),,10,.F.,.F.)
			oPnlCenRod:Align := CONTROL_ALIGN_BOTTOM

			//Cria Total (Im)Produtivas
			CriaRodape("","",oPnlCenRod,1)

			oPnlRod       := TPanel():New(0,0,,oSplitter,,,,,,nLargura/4,nAltPnl*0.5,.F.,.F.)
			oPnlRod:Align := CONTROL_ALIGN_ALLCLIENT

			//Menu lateral esquerdo
			oPnlBtn2 := TPanel():New(0,0,,oPnlRod,,,,,RGB(67,70,87),13,0,.F.,.F.)
			oPnlBtn2:Align := CONTROL_ALIGN_LEFT

			oBtnHoras2  := TBtnBmp():NewBar("ng_icografhora2","ng_icografhora2",,,,{|| Grafico400(1,'I')},,oPnlBtn2)
			oBtnHoras2:cToolTip := STR0022 //"Gr·fico de Horas"
			oBtnHoras2:Align    := CONTROL_ALIGN_TOP
			oBtnHoras2:Disable()

			oBtnCusto2  := TBtnBmp():NewBar("ng_icografcusto","ng_icografcusto",,,,{|| Grafico400(2,'I') },,oPnlBtn2)
			oBtnCusto2:cToolTip := STR0023 //"Gr·fico de Custo"
			oBtnCusto2:Align    := CONTROL_ALIGN_TOP
			oBtnCusto2:Disable()

			oBtnRela2  := TBtnBmp():NewBar("ng_ico_imp","ng_ico_imp",,,,{||RelatoC400(2)},,oPnlBtn2)
			oBtnRela2:cToolTip := STR0024 //"RelatÛrio"
			oBtnRela2:Align    := CONTROL_ALIGN_TOP
			oBtnRela2:Disable()

			oPnlBrow2       := TPanel():New(0,0,,oPnlRod,,,,,,,,.F.,.F.)
			oPnlBrow2:Align := CONTROL_ALIGN_ALLCLIENT

			//Cria Browse do Rodape
			CriaBrowse(2,@oPnlBrow2,@oBrowseRO1,@oBrowseCO1)

			oPnlRodRod       := TPanel():New(0,0,,oPnlBrow2,,,,,RGB(67,70,87),,10,.F.,.F.)
			oPnlRodRod:Align := CONTROL_ALIGN_BOTTOM

			CriaRodape("","",oPnlRodRod,2)

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(@oDlg,{||nOpc :=2,If(.T.,oDlg:End(),nOpc :=1)},{||nOpc := 1,oDlg:End()},,aButton)

		NGReturnPrm( aNGBeginPrm )

	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} CriaBrowse
Cria TCBrowse dependendo dos parametros informados no cabec.

Par‚metros:
nBrowse - 1 Centro / 2 Rodape
oPanel  - Painel onde o Browse estara
oBrowse - Objeto Browse em referencia

@author Vitor Emanuel Batista
@since	02/09/2009
/*/
//---------------------------------------------------------------------
Static Function CriaBrowse(nBrowse,oPanel,_oBrowse,_oBrowsePai)
Local aColumm := {}
Local nX := 1

	//Coloca o Ponteiro do Mouse em Estado de Espera
CursorWait()

aInfoBrw := RetInfoBrw(nBrowse)
If nBrowse == 1 //Browse do Centro

    // Cria Browse
	If ValType(_oBrowse) != "O"
		_oBrowse := TCBrowse():New( 0 , 0, 260 , 156 ,,,,oPanel,,,,,{||},,,,,,,.F.,,.F.,,.F.,,, )
		_oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

		aColumm := aInfoBrw[2]
		For nX := 1 to Len(aColumm)
				If Empty(aColumm[nX][1])
				_oBrowse:AddColumn(TCColumn():New(" ",{|| If( _oBrowse:aArray[_oBrowse:nAt,1], oOK , oNO )},;
            nil,nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))
			Else
				_oBrowse:AddColumn(TCColumn():New(aColumm[nX][1],&("{|| If(Len(_oBrowse:aArray) >= _oBrowse:nAt,_oBrowse:aArray[_oBrowse:nAt,"+cValToChar(nX)+"],'') }"),aColumm[nX][4],,,aColumm[nX][3],aColumm[nX][2],.F.,.F.,,,,.F.))
			Endif
		Next nX
	Endif

		If cTpAnalise == 'U' .And. nAcesso == 1
		If lDetalhado
			aColsCab := aSort(aColsCab,,,{|x,y| x[1]+x[2]+x[5] < y[1]+y[2]+y[5]})
		Else
			aColsCab := aSort(aColsCab,,,{|x,y| x[1]+x[4] < y[1]+y[4]})
		Endif
	Else
		If Type('aColsCab[1][1]') == 'L'
			If lDetalhado
				aColsCab := aSort(aColsCab,,,{|x,y| x[2]+x[3] < y[2]+y[3]})
			Else
				aColsCab := aSort(aColsCab,,,{|x,y| x[2] < y[2]})
			Endif
		Else
			If lDetalhado
				aColsCab := aSort(aColsCab,,,{|x,y| x[1]+x[2] < y[1]+y[2]})
			Else
				aColsCab := aSort(aColsCab,,,{|x,y| x[1] < y[1]})
			Endif
		Endif
	Endif

	If Len(aColsCab) < 1
	 	aColsCab := fBlankArray(_oBrowse:aColumns)
	Endif

	_oBrowse:SetArray(aColsCab) // Seta vetor para a browse

ElseIf nBrowse == 2 //Browse do Rodape

    // Cria Browse
	If ValType(_oBrowse) != "O"
		_oBrowse := TCBrowse():New( 0 , 0, 260 , 156 ,,,,oPanel,,,,,{||},,,,,,,.F.,,.F.,,.F.,,, )
		_oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		_oBrowse:bLDblClick   := {|| DuploClick() }

			_oBrowsePai:bChange      := {|| MudaInferior(@_oBrowsePai,@_oBrowse,.F.) }

		aColumm := aInfoBrw[2]
		For nX := 1 to Len(aColumm)
				If Empty(aColumm[nX][1])
				_oBrowse:AddColumn(TCColumn():New(" ",{|| If( _oBrowse:aArray[_oBrowse:nAt,1], oOK , oNO )},;
            nil,nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))
			Else
				_oBrowse:AddColumn(TCColumn():New(aColumm[nX][1],&("{|| If(Len(_oBrowse:aArray) >= _oBrowse:nAt,_oBrowse:aArray[_oBrowse:nAt,"+cValToChar(nX)+"],'') }"),aColumm[nX][4],,,aColumm[nX][3],aColumm[nX][2],.F.,.F.,,,,.F.))
			Endif
		Next nX
	Endif
	If Len(aColsRod) < 1
		aColsRod := fBlankArray(_oBrowse:aColumns)
	Endif
	_oBrowse:SetArray(aColsRod) // Seta vetor para a browse

EndIf

_oBrowse:nScrollType := 1

	//Restaura o Estado do Cursor
CursorArrow()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} RetInfoBrw
Retorna array contendo aCols e aHeader para o TCBrowse

Parametros:
nBrowse  - Indica o Browse a ser retornado informacoes
nAcesso  - Numero do acesso (Clique nos TcBrowse)   Def. 0

@author Vitor Emanuel Batista
@since	19/02/2009
/*/
//---------------------------------------------------------------------

Static Function RetInfoBrw(nBrowse)
	Local aInfoBrw := Array(2,0)
	Private _cGetDB := TcGetDb()
	Default nAcesso := 0

	lDetalhado := .F.
	nP := 0

	If cTpAnalise == "D" .And. ((nBrowse == 2 .And. (nAcesso == 1)) .Or. (nBrowse == 1 .And. nAcesso == 2)) //Legenda
		aAdd(aInfoBrw[2],{' ',10,"LEFT",})
	Endif

	If cPerCons == "D" //Detalhado
		If cVisualiz != "I" //Se Visualizar for diferente de Periodo
			aAdd(aInfoBrw[2],{STR0025,40,"LEFT",}) //"PerÌodo"
			lDetalhado := .T.
			nP := 1
		EndIf
	EndIf

	If nBrowse == 1
		cDescMDO := ""
		If cTpAnalise = "O" //Ociosidade
			If nAcesso == 0 //Por Centro de Custo
				aAdd(aInfoBrw[2],{STR0026,45,"LEFT",}) //"Centro Custo"
				aAdd(aInfoBrw[2],{STR0027,170,"LEFT",}) //"Nome"
				aAdd(aInfoBrw[2],{STR0028,35,"RIGHT",}) //"Hrs. Produt."
				aAdd(aInfoBrw[2],{STR0029,50,"RIGHT","@E 999,999,999.99"}) //"Valor"
				aAdd(aInfoBrw[2],{"%",20,"RIGHT","@E 9999.99"})
				aAdd(aInfoBrw[2],{STR0030,35,"RIGHT",}) //"Hrs. Improd."
				aAdd(aInfoBrw[2],{STR0029,50,"RIGHT","@E 999,999,999.99"}) //"Valor"
				aAdd(aInfoBrw[2],{"%",20,"RIGHT","@E 9999.99"})
				aAdd(aInfoBrw[2],{STR0031,40,"RIGHT",}) //"Total Horas"
				aAdd(aInfoBrw[2],{STR0032,40,"RIGHT",}) //"Hrs. Dispon."
				aAdd(aInfoBrw[2],{STR0033,40,"RIGHT",}) //"Hrs. N„o Repor."
				cDescMDO := 'OxCC'
				If lGerarCons
					OciosidxCC()
				Endif
				cGrafDesc1 := STR0034 //"Ociosidade x Centro de Custo"
			ElseIf nAcesso == 1 //Por Especialidade
				aAdd(aInfoBrw[2],{STR0010,55,"LEFT",}) //"Especialidade"
				aAdd(aInfoBrw[2],{STR0027,170,"LEFT",}) //"Nome"
				aAdd(aInfoBrw[2],{STR0035,45,"RIGHT",}) //"Quant. Func."
				aAdd(aInfoBrw[2],{STR0028,35,"RIGHT",}) //"Hrs. Produt."
				aAdd(aInfoBrw[2],{STR0029,50,"RIGHT","@E 999,999,999.99"}) //"Valor"
				aAdd(aInfoBrw[2],{"%",20,"RIGHT","@E 9999.99"})
				aAdd(aInfoBrw[2],{STR0030,35,"RIGHT",}) //"Hrs. Improd."
				aAdd(aInfoBrw[2],{STR0029,50,"RIGHT","@E 999,999,999.99"}) //"Valor"
				aAdd(aInfoBrw[2],{"%",20,"RIGHT","@E 9999.99"})
				aAdd(aInfoBrw[2],{STR0031,40,"RIGHT",}) //"Total Horas"
				aAdd(aInfoBrw[2],{STR0032,40,"RIGHT",}) //"Hrs. Dispon."
				aAdd(aInfoBrw[2],{STR0033,40,"RIGHT",}) //"Hrs. N„o Repor."
				If lGerarCons
					OciosidxEs()
				Endif
				cGrafDesc1 := STR0036 //"Ociosidade x Especialidade"
				cDescMDO := 'OxES'
			ElseIf nAcesso == 2 //Por Funcionario
				aAdd(aInfoBrw[2],{STR0037,40,"LEFT",}) //"MatrÌcula"
				aAdd(aInfoBrw[2],{STR0027,170,"LEFT",}) //"Nome"
				aAdd(aInfoBrw[2],{STR0028,35,"RIGHT",}) //"Hrs. Produt."
				aAdd(aInfoBrw[2],{"%",20,"RIGHT","@E 9999.99"})
				aAdd(aInfoBrw[2],{STR0030,35,"RIGHT",}) //"Hrs. Improd."
				aAdd(aInfoBrw[2],{"%",20,"RIGHT","@E 9999.99"})
				aAdd(aInfoBrw[2],{STR0031,40,"RIGHT",}) //"Total Horas"
				aAdd(aInfoBrw[2],{STR0032,40,"RIGHT",}) //"Hrs. Dispon."
				aAdd(aInfoBrw[2],{STR0033,40,"RIGHT",}) //"Hrs. N„o Repor."
				If lGerarCons
					OciosidxFu()
				Endif
				cGrafDesc1 := STR0038 //"Ociosidade x Funcion·rio"
				cDescMDO := 'OxFU'
			EndIf
		ElseIf cTpAnalise = "U" //Utilizacao
			If nAcesso == 0 //Por Centro de Custo
				aAdd(aInfoBrw[2],{STR0026,45,"LEFT",}) //"Centro Custo"
				aAdd(aInfoBrw[2],{STR0027,170,"LEFT",}) //"Nome"
				aAdd(aInfoBrw[2],{STR0039,64,"RIGHT",}) //"Hrs. Preventivas"
				aAdd(aInfoBrw[2],{STR0029,50,"RIGHT","@E 999,999,999.99"}) //"Valor"
				aAdd(aInfoBrw[2],{"%",20,"RIGHT","@E 9999.99"})
				aAdd(aInfoBrw[2],{STR0040,60,"RIGHT",}) //"Hrs. Corretivas"
				aAdd(aInfoBrw[2],{STR0029,50,"RIGHT","@E 999,999,999.99"}) //"Valor"
				aAdd(aInfoBrw[2],{"%",20,"RIGHT","@E 9999.99"})
				aAdd(aInfoBrw[2],{STR0031,40,"RIGHT",}) //"Total Horas"
				If lGerarCons
					UtilizxCC()
				Endif
				cGrafDesc1 := STR0041 //"UtilizaÁ„o x Centro de Custo"
				cDescMDO := 'UxCC'
			ElseIf nAcesso == 1 //Por Especialidade
				aAdd(aInfoBrw[2],{STR0010,55,"LEFT",}) //"Especialidade"
				aAdd(aInfoBrw[2],{STR0027,170,"LEFT",}) //"Nome"
				aAdd(aInfoBrw[2],{STR0035,45,"RIGHT",}) //"Quant. Func."
				aAdd(aInfoBrw[2],{STR0042,36,"LEFT",}) //"CC. Func."
				aAdd(aInfoBrw[2],{STR0039,64,"RIGHT",}) //"Hrs. Preventivas"
				aAdd(aInfoBrw[2],{STR0029,50,"RIGHT","@E 999,999,999.99"}) //"Valor"
				aAdd(aInfoBrw[2],{"%",20,"RIGHT","@E 9999.99"})
				aAdd(aInfoBrw[2],{STR0040,60,"RIGHT",}) //"Hrs. Corretivas"
				aAdd(aInfoBrw[2],{STR0029,50,"RIGHT","@E 999,999,999.99"}) //"Valor"
				aAdd(aInfoBrw[2],{"%",20,"RIGHT","@E 9999.99"})
				aAdd(aInfoBrw[2],{STR0031,40,"RIGHT",}) //"Total Horas"
				If lGerarCons
					UtilizxEs()
				Endif
				cGrafDesc1 := STR0043 //"UtilizaÁ„o x Especialidade"
				cDescMDO := 'UxES'
			ElseIf nAcesso == 2 //Por Funcionario
				aAdd(aInfoBrw[2],{STR0037,40,"LEFT",}) //"MatrÌcula"
				aAdd(aInfoBrw[2],{STR0027,170,"LEFT",}) //"Nome"
				aAdd(aInfoBrw[2],{STR0039,64,"RIGHT",}) //"Hrs. Preventivas"
				aAdd(aInfoBrw[2],{STR0029,50,"RIGHT","@E 999,999,999.99"}) //"Valor"
				aAdd(aInfoBrw[2],{"%",20,"RIGHT","@E 9999.99"})
				aAdd(aInfoBrw[2],{STR0040,60,"RIGHT",}) //"Hrs. Corretivas"
				aAdd(aInfoBrw[2],{STR0029,50,"RIGHT","@E 999,999,999.99"}) //"Valor"
				aAdd(aInfoBrw[2],{"%",20,"RIGHT","@E 9999.99"})
				aAdd(aInfoBrw[2],{STR0031,40,"RIGHT",}) //"Total Horas"
				If lGerarCons
					UtilizxFu()
				Endif
				cGrafDesc1 := STR0044 //"UtilizaÁ„o x Funcion·rio"
				cDescMDO := 'UxFU'
			EndIf
		ElseIf cTpAnalise = "E" //Eficiencia
			If nAcesso == 0 //Por Centro de Custo
				aAdd(aInfoBrw[2],{STR0026,45,"LEFT",}) //"Centro Custo"
				aAdd(aInfoBrw[2],{STR0027,170,"LEFT",}) //"Nome"
				aAdd(aInfoBrw[2],{STR0045,56,"RIGHT",}) //"Hrs. Previstas"
				aAdd(aInfoBrw[2],{STR0046,60,"RIGHT",}) //"Hrs. Realizadas"
				aAdd(aInfoBrw[2],{STR0047,36,"RIGHT",}) //"DiferenÁa"
				aAdd(aInfoBrw[2],{"%",20,"RIGHT","@E 9999.99"})
				aAdd(aInfoBrw[2],{STR0048,44,"RIGHT",}) //"Hrs. Extras"
				If lGerarCons
					EficiencCC()
				Endif
				cGrafDesc1 := STR0049 //"EficiÍncia x Centro de Custo"
				cDescMDO := 'ExCC'
			ElseIf nAcesso == 1 //Por Especialidade
				aAdd(aInfoBrw[2],{STR0010,55,"LEFT",}) //"Especialidade"
				aAdd(aInfoBrw[2],{STR0027,170,"LEFT",}) //"Nome"
				aAdd(aInfoBrw[2],{STR0045,56,"RIGHT",}) //"Hrs. Previstas"
				aAdd(aInfoBrw[2],{STR0046,60,"RIGHT",}) //"Hrs. Realizadas"
				aAdd(aInfoBrw[2],{STR0047,36,"RIGHT",}) //"DiferenÁa"
				aAdd(aInfoBrw[2],{"%",20,"RIGHT","@E 9999.99"})
				aAdd(aInfoBrw[2],{STR0048,44,"RIGHT",}) //"Hrs. Extras"
				If lGerarCons
					EficiencEs()
				Endif
				cGrafDesc1 := STR0050 //"EficiÍncia x Especialidade"
				cDescMDO := 'ExES'
			ElseIf nAcesso == 2 //Por Funcionario
				aAdd(aInfoBrw[2],{STR0037,40,"LEFT",}) //"MatrÌcula"
				aAdd(aInfoBrw[2],{STR0027,170,"LEFT",}) //"Nome"
				aAdd(aInfoBrw[2],{STR0045,56,"RIGHT",}) //"Hrs. Previstas"
				aAdd(aInfoBrw[2],{STR0046,60,"RIGHT",}) //"Hrs. Realizadas"
				aAdd(aInfoBrw[2],{STR0047,40,"RIGHT",}) //"DiferenÁa"
				aAdd(aInfoBrw[2],{"%",20,"RIGHT","@E 9999.99"})
				aAdd(aInfoBrw[2],{STR0048,44,"RIGHT",}) //"Hrs. Extras"
				If lGerarCons
					EficiencFu()
				Endif
				cGrafDesc1 := STR0052 //"EficiÍncia x Funcion·rio"
				cDescMDO := 'ExFU'
			EndIf
		ElseIf cTpAnalise = "D" //Distribuicao
			If nAcesso == 1 //Por Prioridade
				aAdd(aInfoBrw[2],{STR0058,40,"LEFT",}) //"Prioridade"
				aAdd(aInfoBrw[2],{STR0055,36,"LEFT",}) //"Impedidas"
				aAdd(aInfoBrw[2],{STR0056,48,"LEFT",}) //"DistribuÌdas"
				aAdd(aInfoBrw[2],{STR0054,28,"LEFT",}) //"Total de O.S."
				DistribxPr()
				cDescMDO := 'DxPR'
			ElseIf nAcesso == 2 //Por O.S
				aAdd(aInfoBrw[2],{STR0059,64,"LEFT",}) //"Ordem de ServiÁo"
				aAdd(aInfoBrw[2],{STR0060,25,"LEFT",}) //"Status"
				aAdd(aInfoBrw[2],{STR0061,60,"LEFT",}) //"Bem"
				aAdd(aInfoBrw[2],{STR0027,170,"LEFT",}) //"Nome"
				aAdd(aInfoBrw[2],{STR0062,52,"CENTER",}) //"Data Prevista"
				aAdd(aInfoBrw[2],{STR0045,56,"RIGHT",}) //"Hrs. Previstas"
				aAdd(aInfoBrw[2],{STR0046,60,"RIGHT",}) //"Hrs. Realizadas"
				aAdd(aInfoBrw[2],{'%',20,"RIGHT","@E 9999.99"})
				DistribxOS()
				cDescMDO := 'DxOS'
			EndIf
		EndIf
		aOldHeader[nAcesso+1][1] := aClone(aInfoBrw[2])
	//##################### BROWSE INFERIOR
	ElseIf nBrowse == 2

		If cTpAnalise = "O" //Ociosidade
			If nAcesso == 0 //Por Centro de Custo
				aAdd(aInfoBrw[2],{STR0010,55,"LEFT",}) //"Especialidade"
				aAdd(aInfoBrw[2],{STR0027,170,"LEFT",}) //"Nome"
				aAdd(aInfoBrw[2],{STR0035,45,"RIGHT",}) //"Quant. Func."
				aAdd(aInfoBrw[2],{STR0028,35,"RIGHT",}) //"Hrs. Produt."
				aAdd(aInfoBrw[2],{STR0029,50,"RIGHT","@E 999,999,999.99"}) //"Valor"
				aAdd(aInfoBrw[2],{"%",20,"RIGHT","@E 9999.99"})
				aAdd(aInfoBrw[2],{STR0030,35,"RIGHT",}) //"Hrs. Improd."
				aAdd(aInfoBrw[2],{STR0029,50,"RIGHT","@E 999,999,999.99"}) //"Valor"
				aAdd(aInfoBrw[2],{"%",20,"RIGHT","@E 9999.99"})
				aAdd(aInfoBrw[2],{STR0031,40,"RIGHT",}) //"Total Horas"
				aAdd(aInfoBrw[2],{STR0032,40,"RIGHT",}) //"Hrs. Dispon."
				aAdd(aInfoBrw[2],{STR0033,40,"RIGHT",}) //"Hrs. N„o Repor."
			ElseIf nAcesso == 1 //Por Especialidade
				aAdd(aInfoBrw[2],{STR0037,40,"LEFT",}) //"MatrÌcula"
				aAdd(aInfoBrw[2],{STR0027,170,"LEFT",}) //"Nome"
				aAdd(aInfoBrw[2],{STR0028,35,"RIGHT",}) //"Hrs. Produt."
				aAdd(aInfoBrw[2],{"%",20,"RIGHT","@E 9999.99"})
				aAdd(aInfoBrw[2],{STR0030,35,"RIGHT",}) //"Hrs. Improd."
				aAdd(aInfoBrw[2],{"%",20,"RIGHT","@E 9999.99"})
				aAdd(aInfoBrw[2],{STR0031,40,"RIGHT",}) //"Total Horas"
				aAdd(aInfoBrw[2],{STR0032,40,"RIGHT",}) //"Hrs. Dispon."
				aAdd(aInfoBrw[2],{STR0033,40,"RIGHT",}) //"Hrs. N„o Repor."
			ElseIf nAcesso == 2 //Por Funcionario
				aAdd(aInfoBrw[2],{STR0067,170,"LEFT",}) //"Tipo de Hora"
				aAdd(aInfoBrw[2],{STR0031,40,"RIGHT",}) //"Total Horas"
				aAdd(aInfoBrw[2],{"%",20,"RIGHT","@E 9999.99"})
				aAdd(aInfoBrw[2],{STR0029,50,"RIGHT","@E 999,999,999.99"}) //"Valor"
			EndIf
		ElseIf cTpAnalise = "U" //Utilizacao
			If nAcesso == 0 //Por Centro de Custo
				aAdd(aInfoBrw[2],{STR0010,55,"LEFT",}) //"Especialidade"
				aAdd(aInfoBrw[2],{STR0027,170,"LEFT",}) //"Nome"
				aAdd(aInfoBrw[2],{STR0035,45,"RIGHT",}) //"Quant. Func."
				aAdd(aInfoBrw[2],{STR0042,36,"LEFT",}) //"CC. Func."
				aAdd(aInfoBrw[2],{STR0039,64,"RIGHT",}) //"Hrs. Preventivas"
				aAdd(aInfoBrw[2],{STR0029,50,"RIGHT","@E 999,999,999.99"}) //"Valor"
				aAdd(aInfoBrw[2],{"%",20,"RIGHT","@E 9999.99"})
				aAdd(aInfoBrw[2],{STR0040,60,"RIGHT",}) //"Hrs. Corretivas"
				aAdd(aInfoBrw[2],{STR0029,50,"RIGHT","@E 999,999,999.99"}) //"Valor"
				aAdd(aInfoBrw[2],{"%",20,"RIGHT","@E 9999.99"})
				aAdd(aInfoBrw[2],{STR0031,40,"RIGHT",}) //"Total Horas"
			ElseIf nAcesso == 1	//Por Especialidade
				aAdd(aInfoBrw[2],{STR0037,40,"LEFT",}) //"MatrÌcula"
				aAdd(aInfoBrw[2],{STR0027,170,"LEFT",}) //"Nome"
				aAdd(aInfoBrw[2],{STR0039,64,"RIGHT",}) //"Hrs. Preventivas"
				aAdd(aInfoBrw[2],{STR0029,50,"RIGHT","@E 999,999,999.99"}) //"Valor"
				aAdd(aInfoBrw[2],{"%",20,"RIGHT","@E 9999.99"})
				aAdd(aInfoBrw[2],{STR0040,60,"RIGHT",}) //"Hrs. Corretivas"
				aAdd(aInfoBrw[2],{STR0029,50,"RIGHT","@E 999,999,999.99"}) //"Valor"
				aAdd(aInfoBrw[2],{"%",20,"RIGHT","@E 9999.99"})
				aAdd(aInfoBrw[2],{STR0031,40,"RIGHT",}) //"Total Horas"
			ElseIf nAcesso == 2	//Por Funcionario
				aAdd(aInfoBrw[2],{STR0059,64,"LEFT",}) //"Ordem de ServiÁo"
				aAdd(aInfoBrw[2],{STR0069,60,"LEFT",}) //"Tipo ManutenÁ„o"
				aAdd(aInfoBrw[2],{STR0215,60,"LEFT",}) //"Equipamento"
				aAdd(aInfoBrw[2],{STR0216,52,"LEFT",}) //"Data inÌcio"
				aAdd(aInfoBrw[2],{STR0217,40,"LEFT",}) //"Hora inÌcio"
				aAdd(aInfoBrw[2],{STR0218,52,"LEFT",}) //"Data fim"
				aAdd(aInfoBrw[2],{STR0219,40,"LEFT",}) //"Hora fim"
				aAdd(aInfoBrw[2],{STR0031,40,"RIGHT",}) //"Total Horas"
				aAdd(aInfoBrw[2],{STR0029,50,"RIGHT","@E 999,999,999.99"}) //"Valor"
				aAdd(aInfoBrw[2],{"%",20,"RIGHT","@E 9999.99"})//Percentual
				aAdd(aInfoBrw[2],{STR0071,25,"LEFT",}) //"Tarefa"
				aAdd(aInfoBrw[2],{STR0068,25,"LEFT",}) //"Etapa"
				aAdd(aInfoBrw[2],{STR0072,170,"LEFT",}) //"DescriÁ„o"
				aAdd(aInfoBrw[2],{STR0214,200,"LEFT",}) //"ObservaÁ„o"
			EndIf
		ElseIf cTpAnalise = "E" //Eficiencia
			If nAcesso == 0 //Por Centro de Custo
				aAdd(aInfoBrw[2],{STR0010,55,"LEFT",}) //"Especialidade"
				aAdd(aInfoBrw[2],{STR0027,170,"LEFT",}) //"Nome"
				aAdd(aInfoBrw[2],{STR0045,56,"RIGHT",}) //"Hrs. Previstas"
				aAdd(aInfoBrw[2],{STR0046,60,"RIGHT",}) //"Hrs. Realizadas"
				aAdd(aInfoBrw[2],{STR0047,36,"RIGHT",}) //"DiferenÁa"
				aAdd(aInfoBrw[2],{"%",20,"RIGHT","@E 9999.99"})
				aAdd(aInfoBrw[2],{STR0048,44,"RIGHT",}) //"Hrs. Extras"
			ElseIf nAcesso == 1 //Por Especialidade
				aAdd(aInfoBrw[2],{STR0037,40,"LEFT",}) //"MatrÌcula"
				aAdd(aInfoBrw[2],{STR0027,170,"LEFT",}) //"Nome"
				aAdd(aInfoBrw[2],{STR0045,56,"RIGHT",}) //"Hrs. Previstas"
				aAdd(aInfoBrw[2],{STR0046,60,"RIGHT",}) //"Hrs. Realizadas"
				aAdd(aInfoBrw[2],{STR0047,40,"RIGHT",}) //"DiferenÁa"
				aAdd(aInfoBrw[2],{"%",20,"RIGHT","@E 9999.99"})
				aAdd(aInfoBrw[2],{STR0048,44,"RIGHT",}) //"Hrs. Extras"
			ElseIf nAcesso == 2 //Por Funcionario
				aAdd(aInfoBrw[2],{STR0059,64,"LEFT",}) //"Ordem de ServiÁo"
				aAdd(aInfoBrw[2],{STR0070,20,"LEFT",}) //"Plano"
				aAdd(aInfoBrw[2],{STR0071,25,"LEFT",}) //"Tarefa"
				aAdd(aInfoBrw[2],{STR0045,56,"RIGHT",}) //"Hrs. Previstas"
				aAdd(aInfoBrw[2],{STR0046,60,"RIGHT",}) //"Hrs. Realizadas"
				aAdd(aInfoBrw[2],{STR0047,36,"RIGHT",}) //"DiferenÁa"
				aAdd(aInfoBrw[2],{"%",20,"RIGHT","@E 9999.99"})
				aAdd(aInfoBrw[2],{STR0048,44,"RIGHT",}) //"Hrs. Extras"
			EndIf
		ElseIf cTpAnalise = "D" //Distribuicao
			If nAcesso == 1 //Por Prioridade
				aAdd(aInfoBrw[2],{STR0059,64,"LEFT",}) //"Ordem de ServiÁo"
				aAdd(aInfoBrw[2],{STR0060,25,"LEFT",}) //"Status"
				aAdd(aInfoBrw[2],{STR0061,60,"LEFT",}) //"Bem"
				aAdd(aInfoBrw[2],{STR0027,170,"LEFT",}) //"Nome"
				aAdd(aInfoBrw[2],{STR0062,52,"CENTER",}) //"Data Prevista"
				aAdd(aInfoBrw[2],{STR0045,56,"RIGHT",}) //"Hrs. Previstas"
				aAdd(aInfoBrw[2],{STR0046,60,"RIGHT",}) //"Hrs. Realizadas"
				aAdd(aInfoBrw[2],{'%',20,"RIGHT","@E 9999.99"})
			ElseIf nAcesso == 2 //Por O.S
				aAdd(aInfoBrw[2],{STR0051,55,"LEFT",}) //"Horas"
				aAdd(aInfoBrw[2],{STR0154,70,"LEFT",}) //"Tipo"
				aAdd(aInfoBrw[2],{STR0155,55,"LEFT",}) //"CÛdigo"
				aAdd(aInfoBrw[2],{STR0027,170,"LEFT",}) //"Nome"
				aAdd(aInfoBrw[2],{STR0031,40,"RIGHT",}) //"Total Horas"
			EndIf
		EndIf
		aOldHeader[nAcesso+1][2] := aClone(aInfoBrw[2])
	EndIf

aInfoBrw[1] := aClone(aColsCab)

Return aInfoBrw

//---------------------------------------------------------------------
/*/{Protheus.doc} CriaRodape
Cria rodape contendo informacoes sobre Totais (Im)Produtivas

Par‚metros:
nTotProd - Total Produtivas
nTotImp  - Total Improdutivas
oTotProd - Objeto do Total Produtivas
oTotImp  - Objeto do Total Improdutivas
oPanel   - Objeto Pai

@author Vitor Emanuel Batista
@since	02/09/2009
/*/
//---------------------------------------------------------------------
Static Function CriaRodape(cCabecSup,cCabecInf,oPanel,nPar)

	If lVoltaNivel .Or. (nPar == 2 .And. nAcesso >= 1)
	If nAcesso >= 1
		If ValType(oCabInf1) == "O"
				oCabInf1:cTitle := ""
		Endif
		If ValType(oCabInf2) == "O"
				oCabInf2:cTitle := ""
		Endif
	Endif
	Return
Endif

If ValType(oPanel) == "O"
	If nPar == 1 //GetDados 1

			If ValType(oCabInf1) == "O"
				oCabInf1:cTitle := ""
				oCabInf2:cTitle := ""
			EndIf

		If ValType(oCabSup1) != "O"
			@ 002,020 SAY oCabSup1 VAR "" SIZE 348, 08 COLOR RGB(255,255,255) OF oPanel FONT oFont14B PIXEL
			@ 002,160 SAY oCabSup2 VAR "" SIZE 348, 08 COLOR RGB(255,255,255) OF oPanel FONT oFont14B PIXEL
		Else
				oCabSup1:cTitle := ""
				oCabSup2:cTitle := ""
		Endif
		oCabSup1:cTitle := cCabecSup
		oCabSup2:cTitle := cCabecInf

	ElseIf nPar == 2 //GetDados 2

			If ValType(oCabSup1) == "O"
				oCabSup1:cTitle := ""
				oCabSup2:cTitle := ""
			EndIf

		If ValType(oCabInf1) != "O"
			@ 002,020 SAY oCabInf1 VAR "" SIZE 348, 08 COLOR RGB(255,255,255) OF oPanel FONT oFont14B PIXEL
			@ 002,160 SAY oCabInf2  VAR "" SIZE 348, 08 COLOR RGB(255,255,255) OF oPanel FONT oFont14B PIXEL
		Else
				oCabInf1:cTitle := ""
				oCabInf2:cTitle := ""
		Endif
		oCabInf1:cTitle := cCabecSup
		oCabInf2:cTitle := cCabecInf

	Endif
EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ChangeVisual
Faz alteracoes necessarias ao modificar combo Tipo Analise

@author Vitor Emanuel Batista
@since	01/09/2009
/*/
//---------------------------------------------------------------------
Static Function ChangeVisual(oVisualiz,lTroca)

If cTpAnalise != "D"
	If lTroca
		oVisualiz:aItems := {"C="+STR0009,"E="+STR0010,"F="+STR0011} //"Centro de Custo"###"Especialidade"###"Funcion·rio"
		If cTpAnalise == 'E'
			CheckEsp()
		Endif
	EndIf
Else
	oVisualiz:aItems := {"P="+STR0058,"O="+STR0074} //"Prioridade"###"O.S."
EndIf

cTpAnalOld := cTpAnalise

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} GerarConsulta
Gera consulta no Browse superior e inferior

@author Vitor Emanuel Batista
@since	01/09/2009
/*/
//---------------------------------------------------------------------
Static Function GerarConsulta()

lValWhen := .T. //Vari·vel utilizada para fechar o when dos campos do filtro quando gerar a consulta.

	If Empty(dTpAnaliDe) .And. Empty(dTpAnaliAte)
	ShowHelpDlg(STR0117,{STR0174},2,{STR0175},2)//"Para geraÁ„o da consulta È necess·rio que os campos 'Pesquisar entre:' sejam informados"###"Informe os campos de data."
		Return .F.
	ElseIf Empty(dTpAnaliAte) .And. dTpAnaliAte == CTOD("  /  /  ")
		ShowHelpDlg(STR0117,{STR0174},2,{STR0175},2)//"Para geraÁ„o da consulta È necess·rio que os campos 'Pesquisar entre:' sejam informados"###"Informe os campos de data."
		Return .F.
	EndIf

	lPrimeira := .F.
	lNovaCons := .F.
oBtnHoras1:Enable()
oBtnCusto1:Enable()
oBtnHoras2:Enable()
oBtnCusto2:Enable()
oBtnRela1:Enable()
oBtnRela2:Enable()
oBtnVoltar:Enable()
oNovaCons:Enable()

oGeraCons:Disable()
oTpAnalise:Disable()
oPeriodo:Disable()
oVisualiz:Disable()
oTpCusto:Disable()
oVisualiDe:Disable()
oVisualiAte:Disable()
oTpAnaliDe:Disable()
oTpAnaliAte:Disable()
If cTpAnalise <> "D"
	oBtnRela1:Show()
	oBtnRela2:Show()
Endif

	lVoltaNivel := .F.
aOldHeader := {{{},{}},{{},{}},{{},{}}}
aOldCols   := {{{},{},{}},{{},{},{}},{{},{},{}},{{},{},{}},{{},{},{}},{{},{},{}},{{},{},{}},{{},{},{}}}

	lGerarCons := .T.
	lDuploClick := .F.

	cCCDuplo   := ""
	cEspDuplo  := ""
	cCCFDuplo  := ""
	cMatDuplo  := ""
	cPrioDuplo := ""
	cOrdeDuplo := ""
	cPerDuplo  := ""

nAcesso := 0
If cTpAnalise != "D"
	If cVisualiz = "E"
		nAcesso := 1
	ElseIf cVisualiz != 'C'
		nAcesso := 2
	EndIf
Else
	If cVisualiz = "P" //"R"
		nAcesso := 1
	ElseIf cVisualiz = "O"
		nAcesso := 2
	EndIf
EndIf

	aColsInfer := {}
	aColsCab   := {}
	aColsRod   := {}
	aColsFunci := {}
	aPosEspCal := {}
	aTurnoST1  := {}
	aEspecHora := {}
	aColsOSxFu := {}
	aColsRel   := {}
	aMesAno    := {}

If cTpAnalise = "O"
	If nAcesso == 0
		oBtnHoras1:Show()
		oBtnCusto1:Show()
		oBtnHoras2:Show()
		oBtnCusto2:Show()
		If cPerCons == 'D'
			HideShowOb(@oBrowsDCO1,@oBrowsDRO1)
		Else
			HideShowOb(@oBrowseCO1,@oBrowseRO1)
		Endif
	ElseIf nAcesso == 1
		oBtnHoras1:Show()
		oBtnCusto1:Show()
		oBtnHoras2:Show()
		oBtnCusto2:Hide()
		If cPerCons == 'D'
			oBtnHoras2:Hide()
			HideShowOb(@oBrowsDCO2,@oBrowsDRO2)
		Else
			HideShowOb(@oBrowseCO2,@oBrowseRO2)
		Endif
	ElseIf nAcesso == 2
		oBtnHoras1:Show()
		oBtnCusto1:Hide()
		oBtnHoras2:Hide()
		oBtnCusto2:Hide()
		If cPerCons == 'D'
			oBtnHoras1:Hide()
			HideShowOb(@oBrowsDCO3,@oBrowsDRO3)
		Else
			HideShowOb(@oBrowseCO3,@oBrowseRO3)
		Endif
	Endif
ElseIf cTpAnalise = "E"
	If nAcesso == 0
		oBtnHoras1:Show()
		oBtnCusto1:Hide()
		oBtnHoras2:Show()
		oBtnCusto2:Hide()
		If cPerCons == 'D'
			oBtnHoras1:Hide()
			oBtnHoras2:Hide()
			HideShowOb(@oBrowsDCE1,@oBrowsDRE1)
		Else
			HideShowOb(@oBrowseCE1,@oBrowseRE1)
		Endif
	ElseIf nAcesso == 1
		oBtnHoras1:Show()
		oBtnCusto1:Hide()
		oBtnHoras2:Show()
		oBtnCusto2:Hide()
		If cPerCons == 'D'
			oBtnHoras1:Hide()
			oBtnHoras2:Hide()
			HideShowOb(@oBrowsDCE2,@oBrowsDRE2)
		Else
			HideShowOb(@oBrowseCE2,@oBrowseRE2)
		Endif
	ElseIf nAcesso == 2
		oBtnHoras1:Show()
		oBtnCusto1:Hide()
		oBtnHoras2:Hide()
		oBtnCusto2:Hide()
		If cPerCons == 'D'
			oBtnHoras1:Hide()
			HideShowOb(@oBrowsDCE3,@oBrowsDRE3)
		Else
			HideShowOb(@oBrowseCE3,@oBrowseRE3)
		Endif
	Endif
ElseIf cTpAnalise = "D"
	oBtnHoras1:Hide()
	oBtnCusto1:Hide()
	oBtnHoras2:Hide()
	oBtnCusto2:Hide()
	If nAcesso == 0
		oBtnRela1:Show()
		oBtnRela2:Hide()
		If cPerCons == 'D'
			HideShowOb(@oBrowsDCD1,@oBrowsDRD1)
		Else
			HideShowOb(@oBrowseCD1,@oBrowseRD1)
		Endif
	ElseIf nAcesso == 1
		oBtnRela1:Show()
		oBtnRela2:Hide()
		If cPerCons == 'D'
			HideShowOb(@oBrowsDCD2,@oBrowsDRD2)
		Else
			HideShowOb(@oBrowseCD2,@oBrowseRD2)
		Endif
	ElseIf nAcesso == 2
		oBtnRela1:Hide()
		oBtnRela2:Hide()
		If cPerCons == 'D'
			HideShowOb(@oBrowsDCD3,@oBrowsDRD3)
		Else
			HideShowOb(@oBrowseCD3,@oBrowseRD3)
		Endif
	Endif
ElseIf cTpAnalise = "U"
	If nAcesso == 0
		oBtnHoras1:Show()
		oBtnCusto1:Show()
		oBtnHoras2:Show()
		oBtnCusto2:Show()
		If cPerCons == 'D'
			oBtnHoras2:Hide()
			oBtnCusto2:Hide()
			HideShowOb(@oBrowsDCU1,@oBrowsDRU1)
		Else
			HideShowOb(@oBrowseCU1,@oBrowseRU1)
		Endif
	ElseIf nAcesso == 1
		oBtnHoras1:Show()
		oBtnCusto1:Show()
		oBtnHoras2:Show()
		oBtnCusto2:Show()
		If cPerCons == 'D'
			oBtnHoras1:Hide()
			oBtnCusto1:Hide()
			oBtnHoras2:Hide()
			oBtnCusto2:Hide()
			HideShowOb(@oBrowsDCU2,@oBrowsDRU2)
		Else
			HideShowOb(@oBrowseCU2,@oBrowseRU2)
		Endif
	ElseIf nAcesso == 2
		oBtnHoras1:Show()
		oBtnCusto1:Show()
		oBtnHoras2:Hide()
		oBtnCusto2:Hide()
		If cPerCons == 'D'
			oBtnHoras1:Hide()
			oBtnCusto1:Hide()
			oBtnHoras2:Hide()
			oBtnCusto2:Hide()
			HideShowOb(@oBrowsDCU3,@oBrowsDRU3)
		Else
			HideShowOb(@oBrowseCU3,@oBrowseRU3)
		Endif
	Endif
Endif

nAcessoGC := nAcesso
aOldCols[nAcesso+1][3] := aClone(aColsInfer)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} NGTrocaF3
Altera consulta F3 dos campos De/Ate

@author Vitor Emanuel Batista
@since	01/09/2009
/*/
//---------------------------------------------------------------------
Static Function NGTrocaF3()

	Local lReturn := .T.
	aTrocaF3 := {}

	If cTpAnalise != 'D'
		If cVisualiz == "C"
			aAdd(aTrocaF3,{"cVisualiDe","CTT"})
			aAdd(aTrocaF3,{"cVisualiAte","CTT"})
			If cOldF3 <> "CTT"
				cVisualiDe  := Space(Len(CTT->CTT_CUSTO))
				cVisualiAte := Replicate('Z',Len(CTT->CTT_CUSTO))
			Endif
		ElseIf cVisualiz == "E"
			aAdd(aTrocaF3,{"cVisualiDe","ST0"})
			aAdd(aTrocaF3,{"cVisualiAte","ST0"})
			If cOldF3 <> "ST0"
				cVisualiDe  := Space(Len(ST0->T0_ESPECIA))
				cVisualiAte := Replicate('Z',Len(ST0->T0_ESPECIA))
			Endif
		ElseIf cVisualiz == "F"
			aAdd(aTrocaF3,{"cVisualiDe","ST1"})
			aAdd(aTrocaF3,{"cVisualiAte","ST1"})
			If cOldF3 <> "ST1"
				cVisualiDe  := Space(Len(ST1->T1_CODFUNC))
				cVisualiAte := Replicate('Z',Len(ST1->T1_CODFUNC))
			Endif
		EndIf
		cOldF3 := aTrocaF3[1][2]
	Else
		If cVisualiz == "O"
			aAdd(aTrocaF3,{"cVisualiDe","STJLIB"})
			aAdd(aTrocaF3,{"cVisualiAte","STJLIB"})
			If cOldF3 <> "STJ"
				cVisualiDe  := Space(Len(STJ->TJ_ORDEM))
				cVisualiAte := Replicate('Z',Len(STJ->TJ_ORDEM))
			Endif
			cOldF3 := aTrocaF3[1][2]
		ElseIf cTpAnalise == "D" .And. cVisualiz == "P" //Se o tipo de an·lise for igual ‡ 'DistribuiÁ„o' e a visualizaÁ„o igual ‡ 'Prioridade'.
			cVisualiDe  := Space( Len( ST0->T0_ESPECIA ))
			cVisualiAte := Replicate('Z',Len( ST0->T0_ESPECIA ))
			lReturn	:= .F.
			cOldF3	:= ""
		Endif
	Endif

	If lValWhen //Se o usu·rio clicar em 'Gerar Consulta';
		lReturn := .F. //Fecha When dos filtros da consulta;
	EndIf

Return lReturn

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ LimpaDeAte  ≥Autor≥ Marcos Wagner Junior ≥ Data ≥20/07/2009≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Limpa os campos De/Ate      				                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ MNTC400                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function LimpaDeAte()

	If cVisualiz != cOLDVisual
		If cVisualiz == "C"
			cVisualiDe  := Space(Len(CTT->CTT_CUSTO))
			cVisualiAte := Replicate('Z',Len(CTT->CTT_CUSTO))
		ElseIf cVisualiz == "E"
			cVisualiDe  := Space(Len(ST0->T0_ESPECIA))
			cVisualiAte := Replicate('Z',Len(ST0->T0_ESPECIA))
		ElseIf cVisualiz == "F"
			cVisualiDe  := Space(Len(ST1->T1_CODFUNC))
			cVisualiAte := Replicate('Z',Len(ST1->T1_CODFUNC))
		ElseIf cVisualiz == "P"
			cVisualiDe  := Space(Len(STJ->TJ_PRIORID))
			cVisualiAte := Replicate('Z',Len(STJ->TJ_PRIORID))
		ElseIf cVisualiz == "O"
			cVisualiDe  := Space(Len(STJ->TJ_ORDEM))
			cVisualiAte := Replicate('Z',Len(STJ->TJ_ORDEM))
		EndIf
	Endif

	cOLDVisual := cVisualiz

Return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥NGValid400 ≥Autor ≥ Marcos Wagner Junior  ≥ Data ≥19/02/2009≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Valida CC ou Funcionario                                   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥                                                            ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function NGValid400(nPar)

If cTpAnalise <> 'D'
	If cVisualiz == "C"
		cAliasVld := "CTT"
	ElseIf cVisualiz == "E"
		cAliasVld := "ST0"
	ElseIf cVisualiz == "F"
		cAliasVld := "ST1"
	EndIf
Else
	If cVisualiz == "O"
		cAliasVld := "STJ"
		dbSelectArea("STJ")
		dbSetOrder(1)
		If dbSeek(xFilial("STJ")+IIF(nPar=1,cVisualiDe,cVisualiAte)) .And. STJ->TJ_SITUACA != 'L'
			MsgInfo(STR0160,STR0117) //"O.S. informada dever· ser liberada!"###"AtenÁ„o"
			Return .F.
		Endif
	ElseIf cVisualiz == "P"
		If cVisualiDe > cVisualiAte
			MsgInfo(STR0161,STR0117) //"'De Prioridade' n„o poder· ser maior que 'AtÈ Prioridade'!"###"AtenÁ„o"
			Return .F.
		Else
			Return .T.
		Endif
	EndIf
Endif

If nPar == 1
	If Empty(cVisualiDe)
		Return .T.
	Else
		If !ExistCpo(cAliasVld,cVisualiDe)
	 		Return .F.
		Endif
	Endif
Else
	If cVisualiAte == Replicate('Z',Len(cVisualiDe))
		Return .T.
	Else
		If !ExistCpo(cAliasVld,cVisualiAte)
	 		Return .F.
		Endif
		If !Atecodigo(cAliasVld,cVisualiDe,cVisualiAte,06)
			Return .F.
		Endif
	Endif
Endif

Return .T.

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥MudaInferior≥Autor ≥ Marcos Wagner Junior ≥ Data ≥19/02/2009≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Altera GetDados inferior de acordo com CC selecionado acima≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥                                                            ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function MudaInferior(_oBrowsePai,_oBrowseFilho,_lVoltaNiv)
	
	Local nX := 0

	If !(ValType(_oBrowsePai)=="O") .Or. !(ValType(_oBrowseFilho)=="O")
		Return .T.
	Endif

	If !_lVoltaNiv
		lVoltaNivel := .F.
	Endif

	aColsRod  := {}
	nTotProd2 := 0
	nTotImp2  := 0
	nTotCabPre := 0
	nTotCabRea := 0

	cCabecInf1 := ""
	cCabecInf2 := ""

	If cDescMDO == 'UxCC'

		nTotRodPre := 0
		nTotRodCor := 0

		aColsInfer := aSort(aColsInfer,,,{|x,y| x[1+nP]+x[2+nP]+x[5+nP] < y[1+nP]+y[2+nP]+y[5+nP]})

		For nX := 1 to Len(aColsInfer)
			If (!lDetalhado .And. _oBrowsePai:aARRAY[_oBrowsePai:nAt][1] == aColsInfer[nX][1]) .Or.;
				(lDetalhado .And. _oBrowsePai:aARRAY[_oBrowsePai:nAt][1]+_oBrowsePai:aARRAY[_oBrowsePai:nAt][2] == aColsInfer[nX][1]+aColsInfer[nX][2])

				aAdicionar := {}

				If lDetalhado
					aAdd(aAdicionar,aColsInfer[nX][1])
				Endif
				aAdd(aAdicionar,aColsInfer[nX][2+nP])
				aAdd(aAdicionar,aColsInfer[nX][3+nP])
				aAdd(aAdicionar,aColsInfer[nX][4+nP])
				aAdd(aAdicionar,aColsInfer[nX][5+nP])
				aAdd(aAdicionar,aColsInfer[nX][6+nP])
				aAdd(aAdicionar,aColsInfer[nX][7+nP])
				aAdd(aAdicionar,aColsInfer[nX][8+nP])
				aAdd(aAdicionar,aColsInfer[nX][9+nP])
				aAdd(aAdicionar,aColsInfer[nX][10+nP])
				aAdd(aAdicionar,aColsInfer[nX][11+nP])
				aAdd(aAdicionar,aColsInfer[nX][12+nP])

				aAdd(aColsRod,aAdicionar)

				nTotRodPre := SomaHoras( nTotRodPre,aColsInfer[nX][6+nP] )
				nTotRodCor := SomaHoras( nTotRodCor,aColsInfer[nX][9+nP] )
			Endif
		Next

		cCabecInf1 := STR0080 + IIF( nTotRodPre == 0, NTOH( 0 ), NgTraNtoH( nTotRodPre ) ) //"Total Preventivas: "
		cCabecInf2 := STR0081 + IIF( nTotRodCor == 0, NTOH( 0 ), NgTraNtoH( nTotRodCor ) ) //"Total Corretivas: "
	ElseIf cDescMDO == 'OxES'
		aColsInfer := aSort(aColsInfer,,,{|x,y| x[2+nP] < y[2+nP]})

		For nX := 1 to Len(aColsInfer)
			If (!lDetalhado .And. _oBrowsePai:aARRAY[_oBrowsePai:nAt][1] == aColsInfer[nX][1]) .Or.;
				(lDetalhado .And. _oBrowsePai:aARRAY[_oBrowsePai:nAt][1]+_oBrowsePai:aARRAY[_oBrowsePai:nAt][2] == aColsInfer[nX][1]+aColsInfer[nX][2])

				aAdicionar := {}

				If lDetalhado
					aAdd(aAdicionar,aColsInfer[nX][1])
				Endif
				aAdd(aAdicionar,aColsInfer[nX][2+nP])
				aAdd(aAdicionar,aColsInfer[nX][3+nP])
				aAdd(aAdicionar,aColsInfer[nX][4+nP])
				aAdd(aAdicionar,aColsInfer[nX][5+nP])
				aAdd(aAdicionar,aColsInfer[nX][6+nP])
				aAdd(aAdicionar,aColsInfer[nX][7+nP])
				aAdd(aAdicionar,aColsInfer[nX][8+nP])
				aAdd(aAdicionar,aColsInfer[nX][9+nP])
				aAdd(aAdicionar,aColsInfer[nX][10+nP])

				aAdd(aColsRod,aAdicionar)

				nTotProd2 := SomaHoras( nTotProd2,aColsInfer[nX][4+nP] )
				nTotImp2  := SomaHoras( nTotImp2,aColsInfer[nX][6+nP]  )
			Endif
		Next
	ElseIf cDescMDO == 'UxES'
		nTotRodPre := 0
		nTotRodCor := 0

		aColsInfer := aSort(aColsInfer,,,{|x,y| x[3+nP] < y[3+nP]})

		For nX := 1 to Len(aColsInfer)
			If (!lDetalhado .And. _oBrowsePai:aARRAY[_oBrowsePai:nAt][1]+_oBrowsePai:aARRAY[_oBrowsePai:nAt][4] == aColsInfer[nX][1]+aColsInfer[nX][2]) .Or.;
				(lDetalhado .And. _oBrowsePai:aARRAY[_oBrowsePai:nAt][1]+_oBrowsePai:aARRAY[_oBrowsePai:nAt][2]+_oBrowsePai:aARRAY[_oBrowsePai:nAt][5] == aColsInfer[nX][1]+aColsInfer[nX][2]+aColsInfer[nX][3])

				aAdicionar := {}

				If lDetalhado
					aAdd(aAdicionar,aColsInfer[nX][1])
				Endif
				aAdd(aAdicionar,aColsInfer[nX][3+nP])
				aAdd(aAdicionar,aColsInfer[nX][4+nP])
				aAdd(aAdicionar,aColsInfer[nX][5+nP])
				aAdd(aAdicionar,aColsInfer[nX][6+nP])
				aAdd(aAdicionar,aColsInfer[nX][7+nP])
				aAdd(aAdicionar,aColsInfer[nX][8+nP])
				aAdd(aAdicionar,aColsInfer[nX][9+nP])
				aAdd(aAdicionar,aColsInfer[nX][10+nP])
				aAdd(aAdicionar,aColsInfer[nX][11+nP])

				aAdd(aColsRod,aAdicionar)

				nTotRodPre := SomaHoras( nTotRodPre,aColsInfer[nX][5+nP] )
				nTotRodCor := SomaHoras( nTotRodCor,aColsInfer[nX][8+nP] )
			Endif
		Next
		cCabecInf1 := STR0080 + IIF( nTotRodPre == 0, NTOH( 0 ), NgTraNtoH( nTotRodPre ) ) //"Total Preventivas: "
		cCabecInf2 := STR0081 + IIF( nTotRodCor == 0, NTOH( 0 ), NgTraNtoH( nTotRodCor ) ) //"Total Corretivas: "
	ElseIf cDescMDO == 'DxPR' .Or. cDescMDO == 'OxFU' .Or. cDescMDO == 'UxFU' .Or. cDescMDO == 'DxOS' .Or.;
			cDescMDO == 'ExCC' .Or. cDescMDO == 'ExES' .Or. cDescMDO == 'OxCC' .Or. cDescMDO == 'ExFU'

		If cDescMDO == 'DxPR'
			aColsInfer := aSort(aColsInfer,,,{|x,y| x[2+nP]+x[3+nP] < y[2+nP]+y[3+nP]})
		ElseIf cDescMDO == 'DxOS'
			aColsInfer := aSort(aColsInfer,,,{|x,y| x[2+nP]+x[3+nP]+x[4+nP] < y[2+nP]+y[3+nP]+y[4+nP]})
		Else
			aColsInfer := aSort(aColsInfer,,,{|x,y| x[2+nP] < y[2+nP]})
		Endif

		For nX := 1 to Len(aColsInfer)
			If cDescMDO == 'DxPR'
				If !lDetalhado
					cChavePai   := _oBrowsePai:aARRAY[_oBrowsePai:nAt][1]
					cChaveFilho := aColsInfer[nX][2]
				Else
					cChavePai   := _oBrowsePai:aARRAY[_oBrowsePai:nAt][1]+_oBrowsePai:aARRAY[_oBrowsePai:nAt][2]
					cChaveFilho := aColsInfer[nX][2]+aColsInfer[nX][3]
				Endif
			ElseIf cDescMDO == 'OxFU' .Or. cDescMDO == 'OxCC' .Or. cDescMDO == 'UxFU'
				If !lDetalhado
					cChavePai   := _oBrowsePai:aARRAY[_oBrowsePai:nAt][1]
					cChaveFilho := aColsInfer[nX][1]
				Else
					cChavePai   := _oBrowsePai:aARRAY[_oBrowsePai:nAt][1]+_oBrowsePai:aARRAY[_oBrowsePai:nAt][2]
					cChaveFilho := aColsInfer[nX][1]+aColsInfer[nX][2]
				Endif
			ElseIf cDescMDO == 'DxOS'
				If !lDetalhado
					cChavePai   := _oBrowsePai:aARRAY[_oBrowsePai:nAt][2]
					cChaveFilho := aColsInfer[nX][1]
				Else
					cChavePai   := _oBrowsePai:aARRAY[_oBrowsePai:nAt][2]+_oBrowsePai:aARRAY[_oBrowsePai:nAt][3]
					cChaveFilho := aColsInfer[nX][1]+aColsInfer[nX][2]
				Endif
			ElseIf cDescMDO == 'ExCC' .Or. cDescMDO == 'ExES' .Or. cDescMDO == 'ExFU'
				If cDescMDO == 'ExCC' .Or. cDescMDO == 'ExES' .Or. cDescMDO == 'ExFU'
					If !lDetalhado
						cChavePai   := _oBrowsePai:aARRAY[_oBrowsePai:nAt][1]
						cChaveFilho := aColsInfer[nX][1]
					Else
						cChavePai   := _oBrowsePai:aARRAY[_oBrowsePai:nAt][1]+_oBrowsePai:aARRAY[_oBrowsePai:nAt][2]
						cChaveFilho := aColsInfer[nX][1]+aColsInfer[nX][2]
					Endif
				Else
					If !lDetalhado
						cChavePai   := _oBrowsePai:aARRAY[_oBrowsePai:nAt][1]
						cChaveFilho := aColsInfer[nX][2]
					Else
						cChavePai   := _oBrowsePai:aARRAY[_oBrowsePai:nAt][1]+_oBrowsePai:aARRAY[_oBrowsePai:nAt][2]
						cChaveFilho := aColsInfer[nX][2]+aColsInfer[nX][3]
					Endif
				Endif

			Endif

			If cChavePai == cChaveFilho //Verifica os filhos pertencentes ao pai selecionado na Getdados Superior

				aAdicionar := {}

				If cDescMDO == 'UxFU'

					If lDetalhado
						aAdd(aAdicionar,aColsInfer[nX][1])
					EndIf

					aAdd(aAdicionar,aColsInfer[nX][3+nP])
					aAdd(aAdicionar,aColsInfer[nX][4+nP])
					aAdd(aAdicionar,aColsInfer[nX][5+nP])
					aAdd(aAdicionar,aColsInfer[nX][6+nP])
					aAdd(aAdicionar,aColsInfer[nX][7+nP])
					aAdd(aAdicionar,aColsInfer[nX][8+nP])
					aAdd(aAdicionar,aColsInfer[nX][9+nP])
					aAdd(aAdicionar,aColsInfer[nX][10+nP])
					aAdd(aAdicionar,aColsInfer[nX][11+nP])
					aAdd(aAdicionar,aColsInfer[nX][12+nP])
					aAdd(aAdicionar,aColsInfer[nX][13+nP])
					aAdd(aAdicionar,aColsInfer[nX][14+nP])
					aAdd(aAdicionar,aColsInfer[nX][15+nP])
					aAdd(aAdicionar,aColsInfer[nX][16+nP])

				Else

					If cDescMDO == 'DxPR'
						aAdd(aAdicionar,aColsInfer[nX][1])
						If lDetalhado
							aAdd(aAdicionar,aColsInfer[nX][2])
						Endif
					Else
						If cDescMDO == 'DxPR' .Or. cDescMDO == 'OxFU' .Or. cDescMDO == 'OxCC'
							If lDetalhado
								aAdd(aAdicionar,aColsInfer[nX][1])
							Endif
							aAdd(aAdicionar,aColsInfer[nX][2+nP])
						Else //If cDescMDO == 'ExCC' .Or. cDescMDO == 'ExES' .Or. cDescMDO == 'ExFU' .Or. cDescMDO == 'DxOS'
							If lDetalhado
								aAdd(aAdicionar,aColsInfer[nX][1])
							Endif
							aAdd(aAdicionar,aColsInfer[nX][2+nP])
						Endif
					Endif

					If cDescMDO == 'ExCC' .Or. cDescMDO == 'ExES'
						nTotCabPre += HTON(aColsInfer[nX][4+nP])
						nTotCabRea += HTON(aColsInfer[nX][5+nP])
					Endif

					aAdd(aAdicionar,aColsInfer[nX][3+nP])
					aAdd(aAdicionar,aColsInfer[nX][4+nP])

					If Len(aColsInfer[1]) >= 5+nP
						aAdd(aAdicionar,aColsInfer[nX][5+nP])
					Endif

					If Len(aColsInfer[1]) >= 6+nP
						aAdd(aAdicionar,aColsInfer[nX][6+nP])
					Endif

					If Len(aColsInfer[1]) >= 7+nP
						aAdd(aAdicionar,aColsInfer[nX][7+nP])
					Endif

					If Len(aColsInfer[1]) >= 8+nP
						aAdd(aAdicionar,aColsInfer[nX][8+nP])
					Endif

					If Len(aColsInfer[1]) >= 9+nP
						aAdd(aAdicionar,aColsInfer[nX][9+nP])
					Endif

					If Len(aColsInfer[1]) >= 10+nP
						aAdd(aAdicionar,aColsInfer[nX][10+nP])
					Endif

					If Len(aColsInfer[1]) >= 11+nP
						aAdd(aAdicionar,aColsInfer[nX][11+nP])
					Endif

					If Len(aColsInfer[1]) >= 12+nP
						aAdd(aAdicionar,aColsInfer[nX][12+nP])
					Endif

					If Len(aColsInfer[1]) == 13+nP
						If cDescMDO == 'OxCC'
							aAdd(aAdicionar,aColsInfer[nX][13+nP])
							nTotProd2 += HTON(aColsInfer[nX][5+nP])
							nTotImp2  += HTON(aColsInfer[nX][8+nP])
						Else
							aAdd(aAdicionar,0)
							aAdd(aAdicionar,"")
							nTotProd2 += HTON(aColsInfer[nX][4+nP])
							nTotImp2  += HTON(aColsInfer[nX][6+nP])
						Endif
					Endif

				EndIf

				aAdd(aColsRod,aAdicionar)

			Endif
		Next
	Endif
	If cDescMDO == 'OxCC' .Or. cDescMDO == 'OxES'
		cCabecInf1 := STR0077 + NTOH( nTotProd2 ) + STR0078 //"Total Produtivas: "###" horas"
		cCabecInf2 := STR0079 + NTOH( nTotImp2  ) + STR0078 //"Total Improdutivas: "###" horas"
	ElseIf cDescMDO == 'ExCC' .Or. cDescMDO == 'ExES'
		cCabecInf1 := STR0082 + NTOH( nTotCabPre ) //"Total Previstas: "
		cCabecInf2 := STR0083 + NTOH( nTotCabRea ) //"Total Realizadas: "
	Endif

	_oBrowseFilho:SetArray( aColsRod )

	If Len(aColsRod) > 0
		aOldCols[nAcesso+1][2] := aClone(aColsRod)
	Endif

	nX := 1
	_oBrowseFilho:GoTop()
	_oBrowseFilho:Refresh()

	If lDuploClick
		cCabecInf1 := ""
		cCabecInf2 := ""
	Endif

	CriaRodape(cCabecInf1,cCabecInf2,oPnlRodRod,2)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} DuploClick
Duplo clique da GetDados Inferior

@author Marcos Wagner Junior
@since	20/07/2009
/*/
//---------------------------------------------------------------------
Static Function DuploClick()

If lNovaCons .or. lPrimeira
	Return
Endif

If Len(aColsCab) < 1
 	aColsUp := fBlankArray(oBrowsePai:aColumns)
	oBrowsePai:SetArray(aColsUp)
	oBrowsePai:Refresh()
Endif

If Len(aColsRod) < 1
	aColsDown := fBlankArray(oBrowseFil:aColumns)
	oBrowseFil:SetArray(aColsDown)
	oBrowseFil:Refresh()
Endif

	lVoltaNivel := .F.

	If nAcesso == 2 .Or. Len(aColsInfer) == 0
	Return
Endif

aOldCols[nAcesso+1][1] := aClone(aColsCab)
aOldCols[nAcesso+1][3] := aClone(aColsInfer)
aOldCols[4][nAcesso+1] := cDescMDO
aOldCols[5][nAcesso+1] := oCabSup1:cTitle
aOldCols[6][nAcesso+1] := oCabSup2:cTitle
aOldCols[7][nAcesso+1] := oCabInf1:cTitle
aOldCols[8][nAcesso+1] := oCabInf2:cTitle

	lDuploClick := .T.

aColsCab := {}
aColsInfer := {}
aColsRod := {}

If cTpAnalise = "O" //Ociosidade
	If nAcesso == 0 //Por Centro de Custo
		If cPerCons == 'U'
			cCCDuplo  := oBrowseCO1:aARRAY[oBrowseCO1:nAt][1]
			cEspDuplo := oBrowseRO1:aARRAY[oBrowseRO1:nAt][1]
			AADD(aColsCab,oBrowseRO1:aARRAY[oBrowseRO1:nAt])
		ElseIf cPerCons == 'D'
			cPerDuplo := oBrowsDCO1:aARRAY[oBrowsDCO1:nAt][1]
			cCCDuplo  := oBrowsDCO1:aARRAY[oBrowsDCO1:nAt][2]
			cEspDuplo := oBrowsDRO1:aARRAY[oBrowsDRO1:nAt][2]
			AADD(aColsCab,oBrowsDRO1:aARRAY[oBrowsDRO1:nAt])
		Endif
		nAcesso := 1
	ElseIf nAcesso == 1 //Por Especialidade
		If cPerCons == 'U'
			cCCDuplo  := NGSEEK("ST1",oBrowseRO2:aARRAY[oBrowseRO2:nAt][1],1,"T1_CCUSTO")
			cEspDuplo := oBrowseCO2:aARRAY[oBrowseCO2:nAt][1]
			cMatDuplo := oBrowseRO2:aARRAY[oBrowseRO2:nAt][1]
			AADD(aColsCab,oBrowseRO2:aARRAY[oBrowseRO2:nAt])
		ElseIf cPerCons == 'D'
			cPerDuplo := oBrowsDRO2:aARRAY[oBrowsDRO2:nAt][1]
			cCCDuplo  := NGSEEK("ST1",oBrowsDRO2:aARRAY[oBrowsDRO2:nAt][2],1,"T1_CCUSTO")
			cEspDuplo := oBrowsDCO2:aARRAY[oBrowsDCO2:nAt][2]
			cMatDuplo := oBrowsDRO2:aARRAY[oBrowsDRO2:nAt][2]
			AADD(aColsCab,oBrowsDRO2:aARRAY[oBrowsDRO2:nAt])
		Endif
		nAcesso := 2
	Endif
ElseIf cTpAnalise = "E" //Eficiencia
	If nAcesso == 0 //Por Centro de Custo
		If cPerCons == 'U'
			cCCDuplo  := oBrowseCE1:aARRAY[oBrowseCE1:nAt][1]
			cEspDuplo := oBrowseRE1:aARRAY[oBrowseRE1:nAt][1]
			AADD(aColsCab,oBrowseRE1:aARRAY[oBrowseRE1:nAt])
		ElseIf cPerCons == 'D'
			cPerDuplo := oBrowsDCE1:aARRAY[oBrowsDCE1:nAt][1]
			cCCDuplo  := oBrowsDCE1:aARRAY[oBrowsDCE1:nAt][2]
			cEspDuplo := oBrowsDRE1:aARRAY[oBrowsDRE1:nAt][2]
			AADD(aColsCab,oBrowsDRE1:aARRAY[oBrowsDRE1:nAt])
		Endif
		nAcesso := 1
	ElseIf nAcesso == 1 //Por Especialidade
		If cPerCons == 'U'
			cCCDuplo  := NGSEEK("ST1",oBrowseRE2:aARRAY[oBrowseRE2:nAt][1],1,"T1_CCUSTO")
			cEspDuplo := oBrowseCE2:aARRAY[oBrowseCE2:nAt][1]
			cMatDuplo := oBrowseRE2:aARRAY[oBrowseRE2:nAt][1]
			AADD(aColsCab,oBrowseRE2:aARRAY[oBrowseRE2:nAt])
		ElseIf cPerCons == 'D'
			cPerDuplo := oBrowsDRE2:aARRAY[oBrowsDRE2:nAt][1]
			cCCDuplo  := NGSEEK("ST1",oBrowsDRE2:aARRAY[oBrowsDRE2:nAt][2],1,"T1_CCUSTO")
			cEspDuplo := oBrowsDCE2:aARRAY[oBrowsDCE2:nAt][2]
			cMatDuplo := oBrowsDRE2:aARRAY[oBrowsDRE2:nAt][2]
			AADD(aColsCab,oBrowsDRE2:aARRAY[oBrowsDRE2:nAt])
		Endif
		nAcesso := 2
	Endif
ElseIf cTpAnalise = "D" //Distribuicao
	If nAcesso == 1 //Por Prioridade
		If cPerCons == 'U'
			cPrioDuplo := oBrowseCD2:aARRAY[oBrowseCD2:nAt][1]
			cOrdeDuplo := oBrowseRD2:aARRAY[oBrowseRD2:nAt][2]
			AADD(aColsCab,oBrowseRD2:aARRAY[oBrowseRD2:nAt])
		ElseIf cPerCons == 'D'
			cPerDuplo  := oBrowsDCD2:aARRAY[oBrowsDCD2:nAt][1]
			cPrioDuplo := oBrowsDCD2:aARRAY[oBrowsDCD2:nAt][2]
			cOrdeDuplo := oBrowsDRD2:aARRAY[oBrowsDRD2:nAt][3]
			AADD(aColsCab,oBrowsDRD2:aARRAY[oBrowsDRD2:nAt])
		Endif
		nAcesso := 2
	Endif
ElseIf cTpAnalise = "U" //Utilizacao
	If nAcesso == 0 //Por Centro de Custo
			lCCFun := .F.
		If cPerCons == 'U'
			cCCDuplo  := oBrowseCU1:aARRAY[oBrowseCU1:nAt][1]
			cEspDuplo := oBrowseRU1:aARRAY[oBrowseRU1:nAt][1]
			cCCFDuplo := oBrowseRU1:aARRAY[oBrowseRU1:nAt][4]
			AADD(aColsCab,oBrowseRU1:aARRAY[oBrowseRU1:nAt])
		ElseIf cPerCons == 'D'
			cPerDuplo := oBrowsDCU1:aARRAY[oBrowsDCU1:nAt][1]
			cCCDuplo  := oBrowsDCU1:aARRAY[oBrowsDCU1:nAt][2]
			cEspDuplo := oBrowsDRU1:aARRAY[oBrowsDRU1:nAt][2]
			cCCFDuplo := oBrowsDRU1:aARRAY[oBrowsDRU1:nAt][5]
			AADD(aColsCab,oBrowsDRU1:aARRAY[oBrowsDRU1:nAt])
		Endif
		nAcesso := 1
	ElseIf nAcesso == 1 //Por Especialidade
			lCCFun := .T.
		If cPerCons == 'U'
			cEspDuplo := oBrowseCU2:aARRAY[oBrowseCU2:nAt][1]
			cCCFDuplo := oBrowseCU2:aARRAY[oBrowseCU2:nAt][4]
			cMatDuplo := oBrowseRU2:aARRAY[oBrowseRU2:nAt][1]
			AADD(aColsCab,oBrowseRU2:aARRAY[oBrowseRU2:nAt])
		ElseIf cPerCons == 'D'
			cPerDuplo := oBrowsDCU2:aARRAY[oBrowsDCU2:nAt][1]
			cEspDuplo := oBrowsDCU2:aARRAY[oBrowsDCU2:nAt][2]
			cCCFDuplo := oBrowsDCU2:aARRAY[oBrowsDCU2:nAt][5]
			cMatDuplo := oBrowsDRU2:aARRAY[oBrowsDRU2:nAt][2]
			AADD(aColsCab,oBrowsDRU2:aARRAY[oBrowsDRU2:nAt])
		Endif
		nAcesso := 2
	Endif
Endif

	ChangeObj(.T.)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} CarregaRod
Altera GetDados inferior de acordo a seleÁ„o da getDados principal

@param _nPar, numÈrico, cÛdigo da operaÁ„o
@param _CodEspec
@param _cCodFunc, string, cÛdigo do funcion·rio
@param _cDesFunc, string, nome do funcion·rio
@param _cCusto, string, centro de custo do funcion·rio
@param _nQuanti, numÈrico, quantidade de horas
@param _nProdImpr, numÈrico, indica se È atividade produtiva: 1=Produtiva;2=Improdutiva
@param _cCCdaOS, string, Centro de Custo da ordem
@param _cOrdemSer, string, n˙mero da ordem de serviÁo
@param _cPctHrExt, string, hora extra
@param _cSTLouTTL, string, nome da tabela
@param _cPerCons, indefinido
@param [nQtDecimal], numÈrico, quantidade de horas em decimais

@author Marcos Wagner Junior
@since	20/07/2009
/*/
//---------------------------------------------------------------------
Static Function CarregaRod(_nPar,_CodEspec,_cCodFunc,_cDesFunc,_cCusto,_nQuanti,_nProdImpr,_cCCdaOS,_cOrdemSer,;
								_cPctHrExt,_cSTLouTTL,_cPerCons, nQtDecimal)

	Local nQuantPro   := 0
	Local nQuantImp   := 0
	Local cObserva    := ""
	Local cDescEtapa  := ""
	Local cDescTarefa := ""
	Local cTipoMan    := ""
	Local aOldArea    := GetArea()

	Default nQtDecimal := IIF( Valtype( _nQuanti ) == 'N', _nQuanti, HTON( _nQuanti ) )

	_nQuanti := IIF(Valtype(_nQuanti)=='N',_nQuanti,HTON(_nQuanti))

	If Empty(_CodEspec)
		_CodEspec := Space(Len(ST2->T2_ESPECIA)) //Tratamento para quando o funcionario nao tiver especialidade
	Endif

	If _nProdImpr == 1
		nQuantPro := _nQuanti
	Else
		nQuantImp := _nQuanti
	Endif

	If !Empty(_CodEspec)
		cDesEspec := NGSEEK("ST0",_CodEspec,1,"T0_NOME")
	Else
		cDesEspec := STR0165 //"N„o possui especialidade"
	Endif

	nCorretiva := 0
	nPreventiv := 0

	If _nPar == 3 .Or. _nPar == 4 .Or. _nPar == 7 // UtilizaÁ„o
		If lCorretiva
			nCorretiva := _nQuanti
		Else
			nPreventiv := _nQuanti
		Endif
	Endif

	If _nPar == 1
		If !lDetalhado
			nPos := aSCAN(aColsInfer,{|x| x[1]+x[2] == _cCusto+_CodEspec })
			If nPos == 0
				aAdd(aColsInfer,{_cCusto,_CodEspec,cDesEspec,1,nQuantPro,0,0,nQuantImp,0,0,0,0,0})
			Else //Detalhado
				aColsInfer[nPos][5] := somahoras(aColsInfer[nPos][5],nQuantPro)
				aColsInfer[nPos][8] := somahoras(aColsInfer[nPos][8],nQuantImp)
			Endif
		Else
			nPos := aSCAN(aColsInfer,{|x| x[1]+x[2]+x[3] == _cPerCons+_cCusto+_CodEspec })
			If nPos == 0
				aAdd(aColsInfer,{_cPerCons,_cCusto,_CodEspec,cDesEspec,1,nQuantPro,0,0,nQuantImp,0,0,0,0,0})
			Else
				aColsInfer[nPos][6] := somahoras(aColsInfer[nPos][6],nQuantPro)
				aColsInfer[nPos][9] := somahoras(aColsInfer[nPos][9],nQuantImp)
			Endif
		Endif
	ElseIf _nPar == 2
			If (!lDetalhado .And. (!lDuploClick .Or. (lDuploClick .And. _cCusto == cCCDuplo .And. _CodEspec == cEspDuplo))) .Or.;
					(lDetalhado .And. (!lDuploClick .Or. (lDuploClick .And. _cCusto == cCCDuplo .And. _CodEspec == cEspDuplo .And. _cPerCons == cPerDuplo)))
			If !lDetalhado
				nPos := aSCAN(aColsInfer,{|x| x[1]+x[2] == _CodEspec+_cCodFunc })
				If nPos == 0
					aAdd(aColsInfer,{_CodEspec,_cCodFunc,_cDesFunc,nQuantPro,0,nQuantImp,0,0,0,0,_cCusto})
				Else
					aColsInfer[nPos][4] := somahoras(aColsInfer[nPos][4],nQuantPro)
					aColsInfer[nPos][6] := somahoras(aColsInfer[nPos][6],nQuantImp)
				Endif
			Else
				nPos := aSCAN(aColsInfer,{|x| x[1]+x[2]+x[3] == _cPerCons+_CodEspec+_cCodFunc })
				If nPos == 0
					aAdd(aColsInfer,{_cPerCons,_CodEspec,_cCodFunc,_cDesFunc,nQuantPro,0,nQuantImp,0,0,0,0,_cCusto})
				Else
					aColsInfer[nPos][5] := somahoras(aColsInfer[nPos][5],nQuantPro)
					aColsInfer[nPos][7] := somahoras(aColsInfer[nPos][7],nQuantImp)
				Endif
			Endif
		Endif
	ElseIf _nPar == 3
		If !lDetalhado
			nPos := aSCAN(aColsInfer,{|x| x[1]+x[2]+x[5] == _cCCdaOS+_CodEspec+_cCusto })
			If nPos == 0
				aAdd(aColsInfer,{_cCCdaOS,_CodEspec,cDesEspec,0,_cCusto,nPreventiv,0,0,nCorretiva,0,0,0})
			Else
				aColsInfer[nPos][6] := somahoras(aColsInfer[nPos][6],nPreventiv)
				aColsInfer[nPos][9] := somahoras(aColsInfer[nPos][9],nCorretiva)
			Endif

			//Alimenta GetDados Inferior
			nPos := IIF(nPos==0,Len(aColsInfer),nPos)
			aColsInfer[nPos][7]  += IIf( nPreventiv == 0, 0, nQtDecimal * nCustoMSta ) //Valor preventiva (Custo Medio ou Standard)
			aColsInfer[nPos][10] += IIf( nCorretiva == 0, 0, nQtDecimal * nCustoMSta ) //Valor corretiva (Custo Medio ou Standard)
		Else
			nPos := aSCAN(aColsInfer,{|x| x[1]+x[2]+x[3]+x[6] == _cPerCons+_cCCdaOS+_CodEspec+_cCusto })
			If nPos == 0
				aAdd(aColsInfer,{_cPerCons,_cCCdaOS,_CodEspec,cDesEspec,0,_cCusto,nPreventiv,0,0,nCorretiva,0,0,0})
			Else
				aColsInfer[nPos][7]  := somahoras(aColsInfer[nPos][7],nPreventiv)
				aColsInfer[nPos][10] := somahoras(aColsInfer[nPos][10],nCorretiva)
			Endif

			//Alimenta GetDados Inferior
			nPos := IIF(nPos==0,Len(aColsInfer),nPos)
			aColsInfer[nPos][8]  += IIf( nPreventiv == 0, 0, nQtDecimal * nCustoMSta ) //Valor (Custo Medio ou Standard)
			aColsInfer[nPos][11] += IIf( nCorretiva == 0, 0, nQtDecimal * nCustoMSta ) //Valor (Custo Medio ou Standard)
		Endif
	ElseIf _nPar == 4
			If (!lDetalhado .And. (!lDuploClick .Or. (lDuploClick .And. cCodCCusto == cCCDuplo .And. _CodEspec == cEspDuplo .And. _cCusto == cCCFDuplo))) .Or.;
					(lDetalhado .And. (!lDuploClick .Or. (lDuploClick .And. cCodCCusto == cCCDuplo .And. _CodEspec == cEspDuplo .And. _cCusto == cCCFDuplo .And. _cPerCons == cPerDuplo)))
			If !lDetalhado
				nPos := aSCAN(aColsInfer,{|x| x[1]+x[2]+x[3] == _CodEspec+_cCusto+_cCodFunc })
				If nPos == 0
					aAdd(aColsInfer,{_CodEspec,_cCusto,_cCodFunc,_cDesFunc,nPreventiv,0,0,nCorretiva,0,0,0})
				Else
					aColsInfer[nPos][5] := somahoras(aColsInfer[nPos][5],nPreventiv)
					aColsInfer[nPos][8] := somahoras(aColsInfer[nPos][8],nCorretiva)
				Endif
				//Alimenta GetDados Inferior
				nPos := IIF(nPos==0,Len(aColsInfer),nPos)
				aColsInfer[nPos][6] += IIf( nPreventiv == 0, 0, nQtDecimal * nCustoMSta ) //Valor (Custo Medio ou Standard)
				aColsInfer[nPos][9] += IIf( nCorretiva == 0, 0, nQtDecimal * nCustoMSta ) //Valor (Custo Medio ou Standard)
			Else
				nPos := aSCAN(aColsInfer,{|x| x[1]+x[2]+x[3]+x[4] == _cPerCons+_CodEspec+_cCusto+_cCodFunc })
				If nPos == 0
					aAdd(aColsInfer,{_cPerCons,_CodEspec,_cCusto,_cCodFunc,_cDesFunc,nPreventiv,0,0,nCorretiva,0,0,0})
				Else
					aColsInfer[nPos][6] := somahoras(aColsInfer[nPos][6],nPreventiv)
					aColsInfer[nPos][9] := somahoras(aColsInfer[nPos][9],nCorretiva)
				Endif

				//Alimenta GetDados Inferior
				nPos := IIF(nPos==0,Len(aColsInfer),nPos)
				aColsInfer[nPos][7] += IIf( nPreventiv == 0, 0, nQtDecimal * nCustoMSta ) //Valor (Custo Medio ou Standard)
				aColsInfer[nPos][10] += IIf( nCorretiva == 0, 0, nQtDecimal * nCustoMSta ) //Valor (Custo Medio ou Standard)

			Endif
		Endif
	ElseIf _nPar == 5
		If !lDetalhado
			nPos := aSCAN(aColsInfer,{|x| x[1]+x[2] == _cCusto+_CodEspec })
			If nPos == 0
				aAdd(aColsInfer,{_cCusto,_CodEspec,cDesEspec,nPrevista,nRealizada,0,0,nHrExtras})
			Else
				aColsInfer[nPos][4] := somahoras(aColsInfer[nPos][4],nPrevista)
				aColsInfer[nPos][5] := somahoras(aColsInfer[nPos][5],nRealizada)
				aColsInfer[nPos][8] := somahoras(aColsInfer[nPos][8],nHrExtras)
			Endif
		Else
			nPos := aSCAN(aColsInfer,{|x| x[1]+x[2]+x[3] == _cPerCons+_cCusto+_CodEspec })
			If nPos == 0
				aAdd(aColsInfer,{_cPerCons,_cCusto,_CodEspec,cDesEspec,nPrevista,nRealizada,0,0,nHrExtras})
			Else
				aColsInfer[nPos][5] := somahoras(aColsInfer[nPos][5],nPrevista)
				aColsInfer[nPos][6] := somahoras(aColsInfer[nPos][6],nRealizada)
				aColsInfer[nPos][9] := somahoras(aColsInfer[nPos][9],nHrExtras)
			Endif
		Endif
	ElseIf _nPar == 6
			If (!lDetalhado .And. (!lDuploClick .Or. (lDuploClick .And. _cCusto == cCCDuplo .And. _CodEspec == cEspDuplo))) .Or.;
					(lDetalhado .And. (!lDuploClick .Or. (lDuploClick .And. _cCusto == cCCDuplo .And. _CodEspec == cEspDuplo .And. _cPerCons == cPerDuplo)))
			If !lDetalhado
				nPos := aSCAN(aColsInfer,{|x| x[1]+x[2] == _CodEspec+_cCodFunc })
				If nPos == 0
					aAdd(aColsInfer,{_CodEspec,_cCodFunc,_cDesFunc,nPrevista,nRealizada,0,0,nHrExtras})
				Else
					aColsInfer[nPos][4] := somahoras(aColsInfer[nPos][4],nPrevista)
					aColsInfer[nPos][5] := somahoras(aColsInfer[nPos][5],nRealizada)
					aColsInfer[nPos][8] := somahoras(aColsInfer[nPos][8],nHrExtras)
				Endif
			Else
				nPos := aSCAN(aColsInfer,{|x| x[1]+x[2]+x[3] == _cPerCons+_CodEspec+_cCodFunc })
				If nPos == 0
					aAdd(aColsInfer,{_cPerCons,_CodEspec,_cCodFunc,_cDesFunc,nPrevista,nRealizada,0,0,nHrExtras})
				Else
					aColsInfer[nPos][5] := somahoras(aColsInfer[nPos][5],nPrevista)
					aColsInfer[nPos][6] := somahoras(aColsInfer[nPos][6],nRealizada)
					aColsInfer[nPos][9] := somahoras(aColsInfer[nPos][9],nHrExtras)
				Endif
			Endif
		Endif
	ElseIf _nPar == 7 //Utilizacao x Funcionario
		If !Empty(cCCDuplo)
			cCCDup := cCCDuplo
		Else
			cCCDup := cCCFDuplo
		Endif
			If (!lDetalhado .And. (!lDuploClick .Or. (lDuploClick .And. _CodEspec == cEspDuplo .And. _cCusto == cCCDup .And. _cCodFunc == cMatDuplo))) .Or.;
					(lDetalhado .And. (!lDuploClick .Or. (lDuploClick .And. _CodEspec == cEspDuplo .And. _cCusto == cCCDup .And. _cCodFunc == cMatDuplo .And. _cPerCons == cPerDuplo)))

			If _cSTLouTTL == "STL"

				dbSelectArea("STJ")
				dbSetOrder(1)
				dbSeek(xFilial("STJ")+_cOrdemSer)
				c_SERVICO := STJ->TJ_SERVICO
				cTIPOOS   := STJ->TJ_TIPOOS
				cCODBEM   := STJ->TJ_CODBEM
				d_DTMRINI := STJ->TJ_DTMRINI
				c_HOMRINI := STJ->TJ_HOMRINI
				d_DTMRFIM := STJ->TJ_DTMRFIM
				c_HOMRFIM := STJ->TJ_HOMRFIM
				c_CCUSTO  := STJ->TJ_CCUSTO
			ElseIf _cSTLouTTL == "STT"
				dbSelectArea("STS")
				dbSetOrder(1)
				dbSeek(xFilial("STS")+_cOrdemSer)
				c_SERVICO := STS->TS_SERVICO
				cTIPOOS   := STS->TS_TIPOOS
				cCODBEM   := STS->TS_CODBEM
				d_DTMRINI := STS->TS_DTMRINI
				c_HOMRINI := STS->TS_HOMRINI
				d_DTMRFIM := STS->TS_DTMRFIM
				c_HOMRFIM := STS->TS_HOMRFIM
				c_CCUSTO  := STS->TS_CCUSTO
			Endif

			dbSelectArea("STQ")
			dbSetOrder(1)
			dbSeek(xFilial("STQ")+_cOrdemSer+cPlano+cTarefa+cEtapa)
			cObserva := STQ->TQ_OBSERVA

			dbSelectArea("TT9")
			dbSetOrder(1)
			dbSeek(xFilial("TT9")+cTarefa)
			cDescTarefa := TT9->TT9_DESCRI

			dbSelectArea("ST4")
			dbSetOrder(1)
			dbSeek(xFilial("ST4")+c_SERVICO)

			dbSelectArea("STE")
			dbSetOrder(1)
			dbSeek(xFilial("STE")+ST4->T4_TIPOMAN)
			cTipoMan := NGRETSX3BOX("TE_CARACTE",STE->TE_CARACTE)

			nCustoPouC := nQtDecimal * nCustoMSta
			nTotalHora := nPreventiv + nCorretiva
			cDescEtapa := NGSEEK("TPA",cEtapa,1,"TPA->TPA_DESCRI")

			If cTIPOOS == 'B'
				nNomeBem := NGSEEK("ST9",cCODBEM,1,"ST9->T9_NOME")
			Else
				nNomeBem := NGSEEK("TAF","X2"+Substr(cCODBEM,1,3),7,"SUBSTR(TAF_NOMNIV,1,30)")
			Endif

			If !lDetalhado
					aAdd(aColsInfer,{_cCodFunc, c_SERVICO, _cOrdemSer, cTipoMan, cCODBEM, dDtInici, cHrInici,;
									dDtFim, cHrFim, nTotalHora, nCustoPouC, 0, cTarefa, cEtapa, cDescEtapa, cObserva})
					aAdd(aColsOSxFu,{_cCodFunc,_cOrdemSer,cCODBEM,nNomeBem,c_CCUSTO,;
											c_SERVICO,ST4->T4_NOME,dDtInici,cHrInici,dDtFim,cHrFim,;
											AllTrim(_cDesFunc),AllTrim(_CodEspec),AllTrim(cDesEspec),AllTrim(_cCusto),;
											AllTrim(NGSEEK("CTT",_cCusto,1,"CTT_DESC01")),cEtapa,cDescEtapa,cObserva,AllTrim(cTarefa),AllTrim(cDescTarefa)})
			Else
					aAdd(aColsInfer,{_cPerCons, _cCodFunc, c_SERVICO,_cOrdemSer, cTipoMan, cCODBEM, dDtInici, cHrInici,;
									dDtFim, cHrFim, nTotalHora, nCustoPouC, 0, cTarefa, cEtapa, cDescEtapa, cObserva})
					aAdd(aColsOSxFu,{_cPerCons,_cCodFunc,_cOrdemSer,cCODBEM,nNomeBem,c_CCUSTO,;
											c_SERVICO,ST4->T4_NOME,dDtInici,cHrInici,dDtFim,cHrFim,;
											AllTrim(_cDesFunc),AllTrim(_CodEspec),AllTrim(cDesEspec),AllTrim(_cCusto),;
											AllTrim(NGSEEK("CTT",_cCusto,1,"CTT_DESC01")),cEtapa,cDescEtapa,cObserva,AllTrim(cTarefa),AllTrim(cDescTarefa)})
			Endif
		Endif
	ElseIf _nPar == 8 //Eficiencia x Funcionario

	ElseIf _nPar == 9 //Ociosidade x Funcionario
			If (!lDetalhado .And. (!lDuploClick .Or. (lDuploClick .And. _cCusto == cCCDuplo .And. _CodEspec == cEspDuplo .And. _cCodFunc == cMatDuplo))) .Or.;
					(lDetalhado .And. (!lDuploClick .Or. (lDuploClick .And. _cCusto == cCCDuplo .And. _CodEspec == cEspDuplo .And. _cCodFunc == cMatDuplo .And. _cPerCons == cPerDuplo)))
			nValExtra := 0
			cDescHora := ""
			nValExtra := ( nCustoMSta / 60 ) * Hrs2Min( _nQuanti )
			If _nProdImpr == 1
					If nHrExtras > 0 .And. !Empty(_cPctHrExt)
					cDescHora := STR0085 //"Extra "
						If _cSTLouTTL == 'STL' .Or. _cSTLouTTL == 'STT'
						If lPcthrex
							cDescHora += AllTrim(Str(_cPctHrExt))
							nValExtra := nValExtra + ((nCustoMSta /100) * _cPctHrExt)
						Else
							cDescHora += NGRETSX3BOX('TL_HREXTRA',AllTrim(_cPctHrExt))
							nValExtra := nValExtra + ((nCustoMSta /100) * _cPctHrExt)
						Endif
					ElseIf _cSTLouTTL == 'TTL'
						cDescHora += AllTrim(Str(_cPctHrExt))
						nValExtra := nValExtra + ((nCustoMSta /100) * _cPctHrExt)
					Endif
					nAt := At('.00',cDescHora)
					If nAt > 0
						cDescHora := SubStr(cDescHora,1,nAt-1)
					Endif
					cDescHora += '%'
				Else
					cDescHora := STR0084 //"Normal"
				Endif
			Else
				cDescHora := (cAliasQry)->TTJ_DESCRI
			Endif

			If !lDetalhado
				nPos := aSCAN(aColsInfer,{|x| x[1]+x[2] == _cCodFunc+cDescHora })
				If nPos == 0
					aAdd(aColsInfer,{_cCodFunc,cDescHora,_nQuanti,0,nValExtra})
				Else
					aColsInfer[nPos][3] := somahoras(aColsInfer[nPos][3],_nQuanti)
					aColsInfer[nPos][5] += nValExtra
				Endif
			Else
				nPos := aSCAN(aColsInfer,{|x| x[1]+x[2]+x[3] == _cPerCons+_cCodFunc+cDescHora })
				If nPos == 0
					aAdd(aColsInfer,{_cPerCons,_cCodFunc,cDescHora,_nQuanti,0,nValExtra})
				Else
					aColsInfer[nPos][4] := somahoras(aColsInfer[nPos][4],_nQuanti)
					aColsInfer[nPos][6] += nValExtra
				Endif
			Endif
		Endif
	Endif

	RestArea(aOldArea)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} OciosidxCC
Carrega arrays quando selecionado Ociosidade por CC

@author Marcos Wagner Junior
@since  24/02/2009
@version MP11
@return
/*/
//---------------------------------------------------------------------
Static Function OciosidxCC()

Local nI := 0
Local nX := 0
Local nTotCabPro := 0
Local nTotCabImp := 0
Local lExistPos  := .T.
Local nSizeaCols := Len( aColsCab )

QuerySTL(1)

For nI := 1 to Len(aColsCab)
	aColsCab[nI][4+nP] := Round(aColsCab[nI][4+nP],2)
	aColsCab[nI][7+nP] := Round(aColsCab[nI][7+nP],2)

	aColsCab[nI][9+nP] := SomaHoras(aColsCab[nI][3+nP],aColsCab[nI][6+nP] ) //Total Geral do CC

	aColsCab[nI][5+nP] := Round(aColsCab[nI][3+nP]/aColsCab[nI][9+nP]*100,2) //Total Produtivas do CC
	aColsCab[nI][8+nP] := Round(aColsCab[nI][6+nP]/aColsCab[nI][9+nP]*100,2) //Total Improdutivas do CC

	nTotCabPro := SomaHoras( nTotCabPro,aColsCab[nI][3+nP] )
	nTotCabImp := SomaHoras( nTotCabImp,aColsCab[nI][6+nP] )

	aColsCab[nI][3+nP] := aColsCab[nI][3+nP]
	aColsCab[nI][6+nP] := aColsCab[nI][6+nP]

	If lDetalhado
		For nX := 1 to Len(aEspecHora)
			If aEspecHora[nX][5] == aColsCab[nI][1] .And. aEspecHora[nX][1] == aColsCab[nI][2]
				aColsCab[nI][11] := SomaHoras(aColsCab[nI][11],aEspecHora[nX][3])
			Endif
		Next
	Else
		For nX := 1 to Len(aEspecHora)
			If aEspecHora[nX][1] == aColsCab[nI][1]
				aColsCab[nI][10] := SomaHoras(aColsCab[nI][10],aEspecHora[nX][3])
			Endif
		Next
	Endif

	If aColsCab[nI][10+nP]-aColsCab[nI][9+nP] <= 0
		aColsCab[nI][11+nP] := NTOH(0)
	Else
		aColsCab[nI][11+nP] := NgTraNtoH(SubHoras(aColsCab[nI][10+nP],aColsCab[nI][9+nP]))
	EndIf

	If aColsCab[nI][10+nP] <= 0
		aColsCab[nI][10+nP] := NTOH(0)
	Else
		aColsCab[nI][10+nP] := NgTraNtoH(aColsCab[nI][10+nP])
	EndIf

	aColsCab[nI][9+nP] := IIf( aColsCab[nI][9+nP]  <= 0, NTOH(0), NgTraNtoH(aColsCab[nI][9+nP]))
	aColsCab[nI][6+nP] := IIf( aColsCab[nI][6+nP]  <= 0, NTOH(0), NgTraNtoH(aColsCab[nI][6+nP]))
	aColsCab[nI][3+nP] := IIf( aColsCab[nI][3+nP]  <= 0, NTOH(0), NgTraNtoH(aColsCab[nI][3+nP]))

	CalcuHora(1,nI)
Next

For nI := 1 to Len(aColsInfer)
	aColsInfer[nI][11+nP] := SomaHoras( aColsInfer[nI][5+nP],aColsInfer[nI][8+nP]) //Total Geral do CC

	aColsInfer[nI][7+nP]  := Round(aColsInfer[nI][5+nP]/aColsInfer[nI][11+nP]*100,2) //Total Produtivas do CC
	aColsInfer[nI][10+nP] := Round(aColsInfer[nI][8+nP]/aColsInfer[nI][11+nP]*100,2) //Total Improdutivas do CC

	aColsInfer[nI][5+nP] := aColsInfer[nI][5+nP]
	aColsInfer[nI][8+nP] := aColsInfer[nI][8+nP]

	nTotDispCC := 0
	dbSelectArea("ST1")
	dbSetOrder(3)
	If dbSeek(xFilial("ST1")+aColsInfer[nI][1+nP])

		If cTpCusto == 'S'
			aColsInfer[nI][6+nP] := SomaHoras( aColsInfer[nI][6+nP],aColsInfer[nI][5+nP] * ST1->T1_SALARIO ) //Valor (Custo Medio ou Standard)
			aColsInfer[nI][9+nP] := SomaHoras( aColsInfer[nI][9+nP],aColsInfer[nI][8+nP] * ST1->T1_SALARIO ) //Valor (Custo Medio ou Standard)
		Else
			cCusMedio := NGSEEK("SB2",'MOD'+AllTrim(aColsInfer[nI][1+nP]),1,"B2_CM1")
			If ValType(cCusMedio) == "C"
				cCusMedio := 0
			Endif
			aColsInfer[nI][6+nP] := SomaHoras( aColsInfer[nI][6+nP],aColsInfer[nI][5+nP] * cCusMedio ) //Valor (Custo Medio ou Standard)
			aColsInfer[nI][9+nP] := SomaHoras( aColsInfer[nI][9+nP],aColsInfer[nI][8+nP] * cCusMedio ) //Valor (Custo Medio ou Standard)
		Endif

	Endif

	aColsInfer[nI][6+nP]  := Round(aColsInfer[nI][6+nP],2)
	aColsInfer[nI][9+nP]  := Round(aColsInfer[nI][9+nP],2)
	If !lTurnoFlut
		If lDetalhado
			nPos := aSCAN(aEspecHora,{|x| x[5]+x[1]+x[2] == aColsInfer[nI][1]+aColsInfer[nI][2]+aColsInfer[nI][3] })
		Else
			nPos := aSCAN(aEspecHora,{|x| x[1]+x[2] == aColsInfer[nI][1]+aColsInfer[nI][2] })
		Endif
		aColsInfer[nI][12+nP] := IIF( aEspecHora[nPos][3] == 0, NTOH( 0 ), NgTraNtoH( aEspecHora[nPos][3] ) )
		aColsInfer[nI][13+nP] := NgTraNtoH(IIF(aEspecHora[nPos][3] - aColsInfer[nI][11+nP] < 0,0, SubHoras( aEspecHora[nPos][3],aColsInfer[nI][11+nP] )))
	Else
		If lDetalhado //ST1->T1_CCUSTO,ST2->T2_ESPECIA,aPerAcols[nI],nTLQUANTID
			nPOS := aSCAN(aFunxHras,{|x| x[4]+x[1]+x[2] == aColsInfer[nI][1]+aColsInfer[nI][2]+aColsInfer[nI][3] })
		Else
			nPOS := aSCAN(aFunxHras,{|x| x[1]+x[2] == aColsInfer[nI][1]+aColsInfer[nI][2] })
		Endif

		If nPOS == 0
			aColsInfer[nI][12+nP]  := 0
		Else
			aColsInfer[nI][12+nP]  := aFunxHras[nPOS][3]
		Endif

		If lDetalhado
			//Busca na GetDados Superior o Total de Horas
			nPosPai := aSCAN(aColsCab,{|x| x[1]+x[2] == aColsInfer[nI][1]+aColsInfer[nI][2] })
		Else
			//Busca na GetDados Superior o Total de Horas
			nPosPai := aSCAN(aColsCab,{|x| x[1] == aColsInfer[nI][1] })
		Endif

		// Verifica array aColsCab para inserir novos valores, caso contr·rio atribui a uma posiÁ„o j· existente.
		lExistPos := nSizeaCols >= nI

		If SomaHoras(aColsCab[nPosPai][10+nP],aColsInfer[nI][12+nP]) <= 0 .And. lExistPos
			aColsCab[nI][10+nP] := NgTraNtoH(0)
		Else
			aColsCab[nPosPai][10+nP] := MTOH(HTOM(aColsCab[nPosPai][10+nP])+HTOM(NTOH(aColsInfer[nI][12+nP])))
		EndIf

		If lExistPos .And. SubHoras(aColsCab[nI][10+nP],aColsCab[nI][9+nP]) <= 0
			aColsCab[nI][11+nP] := NgTraNtoH(0)
		Else
			aColsCab[nPosPai][11+nP] := MTOH(HTOM(aColsCab[nPosPai][10+nP])-HTOM(aColsCab[nPosPai][9+nP]))
		EndIf

		aColsInfer[nI][13+nP]	 := SubHoras( aColsInfer[nI][12+nP],aColsInfer[nI][11+nP] )
		aColsInfer[nI][12+nP]	 := IIF( aColsInfer[nI][12+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsInfer[nI][12+nP] ) )
		aColsInfer[nI][13+nP]	 := IIF( aColsInfer[nI][13+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsInfer[nI][13+nP] ) )

	Endif

	aColsInfer[nI][11+nP] := IIf(aColsInfer[nI][11+nP] <= 0, NTOH(0), NgTraNtoH(aColsInfer[nI][11+nP]))
	aColsInfer[nI][8+nP]  := IIf(aColsInfer[nI][8+nP]  <= 0, NTOH(0), NgTraNtoH(aColsInfer[nI][8+nP] ))
	aColsInfer[nI][5+nP]  := IIf(aColsInfer[nI][5+nP]  <= 0, NTOH(0), NgTraNtoH(aColsInfer[nI][5+nP] ))
	aColsInfer[nI][6+nP]  := Round(aColsInfer[nI][6+nP],2)
	aColsInfer[nI][9+nP]  := Round(aColsInfer[nI][9+nP],2)
Next

	cCabecSup1 := STR0077 + IIF( nTotCabPro == 0, NTOH( 0 ), NgTraNtoH( nTotCabPro ) ) + STR0078 //"Total Produtivas: "###" horas"
	cCabecSup2 := STR0079 + IIF( nTotCabImp == 0, NTOH( 0 ), NgTraNtoH( nTotCabImp ) ) + STR0078 //"Total Improdutivas: "###" horas"

If nSizeaCols > 0
	CriaRodape(cCabecSup1,cCabecSup2,oPnlCenRod,1)
Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} OciosidxEs
Carrega arrays quando selecionado Ociosidade por Especialidade

@author Marcos Wagner Junior
@since  24/02/2009
@version MP11
@return
/*/
//---------------------------------------------------------------------
Static Function OciosidxEs()

Local nI         := 0
Local nX         := 0
Local nTotCabPro := 0
Local nTotCabImp := 0

QuerySTL(2)

If !lDuploClick
	For nI := 1 to Len(aColsCab)

		aColsCab[nI][10+nP] := aColsCab[nI][4+nP]+aColsCab[nI][7+nP] //Total Geral da Especialidade
		aColsCab[nI][6+nP]	:= Round(aColsCab[nI][4+nP]/aColsCab[nI][10+nP]*100,2) //Total Produtivas da Especialidade
		aColsCab[nI][9+nP]	:= Round(aColsCab[nI][7+nP]/aColsCab[nI][10+nP]*100,2) //Total Improdutivas da Especialidade

		nTotCabPro := SomaHoras( nTotCabPro,aColsCab[nI][4+nP] )
		nTotCabImp := SomaHoras( nTotCabImp,aColsCab[nI][7+nP] )

		If !lTurnoFlut
			For nX := 1 to Len(aEspecHora)
				If lDetalhado
					If aEspecHora[nX][5] == aColsCab[nI][1] .And. aEspecHora[nX][2] == aColsCab[nI][2]
						aColsCab[nI][12] := SomaHoras( aColsCab[nI][12],aEspecHora[nX][3] )
					Endif
				Else
					If aEspecHora[nX][2] == aColsCab[nI][1]
						aColsCab[nI][11] := SomaHoras( aColsCab[nI][11],aEspecHora[nX][3] )
					Endif
				Endif
			Next
		Endif

			aColsCab[nI][12+nP] := SubHoras( aColsCab[nI][11+nP],aColsCab[nI][10+nP] )
			aColsCab[nI][4+nP]	:= IIf(aColsCab[nI][4+nP]  <= 0, NTOH(0),NgTraNtoH(aColsCab[nI][4+nP] ))
			aColsCab[nI][7+nP]	:= IIf(aColsCab[nI][7+nP]  <= 0, NTOH(0),NgTraNtoH(aColsCab[nI][7+nP] ))
			aColsCab[nI][10+nP] := IIf(aColsCab[nI][10+nP] <= 0, NTOH(0),NgTraNtoH(aColsCab[nI][10+nP]))

			If aColsCab[nI][11+nP] <= 0
				aColsCab[nI][11+nP] := NTOH(0)
			Else
				aColsCab[nI][11+nP] := NgTraNtoH(aColsCab[nI][11+nP])
			EndIf

			If aColsCab[nI][12+nP] <= 0
				aColsCab[nI][12+nP] := NTOH(0)
			Else
				aColsCab[nI][12+nP] := NgTraNtoH(aColsCab[nI][12+nP])
			EndIf

	Next
Else
	nTotCabPro := HTON(aColsCab[1][4+nP])
	nTotCabImp := HTON(aColsCab[1][7+nP])
Endif

For nI := 1 to Len( aColsInfer )

	aColsInfer[nI][8+nP] := SomaHoras( aColsInfer[nI][4+nP],aColsInfer[nI][6+nP] ) //Total Geral da Especialidade
	aColsInfer[nI][5+nP] := Round(aColsInfer[nI][4+nP]/aColsInfer[nI][8+nP]*100,2) //Total Produtivas da Especialidade
	aColsInfer[nI][7+nP] := Round(aColsInfer[nI][6+nP]/aColsInfer[nI][8+nP]*100,2) //Total Improdutivas da Especialidade

	If !lTurnoFlut
		If lDetalhado
			nPOS := aSCAN(aTurnoST1,{|x| x[3]+x[1] == aColsInfer[nI][1]+NGSEEK("ST1",aColsInfer[nI][3],1,"T1_TURNO") })
		Else
			nPOS := aSCAN(aTurnoST1,{|x| x[1] == NGSEEK("ST1",aColsInfer[nI][2],1,"T1_TURNO") })
		Endif
		aColsInfer[nI][9+nP]  := aTurnoST1[nPOS][2]
			aColsInfer[nI][10+nP] := SubHoras( aTurnoST1[nPOS][2],aColsInfer[nI][8+nP] )
	Else
		If lDetalhado
			nPOS := aSCAN(aFunxHras,{|x| x[3]+x[1] == aColsInfer[nI][1]+aColsInfer[nI][3] })
		Else
			nPOS := aSCAN(aFunxHras,{|x| x[1] == aColsInfer[nI][2] })
		Endif
		If nPOS == 0
			aColsInfer[nI][9+nP]  := 0
				aColsInfer[nI][10+nP] := SubHoras( aColsInfer[nI][10+nP],aColsInfer[nI][8+nP] )
		Else
			aColsInfer[nI][9+nP]  := aFunxHras[nPOS][2]
				aColsInfer[nI][10+nP] := SubHoras( aFunxHras[nPOS][2],aColsInfer[nI][8+nP] )
		Endif

		If lDetalhado
			//Busca na GetDados Superior o Total de Horas
			nPosPai := aSCAN(aColsCab,{|x| x[1]+x[2] == aColsInfer[nI][1]+aColsInfer[nI][2] })
		Else
			//Busca na GetDados Superior o Total de Horas
			nPosPai := aSCAN(aColsCab,{|x| x[1] == aColsInfer[nI][1] })
		Endif
		If !lDuploClick
			
			aColsCab[nPosPai,11+nP] := IIf( SomaHoras( aColsCab[nPosPai,11+nP], aColsInfer[nI,9+nP] ) <= 0, NgTraNToH( 0 ),;
				MToH( HToM( aColsCab[nPosPai,11+nP] ) + HToM( NToH( aColsInfer[nI,9+nP] ) ) ) )
			
			aColsCab[nPosPai,12+nP] := IIf( SubHoras( aColsCab[nPosPai,11+nP], aColsCab[nPosPai,10+nP] ) <= 0, NgTraNToH( 0 ),;
				MToH( HToM(aColsCab[nPosPai,11+nP] ) - HToM( aColsCab[nPosPai,10+nP] ) ) )

		Endif
	Endif

		aColsInfer[nI][4+nP]  := IIf(aColsInfer[nI][4+nP]  <= 0, NTOH(0), NgTraNtoH(aColsInfer[nI][4+nP] ))
		aColsInfer[nI][6+nP]  := IIf(aColsInfer[nI][6+nP]  <= 0, NTOH(0), NgTraNtoH(aColsInfer[nI][6+nP] ))
		aColsInfer[nI][8+nP]  := IIf(aColsInfer[nI][8+nP]  <= 0, NTOH(0), NgTraNtoH(aColsInfer[nI][8+nP] ))
		aColsInfer[nI][9+nP]  := IIf(aColsInfer[nI][9+nP]  <= 0, NTOH(0), NgTraNtoH(aColsInfer[nI][9+nP] ))
		aColsInfer[nI][10+nP] := IIf(aColsInfer[nI][10+nP] <= 0, NTOH(0), NgTraNtoH(aColsInfer[nI][10+nP]))

	If !lDuploClick
		CalcuHora(2,nI)
	Endif
Next

If !lDuploClick
		cCabecSup1 := STR0077 + IIF( nTotCabPro == 0, NTOH( 0 ), NgTraNtoH( nTotCabPro ) ) + STR0078 //"Total Produtivas: "###" horas"
		cCabecSup2 := STR0079 + IIF( nTotCabImp == 0, NTOH( 0 ), NgTraNtoH( nTotCabImp ) ) + STR0078 //"Total Improdutivas: "###" horas"
Else
	cCabecSup1 := STR0086+cCCDuplo //"Centro de Custo: "
		cCabecSup2 := ""
Endif

If Len(aColsCab) > 0
	CriaRodape(cCabecSup1,cCabecSup2,oPnlCenRod,1)
Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} OciosidxFu
Carrega arrays quando selecionado Ociosidade por funcion·rio
@type static

@author Marcos Wagner Junior
@since  24/02/2009

@sample OciosidxFu()

@return
/*/
//---------------------------------------------------------------------
Static Function OciosidxFu()

	Local nI         := 0
	Local nTotCabPro := 0
	Local nTotCabImp := 0
	Local nPosCalend := IIf(lDetalhado, 11, 10)

	QuerySTL(9)

	If !lDuploClick
		For nI := 1 To Len(aColsCab)

			aColsCab[nI][7+nP] := SOmahoras(aColsCab[nI][3+nP],aColsCab[nI][5+nP]) //Total Geral do Funcionario

			aColsCab[nI][4+nP] := Round(aColsCab[nI][3+nP]/aColsCab[nI][7+nP]*100,2) //Total Produtivas do Funcionario
			aColsCab[nI][6+nP] := Round(aColsCab[nI][5+nP]/aColsCab[nI][7+nP]*100,2) //Total Improdutivas do Funcionario

			If !lTurnoFlut
				If lDetalhado
					nPos := aScan(aTurnoST1,{|x| x[1]+x[3] == aColsCab[nI][11]+aColsCab[nI][1] })
				Else
					nPos := aScan(aTurnoST1,{|x| x[1] == aColsCab[nI][10] })
				EndIf
				aColsCab[nI][8+nP] := NGCONVERHORA(aTurnoST1[nPos][2],'S','D') //Converte para Decimal
			Else
				If lDetalhado
					nPOS := aScan(aFunxHras,{|x| x[3]+x[1] == aColsCab[nI][1]+aColsCab[nI][2] })
				Else
					nPOS := aScan(aFunxHras,{|x| x[1] == aColsCab[nI][1] })
				EndIf

				If nPOS == 0
					aColsCab[nI][8+nP] := 0
				Else
					aColsCab[nI][8+nP] := aFunxHras[nPOS][2]
				EndIf
			EndIf

				//FunÁ„o que avalia as exceÁıes de calend·rio
			aColsCab[nI][8+nP] := MNTCEXCAL(dTpAnaliAte,aColsCab[nI][8+nP],aColsCab[nI][nPosCalend])

			// Atribui os valores que ser„o apresentados no cabeÁalho da rotina
			nTotCabImp := SomaHoras( nTotCabImp, NgTraNToH( aColsCab[nI,5+nP] ) )
			nTotCabPro := SomaHoras( nTotCabPro, NgTraNToH( aColsCab[nI,3+nP] ) )

			aColsCab[nI][9+nP] := SubHoras( aColsCab[nI][8+nP],aColsCab[nI][7+nP] )

			If aColsCab[nI][8+nP] < 0
				aColsCab[nI][8+nP] := 0
			EndIf

			If aColsCab[nI][9+nP] < 0
				aColsCab[nI][9+nP] := 0
			EndIf

			aColsCab[nI,3+nP] := IIf( aColsCab[nI,3+nP] <= 0, NToH( 0 ), NgTraNToH( aColsCab[nI,3+nP] ) )
			aColsCab[nI,5+nP] := IIf( aColsCab[nI,5+nP] <= 0, NToH( 0 ), NgTraNToH( aColsCab[nI,5+nP] ) )
			aColsCab[nI,7+nP] := IIf( aColsCab[nI,7+nP] <= 0, NToH( 0 ), NgTraNToH( aColsCab[nI,7+nP] ) )
			aColsCab[nI,8+nP] := IIf( aColsCab[nI,8+nP] <= 0, NToH( 0 ), NgTraNToH( aColsCab[nI,8+nP] ) )
			aColsCab[nI,9+nP] := IIf( aColsCab[nI,9+nP] <= 0, NToH( 0 ), NgTraNToH( aColsCab[nI,9+nP] ) )

		Next nI
	Else
		nTotCabPro := HToN(aColsCab[1][3+nP])
		nTotCabImp := HToN(aColsCab[1][5+nP])
	EndIf

	For nI := 1 to Len(aColsInfer)
		If lDetalhado
			nPosPai := aScan(aColsCab,{|x| x[1]+x[2] == aColsInfer[nI][1]+aColsInfer[nI][2] })
		Else
			nPosPai := aScan(aColsCab,{|x| x[1] == aColsInfer[nI][1] })
		EndIf

		aColsInfer[nI][4+nP] := Round( aColsInfer[nI,3+nP] / SomaHoras( aColsCab[nPosPai,3+nP], aColsCab[nPosPai,5+nP] ) * 100, 2 ) //%
		aColsInfer[nI][3+nP] := IIF( aColsInfer[nI][3+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsInfer[nI][3+nP] ) )
	Next nI

	If !lDuploClick
		cCabecSup1 := STR0077 + IIf( nTotCabPro == 0, NToH( 0 ), NgTraNToH( nTotCabPro ) ) + STR0078 // Total Produtivas: XX:XX horas
		cCabecSup2 := STR0210 + IIf( nTotCabImp == 0, NToH( 0 ), NgTraNToH( nTotCabImp ) ) + STR0078 // Total Improdutivas: XX:XX horas
	Else
		cCabecSup1 := STR0087 + cEspDuplo //"Especialidade: "
		cCabecSup2 := STR0086 + cCCDuplo //"Centro de Custo: "
	EndIf

	If Len(aColsCab) > 0
		CriaRodape(cCabecSup1,cCabecSup2,oPnlCenRod,1)
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} QuerySTL
Query STL

@author Marcos Wagner Junior
@since	19/02/2009
/*/
//---------------------------------------------------------------------
Static Function QuerySTL(_nPar)

	Local dTL_DTINICI
	Local dTL_DTFIM
	Local nCorretiva   := 0
	Local nPreventiv   := 0
	Local nI           := 0
	Local nPeriodo     := 0
	Local nTLQUANTID   := 0
	Local nQtDecimal   := 0

	Private nHrExtras  := 0
	Private nRealizada := 0
	Private nPrevista  := 0
	Private nCustoMSta := 0
	Private cCodCCusto := ""
	Private cT1_CCUSTO := ""
	Private aPerAcols  := {}
	Private cTarefa    := ""
	Private cEtapa     := ""
	Private cPlano     := ""
	Private cHrInici   := ""
	Private cHrFim     := ""
	Private dDtInici   := CtoD( '  /  /    ' )
	Private dDtFim     := CtoD( '  /  /    ' )

	cAliasQry := GetNextAlias()

	cQuery := " SELECT ST1.T1_CCUSTO, STL.TL_QUANTID, CTT.CTT_DESC01, ST1.T1_CODFUNC, ST1.T1_TURNO, "
	cQuery += "        ST1.T1_NOME, ST1.T1_SALARIO, STL.TL_PLANO, STL.TL_ORDEM, STL.TL_SEQRELA, "
	cQuery += "        STL.TL_TAREFA, STL.TL_PLANO, STL.TL_DTINICI, STL.TL_HOINICI, STL.TL_DTFIM, STL.TL_HOFIM,
	cQuery += "        STL.TL_TIPOHOR, STL.TL_USACALE, TL_ETAPA" + IIf(lPcthrex, " ,STL.TL_PCTHREX ", " ,STL.TL_HREXTRA ")
	cQuery += " FROM " + RetSqlName("STL") + " STL, "
	cQuery +=            RetSqlName("ST1") + " ST1, "
	cQuery +=            RetSqlName("CTT") + " CTT, "
	cQuery +=            RetSqlName("STJ") + " STJ"
	If NGSX2MODO("STL") == NGSX2MODO("ST1")
		cQuery += " WHERE STL.TL_FILIAL = ST1.T1_FILIAL "
		cQuery += " AND ST1.T1_FILIAL = " + ValToSQL(xFilial("ST1"))
	Else
		cQuery += " WHERE STL.TL_FILIAL = " + ValToSQL(xFilial("STL"))
		cQuery += " AND ST1.T1_FILIAL = " + ValToSQL(xFilial("ST1"))
	EndIf
	
	cQuery += " AND STL.TL_TIPOREG = 'M' "
	cQuery += " AND ( STL.TL_DTINICI BETWEEN " + ValToSQL(dTpAnaliDe) + " AND " + ValToSQL(dTpAnaliAte)
	cQuery +=    " OR STL.TL_DTFIM BETWEEN "   + ValToSQL(dTpAnaliDe) + " AND " + ValToSQL(dTpAnaliAte) + " ) "

	If NGSX2MODO("STJ") == NGSX2MODO("STL")
		cQuery += " AND STJ.TJ_FILIAL = STL.TL_FILIAL "
	Else
		cQuery += " AND STJ.TJ_FILIAL = " + ValToSQL(xFilial("STJ"))
		cQuery += " AND STL.TL_FILIAL = " + ValToSQL(xFilial("STL"))
	EndIf

	cQuery += " AND STJ.TJ_ORDEM = STL.TL_ORDEM "
	cQuery += " AND STJ.TJ_PLANO = STL.TL_PLANO "
	cQuery += " AND STJ.TJ_SITUACA = 'L' "

	cQuery += " AND ST1.T1_FILIAL = " + ValToSQL(xFilial("ST1"))
	cQuery += " AND CTT.CTT_FILIAL = " + ValToSQL(xFilial("CTT"))

	cQuery += " AND ST1.T1_CCUSTO = CTT.CTT_CUSTO "
	If (cTpAnalise != 'U' .And. cVisualiz == "C") .Or. (cVisualiz == "F") //Na utilizacao por CC, ele filtrara o CC da Ordem
		If cTpAnalise <> 'D'
			If cVisualiz == "C"
				cQuery += " AND ST1.T1_CCUSTO >= " + ValToSQL(cVisualiDe)
				cQuery += " AND ST1.T1_CCUSTO <= " + ValToSQL(cVisualiAte)
			ElseIf cVisualiz == "F"
				cQuery += " AND ST1.T1_CODFUNC >= " + ValToSQL(cVisualiDe)
				cQuery += " AND ST1.T1_CODFUNC <= " + ValToSQL(cVisualiAte)
			EndIf
		EndIf
	EndIf

	If Upper(_cGetDB) $ 'ORACLE,DB2,POSTGRES,INFORMIX'
		cQuery += " AND SUBSTR(STL.TL_CODIGO,1,6) = ST1.T1_CODFUNC "
	Else
		cQuery += " AND SUBSTRING(STL.TL_CODIGO,1,6) = ST1.T1_CODFUNC "
	Endif

	If cTpAnalise == 'U' .Or. cTpAnalise == 'O'
		cQuery += " AND STL.TL_SEQRELA <> '0  ' "
	Endif

	If cTpAnalise == 'U' .And. cVisualiz == "C"
		cQuery += " AND STJ.TJ_CCUSTO = ST1.T1_CCUSTO "
	EndIf

	cQuery += " AND CTT.D_E_L_E_T_ <> '*' "
	cQuery += " AND ST1.D_E_L_E_T_ <> '*' "
	cQuery += " AND STL.D_E_L_E_T_ <> '*' "
		cQuery += " AND STJ.D_E_L_E_T_ <> '*' "
	If cVisualiz == 'C'
		cQuery += " ORDER BY ST1.T1_CCUSTO "
	Endif

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	dbGoTop()

	While !Eof()

		dTL_DTINICI := STOD((cAliasQry)->TL_DTINICI)
		dTL_DTFIM   := STOD((cAliasQry)->TL_DTFIM)

		aRetDtHr := PulaData(dTL_DTINICI,(cAliasQry)->TL_HOINICI,dTL_DTFIM,(cAliasQry)->TL_HOFIM,(cAliasQry)->T1_TURNO,(cAliasQry)->TL_USACALE,(cAliasQry)->TL_QUANTID,(cAliasQry)->TL_TIPOHOR )

		If Len(aRetDtHr) == 0
			dbSelectArea(cAliasQry)
			dbSkip()
			Loop
		Else
			dTL_DTINICI := aRetDtHr[1][1]
			dTL_DTFIM   := aRetDtHr[1][2]
			nTLQUANTID  := aRetDtHr[1][3]
			nQtDecimal  := aRetDtHr[1][4] //utilizado para c·lculo
		Endif

		dbSelectArea("ST2")
		dbSetOrder(1)
		If dbSeek(xFilial("ST2")+(cAliasQry)->T1_CODFUNC)
			cCodEspec := ST2->T2_ESPECIA
			cDesEspec := NGSEEK("ST0",cCodEspec,1,"T0_NOME")
		Else
			cCodEspec := Space(Len(ST2->T2_ESPECIA)) //Tratamento para quando o funcionario nao tiver especialidade
			cDesEspec := STR0165 //"N„o possui especialidade"
		Endif

			If cTpAnalise <> 'D' .And. cVisualiz == "E"
				If ST2->T2_ESPECIA < cVisualiDe .Or. ST2->T2_ESPECIA > cVisualiAte
				dbSelectArea(cAliasQry)
				dbSkip()
				Loop
			Endif
		Endif

		If (cAliasQry)->TL_PLANO == '000000'
			lCorretiva := .T.
			nCorretiva := nTLQUANTID
			nPreventiv := 0
		Else
			lCorretiva := .F.
			nPreventiv := nTLQUANTID
			nCorretiva := 0
		Endif

		nHrExtras := 0
		nRealizada := 0
		nPrevista  := 0

		If lPcthrex .And. !Empty((cAliasQry)->TL_PCTHREX)
			nHrExtras := nTLQUANTID
		ElseIf !lPcthrex .And. (cAliasQry)->TL_HREXTRA != '000.00' .And. !Empty((cAliasQry)->TL_HREXTRA)
			nHrExtras := nTLQUANTID
		Endif

		If (cAliasQry)->TL_SEQRELA == '0  '
			nPrevista  := nTLQUANTID
		Else
			nRealizada := nTLQUANTID
		Endif

		dbSelectArea("ST1")
		dbSetOrder(1)
		dbSeek(xFilial("ST1")+(cAliasQry)->T1_CODFUNC)
		If cTpCusto == 'S'
			nCustoMSta  :=  ST1->T1_SALARIO //Valor (Custo Medio ou Standard)
		Else
			dbSelectArea("SB2")
			dbSetOrder(1)
			If dbSeek(xFilial("SB2")+'MOD'+AllTrim(ST1->T1_CCUSTO))
				nCustoMSta := SB2->B2_CM1 //Valor (Custo Medio ou Standard)
			Else
				nCustoMSta := 0
			Endif
		Endif

		//Buscar CC da OS
		cCodCCusto := NGSEEK("STJ",(cAliasQry)->TL_ORDEM,1,"TJ_CCUSTO")
		If Empty(cCodCCusto)
			cDesCCusto := STR0157 //"OS n„o possui Centro de Custo"
		Else
			cDesCCusto := NGSEEK("CTT",cCodCCusto,1,"CTT_DESC01")
		Endif

		If cTpAnalise == 'U' .And. cVisualiz == "C"
			If cCodCCusto < cVisualiDe .Or. cCodCCusto > cVisualiAte
				dbSelectArea(cAliasQry)
				dbSkip()
				Loop
			Endif
		Endif

		nPeriodo := MNTC400PER(dTL_DTINICI,dTL_DTFIM)
		cT1_CCUSTO := (cAliasQry)->T1_CCUSTO

		For nI := 1 to nPeriodo
			If !lDuploClick
			//Primeira GetDados
				If _nPar == 1
					If !lDetalhado
						nPos := aSCAN(aColsCab,{|x| x[1] == cT1_CCUSTO })
						If nPos == 0
							aAdd(aColsCab,{cT1_CCUSTO,(cAliasQry)->CTT_DESC01,nTLQUANTID,0,0,0,0,0,0,0,0})
						Else
							aColsCab[nPos][3] := somahoras(aColsCab[nPos][3],nTLQUANTID)
						Endif
					Else //Detalhado
						nPos := aSCAN(aColsCab,{|x| x[1]+x[2] == aPerAcols[nI]+cT1_CCUSTO })
						If nPos == 0
							aAdd(aColsCab,{aPerAcols[nI],cT1_CCUSTO,(cAliasQry)->CTT_DESC01,nTLQUANTID,0,0,0,0,0,0,0,0})
						Else
							aColsCab[nPos][4] := somahoras(aColsCab[nPos][4],nTLQUANTID)
						Endif
					Endif
				ElseIf _nPar == 2
					If !lDetalhado
						nPos := aSCAN(aColsCab,{|x| x[1] == cCodEspec })
						If nPos == 0
							aAdd(aColsCab,{cCodEspec,cDesEspec,0,nTLQUANTID,0,0,0,0,0,0,0,0})
						Else
							aColsCab[nPos][4] := somahoras(aColsCab[nPos][4],nTLQUANTID)
						Endif
					Else
						nPos := aSCAN(aColsCab,{|x| x[1]+x[2] == aPerAcols[nI]+cCodEspec })
						If nPos == 0
							aAdd(aColsCab,{aPerAcols[nI],cCodEspec,cDesEspec,0,nTLQUANTID,0,0,0,0,0,0,0,0})
						Else
							aColsCab[nPos][5] := somahoras(aColsCab[nPos][5],nTLQUANTID)
						Endif
					Endif
				ElseIf _nPar == 3
					If !lDetalhado
						nPos := aSCAN(aColsCab,{|x| x[1] == cCodCCusto })
						If nPos == 0
							aAdd(aColsCab,{cCodCCusto,cDesCCusto,nPreventiv,0,0,nCorretiva,0,0,0})
						Else
							aColsCab[nPos][3] := somahoras(aColsCab[nPos][3],nPreventiv)
							aColsCab[nPos][6] := somahoras(aColsCab[nPos][6],nCorretiva)
						Endif
					Else
						nPos := aSCAN(aColsCab,{|x| x[1]+x[2] == aPerAcols[nI]+cCodCCusto })
						If nPos == 0
							aAdd(aColsCab,{aPerAcols[nI],cCodCCusto,cDesCCusto,nPreventiv,0,0,nCorretiva,0,0,0})
						Else
							aColsCab[nPos][4] := somahoras(aColsCab[nPos][4],nPreventiv)
							aColsCab[nPos][7] := somahoras(aColsCab[nPos][7],nCorretiva)
						Endif
					Endif
				ElseIf _nPar == 4 // UtilizaÁ„o por especialidade
					If !lDetalhado
						nPos := aSCAN(aColsCab,{|x| x[1]+x[4] == cCodEspec+cT1_CCUSTO })
						If nPos == 0
							aAdd(aColsCab,{cCodEspec,cDesEspec,0,cT1_CCUSTO,nPreventiv,0,0,nCorretiva,0,0,0})
						Else
							aColsCab[nPos][5] := somahoras(aColsCab[nPos][5],nPreventiv)
							aColsCab[nPos][8] := somahoras(aColsCab[nPos][8],nCorretiva)
						Endif
					Else
						nPos := aSCAN(aColsCab,{|x| x[1]+x[2]+x[5] == aPerAcols[nI]+cCodEspec+cT1_CCUSTO })
						If nPos == 0
							aAdd(aColsCab,{aPerAcols[nI],cCodEspec,cDesEspec,0,cT1_CCUSTO,nPreventiv,0,0,nCorretiva,0,0,0})
						Else
							aColsCab[nPos][6] := somahoras(aColsCab[nPos][6],nPreventiv)
							aColsCab[nPos][9] := somahoras(aColsCab[nPos][9],nCorretiva)
						Endif
					Endif
				ElseIf _nPar == 5 //Eficiencia x Centro de Custo
					If !lDetalhado
						nPos := aSCAN(aColsCab,{|x| x[1] == cT1_CCUSTO })
						If nPos == 0
							aAdd(aColsCab,{cT1_CCUSTO,(cAliasQry)->CTT_DESC01,nPrevista,nRealizada,0,0,nHrExtras})
						Else
							aColsCab[nPos][3] := somahoras(aColsCab[nPos][3],nPrevista)
							aColsCab[nPos][4] := somahoras(aColsCab[nPos][4],nRealizada)
							aColsCab[nPos][7] := somahoras(aColsCab[nPos][7],nHrExtras)
						Endif
					Else
						nPos := aSCAN(aColsCab,{|x| x[1]+x[2] == aPerAcols[nI]+cT1_CCUSTO })
						If nPos == 0
							aAdd(aColsCab,{aPerAcols[nI],cT1_CCUSTO,(cAliasQry)->CTT_DESC01,nPrevista,nRealizada,0,0,nHrExtras})
						Else
							aColsCab[nPos][4] := somahoras(aColsCab[nPos][4],nPrevista)
							aColsCab[nPos][5] := somahoras(aColsCab[nPos][5],nRealizada)
							aColsCab[nPos][8] := somahoras(aColsCab[nPos][8],nHrExtras)
						Endif
					Endif
				ElseIf _nPar == 6 //Eficiencia x Especialidade
					If !lDetalhado
						nPos := aSCAN(aColsCab,{|x| x[1] == cCodEspec })
						If nPos == 0
							aAdd(aColsCab,{cCodEspec,cDesEspec,nPrevista,nRealizada,0,0,nHrExtras})
						Else
							aColsCab[nPos][3] := somahoras(aColsCab[nPos][3],nPrevista)
							aColsCab[nPos][4] := somahoras(aColsCab[nPos][4],nRealizada)
							aColsCab[nPos][7] := somahoras(aColsCab[nPos][7],nHrExtras)
						Endif
					Else
						nPos := aSCAN(aColsCab,{|x| x[1]+x[2] == aPerAcols[nI]+cCodEspec })
						If nPos == 0
							aAdd(aColsCab,{aPerAcols[nI],cCodEspec,cDesEspec,nPrevista,nRealizada,0,0,nHrExtras})
						Else
							aColsCab[nPos][4] := somahoras(aColsCab[nPos][4],nPrevista)
							aColsCab[nPos][5] := somahoras(aColsCab[nPos][5],nRealizada)
							aColsCab[nPos][8] := somahoras(aColsCab[nPos][8],nHrExtras)
						Endif
					Endif
				ElseIf _nPar == 7 //Utilizacao x Funcionario
					nCustoPrev := IIf( nPreventiv == 0, 0, nQtDecimal * nCustoMSta )
					nCustoCorr := IIf( nCorretiva == 0, 0, nQtDecimal * nCustoMSta )
					nTotalHora := nPreventiv + nCorretiva
					If !lDetalhado
						nPos := aSCAN(aColsCab,{|x| x[1] == (cAliasQry)->T1_CODFUNC })
						If nPos == 0
							aAdd(aColsCab,{(cAliasQry)->T1_CODFUNC,(cAliasQry)->T1_NOME,nPreventiv,nCustoPrev,0,nCorretiva,nCustoCorr,0,nTotalHora})
						Else

							aColsCab[nPos][3] := somahoras(aColsCab[nPos][3],nPreventiv) // soma horas prev

							If nCustoPrev > 0
								aColsCab[nPos][4] += nCustoPrev // soma de valores prev
							EndIf

							aColsCab[nPos][6] := somahoras(aColsCab[nPos][6],nCorretiva) // soma horas corr
							
							If nCustoCorr > 0
								aColsCab[nPos][7] += nCustoCorr // soma de valores
							EndIf

							aColsCab[nPos][9] := somahoras(aColsCab[nPos][9],nTotalHora)

						Endif
					Else
						nPos := aSCAN(aColsCab,{|x| x[1]+x[2] == aPerAcols[nI]+(cAliasQry)->T1_CODFUNC })
						If nPos == 0
							aAdd(aColsCab,{aPerAcols[nI],(cAliasQry)->T1_CODFUNC,(cAliasQry)->T1_NOME,nPreventiv,nCustoPrev,0,nCorretiva,nCustoCorr,0,nTotalHora})
						Else
							aColsCab[nPos][4]  := somahoras(aColsCab[nPos][4],nPreventiv)

							If nCustoPrev > 0
								aColsCab[nPos][5]  := somahoras(aColsCab[nPos][5],nCustoPrev)
							EndIf

							aColsCab[nPos][7]  := somahoras(aColsCab[nPos][7],nCorretiva)

							If nCustoCorr > 0
								aColsCab[nPos][8]  := somahoras(aColsCab[nPos][8],nCustoCorr)
							EndIf

							aColsCab[nPos][10] := somahoras(aColsCab[nPos][10],nTotalHora)
						Endif
					Endif
				ElseIf _nPar == 9 //Ociosidade x Funcionario
					If !lDetalhado
						nPos := aSCAN(aColsCab,{|x| x[1] == (cAliasQry)->T1_CODFUNC })
						If nPos == 0
							aAdd(aColsCab,{(cAliasQry)->T1_CODFUNC,(cAliasQry)->T1_NOME,nTLQUANTID,0,0,0,0,0,0,(cAliasQry)->T1_TURNO})
						Else
							aColsCab[nPos][3] := somahoras(aColsCab[nPos][3],nTLQUANTID)
						Endif
					Else
						nPos := aSCAN(aColsCab,{|x| x[1]+x[2] == aPerAcols[nI]+(cAliasQry)->T1_CODFUNC })
						If nPos == 0
							aAdd(aColsCab,{aPerAcols[nI],(cAliasQry)->T1_CODFUNC,(cAliasQry)->T1_NOME,nTLQUANTID,0,0,0,0,0,0,(cAliasQry)->T1_TURNO})
						Else
							aColsCab[nPos][4] := somahoras(aColsCab[nPos][4],nTLQUANTID)
						Endif
					Endif
				Endif
			ElseIf _nPar == 7 .And. !Empty(cCCDuplo) //Pegar o CC da STJ
				cT1_CCUSTO := cCodCCusto
			Endif
			//Segunda GetDados
			cEtapa := (cAliasQry)->TL_ETAPA
			cPlano := (cAliasQry)->TL_PLANO
			cTarefa := (cAliasQry)->TL_TAREFA
			dDtInici := StoD( (cAliasQry)->TL_DTINICI )
			cHrInici := (cAliasQry)->TL_HOINICI
			dDtFim := StoD( (cAliasQry)->TL_DTFIM )
			cHrFim := (cAliasQry)->TL_HOFIM
			CarregaRod(_nPar,;
						cCodEspec,;
						(cAliasQry)->T1_CODFUNC,;
						(cAliasQry)->T1_NOME,;
						cT1_CCUSTO,;
						nTLQUANTID,;
						1,;
						cCodCCusto,;
						(cAliasQry)->TL_ORDEM,;
						IIf(lPcthrex,(cAliasQry)->TL_PCTHREX,(cAliasQry)->TL_HREXTRA),;
						'STL',;
						IIf(Len(aPerAcols)>0,aPerAcols[nI], Nil),;
						nQtDecimal)
		Next

		If _nPar == 8 //Eficiencia x Funcionario
			For nI := 1 to nPeriodo
				If !lDuploClick
					If !lDetalhado
						nPos := aSCAN(aColsCab,{|x| x[1] == (cAliasQry)->T1_CODFUNC })
						If nPos == 0
							aAdd(aColsCab,{(cAliasQry)->T1_CODFUNC,(cAliasQry)->T1_NOME,nPrevista,nRealizada,0,0,nHrExtras})
						Else
							aColsCab[nPos][3] := somahoras(aColsCab[nPos][3],nPrevista)
							aColsCab[nPos][4] := somahoras(aColsCab[nPos][4],nRealizada)
							aColsCab[nPos][7] := somahoras(aColsCab[nPos][7],nHrExtras)
						Endif
					Else
						nPos := aSCAN(aColsCab,{|x| x[1]+x[2] == aPerAcols[nI]+(cAliasQry)->T1_CODFUNC })
						If nPos == 0
							aAdd(aColsCab,{aPerAcols[nI],(cAliasQry)->T1_CODFUNC,(cAliasQry)->T1_NOME,nPrevista,nRealizada,0,0,nHrExtras})
						Else
							aColsCab[nPos][4] := somahoras(aColsCab[nPos][4],nPrevista)
							aColsCab[nPos][5] := somahoras(aColsCab[nPos][5],nRealizada)
							aColsCab[nPos][8] := somahoras(aColsCab[nPos][8],nHrExtras)
						Endif
					Endif
				Endif

					If !lDuploClick .Or. (lDuploClick .And. cT1_CCUSTO == cCCDuplo .And. cCodEspec == cEspDuplo)
					If !lDetalhado
						nPos := aSCAN(aColsInfer,{|x| x[1]+x[2]+x[3]+x[4] == (cAliasQry)->T1_CODFUNC+(cAliasQry)->TL_ORDEM+(cAliasQry)->TL_PLANO+(cAliasQry)->TL_TAREFA })
						If nPos == 0
							aAdd(aColsInfer,{(cAliasQry)->T1_CODFUNC,(cAliasQry)->TL_ORDEM,(cAliasQry)->TL_PLANO,(cAliasQry)->TL_TAREFA,nPrevista,nRealizada,,,nHrExtras})
						Else
							aColsInfer[nPos][5] := somahoras(aColsInfer[nPos][5],nPrevista)
							aColsInfer[nPos][6] := somahoras(aColsInfer[nPos][6],nRealizada)
							aColsInfer[nPos][9] := somahoras(aColsInfer[nPos][9],nHrExtras)
						Endif
					Else
						nPos := aSCAN(aColsInfer,{|x| x[1]+x[2]+x[3]+x[4]+x[5] == aPerAcols[nI]+(cAliasQry)->T1_CODFUNC+(cAliasQry)->TL_ORDEM+(cAliasQry)->TL_PLANO+(cAliasQry)->TL_TAREFA })
						If nPos == 0
							aAdd(aColsInfer,{aPerAcols[nI],(cAliasQry)->T1_CODFUNC,(cAliasQry)->TL_ORDEM,(cAliasQry)->TL_PLANO,(cAliasQry)->TL_TAREFA,nPrevista,nRealizada,,,nHrExtras})
						Else
							aColsInfer[nPos][6]  := somahoras(aColsInfer[nPos][6],nPrevista)
							aColsInfer[nPos][7]  := somahoras(aColsInfer[nPos][7],nRealizada)
							aColsInfer[nPos][10] := somahoras(aColsInfer[nPos][10],nHrExtras)
						Endif
					Endif
				Endif
			Next
		Endif

		nTotProd1 := somahoras(nTotProd1,nTLQUANTID)

		dbSelectArea(cAliasQry)
		dbSkip()
	End
	(cAliasQry)->(dbCloseArea())

	QuerySTT(_nPar)

	If _nPar == 1 .Or. _nPar == 2 .Or. _nPar == 9
		QueryTTL(_nPar)
	Endif

	If !lDuploClick .Or. (lDuploClick .And. cTpAnalise == 'O' .And. lTurnoFlut)
		QtdFunxEsp(_nPar)
	Endif

	Return

//---------------------------------------------------------------------
/*/{Protheus.doc} QueryTTL
Query TTL

@author Marcos Wagner Junior
@since	19/02/2009
/*/
//---------------------------------------------------------------------
Static Function QueryTTL(_nPar)

	Local nI
	Local nPeriodo   := 0
	Local nTTLQUANTI := 0

	Private nHrExtras := 0
	Private aPerAcols := {}
	Private cT1_CCUSTO := ""

	cAliasQry := GetNextAlias()
	cQuery := " SELECT ST1.T1_CCUSTO, TTL.TTL_QUANTI, CTT.CTT_DESC01, TTJ.TTJ_CLASSI, ST1.T1_CODFUNC, ST1.T1_TURNO, ST1.T1_NOME, TTJ.TTJ_USACAL, "
	cQuery += "        ST1.T1_SALARIO, TTL.TTL_PCTHRE, TTL.TTL_DTINI, TTL.TTL_HRINI, TTL.TTL_DTFIM, TTL.TTL_HRFIM, TTL.TTL_TIPOHO, TTJ.TTJ_DESCRI "
	cQuery += " FROM " + RetSqlName("TTJ") +" TTJ, " + RetSqlName("TTL") +" TTL, "  + RetSqlName("ST1") +" ST1, " + RetSqlName("CTT") +" CTT "

	If NGSX2MODO("TTL") == NGSX2MODO("ST1")
		cQuery += " WHERE TTL.TTL_FILIAL = ST1.T1_FILIAL "
	Else
		cQuery += " WHERE TTL.TTL_FILIAL = " + ValToSQL(xFilial("TTL"))
		cQuery += " AND ST1.T1_FILIAL = " + ValToSQL(xFilial("ST1"))
	EndIf

	If NGSX2MODO("TTL") == NGSX2MODO("TTJ")
		cQuery += " AND TTL.TTL_FILIAL = TTJ.TTJ_FILIAL "
	Else
		cQuery += " AND TTL.TTL_FILIAL = " + ValToSQL(xFilial("TTL"))
		cQuery += " AND TTJ.TTJ_FILIAL = " + ValToSQL(xFilial("TTJ"))
	EndIf
	
	cQuery += " AND ( TTL.TTL_DTINI BETWEEN " + ValToSQL(dTpAnaliDe) + " AND " + ValToSQL(dTpAnaliAte)
	cQuery +=    " OR TTL.TTL_DTFIM BETWEEN " + ValToSQL(dTpAnaliDe) + " AND " + ValToSQL(dTpAnaliAte) + " ) "
	cQuery += " AND TTJ.TTJ_TPHORA = TTL.TTL_TPHORA "

	cQuery += " AND ST1.T1_FILIAL = " + ValToSQL(xFilial("ST1"))
	cQuery += " AND CTT.CTT_FILIAL = " + ValToSQL(xFilial("CTT"))

	cQuery += " AND ST1.T1_CCUSTO = CTT.CTT_CUSTO "
	If cTpAnalise <> 'D'
		If cVisualiz == "C"
			cQuery += " AND ST1.T1_CCUSTO >= " + ValToSQL(cVisualiDe)
			cQuery += " AND ST1.T1_CCUSTO <= " + ValToSQL(cVisualiAte)
		ElseIf cVisualiz == "F"
			cQuery += " AND ST1.T1_CODFUNC >= " + ValToSQL(cVisualiDe)
			cQuery += " AND ST1.T1_CODFUNC <= " + ValToSQL(cVisualiAte)
		EndIf
	Endif

	cQuery += " AND TTL.TTL_CODFUN = ST1.T1_CODFUNC "
	cQuery += " AND CTT.D_E_L_E_T_ <> '*' "
	cQuery += " AND ST1.D_E_L_E_T_ <> '*' "
	cQuery += " AND TTJ.D_E_L_E_T_ <> '*' "
	cQuery += " AND TTL.D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY ST1.T1_CCUSTO "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	dbGoTop()

	While !Eof()

		nQtdePro := 0
		nQtdeImp := 0
		nTTLQUANTI := 0
		dTTL_DTINI := STOD((cAliasQry)->TTL_DTINI)
		dTTL_DTFIM := STOD((cAliasQry)->TTL_DTFIM)
		nT1_TURNO  := (cAliasQry)->T1_TURNO

		aRetDtHr := PulaData(dTTL_DTINI,(cAliasQry)->TTL_HRINI,dTTL_DTFIM,(cAliasQry)->TTL_HRFIM,nT1_TURNO,(cAliasQry)->TTJ_USACAL,(cAliasQry)->TTL_QUANTI,(cAliasQry)->TTL_TIPOHO )
		If Len(aRetDtHr) == 0
			dbSelectArea(cAliasQry)
			dbSkip()
			Loop
		Else
			dTTL_DTINI := aRetDtHr[1][1]
			dTTL_DTFIM := aRetDtHr[1][2]
			nTTLQUANTI := aRetDtHr[1][3]
		Endif

		dbSelectArea("ST2")
		dbSetOrder(1)
		If dbSeek(xFilial("ST2")+(cAliasQry)->T1_CODFUNC)
			cCodEspec := ST2->T2_ESPECIA
			cDesEspec := NGSEEK("ST0",cCodEspec,1,"T0_NOME")
		Else
			cCodEspec := Space(Len(ST2->T2_ESPECIA)) //Tratamento para quando o funcionario nao tiver especialidade
			cDesEspec := STR0165 //"N„o possui especialidade"
		Endif

			If cTpAnalise <> 'D' .And. cVisualiz == "E"
				If ST2->T2_ESPECIA < cVisualiDe .Or. ST2->T2_ESPECIA > cVisualiAte
				dbSelectArea(cAliasQry)
				dbSkip()
				Loop
			Endif
		Endif

		dbSelectArea("ST1")
		dbSetOrder(1)
		dbSeek(xFilial("ST1")+(cAliasQry)->T1_CODFUNC)
		If cTpCusto == 'S'
			nCustoMSta  :=  ST1->T1_SALARIO //Valor (Custo Medio ou Standard)
		Else
			nCustoMSta := NGSEEK("SB2",'MOD'+AllTrim(ST1->T1_CCUSTO),1,"B2_CM1") //Valor (Custo Medio ou Standard)
			If ValType(nCustoMSta) == "C"
				nCustoMSta := 0
			Endif
		Endif

		If !Empty((cAliasQry)->TTL_PCTHRE)
			nHrExtras := nTTLQUANTI
		Endif

		nPeriodo := MNTC400PER(STOD((cAliasQry)->TTL_DTINI),STOD((cAliasQry)->TTL_DTFIM))
		cT1_CCUSTO := (cAliasQry)->T1_CCUSTO

		For nI := 1 to nPeriodo
			//Primeira GetDados
			If (cAliasQry)->TTJ_CLASSI == 'P'
				nQtdePro := nTTLQUANTI
				//Segunda GetDados
				CarregaRod(_nPar,cCodEspec,(cAliasQry)->T1_CODFUNC,(cAliasQry)->T1_NOME,cT1_CCUSTO,nTTLQUANTI,1,;
								,,(cAliasQry)->TTL_PCTHRE,'TTL',If(Len(aPerAcols)>0,aPerAcols[nI],Nil))
			Else
				nQtdeImp := nTTLQUANTI
				//Segunda GetDados
				CarregaRod(_nPar,cCodEspec,(cAliasQry)->T1_CODFUNC,(cAliasQry)->T1_NOME,cT1_CCUSTO,nTTLQUANTI,2,;
								,,(cAliasQry)->TTL_PCTHRE,'TTL',If(Len(aPerAcols)>0,aPerAcols[nI],Nil))
			Endif

			If !lDuploClick
				If _nPar == 1
					If !lDetalhado
						nPos := aSCAN(aColsCab,{|x| x[1] == cT1_CCUSTO })
						If nPos == 0
							aAdd(aColsCab,{cT1_CCUSTO,(cAliasQry)->CTT_DESC01,nQtdePro,0,0,nQtdeImp,0,0,0,0,0})
						Else
							aColsCab[nPos][3] := somahoras(aColsCab[nPos][3],nQtdePro)
							aColsCab[nPos][6] := somahoras(aColsCab[nPos][6],nQtdeImp)
						Endif
					Else
						nPos := aSCAN(aColsCab,{|x| x[1]+x[2] == aPerAcols[nI]+cT1_CCUSTO })
						If nPos == 0
							aAdd(aColsCab,{aPerAcols[nI],cT1_CCUSTO,(cAliasQry)->CTT_DESC01,nQtdePro,0,0,nQtdeImp,0,0,0,0,0})
						Else
							aColsCab[nPos][4] := somahoras(aColsCab[nPos][4],nQtdePro)
							aColsCab[nPos][7] := somahoras(aColsCab[nPos][7],nQtdeImp)
						Endif
					Endif
				ElseIf _nPar == 2
					If !lDetalhado
						nPos := aSCAN(aColsCab,{|x| x[1] == cCodEspec })
						If nPos == 0
							aAdd(aColsCab,{cCodEspec,cDesEspec,0,nQtdePro,0,nQtdeImp,0,0,0,0,0,0})
						Else
							aColsCab[nPos][4] := somahoras(aColsCab[nPos][4],nQtdePro)
							aColsCab[nPos][7] := somahoras(aColsCab[nPos][7],nQtdeImp)
						Endif
					Else
						nPos := aSCAN(aColsCab,{|x| x[1]+x[2] == aPerAcols[nI]+cCodEspec })
						If nPos == 0
							aAdd(aColsCab,{aPerAcols[nI],cCodEspec,cDesEspec,0,nQtdePro,0,nQtdeImp,0,0,0,0,0,0})
						Else
							aColsCab[nPos][5] += nQtdePro
							aColsCab[nPos][8] += nQtdeImp
						Endif
					Endif
				ElseIf _nPar == 9 //Ociosidade x Funcionario
					If !lDetalhado
						nPos := aSCAN(aColsCab,{|x| x[1] == (cAliasQry)->T1_CODFUNC })
						If nPos == 0
							aAdd(aColsCab,{(cAliasQry)->T1_CODFUNC,(cAliasQry)->T1_NOME,nQtdePro,0,nQtdeImp,0,0,0,0,nT1_TURNO})
						Else
							aColsCab[nPos][3] := somahoras(aColsCab[nPos][3],nQtdePro)
							aColsCab[nPos][5] := somahoras(aColsCab[nPos][5],nQtdeImp)
						Endif
					Else
						nPos := aSCAN(aColsCab,{|x| x[1]+x[2] == aPerAcols[nI]+(cAliasQry)->T1_CODFUNC })
						If nPos == 0
							aAdd(aColsCab,{aPerAcols[nI],(cAliasQry)->T1_CODFUNC,(cAliasQry)->T1_NOME,nQtdePro,0,nQtdeImp,0,0,0,0,nT1_TURNO})
						Else
							aColsCab[nPos][4] := somahoras(aColsCab[nPos][4],nQtdePro)
							aColsCab[nPos][6] := somahoras(aColsCab[nPos][6],nQtdeImp)
						Endif
					Endif

					nTotProd1 := somahoras(nTotProd1,nQtdePro)
					nTotImp1  := somahoras(nTotImp1,nQtdeImp)
				Endif
			Endif
		Next

		dbSelectArea(cAliasQry)
		dbSkip()
	End
	(cAliasQry)->(dbCloseArea())

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} QtdFunxEsp
Calcula a quantidade de funcionarios na especialidade

@author Marcos Wagner Junior
@since	20/07/2009
/*/
//---------------------------------------------------------------------
Static Function QtdFunxEsp(_nPar)

Local cCodEspec		:= ""
Local cFuncioOld 	:= ""
Local cNGMNTRH		:= AllTrim(GetMv("MV_NGMNTRH"))
Local nI 			:= 0
Local nHoraTurno 	:= 0

Private dDataDe_
Private dDataAte_

aFunxEspe := {}
aFunxHras := {}

dbSelectArea("ST1")
dbSetOrder(1)
If dbSeek(xFilial("ST1"))

	If lDetalhado
		nMesAno := Len(aMesAno)
	Else
		nMesAno := 1
		dDataDe_  := dTpAnaliDe
		dDataAte_ := dTpAnaliAte
	Endif

	While !EoF() .And. ST1->T1_FILIAL == xFilial("ST1")

		If cNGMNTRH == "S"
			dbSelectArea("SRA")
			dbSetOrder(1)
				If dbSeek(xFilial("SRA")+ST1->T1_CODFUNC) .And. !Empty(SRA->RA_DEMISSA) //Nao pega funcionario demitido
				dbSelectArea("ST1")
				dbSkip()
				Loop
			Endif
		Endif

		If cFuncioOld != ST1->T1_CODFUNC //Pega apenas a primeira especialidade do funcionario que encontrar na ST2
			dbSelectArea("ST2")
			dbSetOrder(1)
			If dbSeek(xFilial("ST2")+ST1->T1_CODFUNC)
				cCodEspec := ST2->T2_ESPECIA
			Else
				cCodEspec := Space(Len(ST2->T2_ESPECIA))
			Endif

			For nI := 1 to nMesAno

				If Len(aMesAno) > 0
					dDataDe_  := CTOD("01/"+aMesAno[nI],"DDMMYY")
					dDataAte_ := LastDay(CTOD("01/"+aMesAno[nI],"DDMMYY"))
					If dDataAte_ > dTpAnaliAte
						dDataAte_ := dTpAnaliAte
					Endif
					If Month(dDataDe_) == Month(dTpAnaliDe)
						dDataDe_ := dTpAnaliDe
					Endif
					If Month(dDataAte_) == Month(dTpAnaliAte)
						dDataAte_ := dTpAnaliAte
					Endif
				Endif

				If !lDetalhado
						If _nPar == 1 .Or. _nPar == 3  //Por CC
						nPos := aSCAN(aFunxEspe,{|x| x[1]+x[2] == ST1->T1_CCUSTO+cCodEspec })
						If nPos == 0
							aAdd(aFunxEspe,{ST1->T1_CCUSTO,cCodEspec,1})
						Else
							aFunxEspe[nPos][3] += 1
						Endif
					ElseIf _nPar == 2 //Por Especialidade
						nPos := aSCAN(aFunxEspe,{|x| x[1] == cCodEspec })
						If nPos == 0
							aAdd(aFunxEspe,{cCodEspec,1})
						Else
							aFunxEspe[nPos][2] += 1
						Endif
					ElseIf _nPar == 4
						nPos := aSCAN(aFunxEspe,{|x| x[1]+x[2] == cCodEspec+ST1->T1_CCUSTO })
						If nPos == 0
							aAdd(aFunxEspe,{cCodEspec,ST1->T1_CCUSTO,1})
						Else
							aFunxEspe[nPos][3] += 1
						Endif
					Endif
					//Inicio -  Calcula horas disponiveis por Turno
					If !lTurnoFlut
						nPos := aSCAN(aTurnoST1,{|x| x[1] == ST1->T1_TURNO })
						If nPos == 0
							nHoraTurno := NGCALEHDIS(ST1->T1_TURNO,dDataDe_,dDataAte_,'N')
							nHoraTurno := MNTCEXCAL(dDataAte_,nHoraTurno,ST1->T1_TURNO,"N")
							aAdd(aTurnoST1,{ST1->T1_TURNO,nHoraTurno})
						Else
							nHoraTurno := aTurnoST1[nPos][2]
						Endif
					Else
						TurnoFlut()
					Endif
					//Fim -  Calcula horas disponiveis por Turno
					//Inicio -  Calcula horas totais por Especialidade
					nPos := aSCAN(aEspecHora,{|x| x[1]+x[2] == ST1->T1_CCUSTO+cCodEspec })
					If nPos == 0
						aAdd(aEspecHora,{ST1->T1_CCUSTO,cCodEspec,nHoraTurno,nHoraTurno})
					Else
						aEspecHora[nPos][3] := somahoras(aEspecHora[nPos][3],nHoraTurno)
					Endif
					//Fim -  Calcula horas totais por Especialidade
				Else
						If _nPar == 1 .Or. _nPar == 3  //Por CC
						nPos := aSCAN(aFunxEspe,{|x| x[1]+x[2]+x[4] == ST1->T1_CCUSTO+cCodEspec+aMesAno[nI] })
						If nPos == 0
							aAdd(aFunxEspe,{ST1->T1_CCUSTO,cCodEspec,1,aMesAno[nI]})
						Else
							aFunxEspe[nPos][3] += 1
						Endif
					ElseIf _nPar == 2 //Por Especialidade
						nPos := aSCAN(aFunxEspe,{|x| x[1]+x[3] == cCodEspec+aMesAno[nI] })
						If nPos == 0
							aAdd(aFunxEspe,{cCodEspec,1,aMesAno[nI]})
						Else
							aFunxEspe[nPos][2] += 1
						Endif
					ElseIf _nPar == 4
						nPos := aSCAN(aFunxEspe,{|x| x[1]+x[2]+x[4] == cCodEspec+ST1->T1_CCUSTO+aMesAno[nI] })
						If nPos == 0
							aAdd(aFunxEspe,{cCodEspec,ST1->T1_CCUSTO,1,aMesAno[nI]})
						Else
							aFunxEspe[nPos][3] += 1
						Endif
					Endif
					If !lTurnoFlut
						//Inicio -  Calcula horas disponiveis por Turno
						nPos := aSCAN(aTurnoST1,{|x| x[1]+x[3] == ST1->T1_TURNO+aMesAno[nI] })
						If nPos == 0
							If !lTurnoFlut
								nHoraTurno := NGCALEHDIS(ST1->T1_TURNO,dDataDe_,dDataAte_,'N')
								nHoraTurno := MNTCEXCAL(dDataAte_,nHoraTurno,ST1->T1_TURNO,"N")
							Endif
							aAdd(aTurnoST1,{ST1->T1_TURNO,nHoraTurno,aMesAno[nI]})
						Else
							nHoraTurno := aTurnoST1[nPos][2]
						Endif
						//Fim -  Calcula horas disponiveis por Turno
					Else
						TurnoFlut()
					Endif
					//Inicio -  Calcula horas totais por Especialidade
					nPos := aSCAN(aEspecHora,{|x| x[1]+x[2]+x[5] == ST1->T1_CCUSTO+cCodEspec+aMesAno[nI] })
					If nPos == 0
						aAdd(aEspecHora,{ST1->T1_CCUSTO,cCodEspec,nHoraTurno,nHoraTurno,aMesAno[nI]})
					Else
						aEspecHora[nPos][3] := somahoras(aEspecHora[nPos][3],nHoraTurno)
					Endif
					//Fim -  Calcula horas totais por Especialidade
				Endif
			Next
		Endif

		cFuncioOld := ST1->T1_CODFUNC
		dbSelectArea("ST1")
		dbSkip()
	End
Endif

If _nPar == 1
	For nI := 1 to Len(aColsInfer)
		nPos := aSCAN(aFunxEspe,{|x| x[1]+x[2] == aColsInfer[nI][1+nP]+aColsInfer[nI][2+nP] })
			If nPos > 0
		aColsInfer[nI][4+nP] := aFunxEspe[nPos][3] //Quantidade de funcionarios na especialidade
			EndIf
	Next
ElseIf _nPar == 2
	For nI := 1 to Len(aColsCab)
		nPos := aSCAN(aFunxEspe,{|x| x[1] == aColsCab[nI][1+nP] })
			If nPos > 0
		aColsCab[nI][3+nP] := aFunxEspe[nPos][2] //Quantidade de funcionarios na especialidade
			EndIf
	Next
Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} CalcuHora
Calcula o Custo Medio ou Standard

@author Marcos Wagner Junior
@since	20/07/2009
/*/
//---------------------------------------------------------------------
Static Function CalcuHora(_nPar,nI)

If _nPar == 1
	dbSelectArea("ST1")
	dbSetOrder(3)
	If dbSeek(xFilial("ST1")+aColsCab[nI][1+nP])
		If cTpCusto == 'S'
			aColsCab[nI][4+nP] += HTON(aColsCab[nI][3+nP]) * ST1->T1_SALARIO //Valor (Custo Medio ou Standard)
			aColsCab[nI][7+nP] += HTON(aColsCab[nI][6+nP]) * ST1->T1_SALARIO //Valor (Custo Medio ou Standard)
		Else
			cCusMedio := NGSEEK("SB2",'MOD'+AllTrim(aColsCab[nI][1+nP]),1,"B2_CM1")
			If ValType(cCusMedio) == "C"
				cCusMedio := 0
			Endif
			aColsCab[nI][4+nP] += HTON(aColsCab[nI][3+nP]) * cCusMedio //Valor (Custo Medio ou Standard)
			aColsCab[nI][7+nP] += HTON(aColsCab[nI][6+nP]) * cCusMedio //Valor (Custo Medio ou Standard)
		Endif
	Endif
	aColsCab[nI][4+nP]  := Round(aColsCab[nI][4+nP],2)
	aColsCab[nI][7+nP]  := Round(aColsCab[nI][7+nP],2)
ElseIf _nPar == 2
	dbSelectArea("ST2")
	dbSetOrder(1)
	If dbSeek(xFilial("ST2")+aColsInfer[nI][2+nP])

		dbSelectArea("ST1")
		dbSetOrder(1)
		If dbSeek(xFilial("ST1")+ST2->T2_CODFUNC)
			If lDetalhado
				nPosPai := aSCAN(aColsCab,{|x| x[1]+x[2] == aColsInfer[nI][1]+aColsInfer[nI][2] })
			Else
				nPosPai := aSCAN(aColsCab,{|x| x[1] == aColsInfer[nI][1] })
			Endif

			If cTpCusto == 'S'
				aColsCab[nPosPai][5+nP] += HTON(aColsInfer[nI][4+nP]) * ST1->T1_SALARIO //Valor (Custo Medio ou Standard)
				aColsCab[nPosPai][8+nP] += HTON(aColsInfer[nI][6+nP]) * ST1->T1_SALARIO //Valor (Custo Medio ou Standard)
			Else
				cCusMedio := NGSEEK("SB2",'MOD'+AllTrim(ST1->T1_CCUSTO),1,"B2_CM1")
				If ValType(cCusMedio) == "C"
					cCusMedio := 0
				Endif
				aColsCab[nPosPai][5+nP] += HTON(aColsInfer[nI][4+nP]) * cCusMedio //Valor (Custo Medio ou Standard)
				aColsCab[nPosPai][8+nP] += HTON(aColsInfer[nI][6+nP]) * cCusMedio //Valor (Custo Medio ou Standard)
			Endif

		Endif

		dbSelectArea("ST2")
		dbSkip()

	Endif
Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} UtilizxCC
Carrega arrays quando selecionado UtilizaÁ„o por Centro de Custo

@author Marcos Wagner Junior
@since  24/02/2009
@version MP11
@return
/*/
//---------------------------------------------------------------------
Static Function UtilizxCC()

	Local nI := 0
	Local nTotCabPre := 0
	Local nTotCabCor := 0

	QuerySTL(3)
	For nI := 1 to Len(aColsCab)

		aColsCab[nI][9+nP] := SomaHoras( aColsCab[nI][3+nP],aColsCab[nI][6+nP] ) //Total Geral da OS Corretiva ou Preventiva

		nTotCabPre := SomaHoras( nTotCabPre,aColsCab[nI][3+nP] )
		nTotCabCor := SomaHoras( nTotCabCor,aColsCab[nI][6+nP] )

		aColsCab[nI][5+nP] := Round(Hton(aColsCab[nI][3+nP])/Hton(aColsCab[nI][9+nP])*100,2) //Percentual Preventivas por Total de OS
		aColsCab[nI][8+nP] := Round(Hton(aColsCab[nI][6+nP])/Hton(aColsCab[nI][9+nP])*100,2) //Percentual Corretivas por Total de OS

		aColsCab[nI][3+nP] := IIF( aColsCab[nI][3+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsCab[nI][3+nP] ) )
		aColsCab[nI][6+nP] := IIF( aColsCab[nI][6+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsCab[nI][6+nP] ) )
		aColsCab[nI][9+nP] := IIF( aColsCab[nI][9+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsCab[nI][9+nP] ) )

	Next

	For nI := 1 to Len(aColsInfer)
		aColsInfer[nI][12+nP] := aColsInfer[nI][6+nP]+aColsInfer[nI][9+nP] //Total Geral da Especialidade

		aColsInfer[nI][8+nP] := Round(Hton(aColsInfer[nI][6+nP])/Hton(aColsInfer[nI][12+nP])*100,2) //Total Preventivas da Especialidade
		aColsInfer[nI][11+nP] := Round(Hton(aColsInfer[nI][9+nP])/Hton(aColsInfer[nI][12+nP])*100,2) //Total Corretivas da Especialidade

		If lDetalhado
			nPos := aSCAN(aFunxEspe,{|x| x[1]+x[2]+x[4] == aColsInfer[nI][6]+aColsInfer[nI][3]+aColsInfer[nI][1] })

			//Alimenta GetDados Superior (Valor) - CC da OS/Bem
			nPosPai := aSCAN(aColsCab,{|x| x[1]+x[2] == aColsInfer[nI][1]+aColsInfer[nI][2] })
		Else
			nPos := aSCAN(aFunxEspe,{|x| x[1]+x[2] == aColsInfer[nI][5]+aColsInfer[nI][2] })

			//Alimenta GetDados Superior (Valor) - CC da OS/Bem
			nPosPai := aSCAN(aColsCab,{|x| x[1] == aColsInfer[nI][1] })
		Endif
		aColsInfer[nI][4+nP] := aFunxEspe[nPos][3] //Quantidade de funcionarios na Especialidade/CC

		aColsCab[nPosPai][4+nP] += aColsInfer[nI][7+nP] // soma valores prev
		aColsCab[nPosPai][7+nP] += aColsInfer[nI][10+nP] // soma valores corr

		aColsInfer[nI][6+nP]	:= IIF( aColsInfer[nI][6+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsInfer[nI][6+nP] ) )
		aColsInfer[nI][9+nP]	:= IIF( aColsInfer[nI][9+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsInfer[nI][9+nP] ) )
		aColsInfer[nI][12+nP]	:= IIF( aColsInfer[nI][12+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsInfer[nI][12+nP] ) )

	Next

	cCabecSup1 := STR0080 + IIF( nTotCabPre == 0, NTOH( 0 ), NgTraNtoH( nTotCabPre ) ) //"Total Preventivas: "
	cCabecSup2 := STR0081 + IIF( nTotCabCor == 0, NTOH( 0 ), NgTraNtoH( nTotCabCor ) ) //"Total Corretivas: "

	If Len(aColsCab) > 0
		CriaRodape(cCabecSup1,cCabecSup2,oPnlCenRod,1)
	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} UtilizxEs
Carrega arrays quando selecionado UtilizaÁ„o por Especialidade.

@author Marcos Wagner Junior
@since  24/02/2009
@version MP11
@return
/*/
//---------------------------------------------------------------------
Static Function UtilizxEs()

	Local nI := 0
	Local nPos := 0
	Local nTotCabPre := 0
	Local nTotCabCor := 0

	QuerySTL(4)

	If !lDuploClick
		For nI := 1 to Len(aColsCab)

			aColsCab[nI][11+nP] := SomaHoras( aColsCab[nI][5+nP],aColsCab[nI][8+nP] ) //Total Geral da OS Corretiva/Preventiva

			nTotCabPre := SomaHoras( nTotCabPre,aColsCab[nI][5+nP] )
			nTotCabCor := SomaHoras( nTotCabCor,aColsCab[nI][8+nP] )

			aColsCab[nI][7+nP]  := Round(Hton(aColsCab[nI][5+nP])/Hton(aColsCab[nI][11+nP])*100,2) //Percentual Preventivas por Total Corretiva/Preventiva
			aColsCab[nI][10+nP] := Round(Hton(aColsCab[nI][8+nP])/Hton(aColsCab[nI][11+nP])*100,2) //Percentual Corretivas por Total Corretiva/Preventiva

			nPos := 0
			If lDetalhado
				nPos := aSCAN(aFunxEspe,{|x| x[1]+x[2]+x[4] == aColsCab[nI][2]+aColsCab[nI][5]+aColsCab[nI][1] })
			Else
				nPos := aSCAN(aFunxEspe,{|x| x[1]+x[2] == aColsCab[nI][1]+aColsCab[nI][4] })
			Endif

			aColsCab[nI][3+nP] := IIf(nPos==0,0,aFunxEspe[nPos][3]) //Quantidade de funcionarios na Especialidade/CC

			aColsCab[nI][5+nP]	:= IIF( aColsCab[nI][5+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsCab[nI][5+nP] ) )
			aColsCab[nI][8+nP]	:= IIF( aColsCab[nI][8+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsCab[nI][8+nP] ) )
			aColsCab[nI][11+nP]	:= IIF( aColsCab[nI][11+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsCab[nI][11+nP] ) )

		Next
	Endif

	For nI := 1 to Len(aColsInfer)
		aColsInfer[nI][11+nP] := SomaHoras( aColsInfer[nI][5+nP],aColsInfer[nI][8+nP] ) //Total Geral do Funcionario

		aColsInfer[nI][7+nP]  := Round(Hton(aColsInfer[nI][5+nP])/Hton(aColsInfer[nI][11+nP])*100,2) //Percentual Preventivas por Total Corretiva/Preventiva
		aColsInfer[nI][10+nP] := Round(Hton(aColsInfer[nI][8+nP])/Hton(aColsInfer[nI][11+nP])*100,2) //Percentual Corretivas por Total Corretiva/Preventiva

		If lDetalhado
			//Alimenta GetDados Superior
			nPosPai := aSCAN(aColsCab,{|x| x[1]+x[2]+x[5] == aColsInfer[nI][1]+aColsInfer[nI][2]+aColsInfer[nI][3] })
		Else
			//Alimenta GetDados Superior
			nPosPai := aSCAN(aColsCab,{|x| x[1]+x[4] == aColsInfer[nI][1]+aColsInfer[nI][2] })
		Endif

		If !lDuploClick .And. nPosPai > 0
			aColsCab[nPosPai][6+nP] += aColsInfer[nI][6+nP] // soma valores prev
			aColsCab[nPosPai][9+nP] += aColsInfer[nI][9+nP] // soma valores corr
		Endif

		aColsInfer[nI][5+nP]	:= IIF( aColsInfer[nI][5+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsInfer[nI][5+nP] ) )
		aColsInfer[nI][8+nP]	:= IIF( aColsInfer[nI][8+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsInfer[nI][8+nP] ) )
		aColsInfer[nI][11+nP]	:= IIF( aColsInfer[nI][11+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsInfer[nI][11+nP] ) )
	Next

	If !lDuploClick
		cCabecSup1 := STR0080 + IIF( nTotCabPre == 0, NTOH( 0 ), NgTraNtoH( nTotCabPre ) ) //"Total Preventivas: "
		cCabecSup2 := STR0081 + IIF( nTotCabCor == 0, NTOH( 0 ), NgTraNtoH( nTotCabCor ) ) //"Total Corretivas: "
	Else
		cCabecSup1 := STR0088 + cCCDuplo //"Centro Custo de AplicaÁ„o: "
		cCabecSup2 := ""
	Endif

	If Len(aColsCab) > 0
		CriaRodape(cCabecSup1,cCabecSup2,oPnlCenRod,1)
	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} UtilizxFu
Carrega arrays quando selecionado Utilizacao por Funcion·rio.

@author Marcos Wagner Junior
@since  24/02/2009
@version MP11
@return
/*/
//---------------------------------------------------------------------
Static Function UtilizxFu()

	Local nI := 0

	QuerySTL(7)

	If !lDuploClick
		For nI := 1 to Len(aColsCab)
			aColsCab[nI][5+nP] := Round(Hton(aColsCab[nI][3+nP])/Hton(aColsCab[nI][9+nP])*100,2) //Percentual Preventivas por Total Corretiva/Preventiva
			aColsCab[nI][8+nP] := Round(Hton(aColsCab[nI][6+nP])/Hton(aColsCab[nI][9+nP])*100,2) //Percentual Corretivas por Total Corretiva/Preventiva

			aColsCab[nI][3+nP] := IIF( aColsCab[nI][3+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsCab[nI][3+nP] ) )
			aColsCab[nI][6+nP] := IIF( aColsCab[nI][6+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsCab[nI][6+nP] ) )
			aColsCab[nI][9+nP] := IIF( aColsCab[nI][9+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsCab[nI][9+nP] ) )
		Next
	Endif

	For nI := 1 to Len(aColsInfer)
		If lDetalhado
			//Busca na GetDados Superior o Total de Horas
			nPosPai := aSCAN(aColsCab,{|x| x[1]+x[2] == aColsInfer[nI][1]+aColsInfer[nI][2] })
		Else
			//Busca na GetDados Superior o Total de Horas
			nPosPai := aSCAN(aColsCab,{|x| x[1] == aColsInfer[nI][1] })
		Endif

		// Calculo do percentual
		aColsInfer[nI][12+nP] := Round(HTON(aColsInfer[nI][10+nP])/HTON(aColsCab[nPosPai][9+nP])*100,2)

		// Ajuste coluna total horas
		aColsInfer[nI][10+nP] := IIF( aColsInfer[nI][10+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsInfer[nI][10+nP] ) )

	Next

	If lDuploClick
		cCabecSup1 := STR0087 + cEspDuplo //"Especialidade: "
		cCabecSup2 := STR0088 + cCCDuplo //"Centro Custo de AplicaÁ„o: "
		If Len(aColsCab) > 0
			CriaRodape(cCabecSup1,cCabecSup2,oPnlCenRod,1)
		Endif
	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} EficiencCC
Carrega arrays quando selecionado Eficiencia por CC

@author Marcos Wagner Junior
@since  24/02/2009
@version MP11
@return
/*/
//---------------------------------------------------------------------
Static Function EficiencCC()

	Local nI := 0
	Local nTotCabPre := 0
	Local nTotCabRea := 0

	QuerySTL(5)
	QuerySTLEs(5)

	For nI := 1 to Len(aColsCab)

		aColsCab[nI][5+nP] := SubHoras( aColsCab[nI][3+nP],aColsCab[nI][4+nP] )

		// ( Hrs. Realizadas * 100 ) / Hrs. Previstas
		aColsCab[nI][6+nP] := Round( ( NGCONVERHORA( aColsCab[nI,4+nP], 'S', 'D', , 5 ) * 100 ) /;
			NGCONVERHORA( aColsCab[nI,3+nP], 'S', 'D', , 5 ), 2 )

		nTotCabPre := SomaHoras( nTotCabPre,aColsCab[nI][3+nP] )
		nTotCabRea := SomaHoras( nTotCabRea,aColsCab[nI][4+nP] )

		aColsCab[nI][3+nP] := IIF( aColsCab[nI][3+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsCab[nI][3+nP] ) )
		aColsCab[nI][4+nP] := IIF( aColsCab[nI][4+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsCab[nI][4+nP] ) )
		aColsCab[nI][5+nP] := IIF( aColsCab[nI][5+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsCab[nI][5+nP] ) )
		aColsCab[nI][7+nP] := IIF( aColsCab[nI][7+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsCab[nI][7+nP] ) )

	Next

	For nI := 1 to Len(aColsInfer)

		aColsInfer[nI][6+nP] := SubHoras( aColsInfer[nI][4+nP],aColsInfer[nI][5+nP] )

		// ( Hrs. Realizadas * 100 ) / Hrs. Previstas
		aColsInfer[nI][7+nP] := Round( ( NGCONVERHORA( aColsInfer[nI,5+nP], 'S', 'D', , 5 ) * 100 ) /;
			NGCONVERHORA(aColsInfer[nI,4+nP], 'S', 'D', , 5 ), 2 )

		aColsInfer[nI][4+nP] := IIF( aColsInfer[nI][4+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsInfer[nI][4+nP] ) )
		aColsInfer[nI][5+nP] := IIF( aColsInfer[nI][5+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsInfer[nI][5+nP] ) )
		aColsInfer[nI][6+nP] := IIF( aColsInfer[nI][6+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsInfer[nI][6+nP] ) )
		aColsInfer[nI][8+nP] := IIF( aColsInfer[nI][8+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsInfer[nI][8+nP] ) )

	Next

	cCabecSup1 := STR0082 + IIF( nTotCabPre == 0, NTOH( 0 ), NgTraNtoH( nTotCabPre ) ) //"Total Previstas: "
	cCabecSup2 := STR0083 + IIF( nTotCabRea == 0, NTOH( 0 ), NgTraNtoH( nTotCabRea ) ) //"Total Realizadas: "

	If Len(aColsCab) > 0
		CriaRodape(cCabecSup1,cCabecSup2,oPnlCenRod,1)
	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} EficiencEs
Carrega arrays quando selecionado Eficiencia por Especialide.

@author Marcos Wagner Junior
@since  24/02/2009
@version MP11
@return
/*/
//---------------------------------------------------------------------
Static Function EficiencEs()

	Local nI := 0
	Local nTotCabPre := 0
	Local nTotCabRea := 0

	QuerySTL(6)
	QuerySTLEs(6)

	If !lDuploClick

		For nI := 1 to Len(aColsCab)

			aColsCab[nI][5+nP] := SubHoras( aColsCab[nI][3+nP],aColsCab[nI][4+nP] )

			// ( Hrs. Realizadas * 100 ) / Hrs. Previstas
			aColsCab[nI][6+nP] := Round( ( NGCONVERHORA( aColsCab[nI,4+nP], 'S', 'D', , 5 ) * 100 ) /;
				NGCONVERHORA( aColsCab[nI,3+nP], 'S', 'D', , 5 ), 2 )

			nTotCabPre := SomaHoras( nTotCabPre,aColsCab[nI][3+nP] )
			nTotCabRea := SomaHoras( nTotCabRea,aColsCab[nI][4+nP] )

			aColsCab[nI][3+nP] := IIF( aColsCab[nI][3+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsCab[nI][3+nP] ) )
			aColsCab[nI][4+nP] := IIF( aColsCab[nI][4+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsCab[nI][4+nP] ) )
			aColsCab[nI][5+nP] := IIF( aColsCab[nI][5+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsCab[nI][5+nP] ) )
			aColsCab[nI][7+nP] := IIF( aColsCab[nI][7+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsCab[nI][7+nP] ) )

		Next

	EndIf

	For nI := 1 to Len(aColsInfer)

		aColsInfer[nI][6+nP] := SubHoras( aColsInfer[nI][4+nP],aColsInfer[nI][5+nP] )

		// ( Hrs. Realizadas * 100 ) / Hrs. Previstas
		aColsInfer[nI][7+nP] := Round( ( NGCONVERHORA( aColsInfer[nI,5+nP], 'S', 'D', , 5 ) * 100 ) /;
			NGCONVERHORA(aColsInfer[nI,4+nP], 'S', 'D', , 5 ), 2 )

		aColsInfer[nI][4+nP] := IIF( aColsInfer[nI][4+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsInfer[nI][4+nP] ) )
		aColsInfer[nI][5+nP] := IIF( aColsInfer[nI][5+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsInfer[nI][5+nP] ) )
		aColsInfer[nI][6+nP] := IIF( aColsInfer[nI][6+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsInfer[nI][6+nP] ) )
		aColsInfer[nI][8+nP] := IIF( aColsInfer[nI][8+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsInfer[nI][8+nP] ) )

	Next

	If !lDuploClick
		cCabecSup1 := STR0082 + IIF( nTotCabPre == 0, NTOH( 0 ), NgTraNtoH( nTotCabPre ) ) //"Total Previstas: "
		cCabecSup2 := STR0083 + IIF( nTotCabRea == 0, NTOH( 0 ), NgTraNtoH( nTotCabRea ) ) //"Total Realizadas: "
	Else
		cCabecSup1 := STR0086+cCCDuplo //"Centro de Custo: "
		cCabecSup2 := ""
	Endif

	If Len(aColsCab) > 0
		CriaRodape(cCabecSup1,cCabecSup2,oPnlCenRod,1)
	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} EficiencFu
Carrega arrays quando selecionado Eficiencia por Funcionario.

@author Marcos Wagner Junior
@since  24/02/2009
@version MP11
@return
/*/
//---------------------------------------------------------------------
Static Function EficiencFu()

	Local nI := 0
	Local nTotCabPre := 0
	Local nTotCabRea := 0

	QuerySTL(8)

	If !lDuploClick
		For nI := 1 to Len(aColsCab)
			aColsCab[nI][5+nP] := SubHoras( aColsCab[nI][3+nP],aColsCab[nI][4+nP] )

			// ( Hrs. Realizadas * 100 ) / Hrs. Previstas
			aColsCab[nI][6+nP] := Round( ( NGCONVERHORA( aColsCab[nI,4+nP], 'S', 'D', , 5 ) * 100 ) /;
				NGCONVERHORA( aColsCab[nI,3+nP], 'S', 'D', , 5 ), 2 )

			nTotCabPre := SomaHoras( nTotCabPre,aColsCab[nI][3+nP] )
			nTotCabRea := SomaHoras( nTotCabRea,aColsCab[nI][4+nP] )

			aColsCab[nI][3+nP] := IIF( aColsCab[nI][3+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsCab[nI][3+nP] ) )
			aColsCab[nI][4+nP] := IIF( aColsCab[nI][4+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsCab[nI][4+nP] ) )
			aColsCab[nI][5+nP] := IIF( aColsCab[nI][5+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsCab[nI][5+nP] ) )
			aColsCab[nI][7+nP] := IIF( aColsCab[nI][7+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsCab[nI][7+nP] ) )
		Next
	Endif

	For nI := 1 to Len(aColsInfer)

		aColsInfer[nI][7+nP] := SubHoras( aColsInfer[nI][5+nP],aColsInfer[nI][6+nP] )

		// ( Hrs. Realizadas * 100 ) / Hrs. Previstas
		aColsInfer[nI][8+nP] := Round( ( NGCONVERHORA( aColsInfer[nI,6+nP], 'S', 'D', , 5 ) * 100 ) /;
			NGCONVERHORA(aColsInfer[nI,5+nP], 'S', 'D', , 5 ), 2 )

		aColsInfer[nI][5+nP] := IIF( aColsInfer[nI][5+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsInfer[nI][5+nP] ) )
		aColsInfer[nI][6+nP] := IIF( aColsInfer[nI][6+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsInfer[nI][6+nP] ) )
		aColsInfer[nI][7+nP] := IIF( aColsInfer[nI][7+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsInfer[nI][7+nP] ) )
		aColsInfer[nI][9+nP] := IIF( aColsInfer[nI][9+nP] == 0, NTOH( 0 ), NgTraNtoH( aColsInfer[nI][9+nP] ) )
	Next

	If !lDuploClick
		cCabecSup1 := STR0082 + IIF( nTotCabPre == 0, NTOH( 0 ), NgTraNtoH( nTotCabPre ) ) //"Total Previstas: "
		cCabecSup2 := STR0083 + IIF( nTotCabRea == 0, NTOH( 0 ), NgTraNtoH( nTotCabRea ) ) //"Total Realizadas: "
	Else
		cCabecSup1 := STR0087 + cEspDuplo //"Especialidade: "
		cCabecSup2 := STR0086 + cCCDuplo //"Centro de Custo: "
	Endif

	If Len(aColsCab) > 0
		CriaRodape(cCabecSup1,cCabecSup2,oPnlCenRod,1)
	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} DistribxPr
Carrega arrays quando selecionado Distribuicao por Priorid

@author Marcos Wagner Junior
@since	20/07/2009
/*/
//---------------------------------------------------------------------
Static Function DistribxPr()

QueryTT1(2)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} DistribxOS
Carrega arrays quando selecionado Distribuicao por O.S.

@author Marcos Wagner Junior
@since	20/07/2009
/*/
//---------------------------------------------------------------------
Static Function DistribxOS()

QueryTT1(3)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} QueryTT1
Query TT1/TT2

@author Marcos Wagner Junior
@since	19/02/2009
/*/
//---------------------------------------------------------------------
Static Function QueryTT1(_nPar)
	Local nI := 0, nX := 0
	Local aInsumos := {}, cTipoHora := "", cTipoInsu := "", cDescInsu := ""
	Local nTLQUANTID := 0
	Private aPerAcols := {}
	Private lOK := .T.

	cAliasQry := GetNextAlias()
	cQuery := " SELECT STJ.TJ_ORDEM, STJ.TJ_PLANO, STJ.TJ_PRIORID, STJ.TJ_CODBEM, STJ.TJ_DTMPINI, STJ.TJ_HOMPINI, STJ.TJ_TIPOOS "
	If lRelease12
		cQuery += ", STJ.TJ_STFOLUP "
	Endif
	cQuery += " FROM " + RetSqlName("STJ") + " STJ "
	cQuery += " WHERE STJ.D_E_L_E_T_ <> '*' "
	cQuery += " AND STJ.TJ_SITUACA = 'L' "
	If cVisualiz == 'P'
		cQuery += " AND STJ.TJ_PRIORID >= '"+cVisualiDe+"'"
		cQuery += " AND STJ.TJ_PRIORID <= '"+cVisualiAte+"'"
	ElseIf cVisualiz == 'O'
		cQuery += " AND STJ.TJ_ORDEM >= '"+cVisualiDe+"'"
		cQuery += " AND STJ.TJ_ORDEM <= '"+cVisualiAte+"'"
	Endif
	
	cQuery += " AND ( STJ.TJ_DTMPINI BETWEEN " + ValToSQL(dTpAnaliDe) + " AND " + ValToSQL(dTpAnaliAte)
	cQuery +=    " OR STJ.TJ_DTMPFIM BETWEEN " + ValToSQL(dTpAnaliDe) + " AND " + ValToSQL(dTpAnaliAte) + " ) "

	If _nPar == 2
		cQuery += " ORDER BY STJ.TJ_PRIORID  "
	ElseIf _nPar == 3
		cQuery += " ORDER BY STJ.TJ_ORDEM  "
	Endif

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	dbGoTop()

	While !Eof()
		aInsumos := {}
		If (cAliasQry)->TJ_TIPOOS == 'B'
			nNomeBem := NGSEEK("ST9",(cAliasQry)->TJ_CODBEM,1,"ST9->T9_NOME")
		Else
			nNomeBem := NGSEEK("TAF","X2"+Substr((cAliasQry)->TJ_CODBEM,1,3),7,"SUBSTR(TAF_NOMNIV,1,40)")
		Endif

		nDistribui := 0
		nImpedidas := 1
		nHorasRea  := 0
		nHorasPre  := 0

		cAliasSTL := GetNextAlias()
		cQuerySTL := " SELECT STL.TL_QUANTID, STL.TL_SEQRELA, STL.TL_CODIGO, STL.TL_TIPOREG, STL.TL_TIPOHOR, "
		cQuerySTL += "        STL.TL_DTINICI, STL.TL_HOINICI, STL.TL_DTFIM,  STL.TL_HOFIM,   STL.TL_USACALE "
		cQuerySTL += " FROM " + RetSqlName("STL") +" STL "
		cQuerySTL += " WHERE STL.TL_ORDEM = " + ValToSQL((cAliasQry)->TJ_ORDEM)
		cQuerySTL +=   " AND STL.TL_PLANO = " + ValToSQL((cAliasQry)->TJ_PLANO)
		cQuerySTL +=   " AND ( STL.TL_DTINICI BETWEEN " + ValToSQL(dTpAnaliDe) + " AND " + ValToSQL(dTpAnaliAte)
		cQuerySTL +=      " OR STL.TL_DTFIM BETWEEN "   + ValToSQL(dTpAnaliDe) + " AND " + ValToSQL(dTpAnaliAte) + " ) "
		cQuerySTL +=   " AND (STL.TL_TIPOREG = 'M' OR STL.TL_TIPOREG = 'E')"
		cQuerySTL +=   " AND STL.D_E_L_E_T_ <> '*' "
		cQuerySTL := ChangeQuery(cQuerySTL)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuerySTL),cAliasSTL, .F., .T.)
		dbGoTop()
		While !Eof()

			nTLQUANTID := 0
			nT1_TURNO  := ""
			dTL_DTINICI := STOD((cAliasSTL)->TL_DTINICI)
			dTL_DTFIM   := STOD((cAliasSTL)->TL_DTFIM)

			If (cAliasSTL)->TL_USACALE == 'S' .And. (cAliasSTL)->TL_TIPOREG == 'M'
				dbSelectArea("ST1")
				dbSetOrder(01)
				If dbSeek(xFilial("ST1")+SubStr((cAliasSTL)->TL_CODIGO,1,6))
					nT1_TURNO := ST1->T1_TURNO
				Endif
			Endif

			aRetDtHr := PulaData(dTL_DTINICI,(cAliasSTL)->TL_HOINICI,dTL_DTFIM,(cAliasSTL)->TL_HOFIM,nT1_TURNO,(cAliasSTL)->TL_USACALE,(cAliasSTL)->TL_QUANTID,(cAliasSTL)->TL_TIPOHOR )
			If Len(aRetDtHr) == 0
				dbSelectArea(cAliasSTL)
				dbSkip()
				Loop
			Else
				dTL_DTINICI := aRetDtHr[1][1]
				dTL_DTFIM   := aRetDtHr[1][2]
				nTLQUANTID  := aRetDtHr[1][3]
			Endif

			cTipoHora := ""
			If (cAliasSTL)->TL_SEQRELA <> '0  '
				nDistribui	:= 1
				nImpedidas	:= 0
				nHorasRea	:= SomaHoras( nHorasRea,nTLQUANTID )
				cTipoHora	:= STR0166 //"Realizado"
			Else
				nHorasPre	:= SomaHoras( nHorasPre,nTLQUANTID )
				cTipoHora	:= STR0167 //"Previsto"
			Endif

			If (cAliasSTL)->TL_TIPOREG == 'E'
				dbSelectArea('ST0')
				dbSetOrder(01)
				If dbSeek(xFilial('ST0')+SubStr((cAliasSTL)->TL_CODIGO,1,3))
					cDescInsu := ST0->T0_NOME
				Endif
			Else
				dbSelectArea("ST1")
				dbSetOrder(01)
				If dbSeek(xFilial("ST1")+SubStr((cAliasSTL)->TL_CODIGO,1,6))
					cDescInsu := ST1->T1_NOME
				Endif
			Endif
			cTipoInsu := IIF((cAliasSTL)->TL_TIPOREG == 'E',STR0010,STR0168) //"Especialidade"###"Mao de Obra"

			nPOS := aSCAN(aInsumos,{|x| x[1]+x[2]+x[3]+x[4] == (cAliasQry)->TJ_ORDEM+cTipoHora+cTipoInsu+(cAliasSTL)->TL_CODIGO })
			If nPOS == 0
				aAdd(aInsumos,{(cAliasQry)->TJ_ORDEM,cTipoHora,cTipoInsu,(cAliasSTL)->TL_CODIGO,cDescInsu,nTLQUANTID})
			Else
				aInsumos[nPOS][6] := SomaHoras( aInsumos[nPOS][6],nTLQUANTID )
			Endif

			dbSelectArea(cAliasSTL)
			dbSkip()
		End
		(cAliasSTL)->(dbCloseArea())

		If nImpedidas != 0
			lOK := .F.
		Else
			lOK := .T.
		Endif

		If lRelease12
			cTJ_STFOLUP	:= (cAliasQry)->TJ_STFOLUP
		Else
			cTJ_STFOLUP	:= ""
		Endif

		nPeriodo := MNTC400PER(STOD((cAliasQry)->TJ_DTMPINI),STOD((cAliasQry)->TJ_DTMPINI))

		For nX := 1 to nPeriodo
			If _nPar == 2
				If !lDetalhado
					If !lDuploClick
						nPos := aSCAN(aColsCab,{|x| x[1] == (cAliasQry)->TJ_PRIORID })
						If nPos == 0
							aAdd(aColsCab,{(cAliasQry)->TJ_PRIORID,nImpedidas,nDistribui,1})
						Else
							aColsCab[nPos][2] += nImpedidas
							aColsCab[nPos][3] += nDistribui
							aColsCab[nPos][4] += 1
						Endif
					Endif

					If !lDuploClick .Or. (lDuploClick /*.And. nNomePlan == cPlanDuplo*/ .And. (cAliasQry)->TJ_PRIORID == cPrioDuplo)
						nPos := aSCAN(aColsInfer,{|x| x[2]+x[3] == (cAliasQry)->TJ_PRIORID+(cAliasQry)->TJ_ORDEM })
						If nPos == 0
							aAdd(aColsInfer,{lOK,(cAliasQry)->TJ_PRIORID,(cAliasQry)->TJ_ORDEM,cTJ_STFOLUP,(cAliasQry)->TJ_CODBEM,nNomeBem,;
													STOD((cAliasQry)->TJ_DTMPINI),IIF( nHorasPre == 0, NTOH( 0 ), NgTraNtoH(nHorasPre) ),IIF( nHorasRea == 0, NTOH( 0 ), NgTraNtoH(nHorasRea) ),Round(nHorasRea/nHorasPre*100,2)})
						Endif
					Endif
				Else //Detalhado
					If !lDuploClick
						nPos := aSCAN(aColsCab,{|x| x[1]+x[2] == aPerAcols[nX]+(cAliasQry)->TJ_PRIORID })
						If nPos == 0
							aAdd(aColsCab,{aPerAcols[nX],(cAliasQry)->TJ_PRIORID,nImpedidas,nDistribui,1})
						Else
							aColsCab[nPos][3] += nImpedidas
							aColsCab[nPos][4] += nDistribui
							aColsCab[nPos][5] += 1
						Endif
					Endif

					If !lDuploClick .Or. (lDuploClick /*.And. nNomePlan == cPlanDuplo*/ .And. (cAliasQry)->TJ_PRIORID == cPrioDuplo .And. aPerAcols[nX] == cPerDuplo)
							nPos := aSCAN(aColsInfer,{|x| x[2]+x[3]+x[4] == aPerAcols[nX]+(cAliasQry)->TJ_PRIORID+(cAliasQry)->TJ_ORDEM })
							If nPos == 0
								aAdd(aColsInfer,{lOK,aPerAcols[nX],(cAliasQry)->TJ_PRIORID,(cAliasQry)->TJ_ORDEM,cTJ_STFOLUP,(cAliasQry)->TJ_CODBEM,nNomeBem,;
														STOD((cAliasQry)->TJ_DTMPINI),IIF( nHorasPre == 0, NTOH( 0 ), NgTraNtoH(nHorasPre) ),IIF( nHorasRea == 0, NTOH( 0 ), NgTraNtoH(nHorasRea) ),Round(nHorasRea/nHorasPre*100,2)})
							Endif
					Endif
				Endif
			ElseIf _nPar == 3 //Distribuicao x OS
				If !lDetalhado
					nPos := aSCAN(aColsCab,{|x| x[2] == (cAliasQry)->TJ_ORDEM })
					If nPos == 0 .Or. lDuploClick
						If !lDuploClick
							aAdd(aColsCab,{lOK,(cAliasQry)->TJ_ORDEM,cTJ_STFOLUP,(cAliasQry)->TJ_CODBEM,nNomeBem,;
												STOD((cAliasQry)->TJ_DTMPINI),IIF( nHorasPre == 0, NTOH( 0 ), NgTraNtoH(nHorasPre) ),IIF( nHorasRea == 0, NTOH( 0 ), NgTraNtoH(nHorasRea) ),Round(nHorasRea/nHorasPre*100,2)})
						Endif
						If !lDuploClick .Or. (lDuploClick .And. (cAliasQry)->TJ_PRIORID == cPrioDuplo .And. (cAliasQry)->TJ_ORDEM == cOrdeDuplo)
							For nI := 1 to Len(aInsumos)
								aAdd(aColsInfer,{aInsumos[nI][1],aInsumos[nI][2],aInsumos[nI][3],aInsumos[nI][4],aInsumos[nI][5],NgTraNtoH(aInsumos[nI][6]) })
							Next
						Endif
					Endif
				Else //Detalhado
					nPos := aSCAN(aColsCab,{|x| x[2]+x[3] == aPerAcols[nX]+(cAliasQry)->TJ_ORDEM })
					If nPos == 0 .Or. lDuploClick
						If !lDuploClick
							aAdd(aColsCab,{lOK,aPerAcols[nX],(cAliasQry)->TJ_ORDEM,cTJ_STFOLUP,(cAliasQry)->TJ_CODBEM,nNomeBem,;
												STOD((cAliasQry)->TJ_DTMPINI),IIF( nHorasPre == 0, NTOH( 0 ), NgTraNtoH(nHorasPre) ),IIF( nHorasRea == 0, NTOH( 0 ), NgTraNtoH(nHorasRea) ),Round(nHorasRea/nHorasPre*100,2)})
						Endif
						If !lDuploClick .Or. (lDuploClick .And. (cAliasQry)->TJ_PRIORID == cPrioDuplo .And. (cAliasQry)->TJ_ORDEM == cOrdeDuplo .And. aPerAcols[nX] == cPerDuplo)
							For nI := 1 to Len(aInsumos)
								aAdd(aColsInfer,{aPerAcols[nX],aInsumos[nI][1],aInsumos[nI][2],aInsumos[nI][3],aInsumos[nI][4],aInsumos[nI][5],NgTraNtoH(aInsumos[nI][6]) })
							Next
						Endif
					Endif
				Endif
			Endif
		Next nX

		dbSelectArea(cAliasQry)
		dbSkip()
	End
	(cAliasQry)->(dbCloseArea())

	QueryTT2(_nPar)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} RelatoC400
Cria os relatorios

@author Marcos Wagner Junior
@since	19/02/2009
/*/
//---------------------------------------------------------------------
Static Function RelatoC400(_nPaiFilho)
Local WNREL      := "MNTC400"
Local cDESC1     := STR0091 //"Relatorio"
Local cDESC2     := ""
Local cDESC3     := ""
Local cSTRING    := "ST9"
Local lOpcNaoDis := .T.

Private NOMEPROG := "MNTC400"
Private TAMANHO  := "G"
Private aRETURN  := {STR0092,1,STR0093,1,2,1,"",1} //{"Zebrado", 1,"Administracao", 2, 2, 1, "",1} //"Zebrado"###"Administracao"
Private TITULO   := STR0034 //"Ociosidade x Centro de Custo"
//Private nTIPO    := 0
Private nLASTKEY := 0
Private CABEC1,CABEC2
Private cPERG := "MNC400"

If Len(aColsCab) == 1
	If ValType(aColsCab[1][1]) == "C" .and. Empty(aColsCab[1][1])
		MsgInfo(STR0177)//"N„o h· dados para impress„o do relatÛrio."
  		Return .F.
  	Elseif ValType(aColsCab[1][1]) == "L" .and. Empty(aColsCab[1][2])
  		MsgInfo(STR0177)//"N„o h· dados para impress„o do relatÛrio."
  		Return .F.
  	Endif
Endif

If cTpAnalise = "O" //Ociosidade
	If nAcesso == 0 //Por Centro de Custo
		Titulo := STR0094+DTOC(dTpAnaliDe)+" - "+DTOC(dTpAnaliAte)+")" //"Ociosidade x Centro de Custo ("
		cDESC1 := STR0095 //"RelatÛrio de Ociosidade x Centro de Custo"
	ElseIf nAcesso == 1 //Por Especialidade
		Titulo := STR0096+DTOC(dTpAnaliDe)+" - "+DTOC(dTpAnaliAte)+")" //"Ociosidade x Especialidade ("
		cDESC1 := STR0097 //"RelatÛrio de Ociosidade x Especialidade"
		If _nPaiFilho == 2
			lOpcNaoDis := .F.
		Endif
	ElseIf nAcesso == 2 //Por Funcionario
		Titulo := STR0098+DTOC(dTpAnaliDe)+" - "+DTOC(dTpAnaliAte)+")" //"Ociosidade x Funcion·rio ("
		cDESC1 := STR0099 //"RelatÛrio de Ociosidade x Funcion·rio"
		lOpcNaoDis := .F.
	Endif
ElseIf cTpAnalise = "U" //Utilizacao
	If nAcesso == 0 //Por Centro de Custo
		Titulo := STR0100+DTOC(dTpAnaliDe)+" - "+DTOC(dTpAnaliAte)+")" //"UtilizaÁ„o x Centro de Custo ("
		cDESC1 := STR0101 //"RelatÛrio de UtilizaÁ„o x Centro de Custo"
	ElseIf nAcesso == 1 //Por Especialidade
		Titulo := STR0102+DTOC(dTpAnaliDe)+" - "+DTOC(dTpAnaliAte)+")" //"UtilizaÁ„o x Especialidade ("
		cDESC1 := STR0103 //"RelatÛrio de UtilizaÁ„o x Especialidade"
		If _nPaiFilho == 2
			lOpcNaoDis := .F.
		Endif
	ElseIf nAcesso == 2 //Por Funcion·rio
		Titulo := STR0104+DTOC(dTpAnaliDe)+" - "+DTOC(dTpAnaliAte)+")" //"UtilizaÁ„o x Funcion·rio ("
		cDESC1 := STR0105 //"RelatÛrio de UtilizaÁ„o x Funcion·rio"
		lOpcNaoDis := .F.
	Endif
ElseIf cTpAnalise = "E" //Eficiencia
	If nAcesso == 0 //Por Centro de Custo
		Titulo := STR0106+DTOC(dTpAnaliDe)+" - "+DTOC(dTpAnaliAte)+")" //"EficiÍncia x Centro de Custo ("
		cDESC1 := STR0107 //"RelatÛrio de EficiÍncia x Centro de Custo"
	ElseIf nAcesso == 1 //Por Especialidade
		Titulo := STR0108+DTOC(dTpAnaliDe)+" - "+DTOC(dTpAnaliAte)+")" //"EficiÍncia x Especialidade ("
		cDESC1 := STR0109 //"RelatÛrio de EficiÍncia x Especialidade"
	ElseIf nAcesso == 2 //Por Funcion·rio
		Titulo := STR0110+DTOC(dTpAnaliDe)+" - "+DTOC(dTpAnaliAte)+")" //"EficiÍncia x Funcion·rio ("
		cDESC1 := STR0111 //"RelatÛrio de EficiÍncia x Funcion·rio"
		If _nPaiFilho == 2
			lOpcNaoDis := .F.
		Endif
	Endif
ElseIf cTpAnalise = "D" //Distribuicao
	If nAcesso == 1 //Por
		Titulo := STR0114+DTOC(dTpAnaliDe)+" - "+DTOC(dTpAnaliAte)+")" //"DistribuiÁ„o x Prioridade "
		cDESC1 := STR0115 //"RelatÛrio de DistribuiÁ„o x Prioridade"
	Else
		MsgInfo(STR0116,STR0117) //"OpÁ„o n„o disponÌvel!"###"AtenÁ„o"
		Return
	Endif
Endif

If lDetalhado .And. !lOpcNaoDis
	MsgInfo(STR0118,STR0117) //"OpÁ„o n„o disponÌvel para 'PerÌodo' igual a 'Detalhado'!"###"AtenÁ„o"
	Return
Endif

Pergunte(cPERG,.F.)

// Envia controle para a funcao SETPRINT
WNREL:=SetPrint(cSTRING,WNREL,,TITULO,cDESC1,cDESC2,cDESC3,.F.,"")
If nLASTKEY = 27
   Set Filter To
   DbSelectArea("ST9")
   Return
EndIf
SetDefault(aRETURN,cSTRING)
RptStatus({|lEND| RelatoImpr(@lEND,WNREL,TITULO,TAMANHO,_nPaiFilho)},TITULO)
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} RelatoImpr
Cria os relatorios

@author Marcos Wagner Junior
@since	19/02/2009
/*/
//---------------------------------------------------------------------
Static Function RelatoImpr(lEND,WNREL,TITULO,TAMANHO,_nPaiFilho)

Local nPai := 0
Local nFilho := 0
Local cRODATXT := ""
Local nCNTIMPR := 0
Local cCabecRel := ""
Local nX
Local cCab1
Local cCab2

Private li := 80 ,m_pag := 1
Private nTIPO  := IIf(aReturn[4]==1,15,18)

If nP == 0
	nX := 0
	cCab1 := ""
	cCab2 := ""
Else
	nX := 12
	cCab1 := STR0119 //"PerÌodo     "
	cCab2 := Space(12)
Endif

CABEC1 := ""
CABEC2 := ""

If cTpAnalise = "O" //Ociosidade

	//Utilizado no Ociosidade x Centro de Custo e Ociosidade x Especialidade
	/*/
	          1         2         3         4         5         6         7         8         9         0         1         2         3         4
	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
	***************************************************************************************************************************************************
	-----------------Produtivas-----------------   ----------------Improdutivas----------------   ---Total---   ---DisponÌvel---   ---N„o Reportadas---
	    Horas                Valor   Porcentagem       Horas                Valor   Porcentagem      Horas            Horas                Horas
	***************************************************************************************************************************************************
	999999:99   999.999.999.999,99       999,99%   999999:99   999.999.999.999,99       999,99%   99999999:99     99999999:99            99999999:99
	999999:99   999.999.999.999,99       999,99%   999999:99   999.999.999.999,99       999,99%   99999999:99     99999999:99            99999999:99
	*/
	If nAcesso == 0 //Ociosidade x Centro de Custo
		CABEC1 := cCab1+STR0120 //"-----------------Produtivas-----------------   ----------------Improdutivas----------------   ---Total---   ---DisponÌvel---   ---N„o Reportadas---"
		CABEC2 := cCab2+STR0121	 //"    Horas                Valor   Porcentagem       Horas                Valor   Porcentagem      Horas            Horas                Horas       "
		For nPai := 1 To Len(aColsCab)
			NgSomaLi(58)

			@Li,000 Psay STR0086 + aColsCab[nPai][1+nP] + ' - ' + AllTrim(aColsCab[nPai][2+nP]) //"Centro de Custo: "
			If _nPaiFilho == 1
				NgSomaLi(58)
				NgSomaLi(58)
				If lDetalhado
					@Li,000 Psay aColsCab[nPai][1]
				Endif
				@Li,000+nX Psay PADL(aColsCab[nPai][3+nP],9)
				@Li,012+nX Psay aColsCab[nPai][4+nP] Picture '@E 999,999,999,999.99'
				@Li,037+nX Psay aColsCab[nPai][5+nP] Picture '@E 999.99' +'%'
				@Li,047+nX Psay PADL(aColsCab[nPai][6+nP],9)
				@Li,059+nX Psay aColsCab[nPai][7+nP] Picture '@E 999,999,999,999.99'
				@Li,084+nX Psay aColsCab[nPai][8+nP] Picture '@E 999.99' +'%'
				@Li,094+nX Psay PADL(aColsCab[nPai][9+nP],11)
				@Li,110+nX Psay PADL(aColsCab[nPai][10+nP],11)
				@Li,133+nX Psay PADL(aColsCab[nPai][11+nP],11)
			ElseIf _nPaiFilho == 2
				NgSomaLi(58)
				For nFilho := 1 To Len(aColsInfer)
					If aColsCab[nPai][1+nP] == aColsInfer[nFilho][1+nP] .And. (!lDetalhado .Or.;
					   (lDetalhado .And. aColsCab[nPai][1] == aColsInfer[nFilho][1]))
						NgSomaLi(58)
						@Li,000 Psay STR0087 + aColsInfer[nFilho][2+nP] + ' - ' + AllTrim(aColsInfer[nFilho][3+nP]) //"Especialidade: "
						NgSomaLi(58)
						If lDetalhado
							@Li,000 Psay aColsInfer[nFilho][1]
						Endif
						@Li,000+nX Psay PADL(aColsInfer[nFilho][5+nP],9)
						@Li,012+nX Psay aColsInfer[nFilho][6+nP] Picture '@E 999,999,999,999.99'
						@Li,037+nX Psay aColsInfer[nFilho][7+nP] Picture '@E 999.99' +'%'
						@Li,047+nX Psay PADL(aColsInfer[nFilho][8+nP],9)
						@Li,059+nX Psay aColsInfer[nFilho][9+nP]  Picture '@E 999,999,999,999.99'
						@Li,084+nX Psay aColsInfer[nFilho][10+nP] Picture '@E 999.99' +'%'
						@Li,094+nX Psay PADL(aColsInfer[nFilho][11+nP],11)
						@Li,110+nX Psay PADL(aColsInfer[nFilho][12+nP],11)
						@Li,133+nX Psay PADL(aColsInfer[nFilho][13+nP],11)
					Endif
				Next
			Endif
			If nPai != Len(aColsCab)
				NgSomaLi(58)
				@Li,000 Psay __PrtThinLine()
			Endif
		Next
	ElseIf nAcesso == 1 	//Ociosidade x Especialidade
		If _nPaiFilho == 1
			CABEC1 := cCab1+STR0120 //"-----------------Produtivas-----------------   ----------------Improdutivas----------------   ---Total---   ---DisponÌvel---   ---N„o Reportadas---"
			CABEC2 := cCab2+STR0121	 //"    Horas                Valor   Porcentagem       Horas                Valor   Porcentagem      Horas            Horas                Horas       "
		ElseIf _nPaiFilho == 2
			CABEC1 := STR0122 //"                                                                                                               N„o"
			CABEC2 := STR0123 //"MatrÌcula   Nome                             Produtivas         %   Improdutivas         %         Total    Reportadas   DisponÌveis"
		Endif
		If !Empty(cCCDuplo)
			cCabecRel := STR0086+AllTrim(cCCDuplo)+' - '+AllTrim(NGSEEK("CTT",cCCDuplo,1,"CTT_DESC01")) //"Centro de Custo: "
		Endif
		For nPai := 1 To Len(aColsCab)
			If !Empty(cCabecRel)
				NgSomaLi(58)
				@Li,000 Psay cCabecRel
				NgSomaLi(58)
				@Li,000 Psay __PrtThinLine()
			Endif
			NgSomaLi(58)

			@Li,000 Psay STR0087 + aColsCab[nPai][1+nP] + ' - ' + AllTrim(aColsCab[nPai][2+nP]) //"Especialidade: "
			If _nPaiFilho == 1
				NgSomaLi(58)
				NgSomaLi(58)
				If lDetalhado
					@Li,000 Psay aColsCab[nPai][1]
				Endif
				@Li,000+nX Psay PADL(aColsCab[nPai][4+nP],9)
				@Li,012+nX Psay aColsCab[nPai][5+nP] Picture '@E 999,999,999,999.99'
				@Li,037+nX Psay aColsCab[nPai][6+nP] Picture '@E 999.99' +'%'
				@Li,047+nX Psay PADL(aColsCab[nPai][7+nP],9)
				@Li,059+nX Psay aColsCab[nPai][8+nP] Picture '@E 999,999,999,999.99'
				@Li,084+nX Psay aColsCab[nPai][9+nP] Picture '@E 999.99' +'%'
				@Li,094+nX Psay PADL(aColsCab[nPai][10+nP],11)
				@Li,110+nX Psay PADL(aColsCab[nPai][11+nP],11)
				@Li,133+nX Psay PADL(aColsCab[nPai][12+nP],11)
			ElseIf _nPaiFilho == 2
				/*/
				          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7
				0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
				****************************************************************************************************************************************************************************
                                                                                                                           N„o
				MatrÌcula   Nome                             Produtivas         %   Improdutivas         %         Total    Reportadas   DisponÌveis
				*****************************************************************************************************************************************************
				XXXXXX      XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX    999999,99   999,99%      999999,99   999,99%   99999999,99   99999999,99   99999999,99
				XXXXXX      XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX    999999,99   999,99%      999999,99   999,99%   99999999,99   99999999,99   99999999,99
				*/
				NgSomaLi(58)
				For nFilho := 1 To Len(aColsInfer)
					If aColsCab[nPai][1] == aColsInfer[nFilho][1]
						NgSomaLi(58)
						@Li,000 Psay aColsInfer[nFilho][2]
						@Li,012 Psay SubStr(aColsInfer[nFilho][3],1,30)
						@Li,046 Psay PADL(aColsInfer[nFilho][4],9)
						@Li,058 Psay aColsInfer[nFilho][5] Picture '@E 999.99' +'%'
						@Li,071 Psay PADL(aColsInfer[nFilho][6],9)
						@Li,083 Psay aColsInfer[nFilho][7] Picture '@E 999.99' +'%'
						@Li,093 Psay PADL(aColsInfer[nFilho][8],11)
						@Li,107 Psay PADL(aColsInfer[nFilho][10],11)
						@Li,121 Psay PADL(aColsInfer[nFilho][9],11)
					Endif
				Next
			Endif
			If nPai != Len(aColsCab)
				NgSomaLi(58)
				@Li,000 Psay __PrtThinLine()
			Endif
		Next
	ElseIf nAcesso == 2 	//Ociosidade x Funcionario
		If _nPaiFilho == 1
			CABEC1 := STR0122 //"                                                                                                               N„o"
			CABEC2 := STR0123 //"MatrÌcula   Nome                             Produtivas         %   Improdutivas         %         Total    Reportadas   DisponÌveis"
		ElseIf _nPaiFilho == 2
			/*/
			          1         2         3         4         5         6         7
			0123456789012345678901234567890123456789012345678901234567890123456789012
			*************************************************************************
			MatrÌcula   Funcion·rio
				Tipo de Hora                Total Horas         %           Valor (R$)
			*************************************************************************
			XXXXXXXXXXXXXXXXXXXXXXXXX        999999,99   999,99%   999.999.999.999,99
			XXXXXXXXXXXXXXXXXXXXXXXXX
			*/
			CABEC1 := STR0124 //"MatrÌcula   Funcion·rio"
			CABEC2 := STR0125 //"   Tipo de Hora                Total Horas         %           Valor (R$)"
		Endif
		If !Empty(cCCDuplo)
			cCabecRel := STR0086+AllTrim(cCCDuplo)+' - '+AllTrim(NGSEEK("CTT",cCCDuplo,1,"CTT_DESC01")) //"Centro de Custo: "
		Endif
		If !Empty(cEspDuplo)
			cCabecRel += If(Empty(cCCDuplo),"",Space(10))+STR0087+AllTrim(cEspDuplo)+' - '+AllTrim(NGSEEK("ST0",cEspDuplo,1,"T0_NOME")) //"Especialidade: "
		Endif
		For nPai := 1 To Len(aColsCab)
			If !Empty(cCabecRel)
				NgSomaLi(58)
				@Li,000 Psay cCabecRel
				NgSomaLi(58)
				@Li,000 Psay __PrtThinLine()
			Endif
			If _nPaiFilho == 1
				NgSomaLi(58)
				@Li,000 Psay aColsCab[nPai][1]
				@Li,012 Psay SubStr(aColsCab[nPai][2],1,30)
				@Li,046 Psay PADL(aColsCab[nPai][3],9)
				@Li,058 Psay aColsCab[nPai][4] Picture '@E 999.99' +'%'
				@Li,071 Psay PADL(aColsCab[nPai][5],9)
				@Li,083 Psay aColsCab[nPai][6] Picture '@E 999.99' +'%'
				@Li,093 Psay PADL(aColsCab[nPai][7],11)
				@Li,107 Psay PADL(aColsCab[nPai][9],11)
				@Li,121 Psay PADL(aColsCab[nPai][8],11)
			ElseIf _nPaiFilho == 2
				NgSomaLi(58)
				@Li,000 Psay aColsCab[nPai][1]
				@Li,012 Psay aColsCab[nPai][2]
				For nFilho := 1 To Len(aColsInfer)
					If aColsCab[nPai][1] == aColsInfer[nFilho][1]
						NgSomaLi(58)
						@Li,003 Psay SubStr(aColsInfer[nFilho][2],1,25)
						@Li,033 Psay PADL(aColsInfer[nFilho][3],9)
						@Li,045 Psay aColsInfer[nFilho][4] Picture '@E 999.99' +'%'
						@Li,055 Psay aColsInfer[nFilho][5] Picture '@E 999,999,999,999.99'
					Endif
				Next
				If nPai != Len(aColsCab)
					NgSomaLi(58)
					@Li,000 Psay __PrtThinLine()
				Endif
			Endif
		Next
	Endif
ElseIf cTpAnalise = "U" //Utilizacao
	If nAcesso == 0 //Por Centro de Custo
		If _nPaiFilho == 1
/*/
          1         2         3         4         5         6         7         8         9         0
012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234
*********************************************************************************************************
-----------------Preventivas----------------   -----------------Corretivas-----------------   ---Total---
    Horas                Valor   Porcentagem       Horas                Valor   Porcentagem      Horas
*********************************************************************************************************
999999:99   999.999.999.999,99       999,99%   999999:99   999.999.999.999,99       999,99%   99999999:99
999999:99   999.999.999.999,99       999,99%   999999:99   999.999.999.999,99       999,99%   99999999:99
*/
			CABEC1 := cCab1+STR0126 //"-----------------Preventivas----------------   -----------------Corretivas-----------------   ---Total---"
			CABEC2 := cCab2+STR0127 //"    Horas                Valor   Porcentagem       Horas                Valor   Porcentagem      Horas   "

			For nPai := 1 To Len(aColsCab)
				NgSomaLi(58)
				@Li,000 Psay STR0086 + aColsCab[nPai][1+nP] + ' - ' + AllTrim(aColsCab[nPai][2+nP]) //"Centro de Custo: "
				If _nPaiFilho == 1
					NgSomaLi(58)
					NgSomaLi(58)
					If lDetalhado
						@Li,000 Psay aColsCab[nPai][1]
					Endif
					@Li,000+nX Psay PADL(aColsCab[nPai][3+nP],9)
					@Li,012+nX Psay aColsCab[nPai][4+nP] Picture '@E 999,999,999,999.99'
					@Li,037+nX Psay aColsCab[nPai][5+nP] Picture '@E 999.99' +'%'
					@Li,047+nX Psay PADL(aColsCab[nPai][6+nP],9)
					@Li,059+nX Psay aColsCab[nPai][7+nP] Picture '@E 999,999,999,999.99'
					@Li,084+nX Psay aColsCab[nPai][8+nP] Picture '@E 999.99' +'%'
					@Li,094+nX Psay PADL(aColsCab[nPai][9+nP],11)
				Endif
				If nPai != Len(aColsCab)
					NgSomaLi(58)
					@Li,000 Psay __PrtThinLine()
				Endif
			Next
		ElseIf _nPaiFilho == 2
/*/
          1         2         3         4         5         6         7         8         9         0         1         2
01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567
********************************************************************************************************************************
                       -----------------Preventivas----------------   -----------------Corretivas-----------------   ---Total---
C.C. Aplic.                Horas                Valor   Porcentagem       Horas                Valor   Porcentagem      Horas
********************************************************************************************************************************
XXXXXXXXXXXXXXXXXXXX   999999:99   999.999.999.999,99       999,99%   999999:99   999.999.999.999,99       999,99%   99999999:99
XXXXXXXXXXXXXXXXXXXX   999999:99   999.999.999.999,99       999,99%   999999:99   999.999.999.999,99       999,99%   99999999:99
*/
			CABEC1 := cCab1+STR0128 //"                       -----------------Preventivas----------------   -----------------Corretivas-----------------   ---Total---"
			CABEC2 := cCab2+STR0129 //"C.C. Aplic.                Horas                Valor   Porcentagem       Horas                Valor   Porcentagem      Horas   "

			cEspecOld := ""

			NgSomaLi(58)
			For nFilho := 1 To Len(aColsInfer)
				If cEspecOld != aColsInfer[nFilho][2+nP]
					NgSomaLi(58)
					If nFilho != 1
						@Li,000 Psay __PrtThinLine()
						NgSomaLi(58)
					Endif
					@Li,000 Psay STR0087 + aColsInfer[nFilho][2+nP] + ' - ' + AllTrim(aColsInfer[nFilho][3+nP]) //"Especialidade: "
					NgSomaLi(58)
					cEspecOld := aColsInfer[nFilho][2+nP]
				Endif
				NgSomaLi(58)
				If lDetalhado
					nPosPai := aSCAN(aColsCab,{|x| x[1]+x[2] == aColsInfer[nFilho][1]+aColsInfer[nFilho][2] })
					@Li,000 Psay aColsInfer[nFilho][1]
				Else
					nPosPai := aSCAN(aColsCab,{|x| x[1] == aColsInfer[nFilho][1] })
				Endif
				@Li,000+nX Psay aColsCab[nPosPai][1+nP]
				@Li,023+nX Psay PADL(aColsInfer[nFilho][6+nP],9)
				@Li,035+nX Psay aColsInfer[nFilho][7+nP] Picture '@E 999,999,999,999.99'
				@Li,060+nX Psay aColsInfer[nFilho][8+nP] Picture '@E 999.99' +'%'
				@Li,070+nX Psay PADL(aColsInfer[nFilho][9+nP],9)
				@Li,082+nX Psay aColsInfer[nFilho][10+nP] Picture '@E 999,999,999,999.99'
				@Li,107+nX Psay aColsInfer[nFilho][11+nP] Picture '@E 999.99' +'%'
				@Li,117+nX Psay PADL(aColsInfer[nFilho][12+nP],11)
			Next
		Endif
	ElseIf nAcesso == 1 //Por Especialidade
		If _nPaiFilho == 1
			/*/
			          1         2         3         4         5         6         7         8         9         0
			012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234
			*********************************************************************************************************
			-----------------Preventivas----------------   -----------------Corretivas-----------------   ---Total---
			    Horas                Valor   Porcentagem       Horas                Valor   Porcentagem      Horas
			*********************************************************************************************************
			999999:99   999.999.999.999,99       999,99%   999999:99   999.999.999.999,99       999,99%   99999999:99
			999999:99   999.999.999.999,99       999,99%   999999:99   999.999.999.999,99       999,99%   99999999:99
			*/
			CABEC1 := cCab1+STR0126 //"-----------------Preventivas----------------   -----------------Corretivas-----------------   ---Total---"
			CABEC2 := cCab2+STR0127 //"    Horas                Valor   Porcentagem       Horas                Valor   Porcentagem      Horas   "
			For nPai := 1 To Len(aColsCab)
				NgSomaLi(58)
				If !Empty(cCCDuplo)
					NgSomaLi(58)
					@Li,000 Psay STR0086 + AllTrim(cCCDuplo) + ' - ' + AllTrim(NGSEEK("CTT",cCCDuplo,1,"CTT_DESC01")) //"Centro de Custo: "
					NgSomaLi(58)
					NgSomaLi(58)
				Endif
				@Li,000 Psay STR0087 + aColsCab[nPai][1+nP] + ' - ' + AllTrim(aColsCab[nPai][2+nP]) + Space (06) + ; //"Especialidade: "
								 STR0130 + AllTrim(aColsCab[nPai][4+nP]) + ' - ' +; //"C.C. do Funcion·rio: "
								  AllTrim(NGSEEK("CTT",AllTrim(aColsCab[nPai][4+nP]),1,"CTT_DESC01"))
				If _nPaiFilho == 1
					NgSomaLi(58)
					NgSomaLi(58)
					If lDetalhado
						@Li,000 Psay aColsCab[nPai][1]
					Endif
					@Li,000+nX Psay PADL(aColsCab[nPai][5+nP],9)
					@Li,012+nX Psay aColsCab[nPai][6+nP] Picture '@E 999,999,999,999.99'
					@Li,037+nX Psay aColsCab[nPai][7+nP] Picture '@E 999.99' +'%'
					@Li,047+nX Psay PADL(aColsCab[nPai][8+nP],9)
					@Li,059+nX Psay aColsCab[nPai][9+nP] Picture '@E 999,999,999,999.99'
					@Li,084+nX Psay aColsCab[nPai][10+nP] Picture '@E 999.99' +'%'
					@Li,094+nX Psay PADL(aColsCab[nPai][11+nP],11)
				Endif
				If nPai != Len(aColsCab)
					NgSomaLi(58)
					@Li,000 Psay __PrtThinLine()
				Endif
			Next
		ElseIf _nPaiFilho == 2
			/*/
			          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7
			0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
			****************************************************************************************************************************************************************************
			                                                                   -----------------Preventivas----------------   -----------------Corretivas-----------------   ---Total---
			C.C. Func.             Espec.   MatrÌcula   Nome                       Horas                Valor   Porcentagem       Horas                Valor   Porcentagem      Horas
			****************************************************************************************************************************************************************************
			XXXXXXXXXXXXXXXXXXXX   XXX      XXXXXX      XXXXXXXXXXXXXXXXXXXX   999999:99   999.999.999.999,99       999,99%   999999:99   999.999.999.999,99       999,99%   99999999:99
			XXXXXXXXXXXXXXXXXXXX   XXX      XXXXXX      XXXXXXXXXXXXXXXXXXXX   999999:99   999.999.999.999,99       999,99%   999999:99   999.999.999.999,99       999,99%   99999999:99
			*/
			aSort(aColsInfer,,,{|x,y| x[2]+x[1] < y[2]+y[1]})

			CABEC1 := STR0131 //"                                                                   -----------------Preventivas----------------   -----------------Corretivas-----------------   ---Total---"
			CABEC2 := STR0132 //"C.C. Func.             Espec.   MatrÌcula   Nome                       Horas                Valor   Porcentagem       Horas                Valor   Porcentagem      Horas   "

			For nFilho := 1 To Len(aColsInfer)
				NgSomaLi(58)
				If !Empty(cCCDuplo)
					NgSomaLi(58)
					@Li,000 Psay STR0086 + AllTrim(cCCDuplo) + ' - ' + AllTrim(NGSEEK("CTT",cCCDuplo,1,"CTT_DESC01")) //"Centro de Custo: "
					NgSomaLi(58)
					NgSomaLi(58)
				Endif
				@Li,000 Psay aColsInfer[nFilho][2]
				@Li,023 Psay aColsInfer[nFilho][1]
				@Li,032 Psay aColsInfer[nFilho][3]
				@Li,044 Psay SubStr(aColsInfer[nFilho][4],1,20)
				@Li,067 Psay PADL(aColsInfer[nFilho][5],9)
				@Li,079 Psay aColsInfer[nFilho][6] Picture '@E 999,999,999,999.99'
				@Li,104 Psay aColsInfer[nFilho][7] Picture '@E 999.99' +'%'
				@Li,114 Psay PADL(aColsInfer[nFilho][8],9)
				@Li,126 Psay aColsInfer[nFilho][9] Picture '@E 999,999,999,999.99'
				@Li,151 Psay aColsInfer[nFilho][10] Picture '@E 999.99' +'%'
				@Li,161 Psay PADL(aColsInfer[nFilho][11],11)
			Next
      Endif
	ElseIf nAcesso == 2 //Por Funcionario
		If _nPaiFilho == 1
			/*/
			          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7
			0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
			****************************************************************************************************************************************************************************
			                                                                   -----------------Preventivas----------------   -----------------Corretivas-----------------   ---Total---
			C.C. Func.             Espec.   MatrÌcula   Nome                       Horas                Valor   Porcentagem       Horas                Valor   Porcentagem      Horas
			****************************************************************************************************************************************************************************
			XXXXXXXXXXXXXXXXXXXX   XXX      XXXXXX      XXXXXXXXXXXXXXXXXXXX   999999:99   999.999.999.999,99       999,99%   999999:99   999.999.999.999,99       999,99%   99999999:99
			XXXXXXXXXXXXXXXXXXXX   XXX      XXXXXX      XXXXXXXXXXXXXXXXXXXX   999999:99   999.999.999.999,99       999,99%   999999:99   999.999.999.999,99       999,99%   99999999:99
			*/
			aColsAux := {}
			For nPai := 1 To Len(aColsCab)
				aAdd(aColsAux,{aColsCab[nPai][1],aColsCab[nPai][2],aColsCab[nPai][3],aColsCab[nPai][4],aColsCab[nPai][5],;
									aColsCab[nPai][6],aColsCab[nPai][7],aColsCab[nPai][8],aColsCab[nPai][9],;
									NGSEEK("ST1",aColsCab[nPai][1],1,"T1_CCUSTO"),NGSEEK("ST2",aColsCab[nPai][1],1,"T2_ESPECIA")})
			Next
			aSort(aColsAux,,,{|x,y| x[10]+x[11]+x[1] < y[10]+y[11]+y[1]})

			CABEC1 := STR0131 //"                                                                   -----------------Preventivas----------------   -----------------Corretivas-----------------   ---Total---"
			CABEC2 := STR0132 //"C.C. Func.             Espec.   MatrÌcula   Nome                       Horas                Valor   Porcentagem       Horas                Valor   Porcentagem      Horas   "

			For nPai := 1 To Len(aColsAux)
				NgSomaLi(58)
				If !Empty(cCCDuplo)
					NgSomaLi(58)
					@Li,000 Psay STR0086 + AllTrim(cCCDuplo) + ' - ' + AllTrim(NGSEEK("CTT",cCCDuplo,1,"CTT_DESC01")) //"Centro de Custo: "
					NgSomaLi(58)
					NgSomaLi(58)
				Endif
				@Li,000 Psay aColsAux[nPai][10]
				@Li,023 Psay aColsAux[nPai][11]
				@Li,032 Psay aColsAux[nPai][1]
				@Li,044 Psay aColsAux[nPai][2]
				@Li,067 Psay PADL(aColsAux[nPai][3],9)
				@Li,079 Psay aColsAux[nPai][4] Picture '@E 999,999,999,999.99'
				@Li,104 Psay aColsAux[nPai][5] Picture '@E 999.99' +'%'
				@Li,114 Psay PADL(aColsAux[nPai][6],9)
				@Li,126 Psay aColsAux[nPai][7] Picture '@E 999,999,999,999.99'
				@Li,151 Psay aColsAux[nPai][8] Picture '@E 999.99' +'%'
				@Li,161 Psay PADL(aColsAux[nPai][9],11)
			Next
		ElseIf _nPaiFilho == 2
			/*/
			          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6
			012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
			******************************************************************************************************************************************************************
                                                                                                                                        -----InÌcio-----   -------Fim------
			OS       Bem                Nome Bem                         Centro de Custo        ServiÁo   Nome ServiÁo                         Data    Hora       Data    Hora
			******************************************************************************************************************************************************************
			XXXXXX   XXXXXXXXXXXXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   XXXXXXXXXXXXXXXXXXXX   XXXXXX    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   99/99/99   99:99   99/99/99   99:99
			XXXXXX   XXXXXXXXXXXXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   XXXXXXXXXXXXXXXXXXXX   XXXXXX    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   99/99/99   99:99   99/99/99   99:99
			*/
			CABEC1 := STR0133 //"                                                                                                                               -----InÌcio-----   -------Fim------"
			CABEC2 := STR0134 //"OS       Bem                Nome Bem                         Centro de Custo        ServiÁo   Nome ServiÁo                         Data    Hora       Data    Hora"
			cOldFunc := ""
			aSort(aColsOSxFu,,,{|x,y| x[1]+x[2] < y[1]+y[2]})
			For nFilho := 1 to Len(aColsOSxFu)
				NgSomaLi(58)
				If aColsOSxFu[nFilho][1] != cOldFunc
					If nFilho != 1
						NgSomaLi(58)
						NgSomaLi(58)
					Endif
					@Li,000 Psay STR0135+aColsOSxFu[nFilho][1]+' - '+aColsOSxFu[nFilho][12]+Space(10)+; //"Funcion·rio: "
									 STR0087+aColsOSxFu[nFilho][13]+' - '+aColsOSxFu[nFilho][14]+Space(10)+; //"Especialidade: "
									 STR0136+aColsOSxFu[nFilho][15]+' - '+aColsOSxFu[nFilho][16] //"C.Custo: "
					cOldFunc := aColsOSxFu[nFilho][1]
					NgSomaLi(58)
					NgSomaLi(58)
				Endif

				@Li,000 Psay aColsOSxFu[nFilho][2]
				@Li,009 Psay aColsOSxFu[nFilho][3]
				@Li,028 Psay SubStr(aColsOSxFu[nFilho][4],1,30)
				@Li,061 Psay aColsOSxFu[nFilho][5]
				@Li,084 Psay aColsOSxFu[nFilho][20]//Tarefa
				@Li,094 Psay SubStr(aColsOSxFu[nFilho][21],1,30)
				@Li,127 Psay aColsOSxFu[nFilho][17]//Etapa
				@Li,137 Psay SubStr(aColsOSxFu[nFilho][18],1,30)
				@Li,170 Psay aColsOSxFu[nFilho][8]
				@Li,181 Psay aColsOSxFu[nFilho][9]
				@Li,189 Psay aColsOSxFu[nFilho][10]
				@Li,200 Psay aColsOSxFu[nFilho][11]

				NgSomaLi(58)//Linha de observaÁ„o
				@Li,000 Psay STR0213 + SubStr(aColsOSxFu[nFilho][19],1,199)//Obs.: [...]

			Next
		Endif
	Endif
ElseIf cTpAnalise = "E" //Eficiencia
	If nAcesso == 0 //Por Centro de Custo
		For nPai := 1 To Len(aColsCab)
			If _nPaiFilho == 1
				/*/
				          1         2         3         4         5         6         7         8         9         0         1
				01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678
				***********************************************************************************************************************
				Centro de Custo        Nome                             Previstas   Realizadas   DiferenÁa   Porcentagem   Horas Extras
				***********************************************************************************************************************
				XXXXXXXXXXXXXXXXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   999999,99    999999,99   999999,99       999,99%      999999,99
				*/
				CABEC1 := cCab1+STR0137 //"Centro de Custo        Nome                             Previstas   Realizadas   DiferenÁa   Porcentagem   Horas Extras"
				CABEC2 := cCab2+""
				NgSomaLi(58)
				If lDetalhado
					@Li,000 Psay aColsCab[nPai][1]
				Endif
				@Li,000+nX Psay aColsCab[nPai][1+nP]
				@Li,023+nX Psay SubStr(aColsCab[nPai][2+nP],1,30)
				@Li,056+nX Psay PADL(aColsCab[nPai][3+nP],9)
				@Li,069+nX Psay PADL(aColsCab[nPai][4+nP],9)
				@Li,081+nX Psay PADL(aColsCab[nPai][5+nP],9)
				@Li,097+nX Psay aColsCab[nPai][6+nP] Picture '@E 999.99' +'%'
				@Li,110+nX Psay PADL(aColsCab[nPai][7+nP],9)
			ElseIf _nPaiFilho == 2
				/*/
				          1         2         3         4         5         6         7         8         9         0
				0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
				****************************************************************************************************************
				Especialidade   Nome                             Previstas   Realizadas   DiferenÁa   Porcentagem   Horas Extras
				****************************************************************************************************************
				XXXXXX          XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   999999,99    999999,99   999999,99       999,99%      999999,99
				*/
				CABEC1 := cCab1+STR0138 //"Especialidade   Nome                             Previstas   Realizadas   DiferenÁa   Porcentagem   Horas Extras"
				CABEC2 := cCab2+""
				If nPai != 1
					NgSomaLi(58)
					@Li,000 Psay __PrtThinLine()
					NgSomaLi(58)
				Else
					NgSomaLi(58)
				Endif
				@Li,000 Psay STR0086 + AllTrim(aColsCab[nPai][1+nP]) + ' - ' + AllTrim(aColsCab[nPai][2+nP]) //"Centro de Custo: "
				NgSomaLi(58)
				For nFilho := 1 To Len(aColsInfer)
					If aColsInfer[nFilho][1] == aColsCab[nPai][1] .And. (!lDetalhado .Or.;
																						 	(lDetalhado .And. aColsInfer[nFilho][2] == aColsCab[nPai][2]))
						NgSomaLi(58)
						If lDetalhado
							@Li,000 Psay aColsCab[nPai][1]
						Endif
						@Li,000+nX Psay aColsInfer[nFilho][2+nP]
						@Li,016+nX Psay aColsInfer[nFilho][3+nP]
						@Li,050+nX Psay PADL(aColsInfer[nFilho][4+nP],9)
						@Li,063+nX Psay PADL(aColsInfer[nFilho][5+nP],9)
						@Li,075+nX Psay PADL(aColsInfer[nFilho][6+nP],9)
						@Li,091+nX Psay aColsInfer[nFilho][7+nP] Picture '@E 999.99' +'%'
						@Li,104+nX Psay PADL(aColsInfer[nFilho][8+nP],9)
					Endif
				Next
			Endif
		Next
	ElseIf nAcesso == 1 //Por Especialidade
		If _nPaiFilho == 1
			/*/
			          1         2         3         4         5         6         7         8         9         0         1
			0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
			****************************************************************************************************************
			Especialidade   DescriÁ„o                        Previstas   Realizadas   DiferenÁa   Porcentagem   Horas Extras
			****************************************************************************************************************
			XXXXXX          XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   999999,99    999999,99   999999,99       999,99%      999999,99
			*/
			CABEC1 := cCab1+STR0139 //"Especialidade   DescriÁ„o                        Previstas   Realizadas   DiferenÁa   Porcentagem   Horas Extras"
			CABEC2 := cCab2+""
			For nPai := 1 To Len(aColsCab)
				NgSomaLi(58)
				If !Empty(cCCDuplo)
					NgSomaLi(58)
					@Li,000 Psay STR0086 + AllTrim(cCCDuplo) + ' - ' + AllTrim(NGSEEK("CTT",cCCDuplo,1,"CTT_DESC01")) //"Centro de Custo: "
					NgSomaLi(58)
					NgSomaLi(58)
				Endif
				If lDetalhado
					@Li,000 Psay aColsCab[nPai][1]
				Endif
				@Li,000+nX Psay aColsCab[nPai][1+nP]
				@Li,016+nX Psay SubStr(aColsCab[nPai][2+nP],1,30)
				@Li,049+nX Psay PADL(aColsCab[nPai][3+nP],9)
				@Li,062+nX Psay PADL(aColsCab[nPai][4+nP],9)
				@Li,074+nX Psay PADL(aColsCab[nPai][5+nP],9)
				@Li,090+nX Psay aColsCab[nPai][6+nP] Picture '@E 999.99' +'%'
				@Li,103+nX Psay PADL(aColsCab[nPai][7+nP],9)
			Next
		ElseIf _nPaiFilho == 2
			/*/
			          1         2         3         4         5         6         7         8         9         0         1
			0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567
			**********************************************************************************************************************
			MatrÌcula   Nome                                       Previstas   Realizadas   DiferenÁa   Porcentagem   Horas Extras
			**********************************************************************************************************************
			XXXXXX      XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   999999,99    999999,99   999999,99       999,99%      999999,99
			*/
			CABEC1 := cCab1+STR0140 //"MatrÌcula   Nome                                       Previstas   Realizadas   DiferenÁa   Porcentagem   Horas Extras"
			CABEC2 := cCab2+""
			For nPai := 1 To Len(aColsCab)
				NgSomaLi(58)
				If nPai != 1
					NgSomaLi(58)
				Endif
				If !Empty(cCCDuplo)
					NgSomaLi(58)
					@Li,000 Psay STR0087 + AllTrim(aColsCab[nPai][1+nP]) + ' - ' + AllTrim(aColsCab[nPai][2+nP]) + Space(10) +; //"Especialidade: "
									 STR0086 + AllTrim(cCCDuplo) + ' - ' + AllTrim(NGSEEK("CTT",cCCDuplo,1,"CTT_DESC01")) //"Centro de Custo: "
				Else
					@Li,000 Psay STR0087 + AllTrim(aColsCab[nPai][1+nP]) + ' - ' + AllTrim(aColsCab[nPai][2+nP]) //"Especialidade: "
				Endif
				NgSomaLi(58)
				@Li,000 Psay __PrtThinLine()
				For nFilho := 1 to Len(aColsInfer)
					If aColsCab[nPai][1] == aColsInfer[nFilho][1] .And. (!lDetalhado .Or.;
					   (lDetalhado .And. aColsCab[nPai][2] == aColsInfer[nFilho][2]))
						NgSomaLi(58)
						If lDetalhado
							@Li,000 Psay aColsInfer[nFilho][1]
						Endif
						@Li,000+nX Psay aColsInfer[nFilho][2+nP]
						@Li,012+nX Psay aColsInfer[nFilho][3+nP]
						@Li,055+nX Psay PADL(aColsInfer[nFilho][4+nP],9)
						@Li,068+nX Psay PADL(aColsInfer[nFilho][5+nP],9)
						@Li,080+nX Psay PADL(aColsInfer[nFilho][6+nP],9)
						@Li,096+nX Psay aColsInfer[nFilho][7+nP] Picture '@E 999.99' +'%'
						@Li,109+nX Psay PADL(aColsInfer[nFilho][8+nP],9)
					Endif
				Next
			Next
		Endif
	ElseIf nAcesso == 2 //Por Funcionario
		If _nPaiFilho == 1
			/*/
			          1         2         3         4         5         6         7         8         9         0         1
			0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567
			**********************************************************************************************************************
			MatrÌcula   Nome                                       Previstas   Realizadas   DiferenÁa   Porcentagem   Horas Extras
			**********************************************************************************************************************
			XXXXXX      XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   999999,99    999999,99   999999,99       999,99%      999999,99
			*/
			CABEC1 := cCab1+STR0140 //"MatrÌcula   Nome                                       Previstas   Realizadas   DiferenÁa   Porcentagem   Horas Extras"
			CABEC2 := cCab2+""
			cCabecRel := ""
			If !Empty(cCCDuplo)
				cCabecRel := STR0086+AllTrim(cCCDuplo)+' - '+AllTrim(NGSEEK("CTT",cCCDuplo,1,"CTT_DESC01")) //"Centro de Custo: "
			Endif
			If !Empty(cEspDuplo)
				cCabecRel += If(Empty(cCCDuplo),"",Space(10))+STR0087+AllTrim(cEspDuplo)+' - '+AllTrim(NGSEEK("ST0",cEspDuplo,1,"T0_NOME")) //"Especialidade: "
			Endif
			If !Empty(cCabecRel)
				NgSomaLi(58)
				@Li,000 Psay cCabecRel
				NgSomaLi(58)
				@Li,000 Psay __PrtThinLine()
			Endif
			For nPai := 1 To Len(aColsCab)
				NgSomaLi(58)
				If lDetalhado
					@Li,000 Psay aColsCab[nPai][1]
				Endif
				@Li,000+nX Psay aColsCab[nPai][1+nP]
				@Li,012+nX Psay aColsCab[nPai][2+nP]
				@Li,055+nX Psay PADL(aColsCab[nPai][3+nP],9)
				@Li,068+nX Psay PADL(aColsCab[nPai][4+nP],9)
				@Li,080+nX Psay PADL(aColsCab[nPai][5+nP],9)
				@Li,096+nX Psay aColsCab[nPai][6+nP] Picture '@E 999.99' +'%'
				@Li,109+nX Psay PADL(aColsCab[nPai][7+nP],9)
			Next
		ElseIf _nPaiFilho == 2
			/*/
			          1         2         3         4         5         6         7         8
			012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
			******************************************************************************************
			OS       Plano    Tarefa   Previstas   Realizadas   DiferenÁa   Porcentagem   Horas Extras
			******************************************************************************************
			XXXXXX   XXXXXX   XXXXXX   999999,99    999999,99   999999,99       999,99%      999999,99
			*/
			CABEC1 := STR0141 //"OS       Plano    Tarefa   Previstas   Realizadas   DiferenÁa   Porcentagem   Horas Extras"
			CABEC2 := ""

			cCabecRel := ""
			If !Empty(cCCDuplo)
				cCabecRel := STR0086+AllTrim(cCCDuplo)+' - '+AllTrim(NGSEEK("CTT",cCCDuplo,1,"CTT_DESC01")) //"Centro de Custo: "
			Endif
			If !Empty(cEspDuplo)
				cCabecRel += If(Empty(cCCDuplo),"",Space(10))+STR0087+AllTrim(cEspDuplo)+' - '+AllTrim(NGSEEK("ST0",cEspDuplo,1,"T0_NOME")) //"Especialidade: "
			Endif
			If !Empty(cCabecRel)
				NgSomaLi(58)
				@Li,000 Psay cCabecRel
				NgSomaLi(58)
				@Li,000 Psay __PrtThinLine()
			Endif

			cOldFunc := ""

			For nPai := 1 To Len(aColsCab)
				For nFilho := 1 to Len(aColsInfer)
					If cOldFunc != aColsCab[nPai][1]
						NgSomaLi(58)
						cCodEspec := AllTrim(NGSEEK("ST2",aColsCab[nPai][1],1,"T2_ESPECIA"))
						cDesEspec := AllTrim(NGSEEK("ST0",cCodEspec,1,"T0_NOME"))
						@Li,000 Psay STR0135 + AllTrim(aColsCab[nPai][1]) + ' - ' + AllTrim(aColsCab[nPai][2]) + Space(10) + ; //"Funcion·rio: "
										 IIF(Empty(cCabecRel),STR0087+cCodEspec+' - '+cDesEspec,"") //"Especialidade: "
						NgSomaLi(58)
						@Li,000 Psay __PrtThinLine()
						cOldFunc := aColsCab[nPai][1]
					Endif
					If aColsCab[nPai][1] == aColsInfer[nFilho][1]
						NgSomaLi(58)
						@Li,000 Psay aColsInfer[nFilho][2]
						@Li,009 Psay aColsInfer[nFilho][3]
						@Li,018 Psay aColsInfer[nFilho][4]
						@Li,027 Psay PADL(aColsInfer[nFilho][5],9)
						@Li,040 Psay PADL(aColsInfer[nFilho][6],9)
						@Li,052 Psay PADL(aColsInfer[nFilho][7],9)
						@Li,068 Psay aColsInfer[nFilho][8] Picture '@E 999.99' +'%'
						@Li,081 Psay PADL(aColsInfer[nFilho][9],9)
					Endif
				Next
				If nPai != Len(aColsCab)
					NgSomaLi(58)
				Endif
			Next
		Endif

	Endif
ElseIf cTpAnalise = "D" //Distribuicao
	/*/
	          1         2         3         4         5         6         7         8         9         0         1
	0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234
	*******************************************************************************************************************
	OS       Status        Bem                  Nome                             Dt. Prevista   H. Prevista   Realizada   %
	*******************************************************************************************************************
	XXXXXX   XXXXXXXXXXX   XXXXXXXXXXXXXXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX       99/99/99     999999,99   999999,99
	XXXXXX   XXXXXXXXXXX   XXXXXXXXXXXXXXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX       99/99/99     999999,99   999999,99
	*/
	CABEC1 := cCab1+STR0142 //"OS       Status        Bem                  Nome                             Dt. Prevista   H. Prevista   Realizada   %"
	CABEC2 := cCab2+""

	If nAcesso == 1
		For nPai := 1 To Len(aColsCab)

			If nPai != 1
				NgSomaLi(58)
			Endif

			NgSomaLi(58)
			@Li,000 Psay STR0144 + aColsCab[nPai][1+nP] //"Prioridade: "
			NgSomaLi(58)
			@Li,000 Psay __PrtThinLine()

			For nFilho := 1 to Len(aColsInfer)
				If aColsCab[nPai][1] == aColsInfer[nFilho][2] .And. (!lDetalhado .Or.;
				   (lDetalhado .And. aColsCab[nPai][2] == aColsInfer[nFilho][3]))
					NgSomaLi(58)
					If lDetalhado
						@Li,000 Psay aColsInfer[nFilho][2]
					Endif
					@Li,000+nX Psay aColsInfer[nFilho][3+nP]
					@Li,009+nX Psay aColsInfer[nFilho][4+nP]
					@Li,023+nX Psay aColsInfer[nFilho][5+nP]
					@Li,044+nX Psay Substr(aColsInfer[nFilho][6+nP],1,40)
					@Li,085+nX Psay aColsInfer[nFilho][7+nP]
					@Li,102+nX Psay PADL(aColsInfer[nFilho][8+nP],9)
					@Li,116+nX Psay PADL(aColsInfer[nFilho][9+nP],9)
					@Li,130+nX Psay aColsInfer[nFilho][10+nP] PICTURE "@E 9999.99"
				Endif
			Next

		Next
	Endif
Endif

RODA(nCNTIMPR,cRODATXT,TAMANHO)

Set Filter To
Set Device To Screen
If aReturn[5] == 1
   Set Printer To
   dbCommitAll()
   OurSpool(WNREL)
EndIf
MS_FLUSH()

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒø±±
±±≥ FunáÖo   ≥HideShowOb ≥ Autor ≥ Marcos Wagner Junior  ≥ Data ≥17/09/10 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒ¥±±
±±≥ DescriáÖo≥ Esconde/mostra os objetos						                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ MNTC400	                                                  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function HideShowOb(_oBrowsePai,_oBrowseFilho,lLoad)
Local nI, nX, nY
Default lLoad := .T.

If lLoad
	CriaBrowse(1,@oPnlBrow1,@_oBrowsePai)
	CriaBrowse(2,@oPnlBrow2,@_oBrowseFilho,@_oBrowsePai)
Else
	nAcesso--
Endif

For nI := 1 to 4
	For nY := 1 to 2
		If nI == 1
			coBrowse := IIF(nY == 1,'oBrowsDCO1','oBrowseCO1')
		ElseIf nI == 2
			coBrowse := IIF(nY == 1,'oBrowsDCE1','oBrowseCE1')
		ElseIf nI == 3
			coBrowse := IIF(nY == 1,'oBrowsDCD1','oBrowseCD1')
		ElseIf nI == 4
			coBrowse := IIF(nY == 1,'oBrowsDCU1','oBrowseCU1')
		Endif
		For nX := 1 to 3
			If ValType(&(coBrowse)) == "O"
				&(coBrowse):Hide() //Esconde o cabecalho

				coBrowse := StrTran(coBrowse,"C","R")
				&(coBrowse):Hide() //Esconde o rodape
				coBrowse := StrTran(coBrowse,"R","C")
			Endif
			coBrowse := StrTran(coBrowse,AllTrim(Str(nX)),AllTrim(Str(nX+1)))
		Next nX
	Next nY
Next nI

_oBrowsePai:Show()
_oBrowsePai:GoTop()
_oBrowsePai:Refresh()
_oBrowseFilho:Show()
_oBrowseFilho:GoTop()
_oBrowseFilho:Refresh()
oBrowsePai := _oBrowsePai
oBrowseFil := _oBrowseFilho
MudaInferior(@_oBrowsePai,@_oBrowseFilho,lLoad)

Return
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥ FunáÖo   ≥ NGSOMALI ≥ Autor ≥ In†cio Luiz Kolling   ≥ Data ≥17/09/2001≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ DescriáÖo≥ Incrementa Linha e Controla Salto de Pagina                ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ nLINP - Quantidades de linhas por p†gina                   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ GenÇrico                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function NGSOMALI(nLINP)

Li++
If Li > nLINP
   Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo,,.F.)
   Li := PROW() + 1
EndIf

Return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥Grafico400≥ Autor ≥ Marcos Wagner Junior  ≥ Data ≥15/03/10  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Graficos                                                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SIGAMNT                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function Grafico400(_nHoraCusto,_cSupouInf)
Private cTRBP400, lOpcNaoDis := .F.

If Len(aColsCab) == 1
	If ValType(aColsCab[1][1]) == "C" .and. Empty(aColsCab[1][1])
		MsgInfo(STR0176)//"N„o h· dados para geraÁ„o do gr·fico."
  		Return .F.
  	Elseif ValType(aColsCab[1][1]) == "L" .and. Empty(aColsCab[1][2])
  		MsgInfo(STR0176)//"N„o h· dados para geraÁ„o do gr·fico."
  		Return .F.
  	Endif
Endif

If _cSupouInf == 'S'
	If _nHoraCusto == 1 //"Gr·fico de Horas"
		cGrafDesc2 := STR0022 //"Gr·fico de Horas"
		If cTpAnalise = "O" //Ociosidade
			aGrafico400 := {STR0145,STR0146,STR0147} //"Produtivas"###"Improdutivas"###"DisponÌveis"
			If nAcesso == 0 //Por Centro de Custo
				CRIATRB400(_cSupouInf,'H',{3,6,10})
			ElseIf nAcesso == 1 //Por Especialidade
				CRIATRB400(_cSupouInf,'H',{4,7,11})
			ElseIf nAcesso == 2 //Por Funcionario
				If !lDetalhado
					CRIATRB400(_cSupouInf,'H',{3,5,8})
				Endif
			Endif
		ElseIf cTpAnalise == "U" //Utilizacao
			aGrafico400 := {STR0148,STR0149,STR0150} //"Preventivas"###"Corretivas"###"Total"
			If nAcesso == 0 //Por Centro de Custo
				CRIATRB400(_cSupouInf,'H',{3,6,9})
			ElseIf nAcesso == 1 //Por Especialidade
				If !lDetalhado
					CRIATRB400(_cSupouInf,'H',{5,8,11})
				Endif
			ElseIf nAcesso == 2 //Por Funcionario
				If !lDetalhado
					CRIATRB400(_cSupouInf,'H',{3,6,9})
				Endif
			Endif
		ElseIf cTpAnalise == "E" // EficiÍncia
			
			aGrafico400 := { STR0152, STR0151 } // Previstas ## Realizadas
			
			If !lDetalhado .And. (nAcesso == 0 .Or. nAcesso == 1 .Or. nAcesso == 2) //Por Centro de Custo/Especialidade/Funcionario
				CRIATRB400(_cSupouInf,'H',{3,4})
			Endif
		
		Endif
	Else //"Gr·fico de Custos"
		cGrafDesc2 := STR0153 //"Gr·fico de Custos"
		If cTpAnalise = "O" //Ociosidade
			aGrafico400 := {STR0145,STR0146} //"Produtivas"###"Improdutivas"
			If nAcesso == 0 //Por Centro de Custo
				CRIATRB400(_cSupouInf,'C',{4,7})
			ElseIf nAcesso == 1 //Por Especialidade
				CRIATRB400(_cSupouInf,'C',{5,8})
			Endif
		ElseIf cTpAnalise == "U"//Utilizacao
			aGrafico400 := {STR0148,STR0149} //"Preventivas"###"Corretivas"
			If nAcesso == 0 //Por Centro de Custo
				CRIATRB400(_cSupouInf,'C',{4,7})
			ElseIf nAcesso == 1 //Por Especialidade
				If !lDetalhado
					CRIATRB400(_cSupouInf,'C',{6,9})
				Endif
			ElseIf nAcesso == 2 //Por Funcionario
				If !lDetalhado
					CRIATRB400(_cSupouInf,'C',{4,7})
				Endif
			Endif
		Endif
	Endif
ElseIf _cSupouInf == 'I'
	If _nHoraCusto == 1 //"Gr·fico de Horas"
		cGrafDesc2 := STR0022 //"Gr·fico de Horas"
		If cTpAnalise = "O" //Ociosidade
			aGrafico400 := {STR0145,STR0146,STR0147} //"Produtivas"###"Improdutivas"###"DisponÌveis"
			If nAcesso == 0 //Por Centro de Custo
				CRIATRB400(_cSupouInf,'H',{4,7,11})
			ElseIf nAcesso == 1 //Por Especialidade
				If !lDetalhado
					CRIATRB400(_cSupouInf,'H',{3,5,8})
				Endif
			Endif
		ElseIf cTpAnalise = "U" //Utilizacao
			aGrafico400 := {STR0148,STR0149,STR0150} //"Preventivas"###"Corretivas"###"Total"
			If nAcesso == 0 //Por Centro de Custo
				If !lDetalhado
					CRIATRB400(_cSupouInf,'H',{5,8,11})
				Endif
			ElseIf nAcesso == 1 //Por Especialidade
				If !lDetalhado
					CRIATRB400(_cSupouInf,'H',{3,6,9})
				Endif
			Endif
		ElseIf cTpAnalise == "E" // EficiÍncia
			
			aGrafico400 := { STR0152, STR0151 } // Previstas ## Realizadas
			
			If !lDetalhado .And. (nAcesso == 0 .Or. nAcesso == 1) // Por Centro de Custo/Especialidade
				CRIATRB400(_cSupouInf,'H',{3,4})
			Endif

		Endif
	Else //"Gr·fico de Custos"
		cGrafDesc2 := STR0153 //"Gr·fico de Custos"
		If cTpAnalise = "O" //Ociosidade
			aGrafico400 := {STR0145,STR0146} //"Produtivas"###"Improdutivas"
			If nAcesso == 0 //Por Centro de Custo
				CRIATRB400(_cSupouInf,'C',{5,8})
			Endif
		ElseIf cTpAnalise == "U" //Utilizacao
			aGrafico400 := {STR0148,STR0149} //"Preventivas"###"Corretivas"
			If nAcesso == 0 //Por Centro de Custo
				If !lDetalhado
					CRIATRB400(_cSupouInf,'C',{6,9})
				Endif
			ElseIf nAcesso == 1 //Por Especialidade
				If !lDetalhado
					CRIATRB400(_cSupouInf,'C',{4,7})
				Endif
			Endif
		Endif
	Endif
Endif

If !lOpcNaoDis
	MsgInfo(STR0116,STR0117) //"OpÁ„o n„o disponÌvel!"###"AtenÁ„o"
Endif

Return .T.

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥CRIATRB400≥ Autor ≥ Marcos Wagner Junior  ≥ Data ≥15/03/10  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Graficos                                                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SIGAMNT                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function CRIATRB400(_cSupouInf,_cHouC,_aPosCols)
Local nI := 0
Local cLegendaGr := ''
Local aIdx400 := {}
Private aVetInr := {}
Private oTmpTRB400

lOpcNaoDis := .t.
If Len(aColsCab) == 1
	If ValType(aColsCab[1][1]) == "C" .and. Empty(aColsCab[1][1])
		MsgInfo(STR0176)//"N„o h· dados para geraÁ„o do gr·fico."
  		Return .F.
  	Elseif ValType(aColsCab[1][1]) == "L" .and. Empty(aColsCab[1][2])
  		MsgInfo(STR0176)//"N„o h· dados para geraÁ„o do gr·fico."
  		Return .F.
  	Endif
Endif
aDBF400 := {{"CODIGO" ,"C",If(lDetalhado,08,20), 0 },;
			{"DESCRI" ,"C",20, 0 },;
            {"VALOR1" ,"N",12, 2 },;
            {"VALOR2" ,"N",12, 2 }}

If Len(_aPosCols) = 3
	aADD(aDBF400,{"VALOR3" ,"N",12, 2 })
Endif

cTRBP400   := GetNextAlias()
aIdx400    := {{"CODIGO"}}
oTmpTRB400 := NGFwTmpTbl(cTRBP400,aDBF400,aIdx400)

If lDetalhado
	If _cSupouInf = 'S'
		cLegendaGr := AllTrim(aColsCab[oBrowsePai:nAt][2]) + ' - ' + AllTrim(aColsCab[oBrowsePai:nAt][3])
		If (cTpAnalise == "U" .And. nAcesso == 1)
			cChavePai := aColsCab[oBrowsePai:nAt][2]+aColsCab[oBrowsePai:nAt][5]
		Else
			cChavePai := aColsCab[oBrowsePai:nAt][2]
		Endif
		For nI := 1 to Len(aColsCab)
			If (cTpAnalise+AllTrim(Str(nAcesso)) == "U1" .And. cChavePai == aColsCab[nI][2]+aColsCab[nI][5]) .Or.;
				(cTpAnalise+AllTrim(Str(nAcesso)) != "U1" .And. cChavePai == aColsCab[nI][2])
				RecLock(cTRBP400,.T.)
				(cTRBP400)->CODIGO  := aColsCab[nI][1]
				(cTRBP400)->DESCRI  := MESEXTENSO(SubStr(aColsCab[nI][1],1,2)) + ' de ' + SubStr(aColsCab[nI][1],4,4)
			  	(cTRBP400)->VALOR1  := IIF(ValType(aColsCab[nI][_aPosCols[1]+nP])=='C',SomaHoras( aColsCab[nI][_aPosCols[1]+nP],0 ),aColsCab[nI][_aPosCols[1]+nP]) //Produtivas
			  	(cTRBP400)->VALOR2  := IIF(ValType(aColsCab[nI][_aPosCols[2]+nP])=='C',SomaHoras( aColsCab[nI][_aPosCols[2]+nP],0 ),aColsCab[nI][_aPosCols[2]+nP]) //Improdutivas
			  	If Len(_aPosCols) = 3
				  	(cTRBP400)->VALOR3  := IIF(ValType(aColsCab[nI][_aPosCols[3]+nP])=='C',SomaHoras( aColsCab[nI][_aPosCols[3]+nP],0 ),aColsCab[nI][_aPosCols[3]+nP]) //Disponiveis
				Endif
				(cTRBP400)->(MsUnLock())
			Endif
		Next
	ElseIf _cSupouInf = 'I'
		cLegendaGr := AllTrim(aColsRod[oBrowseFil:nAt][2]) + ' - ' + AllTrim(aColsRod[oBrowseFil:nAt][3])
		If (cTpAnalise == "U" .And. nAcesso == 1)
			cChaveFil := aColsRod[oBrowseFil:nAt][2]+aColsRod[oBrowseFil:nAt][5]
		Else
			cChaveFil := aColsRod[oBrowseFil:nAt][2]
		Endif

		For nI := 1 to Len(aColsRod)
			If (cTpAnalise+AllTrim(Str(nAcesso)) == "U1" .And. cChaveFil == aColsRod[nI][2]+aColsRod[nI][5]) .Or.; //xxx
				(cTpAnalise+AllTrim(Str(nAcesso)) != "U1" .And. cChaveFil == aColsRod[nI][2]) //xxx
				RecLock(cTRBP400,.T.)
				(cTRBP400)->CODIGO  := aColsRod[nI][1]
				(cTRBP400)->DESCRI  := MESEXTENSO(SubStr(aColsRod[nI][1],1,2)) + ' de ' + SubStr(aColsRod[nI][1],4,4)
			  	(cTRBP400)->VALOR1  := IIF(ValType(aColsRod[nI][_aPosCols[1]+nP])=='C',SomaHoras( aColsRod[nI][_aPosCols[1]+nP],0 ),aColsRod[nI][_aPosCols[1]+nP]) //Produtivas
			  	(cTRBP400)->VALOR2  := IIF(ValType(aColsRod[nI][_aPosCols[2]+nP])=='C',SomaHoras( aColsRod[nI][_aPosCols[2]+nP],0 ),aColsRod[nI][_aPosCols[2]+nP]) //Improdutivas
			  	If Len(_aPosCols) = 3
				  	(cTRBP400)->VALOR3  := IIF(ValType(aColsRod[nI][_aPosCols[3]+nP])=='C',SomaHoras( aColsRod[nI][_aPosCols[3]+nP],0 ),aColsRod[nI][_aPosCols[3]+nP]) //Disponiveis
				Endif
				(cTRBP400)->(MsUnLock())
			Endif
		Next
	Endif
Else
	If _cSupouInf = 'S'
		For nI := 1 to Len(aColsCab)
			RecLock((cTRBP400),.T.)
			(cTRBP400)->CODIGO  := aColsCab[nI][1]
			(cTRBP400)->DESCRI  := aColsCab[nI][2]
		  	(cTRBP400)->VALOR1  := IIF( ValType( aColsCab[nI][_aPosCols[1]] ) == 'C',SomaHoras( aColsCab[nI][_aPosCols[1]],0 ),aColsCab[nI][_aPosCols[1]] ) //Produtivas
		  	(cTRBP400)->VALOR2  := IIF( ValType( aColsCab[nI][_aPosCols[2]] ) == 'C',SomaHoras( aColsCab[nI][_aPosCols[2]],0 ),aColsCab[nI][_aPosCols[2]] ) //Improdutivas
		  	If Len(_aPosCols) = 3
			  	(cTRBP400)->VALOR3  := IIF(ValType(aColsCab[nI][_aPosCols[3]])=='C',SomaHoras( aColsCab[nI][_aPosCols[3]],0 ),aColsCab[nI][_aPosCols[3]]) //Disponiveis
			Endif
			(cTRBP400)->(MsUnLock())
		Next
	ElseIf _cSupouInf = 'I'
		For nI := 1 to Len(aColsRod)
			RecLock(cTRBP400,.T.)
			(cTRBP400)->CODIGO  := aColsRod[nI][1]
			(cTRBP400)->DESCRI  := aColsRod[nI][2]
		  	(cTRBP400)->VALOR1  := IIF(ValType(aColsRod[nI][_aPosCols[1]])=='C',SomaHoras( aColsRod[nI][_aPosCols[1]],0 ),aColsRod[nI][_aPosCols[1]]) //Produtivas
		  	(cTRBP400)->VALOR2  := IIF(ValType(aColsRod[nI][_aPosCols[2]])=='C',SomaHoras( aColsRod[nI][_aPosCols[2]],0 ),aColsRod[nI][_aPosCols[2]]) //Improdutivas
		  	If Len(_aPosCols) = 3
			  	(cTRBP400)->VALOR3  := IIF(ValType(aColsRod[nI][_aPosCols[3]])=='C',SomaHoras( aColsRod[nI][_aPosCols[3]],0 ),aColsRod[nI][_aPosCols[3]]) //Disponiveis
			Endif
			(cTRBP400)->(MsUnLock())
		Next
	Endif
Endif

dbSelectArea(cTRBP400)
dbGoTop()

vCRIGTXT := NGGRAFICO(" "+cGrafDesc1,;
                      " ",;
                      " ",;
                      cGrafDesc2,;
                      cLegendaGr,;
                      aGrafico400,;
                      "A",;
                      cTRBP400)

//Deleta o arquivo temporario fisicamente
oTmpTRB400:Delete()

Return


//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC400PER
Graficos
@author Marcos Wagner Junior
@since	15/03/10
/*/
//---------------------------------------------------------------------

Static Function MNTC400PER(_dDataIni,_dDataFim)
Local nPeriodo := 0
Local nI := 0
Local nAnoInicio, nAnoFim, nForMes, cMesAno
Local aPeriodoOS := {}

//Quebra os periodos por Mes/Ano
If lDetalhado
	nAnoInicio := Year(_dDataIni)
	nAnoFim := Year(_dDataFim)
	While nAnoInicio <= nAnoFim
		If nAnoInicio == nAnoFim
			nForMes := Month(_dDataFim)
		Else
			nForMes := 12
		Endif

		For nI := Month(_dDataIni) to nForMes
			cMesAno := StrZero(nI,2)+'/'+AllTrim(Str(nAnoInicio))
			If aSCAN(aMesAno,{|x| x == cMesAno }) == 0
				AADD(aMesAno,cMesAno)
			Endif
			AADD(aPeriodoOS,cMesAno)
		Next
		nAnoInicio += 1
	End
	nPeriodo := Len(aPeriodoOS)
	aPerAcols := aClone(aPeriodoOS)
Else
	nPeriodo := 1
Endif

Return nPeriodo

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥VoltaNivel≥ Autor ≥ Marcos Wagner Junior  ≥ Data ≥07/07/10  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Volta nivel do aHeader e aCols                             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SIGAMNT                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function VoltaNivel()
lVoltaNivel := .F.
lDuploClick := .F.

If nAcesso <= nAcessoGC //.And. nAcesso != 0
	MsgInfo(STR0172,STR0117) //"N„o existe um nÌvel anterior a esse!"###"AtenÁ„o"
ElseIf nAcesso >= 1
	lVoltaNivel := .T.
	aColsCab   := aClone(aOldCols[nAcesso][1])
	aColsInfer := aClone(aOldCols[nAcesso][3])

	aHeader1 := aClone(aOldHeader[nAcesso][1])
	aHeader2 := aClone(aOldHeader[nAcesso][2])

	cDescMDO   := aOldCols[4][nAcesso]

	oCabSup1:cTitle := aOldCols[5][nAcesso]
	oCabSup2:cTitle := aOldCols[6][nAcesso]
	oCabInf1:cTitle := aOldCols[7][nAcesso]
	oCabInf2:cTitle := aOldCols[8][nAcesso]

	ChangeObj(.F.)
Endif

Return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ChangeObj ≥ Autor ≥ Marcos Wagner Junior  ≥ Data ≥07/07/10  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Volta nivel do aHeader e aCols                             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SIGAMNT                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function ChangeObj(lLoad)
Default lLoad := .T.

If cTpAnalise = "O"
	If nAcesso == 1
		If lLoad
			oBtnHoras1:Show()
			oBtnCusto1:Show()
			oBtnHoras2:Show()
			oBtnCusto2:Hide()
		Else
			oBtnHoras1:Show()
			oBtnCusto1:Show()
			oBtnHoras2:Show()
			oBtnCusto2:Show()
		Endif
		If cPerCons == 'U'
			If lLoad
				HideShowOb(@oBrowseCO2,@oBrowseRO2,lLoad)
			Else
				HideShowOb(@oBrowseCO1,@oBrowseRO1,lLoad)
			Endif
		Else
			If lLoad
				oBtnHoras2:Hide()
				HideShowOb(@oBrowsDCO2,@oBrowsDRO2,lLoad)
			Else
				HideShowOb(@oBrowsDCO1,@oBrowsDRO1,lLoad)
			Endif
		Endif
	ElseIf nAcesso == 2
		If lLoad
			oBtnHoras1:Show()
			oBtnCusto1:Hide()
			oBtnHoras2:Hide()
			oBtnCusto2:Hide()
		Else
			oBtnHoras1:Show()
			oBtnCusto1:Show()
			oBtnHoras2:Show()
			oBtnCusto2:Hide()
		Endif
		If cPerCons == 'U'
			If lLoad
				HideShowOb(@oBrowseCO3,@oBrowseRO3,lLoad)
			Else
				HideShowOb(@oBrowseCO2,@oBrowseRO2,lLoad)
			Endif
		Else
			If lLoad
				oBtnHoras1:Hide()
				HideShowOb(@oBrowsDCO3,@oBrowsDRO3,lLoad)
			Else
				oBtnHoras2:Hide()
				HideShowOb(@oBrowsDCO2,@oBrowsDRO2,lLoad)
			Endif
		Endif
	Endif
ElseIf cTpAnalise = "E"
	If nAcesso == 1
		oBtnHoras1:Show()
		oBtnCusto1:Hide()
		oBtnHoras2:Show()
		oBtnCusto2:Hide()
		If cPerCons == 'U'
			If lLoad
				HideShowOb(@oBrowseCE2,@oBrowseRE2,lLoad)
			Else
				HideShowOb(@oBrowseCE1,@oBrowseRE1,lLoad)
			Endif
		Else
			oBtnHoras1:Hide()
			oBtnHoras2:Hide()
			If lLoad
				HideShowOb(@oBrowsDCE2,@oBrowsDRE2,lLoad)
			Else
				HideShowOb(@oBrowsDCE1,@oBrowsDRE1,lLoad)
			Endif
		Endif
	ElseIf nAcesso == 2
		If lLoad
			oBtnHoras1:Show()
			oBtnCusto1:Hide()
			oBtnHoras2:Hide()
			oBtnCusto2:Hide()
		Else
			oBtnHoras1:Show()
			oBtnCusto1:Hide()
			oBtnHoras2:Show()
			oBtnCusto2:Hide()
		Endif
		If cPerCons == 'U'
			If lLoad
				HideShowOb(@oBrowseCE3,@oBrowseRE3,lLoad)
			Else
				HideShowOb(@oBrowseCE2,@oBrowseRE2,lLoad)
			Endif
		Else
			oBtnHoras1:Hide()
			oBtnHoras2:Hide()
			If lLoad
				HideShowOb(@oBrowsDCE3,@oBrowsDRE3,lLoad)
			Else
				HideShowOb(@oBrowsDCE2,@oBrowsDRE2,lLoad)
			Endif
		Endif
	Endif
ElseIf cTpAnalise = "D"
	oBtnHoras1:Hide()
	oBtnCusto1:Hide()
	oBtnHoras2:Hide()
	oBtnCusto2:Hide()
	If nAcesso == 1
		oBtnRela1:Show()
		oBtnRela2:Hide()
		If cPerCons == 'U'
			If lLoad
				HideShowOb(@oBrowseCD2,@oBrowseRD2,lLoad)
			Else
				HideShowOb(@oBrowseCD1,@oBrowseRD1,lLoad)
			Endif
		Else
			If lLoad
				HideShowOb(@oBrowsDCD2,@oBrowsDRD2,lLoad)
			Else
				HideShowOb(@oBrowsDCD1,@oBrowsDRD1,lLoad)
			Endif
		Endif
	ElseIf nAcesso == 2
		oBtnRela1:Hide()
		oBtnRela2:Hide()
		If cPerCons == 'U'
			If lLoad
				HideShowOb(@oBrowseCD3,@oBrowseRD3,lLoad)
			Else
				HideShowOb(@oBrowseCD2,@oBrowseRD2,lLoad)
			Endif
		Else
			If lLoad
				HideShowOb(@oBrowsDCD3,@oBrowsDRD3,lLoad)
			Else
				HideShowOb(@oBrowsDCD2,@oBrowsDRD2,lLoad)
			Endif
		Endif
	Endif
	If !lLoad
		oBtnRela1:Show()
	Endif
ElseIf cTpAnalise = "U"
	If nAcesso == 1
		oBtnHoras1:Show()
		oBtnCusto1:Show()
		oBtnHoras2:Show()
		oBtnCusto2:Show()
		If cPerCons == 'U'
			If lLoad
				HideShowOb(@oBrowseCU2,@oBrowseRU2,lLoad)
			Else
				HideShowOb(@oBrowseCU1,@oBrowseRU1,lLoad)
			Endif
		Else
			oBtnHoras1:Hide()
			oBtnCusto1:Hide()
			oBtnHoras2:Hide()
			oBtnCusto2:Hide()
			If lLoad
				HideShowOb(@oBrowsDCU2,@oBrowsDRU2,lLoad)
			Else
				oBtnHoras1:Show()
				oBtnCusto1:Show()
				oBtnHoras2:Hide()
				oBtnCusto2:Hide()
				HideShowOb(@oBrowsDCU1,@oBrowsDRU1,lLoad)
			Endif
		Endif
	ElseIf nAcesso == 2
		If lLoad
			oBtnHoras1:Show()
			oBtnCusto1:Show()
			oBtnHoras2:Hide()
			oBtnCusto2:Hide()
		Else
			oBtnHoras1:Show()
			oBtnCusto1:Show()
			oBtnHoras2:Show()
			oBtnCusto2:Show()
		Endif
		If cPerCons == 'U'
			If lLoad
				HideShowOb(@oBrowseCU3,@oBrowseRU3,lLoad)
			Else
				HideShowOb(@oBrowseCU2,@oBrowseRU2,lLoad)
			Endif
		Else
			oBtnHoras1:Hide()
			oBtnCusto1:Hide()
			oBtnHoras2:Hide()
			oBtnCusto2:Hide()
			If lLoad
				HideShowOb(@oBrowsDCU3,@oBrowsDRU3,lLoad)
			Else
				HideShowOb(@oBrowsDCU2,@oBrowsDRU2,lLoad)
			Endif
		Endif
	Endif
Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC400LEG
Filtra para a legenda

@author Marcos Wagner Junior
@since	15/03/10
/*/
//---------------------------------------------------------------------
Function MNTC400LEG()

BrwLegenda(STR0169,STR0164,{{"BR_VERMELHO",STR0170},; //"Status da OS"###"Legenda"###"Impedida"
												  {"BR_VERDE",STR0171}}) //"DistribuÌda"

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} QuerySTLEs
Query STL 
EficiÍncia por especialidade / EficiÍncia por centro de custo

@param _nPar, numerico, tipo de eficiencia: 5 por especialidade, 6 por CC
@author Marcos Wagner Junior
@since	19/02/2009
/*/
//---------------------------------------------------------------------
Static Function QuerySTLEs(_nPar)

	Local nI := 0
	Local nPeriodo := 0
	Local nTLQUANTID := 0

	Private nHrExtras  := 0
	Private nRealizada := 0
	Private nPrevista  := 0
	Private cCodCCusto := ""
	Private aPerAcols := {}

	cAliasQry := GetNextAlias()
	cQuery := " SELECT STL.TL_QUANTID, STL.TL_PLANO, STL.TL_ORDEM,  "
	cQuery += "        STL.TL_SEQRELA, STL.TL_PLANO, STL.TL_DTINICI, STL.TL_DTFIM, STL.TL_TIPOHOR, STL.TL_CODIGO, STL.TL_HOINICI, STL.TL_HOFIM "
	If lPcthrex
		cQuery += " ,STL.TL_PCTHREX "
	Else
		cQuery += " ,STL.TL_HREXTRA "
	Endif
	cQuery += " FROM " + RetSqlName("STL") +" STL, " + RetSqlName("STJ") +" STJ "
	cQuery += " WHERE STL.TL_TIPOREG = 'E' "
	cQuery +=   " AND STJ.TJ_SITUACA = 'L' "
	cQuery +=   " AND ( STL.TL_DTINICI BETWEEN " + ValToSQL(dTpAnaliDe) + " AND " + ValToSQL(dTpAnaliAte)
	cQuery +=      " OR STL.TL_DTFIM BETWEEN "   + ValToSQL(dTpAnaliDe) + " AND " + ValToSQL(dTpAnaliAte) + " ) "
	If NGSX2MODO("STJ") == NGSX2MODO("STL")
		cQuery += " AND STJ.TJ_FILIAL = STL.TL_FILIAL "
	Else
		cQuery += " AND STJ.TJ_FILIAL = " + ValToSQL(xFilial("STJ"))
		cQuery += " AND STL.TL_FILIAL = " + ValToSQL(xFilial("STL"))
	EndIf
	cQuery += " AND STJ.TJ_ORDEM = STL.TL_ORDEM "
	cQuery += " AND STJ.TJ_PLANO = STL.TL_PLANO "
	If cVisualiz == "E"
		If Upper(_cGetDB) $ 'ORACLE,DB2,POSTGRES,INFORMIX'
			cQuery += " AND SUBSTR(STL.TL_CODIGO,1,3) >= " + ValToSQL(cVisualiDe)
			cQuery += " AND SUBSTR(STL.TL_CODIGO,1,3) <= " + ValToSQL(cVisualiAte)
		Else
			cQuery += " AND SUBSTRING(STL.TL_CODIGO,1,3) >= " + ValToSQL(cVisualiDe)
			cQuery += " AND SUBSTRING(STL.TL_CODIGO,1,3) <= " + ValToSQL(cVisualiAte)
		Endif
	Endif
	cQuery += " AND STJ.D_E_L_E_T_ <> '*' "
	cQuery += " AND STL.D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	dbGoTop()

	While !Eof()
		dTL_DTINICI := STOD((cAliasQry)->TL_DTINICI)
		dTL_DTFIM   := STOD((cAliasQry)->TL_DTFIM)
		nTLQUANTID := 0

		aRetDtHr := PulaData(dTL_DTINICI,(cAliasQry)->TL_HOINICI,dTL_DTFIM,(cAliasQry)->TL_HOFIM,;
									"",'N',(cAliasQry)->TL_QUANTID,(cAliasQry)->TL_TIPOHOR )
		If Len(aRetDtHr) == 0
			dbSelectArea(cAliasQry)
			dbSkip()
			Loop
		Else
			dTL_DTINICI := aRetDtHr[1][1]
			dTL_DTFIM   := aRetDtHr[1][2]
			nTLQUANTID  := aRetDtHr[1][3]
		Endif

		cCodEspec := SubStr((cAliasQry)->TL_CODIGO,1,3)
		cDesEspec := NGSEEK("ST0",cCodEspec,1,"T0_NOME")

		cT1_CCUSTO := ""
		cDesCCusto := ""
		If _nPar == 5
			cAliasCC := GetNextAlias()
			cQueryCC := " SELECT ST1.T1_CCUSTO "
			cQueryCC += " FROM " + RetSqlName("ST1") + " ST1, " + RetSqlName("ST2") + " ST2 "
			cQueryCC += " WHERE ST2.T2_ESPECIA = '"+cCodEspec+"'"
			If NGSX2MODO("ST1") == NGSX2MODO("ST2")
				cQueryCC += " AND ST1.T1_FILIAL = ST2.T2_FILIAL "
			Else
				cQueryCC += " AND ST1.T1_FILIAL = '"+xFilial("ST1")+"'"
				cQueryCC += " AND ST2.T2_FILIAL = '"+xFilial("ST2")+"'"
			EndIf
			cQueryCC += " AND   ST1.T1_CODFUNC = ST2.T2_CODFUNC "
			cQueryCC += " AND   ST1.D_E_L_E_T_ <> '*' "
			cQueryCC += " AND   ST2.D_E_L_E_T_ <> '*' "
			cQueryCC += " ORDER BY ST1.T1_CCUSTO "
			cQueryCC := ChangeQuery(cQueryCC)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryCC),cAliasCC, .F., .T.)
			If !Eof()
				cT1_CCUSTO := (cAliasCC)->T1_CCUSTO
				cDesCCusto := NGSEEK("CTT",cT1_CCUSTO,1,"CTT_DESC01")
				(cAliasCC)->(dbCloseArea())
			Else
				(cAliasCC)->(dbCloseArea())
				dbSelectArea(cAliasQry)
				dbSkip()
				Loop
			Endif
		Endif

		nHrExtras := 0
		nRealizada := 0
		nPrevista  := 0
		If lPcthrex .And. !Empty((cAliasQry)->TL_PCTHREX)
			nHrExtras := nTLQUANTID
		ElseIf !lPcthrex .And. (cAliasQry)->TL_HREXTRA != '000.00' .And. !Empty((cAliasQry)->TL_HREXTRA)
			nHrExtras := nTLQUANTID
		Endif

		If (cAliasQry)->TL_SEQRELA == '0  '
			nPrevista  := nTLQUANTID
		Else
			nRealizada := nTLQUANTID
		Endif

		nPeriodo := MNTC400PER(dTL_DTINICI,dTL_DTFIM)

		For nI := 1 to nPeriodo
			If !lDuploClick
				If _nPar == 5 //Eficiencia x Centro de Custo
					If !lDetalhado
						nPos := aSCAN(aColsCab,{|x| x[1] == cT1_CCUSTO })
						If nPos == 0
							aAdd(aColsCab,{cT1_CCUSTO,cDesCCusto,nPrevista,nRealizada,0,0,nHrExtras})
						Else
							aColsCab[nPos][3] := somahoras(aColsCab[nPos][3],nPrevista)
							aColsCab[nPos][4] := somahoras(aColsCab[nPos][4],nRealizada)
							aColsCab[nPos][7] := somahoras(aColsCab[nPos][7],nHrExtras)
						Endif
					Else
						nPos := aSCAN(aColsCab,{|x| x[1]+x[2] == aPerAcols[nI]+cT1_CCUSTO })
						If nPos == 0
							aAdd(aColsCab,{aPerAcols[nI],cT1_CCUSTO,cDesCCusto,nPrevista,nRealizada,0,0,nHrExtras})
						Else
							aColsCab[nPos][4] := somahoras(aColsCab[nPos][4],nPrevista)
							aColsCab[nPos][5] := somahoras(aColsCab[nPos][5],nRealizada)
							aColsCab[nPos][8] := somahoras(aColsCab[nPos][8],nHrExtras)
						Endif
					Endif
				ElseIf _nPar == 6 //Eficiencia x Especialidade
					If !lDetalhado
						nPos := aSCAN(aColsCab,{|x| x[1] == cCodEspec })
						If nPos == 0
							aAdd(aColsCab,{cCodEspec,cDesEspec,nPrevista,nRealizada,0,0,nHrExtras})
						Else
							aColsCab[nPos][3] := somahoras(aColsCab[nPos][3],nPrevista)
							aColsCab[nPos][4] := somahoras(aColsCab[nPos][4],nRealizada)
							aColsCab[nPos][7] := somahoras(aColsCab[nPos][7],nHrExtras)
						Endif
					Else
						nPos := aSCAN(aColsCab,{|x| x[1]+x[2] == aPerAcols[nI]+cCodEspec })
						If nPos == 0
							aAdd(aColsCab,{aPerAcols[nI],cCodEspec,cDesEspec,nPrevista,nRealizada,0,0,nHrExtras})
						Else
							aColsCab[nPos][4] := somahoras(aColsCab[nPos][4],nPrevista)
							aColsCab[nPos][5] := somahoras(aColsCab[nPos][5],nRealizada)
							aColsCab[nPos][8] := somahoras(aColsCab[nPos][8],nHrExtras)
						Endif
					Endif
				Endif
			Endif
			//Segunda GetDados
			CarregaRod(_nPar,cCodEspec,"",STR0159,cT1_CCUSTO,nTLQUANTID,; //"N„o h· registro para essa especialidade"
						1,"",(cAliasQry)->TL_ORDEM,If(lPcthrex,(cAliasQry)->TL_PCTHREX,(cAliasQry)->TL_HREXTRA),;
						'STL',If(Len(aPerAcols)>0,aPerAcols[nI],Nil))
		Next

		nTotProd1 := somahoras(nTotProd1,nTLQUANTID)

		dbSelectArea(cAliasQry)
		dbSkip()
	End
	(cAliasQry)->(dbCloseArea())

	QuerySTTEs(_nPar)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} PulaData
Busca a quantidade de horas trabalhadas no periodo selecionado.

@author Marcos Wagner Junior
@since	22/07/2010
/*/
//---------------------------------------------------------------------
Static Function PulaData( _dtInsINI,_cHoInsINI,_dtInsFIM,_cHoInsFIM,_cCalend,_cUsaCale,_nQuanti,_cTipHora )

	Local aRet := {}
	Local nQtDecimal := _nQuanti

	Default _cUsaCale := 'N'

	If _dtInsFIM < dTpAnaliDe .Or. _dtInsINI > dTpAnaliAte
		Return aRet //vai dar um dbSkip()
	Endif

	dDtAuxINI := _dtInsINI
	cHrAuxINI := _cHoInsINI
	dDtAuxFIM := _dtInsFIM
	cHrAuxFIM := _cHoInsFIM
	If _dtInsINI < dTpAnaliDe
		dDtAuxINI := dTpAnaliDe
		cHrAuxINI := '00:00'
	Endif
	If _dtInsFIM > dTpAnaliAte
		dDtAuxFIM := dTpAnaliAte//aqui
		cHrAuxFIM := '24:00'
	Endif

	If _cTipHora == "S"
		_nQuanti := NGQUANTIHOR( 'M', 'H', dDtAuxINI, cHrAuxINI, dDtAuxFIM, cHrAuxFIM, _cUsaCale, _cCalend, 'S' )
		nQtDecimal := Hton( _nQuanti )
	Else

		If _cUsaCale == "S"
			nQtDecimal := NGQUANTIHOR( 'M', 'H', dDtAuxINI, cHrAuxINI, dDtAuxFIM, cHrAuxFIM, _cUsaCale, _cCalend, 'D' )		
		Else
			nQtDecimal := NGCALCH100( dDtAuxINI,cHrAuxINI,dDtAuxFIM,cHrAuxFIM )		
		EndIf
		
		_nQuanti   := NGCONVERHORA( nQtDecimal,'D','S' )	

	EndIf

	AADD( aRet, { dDtAuxINI, dDtAuxFIM, _nQuanti, nQtDecimal })

Return aRet

//---------------------------------------------------------------------
/*/{Protheus.doc} TurnoFlut
Trata a questao de turno flutuante para Horas Disponiveis

@author Marcos Wagner Junior
@since	15/03/10
/*/
//---------------------------------------------------------------------
Static Function TurnoFlut()

	Local nI
	Local nPOS      := 0 
	Local aOldArea  := GetArea()
	Local _nQuanti  := 0
	Local nPeriodo  := 0
	Local dDtIniPAR :=  CtoD( '  /  /  ' )
	Local dDtFimPAR :=  CtoD( '  /  /  ' )
	Local nValueInt := SuperGetMv( 'MV_PRECISA', .F., 4 ) // Parametro de Intervalo do Calendario
	Local cUniData  := AllTrim( SuperGetMv( 'MV_NGUNIDT', .F., 'S' ) )
	Local cAliasTP  := GetNextAlias()

	dbSelectArea("ST2")
	dbSetOrder(1)
	dbSeek(xFilial("ST2")+ST1->T1_CODFUNC)
	
	If (cDescMDO != 'OxCC' .And. aSCAN(aFunxHras,{|x| x[1] == ST1->T1_CODFUNC }) <> 0) .Or.;
		(cDescMDO == 'OxCC' .And. aSCAN(aFunxHras,{|x| x[1]+x[2] == ST1->T1_CCUSTO+ST2->T2_ESPECIA }) <> 0) .Or.;
		Empty(ST1->T1_EQUIPE)
		Return
	Endif

	BeginSQL Alias cAliasTP
		column	TP6_DTINI as Date
		column	TP6_DTFIM as Date
		SELECT  TP6.TP6_DTINI, 
				TP6.TP6_DTFIM, 
				TP6.TP6_CALEND 
		FROM %Table:TP4% TP4
			INNER JOIN %Table:TP6% TP6
				ON ( TP6.TP6_FILIAL = %xFilial:TP6% AND TP6.TP6_EQUIPE = TP4.TP4_CODIGO AND TP6.%NotDel% )
		WHERE TP4.TP4_FILIAL = %xFilial:TP4%
		  AND TP4.TP4_CODIGO = %exp:ST1->T1_EQUIPE%
		  AND TP4.%NotDel%

	EndSQL

	Do While (cAliasTP)->( !EoF() )

		nPeriodo := MNTC400PER((cAliasTP)->TP6_DTINI,(cAliasTP)->TP6_DTFIM)
		For nI := 1 To nPeriodo

			If nPeriodo == 1
				dDtIniPAR := (cAliasTP)->TP6_DTINI
				dDtFimPAR := (cAliasTP)->TP6_DTFIM
			Else
				If nI == 1
					dDtIniPAR := (cAliasTP)->TP6_DTINI
				Else
					dDtIniPAR := CTOD('01/'+aPerAcols[nI])
				Endif
				If nI != nPeriodo
					dDtFimPAR := LastDay(dDtIniPAR)
				Else
					dDtFimPAR := (cAliasTP)->TP6_DTFIM
				Endif
			Endif

			_nQuanti := NGCALEHDIS( (cAliasTP)->TP6_CALEND, dDtIniPAR, dDtFimPAR, 'N', nValueInt, cUniData )
			aRetDtHr := PulaData(dDtIniPAR,'00:00',dDtFimPAR,'24:00',(cAliasTP)->TP6_CALEND,'S',_nQuanti)//aqui
			If Len(aRetDtHr) == 0
				(cAliasTP)->( dbSkip() )
				Loop
			Else
				dTL_DTINICI := aRetDtHr[1][1]
				dTL_DTFIM   := aRetDtHr[1][2]
				nTLQUANTID  := aRetDtHr[1][3]
			Endif

			If cDescMDO == 'OxCC'
				If lDetalhado
					nPOS := aSCAN(aFunxHras,{|x| x[1]+x[2]+x[4] == ST1->T1_CCUSTO+ST2->T2_ESPECIA+aPerAcols[nI] })
					If nPOS == 0
						aAdd(aFunxHras,{ST1->T1_CCUSTO,ST2->T2_ESPECIA,nTLQUANTID,aPerAcols[nI]})
					Else
						aFunxHras[nPOS][3] := SomaHoras( aFunxHras[nPOS][3],nTLQUANTID )
					Endif
				Else
					nPOS := aSCAN(aFunxHras,{|x| x[1]+x[2] == ST1->T1_CCUSTO+ST2->T2_ESPECIA })
					If nPOS == 0
						aAdd(aFunxHras,{ST1->T1_CCUSTO,ST2->T2_ESPECIA,nTLQUANTID})
					Else
						aFunxHras[nPOS][3] := SomaHoras( aFunxHras[nPOS][3],nTLQUANTID )
					Endif
				Endif
			Else
				If lDetalhado
					nPOS := aSCAN(aFunxHras,{|x| x[1]+x[3] == ST1->T1_CODFUNC+aPerAcols[nI] })
					If nPOS == 0
						aAdd(aFunxHras,{ST1->T1_CODFUNC,nTLQUANTID,aPerAcols[nI],ST2->T2_ESPECIA,ST1->T1_CCUSTO})
					Else
						aFunxHras[nPOS][2] := SomaHoras( aFunxHras[nPOS][2],nTLQUANTID )
					Endif
				Else
					nPOS := aSCAN(aFunxHras,{|x| x[1] == ST1->T1_CODFUNC })
					If nPOS == 0
						aAdd(aFunxHras,{ST1->T1_CODFUNC,nTLQUANTID})
					Else
						aFunxHras[nPOS][2] := SomaHoras( aFunxHras[nPOS][2],nTLQUANTID )
					Endif
				Endif
			Endif

		Next
		
		(cAliasTP)->( dbSkip() )
	EndDo
	
	(cAliasTP)->( dbCloseArea() )

	RestArea(aOldArea)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} CheckEsp
Busca a quantidade de horas trabalhadas no periodo selecionado.

@author Marcos Wagner Junior
@since	22/07/2010
@return aColsRet
/*/
//---------------------------------------------------------------------
Function CheckEsp()
Local aCCxEsp := {}
Local nPOS := 0

dbSelectArea("ST1")
dbSetOrder(01)
dbGoTop()
While !Eof()
	dbSelectArea("ST2")
	dbSetOrder(01)
	If dbSeek(xFilial("ST2")+ST1->T1_CODFUNC)
		nPOS := aSCAN(aCCxEsp,{|x| x[1] == ST2->T2_ESPECIA })
		If nPOS == 0
			aAdd(aCCxEsp,{ST2->T2_ESPECIA,ST1->T1_CCUSTO})
		Else
			If aCCxEsp[nPOS][2] != ST1->T1_CCUSTO
				MsgInfo(STR0158,STR0117) //"As especialidades cadastradas est„o vinculadas a mais de um Centro de Custo, portanto, esta consulta pode apresentar inconsistÍncias"###"AtenÁ„o"
				Return .T.
			Endif
		Endif
	Endif
	dbSelectArea("ST1")
	dbSkip()
End

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} QuerySTTEs
Query STT

@author Marcos Wagner Junior
@since	19/02/2009
@return aColsRet
/*/
//---------------------------------------------------------------------
Static Function QuerySTTEs(_nPar)
	Local nI := 0
	Local nPeriodo := 0
	Local nTTQUANTID := 0
	Private nHrExtras  := 0
	Private nRealizada := 0
	Private nPrevista  := 0
	Private cCodCCusto := ""
	Private aPerAcols := {}

	cAliasQry := GetNextAlias()
	cQuery := " SELECT STT.TT_QUANTID, STT.TT_PLANO, STT.TT_ORDEM,  "
	cQuery += "        STT.TT_SEQRELA, STT.TT_PLANO, STT.TT_DTINICI, STT.TT_DTFIM, STT.TT_TIPOHOR, STT.TT_CODIGO, STT.TT_HOINICI, STT.TT_HOFIM "
	If lPcthrex
		cQuery += " ,STT.TT_PCTHREX "
	Else
		cQuery += " ,STT.TT_HREXTRA "
	Endif
	cQuery += " FROM " + RetSqlName("STT") +" STT, " + RetSqlName("STS") +" STS "
	cQuery += " WHERE STT.TT_TIPOREG = 'E' "
	cQuery += " AND STS.TS_SITUACA = 'L' "

	cQuery += " AND ( STT.TT_DTINICI BETWEEN " + ValToSQL(dTpAnaliDe) + " AND " + ValToSQL(dTpAnaliAte)
	cQuery +=    " OR STT.TT_DTFIM BETWEEN "   + ValToSQL(dTpAnaliDe) + " AND " + ValToSQL(dTpAnaliAte) + " ) "

	If NGSX2MODO("STS") == NGSX2MODO("STT")
		cQuery += " AND STS.TS_FILIAL = STT.TT_FILIAL "
	Else
		cQuery += " AND STS.TS_FILIAL = " + ValToSQL(xFilial("STS"))
		cQuery += " AND STT.TT_FILIAL = " + ValToSQL(xFilial("STT"))
	EndIf
	cQuery += " AND STS.TS_ORDEM = STT.TT_ORDEM "
	cQuery += " AND STS.TS_PLANO = STT.TT_PLANO "
	If cVisualiz == "E"
		If Upper(_cGetDB) $ 'ORACLE,DB2,POSTGRES,INFORMIX'
			cQuery += " AND SUBSTR(STT.TT_CODIGO,1,3) >= " + ValToSQL(cVisualiDe)
			cQuery += " AND SUBSTR(STT.TT_CODIGO,1,3) <= " + ValToSQL(cVisualiAte)
		Else
			cQuery += " AND SUBSTRING(STT.TT_CODIGO,1,3) >= " + ValToSQL(cVisualiDe)
			cQuery += " AND SUBSTRING(STT.TT_CODIGO,1,3) <= " + ValToSQL(cVisualiAte)
		Endif
	Endif
	cQuery += " AND STS.D_E_L_E_T_ <> '*' "
	cQuery += " AND STT.D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	dbGoTop()

	While !Eof()
		dTT_DTINICI := STOD((cAliasQry)->TT_DTINICI)
		dTT_DTFIM   := STOD((cAliasQry)->TT_DTFIM)
		nTTQUANTID := 0

		aRetDtHr := PulaData(dTT_DTINICI,(cAliasQry)->TT_HOINICI,dTT_DTFIM,(cAliasQry)->TT_HOFIM,;
									"",'N',(cAliasQry)->TT_QUANTID,(cAliasQry)->TT_TIPOHOR )
		If Len(aRetDtHr) == 0
			dbSelectArea(cAliasQry)
			dbSkip()
			Loop
		Else
			dTT_DTINICI := aRetDtHr[1][1]
			dTT_DTFIM   := aRetDtHr[1][2]
			nTTQUANTID  := aRetDtHr[1][3]
		Endif

		cCodEspec := SubStr((cAliasQry)->TT_CODIGO,1,3)
		cDesEspec := NGSEEK("ST0",cCodEspec,1,"T0_NOME")

		cT1_CCUSTO := ""
		cDesCCusto := ""
		If _nPar == 5
			cAliasCC := GetNextAlias()
			cQueryCC := " SELECT ST1.T1_CCUSTO "
			cQueryCC += " FROM " + RetSqlName("ST1") + " ST1, " + RetSqlName("ST2") + " ST2 "
			cQueryCC += " WHERE ST2.T2_ESPECIA = '"+cCodEspec+"'"
			If NGSX2MODO("ST1") == NGSX2MODO("ST2")
				cQueryCC += " AND ST1.T1_FILIAL = ST2.T2_FILIAL "
			Else
				cQueryCC += " AND ST1.T1_FILIAL = '"+xFilial("ST1")+"'"
				cQueryCC += " AND ST2.T2_FILIAL = '"+xFilial("ST2")+"'"
			EndIf
			cQueryCC += " AND   ST1.T1_CODFUNC = ST2.T2_CODFUNC "
			cQueryCC += " AND   ST1.D_E_L_E_T_ <> '*' "
			cQueryCC += " AND   ST2.D_E_L_E_T_ <> '*' "
			cQueryCC += " ORDER BY ST1.T1_CCUSTO "
			cQueryCC := ChangeQuery(cQueryCC)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryCC),cAliasCC, .F., .T.)
			If !Eof()
				cT1_CCUSTO := (cAliasCC)->T1_CCUSTO
				cDesCCusto := NGSEEK("CTT",cT1_CCUSTO,1,"CTT_DESC01")
				(cAliasCC)->(dbCloseArea())
			Else
				(cAliasCC)->(dbCloseArea())
				dbSelectArea(cAliasQry)
				dbSkip()
				Loop
			Endif
		Endif

		nHrExtras := 0
		nRealizada := 0
		nPrevista  := 0
		If lPcthrex .And. !Empty((cAliasQry)->TT_PCTHREX)
			nHrExtras := nTTQUANTID
		ElseIf !lPcthrex .And. (cAliasQry)->TT_HREXTRA != '000.00' .And. !Empty((cAliasQry)->TT_HREXTRA)
			nHrExtras := nTTQUANTID
		Endif

		If (cAliasQry)->TT_SEQRELA == '0  '
			nPrevista  := nTTQUANTID
		Else
			nRealizada := nTTQUANTID
		Endif

		nPeriodo := MNTC400PER(dTT_DTINICI,dTT_DTFIM)

		For nI := 1 to nPeriodo
			If !lDuploClick
				If _nPar == 5 //Eficiencia x Centro de Custo
					If !lDetalhado
						nPos := aSCAN(aColsCab,{|x| x[1] == cT1_CCUSTO })
						If nPos == 0
							aAdd(aColsCab,{cT1_CCUSTO,cDesCCusto,nPrevista,nRealizada,0,0,nHrExtras})
						Else
							aColsCab[nPos][3] := somahoras(aColsCab[nPos][3],nPrevista)
							aColsCab[nPos][4] := somahoras(aColsCab[nPos][4],nRealizada)
							aColsCab[nPos][7] := somahoras(aColsCab[nPos][7],nHrExtras)
						Endif
					Else
						nPos := aSCAN(aColsCab,{|x| x[1]+x[2] == aPerAcols[nI]+cT1_CCUSTO })
						If nPos == 0
							aAdd(aColsCab,{aPerAcols[nI],cT1_CCUSTO,cDesCCusto,nPrevista,nRealizada,0,0,nHrExtras})
						Else
							aColsCab[nPos][4] := somahoras(aColsCab[nPos][4],nPrevista)
							aColsCab[nPos][5] := somahoras(aColsCab[nPos][5],nRealizada)
							aColsCab[nPos][8] := somahoras(aColsCab[nPos][8],nHrExtras)
						Endif
					Endif
				ElseIf _nPar == 6 //Eficiencia x Especialidade
					If !lDetalhado
						nPos := aSCAN(aColsCab,{|x| x[1] == cCodEspec })
						If nPos == 0
							aAdd(aColsCab,{cCodEspec,cDesEspec,nPrevista,nRealizada,0,0,nHrExtras})
						Else
							aColsCab[nPos][3] := somahoras(aColsCab[nPos][3],nPrevista)
							aColsCab[nPos][4] := somahoras(aColsCab[nPos][4],nRealizada)
							aColsCab[nPos][7] := somahoras(aColsCab[nPos][7],nHrExtras)
						Endif
					Else
						nPos := aSCAN(aColsCab,{|x| x[1]+x[2] == aPerAcols[nI]+cCodEspec })
						If nPos == 0
							aAdd(aColsCab,{aPerAcols[nI],cCodEspec,cDesEspec,nPrevista,nRealizada,0,0,nHrExtras})
						Else
							aColsCab[nPos][4] := somahoras(aColsCab[nPos][4],nPrevista)
							aColsCab[nPos][5] := somahoras(aColsCab[nPos][5],nRealizada)
							aColsCab[nPos][8] := somahoras(aColsCab[nPos][8],nHrExtras)
						Endif
					Endif
				Endif
			Endif
			//Segunda GetDados
			CarregaRod(_nPar,cCodEspec,"",STR0159,cT1_CCUSTO,nTTQUANTID,; //"N„o h· registro para essa especialidade"
						1,"",(cAliasQry)->TT_ORDEM,If(lPcthrex,(cAliasQry)->TT_PCTHREX,(cAliasQry)->TT_HREXTRA),;
						'STT',If(Len(aPerAcols)>0,aPerAcols[nI],Nil))
		Next

		nTotProd1 := somahoras(nTotProd1,nTTQUANTID)

		dbSelectArea(cAliasQry)
		dbSkip()
	End
	(cAliasQry)->(dbCloseArea())

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} QuerySTT
Query STT

@author Jackson Machado
@since	19/02/2009
@return aColsRet
/*/
//---------------------------------------------------------------------
Static Function QuerySTT(_nPar)

	Local dTT_DTINICI, dTT_DTFIM
	Local nCorretiva := 0
	Local nPreventiv := 0
	Local nI := 0
	Local nPeriodo := 0
	Local nTTQUANTID := 0

	Private nHrExtras  := 0
	Private nRealizada := 0
	Private nPrevista  := 0
	Private nCustoMSta := 0
	Private aPerAcols := {}
	Private cCodCCusto := ""
	Private cT1_CCUSTO := ""

	cAliasQry := GetNextAlias()
	cQuery := " SELECT ST1.T1_CCUSTO, STT.TT_QUANTID, CTT.CTT_DESC01, ST1.T1_CODFUNC, ST1.T1_TURNO, "
	cQuery += "        ST1.T1_NOME, ST1.T1_SALARIO, STT.TT_PLANO, STT.TT_ORDEM, STT.TT_SEQRELA, "
	cQuery += "        STT.TT_TAREFA, STT.TT_PLANO, STT.TT_DTINICI, STT.TT_HOINICI, STT.TT_DTFIM, STT.TT_HOFIM,
	cQuery += "        STT.TT_TIPOHOR, STT.TT_USACALE "

	If lPcthrex
		cQuery += " ,STT.TT_PCTHREX "
	Else
		cQuery += " ,STT.TT_HREXTRA "
	Endif

	cQuery += " FROM " + RetSqlName("STT") +" STT, " + RetSqlName("ST1") +" ST1, " + RetSqlName("CTT") +" CTT, " + RetSqlName("STS") +" STS "
	If NGSX2MODO("STT") == NGSX2MODO("ST1")
		cQuery += " WHERE STT.TT_FILIAL = ST1.T1_FILIAL "
	Else
		cQuery += " WHERE STT.TT_FILIAL = " + ValToSQL(xFilial("STT"))
		cQuery += " AND ST1.T1_FILIAL = " + ValToSQL(xFilial("ST1"))
	EndIf

	cQuery += " AND STT.TT_TIPOREG = 'M' "

	cQuery += " AND ( STT.TT_DTINICI BETWEEN " + ValToSQL(dTpAnaliDe) + " AND " + ValToSQL(dTpAnaliAte)
	cQuery +=    " OR STT.TT_DTFIM BETWEEN "   + ValToSQL(dTpAnaliDe) + " AND " + ValToSQL(dTpAnaliAte) + " ) "

	If NGSX2MODO("STS") == NGSX2MODO("STT")
		cQuery += " AND STS.TS_FILIAL = STT.TT_FILIAL "
	Else
		cQuery += " AND STS.TS_FILIAL = " + ValToSQL(xFilial("STS"))
		cQuery += " AND STT.TT_FILIAL = " + ValToSQL(xFilial("STT"))
	EndIf

	cQuery += " AND STS.TS_ORDEM = STT.TT_ORDEM "
	cQuery += " AND STS.TS_PLANO = STT.TT_PLANO "
	cQuery += " AND STS.TS_SITUACA = 'L' "

	cQuery += " AND ST1.T1_FILIAL = " + ValToSQL(xFilial("ST1"))
	cQuery += " AND CTT.CTT_FILIAL = " + ValToSQL(xFilial("CTT"))

	cQuery += " AND ST1.T1_CCUSTO = CTT.CTT_CUSTO "
		If (cTpAnalise != 'U' .And. cVisualiz == "C") .Or. (cVisualiz == "F") //Na utilizacao por CC, ele filtrara o CC da Ordem
		If cTpAnalise <> 'D'
			If cVisualiz == "C"
				cQuery += " AND ST1.T1_CCUSTO >= " + ValToSQL(cVisualiDe)
				cQuery += " AND ST1.T1_CCUSTO <= " + ValToSQL(cVisualiAte)
			ElseIf cVisualiz == "F"
				cQuery += " AND ST1.T1_CODFUNC >= " + ValToSQL(cVisualiDe)
				cQuery += " AND ST1.T1_CODFUNC <= " + ValToSQL(cVisualiAte)
			EndIf
		Endif
	Endif

	If Upper(_cGetDB) $ 'ORACLE,DB2,POSTGRES,INFORMIX'
		cQuery += " AND SUBSTR(STT.TT_CODIGO,1,6) = ST1.T1_CODFUNC "
	Else
		cQuery += " AND SUBSTRING(STT.TT_CODIGO,1,6) = ST1.T1_CODFUNC "
	Endif

		If cTpAnalise == 'U' .Or. cTpAnalise == 'O'
		cQuery += " AND STT.TT_SEQRELA <> '0  ' "
	Endif

	cQuery += " AND CTT.D_E_L_E_T_ <> '*' "
	cQuery += " AND ST1.D_E_L_E_T_ <> '*' "
	cQuery += " AND STT.D_E_L_E_T_ <> '*' "
	cQuery += " AND STS.D_E_L_E_T_ <> '*' "

	If cVisualiz == 'C'
		cQuery += " ORDER BY ST1.T1_CCUSTO "
	Endif

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	dbGoTop()

	While !Eof()

		dTT_DTINICI := STOD((cAliasQry)->TT_DTINICI)
		dTT_DTFIM   := STOD((cAliasQry)->TT_DTFIM)
		aRetDtHr := PulaData(dTT_DTINICI,(cAliasQry)->TT_HOINICI,dTT_DTFIM,(cAliasQry)->TT_HOFIM,(cAliasQry)->T1_TURNO,(cAliasQry)->TT_USACALE,(cAliasQry)->TT_QUANTID,(cAliasQry)->TT_TIPOHOR )
		If Len(aRetDtHr) == 0
			dbSelectArea(cAliasQry)
			dbSkip()
			Loop
		Else
			dTT_DTINICI := aRetDtHr[1][1]
			dTT_DTFIM   := aRetDtHr[1][2]
			nTTQUANTID  := aRetDtHr[1][3]
		Endif

		dbSelectArea("ST2")
		dbSetOrder(1)
		If dbSeek(xFilial("ST2")+(cAliasQry)->T1_CODFUNC)
			cCodEspec := ST2->T2_ESPECIA
			cDesEspec := NGSEEK("ST0",cCodEspec,1,"T0_NOME")
		Else
			cCodEspec := Space(Len(ST2->T2_ESPECIA)) //Tratamento para quando o funcionario nao tiver especialidade
			cDesEspec := STR0165 //"N„o possui especialidade"
		Endif

			If cTpAnalise <> 'D' .And. cVisualiz == "E"
				If ST2->T2_ESPECIA < cVisualiDe .Or. ST2->T2_ESPECIA > cVisualiAte
				dbSelectArea(cAliasQry)
				dbSkip()
				Loop
			Endif
		Endif

		If (cAliasQry)->TT_PLANO == '000000'
				lCorretiva := .T.
			nCorretiva := nTTQUANTID
			nPreventiv := 0
		Else
				lCorretiva := .F.
			nPreventiv := nTTQUANTID
			nCorretiva := 0
		Endif

		nHrExtras := 0
		nRealizada := 0
		nPrevista  := 0

			If lPcthrex .And. !Empty((cAliasQry)->TT_PCTHREX)
			nHrExtras := nTTQUANTID
			ElseIf !lPcthrex .And. (cAliasQry)->TT_HREXTRA != '000.00' .And. !Empty((cAliasQry)->TT_HREXTRA)
			nHrExtras := nTTQUANTID
		Endif

		If (cAliasQry)->TT_SEQRELA == '0  '
			nPrevista  := nTTQUANTID
		Else
			nRealizada := nTTQUANTID
		Endif

		dbSelectArea("ST1")
		dbSetOrder(1)
		dbSeek(xFilial("ST1")+(cAliasQry)->T1_CODFUNC)
		If cTpCusto == 'S'
			nCustoMSta  :=  ST1->T1_SALARIO //Valor (Custo Medio ou Standard)
		Else
			dbSelectArea("SB2")
			dbSetOrder(1)
			If dbSeek(xFilial("SB2")+'MOD'+AllTrim(ST1->T1_CCUSTO))
				nCustoMSta := SB2->B2_CM1 //Valor (Custo Medio ou Standard)
			Else
				nCustoMSta := 0
			Endif
		Endif

		//Buscar CC da OS
		cCodCCusto := NGSEEK("STS",(cAliasQry)->TT_ORDEM,1,"TS_CCUSTO")
		If Empty(cCodCCusto)
			cDesCCusto := STR0157 //"OS n„o possui Centro de Custo"
		Else
			cDesCCusto := NGSEEK("CTT",cCodCCusto,1,"CTT_DESC01")
		Endif

			If cTpAnalise == 'U' .And. cVisualiz == "C"
				If cCodCCusto < cVisualiDe .Or. cCodCCusto > cVisualiAte
				dbSelectArea(cAliasQry)
				dbSkip()
				Loop
			Endif
		Endif

		nPeriodo := MNTC400PER(dTT_DTINICI,dTT_DTFIM)
		cT1_CCUSTO := (cAliasQry)->T1_CCUSTO

		For nI := 1 to nPeriodo
			If !lDuploClick
			//Primeira GetDados
				If _nPar == 1
					If !lDetalhado
						nPos := aSCAN(aColsCab,{|x| x[1] == cT1_CCUSTO })
						If nPos == 0
							aAdd(aColsCab,{cT1_CCUSTO,(cAliasQry)->CTT_DESC01,nTTQUANTID,0,0,0,0,0,0,0,0})
						Else
							aColsCab[nPos][3] := SomaHoras( aColsCab[nPos][3],nTTQUANTID )
						Endif
					Else //Detalhado
						nPos := aSCAN(aColsCab,{|x| x[1]+x[2] == aPerAcols[nI]+cT1_CCUSTO })
						If nPos == 0
							aAdd(aColsCab,{aPerAcols[nI],cT1_CCUSTO,(cAliasQry)->CTT_DESC01,nTTQUANTID,0,0,0,0,0,0,0,0})
						Else
							aColsCab[nPos][4] := somahoras(aColsCab[nPos][4],nTTQUANTID)
						Endif
					Endif
				ElseIf _nPar == 2
					If !lDetalhado
						nPos := aSCAN(aColsCab,{|x| x[1] == cCodEspec })
						If nPos == 0
							aAdd(aColsCab,{cCodEspec,cDesEspec,0,nTTQUANTID,0,0,0,0,0,0,0,0})
						Else
							aColsCab[nPos][4] := somahoras(aColsCab[nPos][4],nTTQUANTID)
						Endif
					Else
						nPos := aSCAN(aColsCab,{|x| x[1]+x[2] == aPerAcols[nI]+cCodEspec })
						If nPos == 0
							aAdd(aColsCab,{aPerAcols[nI],cCodEspec,cDesEspec,0,nTTQUANTID,0,0,0,0,0,0,0,0})
						Else
							aColsCab[nPos][5] := SomaHoras( aColsCab[nPos][5],nTTQUANTID )
						Endif
					Endif
				ElseIf _nPar == 3
					If !lDetalhado
						nPos := aSCAN(aColsCab,{|x| x[1] == cCodCCusto })
						If nPos == 0
							aAdd(aColsCab,{cCodCCusto,cDesCCusto,nPreventiv,0,0,nCorretiva,0,0,0})
						Else
							aColsCab[nPos][3] := somahoras(aColsCab[nPos][3],nPreventiv)
							aColsCab[nPos][6] := somahoras(aColsCab[nPos][6],nCorretiva)
						Endif
					Else
						nPos := aSCAN(aColsCab,{|x| x[1]+x[2] == aPerAcols[nI]+cCodCCusto })
						If nPos == 0
							aAdd(aColsCab,{aPerAcols[nI],cCodCCusto,cDesCCusto,nPreventiv,0,0,nCorretiva,0,0,0})
						Else
							aColsCab[nPos][4] := somahoras(aColsCab[nPos][4],nPreventiv)
							aColsCab[nPos][7] := somahoras(aColsCab[nPos][7],nCorretiva)
						Endif
					Endif
				ElseIf _nPar == 4
					If !lDetalhado
						nPos := aSCAN(aColsCab,{|x| x[1]+x[4] == cCodEspec+cT1_CCUSTO })
						If nPos == 0
							aAdd(aColsCab,{cCodEspec,cDesEspec,0,cT1_CCUSTO,nPreventiv,0,0,nCorretiva,0,0,0})
						Else
							aColsCab[nPos][5] := somahoras(aColsCab[nPos][5],nPreventiv)
							aColsCab[nPos][8] := somahoras(aColsCab[nPos][8],nCorretiva)
						Endif
					Else
						nPos := aSCAN(aColsCab,{|x| x[1]+x[2]+x[5] == aPerAcols[nI]+cCodEspec+cT1_CCUSTO })
						If nPos == 0
							aAdd(aColsCab,{aPerAcols[nI],cCodEspec,cDesEspec,0,cT1_CCUSTO,nPreventiv,0,0,nCorretiva,0,0,0})
						Else
							aColsCab[nPos][6] := somahoras(aColsCab[nPos][6],nPreventiv)
							aColsCab[nPos][9] := somahoras(aColsCab[nPos][9],nCorretiva)
						Endif
					Endif
				ElseIf _nPar == 5 //Eficiencia x Centro de Custo
					If !lDetalhado
						nPos := aSCAN(aColsCab,{|x| x[1] == cT1_CCUSTO })
						If nPos == 0
							aAdd(aColsCab,{cT1_CCUSTO,(cAliasQry)->CTT_DESC01,nPrevista,nRealizada,0,0,nHrExtras})
						Else
							aColsCab[nPos][3] := somahoras(aColsCab[nPos][3],nPrevista)
							aColsCab[nPos][4] := somahoras(aColsCab[nPos][4],nRealizada)
							aColsCab[nPos][7] := somahoras(aColsCab[nPos][7],nHrExtras)
						Endif
					Else
						nPos := aSCAN(aColsCab,{|x| x[1]+x[2] == aPerAcols[nI]+cT1_CCUSTO })
						If nPos == 0
							aAdd(aColsCab,{aPerAcols[nI],cT1_CCUSTO,(cAliasQry)->CTT_DESC01,nPrevista,nRealizada,0,0,nHrExtras})
						Else
							aColsCab[nPos][4] := somahoras(aColsCab[nPos][4],nPrevista)
							aColsCab[nPos][5] := somahoras(aColsCab[nPos][5],nRealizada)
							aColsCab[nPos][8] := somahoras(aColsCab[nPos][8],nHrExtras)
						Endif
					Endif
				ElseIf _nPar == 6 //Eficiencia x Especialidade
					If !lDetalhado
						nPos := aSCAN(aColsCab,{|x| x[1] == cCodEspec })
						If nPos == 0
							aAdd(aColsCab,{cCodEspec,cDesEspec,nPrevista,nRealizada,0,0,nHrExtras})
						Else
							aColsCab[nPos][3] := somahoras(aColsCab[nPos][3],nPrevista)
							aColsCab[nPos][4] := somahoras(aColsCab[nPos][4],nRealizada)
							aColsCab[nPos][7] := somahoras(aColsCab[nPos][7],nHrExtras)
						Endif
					Else
						nPos := aSCAN(aColsCab,{|x| x[1]+x[2] == aPerAcols[nI]+cCodEspec })
						If nPos == 0
							aAdd(aColsCab,{aPerAcols[nI],cCodEspec,cDesEspec,nPrevista,nRealizada,0,0,nHrExtras})
						Else
							aColsCab[nPos][4] := somahoras(aColsCab[nPos][4],nPrevista)
							aColsCab[nPos][5] := somahoras(aColsCab[nPos][5],nRealizada)
							aColsCab[nPos][8] := somahoras(aColsCab[nPos][8],nHrExtras)
						Endif
					Endif
				ElseIf _nPar == 7 //Utilizacao x Funcionario
					nCustoPrev := nPreventiv * nCustoMSta
					nCustoCorr := nCorretiva * nCustoMSta
					nTotalHora := nPreventiv + nCorretiva
					If !lDetalhado
						nPos := aSCAN(aColsCab,{|x| x[1] == (cAliasQry)->T1_CODFUNC })
						If nPos == 0
							aAdd(aColsCab,{(cAliasQry)->T1_CODFUNC,(cAliasQry)->T1_NOME,nPreventiv,nCustoPrev,0,nCorretiva,nCustoCorr,0,nTotalHora})
						Else
							aColsCab[nPos][3] += nPreventiv
							aColsCab[nPos][4] += nCustoPrev
							aColsCab[nPos][6] += nCorretiva
							aColsCab[nPos][7] += nCustoCorr
							aColsCab[nPos][9] := somahoras(aColsCab[nPos][9],nTotalHora)
						Endif
					Else
						nPos := aSCAN(aColsCab,{|x| x[1]+x[2] == aPerAcols[nI]+(cAliasQry)->T1_CODFUNC })
						If nPos == 0
							aAdd(aColsCab,{aPerAcols[nI],(cAliasQry)->T1_CODFUNC,(cAliasQry)->T1_NOME,nPreventiv,nCustoPrev,0,nCorretiva,nCustoCorr,0,nTotalHora})
						Else
							aColsCab[nPos][4] += nPreventiv
							aColsCab[nPos][5] += nCustoPrev
							aColsCab[nPos][7] += nCorretiva
							aColsCab[nPos][8] += nCustoCorr
							aColsCab[nPos][10] := somahoras(aColsCab[nPos][10],nTotalHora)
						Endif
					Endif
				ElseIf _nPar == 9 //Ociosidade x Funcionario
					If !lDetalhado
						nPos := aSCAN(aColsCab,{|x| x[1] == (cAliasQry)->T1_CODFUNC })
						If nPos == 0
							aAdd(aColsCab,{(cAliasQry)->T1_CODFUNC,(cAliasQry)->T1_NOME,nTTQUANTID,0,0,0,0,0,0,(cAliasQry)->T1_TURNO})
						Else
							aColsCab[nPos][3] := SomaHoras( aColsCab[nPos][3],nTTQUANTID )
						Endif
					Else
						nPos := aSCAN(aColsCab,{|x| x[1]+x[2] == aPerAcols[nI]+(cAliasQry)->T1_CODFUNC })
						If nPos == 0
							aAdd(aColsCab,{aPerAcols[nI],(cAliasQry)->T1_CODFUNC,(cAliasQry)->T1_NOME,nTTQUANTID,0,0,0,0,0,0,(cAliasQry)->T1_TURNO})
						Else
							aColsCab[nPos][4] := somahoras(aColsCab[nPos][4],nTTQUANTID)
						Endif
					Endif
				Endif
			Else
					If _nPar == 7 .And. !Empty(cCCDuplo) //Pegar o CC da STS
					cT1_CCUSTO := cCodCCusto
				Endif
			Endif

			//Segunda GetDados
			CarregaRod(_nPar,cCodEspec,(cAliasQry)->T1_CODFUNC,(cAliasQry)->T1_NOME,cT1_CCUSTO,nTTQUANTID,;
						1,cCodCCusto,(cAliasQry)->TT_ORDEM,If(lPcthrex,(cAliasQry)->TT_PCTHREX,(cAliasQry)->TT_HREXTRA),;
						'STT',If(Len(aPerAcols)>0,aPerAcols[nI],Nil))
		Next

		If _nPar == 8 //Eficiencia x Funcionario
			For nI := 1 to nPeriodo
				If !lDuploClick
					If !lDetalhado
						nPos := aSCAN(aColsCab,{|x| x[1] == (cAliasQry)->T1_CODFUNC })
						If nPos == 0
							aAdd(aColsCab,{(cAliasQry)->T1_CODFUNC,(cAliasQry)->T1_NOME,nPrevista,nRealizada,0,0,nHrExtras})
						Else
							aColsCab[nPos][3] := somahoras(aColsCab[nPos][3],nPrevista)
							aColsCab[nPos][4] := somahoras(aColsCab[nPos][4],nRealizada)
							aColsCab[nPos][7] := somahoras(aColsCab[nPos][7],nHrExtras)
						Endif
					Else
						nPos := aSCAN(aColsCab,{|x| x[1]+x[2] == aPerAcols[nI]+(cAliasQry)->T1_CODFUNC })
						If nPos == 0
							aAdd(aColsCab,{aPerAcols[nI],(cAliasQry)->T1_CODFUNC,(cAliasQry)->T1_NOME,nPrevista,nRealizada,0,0,nHrExtras})
						Else
							aColsCab[nPos][4] := somahoras(aColsCab[nPos][4],nPrevista)
							aColsCab[nPos][5] := somahoras(aColsCab[nPos][5],nRealizada)
							aColsCab[nPos][8] := somahoras(aColsCab[nPos][8],nHrExtras)
						Endif
					Endif
				Endif

					If !lDuploClick .Or. (lDuploClick .And. cT1_CCUSTO == cCCDuplo .And. cCodEspec == cEspDuplo)
					If !lDetalhado
						nPos := aSCAN(aColsInfer,{|x| x[1]+x[2]+x[3]+x[4] == (cAliasQry)->T1_CODFUNC+(cAliasQry)->TT_ORDEM+(cAliasQry)->TT_PLANO+(cAliasQry)->TT_TAREFA })
						If nPos == 0
							aAdd(aColsInfer,{(cAliasQry)->T1_CODFUNC,(cAliasQry)->TT_ORDEM,(cAliasQry)->TT_PLANO,(cAliasQry)->TT_TAREFA,nPrevista,nRealizada,,,nHrExtras})
						Else
							aColsInfer[nPos][5] := somahoras(aColsInfer[nPos][5],nPrevista)
							aColsInfer[nPos][6] := somahoras(aColsInfer[nPos][6],nRealizada)
							aColsInfer[nPos][9] := somahoras(aColsInfer[nPos][9],nHrExtras)
						Endif
					Else
						nPos := aSCAN(aColsInfer,{|x| x[1]+x[2]+x[3]+x[4]+x[5] == aPerAcols[nI]+(cAliasQry)->T1_CODFUNC+(cAliasQry)->TT_ORDEM+(cAliasQry)->TT_PLANO+(cAliasQry)->TT_TAREFA })
						If nPos == 0
							aAdd(aColsInfer,{aPerAcols[nI],(cAliasQry)->T1_CODFUNC,(cAliasQry)->TT_ORDEM,(cAliasQry)->TT_PLANO,(cAliasQry)->TT_TAREFA,nPrevista,nRealizada,,,nHrExtras})
						Else
							aColsInfer[nPos][6]  := somahoras(aColsInfer[nPos][6],nPrevista)
							aColsInfer[nPos][7]  := somahoras(aColsInfer[nPos][7],nRealizada)
							aColsInfer[nPos][10] := somahoras(aColsInfer[nPos][10],nHrExtras)
						Endif
					Endif
				Endif
			Next
		Endif

		nTotProd1 := somahoras(nTotProd1,nTTQUANTID)

		dbSelectArea(cAliasQry)
		dbSkip()
	End
	(cAliasQry)->(dbCloseArea())

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fBlankArray
Query TT1/TT2

@author Marcos Wagner Junior
@since	19/02/2009
/*/
//---------------------------------------------------------------------
Static Function QueryTT2(_nPar)
	Local nI := 0, nX := 0
	Local aInsumos := {}, cTipoHora := "", cTipoInsu := "", cDescInsu := ""
	Local nTTQUANTID := 0
	Private aPerAcols := {}
	Private lOK := .T.

	cAliasQry := GetNextAlias()
	cQuery := " SELECT STS.TS_ORDEM, STS.TS_PLANO, STS.TS_PRIORID, STS.TS_CODBEM, STS.TS_DTMPINI, STS.TS_HOMPINI, STS.TS_TIPOOS "
	If lRelease12
		cQuery += ", STS.TS_STFOLUP "
	Endif
	cQuery += " FROM " + RetSqlName("STS") + " STS "
	cQuery += " WHERE STS.D_E_L_E_T_ <> '*' "
	cQuery += " AND STS.TS_SITUACA = 'L' "
	If cVisualiz == 'P'
		cQuery += " AND STS.TS_PRIORID >= '"+cVisualiDe+"'"
		cQuery += " AND STS.TS_PRIORID <= '"+cVisualiAte+"'"
	ElseIf cVisualiz == 'O'
		cQuery += " AND STS.TS_ORDEM >= '"+cVisualiDe+"'"
		cQuery += " AND STS.TS_ORDEM <= '"+cVisualiAte+"'"
	Endif
	
	cQuery += " AND ( STS.TS_DTMPINI BETWEEN " + ValToSQL(dTpAnaliDe) + " AND " + ValToSQL(dTpAnaliAte)
	cQuery +=    " OR STS.TS_DTMPFIM BETWEEN " + ValToSQL(dTpAnaliDe) + " AND " + ValToSQL(dTpAnaliAte) + " ) "

	If _nPar == 2
		cQuery += " ORDER BY STS.TS_PRIORID  "
	ElseIf _nPar == 3
		cQuery += " ORDER BY STS.TS_ORDEM  "
	Endif

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	dbGoTop()

	While !Eof()
		aInsumos := {}
		If (cAliasQry)->TS_TIPOOS == 'B'
			nNomeBem := NGSEEK("ST9",(cAliasQry)->TS_CODBEM,1,"ST9->T9_NOME")
		Else
			nNomeBem := NGSEEK("TAF","X2"+Substr((cAliasQry)->TS_CODBEM,1,3),7,"SUBSTR(TAF_NOMNIV,1,30)")
		Endif

		nDistribui := 0
		nImpedidas := 1
		nHorasRea  := 0
		nHorasPre  := 0

		cAliasSTT := GetNextAlias()
		cQuerySTT := " SELECT STT.TT_QUANTID, STT.TT_SEQRELA, STT.TT_CODIGO, STT.TT_TIPOREG, STT.TT_TIPOHOR, "
		cQuerySTT += "        STT.TT_DTINICI, STT.TT_HOINICI, STT.TT_DTFIM,  STT.TT_HOFIM,   STT.TT_USACALE "
		cQuerySTT += " FROM " + RetSqlName("STT") +" STT "
		cQuerySTT += " WHERE STT.TT_ORDEM = " + ValToSQL((cAliasQry)->TS_ORDEM)
		cQuerySTT +=   " AND STT.TT_PLANO = " + ValToSQL((cAliasQry)->TS_PLANO)
		cQuerySTT +=   " AND ( STT.TT_DTINICI BETWEEN " + ValToSQL(dTpAnaliDe) + " AND " + ValToSQL(dTpAnaliAte)
		cQuerySTT +=      " OR STT.TT_DTFIM BETWEEN "   + ValToSQL(dTpAnaliDe) + " AND " + ValToSQL(dTpAnaliAte) + " ) "
		cQuerySTT +=   " AND (STT.TT_TIPOREG = 'M' OR STT.TT_TIPOREG = 'E')"
		cQuerySTT +=   " AND STT.D_E_L_E_T_ <> '*' "
		cQuerySTT := ChangeQuery(cQuerySTT)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuerySTT),cAliasSTT, .F., .T.)
		dbGoTop()
		While !Eof()

			nTTQUANTID := 0
			nT1_TURNO  := ""
			dTT_DTINICI := STOD((cAliasSTT)->TT_DTINICI)
			dTT_DTFIM   := STOD((cAliasSTT)->TT_DTFIM)

			If (cAliasSTT)->TT_USACALE == 'S' .And. (cAliasSTT)->TT_TIPOREG == 'M'
				dbSelectArea("ST1")
				dbSetOrder(01)
				If dbSeek(xFilial("ST1")+SubStr((cAliasSTT)->TT_CODIGO,1,6))
					nT1_TURNO := ST1->T1_TURNO
				Endif
			Endif

			aRetDtHr := PulaData(dTT_DTINICI,(cAliasSTT)->TT_HOINICI,dTT_DTFIM,(cAliasSTT)->TT_HOFIM,;
										nT1_TURNO,(cAliasSTT)->TT_USACALE,(cAliasSTT)->TT_QUANTID,(cAliasSTT)->TT_TIPOHOR )
			If Len(aRetDtHr) == 0
				dbSelectArea(cAliasSTT)
				dbSkip()
				Loop
			Else
				dTT_DTINICI := aRetDtHr[1][1]
				dTT_DTFIM   := aRetDtHr[1][2]
				nTTQUANTID  := aRetDtHr[1][3]
			Endif

			cTipoHora := ""
			If (cAliasSTT)->TT_SEQRELA <> '0  '
				nDistribui	:= 1
				nImpedidas	:= 0
				nHorasRea	:= SomaHoras( nHorasRea,nTTQUANTID )
				cTipoHora	:= STR0166 //"Realizado"
			Else
				nHorasPre := SomaHoras( nHorasPre,nTTQUANTID )
				cTipoHora := STR0167 //"Previsto"
			Endif

			If (cAliasSTT)->TT_TIPOREG == 'E'
				dbSelectArea('ST0')
				dbSetOrder(01)
				If dbSeek(xFilial('ST0')+SubStr((cAliasSTT)->TT_CODIGO,1,3))
					cDescInsu := ST0->T0_NOME
				Endif
			Else
				dbSelectArea("ST1")
				dbSetOrder(01)
				If dbSeek(xFilial("ST1")+SubStr((cAliasSTT)->TT_CODIGO,1,6))
					cDescInsu := ST1->T1_NOME
				Endif
			Endif
			cTipoInsu := IIF((cAliasSTT)->TT_TIPOREG == 'E',STR0010,STR0168) //"Especialidade"###"Mao de Obra"

			nPOS := aSCAN(aInsumos,{|x| x[1]+x[2]+x[3]+x[4] == (cAliasQry)->TS_ORDEM+cTipoHora+cTipoInsu+(cAliasSTT)->TT_CODIGO })
			If nPOS == 0
				aAdd(aInsumos,{(cAliasQry)->TS_ORDEM,cTipoHora,cTipoInsu,(cAliasSTT)->TT_CODIGO,cDescInsu,nTTQUANTID})
			Else
				aInsumos[nPOS][6] := SomaHoras( aInsumos[nPOS][6],nTTQUANTID )
			Endif

			dbSelectArea(cAliasSTT)
			dbSkip()
		End
		(cAliasSTT)->(dbCloseArea())

		If nImpedidas != 0
			lOK := .F.
		Else
			lOK := .T.
		Endif

		If lRelease12
			cTS_STFOLUP	:= (cAliasQry)->TS_STFOLUP
		Else
			cTS_STFOLUP	:= ""
		Endif

		nPeriodo := MNTC400PER(STOD((cAliasQry)->TS_DTMPINI),STOD((cAliasQry)->TS_DTMPINI))

		For nX := 1 to nPeriodo
			If _nPar == 2
				If !lDetalhado
					If !lDuploClick
						nPos := aSCAN(aColsCab,{|x| x[1] == (cAliasQry)->TS_PRIORID })
						If nPos == 0
							aAdd(aColsCab,{(cAliasQry)->TS_PRIORID,nImpedidas,nDistribui,1})
						Else
							aColsCab[nPos][2] += nImpedidas
							aColsCab[nPos][3] += nDistribui
							aColsCab[nPos][4] += 1
						Endif
					Endif

					If !lDuploClick .Or. (lDuploClick /*.And. nNomePlan == cPlanDuplo*/ .And. (cAliasQry)->TS_PRIORID == cPrioDuplo)
						nPos := aSCAN(aColsInfer,{|x| x[2]+x[3] == (cAliasQry)->TS_PRIORID+(cAliasQry)->TS_ORDEM })
						If nPos == 0
							aAdd(aColsInfer,{lOK,(cAliasQry)->TS_PRIORID,(cAliasQry)->TS_ORDEM,cTS_STFOLUP,(cAliasQry)->TS_CODBEM,nNomeBem,;
													STOD((cAliasQry)->TS_DTMPINI),IIF( nHorasPre == 0, NTOH( 0 ), NgTraNtoH(nHorasPre) ),IIF( nHorasRea == 0, NTOH( 0 ), NgTraNtoH(nHorasRea) ),Round(nHorasRea/nHorasPre*100,2)})
						Endif
					Endif
				Else //Detalhado
					If !lDuploClick
						nPos := aSCAN(aColsCab,{|x| x[1]+x[2] == aPerAcols[nX]+(cAliasQry)->TS_PRIORID })
						If nPos == 0
							aAdd(aColsCab,{aPerAcols[nX],(cAliasQry)->TS_PRIORID,nImpedidas,nDistribui,1})
						Else
							aColsCab[nPos][3] += nImpedidas
							aColsCab[nPos][4] += nDistribui
							aColsCab[nPos][5] += 1
						Endif
					Endif

					If !lDuploClick .Or. (lDuploClick /*.And. nNomePlan == cPlanDuplo*/ .And. (cAliasQry)->TS_PRIORID == cPrioDuplo .And. aPerAcols[nX] == cPerDuplo)
							nPos := aSCAN(aColsInfer,{|x| x[2]+x[3]+x[4] == aPerAcols[nX]+(cAliasQry)->TS_PRIORID+(cAliasQry)->TS_ORDEM })
							If nPos == 0
								aAdd(aColsInfer,{lOK,aPerAcols[nX],(cAliasQry)->TS_PRIORID,(cAliasQry)->TS_ORDEM,cTS_STFOLUP,(cAliasQry)->TS_CODBEM,nNomeBem,;
														STOD((cAliasQry)->TS_DTMPINI),IIF( nHorasPre == 0, NTOH( 0 ), NgTraNtoH(nHorasPre) ),IIF( nHorasRea == 0, NTOH( 0 ), NgTraNtoH(nHorasRea) ),Round(nHorasRea/nHorasPre*100,2)})
							Endif
					Endif
				Endif
			ElseIf _nPar == 3 //Distribuicao x OS
				If !lDetalhado
					nPos := aSCAN(aColsCab,{|x| x[2] == (cAliasQry)->TS_ORDEM })
					If nPos == 0 .Or. lDuploClick
						If !lDuploClick
							aAdd(aColsCab,{lOK,(cAliasQry)->TS_ORDEM,cTS_STFOLUP,(cAliasQry)->TS_CODBEM,nNomeBem,;
												STOD((cAliasQry)->TS_DTMPINI),IIF( nHorasPre == 0, NTOH( 0 ), NgTraNtoH(nHorasPre) ),IIF( nHorasRea == 0, NTOH( 0 ), NgTraNtoH(nHorasRea) ),Round(nHorasRea/nHorasPre*100,2)})
						Endif
						If !lDuploClick .Or. (lDuploClick .And. (cAliasQry)->TS_PRIORID == cPrioDuplo .And. (cAliasQry)->TS_ORDEM == cOrdeDuplo)
							For nI := 1 to Len(aInsumos)
								aAdd(aColsInfer,{aInsumos[nI][1],aInsumos[nI][2],aInsumos[nI][3],aInsumos[nI][4],aInsumos[nI][5],NgTraNtoH(aInsumos[nI][6]) })
							Next
						Endif
					Endif
				Else //Detalhado
					nPos := aSCAN(aColsCab,{|x| x[2]+x[3] == aPerAcols[nX]+(cAliasQry)->TS_ORDEM })
					If nPos == 0 .Or. lDuploClick
						If !lDuploClick
							aAdd(aColsCab,{lOK,aPerAcols[nX],(cAliasQry)->TS_ORDEM,cTS_STFOLUP,(cAliasQry)->TS_CODBEM,nNomeBem,;
												STOD((cAliasQry)->TS_DTMPINI),IIF( nHorasPre == 0, NTOH( 0 ), NgTraNtoH(nHorasPre) ),IIF( nHorasRea == 0, NTOH( 0 ), NgTraNtoH(nHorasRea) ),Round(nHorasRea/nHorasPre*100,2)})
						Endif
						If !lDuploClick .Or. (lDuploClick .And. (cAliasQry)->TS_PRIORID == cPrioDuplo .And. (cAliasQry)->TS_ORDEM == cOrdeDuplo .And. aPerAcols[nX] == cPerDuplo)
							For nI := 1 to Len(aInsumos)
								aAdd(aColsInfer,{aPerAcols[nX],aInsumos[nI][1],aInsumos[nI][2],aInsumos[nI][3],aInsumos[nI][4],aInsumos[nI][5],NgTraNtoH(aInsumos[nI][6]) })
							Next
						Endif
					Endif
				Endif
			Endif
		Next nX

		dbSelectArea(cAliasQry)
		dbSkip()
	End
	(cAliasQry)->(dbCloseArea())

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} NovaConsulta
FunÁ„o para geraÁ„o de uma nova consulta

@author Jackson Machado
@since	15/07/2011
@return aColsRet
/*/
//---------------------------------------------------------------------
Static Function NovaConsulta()

lValWhen := .F. //Vari·vel utilizada para abrir o when dos campos do filtro quando gerar uma nova consulta.

aColsUp := {}
aColsDown := {}

lNovaCons := .T.
oBtnHoras1:Disable()
oBtnCusto1:Disable()
oBtnHoras2:Disable()
oBtnCusto2:Disable()
oBtnRela1:Disable()
oBtnRela2:Disable()
oBtnVoltar:Disable()
oNovaCons:Disable()

oGeraCons:Enable()
oTpAnalise:Enable()
oPeriodo:Enable()
oVisualiz:Enable()
oTpCusto:Enable()
oVisualiDe:Enable()
oVisualiAte:Enable()
oTpAnaliDe:Enable()
oTpAnaliAte:Enable()

aColsUp := fBlankArray(oBrowsePai:aColumns)
aColsDown := fBlankArray(oBrowseFil:aColumns)
oBrowsePai:SetArray(aColsUp)
oBrowsePai:Refresh()
oBrowseFil:SetArray(aColsDown)
oBrowseFil:Refresh()
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fBlankArray
FunÁ„o para zerar o array

@author Jackson Machado
@since	15/07/2011
@return aColsRet
/*/
//---------------------------------------------------------------------
Static Function fBlankArray(oColumn)
Local aColsRet := {{}}
Local nX

For nX := 1 To Len(oColumn)
	If oColumn[nX]:CHEADING == "%" .or. oColumn[nX]:CHEADING == STR0029 //"Valor"
		aAdd(aColsRet[1],0)
	Elseif Empty(oColumn[nX]:CHEADING)
		aAdd(aColsRet[1],.F.)
	Else
		aAdd(aColsRet[1],"")
	Endif
Next nX

Return aColsRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTCEXCAL()
C·lculo das horas n„o disponÌveis, exceÁıes de calend·rio.

@param dTpAnaliAte --> Data "AtÈ" da Consulta.

@author Diego de Oliveira
@since  07/03/2017
@return .T.
/*/
//---------------------------------------------------------------------
Static Function MNTCEXCAL(dTpAnaliAte,nHorasDisp,cCalend,cTipoDt)

	Local dDtAtu 	 := dTpAnaliDe
	Local aDIAMAN    := {}
	Local nDISPO	 := 0
	Local nQuantDEx  := 0

	Private aARRCALE := {}

	Default cTipoDt := SuperGetMV("MV_NGUNIDT",.F.,"")

	aDIAMAN := NG_H7(cCalend)
	aAdd(aARRCALE,{cCalend,aDIAMAN})

	If Empty(aDIAMAN)
		MsgAlert(STR0211+""+ST1->T1_CODFUNC+""+STR0212+chr(13),STR0117) //"Calendario/Turno"###"n„o cadastrado"###"AtenÁ„o
	Else
		While dDTATU <= dTpAnaliAte
			If ST1->T1_DTFIMDI >= dDTATU .Or. Empty( ST1->T1_DTFIMDI ) //Se a data fim da disponibilidade do funcion·rio for maior/igual que a data atual.

				nSEM   := If( Dow(dDTATU) == 1, 7, Dow(dDTATU)-1)
				nDISPO := HtoM( aDIAMAN[nSEM][03] )

				//Tratamento da ExceÁ„o do Calendario
				If nDISPO > 0
					vHOREXC := NG_H9( dDTATU )
					If !Empty( vHOREXC )
						nQuantDEx := nDISPO - HtoM(vHOREXC[3])
						If nQuantDEx > 0
							If cTipoDt == "D"
								nHorasDisp := NGCONVERHORA(nHorasDisp,'S','D') - HtoN(MtoH(nQuantDEx))
							ElseIf cTipoDt == "S"
								nHorasDisp := nHorasDisp - HtoN(MtoH(nQuantDEx))
							Else//if == "N"
								nQuantDEx  := HtoN(MtoH(nQuantDEx))
								nHorasDisp := SubHoras(nHorasDisp,NGCONVERHORA(nQuantDEx,'D','S'))
							EndIf
						ElseIf nQuantDEx < 0
							nQuantDEx = nQuantDEx * -1
							If cTipoDt == "D"
								nHorasDisp := NGCONVERHORA(nHorasDisp,'S','D') + HtoN(MtoH(nQuantDEx))
							ElseIf cTipoDt == "S"
								nHorasDisp := nHorasDisp + HtoN(MtoH(nQuantDEx))
							Else//if == "N"
								nQuantDEx  := HtoN(MtoH(nQuantDEx))
								nHorasDisp := SomaHoras(nHorasDisp,NGCONVERHORA(nQuantDEx,'D','S'))
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			dDTATU := dDTATU + 1
		End
	EndIf

Return nHorasDisp
