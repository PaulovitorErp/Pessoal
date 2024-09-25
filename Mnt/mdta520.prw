#Include "Protheus.ch"
#INCLUDE "MDTA520.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA520
Programa de Cadastro de Vacinas

@return Lógico Sempre verdadeiro

@sample MDTA520()

@author Ricardo Dal Ponte
@since 13/10/2006
/*/
//---------------------------------------------------------------------
Function MDTA520()

	//------------------------------------------------------
	// Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	//------------------------------------------------------
	Local aNGBEGINPRM		:= NGBEGINPRM( )
	Private lSigaMdtPS	:= If( SuperGetMv( "MV_MDTPS" , .F. , "N" ) == "S" , .T. , .F. )

	//------------------------------------------------------
	// Define o cabecalho da tela de atualizacoes
	//------------------------------------------------------
	PRIVATE cCadastro
	PRIVATE aRotina
	PRIVATE aCHKDEL	:= {}, bNGGRAVA
	PRIVATE aMemos	:= {}

	If AMiIn( 35 ) // Somente autorizado para SIGAMDT
		//----------------------------------------------------------------
		// aCHKDEL array que verifica a INTEGRIDADE REFERENCIAL na exclu-
		// s„o do registro.
		//
		// 1 - Chave de pesquisa
		// 2 - Alias de pesquisa
		// 3 - Ordem de pesquisa
		//----------------------------------------------------------------
		aCHKDEL :=	{ { "TL6->TL6_VACINA" , "TL9" , 3 } , ;
					  { "TL6->TL6_VACINA" , "TL7" , 1 } }

		If FindFunction( "MDTRESTRI" ) .AND. MDTRESTRI( cPrograma )
			//-----------------------------------
			// Endereca a funcao de BROWSE
			//-----------------------------------

			aRotina := MenuDef()

			If lSigaMdtPS
				cCadastro := OemtoAnsi( STR0012 )  //"Clientes" //"Clientes"

				dbSelectArea( "SA1" )
				dbSetOrder( 1 )
				mBrowse( 6 , 1 , 22 , 75 , "SA1" )
			Else
				cCadastro := OemtoAnsi( STR0006 )  //"Vacinas"

				dbSelectArea( "TL6" )
				dbSetOrder( 1 )
				mBrowse( 6 , 1 , 22 , 75 , "TL6" )
			Endif

		Endif
	EndIf
	//------------------------------------------------------
	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	//------------------------------------------------------
	NGRETURNPRM( aNGBEGINPRM )

Return .T.
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

@author Rafael Diogo Richter
@since 29/11/2006
/*/
//---------------------------------------------------------------------
Static Function MenuDef( lMdtPs , lOld )

	Local lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )

	Default lMdtPs	:= lSigaMdtPs
	Default lOld		:= .F.

	If lMdtPs
		aRotina :=	{	{ STR0001 , "AxPesqui" , 0 , 1 } , ;  //"Pesquisar"
						{ STR0002 , "MDTA520IN" , 0 , 2 } , ;  //"Visualizar"
						{ STR0006 , "MDTA520MD" , 0 , 4 } }  //"Vacinas"
	Else
		aRotina :=	{	{ STR0001 , "AxPesqui" , 0 , 1 } , ;  //"Pesquisar"
						{ STR0002 , "MDTA520IN" , 0 , 2 } , ;  //"Visualizar"
		              { STR0003 , "MDTA520IN" , 0 , 3 } , ;  //"Incluir"
		              { STR0004 , "MDTA520IN" , 0 , 4 } , ;  //"Alterar"
		              { STR0005 , "MDTA520IN" , 0 , 5 , 3 } }  //"Excluir"
	Endif

Return aRotina
//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA520MD
Monta um browse com as vacinas por cliente

@return Nulo

@sample MDTA520MD()

@author Jackson Machado
@since 22/02/2011
/*/
//---------------------------------------------------------------------
Function MDTA520MD()

	Local aArea	:= GetArea()
	Local oldROTINA := aCLONE(aROTINA)
	Local oldCad := cCadastro
	Private bNGGRAVA

	cCliMdtPs	:= SA1->A1_COD+SA1->A1_LOJA
	cCadastro	:= OemtoAnsi( STR0006 )  //"Vacinas"
	aRotina	:= MenuDef( .F. )

	//Montagem do Browse
	dbSelectArea( "TL6" )
	dbSetOrder( 3 )
	Set Filter To TL6->( TL6_CLIENT + TL6_LOJA ) == cCliMdtps
	mBrowse( 6 , 1 , 22 , 75 , "TL6" )

	aRotina	:= aCLONE( oldRotina )
	cCadastro	:= oldCad
	Set Filter To
	RestArea( aArea )

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA520IN
Monta um browse com as vacinas por cliente

@return Logico Sempre verdadeiro

@param cAlias Caracter Alias do arquivo
@param nRecno Numerico Numero do registro
@param nOpcx  Boolean Opcao selecionada no menu

@sample MDTA520IN( 'TL6' , 0 , 3 )

@author Jackson Machado
@since 22/02/2011
/*/
//---------------------------------------------------------------------
Function MDTA520IN( cAlias , nRecno , nOpcx )

	Local nX, nX2
	Local nOpca		:= 0
	Local nControl	:= 0
	Local cSexo
	Local cCadOpt		:= ""
	Local lAltProg	:= .T.
	Local aPages		:= {}
	Local aTitles		:= {}
	Local oDlg
	Local oPnlPai, oPanel, oPnlBtn, oEnc01, oBtnImp

	Private aCols
	Private aCoBrwA := {}
	Private aHoBrwA := {}
	Private aCoBrwB := {}
	Private aHoBrwB := {}
	Private aCoBrwC := {}
	Private aHoBrwC := {}
	Private lAltInd  := .T.
	Private aSvATela := {} , aSvAGets := {} , aTela := {} , aGets := {} , aNao := {}
	Private aNoFields
	Private oBrwA, oBrwB, oBrwC
	Private oFolder

	//Tamanho da tela
	Private aAC := { STR0013 , STR0014}//"Abandona"###"Confirma" //"Abandona"###"Confirma"
	Private aCRA:= { STR0014 , STR0015 , STR0013 }//"Confirma"###"Redigita"###"Abandona" //"Confirma"###"Redigita"###"Abandona"
	Private aHeader[0] , Continua , nUsado := 0
	Private aSize := MsAdvSize( , .F. , 430 ) , aObjects := {}
	aAdd( aObjects , { 200 , 200 , .T. , .F. } )
	aInfo := { aSize[ 1 ] , aSize[ 2 ] , aSize[ 3 ] , aSize[ 4 ] , 0 , 0 }
	aPosObj := MsObjSize( aInfo , aObjects , .T. )

	dbSelectArea( "TL6" )
	RegToMemory( "TL6" , ( nOpcx == 3 ) )

	//----------------------------------------------------
	// Inicio das Montagens das informações das GetDados
	//----------------------------------------------------

	//Montagem dos campos da tabela TKF
	aCols		:={}
	aHeader	:={}
	aNoFields	:={}

	aAdd( aNoFields , "TKF_FILIAL" )
	aAdd( aNoFields , "TKF_CODVAC" )
	aAdd( aNoFields , "TKF_NOMVAC" )

	If lSigaMdtps
		aAdd( aNoFields , "TKF_CLIENT" )
		aAdd( aNoFields , "TKF_LOJA" )
		nInd		:= 2
		cKeyTPY	:="SA1->A1_COD+SA1->A1_LOJA+TL6->TL6_VACINA"
		cGETWHTPB	:= "TKF->TKF_FILIAL == '" + xFilial( "TKF" ) + "' .AND. TKF->TKF_CLIENT == '" + SA1->A1_COD + "'" + ;
						" .AND. TKF->TKF_LOJA == '" + SA1->A1_LOJA + "' .AND. TKF->TKF_CODVAC == '" + TL6->TL6_VACINA + "'"
	Else
		nInd		:= 1
		cKeyTPY	:= "TL6->TL6_VACINA"
		cGETWHTPB	:= "TKF->TKF_FILIAL == '" + xFilial( "TKF" ) + "' .AND. TKF->TKF_CODVAC == '" + TL6->TL6_VACINA + "'"
	Endif

	dbSelectArea( "TKF" )
	dbSetOrder( nInd )
	FillGetDados( nOpcx , "TKF" , nInd , cKeyTPY , { | | } , { | | .T. } , aNoFields , , , , ;
					{ | | NGMontaACols( "TKF" , &cKeyTPY , cGETWHTPB ) } )

	If Empty( aCols ) .Or. nOpcx == 3
		aCols := BlankGetD( aHeader )
	Endif
	aCoBrwA := aClone( aCols )
	aHoBrwA := aClone( aHeader )

	//Montagem dos campos da tabela TKG
	aCols		:={}
	aHeader	:={}
	aNoFields	:={}

	aAdd( aNoFields , "TKG_FILIAL" )
	aAdd( aNoFields , "TKG_CODVAC" )
	aAdd( aNoFields , "TKG_NOMVAC" )

	If lSigaMdtps
		aAdd( aNoFields , "TKG_CLIENT" )
		aAdd( aNoFields , "TKG_LOJA" )
		nInd		:= 2
		cKeyTPY	:= "SA1->A1_COD+SA1->A1_LOJA+TL6->TL6_VACINA"
		cGETWHTPB	:= "TKG->TKG_FILIAL == '" + xFilial( "TKG" ) + "' .AND. TKG->TKG_CLIENT == '" + SA1->A1_COD + "'" + ;
						" .AND. TKG->TKG_LOJA == '" + SA1->A1_LOJA + "' .AND. TKG->TKG_CODVAC == '" + TL6->TL6_VACINA + "'"
	Else
		nInd		:= 1
		cKeyTPY	:= "TL6->TL6_VACINA"
		cGETWHTPB	:= "TKG->TKG_FILIAL == '" + xFilial( "TKG" ) + "' .AND. TKG->TKG_CODVAC == '" + TL6->TL6_VACINA + "'"
	Endif
	dbSelectArea( "TKG" )
	dbSetOrder( nInd )
	FillGetDados( nOpcx , "TKG" , 1 , cKeyTPY , { | | } , { | | .T. } , aNoFields , , , , ;
					{ | | NGMontaACols( "TKG" , &cKeyTPY , cGETWHTPB ) } )

	If Empty( aCols ) .Or. nOpcx == 3
		aCols := BlankGetD( aHeader )
	Endif
	aCoBrwB := aClone(aCols)
	aHoBrwB := aClone(aHeader)

	//Montagem dos campos da tabela TKH
	aCols		:= {}
	aHeader	:= {}
	aNoFields	:= {}

	aAdd( aNoFields , "TKH_CODVAC" )
	aAdd( aNoFields , "TKH_NOMVAC" )
	aAdd( aNoFields , "TKH_FILIAL" )

	If lSigaMdtps
		aAdd( aNoFields , "TKH_CLIENT" )
		aAdd( aNoFields , "TKH_LOJACL" )
		nInd		:= 2
		cKeyTPY	:= "SA1->A1_COD+SA1->A1_LOJA+TL6->TL6_VACINA"
		cGETWHTPB	:= "TKH->TKH_FILIAL == '" + xFilial( "TKH" ) + "' .AND. TKH->TKH_CLIENT == '" + SA1->A1_COD + "'" + ;
						" .AND. TKH->TKH_LOJA == '" + SA1->A1_LOJA + "' .AND. TKH->TKH_CODVAC == '" + TL6->TL6_VACINA + "'"
	Else
		nInf		:= 1
		cKeyTPY	:="TL6->TL6_VACINA"
		cGETWHTPB	:= "TKH->TKH_FILIAL == '" + xFilial( "TKH" ) + "' .AND. TKH->TKH_CODVAC == '" + TL6->TL6_VACINA + "'"
	Endif
	dbSelectArea( "TKH" )
	dbSetOrder( nInd )
	FillGetDados( nOpcx , "TKH" , 1 , cKeyTPY , { | | } , { | | .T. } , aNoFields , , , , ;
					{ | | NGMontaACols( "TKH" , &cKeyTPY , cGETWHTPB ) } )
	If Empty(aCols) .Or. nOpcx == 3
		aCols := BlankGetD(aHeader)
	Endif
	aCoBrwC := aClone( aCols )
	aHoBrwC := aClone( aHeader )
	//----------------------------------------------------
	// Final das Montagens das informações das GetDados
	//----------------------------------------------------

	//Define se é uma operação de alteração de informações
	If nOpcx == 2 .or. nOpcx == 5
		lAltProg := .f.
	Endif

	//-----------------------------------------------------
	// Inicializa variaveis para campos Memos Virtuais
	//-----------------------------------------------------
	If Type( "aMemos" ) == "A"
		For nX2 := 1 To Len( aMemos )
			cMemo := "M->" + aMemos[ nX2 , 2 ]
			If ExistIni( aMemos[ nX2 , 2 ] )
				&cMemo := InitPad( GetSx3Cache( aMemos[ nX2 , 2 ]  , 'X3_RELACAO' ) )
			Else
				&cMemo := ""
			EndIf
		Next nX2
	EndIf

	//Define o Título da Janela
	If nOpcx == 3
		cCadOpt  := " - " + STR0003//" - Incluir"
	ElseIf nOpcx == 2
		cCadOpt  := " - " + STR0002//" - Visualizar"
		lAltInd := .f.
	ElseIf nOpcx == 5
		cCadOpt  := " - " + STR0005//" - Excluir"
		lAltInd := .f.
	ElseIf nOpcx == 4
		cCadOpt  := " - " + STR0004//" - Alterar"
	EndIf

	//aChoice recebe os campos que serao apresentados na tela
	aNao    := {}
	aChoice := NGCAMPNSX3( "TL6" , aNao )
	aTela   := {}
	aGets   := {}

	//Criando Folders
	aAdd( aTitles , OemToAnsi( STR0016 ) ) //"Centro de Custo" //"Centro de Custo"
	aAdd( aTitles , OemToAnsi( STR0017 ) ) //"Função" //"Função"
	aAdd( aTitles , OemToAnsi( STR0018 ) ) //"Funcionário" //"Funcionário"
	aAdd( aPages , "Header 1" )
	aAdd( aPages , "Header 2" )
	aAdd( aPages , "Header 3" )
	nControl := 4

	Define MsDialog oDlg Title OemToAnsi( cCadastro + cCadOpt ) From aSize[ 7 ] , 0 To aSize[ 6 ] , aSize[ 5 ] Of oMainWnd Pixel

		//Panel criado para correta disposicao da tela
		oPnlPai := TPanel():New( , , , oDlg , , , , , , , , .F. , .F. )
			oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

			//Panel criado para correta disposicao da tela
			oPanel := TPanel():New( , , , oPnlPai , , , , , , , aSize[ 6 ] / 6 , .F. , .F. )
				oPanel:Align := CONTROL_ALIGN_TOP

				oEnc01 := MsMGet():New( "TL6" , nRecno , nOpcx , , , , aChoice , { 13 , 0 , 89 , aPosObj[ 1 , 4 ] } , , , , , , oPanel , , , .F. , "aSvATela" )
					oEnc01:oBox:Align := CONTROL_ALIGN_ALLCLIENT
					oEnc01:oBox:bGotFocus := { | | NgEntraEnc( "TL6" ) }
					aSvATela := aClone( aTela )
					aSvAGets := aClone( aGets )

			//Painel - Parte Intermediária ( Botão de Importação )
			oPnlBtn := TPanel():New( , , , oPnlPai , , , , , , , 15 , .F. , .F. )
		   		oPnlBtn:Align := CONTROL_ALIGN_TOP
			    //Monta o Botão de Importação
				oBtnImp := TButton():New( 2 , 5 , STR0019 , oPnlBtn , { | | fButton( oFolder ) } , 49 , 12 , , /*oFont*/ , , .T. , , , , { | | fBlockBtt( oFolder ) }/* bWhen*/ , , )	 //"Importação"

			//----------------
			// Folders
			//----------------
			oFolder := TFolder():New( 7 , 0 , aTitles , aPages , oPnlPai , , , , .F. , .F. , aPosObj[ 1 , 4 ] , aPosObj[ 1 , 3 ] , )
				oFolder:Align 	:= CONTROL_ALIGN_ALLCLIENT
				oFolder:bChange	:= { | | fChange( oBtnImp , oFolder ) }
				//------------------------------
				// Folder 1 - Centro de Custo
				//------------------------------
				nTelaX := ( aSize[ 6 ]/2.02 ) - 108

				dbSelectArea( "TKF" )
				PutFileInEof( "TKF" )

				oBrwA   := MsNewGetDados():New( 20 , 1 , nTelaX , 220 , IIF( !lAltProg , 0 , GD_INSERT + GD_UPDATE + GD_DELETE ) , ;
													{ | | fLinhaOK( "TKF" , oBrwA , aHoBrwA , "TKF_CODCC" ) } , { | | .T. } , , , , 9999 , , , , oFolder:aDialogs[ 1 ] , aHoBrwA , aCoBrwA )
					oBrwA:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
					oBrwA:oBrowse:Default()
					oBrwA:oBrowse:Disable()
					If AllTrim( M->TL6_CC ) == "1"
						oBrwA:oBrowse:Enable()
					Endif
					oBrwA:oBrowse:Refresh()

				//------------------------------
				// Folder 2 - Funcao
				//------------------------------
				nTelaX := ( aSize[6]/2.02 ) - 108

				dbSelectArea( "TKG" )
				PutFileInEof( "TKG" )

				oBrwB   := MsNewGetDados():New( 20 , 1 , nTelaX , 220 , IIF( !lAltProg , 0 , GD_INSERT + GD_UPDATE + GD_DELETE ) , ;
													{ | | fLinhaOK( "TKG" , oBrwB , aHoBrwB , "TKG_CODFUN" ) } , { | | .T. } , , , , 9999 , , , , oFolder:aDialogs[ 2 ] , aHoBrwB , aCoBrwB )
					oBrwB:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
					oBrwB:oBrowse:Default()
					oBrwB:oBrowse:Disable()
					If AllTrim( M->TL6_FUNC ) == "1"
						oBrwB:oBrowse:Enable()
					Endif
					oBrwB:oBrowse:Refresh()

				//------------------------------
				// Folder 3 - Funcionario
				//------------------------------
				nTelaX := ( aSize[6]/2.02 ) - 108

				dbSelectArea( "TKH" )
				PutFileInEof( "TKH" )

				oBrwC   := MsNewGetDados():New(20,1,nTelaX,220,IIF(!lAltProg,0,GD_INSERT+GD_UPDATE+GD_DELETE),;
													{ | | fLinhaOK( "TKH" , oBrwC , aHoBrwC , "TKH_MATFUN" ) } , { | | .T. } , , , , 9999 , , , , oFolder:aDialogs[ 3 ] , aHoBrwC , aCoBrwC )
					oBrwC:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
					oBrwC:oBrowse:Default()
					oBrwC:oBrowse:Disable()
					If AllTrim( M->TL6_FNCR ) == "1"
						oBrwC:oBrowse:Enable()
					Endif

					oBrwC:oBrowse:Refresh()

	Activate MsDialog oDlg On Init EnchoiceBar( oDlg , ;
														{ | | nOpca := 1 , If( !A520Ok( cAlias , nOpcx ) , nOpca := 0 , oDlg:End() ) } , ;
														{ | | oDlg:End() } ) Centered

	If nOpca == 1
	   A520GRAVA( cAlias , nRecno , nOpcx )
	Else
		RollBackSX8()
	Endif

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} A520Ok
Checa se está tudo ok para gravação dos dados

@return lRet Lógico Indica se as validações estão corretas

@sample A520Ok()

@author Jackson Machado
@since 22/02/2011
/*/
//---------------------------------------------------------------------
Function A520Ok( cAlias , nOpcx  )

	Local lRet := .T.

	If !Obrigatorio( aGets , aTela )
		lRet := .F.
	EndIf

	If lRet .And. nOpcx == 5 .And. !NGCHKDEL( cAlias )
		lRet := .F.
	EndIf

	If lRet
		If !fLinhaOK( "TKF" , oBrwA , aHoBrwA , "TKF_CODCC" , .T. )
			oFolder:SetOption(1)
			lRet := .F.
		ElseIf !fLinhaOK( "TKG" , oBrwB , aHoBrwB , "TKG_CODFUN" , .T. )
			oFolder:SetOption(2)
			lRet := .F.
		ElseIf !fLinhaOK( "TKH" , oBrwC , aHoBrwC , "TKH_MATFUN" , .T. )
			oFolder:SetOption(3)
			lRet := .F.
		EndIf
	EndIf

	If lRet
		aCoBrwA := aClone( oBrwA:aCols )
		aCoBrwB := aClone( oBrwB:aCols )
		aCoBrwC := aClone( oBrwC:aCols )
	EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} A520GRAVA
Funcao chamada para gravacao

@return Nulo

@param cAliasX Caracter Tabela em questão
@param nRecnoX Numerico Recno da Tabela
@param nOpcX Numerico Opção a ser executada

@sample A520GRAVA( "TL6" , 0 , 3 )

@author Jackson Machado
@since 22/02/2011
/*/
//---------------------------------------------------------------------
Function A520GRAVA( cAliasX , nRecnoX , nOpcx )

	Local i, j, ny
	Local nTbl
	Local nOrd, cKey, cWhile, cVac, cKey2
	Local nPosCod
	Local cTblGrv
	Local cCpCli, cCpLoja, cCpKey
	Local aColsOk, aHeadOk
	Local aArea := GetArea()
	Local aTblGrv := { "TKF" , "TKG" , "TKH" }

	//-------------------------
	// Manipula a tabela TL6
	//-------------------------
	dbSelectArea( "TL6" )
	If nOpcx == 3
		ConfirmSX8()
	Endif

	If lSigaMdtPS
		nOrd := 3
		cVac := xFilial( "TL6" ) + SA1->A1_COD + SA1->A1_LOJA + M->TL6_VACINA
	Else
		nOrd := 1
		cVac := xFilial( "TL6" ) + M->TL6_VACINA
	Endif

	dbSetOrder( nOrd )
	If dbSeek( cVac )
		RecLock( "TL6" , .F. )
	Else
		RecLock( "TL6" , .T. )
	EndIf

	If nOpcx <> 5
		TL6->TL6_FILIAL 	:= xFilial( "TL6" )
		If lSigaMdtPS
			TL6->TL6_CLIENT 	:= SA1->A1_COD
			TL6->TL6_LOJA		:= SA1->A1_LOJA
		Endif

		dbSelectArea( "TL6" )
		dbSetOrder( nOrd )
		For i := 1 To FCount()
			If Alltrim( FieldName( i ) ) $ "TL6_FILIAL"
				Loop
			EndIf
			x  := "M->" + FieldName( i )
			y  := "TL6->" + FieldName( i )
			&y := &x
		Next i
	Else
		dbDelete()
	EndIf
	TL6->( MsUnLock() )

	If ( nOpcx == 3 .OR. nOpcx == 4 )
  		MsMM( If( nOpcx == 4 , TL6->TL6_MMVNG , Nil ) , , , M->TL6_VANTAG , 1 , , , "TL6" , "TL6_MMVNG" )
   		MsMM( If( nOpcx == 4 , TL6->TL6_MMEFTO , Nil ) , , , M->TL6_EFEITO , 1, , , "TL6" , "TL6_MMEFTO" )
   		MsMM( If( nOpcx == 4 , TL6->TL6_MMRCMC , Nil ) , , , M->TL6_RECOME , 1, , , "TL6" , "TL6_MMRCMC" )
	ElseIf nOpcx == 5
   		MsMM( TL6->TL6_MMVNG , , , , 2 )
   		MsMM( TL6->TL6_MMEFTO , , , , 2 )
   		MsMM( TL6->TL6_MMRCMC , , , , 2 )
	EndIf

	//----------------------------------------------
	// Manipulação das Tabelas TKF, TKG e TKH
	//----------------------------------------------
	For nTbl := 1 To Len( aTblGrv )

		cTblGrv := aTblGrv[ nTbl ]

		If cTblGrv == "TKF"
			nPosCod := aScan( aHoBrwA , { | x | Trim( Upper( x[ 2 ] ) ) == "TKF_CODCC" } )
			cCpCli	 := "TKF_CLIENT"
			cCpLoja := "TKF_LOJA"
			cCpKey  := "TKF_CODCC"
			aColsOk := aCoBrwA
			aHeadOk := aHoBrwA
			If lSigaMdtPS
				nOrd 	:= 2
				cKey 	:= xFilial( "TKF" ) + SA1->A1_COD + SA1->A1_LOJA + M->TL6_VACINA
				cWhile:= "xFilial( 'TKF' ) + M->TL6_VACINA + SA1->A1_COD + SA1->A1_LOJA == TKF->TKF_FILIAL + TKF->TKF_CODVAC + TKF->TKF_CLIENT + TKF->TKF_LOJA"
			Else
				nOrd 	:= 1
				cKey 	:= xFilial( "TKF" ) + M->TL6_VACINA
				cWhile:= "xFilial( 'TKF' ) + M->TL6_VACINA == TKF->TKF_FILIAL + TKF->TKF_CODVAC"
			Endif
		ElseIf cTblGrv == "TKG"
			nPosCod := aScan( aHoBrwB , { | x | Trim( Upper( x[ 2 ] ) ) == "TKG_CODFUN" } )
			cCpCli	 := "TKG_CLIENT"
			cCpLoja := "TKG_LOJA"
			cCpKey  := "TKG_CODFUN"
			aColsOk := aCoBrwB
			aHeadOk := aHoBrwB
			If lSigaMdtPS
				nOrd 	:= 2
				cKey 	:= xFilial( "TKG" ) + SA1->A1_COD + SA1->A1_LOJA + M->TL6_VACINA
				cWhile:= "xFilial( 'TKG' ) + M->TL6_VACINA + SA1->A1_COD + SA1->A1_LOJA == TKG->TKG_FILIAL + TKG->TKG_CODVAC + TKG->TKG_CLIENT + TKG->TKG_LOJA"
			Else
				nOrd 	:= 1
				cKey 	:= xFilial( "TKF" ) + M->TL6_VACINA
				cWhile:= "xFilial( 'TKF' ) + M->TL6_VACINA == TKG->TKG_FILIAL + TKG->TKG_CODVAC"
			Endif
		ElseIf cTblGrv == "TKH"
			nPosCod := aScan( aHoBrwC , { | x | Trim( Upper( x[ 2 ] ) ) == "TKH_MATFUN" } )
			cCpCli	 := "TKH_CLIENT"
			cCpLoja := "TKH_LOJA"
			cCpKey  := "TKH_MATFUN"
			aColsOk := aCoBrwC
			aHeadOk := aHoBrwC

			If lSigaMdtPS
				nOrd 	:= 2
				cKey 	:= xFilial( "TKH" ) + SA1->A1_COD + SA1->A1_LOJA + M->TL6_VACINA
				cWhile:= "xFilial( 'TKH' ) + M->TL6_VACINA + SA1->A1_COD + SA1->A1_LOJA == TKH->TKH_FILIAL + TKH->TKH_CODVAC + TKH->TKH_CLIENT + TKH->TKH_LOJA"
			Else
				nOrd 	:= 1
				cKey 	:= xFilial( "TKH" ) + M->TL6_VACINA
				cWhile:= "xFilial( 'TKH' ) + M->TL6_VACINA == TKH->TKH_FILIAL + TKH->TKH_CODVAC"
			Endif
		EndIf

		If nOpcx == 5
			dbSelectArea( cTblGrv )
			dbSetOrder( nOrd )
			dbSeek( cKey )
			While ( cTblGrv )->( !Eof() ) .and. &( cWhile )
				RecLock( cTblGrv , .F. )
				( cTblGrv )->( dbDelete() )
				( cTblGrv )->( MsUnLock() )
				( cTblGrv )->( dbSkip() )
			End
		Else
			If Len( aColsOk ) > 0
				aSort( aColsOk , , , { | x , y| x[ Len( aColsOk[ 1 ] ) ] .And. !y[ Len( aColsOk[ 1 ] ) ] } )
			Endif

			For i := 1 to Len( aColsOk )
				If !aColsOk[ i , Len( aColsOk[ i ] ) ] .And. !Empty( aColsOk[ i , nPosCod ] )
					dbSelectArea( cTblGrv )
					dbSetOrder( nOrd )
					If lSigaMdtPs
						cKey2 := xFilial( cTblGrv ) + SA1->A1_COD + SA1->A1_LOJA + M->TL6_VACINA + aColsOk[ i , nPosCod ]
					Else
						cKey2 := xFilial( cTblGrv ) + M->TL6_VACINA + aColsOk[ i , nPosCod ]
					Endif
					If dbSeek( cKey2 )
						RecLock( cTblGrv , .F. )
					Else
						RecLock( cTblGrv , .T. )
					Endif

					For j := 1 To FCount()
						If "_FILIAL" $ Upper( FieldName( j ) )
							FieldPut( j , xFilial( cTblGrv ) )
						ElseIf "_CODVAC" $ Upper( FieldName( j ) )
							FieldPut( j , M->TL6_VACINA )
						ElseIf ( nPos := aScan( aHeadOk , { | x | Trim( Upper( x[ 2 ] ) ) == Trim( Upper( FieldName( j ) ) ) } ) ) > 0
							FieldPut( j , aColsOk[ i , nPos ] )
						Endif
					Next j
					If lSigaMdtPs
						&( cCpCli )  := SA1->A1_COD
						&( cCpLoja ) := SA1->A1_LOJA
					Endif
					( cTblGrv )->( MsUnLock() )
				Elseif !Empty( aColsOk[ i , nPosCod ] )
					dbSelectArea( cTblGrv )
					dbSetOrder( nOrd )
					If lSigaMdtPs
						cKey2 := xFilial( cTblGrv ) + SA1->A1_COD + SA1->A1_LOJA + M->TL6_VACINA + aColsOk[ i , nPosCod ]
					Else
						cKey2 := xFilial( cTblGrv ) + M->TL6_VACINA + aColsOk[ i , nPosCod ]
					Endif
					If dbSeek( cKey2 )
						RecLock( cTblGrv , .F. )
						( cTblGrv )->( dbDelete() )
						( cTblGrv )->( MsUnLock() )
					Endif
				Endif
			Next i

			dbSelectArea( cTblGrv )
			dbSetOrder( nOrd )
			dbSeek( cKey )
			While ( cTblGrv )->( !Eof() ) .and. &( cWhile )
				If aScan( aColsOk , { | x | x[ nPosCod ] == ( cTblGrv )->&( cCpKey ) .And. !x[ Len( x ) ] } ) == 0
					RecLock( cTblGrv , .F. )
					( cTblGrv )->( dbDelete() )
					( cTblGrv )->( MsUnLock() )
				Endif
				( cTblGrv )->( dbSkip() )
			End
		Endif
	Next nTbl

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} VLDCC520
Função para habilitação/desabilitação do Centro de Custo

@return Nulo

@sample VLDCC520()

@author Jackson Machado
@since 22/02/2011
/*/
//---------------------------------------------------------------------
Function VLDCC520()

   If M->TL6_CC == "1"
  		oBrwA:oBrowse:Enable()
	Else
		oBrwA:oBrowse:Disable()
		oBrwA:aCols := BlankGetD( aHoBrwA )
		oBrwA:oBrowse:Refresh()
	EndIf

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} VLDFUNC520
Função para habilitação/desabilitação da Função

@return Nulo

@sample VLDFUNC520()

@author Jackson Machado
@since 22/02/2011
/*/
//---------------------------------------------------------------------
Function VLDFUNC520()

   If M->TL6_FUNC == "1"
  		oBrwB:oBrowse:Enable()
	Else
		oBrwB:oBrowse:Disable()
		oBrwB:aCols := BlankGetD( aHoBrwB )
		oBrwB:oBrowse:Refresh()
	EndIf

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} VLDFNCR520
Função para habilitação/desabilitação do Funcionário

@return Nulo

@sample VLDFNCR520()

@author Jackson Machado
@since 22/02/2011
/*/
//---------------------------------------------------------------------
Function VLDFNCR520()

   If M->TL6_FNCR == "1"
  		oBrwC:oBrowse:Enable()
	Else
		oBrwC:oBrowse:Disable()
		oBrwC:aCols := BlankGetD( aHoBrwC )
		oBrwC:oBrowse:Refresh()
	EndIf

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT520VCOD
Valida campo TL6_VACINA

@return lRet Lógico Retorna verdadeiro quando código correto

@sample MDT520VLD()

@author Jackson Machado
@since 24/02/2011
/*/
//---------------------------------------------------------------------
Function MDT520VCOD()

	Local lPrest	:= .F.
	Local lRet		:= .T.

	If Type( "cCliMdtPs" ) == "C"
		If !Empty( cCliMdtPs )
			lPrest := .T.
		Endif
	Endif

	If lPrest
		lRet := ExistChav( "TL6" , M->TL6_CLIENT + M->TL6_LOJA + M->TL6_VACINA , 3 )
	Else
		lRet := ExistChav( "TNN" , M->TL6_VACINA )
	Endif

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT520VLD
Valida sexo da TL6_VACINA

@return lRet Lógico Retorna verdadeiro quando sexo do funcionário corresponda ao filtro

@sample MDT520VLD()

@author Jackson Machado
@since 24/02/2011
/*/
//---------------------------------------------------------------------
Function MDT520VLD()

	Local cSexo := If( AllTrim( M->TL6_SEXO ) == "1" , "M" , If( AllTrim( M->TL6_SEXO ) == "2" , "F" , "MF" ) )
	Local lVldPS
	Local lRet  := .T.

 	If lSigaMdtPs
 		lVldPS := ( Type( "cCliMdtPs" ) == "U" .Or. Empty( cCliMdtPs ) .Or. Substr( SRA->RA_CC , 1 , 8 ) == cCliMdtPs )
 		lRet := lVldPS .AND. SRA->RA_SEXO $ cSexo
 	Else
  		lRet := SRA->RA_SEXO $ cSexo
 	Endif

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT520VLDF
Valid do TKG_CODFUN

@return Sempre Lógico

@sample MDT520RLCF()

@author Jackson Machado
@since 24/02/2011
/*/
//---------------------------------------------------------------------
Function MDT520VLDF()

	Local nPos := aScan( oBrwB:aHeader , { | x | Trim( Upper( x[ 2 ] ) ) == "TKG_DESFUN" } )
	Local cDesc := ""
	Local cBranco := Space(4)

	If nPos > 0

		If lSigaMdtPs
			cDesc := POSICIONE( "TOS" , 2 , xFilial( "TOS" ) + cCliMdtps + M->TKG_CODFUN , "TOS_DESFUN" )
			oBrwB:aCols[ oBrwB:nAt , nPos ] := cDesc
			cValid := If( INCLUI , cBranco , cDesc )
		Else
			cDesc := POSICIONE( "SRJ" , 1 , xFilial( "SRJ" ) + M->TKG_CODFUN , "RJ_DESC" )
			oBrwB:aCols[ oBrwB:nAt , nPos ] := cDesc
			cValid := If( INCLUI , cBranco , cDesc )
		Endif

		oBrwB:Refresh()

	Endif

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT520RLCF
Relação do TKG_DESFUN

@return cDesc Caracter Descrição do campo TKG_DESFUN

@sample MDT520RLCF()

@author Jackson Machado
@since 24/02/2011
/*/
//---------------------------------------------------------------------
Function MDT520RLCF()

	Local cDesc := ""

	If lSigaMdtPs
		If	INCLUI
			cDesc := Space( TamSX3( "TKG_CODFUN" )[ 1 ] )
		Else
			dbSelectArea( "TOS" )
			dbSetOrder( 2 )
			If dbSeek( xFilial( "TOS" ) + cCliMdtps + TKG->TKG_CODFUN )
				cDesc := TOS->TOS_DESFUN
			Endif
		Endif
	Else
		If INCLUI
			cDesc := Space( TamSX3( "TKG_CODFUN" )[ 1 ] )
		Else
			dbSelectArea( "SRJ" )
			dbSetOrder( 1 )
			If dbSeek( xFilial( "SRJ" ) + TKG->TKG_CODFUN )
				cDesc := SRJ->SRJ_DESC
			Endif
		Endif
	Endif

Return cDesc
//---------------------------------------------------------------------
/*/{Protheus.doc} fLinhaOk
Validacao de Linha padrao das GetDados

@return lRet Logico Indica se esta tudo correto na linha

@param cTbl Caracter Indica a Tabela a ser validada
@param oGetDad Objeto GetDados a ser validada
@param aParHead Array aHeader da GetDados a ser validada
@param cCodVal Caracter Código da GetDados a ser validado
@param lFim Logico Indica se eh chamado pelo TudoOk

@sample fLinhaOK( "TKF" , oObj , {} , "TKF_CODCC" )

@author Jackson Machado
@since 05/12/2014
/*/
//---------------------------------------------------------------------
Static Function fLinhaOK( cTbl , oGetDad , aParHead , cCodVal , lFim )

	//Variaveis auxiliares
	Local f
	Local aColsOk 	:= {}, aHeadOk := {}
	Local nPosCod 	:= 1, nAt := 1
	Local lRet			:= .T.
	Local nPosSec	:= 0

	Default lFim		:= .F.//Define fim como .F.

	//Salva o aCols e aHeader de acordo com a posicao, o nAt da GetDados posicionada e o código de acordo com sua posicao
	aColsOk	:= aClone( oGetDad:aCols )
	aHeadOk	:= aClone( aParHead )
	nAt			:= oGetDad:nAt
	nPosCod	:= aScan( aHeadOk , { | x | AllTrim( Upper( x[ 2 ] ) ) == cCodVal } )

	//Percorre aCols
	For f:= 1 to Len( aColsOk )
		If !aColsOk[ f , Len( aColsOk[ f ] ) ]
			If lFim .or. f == nAt//Caso seja final ou linha atual
				//Verifica se os campos obrigatórios estão preenchidos
				If Empty( aColsOk[ f , nPosCod ] ) .And. If( lFim , Len( aColsOk ) <> 1 , .T. )
					//Mostra mensagem de Help
					Help( 1 , " " , "OBRIGAT2" , , aHeadOk[ nPosCod , 1 ] , 3 , 0 )
					lRet := .F.
					Exit
				Endif
			Endif
			//Verifica se é somente LinhaOk
			If lRet .And. f <> nAt .and. !aColsOk[ nAt , Len( aColsOk[ nAt ] ) ]
				If aColsOk[ f , nPosCod ] == aColsOk[ nAt , nPosCod ] .And. If( nPosSec > 0 , aColsOk[ f , nPosSec ] == aColsOk[ nAt , nPosSec ] , .T. )
					//Mostra mensagem de Help
					Help( " " , 1 , "JAEXISTINF" , , aHeadOk[ nPosCod , 1 ] )
					lRet := .F.
					Exit
				Endif
			Endif
		Endif
	Next f

	//Posiciona tabelas em fim de arquivo
	PutFileInEof( cTbl )

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT520WHEN
Verifica propriedade WHEN do campo passado como parâmetro.


@param cCpo - Campo a ser verificado a propriedade WHEN
@return lRet - .T. se permitir edição, .F. caso contrário

@author Thiago Henrique dos Santos
@since 25/04/2013
/*/
//---------------------------------------------------------------------

Function MDT520WHEN( cCpo )

	Local lRet := .T.

	If SuperGetMV("MV_NG2SEG",.F.,"2") == "1" .And. ALTERA .AND. Alltrim(cCpo) == "TL6_NOMVAC"

		//TL7 - Calendário de Vacinação
		DbSelectArea("TL7")
		TL7->(DbSetOrder(1))
		If  TL7->(DbSeek(xFilial("TL7")+M->TL6_VACINA))

			lRet := .F.

		Else

			//TL8 - Itens do Calendário de Vacinação
			DbSelectArea("TL8")
			TL8->(DbSetOrder(1))
			If  TL8->(DbSeek(xFilial("TL8")+M->TL6_VACINA))

				lRet := .F.
			Else

				//TL9 - Vacinas do Funcionário
				DbSelectArea("TL9")
				TL8->(DbSetOrder(3))
				lRet :=  !TL9->(DbSeek(xFilial("TL9")+M->TL6_VACINA))
			Endif
		Endif
	Endif

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT520LMP
Define funcao que limpa a getdados de acordo com o sexo selecionado.
Uso MDTA520

@return Nil

@sample
MDT520LMP()

@author Kawan Tácito Soares
@since 25/09/2013
/*/
//---------------------------------------------------------------------
Function MDT520LMP()

	Local cSexo := If(AllTrim(M->TL6_SEXO)=='1','M',If(AllTrim(M->TL6_SEXO)=='2','F','MF'))
	Local nPOS := aSCAN( oBrwC:aHeader, { |x| Trim( Upper(x[2]) ) == "TKH_MATFUN"})
	Local i

	If Type("oBrwC") == "O" .And. AllTrim(M->TL6_FNCR) == "1"
		For i := Len(oBrwC:aCols) to 1 Step -1
			If !(NGSeek("SRA", oBrwC:aCols[i][nPOS], 1, "RA_SEXO") $ cSexo) .And. !Empty(oBrwC:aCols[i][nPOS])
				aDel(oBrwC:aCols, i)
				aSize(oBrwC:aCols,Len(oBrwC:aCols)-1)
				oBrwC:oBrowse:Refresh()
			Endif
		Next i
	Endif

	If Len(oBrwC:aCols) == 0
		 oBrwC:aCols := BLANKGETD(oBrwC:aHeader)
		 oBrwC:oBrowse:Refresh()
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fButton
Adiciona multiplos no relacionamento

@return Nil

@param oFolder Objeto Objeto do Folder ( Obrigatório )

@sample fButton( oFolder , aRelacio )

@author Jackson Machado
@since 08/12/2013
/*/
//---------------------------------------------------------------------
Static Function fButton( oFolder )

	Local nCps	   := 0
	Local nFolPos  := oFolder:nOption
	Local cTab	   := ""
	Local cTabRel  := ""
	Local cCodigo  := ""
	Local aTam	   := {}
	Local aCampos  := {}, aCpsExt := {}
	Local aArea	   := GetArea()//Salva a Area Atual
	Local aAreaAtu := {}
	Local nIdx     := 0
	Local cTipo
	Local cTitu

	//Variaveis para montar TRB
	Local cAliasTRB	:= GetNextAlias()
	Local aDBF, aTRB, aIdx, aDescIdx

	//Variaveis da Montagem do MarkBrowse
	Local lOK := .F.
	Local lInverte, lRet := .T.

	//Definicoes de Objetos
	Local oDialog
	Local oMark

	Local oPnlPai

	//Variaveis Privadas
	Private cMarca	:= GetMark()
	Private oGetDad

	//Variaveis da Pesquisa
	Private cPesquisar := Space( 200 )//Valor a ser pesquisado
	Private cCbxPesq   := ""
	Private aCbxPesq //ComboBox com indices de pesquisa
	Private oBtnPesq, oPesquisar//Botao de Pesquisa e Campo para Pesquisa
	Private oCbxPesq //ComboBox de Pesquisa

	//Define estruturas pelo Folder
	If nFolPos == 1
		cTab		:= "TKF"
		cTabRel	:= "CTT"
		aCpsExt	:= { "TKF_CODCC" , "TKF_NOMCC" }
		cCodigo	:= "TKF_CODCC"
		aCampos	:= { "CTT_CUSTO" , "CTT_DESC01" }
		oGetDad	:= oBrwA
		cDescri	:= STR0016 //"Centro de Custo"
	ElseIf nFolPos == 2
		cTab		:= "TKG"
		cTabRel	:= "SRJ"
		aCpsExt	:= { "TKG_CODFUN" , "TKG_DESFUN" }
		cCodigo	:= "TKG_CODFUN"
		aCampos	:= { "RJ_FUNCAO" , "RJ_DESC" }
		oGetDad	:= oBrwB
		cDescri	:= STR0017 //"Função"
	Else
		cTab		:= "TKH"
		cTabRel	:= "SRA"
		aCpsExt	:= { "TKH_MATFUN" , "TKH_NOMFUN" }
		cCodigo	:= "TKH_MATFUN"
		aCampos	:= { "RA_MAT" , "RA_NOME" }
		oGetDad	:= oBrwC
		cDescri	:= STR0018 //"Funcionário"
	EndIf

	lInverte := .F.

	//Valores e Caracteristicas da TRB
	aDBF		:= {}
	aTRB		:= {}
	aIdx		:= {}
	aDescIdx	:= {}

	aAdd( aDBF , { "OK"      , "C" , 02 , 0    } )
	aAdd( aTRB , { "OK"     , NIL , " "	  	 , } )

	//Define os campos
	aAreaAtu := GetArea()
	For nCps := 1 To Len( aCampos )

		aTam := TAMSX3( aCampos[ nCps ] )
		cTipo := GetSx3Cache( aCampos[ nCps ] ,'X3_TIPO' )
		cTitu := AllTrim( Posicione( 'SX3' , 2 , aCampos[ nCps ] , 'X3Titulo()' ) )
		aAdd( aDBF , { aCampos[ nCps ] , cTipo	, aTam[ 1 ]	, aTam[ 2 ]	} )
		aAdd( aTRB , { aCampos[ nCps ] , NIL 	, cTitu     ,			} )

	Next nCps

	MDTA232IDX( @aIdx , @aDescIdx , aCampos ) //Realiza a Geracao dos Indices

	//Adiciona ultima posicao como Marcados
	aAdd( aIdx , "OK" )
	RestArea( aAreaAtu )

	//Cria TRB
	oTempTRB := FWTemporaryTable():New( cAliasTRB, aDBF )
	For nIdx := 1 To Len( aIdx )
		oTempTRB:AddIndex( RETASC( cValToChar( nIdx ) , 1 , .T. ), StrTokArr( aIdx[nIdx] , "+" ) )
	Next nIdx
	oTempTRB:Create()

	dbSelectArea( cTab )

	Processa( { | lEnd | fBuscaReg( cTabRel , cAliasTRB , nFolPos , aCampos , cCodigo, aDBF ) } , STR0020 , STR0021 ) //"Buscando Registros"###"Aguarde"

	dbSelectArea( cAliasTRB )
	dbGoTop()
	If ( cAliasTRB )->( Reccount() ) <= 0
		MsgStop( STR0022 , STR0007 ) //"Não existem registros cadastrados"###"ATENÇÃO"
		lRet := .F.
	Endif

	If lRet
		DEFINE MSDIALOG oDialog TITLE OemToAnsi( cDescri ) From 64,160 To 580,736 OF oMainWnd Pixel

			oPnlPai := TPanel():New( , , , oDialog , , , , , , , , .F. , .F. )
				oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

			//--- DESCRICAO ( TOPO )
			oPanel := TPanel():New( 0 , 0 , , oPnlPai , , .T. , .F. , , , 0 , 55 , .T. , .F. )
				oPanel:Align := CONTROL_ALIGN_TOP

				@ 8,9.6 TO 45,280 OF oPanel PIXEL

				TSay():New( 19 , 12 , { | | OemtoAnsi( STR0023 ) } , oPanel , , , .F. , .F. , .F. , .T. , CLR_BLACK , CLR_WHITE , 200 , 010 ) //"Estes são os registros cadastrados no sistema."
				TSay():New( 29 , 12 , { | | OemtoAnsi( STR0024 ) } , oPanel , , , .F. , .F. , .F. , .T. , CLR_BLACK , CLR_WHITE , 200 , 010 ) //"Selecione aqueles que foram avaliados no laudo."

			//--- PESQUISAR
			//Define as opcoes de Pesquisa
			aCbxPesq := aClone( aDescIdx )
			aAdd( aCbxPesq , STR0025 ) //"Marcados" //"Marcados"
			cCbxPesq := aCbxPesq[ 1 ]

			oPnlPesq 		:= TPanel():New( 01 , 01 , , oPnlPai , , , , CLR_BLACK , CLR_WHITE , 50 , 30 , .T. , .T. )
				oPnlPesq:Align	:= CONTROL_ALIGN_TOP

					oCbxPesq := TComboBox():New( 002 , 002 , { | u | If( PCount() > 0 , cCbxPesq := u , cCbxPesq ) } , ;
															aCbxPesq , 200 , 08 , oPnlPesq , , { | | } ;
															, , , , .T. , , , , , , , , , "cCbxPesq" )
						oCbxPesq:bChange := { | | fSetIndex( cAliasTRB , aCbxPesq , @cPesquisar , oMark ) }

					oPesquisar := TGet():New( 015 , 002 , { | u | If( PCount() > 0 , cPesquisar := u , cPesquisar ) } , oPnlPesq , 200 , 008 , "" , { | | .T. } , CLR_BLACK , CLR_WHITE , ,;
							 				.F. , , .T. /*lPixel*/ , , .F. , { | | cCbxPesq <> aCbxPesq[ Len( aCbxPesq ) ] }/*bWhen*/ , .F. , .F. , , .F. /*lReadOnly*/ , .F. , "" , "cPesquisar" , , , , .F. /*lHasButton*/ )

					oBtnPesq := TButton():New( 002 , 220 , STR0001 , oPnlPesq , { | | fPesqTRB( cAliasTRB , oMark ) } , ;//"Pesquisar" //"Pesquisar"
															70 , 10 , , , .F. , .T. , .F. , , .F. , , , .F. )

			oMark := MsSelect():New( cAliasTRB , "OK" , , aTRB , @lInverte , @cMarca , { 45 , 5 , 254 , 281 }, , , oPnlPai )
				oMark:oBrowse:lHasMark		:= .T.
				oMark:oBrowse:lCanAllMark	:= .T.
				oMark:oBrowse:bAllMark		:= { | | fInverte( cMarca , cAliasTRB , oMark , .T. ) }//Funcao inverte marcadores
				oMark:bMark	   				:= { | | fInverte( cMarca , cAliasTRB , oMark ) }//Funcao inverte marcadores
				oMark:oBrowse:Align			:= CONTROL_ALIGN_ALLCLIENT

		ACTIVATE MSDIALOG oDialog ON INIT EnchoiceBar(oDialog,{|| lOk := .T. ,oDialog:End()},{|| lOk := .F.,oDialog:End()}) CENTERED

		If lOK
			fGravCols( oGetDad , cAliasTRB , aCampos , cCodigo , cTab , aCpsExt )//Funcao para copiar planos a GetDados
		Endif
	EndIf

	oTempTRB:Delete()

	RestArea(aArea)

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fSetIndex
Seta o indice para pesquisa

@return

@param cAliasTRB Caracter Alias do TRB ( Obrigatório )
@param aCbxPesq Array Indices de pesquisa do markbrowse. ( Obrigatório )
@param cPesquisar	Caracter Valor da Pesquisa ( Obrigatório )
@param oMark Objeto Objeto do MarkBrowse ( Obrigatório )

@author Jackson Machado
@since 08/12/2013
/*/
//---------------------------------------------------------------------
Static Function fSetIndex( cAliasTRB , aCbxPesq , cPesquisar , oMark )

	Local nIndice := fRetInd( aCbxPesq ) // Retorna numero do indice selecionado

	// Efetua ordenacao do alias do markbrowse, conforme indice selecionado
	dbSelectArea( cAliasTRB )
	dbSetOrder( nIndice )
	dbGoTop()

	// Se o indice selecionado for o ultimo [Marcados]
	If nIndice == Len( aCbxPesq )
		cPesquisar := Space( Len( cPesquisar ) ) // Limpa campo de pesquisa
		oPesquisar:Disable()              // Desabilita campo de pesquisa
		oBtnPesq:Disable()              // Desabilita botao de pesquisa
		oMark:oBrowse:SetFocus()     // Define foco no markbrowse
	Else
		oPesquisar:Enable()               // Habilita campo de pesquisa
		oBtnPesq:Enable()               // Habilita botao de pesquisa
		oBtnPesq:SetFocus()             // Define foco no campo de pesquisa
	Endif

	oMark:oBrowse:Refresh()

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fRetInd
Retorna o indice, em numero, do item selecionado no combobox

@return nIndice Numerico Retorna o valor do Indice

@param aIndMrk Array Indices de pesquisa do markbrowse. ( Obrigatório )

@author Jackson Machado
@since 08/12/2013
/*/
//---------------------------------------------------------------------
Static Function fRetInd( aIndMrk )

	Local nIndice := aScan( aIndMrk , { | x | AllTrim( x ) == AllTrim( cCbxPesq ) } )

	// Se o indice nao foi encontrado nos indices pre-definidos, apresenta mensagem
	If nIndice == 0
		ShowHelpDlg( STR0007 ,	{ STR0026 } , 1 , ; //"Atenção"###"Índice não encontrado."
									{ STR0027 } , 1 ) //"Contate o administrador do sistema."
		nIndice := 1
	Endif

Return nIndice
//---------------------------------------------------------------------
/*/{Protheus.doc} fBuscaReg
Realiza a busca dos registros para alimentar o TRB

@return Nil

@param cTabela, Caractere, Tabela a ser pesquisada
@param cAliasTRB, Caractere, Alias da tabela temporária
@param nFolPos, Numerico, Posicao do Folder
@param aCampos, Array, Campos a serem considerados
@param cCodigo, Codigo, Campo de codigo a ser validado
@param aDBF, Array, Campos da tabela temporária

@sample fBuscaReg( 'SRA', '1SCGN000253' , 3, {"RA_MAT", "RA_NOME"}, ;
					"TKH_MATFUN", {{"OK", "C", 2 ,0}} )

@author Jackson Machado
@since 08/12/2013
/*/
//---------------------------------------------------------------------
Static Function fBuscaReg( cTabela , cAliasTRB , nFolPos , aCampos , cCodigo, aDBF )

	Local nCps		:= 0
	Local nPosCod	:= 1
	Local cCampo	:= ''
	Local cCodRel	:= ''
	Local oGet		:= oGetDad
	Local aColsOK	:= aClone( oGet:aCols )
	Local aHeadOk	:= aClone( oGet:aHeader )
	Local cSelec    := ''
	Local cCampos   := ''
	Local cQuery    := ''
	Local nX        := 0
	Local cPrefix   := PrefixoCpo (cTabela)

	//Adiciona registros na SRA

    nPosCod	:= aScan( aHeadOk , { | x | AllTrim( Upper( x[ 2 ] ) ) == cCodigo } )
	cCodRel := aCampos[ 1 ]

	aFields := {}
	aEval( aColsOk , { | aLine |  aAdd( aFields ,  aLine[ nPosCod ] ) } )
	cSelec := FormatIn( ArrTokStr( aFields ) , "|" )

	For nX := 1 to Len(aCampos) //Cria uma string dos itens selecionados
		cCampos += IIf(nX <> 1,', ','') + cTabela + '.'+ aCampos[ nX ]
	Next nX

	dbSelectArea(cTabela)

	cQuery := "SELECT "
	cQuery += "CASE WHEN " + cTabela + "." + cCodRel + " IN" + cSelec + " THEN '" + cMarca + "' ELSE '' END OK, "
	cQuery += cCampos +  " "
	cQuery += "FROM " + RetSqlName(cTabela) +  " " + cTabela + " "
	cQuery += "WHERE " + cTabela + ".D_E_L_E_T_ <> '*' "
	cQuery += "AND " + cTabela + "." + cPrefix + "_FILIAL = " + ValToSql( xFilial(cTabela) ) + " "
	If FieldPos( cPrefix +'_MSBLQL' ) > 0 //Se existir o campo de bloqueio de registro
		cQuery += "AND " + cTabela + "." + cPrefix + "_MSBLQL <> '1' "
	EndIf
	If cTabela == "SRA"
		If M->TL6_SEXO = '1'
			cQuery += "AND SRA.RA_SEXO <> 'F'
		ElseIf TL6_SEXO = '2'
			cQuery += "AND SRA.RA_SEXO <> 'M'
		EndIf
	EndIf

	cQuery := ChangeQuery(cQuery)
	SqlToTrb( cQuery, aDBF, cAliasTRB )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fGravCols
Faz as gravações do TRB para o aCols correspondente

@return Nil

@param oGet Objeto Objeto da GetDados ( Obrigatório )
@param cAliasTRB Caracter Alias do TRB ( Obrigatório )
@param aCampos Array Campos a serem considerados ( Obrigatório )
@param cCodigo Caracter Campo de codigo a ser validado ( Obrigatório )
@param aCampos2 Array Campos a serem verificados no aHeader ( Obrigatório )

@sample
fButton( "TN0" , 1 , { "TN0_NUMRIS" , "TN0_NOMAGE" } , "TN0_NUMRIS" )

@author Jackson Machado
@since 08/12/2013
/*/
//---------------------------------------------------------------------
Static Function fGravCols( oGet , cAliasTRB , aCampos , cCodigo , cTabela , aCampos2 )

	Local nCols, nCps
	Local nPosCod := 1
	Local nPosCps := 0
	Local cCodRel := ""
	Local aColsOk := {}
	Local aHeadOk := {}
	Local aColsTp := {}

	aColsOk := aClone( oGet:aCols )
	aHeadOk := aClone( oGet:aHeader )
	aColsTp := BLANKGETD( aHeadOk )

	nPosCod := aScan( aHeadOk , { | x | Trim( Upper( x[ 2 ] ) ) == cCodigo } )
	cCodRel := aCampos[ 1 ]

	For nCols := Len( aColsOk ) To 1 Step -1 //Deleta do aColsOk os registros - não marcados; não estiver encontrado
		dbSelectArea( cAliasTRB )
		dbSetOrder( 1 )
		If !dbSeek( aColsOK[ nCols , nPosCod ] ) .OR. Empty( ( cAliasTRB )->OK )
			aDel( aColsOk , nCols )
			aSize( aColsOk , Len( aColsOk ) - 1 )
		EndIf
	Next nCols

	dbSelectArea( cAliasTRB )
	Set Filter To !Empty( ( cAliasTRB )->OK )
	dbGoTop()
	While ( cAliasTRB )->( !Eof() )
		If aScan( aColsOk , {|x| x[ nPosCod ] == &( cAliasTRB + "->" + cCodRel ) } ) == 0
			aAdd( aColsOk , aClone( aColsTp[ 1 ] ) )
			For nCps := 1 To Len( aCampos )
				nPosCps := aScan( aHeadOk , { | x | Trim( Upper( x[ 2 ] ) ) == aCampos2[ nCps ] } )
				If nPosCps > 0
					aColsOk[ Len( aColsOk ) , nPosCps ] := &( cAliasTRB + "->" + aCampos[ nCps ] )
				EndIf
			Next nCps
		EndIf
		( cAliasTRB )->(dbSkip())
	End

	If Len( aColsOK ) <= 0
		aColsOK := aClone( aColsTp )
	EndIf

	aSort( aColsOK , , , { | x , y | x[ 1 ] < y[ 1 ] }) //Ordena por plano
	oGet:aCols := aClone( aColsOK )
	oGet:oBrowse:Refresh()

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fInverte
Inverte as marcacoes ( bAllMark )

@return Nil

@param cMarca Caracter Valor da marca do TRB ( Obrigatório )
@param cAliasTRB Caracter Alias do TRB ( Obrigatório )
@param oMark Objeto Objeto do MarkBrowse ( Obrigatório )
@param lAll Logico Indica se eh AllMark

@sample
fInverte( "E" , "TRB" )

@author Jackson Machado
@since 08/12/2013
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
			( cAliasTRB )->OK := IF( Empty( ( cAliasTRB )->OK ) , cMarca , Space( Len( cMarca ) ) )
			(cAliasTRB)->( dbskip() )
		End

		RestArea( aArea )
	EndIf

	// Atualiza markbrowse
	oMark:oBrowse:Refresh()

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fPesqTRB
Funcao de Pesquisar no Browse.

@sample fPesqTRB()

@return Sempre verdadeiro

@param cAliasTRB	Caracter Alias do MarkBrowse ( Obrigatório )
@param oMark Objeto Objeto do MarkBrowse ( Obrigatório )

@author Jackson Machado
@since 08/12/2013
/*/
//---------------------------------------------------------------------
Static Function fPesqTRB( cAliasTRB , oMark )

	Local nRecNoAtu := 1//Variavel para salvar o recno
	Local lRet		:= .T.

	//Posiciona no TRB e salva o recno
	dbSelectArea( cAliasTRB )
	nRecNoAtu := RecNo()

	dbSelectArea( cAliasTRB )
	If dbSeek( AllTrim( cPesquisar ) )
		//Caso exista a pesquisa, posiciona
		oMark:oBrowse:SetFocus()
	Else
		//Caso nao exista, retorna ao primeiro recno e exibe mensagem
		dbGoTo( nRecNoAtu )
		ApMsgInfo( STR0028 , STR0007 ) //"Valor não encontrado."###"Atenção"
		oPesquisar:SetFocus()
		lRet := .F.
	EndIf

	// Atualiza markbrowse
	oMark:oBrowse:Refresh(.T.)

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fBlockBtt
Bloqueia botão de Importação

@sample fBlockBtt( oFolder )

@return lRet Logico Retorna se deve ou não estar habilitado o botao

@param oFolder Objeto Objeto do Folder ( Obrigatório )

@author Jackson Machado
@since 08/12/2013
/*/
//---------------------------------------------------------------------
Static Function fBlockBtt( oFolder )

	Local nFolPos
	Local lRet		:= .F.

	If ValType( oFolder ) == "O"
   		nFolPos	:= oFolder:nOption
		If ( nFolPos == 1 .And. M->TL6_CC == "1" ) .Or. ;
			( nFolPos == 2 .And. M->TL6_FUNC == "1" ) .Or. ;
			( nFolPos == 3 .And. M->TL6_FNCR == "1" )
			lRet := .T.
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fSetOption
Atualiza botão de importação

@sample fSetOption( oBtn )

@return lRet Logico Retorna se deve ou não estar habilitado o botao

@param oBtn Objeto Objeto do Botao ( Obrigatório )

@author Jackson Machado
@since 08/12/2013
/*/
//---------------------------------------------------------------------
Static Function fChange( oBtn , oFolder )

	Local nFolPos := oFolder:nOption

	If ( nFolPos == 1 .And. M->TL6_CC == "1" ) .Or. ;
		( nFolPos == 2 .And. M->TL6_FUNC == "1" ) .Or. ;
		( nFolPos == 3 .And. M->TL6_FNCR == "1" )
		oBtn:Enable()
	Else
		oBtn:Disable()
	EndIf

Return
