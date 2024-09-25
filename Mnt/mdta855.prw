#INCLUDE "MDTA855.ch"
#Include "Protheus.ch"
#Include "DbTree.ch"

#Define _nFolPer_ 1
#Define _nFolDan_ 2
#Define _nFolLoc_ 3
#Define _nFolPla_ 4
#Define _nFolEme_ 5
#Define _nFolObj_ 6
#Define _nFolMon_ 7
#Define _nQtdFor_ 5

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA855
Programa para cadastrar a Analise Preliminar

@return

@sample
MDTA855()

@author Jackson Machado
@since 27/03/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDTA855()

	//----------------------------
	// Salva area de trabalho
	//----------------------------
	Local aOldArea 		:= GetArea()
	//-----------------------------------------------------
	// Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	//-----------------------------------------------------
	Local aNGBEGINPRM 	:= NGBEGINPRM( ,, { "TG6" , { "TGF" , "TGG" , "TGH" , "TGI" , "TGN" } } )
	Local aCores 		:= {}

	Private aRotina 	:= MenuDef()

	Private cCadastro 	:= OemtoAnsi( STR0001 ) //"Análise Preliminar"

	If !AliasInDic( "TG0" )
		If NGINCOMPDIC( "UPDMDTB9" , "THXD30" )
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

	aAdd( aCores, { "TG6->TG6_SITUAC == '1' .Or. Empty( TG6->TG6_SITUAC ) "	, "BR_AMARELO" 	} )
	aAdd( aCores, { "TG6->TG6_SITUAC == '2'"								, "BR_VERDE" 	} )

	mBrowse( 6 , 1 , 22 , 75 , "TG6" , , , , , , aCores )

	dbSelectArea( "TG6" )
	dbSetOrder( 1 )

	//------------------------------
	// Restaura Area de trabalho
	//------------------------------
	RestArea( aOldArea )
	//-----------------------------------------------------
	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	//-----------------------------------------------------
	NGRETURNPRM( aNGBEGINPRM )

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT855PRO
Programa padrao de cadastro da analise

@return

@param cAlias - Alias do MenuDef
@param nRecno - Recno do Registro
@param nOpcx - Valor da operacao

@sample
MDT855PRO()

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Function MDT855PRO( cAlias , nRecno , nOpcx , cNivel , cCodPer )

	Local aNGBEGINPRM := If( IsInCallStack("MDTA855") , {} , NGBEGINPRM() )//Armazena Varíaveis para devolução

	Local Ni, nA, nFor
	Local nControl	  		:= 0
	Local nOK		  		:= 0
	Local nOpca 	  		:= 0
	Local nCount 	 		:= 0
	Local cTitulo	  		:= If( Type( "cCadastro" ) == "C" , cCadastro , STR0001 )  // Titulo da janela //"Análise Preliminar"
	Local aPages	 		:= {}
	Local aTitles 	  	:= {}
	Local aTitulos	  	:= {}
	Local aAliasTRB		:= {}
	Local oFont		  	:= TFont():New("Arial",,-13,,.T.)
	Local aNoFields		:= {}
	Local lInclui		:= nOpcx == 3
	Local lAltera		:= nOpcx == 4
	Local lWhenPerigo	:= !IsInCallStack("MNTA902") .And. lInclui
	Local nIdx := 0

	//Definicoes do MarkBrowse
	Local aMark			:= {}
	Local aMark1	 		:= {}
	Local aMark2	 		:= {}
	Local oMark
	Local oMark1
	Local oMark2
	//Definicoes de Paineis
	Local oPnlPai
	Local oPnlCab
	Local oPnlDiv
	Local oPnlEst
	Local oPnlTEst
	Local oPnlLEst
	Local oPnlBot
	Local oDlg
	Local oPnlTopP
	Local oPnlTPCar
	Local oPnlTPOpt
	Local oPnlReqP
	Local oPnlTopD
	Local oPnlTDAva
	Local oPnlTDOpt
	Local oPnlReqD
	Local oPnlTopL
	Local oPnlTLOpt

	//Tamanho de Tela
	Local aSize 			:= MsAdvSize(,.f.,430)

	//Cores
	Local aCores 			:= NGCOLOR()

	//Tabelas de GetDados
	Private aTabGet 		:= { ;
									{ "TGF" , "TGJ" , "TGF_CODPLA" } , ;
									{ "TGG" , "TGK" , "TGG_CODPLA" } , ;
									{ "TGH" , "TGL" , "TGH_CODOBJ" } , ;
									{ "TGI" , "TGM" , "TGI_CODMON" } ;
								}

	//Definicoes de GetDados
	Private aColsPA			:= {}
	Private aColsPE			:= {}
	Private aColsMO			:= {}
	Private aColsOB			:= {}
	Private aHeadPA			:= {}
	Private aHeadPE			:= {}
	Private aHeadMO			:= {}
	Private aHeadOB			:= {}
	Private oGetPA
	Private oGetPE
	Private oGetMO
	Private oGetOB

	Private lMDT855Rea	:= .F. //Variavel de indicacao de reavaliacao
	Private lCpy	 		:= IsInCallStack( "MDT855CPY" ) .Or. ( Type( "lMDT855Cpy" ) == "L" .And. lMDT855Cpy )
	Private lVisual  		:= .F.
	Private aTrocaF3  		:= {}

	Private cLabel	 		:= ""
	Private cLabel1	 		:= ""
	Private cLabel2	 		:= ""
	Private cLabel3	 		:= ""
	Private cLabel4	 		:= ""

	Private cOrdTG6
	Private cTRBSGA, aTRB

	Private oGet , aHeader , nItens , oGet1
	Private oTotal1 , oTotal2 , oTotal3 , oTotal4 , oTotal5

	Private nTotal1			:= 0
	Private nTotal2			:= 0
	Private nTotal3			:= 0
	Private nTotal4	 		:= 0
	Private nTotal5	 		:= 0

	Private aColsDan 		:= {}
	Private aColsLoc 		:= {}
	Private aCols1	 		:= {}
	Private lInverte 		:= .f.

	Private cMarca   		:= GetMark()

	Private n		 		:= 1
	Private n1		 		:= 1
	Private n2				:= 1
	Private aLocal2	 		:= {}
	Private aLocal	 		:= {}
	Private cAval	 		:= ""
	Private cAval1	 		:= ""
	Private cAval2	 		:= ""
	Private cDescPer 		:= ""
	Private cDescDan 		:= ""

	Private oTree , oDesc , oClasse , oDesDan , oMenu
	Private M->TG6_CODDAN	:= Space( Len( TG8->TG8_CODDAN ) )
	Private cDesc			:= Space( Len( TAF->TAF_NOMNIV ) ) //Descricao do pai da estrutura
	Private cClasse			:= Space( Len( TG4->TG4_DESCRI ) ) //Descricao da Classificacao
	Private cCodCla			:= Space( Len( TG4->TG4_CODCLA ) ) //Codigo da Classificacao
	Private dDtImp			:= cToD("  /  /  ")  //Data de Implantacao do Plano
	Private dDtEmis			:= dDataBase
	Private cCodEst			:= "001"
	Private lArvore			:= .T.
	Private lWhen			:= .f.
	Private nTotal			:= 0
	Private cDocto			:= ""
	Private aQDG			:= {}
	Private aQdGDoc	 		:= {}
	Private aQdjDoc			:= {}
	Private aMarcado		:= {}

	Private oQDJ , oQDG , bQDGLine1 , bQDGLine2 , bQDJLine1 , bQDJLine2
	Private lSituac			:= .T.//Varáivel que verifica When dos campos Plano de Ação e Emergencial
	Private aVETINR			:= {}
	Private cCargo			:= ""

	Private M->TG1_CODPER	:= Space( Len( TG1->TG1_CODPER ) )
	Private M->TG6_DESCRI	:= Space( 40 )
	Private M->TG6_SITUAC	:= "1"

	Private M->TG6_REVISA	:= Space(6)

	Private cTRBX			:= GetNextAlias()
	Private cTRBA			:= GetNextAlias()
	Private cTRBB			:= GetNextAlias()
	Private cTRBG			:= GetNextAlias()
	Private cTRBL			:= GetNextAlias()
	Private cTRBC			:= GetNextAlias()

	Default cNivel			:= Space( 3 )
	Default cCodPer			:= Space( Len( TG1->TG1_CODPER ) )
	//-----------------------------------
	//Inicialização de variaveis
	//-----------------------------------
	If nOpcx == 4
		If lMDT855Rea := fChkReav( nOpcx )
			If MsgYesNo( STR0119 , STR0035 )//"A Avaliação nessecita ser reavalida. Deseja continuar?"##"Atenção"
				nOpcx := 3
			Else
				Return .F.
			EndIf
		EndIf
	EndIf
	lInclui		:= nOpcx == 3
	lAltera		:= nOpcx == 4
	lWhenPerigo	:= If(lMDT855Rea,.F., !IsInCallStack("MNTA902") .And. lInclui )
	lSituac					:= If( lInclui .OR. ( lAltera .and. TG6->TG6_SITUAC == "1" .Or. Empty( TG6->TG6_SITUAC ) ) , .T. , .F. )

	If nOpcx == 3
		M->TG6_SITUAC		:= "1"
	Else
		M->TG6_SITUAC 		:= If( Empty( TG6->TG6_SITUAC ) , "1" , TG6->TG6_SITUAC )
	EndIf

	dbSelectArea( "TG0" )
	dbSetOrder( 01 )
	If !dbSeek( xFilial( "TG0" ) )
		MsgAlert( STR0002 ) //"É necessário ter pelo menos uma Fórmula cadastrada."
		Return 0
	EndIf

	If nOpcx <> 3 .Or. lCpy .Or. lMDT855Rea
		M->TG1_CODPER		:= TG6->TG6_CODPER
		M->TG6_CODDAN		:= TG6->TG6_CODDAN
		M->TG6_REVISA := TG6->TG6_REVISA
		If !lMDT855Rea
			DbSelectArea( "TG4" )
			DbSetOrder( 1 )
			If DbSeek( xFilial( "TG4" ) + TG6->TG6_CODCLA )
				cClasse 		:= TG4->TG4_DESCRI
			EndIf

			dbSelectArea( "TG0" )
			dbSetOrder( 1 )
			dbSeek( xFilial( "TG0" ) )
			nFor := 1
			While TG0->( !Eof() ) .And. nFor <= _nQtdFor_
				dbSelectArea( "TGN" )
				dbSetOrder( 1 )
				dbSeek( xFilial( "TGN" ) + TG6->TG6_ORDEM + TG0->TG0_CODFOR )
				&( "nTotal" + cValToChar( nFor ) )	:= TGN->TGN_RESULT
				nFor++
				dbSelectArea( "TG0" )
				TG0->( dbSkip() )
	   		End
		EndIf

		If !lCpy .Or. !lMDT855Rea
			dDtEmis			:= TG6->TG6_DTRESU
		Endif

		cOrdTG6				:= TG6->TG6_ORDEM

		DbSelectArea( "TG1" )
		DbSetOrder( 1 )
		If DbSeek( xFilial( "TG1" ) + M->TG1_CODPER )
			cDescPer 		:= SubStr( TG1->TG1_DESCRI , 1 , 50 )
		EndIf

		DbSelectArea( "TG8" )
		DbSetOrder( 1 )
		If DbSeek( xFilial( "TG8" ) + M->TG6_CODDAN )
			cDescDan 		:= SubStr( TG8->TG8_DESCRI , 1 , 50 )
		EndIf
	ElseIf nOpcx == 3 .And. IsInCallStack( "MNTA902" )
		M->TG1_CODPER		:= cCodPer
		DbSelectArea( "TG1" )
		DbSetOrder( 1 )
		If DbSeek( xFilial( "TG1" ) + M->TG1_CODPER )
			cDescPer 		:= SubStr( TG1->TG1_DESCRI , 1 , 50 )
		EndIf
	Endif

	If nOpcx == 3
		If lCpy .Or. lMDT855Rea
			cOrdemOld		:= fRetOrdem()
		Else
			cOrdTG6			:= fRetOrdem()
		Endif
	EndIf

	TAF->( dbSeek( xFilial( "TAF" ) + "001" ) )
	cDesc					:= TAF->TAF_NOMNIV

	If !MDT853GET( nOpcx , .T. )
	   Return 0
	EndIf

	aTRB    				:= SGATRBEST(.T.)//Define estrutura do TRB
	cTRBSGA 				:= aTRB[3]
	oTempSGA := FWTemporaryTable():New( cTRBSGA, aTRB[1] )
	For nIdx := 1 To Len( aTRB[2] )
		oTempSGA:AddIndex( RETASC( cValToChar( nIdx ) , 1 , .T. ), aTRB[2,nIdx] )
	Next nIdx
	oTempSGA:Create()

	aAliasTRB	:= { cTRBB, cTRBA, cTRBC }
	aDBF			:= {}
	aAdd( aDBF , { "TRB_CODAVA"	, "C" , 03 , 0 } )
	aAdd( aDBF , { "TRB_CODIGO"	, "C" , 03 , 0 } )
	aAdd( aDBF , { "TRB_PESO"		, "N" , 03 , 0 } )
	aAdd( aDBF , { "TRB_RESULT"	, "N" , 03 , 0 } )
	For nA := 1 To Len( aAliasTRB )
		oTempTRB := FWTemporaryTable():New( aAliasTRB[ nA ], aDBF )
		oTempTRB:AddIndex( "1", {"TRB_CODAVA","TRB_CODIGO"} )
		oTempTRB:Create()
	Next nA

	//Definicoes dos Titulos dos Folders
	aTitulos := { STR0003 , STR0004 , STR0008 , STR0005 , STR0006 , STR0007 , STR0009 } //"Perigo"###"Dano"###"Localização"###"Plano Ação"###"Plano Emerg."###"Objetivo"###"Monitoramento"

	For nA := 1 To Len( aTitulos )
		aAdd( aTitles , OemToAnsi( aTitulos[ nA ] ) )
		aAdd( aPages , "Header " + Str( nA ) )
		nControl++
	Next nA

	Define MsDialog oDlg Title cTitulo From aSize[ 7 ] , 0 To aSize[ 6 ] , aSize[ 5 ] Of oMainWnd Pixel

	oPnlPai := TPanel():New( 0 , 0 , , oDlg , , , , CLR_BLACK , CLR_WHITE , 0 , 0 , .F. , .F. )
		oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

	//---------------------------
	// Header
	//---------------------------
	oPnlCab := TPanel():New( 0 , 0 , , oPnlPai , , , , CLR_BLACK , CLR_WHITE , 0 , 0 , .F. , .F. )
		oPnlCab:Align := CONTROL_ALIGN_TOP
		oPnlCab:nHeight := 40

		@ 007 , 008 Say OemToAnsi( STR0010 ) Size 37 , 7 Of oPnlCab Pixel Color CLR_HBLUE //"Num. Ordem"
		If lCpy .Or. lMDT855Rea
			@ 005 , 047 MsGet cOrdemOld Size 038 , 08 Of oPnlCab Pixel When .F.
		Else
			@ 005 , 047 MsGet cOrdTG6 Size 038 , 08 Of oPnlCab Pixel When .F.
		Endif

		@ 007 , 100 Say OemToAnsi( STR0011 ) Size 57 , 7 Of oPnlCab Pixel Color CLR_HBLUE  //"Data"
		@ 005 , 120 MsGet dDtEmis Size 48 , 06 Of oPnlCab Pixel Picture "99/99/9999" When .F. HASBUTTON


		@ 007 , 220 Say OemToAnsi( STR0125 ) Size 57 , 7 Of oPnlCab Pixel Color CLR_HBLUE //"Revisão"
		@ 005 , 255 MsGet M->TG6_REVISA Size 48 , 06 Of oPnlCab Pixel Valid ExistCPO( "TGP" , M->TG6_REVISA ) F3 "TGP" HASBUTTON

		@ 020 , 004 TO 21 , 468 Label "" of oPnlCab Pixel

	oPnlDiv := TPanel():New( 0 , 0 , , oPnlPai , , , , CLR_BLACK , aCores[2] , 0 , 0 , .F. , .F. )
		oPnlDiv:Align := CONTROL_ALIGN_TOP
		oPnlDiv:nHeight := 1.5

	//---------------------------
	// Estrutura
	//---------------------------

	oPnlEst := TPanel():New( 0 , 0 , , oPnlPai , , , , CLR_BLACK , CLR_WHITE , 0 , 0 , .F. , .F. )
		oPnlEst:Align := CONTROL_ALIGN_LEFT
		oPnlEst:nWidth := 450

		oPnlTEst := TPanel():New( 0 , 0 , , oPnlEst , , , , CLR_BLACK , CLR_WHITE , 0 , 0 , .F. , .F. )
			oPnlTEst:Align := CONTROL_ALIGN_TOP
			oPnlTEst:nHeight := 22

			@ 003 , 025 Say OemToAnsi( STR0012 ) Size 200 , 10 Of oPnlTEst Pixel Font oFont //"Estrutura Organizacional"

		oTree := DbTree():New( 042 , 005 , 250 , 180 , oPnlEst , , , .T. )
		oTree:bChange   := { | | MDT853TREE( 2 ) }
		oTree:Align 	:= CONTROL_ALIGN_ALLCLIENT

		If nOpcx <> 3 .Or. lCpy .Or. lMDT855Rea
			SetNivMrk( M->TG1_CODPER , cOrdTG6 ) // Carrega niveis selecionados
			fMontaTree( .F. )                   // Construcao de componentes da tree
		ElseIf nOpcx == 3 .And. IsInCallStack( "MNTA902" )
			SetNivMrk( cCodPer )
			aAdd( aLocal2 , { cNivel , .T. } )
			fMontaTree( .F. )
		Endif

		// Se nao for inclusao, desativa 'action' de duplo clique
		If nOpcx == 3 .And. !IsInCallStack( "MNTA902" ) .And. !lMDT855Rea
			oTree:blDblClick := { | | fChangeBMP() }
		Else
			oTree:BlDblClick := { | |  }
		EndIf

		NgPopUp( asMenu , @oMenu )
		oPnlEst:bRClicked:= { | o , x , y | oMenu:Activate( x , y , oPnlEst ) }

		nTree := aScan( aLocal2 , { | x | x[ 2 ] } )
		If nTree > 0
			cCargo := aLocal2[ nTree , 1 ]
		Endif

		// Verifica item definido como 'Sendo Avaliado', e se o processo for de copia
		If lCpy .And. oTree:TreeSeek( cCargo )

			// Retira marcacao de nivel 'Sendo Avaliado'
			// Altera referencia do item da tree com situacao 'Sendo Avaliado' [ Folder Amarelo], para 'Presenca de Perigo' [ Folder Vermelho ]
			oTree:ChangeBmp( "Folder7" , "Folder8" )
			( oTree:cArqTree )->T_CARGO := SubStr( oTree:getCargo() , 1 , 6 ) + "2"

			nPos := aScan( aLocal2 , { | x | x[ 1 ] == SubStr( oTree:GetCargo() , 1 , 3 ) } )
			If nPos > 0
				aLocal2[ nPos , 2 ] := .F.
			Else
				aAdd( aLocal2 , { SubStr( oTree:GetCargo() , 1 , 3 ) , .F. } )
			EndIf
		Endif

		oTree:TreeSeek( "001" )

   		oPnlLEst := TPanel():New( 0 , 0 , , oPnlEst , , , , CLR_BLACK , CLR_WHITE , 0 , 0 , .F. , .F. )
			oPnlLEst:Align := CONTROL_ALIGN_BOTTOM
			oPnlLEst:nHeight := 60

			@ 000 , 008 Bitmap oBmp1 Resource "Folder11" Size 25 , 25 Pixel Of oPnlLEst NoBorder When .F.
			@ 003 , 023 Say OemToAnsi( STR0013 ) Size 37 , 7 Of oPnlLEst Pixel  //"Identificação"
			@ 000 , 076 Bitmap oBmp2 Resource "Folder15" Size 25 , 25 Pixel Of oPnlLEst NoBorder When .F.
			@ 003 , 091 Say OemToAnsi( STR0014 ) Size 57 , 7 Of oPnlLEst Pixel  //"Função"
			@ 000 , 144 Bitmap oBmp3 Resource "Folder13" Size 25 , 25 Pixel Of oPnlLEst NoBorder When .F.
			@ 003 , 159 Say OemToAnsi( STR0015 ) Size 57 , 7 Of oPnlLEst Pixel //"Tarefa"

			@ 013 , 008 Bitmap oBmp1 Resource "Folder8" Size 25 , 25 Pixel Of oPnlLEst NoBorder When .F.
			@ 015 , 023 Say OemToAnsi( STR0016 ) Size 57 , 7 Of oPnlLEst Pixel  //"Presença de Perigo"
			@ 013 , 076 Bitmap oBmp2 Resource "Folder6" Size 25 , 25 Pixel Of oPnlLEst NoBorder When .F.
			@ 015 , 091 Say OemToAnsi( STR0017 ) Size 57 , 7 Of oPnlLEst Pixel  //"Sendo Avaliado"

	oFolder := TFolder():New( 031 , 180 , aTitles , aPages , oPnlPai , , , , .T. , .F. , 290 , 240 , )
		For nA := 1 To Len( aPages )
			oFolder:aDialogs[ nA ]:oFont := oDlg:oFont
		Next nA
		oFolder:Align := CONTROL_ALIGN_ALLCLIENT

		//---------------------------
		// Folder 01 - Perigo
		//---------------------------
		fValores( nOpcx , "1" )
		oPnlTopP := TPanel():New( 0 , 0 , , oFolder:aDialogs[ _nFolPer_ ] , , , , CLR_BLACK , CLR_WHITE , 0 , 0 , .F. , .F. )
			oPnlTopP:Align := CONTROL_ALIGN_TOP
			oPnlTopP:nHeight := 60

			@ 007 , 008 Say OemToAnsi( STR0003 ) Size 37 , 07 Of oPnlTopP Pixel Color CLR_HBLUE //"Perigo"
			@ 005 , 047 MsGet M->TG1_CODPER Size 038 , 08 Of oPnlTopP Pixel F3 "TG1" Valid fRetPerigo() .and.;
																							      fMontaTree() .And.;
																							      fRMarkPer( nOpcx , oMark) When lWhenPerigo HasButton

			@ 020 , 008 Say OemToAnsi( STR0018 ) Size 37 , 7 Of oPnlTopP Pixel //"Descrição"
			@ 018 , 047 MsGet oDesc Var cDescPer Size 200 , 8 Of oPnlTopP Pixel When .F.


		oPnlTpCar := TPanel():New( 0 , 0 , , oFolder:aDialogs[ _nFolPer_ ] , , , , CLR_BLACK , CLR_WHITE , 0 , 0 , .F. , .F. )
			oPnlTpCar:Align := CONTROL_ALIGN_TOP
			oPnlTpCar:nHeight := 30

			@ 005 , 008 Say OemToAnsi( STR0019 ) Size 84 , 8 Of oPnlTpCar Pixel Font oFont //"Caracterizações"

		@ 045 , 008 ListBox oGet Fields aCols1[ n , 1 ], aCols1[ n , 2 ] , aCols1[ n , 3 ], aCols1[ n , 4 ] , aCols1[ n , 5 ] ;
				Headers STR0020 , STR0021 , STR0018 , STR0022 , STR0023 Of oFolder:aDialogs[ _nFolPer_ ] Size 270 , 63 Pixel; //"Avaliação"###"Forma Avaliação"###"Descrição"###"Peso"###"Resultado"
				On Change ( fChangeCri( n , nOpcx, cAval, "1", @aCols1, @aMark, @oMark, cTRBX, cTRBA ) )
				oGet:bGotop    := { | | n := 1 }
				oGet:bGoBottom := { | | n := eval( oGet:bLogicLen ) }
				oGet:bSkip     := { | nWant, nOld | nOld := n , n += nWant,;
		      n := Max( 1 , Min( n , Eval( oGet:bLogicLen ) ) ),;
		      n - nOld }
		      oGet:bLogicLen := { | | Len( aCols1 ) }
		      oGet:cAlias    := "Array"
				oGet:nHeight   := 120
		   	oGet:Align     := CONTROL_ALIGN_TOP

				If Len(aCols1) > 0
					cAval := aCols1[1][1]
					If Empty( cAval )
						oGet:Disable()
					EndIF
				EndIf

		oPnlTPOpt := TPanel():New( 0 , 0 , , oFolder:aDialogs[ _nFolPer_ ] , , , , CLR_BLACK , CLR_WHITE , 0 , 0 , .F. , .F. )
			oPnlTPOpt:Align := CONTROL_ALIGN_TOP
			oPnlTPOpt:nHeight := 30

			@ 005 , 008 Say OemToAnsi( STR0024 ) Size 57 , 8 Of oPnlTPOpt Pixel Font oFont  //"Opções"
		//------------
		// Carrega Mark de Perigos
		//------------
		fMarkOpc( , cAval , nOpcx , "1", cTRBX, cTRBA, @aMark )

		oMark := MsSelect():New( cTRBX , "TRB_OK" , , aMark , @lInverte , @cMarca , { 130 , 8 , 193 , 280 } , , , oFolder:aDialogs[ _nFolPer_ ] )
		oMark:oBrowse:lHasMark		:= .T.
		oMark:oBrowse:lCanAllMark	:= .F.
		oMark:bMark					:= { | | fBMarkPer( cMarca , oGet , oMark ) }
		oMark:oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT

		If Str( nOpcx , 1 ) $ "2/5" .Or. M->TG6_SITUAC <> "1"
			oMark:oBrowse:lReadOnly := .T.
		EndIf

		oPnlReqP := TPanel():New( 0 , 0 , , oFolder:aDialogs[ _nFolPer_ ] , , , , CLR_BLACK , CLR_WHITE , 0 , 0 , .F. , .F. )
			oPnlReqP:Align := CONTROL_ALIGN_BOTTOM
			oPnlReqP:nHeight := 30

			@ 002 , 220 BTNBMP oBtn02 Resource "sduprop" Size 162,24 OF oPnlReqP Pixel ;
								    Action fDocumento( 1 )

			oBtn02:cCaption:= PADR( OemToAnsi( STR0025 ) , 20 ) //"Requisitos do Perigo"
			oBtn02:cToolTip:= OemToAnsi( STR0026 ) //"Visualiza os Requisitos referentes ao Perigo."

		//---------------------------
		// Folder 02 - Dano
		//---------------------------
		fValores( nOpcx , "2" )

		oPnlTopD := TPanel():New( 0 , 0 , , oFolder:aDialogs[ _nFolDan_ ] , , , , CLR_BLACK , CLR_WHITE , 0 , 0 , .F. , .F. )
			oPnlTopD:Align := CONTROL_ALIGN_TOP
			oPnlTopD:nHeight := 60

			@ 007 , 008 Say OemToAnsi( STR0004 ) Size 037 , 007 Of oPnlTopD Pixel Color CLR_HBLUE  //"Dano"
			@ 005 , 047 MsGet M->TG6_CODDAN Size 038 , 008 Of oPnlTopD Pixel F3 "TG8" Valid fRetDano() When If(lMDT855Rea, .F. ,lInclui) HasButton

			@ 020 , 008 Say OemToAnsi( STR0018 ) Size 037 , 007 Of oPnlTopD Pixel  //"Descrição"
			@ 018 , 047 MsGet oDesDan Var cDescDan Size 200 , 008 Of oPnlTopD Pixel When .f.


		oPnlTDAva := TPanel():New( 0 , 0 , , oFolder:aDialogs[ _nFolDan_ ] , , , , CLR_BLACK , CLR_WHITE , 0 , 0 , .F. , .F. )
			oPnlTDAva:Align := CONTROL_ALIGN_TOP
			oPnlTDAva:nHeight := 30

			@ 005 , 008 Say OemToAnsi( STR0020 ) Size 57 , 8 Of oPnlTDAva Pixel Font oFont //"Avaliação"

			@ 045 , 008 ListBox oGet1 Fields aColsDan[ n1 , 1 ] , aColsDan[ n1 , 2 ] , aColsDan[ n1 , 3 ] , aColsDan[ n1 , 4 ] , aColsDan[ n1 , 5 ] ;
		 		Headers STR0020 , STR0021 , STR0018 , STR0022 , STR0023 Of oFolder:aDialogs[ _nFolDan_ ] Size 270 , 063 Pixel;  //"Avaliação"###"Forma Avaliação"###"Descrição"###"Peso"###"Resultado"
				On Change ( fChangeCri( n1 , nOpcx, cAval1, "2", @aColsDan, @aMark1, @oMark1, cTRBG, cTRBB ) )

				oGet1:bGotop    := { | | n1 := 1 }
				oGet1:bGoBottom := { | | n1 := eval( oGet1:bLogicLen ) }

				oGet1:bSkip     := { | nWant, nOld | nOld := n1 , n1 += nWant,;
		      n1 := Max( 1 , Min( n1 , Eval( oGet1:bLogicLen ) ) ) , ;
		      n1 - nOld }
		      oGet1:bLogicLen := { | | Len( aColsDan ) }
		  		oGet1:cAlias    := "Array"
				oGet1:nHeight   := 120
		   		oGet1:Align     := CONTROL_ALIGN_TOP

				If Len(aColsDan) > 0
					cAval1 := aColsDan[1][1]
					If Empty( cAval1 )
						oGet1:Disable()
					EndIF
				EndIf
		oPnlTDOpt := TPanel():New( 0 , 0 , , oFolder:aDialogs[ _nFolDan_ ] , , , , CLR_BLACK , CLR_WHITE , 0 , 0 , .F. , .F. )
			oPnlTDOpt:Align := CONTROL_ALIGN_TOP
			oPnlTDOpt:nHeight := 30

			@ 005 , 008 Say OemToAnsi( STR0024 ) Size 57 , 8 Of oPnlTDOpt Pixel Font oFont  //"Opções"
		//------------
		// Carrega Mark de Danos
		//------------
		fMarkOpc( , cAval1 , nOpcx , "2", cTRBG, cTRBB, @aMark1 )

		oMark1 := MsSelect():New( cTRBG , "TRB_OK" , , aMark1 , @lInverte , @cMarca , { 130 , 8 , 193 , 280 } , , , oFolder:aDialogs[ _nFolDan_ ] )
		oMark1:oBrowse:lHasMark 	:= .F.
		oMark1:oBrowse:lCanAllMark 	:= .F.
		oMark1:bMark 				:= { | | fBMarkDan( cMarca , oGet1 , oMark1 ) }
		oMark1:oBrowse:Align       	:= CONTROL_ALIGN_ALLCLIENT

		If Str( nOpcx , 1 ) $ "2/5" .Or. M->TG6_SITUAC <> "1"
			oMark1:oBrowse:lReadOnly := .T.
		EndIf

		oPnlReqD := TPanel():New( 0 , 0 , , oFolder:aDialogs[ _nFolDan_ ] , , , , CLR_BLACK , CLR_WHITE , 0 , 0 , .F. , .F. )
			oPnlReqD:Align := CONTROL_ALIGN_BOTTOM
			oPnlReqD:nHeight := 30

			@ 002 , 220 BTNBMP oBtn03 Resource "sduprop" Size 162 , 24 OF oPnlReqD Pixel ;
								    Action fDocumento( 2 )

		oBtn03:cCaption := PADR( OemToAnsi( STR0028 ) , 20 )  //"Requisitos do Dano"
		oBtn03:cToolTip := OemToAnsi( STR0029 ) //"Visualiza os Requisitos referentes ao Dano."

		//---------------------------
		// Folder 03 - Localização
		//---------------------------
		fValores( nOpcx , "3" )

		oPnlTopL := TPanel():New( 0 , 0 , , oFolder:aDialogs[ _nFolLoc_ ] , , , , CLR_BLACK , CLR_WHITE , 0 , 0 , .F. , .F. )
			oPnlTopL:Align := CONTROL_ALIGN_TOP
			oPnlTopL:nHeight := 30

			@ 005 , 008 Say OemToAnsi( STR0008 ) Size 57 , 8 Of oPnlTopL Pixel Font oFont   // //"STR0127 Localização" //"Localização"

		@ 45,008 ListBox oGet2 Fields aColsLoc[ n2 , 1 ] , aColsLoc[ n2 , 2 ] , aColsLoc[ n2 , 3 ] , aColsLoc[ n2 , 4 ] , aColsLoc[ n2 , 5 ] ;
				Headers STR0020 , STR0021 , STR0018 , STR0022 , STR0023  Of oFolder:aDialogs[ _nFolLoc_ ] Size 270,63 Pixel; //"Avaliação"###"Forma Avaliação"###"Descrição"###"Peso"###"Resultado"
				On Change ( fChangeCri( n2 , nOpcx, cAval2, "3", @aColsLoc, @aMark2, @oMark2, cTRBL, cTRBC ) )

				oGet2:bGotop    := { || n2 := 1 }
				oGet2:bGoBottom := { || n2 := eval( oGet2:bLogicLen ) }

				oGet2:bSkip     := { | nwant, nold | nold := n2 , n2 += nwant,;
				n2 := max( 1, min( n2, eval( oGet2:bLogicLen ))),;
				n2 - nOld }
				oGet2:bLogicLen := { || Len( aColsLoc ) }
				oGet2:nHeight   := 120
		   	oGet2:Align     := CONTROL_ALIGN_TOP
				oGet2:cAlias    := "Array"

				If Len(aColsLoc) > 0
					cAval2 := aColsLoc[1][1]
					If Empty( cAval2 )
						oGet2:Disable()
					EndIF
				EndIf
		oPnlTLOpt := TPanel():New( 0 , 0 , , oFolder:aDialogs[ _nFolLoc_ ] , , , , CLR_BLACK , CLR_WHITE , 0 , 0 , .F. , .F. )
			oPnlTLOpt:Align := CONTROL_ALIGN_TOP
			oPnlTLOpt:nHeight := 30

			@ 005 , 008 Say OemToAnsi( STR0024 ) Size 57 , 8 Of oPnlTLOpt Pixel Font oFont   // "Opcoes"
		//------------
		// Carrega Mark de Localização
		//------------
		fMarkOpc( , cAval2 , nOpcx , "3", cTRBL, cTRBC, @aMark2 )

		oMark2 := MsSelect():New( cTRBL , "TRB_OK" , , aMark2 , @lInverte , @cMarca , { 130 , 8 , 193 , 280 } , , , oFolder:aDialogs[ _nFolLoc_ ] )
			oMark2:oBrowse:lHasMark 	:= .F.
			oMark2:oBrowse:lCanAllMark 	:= .F.
			oMark2:bMark 				:= { | | fBMarkLoc( cMarca , oGet2 , oMark2 ) }
			oMark2:oBrowse:Align       	:= CONTROL_ALIGN_ALLCLIENT

			If Str( nOpcx , 1 ) $ "2/5" .Or. M->TG6_SITUAC <> "1"
				oMark2:oBrowse:lReadOnly := .T.
			EndIf


		//---------------------------
		// Folder 04 - Plano Ação
		//---------------------------
		aNoFields 	:= {}
		aCols		:= {}
		aHeader		:= {}
		aAdd( aNoFields , "TGF_FILIAL" )
		aAdd( aNoFields , "TGF_ANALIS" )

		cKeyGet		:= "cOrdTG6"
		cWhileGet	:= "TGF->TGF_FILIAL == '" + xFilial("TGF") + "' .AND. TGF->TGF_ANALIS == '" + cOrdTG6 + "'"
		dbSelectArea( "TGF" )
		dbSetOrder( 1 )
		FillGetDados( nOpcx , "TGF" , 1 , cKeyGet , {|| } , {|| .T.} , aNoFields , , , , ;
						{ | | NGMontaAcols( "TGF" , &cKeyGet , cWhileGet ) } )
		If Empty(aCols) .Or. nOpcx == 3
			aCols := BLANKGETD( aHeader )
		Endif
		aColsPA := ACLONE(aCols)
		aHeadPA := ACLONE(aHeader)
		nLenPA  := Len( aColsPA )

		nTelaX := ( aSize[6]/2.02 ) - 108

		dbSelectArea( "TGF" )
		PutFileInEof( "TGF" )
		oGetPA   := MsNewGetDados():New(0,0,1000,1000,IIF(!lInclui .and. !lAltera,0,GD_INSERT+GD_UPDATE+GD_DELETE),;
					{ | | MDT855LIOK( "TGF" ) } , { | | .T. } , , , , 9999 , , , , oFolder:aDialogs[ _nFolPla_ ] , aHeadPA , aColsPA )
			oGetPA:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
			oGetPA:oBrowse:Refresh()
			If !lSituac
				oGetPA:Disable()
			EndIf
		//---------------------------
		// Folder 05 - Plano Emergencial
		//---------------------------
		aNoFields	:= {}
		aCols		:= {}
		aHeader		:= {}
		aAdd( aNoFields , "TGG_FILIAL" )
		aAdd( aNoFields , "TGG_ANALIS" )

		cKeyGet		:= "cOrdTG6"
		cWhileGet	:= "TGG->TGG_FILIAL == '" + xFilial("TGG") + "' .AND. TGG->TGG_ANALIS == '" + cOrdTG6 + "'"
		dbSelectArea( "TGG" )
		dbSetOrder( 1 )
		FillGetDados( nOpcx , "TGG" , 1 , cKeyGet , {|| } , {|| .T.} , aNoFields , , , , ;
						{ | | NGMontaAcols( "TGG" , &cKeyGet , cWhileGet ) } )
		If Empty(aCols) .Or. nOpcx == 3
			aCols := BLANKGETD( aHeader )
		Endif
		aColsPE := ACLONE(aCols)
		aHeadPE := ACLONE(aHeader)
		nLenPE  := Len( aColsPE )

		nTelaX := ( aSize[6]/2.02 ) - 108

		dbSelectArea( "TGG" )
		PutFileInEof( "TGG" )
		oGetPE   := MsNewGetDados():New(0,0,1000,1000,IIF(!lInclui .and. !lAltera,0,GD_INSERT+GD_UPDATE+GD_DELETE),;
					{ | | MDT855LIOK( "TGG" ) } , { | | .T. } , , , , 9999 , , , , oFolder:aDialogs[ _nFolEme_ ] , aHeadPE , aColsPE )
			oGetPE:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
			oGetPE:oBrowse:Refresh()
			If !lSituac
				oGetPE:Disable()
			EndIf
		//---------------------------
		// Folder 06 - Objetivo
		//---------------------------
		aNoFields	:= {}
		aCols		:= {}
		aHeader		:= {}
		aAdd( aNoFields , "TGH_FILIAL" )
		aAdd( aNoFields , "TGH_ANALIS" )

		cKeyGet		:= "cOrdTG6"
		cWhileGet	:= "TGH->TGH_FILIAL == '" + xFilial("TGH") + "' .AND. TGH->TGH_ANALIS == '" + cOrdTG6 + "'"
		dbSelectArea( "TGH" )
		dbSetOrder( 1 )
		FillGetDados( nOpcx , "TGH" , 1 , cKeyGet , {|| } , {|| .T.} , aNoFields , , , , ;
						{ | | NGMontaAcols( "TGH" , &cKeyGet , cWhileGet ) } )
		If Empty(aCols) .Or. nOpcx == 3
			aCols := BLANKGETD( aHeader )
		Endif
		aColsOB := ACLONE(aCols)
		aHeadOB := ACLONE(aHeader)
		nLenOB  := Len( aColsOB )

		nTelaX := ( aSize[6]/2.02 ) - 108

		dbSelectArea( "TGH" )
		PutFileInEof( "TGH" )
		oGetOB   := MsNewGetDados():New(0,0,1000,1000,IIF(!lInclui .and. !lAltera,0,GD_INSERT+GD_UPDATE+GD_DELETE),;
					{ | | MDT855LIOK( "TGH" ) } , { | | .T. } , , , , 9999 , , , , oFolder:aDialogs[ _nFolObj_ ] , aHeadOB , aColsOB )
			oGetOB:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
			oGetOB:oBrowse:Refresh()
			If !lSituac
				oGetOB:Disable()
			EndIf
		//---------------------------
		// Folder 07 - Monitoramento
		//---------------------------
		aNoFields	:= {}
		aCols		:= {}
		aHeader		:= {}
		aAdd( aNoFields , "TGI_FILIAL" )
		aAdd( aNoFields , "TGI_ANALIS" )

		cKeyGet		:= "cOrdTG6"
		cWhileGet	:= "TGI->TGI_FILIAL == '" + xFilial("TGI") + "' .AND. TGI->TGI_ANALIS == '" + cOrdTG6 + "'"
		dbSelectArea( "TGI" )
		dbSetOrder( 1 )
		FillGetDados( nOpcx , "TGI" , 1 , cKeyGet , {|| } , {|| .T.} , aNoFields , , , , ;
						{ | | NGMontaAcols( "TGI" , &cKeyGet , cWhileGet ) } )
		If Empty(aCols) .Or. nOpcx == 3
			aCols := BLANKGETD( aHeader )
		Endif
		aColsMO := ACLONE(aCols)
		aHeadMO := ACLONE(aHeader)
		nLenMO  := Len( aColsMO )

		dbSelectArea( "TGI" )
		PutFileInEof( "TGI" )
		oGetMO   := MsNewGetDados():New(0,0,1000,1000,IIF(!lInclui .and. !lAltera,0,GD_INSERT+GD_UPDATE+GD_DELETE),;
					{ | | MDT855LIOK( "TGI" ) } , { | | .T. } , , , , 9999 , , , , oFolder:aDialogs[ _nFolMon_ ] , aHeadMO , aColsMO )
			oGetMO:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
			oGetMO:oBrowse:Refresh()
			If !lSituac
				oGetMO:Disable()
			EndIf
	//---------------------------
	// Footer
	//---------------------------

	oPnlBot := TPanel():New( 0 , 0 , , oPnlPai , , , , CLR_BLACK , CLR_WHITE , 0 , 0 , .F. , .F. )
		oPnlBot:Align := CONTROL_ALIGN_BOTTOM
		oPnlBot:nHeight := 80

		@ 005 , 004 TO 030,140 Label STR0030 of oPnlBot Pixel //"Significância"
		@ 015 , 008 MsGet oClasse Var cClasse Size 128 , 08 Of oPnlBot Pixel When .f.

		@ 005 , 145 TO 030 , ( aSize[ 5 ] / 2 ) - 10 Label STR0023 of oPnlBot Pixel //"Resultado"

		fMontaResu( ( aSize[ 5 ] / 2 ) , @oPnlBot)

		@ 015 , 147 Button oBtn1 Prompt STR0031 Size 30 , 10 Of oPnlBot Pixel Action fCalcular()  //"Calcular"
		oBtn1:SetEnable( !( Str( nOpcx , 1 ) $ "2/5" ) )

	Activate MsDialog oDlg On Init fEnchBar( oDlg , ;
											{ | | lOk := .T. , nOpca := 1 , If( MDT855VADV( nOpcx ) , oDlg:End() , ( lOk := .F. , nOpca := 0 ) ) } , ;// bOk
											{ | | nOk := 0 , oDlg:End() , nOpca := 0 },;	// bCancel
											{ | | lGrava := .F. , If( !fMemo( .T. , nOpcx ) , oDlg:End() , .T. ) },;// bCria
											@nOpca , nOpcx ) Centered

	dbSelectArea( "TG6" )
	dbSetOrder( 1 )
	If nOpca == 1
		EvalTrigger()
		ConfirmSX8()
	Else
		RollBackSX8()
	EndIf

	//deverá fechar, pois foi add no For
	//--------------------------
	DbSelectArea( cTRBB )
	DbCloseArea()
	DbSelectArea( cTRBA )
	DbCloseArea()
	DbSelectArea( cTRBC )
	DbCloseArea()
	//--------------------------

	DbSelectArea( cTRBG )
	DbCloseArea()

	DbSelectArea( cTRBX )
	DbCloseArea()

	DbSelectArea( cTRBL )
	DbCloseArea()

	//Deleta o arquivo temporario fisicamente
	oTempSGA:Delete()
	oTempTRB:Delete()

	NGRETURNPRM( aNGBEGINPRM )//Devolve Varíaveis armazenadas

Return nOpca

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT855VADV
Validacao geral da tela de desempenho.

@return Lógico - Retorna verdadeiro caso validacao esteja correta

@param nOpcx - Valor da operacao

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Static Function MDT855VADV( nOpcx )

	Local nTab := 0

	// Se o processo for de visualizacao, nao realiza a validacao 'geral'
	If nOpcx == 2
		Return .T.
	ElseIf nOpcx == 5
		If !NGVALSX9( "TG6" , { "TGC" , "TGN" , "TGO" , "TGF" , "TGG" , "TGH" , "TGI" } , .T. )
			Return .F.
		EndIf
	Endif

	//Valida as GetDados
	aColsPA := aClone( oGetPA:aCols )
	aCOlsPE := aClone( oGetPE:aCols )
	aColsOB := aClone( oGetOB:aCols )
	aColsMO := aClone( oGetMO:aCols )

	For nTab := 1 To Len( aTabGet )
		If !MDT855LIOK( aTabGet[ nTab , 1 ] , .T. )
			Return .F.
		EndIf
	Next nTab

	// Verifica obrigatoriedades
	If !fObrigatorio( nOpcx )
		Return .F.
	Endif

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fRetOrdem
Retorna a ordem da analise

@return cRetorno - Codigo da analise

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Static Function fRetOrdem()

	If lCpy .Or. lMDT855Rea
		cOrdemOld	:= GetSxENum( "TG6" , "TG6_ORDEM" )
		cRetorno	:= cOrdemOld
	Else
		cOrdTG6		:= GetSxENum( "TG6" , "TG6_ORDEM" )
		cRetorno	:= cOrdTG6
	Endif

Return cRetorno
//---------------------------------------------------------------------
/*/{Protheus.doc} fRetPerigo
Retorna a descricao do perigo

@return

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Function fRetPerigo()

	If Empty( M->TG1_CODPER )
	   Return .F.
	EndIf
	If !ExistCpo( "TG1" , M->TG1_CODPER )
	   Return .F.
	EndIf

	TG1->( dbSeek( xFilial( "TG1" ) + M->TG1_CODPER ) )
	cDescPer := SubStr( TG1->TG1_DESCRI , 1 , 50 )
	oDesc:Refresh()

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fRetDano
Retorna a descricao do dano

@return

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Static Function fRetDano()

	If Empty( M->TG6_CODDAN )
	   Return .F.
	EndIf
	If !ExistCpo( "TG8" , M->TG6_CODDAN )
	   Return .F.
	EndIf

	TG8->( dbSeek( xFilial( "TG8" ) + M->TG6_CODDAN ) )
	cDescDan := SubStr( TG8->TG8_DESCRI , 1 , 50 )
	oDesDan:Refresh()

Return .t.

//---------------------------------------------------------------------
/*/{Protheus.doc} fValores
Inicializacoes iniciais

@return

@param nOpcx - Valor da  Operacao
@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Static Function fValores( nOpcx , cTipo )
	Local lFirst 	:= .T.
	Local lRet   	:= .T.
	Local nPeso  	:= 0
	Local aColsAli:= {}

	If nOpcx <> 3 .Or. lCpy
		dbSelectArea( "TG7" )
		dbSetOrder( 1 )//TG7_FILIAL+TG7_ORDEM+TG7_CODAVA+TG7_CODOPC
		dbSeek( xFilial( "TG7" ) + cOrdTG6 )
		While TG7->( !Eof() ) .and. xFilial( "TG7" ) == TG7->TG7_FILIAL .And. cOrdTG6 == TG7->TG7_ORDEM
			nPeso := 0

			If (nPosCol := aScan( aColsAli, {|x| x[1] == TG7->TG7_CODAVA }) )== 0

				If NGSEEK("TG2", TG7->TG7_CODAVA, 1, "TG2_TIPO") <> cTipo
					dbskip()
					Loop
				EndIf

				If lFirst
					If cTipo == "3" //Localizacao
						cAval2 := TG7->TG7_CODAVA
					ElseIF cTipo == "2" // Danos
						cAval1 := TG7->TG7_CODAVA
					Else // Perigo
						cAval := TG7->TG7_CODAVA
					EndIf
					lFirst := .F.
				EndIf

				aAdd( aColsAli , { TG7->TG7_CODAVA ,;
					NGRETSX3BOX( "TG2_TITULO" , NGSEEK("TG2", TG7->TG7_CODAVA, 1, "TG2_TITULO") ) ,;
					NGSEEK("TG2", TG7->TG7_CODAVA, 1, "TG2_DESCRI") ,;
					NGSEEK("TG2", TG7->TG7_CODAVA, 1, "TG2_PESO") ,;
					nPeso , .F. } )
				nPosCol := Len(aColsAli)
			EndIf
			If TG7->TG7_OK == "1"
				dbSelectArea( "TG2" )
				dbSetOrder( 1 ) //TG2_FILIAL+TG2_CODAVA
				If DbSeek( xFilial( "TG2" ) + TG7->TG7_CODAVA ) .And. TG7->TG7_PESO > 0
					nPeso := ( TG2->TG2_PESO * TG7->TG7_PESO ) / 100
				EndIf
				aColsAli[nPosCol,5] := nPeso
			EndIf
			dbSelectArea( "TG7" )
			dbSkip()
		EndDo


	Else
		dbSelectArea( "TG2" )
		dbSetOrder( 1 )
		dbSeek( xFilial( "TG2" ) )
		While TG2->( !Eof() ) .and. xFilial( "TG2" ) == TG2->TG2_FILIAL

		    If TG2->TG2_TIPO <> cTipo .Or. TG2->TG2_MSBLQL == "1"
		       dbskip()
		       Loop
		    EndIf

		    If lFirst
		       If cTipo == "3" // Localizção
					cAval2 := TG2->TG2_CODAVA
				ElseIF cTipo == "2" // Dano
					cAval1 := TG2->TG2_CODAVA
				Else // Perigo
					cAval := TG2->TG2_CODAVA
				EndIf
		       lFirst := .F.
		    EndIf

		    aAdd( aColsAli , { TG2->TG2_CODAVA , NGRETSX3BOX( "TG2_TITULO" , TG2->TG2_TITULO ) , TG2->TG2_DESCRI , TG2->TG2_PESO , nPeso , .F. } )

		 	dbSelectArea( "TG2" )
			dbSkip()
		EndDo

	EndIf

	If Len( aColsAli ) == 0
		aAdd( aColsAli , { "" , "" , "" , 0 , 0 , .F. } )
	EndIf

	If cTipo == "2" //Dano
		aColsDan := aClone( aColsAli )
	ElseIF cTipo == "3" //Localização
		aColsLoc := aClone( aColsAli )
	Else //Perigo
		aCols1 := aClone( aColsAli )
	EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fBMarkDan
Atualiza o total do resultado de acordo com a opcao escolhida

@return

@param cMarca - Valor da Marcao
@param oGet1 - Objeto para atualizacao

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Static Function fBMarkDan( cMarca , oGet1 , oMark1 )
	Local cFieldMarca	:= "TRB_OK"
	Local nPos 			:= 0

	nPos := aScan( aColsDan , { | x | x[ 1 ] == cAval1 } )

	If IsMark( cFieldMarca , cMarca , lInverte )
		aColsDan[ nPos , 6 ]	:= .F.
		cCodigo1 				:= ( cTRBG )->TRB_CODIGO
		nPeso1					:= ( cTRBG )->TRB_PESO
		nRecno1					:= Recno()
		nCont1					:= 0

		DbSelectArea( cTRBG )
		DbGotop()
		Do While !Eof()
			If !Empty( ( cTRBG )->TRB_OK )
				nCont1 ++
			EndIf
			dbskip()
		EndDo

		If nCont1 > 1
			DbSelectArea( cTRBG )
			If DbSeek( cCodigo1 )
				RecLock( cTRBG , .F. )
				( cTRBG )->TRB_OK := Space( 02 )
				MsUnLock( cTRBG )
			EndIf
		Else
			fGravaTRBB( , cTRBG , aColsDan , n1 , cTRBB )
			aColsDan[ n1 , 5 ] := ( aColsDan[ n1 , 4 ] * nPeso1 ) / 100
		EndIf

		DbGoTo(nRecno1)
		oMark1:oBrowse:Refresh()
		oGet1:Refresh()
	Else
		cCodigo1 := ( cTRBG )->TRB_CODIGO
		nPeso1   := ( cTRBG )->TRB_PESO
		nRecno1  := Recno()
		nCont1   := 0
		aColsDan[ n1 , 5 ] := 0
		fGravaTRBB( , cTRBG , aColsDan , n1  , cTRBB )
		oTotal1:Refresh()
		DbGoTo( nRecno1 )
		oMark1:oBrowse:Refresh()
		oGet1:Refresh()
		aColsDan[ nPos , 6 ] := .T.
	EndIf

	//fGravaTRBB()

Return .t.
//---------------------------------------------------------------------
/*/{Protheus.doc} fChangeCri
Atualiza de acordo com a troca de linha

@return

@param x - Linha atual
@param nOpcx - Valor da Operacao

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------

Static Function fChangeCri( x , nOpcx, cAvalia, cIndica, aCols, aMark , oMark , cTRBF, cTRBV )

	Local cCodigo := ""

	fGravaTRBB( , cTRBF , aCols , x , cTRBV )

	cAvalia := aCols[ x , 1 ]

	If nOpcx == 3
	   dbSelectArea( cTRBV )
	   dbSetOrder( 1 )
	   If dbSeek( cAvalia )
	      cCodigo := ( cTRBV )->TRB_CODIGO
	   EndIf

	Else
	   dbSelectArea( cTRBV )
	   dbSetOrder( 1 )
	   If dbSeek( cAvalia )
	      cCodigo := ( cTRBV )->TRB_CODIGO
	   Else
		  dbSelectArea( "TG5" )
		  dbSetOrder( 1 )
		  If dbSeek( xFilial( "TG5" ) + M->TG1_CODPER + cAvalia )
		     cCodigo := TG5->TG5_CODOPC
		  EndIf
	   EndIf
	EndIf

	dbSelectArea( cTRBF )
	dbCloseArea()
	fMarkOpc( cCodigo , cAvalia, nOpcx , cIndica , cTRBF, cTRBV, @aMark )
	oMark:oBrowse:Refresh()

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fMontaTree
Montagem da Tree

@return

@param lReset - Indica se deve remontar

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Function fMontaTree( lReset )

	Default lReset := .T.

	If Empty( M->TG1_CODPER )
	   Return .f.
	EndIf

	If lReset
		aLocal  := {}
		aLocal2 := {}

		oTree:Reset()

		// Carrega niveis selecionados
		SetNivMrk( M->TG1_CODPER )

		If !Empty( oTree:cArqTree )
			dbSelectArea( oTree:cArqTree )
			ZAP
		Endif

		dbSelectArea( cTRBSGA )
		ZAP
	Endif

	// Definica dos componentes da tree
	MDT853TREE( 1 , aMarcado , "MDT855CSAV" )

	oTree:Refresh()
	oTree:SetFocus()

Return .t.
//---------------------------------------------------------------------
/*/{Protheus.doc} fGravaTRBB
Grava o TRBB

@return

@param nOpcx - Valor da Operacao

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Static Function fGravaTRBB( nOpcx , cAlias , aCols , nPos , cTrbMark )

	If nOpcx <> 5
		DbSelectArea( cTrbMark )
		DbSetOrder( 1 )  //TRB_CODAVA+TRB_CODIGO
		If dbSeek( ( cAlias )->TRB_CODAVA )
			While !Eof() .And. ( cAlias )->TRB_CODAVA == ( cTrbMark )->TRB_CODAVA
				RecLock( cTrbMark , .F. )
				dbDelete()
				MsUnLock( cTrbMark )
				dbSkip()
			End
		EndIf
		dbSelectArea( cAlias )
		dbGotop()
		Do While !Eof()
			If !Empty( ( cAlias )->TRB_OK )
				dbSelectArea( cTrbMark )
				dbSetOrder(1)
				If !dbSeek( ( cAlias )->TRB_CODAVA + ( cAlias )->TRB_CODIGO )
					RecLock( cTrbMark , .T. )
					( cTrbMark )->TRB_CODAVA	:= ( cAlias )->TRB_CODAVA
					( cTrbMark )->TRB_CODIGO	:= ( cAlias )->TRB_CODIGO
					( cTrbMark )->TRB_PESO		:= ( cAlias )->TRB_PESO
					( cTrbMark )->TRB_RESULT	:= If( ( cAlias )->TRB_PESO > 0 , ( aCols[ nPos , 4 ] * ( cAlias )->TRB_PESO ) / 100 , 0 )
					MsUnLock( cTrbMark )
				EndIf
			EndIf
			dbSelectArea( cAlias )
			dbSkip()
		EndDo
	EndIf

Return .t.
//---------------------------------------------------------------------
/*/{Protheus.doc} fMontaResu
Inclui na tela campos de resultado da formula

@return

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Static Function fMontaResu( nTamMax , oObj )
	Local nColX1 := nTamMax - 75
	Local nColY1 := nTamMax - 60
	Local nColX2 := nTamMax - 135
	Local nColY2 := nTamMax - 120
	Local nColX3 := nTamMax - 195
	Local nColY3 := nTamMax - 180
	Local nColX4 := nTamMax - 255
	Local nColY4 := nTamMax - 240
	Local nColX5 := nTamMax - 315
	Local nColY5 := nTamMax - 300
	Local oLinhas1
	Private nCont  := 0

	dbSelectArea( "TG0" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "TG0" ) )
	Do While !Eof() .And. TG0->TG0_FILIAL == xFilial( "TG0" )

		//-------------------------------------------------------------------
		// Caso seja uma fórmula de Perguntas, então não exibe no desempenho.
		//-------------------------------------------------------------------

		If TG0->TG0_TPFORM == "2"
			DbSelectArea( "TG0" )
			DbSkip()
			Loop
		EndIf

		nCont++
		If nCont == 1
			cLabel := TG0->TG0_CODFOR
			@ 015 , nColX1 Say OemToAnsi( cLabel ) Size 037 , 007 Of oObj Pixel
			@ 013 , nColY1 MsGet oTotal1 Var nTotal1 Size 037 , 006 Of oObj Pixel When .F.
			oTotal1:blDblClick := { | | fFormula( nTotal1 ) }
		ElseIf nCont	== 2
			cLabel1 := TG0->TG0_CODFOR
			@ 015 , nColX2 Say OemToAnsi( cLabel1 ) Size 037 , 007 Of oObj Pixel
			@ 013 , nColY2 MsGet oTotal2 Var nTotal2 Size 037 , 006 Of oObj Pixel When .F.
			oTotal2:blDblClick := { | | fFormula( nTotal2 ) }
		ElseIf nCont == 3
			cLabel2 := TG0->TG0_CODFOR
			@ 015 , nColX3 Say OemToAnsi( cLabel2 ) Size 037 , 007 Of oObj Pixel
			@ 013 , nColY3 MsGet oTotal3 Var nTotal3 Size 037 , 006 Of oObj Pixel When .F.
			oTotal3:blDblClick := { | | fFormula( nTotal3 ) }
		ElseIf nCont == 4
			cLabel3 := TG0->TG0_CODFOR
			@ 015 , nColX4 Say OemToAnsi( cLabel3 ) Size 037 , 007 Of oObj Pixel
			@ 013 , nColY4 MsGet oTotal4 Var nTotal4 Size 037 , 006 Of oObj Pixel When .F.
			oTotal4:blDblClick := { || fFormula(nTotal4)}
		ElseIf nCont == 5
			cLabel4 := TG0->TG0_CODFOR
			@ 015 , nColX5 Say OemToAnsi( cLabel4 ) Size 037 , 007 Of oObj Pixel
			@ 013 , nColY5 MsGet oTotal5 Var nTotal5 Size 037 , 006 Of oObj Pixel When .f.
			oTotal5:blDblClick := { | | fFormula( nTotal5 ) }
		EndIf

		DbSkip()
	EndDo

Return .t.
//---------------------------------------------------------------------
/*/{Protheus.doc} fBMarkPer
Atualiza o total do resultado de acordo com a opcao escolhida

@return

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Static Function fBMarkPer( cMarca , oGet , oMark )

	Local cFieldMarca	:= "TRB_OK"
	Local nPos 			:= 0

	nPos	:= aScan( aCols1 , { | x | x[ 1 ] == cAval } )
	//n		:= oGet:nAt
 	//If aCols1[ n , 4 ] > 0
		If IsMark( cFieldMarca , cMarca , lInverte )
			aCols1[ nPos , 6 ] 		:= .F.
			cCodigo1 				:= ( cTRBX )->TRB_CODIGO
			nPeso1					:= ( cTRBX )->TRB_PESO
			nRecno1					:= Recno()
			nCont1					:= 0

			DbSelectArea( cTRBX )
			DbGotop()
			Do While !Eof()
				If !Empty( ( cTRBX )->TRB_OK )
					nCont1 ++
				EndIf
				dbskip()
			EndDo

			If nCont1 > 1
				DbSelectArea( cTRBX )
				If DbSeek( cCodigo1 )
					RecLock( cTRBX , .F. )
					( cTRBX )->TRB_OK := Space( 02 )
					MsUnLock( cTRBX )
				EndIf
			Else
				fGravaTRBB( , cTRBX , aCols1 , n , cTRBA )
				oTotal1:Refresh()
				aCols1[ n , 5 ] := ( aCols1[ n , 4 ] * nPeso1 ) / 100
			EndIf

			DbGoTo(nRecno1)
			oMark:oBrowse:Refresh()
			oGet:Refresh()
		Else
			cCodigo1 := ( cTRBX )->TRB_CODIGO
			nPeso1   := ( cTRBX )->TRB_PESO
			nRecno1  := Recno()
			nCont1   := 0
			aCols1[ n , 5 ] := 0
			fGravaTRBB( , cTRBX , aCols1 , n , cTRBA )
			oTotal1:Refresh()
			DbGoTo( nRecno1 )
			oMark:oBrowse:Refresh()
			oGet:Refresh()
			aCols1[ nPos , 6 ] := .T.
		EndIf
  	/*Else
		nRecno1 := Recno()
		fGravaTRBB( , cTRBX , aCols1 , n , cTRBA )
		DbGoTo(nRecno1)
		oMark:oBrowse:Refresh()
		oGet:Refresh()
	EndIf*/
	//fGravaTRBB()

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fMarkOpc
Monta um MarkBrowse com as respostas das avaliacoes

@return

@param cCodigo - Array dos Codigos das Opcoes
@param cCodAva - Codigo da Avaliacao
@param nOpc - Valor da Operacao
@param cIndica - Indica a avalição a ser gravada

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Static Function fMarkOpc( cCodigo , cCodAva , nOpc , cIndica, cTRBF, cTRBV, aMark)

	Local cCheck	:= ""

	aDBF := {}
	aAdd( aDBF , { "TRB_OK"       , "C" , 02 , 0 } )
	aAdd( aDBF , { "TRB_CODAVA"   , "C" , 03 , 0 } )
	aAdd( aDBF , { "TRB_CODIGO"   , "C" , 03 , 0 } )
	aAdd( aDBF , { "TRB_DESCRI"   , "C" , 40 , 0 } )
	aAdd( aDBF , { "TRB_PESO"     , "N" , 03 , 0 } )

	oTempTRB1 := FWTemporaryTable():New( cTRBF, aDBF )
	oTempTRB1:AddIndex( "1", {"TRB_CODIGO","TRB_CODAVA"} )
	oTempTRB1:Create()

	aAdd( aMark , { "TRB_OK"       , NIL , " "     , } )
	aAdd( aMark , { "TRB_CODIGO"   , NIL , STR0032 , } ) //"Código"
	aAdd( aMark , { "TRB_DESCRI"   , NIL , STR0033 , } ) //"Respostas"
	aAdd( aMark , { "TRB_PESO"     , NIL , STR0034 	, } )  //"Peso %"

	If cCodigo == Nil// .And. nOpc <> 4
		If nOpc <> 3 .OR. lCpy
			dbSelectArea( "TG7" )
			dbSetOrder( 1 )//TG7_FILIAL+TG7_ORDEM+TG7_CODAVA+TG7_CODOPC
			dbSeek( xFilial( "TG7" ) + cOrdTG6 )
			While !Eof() .and. TG7->TG7_ORDEM == cOrdTG6
				If TG7->TG7_INDICA == cIndica .And. TG7->TG7_OK == "1"
				   dbSelectArea( cTRBV )
				   dbSetOrder( 1 )
				   If !dbSeek( TG7->TG7_CODAVA + TG7->TG7_CODOPC )
					  RecLock( cTRBV , .T. )
					  ( cTRBV )->TRB_CODAVA := TG7->TG7_CODAVA
					  ( cTRBV )->TRB_CODIGO := TG7->TG7_CODOPC
					  ( cTRBV )->TRB_PESO   := TG7->TG7_PESO
					  ( cTRBV )->TRB_RESULT := ( aCols1[ n1 , 4 ] * TG7->TG7_PESO ) / 100
					  MsUnLock( cTRBV )
				   EndIf
				EndIf
			   dbSelectArea( "TG7" )
			   dbSkip()
			End
		EndIf
	EndIf

	If nOpc <> 3
		dbSelectArea( "TG7" )
		dbSetOrder( 1 )//TG7_FILIAL+TG7_ORDEM+TG7_CODAVA+TG7_CODOPC
		dbSeek( xFilial( "TG7" ) + cOrdTG6 + cCodAva )
		While !Eof() .and. xFilial( "TG7" ) == TG7->TG7_FILIAL .And.;
			TG7->TG7_CODAVA == cCodAva .And. TG7->TG7_ORDEM == cOrdTG6

		  	cCheck := ""
			dbSelectArea( cTRBV )
			dbSetOrder( 1 )
			If dbSeek( cCodAva + TG7->TG7_CODOPC )
		  		cCheck := cMarca
		 	EndIf

			RecLock( cTRBF , .T. )
			( cTRBF )->TRB_OK      := cCheck
			( cTRBF )->TRB_CODAVA  := TG7->TG7_CODAVA
			( cTRBF )->TRB_CODIGO  := TG7->TG7_CODOPC
			( cTRBF )->TRB_DESCRI  := NGSEEK( "TG3" , TG7->(TG7_CODAVA + TG7_CODOPC) , 1 , "TG3_OPCAO" )
			( cTRBF )->TRB_PESO    := TG7->TG7_PESO
			MsUnLock( cTRBF )

			dbSelectArea( "TG7" )
			dbSkip()
		End
	Else
		dbSelectArea( "TG3" )
		dbSetOrder( 1 )
		dbSeek( xFilial( "TG3" ) + cCodAva )
		While !Eof() .and. xFilial( "TG3" ) == TG3->TG3_FILIAL .And.;
			TG3->TG3_CODAVA == cCodAva

			cCheck := ""

			If TG3->TG3_MSBLQL == "1"
				("TG3")->(Dbskip())
				Loop
			EndIf

		   dbSelectArea( cTRBV )
			dbSetOrder( 1 )
			If dbSeek( cCodAva + TG3->TG3_CODOPC )
				cCheck := cMarca
			Else
				cCheck := ""
			EndIf

			RecLock( cTRBF , .T. )
			( cTRBF )->TRB_OK      := cCheck
			( cTRBF )->TRB_CODAVA  := TG3->TG3_CODAVA
			( cTRBF )->TRB_CODIGO  := TG3->TG3_CODOPC
			( cTRBF )->TRB_DESCRI  := TG3->TG3_OPCAO
			( cTRBF )->TRB_PESO    := TG3->TG3_PESO
			MsUnLock( cTRBF )

			dbSelectArea( "TG3" )
			dbSkip()
		End
	EndIf

	( cTRBF )->( dbGoTop() )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fFormula
Resultado atraves da Formula

@return

@param nResultado - Valor do Resultado

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Static Function fFormula( nResultado )

	Local lRet	:= .T.

	aOldArea	:= GetArea()
nResultado	:= If(nResultado == nil .Or. Valtype( nResultado ) <> "N",0,nResultado)

	DbSelectArea( "TG4" )
	DbSetOrder( 1 )
	DbSeek( xFilial( "TG4" ) )
	While TG4->( !Eof() ) .and. xFilial( "TG4" ) == TG4->TG4_FILIAL
		If nResultado >= TG4->TG4_LIMMIN .and. nResultado <= TG4->TG4_LIMMAX
			cCodCla := TG4->TG4_CODCLA
			cClasse := TG4->TG4_DESCRI
		EndIf
		TG4->( DbSkip() )
	End

	If nResultado == 0
		cCodCla := ""
		cClasse := ""
	Endif

	If Empty( cCodCla ) .AND. Empty( cClasse )
		ShowHelpDlg( STR0035 , { STR0036 } , 2 , { STR0037 } , 2 ) //"ATENÇÃO"###"As opções necessárias ao cálculo da fórmula não estão preenchidos corretamente"###"Selecionar opções das avaliações na segunda pasta."
		lRet := .F.
	Endif

	oClasse:Refresh()
	RestArea( aOldArea )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fCalcular
Realiza o calculo

@return

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Static Function fCalcular( nTotRet )
	Local xResult
	Local i
	Local nAval		:= 1,nFor := 1
	Local Ind		:= 1 ,nCount := 0
	Local nTotal	:= 0 , nHif := 0 , nQtd := 0
	Local cStrForm , cAlias
	Local cArquivo
	Local cVar		:= ""
	Local cCampo	:= ""
	Local cSavAlias	:= Alias()
	Local lSair		:= .F.
	Local lQuit		:= .F.
	Local bBlock	:= ErrorBlock(), bErro := ErrorBlock( { | e | ChecErro( e ) } )
	Local aAlias	:= {}, aAval := {}
	Local aCampo	:= {}
	Local nA		:= 0
	Local aPesosForm := {}

	Default nTotRet := 0

	DbSelectArea( "TG0" )
	DbSetOrder( 1 )
	DbSeek( xFilial( "TG0" ) )
	Do While !Eof() .and. TG0->TG0_FILIAL == xFilial( "TG0" )

		If NGCADICBASE("TG0_TPFORM","A","TG0",.F.) .And. TG0->TG0_TPFORM <> '1'
			dbSelectArea( "TG0" )
			dbSkip()
			Loop
		EndIf

		cStrForm	:= Upper( TG0->TG0_FORMUL )
		aCampo		:= {}
		aAlias		:= {}
		cCampo		:= ''
		lSair		:= .f.
		nTotal		:= 0
		Ind			:= 1
		BEGIN SEQUENCE
			Do While !lSair
				nAcha := 0
				nAcha := AT( "#" , SubStr( cStrForm , nTotal + 1 , Len( cStrForm ) ) )
				If nAcha > 0
					nTotal	+= nAcha
					nHif 	:= nAcha
					aAdd( aAlias , { nAcha , nTotal } )
					nQtd ++
				Else
					lSair := .T.
				EndIf
			EndDo
		END SEQUENCE

		BEGIN SEQUENCE
		For i:= 1 to Len( aAlias ) - 1
			If Mod( i , 2 ) <> 0
				aAdd( aAval , { SubStr( cStrForm , aAlias[ i , 2 ] + 1 , aAlias[ i + 1 , 1 ] - 1 ) } )
			EndIf
		Next
		END SEQUENCE

		TexLinha := cStrForm

	   	// Monta Array Com Todas os Criterios Avaliados por Peso Para verificar
		// se os critérios controlados por PESO e fazem parte da Formula estão preenchidos
		aPesosForm := {}
		For nA := 1 To Len( aCols1 )
			If aCols1[ nA , 4 ] > 0
				aAdd( aPesosForm , { aCols1[ nA , 1 ] , aCols1[ nA , 2 ] , aCols1[ nA , 3 ] , aCols1[ nA , 4 ] , aCols1[ nA , 5 ] , aCols1[ nA , 6 ] } )
			Endif
		Next

		For nA := 1 To Len( aColsDan )
			If aColsDan[ nA , 4 ] > 0
				aAdd( aPesosForm , { aColsDan[ nA , 1 ] , aColsDan[ nA , 2 ] , aColsDan[ nA , 3 ] , aColsDan[ nA , 4 ] , aColsDan[ nA , 5 ] , aColsDan[ nA , 6 ] } )
			Endif
		Next

		For nA := 1 To Len( aColsLOC )
			If aColsLOC[ nA , 4 ] > 0
				aAdd( aPesosForm , { aColsLOC[ nA , 1 ] , aColsLOC[ nA , 2 ] , aColsLOC[ nA , 3 ] , aColsLOC[ nA , 4 ] , aColsLOC[ nA , 5 ] , aColsLOC[ nA , 6 ] } )
			Endif
		Next

		BEGIN SEQUENCE
			For i := 1 To Len( TexLinha )
				If SubStr( TexLinha , Ind , 1 ) == "#"
					If nCount > 1
						nCount		:= 0
						nPos		:= 0
						nPos1		:= 0
						cAvaliacao	:= aAval[ nAval , 1 ]
						nPos1		:= aScan( aPesosForm , { | x | AllTrim( x[ 3 ] ) == AllTrim( cAvaliacao ) } )
						If nPos1 > 0
							aAdd( aCampo , { aPesosForm[ nPos1 , 5 ] } )
						EndIf

						If nPos1 == 0
							Help( " " , 1 , STR0035 , , STR0038 + cAvaliacao , 3 , 1 )  //"ATENÇÃO"###"Nao existe a avaliação "
							Return .F.
						EndIf
						Ind++
						nAval++
					EndIf
				EndIf
				If SubStr( TexLinha , Ind , 1 ) <> "#" .and. nCount == 0
					aAdd( aCampo , { SubStr( TexLinha , Ind , 1 ) } )
				Else
					nCount ++
				EndIf
				Ind++
			Next
		END SEQUENCE

		BEGIN SEQUENCE
			For i := 1 To Len( aCampo )
				If ValType( aCampo[ i , 1 ] ) == "N"
					cCampo += Str( aCampo[ i , 1 ] )
				Else
					cCampo += aCampo[ i , 1 ]
				EndIf
			Next i
			xResult := &cCampo
		END SEQUENCE

		cResult := xResult
		If ValType( cResult ) == "C"
			cResult := Val( cResult )
		Endif
		lWhen := .T.
		If nFor == 1
			nTotal1 := cResult
			oTotal1:Refresh()
		ElseIf nFor == 2
			nTotal2 := cResult
			oTotal2:Refresh()
		ElseIf nFor == 3
			nTotal3 := cResult
			oTotal3:Refresh()
		ElseIf nFor == 4
			nTotal4 := cResult
			oTotal4:Refresh()
		ElseIf nFor == 5
			nTotal5 := cResult
			oTotal5:Refresh()
		EndIf

		DbSelectArea( cSavAlias )
		ErrorBlock( bBlock )
		nFor++
		DbSelectArea( "TG0" )
		DbSkip()
	EndDo

	If !fFormula( nTotal1 )
		Return .F.
	Endif

	nTotRet := nTotal1

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fChangeBMP
Troca a cor dos folders

@return

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Static Function fChangeBMP()
	Local nPos := 0
	Local lTG9 := .F.
	Local lTG6 := .F.
	Local j

	If oTree:nTotal <= 0
		MsgStop( STR0039 , STR0040 )  //"É necessário escolher um Perigo para visualizar a Estrutura."###"Aviso"
		Return .F.
	EndIf

	DbSelectArea( "TG9" )
	DbSetOrder( 1 )
	If !DbSeek( xFilial( "TG9" ) + M->TG1_CODPER + "001" + SubStr( oTree:GetCargo() , 1 , 3 ) )
		MsgStop( STR0041 , STR0035 ) //"Escolha uma localização que esteja marcada como Presença de Perigo."###"ATENÇÃO"
		Return .F.
	Else
		dbSelectArea( oTree:cArqTree )
		If SubStr( oTree:getCargo() , 7 , 1 ) == "2"

			// Verifica se ha um item 'Sendo Avaliado'
					dbSelectArea( oTree:cArqTree )
			If aScan( aLocal2 , { | x | x[2] .And. x[1] <> SubStr( oTree:GetCargo() , 1 , 3 ) } ) > 0
						Help( " " , 1 , STR0035 , , STR0042 , 3 , 1 ) //"ATENÇÃO"###"Não é possível avaliar mais de uma localização."
						Return .F.
					EndIf

			// Verifica se, atualmente, o nivel esta inativo
			If !Sg100NvAtv( Substr( oTree:GetCargo() , 1 , 3 ), cCodest , .T. )
				Return .F.
			Endif

			// Altera referencia do item da tree para a situacao 'Sendo Avaliado' [ Folder Amarelo]
			oTree:ChangeBmp( "Folder5" , "Folder6" )
			( oTree:cArqTree )->T_CARGO := SubStr( oTree:getCargo() , 1 , 6 ) + "3"

			nPos := aScan( aLocal2 , { | x | x[ 1 ] == SubStr( oTree:GetCargo() , 1 , 3 ) } )
			If nPos > 0
				aLocal2[ nPos ][ 2 ] := .T.
			Else
				aAdd( aLocal2 , { SubStr( oTree:GetCargo() , 1 , 3 ) , .T. } )
			EndIf

		Else
			// Altera referencia do item da tree para a situacao 'Presenca de Perigo' [ Folder Vermelho ]
			oTree:ChangeBmp( "Folder7" , "Folder8" )
			( oTree:cArqTree )->T_CARGO := SubStr( oTree:getCargo() , 1 , 6 ) + "2"

			nPos := aScan( aLocal2 , { | x | x[ 1 ] == SubStr( oTree:GetCargo() , 1 , 3 ) } )
			If nPos > 0
				aLocal2[ nPos , 2 ] := .F.
			Else
				aAdd( aLocal2 , { SubStr( oTree:GetCargo() , 1 , 3 ) , .F. } )
			EndIf
		EndIf
	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fRMarkPer
Marca a primeira opcao de Caracterizacao se houver

@return

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Function fRMarkPer( nOpcx , oMark )

	If nOpcx == 3
		DbSelectArea( cTRBA )
		ZAP
	Endif

	DbSelectArea( "TG5" )
	DbSetOrder( 1 )
	DbSeek( xFilial( "TG5" ) + M->TG1_CODPER )
	While !Eof() .and. TG5->TG5_CODPER == M->TG1_CODPER
	   DbSelectArea( cTRBA )
	   DbSetOrder( 1 )
	   If !DbSeek( TG5->TG5_CODAVA + TG5->TG5_CODOPC )
		  RecLock( cTRBA , .T. )
		  ( cTRBA )->TRB_CODAVA := TG5->TG5_CODAVA
		  ( cTRBA )->TRB_CODIGO := TG5->TG5_CODOPC
		  MsUnLock( cTRBA )
	   EndIf
	   DbSelectArea( "TG5" )
	   DbSkip()
	End


	dbSelectArea( cTRBX )
	dbGoTop()
	While !Eof()
		RecLock( cTRBX , .F. )
		( cTRBX )->TRB_OK := ""
		MsUnLock( cTRBX )
		dbSelectArea( cTRBX )
		dbSkip()
	End

	dbSelectArea( "TG5" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "TG5" ) + M->TG1_CODPER )
	While !Eof() .and. TG5->TG5_FILIAL == xFilial( "TG5" ) .and.;
		TG5->TG5_CODPER == M->TG1_CODPER

		dbSelectArea( cTRBX )
		dbSetOrder( 1 )
		If dbSeek( TG5->TG5_CODOPC + TG5->TG5_CODAVA )
			RecLock( cTRBX , .F. )
			( cTRBX )->TRB_OK := cMarca
			MsUnLock( cTRBX )
		EndIf
		dbSelectArea( "TG5" )
		dbSkip()
	End

	( cTRBX )->( dbGoTop() )
	oMark:oBrowse:Refresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fObrigatorio
Faz validacoes dos campos obrigatorios e grava

@return

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Static Function fObrigatorio( nOpcx , lFinal )

	Local aOldArea := GetArea() // Guarda variaveis de alias e indice

	Default lFinal := .F.//Indica se o desempenho está sendo finalizado

	If Empty( M->TG1_CODPER )
		ShowHelpDlg( STR0035 , { STR0043 } , 2 , { STR0044 } , 2 ) //"ATENÇÃO"###"As opções necessárias ao cálculo da fórmula não estão preenchidos corretamente - Perigo"###"Informe um perigo na primeira pasta."
		Return .f.
	EndIf

	If Empty( M->TG6_CODDAN )
		ShowHelpDlg( STR0035 , { STR0045 } , 2 , { STR0046 } , 2 ) //"ATENÇÃO"###"As opções necessárias ao cálculo da fórmula não estão preenchidos corretamente - Dano"###"Informe um dano na segunda pasta."
		Return .f.
	EndIf

	If nTotal1 == 0
		ShowHelpDlg( STR0035 , { STR0047 } , 2 , { STR0048 } , 2 ) //"ATENÇÃO"###"Avaliação sem resultado."###"Clique no botão calcular para gerar um resultado."
		Return .F.
	EndIf

	If Len( aLocal2 ) == 0
		Help( " " , 1 , STR0035 , , STR0049 , 3 , 1 ) //"ATENÇÃO"###"Escolha em que área o Perigo está sendo avaliado."
		Return .F.
	Else
		nPos := aScan( aLocal2 , { | x | x[ 2 ] == .T. } )
		If nPos == 0
			Help( " " , 1 , STR0035 , , STR0049 , 3 , 1 ) //"ATENÇÃO"###"Escolha em que área o Perigo está sendo avaliado."
			Return .F.
		EndIf
	EndIf

	If Empty( cCodCla ) .AND. Empty( cClasse )
		ShowHelpDlg( STR0035 , { STR0036 } , 2 , { STR0037 } , 2 ) //"ATENÇÃO"###"As opções necessárias ao cálculo da fórmula não estão preenchidos corretamente"###"Selecionar opções das avaliações na segunda pasta."
		cCodCla := ""
		cClasse := ""
		Return .F.
	Endif

	If !lFinal

		If nOpcx != 5
			If !fCalcular()
				Return .F.
			Endif
		Endif

		If !fGravaAva( nOpcx )
			Return .F.
		EndIf

	Endif

	RestArea( aOldArea )
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fGravaAva
Grava a avaliacao

@return

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Function fGravaAva( nOpcx )

	Local i, j
	Local nPos, cLocal, cOrd
	Local nTab			:= 0
	Local cCodClasse	:= ""
	Local cNumRis		:= ""
	Local cTabela		:= ""
	Local cCheck		:= ""
	Local aAliasTRB	:= { cTRBA, cTRBB, cTRBC }//Perigo, Dano, Localizacao
	Local aHeadGra		:= {}
	Local aColsGra		:= {}
	Local lReavali
	Local cCodOrdem

	Private cOrdGet		:= ""

	If lCpy .Or. lMDT855Rea
		cOrd 			:= cOrdemOld
	Else
		cOrd 			:= cOrdTG6
	Endif

	nPos 				:= aScan( aLocal2, { | x | x[ 2 ] == .T. } )
	cLocal				:= aLocal2[ nPos , 1 ]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Manipula a tabela TG6³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If nOpcx == 3
		//Procura uma avaliacao semelhante
		dbSelectArea( "TG6" )
		dbSetOrder( 5 ) //TG6_FILIAL+TG6_CODEST+TG6_CODNIV+TG6_CODPER+TG6_CODDAN
		If dbSeek( xFilial( "TG6" ) + "001" + cLocal + M->TG1_CODPER + M->TG6_CODDAN )
			If !lMDT855Rea .And. !MsgYesNo( STR0050 + " (" + TG6->TG6_ORDEM + ") " + STR0051 + CHR( 13 ) + CHR( 10 ) + STR0052 , STR0035 ) //"Já existe uma avaliação"###"com a mesma chave (Nivel+Perigo+Dano)."###"Deseja finalizá-la e tornar a avaliação atual como vigente?"###"ATENÇÃO"
				Return .F.
			Else
				//Cancela avaliação antiga gerando histórico
				If !MDT855HIST( nOpcx , TG6->TG6_ORDEM , cOrd )
					Return .F.
				Endif
				If !Empty( TG6->TG6_NUMRIS )
					If Aviso( STR0035 , STR0053 , { STR0054 , STR0055 } ) == 2 //"ATENÇÃO"###"Para esta avaliação existe um risco gerado. Deseja eliminar o risco ou mantê-lo, vinculando a nova avaliação?"###"Manter"###"Eliminar"
					 	fElimRis( dDtEmis , TG6->TG6_NUMRIS )
					Else
					 	cNumRis := TG6->TG6_NUMRIS
					EndIf
				EndIf
			Endif
		EndIf
	EndIf

	cCodOrdem := cOrd

	DbSelectArea( "TG6" )
	DbSetOrder( 1 )
	If DbSeek( xFilial( "TG6" ) + cOrd + M->TG1_CODPER )
		RecLock( "TG6" , .F. )
	Else
		RecLock( "TG6" , .T. )
	EndIf

	If nOpcx <> 5
		TG6->TG6_FILIAL := xFilial( "TG6" )
		TG6->TG6_CODPER := M->TG1_CODPER
		TG6->TG6_CODDAN := M->TG6_CODDAN
		TG6->TG6_CODEST := "001"
		TG6->TG6_CODNIV := cLocal
		TG6->TG6_DTRESU := dDtEmis
		TG6->TG6_ORDEM  := cOrd
		TG6->TG6_DESCRI := M->TG6_DESCRI
		TG6->TG6_SITUAC := M->TG6_SITUAC
	 	If !Empty( cNumRis )
	   	TG6->TG6_NUMRIS := cNumRis
	   EndIf
		TG6->TG6_REVISA := M->TG6_REVISA
		aAreaTG6 := TG6->( GetArea() )

		DbSelectArea( "TG4" )
		DbSetOrder( 2 )
		If DbSeek( xFilial( "TG4" ) + cClasse )
			TG6->TG6_CODCLA := TG4->TG4_CODCLA
		Endif
		RestArea( aAreaTG6 )
	Else
		DbDelete()
	EndIf

	MsUnLock( "TG6" )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Manipula a tabela TGN³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcx <> 5
		dbSelectArea( "TG0" )
		dbSetOrder( 1 )
		dbSeek( xFilial( "TG0" ) )
		nFor := 1
		While TG0->( !Eof() ) .And. nFor <= _nQtdFor_
			dbSelectArea( "TGN" )
			dbSetOrder( 1 ) //TGN_FILIAL+TGN_ANALIS+TGN_CODFOR
			If dbSeek( xFilial( "TGN" ) + cOrd + TG0->TG0_CODFOR )
				RecLock( "TGN" , .F. )
			Else
				RecLock( "TGN" , .T. )
				TGN->TGN_FILIAL := xFilial( "TGN" )
				TGN->TGN_ANALIS := cOrd
				TGN->TGN_CODFOR := TG0->TG0_CODFOR
			EndIf
			TGN->TGN_RESULT := &( "nTotal" + cValToChar( nFor ) )
			TGN->( MsUnLock() )
			nFor++
			dbSelectArea( "TG0" )
			TG0->( dbSkip() )
  		End
    Else
    	dbSelectArea( "TGN" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "TGN" ) + cOrd )
		    While TGN->( !Eof() ) .And. TGN->TGN_FILIAL == xFilial( "TGN" ) .And. ;
		    		TGN->TGN_ANALIS == cOrd
			    RecLock( "TGN" , .F. )
			    TGN->( dbDelete() )
			    TGN->( MsUnLock() )
				TGN->( dbSkip() )
			End
		EndIf
    EndIf
	//-----------------------
	// Manipula a tabela TG7
	//-----------------------
	If nOpcx == 3
		dbSelectArea( "TG3" )
		dbSetOrder( 1 )
		dbSeek( xFilial( "TG3" ) )
		While TG3->( !Eof() )
			If TG3->TG3_MSBLQL == "1"
				TG3->( dbSkip() )
				Loop
			EndIf

			dbSelectArea( "TG7" )
			RecLock( "TG7" , .T. )
			TG7->TG7_FILIAL := xFilial( "TG7" )
			TG7->TG7_OK     := "2"
			TG7->TG7_CODAVA := TG3->TG3_CODAVA
			TG7->TG7_CODOPC := TG3->TG3_CODOPC
			TG7->TG7_PESO   := TG3->TG3_PESO
			TG7->TG7_INDICA := NGSEEK( "TG2", TG3->TG3_CODAVA , 1 , "TG2_TIPO" )
			TG7->TG7_ORDEM  := cOrd
			TG7->( MsUnLock() )
			TG3->( dbSkip() )
		End
	ElseIf nOpcx == 5
		DbSelectArea( "TG7" )
		DbSetOrder(1)//TG7_FILIAL+TG7_ORDEM+TG7_CODAVA+TG7_CODOPC
		dbSeek( xFilial( "TG7" ) + cOrd )
		While !Eof() .And. TG7->TG7_FILIAL == xFilial('TG7') .And. TG7->TG7_ORDEM == cOrd
			RecLock("TG7",.F.)
			DbDelete()
			MsUnLock("TG7")
			TG7->(dbSkip())
		End
	EndIf

	If nOpcx <> 5
		DbSelectArea("TG7")
		dbSetOrder(1) //TG7_FILIAL+TG7_ORDEM+TG7_CODAVA+TG7_CODOPC
		dbSeek( xFilial( "TG7" ) + cOrd )
		Do While ("TG7")->( !Eof() ) .And. TG7->TG7_ORDEM == cOrd
			nTRB := Val( NGSEEK( "TG2", TG7->TG7_CODAVA , 1 , "TG2_TIPO" ) )

      	dbSelectArea( aAliasTRB[nTRB] )
      	dbSetOrder( 1 ) // TRB_CODAVA + TRB_CODOPC
			If dbSeek( TG7->TG7_CODAVA + TG7->TG7_CODOPC )
				cCheck	:= "1"
			Else
				cCheck	:= "2"
			EndIf

			dbSelectArea( "TG7" )
			RecLock("TG7",.F.)
				TG7->TG7_OK := cCheck
			MsUnLock("TG7")

			TG7->(DbSkip())

		EndDo
	EndIf

	For nTab := 1 To Len( aTabGet )
		cOrdGet := cOrd
		cTabela := aTabGet[nTab,1]
		If cTabela == "TGF"
			aHeadGra := aClone( aHeadPA )
			aColsGra := aClone( aColsPA )
		ElseIf cTabela == "TGG"
			aHeadGra := aClone( aHeadPE )
			aColsGra := aClone( aColsPE )
		ElseIf cTabela == "TGH"
			aHeadGra := aClone( aHeadOB )
			aColsGra := aClone( aColsOB )
		ElseIf cTabela == "TGI"
			aHeadGra := aClone( aHeadMO )
			aColsGra := aClone( aColsMO )
		EndIf
		nPosCod := aScan( aHeadGra , { | x | Trim( Upper( x[ 2 ] ) ) == aTabGet[ nTab , 3 ] } )
		nOrd 	:= 1
		cKey 	:= xFilial( cTabela ) + cOrdGet
		cWhile	:= "xFilial('" + cTabela + "') + cOrdGet == " + cTabela + "->" + PrefixoCPO( cTabela ) + "_FILIAL+" + cTabela + "->" + PrefixoCPO( cTabela ) + "_ANALIS"
		If nOpcx == 5
			dbSelectArea( cTabela )
			dbSetOrder( nOrd )
			dbSeek( cKey )
			While !Eof() .and. &( cWhile )
				RecLock( cTabela , .F. )
				DbDelete()
				MsUnLock( cTabela )
				dbSelectArea( cTabela )
				dbSkip()
			End
		Else
			If Len( aColsGra ) > 0
				//Coloca os deletados por primeiro
				aSORT( aColsGra , , , { | x , y | x[ Len( aColsGra[ 1 ] ) ] .And. !y[ Len( aColsGra[ 1 ] ) ] } )

				For i := 1 to Len( aColsGra )
					If !aColsGra[ i , Len( aColsGra[ i ] ) ] .and. !Empty( aColsGra[ i , nPosCod ] )
						dbSelectArea( cTabela )
						dbSetOrder( nOrd )
						If dbSeek( xFilial( cTabela ) + cOrdGet + aColsGra[ i , nPosCod ] )
							RecLock( cTabela , .F. )
						Else
							RecLock( cTabela , .T. )
						Endif
						For j := 1 to FCount()
							If "_FILIAL" $ Upper( FieldName( j ) )
								FieldPut( j , xFilial( cTabela ) )
							ElseIf "_ANALIS" $ Upper( FieldName( j ) )
								FieldPut( j , cOrdGet )
							ElseIf ( nPos := aScan( aHeadGra , { | x | Trim( Upper( x[ 2 ] ) ) == Trim( Upper( FieldName( j ) ) ) } ) ) > 0
								FieldPut( j , aColsGra[ i , nPos ] )
							Endif
						Next j
						MsUnlock( cTabela )
					Elseif !Empty( aColsGra[ i , nPosCod ] )
						dbSelectArea( cTabela )
						dbSetOrder( nOrd )
						If dbSeek( xFilial( cTabela ) + cOrdGet + aColsGra[ i , nPosCod ] )
							RecLock( cTabela , .F. )
							dbDelete()
							MsUnlock( cTabela )
						Endif
					Endif
				Next i
			Endif
			dbSelectArea( cTabela )
			dbSetOrder( nOrd )
			dbSeek( cKey )
			While !Eof() .and. &( cWhile )
				If aScan( aColsGra , { | x | x[ nPosCod ] == &( cTabela + "->" + aTabGet[ nTab , 3 ] ) .AND. !x[ Len( x ) ] } ) == 0
					RecLock( cTabela , .F. )
					DbDelete()
					MsUnLock( cTabela )
				Endif
				dbSelectArea( cTabela )
				dbSkip()
			End
		Endif
	Next nTab

	CursorArrow()
	fGravaRes()

	dbSelectArea( "TGD" )
	dbSetOrder( 4 )
	lReavali := dbSeek( xFilial( "TGD" ) + cCodOrdem )
	If nOpcx == 5 .And. lReavali .And. !( lCpy .Or. lMDT855Rea ) .And. ;
		MsgYesNo( "Esta análise é decorrente de uma reavaliação, deseja excluir a análise anterior?" , STR0035 )
		fExcluiReav( cCodOrdem )
	EndIf

Return .t.
//---------------------------------------------------------------------
/*/{Protheus.doc} fDocumento
Visualiza documento relacionado a estrutura

@return

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Function fDocumento( nTipo )
	Local oDlgDem,oGet
	Local aNoFields := {}
	Private aCols 	:= {},aHeader := {}

	If nTipo = 1

		If Empty( M->TG1_CODPER )
		   Return .t.
		EndIf

		aAdd( aNoFields , "TGB_CODPER" )
		cQuery := " SELECT * FROM " + RetSqlName( "TGB" ) + " TGB WHERE TGB.TGB_FILIAL = " + ValToSql( xFilial( "TGB" ) )
		cQuery += " AND TGB.TGB_CODPER = " + ValToSql( M->TG1_CODPER ) + " AND TGB.D_E_L_E_T_ <> '*' "
		FillGetDados( 4 , "TGB" , 1 , xFilial( "TGB" ) + M->TG1_CODPER , { | | "TGB->TGB_FILIAL + TGB->TGB_CODPER" } , { | | .T. } , aNoFields , , , cQuery )

		cTitulo := "Requisitos do Perigo"

		aTrocaF3 := {}
		AAdd( aTrocaF3 , { "TGB_CODLEG" , "" } )

	Else

		If Empty( M->TG6_CODDAN )
		   Return .t.
		EndIf

		aAdd( aNoFields , "TGA_CODDAN" )
		cQuery := " SELECT * FROM " + RetSqlName( "TGA" ) + " TGA WHERE TGA.TGA_FILIAL = " + ValToSql( xFilial( "TGA" ) )
		cQuery += " AND TGA.TGA_CODDAN = " + ValToSql( M->TG6_CODDAN ) + " AND TGA.D_E_L_E_T_ <> '*' "
		FillGetDados( 4 , "TGA" , 1 , xFilial( "TGA" ) + M->TG6_CODDAN , { | | "TGA->TGA_FILIAL + TGA->TGA_CODDAN" } , { | | .T. } , aNoFields , , , cQuery )

		cTitulo := STR0028 //"Requisitos do Dano"

		aTrocaF3 := {}
		AAdd( aTrocaF3 , { "TGA_CODLEG" , "" } )

	EndIf

	fEmenta()

	Define MsDialog oDlgDem Title cTitulo From 9 , 0 To 29 , 80 Of oMainWnd

		If Empty( aCols )
		   aCols := BlankGetd( aHeader )
		Endif

		n   := Len( aCols )
		oGet:= MsGetDados():New( 30 , 0 , 125 , 315 , 2 , "AllwaysTrue" , "AllwaysTrue" , , .F. , , 1 , , , , , , , oDlgDem )
		oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oGet:oBrowse:Default()
		oGet:oBrowse:Refresh()

	Activate Dialog oDlgDem On Init ( EnchoiceBar( oDlgDem , { | | lOk := .T. , oDlgDem:End() } , { | | nOk:= 0 , oDlgDem:End() } ) ) Centered

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fDocumento
Monta a EnchoiceBar especifica

@return

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Static Function fEnchBar( oDlg , bOk , bCancel , bCria , nOpca , nOpcx )
	Local aButtons := { { "PEDIDO" , bCria , STR0056 } } //"Observações"

	If M->TG6_SITUAC == "1" .and. !IsInCallStack( "MDT855CPY" )//Verifica se está pendente e não é cópia
		aAdd( aButtons , { "PMSSETABOT" , { | | nOpca := 1 , If( fSitAval( nOpcx ) , oDlg:End() , ( lOk := .F. , nOpca := 0 ) ) } , STR0057 } ) //"Aprovar"

	EndIf
	If M->TG6_SITUAC <> "1"
		aAdd( aButtons , { "NCO" , { | | MDT855TRM() } , STR0058 } )	 //"Treinamento"
	EndIf

	If nOpcx == 5 .or. nOpcx == 2
		aButtons := {}
	Endif
Return ( EnchoiceBar( oDlg , bOk , bCancel , , aButtons ) )
//---------------------------------------------------------------------
/*/{Protheus.doc} fMemo
Mostra um memo para digitacao das observacoes referentes a Avaliacao

@return

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Static Function fMemo( lEdita , nOpcx )
	Local oDlgMem
	Local oFontMet   	:= TFont():New( "Courier New" , 6 , 0 )
	Local oFontDialog	:= TFont():New( "Arial" , 6 , 15 , , .T. )
	Local oTexto
	Local cTexto		:= M->TG6_DESCRI
	Local nOpcC			:= 0
	Local cTit			:= OemtoAnsi( STR0059 ) //"OBSERVAÇÃO"
	Local cCab			:= OemtoAnsi( STR0060 )  //"Observações referente a Avaliação"
	Local cCod			:= STR0061 + ":" + cOrdTG6 + "        " + STR0062 + ":" + DtoC( dDtEmis ) //"Ordem"###"Data da Avaliação"

	If Empty( M->TG6_DESCRI )
		cTexto := TG6->TG6_DESCRI
	EndIf

	Private lEdit := If( lEdita == NIL , .T. , lEdita )

		DEFINE MSDIALOG oDlgMem FROM 62 , 100 TO 320 , 610 TITLE cCab PIXEL FONT oFontDialog

		@ 003 , 004 TO 027 , 250 LABEL cTit OF oDlgMem PIXEL
		@ 040 , 004 TO 110 , 250 OF oDlgMem PIXEL

		@ 013 , 010 MSGET cCod WHEN .F. SIZE 185 , 010 OF oDlgMem PIXEL

		If lEdit
		   @ 050 , 010 GET oTexto VAR cTexto MEMO NO VSCROLL SIZE 238 , 051 OF oDlgMem PIXEL
		Else
		   @ 050 , 010 GET oTexto VAR cTexto MEMO READONLY NO VSCROLL SIZE 238 , 051 OF oDlgMem PIXEL
		Endif

		oTexto:SetFont( oFontMet )

		DEFINE SBUTTON FROM 115 , 190 TYPE 1 ACTION ( nOpcC := 1 , oDlgMem:End() ) ENABLE OF oDlgMem
		DEFINE SBUTTON FROM 115 , 220 TYPE 2 ACTION ( nOpcC := 2 , oDlgMem:End() ) ENABLE OF oDlgMem

		ACTIVATE MSDIALOG oDlgMem CENTERED

	If nOpcC == 1
	   M->TG6_DESCRI := cTexto
	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fGravaRes
Grava os Resposaveis

@return

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Static Function fGravaRes()
	Local i
	Local lDelete	:= .F.
	Local cOr

	If lCpy .Or. lMDT855Rea
		cOr := cOrdemOld
	Else
		cOr := cOrdTG6
	Endif

	For i:= 1 To Len( aQDGDoc )
		DbSelectArea( "TGC" )
		DbSetOrder( 1 )
		If DbSeek( xFilial( "TGC" ) + cOr + aQdgDoc[ i , 5 ] )
			RecLock( "TGC" , .F. )
			lDelete := .T.
		Else
			RecLock( "TGC" , .T. )
		EndIf

		If aQdgDoc[ i , 4 ] == "S"
			TGC->TGC_FILIAL := xFilial( "TGC" )
			TGC->TGC_ORDEM  := cOr
			TGC->TGC_CODFUN := aQdgDoc[ i , 3 ]
			TGC->TGC_MAT    := aQdgDoc[ i , 5 ]
		Else
			If lDelete
				DbDelete()
			EndIf
		EndIf
		MsUnLock( "TGC" )
	Next i

Return .t.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT855HIST
Grava no Historico a Avaliacao

@return

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Function MDT855HIST( nOpcx, cOrdem2, cOrdRea )

	Local nTab
	Local Tab , ny , nx , TGE , cCodHis , i , nFor
	Local cTabGet	:= ""
	Local cTabHis	:= ""
	Local cSeek		:= ""
	Local cRet		:= "2"

	cCodCla 		:= If( Type( "cCodCla"       ) == "C" , cCodCla       , TG6->TG6_CODCLA )

	// Se deve verificar as validacoes. [Utilizado para processos automaticos]
	If ( cRet := fVerStatus( cCodCla , .T. ) ) == "0" // Verifica a classe da avaliação
		Return .F.
	Endif

	cCodHis := fCodHist()

	dbSelectArea( "TG6" )
	RegToMemory( "TG6" , .F. )

	dbSelectArea( "TGD" )
	dbSetOrder( 3 )
	If !DbSeek( xFilial( "TGD" ) + cOrdem2 )
		RecLock( "TGD" , .T. )
	Else
		RecLock( "TGD" , .F. )
	Endif

	For i:=1 To FCount()
		If "_SITUAC" $ Upper( FieldName( i ) )
			FieldPut( i , cRet )
		ElseIf "_CODHIS" $ Upper( FieldName( i ) )
			FieldPut( i , cCodHis )
		ElseIf "_DTHIST" $ Upper( FieldName( i ) )
			FieldPut( i , dDataBase )
		ElseIf "_DTFINA" $ Upper( FieldName( i ) )
			FieldPut( i , dDataBase )
		ElseIf lMDT855Rea .And. "_REAVAL" $ Upper ( FieldName( i ) )
			FieldPut( i , cOrdRea )
		Else
			nx := "TG6_" + Substr( FieldName( i ) , 5 )
			If TG6->( ColumnPos( nx ) ) > 0
				FieldPut( i , &( "M->" + nx ) )
			Endif
		Endif
	Next
	MsUnlock( "TGD" )

	dbSelectArea( "TG6" )
	RecLock( "TG6" , .F. )
	DbDelete()
	MsUnLock( "TG6" )

	//Passa a tabela TGN
	dbSelectArea( "TGN" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "TGN" ) + cOrdem2 )
	While TGN->( !Eof() ) .And. TGN->TGN_FILIAL == xFilial( "TGN" ) .And. TGN->TGN_ANALIS == cOrdem2
		dbSelectArea( "TGN" )
		RegToMemory( "TGN" , .F. )

		dbSelectArea( "TGO" )
		dbSetOrder( 1 )
		If !dbSeek( xFilial( "TGO" ) + cCodHis + cOrdem2 + TGN->TGN_CODFOR )
			RecLock( "TGO" , .T. )
		Else
		 	RecLock( "TGO" , .F. )
		EndIf
		For i := 1 To FCount()
			If "_FILIAL" $ Upper( FieldName( i ) )
				FieldPut( i , xFilial( "TGO" ) )
			ElseIf "_CODHIS" $ Upper( FieldName( i ) )
				FieldPut( i , cCodHis )
			Else
				nx := "TGN_" + Substr( FieldName( i ) , 5 )
				If  TGN->( ColumnPos( nx ) ) > 0
					FieldPut( i , &( 'M->' + nx ) )
				Endif
			Endif
		Next i
		nFor++
		TGO->( MsUnlock() )

		dbSelectArea( "TGN" )
		TGN->( dbSkip() )
	End

	//Passa a tabela TG7
	dbSelectArea( "TG7" )
	dbSetOrder( 1 )//TG7_FILIAL+TG7_ORDEM+TG7_CODAVA+TG7_CODOPC
	dbSeek( xFilial( "TG7" ) + cOrdem2 )
	While !Eof() .and. TG7->TG7_FILIAL == xFilial( "TG7" ) .and. TG7->TG7_ORDEM == cOrdem2
		dbSelectArea( "TG7" )
		RegToMemory( "TG7" , .F. )

		dbSelectArea( "TGE" )
		dbSetOrder( 1 ) //TGE_FILIAL+TGE_CODHIS+TGE_CODAVA+TGE_CODOPC
		If !dbSeek( xFilial( "TGE" ) + TGD->TGD_CODHIS + TG7->TG7_ORDEM + TG7->TG7_CODAVA + TG7->TG7_CODOPC )
			RecLock( "TGE" , .T. )
			For i := 1 To FCount()
				If "_CODHIS" $ Upper( FieldName( i ) )
					FieldPut( i , TGD->TGD_CODHIS )
				Else
					nX := "TG7_" + Substr( FieldName( i ) , 5 )
					If TG7->( ColumnPos( nx ) ) > 0 //&nX != Nil
						FieldPut( i , &( 'M->' + nx ) )
					EndIf
				EndIf
			Next
			MsUnlock( "TGE" )

			DbSelectArea( "TG7" )
			RecLock( "TG7" , .F. )
			DbDelete()
			MsUnLock( "TG7" )

		EndIf

		dbSelectArea( "TG7" )
		dbSkip()
	End

	For nTab := 1 To Len( aTabGet )

		cTabGet	:= aTabGet[ nTab , 1 ]
		cTabHis	:= aTabGet[ nTab , 2 ]
		cSeek		:= aTabGet[ nTab , 3 ]

		dbSelectArea( cTabGet )
		dbSetOrder( 1 )
		dbSeek( xFilial( cTabGet ) + cOrdem2 )
		While !Eof() .and. &( PrefixoCPO( cTabGet ) + "->" + cTabGet + "_FILIAL" ) == xFilial( cTabGet ) .And. ;
							&( PrefixoCPO( cTabGet ) + "->" + cTabGet + "_ANALIS" ) == cOrdem2
			dbSelectArea( cTabGet )
			RegToMemory( cTabGet , .F. )

			dbSelectArea( cTabHis )
			dbSetOrder( 1 )
			If !dbSeek( xFilial( cTabHis ) + TGD->TGD_CODHIS + &( PrefixoCPO( cTabGet ) + "->" + cTabGet + "_ANALIS" ) + &( PrefixoCPO( cTabGet ) + "->" + cSeek ) )
				RecLock( cTabHis , .T. )
				For i := 1 To FCount()
					If "_CODHIS" $ Upper( FieldName( i ) )
						FieldPut( i , TGD->TGD_CODHIS )
					Else
						nX :=  cTabGet + "_" + Substr( FieldName( i ) , 5 )
						If cTabGet->( ColumnPos( nx ) ) > 0 //&nX != Nil
							FieldPut( i , &("M->" +nx) )
						EndIf
					EndIf
				Next
				MsUnlock( cTabHis )

				DbSelectArea( cTabGet )
				RecLock( cTabGet , .F. )
				( cTabGet )->( DbDelete() )
				MsUnLock( cTabGet )
			EndIf
			( cTabGet )->( dbSkip() )
		End

	Next nTab

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fCodHist
Retorna codigo do historico

@return

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Static Function fCodHist()

	Local cCodHis := "000000"
	dbSelectArea( "TGD" )
	dbSetOrder( 1 )
	dbGoTop()
	While TGD->( !Eof() ) .and. xFilial( "TGD" ) == TGD->TGD_FILIAL
		cCodHis := TGD->TGD_CODHIS
		TGD->( DbSkip() )
	End

	If Empty( cCodHis )
		cCodHis := "000000"
	EndIf

Return StrZero( Val( cCodHis ) + 1 , 6 )
//---------------------------------------------------------------------
/*/{Protheus.doc} fEmenta
Retorna a Ementa

@return

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Function fEmenta()
	Local i

	For i := 1 To Len( aCols )
		If TA0->( dbSeek( xFilial( "TA0" ) + aCols[ i , 1 ] ) )
			aCols[ i , 2 ] := TA0->TA0_EMENTA
		EndIf
	Next i

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
@since 22/03/2013
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {	{ STR0063 , "AxPesqui"  , 0 , 1 } , ; //"Pesquisar"
	                    { STR0064 , "MDT855PRO" , 0 , 2 } , ; //"Visualizar"
	                    { STR0065 , "MDT855PRO" , 0 , 3 } , ; //"Incluir"
	                    { STR0066 , "MDT855PRO" , 0 , 4 } , ; //"Alterar"
	                    { STR0067 , "MDT855PRO" , 0 , 5 , 3 } , ; //"Excluir"
	                    { STR0068 , "MDT855CPY" , 0 , 4 } , ; //"Copiar"
	                    { STR0069 , "MDT855LGN" , 0 , 3 } }  //"Legenda"

Return aRotina
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT855CPY
Funcao para copiar nova avaliacao de uma ja existente

@return

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Function MDT855CPY()

	Local aOldOpc := { { STR0070 , Inclui }, { STR0071 , Altera } } //"Inclui"###"Altera"
	Local nInd

	If !MsgYesNo( STR0072 + ": " + TG6->TG6_ORDEM + " ?" , STR0035 ) //"Deseja realizar uma cópia do desempenho"###"ATENÇÃO"
		Return .F.
	EndIf

	SetInclui() // Define operacao como inclusao [Incluir := .T.]

	dbSelectArea( "TG6" )
	dbSetOrder( 1 )
	MDT855Pro( "TG6" , Recno() , 3 )

	For nInd := 1 To Len( aOldOpc )
		&( aOldOpc[ nInd , 1 ] ) := aOldOpc[ nInd , 2 ]
	Next nInd


Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fSitAval
Muda a situacao do desempenho

@return

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Static Function fSitAval( nOpcao )
	Local cRet    := M->TG6_SITUAC
	Local nTotRet := 0
	//Verifica se é inclusão ou alteração
	If nOpcao == 4 .OR. nOpcao == 3
		M->TG6_SITUAC := "1"
		//Verifica os campos obrigatórios
		If !fObrigatorio( nOpcao , .T. )
			Return .F.
		Endif

		//Verifica se as avaliações foram respondidas
		If !MDT855VIMR()
			Return .F.
		Endif

		//Calcula os totais
		If !fCalcular( @nTotRet )
			Return .F.
		Endif

		//Procura Classe do Desempenho
		If ( cRet := fVerStatus( cCodCla ) ) <> "0"
			M->TG6_SITUAC := cRet
		Else
			Return .F.
		Endif

		//Grava os dados Finalizando o Plano
		If !fGravaAva( nOpcao )
			Return .F.
		Endif

		If NGSEEK( "TG4" , cCodCla , 1 , "TG4_RISCO" ) == "1" .And. Empty( TG6->TG6_NUMRIS ) .And. ;
					MsgYesNo( STR0120 , STR0035 ) //"O Agente de Risco é referente à NR 9?"###"ATENÇÃO"
			If MsgYesNo( STR0121 , STR0035 )//"Será necessário o quantitativo (medição) do Risco. Tem certeza que deseja continuar?"###"ATENÇÃO"
				fGeraRisco( nTotRet )
			EndIf
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT855LGN
Cria uma janela contendo a legenda da mBrowse

@return

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Function MDT855LGN()

	Local aLegenda := {}

	aAdd( aLegenda , { "BR_AMARELO"  , STR0074 } ) //"Parcialmente Respondido"
	aAdd( aLegenda , { "BR_VERDE"    , STR0075 } )  //"Aprovado"
	//aAdd( aLegenda , { "BR_BRANCO"   , STR0076 } ) //"Aprovado Sem Objetivo"
	//aAdd( aLegenda , { "BR_AZUL"     , STR0077 } )   //"Aprovado Sem Monitoramento"
	//aAdd( aLegenda , { "BR_LARANJA"  , STR0078 } )  //"Aprovado Sem Plano de Ação"
	//aAdd( aLegenda , { "BR_MARROM"   , STR0079 } )  //"Aprovado Sem Plano Emergencial"
	//aAdd( aLegenda , { "BR_VERMELHO" , STR0080 } )  //"Aprovado com duas ou mais pendências"

	BrwLegenda( cCadastro , STR0069 , aLegenda ) //"Legenda"

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fVerStatus
Verifica se a avaliação tem os planos de ação e emergencial preenchidos de acordo com a sua classe

@return

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Static Function fVerStatus( cCodClasse , lHist )

	Local nAlias	:= 0
	Local cRet		:= "2"//Retorno como Aprovado
	Local cMsg		:= ""
	Local cAlias	:= ""
	Local aArea		:= GetArea()//Guarda tabelas e indices
	Local aAlias	:= { cTRBA , cTRBB , cTRBC }
	Local lSemPlaAc	:= .F.
	Local lSemPlaEm := .F.
	Local lSemObj	:= .F.
	Local lSemMon	:= .F.

	Default lHist	:= .F.

    If IsInCallStack( "fRemPer" )
    	aColsPA := aColsPla
		aCOlsPE := aColsEme
		aColsOB := aColsObj
		aColsMO := aColsMon
    Else
		aColsPA := aClone( oGetPA:aCols )
		aCOlsPE := aClone( oGetPE:aCols )
		aColsOB := aClone( oGetOB:aCols )
		aColsMO := aClone( oGetMO:aCols )
	EndIf

	dbSelectArea( "TG4" )
	dbSetOrder( 1 )
	If dbSeek( xFilial( "TG4" ) + cCodClasse )
		//Verifica se deveria ter plano de ação, emergencial, objetivo ou monitoramento
		If TG4->TG4_PLANAC == "1" .AND. Len( aColsPA ) == 1 .And. ( Empty( aColsPA[ 1 , 1 ] ) .Or. aColsPA[ 1 , Len( aColsPA[ 1 ] ) ] )//Verifica se deveria ter plano de ação
			lSemPlaAc := .T.
		EndIf
		If TG4->TG4_PLANEM == "1" .AND. Len( aColsPE ) == 1 .And. ( Empty( aColsPE[ 1 , 1 ] ) .Or. aColsPE[ 1 , Len( aColsPE[ 1 ] ) ] )//Verifica se deveria ter plano emergencial
			lSemPlaEm := .T.
		Endif
		If TG4->TG4_OBJETI == "1" .AND. Len( aColsOB ) == 1 .AND. ( Empty( aColsOB[ 1 , 1 ] ) .Or. aColsOB[ 1 , Len( aColsOB[ 1 ] ) ] )//Verifica se deveria ter objetivo
			lSemObj := .T.
		Endif
		If TG4->TG4_MONITO == "1" .AND. Len( aColsMO ) == 1 .And. ( Empty( aColsMO[ 1 , 1 ] ) .Or. aColsMO[ 1 , Len( aColsMO[ 1 ] ) ] )//Verifica se deveria ter monitoramento
			lSemMon := .T.
		Endif
	Endif

	//Verifica se os criterios necessitam de relacionamento
	For nAlias := 1 To Len( aAlias )
		cAlias := aAlias[ nAlias ]
		dbSelectArea( cAlias )
		dbGoTop()
		While !Eof()
			dbSelectArea( "TG3" )
			dbSetOrder( 1 )
			If dbSeek( xFilial( "TG3" ) + ( cAlias )->TRB_CODAVA + ( cAlias )->TRB_CODIGO )
				//Verifica se deveria ter plano de ação, emergencial, objetivo ou monitoramento
				If TG3->TG3_PLANAC == "1" .AND. Len( aColsPA ) == 1 .And. ( Empty( aColsPA[ 1 , 1 ] ) .Or. aColsPA[ 1 , Len( aColsPA[ 1 ] ) ] )//Verifica se deveria ter plano de ação
					lSemPlaAc := .T.
				EndIf
				If TG3->TG3_PLANEM == "1" .AND. Len( aColsPE ) == 1 .And. ( Empty( aColsPE[ 1 , 1 ] ) .Or. aColsPE[ 1 , Len( aColsPE[ 1 ] ) ] )//Verifica se deveria ter plano emergencial
					lSemPlaEm := .T.
				Endif
				If TG3->TG3_OBJETI == "1" .AND. Len( aColsOB ) == 1 .AND. ( Empty( aColsOB[ 1 , 1 ] ) .Or. aColsOB[ 1 , Len( aColsOB[ 1 ] ) ] )//Verifica se deveria ter objetivo
					lSemObj := .T.
				Endif
				If TG3->TG3_MONITO == "1" .AND. Len( aColsMO ) == 1 .And. ( Empty( aColsMO[ 1 , 1 ] ) .Or. aColsMO[ 1 , Len( aColsMO[ 1 ] ) ] )//Verifica se deveria ter monitoramento
					lSemMon := .T.
				Endif
			EndIf
			dbSelectArea(cAlias)
			dbSkip()
		EndDo
	Next nAlias

	If lSemPlaAc
		cRet := "3"//Aprovado sem plano de acao
		cMsg += STR0081 //"um Plano de Ação"
		If lSemPlaEm .Or. lSemObj .Or. lSemMon
			cRet := "5"//Aprovado com duas ou mais pendências
		EndIf
	Endif
	If lSemPlaEm
		If !Empty( cMsg )
			cMsg += ", "
		EndIf
		cMsg += STR0082 //"um Plano Emergencial"
		If cRet == "2"
			cRet := "4"//Aprovado sem Plano Emergencial

			If lSemPlaAc .Or. lSemObj .Or. lSemMon
				cRet := "5"//Aprovado com duas ou mais pendências
			EndIf
		EndIf
	EndIf
	If lSemObj
		If !Empty( cMsg )
			cMsg += ", "
		EndIf
		cMsg += STR0083 //"um Objetivo"
		If cRet == "2"
			cRet := "6"//Aprovado sem Objetivo
			If lSemPlaAc .Or. lSemPlaEm .Or. lSemMon
				cRet := "5"//Aprovado com duas ou mais pendências
			EndIf
		EndIf
	EndIf
	If lSemMon
		If !Empty( cMsg )
			cMsg += ", "
		EndIf
		cMsg += STR0084 //"um Monitoramento"
		If cRet == "2"
			cRet := "7"//Aprovado sem Plano Emergencial
			If lSemPlaAc .Or. lSemPlaEm .Or. lSemObj
				cRet := "5"//Aprovado com duas ou mais pendências
			EndIf
		EndIf
	EndIf

	If Rat( "," , cMsg ) > 0
		cMsg := Stuff( cMsg , Rat( "," , cMsg ) , 1 , STR0085  ) //" e"
	EndIf

	If cRet <> "2" .And. !IsInCallStack( "MNTA902" )
		/*If !MsgYesNo( STR0086 + cMsg + STR0087 + If( lHist , STR0088 , STR0057 ) + STR0089 , STR0035 ) //"A Significância pede que seja relacionado "###". Deseja "###"Finalizar"###"Aprovar"###" a Avaliação mesmo assim?"###"ATENÇÃO"
			cRet := "0"
		EndIf*/
		MsgStop( STR0086 + cMsg + "."/*STR0087 + If( lHist , STR0088 , STR0057 ) + STR0089*/ , STR0035 ) //"A Significância pede que seja relacionado "###". Deseja "###"Finalizar"###"Aprovar"###" a Avaliação mesmo assim?"###"ATENÇÃO"
		cRet := "0"
	EndIf

	RestArea(aArea)//Retorna tabelas e indices
Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT855CSAV
Efetua alteracao do item da tree para estado 'Sendo Avaliado'.

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Function MDT855CSAV()

	Local nInd

	For nInd := 1 To Len( aLocal2 )
		If !Empty( aLocal2[ nInd , 1 ] )
			dbSelectArea( oTree:cArqTree )
			dbSetOrder( 4 )
			If dbSeek( aLocal2[nInd][1] )
				If SubStr( ( oTree:cArqTree )->T_CARGO , 1 , 3 ) == aLocal2[ nInd , 1 ] .and. SubStr( ( oTree:cArqTree )->T_CARGO , 7 , 1 ) != "3"

					// Altera referencia do item da tree para 'Sendo Avaliado' [ Folder Amarelo ]
					oTree:TreeSeek( aLocal2[ nInd , 1 ] )
					oTree:ChangeBmp( "Folder5" , "Folder6" )

					(oTree:cArqTree)->T_CARGO := SubStr( oTree:GetCargo() , 1 , 6 ) + "3"
					oTree:TreeSeek( aLocal2[ nInd , 1 ] )

				EndIf
			Endif
		Endif
	Next nInd

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SetNivMrk
Define niveis de 'Presenca de Perigo', conforme Perigo informado.

@param cCodPer Codigo do Perigo a ser considerado para analise.
@param cOrdem Numero da ordem a ser verificada.

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Static Function SetNivMrk( cCodPer , cOrdem )

	Local aArea    := GetArea()
	Local aAreaTG9 := TG9->( GetArea() )

	Default cOrdem := ""

	// Verifica niveis com 'Presenca de Perigo'
	dbSelectArea( "TG9" )
	dbSetOrder( 1 )
	If dbSeek( xFilial( "TG9" ) + cCodPer + "001" )
		While !Eof() .And. xFilial( "TG9" ) + cCodPer == TG9->TG9_FILIAl + TG9->TG9_CODPER
			If aScan( aLocal , { | x | Trim( Upper( x[ 1 ] ) ) == TG9->TG9_CODNIV } ) == 0
				aAdd( aLocal , { TG9->TG9_CODNIV , .T. } )
			Endif
			dbSelectArea( "TG9" )
			dbSkip()
		End
	Endif

	// Realiza copia de itens marcados [Necessario devido a atual situacao do fonte | Verificar possibilidade de correcao]
	aMarcado := aClone( aLocal )

	// Caso a ordem seja informada, define nivel com estado 'Sendo Avaliado'
	If !Empty( cOrdem )
		GetAvalNiv( cOrdem )
	Endif

	// Restaura areas
	RestArea( aArea )
	RestArea( aAreaTG9 )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} GetAvalNiv
Define nivel referente a avaliacao atual, conforme ordem informada.

@param cOrdem Numero da ordem a ser verificada.

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Static Function GetAvalNiv( cOrdem )

	Local aArea    := GetArea()
	Local aAreaTG6 := TG6->( GetArea() )

	dbSelectArea( "TG6" )
	dbSetOrder( 1 )
	If DbSeek( xFilial( "TG6" ) + cOrdem )
		cFolderA := "Folder5"
		cFolderB := "Folder6"
		aAdd( aLocal2 , { TG6->TG6_CODNIV , .T. } ) // Adiciona item em array de controle de itens marcados como 'Sendo Avaliado'
	Endif

	RestArea( aArea )
	RestArea( aAreaTG6 )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT855VIMR
Verifica se as avaliações foram respondidas. Criterios de Avaliacao de Dano

@param lVrfBase Define se deve verificar a base de dados, ou o processo atual.
@param cOrdem   Define numero da ordem a ser verificada.
@param lShowMsg Define se deve apresentar a mensagem de inconsistencia.

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Function MDT855VIMR( lVrfBase , cOrdem , lShowMsg )

	Local nLine, nArea
	Local lReturn 		:= .T.
	Local aAreas		:= {}

	Default lVrfBase	:= .F.
	Default lShowMsg	:= .T.
	Default cOrdem		:= Space( TAMSX3( "TG6_ORDEM" )[ 1 ] )

	If !lVrfBase // Se nao deve realizar a verificacao a partir da base de dados

		For nLine := 1 To Len( aColsDan )
			dbSelectArea( cTRBB )
			dbSetOrder( 1 )
			If !dbSeek( aColsDan[ nLine , 1 ] )
				lReturn := .F.
				Exit
			EndIf
		Next nLine

		If lReturn
			For nLine := 1 To Len( aCols1 )
				dbSelectArea( cTRBA )
				dbSetOrder( 1 )
				If !dbSeek( aCols1[ nLine , 1 ] ) .And. "Avalia" $ aCols1[ nLine , 2 ]
					lReturn := .F.
					Exit
				EndIf
			Next nLine
		EndIf

		If lReturn
			For nLine := 1 To Len( aColsLoc )
				dbSelectArea( cTRBC )
				dbSetOrder( 1 )
				If !dbSeek( aColsLoc[ nLine , 1 ] ) .And. "Avalia" $ aColsLoc[ nLine , 2 ]
					lReturn := .F.
					Exit
				EndIf
			Next nLine
		EndIf
	Else // Se realiza a analise na base de dados

		// Define areas de trabalho atuais
		aAdd( aAreas , GetArea() )
		aAdd( aAreas , TG2->( GetArea() ) )
		aAdd( aAreas , TG7->( GetArea() ) )

		// Verifica todos os criterios de avaliacao do tipo 'Dano'
		dbSelectArea( "TG2" )
		dbSetOrder( 1 )
		dbSeek( xFilial( "TG2" ) )
		While TG2->( !Eof() ) .And. xFilial( "TG2" ) == TG2->TG2_FILIAL

			// Se o tipo for diferente de 'Caracterização'
			If TG2->TG2_TITULO <> "1"
				dbskip()
				Loop
			EndIf

			// Verifica se ha algum criterio de avaliacao nao respondido
		   dbSelectArea( "TG7" )
		   dbSetOrder( 1 )//TG7_FILIAL+TG7_ORDEM+TG7_CODAVA+TG7_CODOPC
		   If !dbSeek( xFilial( "TG7" ) + cOrdem + TG2->TG2_CODAVA )
		      lReturn := .F.
		      Exit
		   EndIf

			dbSelectArea( "TG2" )
			dbSkip()
		End

	Endif

	// Caso seja requisitada a apresentacao de mensagem de erro
	If lShowMsg .And. !lReturn
		MsgStop( STR0090 , STR0035 ) //"Responda todas as avaliações do Dano antes de aprovar a Análise."###"ATENÇÃO"
	Endif

	// Retorna areas de trabalho
	If Len( aAreas ) > 0
		For nArea := Len( aAreas ) To 1 Step -1
			RestArea( aAreas[ nArea ] )
		Next nArea
	Endif

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT855VLRE
Valida os campos codigos das GetDados

@param cAlias - Alias a ser validado

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Function MDT855VLRE( cAlias )

	Local lRet := .T.

	If cAlias == "TGF"
		dbSelectArea( "TAA" )
		TAA->( dbSetOrder( 1 ) )
		If TAA->( dbseek( xFilial( "TAA" ) + M->TGF_CODPLA ) ) .And. !Empty( TAA->TAA_STATUS ) .And. TAA->TAA_STATUS <> "1"
			If !MsgYesNo( STR0091 + M->TGF_CODPLA + STR0092 + If( TAA->TAA_STATUS == "2" , STR0093 , STR0094 ) + ; //"O Plano de Ação: "###" se encontra "###"Finalizado."###"Cancelado."
				Chr( 13 ) + Chr( 10 ) + STR0095 , STR0035 ) //"Deseja selecioná-lo assim mesmo?"###"Atenção"
				lRet := .F.
			EndIf
		EndIf
	ElseIf cAlias == "TGG"
		lRet := .T.
	ElseIf cAlias == "TGH"
		dbSelectArea( "TBH" )
		TBH->( DbSetOrder( 1 ) )
		If TBH->( Dbseek( xFilial( "TBH" ) + M->TGH_CODOBJ ) ) .And. !TBH->TBH_SITUAC $ "2;3"
			lRet := .F.
	   		ShowHelpDlg( STR0035 , { STR0096 } , 2 , { STR0097 } , 2 ) //"ATENÇÃO"###"Objetivo Inválido"###"O objetivo deve existir e possuir situação aberto ou fechado."
		EndIf
	ElseIf cAlias == "TGI"
		dbSelectArea( "TCD" )
		TCD->( dbSetOrder( 1 ) )
		If TCD->( dbseek( xFilial( "TCD" ) + M->TGI_CODMON ) )
			If !Empty( TCD->TCD_STATUS ) .And. !( TCD->TCD_STATUS $ "1;2" )
				If !MsgYesNo( STR0098 + M->TGI_CODMON + STR0092 + If( TCD->TCD_STATUS == "3" , STR0093 , STR0094 ) + ; //"O Monitoramento: "###" se encontra "###"Finalizado."###"Cancelado."
					Chr( 13 ) + Chr( 10 ) + STR0095 , STR0035 ) //"Deseja selecioná-lo assim mesmo?"###"Atenção"
					lRet := .F.
				EndIf
			ElseIf TCD->TCD_CODDAN <> M->TG6_CODDAN
				If !MsgYesNo( STR0098 + M->TGI_CODMON + STR0099 + ; //"O Monitoramento: "###" possui um dano diferente do selecionado."
					Chr( 13 ) + Chr( 10 ) + STR0095 , STR0035 ) //"Deseja selecioná-lo assim mesmo?"###"Atenção"
					lRet := .F.
				EndIf
			ElseIf TCD->TCD_CODPER <> M->TG1_CODPER
			 	If !MsgYesNo( STR0098 + M->TGI_CODMON + STR0100 + ; //"O Monitoramento: "###" possui um perigo diferente do selecionado."
					Chr( 13 ) + Chr( 10 ) + STR0095 , STR0035 ) //"Deseja selecioná-lo assim mesmo?"###"Atenção"
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fGeraRisco
Gera o risco com as configurações pre-estabelecidas

@param  nQtd - Quantidade do Risco

@author Jackson Machado
@since 16/01/2013
/*/
//---------------------------------------------------------------------
Static Function fGeraRisco( nQtd )
    Local i
    Local cUni		:= ""
    Local cAgente 	:= ""
    Local cCusto  	:= ""
    Local cFonte  	:= ""
    Local cFuncao 	:= ""
    Local cTarefa 	:= ""
    Local cDepto	:= ""

    dbSelectArea( "TG1" )
    dbSetOrder( 1 )
    dbSeek( xFilial( "TG1" ) + M->TG1_CODPER )

	fVerLocRis( @cCusto , @cFuncao , @cTarefa , @cDepto )

	fSolQtd( @nQtd , @cUni )

	aRotSetOpc( "TN0" , 0 , 3 )

	RegToMemory( "TN0" , .T. )

	dbSelectArea( "TN0" )
	RecLock( "TN0" , .T. )
	TN0_FILIAL := xFilial( "TN0" )
	TN0_DTRECO := dDtEmis
	TN0_AGENTE := TG1->TG1_AGENTE
	TN0_FONTE  := TG1->TG1_FONTE
//	TN0_DTAVAL := dDtEmis
	TN0_UNIMED := cUni
	TN0_CC     := cCusto
	TN0_CODFUN := cFuncao
	TN0_CODTAR := cTarefa
	If NGCADICBASE( "TN0_DEPTO" , "A" , "TN0" , .F. )
		TN0_DEPTO  := cDepto
	EndIf
	TN0_QTAGEN := nQtd
	//TN0_UNIMED := TG1->TG1_UNIMED
	For i := 1 To FCount()
		If "_FILIAL" $ Alltrim( FieldName( i ) )
			Loop
		ElseIf "_DTRECO" $ Alltrim( FieldName( i ) )
			Loop
		ElseIf "_AGENTE" $ Alltrim( FieldName( i ) )
			Loop
		ElseIf "_FONTE" $ Alltrim( FieldName( i ) )
			Loop
		ElseIf "_DTAVAL" $ Alltrim( FieldName( i ) )
			Loop
		ElseIf "_CC" $ Alltrim( FieldName( i ) )
			Loop
		ElseIf "_CODFUN" $ Alltrim( FieldName( i ) )
			Loop
		ElseIf "_CODTAR" $ Alltrim( FieldName( i ) )
			Loop
		ElseIf "_QTAGEN" $ Alltrim( FieldName( i ) )
			Loop
		ElseIf "_UNIMED" $ Alltrim( FieldName( i ) )
			Loop
		ElseIf "_DEPTO" $ Alltrim( FieldName( i ) )
			Loop
		EndIf
		x  := "M->" + FieldName( i )
		y  := "TN0->" + FieldName( i )
		&y := &x
	Next i
	TN0->( MsUnLock() )

	RecLock( "TG6" , .F. )
	TG6->TG6_NUMRIS := TN0->TN0_NUMRIS
	TG6->( MsUnLock() )

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fVerLocRis
Retorna as definicoes de locais do risco

@param cCusto  - Codigo do Centro de Custo
@param cFuncao - Codigo da Funcao
@param cTarefa - Codigo da Tarefa

@author Jackson Machado
@since 16/01/2013
/*/
//---------------------------------------------------------------------
Static Function fVerLocRis( cCusto , cFuncao , cTarefa , cDepto )

	Local cNivSup	:= ""
	Local cCarOld	:= SubStr( oTree:GetCargo() , 1 , 3 )
	Local cCargo	:= ""
	Local lTN0Depto := NGCADICBASE( "TN0_DEPTO" , "A" , "TN0" , .F. )
	Local aArea		:= GetArea()

	nPos := aScan( aLocal2 , { | x | x[ 2 ] == .T. } )

	cCargo := aLocal2[ nPos , 1 ]

	dbSelectArea( cTRBSGA )
	dbSetOrder( 2 )
	dbSeek( "001" + cCargo )

	oTree:TreeSeek( cCargo )

	If SubStr( oTree:GetCargo() , 4 , 3 ) == "LOC"
		If SubStr( oTree:GetCargo() , 1 , 3 ) <> "001"
			While Empty( cCusto )
			    If ( cTRBSGA )->CODPRO <> "001"
				    If !Empty( ( cTRBSGA )->CC )
				    	cCusto := ( cTRBSGA )->CC
						If lTN0Depto
							If !Empty( ( cTRBSGA )->DEPTO )
								cDepto := ( cTRBSGA )->DEPTO
				    Else
								cDepto := "*"
							EndIf
						EndIf
				    Else
				    	If lTN0Depto .And. Empty( cDepto ) .And. !Empty( ( cTRBSGA )->DEPTO )
				    		cDepto := ( cTRBSGA )->DEPTO
				    	EndIf
				    	cNivSup := ( cTRBSGA )->NIVSUP
				    	dbSelectArea( cTRBSGA )
				    	dbSetOrder( 2 )
				    	dbSeek( "001" + cNivSup )
				    	Loop
				    EndIf
				Else
					cCusto := "*"
					cDepto := "*"
				EndIf
			End
		Else
			cCusto := "*"
			cDepto := "*"
		EndIf
		cFuncao := "*"
		cTarefa := "*"
	ElseIf SubStr( oTree:GetCargo() , 4 , 3 ) == "FUN"
		cFuncao := SubStr( ( cTRBSGA )->CODTIPO , 1 , Len( SRJ->RJ_FUNCAO ) )
		cTarefa := "*"
		cNivSup := ( cTRBSGA )->NIVSUP
		dbSelectArea( cTRBSGA )
    	dbSetOrder( 2 )
    	dbSeek( "001" + cNivSup )
		While Empty( cCusto )
		    If ( cTRBSGA )->CODPRO <> "001"
			    If !Empty( ( cTRBSGA )->CC )
			    	cCusto := ( cTRBSGA )->CC
					If lTN0Depto
						If !Empty( ( cTRBSGA )->DEPTO )
							cDepto := ( cTRBSGA )->DEPTO
			    Else
							cDepto := "*"
						EndIf
					EndIf
			    Else
			    	If lTN0Depto .And. Empty( cDepto ) .And. !Empty( ( cTRBSGA )->DEPTO )
			    		cDepto := ( cTRBSGA )->DEPTO
			    	EndIf
			    	cNivSup := ( cTRBSGA )->NIVSUP
			    	dbSelectArea( cTRBSGA )
			    	dbSetOrder( 2 )
			    	dbSeek( "001" + cNivSup )
			    	Loop
			    EndIf
			Else
				cCusto := "*"
				cDepto := "*"
			EndIf
		End
	ElseIf SubStr( oTree:GetCargo() , 4 , 3 ) == "TAR"
		cTarefa := SubStr( ( cTRBSGA )->CODTIPO , 1 , Len( TN6->TN6_CODTAR ) )
		cNivSup := ( cTRBSGA )->NIVSUP

		dbSelectArea( cTRBSGA )
    	dbSetOrder( 2 )
    	dbSeek( "001" + cNivSup )

    	oTree:TreeSeek( cNivSup )

    	If SubStr( oTree:GetCargo() , 4 , 3 ) == "FUN"
    		cFuncao := SubStr( ( cTRBSGA )->CODTIPO , 1 , Len( SRJ->RJ_FUNCAO ) )
    	Else
    		cFuncao := "*"
    	EndIf
    	cNivSup := ( cTRBSGA )->NIVSUP

		dbSelectArea( cTRBSGA )
    	dbSetOrder( 2 )
    	dbSeek( "001" + cNivSup )

		While Empty( cCusto )
		    If ( cTRBSGA )->CODPRO <> "001"
			    If !Empty( ( cTRBSGA )->CC )
			    	cCusto := ( cTRBSGA )->CC
					If lTN0Depto
						If !Empty( ( cTRBSGA )->DEPTO )
							cDepto := ( cTRBSGA )->DEPTO
			    Else
							cDepto := "*"
						EndIf
					EndIf
			    Else
			    	If lTN0Depto .And. Empty( cDepto ) .And. !Empty( ( cTRBSGA )->DEPTO )
			    		cDepto := ( cTRBSGA )->DEPTO
			    	EndIf
			    	cNivSup := ( cTRBSGA )->NIVSUP
			    	dbSelectArea( cTRBSGA )
			    	dbSetOrder( 2 )
			    	dbSeek( "001" + cNivSup )
			    	Loop
			    EndIf
			Else
				cCusto := "*"
				cDepto := "*"
			EndIf
		End
	EndIf

	cCargo := cCarOld

	dbSelectArea( cTRBSGA )
	dbSetOrder( 2 )
	dbSeek( "001" + cCargo )

	oTree:TreeSeek( cCargo )

	RestArea( aArea )
Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fSolQtd
Solicita quantidade do risco

@param nQtd  - Quantidade preestabelecida

@author Jackson Machado
@since 16/01/2013
/*/
//---------------------------------------------------------------------
Static Function fSolQtd( nQtd , cUni )

	Local nQuant := 0
	Local nOpcao := 0
	Local cUnida := Space( Len( TN0->TN0_UNIMED ) )
	Local oDialog, oPnlPai

	Default nQtd := 0
	Default cUni := ""
	//nQuant := nQtd

	Define MsDialog oDialog From 03.5,6 To 150,500 Title STR0101 Pixel //"Tarefa" //"Informação da Quantidade"

        oPnlPai := TPanel():New( 00 , 00 , , oDialog , , , , , , 00 , 00 , .F. , .F. )
			oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

		@ 07,008 Say OemToAnsi( STR0102 ) Size 300,10 Of oPnlPai Pixel //"Informe a quantidade para geração do risco:"

		@ 20,008 Say OemToAnsi( STR0103 ) Size 37,7 Of oPnlPai Pixel //"Quantidade"
		@ 18,047 MsGet nQuant  Size 038,08 Of oPnlPai Picture PesqPict( "TN0" , "TN0_QTAGEN" ) HASBUTTON Pixel
		@ 20,090 Say OemToAnsi( "Unidade" ) Size 37,7 Of oPnlPai Pixel //"Unidade"
		@ 18,129 MsGet cUnida  Size 038,08 Of oPnlPai Picture PesqPict( "TN0" , "TN0_UNIMED" ) HASBUTTON F3 "MDTV3F" Pixel

	Activate MsDialog oDialog On Init EnchoiceBar( oDialog , { | | nOpcao := 1 , oDialog:End() } , ;
							{ | | nOpcao := 2 , MsgStop( STR0104 ) } ) Center	 //"Não é possível cancelar a operação."

	If nOpcao == 1
		nQtd := nQuant
		cUni := cUnida
	EndIf

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fElimRis
Elimina o risco

@param dDataElim  	- Data de Eliminacao
@param cNumRis		- Numero do Risco

@author Jackson Machado
@since 16/01/2013
/*/
//---------------------------------------------------------------------
Static Function fElimRis( dDataElim , cNumRis )

	dbSelectArea( "TN0" )
	dbSetOrder( 1 )
	If dbSeek( xFilial( "TN0" ) + cNumRis )
		RecLock( "TN0" , .F. )
		TN0->TN0_DTELIM := dDataElim
		TN0->( MsUnLock() )
	EndIf

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fBMarkLoc
Atualiza o total do resultado de acordo com a opcao escolhida

@return

@param cMarca - Valor da Marcao
@param oGet2 - Objeto para atualizacao

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Static Function fBMarkLoc( cMarca , oGet2 , oMark )
	Local cFieldMarca	:= "TRB_OK"
	Local nPos 			:= 0

	nPos := aScan( aColsLoc , { | x | x[ 1 ] == cAval2 } )

	If IsMark( cFieldMarca , cMarca , lInverte )
		aColsLoc[ nPos , 6 ]	:= .F.
		cCodigo1 				:= ( cTRBL )->TRB_CODIGO
		nPeso1					:= ( cTRBL )->TRB_PESO
		nRecno1					:= Recno()
		nCont1					:= 0

		DbSelectArea( cTRBL )
		DbGotop()
		Do While !Eof()
			If !Empty( ( cTRBL )->TRB_OK )
				nCont1 ++
			EndIf
			dbskip()
		EndDo

		If nCont1 > 1
			DbSelectArea( cTRBL )
			If DbSeek( cCodigo1 )
				RecLock( cTRBL , .F. )
				( cTRBL )->TRB_OK := Space( 02 )
				MsUnLock( cTRBL )
			EndIf
		Else
			fGravaTRBB( , cTRBL , aColsLoc , n2 , cTRBC )
			aColsLoc[ n2 , 5 ] := ( aColsLoc[ n2 , 4 ] * nPeso1 ) / 100
		EndIf

		DbGoTo(nRecno1)
		oMark:oBrowse:Refresh()
		oGet2:Refresh()
	Else
		cCodigo1 := ( cTRBL )->TRB_CODIGO
		nPeso1   := ( cTRBL )->TRB_PESO
		nRecno1  := Recno()
		nCont1   := 0
		aColsLoc[ n2 , 5 ] := 0
		fGravaTRBB( , cTRBL , aColsLoc , n2 , cTRBC )
		oTotal1:Refresh()
		DbGoTo( nRecno1 )
		oMark:oBrowse:Refresh()
		oGet2:Refresh()
		aColsLoc[ nPos , 6 ] := .T.
	EndIf

	//fGravaTRBB()

Return .t.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT855LIOK
Validacoes de LinhaOk

@return

@param cTabela 	- Tabela a ser validada
@param lFim 	- Indica se é a verificação do TudoOk

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Function MDT855LIOK( cTabela , lFim )

Local f
Local aColsOk := {}, aHeadOk := {}
Local nPosCod := 1, nPosFai := 0, nAt := 1
Local nCols, nHead

Default lFim := .F.

If cTabela == "TGF"
	aColsOk := aClone( oGetPA:aCols )
	aHeadOk := aClone( aHeadPA )
	nAt 	:= oGetPA:nAt
	nPosCod := aScan( aHeadOk , { | x | Trim( Upper( x[ 2 ] ) ) == "TGF_CODPLA" } )
ElseIf cTabela == "TGG"
	aColsOk := aClone( oGetPE:aCols)
	aHeadOk := aClone( aHeadPE )
	nAt 	:= oGetPE:nAt
	nPosCod := aScan( aHeadOk , { | x | Trim( Upper( x[ 2 ] ) ) == "TGG_CODPLA" } )
ElseIf cTabela == "TGH"
	aColsOk := aClone( oGetOB:aCols)
	aHeadOk := aClone( aHeadOB )
	nAt 	:= oGetOB:nAt
	nPosCod := aScan( aHeadOk , { | x | Trim( Upper( x[ 2 ] ) ) == "TGH_CODOBJ" } )
ElseIf cTabela == "TGI"
	aColsOk := aClone( oGetMO:aCols)
	aHeadOk := aClone( aHeadMO )
	nAt 	:= oGetMO:nAt
	nPosCod := aScan( aHeadOk , { | x | Trim( Upper( x[ 2 ] ) ) == "TGI_CODMON" } )
Endif

If lFim .And. Len( aColsOk ) == 1 .And. ( Empty( aColsOk[ 1 , 1 ] ) .Or. aColsOk[ 1 , Len( aColsOk[ 1 ] ) ] )
	Return .T.
Endif

//Percorre aCols
For f := 1 to Len( aColsOk )
	If !aColsOk[ f , Len( aColsOk[ f ] ) ]//Valida apenas linhas nao deletadas
		If lFim .Or. f == nAt
			//VerIfica se os campos obrigatórios estão preenchidos
			If Empty( aColsOk[ f , nPosCod ] )
				//Mostra mensagem de Help
				Help( " " , 1 , "OBRIGAT2" , , aHeadOk[ nPosCod , 1 ] , 3 , 0 )
				Return .F.
			EndIf
		Endif
		//Verifica se é somente LinhaOk
		If f <> nAt .and. !aColsOk[ nAt , Len( aColsOk[ nAt ] ) ]
			If aColsOk[ f , nPosCod ] == aColsOk[ nAt , nPosCod ]
				Help( " " , 1 , "JAEXISTINF" , , aHeadOk[ nPosCod , 1 ] , 3 , 0 )
				Return .F.
			Endif
		Endif
	Endif
Next f

PutFileInEof( cTabela )

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT855NRE
Relação do campo de responsável

@return Nome do Reponsável

@author Jackson Machado
@since 27/03/2013
/*/
//---------------------------------------------------------------------
Function MDT855NRE()
Return If( INCLUI , "" , NGSEEK( "QAA" , NGSEEK( "TBB" , TGG->TGG_CODPLA , 1 , "TBB_RESPON" ) , 1 , "QAA_NOME" ) )
//---------------------------------------------------------------------
/*/{Protheus.doc} SG390TRM
Gera o treinamento para os responsáveis funcionários

@return .T.

@sample
SG390TRM()

@author Jackson Machado
@since 02/04/2013
/*/
//---------------------------------------------------------------------
Function MDT855TRM( cAlias , nReg , nOpcx )

    Local nOpcao    := 0
    Local nFun		:= 0
	Local lExist	:= .F.

	Local cSeekTRM	:= ""

	//Validacoes do Funcionario
	Local cCusto
	Local cFunc
	Local cTarefa

	//Objetos
	Local oWndCfgEmp, oPnlWnd, oPnlFun, oPnlTrm, oSplitter
	Local oPnlMsgF, oPnlMsgT

	//Definicoes de TRB
	Local nCont		:= 0
	Local cTRBFUN	:= GetNextAlias()
	Local cTRBTRM	:= GetNextAlias()
	Local aDBFFUN	:= {}
	Local aDBFTRM	:= {}
	Local aColFun	:= {}
	Local aColTrm	:= {}

	Local aTRM		:= {}
	Local aFunc		:= {}
	Local aFuncMK	:= {}

	Private cMarca	:= GetMark()

	//Validacoes para utilizacao da funcao
    If !AliasInDic( "TJE" ) .AND. !NGINCOMPDIC("UPDMDTB3","XXXXXX")
		Return .F.
	ElseIf SuperGetMv( "MV_NGMDTTR" , .F. , "" ) <> "1"
		ShowHelpDlg( STR0035 , ;			//"ATENÇÃO"
					{ STR0122 } , 2 , ;	//"Não existe integração com o módulo de treinamento."
					{ STR0123 } , 2 ) 	//"favor habilitar a integração para utilizar esta funcionalidade"
		Return .F.
    EndIf

    fVerLocRis( @cCusto , @cFunc , @cTarefa )

    //Verifica a existência de funcionários na análise
	dbSelectArea( "SRA" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "SRA" ) )
	While SRA->( !Eof() ) .AND. SRA->RA_FILIAL == xFilial( "SRA" )
	    If ( ( SRA->RA_CC == cCusto .Or. cCusto == "*" ) .AND. ;
	    	( SRA->RA_CODFUNC == cFunc .Or. cFunc == "*" ) .AND. ;
	    	( cTarefa == "*" .Or. NGIFDBSEEK( "TN6" , cTarefa + SRA->RA_MAT , 1 ) ) )
	    	aAdd( aFunc , { SRA->RA_MAT } )
	    EndIf
		SRA->( dbSkip() )
	End
	If Len( aFunc ) == 0
		ShowHelpDlg( STR0035 , { STR0105 } , 2 , { STR0106 } , 2 ) //"Atenção"###"Não existem funcionário da folha cadastrados para esta análise."###"Selecione uma análise com funcionários"
		Return .F.
	EndIf

	//Verifica a existência de treinamentos na análise
	dbSelectArea( "TGB" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "TGB" ) + M->TG1_CODPER )
	While TGB->( !Eof() ) .AND. TGB->TGB_FILIAL == xFilial( "TGB" ) .AND. TGB->TGB_CODPER == M->TG1_CODPER
	    dbSelectArea( "TJE" )
	    dbSetOrder( 1 )
	    If dbSeek( xFilial( "TJE" ) + TGB->TGB_CODLEG )
	    	While TJE->( !Eof() ) .AND. TJE->TJE_FILIAL == xFilial( "TJE" ) .AND. TJE->TJE_CODLEG == TGB->TGB_CODLEG
	    		aAdd( aTRM , { TJE->TJE_CALEND , TJE->TJE_CURSO , TJE->TJE_TURMA } )
	    		TJE->( dbSkip() )
	    	End
	    EndIf
		TGB->( dbSkip() )
	End

	dbSelectArea( "TGA" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "TGA" ) + M->TG6_CODDAN )
	While TGA->( !Eof() ) .AND. TGA->TGA_FILIAL == xFilial( "TGA" ) .AND. TGA->TGA_CODDAN == M->TG6_CODDAN
	    dbSelectArea( "TJE" )
	    dbSetOrder( 1 )
	    If dbSeek( xFilial( "TJE" ) + TGA->TGA_CODLEG )
	    	While TJE->( !Eof() ) .AND. TJE->TJE_FILIAL == xFilial( "TJE" ) .AND. TJE->TJE_CODLEG == TGA->TGA_CODLEG
	    		If aScan( aTRM , { | x | x[ 1 ] == TJE->TJE_CALEND .And. x[ 2 ] == TJE->TJE_CURSO .AND. x[ 3 ] == TJE->TJE_TURMA } ) == 0
		    		aAdd( aTRM , { TJE->TJE_CALEND , TJE->TJE_CURSO , TJE->TJE_TURMA } )
		    	EndIf
	    		TJE->( dbSkip() )
	    	End
	    EndIf
		TGA->( dbSkip() )
	End
	If Len( aTRM ) == 0
		ShowHelpDlg( STR0035 , { STR0107 } , 2 , { STR0108 } , 2 ) //"ATENÇÃO"###"Requisitos do perigo/dano não possuem treinamentos."###"Relacione treinamentos aos requisitos."
		Return .F.
	EndIf

	//Monta e Alimenta o TRB de Funcionarios
	aAdd( aDBFFUN , { "OK" 		, "C" , 02 , 0 } )
	aAdd( aDBFFUN , { "MATFUN"	, "C" , 06 , 0 } )
	aAdd( aDBFFUN , { "NOMFUN"	, "C" , 40 , 0 } )

	oTempFunc := FWTemporaryTable():New( cTRBFUN, aDBFFUN )
	oTempFunc:AddIndex( "1", {"MATFUN","NOMFUN"} )
	oTempFunc:AddIndex( "2", {"NOMFUN","MATFUN"} )
	oTempFunc:AddIndex( "3", {"OK"} )
	oTempFunc:Create()

	For nCont := 1 To Len( aFunc )
		RecLock( cTRBFUN , .T. )
		( cTRBFUN )->OK		:= ""
		( cTRBFUN )->MATFUN	:= aFunc[ nCont , 1 ]
		( cTRBFUN )->NOMFUN	:= NGSEEK( "SRA" , aFunc[ nCont , 1 ] , 1 , "RA_NOME" )
		( cTRBFUN )->( MsUnLock() )
	Next nCont

	aAdd( aColFun , { "OK"		, NIL , " "			, } )
	aAdd( aColFun , { "MATFUN"	, NIL , STR0109	, } )//"Matrícula" //"Matrícula"
	aAdd( aColFun , { "NOMFUN"	, NIL , STR0110	, } )//"Nome" //"Nome"

	//Monta e Alimenta o TRB de Treinamentos
	aAdd( aDBFTRM , { "OK" 		, "C" , 02 , 0 } )
	aAdd( aDBFTRM , { "CALEND"	, "C" , 04 , 0 } )
	aAdd( aDBFTRM , { "DESCAL"	, "C" , 20 , 0 } )
	aAdd( aDBFTRM , { "CURSO"	, "C" , 04 , 0 } )
	aAdd( aDBFTRM , { "DESCUR"	, "C" , 30 , 0 } )
	aAdd( aDBFTRM , { "TURMA"	, "C" , 03 , 0 } )
	aAdd( aDBFTRM , { "VAGAS"	, "N" , 12 , 0 } )

	oTempTrm := FWTemporaryTable():New( cTRBTRM, aDBFTRM )
	oTempTrm:AddIndex( "1", {"CALEND","CURSO","TURMA","NOMFUN"} )
	oTempTrm:AddIndex( "2", {"CURSO"} )
	oTempTrm:AddIndex( "3", {"TURMA","CURSO","CALEND"} )
	oTempTrm:AddIndex( "4", {"OK"} )
	oTempTrm:Create()

	For nCont := 1 To Len( aTRM )
		cSeekTRM := aTRM[ nCont , 1 ] + aTRM[ nCont , 2 ] + aTRM[ nCont , 3 ]
		RecLock( cTRBTRM , .T. )
		( cTRBTRM )->OK		:= ""
		( cTRBTRM )->CALEND	:= aTRM[ nCont , 1 ]
		( cTRBTRM )->DESCAL	:= NGSEEK( "RA2" , aTRM[ nCont , 1 ] , 1 , "RA2_DESC" )
		( cTRBTRM )->CURSO	:= aTRM[ nCont , 2 ]
		( cTRBTRM )->DESCUR	:= NGSEEK( "RA1" , aTRM[ nCont , 2 ] , 1 , "RA1_DESC" )
		( cTRBTRM )->TURMA	:= aTRM[ nCont , 3 ]
		( cTRBTRM )->VAGAS	:= NGSEEK( "RA2" , cSeekTRM , 1 , "RA2_VAGAS" ) - NGSEEK( "RA2" , cSeekTRM , 1 , "RA2_RESERV" )
		( cTRBTRM )->( MsUnLock() )
	Next nCont

	aAdd( aColTrm , { "OK"		, NIL , " "		, } )
	aAdd( aColTrm , { "CALEND"	, NIL , STR0058	, } )//"Treinamento" //"Treinamento"
	aAdd( aColTrm , { "DESCAL"	, NIL , STR0018	, } )//"Descrição" //"Descrição"
	aAdd( aColTrm , { "CURSO"	, NIL , STR0111	, } )//"Curso" //"Curso"
	aAdd( aColTrm , { "DESCUR"	, NIL , STR0112	, } )//"Desc. Curso" //"Desc. Curso"
	aAdd( aColTrm , { "TURMA"	, NIL , STR0113	, } )//"Turma" //"Turma"
	aAdd( aColTrm , { "VAGAS"	, NIL , STR0114	, } )//"Vagas Restantes" //"Vagas Restantes"

	dbSelectArea( cTRBFUN )
	dbGoTop()

	dbSelectArea( cTRBTRM )
	dbGoTop()

	//Definicao de Tela
	Define Dialog oWndCfgEmp From 0, 0 To 600, 1000 Title STR0115 Pixel//"Treinamentos a serem gerados" //"Treinamentos a serem gerados"

		// Main Panel
		oPnlWnd := TPanel():New(0, 0, , oWndCfgEmp, , , , , , 0, 0, .F., .F.)
		oPnlWnd:Align := CONTROL_ALIGN_ALLCLIENT

			// Splitter - Centro
			oSplitter := tSplitter():New(01, 01, oPnlWnd, 0, 0)
			oSplitter:Align := CONTROL_ALIGN_ALLCLIENT

			// Left Panel - Funcionários
			oPnlFun := TPanel():New(0, 0, , oSplitter, , , , , , 250, 0, .F., .F.)
			oPnlFun:Align := CONTROL_ALIGN_LEFT

				oPnlMsgF := TPanel():New( 0 , 0 , , oPnlFun , , , , , , 0 , 017 , .F. , .F. )
	 				oPnlMsgF:Align := CONTROL_ALIGN_TOP

	 				TSay():New( 007 , 002 , {|| STR0116 } , ;//"Selecione os funcionários que deverão realizar o treinamento:" //"Selecione os funcionários que deverão realizar o treinamento:"
	 							oPnlMsgF , , , .F. , .F. , .F. , .T. , , , 155 , 008 )

				oMrkFun := MsSelect():New( cTRBFUN , "OK" , , aColFun , , @cMarca, { 0 , 0 , 0 , 0 }, , , oPnlFun )
				oMrkFun:oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT
				oMrkFun:oBrowse:lCANALLMARK := .T.
				oMrkFun:oBrowse:lALLMARK    := .T.
				oMrkFun:oBrowse:bALLMARK    := {|| SetMarkAll( cTRBFUN , @cMarca , oMrkFun )  }
				oMrkFun:bMark               := {|| SetMark( cTRBFUN , @cMarca , , , oMrkFun ) }

			// Right Panel - Treinamentos
			oPnlTrm := TPanel():New(0, 0, , oSplitter, , , , , , 0, 0, .F., .F.)
			oPnlTrm:Align := CONTROL_ALIGN_ALLCLIENT

				oPnlMsgT := TPanel():New( 0 , 0 , , oPnlTrm , , , , , , 0 , 017 , .F. , .F. )
	 				oPnlMsgT:Align := CONTROL_ALIGN_TOP

	 				TSay():New( 007 , 002 , {|| STR0117 } , ;//"Selecione os treinamentos a serem realizados:" //"Selecione os treinamentos a serem realizados:"
	 							oPnlMsgT , , , .F. , .F. , .F. , .T. , , , 135 , 008 )

				oMrkTrm := MsSelect():New( cTRBTRM , "OK" , , aColTrm , , @cMarca , { 0 , 0 , 0 , 0 } , , , oPnlTrm )
				oMrkTrm:oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT
				oMrkTrm:oBrowse:lCANALLMARK := .T.
				oMrkTrm:oBrowse:lALLMARK    := .T.
				oMrkTrm:oBrowse:bALLMARK    := {|| SetMarkAll( cTRBTRM , @cMarca , oMrkTrm )  }
				oMrkTrm:bMark               := {|| SetMark( cTRBTRM , @cMarca , , , oMrkTrm ) }

		oWndCfgEmp:lEscClose := .F.

	Activate Dialog oWndCfgEmp ON INIT EnchoiceBar( oWndCfgEmp , { | | nOpcao := 1 , If( fValTrm( cTRBFUN , cTRBTRM ) , oWndCfgEmp:End() , Nil ) } , { | | nOpcao := 2 , oWndCfgEmp:End() } ) CENTERED

	If nOpcao == 1
		dbSelectArea( cTRBFUN )
		dbGoTop()
		While ( cTRBFUN )->( !Eof() )
		    If !Empty( ( cTRBFUN )->OK )
		    	aAdd( aFuncMK , { ( cTRBFUN )->MATFUN } )
		    EndIf
			( cTRBFUN )->( dbSkip() )
		End

	    dbSelectArea( cTRBTRM )
		dbGoTop()
		While ( cTRBTRM )->( !Eof() )
		    If !Empty( ( cTRBTRM )->OK )

		    	lExist := .F.

		    	For nFun := 1 To Len( aFuncMK )
			    	dbSelectArea( "RA4" )
					dbSetOrder( 1 )
					If dbSeek( xFilial( "RA4" ) + aFuncMK[ nFun , 1 ] + ( cTRBTRM )->CURSO )
				    	RecLock( "RA4" , .F. )
						RA4->( dbDelete() )
						RA4->( MsUnLock() )
					EndIf

				    dbSelectArea( "RAI" )
					dbSetOrder( 1 )
					If dbSeek( xFilial("RAI") + ( cTRBTRM )->CALEND + ( cTRBTRM )->CURSO + ( cTRBTRM )->TURMA + aFuncMK[ nFun , 1 ] )
						RecLock("RAI",.F.)
						dbDelete()
						RAI->(MsUnLock())
					Endif

					dbSelectArea( "RA3" )
   					dbSetOrder( 1 )
					If dbSeek( xFilial("RA3") + aFuncMK[ nFun , 1 ] + ( cTRBTRM )->CURSO )
						While RA3->( !Eof() ) .AND. xFilial("RA3") == RA3->RA3_FILIAL .AND. ;
								RA3->RA3_MAT ==  aFuncMK[ nFun , 1 ] .AND. RA3->RA3_CURSO == ( cTRBTRM )->CURSO
							If RA3->RA3_CALEND == ( cTRBTRM )->CALEND
								RecLock( "RA3" , .F. )
								lExist := .T.
								Exit
							EndIf
							RA3->( dbSkip() )
						End
					EndIf
					If !lExist
						RecLock( "RA3" , .T. )
					EndIf
					RA3->RA3_FILIAL := xFilial( "RA3" )
					RA3->RA3_MAT    := aFuncMK[ nFun , 1 ]
					RA3->RA3_CURSO  := ( cTRBTRM )->CURSO
					RA3->RA3_DATA   := dDataBase
					RA3->RA3_TURMA  := ( cTRBTRM )->TURMA
					RA3->RA3_CALEND := ( cTRBTRM )->CALEND
					RA3->RA3_RESERV := "S"
					RA3->RA3_NVEZAD := 0
					RA3->RA3_SEQ 	 := 0
					RA3->(MsUnLock())
		    	Next nFun

		    EndIf
			( cTRBTRM )->( dbSkip() )
		End
	EndIf

	oTempFunc:Delete()
	oTempTrm:Delete()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SetMark
Função para Marcação

@param cAliasMrk - Area do MarkBrowse
@param cMrkBrw 	- Valor da Marcação
@param lGrMrk  	- Indica se deve inverter a marcacao
@param lAlwMrk 	- Indica se eh MarkAll
@param oBrwMrk 	- Objeto do MarkBrowse

@author Jackson Machado
@since 03/04/13
/*/
//---------------------------------------------------------------------
Static Function SetMark( cAliasMrk , cMrkBrw , lGrMrk , lAlwMrk , oBrwMrk )

	Local lRefreshMrk := ValType( oBrwMrk ) == "O"

	Default lGrMrk  := .F.
	Default lAlwMrk := .F.

	dbSelectArea( cAliasMrk )
	RecLock( cAliasMrk , .F. )
	If lGrMrk
		( cAliasMrk )->OK := GetMrk( ( cAliasMrk )->OK , cMrkBrw , lAlwMrk )
	Endif
	(cAliasMrk)->( MsUnlock() )

	If lRefreshMrk
		oBrwMrk:oBrowse:Refresh( .T. )
		oBrwMrk:oBrowse:SetFocus()
	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} GetMark
Função para verificar a marcação

@param cField	- Campo a ser marcado
@param cMrkBrw	- Valor da Marcação
@param lAlwMrk	- Indica o tipo de marcacao

@author Jackson Machado
@since 03/04/13
/*/
//---------------------------------------------------------------------
Static Function GetMrk( cField , cMrkBrw , lAlwMrk )
Return If( lAlwMrk , cMrkBrw , If( !Empty( cField ) , Space( 2 ) , cMrkBrw ) )

//---------------------------------------------------------------------
/*/{Protheus.doc} SetMarkAll
Função para marcar e desmarcar todos

@param AliasMrk - Area do MarkBrowse
@param cMrkBrw 	- Valor da Marcação
@param oBrwMrk 	- Objeto do MarkBrowse

@author Jackson Machado
@since 03/04/13
/*/
//---------------------------------------------------------------------
Static Function SetMarkAll( cAliasMrk , cMrkBrw , oBrwMrk )

	Local nRecnoMrk

	dbSelectArea( cAliasMrk )
	nRecnoMrk := Recno()
	dbGoTop()
	While !Eof()
		SetMark( cAliasMrk , cMrkBrw , .T. , .F. )
		dbSelectArea( cAliasMrk )
		dbSkip()
	End

	dbSelectArea( cAliasMrk )
	dbGoTo( nRecnoMrk )

	oBrwMrk:oBrowse:Refresh( .T. )
	oBrwMrk:oBrowse:SetFocus()

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fValTrm
Valida os treinametnos

@param cFUN - Alias do arquivo de funcionários
@param cTRM	- Alias do arquivo de treinamentos

@author Jackson Machado
@since 03/04/13
/*/
//---------------------------------------------------------------------
Static Function fValTrm( cFun , cTrm )

	Local nRegFun	:= ( cFun )->( Recno() )
	Local nRegTrm	:= ( cTrm )->( Recno() )
	Local cMsg		:= STR0118 //"Os seguintes treinamentos não possuem a quantidade de vagas solicitadas:"  //"Os seguintes treinamentos não possuem a quantidade de vagas solicitadas:"
	Local lRet		:= .T.
	Local aFuncMK	:= {}
	Local aArea		:= GetArea()


	dbSelectArea( cFUN )
	dbGoTop()
	While ( cFUN )->( !Eof() )
	    If !Empty( ( cFUN )->OK )
	    	aAdd( aFuncMK , { ( cFUN )->MATFUN } )
	    EndIf
		( cFUN )->( dbSkip() )
	End

	dbSelectArea( cTRM )
	dbGoTop()
	While ( cTRM )->( !Eof() )
	    If ( cTRM )->VAGAS < Len( aFuncMK )
			lRet := .F.
			cMsg += CRLF + STR0058 + ":" + CHR( 09 ) + ( cTRM )->CALEND + " - " + AllTrim( ( cTRM )->DESCAL )//"Treinamento" //"Treinamento"
			cMsg += CRLF + STR0111 + ":" + CHR( 09 ) + CHR( 09 ) + ( cTRM )->CURSO  + " - " + AllTrim( ( cTRM )->DESCUR )//"Curso" //"Curso"
			cMsg += CRLF + STR0113 + ":" + CHR( 09 ) + CHR( 09 ) + ( cTRM )->TURMA//"Turma" //"Turma"
			cMsg += CRLF + Replicate( "-" , 100 )
		EndIf
		( cTRM )->( dbSkip() )
	End

	If !lRet
		If FindFunction( "NGMSGMEMO" )
			NGMSGMEMO( STR0035 , cMsg )//"ATENÇÃO" //"ATENÇÃO"
		Else
		 	MsgInfo( cMsg )
		EndIf
	EndIf

	dbSelectArea( cFun )
	dbGoTo( nRegFun )

	dbSelectArea( cTrm )
	dbGoTo( nRegTrm )

	RestArea( aArea )
Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fChkReav
Valida os treinametnos

@param cFUN - Alias do arquivo de funcionários
@param cTRM	- Alias do arquivo de treinamentos

@author Jackson Machado
@since 03/04/13
/*/
//---------------------------------------------------------------------
Static Function fChkReav( nOpcx )
	Local aAreaTG4	:= GetArea()
	Local lReaval	:= .F.
	dbSelectArea( "TG4" )
	dbSetOrder( 1 ) //TG4_FILIAL+TG4_CODCLA

	If nOpcx == 4 .And. TG6->TG6_SITUAC == "2" .And. ;// Verifica se a avalição precisa ser reavalida
			( dbSeek( xFilial( "TG4" ) + TG6->TG6_CODCLA ) .And. TG4->TG4_REAVAL == "1" )
		lReaval := .T.
	EndIf

	RestArea( aAreaTG4 )
Return lReaval
//---------------------------------------------------------------------
/*/{Protheus.doc} ChkOHSAS
Faz a verificação para a execução da rotina MDTA850, MDTA851, MDTA852
MDTA853, MDTA854, MDTA855 e MDTR849

@return boolean

@param

@author Guilherme Benkendorf
@since 01/10/2013
/*/
//---------------------------------------------------------------------
Function ChkOHSAS()
	Local lOHSAS	:= SuperGetMV("MV_NG2OHSA",.F.,"2") == "1"
	Local lRet 	:= .T.

	If !AliasInDic( "TG0" )
		If !NGINCOMPDIC( "UPDMDTB9" , "THXD30" )
			lRet := .F.
		EndIf
	ElseIf !AliasInDic( "TG1" )
		If !NGINCOMPDIC( "UPDMDT70" , "XXXXXX" )
			lRet := .F.
		Endif
	ElseIf !lOHSAS //Não utiliza OHSAS 18001
		MsgInfo( STR0124 , STR0035 )//"Rotina não poderá ser executada. O parâmetro 'MV_NG2OHSA' não está habilitado."//"Atenção"
		lRet := .F.
	EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fExcluiReav
Exclui o vinculo de reavaliação

@return Nil

@param

@author Jackson Machado
@since 01/10/2013
/*/
//---------------------------------------------------------------------
Function fExcluiReav( cCodOrdem )

	Local nTables
	Local cCodReav	:= cCodOrdem
	Local cHisBusca	:= ""
	Local cOrdBusca	:= ""
	Local aTabRel	:= { ;
							{ "TGE" , 1 } , ;
							{ "TGJ" , 1 } , ;
							{ "TGK" , 1 } , ;
							{ "TGL" , 1 } , ;
							{ "TGM" , 1 } , ;
							{ "TGO" , 1 } ;
						}

	While !Empty( cCodReav )

		dbSelectArea( "TGD" )
		dbSetOrder( 4 )
		dbSeek( xFilial( "TGD" ) + cCodReav )
		cHisBusca := TGD->TGD_CODHIS
		cOrdBusca := TGD->TGD_ORDEM
		RecLock( "TGD" , .F. )
		TGD->( dbDelete() )
		TGD->( MsUnLock() )

		For nTables := 1 To Len( aTabRel )
			dbSelectArea( aTabRel[ nTables , 1 ] )
			dbSetOrder( aTabRel[ nTables , 2 ] )
			dbSeek( xFilial( aTabRel[ nTables , 1 ] ) + cHisBusca )
			While ( aTabRel[ nTables , 1 ] )->( !Eof() ) .And. ;
				&( ( aTabRel[ nTables , 1 ] ) + "->" + PrefixoCPO( ( aTabRel[ nTables , 1 ] ) ) + "_FILIAL" ) == xFilial( ( aTabRel[ nTables , 1 ] ) ) .And. ;
				&( ( aTabRel[ nTables , 1 ] ) + "->" + PrefixoCPO( ( aTabRel[ nTables , 1 ] ) ) + "_CODHIS" ) == cHisBusca
				RecLock( aTabRel[ nTables , 1 ] , .F. )
				( aTabRel[ nTables , 1 ] )->( dbDelete() )
				( aTabRel[ nTables , 1 ] )->( MsUnLock() )
				( aTabRel[ nTables , 1 ] )->( dbSkip() )
			End
		Next nTables

		dbSelectArea( "TGD" )
		dbSetOrder( 4 )
		dbSeek( xFilial( "TGD" ) + cOrdBusca )

		cCodReav := TGD->TGD_REAVAL

	End

Return
