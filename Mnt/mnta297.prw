#INCLUDE "Protheus.ch"
#INCLUDE "DBTREE.ch"
#INCLUDE "MNTA297.ch"

// Variแveis de numera็ใo dos folders
#DEFINE __FOLDER_CTT__ 01   // CENTRO DE CUSTO
#DEFINE __FOLDER_ST6__ 02   // FAMILIA
#DEFINE __FOLDER_ST9__ 03   // BENS
#DEFINE __FOLDER_TAF__ 04   // LOCALIZACAO
#DEFINE __FOLDER_TQ3__ 05   // TIPO DE SERVICO

#DEFINE __SIZE_ARRAY__ 05   // TAMANHO DO ARRAY
#DEFINE __SIZE_SAZONAL__ 01 // TAMANHO DO ARRAY DE SAZONALIDADE

#DEFINE __LEN_ARR_SAZ__ 03  // TAMANHO DO ARRAY DE SAZONALIDADE
#DEFINE __POS_COD__ 01      // POSICAO DO CODIGO
#DEFINE __POS_HEAD__ 02     // POSICAO DO AHEADER
#DEFINE __POS_COLS__ 03     // POSICAO DO ACOLS

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA297
Tela de Defini็ใo de Criticidade

@type   Function

@author Roger Rodrigues
@since  06/07/2011

@return L๓gico, sempre verdadeiro
/*/
//-------------------------------------------------------------------
Function MNTA297()

	// Guarda variaveis padrao
	Local aNGBEGINPRM := NGBEGINPRM(,"MNTA297")

	// Variแveis da GetDados
	Local aArrGet := {}
	Local oGetCTT
    Local oGetST6
    Local oGetST9
	Local oGetTQ3
	Local oTree

	// Defini็ใo de tamanho de tela e objetos
	Local aSize := MsAdvSize(,.F.,430)

	// Variแveis da tela
	Local oDlg297
	Local lOk        := .T.
	Local bGravaEnc  := {|| }
	Local cTitulo    := STR0001 // "Defini็ใo de Parโmetros de Criticidade"
	Local oGetSearch
    Local oCBoxSearch
    Local oBtnSearch
    Local cCombo
    Local cGetSearch := Space(100)
	Local aIndex     := {RetTitle("TU7_CODIGO"),RetTitle("TU7_DESCRI")}

	// Pain้is da tela
	Local oPnlLeg
    Local oPnlFolder
    Local oPanelEsq
    Local oPanelDir

	// Verifica se o update de facilities foi aplicado
	If !FindFunction("MNTUPDFAC") .Or. !MNTUPDFAC()
		Return .F.
	Endif

	Private oPnlSrc297
    Private oPnlBtn297
    Private oFolder297
    Private oPnlBtnTAF

	// Bot๕es da Tela
	Private oBtnVisual
    Private oBtnSaz
    Private oBtnAlt
    Private oBtnConf
    Private oBtnCanc

	// Variแveis do Folder Arvore Logica
	Private aColsTAF := {}
	Private cTRBTAF  := GetNextAlias()
    Private oTmpTree
	Private aVetInr  := {}
	Private oEncTAF
    Private aGets    := {}
    Private aTela    := {}
	Private aNao     := {"TU7_OPCAO"}
	Private lALTERA  := .T. // When do campo TU7_CRITIC

	// Variแveis gerais da rotina
	Private cCadastro := cTitulo
	Private aRotina := {{"", "PesqBrw",0, 1},;
                        {"", "NGCAD01",0, 2},;
                        {"", "NGCAD01",0, 3},;
                        {"", "NGCAD01",0, 4},;
                        {"", "NGCAD01",0, 5,3}}

	Private nFolderAtu := 1 // Indica folder atual
	Private aHeadCri := {}
	FillGetDados( 3,"TU7",,,,,aNao,,,,,,aHeadCri)

	// Arrays de controle de Variaveis
	Private aTFolder   := Array(__SIZE_ARRAY__)
	Private aAlias     := Array(__SIZE_ARRAY__)
	Private aKeyField  := Array(__SIZE_ARRAY__)
	Private aDescField := Array(__SIZE_ARRAY__)
	Private aObjects   := Array(__SIZE_ARRAY__)
	Private aSazonal   := Array(__SIZE_ARRAY__,__SIZE_SAZONAL__)

	// Variแvel das cores da tela
	Private aNGColor := aClone( NGCOLOR("10") )

	// Carrega array com Folders
	aTFolder[__FOLDER_CTT__] := STR0002 // "Centro de Custo"
	aTFolder[__FOLDER_ST6__] := STR0003 // "Famํlia"
	aTFolder[__FOLDER_ST9__] := STR0004 // "Bens"
	aTFolder[__FOLDER_TAF__] := STR0005 // "มrvore L๓gica"
	aTFolder[__FOLDER_TQ3__] := STR0027 // "Tipo de Servi็o"

	//Carrega array com Alias
	aAlias[__FOLDER_CTT__] := "CTT"
	aAlias[__FOLDER_ST6__] := "ST6"
	aAlias[__FOLDER_ST9__] := "ST9"
	aAlias[__FOLDER_TAF__] := "TAF"
	aAlias[__FOLDER_TQ3__] := "TQ3"

	// Carrega array com chaves
	aKeyField[__FOLDER_CTT__] := "CTT_CUSTO"
	aKeyField[__FOLDER_ST6__] := "T6_CODFAMI"
	aKeyField[__FOLDER_ST9__] := "T9_CODBEM"
	aKeyField[__FOLDER_TAF__] := "TAF_CODNIV"
	aKeyField[__FOLDER_TQ3__] := "TQ3_CDSERV"

	// Carrega array com descri็๕es
	aDescField[__FOLDER_CTT__] := "CTT_DESC01"
	aDescField[__FOLDER_ST6__] := "T6_NOME"
	aDescField[__FOLDER_ST9__] := "T9_NOME"
	aDescField[__FOLDER_TAF__] := "TAF_NOMNIV"
	aDescField[__FOLDER_TQ3__] := "TQ3_NMSERV"

	// Carrega variaveis para modo de altera็ใo
	SetAltera(.T.)

	Define MsDialog oDlg297 Title OemToAnsi(cTitulo) From aSize[7],0 To aSize[6],aSize[5] Of oMainWnd Pixel
	oDlg297:lMaximized := .T.

	//-----------------------------------
	// Cria Panel de Legenda
	//-----------------------------------
	oPnlLeg:=TPanel():New(00,00,,oDlg297,,,,aNGColor[1],aNGColor[2],200,200,.F.,.F.)
	oPnlLeg:nHeight := 25
	oPnlLeg:Align := CONTROL_ALIGN_TOP

	@ 003,003 Say OemToAnsi(STR0006) Of oPnlLeg Color aNGColor[1] Pixel // "Informe valores de 0 a 100 para definir a criticade dos itens"

	//-----------------------------------
	// Cria Panel com os Folders
	//-----------------------------------
	oPnlFolder := TPanel():New(0,0,,oDlg297,,,,,CLR_WHITE,0,0,.T.,.T.)
	oPnlFolder:Align := CONTROL_ALIGN_ALLCLIENT

	//-------------------------------------------------------------------
	// Cria Panel com opcoes de pesquisa no MsSelect
	//-------------------------------------------------------------------
	oPnlSrc297 := TPanel():New(0,0,,oPnlFolder,,,,,CLR_WHITE,0,20,.F.,.F.)
	oPnlSrc297:Align := CONTROL_ALIGN_TOP

	oCBoxSearch := TComboBox():New(02,02,{|u| If(PCount()>0,cCombo:=u,cCombo)},aIndex,100,20,oPnlSrc297,,;
	{|| .T.},,,,.T.,,,,{|| nFolderAtu != __FOLDER_TAF__},,,,,"cCombo")
	oGetSearch  := TGet():New( 02,105,{|u| If(PCount()>0,cGetSearch:=u,cGetSearch)}, oPnlSrc297,096,008,,,;
	0,,,.F.,,.T.,,.F.,{|| nFolderAtu != __FOLDER_TAF__},.F.,.F.,,.F.,.F.,,cGetSearch,,,, )
	oBtnSearch  := TButton():New( 002, 202, STR0007,oPnlSrc297,{|| fColsSeek(aObjects[nFolderAtu],oCBoxSearch:nAt,Trim(cGetSearch))},; //"Buscar"
	35,11,,,.F.,.T.,.F.,,.F.,{|| nFolderAtu != __FOLDER_TAF__},,.F. )

	//-------------------------------------------------------------------
	// Cria Panel de bot๕es na parte Esquerda
	//-------------------------------------------------------------------
	oPnlBtn297 := TPanel():New(0,0,,oPnlFolder,,,,aNGColor[1],aNGColor[2],13,0,.F.,.F.)
	oPnlBtn297:Align := CONTROL_ALIGN_LEFT

	oBtnVisual  := TBtnBmp():NewBar("ng_ico_visualizar","ng_ico_visualizar",,,,{|| Visualize(aObjects[nFolderAtu],aAlias[nFolderAtu])},,oPnlBtn297,,,STR0008,,,,,"") //"Visualizar Registro"
	oBtnVisual:Align    := CONTROL_ALIGN_TOP

	oBtnSaz  := TBtnBmp():NewBar("ng_ico_refresh","ng_ico_refresh",,,,{|| fDefSaz()},,oPnlBtn297,,,STR0009,,,,,"") //"Definir Criticidade por Sazonalidade"
	oBtnSaz:Align    := CONTROL_ALIGN_TOP

	oBtnAlt  := TBtnBmp():NewBar("ng_ico_altid","ng_ico_altid",,,,{|| fAtuEnc(Substr(oTree:GetCargo(),1,3),.T.)},,oPnlBtn297,,,STR0010,,,,,"") //"Alterar Registro"
	oBtnAlt:lVisible := .F.
	oBtnAlt:Align    := CONTROL_ALIGN_TOP

	//-----------------------------------
	// Cria Folder com informa็๕es
	//-----------------------------------
	oFolder297 := TFolder():New( 0,0,aTFolder,,oPnlFolder,,,,.T.,,0,aSize[6] )
	oFolder297:Align := CONTROL_ALIGN_ALLCLIENT
	oFolder297:bSetOption := {|nOption| ChangeFolder( nOption, oTree ) }

	//-----------------------------------
	// Carrega dados do Centro de Custo
	//-----------------------------------
	Processa({|| aArrGet := fLoadFold(__FOLDER_CTT__)},STR0011, STR0012) //"Aguarde..." ## "Carregando dados de Centro de Custo..."
	oGetCTT := MsNewGetDados():New(5,5,500,500,If(!Inclui.And.!Altera,0,GD_UPDATE),"AllWaysTrue()","AllWaysTrue()",,,,9999,,,,oFolder297:aDialogs[__FOLDER_CTT__],aHeadCri, aArrGet)
	oGetCTT:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGetCTT:oBrowse:Refresh()

	//-----------------------------------
	// Carrega dados da Famํlia
	//-----------------------------------
	Processa({|| aArrGet := fLoadFold(__FOLDER_ST6__)},STR0011, STR0013) //"Aguarde..." ## "Carregando dados de Famํlia..."
	oGetST6 := MsNewGetDados():New(5,5,500,500,If(!Inclui.And.!Altera,0,GD_UPDATE),"AllWaysTrue()","AllWaysTrue()",,,,9999,,,,oFolder297:aDialogs[__FOLDER_ST6__],aHeadCri, aArrGet)
	oGetST6:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGetST6:oBrowse:Refresh()

	//-----------------------------------
	// Carrega dados do Bem
	//-----------------------------------
	Processa({|| aArrGet := fLoadFold(__FOLDER_ST9__)},STR0011, STR0014) //"Aguarde..." ## "Carregando dados de Bens..."
	oGetST9 := MsNewGetDados():New(5,5,500,500,If(!Inclui.And.!Altera,0,GD_UPDATE),"AllWaysTrue()","AllWaysTrue()",,,,9999,,,,oFolder297:aDialogs[__FOLDER_ST9__],aHeadCri, aArrGet)
	oGetST9:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGetST9:oBrowse:Refresh()

	//-----------------------------------
	// Carrega dados da มrvore L๓gica
	//-----------------------------------
	oSplitter := tSplitter():New(0,0,oFolder297:aDIALOGS[__FOLDER_TAF__],100,100,0 )
	oSplitter:Align := CONTROL_ALIGN_ALLCLIENT

	// Painel da Esquerda
	oPanelEsq := TPanel():New(01,01,,oSplitter,,,,,,10,10,.F.,.F.)
	oPanelEsq:nWidth := 17
	oPanelEsq:Align := CONTROL_ALIGN_LEFT

	oPanelDir := TPanel():New(01,01,,oSplitter,,,,,,10,10,.F.,.F.)
	oPanelDir:nHeight := 50
	oPanelDir:Align := CONTROL_ALIGN_RIGHT

	oTree := DbTree():New(052, 005, 260, 180, oPanelEsq,,, .T.)
	oTree:bChange:= {|| fAtuEnc(Substr(oTree:GetCargo(),1,3))}
	oTree:Align    := CONTROL_ALIGN_ALLCLIENT
	oTree:nClrPane := RGB(221,221,221)

	Processa({|| aColsTAF := fLoadFold(__FOLDER_TAF__,oTree)},STR0011, STR0015) //"Aguarde..." ## "Carregando dados da มrvore L๓gica..."

	RegToMemory("TU7",.T.)
	oPnlBtnTAF:=TPanel():New(00,00,,oPanelDir,,,,aNGColor[1],aNGColor[2],12,12,.F.,.F.)
	oPnlBtnTAF:Align := CONTROL_ALIGN_LEFT

	bGravaEnc := {|| If(Obrigatorio(aGets,aTela),fAtuEnc(Substr(oTree:GetCargo(),1,3),.T.,.T.),.F.)}
	oBtnConf  := TBtnBmp():NewBar("ng_ico_confirmar","ng_ico_confirmar",,,,bGravaEnc,,oPnlBtnTAF,,,STR0016,,,,,"") //"Confirmar"
	oBtnConf:Align  := CONTROL_ALIGN_TOP

	oBtnCanc  := TBtnBmp():NewBar("ng_ico_cancelar","ng_ico_cancelar",,,,{|| fDisable(.F.) },,oPnlBtnTAF,,,STR0017,,,,,"") //"Cancelar"
	oBtnCanc:Align  := CONTROL_ALIGN_TOP

	oPnlBtnTAF:Hide()

	oEncTAF := MsMGet():New("TU7",Recno(),4,,,,NGCAMPNSX3("TU7",aNao),{0,0,500,300},,3,,,,oPanelDir)
	oEncTAF:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	//-----------------------------------
	// Carrega dados do Tipo de Servi็o
	//-----------------------------------
	Processa({|| aArrGet := fLoadFold(__FOLDER_TQ3__)},STR0011, STR0028) //"Aguarde..." ## "Carregando dados do Tipo de Servi็o..."
	oGetTQ3 := MsNewGetDados():New(5,5,500,500,If(!Inclui.And.!Altera,0,GD_UPDATE),"AllWaysTrue()","AllWaysTrue()",,,,9999,,,,oFolder297:aDialogs[__FOLDER_TQ3__],aHeadCri, aArrGet)
	oGetTQ3:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGetTQ3:oBrowse:Refresh()

	//-------------------------------------------------------------------
	// Carrega array de controle dos Objetos criados
	//-------------------------------------------------------------------
	aObjects[__FOLDER_CTT__] := oGetCTT
	aObjects[__FOLDER_ST6__] := oGetST6
	aObjects[__FOLDER_ST9__] := oGetST9
	aObjects[__FOLDER_TAF__] := oTree
	aObjects[__FOLDER_TQ3__] := oGetTQ3

	Activate MsDialog oDlg297 On Init (EnchoiceBar(oDlg297,{|| If(oPnlBtnTAF:lVisible,(Eval(bGravaEnc),lOk:=.T.,oDlg297:End()),(lOk:=.T.,oDlg297:End()))},;
	{|| lOk:=.F.,oDlg297:End()})) Centered

	If lOk
		fGrava()
	Endif

	// Exclui tabela temporแrio da Arvore Logica
	oTmpTree:Delete()

	NGRETURNPRM(aNGBEGINPRM)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfLoadFold บAutor  ณRoger Rodrigues     บ Data ณ  07/07/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega conteudo do folder                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA297                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fLoadFold(nFolder,oTree)
	Local aCols := {}

	Local cAlias    := aAlias[nFolder]
	Local cFilField := cAlias+"->"+PrefixoCpo(cAlias)+"_FILIAL"
	Local cKeyField := cAlias+"->"+aKeyField[nFolder]
	Local cDescField:= cAlias+"->"+aDescField[nFolder]

	aCols := {}

	If nFolder != __FOLDER_TAF__
		dbSelectArea(cAlias)
		dbSetOrder(1)
		dbSeek(xFilial(cAlias))
		ProcRegua(RecCount())
		While !eof() .and. xFilial(cAlias) == &(cFilField)
			IncProc()
			aAdd(aCols, fAddCols(nFolder,cKeyField,cDescField))
			dbSelectArea(cAlias)
			dbSkip()
		End
		If Len(aCols) == 0
			aCols := BlankGetD(aHeadCri)
		Endif
	ElseIf nFolder == __FOLDER_TAF__
		Processa({|| aCols := LoadTree(oTree)},STR0011, STR0015) //"Aguarde..." ##  "Carregando dados da มrvore L๓gica..."
	Endif

Return aCols

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfAddCols  บAutor  ณRoger Rodrigues     บ Data ณ  19/07/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAdiciona linha no acols                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA297                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fAddCols(nFolder,cKeyField,cDescField)
	Local i
	Local cOpcao := StrZero(nFolder,1)
	Local nSizeCod := If(TAMSX3("TU7_CODIGO")[1] > 0, TAMSX3("TU7_CODIGO")[1], 20)
	Local aLinha := {}

	aLinha := BlankGetD(aHeadCri)[1]
	For i:=1 to Len(aHeadCri)
		If aHeadCri[i][2] == "TU7_CODIGO"
			aLinha[i] := Padr(&(cKeyField),nSizeCod)
		Elseif aHeadCri[i][2] == "TU7_DESCRI"
			aLinha[i] := &(cDescField)
		Elseif aHeadCri[i][2] == "TU7_ALI_WT"
			aLinha[i] := "TU7"
		Else
			dbSelectArea("TU7")
			dbSetOrder(1)
			If dbSeek(xFilial("TU7")+StrZero(nFolder,1)+Padr(&(cKeyField),nSizeCod))
				If aHeadCri[i][2] == "TU7_REC_WT"
					aLinha[i] := TU7->(Recno())
				Else
					aLinha[i] := &("TU7->"+aHeadCri[i][2])
				Endif
			ElseIf aHeadCri[i][2] == "TU7_CRITIC"
				aLinha[i] := 0
			Endif
		Endif
	Next i

Return aLinha
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfColsSeek บAutor  ณRoger Rodrigues     บ Data ณ  07/07/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza busca e posiciona no registro                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA297                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fColsSeek(oObjeto, nIndex, cPesquisa)
	Local aCols   := oObjeto:aCols
	Local nPos, nLinha

	If !Empty(cPesquisa)
		If nIndex == 1
			nPos := GDFIELDPOS("TU7_CODIGO",aHeadCri)
		Else
			nPos := GDFIELDPOS("TU7_DESCRI",aHeadCri)
		Endif

		nLinha := aScan(aCols,{|x| Substr(x[nPos],1,Len(cPesquisa)) == cPesquisa})

		If nLinha > 0
			oObjeto:oBrowse:SetFocus()
			oObjeto:ForceRefresh()
			oObjeto:oBrowse:nAt := nLinha
			oObjeto:oBrowse:nRowPos := 1
		Endif
	Endif
Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณLoadTree    ณAutor ณRoger Rodrigues       ณ Data ณ11/07/2011ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณCarrega Tree de acorodo com a TAF                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณoTree   - Objeto Tree                                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณMNTA297                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function LoadTree(oTree)
	Local aCols := {}
	Local aCampos := {}
	Local aIndex  := {}
	Local cCargo  := "LOC"
	Local cCodEst := "001"
	Local cPai    := "001"
	Local cFolderA := "FOLDER10"
	Local cFolderB := "FOLDER11"
	Local nNivel
	Local nIdx

	aAdd(aCampos,{"CODEST"   ,"C",03,0})
	aAdd(aCampos,{"CODPRO"   ,"C",03,0})
	aAdd(aCampos,{"DESCRI"   ,"C",56,0})
	aAdd(aCampos,{"NIVSUP"   ,"C",03,0})
	aAdd(aCampos,{"TIPO"     ,"C",01,0})
	aAdd(aCampos,{"CODTIPO"  ,"C",16,0})
	aAdd(aCampos,{"ORDEM"    ,"C",03,0})
	aAdd(aCampos,{"NIVEL"    ,"N",03,0})
	aAdd(aCampos,{"CARGO"    ,"C",06,0})
	aAdd(aCampos,{"CC"       ,"C",09,0})
	aAdd(aCampos,{"CENTRAB"  ,"C",06,0})

	aIndex   := {{"CODEST", "NIVSUP"},;
                 {"CODEST","CODPRO","ORDEM"},;
                 {"TIPO","CODTIPO"},;
                 {"CODEST","NIVSUP","ORDEM"},;
                 {"CODEST","NIVEL","ORDEM"} }

	oTmpTree := FWTemporaryTable():New(cTRBTAF, aCampos)
	For nIdx := 1 To Len(aIndex)
		oTmpTree:AddIndex("Ind"+cValToChar(nIdx), aIndex[nIdx])
	Next nIdx
	oTmpTree:Create()

	oTree:Reset()
	oTree:BeginUpdate()

	dbSelectArea("TAF")
	dbSetOrder(1)
	dbSeek(xFilial("TAF")+cCodEst)

	RecLock(cTRBTAF,.T.)
	(cTRBTAF)->CODEST  := cCodEst
	(cTRBTAF)->CODPRO  := TAF->TAF_CODNIV
	(cTRBTAF)->DESCRI  := TAF->TAF_NOMNIV
	(cTRBTAF)->NIVSUP  := TAF->TAF_NIVSUP
	(cTRBTAF)->TIPO    := TAF->TAF_INDCON
	(cTRBTAF)->CODTIPO := TAF->TAF_CODCON
	(cTRBTAF)->NIVEL   := 0
	(cTRBTAF)->CARGO   := "LOC"
	(cTRBTAF)->ORDEM   := TAF->TAF_ORDEM
	(cTRBTAF)->CC      := TAF->TAF_CCUSTO
	(cTRBTAF)->CENTRAB := TAF->TAF_CENTRA
	(cTRBTAF)->(MsUnLock())

	DbAddTree oTree Prompt TAF->TAF_NOMNIV Opened Resource cFolderA, cFolderB Cargo cPai+cCargo
	//Adiciona item no array
	aAdd(aCols, fAddCols(__FOLDER_TAF__,"TAF->TAF_CODNIV","TAF->TAF_NOMNIV"))

	cPai:="001"
	dbSelectArea("TAF")
	dbSetOrder(1)
	dbSeek(xFilial("TAF")+cCodEst+cPai)
	ProcRegua(RecCount()*2)
	While !TAF->(Eof()) .And. TAF->TAF_FILIAL == xFilial("TAF") .And. TAF->TAF_NIVSUP == cPai

		IncProc()
		If Empty( TAF->TAF_MODMNT ) .Or. !(TAF->TAF_INDCON $ "1/2/")
			TAF->(dbSkip())
			Loop
		EndIf

		If TAF->TAF_INDCON == "1"
			cCargo   := "BEM"

			dbSelectArea("ST9")
			dbSetOrder(1)
			If !dbSeek(xFilial("ST9")+TAF->TAF_CODCON) .Or. ST9->T9_SITBEM <> "A"
				TAF->(dbSkip())
				Loop
			EndIf

		ElseIf TAF->TAF_INDCON == "2"
			cCargo := "LOC"
		EndIf

		dbSelectArea(cTRBTAF)
		dbSetOrder(2)
		RecLock(cTRBTAF,.T.)
		(cTRBTAF)->CODEST  := cCodEst
		(cTRBTAF)->CODPRO  := TAF->TAF_CODNIV
		(cTRBTAF)->DESCRI  := TAF->TAF_NOMNIV
		(cTRBTAF)->NIVSUP  := TAF->TAF_NIVSUP
		(cTRBTAF)->TIPO    := TAF->TAF_INDCON
		(cTRBTAF)->CODTIPO := TAF->TAF_CODCON
		(cTRBTAF)->NIVEL   := 1
		(cTRBTAF)->CARGO   := cCargo
		(cTRBTAF)->ORDEM   := TAF->TAF_ORDEM
		(cTRBTAF)->CC      := TAF->TAF_CCUSTO
		(cTRBTAF)->CENTRAB := TAF->TAF_CENTRA
		(cTRBTAF)->(MsUnLock())

		//Adiciona item no array
		If TAF->TAF_INDCON == "2"
			//Adiciona item no array
			aAdd(aCols, fAddCols(__FOLDER_TAF__,"TAF->TAF_CODNIV","TAF->TAF_NOMNIV"))
		Endif
		dbSelectArea("TAF")
		dbSkip()
	End

	dbSelectArea(cTRBTAF)
	dbSetOrder(5)
	nNivel		:= 1
	nMaxNivel	:= 1
	While nNivel<=nMaxNivel
        dbSeek(cCodEst+Str(nNivel,2,0))
		While !(cTRBTAF)->(Eof()) .And. nNivel==(cTRBTAF)->NIVEL

			IncProc()
			nRecTrb:= (cTRBTAF)->(Recno())
			cFilho := (cTRBTAF)->CODPRO

			dbSelectArea("TAF")
			dbSetOrder(2)
			dbSeek(xFilial("TAF")+cCodEst+cFilho)

			nRecTAF := TAF->(Recno())

			dbSelectArea("TAF")
			dbSetOrder(1)
			dbSeek(xFilial("TAF")+cCodEst+cFilho)
			While !TAF->(Eof()) .And. TAF->TAF_FILIAL == xFilial("TAF") .And.;
			TAF->TAF_NIVSUP == cFilho

				IncProc()
				If Empty( TAF->TAF_MODMNT ) .Or. !(TAF->TAF_INDCON $ "1/2")
					TAF->(dbSkip())
					Loop
				EndIf

				If TAF->TAF_INDCON == "1"
					cCargo   := "BEM"

					dbSelectArea("ST9")
					dbSetOrder(1)
					If !dbSeek(xFilial("ST9")+TAF->TAF_CODCON) .Or. ST9->T9_SITBEM <> "A"
						TAF->(dbSkip())
						Loop
					EndIf
				ElseIf TAF->TAF_INDCON == "2"
					cCargo := "LOC"
				EndIf

				RecLock(cTRBTAF,.T.)
				(cTRBTAF)->CODEST  := cCodEst
				(cTRBTAF)->CODPRO  := TAF->TAF_CODNIV
				(cTRBTAF)->DESCRI  := TAF->TAF_NOMNIV
				(cTRBTAF)->NIVSUP  := TAF->TAF_NIVSUP
				(cTRBTAF)->TIPO    := TAF->TAF_INDCON
				(cTRBTAF)->CODTIPO := TAF->TAF_CODCON
				(cTRBTAF)->NIVEL   := nNivel+1
				(cTRBTAF)->CARGO   := cCargo
				(cTRBTAF)->ORDEM   := TAF->TAF_ORDEM
				(cTRBTAF)->CC      := TAF->TAF_CCUSTO
				(cTRBTAF)->CENTRAB := TAF->TAF_CENTRA
				(cTRBTAF)->(MsUnLock())
				nMaxNivel:=nNivel+1
				//Adiciona item no array
				If TAF->TAF_INDCON == "2"
					//Adiciona item no array
					aAdd(aCols, fAddCols(__FOLDER_TAF__,"TAF->TAF_CODNIV","TAF->TAF_NOMNIV"))
				Endif
				dbSelectArea("TAF")
				dbSkip()

			EndDo

			(cTRBTAF)->(dbGoto(nRecTrb))
			TAF->(dbGoTo(nRecTAF))

			If TAF->TAF_INDCON == "1"
				cCargo := "BEM"
			ElseIf TAF->TAF_INDCON == "2"
				cCargo := "LOC"
			EndIf

			If (cTRBTAF)->TIPO == "1"
				cFolderA := "ENGRENAGEM"
				cFolderB := "ENGRENAGEM"
			Else
				cFolderA := "FOLDER10"
				cFolderB := "FOLDER11"
			EndIf

			oTree:TreeSeek((cTRBTAF)->NIVSUP+"LOC")
			oTree:AddItem((cTRBTAF)->DESCRI,(cTRBTAF)->CODPRO+cCargo,cFolderA,cFolderB,,, 2)
			dbSelectArea(cTRBTAF)
			dbSkip()
		EndDo
		nNivel++
	End

	//+----------------------------------+
	//| Fecha folders de todos os filhos |
	//+----------------------------------+
	nNivel := nMaxNivel
	dbSelectArea(cTRBTAF)
	dbSetOrder(5)
	If (cTRBTAF)->(RecCount()) > 0
		ProcRegua(nNivel)
		While nNivel >= 1
            IncProc()
			dbSeek(cCodEst+Str(nNivel,2,0))
            While (cTRBTAF)->NIVEL == nNivel
				If (cTRBTAF)->TIPO == "1"
					cCargo   := "BEM"
				ElseIf (cTRBTAF)->TIPO == "2"
					cCargo := "LOC"
				EndIf

				oTree:TreeSeek((cTRBTAF)->CODPRO+cCargo)

				oTree:PtCollapse()
				(cTRBTAF)->(dbSkip())
			End
			nNivel--
		End
	EndIf

	oTree:EndUpdate()
	oTree:EndTree()
	oTree:TreeSeek("001LOC")
Return aCols

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณChangeFolder บAutor  ณRoger Rodrigues  บ Data ณ  14/07/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAltera variaveis ao trocar de folder                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA297                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ChangeFolder( nOption, oTree )

	Local aArea
	Local lExistReg := .T.
	nFolderAtu := nOption

	If nOption == __FOLDER_TAF__
		lALTERA	:= .F.
		//Verifica se existem registros na arvore para habilitar edi็ใo.
		aArea		:= GetArea()
		dbSelectArea( cTRBTAF )
		dbSetOrder( 2 )
		lExistReg := dbSeek( "001" + Substr( oTree:GetCargo(), 1, 3 ) )
		RestArea( aArea )

		oBtnAlt:lVisible := lExistReg

		//Cria enchoice
		Eval(aObjects[__FOLDER_TAF__]:bChange)
		aObjects[__FOLDER_TAF__]:SetFocus()
	Else
		lALTERA := .T.
		aObjects[nOption]:oBrowse:Refresh()
		oBtnAlt:lVisible := .F.
	EndIf
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} Visualize
Visualiza registro posicionado no momento

@type function

@source MNTA297.prw

@author Roger Rodrigues
@since 11/07/2011

@param oObjeto, Objeto, Objeto com aCols
@param cAlias, Caracter, Alias relacionada ao Folder atual

@sample Visualize( oAcols , "ST9" )

@return Vazio.
/*/
//---------------------------------------------------------------------
Static Function Visualize(oObjeto,cAlias)
	Local aCols, nAt
	Local cIndice := ""
	Local bVisual := {|| NGCAD01(cAlias,Recno(),2)}

	Private aHeader := {}
	Private n := 0
	Private lUltTMS := (GetNewPar("MV_NGMNTMS","N") == "S") //Indica utiliza็ใo do TMS

	//|------------------------------------|
	//| Altera forma de consulta se funcao |
	//| for chamada pela Tree              |
	//|------------------------------------|
	If cAlias == "TAF"
		dbSelectArea(cTRBTAF)
		dbSetOrder(2)
		If dbSeek("001"+Substr(aObjects[__FOLDER_TAF__]:GetCargo(),1,3))
			If (cTRBTAF)->TIPO == "1"
				cIndice := xFilial("ST9")+(cTRBTAF)->(CODTIPO)
				cAlias  := "ST9"
				bVisual := {|| NG080FOLD(cAlias,Recno(),2)}
			Else
				cIndice := xFilial("TAF")+(cTRBTAF)->(CODEST+NIVSUP+ORDEM)
			EndIf
		Else
			Return
		EndIf
	Else
		aCols   := oObjeto:aCols
		aHeader := oObjeto:aHeader
		nAt := oObjeto:nAt
		n 	:= nAt //Transfere o nAt(Variavel de posi็ใo do objeto) para o n(Variavel de posi็ใo do aCols.)
		nPos := GDFIELDPOS("TU7_CODIGO",aHeadCri)
		If nPos > 0
			If cAlias == "ST9"
				cIndice := xFilial(cAlias)+PadR(aCols[nAt][nPos],TAMSX3("T9_CODBEM")[1])
			ElseIf cAlias == "CTT"
				cIndice := xFilial(cAlias)+PadR(aCols[nAt][nPos],TAMSX3("CTT_CUSTO")[1])
			ElseIf cAlias == "ST6"
				cIndice := xFilial(cAlias)+PadR(aCols[nAt][nPos],TAMSX3("T6_CODFAMI")[1])
			Else
				cIndice := xFilial(cAlias)+PadR(aCols[nAt][nPos],TAMSX3("TQ3_CDSERV")[1])
			EndIf
		Endif
		If cAlias == "ST9"
			bVisual := {|| NG080FOLD(cAlias,Recno(),2)}
		Endif
	EndIf

	//|---------------------------------------------------
	//| Localiza registro na cAlias com a chave da cTrb  |
	//|---------------------------------------------------
	dbSelectArea(cAlias)
	dbSetOrder(1)
	If dbSeek(cIndice)
		Eval(bVisual)
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfAtuEnc   บAutor  ณRoger Rodrigues     บ Data ณ  07/13/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria enchoice no folder de arvore logica                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA297                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fAtuEnc(cCodNiv,lDisable,lGrava)
	Local i,nPos, nPosCampo
	Local aChoice 	:= NGCAMPNSX3("TU7",aNao)
	Local aCols 	:= {}
	Local nCmpo 	:= 0
	Local xConteudo := ""

	Default lDisable := .F.
	Default lGrava := .F.

	If lGrava .and. !MNT297VAL("M->TU7_CRITIC")
		Return .F.
	Endif
	If lDisable
		fDisable(!lGrava,!lGrava)
	Endif

	dbSelectArea(cTRBTAF)
	dbSetOrder(2)
	If dbSeek("001"+cCodNiv)
		//Carrega aCols de bem ou localizacao
		If (cTRBTAF)->TIPO == "1"
			aCols := aObjects[__FOLDER_ST9__]:aCols
			cCodNiv := (cTRBTAF)->CODTIPO
		Else
			aCols := aColsTAF
		Endif
		nPosCampo := GDFIELDPOS("TU7_CODIGO",aHeadCri)
		If (nPos := aScan(aCols, {|x| Substr(x[nPosCampo],1,Len(cCodNiv)) == cCodNiv})) > 0
			If lGrava//Gravacao no Array
				For i:=1 to Len(aHeadCri)

					nCmpo := "M->" + aHeadCri[i][2]
					xConteudo := &nCmpo.

					If ValType(xConteudo) != "U"
						aCols[nPos][i] := &("M->"+aHeadCri[i][2])
					Endif
				Next i
				If (cTRBTAF)->TIPO == "1"
					aObjects[__FOLDER_ST9__]:aCols := aCols
				Else
					aColsTAF := aCols
				Endif
			Else//Visualizacao
				For i:=1 to Len(aChoice)
					If (nPosCampo := GDFIELDPOS(aChoice[i],aHeadCri)) > 0
						&("M->"+aChoice[i]) := aCols[nPos][nPosCampo]
					Endif
				Next i
			Endif
		Endif
	Endif

	oEncTAF:EnchRefreshAll()

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfDisable  บAutor  ณRoger Rodrigues     บ Data ณ  14/07/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDesabilita/Habilita objetos da tela                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMTNA297                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fDisable(lDisable,lAtuEnc)
	Local i
	Default lDisable := .T.
	Default lAtuEnc  := .T.

	lALTERA := lDisable

	If lDisable
		aObjects[__FOLDER_TAF__]:Disable()
		oPnlBtn297:Disable()
		oPnlSrc297:Disable()
		oPnlBtnTAF:Show()
		For i:=1 to Len(oFolder297:aDialogs)
			If i != __FOLDER_TAF__
				oFolder297:aDialogs[i]:Disable()
			Endif
		Next i
	Else
		If lAtuEnc
			fAtuEnc(Substr(aObjects[__FOLDER_TAF__]:GetCargo(),1,3))
		Endif
		aObjects[__FOLDER_TAF__]:Enable()
		oPnlBtn297:Enable()
		oPnlSrc297:Enable()
		oPnlBtnTAF:Hide()
		For i:=1 to Len(oFolder297:aDialogs)
			If i != __FOLDER_TAF__
				oFolder297:aDialogs[i]:Enable()
			Endif
		Next i
	Endif
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMNT297VAL บAutor  ณRoger Rodrigues     บ Data ณ  14/07/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida campos da tela                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA297                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNT297VAL(cReadVar)
	Local cVar := ""
	Local cDia := cMes := ""
	Local dData:= CTOD("")
	Local aHeadVal := {}, aColsVal := {}, nPos, nAt
	Default cReadVar := ReadVar()

	If cReadVar == "M->TU7_CRITIC" .or. cReadVar == "M->TUC_CRITIC"
		cVar := &(cReadVar)
		If Positivo(cVar)
			If cVar > 100
				ShowHelpDlg(STR0011,{STR0018},1,{STR0019}) //"Aten็ใo" ## "Favor informar um valor de 0 at้ 100." ## "Onde 0 indica que nใo hแ criticidade definida."
				Return .F.
			Endif
		Else
			Return .F.
		Endif
	ElseIf cReadVar == "M->TUC_PERINI" .or. cReadVar == "M->TUC_PERFIM"
		cVar := &(cReadVar)
		cDia := Substr(cVar,1,2)
		cMes := Substr(cVar,4,2)
		If NaoVazio(cDia) .and. NaoVazio(cMes)
			dData := CTOD(cVar+"/"+Str(Year(dDatabase),4))
			If (At("-",cVar) > 0) .or. Empty(dData)
				If cDia != "29" .or. ((Len(AllTrim(cMes)) == 1 .and. AllTrim(cMes) <> "2") .or. (Len(AllTrim(cMes)) > 1 .and. cMes <> "02"))//Tratamento para ano bisexto
					ShowHelpDlg(STR0011,{STR0020},1,{STR0021}) //"Aten็ใo" ## "O dia/m๊s informado estแ incorreto." ## "Favor informar um dia/m๊s vแlido."
					Return .F.
				Endif
			Endif
			&(cReadVar) := StrZero(Val(cDia),2)+"/"+StrZero(Val(cMes),2)//Corrige mes com zero
			aHeadVal := oGetSAZ:aHeader
			aColsVal := oGetSAZ:aCols
			nAt := oGetSAZ:nAt
			nPos := If(cReadVar == "M->TUC_PERINI", GDFIELDPOS("TUC_PERFIM",aHeadVal), GDFIELDPOS("TUC_PERINI",aHeadVal))
			If !Empty(aColsVal[nAt][nPos])
				If (cReadVar == "M->TUC_PERINI" .and. A297CPER(M->TUC_PERINI, aColsVal[nAt][nPos], ">")) .or.;
				(cReadVar == "M->TUC_PERFIM" .and. A297CPER(aColsVal[nAt][nPos], M->TUC_PERFIM, ">"))
					ShowHelpDlg(STR0011,{STR0022},1,{STR0023}) //"Aten็ใo" ## "O perํodo informado nใo ้ vแlido." ## "Favor informar um perํodo vแlido."
					Return .F.
				Endif
			Endif
		Else
			Return .F.
		Endif
	Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfGrava    บAutor  ณRoger Rodrigues     บ Data ณ  19/07/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza gravacao nas tabelas                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMTNA297                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fGrava()
	Local i,j,k,l,nPos
	Local aCols := {}
	Local cAliasSaz, aHeadSaz, aColsSaz, nPosChav, cCpoChav, cCond
	Local cOpcao:= ""
	Local nPosCod := GDFIELDPOS("TU7_CODIGO",aHeadCri)
	Local nPosCri := GDFIELDPOS("TU7_CRITIC",aHeadCri)
	Local nValCri

	If nPosCod > 0 .and. nPosCri > 0
		For i:=1 to __SIZE_ARRAY__
			If i != __FOLDER_TAF__
				aCols := aObjects[i]:aCols
			Else
				aCols := aColsTAF
			Endif
			cOpcao := StrZero(i,1)
			For j:=1 to Len(aCols)
				nValCri := If( ValType( aCols[j][nPosCri] ) == "N", aCols[j][nPosCri], Val( aCols[j][nPosCri] ) )
				If nValCri > 0
					dbSelectArea("TU7")
					dbSetOrder(1)
					If dbSeek(xFilial("TU7")+cOpcao+aCols[j][nPosCod])
						RecLock("TU7",.F.)
					Else
						RecLock("TU7",.T.)
					Endif
					For k:=1 to FCount()
						If "_FILIAL" $ FieldName(k)
							FieldPut(k, xFilial("TU7"))
						ElseIf "_OPCAO" $ FieldName(k)
							FieldPut(k, cOpcao)
						ElseIf "_CODIGO" $ FieldName(k)
							FieldPut(k, aCols[j][nPosCod])
						ElseIf "_CRITIC" $ FieldName(k)
							If NgSeekDic( "SX3", "TU7_CRITIC", 2, "X3_TIPO" ) <> "N"
								FieldPut( k, cValToChar( nValCri ) )
							Else
								FieldPut( k, nValCri )
							EndIf
						ElseIf (nPos := GDFIELDPOS(FieldName(k),aHeadCri)) > 0
							FieldPut(k, aCols[j][nPos])
						Endif
					Next k
					MsUnlock("TU7")
				Else
					dbSelectArea("TU7")
					dbSetOrder(1)
					If dbSeek(xFilial("TU7")+cOpcao+aCols[j][nPosCod])
						RecLock("TU7",.F.)
						dbDelete()
						MsUnlock("TU7")
					Endif
				Endif
			Next j
			//Grava Sazonalidade e Areas
			For j:=1 to __SIZE_SAZONAL__
				If !Empty(aSazonal[i][j])
					cAliasSaz := "TUC"
					cCpoChav  := "TUC_PERINI"
					cCond     := "TUC->(TUC_FILIAL+TUC_OPCAO+TUC_CODIGO)"
					For k:=1 to Len(aSazonal[i][j])
						cCodigo  := aSazonal[i][j][k][__POS_COD__]
						aHeadSaz := aSazonal[i][j][k][__POS_HEAD__]
						aColsSaz := aSazonal[i][j][k][__POS_COLS__]

						//Exclui registros da base
						dbSelectArea(cAliasSaz)
						dbSetOrder(1)
						dbSeek(xFilial(cAliasSaz)+cOpcao+cCodigo)
						While !eof() .and. xFilial(cAliasSaz)+cOpcao+cCodigo == &(cCond)
							RecLock(cAliasSaz,.F.)
							dbDelete()
							MsUnlock(cAliasSaz)
							dbSelectArea(cAliasSaz)
							dbSkip()
						End

						nPosChav := GDFIELDPOS(cCpoChav,aHeadSaz)
						ASORT(aColsSaz,,, { |x, y| x[Len(aHeadSaz)+1] .and. !y[Len(aHeadSaz)+1] } )//Ordena os deletados por primeiro
						For l:=1 to Len(aColsSaz)
							If !aColsSaz[l][Len(aHeadSaz)+1] .and. !Empty(aColsSaz[l][nPosChav])
								dbSelectArea(cAliasSaz)
								dbSetOrder(1)
								If dbSeek(xFilial(cAliasSaz)+cOpcao+cCodigo+aColsSaz[l][nPosChav])
									RecLock(cAliasSaz,.F.)
								Else
									RecLock(cAliasSaz,.T.)
								Endif
								For k:=1 to FCount()
									If "_FILIAL" $ FieldName(k)
										FieldPut(k, xFilial(cAliasSaz))
									ElseIf "_OPCAO" $ FieldName(k)
										FieldPut(k, cOpcao)
									ElseIf "_CODIGO" $ FieldName(k)
										FieldPut(k, cCodigo)
									ElseIf cCpoChav $ FieldName(k)
										FieldPut(k, aColsSaz[l][nPosChav])
									ElseIf (nPos := GDFIELDPOS(FieldName(k),aHeadSaz)) > 0
										FieldPut(k, aColsSaz[l][nPos])
									Endif
								Next k
								MsUnlock(cAliasSaz)
							ElseIf !Empty(aColsSaz[l][nPosChav])
								dbSelectArea(cAliasSaz)
								dbSetOrder(1)
								If dbSeek(xFilial(cAliasSaz)+cOpcao+cCodigo+aColsSaz[l][nPosChav])
									RecLock(cAliasSaz,.F.)
									dbDelete()
									MsUnlock(cAliasSaz)
								Endif
							Endif
						Next l
					Next k
				Endif
			Next j
		Next i
	Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfDefSaz   บAutor  ณRoger Rodrigues     บ Data ณ  20/07/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta tela para definicao de criticidade por sazonalidade e บฑฑ
ฑฑบ          ณarea                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA297                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fDefSaz()
	Local aNGBEGINPRM := NGBEGINPRM(,"MNTA297")//Guarda Variaveis padrao

	//Variaveis da tela
	Local i, nLinha, oObjeto
	Local oDlgSaz
	Local lOk 		:= .T.
	Local nFolder  	:= nFolderAtu
	Local nSizeCod 	:= If(TAMSX3("TU7_CODIGO")[1] > 0, TAMSX3("TU7_CODIGO")[1], 20)
	Local lOldAlt 	:= lAltera
	Local cTitulo 	:= STR0001 //"Defini็ใo de Parโmetros de Criticidade"
	Local nCmpo		:= 0

	//Variaveis para obter codigo do codigo pai
	Local aColsItem := {}
	Local cOpcao  	:= StrZero(nFolder,1), cCodigo := ""
	Local nAt, nPosCod := GDFIELDPOS("TU7_CODIGO",aHeadCri)

	//Definicao de tamanho de tela e objetos
	Local aSize := {}, aObj := {}, aInfo := {}, aPosObj := {}

	Local oFolderSaz, aFolders := {}
	Local oEncSaz
	Local aHeadSaz := aColsSaz := {}
	Local aNaoTUC := {"TUC_OPCAO","TUC_CODIGO"}, cWhileTUC

	Local xConteudo := ""

	//Redefine variaveis
	aTela := {}
	aGets := {}
	lAltera := .F.

	//Determina item pai
	If nFolder == __FOLDER_TAF__
		cCodigo := Substr(aObjects[__FOLDER_TAF__]:GetCargo(),1,3)
		dbSelectArea(cTRBTAF)
		dbSetOrder(2)
		If dbSeek("001"+cCodigo) .and. (cTRBTAF)->TIPO == "1"
			cCodigo := (cTRBTAF)->CODTIPO
			aColsItem := aObjects[__FOLDER_ST9__]:aCols
			nFolder := __FOLDER_ST9__
			cOpcao  := StrZero(nFolder,1)
		Else
			aColsItem := aColsTAF
		Endif
		cCodigo := Padr(cCodigo,nSizeCod)
		nAt := aScan(aColsItem, {|x| x[nPosCod] == cCodigo})
	Else
		nAt := aObjects[nFolder]:nAt
		cCodigo := aObjects[nFolder]:aCols[nAt][nPosCod]
		aColsItem := aObjects[nFolder]:aCols
	Endif
	cWhileTUC := "TUC->(TUC_FILIAL+TUC_OPCAO+TUC_CODIGO) == '"+xFilial("TUC")+cOpcao+cCodigo+"'"

	aAdd(aFolders,STR0024) //"Sazonalidade"

	//Definicao de tamanho de tela e objetos
	aSize := MsAdvSize(,.F.,430)
	Aadd(aObj,{015,015,.T.,.T.})
	Aadd(aObj,{085,085,.T.,.T.})
	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObj,.T.)

	Define MsDialog oDlgSaz Title OemToAnsi(cTitulo) From aSize[7],0 To aSize[6],aSize[5] Of oMainWnd Pixel

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Parte Superior da tela                               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Dbselectarea("TU7")
	//Carrega Registro
	RegToMemory("TU7",.T.)
	For i:=1 to Len(aHeadCri)

		nCmpo := "M->" + aHeadCri[i][2]
		xConteudo := &nCmpo.

		If ValType(xConteudo) != "U"
			&("M->"+aHeadCri[i][2]) := aColsItem[nAt][i]
		Endif
	Next i
	oEncSaz:= MsMGet():New("TU7",0,3,,,,NGCAMPNSX3("TU7",aNao),aPosObj[1],,,,,,oDlgSaz,,.T.,.F.)
	oEncSaz:oBox:Align := CONTROL_ALIGN_TOP

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Parte Inferior da tela                               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oFolderSaz := TFolder():New(300,0,aFolders,,oDlgSaz,,,,.T.,.F.)
	oFolderSaz:Align := CONTROL_ALIGN_ALLCLIENT

	//-----------------------------------
	// Carrega dados de Sazonalidade
	//-----------------------------------
	FillGetDados( 4,"TUC",1,,,,aNaoTUC,,,,{|| NGMontaAcols("TUC",cOpcao+cCodigo,cWhileTUC)},,aHeadSaz,aColsSaz)
	If (nLinha := aScan(aSazonal[nFolder][1], {|x| x[__POS_COD__] == cCodigo})) > 0
		aHeadSaz := aSazonal[nFolder][1][nLinha][__POS_HEAD__]
		aColsSaz := aSazonal[nFolder][1][nLinha][__POS_COLS__]
	Endif
	oGetSaz := MsNewGetDados():New(5,5,500,500,If(!Inclui.And.!Altera,0,GD_INSERT+GD_UPDATE+GD_DELETE),{|| MNT297OK(oGetSaz,"TUC")},"AllWaysTrue()",,,,9999,,,,oFolderSaz:aDialogs[1],aHeadSaz,aColsSaz)
	oGetSaz:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGetSaz:oBrowse:Refresh()

	Activate MsDialog oDlgSaz On Init (EnchoiceBar(oDlgSaz,{|| If(MNT297OK(oGetSaz,"TUC",.T.),(lOk:=.T.,oDlgSaz:End()),lOk:=.F.)},;
	{|| lOk:=.F.,oDlgSaz:End()})) Centered

	//Grava itens no Array
	If lOk
		For i:=1 To __SIZE_SAZONAL__
			nLinha := 0
			If i == 1
				oObjeto := oGetSaz
			Endif
			//Grava areas em um array
			If Empty(aSazonal[nFolder][i])
				aSazonal[nFolder][i] := {}
			Endif
			If Len(aSazonal[nFolder][i]) == 0 .or. ((nLinha := aScan(aSazonal[nFolder][i], {|x| x[__POS_COD__] == cCodigo})) == 0)
				aAdd(aSazonal[nFolder][i], Array(__LEN_ARR_SAZ__))//Opcao, Codigo, aHeader, aCols
				nLinha := Len(aSazonal[nFolder][i])
			Endif
			If nLinha > 0
				aSazonal[nFolder][i][nLinha][__POS_COD__]  := cCodigo
				aSazonal[nFolder][i][nLinha][__POS_HEAD__] := oObjeto:aHeader
				aSazonal[nFolder][i][nLinha][__POS_COLS__] := oObjeto:aCols
			Endif
		Next i
	Endif

	//Retorna Variaveis
	lAltera := lOldAlt
	NGRETURNPRM(aNGBEGINPRM)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMNT297LOK บAutor  ณRoger Rodrigues     บ Data ณ  21/07/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida as linhas da GetDados                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA297                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNT297OK(oGet,cTabela,lFim)
	Local f
	Local aColsOk := {}, aHeadOk := {}
	Local nPosCod := 1, nPosFim := 0, nPosCri := 3, nAt := 1
	Default lFim := .F.

	aColsOk := aClone(oGet:aCols)
	aHeadOk := aClone(oGet:aHeader)
	nAt := oGet:nAt

	If cTabela == "TUC"
		nPosCod := GDFIELDPOS("TUC_PERINI",aHeadOk)
		nPosFim := GDFIELDPOS("TUC_PERFIM",aHeadOk)
		nPosCri := GDFIELDPOS("TUC_CRITIC",aHeadOk)
	Endif

	//Percorre aCols
	For f:= 1 to Len(aColsOk)
		If !aColsOk[f][Len(aColsOk[f])]
			If lFim .or. f == nAt
				//Verifica se os campos obrigat๓rios estใo preenchidos
				If cTabela == "TUC"
					If !lFim .or. (!Empty(aColsOk[f][nPosCod]) .or. !Empty(aColsOk[f][nPosFim]) .or. !Empty(aColsOk[f][nPosCri]))
						If Empty(aColsOk[f][nPosCod])
							//Mostra mensagem de Help
							Help(1," ","OBRIGAT2",,aHeadOk[nPosCod][1],3,0)
							Return .F.
						ElseIf Empty(aColsOk[f][nPosFim])
							//Mostra mensagem de Help
							Help(1," ","OBRIGAT2",,aHeadOk[nPosFim][1],3,0)
							Return .F.
						ElseIf Empty(aColsOk[f][nPosCri])
							//Mostra mensagem de Help
							Help(1," ","OBRIGAT2",,aHeadOk[nPosCri][1],3,0)
							Return .F.
						Endif
					Endif
				Endif
			Endif

			//Verifica se ้ somente LinhaOk
			If f <> nAt .and. !aColsOk[nAt][Len(aColsOk[nAt])]
				If cTabela == "TUC"
					If (A297CPER(aColsOk[nAt][nPosCod], aColsOk[f][nPosCod], ">=") .and. A297CPER(aColsOk[nAt][nPosCod], aColsOk[f][nPosFim], "<=")) .or.;
					(A297CPER(aColsOk[nAt][nPosFim], aColsOk[f][nPosCod], ">=") .and. A297CPER(aColsOk[nAt][nPosFim], aColsOk[f][nPosFim], "<=")) .or.;
					(A297CPER(aColsOk[nAt][nPosCod], aColsOk[f][nPosCod], "<=") .and. A297CPER(aColsOk[nAt][nPosFim], aColsOk[f][nPosFim], ">="))
						ShowHelpDlg("JAEXISTINF",{STR0025},1,{STR0026})//"Perํodo jแ informado." ## "Informe um perํodo vแlido."
						Return .F.
					Endif
				Endif
			Endif
		Endif
	Next f

	PutFileInEof(cTabela)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA297CPER  บAutor  ณRoger Rodrigues     บ Data ณ  02/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCompara periodos                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA297                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A297CPER(cPer1, cPer2, cOperac)
	Local lRet := .T.
	Local nDia1 := Val(Substr(cPer1,1,2))
	Local nMes1 := Val(Substr(cPer1,4,2))
	Local nDia2 := Val(Substr(cPer2,1,2))
	Local nMes2 := Val(Substr(cPer2,4,2))

	If cOperac == ">="
		lRet := ((nDia1 == nDia2 .and. nMes1 == nMes2) .or. (nMes1 > nMes2) .or. (nMes1 == nMes2 .and. nDia1 > nDia2))
	ElseIf cOperac == ">"
		lRet := ((nMes1 > nMes2) .or. (nMes1 == nMes2 .and. nDia1 > nDia2))
	ElseIf cOperac == "<="
		lRet := ((nDia1 == nDia2 .and. nMes1 == nMes2) .or. (nMes1 < nMes2) .or. (nMes1 == nMes2 .and. nDia1 < nDia2))
	ElseIf cOperac == "<"
		lRet := ((nMes1 < nMes2) .or. (nMes1 == nMes2 .and. nDia1 < nDia2))
	ElseIf cOperac == "=="
		lRet := (nDia1 == nDia2 .and. nMes1 == nMes2)
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} NGCALCRI
Realiza cแlculo da Criticidade da Solicita็ใo

@type Function

@author Roger Rodrigues
@since 03/08/2011

@param cTipoSS, caractere, tipo da SS
@param cBemLoc, caractere, bem/Localiza็ใo da SS
@param [cCCusto], caractere, centro de Custo da SS
@param [dDataSS], data, data da SS
@param [cCDServ], caractere, c๓digo do servi็o

@todo implementar o parโmetro cCDServ nas chamadas da fun็ใo

@return num้rico, total da criticidade da SS
/*/
//-------------------------------------------------------------------
Function NGCALCRI(cTipoSS, cBemLoc, cCCusto, dDataSS, cCDServ)

    Local nGrupo
    Local nQtdGrps   := 0  // Quantidade de Grupos com criticidade maior que zero
    Local nCritGrp   := 0  // Criticidade individual de um grupo
    Local nCritSoma  := 0  // Soma das criticidades dos grupos
    Local nCritFinal := 0  // Criticidade final calculada
    Local aCritGrps  := {} // Criticidades de todos os grupos
	Local cFamilia   := "" // Famํlia do Bem/Localiza็ใo utilizada no Grupo 1

	Local aArea := GetArea()

	Default cCCusto := ""
	Default dDataSS := dDatabase
	Default cCDServ := ""

	If !Empty(cTipoSS) .And. !Empty(cBemLoc)

		//-------------------------------------------
		// Grupo 1 (Bem/Localiza็ใo/Famํlia)
		//-------------------------------------------
		If cTipoSS == "B" // Bem
			dbSelectArea("ST9")
			dbSetOrder(1)
			If dbSeek(xFilial("ST9")+cBemLoc)
				cFamilia := ST9->T9_CODFAMI
				If Empty(cCCusto)
					cCCusto := ST9->T9_CCUSTO
				Endif
			Endif
			nCritGrp := NGRETCRIT("ST9", cBemLoc, dDataSS)
		Else // Localiza็ใo
			dbSelectArea("TAF")
			dbSetOrder(8)
			If dbSeek(xFilial("TAF")+cBemLoc)
				cFamilia := TAF->TAF_CODFAM
				If Empty(cCCusto)
					cCCusto := TAF->TAF_CCUSTO
				Endif
			Endif
			nCritGrp := NGRETCRIT("TAF", cBemLoc, dDataSS)
		Endif

        // Caso a criticidade do Bem/Localiza็ใo for 0 (zero),
        // busca a criticidade da Famํlia
        If nCritGrp == 0
            // A criticidade mํnima para esse grupo deve ser 1
			nCritGrp := Max( 1, NGRETCRIT("ST6", cFamilia, dDataSS) )
        EndIf

        // Adicionar o Grupo 1 ao array de criticidades dos grupos
        aAdd( aCritGrps, nCritGrp )

		//-------------------------------------------
		// Grupo 2 (Centro de Custo)
		//-------------------------------------------
		aAdd( aCritGrps, NGRETCRIT( "CTT", cCCusto, dDataSS ) )

        //-------------------------------------------
		// Grupo 3 (Tipo de Servi็o)
		//-------------------------------------------
        aAdd( aCritGrps, NGRETCRIT( "TQ3", cCDServ, dDataSS ) )

		//-------------------------------------------
		// Calcula a criticidade final
		//-------------------------------------------
		For nGrupo := 1 To Len( aCritGrps )

            // Desconsidera grupos com criticidade 0 (zero)
            If aCritGrps[nGrupo] > 0

                // Acumula a criticidade do grupo atual
                // e incrementa contador de grupos
                nCritSoma += aCritGrps[nGrupo]
                nQtdGrps++

            EndIf

        Next

        // Criticidade Final = M้dia entre os grupos com criticidade maior que 0 (zero)
        nCritFinal := Round( nCritSoma / nQtdGrps, 0 )

	Endif

	RestArea(aArea)

Return nCritFinal

//-------------------------------------------------------------------
/*/{Protheus.doc} NGRETCRIT
Retorna criticidade de um item

@type   Function

@author Roger Rodrigues
@since 03/08/2011

@param cTabela, caractere, tabela a ser verificada
@param cCodigo, caractere, codigo do item a ser verificado
@param [dData], data, data para ser verificada

@return num้rico, criticidade do item da SS
/*/
//-------------------------------------------------------------------
Function NGRETCRIT(cTabela,cCodigo,dData)

	Local aArea    := GetArea()
	Local nCrit    := 0
	Local nCritSaz := 0
	Local nSizeCod := IIf(TAMSX3("TU7_CODIGO")[1] > 0, TAMSX3("TU7_CODIGO")[1], 20)
	Local cPeriodo := ""
	Local cOpcCTT  := StrZero(__FOLDER_CTT__,1) // CENTRO DE CUSTO
	Local cOpcST6  := StrZero(__FOLDER_ST6__,1) // FAMILIA DE BENS
	Local cOpcST9  := StrZero(__FOLDER_ST9__,1) // BEM
	Local cOpcTQ3  := StrZero(__FOLDER_TQ3__,1) // TIPO DE SERVICO
	Local cOpcTAF  := StrZero(__FOLDER_TAF__,1) // LOCALIZACAO
	Local cOpcSeek := ""

	Default dData := CTOD("")

	// Valida exist๊ncia das tabelas TU7 e TUC
	If !AliasInDic("TU7") .Or. !AliasInDic("TUC")
		RestArea(aArea)
		Return nCrit
	Endif

	// Se nใo tiver item para validar
	If Empty(cCodigo)
		RestArea(aArea)
		Return nCrit
	Endif

	// Monta Perํodo
	If !Empty(dData)
		cPeriodo := StrZero(Day(dData),2)+"/"+StrZero(Month(dData),2)
	Endif

	// Carrega op็ใo
	If cTabela == "CTT"
		cOpcSeek := cOpcCTT
	ElseIf cTabela == "ST6"
		cOpcSeek := cOpcST6
	ElseIf cTabela == "ST9"
		cOpcSeek := cOpcST9
	ElseIf cTabela == "TAF"
		cOpcSeek := cOpcTAF
	ElseIf cTabela == "TQ3"
		cOpcSeek := cOpcTQ3
	Endif
	cCodigo := Padr(cCodigo,nSizeCod)

	// Pesquisa Criticidade
	dbSelectArea("TU7")
	dbSetOrder(1)
	If dbSeek(xFilial("TU7")+cOpcSeek+cCodigo)
		nCrit := If( ValType( TU7->TU7_CRITIC ) == "N", TU7->TU7_CRITIC, Val( TU7->TU7_CRITIC ) )
	Endif

	// Verifica por Sazonalidade
	If !Empty(cPeriodo)
		dbSelectArea("TUC")
		dbSetOrder(1)
		dbSeek(xFilial("TUC")+cOpcSeek+cCodigo)
		While !Eof() .And. xFilial("TUC")+cOpcSeek+cCodigo == TUC->(TUC_FILIAL+TUC_OPCAO+TUC_CODIGO)
			If A297CPER(cPeriodo, TUC->TUC_PERINI, ">=") .And. A297CPER(cPeriodo, TUC->TUC_PERFIM, "<=")
				nCritSaz := TUC->TUC_CRITIC
			Endif
			dbSelectArea("TUC")
			dbSkip()
		End
	Endif

	If nCritSaz > 0
		nCrit := nCritSaz
	Endif

	RestArea(aArea)

Return nCrit
