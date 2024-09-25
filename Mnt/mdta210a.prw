#Include "MDTA210A.ch"
#Include "Protheus.ch"

//-- Dimensoes Area de Trabalho (Folha Relatorio)
#Define __nHeightArea__  1358.12
#Define __nWidthArea__   967.2
#Define _nPix 			 7

// Caminho completo do diretorio temporario, utilizado
// para armazenar as imagens
#Define __cDirectory__ GetTempPath()+"TNGLAUDO_"+cValToChar(ThreadId())+If(IsSrvUnix(),"/","\")

// Id do Shape Auxiliar para o funcionamento do clique
Static __nIdAux := 0

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Classe    ³TNGLAUDO   ³Autor ³ Denis                 ³ Data ³01/03/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Classe destinada a montagem da estrutura de Laudos         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTA210                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Class TNGLAUDO From TPanel

	DATA oPnlModel    AS OBJECT
	DATA oScrollMd    AS OBJECT
	DATA oBlackPnl    AS OBJECT
  	DATA oWnd         AS OBJECT
  	DATA oLayer       AS OBJECT
	DATA oScrollPp    AS OBJECT
	DATA oSayNoCpo    AS OBJECT
	DATA oBtnItem     AS OBJECT

	DATA aCpnts       AS ARRAY INIT {}
  	DATA aObjAtu      AS ARRAY INIT {}
  	DATA aShapesUt    AS ARRAY INIT {}
  	DATA aGradeSh     AS ARRAY INIT {}
	DATA oPnlProp     AS ARRAY INIT {}
	DATA oPnlProp2    AS ARRAY INIT {}
	DATA aPropCpn     AS ARRAY INIT {}
	DATA aPropOpc     AS ARRAY INIT {}

  	DATA lCreate      AS BOOLEAN INIT .F.
  	DATA lIsMoving    AS BOOLEAN	//Indica se imagem esta em movimento
  	DATA lMulti       AS BOOLEAN INIT .F.//Indica que se trata de Multi-atalho
	DATA lGetMark     AS BOOLEAN INIT .T.//Indica se deve buscar o GetMark

	DATA nHeightArea  AS FLOAT INIT 0
	DATA nWidthArea   AS FLOAT INIT 0
	DATA nIdShp       AS INTEGER INIT 0
	DATA nTipoLaudo   AS INTEGER INIT 0 //Tipo do Laudo:1=PPRA;2=PCMSO;3=L.T. Pericial;4=LTCAT;5=DIRBEN 8030;6=PGR;7=PCMAT; 8=PPR
	DATA nItemAtual   AS INTEGER INIT 0 //Numero do item selecionado
	DATA cMkLaudo     AS STRING

	Method New(oWnd) CONSTRUCTOR

	Method AbreArquivo()
	Method BoxLaudo()
	Method DefineCabec()
	Method DefineCpn(aArrAuto,lEditShape)
	Method DefineAtalho(aArrAuto,lEditShape)
	Method DefineLabel(aArrAuto,lEditShape)
	Method DefineTexto(aArrAuto,lEditShape)
	Method DefineArquivo(aArrAuto,cTipo,lEditShape)
	Method DefinePagina(aArrAuto)
	Method DefineMulti()
	Method DelLinha()
	Method EditCpo()
	Method ExportImage()
	Method fShapeCabec()
	Method ImpTexto(_cTexto)
	Method ImpTitulo(_cTit)
	Method ImpAtalho(cTitExe)
	Method LoadBg(oWnd)
	Method LoadCpn()
	Method LoadModel()
	Method LoadProp()
	Method ModToStr()
	Method NewModel(oWnd)
	Method PaintClick(nPosX,nPosY,lDfnCpo,lEditShape,lForcaMov)
	Method ResetPnl()
	Method SelectCpn(nCpnt,aArrAuto,lEditShape)
	Method SetBlackPnl(lVisible)
	Method SetIdShp()
	Method TrocaItem(nIdAt)
	Method ViewBtn()
	Method VldTexto(cTexto,TitCmp,lCpoAtalho,cBakAtal)

EndClass

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Classe    ³ New       ³Autor ³ Denis                 ³ Data ³01/03/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Metodo construtor                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTA210                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method New(oWnd) Class TNGLAUDO
	:New(0, 0, Nil, oWnd, Nil, Nil, Nil, Nil, CLR_WHITE, 0, 0, .F., .F.)

	Local oPnlObj, oScrlCenter, oPnlPaint
	Local nWidthPaint
	Local aSize   := MsAdvSize()
	Local nWidth  := If(SetMdiChild(),aSize[5] -= 03,aSize[5])
	Local nHeight := If(!(Alltrim(GetTheme()) == "FLAT") .And. !SetMdiChild(),aSize[6] - 30,aSize[6] + 10)
	Local nPontoC

	Private oScrollObj, oPnlOpc

	Self:NewModel()

	Self:Align := CONTROL_ALIGN_ALLCLIENT

	Self:oWnd        := oWnd
	Self:aShapesUt   := {}
	Self:aGradeSh    := {}
	Self:aPropCpn    := {}
	Self:aPropOpc    := {}
	Self:aObjAtu     := {}
	Self:nIdShp      := 0
	Self:lIsMoving   := .F.
	Self:lGetMark    := .T.

	If lActivate //-- Caso haja uma definição de modelo

	 	Self:nHeightArea := __nHeightArea__
		Self:nWidthArea  := __nWidthArea__

		nWidth  := If(SetMdiChild(),aSize[5] -= 03,aSize[5])
		nHeight := If(!(Alltrim(GetTheme()) == "FLAT") .And. !SetMdiChild(),aSize[6] - 30,aSize[6] + 10)

		nWidthPaint      := If( Self:nWidthArea > Self:oWnd:nWidth, Self:nWidthArea + 20, Self:oWnd:nWidth )

		// -- Painel Central
		oScrlCenter := TScrollBox():New(Self, 0, 0, 0, 0, .T., .T., .T.)//TPanel():New(0, 0, Nil, Self, Nil, Nil, Nil, Nil, CLR_WHITE, 0, 0, .F., .F.)
		oScrlCenter:Align := CONTROL_ALIGN_ALLCLIENT

		 	Self:oLayer := FWLayer():new()
			Self:oLayer:init(oScrlCenter,.F.)
			nHeightWnd := (120/Self:oWnd:nHeight)*100

			//-- Linha 01
			Self:oLayer:addLine('Lin01',100 - nHeightWnd,.F.)
			nCol1H := Int(18000/Self:oLayer:oPanel:nClientHeight)
			nCol1H := If(nCol1H<35,35,nCol1H)
			nCol2H := 93-nCol1H

				Self:oLayer:addCollumn('Col01',73,.F.,'Lin01')
						Self:oLayer:addWindow('Col01','C1_Win01',STR0001,100,.F.,.F.,{||  },'Lin01',{|| }) //"Conteúdo do Laudo"
				Self:oLayer:addCollumn('Col02',27,.F.,'Lin01')
						Self:oLayer:addWindow('Col02','C2_Win01',STR0002,nCol1H,.T.,.F.,{|| },'Lin01',{|| }) //"Componentes"
						Self:oLayer:addWindow('Col02','C2_Win02',STR0003,nCol2H,.T.,.F.,{|| },'Lin01',{|| }) //"Propriedades"

		// -- PaintPanel (Centro)
		oPnlPaint := TPanel():New(0, 0, Nil, Self:oLayer:getWinPanel('Col01','C1_Win01','Lin01'), Nil, Nil, Nil, Nil, CLR_WHITE, 0, 0, .F., .F.)
		oPnlPaint:Align := CONTROL_ALIGN_ALLCLIENT

		// -- Area PaintPanel
		nPontoC := Self:nWidthArea / 2
		Self:oScrollMd := TScrollBox():New(oPnlPaint, 0, 0, 0, 0, .T., .T., .T.)
		Self:oScrollMd:Align := CONTROL_ALIGN_ALLCLIENT

		Self:oPnlModel := TPaintPanel():New(0, 0, 0/*2480*/, 0/*3508*/,Self:oScrollMd,.F.,.F.)
		Self:oPnlModel:SetBlinker(500)
		Self:oPnlModel:blClicked  := {|nPosX,nPosY| Self:PaintClick(nPosX,nPosY) }

		// Se o bloco de código blClicked do Shape, será disparado no release do botão do mouse,;
		// mesmo estando este dentro no mesmo Container de origem do click do mouse.
		Self:oPnlModel:SetReleaseButton( .T. )

		Self:oPnlModel:nHeight := Self:oScrollMd:nClientHeight+10
		Self:oPnlModel:nWidth  := Self:oScrollMd:nClientWidth-30

		Self:fShapeCabec()

		// -- Painel de Componentes
		oPnlObj := TPanel():New(0, 0, Nil, Self:oLayer:getWinPanel('Col02','C2_Win01','Lin01'), ;
			Nil, Nil, Nil, Nil, CLR_WHITE, 0, 0, .T., .T.)
		oPnlObj:Align := CONTROL_ALIGN_ALLCLIENT

		oScrollObj := TScrollBox():New(oPnlObj, 0, 0, 0, 0, .T., .T., .T.)
		oScrollObj:Align := CONTROL_ALIGN_ALLCLIENT

		Self:LoadCpn() //-- Define os componentes no panel respectivo

		// -- Painel de Propriedades
		Self:LoadProp() //-- Carrega/Atualiza panel de propriedades do componente selecionado
	EndIf

Return Self

//---------------------------------------------------------------------
/*/{Protheus.doc} fShapeCabec
Monta cabeçalho do PaintPanel

@type Method

@source MDTA210a.prw

@author Denis
@since 02/03/2010

@sample fShapeCabec()

@return
/*/
//---------------------------------------------------------------------
Method fShapeCabec() Class TNGLAUDO

	Local nPontoC := Self:nWidthArea / 2

	//Cria shape Auxiliar para o funcionamento do clique
	__nIdAux := Self:SetIdShp()
	Self:oPnlModel:addShape("id="+cValToChar(__nIdAux)+";type=6;gradient=1,0,0,0,0,0.0,#000000;pen-width=0;"+;
								"pen-color=#000000;can-move=0;can-mark=0;large=0;from-left=0;from-top=0;to-left=0;to-top=0;")
	Self:oPnlModel:SetVisible(__nIdAux,.F.)
	/*
	----- 	RETIRADO SHAPE POIS NAO LOCALIZADO MOTIVO DE SUA EXISTENCIA. ------------------------------------------------------------------------------
	-----	TECNOLOGIA REALIZOU UMA IMPLEMENTACAO EM 18/12/2013 ONDE NAO E' MAIS POSSIVEL MOVIMENTAR OBJETOS DENTRO DE SHAPES COM IS-CONTAINER=1. -----
	-----	COMO A UTILIZACAO DO SHAPE SE DAVA APENAS PARA COBRIR A TELA COMO UM TODO, ESTE FOI COMENTADO. --------------------------------------------
	Self:oPnlModel:addShape("id="+cValToChar(Self:SetIdShp())+";type=1;left=0;top=0;width="+cValToChar(Self:oPnlModel:nWidth)+;
		";height="+cValToChar(Self:oPnlModel:nHeight)+";"+;
		"gradient=1,0,0,0,0,0.0,#FFFFFF;pen-width=1;pen-color=#ffffff;can-move=0;can-mark=0;is-container=1;")
	*/
	Self:oPnlModel:AddShape("id=" + cValToChar(Self:SetIdShp()) + ";type=1;left=" + cValToChar(0) + ;
		";top=0;width=" + cValToChar(Self:nWidthArea) + ";height=" + cValToChar(40) + ";"+;
		"gradient=1,0,0,0,0,0.0,#1874CD;pen-width=1;"+;
		"pen-color=#1874CD;can-move=0;can-mark=0;is-container=1;")
	Self:oPnlModel:AddShape("id=" + cValToChar(Self:SetIdShp()) + ";type=9;can-move=0;pen-color=#FFFFFF;" + ;
		"gradient=0,0,0,0,0,0,#FFFFFF;pen-width=1;can-mark=0;is-container=0;" + ;
		"from-left=" + cValToChar(55) + ";from-top=" + cValToChar(0) + ;
		";to-left=" + cValToChar(55) + ";to-top=" + cValToChar(40) + ";")
	Self:oPnlModel:AddShape("id=" + cValToChar(Self:SetIdShp()) + ";type=9;can-move=0;pen-color=#FFFFFF;" + ;
		"gradient=0,0,0,0,0,0,#FFFFFF;pen-width=1;can-mark=0;is-container=0;" + ;
		"from-left=" + cValToChar(150) + ";from-top=" + cValToChar(0) + ;
		";to-left=" + cValToChar(150) + ";to-top=" + cValToChar(40) + ";")

	nTmpX := Len(STR0015)*_nPix //"Item"
	Self:oPnlModel:AddShape("id=" + cValToChar(Self:SetIdShp()) + ";type=7;left=" + cValToChar(17) + ;
		";top=" + cValToChar(12) + ";gradient=0,0,0,0,0,0,#FFFFFF;" + ;
		"can-mark=0;can-move=0;can-deform=0;is-container=0;pen-width=1;" + ;
		"width=" + cValToChar(nTmpX) + ";height=20;" + ;
		"pen-color=#FFFFFF;text=" + STR0015 + ";font=Arial,8,0,0,1;") //"Item"

	nTmpX := Len(STR0016)*_nPix //"Tipo"
	Self:oPnlModel:AddShape("id=" + cValToChar(Self:SetIdShp()) + ";type=7;left=" + cValToChar(90) + ;
		";top=" + cValToChar(10) + ";gradient=0,0,0,0,0,0,#FFFFFF;" + ;
		"can-mark=0;can-move=0;can-deform=0;is-container=0;pen-width=1;" + ;
		"width=" + cValToChar(nTmpX) + ";height=20;" + ;
		"pen-color=#FFFFFF;text=" + STR0016 + ";font=Arial,8,0,0,1;") //"Tipo"

	nTmpX := Len(STR0014)*_nPix //"Conteúdo"
	Self:oPnlModel:AddShape("id=" + cValToChar(Self:SetIdShp()) + ";type=7;left=" + cValToChar(nPontoC-(nTmpX/2)) + ;
		";top=" + cValToChar(10) + ";gradient=0,0,0,0,0,0,#FFFFFF;" + ;
		"can-mark=0;can-move=0;can-deform=0;is-container=0;pen-width=1;" + ;
		"width=" + cValToChar(nTmpX) + ";height=20;" + ;
		"pen-color=#FFFFFF;text=" + STR0014 + ";font=Arial,8,0,0,1;") //"Conteúdo"

	Self:oPnlModel:SetFocus()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³LoadOpc          ³Autor³ Denis               ³Data³02/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carrega opções disponíveis, conforme o modelo especificado,  ³±±
±±³          ³na barra de opções.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTA210                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method NewModel() Class TNGLAUDO

	//-- Habilita Panel preto transparente como fundo
	Self:SetBlackPnl(.F.)

	lEnd := .F.
	lActivate := .T.

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³ LoadModel       ³Autor³ Denis               ³Data³02/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carrega opções disponíveis, conforme o modelo especificado,  ³±±
±±³          ³na barra de opções.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTA210                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method LoadModel(cMemo) Class TNGLAUDO

	Local cMemoTxt := cMemo
	Local cTexto, nPos1, cTitulo, lEof := .T.

	While lEof
		If Empty(cMemoTxt)  //Memo vazio
			lEof := .F.
			Exit
		Else
			nPos1 := At("#",cMemoTxt) //Inicio de um Titulo
			If nPos1 > 1
				cTexto   := Alltrim(Substr(cMemoTxt,1,nPos1-1))
				cMemoTxt := Alltrim(Substr(cMemoTxt,nPos1))
				Self:ImpTexto(Alltrim(cTexto))
				Loop
			ElseIf nPos1 == 1 //Existe #
				cMemoTxt := Alltrim(Substr(cMemoTxt,nPos1+1))
				nPos1    := At("#",cMemoTxt)
				cTitulo  := Alltrim(Substr(cMemoTxt,1,nPos1-1))
				cMemoTxt := Alltrim(Substr(cMemoTxt,nPos1+1))
				nPos1    := At("#",cMemoTxt)
				If nPos1 > 0
					cTexto   := Alltrim(Substr(cMemoTxt,1,nPos1-1))
					cMemoTxt := Alltrim(Substr(cMemoTxt,nPos1))
				Else
					cTexto   := Alltrim(cMemoTxt)
					cMemoTxt := " "
					lEof     := .F.
				EndIf
			Else//Nao existe #
				//IMPRIME TEXTO
				Self:ImpTexto(Alltrim(cMemoTxt))
				lEof := .F.
				Exit
			EndIf
			//IMPRIME TITULO
			If !Empty(cTitulo)
				If Self:nTipoLaudo != 5
					Self:ImpTitulo(cTitulo)
				EndIf
			EndIf
			//IMPRIME TEXTO
			If !Empty(cTexto)
				Self:ImpTexto(Alltrim(cTexto))
			EndIf
		EndIf
	End

	If Len(Self:aShapesUt) > 0
		Self:LoadProp( Self:oPnlModel:ShapeAtu := Self:aShapesUt[1,1] )
	EndIf

	Self:aObjAtu := {}
	Self:lCreate := .F.

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImpTexto ³ Autor ³Denis Hyroshi de Souza ³ Data ³ 08.04.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³IMPRIME O CONTEUDO DO TEXTO                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method ImpTexto(_cTexto) Class TNGLAUDO

	Local lTexto  := .T.
	Local cTitExe, nArroba
	Local cTextoNew := _cTexto
	Local cTxtMemo  := _cTexto

	Private lFirst    := .T.

	lJumpCab := .F. //Somalinha do Titulo de Relatorio
	While lTexto
		nArroba := At("@",cTxtMemo)

		If nArroba > 1
			cTextoNew := Alltrim(Substr(cTxtMemo,1,nArroba-1))
			cTxtMemo  := Alltrim(Substr(cTxtMemo,nArroba))
			Self:ImpTexto(Alltrim(cTextoNew))
			Loop
		ElseIf nArroba == 1 //Existe @
			cTxtMemo := Alltrim(Substr(cTxtMemo,nArroba+1))
			nArroba  := At("@",cTxtMemo)
			cTitExe  := Alltrim(Substr(cTxtMemo,1,nArroba-1))
			If Self:nTipoLaudo != 5
				Self:ImpAtalho(cTitExe)
			EndIf
			cTxtMemo := Alltrim(Substr(cTxtMemo,nArroba+1))
			nArroba   := At("@",cTxtMemo)
			If nArroba > 0
				cTextoNew := Alltrim(Substr(cTxtMemo,1,nArroba-1))
				cTxtMemo  := Alltrim(Substr(cTxtMemo,nArroba))
				If !Empty(cTextoNew) .And. Len(Alltrim(cTextoNew)) > 2
					Self:ImpTexto(Alltrim(cTextoNew))
				EndIf
				Loop
			EndIf
		EndIf

		If (nPosTxt := At(Chr(13)+Chr(10),cTxtMemo)) == 1
			cTextoNew :=  Alltrim(Substr(cTxtMemo,nPosTxt+2))
		Else
			cTextoNew :=  Alltrim(cTxtMemo)
		EndIf
		lTexto := .F.

		If Empty(cTextoNew)
			cTextoNew := " "
		EndIf
		If !Empty(cTextoNew) .And. Len(Alltrim(cTextoNew)) > 2
			Self:SelectCpn(1,{cTextoNew},.F.)
		EndIf
	End

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ImpTitulo ³ Autor ³Denis Hyroshi de Souza ³ Data ³ 08.04.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³IMPRIME O TITULO DO TEXTO                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method ImpTitulo(_cTit) Class TNGLAUDO

	Local nPosTemp
	Local _cTitulo := _cTit
	Local cCNS := " "
	Local lNegrito := .F.
	Local lCentro  := .F.
	Local lSublin  := .F.
	Local nIndice  := 0

	If ("{" $ _cTitulo) .And.  ("}" $ _cTitulo)
		nPosTemp := At("}",_cTitulo)
		cCNS     := Substr(_cTitulo,1,nPosTemp)
		_cTitulo := Substr(_cTitulo,nPosTemp+1)
	EndIf

	If ("1" $Upper(cCNS))//Titulo 1
		nIndice := 1
	ElseIf("2" $Upper(cCNS))//2=Titulo 2
		nIndice := 2
	ElseIf("3" $Upper(cCNS))//2=Titulo 3
		nIndice := 3
	ElseIf("4" $Upper(cCNS))//2=Titulo 4
		nIndice := 4
	EndIf

	If ("N" $ Upper(cCNS)) //N=Negrito
		lNegrito := .T.
	EndIf
	If ("C" $ Upper(cCNS)) //C=Centralizar
		lCentro := .T.
	EndIf
	If ("S" $ Upper(cCNS)) //S=Sublinhar
		lSublin := .T.
	EndIf

	Self:SelectCpn(3,{_cTitulo,lNegrito,lCentro,lSublin,nIndice},.F.)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ImpAtalho ³ Autor ³Denis Hyroshi de Souza ³ Data ³ 08.04.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³IMPRIME ATALHO                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method ImpAtalho(cTitExe) Class TNGLAUDO

	Local nPos1, nTipo
	Local cTitTemp

	If Alltrim(cTitExe) == "PAGINA"
		Self:SelectCpn(6,{cTitExe},.F.)
	Else
		nTipo := 2

		cTitTemp := cTitExe
		nPos1    := At("!",cTitTemp)
		If nPos1 > 0
			cTitTemp := Alltrim(Substr(cTitTemp,nPos1+1))
			nPos1    := At("!",cTitTemp)
			If nPos1 > 0
				cTitTemp := Substr(cTitTemp,1,nPos1-1)
				nTipo    := 4
			EndIf
		EndIf

		If nTipo == 2
			cTitTemp := cTitExe
			nPos1    := At("%",cTitTemp)
			If nPos1 > 0
				cTitTemp := Alltrim(Substr(cTitTemp,nPos1+1))
				nPos1    := At("%",cTitTemp)
				If nPos1 > 0
					cTitTemp := Substr(cTitTemp,1,nPos1-1)
					nTipo    := 5
				EndIf
			EndIf
		EndIf

		If nTipo == 2
			cTitTemp := cTitExe
			Self:SelectCpn(nTipo,{Alltrim(cTitTemp)},.F.)
		Else
			Self:SelectCpn(nTipo,{Alltrim(cTitTemp)},.F.)
		EndIf

	EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³LoadCpn          ³Autor³ Denis               ³Data³02/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carrega opções disponíveis, conforme o modelo especificado,  ³±±
±±³          ³na barra de opções.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTA210                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method LoadCpn() Class TNGLAUDO

	Local aPos := {{05,08},{05,55},{05,102},{35,08},{35,55},{35,102},{65,08}}
	Local nPos := 0

	If Self:oPnlModel:nWidth < 750
		aPos := {{05,08},{05,48},{05,88},{35,08},{35,48},{35,88},{65,08}}
	EndIf

	Self:aCpnts := Array(7,3)

	nPos++
	Self:aCpnts[1,1] := TButton():New(aPos[nPos,1],aPos[nPos,2],STR0004,oScrollObj,{|| Self:SelectCpn(1) },20,25, , , ,.T.) //"Texto"
	Self:aCpnts[1,1]:SetCss("QPushButton{ background-image: url(rpo:texto_enable.png);" + ;
		"text-align:bottom; background-position:center top; background-repeat: no-repeat; display: flex;" + ;
		" flex-direction: column;align-items: center;justify-content: flex-end; margin: 1px; border: none }")
	Self:aCpnts[1,1]:SetEnable(.T.)
	Self:aCpnts[1,1]:lCanGotFocus := .F.
	Self:aCpnts[1,2] := 7
	Self:aCpnts[1,3] := "Texto"

	nPos++
	Self:aCpnts[2,1] := TButton():New(aPos[nPos,1],aPos[nPos,2],STR0005,oScrollObj,{|| Self:SelectCpn(2) },23,25, , , ,.T.) //"Atalho"
	Self:aCpnts[2,1]:SetCss("QPushButton{ background-image: url(rpo:campo_enable.png);" + ;
		"text-align:bottom; background-position:center top; background-repeat: no-repeat; display: flex;" + ;
		" flex-direction: column;align-items: center;justify-content: flex-end; margin: 1px; border: none }")
	Self:aCpnts[2,1]:lCanGotFocus := .F.
	Self:aCpnts[2,2] := 7
	Self:aCpnts[2,3] := "Atalho"

	nPos++
	Self:aCpnts[3,1] := TButton():New(aPos[nPos,1],aPos[nPos,2],STR0006,oScrollObj,{|| Self:SelectCpn(3) },20,25, , , ,.T.) //"Título"
	Self:aCpnts[3,1]:SetCss("QPushButton{ background-image: url(rpo:titulo_enable.png);" + ;
		"text-align:bottom; background-position:center top; background-repeat: no-repeat; display: flex;" + ;
		" flex-direction: column;align-items: center;justify-content: flex-end; margin: 1px; border: none }")
	Self:aCpnts[3,1]:lCanGotFocus := .F.
	Self:aCpnts[3,2] := 7
	Self:aCpnts[3,3] := "Titulo"

	nPos++
	Self:aCpnts[4,1] := TButton():New(aPos[nPos,1],aPos[nPos,2],STR0007,oScrollObj,{|| Self:SelectCpn(4) },20,25, , , ,.T.) //"Imagem"
	Self:aCpnts[4,1]:SetCss("QPushButton{ background-image: url(rpo:imagem_enable.png);" + ;
		"text-align:bottom; background-position:center top; background-repeat: no-repeat; display: flex;" + ;
		" flex-direction: column;align-items: center;justify-content: flex-end; margin: 1px; border: none }")
	Self:aCpnts[4,1]:SetEnable(.T.)
	Self:aCpnts[4,1]:lCanGotFocus := .F.
	Self:aCpnts[4,2] := 8
	Self:aCpnts[4,3] := "Imagem"

	nPos++
	Self:aCpnts[5,1] := TButton():New(aPos[nPos,1],aPos[nPos,2],STR0008,oScrollObj,{|| Self:SelectCpn(5) },23,25, , , ,.T.) //"Arquivo"
	Self:aCpnts[5,1]:SetCss("QPushButton{ background-image: url(rpo:arquivo_enable.png);" + ;
		"text-align:bottom; background-position:center top; background-repeat: no-repeat; display: flex;" + ;
		" flex-direction: column;align-items: center;justify-content: flex-end; margin: 1px; border: none }")
	Self:aCpnts[5,1]:lCanGotFocus := .F.
	Self:aCpnts[5,2] := 8
	Self:aCpnts[5,3] := "Arquivo"

	nPos++
	Self:aCpnts[6,1] := TButton():New(aPos[nPos,1],aPos[nPos,2]-10,STR0009,oScrollObj,{|| Self:SelectCpn(6) },40,25, , , ,.T.) //"Quebra de Página"
	Self:aCpnts[6,1]:SetCss("QPushButton{ background-image: url(rpo:pagina_enable.png);" + ;
		"text-align:bottom; background-position:center top; background-repeat: no-repeat; display: flex;" + ;
		" flex-direction: column;align-items: center;justify-content: flex-end; margin: 1px; border: none }")
	Self:aCpnts[6,1]:lCanGotFocus := .F.
	Self:aCpnts[6,2] := 8
	Self:aCpnts[6,3] := "Pagina"

	nPos++
	Self:aCpnts[7,1] := TButton():New(aPos[nPos,1],aPos[nPos,2]-10,STR0149,oScrollObj,{|| Self:SelectCpn(7) },40,25, , , ,.T.)//"Multi-Atalho"
	Self:aCpnts[7,1]:SetCss("QPushButton{ background-image: url(rpo:multi_enable.png);" + ;
		"text-align:bottom; background-position:center top; background-repeat: no-repeat; display: flex;" + ;
		" flex-direction: column;align-items: center;justify-content: flex-end; margin: 1px; border: none }")
	Self:aCpnts[7,1]:lCanGotFocus := .F.
	Self:aCpnts[7,2] := 9
	Self:aCpnts[7,3] := STR0149//"Multi-Atalho"

	If !Inclui .And. !Altera
		Self:aCpnts[1,1]:Disable()
		Self:aCpnts[2,1]:Disable()
		Self:aCpnts[3,1]:Disable()
		Self:aCpnts[4,1]:Disable()
		Self:aCpnts[5,1]:Disable()
		Self:aCpnts[6,1]:Disable()
		Self:aCpnts[7,1]:Disable()
	EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³SetBlackPnl  ³Autor³ Denis                ³ Data ³04/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cria painel escuro transparente, utilizado ao exibir novas  ³±±
±±³          ³dialogs sobre a Area de Trabalho                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especificação de Projeto                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method SetBlackPnl(lVisible) class TNGLAUDO

	Default lVisible := .T.
	If ValType(Self:oBlackPnl) != "O"
		Self:oBlackPnl := TPanel():New(0,0, ,Self:oLayer, , , , , ;
			SetTransparentColor(CLR_BLACK,70),Self:nWidthArea,Self:nHeightArea,.F.,.F.)
		Self:oBlackPnl:Hide()
	EndIf
	If lVisible
		Self:oBlackPnl:nWidth  := Self:nWidthArea
		Self:oBlackPnl:nHeight := Self:nHeightArea
		Self:oBlackPnl:Show()
		Self:oBlackPnl:Align := CONTROL_ALIGN_ALLCLIENT
	Else
		Self:oBlackPnl:Hide()
	EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³ViewBtn          ³Autor³ Denis               ³Data³02/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carrega opções disponíveis, conforme o modelo especificado,  ³±±
±±³          ³na barra de opções.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTA210                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method ViewBtn() Class TNGLAUDO

	Local aPos := {{05,08},{05,55},{05,102},{35,08},{35,55},{35,102},{65,08}}
	Local nPos := 0

	If Self:oPnlModel:nWidth < 750
		aPos := {{05,08},{05,48},{05,88},{35,08},{35,48},{35,88},{65,08}}
	EndIf

	nPos++
	Self:aCpnts[1,1]:Show()
	Self:aCpnts[1,1]:nTop  := 2*aPos[nPos,1]
	Self:aCpnts[1,1]:nLeft := 2*aPos[nPos,2]
	Self:aCpnts[1,1]:cCaption := If(Self:nTipoLaudo==5,STR0021,STR0004)//Objetivo //Texto
	Self:aCpnts[1,1]:bAction := If(Self:nTipoLaudo==5,{|| Self:SelectCpn(1,{},.T.) },{|| Self:SelectCpn(1) })

	If Self:nTipoLaudo != 5
		nPos++
		Self:aCpnts[2,1]:Show()
		Self:aCpnts[2,1]:nTop  := 2*aPos[nPos,1]
		Self:aCpnts[2,1]:nLeft := 2*aPos[nPos,2]
	Else
		Self:aCpnts[2,1]:Hide()
	EndIf

	If Self:nTipoLaudo != 5
		nPos++
		Self:aCpnts[3,1]:Show()
		Self:aCpnts[3,1]:nTop  := 2*aPos[nPos,1]
		Self:aCpnts[3,1]:nLeft := 2*aPos[nPos,2]
	Else
		Self:aCpnts[3,1]:Hide()
	EndIf

	If Self:nTipoLaudo != 5
		nPos++
		Self:aCpnts[4,1]:Show()
		Self:aCpnts[4,1]:nTop  := 2*aPos[nPos,1]
		Self:aCpnts[4,1]:nLeft := 2*aPos[nPos,2]
	Else
		Self:aCpnts[4,1]:Hide()
	EndIf

	If Self:nTipoLaudo != 5
		nPos++
		Self:aCpnts[5,1]:Show()
		Self:aCpnts[5,1]:nTop  := 2*aPos[nPos,1]
		Self:aCpnts[5,1]:nLeft := 2*aPos[nPos,2]
	Else
		Self:aCpnts[5,1]:Hide()
	EndIf

	If Self:nTipoLaudo != 5
		nPos++
		Self:aCpnts[6,1]:Show()
		Self:aCpnts[6,1]:nTop  := 2*aPos[nPos,1]
		Self:aCpnts[6,1]:nLeft := 2*(aPos[nPos,2]-10)
	Else
		Self:aCpnts[6,1]:Hide()
	EndIf

	If Self:nTipoLaudo != 5
		nPos++
		Self:aCpnts[7,1]:Show()
		Self:aCpnts[7,1]:nTop  := 2*aPos[nPos,1]
		Self:aCpnts[7,1]:nLeft := 2*(aPos[nPos,2]-10)
	Else
		Self:aCpnts[7,1]:Hide()
	EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³LoadCpn          ³Autor³ Denis               ³Data³02/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carrega opções disponíveis, conforme o modelo especificado,  ³±±
±±³          ³na barra de opções.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTA210                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method LoadProp(nIdAt) Class TNGLAUDO

	Local nPosShape
	Local cTitle, nMax, cDesc := ""
	Local nFor

	Default nIdAt := 0

	If ValType(Self:oPnlProp) != "O"
		Self:oPnlProp := TPanel():New(0, 0, Nil, Self:oLayer:getWinPanel('Col02','C2_Win02','Lin01'), ;
			Nil, Nil, Nil, Nil,CLR_WHITE, 0, 0, .T., .F.)
		Self:oPnlProp:Align := CONTROL_ALIGN_ALLCLIENT

		Self:oScrollPp := TScrollBox():New(Self:oPnlProp, 0, 0, 0, 0, .T., .T., .T.)
		Self:oScrollPp:Align := CONTROL_ALIGN_ALLCLIENT

		Self:oSayNoCpo := TSAY():New(((Self:oPnlProp:nClientHeight)*0.22),;
				(((Self:oPnlProp:nClientWidth)*0.25) - 32.5),{|| STR0020 },Self:oScrollPp, ; //"Selecione um componente."
				, , .F., .F., .F., .T., , ,65, , , , , , .F. )

		Self:oBtnItem  := TButton():New(11,40,"",Self:oScrollPp,{|| Self:TrocaItem(nIdAt)},20,20, , , ,.T.)
		Self:oBtnItem:SetCss("QPushButton{ background-image: url(rpo:ngicoconfirma.png); " + ;
			"background-position:left center; background-repeat: no-repeat; display: flex;" + ;
			" flex-direction: column;align-items: center;justify-content: flex-end; margin: 1px; border: none }")
		Self:oBtnItem:lCanGotFocus := .T.
		Self:oBtnItem:Hide()
	EndIf

		For nFor := 1 To Len(Self:aPropCpn)
			If ValType(Self:aPropCpn[nFor]) == "O"
				Self:aPropCpn[nFor]:Free()
			EndIf
		Next nFor

		If nIdAt > 0 .And. Len(Self:aShapesUt) > 0 .And. ;
			(nPosShape := aScan(Self:aShapesUt, {|x| x[1] == nIdAt })) > 0

			Self:aPropCpn := Array(7)
			Self:oBtnItem:Show()

			Self:nItemAtual := nPosShape
			nMax := Len(Self:aShapesUt)

			Self:aPropCpn[6] := TSAY():New(5,5,{|| STR0015 },Self:oScrollPp, ; //"Item"
				, , .F., .F., .F., .T., , ,90, , , , , , .F.)

			Self:aPropCpn[7]:= tSpinBox():new(15, 5, Self:oScrollPp, {|x| Self:nItemAtual := x }, 30, 13)
			Self:aPropCpn[7]:SetRange(1, nMax)
			Self:aPropCpn[7]:SetStep(1)
			Self:aPropCpn[7]:SetValue(Self:nItemAtual)
			If !Inclui .And. !Altera
				Self:aPropCpn[7]:Disable()
			EndIf

			If Self:aShapesUt[nPosShape][6] == "Titulo"

				cTitle := PADR( Self:aShapesUt[nPosShape][3][2], 30 )

				Self:aPropCpn[3] := TSAY():New(30,5,{|| STR0006 },Self:oScrollPp, ; //"Título"
					, , .F., .F., .F., .T., , ,90, , , , , , .F.)

				Self:aPropCpn[1] := TGET():New(40,5, ;
					{|u| If( Pcount() > 0, cTitle := u, cTitle) },	Self:oScrollPp,130,08, , ;
						{||  }, , , , , ,.T., , , {|| /*When*/ }, , , , , , ,cTitle)
				Self:aPropCpn[1]:Disable()

			ElseIf Self:aShapesUt[nPosShape][6] == "Atalho"

				cTitle := PADR( Self:aShapesUt[nPosShape][3][2], 30 )

				Self:aPropCpn[3] := TSAY():New(30,5,{|| STR0005 },Self:oScrollPp, ; //"Atalho"
					, , .F., .F., .F., .T., , ,90, , , , , , .F.)

				Self:aPropCpn[1] := TGET():New(40,5, ;
					{|u| If( Pcount() > 0, cTitle := u, cTitle) },	Self:oScrollPp,130,08, , ;
						{||  }, , , , , ,.T., , , {|| /*When*/ }, , , , , , ,cTitle)
				Self:aPropCpn[1]:Disable()

				cDesc  := Self:aShapesUt[nPosShape][3][3]

				Self:aPropCpn[4] := TSAY():New(55,5,{|| STR0019 },Self:oScrollPp, ; //"Descrição"
					, , .F., .F., .F., .T., , ,50, , , , , , .F.)

				nMltHei := 140
				nMlmHei := 73
				nCliHei := Self:oPnlProp:nClientHeight
				If ValType(Self:oPnlProp2) != "O"
					nCliHei := Self:oPnlProp:nClientHeight-40
				EndIf
				If nCliHei < 350
					nMltHei := nCliHei/2
					nMlmHei := nMltHei-67
				EndIf
				Self:aPropCpn[5] := TGroup():New(65,05,nMltHei,((Self:oPnlProp:nClientWidth)*0.50)-08,"",Self:oScrollPp, , ,.T.)

				Self:aPropCpn[2] := TMultiGet():Create(Self:aPropCpn[5],{|u| If(Pcount() > 0, cDesc := u, cDesc)},66,06,((Self:oPnlProp:nClientWidth)*0.50)-16,nMlmHei, , , , , , .T., , , , , , .T.,{|| /*Valid*/}, , ,.F.,.F.)
				Self:aPropCpn[2]:EnableHScroll(.T.)
				Self:aPropCpn[2]:EnableVScroll(.T.)

			ElseIf Self:aShapesUt[nPosShape][6] == "Texto"

				cDesc := Self:aShapesUt[nPosShape][3][2]

				Self:aPropCpn[3] := TSAY():New(30,5,{|| If(Self:nTipoLaudo==5,STR0021,STR0004) },Self:oScrollPp, ; //"Texto" //"Objetivo"
					, , .F., .F., .F., .T., , ,90, , , , , , .F.)

				nMltHei := 140
				nMlmHei := 98
				nCliHei := Self:oPnlProp:nClientHeight
				If ValType(Self:oPnlProp2) != "O"
					nCliHei := Self:oPnlProp:nClientHeight-40
				EndIf
				If nCliHei < 350
					nMltHei := nCliHei/2
					nMlmHei := nMltHei-42
				EndIf
				Self:aPropCpn[5] := TGroup():New(40,05,nMltHei,((Self:oPnlProp:nClientWidth)*0.50)-08,"",Self:oScrollPp, , ,.T.)

				Self:aPropCpn[2] := TMultiGet():Create(Self:aPropCpn[5],{|u| If(Pcount() > 0, cDesc := u, cDesc)},41,06,((Self:oPnlProp:nClientWidth)*0.50)-16,nMlmHei, , , , , , .T., , , , , , .T.,{|| /*Valid*/}, , ,.F.,.F.)
				Self:aPropCpn[2]:EnableHScroll(.T.)
				Self:aPropCpn[2]:EnableVScroll(.T.)

			ElseIf Self:aShapesUt[nPosShape][6] == "Arquivo" .Or. Self:aShapesUt[nPosShape][6] == "Imagem"

				cTitle := PADR( Self:aShapesUt[nPosShape][3][2], 30 )

				If Self:aShapesUt[nPosShape][6] == "Imagem"
					Self:aPropCpn[3] := TSAY():New(30,5,{|| STR0007 },Self:oScrollPp, ; //"Imagem"
						, , .F., .F., .F., .T., , ,90, , , , , , .F.)
				Else
					Self:aPropCpn[3] := TSAY():New(30,5,{|| STR0008 },Self:oScrollPp, ; //"Arquivo"
						, , .F., .F., .F., .T., , ,90, , , , , , .F.)
				EndIf

				Self:aPropCpn[1] := TGET():New(40,5, ;
					{|u| If( Pcount() > 0, cTitle := u, cTitle) },	Self:oScrollPp,130,08, , ;
						{||  }, , , , , ,.T., , , {|| /*When*/ }, , , , , , ,cTitle)
				Self:aPropCpn[1]:Disable()
			ElseIf Self:aShapesUt[nPosShape][6] == "Pagina"
				Self:aPropCpn[3] := TSAY():New(30,5,{|| STR0009 },Self:oScrollPp, ; //"Quebra de Página"
					, , .F., .F., .F., .T., , ,90, , , , , , .F.)
			EndIf

			If ValType(Self:oPnlProp2) != "O"
				Self:aPropOpc := Array(4)

				Self:oPnlProp2 := TPanel():New(0, 0, Nil, Self:oLayer:getWinPanel('Col02','C2_Win02','Lin01'), ;
				Nil, Nil, Nil, CLR_BLACK, CLR_WHITE, 0, 20, .T., .T.)
				Self:oPnlProp2:Align := CONTROL_ALIGN_BOTTOM

				Self:aPropOpc[1]  := TButton():New(0,0,STR0010,Self:oPnlProp2,{|| Self:EditCpo()},40,14, , , ,.T.) //"Editar"
				Self:aPropOpc[1]:Align := CONTROL_ALIGN_LEFT
				Self:aPropOpc[1]:SetCss("QPushButton{ background-image: url(rpo:editable.png); " + ;
					"background-position:left center; background-repeat: no-repeat; display: flex;" + ;
					" flex-direction: column;align-items: center;justify-content: flex-end; margin: 1px; border: none }")
				Self:aPropOpc[1]:lCanGotFocus := .F.

				Self:aPropOpc[2]   := TButton():New(0,0,STR0011,Self:oPnlProp2,{|| Self:DelLinha()},41,14, , , ,.T.) //"Excluir"
				Self:aPropOpc[2]:Align :=  CONTROL_ALIGN_LEFT
				Self:aPropOpc[2]:SetCss("QPushButton{ background-image: url(rpo:excluir.png); " + ;
					"background-position:left center; background-repeat: no-repeat; display: flex;" + ;
					" flex-direction: column;align-items: center;justify-content: flex-end; margin: 1px; border: none }")
				Self:aPropOpc[2]:lCanGotFocus := .F.

				Self:aPropOpc[3] := TButton():New(0,0,STR0022,Self:oPnlProp2,{|| Self:AbreArquivo(nIdAt)},50,14, , , ,.T.) //"Visualizar"
				Self:aPropOpc[3]:Align :=  CONTROL_ALIGN_LEFT
				Self:aPropOpc[3]:SetCss("QPushButton{ background-image: url(rpo:BMPVISUAL.png); " + ;
					"background-position:left center; background-repeat: no-repeat; display: flex;" + ;
					" flex-direction: column;align-items: center;justify-content: flex-end; margin: 1px; border: none }")
				Self:aPropOpc[3]:lCanGotFocus := .F.
				Self:aPropOpc[3]:Hide()

				Self:aPropOpc[4] := TButton():New(0,0,STR0013,Self:oPnlProp2,{|| Self:EditCpo()},40,10, , , ,.T.) //"Cancelar"
				Self:aPropOpc[4]:Align :=  CONTROL_ALIGN_RIGHT
				Self:aPropOpc[4]:SetCss("QPushButton{ background-image: url(rpo:cancel_15.png); " + ;
					"background-position:left center; background-repeat: no-repeat; display: flex;" + ;
					" flex-direction: column;align-items: center;justify-content: flex-end; margin: 1px; border: none }")
				Self:aPropOpc[4]:lCanGotFocus := .F.
				Self:aPropOpc[4]:Hide()
			ElseIf Self:aShapesUt[nPosShape][6] == "Pagina"
				Self:aPropOpc[1]:Disable()
				Self:aPropOpc[2]:Show()
				Self:aPropOpc[3]:Hide()
				Self:aPropOpc[4]:Hide()
				If !Inclui .And. !Altera
					Self:aPropOpc[2]:Disable()
				EndIf
			ElseIf Self:aShapesUt[nPosShape][6] == "Arquivo" .Or. Self:aShapesUt[nPosShape][6] == "Imagem"
				Self:aPropOpc[1]:Show()
				Self:aPropOpc[1]:Enable()
				Self:aPropOpc[2]:Show()
				Self:aPropOpc[3]:Show()
				Self:aPropOpc[4]:Hide()
				If !Inclui .And. !Altera
					Self:aPropOpc[1]:Disable()
					Self:aPropOpc[2]:Disable()
					Self:aPropOpc[3]:Disable()
				EndIf
			Else
				Self:aPropOpc[1]:Show()
				Self:aPropOpc[1]:Enable()
				Self:aPropOpc[2]:Show()
				Self:aPropOpc[3]:Hide()
				Self:aPropOpc[4]:Hide()
				If !Inclui .And. !Altera
					Self:aPropOpc[1]:Disable()
					Self:aPropOpc[2]:Disable()
				EndIf
			EndIf

			If Self:aShapesUt[nPosShape][6] == "Texto"
				Self:aPropOpc[1]:bAction := {|| Self:SelectCpn(1,{},.T.) }
			ElseIf Self:aShapesUt[nPosShape][6] == "Atalho"
				Self:aPropOpc[1]:bAction := {|| Self:SelectCpn(2,{},.T.) }
			ElseIf Self:aShapesUt[nPosShape][6] == "Titulo"
				Self:aPropOpc[1]:bAction := {|| Self:SelectCpn(3,{},.T.) }
			ElseIf Self:aShapesUt[nPosShape][6] == "Imagem"
				Self:aPropOpc[1]:bAction := {|| Self:SelectCpn(4,{},.T.) }
				Self:aPropOpc[3]:bAction := {|| Self:AbreArquivo(nIdAt) }
			ElseIf Self:aShapesUt[nPosShape][6] == "Arquivo"
				Self:aPropOpc[1]:bAction := {|| Self:SelectCpn(5,{},.T.) }
				Self:aPropOpc[3]:bAction := {|| Self:AbreArquivo(nIdAt) }
			EndIf
			Self:oBtnItem:bAction := {|| Self:TrocaItem(nIdAt)}

			If ValType(Self:oSayNoCpo) == "O"
				Self:oSayNoCpo:Hide()
			EndIf

		Else

			Self:oSayNoCpo:Show()
			Self:oBtnItem:Hide()
			If Len(Self:aPropOpc) > 0 .And. ValType(Self:aPropOpc[1]) == "O"
				Self:aPropOpc[1]:Hide()
				Self:aPropOpc[2]:Hide()
				Self:aPropOpc[3]:Hide()
				Self:aPropOpc[4]:Hide()
			EndIf
		EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³ AbreArquivo     ³Autor³ Denis               ³Data³02/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Abre arquivo ou imagem                                       ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTA210                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method AbreArquivo(nIdAt) Class TNGLAUDO

	Local cDirectory := __cDirectory__
	Local nPosTmp1 := aScan(Self:aShapesUt, {|x| nIdAt == x[1] })
	Local cFileArq := "", nPos
	Local cBarraSrv := "\"

	If isSRVunix()  //servidor eh da familia Unix (linux, solaris, free-bsd, hp-ux, etc.)
		cBarraSrv := "/"
	EndIf

	If nPosTmp1 > 0
		If !Empty(Self:aShapesUt[nPosTmp1][3][2])
			//Cria pasta no Temp
			If !ExistDir(cDirectory)
				MakeDir(cDirectory)
			EndIf
			nPos := Rat(cBarraSrv,Self:aShapesUt[nPosTmp1][3][2])
			If nPos > 0
				cFileArq := AllTrim(Substr(Self:aShapesUt[nPosTmp1][3][2],nPos+1))
			EndIf
			CpyS2T( Self:aShapesUt[nPosTmp1][3][2], cDirectory, .T.) // Copia do Server para o Remote, eh necessario
			If File(cDirectory+cFileArq)
				ShellExecute("open", cDirectory+cFileArq , "" ,"" , 3 )
			EndIf
		EndIf
	EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³ DelLinha        ³Autor³ Denis               ³Data³02/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Deleta linha                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTA210                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method DelLinha() Class TNGLAUDO

	Local nPosTmp1 := aScan(Self:aShapesUt, {|x| Self:oPnlModel:ShapeAtu == x[1] })
	Local nFor2,nFor3
	Local nIdNext := 0

	If nPosTmp1 > 0 .And. Self:oPnlModel:ShapeAtu > 0
		//Apaga os objetos da linha
		Self:oPnlModel:DeleteItem(Self:oPnlModel:ShapeAtu)
		For nFor2 := 1 To Len(Self:aShapesUt[nPosTmp1,10])
			Self:oPnlModel:DeleteItem( Self:aShapesUt[nPosTmp1][10][nFor2][1] )
		Next nFor2

		//Sobe as linhas
		For nFor2 := nPosTmp1 To Len(Self:aShapesUt)-1
			nTopTemp1 := Self:aShapesUt[nFor2,5]
			nTopTemp2 := Self:aShapesUt[nFor2,7]
			Self:aShapesUt[nFor2] := aClone(Self:aShapesUt[nFor2+1])
			Self:aShapesUt[nFor2,5] := nTopTemp1
			Self:aShapesUt[nFor2,7] := nTopTemp2
			Self:oPnlModel:SetPosition(Self:aShapesUt[nFor2][1],Self:aShapesUt[nFor2][4],Self:aShapesUt[nFor2,5]+Self:aShapesUt[nFor2,8])
			For nFor3 := 1 To Len(Self:aShapesUt[nFor2,10])
				Self:oPnlModel:SetPosition(	Self:aShapesUt[nFor2][10][nFor3][1],;
											Self:aShapesUt[nFor2][10][nFor3][2],;
											Self:aShapesUt[nFor2,5]+Self:aShapesUt[nFor2][10][nFor3][3])
			Next nFor3
		Next nFor2

		aDel( Self:aShapesUt, Len(Self:aShapesUt) )
		aSize( Self:aShapesUt, Len(Self:aShapesUt)-1 )

		If Len(Self:aGradeSh) > 0
			For nFor2 := 1 To 4
				Self:oPnlModel:DeleteItem( Self:aGradeSh[Len(Self:aGradeSh),nFor2] )
			Next nFor2
			aDel( Self:aGradeSh, Len(Self:aGradeSh) )
			aSize( Self:aGradeSh, Len(Self:aGradeSh)-1 )
		EndIf

		nIdNext := If( nPosTmp1 > Len(Self:aShapesUt) , Len(Self:aShapesUt) , nPosTmp1 )

		If nIdNext > 0
			Self:oPnlModel:ShapeAtu := Self:aShapesUt[nIdNext][1]
			Self:LoadProp( Self:aShapesUt[nIdNext][1] )
		Else
			Self:LoadProp( 0 )
		EndIf
	EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³LoadCpn          ³Autor³ Denis               ³Data³02/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carrega opções disponíveis, conforme o modelo especificado,  ³±±
±±³          ³na barra de opções.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTA210                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method EditCpo() Class TNGLAUDO

	Self:SelectCpn(1,{},.T.)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³LoadCpn          ³Autor³ Denis               ³Data³02/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carrega opções disponíveis, conforme o modelo especificado,  ³±±
±±³          ³na barra de opções.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTA210                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method SelectCpn(nCpnt,aArrAuto,lEditShape) Class TNGLAUDO

	Local nPosLin := 40, nPosCol := 70
	Default aArrAuto := {}
	Default lEditShape := .F.
	Private cTamFld, nMargin := 70

	If nCpnt == 7
		nCpnt := 2
		Self:lMulti := .T.
	EndIf

	//-- Atribui à array aObjAtu, o conteudo correspondente ao nCpnt
	Self:aObjAtu := aClone(Self:aCpnts[nCpnt])
	Self:lCreate := .T. //-- Indicando a criação do objeto ao acionar o evento click do paintpanel

	If Self:DefineCpn(aArrAuto,lEditShape) //-- Caso haja uma definição para o componente solicitado
		If !( Self:lMulti )
			If Len(Self:aShapesUt) > 0
				nPosLin := Self:aShapesUt[Len(Self:aShapesUt),5] + 40
			EndIf
			Self:PaintClick(nPosCol,nPosLin,.F.,lEditShape)
		Else
			Self:lMulti := .F.
		EndIf
	EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³LoadCpn          ³Autor³ Denis               ³Data³02/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carrega opções disponíveis, conforme o modelo especificado,  ³±±
±±³          ³na barra de opções.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTA210                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method DefineCpn(aArrAuto,lEditShape) Class TNGLAUDO

	Local lRet := .F.

	Default aArrAuto := {}
	Default lEditShape := .F.

	If Self:aObjAtu[3] == "Atalho" //-- Caso o componente solicitado seja um Atalho
		If Self:lMulti
			lRet := Self:DefineMulti()
		Else
			lRet := Self:DefineAtalho(aArrAuto,lEditShape)
		EndIf
	ElseIf Self:aObjAtu[3] == "Texto" //-- Caso o componente solicitado seja um Texto
		lRet := Self:DefineTexto(aArrAuto,lEditShape)
	ElseIf Self:aObjAtu[3] == "Titulo" //-- Caso o componente solicitado seja um Titulo
		lRet := Self:DefineLabel(aArrAuto,lEditShape)
	ElseIf Self:aObjAtu[3] == "Imagem" //-- Caso o componente solicitado seja uma Imagem
		lRet := Self:DefineArquivo(aArrAuto,"IMG",lEditShape)
	ElseIf Self:aObjAtu[3] == "Arquivo" //-- Caso o componente solicitado seja um Arquivo Txt
		lRet := Self:DefineArquivo(aArrAuto,"DOC",lEditShape)
	ElseIf Self:aObjAtu[3] == "Pagina" //-- Caso o componente solicitado seja uma Quebra Pagina
		lRet := Self:DefinePagina(aArrAuto)
	EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³ DefineAtalho    ³Autor³ Denis               ³Data³02/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Tela de montagem de atalho para o laudo.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTA210                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method DefineAtalho(aArrAuto,lEditShape) Class TNGLAUDO

	Local oDlgDfField, oPnlField
	Local oBtnCancel, oBtnInic, oScrollBox
	Local lRet := .F., oDesc, nPos, nPosTmp1, nXXX
	Local aRetBox := Self:BoxLaudo()
	Local cTipAtal := aRetBox[1][1]
	Local cDesc    := aRetBox[1][2]
	Local aRetCBox := {}
	Local cBakAtal
	Default aArrAuto := {}

	For nXXX := 1 To Len(aRetBox)
		aAdd( aRetCBox , aRetBox[nXXX,1] )
	Next nXXX

	If Len(aArrAuto) > 0

		cTipAtal := Alltrim(aArrAuto[1])
		nPos := aScan(aRetBox, {|x| AllTrim(x[1]) == AllTrim(cTipAtal) .And. Len(AllTrim(x[1])) == Len(AllTrim(cTipAtal)) })

		//nPos := aScan(aRetBox, {|x| Alltrim(x[1]) == AllTrim(cTipAtal) .And. Len(Alltrim(x[1])) == Len(AllTrim(cTipAtal)) })
		If nPos > 0
			cDesc := aRetBox[nPos,2]
		//-- Alimenta array aObjAtu com as definições informadas
			aAdd(Self:aObjAtu, Array(4))
			Self:aObjAtu[4][1] := AllTrim(cTipAtal)
			Self:aObjAtu[4][2] := AllTrim(cDesc)
			Return .T.
		Else
			Return .F.
		EndIf
	ElseIf lEditShape
		nPosTmp1 := aScan(Self:aShapesUt, {|x| Self:oPnlModel:ShapeAtu == x[1] })
		If nPosTmp1 > 0
			cTipAtal := Alltrim(Self:aShapesUt[nPosTmp1][3][2])
			cDesc := Self:aShapesUt[nPosTmp1][3][3]
		Else
			Return .F.
		EndIf
	EndIf

	cBakAtal := cTipAtal

	Self:SetBlackPnl(.T.)

	DEFINE MSDIALOG oDlgDfField FROM 0,0 TO 215,360 OF SELF ;
	COLOR CLR_BLACK,CLR_WHITE STYLE nOr(DS_SYSMODAL,WS_MAXIMIZEBOX,WS_POPUP) PIXEL

		oPnlField := Self:LoadBg(oDlgDfField)

		@ 013.5,015 SAY OemToAnsi(STR0005) OF oPnlField PIXEL //"Atalho"
		@ 012,034 COMBOBOX oCbxAtal VAR cTipAtal Items aRetCBox SIZE 135,60 PIXEL OF oPnlField
		oCbxAtal:SetFocus()
		oCbxAtal:bValid  := {|| VldAtalho(Alltrim(cTipAtal),aRetBox,@cDesc,@oDesc)}
		oCbxAtal:bChange := {|| VldAtalho(Alltrim(cTipAtal),aRetBox,@cDesc,@oDesc)}

		@ 029,015 SAY OemToAnsi(STR0019) OF oPnlField PIXEL //"Descrição"
		oScrollBox  := TScrollBox():New(oPnlField,039,015,55,152,.T.,.T.,.F.)
		oDesc       := TMultiGet():Create(oScrollBox,{|u| If(Pcount() > 0, cDesc := u, cDesc)},000,000,000,000, , , , , ,.T.)
		oDesc:Align := CONTROL_ALIGN_ALLCLIENT
		oDesc:Disable()

		@ 103,43  BUTTON oBtnInic   Prompt STR0012 SIZE 45,11 OF oPnlField PIXEL ACTION ( lRet := .T., If(Self:VldTexto(cTipAtal,STR0005,.T.,cBakAtal),oDlgDfField:End(),lRet := .F.) ) //"Confirmar"
		@ 103,93  BUTTON oBtnCancel Prompt STR0013  SIZE 45,11 OF oPnlField PIXEL ACTION ( lRet := .F., oDlgDfField:End() ) //"Cancelar"

	ACTIVATE MSDIALOG oDlgDfField CENTERED

	If lRet .And. !Empty(cTipAtal)
	//-- Alimenta array aObjAtu com as definições informadas
		aAdd(Self:aObjAtu, Array(4))
		Self:aObjAtu[4][1] := AllTrim(cTipAtal)
		Self:aObjAtu[4][2] := AllTrim(cDesc)
	Else
		//-- Define que o objeto não será criado ao acionar o click na area do paintpanel
		Self:lCreate := .F.
		Self:aObjAtu := {}
	EndIf

	Self:SetBlackPnl(.F.)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³ VldAtalho       ³Autor³ Denis               ³Data³02/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida campo de selecoa do atalho                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTA210                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function VldAtalho(cTipAtal,aRetBox,cDesc,oDesc)

	Local nPos := aScan(aRetBox, {|x| Alltrim(x[1]) == cTipAtal .And. Len(Alltrim(x[1])) == Len(cTipAtal) })
	If nPos > 0
		cDesc := aRetBox[nPos,2]
		oDesc:Refresh()
	EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³ DefineTexto     ³Autor³ Denis               ³Data³02/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Tela de montagem de texto fixo no laudo.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTA210                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method DefineTexto(aArrAuto,lEditShape) Class TNGLAUDO

	Local oDlgDfField, oPnlField
	Local oBtnCancel, oBtnInic, oScrollBox
	Local lRet := .F., oDesc, cDesc
	Default aArrAuto := {}

	If Len(aArrAuto) > 0
		cDesc := aArrAuto[1]
		If !Empty(cDesc)
		//-- Alimenta array aObjAtu com as definições informadas
			aAdd(Self:aObjAtu,Array(1))
			Self:aObjAtu[4][1] := cDesc
			Return .T.
		Else
			Return .F.
		EndIf
	ElseIf lEditShape
		nPosTmp1 := aScan(Self:aShapesUt, {|x| Self:oPnlModel:ShapeAtu == x[1] })
		If nPosTmp1 > 0
			cDesc := Self:aShapesUt[nPosTmp1][3][2]
		Else
			If Self:nTipoLaudo != 5
				Return .F.
			EndIf
		EndIf
	EndIf

	Self:SetBlackPnl(.T.)

	DEFINE MSDIALOG oDlgDfField FROM 0,0 TO 405,650 OF SELF ;
	COLOR CLR_BLACK,CLR_WHITE STYLE nOr(DS_SYSMODAL,WS_MAXIMIZEBOX,WS_POPUP) PIXEL

		oPnlField := Self:LoadBg(oDlgDfField)

		@ 010,015 SAY OemToAnsi(If(Self:nTipoLaudo==5,STR0021,STR0004)) OF oPnlField PIXEL //"Texto" //"Objetivo"
		oScrollBox  := TScrollBox():New(oPnlField,020,015,170,300,.T.,.T.,.F.)
		oDesc       := TMultiGet():Create(oScrollBox,{|u| If(Pcount() > 0, cDesc := u, cDesc)},000,000,000,000, , , , , ,.T.)
		oDesc:Align := CONTROL_ALIGN_ALLCLIENT
		oDesc:SetFocus()

		@ 198,120 BUTTON oBtnInic   Prompt STR0012 SIZE 45,11 OF oPnlField PIXEL ACTION ( lRet := .T., If(Self:VldTexto(cDesc,If(Self:nTipoLaudo==5,STR0021,STR0004)),oDlgDfField:End(),lRet := .F.) ) //"Confirmar"
		@ 198,170 BUTTON oBtnCancel Prompt STR0013  SIZE 45,11 OF oPnlField PIXEL ACTION ( lRet := .F., oDlgDfField:End() ) //"Cancelar"

	ACTIVATE MSDIALOG oDlgDfField CENTERED

	If lRet

		//-- Alimenta array aObjAtu com as definições informadas
		aAdd(Self:aObjAtu,Array(1))
		Self:aObjAtu[4][1] := cDesc

	Else
		Self:lCreate := .F.
		Self:aObjAtu := {}
	EndIf

	Self:SetBlackPnl(.F.)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³LoadCpn          ³Autor³ Denis               ³Data³02/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carrega opções disponíveis, conforme o modelo especificado,  ³±±
±±³          ³na barra de opções.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTA210                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method DefinePagina(aArrAuto) Class TNGLAUDO

	Default aArrAuto := {}

	aAdd(Self:aObjAtu,Array(1))
	Self:aObjAtu[4][1] := "QUEBRA PAGINA"

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³LoadCpn          ³Autor³ Denis               ³Data³02/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carrega opções disponíveis, conforme o modelo especificado,  ³±±
±±³          ³na barra de opções.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTA210                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method DefineLabel(aArrAuto,lEditShape) Class TNGLAUDO

	Local oPnlField, oBtnInic
	Local l_Bold  := .F.
	Local l_Under := .F.
	Local l_Centr := .F.
	Local lRet    := .F.
	Local cTipInd := "0"
	Local aTipInd := {STR0023,STR0024,STR0025,STR0026,STR0027} //"0=Não adicionar"###"1=Título 1"###"2=Título 2"###"3=Título 3"###"4=Título 4"
	Default aArrAuto := {}

	cTitleFld := Space(100)

	If Len(aArrAuto) > 0
		cTitleFld := aArrAuto[1]
		If !Empty(cTitleFld)
		//-- Alimenta array aObjAtu com as definições informadas
			aAdd(Self:aObjAtu,Array(5))
			Self:aObjAtu[4][1] := AllTrim(cTitleFld)
			Self:aObjAtu[4][2] := aArrAuto[2] //lNegrito
			Self:aObjAtu[4][3] := aArrAuto[3] //lCentro
			Self:aObjAtu[4][4] := aArrAuto[4] //lSublin
			Self:aObjAtu[4][5] := aArrAuto[5] //nIndice
			Return .T.
		Else
			Return .F.
		EndIf
	ElseIf lEditShape
		nPosTmp1 := aScan(Self:aShapesUt, {|x| Self:oPnlModel:ShapeAtu == x[1] })
		If nPosTmp1 > 0
			cTitleFld := Self:aShapesUt[nPosTmp1][3][2]
			l_Bold    := Self:aShapesUt[nPosTmp1][3][3]
			l_Centr   := Self:aShapesUt[nPosTmp1][3][4]
			l_Under   := Self:aShapesUt[nPosTmp1][3][5]
			cTipInd   := Str(Self:aShapesUt[nPosTmp1][3][6],1)
		Else
			Return .F.
		EndIf
	EndIf

	Self:SetBlackPnl(.T.)

	DEFINE MSDIALOG oDlgDfField FROM 0,0 TO 205,360 OF SELF ;
	COLOR CLR_BLACK,CLR_WHITE STYLE nOr(DS_SYSMODAL,WS_MAXIMIZEBOX,WS_POPUP) PIXEL

		oPnlField := Self:LoadBg(oDlgDfField)

		@ 013.5,15 SAY OemToAnsi(STR0006) OF oPnlField PIXEL //"Título"
		oScrollBox  := TScrollBox():New(oPnlField,026,015,30,160,.T.,.T.,.F.)
		oDesc       := TMultiGet():Create(oScrollBox,{|u| If(Pcount() > 0, cTitleFld := u, cTitleFld)},000,000,000,000, , , , , ,.T.)
		oDesc:Align := CONTROL_ALIGN_ALLCLIENT
		oDesc:SetFocus()

		@ 059,015 CHECKBOX oNegrito VAR l_Bold  PROMPT STR0028 SIZE 80,10 OF oPnlField PIXEL //"Negrito"
		@ 059,065 CHECKBOX oUnderli VAR l_Centr PROMPT STR0029 SIZE 80,10 OF oPnlField PIXEL //"Centralizado"
		@ 059,115 CHECKBOX oUnderli VAR l_Under PROMPT STR0030 SIZE 80,10 OF oPnlField PIXEL //"Sublinhado"

		If Self:nTipoLaudo == 1 .Or. Self:nTipoLaudo == 2 .Or. Self:nTipoLaudo == 6 .Or. Self:nTipoLaudo == 7 .Or. Self:nTipoLaudo == 12
			@ 075.5,15 SAY OemToAnsi(STR0031) OF oPnlField PIXEL //"Adicionar ao índice como:"
			@ 74,085   COMBOBOX oCbxAtal VAR cTipInd Items aTipInd SIZE 60,60 PIXEL OF oPnlField
		EndIf

		@ 98,43  BUTTON oBtnInic   Prompt STR0012 SIZE 45,11 OF oPnlField PIXEL ACTION ( lRet := .T., If(Self:VldTexto(cTitleFld,STR0006),oDlgDfField:End(),lRet := .F.) ) //"Confirmar"
		@ 98,93  BUTTON oBtnCancel Prompt STR0013  SIZE 45,11 OF oPnlField PIXEL ACTION ( lRet := .F., oDlgDfField:End() ) //"Cancelar"

	ACTIVATE MSDIALOG oDlgDfField CENTERED


	Self:SetBlackPnl(.F.)

	If lRet
		aAdd(Self:aObjAtu,Array(5))
		Self:aObjAtu[4][1] := AllTrim(cTitleFld)
		Self:aObjAtu[4][2] := l_Bold //lNegrito
		Self:aObjAtu[4][3] := l_Centr //lCentro
		Self:aObjAtu[4][4] := l_Under //lSublin
		Self:aObjAtu[4][5] := Val(Substr(cTipInd,1,1)) //nIndice
	Else
		Self:lCreate := .F.
		Self:aObjAtu := {}
	EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³ DefineArquivo   ³Autor³ Denis               ³Data³02/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Tela de montagem de imagem/documentos para o laudo.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTA210                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method DefineArquivo(aArrAuto,cTipo,lEditShape) Class TNGLAUDO

	Local nPosBar	:= 0
	Local nPosPon	:= 0
	Local lRet := .F.
	Local lTem := .F.
	Local cMask
	Local cPathImg := Alltrim(GetMv("MV_DIRACA"))			// Path dos arquivos no Servidor
	Local cBarraSrv := If( IsSrvUnix() , "/" , "\" )
	Local cBarraRem := If( GetRemoteType() == 2, "/", "\")
	Local cArqImg	:= ""
	Default aArrAuto := {}

	cMask := 	STR0032+" |*.bmp|"+; //"Arquivos Bitmap"
				STR0033+"|*.jpg|"+; //"Arquivos JPG"
				STR0034+"|*.jpeg|"+; //"Arquivos JPEG"
				STR0035+"|*.png|"+; //"Arquivos PNG"
				STR0036+"|*.gif|" //"Arquivos GIF"
	//STR0037+" (*.*)|*.*|" //"Todos os Arquivos"

	If cTipo == "DOC"
		cMask := 	STR0038+" (*.doc)|*.doc|"+; //"Documento do Word 97-2003"
					STR0039+" (*.docx)|*.docx|"+; //"Documento do Word"
					STR0040+" (*.txt)|*.txt|"+; //"Arquivos Texto"
					STR0153+" (*.pdf)|*.pdf|" //"Arquivos PDF"
	EndIf

	If Len(aArrAuto) > 0
		cTitleFld := aArrAuto[1]
	Else
		Self:SetBlackPnl(.T.)
		cTitleFld := cGetFile(cMask,OemToAnsi(STR0041),0,"",.T.,GETF_LOCALHARD) //"Selecione o Arquivo" GETF_ONLYSERVER
		lTem := .T.
	EndIf

	If !Empty(cTitleFld) .And. File(cTitleFld)
		cPathImg += If( Substr( cPathImg , Len( cPathImg ) , 1 ) != cBarraSrv , cBarraSrv , "" )

		nPosBar := RAt( cBarraSrv , cTitleFld )

		If nPosBar > 0
			cArqImg := SubStr( cTitleFld , nPosBar + 1 )
		Else
			If cBarraRem <> cBarraSrv
				nPosBar := RAt( cBarraRem , cTitleFld )
				If nPosBar > 0
					cArqImg := SubStr( cTitleFld , nPosBar + 1 )
				Else
					cArqImg := cTitleFld
				EndIf
			Else
				cArqImg := cTitleFld
			EndIf
		EndIf

		nPosPon  := RAt( "." , cArqImg )

		If nPosPon > 0 .And. SubStr( cTitleFld , 1 , nPosBar ) <> cPathImg
			cArqImg := SubStr( cArqImg , 1 , nPosPon - 1 )	+ DtoS( dDataBase ) + StrTran( Time() , ":" , "" ) + SubStr( cArqImg , nPosPon )
		EndIf

		If AllTrim( cTitleFld ) <> AllTrim( cPathImg + cArqImg )
			If File( cPathImg + cArqImg )
				Ferase( cPathImg + cArqImg )
			EndIf

			__CopyFile( cTitleFld , cPathImg + cArqImg )
		EndIf

		cTitleFld := cPathImg + cArqImg

		lRet := .T.
		//-- Alimenta array aObjAtu com as definições informadas
		aAdd(Self:aObjAtu, Array(1))
		Self:aObjAtu[4][1] := AllTrim(cTitleFld)
	Else
		//-- Define que o objeto não será criado ao acionar o click na area do paintpanel
		Self:lCreate := .F.
		Self:aObjAtu := {}
	EndIf

	If lTem
		Self:SetBlackPnl(.F.)
	EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³ PaintClick      ³Autor³ Denis               ³Data³02/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carrega opções disponíveis, conforme o modelo especificado,  ³±±
±±³          ³na barra de opções.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTA210                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method PaintClick(nPosX,nPosY,lDfnCpo,lEditShape,lForcaMov) Class TNGLAUDO

	Local nPosShape, nIdCampo := 0, nDif := 0
	Local cShpAtb, cShpAtb2
	Local nPontoC := Self:nWidthArea / 2
	Local nPosTmp1,nPosTmp2,nPosMin,nPosMax,aTemp1,aTemp2,nFor,nFor2,nPosTmpS:=0,nLinha,nLinhasMemo
	Local nTempY := 0
	Local nTempX := 0
	Local aTipos := {}
	Local cTempID := ""
	Local lTrocaPos := .F.
	Local cMoveImg := "1"
	If !Inclui .And. !Altera
		cMoveImg := "0"
	EndIf

	If ValType(lForcaMov) == "L" .And. lForcaMov
		lTrocaPos := .T.
	EndIf

	Default lEditShape := .F.
	Default lDfnCpo := .T.

	aAdd( aTipos , { "Atalho"	, STR0005			} ) //"Atalho"
	aAdd( aTipos , { "Texto"	, If(Self:nTipoLaudo==5,STR0021,STR0004)	} ) //"Texto" //"Objetivo"
	aAdd( aTipos , { "Titulo"	, STR0006			} ) //"Título"
	aAdd( aTipos , { "Imagem"	, STR0007			} ) //"Imagem"
	aAdd( aTipos , { "Arquivo"	, STR0008			} ) //"Arquivo"
	aAdd( aTipos , { "Pagina"	, STR0009	} ) //"Quebra de Página"

	Private lFocus := .F.
	Private aPropShpAt := {}

	If Len(Self:aObjAtu) > 0 .And. ValType(Self:aObjAtu[1]) == "O" .And. !lTrocaPos

		If Self:lCreate

			If lDfnCpo
				If !Self:DefineCpn()
					Return
				EndIf
			EndIf

			If lEditShape
				nPosTmpS := aScan(Self:aShapesUt, {|x| Self:oPnlModel:ShapeAtu == x[1] })
				If nPosTmpS > 0
					cTempID := cValToChar(Self:oPnlModel:ShapeAtu)
					nIdCampo := Self:oPnlModel:ShapeAtu
					nPosY := Self:aShapesUt[nPosTmpS,5]
					Self:oPnlModel:DeleteItem(Self:aShapesUt[nPosTmpS,1])
					For nFor2 := 1 To Len(Self:aShapesUt[nPosTmpS,10])
						Self:oPnlModel:DeleteItem( Self:aShapesUt[nPosTmpS][10][nFor2][1] )
					Next nFor2
				EndIf
			EndIf

			cShpAtb := ""
			If Self:aObjAtu[3] == "Atalho"
				If nPosTmpS == 0
					cTempID := cValToChar(Self:SetIdShp())
					nIdCampo := Self:nIdShp
				EndIf
				nWidth := Len(Self:aObjAtu[4][1])*(_nPix+1)
				If nWidth > (Self:oPnlModel:nWidth-(nPosX+90))
					nWidth := Self:oPnlModel:nWidth-(nPosX+90)
				EndIf

				cShpAtb := "id=" + cTempID + ";type=" + cValToChar(Self:aObjAtu[2]) +  ;
					";left=" + cValToChar(nPosX+90) + ";top=" + cValToChar(nPosY+10) + ";gradient=0,0,0,0,0,0,#000000;" + ;
					"can-mark=1;can-move="+cMoveImg+";can-deform=1;is-container=0;pen-width=1;"
				cShpAtb   += "width=" + cValToChar(nWidth) + ";height=20;" + ;
					"pen-color=#000000;text=" + Self:aObjAtu[4][1] + ";font=Arial,8,0,0,1;"

				aPropShpAt := Array(3)
				aPropShpAt[1] := Len(Self:aObjAtu[4][1])*(_nPix+1)
				aPropShpAt[2] := Self:aObjAtu[4][1]
				aPropShpAt[3] := Self:aObjAtu[4][2]

				nTempY := 10
				nTempX := nPosX+90

			ElseIf Self:aObjAtu[3] == "Texto" //-- Caso o componente solicitado seja um Texto
				If nPosTmpS == 0
					cTempID := cValToChar(Self:SetIdShp())
					nIdCampo := Self:nIdShp
				EndIf

				cTextID := " "
				nLinhasMemo := MLCOUNT(Self:aObjAtu[4][1],200)
				For nLinha := 1 to nLinhasMemo
					cTextTemp := MemoLine(Self:aObjAtu[4][1],200,nLinha)
					If !Empty(cTextTemp)
						cTextID := Alltrim(cTextTemp)+" "
						Exit
					EndIf
				Next nLinha

				nWidth  := Len(cTextID)*_nPix
				nSubTxt := Len(cTextID)
				If nWidth > (Self:oPnlModel:nWidth-(nPosX+90))
					nWidth := Self:oPnlModel:nWidth-(nPosX+90)
					nSubTxt := Int(nWidth/_nPix)
				EndIf

				cShpAtb := "id=" + cTempID + ";type=" + cValToChar(Self:aObjAtu[2]) +  ;
					";left=" + cValToChar(nPosX+90) + ";top=" + cValToChar(nPosY+10) + ";gradient=0,0,0,0,0,0,#000000;" + ;
					"can-mark=1;can-move="+cMoveImg+";can-deform=1;is-container=0;pen-width=1;"
					cShpAtb += "width=" + cValToChar(nWidth) + ";height=20;" + ;
					"pen-color=#000000;text=" + Substr(cTextID,1,nSubTxt) + ";font=Arial,8,0,0,1;"

				aPropShpAt := Array(2)
				aPropShpAt[1] := 50
				aPropShpAt[2] := Self:aObjAtu[4][1]

				nTempY := 10
				nTempX := nPosX+90

			ElseIf Self:aObjAtu[3] == "Titulo" //-- Caso o componente solicitado seja um Titulo
				nTmpX := nPosX+90
				If nPosTmpS == 0
					cTempID := cValToChar(Self:SetIdShp())
					nIdCampo := Self:nIdShp
				EndIf
				nWidth := ( Len(Self:aObjAtu[4][1]) * 9.1 ) + If(Self:aObjAtu[4][2],10,1)
				If nWidth > (Self:oPnlModel:nWidth-nTmpX)
					nWidth := Self:oPnlModel:nWidth-nTmpX
				EndIf
				cShpAtb := "id=" + cTempID + ";type=" + cValToChar(Self:aObjAtu[2]) +  ;
					";left=" + cValToChar(nTmpX) + ";top=" + cValToChar(nPosY+10) + ";gradient=0,0,0,0,0,0,#000000;" + ;
					"can-mark=1;can-move="+cMoveImg+";can-deform=1;is-container=0;pen-width=1;"
					cShpAtb += "width=" + cValToChar(nWidth) + ";height=20;" + ;
						"pen-color=#000000;text=" + Self:aObjAtu[4][1] + ";font=Arial,10,"+;
						If(Self:aObjAtu[4][2],"1","0")+",0,1;"

				aPropShpAt := Array(6)
				aPropShpAt[1] := 50
				aPropShpAt[2] := Self:aObjAtu[4][1]
				aPropShpAt[3] := Self:aObjAtu[4][2]
				aPropShpAt[4] := Self:aObjAtu[4][3]
				aPropShpAt[5] := Self:aObjAtu[4][4]
				aPropShpAt[6] := Self:aObjAtu[4][5]

				nTempY := 10
				nTempX := nTmpX

			ElseIf Self:aObjAtu[3] == "Imagem" //-- Caso o componente solicitado seja uma Imagem
				If nPosTmpS == 0
					cTempID := cValToChar(Self:SetIdShp())
					nIdCampo := Self:nIdShp
				EndIf
				nTmpX := Len(Alltrim(Self:aObjAtu[4][1]))*_nPix/2
				cDirImg := Self:ExportImage("ngicoimg.png")
				cShpAtb := "id=" + cTempID + ";type=" + cValToChar(Self:aObjAtu[2]) +  ;
					";left=" + cValToChar(nPosX+90) + ";top=" + cValToChar(nPosY+3) + ";" + ;
					"width=41;height=41;Image-file="+cDirImg+";can-mark=1;can-move="+cMoveImg+";can-deform=1;is-container=1;"

				aPropShpAt := Array(2)
				aPropShpAt[1] := 50
				aPropShpAt[2] := Self:aObjAtu[4][1]

				nTempY := 3
				nTempX := nPosX+90

			ElseIf Self:aObjAtu[3] == "Arquivo" //-- Caso o componente solicitado seja um Arquivo Txt ou Doc
				If nPosTmpS == 0
					cTempID := cValToChar(Self:SetIdShp())
					nIdCampo := Self:nIdShp
				EndIf
				nTmpX := Len(Alltrim(Self:aObjAtu[4][1]))*_nPix/2

				//left=" + cValToChar(nPontoC-nTmpX-50)
				If ".TXT" $ Upper(Alltrim(Self:aObjAtu[4][1]))
					cDirImg := Self:ExportImage("ngiconote.png")
					cShpAtb := "id=" + cTempID + ";type=" + cValToChar(Self:aObjAtu[2]) +  ;
						";left=" + cValToChar(nPosX+90) + ";top=" + cValToChar(nPosY+3) + ";" + ;
						"width=41;height=41;Image-file="+cDirImg+";can-mark=1;can-move="+cMoveImg+";can-deform=1;is-container=0;"
				Else
					cDirImg := Self:ExportImage("ngicoword.png")
					cShpAtb := "id=" + cTempID + ";type=" + cValToChar(Self:aObjAtu[2]) +  ;
						";left=" + cValToChar(nPosX+90) + ";top=" + cValToChar(nPosY+3) + ";" + ;
											"width=41;height=41;Image-file="+cDirImg+";can-mark=1;can-move="+cMoveImg+";can-deform=1;is-container=0;"
				EndIf

				aPropShpAt := Array(2)
				aPropShpAt[1] := 50
				aPropShpAt[2] := Self:aObjAtu[4][1]

				nTempY := 3
				nTempX := nPosX+90

			ElseIf Self:aObjAtu[3] == "Pagina" //-- Caso o componente solicitado seja uma Quebra Pagina

				nWidth := Self:oPnlModel:nWidth-15
				If nWidth > (Self:oPnlModel:nWidth-(nPosX+90))
					nWidth := Self:oPnlModel:nWidth-(nPosX+90)
				EndIf

				cShpAtb := "id=" + cValToChar(Self:SetIdShp()) + ;
					";type=1;left=" + cValToChar(nPosX+90) + ;
					";top=" + cValToChar(nPosY+17) + ";width=" + cValToChar(nWidth) + ";height=" + cValToChar(5) + ";"+;
					"gradient=1,0,0,0,0,0.0,#1874CD;pen-width=1;"+;
					"pen-color=#1874CD;can-move="+cMoveImg+";can-mark=1;is-container=0;"

				nIdCampo := Self:nIdShp
				nTempY := 17
				nTempX := nPosX+90

			EndIf

			// -- Adicionando Shape no Panel
			If !Empty(cShpAtb)

				If !(lEditShape .And. nPosTmpS > 0)
					aGradTmp := Array(4)
					aGradTmp[1] := Self:SetIdShp()
					aGradTmp[2] := Self:SetIdShp()
					aGradTmp[3] := Self:SetIdShp()
					aGradTmp[4] := Self:SetIdShp()
					Self:oPnlModel:AddShape("id=" + cValToChar(aGradTmp[1]) + ";type=9;can-move=0;pen-color=#1874CD;" + ;
						"gradient=0,0,0,0,0,0,#1874CD;pen-width=1;can-mark=0;is-container=0;" + ;
						"from-left=" + cValToChar(0) + ";from-top=" + cValToChar(nPosY+40) + ;
						";to-left=" + cValToChar(Self:nWidthArea) + ";to-top=" + cValToChar(nPosY+40) + ";")
					Self:oPnlModel:AddShape("id=" + cValToChar(aGradTmp[2]) + ";type=9;can-move=0;pen-color=#1874CD;" + ;
						"gradient=0,0,0,0,0,0,#1874CD;pen-width=1;can-mark=0;is-container=0;" + ;
						"from-left=" + cValToChar(55) + ";from-top=" + cValToChar(nPosY) + ;
						";to-left=" + cValToChar(55) + ";to-top=" + cValToChar(nPosY+40) + ";")
					Self:oPnlModel:AddShape("id=" + cValToChar(aGradTmp[3]) + ";type=9;can-move=0;pen-color=#1874CD;" + ;
						"gradient=0,0,0,0,0,0,#1874CD;pen-width=1;can-mark=0;is-container=0;" + ;
						"from-left=" + cValToChar(150) + ";from-top=" + cValToChar(nPosY) + ;
						";to-left=" + cValToChar(150) + ";to-top=" + cValToChar(nPosY+40) + ";")
					Self:oPnlModel:AddShape("id=" + cValToChar(aGradTmp[4]) + ";type=7;left=" + cValToChar(5) + ;
						";top=" + cValToChar(nPosY+10) + ";gradient=0,0,0,0,0,0,#000000;" + ;
						"can-mark=0;can-move=0;can-deform=0;is-container=0;pen-width=1;" + ;
						"width=35;height=20;pen-color=#000000;text=" + cValToChar(Len(Self:aShapesUt)+1) + ";font=Arial,8,0,0,1;")
					aAdd( Self:aGradeSh , aGradTmp )
				EndIf

				Self:oPnlModel:addShape(cShpAtb)
				Self:lCreate := .F.

				If !(lEditShape .And. nPosTmpS > 0)
					aAdd(Self:aShapesUt,Array(10))
					nPosShape := Len(Self:aShapesUt)
					Self:aShapesUt[nPosShape][2] := cValToChar(Self:aObjAtu[2]) //Type Shape
					Self:aShapesUt[nPosShape][5] := nPosY //Top ini
					Self:aShapesUt[nPosShape][6] := Self:aObjAtu[3] //Tipo (Imagem, Titulo....)
					Self:aShapesUt[nPosShape][7] := nPosY+40 //Top fim
					Self:aShapesUt[nPosShape][8] := nTempY
					Self:aShapesUt[nPosShape][9] := nil //Grades da linha
				Else
					nPosShape := nPosTmpS
				EndIf
				Self:aShapesUt[nPosShape][1] := If(nIdCampo > 0, nIdCampo, Self:nIdShp) //ID do Shape
				Self:aShapesUt[nPosShape][3] := aPropShpAt //Propriedades
				Self:aShapesUt[nPosShape][4] := nTempX //Left
				Self:aShapesUt[nPosShape][10]:= {} //Componentes da linha

				lFocus := .T.
				Self:oPnlModel:ShapeAtu := If(nIdCampo > 0, nIdCampo, Self:nIdShp)

				// -- Adicionando Tipo na linha
				cTipoVar := " "
				nTmp01   := aScan(aTipos, {|x| Self:aObjAtu[3] == x[1] })
				If nTmp01 > 0
					cTipoVar := aTipos[nTmp01,2]
				EndIf
				cShpAtb2 := "id=" + cValToChar(Self:SetIdShp()) + ";type=7;left=" + cValToChar(60) + ;
					";top=" + cValToChar(nPosY+10) + ";gradient=0,0,0,0,0,0,#000000;" + ;
					"can-mark=0;can-move=0;can-deform=0;is-container=0;pen-width=1;"
				cShpAtb2 += "width=80;height=20;pen-color=#000000;text=" + cTipoVar + ";font=Arial,8,0,0,1;"
				Self:oPnlModel:addShape(cShpAtb2)
				Self:lCreate := .F.
				aShpTmp := Array(3)
				//nPosShape := Len(Self:aShapesUt)
				aShpTmp[1] := Self:nIdShp
				aShpTmp[2] := 60
				aShpTmp[3] := 10
				aAdd( Self:aShapesUt[nPosShape][10] , aShpTmp )

				// -- Adicionando Nome do arquivo/imagem na linha
				If Self:aObjAtu[3] $ "Imagem/Arquivo"
					nTmpX := Len(Alltrim(Self:aObjAtu[4][1]))*_nPix/2
					nWidth := Len(Self:aObjAtu[4][1])*_nPix
					If nWidth > (Self:oPnlModel:nWidth-(nPosX+90+50))
						nWidth := Self:oPnlModel:nWidth-(nPosX+90+50)
					EndIf

					cShpAtb2 := "id=" + cValToChar(Self:SetIdShp()) + ";type=7;left=" + cValToChar(nPosX+90+50) + ; //nPontoC-nTmpX
						";top=" + cValToChar(nPosY+10) + ";gradient=0,0,0,0,0,0,#000000;" + ;
						"can-mark=0;can-move=0;can-deform=0;is-container=0;pen-width=1;"
					cShpAtb2 += "width=" + cValToChar() + ";height=20;" + ;
						"pen-color=#000000;text=" + Self:aObjAtu[4][1] + ";font=Arial,8,0,0,1;"
					Self:oPnlModel:addShape(cShpAtb2)
					Self:lCreate := .F.
					aShpTmp := Array(3)
					//nPosShape := Len(Self:aShapesUt)
					aShpTmp[1] := Self:nIdShp
					aShpTmp[2] := nPosX+90+50 //nPontoC-nTmpX
					aShpTmp[3] := 10
					aAdd( Self:aShapesUt[nPosShape][10] , aShpTmp )
				EndIf

				Self:aObjAtu := {}
			EndIf

			nPosMax := (Len(Self:aShapesUt)+1.2)*40
			If nPosMax > Self:oPnlModel:nHeight
				Self:oPnlModel:SetUpdatesEnabled(.F.)
				Self:oScrollMd:Reset()
				Self:oPnlModel:nHeight       := nPosMax
				Self:oPnlModel:nBottom       := nPosMax
				Self:oPnlModel:nClientHeight := nPosMax
				Self:oPnlModel:Refresh()
				Self:oPnlModel:SetUpdatesEnabled(.T.)

			EndIf
		EndIf

		//Tira o foco do shape em movimento
		Self:oPnlModel:SetPosition(__nIdAux,0,0)
		Self:lIsMoving := .F.

	ElseIf Self:oPnlModel:ShapeAtu > 0

		nPosTmp1 := aScan(Self:aShapesUt, {|x| Self:oPnlModel:ShapeAtu == x[1] })

		If nPosTmp1 > 0
			If Self:lIsMoving
				Self:lIsMoving := .F.

				//Se movimentou para outra linha
				nPosTmp2 := aScan(Self:aShapesUt, {|x| nPosY >= x[5] .And. nPosY <= x[7] })
				If nPosTmp2 > 0 .And. nPosTmp2 <> nPosTmp1
					aTemp1 := aClone(Self:aShapesUt[nPosTmp1])
					aTemp2 := aClone(Self:aShapesUt[nPosTmp2])

					nPosMin  := Min(nPosTmp1,nPosTmp2)
					nPosMax  := Max(nPosTmp1,nPosTmp2)

					lDesceu  := (nPosMin == nPosTmp1)
					nValStep := If(lDesceu,1,-1)
					nValInic := If(lDesceu,nPosMin,nPosMax)
					nValFina := If(lDesceu,nPosMax,nPosMin)

					For nFor := nValInic To nValFina Step nValStep
						If nFor == nPosTmp2
							Loop
						Else
							nTopTemp1 := Self:aShapesUt[nFor,5]
							nTopTemp2 := Self:aShapesUt[nFor,7]
							If lDesceu
								Self:aShapesUt[nFor] := aClone(Self:aShapesUt[nFor+1])
							Else
								Self:aShapesUt[nFor] := aClone(Self:aShapesUt[nFor-1])
							EndIf
							Self:aShapesUt[nFor,5] := nTopTemp1
							Self:aShapesUt[nFor,7] := nTopTemp2
							Self:oPnlModel:SetPosition(Self:aShapesUt[nFor][1],Self:aShapesUt[nFor][4],Self:aShapesUt[nFor,5]+Self:aShapesUt[nFor,8])
							For nFor2 := 1 To Len(Self:aShapesUt[nFor,10])
								If Len(Self:aShapesUt[nFor,10,nFor2]) > 3
									nDiff := nTopTemp1 - Self:aShapesUt[nFor][10][nFor2][4]
									Self:oPnlModel:SetPosition(	Self:aShapesUt[nFor][10][nFor2][1],;
																0,;
																nDiff)
								Else
									Self:oPnlModel:SetPosition(	Self:aShapesUt[nFor][10][nFor2][1],;
																Self:aShapesUt[nFor][10][nFor2][2],;
																Self:aShapesUt[nFor,5]+Self:aShapesUt[nFor][10][nFor2][3])
								EndIf
							Next nFor2
						EndIf
					Next nFor

					nTopTemp1 := Self:aShapesUt[nPosTmp2,5]
					nTopTemp2 := Self:aShapesUt[nPosTmp2,7]
					Self:aShapesUt[nPosTmp2] := aClone(aTemp1)
					Self:aShapesUt[nPosTmp2,5] := nTopTemp1
					Self:aShapesUt[nPosTmp2,7] := nTopTemp2

					nCpnt := aScan(Self:aCpnts, {|x| Self:aShapesUt[nPosTmp2][6] == x[3] })
					If nCpnt > 0// .And. .F.
						Self:aObjAtu := aClone(Self:aCpnts[nCpnt])
						Self:lCreate := .T. //-- Indicando a criação do objeto ao acionar o evento click do paintpanel
						If nCpnt == 1 //TEXTO
							//-- Alimenta array aObjAtu com as definições informadas
							aAdd(Self:aObjAtu,Array(1))
							Self:aObjAtu[4][1] := Self:aShapesUt[nPosTmp2][3][2]
						ElseIf nCpnt == 2 //ATALHO
						//-- Alimenta array aObjAtu com as definições informadas
							aAdd(Self:aObjAtu, Array(4))
							Self:aObjAtu[4][1] := AllTrim(Self:aShapesUt[nPosTmp2][3][2])
							Self:aObjAtu[4][2] := AllTrim(Self:aShapesUt[nPosTmp2][3][3])
						ElseIf nCpnt == 3 //TITULO
							aAdd(Self:aObjAtu,Array(5))
							Self:aObjAtu[4][1] := AllTrim(Self:aShapesUt[nPosTmp2][3][2])
							Self:aObjAtu[4][2] := Self:aShapesUt[nPosTmp2][3][3] //lNegrito
							Self:aObjAtu[4][3] := Self:aShapesUt[nPosTmp2][3][4] //lCentro
							Self:aObjAtu[4][4] := Self:aShapesUt[nPosTmp2][3][5] //lSublin
							Self:aObjAtu[4][5] := Self:aShapesUt[nPosTmp2][3][6] //nIndice
						ElseIf nCpnt == 4 .or. nCpnt == 5 //ARQUIVO
							//-- Alimenta array aObjAtu com as definições informadas
							aAdd(Self:aObjAtu, Array(1))
							Self:aObjAtu[4][1] := AllTrim(Self:aShapesUt[nPosTmp2][3][2])
						EndIf
						Self:lCreate := .T.
						Self:PaintClick(70, Self:aShapesUt[nPosTmp2,5]+Self:aShapesUt[nPosTmp2,8], .F., .T. )
						Return
					Else
						Self:oPnlModel:SetPosition(Self:aShapesUt[nPosTmp2][1],Self:aShapesUt[nPosTmp2][4],Self:aShapesUt[nPosTmp2,5]+Self:aShapesUt[nPosTmp2,8])
						For nFor2 := 1 To Len(Self:aShapesUt[nPosTmp2,10])
							If Len(Self:aShapesUt[nPosTmp2,10,nFor2]) > 3
								nDiff := nTopTemp1 - Self:aShapesUt[nPosTmp2][10][nFor2][4]
								Self:oPnlModel:SetPosition(	Self:aShapesUt[nPosTmp2][10][nFor2][1],;
															0,;
															nDiff)
							Else
								Self:oPnlModel:SetPosition(	Self:aShapesUt[nPosTmp2][10][nFor2][1],;
															Self:aShapesUt[nPosTmp2][10][nFor2][2],;
															Self:aShapesUt[nPosTmp2,5]+Self:aShapesUt[nPosTmp2][10][nFor2][3])
							EndIf
						Next nFor2
					EndIf
				Else
					nCpnt := aScan(Self:aCpnts, {|x| Self:aShapesUt[nPosTmp1][6] == x[3] })
					If nCpnt > 0
						Self:aObjAtu := aClone(Self:aCpnts[nCpnt])
						Self:lCreate := .T. //-- Indicando a criação do objeto ao acionar o evento click do paintpanel
						If nCpnt == 1 //TEXTO
							//-- Alimenta array aObjAtu com as definições informadas
							aAdd(Self:aObjAtu,Array(1))
							Self:aObjAtu[4][1] := Self:aShapesUt[nPosTmp1][3][2]
						ElseIf nCpnt == 2 //ATALHO
						//-- Alimenta array aObjAtu com as definições informadas
							aAdd(Self:aObjAtu, Array(4))
							Self:aObjAtu[4][1] := AllTrim(Self:aShapesUt[nPosTmp1][3][2])
							Self:aObjAtu[4][2] := AllTrim(Self:aShapesUt[nPosTmp1][3][3])
						ElseIf nCpnt == 3 //TITULO
							aAdd(Self:aObjAtu,Array(5))
							Self:aObjAtu[4][1] := AllTrim(Self:aShapesUt[nPosTmp1][3][2])
							Self:aObjAtu[4][2] := Self:aShapesUt[nPosTmp1][3][3] //lNegrito
							Self:aObjAtu[4][3] := Self:aShapesUt[nPosTmp1][3][4] //lCentro
							Self:aObjAtu[4][4] := Self:aShapesUt[nPosTmp1][3][5] //lSublin
							Self:aObjAtu[4][5] := Self:aShapesUt[nPosTmp1][3][6] //nIndice
						ElseIf nCpnt == 4 .or. nCpnt == 5 //ARQUIVO
							//-- Alimenta array aObjAtu com as definições informadas
							aAdd(Self:aObjAtu, Array(1))
							Self:aObjAtu[4][1] := AllTrim(Self:aShapesUt[nPosTmp1][3][2])
						EndIf
						Self:lCreate := .T.
						Self:PaintClick(70, Self:aShapesUt[nPosTmp1,5]+Self:aShapesUt[nPosTmp1,8], .F., .T. )
						Return
					Else
						Self:oPnlModel:SetPosition( Self:aShapesUt[nPosTmp1][1],;
													Self:aShapesUt[nPosTmp1][4],;
													Self:aShapesUt[nPosTmp1,5]+Self:aShapesUt[nPosTmp1,8])
					EndIf
				EndIf
				//Tira o foco do shape em movimento
				Self:oPnlModel:SetPosition(__nIdAux,0,0)
			Else
				Self:lIsMoving := .T.
			EndIf
		Else

			Self:lIsMoving := .F.
		EndIf

	EndIf

	Self:LoadProp(Self:oPnlModel:ShapeAtu)
	aPropShpAt := {}

Return NIl

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TrocaItem ³Autor³ Denis                  ³ Data ³18/02/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Troca a ordem do item                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Genérico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method TrocaItem(nIdAt) Class TNGLAUDO

	Local nPosTmp1 := aScan(Self:aShapesUt, {|x| nIdAt == x[1] })

	If Self:nItemAtual <> nPosTmp1 .And. Self:nItemAtual >= 1 .And. Self:nItemAtual <= Len(Self:aShapesUt)
		Self:oPnlModel:ShapeAtu := nIdAt
		Self:lIsMoving := .T.
		nPosY := Self:aShapesUt[Self:nItemAtual,5]+1
		Self:PaintClick(100,nPosY,,,.T.)
	EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³fNgClearFt ³Autor³ Denis                  ³ Data ³18/02/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Definicao de campos                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Genérico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method LoadBg(oWnd) Class TNGLAUDO

	Local oPanel

	oPanel := TPaintPanel():New(0,0,0,0,oWnd,.F.)
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT

	//Container do Fundo
	oPanel:addShape("id=" + cValToChar(Self:SetIdShp()) + ";type=1;left=0;top=0;" + ;
		"width=" + cValToChar(oWnd:nWidth) + ";height=" + cValToChar(oWnd:nHeight) + ;
			";gradient=1,0,0,0,180,0.0,#FFFFFF;pen-color=#FFFFFF;can-move=0;can-mark=0;is-container=1;")

	//Gradiente
	oPanel:addShape("id=" + cValToChar(Self:SetIdShp()) + ";type=1;left=1;top=1;" + ;
		"width=" + cValToChar(oWnd:nWidth - 2) + ";height=" + cValToChar(oWnd:nHeight - 2) + ;
			";gradient=1,0,0,0,360,0.0,#FFFFFF,0.1,#FFFFFF,1.0,#CFCFCF;"  + ;
				"pen-width=0;pen-color=#FFFFFF;can-move=0;can-mark=0;is-container=1;")

Return oPanel

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³fNgClearFt ³Autor³ Denis                  ³ Data ³18/02/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Definicao de campos                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Genérico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fEnable

	If lChecked
		oCbxFont:Disable()
		oChkBld:Disable()
		oChkItl:Disable()
		oCbxSize:Disable()
	Else
		oChkBld:Enable()
		oChkItl:Enable()
		oCbxFont:Enable()
		oCbxSize:Enable()
	EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³ SetIdShp    ³Autor³ Denis                ³ Data ³04/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Faz controle de ID's sobre os shapes criados na planta      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especificação de Projeto                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method SetIdShp() Class TNGLAUDO
Return ++Self:nIdShp

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³ ExportImage ³Autor³ Denis                ³ Data ³10/09/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Exporta imagem do RPO p/ diretorio                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especificação de Projeto                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method ExportImage(cImage,cDirectory) Class TNGLAUDO

	Local cImageTo
	Default cDirectory := __cDirectory__

	//Cria pasta no Temp
	If !ExistDir(cDirectory)
		MakeDir(cDirectory)
	EndIf

	cImageTo := AllTrim(cDirectory+Trim(cImage))
	If !Resource2File(Trim(cImage),cImageTo)
		cImageTo := ""
	EndIf

Return cImageTo

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³ ResetPnl    ³Autor³ Denis                ³ Data ³08/12/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Redefine o painel                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method ResetPnl() Class TNGLAUDO

	Local cMemoTO0 := "",nFor

	cMemoTO0 := Self:ModToStr(Self:aShapesUt)
	Self:oPnlModel:ClearAll()
	For nFor := 1 To Len(Self:aPropCpn)
		If ValType(Self:aPropCpn[nFor]) == "O"
			Self:aPropCpn[nFor]:Free()
		EndIf
	Next nFor
	Self:aShapesUt   := {}
	Self:aGradeSh    := {}
	Self:oBtnItem:Hide()
	Self:oSayNoCpo:Show()
	If Len(Self:aPropOpc) > 0 .And. ValType(Self:aPropOpc[1]) == "O"
		Self:aPropOpc[1]:Hide()
		Self:aPropOpc[2]:Hide()
		Self:aPropOpc[3]:Hide()
		Self:aPropOpc[4]:Hide()
	EndIf
	Self:aObjAtu     := {}
	Self:nIdShp      := 0
	Self:lIsMoving   := .F.
	Self:nTipoLaudo  := Val( RETASC( M->TO0_TIPREL , 1 , .F. ) )
	Self:fShapeCabec()
	Self:LoadModel(cMemoTO0)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³ ModToStr    ³Autor³ Denis                ³ Data ³08/12/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Converte painel de array para string                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method ModToStr() Class TNGLAUDO

	Local cRet := "",nFor

	For nFor := 1 To Len(Self:aShapesUt)
		If Self:aShapesUt[nFor][6] == "Atalho"
			cRet += "@" + Self:aShapesUt[nFor][3][2] + "@" + CRLF
		ElseIf Self:aShapesUt[nFor][6] == "Texto"
			If M->TO0_TIPREL == "5"
				//Não traduzir
				cRet += "#CONCLUSAO# " + Self:aShapesUt[nFor][3][2]
			Else
				cRet += Self:aShapesUt[nFor][3][2] + CRLF
			EndIf
			If Right(Self:aShapesUt[nFor][3][2],1) <> CRLF
				cRet += CRLF
			EndIf
		ElseIf Self:aShapesUt[nFor][6] == "Titulo"
			cCNS := ""
			If Self:aShapesUt[nFor][3][3]
				cCNS += "N"
			EndIf
			If Self:aShapesUt[nFor][3][4]
				cCNS += "C"
			EndIf
			If Self:aShapesUt[nFor][3][5]
				cCNS += "S"
			EndIf
			If Self:aShapesUt[nFor][3][6] > 0
				cCNS += Str(Self:aShapesUt[nFor][3][6],1)
			EndIf
			If !Empty(cCNS)
				cRet += "#{" + cCNS + "}" + Self:aShapesUt[nFor][3][2] + "#" + CRLF
			Else
				cRet += "#" + Self:aShapesUt[nFor][3][2] + "#" + CRLF
			EndIf
		ElseIf Self:aShapesUt[nFor][6] == "Imagem"
			cRet += "@!" + Self:aShapesUt[nFor][3][2] + "!@" + CRLF
		ElseIf Self:aShapesUt[nFor][6] == "Arquivo"
			cRet += "@%" + Self:aShapesUt[nFor][3][2] + "%@" + CRLF
		ElseIf Self:aShapesUt[nFor][6] == "Pagina"
			cRet += "@PAGINA@" + CRLF
		EndIf
	Next nFor

Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BoxLaudo  ³ Autor ³ Denis                 ³ Data ³24/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna as opções de atalhos dos Laudos                     ³±±
±±³          ³ 1=PPRA;2=PCMSO;3=L.T. Pericial;4=LTCAT;5=DIRBEN 8030;       ³±±
±±³          ³ 6=PGR;7=PCMAT                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method BoxLaudo() Class TNGLAUDO

	Local aAtalhos := {}
	Local aRetPE,nFor

	// 1. PPRA ou 6. PGR
	If Self:nTipoLaudo == 1 .Or. Self:nTipoLaudo == 6

		aAdd( aAtalhos , { "LOCAL" , STR0044 } ) //"Imprimirá todos os Locais Avaliados do Laudo em questão."
		aAdd( aAtalhos , { "QUADRO LOCAL" , STR0076+Chr(13)+Chr(10)+; //"Imprimirá todos os Locais Avaliados do Laudo em questão em formato de tabela. "
							STR0077 } ) //"Obs: Este item somente será aplicado em formato de tabela no PPRA/PGR modelo Ms-Word. Nos demais modelos será apresentado em formato de texto."
		aAdd( aAtalhos , { "RISCO-RUIDO" , STR0049 } ) //"Imprimirá todos os Riscos do agente Ruido relacionados ao Laudo."
		aAdd( aAtalhos , { "RISCO-CALOR" , STR0050 } ) //"Imprimirá todos os Riscos do agente Calor relacionados ao Laudo."
		aAdd( aAtalhos , { "RISCO-FRIO" , STR0047 } ) //"Imprimirá todos os Riscos do agente Frio relacionados ao Laudo em questão."
		aAdd( aAtalhos , { "RISCO-QUIMICO" , STR0051 } ) //"Imprimirá todos os Riscos de agente Quimico relacionados ao Laudo."
		aAdd( aAtalhos , { "RISCO-UMIDADE" , STR0074 } ) //"Imprimirá todos os Riscos do agente Umidade relacionados ao Laudo."
		aAdd( aAtalhos , { "RISCO-FISICO" , STR0052 } ) //"Imprimirá todos os Riscos de agente Fisico relacionados ao Laudo."
		aAdd( aAtalhos , { "RISCO-EPC" , STR0053 } ) //"Imprimirá todos os equipamentos de proteção coletivo (EPC) relacionados aos riscos avaliados no Laudo."
		If AliasInDic("TID") .And. !lSigaMdtPs .And. Self:nTipoLaudo == 1
			aAdd( aAtalhos , { "QUESTIONARIO PRODUTO" , STR0124 } ) //"Imprimirá os questionários de produtos químicos vinculados ao Laudo."
		EndIf
		aAdd( aAtalhos , { "QUADRO RISCOS" , STR0054 } ) //"Imprimirá todos os Riscos relacionados ao Laudo em questão, em um quadro contendo cinco colunas. Entre elas estão o tipo, a fonte geradora, a trajetória e as funções."
		aAdd( aAtalhos , { "RISCO" , STR0045 } ) //"Imprimirá todos os Riscos relacionados ao Laudo em questão."
		aAdd( aAtalhos , { "QUADRO FUNCIONARIOS" , STR0017+STR0018 } ) //"Imprimirá o numero de funcionarios do sexo masculino, " //"feminino e menor aprendiz"
		aAdd( aAtalhos , { "QUADRO FUNCIONARIOS POR CENTRO DE CUSTO" , STR0075 } ) //"Imprimirá o numero de funcionarios do sexo masculino, feminino e menor aprendiz por Setor."
		aAdd( aAtalhos , { "EQUIPAMENTO" , STR0061 } ) //"Imprimirá todos os Equipamentos utilizados no Laudo em questão."
		aAdd( aAtalhos , { "QUADRO MEDIDA CONTROLE" , STR0063 } ) //"Imprimirá todas as Medidas de Controle utilizadas no Laudo em questão, em um quadro contendo as recomendações e as metas."
		aAdd( aAtalhos , { "CONTROLE" , STR0062 } ) //"Imprimirá todas as Medidas de Controle utilizadas no Laudo em questão."
		aAdd( aAtalhos , { "EXAMES" , STR0066 } ) //"Imprimirá todos os Exames necessários aos riscos avaliados no Laudo."
		aAdd( aAtalhos , { "SESMT" , STR0067 } ) //"Imprimirá a composição do SESMT."
		aAdd( aAtalhos , { "QUADRO EPI" , STR0065 } ) //"Imprimirá num quadro os Epi's necessários aos riscos. O quadro contém o tipo de proteção, a descrição e a área de utilização do Epi."
		aAdd( aAtalhos , { "EPI" , STR0064 } ) //"Imprimirá todos os Epi's necessários aos riscos avaliados no Laudo."
		aAdd( aAtalhos , { "PLANO" , STR0068 } ) //"Imprimirá os Planos de Ação dos riscos avaliados."
		aAdd( aAtalhos , { "QUESTIONARIO" , STR0073 } ) //"Imprimirá todos os Questionários do Laudo em questão."
		aAdd( aAtalhos , { "FUNCIONARIOS X FUNCAO" , STR0070 } ) //"Imprimirá todas as funções e a quantidade de funcionários empregados em cada função."
		aAdd( aAtalhos , { "FUNCOES" , STR0071 } ) //"Imprimirá a descrição das atividades desenvolvidas pelo Funcionário."
		aAdd( aAtalhos , { "FUNCOES E TAREFAS" , STR0072 } ) //"Imprimirá a descrição das atividades desenvolvidas pelo Funcionário. E também imprimirá a descrição das tarefas do mesmo."
		aAdd( aAtalhos , { "CRONOGRAMA" , STR0069 } ) //"Imprimirá o cronograma do Plano de Ação do Laudo."
		aAdd( aAtalhos , { "QUADRO DE AGENTES" , STR0101+CRLF+STR0102+	CRLF+STR0103+CRLF+STR0104+CRLF+STR0105} )//"Imprimirá o Quadro de Agentes." "	O Quadro Indica o Grupo de Risco que o Agente pertence." "1-Físico"	"2-Químico" "3-Biológico"
		AaDd( aAtalhos , { "PLANO EMERGENCIAL" , STR0107 } )//"Imprimirá o Plano Emergencial."
		If AliasInDic("TJB") .And. !lSigaMdtps
			aAdd( aAtalhos , { "ANEXO IV" , STR0108 } ) //"Imprimirá os produtos químicos do Laudo."
		EndIf
		If AliasIndic("TJA")
			aAdd( aAtalhos , { "REQUISITOS", STR0110 } ) //"Imprimirá os Requisitos Legais do Laudo."
		EndIf
		If AliasIndic("TJ9")
			aAdd( aAtalhos , { "EPI X ATIVIDADES" , STR0109 } ) //"Imprimirá equipamentos individuais de proteção relacionado as atividades."
		EndIf
		If Self:nTipoLaudo == 6
			If AliasIndic("TOD")
				aAdd( aAtalhos , { "BEM" , STR0132 } )//"Imprimirá todos os Bens utilizados no Laudo em questão."
			EndIf
			aAdd( aAtalhos , { "MD-EPC" , STR0133 } )	//"Imprimirá todos os EPC's utilizados no Laudo em questão."
			aAdd( aAtalhos , { "QUADRO TOQUES" , "Imprimirá o Quadro de Toques padrão." } )
		EndIf
		If AliasIndic("TJA") .And. AliasIndic("TJE")
			aAdd( aAtalhos , { "QUADRO REQUISITOS X TREINAMENTO", STR0131 } ) //"Imprimirá o quadro de requisito por treinamento"
		EndIf
		If AliasIndic("TJ7")
			Aadd( aAtalhos , { "DOSIMETRIA POR AMBIENTE FÍSICO"	,	STR0111	}	) // "Imprimirá as Medições de Dosimetria do Ambiente Físico."
			Aadd( aAtalhos , { "DOSIMETRIA POR FUNCIONÁRIOS"	, 	STR0112	}	) // "Imprimirá as Medições de Dosimetria dos Funcionários."
			Aadd( aAtalhos , { "DOSIMETRIA POR CENTRO DE CUSTO"	, 	STR0113	}	) // "Imprimirá as Medições de Dosimetria do Centro de Custo."
			Aadd( aAtalhos , { "DOSIMETRIA POR FUNÇÃO" 			, 	STR0114	}	) // "Imprimirá as Medições de Dosimetria das Funções."
			Aadd( aAtalhos , { "DOSIMETRIA POR ATIVIDADE" 		, 	STR0115	}	) // "Imprimirá as Medições de Dosimetria das Atividades."
		EndIf

		//Caso for PGR
		If Self:nTipoLaudo == 6

			aAdd( aAtalhos, { "EQUIPAMENTOS RADIOATIVOS", STR0155 } ) //"Imprimirá os equipamentos radioativos."
			aAdd( aAtalhos, { "ESTRUTURA LOCAIS", STR0156 } ) //"Imprimirá o quadro com especificações da estrutura dos locais."
			aAdd( aAtalhos, { "PGR - FUNCIONARIOS", STR0157 } ) //"Imprimirá o quadro de funcionários que estão cadastrados no programa de saúde relacionado ao laudo."
			aAdd( aAtalhos, { "PGR X PE", STR0158 } ) //"Imprimirá os dados do plano de emergência relacionado ao laudo."
			If AliasIndic( "TIG" )
				Aadd( aAtalhos, { "QUADRO - PROGRAMA MONITORAMENTO", STR0159 } ) //"Imprimirá o programa de monitoramento."
			EndIf
			aAdd( aAtalhos, { "RADIAÇÃO DE FUGA", STR0160 } ) //"Imprimirá o quadro de radiação de fuga vinculado ao ambiente físico relacionado ao laudo."
			aAdd( aAtalhos, { "PROGRAMA", STR0161 } ) //"Imprimirá os programas de saúde existentes na empresa."
			aAdd( aAtalhos, { "AGENTE X MEDIDA", STR0162 } ) //"Imprimirá todos os agentes do laudo em questão, juntamente com as situações encontradas e medidas aplicadas."
			aAdd( aAtalhos, { "QUADRO AGENTE", STR0163 } ) //"Imprimirá um quadro com todos os agentes e fontes geradoras do laudo em questão, identificando sua patogênese e sintomatologia."
			aAdd( aAtalhos, { "FUNCAO X TAREFA", STR0164 } ) //"Imprimirá todas as funções e tarefas de risco da empresa, indicando sua duração e a vestimenta aplicável."
			aAdd( aAtalhos, { "POLITICA", STR0165 } )//"Imprimirá no laudo as políticas vigentes cadastradas ao sistema"
			aAdd( aAtalhos, { "ACIDENTE S/VITÍMAS", STR0166 } ) // "Imprimirá todos os acidentes sem vitímas ocorridos no período do laudo por setor."
			aAdd( aAtalhos, { "ACIDENTE C/VITÍMAS", STR0167 } ) // "Imprimirá todos os acidentes com vitímas ocorridos no período do laudo por setor."
			aAdd( aAtalhos, { 'ANÁLISE PRELIMINAR', STR0168 } ) // "Imprimirá todos os levantamentos de perigos e danos existentes na empresa."

		EndIf

	// 2. PCMSO
	ElseIf Self:nTipoLaudo == 2

		aAdd( aAtalhos , { "LOCAL" , STR0078 } ) //"Imprimirá todos os Locais Avaliados do Laudo em questão."
		aAdd( aAtalhos , { "RISCO" , STR0045 } ) //"Imprimirá todos os Riscos relacionados ao Laudo em questão."
		aAdd( aAtalhos, { "ACIDENTE", STR0169 } ) // "Imprimirá informações sobre CATs, emitidas pela organização, referentes a seus empregados relacionados ao Laudo"
		aAdd( aAtalhos , { "FUNCIONARIOS X FUNCAO" , STR0070 } ) //"Imprimirá todas as funções e a quantidade de funcionários empregados em cada função."
		aAdd( aAtalhos , { "LISTA FUNCIONARIOS" , STR0081 } ) //"Imprimirá todas as funções e a lista dos funcionários empregados em cada função."
		aAdd( aAtalhos , { "EQUIPAMENTO" , STR0061 } ) //"Imprimirá todos os Equipamentos utilizados no Laudo em questão."
		aAdd( aAtalhos , { "CONTROLE" , STR0062 } ) //"Imprimirá todas as Medidas de Controle utilizadas no Laudo em questão."
		aAdd( aAtalhos , { "EXAMES" , STR0079 } ) //"Imprimirá todos os Exames que foram realizados no período em que abrange o PCMSO."
		aAdd( aAtalhos , { "SESMT" , STR0067 } ) //"Imprimirá a composição do SESMT."
		aAdd( aAtalhos , { "PLANO" , STR0068 } ) //"Imprimirá os Planos de Ação dos riscos avaliados."
		aAdd( aAtalhos , { "CRONOGRAMA" , STR0069 } ) //"Imprimirá o cronograma do Plano de Ação do Laudo."
		aAdd( aAtalhos , { "PROGRAMA" , STR0080 } ) //"Imprimirá os programas de saúde existentes na empresa."
		aAdd( aAtalhos , { "PROGRAMACAO VACINAS" , STR0106 } ) //"Imprimirá a programação de vacinas no período do PCMSO."
		aAdd( aAtalhos , { "QUADRO FUNCIONARIOS" , STR0082 } ) //"Imprimirá o numero de funcionarios do sexo masculino, feminino e menor aprendiz"
		aAdd( aAtalhos , { "TURNOS" , STR0083 } ) //"Imprimirá os turnos de trabalho dos funcionários"
		aAdd( aAtalhos , { "ANEXO-A" , STR0084 } ) //"Imprimirá os Anexos I e II. Anexo I - Relação das funções e seu respectivo quantitativo. Anexo II - Riscos Ambientais e Exames Programados de acordo com a função."
		aAdd( aAtalhos , { "ANEXO-B" , STR0085 } ) //"Imprimirá os Anexos I e II. Anexo I - Relação das funções e seu respectivo quantitativo. Anexo II - Riscos Ambientais e Exames Programados, Admissionais,  Demissionais, de Mudança de Função e  Ret. ao Trabalho de acordo  com a função."
		If AliasIndic("TJA")
			aAdd( aAtalhos , { "REQUISITOS", STR0110 } ) //"Imprimirá os Requisitos Legais do Laudo."
		EndIf

	// 3. L.T. Pericial
	ElseIf Self:nTipoLaudo == 3

		aAdd( aAtalhos , { "LOCAL" , STR0078 } ) //"Imprimirá todos os Locais Avaliados do Laudo em questão."
		aAdd( aAtalhos , { "RISCO" , STR0045 } ) //"Imprimirá todos os Riscos relacionados ao Laudo em questão."
		aAdd( aAtalhos , { "EQUIPAMENTO" , STR0061 } ) //"Imprimirá todos os Equipamentos utilizados no Laudo em questão."
		aAdd( aAtalhos , { "CONTROLE" , STR0062 } ) //"Imprimirá todas as Medidas de Controle utilizadas no Laudo em questão."
		aAdd( aAtalhos , { "TAREFA" , STR0086 } ) //"Imprimirá todas as Tarefas que o Funcionário exerceu e o período delas."
		aAdd( aAtalhos , { "FUNCOES" , STR0071 } ) //"Imprimirá a descrição das atividades desenvolvidas pelo Funcionário."
		aAdd( aAtalhos , { "QUADRO FUNCIONARIOS" , STR0082 } ) //"Imprimirá o numero de funcionarios do sexo masculino, feminino e menor aprendiz"
		aAdd( aAtalhos , { "HISTORICO" , STR0087 } ) //"Imprimirá o Histórico das Funções exercidas pelo Funcionário, e serão listados o Cargo e o CBO relacionados à cada Função exercida."
		aAdd( aAtalhos , { "EPI" , STR0088 } ) //"Imprimirá todos os Epi's necessários à Função Atual do Funcionário."
		aAdd( aAtalhos , { "NAO-EXPOSTOS", STR0154 } ) // "Imprimirá o quadro de funcionários não expostos a Riscos."

	// 4. LTCAT
	ElseIf Self:nTipoLaudo == 4

		aAdd( aAtalhos , { "LOCAL" , STR0078 } ) //"Imprimirá todos os Locais Avaliados do Laudo em questão."
		aAdd( aAtalhos , { "RISCOS E ATIVIDADES" , STR0055 } ) //"Imprimirá todos os Riscos relacionados ao Laudo em questão. E também imprimirá a descrição da função exposta à agentes a cada risco avaliado."
		aAdd( aAtalhos , { "RISCO" , STR0045 } ) //"Imprimirá todos os Riscos relacionados ao Laudo em questão."
		aAdd( aAtalhos , { "QUADRO FUNCIONARIOS" , STR0089 } ) //"Imprimirá o numero de funcionarios do sexo masculino, feminino e menor aprendiz."
		aAdd( aAtalhos , { "EQUIPAMENTO" , STR0061 } ) //"Imprimirá todos os Equipamentos utilizados no Laudo em questão."
		aAdd( aAtalhos , { "CONTROLE" , STR0062 } ) //"Imprimirá todas as Medidas de Controle utilizadas no Laudo em questão."
		aAdd( aAtalhos , { "PLANO DE ACAO" , STR0068 } ) //"Imprimirá os Planos de Ação dos riscos avaliados."
		aAdd( aAtalhos , { "EPI" , STR0090 } ) //"Imprimirá todos os Epi's necessários à eliminação dos riscos existentes."
		aAdd( aAtalhos , { "NAO-EXPOSTOS", STR0154 } ) // "Imprimirá o quadro de funcionários não expostos a Riscos."

	// 5. DIRBEN 8030
	ElseIf Self:nTipoLaudo == 5

		//Não possui atalhos

	// 7. PCMAT
	ElseIf Self:nTipoLaudo == 7

		aAdd( aAtalhos , { "QUADRO FASE" , STR0092 } ) //"Imprimirá as Atividades, Riscos, Epi's e Epc's relacionados a cada Fase da Obra."
		//Verifica se o UPDMDT58 está aplicado
		If NGCADICBASE("TK1_AREA","A","TK1",.F.)
			aAdd( aAtalhos , { "FASES, VIVENCIAS, EQUIPAMENTOS, EPC'S" , STR0043 } ) //"Imprimirá as Áreas de Vivência, Equipamentos e EPC's relacionados a cada Fase da Obra."
		EndIf
		aAdd( aAtalhos , { "EQUIPAMENTO" , STR0091 } ) //"Imprimirá todos os Equipamentos utilizados na Obra."
		aAdd( aAtalhos , { "CONTROLE" , STR0062 } ) //"Imprimirá todas as Medidas de Controle utilizadas no Laudo em questão."
		aAdd( aAtalhos , { "FUNCOES" , STR0094 } ) //"Imprimirá a descrição das atividades desenvolvidas na empresa."
		aAdd( aAtalhos , { "CRONOGRAMA" , STR0069 } ) //"Imprimirá o cronograma do Plano de Ação do Laudo."
		aAdd( aAtalhos , { "VIVENCIA" , STR0100 } ) //"Imprimirá as áreas de vivência da Obra."
		aAdd( aAtalhos , { "ANEXOS" , STR0048 } ) //"Imprimirá anexo com imagens da obra."
		aAdd( aAtalhos , { "QUADRO EPI" , STR0065 } ) //"Imprimirá num quadro os Epi's necessários aos riscos. O quadro contém o tipo de proteção, a descrição e a área de utilização do Epi."
		aAdd( aAtalhos , { "EPI X FUNCAO" , STR0093 } ) //"Imprimirá todos os Epi's necessários as Funções."
		aAdd( aAtalhos , { "MEMO LOCAL" , STR0095 } ) //"Imprimirá o campo Carac. Local do cadastro da Obra."
		aAdd( aAtalhos , { "MEMO EMPREENDIMENTO" , STR0096 } ) //"Imprimirá o campo Empreendim. do cadastro da Obra."
		aAdd( aAtalhos , { "MEMO ELETRICA" , STR0097 } ) //"Imprimirá o campo Ins.Eletrica do cadastro da Obra."
		aAdd( aAtalhos , { "MEMO SINALIZACAO" , STR0098 } ) //"Imprimirá o campo Sinalizacao do cadastro da Obra."
		aAdd( aAtalhos , { "MEMO EMERGENCIA" , STR0099 } ) //"Imprimirá o campo Proc.Emergen do cadastro da Obra."

	// 8. PPR
	ElseIf Self:nTipoLaudo == 8

		aAdd( aAtalhos , { "EQUIPAMENTOS RADIOATIVOS" , STR0125 } ) //"Imprimirá os equipamentos do PPR."
		aAdd( aAtalhos , { "PPR - FUNCIONÁRIOS" , STR0126 } ) //"Imprimirá o quadro de funcionários que estão cadastrados no programa de saúde relacionado ao laudo."
		aAdd( aAtalhos , { "CONTROLE" , STR0127 } )//"Imprimirá medidas de controle no relatório geral do PPR."
		aAdd( aAtalhos , { "LEVANTAMENTO RADIOMÉTRICO" , STR0128 } ) //"Imprimirá no PPR, as imagens associadas aos ambientes, relacionados ao laudo."
		aAdd( aAtalhos , { "ESTRUTURA LOCAIS" , STR0129 } ) //"Imprimirá no PPR, o quadro com especificações da estrutura dos locais."
		aAdd( aAtalhos , { "PPR X PE" , STR0130 } ) //"Imprimirá no PPR, dados do plano de emergência relacionado ao laudo."
		aAdd( aAtalhos , { "RADIAÇÃO DE FUGA" , STR0136 } ) //"Imprimirá no PPR, o quadro de radiação de fuga vinculado ao ambiente físico relacionado ao laudo."
		If AliasIndic("TJA") .And. AliasIndic("TJE")
			aAdd( aAtalhos , { "QUADRO REQUISITOS X TREINAMENTO", STR0131 } )  //"Imprimirá o quadro de requisito por treinamento"
		EndIf
		Aadd( aAtalhos , { "DOSIMETRIA POR AMBIENTE FÍSICO"	,	STR0111	}	) // "Imprimirá as Medições de Dosimetria do Ambiente Físico."
		Aadd( aAtalhos , { "DOSIMETRIA POR FUNCIONÁRIOS"	    , 	STR0112	}	) // "Imprimirá as Medições de Dosimetria dos Funcionários."
		Aadd( aAtalhos , { "DOSIMETRIA POR CENTRO DE CUSTO"	, 	STR0113	}	) // "Imprimirá as Medições de Dosimetria do Centro de Custo."
		Aadd( aAtalhos , { "DOSIMETRIA POR FUNÇÃO" 			, 	STR0114	}	) // "Imprimirá as Medições de Dosimetria das Funções."
		Aadd( aAtalhos , { "DOSIMETRIA POR ATIVIDADE" 		    , 	STR0115	}	) // "Imprimirá as Medições de Dosimetria das Atividades."
		If AliasIndic("TIG")
			Aadd( aAtalhos , { "QUADRO - PROGRAMA MONITORAMENTO", STR0132	}	) // "Imprimirá o Programa de Monitoramento."
		EndIf

	// 8. B. Resíduos de Serviço de Saúde e Resíduos
	ElseIf Self:nTipoLaudo == 11 .OR. Self:nTipoLaudo == 9

		aAdd( aAtalhos , { "IDENTIFICAÇÃO E PLANEJAMENTO DO GERENCIAMENTO" , STR0116 } ) //"Imprimirá as informações dos resíduos contidas no Cadastro de Definição de Resíduo."
		aAdd( aAtalhos , { "INDICADORES E METAS" , STR0117 } ) //"Imprimirá as informações dos Objetivos e Metas com data início e fim dentro da vigência do laudo."
		aAdd( aAtalhos , { "CRONOGRAMA DE PROGRAMAS" , STR0135 } ) //"Imprimirá os Planos de Ação vinculados ao Laudo(Laudo x Planos de Ação) em formato de tabela conforme traz o exemplo de PGR encaminhado."
		aAdd( aAtalhos , { "PLANOS DE AÇÃO" , STR0134 } ) //"Imprimirá os planos de ação com as principais informações de descrição, o que, como, onde, prazo, data início, data fim, responsável, observação, etc."


	// 10. PAE
	ElseIf Self:nTipoLaudo == 10

		If nModulo == 35
			aAdd( aAtalhos , { "BRIGADAS EMERGENCIAIS"			, STR0118 } ) //"Imprimirá todas as brigadas emergenciais cuja a vigência esteja dentro do período do laudo."
			aAdd( aAtalhos , { "RESPONSABILIDADES DAS BRIGADAS"	, STR0119 } ) //"Imprimirá todas as funções e respectivas responsabilidades contidas nas brigadas emergenciais."
			aAdd( aAtalhos , { "ENTIDADES DE APOIO"				, STR0120 } ) //"Imprimirá todos os contatos externos relacionados aos planos emergenciais do laudo."
			aAdd( aAtalhos , { "PLANOS EMERGENCIAIS"				, STR0121 } ) //"Imprimirá todos os planos emergenciais relacionados na rotina Laudo x Plano de Atendimento Emergencial."
			aAdd( aAtalhos , { "CRONOGRAMA DE SIMULAÇÕES"			, STR0122 } ) //"Imprimirá todas as simulações de plano de atendimento emergencial que serão realizadas no período do relatório."
			aAdd( aAtalhos , { "CRONOGRAMA DE TREINAMENTOS"		, STR0123 } ) //"Imprimirá um cronograma contendo os treinamentos que serão realizados para as brigadas de atendimento."
		ElseIf nModulo == 56
			aAdd( aAtalhos , { "PLANOS EMERGENCIAIS"			, STR0121 } ) //"Imprimirá todos os planos emergenciais relacionados na rotina Laudo x Plano de Atendimento Emergencial."
			aAdd( aAtalhos , { "ENTIDADES DE APOIO"			, STR0120 } ) //"Imprimirá todos os contatos externos relacionados aos planos emergenciais do laudo."
			aAdd( aAtalhos , { "CRONOGRAMA DE SIMULAÇÕES"		, STR0122 } ) //"Imprimirá todas as simulações de plano de atendimento emergencial que serão realizadas no período do relatório."
		EndIf

	// 12. Ergonomia
	ElseIf Self:nTipoLaudo == 12

		//Atalhos advindos do PPRA
		aAdd( aAtalhos , { "CONTROLE" 				, STR0062 } ) //"Imprimirá todas as Medidas de Controle utilizadas no Laudo em questão."
		aAdd( aAtalhos , { "LOCAL" 					, STR0044 } ) //"Imprimirá todos os Locais Avaliados do Laudo em questão."
		aAdd( aAtalhos , { "QUADRO LOCAL" 			, STR0076 + Chr( 13 ) + Chr( 10 ) + ; //"Imprimirá todos os Locais Avaliados do Laudo em questão em formato de tabela. "
														STR0077 } ) //"Obs: Este item somente será aplicado em formato de tabela no PPRA/PGR modelo Ms-Word. Nos demais modelos será apresentado em formato de texto."
		aAdd( aAtalhos , { "QUADRO MEDIDA CONTROLE" , STR0063 } ) //"Imprimirá todas as Medidas de Controle utilizadas no Laudo em questão, em um quadro contendo as recomendações e as metas."
		aAdd( aAtalhos , { "QUESTIONARIO" 			, STR0073 } ) //"Imprimirá todos os Questionários do Laudo em questão."
		aAdd( aAtalhos , { "RISCOS X FUNCIONARIOS" 	, STR0058 } ) //"Imprimirá todos os Riscos relacionados ao Laudo em questão. E também uma relação dos funcionários expostos à esse risco."
		aAdd( aAtalhos , { "SESMT" 					, STR0067 } ) //"Imprimirá a composição do SESMT."
		aAdd( aAtalhos , { "FUNCIONARIOS X FUNCAO"	, STR0070 } ) //"Imprimirá todas as funções e a quantidade de funcionários empregados em cada função."
		aAdd( aAtalhos , { "FUNCOES" 				, STR0071 } ) //"Imprimirá a descrição das atividades desenvolvidas pelo Funcionário."
		aAdd( aAtalhos , { "NAO-EXPOSTOS"           , STR0154 } ) // "Imprimirá o quadro de funcionários não expostos a Riscos."

		//Específicos de Ergonomia
		aAdd( aAtalhos , { "QUADRO AGENTE" 			, STR0150 } )//"Imprimirá um quadro com todos os Agentes e Fontes Geradoras do Laudo em questão, identificando sua patogênese e sintomatologia."
		aAdd( aAtalhos , { "FUNCAO X TAREFA" 		, STR0151 } )//"Imprimirá todas as Funções e Tarefas de Risco da empresa, indicando sua duração e a vestimenta aplicável."
		aAdd( aAtalhos , { "AGENTE X MEDIDA" 		, STR0152 } )//"Imprimirá todos os Agentes Ergonômicos do Laudo em questão, juntamente com as situações encontradas e medidas aplicadas."

	EndIf

	If ExistBlock('MDTA210A1') //Ponto de Entrada para adicionar novos itens nas opcoes de ATALHO
		aRetPE := ExecBlock('MDTA210A1',.F.,.F., {Alltrim(Str(Self:nTipoLaudo))})
		If ValType(aRetPE) == "A"
			For nFor := 1 To Len(aRetPE)
				aAdd( aAtalhos , { aRetPE[nFor,1] , aRetPE[nFor,2] } )
			Next nFor
		EndIf
	EndIf

	aAdd( aAtalhos , { Space(1) , Space(1) } ) //Default vazio

	aSort(aAtalhos,,,{|x,y| x[1]+x[2] < y[1]+y[2] } ) //Ordena os atalhos pela chave

Return aAtalhos

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³  VldTexto       ³Autor³ Denis               ³Data³02/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida se o campo obrigatorio esta preenchido               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTA210                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method VldTexto(cTexto,TitCmp,lCpoAtalho,cBakAtal) Class TNGLAUDO

	Local nPosTmp1
	Default lCpoAtalho := .F.
	Default cBakAtal   := " "
	If Empty(cTexto)
		Help(1," ","OBRIGAT2",,TitCmp,3,0)
		Return .F.
	EndIf
	If lCpoAtalho .And. cTexto <> cBakAtal
		nPosTmp1 := aScan(Self:aShapesUt, {|x| x[6] == "Atalho" .And. Alltrim(cTexto) == Alltrim(x[3][2]) })
		If nPosTmp1 > 0
			Help(" ",1,"JAEXISTINF")
			Return .F.
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} DefineMulti
Tela de montagem da multi seleção de atalhos

@return Sempre verdadeiro

@sample Self:DefineMulti()

@author Jackson Machado
@since 07/01/2015
/*/
//---------------------------------------------------------------------
Method DefineMulti() Class TNGLAUDO

	Local nX
	Local nPosLin := 40, nPosCol := 70
	Local oDlgMGet, oPnlField
	Local oBtnCancel, oBtnInic, oScrollBox
	Local lRet := .F.
	Local aRetBox := Self:BoxLaudo()
	Local cDesc    := aRetBox[1][2]
	Local aBkpAtu := {}

	//Variaveis para montar TRB
	Local cAliasTRB	:= GetNextAlias()
	Local aDBF, aTRB
	Local oTempTRB

	Local lInverte
	Private cMarca

	If Self:lGetMark
		Self:cMkLaudo := GetMark()
		Self:lGetMark := .F.
	EndIf
	cMarca := Self:cMkLaudo

	//Valores e Caracteristicas da TRB
	aDBF		:= {}
	aTRB		:= {}

	aAdd( aDBF , { "OK"      , "C" , 002 		, 0 } )
	aAdd( aDBF , { "ATALHO"  , "C" , 050 		, 0 } )
	aAdd( aTRB , { "OK"      , NIL , " "	  	, 	} )
	aAdd( aTRB , { "ATALHO"  , NIL , STR0138	, 	} ) //"Atalhos"

	//Cria TRB
	oTempTRB := FWTemporaryTable():New( cAliasTRB, aDBF )
	oTempTRB:AddIndex( "1", {"ATALHO","OK"} )
	oTempTRB:Create()

	dbSelectArea( cAliasTRB )
	dbGoTop()

	//devera ser chamado antes de ser alimentado a tela dos atalhos
	If fAtalDup( aRetBox , Self:aShapesUt , cAliasTRB )

		//Alimenta o TRB
		For nX := 1 To Len( aRetBox )
			If !Empty( aRetBox[ nX , 1 ] ) .And. aScan( Self:aShapesUt , { | x | x[ 6 ] == "Multi-Atalho" .And. Alltrim( aRetBox[ nX , 1 ] ) == Alltrim( x[ 3 ][ 2 ] ) } ) == 0
				RecLock( cAliasTRB , .T. )
				( cAliasTRB )->OK := Space( Len( cMarca ) )
				( cAliasTRB )->ATALHO := aRetBox[ nX , 1 ]
				( cAliasTRB )->( MsUnLock() )
			EndIf
		Next nX
	EndIf

	dbSelectArea( cAliasTRB )
	dbGoTop()

	If ( cAliasTRB )->( RecCount() ) > 0

		Self:SetBlackPnl(.T.)

		DEFINE MSDIALOG oDlgMGet FROM 0,0 TO 215,700 OF Self ;
			COLOR CLR_BLACK,CLR_WHITE STYLE nOr(DS_SYSMODAL,WS_MAXIMIZEBOX,WS_POPUP) PIXEL


			oPnlField := Self:LoadBg(oDlgMGet)

			@ 013.5,015 SAY OemToAnsi( STR0139 ) OF oPnlField PIXEL //"Atalho" //"Multipla Seleção"
			oMark := MsSelect():New( cAliasTRB , "OK" , , aTRB , @lInverte , @cMarca , { 025 , 013.5 , 90 , 180 } )
				oMark:oBrowse:lHasMark		:= .T.
				oMark:oBrowse:lCanAllMark	:= .T.
				oMark:oBrowse:bAllMark		:= { | | fInverte( cMarca , cAliasTRB , oMark , .T. ) }//Funcao inverte marcadores
				oMark:oBrowse:bChange		:= { | | fChangeDesc( cAliasTRB , aRetBox , @cDesc , @oDesc ) }//Funcao inverte marcadores
				oMark:bMark	   				:= { | | fInverte( cMarca , cAliasTRB , oMark ) }//Funcao inverte marcadores

			@ 025,185 SAY OemToAnsi(STR0019) OF oPnlField PIXEL //"Descrição"
			oScrollBox  := TScrollBox():New(oPnlField,035,185,55,152,.T.,.T.,.F.)
			oDesc       := TMultiGet():Create(oScrollBox,{|u| If(Pcount() > 0, cDesc := u, cDesc)},000,000,000,000, , , , , ,.T.)
			oDesc:Align := CONTROL_ALIGN_ALLCLIENT
			oDesc:Disable()

			oBtnInic := TButton():New( 103 , 135 , STR0012 , oPnlField , { | | lRet := .T., If(fVldMSelect(cAliasTRB) ,oDlgMGet:End(),lRet := .F.) } , 45 , 11 , , /*oFont*/ , , .T. , , , , /* bWhen*/ , , )	 //"Confirmar"
			oBtnCancel := TButton():New( 103 , 185 , STR0013 , oPnlField , { | | lRet := .F., oDlgMGet:End() } , 45 , 11 , , /*oFont*/ , , .T. , , , , /* bWhen*/ , , )	 //"Cancelar"

		ACTIVATE MSDIALOG oDlgMGet CENTERED

		If lRet

			dbSelectArea( cAliasTRB )
			dbGoTop()
			While ( cAliasTRB )->( !Eof() )
				If !Empty( ( cAliasTRB )->OK )
					//-- Alimenta array aObjAtu com as definições informadas

					aAdd(Self:aObjAtu, Array(4))

					If Len( aBkpAtu ) > 0
						Self:aObjAtu := aClone( aBkpAtu )
						Self:lCreate := .T. //-- Indicando a criação do objeto ao acionar o evento click do paintpanel
					Else
						aBkpAtu := aClone( Self:aObjAtu )
					EndIf

					fChangeDesc( cAliasTRB , aRetBox , @cDesc )

					Self:aObjAtu[4][1] := AllTrim(( cAliasTRB )->ATALHO)
					Self:aObjAtu[4][2] := AllTrim(cDesc)
					Self:aObjAtu[4][3] := Nil
					Self:aObjAtu[4][4] := Nil

					If Len(Self:aShapesUt) > 0
						nPosLin := Self:aShapesUt[Len(Self:aShapesUt),5] + 40
					EndIf

					Self:PaintClick(nPosCol,nPosLin,.F.)

				EndIf
				( cAliasTRB )->( dbSkip() )
			End

		Else
			//-- Define que o objeto não será criado ao acionar o click na area do paintpanel
			Self:lCreate := .F.
			Self:aObjAtu := {}
		EndIf

		Self:SetBlackPnl(.F.)
	Else
		MsgInfo( STR0140 ) //"Não existem mais atalhos a serem selecionados."
		//-- Define que o objeto não será criado ao acionar o click na area do paintpanel
		Self:lCreate := .F.
		Self:aObjAtu := {}
	EndIf

	oTempTRB:Delete()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fInverte
Inverte as marcacoes ( bAllMark )

@return Nil

@param cMarca Caracter Valor da marca do TRB ( Obrigatório )
@param cAliasTRB Caracter Valor do Alias do TRB ( Obrigatório )
@param oMark Objeto Objeto do MarkBrowse ( Obrigatório )
@param lAll Logico Indica se eh AllMark

@sample fInverte( "E" , "TRB" )

@author Jackson Machado
@since 07/01/2015
/*/
//---------------------------------------------------------------------
Static Function fInverte( cMarca , cAliasTRB , oMark , lAll )

	Local aArea := {}

	Default lAll := .F.

	If lAll
		aArea := GetArea()

		dbSelectArea( cAliasTRB )
		dbGoTop()
		While ( cAliasTRB )->( !Eof() )
			( cAliasTRB )->OK := IF( Empty( ( cAliasTRB )->OK ) , cMarca, Space( Len( cMarca ) ) )
			(cAliasTRB)->( dbskip() )
		End

		RestArea( aArea )
	EndIf

	// Atualiza markbrowse
	oMark:oBrowse:Refresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fChangeDesc
Executa troca da descrição dos atalhos

@return Sempre nulo

@param cAliasTRB Caracter Valor do Alias do TRB ( Obrigatório )
@param aRetBox Array Valores do combo de atalho  ( Obrigatório )
@param cDesc Caracter Variavel que recebera o valor da descrição ( Obrigatório )
@param oDesc Objeto Objeto que deve ser atualizado com a descrição do atalho

@sample

@author Jackson Machado
@since 07/01/2015
/*/
//---------------------------------------------------------------------
Static Function fChangeDesc( cAliasTRB , aRetBox , cDesc , oDesc )

	Local nPos
	Local cTipAtal := AllTrim( ( cAliasTRB )->ATALHO )

	nPos := aScan( aRetBox , { | x | Alltrim( x[ 1 ] ) == cTipAtal .And. Len( Alltrim( x[ 1 ] ) ) == Len( cTipAtal ) } )

	If nPos > 0
		cDesc := aRetBox[ nPos , 2 ]
		If ValType( oDesc ) == "O"
			oDesc:Refresh()
		EndIf
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fVldMSelect
Valida se ao menos um item do Mark foi selecionado

@return lRet Logico Retorna verdadeiro quando MsSelect correto

@param cAliasTRB Caracter Valor do Alias do TRB ( Obrigatório )

@sample fVldMSelect( "TRB" )

@author Jackson Machado
@since 07/01/2015
/*/
//---------------------------------------------------------------------
Static Function fVldMSelect( cAliasTRB )

	Local lRet := .F.
	Local aArea := getArea()

	dbSelectArea( cAliasTRB )
	dbGoTop()
	While ( cAliasTRB )->( !Eof() )

		If !Empty( ( cAliasTRB )->OK )
			lRet := .T.
			Exit
		EndIf

		( cAliasTRB )->( dbSkip() )
	End

	If !lRet
		ShowHelpDlg( STR0141 , { STR0142 } , 1 , { STR0137 } , 1 ) //"Atenção"###"Nenhum item selecionado."###"Favor selecionar ao menos um item."
	EndIf

	RestArea(aArea)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fAtalDup
Verifica se o item ja foi adicionado para não duplicar

@return

@param aRetBox - Atalhos para selecionar
@Param Self:aShapesUt - Local onde os atalhos vão ser salvos

@sample fAtalDup( aArray  )

@author Jean Pytter da Costa
@since 15/01/2016
/*/
//---------------------------------------------------------------------
Static Function fAtalDup( aRetBox , aShapesUt , cAliasTRB )

	Local nX
	Local lRet := .T.
	Local aRetBoxAux := {}
	Local aShapesAux := {}

	If !Empty( aShapesUt )

		//Somente as posições preenchidas
		For nX := 1 To Len( aRetBox )
			If !Empty( aRetBox[ nX , 1 ] )
				aAdd( aRetBoxAux , aRetBox[ nX ] )
			EndIf
		Next nX

		//Somente as posições do atalho
		For nX := 1 To Len( aShapesUt )
			If !Empty( aShapesUt[ nX , 1 ] )
				If aShapesUt[ nX , 6 ] == "Atalho"
					aAdd( aShapesAux , aShapesUt[ nX ] )
				EndIf
			EndIf
		Next nX

		nX := 1
		nCont := 0
		nCont1 := 1
		//Deleta do array do Multi-atalhos os atalhos que ja foram incluso
		While ( Len( aShapesAux ) - nCont ) <> 0 //Enquanto todos os atalhos incluso não for encontrado.
			If AllTrim(aRetBoxAux[ nX , 1 ] ) == AllTrim( aShapesAux[ nCont1 , 3 , 2 ] )

				//Deleta os atalhos que ja foram inclusos, para ñ duplicar
				aDel( aRetBoxAux , nX )
				aSize( aRetBoxAux , Len( aRetBoxAux ) - 1 )

				nX := 0
				nCont1 := nCont1 + 1
				nCont := nCont + 1 //variavel para controle, se chegar ao total vai sair do loop
			EndIf

			If ( Len( aRetBoxAux ) - nX ) == 0 //Verifica se chegou ao total de atalhos
				nX := 0
				nCont1 := nCont1 + 1
			EndIf

			nX := nX + 1
		End

		For nX := 1 To Len( aRetBoxAux )
			RecLock( cAliasTRB , .T. )
			( cAliasTRB )->OK := Space( Len( cMarca ) )
			( cAliasTRB )->ATALHO := aRetBoxAux[ nX , 1 ]
			( cAliasTRB )->( MsUnLock() )
		Next nX

		lRet := .F.

	EndIf

Return lRet
