#INCLUDE "MDTA853.ch"
#Include "Protheus.ch"
#Include "DbTree.ch"

#DEFINE _nVERSAO 2 //Versao do fonte

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA853
Programa para cadastrar Perigos

@return

@sample
MDTA853()

@author Jackson Machado
@since 22/03/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDTA853()

	//-----------------------------------------------------
	// Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	//-----------------------------------------------------
	Local aNGBEGINPRM := NGBEGINPRM( _nVERSAO , , { "TG1" , { "TG5" , "TG9" , "TGB" } } )


	Private aRotina := MenuDef()

	Private cCadastro := OemtoAnsi( STR0001 ) //"Perigos"
	Private aChkDel := {}, bNgGrava

	If !AliasInDic( "TG0" )
		If NGINCOMPDIC("UPDMDT88","THXDPI")
			//-----------------------------------------------------
			// Devolve variaveis armazenadas (NGRIGHTCLICK)
			//-----------------------------------------------------
			NGRETURNPRM( aNGBEGINPRM )
			Return .F.
		EndIf
	EndIf

	If !ChkOHSAS()
		//-----------------------------------------------------
		// Devolve variaveis armazenadas (NGRIGHTCLICK)
		//-----------------------------------------------------
		NGRETURNPRM( aNGBEGINPRM )
		Return .F.
	EndIf

	aCHKDEL := {	{ "TG1->TG1_CODPER" , "TG6" , 4 } , ;
					{ "TG1->TG1_CODPER" , "TGD" , 1 } }

	DbSelectArea( "TG1" )
	DbSetOrder( 1 )
	mBrowse( 6 , 1 , 22 , 75 , "TG1" )


	//-----------------------------------------------------
	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	//-----------------------------------------------------
	NGRETURNPRM( aNGBEGINPRM )

Return .t.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT853PRO
Programa para cadastrar Aspectos/Local/Avaliacao Padrao

@return Lógico - Retorna verdadeiro caso correta gravação

@sample
MDT853PRO()

@author Jackson Machado
@since 22/03/2013
/*/
//---------------------------------------------------------------------
Function MDT853PRO( cAlias , nRecno , nOpcx , xPar01 )

	Local oPnlBEst, cBEst, oBEst, oPnlTAva, oTAva, cTAva, oPnlTObs, oTObs, cTObs
	Local oDlg, oMenu, oTempVis1, oTempTRBSGA, nIdx
	Local lOk				:= .F.

	Local cLocPer			:= ""
	Local cTitulo			:= cCadastro  // Titulo da janela

	Local oFontB			:= TFont():New( "Arial" , , 14 , , .T. )

	Local lGetd				:= .T.
	Local nControl			:= 0
	Local nOK				:= 0

	Local aNoFields			:= {}
	Local aPages			:= {}
	Local aTitles			:= {}
	Local aTRB      		:= {}

	Local cTudoOk			:=	"AllwaysTrue()"
	Local cLinhaOk			:=	"MDT853LIN"

	Local aSize				:= MsAdvSize()
	Local nLeft				:= 0

	Local aOldRot			:= If( Type( "aRotina" ) == "A" , aClone( aRotina ) , {} )

	Private cIndVisx1, cIndVis1
	Private oEnc01, oGet01, oGet, aHeader, nItens, oMark, oTempVisx

	Private nTotal			:= 0
	Private n				:= 1
	Private aLocal			:= {}

	Private cAval			:= ""
	Private aSvATela		:= {}
	Private aSvAGets		:= {}
	Private aTela     		:= {}
	Private aCols1    		:= {}
	Private aCols     		:= {}
	Private aMark			:= {}
	Private lInverte		:= .F.
	Private lQuery			:= .T.

	Private aSvHeader 		:= { {},{},{},{} }
	Private aSvCols   		:= { {},{},{},{} }
	Private aVETINR 		:= {}
	Private cMarca			:= GetMark()
	Private cBMP			:= "1"

	Private M->TG1_CODPER 	:= ""

	//Variável de TRB
	Private cTRBSGA
	Private cTRBA			:= GetNextAlias()
	Private cTRBX   		:= GetNextAlias()

	Default xPar01			:= ""

	If ValType( xPar01 ) == "C"
		cLocPer := xPar01
	EndIf

	//Define um aRotina novo
	aRotina := MenuDef()

	If !( Alltrim( GetTheme() ) == "FLAT" ) .And. !SetMdiChild()
		aSize[ 7 ]	:= aSize[ 7 ]-50
		aSize[ 6 ]	:= aSize[ 6 ]-30
		aSize[ 5 ]	:= aSize[ 5 ]-14
		nLeft		:= 5
	EndIf

	dbSelectArea( "TAF" )
	TAF->( dbSeek( xFilial( "TAF" ) + "001" ) )

	If !MDT853GET( nOpcx )
		If Len( aOldRot ) > 0
			aRotina := aClone( aOldRot )
		EndIf
		Return .F.
	EndIf

	aTRB := SGATRBEST(.T.)//Define estrutura do TRB
	cTRBSGA := aTRB[3]
	oTempTRBSGA := FWTemporaryTable():New( cTRBSGA, aTRB[1] )
	For nIdx := 1 To Len( aTRB[2] )
		oTempTRBSGA:AddIndex( RETASC( cValToChar( nIdx ) , 1 , .T. ), aTRB[2,nIdx] )
	Next nIdx
	oTempTRBSGA:Create()

	aDBF := {}
	aAdd( aDBF , { "TRB_CODAVA" , "C" , 03 , 0 } )
	aAdd( aDBF , { "TRB_CODIGO" , "C" , 03 , 0 } )
	aAdd( aDBF , { "TRB_PESO"   , "N" , 03 , 0 } )
	aAdd( aDBF , { "TRB_RESULT" , "N" , 03 , 0 } )

	oTempVis1 := FWTemporaryTable():New( cTRBA, aDBF )
	oTempVis1:AddIndex( "1", {"TRB_CODAVA","TRB_CODIGO"} )
	oTempVis1:Create()

	Aadd( aTitles, OemToAnsi( STR0002 ) ) //"Perigo x Localização"
	Aadd( aPages, "Header 2" )
	nControl++

	Aadd( aTitles, OemToAnsi( STR0003 ) ) //"Perigo x Avaliação"
	Aadd( aPages, "Header 3" )
	nControl++

	Aadd( aTitles , OemToAnsi( STR0004 ) ) //"Perigo x Requisitos"
	Aadd( aPages , "Header 4" )
	nControl++

	Define MsDialog oDlg From aSize[ 7 ] , nLeft To aSize[ 6 ] , aSize[ 5 ] Title cTitulo Pixel

	oPanel2 := TPanel():New( 0 , 0 , Nil , oDlg , Nil , .T. , .F. , Nil , Nil , 0 , 0 , .T. , .F. )
	oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

	oFolder := TFolder():New( 1 , 0 , aTitles , aPages , oPanel2 , , , , .F. , .F. , 320 , 200 , )
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT
	oFolder:aDialogs[ 1 ]:oFont := oDlg:oFont
	oFolder:aDialogs[ 2 ]:oFont := oDlg:oFont
	oFolder:aDialogs[ 3 ]:oFont := oDlg:oFont

	aTela := {}
	aGets := {}

	dbselectarea( "TG1" )
	RegToMemory( "TG1" , ( nOpcx == 3 ) )

	oEnc01:= MsMGet():New( "TG1" , nRecno , nOpcx , , , , , { 0 , 0 , 130 , 0 } , , , , , , oPanel2 , , , .F. , "aSvATela" )
	oEnc01:oBox:Align := CONTROL_ALIGN_TOP
	oEnc01:oBox:bGotFocus := { | | NgEntraEnc( "TG1" ) }

	aSvATela := aClone( aTela )
	aSvAGets := aClone( aGets )

	// Markbrowse
	If nOpcx == 5
		MDT853GTRB( nOpcx )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Folder 01                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//Carrega todos niveis selecionados
	If !Inclui
		dbSelectArea( "TG9" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "TG9" ) + M->TG1_CODPER + "001" )
			While !Eof() .and. xFilial( "TG9" ) + M->TG1_CODPER == TG9->TG9_FILIAl + TG9->TG9_CODPER
				If aScan( aLocal ,{ | x | Trim( Upper( x[ 1 ] ) ) == TG9->TG9_CODNIV } ) == 0
					aAdd( aLocal , { TG9->TG9_CODNIV , .T. } )
				Endif
				dbSelectArea( "TG9" )
				dbSkip()
			End
		Endif
	Else
		If cLocPer <> ""
			aAdd( aLocal , { cLocPer , .T. } )
		EndIf
	Endif
	aMarcado := aClone( aLocal )

	oTree := DbTree():New( 005 , 022 , 150 , 302 , oFolder:aDialogs[ 1 ] , , , .T. )
	oTree:Align    := CONTROL_ALIGN_ALLCLIENT

	MDT853TREE( 1 , aMarcado )

	If Str( nOpcx , 1 ) $ "2/5"
		oTree:bChange := { | | MDT853TREE( 2 ) }
		lGetd := .f.
	ElseIf !Empty( cLocPer ) .Or. IsInCallStack("MNTA902")
		oTree:bChange := { | | MDT853TREE( 2 ) }
	Else
		oTree:bChange	  := { | | MDT853TREE( 2 ) }
		oTree:blDblClick  := { | | MDT853CHBMP() }
	EndIf

	oPnlBEst := TPanel():New( 900 , 900 , , oFolder:aDialogs[ 1 ] , , , , , RGB( 67 , 70 , 87 ) , 200 , 200 , .F. , .F. )
	oPnlBEst:Align   := CONTROL_ALIGN_TOP
	oPnlBEst:nHeight := 25

	cBEst := STR0005 //"Escolha a área clicando duas vezes sobre a pasta"
	@ 002 , 015 SAY oBEst VAR cBEst SIZE 200 , 20 Font oFontB Color RGB( 255 , 255 , 255 ) OF oPnlBEst PIXEL

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Folder 02                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oSplitter2 := tSplitter():New( 0 , 0 , oFolder:aDialogs[ 2 ] , 100 , 100 , 1 )
	oSplitter2:Align := CONTROL_ALIGN_ALLCLIENT

	oPanel3 := TPanel():New( 01 , 01 , , oSplitter2 , , , , , , 10 , 10 , .F. , .F. )
	oPanel3:Align := CONTROL_ALIGN_ALLCLIENT

	oPanel4 := TPanel():New( 01 , 01 , , oSplitter2 , , , , , , 10 , 10 , .F. , .F. )
	oPanel4:Align := CONTROL_ALIGN_ALLCLIENT

	oPnlTAva := TPanel():New( 900 , 900 , , oPanel3 , , , , , RGB( 67 , 70 , 87 ) , 200 , 200 , .F. , .F. )
	oPnlTAva:Align   := CONTROL_ALIGN_TOP
	oPnlTAva:nHeight := 25

	cTAva := STR0006 //"Avaliações"
	@ 002,015 SAY oTAva VAR cTAva SIZE 200, 20 Font oFontB Color RGB( 255 , 255 , 255 ) OF oPnlTAva PIXEL

	oPnlTObs := TPanel():New( 900 , 900 , , oPanel4 , , , , , RGB( 67 , 70 , 87 ) , 200 , 200 , .F. , .F. )
	oPnlTObs:Align   := CONTROL_ALIGN_TOP
	oPnlTObs:nHeight := 25

	cTObs := STR0007 //"Opções"
	@ 002,015 SAY oTObs VAR cTObs SIZE 200 , 20 Font oFontB Color RGB( 255 , 255 , 255 ) OF oPnlTObs PIXEL

	@ 25,008 ListBox oGet Fields aCols1[ n ][ 1 ] , aCols1[ n ][ 2 ] ;
		Headers STR0008 , STR0009 Of oPanel3 Size 316 , 63 Pixel ; //"Avaliação"###"Descrição"
		On Change ( MDT853LOK( n , nOpcx ) )

	oGet:bGotop    := { | | n := 1 }
	oGet:bGoBottom := { | | n := Eval( oGet:bLogicLen ) }

	oGet:bSkip     := { | nWant, nOld | nOld := n , n += nWant,;
		n := Max( 1, Min( n, Eval( oGet:bLogicLen ) ) ) , ;
		n - nOld }

	oGet:bLogicLen := { | | Len( aCols1 ) }
	oGet:cAlias    := "Array"
	oGet:Align     := CONTROL_ALIGN_ALLCLIENT

	MDT853MRK( , , nOpcx , .T. )

	oMark := MsSelect():New( cTRBX , "TRB_OK" , , aMark , @lInverte , @cMarca , { 110 , 8 , 173 , 324 } , , , oPanel4 )
	oMark:oBrowse:lHasMark    := .T.
	oMark:oBrowse:lCanAllMark := .F.
	oMark:oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT
	oMark:bMark := { | | MDT853VMK( cMarca , oGet ) }

	If Str(nOpcx,1) $ "2/5"
		oMark:oBrowse:lReadOnly := .t.
	EndIf
	aSvCols := aClone( aCols1 )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Folder 03                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd( aNoFields , "TGB_CODPER" )
	cQuery := " SELECT * FROM " + RetSqlName( "TGB" ) + " TGB "
	cQuery += " WHERE TGB.TGB_FILIAL = " + ValToSql( xFilial( "TGB" ) ) + " AND "
	cQuery += " TGB.TGB_CODPER = " + ValToSql( M->TG1_CODPER ) + " AND TGB.D_E_L_E_T_ <> '*' "
	FillGetDados( nOpcx , "TGB" , 1 , xFilial( "TGB" ) + M->TG1_CODPER , ;
				{ | | "TGB->TGB_FILIAL + TGB->TGB_CODPER" } , { | | .T. } , aNoFields , , , cQuery )

	If Len( aCols ) == 0 .Or. nOpcx == 3
		aCols := BlankGetd( aHeader )
	EndIf

	n      := Len( aCols )
	oGet01 := MsGetDados():New( 005 , 022 , 150 , 302 , nOpcx , cLinhaOk+"('TGB')" , cTudoOk , "" , lGetd , , 1 , , , , , , , oFolder:aDialogs[ 3 ] )
	oGet01:oBrowse:Default()
	oGet01:oBrowse:Refresh()
	oGet01:oBrowse:bGotFocus  := { | | x := n , n := 1 , oGet01:oBrowse:Refresh() }
	oGet01:oBrowse:bLostFocus := { | | n := x }
	oGet01:oBrowse:Align      := CONTROL_ALIGN_ALLCLIENT

	If Len( aCols1 ) == 0 .Or. ( Len( aCols1 ) == 1 .And. Empty( aCols1[ 1 , 1 ] ) )
		oFolder:aDialogs[ 2 ]:Disable()
	EndIf

	NGPOPUP( aSMenu , @oMenu , oPanel2 )
	oPanel2:bRClicked:= { | o , x , y | oMenu:Activate( x , y , oPanel2 ) }
	Activate MsDialog oDlg On Init ( EnchoiceBar( oDlg , { | | lOk:=.T. , ;
											If( MDT853OBR( nOpcx ) , oDlg:End() , lOk := .f. ) } , ;
											{ | | lOk := .f. , oDlg:End() } ) )

	//Deleta o arquivo temporario fisicamente
	oTempTRBSGA:Delete()
	oTempVis1:Delete()
	oTempVisx:Delete()

	If Len( aOldRot ) > 0
		aRotina := aClone( aOldRot )
	EndIf

Return lOk

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT853CHBMP
Altera o folder ao clicar

@return

@sample
MDT853CHBMP()

@author Jackson Machado
@since 22/03/2013
/*/
//---------------------------------------------------------------------
Function MDT853CHBMP()

	Local aAreaTG6 := {}
	Local aClrNiv := { "Folder10" , "Folder11" }

	If oTree:IsEmpty()
		Return .F.
	EndIf

	dbSelectArea( oTree:cArqTree )

	If SubStr( oTree:GetCargo() , 7 , 1 ) = "2"
		If SubStr( oTree:GetCargo() , 4 , 3 ) == "FUN"
			aClrNiv := { "Folder14" , "Folder15" }
		ElseIf SubStr( oTree:GetCargo() , 4 , 3 ) == "TAR"
			aClrNiv := { "Folder12" , "Folder13" }
		EndIf

		If Type( "M->TG1_CODPER" ) != "U"
			dbSelectArea( "TG6" )
			dbSetOrder( 4 )
			dbSeek( xFilial( "TG6" ) + M->TG1_CODPER )
			While !Eof() .And. TG6->TG6_FILIAL == xFilial( "TG6" ) .And. TG6->TG6_CODPER == M->TG1_CODPER
				If TG6->TG6_CODNIV == SubStr( oTree:GetCargo() , 1 , 3 )
					MsgStop( STR0010 + AllTrim( TG6->TG6_ORDEM ) , STR0011 ) //"Este item não pode ser desmarcado pois está relacionado ao Desempenho: "###"Atenção"
					Return .F.
				EndIf

				dbSelectArea( "TG6" )
				dbSetOrder( 4 )
				dbSkip()
			EndDo
		EndIf

		If !Sg100NvAtv( Substr( oTree:GetCargo() , 1 , 3 ) , cCodest )
			aClrNiv := { "cadeado" , "cadeado" }
		Endif

		oTree:ChangeBmp( aClrNiv[1] , aClrNiv[2] )

		(oTree:cArqTree)->T_CARGO := SubStr( oTree:getCargo() , 1 , 6 ) + "1"
		nPos := aScan( aLocal , { | x | x[ 1 ] == SubStr( oTree:GetCargo() , 1 , 3 ) } )
		If nPos > 0
			aLocal[ nPos , 2 ] := .F.
		Else
			aAdd( aLocal , { SubStr( oTree:GetCargo() , 1 , 3 ) , .F. } )
		EndIf
	Else
		oTree:ChangeBmp( "Folder7" , "Folder8" )
		(oTree:cArqTree)->T_CARGO := SubStr( oTree:getCargo() , 1 , 6 ) + "2"
		nPos := aScan( aLocal , { | x | x[ 1 ] == SubStr( oTree:GetCargo() , 1 , 3 ) } )

		If nPos > 0
			aLocal[ nPos , 2 ] := .T.
		Else
			aAdd( aLocal , { SubStr( oTree:GetCargo() , 1 , 3 ) , .T. } )
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT853GET
Altera o folder ao clicar

@return

@param nOpcx   - Opção de seleção
@param lImpact - Verifica se valida os Danos

@sample
MDT853GET()

@author Jackson Machado
@since 22/03/2013
/*/
//---------------------------------------------------------------------
Function MDT853GET( nOpcx , lDanos )

	Local nCnt  := 0
	Local nPeso := 0

	Local nDanos := 0

	Default lDanos := .F.

	DbSelectArea( "TG2" )
	DbSetOrder(1)
	DbSeek( xFilial( "TG2" ) )
	While TG2->( !Eof() ) .and. xFilial( "TG2" ) == TG2->TG2_FILIAL

		If nCnt == 1
			cAval := TG2->TG2_CODAVA
		EndIf

		If lDanos .And. TG2->TG2_PESO > 0
			nDanos++
		EndIf

		If !lDanos .And. TG2->TG2_TIPO <> "1"
			Dbskip()
			Loop
		EndIf

		If nOpcx <> 3
			DbSelectArea( "TG5" )
			DbSetOrder( 1 )
			If DbSeek( xFilial( "TG5" ) + M->TG1_CODPER + TG2->TG2_CODAVA )
				nPeso := TG5->TG5_RESULT
			EndIf
		EndIf
		nCnt++
		If TG2->TG2_PESO <= 0
			aAdd( aCols1 , { TG2->TG2_CODAVA , TG2->TG2_DESCRI } )
		EndIf

		DbSelectArea( "TG2" )
		DbSkip()
	EndDo

	If nCnt == 0 .Or. ( lDanos .And. nDanos == 0 )
		Help( " " , 1 , STR0011 , , STR0012 , 3 , 1 ) //"ATENÇÃO"###"Não é possível realizar avaliação sem critérios cadastrados."
		Return .F.
	EndIf

	If Len( aCols1 ) == 0
		aAdd( aCols1 , { Space( Len( TG2->TG2_CODAVA ) ) , Space( Len( TG2->TG2_DESCRI ) ) } )
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT853MRK
Monta um MarkBrowse com as respostas das avaliacoes.

@return

@param aCodigo	- Array contendo os códigos das opções
@param cCodAva	- Codigo da Avaliação
@param nOpc		- Opcao de selecao
@param lPrim	- Indica se eh a primeira montagem

@sample
MDT853GET()

@author Jackson Machado
@since 22/03/2013
/*/
//---------------------------------------------------------------------
Function MDT853MRK( aCodigo , cCodAva , nOpc , lPrim )

	Local oDlgMar
	Local nOpcx  := 2
	Local cCheck := ""
	Local vIndVis1
	Local aDbf   := {}

	aAdd( aDBF , { "TRB_OK"       , "C" , 02 , 0 } )
	aAdd( aDBF , { "TRB_CODAVA"   , "C" , 03 , 0 } )
	aAdd( aDBF , { "TRB_CODIGO"   , "C" , 03 , 0 } )
	aAdd( aDBF , { "TRB_DESCRI"   , "C" , 40 , 0 } )
	aAdd( aDBF , { "TRB_PESO"     , "N" , 03 , 0 } )

	oTempVisx := FWTemporaryTable():New( cTRBX, aDBF )
	oTempVisx:AddIndex( "1", {"TRB_CODIGO","TRB_CODAVA"} )
	oTempVisx:Create()

	aAdd( aMark , { "TRB_OK"     , NIL , " "     , } )
	aAdd( aMark , { "TRB_CODIGO" , NIL , STR0013 , } ) //"Código"
	aAdd( aMark , { "TRB_DESCRI" , NIL , STR0014 , } )  //"Respostas"

	DbSelectArea( "TG3" )
	DbSetOrder( 1 )
	DbSeek( xFilial( "TG3" ) + cAval )
	Do While !Eof() .and. xFilial( "TG3" ) == TG3->TG3_FILIAL .and.;
		TG3->TG3_CODAVA == cAval

		cCheck := ""

		dbSelectArea( cTRBA )
		dbSetOrder( 1 )
		If dbSeek( cAval )
			If dbSeek( cAval + TG3->TG3_CODOPC )
				cCheck := cMarca
			Else
				cCheck := ""
			EndIf
			RecLock( cTRBX , .T. )
			( cTRBX )->TRB_OK      := cCheck
			( cTRBX )->TRB_CODAVA  := TG3->TG3_CODAVA
			( cTRBX )->TRB_CODIGO  := TG3->TG3_CODOPC
			( cTRBX )->TRB_DESCRI  := TG3->TG3_OPCAO
			MsUnLock( cTRBX )
			DbSelectArea( "TG3" )
			DbSkip()
			Loop
		EndIf

		DbSelectArea( cTRBX )
		DbSetOrder( 1 )
		If !DbSeek( TG3->TG3_CODOPC )
			If aCodigo <> Nil
				nPOS := aScan( aCodigo , { | x | x[ 1 ] == TG3->TG3_CODOPC } )
				If nPos > 0 .And. cCodAva == TG3->TG3_CODAVA
					cCheck := cMarca
				Else
					cCheck := ""
				EndIf
			Else
				cCheck := ""
			EndIf
			RecLock( cTRBX , .T. )
			( cTRBX )->TRB_OK      := cCheck
			( cTRBX )->TRB_CODAVA  := TG3->TG3_CODAVA
			( cTRBX )->TRB_CODIGO  := TG3->TG3_CODOPC
			( cTRBX )->TRB_DESCRI  := TG3->TG3_OPCAO
			MsUnLock( cTRBX )
		EndIf

		DbSelectArea( "TG3" )
		DbSkip()
	EndDo

	If nOpc <> 3 .and. lPrim <> Nil
		DbSelectArea( "TG5" )
		DbSetOrder( 1 )
		DbSeek( xFilial( "TG5" ) + M->TG1_CODPER )
		Do While !Eof() .and. TG5->TG5_FILIAL == xFilial( "TG5" ) .and.;
			TG5->TG5_CODPER == M->TG1_CODPER

			DbSelectArea( cTRBX )
			DbSetOrder( 1 )
			If DbSeek( TG5->TG5_CODOPC + TG5->TG5_CODAVA )
				RecLock( cTRBX , .F. )
				( cTRBX )->TRB_OK := cMarca
				MsUnLock( cTRBX )
			EndIf
			DbSelectArea( "TG5" )
			DbSkip()
		EndDo
	EndIf

	( cTRBX )->( DbGoTop() )

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT853LOK
LinhaOk do ListBox

@return Sempre verdadeiro

@param x		- Linha posicionada
@param nOpcx	- Opcao de selecao


@sample
MDT853LOK( 1 , 3 )

@author Jackson Machado
@since 22/03/2013
/*/
//---------------------------------------------------------------------
Function MDT853LOK( x , nOpcx )

	Local aCodigo := {}

	MDT853GTRB()
	cAval:= aCols1[ x , 1 ]
	If nOpcx == 3
		DbSelectArea( cTRBA )
		DbSetOrder( 1 )
		DbSeek( cAval )
		While !Eof() .And. ( cTRBA )->TRB_CODAVA == cAval
			aAdd( aCodigo , { ( cTRBA )->TRB_CODIGO } )
			dbSkip()
		End
	Else
		DbSelectArea( cTRBA )
		DbSetOrder( 1 )
		If DbSeek( cAval )
			While !Eof() .And. ( cTRBA )->TRB_CODAVA == cAval
				aAdd( aCodigo , { ( cTRBA )->TRB_CODIGO } )
				dbSkip()
			End
		Else
			DbSelectArea( "TG5" )
			DbSetOrder( 1 )
			If DbSeek( xFilial( "TG5" ) + M->TG1_CODPER + cAval )
				While !Eof() .And. TG5->TG5_FILIAL == xFilial( "TG5" ) .And. TG5->TG5_CODPER == M->TG1_CODPER .And. ;
					TG5->TG5_CODAVA == cAval
					aAdd( aCodigo , { TG5->TG5_CODOPC } )
					dbSkip()
				End
			EndIf
		EndIf
	EndIf

	oTempVisx:Delete()

	MDT853MRK( aCodigo , cAval )
	oMark:oBrowse:Refresh()

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT853VMK
Atualiza o total do resultado de acordo com a opcao escolhida

@return Sempre verdadeiro

@param cMarca	- Marcacao do MarkBrowse
@param oGet		- Objeto do Get


@sample
MDT853VMK( "X" , oGet )

@author Jackson Machado
@since 22/03/2013
/*/
//---------------------------------------------------------------------
Function MDT853VMK( cMarca , oGet )

	Local cFieldMarca := "TRB_OK"

	IsMark( cFieldMarca , cMarca , lInverte )
	nRecno := Recno()

	MDT853GTRB()

	dbGoTo( nRecno )
	oGet:Refresh()

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT853GTRB
Grava TRB com as informacoes do MarkBrowse

@return Sempre verdadeiro

@param nOpcx	- Opção de Seleção

@sample
MDT853GTRB( 3 )

@author Jackson Machado
@since 22/03/2013
/*/
//---------------------------------------------------------------------
Function MDT853GTRB( nOpcx )

	If nOpcx <> 5 .And. nOpcx <> 3
		dbSelectArea( cTRBX )
		dbGotop()
		Do While !Eof()
			If !Empty( ( cTRBX )->TRB_OK )
				dbSelectArea( cTRBA )
				dbSetOrder( 1 )
				If !dbSeek( ( cTRBX )->TRB_CODAVA + ( cTRBX )->TRB_CODIGO )
					RecLock( cTRBA , .T. )
					( cTRBA )->TRB_CODAVA := ( cTRBX )->TRB_CODAVA
					( cTRBA )->TRB_CODIGO := ( cTRBX )->TRB_CODIGO
					MsUnLock( cTRBA )
				EndIf
			Else
				dbSelectArea( cTRBA )
				dbSetOrder(1)
				If dbSeek( ( cTRBX )->TRB_CODAVA + ( cTRBX )->TRB_CODIGO )
					RecLock( cTRBA , .F. )
					dbDelete()
					MsUnLock( cTRBA )
				EndIf
			EndIf
			dbSelectArea( cTRBX )
			dbSkip()
		EndDo
	Else
		DbSelectArea( "TG5" )
		DbSetOrder( 1 )
		DbSeek( xFilial( "TG5" ) + M->TG1_CODPER )
		Do While !Eof() .and. TG5->TG5_CODPER == M->TG1_CODPER

			DbSelectArea( cTRBA )
			DbSetOrder( 1 )
			If !DbSeek( TG5->TG5_CODAVA + TG5->TG5_CODOPC )
				RecLock( cTRBA , .T. )
				( cTRBA )->TRB_CODAVA := TG5->TG5_CODAVA
				( cTRBA )->TRB_CODIGO := TG5->TG5_CODAVA
				MsUnLock( cTRBA )
			EndIf
			DbSelectArea( "TG5" )
			DbSkip()
		EndDo

	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT853OBR
Faz a validação dos campos OBRIGATORIOS

@return Retorna verdadeiro quando todos os campos forem preenchidos corretamente

@param nOpcx	- Opção de Seleção

@sample
MDT853OBR( 3 )

@author Jackson Machado
@since 22/03/2013
/*/
//---------------------------------------------------------------------
Function MDT853OBR( nOpcx )

	Local i , x := 0
	Local aOldArea := GetArea() // Guarda variaveis de alias e indice

	If !Obrigatorio( aGets , aTela )
		Return .F.
	Endif

	If !MDT853LIN( "TGB" , .T. )
		Return .F.
	EndIf

	If nOpcx == 3 .Or. nOpcx == 4
		If Len( aLocal ) == 0
			Help( " " , 1 , STR0011 , , STR0015 , 3 , 1 ) //"ATENÇÃO"###"A seleção de pelo menos uma localização é obrigatória."
			Return .f.
		Else
			For i:= 1 To Len( aLocal )
				If aLocal[ i , 2 ]
					x++
				EndIf
			Next
		EndIf
		If x == 0
			Help( " " , 1 , STR0011 , , STR0015 , 3 , 1 ) //"ATENÇÃO"###"A seleção de pelo menos uma localização é obrigatória."
			Return .F.
		EndIf
	Elseif nOpcx == 5
		If !NGVALSX9( "TG1" , { "TG5" , "TG9" , "TGB" } , .T. )
			Return .F.
		Endif
	EndIf
	MDT853GRV( nOpcx )

	RestArea( aOldArea )

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT853GRV
Grava as informacoes

@return Retorna verdadeiro quando todos os campos foram gravados corretamente

@param nOpcx	- Opção de Seleção

@sample
MDT853GRV( 3 )

@author Jackson Machado
@since 22/03/2013
/*/
//---------------------------------------------------------------------
Function MDT853GRV( nOpcx )

	Local i , j
	Local nQtd 		:= 0
	Local nPosCod 	:= 0
	Local nOrd		:= 0
	Local cKey		:= ""
	Local cWhile	:= ""

	//Valida arquivos relacionados na exclusao
	If nOpcx == 5
		aArea := GetArea()
		lDEL  := .t.
		For i := 1 to Len( aChkDel )
			dbSelectArea( aChkDel[ i , 2 ] )
			OldInd := IndexOrd()
			dbSetOrder( aChkDel[ i , 3 ] )
			cKEY := aCHKDEL[ i , 1 ]
			lDEL := !( dbSeek( xFilial() + &cKEY. ) )
			dbSetOrder( OldInd )
			If !lDEL
				cError := AllTrim( FwX2Nome( aCHKDEL[i, 2]) ) + " ("+ aCHKDEL[i, 2]+")"
				HELP( " " , 1 , "MA10SC" , , cError , 5 , 1 )
				RestArea( aArea )
				Return .F.
			Endif
		Next
		RestArea( aArea )
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Manipula a tabela TG1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbSelectArea( "TG1" )
	DbSetOrder( 1 )
	If DbSeek( xFilial( "TG1" ) + M->TG1_CODPER )
		RecLock( "TG1" , .F. )
	Else
		RecLock( "TG1" , .T. )
	EndIf

	If nOpcx <> 5
		TG1->TG1_FILIAL := xFilial( "TG1" )
		For i := 1 To FCount()
			If "_FILIAL" $ Alltrim(FieldName(i))
				Loop
			EndIf
			x  := "M->" + FieldName(i)
			y  := "TG1->" + FieldName(i)
			&y := &x
		Next i
	Else
		DbDelete()
	EndIf

	MsUnLock( "TG1" )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Manipula a tabela TG9³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If nOpcx == 5
		TG9->( dbSetOrder( 1 ) )
		If TG9->( dbSeek( xFilial( "TG9" ) + M->TG1_CODPER + "001" ) )
			While TG9->( !Eof() ) .and. xFilial( "TG9" ) == TG9->TG9_FILIAL .and.;
				TG9->TG9_CODPER == M->TG1_CODPER  .and.;
				TG9->TG9_CODEST == "001"
				RecLock( "TG9" , .F. )
				DbDelete()
				MsUnLock( "TG9" )
				TG9->( dbSkip() )
			End
		EndIf
	Else

		For i:= 1 To Len( aLocal )

			DbSelectArea( cTRBSGA )
			DbSetOrder( 2 )
			If DbSeek( "001" + aLocal[ i , 1 ] )
				DbSelectArea( "TG9" )
				DbSetOrder( 1 )
				If !DbSeek( xFilial( "TG9" ) + M->TG1_CODPER + "001" + aLocal[ i , 1 ] )
					If aLocal[ i , 2 ]
						RecLock( "TG9" , .T. )
						TG9->TG9_FILIAL := xFilial( "TG9" )
						TG9->TG9_CODPER := M->TG1_CODPER
						TG9->TG9_CODEST := "001"
						TG9->TG9_CODNIV := aLocal[ i , 1 ]
						TG9->TG9_NIVSUP := ( cTRBSGA )->NIVSUP
						MsUnLock( "TG9" )
					EndIf
				Else
					If !aLocal[ i , 2 ]
						RecLock( "TG9" , .F. )
						DbDelete()
						MsUnLock( "TG9" )
					Else
						RecLock( "TG9" , .F. )
						TG9->TG9_FILIAL := xFilial( "TG9" )
						TG9->TG9_CODPER := M->TG1_CODPER
						TG9->TG9_CODEST := "001"
						TG9->TG9_CODNIV := aLocal[ i , 1 ]
						TG9->TG9_NIVSUP := ( cTRBSGA )->NIVSUP
						MsUnLock( "TG9" )
					EndIf
				EndIf
			Endif
		Next
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Manipula a tabela TG5³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbSelectArea( "TG5" )
	DbSetOrder( 1 )
	DbGoTop()
	While TG5->( !Eof() ) .And. TG5->TG5_FILIAL == xFilial( "TG5" ) .And. TG5->TG5_CODPER == M->TG1_CODPER
		RecLock( "TG5" , .F. )
		DbDelete()
		MsUnLock( "TG5" )
		TG5->( dbSkip() )
	End


	DbSelectArea( cTRBA )
	dbSetOrder( 1 )
	DbGoTop()
	Do While ( cTRBA )->( !Eof() )
		DbSelectArea( "TG5" )
		DbSetOrder(1)
		If !DbSeek( xFilial( "TG5" ) + M->TG1_CODPER + ( cTRBA )->TRB_CODAVA + ( cTRBA )->TRB_CODIGO)
			RecLock( "TG5" , .T. )
		Else
			RecLock( "TG5" , .F. )
		EndIf
		If nOpcx == 5
			DbDelete()
		Else
			TG5->TG5_FILIAL := xFilial( "TG5" )
			TG5->TG5_CODPER := M->TG1_CODPER
			TG5->TG5_CODAVA := ( cTRBA )->TRB_CODAVA
			TG5->TG5_CODOPC := ( cTRBA )->TRB_CODIGO
			TG5->TG5_PESO   := ( cTRBA )->TRB_PESO
			TG5->TG5_RESULT := ( cTRBA )->TRB_RESULT
		EndIf
		MsUnLock( "TG5" )

		DbSelectArea( cTRBA )
		DbSkip()
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Manipula a tabela TGB³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPosCod := aScan( aHeader , { | x | Trim( Upper( x[ 2 ] ) ) == "TGB_CODLEG" } )
	nOrd 	:= 1
	cKey 	:= xFilial( "TGB" ) + M->TG1_CODPER
	cWhile	:= "xFilial( 'TGB' ) + M->TG1_CODPER == TGB->TGB_FILIAL + TGB->TGB_CODPER"
	If nOpcx == 5
		dbSelectArea("TGB")
		dbSetOrder(nOrd)
		dbSeek(cKey)
		While !Eof() .and. &(cWhile)
			RecLock("TGB",.f.)
			DbDelete()
			MsUnLock("TGB")
			dbSelectArea("TGB")
			dbSkip()
		End
	Else
		If Len(aCols) > 0
			//Coloca os deletados por primeiro
			aSORT( aCols , , , { | x , y | x[ Len( aCols[ 1 ] ) ] .and. !y[ Len( aCols[ 1 ] ) ] } )

			For i := 1 To Len( aCols )
				If !aCols[ i , Len( aCols[ i ] ) ] .and. !Empty( aCols[ i , nPosCod ] )
					dbSelectArea( "TGB" )
					dbSetOrder( nOrd )
					If dbSeek( xFilial( "TGB" ) + M->TG1_CODPER + aCols[ i , nPosCod ] )
						RecLock( "TGB" , .F. )
					Else
						RecLock( "TGB" , .T. )
					Endif
					For j := 1 to FCount()
						If "_FILIAL" $ Upper( FieldName( j ) )
							FieldPut( j , xFilial( "TGB" ) )
						ElseIf "_CODPER" $ Upper( FieldName( j ) )
							FieldPut( j , M->TG1_CODPER )
						ElseIf ( nPos := aScan( aHeader , { | x | Trim( Upper( x[ 2 ] ) ) == Trim( Upper( FieldName( j ) ) ) } ) ) > 0
							FieldPut( j , aCols[ i , nPos ] )
						Endif
					Next j
					MsUnlock( "TGB" )
				Elseif !Empty( aCols[ i , nPosCod ] )
					dbSelectArea( "TGB" )
					dbSetOrder( nOrd )
					If dbSeek( xFilial( "TGB" ) + M->TG1_CODPER + aCols[ i , nPosCod ] )
						RecLock( "TGB" , .F. )
						dbDelete()
						MsUnlock( "TGB" )
					Endif
				Endif
			Next i
		Endif
		dbSelectArea( "TGB" )
		dbSetOrder( nOrd )
		dbSeek( cKey )
		While !Eof() .and. &( cWhile )
			If aScan( aCols , { | x | x[ nPosCod ] == TGB->TGB_CODLEG .AND. !x[ Len( x ) ] } ) == 0
				RecLock( "TGB" , .F. )
				DbDelete()
				MsUnLock( "TGB" )
			Endif
			dbSelectArea( "TGB" )
			dbSkip()
		End
	EndIf

Return .t.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT853LIN
Valida a linha digitada no GetDados

@return Retorna verdadeiro quando linha correta

@sample
MDT853LIN()

@author Jackson Machado
@since 22/03/2013
/*/
//---------------------------------------------------------------------
Function MDT853LIN( cTabela , lFim )

	Local f, nQtd := 0
	Local aColsOk := {}, aHeadOk := {}
	Local nPosCod := 1, nPosFai := 0, nAt := 1
	Local nCols, nHead

	Default lFim := .F.

	If cTabela == "TGB"
		aColsOk := aClone(aCols)
		aHeadOk := aClone(aHeader)
		nAt 	:= oGet:nAt
		nPosCod := aScan( aHeader , { | x | Trim( Upper( x[ 2 ] ) ) == "TGB_CODLEG" } )

		If lFim .AND. Len( aColsOk ) == 1 .AND. Empty( aColsOk[ 1 , nPosCod ] )
			Return .T.
		Endif
	EndIf

	//Percorre aCols
	For f := 1 to Len( aColsOk )
		If !aColsOk[ f , Len( aColsOk[ f ] ) ]
			nQtd ++
			If f == nAt
				//VerIfica se os campos obrigatórios estão preenchidos
				If Empty( aColsOk[ f , nPosCod ] )
					//Mostra mensagem de Help
					Help( 1 , " " , "OBRIGAT2" , , aHeadOk[ nPosCod , 1 ] , 3 , 0 )
					Return .F.
				Endif
			Endif
			//Verifica se é somente LinhaOk
			If f <> nAt .and. !aColsOk[ nAt , Len( aColsOk[ nAt ] ) ]
				If aColsOk[ f , nPosCod ] == aColsOk[ nAt , nPosCod ]
					Help( " " , 1 , "JAEXISTINF" , , aHeadOk[ nPosCod , 1 ] )
					Return .F.
				Endif
			Endif
		Endif
	Next f

	PutFileInEof("TGB")

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

@author Jackson Machado
@since 22/03/2013
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {	{ STR0016  , "AxPesqui"  , 0 , 1 } , ; //"Pesquisar"
						{ STR0017  , "MDT853PRO" , 0 , 2 } , ; //"Visualizar"
						{ STR0018  , "MDT853PRO" , 0 , 3 } , ;  //"Incluir"
						{ STR0019  , "MDT853PRO" , 0 , 4 } , ;  //"Alterar"
						{ STR0020  , "MDT853PRO" , 0 , 5 , 3 } }  //"Excluir"

Return aRotina
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT853Em
Traz a descricao do Requisito

@return Descrição do Requisito

@sample
MDT853Em()

@author Jackson Machado
@since 22/03/2013
/*/
//---------------------------------------------------------------------
Function MDT853Em()
Return If( !INCLUI , NGSEEK( "TA0" , TGB->TGB_CODLEG , 1 , "TA0_EMENTA" ) , Space( TAMSX3( "TA0_EMENTA" )[ 1 ] ) )
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT853TREE
Realiza a carga da estrutura organizacional

@return

@sample
MDT853TREE( 1 )

@author Jackson Machado
@since 22/03/2013
/*/
//---------------------------------------------------------------------
Function MDT853TREE( nOpcao , aNivMrk , cFctClr )

Local cLocal 		:= ""
Local i

Default aNivMrk		:= {}
Default cFctClr		:= ""

If nOpcao == 1//Opcao 1 Carrega tudo e 2 bChange

	//Posiciona no nivel pai da estrutura
	dbSelectArea( "TAF" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "TAF" ) + cCodest + "000" )

	// Processa itens da tree, e define suas marcacoes
	Processa( { | lEnd | Sg100Tree( .F. , cCodest , 5 , aNivMrk ) } , STR0021 , STR0022 , .T. ) //"Aguarde..."###"Carregando Estrutura..."
	Processa( { | lEnd | MDT853MKNIV( aNivMrk ) } , STR0021 , STR0022 , .T. ) //"Aguarde..."###"Carregando Estrutura..."

Else

	dbSelectArea( oTree:cArqTree )
	cLocal := SubStr( oTree:getCargo() , 1, 3 )
	SG100VChg( 5 , {} )

Endif

MDT853COR( cLocal )//Troca cor das pastas

// Executa funcao especifica de cores
If !Empty( cFctClr )
	ExecFctClr( cFctClr )
Endif

//Se estiver abrindo a tela, fecha a estrutura
If nOpcao == 1
	For i:=1 to Len( aLocal )
		If aLocal[ i , 2 ]
			oTree:TreeSeek( aLocal[ i , 1 ] )
		Endif
	Next i
	oTree:TreeSeek( cCodest )
Endif

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT853COR
Altera cor dos itens que foram previamente marcados

@return

@sample
MDT853COR( '001' )

@author Jackson Machado
@since 22/03/2013
/*/
//---------------------------------------------------------------------
Function MDT853COR( cLocal )
Local i
Local aArea := GetArea()

For i := 1 to Len( aMarcado )
	If aMarcado[ i , Len( aMarcado[ i ] ) ]
		dbSelectArea( cTRBSGA )
		dbSetOrder( 2 )
		If dbSeek( cCodest + aMarcado[ i , 1 ] )
			dbSelectArea( oTree:cArqTree )
			dbSetOrder( 4 )
			If dbSeek( aMarcado[ i , 1 ] )
				If SubStr( ( oTree:cArqTree )->T_CARGO , 1 , 3 ) == aMarcado[ i , 1 ] .and. SubStr( ( oTree:cArqTree )->T_CARGO , 7 , 1 ) != "2"//Desmarca

					oTree:TreeSeek( aMarcado[ i , 1 ] )
					oTree:ChangeBmp( "Folder7" , "Folder8" )
					( oTree:cArqTree )->T_CARGO := SubStr( oTree:getCargo() , 1 , 6 ) + "2"
					aMarcado[ i , Len( aMarcado[ i ] ) ] := .F.

					//Caso nao seja nivel clicado, fecha o mesmo
					If ( cTRBSGA )->NIVSUP != cLocal .and. ( cTRBSGA )->CODPRO != cCodest
						oTree:TreeSeek( ( cTRBSGA )->NIVSUP )
						oTree:PtCollapse()
					Endif

					oTree:TreeSeek( cLocal )
				EndIf
			Endif
		Endif
	Endif
Next i

RestArea( aArea )

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT853MKNIV
Define marcacao para os niveis relacionados.

@return

@sample
MDT853MKNIV( {} )

@author Jackson Machado
@since 22/03/2013
/*/
//---------------------------------------------------------------------
Function MDT853MKNIV( aNivMrk )

	Local i

	ProcRegua( Len( aLocal ) )

	// Abre itens na estrutura
	For i := 1 to Len( aLocal )
		IncProc()
		If aLocal[ i , 2 ]
			fPosicLoc( aLocal[ i , 1 ] , aNivMrk )
		Endif
	Next i

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} ExecFctClr
Executa funcao para selecao de cores secundarias.

@return

@param cFctClr Nome da funcao em forma de string, a ser executada.

@author Jackson Machado
@since 22/03/2013
/*/
//---------------------------------------------------------------------
Static Function ExecFctClr( cFctClr )

	Local nPos     := At( "(" , cFctClr )
	Local cExecFct := If( nPos > 0 ,;
								SubStr( cFctClr , 1 , Len( cFctClr ) - nPos ) , ;
								cFctClr )

	If FindFunction( cExecFct )
		cFctClr += If( nPos > 0 , "" , "()" )
		&cFctClr.
	Endif

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} ExecFctClr
Posiciona na localizacao a ser marcada

@return

@param cCodigo  - Codigo do Local
@param aNivMrk - Niveis marcados

@author Jackson Machado
@since 22/03/2013
/*/
//---------------------------------------------------------------------
Static Function fPosicLoc( cCodigo , aNivMrk )
Local i
Local cSupNiv  := cCodEst
Local aLocPais := {}

//Carrega itens pais
If !Empty( cCodigo )

	aAdd( aLocPais , cCodigo )
	cSupNiv := NGSEEK( "TAF" , cCodigo , 8 , "TAF->TAF_NIVSUP" )

	dbSelectArea( "TAF" )
	dbSetOrder( 2 )
	dbSeek( xFilial( "TAF" ) + cCodEst + cCodigo )
	While !eof() .and. Found() .and. cSupNiv != "000"

		dbSelectArea( "TAF" )
		dbSetOrder( 2 )
		If dbSeek( xFilial( "TAF" ) + cCodEst + cSupNiv )
			aAdd( aLocPais , TAF->TAF_CODNIV )
			cSupNiv := TAF->TAF_NIVSUP
		Endif

	End
Else
	Return .F.
Endif

//Encontra item na arvore
For i := Len( aLocPais ) to 1 Step -1
	oTree:TreeSeek( aLocPais[ i ] + "LOC" )
	SG100VChg( 5 , aNivMrk )
Next i

Return .T.
