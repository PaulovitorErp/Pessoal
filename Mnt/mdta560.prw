#INCLUDE "MDTA560.ch"
#Include "Protheus.ch"
#Include "DbTree.ch"
#Include "Ptmenu.ch"

Static cQrySonTKM

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA560
Programa de Cadastro de Brigadas

@return Sempre Nulo

@sample MDTA560()

@author Jackson Machado
@since 13/05/11 - Revisão: 29/10/14
/*/
//---------------------------------------------------------------------
Function MDTA560()

	//------------------------------------------------------
	// Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	//------------------------------------------------------
	Local aNGBEGINPRM := NGBEGINPRM()

	//------------------------------------------------------
	// Define o cabecalho da tela de atualizacoes
	//------------------------------------------------------
	Private cCadastro		:= OemtoAnsi(STR0001)   //"Brigadas"
	Private aRotina		:= MenuDef()
	Private lFilMat := TKM->(ColumnPos("TKM_FILMAT")) > 0 //Verifica se campo de FilMat existe,
	Private lTravFilMAt := .T. //Variavel utilizada no When do FilMat

	//----------------------------------------------------------------
	// aCHKDEL array que verifica a INTEGRIDADE REFERENCIAL na exclu-
	// são do registro.
	//
	// 1 - Chave de pesquisa
	// 2 - Alias de pesquisa
	// 3 - Ordem de pesquisa
	//----------------------------------------------------------------
	Private aCHKDEL		:= { { "TKL->TKL_BRIGAD" , "TKQ" , 1 } }

	If AMiIn( 35 ) // Somente autorizado para SIGAMDT
		dbSelectArea( "TKL" )
		dbSetOrder( 1 )
		mBrowse( 6 , 1 , 22 , 75 , "TKL" )
	EndIf

	//------------------------------------------------------
	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	//------------------------------------------------------
	NGRETURNPRM( aNGBEGINPRM )

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

@author Jackson Machado
@since 13/05/2011
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {	{ STR0005 , "AxPesqui" 	, 0 , 1 } , ;		//"Pesquisar"
						{ STR0006 , "MDTA560IN" , 0 , 2 } , ;		//"Visualizar"
						{ STR0007 , "MDTA560IN" , 0 , 3 } , ;		//"Incluir"
						{ STR0008 , "MDTA560IN" , 0 , 4 } , ;		//"Alterar"
						{ STR0009 , "MDTA560IN" , 0 , 5 , 3 } , ;	//"Excluir"
						{ STR0010 , "MDTA560Copy" , 0 , 3 } }		//"Copiar"

Return aRotina
//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA560IN
Tela de manutencao da Brigada

@return Sempre Nulo

@param cAlias Caracter Tabela em utilização
@param nRecno Numerico Recno posicionado da tabela
@param nOpcx Numerico Opção de Manutenção ( 3 - Inclusão ; 4 - Alteração ; 5 - Exclusão )

@sample MDTA560IN( 'TKL' , 0 , 3 )

@author Jackson Machado
@since 13/05/2011
/*/
//---------------------------------------------------------------------
Function MDTA560IN( cAlias , nRecno , nOpcx )

	Local oDlg
	Local oTempTKM
	Local nOpca := 0
	Local aButtons := {}
	Local aColor := NGCOLOR()
	Local nFILIAL	:= If((TAMSX3("TMY_FILIAL")[1]) > 0,TAMSX3("TMY_FILIAL")[1], 8)

	//Variaveis de GetDados
	Local nInd := 1
	Local cKeyGet := "", cWhileGet := ""
	Private aCols := {}, aHeader := {}
	Private aCoBrwB := {}, aHoBrwB := {}
	Private aCoBrwC := {}, aHoBrwC := {}
	Private nLenB := 0, nLenC := 0
	Private aNoFields := {}
	Private oBrwC, oBrwB

	//Variaveis de tamanho de tela e objetos
	Private aSize := {}

	//Variaveis da Tela
	Private aSvATela := {}, aSvAGets := {}
	Private aTelaVis := {}, aGetsVis := {}
	Private aTelaInc := {}, aGetsInc := {}
	Private aTelaAlt := {}, aGetsAlt := {}
	Private aTela := {}, aGets := {}
	Private oPanelEnc, oEncTKL

	//Variaveis da Tree
	Private cLocal := "001"

	//Variáveis de imagens do organograma
	Private cFolderA := "ng_ico_brigadista"
	Private cFolderB := "ng_ico_brigadista"

	//Panel de exames e treinamentos
	Private oPanelBrig
	Private oPanelInf
	Private oPanelI
	Private oPainelVis
	Private oPainelAlt
	Private oPainelInc

	//Variáveis de botões
	Private oBtnAltBrig
	Private oBtnExcBrig
	Private oBtnConf
	Private oBtnCanc

	//Variáveis utilizadas na pesquisa dos exames
	Private cFicha
	Private aExames := {}

	//Variáveis utilizadas na pesquisa dos treinamentos
	Private aTreinamento := {}

	//Variáveis do Panel do Brigadista
	Private oBrwExa
	Private oBrwTre
	Private oEncAlt
	Private bBrwExa
	Private bBrwTre

	//Variáveis do TWBrowse
	Private aTitulos := {}
	Private aTitTre  := {}

	//Variaveis de Folder
	Private oFolder560
	Private aPages    := {}, aTitles    := {}
	Private oFolderInf
	Private aPagesInf    := {}, aTitlesInf    := {}

	//Variável utilizada para filtro no SXB
	Private cCalend := ""

	//Indicacao de integracao com o treinamento
	Private lTreinamento := If( SuperGetMv( "MV_NGMDTTR" , .F. , "2" ) == "1" , .T. , .F. )

	Private cTitulo := STR0011 //"Visualização do Brigadista"
	Private oSayInf
	Private aRelac := {}
	Private nAlt := 2
	Private cMarca  := GetMark()

	//Controle da Confirmação de Tela
	Private lIncBrig	 := .F.

	//Salva a Filial selecionada
	Private cFilBrig
	//Realiza trativa de Filial
	If cFilAnt <> PadR( SM0->M0_CODFIL , Len( cFilAnt ) )
		cFilAnt := PadR( SM0->M0_CODFIL , Len( cFilAnt ) )
	EndIf
	cFilBrig := cFilAnt

	If ALTERA
		If SuperGetMv( "MV_NGMDTTR" , .F. , "2" ) == "1"
			aAdd( aButtons , { "pedido" , { | | MDT560GerTre() } , STR0012 , STR0013 } )//"Solicitação de Reserva de Treinamentos"###"Solic. Trein."
		Endif
		aAdd( aButtons , { "salvar" , { | | A560OK( nOpcx , nRecno , cAlias , .T. ) } , STR0070 , STR0069 } )//""Salvar alterações já realizadas"###Salvar"
	Endif

	//-------------------------------------------
	// Monta a GetDados dos Exames da Brigada
	//-------------------------------------------
	aAdd( aNoFields , "TKN_BRIGAD" )
	aAdd( aNoFields , "TKN_FILIAL" )

	nInd		:= 1
	cKeyGet	:= "TKL->TKL_BRIGAD"
	cWhileGet	:= "TKN->TKN_FILIAL == '" + xFilial( "TKN" ) + "' .AND. TKN->TKN_BRIGAD == '" + TKL->TKL_BRIGAD + "'"
	dbSelectArea( "TKN" )
	dbSetOrder( nInd )
	FillGetDados( nOpcx , "TKN" , 1 , cKeyGet , { | | } , { | | .T. } , aNoFields , , , , ;
						{ | | NGMontaACols( "TKN" , &cKeyGet , cWhileGet ) } )

	If Empty( aCols ) .Or. nOpcx == 3
		aCols := BLANKGETD( aHeader )
	Endif
	aCoBrwB := aClone( aCols )
	aHoBrwB := aClone( aHeader )
	nLenB   := Len( aCoBrwB )

	//-------------------------------------------
	//Monta a GetDados do Treinamento da Brigada
	//-------------------------------------------
	aCols := {}
	aHeader := {}
	aNoFields := {}

	aAdd( aNoFields , "TKO_BRIGAD" )
	aAdd( aNoFields , "TKO_FILIAL" )

	nInd		:= 1
	cKeyGet	:= "TKL->TKL_BRIGAD"
	cWhileGet	:= "TKO->TKO_FILIAL == '" + xFilial( "TKO" ) + "' .AND. TKO->TKO_BRIGAD == '" + TKL->TKL_BRIGAD + "'"

	dbSelectArea( "TKO" )
	dbSetOrder( nInd )
	FillGetDados( nOpcx , "TKO" , 1 , cKeyGet, { | | } , { | | .T.} , aNoFields , , , , ;
						{ | | NGMontaACols( "TKO" , &cKeyGet , cWhileGet ) } )

	If Empty( aCols ) .Or. nOpcx == 3
		aCols := BLANKGETD( aHeader )
	Endif
	aCoBrwC := aClone( aCols )
	aHoBrwC := aClone( aHeader )
	nLenC   := Len( aCoBrwC )

	//Definicao de tamanho de tela e objetos
	aSize := MsAdvSize( , .F. , 430 )

	//-------------------------------------------
	// Monta TRB da Árvore da Brigada
	//-------------------------------------------
	//Define campos do TRB
	aCampos := {}
	aAdd( aCampos , { "CODNIV" , "C" , 03 , 0 } )
	aAdd( aCampos , { "NIVEL"  , "N" , 03 , 0 } )
	aAdd( aCampos , { "NIVSUP" , "C" , 03 , 0 } )
	aAdd( aCampos , { "ORDEM"  , "C" , 03 , 0 } )
	aAdd( aCampos , { "CODFUN" , "C" , 05 , 0 } )
	aAdd( aCampos , { "DESFUN" , "C" , 20 , 0 } )
	If lFilMat //Verifica se campo existe.
		aAdd( aCampos , { "FILMAT" , "C" , nFILIAL , 0 } )
	Endif
	aAdd( aCampos , { "MATFUN" , "C" , 06 , 0 } )
	aAdd( aCampos , { "NOMFUN" , "C" , 30 , 0 } )
	aAdd( aCampos , { "TIPO"   , "C" , 01 , 0 } )
	aAdd( aCampos , { "DTINCL" , "D" , 08 , 0 } )
	aAdd( aCampos , { "DTSAID" , "D" , 08 , 0 } )
	aAdd( aCampos , { "ATRIB"  , "M" , 10 , 0 } )
	aAdd( aCampos , { "DELET"  , "C" , 01 , 0 } )

	//Criação do TRB
	cTRBTKM	:= GetNextAlias()

	oTempTKM := FWTemporaryTable():New( cTRBTKM, aCampos )
	oTempTKM:AddIndex( "1", {"CODNIV"} )
	oTempTKM:AddIndex( "2", {"NIVSUP"} )
	oTempTKM:AddIndex( "3", {"NIVEL"} )
	oTempTKM:AddIndex( "4", {"CODFUN"} )
	oTempTKM:AddIndex( "5", {"CODNIV","CODFUN"} )
	oTempTKM:AddIndex( "6", {"MATFUN"} )
	oTempTKM:AddIndex( "7", {"NIVSUP","CODNIV"} )
	If lFilMat //Verifica se campo FilMat existe.
		oTempTKM:AddIndex( "8", {"FILMAT","MATFUN"} )
	Endif
	oTempTKM:Create()

	//-------------------------------------------
	// INÍCIO DA MONTAGEM DA TELA
	//-------------------------------------------

	Define MsDialog oDlg Title OemToAnsi( cCadastro ) From aSize[ 7 ] , 0 To aSize[ 6 ] , aSize[ 5 ] COLOR CLR_BLACK,CLR_WHITE Of oMainWnd Pixel

		//Monta Splitter que servirá de serparador
		oSplitter := tSplitter():New( 0 , 0 , oDlg , 100 , 100 , 0 )
			oSplitter:Align := CONTROL_ALIGN_ALLCLIENT

			oPanelLeft := TPanel():New( 01 , 01 , , oSplitter , , , , , , 10 , 10 , .F. , .F. )
				oPanelLeft:nWidth	:= 8
				oPanelLeft:Align	:= CONTROL_ALIGN_LEFT

				oPnlTop := TPanel():New( 00 , 00 , , oPanelLeft , , , , , aColor[ 2 ] , aSize[ 6 ] , 12 , .F. , .F. )
					oPnlTop:Align := CONTROL_ALIGN_TOP

					oSay := tSay():New( 03 , 15 , { | | STR0004 } , oPnlTop , , , , , , .T. , aColor[ 1 ] , aColor[ 1 ] , 100 , 20 ) //"Organograma"

				oPnlBtn := TPanel():New( 00 , 00 , , oPanelLeft , , , , , aColor[ 2 ] , 12 , 12 , .F. , .F. )
					oPnlBtn:Align := CONTROL_ALIGN_LEFT
					If nOpcx == 3 .or. nOpcx == 4
						oBtnLegBrig := TBtnBmp():NewBar( "ng_ico_lgndos" , "ng_ico_lgndos" , , , , { | | MDT560Leg( 1 ) } , , oPnlBtn , , , STR0015 , , , , , "" )//"Legenda - Brigadista"
							oBtnLegBrig:Align := CONTROL_ALIGN_TOP

						oBtnIncBrig := TBtnBmp():NewBar( "ng_ico_brigaincluir" , "ng_ico_brigaincluir" , , , , { | | MDT560Alt( 3 , , 3 ) } , , oPnlBtn , , , STR0016 , , , , , "" )//"Incluir Brigadista"
							oBtnIncBrig:Align := CONTROL_ALIGN_TOP

						oBtnAltBrig := TBtnBmp():NewBar( "ng_ico_brigaalterar" , "ng_ico_brigaalterar" , , , , { | | MDT560Alt( 4 , , 4 ) } , , oPnlBtn , , , STR0017 , , , , , "" )//"Alterar Brigadista"
							oBtnAltBrig:Align := CONTROL_ALIGN_TOP

						oBtnExcBrig := TBtnBmp():NewBar( "ng_ico_brigaexcluir" , "ng_ico_brigaexcluir" , , , , { | | MDT560Exc() } , , oPnlBtn , , , STR0018 , , , , , "" )//"Excluir Brigadista"
							oBtnExcBrig:Align := CONTROL_ALIGN_TOP

						oBtnResBrig := TBtnBmp():NewBar( "ng_ico_brigarest" , "ng_ico_brigarest" , , , , { | | MDT560Exc( .T. ) } , , oPnlBtn , , , STR0068 , , , , , "" )//"Restaurar Brigadista"
							oBtnResBrig:Align := CONTROL_ALIGN_TOP
					Endif

				oTree := DbTree():New( 052 , 005 , 260 , 180 , oPanelLeft , , , .T. )
					oTree:Align    := CONTROL_ALIGN_ALLCLIENT
					oTree:nClrPane := RGB( 221 , 221 , 221 )
					oTree:bChange  := { | | Processa( { | lEnd | MDT560Crg( nOpcx , SubStr( oTree:GetCargo(), 1, 3 ) ) } , STR0019 , STR0020 , .T. ) }//"Aguarde..."###"Carregando Informações..."
					cProc := "001"
					FWMsgRun( , { | lEnd |  MDT560Tree( cProc ) }, STR0019, STR0021 ) 

			oPanelRight := TPanel():New( 01 , 01 , , oSplitter , , , , , , 10 , 10 , .F. , .F. )
				oPanelRight:nHeight := 50
				oPanelRight:Align := CONTROL_ALIGN_RIGHT

				//-------------------------------
				// Enchoice tabela TKL
				//-------------------------------

				dbSelectArea( "TKL" )
				RegToMemory( "TKL" , ( nOpcx == 3 ) )
				oPanelEnc := TPanel():New( 00 , 00 , , oPanelRight , , , , , , aSize[ 5 ] , aSize[ 6 ] , .F. , .F. )
					oPanelEnc:Align := CONTROL_ALIGN_TOP
					oPanelEnc:nHeight := 120

					oEncTKL:= MsMGet():New( "TKL" , nRecno , nOpcx , , , , , { 12 , 0 , 67.26923077 , 380 } , , , , , , oPanelEnc , , , .F. , "aSvATela" , , , , , , .T. )
						oEncTKL:oBox:Align := CONTROL_ALIGN_ALLCLIENT
						aSvATela := aClone( aTela )
						aSvAGets := aClone( aGets )

				//Paineis separadores
				oPanelBrig := TPanel():New( 00 , 00 , , oPanelRight , , , , , , aSize[ 5 ] , aSize[ 6 ] , .F. , .F. )
					oPanelBrig:Align := CONTROL_ALIGN_ALLCLIENT

				oPanelInf := TPanel():New( 00 , 00 , , oPanelRight , , , , , , aSize[ 5 ] , aSize[ 6 ] , .F. , .F. )
					oPanelInf:Align := CONTROL_ALIGN_ALLCLIENT

					oPanelInf:Hide()
					oPanelBrig:Show()

				//----------------------------------
				// Criando Folders do Nivel Brigada
				//----------------------------------
				aAdd( aTitles , OemToAnsi( STR0022 ) )//"Exames"
				aAdd( aTitles , OemToAnsi( STR0023 ) )//"Treinamentos"
				aAdd( aPages , "Header 2" )
				aAdd( aPages , "Header 3" )

				oFolder560 := TFolder():New( 7 , 0 , aTitles , aPages , oPanelBrig , , , , .F. , .F. , 1000 , 1000 , )
					oFolder560:Align := CONTROL_ALIGN_ALLCLIENT

					//----------------------------------
					// FOLDER 1 - EXAMES
					//----------------------------------
					oFolder560:aDialogs[ 1 ]:oFont := oPanelBrig:oFont
					nTelaX := ( aSize[ 6 ] / 2.02 ) - 108

					dbSelectArea( "TKN" )
					PutFileInEof( "TKN" )
					oBrwB := MsNewGetDados():New( 0 , 0 , 1000 , 1000 , If( !INCLUI .and. !ALTERA , 0 , GD_INSERT + GD_UPDATE + GD_DELETE ) , ;
														{ | | MDT560LIOK( "TKN" ) } , { | | .T. } , , , , 9999 , , , , oFolder560:aDialogs[ 1 ] , aHoBrwB , aCoBrwB )
						oBrwB:oBrowse:Refresh()

					//----------------------------------
					// FOLDER 2 - TREINAMENTOS
					//----------------------------------
					oFolder560:aDialogs[ 2 ]:oFont := oPanelBrig:oFont
					nTelaX := ( aSize[ 6 ] / 2.02 ) - 108

					dbSelectArea( "TKO" )
					PutFileInEof( "TKO" )
					oBrwC := MsNewGetDados():New( 0 , 0 , 1000 , 1000 , If( !INCLUI .and. !ALTERA , 0 , GD_INSERT + GD_UPDATE + GD_DELETE ) , ;
														{ | | MDT560LIOK( "TKO" ) } , { | | .T. } , , , , 9999 , , , , oFolder560:aDialogs[ 2 ] , aHoBrwC , aCoBrwC )
						oBrwC:oBrowse:Refresh()
						If !lTreinamento
							oFolder560:aDialogs[ 2 ]:Disable()
						Endif

				//-------------------------------------
				// Criando Folders do Nivel Brigadista
				//-------------------------------------
				aAdd( aTitlesInf , OemToAnsi( STR0024 ) )  //"Brigadista"
				aAdd( aTitlesInf , OemToAnsi( STR0022 ) )  //"Exames"
				aAdd( aTitlesInf , OemToAnsi( STR0023 ) )  //"Treinamentos"
				aAdd( aPagesInf , "Header 1" )
				aAdd( aPagesInf , "Header 2" )
				aAdd( aPagesInf , "Header 3" )

				oFolderInf := TFolder():New( 7 , 0 , aTitlesInf , aPagesInf , oPanelInf , , , , .F. , .F. , 2000 , 2000 , )
					oFolderInf:Align := CONTROL_ALIGN_ALLCLIENT

					//------------------------------------------
					//Realiza a Primeira carga de Informações
					//------------------------------------------
					MDT560Carg()

					//------------------------------------------
					// Folder 1 - Informacoes do Brigadista
					//------------------------------------------
					oPanelI := TPanel():New( 00 , 00 , , oFolderInf:aDialogs[ 1 ] , , , , , , aSize[ 5 ] , aSize[ 6 ] , .F. , .F. )
						oPanelI:Align := CONTROL_ALIGN_ALLCLIENT

					oPnlVis := TPanel():New( 00 , 00 , , oPanelI , , , , , aColor[ 2 ] , aSize[ 6 ] , 12 , .F. , .F. )
						oPnlVis:Align := CONTROL_ALIGN_TOP

						oSayInf := tSay():New( 03 , 15 , { | | cTitulo } , oPnlVis , , , , , , .T. , aColor[ 1 ] , aColor[ 1 ] , 100 , 20 )

					oPanelB := TPanel():New( 00 , 00 , , oPanelI , , , , , aColor[ 2 ] , 12 , 12 , .F. , .F. )
						oPanelB:Align := CONTROL_ALIGN_LEFT

					oBtnConf := TBtnBmp():NewBar( "ng_ico_confirmar" , "ng_ico_confirmar" , , , , { | | If( Obrigatorio( aGets , aTela ) .AND. ExistCPO( "TKU" , M->TKM_FUNCAO ) , MDT560Conf() , .F. ) } , , oPanelB , , , STR0025 , , , , , "" )//"Confirmar"
						oBtnConf:Align  := CONTROL_ALIGN_TOP

					oBtnCanc := TBtnBmp():NewBar( "ng_ico_cancelar" , "ng_ico_cancelar" , , , , { | | MDT560Canc() } , , oPanelB , , , STR0026 , , , , , "" )//"Cancelar"
						oBtnCanc:Align  := CONTROL_ALIGN_TOP

					oPainelVis := TPanel():New( 00 , 00 , , oPanelI , , , , , aColor[ 2 ] , aSize[ 6 ] , 12 , .F. , .F. )
						oPainelVis:Align := CONTROL_ALIGN_ALLCLIENT

					oPainelInc := TPanel():New( 00 , 00 , , oPanelI , , , , , aColor[ 2 ] , aSize[ 6 ] , 12 , .F. , .F. )
						oPainelInc:Align := CONTROL_ALIGN_ALLCLIENT

					oPainelAlt := TPanel():New( 00 , 00 , , oPanelI , , , , , aColor[ 2 ] , aSize[ 6 ] , 12 , .F. , .F. )
						oPainelAlt:Align := CONTROL_ALIGN_ALLCLIENT

					// Cria os Paineis de Inclusão, Alteração e Visualização
					// Necessária a criação de 3 Enchoices para a atualização de uma única apresentava problema
					dbSelectArea( "TKM" )
					RegToMemory( "TKM" , .T. )
					aNao := { "TKM_BRIGAD" , "TKM_CODNIV" , "TKM_NIVEL" , "TKM_NIVSUP" }
					aChoice := NGCAMPNSX3( "TKM" , aNao )

					aGets		:= {}
					aTela		:= {}
					oEncVis	:= MsMGet():New( "TKM" , 0 , 2 , , , , aChoice , { 12 , 0 , 67.26923077 , 380 } , , , , , , oPainelVis , , .T. , .F. , "aTelaVis" )
						oEncVis:oBox:Align := CONTROL_ALIGN_ALLCLIENT
					aTelaVis	:= aClone( aTela )
					aGetsVis	:= aClone( aGets )


					aGets		:= {}
					aTela		:= {}
					oEncInc	:= MsMGet():New( "TKM" , 0 , 3 , , , , aChoice , { 12 , 0 , 67.26923077 , 380 } , , , , , , oPainelInc , , .T. , .F. , "aTelaInc" )
						oEncInc:oBox:Align := CONTROL_ALIGN_ALLCLIENT
					aTelaInc	:= aClone( aTela )
					aGetsInc	:= aClone( aGets )

					aGets		:= {}
					aTela		:= {}
					oEncAlt	:= MsMGet():New( "TKM" , 0 , 4 , , , , aChoice , { 12 , 0 , 67.26923077 , 380 } , , , , , , oPainelAlt , , .T. , .F. , "aTelaAlt" )
						oEncAlt:oBox:Align := CONTROL_ALIGN_ALLCLIENT
					aTelaAlt	:= aClone( aTela )
					aGetsAlt	:= aClone( aGets )

					//------------------------------------------
					// Folder 2 - Exames
					//------------------------------------------
					oPanelE := TPanel():New( 00 , 00 , , oFolderInf:aDialogs[ 2 ] , , , , , , aSize[ 5 ] , aSize[ 6 ] , .F. , .F. )
						oPanelE:Align := CONTROL_ALIGN_ALLCLIENT

						oPanelBot := TPanel():New( 00 , 00 , , oPanelE , , , , , aColor[ 2 ] , 12 , 12 , .F. , .F. )
							oPanelBot:Align := CONTROL_ALIGN_LEFT

							oBtnExcLeg := TBtnBmp():NewBar( "ng_ico_lgndos" , "ng_ico_lgndos" , , , , { | | MDT560Leg( 2 ) } , , oPanelBot , , , STR0027 , , , , , "" )  //"Legenda"
								oBtnExcLeg:Align  := CONTROL_ALIGN_TOP

						aTitulos	:= { " " , STR0028 , STR0029 , STR0030 , STR0031 }//"Exame"###"Descrição"###"Dt. Prog."###"Dt. Resul."
						aColsSize	:= { 25 , 40 , 200 , 40 , 40 }
						oBrwExa	:= TWBrowse():New( 22 , 01 , 245 , 150 , , aTitulos , aColsSize , oPanelE , , , , , { | | } , , , , , , , .F. , , .T. , , .F. , , , )
							oBrwExa:Align := CONTROL_ALIGN_ALLCLIENT
							oBrwExa:SetArray( aExames )
							bBrwExa := { | | { ;
												LoadBitmap( GetResources() , MDT560Cor( aExames[ oBrwExa:nAt ] , 1 ) ) , ;
												aExames[ oBrwExa:nAt , 1 ] , ;
												aExames[ oBrwExa:nAt , 2 ] , ;
												aExames[ oBrwExa:nAt , 3 ] , ;
												aExames[ oBrwExa:nAt , 4 ] ;
												} }
							oBrwExa:bLine	:= bBrwExa
							oBrwExa:nAt	:= 1
							oBrwExa:Refresh()
					//------------------------------------------
					// Folder 3 - Treinamentos
					//------------------------------------------
					aTitTre := {}
					oPanelT := TPanel():New( 00 , 00 , , oFolderInf:aDialogs[ 3 ] , , , , , , aSize[ 5 ] , aSize[ 6 ] , .F. , .F. )
						oPanelT:Align := CONTROL_ALIGN_ALLCLIENT

						oPanelTBot := TPanel():New( 00 , 00 , , oPanelT , , , , , aColor[ 2 ] , 12 , 12 , .F. , .F. )
							oPanelTBot:Align := CONTROL_ALIGN_LEFT

							oBtnTLeg  := TBtnBmp():NewBar( "ng_ico_lgndos" , "ng_ico_lgndos" , , , , { | | MDT560Leg( 3 ) } , , oPanelTBot , , , STR0027 , , , , , "" )//"Legenda"
								oBtnTLeg:Align  := CONTROL_ALIGN_TOP

						aTitTre 	:= { " " , STR0032 , STR0033 , STR0034 , STR0035 , STR0036 }//"Treinamento"###"Código Curso"###"Desc. Curso"###"Nota"###"% Presença"
						aColsTre	:= { 25 , 40 , 40 , 100 , 40 , 40 }
						oBrwTre	:= TWBrowse():New( 22 , 01 , 245 , 150 , , aTitTre , aColsTre , oPanelT , , , , , { | | } , , , , , , , .F. , , .T. , , .F. , , , )
						oBrwTre:Align := CONTROL_ALIGN_ALLCLIENT
						oBrwTre:SetArray( aTreinamento )
						bBrwTre := { || { ;
											LoadBitmap( GetResources() , MDT560Cor( aTreinamento[ oBrwTre:nAt ] , 2 ) ) , ;
											aTreinamento[ oBrwTre:nAt , 2 ] , ;
											aTreinamento[ oBrwTre:nAt , 3 ] , ;
											aTreinamento[ oBrwTre:nAt , 4 ] , ;
											aTreinamento[ oBrwTre:nAt , 5 ] , ;
											aTreinamento[ oBrwTre:nAt , 6 ];
											} }
						oBrwTre:bLine	:= bBrwTre
						oBrwTre:nAt	:= 1
						oBrwTre:Refresh()
						If !lTreinamento
							oFolderInf:aDialogs[ 3 ]:Disable()
						Endif

					//Caso seja Inclusao ou Alteração, esconde os paineis
					If nOpcx == 3 .or. nOpcx == 4
						oBtnAltBrig:Hide()
						oBtnExcBrig:Hide()
						oBtnResBrig:Hide()
					Endif

					//Desabilita botões de interação dos brigadistas
					oBtnConf:Hide()
					oBtnCanc:Hide()
					//Habilita apenas o painel de visualização inicialmente
					oPainelAlt:Hide()
					oPainelInc:Hide()
					oPainelVis:Show()

		//Realiza tratativas de inicialização
		dbSelectArea( "TKM" )
		RegToMemory( "TKM" , .F. )

		//Click da Direita
		If Len(aSMenu) > 0
			NGPOPUP( asMenu , @oMenu )
			oDlg:bRClicked := { | o , x , y | oMenu:Activate( x , y , oDlg ) }
			oEncTKL:oBox:bRClicked := { | o , x , y | oMenu:Activate( x , y , oDlg ) }
		Endif
		oEncTKL:SetFocus()

	Activate MsDialog oDlg On Init EnchoiceBar( oDlg , ;
														{ | | nOpca := 1 , If( A560Ok( nOpcx ) , oDlg:End() , nOpca := 0 ) } , ;
														{ | | oDlg:End() } , , aButtons ) Centered

	If nOpca == 1
		A560GRAVA( cAlias , nRecno , nOpcx )
	Endif

	oTempTKM:Delete()

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} A560Ok
Realiza validações de consistência de dados

@return lRet Lógico Retorna verdadeiro quando critica de validação for correta

@param nOpcx Numerico Opção de Manutenção ( 3 - Inclusão ; 4 - Alteração ; 5 - Exclusão )
@param nRecnoX Numerico Recno posicionado da tabela
@param cAliasX Caracter Tabela em utilização
@param lBtn Logico Indica se deve ou não realizar a gravação

@sample A560Ok( 3 , 0 , 'TKN' )

@author Jackson Machado
@since 13/05/2011
/*/
//---------------------------------------------------------------------
Static Function A560Ok( nOpcx , nRecnoX , cAliasX , lBtn )

	Local lRet			:= .T.
	Local aTelaTKL	:= oEncTKL:aTela
	Local aGetsTKL	:= oEncTKL:aGets

	Default nRecnoX := 0
	Default cAliasX := ""

	//Realiza cópia das atuais GetDados (Exames e Treinamentos)
	aCoBrwB := aClone( oBrwB:aCols )
	aCoBrwC := aClone( oBrwC:aCols )

	If nOpcx != 2 .And. nOpcx != 5

		//Verifica se esta incluindo Brigadista
		If lIncBrig
			ShowHelpDlg( "ATENÇÃO" , ;
							{ "Não é possível a confirmação da tela" } , 2 , ;
							{ "Para confirmar a brigada primeiro confirme a inclusão/alteração do participante." } , 2 )
			lRet := .F.
		EndIf

		//Verifica Enchoice
		If lRet .And. !Obrigatorio(aGetsTKL,aTelaTKL)
			lRet := .F.
		Endif

		//Verifica GetDados de Exames
		If lRet .And. !MDT560LIOK("TKN",.T.)
			lRet := .F.
		Endif

		//Verifica GetDados de Treinamentos
		If lRet .And. !MDT560LIOK("TKO",.T.)
			lRet := .F.
		Endif

	Elseif nOpcx == 5

		If !NGCHKDEL("TKL")
			lRet := .F.
		Endif

	Endif

	If lBtn
		A560GRAVA(cAliasX,nRecnoX,nOpcx)
	Endif

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} A560GRAVA
Função de Gravação do Registro da Brigada

@return Sempre Nulo

@param cAliasX Caracter Tabela em utilização
@param nRecnoX Numerico Recno posicionado da tabela
@param nOpcx Numerico Opção de Manutenção ( 3 - Inclusão ; 4 - Alteração ; 5 - Exclusão )

@sample A560GRAVA( 'TKN' , 0 , 3 )

@author Jackson Machado
@since 13/05/2011
/*/
//---------------------------------------------------------------------
Static Function A560GRAVA( cAliasX , nRecnoX , nOpcx )

	Local i, j, ny
	Local aArea := GetArea()
	Local cKey, cWhile, cKey2
	Local nTipAtu ,aWFAviso := {}
	Local lLocTKL

	//------------------------
	// Manipula a tabela TKL
	//------------------------
	dbSelectArea( "TKL" )
	dbSetOrder( 1 )
	If nOpcx == 3
		ConfirmSX8()
	Endif
	lLocTKL := dbSeek( xFilial( "TKL" ) + M->TKL_BRIGAD )
	RecLock( "TKL" , !lLocTKL )
	If nOpcx <> 5
		TKL->TKL_FILIAL := xFilial( "TKL" )
		dbSelectArea( "TKL" )
		dbSetOrder( 1 )
		For i := 1 To FCount()
			If Alltrim( FieldName( i ) ) $ "TKL_FILIAL"
				Loop
			EndIf
			x  := "M->" + FieldName( i )
			y  := "TKL->" + FieldName( i )
			&y := &x
		Next i
	Else
		dbDelete()
	EndIf
	MsUnLock( "TKL" )

	//------------------------
	// Manipula a tabela TKM
	//------------------------

	dbSelectArea( cTRBTKM )
	dbSetOrder( 1 )
	dbGoTop()
	While ( cTRBTKM )->( !Eof() )
		If nOpcx == 5
			dbSelectArea( "TKM" )
			dbSetOrder( 5 )
			If dbSeek( xFilial( "TKM" ) + M->TKL_BRIGAD + ( cTRBTKM )->MATFUN )
				RecLock( "TKM" , .F. )
				TKM->( dbDelete() )
				TKM->( MsUnLock( ) )
			Endif
		Else
			If ( cTRBTKM )->CODNIV == "001"
				dbSelectArea( cTRBTKM )
				dbSkip()
				Loop
			Endif
			If Empty( ( cTRBTKM )->DELET )
				dbSelectArea( "TKM" )
				dbSetOrder( 5 )
				If dbSeek( xFilial( "TKM" ) + M->TKL_BRIGAD + ( cTRBTKM )->MATFUN )
					RecLock( "TKM" , .F. )
					nTipAtu := 2
				Else
					RecLock( "TKM" , .T. )
					nTipAtu := 1
				Endif
				If nTipAtu == 2
				 	If 	TKM->TKM_MATFUN == ( cTRBTKM )->MATFUN .And.	TKM->TKM_DTINCL <> ( cTRBTKM )->DTINCL .Or. ;
						TKM->TKM_DTSAID	<> ( cTRBTKM )->DTSAID .Or. ;
						TKM->TKM_FUNCAO	<> ( cTRBTKM )->CODFUN .Or. ;
						TKM->TKM_TIPO <> ( cTRBTKM )->TIPO

						aAdd( aWFAviso , { ( cTRBTKM )->MATFUN , ( cTRBTKM )->CODFUN , ( cTRBTKM )->DTINCL , ( cTRBTKM )->DTSAID , nTipAtu } )

					EndIf
				Else
					aAdd( aWFAviso , { ( cTRBTKM )->MATFUN , ( cTRBTKM )->CODFUN , ( cTRBTKM )->DTINCL , ( cTRBTKM )->DTSAID , nTipAtu } )
				EndIf
				TKM->TKM_FILIAL	:= xFilial( "TKM" )
				TKM->TKM_BRIGAD	:= M->TKL_BRIGAD    	//Brigada
				TKM->TKM_CODNIV	:= ( cTRBTKM )->CODNIV	//Código do Nivel
				TKM->TKM_NIVEL	:= ( cTRBTKM )->NIVEL   //Nivel
				TKM->TKM_NIVSUP	:= ( cTRBTKM )->NIVSUP	//C. Nivel Sup
				TKM->TKM_ORDEM	:= ( cTRBTKM )->ORDEM 	//Ordem
				If lFilMat //Verifica se campo existe.
					TKM->TKM_FILMAT	:= ( cTRBTKM )->FILMAT	//Filial do Componente
				Endif
				TKM->TKM_MATFUN	:= ( cTRBTKM )->MATFUN	//Componente
				TKM->TKM_TIPO	:= ( cTRBTKM )->TIPO  	//Tipo
				TKM->TKM_DTINCL	:= ( cTRBTKM )->DTINCL	//Dt. Inclusao
				TKM->TKM_DTSAID	:= ( cTRBTKM )->DTSAID	//Dt. Saida
				TKM->TKM_FUNCAO	:= ( cTRBTKM )->CODFUN	//Funcao
				TKM->TKM_ATRIB 	:= ( cTRBTKM )->ATRIB 	//Atribuicoes
				TKM->( MsUnLock() )
			Elseif !Empty( ( cTRBTKM )->DELET )
				dbSelectArea( "TKM" )
				dbSetOrder( 5 )
				If dbSeek( xFilial( "TKM" ) + M->TKL_BRIGAD + ( cTRBTKM )->MATFUN )
					aAdd( aWFAviso , { ( cTRBTKM )->MATFUN , ( cTRBTKM )->CODFUN , ( cTRBTKM )->DTINCL , ( cTRBTKM )->DTSAID , 3 } )
					RecLock( "TKM" , .F. )
					TKM->( dbDelete() )
					TKM->( MsUnLock() )
				Endif
			Endif
		Endif
	 	dbSelectArea( cTRBTKM )
		dbSkip()
	End

	If ExistBlock( "MDTA5601" )
		ExecBlock( "MDTA5601" , .F. , .F. , { aWFAviso , M->TKL_BRIGAD } )
	EndIf

	//------------------------
	// Manipula a tabela TKN
	//------------------------
	nPosCod	:= aScan( aHoBrwB , { | x | Trim( Upper(x[ 2 ] ) ) == "TKN_EXAME" } )
	nOrd		:= 1
	cKey		:= xFilial( "TKM" ) + M->TKL_BRIGAD
	cWhile		:= "xFilial( 'TKM' ) + M->TKL_BRIGAD == TKN->TKN_FILIAL + TKN->TKN_BRIGAD"
	If nOpcx == 5
		dbSelectArea( "TKN" )
		dbSetOrder( nOrd )
		dbSeek( cKey )
		While TKN->( !Eof() ) .and. &( cWhile )
			RecLock( "TKN" , .F. )
			TKN->( dbDelete() )
			TKN->( MsUnLock() )
			dbSelectArea( "TKN" )
			TKN->( dbSkip() )
		End
	Else
		If Len( aCoBrwB ) > 0
			//Coloca os deletados por primeiro
			aSort( aCoBrwB , , , { | x , y | x[ Len( aCoBrwB[ 1 ] ) ] .and. !y[ Len( aCoBrwB[ 1 ] ) ] } )

			For i := 1 To Len( aCoBrwB )
				If !aCoBrwB[ i , Len( aCoBrwB[ i ] ) ] .and. !Empty( aCoBrwB[ i , nPosCod ] )
					dbSelectArea( "TKN" )
					dbSetOrder( nOrd )
					If dbSeek( xFilial( "TKN" ) + M->TKL_BRIGAD + aCoBrwB[ i , nPosCod ] )
						RecLock( "TKN" , .F. )
					Else
						RecLock( "TKN" , .T. )
					Endif
					For j := 1 to FCount()
						If "_FILIAL" $ Upper( FieldName( j ) )
							FieldPut( j , xFilial( "TKN" ) )
						ElseIf "_BRIGAD" $ Upper( FieldName( j ) )
							FieldPut( j , M->TKL_BRIGAD )
						ElseIf ( nPos := aScan( aHoBrwB , { | x | Trim( Upper( x[ 2 ] ) ) == Trim( Upper( FieldName( j ) ) ) } ) ) > 0
							FieldPut( j , aCoBrwB[ i , nPos ] )
						Endif
					Next j
					TKN->( MsUnlock() )
				Elseif !Empty( aCoBrwB[ i , nPosCod ] )
					dbSelectArea( "TKN" )
					dbSetOrder( nOrd )
					If dbSeek( xFilial( "TKN" ) + M->TKL_BRIGAD + aCoBrwB[ i , nPosCod ] )
						RecLock( "TKN" , .F. )
						TKN->( dbDelete() )
						TKN->( MsUnlock() )
					Endif
				Endif
			Next i
		Endif
		dbSelectArea( "TKN" )
		dbSetOrder( nOrd )
		dbSeek( cKey )
		While TKN->( !Eof() ) .and. &( cWhile )
			If aScan( aCoBrwB , { | x | x[ nPosCod ] == TKN->TKN_EXAME .AND. !x[ Len( x ) ] } ) == 0
				RecLock( "TKN" , .F. )
				TKN->( dbDelete() )
				TKN->( MsUnlock() )
			Endif
			dbSelectArea( "TKN" )
			TKN->( dbSkip() )
		End
	Endif

	//------------------------
	// Manipula a tabela TKO
	//------------------------
	nPosCod	:= aScan( aHoBrwC , { | x | Trim( Upper( x[ 2 ] ) ) == "TKO_CODTRE" } )
	nPosCur	:= aScan( aHoBrwC , { | x | Trim( Upper( x[ 2 ] ) ) == "TKO_CURSO" } )
	nOrd		:= 3
	cKey		:= xFilial( "TKO" ) + M->TKL_BRIGAD
	cWhile		:= "xFilial( 'TKO' ) + M->TKL_BRIGAD == TKO->TKO_FILIAL + TKO->TKO_BRIGAD"
	If nOpcx == 5
		dbSelectArea( "TKO" )
		dbSetOrder( nOrd )
		dbSeek( cKey )
		While TKO->( !Eof() ) .and. &( cWhile )
			RecLock( "TKO" , .F. )
			TKO->( dbDelete() )
			TKO->( MsUnLock() )
			dbSelectArea( "TKO" )
			TKO->( dbSkip() )
		End
	Else
		If Len( aCoBrwC ) > 0
			//Coloca os deletados por primeiro
			aSort( aCoBrwC , , , { | x , y | x[ Len( aCoBrwC[ 1 ] ) ] .and. !y[ Len( aCoBrwC[ 1 ] ) ] } )

			For i := 1 to Len( aCoBrwC )
				If 	!aCoBrwC[ i , Len( aCoBrwC[ i ] ) ] .And. ;
					!Empty( aCoBrwC[ i , nPosCod ] ) .And. ;
					!Empty( aCoBrwC[ i , nPosCur ] )

					dbSelectArea( "TKO" )
					dbSetOrder( nOrd )
					If dbSeek( xFilial( "TKO" ) + M->TKL_BRIGAD + aCoBrwC[ i , nPosCur ] + aCoBrwC[ i , nPosCod ] )
						RecLock( "TKO" , .F. )
					Else
						RecLock( "TKO" , .T. )
					Endif
					For j := 1 to FCount()
						If "_FILIAL" $ Upper( FieldName( j ) )
							FieldPut( j , xFilial( "TKO" ) )
						ElseIf "_BRIGAD" $ Upper( FieldName( j ) )
							FieldPut( j , M->TKL_BRIGAD )
						ElseIf ( nPos := aScan( aHoBrwC , { | x | Trim( Upper( x[ 2 ] ) ) == Trim( Upper( FieldName( j ) ) ) } ) ) > 0
							FieldPut( j , aCoBrwC[ i , nPos ] )
						Endif
					Next j
					TKO->( MsUnlock() )
				Elseif !Empty( aCoBrwC[ i , nPosCod ] ) .And. !Empty( aCoBrwC[ i , nPosCur ] )
					dbSelectArea( "TKO" )
					dbSetOrder( nOrd )
					If dbSeek( xFilial( "TKO" ) + M->TKL_BRIGAD + aCoBrwC[ i , nPosCur ] + aCoBrwC[ i , nPosCod ] )
						RecLock( "TKO" , .F. )
						TKO->( dbDelete() )
						TKO->( MsUnlock() )
					Endif
				Endif
			Next i
		Endif
		dbSelectArea( "TKO" )
		dbSetOrder( nOrd )
		dbSeek( cKey )
		While TKO->( !Eof() ) .and. &( cWhile )
			If aScan( aCoBrwC , { | x | x[ nPosCod ] == TKO->TKO_CODTRE .AND. x[ nPosCur ] == TKO->TKO_CURSO .AND. !x[ Len( x ) ] } ) == 0
				RecLock( "TKO" , .F. )
				TKO->( dbDelete() )
				TKO->( MsUnlock() )
			Endif
			dbSelectArea( "TKO" )
			TKO->( dbSkip() )
		End
	Endif

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT560LIOK
Critica as Linhas das GetDados (TKN e TKO)

@return lRet Lógico Caso linha(s) esteja(m) correta(s), retorna verdadeiro

@param cAlias Caracter Tabela a ser validada
@param lFim Logico Indica se é TudoOk

@sample MDT560LIOK( 'TKN' )

@author Jackson Machado
@since 13/05/2011
/*/
//---------------------------------------------------------------------
Static Function MDT560LIOK( cAlias , lFim )

	Local f, nCols, nHead
	Local nPosCod			:= 1, nPosFai := 0, nAt := 1
	Local aColsOk			:= {}, aHeadOk := {}
	Local lRet				:= .T.
	Local lTreinamento	:= If( SuperGetMv( "MV_NGMDTTR" , .F. , "2" ) == "1" , .T. , .F. )
	Local lValTrm			:= .T.

	Default lFim := .F.

	//Caso Integração com o Treinamento não esteja ativo, não valida
	If cAlias == "TKO" .and. !lTreinamento
		lValTrm := .F.
	Endif

	If lValTrm//Caso não seja treinamento, ou haja integração, valida
		//Verifica qual GetDados está sendo a validação
		If cAlias == "TKN"
			aColsOk	:= aClone( oBrwB:aCols )
			aHeadOk	:= aClone( aHoBrwB )
			nAt			:= oBrwB:nAt
			nPosCod	:= aScan( aHoBrwB , { | x | Trim( Upper( x[ 2 ] ) ) == "TKN_EXAME" } )
			nPosFai	:= aScan( aHoBrwB , { | x | Trim( Upper( x[ 2 ] ) ) == "TKN_FAIXA" } )
		ElseIf cAlias == "TKO"
			aColsOk	:= aClone( oBrwC:aCols )
			aHeadOk	:= aClone( aHoBrwC )
			nAt			:= oBrwC:nAt
			nPosCod	:= aScan( aHoBrwC , { | x | Trim( Upper( x[ 2 ] ) ) == "TKO_CODTRE" } )
			nPosFai	:= aScan( aHoBrwC , { | x | Trim( Upper( x[ 2 ] ) ) == "TKO_CURSO" } )
		Endif

		If lFim//Caso for validação Final, apenas verifica se um campo foi preenchido e o outro não
			For nCols := 1 To Len( aColsOk )
				If 	!aColsOk[ nCols , Len( aColsOk[ nCols ] ) ] .And. ;
					!Empty( aColsOk[ nCols , nPosCod ] ) .And. Empty( aColsOk[ nCols , nPosFai ] )
					Help( 1 , " " , "OBRIGAT2" , , aHeadOk[ nCols , nPosFai ] , 3 , 0 )
					lRet := .F.
				Elseif !aColsOk[ nCols , Len( aColsOk[ nCols ] ) ] .And. ;
						Empty( aColsOk[ nCols , nPosCod ] ) .And. !Empty( aColsOk[ nCols , nPosFai ] )
					Help( 1 , " " , "OBRIGAT2" , , aHeadOk[ nCols , nPosCod ] , 3 , 0 )
					lRet := .F.
				Endif
				//Caso encontre algum erro sai da verificação
				If !lRet
					Exit
				EndIf
			Next nCols
		Else
			//Percorre aCols
			For f := 1 to Len( aColsOk )
				If !aColsOk[ f , Len( aColsOk[ f ] ) ]
					If f == nAt
						//VerIfica se os campos obrigatórios estão preenchidos
						If Empty( aColsOk[ f , nPosCod ] )
							//Mostra mensagem de Help
							Help( " " , 1 , "OBRIGAT2" , , aHeadOk[ nPosCod , 1 ] , 3 , 0 )
							lRet := .F.
						ElseIf nPosFai > 0 .and. Empty( aColsOk[ f , nPosFai ] )
							//Mostra mensagem de Help
							Help( " " , 1 , "OBRIGAT2" , , aHeadOk[ nPosFai , 1 ] , 3 , 0 )
							lRet := .F.
						Endif
					Endif
					//Caso encontre algum erro sai da verificação
					If !lRet
						Exit
					EndIf

					//Verifica se é somente LinhaOk
					If f <> nAt .and. !aColsOk[ nAt , Len( aColsOk[ nAt ] ) ]
						If 	aColsOk[ f , nPosCod ] == aColsOk[ nAt , nPosCod ] .And. ;
							aColsOk[ f , nPosFai ] == aColsOk[ nAt , nPosFai ]
							Help( " " , 1 , "JAEXISTINF" , , aHeadOk[ nPosCod , 1 ] )
							lRet := .F.
						Endif
					Endif
					//Caso encontre algum erro sai da verificação
					If !lRet
						Exit
					EndIf
				Endif
			Next f
		EndIf
	EndIf

	//Posiciona tabelas em final de arquivo
	PutFileInEof( "TKN" )
	PutFileInEof( "TKO" )

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT560Tree
Monta a estrutura apartir do arquivo TKM

@return Objeto Objeto da Tree montada

@param cPai Caracter Código do Item Pai

@sample MDT560Tree( '001' )

@author Jackson Machado
@since 02/06/2011
/*/
//---------------------------------------------------------------------
Static Function MDT560Tree( cPai )

	Local aNodes   := {}
	Local cPredio  := "ng_ico_brigada"
	Local cComp    := ""
	Local cDescri  := ""
	Local cMat     := ""
	Local cFun     := ""
	Local nRec     := 0
	Local nTree    := 0
	Local cFilTKU  := FWxFilial( 'TKU' )
	Local cFilSRA  := FWxFilial( 'SRA' )
	Local cFilTKM  := FWxFilial( 'TKM' )
	
	RecLock( cTRBTKM , .T. )
	( cTRBTKM )->CODNIV  := "001"
	( cTRBTKM )->NIVEL   := 1
	( cTRBTKM )->NIVSUP  := "000"
	( cTRBTKM )->ORDEM   := "001"
	( cTRBTKM )->DESFUN  := STR0002//"BRIGADA"
	( cTRBTKM )->( MsUnLock() )

	DbAddTree oTree Prompt Padr( STR0002 , 56 ) Opened Resource cPredio Cargo "001" //"BRIGADA"
	
	If !INCLUI
		dbSelectArea( "TKM" )
		dbSetOrder( 2 )
		dbSeek( cFilTKM + TKL->TKL_BRIGAD + cPai )
		ProcRegua( RecCount() )
		While TKM->( !Eof() ) .and. TKM->TKM_BRIGAD + TKM->TKM_NIVSUP == TKL->TKL_BRIGAD + cPai .And. cFilTKM == TKM->TKM_FILIAL

			IncProc() // Incrementa regua de processamento

			nRec		:= Recno()
			cComp		:= TKM->TKM_CODNIV
			cDescri	    := TKM->TKM_FUNCAO + " - " + NGSEEK( "TKU" , TKM->TKM_FUNCAO , 1 , "TKU_DESC" )
			cMat		:= TKM->TKM_MATFUN
			cFun		:= TKM->TKM_FUNCAO

			dbSelectArea( cTRBTKM )
			dbSetOrder( 6 )
			RecLock( cTRBTKM , !dbSeek( TKM->TKM_MATFUN ) )
			( cTRBTKM )->CODNIV	:= TKM->TKM_CODNIV
			( cTRBTKM )->NIVEL 	:= TKM->TKM_NIVEL
			( cTRBTKM )->NIVSUP	:= TKM->TKM_NIVSUP
			( cTRBTKM )->ORDEM	:= TKM->TKM_ORDEM
			( cTRBTKM )->CODFUN	:= TKM->TKM_FUNCAO
			( cTRBTKM )->DESFUN	:= NGSEEK( "TKU" , TKM->TKM_FUNCAO , 1 , "TKU_DESC" )
			If lFilMat //Verifica se campo existe.
				( cTRBTKM )->FILMAT	:= TKM->TKM_FILMAT
			Endif
			( cTRBTKM )->MATFUN	:= TKM->TKM_MATFUN
			( cTRBTKM )->NOMFUN	:= NGSEEK( "SRA" , TKM->TKM_MATFUN , 1 , "RA_NOME" )
			( cTRBTKM )->TIPO	:= TKM->TKM_TIPO
			( cTRBTKM )->DTINCL	:= TKM->TKM_DTINCL
			( cTRBTKM )->DTSAID	:= TKM->TKM_DTSAID
			( cTRBTKM )->ATRIB	:= TKM->TKM_ATRIB
			( cTRBTKM )->( MsUnLock() )

			aAdd( aNodes,{ TKM->TKM_NIVSUP, TKM->TKM_CODNIV, cDescri } )
			
			dbSelectArea( "TKM" )
			dbSetOrder( 2 )
			If dbSeek( cFilTKM + TKL->TKL_BRIGAD + cComp )
				MDT560Son( cComp, @aNodes, cFilTKU, cFilSRA, cFilTKM )
			Endif

			dbSelectArea( "TKM" )
			dbGoTo( nRec )
			TKM->( dbSkip() )
		End

		If Len( aNodes ) > 0

			// Realizada ordenação para criação da arvore TKM->TKM_NIVSUP + TKM->TKM_CODNIV
			aSort( aNodes, , , { | x, y | x[ 1 ] + x[ 2 ] < y[ 1 ] + y[ 2 ] } )

			For nTree := 1 to Len( aNodes )
				oTree:TreeSeek( aNodes[ nTree, 1 ] )
				oTree:AddItem( aNodes[ nTree, 3 ], aNodes[ nTree, 2 ], cFolderA, cFolderB, , , 2 )
			Next nTree

			oTree:TreeSeek( cPai )
			oTree:PtCollapse()
			
		EndIf

	Endif
	
	DbEndTree oTree

Return oTree

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT560Son
Monta a estrutura dos filhos

@return Sempre Nulo

@param cPai   , Caracter, Código do Item Pai
@param aNodes , array   , array contendo os informações para criação da tree
					  [ 1 ] - TKM_NIVSUP
					  [ 2 ] - TKM_CODNIV
					  [ 3 ] - Compatibilidade
					  [ 4 ] - TKM_FUNCAO
					  [ 5 ] - Imagem quando estiver aberto
					  [ 6 ] - Imagem quando estiver fechado

@param cFilTKU , caracter   , Filial referente a tabela TKU
@param cFilSRA , caracter   , Filial referente a tabela SRA
@param cFilTKM , caracter   , Filial referente a tabela TKM
@param [nNvMax], numérico   , define limite máximo da recursividade

@sample MDT560Son( '001', aNodes )

@author Jackson Machado
@since 02/06/2011
/*/
//---------------------------------------------------------------------
Static Function MDT560Son( cPai, aNodes, cFilTKU, cFilSRA, cFilTKM, nNvMax )

	Local aBind      As Array
	Local cAlsSonTKM As Character

	Default nNvMax := 1

	/*----------------------------------------+
	| Verifica a existência da query em cache |
	+----------------------------------------*/
	If Empty( cQrySonTKM )
		
		cQrySonTKM := 'SELECT TKM.*, '
		cQrySonTKM += '       TKU.TKU_DESC AS TKM_DESFUN, '
		cQrySonTKM += '       SRA.RA_NOME AS TKM_NOMFUN ' 
		cQrySonTKM += 'FROM' + RetSqlName( 'TKM' ) + ' TKM '
		cQrySonTKM += '    INNER JOIN ' + RetSqlName( 'TKU' ) + ' TKU '
		cQrySonTKM += '        ON TKU.TKU_FILIAL = ? AND TKU.TKU_CODIGO = TKM.TKM_FUNCAO '
		cQrySonTKM += '    INNER JOIN ' + RetSqlName( 'SRA' )  + ' SRA '
		cQrySonTKM += '        ON SRA.RA_FILIAL = ? AND SRA.RA_MAT = TKM.TKM_MATFUN '
		cQrySonTKM += ' WHERE TKM.TKM_FILIAL = ? '
		cQrySonTKM += '   AND TKM.TKM_BRIGAD = ? '
		cQrySonTKM += '   AND TKM.TKM_NIVSUP = ? '
		cQrySonTKM += '   AND TKM.D_E_L_E_T_ = ? '
		
		cQrySonTKM := ChangeQuery( cQrySonTKM )

	EndIf

	aBind := {}
	aAdd( aBind, cFilTKU )
	aAdd( aBind, cFilSRA )
	aAdd( aBind, cFilTKM )
	aAdd( aBind, TKL->TKL_BRIGAD )
	aAdd( aBind, cPai )
	aAdd( aBind, Space( 1 ) )

	cAlsSonTKM := GetNextAlias()

	dbUseArea( .T., 'TOPCONN', TcGenQry2( , , cQrySonTKM, aBind ), cAlsSonTKM, .T., .T. )

	(cAlsSonTKM)->( dbGoTop() )
	Do While (cAlsSonTKM)->( !EoF() )

		dbSelectArea( cTRBTKM )
		dbSetOrder( 6 )
		RecLock( cTRBTKM , !dbSeek( (cAlsSonTKM)->TKM_MATFUN ) )
		( cTRBTKM )->CODNIV	:= (cAlsSonTKM)->TKM_CODNIV
		( cTRBTKM )->NIVEL 	:= (cAlsSonTKM)->TKM_NIVEL
		( cTRBTKM )->NIVSUP	:= (cAlsSonTKM)->TKM_NIVSUP
		( cTRBTKM )->ORDEM	:= (cAlsSonTKM)->TKM_ORDEM
		( cTRBTKM )->CODFUN	:= (cAlsSonTKM)->TKM_FUNCAO
		( cTRBTKM )->DESFUN	:= (cAlsSonTKM)->TKM_DESFUN
		If lFilMat //Verifica se campo existe.
			( cTRBTKM )->FILMAT	:= (cAlsSonTKM)->TKM_FILMAT
		EndIf
		( cTRBTKM )->MATFUN	:= (cAlsSonTKM)->TKM_MATFUN
		( cTRBTKM )->NOMFUN	:= (cAlsSonTKM)->TKM_NOMFUN
		( cTRBTKM )->TIPO	:= (cAlsSonTKM)->TKM_TIPO
		( cTRBTKM )->DTINCL	:= StoD( (cAlsSonTKM)->TKM_DTINCL )
		( cTRBTKM )->DTSAID	:= Stod( (cAlsSonTKM)->TKM_DTSAID )
		( cTRBTKM )->ATRIB	:= Posicione( 'TKM', 1, cFilTKM + TKL->TKL_BRIGAD + (cAlsSonTKM)->TKM_CODNIV, 'TKM_ATRIB' )
		( cTRBTKM )->( MsUnLock() )

		aAdd( aNodes, { (cAlsSonTKM)->TKM_NIVSUP, (cAlsSonTKM)->TKM_CODNIV,(cAlsSonTKM)->TKM_FUNCAO + ' - ' + (cAlsSonTKM)->TKM_DESFUN } )

		If nNvMax <= 150
			DbSelectArea( 'TKM' )
			dbSetOrder( 2 )
			If dbSeek( (cAlsSonTKM)->TKM_FILIAL + TKL->TKL_BRIGAD + (cAlsSonTKM)->TKM_CODNIV )
				DbSelectArea( cTRBTKM )
				dbSetOrder( 3 )
				If !dbSeek( TKM->TKM_NIVEL )
					nNvMax++
				EndIf
				MDT560Son( (cAlsSonTKM)->TKM_CODNIV, @aNodes, cFilTKU, cFilSRA, cFilTKM, @nNvMax )
			EndIf
		EndIf

		(cAlsSonTKM)->( dbSkip() )

		/*--------------------------------------------------+
		| Desaloca consumo de memória p/ melhor performance |
		+--------------------------------------------------*/
		aBind := Nil 

	End Do

	(cAlsSonTKM)->( dbCloseArea() )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT560DAT
Valida as datas

@return Sempre Nulo

@param cData Caracter Data a ser validada

@sample MDT560DAT( 'TKL_DTVIIN' )

@author Jackson Machado
@since 13/05/2011
/*/
//---------------------------------------------------------------------
Function MDT560DAT( cData )

	Local dDtVlEm
	Local dVlDt	:= &( cData )
	Local lRet		:= .T.

	If "_DTVIIN" $ cData
		dDtVlEm := M->TKL_DTVIFI
	Elseif "_DTVIFI" $ cData
		dDtVlEm := M->TKL_DTVIIN
	Endif

	If Empty( dVlDt )
		HELP( " " , 1 , "NAOVAZIO" )
		lRet := .F.
	ElseIf !Empty( dVlDt ) .AND. !Empty( dDtVlEm )
		lRet := VALDATA( M->TKL_DTVIIN , M->TKL_DTVIFI , "DATAMENOR" )
	Endif

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MDTVERFUN
Valida a inclusão do brigadistas

@return lRet Lógico Retorna verdadeiro quando funcionário incluido for válido

@param cMat Caracter Matrículo do Funcionário a ser incluído como Brigadista

@sample MDTVERFUN( '000001' )

@author Jackson Machado
@since 13/05/2011
/*/
//---------------------------------------------------------------------
Function MDTVERFUN( cMat , cFilMat )

	Local lRet := .T.

	Default cFilMat := cFilAnt

	If !Empty(cMat)
		dbSelectArea( cTRBTKM )
		If lFilMat //Verifica se existe o campo FilMat
			dbSetOrder( 8 )
			If dbSeek( cFilMat + cMat )
				If Empty( ( cTRBTKM )->DELET )
					lRet := .F.
				Endif
			Endif
		Else
			dbSetOrder( 6 )
			If dbSeek( cMat )
				If Empty( ( cTRBTKM )->DELET )
					lRet := .F.
				Endif
			Endif
		EndIf

		If lRet
			If lFilMat //Verifica se existe o campo FilMat
				dbSelectArea( "TKM" )
				dbSetOrder( 8 )//TKM_FILIAL+TKM_BRIGAD+TKM_FILMAT+TKM_MATFUN
				If dbSeek( xFilial( "TKM" ) + M->TKL_BRIGAD + cFilMat + cMat )
					lRet := .F.
				Endif
			Else
				dbSelectArea( "TKM" )
				dbSetOrder( 5 )//TKM_FILIAL+TKM_BRIGAD+TKM_MATFUN
				If dbSeek( xFilial( "TKM" ) + M->TKL_BRIGAD + cMat )
					lRet := .F.
				Endif
			Endif

		EndIf

		If !lRet
			ShowHelpDlg( "JAEXIST" , ;
								{ STR0038 } , 2 , ;//"Brigadista já adicionado a Brigada."
								{ STR0039 } , 2 )//"Informar um código diferente."
		EndIf

		If lRet
			lRet := MDT575CHKE( "SRA" , "M->TKM_MATFUN" , "SRA->RA_MAT" )
		Endif
	Endif

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MDTDTVIG
Valida a vigencia da brigada

@return lRet Logico Retorna verdadeiro quando vigencia da brigada for correta

@param dInicio Data Data de Início da Vigência
@param dFim Data Data de Termino da Vigência

@sample MDTDTVIG( '01/01/2011' , '31/12/2011' )

@author Jackson Machado
@since 13/05/2011
/*/
//---------------------------------------------------------------------
Function MDTDTVIG( dInicio , dFim )

	Local lRet := .T.

	If !Empty( dInicio ) .AND. !Empty( dFim )
		lRet := VALDATA( dInicio , dFim , "DATAMENOR" )
	Endif

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT560Crg
Carrega as Informações do Nível

@return Sempre verdadeiro

@param nOpcx Numerico Opção de Manutenção
@param cNiv Caracter Nivel a ser carregado

@sample MDT560Crg( 3 , '001' )

@author Jackson Machado
@since 13/05/2011
/*/
//---------------------------------------------------------------------
Static Function MDT560Crg( nOpcx , cNiv )

	Local i

	If cNiv == "001"
		oPanelInf:Hide()
		oPanelBrig:Show()
		If nOpcx == 3 .Or. nOpcx == 4
			oBtnAltBrig:Hide()
			oBtnExcBrig:Hide()
			oBtnResBrig:Hide()
		Endif
	Else
		If nOpcx == 3 .or. nOpcx == 4
			oBtnAltBrig:Show()
			dbSelectArea( cTRBTKM )
			dbSetOrder( 1 )
			dbSeek( oTree:GetCargo() )
			If Empty( ( cTRBTKM )->DELET )
				oBtnResBrig:Hide()
				oBtnExcBrig:Show()
			Else
				oBtnExcBrig:Hide()
				oBtnResBrig:Show()
			Endif
		Endif
		oPanelBrig:Hide()
		oPanelInf:Show()

		MDT560Carg( cNiv , nOpcx )

		//Monta Enchoice de Brigadista
		aRelac   := {	{ "TKM_BRIGAD"	, "M->TKL_BRIGAD" } , ;
						{ "TKM_CODNIV"	, "( cTRBTKM )->CODNIV" } , ;
						{ "TKM_NIVEL"		, "( cTRBTKM )->NIVEL" } , ;
						{ "TKM_NIVSUP"	, "( cTRBTKM )->NIVSUP" } , ;
						{ "TKM_MATFUN"	, "( cTRBTKM )->MATFUN" } , ;
						{ "TKM_TIPO"		, "( cTRBTKM )->TIPO" } , ;
						{ "TKM_DTINCL"	, "( cTRBTKM )->DTINCL" } , ;
						{ "TKM_DTSAID"	, "( cTRBTKM )->DTSAID" } , ;
						{ "TKM_FUNCAO"	, "( cTRBTKM )->CODFUN" } , ;
						{ "TKM_DESFUN"	, "NGSEEK( 'TKU' , ( cTRBTKM )->CODFUN , 1 , 'TKU_DESC' )" } , ;
						{ "TKM_ATRIB"		, "( cTRBTKM )->ATRIB" } }

		If lFilMat //Verifica se campo existe.
			AADD(aRelac,{ "TKM_FILMAT"	, "( cTRBTKM )->FILMAT" } )
			AADD(aRelac,{ "TKM_NOMFUN"	, "NGSEEK( 'SRA' , ( cTRBTKM )->MATFUN , 1 , 'RA_NOME',( cTRBTKM )->FILMAT )" } )
		Else
			AADD(aRelac,{ "TKM_NOMFUN"	, "NGSEEK( 'SRA' , ( cTRBTKM )->MATFUN , 1 , 'RA_NOME')" } )
		Endif


		For i := 1 to Len( aRELAC )
			cCampo := "M->" + aRELAC[ i , 1 ]
			cRelac := aRELAC[ i , 2 ]
			&cCampo. := &cRelac
		Next

		oEncVis:Refresh()

		//Monta Browse de Exames
		oBrwExa:SetArray( aExames )
		bBrwExa := { || { ;
							LoadBitmap( GetResources() , MDT560Cor( aExames[ oBrwExa:nAt ] , 1 ) ) , ;
							aExames[ oBrwExa:nAt , 1 ] , ;
							aExames[ oBrwExa:nAt , 2 ] , ;
							aExames[ oBrwExa:nAt , 3 ] , ;
							aExames[ oBrwExa:nAt , 4 ];
							} }
		oBrwExa:bLine	:= bBrwExa
		oBrwExa:nAt	:= 1
		oBrwExa:Refresh()

		//Monta Browse de Treinamento
		oBrwTre:SetArray( aTreinamento )
		bBrwTre := { || { ;
							LoadBitmap( GetResources() , MDT560Cor( aTreinamento[ oBrwTre:nAt ] , 2 ) ) , ;
							aTreinamento[ oBrwTre:nAt , 2 ] , ;
							aTreinamento[ oBrwTre:nAt , 3 ] , ;
							aTreinamento[ oBrwTre:nAt , 4 ] , ;
							aTreinamento[ oBrwTre:nAt , 5 ] , ;
							aTreinamento[ oBrwTre:nAt , 6 ];
							} }
		oBrwTre:bLine	:= bBrwTre
		oBrwTre:nAt	:= 1
		oBrwTre:Refresh()
	Endif

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT560Carg
Carrega informações do panel de informações

@return Sempre verdadeiro

@param cNiv Caracter Nivel a ser carregado
@param nOpcx Numerico Opção de Manutenção

@sample MDT560Carg( '001', 3 )

@author Jackson Machado
@since 13/05/2011
/*/
//---------------------------------------------------------------------
Static Function MDT560Carg( cNiv, nOpcx )

	Local nExa := 0
	Local nTre := 0

	Private cFicha	:= Space( 9 )

	Default cNiv	:= Space( 3 )

	aExames := {}
	dbSelectArea( cTRBTKM )
	dbSetOrder( 1 )
	If dbSeek( cNiv )
		dbSelectArea( "TM0" )
		dbSetOrder( 11 ) //TM0_FILIAL + TM0_MAT
		If lFilMat
			If dbSeek( (cTRBTKM)->FILMAT + ( cTRBTKM )->MATFUN )
				cFicha := TM0->TM0_NUMFIC
			Endif
		Else
			If dbSeek( xFilial("TM0") + ( cTRBTKM )->MATFUN )
				cFicha := TM0->TM0_NUMFIC
			Endif
		Endif
	Endif

	For nExa := 1 To Len( oBrwB:aCols )

		If !oBrwB:aCols[ nExa , Len( oBrwB:aCols[ nExa ] ) ] //Caso a linha não esteja deletada
			//Busca exames realizados
			dbSelectArea( "TM5" )
			dbSetOrder( 6 ) //TM5_FILIAL + TM5_NUMFIC + TM5_EXAME + DTOS(TM5_DTPROG)
			If dbSeek( xFilial( "TM5" ) + cFicha + oBrwB:aCols[ nExa , 1 ] )
				While TM5->( !Eof() ) .And. ;
					AllTrim( TM5->TM5_NUMFIC + TM5->TM5_EXAME ) == AllTrim( cFicha + oBrwB:aCols[ nExa , 1 ] )

					dbSelectArea( "TM4" )
					dbSetOrder( 1 )
					If dbSeek( xFilial( "TM4" ) + TM5->TM5_EXAME )
						aAdd( aExames , { TM4->TM4_EXAME , TM4->TM4_NOMEXA , TM5->TM5_DTPROG , TM5->TM5_DTRESU } )
					Endif
					dbSelectArea( "TM5" )
					TM5->( dbSkip() )
				End
			Endif
		EndIf

	Next nExa

	//Caso Array esteja vazio, alimenta com registro em branco
	If Len( aExames ) == 0
		aAdd( aExames , { Space( 1 ) , Space( 1 ) , StoD( Space( 8 ) ) , StoD( Space( 8 ) ) } )
	Endif

	aTreinamento := {}
	For nTre := 1 To Len( oBrwC:aCols )

		If !oBrwC:aCols[ nTre , Len( oBrwC:aCols[ nTre ] ) ] //Caso a linha não esteja deletada
			//Busca Treinamentos Reservados
			dbSelectArea( "RA3" )
			dbSetOrder( 2 ) //RA3_FILIAL + RA3_CALEND + RA3_MAT

			If dbSeek( xFilial( "RA3" ) + oBrwC:aCols[ nTre , 1 ] + ( cTRBTKM )->MATFUN )
				While RA3->( !Eof() ) .And. RA3->RA3_CALEND == oBrwC:aCols[ nTre , 1 ] .And. ;
					RA3->RA3_MAT == ( cTRBTKM )->MATFUN

					If RA3->RA3_RESERV <> "R" .Or. RA3->RA3_CURSO <> oBrwC:aCols[ nTre , 3 ]
						dbSelectArea( "RA3" )
						RA3->( dbSkip() )
					Else
						dbSelectArea( "RA1" )
						dbSetOrder( 1 )
						If dbSeek( xFilial( "RA1" ) + RA3->RA3_CURSO )
							aAdd( aTreinamento , { "2" , oBrwC:aCols[ nTre , 2 ] , RA3->RA3_CURSO , RA1->RA1_DESC , "" , "" } )
						Endif
						dbSelectArea( "RA3" )
						RA3->( dbSkip() )
					Endif
				End
			Endif

			//Busca Treinamentos Realizados
			dbSelectArea( "RA4" )
			dbSetOrder( 3 ) //RA4_FILIAL + RA4_CALEND + RA4_CURSO + RA4_TURMA + RA4_MAT
			If dbSeek( xFilial( "RA4" ) + oBrwC:aCols[ nTre , 1 ] + oBrwC:aCols[ nTre , 3 ] )
				While RA4->( !Eof() ) .And. ;
					RA4->RA4_CALEND	== oBrwC:aCols[ nTre , 1 ] .And. ;
					RA4->RA4_CURSO	== oBrwC:aCols[ nTre , 3 ]

					If RA4->RA4_MAT == ( cTRBTKM )->MATFUN
						dbSelectArea( "RA1" )
						dbSetOrder( 1 )
						If dbSeek( xFilial( "RA1" ) + RA4->RA4_CURSO )
							If !Empty( RA4->RA4_VALIDA ) .and. RA4->RA4_VALIDA < dDataBase
								aAdd( aTreinamento , { "3" , oBrwC:aCols[ nTre , 2 ] , RA4->RA4_CURSO , RA1->RA1_DESC , RA4->RA4_NOTA , RA4->RA4_PRESEN } )
							Else
								aAdd( aTreinamento , { "1" , oBrwC:aCols[ nTre , 2 ] , RA4->RA4_CURSO , RA1->RA1_DESC , RA4->RA4_NOTA , RA4->RA4_PRESEN } )
							Endif
						Endif
					Endif
					dbSelectArea( "RA4" )
					RA4->( dbSkip() )
				End
			Endif
		EndIf

	Next nTre

	//Caso Array esteja vazio, alimenta com registro em branco
	If Len( aTreinamento ) == 0
		aAdd( aTreinamento , { Space(1) , Space(1) , Space(1) , Space(1) , Space(1) , Space(1) } )
	Endif

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT560Cor
Retorna a cor do semáfaro

@return cCores Caracter Cor correspondente a Legenda do Registro

@param aArray Array Vetor contendo as informações
@param nTipo Numerico Tipo a ser validado

@sample MDT560Cor( {} , 1 )

@author Jackson Machado
@since 13/05/2011
/*/
//---------------------------------------------------------------------
Static Function MDT560Cor( aArray , nTipo )

	Local cCores := ""

	If Len( aArray ) > 0
		If nTipo == 1
			If !Empty( aArray[ 4 ] )
				cCores := "BR_AZUL"
			ElseIf !Empty( aArray[ 3 ] ) .AND. aArray[ 3 ] < dDataBase
				cCores := "BR_VERMELHO"
			ElseIf !Empty( aArray[ 3 ] ) .AND. aArray[ 3 ] >= dDataBase
				cCores := "BR_VERDE"
			Endif
		Elseif nTipo == 2
			If aArray[ 1 ] == "1"
				cCores := "BR_VERDE"
			ElseIf aArray[ 1 ] == "2"
				cCores := "BR_VERMELHO"
			ElseIf aArray[ 1 ] == "3"
				cCores := "BR_LARANJA"
			Endif
		Endif
	Endif

Return cCores
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT560Leg
Cria uma janela contendo a legenda da mBrowse

@return Sempre verdadeiro

@param nLeg Numérico Tipo da Legenda ( 1 - Organograma ; 2 - Exames ; 3 - Treinamentos )

@sample MDT560Leg( 1 )

@author Jackson Machado
@since 13/05/2011
/*/
//---------------------------------------------------------------------
Static Function MDT560Leg( nLeg )

	Local nColImg := 13, nColTxt := 30
	Local nImg := 17, nTxt := 20
	Local nTam := 125
	Local aLegenda := {}
	Local oLeg
	Local oPnlLegend

	IF Type( "cCadastro" ) == "U"
		Private cCadastro := STR0027 //"Legenda"
	EndIF

	If nLeg == 1
		aAdd( aLegenda , { "ng_ico_brigadista"			, OemToAnsi( STR0041 ) } )//"Ativo"
		aAdd( aLegenda , { "ng_ico_brigadistaexcluir"	, OemToAnsi( STR0042 ) } )//"Excluído"
	Elseif nLeg == 2
		aAdd( aLegenda , { "BR_VERDE"					, OemToAnsi( STR0043 ) } )//"Não Realizado - A vencer"
		aAdd( aLegenda , { "BR_VERMELHO"				, OemToAnsi( STR0044 ) } )//"Não Realizado - Vencido"
		aAdd( aLegenda , { "BR_AZUL"					, OemToAnsi( STR0045 ) } )//"Realizado"
	Elseif nLeg == 3
		aAdd( aLegenda , { "BR_VERDE"					, OemToAnsi( STR0045 ) } )//"Realizado"
		aAdd( aLegenda , { "BR_VERMELHO"				, OemToAnsi( STR0046 ) } )//"Não Realizado"
		aAdd( aLegenda , { "BR_LARANJA"					, OemToAnsi( STR0047 ) } )//"Realizado - Com Data Expirada"
	Endif

	DEFINE MSDIALOG oLeg TITLE OemToAnsi( STR0027 ) FROM 0 , 0 TO nTam , 235 Of oMainWnd PIXEL//"Legenda"

		oPnlLegend := TPanel():New( 0 , 0 , , oLeg , , , , , CLR_WHITE , 0 , 18 , .F. , .F. )
			oPnlLegend:Align := CONTROL_ALIGN_ALLCLIENT

			@ 004,005 To 60,113 LABEL Oemtoansi( STR0027 ) OF oPnlLegend Pixel //"Legenda"

			If Len( aLegenda ) == 3
				nTxt -= 2
			Else
				nImg += 5
				nTxt += 5
			Endif
			oBmp := TBitmap():New( nImg , nColImg , 0 , 0 , aLegenda[ 1 , 1 ] , , .T. , oPnlLegend , , , .F. , .F. , , , .F. , , .T. , , .F. )
				oBmp:lAutoSize := .T.
				TSay():New( nTxt , nColTxt , { | | aLegenda[ 1 , 2 ] } , oPnlLegend , , , , , , .T. , CLR_BLACK , , 200 , 20 )

			nImg += 15
			nTxt += 15

			oBmp := TBitmap():New( nImg , nColImg , 0 , 0 , aLegenda[ 2 , 1 ] , , .T. , oPnlLegend , , , .F. , .F. , , , .F. , , .T. , , .F. )
				oBmp:lAutoSize := .T.
				TSay():New( nTxt , nColTxt , { | | aLegenda[ 2 , 2 ] } , oPnlLegend , , , , , , .T. , CLR_BLACK , , 200 , 20 )

			nImg += 15
			nTxt += 15
			If Len( aLegenda ) == 3
				oBmp := TBitmap():New( nImg , nColImg , 0 , 0 , aLegenda[ 3 , 1 ] , , .T. , oPnlLegend , , , .F. , .F. , , , .F. , , .T. , , .F. )
					oBmp:lAutoSize := .T.
					TSay():New( nTxt , nColTxt , { | | aLegenda[ 3 , 2 ] } , oPnlLegend , , , , , , .T. , CLR_BLACK , , 200 , 20 )
			Endif

	ACTIVATE MSDIALOG oLeg CENTERED

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT560Alt
Função para alteração do brigadista

@return lRet Lógico Retorna verdadeiro caso seja possível incluir o brigadista

@param nOpcao Numérico Tipo da Opção
@param lDestroi Logico Indica se deve destruir objeto
@param nVal Numérico Tipo da Opção

@sample MDT560Alt( 3 , , 3 )

@author Jackson Machado
@since 16/06/2011
/*/
//---------------------------------------------------------------------
Static Function MDT560Alt( nOpcao , lDestroi , nVal )

	Local i
	Local lRet				:= .T.
	Local lTreinamento	:= If( SuperGetMv( "MV_NGMDTTR" , .F. , "2" ) == "1" , .T. , .F. )

	nAlt := nVal

	Default nOpcao	:= 2
	Default lDestroi	:= .T.
	Default nVal		:= 2
	
	// Valida se poderá ser adicionado mais brigadistas a arvore( limitação do frame é de 180 )
	If nOpcao == 2 .Or. nOpcao == 4 .Or. ( nOpcao == 3 .And. oTree:Nivel() < 154 )
		If nOpcao == 3 .And. oTree:GetCargo() == "001"
			oPanelBrig:Hide()
			oPanelInf:Show()
		EndIf

		If lDestroi
			If nOpcao == 2 .or. nOpcao == 5//Opção de Visualização e Exclusão
				cTitulo := STR0011 //"Visualização do Brigadista"
				oSayInf:SetText( cTitulo )
				oSayInf:CtrlRefresh()
				oPanelBrig:Enable()
				oTree:Enable()
				oEncTKL:Enable()
				oPainelVis:Show()
				oPainelInc:Hide()
				oPainelAlt:Hide()
				oFolderInf:aDialogs[ 2 ]:Enable()
				If lTreinamento
					oFolderInf:aDialogs[ 3 ]:Enable()
				EndIf

				If nVal == 3 .or. nVal == 4
					oBtnConf:Hide()
					oBtnCanc:Hide()
					dbSelectArea( cTRBTKM )
					dbSetOrder(1)
					dbSeek( oTree:GetCargo() )
					If Empty( ( cTRBTKM )->DELET )
						oBtnResBrig:Hide()
						oBtnExcBrig:Show()
					Else
						oBtnExcBrig:Hide()
						oBtnResBrig:Show()
					Endif
					oBtnAltBrig:Show()
					oBtnIncBrig:Show()
				Endif

				aRelac   := {	{ "TKM_BRIGAD" , "M->TKL_BRIGAD" } , ;
								{ "TKM_CODNIV" , "( cTRBTKM )->CODNIV" } , ;
								{ "TKM_NIVEL"  , "( cTRBTKM )->NIVEL" } , ;
								{ "TKM_NIVSUP" , "( cTRBTKM )->NIVSUP" } , ;
								{ "TKM_MATFUN" , "( cTRBTKM )->MATFUN" } , ;
								{ "TKM_NOMFUN" , "NGSEEK( 'SRA' , ( cTRBTKM )->MATFUN , 1 , 'RA_NOME' )" } , ;
								{ "TKM_TIPO"   , "( cTRBTKM )->TIPO" } , ;
								{ "TKM_DTINCL" , "( cTRBTKM )->DTINCL" } , ;
								{ "TKM_DTSAID" , "( cTRBTKM )->DTSAID" } , ;
								{ "TKM_FUNCAO" , "( cTRBTKM )->CODFUN" } , ;
								{ "TKM_DESFUN" , "NGSEEK( 'TKU' , ( cTRBTKM )->CODFUN , 1 , 'TKU_DESC' )" } , ;
								{ "TKM_ATRIB"  , "( cTRBTKM )->ATRIB" } }

				If lFilMat //Verifica se campo existe.
					AADD(aRelac,{ "TKM_FILMAT"	, "( cTRBTKM )->FILMAT" } )
					AADD(aRelac,{ "TKM_NOMFUN"	, "NGSEEK( 'SRA' , ( cTRBTKM )->MATFUN , 1 , 'RA_NOME',( cTRBTKM )->FILMAT )" } )
				Else
					AADD(aRelac,{ "TKM_NOMFUN"	, "NGSEEK( 'SRA' , ( cTRBTKM )->MATFUN , 1 , 'RA_NOME')" } )
				Endif

			Elseif nOpcao == 3//Opção de  Inclusão
				lTravFilMAt := .T.
				lIncBrig := .T.
				If !Empty( ( cTRBTKM )->DELET )
					ShowHelpDlg( 	STR0051 , ;//"ATENÇÃO"
									{ STR0071 } , 2 , ;//"Restaure o brigadista ou selecione outro."
									{ STR0072 } , 4 ) //"Não é possível incluir subordinados a um brigadista excluído."
					lRet := .F.
				Else
					cTitulo := STR0048 //"Inclusão do Brigadista"
					oSayInf:SetText( cTitulo )
					oSayInf:CtrlRefresh()
					oPanelBrig:Disable()
					oTree:Disable()
					oEncTKL:Disable()
					oPainelVis:Hide()
					oPainelInc:Show()
					oPainelAlt:Hide()
					oFolderInf:aDialogs[ 1 ]:Show()
					oFolderInf:aDialogs[ 2 ]:Disable()
					oFolderInf:aDialogs[ 3 ]:Disable()
					If nVal == 3 .or. nVal == 4
						oBtnConf:Show()
						oBtnCanc:Show()
						oBtnResBrig:Hide()
						oBtnExcBrig:Hide()
						oBtnAltBrig:Hide()
						oBtnIncBrig:Hide()
					Endif
					aRelac   := {	{ "TKM_BRIGAD" , "Space( 10 )" } , ;
									{ "TKM_CODNIV" , "Space( 03 )" } , ;
									{ "TKM_NIVEL"  , "Space( 03 )" } , ;
									{ "TKM_NIVSUP" , "Space( 03 )" } , ;
									{ "TKM_MATFUN" , "Space( 06 )" } , ;
									{ "TKM_NOMFUN" , "Space( 30 )" } , ;
									{ "TKM_TIPO"   , "Space( 01 )" } , ;
									{ "TKM_DTINCL" , "STOD( Space( 08 ) )" }, ;
									{ "TKM_DTSAID" , "STOD( Space( 08 ) )" }, ;
									{ "TKM_FUNCAO" , "Space( 05 )" } , ;
									{ "TKM_DESFUN" , "Space( 20 )" } , ;
									{ "TKM_ATRIB"  , "Space( 40 )" } }
					If lFilMat //Verifica se campo existe.
						AADD(aRelac,{ "TKM_FILMAT"	, "cFilAnt" } )
					Endif
				Endif
			Elseif nOpcao == 4//Opção de Alteração
				lTravFilMAt := .F. //Variavel utilizada no When do FilMat
				lIncBrig := .T.
				cTitulo := STR0049 //"Alteração do Brigadista"
				oSayInf:SetText( cTitulo )
				oSayInf:CtrlRefresh()
				oPanelBrig:Disable()
				oTree:Disable()
				oEncTKL:Disable()
				oPainelVis:Hide()
				oPainelInc:Hide()
				oPainelAlt:Show()
				oFolderInf:aDialogs[ 1 ]:Show()
				oFolderInf:aDialogs[ 2 ]:Disable()
				oFolderInf:aDialogs[ 3 ]:Disable()
				If nVal == 3 .or. nVal == 4
					oBtnConf:Show()
					oBtnCanc:Show()
					oBtnResBrig:Hide()
					oBtnExcBrig:Hide()
					oBtnAltBrig:Hide()
					oBtnIncBrig:Hide()
				Endif
			Endif
			For i := 1 to Len( aRELAC )
				cCampo := "M->" + aRELAC[ i , 1 ]
				cRelac := aRELAC[ i , 2 ]
				&cCampo. := &cRelac
			Next
			oEncInc:Refresh()
		Endif
	Else
		// "Você atingiu o número máximo de nivel de brigadistas suportado pela rotina. Não poderão ser adicionados mais brigadistas abaixo desse nível!"
		Help( , , STR0051, , STR0077, 1, 0 )
	EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT560Exc
Função para exclusão do brigadista

@return Lógico Retorna verdadeiro caso seja excluido/restaurado brigadista

@param lRes Lógico Indica se esta restaurando brigadista

@sample MDT560Exc()

@author Jackson Machado
@since 16/06/2011
/*/
//---------------------------------------------------------------------
Static Function MDT560Exc( lRes )

	Local cFolder		:= "ng_ico_brigadistaexcluir"
	Local cFolder2	:= "ng_ico_brigadistaexcluir"
	Local cNivBrig	:= SubStr( oTree:GetCargo(), 1, 3 )
	Local cPergunta	:= STR0050 //"Deseja realmente excluir o participante?"
	Local lRet 		:= .T.

	Default lRes		:= .F.

	If lRes
		cPergunta := STR0040 //"Deseja realmente restaurar o participante?"
	Endif

	If MsgYesNo( cPergunta )
		dbSelectArea( cTRBTKM )
		dbSetOrder( 2 )
		If dbSeek( cNivBrig )
			While !Eof() .and. ( cTRBTKM )->NIVSUP == cNivBrig .and. Empty( ( cTRBTKM )->DELET ) .And. lRet
				ShowHelpDlg( 	STR0051 , ; //"ATENÇÃO"
								{ STR0052 } , 2 , ;//"Não é possível excluir brigadista pois ele possui subordinados."
								{ STR0053 } , 2 )//"Exclua seus subordinádos primeiramente."
				lRet := .F.
				(cTRBTKM)->(dbSkip())
			End
		Endif

		If lRet
			dbSelectArea( cTRBTKM )
			dbSetOrder( 1 )
			If dbSeek( cNivBrig )
				RecLock( cTRBTKM , .F. )
				If Empty( ( cTRBTKM )->DELET )
					( cTRBTKM )->DELET := "*"
					oBtnExcBrig:Hide()
					oBtnResBrig:Show()
				Else
					( cTRBTKM )->DELET := " "
					cFolder := cFolderA
					cFolder2:= cFolderB
					oBtnExcBrig:Show()
					oBtnResBrig:Hide()
				Endif
				MsUnLock( cTRBTKM )
				oTree:TreeSeek( cNivBrig )
				oTree:ChangeBmp( cFolder , cFolder2 )
				oTree:Refresh()
			Endif
		EndIf
	Else
		lRet := .F.
	Endif

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT560Conf
Função para confirmação da alteração

@return Lógico Sempre Verdadeiro

@sample MDT560Conf()

@author Jackson Machado
@since 16/06/2011
/*/
//---------------------------------------------------------------------
Static Function MDT560Conf()

	Local cCargo		:= SubStr( oTree:GetCargo() , 1 , 3 )

	Private cCodLevel	:= ""
	Private nLevel	:= 0

	lIncBrig := .F.
	cFilAnt := cFilBrig //Retorna filial inicial

	If nAlt == 3
		cCodLevel := SubStr( oTree:GetCargo() , 1 , 3 )
		dbSelectArea( cTRBTKM )
		dbSetOrder( 1 )
		dbSeek( cCodLevel )
		nLevel := ( cTRBTKM )->NIVEL

		Inclui := .t.
		nRecno := 1
		If cLocal == "001"
			dbSelectArea( "TKM" )
			dbSetOrder( 1 )
			dbSeek( xFilial( "TKM" ) + M->TKL_BRIGAD )
			While TKM->( !Eof() ) .and. TKM->TKM_BRIGAD == M->TKL_BRIGAD .And. TKM->TKM_FILMAT == cFilBrig				
				cLocal := TKM->TKM_CODNIV
				dbSelectArea( "TKM" )
				TKM->( dbSkip() )
			End
			If Empty( cLocal )
				dbSelectArea( cTRBTKM )
				dbSetOrder( 2 )
				dbGoBottom()
				cLocal := ( cTRBTKM )->CODNIV
			Endif
			If FindFunction( "Soma1Old" )
				cLocal := Soma1Old( AllTrim( cLocal ) )
			Else
				cLocal := Soma1( AllTrim( cLocal ) )
			EndIf
		Else
			If Empty( cLocal )
				dbSelectArea( cTRBTKM )
				dbSetOrder( 2 )
				dbGoBottom()
				cLocal := ( cTRBTKM )->CODNIV
			Endif
			If FindFunction( "Soma1Old" )
				cLocal := Soma1Old( AllTrim( cLocal ) )
			Else
				cLocal := Soma1( AllTrim( cLocal ) )
			EndIf
		EndIf

		oTree:AddItem( M->TKM_FUNCAO + " - " + NGSEEK( "TKU" , M->TKM_FUNCAO , 1 , "TKU->TKU_DESC" ) , cLocal , cFolderA , cFolderB , , , 2 )

		dbSelectArea( cTRBTKM )
		RecLock( cTRBTKM , .T. )
		( cTRBTKM )->CODNIV	:= cLocal
		( cTRBTKM )->NIVEL	:= nLevel + 1
		( cTRBTKM )->NIVSUP	:= cCodLevel
		( cTRBTKM )->ORDEM	:= cLocal
		( cTRBTKM )->CODFUN	:= M->TKM_FUNCAO
		( cTRBTKM )->DESFUN	:= NGSEEK( "TKU" , M->TKM_FUNCAO , 1 , "TKU_DESC" )
		If lFilMat //Verifica se campo existe.
			( cTRBTKM )->FILMAT	:= M->TKM_FILMAT
		EndIf
		( cTRBTKM )->MATFUN	:= M->TKM_MATFUN
		( cTRBTKM )->NOMFUN	:= NGSEEK( "SRA" , M->TKM_MATFUN , 1 , "RA_NOME" )
		( cTRBTKM )->TIPO		:= M->TKM_TIPO
		( cTRBTKM )->DTINCL	:= M->TKM_DTINCL
		( cTRBTKM )->DTSAID	:= M->TKM_DTSAID
		( cTRBTKM )->ATRIB	:= M->TKM_ATRIB
		MsUnLock( cTRBTKM )
		oTree:TreeSeek( cLocal )
		oTree:PtRefresh()
	ElseIf nAlt == 4
		dbSelectArea( cTRBTKM )
		dbSetOrder( 1 )
		If dbSeek( cCargo )
			RecLock( cTRBTKM , .F. )
			( cTRBTKM )->CODFUN	:= M->TKM_FUNCAO
			( cTRBTKM )->DESFUN	:= NGSEEK( "TKU" , M->TKM_FUNCAO , 1 , "TKU->TKU_DESC" )
			If lFilMat //Verifica se campo existe.
				( cTRBTKM )->FILMAT	:= M->TKM_FILMAT
			Endif
			( cTRBTKM )->MATFUN	:= M->TKM_MATFUN
			( cTRBTKM )->NOMFUN	:= NGSEEK( "SRA" , M->TKM_MATFUN , 1 , "SRA->RA_NOME" )
			( cTRBTKM )->TIPO		:= M->TKM_TIPO
			( cTRBTKM )->DTINCL	:= M->TKM_DTINCL
			( cTRBTKM )->DTSAID	:= M->TKM_DTSAID
			( cTRBTKM )->ATRIB	:= M->TKM_ATRIB
			MsUnLock( cTRBTKM )
		Endif
		oTree:TreeSeek( SubStr( oTree:GetCargo() , 1 , 3 ) )
		oTree:ChangePrompt( M->TKM_FUNCAO + " - " + NGSEEK( "TKU" , M->TKM_FUNCAO , 1 , "TKU->TKU_DESC" ) )
		oTree:PtRefresh()
	Endif

	MDT560Alt( 2 , , 3 )

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT560VIN
Função para validação das datas do brigadista

@return lRet Lógico Retorna verdadeiro quando datas corretas

@param dDtaBrig Date Data a ser validada

@sample MDT560Conf()

@author Jackson Machado
@since 16/06/2011
/*/
//---------------------------------------------------------------------
Function MDT560VIN(dDataBrig)

	Local lRet := .T.

	If !Empty( dDataBrig ) .And. !Empty( M->TKL_DTVIIN ) .And. !Empty( M->TKL_DTVIFI )
		If dDataBrig < M->TKL_DTVIIN
			ShowHelpDlg( 	"DATAINVAL" , ;
							{ STR0054 } , 2 , ;//"Data não pode ser menor que a vigência da brigada"
							{ STR0055 } , 2 )//"Informe uma data válida entre a vigência"
			lRet := .F.
		ElseIf dDataBrig > M->TKL_DTVIFI
			ShowHelpDlg( 	"DATAINVAL" , ;
							{ STR0056 } , 2 , ;//"Data não pode ser maior que a vigência da brigada"
							{ STR0055 } , 2 )//"Informe uma data válida entre a vigência"
			lRet := .F.
		Endif
	Endif

	cFilAnt := cFilBrig //Retorna a filial

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT560Canc
Função para cancelamento

@return Lógico Sempre Verdadeiro

@sample MDT560Conf()

@author Jackson Machado
@since 16/06/2011
/*/
//---------------------------------------------------------------------
Static Function MDT560Canc()

	cFilAnt := cFilBrig //Retorna filial inicial

	oTree:TreeSeek( oTree:GetCargo() )
	dbSelectArea( cTRBTKM )
	dbSetOrder( 1 )
	dbSeek( oTree:GetCargo() )
	oEncAlt:Refresh()
	MDT560Alt( 2 , .T. , 3 )
	lIncBrig := .F.

	If oTree:GetCargo() == "001"
		oPanelBrig:Show()
		oBtnResBrig:Hide()
		oBtnExcBrig:Hide()
		oBtnAltBrig:Hide()
		oBtnIncBrig:Show()
		oPanelInf:Hide()
	Endif

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA560Copy
Função para copia da brigada

@return Lógico Sempre Verdadeiro

@sample MDT560Conf()

@author Jackson Machado
@since 16/06/2011
/*/
//---------------------------------------------------------------------
Function MDTA560Copy()

	//Variaveis da tela
	Local aSize		:= MsAdvSize( , .F. , 430 )
	Local nLargura	:= aSize[ 5 ] / 2
	Local nAltura	:= aSize[ 6 ] / 3

	Local cTRBCopy, cBrigada
	Local nPar, nExa, nTre
	Local nCopy		:= 0
	Local aPar		:= {}, aExa := {}, aTre := {}, aIndices := {}, aDBF := {}
	Local aCopyAGets:= {}
	Local oCopy, oEncCopy
	Private aCopyATela	:= {}

	DEFINE MSDIALOG oCopy TITLE OemToAnsi( STR0002 ) From aSize[ 7 ] , 0 To nAltura , nLargura OF oMainWnd PIXEL //"Brigada"

		oPnlPai := TPanel():New( 00 , 00 , , oCopy , , , , , , nLargura , nAltura , .F. , .F. )
			oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

			aGets := {}
			aTela := {}
			dbSelectArea( "TKL" )
			RegToMemory( "TKL" , .T. )
			oEncCopy:= MsMGet():New( "TKL" , 0 , 3 , , , , , {0,0,nAltura/2,nLargura/1.9} , , , , , , oPnlPai , , , .T. , "aCopyATela")
			aCopyATela := aClone( aTela )
			aCopyAGets := aClone( aGets )

	ACTIVATE MSDIALOG oCopy ON INIT EnchoiceBar( oCopy , ;
														{ | | nCopy := 1 , If( Obrigatorio( aGets , aTela ) , oCopy:End() , nCopy := 0 ) } , ;
														{ | | nCopy := 0 , oCopy:End() } ) CENTERED
	If nCopy == 1
		cBrigada := TKL->TKL_BRIGAD

		dbSelectArea( "TKL" )
		dbSetOrder( 1 )
		If !dbSeek( xFilial( "TKL" ) + M->TKL_BRIGAD )
			RecLock( "TKL" , .T. )
			TKL->TKL_FILIAL	:= xFilial( "TKL" )
			TKL->TKL_BRIGAD	:= M->TKL_BRIGAD
			TKL->TKL_DESC		:= M->TKL_DESC
			TKL->TKL_DTVIIN	:= M->TKL_DTVIIN
			TKL->TKL_DTVIFI	:= M->TKL_DTVIFI
			TKL->( MsUnLock() )
		EndIf

		dbSelectArea( "TKM" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "TKM" ) + cBrigada )
			While TKM->( !Eof() ) .and. TKM->TKM_BRIGAD == cBrigada
			If lFilMat //Verifica se campo existe.
				aAdd( aPar , { TKM->TKM_CODNIV , TKM->TKM_NIVEL , TKM->TKM_NIVSUP , TKM->TKM_ORDEM , TKM->TKM_FILMAT , TKM->TKM_MATFUN , M->TKL_DTVIIN , M->TKL_DTVIFI , TKM->TKM_FUNCAO , TKM->TKM_TIPO , TKM->TKM_ATRIB } )
			Else
				aAdd( aPar , { TKM->TKM_CODNIV , TKM->TKM_NIVEL , TKM->TKM_NIVSUP , TKM->TKM_ORDEM , TKM->TKM_MATFUN , M->TKL_DTVIIN , M->TKL_DTVIFI , TKM->TKM_FUNCAO , TKM->TKM_TIPO , TKM->TKM_ATRIB } )
			EndIf
				dbSelectArea("TKM")
				TKM->( dbSkip() )
			End
		EndIf

		dbSelectArea( "TKM" )
		dbSetOrder( 1 )
		If !dbSeek( xFilial( "TKM" ) + M->TKL_BRIGAD )
			For nPar := 1 To Len( aPar )
				RecLock(  "TKM" , .T. )
				TKM->TKM_FILIAL	:= xFilial( "TKM" )
				TKM->TKM_BRIGAD	:= M->TKL_BRIGAD
				TKM->TKM_CODNIV	:= aPar[ nPar , 1 ]
				TKM->TKM_NIVEL	:= aPar[ nPar , 2 ]
				TKM->TKM_NIVSUP	:= aPar[ nPar , 3 ]
				TKM->TKM_ORDEM	:= aPar[ nPar , 4 ]
				If lFilMat //Verifica se campo existe.
					TKM->TKM_FILMAT	:= aPar[ nPar , 5 ]
				Endif
				TKM->TKM_MATFUN	:= aPar[ nPar , If(lFilMat,6,5) ]
				TKM->TKM_DTINCL	:= aPar[ nPar , If(lFilMat,7,6) ]
				TKM->TKM_DTSAID	:= aPar[ nPar , If(lFilMat,8,7) ]
				TKM->TKM_FUNCAO	:= aPar[ nPar , If(lFilMat,9,8) ]
				TKM->TKM_TIPO		:= aPar[ nPar , If(lFilMat,10,9) ]
				TKM->TKM_ATRIB	:= aPar[ nPar , If(lFilMat,11,10) ]
				TKM->( MsUnLock() )
			Next nPar
		EndIf

		dbSelectArea( "TKN" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "TKN" ) + cBrigada )
			While TKN->( !Eof() ) .and. TKN->TKN_BRIGAD == cBrigada
				aAdd( aExa , { TKN_EXAME , TKN_FAIXA } )
				dbSelectArea( "TKN" )
				TKN->( dbSkip() )
			End
		EndIf

		dbSelectArea( "TKN" )
		dbSetOrder( 1 )
		If !dbSeek( xFilial( "TKN" ) + M->TKL_BRIGAD )
			For nExa := 1 To Len( aExa )
				RecLock( "TKN" , .T. )
				TKN->TKN_FILIAL := xFilial( "TKN" )
				TKN->TKN_BRIGAD := M->TKL_BRIGAD
				TKN->TKN_EXAME  := aExa[ nExa , 1 ]
				TKN->TKN_FAIXA  := aExa[ nExa , 2 ]
				TKN->( MsUnLock() )
			Next nExa
		EndIf

		dbSelectArea( "TKO" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "TKO" ) + cBrigada )
			While TKO->( !Eof() ) .and. TKO->TKO_BRIGAD == cBrigada
				aAdd( aTre , { TKO_CODTRE , TKO_CURSO } )
				dbSelectArea( "TKO" )
				TKO->( dbSkip() )
			End
		EndIf

		dbSelectArea( "TKO" )
		dbSetOrder( 1 )
		If !dbSeek( xFilial( "TKO" ) + M->TKL_BRIGAD )
			For nTre := 1 To Len( aTre )
				RecLock( "TKO" , .T. )
				TKO->TKO_FILIAL	:= xFilial( "TKO" )
				TKO->TKO_BRIGAD	:= M->TKL_BRIGAD
				TKO->TKO_CODTRE	:= aTre[ nTre , 1 ]
				TKO->TKO_CURSO	:= aTre[ nTre , 2 ]
				TKO->( MsUnLock() )
			Next nTre
		EndIf
	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT560GerTre
Função geração de treinamentos para o brigadista

@return Lógico Sempre Verdadeiro

@sample MDT560GerTre()

@author Jackson Machado
@since 16/06/2011
/*/
//---------------------------------------------------------------------
Static Function MDT560GerTre()

	Local nX
	Local nGetTre		:= 0
	Local aFunc		:= {}
	Local oGerTre
	Local oTempTRB
	Local nFILIAL	:= If((TAMSX3("TMY_FILIAL")[1]) > 0,TAMSX3("TMY_FILIAL")[1], 8)

	Private nMax
	Private cGerTre	:= Space( 4 )
	Private cGerCur	:= Space( 4 )
	Private cDesCur	:= Space( 20 )
	Private cDesTre	:= Space( 20 )
	Private lInverte	:= .F.
	Private cTurma	:= ""

	aTrei := {}

	aAdd( aTrei , { "OK"		, "C" , 02 , 0 } )
	If lFilMat //Verifica se campo existe.
		aAdd( aTrei , { "FILMAT"	, "C" , nFILIAL , 0 } )
	EndIf
	aAdd( aTrei , { "MATFUN"	, "C" , 06 , 0 } )
	aAdd( aTrei , { "NOMFUN"	, "C" , 30 , 0 } )
	aAdd( aTrei , { "CODFUN"	, "C" , 05 , 0 } )
	aAdd( aTrei , { "DESFUN"	, "C" , 20 , 0 } )

	cTRBTre	:= GetNextAlias()

	oTempTRB := FWTemporaryTable():New( cTRBTre, aTrei )
	oTempTRB:AddIndex( "1", {"CODFUN"} )
	oTempTRB:AddIndex( "2", {"MATFUN"} )
	oTempTRB:Create()

	aTRB := {}
	aAdd( aTRB , { "OK"     , NIL , " "		, } )
	If lFilMat //Verifica se campo existe.
		aAdd( aTRB , { "FILMAT" , NIL , STR0076	, } )//"Filial Matr."
	Endif
	aAdd( aTRB , { "MATFUN" , NIL , STR0057	, } )//"Matrícula"
	aAdd( aTRB , { "NOMFUN" , NIL , STR0058	, } )//"Nome"
	aAdd( aTRB , { "CODFUN" , NIL , STR0059	, } )//"Função"
	aAdd( aTRB , { "DESFUN" , NIL , STR0029	, } )//"Descrição"

	MDT560CarTrb()

	Define MsDialog oGerTre Title OemToAnsi( STR0060 ) From 0 , 0 To 400 , 800 Of oMainWnd Pixel //"Gerar Treinamentos"

		oPnlPai := TPanel():New( , , , oGerTre , , , , , , , , .F. , .F. )
			oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

			oPanelGer := TPanel():New( 00 , 00 , , oPnlPai , , , , , , 12 , 12 , .F. , .F. )
				oPanelGer:Align	:= CONTROL_ALIGN_TOP
				oPanelGer:nHeight	:= 100
				If aSize[ 6 ] > 600
					oPanelGer:nHeight := 140
				Endif

				@ 006 , 006 To 048 , 380 LABEL STR0061 Of oPanelGer Pixel //"Informe o treinamento que deseja gerar"
				@ 017 , 010 Say OemToAnsi( STR0032 + ":" ) Of oPanelGer Pixel COLOR CLR_HBLUE //"Treinamento"
				@ 015 , 045 MsGet cGerTre Picture "9999" Size 10 , 10 Of oPanelGer Valid MDT560ValTre() F3 "TKO" Pixel HasButton
				@ 017 , 100 Say OemToAnsi( STR0029 + ":" ) Of oPanelGer Pixel //"Descrição"
				@ 015 , 135 MsGet oDesTre Var cDesTre Picture "@!" Size 080 , 010 Of oPanelGer When .F. Pixel
				@ 034 , 010 Say OemToAnsi( STR0062 + ":" ) Of oPanelGer Pixel COLOR CLR_HBLUE //"Curso"
				@ 032 , 045 MsGet cGerCur Picture "9999" SIZE 010 , 010 Of oPanelGer When !Empty( cCalend ) Valid MDT560ValCur() F3 "TKOCUR" Pixel HasButton
				@ 034 , 100 Say OemToAnsi( STR0034 + ":" ) Of oPanelGer Pixel //"Desc. Curso"
				@ 032 , 135 MsGet oDesCur Var cDesCur Picture "@!" SIZE 080 , 010 Of oPanelGer When .F. Pixel
				@ 034 , 250 Say OemToAnsi( STR0063 + ":" ) Of oPanelGer Pixel //"Vagas Restantes"
				@ 032 , 300 MsGet oMax Var nMax Picture "@!" SIZE 030 , 010 Of oPanelGer When .F. Pixel

			TGet():New( -100 , -100 , { | | " " } , oPanelGer , 1 , , , { | | } , , , , .T. , , .T. , , .T. , , .F. , .F. , , .F. , .F. , , , , , , .T. )
			oPanelMark := TPanel():New( 00 , 00 , , oPnlPai , , , , , , 12 , 12 , .F. , .F. )
				oPanelMark:Align := CONTROL_ALIGN_ALLCLIENT

				oMarkFun := MsSelect():New( ( cTRBTre ) , "OK" , , aTRB , @lInverte , @cMarca , { 60 , 5 , 281 , 292 } , , , oPanelMark )
					oMarkFun:oBrowse:lHasMark		:= .T.
					oMarkFun:oBrowse:lCanAllMark	:= .T.
					oMarkFun:oBrowse:bAllMark		:= { | | MDTA560INV( cMarca ) }
					oMarkFun:oBrowse:Align			:= CONTROL_ALIGN_ALLCLIENT

	Activate MsDialog oGerTre On Init EnchoiceBar(	oGerTre , ;
												{ | | nGetTre := 1 , If( MDT560GTRM() , oGerTre:End() , nGetTre := 0 ) } , ;
												{ | | nGetTre := 0 , oGerTre:End() } ) CENTERED
	If nGetTre == 1
		dbSelectArea( cTRBTre )
		dbSetOrder( 1 )
		dbGoTop()
		While !Eof()
			If !Empty( ( cTRBTre )->OK )
				aAdd( aFunc , { ( cTRBTre )->MATFUN } )
			Endif
			dbSelectArea( cTRBTre )
			dbSkip()
		End

		dbSelectArea( "RA4" )
		dbSetOrder( 1 )
		For nX := 1 To Len( aFunc )
			If dbSeek( xFilial( "RA4" ) + aFunc[ nX , 1 ] + cGerCur )
				RecLock( "RA4" , .F. )
				RA4->( dbDelete() )
				RA4->( MsUnLock() )
			Endif
		Next nX

		dbSelectArea( "RAI" )
		dbSetOrder( 1 )
		For nX := 1 To Len( aFunc )
			If dbSeek( xFilial( "RAI" ) + cGerTre + cGerCur + cTurma + aFunc[ nX , 1 ] )
				RecLock( "RAI" , .F. )
				RAI->( dbDelete() )
				RAI->( MsUnLock() )
			Endif
		Next nX


		dbSelectArea( "RA3" )
		dbSetOrder( 1 )
		For nX := 1 To Len( aFunc )
			If dbSeek( xFilial( "RA3" ) + aFunc[ nX , 1 ] + cGerCur )
				RecLock( "RA3" , .F. )
			Else
				RecLock( "RA3" , .T. )
			Endif
			RA3->RA3_FILIAL	:= xFilial( "RA3" )
			RA3->RA3_MAT		:= aFunc[ nX , 1 ]
			RA3->RA3_CURSO	:= cGerCur
			RA3->RA3_DATA		:= dDataBase
			RA3->RA3_TURMA	:= cTurma
			RA3->RA3_CALEND	:= cGerTre
			RA3->RA3_RESERV	:= "S"
			RA3->RA3_NVEZAD	:= 0
			RA3->RA3_SEQ		:= 0
			RA3->(MsUnLock())
		Next nX
	Endif
	cCalend := ""
	oTempTRB:Delete()

	Processa( { | lEnd | MDT560Crg( 3 , SubStr( oTree:GetCargo() , 1 , 3 ) ) } , STR0019 , STR0020 , .T. ) //"Aguarde..."###"Carregando Informações..."

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT560ValTre
Função validação dos treinamentos do brigadista

@return lRet Lógico Retorna verdadeiro treinamento esteja correto

@sample MDT560ValTre()

@author Jackson Machado
@since 16/06/2011
/*/
//---------------------------------------------------------------------
Static Function MDT560ValTre()

	Local nRA2Rec	:= 0
	Local lRet		:= .T.

	If( lRet := ExistCpo( "TKO" , M->TKL_BRIGAD + cGerTre ) )
		cDesTre := NGSEEK( "RA2" , cGerTre , 1 , "RA2_DESC" )
		cCalend := cGerTre
		nRA2Rec := RA2->( Recno() )
		dbSelectArea( "RA2" )
		dbGoTo( nRA2Rec )
		cGerCur := RA2->RA2_CURSO
		If !Empty( cGerCur )
			MDT560ValCur()
		Endif
	Endif

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT560ValCur
Função validação dos cursos do brigadista

@return lRet Lógico Retorna verdadeiro treinamento esteja correto

@sample MDT560ValCur()

@author Jackson Machado
@since 16/06/2011
/*/
//---------------------------------------------------------------------
Static Function MDT560ValCur()

	Local lRet := .T.

	dbSelectArea( "TKO" )
	dbSetOrder( 1 )
	If !dbSeek( xFilial( "TKO" ) + M->TKL_BRIGAD + cGerTre + cGerCur )
		Help( 1 , "" , "REGNOIS" )
		lRet := .F.
	Endif

	If lRet
		dbSelectArea( "RA2" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "RA2" ) + cGerTre + cGerCur )
			cDesCur := NGSEEK( "RA1" , cGerCur , 1 , "RA1_DESC" )
			dbSelectArea( "RA2" )
			dbSetOrder( 1 )
			If dbSeek( xFilial( "RA2" ) + cGerTre + cGerCur )
				nMax	:= RA2->RA2_VAGAS - RA2->RA2_RESERV
				cTurma	:= RA2->RA2_TURMA
			Endif
		Else
			Help( 1 , "" , "REGNOIS" )
			lRet := .F.
		Endif
	EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA560INV
Inverte a marcacao do browse

@return Lógico Sempre verdadeiro

@sample MDTA560INV( "X" )

@author Jackson Machado
@since 16/06/2011
/*/
//---------------------------------------------------------------------
Static Function MDTA560INV(cMarca)

	Local aArea := GetArea()

	dbSelectArea( ( cTRBTre ) )
	dbGoTop()
	While !Eof()
		( cTRBTre )->OK := If( ( cTRBTre )->OK == "  " , cMARCA , "  " )
		dbSkip()
	End
	dbSelectArea( ( cTRBTre ) )
	dbGoTop()

	RestArea( aArea )

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT560CarTrb
Carrega MarkBrowse dos Brigadistas

@return Lógico Sempre verdadeiro

@sample MDT560CarTrb()

@author Jackson Machado
@since 16/06/2011
/*/
//---------------------------------------------------------------------
Static Function MDT560CarTrb()

	Local cLoc := oTree:GetCargo()

	dbSelectArea( "TKM" )
	dbSetOrder( 1 )
	If dbSeek( xFilial( "TKM" ) + M->TKL_BRIGAD )
		While !Eof() .AND. TKM->TKM_BRIGAD == TKL->TKL_BRIGAD
			dbSelectArea( cTRBTre )
			RecLock( cTRBTre , .T. )
			( cTRBTre )->OK		:= ""
			( cTRBTre )->CODFUN	:= TKM->TKM_FUNCAO
			( cTRBTre )->DESFUN	:= NGSEEK( "TKU" , TKM->TKM_FUNCAO , 1 , "TKU_DESC" )
			If lFilMat //Verifica se campo existe.
				( cTRBTre )->FILMAT	:= TKM->TKM_FILMAT
			Endif
			( cTRBTre )->MATFUN	:= TKM->TKM_MATFUN
			( cTRBTre )->NOMFUN	:= NGSEEK( "SRA" , TKM->TKM_MATFUN , 1 , "RA_NOME" )
			( cTRBTKM )->( MsUnLock() )
			dbSelectArea( "TKM" )
			dbSkip()
		End
	Endif

	dbSelectArea( cTRBTre )
	dbSetOrder( 2 )
	dbGoTop()

	oTree:TreeSeek( cLoc )

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT560Trm
Valida o Treinamento

@return lRet Lógico Retorna verdadeiro caso treinamento esteja correto

@sample MDT560Trm()

@author Jackson Machado
@since 16/06/2011
/*/
//---------------------------------------------------------------------
Function MDT560Trm()

	Local nRA2Rec	:= 0
	Local lRet		:= .T.

	If ( lRet := MDT575CHKE( "RA2" , "M->TKO_CODTRE" , "RA2->RA2_CALEND" ) )

		cCalend		:= M->TKO_CODTRE
		M->TKO_CODTRE	:= RA2->RA2_CALEND
		nRA2Rec		:= RA2->(Recno())

		dbSelectArea( "RA2" )
		dbGoTo( nRA2Rec )
		oBrwC:aCols[ n , 3 ]	:= RA2->RA2_CURSO
		M->TKO_CURSO			:= RA2->RA2_CURSO
		If &( X3Valid( "TKO_CURSO" ) )
			dbSelectArea( "RA1" )
			dbSetOrder( 1 )
			dbSeek( xFilial( "RA1" ) + RA2->RA2_CURSO )
			oBrwC:aCols[ n , 4 ] := RA1->RA1_DESC
			oBrwC:aCols[ n , 5 ] := RA2->RA2_DURACA
			oBrwC:aCols[ n , 6 ] := RA2->RA2_UNDURA
		Endif

		oBrwC:oBrowse:Refresh()
	Endif

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT560GTrm
Valida gravação do Treinamento

@return lRet Lógico Retorna verdadeiro caso treinamento possa ser reservado

@sample MDT560GTrm()

@author Jackson Machado
@since 16/06/2011
/*/
//---------------------------------------------------------------------
Static Function MDT560GTrm()
Local nCont	:= 0
Local lRet		:= .T.
Local aSCargo	:= {}

If !MDT560ValCur() .Or. !MDT560ValTre()
	lRet := .F.
Endif

If lRet
	If !Empty( cGerTre ) .And. !Empty( cGerCur )
		dbSelectArea( "RA2" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "RA2" ) + cGerTre + cGerCur )
			If AllTrim( RA2->RA2_REALIZ ) == "S"
				ShowHelpDlg(	STR0051 , ;//"ATENÇÃO"
								{ STR0064 } , 2 , ;//"Treinamento já finalizado"
								{ STR0065 } , 2 )//"Informe um treinamento/curso não finalizado"
				lRet := .F.
			Endif
		Endif
		If lRet
			dbSelectArea( cTRBTre )
			dbSetOrder( 1 )
			dbGoTop()
			While ( cTRBTre )->( !Eof() )
				If !Empty( ( cTRBTre )->OK )
					nCont ++
					If !fExistCargo( ( cTRBTRE )->MATFUN )
						aAdd( aSCargo , ( cTRBTRE )->MATFUN )
					Endif
				Endif
				dbSelectArea( cTRBTre )
				dbSkip()
			End
			If Len( aSCargo ) > 0
				ShowHelpDlg(	STR0051 , ;//"ATENÇÃO"
								{ STR0073 + fRetFunc( aSCargo ) } , 4 , ;//"O(s) seguinte(s) funcionário(s) está(ão) sem cargo: "
								{ STR0074 } , 2 )//"Favor infomar cargo(s) para a(s) função(ões) do(s) funcionário(s)"
				dbSelectArea( cTRBTre )
				dbGoTop()
				lRet := .F.
			Endif
			If lRet
				If nCont > nMax
					ShowHelpDlg(	STR0051 , ;//"ATENÇÃO"
									{ STR0066 } , 2 , ;//"Número de brigadistas maior que o permitido"
									{ STR0067 } , 2 )//"Informe um número menor de brigadistas que irão fazer o treinamento"
					dbSelectArea( cTRBTre )
					dbGoTop()
					lRet := .F.
				Elseif nCont == 0
					ShowHelpDlg(	STR0051 , ;//"ATENÇÃO"
									{ STR0014 } , 2 , ;//"Nenhum brigadista selecionado."
									{ STR0037 } , 2 )//"Informe ao menos um brigadista para geração do treinamento ou clique no botão cancelar para sair"
					dbSelectArea( cTRBTre )
					dbGoTop()
					lRet := .F.
				Endif
			EndIf
		EndIf
	Else
		Help( 1 , " " , "OBRIGAT2" )
		lRet := .F.
	Endif
EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT560When
When do campo TKO_CURSO

@return lRet Lógico Retorna verdadeiro quando campo deve ser aberto

@sample MDT560When()

@author Jackson Machado
@since 16/06/2011
/*/
//---------------------------------------------------------------------
Function MDT560When()

	Local nPos := aScan( aHoBrwC , { | x | Trim( Upper( x[ 2 ] ) ) == "TKO_CODTRE" } )
	Local lRet := .F.

	If !Empty( oBrwC:aCols[ n , nPos ] )
		lRet := .T.
	Endif

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fExistCargo
Verifica a existencia de cargo para o funcionario

@return lRet Lógico Retorna verdadeiro quando cargo do funcionário for preenchido (necessário para o TRM)

@param cMat Caracter Matricula a ser validada

@sample fExistCargo( '000001' )

@author Jackson Machado
@since 01/11/2011
/*/
//---------------------------------------------------------------------
Static Function fExistCargo( cMat )

	Local aArea := GetArea()
	Local lRet:= .T.

	dbSelectArea( "SRA" )
	dbSetOrder( 1 )
	If ( lRet := SRA->( dbSeek( xFilial("SRA") + cMat ) ) )
		If Empty( SRA->RA_CARGO )
			dbSelectArea( "SRJ" )
			dbSetOrder( 1 )
			If ( lRet := SRJ->( dbSeek( xFilial( "SRJ" ) + SRA->RA_CODFUNC ) ) )
			   lRet:= !Empty( SRJ->RJ_CARGO )
		    Endif
		Endif
	Endif

	RestArea( aArea )

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fRetFunc
Retorna o nome dos funcionários

@return cFunc Caracter String com o nome de todos os funcionários

@param aFuncionarios Array Matriz com os funcionários a serem considerados

@sample fRetFunc( { '000001' } )

@author Jackson Machado
@since 01/11/2011
/*/
//---------------------------------------------------------------------
Static Function fRetFunc( aFuncionarios )

	Local nX
	Local cFunc := ""

	For nX := 1 To Len( aFuncionarios )
		If Empty( cFunc )
			cFunc += AllTrim( NGSEEK( "SRA" , aFuncionarios[ nX ] , 1 , "RA_NOME" ) )
		Else
			cFunc += ", " + AllTrim( NGSEEK( "SRA" , aFuncionarios[ nX ] , 1 , "RA_NOME" ) )
		Endif
	Next nX

Return cFunc
//---------------------------------------------------------------------
/*/{Protheus.doc} ValCodBrig
Valida o código da brigada

@return lRet Lógico Retorna verdadeiro quando código da brigada esteja correto

@param aFuncionarios Array Matriz com os funcionários a serem considerados

@sample ValCodBrig()

@author Jackson Machado
@since 01/11/2011
/*/
//---------------------------------------------------------------------
Function ValCodBrig()

	Local lRet		:= .T.
	Local aArea	:= GetArea()

	dbSelectArea( "TKL" )
	dbSetOrder( 1 )
	If dbSeek( xFilial( "TKL" ) + M->TKL_BRIGAD )
		HELP( " " , 1 , "JAGRAVADO" )
		lRet := .F.
	Endif

	RestArea( aArea )

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} MDT560DEM()
Informa que o funcionario está cadastrado na Brigada caso for demitir.
Usado pelo GPEA010.

@return lRet Lógico Retorna verdadeiro caso funcionário faça parte da brigada

@author Elynton Fellipe Bazzo
@since 25/02/2013
/*/
//-------------------------------------------------------------------
Function MDT560DEM()

	Local lRet			:= .F.
	Local lBrigada	:= .F. // Variável lógica, para verificação da data de saída do brigadista.
	Local lPerg		:= .F.
	Local aArea		:= GetArea() // Retorna a area de Trabalho.

	// verifica se o funcionário encontra em pelo menos uma brigada e que nao esteja com a data de saída preenchida.
	dbSelectArea( "TKM" )
	dbSetOrder( 6 ) // TKM_FILIAL+TKM_MATFUN
	dbSeek( xFilial( "TKM" ) + SRA->RA_MAT )
	While !Eof() .And. TKM->TKM_FILIAL == xFilial( "TKM" ) .And. TKM->TKM_MATFUN == SRA->RA_MAT
 		If Empty( TKM->TKM_DTSAID ) // Se a data de saída do brigadista não estiver preenchida.
  			lBrigada := .T.
 		EndIf
 		dbSelectArea("TKM")
 		dbSkip()
	EndDo

	If lBrigada // Se a data de saída do brigadista não estiver preenchida, exibe a mensagem.
		lRet := MsgYesNo( STR0075 ) // "Este Funcionário esta relacionado a uma ou mais brigadas, deseja demiti-lo?"
		lPerg := .T.
	EndIf

	If lRet // Retorno que exibe a mensagem informando que o funcionário será demitido.
		dbSelectArea( "TKM" )
		dbSetOrder( 6 ) // TKM_FILIAL+TKM_MATFUN
		dbSeek( xFilial( "TKM" ) + SRA->RA_MAT )
		While !Eof() .And. TKM->TKM_FILIAL == xFilial( "TKM" ) .And. TKM->TKM_MATFUN == SRA->RA_MAT
			If Empty( TKM->TKM_DTSAID )
				RecLock( "TKM" , .F. )
				TKM->TKM_DTSAID := M->RA_DEMISSA // marca a saída como a data de demissão.
				MsUnlock( "TKM" )
			EndIf
			dbSelectArea( "TKM" )
			dbSkip()
		EndDo
	EndIf

	lRet := If( lPerg , lRet , .T. )

	RestArea( aArea )

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} MDT560FILF()
Função responsável pela validação do campo TKM_FILMAT

@return lRet - Lógico

@author Guilherme Freudenburg
@since 02/02/2016
/*/
//-------------------------------------------------------------------
Function MDT560FILF()
	Local aArea    := GetArea()//Salva área
	Local aAreaSM0 := SM0->(GetArea())
	Local lRet     := .T.

	Dbselectarea("SM0")
	IF !Dbseek(cEmpAnt+M->TKM_FILMAT)
		Help(" ",1,"REGNOIS")
		lRet := .F.
	Else
		cFilAnt := M->TKM_FILMAT
		M->TKM_MATFUN := Space( Len(TKM->TKM_MATFUN) )
		M->TKM_NOMFUN := " "
		M->TKM_DTINCL := cTod(Space(8))
		M->TKM_DTSAID := cTod(Space(8))
		M->TKM_FUNCAO := Space( Len(TKM->TKM_FUNCAO) )
		M->TKM_DESFUN := " "
		M->TKM_TIPO   := " "
		M->TKM_ATRIB   := Space( Len(TKM->TKM_ATRIB) )
	EndIF

	RestArea(aAreaSM0)
	RestArea(aArea)
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} MDT560OLD()
Função responsavel por retornar a filial logada.

@return

@author Guilherme Freudenburg
@since 02/02/2016
/*/
//-------------------------------------------------------------------
Function MDT560OLD()

	If "TKM_MATFUN" $ ReadVar()
		cFilAnt := M->TKM_FILMAT
	Else
		cFilAnt := cFilBrig
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT560SRAF()
Função responsavel por realizar o filtro do SXB SRAF - Funcionários.

@return - Filtro

@author Guilherme Freudenburg
@since 22/07/2016
/*/
//-------------------------------------------------------------------
Function MDT560SRAF()

Return If(!Empty(M->TKM_FILMAT),SRA->RA_FILIAL==cFilAnt .And. !(SRA->RA_SITFOLH == 'D' .Or. !Empty(RA_DEMISSA) ),.T.)
