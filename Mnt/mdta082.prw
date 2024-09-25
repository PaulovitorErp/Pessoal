#include "MDTA082.ch"
#include "Protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MDTA082  ³ Autor ³ Denis Hyroshi de Souza³ Data ³ 09/02/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Cadastro de CID x CNAE                          ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDTA082()

	//Guarda conteudo e declara variaveis padroes

	Local aNGBEGINPRM := NGBEGINPRM( )

	Private aRotina := MenuDef()
	//Define o cabecalho da tela de atualizacoes
	Private cPrograma := "MDTA082"
	Private cCadastro := OemtoAnsi(STR0001) //"Intervalo CID x CNAE"
	Private aCHKDEL := {}, bNGGRAVA

	If !NGCADICBASE("TK9_CIDINI","D","TK9",.F.)
		If !NGINCOMPDIC("UPDMDT14","00000022621/2010")
			Return .F.
		Endif
	Endif

	If !AliasInDic('TYH')
		MsgStop( STR0028 ) //"O dicionário de dados está desatualizado, favor aplicar a atualização contida no pacote da issue DNG-1847	"
	Else
		//Endereca a funcao de BROWSE
		DbSelectArea("TK9")
		DbSetOrder(1)
		mBrowse( 6, 1,22,75,"TK9")
	EndIf

	//
	//Retorna conteudo de variaveis padroes
	NGRETURNPRM(aNGBEGINPRM)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MDT82CAD ³ Autor ³ Denis Hyroshi de Souza³ Data ³ 09/02/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tela de cadastro                                            ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDT82CAD(cAlias,nRecno,nOpcx)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Carregando variaveis de controle da tela
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	Private nOpcxFP := nOpcx
	Private aAC := {STR0002,STR0003},aCRA:= {STR0003,STR0004,STR0002} //"Abandona"###"Confirma"###"Confirma"###"Redigita"###"Abandona"
	Private aTELA[0][0],aGETS[0],Continua,nUsado:=0
	Private aSize := MsAdvSize(,.f.,430), aObjects := {}
	Aadd(aObjects,{050,050,.t.,.t.})
	Aadd(aObjects,{100,100,.t.,.f.})
	Aadd(aObjects,{100,100,.t.,.f.})
	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObjects,.t.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Carregando variaveis dos objetos da tela
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	Private oFont14  := TFont():New("Arial",,-14,.T.,.T.)
	Private oChecked := LoadBitmap(GetResources(),'LBTIK')
	Private oUnCheck := LoadBitmap(GetResources(),'LBNO')
	Private aCoBrwB  := {}
	Private aHoBrwB  := {}
	Private lIndCnae := .F.
	Private lAltProg := .t.
	Private oBrwB,oMenu

	dbSelectArea("TK9")
	RegToMemory("TK9",(nOpcxFP == 3))

	aBlankTKA := fHeadTKA( nOpcx )

	If nOpcxFP != 3
		If nOpcxFP == 2 .or. nOpcxFP == 5
			lAltProg := .f.
		Endif
		If TK9->TK9_MARCA == "1"
			lIndCnae := .T.
		Endif
	Endif

	nOpca := 0

	If nOpcxFP == 3 .or. nOpcxFP == 4
		SetKey(VK_F12,{|| MDT082MRK() })
	Endif

	cTitTela := cCadastro
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(cTitTela) From aSize[7],0 To aSize[6],aSize[5] COLOR CLR_BLACK,CLR_WHITE OF oMainWnd PIXEL

		oPnlPai := TPanel():New(0, 0, , oDlg, , .T., .F., , , 0, 0, .T., .F. )
		oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

		oDlg:LESCCLOSE := .f.

		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		//±±  Enchoice (TK9)                          ±±
		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		oEnchoice := MsMGet():New("TK9",nRecno,nOpcx,,,,,{13,0,80,aPosObj[1,4]},,,,,,oPnlPai,,,.f.)
		oEnchoice:oBox:Align := CONTROL_ALIGN_TOP
		NGPOPUP(asMenu,@oMenu)
		oDlg:bRClicked:= { |o,x,y| oMenu:Activate(x,y,oDlg)}

		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		//±±  Panel Botao Selecionar Cnae             ±±
		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		oPanelTit:=TPanel():New(00,00,,oPnlPai,,,,,RGB(255,255,255),12,12,.F.,.F.)
		oPanelTit:Align := CONTROL_ALIGN_TOP
		oPanelTit:nHeight := 35
		@003,3 Button oGerCons PROMPT STR0006 OF oPanelTit SIZE 50,12 PIXEL ACTION fIncCnae() When lAltProg //"Pesquisar CNAE"

		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		//±±  GetDados (TKA)                          ±±
		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		dbSelectArea("TKA")
		oBrwB   := MsNewGetDados():New(82,1,245,aPosObj[1,4],IIF(!lAltProg,0,GD_INSERT+GD_UPDATE+GD_DELETE),;
									{|| Mdt082lOk()},{|| .T. },,,,9999,,,,oPnlPai,aHoBrwB,aCoBrwB)
		oBrwB:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oBrwB:oBrowse:Default()
		oBrwB:oBrowse:Refresh()

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,If( !obrigatorio(aGets,aTela) .or. !fChk082(nRecno),nOpca := 0,oDlg:End())},{||oDlg:End()}) CENTERED

	SetKey(VK_F12,{||Nil})

	If nOpcxFP != 2
		If nOpca == 0 .and. nOpcxFP == 3
			RollBackSX8()
		ElseIf nOpca == 1
			fGrava082()
		Endif
	Endif

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³fGrava082 ³ Autor ³Denis Hyroshi de Souza ³ Data ³ 25/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Gravacao dos dados das tabelas TK9 e TKA                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function fGrava082()

	Local nFor,i

	If nOpcxFP == 5

		dbSelectArea("TK9")
		dbSetOrder(1)
		If dbSeek(xFilial("TK9")+M->TK9_INTERV)
			RecLock("TK9",.f.)
			dbDelete()
			TK9->(MsUnLock())
		Endif

		dbSelectArea("TKA")
		dbSetOrder(1)
		dbSeek(xFilial("TKA")+M->TK9_INTERV)
		While !Eof() .and. xFilial("TKA")+M->TK9_INTERV == TKA->TKA_FILIAL+TKA->TKA_INTERV
			RecLock("TKA",.f.)
			dbDelete()
			TKA->(MsUnLock())
			dbSkip()
		End

	ElseIf nOpcxFP == 3 .or. nOpcxFP == 4

		If nOpcxFP == 3
			dbSelectArea("TK9")
			RecLock("TK9",.t.)
		Else
			dbSelectArea("TK9")
			dbSetOrder(1)
			dbSeek(xFilial("TK9")+M->TK9_INTERV)
			RecLock("TK9",.f.)
		Endif
		For nFor := 1 To FCOUNT()
			If Alltrim(FieldName(nFor)) <> "TK9_FILIAL" .and. Alltrim(FieldName(nFor)) <> "TK9_INTERV" .and. Alltrim(FieldName(nFor)) <> "TK9_MARCA"
				nCmpo := "M->" + FieldName(nFor)
				FieldPut(nFor, &nCmpo.)
			Endif
		Next nFor
		TK9->TK9_FILIAL := xFilial("TK9")
		TK9->TK9_INTERV := M->TK9_INTERV
		TK9->TK9_MARCA  := If(lIndCnae,"1","2")
		TK9->(MsUnLock())

		If nOpcxFP == 3
			ConfirmSX8()
		Endif

		For nFor := 1 To Len(aCoBrwB)
			If !Empty(aCoBrwB[nFor][1]) .and. !aCoBrwB[nFor][Len(aCoBrwB[nFor])]
				dbSelectArea("TKA")
				dbSetOrder(1)
				If dbSeek(xFilial("TKA")+M->TK9_INTERV+aCoBrwB[nFor][1])
					RecLock("TKA",.F.)
				Else
					RecLock("TKA",.T.)
				Endif
				TKA->TKA_FILIAL := xFilial("TKA")
				TKA->TKA_CNAE   := aCoBrwB[nFor][1]
				TKA->TKA_INTERV := M->TK9_INTERV
				dbSelectArea("TKA")
				dbSetOrder(1)
				For i := 1 To FCount()
					nPosCol := aScan(aHoBrwB, {|x| AllTrim(Upper(X[2])) == Alltrim(FieldName(i)) })
					If Alltrim(FieldName(i)) $ "TKA_FILIAL/TKA_CNAE/TKA_ATIVID" .or. nPosCol == 0
						Loop
					EndIf
					x  := "m->" + FieldName(i)
					&x.:= aCoBrwB[nFor][nPosCol]
					y  := "TKA->" + FieldName(i)
					&y := &x
				Next i
				TKA->(MsUnLock())
			Endif
		Next nFor

		If nOpcxFP == 4
			dbSelectArea("TKA")
			dbSetOrder(1)
			dbSeek(xFilial("TKA")+M->TK9_INTERV)
			While !Eof() .and. xFilial("TKA")+M->TK9_INTERV == TKA->TKA_FILIAL+TKA->TKA_INTERV
				If aSCAN(aCoBrwB,{|x| x[1] == TKA->TKA_CNAE .and. !x[Len(x)] }) == 0
					RecLock("TKA",.f.)
					dbDelete()
					TKA->(MsUnLock())
				Endif
				dbSkip()
			End
		Endif
	Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MenuDef  ³ Autor ³ Denis Hyroshi de Souza³ Data ³07/02/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Utilizacao de Menu Funcional.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaMDT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados         ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ F.O  ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

	Local aRotina :=	{ { STR0007, 	"AxPesqui"  , 0 , 1},; //"Pesquisar"
						{ STR0008,	"MDT82CAD"   , 0 , 2},; //"Visualizar"
						{ STR0009,   "MDT82CAD"   , 0 , 3},; //"Incluir"
						{ STR0010,   "MDT82CAD"   , 0 , 4},; //"Alterar"
						{ STR0011,   "MDT82CAD" , 0 , 5, 3} } //"Excluir"

Return aRotina

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fHeadTKA ³ Autor ³ Denis Hyroshi de Souza³ Data ³ 09/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega aHeader da tabela TKA                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fHeadTKA( nOpcx )

	Local nX
	Local nCps    := 0
	Local aCampos := { "TKA_CNAE" , "TKA_ATIVID", "TKA_INTERV" }
	Local aTamCpo := {}
	Local cUsado  := ''
	Local cNivCpo := ''
	Local nInd    := 1//TKA_FILIAL+TKA_INTERV+TKA_CNAE
	Local cSeek   := M->TK9_INTERV
	Local cCond   := 'TKA_FILIAL+TKA_INTERV == "' + xFilial("TKA") + M->TK9_INTERV + '"'

	aHoBrwB := {}

	//Monta o aCols e o aHeader
	FillGetDados( nOpcx, 'TKA', nInd, cSeek, {||}, {||.T.}, , , , , { | | NGMontaaCols( "TKA", cSeek, cCond, , nInd ) }, nOpcx == 3 )

	aHoBrwB := aClone( aHeader )

	aCoBrwB := aClone( aCols )

Return aClone( BlankGetD(aHoBrwB)[1] )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fIncCnae ³ Autor ³ Denis Hyroshi de Souza³ Data ³ 09/02/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Manipular lista de Atividades                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fIncCnae()

	Local aArea := GetArea()
	Local aColsTmp := aClone(oBrwB:aCols)
	Local cBuscaEx := Space(40)
	Local lRet := .f.
	Local nXX, nXXX

	Private oAtiCnae, aAtiCnae, bAtiCnae

	aAtiCnae := {}

	dbSelectArea("TOE")
	dbSetOrder(1)
	dbSeek(xFilial("TOE"))
	While !eof() .and. xFilial("TOE") == TOE->TOE_FILIAL
		aAdd( aAtiCnae , { .f. , TOE->TOE_CNAE , TOE->TOE_DESCRI , TOE->TOE_GRISCO } )
		dbSkip()
	End

	aSORT(aAtiCnae,,,{|x,y| x[2] < y[2] })

	If Len(aAtiCnae) == 0
		MsgInfo(STR0012,STR0013) //"Não existe Atividade (CNAE) cadastrada."###"Atenção"
		Return .f.
	Endif

	For nXX := 1 To Len(oBrwB:aCols)
		If oBrwB:aCols[ nXX , Len(oBrwB:aCols[nXX]) ]
			Loop
		Endif
		nPosCols := aSCAN(aAtiCnae,{|x| x[2] == oBrwB:aCols[nXX,1] })
		If nPosCols > 0
			aAtiCnae[nPosCols,1] := .t.
		Endif
	Next nXX

	opcaoZZ  := 0
	aDosiInd := {'1=CNAE','2=Descrição','3=Grau Risco'}
	cIndDosi := Substr(aDosiInd[1],1,1)

	DEFINE MSDIALOG oDlg1 TITLE OemToAnsi(STR0014) from 0,0 To 35,77 of oMainwnd //"Atividades (CNAE) do Intervalo CID"

		@ 3,3 SCROLLBOX oScr1 SIZE 259,298 OF oDlg1 BORDER

		@ 05,3  SAY STR0015 OF oScr1 Pixel //"Selecione as atividades (CNAE)"

		@ 16,003 SAY OemToAnsi(STR0016) Of oScr1 Pixel //"Ordenar Por"
		@ 16,040 COMBOBOX oCbx1 VAR cIndDosi ITEMS aDosiInd Valid fDosOrder(cIndDosi,.t.) SIZE 50,60 Of oScr1 Pixel

		@ 16,105 Say OemToAnsi(STR0007) Of oScr1 Pixel //"Pesquisar"
		@ 16,135 MsGet cBuscaEx Picture '@!' Valid fDosPesqu(Alltrim(cBuscaEx),cIndDosi) Size 115,5 Of oScr1 Pixel

		@ 27,3 Checkbox oCheck01 Var lIndCnae Prompt ;
		STR0017 Size 290,7 OF oScr1 When lAltProg //"Selecionar automaticamente os outros códigos CNAE da mesma classe (quatro dígitos iniciais em comum)?"

		oAtiCnae := VCBrowse():New( 039 , 4, 290, 197,,{' ','CNAE','Descrição','Grau Risco'},{10,30,120,30},;
									oScr1,,,,,{||},,,,,,,.F.,,.T.,,.F.,,.t.,.t.)
		oAtiCnae:SetArray(aAtiCnae)
		bAtiCnae := { || { If(aAtiCnae[oAtiCnae:nAt,1],oChecked,oUnCheck), aAtiCnae[oAtiCnae:nAt,2], aAtiCnae[oAtiCnae:nAt,3],;
							aAtiCnae[oAtiCnae:nAt,4] } }
		oAtiCnae:bLine:= bAtiCnae
		If lAltProg
			oAtiCnae:bLDblClick := {|| fMarkCnae() , oAtiCnae:DrawSelect() }
		Endif
		oAtiCnae:nAt := 1

		DEFINE SBUTTON FROM 242,225 TYPE 1 ENABLE OF oScr1 ACTION (opcaoZZ := 1,oDlg1:End())
		DEFINE SBUTTON FROM 242,255 TYPE 2 ENABLE OF oScr1 ACTION oDlg1:END()

	ACTIVATE MSDIALOG oDlg1 CENTERED

	If opcaoZZ == 1
		oBrwB:aCols := {}
		For nXXX := 1 To Len(aAtiCnae)
			If aAtiCnae[nXXX,1]
				nPosCols := aSCAN(aColsTmp,{|x| x[1] == aAtiCnae[nXXX,2] .and. !x[Len(x)] })
				If nPosCols > 0
					aAdd( oBrwB:aCols , aClone(aColsTmp[nPosCols]) )
				Else
					aAdd( oBrwB:aCols , aClone(aBlankTKA) )
					oBrwB:aCols[ Len(oBrwB:aCols) , 1 ] := aAtiCnae[nXXX,2]
					oBrwB:aCols[ Len(oBrwB:aCols) , 2 ] := aAtiCnae[nXXX,3]
				Endif
			Endif
		Next nXXX

		If Len(oBrwB:aCols) == 0
			aAdd( oBrwB:aCols , aClone(aBlankTKA) )
			oBrwB:LMODIFIED := .F.
		Else
			oBrwB:LMODIFIED := .T.
		Endif

		aSORT(oBrwB:aCols,,,{|x,y| x[1] < y[1] })
		n := 1
		oBrwB:nAt := 1
		oBrwB:lNewLine := .F.
		oBrwB:oBrowse:Refresh()
	Endif

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³fMarkCnae ³ Autor ³Denis Hyroshi de Souza ³ Data ³ 25/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Funcao para marcar/desmarcar opcao selecionada             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function fMarkCnae()

	Local nPos := oAtiCnae:nAt, lTemp, nFor, cClasse

	aAtiCnae[oAtiCnae:nAt,1] := !aAtiCnae[oAtiCnae:nAt,1]

	If lIndCnae
		lTemp   := aAtiCnae[oAtiCnae:nAt,1]
		cClasse := Substr(aAtiCnae[oAtiCnae:nAt,2],1,4)
		aSORT(aAtiCnae,,,{|x,y| x[2] < y[2] })
		nPosCol := aScan(aAtiCnae, {|x| Substr(x[2],1,4) == cClasse })
		If nPosCol > 0
			For nFor := nPosCol To Len(aAtiCnae)
				If Substr(aAtiCnae[nFor,2],1,4) != cClasse
					Exit
				Endif
				aAtiCnae[nFor,1] := lTemp
			Next nFor
		Endif
		fDosOrder(cIndDosi,.t.)
		oAtiCnae:nAt := nPos
	Endif

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³fDosOrder ³ Autor ³Denis Hyroshi de Souza ³ Data ³ 25/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Ordena lista de funcionarioas                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function fDosOrder(cIndDosi,lAtualiza)

	If Val(cIndDosi) > 0 .and. Val(cIndDosi) < 4
		aSORT(aAtiCnae,,,{|x,y| x[Val(cIndDosi)+1] < y[Val(cIndDosi)+1] })
		If lAtualiza
			oAtiCnae:Refresh()
		Endif
	Endif

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³fDosPesqu ³ Autor ³Denis Hyroshi de Souza ³ Data ³ 25/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Pesquisar lista de funcionarioas                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function fDosPesqu(cBuscaEx,cIndDosi)

	Local nTam := Len(cBuscaEx),nPos, nFor
	Local lNaoTem := .t.

	If Val(cIndDosi) > 0 .and. Val(cIndDosi) < 4
		nPos := aSCAN(aAtiCnae,{|x| Substr( x[Val(cIndDosi)+1] , 1 , nTam ) == cBuscaEx })
		If nPos > 0
			oAtiCnae:nAt := nPos
			oAtiCnae:Refresh()
		Else
			MsgInfo(STR0018,STR0013) //"Não foi possível localizar esta informação."###"Atenção"
		Endif
	ElseIf Val(cIndDosi) == 4
		For nFor := 1 to 3
			nPos := aSCAN(aAtiCnae,{|x| Substr( x[nFor+1] , 1 , nTam ) == cBuscaEx })
			If nPos > 0
				oAtiCnae:nAt := nPos
				oAtiCnae:Refresh()
				lNaoTem := .f.
				Exit
			Endif
		Next nFor
		If lNaoTem
			MsgInfo(STR0018,STR0013) //"Não foi possível localizar esta informação."###"Atenção"
		Endif
	Endif

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³Mdt82VCnae³ Autor ³Denis Hyroshi de Souza ³ Data ³ 25/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Validacao do codigo do CNAE                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function Mdt82VCnae(nTipo)

	dbSelectArea("TOE")
	dbSetOrder(1)
	If !dbSeek(xFilial("TOE")+M->TKA_CNAE)
		Help(" ",1,"REGNOIS")
		Return .f.
	Endif
	//oBrwB:aCols[ oBrwB:nAt , 2 ] := TOE->TOE_DESCRI

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ Mdt82VCid³ Autor ³Denis Hyroshi de Souza ³ Data ³ 25/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Validacao do codigo do CID                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function Mdt82VCid(nTipo)

	If nTipo == 1

		dbSelectArea("TMR")
		dbSetOrder(1)
		If !dbSeek(xFilial("TMR")+M->TK9_CIDINI)
			Help(" ",1,"REGNOIS")
			Return .f.
		Endif
		M->TK9_DESINI := TMR->TMR_DOENCA

		If M->TK9_CIDINI > M->TK9_CIDFIM .and. !Empty(M->TK9_CIDFIM)
			M->TK9_CIDFIM := M->TK9_CIDINI
			M->TK9_DESFIM := M->TK9_DESINI
		Endif

	ElseIf nTipo == 2

		If M->TK9_CIDFIM < M->TK9_CIDINI
			Help(" ",1,"DEATEINVAL")
			Return .f.
		Endif
		dbSelectArea("TMR")
		dbSetOrder(1)
		If !dbSeek(xFilial("TMR")+M->TK9_CIDFIM)
			Help(" ",1,"REGNOIS")
			Return .f.
		Endif
		M->TK9_DESFIM := TMR->TMR_DOENCA

	Endif

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ fChk082  ³ Autor ³Denis Hyroshi de Souza ³ Data ³ 25/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Validacao da tela do intervalo CID                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function fChk082(nRecnoTmp)

	Local cDuplic := ""
	Local cAlias  := Alias()
	Local aArea   := TK9->(GetArea())

	If nOpcxFP == 3 .or. nOpcxFP == 4

		If !Mdt082lOk(.T.)
			Return .f.
		Endif

		dbSelectArea("TK9")
		dbSetOrder(1)
		dbSeek(xFilial("TK9"))
		While !Eof() .and. xFilial("TK9") == TK9->TK9_FILIAL
			If nOpcxFP == 4 .and. nRecnoTmp == TK9->(Recno())
				dbSelectArea("TK9")
				dbSkip()
				Loop
			Endif
			If TK9->TK9_CIDINI <= M->TK9_CIDFIM .and. TK9->TK9_CIDFIM >= M->TK9_CIDINI
				cDuplic := STR0019 + " " + STR0020 + " " + ; //"Este Intervalo não poderá ser cadastrado, pois houve conflito com outro Intervalo:"###"CID"
							Alltrim(TK9->TK9_CIDINI) + " " + STR0021 + " " + Alltrim(TK9->TK9_CIDFIM) + "." //"até"
				MsgInfo(cDuplic)

				RestArea(aArea)
				dbSelectArea(cAlias)
				Return .f.
			Endif
			dbSelectArea("TK9")
			dbSkip()
		End
	Endif

	aCoBrwB := aClone(oBrwB:aCols)

	RestArea(aArea)
	dbSelectArea(cAlias)

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³Mdt082lOk ³ Autor ³Denis Hyroshi de Souza ³ Data ³ 25/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Valida linha                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function Mdt082lOk( lAllOk )

	Local nFor
	Local lTem := .f.
	Local nPosCnae

	Default lAllOk := .F.

	nPosCnae := aScan( oBrwB:aHeader,{|x| Trim(Upper(x[2])) == "TKA_CNAE"})

	If oBrwB:aCols[ oBrwB:nAt , Len(oBrwB:aCols[ oBrwB:nAt ])  ]
		Return .t.
	Endif

	If !lAllOk .And. Empty(oBrwB:aCols[ oBrwB:nAt , nPosCnae ])
		Help(" ",1,"NVAZIO")
		Return .f.
	EndIf

	For nFor := 1 To Len(oBrwB:aCols)
		If !oBrwB:aCols[ nFor , Len(oBrwB:aCols[ nFor ]) ] .and. nFor <> oBrwB:nAt
			If oBrwB:aCols[ nFor , 1 ] == oBrwB:aCols[ oBrwB:nAt , 1 ]
				lTem := .t.
				Exit
			Endif
		Endif
	Next nFor

	If lTem
		Help(" ",1,"JAEXISTINF")
		Return .f.
	Endif

	PutFileInEOF('TKA')

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MDT82NEXO ³ Autor ³ Denis Hyroshi de Souza³ Data ³ 09/02/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica o Nexo Causal entre o CID e o CNAE                 ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDT82NEXO( cCodCid , cCodCnae , nMsg )

	Local lRet    := .f.
	Local cCodInt := ""
	Local cAlias  := Alias()
	Local cTexto  := ""

	Default nMsg := 0

	If Empty(cCodCid) .or. Empty(cCodCnae)
		Return .f.
	Endif

	dbSelectArea("TK9")
	dbSetOrder(2)
	dbSeek( xFilial("TK9") + cCodCid , .t.)
	If !Eof() .and. xFilial("TK9") == TK9->TK9_FILIAL .and. cCodCid == TK9->TK9_CIDINI
		cCodInt := TK9->TK9_INTERV
	Else
		dbSkip(-1)
		If !Eof() .and. xFilial("TK9") == TK9->TK9_FILIAL .and. cCodCid >= TK9->TK9_CIDINI .and. cCodCid <= TK9->TK9_CIDFIM
			cCodInt := TK9->TK9_INTERV
		Endif
	Endif

	If !Empty(cCodInt)
		dbSelectArea("TKA")
		dbSetOrder(1)
		If dbSeek( xFilial("TKA") + cCodInt + cCodCnae)
			lRet := .t.
			cTexto := STR0022 + " " //"A origem deste afastamento aponta a existência de relação entre o CID (doença) e o CNAE (atividade da empresa),"
			cTexto += STR0023 //"influenciando no Nexo Técnico Epidemiológico Previdenciário (NTEP)."
			dbSelectArea("TMR")
			dbSetOrder(1)
			dbSeek(xFilial("TMR")+cCodCid)
			dbSelectArea("TOE")
			dbSetOrder(1)
			dbSeek(xFilial("TOE")+cCodCnae)
			cTexto += Chr(13) + STR0020 + ": " + Alltrim(cCodCid) + " - " + Alltrim(TMR->TMR_DOENCA) //"CID"
			cTexto += Chr(13) + STR0024 + ": " + Alltrim(cCodCnae) + " - " + Alltrim(TOE->TOE_DESCRI) //"CNAE"
			If nMsg == 1
				MsgInfo(cTexto)
			ElseIf nMsg == 2
				If MsgYesNo(cTexto + Chr(13) + STR0025) //"Deseja continuar?"
					lRet := .f.
				Endif
			Endif
		Endif
	Endif

	If !Empty(cAlias)
		dbSelectArea(cAlias)
	Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MDT082MRK ³ Autor ³ Denis Hyroshi de Souza³ Data ³ 09/02/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Adiciona a atividade da empresa atual                       ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MDT082MRK()

	Local nLin     := Len( oBrwB:aCols )
	Local nLenLin  := Len( oBrwB:aCols[nLin] )
	Local cCnaeEmp := PadR( SM0->M0_CNAE , Len(TOE->TOE_CNAE) )

	If !Empty(cCnaeEmp)
		If aSCAN(oBrwB:aCols,{|x| x[1] == cCnaeEmp .and. !x[Len(x)] }) == 0
			dbSelectArea("TOE")
			dbSetOrder(1)
			If dbSeek(xFilial("TOE")+cCnaeEmp)
				If Empty( oBrwB:aCols[nLin,1] ) .and. !oBrwB:aCols[nLin,nLenLin]
					oBrwB:aCols[ nLin , 1 ] := TOE->TOE_CNAE
					oBrwB:aCols[ nLin , 2 ] := TOE->TOE_DESCRI
				Else
					aAdd( oBrwB:aCols , aClone(aBlankTKA) )
					nLin := Len( oBrwB:aCols )
					oBrwB:aCols[ nLin , 1 ] := TOE->TOE_CNAE
					oBrwB:aCols[ nLin , 2 ] := TOE->TOE_DESCRI
				Endif
				oBrwB:lModified := .T.
				oBrwB:lNewLine  := .F.
			Else
				MsgInfo(STR0026+cCnaeEmp,STR0013) //"Atividade (CNAE) não cadastrada. Código: "###"Atenção"
			Endif
		Endif
	Else
		MsgInfo(STR0027,STR0013) //"O código da Atividade (CNAE) não foi informado no Cadastro de Empresas."###"Atenção"
	Endif

Return