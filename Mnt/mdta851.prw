#Include "MDTA851.ch"
#Include "Protheus.ch"

#DEFINE _nVERSAO 2 //Versao do fonte
//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA851
Programa para cadastrar formulas.

@return

@sample
MDTA851()

@author Jackson Machado
@since 22/03/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDTA851()

	//-----------------------------------------------------
	// Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	//-----------------------------------------------------
	Local aNGBEGINPRM 	:= NGBEGINPRM( _nVERSAO,,{"TG0"} )

	Private aRotina 	:= MenuDef()

	Private cCadastro 	:= OemtoAnsi( STR0001 )   //"Formulas" //"Fórmulas"
	Private aChkDel 	:= {} , bNgGrava

	If !AliasInDic( "TG0" )
		NGINCOMPDIC("UPDMDT88","THXDPI")

		//-----------------------------------------------------
		// Devolve variaveis armazenadas (NGRIGHTCLICK)
		//-----------------------------------------------------
		NGRETURNPRM( aNGBEGINPRM )

		Return .F.
	EndIf

	DbSelectArea( "TG0" )
	DbSetOrder( 1 )
	mBrowse( 6 , 1 , 22 , 75 , "TG0" )

	//-----------------------------------------------------
	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	//-----------------------------------------------------
	NGRETURNPRM( aNGBEGINPRM )

Return .t.
//---------------------------------------------------------------------
/*/{Protheus.doc} SGA120PRO
Processa visualizacao/inclusao/alteracao/exclusao da formula

@return

@param cAlias 	- Alias a ser do mBrowse
@param nRecno	- Recno a ser tratado
@param nOpcx	- Opção do MenuDef

@sample
MDT001GRV( 'TG3' , 1 , 2 )

@author Jackson Machado
@since 22/03/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDT851PRO( cAlias , nRecno , nOpcx )

	Local cTitulo := cCadastro // Titulo da janela
	Local oDlg// Objeto para montar a janela de cadastro
	Local oMenu
	Local lVisual := .t.
	Local nControl:= 0,nOK := 0
	Local aPages:= {},aTitles:= {},aVAR:= {}
	Local Ni,oFont,oGet,cGet
	Local aSize := MsAdvSize()
	Local nLeft := 0
	Local oPnlTDet, oTDet, cTDet,oPnlPai
	Local oFontB := TFont():New( "Arial" , , 14 , , .T. )

	Local cGetPg := Space( TAMSX3( "TJ3_QUESTA" )[1] )

	Private nPula := 70
	Private aCbx1  := MDT851COM( "2" )
	Private aCriterio  := {}           // Tipos de criterios
	Private oCriterio                  // Objeto
	Private cCriterio  := Space(50)    // Variavel Critério
	Private oCbx1// Objeto do primeiro combo box
	Private cFormula   := Space( Len( TG0->TG0_CODFOR ) )
	Private cDescricao := Space( Len( TG0->TG0_DESCRI ) )
	Private cCbx1 := Space( If( AliasInDic( "TG2" ),Len( TG2->TG2_DESCRI ),40 ) )
	Private cCbx2 := ""
	Private cMemoFor := ""
	Private oMemo
	Private aSvATela := {}, aSvAGets := {}, aTela := {}, aGets := {}, anao := {}

	// Utilizadas no Folder de Perguntas
	Private oGetQt := Nil
	Private oGetPg := Nil
	Private oBtnPg := Nil

	// Utilizadas no Folder de Desempenho
	Private oDe       := Nil
	Private nDe       := 0
	Private oAte      := Nil
	Private nAte      := 0
	Private oRet      := Nil
	Private cRet      := Space( 50 )
	Private oBtnAdd   := Nil
	Private oBtnAlt   := Nil
	Private oBtnDel   := Nil
	Private aDeAte    := { { ,,, } } // array para indicar os níveis de ateh da fórmula que possui desempenho.
	Private oBrwDeAte := Nil
	Private cItemAtu  := "" // usado para indicar o item de desempenho que se esta alterando excluindo atualmente
	Private nOpDpAtu  := 0  // usada para indicar a operação atual que se realiza com registro de desempenho

	aAdd( aCriterio , STR0002 ) //"Perigo"
	aAdd( aCriterio , STR0003 ) //"Dano"
	aAdd( aCriterio , STR0004 ) //"Localização"

	If !( Alltrim( GetTheme() ) == "FLAT" ) .And. !SetMdiChild()
		aSize[ 7 ] := aSize[ 7 ] - 50
		aSize[ 6 ] := aSize[ 6 ] - 30
		aSize[ 5 ] := aSize[ 5 ] - 14
		nLeft := 5
	EndIf

	Aadd( aTitles , OemToAnsi( STR0005 ) ) //"Operadores"
	Aadd( aPages , "Header 1" )
	nControl++

	Aadd( aTitles , OemToAnsi( STR0006 ) ) //"Comparadores"
	Aadd( aPages , "Header 2" )
	nControl++

	Aadd( aTitles , OemToAnsi( STR0007 ) ) //"Números"
	Aadd( aPages , "Header 3" )
	nControl++

	aAdd( aTitles , OemToAnsi( STR0028 ) ) //"Perguntas"
	aAdd( aPages , "Header 3" )
	nControl++

	aAdd( aTitles , OemToAnsi( STR0029 ) ) //"Desempenho"
	aAdd( aPages , "Header 3" )
	nControl++

	If nOpcx <> 3
	   cFormula		:= TG0->TG0_CODFOR
	   cDescricao	:= TG0->TG0_DESCRI
	   cMemoFor		:= TG0->TG0_FORMUL
	EndIf

	If AllTrim( Str( nOpcx ) ) $ "25"
	   lVisual    := .f.
	EndIf

	Define MsDialog oDlg From aSize[ 7 ] , nLeft to aSize[ 6 ] , aSize[ 5 ] Title cTitulo Pixel

	//Panel criado para correta disposicao da tela
	oPnlPai := TPanel():New( , , , oDlg , , , , , , , , .F. , .F. )
		oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

	oPanel1 := TPanel():New( 01 , 01 , , oPnlPai , , , , , , 10 , 10 , .F. , .F. )
	oPanel1:Align := CONTROL_ALIGN_TOP
	oPanel1:nHeight := 130

	oPanel2 := TPanel():New( 01 , 01 , , oPnlPai , , , , , , 10 , 10 , .F. , .F. )
	oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

	oPanel21 := TPanel():New( 01 , 01 , , oPanel2 , , , , , , 10 , 10 , .F. , .F. )
	oPanel21:Align := CONTROL_ALIGN_TOP
	oPanel21:nHeight := 50

	oPanel22 := TPanel():New( 01 , 01 , , oPanel2 , , , , , , 10 , 10 , .F. , .F. )
	oPanel22:Align := CONTROL_ALIGN_ALLCLIENT

	aNao := { "TG0_FORMUL","TG0_QUESTI" }

	aChoice  := NGCAMPNSX3( "TG0" , aNao )

	aTela := {}
	aGets := {}
	dbselectarea( "TG0" )
	RegToMemory( "TG0" , ( nOpcx == 3 ) )
	oEnc01:= MsMGet():New( "TG0" , nRecno , nOpcx , , , , aChoice , { 14 , 0 , 50 , 280 } , , , , , , oPanel1 , , , .F. , "aSvATela" )
	oEnc01:oBox:bGotFocus := { | | NgEntraEnc( "TG0" ) }
	oEnc01:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	aSvATela := aClone( aTela )
	aSvAGets := aClone( aGets )

	@ 006.5,008 Say OemToAnsi(STR0008) Size 50,7 Of oPanel21 Pixel // Criterio de + Conteudo campo X3_CBOX do CAMPO TA6_TIPO //"Critério de "
	@ 005,061 ComboBox oCriterio Var cCriterio Items aCriterio Size 080, 65 Of oPanel21 Pixel When lVisual .And. ( M->TG0_TPFORM != "2" ) Valid TrocaCombo(lVisual)
	@ 005,150 ComboBox oCbx1 Var cCbx1 Items aCbx1 Size 140, 65 Of oPanel21 Pixel When lVisual .And. ( M->TG0_TPFORM != "2" )

	oCriterio:bHelp  := { | | ShowHelpCpo( STR0009 , ; //"Critérios da Fórmula " //"Critérios da Fórmula "
	      			        	{ STR0010 } , 5 , ;  //"Os critérios das fórmulas podem ser 1-Perigo , 2-Dano e ou 3-Localização"
								{ } , 5 )  }

	oCbx1:bHelp  := { | | ShowHelpCpo( STR0011 , ; //"Critérios" //"Critérios"
								{ STR0012 } , 5 , ; //"Informe um critério que seja avaliado por peso"
	           	           		{ } , 5 )  }

	oFolder := TFolder():New( 6 , 1 , aTitles , aPages , oPanel22 , , , , .F. , .F. , 270 , 40 , )
	oFolder:aDialogs[ 1 ]:oFont	:= oDlg:oFont
	oFolder:aDialogs[ 2 ]:oFont	:= oDlg:oFont
	oFolder:Align 				:= CONTROL_ALIGN_TOP
	oFolder:nHeight 			:= 200
	oFolder:bSetOption          := ( { |nNewOption| fChgFold851( nNewOption ) } )

	oPnlTDet := TPanel():New( 900 , 900 , , oPanel22 , , , , , RGB( 67 , 70 , 87 ) , 200 , 200 , .F. , .F. )
	oPnlTDet:Align 				:= CONTROL_ALIGN_TOP
	oPnlTDet:nHeight 			:= 25

	cTDet := STR0013 //"Detalhamento:"
	@ 002,008 SAY oTDet VAR cTDet SIZE 200, 20 Font oFontB Color RGB( 255 , 255 , 255 ) OF oPnlTDet PIXEL

	oMemo:= tMultiget():New( 120 , 008 , { | u | If( Pcount() > 0 , cMemoFor := u , cMemoFor ) } , ;
				oPanel22 , 250 , 40 , , .F. , , , , .T. , , , , , , .T. )
	oMemo:Align 				:= CONTROL_ALIGN_ALLCLIENT

	@ 100,008 TO 110,248 Label "" of oFolder:aDialogs[ 1 ] Pixel

	@ 010 , 010 Button oBtn1 Prompt "+" Size 20 , 10 Of oFolder:aDialogs[ 1 ] Pixel Action MDT851ADD( "+" )
	@ 010 , 040 Button oBtn2 Prompt "-" Size 20 , 10 Of oFolder:aDialogs[ 1 ] Pixel Action MDT851ADD( "-" )
	@ 010 , 070 Button oBtn3 Prompt "*" Size 20 , 10 Of oFolder:aDialogs[ 1 ] Pixel Action MDT851ADD( "*" )
	@ 010 , 100 Button oBtn4 Prompt "/" Size 20 , 10 Of oFolder:aDialogs[ 1 ] Pixel Action MDT851ADD( "/" )
	@ 010 , 130 Button oBtn5 Prompt "(" Size 20 , 10 Of oFolder:aDialogs[ 1 ] Pixel Action MDT851ADD( "(" )
	@ 010 , 160 Button oBtn6 Prompt ")" Size 20 , 10 Of oFolder:aDialogs[ 1 ] Pixel Action MDT851ADD( ")" )
	@ 010 , 190 Button oBtn7 Prompt STR0014 Size 20 , 10 Of oFolder:aDialogs[ 1 ] Pixel Action MDT851ADD( "If" ) //"Se"
	@ 010 , 220 Button oBtn8 Prompt STR0015 Size 20 , 10 Of oFolder:aDialogs[ 1 ] Pixel Action MDT851ADD( "," ) //"Senao"

	@ 010 , 010 Button oBtn11 Prompt "="  Size 20 , 10 Of oFolder:aDialogs[ 2 ] Pixel Action MDT851ADD( "=" )
	@ 010 , 040 Button oBtn12 Prompt "<>" Size 20 , 10 Of oFolder:aDialogs[ 2 ] Pixel Action MDT851ADD( "<>" )
	@ 010 , 070 Button oBtn13 Prompt "<"  Size 20 , 10 Of oFolder:aDialogs[ 2 ] Pixel Action MDT851ADD( "<" )
	@ 010 , 100 Button oBtn14 Prompt "<=" Size 20 , 10 Of oFolder:aDialogs[ 2 ] Pixel Action MDT851ADD( "<=" )
	@ 010 , 130 Button oBtn15 Prompt ">"  Size 20 , 10 Of oFolder:aDialogs[ 2 ] Pixel Action MDT851ADD( ">" )
	@ 010 , 160 Button oBtn16 Prompt ">=" Size 20 , 10 Of oFolder:aDialogs[ 2 ] Pixel Action MDT851ADD( ">=" )

	@ 010 , 010 Button oBtn1 Prompt "1" Size 20 , 10 Of oFolder:aDialogs[ 3 ] Pixel Action MDT851ADD( "1" )
	@ 010 , 035 Button oBtn2 Prompt "2" Size 20 , 10 Of oFolder:aDialogs[ 3 ] Pixel Action MDT851ADD( "2" )
	@ 010 , 060 Button oBtn3 Prompt "3" Size 20 , 10 Of oFolder:aDialogs[ 3 ] Pixel Action MDT851ADD( "3" )
	@ 010 , 085 Button oBtn4 Prompt "4" Size 20 , 10 Of oFolder:aDialogs[ 3 ] Pixel Action MDT851ADD( "4" )
	@ 010 , 110 Button oBtn5 Prompt "5" Size 20 , 10 Of oFolder:aDialogs[ 3 ] Pixel Action MDT851ADD( "5" )
	@ 010 , 135 Button oBtn6 Prompt "6" Size 20 , 10 Of oFolder:aDialogs[ 3 ] Pixel Action MDT851ADD( "6" )
	@ 010 , 160 Button oBtn7 Prompt "7" Size 20 , 10 Of oFolder:aDialogs[ 3 ] Pixel Action MDT851ADD( "7" )
	@ 010 , 185 Button oBtn8 Prompt "8" Size 20 , 10 Of oFolder:aDialogs[ 3 ] Pixel Action MDT851ADD( "8" )
	@ 010 , 210 Button oBtn7 Prompt "9" Size 20 , 10 Of oFolder:aDialogs[ 3 ] Pixel Action MDT851ADD( "9" )
	@ 010 , 235 Button oBtn8 Prompt "0" Size 20 , 10 Of oFolder:aDialogs[ 3 ] Pixel Action MDT851ADD( "0" )

	//--------------------------
	// Folder de Perguntas
	//--------------------------

		@ 010,010 Say OemToAnsi( STR0030 ) Size 70,7 Of oFolder:aDialogs[4] Pixel // "Questionário: "
		@ 010,050 MsGet oGetQt Var M->TG0_QUESTI Picture "@!" Size 015,008 Of oFolder:aDialogs[4] F3 "TJ2" Hasbutton Valid fValQt851( M->TG0_QUESTI ) Pixel

		// Deixa mudar Questionário da fórmula apenas se for inclusão
		If nOpcx != 3
			oGetQt:Disable()
		EndIf

		@ 010,090 Say OemToAnsi( STR0031 ) Size 70,7 Of oFolder:aDialogs[4] Pixel // "Pergunta: "
		@ 010,120 MsGet oGetPg Var cGetPg Picture "@!" Size 007,008 Of oFolder:aDialogs[4] F3 "TJ3" Hasbutton When !Empty( M->TG0_QUESTI ) Valid fValPg851( M->TG0_QUESTI,cGetPg ) Pixel
		oGetPg:bHelp := { || ShowHelpCpo( "cGetPg",{ "Informe a pergunta para adicionar na fórmula." },5,{},5 ) } // "Informe a pergunta para adicionar na fórmula."

		@ 010,170 Button oBtnPg Prompt STR0032 Size 050,10 Of oFolder:aDialogs[4] Pixel Action If ( !Empty( cGetPg ),MDT851ADD( "#" + cGetPg + "#" ), ShowHelpCpo( "cGetPg",{ "Informe a pergunta para adicionar na fórmula." },5,{},5 ) ) Pixel // "Adicionar"

		If nOpcx != 3 .And. nOpcx != 4
			oBtnPg:Disable()
		EndIf

	//-----------------------
	// Folder Desempenho
	//-----------------------

		@ 010,010 Say OemToAnsi( STR0033 ) Size 070,007 Of oFolder:aDialogs[5] Pixel // "Resultado"

		@ 010,060 Say OemToAnsi( STR0034 ) Size 050,007 Of oFolder:aDialogs[5] Pixel // "De:"
		@ 010,080 MsGet oDe Var nDe Size 050,008 Picture "@E 999,999,999.99" Of oFolder:aDialogs[5] Pixel Hasbutton
			oDe:bHelp := { || ShowHelpCpo( "nDe",{ STR0035 },5,{},5 ) } // "Indica a faixa inicial do item de desempenho."

		@ 010,150 Say OemToAnsi( STR0037 ) Size 050,007 Of oFolder:aDialogs[5] Pixel // "Até:"
		@ 010,170 MsGet oAte Var nAte Size 050,008 Picture "@E 999,999,999.99" Of oFolder:aDialogs[5] Pixel Hasbutton
			oAte:bHelp := { || ShowHelpCpo( "nAte",{ STR0036 },5,{},5 ) } // "Indica a faixa final do item de desempenho."

		@ 025,010 Say OemToAnsi( STR0038 ) Size 070,007 Of oFolder:aDialogs[5] Pixel // "Retornar: "
		@ 025,050 MsGet oRet Var cRet Size 080,008 Of oFolder:aDialogs[5] Pixel
			oRet:bHelp := { || ShowHelpCpo( "cRet",{ STR0039 },5,{},5 ) } // "Indica o texto de retorno do item, que será exibido no relatório de Desvio de Respostas de acordo com o resultado da Fórmula."

		@ 025,130 Button oBtnRet Prompt STR0040 Size 030,010 Of oFolder:aDialogs[5] Pixel Action fMngBrwDsp( 1 ) // "Concluir"
		@ 025,165 Button oBtnRet Prompt STR0041 Size 030,010 Of oFolder:aDialogs[5] Pixel Action fMngBrwDsp( 5 ) // "Cancelar"

		oDe:Disable()
		oAte:Disable()
		oRet:Disable()

		If !( cValToChar( nOpcx ) $ "34" )
			oBtnRet:Disable()
		EndIf

		@ 010,260 Button oBtnAdd Prompt STR0042 Size 030,010 Of oFolder:aDialogs[5] Pixel Action fMngBrwDsp( 2 ) When ( nOpcx == 3 .Or. nOpcx == 4 ) // "Incluir"
		@ 025,260 Button oBtnAlt Prompt STR0043 Size 030,010 Of oFolder:aDialogs[5] Pixel Action fMngBrwDsp( 3 ) When ( nOpcx == 3 .Or. nOpcx == 4 ) // "Alterar"
		@ 040,260 Button oBtnDel Prompt STR0044 Size 030,010 Of oFolder:aDialogs[5] Pixel Action fMngBrwDsp( 4 ) When ( nOpcx == 3 .Or. nOpcx == 4 ) // "Deletar"

		oBrwDeAte := TCBrowse():New( 005,300,300,080,,,,oFolder:aDialogs[5],,,,,,,,,,,,,,.T.,,,,.T., )

			oBrwDeAte:AddColumn( TCColumn():New( STR0045,{ || aDeAte[oBrwDeAte:nAt][1] },,,,,50,.F.,.F.,,,,, ) ) // "Item"
			oBrwDeAte:AddColumn( TCColumn():New( STR0046,  { || aDeAte[oBrwDeAte:nAt][2] },,,,,50,.F.,.F.,,,,, ) ) // "De"
			oBrwDeAte:AddColumn( TCColumn():New( STR0047, { || aDeAte[oBrwDeAte:nAt][3] },,,,,50,.F.,.F.,,,,, ) ) // "Até"
			oBrwDeAte:AddColumn( TCColumn():New( STR0048,{ || aDeAte[oBrwDeAte:nAt][4] },,,,,50,.F.,.F.,,,,, ) ) // "Retornar"
			oBrwDeAte:lAutoEdit := .F.
			oBrwDeAte:lReadOnly := .F.

			// carrega dados de browse de desempenho
			fLoadBrw( .T. )

			oBrwDeAte:SetArray( aDeAte )
			oBrwDeAte:bLine := { || { aDeAte[oBrwDeAte:nAt][1],aDeAte[oBrwDeAte:nAt][2],aDeAte[oBrwDeAte:nAt][3],aDeAte[oBrwDeAte:nAt][4] } }
			oBrwDeAte:Refresh()

	//-----------------------
	// Botões da rotina
	//-----------------------
	@ 005,295 Button oBtn9 Prompt STR0016 Size 40,12 Of oPanel21 Pixel Action MDT851ADD() //"Adiciona"
    @ 005,345 Button oBtn10 Prompt STR0017 Size 40,12 Of oPanel21 Pixel Action ( cMemoFor := "" , oMemo:Refresh() , nPula := 70 ) //"Limpa Filtro"

    If !Inclui .And. M->TG0_TPFORM == "2"
    	oBtn9:Disable()
    EndIf

	If !lVisual
	   oBtn1:Disable()
	   oBtn2:Disable()
	   oBtn3:Disable()
	   oBtn4:Disable()
	   oBtn5:Disable()
	   oBtn6:Disable()
	   oBtn7:Disable()
	   oBtn8:Disable()
	   oBtn9:Disable()
	   oBtn10:Disable()
	   oBtn11:Disable()
	   oBtn12:Disable()
	   oBtn13:Disable()
	   oBtn14:Disable()
	   oBtn15:Disable()
	   oBtn16:Disable()
	EndIf

	@ 1000 , 1000 MsGet oGet Var cGet Picture "@!" Size 1 , 01 Of oFolder:aDialogs[ 2 ]

	NGPOPUP( aSMenu , @oMenu )
	oDlg:bRClicked:= { | o , x , y | oMenu:Activate( x , y , oDlg ) }
	oEnc01:oBox:bRClicked:= { | o , x  , y | oMenu:Activate( x , y , oDlg ) }
	TrocaCombo(lVisual)
	Activate MsDialog oDlg On Init EnchoiceBar( oDlg , { | | nOpca := 1 , ;
															If( !MDT851Grv( nOpcx ) , nOpca := 0 , oDlg:End() ) } , ;
															{ | | oDlg:End() } )

Return .t.
//---------------------------------------------------------------------
/*/{Protheus.doc} SGA120PRO
Carrega combobox com as Avaliacoes do Perigo/Dano

@return aCombo - Retorna o ComboBox

@sample
MDT001GRV()

@author Jackson Machado
@since 22/03/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDT851COM( cTipo )

	Local aCombo	:= {}

	Default cTipo	:= "2"

	If AliasInDic( "TG2" )
	DbSelectArea( "TG2" )
	DbSetOrder( 1 )
	DbSeek( xFilial( "TG2" ) )
	While !Eof() .and. xFilial( "TG2" ) == TG2->TG2_FILIAL

	   If TG2->TG2_TIPO == cTipo .and. TG2->TG2_PESO > 0
		   Aadd( aCombo , AllTrim( TG2->TG2_DESCRI ) )
		EndIf
	   TG2->( dbSkip() )
	End
	EndIf

Return aCombo
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT851ADD
Adiciona as avaliacoes na formula

@return

@sample
MDT851ADD( '+' )

@author Jackson Machado
@since 22/03/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDT851ADD( cOperacao )

	If Len( aCbx1 ) == 0 .And. M->TG0_TPFORM == "1" // Se não existir nenhum critério com Peso Cadastrado e a fórmula for do tipo Critério, não deixa incluir Fórmula
	   Help( " " , 1 , STR0018 , , STR0019 , 3 , 1 ) //"ATENÇÃO"###"O critério informado não possui nenhuma avalição por peso , portanto não pode ser utilizado em fórmulas"
	   Return .F.
	Endif

	If Len( cMemoFor )  >=  nPula
		nPula += 70
	EndIf
	If cOperacao == Nil
		cMemoFor +=  "#" + cCbx1 + "# "
	ElseIf cOperacao $ "1234567890"
		If SubStr( cMemoFor , Len( cMemoFor ) - 1 , 1 ) $ "1234567890"
			cMemoFor := RTRIM( cMemoFor ) + cOperacao + " "
		Else
			cMemoFor += cOperacao + " "
		EndIf
	Else
		cMemoFor += cOperacao + " "
	Endif
	oMemo:Refresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT851FOR
Valida se a formula digitada esta correta

@return Lógico - Retorna verdadeiro caso formula correta

@sample
MDT851FOR()

@author Jackson Machado
@since 22/03/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDT851FOR()

	Local i
	Local nTotal 	:= 0
	Local nHif		:=0
	Local nQtd		:= 0
	Local Ind		:= 1
	Local nCount 	:= 0
	Local cStrForm , cAlias
	Local cArquivo , cVar := ""
	Local cCampo 	:= ""
	Local cSavAlias := Alias()
	Local lQuit  	:= .F.
	Local lSair 	:=.F.
	Local aAlias 	:= {} , aAval := {}
	Local bBlock 	:= ErrorBlock() , bErro := ErrorBlock( { | e | ChecErro( e ) } )
	Local aCampo 	:= {}
	Local xResult

	Private lRet:=.T.

	cStrForm := Upper( cMemoFor )

	If Empty( cStrForm )
		Help( " " , 1 , STR0018 , , STR0020 , 3 , 1 ) //"ATENÇÃO"###"A fórmula nao pode ficar vazia"
		Return .f.
	EndIf

	If M->TG0_TPFORM == "2" // Caso fórmula do tipo de Perguntas, não valida a execução da fórmula.
		Return .T.
	EndIf

	BEGIN SEQUENCE
		Do While !lSair
			nAcha := 0
			nAcha := AT( "#" , SubStr( cStrForm , nTotal + 1 , Len( cStrForm ) ) )
			If nAcha > 0
				nTotal 	+= nAcha
				nHif 	:= nAcha
				aAdd( aAlias , { nAcha , nTotal } )
				nQtd ++
			Else
				lSair := .t.
			EndIf
		EndDo
	END SEQUENCE

	cVar := cStrForm

	BEGIN SEQUENCE
		For i := 1 to Len( aAlias ) - 1
			If Mod( i , 2 ) <> 0
				aAdd( aAval, { SubStr( cStrForm , aAlias[ i , 2 ] + 1 , aAlias[ i + 1 , 1 ] - 1 ) } )
			EndIf
		Next i
	END SEQUENCE

	TexLinha := cStrForm

	BEGIN SEQUENCE
		For i := 1 To Len( TexLinha )
			If SubStr( TexLinha , Ind , 1 ) == "#"
				If nCount > 1
					nCount := 0
					aAdd( aCampo, { 0 } )
					Ind++
				EndIf
			EndIf
			If SubStr( TexLinha , Ind , 1 ) <> "#" .and. nCount == 0
				aAdd( aCampo, { SubStr( TexLinha , Ind , 1 ) } )
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
	END SEQUENCE

	If AliasInDic( "TG2" )
	BEGIN SEQUENCE
		For i:= 1 to Len( aAval )
			cAvaliacao := aAval[ i , 1 ]
			DbSelectArea( "TG2" )
			DbSetOrder( 2 )
			If DbSeek( xFilial( "TG2" ) + cAvaliacao )
				lRet := .T.
			Else
				lRet := .F.
				Help( " " , 1 , STR0018 , , STR0021 + aAval[ i , 1 ] , 3 , 1 ) //"ATENÇÃO"###"Nao existe a avaliação "
			EndIf
		Next

		xResult := &cCampo
	End SEQUENCE
	EndIf

	DbSelectArea( cSavAlias )
	ErrorBlock( bBlock )

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT851Grv
Checa a fórmula e grava

@return Lógico - Retorna verdadeiro caso efetivou a gravação

@sample
MDT851Grv()

@author Jackson Machado
@since 22/03/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDT851Grv( nOpcx )

	Local cSeqTJ6 := "000"
	Local nI      := 0

	If Empty( M->TG0_CODFOR )
	   Help( " " , 1 , STR0018 , , STR0022 , 3 , 1 ) //"ATENÇÃO"###"O código não pode estar vazio."
	   Return .F.
	EndIf

	If AllTrim( Str( nOpcx ) ) $  "34"
		If !MDT851FOR()
			Return .F.
		EndIf
	ElseIf nOpcx == 5
		If !fValDelete()
			Return .F.
		Endif
	EndIf

	If AllTrim( Str( nOpcx ) ) $ "34"

		DbSelectArea( "TG0" )
		DbSetOrder( 1 ) // TG0_FILIAL+TG0_CODFOR
		If DbSeek( xFilial("TG0") + cFormula )
		   RecLock( "TG0" , .F. )
		Else
		   RecLock( "TG0" , .T. )
		EndIf

	   TG0->TG0_FILIAL := xFilial( "TG0" )
	   TG0->TG0_CODFOR := M->TG0_CODFOR
	   TG0->TG0_DESCRI := M->TG0_DESCRI
	   TG0->TG0_QUESTI := M->TG0_QUESTI
	   TG0->TG0_TPFORM := M->TG0_TPFORM
	   TG0->TG0_FORMUL := cMemoFor
	   MsUnLock( "TG0" )

	   	// Deleta registros da TJ6 caso exista desempenho relacionado a fórmula
		DbSelectArea( "TJ6" )
		DbSetOrder( 01 ) // TJ6_FILIAL+TJ6_CODFOR+TJ6_ITDE+TJ6_ITATE
		If DbSeek( xFilial( "TJ6" ) + M->TG0_CODFOR )
			While !EoF() .And. TJ6->( TJ6_FILIAL + TJ6_CODFOR ) == xFilial( "TJ6" ) + M->TG0_CODFOR
				RecLock( "TJ6",.F. )
				DbDelete()
				MsUnLock( "TJ6" )

				DbSelectArea( "TJ6" )
				DbSkip()
			EndDo
		EndIf

		// Insere registros de desempenho
		If M->TG0_TPFORM == "2" // Caso Fórmula tipo Questionário.
			For nI := 1 To Len( aDeAte )
				If aDeAte[nI][3] > 0
					cSeqTJ6 := Soma1( cSeqTJ6 )
					RecLock( "TJ6",.T. )
					TJ6->TJ6_FILIAL := xFilial( "TJ6" )
					TJ6->TJ6_IDFXA  := cSeqTJ6
					TJ6->TJ6_CODFOR := M->TG0_CODFOR
					TJ6->TJ6_ITDE   := aDeAte[nI][2]
					TJ6->TJ6_ITATE  := aDeAte[nI][3]
					TJ6->TJ6_RETOR  := aDeAte[nI][4]
					MsUnLock( "TJ6" )
				EndIf
			Next nI
		EndIf

	ElseIf nOpcx == 5

		// Deleta registros da TJ6 caso exista desempenho relacionado a fórmula
		DbSelectArea( "TJ6" )
		DbSetOrder( 01 ) // TJ6_FILIAL+TJ6_CODFOR+TJ6_ITDE+TJ6_ITATE
		If DbSeek( xFilial( "TJ6" ) + M->TG0_CODFOR )
			While !EoF() .And. TJ6->( TJ6_FILIAL + TJ6_CODFOR ) == xFilial( "TJ6" ) + M->TG0_CODFOR
				RecLock( "TJ6",.F. )
				DbDelete()
				MsUnLock( "TJ6" )

				DbSelectArea( "TJ6" )
				DbSkip()
			EndDo
		EndIf

		DbSelectArea( "TG0" )
		DbSetOrder( 1 ) // TG0_FILIAL+TG0_CODFOR
		If DbSeek( xFilial("TG0") + cFormula )
			RecLock( "TG0" , .F. )
			DbDelete()
			MsUnLock( "TG0" )
		EndIf

	EndIf

	MsUnLock( "TG0" )

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fValDelete
Valida a deleção do Registro

@return Lógico - Retorna verdadeiro caso esteja correto para deletar

@sample
fValDelete()

@author Jackson Machado
@since 22/03/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fValDelete()

Return NGVALSX9("TG0",,.T.)
//---------------------------------------------------------------------
/*/{Protheus.doc} TrocaCombo
Muda o ComboBox de o Criterio

@sample
TrocaCombo( .F. )

@author Jackson Machado
@since 22/03/2013
/*/
//---------------------------------------------------------------------
Static Function TrocaCombo( lVisual )

cTipo := Alltrim( Str( oCriterio:nAt ) )
aCbx1 := MDT851COM( cTipo )
cCbx1 := Space( If ( AliasInDic( "TG2" ),Len( TG2->TG2_DESCRI ),40 ) )

oCbx1:Refresh()

oPanel21:Refresh()

@ 005,150 ComboBox oCbx1 Var cCbx1 Items aCbx1 Size 140, 65 Of oPanel21 Pixel When lVisual

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

	Local aRotina := {	{ STR0023 , "AxPesqui" , 0 , 1 } , ; //"Pesquisar"
	                    { STR0024 , "MDT851PRO" , 0 , 2 } , ; //"Visualizar"
	                    { STR0025 , "MDT851PRO" , 0 , 3 } , ; //"Incluir"
	                    { STR0026 , "MDT851PRO" , 0 , 4 } , ; //"Alterar"
	                    { STR0027 , "MDT851PRO" , 0 , 5 , 3 } } //"Excluir"

Return aRotina


//---------------------------------------------------------------------
/*/{Protheus.doc} fValQt851
Validação do campo de questionário.

@param string cQt: indica o código do questionário para validar.
@author André Felipe Joriatti
@since 07/03/2013
@version MP11
@return lRet: conforme validação.
/*/
//---------------------------------------------------------------------

Static Function fValQt851( cQt )

	Local lRet := .F.

	If !Empty( cQt )
		lRet := ExistCpo( "TJ2",cQt ) .And. !Empty( cQt )
		If lRet
			oGetQt:Disable()
		EndIf
	Else
		lRet := .T.
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fValPg851
Validação de pergunta/questão do questionário.

@param string cQt: indica o questionário relacionado.
@param string cPg: indica a pergunta para validação.
@author André Felipe Joriatti
@since 07/03/2013
@version MP11
@return lRet: conforme validação.
/*/
//---------------------------------------------------------------------

Static Function fValPg851( cQt,cPg )

	Local lRet    := .F.
	Local cTpList := ""

	cQt := PadR( cQt,TAMSX3( "TJ3_QUESTI" )[1] )
	cPg := PadR( cPg,TAMSX3( "TJ3_QUESTA" )[1] )

	If !Empty( cPg )
		lRet := ExistCpo( "TJ3",cQt + cPg ) .And. !Empty( cPg )
		If lRet
			cTpList := NGSEEK( "TJ3",cQt + cPg,1,"TJ3->TJ3_TPLIST" )
			lRet := If( cTpList $ "14",.T.,.F. )
			If !lRet
				MsgStop( STR0049 ) // "As questões da Fórmula devem ser do tipo 'Numérico' ou 'Opção Exclusiva' com peso informado."
			ElseIf cTpList == "1"
				// se for pergunta de multiplas opções ( opção única ) deve ter o peso informado para cada opção
				cCombo := NGSEEK( "TJ3",cQt + cPg,1,"TJ3->TJ3_COMBO" )
				lRet := If ( "*P:" $ cCombo,.T.,.F. )
				If !lRet
					MsgStop( STR0050 ) // "Para perguntas do tipo 'Opção Exclusiva' o peso deve estar informado."
				EndIf
			EndIf
		EndIf
	Else
		lRet := .T.
	EndIf

Return lRet


//---------------------------------------------------------------------
/*/{Protheus.doc} fMngBrwDsp
Gerencia operações com o browse de itens do desempenho (Incluir, Alterar,
Deletar)

@author André Felipe Joriatti
@since 19/06/2013
@return Nil
@version MP11
/*/
//---------------------------------------------------------------------

Static Function fMngBrwDsp( nOpc )

	Local nRg        := 0
	Local nI         := 0
	Local nT         := 0
	Local nCntDp     := 0
	Local nMaior     := 0
	Local cSeqDsp    := ""

	Local nAntes     := 0
	Local nDepois    := 0
	Local nAteAntes  := 0
	Local nDeDepois  := 0

	If nOpc == 1 // confirmar conforme o que estiver no formulário

		If ( cValToChar( nOpDpAtu ) $ "23" ) // Inclusão/Alteração

			If Empty( nAte ) .Or. Empty( cRet )
				ShowHelpDlg( "",{ STR0051 },2,{ STR0052 },2 ) // "Todos os campos devem ser preenchidos." # "Preencha todos os campos"
				Return .F.
			EndIf

		EndIf

		// Valida faixa
		If nDe > nAte
			ShowHelpDlg( "",{ STR0053 },2,{ "" },2 ) // "A opção 'De' não pode ser maior que a opção 'Até'."
			Return .F.
		EndIf

		If nOpDpAtu == 2 // se for uma inclusão

			//-----------------------
			// Valida sobreposição
			//-----------------------
			For nI := 1 To Len( aDeAte )

				For nT := aDeAte[nI][2] To aDeAte[nI][3]
					If nT >= nDe .And. nT <= nAte
						ShowHelpDlg( "",{ STR0054 + aDeAte[nI][1] },2,{ "" },2 ) // "Não pode haver sobreposição de faixas. Sobreposição com o item "
						Return .F.
					EndIf
				Next nT

				For nT := nDe To nAte
					If nT >= aDeAte[nI][2] .And. nT <= aDeAte[nI][3]
						ShowHelpDlg( "",{ STR0055 + aDeAte[nI][1] },2,{ "" },2 ) // "Não pode haver sobreposição de faixas. Sobreposição com o item "
						Return .F.
					EndIf
				Next nT

			Next nI

			cSeqDsp := "000"

			For nI := 1 To Len( aDeAte )
				cSeqDsp := If( aDeAte[nI][1] > cSeqDsp,aDeAte[nI][1],cSeqDsp )
			Next nI

			cSeqDsp := Soma1( cSeqDsp )

			aAdd( aDeAte,{ cSeqDsp,nDe,nAte,cRet } )

		ElseIf nOpDpAtu == 3 // se for alteração

			//------------------------------------------
			// Valida para que não exista sobreposição
			//------------------------------------------
			For nI := 1 To Len( aDeAte )

				If nI != oBrwDeAte:nAt

					For nT := aDeAte[nI][2] To aDeAte[nI][3]
						If nT >= nDe .And. nT <= nAte
							ShowHelpDlg( "",{ STR0056 + aDeAte[nI][1] },2,{ "" },2 ) // "Não pode haver sobreposição de faixas. Sobreposição com o item "
							Return .F.
						EndIf
					Next nT

					For nT := nDe To nAte
						If nT >= aDeAte[nI][2] .And. nT <= aDeAte[nI][3]
							ShowHelpDlg( "",{ STR0057 + aDeAte[nI][1] },2,{ "" },2 ) // "Não pode haver sobreposição de faixas. Sobreposição com o item "
							Return .F.
						EndIf
					Next nT

				EndIf

			Next nI

			// realiza alteração
			nRg := aScan( aDeAte,{ |x| AllTrim( x[1] ) == AllTrim( cItemAtu ) } )

			If nRg != 0
				aDeAte[nRg][2] := nDe
				aDeAte[nRg][3] := nAte
				aDeAte[nRg][4] := cRet
			EndIf

		EndIf

		// desabilita os controles visuais
		nDe  := 0
		nAte := 0
		cRet := Space( 50 )
		oDe:Disable()
		oAte:Disable()
		oRet:Disable()

		// recarrega o browse de desempenho
		fLoadBrw()

	ElseIf nOpc == 2 // incluir novo

		oDe:Enable()
		oAte:Enable()
		oRet:Enable()
		nDe  := 0
		nAte := 0
		cRet := Space( 50 )
		nOpDpAtu := 2

	ElseIf nOpc == 3 // alterar

		If Len( aDeAte ) == 0
			Return Nil
		EndIf

		oDe:Enable()
		oAte:Enable()
		oRet:Enable()
		cItemAtu := aDeAte[oBrwDeAte:nAt][1]
		nDe      := aDeAte[oBrwDeAte:nAt][2]
		nAte     := aDeAte[oBrwDeAte:nAt][3]
		cRet     := aDeAte[oBrwDeAte:nAt][4]
		oBrwDeAte:Disable()
		nOpDpAtu := 3

	ElseIf nOpc == 4 // deletar

		nRg := aScan( aDeAte,{ |x| x[1] == aDeAte[oBrwDeAte:nAt][1] } )
		If nRg != 0
			aDel( aDeAte,nRg )
			aSize( aDeAte,Len( aDeAte ) - 1 )
			fLoadBrw()
		EndIf

	ElseIf nOpc == 5 // cancelar operação atual

		nDe  := 0
		nAte := 0
		cRet := Space( 50 )
		oDe:Disable()
		oAte:Disable()
		oRet:Disable()
		oBrwDeAte:Enable()

	EndIf

Return Nil

//---------------------------------------------------------------------------
/*/{Protheus.doc} fLoadBrw
Carrega browse de Desempenho.

@param boolean lLdAgrv: se for true então se trata do primeiro carregamento
	que será montado a partir de registros da TJ6 relacionados com a memória
	de TG0_CODFOR
@author André Felipe Joriatti
@since 19/06/2013
@return Nil
@version MP11
/*/
//----------------------------------------------------------------------------

Static Function fLoadBrw( lLdAgrv )

	Default lLdAgrv := .F.

	If lLdAgrv
		aDeAte := {}

		DbSelectArea( "TJ6" )
		DbSetOrder( 01 ) // TJ6_FILIAL+TJ6_CODFOR+TJ6_IDFXA
		DbSeek( xFilial( "TJ6" ) + M->TG0_CODFOR )
		While !EoF() .And. TJ6->( TJ6_FILIAL + TJ6_CODFOR ) == xFilial( "TJ6" ) + M->TG0_CODFOR
			aAdd( aDeAte,{ TJ6->TJ6_IDFXA,TJ6->TJ6_ITDE,TJ6->TJ6_ITATE,TJ6->TJ6_RETOR } )
			DbSelectArea( "TJ6" )
			DbSkip()
		End While

	EndIf

	// Ordena conforme a faixa De + Ate
	aSort( aDeAte,,,{ |x,y| x[2] + x[3] < y[2] + y[3] } )

	oBrwDeAte:SetArray( aDeAte )
	oBrwDeAte:Refresh()
	oBrwDeAte:Enable()

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT851VLTPF()
Valid do campo TG0_TPFORM.

@author André Felipe Joriatti
@since 19/06/2013
@return Boolean lRet: sempre true.
@version MP11
/*/
//---------------------------------------------------------------------

Function MDT851VLTPF()

	Local lRet    := .T.

	cMemoFor := ""
	oMemo:Refresh()

	If M->TG0_TPFORM == "2" // Fórmula de Perguntas.
		oBtn9:Disable()
	Else // Fórmula tipo Critério
		aDeAte := { { ,,, } } // Zera os itens de Desempenho que tenham sido cadastrados.
		oBtn9:Enable()
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fChgFold851
Valida troca de folder, só pode direcionar-se para folder de perguntas
e/ou desempenho se tipo da Fórmula for 'Perguntas'

@param integer nNewOption: indica número do folder.
@author André Felipe Joriatti
@since 19/06/2013
@version MP11
@return lRet: conforme validação.
/*/
//---------------------------------------------------------------------

Static Function fChgFold851( nNewOption )

	Local lRet := .T.

	// Folder de Perguntas e Desempenho respectivamente
	If nNewOption == 4 .Or. nNewOption == 5
		If M->TG0_TPFORM == "1"
			lRet := .F.
			ShowHelpDlg( "",{ STR0058 },2,{ "" },2 ) // "Para habilitar os folders de Perguntas e Desempenho, a Fórmula deve ser do tipo 'Pergunta'."
		EndIf
	EndIf

Return lRet