#Include "Protheus.ch"
#Include "MDTA992.ch"

#Define _Picture 3
#Define _Tamanho 4

STATIC _nFolders	:= 6 //Numero total de folder
STATIC _nFunc			:= 1
STATIC _nRisc			:= 2
STATIC _nEpis			:= 3
STATIC _nEqui			:= 4
STATIC _nChec			:= 5
STATIC _nCont			:= 6

//Define posicoes do array de tabelas
STATIC _nPosFol := 1
STATIC _nPosTab := 2
STATIC _nPosOrd := 3
STATIC _nPosCps := 4

STATIC _MDT992DEL := "X"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA992
Permissão de Trabalho

@author Marcos Wagner Jr.
@since 15/02/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDTA992()

	Local aNGBEGINPRM := NGBEGINPRM()

	If !NGCADICBASE( "TI0_PERMIS", "A", "TI0", .F. )
		NGINCOMPDIC( , "TRXQOC" )
	Else
		Private aRotina  := MenuDef()

		//--------------------------------------------
		// Define o cabecalho da tela de atualizacoes
		//--------------------------------------------
		Private cCadastro := OemtoAnsi( STR0001 ) // "Permissão de Trabalho"

		//-------------------------------
		// Endereca a funcao de BROWSE
		//-------------------------------
		dbSelectArea( "TI0" )
		dbSetOrder( 1 )
		MBrowse( 6, 1, 22, 75, "TI0", , , , , , MDTA992COR() )

	EndIf

	NGRETURNPRM( aNGBEGINPRM )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu de Compartimento Padrão

@author Marcos Wagner Jr.
@since 15/02/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	aRotina := { { STR0002, "AxPesqui", 0, 1 },;	  // "Pesquisar"
				 { STR0003, "MDTA992CAD", 0, 2 },;	  // "Visualizar"
				 { STR0004, "MDTA992CAD", 0, 3 },;	  // "Incluir"
				 { STR0005, "MDTA992CAD", 0, 4 },;	  // "Alterar"
				 { STR0006, "MDTA992CAD", 0, 5, 3 },; // "Excluir"
				 { STR0022, "MDTR980", 0, 6 },;	      // "Imprimir"
				 { STR0008, "MDTA992LEG", 0, 7 },;	  // "Legenda"
				 { STR0009, "MDTA992CAD", 0, 8 },;	  // "Cópia"
				 { STR0111, "MDTA992CON", 0, 4 },;	  // "Conclusão"
				 { STR0112, "MDTA992REV", 0, 4 },;	  // "Revisão"
				 { STR0007, "MDTA992LIB", 0, 4 } }    // "Liberação"

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA992CAD
Cadastro de permissão de trabalho (Inclusao/Alteracao/Exclusao)

@author Marcos Wagner Jr.
@since 15/02/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDTA992CAD( cAliasX, nRecnoX, nOpcx )

	Local nOpca
	Local cQuesti
	Local oDlg992
	Local oEnc992
	Local oPnlPai
	Local oPnlTop
	Local oPnlBot
	Local oPanelBT
	Local oSplitterA
	Local oSplitterB
	Local cPermiss
	Local cSeqPerm
	Local oTempGrp
	Local oTempPer
	Local nOper      := 0
	Local cTitulo    := cCadastro
	Local aTitles992 := {}
	Local aPages992  := {}
	Local aColor     := NGColor()
	Local cAliGrp    := GetNextAlias()
	Local cAliPerg   := GetNextAlias()
	Local aAreaTI0   := TI0->( GetArea() )
	Local aChoiceTI0 := {}

	Private aTROCAF3   := {}
	Private lDiretriz  := .F.
	Private lCopia     := .F.
	Private cOrdGpr992 := "" //Utilizado no SXB da tabela TJ3, função FILSXBTJ3

	//-----------------------------
	// _nPosFol := 1
	// _nPosTab := 2
	// _nPosOrd := 3
	// _nPosCps := 4
	// Folder;Tabela;Indice;Campos
	//-----------------------------

	Private aRelacio := { ;
						 { _nFunc, "TI1", 1, { "TI1_TIPFUN", "TI1_CODFUN", "TI1_NOMFUN" } },;
						 { _nRisc, "TI2", 1, { "TI2_NUMRIS" } },;
						 { _nEpis, "TI3", 1, { "TI3_CODEPI" } },;
						 { _nEqui, "TI4", 1, { "TI4_EQUIPA" } },;
						 { _nCont, "TI6", 1, { "TI6_CODCON" } },;
						 }
	//Mark Browse
	Private cMarca    := GetMark()
	Private lInverte  := .F.

	//Variaveis de Enchoice
	Private aTela    := {}
	Private aGets    := {}
	Private aSvATela := {}
	Private aSvAGets := { {}, {} }

	//Variaveis para objeto MSNewGetDados
	Private aCols1
	Private aCols2
	Private aCols3
	Private aCols4
	Private aCols6
	Private aHead1
	Private aHead2
	Private aHead3
	Private aHead4
	Private aHead6

	Private aHeadGrp
	Private aHeadPerg
	Private aColsGrp
	Private aColsPerg

	Private oGetGrp
	Private oGetPerg

	//Variaveis para Estrutura Organizacional e TRB
	Private oFolder

	//Variaveis de tamanho de tela e objetos
	Private aSize    := MsAdvSize( , .F., 430 )
	Private aObjects := {}

	aAdd( aObjects, { 050, 050, .T., .T. } )
	aAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	nRecno := TI0->(Recno())

	//--------------------------------------------------
	// Analisa qual a correta operação a ser realizada
	//--------------------------------------------------
	If nOpcx == 4
		If TI0->TI0_STATUS $ "1#2#5"
			ShowHelpDlg( "NOLIBERAD", { STR0036 + NGRETSX3BOX( "TI0_STATUS", TI0->TI0_STATUS ) + "'." },; //"Permissão de trabalho está com o Status igual a '"
						 2, { STR0037 }, 3 ) //" Será possivel, apenas, a visualização deste registro."
			nOpcx := 2
		EndIf
	EndIf

	Inclui     := ( nOpcx == 3 )
	Altera     := ( nOpcx == 4 )
	aChoiceTI0 := faChoice( nOpcx )

	//------------------------
	// PT/PET
	//------------------------
	dbSelectArea( "TI0" )
	RegToMemory( "TI0", ( nOpcx == 3 ) )

	If nOpcx == 8 //Cópia
		SetAltera( .T. ) // Define operacao como alteração
		lCopia := .T.

		M->TI0_PERMIS := GETSXENUM( 'TI0', 'TI0_PERMIS' )
		M->TI0_SEQPER := Replicate( "0", Len( TI0->TI0_SEQPER ) )
		M->TI0_STATUS := "4"//Não respondida

		lDiretriz := MsgYesNo( STR0023, STR0024 ) // "Deseja copiar a permissão com as mesmas diretrizes?" ## "Atenção"

		If lDiretriz
			M->TI0_STATUS := TI0->TI0_STATUS
			cPermiss      := TI0->TI0_PERMIS
			cSeqPerm      := TI0->TI0_SEQPER
		Else
			cPermiss     := M->TI0_PERMIS
			cSeqPerm     := M->TI0_SEQPER
		EndIf
	Else
		cPermiss := M->TI0_PERMIS
		cSeqPerm := M->TI0_SEQPER
	EndIf
	nOper  := IIf( lCopia, 4, nOpcx )

	//-------------------------------------------
	// Inicialização das estruturas e valores:
	// fGetFrame: aHeader e aCols
	// fGetFolder: Folders
	// fGetQuesti: TRB do Questionario
	//--------------------------------------------

	// Utilizada na TGet()
	M->TI5_QUESTI := PaDR( NGSeek( "TI5", cPermiss + cSeqPerm, 1, "TI5_QUESTI" ), TAMSX3( "TJ3_QUESTI" )[1] )
	//Variavel de controle, para caso altere o codigo do questionario
	cQuesti	:= M->TI5_QUESTI

	fGetFrame( nOper )
	fGetFolder( @aPages992, @aTitles992 )
	fGetQuesti( cPermiss + cSeqPerm, @cAliGrp, @oTempGrp, @cAliPerg, @oTempPer, IIf( lCopia, nOpcx, nOper ) )

	Define MsDialog oDlg992 Title cTitulo From aSize[7], 000 To aSize[6], aSize[5] Of oMainWnd Pixel

		oPnlPai := TPanel():New( 0, 0, , oDlg992, , , , , , 0, 0, .F., .F. )
			oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

		oSplitterA := tSplitter():New( 00, 00, oPnlPai, 000, 000 )
			oSplitterA:SetOrient( 1 )
			oSplitterA:Align := CONTROL_ALIGN_ALLCLIENT

		oPnlTop := TPanel():New( 0, 0, , oSplitterA, , , , , , 12, oSplitterA:nClientHeight * 0.2, .F., .F. )
			oPnlTop:Align := CONTROL_ALIGN_TOP

		oPnlBot := TPanel():New( 0, 0, , oSplitterA, , , , , , 12, , .F., .F. )
			oPnlBot:Align := CONTROL_ALIGN_ALLCLIENT

		//-----------------------------------------------
		// Enchoice PT/PET
		//-----------------------------------------------
		oEnc992:= MsMGet():New( "TI0", nRecno, nOper, , , , aChoiceTI0, aPosObj[1], , , , , , oPnlTop, , , .F. )
		oEnc992:oBox:Align := CONTROL_ALIGN_ALLCLIENT

		//-----------------------------------------------
		// Cria os Folders
		//-----------------------------------------------
		oFolder := TFolder():New( 1, 0, aTitles992, aPages992, oPnlBot, , , , .F., .F., 0, 0 )
		oFolder:Align := CONTROL_ALIGN_ALLCLIENT

		aSvATela := aClone( aTela )
		aSvAGets := aClone( aGets )

		//-----------------------------------------------
		// Folder 1 - Funcionarios
		//-----------------------------------------------
		oPnlFunLef := TPanel():New( 0, 0, , oFOLDER:aDIALOGS[_nFunc], , , , , aColor[ 2 ], 12, 12, .F., .F. )
			oPnlFunLef:Align := CONTROL_ALIGN_LEFT

		If nOper == 3 .Or. nOper == 4
			oBtnEntBrig := TBtnBmp():NewBar( "ng_ico_entrada", "ng_ico_entrada", , , , { ||fImpRegCols( 1 ) }, , oPnlFunLef, , , STR0017, , , , , "" ) // "Importar participantes"
				oBtnEntBrig:Align  := CONTROL_ALIGN_TOP
		EndIf

		oGet9921 := MsNewGetDados():New( 0, 0, 135, 315, IIf( !Inclui .And. !Altera, 0, GD_INSERT + GD_UPDATE + GD_DELETE ),;
						 { || MDT992LIOK( _nFunc, oFolder ) }, "AllwaysTrue()", , , , 9929, , , , oFOLDER:aDIALOGS[_nFunc], aHead1, aCols1 )
			oGet9921:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
			oGet9921:oBrowse:bValid:= { || MDT992LIOK( _nFunc, oFolder ) }
			oGet9921:oBrowse:Default()
			oGet9921:oBrowse:REFRESH()

		//-----------------------------------------------
		// Folder 2 - Riscos da permissão
		//-----------------------------------------------
		oPnlRisLef := TPanel():New( 0, 0, , oFOLDER:aDIALOGS[_nRisc], , , , , aColor[ 2 ], 12, 12, .F., .F. )
			oPnlRisLef:Align := CONTROL_ALIGN_LEFT

		If nOper == 3 .Or. nOper == 4
			oBtnImpRis  := TBtnBmp():NewBar( "ng_ico_entrada", "ng_ico_entrada", , , , { ||fImpRegCols( 2 ) }, , oPnlRisLef, , , STR0018, , , , , "" ) // "Importar riscos"
				oBtnImpRis:Align  := CONTROL_ALIGN_TOP
		EndIf

		oGet9922 := MsNewGetDados():New( 0, 0, 135, 315, IIf( !Inclui .And. !Altera, 0, GD_INSERT + GD_UPDATE + GD_DELETE ),;
				 { || MDT992LIOK( _nRisc, oFolder ) }, "AllwaysTrue()", , , , 9929, , , "MDT992DEL(2)", oFOLDER:aDIALOGS[_nRisc], aHead2, aCols2 )
		oGet9922:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oGet9922:oBrowse:bValid:= { || MDT992LIOK( _nRisc, oFolder ) }
		oGet9922:oBrowse:Default()
		oGet9922:oBrowse:REFRESH()

		//-----------------------------------------------
		// Folder 3 - Epis da permissão
		//-----------------------------------------------
		oGet9923 := MsNewGetDados():New(0, 0, 135, 315, IIf( !Inclui .And. !Altera, 0, GD_INSERT + GD_UPDATE + GD_DELETE ),;
				 { || MDT992LIOK( _nEpis, oFolder ) }, "AllwaysTrue()", , , , 9929, , , , oFOLDER:aDIALOGS[_nEpis], aHead3, aCols3 )
		oGet9923:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oGet9923:oBrowse:Default()
		oGet9923:oBrowse:REFRESH()

		//-----------------------------------------------
		// Folder 4 - Equipamentos da permissão
		//-----------------------------------------------

		oGet9924 := MsNewGetDados():New( 0, 0, 135, 315, IIf( !Inclui .And. !Altera, 0, GD_INSERT + GD_UPDATE + GD_DELETE ),;
				 { || MDT992LIOK( _nEqui, oFolder ) }, "AllwaysTrue()", , , , 9929, , , , oFOLDER:aDIALOGS[_nEqui], aHead4, aCols4 )
		oGet9924:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oGet9924:oBrowse:Default()
		oGet9924:oBrowse:REFRESH()

		//-----------------------------------------------
		// Folder 5 - CheckList
		//-----------------------------------------------
		oPnlChkTop := TPanel():New( 0, 0, , oFOLDER:aDIALOGS[_nChec], , , , , aColor[ 2 ], 12, 15, .F., .F. )
			oPnlChkTop:Align := CONTROL_ALIGN_TOP

		// Panel bottom
		oPanelBT := TPanel():New( 000, 000, , oFOLDER:aDIALOGS[_nChec], , , , , CLR_WHITE, 12, 12, .F., .T. )
			oPanelBT:Align := CONTROL_ALIGN_ALLCLIENT

			TSay():New( 003, 002, { | | OemtoAnsi( STR0041 ) }, oPnlChkTop, , , .F., .F., .F., .T., aColor[ 1 ], CLR_WHITE, 200, 010 ) //"Questionário: "

			oQuest := TGet():New( 002, Len( STR0041 ) * 3, { | u | IIf( PCount() > 0, M->TI5_QUESTI := u, M->TI5_QUESTI ) },; //"Questionário: "
								 oPnlChkTop, TAMSX3( "TJ2_QUESTI" )[1] * 8, 008, "", { || fValQuesti( @cQuesti, cAliGrp, cAliPerg ) },;
								 CLR_BLACK, CLR_WHITE, , .F., , .T., , .F., { || fGetPergs( M->TI5_QUESTI, @oPanelBT, nOper ) },;
								 .F., .F., { | | fGetPergs( M->TI5_QUESTI, @oPanelBT, nOper ) }, .F., .F., "TJ2", "M->TI5_QUESTI",;
								 "TI5_QUESTI", , , .T. )
				oQuest:SetFocus()

					oSplitterB := tSplitter():New( 00, 00, oPanelBT, 000, 000 )
					oSplitterB:Align := CONTROL_ALIGN_ALLCLIENT
						//---------------------
						// Grupo de perguntas
						//---------------------
						oBttom1 := TPanel():New( 00, 00, , oSplitterB, , , , , , 000, 000, .F., .F. )
						oBttom1:nWidth := 150

							// Exibe titulo de grupo de perguntas
							oPnlTGR := TPanel():New( 00, 00, , oBttom1, , , , CLR_WHITE, RGB( 67, 70, 87 ), 000, 013, .F., .F. )
							oPnlTGR:Align := CONTROL_ALIGN_TOP
								TSay():New( 002, 002, { || STR0042 }, oPnlTGR, , , , , , .T., CLR_WHITE, , 200, 010 ) // # "Grupo Perguntas"

							// Panel da get dados de grupo de perguntas
							oPnlGRP := TPanel():New( 000, 000, , oBttom1, , , , , CLR_WHITE, 000, 000, .F., .F. )
							oPnlGRP:Align := CONTROL_ALIGN_ALLCLIENT

								// Get dados de grupo de perguntas TJ3
								oGetGrp := MsNewGetDados():New( 000, 000, 000, 000, IIf( !Inclui .And. !Altera, 0, GD_INSERT + GD_UPDATE + GD_DELETE),;
																 , , , , , , , , , oPnlGRP, aHeadGrp, aColsGrp )
								oGetGrp:bLinhaOk       := { || fLinhaOk( 1, .T. ) .And. fChgGrp( cAliGrp, cAliPerg ) }
								oGetGrp:bChange        := { || fChgGrp( cAliGrp, cAliPerg ) }
								oGetGrp:bFieldOk       := { || fValGrupo( cAliGrp, cAliPerg ) }
								oGetGrp:bDelOk         := { || fDelCheck( cAliGrp, cAliPerg, 1 ) }
								oGetGrp:oBrowse:bValid := { || fLinhaOk( 1, .F. ) .And. fChgGrp( cAliGrp, cAliPerg ) }
								oGetGrp:oBrowse:Align  := CONTROL_ALIGN_ALLCLIENT

						//-------------------------
						// Perguntas
						//-------------------------
						oBttom2 := TPanel():New( 00, 00, , oSplitterB, , , , , CLR_WHITE, 000, 000, .F., .F. )
						oBttom2:nWidth := 300

							// exibe titulo de grupo de perguntas
							oPnlTPR := TPanel():New( 00, 00, , oBttom2, , , , CLR_WHITE, RGB( 67, 70, 87 ), 000, 013, .F., .F. )
							oPnlTPR:Align := CONTROL_ALIGN_TOP
								TSay():New( 002, 002, { || STR0043 }, oPnlTPR, , , , , , .T., CLR_WHITE, , 200, 010 ) // #"Perguntas"

							// panel da get dados de perguntas
							oPnlPER := TPanel():New( 000, 000, , oBttom2, , , , , CLR_WHITE, 000, 000, .F., .F. )
							oPnlPER:nWidth := 300
							oPnlPER:Align := CONTROL_ALIGN_ALLCLIENT

								// Get dados de perguntas
								oGetPerg := MsNewGetDados():New( 000, 000, 000, 300, IIf( !Inclui .And. !Altera, 0, GD_INSERT + GD_UPDATE + GD_DELETE ),;
																 , , , , , , , , , oPnlPER, aHeadPerg, aColsPerg )
								oGetPerg:bLinhaOk       := { || fChgPerg( cAliGrp, cAliPerg ) .And. fLinhaOk( 2, .T. ) }
								oGetPerg:bChange        := { || fChgPerg( cAliGrp, cAliPerg ) }
								oGetPerg:bDelOk         := { || fDelCheck( cAliGrp, cAliPerg, 2 ) }
								oGetPerg:oBrowse:bValid := { || fChgPerg( cAliGrp, cAliPerg ) .And. fLinhaOk( 2, .F. ) }
								oGetPerg:bFieldOk       := { || fValQuesta() }

								//Seta atributos do objeto get dados
								oGetPerg:oBrowse:Align		:= CONTROL_ALIGN_ALLCLIENT

 		//-----------------------------------------------
		// Folder 6 - Contatos
		//-----------------------------------------------
		oGet9926 := MsNewGetDados():New( 0, 0, 135, 315, IIf( !Inclui .And. !Altera, 0, GD_INSERT + GD_UPDATE + GD_DELETE),;
						 { || MDT992LIOK( _nCont, oFolder ) }, "AllwaysTrue()", , , , 9929, , , , oFOLDER:aDIALOGS[_nCont], aHead6, aCols6 )
		oGet9926:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oGet9926:oBrowse:Default()
		oGet9926:oBrowse:REFRESH()

		//Habilita ou desabilita o folder de Riscos/Equipamentos/EPIs
		HabFolder()

	Activate MsDialog oDlg992 On Init EnchoiceBar( oDlg992, { || nOpca := 1, IIf( !MDTA992TOK( oFolder, nOper ), nOpca := 0, oDlg992:End() ) };
												 , { || oDlg992:End() } ) CENTERED

	If nOpca == 1
		MDTA992GRA( nOper, nRecno, cAliGrp, cAliPerg )
	Else
		If nOper == 3 .Or. nOper == 4
			RollBackSX8()
		EndIf
	EndIf

	IIf( Select( oTempGrp ) > 0, oTempGrp:Delete(), )
	IIf( Select( oTempPer ) > 0, oTempPer:Delete(), )

	RestArea( aAreaTI0 )

Return nOpca

//---------------------------------------------------------------------
/*/{Protheus.doc} fValQuesti
Validação do campo de Questionário (M->TI5_QUESTI)

@author Guilherme Benkendorf
@since 01/12/2014
@version MP11
@return lRet
/*/
//---------------------------------------------------------------------
Static Function fValQuesti( cQuesti, cAliGrp, cAliPerg )

	Local lRet     := .T.
	Local aArea    := GetArea()
	Local aAreaTJ2 := TJ2->( GetArea() )

	If !Empty( cQuesti ) .And. cQuesti != M->TI5_QUESTI .And. Len( oGetGrp:aCols ) > 0
		lRet := MsgYesNo( STR0044, STR0024 ) //"Ao trocar o questionário, será limpo os 'Grupos de Perguntas' e suas 'Perguntas'. Deseja continuar?"###//"Atenção"
		If lRet
			dbSelectArea( cAliGrp )
			ZAP
			dbSelectArea( cAliPerg )
			ZAP

			oGetGrp:aCols := BLANKGETD( oGetGrp:aHeader )
			oGetPerg:aCols:= BLANKGETD( oGetPerg:aHeader )
			oGetGrp:Refresh()
			oGetPerg:Refresh()
		EndIf
	EndIf

	If lRet
		lRet := IIf( !Empty( cQuesti ), ExistCpo( "TJ2", cQuesti ), .T. )
	EndIf

	If lRet .And. !Empty( M->TI5_QUESTI )
		lRet := fValCpoTJ2( , , .T. )
	EndIf


	// Bloco de controle para o preenchimento do código do questionário
	If lRet
		cQuesti := M->TI5_QUESTI
	EndIf

	RestArea( aArea )
	RestArea( aAreaTJ2 )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT992LIOK
Funcao de validação do para as GetDados, menos a do CheckList

@author Marcos Wagner Jr.
@since 15/02/2013
@author Guilherme Benkendorf
@since 01/12/2014
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT992LIOK( nGet, oFolder )

	Local nI
	Local nX
	Local nY
	Local nAt
	Local nPosSeek
	Local nRelac := 0
	Local lRet   := .T.

	Local nTI1TipFun := GDFieldPos( "TI1_TIPFUN", oGet9921:aHeader )
	Local nTI1CodFun := GDFieldPos( "TI1_CODFUN", oGet9921:aHeader )
	Local nTI1NomFun := GDFieldPos( "TI1_NOMFUN", oGet9921:aHeader )
	Local nTI2NumRis := GDFieldPos( "TI2_NUMRIS", oGet9922:aHeader )

	Local aColsOk := {}
	Local aHeadOk := {}

	aColsOk	:= aClone( &( "oGet992" + cValToChar( nGet ) ):aCols )
	aHeadOk	:= aClone( &( "oGet992" + cValToChar( nGet ) ):aHeader )
	nAt		:= &( "oGet992"+ cValToChar( nGet ) ):nAt

	nPosRel := aScan( aRelacio, { | x | nGet == x[1] } )

	For nI := 1 To Len( aColsOk )

		If !( aTail( aColsOk[nI] ) ) .And. !Empty( aColsOk[nI][1] )
			//GetDados de Funcionarios
			If nGet == _nFunc
				If aColsOk[nI][nTI1TipFun] == '1'
					If Empty( aColsOk[nI][nTI1CodFun] )
						Help( " ", 1, "OBRIGAT", , oGet9921:aHeader[nTI1CodFun][1], 05 )
						lRet := .F.
						Exit
					EndIf
				ElseIf aColsOk[nI][nTI1TipFun] == '2' .And. Empty( aColsOk[nI][nTI1NomFun] )
					Help( " ", 1, "OBRIGAT", , oGet9921:aHeader[nTI1NomFun][1], 05 )
					lRet := .F.
					Exit
				EndIf
			//GetDados de Riscos
			ElseIf nGet == _nRisc
				If !fChkIntRis( aColsOk[nI][nTI2NumRis], .T. )
					lRet := .F.
					Exit
				EndIf
			EndIf
		EndIf

		If lRet .And. nI != nAt .And. !( aTail( aColsOk[nI] ) ) .And. !( aTail( aColsOk[nAt] ) )
			For nY := 1 To Len( aRelacio[nPosRel][_nPosCps] )
				nPosSeek := GDFieldPos( aRelacio[nPosRel][_nPosCps][nY], aHeadOk )
				If aColsOk[nI][nPosSeek] == aColsOk[nAt][nPosSeek]
					nRelac++
				EndIf
			Next nY
			If nRelac > 0 .And. nRelac == Len( aRelacio[nPosRel][_nPosCps] )
	  			MsgStop( STR0021 + oFolder:aDialogs[nGet]:GetText(), STR0020 ) // "Registro duplicado no Folder: " ## "Atenção"
		   		lRet := .F.
		   		Exit
			EndIf
			nRelac := 0
		EndIf
	Next nI

	PutFileInEof( aRelacio[nPosRel][_nPosTab] )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA992TOK
TudoOK da tela

@author Marcos Wagner Jr.
@since 15/02/2013
@version MP11
@return lRet Boolean
/*/
//---------------------------------------------------------------------
Function MDTA992TOK( oFolder, nOpc )

	Local aOldArea := GetArea()
	Local aAreaTI0 := {}
	Local lRet     := .T.
	Local lIncons  := .F.
	Local nI

	If nOpc == 3 .Or. nOpc == 4
		If lRet
		 	lRet := OBRIGATORIO( aSvAGets, aSvATela )
		EndIf

		If lRet
			lRet := fValPTDt()
		EndIf

		If lRet
			For nI := 1 To _nFolders
				If lRet
					If nI != _nChec // Para o Folder de CheckList a verificação é personalizada
						lRet := MDT992LIOK( nI, oFolder )
					EndIf
				EndIf
			Next nI
		EndIf
	ElseIf nOpc == 5
		aAreaTI0 := TI0->( GetArea() )
		dbSelectArea( "TI0" )
		dbSetOrder( 1 )
		dbSeek( xFilial( "TI0" ) + M->TI0_PERMIS + M->TI0_SEQPER )
		TI0->( dbSkip() )
		If ( !Bof() .And. !Eof() )
			lIncons := xFilial( "TI0" ) == TI0->TI0_FILIAL .And. M->TI0_PERMIS == TI0->TI0_PERMIS .And. M->TI0_SEQPER != TI0->TI0_SEQPER

			If lIncons
				ShowHelpDlg( "EXCPERINV", { STR0119 }, 2,; //"Operação de exclusão inválida. Há uma sequência posterior a esta."
							 { STR0120 }, 2 )              //"A realização deverá ser feita na última sequência desta Permissão."
				lRet := .F.
			EndIf
		EndIf
		RestArea( aAreaTI0 )
	EndIf

	RestArea( aOldArea )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fLinhaOk
LinhaOk da tela de CheckList

@author Guilherme Benkendorf
@since 29/09/2014
@version MP11
@return lRet Boolean
/*/
//---------------------------------------------------------------------
Static Function fLinhaOk( nOpcao, lLinhaOk )

	Local cTpList
	Local cTipReg
	Local nX
	Local lRet       := .T.
	Local nAtG       := oGetGrp:nAt
	Local nAtP       := oGetPerg:nAt
	Local nPosCodGru := GDFieldPos( "TI5_CODGRU", oGetGrp:aHeader )
	Local nPosQuesta := GDFieldPos( "TI5_QUESTA", oGetPerg:aHeader )
	Local nPosRespos := GDFieldPos( "TI5_RESPOS", oGetPerg:aHeader )
	Local nPosResult := GDFieldPos( "TI5_RESULT", oGetPerg:aHeader )
	Local nPosOperad := GDFieldPos( "TI5_OPERAD", oGetPerg:aHeader )


	Local lDelGrp := aTail( oGetGrp:aCols[nAtG] )
	Local lDelPrg := aTail( oGetPerg:aCols[nAtP] )

	Default lLinhaOk := .F.

	cTipReg   := NGSeek( "TJ4", oGetGrp:aCols[nAtG][nPosCodGru], 1, "TJ4_TIPREG" )
	cTpList   := NGSeek( "TJ3", M->TI5_QUESTI + oGetPerg:aCols[nAtP][nPosQuesta], 1, "TJ3_TPLIST" )
	//-----------------------------
	// Grupo de Perguntas
	//	----------------------------
	If nOpcao == 1 //Grupo de Perguntas
		If lRet .And. ( nOpcao == 1 )
			For nX := 1 To Len( oGetGrp:aCols )

				If nAtG != nX .And. !( lDelGrp ) .And. !( aTail( oGetGrp:aCols[nX] ) )
					If oGetGrp:aCols[nAtG][nPosCodGru] == oGetGrp:aCols[nX][nPosCodGru]
						lRet := .F.
						Help( " ", 1, "JAEXISTINF" )
						Exit
					EndIf
				EndIf

			Next nX
		EndIf
	EndIf

	//-----------------------------
	// Perguntas
	//	----------------------------
	If nOpcao == 2 // Perguntas

		If lRet .And. ( nOpcao == 2 )
			For nX := 1 To Len( oGetPerg:aCols )
				If nAtP != nX .And. !( lDelPrg ) .And. !( aTail( oGetPerg:aCols[nX] ) )

					If oGetPerg:aCols[nAtP][nPosCodGru] == oGetPerg:aCols[nX][nPosCodGru]
						lRet := .F.
						Help( " ", 1, "JAEXISTINF" )
						Exit
					EndIf

				EndIf
			Next nX
		EndIf

			// Não permite perguntas dos tipos 'Múltiplas Opções'( 2 ) para grupo do tipo 'Titulo de Colunas'( 2 )
		If lRet .And. cTpList == "2" .And. cTipReg == "2" .And. !( lDelGrp .And. lDelPrg )
			ShowHelpDlg( "", { STR0045 }, 2, { "" }, 2 ) // "Não é possível inserir perguntas de 'Múltiplas Opções' caso grupo seja do tipo 'Título de colunas'."
			lRet := .F.
		EndIf

		If lRet .And. lDelGrp .And. !lDelPrg
			ShowHelpDlg( "", { STR0058 }, 2, { "" }, 2 ) // "Não é possível relacionar perguntas a um grupo deletado."
			lRet := .F.
		EndIf

		If !lDelGrp .And. !lDelPrg

			If lRet .And. !Empty( oGetPerg:aCols[nAtP][nPosQuesta] ) .And. Empty( oGetGrp:aCols[nAtG][nPosCodGru] )
				ShowHelpDlg( "", { STR0059 }, 2,; // "Código do Grupo esta vazio."
							 { STR0060 }, 2 )      //"Preencha o Código do Grupo relacionado a essa pergunta."
				lRet := .F.
			EndIf

			If cTpList $ "12" .And. !( cTipReg $ "34" )
				If lRet .And. Empty( oGetPerg:aCols[nAtP][nPosRespos] )

					ShowHelpDlg( "", { STR0061 }, 2,; // "Para pergunta do tipo 'Opção Exclusiva' ou 'Múltiplas Opções' é obrigatório informar as opções."
								 { STR0067 }, 2 )     //"Informe as opções."
					lRet := .F.
				EndIf
			EndIf

			If ( cTpList $ "45" .Or. cTipReg == "3" )
				If lRet .And. Empty( oGetPerg:aCols[nAtP][nPosResult] ) .Or. Empty( oGetPerg:aCols[nAtP][nPosOperad] )
					ShowHelpDlg( "", { STR0068 }, 2,; //"Para perguntas do tipo 'Numérico' ou 'Fórmula' é obrigatório informar a 'Operação' e o 'Resultado'."
								 { STR0069 }, 2 )     //"Informe a Operação/Resultado."
					lRet := .F.
				EndIf
			EndIf
			If lRet .And. cTipReg == "3" .And. Len( oGetPerg:aCols ) == 1 .And. lLinhaOk
				ShowHelpDlg( "", { STR0070 }, 2,; //"Para Grupos de Perguntas do tipo 'Total' será informado apenas o valor do Totalizador."
							 { STR0071 }, 2 )    //"Informe apenas um valor total."
				lRet := .F.
			EndIf
		EndIf

		If !lRet .And. lLinhaOk
			oGetPerg:oBrowse:SetFocus()
		EndIf
	EndIf


	PutFileInEof( "TI5" )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA992GRA
Gravacao da tabela de Permissoes e relacionadas

@author Marcos Wagner Jr.
@since 15/02/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDTA992GRA( nOpcx, nRecno, cAliGrp, cAliPerg )

	Local cChaveTI0 := ""
	Local aAreaTI0  := TI0->( GetArea() )
	Local lExclui   := .F.
	Local lAltChkSt := .F.
	Local lGrava    := .T.
	Local aNao      := { "TI1", "TI2", "TI3", "TI4", "TI5", "TI6" } //Tabelas que não serão verificadas no SX9

	// Se for cópia, seta como Inclusão.
	nOpcx  := IIf( lCopia, 3, nOpcx )
	Altera := IIf( lCopia, .F., Altera )
	lExclui:= nOpcx == 5

	//----------------------
	// TI0 - Permissao
	//----------------------
	//-------------------------------------------------------------------------
	// Quando é exclusão e necessario alterar o Status da permissão anterior.
	//-------------------------------------------------------------------------
	If lExclui
		dbSelectArea( "TI0" )
		dbSetOrder( 1 ) //TI0_FILIAL+TI0_PERMIS+TI0_SEQPER
		dbSeek( xFilial( "TI0" ) + M->TI0_PERMIS + M->TI0_SEQPER )
		TI0->( dbSkip( -1 ) )

		If ( !Bof() .Or. !Eof() ) .And. TI0->TI0_PERMIS == M->TI0_PERMIS
			lAltChkSt := .T.
			cChaveTI0 := xFilial( "TI0" ) + TI0->TI0_PERMIS + TI0->TI0_SEQPER
		EndIf
		RestArea( aAreaTI0 )
	EndIf

	lGrava:= IIf( nOpcx == 5, NGVALSX9( "TI0", aNao, .T., , .T. ), .T. ) //Caso seja exclusão verifica relacionamentos.

	If lGrava //Verifica relacionamentos ao excluir.
		fGravaTI0( nOpcx, nRecno )

		//----------------------
		// TI5 - CheckList da Permissão
		//----------------------
		fGravaTI5( nOpcx, cAliGrp, cAliPerg )

		//----------------------
		// TI1/TI2/TI3/TI4/TI6
		//----------------------
		fGravaFol( nOpcx )
	EndIf
	//-------------------------------------------------------------------------
	// Quando é exclusão e necessario alterar o Status da permissão anterior.
	//-------------------------------------------------------------------------
	If lAltChkSt
		dbSelectArea( "TI0" )
		dbSetOrder( 1 ) //TI0_FILIAL+TI0_PERMIS+TI0_SEQPER
		dbSeek( cChaveTI0 )

		//---------------------------------------------------------
		// Verifica checklist com o questionário respondido.
		// E altera status da liberação da PT/PET.
		//---------------------------------------------------------
		fPTStatus( .T. )
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fGravaTI0
Gravacao da tabela de Permissoes e relacionadas

@author Guilherme Benkendorf
@since 01/12/2014
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fGravaTI0( nOpcTI0, nRecTI0 )

	Local nX
	Local nY
	Local cSeqRes
	Local aMemos  := {	 {"TI0_PROSYP", "TI0_PROCED" },;
						 {"TI0_MEDSYP", "TI0_MEDIDA" },;
						 {"TI0_OBSSYP", "TI0_OBSERV" } }

	dbSelectArea( "TI0" )
	If Altera .Or. nOpcTI0 == 5
		cSeqRes := TI0->TI0_SEQRES
		dbGoTo( nRecTI0 )
		RecLock( "TI0", .F. )
	ElseIf Inclui .Or. lCopia
		ConfirmSX8()
		RecLock( "TI0", .T. )
	EndIf

	dbSelectArea( "TI0" )
	If nOpcTI0 == 5
		dbDelete()
	Else
		For ny := 1 To FCount()
	     	nx := "M->" + FieldName( ny )
	     	If "_FILIAL" $ Upper( nx )
	       		&nx. := xFilial( "TI0" )
	     	EndIf
	     	FieldPut( ny, &nx. )
		Next ny
	EndIf
	EvalTrigger()  // Processa Gatilhos
	TI0->(MsUnlock())

	//-------------------------------------
	// Ajusta relacionamento da TI0
	//-------------------------------------
	If	nOpcTI0 == 5
		MDTDelResp( cSeqRes )
	EndIf

 	For ny := 1 To Len( aMemos )
		If nOpcTI0 == 3
			MSMM( , TamSX3( aMemos[ny][2] )[1], , &( "M->" + aMemos[ny][2] ), 1, , , "TI0", aMemos[ny][1] )
		ElseIf nOpcTI0 == 4
			MSMM( &( aMemos[ny][1] ), TamSX3( aMemos[ny][2] )[1], , &( "M->" + aMemos[ny][2] ), 1, , , "TI0", aMemos[ny][1] )
		ElseIf nOpcTI0 == 5
			MSMM( &( aMemos[nY][1] ), , , , 2 )
		EndIf
	Next ny

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fGravaReav
Gravacao da tabela da geração de nova Permissoes, após a reavaliação.

@author Guilherme Benkendorf
@since 01/12/2014
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fGravaReav()

	Local nX
	Local nY
	Local cSeqRes
	Local aGravaReav := {}
	Local cPermissao := M->TI0_PERMIS
	Local aRelacio   := { "TI1", "TI2", "TI3", "TI4", "TI5", "TI6" }


	aAdd( aGravaReav, { "TI0_DATIMP", "STOD('')" } )
	aAdd( aGravaReav, { "TI0_DTPINI", "STOD('')" } )
	aAdd( aGravaReav, { "TI0_HRPINI", "''" } )
	aAdd( aGravaReav, { "TI0_DTPFIM", "STOD('')" } )
	aAdd( aGravaReav, { "TI0_HRPFIM", "''" } )
	aAdd( aGravaReav, { "TI0_DTRINI", "STOD('')" } )
	aAdd( aGravaReav, { "TI0_HRRINI", "''" } )
	aAdd( aGravaReav, { "TI0_DTRFIM", "STOD('')" } )
	aAdd( aGravaReav, { "TI0_HRRFIM", "''" } )
	aAdd( aGravaReav, { "TI0_DTCONC", "STOD('')" } )
	aAdd( aGravaReav, { "TI0_HRCONC", "''" } )
	aAdd( aGravaReav, { "TI0_DINIRV", "STOD('')" } )
	aAdd( aGravaReav, { "TI0_HINIRV", "''" } )
	aAdd( aGravaReav, { "TI0_DFIMRV", "STOD('')" } )
	aAdd( aGravaReav, { "TI0_HFIMRV", "''" } )
	aAdd( aGravaReav, { "TI0_STATUS", "'4'" } )
	aAdd( aGravaReav, { "TI0_SEQRES", "''" } )

	Begin Transaction

		dbSelectArea( "TI0" )
		RecLock( "TI0", .T. )
			For ny := 1 To FCount()
				nx :=  "M->" + FieldName( ny )
				If "_FILIAL" $ Upper( nx )
					FieldPut( ny, xFilial( "TI0" ) )
				Else
					nPos := aScan( aGravaReav, { | x | x[1] $ Upper( nx ) } )
					If nPos > 0
						FieldPut( ny, &( aGravaReav[nPos][2] ) )
					Else
						FieldPut( ny, &nx. )
					EndIf
				EndIf
			Next ny
		MsUnlock()

		ConfirmSX8()

		For ny := 1 To Len( aRelacio )
			fGravaRelac( aRelacio[ ny ], 1, cPermissao, TI0->TI0_SEQPER )
		Next ny

	End Transaction

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fGravaRelac
Gravacao da tabela da geração de nova Permissoes, após a revição

@author Guilherme Benkendorf
@since 01/12/2014
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fGravaRelac( cAliRelac, nIndRelac, cPermiss, cSeqPerm )

	Local nY
	Local nX
	Local cSeqAnt
	Local aGravaRel := {}
	Local aRegistro := {}

	cSeqAnt := STRZero( Val( cSeqPerm ) - 1, Len( cSeqPerm ) )

	dbSelectArea( cAliRelac )
	dbSetOrder( nIndRelac )
	dbSeek( xFilial( cAliRelac ) + cPermiss + cSeqAnt )

	While ( cAliRelac )->( !Eof() ) .And. xFilial( cAliRelac ) == &( cAliRelac + "->" + ( cAliRelac ) + "_FILIAL" ) .And. ;
													&( cAliRelac + "->" + ( cAliRelac ) + "_PERMISS" ) == cPermiss .And.;
													&( cAliRelac + "->" + ( cAliRelac ) + "_SEQPER" ) == cSeqAnt

		For ny := 1 To FCount()
			nx :=  cAliRelac + "->" + FieldName( ny )
			If "_FILIAL" $ Upper( nx )
				aAdd( aRegistro, xFilial( cAliRelac ) )
			ElseIf "_SEQPER" $ Upper( nx )
				aAdd( aRegistro, cSeqPerm )
			Else
				aAdd( aRegistro, &nx. )
			EndIf
		Next ny

		aAdd( aGravaRel, aRegistro )
		aRegistro := {}

		dbSelectArea( cAliRelac )
		dbSkip()
	End

	For ny := 1 To Len( aGravaRel )
		RecLock( cAliRelac, .T. )
			For nX := 1 To Len( aGravaRel[ny] )
				FieldPut( nx, aGravaRel[ny][nX] )
			Next nX
		MsUnLock()
	Next ny

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fGravaTI5
Gravacao da tabela TI5 CheckList

@author Guilherme Benkendorf
@since 30/09/2014
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fGravaTI5( nOpcTI5, cAliGrp, cAliPerg )

	Local lRet := .T.

	//---------------------------------------------
	// Analisa Base (TI5) excluindo
	// valores que não possuem na TRB de perguntas
	//----------------------------------------------
	dbSelectArea( "TI5" )
	dbSetOrder( 1 ) //TI5_FILIAL+TI5_PERMIS+TI5_SEQPER+TI5_QUESTI+TI5_CODGRU+TI5_QUESTA
	dbSeek( xFilial( "TI5" ) + M->TI0_PERMIS + M->TI0_SEQPER + M->TI5_QUESTI )
	While TI5->( !Eof() ) .And. TI5->TI5_FILIAL == xFilial( "TI5" ) .And. TI5->TI5_PERMIS == M->TI0_PERMIS .And.;
								TI5->TI5_SEQPER == M->TI0_SEQPER .And. TI5->TI5_QUESTI == M->TI5_QUESTI
		dbSelectArea( cAliPerg )
		dbSetOrder( 1 ) //TRB_CODGRU+TRB_QUESTA
		If !dbSeek( TI5->TI5_CODGRU + TI5->TI5_QUESTA )
			RecLock( "TI5", .F. )
				dbDelete()
			MsUnLock()
		EndIf
		TI5->( dbSkip() )
	End

	//-------------------------
	// Realiza gravação da TI5
	//-------------------------
	dbSelectArea( cAliGrp )
	dbSetOrder( 1 )
	dbGoTop()
	While ( cAliGrp )->( !Eof() )
		dbSelectArea( cAliPerg )
		dbSetOrder( 1 )
		If dbSeek( ( cAliGrp )->TRB_CODGRU )
			While ( cAliPerg )->( !Eof() ) .And. ( cAliGrp )->TRB_CODGRU == ( cAliPerg )->TRB_CODGRU
				dbSelectArea( "TI5" )
				dbSetOrder( 1 ) //TI5_FILIAL+TI5_PERMIS+TI5_SEQPER+TI5_QUESTI+TI5_CODGRU+TI5_QUESTA
				lRet := dbSeek( xFilial( "TI5" ) + M->TI0_PERMIS + M->TI0_SEQPER + M->TI5_QUESTI + ( cAliGrp )->TRB_CODGRU + ( cAliPerg )->TRB_QUESTA )

				If !Empty( ( cAliPerg )->TRB_DELETE ) .Or. nOpcTI5 == 5
					If lRet
						RecLock( "TI5", !lRet )
							dbDelete()
						MsUnLock()
					EndIf
				Else
					RecLock( "TI5", !lRet )
						TI5->TI5_FILIAL := xFilial( "TI5" )
						TI5->TI5_PERMIS := M->TI0_PERMIS
						TI5->TI5_SEQPER := M->TI0_SEQPER
						TI5->TI5_QUESTI := M->TI5_QUESTI
						TI5->TI5_CODGRU := ( cAliGrp )->TRB_CODGRU
						TI5->TI5_QUESTA := ( cAliPerg )->TRB_QUESTA
						TI5->TI5_OPERAD := ( cAliPerg )->TRB_OPERAD
						TI5->TI5_RESULT := fTratPict( ( cAliPerg )->TRB_RESULT )
						TI5->TI5_RESPOS := ( cAliPerg )->TRB_RESPOS
					MsUnLock()
				EndIf
				( cAliPerg )->( dbSkip() )
			End
		EndIf
		( cAliGrp )->( dbSkip() )
	End

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA992GRA
Gravacao de tabelas relacionais da Permissão de Trabalho.

@author Marcos Wagner Jr.
@since 15/02/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fGravaFol( nOpcx )

	Local nFolder
	Local nGrav
	Local j
	Local nY
	Local nX
	Local aHeadGrav := {}
	Local cMarcTI3  := ""
	Local cMarcTI4  := ""

	Local nTI1TipFun := GDFieldPos( "TI1_TIPFUN", oGet9921:aHeader )
	Local nTI1CodFun := GDFieldPos( "TI1_CODFUN", oGet9921:aHeader )
	Local nTI1NomFun := GDFieldPos( "TI1_NOMFUN", oGet9921:aHeader )
	Local nTI2NumRis := GDFieldPos( "TI2_NUMRIS", oGet9922:aHeader )
	Local nTI3CodEPI := GDFieldPos( "TI3_CODEPI", oGet9923:aHeader )
	Local nTI4Equipa := GDFieldPos( "TI4_EQUIPA", oGet9924:aHeader )
	Local nTI6CodCon := GDFieldPos( "TI6_CODCON", oGet9926:aHeader )

	Private aColsGrav := {}

	Altera := IIf( lCopia, .F., Altera )

	For nFolder := 1 To _nFolders //Folder
		If nFolder == _nChec // Não analisa folder de CheckList por ter o processo diferenciado
			Loop
		EndIf

		// Caso as opções de há riscos e há equipamento estiverem diferente de "Sim", limpa aCols
		If ( nFolder == _nRisc .And. M->TI0_RISCOS != "1" ) .Or.;
			( nFolder == _nEPIs .And. M->TI0_EPINEC != "1" ) .Or.;
			( nFolder == _nEqui .And. M->TI0_EQUIPA != "1" )

			&( "oGet992" + cValToChar( nFolder ) ):aCols := BLANKGETD( &( "oGet992" + cValToChar( nFolder ) ):aHeader )
		EndIf

		aColsGrav := aClone( &( "oGet992" + cValToChar( nFolder ) ):aCols )
		aHeadGrav := aClone( &( "oGet992" + cValToChar( nFolder ) ):aHeader )

			nPosRel := aScan( aRelacio, { | x | nFolder == x[1] } )

			cTab := aRelacio[nPosRel][_nPosTab]
			nOrd := aRelacio[nPosRel][_nPosOrd]

		aSort( aColsGrav, , , { |x, y| y[Len( aColsGrav[1] )] < x[Len( aColsGrav[1] )] } )
		For nGrav := 1 To Len( aColsGrav ) //Linhas

			//TI4_FILIAL+TI4_PERMIS+TI4_EQUIPA
			cSeek:= xFilial( cTab ) + M->TI0_PERMIS
			If cTab != "TI4"
				//TI0_FILIAL+TI0_PERMIS+TI0_SEQPER
				//TI1_FILIAL+TI1_PERMIS+TI1_SEQPER+TI1_TIPFUN+TI1_CODFUN+TI1_NOMFUN
				//TI2_FILIAL+TI2_PERMIS+TI2_SEQPER+TI2_NUMRIS
				//TI3_FILIAL+TI3_PERMIS+TI3_SEQPER+TI3_CODEPI
				//TI5_FILIAL+TI5_PERMIS+TI5_SEQPER+TI5_QUESTI+TI5_CODGRU+TI5_QUESTA
				//TI6_FILIAL+TI6_PERMIS+TI6_SEQPER+TI6_CODCON
				cSeek+= M->TI0_SEQPER
			EndIf

			For nY := 1 To Len( aRelacio[nPosRel][_nPosCps] )
				nPosSeek := GDFieldPos( aRelacio[nPosRel][_nPosCps][nY], aHeadGrav )
				cSeek += aColsGrav[nGrav][nPosSeek]
			Next nY

			If !Empty( aColsGrav[nGrav][1] ) .And. !aTail( aColsGrav[nGrav] )

				dbSelectArea( cTab )
				dbSetOrder( nOrd )
				RecLock( cTab, !dbSeek( cSeek ) )
					If nOpcx == 5
						DbDelete()
					Else
						For j := 1 To FCount()//Percorre todos os campos da tabela gravando as informacoes, caso necessaria inclusao específica, feita condicao via If/ElseIf
							If "_FILIAL" $ Upper( FieldName( j ) )
								FieldPut( j, xFilial( cTab ) )
							ElseIf "_PERMIS" $ Upper( FieldName( j ) )
								FieldPut( j, M->TI0_PERMIS )
							ElseIf "_SEQPER" $ Upper( FieldName( j ) )
								FieldPut( j, M->TI0_SEQPER )
							ElseIf ( nPos := aScan( aHeadGrav, { | x | AllTrim( Upper( x[ 2 ] ) ) == AllTrim( Upper( FieldName( j ) ) ) } ) ) > 0//Caso posicao do campo esteja no aHeader
								FieldPut( j, aColsGrav[ nGrav, nPos ] )
							EndIf
						Next j
					EndIf
				&(cTab)->(MsUnLock())
			Else
				dbSelectArea( cTab )
				dbSetOrder( nOrd )
				If dbSeek( xFilial( cTab ) + cSeek )
					RecLock( cTab, .F. )
						dbDelete()
					&(cTab)->(MsUnLock())
				EndIf
			EndIf
		Next nGrav

		//Verifica toda a tabela, para que delete os registros caso este nao estejam no aCols ou seja 'exclusao'
		dbSelectArea( cTab )
		dbSetOrder( nOrd )
		If dbSeek( xFilial( cTab ) +  M->TI0_PERMIS + M->TI0_SEQPER )
			While !Eof() .And. &(cTab+'->'+cTab+'_FILIAL') == xFilial( cTab ) .And. &( cTab + '->' + cTab + '_PERMIS' ) == M->TI0_PERMIS;
																			  .And. &(cTab+'->'+cTab+'_SEQPER') == M->TI0_SEQPER

				If nFolder == _nFunc
					nPos := aScan( aColsGrav, { |x| x[nTI1CodFun] == TI1->TI1_CODFUN .And.;
								 AllTrim( x[nTI1NomFun] ) == AllTrim( TI1->TI1_NOMFUN ) .And. !aTail( x ) } )
				ElseIf nFolder == _nRisc
					nPos := aScan( aColsGrav, { |x| x[nTI2NumRis] == TI2->TI2_NUMRIS .And. !aTail( x ) } )
				ElseIf nFolder == _nEpis
					nPos := aScan( aColsGrav, { |x| x[nTI3CodEPI] == TI3->TI3_CODEPI .And. !aTail( x ) } )
				ElseIf nFolder == _nEqui
					nPos := aScan( aColsGrav, { |x| x[nTI4Equipa] == TI4->TI4_EQUIPA .And. !aTail( x ) } )
				ElseIf nFolder == _nCont
					nPos := aScan( aColsGrav, { |x| x[nTI6CodCon] == TI6->TI6_CODCON .And. !aTail( x ) } )
				EndIf
				If nPos == 0
					RecLock( cTab, .F. )
						dbDelete()
					&(cTab)->(MsUnLock())
				EndIf
				dbSkip()
			End
		EndIf

	Next nFolder

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA992WHN
X3_WHEN dos campos TI1_CODFUN e TI1_NOMFUN

@author Marcos Wagner Jr.
@since 15/02/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDTA992WHN( cCampoGet )

	Local lRet		 := .F.
	Local nTI1TipFun := GDFieldPos( "TI1_TIPFUN", oGet9921:aHeader )

	If cCampoGet == 'TI1_CODFUN'
		lRet := aCols[n][nTI1TipFun] == '1'
	ElseIf cCampoGet == 'TI1_NOMFUN'
		lRet := aCols[n][nTI1TipFun] == '2'
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTTI5REL
Função de Relação para dos campos da TI5

@author Guilherme Benkendorf
@since 07/10/14
@version MP11
@obs Utilização: TI5_DESCRI / TI5_PERGUN
@return Nil
/*/
//---------------------------------------------------------------------
Function MDTTI5REL( nCpoTI5 )

	Local cRet := ""

	If !IsInCallStack( "MDTA992CAD" ) .And. !INCLUI
		If nCpoTI5 == 1 //TI5_DESCRI
			cRet := Posicione( "TJ4", 1, xFilial( "TJ4" ) + TI5->TI5_CODGRU, "TJ4_DESCRI" )
		ElseIf nCpoTI5 == 2 //TI5_PERGUN
			cRet := Posicione( "TJ3", 1, xFilial( "TJ3" ) + TI5->TI5_QUESTI + TI5->TI5_QUESTA, "TJ3_PERGUN" )
		EndIf
	EndIf

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT992RELA
X3_RELACAO dos campos DA TI1 ate a TI6

@author Marcos Wagner Jr.
@since 15/02/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT992RELA( cTabRel, nCampo )

	Local _cTab
	Local _cNome
	Local _cCodigo
	Local cTCampo
	Local cRetCampo := ""

	Local aOldArea := GetArea()

	If cTabRel == "TI0"
		Do Case
			Case nCampo == 1 //TI0_NOMVIG
				cTCampo := TI0->TI0_TIPVIG
				_cCodigo := TI0->TI0_CODVIG
			Case nCampo == 2 //TI0_NOMRES
				cTCampo := TI0->TI0_TIPRES
				_cCodigo := TI0->TI0_CODRES
			Case nCampo == 3 //TI0_NOMSUP
				cTCampo := TI0->TI0_TIPSUP
				_cCodigo := TI0->TI0_CODSUP
			Case nCampo == 4 //TI0_NOMSUE
				cTCampo := TI0->TI0_TIPSUE
				_cCodigo := TI0->TI0_CODSUE
		End Case
		If !Empty( cTCampo )
			_cTab  := RetPropri( cTCampo )[1]
			_cNome := RetPropri( cTCampo )[2]
		EndIf

		cRetCampo := IIf( !Empty( _cTab ), NGSEEK( _cTab, _cCodigo, 1, _cNome ), "" )

	ElseIf cTabRel == "TI2"
		dbSelectArea( "TN0" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "TN0", TI2->TI2_FILIAL ) + TI2->TI2_NUMRIS )
			Do Case
				Case nCampo == 1 //TI2_NOMAGE
					cRetCampo := NGSeek( "TMA", TN0->TN0_AGENTE, 1, "TMA_NOMAGE" )
				Case nCampo == 2 //TI2_DTRECO
					cRetCampo := TN0->TN0_DTRECO
				Case nCampo == 3 //TI2_DTAVAL
					cRetCampo := TN0->TN0_DTAVAL
				Case nCampo == 4 //TI2_QTAGEN
					cRetCampo := TN0->TN0_QTAGEN
				Case nCampo == 5 //TI2_UNIMED
					cRetCampo := TN0->TN0_UNIMED
			End Case
		EndIf
	EndIf

	RestArea( aOldArea )

Return cRetCampo

//---------------------------------------------------------------------
/*/{Protheus.doc} HabFolder
Habilita ou desabilita o folder de Riscos/Equipamentos

@author Marcos Wagner Jr.
@since 15/02/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function HabFolder()

	oFolder:ADIALOGS[_nRisc]:LACTIVE := M->TI0_RISCOS == "1"
	oFolder:ADIALOGS[_nEPIs]:LACTIVE := M->TI0_EPINEC == "1"
	oFolder:ADIALOGS[_nEqui]:LACTIVE := M->TI0_EQUIPA == "1"

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT992VLD
X3_VALID dos campos DA TI0 ate a TI6

@author Marcos Wagner Jr.
@since 15/02/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT992VLD( nCampoTI )

	Local nParam   := 0
	Local lRet     := .T.
	Local lCallPET := IsInCallStack( "MDTA992" )
	Local cAliAux  := ""
	Local cCodAux  := ""
	Local aOldArea := GetArea()

	Local nTI1CodFun
	Local nTI2NumRis
	Local nTI2NomAge

	Do Case
		Case nCampoTI == 1 //TI2_NUMRIS
			If Empty( TN0->TN0_DTAVAL ) .Or. !Empty( TN0->TN0_DTELIM )
				MsgStop( STR0019, STR0020 ) // "O Risco informado deverá ser avaliado e ativo!" ## "Atenção"
				lRet := .F.
			EndIf

			If lRet .And. !( ExistCpo( 'TN0', M->TI2_NUMRIS ) )
				lRet := .F.
			EndIf

			If lRet .And. Type( "oGet9922" ) != "U"
				nTI2NomAge := GDFieldPos( "TI2_NOMAGE", oGet9922:aHeader )
				aCols[n][nTI2NomAge] := NGSEEK( "TMA", TN0->TN0_AGENTE, 1, "TMA_NOMAGE" )
			EndIf
		Case nCampoTI == 2 .Or. nCampoTI == 3 .Or. nCampoTI == 8 //TI0_RISCOS//TI0_EQUIPA//TI0_EPINEC
			lRet := Pertence( "12" )
			If lRet
				HabFolder()
			EndIf
		Case nCampoTI == 4 //TI0_CCUSTO
			If !Empty( M->TI0_CCUSTO )
				cAliAux  := "CTT"
				cCodAux  := M->TI0_CCUSTO
				nParam   := 1
			EndIf

		Case nCampoTI == 5 //TI0_FUNCAO
			If !Empty( M->TI0_FUNCAO )
				cAliAux  := "SRJ"
				cCodAux  := M->TI0_FUNCAO
				nParam   := 2
			EndIf

		Case nCampoTI == 6 //TI0_CODTAR
			If !Empty( M->TI0_CODTAR )
				cAliAux  := "TN5"
				cCodAux  := M->TI0_CODTAR
				nParam   := 3
			EndIf

		Case nCampoTI == 7 //TI0_LOCTRA
			If !Empty( M->TI0_LOCTRA )
				cAliAux := "TNE"
				cCodAux := M->TI0_LOCTRA
				nParam  := 4
			EndIf
	End Case

	//Caso o alias auxiliar esteja preenchedo verifica a existencia do código em tal tabela.
	If !Empty( cAliAux )
		If lRet
			lRet := ExistCpo( cAliAux, cCodAux )
		EndIf
		//Se a chamada foi realizada no MDTA992 verifica integridade de
		// Centro de Custo, Função, Tarefa e Ambiente de Trabalho.
		If lCallPET
			If lRet .And. !Empty( M->TI5_QUESTI )
				lRet := fValCpoTJ2( cCodAux, nParam )
			EndIf
			//Analisa aCols de Riscos, pois deve estar com os mesmos
			// Centro de Custo, Função, Tarefa e Ambiente de Trabalho.
			If lRet .And. Len( oGet9922:aCols ) > 0
				nTI2NumRis := GDFieldPos( "TI2_NUMRIS", oGet9922:aHeader )
				aEval( oGet9922:aCols, { |x| IIf( lRet .And. !Empty( x[ nTI2NumRis ] ) .And. !aTail( x ), lRet := fChkIntRis( x[nTI2NumRis] ), ) } )
			EndIf
		EndIf
	EndIf

	RestArea( aOldArea )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetFrame
Função auxiliar para estruturar a Montagem do aHeader e aCols

@author Guilherme Benkendorf
@since 19/09/2014
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fGetFrame( nOpcx )

	Local aCposNot := {}
	Local aCposYes := {}

	//--------------------------
	//	 Monta estrutura de TI1
	//--------------------------
	aCposNot := { "TI1_PERMIS", "TI1_SEQPER" }
	HeaderCols( "TI1", 1, nOpcx, aCposNot, , @aHead1, @aCols1 )

	//--------------------------
	//	 Monta estrutura de TI2
	//--------------------------
	aCposNot := { "TI2_PERMIS", "TI2_SEQPER" }
	HeaderCols( "TI2", 1, nOpcx, aCposNot, , @aHead2, @aCols2 )

	//--------------------------
	//	 Monta estrutura de TI3
	//--------------------------
	aCposNot := { "TI3_PERMIS", "TI3_SEQPER" }
	HeaderCols( "TI3", 1, nOpcx, aCposNot, , @aHead3, @aCols3 )

	//--------------------------
	//	 Monta estrutura de TI4
	//--------------------------
	aCposNot := { "TI4_PERMIS", "TI4_SEQPER" }
	HeaderCols( "TI4", 1, nOpcx, aCposNot, , @aHead4, @aCols4 )

	//--------------------------
	//	 Monta estrutura de TI5
	//--------------------------
	aCposYes := { "TI5_CODGRU", "TI5_DESCRI" }
	HeaderCols( "TI5", 1, nOpcx, , aCposYes, @aHeadGrp, @aColsGrp, .F. )

	//--------------------------
	//	 Monta estrutura de TI5
	//--------------------------
	aCposYes := { "TI5_QUESTA", "TI5_PERGUN", "TI5_RESULT", "TI5_OPERAD", "TI5_RESPOS" }
	HeaderCols( "TI5", 1, nOpcx, , aCposYes, @aHeadPerg, @aColsPerg, .F. )

	//--------------------------
	//	 Monta estrutura de TI6
	//--------------------------
	aCposNot := { "TI6_PERMIS", "TI6_SEQPER" }
	HeaderCols( "TI6", 1, nOpcx, aCposNot, , @aHead6, @aCols6 )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} HeaderCols
Monta o aHeader e o aCols

@author Marcos Wagner Jr.
@since 15/02/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function HeaderCols( _cTab, _nOrder, _nOpcx, _aNoFields, _aYesFields, aHeaderAux, aColsAux, lSearch )

	Local nI
	Local cKeyGet
	Local cWhileGet
	Local bMontaCols

	Local aOldArea := GetArea()

	Default _aNoFields	:= Nil
	Default _aYesFields	:= Nil
	Default aHeaderAux	:= {}
	Default aColsAux	:= {}
	Default lSearch		:= .T.

	cKeyGet		:= "TI0->TI0_PERMIS+TI0->TI0_SEQPER"
	cWhileGet	:= "xFilial('"+_cTab+"') == "+_cTab+"->"+_cTab+"_FILIAL .AND. TI0->TI0_PERMIS == "+_cTab+"->"+_cTab+"_PERMIS"
	cWhileGet   +=" .AND. TI0->TI0_SEQPER == "+_cTab+"->"+_cTab+"_SEQPER"
	bMontaCols  := { || NGMontaAcols( _cTab, &cKeyGet, cWhileGet ) }

	If !lSearch
		cKeyGet		:= ""
		bMontaCols	:= { || }
	EndIf

	dbSelectArea( _cTab )
	dbSetOrder( _nOrder )
	FillGetDados( _nOpcx, _cTab, _nOrder, cKeyGet, {||  }, {|| .T.},;
				 _aNoFields, _aYesFields, , , bMontaCols, , @aHeaderAux, @aColsAux )

	If Empty( aColsAux ) .Or. _nOpcx == 3
		PutFileInEof( _cTab )
	   aColsAux := BLANKGETD( aHeaderAux )
	EndIf

	RestArea( aOldArea )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetFolder
Função auxiliar para estruturação dos folders da rotina MDTA992.

@param
@author Guilherme Benkendorf
@since 22/09/2014
@version MP11
@return Boolean .T.
/*/
//---------------------------------------------------------------------
Static Function fGetFolder( aPages, aTitles )

	aAdd( aTitles, OemToAnsi( STR0011 ) ) // "Funcionários"
	aAdd( aTitles, OemToAnsi( STR0012 ) ) // "Riscos"
	aAdd( aTitles, OemToAnsi( STR0013 ) ) // "EPI's"
	aAdd( aTitles, OemToAnsi( STR0014 ) ) // "Equipamentos"
	aAdd( aTitles, OemToAnsi( STR0015 ) ) // "Check-List"
	aAdd( aTitles, OemToAnsi( STR0016 ) ) // "Contatos"
	aAdd( aPages, "Header 1" )
	aAdd( aPages, "Header 2" )
	aAdd( aPages, "Header 3" )
	aAdd( aPages, "Header 4" )
	aAdd( aPages, "Header 5" )
	aAdd( aPages, "Header 6" )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetQuesti

Monta TRB auxiliares e carrega aCols para o folder da CheckList

@param
@author Guilherme Benkendorf
@since 25/09/2014
@version MP11
@return Boolean .T.
/*/
//---------------------------------------------------------------------
Static Function fGetQuesti( cKeyPerm, cAliTRB, cArqTRB, cAliTRB2, cArqTRB2, nOpc )

	Local cCodGru
	Local nPosCodGru
	Local nPosDescri
	Local oTempTRB
	Local oTempTRB2
	Local nPosNat   := 0
	Local aDBF	    := {}
	Local aDBF2	    := {}
	Local aColsAuxG := BLANKGETD( aHeadGrp )

	aAdd( aDBF, { "TRB_QUESTI", "C", TAMSX3( "TI5_QUESTI" )[1], 0 } )
	aAdd( aDBF, { "TRB_CODGRU", "C", TAMSX3( "TI5_CODGRU" )[1], 0 } )
	aAdd( aDBF, { "TRB_DESCRI", "C", TAMSX3( "TI5_DESCRI" )[1], 0 } )
	aAdd( aDBF, { "TRB_ORDGRU", "C", TAMSX3( "TJ3_ORDGRP" )[1], 0 } )
	aAdd( aDBF, { "TRB_DELETE", "C", 1, 0 } )

	aAdd( aDBF2, { "TRB_NAT", "C", 3, 0 } )
	aAdd( aDBF2, { "TRB_CODGRU", "C", TAMSX3( "TI5_CODGRU" )[1], 0 } )
	aAdd( aDBF2, { "TRB_QUESTA", "C", TAMSX3( "TI5_QUESTA" )[1], 0 } )
	aAdd( aDBF2, { "TRB_PERGUN", "C", TAMSX3( "TI5_PERGUN" )[1], 0 } )
	aAdd( aDBF2, { "TRB_OPERAD", "C", TAMSX3( "TI5_OPERAD" )[1], 0 } )
	aAdd( aDBF2, { "TRB_RESULT", "C", TAMSX3( "TI5_RESULT" )[1], 0 } )
	aAdd( aDBF2, { "TRB_RESPOS", "C", TAMSX3( "TI5_RESPOS" )[1], 0 } )
	aAdd( aDBF2, { "TRB_DELETE", "C", 1, 0 } )

	oTempTRB := FWTemporaryTable():New( cAliTRB, aDBF )
	oTempTRB:AddIndex( "1", {"TRB_CODGRU"} )
	oTempTRB:AddIndex( "2", {"TRB_ORDGRU"} )
	oTempTRB:Create()

	oTempTRB2 := FWTemporaryTable():New( cAliTRB2, aDBF2 )
	oTempTRB2:AddIndex( "1", { "TRB_CODGRU", "TRB_QUESTA" } )
	oTempTRB2:AddIndex( "2", { "TRB_CODGRU", "TRB_NAT" } )
	oTempTRB2:Create()

	If nOpc != 3 .And. Select( cAliTRB ) > 0

		aColsGrp := {}
		nPosCodGru := GDFieldPos( "TI5_CODGRU", aHeadGrp )
		nPosDescri := GDFieldPos( "TI5_DESCRI", aHeadGrp )

		aColsPerg:= {}

		dbSelectArea( "TI5" )
		dbSetOrder( 1 ) //TI5_FILIAL+TI5_PERMIS+TI5_SEQPER+TI5_QUESTI+TI5_CODGRU+TI5_QUESTA
		dbSeek( xFilial( "TI5" ) + cKeyPerm + M->TI5_QUESTI )
		While TI5->( !Eof() ) .And. TI5->TI5_FILIAL == xFilial( "TI5" ) .And. cKeyPerm == TI5->TI5_PERMIS+TI5->TI5_SEQPER;
																											.And. M->TI5_QUESTI == TI5->TI5_QUESTI
			RecLock( cAliTRB, .T. )

				( cAliTRB )->TRB_QUESTI := TI5->TI5_QUESTI
				( cAliTRB )->TRB_CODGRU := TI5->TI5_CODGRU
				( cAliTRB )->TRB_DESCRI := NGSeek( "TJ4", TI5->TI5_CODGRU, 1, "TJ4_DESCRI" )
				( cAliTRB )->TRB_ORDGRU := NGSeek( "TJ3", TI5->TI5_QUESTI+TI5->TI5_QUESTA, 1, "TJ3_ORDGRP" )
				( cAliTRB )->TRB_DELETE := Space( 1 )

			( cAliTRB )->( MsUnLock() )

			If TI5->TI5_CODGRU <> cCodGru
				nPosNat := 0
				cCodGru := TI5->TI5_CODGRU
			EndIf

			RecLock( cAliTRB2, .T. )

				( cAliTRB2 )->TRB_NAT := cValToChar( ++nPosNat )
				( cAliTRB2 )->TRB_CODGRU := TI5->TI5_CODGRU
				( cAliTRB2 )->TRB_QUESTA := TI5->TI5_QUESTA
				( cAliTRB2 )->TRB_PERGUN := NGSeek( "TJ3", M->TI5_QUESTI + TI5->TI5_QUESTA, 1, "TJ3_PERGUN" )
				( cAliTRB2 )->TRB_OPERAD := TI5->TI5_OPERAD
				( cAliTRB2 )->TRB_RESULT := fTratPict( TI5->TI5_RESULT )
				( cAliTRB2 )->TRB_RESPOS := TI5->TI5_RESPOS
				( cAliTRB2 )->TRB_DELETE := Space( 1 )

			( cAliTRB2 )->( MsUnLock() )

			TI5->( dbSkip() )
		End

		dbSelectArea( cAliTRB )
		dbSetOrder( 2 )//Ordena pela ordem do Grupo
		dbGoTop()
		While (cAliTRB)->( !Eof() )
			If aScan( aColsGrp, { | x | x[nPosCodGru] == ( cAliTRB )->TRB_CODGRU } ) == 0
				aAdd( aColsGrp, aClone( aColsAuxG[1] ) )
				aColsGrp[Len( aColsGrp )][nPosCodGru] := ( cAliTRB )->TRB_CODGRU
				aColsGrp[Len( aColsGrp )][nPosDescri] := ( cAliTRB )->TRB_DESCRI
				nPosNat := 0
			EndIf
			(cAliTRB)->( dbSkip() )
		End

		If Len( aColsGrp ) > 0
			aColsPerg := aClone( fAddPerg( cAliTRB2, aColsGrp[1][nPosCodGru] ) )
		EndIf
  	EndIf

	If ( cAliTRB )->( RecCount() ) == 0
		aColsGrp := aClone( aColsAuxG )
		aColsPerg:= BLANKGETD( aHeadPerg )
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA992LIB
Liberacao da PT / PET, através dos dados da TI0, trabalha com as funções
MDTB001C e MDTB001CM para responder o questionário escolhido na TI5

@author Guilherme Benkendorf
@since 01/12/2014
@version MP11
@return lRet Boolean
/*/
//---------------------------------------------------------------------
Function MDTA992LIB( cAlias, nRecno, nOpcx )

	Local lRet := .T.
	//Variavel utilizada em MDTA996
	Private cQuestSel

	If TI0->TI0_STATUS == "1" .Or. TI0->TI0_STATUS == "2" .Or. TI0->TI0_STATUS == "5" // "1=Liberada;//"2=Não Liberada;"//"5=Reavaliada"

		ShowHelpDlg( "PTRESP", { STR0036 + NGRETSX3BOX( "TI0_STATUS", TI0->TI0_STATUS ) + "'." },; //"Permissão de trabalho está com o Status igual a '"
					 2, { STR0073 }, 2 )                                                           //"Será permitido apenas a operação de visualização do questionário."
		dbSelectArea( "TJ1" )
		dbSetOrder( 5 )	//TJ1_FILIAL+TJ1_SEQRES
		dbSeek( xFilial( "TJ1" ) + TI0->TI0_SEQRES )
		RegToMemory( "TJ1", .F. )

		MDTB001C( "TJ1", TJ1->( Recno() ), 2 )
	Else
		//------------------------------------------------------
		// Verifica qual o questionário deverá ser respondido
		//------------------------------------------------------
		dbSelectArea( "TI5" )
		dbSetOrder( 1 ) //"TI5_FILIAL+TI5_PERMIS+TI5_SEQPER+TI5_QUESTI+TI5_CODGRU+TI5_QUESTA"
		If lRet .And. dbSeek( xFilial( "TI5" ) + TI0->TI0_PERMIS + TI0->TI0_SEQPER )

			If TI0->TI0_STATUS == "3" //3=Respondida Parcialmente;

				dbSelectArea( "TJ1" )
				dbSetOrder( 5 )	//TJ1_FILIAL+TJ1_SEQRES
				dbSeek( xFilial( "TJ1" ) + TI0->TI0_SEQRES )
				RegToMemory( "TJ1", .F. )

				MDTB001C( "TJ1", TJ1->( Recno() ), 4 )

			ElseIf TI0->TI0_STATUS == "4" //4=Não Respondida";
				//-----------------------------------------------------
				// A função MDTB001CM trabalha com os valores em
				// memória para o preenchimento da tela de responsavel
				// da resposta (TJ1). Entao será preenchido os valores
				// correspondente ao da TI0 - PT/PET
				//------------------------------------------------------

				// Questionário preenchido com os valores da PT/PET - MDTA992
				M->TJ1_QUESTI	:= PADR( TI5->TI5_QUESTI, TAMSX3( "TJ1_QUESTI" )[1] )
				cQuestSel       := M->TJ1_QUESTI
				//1=Funcionários;2=Sesmt;3=Outros
				M->TJ1_TPFUN	:= TI0->TI0_TIPVIG
				M->TJ1_MAT		:= PADR( TI0->TI0_CODVIG, TAMSX3( "TJ1_MAT" )[1] )
				M->TJ1_DTINC	:= dDataBase
				//1=Funcionários;2=Sesmt;3=Outros
				M->TJ1_TPRES	:= TI0->TI0_TIPRES
				M->TJ1_RESPEN	:= PADR( TI0->TI0_CODRES, TAMSX3( "TJ1_RESPEN" )[1] )
				M->TJ1_TITULO	:= Space( TAMSX3( "TJ1_TITULO" )[1] )
				M->TJ1_COMTVM	:= Space( TAMSX3( "TJ1_COMTVM" )[1] )
				M->TJ1_COMTCM	:= Space( TAMSX3( "TJ1_COMTCM" )[1] )

				M->TJ1_FUNC	   := TI0->TI0_FUNCAO
				M->TJ1_TAR		:= TI0->TI0_CODTAR
				M->TJ1_CC		:= TI0->TI0_CCUSTO
				M->TJ1_AMB		:= TI0->TI0_LOCTRA
				M->TJ1_LOC		:= Space( TamSX3( "TJ1_LOC" )[1] )
				//--------------------------------------
				// TJ1_SEQRES corresponde ao código das
				// respostas realizadas através da TI0
				//--------------------------------------
				M->TJ1_SEQRES := GetSXENum( "TJ5", "TJ5_SEQRES", , 2 )

				// Função para tela de cadastro da rotina.
				If MDTB001CM( , 0, 3 )
					RecLock( "TI0", .F. )
						TI0->TI0_SEQRES := M->TJ1_SEQRES
					MsUnLock()
					// Confirmação do GetSXENum
					ConfirmSX8()
				Else
					RollBackSX8()
				EndIf

			EndIf
			//---------------------------------------------------------
			// Verifica checklist com o questionário respondido.
			// E altera status da liberação da PT/PET.
			//---------------------------------------------------------
			fPTStatus()
		Else
			If MsgYesNo( STR0074, STR0024 ) //"Não há questionário a ser respondido. Deseja confirmar a liberação?"//"Atenção"
				RecLock( "TI0", .F. )
					TI0->TI0_STATUS := "1" //Liberado
				MsUnLock()
			EndIf
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA992LEG
Conclusão da PT/PET, exibe tela com as datas e horas reais, inicio e fim.

@author Guilherme Benkendorf
@since 17/12/2014
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------

Function MDTA992CON( cAlias, nRecno, nOpcx )

	Local lRet     := .T.
	//Bloco de confirmação da tela
	Local bConfirm := { || fGravaTI0( nOpcx, nRecno ), oDlgConcl:End() }

	//Variaveis de controle para a conclusão
	Local lInfoDtCon := !Empty( TI0->TI0_DTCONC )//Indica se ja foi informado a data da conclusao
	Local lLiberado  := TI0->TI0_STATUS == "1"//Indica se a PT/PET ja foi liberada
	//Variaveis de tela

	Local oDlgConcl
	Local oPnlAll
	Local aSize      := MsAdvSize( , .F., 430 )
	Local aObjects   := { { 050, 050, .T., .T. }, { 100, 100, .T., .T. } }
	Local aInfo      := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 }
	Local aPosObj    := MsObjSize( aInfo, aObjects, .T. )
	//Monta aChoice da conclusao
	Local aChoiceCon := faChoice( nOpcx, .T. )
	Local oEnc992

	If lLiberado .And. !lInfoDtCon //"Liberada"

		RegToMemory( "TI0", .F. )

		oDlgConcl := MSDialog():New( aSize[7], 000, aSize[6], aSize[5], STR0111, , , , , , , , oMainWnd, .T. ) //"Conclusão"
			oDlgConcl:lESCClose  := .F.
			oDlgConcl:lMaximized := .T.

			oPnlAll := TPanel():New( 0, 0, , oDlgConcl, , , , , , 12, 20, .F., .F. )
				oPnlAll:Align := CONTROL_ALIGN_ALLCLIENT

					oEnc992:= MsMGet():New( cAlias, nRecno, nOpcx, , , , aChoiceCon, aPosObj[1], , , , , , oPnlAll, , , .F. )
						oEnc992:oBox:Align := CONTROL_ALIGN_ALLCLIENT


		oDlgConcl:Activate( , , , .T., , , EnchoiceBar( oDlgConcl, { || M->TI0_DTCONC := dDataBase, M->TI0_HRCONC := SubStr( Time(), 1, 5 ),;
														 IIf( fValPTDt( .T. ), Eval( bConfirm ), ) },;
														 { || oDlgConcl:End() }, .F. ) )

	ElseIf !lLiberado //"Liberada"
		ShowHelpDlg( "", { STR0036 + NGRETSX3BOX( "TI0_STATUS", TI0->TI0_STATUS ) + "'." },; //"Permissão de trabalho está com o Status igual a '"
					 2, { STR0113 }, 2 ) //"Para a Conclusão da PT/PET é necessário que esteja com o Status igual a 1=Liberada."
	ElseIf lInfoDtCon
		ShowHelpDlg( "", { STR0114 }, 2,; //"PT/PET já possui data de conclusão."
					 { STR0115 }, 3 )     //"Operação de Conclusão da PT/PET não será realizada, pois já foi informada as datas de realizações."
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA992REV
Cadastro de reavaliação da PT/PET.
Regra: É preenchido as datas e horas (inicio/fim) da permissão de trabalho
selecionada no browse. Após é gravado as datas, e gerado uma nova sequencia
da PT/PET. Chamado fGravaReav() que gravará a PT/PET com a nova sequencia.

@author Guilherme Benkendorf
@since 17/12/2014
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDTA992REV( cAlias, nRecno, nOpcx )

	Local lRet := .T.
	Local cCodSeq
	//Bloco de confirmação da tela
	Local bConfirm := { || M->TI0_STATUS := "5", fGravaTI0( nOpcx, nRecno ), M->TI0_SEQPER := cCodSeq,;
									  fGravaReav(), UnLockByName( TI0->TI0_PERMIS + cCodSeq, .F. ), oDlgRev:End() }

	//Variaveis de controle para a Reavaliacao
	Local lReaval  := TI0->TI0_STATUS == "1" .Or. TI0->TI0_STATUS == "2" //Indica se a PT/PET pode ser liberada

	//Variaveis de tela
	Local oDlgRev
	Local oPnlAll
	Local aSize    := MsAdvSize( , .F., 430 )
	Local aObjects := { { 050, 050, .T., .T. }, { 100, 100, .T., .T. } }
	Local aInfo    := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 }
	Local aPosObj  := MsObjSize( aInfo, aObjects, .T. )

	//Monta aChoice da Revisão
	Local aChoiceRev := faChoice( nOpcx, .F., .T. )
	Local oEnc992

	If lReaval
		cCodSeq := GetCodSeq()
		If LockByName( TI0->TI0_PERMIS + cCodSeq, .F. )
			RegToMemory( "TI0", .F. )

			oDlgRev := MSDialog():New( aSize[7], 000, aSize[6], aSize[5], STR0122, , , , , , , , oMainWnd, .T. ) //"Reavaliação"
				oDlgRev:lESCClose  := .F.
				oDlgRev:lMaximized := .T.

				oPnlAll := TPanel():New( 0, 0, , oDlgRev, , , , , , 12, 20, .F., .F. )
					oPnlAll:Align := CONTROL_ALIGN_ALLCLIENT

						oEnc992:= MsMGet():New( cAlias, nRecno, nOpcx, , , , aChoiceRev, aPosObj[1], , , , , , oPnlAll, , , .F. )
							oEnc992:oBox:Align := CONTROL_ALIGN_ALLCLIENT


			oDlgRev:Activate( , , , .T., , , EnchoiceBar( oDlgRev, { || IIf( fValPTDt( , .T. ), Eval( bConfirm ), ) }, { || oDlgRev:End() }, .F. ) )
		Else
			ShowHelpDlg( "BLOCREAV", { STR0116 }, 3,; //"Permissão de trabalho esta bloqueada. Pois está sendo revisada por outro usuário"
						 { STR0117 }, 2 )             //"Contate adminstrador do sistema ou usuário responsável."
		EndIf
	Else
			ShowHelpDlg( "NOLIBERAD", { STR0036 + NGRETSX3BOX( "TI0_STATUS", TI0->TI0_STATUS ) + "'." },; //"Permissão de trabalho está com o Status igual a '"
						 3, { STR0118 }, 3 ) //"Para a Revisão da PT/PET é aceito somente permissões que sejam diferente de Libera\Não Liberada."
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA992LEG
Legenda da rotina MDTA992, tabela TI0 - Permissão de Trabalho

@author Marcos Wagner Jr.
@since 19/02/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDTA992LEG()

	Local aLegenda := {	 { "BR_VERDE", NGRETSX3BOX( "TI0_STATUS", "1" )    },;
	                   	 { "BR_AMARELO", NGRETSX3BOX( "TI0_STATUS", "4" )  },;
	                   	 { "BR_LARANJA", NGRETSX3BOX( "TI0_STATUS", "3" )  },;
	                   	 { "BR_VERMELHO", NGRETSX3BOX( "TI0_STATUS", "2" ) },;
	                   	 { "BR_CINZA", NGRETSX3BOX( "TI0_STATUS", "5" )    } }

	BrwLegenda( STR0035, STR0035, aLegenda ) // "Legenda" ## "Legenda"

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA992COR
Cores

@author Marcos Wagner Jr.
@since 19/02/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDTA992COR()

	Local aCORES :=		{;
	             			 { "TI0->TI0_STATUS = '1'", "BR_VERDE"	  },;
	             			 { "TI0->TI0_STATUS = '4'", "BR_AMARELO"  },;
	             			 { "TI0->TI0_STATUS = '3'", "BR_LARANJA"  },;
	             			 { "TI0->TI0_STATUS = '2'", "BR_VERMELHO" },;
	             			 { "TI0->TI0_STATUS = '5'", "BR_CINZA"    }	;
							 }

Return ( aCORES )

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA992EPI
Atualizar o folder de EPI's

@author Marcos Wagner Jr.
@since 19/02/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDTA992EPI( cNumRisco )

	Local aOldArea := GetArea()
	Local aColsAux := {}

	Local nTI3CodEPI
	Local nTI3DesEPI

	Default cNumRisco := M->TI2_NUMRIS

	If Type( "oGet9923" ) == "O"
		nTI3CodEPI := GDFieldPos( "TI3_CODEPI", oGet9923:aHeader )
		nTI3DesEPI := GDFieldPos( "TI3_DESEPI", oGet9923:aHeader )
		aColsAux := BLANKGETD( oGet9923:aHeader )

		dbSelectArea( "TNX" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "TNX" ) + cNumRisco )
			While TNX->( !Eof() ) .And. TNX->TNX_FILIAL == xFilial( "TNX" ) .And. TNX->TNX_NUMRIS == cNumRisco
				If aScan( oGet9923:aCols, { | x | x[nTI3CodEPI] == TNX->TNX_EPI .And. !x[Len( x )] } ) == 0
					If Empty( oGet9923:aCols[1][nTI3CodEPI] )
						aDel( oGet9923:aCols, 1 )
						aSize( oGet9923:aCols, Len( oGet9923:aCols ) - 1 )
					EndIf

					aAdd( oGet9923:aCols, aClone( aColsAux[1] ) )
					oGet9923:aCols[Len( oGet9923:aCols ), nTI3CodEPI] := TNX->TNX_EPI
					oGet9923:aCols[Len( oGet9923:aCols ), nTI3DesEPI] := NGSEEK( "SB1", TNX->TNX_EPI, 1, "B1_DESC" )
				EndIf
				TNX->( dbSkip() )
			End
		EndIf

		oGet9923:oBrowse:Refresh()
	EndIf

	RestArea( aOldArea )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT992DEL
Funcao chamada ao deletar a linha da GetDados do CheckList

@author Guilherme Benkendorf
@since 01/12/2014
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT992DEL( nGet )

	Local nPos
	Local aOldArea := GetArea()
	Local aColsAux := {}

	Local nTI2NumRis
	Local nTI3CodEPI
	Local nTI3DesEPI

	If Type( "oGet9922" ) == "O" .Or. Type( "oGet9922" ) == "O"
		nTI2NumRis := GDFieldPos( "TI2_NUMRIS", oGet9922:aHeader )
		nTI3CodEPI := GDFieldPos( "TI3_CODEPI", oGet9923:aHeader )
		nTI3DesEPI := GDFieldPos( "TI3_DESEPI", oGet9923:aHeader )
		aColsAux := BLANKGETD( oGet9923:aHeader )

		If nTI2NumRis > 0 .And. Empty( oGet9922:aCols[n][nTI2NumRis] )
			Return .T.
		EndIf

		If aTail( oGet9922:aCols[n] ) //Se a linha estiver deletada, acrescentara os EPIs no folder seguinte
			dbSelectArea( "TNX" )
			dbSetOrder( 1 )
			If dbSeek( xFilial( "TNX" ) + oGet9922:aCols[n][nTI2NumRis] )
				While TNX->( !Eof() ) .And. TNX->TNX_FILIAL == xFilial( "TNX" ) .And. TNX->TNX_NUMRIS == oGet9922:aCols[n][nTI2NumRis]
					If aScan( oGet9923:aCols, { | x | x[ nTI3CodEPI ] == TNX->TNX_EPI .And. !x[Len( x )] } ) == 0
						If Empty( oGet9923:aCols[1][nTI3CodEPI] )
			            aDel( oGet9923:aCols, 1 )
		   	         aSize( oGet9923:aCols, Len( oGet9923:aCols ) - 1 )
		   			EndIf
						aAdd( oGet9923:aCols, aClone( aColsAux[1] ) )
						oGet9923:aCols[Len( oGet9923:aCols )][nTI3CodEPI] := TNX->TNX_EPI
						oGet9923:aCols[Len( oGet9923:aCols )][nTI3DesEPI] := NGSEEK( "SB1", TNX->TNX_EPI, 1, "B1_DESC" )
					EndIf
					TNX->( dbSkip() )
				End
			EndIf
		Else
			If fScan( oGet9922:aCols )
				If NGIFDBSEEK( "TNX", oGet9922:aCols[n][nTI2NumRis], 1 )
					While !Eof() .And. TNX->TNX_FILIAL == xFilial( "TNX" ) .And. TNX->TNX_NUMRIS == oGet9922:aCols[n][nTI2NumRis]
						nPos := aScan( oGet9923:aCols, { | x | x[ nTI3CodEPI ] == TNX->TNX_EPI .And. !aTail( x ) } )
						If nPos > 0
							aTail( oGet9923:aCols[nPos] ) := .T.
							aDel( oGet9923:aCols, nPos )
							aSize( oGet9923:aCols, Len( oGet9923:aCols ) - 1 )
						EndIf
						dbSkip()
					End
				EndIf
			EndIf
		EndIf

		If Len( oGet9923:aCols ) == 0
			oGet9923:aCols := BlankGetD( oGet9923:aHeader )
		EndIf

		oGet9923:oBrowse:Refresh()
	EndIf

	RestArea( aOldArea )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fScan
Funcao que varre o array

@author Marcos Wagner Jr.
@since 19/02/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fScan( _aCols )

	Local nI
	Local nTI2NumRis := GDFieldPos( "TI2_NUMRIS", oGet9922:aHeader )

	For nI := 1 To Len( _aCols )
		If nI != n .And. _aCols[nI][nTI2NumRis] == _aCols[n][nTI2NumRis] .And. !aTail( _aCols[nI] )
			Return .F.
		EndIf
	Next

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fImpRegCols
Funcao de importação de registros para o aCols, TI1 e TI2

@author Marcos Wagner Jr.
@since 19/02/2013
@author Guiherme Benkendorf
@since 15/12/2014
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fImpRegCols( nImport )

	Local bActExibir
	Local bConfirm
	Local cAliImp		:= ""
	Local cTitulo		:= ""
	Local aResul		:= {}
	Local aDBFIMP		:= {}
	Local aTRBImp		:= {}
	Local aIndImp		:= {}
	Local aCoresImp 	:= {}
	Local aButtons      := {}

	//Panel
	Local oPanelAll
	Local oDlgImpReg
	Local oTempIMP

	//Objeto do combo box
	Local oCbx

	Private cAliTRB		:= GetNextAlias()
	//Objeto da variável de filtro
	Private oFiltro

	aAdd( aButtons, { "ng_ico_legenda", { || MDT992Leg1() }, STR0039, STR0039 } ) // "Legenda" ## "Legenda"

	fMontaImp( nImport, @aDBFImp, @aTRBImp, @aIndImp, @aCoresImp )

	oTempIMP := FWTemporaryTable():New( cAliTRB, aDBFIMP )
	If nImport == 1
		oTempIMP:AddIndex( "1", { "RA_MAT" } )
		oTempIMP:AddIndex( "2", { "RA_CODFUNC" } )
	Else
		oTempIMP:AddIndex( "1", { "TI2_NUMRIS" } )
	EndIf
	oTempIMP:Create()

	If nImport == 1 // Funcionarios
		cAliImp := "SRA"
		cTitulo	:= STR0038 // "Importar Funcionários"
		TRBFunc( cAliTRB )
		bConfirm := { || RetFuncion( cAliTRB ) }

	ElseIf nImport == 2 // Riscos
		cAliImp := "TI2"
		cTitulo	:= STR0062 // "Importar Riscos"
		TRBRiscos( cAliTRB )
		bConfirm := { || RetRiscos( cAliTRB	) }

	EndIf

	oDlgImpReg := TDialog():New( 00, 00, aSize[4] + 100, aSize[3] + 140, cTitulo, , , , , , , , oMainWnd, .T. )

		//Panel de baixo com o markbrowse
		oPanelAll := TPanel():New( , , , oDlgImpReg, , , , , , , , .F., .F. )
		oPanelAll:Align := CONTROL_ALIGN_ALLCLIENT

		//Panel de baixo com o markbrowse
		oPanelBottom := TPanel():New( , , , oPanelAll, , , , , , , aPosObj[1, 3], .F., .F. )
		oPanelBottom:Align := CONTROL_ALIGN_ALLCLIENT

		dbSelectArea( cAliImp )

		oMarkImp := MsSelect():New( (cAliTRB), "TRB_OK", , aTRBImp, @lINVERTE, @cMARCA, aPosObj[1], , , oPanelBottom, , aCoresImp )
		oMarkImp:oBrowse:lHASMARK := .T.
		oMarkImp:oBrowse:lCANALLMARK := .T.
		oMarkImp:oBrowse:bALLMARK := {|| fInverte( cAliTRB, cMarca ) }
		oMarkImp:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	oDlgImpReg:Activate( , , , .T., , , EnchoiceBar( oDlgImpReg, { ||nOpc := 1, IIf( Eval( bConfirm ), oDlgImpReg:End(), nOpc := 0 ) },;
						 { ||nOpc := 0, oDlgImpReg:End() }, .F., aButtons ) )

	oTempIMP:Delete()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fMontaImp
Funcao auxiliar para a montagem da tabela temporaria do markBrowse

@author Guilherme Benkendorf
@since 19/02/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fMontaImp( nOpc, aDBF, aTRB, aIndex, aCores )

	Local aTamSX3   := TAMSX3( "TI2_QTDGEN" )

	If nOpc == 1
		aAdd( aDBF, { "TRB_OK", "C", 02, 0     } )
		aAdd( aDBF, { "RA_MAT", "C", 06, 0     } )
		aAdd( aDBF, { "RA_NOME", "C", 30, 0    } )
		aAdd( aDBF, { "RA_CODFUNC", "C", 5, 0  } )
		aAdd( aDBF, { "RA_DESCFUN", "C", 20, 0 } )
		aAdd( aDBF, { "RA_SITUAC", "C", 01, 0  } )

		aIndex   := { "RA_MAT", "RA_CODFUNC" }

		aAdd( aTRB, { "TRB_OK", NIL, " ", } )
		aAdd( aTRB, { "RA_MAT", NIL, STR0047, } )     // "Matrícula"
		aAdd( aTRB, { "RA_NOME", NIL, STR0048, } )    // "Nome"
		aAdd( aTRB, { "RA_CODFUNC", NIL, STR0049, } ) // "Função"
		aAdd( aTRB, { "RA_DESCFUN", NIL, STR0050, } ) // "Descrição"

		aAdd( aCores, { "Empty((cAliTRB)->RA_SITUAC)", "ENABLE"		 } )
		aAdd( aCores, { "(cAliTRB)->RA_SITUAC == 'T'", "BR_PINK"	 } )
		aAdd( aCores, { "(cAliTRB)->RA_SITUAC == 'D'", "BR_VERMELHO" } )
		aAdd( aCores, { "(cAliTRB)->RA_SITUAC == 'A'", "BR_AMARELO"	 } )
		aAdd( aCores, { "(cAliTRB)->RA_SITUAC == 'F'", "BR_AZUL"	 } )
	Else


		aAdd( aDBF, { "TRB_OK", "C", 02, 0     } )
		aAdd( aDBF, { "TI2_NUMRIS", "C", 09, 0 } )
		aAdd( aDBF, { "TI2_AGENTE", "C", 06, 0 } )
		aAdd( aDBF, { "TI2_NOMAGE", "C", 60, 0 } )
		aAdd( aDBF, { "TI2_DTRECO", "D", 08, 0 } )
		aAdd( aDBF, { "TI2_DTAVAL", "D", 08, 0 } )
		aAdd( aDBF, { "TI2_QTDGEN", "N", aTamSX3[1], aTamSX3[2] } )
		aAdd( aDBF, { "TI2_UNIMED", "C", 06, 0 } )

		aIndex := { "TI2_NUMRIS" }

		aAdd( aTRB, { "TRB_OK", NIL, " ", } )
		aAdd( aTRB, { "TI2_NUMRIS", NIL, NGRETTITULO( "TI2_NUMRIS" ), } )
		aAdd( aTRB, { "TI2_AGENTE", NIL, NGRETTITULO( "TI2_AGENTE" ), } )
		aAdd( aTRB, { "TI2_NOMAGE", NIL, NGRETTITULO( "TI2_NOMAGE" ), } )
		aAdd( aTRB, { "TI2_DTRECO", NIL, NGRETTITULO( "TI2_DTRECO" ), } )
		aAdd( aTRB, { "TI2_DTAVAL", NIL, NGRETTITULO( "TI2_DTAVAL" ), } )
		aAdd( aTRB, { "TI2_QTDGEN", NIL, NGRETTITULO( "TI2_QTAGEN" ), } )
		aAdd( aTRB, { "TI2_UNIMED", NIL, NGRETTITULO( "TI2_UNIMED" ), } )
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT992Leg1
Legenda do markBrose de importação da TI1 e TI2.

@author Marcos Wagner Jr.
@since 22/02/2013
@version MP11
@return .T.
/*/
//---------------------------------------------------------------------
Function MDT992Leg1()

	Local aCores  := {}
	Local cOldCad := cCadastro

	cCadastro := "Legenda" // "Legenda"

	aCores    := {	 { "ENABLE", OemToAnsi( STR0051 )	   },; // "Situa‡„o Normal"
					 { "BR_PINK", OemToAnsi( STR0052 )     },; // "Transferido"
					 { "BR_VERMELHO", OemToAnsi( STR0053 ) },; // "Demitido"
					 { "BR_AMARELO", OemToAnsi( STR0054 )  },; // "Afastado"
					 { "BR_AZUL", OemToAnsi( STR0055 )	   };  // "Férias"
					 }

	BrwLegenda( OemToAnsi( STR0056 ),;  // "Situação do Funcionário"
				 OemToAnsi( STR0057 ),; // "Legenda"
				 aCores )

	cCadastro := cOldCad

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} TRBFunc
Carrega a temporario dos funcionarios

@author Marcos Wagner Jr.
@since 22/02/2013
@author Guilherme Benkendorf
@since 01/12/2014
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function TRBFunc( cAliTRB )

	Local cAlias     := "SRA"
	Local cIfFunc    := ""
	Local nTI1CodFun := GDFieldPos( "TI1_CODFUN", oGet9921:aHeader )

	dbSelectArea( "SRA" )
	dbSetOrder( 1 )
	If dbSeek( xFilial( "SRA" ) )
		While SRA->( !Eof() ) .And. xFilial( "SRA" ) == SRA->RA_FILIAL

			dbSelectArea( cAliTRB )
			dbSetOrder( 1 )
			If dbSeek( SRA->RA_MAT )
				RecLock( cAliTRB, .F. )
			Else
				RecLock( cAliTRB, .T. )
			EndIf
				(cAliTRB)->TRB_OK	  := IIf( aScan( oGet9921:aCols, { |x| x[nTI1CodFun] == SRA->RA_MAT .And. !aTail( x ) } ) == 0,;
											 Space( Len( (cAliTRB)->TRB_OK ) ), cMarca )
				(cAliTRB)->RA_SITUAC  := SRA->RA_SITFOLH
				(cAliTRB)->RA_MAT	  := SRA->RA_MAT
				(cAliTRB)->RA_NOME	  := SRA->RA_NOME
				(cAliTRB)->RA_CODFUNC := SRA->RA_CODFUNC
				(cAliTRB)->RA_DESCFUN := NGSEEK( "SRJ", SRA->RA_CODFUNC, 1, "RJ_DESC" )
			(cAliTRB)->(MsUnLock())

			dbSelectArea( cAlias )
			dbSkip()
		End
	EndIf

	dbSelectArea( cAliTRB )
	dbGoTop()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} RetFuncion
Retorna os funcionarios para a Getdados

@author Marcos Wagner Jr.
@since 22/02/2013
@author Guilherme Benkendorf
@since 01/12/2014
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function RetFuncion( cAliTRB )

	Local aColsAux   := aClone( oGet9921:aCols )
	Local aHeadAux   := aClone( oGet9921:aHeader )
	Local aColsTp    := BLANKGETD( aHeadAux )
	Local nTI1TipFun := GDFieldPos( "TI1_TIPFUN", aHeadAux )
	Local nTI1CodFun := GDFieldPos( "TI1_CODFUN", aHeadAux )
	Local nTI1NomFun := GDFieldPos( "TI1_NOMFUN", aHeadAux )
	Local nX

	For nX := Len( aColsAux ) To 1 Step -1
		dbSelectArea( cAliTRB )
		dbSetOrder( 1 )
		If !dbSeek( aColsAux[nX, nTI1CodFun] ) .Or. Empty( (cAliTRB)->TRB_OK )
			aDel( aColsAux, nX )
			aSize( aColsAux, Len( aColsAux ) - 1 )
		EndIf
	Next nX

	dbSelectArea( cAliTRB )
	dbSetOrder( 1 )
	dbGoTop()
	While !Eof()

		If !Empty( (cAliTRB)->TRB_OK ) .And. aScan( aColsAux, { | x | AllTrim( Upper( x[nTI1CodFun] ) ) == AllTrim( Upper( (cAliTRB)->RA_MAT ) ) } ) == 0
	   		aAdd( aColsAux, aClone( aColsTp[1] ) )
	   		aColsAux[Len( aColsAux )][nTI1TipFun] := "1" //Interno
	   		aColsAux[Len( aColsAux )][nTI1CodFun] := (cAliTRB)->RA_MAT
	   		aColsAux[Len( aColsAux )][nTI1NomFun] := (cAliTRB)->RA_NOME
	 	EndIf

		dbSelectArea( cAliTRB )
		dbSkip()
	End
	If Len( aColsAux ) == 0
		aColsAux := BLANKGETD( aHeadAux )
	EndIf

	oGet9921:aCols := aClone( aColsAux )
	oGet9921:oBrowse:Refresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} Inverte
Inverte a marcacao

@author Marcos Wagner Jr.
@since 22/02/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fInverte( cAliTRB, cMarca )

	Local aArea := GetArea()

	If Type( "cAliTRB" ) == "C" .And. Select( cAliTRB ) > 0
		dbSelectArea( cAliTRB )
		dbGoTop()
		While !Eof()
			(cAliTRB)->TRB_OK := IIf( Empty( (cAliTRB)->TRB_OK ), cMARCA, Space( Len( (cAliTRB)->TRB_OK ) ) )
			dbSkip()
		End
		dbSelectArea( cAliTRB )
		dbGoTop()
		oMarkImp:oBrowse:Refresh()
		RestArea( aArea )
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} RetRiscos
Retorna os riscos para a Getdados

@author Marcos Wagner Jr.
@since 22/02/2013
@author Guilherme Benkendorf
@since 01/12/2014
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function RetRiscos( cAliTRB )

	Local aColsAux   := aClone( oGet9922:aCols )
	Local aHeadAux   := aClone( oGet9922:aHeader )
	Local aColsTp    := BLANKGETD( aHeadAux )
	Local nLenAux    := 0
	Local nTI2NumRis := GDFieldPos( "TI2_NUMRIS", aHeadAux )
	Local nTI2Agente := GDFieldPos( "TI2_AGENTE", aHeadAux )
	Local nTI2NomAge := GDFieldPos( "TI2_NOMAGE", aHeadAux )
	Local nTI2DtReco := GDFieldPos( "TI2_DTRECO", aHeadAux )
	Local nTI2DtAval := GDFieldPos( "TI2_DTAVAL", aHeadAux )
	Local nTI2QtdGen := GDFieldPos( "TI2_QTAGEN", aHeadAux )
	Local nTI2Unimed := GDFieldPos( "TI2_UNIMED", aHeadAux )

	Local nX

	For nX := Len( aColsAux ) To 1 Step -1
		dbSelectArea( cAliTRB )
		dbSetOrder( 1 )
		If !dbSeek( aColsAux[nX, nTI2NumRis] ) .Or. Empty( (cAliTRB)->TRB_OK )
			aDel( aColsAux, nX)
			aSize( aColsAux, Len( aColsAux ) - 1 )
		EndIf
	Next nX

	dbSelectArea( cAliTRB )
	dbSetOrder( 1 )
	dbGoTop()
	While !Eof()

		If !Empty( (cAliTRB)->TRB_OK ) .And. aScan( aColsAux, { | x | AllTrim( Upper( x[nTI2NumRis] ) ) == AllTrim( Upper( (cAliTRB)->TI2_NUMRIS ) ) } ) == 0
	   		aAdd( aColsAux, aClone( aColsTp[1] ) )
	   		nLenAux := Len( aColsAux )
	   		aColsAux[nLenAux][nTI2NumRis] := (cAliTRB)->TI2_NUMRIS
	   		aColsAux[nLenAux][nTI2Agente] := (cAliTRB)->TI2_AGENTE
	   		aColsAux[nLenAux][nTI2NomAge] := (cAliTRB)->TI2_NOMAGE
	   		aColsAux[nLenAux][nTI2DtReco] := (cAliTRB)->TI2_DTRECO
	   		aColsAux[nLenAux][nTI2DtAval] := (cAliTRB)->TI2_DTAVAL
	   		aColsAux[nLenAux][nTI2QtdGen] := (cAliTRB)->TI2_QTDGEN
	   		aColsAux[nLenAux][nTI2Unimed] := (cAliTRB)->TI2_UNIMED
	   		MDTA992EPI( (cAliTRB)->TI2_NUMRIS )
	 	EndIf

		dbSelectArea( cAliTRB )
		dbSkip()
	End
	If Len( aColsAux ) == 0
		aColsAux := BLANKGETD( aHeadAux )
	EndIf

	oGet9922:aCols := aClone( aColsAux )
	oGet9922:oBrowse:Refresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} TRBRiscos
Carrega a temporaria dos riscos

@author Marcos Wagner Jr.
@since 22/02/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function TRBRiscos( cAliTRB )

	Local cTMANOMAGE
	Local nTI2NumRis := GDFieldPos( "TI2_NUMRIS", oGet9922:aHeader )

	dbSelectArea( cAliTRB )
	Zap

	dbSelectArea( "TN0" )
	dbSetOrder( 1 ) //TN0_FILIAL+TN0_NUMRIS
	If dbSeek( xFilial( "TN0" ) )
		While TN0->( !Eof() ) .And. TN0->TN0_FILIAL == xFilial( "TN0" )

			If !Empty( TN0->TN0_DTAVAL ) .And. Empty( TN0->TN0_DTELIM )

				cTMANOMAGE := ''
				If NGIFDBSEEK( "TMA", TN0->TN0_AGENTE, 1 )
					cTMANOMAGE := TMA->TMA_NOMAGE
				EndIf

				If !fChkIntRis( , , .F. )
					 dbSelectArea( "TN0" )
					 dbSkip()
					 Loop
				EndIf

				dbSelectArea( cAliTRB )
				dbSetOrder( 1 )
				If dbSeek( TN0->TN0_NUMRIS )
					RecLock( cAliTRB, .F. )
				Else
					RecLock( cAliTRB, .T. )
				EndIf
					(cAliTRB)->TRB_OK     := IIf( aScan( oGet9922:aCols, { |x| x[nTI2NumRis] == TN0->TN0_NUMRIS .And. !aTail( x ) } ) == 0,;
												 Space( Len( (cAliTRB)->TRB_OK ) ), cMarca )
					(cAliTRB)->TI2_NUMRIS := TN0->TN0_NUMRIS
					(cAliTRB)->TI2_AGENTE := TN0->TN0_AGENTE
					(cAliTRB)->TI2_NOMAGE := cTMANOMAGE
					(cAliTRB)->TI2_DTRECO := TN0->TN0_DTRECO
					(cAliTRB)->TI2_DTAVAL := TN0->TN0_DTAVAL
					(cAliTRB)->TI2_QTDGEN := TN0->TN0_QTAGEN
					(cAliTRB)->TI2_UNIMED := TN0->TN0_UNIMED

				(cAliTRB)->( MsUnLock() )
			EndIf
			dbSelectArea( "TN0" )
			dbSkip()
		End
	EndIf

	dbSelectArea( cAliTRB )
	dbGoTop()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT992WHF3
Troca o F3 de acordo com o combobox do tipo

@author Marcos Wagner Jr.
@since 07/03/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT992WHF3()

	Local _cTabVIG
	Local _cTabRES
	Local _cTabSUP
	Local _cTabSUE

	Local aTabelas := { "SRA", "TMK", "QAA" }

	If IsInCallStack( "MDTA992" )

		_cTabVIG := aTabelas[ Val( M->TI0_TIPVIG ) ]

		_cTabRES := aTabelas[ Val( M->TI0_TIPRES ) ]

		_cTabSUP := aTabelas[ Val( M->TI0_TIPSUP ) ]

		_cTabSUE := aTabelas[ Val( M->TI0_TIPSUE ) ]

		aTROCAF3 := {}
		aAdd( aTROCAF3, { "TI0_CODVIG", _cTabVIG } )
		aAdd( aTROCAF3, { "TI0_CODRES", _cTabRES } )
		aAdd( aTROCAF3, { "TI0_CODSUP", _cTabSUP } )
		aAdd( aTROCAF3, { "TI0_CODSUE", _cTabSUE } )
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} RetPropri
Função auxiliar para retorno a tabela, campo e descrição

@author Marcos Wagner Jr.
@since 07/03/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function RetPropri( _cCombo )

	Local nPosCombo := Val( _cCombo )
	Local aTabelas  := {}
	Local aReturn   := {}

	aAdd( aTabelas, { "SRA", "RA_NOME", IIf( ( TAMSX3( "RA_MAT" )[1] ) < 1, 9, ( TAMSX3( "RA_MAT" )[1] ) ) } )
	aAdd( aTabelas, { "TMK", "TMK_NOMUSU", IIf( ( TAMSX3( "TMK_CODUSU" )[1] ) < 1, 9, ( TAMSX3( "TMK_CODUSU" )[1] ) ) } )
	aAdd( aTabelas, { "QAA", "QAA_NOME", IIf( ( TAMSX3( "QAA_MAT" )[1] ) < 1, 9, ( TAMSX3( "QAA_MAT" )[1] ) ) } )
	_nTamanho := 1

	If nPosCombo <= Len( aTabelas )
		aReturn := aClone( aTabelas[nPosCombo] )
	Else
		aReturn := { "", "", "" }
	EndIf

Return aReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT992CBX
Valid dos campos Combobox

@author Marcos Wagner Jr.
@since 07/03/2013
@version MP11
@obs Utilização: X3_VALID (TI0_TIPVIG/TI0_TIPRES/TI0_TIPSUP/TI0_TIPSUE)
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT992CBX( _cCombo, _cCodigo, _cDescrica )

	Local lRet := .F.

	lRet := Pertence( "123" )

	If lRet
		&(_cCodigo)   := Space( Len( &( _cCodigo ) ) )
		&(_cDescrica) := Space( Len( &( _cDescrica ) ) )

		MDT992WHF3()
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT992COD
Valida o campos de codigo

@author Marcos Wagner Jr.
@since 11/03/2013
@version MP11
@Obs Utilização: X3_VALID (TI0_CODVIG/TI0_CODRES/TI0_CODSUP/TI0_CODSUE)
@return Nil
/*/
//---------------------------------------------------------------------
Function MDT992COD( _nCampo )

	Local lRet := .T.
	Local cCmpCod
	Local cCmpTip
	Local cCmpDes

	If _nCampo == 1 //TI0_CODVIG
		cCmpCod := M->TI0_CODVIG
		cCmpTip := M->TI0_TIPVIG
		cCmpDes := "M->TI0_NOMVIG"
	ElseIf _nCampo == 2 //TI0_CODRES
		cCmpCod := M->TI0_CODRES
		cCmpTip := M->TI0_TIPRES
		cCmpDes := "M->TI0_NOMRES"
	ElseIf _nCampo == 3 //TI0_CODSUP
		cCmpCod := M->TI0_CODSUP
		cCmpTip := M->TI0_TIPSUP
		cCmpDes := "M->TI0_NOMSUP"
	ElseIf _nCampo == 4 //TI0_CODSUE
		cCmpCod := M->TI0_CODSUE
		cCmpTip := M->TI0_TIPSUE
		cCmpDes := "M->TI0_NOMSUE"
	EndIf

	If !Empty( cCmpCod )
		lRet := MDT992VLID( cCmpTip, _nCampo )
	Else
		&cCmpDes := Space( Len( &cCmpDes ) )
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT992VLID
Valid dos campos relacionados com os combos

@author Marcos Wagner Jr.
@since 07/03/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MDT992VLID( _cCombo, _nCampo )

	Local _cTab
	Local _cCodigo
	Local _cNome
	Local _nTamanho
	Local lRet := .T.

	_cTab     := RetPropri( _cCombo )[1]
	_cNome    := RetPropri( _cCombo )[2]
	_nTamanho := RetPropri( _cCombo )[3]

	If _nCampo == 1
		_cCodigo := SubStr( M->TI0_CODVIG, 1, _nTamanho )
	ElseIf _nCampo == 2
		_cCodigo := SubStr( M->TI0_CODRES, 1, _nTamanho )
	ElseIf _nCampo == 3
		_cCodigo := SubStr( M->TI0_CODSUP, 1, _nTamanho )
	ElseIf _nCampo == 4
		_cCodigo := SubStr( M->TI0_CODSUE, 1, _nTamanho )
	EndIf

	If !ExistCpo( _cTab, _cCodigo, 1 )
		lRet := .F.
	EndIf

	If lRet
		If _nCampo == 1
			M->TI0_NOMVIG := NGSEEK( _cTab, M->TI0_CODVIG, 1, _cNome )
		ElseIf _nCampo == 2
			M->TI0_NOMRES := NGSEEK( _cTab, M->TI0_CODRES, 1, _cNome )
		ElseIf _nCampo == 3
			M->TI0_NOMSUP := NGSEEK( _cTab, M->TI0_CODSUP, 1, _cNome )
		ElseIf _nCampo == 4
			M->TI0_NOMSUE := NGSEEK( _cTab, M->TI0_CODSUE, 1, _cNome )
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} RetBoxTI5
Retorna a lista de opcoes dos campos da TI5

@param nCampo Numerico Indica o campo a ser retornado.
					 1 - TI5_OPERAD
@Obs Função utilizada no X3_CBOX do campo TI5_OPERAD.

@author Guilherme Benkendorf
@since 21/09/2014
@return cRet
/*/
//---------------------------------------------------------------------
Function RetBoxTI5( nCampo )

	Local cRet

	If nCampo == 1 //1 - TI5_OPERAD
		cRet :=	  "1=" + STR0075 + ; //"Igual a"
				 ";2=" + STR0076 + ; //"Diferente de"
				 ";3=" + STR0077 + ; //"Menor que"
				 ";4=" + STR0078 + ; //"Menor que ou igual a"
				 ";5=" + STR0079 + ; //"Maior que"
				 ";6=" + STR0080     //"Maior que ou igual a"
	EndIf

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fValPTDt
Valida Datas e horas do cadastro da PT/PET

@author Guilherme Benkendorf
@since 04/12/2014
@return lRet
/*/
//---------------------------------------------------------------------
Static Function fValPTDt( lConclusao, lRevisao )

	Local nX
	Local lRet := .T.

	Local dDtSuper // Variavel para analise de data superior
	Local dDtIni
	Local dDtFim

	Local cHrSuper // Variavel para analise de hora superior
	Local cHrIni
	Local cHrFim
	// aDtCheck defique o conjunto de campos que serao analisados
	Local aDtCheck := { "TI0_DTPINI", "TI0_DTPFIM", "TI0_HRPINI", "TI0_HRPFIM" }
	Local aDtConcl := {}
	Local aDtRevis := {}

	Default lConclusao := .F.
	Default lRevisao   := .F.

	If lConclusao .Or. lRevisao
		//Conclusao - Analise de Data/Hora Real Inicio/Fim
		aDtConcl := { "TI0_DTRINI", "TI0_DTRFIM", "TI0_HRRINI", "TI0_HRRFIM" }

		//Revisao - Analise de Data/Hora Real Inicio/Fim
		aDtRevis := { "TI0_DINIRV", "TI0_DFIMRV", "TI0_HINIRV", "TI0_HFIMRV" }

		dDtSuper := M->TI0_DTCONC
		cHrSuper := M->TI0_HRCONC

		If lConclusao
			// Quando for Conclusão é necessario analisar se as
			// datas informas são menores do que as datas de conclusão
			aDtCheck := aClone( aDtConcl )
		Else
			// Quando for revisão é necessario analisar se as
			// datas informas são menores do que as datas de conclusão,
			// caso a conclusao não seja informada, será analisado a data/hora atual
			aDtCheck := aClone( aDtRevis )
			If Empty( dDtSuper )
				dDtSuper := dDataBase
				cHrSuper := SubStr( Time(), 1, 5 )
			EndIf
		EndIf

		dDtFim   := M->( &( aDtCheck[ 2 ] ) ) // Data Fim
		cHrFim   := M->( &( aDtCheck[ 4 ] ) ) // Hora Fim

		If dDtFim > dDtSuper .Or. ( dDtSuper == dDtFim .And. cHrFim > cHrSuper  )
				ShowHelpDlg( "INVALID", { STR0081 }, 1,;//"Registros inválidos."
							 { AllTrim( NGRETTITULO( aDtCheck[ 2 ] ) ) + ": '" + DtoC( dDtFim ) + "'" + CRLF + ;
							 AllTrim( NGRETTITULO( aDtCheck[ 4 ] ) ) + ": '" + cHrFim + "'" + CRLF + ;
							 STR0121 + CRLF + ;//" deverá ser menor ou igual que "
							 AllTrim( STR0029 ) + "'" + DtoC( dDtSuper )+ "'" + CRLF + ;//"Data: "
							 AllTrim( STR0030 ) + "'" + cHrSuper + "'." } )//"Hora: "
			lRet := .F.
		EndIf

		//Quando for operação de Conclusão e Revisao, será verficado a obrigatoriedade do preenchimento dos campos
		For nX := 1 To Len( aDtCheck )
			If Empty( M->( &( aDtCheck[ nX ] ) ) )
				Help( " ", 1, "OBRIGAT", , NGRETTITULO( aDtCheck[ nX ] ), 05 )
				lRet := .F.
				Exit
			EndIf
		Next nX
	EndIf

	//Verificação de datas e horas genéricas, pelo array aDtCheck
	// Posição 1 - Corresponde da Data Inicio
	// Posição 2 - Corresponde da Data Fim
	// Posição 3 - Corresponde a Hora Inicio
	// Posição 4 - Corresponde a Hora Final
	If lRet

		dDtIni := M->( &( aDtCheck[ 1 ] ) ) // Data Inicio
		dDtFim := M->( &( aDtCheck[ 2 ] ) ) // Data Fim
		cHrIni := M->( &( aDtCheck[ 3 ] ) ) // Hora Inicio
		cHrFim := M->( &( aDtCheck[ 4 ] ) ) // Hora Fim

		If dDtIni > dDtFim
			ShowHelpDlg( "INVALID", { STR0081}, 1,; //"Registros inválidos."
						 { AllTrim( NGRETTITULO( aDtCheck[ 2 ] ) ) +;
						 STR0082 + ; //" deverá ser maior ou igual que "
						 AllTrim( NGRETTITULO( aDtCheck[ 1 ] ) ) + "." }, 2 )
			lRet := .F.

		ElseIf dDtIni == dDtFim

			If !Empty( cHrIni ) .And. !Empty( cHrFim ) .And. cHrIni > cHrFim
				ShowHelpDlg( "INVALID", { STR0081 }, 1,;//"Registros inválidos."
							 { AllTrim( NGRETTITULO( aDtCheck[ 4 ] ) ) +;
							 STR0082 + AllTrim( NGRETTITULO( aDtCheck[ 3 ] ) ) + "." }, 2 ) //" deverá ser maior ou igual que "
				lRet := .F.

			EndIf
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTVLDTI5( nCampo )
Validação da tabela TI5 - CheckList PT/PET.

@param nCampo Numerico Indica o campo a ser retornado.
					 9 - TI5_OPERAD

@author Guilherme Benkendorf
@since 21/09/2014
@return lRet
/*/
//---------------------------------------------------------------------
Function MDTVLDTI5( nCampo )

	Local lRet  := .T.
	Local aArea := GetArea()

	Do Case

		Case nCampo == 1 // TI5_QUESTI
			lRet := IIf( !Empty( M->TI5_QUESTI ), ExistCpo( "TJ2", M->TI5_QUESTI ), .T. )
		Case nCampo == 2 // TI5_CODGRU
			lRet := IIf( !Empty( M->TI5_CODGRU ), ExistCpo( "TJ4", M->TI5_CODGRU ), .T. )
			If lRet
				If NGSeek( "TJ4", M->TI5_CODGRU, 1, "TJ4_TIPREG" ) == "2"
					ShowHelpDlg( "", { "" }, 2, { "" }, 2 ) //Deveria Trazer mensagem
					lRet := .F.
				EndIf
			EndIf

			If lRet .And. IsInCallStack( "MDTA992CAD" )
				fGrpTotal( M->TI5_CODGRU )
			EndIf

		Case nCampo == 3 // TI5_QUESTA
			If Type( "M->TI5_QUESTI" ) != "U" .And. !Empty( M->TI5_QUESTA )
				dbSelectArea( "TJ3" )
				dbSetOrder( 1 )
				If !( lRet := dbSeek( xFilial( "TJ3" ) + M->TI5_QUESTI + M->TI5_QUESTA ) )
					Help( " ", 1, "REGNOIS" )
				EndIf
			EndIf
		Case nCampo == 4 // TI5_OPERAD
			lRet := IIf( !Empty( M->TI5_OPERAD ), Pertence( "123456" ), .T. )

	End Case

	RestArea( aArea )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT999WBOX
When do campo TI5_RESPOS, abre essa função quando tenta entrar no campo
tela para informar as opções do combo da pergunta.

@author Guilherme Benkendorf
@since 24/09/2014
@version MP11
@return boolean lRet: sempre falso
/*/
//---------------------------------------------------------------------
Function MDTWHENTI5( nCampo )

	Local lRet      := .T.
	Local nPosCodGru
	Local nPosQuesta
	Local nAtG
	Local nAtP

	Default nCampo := 1

	If IsInCallStack( "MDTA992CAD" )
		nPosCodGru := GDFieldPos( "TI5_CODGRU", oGetGrp:aHeader )
		nPosQuesta := GDFieldPos( "TI5_QUESTA", oGetPerg:aHeader )
		nAtG	   := oGetGrp:nAt
		nAtP	   := oGetPerg:nAt
		cTpList	   := NGSeek( "TJ3", M->TI5_QUESTI + oGetPerg:aCols[nAtP][nPosQuesta], 1, "TJ3_TPLIST" )
		cTipReg	   := NGSeek( "TJ4", oGetGrp:aCols[nAtG][nPosCodGru], 1, "TJ4_TIPREG" )
		//Bloqueia TI5_QUESTA caso o grupo de pergunta seja do tipo 3=Total;
		If nCampo == 1
			lRet  := ( cTipReg != "3" )
		//TI5_RESULT//TI5_OPERAD
		ElseIf nCampo == 2 .Or. nCampo == 3
		//TJ4_TIPREG;"1=Título Central;2=Título de Colunas;3=Total;4=Total por coluna da seção de perguntas"
		//TJ3_TPLIST;"1=Opção Exclusiva;2=Múltiplas Opções;3=Texto Descritivo;4=Numérico;5=Result. Formul."
			If cTipReg == "3"//Total
				lRet  := .T.
			Else
				lRet	:= cTpList $ "45"
			EndIf

       	If lRet .And. nCampo == 3
       		lRet := fChgFormt()
       	EndIf
		ElseIf nCampo == 4//O campo TI5_RESPOS exibe
			If lRet .And. ( cTpList $ "1#2" ) .And. ( cTipReg <> "3" )
				lRet := MDT992WBOX()
			Else
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT992WBOX
When do campo TI5_RESPOS, abre essa função quando tenta entrar no campo
tela para informar as opções do combo da pergunta.

@author Guilherme Benkendorf
@since 24/09/2014
@version MP11
@return boolean lRet: sempre falso
/*/
//---------------------------------------------------------------------
Static Function MDT992WBOX()

	Local lRet       := .F.
	Local nAtP		 := oGetPerg:nAt
	Local nPosQuesta := GDFieldPos( "TI5_QUESTA", oGetPerg:aHeader )
	Local nPosRespos := GDFieldPos( "TI5_RESPOS", oGetPerg:aHeader )

	Local oChecked  := LoadBitmap( GetResources(), "LBTIK" )
	Local oUnCheck  := LoadBitmap( GetResources(), "LBNO" )
	Local bBoxPerg
	Local cCombo
	Local cResposta

	Local aCodBox   := { "1", "2", "3", "4", "5", "6", "7", "8", "9",;
						 "A", "B", "C", "D", "E", "F", "G", "H", "I",;
						 "J", "K", "L", "M", "N", "O", "P", "Q", "R",;
						 "S", "T", "U", "V", "W", "X", "Y", "Z" }
	//Esta função executa uma pesquisa em um arquivo, pela chave especificada e ordem especificada, retornando o conteúdo de um ou mais campos.
	Local aPergTJ3 := GetAdvFval( "TJ3", { "TJ3_TPLIST", "TJ3_COMBO" },;
								 xFilial( "TJ3" ) + M->TI5_QUESTI + oGetPerg:aCols[oGetPerg:nAt][nPosQuesta], 1 )

	Local oPnlTop
	Local oPnlCenter
	Local oPnlBottom

	Local nRecGeral
	Local cPeso    := ""
	Local nPosPeso := 0
	Local nI       := 0

	Private oBoxPerg
	Private aBoxPerg

	If !( aPergTJ3[1] $ "12" ) //TJ3_TPLIST //"1=Opção Exclusiva;//2=Múltiplas Opções;
		Return .F.
	EndIf

	cResposta		:= oGetPerg:aCols[nAtP][nPosRespos]
	cCombo			:= aPergTJ3[2] //TJ3_COMBO
	aBoxPerg		:= {}

	aOptions := StrTokArr( cCombo, ";" )

	For nI := 1 To Len( aCodBox )
		nPos     := aScan( aOptions, { |x| SubStr( x, 1, 2 ) == aCodBox[nI] + "=" } )
		If nPos != 0
			nPosPeso := At( "*P:", aOptions[nPos] )
			nPosFim  := IIf( nPosPeso != 0, nPosPeso - 3, Len( aOptions[nPos] ) )
			cDesc    := SubStr( aOptions[nPos], 3, nPosFim )
			cPeso    := SubStr( aOptions[nPos], nPosPeso + 3, 3 )
			cPeso    := IIf( nPosPeso != 0, cPeso, Space( 3 ) )
			aAdd( aBoxPerg, { ( aCodBox[nI] $ cResposta ), aCodBox[nI], PadR( cDesc, 30 ), cPeso } )
		Else
			aAdd( aBoxPerg, { .F., aCodBox[nI], Space( 30 ), Space( 3 ) } )
		EndIf
	Next nI

	opcaoZZ := 0

	oDlgOpcs := MsDialog():New(000, 000, 350, 600, STR0083, , , , , , , , oMainWnd, .T. ) //"Editar Lista de Opções"

		oPnlTop := TPanel():New( 0, 0, , oDlgOpcs, , , , , , 12, 20, .F., .F. )
			oPnlTop:Align := CONTROL_ALIGN_TOP

		TSay():New( 005, 009, { | | OemtoAnsi( STR0084 ) }, oPnlTop, , , .F., .F., .F., .T., , CLR_BLACK ) // "Configure a lista de opções:"

		oPnlCenter := TPanel():New( 0, 0, , oDlgOpcs, , , , , , 12, 15, .F., .F. )
			oPnlCenter:Align := CONTROL_ALIGN_ALLCLIENT

		oBoxPerg := TWBrowse():New( 017, 010, 200, 110, , { " ", STR0085, STR0050, STR0086 }, { 10, 20, 130, 100 },; //"Opção"//"Descrição"//"Peso"
									 oPnlCenter, , , , , , , , , , , , , , .T., , , , .T., .T. )


		oBoxPerg:SetArray( aBoxPerg )
		bBoxPerg            := { || { IIf( aBoxPerg[oBoxPerg:nAt, 1], oChecked, oUnCheck ), aBoxPerg[oBoxPerg:nAt, 2],;
								 aBoxPerg[oBoxPerg:nAt, 3], aBoxPerg[oBoxPerg:nAt, 4] } }
		oBoxPerg:bLine      := bBoxPerg
		oBoxPerg:bLDblClick := { || fMarkOpca() }
		oBoxPerg:Align := CONTROL_ALIGN_ALLCLIENT

	oDlgOpcs:Activate( , , , .T., , , EnchoiceBar( oDlgOpcs, { || ( IIf( fValResp( aBoxPerg ), ( opcaoZZ := 1, oDlgOpcs:End() ), opcaoZZ := 0 ) ) }, { || oDlgOpcs:End() } ) )

	If opcaoZZ == 1
		fGravRes( @oGetPerg )
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fValResp
Valida confirmação da tela de opções da pergunta.

@author Guilherme Benkendorf
@since 28/02/2013
@version MP11
@return boolean lRet: conforme validação
/*/
//---------------------------------------------------------------------
Static Function fValResp( aBoxPerg )

	Local lRet  := .T.
	Local nCont := 0

	aEval( aBoxPerg, { | x | IIf( x[1], nCont++, ) } )

	If nCont == 0
		ShowHelpDlg( "", { STR0087 }, 2,; //"Não poderá ser realizado a confirmação sem nenhuma opção selecionada."
					 { STR0088 }, 2 )     //"No mínimo uma opção deverá ser selecionada."
		lRet := .F.
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fMarkOpca
Função contem a regra de marcação.
 - Quando o tipo de pergunta for exclusiva, deverá selecionar apenas um valor.
 - Quando o tipo de pergunta for multiplas ações, deverá selecionar quantos
 valores quiser

@author Guilherme Benkendorf
@since 08/12/2014
@version MP11
@return boolean
/*/
//---------------------------------------------------------------------
Static Function fMarkOpca()

	Local nPosQuesta	:= GDFieldPos( "TI5_QUESTA", oGetPerg:aHeader )
	Local nAtP			:= oGetPerg:nAt
	Local nCheck		:= 0
	Local lExclusive 	:= ( NGSeek( "TJ3", M->TI5_QUESTI +	oGetPerg:aCols[nAtP][nPosQuesta], 1, "TJ3_TPLIST" ) == "1" )

	If !Empty( aBoxPerg[oBoxPerg:nAt][3] )
		If lExclusive
			aEval( aBoxPerg, { | x | IIf( !Empty( x[3] ), x[1] := .F., ) } )
			aBoxPerg[oBoxPerg:nAt][1] := !aBoxPerg[oBoxPerg:nAt][1]
			oBoxPerg:Refresh()
		Else
			aBoxPerg[oBoxPerg:nAt][1] := !aBoxPerg[oBoxPerg:nAt][1]
		EndIf
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fGravRes
Valida confirmação da tela de opções da pergunta.

@author André Felipe Joriatti
@since 28/02/2013
@version MP11
@return boolean lRet: conforme validação
/*/
//---------------------------------------------------------------------
Static Function fGravRes( oPerg )

	Local lRet    := .T.

	Local nx
	Local nAt := oPerg:nAt
	Local nPosRespos := GDFieldPos( "TI5_RESPOS", oPerg:aHeader )

	Local cResposta := ""

	aEval( aBoxPerg, { | x | IIf( x[1] .And. !Empty( x[3] ), cResposta += x[2] + ";", ) } )

	oPerg:aCols[nAt][nPosRespos] := cResposta
	oPerg:Refresh()

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetPergs
When do campo TI5_RESPOS, abre essa função quando tenta entrar no campo
tela para informar as opções do combo da pergunta.

@author Guilherme Benkendorf
@since 24/09/2014
@version MP11
@return boolean lRet: sempre falso
/*/
//---------------------------------------------------------------------
Static Function fGetPergs( cQuesti, oPanel, nOpcao )

	Local lRet := .T.

	Default nOpcao := 2

	If nOpcao != 2 .And. nOpcao != 5
		If Empty( cQuesti ) .Or. M->TI0_STATUS $ "3#4" //3=Respondida Parcialmente;4=Não Respondida
			oPanel:Enable()
			oPanel:SetFocus()
			lRet := .T.
		Else
			oPanel:Disable()
			lRet := .F.
		EndIf
	Else
		lRet := .F.
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fAddPerg
Função de verificação do grupo de perguntas e adiciona em um array,
para retorna lo e adiciona lo no aCols de perguntas.

@author Guilherme Benkendorf
@since 24/09/2014
@version MP11
@return aPerguntas Array
/*/
//---------------------------------------------------------------------
Static Function fAddPerg( cAliAux, cGrupo )

	Local nPosQuesta
	Local nPosPergun
	Local nPosOperad
	Local nPosResult
	Local nPosRespos
	Local nLenPerg

	Local aPerguntas:= {}
	Local aColsAuxp := BLANKGETD( aHeadPerg )

	nPosQuesta := GDFieldPos( "TI5_QUESTA", aHeadPerg )
	nPosPergun := GDFieldPos( "TI5_PERGUN", aHeadPerg )
	nPosOperad := GDFieldPos( "TI5_OPERAD", aHeadPerg )
	nPosResult := GDFieldPos( "TI5_RESULT", aHeadPerg )
	nPosRespos := GDFieldPos( "TI5_RESPOS", aHeadPerg )

	dbSelectArea( cAliAux )
	dbSetOrder( 1 )
	If dbSeek( cGrupo ) .And. !Empty( ( cAliAux )->TRB_QUESTA )
		While ( cAliAux )->( !Eof() ) .And. ( cAliAux )->TRB_CODGRU == cGrupo

			aAdd( aPerguntas, aClone( aColsAuxP[1] ) )
			nLenPerg := Len( aPerguntas )
			aPerguntas[nLenPerg][nPosQuesta] := ( cAliAux )->TRB_QUESTA
			aPerguntas[nLenPerg][nPosPergun] := ( cAliAux )->TRB_PERGUN
			aPerguntas[nLenPerg][nPosOperad] := ( cAliAux )->TRB_OPERAD
			aPerguntas[nLenPerg][nPosResult] := ( cAliAux )->TRB_RESULT
			aPerguntas[nLenPerg][nPosRespos] := ( cAliAux )->TRB_RESPOS
			aTail( aPerguntas[nLenPerg] )    := !Empty( ( cAliAux )->TRB_DELETE )
			( cAliAux )->( dbSkip() )
		End
	EndIf

	If Len( aPerguntas ) == 0
		aPerguntas := aClone( aColsAuxp )
	EndIf

Return aPerguntas

//---------------------------------------------------------------------
/*/{Protheus.doc} fChgGrp
fChgGrp - Função utilizada no bChange de oGetGrp. Muda o acols de perguntas
e atualiza variaveis privates para utilização de filtros na get de perguntas.

@author Guilherme Benkendorf
@since 24/09/2014
@version MP11
@return boolean lRet: sempre falso
/*/
//---------------------------------------------------------------------
Static Function fChgGrp( cAliTRB1, cAliTRB2 )

	Local nAt
	Local nPosCodGru
	Local nPosDescri

	nAt		   := oGetGrp:nAt
	nPosCodGru := GDFieldPos( "TI5_CODGRU", oGetGrp:aHeader )
	nPosDescri := GDFieldPos( "TI5_DESCRI", oGetGrp:aHeader )

	oGetPerg:aCols := aClone( fAddPerg( cAliTRB2, oGetGrp:aCols[nAt][nPosCodGru] ) )
	fGrpTotal( oGetGrp:aCols[nAt][nPosCodGru] )

	oGetPerg:Refresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fChgPerg
fChgPerg - Função utilizada no bChange da oGetPerg. Atualiza TRB auxiliar
das perguntas.

@author Guilherme Benkendorf
@since 24/09/2014
@version MP11
@return boolean lRet: sempre falso
/*/
//---------------------------------------------------------------------
Static Function fChgPerg( cAliTRB, cAliTRB2 )

	Local nAtG, nAtP
	Local nPosCodGru
	Local nPosDescri
	Local nPosQuesta
	Local nPosPergun
	Local nPosOperad
	Local nPosResult
	Local nPosRespos

	Local lRet

	nAtG       := oGetGrp:nAt
	nAtP       := oGetPerg:nAt
	nPosCodGru := GDFieldPos( "TI5_CODGRU", oGetGrp:aHeader )
	nPosDescri := GDFieldPos( "TI5_DESCRI", oGetGrp:aHeader )
	nPosQuesta := GDFieldPos( "TI5_QUESTA", oGetPerg:aHeader )
	nPosPergun := GDFieldPos( "TI5_PERGUN", oGetPerg:aHeader )
	nPosOperad := GDFieldPos( "TI5_OPERAD", oGetPerg:aHeader )
	nPosResult := GDFieldPos( "TI5_RESULT", oGetPerg:aHeader )
	nPosRespos := GDFieldPos( "TI5_RESPOS", oGetPerg:aHeader )

	dbSelectArea( cAliTRB )
	dbSetOrder( 1 )
	lRet := !( dbSeek( oGetGrp:aCols[nAtG][nPosCodGru] ) )

	If !Empty( oGetPerg:aCols[nAtP][nPosQuesta] )
		RecLock( cAliTRB, lRet )

			( cAliTRB )->TRB_QUESTI := M->TI5_QUESTI
			( cAliTRB )->TRB_CODGRU := oGetGrp:aCols[nAtG][nPosCodGru]
			( cAliTRB )->TRB_DESCRI := oGetGrp:aCols[nAtG][nPosDescri]

		( cAliTRB )->( MsUnLock() )

		dbSelectArea( cAliTRB2 )
		dbSetOrder( 2 )
		lRet := !( dbSeek( oGetGrp:aCols[nAtG][nPosCodGru] + cValToChar( nAtP ) ) )
		RecLock( cAliTRB2, lRet )
			( cAliTRB2 )->TRB_NAT    := cValToChar( nAtP )
			( cAliTRB2 )->TRB_CODGRU := oGetGrp:aCols[nAtG][nPosCodGru]
			( cAliTRB2 )->TRB_QUESTA := oGetPerg:aCols[nAtP][nPosQuesta]
			( cAliTRB2 )->TRB_PERGUN := oGetPerg:aCols[nAtP][nPosPergun]
			( cAliTRB2 )->TRB_OPERAD := oGetPerg:aCols[nAtP][nPosOperad]
			( cAliTRB2 )->TRB_RESULT := oGetPerg:aCols[nAtP][nPosResult]
			( cAliTRB2 )->TRB_RESPOS := oGetPerg:aCols[nAtP][nPosRespos]

		( cAliTRB2 )->( MsUnLock() )

		dbSelectArea( cAliTRB2 )
		dbSetOrder( 1 )
		dbSeek( oGetGrp:aCols[nAtG][nPosCodGru] )
		While ( cAliTRB2 )->( !Eof() ) .And. ( cAliTRB2 )->TRB_CODGRU == oGetGrp:aCols[nAtG][nPosCodGru]
			If aScan( oGetPerg:aCols, { | x | x[nPosQuesta] == ( cAliTRB2 )->TRB_QUESTA } ) == 0
				RecLock( cAliTRB2, .F. )
					( cAliTRB2 )->( dbDelete() )
				( cAliTRB2 )->( MsUnLock() )
			EndIf
			( cAliTRB2 )->( dbSkip() )
		End
	EndIf

	oGetGrp:Refresh()
	oGetPerg:Refresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fDelCheck
fDelCheck - Função do bloco bDelOk. Verifica se é possivel a exclusão
da Getdados de oGetGrp e oGetPerg.

@author Guilherme Benkendorf
@since 24/09/2014
@version MP11
@return lRet Boolean
/*/
//---------------------------------------------------------------------
Static Function fDelCheck( cAliTRB, cAliTRB2, nOpc )

	Local lRet  := .T.
	Local nCont := 0
	Local nX
	Local nAtG
	Local nAtP

	nPosCodGru := GDFieldPos( "TI5_CODGRU", oGetGrp:aHeader )
	nPosQuesta := GDFieldPos( "TI5_QUESTA", oGetPerg:aHeader )

	If nOpc == 1
		//Verifica se há perguntas não exluidas e sendo Código da questão preenchida
		aEval( oGetPerg:aCols, { | x | IIf( !aTail( x ) .And. !Empty( x[1] ), nCont++, ) } )
		If nCont > 0
			lRet := .F.
			ShowHelpDlg( "", { STR0089 }, 2,; // "Não é possível deletar Grupo pois ele está relacionado a uma ou mais perguntas."
						 { STR0090 }, 2 )     // "Primeiramente exclua suas perguntas."
			oGetGrp:oBrowse:SetFocus()
		EndIf
	EndIf

	If lRet
		nAtG := oGetGrp:nAt
		nAtP := oGetPerg:nAt
		If nOpc == 1
			dbSelectArea( cAliTRB )
			dbSetOrder( 1 )
			If dbSeek( oGetGrp:aCols[nAtG][nPosCodGru] )
				RecLock( cAliTRB, .F. )
					( cAliTRB )->TRB_DELETE := IIf( !aTail( oGetPerg:aCols[nAtP] ), _MDT992DEL, Space( 1 ) )
				MsUnLock()
			EndIf
		ElseIf nOpc == 2
			dbSelectArea( cAliTRB2 )
			dbSetOrder( 2 )
			If dbSeek( oGetGrp:aCols[nAtG][nPosCodGru] + cValToChar( nAtP ) )
				RecLock( cAliTRB2, .F. )
					( cAliTRB2 )->TRB_DELETE := IIf( !aTail( oGetPerg:aCols[nAtP] ), _MDT992DEL, Space( 1 ) )
				MsUnLock()
			EndIf
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fGrpTotal
Função auxiliar para atualizar variavel private cOrdGpr992. Responsavel
pelo filtro de perguntas quando for grupo de perguntas do tipo
"4=Total por coluna da seção de perguntas".
E preenche o aCols de perguntas quando o grupo de perguntas for do tipo
"3=Total"

@author Guilherme Benkendorf
@since 24/09/2014
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fGrpTotal( cGrupo )

	Local nPosQuesta := GDFieldPos( "TI5_QUESTA", oGetPerg:aHeader )
	Local nAux

	Local cTipReg := NGSeek( "TJ4", cGrupo, 1, "TJ4_TIPREG" )

	If cTipReg == "3" .And. Empty( oGetPerg:aCols[1][nPosQuesta] )
		oGetPerg:aCols[1][nPosQuesta] := NGSeek( "TJ3", cGrupo + M->TI5_QUESTI, 4, "TJ3_QUESTA" )
		oGetPerg:Refresh()
	ElseIf cTipReg == "4"
		cOrdGpr992 := NGSeek( "TJ3", cGrupo + M->TI5_QUESTI, 4, "TJ3_ORDGRP" )
		nAux := Val( cOrdGpr992 ) - 1
		cOrdGpr992 := STRZero( nAux, 3 )

		dbSelectArea( "TJ3" )
		dbSetOrder( 3 )
		dbSeek( xFilial( "TJ3" ) + M->TI5_QUESTI + cOrdGpr992 )
		While ( Bof() .Or. Eof() ) .And. !dbSeek( xFilial( "TJ3" ) + M->TI5_QUESTI + cOrdGpr992 ) .And. nAux > 0
			nAux := Val( cOrdGpr992 ) - 1
			cOrdGpr992 := STRZero( nAux, 3 )
		End
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fPTStatus

Função verifica checklist com o questionário respondido.
E altera status da liberação da PT/PET.

@author Guilherme Benkendorf
@since 13/10/2014
@version MP11
@return
/*/
//---------------------------------------------------------------------
Static Function fPTStatus( lDelete )

	Local cStatus    := ""
	Local cCato      := ""
	Local nRespon    := 0
	Local nTotResp   := 0
	Local nTotalGrp  := 0
	Local nReprovado := 0
	Local nValRespos := 0
	Local lLiberado  := .T.
	Local aOperaTI5  := { "==", "<>", "<", "<=", ">", ">=" }

	Local cTipGrup
	Local cTipoPerg

	Local lSeekTJ1	:= NGIFDBSEEK( "TJ1", TI0->TI0_SEQRES, 5 ) //TJ1_FILIAL+TJ1_SEQRES
	Local lSeekTJ5 := NGIFDBSEEK( "TJ5", TI0->TI0_SEQRES, 3 ) //TJ5_FILIAL + TJ5_SEQRES

	Default lDelete := .F.

	If lSeekTJ1 .And. !Empty( TI0->TI0_SEQRES )
		If  !lSeekTJ5
			cStatus := "4" //Não Respondida
		Else

			//---------------------------------------------------
			// Verifica se questão a ser avaliado foi respondida
			//---------------------------------------------------
			dbSelectArea( "TI5" )
			dbSetOrder( 1 ) //TI5_FILIAL+TI5_PERMIS+TI5_SEQPER+TI5_QUESTI+TI5_CODGRU+TI5_QUESTA
			dbSeek( xFilial( "TI5" ) + TI0->TI0_PERMIS + TI0->TI0_SEQPER )
			While TI5->( !Eof() ) .And. xFilial( "TI5" ) == TI5->TI5_FILIAL .And. TI0->TI0_PERMIS == TI5->TI5_PERMISS;
																			.And. TI0->TI0_SEQPER == TI5->TI5_SEQPER

				//-----------------------------------------
				// Pega o Tipo de pergunta a ser avaliado
				//-----------------------------------------
				cTipPerg := NGSeek( "TJ3", TI5->TI5_QUESTI + TI5->TI5_QUESTA, 1, "TJ3_TPLIST" ) //TJ3_FILIAL+TJ3_QUESTI+TJ3_QUESTA
				cTipGrup := NGSeek( "TJ4", TI5->TI5_CODGRU, 1, "TJ4_TIPREG" ) //TJ4_FILIAL+TJ4_CODGRU

				dbSelectArea( "TJ5" )
				dbSetOrder( 2 ) //TJ5_QUEST+TJ5_PERG+TJ5_SEQRES
				If dbSeek( xFilial( "TJ5" ) + TI5->TI5_QUESTI + TI5->TI5_QUESTA + TI0->TI0_SEQRES ) .And.;
						 ( !Empty( TJ5->TJ5_RESPCD ) .Or. !Empty( TJ5->TJ5_TEXTD ) .Or. !Empty( TJ5->TJ5_NUMERI ) )
					//Numero de Respostas
					nRespon++

					//1=Opção Exclusiva;//2=Múltiplas Opções;
					If cTipPerg == "1" .Or. cTipPerg == "2"
						lLiberado := Alltrim( TJ5->TJ5_RESPCD ) $ Alltrim( TI5->TI5_RESPOS )

					//4=Numérico;//5=Result. Formul.
					ElseIf cTipPerg == "4" .Or. cTipPerg == "5"
						cOperaTI5:= aOperaTI5[ Val( TI5->TI5_OPERAD ) ]
						//5=Result. Formul.
						// Total por colunas
						If cTipGrup == "4"
							// Query de Total por colunas
							cCato := NGSEEK( "TJ3", TI5->TI5_QUESTI + TI5->TI5_QUESTA, 1, "TJ3->TJ3_CATOT" )  // verifica se deve calcular como formula
							If cCato == "1"
								nValRespos:= fGetTotCol( TI5->TI5_QUESTI, TI0->TI0_SEQRES, TI5->TI5_QUESTA )
								lLiberado := &( cValToChar( nValRespos ) + cOperaTI5 + fTratPict( TI5->TI5_RESULT ) )
							Else
								nValRespos:= fGetForCol( TI5->TI5_QUESTI, TI0->TI0_SEQRES, TI5->TI5_QUESTA )
								lLiberado := &(  cValToChar( nValRespos ) + cOperaTI5 + fTratPict( TI5->TI5_RESULT ) )
							EndIf
						Else

							//4=Numérico;
							If cTipPerg == "4"
								lLiberado := &( "TJ5->TJ5_NUMERI" + cOperaTI5 + fTratPict( TI5->TI5_RESULT ) )
							Else
								nValRespos:= fGetTotRes( TI5->TI5_QUESTI, , TI5->TI5_QUESTA )
								lLiberado := &( cValToChar( nValRespos ) + cOperaTI5 + fTratPict( TI5->TI5_RESULT ) )
							EndIf
						EndIf
					EndIf
				EndIf

				//----------------------------
				// Verifica os Totalizadores
				//----------------------------
				// Total por Titulo Central
				If cTipGrup == "3"

					cOrdGrup := NGSeek( "TJ3", TI5->TI5_QUESTI + TI5->TI5_QUESTA, 1, "TJ3_ORDGRP" ) //TJ3_FILIAL+TJ3_QUESTI+TJ3_QUESTA
					nTotalGrp := fGetTotRes( TI5->TI5_QUESTI, cOrdGrup )

					cOperaTI5:= aOperaTI5[ Val( TI5->TI5_OPERAD ) ]
					lLiberado := &( cValToChar( nTotalGrp ) + cOperaTI5 + fTratPict( TI5->TI5_RESULT )  )

					nRespon++ //liberação
				EndIf

				If !lLiberado
					nReprovado++
					lLiberado := .T.
				EndIf

				nTotResp++
				TI5->( dbSkip() )
			End

			// Respondida Parcialmente
			If nTotResp <> nRespon .And. nTotResp > 0 .And. nRespon > 0
				cStatus := "3" // Respondida Parcialmente
			ElseIf Empty( cStatus )
				cStatus := IIf( nReprovado > 0 .And. nRespon != 0, "2", "1" )
			EndIf

		EndIf
	// Caso a chamada de analise de Status seja na exclusao, é verificado se a Permissão não contém Questões
	// Pois a lógica é ter uma sequencia quando a permissão foi reavaliada.
	// Para ser reavaliado o Status dela deverá ser 1/2 (Quando já foi realaizado a operação de liberação)
	// Então, quando analisar a verificação de status pela exclusão e não houver questões na TJ1/TJ5/TI5 é porque foi confirmado o questionamento
	// que o status deveria ser liberado.
	ElseIf lDelete
		If !NGIFDBSEEK( "TI5", + TI0->TI0_PERMIS + TI0->TI0_SEQPER, 1 )
			cStatus := "1" //Liberado
		Else
			cStatus := "4"//Não Respondida
		EndIf
	EndIf

	If !Empty( cStatus )
		RecLock( "TI0", .F. )
			TI0->TI0_STATUS = cStatus
		MsUnLock()
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetTotRes

Retorna um valor total da resposta conforme, questionario, questão e ordem
da pergunta.

@author Guilherme Benkendorf
@since 13/10/2014
@version MP11
@return  nTotal Numérico
/*/
//---------------------------------------------------------------------
Static Function fGetTotRes( cQuesti, cOrdem, cQuesta )

	Local nTotal     := 0
	Local aPerguntas := {}
	Local aArea		 := GetArea()
	Local aAreaTJ3	 := TJ3->( GetArea() )
	Local aAreaTJ5	 := TJ5->( GetArea() )
	Local cAliQry    := GetNextAlias()
	Local cQuery     := ""
	Local nX
	Local nI

	Local lTotal := Empty( cQuesta ) // Variavel lTotal indica se é feito a verifiação de totalizador ou o calculo de um campo do tipo formula

	// Query busca todos as questões do questionario
	cQuery := "SELECT TJ3_QUESTA AS QUESTA, TJ3_TPLIST AS TPLIST, TJ3_FORMUL AS FORMUL FROM " + RetSqlName( "TJ3" )
	cQuery += " WHERE TJ3_QUESTI = " + ValToSql( cQuesti )
	If lTotal
		cQuery += " AND TJ3_ORDGRP < " + ValToSql( cOrdem )
	EndIf
	cQuery += " AND TJ3_TPLIST IN ( '1','4','5' )"
	cQuery += " AND D_E_L_E_T_ <> '*' AND TJ3_FILIAL = " + ValToSql( xFilial( "TJ3" ) )
	cQuery := ChangeQuery( cQuery )

	MPSysOpenQuery( cQuery, cAliQry )

	// Depois, é estruturado o array aPergustas { Questão, Tipo da Quetão , Fórmula , Resposta da questão }
	dbSelectArea( cAliQry )
	While (cAliQry)->(!Eof())

		aAdd( aPerguntas, {	(cAliQry)->QUESTA,; // Questão
			 (cAliQry)->TPLIST,; // Tipo da Questão
			 NGSEEK( "TG0", PadR( (cAliQry)->FORMUL, TAMSX3( "TG0_CODFOR" )[1] ), 01, "TG0_FORMUL" ),;
			 fGetRespos( cQuesti, (cAliQry)->QUESTA, (cAliQry)->TPLIST ) } )  // Código da Formula
		(cAliQry)->( dbSkip() )
	End

	If Select( cAliQry ) > 0
		dbCloseArea()
	EndIf

	// Totalizado os resultados, seja por total ou unitario
	If lTotal
		//Ajusta resultado para o tipo Fórmula
		For nX := 1 To Len( aPerguntas )
			// Quando o tipo da pergunta for por fórmula calcula em fCalFormula
			If aPerguntas[ nX, 2 ] == "5"
				//Desmembra os códigos da formula em um array.
				aAuxiliar := aClone( fGetCpoFor( aPerguntas[ nX, 3 ] ) )
				For nI := 1 To Len( aAuxiliar )
					//Altera os códigos da fórmula pelos valores respondidos.
					aEval( aPerguntas, { | x | IIf( x[1] == aAuxiliar[nI],;
						 cCalcular := StrTran( aPerguntas[ nX, 3 ], "#" + aAuxiliar[nI] + "#", cValToChar( x[4] ) ), ) } )
				Next nI

				nTotal += fCalFormula( cCalcular )
			Else // Caso contrario soma o resultado
				nTotal += aPerguntas[ nX, 4 ]
			EndIf

		Next nX
	Else
		nPosic := aScan( aPerguntas, { | x | Alltrim( x[1] ) == Alltrim( cQuesta ) } )
		nTotal += IIf( nPosic > 0, fCalFormula( aPerguntas[ nPosic, 3 ], aPerguntas ), 0 )
	EndIf

	RestArea( aArea )
	RestArea( aAreaTJ3 )
	RestArea( aAreaTJ5 )

Return nTotal

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetForCol

Retorna valor numerico para o calculo de perguntas do tipo de formulas.

@author Guilherme Benkendorf
@since 13/10/2014
@version MP11
@return nResult Numérico
/*/
//---------------------------------------------------------------------
Static Function fGetForCol( cCodQuest, cSeqRes, cRespos )

	Local nResult	:= 0
	Local cFormula  := ""
	Local cCalcular	:= ""
	Local aAuxiliar := {}
	Local aValores  := {}

	cFormula := NGSeek( "TJ3", cCodQuest + cRespos, 1, "TJ3_FORMUL" )
	cCalcular:= NGSEEK( "TG0", PadR( cFormula, TAMSX3( "TG0_CODFOR" )[1] ), 01, "TG0_FORMUL" )

	aAuxiliar := aClone( fGetCpoFor( cCalcular ) )

	aEval( aAuxiliar, { | x | cCalcular := StrTran( cCalcular, "#" + x + "#", cValToChar( fGetTotCol( cCodQuest, cSeqRes, x ) ) ) } )

	nResult := fCalFormula( cCalcular )

Return nResult

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetRespos

Função auxiliar para retornar a resposta realizada conforme a pergunta.

@author Guilherme Benkendorf
@since 13/10/2014
@version MP11
@return nResult Numerico
/*/
//---------------------------------------------------------------------
Static Function fGetRespos( cCodQuest, cCodPerg, cTipoResp )

	Local nResult	:= 0
	Local cResult	:= IIf( cTipoResp == "4", "TJ5->TJ5_NUMERI", "TJ5->TJ5_RSPSO" )
	Local aArea		:= GetArea()

	dbSelectArea( "TJ5" )
	dbSetOrder( 1 )//TJ5_FILIAL+TJ5_QUEST+DTOS( TJ5_DTRESP )+TJ5_FUNC+TJ5_TAR+TJ5_CC+TJ5_AMB+TJ5_LOC+TJ5_MAT+TJ5_OSSIMU+TJ5_SEQRES+TJ5_PERG+TJ5_RESPCD+TJ5_SEQGTD
	If dbSeek( xFilial( "TJ5" ) + cCodQuest	+ DTOS( M->TJ1_DTINC ) + M->TJ1_FUNC +;
				 M->TJ1_TAR	+ M->TJ1_CC	+ M->TJ1_AMB +;
				 M->TJ1_LOC	+ M->TJ1_MAT + Space( TamSX3( "TJ5_OSSIMU" )[1] ) +;
				 TI0->TI0_SEQRES + cCodPerg )
		nResult := &( cResult )
	EndIf
	RestArea( aArea )

Return nResult

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetTotCol

Função que retorna o totalizador de questões, onde seu grupo de perguntas
é do tipo 4=Total por coluna da seção de perguntas

@author Guilherme Benkendorf
@since 13/10/2014
@version MP11
@return nResult Numérico
/*/
//---------------------------------------------------------------------
Static Function fGetTotCol( cCodQuest, cSeqRes, cRespos )

	Local nResult := 0
	Local cSeq    := ""
	Local cAliQry := GetNextAlias()
	Local cQuery  := ""
	Local cQryAll := ""
	Local cQrySeq := ""
	Local cQrySum := ""

	// Query busca todos as questões do questionario
	cQrySeq := "SELECT MAX( TJ5_SEQGTD ) AS TRB_SEQ FROM " + RetSqlName( "TJ5" )
	cQryAll += " TJ5 WHERE TJ5.TJ5_QUEST = " + ValToSql( cCodQuest )

	cQryAll += " AND TJ5.TJ5_SEQRES = " + ValToSql( cSeqRes )
	cQryAll += " AND TJ5.D_E_L_E_T_ <> '*' AND TJ5.TJ5_FILIAL = " + ValToSql( xFilial( "TJ5" ) )
	cQrySeq += cQryAll
	cQuery := ChangeQuery( cQrySeq )

	MPSysOpenQuery( cQuery, cAliQry )

	dbSelectArea( cAliQry )
	If !Empty( (cAliQry)->TRB_SEQ )
		cSeq := (cAliQry)->TRB_SEQ
	EndIf

	If Select( cAliQry ) > 0
		dbCloseArea()
	EndIf

	If !Empty( cSeq )
		cQrySum := "SELECT SUM(TJ5.TJ5_RSPSO+TJ5.TJ5_NUMERI) AS TRB_TOTAL FROM " + RetSqlName( "TJ5" )
		cQryAll += " AND TJ5.TJ5_PERG = " + ValToSql( cRespos )
		cQrySum += cQryAll
		// Quando não for calculo por fórmula
		cQrySum +=" AND TJ5.TJ5_SEQGTD <= " + ValToSql( cSeq )
		cQuery := ChangeQuery( cQrySum )

			MPSysOpenQuery( cQuery, cAliQry )

			dbSelectArea( cAliQry )
			If (cAliQry)->TRB_TOTAL > 0
				nResult := (cAliQry)->TRB_TOTAL
			EndIf

			If Select( cAliQry ) > 0
				dbCloseArea()
			EndIf
	EndIf

Return nResult

//---------------------------------------------------------------------
/*/{Protheus.doc} fCalFormula
Função para aplicar cálculo de fórmula no relatório.

@param cCalcular Indica a fórmula a ser usada para o cálculo

@author Guilherme Benkendorf
@since 13/10/2014
@return nResult Numérico
@version MP11
/*/
//---------------------------------------------------------------------
Static Function fCalFormula( cCalcular  )

	Local oError
    Local nResult     := 0
    Local nI          := 0
    Local cError      := ""
    Local bError      := { |e| oError := e, Break( e ) }
    Local bErrorBlock := ErrorBlock( bError )

    Begin Sequence

        nResult := &( cCalcular )

    Recover
        MsgStop( STR0091 + cCalcular ) // "Erro de cálculo da fórmula: "
        nResult := 0

    End Sequence

    ErrorBlock( bErrorBlock )
    cError := oError:Description

Return nResult

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetCpoFor
Função aulixiliar para, atrazendo da formula, retornar os campos que
deveram ser pegos os seus resultados.

@author Guilherme Benkendorf
@since 21/10/14
@return aCampos Array
@version MP11
/*/
//---------------------------------------------------------------------
Static Function fGetCpoFor( cFormula )

	Local nAux
	Local cAux
	Local aCampos := {}

	nAux := At( "#", cFormula )

	While nAux != 0
		cFormula := SubStr( cFormula, nAux + 1, Len( cFormula ) )
		cAux := SubStr( cFormula, 1, At( "#", cFormula ) - 1 )
		cFormula := StrTran( cFormula, cAux + "#", "" )
		If !Empty( cAux )
			aAdd( aCampos, cAux )
		EndIf
		nAux := At( "#", cFormula )
	End

Return aCampos

//---------------------------------------------------------------------
/*/{Protheus.doc} fValGrupo
Realiza operações da TRB para atualizar quando alterar o código do grupo
de perguntas.

@author Guilherme Benkendorf
@since 21/10/14
@return
@version MP11
/*/
//---------------------------------------------------------------------
Static Function fValGrupo( cAliTRB1, cAliTRB2 )

	Local nPosCodGru := GDFieldPos( "TI5_CODGRU", oGetGrp:aHeader )
	Local nAtG       := oGetGrp:nAt

	If ( "TI5_CODGRU" $ ReadVar() )
		//Ao alterar o código do grupo, é necessario excluir da TRB
		If !Empty( oGetGrp:aCols[nAtG][nPosCodGru] ) .And. oGetGrp:aCols[nAtG][nPosCodGru] != M->TI5_CODGRU
			dbSelectArea( cAliTRB1 )
			dbSetOrder( 1 ) //TRB_CODGRU
			If dbSeek( oGetGrp:aCols[nAtG][nPosCodGru] )
				RecLock( cAliTRB1, .F. )
					dbDelete()
				MsUnLock()

				dbSelectArea( cAliTRB2 )
				dbSetOrder( 1 ) //TRB_CODGRU+TRB_QUESTA
				dbSeek( oGetGrp:aCols[nAtG][nPosCodGru] )
				While ( cAliTRB2 )->( !Eof() ) .And. ( cAliTRB2 )->TRB_CODGRU == oGetGrp:aCols[nAtG][nPosCodGru]
					RecLock( cAliTRB2, .F. )
						dbDelete()
					MsUnLock()
					( cAliTRB2 )->( dbSkip() )
				End

				oGetPerg:aCols := aClone( BLANKGETD( oGetPerg:aHeader ) )
				oGetPerg:Refresh()
			EndIf
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fValQuesta
Realiza as operações de limpar outros campos da linha da getdados
quando for alterado a questão.
Também executa a validação da pergunta, conforme o tipo do código do
grupo de pergunta.

@author Guilherme Benkendorf
@since 21/10/14
@return
@version MP11
/*/
//---------------------------------------------------------------------
Static Function fValQuesta()

	Local lRet       := .T.
	Local aArea      := GetArea()
	Local nAtG       := oGetGrp:nAt
	Local nAtP       := oGetPerg:nAt
	Local nPosCodGru := GDFieldPos( "TI5_CODGRU", oGetGrp:aHeader )
	Local nPosQuesta := GDFieldPos( "TI5_QUESTA", oGetPerg:aHeader )

	Local cTipReg
	Local cCodGru

	If( "TI5_QUESTA" $ ReadVar() )
		cTipReg   := NGSeek( "TJ4", oGetGrp:aCols[nAtG][nPosCodGru], 1, "TJ4_TIPREG" )
		cCodGru   := NGSeek( "TJ3", M->TI5_QUESTI + M->TI5_QUESTA, 1, "TJ3_CODGRU" )

		If cTipReg != "2" //2=Título de Colunas;
			If cTipReg != "4"//4=Total Título de Colunas
				lRet := cCodGru == oGetGrp:aCols[nAtG][nPosCodGru]
			Else
				lRet := NGSeek( "TJ3", M->TI5_QUESTI + cOrdGpr992, 3, "TJ3_CODGRU" ) == cCodGru
			EndIf
		EndIf

		If !lRet
			Help( " ", 1, "REGNOIS" )
		EndIf

		If lRet .And. M->TI5_QUESTA != oGetPerg:aCols[nAtP][nPosQuesta]
			oGetPerg:aCols[nAtP] := aClone( BLANKGETD( oGetPerg:aHeader )[1] )
			oGetPerg:aCols[nAtP][nPosQuesta] := M->TI5_QUESTA
			oGetPerg:Refresh()
		EndIf

	EndIf

	oGetPerg:oBrowse:SetFocus()

	RestArea( aArea )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fValCpoTJ2

Faz a verificação do Centro de Custo, Função e Tarefa entre TJ2 - Questionario
e a TI0 - Permissão de Trabalho.

@author Guilherme Benkendorf
@since 08/12/14
@return
@version MP11
/*/
//---------------------------------------------------------------------
Static Function fValCpoTJ2( cCodigo, nChkCpo, lChkAll )

	Local nX
	Local lRet     := .T.
	Local cMsgCpo  := ""
	Local aCpoChk  := {	 { "TJ2_CC", "TI0_CCUSTO"   },;
						 { "TJ2_FUNC", "TI0_FUNCAO" },;
						 { "TJ2_TAR", "TI0_CODTAR"  },;
						 { "TJ2_AMB", "TI0_LOCTRA"  } }
	Local aArea    := GetArea()
	Local aAreaTJ2 := TJ2->( GetArea() )

	Default lChkAll := .F.
	Default nChkCpo := 0

	dbSelectArea( "TJ2" )
	dbSetOrder( 1 ) //TJ2_FILIAL+TJ2_QUESTI
	dbSeek( xFilial( "TJ2" ) + M->TI5_QUESTI )
	If lChkAll
		For nX := 1 To Len( aCpoChk )
			If TJ2->( &( aCpoChk[ nX, 1 ] ) ) != M->( &( aCpoChk[ nX, 2 ] ) )
				cMsgCpo += CRLF + " - " + NGRETTITULO( aCpoChk[ nX, 2 ] )
				lRet := .F.
			EndIf
		Next nX
	Else
		lRet := TJ2->( &( aCpoChk[ nChkCpo, 1 ] ) ) == cCodigo
		cMsgCpo := CRLF + " - " + NGRETTITULO( aCpoChk[ nChkCpo, 2 ] )
	EndIf


	If !lRet
		If MsgYesNo( STR0093 + cMsgCpo + Chr( 13 ) + STR0125 +; //"O(s) campo(s): "###"Diferem ao do Código do questionário informado."
					 Chr( 13 ) + Chr( 13 ) + STR0126 )          //"Deseja continuar mesmo assim?"
			lRet := .T.
		EndIf
	EndIf

	RestArea( aArea )
	RestArea( aAreaTJ2 )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fChgFormt
Função auxiliar para informar valor de resultados. Como o resultado
pode ter varios formatos por causa do campo TJ3_FORMAT. Foi criado uma
tela para informar o campo conforme o formato realizado em Questionarios

@author Guilherme Benkendorf
@since 21/10/14
@return
@version MP11
/*/
//---------------------------------------------------------------------
Static Function fChgFormt()

	Local cTpList
	Local cPicture
	Local nPosQuesta
	Local nPosResult
	Local nPosCodGru
	Local nResultado
	Local nTamCpo
	Local nAtG
	Local nAtP

	Local oDlgResult
	Local oPnlAll

	If IsInCallStack( "MDTA992" )
		nPosQuesta := GDFieldPos( "TI5_QUESTA", oGetPerg:aHeader )
		nPosResult := GDFieldPos( "TI5_RESULT", oGetPerg:aHeader )
		nPosCodGru := GDFieldPos( "TI5_CODGRU", oGetGrp:aHeader )
		nAtP       := oGetPerg:nAt
		nAtG       := oGetGrp:nAt
		nResultado := Val( M->TI5_RESULT )
		cTpList := NGSeek( "TJ3", M->TI5_QUESTI + oGetPerg:aCols[nAtP][nPosQuesta], 1, "TJ3_TPLIST" ) //TJ3_FILIAL+TJ3_QUESTI+TJ3_QUESTA
		cTipReg := NGSeek( "TJ4", oGetGrp:aCols[nAtG][nPosCodGru], 1, "TJ4_TIPREG" )
		If cTpList == "4"
			cPicture:= AllTrim( NGSeek( "TJ3", M->TI5_QUESTI + oGetPerg:aCols[nAtP][nPosQuesta], 1, "TJ3_FORMAT" ) )
			nTamCpo := Len( cPicture )
			cPicture := "@E " + cPicture

		ElseIf cTpList == "5" .Or. cTipReg $ "3#4"
			cPicture := "@E 99,999.99"
			nTamCpo := 9
		EndIf

		If !Empty( cPicture )
			oDlgResult := MSDialog():New( 00, 00, 230, 530, STR0095, , , , , , , , oMainWnd, .T. ) //"Resultado"
				oPnlAll := TPanel():New( 0, 0, , oDlgResult, , , , , , 12, 20, .F., .F. )
					oPnlAll:Align := CONTROL_ALIGN_ALLCLIENT

				TSay():New( 018, 008, { | | OemtoAnsi( NGRETTITULO( "TI5_RESULT" ) ) }, oPnlAll, , , .F., .F., .F., .T., , )
				TGet():New( 016, 047, { | u | IIf( PCount() > 0, nResultado := u, nResultado ) }, oPnlAll, 38, 008, cPicture, , , , ,;
						 	 .F., , .T., , .F., , .F., .F., , .F., .F., , "nResultado", "TI5_RESULT", , , .T. )

			oDlgResult:Activate( , , , .T., , , EnchoiceBar( oDlgResult, { || oGetPerg:aCols[nAtP][nPosResult] := cValToChar( nResultado ),;
								 oGetPerg:Refresh(), oDlgResult:End() }, { ||oDlgResult:End() }, .F. ) )
		EndIf
	EndIf

Return .F.

//---------------------------------------------------------------------
/*/{Protheus.doc} xParmPict
Função altera picture e tamanho do campo de resultado, conforme regra
preenchida no Questionário (MDTA999), tabela TJ3.

@author Guilherme Benkendorf
@since 24/10/14
@return
@version MP11
/*/
//---------------------------------------------------------------------
Static Function fTratPict( xParmPict )

	Local nCntPict	:= 0
	Local cTempPict	:= ""
	Local cPicture	:= ""

	Default xParmPict := ""

	//Verifica se o valor do parâmetro corresponde a um caracter
	If ValType( xParmPict ) != "C"
		xParmPict := cValToChar( xParmPict )
	Else
		xParmPict := AllTrim( xParmPict )
	EndIf

	//Percorre toda a Picture para Tratativa
	For nCntPict := 1 To Len( xParmPict )

		//Salva a posição atual de leitura da Picture
		cTempPict := SubStr( xParmPict, nCntPict, 1 )

		//Verifica se a posição corresponde a uma virgula ou um ponto,
		//caso seja, inverte, caso não, apenas salva a posição
		If cTempPict == "."
			cPicture += ","
		ElseIf cTempPict == ","
			cPicture += "."
		Else
			cPicture += cTempPict
		EndIf

	Next nCntPict

Return cPicture

//---------------------------------------------------------------------
/*/{Protheus.doc} faChoice
Monta array dos campos que serão exibidos na Enchoice.

@author Guilherme Benkendorf
@since 24/10/14
@return
@version MP11
@return aChoiceAux Array
/*/
//---------------------------------------------------------------------
Static Function faChoice( nOperation, lConclusao, lRevisao )

	Local aNao       := {}
	Local aChoiceAux := {}

	Default nOperation := 2
	Default lConclusao := .F.
	Default lRevisao   := .F.

	// Se for visualização ou exclusao, exibe todos os campos.
	If nOperation != 2 .And. nOperation != 5
		aAdd( aNao, "TI0_DTCONC" )
		aAdd( aNao, "TI0_HRCONC" )
		aAdd( aNao, "TI0_DINIRV" )
		aAdd( aNao, "TI0_HINIRV" )
		aAdd( aNao, "TI0_DFIMRV" )
		aAdd( aNao, "TI0_HFIMRV" )

		If !lConclusao .And. !lRevisao
			aAdd( aNao, "TI0_DTRINI" )
			aAdd( aNao, "TI0_HRRINI" )
			aAdd( aNao, "TI0_DTRFIM" )
			aAdd( aNao, "TI0_HRRFIM" )

			aChoiceAux := NGCAMPNSX3( "TI0", aNao )
		ElseIf lConclusao
			aAdd( aChoiceAux, "TI0_DTRINI" )
			aAdd( aChoiceAux, "TI0_HRRINI" )
			aAdd( aChoiceAux, "TI0_DTRFIM" )
			aAdd( aChoiceAux, "TI0_HRRFIM" )
		ElseIf lRevisao
			aAdd( aChoiceAux, "TI0_DINIRV" )
			aAdd( aChoiceAux, "TI0_HINIRV" )
			aAdd( aChoiceAux, "TI0_DFIMRV" )
			aAdd( aChoiceAux, "TI0_HFIMRV" )
		EndIf
	Else
		aChoiceAux := NGCAMPNSX3( "TI0" )
	EndIf

Return aChoiceAux

//---------------------------------------------------------------------
/*/{Protheus.doc} fChkIntRis
Verifica a integridade dos Riscos (TN0) com os valores da permissão de
trabalho (TI0)

@author Guilherme Benkendorf
@since 10/12/14
@return
@version MP11
/*/
//---------------------------------------------------------------------
Static Function fChkIntRis( cRisco, lLinhaOk, lShowMsg )

	Local lRet := .T.
	Local cMsgCCusto
	Local cMsgFuncao
	Local cMsgTarefa
	Local cMsgCodAmb
	Local cMsgDepto

	Local cMsgHelp

	Local aArea    := GetArea()
	Local aAreaTN0 := TN0->( GetArea() )

	Default cRisco   := TN0->TN0_NUMRIS
	Default lLinhaOk := .F.
	Default lShowMsg := .T.

	dbSelectArea( "TN0" )
	dbSetOrder( 1 ) //TN0_FILIAL+TN0_NUMRIS
	dbSeek( xFilial( "TN0" ) + cRisco )

	cMsgCCusto := IIf( lLinhaOk, STR0103, STR0104 ) //"Risco não corresponde ao Centro de Custo informado."###//"Centro de Custo não corresponte ao(s) do(s) risco(s)."
	cMsgFuncao := IIf( lLinhaOk, STR0105, STR0106 ) //"Risco não corresponde a Função informada."###//"Risco não corresponde ao Centro de Custo informado."
	cMsgTarefa := IIf( lLinhaOk, STR0107, STR0108 ) //"Risco não está executando a Tarefa informada."###//"Tarefa não corresponte ao(s) do(s) risco(s)."
	cMsgCodAmb := IIf( lLinhaOk, STR0109, STR0110 ) //"Risco não está executando ao Ambiente de Trabalho informado."//"Ambiente de Trabalho não corresponte ao(s) do(s) risco(s)."
	cMsgDepto  := IIf( lLinhaOk, STR0123, STR0124 ) //"Risco não corresponde ao Departamento informado."//"Departamento não corresponde ao(s) do(s) risco(s)."

	If !Empty( M->TI0_CCUSTO ) .And. IIf( Alltrim( TN0->TN0_CC ) == "*", .F., TN0->TN0_CC != M->TI0_CCUSTO )
		cMsgHelp := cMsgCCusto
		lRet := .F.
	EndIf

	If lRet .And. !Empty( M->TI0_FUNCAO ) .And. IIf( Alltrim( TN0->TN0_CODFUN ) == "*", .F., TN0->TN0_CODFUN != M->TI0_FUNCAO )
		cMsgHelp := cMsgFuncao
		lRet := .F.
	EndIf

	If lRet .And. !Empty( M->TI0_CODTAR ) .And. IIf( Alltrim( TN0->TN0_CODTAR ) == "*", .F., TN0->TN0_CODTAR != M->TI0_CODTAR )
		cMsgHelp := cMsgTarefa
		lRet := .F.
	EndIf

	If lRet .And. !Empty( M->TI0_LOCTRA ) .And. TN0->TN0_CODAMB != M->TI0_LOCTRA .And. !Empty( TN0->TN0_CODAMB )
		cMsgHelp := cMsgCodAmb
		lRet := .F.
	EndIf

	If NGCADICBASE( "TN0_DEPTO", "A", "TN0", .F. ) .And. !Empty( M->TI0_DEPTO ) .And. IIf( Alltrim( TN0->TN0_DEPTO ) == "*", .F., TN0->TN0_DEPTO != M->TI0_DEPTO )
		cMsgHelp := cMsgDepto
		lRet := .F.
	EndIf

	If !lRet .And. lShowMsg
		ShowHelpDlg( "", { cMsgHelp }, 3, { STR0102 } ) //"Informe um código correspondente."
	EndIf

	RestArea( aArea )
	RestArea( aAreaTN0 )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} GetCodSeq
Verifica a integridade dos Riscos (TN0) com os valores da permissão de
trabalho (TI0)

@author Guilherme Benkendorf
@since 10/12/14
@return
@version MP11
/*/
//---------------------------------------------------------------------
Static Function GetCodSeq()

	Local cCodigo   := ""
	Local cQry      := ""
	Local cAliasQry := GetNextAlias()

	Local aArea := GetArea()

	cQry := " SELECT MAX( TI0.TI0_SEQPER ) AS CODREV FROM " + RetSQLName( "TI0" ) + " TI0"
	cQry += " WHERE TI0.TI0_PERMIS = " + ValToSQL( TI0->TI0_PERMIS ) + " AND D_E_L_E_T_ <> '*' "

	MPSysOpenQuery( cQry, cAliasQry )

	dbSelectArea( cAliasQry )
	If ( cAliasQry )->( !Eof() )
		cCodigo := Soma1( ( cAliasQry )->CODREV )
	Else
		cCodigo := Soma1( Space( Len( TI0->TI0_SEQPER ) ) )
	EndIf

	dbSelectArea( cAliasQry )
	dbCloseArea()

	RestArea( aArea )

Return cCodigo

//---------------------------------------------------------------------
/*/{Protheus.doc} FILSXBTI0
Filtra consulta padrão TI0.

@author Guilherme Benkendorf
@param nIndConsul - Indica qual a consulta padrão está sendo chamado o filtro
@since 06/03/15
@return
@version MP11

@obs nIndConsul == 1 -> TI0SEQ
/*/
//---------------------------------------------------------------------
Function FILSXBTI0( nIndConsul )

	Local lRet := .T.

	If nIndConsul == 1 // TI0SEQ
		If IsInCallStack( "MDTR980" )
			lRet:= !Empty( MV_PAR01 ) .And. Alltrim( MV_PAR01 ) == Alltrim( TI0->TI0_PERMIS )
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT992TN0
Filtro para a Consulta Padrão TN0AVA

@type function

@source MDTA992.prw

@author Guilherme Freudenburg
@since 06/10/2016


@sample MDT992TN0( )

@return Lógico, Retorna verdadeiro quando função estiver correta
/*/
//---------------------------------------------------------------------
Function MDT992TN0()

	Local lRet   := .F.
	Local lDepto := NGCADICBASE( "TI0_DEPTO", "A", "TI0", .F. )

	If IsInCallStack( 'MDTA650' )

		lRet := TN0->TN0_MAPRIS == TAA->TAA_TIPOPL

	ElseIf IsInCallStack( 'MDTA992' )

		If !Empty( TN0->TN0_DTAVAL ) .And. Empty( TN0->TN0_DTELIM ) .And.;
			IIf( !Empty( M->TI0_CCUSTO ), ( M->TI0_CCUSTO == TN0->TN0_CC .Or. Alltrim( TN0->TN0_CC ) == "*" ), .T. ) .And. ;
			IIf( !Empty( M->TI0_FUNCAO ), ( M->TI0_FUNCAO == TN0->TN0_CODFUN .Or. Alltrim( TN0->TN0_CODFUN ) == "*" ), .T. ) .And. ;
		 	IIf( !Empty( M->TI0_CODTAR ), ( M->TI0_CODTAR == TN0->TN0_CODTAR .Or. Alltrim( TN0->TN0_CODTAR ) == "*" ), .T. ) .And. ;
		 	IIf( !Empty( M->TI0_LOCTRA ), ( M->TI0_LOCTRA == TN0->TN0_CODAMB .Or. Empty( TN0->TN0_CODAMB ) ), .T. ) .And. ;
		 	IIf( lDepto, IIf( !Empty( M->TI0_DEPTO ), ( M->TI0_DEPTO == TN0->TN0_DEPTO .Or. Alltrim( TN0->TN0_DEPTO ) == "*" ), .T. ), .T. )

			lRet := .T.

		EndIf
	Else
		lRet := .T.
	EndIf

Return lRet