#INCLUDE "SGAA470.ch"
#include "Protheus.ch"

#define _nVERSAO 2

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSGAA470   บAutor  ณRoger Rodrigues     บ Data ณ  11/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefinicao de Produtos Geradores de Gases - GEE              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGASGA                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SGAA470()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Armazena variaveis p/ devolucao (NGRIGHTCLICK) 	   					  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aNGBEGINPRM 	:= NGBEGINPRM(_nVERSAO)
Private cCadastro 	:= STR0001 //"Produtos Geradores de Gases - GEE"
Private aRotina		:= MenuDef()

If !SGAUPDGEE()//Verifica se o update de GEE esta aplicado
	Return .F.
Endif

If !SGAUPDCAMP()
	Return .F.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Endereca a funcao de BROWSE                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("TD2")
dbSetOrder(1)
mBrowse( 6, 1,22,75,"TD2")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Devolve variaveis armazenadas (NGRIGHTCLICK) 					 	  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
NGRETURNPRM(aNGBEGINPRM)

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ MenuDef  ณ Autor ณ Roger Rodrigues       ณ Data ณ10/08/2010ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณUtilizacao de Menu Funcional.                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SigaSGA                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ    1 - Pesquisa e Posiciona em um Banco de Dados           ณฑฑ
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ    3 - Inclui registros no Bancos de Dados                 ณฑฑ
ฑฑณ          ณ    4 - Altera o registro corrente                          ณฑฑ
ฑฑณ          ณ    5 - Remove o registro corrente do Banco de Dados        ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MenuDef()
Local aRotina := {	{ STR0002	, "AxPesqui", 0 , 1},; //"Pesquisar"
                    { STR0003	, "SG470INC"	, 0 , 2},; //"Visualizar"
                    { STR0004	, "SG470INC"	, 0 , 3},; //"Incluir"
                    { STR0005	, "SG470INC"	, 0 , 4},; //"Alterar"
                    { STR0006	, "SG470INC"	, 0 , 5, 3}} //"Excluir"

Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG470INC  บAutor  ณRoger Rodrigues     บ Data ณ  11/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta tela para definicao Produtos Geradores de Gases - GEE บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA470                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG470INC(cAlias,nRecno,nOpcx)
Local aNGBEGINPRM := If(!IsInCallStack("SGAA470"),NGBEGINPRM(_nVERSAO,"SGAA470",,.f.),{})
Local cTitulo := STR0001 //"Produtos Geradores de Gases - GEE"
Local i
Local lOk := .F.
Local nIdx := 0
Local aPages:= {},aTitles:= {}
Local oDlg470,oFolder470,oSplitter
Local oPanelTop,oPanelBot,oPanelF1,oPnlLgnd
Local oPanelH1, oPanelH2,oPnlBtn, oMenu, oTempTRB

//Variaveis de tamanho de tela e objetos
Local aSize := {}, aObjects := {}, aInfo := {}, aPosObj := {}

//Variaveis da GetDados
Local cGetWhlGas  := "", cGetWhlFon:= ""
Private aColsGas  := {}, aColsFon  := {}, aColsEst := {}
Private aHeadGas  := {}, aHeadFon  := {}, aHeadEst := {}
Private aSvGasCols:= {}, aSvFonCols:= {}, aSvEstCols := {}
Private nTD4 := 0, nTD5 := 0//Variaveis para o When dos campos TD4_CODGAS e TD5_CODFON
Private oGetEst, oGetFon

//Variaveis de Tela
Private aTela := {}, aGets := {}

//Variaveis para Estrutura Organizacional e TRB
Private aLocal := {}, aMarcado := {}
Private oTree
Private aVETINR := {}, cArq470, aTRB := SGATRBEST(.T.)
Private aItensCar := {},nNivel := 0,nMaxNivel := 0
Private cCodEst := "001", cDesc := NGSEEK("TAF","001000",1,"TAF->TAF_NOMNIV")
Private lRateio := NGCADICBASE("TAF_RATEIO"	,"D","TAF",.F.)
Private lRetS 	:= NGCADICBASE("TAF_ETAPA"	,"A","TAF",.F.)

//Definicao de tamanho de tela e objetos
aSize := MsAdvSize(,.f.,430)
Aadd(aObjects,{030,030,.t.,.t.})
Aadd(aObjects,{100,100,.t.,.t.})
aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
aPosObj := MsObjSize(aInfo, aObjects,.t.)

dbSelectArea("TAF")
dbSetOrder(1)
If !dbSeek(xFilial("TAF")+cCodest+"000")
	ShowHelpDlg(STR0007,{STR0008},2,; //"Aten็ใo"###"Nใo existe Estrutura Organizacional cadastrada para este M๓dulo."
								{STR0009}) //"Favor cadastrar uma Estrutura Organizacional."
	Return .F.
Endif

//Cria arquivo temporario
cTRBSGA := aTRB[3]
oTempTRB := FWTemporaryTable():New( cTRBSGA, aTRB[1] )
For nIdx := 1 To Len( aTRB[2] )
	oTempTRB:AddIndex( RETASC( cValToChar( nIdx ) , 1 , .T. ), aTRB[2,nIdx] )
Next nIdx

oTempTRB:Create()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria variaveis de Fontes de Emissaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aCols := {}
aHeader := {}

//Criacao do aCols com estrutura e nivel
cGetWhlFon := "TD5->TD5_FILIAL == '"+xFilial("TD5")+"' .AND. TD5->TD5_CODPRO == '"+TD2->TD2_CODPRO+"'"
FillGetDados( nOpcx, "TD5", 1, "TD2->TD2_CODPRO", {|| }, {|| .T.},{"TD5_CODPRO"},,,,{|| NGMontaAcols("TD5", TD2->TD2_CODPRO,cGetWhlFon)})
aColsFFon := aClone(aCols)
aHeadFFon:= aClone(aHeader)

If Empty(aColsFFon) .Or. nOpcx == 3
   aColsFFon := {}
Endif
aSvFonCols:= aClone(aColsFFon)

aCols := {}
aHeader := {}
//Criacao de aHeader sem estrutura e nivel
cGetWhlFon := "TD5->TD5_FILIAL == '"+xFilial("TD5")+"' .AND. TD5->TD5_CODPRO == '"+TD2->TD2_CODPRO+"'"
FillGetDados( nOpcx, "TD5", 1, "TD2->TD2_CODPRO", {|| }, {|| .T.},{"TD5_CODPRO", "TD5_ESTRUT", "TD5_CODNIV"},;
				,,,{|| NGMontaAcols("TD5", TD2->TD2_CODPRO,cGetWhlFon)})

aHeadFon := aClone(aHeader)

//Cria os Folders
Aadd(aTitles,OemToAnsi(STR0010)) //"Locais de Consumo"
Aadd(aPages,"Header 1")
Aadd(aTitles,OemToAnsi(STR0011)) //"Gases Gerados"
Aadd(aPages,"Header 2")

Inclui := (nOpcx == 3)
Altera := (nOpcx == 4)

Define MsDialog oDLG470 Title OemToAnsi(cTitulo) From aSize[7],0 To aSize[6],aSize[5] Of oMainWnd Pixel

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta Estrutura da Tela            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSplitter := tSplitter():New(0,0,oDlg470,100,100,1 )
oSplitter:Align := CONTROL_ALIGN_ALLCLIENT

oPanelTop := TPanel():New(0,0,,oSplitter,,,,,,10,10,.F.,.F.)
oPanelTop:nHeight := 6
oPanelTop:Align := CONTROL_ALIGN_TOP

oPanelBot := TPanel():New(0,0,,oSplitter,,,,,,10,10,.F.,.F.)
oPanelBot:Align := CONTROL_ALIGN_BOTTOM

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Parte de Superior da Tela          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Dbselectarea("TD2")
RegToMemory("TD2",(nOpcx == 3))
oEnc470 := MsMGet():New("TD2",nRecno,nOpcx,,,,,aPosObj[1],,,,,,oPanelTop)
oEnc470:oBox:Align := CONTROL_ALIGN_ALLCLIENT

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Parte Inferior da Tela             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oFolder470 := TFolder():New(0,0,aTitles,aPages,oPanelBot,,,,.T.,.f.)
oFolder470:aDialogs[1]:oFont := oDLG470:oFont
oFolder470:aDialogs[2]:oFont := oDLG470:oFont
oFolder470:Align := CONTROL_ALIGN_ALLCLIENT

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Folder 01 - Locais de Consumo      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oPanelH1 := TPanel():New(0,0,,oFolder470:aDialogs[1],,,,,RGB(67,70,87),200,200,.F.,.F.)
oPanelH1:Align := CONTROL_ALIGN_TOP
oPanelH1:nHeight := 20

@ 002,004 Say OemToAnsi(STR0013) Of oPanelH1 Color RGB(255,255,255) Pixel //"Escolha o Local Consumidor clicando duas vezes sobre a pasta."

oPanelF1 := TPanel():New(0,0,,oFolder470:aDialogs[1],,,,,,10,10,.F.,.F.)
oPanelF1:Align := CONTROL_ALIGN_ALLCLIENT

//Carrega todos niveis selecionados
If !Inclui
	dbSelectArea("TD3")
	dbSetOrder(1)
	dbSeek(xFilial("TD3")+TD2->TD2_CODPRO)
	While !eof() .and. xFilial("TD3")+TD2->TD2_CODPRO == TD3->TD3_FILIAl+TD3->TD3_CODPRO
		If aScan(aLocal,{|x| Trim(Upper(x[1])) == TD3->TD3_CODNIV}) == 0
			aAdd(aLocal, {TD3->TD3_CODNIV, TD3->TD3_PORCEN, .T.} )
		Endif
		dbSelectArea("TD3")
		dbSkip()
	End
Endif
aMarcado := aClone(aLocal)

oTree := DbTree():New(005, 022, 170, 302, oPanelF1,,, .t.)
oTree:Align := CONTROL_ALIGN_ALLCLIENT

//Carrega estrutura organizacional
SG470TREE( 1, aMarcado )

If Str(nOpcx,1) $ "2/5"
	oTree:bChange	:= {|| SG470TREE(2)}
	oTree:BlDblClick:= {||}
Else
	oTree:bChange	:= {|| SG470TREE(2)}
	oTree:blDblClick:= {|| SG470MRK()}
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Painel de Legenda                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oPnlBtn := TPanel():New(00,00,,oPanelF1,,,,,RGB(67,70,87),12,12,.F.,.F.)
oPnlBtn:Align := CONTROL_ALIGN_LEFT

oBtnMrk  := TBtnBmp():NewBar("ng_ico_altid","ng_ico_altid",,,,{|| SG470MRK()},,oPnlBtn,,,STR0025,,,,,"")//"Marcar Localiza็ใo"
oBtnMrk:Align  := CONTROL_ALIGN_TOP
oBtnMrk:lVisible := Inclui .or. Altera

oBtnFon  := TBtnBmp():NewBar("ng_ico_relac","ng_ico_relac",,,,{|| SG470FON(oTree:GetCargo(),.T.)},,oPnlBtn,,,STR0026,,,,,"")//"Fontes de Emissใo"
oBtnFon:Align  := CONTROL_ALIGN_TOP
oBtnFon:lVisible := .T.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Painel de Legenda                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oPnlLgnd := TPanel():New(00,00,,oPanelF1,,,,,RGB(200,200,200),12,12,.F.,.F.)
oPnlLgnd:Align := CONTROL_ALIGN_BOTTOM
oPnlLgnd:nHeight := 30

@ 002,010 Bitmap oLgnd1 Resource "Folder10" Size 25,25 Pixel Of oPnlLgnd Noborder When .F.
@ 005,025 Say OemToAnsi(STR0014) Of oPnlLgnd Pixel //"Localiza็ใo Normal"

@ 002,100 Bitmap oLgnd1 Resource "Folder7" Size 25,25 Pixel Of oPnlLgnd Noborder When .F.
@ 005,115 Say OemToAnsi(STR0015) Of oPnlLgnd Pixel //"Local Consumidor"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Folder 02 - Gases Gerados          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oPanelH2 := TPanel():New(0,0,,oFolder470:aDialogs[2],,,,,RGB(67,70,87),200,200,.F.,.F.)
oPanelH2:Align := CONTROL_ALIGN_TOP
oPanelH2:nHeight := 20

@ 002,004 Say OemToAnsi(STR0016) Of oPanelH2 Color RGB(255,255,255) Pixel //"Informe os Gases gerados pelo Produto."

aCols := {}
aHeader := {}

cGetWhlGas := "TD4->TD4_FILIAL == '"+xFilial("TD4")+"' .AND. TD4->TD4_CODPRO = '"+TD2->TD2_CODPRO+"'"
FillGetDados( nOpcx, "TD4", 1, "TD2->TD2_CODPRO", {|| }, {|| .T.},{"TD4_CODPRO"},,,,{|| NGMontaAcols("TD4", TD2->TD2_CODPRO,cGetWhlGas)})

aColsGas := aClone(aCols)
aHeadGas := aClone(aHeader)

If Empty(aColsGas) .Or. nOpcx == 3
   aColsGas := BlankGetd(aHeadGas)
Endif
aSvGasCols:= aClone(aColsGas)
nTD4 := Len(aColsGas)

oGetGG := MsNewGetDados():New(005, 005, 100, 200,IIF(!Inclui.And.!Altera,0,GD_INSERT+GD_UPDATE+GD_DELETE),"SG470LINOK('TD4')","AllWaysTrue()",,,,9999,,,"SG470DELOK('TD4')",oFolder470:aDialogs[2],aHeadGas, aColsGas)
oGetGG:oBrowse:Default()
oGetGG:oBrowse:Refresh()
oGetGG:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

PutFileInEof("TD4")

//Implementa Click da Direita
If Len(aSMenu) > 0
	NGPOPUP(aSMenu,@oMenu)
	oDlg470:bRClicked	:= { |o,x,y| oMenu:Activate(x,y,oDlg470)}
	oPanelTop:bRClicked	:= { |o,x,y| oMenu:Activate(x,y,oPanelTop)}
	oPanelBot:bRClicked	:= { |o,x,y| oMenu:Activate(x,y,oPanelBot)}
	oPanelH1:bRClicked	:= { |o,x,y| oMenu:Activate(x,y,oPanelH1)}
	oPanelH2:bRClicked	:= { |o,x,y| oMenu:Activate(x,y,oPanelH2)}
	oPnlLgnd:bRClicked	:= { |o,x,y| oMenu:Activate(x,y,oPnlLgnd)}
	oFolder470:bRClicked:= { |o,x,y| oMenu:Activate(x,y,oFolder470)}
Endif

Activate Dialog oDLG470 On Init (EnchoiceBar(oDLG470,{|| lOk:=.T.,If(SG470TUDOK(nOpcx),(lOk:=.T.,oDLG470:End()),lOk:=.F.)},;
																				{|| lOk:=.F.,oDLG470:End()})) Centered

If nOpcx == 5 .and. lOk
	lOk := NGVALSX9("TD2",{"TD3","TD4","TD5","TD6","TD7","TD8"},.T.)
Endif

If lOk .and. nOpcx != 2
	SG470GRAVA(nOpcx)
Endif

//Deleta TRB
oTempTRB:Delete()
dbSelectArea("TD2")

NGRETURNPRM(aNGBEGINPRM)

Return lOk
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG470LINOKบAutor  ณRoger Rodrigues     บ Data ณ  12/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz a verificacao das linhas das GetDados                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA470                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG470LINOK(cAlias,lFim)
Local f, nQtd := 0
Local aColsOk := {}, aHeadOk := {}
Local nPosCod := 1, nPosFat := 0, nPosPor := 0, nAt := 1

Default lFim := .F.

If cAlias == "TD4"
	aColsOk := aClone(oGetGG:aCols)
	aHeadOk := aClone(aHeadGas)
	nAt := oGetGG:nAt
	nPosCod := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TD4_CODGAS"})
	nPosFat := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TD4_FATOR"})
ElseIf cAlias == "TD5"
	aColsOk := aClone(oGetFon:aCols)
	aHeadOk := aClone(aHeadFon)
	nAt := oGetFon:nAt
	nPosCod := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TD5_CODFON"})
	nPosPor := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TD5_PORCEN"})
ElseIf cAlias == "TD3"
	aColsOk := aClone(oGetEst:aCols)
	aHeadOk := aClone(aHeadEst)
	nAt := oGetEst:nAt
	nPosCod := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TD3_CODNIV"})
	nPosPor := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TD3_PORCEN"})
Endif

//Percorre aCols
For f:= 1 to Len(aColsOk)
	If !aColsOk[f][Len(aColsOk[f])]
		nQtd++
		  
		If cAlias $ "TD4,TD5"
			If f <> nAt .And. aColsOk[f][nPosCod]  == aColsOk[nat][nPosCod] .And. !aColsOk[nat][Len(aColsOk[nat])]
				Help(" ",1,STR0007,,"Campo " + aHeadOk[nPosCod][1] + " duplicado.",3,1) //"ATENวรO"###"Protocolo jแ finalizado"
				Return .F.
			EndIf
		EndIf

		If lFim .or. f == nAt
			//VerIfica se os campos obrigat๓rios estใo preenchidos
			If Empty(aColsOk[f][nPosCod])
				//Mostra mensagem de Help
				Help(1," ","OBRIGAT2",,aHeadOk[nPosCod][1],3,0)
				Return .F.
			ElseIf nPosFat > 0 .and. Empty(aColsOk[f][nPosFat])
				//Mostra mensagem de Help
				Help(1," ","OBRIGAT2",,aHeadOk[nPosFat][1],3,0)
				Return .F.
			ElseIf nPosPor > 0 .and. Empty(aColsOk[f][nPosPor])
				//Mostra mensagem de Help
				Help(1," ","OBRIGAT2",,aHeadOk[nPosPor][1],3,0)
				Return .F.
			EndIf
		EndIf
	EndIf
Next f  

If nQtd == 0 .and. lFim
	Help(1," ","OBRIGAT2",,aHeadOk[nPosCod][1],3,0)
	Return .F.
EndIf          

PutFileInEof("TD1")
PutFileInEof("TD3")
PutFileInEof("TD4")
PutFileInEof("TD5")

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG470TUDOKบAutor  ณRoger Rodrigues     บ Data ณ  12/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz validacao da enchoice e todas GetDados                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA470                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG470TUDOK(nOpcx)
Local i, nQtd := 0

If nOpcx != 2 .and. nOpcx != 5
	//Verifica Enchoice
	If !Obrigatorio(aGets,aTela)
		Return .F.
	Endif
	//Verifica se existe algum local marcado
	For i:=1 to Len(aLocal)
		If aLocal[i][Len(aLocal[i])]
			nQtd ++
		Endif
	Next
	If nQtd == 0
		ShowHelpDlg(STR0007,{STR0020},1,{STR0021}) //"Aten็ใo"###"Deve ser marcado ao menos um Local Consumidor."###"Selecione uma localiza็ใo na aba Local Consumidor."
		Return .F.
	Endif
	//Verifica GetDados de Gases
	If !SG470LINOK("TD4",.T.)
		Return .F.
	Endif
	//Traz tela de percentual das localizacoes
	If !SG470EST(nOpcx)
		Return .F.
	Endif
Endif
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG470GRAVAบAutor  ณRoger Rodrigues     บ Data ณ  12/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza gravacao das informacoes                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSG470GRAVA                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG470GRAVA(nOpcx)
Local i, j, k, nLin
Local lAltera := .F.//Variavel para gravacao do Memo
Local aColsGas:= aClone(oGetGG:aCols), aHeadGas := aClone(oGetGG:aHeader)
Local aColsNiv:= If(Type("oGetEst") != "U", aClone(oGetEst:aCols), {}), aHeadNiv := If(Type("oGetEst") != "U", aClone(oGetEst:aHeader), {})
Local aGrvHist:= {}, aLocalOK := {}
Local nPosCod := 1, nPos, nPosEst, nPosNiv
//Variaveis para historico
Local dDataAlt:= dDataBase
Local cHoraAlt:= Time()
Local cOperAlt:= ""

If Empty(aColsNiv)
	aColsNiv := If(Type("aColsEst") != "U", aClone(aColsEst), {})
Endif
If Empty(aHeadNiv)
	aHeadNiv := If(Type("aHeadEst") != "U", aClone(aHeadEst), {})
Endif
//Grava o Produto Gerador de Gases
dbSelectArea("TD2")
dbSetOrder(1)
If dbSeek(xFilial("TD2")+M->TD2_CODPRO)
	RecLock("TD2",.F.)
	lAltera := .T.
Else
	RecLock("TD2",.T.)
	lAltera := .F.
Endif

If nOpcx == 5
	dbDelete()
	MSMM(&("TD2_OBSERV"),,,,2,,,,,)
Else
	For i:=1 to Fcount()
		If "_FILIAL"$Upper(FieldName(i))
			FieldPut(i, xFilial("TD2"))
		ElseIf "_OBSERV"$Upper(FieldName(i))//Grava Memo
			If lAltera
				MSMM(&("TD2_OBSERV"),TAMSX3("TD2_MEMO1")[1],,M->TD2_MEMO1,1,,,"TD2","TD2_OBSERV")
			Else
				MSMM(,TAMSX3("TD2_MEMO1")[1],,M->TD2_MEMO1,1,,,"TD2","TD2_OBSERV")
			Endif
		Else
			FieldPut(i, &("M->"+FieldName(i)))
		Endif
	Next i
Endif
MsUnlock("TD2")

nPosCod := aScan(aHeadNiv, {|x| Trim(Upper(x[2])) =="TD3_CODNIV"} )
aGrvHist:= {}
//Verifica se existiram alteracoes
For i:=1 to Len(aSvEstCols)
	If (nPos := aScan(aColsNiv, {|x| Trim(Upper(x[nPosCod])) == aSvEstCols[i][nPosCod] } ) ) > 0
		For j:=1 to Len(aColsNiv[nPos])
			If j <= Len(aHeadNiv) .and. TD3->(FieldPos(aHeadNiv[j][2])) > 0//Considera somente os campos reais
				If aColsNiv[nPos][j] != aSvEstCols[i][j] .and. aScan(aGrvHist, {|x| x == aSvEstCols[i][nPosCod]} ) == 0
					aAdd(aGrvHist, aSvEstCols[i][nPosCod])
				Endif
			Endif
		Next j
	Endif
Next i
//Grava os Locais de Consumo
For j:= 1 to Len(aLocal)
	cOperAlt := ""
	If aLocal[j][Len(aLocal[j])] .and. nOpcx != 5
		aAdd(aLocalOK, aLocal[j])
		If (nLin := aScan(aColsNiv, {|x| Trim(Upper(x[nPosCod])) == aLocal[j][1] } ) ) > 0
			dbSelectArea("TD3")
			dbSetOrder(1)
			If dbSeek(xFilial("TD3")+M->TD2_CODPRO+cCodest+aLocal[j][1])
				If aScan(aGrvHist, {|x| x == aColsNiv[nLin][nPosCod]} ) > 0
					cOperAlt := "2"
				Endif
				RecLock("TD3",.F.)
			Else
				cOperAlt := "1"
				RecLock("TD3",.T.)
			Endif
			For i:=1 to FCount()
				If "_FILIAL"$FieldName(i)
					FieldPut(i, xFilial("TD3"))
				ElseIf "_CODPRO"$FieldName(i)
					FieldPut(i, M->TD2_CODPRO)
				ElseIf "_ESTRUT"$FieldName(i)
					FieldPut(i, cCodEst)
				ElseIf "_CODNIV"$FieldName(i)
					FieldPut(i, aLocal[j][1])
				ElseIf (nPos := aScan(aHeadNiv, {|x| Trim(Upper(x[2])) == Trim(Upper(FieldName(i))) })) > 0
					FieldPut(i, aColsNiv[nLin][nPos])
				Endif
			Next i
			MsUnlock("TD3")
			//Gera historico do registro
			If !Empty(cOperAlt)
				SG470HIST("TD3", "TD6", cOperAlt, dDataAlt, cHoraAlt, TD3->(TD3_CODPRO+TD3_ESTRUT+TD3_CODNIV))
			Endif
		Endif
	Else
		dbSelectArea("TD3")
		dbSetOrder(1)
		If dbSeek(xFilial("TD3")+M->TD2_CODPRO+cCodest+aLocal[j][1])
			//Deleta as Fontes de Emissao da Localizacao
			dbSelectArea("TD5")
			dbSetOrder(1)
			dbSeek(xFilial("TD5")+M->TD2_CODPRO+cCodest+aLocal[j][1])
			While !Eof() .and. xFilial("TD5")+M->TD2_CODPRO+cCodest+aLocal[j][1] == TD5->(TD5_FILIAL+TD5_CODPRO+TD5_ESTRUT+TD5_CODNIV)
				//Gera historico do registro
				SG470HIST("TD5", "TD8", "3", dDataAlt, cHoraAlt, TD5->(TD5_FILIAL+TD5_CODPRO+TD5_ESTRUT+TD5_CODNIV))
				RecLock("TD5",.F.)
				dbDelete()
				MsUnlock("TD5")
				dbSelectArea("TD5")
				dbSkip()
			End
			dbSelectArea("TD3")
			//Gera historico do registro
			SG470HIST("TD3", "TD6", "3", dDataAlt, cHoraAlt, TD3->(TD3_CODPRO+TD3_ESTRUT+TD3_CODNIV))
			RecLock("TD3",.F.)
			dbDelete()
			MsUnlock("TD3")
		Endif
	Endif
Next j

nPosCod := aScan( aHeadGas,{|x| Trim(Upper(x[2])) == "TD4_CODGAS"})
aGrvHist:= {}
//Verifica se existiram alteracoes
For i:=1 to Len(aSvGasCols)
	For j:=1 to Len(aSvGasCols[i])
		If aSvGasCols[i][j] != aColsGas[i][j] .and. aScan(aGrvHist, {|x| x == aSvGasCols[i][nPosCod]} ) == 0
			aAdd(aGrvHist, aSvGasCols[i][nPosCod])
		Endif
	Next j
Next i

//Grava os Gases Gerados
For j:=1 to Len(aColsGas)
	cOperAlt := ""
	//Se for registro novo e estiver deletado, desconsidera
	If aColsGas[j][Len(aColsGas[j])] .and. j > nTD4
		Loop
	Endif
	If !aColsGas[j][Len(aColsGas[j])] .and. nOpcx != 5
		dbSelectArea("TD4")
		dbSetOrder(1)
		If dbSeek(xFilial("TD4")+M->TD2_CODPRO+aColsGas[j][nPosCod])
			If aScan(aGrvHist, {|x| x == aColsGas[j][nPosCod]} ) > 0
				cOperAlt := "2"
			Endif
			RecLock("TD4",.F.)
		Else
			cOperAlt := "1"
			RecLock("TD4",.T.)
		Endif
		For i:=1 to FCount()
			If "_FILIAL"$FieldName(i)
				FieldPut(i, xFilial("TD4"))
			ElseIf "_CODPRO"$FieldName(i)
				FieldPut(i, M->TD2_CODPRO)
			ElseIf (nPos := aScan(aHeadGas, {|x| Trim(Upper(x[2])) == Trim(Upper(FieldName(i))) })) > 0
				FieldPut(i, aColsGas[j][nPos])
			Endif
		Next i
		MsUnlock("TD4")
		//Gera historico do registro
		If !Empty(cOperAlt)
			SG470HIST("TD4", "TD7", cOperAlt, dDataAlt, cHoraAlt, TD4->(TD4_CODPRO+TD4_CODGAS))
		Endif
	Else
		dbSelectArea("TD4")
		dbSetOrder(1)
		If dbSeek(xFilial("TD4")+M->TD2_CODPRO+aColsGas[j][nPosCod])
			//Gera historico do registro
			SG470HIST("TD4", "TD7", "3", dDataAlt, cHoraAlt, TD4->(TD4_CODPRO+TD4_CODGAS))
			RecLock("TD4",.F.)
			dbDelete()
			MsUnlock("TD4")
		Endif
	Endif
Next j

nPosCod := aScan( aHeadFFon,{|x| Trim(Upper(x[2])) == "TD5_CODFON"})
nPosEst := aScan( aHeadFFon,{|x| Trim(Upper(x[2])) == "TD5_ESTRUT"})
nPosNiv := aScan( aHeadFFon,{|x| Trim(Upper(x[2])) == "TD5_CODNIV"})

For k:=1 to Len(aLocalOK)
	For j:=1 to Len(aColsFFon)
		cOperAlt := ""
		If aColsFFon[j][nPosEst]+aColsFFon[j][nPosNiv] == cCodEst+aLocalOK[k][1]
			If !aColsFFon[j][Len(aColsFFon[j])] .and. nOpcx != 5
				dbSelectArea("TD5")
				dbSetOrder(1)
				If dbSeek(xFilial("TD5")+M->TD2_CODPRO+cCodEst+aLocalOK[k][1]+aColsFFon[j][nPosCod])
					//Verifica historico
					nPos := aScan(aColsFFon, {|x| x[nPosEst]+x[nPosNiv]+x[nPosCod] == ;
											aColsFFon[j][nPosEst]+aColsFFon[j][nPosNiv]+aColsFFon[j][nPosCod] .and. !x[Len(aColsFFon[j])]} )
					If nPos > 0
						For i:=1 to Len(aColsFFon[j])
							If aSvFonCols[j][i] != aColsFFon[j][i]
								cOperAlt := "2"
								Exit
							Endif
						Next i
					Endif
					RecLock("TD5",.F.)
				Else
					cOperAlt := "1"
					RecLock("TD5",.T.)
				Endif
				For i:=1 to FCount()
					If "_FILIAL"$FieldName(i)
						FieldPut(i, xFilial("TD5"))
					ElseIf "_CODPRO"$FieldName(i)
						FieldPut(i, M->TD2_CODPRO)
					ElseIf "_ESTRUT"$FieldName(i)
						FieldPut(i, cCodEst)
					ElseIf "_CODNIV"$FieldName(i)
						FieldPut(i, aLocalOK[k][1])
					ElseIf (nPos := aScan(aHeadFFon, {|x| Trim(Upper(x[2])) == Trim(Upper(FieldName(i))) })) > 0
						FieldPut(i, aColsFFon[j][nPos])
					Endif
				Next i
				MsUnlock("TD5")
				//Gera Historico
				If !Empty(cOperAlt)
					SG470HIST("TD5", "TD8", cOperAlt, dDataAlt, cHoraAlt, TD5->(TD5_FILIAL+TD5_CODPRO+TD5_ESTRUT+TD5_CODNIV))
				Endif
			ElseIf nOpcx == 5 .or. aScan(aColsFFon,;
				   {|x| x[nPosEst]+x[nPosNiv]+x[nPosCod] == aColsFFon[j][nPosEst]+aColsFFon[j][nPosNiv]+aColsFFon[j][nPosCod] .and. !x[Len(aColsFFon[j])]} ) == 0
				dbSelectArea("TD5")
				dbSetOrder(1)
				If dbSeek(xFilial("TD5")+M->TD2_CODPRO+cCodEst+aLocalOK[k][1]+aColsFFon[j][nPosCod])
					//Gera historico do registro
					SG470HIST("TD5", "TD8", "3", dDataAlt, cHoraAlt, TD5->(TD5_FILIAL+TD5_CODPRO+TD5_ESTRUT+TD5_CODNIV))
					RecLock("TD5",.F.)
					dbDelete()
					MsUnlock("TD5")
				Endif
			Endif
		Endif
	Next j
Next k

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG470TREE บAutor  ณRoger Rodrigues     บ Data ณ  12/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega estrutura organizacional                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ                   ?
ฑฑบUso       ณSGAA470                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG470TREE(nOpcao, aNivMrk)

Local cLocal := ""
Local i

Default aNivMrk := {}

If nOpcao == 1//Opcao 1 Carrega tudo e 2 bChange

	//Posiciona no nivel pai da estrutura
	dbSelectArea("TAF")
	dbSetOrder(1)
	dbSeek(xFilial("TAF")+cCodest+"000")

	Processa({|lEnd| Sg100Tree(.F., cCodest, 3, aNivMrk)},STR0018,STR0019,.T.) //"Aguarde..."###"Carregando Estrutura..."

	//Abre itens na estrutura
	For i := 1 to Len(aLocal)
		If aLocal[i][Len(aLocal[i])]
			fPosicLoc( aLocal[i][1], aNivMrk )
		Endif
	Next i

Else

	dbSelectArea(oTree:cArqTree)
	cLocal := SubStr( oTree:getCargo(), 1, 3 )
	SG100VChg(3, {})

Endif

If IsInCallStack("SG470INC") .Or. IsInCallStack("SGC470VI") //Se estiver incluindo pelo SGAA480
	SG470COR(cLocal)
Else
	SG480COR(cLocal)
Endif

//Se estiver abrindo a tela, fecha a estrutura
If nOpcao == 1
	For i := 1 to Len(aLocal)
		If aLocal[i][Len(aLocal[i])]
			oTree:TreeSeek(aLocal[i][1])
		Endif
	Next i
	oTree:TreeSeek(cCodest)
Endif

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG470MRK  บAutor  ณRoger Rodrigues     บ Data ณ  12/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMarca o item selecionado na estrutura organizacional        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA470                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG470MRK()

Local nPos
Local lRet := .T.
Local aClrNiv := { "Folder10", "Folder11" }

If oTree:isEmpty()
	Return .F.
EndIf

dbSelectArea(oTree:cArqTree)

If SubStr( oTree:getCargo(), 7, 1 ) == "2"//Desmraca
	dbSelectArea("TD3")
	dbSetOrder(1)
	dbSeek(xFilial("TD3")+M->TD2_CODPRO+cCodEst+Substr( oTree:getCargo(), 1, 3))

	If !NGVALSX9("TD3",{"TD5","TD6"},.F.)
		lRet := MsgYesNo(STR0022, STR0007) //"Jแ foram geradas ocorr๊ncias para esta localiza็ใo. Deseja desmarcar a mesma?"###"Aten็ใo"
	Endif

	If !Sg100NvAtv( SubStr( oTree:GetCargo(), 1, 3 ), cCodest )
		aClrNiv := { "cadeado","cadeado" }
	Endif

	If Inclui .or. lRet
		dbSelectArea(oTree:cArqTree)

		oTree:ChangeBmp(aClrNiv[1],aClrNiv[2])
		(oTree:cArqTree)->T_CARGO := SubStr(oTree:getCargo(),1,6)+"1"

		If (nPos := aScan(aLocal, {|x| x[1] == SubStr( oTree:GetCargo(), 1, 3 )})) > 0
			aLocal[nPos][Len(aLocal[nPos])] := .F.
		Else
			aAdd( aLocal,{ SubStr( oTree:GetCargo(), 1, 3 ), 0, .F. } )
		EndIf
	Endif
Else//Marca
	If SG470FON(oTree:getCargo())
		oTree:ChangeBmp("Folder7","Folder8")
		(oTree:cArqTree)->T_CARGO := SubStr(oTree:getCargo(),1,6)+"2"

		If (nPos := aScan(aLocal, {|x| x[1] == SubStr( oTree:GetCargo(), 1, 3 )})) > 0
			aLocal[nPos][Len(aLocal[nPos])] := .T.
		Else
			aAdd( aLocal,{ SubStr( oTree:GetCargo(), 1, 3 ), 0, .T. } )
		EndIf
	Endif
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG470COR  บAutor  ณRoger Rodrigues     บ Data ณ  13/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAltera cor dos itens que foram previamente marcados         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA470                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG470COR(cLocal)
Local i
Local aArea := GetArea()

For i:=1 to Len(aMarcado)
	If aMarcado[i][Len(aMarcado[i])]
		dbSelectArea(cTRBSGA)
		dbSetOrder(2)
		If dbSeek(cCodest+aMarcado[i][1])
			dbSelectArea(oTree:cArqTree)
			dbSetOrder(4)
			If dbSeek(aMarcado[i][1])
				If SubStr( (oTree:cArqTree)->T_CARGO, 1, 3 ) == aMarcado[i][1] .and. SubStr( (oTree:cArqTree)->T_CARGO, 7, 1 ) != "2"//Desmraca
					oTree:TreeSeek(aMarcado[i][1])
					If !Altera .and. !Inclui
						oTree:ChangePrompt((oTree:cArqTree)->T_PROMPT+"("+AllTrim(Str(aMarcado[i][2],5))+"%)",aMarcado[i][1])
					Endif
					oTree:ChangeBmp("Folder7","Folder8")
					(oTree:cArqTree)->T_CARGO := SubStr(oTree:getCargo(),1,6)+"2"
					aMarcado[i][Len(aMarcado[i])] := .F.
					//Caso nao seja nivel clicado, fecha o mesmo
					If (cTRBSGA)->NIVSUP != cLocal .and. (cTRBSGA)->CODPRO != cCodest
						oTree:TreeSeek((cTRBSGA)->NIVSUP)
						oTree:PtCollapse()
					Endif
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
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG470HIST บAutor  ณRoger Rodrigues     บ Data ณ  18/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera hist๓rico para as tabelas relacionadas aos produtos    บฑฑ
ฑฑบ          ณgeradores de gases                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA470                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG470HIST(cAlias, cHist, cOper, dData, cHora, cChave)
Local i
Local cCampo

dbSelectArea(cAlias)

//Grava historico baseado no registro posicionado
dbSelectArea(cHist)
dbSetOrder(1)
If dbSeek(xFilial(cHist)+cChave+DTOS(dData)+cHora)
	RecLock(cHist,.F.)
Else
	RecLock(cHist,.T.)
Endif
For i:=1 to FCount()
	If "_FILIAL"$FieldName(i)
		FieldPut(i, xFilial(cHist))
	ElseIf "_DATA"$FieldName(i)
		FieldPut(i, dData)
	ElseIf "_HORA"$FieldName(i)
		FieldPut(i, cHora)
	ElseIf "_OPERAC"$FieldName(i)
		FieldPut(i, cOper)
	Else
		cCampo := PrefixoCpo(cAlias)+Substr(FieldName(i),At("_",FieldName(i)))
		If (cAlias)->(FieldPos(cCampo)) > 0
			FieldPut(i, &(cAlias+"->"+cCampo))
		Endif
	Endif
Next i
MsUnlock(cHist)

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG470WHEN บAutor  ณRoger Rodrigues     บ Data ณ  18/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณWhen dos campos TD4_CODGAS e TD5_CODFON                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA470                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG470WHEN(cCampo)
Local lRet := .T.

If Inclui
	lRet := .T.
Else
	If cCampo == "TD4_CODGAS"
		If Type("nTD4") == "U" .or. nTD4 < oGetGG:nAt
			lRet := .T.
		Else
			lRet := .F.
		Endif
	ElseIf cCampo == "TD5_CODFON"
		If Type("nTD5") == "U" .or. nTD5 < oGetFon:nAt
			lRet := .T.
		Else
			lRet := .F.
		Endif
	Endif
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG470DELOKบAutor  ณRoger Rodrigues     บ Data ณ  23/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se a linha da getDados pode ser excluida           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA470                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG470DELOK(cAlias)
Local lRet := .T.
Local f, nQtd := 0
Local aColsOk := {}, aHeadOk := {}
Local nPosCod := 1, nAt := 1, nQtde := 0

If cAlias == "TD4"
	aColsOk := aClone(oGetGG:aCols)
	aHeadOk := aClone(aHeadGas)
	nAt := oGetGG:nAt
	nPosCod := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TD4_CODGAS"})
Else
	aColsOk := aClone(oGetFon:aCols)
	aHeadOk := aClone(aHeadFon)
	nAt := oGetFon:nAt
	nPosCod := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TD5_CODFON"})
Endif

//Se inclusao ou estiver reativando a linha
If Inclui .or. aColsOk[nAt][Len(aColsOk[nAt])]
	Return .T.
Endif

If (nAt <= nTD4 .and. cAlias == "TD4") .or. (nAt <= nTD5 .and. cAlias == "TD5")
	If cAlias == "TD4"
		nQtde := 0
		#IFDEF TOP
			cAliasQry := GetNextAlias()
			cQuery := "SELECT COUNT(TDA.TDA_CODGAS) QTDE FROM "+RetSqlName("TDA")+" TDA "
			cQuery += "JOIN "+RetSqlName("TD9")+" TD9 ON (TD9.TD9_CODIGO = TDA.TDA_CODOCO AND "
			cQuery += "TD9.TD9_FILIAL = '"+xFilial("TD9")+"' AND TD9.D_E_L_E_T_ <> '*' "
			cQuery += "AND TD9.TD9_CODPRO = '"+M->TD2_CODPRO+"') "
			cQuery += "WHERE TDA.TDA_FILIAL = '"+xFilial("TDA")+"' AND TDA.D_E_L_E_T_ <> '*' "
			cQuery += "AND TDA.TDA_CODGAS = '"+aColsOk[nAt][nPosCod]+"' "
			cQuery := ChangeQuery(cQuery)
			MPSysOpenQuery( cQuery , cAliasQry )

			dbSelectArea(cAliasQry)
			dbGoTop()
			If !Eof()
				nQtde := (cAliasQry)->QTDE
			EndIf
			(cAliasQry)->(dbCloseArea())
		#ELSE
			dbSelectArea("TD9")
			dbSetOrder(2)
			dbSeek(xFilial("TD9")+M->TD2_CODPRO)
			While !eof() .and. xFilial("TD9")+M->TD2_CODPRO == TD9->TD9_FILIAL+TD9->TD9_CODPRO
				dbSelectArea("TDA")
				dbSetOrder(1)
				If dbSeek(xFilial("TDA")+TD9->TD9_CODIGO+aColsOk[nAt][nPosCod])
					nQtde := 1
					Exit
				Endif
				dbSelectArea("TD9")
				dbSkip()
			End
		#ENDIF
		If nQtde > 0
			lRet := MsgYesNo(STR0023, STR0007) //"Jแ foram geradas ocorr๊ncias com este Gแs. Deseja excluir o mesmo?"###"Aten็ใo"
		Endif
	Else
		dbSelectArea("TD5")
		dbSetOrder(1)
		dbSeek(xFilial("TD5")+M->TD2_CODPRO+cCodest+Substr(oTree:GetCargo(),1,3)+aColsOk[nAt][nPosCod])
		If !NGVALSX9("TD5",{"TD8"},.F.)
			lRet := MsgYesNo(STR0024, STR0007) //"Jแ foram geradas ocorr๊ncias para esta fonte geradora. Deseja excluir a mesma?"###"Aten็ใo"
		Endif
	Endif
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG470PORC บAutor  ณRoger Rodrigues     บ Data ณ  24/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza calcula de porcentagens                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA470                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG470PORC(cAlias, nValor, lValCpo)
Local lRet := .T.
Local i, nSoma := 0
Local aColsOk := {}, aHeadOk := {}, nAt := 0
Local nPosPor := 0

If lValCpo//Valida valor digitado
	If NaoVazio(nValor) .and. Positivo(nValor)
		If nValor > 100
			ShowHelpDlg(STR0007,{STR0027},1,;//"Aten็ใo"##"A porcentagem mแxima que pode ser informada ้ 100%."
								{STR0028},1)//"Informe um valor igual ou abaixo de 100."
			lRet := .F.
		Endif
	Else
		lRet := .F.
	Endif
Endif
If lRet
	If cAlias == "TD5"
		aColsOk := aClone(oGetFon:aCols)
		aHeadOk := aClone(aHeadFon)
		nAt := oGetFon:nAt
		nPosPor := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TD5_PORCEN"})
	ElseIf cAlias == "TD3"
		aColsOk := aClone(oGetEst:aCols)
		aHeadOk := aClone(aHeadEst)
		nAt := oGetEst:nAt
		nPosPor := aScan( aHeadOk,{|x| Trim(Upper(x[2])) == "TD3_PORCEN"})
	Endif
	//Realiza soma
	For i:=1 to Len(aColsOk)
		If !aColsOk[i][Len(aColsOk[i])]
			If i == nAt .and. lValCpo
				nSoma += nValor
			Else
				nSoma += aColsOk[i][nPosPor]
			Endif
		Endif
	Next i
	If nSoma > 100
		ShowHelpDlg(STR0007,{STR0029},1,;//"Aten็ใo"##"A soma das porcentagens informadas para as fontes ultrapassa 100%."
								{STR0030},1)//"Informe os valores de forma que a soma nใo ultrapasse 100%."
		lRet := .F.
	Endif
	If !lValCpo .and. nSoma < 100
		ShowHelpDlg(STR0007,{STR0031},1,;//"Aten็ใo"##"A soma das porcentagens informadas para as fontes ้ menor que 100%."
								{STR0032},1)//"Informe os valores de forma que a soma atinja 100%."
		lRet := .F.
	Endif
Endif

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG470EST  บAutor  ณRoger Rodrigues     บ Data ณ  23/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefine percentuais de emissao das localizacoes              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA470                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG470EST(nOpcx)
Local j, i, nPos, nPosCod, nPosPor
Local lOk := .T.
Local oPanelHlp
Local cGetWhl := ""
Local aSvCols := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta Variaveis da GetDados        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aCols := {}
aHeader := {}

cGetWhl := "TD3->TD3_FILIAL == '"+xFilial("TD3")+"' .AND. TD3->TD3_CODPRO = '"+M->TD2_CODPRO+"'"
FillGetDados( nOpcx, "TD3", 1, "TD2->TD2_CODPRO", {|| }, {|| .T.},{"TD3_CODPRO", "TD3_ESTRUT"},,,,{|| NGMontaAcols("TD3", TD2->TD2_CODPRO,cGetWhl)})

aSvEstCols := aClone(aCols)
aSvCols := aClone(aCols)
aHeadEst:= aClone(aHeader)

aColsEst := {}

nPosCod := aScan(aHeadEst, {|x| Trim(Upper(x[2])) =="TD3_CODNIV"} )
nPosPor := aScan(aHeadEst, {|x| Trim(Upper(x[2])) =="TD3_PORCEN"} )
//Monta aCols
For j:= 1 to Len(aLocal)
	If aLocal[j][Len(aLocal[j])]
		If (nPos := aScan(aSvCols, {|x| Trim(Upper(x[nPosCod])) == Trim(Upper(aLocal[j][1])) }) ) > 0
			aAdd(aColsEst, aClone(aSvCols[nPos]) )
		Else
			aAdd(aColsEst, aClone(BlankGetd(aHeadEst)[1]))
		Endif
		//Preenche com conteudo da base
		dbSelectArea("TD3")
		dbSetOrder(1)
		If dbSeek(xFilial("TD3")+M->TD2_CODPRO+cCodEst+aLocal[j][1])
			dbSelectArea("TD3")
			For i:=1 to FCount()
				If (nPos := aScan(aHeadEst, {|x| Trim(Upper(x[2])) == FieldName(i)} ) ) > 0
					aColsEst[Len(aColsEst)][nPos] := &("TD3->"+FieldName(i))
				Endif
			Next i
		Endif
		For i:=1 to Len(aHeadEst)
			If "TD3_CODNIV"$Trim(Upper(aHeadEst[i][2]))
				aColsEst[Len(aColsEst)][i] := aLocal[j][1]
			ElseIf "TD3_NOMNIV"$Trim(Upper(aHeadEst[i][2]))
				aColsEst[Len(aColsEst)][i] := SubStr(NGSEEK("TAF",cCodEst+aLocal[j][1],2,"TAF->TAF_NOMNIV"),1,30)
			ElseIf "TD3_PORCEN"$Trim(Upper(aHeadEst[i][2]))
				aColsEst[Len(aColsEst)][i] := aLocal[j][2]
			Endif
		Next i
	Endif
Next j
//Se tiver somente uma localizacao, automaticamente retorna 100%
If Len(aColsEst) == 1
	aColsEst[Len(aColsEst)][nPosPor] := 100
	Return .T.
Endif

Define MsDialog oDlgPorc Title STR0033 From 08,15 To 30,87 Of oMainWnd//"Percentuais de Emissใo das Localiza็๕es"
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Painel de Help                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oPanelHlp := TPanel():New(0,0,,oDlgPorc,,,,,RGB(67,70,87),200,200,.F.,.F.)
oPanelHlp:Align := CONTROL_ALIGN_TOP
oPanelHlp:nHeight := 20

@ 002,004 Say OemToAnsi(STR0034) Of oPanelHlp Color RGB(255,255,255) Pixel//"Defina os percentuais de gera็ใo dos Gases para cada Localiza็ใo."

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ GetDados                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oGetEst := MsNewGetDados():New(005, 005, 100, 200,IIF(!Inclui.And.!Altera,0,GD_INSERT+GD_UPDATE),"SG470LINOK('TD3')","AllWaysTrue()",,,,Len(aColsEst),,,"",oDlgPorc,aHeadEst, aColsEst)
oGetEst:oBrowse:Default()
oGetEst:oBrowse:Refresh()
oGetEst:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
PutFileInEof("TD3")

Activate MsDialog oDlgPorc On Init EnchoiceBar(oDlgPorc,{|| lOk := .T.,;
					If(SG470LINOK("TD3",.T.) .and. SG470PORC("TD3", 0, .F.),(lOk := .T.,oDlgPorc:End()), lOk := .F.)},;
					{|| lOk := .F.,oDlgPorc:End()}) Centered

Return lOk
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG470FON  บAutor  ณRoger Rodrigues     บ Data ณ  23/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAbre tela para definicao de fontes geradoras da localizacao บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA470                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG470FON(cCargo,lVerif)
Local j, i, nPos
Local lOk := .T.
Local oPanelHlp
Local nPosCod, nPosFCod, nPosEst, nPosNiv, nPosLin
Local cCodNiv := Substr(cCargo,1,3)//Codigo do nivel
Local cTipo   := Substr(cCargo,7,1)//Tipo de Marcacao
Default lVerif := .F.//Indica se deve verificar marcacao
Private aColsEF := {}, aHeadEF := aClone(aHeadFon)

If lVerif .and. cTipo != "2"
	ShowHelpDlg(STR0007, {STR0035},1)//"Aten็ใo"##"Esta op็ใo s๓ se aplica a localiza็๕es definidas como possํveis locais de consumo"
	Return .F.
EndIf

Define MsDialog oDlgFon Title STR0036 From 08,15 To 30,87 Of oMainWnd//"Fontes de Emissใo das Localiza็๕es"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Painel de Help                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oPanelHlp := TPanel():New(0,0,,oDlgFon,,,,,RGB(67,70,87),200,200,.F.,.F.)
oPanelHlp:Align := CONTROL_ALIGN_TOP
oPanelHlp:nHeight := 20

@ 002,004 Say OemToAnsi(STR0037) Of oPanelHlp Color RGB(255,255,255) Pixel//"Defina as Fontes de Emissใo de Gases para a Localiza็ใo."

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta Array                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nPosEst := aScan( aHeadFFon,{|x| Trim(Upper(x[2])) == "TD5_ESTRUT"})
nPosNiv := aScan( aHeadFFon,{|x| Trim(Upper(x[2])) == "TD5_CODNIV"})
nPosFCod := aScan( aHeadFFon,{|x| Trim(Upper(x[2])) == "TD5_CODFON"})

//Monta array somente com informacoes do nivel
For i:=1 to Len(aColsFFon)
	If aColsFFon[i][nPosEst]+aColsFFon[i][nPosNiv] == cCodEst+cCodNiv
		aAdd(aColsEF, BlankGetD(aHeadEF)[1] )
		For j:=1 to Len(aHeadEF)
			If (nPos := aScan(aHeadFFon, {|x| x[2] == aHeadEf[j][2]} ) ) > 0
				aColsEf[Len(aColsEF)][j] := aColsFFon[i][nPos]
			Endif
		Next j
		aColsEF[Len(aColsEF)][Len(aColsEF[Len(aColsEF)])] := aColsFFon[i][Len(aColsFFon[i])]
	Endif
Next i
If Empty(aColsEf)
	aColsEf := BlankGetD(aHeadEF)
	nTD5 := 0
Else
	nTD5 := Len(aColsEF)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ GetDados                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oGetFon := MsNewGetDados():New(005, 005, 100, 200,IIF(!Inclui.And.!Altera,0,GD_INSERT+GD_UPDATE+GD_DELETE),"SG470LINOK('TD5')","AllWaysTrue()",,,,9999,,,"SG470DELOK('TD5')",oDlgFon,aHeadEF, aColsEF)
oGetFon:oBrowse:Default()
oGetFon:oBrowse:Refresh()
oGetFon:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
PutFileInEof("TD5")

Activate MsDialog oDlgFon On Init EnchoiceBar(oDlgFon,{|| lOk := .T.,;
					If(SG470LINOK("TD5",.T.) .and. SG470PORC("TD5", 0, .F.),(lOk := .T.,oDlgFon:End()), lOk := .F.)},;
					{|| lOk := .F.,oDlgFon:End()}) Centered

If lOk
	aColsEF := aClone(oGetFon:aCols)
	nPosCod := aScan( aHeadEF,{|x| Trim(Upper(x[2])) == "TD5_CODFON"})

	//Joga as informacoes no array principal
	For i:=1 to Len(aColsEF)
		nPosLin := aScan(aColsFFon, {|x| x[nPosEst]+x[nPosNiv]+x[nPosFCod] == cCodEst+cCodNiv+aColsEF[i][nPosCod];
										.and. x[Len(BlankGetD(aHeadFFon)[1])] == aColsEF[i][Len(aColsEF[i])] } )

		//Se encontrar altera linha, se nao adiciona nova
		If nPosLin > 0
			For j:=1 to Len(aHeadFFon)
				If (nPos := aScan(aHeadEF, {|x| x[2] == aHeadFFon[j][2]} ) ) > 0
					aColsFFon[nPosLin][j] := aColsEF[i][nPos]
				Endif
			Next j
			aColsFFon[nPosLin][Len(aColsFFon[nPosLin])] := aColsEF[i][Len(aColsEF[i])]
		Else
			aAdd(aColsFFon, BlankGetD(aHeadFFon)[1] )
			For j:=1 to Len(aHeadFFon)
				If "TD5_ESTRUT"$aHeadFFon[j][2]
					aColsFFon[Len(aColsFFon)][j] := cCodEst
				Elseif "TD5_CODNIV"$aHeadFFon[j][2]
					aColsFFon[Len(aColsFFon)][j] := cCodNiv
				ElseIf (nPos := aScan(aHeadEF, {|x| x[2] == aHeadFFon[j][2]} ) ) > 0
					aColsFFon[Len(aColsFFon)][j] := aColsEF[i][nPos]
				Endif
			Next j
			aColsFFon[Len(aColsFFon)][Len(aColsFFon[Len(aColsFFon)])] := aColsEF[i][Len(aColsEF[i])]
		Endif
	Next i
	//Verifica os nao deletados se de fato estao ativos
	For i := Len(aColsFFon) to 1 Step -1
		If !aColsFFon[i][Len(aColsFFon[i])] .and. aColsFFon[i][nPosNiv] == cCodNiv
			//Se nao encontrar nenhum ativo, deleta a linha
			If aScan(aColsEF, {|x| x[nPosCod] == aColsFFon[i][nPosFCod] .and. x[Len(BlankGetD(aHeadEF)[1])] == .F.} ) == 0
				aColsFFon[i][Len(aColsFFon[i])] := .T.
			Endif
			//Deleta do Array a op็ใo que foi deletada, para nใo duplicar.
			If aColsFFon[i][Len(aColsFFon[i])] == .T.
				aDel( aColsFFon, i )
				aSize( aColsFFon, Len(aColsFFon) - 1 )
			EndIf
		Endif
	Next i
Endif

Return lOk
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG470F3   บAutor  ณRoger Rodrigues     บ Data ณ  20/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณChama tela para inclusao a partir de F3                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA470/SGAA480                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG470F3(cAlias,nRecno,nOpcx,cCodPro)
Local lRet := .T.
Local aArea:= GetArea()
Local lOldInclui := Inclui, lOldAltera := Altera
cOldTRB := If(Type("cTRBSGA") != "U", cTRBSGA, Nil)
oOldTree:= If(Type("oTree") != "U", oTree, Nil)
aOldLoc := If(Type("aLocal") != "U", aClone(aLocal), Nil)
aOldMarc:= If(Type("aMarcado") != "U", aClone(aMarcado), Nil)

cTRBSGA	:= Nil
oTree	:= Nil
aLocal	:= {}
aMarcado:= {}
Inclui 	:= (nOpcx == 3)
Altera 	:= (nOpcx == 3)

dbSelectArea("TD2")
dbSetOrder(1)
If nOpcx != 3
	dbSeek(xFilial("TD2")+cCodPro)
Endif
If !SG470INC(cAlias, TD2->(Recno()), nOpcx)
	lRet := .F.
Endif

cTRBSGA := cOldTRB
oTree	:= oOldTree
aLocal  := If(Type("aOldLoc") != "U", aClone(aOldLoc), {})
aMarcado:= If(Type("aOldMarc") != "U", aClone(aOldMarc),{})
Inclui 	:= lOldInclui
Altera 	:= lOldAltera
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfPosicLoc บAutor  ณRoger Rodrigues     บ Data ณ  29/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPosiciona na localizacao a ser marcada                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA150                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fPosicLoc( cCodigo, aNivMrk )
Local i
Local cSupNiv  := cCodEst
Local aLocPais := {}

//Carrega itens pais
If !Empty(cCodigo)

	aAdd(aLocPais, cCodigo)
	cSupNiv := NGSEEK("TAF",cCodigo,8,"TAF->TAF_NIVSUP")

	dbSelectArea("TAF")
	dbSetOrder(2)
	dbSeek(xFilial("TAF")+cCodEst+cCodigo)
	While !eof() .and. Found() .and. cSupNiv != "000"

		dbSelectArea("TAF")
		dbSetOrder(2)
		If dbSeek(xFilial("TAF")+cCodEst+cSupNiv)
			aAdd(aLocPais, TAF->TAF_CODNIV)
			cSupNiv := TAF->TAF_NIVSUP
		Endif

	End
Else
	Return .F.
Endif

//Encontra item na arvore
For i := Len(aLocPais) to 1 Step -1
	oTree:TreeSeek( aLocPais[i] + "LOC" )
	SG100VChg( 3, aNivMrk )
Next i

Return .T.