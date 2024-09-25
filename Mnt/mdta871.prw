#Include "Protheus.ch"
#Include "MDTA871.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA871
Cadastro de Certificado de Aprovação de Instalação

@return Nil

@sample MDTA871()

@author Bruno Lobo de Souza
@since 07/06/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDTA871()

	//-----------------------------------------------------------------
	// Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	//-----------------------------------------------------------------
	Local aNGBEGINPRM := NGBEGINPRM(  )

	//-----------------------------------------------------------------
	// Define Array contendo as Rotinas a executar do programa
	// ----------- Elementos contidos por dimensao ------------
	// 1. Nome a aparecer no cabecalho
	// 2. Nome da Rotina associada
	// 3. Usado pela rotina
	// 4. Tipo de Transa‡„o a ser efetuada
	//    1 - Pesquisa e Posiciona em um Banco de Dados
	//    2 - Simplesmente Mostra os Campos
	//    3 - Inclui registros no Bancos de Dados
	//    4 - Altera o registro corrente
	//    5 - Remove o registro corrente do Banco de Dados
	//-----------------------------------------------------------------
	Private aRotina := MenuDef()

	//-----------------------------------------------------------------
	// Definicoes Iniciais
	//-----------------------------------------------------------------
	Private cCadastro 	:= OemtoAnsi( STR0001 )
	Private aCHKDEL 	:= { } , bNGGRAVA

	//Verifica a aplicação do update.
	If !NGCADICBASE("TIE_CODDEL","A","TIE",.F.)
		If !NGINCOMPDIC("UPDMDT83","THZOIM")
			Return .F.
		EndIf
	EndIf

	//Abertura do Browse
	dbSelectArea("TIH")
	dbSetOrder(1)
	mBrowse( 6, 1,22,75,"TIH")

	//-----------------------------------------------------------------
	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	//-----------------------------------------------------------------
	NGRETURNPRM(aNGBEGINPRM)

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de Menu Funcional.

@return aRotina  - 	Array com as opções de menu.
					Parametros do array a Rotina:
					1. Nome a aparecer no cabecalho
					2. Nome da Rotina associada
					3. Reservado
					4. Tipo de Transa‡„o a ser efetuada:
						1 - Pesquisa e Posiciona em um Banco de Dados
						2 - Simplesmente Mostra os Campos
						3 - Inclui registros no Bancos de Dados
						4 - Altera o registro corrente
						5 - Remove o registro corrente do Banco de Dados
					5. Nivel de acesso
					6. Habilita Menu Funcional

@sample
MenuDef()

@author Bruno Lobo de Souza
@since 07/06/2013
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

Local aRotina

aRotina :=	{ 	{ STR0002 , "AxPesqui"	, 0 , 1		} , ;
				{ STR0003 , "MT871CRUD"	, 0 , 2		} , ;
				{ STR0004 , "MT871CRUD"	, 0 , 3		} , ;
				{ STR0005 , "MT871CRUD"	, 0 , 4		} , ;
				{ STR0006 , "MT871CRUD"	, 0 , 5	, 3	} , ;
				{ STR0030 , "MDT871IMP"	, 0 , 4		} , ;//"Imprimir"
				{ STR0007 , "MT871COPY"	, 0 , 4		} }

//Verifica se pode adicionar o banco de conhecimetno
lPyme := Iif(Type("__lPyme") <> "U",__lPyme,.F.)

If !lPyme
	AAdd( aRotina , { STR0008 , "MsDocument" , 0 , 4 } )
EndIf

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} MT871CRUD
Cadastro do CAI

@return Nil

@sample MT871CRUD( "XXX" , 0 , 3 )

@param cAliasX  - Indica o alias posicionado
@param nRecnoX  - Indica o recno posicionado
@param nOpcx	- Indica o tipo de transacao

@author Bruno Lobo de Souza
@since 07/06/2013
/*/
//---------------------------------------------------------------------
Function MT871CRUD( cAliasX , nRecnoX , nOpcX )

	Local nOpca	:= 0, nFor
	Local nRecno  := 0
	Local aSize	:= MsAdvSize()
	Local cMemo   := "", oMemo
	Local nWidth  := If( SetMdiChild() , aSize[ 5 ] -= 03 , aSize[ 5 ] )
	Local nHeight := If( !( Alltrim( GetTheme() ) == "FLAT" ) .And. !SetMdiChild() , aSize[ 6 ] - 30 , aSize[ 6 ] )
	Local lOpc	  	:= If(nOpcx == 2 .Or. nOpcx == 5, .F., .T.)
	Local aNao
	Local aPages  := {}
	Local aTitles := {}
	Local aCpoVal := {}
	Local aHeAmb, aCoAmb, aHeEqp, aCoEqp
	Local oDLGCAI, oPnlAll, oPnlFolder, oPnlCAI

	Private oGetAmb, oGetEqp
	Private nModel

	Private lActivate 	  := .F. , lLoad := .F.
	Private lEntra210	  := .F.
	Private aEspcMd		  := {}
	Private bInit
	Private aTELA[ 0 , 0 ] , aGETS[ 0 ]

	//Definicao dos campos que serao apresentados na tela
	aNao	 := { }
	aMGetTIH := NGCAMPNSX3( "TIH" , aNao )

	//Definicioes das variaveis de memoria
	nRecno := TIH->(Recno())
	dbSelectArea( "TIH" )
	RegToMemory( "TIH" , Inclui )

	//Definicoes dos folders
	aAdd( aTitles	, OemToAnsi( STR0009 )	)
	aAdd( aTitles	, OemToAnsi( STR0010 )	)
	aAdd( aPages	, "Header 1"			)
	aAdd( aPages	, "Header 2"			)

	//Monta os aCols e aHeaders
	fMontaGet( "TII" , 1 , @aCoAmb , @aHeAmb , nOpcx )
	fMontaGet( "TIJ" , 1 , @aCoEqp , @aHeEqp , nOpcx )

	//Adiciona campos obrigatórios para verificação
	aAdd(aCpoVal,"TIH_CODCAI")
	aAdd(aCpoVal,"TIH_DESCAI")
	aAdd(aCpoVal,"TIH_CODDEL")
	aAdd(aCpoVal,"TIH_CNAE")

	DEFINE MSDIALOG oDLGCAI TITLE OemToAnsi( cCadastro ) FROM 0 , 0 TO nHeight , nWidth COLOR CLR_BLACK , CLR_WHITE OF oMainWnd Pixel

		oDLGCAI:lMaximized := .T.
		oDLGCAI:lEscClose  := .F.//Desabilita saida por ESC

		//TPanel que abrange toda a Dialog
		oPnlAll := TPanel():New(0, 0, Nil, oDLGCAI, Nil, .T., .F., Nil, Nil, 0, 0, .T., .F. )
		oPnlAll:Align := CONTROL_ALIGN_ALLCLIENT

	    //TPanel para o cadastro de CAI
	    oPnlCAI   := TPanel():New(0, 0, Nil, oPnlAll, Nil, .T., .F., Nil, Nil, 0, 150, .T., .F. )
		oPnlCAI:Align := CONTROL_ALIGN_TOP

		//TPanel para o TFolder
		oPnlFolder   := TPanel():New(0, 0, Nil, oPnlAll, Nil, .T., .F., Nil, Nil, 0, 300, .T., .F. )
		oPnlFolder:Align := CONTROL_ALIGN_ALLCLIENT

		//Campos do CAI

		TSay():New(005,006,{||STR0011} ,oPnlCAI,,,,,,.T.,CLR_HBLUE,CLR_WHITE,200,20)
		@ 003,036 MsGet oMsGet Var M->TIH_CODCAI Picture "@!" Valid &(X3VALID("TIH_CODCAI")) SIZE 096,009 Of oPnlCAI When If(nOpcx == 4,.F.,lOpc) Pixel

		TSay():New(005,0160,{||STR0012},oPnlCAI,,,,,,.T.,CLR_HBLUE,CLR_WHITE,200,20)
		@ 003,190 MsGet oMsGet Var M->TIH_DESCAI Picture "@!" SIZE 096,009 Of oPnlCAI When lOpc Pixel

		TSay():New(022,006,{||STR0013},oPnlCAI,,,,,,.T.,CLR_HBLUE,CLR_WHITE,200,20)
		@ 020,036 MsGet oMsGet Var M->TIH_CODDEL Picture "@!" Valid &(X3VALID("TIH_CODDEL")) SIZE 096,009 Of oPnlCAI When lOpc F3 "TIE" Pixel HASBUTTON
		@ 020,190 MsGet oMsGet Var NGSEEK("TIE",M->TIH_CODDEL,1,"TIE->TIE_NOME") Picture "@!"  SIZE 096,009 Of oPnlCAI When .F. Pixel

		TSay():New(022,314,{||STR0014},oPnlCAI,,,,,,.T.,CLR_HBLUE,CLR_WHITE,200,20)
		@ 020,344 MsGet oMsGet Var M->TIH_CNAE Picture "@!" Valid &(X3VALID("TIH_CNAE")) SIZE 096,009 Of oPnlCAI When lOpc F3 "TOE" Pixel HASBUTTON

		TSay():New(058,006,{||STR0015},oPnlCAI,,,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)

		TSay():New(070,006,{||STR0016},oPnlCAI,,,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
		@ 068,036 MsGet oMsGet Var M->TIH_MASMAI Picture PesqPict("TIH","TIH_MASMAI") SIZE 096,009 Of oPnlCAI When lOpc Pixel

		TSay():New(085,006,{||STR0017},oPnlCAI,,,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
		@ 083,036 MsGet oMsGet Var M->TIH_MASMEN Picture PesqPict("TIH","TIH_MASMEN") SIZE 096,009 Of oPnlCAI When lOpc Pixel

		TSay():New(058,160,{||STR0018},oPnlCAI,,,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)

		TSay():New(070,160,{||STR0016},oPnlCAI,,,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
		@ 068,190 MsGet oMsGet Var M->TIH_FEMMAI Picture PesqPict("TIH","TIH_FEMMAI") SIZE 096,009 Of oPnlCAI When lOpc Pixel

		TSay():New(085,160,{||STR0017},oPnlCAI,,,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
		@ 083,190 MsGet oMsGet Var M->TIH_FEMMEN Picture PesqPict("TIH","TIH_FEMMEN") SIZE 096,009 Of oPnlCAI When lOpc Pixel

		TSay():New(100,006,{||STR0019},oPnlCAI,,,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
		@ 098,036 MsGet oMsGet Var M->TIH_TERRES Picture "@!" Valid &(X3VALID("TIH_TERRES")) SIZE 096,009 Of oPnlCAI F3 "TMZ" When lOpc Pixel HASBUTTON

		TSay():New(100,160,{||STR0020},oPnlCAI,,,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
		@ 098,190 MsGet oMsGet Var M->TIH_PERMAX Picture PesqPict("TIH","TIH_PERMAX") SIZE 096,009 Of oPnlCAI When lOpc Pixel

		TSay():New(058,314,{||STR0021},oPnlCAI,,,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
		@ 068,314 Get oMemo Var M->TIH_INFONR MEMO SIZE 150,040 Of oPnlCAI When lOpc Pixel
		oMemo:bHelp := {|| ShowHelpCpo(STR0028,{STR0029},2,{},2)} //"Memo"

		M->TIH_QTDFUN := (M->TIH_MASMAI+M->TIH_MASMEN+M->TIH_FEMMAI+M->TIH_FEMMEN)

		//Cria o Folder
		oFolder 	  := TFolder():New( 1 , 0 , aTitles , aPages , oPnlFolder , , , , .F. , .F. , aSize[ 3 ] , aSize[ 4 ] , )
		oFolder:Align := CONTROL_ALIGN_ALLCLIENT

		//Folder 1 - GetDados de Ambientes fisicos
		oGetAmb := MsNewGetDados():New(15 , 010, 125, 285,IIF(!INCLUI .and. !ALTERA,0,GD_INSERT+GD_UPDATE+GD_DELETE),;
								{|| fValidOk( oGetAmb, "1", @nOpca ) },{|| .T. },,,,9999,,,,oFolder:aDialogs[ 1 ] ,aHeAmb,aCoAmb)
		oGetAmb:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

		//Folder 2 - GetDados de Equipamentos
		oGetEqp := MsNewGetDados():New(15 , 010, 125, 285,IIF(!INCLUI .and. !ALTERA,0,GD_INSERT+GD_UPDATE+GD_DELETE),;
								{|| fValidOk( oGetEqp , "2", @nOpca) },{|| .T. },,,,9999,,,,oFolder:aDialogs[ 2 ] ,aHeEqp,aCoEqp)
		oGetEqp:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE MSDIALOG oDlgCAI ON INIT EnchoiceBar( oDlgCAI, ;
				{ | | If( fTudoOk(oGetAmb,oGetEqp,@nOpca,aCpoVal) , oDlgCAI:End() , nOpca := 0 ) } , ;
				{ | | oDlgCAI:End() } ) CENTERED

	If nOpca == 1 .And. nOpcx <> 2
		Begin Transaction
			fGrava( nOpcx )
		End Transaction
	Endif

	dbSelectArea( "TIH" )

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fValidOk
Validação das linhas da GetDados

@author Bruno Lobo
@since 13/06/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fValidOk( oGet , cFolder, nOpca, lFim)

Local f
Local aColsOk := {}, aHeadOk := {}
Local nPosCod := 1, nPosTipo := 0, nAt := 1
Default lFim  := .F.

aColsOk := aClone(oGet:aCols)
aHeadOk := aClone(oGet:aHeader)
nAt 	:= oGet:nAt

If cFolder == "1"
	nAmbTII := aSCAN(aHeadOk,{|x| TRIM(UPPER(x[2])) == "TII_CODAMB"})
	nQuesti := aSCAN(aHeadOk,{|x| TRIM(UPPER(x[2])) == "TII_QUESTI"})
	nCodAmb := nAmbTII
	cAliasPut := "TII"
EndIf
If cFolder == "2"
	nAmbTIJ := aSCAN(aHeadOk,{|x| TRIM(UPPER(x[2])) == "TIJ_CODAMB"})
	nCodFam := aSCAN(aHeadOk,{|x| TRIM(UPPER(x[2])) == "TIJ_CODFAM"})
	nTipMod := aSCAN(aHeadOk,{|x| TRIM(UPPER(x[2])) == "TIJ_TIPMOD"})
	nCodAmb := nAmbTIJ
	cAliasPut := "TIJ"
EndIf

//Percorre aCols
For f:= 1 to Len(aColsOk)

	//Valida o folder de Ambiente Fisico
	If cFolder == "1"
		cAmbTII := aColsOk[f][nAmbTII]
		cQuesti := aColsOk[f][nQuesti]
		If !aColsOk[f][Len(aColsOk[f])]
			If lFim .or. f == nAt
				//VerIfica se os campos obrigatórios estão preenchidos
				If Empty(cAmbTII) .And. !Empty(cQuesti)
					//Mostra mensagem de Help
					Help(1," ","OBRIGAT2",,aHeadOk[nAmbTII][1],3,0)
					Return .F.
				Endif
			Endif
			//Verifica se é somente LinhaOk
			If f <> nAt .and. !aColsOk[nAt][Len(aColsOk[nAt])]
				If cAmbTII == aColsOk[nAt][nAmbTII] .And. cQuesti == aColsOk[nAt][nQuesti]
					Help(" ",1,"JAEXISTINF",,aHeadOk[nAmbTII][1]+" "+aHeadOk[nQuesti][1])
					Return .F.
				EndIf
			EndIf
		EndIf
	EndIf

	//Valida o folder de Equipamentos
	If cFolder == "2"
		cAmbTIJ := aColsOk[f][nAmbTIJ]
		cCodFam := aColsOk[f][nCodFam]
		cTipMod := aColsOk[f][nTipMod]
		If !aColsOk[f][Len(aColsOk[f])]
			If lFim .or. f == nAt
				//VerIfica se os campos obrigatórios estão preenchidos
				If Empty(cAmbTIJ) .And. (!Empty(cCodFam) .Or. !Empty(cTipMod))
					//Mostra mensagem de Help
					Help(1," ","OBRIGAT2",,aHeadOk[nAmbTIJ][1],3,0)
					Return .F.
				ElseIf Empty(cCodFam) .And. (!Empty(cAmbTIJ) .Or. !Empty(cTipMod))
					//Mostra mensagem de Help
					Help(1," ","OBRIGAT2",,aHeadOk[nCodFam][1],3,0)
					Return .F.
				ElseIf Empty(cTipMod) .And. (!Empty(cAmbTIJ) .Or. !Empty(cCodFam))
					//Mostra mensagem de Help
					Help(1," ","OBRIGAT2",,aHeadOk[nTipMod][1],3,0)
					Return .F.
				Endif
			Endif
			//Verifica se é somente LinhaOk
			If f <> nAt .and. !aColsOk[nAt][Len(aColsOk[nAt])]
				If cAmbTIJ == aColsOk[nAt][nAmbTIJ] .And. cCodFam == aColsOk[nAt][nCodFam] .And. cTipMod == aColsOk[nAt][nTipMod]
					Help(" ",1,"JAEXISTINF",,aHeadOk[nAmbTIJ][1]+" "+aHeadOk[nCodFam][1]+" "+aHeadOk[nTipMod][1])
					Return .F.
				EndIf
			EndIf
		EndIf
	EndIf
Next f

nOpca := 1

PutFileInEof(cAliasPut)
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fGrava
Efetua a gravacao da tabela TIH, TII e TIJ
CAI, Ambientes Inspecionados e CAI x Equipamentos respectivamente.

@return Nil

@sample fGrava( 3 )

@param nOpcx	- Indica o tipo de transacao

@author Bruno L. Souza
@since 11/06/2013
/*/
//---------------------------------------------------------------------
Static Function fGrava( nOpcx )

Local i, j, ny, nX //Contador de for
Local aArea := GetArea()
Local nOrd, cKey, cWhile
Local cCmpo	:= "" //Recebe o valor da variavel de memória

If nOpcx == 3 .or. nOpcx == 4//Caso inclusao ou alteracao

	//Reliza a inclusao/alteracao do laudo
	dbSelectArea("TIH")
	RecLock("TIH", ( nOpcx == 3 ) )//Caso seja diferente de inclusao, altera o registro posicionado
	For nx := 1 To FCount()//Percorre todos os campos
		cCmpo :=  + FieldName( nx )//Pega memória do campo
		//Campo de filial e descrição são tratados posteriormente
		If Alltrim( cCmpo ) <> "TIH_FILIAL"
			If TIH->( ColumnPos( cCmpo ) ) > 0 //&cCmpo != Nil //Verifica se nao é nula
				FieldPut( nx, &( "M->" + cCmpo ) )//Adiciona o valor da memória para o campo físico
			EndIf
		EndIf
	Next nx
	TIH->TIH_FILIAL := xFilial( "TIH" )//Trata a filial
	TIH->(MsUnLock())
	//Grava Memo
	MSMM(If(nOpcx == 4,TIH->TIH_MMSYP,Nil),,,M->TIH_INFONR,1,,,"TIH","TIH_MMSYP")

	EvalTrigger() // Processar Gatilhos

ElseIf nOpcx == 5 //Caso exclusao

	//Exclui o CAI
	dbSelectArea( "TIH" )
	RecLock( "TIH" , .F. )
	dbDelete()
	TIH->( MsUnLock() )

	MSMM(TIH->TIH_MMSYP,,,,2)

EndIf

nPosCod := aScan( oGetAmb:aHeader,{|x| Trim(Upper(x[2])) == "TII_CODAMB"})
nOrd 	:= 1
cKey 	:= xFilial("TII")+M->TIH_CODCAI
cWhile:= "xFilial('TII')+M->TIH_CODCAI == TII->TII_FILIAL+TII->TII_CODCAI"
If nOpcx == 5
	dbSelectArea("TII")
	dbSetOrder(nOrd)
	dbSeek(cKey)
	While !Eof() .and. &(cWhile)
		RecLock("TII",.F.)
		DbDelete()
		MsUnLock("TII")
		dbSelectArea("TII")
		dbSkip()
	End
Else
	If Len(oGetAmb:aCols) > 0
		//Coloca os deletados por primeiro
		aSORT(oGetAmb:aCols,,, { |x, y| x[Len(oGetAmb:aCols[1])] .and. !y[Len(oGetAmb:aCols[1])] } )

		For i:=1 to Len(oGetAmb:aCols)
			If !oGetAmb:aCols[i][Len(oGetAmb:aCols[i])] .and. !Empty(oGetAmb:aCols[i][nPosCod])
				dbSelectArea("TII")
				dbSetOrder(nOrd)
				If dbSeek(xFilial("TII")+M->TIH_CODCAI+oGetAmb:aCols[i][nPosCod])
					RecLock("TII",.F.)
				Else
					RecLock("TII",.T.)
				Endif
				For j:=1 to FCount()
					If "_FILIAL"$Upper(FieldName(j))
						FieldPut(j, xFilial("TII"))
					ElseIf "_CODCAI"$Upper(FieldName(j))
						FieldPut(j, M->TIH_CODCAI)
					ElseIf (nPos := aScan(oGetAmb:aHeader, {|x| Trim(Upper(x[2])) == Trim(Upper(FieldName(j))) }) ) > 0
						FieldPut(j, oGetAmb:aCols[i][nPos])
					Endif
				Next j
				MsUnlock("TII")
			Elseif !Empty(oGetAmb:aCols[i][nPosCod])
				dbSelectArea("TII")
				dbSetOrder(nOrd)
				If dbSeek(xFilial("TII")+M->TIH_CODCAI+oGetAmb:aCols[i][nPosCod])
					RecLock("TII",.F.)
					dbDelete()
					MsUnlock("TII")
				Endif
			Endif
		Next i
	Endif
	dbSelectArea("TII")
	dbSetOrder(nOrd)
	dbSeek(cKey)
	While !Eof() .and. &(cWhile)
		If aScan( oGetAmb:aCols,{|x| x[nPosCod] == TII->TII_CODAMB .AND. !x[Len(x)]}) == 0
			RecLock("TII",.f.)
			DbDelete()
			MsUnLock("TII")
		Endif
		dbSelectArea("TII")
		dbSkip()
	End
Endif

nPosCod := aScan( oGetEqp:aHeader,{|x| Trim(Upper(x[2])) == "TIJ_CODAMB"})
nPosFam := aScan( oGetEqp:aHeader,{|x| Trim(Upper(x[2])) == "TIJ_CODFAM"})
nOrd 	:= 1
cKey 	:= xFilial("TIJ")+M->TIH_CODCAI
cWhile:= "xFilial('TIJ')+M->TIH_CODCAI == TIJ->TIJ_FILIAL+TIJ->TIJ_CODCAI"

If nOpcx == 5
	dbSelectArea("TIJ")
	dbSetOrder(nOrd)
	dbSeek(cKey)
	While !Eof() .and. &(cWhile)
		RecLock("TIJ",.F.)
		DbDelete()
		MsUnLock("TIJ")
		dbSelectArea("TIJ")
		dbSkip()
	End
Else
	If Len(oGetEqp:aCols) > 0
		//Coloca os deletados por primeiro
		aSORT(oGetEqp:aCols,,, { |x, y| x[Len(oGetEqp:aCols[1])] .and. !y[Len(oGetEqp:aCols[1])] } )

		For i := 1 to Len(oGetEqp:aCols)
			If !oGetEqp:aCols[i][Len(oGetEqp:aCols[i])] .and. !Empty(oGetEqp:aCols[i][nPosCod]) .and. !Empty(oGetEqp:aCols[i][nPosFam])

				dbSelectArea("TII")
				dbSetOrder(nOrd)
				If !dbSeek(xFilial("TII")+M->TIH_CODCAI+oGetEqp:aCols[i][nPosCod])
					dbSelectArea("TIJ")
					dbSetOrder(nOrd)
					If dbSeek(xFilial("TIJ")+M->TIH_CODCAI+oGetEqp:aCols[i][nPosCod]+oGetEqp:aCols[i][nPosFam])
						RecLock("TIJ",.F.)
						DbDelete()
						MsUnLock("TIJ")
					EndIf
					Loop
				EndIf

				dbSelectArea("TIJ")
				dbSetOrder(nOrd)
				If dbSeek(xFilial("TIJ")+M->TIH_CODCAI+oGetEqp:aCols[i][nPosCod]+oGetEqp:aCols[i][nPosFam])
					RecLock("TIJ",.F.)
				Else
					RecLock("TIJ",.T.)
				Endif
				For j:=1 to FCount()
					If "_FILIAL"$Upper(FieldName(j))
						FieldPut(j, xFilial("TIJ"))
					ElseIf "_CODCAI"$Upper(FieldName(j))
						FieldPut(j, M->TIH_CODCAI)
					ElseIf (nPos := aScan(oGetEqp:aHeader, {|x| Trim(Upper(x[2])) == Trim(Upper(FieldName(j))) }) ) > 0
						FieldPut(j,oGetEqp:aCols[i][nPos])
					Endif
				Next j
				MsUnlock("TIJ")
			Elseif !Empty(oGetEqp:aCols[i][nPosCod]) .and. !Empty(oGetEqp:aCols[i][nPosFam])
				dbSelectArea("TIJ")
				dbSetOrder(nOrd)
				If dbSeek(xFilial("TIJ")+M->TIH_CODCAI+oGetEqp:aCols[i][nPosCod]+oGetEqp:aCols[i][nPosFam])
					RecLock("TIJ",.F.)
					dbDelete()
					MsUnlock("TIJ")
				Endif
			Endif
		Next i
	Endif
	dbSelectArea("TIJ")
	dbSetOrder(nOrd)
	dbSeek(cKey)
	While !Eof() .and. &(cWhile)
		If aScan( oGetEqp:aCols,{|x| x[nPosCod] == TIJ->TIJ_CODAMB .AND. x[nPosFam] == TIJ->TIJ_CODFAM .AND. !x[Len(x)]}) == 0
			RecLock("TIJ",.F.)
			DbDelete()
			MsUnLock("TIJ")
		Endif
		dbSelectArea("TIJ")
		dbSkip()
	End
EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MT871COPY
Copia um CAI ja existente,
sendo obrigatorio a alteração do codigo do CAI

@return Nil

@sample MT871COPY()

@author Bruno L. Souza
@since 11/06/2013
/*/
//---------------------------------------------------------------------
Function MT871COPY()

 	Local i				:= 0
	Local nOpcc 		:= 0
	Local cCodigo		:= space(12)
	Local cDescricao	:= TIH->TIH_DESCAI
	Local cTIH_CODCAI	:= TIH->TIH_CODCAI
	Local cTIH_DESCAI	:= TIH->TIH_DESCAI
	Local oDlg2
	Local oPnlCopy

	//Monta a tela de copia
	DEFINE MSDIALOG oDlg2 TITLE OemToAnsi( STR0022 ) From 0,0 To 250,550 OF oMainWnd PIXEL

	    oPnlCopy := TPanel():New(0, 0, Nil, oDlg2, Nil, .T., .F., Nil, Nil, 0, 0, .T., .F. )
		oPnlCopy:Align := CONTROL_ALIGN_ALLCLIENT

		//CAI Modelo
		@ 05,05 TO 042,273 LABEL STR0023 OF oPnlCopy PIXEL
		@ 12,10  SAY OemToAnsi( STR0011 ) OF oPnlCopy PIXEL
		@ 12,40  MSGET cTIH_CODCAI Picture "@!" Size 42,08 When .F. OF oPnlCopy PIXEL
		@ 28,10  SAY OemToAnsi( STR0012 ) OF oPnlCopy PIXEL
		@ 28,40  MSGET cTIH_DESCAI Picture "@!" Size 220,08 When .F. OF oPnlCopy PIXEL

		//Novo CAI
		@ 50,05 TO 088,273 LABEL STR0024 OF oPnlCopy PIXEL
		@ 57,10  SAY OemToAnsi( STR0011 ) OF oPnlCopy PIXEL
		@ 57,40  MSGET cCodigo Picture "@!" Size 42,08 Valid fValCpyCAI(cCodigo,TIH->TIH_CODCAI) When .T. OF oPnlCopy PIXEL
		@ 73,10  SAY OemToAnsi( STR0012 ) OF oPnlCopy PIXEL
		@ 73,40  MSGET cDescricao Picture "@!" SIZE 220,08 Valid NaoVazio( cDescricao ) WHEN .T. OF oPnlCopy PIXEL

	ACTIVATE MSDIALOG oDlg2 ON INIT EnchoiceBar( oDlg2 , { | | nOpcc := 1 , oDlg2:End() } , { | | oDlg2:End() } ) CENTERED

	If nOpcc = 1//Se for confirmada a operação

		//Alimente variaveis de memória com o valor do CAI Modelo
		Dbselectarea( "TIH" )
		For i := 1 TO FCount()
			x   := "M->" + FieldName( i )
			y   := "TIH->" + FieldName( i )
			&x 	:= &y
		Next i

		//Cria um novo registro para o novo laudo
		RecLock( "TIH" , .T. )
		TIH->TIH_FILIAL := xFilial( "TIH" )
		TIH->TIH_CODCAI := cCodigo
		TIH->TIH_DESCAI := cDescricao

		//Percorre todos os campos da tabela, alimentando a base com a memória

		For i := 1 TO FCount()
			//Filial, Nome, Laudo e MMSYP2 são tratados em separado
			If 	FieldName( i ) == "TIH_FILIAL" 	.OR. ;
				FieldName( i ) == "TIH_CODCAI" 	.OR. ;
				FieldName( i ) == "TIH_DESCAI"

				Loop
			EndIf
			x   := "M->" + FieldName( i )
			y   := "TIH->" + FieldName( i )
			&y := &x
		Next i

		Msunlock( "TIH" )

	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fMontaGet
Realiza a construção da GetDados

@sample fMontaGet( "TIJ" , 1 , @aCoEqp , @aHeEqp , nOpcx )

@author Bruno L. Souza
@since 12/06/2013
/*/
//---------------------------------------------------------------------

Static Function fMontaGet( cTabela , nInd , aColsRet , aHeaderRet , nOpcx )

Local cKeyGet	:= ""
Local cWhileGet	:= ""
Local aNoFields	:= {}
Private aCols := {}, aHeader := {}

If cTabela == "TII"
	aAdd(aNoFields , "TII_FILIAL" )
	aAdd(aNoFields , "TII_CODCAI" )

	cKeyGet   := "TIH->TIH_CODCAI"
	cWhileGet := "TII->TII_FILIAL == '"+xFilial("TII")+"' .AND. TII->TII_CODCAI == '"+TIH->TIH_CODCAI+"'"
ElseIf cTabela == "TIJ"
	aAdd(aNoFields , "TIJ_FILIAL" )
	aAdd(aNoFields , "TIJ_CODCAI" )

	cKeyGet   := "TIH->TIH_CODCAI"
	cWhileGet := "TIJ->TIJ_FILIAL == '"+xFilial("TIJ")+"' .AND. TIJ->TIJ_CODCAI == '"+TIH->TIH_CODCAI+"'"
 	EndIf

 //Monta aCols e aHeader de TII/TIJ
dbSelectArea( cTabela )
dbSetOrder( nInd )
FillGetDados( nOpcx , cTabela , 1 , cKeyGet , { | | } , { | | .T. } , aNoFields , , , , ;
					{ | | NGMontaAcols( cTabela , &cKeyGet , cWhileGet ) } )
If Empty( aCols ) .Or. nOpcx == 3
	aCols := BLANKGETD( aHeader )
Endif

aHeaderRet	:= aClone( aHeader )
aColsRet	:= aClone( aCols )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fTudoOk
Chama Validação na confirmação da tela.

@aParam oObj1 - Objeto da GetDados
		oObj2 - Objeto da GetDados

@sample fTudoOk( oGetAmb , oGetEqp)

@author Bruno L. Souza
@since 13/06/2013
/*/
//---------------------------------------------------------------------
Static Function fTudoOk( oObj1 , oObj2, nOpca , aCpoVal)
Local lRet

lRet := fValObriga(aCpoVal)
If lRet
	lRet := fValidOK( oObj1 , "1" , @nOpca , .T. ) .And. fValidOk( oObj2 , "2" , @nOpca , .T. )
EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT871SXB
Filtro da Consulta SXB

@sample MDT871SXB()

@author Bruno L. Souza
@since 13/06/2013
/*/
//---------------------------------------------------------------------
Function MDT871SXB(cCodAmb)

Local nPosAmb	:= 0
Local aColsVal	:= aClone( oGetAmb:aCols )
Local aHeadVal	:= aClone( oGetAmb:aHeader )

Default cCodAmb := TNE->TNE_CODAMB

nPosAmb := aScan( aHeadVal , { | x | AllTrim( Upper( x[ 2 ] ) ) == "TII_CODAMB" } )

Return aScan( aColsVal , { | x | x[ nPosAmb ] == cCodAmb .And. !x[ Len( x ) ] } ) > 0

//---------------------------------------------------------------------
/*/{Protheus.doc} fValCpyCAI
Validação do CAI

@sample fValCpyCAI(cCodigo,cCodGrv)

@author Bruno L. Souza
@since 13/06/2013
/*/
//---------------------------------------------------------------------
Static Function fValCpyCAI(cCodigo,cCodGrv)
If cCodGrv == cCodigo
	HELP(" ",1,"JAGRAVADO")
	return .F.
EndIf
If ExistChav("TIH",cCodigo).AND. NaoVazio(cCodigo)
	Return .T.
EndIf

Return .F.

//---------------------------------------------------------------------
/*/{Protheus.doc} fValObriga
Validação dos campos obrigatórios

@sample fValObriga(cCampo)

@author Bruno L. Souza
@since 13/06/2013
/*/
//---------------------------------------------------------------------
Static Function fValObriga(xCampo)
Local nX
Local lRet := .T.
aArea := GetArea()
dbSelectArea("SX3")
dbSetOrder(2)
If ValType(xCampo) == "A"
	For nX := 1 To Len(xCampo)
		If Empty(M->&(xCampo[nX]))
			dbSeek(xCampo[nX])
			Help(1," ","OBRIGAT2",,x3titulo(xCampo[nX]),3,0)
			lRet := .F.
			Exit
		EndIf
		If nX == 1
			lRet := ExistChav("TIH",M->&(xCampo[nX]))
		EndIf
	Next nX
EndIf
RestArea(aArea)
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT871IMP
Função para imprimir relatório.

@return
@sample
@author Jean Pytter da Costa
@since 04/04/2014
/*/
//---------------------------------------------------------------------
Function MDT871IMP()

Local aAreaTIH := TIH->(GetArea())
cPerg := "MDT935"

MDTR935()

RestArea(aAreaTIH)
Return