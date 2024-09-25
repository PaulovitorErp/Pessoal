#include "Protheus.ch" 
#Include "DbTree.ch"
#Include "MNTA299.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MNTA299   ºAutor  ³Roger Rodrigues     º Data ³  20/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Questionário de Sintomas                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAMNT                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNTA299()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Armazena variaveis p/ devolucao (NGRIGHTCLICK) 	   					  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aNGBEGINPRM 	:= NGBEGINPRM()
	Private cCadastro 	:= FWX2Nome("TU2")
	Private aRotina		:= MenuDef()

	// Variável das cores da tela
	Private aNGColor := aClone( NGCOLOR("10") )

	//Verifica se o update de facilities foi aplicado
	If !FindFunction("MNTUPDFAC") .or. !MNTUPDFAC()
		Return .F.
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("TU2")
	dbSetOrder(1)
	mBrowse( 6, 1,22,75,"TU2")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Devolve variaveis armazenadas (NGRIGHTCLICK) 					 	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	NGRETURNPRM(aNGBEGINPRM)

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MenuDef  ³ Autor ³ Roger Rodrigues       ³ Data ³20/12/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Utilizacao de Menu Funcional.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaMNT                                                    ³±±
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
	Local aRotina := {	{ STR0001 , "AxPesqui"	, 0 , 1},; //"Pesquisar"
	{ STR0002 , "MNT299CAD"	, 0 , 2},; //"Visualizar"
	{ STR0003 , "MNT299CAD"	, 0 , 3},; //"Incluir"
	{ STR0004 , "MNT299CAD"	, 0 , 4},; //"Alterar"
	{ STR0005 , "MNT299CAD"	, 0 , 5, 3}} //"Excluir"

Return aRotina
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MNT299CAD ºAutor  ³Roger Rodrigues     º Data ³  20/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta tela de cadastro                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MNTA299                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNT299CAD(cAlias, nRecno, nOpcx)
	Local aNGBEGINPRM := If(!IsInCallStack("MNTA299"),NGBEGINPRM(,"MNTA299",,.f.),{})
	Local cTitulo := FWX2Nome("TU2")
	Local lOk := .F.
	Local oDlg299, oSplitter
	Local oPanelTop,oPanelBot,oPnlBtn,oMenu
	Local nIdx

	//Variaveis de tamanho de tela e objetos
	Local aSize := {}, aObjects := {}, aInfo := {}, aPosObj := {}

	//Variaiveis para criacao do arquivo temporario
	Private aTRB299 := {}, aInd299 := {}, oTmp299, cAlias299 := GetNextAlias()

	//Variaveis da Arvore
	Private cNivPai    := "001"
	Private cFolderBem := "ENGRENAGEM"
	Private cFolderLoc := "PREDIO"

	//Variaveis de Tela
	Private aTela := {}, aGets := {}

	//Definicao de tamanho de tela e objetos
	aSize := MsAdvSize(,.f.,430)
	Aadd(aObjects,{030,030,.t.,.t.})
	Aadd(aObjects,{100,100,.t.,.t.})
	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObjects,.t.)

	Inclui := (nOpcx == 3)
	Altera := (nOpcx == 4)

	//Criacao do Arquivo temporario
	dbSelectArea("TU3")
	aTRB299 := dbStruct()
	aAdd(aTRB299, {"DESCRI"		,"C",50,0})
	aAdd(aTRB299, {"DELETADO"	,"C",01,0})

	aInd299  := {	{"TU3_CODNIV"},;
	{"TU3_NIVSUP"},;
	{"TU3_TIPO"},;
	{"TU3_NIVSUP","TU3_ORDEM"}}

	oTmp299 := FWTemporaryTable():New(cAlias299, aTRB299)
	For nIdx := 1 To Len(aInd299)
		oTmp299:AddIndex("Ind"+cValToChar(nIdx), aInd299[nIdx])
	Next nIdx
	oTmp299:Create()

	Define MsDialog oDlg299 Title OemToAnsi(cTitulo) From aSize[7],0 To aSize[6],aSize[5] Of oMainWnd Pixel
	oDlg299:lMaximized := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Estrutura da Tela            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSplitter := tSplitter():New(0,0,oDlg299,100,100,1 )
	oSplitter:Align := CONTROL_ALIGN_ALLCLIENT

	oPanelTop := TPanel():New(0,0,,oSplitter,,,,,,10,10,.F.,.F.)
	oPanelTop:nHeight := 4
	oPanelTop:Align := CONTROL_ALIGN_TOP

	oPanelBot := TPanel():New(0,0,,oSplitter,,,,,,10,10,.F.,.F.)
	oPanelBot:Align := CONTROL_ALIGN_BOTTOM

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parte de Superior da Tela          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Dbselectarea("TU2")
	RegToMemory("TU2",(nOpcx == 3))
	oEnc299 := MsMGet():New("TU2",nRecno,nOpcx,,,,,aPosObj[1],,,,,,oPanelTop)
	oEnc299:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parte de Inferior da Tela          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oTree := DbTree():New(005, 022, 170, 302, oPanelBot,,, .t.)
	oTree:Align := CONTROL_ALIGN_ALLCLIENT

	//Monta Arvore
	If nOpcx != 3
		Processa( {|| MNT299LOAD()} )
	Endif

	If Str(nOpcx,1) $ "2/5"
		oTree:bChange	:= {||}
		oTree:BlDblClick:= {|| fIncItem(2)}
	Else
		oTree:bChange	:= {||}
		oTree:blDblClick:= {|| fIncItem(4)}
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Painel de Legenda                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPnlBtn := TPanel():New(00,00,,oPanelBot,,,,aNGColor[1],aNGColor[2],12,12,.F.,.F.)
	oPnlBtn:Align := CONTROL_ALIGN_LEFT

	oBtnVisId  := TBtnBmp():NewBar("ng_ico_visual","ng_ico_visual",,,,{|| fIncItem(2)},,oPnlBtn,,,STR0002,,,,,"") //"Visualizar"
	oBtnVisId:Align  := CONTROL_ALIGN_TOP
	oBtnVisId:lVisible := (nOpcx !=3 .and. nOpcx !=4)

	oBtnIncId  := TBtnBmp():NewBar("ng_ico_incid","ng_ico_incid",,,,{|| fIncItem(3)},,oPnlBtn,,,STR0003,,,,,"") //"Incluir"
	oBtnIncId:Align  := CONTROL_ALIGN_TOP
	oBtnIncId:lVisible := (nOpcx != 2 .and. nOpcx != 5)

	oBtnAltId  := TBtnBmp():NewBar("ng_ico_altid","ng_ico_altid",,,,{|| fIncItem(4)},,oPnlBtn,,,STR0004,,,,,"") //"Alterar"
	oBtnAltId:Align  := CONTROL_ALIGN_TOP
	oBtnAltId:lVisible := (nOpcx != 2 .and. nOpcx != 5)

	oBtnExcId  := TBtnBmp():NewBar("ng_ico_excid","ng_ico_excid",,,,{|| fExcItem()},,oPnlBtn,,,STR0005,,,,,"") //"Excluir"
	oBtnExcId:Align  := CONTROL_ALIGN_TOP
	oBtnExcId:lVisible := (nOpcx != 2 .and. nOpcx != 5)

	Activate Dialog oDlg299 On Init (EnchoiceBar(oDlg299,{|| lOk:=.T.,If(!fTudoOK(,nOpcx),lOk := .F., oDlg299:End())},;
	{|| lOk:=.F.,oDlg299:End()})) Centered

	If lOk
		fGrava299(nOpcx)
	Endif

	//Deleta o arquivo temporario fisicamente
	oTmp299:Delete()

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fCriaTree ºAutor  ³Roger Rodrigues     º Data ³  20/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria ou Atualiza o item pai da arvore                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MNTA299                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fCriaTree()
	Local cDescFam := "", cDescMod := ""
	Local cDescr := Space(56)
	Local cFolder:= cFolderBem

	If !Empty(M->TU2_CODFAM)
		dbSelectArea("ST6")
		dbSetOrder(1)
		If dbSeek(xFilial("ST6")+M->TU2_CODFAM)
			cDescFam := ST6->T6_NOME
			If ST6->T6_TIPOFAM == "1"
				cFolder := cFolderBem
			Else
				cFolder := cFolderLoc
			Endif
		Endif
	Endif
	If !Empty(M->TU2_TIPMOD)
		cDescMod := NGSEEK("TQR",M->TU2_TIPMOD,1,"TQR->TQR_DESMOD")
	Endif

	If !Empty(cDescFam)
		If !Empty(cDescMod)
			cDescr := AllTrim(Substr(cDescFam,1,33))+" / "+AllTrim(cDescMod)
		Else
			cDescr := AllTrim(cDescFam)
		Endif
	ElseIf !Empty(cDescMod)
		cDescr := AllTrim(cDescMod)
	Endif

	cDescr := Padr(cDescr,56)

	dbSelectArea(cAlias299)
	dbSetOrder(1)
	If !dbSeek(cNivPai)
		//Cria nova Estrutura
		DbAddTree oTree Prompt cDescr Opened Resource cFolder, cFolder Cargo cNivPai+"FAM"
		RecLock(cAlias299,.T.)
		(cAlias299)->TU3_CODNIV  := cNivPai
		(cAlias299)->DESCRI      := cDescr
		(cAlias299)->TU3_NIVSUP  := "000"
		(cAlias299)->TU3_ORDEM   := "000"
		(cAlias299)->TU3_TIPO	 := "FAM"
		MsUnlock(cAlias299)
		DbEndTree oTree
	Else
		oTree:TreeSeek(cNivPai)
		oTree:ChangePrompt(cDescr,cNivPai)
		oTree:ChangeBmp(cFolder,cFolder)
		RecLock(cAlias299,.F.)
		(cAlias299)->DESCRI  := cDescr
		MsUnlock(cAlias299)
		DbEndTree oTree
	Endif

	oTree:Refresh()
	oTree:SetFocus()

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MNT299LOADºAutor  ³Roger Rodrigues     º Data ³  23/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega arvore                                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MNTA299                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNT299LOAD()
	Local cChave := xFilial("TU3")+TU2->TU2_CODFAM+TU2->TU2_TIPMOD+cNivPai
	Local cFolder1, cFolder2, cTipo, cConvTipo, cDescri
	Local nRecTU3
	Local i

	//Cria item pai
	fCriaTree()

	//Para garantir que nao vai ultrapassar as 999 vezes de recursividade faz o primeiro nivel aqui
	dbSelectArea("TU3")
	dbSetOrder(2)
	dbSeek(cChave)
	While !Eof() .and. cChave == TU3->(TU3_FILIAL+TU3_CODFAM+TU3_TIPMOD+TU3_NIVSUP)

		If TU3->TU3_TIPO == "1"
			cFolder1 := "NGOSVERMELHO"
			cFolder2 := "NGOSVERMELHO"
			cTipo	 := "PRO"
			cConvTipo:= "P"
			cDescri  := NGSEEK("ST8",TU3->TU3_CODOCO+cConvTipo,1,"ST8->T8_NOME")
		ElseIf TU3->TU3_TIPO == "2"
			cFolder1 := "BMPPERG"
			cFolder2 := "BMPPERG"
			cTipo	 := "PER"
			cDescri  := TU3->TU3_PERGUN
		Else
			cFolder1 := "ng_ico_areamnt"
			cFolder2 := "ng_ico_areamnt2"
			cTipo	 := "SER"
			cDescri  := NGSEEK("TQ3",TU3->TU3_CDSERV,1,"TQ3->TQ3_NMSERV")
		Endif

		If !Empty(TU3->TU3_PERGOP)
			cDescri := AllTrim(TU3->TU3_PERGOP)+" - "+cDescri
		Endif

		oTree:TreeSeek(cNivPai)
		//Adiciona na arvore
		oTree:AddItem(cDescri,TU3->TU3_CODNIV+cTipo,cFolder1,cFolder2,,, 2)
		//Adiciona no TRB
		dbSelectArea(cAlias299)
		RecLock(cAlias299,.T.)
		For i:=1 to FCount()
			If "DESCRI" $ Upper(FieldName(i))
				FieldPut(i, cDescri)
			ElseIf "DELETADO" $ Upper(FieldName(i))
				FieldPut(i, Space(1))
			Else
				FieldPut(i, &("TU3->"+FieldName(i)))
			Endif
		Next i
		MsUnlock(cAlias299)

		nRecTU3 := TU3->(Recno())
		fLoadSon(TU3->TU3_CODNIV)
		//Fecha item pai
		oTree:TreeSeek(cNivPai)
		dbSelectArea("TU3")
		dbSetOrder(2)
		dbGoTo(nRecTU3)
		dbSkip()
	End

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fLoadSon  ºAutor  ³Roger Rodrigues     º Data ³  23/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega itens filhos                                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MNTA299                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fLoadSon(cFather)
	Local cChave := xFilial("TU3")+TU2->TU2_CODFAM+TU2->TU2_TIPMOD+cFather
	Local cFolder1, cFolder2, cTipo, cConvTipo, cDescri
	Local nRecTU3
	Local i

	dbSelectArea("TU3")
	dbSetOrder(2)
	dbSeek(xFilial("TU3")+TU2->TU2_CODFAM+TU2->TU2_TIPMOD+cFather)
	While !eof() .and. xFilial("TU3")+TU2->TU2_CODFAM+TU2->TU2_TIPMOD+cFather == TU3->(TU3_FILIAL+TU3_CODFAM+TU3_TIPMOD+TU3_NIVSUP)

		If TU3->TU3_TIPO == "1"
			cFolder1 := "NGOSVERMELHO"
			cFolder2 := "NGOSVERMELHO"
			cTipo	 := "PRO"
			cConvTipo:= "P"
			cDescri  := NGSEEK("ST8",TU3->TU3_CODOCO+cConvTipo,1,"ST8->T8_NOME")
		ElseIf TU3->TU3_TIPO == "2"
			cFolder1 := "BMPPERG"
			cFolder2 := "BMPPERG"
			cTipo	 := "PER"
			cDescri  := TU3->TU3_PERGUN
		Else
			cFolder1 := "ng_ico_areamnt"
			cFolder2 := "ng_ico_areamnt2"
			cTipo	 := "SER"
			cDescri  := NGSEEK("TQ3",TU3->TU3_CDSERV,1,"TQ3->TQ3_NMSERV")
		Endif

		If !Empty(TU3->TU3_PERGOP)
			cDescri := AllTrim(TU3->TU3_PERGOP)+" - "+cDescri
		Endif

		oTree:TreeSeek(cFather)
		//Adiciona na arvore
		oTree:AddItem(cDescri,TU3->TU3_CODNIV+cTipo,cFolder1,cFolder2,,, 2)
		//Adiciona no TRB
		dbSelectArea(cAlias299)
		RecLock(cAlias299,.T.)
		For i:=1 to FCount()
			If "DESCRI" $ Upper(FieldName(i))
				FieldPut(i, cDescri)
			ElseIf "DELETADO" $ Upper(FieldName(i))
				FieldPut(i, Space(1))
			Else
				FieldPut(i, &("TU3->"+FieldName(i)))
			Endif
		Next i
		MsUnlock(cAlias299)

		nRecTU3 := TU3->(Recno())
		fLoadSon(TU3->TU3_CODNIV)
		//Fecha item pai
		oTree:TreeSeek(cFather)
		dbSelectArea("TU3")
		dbSetOrder(2)
		dbGoTo(nRecTU3)
		dbSkip()
	End

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MNT299VAL ºAutor  ³Roger Rodrigues     º Data ³  20/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza validacao dos campos da tela                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MNTA299                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNT299VAL(cCampo)
	Local i
	Local lRet := .T.
	Local cMsg := cSol := cTipoItem := ""
	Local aArea:= GetArea(), aTemp := {}
	Default cCampo := ReadVar()

	If cCampo == "M->TU2_CODFAM"
		lRet := ExistCpo("ST6",M->TU2_CODFAM)
	ElseIf cCampo == "M->TU2_TIPMOD" .and. !Empty(M->TU2_TIPMOD)
		lRet := ExistCpo("TQR",M->TU2_TIPMOD)
	ElseIf cCampo == "M->TU3_TIPO"
		If (lRet := Pertence("123",M->TU3_TIPO))
			If (M->TU3_TIPO == "1" .and. cNivSup != cNivPai)
				cMsg := STR0006 //"Itens do tipo Problema só podem ser cadastrados no primeiro nível da estrutura."
				cSol := STR0007 //"Cadastrar um item do tipo Problema logo abaixo do item principal(Família+Tipo Modelo)."
			ElseIf (M->TU3_TIPO != "1" .and. cNivSup == cNivPai)
				cMsg := STR0008 //"Só podem ser cadastrados itens do tipo Problema no primeiro nível da estrutura."
				cSol := STR0007 //"Cadastrar um item do tipo Problema logo abaixo do item principal(Família+Tipo Modelo)."
			ElseIf M->TU3_TIPO == "2" .and. SubStr(oTree:GetCargo(), 4, 3) == "ARE"
				cMsg := STR0009 //"Não é possível incluir uma pergunta abaixo de um tipo de serviço."
				cSol := STR0010 //"Cadastre a pergunta em outro nível."
			ElseIF !lPaiPerg
				dbSelectArea(cAlias299)
				dbSetOrder(2)
				dbSeek(cNivSup)
				While !eof() .and. (cAlias299)->TU3_NIVSUP == cNivSup
					//Se estiver tentando incluir pergunta com outro item
					If (cAlias299)->TU3_CODNIV != cCodNiv .and. M->TU3_TIPO != "1" .and. Empty((cAlias299)->DELETADO)
						If M->TU3_TIPO == "2"
							cTipoItem := STR0011 //"a pergunta"
						ElseIf M->TU3_TIPO == "3"
							cTipoItem := STR0012 //"o tipo de serviço"
						Endif
						cMsg := STR0013+cTipoItem+STR0014 //"Já existe outro item cadastrado neste nível. Neste caso " # " deve ser o único item do nível."
						cSol := STR0015+cTipoItem+STR0016 //"Exclua os demais itens do nível ou cadastre " # " em outro nível."
						Exit
					Endif
					dbSelectArea(cAlias299)
					dbSkip()
				End
			ElseIf lPaiPerg
				dbSelectArea(cAlias299)
				dbSetOrder(2)
				dbSeek(cNivSup)
				While !eof() .and. (cAlias299)->TU3_NIVSUP == cNivSup
					//Se estiver tentando incluir pergunta com outro item
					If (cAlias299)->TU3_CODNIV != cCodNiv  .and. Empty((cAlias299)->DELETADO);
					.and. (M->TU3_TIPO != "1" .or. (cAlias299)->TU3_TIPO != "1")
						aTemp := StrTokArr(M->TU3_PERGOP,";")
						For i:=1 to Len(aTemp)
							If aTemp[i] $ (cAlias299)->TU3_PERGOP
								If M->TU3_TIPO == "2"
									cTipoItem := STR0011 //"a pergunta"
								ElseIf M->TU3_TIPO == "3"
									cTipoItem := STR0012 //"o tipo de serviço"
								Endif
								cMsg := STR0013+cTipoItem+STR0014 //"Já existe outro item cadastrado neste nível. Neste caso " # " deve ser o único item do nível."
								cSol := STR0015+cTipoItem+STR0016 //"Exclua os demais itens do nível ou cadastre " # " em outro nível."
								Exit
							Endif
						Next i
					Endif
					dbSelectArea(cAlias299)
					dbSkip()
				End
			Endif

			RestArea(aArea)

			If !Empty(cMsg)
				ShowHelpDlg(STR0017,{cMsg},1,{cSol}) //"Atenção"
				lRet := .F.
			Endif
			If lRet .and. M->TU3_TIPO == "1"
				cTipoOco := "P"
			Endif
		Endif
	ElseIf cCampo == "M->TU3_CODOCO"
		lRet := ExistCpo("ST8",M->TU3_CODOCO+cTipoOco)
		dbSelectArea(cAlias299)
		dbSetOrder(2)
		dbSeek(cNivSup)
		While !eof() .and. (cAlias299)->TU3_NIVSUP == cNivSup
			//Se estiver tentando incluir pergunta com outro item
			If (cAlias299)->TU3_CODNIV != cCodNiv .and. M->TU3_TIPO == "1" .and. Empty((cAlias299)->DELETADO);
			.and. M->TU3_CODOCO == (cAlias299)->TU3_CODOCO
				Help(" ",1,"JAEXISTINF")
				lRet := .F.
				Exit
			Endif
			dbSelectArea(cAlias299)
			dbSkip()
		End
		RestArea(aArea)
	ElseIf cCampo == "M->TU3_CDSERV"
		lRet := ExistCpo("TQ3",M->TU3_CDSERV)
	Endif

	If lRet .and. (cCampo == "M->TU2_CODFAM" .or. cCampo == "M->TU2_TIPMOD")
		fCriaTree()
	Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MNT299WHENºAutor  ³Roger Rodrigues     º Data ³  03/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza when dos campos da tela                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MNTA299                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNT299WHEN(cCampo)
	Local lRet := .T.

	If cCampo == "M->TU3_CODOCO"
		lRet := Empty(M->TU3_TIPO) .or. M->TU3_TIPO == "1"
		If lRet
			M->TU3_PERGUN	:= Space(TAMSX3("TU3_PERGUN")[1])
			M->TU3_COMBO	:= Space(TAMSX3("TU3_COMBO")[1])
			M->TU3_TPLIST	:= Space(TAMSX3("TU3_TPLIST")[1])
			M->TU3_CDSERV	:= Space(TAMSX3("TU3_CDSERV")[1])
			M->TU3_NMSERV	:= Space(TAMSX3("TU3_NMSERV")[1])
		Endif
		M->TU3_DESOCO	:= NGSEEK('ST8',M->TU3_CODOCO,1,'ST8->T8_NOME')
	ElseIf cCampo == "M->TU3_CDSERV"
		lRet := M->TU3_TIPO == "3"
		If lRet
			M->TU3_PERGUN	:= Space(TAMSX3("TU3_PERGUN")[1])
			M->TU3_COMBO	:= Space(TAMSX3("TU3_COMBO")[1])
			M->TU3_TPLIST	:= Space(TAMSX3("TU3_TPLIST")[1])
			M->TU3_CODOCO	:= Space(TAMSX3("TU3_CODOCO")[1])
			M->TU3_DESOCO	:= Space(TAMSX3("TU3_DESOCO")[1])
		Endif
	ElseIf cCampo == "M->TU3_PERGUN"
		lRet := (M->TU3_TIPO $ "2")
	ElseIf cCampo == "M->TU3_TPLIST"
		lRet := (M->TU3_TIPO $ "2")
	ElseIf cCampo == "M->TU3_COMBO"
		lRet := (M->TU3_TIPO $ "2")
		If ReadVar() == "M->TU3_COMBO"
			MNT299BOX()
			lRet := .F.
		Endif
	ElseIf cCampo == "M->TU3_PERGOP"
		lRet := lPaiPerg
		If ReadVar() == "M->TU3_PERGOP"
			fChooseOpc(cNivSup,.F.)
			lRet := .F.
		Endif
	Endif
	If lRet .and. (cCampo == "M->TU3_PERGUN" .or. cCampo == "M->TU3_COMBO")
		M->TU3_CODOCO := Space(TAMSX3("TU3_CODOCO")[1])
		M->TU3_DESOCO := Space(TAMSX3("TU3_DESOCO")[1])
		M->TU3_CDSERV	:= Space(TAMSX3("TU3_CDSERV")[1])
		M->TU3_NMSERV	:= Space(TAMSX3("TU3_NMSERV")[1])
	Endif

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fIncItem  ºAutor  ³Roger Rodrigues     º Data ³  21/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza a inclusao de itens                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MNTA299                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fIncItem(nOpcx)
	Local aNGBEGINPRM := NGBEGINPRM(,"MNTA299")
	Local oDlgItem
	Local cFolder1, cFolder2, cTipo, cDescTree := ""
	Local nCmpo 	:= 0
	Local xConteudo := ""
	Local cOpcoes 	:= ""
	Local i
	Local lOk 		:= .F.
	Local lRet 		:= .T.

	Private cTipoOco := Space(1)//Variavel filtro do F3 do campo Ocorrencia
	Private lPaiPerg := .F.//Indica se o item pai eh uma pergunta
	Private cCodNiv := SubStr(oTree:GetCargo(), 1, 3)
	Private cNivSup  := cCodNiv

	dbSelectArea(cAlias299)
	dbSetOrder(1)
	If !dbSeek(cNivPai)
		ShowHelpDlg(STR0017,{STR0018}) //"Atenção" # "Favor informar a Família de Bem/Localização para criação da Árvore."
		lRet := .F.
	Endif
	If lRet .and. cNivSup == cNivPai .and. nOpcx != 3
		ShowHelpDlg(STR0017,{STR0019}) //"Atenção" # "O Item Principal da Árvore não pode ser alterado, excluído ou visualizado."
		lRet := .F.
	Endif

	//Se for Pergunta
	If lRet .and. nOpcx == 3 .and. SubStr(oTree:GetCargo(), 4, 3) == "PER"
		lPaiPerg := .T.
		cOpcoes  := fChooseOpc(cCodNiv,.T.)
		If Empty(cOpcoes)
			lRet := .F.
		Endif
	ElseIf lRet .and. nOpcx == 3 .and. SubStr(oTree:GetCargo(), 4, 3) == "SER"
		ShowHelpDlg(STR0017,{STR0020},1,; //"Atenção" # "Não é possível relacionar itens ao tipo de serviço, o mesmo deve ser o último item do Questionário de Sintomas."
		{STR0021}) //"Inverta a ordem dos itens a serem cadastrados."
		lRet := .F.
	ElseIf lRet .and. nOpcx == 3
		dbSelectArea(cAlias299)
		dbSetOrder(2)
		dbSeek(cNivSup)
		While !eof() .and. (cAlias299)->TU3_NIVSUP == cNivSup
			//Se for pergunta nao pode adicionar outra
			If (cAlias299)->TU3_CODNIV != cCodNiv .and. (cAlias299)->TU3_TIPO == "2" .and. Empty((cAlias299)->DELETADO)
				ShowHelpDlg(STR0017,{STR0022},1,; //"Atenção" # "O nível para a inclusão do item já têm uma pergunta incluida. Não é possível incluir o novo item."
				{STR0023}) //"Cadastre o novo item em outro nível."
				lRet := .F.
			Endif
			dbSelectArea(cAlias299)
			dbSkip()
		End
	Endif

	If !lRet
		NGRETURNPRM(aNGBEGINPRM)
		Return .F.
	Endif

	//Variaveis de tela
	Inclui	:= (nOpcx == 3)
	Altera	:= (nOpcx == 4)
	aTela	:= {}
	aGets	:= {}

	aNao 	:= {"TU3_FILIAL", "TU3_CODFAM", "TU3_TIPMOD", "TU3_CODNIV", "TU3_NIVSUP", "TU3_ORDEM"}
	aChoice	:= NGCAMPNSX3("TU3",aNao)

	Define MsDialog oDlgItem From 400.5,226 To 620,805 Title STR0029 Pixel //"Problema/Causa/Solução"

	Dbselectarea("TU3")
	If nOpcx == 2
		dbSetOrder(1)
		dbSeek(xFilial("TU3")+M->TU2_CODFAM+M->TU2_TIPMOD+cCodNiv)
	Endif
	RegToMemory("TU3",(nOpcx == 3))
	oEncItem:= MsMGet():New("TU3",0,nOpcx,,,,aChoice,,,3)
	oEncItem:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	//Se nao for Inclusao, carrega campos
	If nOpcx != 3 .and. nOpcx != 2
		//Posiciona no Registro
		dbSelectArea(cAlias299)
		dbSetOrder(1)
		dbSeek(cCodNiv)
		cNivSup := (cAlias299)->TU3_NIVSUP
		For i:=1 to Len(aChoice)
			//Cria campo na Memoria
			CriaVar(aChoice[i])
			If aScan(aTRB299, {|x| x[1] == Trim(aChoice[i]) }) > 0
				//Carrega com informacoes do TRB
				&("M->"+aChoice[i]) := &("(cAlias299)->"+aChoice[i])
			Endif
			If "TU3_TIPO" $ Trim(Upper(aChoice[i]))
				If M->TU3_TIPO == "1"
					cTipoOco := "P"
				Endif
			Endif
			If "TU3_PERGOP" $ Trim(Upper(aChoice[i]))
				lPaiPerg := !Empty((cAlias299)->TU3_PERGOP)
			Endif
		Next i
	ElseIf nOpcx != 2
		M->TU3_PERGOP := cOpcoes
	Endif

	Activate MsDialog oDlgItem On Init (EnchoiceBar(oDlgItem,{|| lOk:=.T.,If(!fTudoOk(.T.,nOpcx),lOk := .F., oDlgItem:End())},;
	{|| lOk:=.F.,oDlgItem:End()})) Centered
	If lOk .and. nOpcx != 2
		If M->TU3_TIPO == "1"
			cFolder1 := "NGOSVERMELHO"
			cFolder2 := "NGOSVERMELHO"
			cTipo	 := "PRO"
			cConvTipo:= "P"
			cDescTree:= NGSEEK("ST8",M->TU3_CODOCO+cConvTipo,1,"ST8->T8_NOME")
		ElseIf M->TU3_TIPO == "2"
			cFolder1 := "BMPPERG"
			cFolder2 := "BMPPERG"
			cTipo	 := "PER"
			cDescTree:= M->TU3_PERGUN
		Else
			cFolder1 := "ng_ico_areamnt"
			cFolder2 := "ng_ico_areamnt2"
			cTipo	 := "SER"
			cDescTree:= NGSEEK("TQ3",M->TU3_CDSERV,1,"TQ3->TQ3_NMSERV")
		Endif

		If !Empty(M->TU3_PERGOP)
			cDescTree := AllTrim(M->TU3_PERGOP)+" - "+cDescTree
		Endif
		If nOpcx == 3
			cCodNiv := fRetCodigo(.T.)
			//Adiciona na arvore
			oTree:AddItem(cDescTree,cCodNiv+cTipo,cFolder1,cFolder2,,, 2)
			//Adiciona no TRB
			dbSelectArea(cAlias299)
			RecLock(cAlias299,.T.)
			For i:=1 to FCount()

				nCmpo := "M->"+FieldName(i)
				xConteudo := &nCmpo.

				If "_CODNIV" $ Upper(FieldName(i))
					FieldPut(i, cCodNiv)
				ElseIf "_ORDEM" $ Upper(FieldName(i))
					FieldPut(i, cCodNiv)
				ElseIf "_NIVSUP" $ Upper(FieldName(i))
					FieldPut(i, cNivSup)
				ElseIf "DESCRI" $ Upper(FieldName(i))
					FieldPut(i, cDescTree)
				ElseIf aScan(aNao,{|x| x == FieldName(i)}) == 0 .and. ValType(xConteudo) != "U"
					FieldPut(i, &("M->"+FieldName(i)))
				Endif
			Next i
			MsUnlock(cAlias299)
		ElseIf nOpcx == 4
			//Altera na Arvore
			oTree:ChangePrompt(cDescTree,cCodNiv)
			//Altera somente os campos necessarios
			dbSelectArea(cAlias299)
			dbSetOrder(1)
			dbSeek(cCodNiv)
			RecLock(cAlias299,.F.)
			For i:=1 to Len(aChoice)
				//Se encontrar no TRB
				If aScan(aTRB299, {|x| x[1] == Trim(aChoice[i]) }) > 0
					&("(cAlias299)->"+aChoice[i]) := &("M->"+aChoice[i])
				Endif
			Next i
			(cAlias299)->DESCRI := cDescTree//Atualiza Descricao
			MsUnlock(cAlias299)
		Endif
	Endif

	NGRETURNPRM(aNGBEGINPRM)
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fRetCodigoºAutor  ³Roger Rodrigues     º Data ³  21/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna proximo codigo a ser gravado                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MNTA299                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fRetCodigo(lTRB)
	Local cCodigo:= "002"
	Local aArea  := GetArea()
	Default lTRB := .F.

	If lTRB
		dbSelectArea(cAlias299)
		dbSetOrder(1)
		dbGoBottom()
		If (cAlias299)->(RecCount()) > 0
			If FindFunction("Soma1Old")
				cCodigo := Soma1Old(AllTrim((cAlias299)->TU3_CODNIV))
			Else
				cCodigo := Soma1(AllTrim((cAlias299)->TU3_CODNIV))
			EndIf
		Endif
	Endif

	RestArea(aArea)
Return cCodigo
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fExcItem  ºAutor  ³Roger Rodrigues     º Data ³  12/22/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exclui item da Arvore                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MNTA299                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fExcItem(cLocal,cPrompt)
	Local aArea    := GetArea()
	Local lFilhos  := .F.
	Local cMensagem:= ""
	Default cLocal := Substr(oTree:GetCargo(), 1, 3)
	Default cPrompt:= AllTrim(oTree:GetPrompt())

	If !EMPTY(cLocal)
		//Verifica se nao eh o item principal
		If cLocal == cNivPai
			ShowHelpDlg(STR0017,{STR0024}) //"Atenção" # "O Item Principal da Árvore não pode ser alterado nem excluído."
			Return .F.
		Endif

		//Verifica se tem itens filhos
		dbSelectArea(cAlias299)
		dbSetOrder(2)
		If dbSeek(cLocal)
			lFilhos := .T.
		Endif
		If lFilhos
			cMensagem := STR0025+cPrompt+STR0026 //"Confirma a exclusão do item " # "? Todos os itens abaixo do mesmo também serão excluídos."
		Else
			cMensagem := STR0027+cPrompt+"?" //"Confirma a exclusão do item "
		Endif
		If MsgYesNo(cMensagem,STR0017) //"Atenção"
			//Remove Item do TRB
			dbSelectArea(cAlias299)
			dbSetOrder(1)
			dbSeek(cLocal)
			RecLock(cAlias299,.F.)
			(cAlias299)->DELETADO := "X"
			MsUnlock(cAlias299)
			//Remove Item na Arvore
			oTree:TreeSeek(cLocal)
			oTree:DelItem()
			oTree:Refresh()
			oTree:SetFocus()
			//Deleta itens filhos no TRB
			fDelFilho(cLocal)
		Endif
	Else
		HELP(" ",1,"ARQVAZIO")
		Return .F.
	EndIf

	RestArea(aArea)
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fDelFilho ºAutor  ³Roger Rodrigues     º Data ³  22/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Deleta itens filhos no TRB                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MNTA299                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fDelFilho(cPai)
	Local nRecno

	dbSelectArea(cAlias299)
	dbSetOrder(2)
	dbSeek(cPai)
	While !eof() .and. cPai == (cAlias299)->TU3_NIVSUP
		RecLock(cAlias299,.F.)
		(cAlias299)->DELETADO := "X"
		MsUnlock(cAlias299)
		nRecno := (cAlias299)->(Recno())
		fDelFilho((cAlias299)->TU3_CODNIV)
		dbSelectArea(cAlias299)
		dbGoTo(nRecno)
		dbSkip()
	End

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fTudoOK   ºAutor  ³Roger Rodrigues     º Data ³  22/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza validacao da tela                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MNTA299                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fTudoOK(lTela2,nOpcx)
	Local lRet := .T.
	Local nItem:= 0
	Default lTela2 := .F.

	lRet := Obrigatorio(aGets,aTela)

	If lRet
		//Se for a tela principal
		If !lTela2
			//Procura algum item filho
			dbSelectArea(cAlias299)
			dbSetOrder(2)
			dbSeek(cNivPai)
			While !eof() .and. (cAlias299)->TU3_NIVSUP == cNivPai
				If Empty((cAlias299)->DELETADO)
					nItem++
					Exit
				Endif
				dbSelectArea(cAlias299)
				dbSkip()
			End

			If nItem == 0 .and. (nOpcx == 3 .or. nOpcx == 4)
				ShowHelpDlg(STR0017,{STR0028}) //"Atenção" # "Favor informar pelo menos um Problema."
				lRet := .F.
			Endif
		Else
			If M->TU3_TIPO == "2"
				If Empty(M->TU3_PERGUN)
					Help(1," ","OBRIGAT2",,RetTitle("TU3_PERGUN"),3,0)
					Return .F.
				Endif
				If Empty(M->TU3_COMBO)
					Help(1," ","OBRIGAT2",,RetTitle("TU3_COMBO"),3,0)
					Return .F.
				Endif
				If Empty(M->TU3_TPLIST)
					Help(1," ","OBRIGAT2",,RetTitle("TU3_TPLIST"),3,0)
					Return .F.
				Endif
			ElseIf M->TU3_TIPO == "1"
				If Empty(M->TU3_CODOCO)
					Help(1," ","OBRIGAT2",,RetTitle("TU3_CODOCO"),3,0)
					Return .F.
				Endif
			ElseIf M->TU3_TIPO == "3"
				If Empty(M->TU3_CDSERV)
					Help(1," ","OBRIGAT2",,RetTitle("TU3_CDSERV"),3,0)
					Return .F.
				Endif
			Endif
		Endif
	Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGrava299 ºAutor  ³Roger Rodrigues     º Data ³  22/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza Gravacao                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MNTA299                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGrava299(nOpcx)
	Local lNovo   := .T.
	Local cCodNiv := "002"
	Local aNivel  := {}//Array com os niveis que foram modificados caso um registro tenha sido incluido ao mesmo tempo
	Local cQuery, i

	If nOpcx == 3 .or. nOpcx == 4
		dbSelectArea("TU2")
		dbSetOrder(1)
		If dbSeek(xFilial("TU2")+M->TU2_CODFAM+M->TU2_TIPMOD)
			RecLock("TU2",.F.)
		Else
			RecLock("TU2",.T.)
		Endif
		For i:=1 to FCount()
			If "_FILIAL"$Upper(FieldName(i))
				FieldPut(i, xFilial("TU2"))
			Else
				FieldPut(i, &("M->"+FieldName(i)))
			Endif
		Next i
		MsUnlock("TU2")

		dbSelectArea(cAlias299)
		dbSetOrder(1)
		While !eof()
			//Nao Grava o Nivel pai
			If (cAlias299)->TU3_CODNIV == cNivPai
				dbSelectArea(cAlias299)
				dbSkip()
			Endif
			If !Empty((cAlias299)->DELETADO)
				dbSelectArea("TU3")
				dbSetOrder(1)
				If dbSeek(xFilial("TU3")+M->TU2_CODFAM+M->TU2_TIPMOD+(cAlias299)->TU3_CODNIV)
					RecLock("TU3",.F.)
					dbDelete()
					MsUnlock("TU3")
				Endif
			Else
				lNovo := .T.
				dbSelectArea("TU3")
				dbSetOrder(1)
				If dbSeek(xFilial("TU3")+M->TU2_CODFAM+M->TU2_TIPMOD+(cAlias299)->TU3_CODNIV)
					lNovo := .F.
				Else
					//Acha o ultimo registro da tabela
					cCodNiv := "001"
					#IFDEF TOP
					cAliasQry := GetNextAlias()
					cQuery := " SELECT MAX(TU3.TU3_CODNIV) CODMAX FROM "+RetSqlName("TU3")+" TU3 "
					cQuery += " WHERE TU3.TU3_FILIAL = '"+xFilial("TU3")+"' AND TU3.TU3_CODFAM = '"+M->TU2_CODFAM+"' "
					cQuery += " AND TU3.TU3_TIPMOD = '"+M->TU2_TIPMOD+"' "
					cQuery := ChangeQuery(cQuery)
					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

					dbSelectArea(cAliasQry)
					dbGoTop()
					If !Eof()
						cCodNiv := (cAliasQry)->CODMAX
					EndIf
					(cAliasQry)->(dbCloseArea())

					#ELSE
					dbSelectArea("TU3")
					dbSetOrder(1)
					dbSeek(xFilial("TU3")+M->TU2_CODFAM+M->TU2_TIPMOD)
					While !Eof() .and. xFilial("TU3")+M->TU2_CODFAM+M->TU2_TIPMOD == TU3->(TU3_FILIAL+TU3_CODFAM+TU3_TIPMOD)
						cCodNiv := TU3->TU3_CODNIV
					End
					#ENDIF
					If cCodNiv != "001" .AND. !Empty(cCodNiv)
						If FindFunction("Soma1Old")
							cCodNiv := Soma1Old(AllTrim(cCodNiv),3)
						Else
							cCodNiv := Soma1(AllTrim(cCodNiv),3)
						Endif
						aADD( aNivel,{cCodNiv, (cAlias299)->TU3_CODNIV })
					Else
						cCodNiv := "002"
					EndIf
				Endif
				dbSelectArea("TU3")
				RecLock("TU3",lNovo)
				For i:=1 to FCount()
					If "_FILIAL" $ Trim(Upper(FieldName(i)))
						FieldPut(i, xFilial("TU3"))
					ElseIf "_CODFAM" $ Trim(Upper(FieldName(i)))
						FieldPut(i, M->TU2_CODFAM)
					ElseIf "_TIPMOD" $ Trim(Upper(FieldName(i)))
						FieldPut(i, M->TU2_TIPMOD)
					ElseIf "_CODNIV" $ Trim(Upper(FieldName(i))) .and. nOpcx == 3
						FieldPut(i, cCodNiv)
					ElseIf "_NIVSUP" $ Trim(Upper(FieldName(i))) .and. nOpcx == 3
						If (nPos := aScan(aNivel,{ |x| Trim(Upper(x[2])) == (cAlias299)->TU3_NIVSUP})) > 0
							FieldPut(i, aNivel[nPos][1])
						Else
							FieldPut(i, (cAlias299)->TU3_NIVSUP)
						Endif
					ElseIf aScan(aTRB299, {|x| x[1] == Trim(Upper(FieldName(i)))}) > 0
						FieldPut(i, &("(cAlias299)->"+FieldName(i)) )
					Endif
				Next i
				MsUnlock("TU3")
			Endif

			dbSelectArea(cAlias299)
			dbSkip()
		End
	ElseIf nOpcx == 5
		dbSelectArea("TU3")
		dbSetOrder(1)
		dbSeek(xFilial("TU3")+M->TU2_CODFAM+M->TU2_TIPMOD)
		While !eof() .and. xFilial("TU3")+M->TU2_CODFAM+M->TU2_TIPMOD == TU3->(TU3_FILIAL+TU3_CODFAM+TU3_TIPMOD)
			RecLock("TU3",.F.)
			dbDelete()
			MsUnlock("TU3")
			dbSelectArea("TU3")
			dbSkip()
		End
		dbSelectArea("TU2")
		dbSetOrder(1)
		If dbSeek(xFilial("TU2")+M->TU2_CODFAM+M->TU2_TIPMOD)
			RecLock("TU2",.F.)
			dbDelete()
			MsUnlock("TU2")
		Endif
	Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MNT299BOX ºAutor  ³Roger Rodrigues     º Data ³  03/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta tela para opcoes de Combo                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MNTA299                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNT299BOX()
	Local lRet := .f.
	Local nXX
	Local oChecked := LoadBitmap(GetResources(),'LBTIK')
	Local oUnCheck := LoadBitmap(GetResources(),'LBNO')
	Local aCodBox  := {	"1","2","3","4","5","6","7","8","9",;
	"A","B","C","D","E","F","G","H","I",;
	"J","K","L","M","N","O","P","Q","R",;
	"S","T","U","V","W","X","Y","Z" }

	Private oBoxPerg, aBoxPerg, bBoxPerg

	aBoxPerg := {}

	For nXX := 1 To Len(aCodBox)
		nPos := At( aCodBox[nXX]+"=" , M->TU3_COMBO )
		If nPos > 0
			nPos1 := At( ";" , Substr( M->TU3_COMBO , nPos+2 ) )
			cDesc := Alltrim(Substr( M->TU3_COMBO , nPos+2 ))
			If nPos1 > 0
				cDesc := Alltrim(Substr( M->TU3_COMBO , nPos+2 , nPos1-1 ))
			Endif
			aAdd( aBoxPerg , { .T. , aCodBox[nXX] , PadR(cDesc,30) } )
		Else
			aAdd( aBoxPerg , { .F. , aCodBox[nXX] , Space(30) } )
		Endif
	Next nXX

	opcaoZZ  := 0

	DEFINE MSDIALOG oDlg1 TITLE OemToAnsi(STR0030) from 10,15 To 30,70 COLOR CLR_BLACK,CLR_WHITE of oMainwnd //"Editar Lista de Opções"

	@ 05,9  SAY STR0031 OF oDlg1 Pixel //"Configure a lista de opções:"
	oBoxPerg := VCBrowse():New( 17 , 010, 200, 110,,{' ',STR0032,STR0033},{10,20,130},; //"Opção" # "Descrição"
	oDlg1,,,,,{||},,,,,,,.F.,,.T.,,.F.,,.t.,.t.)
	oBoxPerg:SetArray(aBoxPerg)
	bBoxPerg := { || { If(aBoxPerg[oBoxPerg:nAt,1],oChecked,oUnCheck), aBoxPerg[oBoxPerg:nAt,2], aBoxPerg[oBoxPerg:nAt,3] } }
	oBoxPerg:bLine:= bBoxPerg
	oBoxPerg:bLDblClick := {|| fMarkOpca(oBoxPerg:nColPos) }

	DEFINE SBUTTON FROM 135,155 TYPE 1 ENABLE OF oDlg1 ACTION ( If( fValCombo(), (opcaoZZ := 1,oDlg1:End()) , opcaoZZ := 0))
	DEFINE SBUTTON FROM 135,185 TYPE 2 ENABLE OF oDlg1 ACTION oDlg1:END()

	ACTIVATE MSDIALOG oDlg1 CENTERED

Return (opcaoZZ == 1)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fMarkOpca ³ Autor ³Roger Rodrigues        ³ Data ³ 03/01/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para marcar ou desmarcar as opções                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fMarkOpca(nColuna,lOnlyOne)
	Local nAntes3, i
	Default lOnlyOne := .F.

	If !lOnlyOne
		If !aBoxPerg[oBoxPerg:nAt][1]
			nAntes3 := aBoxPerg[oBoxPerg:nAt][3]
			lEditCell(@aBoxPerg,oBoxPerg,"",3)
			If !Empty(aBoxPerg[oBoxPerg:nAt][3])
				If "=" $ aBoxPerg[oBoxPerg:nAt][3] .or. ";" $ aBoxPerg[oBoxPerg:nAt][3]
					aBoxPerg[oBoxPerg:nAt][3] := nAntes3
					MsgInfo(STR0034) //"Os seguintes caracteres não poderão ser utilizados: = (sinal de igualdade) ou ; (ponto e virgula)"
					Return .F.
				Endif
				//Se o parametro for informado corretamente, a listbox é atualizada
				aBoxPerg[oBoxPerg:nAt][1] := .t.
				aBoxPerg[oBoxPerg:nAt][3] := PadR(aBoxPerg[oBoxPerg:nAt][3],30)
				oBoxPerg:Refresh()
			Else
				aBoxPerg[oBoxPerg:nAt][1] := .f.
				aBoxPerg[oBoxPerg:nAt][3] := Space(30)
				oBoxPerg:Refresh()
			Endif
		Else
			//Caso o usuario desmarque o checkbox
			aBoxPerg[oBoxPerg:nAt][1] := .f.
			aBoxPerg[oBoxPerg:nAt][3] := Space(30)
			oBoxPerg:Refresh()
		Endif
	Else
		For i:=1 to Len(aBoxPerg)
			If i == oBoxPerg:nAt
				If !aBoxPerg[oBoxPerg:nAt][1]
					aBoxPerg[oBoxPerg:nAt][1] := .T.
				Else
					aBoxPerg[oBoxPerg:nAt][1] := .F.
				Endif
			Else
				aBoxPerg[i][1] := .f.
			Endif
		Next i
		oBoxPerg:Refresh()
	Endif

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fValCombo³ Autor ³Roger Rodrigues        ³ Data ³ 03/01/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para validar a confirmação da tela                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fValCombo()
	Local nXX, nPos
	Local cCombo := "", cPergOp := "", cOpcCombo := ""
	Local aArea  := GetArea()

	//Verifica se algum item filho utiliza a opcao
	If !Inclui
		dbSelectArea(cAlias299)
		dbSetOrder(2)
		dbSeek(cCodNiv)
		While !eof() .and. (cAlias299)->TU3_NIVSUP == cCodNiv
			If Empty((cAlias299)->DELETADO)
				//Joga opcoes para verificacao posterior
				cPergOp := (cAlias299)->TU3_PERGOP
				While !Empty(cPergOp)
					nPos := At( ";" , cPergOp )
					If nPos > 0
						cOpcCombo := Substr(cPergOp,1,nPos-1)
						cPergOp   := Substr(cPergOp,nPos+1)
					Else
						cOpcCombo := cPergOp
						cPergOp   := ""
					Endif
					//Se nao encontrar opcao igual, preenchida e marcada
					If aScan(aBoxPerg, {|x| x[2] == cOpcCombo .and. !Empty(x[3]) .and. x[1]}) == 0
						ShowHelpDlg(STR0017,{STR0035+cOpcCombo+STR0036+; //"Atenção" # "A opção '" # "' não pode ser excluida, pois algum item, já relacionado a esta pergunta,"
						STR0037}) //" faz uso da mesma."
						RestArea(aArea)
						Return .F.
					Endif
					If Empty(cPergOp)
						Exit
					Endif
				End
			Endif
			dbSelectArea(cAlias299)
			dbSkip()
		End
	Endif
	RestArea(aArea)

	For nXX := 1 To Len(aBoxPerg)
		If aBoxPerg[nXX,1] .and. !Empty(aBoxPerg[nXX,3])
			If !Empty(cCombo)
				cCombo += ";"
			Endif
			cCombo += aBoxPerg[nXX,2] + "=" + Alltrim(Substr(aBoxPerg[nXX,3],1,30))
		Endif
	Next nXX

	If Len(cCombo) > 250
		MsgInfo(STR0038) //"A quantidade de caracteres no campo Editar Opc. ultrapassou 250."
		Return .f.
	ElseIf Empty(cCombo)
		cCombo := "1="+STR0039+";"+"2="+STR0040 //"Sim" # "Nao"
		MsgInfo(STR0041) //"Nenhum item foi selecionado, portanto, serão consideradas as opções padrão (Sim e Não)."
	Endif

	M->TU3_COMBO  := PadR(cCombo,250)

Return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fChooseOpcºAutor  ³Roger Rodrigues     º Data ³  03/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta tela para opcoes de Combo                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MNTA299                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fChooseOpc(cNivSup,lMark)
	Local lRet := .f.
	Local nXX
	Local nPos, nPos1
	Local oChecked := LoadBitmap(GetResources(),"LBTIK")
	Local oUnCheck := LoadBitmap(GetResources(),"LBNO")
	Local cCombo   := "", cDesc := "", cOpcMark := ""
	Local cReturn  := ""
	Default lMark  := .T.
	Private oBoxPerg, aBoxPerg, bBoxPerg

	dbSelectArea(cAlias299)
	dbSetOrder(1)
	dbSeek(cNivSup)

	cCombo   := (cAlias299)->TU3_COMBO
	lUnico   := ((cAlias299)->TU3_TPLIST == "1")
	If !lMark
		cOpcMark := M->TU3_PERGOP
	Endif

	aBoxPerg := {}

	While !Empty(cCombo)
		nPos := At( ";" , cCombo )
		If nPos > 0
			cDesc := Substr(cCombo,1,nPos-1)
			cCombo:= Substr(cCombo,nPos+1)
		Else
			cDesc := cCombo
			cCombo:= ""
		Endif
		aAdd( aBoxPerg , { (At((Substr(cDesc,1,1)+";"),cOpcMark) > 0) , Substr(cDesc,1,1) , AllTrim(Substr(cDesc,3)) } )
	End

	DEFINE MSDIALOG oDlg1 TITLE OemToAnsi(STR0030) from 10,15 To 30,70 COLOR CLR_BLACK,CLR_WHITE of oMainwnd //"Editar Lista de Opções"

	@ 05,9  SAY STR0042 OF oDlg1 Pixel //"Lista de opções:"
	oBoxPerg := VCBrowse():New( 17 , 010, 200, 110,,{' ',STR0032,STR0033},{10,20,130},; //"Opção" # "Descrição"
	oDlg1,,,,,{||},,,,,,,.F.,,.T.,,.F.,,.t.,.t.)
	oBoxPerg:SetArray(aBoxPerg)
	bBoxPerg := { || { If(aBoxPerg[oBoxPerg:nAt,1],oChecked,oUnCheck), aBoxPerg[oBoxPerg:nAt,2], aBoxPerg[oBoxPerg:nAt,3] } }
	oBoxPerg:bLine:= bBoxPerg
	oBoxPerg:bLDblClick := {|| fMarcaResp(lUnico) }

	DEFINE SBUTTON FROM 135,155 TYPE 1 ENABLE OF oDlg1 ACTION ((cReturn:=fRetOpc(cNivSup)),If(!Empty(cReturn),(lRet := .T.,oDlg1:End()) , lRet := .F.))
	DEFINE SBUTTON FROM 135,185 TYPE 2 ENABLE OF oDlg1 ACTION oDlg1:END()

	ACTIVATE MSDIALOG oDlg1 CENTERED

Return cReturn
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fMarcaResp³ Autor ³Roger Rodrigues        ³ Data ³ 03/01/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para marcar ou desmarcar as opções                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fMarcaResp(lOnlyOne)
	Local i
	Default lOnlyOne := .F.

	If !lOnlyOne
		aBoxPerg[oBoxPerg:nAt][1] := !(aBoxPerg[oBoxPerg:nAt][1])
	Else
		For i:=1 to Len(aBoxPerg)
			If i == oBoxPerg:nAt
				aBoxPerg[oBoxPerg:nAt][1] := !(aBoxPerg[oBoxPerg:nAt][1])
			Else
				aBoxPerg[i][1] := .f.
			Endif
		Next i
	Endif

	oBoxPerg:Refresh()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fRetOpc   ºAutor  ³Roger Rodrigues     º Data ³  18/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna opcoes marcadas                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MNTA299                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fRetOpc(cNivSup)
	Local cMarcados := ""
	Local i
	Local lTu3Tipo := Type("M->TU3_TIPO") == "C"

	For i:=1 to Len(aBoxPerg)
		//Verifica se nao existe outro item utilizando a opcao
		If aBoxPerg[i][1]
			dbSelectArea(cAlias299)
			dbSetOrder(2)
			dbSeek(cNivSup)
			While !eof() .and. (cAlias299)->TU3_NIVSUP == cNivSup
				If At((aBoxPerg[i][2]+";"), (cAlias299)->TU3_PERGOP) > 0 .and. (cAlias299)->TU3_CODNIV != cCodNiv .and. Empty((cAlias299)->DELETADO)
					If (cAlias299)->TU3_TIPO == "4"
						ShowHelpDlg(STR0017,{STR0043+aBoxPerg[i][2]+STR0044}) //"Atenção" # "Não é possível selecionar a opção '" # "', pois já existe uma pergunta relacionada a mesma."
						Return .F.
					ElseIf lTu3Tipo .and. M->TU3_TIPO == "4"
						ShowHelpDlg(STR0017,{STR0043+aBoxPerg[i][2]+STR0045}) //"Atenção" # "Não é possível selecionar a opção '" # "', pois já existe outro tem relacionado a mesma."
						Return .F.
					Endif
				Endif
				dbSelectArea(cAlias299)
				dbSkip()
			End
		Endif
		If !Empty(aBoxPerg[i][3]) .and. aBoxPerg[i][1]
			cMarcados += aBoxPerg[i][2]+";"
		Endif
	Next i

	If Empty(cMarcados)
		ShowHelpDlg(STR0017,{STR0046},1) //"Atenção" # "Favor selecionar pelo menos uma opção."
	Else
		M->TU3_PERGOP := cMarcados
	Endif

Return cMarcados
