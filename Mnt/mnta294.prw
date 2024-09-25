#INCLUDE "Protheus.ch"
#INCLUDE "MNTA294.ch"

#DEFINE _nVERSAO 1 //Versao do fonte
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMNTA294   บAutor  ณRoger Rodrigues     บ Data ณ  07/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefinicao do pre-filtro de distribuicao                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAMNT                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTA294()

	//Guarda Variaveis Padrao
	Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)

	Private cCadastro := FWX2Nome("TUG")
	Private aRotina := MenuDef()

	// Variแvel das cores da tela
	Private aNGColor := aClone( NGCOLOR("10") )

	//Verifica se o update de facilities foi aplicado
	If !FindFunction("MNTUPDFAC") .or. !MNTUPDFAC()
		Return .F.
	Endif

	dbSelectArea("TUG")
	dbSetOrder(1)
	mBrowse(6,1,22,75,"TUG")

	//Retorna variaveis padrao
	NGRETURNPRM(aNGBEGINPRM)
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณ Roger Rodrigues       ณ Data ณ07/12/2011ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Utilizacao de menu Funcional                               ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transacao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ    1 - Pesquisa e Posiciona em um Banco de Dados           ณฑฑ
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ    3 - Inclui registros no Bancos de Dados                 ณฑฑ
ฑฑณ          ณ    4 - Altera o registro corrente                          ณฑฑ
ฑฑณ          ณ    5 - Remove o registro corrente do Banco de Dados        ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MenuDef()
	Local aRotina := {	{STR0001,"PesqBrw"	, 0, 1},; //"Pesquisar"
	{STR0002,"MNT294INC"	, 0, 2},; //"Visualizar"
	{STR0003,"MNT294INC"	, 0, 3},; //"Incluir"
	{STR0004,"MNT294INC"	, 0, 4},; //"Alterar"
	{STR0005,"MNT294INC"	, 0, 5,,.F.}} //"Excluir"

Return aRotina
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMNT294INC บAutor  ณRoger Rodrigues     บ Data ณ  07/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta tela de inclusao                                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA294                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNT294INC(cAlias, nRecno, nOpcx)

	Local oDlg294, oPanel, oEnc294, oPnlLeg, oPnlTop, oPnlBot, oPnlBtn, oBtnCC
	Local lOk := .F.

	//Variaveis de tamanho de tela e objetos
	Local aSize := {}, aObjects := {}, aInfo := {}, aPosObj := {}

	//Variaveis de getdados
	Local cGetTUH
	Local aColsTUH := {}, aHeadTUH := {}
	Private oGet294

	//Variaveis da enchoice
	Private aTrocaF3 := {}
	Private aGets := {}, aTela := {}
	Private cFilOld := cFilAnt//Variavel para troca de filiais

	//Variaveis do MarkBrowse
	Private cMarca := GetMark()
	Private lInverte := .F.

	//Definicao de tamanho de tela e objetos
	aSize := MsAdvSize(,.f.,430)
	Aadd(aObjects,{025,025,.t.,.t.})
	Aadd(aObjects,{075,075,.t.,.t.})
	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObjects,.t.)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSeta Visual, Inclui, Altera ou Exclui conforme nOpcณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aRotSetOpc(cAlias,nRecno,nOpcx)

	Define MsDialog oDlg294 Title OemToAnsi(cCadastro) From aSize[7],0 To aSize[6],aSize[5] Of oMainWnd Pixel
	oDlg294:lMaximized := .T.

	//Define painel principal
	oPanel := TPanel():New(0,0,,oDlg294,,,,,,aSize[5],aSize[6],.F.,.F.)
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Parte Superior da tela                               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oPnlTop := TPanel():New(,,,oPanel,,,,,aNGColor[1],aNGColor[2], aPosObj[1,3], .F., .F. )
	oPnlTop:Align := CONTROL_ALIGN_TOP

	Dbselectarea("TUG")
	RegToMemory("TUG",Inclui)
	oEnc294 := MsMGet():New("TUG",nRecno,nOpcx,,,,,aPosObj[1],,,,,,oPnlTop,,,.F.)
	oEnc294:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Parte Inferior da tela                               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oPnlBot := TPanel():New(00,00,,oPanel,,,,,,aPosObj[2,4],aPosObj[2,3],.F.,.F.)
	oPnlBot:Align := CONTROL_ALIGN_ALLCLIENT

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCarrega dados da Regra           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//Cria Panel de Legenda
	oPnlLeg:=TPanel():New(00,00,,oPnlBot,,,,aNGColor[1],aNGColor[2],200,200,.F.,.F.)
	oPnlLeg:nHeight := 25
	oPnlLeg:Align := CONTROL_ALIGN_TOP

	@ 003,003 Say OemToAnsi(STR0006) Of oPnlLeg Color aNGColor[1] Pixel //"Informe os atendentes desta Famํlia/Tipo Servi็o."

	//Cria Panel com Botao
	oPnlBtn := TPanel():New(00,00,,oPnlBot,,,,aNGColor[1],aNGColor[2],12,12,.F.,.F.)
	oPnlBtn:Align := CONTROL_ALIGN_LEFT

	oBtnCC := TBtnBmp():NewBar("ng_ico_etapa","ng_ico_etapa",,,,{|| fMarkCC() },,oPnlBtn,,,STR0007,,,,,"") //"Centros de Custo do Atendente"
	oBtnCC:Align := CONTROL_ALIGN_TOP

	cGetTUH := "TUH->TUH_FILIAL == '"+xFilial("TUH")+"' .AND. TUH->TUH_CODFAM = '"+M->TUG_CODFAM+"' .AND. TUH->TUH_CDSERV = '"+M->TUG_CDSERV+"'"
	FillGetDados( nOpcx, "TUH", 1, "TUG->TUG_CODFAM+TUG->TUG_CDSERV", {|| }, {|| .T.},{"TUH_CODFAM","TUH_CDSERV"},,,,{|| NGMontaAcols("TUH", TUG->TUG_CODFAM+TUG->TUG_CDSERV,cGetTUH)},,aHeadTUH,aColsTUH)

	If Empty(aColsTUH) .Or. nOpcx == 3
		aColsTUH := BlankGetd(aHeadTUH)
	Endif
	n := Len(aColsTUH)

	oGet294 := MsNewGetDados():New(5,5,600,600,If(!Inclui .and. !Altera, 0, GD_INSERT+GD_DELETE+GD_UPDATE),{|| fLinOK()},"AllWaysTrue()",,,,9999,,,,oPnlBot, aHeadTUH, aColsTUH)
	oGet294:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGet294:oBrowse:Default()
	oGet294:oBrowse:Refresh()

	Activate MsDialog oDlg294 On Init (EnchoiceBar(oDlg294,{|| If(fTudoOk(nOpcx),(lOk:=.T.,oDlg294:End()),lOk:=.F.)},{|| lOk:=.F.,oDlg294:End()})) Centered

	If lOk .and. nOpcx != 2
		fGrava(nOpcx)
	Endif

	If nOpcx != 3
		dbSelectArea("TUG")
		dbGoTo(nRecno)
	Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMNT294VAL บAutor  ณRoger Rodrigues     บ Data ณ  07/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao dos campos da tela                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA294                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNT294VAL(cCampo)
	Local lRet := .T.
	Local xValor
	Local nAt  := oGet294:nAt
	Local aColsVal := oGet294:aCols
	Local nPos, nPosTip
	Local nTamFor  := If((TAMSX3("A2_COD")[1]) > 0,TAMSX3("A2_COD")[1], 6)
	Default cCampo := ReadVar()

	xValor := &(cCampo)

	If cCampo == "M->TUG_CODFAM"
		lRet := ExistCpo("ST6",xValor)
	ElseIf cCampo == "M->TUG_CDSERV"
		lRet := Empty(xValor) .or. ExistCpo("TQ3",xValor)
	ElseIf cCampo == "M->TUG_QTDREI"
		lRet := Positivo()
	ElseIf cCampo == "M->TUG_UNIREI"
		lRet := Empty(xValor) .or. Pertence("123")
	ElseIf cCampo == "M->TUG_TMPMAX"
		lRet := Empty(StrTran(xValor,":","")) .or. VALHORA(xValor)
	ElseIf cCampo == "M->TUH_TIPATE"
		lRet := Pertence("123")
		If lRet
			nPos := GDFIELDPOS("TUH_FILATE", oGet294:aHeader)
			aColsVal[nAt][nPos] := Space(TAMSX3("TUH_FILATE")[1])
			nPos := GDFIELDPOS("TUH_CODATE", oGet294:aHeader)
			aColsVal[nAt][nPos] := Space(TAMSX3("TUH_CODATE")[1])
			nPos := GDFIELDPOS("TUH_DESATE", oGet294:aHeader)
			aColsVal[nAt][nPos] := Space(TAMSX3("TUH_DESATE")[1])
			nPos := GDFIELDPOS("TUH_LOJATE", oGet294:aHeader)
			aColsVal[nAt][nPos] := Space(TAMSX3("TUH_LOJATE")[1])
		Endif
	ElseIf cCampo == "M->TUH_FILATE"
		lRet := FilChkNew(cEmpAnt,xValor)
		If lRet
			nPos := GDFIELDPOS("TUH_CODATE", oGet294:aHeader)
			aColsVal[nAt][nPos] := Space(TAMSX3("TUH_CODATE")[1])
			nPos := GDFIELDPOS("TUH_DESATE", oGet294:aHeader)
			aColsVal[nAt][nPos] := Space(TAMSX3("TUH_DESATE")[1])
			nPos := GDFIELDPOS("TUH_LOJATE", oGet294:aHeader)
			aColsVal[nAt][nPos] := Space(TAMSX3("TUH_LOJATE")[1])
		Endif
	ElseIf cCampo == "M->TUH_CODATE"
		nPosTip := GDFIELDPOS("TUH_TIPATE", oGet294:aHeader)
		If aColsVal[nAt][nPosTip] == "1"//Equipe
			lRet := ExistCpo("TP4",Trim(xValor))
		ElseIf aColsVal[nAt][nPosTip] == "2"//Atendente
			lRet := ExistCpo("ST1",Trim(xValor))
		ElseIf aColsVal[nAt][nPosTip] == "3"//Terceiros
			nPos := GDFIELDPOS("TUH_LOJATE", oGet294:aHeader)
			lRet := ExistCpo("SA2",Substr(xValor,1,nTamFor)+aColsVal[nAt][nPos])//Falta Loja
		Endif
		If lRet
			If aColsVal[nAt][nPosTip] != "3"
				nPos := GDFIELDPOS("TUH_LOJATE", oGet294:aHeader)
				aColsVal[nAt][nPos] := Space(TAMSX3("TUH_LOJATE")[1])
			Endif
			nPos := GDFIELDPOS("TUH_DESATE", oGet294:aHeader)
			aColsVal[nAt][nPos] := Space(TAMSX3("TUH_DESATE")[1])
		Endif
	ElseIf EMPTY("M->TUH_CCUSTO")
		Help(1," ",STR0010,,NGRETTITULO("TUH_CCUSTO"),3,0)//Mensagem de Help padrใo de campo obrigat๓rio
		lRet := .F.
	ElseIf cCampo == "M->TUH_CCUSTO"
		lRet := ExistCpo("CTT",xValor)
	Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMNT294WHENบAutor  ณRoger Rodrigues     บ Data ณ  08/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณWhen dos campos da tela                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA294                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNT294WHEN(cCampo)
	Local lRet := .T.
	Local nAt  := oGet294:nAt
	Local aColsVal := oGet294:aCols
	Local nPosTipo := GDFIELDPOS("TUH_TIPATE", oGet294:aHeader)
	Local nPosFil  := GDFIELDPOS("TUH_FILATE", oGet294:aHeader)

	cFilAnt := cFilOld

	If cCampo == "TUH_FILATE"
		If aColsVal[nAt][nPosTipo] != "1" .and. aColsVal[nAt][nPosTipo] != "2"
			lRet := .F.
		Endif
	ElseIf cCampo == "TUH_CODATE"
		aTrocaF3 := {}
		If MNT294WHEN("TUH_FILATE")
			cFilAnt  := aColsVal[nAt][nPosFil]
		Endif
		If aColsVal[nAt][nPosTipo] == "1" //Equipe
			aAdd(aTrocaF3,{"TUH_CODATE","TP4"})
		ElseIf aColsVal[nAt][nPosTipo] == "2"//Atendente
			aAdd(aTrocaF3,{"TUH_CODATE","ST1"})
		ElseIf aColsVal[nAt][nPosTipo] == "3"//Terceiros
			aAdd(aTrocaF3,{"TUH_CODATE","FOR"})
		EndIf
	Endif

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMNT294REL บAutor  ณRoger Rodrigues     บ Data ณ  08/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRelacao dos campos da tela                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA294                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNT294REL(cCampo)
	Local cRetorno := cFilAte := cValor := "", cTipo := "1"
	Local nAt, aColsVal
	Local nPosTipo, nPosFil, nPosLoj
	Local nTamFor  := If((TAMSX3("A2_COD")[1]) > 0,TAMSX3("A2_COD")[1], 6)

	If Type("oGet294") == "O"
		nAt  := oGet294:nAt
		aColsVal := oGet294:aCols
		nPosTipo := GDFIELDPOS("TUH_TIPATE", oGet294:aHeader)
		nPosFil  := GDFIELDPOS("TUH_FILATE", oGet294:aHeader)
		nPosLoj  := GDFIELDPOS("TUH_LOJATE", oGet294:aHeader)
	Endif

	If cCampo == "TUH_DESATE"
		If Type("M->TUH_CODATE") == "C"
			cTipo := aColsVal[nAt][nPosTipo]
			cValor := M->TUH_CODATE
			If cTipo == "3"//Terceiros
				cValor := Substr(cValor,1,nTamFor)+aColsVal[nAt][nPosLoj]
			Else
				cFilAnt:= aColsVal[nAt][nPosFil]
				cValor := Trim(cValor)
			Endif
		Else
			cTipo  := TUH->TUH_TIPATE
			cValor := TUH->TUH_CODATE
			If cTipo == "3"//Terceiros
				cValor := Substr(cValor,1,nTamFor)+TUH->TUH_LOJATE
			Else
				cFilAnt:= TUH->TUH_FILATE
				cValor := Trim(cValor)
			Endif
		Endif
		If cTipo == "1"//Equipe
			cRetorno := NGSEEK("TP4",cValor,1,"TP4->TP4_DESCRI")
		ElseIf cTipo == "2"//Atendente
			cRetorno := NGSEEK("ST1",cValor,1,"ST1->T1_NOME")
		ElseIf cTipo == "3"//Terceiro
			cRetorno := NGSEEK("SA2",cValor,1,"SA2->A2_NOME")
		Endif
		cFilAnt := cFilOld
	ElseIf cCampo == "TUH_DESCC"
		cRetorno := NGSEEK("CTT",TUH->TUH_CCUSTO,1,"CTT->CTT_DESC01")
	Endif

Return cRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfGrava    บAutor  ณRoger Rodrigues     บ Data ณ  14/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza gravacao das informacoes                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA294                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fGrava(nOpcx)
	Local i, j
	Local aColsGrv:= oGet294:aCols
	Local aHeadGrv:= oGet294:aHeader
	Local nPosTip := GDFIELDPOS("TUH_TIPATE",aHeadGrv)
	Local nPosFil := GDFIELDPOS("TUH_FILATE",aHeadGrv)
	Local nPosCod := GDFIELDPOS("TUH_CODATE",aHeadGrv)
	Local nPosLoj := GDFIELDPOS("TUH_LOJATE",aHeadGrv)
	Local nPosCC  := GDFIELDPOS("TUH_CCUSTO",aHeadGrv)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณManipula a tabela TUGณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("TUG")
	dbSetOrder(1)
	If dbSeek(xFilial("TUG")+M->TUG_CODFAM+M->TUG_CDSERV)
		RecLock("TUG",.F.)
	Else
		RecLock("TUG",.T.)
	Endif

	If nOpcx <> 5
		For i:=1 to FCount()
			If "_FILIAL"$FieldName(i)
				FieldPut(i, xFilial("TUG"))
			Else
				FieldPut(i, &("M->"+FieldName(i)))
			Endif
		Next i
	Else
		dbDelete()
	Endif
	MsUnlock("TUG")

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณManipula a tabela TUHณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("TUH")
	dbSetOrder(1)
	dbSeek(xFilial("TUH")+M->TUG_CODFAM+M->TUG_CDSERV)
	While !Eof() .and. xFilial("TUH")+M->TUG_CODFAM+M->TUG_CDSERV == TUH->TUH_FILIAL+TUH->TUH_CODFAM+TUH->TUH_CDSERV
		RecLock("TUH",.f.)
		dbDelete()
		MsUnLock("TUH")
		dbSelectArea("TUH")
		dbSkip()
	End
	If nOpcx != 5 .or. nOpcx != 2
		If Len(aColsGrv) > 0
			aSORT(aColsGrv,,, { |x, y| x[Len(aColsGrv[1])] .and. !y[Len(aColsGrv[1])] } )
		Endif
		For i:=1 to Len(aColsGrv)
			If !aColsGrv[i][Len(aColsGrv[i])] .and. !Empty(aColsGrv[i][nPosCod])
				dbSelectArea("TUH")
				dbSetOrder(1)
				If dbSeek(xFilial("TUH")+M->TUG_CODFAM+M->TUG_CDSERV+aColsGrv[i][nPosTip]+aColsGrv[i][nPosFil]+aColsGrv[i][nPosCod];
				+aColsGrv[i][nPosLoj]+aColsGrv[i][nPosCC])
					RecLock("TUH",.F.)
				Else
					RecLock("TUH",.T.)
				Endif
				For j:=1 to FCount()
					If "_FILIAL"$Upper(FieldName(j))
						FieldPut(j, xFilial("TUH"))
					ElseIf "_CODFAM"$Upper(FieldName(j))
						FieldPut(j, M->TUG_CODFAM)
					ElseIf "_CDSERV"$Upper(FieldName(j))
						FieldPut(j, M->TUG_CDSERV)
					ElseIf (nPos := GDFIELDPOS(FieldName(j), aHeadGrv) ) > 0
						FieldPut(j, aColsGrv[i][nPos])
					Endif
				Next j
				MsUnlock("TUH")
			Elseif !Empty(aColsGrv[i][nPosCod])
				dbSelectArea("TUH")
				dbSetOrder(1) //TUH_FILIAL,TUH_CODFAM,TUH_CDSERV,TUH_TIPATE,TUH_FILATE,TUH_CODATE,TUH_LOJATE,TUH_CCUSTO
				If dbSeek(xFilial("TUH")+M->TUG_CODFAM+M->TUG_CDSERV+aColsGrv[i][nPosTip]+aColsGrv[i][nPosFil]+aColsGrv[i][nPosCod];
				+aColsGrv[i][nPosLoj]+aColsGrv[i][nPosCC])
					RecLock("TUH",.F.)
					dbDelete()
					MsUnlock("TUH")
				Endif
			Endif
		Next i
	Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfLinOk    บAutor  ณRoger Rodrigues     บ Data ณ  14/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida linhas da getdados                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA294                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fLinOK(lFim)
	Local f
	Local nAt := oGet294:nAt
	Local aColsOk := oGet294:aCols
	Local aHeadOk := oGet294:aHeader
	Local nPosTip := GDFIELDPOS("TUH_TIPATE",aHeadOk)
	Local nPosFil := GDFIELDPOS("TUH_FILATE",aHeadOk)
	Local nPosCod := GDFIELDPOS("TUH_CODATE",aHeadOk)
	Local nPosLoj := GDFIELDPOS("TUH_LOJATE",aHeadOk)
	Local nPosCC  := GDFIELDPOS("TUH_CCUSTO",aHeadOk)
	Local lLinhas := .F.
	Default lFim := .F.

	If lFim
		For f:=1 to Len(aColsOk)
			If !aColsOk[f][Len(aColsOk[f])]
				lLinhas := .T.
				Exit
			Endif
		Next f
		If !lLinhas
			Help(1," ","OBRIGAT2",,aHeadOk[nPosTip][1],3,0)
			Return .F.
		Endif
	Endif

	//Percorre aCols
	For f:= 1 to Len(aColsOk)
		If !aColsOk[f][Len(aColsOk[f])]
			If lFim .or. f == nAt
				//VerIfica se os campos obrigat๓rios estใo preenchidos
				If Empty(aColsOk[f][nPosTip])
					//Mostra mensagem de Help
					Help(1," ","OBRIGAT2",,aHeadOk[nPosTip][1],3,0)
					Return .F.
				ElseIf aColsOk[f][nPosTip] != "3" .and. Empty(aColsOk[f][nPosFil])
					//Mostra mensagem de Help
					Help(1," ","OBRIGAT2",,aHeadOk[nPosFil][1],3,0)
					Return .F.
				ElseIf Empty(aColsOk[f][nPosCod])
					//Mostra mensagem de Help
					Help(1," ","OBRIGAT2",,aHeadOk[nPosCod][1],3,0)
					Return .F.
				ElseIf Empty(aColsOk[f][nPosCC])
					//Mostra mensagem de Help
					ShowHelpDlg("ATENCAO",{STR0010},1,{"Favor, preencher o campo Centro Custo."},2)
					Return .F.
				Endif
			ElseIf aColsOk[f][nPosTip] == "3" .and. Empty(aColsOk[f][nPosLoj])
				//Mostra mensagem de Help
				Help(1," ","OBRIGAT2",,aHeadOk[nPosLoj][1],3,0)
				Return .F.
			Endif
			//Verifica se ้ somente LinhaOk
			If f <> nAt .and. !aColsOk[nAt][Len(aColsOk[nAt])]
				If aColsOk[f][nPosTip]+aColsOk[f][nPosFil]+aColsOk[f][nPosCod]+aColsOk[f][nPosLoj]+aColsOk[f][nPosCod]+aColsOk[f][nPosCC] == ;
				aColsOk[nAt][nPosTip]+aColsOk[nAt][nPosFil]+aColsOk[nAt][nPosCod]+aColsOk[nAt][nPosLoj]+aColsOk[nAt][nPosCod]+aColsOk[nAT][nPosCC]
					Help(" ",1,"JAEXISTINF",,aHeadOk[nPosTip][1]+aHeadOk[nPosFil][1]+aHeadOk[nPosCod][1]+aHeadOk[nPosLoj][1]+aHeadOk[nPosCod][1]+aHeadOk[nPosCC][1])
					Return .F.
				Endif
			Endif
		Endif
	Next f

	PutFileInEof("TUH")

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfTudoOk   บAutor  ณRoger Rodrigues     บ Data ณ  14/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza validacao geral da rotina                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA294                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fTudoOk(nOpcx)

	If nOpcx !=2 .and. nOpcx != 5
		If !Obrigatorio(aGets,aTela)
			Return .F.
		Endif
		If nOpcx == 3
			If !ExistChav("TUG",M->TUG_CODFAM+M->TUG_CDSERV)
				Return .F.
			Endif
		Endif
		If !fLinOk(.T.)
			Return .F.
		Endif
	Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfMarkCC   บAutor  ณRoger Rodrigues     บ Data ณ  14/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPermite a marcacao dos centros de custo                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA294                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fMarkCC()
	Local i, nSituac := 1, nOpt := 0, nLinha := 0
	Local lMarcado := .F.

	//Variaveis da GetDados
	Local nAt := oGet294:nAt
	Local nNewNat
	Local aColsTmp:= {}
	Local aColsOk := oGet294:aCols
	Local aHeadOk := oGet294:aHeader
	Local aLinha  := oGet294:aCols[nAt]
	Local nPosTip := GDFIELDPOS("TUH_TIPATE",aHeadOk)
	Local nPosFil := GDFIELDPOS("TUH_FILATE",aHeadOk)
	Local nPosCod := GDFIELDPOS("TUH_CODATE",aHeadOk)
	Local nPosLoj := GDFIELDPOS("TUH_LOJATE",aHeadOk)
	Local nPosCC  := GDFIELDPOS("TUH_CCUSTO",aHeadOk)
	Local nPosDes := GDFIELDPOS("TUH_DESCC",aHeadOk)

	//Objetos da tela
	Local oFont, oPanel, oDlgMrk, oMarkRel

	//Variaveis do markbrowse
	Local aDBFMRK := {}, aFieldsMRK := {}//Array com campos do TRB

	//Variaveis do TRB
	Private oTmpMrk
	Private cAliasMrk := GetNextAlias()

	dbSelectArea("CTT")

	If !fLinOk() .or. aLinha[Len(aLinha)]
		Return .F.
	Endif

	//Define campos do arquivo temporario
	aADD(aDBFMRK,{"OK"		,"C",2	,0	})
	aADD(aDBFMRK,{"CODIGO"	,"C",TAMSX3("CTT_CUSTO")[1]	,TAMSX3("CTT_CUSTO")[2]	})
	aADD(aDBFMRK,{"DESCRI" 	,"C",TAMSX3("CTT_DESC01")[1]	,TAMSX3("CTT_DESC01")[2]	})

	aADD(aFieldsMRK, {"OK", Nil,"", "" })
	aADD(aFieldsMRK, {"CODIGO"	,Nil,RetTitle("CTT_CUSTO")	, PesqPict("CTT", "CTT_CUSTO")	})
	aADD(aFieldsMRK, {"DESCRI"	,Nil,RetTitle("CTT_DESC01"), PesqPict("CTT", "CTT_DESC01")	})

	//Cria Arquivo temporario
	oTmpMrk := FWTemporaryTable():New(cAliasMrk, aDBFMRK)
	oTmpMrk:AddIndex( "Ind01" , {"OK"} )
	oTmpMrk:AddIndex( "Ind02" , {"CODIGO"} )
	oTmpMrk:Create()

	//Carrega Arquivo Temporario
	dbSelectArea("CTT")
	dbSetOrder(1)
	dbSeek(xFilial("CTT"))
	While !eof() .and. xFilial("CTT") == CTT->CTT_FILIAL
		lMarcado := .F.
		//Verifica se deve marcar
		If aScan(aColsOk, {|x| x[nPosTip]+x[nPosFil]+x[nPosCod]+x[nPosLoj]+x[nPosCC] == aLinha[nPosTip]+aLinha[nPosFil]+aLinha[nPosCod];
		+aLinha[nPosLoj]+CTT->CTT_CUSTO .and. !x[Len(aLinha)] }) > 0
			lMarcado := .T.
		EndIf
		RecLock(cAliasMrk,.T.)
		(cAliasMrk)->OK     := If(lMarcado, cMarca, Space(2))
		(cAliasMrk)->CODIGO := CTT->CTT_CUSTO
		(cAliasMrk)->DESCRI := CTT->CTT_DESC01
		MsUnlock(cAliasMrk)
		dbSelectarea("CTT")
		dbSkip()
	End
	dbSelectArea(cAliasMrk)
	dbSetOrder(2)
	dbGoTop()

	Define FONT oFont NAME "Arial" SIZE 0,-12
	Define MsDialog oDlgMrk Title cCadastro From 08,15 To 42,87 Of oMainWnd

	oPanel := TPanel():New(0,0,,oDlgMrk,,,,,,600,600,.F.,.F.)
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT

	@4,5 TO 30,280 OF oPanel Pixel
	@08,10 SAY STR0008 SIZE 200,10 of oPanel PIXEL FONT oFont //"Estes sใo os centros de custo cadastrados no sistema."
	@18,10 SAY STR0009 SIZE 200,10 of oPanel Pixel FONT oFont //"Selecione o que deseja relacionar ao atendente."

	oMarkRel := MsSelect():NEW(cAliasMrk,"OK",,aFieldsMRK,@lINVERTE,@cMARCA,{35,5,244,281},,,oPanel)
	oMarkRel:oBrowse:lHasMark := .T.
	oMarkRel:oBrowse:lCanAllMark := .T.
	oMarkRel:oBrowse:bAllMark := { || fMrkAll(oMarkRel)}

	Activate MsDialog oDlgMrk On Init EnchoiceBar(oDlgMrk,{|| nOpt := 1,oDlgMrk:End()},{|| nOpt := 0,oDlgMrk:End()}) Centered

	//Se confirmar monta aCols
	If nOpt == 1
		//Verifica situacao 0=Nenhum;1=Alguns;2=Todos
		dbSelectArea(cAliasMrk)
		dbSetOrder(1)
		If !dbSeek(Space(2))
			nSituac := 2
		ElseIf !dbSeek(cMarca)
			nSituac := 0
		Endif
		aColsTmp := {}
		//Deleta linhas semelhantes
		For i:=1 to Len(aColsOk)
			If aColsOk[i][nPosTip]+aColsOk[i][nPosFil]+aColsOk[i][nPosCod]+aColsOk[i][nPosLoj] != ;
			aLinha[nPosTip]+aLinha[nPosFil]+aLinha[nPosCod]+aLinha[nPosLoj] .or. (nSituac == 2 .and. nAt == i)
				aAdd(aColsTmp, aColsOk[i])
				If nSituac == 2 .and. nAt == i
					nNewNat := Len(aColsTmp)
				Endif
			Endif
		Next i
		If nSituac == 2
			aColsTmp[nNewNAt][nPosCC] := Space(TAMSX3("TUH_CCUSTO")[1])
			aColsTmp[nNewNAt][nPosDes]:= Space(TAMSX3("TUH_DESCC")[1])
		ElseIf nSituac == 1
			dbSelectArea(cAliasMrk)
			dbSetOrder(2)
			dbGoTop()
			While !eof()
				If !Empty((cAliasMrk)->OK)
					aAdd(aColsTmp, BlankGetD(aHeadOk)[1])
					If nLinha == 0
						nLinha := Len(aColsTmp)
					Endif
					For i:=1 to Len(aHeadOk)
						If aHeadOk[i][2] $ "TUH_TIPATE/TUH_FILATE/TUH_CODATE/TUH_LOJATE/TUH_DESATE"
							aColsTmp[Len(aColsTmp)][i] := aLinha[i]
						ElseIf Trim(aHeadOk[i][2]) == "TUH_CCUSTO"
							aColsTmp[Len(aColsTmp)][i] := (cAliasMrk)->CODIGO
						Elseif Trim(aHeadOk[i][2]) == "TUH_DESCC"
							aColsTmp[Len(aColsTmp)][i] := (cAliasMrk)->DESCRI
						Endif
					Next i
				Endif
				dbSelectArea(cAliasMrk)
				dbSkip()
			End
			If nLinha > 0
				nAt := nLinha
			Endif
		Else
			If nAt > 1
				nAt := nAt-1
			Endif
		Endif
		//Se o aCols estiver sem registros
		If Len(aColsTmp) == 0
			aColsTmp := BlankGetd(aHeadOk)
		Endif
		oGet294:aCols := aColsTmp
		oGet294:nAt   := nAt
		oGet294:oBrowse:nAt   := nAt
		aCols := aColsTmp//Variavel atualizada, pois MsNewGetDados ainda utiliza a mesma
		n := nAt//Variavel atualizada, pois MsNewGetDados ainda utiliza a mesma
		oGet294:oBrowse:SetFocus()
		oGet294:oBrowse:Refresh()
	Endif

	//Deleta Arquivo temporario
	oTmpMrk:Delete()

Return .F.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfMrkAll   บAutor  ณRoger Rodrigues     บ Data ณ  15/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMarca itens do Markbrowse                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMNTA294                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fMrkAll(oMarkRel)
	Local lMarca:= .F.

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
	dbSetOrder(2)
	dbGoTop()
	While !eof()
		RecLock(cAliasMrk,.F.)
		(cAliasMrk)->OK := If(lMarca, cMarca, Space(2))
		MsUnlock(cAliasMrk)
		dbSelectArea(cAliasMrk)
		dbSkip()
	End

	//Atualiza MarkBrowse
	dbSelectArea(cAliasMrk)
	dbSetOrder(2)
	dbGoTop()
	oMarkRel:oBrowse:Refresh(.T.)

Return .T.
