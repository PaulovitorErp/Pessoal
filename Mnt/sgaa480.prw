#INCLUDE "SGAA480.ch"
#include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SGAA480   ºAutor  ³Roger Rodrigues     º Data ³  19/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ocorrencia Geradora de Gases - GEE                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGASGA                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SGAA480()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena variaveis p/ devolucao (NGRIGHTCLICK) 	   					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aNGBEGINPRM 	:= NGBEGINPRM( )
Private lTodos		:= .F.
Private cCadastro 	:= STR0001 //"Ocorrência Geradora de Gases"
Private aRotina		:= MenuDef()

If !SGAUPDGEE()//Verifica se o update de GEE esta aplicado
	Return .F.
Endif

If !SGAUPDCAMP()
	Return .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TD9")
dbSetOrder(1)
mBrowse( 6, 1,22,75,"TD9")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve variaveis armazenadas (NGRIGHTCLICK) 					 	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
NGRETURNPRM(aNGBEGINPRM)

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MenuDef  ³ Autor ³ Roger Rodrigues       ³ Data ³19/08/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Utilizacao de Menu Funcional.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaSGA                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local aRotina := {	{ STR0002	, "AxPesqui"	, 0 , 1},; //"Pesquisar"
                    { STR0003	, "SG480INC"	, 0 , 2},; //"Visualizar"
                    { STR0004	, "SG480INC"	, 0 , 3},; //"Incluir"
                    { STR0005	, "SG480INC"	, 0 , 5, 3}}//"Excluir"
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SG480INC  ºAutor  ³Roger Rodrigues     º Data ³  19/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta tela para Geracao de Ocorrência do GEE                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SGAA480                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SG480INC(cAlias, nRecno, nOpcx)
Local aNGBEGINPRM := If(!IsInCallStack("SGAA480"),NGBEGINPRM(,"SGAA480",,.f.),{})
Local cTitulo := STR0001 //"Ocorrência Geradora de Gases"
Local lOk := .F., i
Local aPages:= {},aTitles:= {}
Local oDlg480,oFolder480,oSplitter
Local oPanelTop,oPanelBot,oPanelF1,oPanelLgnd
Local oPanelH1, oPanelH2, oPanelH3
Local aHeaderFon := CABECGETD("TD5",{"TD5_CODPRO","TD5_ESTRUT","TD5_CODNIV"})//Monta acols para estruturar MarkBrowse
Local nIdx

//Variaveis de tamanho de tela e objetos
Local aSize := {}, aObjects := {}, aInfo := {}, aPosObj := {}

//Variaveis da GetDados
Local cGetWhlGG  := ""
Private aColsGG  := {}, aHeadGG  := {}

//Variaveis do MarkBrowse
Private aTRBFon := {}, aCpoFon := {}, oTempFON
Private lInverte:= .F., cMarca  := GetMark()

//Variaveis de Tela
Private aTela := {}, aGets := {}

//Variaveis para Estrutura Organizacional e TRB
Private aLocal := {}, aDefinido := {}, aMarcado := {}
Private oTree
Private aVETINR := {}, aTRB := SGATRBEST(.T.)
Private aItensCar := {},nNivel := 0,nMaxNivel := 0
Private cCodEst := "001", cDesc := NGSEEK("TAF","001000",1,"TAF->TAF_NOMNIV")
Private lRateio := NGCADICBASE("TAF_RATEIO"	,"D","TAF",.F.)
Private lRetS 	:= NGCADICBASE("TAF_ETAPA"	,"A","TAF",.F.)

dbSelectArea("TAF")
dbSetOrder(1)
If !dbSeek(xFilial("TAF")+cCodest+"000")
	ShowHelpDlg(STR0006,{STR0007},2,; //"Atenção"###"Não existe Estrutura Organizacional cadastrada para este Módulo."
								{STR0008}) //"Favor cadastrar uma Estrutura Organizacional."
	Return .F.
Endif
aRotina := {	{ STR0002	, "AxPesqui"	, 0 , 1},; //"Pesquisar"
                { STR0003	, "SG480INC"	, 0 , 2},; //"Visualizar"
                { STR0004	, "SG480INC"	, 0 , 3},; //"Incluir"
                { STR0009	, "SG480INC"	, 0 , 4},; //"Alterar"
                { STR0005	, "SG480INC"	, 0 , 5, 3}} //"Excluir"

//Cria arquivo temporario
cTRBSGA := aTRB[3]
oTempSGA := FWTemporaryTable():New( cTRBSGA, aTRB[1] )
For nIdx := 1 To Len( aTRB[2] )
	oTempSGA:AddIndex( RETASC( cValToChar( nIdx ) , 1 , .T. ), aTRB[2,nIdx] )
Next nIdx
oTempSGA:Create()

//Definicao de variaveis do MarkBrowse
cTRBMRK := GetNextAlias()
//Definicao da estrutura do TRB
aTRBFon := {}
Aadd(aTRBFon,{"OK"		   	,"C", 02,0})
Aadd(aTRBFon,{"TD5_CODFON" 	,"C", TAMSX3("TD5_CODFON")[1],0})
Aadd(aTRBFon,{"TD5_DESFON"  ,"C", TAMSX3("TD5_DESFON")[1],0})
//Verifica campos do usuario
For i:=1 to Len(aHeaderFon)
	//Se nao existir no TRB, adiciona
	If aScan(aTRBFon, {|x| x[1] == aHeaderFon[i][2]} ) == 0
		Aadd(aTRBFon,{aHeaderFon[i][2]  ,aHeaderFon[i][8], aHeaderFon[i][4], aHeaderFon[i][5]})
	Endif
Next i

//Cria estrutura do MsSelect
aCpoFon := {}
Aadd(aCpoFon,{"OK"			,Nil, " "})
Aadd(aCpoFon,{"TD5_CODFON"	,Nil, RetTitle("TD5_CODFON")})
Aadd(aCpoFon,{"TD5_DESFON"	,Nil, RetTitle("TD5_DESFON")})
For i:=1 to Len(aTRBFon)
	//Se nao encontrar na estrutura adiciona
	If aScan(aCpoFon, {|x| x[1] == aTRBFon[i][1]} ) == 0
		Aadd(aCpoFon,{aTRBFon[i][1]	,Nil, RetTitle(aTRBFon[i][1])})
	Endif
Next i

//Cria Arquivo Temporário
oTempFON := FWTemporaryTable():New( cTRBMRK, aTRBFon )
oTempFON:AddIndex( "1", {"TD5_CODFON"} )
oTempFON:Create()

//Definicao de tamanho de tela e objetos
aSize := MsAdvSize(,.f.,430)
Aadd(aObjects,{030,030,.t.,.t.})
Aadd(aObjects,{100,100,.t.,.t.})
aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
aPosObj := MsObjSize(aInfo, aObjects,.t.)

//Cria os Folders de acordo com a Rotina que chama
Aadd(aTitles,OemToAnsi(STR0010)) //"Local Consumidor"
Aadd(aPages,"Header 1")
Aadd(aTitles,OemToAnsi(STR0011)) //"Gases Gerados"
Aadd(aPages,"Header 2")
Aadd(aTitles,OemToAnsi(STR0023)) //"Fonte Geradora"
Aadd(aPages,"Header 3")

nOpcx := If(nOpcx > 3, 5, nOpcx)
Inclui := (nOpcx == 3)
Altera := (nOpcx == 4)

Define MsDialog oDLG480 Title OemToAnsi(cTitulo) From aSize[7],0 To aSize[6],aSize[5] Of oMainWnd Pixel

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Estrutura da Tela            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSplitter := tSplitter():New(0,0,oDlg480,100,100,1 )
oSplitter:Align := CONTROL_ALIGN_ALLCLIENT

oPanelTop := TPanel():New(0,0,,oSplitter,,,,,,10,10,.F.,.F.)
oPanelTop:nHeight := 6
oPanelTop:Align := CONTROL_ALIGN_TOP

oPanelBot := TPanel():New(0,0,,oSplitter,,,,,,10,10,.F.,.F.)
oPanelBot:Align := CONTROL_ALIGN_BOTTOM

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parte de Superior da Tela          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Dbselectarea("TD9")
RegToMemory("TD9",(nOpcx == 3))
oEnc480 := MsMGet():New("TD9",nRecno,nOpcx,,,,,aPosObj[1],,,,,,oPanelTop)
oEnc480:oBox:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parte Inferior da Tela             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oFolder480 := TFolder():New(0,0,aTitles,aPages,oPanelBot,,,,.T.,.f.)
oFolder480:aDialogs[1]:oFont := oDLG480:oFont
oFolder480:aDialogs[2]:oFont := oDLG480:oFont
oFolder480:aDialogs[3]:oFont := oDLG480:oFont
oFolder480:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 01 - Locais de Consumo      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanelH1 := TPanel():New(0,0,,oFolder480:aDialogs[1],,,,,RGB(67,70,87),200,200,.F.,.F.)
oPanelH1:Align := CONTROL_ALIGN_TOP
oPanelH1:nHeight := 20

@ 002,004 Say OemToAnsi(STR0012) Of oPanelH1 Color RGB(255,255,255) Pixel //"Escolha o Local Consumidor do Produto clicando duas vezes sobre a pasta."

oPanelF1 := TPanel():New(0,0,,oFolder480:aDialogs[1],,,,,,10,10,.F.,.F.)
oPanelF1:Align := CONTROL_ALIGN_ALLCLIENT

oTree := DbTree():New(005, 022, 170, 302, oPanelF1,,, .t.)
oTree:Align := CONTROL_ALIGN_ALLCLIENT

If !Inclui .and. !Empty(TD9->TD9_CODNIV)
	aAdd(aLocal, {TD9->TD9_CODNIV, .T.})
	aAdd(aMarcado, {TD9->TD9_CODNIV, .F.})
Endif

If nOpcx != 3
	aDefinido := SG480TD3(TD9->TD9_CODPRO)
	//Carrega estrutura organizacional
	SG470TREE( 1, aClone(aDefinido) )
Endif

If Str(nOpcx,1) $ "2/5"
	oTree:bChange	:= {|| SG470TREE(2)}
	oTree:BlDblClick:= {||}
Else
	oTree:bChange	:= {|| SG470TREE(2)}
	oTree:blDblClick:= {|| SG480MRK()}
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Painel de Legenda                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPnlLgnd := TPanel():New(00,00,,oPanelF1,,,,,RGB(200,200,200),12,12,.F.,.F.)
oPnlLgnd:Align := CONTROL_ALIGN_BOTTOM
oPnlLgnd:nHeight := 30

@ 002,010 Bitmap oLgnd1 Resource "Folder10" Size 25,25 Pixel Of oPnlLgnd Noborder When .F.
@ 005,025 Say OemToAnsi(STR0013) Of oPnlLgnd Pixel //"Localização Normal"

@ 002,100 Bitmap oLgnd1 Resource "Folder5" Size 25,25 Pixel Of oPnlLgnd Noborder When .F.
@ 005,115 Say OemToAnsi(STR0014) Of oPnlLgnd Pixel //"Possível Local de Consumo"

@ 002,200 Bitmap oLgnd1 Resource "Folder7" Size 25,25 Pixel Of oPnlLgnd Noborder When .F.
@ 005,215 Say OemToAnsi(STR0010) Of oPnlLgnd Pixel //"Local Consumidor"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 02 - Gases Gerados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanelH2 := TPanel():New(0,0,,oFolder480:aDialogs[2],,,,,RGB(67,70,87),200,200,.F.,.F.)
oPanelH2:Align := CONTROL_ALIGN_TOP
oPanelH2:nHeight := 20

@ 002,004 Say OemToAnsi(STR0015) Of oPanelH2 Color RGB(255,255,255) Pixel //"Abaixo estão os Gases gerados pelo Produto."

aCols := {}
aHeader := {}

cGetWhlGG := "TDA->TDA_FILIAL == '"+xFilial("TDA")+"' .AND. TDA->TDA_CODOCO = '"+TD9->TD9_CODIGO+"'"
FillGetDados( nOpcx, "TDA", 1, "TD9->TD9_CODIGO", {|| }, {|| .T.},{"TDA_CODOCO"},,,,{|| NGMontaAcols("TDA", TD9->TD9_CODIGO,cGetWhlGG)})

aColsGG := aClone(aCols)
aHeadGG := aClone(aHeader)

If Empty(aColsGG) .Or. nOpcx == 3
   aColsGG := BlankGetd(aHeadGG)
Endif

oGetGases := MsNewGetDados():New(005, 005, 100, 200,IIF(!Inclui.And.!Altera,0,GD_INSERT+GD_UPDATE),"AllWaysTrue()","AllWaysTrue()",,,,1,,,,oFolder480:aDialogs[2],aHeadGG, aColsGG)
oGetGases:oBrowse:Default()
oGetGases:oBrowse:Refresh()
oGetGases:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

PutFileInEof("TDA")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 03 - Fonte Geradora         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanelH3 := TPanel():New(0,0,,oFolder480:aDialogs[3],,,,,RGB(67,70,87),200,200,.F.,.F.)
oPanelH3:Align := CONTROL_ALIGN_TOP
oPanelH3:nHeight := 20

@ 002,004 Say OemToAnsi(STR0024) Of oPanelH3 Color RGB(255,255,255) Pixel //"Marque a fonte geradora dos Gases de Efeito Estufa."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MarkBrowse                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oMark480 := MsSelect():New(cTRBMRK,"OK",,aCpoFon,@lINVERTE,@cMarca,{0,0,250,187},,,oFolder480:aDialogs[3])
oMark480:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oMark480:oBrowse:lHASMARK := .T.
oMark480:oBrowse:lCANALLMARK := .F.
oMark480:oBrowse:bAllMark := {|| }
oMark480:bMark := {|| SG480INV(cMarca,lInverte,(cTRBMRK)->(Recno()),nOpcx) .and. oMark480:oBrowse:Refresh(.T.)}

If !Inclui
	Processa( { || SG480TRBK(TD9->TD9_CODPRO, cCodEst, TD9->TD9_CODNIV, TD9->TD9_CODFON, 2)}, STR0025, STR0026) //"Aguarde..."###"Carregando Fontes de Emissão"
Endif
dbSelectArea(cTRBMRK)
dbSetOrder(1)
dbGoTop()
oMark480:oBrowse:Refresh(.T.)

//Implementa Click da Direita
If Len(aSMenu) > 0
	NGPOPUP(aSMenu,@oMenu)
	oDlg480:bRClicked	:= { |o,x,y| oMenu:Activate(x,y,oDlg480)}
	oPanelTop:bRClicked	:= { |o,x,y| oMenu:Activate(x,y,oPanelTop)}
	oPanelBot:bRClicked	:= { |o,x,y| oMenu:Activate(x,y,oPanelBot)}
	oPanelH1:bRClicked	:= { |o,x,y| oMenu:Activate(x,y,oPanelH1)}
	oPanelH2:bRClicked	:= { |o,x,y| oMenu:Activate(x,y,oPanelH2)}
	oPanelH3:bRClicked	:= { |o,x,y| oMenu:Activate(x,y,oPanelH3)}
	oPnlLgnd:bRClicked	:= { |o,x,y| oMenu:Activate(x,y,oPnlLgnd)}
	oFolder480:bRClicked:= { |o,x,y| oMenu:Activate(x,y,oFolder480)}
Endif

Activate Dialog oDLG480 On Init (EnchoiceBar(oDLG480,{|| lOk:=.T.,If(SG480TUDOK(nOpcx),(lOk:=.T.,oDLG480:End()),lOk:=.F.)},;
																				{|| lOk:=.F.,oDLG480:End()})) Centered
If lOk .and. nOpcx != 2
	M->TD9_ORIGEM := "1"//Origem SGA
	M->TD9_ESTRUT := cCodEst
	M->TD9_CODNIV := aLocal[aScan(aLocal, {|x| x[2] == .T.} )][1]
	//Verifica se foi marcada a fonte geradora
	M->TD9_CODFON := SG480RETF()
	SG480GRAVA(nOpcx, oGetGases:aCols, aHeadGG)
Else
	If nOpcx == 3
		RollBackSX8()
	Endif
Endif

//Deleta TRB
oTempSGA:Delete()
oTempFON:Delete()
dbSelectArea("TD9")

NGRETURNPRM(aNGBEGINPRM)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SG480COR  ºAutor  ³Roger Rodrigues     º Data ³  20/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Altera cor dos itens que foram previamente marcados         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SGAA470                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SG480COR(cLocal)
Local i
Local aArea := GetArea()

For i:=1 to Len(aDefinido)
	If !aDefinido[i][Len(aDefinido[i])] .and. aScan(aMarcado, {|x| x[1] == aDefinido[i][1] } ) == 0
		dbSelectArea(cTRBSGA)
		dbSetOrder(2)
		If dbSeek(cCodest+aDefinido[i][1])
			dbSelectArea(oTree:cArqTree)
			dbSetOrder(4)
			If dbSeek(aDefinido[i][1])
				If SubStr( (oTree:cArqTree)->T_CARGO, 1, 3 ) == aDefinido[i][1] .and. SubStr( (oTree:cArqTree)->T_CARGO, 7, 1 ) != "3"
					oTree:TreeSeek(aDefinido[i][1])
					oTree:ChangeBmp("Folder5","Folder6")
					(oTree:cArqTree)->T_CARGO := SubStr(oTree:getCargo(),1,6)+"3"
					aDefinido[i][Len(aDefinido[i])] := .T.
					oTree:TreeSeek(cLocal)
				EndIf
			Endif
		Endif
	Endif
Next i

For i:=1 to Len(aMarcado)
	If !aMarcado[i][Len(aMarcado[i])]
		dbSelectArea(cTRBSGA)
		dbSetOrder(2)
		If dbSeek(cCodest+aMarcado[i][1])
			dbSelectArea(oTree:cArqTree)
			dbSetOrder(4)
			If dbSeek(aMarcado[i][1])
				If SubStr( (oTree:cArqTree)->T_CARGO, 1, 3 ) == aMarcado[i][1] .and. SubStr( (oTree:cArqTree)->T_CARGO, 7, 1 ) != "2"
					oTree:TreeSeek(aMarcado[i][1])
					oTree:ChangeBmp("Folder7","Folder8")
					(oTree:cArqTree)->T_CARGO := SubStr(oTree:getCargo(),1,6)+"2"
					aMarcado[i][Len(aMarcado[i])] := .T.
					oTree:TreeSeek(cLocal)
				EndIf
			Endif
		Endif
	Endif
Next i

RestArea(aArea)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SG480TD3  ºAutor  ³Roger Rodrigues     º Data ³  20/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna array com todos locais de consumos disponiveis      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SGAA480                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SG480TD3(cCodPro)
Local aArray := {}

//Percorre localizações previamente selecionadas
dbSelectArea("TD3")
dbSetOrder(1)
dbSeek(xFilial("TD3")+cCodPro)
While !eof() .and. xFilial("TD3")+cCodPro == TD3->TD3_FILIAL+TD3->TD3_CODPRO
	If aScan(aArray, {|x| x[1] == TD3->TD3_CODNIV}) == 0
		aAdd(aArray, {TD3->TD3_CODNIV, .F.})
	Endif
	dbSelectArea("TD3")
	dbSkip()
End

Return aArray
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SG480VLPROºAutor  ³Roger Rodrigues     º Data ³  20/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega os gases do produto                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SGAA480                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SG480VLPRO(lValidPro)
Local lRet := .T.
Local i, cCampo
Local nFator
Local nPosGas := aScan( aHeadGG,{|x| Trim(Upper(x[2])) == "TDA_CODGAS"})
Local nPosGer := aScan( aHeadGG,{|x| Trim(Upper(x[2])) == "TDA_GERADO"})
Default lValidPro := .F.

//Carrega gases na GetDados
If !Empty(M->TD9_CODPRO)
	If lValidPro
		//Limpa MarkBrowse
		dbSelectArea(cTRBMRK)
		ZAP
		oMark480:oBrowse:Refresh(.T.)
		//Carrega Informacoes dos gases
		aColsGG := aClone(SG480CARG(M->TD9_CODPRO, M->TD9_QUANTI, aHeadGG))
		If Len(aColsGG) == 0
			aColsGG := BlankGetd(aHeadGG)
			lRet := .F.
			ShowHelpDlg(STR0006,{STR0016},1,; //"Atenção"###"Não foram definidos os Gases de Efeito Estufa gerados pelo Produto."
						{STR0017}) //"Definir os Gases gerados pelo produto na rotina Emissores de Gases."
		Endif
		aDefinido := SG480TD3(M->TD9_CODPRO)//Carrega localizacoes disponiveis
		aLocal := {}
		aMarcado := {}
		dbSelectArea(cTRBSGA)
		Zap
		oMark480:oBrowse:Refresh(.T.)
		aItensCar := {}
		//Limpa a arvore e recarrega do zero de acordo com o modulo
		oTree:Reset()
		oTree:SetUpdatesEnable(.F.)
		SG470TREE( 1, aClone(aDefinido) )
		oTree:SetUpdatesEnable(.T.)
		oTree:Refresh()
		oTree:SetFocus()
	Else
		aColsGG := aClone(oGetGases:aCols)
		For i:=1 to Len(aColsGG)
			nFator := 0
			dbSelectArea("TD4")
			dbSetOrder(1)
			If dbSeek(xFilial("TD4")+M->TD9_CODPRO+aColsGG[i][nPosGas])
				nFator := TD4->TD4_FATOR
			Endif
			aColsGG[i][nPosGer] := nFator * M->TD9_QUANTI
		Next i
	Endif
	oGetGases:aCols:= aClone(aColsGG)
	oGetGases:nMax := Len(aColsGG)
	oGetGases:Refresh()
	oGetGases:nAt  := 1
Endif

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SG480MRK  ºAutor  ³Roger Rodrigues     º Data ³  23/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Marca o item selecionado na estrutura organizacional        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SGAA480                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SG480MRK()
Local nPos

If oTree:isEmpty()
	Return .F.
EndIf

dbSelectArea(oTree:cArqTree)

If SubStr( oTree:getCargo(), 7, 1 ) == "2"//Desmraca

	oTree:ChangeBmp("Folder5","Folder6")
	(oTree:cArqTree)->T_CARGO := SubStr(oTree:getCargo(),1,6)+"3"

	If (nPos := aScan(aLocal, {|x| x[1] == SubStr( oTree:GetCargo(), 1, 3 )})) > 0
		aLocal[nPos][2] := .F.
	Else
		aAdd( aLocal,{ SubStr( oTree:GetCargo(), 1, 3 ),.F. } )
	EndIf

	//Limpa MarkBrowse
	dbSelectArea(cTRBMRK)
	ZAP
	oMark480:oBrowse:Refresh(.T.)

ElseIf SubStr( oTree:getCargo(), 7, 1 ) == "3"//Marca

	If aScan(aLocal, {|x| x[2] == .T.}) == 0//Se nao encontra local marcado

		oTree:ChangeBmp("Folder7","Folder8")

		(oTree:cArqTree)->T_CARGO := SubStr(oTree:getCargo(),1,6)+"2"
		If (nPos := aScan(aLocal, {|x| x[1] == SubStr( oTree:GetCargo(), 1, 3 )})) > 0
			aLocal[nPos][2] := .T.
		Else
			aAdd( aLocal,{ SubStr( oTree:GetCargo(), 1, 3 ),.T. } )
		EndIf

		Processa( { || SG480TRBK(M->TD9_CODPRO, cCodEst, SubStr(oTree:GetCargo(),1,3))}, STR0025, STR0026) //"Aguarde..."###"Carregando Fontes de Emissão"
	Else
		ShowHelpDlg(STR0006,{STR0018},1) //"Atenção"###"Só é possível a marcação de uma localização por ocorrência."
		Return .F.
	Endif

Else
	ShowHelpDlg(STR0006,{STR0019},1,; //"Atenção"###"Só podem ser marcadas as localizações que foram definidas como Local de Consumo."
						{STR0020},1) //"Marque as localizações em amarelo, ou seja, definidas como Local de Consumo."
	Return .F.
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SG480TUDOKºAutor  ³Roger Rodrigues     º Data ³  23/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz verificacao de todos objetos da tela                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SGAA480                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SG480TUDOK(nOpcx)

If nOpcx != 2 .and. nOpcx != 5
	If !SG480VLDT()//Verifica a data+hora
		Return .F.
	Endif
	If !Obrigatorio(aGets,aTela)
		Return .F.
	Endif
	If aScan(aLocal, {|x| x[2] == .T.} ) == 0
		ShowHelpDlg(STR0006,{STR0021},1,; //"Atenção"###"Não foi selecionado nenhum Local de Consumo."
								{STR0022}) //"Selecione um Local de Consumo na Estrutura Organizacional, localização em amarelo."
		Return .F.
	Endif
	//Verifica se foi marcada a fonte geradora
	If Empty(SG480RETF())
		dbSelectArea(cTRBMRK)
		dbGoTop()
		ShowHelpDlg(STR0006,{STR0027},1,; //"Não foi selecionada nenhuma Fonte Geradora para a Ocorrência."
							{STR0028},1) //"Marque uma Fonte Geradora de Gases no Folder 'Fonte Geradora'."
		Return .F.
	Endif
Endif
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SG480GRAVAºAutor  ³Roger Rodrigues     º Data ³  23/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz gravacao da ocorrência                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SGAA480                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SG480GRAVA(nOpcx, aColsGG, aHeadGG)
Local i, j, nPos, nPosGas

//Grava o Ocorrencia
dbSelectArea("TD9")
dbSetOrder(1)
If dbSeek(xFilial("TD9")+M->TD9_CODIGO)
	RecLock("TD9",.F.)
Else
	RecLock("TD9",.T.)
	ConfirmSX8()
Endif

If nOpcx == 5
	dbDelete()
Else
	For i:=1 to Fcount()
		If "_FILIAL"$Upper(FieldName(i))
			FieldPut(i, xFilial("TD9"))
		Else
			FieldPut(i, &("M->"+FieldName(i)))
		Endif
	Next i
Endif
MsUnlock("TD9")

nPosGas := aScan( aHeadGG,{|x| Trim(Upper(x[2])) == "TDA_CODGAS"})
//Grava Gases
For j:=1 to Len(aColsGG)
	If !aColsGG[j][Len(aColsGG[j])] .and. nOpcx != 5
		dbSelectArea("TDA")
		dbSetOrder(1)
		If dbSeek(xFilial("TDA")+M->TD9_CODIGO+aColsGG[j][nPosGas])
			RecLock("TDA",.F.)
		Else
			RecLock("TDA",.T.)
		Endif
		For i:=1 to FCount()
			If "_FILIAL"$FieldName(i)
				FieldPut(i, xFilial("TDA"))
			ElseIf "_CODOCO"$FieldName(i)
				FieldPut(i, M->TD9_CODIGO)
			ElseIf (nPos := aScan(aHeadGG, {|x| Trim(Upper(x[2])) == Trim(Upper(FieldName(i))) })) > 0
				FieldPut(i, aColsGG[j][nPos])
			Endif
		Next i
		MsUnlock("TDA")
	Else
		dbSelectArea("TDA")
		dbSetOrder(1)
		If dbSeek(xFilial("TDA")+M->TD9_CODIGO+aColsGG[j][nPosGas])
			RecLock("TDA",.F.)
			dbDelete()
			MsUnlock("TDA")
		Endif
	Endif
Next j

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SG480TRBK ºAutor  ³Roger Rodrigues     º Data ³  26/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega arquivo temporario com as fontes de emissao do      º±±
±±º          ³produto+localizacao                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SGAA480                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SG480TRBK(cCodPro, cEstrut, cCodNiv, cCodFon, nOpcx)

	Local i, cCampo := ""
	Local lOldInclui:= Inclui
	Local lOldAltera:= Altera
	Default cCodFon := ""
	Default nOpcx	:= 3
	//Limpa arquivo temporario
	dbSelectArea(cTRBMRK)
	Zap
	oMark480:oBrowse:Refresh(.T.)

	//Altera conteudo das variaveis para inicializador padrao dos campos
	Inclui := .F.
	Altera := .T.
	//Se for inclusao pega a tabela atual
	If nOpcx == 3
		dbSelectArea("TD5")
		dbSetOrder(1)
		dbSeek(xFilial("TD5")+cCodPro+cEstrut+cCodNiv)
		ProcRegua(TD5->(RecCount()))
		While !eof() .and. xFilial("TD5")+cCodPro+cEstrut+cCodNiv == TD5->(TD5_FILIAL+TD5_CODPRO+TD5_ESTRUT+TD5_CODNIV)
			IncProc()
			RegToMemory("TD5",.F.)//Joga registro na memoria
			dbSelectArea(cTRBMRK)
			dbSetOrder(1)
			If dbSeek(TD5->TD5_CODFON)
				RecLock(cTRBMRK, .F.)
			Else
				RecLock(cTRBMRK, .T.)
			Endif
			For i:=1 to FCount()
				cCampo := FieldName(i)
				If FieldName(i) == "OK"
					FieldPut(i, If(TD5->TD5_CODFON != cCodFon, Space(2), cMarca))
				ElseIf TD5->(FieldPos(cCampo)) > 0 //Verifica se o campo eh real
					FieldPut(i, &("TD5->"+cCampo))
				ElseIf ExistIni(FieldName(i))//Se o campo for virtual executa relacao
					FieldPut(i, InitPad( GetSx3Cache( cCampo, 'X3_RELACAO' ) ))
				Endif
			Next i
			MsUnlock(cTRBMRK)

			dbSelectArea("TD5")
			dbSkip()
		End
	Else//Pega do Historico
		dbSelectArea("TD8")
		dbSetOrder(1)
		dbSeek(xFilial("TD8")+cCodPro+cEstrut+cCodNiv)
		ProcRegua(TD8->(RecCount()))
		While !eof() .and. xFilial("TD8")+cCodPro+cEstrut+cCodNiv == TD8->(TD8_FILIAL+TD8_CODPRO+TD8_ESTRUT+TD8_CODNIV)
			IncProc()
			If DTOS(TD9->TD9_DATA)+TD9->TD9_HORA < DTOS(TD8->TD8_DATA)+Substr(TD8->TD8_HORA,1,5)
				dbSelectArea("TD8")
				dbSkip()
				Loop
			Endif
			dbSelectArea(cTRBMRK)
			dbSetOrder(1)
			If TD8->TD8_OPERAC == "3"
				If dbSeek(TD8->TD8_CODFON)
					RecLock(cTRBMRK, .F.)
					dbDelete()
					MsUnlock(cTRBMRK)
				Endif
			Else
				If dbSeek(TD8->TD8_CODFON)
					RecLock(cTRBMRK, .F.)
				Else
					RecLock(cTRBMRK, .T.)
				Endif
				For i:=1 to FCount()
					cCampo := PrefixoCpo("TD8")+Substr(FieldName(i),At("_",FieldName(i)))
					If FieldName(i) == "OK"
						FieldPut(i, If(TD8->TD8_CODFON != cCodFon, Space(2), cMarca))
					ElseIf TD8->(FieldPos(cCampo)) > 0 //Verifica se o campo eh real
						FieldPut(i, &("TD8->"+cCampo))
					ElseIf ExistIni(cCampo)//Se o campo for virtual executa relacao
						FieldPut(i, InitPad( GetSx3Cache( cCampo, 'X3_RELACAO' ) ))
					Endif
				Next i
				MsUnlock(cTRBMRK)
			Endif
			dbSelectArea("TD8")
			dbSkip()
		End
	Endif
	//Refresh no MarkBrowse
	dbSelectArea(cTRBMRK)
	dbSetOrder(1)
	dbGoTop()
	oMark480:oBrowse:Refresh(.T.)

	Inclui := lOldInclui
	Altera := lOldAltera

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SG480INV  ºAutor  ³Roger Rodrigues     º Data ³  26/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inverte marcacao do MarkBrowse                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SGAA480                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SG480INV(cMarca,lInverte,nRegs,nOpcx)
Local aArea := GetArea()
Local nQtde := 0

Dbselectarea(cTRBMRK)
Dbgoto(nRegs)
If !eof()
	If nOpcx == 5 .or. nOpcx == 2
		If Empty((cTRBMRK)->OK)
			(cTRBMRK)->OK := cMarca
		Else
			(cTRBMRK)->OK := Space(2)
		Endif
	Else
		If !Empty((cTRBMRK)->OK)
			dbSelectArea(cTRBMRK)
			dbSetOrder(1)
			dbGoTop()
			While !eof()
				If !Empty((cTRBMRK)->OK)
					nQtde ++
				Endif
				dbSelectArea(cTRBMRK)
				dbSkip()
			End
			If nQtde > 1
				dbSelectArea(cTRBMRK)
				dbGoTo(nRegs)
				RecLock(cTRBMRK, .F.)
				(cTRBMRK)->OK := Space(2)
				MsUnlock(cTRBMRK)
				ShowHelpDlg(STR0006,{STR0029},1) //"Atenção"###"Só é possível marcar uma Fonte Geradora por Ocorrência."
				Return .F.
			Endif
		Endif
	Endif
Endif
RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SGAA480   ºAutor  ³Roger Rodrigues     º Data ³  26/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna fonte geradora marcada                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SGAA480                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SG480RETF()
Local cFonte := ""
Local aArea  := GetArea()
dbSelectArea(cTRBMRK)
dbSetOrder(1)
dbGoTop()
While !eof()
	If !Empty((cTRBMRK)->OK)
		cFonte := (cTRBMRK)->TD5_CODFON
		Exit
	Endif
	dbSelectArea(cTRBMRK)
	dbSkip()
End
RestArea(aArea)
Return cFonte

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SG480VLDT ºAutor  ³Roger Rodrigues     º Data ³  26/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida data+hora de inclusao da ocorrência do GEE           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SGAA480                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SG480VLDT()
Local lRet := .T.
Local dData:= CTOD("")
Local cHora:= "  :  "

//Verifica alteracao nos locais
dbSelectArea("TD6")
dbSetOrder(2)
dbSeek(xFilial("TD6")+M->TD9_CODPRO+DTOS(M->TD9_DATA)+M->TD9_HORA,.T.)
While !eof()
	If DTOS(TD6->TD6_DATA)+Substr(TD6->TD6_HORA,1,5) > DTOS(dData)+cHora
		dData := TD6->TD6_DATA
		cHora := Substr(TD6->TD6_HORA,1,5)
	Endif
	dbSelectArea("TD6")
	dbSkip()
End
//Verifica alteracao nos gases
dbSelectArea("TD7")
dbSetOrder(2)
dbSeek(xFilial("TD7")+M->TD9_CODPRO+DTOS(M->TD9_DATA)+M->TD9_HORA,.T.)
While !eof()
	If DTOS(TD7->TD7_DATA)+Substr(TD7->TD7_HORA,1,5) > DTOS(dData)+cHora
		dData := TD7->TD7_DATA
		cHora := Substr(TD7->TD7_HORA,1,5)
	Endif
	dbSelectArea("TD7")
	dbSkip()
End

//Verifica alteracao nas fontes de emissao
dbSelectArea("TD8")
dbSetOrder(2)
dbSeek(xFilial("TD8")+M->TD9_CODPRO+DTOS(M->TD9_DATA)+M->TD9_HORA,.T.)
While !eof()
	If DTOS(TD8->TD8_DATA)+Substr(TD8->TD8_HORA,1,5) > DTOS(dData)+cHora
		dData := TD8->TD8_DATA
		cHora := Substr(TD8->TD8_HORA,1,5)
	Endif
	dbSelectArea("TD8")
	dbSkip()
End

//Caso a data seja menor que a ultima definicao
If DTOS(M->TD9_DATA)+M->TD9_HORA < DTOS(dData)+cHora
	ShowHelpDlg(STR0006,{STR0030},1,; //"Atenção"###"Existem alterações na definição do produto com Data+Hora posterior a informada."
						{STR0031,DTOC(dData)+" "+cHora},2) //"Favor informar uma Data+Hora maior que:"
	lRet := .F.
ElseIf DTOS(M->TD9_DATA)+M->TD9_HORA > DTOS(dDataBase)+Substr(Time(),1,5)
	ShowHelpDlg(STR0006,{STR0032},1,; //"Atenção"###"Não é possível cadastrar Ocorrências com Data+Hora maior que a atual."
						{STR0033},1) //"Favor informar uma Data+Hora menor ou igual a atual."
	lRet := .F.
Endif
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SG480CARG ºAutor  ³Roger Rodrigues     º Data ³  27/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega em um aCols todos os gases gerados pelo produto     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SGAA480/SGAUTIL                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SG480CARG(cCodPro, nQuanti, aHeaderGas)
Local aArray := {}
Local i

dbSelectArea("TD4")
dbSetOrder(1)
dbSeek(xFilial("TD4")+cCodPro)
While !eof() .and. xFilial("TD4")+cCodPro == TD4->TD4_FILIAL+TD4->TD4_CODPRO
	aAdd(aArray, BlankGetd(aHeaderGas)[1])//Adiciona uma linha no acols
	For i:=1 to Len(aHeaderGas)
		cCampo := Trim(Upper(aHeaderGas[i][2]))
		If "_CODGAS" $ cCampo
			aArray[Len(aArray)][i] := TD4->TD4_CODGAS
		ElseIf "_DESGAS" $ cCampo
			aArray[Len(aArray)][i] := NGSEEK("TD0", TD4->TD4_CODGAS, 1, "TD0->TD0_DESCRI")
		ElseIf "_GERADO" $ cCampo
			aArray[Len(aArray)][i] := TD4->TD4_FATOR * nQuanti
		ElseIf "_UNIGAS" $ cCampo
			aArray[Len(aArray)][i] := NGSEEK("TD0", TD4->TD4_CODGAS, 1, "TD0->TD0_UNIMED")
		Endif
	Next i
	dbSelectArea("TD4")
	dbSkip()
End

Return aArray
