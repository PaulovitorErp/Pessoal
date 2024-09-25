#INCLUDE "MDTA181.ch"
#INCLUDE "Protheus.CH"

//Define posicoes do array de tabelas
#DEFINE _nPosTab 1
#DEFINE _nPosNom 2
#DEFINE _nPosCod 3
#DEFINE _nPosTab2 4
#DEFINE _nPosCps 5
#DEFINE _nPosCps2 6
#DEFINE _nPosVld 7

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA181
Rotina para vinculos do Risco

@return

@sample
MDTA181()

@author Jackson Machado
@since 26/04/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDTA181()

	//----------------------------------------------
	// Guarda conteudo e declara variaveis padroes
	//----------------------------------------------
	Local aNGBEGINPRM := NGBEGINPRM()

	If !NGCADICBASE( "TAF_CODAMB", "A", "TAF", .F. )
		NGINCOMPDIC( "UPDMDTA1" , "TPTZE6" )
	Else
		//Variaveis padroes
		Private aRotina   	:= MenuDef()
		Private cCadastro 	:= ""
		Private lSigaMdtPs	:= SuperGetMv("MV_MDTPS",.F.,"N") == "S"
		Private cCliMdtPs	:= ""

		//Monta o Browse
		fBrowse( .T. )
	EndIf

	//----------------------------------------
	// Retorna conteudo de variaveis padroes
	//----------------------------------------
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
@since 26/04/2014
/*/
//---------------------------------------------------------------------
Static Function MenuDef( lSigaMdtPs, lInclui )

	Local aRotina :={}

	//Define os parametros
	Default lSigaMdtPs	:= SuperGetMv("MV_MDTPS",.F.,"N") == "S"
	Default lInclui		:= .F.

	If lSigaMdtPs//Caso prestador de servico
		aAdd( aRotina , { STR0001 , "AxPesqui"	, 0 , 1 } ) //"Pesquisar"
		aAdd( aRotina , { STR0002 , "NGCAD01"	, 0 , 2 } ) //"Visualizar"
		aAdd( aRotina , { STR0003 , "MDT181CLI"	, 0 , 4 } ) //"Riscos"
	Else
		If lInclui
			aAdd( aRotina , { STR0001 ,   "AxPesqui"	, 0 , 1} ) //"Pesquisar"
			aAdd( aRotina , { STR0002 ,   "NGCAD01"		, 0 , 2} ) //"Visualizar"
			aAdd( aRotina , { STR0007 ,   "NGCAD01"		, 0 , 3} ) //"Incluir"
			aAdd( aRotina , { STR0008 ,   "NGCAD01"		, 0 , 4} ) //"Alterar"
			aAdd( aRotina , { STR0009 ,   "NGCAD01"		, 0 , 5, 3 } ) //"Excluir"
		Else
			aAdd( aRotina , { STR0001 , "AxPesqui"	, 0 , 1 } ) //"Pesquisar"
			aAdd( aRotina , { STR0002 , "NGCAD01" 	, 0 , 2 } ) //"Visualizar"
			aAdd( aRotina , { STR0004 , "MDT181REL"	, 0 , 4 } ) //"Relacionamentos"
		EndIf
	EndIf

Return aRotina
//---------------------------------------------------------------------
/*/{Protheus.doc} fBrowse
Montagem padrao de Browse

@return Nil

@param lPrimeiro Logico Indica se deve monta o Broese de prestador

@sample
fBrowse()

@author Jackson Machado
@since 26/04/2014
/*/
//---------------------------------------------------------------------
Static Function fBrowse( lPrimeiro )

	//Definicoes basicas
	Local cAlias		:= "TN0"
	Local cFiltro		:= ""

	Default lPrimeiro	:= .F.//Caso nao seja passado parametro, indica ser a primeira montagem

	cCadastro 	:= STR0005 //"Relacionamento de Riscos"

	If lSigaMdtPs//Caso prestador de servico
		If lPrimeiro//Quando eh primeira montagem limpa o filtro e troca o alias
			cAlias		:= "SA1"
			cFiltro	:= ""
			cCadastro 	:= STR0006 //"Clientes"
		Else
			//Quando segunda montagem adiciona o Filtro na Tabela de Riscos
			cFiltro	:= "TN0->TN0_CLIENT+TN0->TN0_LOJA = '" + cCliMdtPs + "'"
		EndIf
	EndIf

	//Enderacao a funcao de browse
	dbSelectArea( cAlias )
	dbSetOrder( 1 )
	If !Empty( cFiltro )//Caso tenha o filtro, executa
		Set Filter To &( cFiltro )
	EndIf

	mBrowse( 6 , 1 , 22 , 75 , cAlias )//Monta o Browse

	//Retorna a tabela ao estado original
	dbSelectArea( cAlias )
	Set Filter To

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT181CLI
Faz a montagem do Browse de acordo com o Prestador de Serviço

@return Nil

@sample
MDT181CLI()

@author Jackson Machado
@since 26/04/2014
/*/
//---------------------------------------------------------------------
Function MDT181CLI()

    Local aRotOld	:= aClone( aRotina )//Salva o aRotina atual

    aRotina			:= MenuDef( .F. )//Alimenta aRotina com as novas opcoes

	cCliMdtPs		:= SA1->A1_COD + SA1->A1_LOJA//Salva o cliente atual

	fBrowse()//Monta o Browse de acordo com os Riscos do Cliente

	aRotina			:= aClone( aRotOld )//Retorna o aRotina

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT181REL
Montagem da tela padrao

@return Nil

@sample
MDT181REL()

@author Jackson Machado
@since 26/04/2014
/*/
//---------------------------------------------------------------------
Function MDT181REL()

	//Variaveis a serem utilizadas para montagem da tela
	Local nReg		:= TN0->( Recno() )
	Local nTabelas	:= 0
	Local lOk		:= .F.
	Local aNao		:= {}
	Local aChoice	:= {}
	Local aColor	:= NGCOLOR()
	Local aRotOld	:= aClone( aRotina )//Salva o aRotina
	Local aArea		:= GetArea()//Salva a area de trabalho atual

	Local cOldFilTO4 := TO4->( dbFilter() )

	//Variaveis de tamanho de tela
	Local lEnchBar	:= .T. // Indica se a janela de diálogo possuirá enchoicebar
	Local lPadrao	:= .F. // Indica se a janela deve respeitar as medidas padrões do Protheus (.T.) ou usar o máximo disponível (.F.)
	Local nMinY		:= 430 // Altura mínima da janela
	Local aSize 	:= MsAdvSize( lEnchBar , lPadrao , nMinY )
	Local aObjects := {}
	Local aInfo 	:= {}
	Local aPosObj 	:= {}

	//Define variaveis dos folders
	Local nContFol	:= 0
	Local aTitles	:= {}
	Local aPages	:= {}

	//Define os Objetos
	Local oDialog
	Local oPnlPai, oPnlTop, oPnlBtn
	Local oEnchoice

	lSigaMdtPs	:= If( Type("lSigaMdtPs") <> "L", SuperGetMv("MV_MDTPS",.F.,"N") == "S", lSigaMdtPs )

	Private aTROCAF3	:= {}

	//Define array de relacionamentos como private para utilizações externas (MDTA265) - Não Alterar
	Private aRelacio		:= {}
	Private cTipEPC		:= SuperGetMv( "MV_NG2UEPC" , .F. , "1" )
	Private lTipEpc		:= NGCADICBASE( "TO9_OPCEPC" , "A" , "TO9" , .F. )

	//Define o folder como private para utilizações externas (MDTA265) - Não Alterar
	Private oFolder

	//Define variavel pardao que recebera o valor do código do Risco e Agente
	Private cRiscoRel	:= TN0->TN0_NUMRIS
	Private cAgentRel	:= TN0->TN0_AGENTE

	cCadastro 	:= STR0005 //"Relacionamento de Riscos"

	//Adequação do Plano de Ação.
	SG90PLACAO()

	//Define um novo aRotina padrao para nao ocorrer erro
	aRotina 	:=	MenuDef( , .T. )

	aRelacio 	:= MDT181RELAC()

	If lTipEpc .And. cTipEPC <> "1"
		// Verifica se o conteudo do parametro eh diferente de 1 e faz o filtro
		dbSelectArea("TO4")
		Set Filter To xFILIAL("TO4") == TO4->TO4_FILIAL .AND. TO4->TO4_TIPCTR == '2'
	EndIf

	//Valida se todas as tabelas relacionais existem, caso nao exista, deleta do array
	For nTabelas := Len( aRelacio ) To 1 Step -1
		If !AliasInDic( aRelacio[ nTabelas , _nPosTab ] )
			aDel( aRelacio , nTabelas )
			aSize( aRelacio , Len( aRelacio ) - 1 )
		EndIf
	Next nTabelas

	//Define modo de alteracao para a Tabela
	aRotSetOpc( "TN0" , @nReg , 4 )
	RegToMemory( "TN0" , .F. )
	INCLUI := .F.
	ALTERA := .T.

	aChoice := NGCAMPNSX3( "TN0" , aNao )

	//Definicoes de tamanho de tela
	aAdd( aObjects, { 100, 100, .T., .T. } )
	aAdd( aObjects, { 315,  70, .T., .T. } )
	aInfo   := { aSize[ 1 ] , aSize[ 2 ] , aSize[ 3 ] , aSize[ 4 ] , 3 , 3 }
	aPosObj := MsObjSize( aInfo , aObjects , .F. )

	//Define os valores dos folders
	For nContFol := 1 To Len( aRelacio )
		aAdd( aTitles , aRelacio[ nContFol , _nPosNom ] )
		aAdd( aPages  , "Header " + cValToChar( nContFol ) )
		&( "aCols" + cValToChar( nContFol ) ) := {}
		&( "aHeader" + cValToChar( nContFol ) ) := {}
		&( "oGetDad" + cValToChar( nContFol ) ) := Nil
	Next nContFol

	//Realiza a busca das informacoes dos aCols
	Processa( { | lEnd | fBusca( aRelacio ) } , STR0018 ) //"Carregando Informações"

	//Monta a Tela
	Define MsDialog oDialog Title OemToAnsi( cCadastro ) From aSize[ 7 ] , 0 To aSize[ 6 ] , aSize[ 5 ] Of oMainWnd Pixel

		//Panel criado para correta disposicao da tela
		oPnlPai := TPanel():New( , , , oDialog , , , , , , , , .F. , .F. )
			oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

			//Painel - Parte Superior ( Cabeçalho )
			oPnlTop := TPanel():New( , , , oPnlPai , , , , , , , aSize[ 6 ] / 6 , .F. , .F. )
		   		oPnlTop:Align := CONTROL_ALIGN_TOP
	            //Monta a Enchoice de Riscos
				oEnchoice:= MsMGet():New( "TN0" , TN0->( Recno() ) , 2 , , , , aChoice , { 12 , 0 , aSize[ 6 ] / 2 , aSize[ 5 ] / 2 } , , , , , , oPnlTop )
					oEnchoice:oBox:Align := CONTROL_ALIGN_ALLCLIENT

			//Painel - Parte Intermediária ( Botão de Importação )
			oPnlBtn := TPanel():New( , , , oPnlPai , , , , , , , 15 , .F. , .F. )
		   		oPnlBtn:Align := CONTROL_ALIGN_TOP
			    //Monta o Botão de Relacionamentos
				TButton():New( 2 , 5 , STR0019 , oPnlBtn , { | | fButton( oFolder , aRelacio ) } , 49 , 12 , , /*oFont*/ , , .T. , , , , /* bWhen*/ , , )	 //"Relacionamento"

			//Rodapé indicativo
			oPnlRod := TPanel():New( , , , oPnlPai , , , , , aColor[ 2 ] , , 10 , .F. , .F. )
		   		oPnlRod:Align := CONTROL_ALIGN_BOTTOM
		   		//Monta o Texto indicativo do Rodapé
		   		TSay():New( 2 , 4 , { | | OemtoAnsi( STR0020 ) } , oPnlRod , , , .F. , .F. , .F. , .T. , aColor[ 1 ] , , 600 , 008 ) //"Informe os relacionamentos necessário. Caso deseje selecionar multipos, utilize a opção 'Relacionamento' no painel acima que irá se comportar conforme aba (Folder) posicionado."

			//Redefine as variaveis para montar as GetDados corretamente
			INCLUI := .F.
			ALTERA := .T.

			//Folder - Parte Inferior
			oFolder := TFolder():New( 00 , 00 , aTitles , aPages , oPnlPai , , , , .F. , .F. , 1000 , 1000 , )
				oFolder:Align 		:= CONTROL_ALIGN_ALLCLIENT
				oFolder:bChange	:= { | | fChangeFol( oFolder , aRelacio ) }
				//Realiza a montagem das abas dos folders
				For nContFol := 1 To Len( aRelacio )
					cTab := aRelacio[ nContFol , _nPosTab ]
					//Monta a GetDados de acordo com o Folder
					dbSelectArea( cTab )
					PutFileInEof( cTab )
					&( "oGetDad" + cValToChar( nContFol ) )  := MsNewGetDados():New( 0 , 0 , 1000 , 1000 , IIF( !INCLUI .and. !ALTERA , 0 , GD_INSERT+GD_UPDATE+GD_DELETE ) , ;
																	{ | | fLinhaOK( oFolder , aRelacio ) } , { | | .T. } , , , , 9999 , , , , oFolder:aDialogs[ nContFol ] , ;
																	&( "aHeader" + cValToChar( nContFol ) ) , &( "aCols" + cValToChar( nContFol ) ) )
						&( "oGetDad" + cValToChar( nContFol ) ):oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
						&( "oGetDad" + cValToChar( nContFol ) ):oBrowse:Refresh()

				Next nContFol

	//Ativacao do Dialog
	Activate MsDialog oDialog Centered On Init EnchoiceBar( oDialog , { | | lOk := .T. , If( fTudoOk( aRelacio ) , oDialog:End() , lOk := .F. ) } , { | | lOk := .F. , oDialog:End() } )

	If lOk//Caso confirmacao da tela, realiza gravacao dos dadods
		Begin Transaction

		Processa( { | lEnd | fGrava( aRelacio ) }, STR0021 ) //"Gravando Informações"

		//-----------------------------------------------------------------
		// Realiza a integração das informações do evento S-2240 ao Governo
		//-----------------------------------------------------------------
		If FindFunction( 'MdtEsoFun' )
			MdtEsoFun()
		EndIf

		End Transaction
	EndIf

	If !Empty( cOldFilTO4 )
		dbSelectArea( "TO4" )
		Set Filter To &( cOldFilTO4 )
	EndIf

	//Retorna o aRotina
	aRotina := aClone( aRotOld )

	//Retorna a Area de Trabalho
	RestArea( aArea )

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fBusca
Monta os arrays de aCols e aHeader

@return Nil

@param aRelacio - Array contendo os relacionamentos ( Obrigatório )

@sample
fBusca( aRelacio )

@author Jackson Machado
@since 26/04/2014
/*/
//---------------------------------------------------------------------
Static Function fBusca( aRelacio )

	//Variaveis basicas
	Local nCont		:= 0
	Local cTab 		:= ""
	Local cTab2		:= ""

	//Variaveis para montagem do aCols e aHeader
	Local nInd		:= 0
	Local cKeyGet	:= ""
	Local cWhileGet	:= ""
	Local aNoFields	:= {}
	Local nReg      := 0

	//Estrutura para busca padrao
	For nCont := 1 To Len( aRelacio )//Percorre relacionamentos

		IncProc( aRelacio[ nCont , _nPosNom ] )//Define incremento da barra de processamento

		//Zera o aCols e aHeader ( Genéricos )
		aCols := {}
		aHeader := {}

		cTab  := aRelacio[ nCont , _nPosTab ]//Salva a Tabela
		cTab2 := aRelacio[ nCont , _nPosTab2 ]//Salva a Tabela

		// Define os campos que nao apareceram da GetDados
		aAdd( aNoFields , PrefixoCPO( cTab ) + "_NUMRIS" )
		aAdd( aNoFields , PrefixoCPO( cTab ) + "_NOMAGE" )
		aAdd( aNoFields , PrefixoCPO( cTab ) + "_NOMRIS" )
		aAdd( aNoFields , PrefixoCPO( cTab ) + "_FILIAL" )
		aAdd( aNoFields , PrefixoCPO( cTab ) + "_AGENTE" )
		aAdd( aNoFields , PrefixoCPO( cTab ) + "_USERGI" )
		aAdd( aNoFields , PrefixoCPO( cTab ) + "_OPCEPC" )

		//Estrutura padrao de repeticao da tabela
		cWhileGet:= cTab + "->" + PrefixoCPO( cTab ) + "_FILIAL == '" + xFilial( cTab ) + "' .AND. " + ;
						cTab + "->" + PrefixoCPO( cTab ) + "_NUMRIS == '" + cRiscoRel + "'"

		If lSigaMdtPs//Caso seja prestador
			//Define que os campos de cliente e loja nao iram aparecer na GetDados
			aAdd( aNoFields , PrefixoCPO( cTab ) + "_CLIENT" )
			aAdd( aNoFields , PrefixoCPO( cTab ) + "_LOJA" )

			//Altera Indice, Chave de Pesquisa e Repeticao padrao da Tabela
			If ( nInd := NGRETORDEM( cTab , PrefixoCPO( cTab ) + "_FILIAL+" + PrefixoCPO( cTab ) + "_CLIENT+" + PrefixoCPO( cTab ) + "_LOJA+" + PrefixoCPO( cTab ) + "_NUMRIS" , .F. ) ) == 0
				nInd		:= 2
			EndIf
			cKeyGet		:= "cCliMdtPs + cRiscoRel"
			cWhileGet	+= cTab + "->" + PrefixoCPO( cTab ) + "_CLIENT+" + cTab + "->" + PrefixoCPO( cTab ) + "_LOJA = '" + cCliMdtPs + "'"
		Else
			//Define Indice e Chave de Pesquisa
			If ( nInd := NGRETORDEM( cTab , PrefixoCPO( cTab ) + "_FILIAL+" + PrefixoCPO( cTab ) + "_NUMRIS" , .F. ) ) == 0
				nInd		:= 1
			EndIf
			cKeyGet		:= "cRiscoRel"
		EndIf

		//Caso seja EPC, verifica os bens e medidas em separado
		If cTab == "TO9" .And. lTipEpc
				If cTab2 == "ST9"
					cKeyGet		+= "+'1'"
					cWhileGet	+= " .AND. " + cTab + "->" + PrefixoCPO( cTab ) + "_OPCEPC == '1'"
				Else
					cKeyGet		+= "+'2'"
					cWhileGet	+= " .AND. " + cTab + "->" + PrefixoCPO( cTab ) + "_OPCEPC == '2'"
				EndIf
			//EndIf
		EndIf

		//Realiza a montagem do aCols e aHeader
		dbSelectArea( cTab )
		dbSetOrder( nInd )
		FillGetDados( 4 , cTab , nInd , cKeyGet , { | | } , { | | .T. } , aNoFields , , , , ;
						{ | | NGMontaaCols( cTab , &cKeyGet , cWhileGet ) } )

		//Na tabela de exames, retira o espaço no conteúdo do campo TN2_TIPEXA, para trazer as decrições.
		If cTab == "TN2"
			For nReg := 1 To Len(aCols)
				aCols[nReg,5] := Alltrim(aCols[nReg,5])
			Next nReg
		EndIf

		//Salva o aCols e aHeader ( Genérico ) no aCols e aHeader correspondente
		&( "aCols" + cValToChar( nCont ) )		:= aClone( aCols )
		&( "aHeader" + cValToChar( nCont ) )	:= aClone( aHeader )

	Next nCont

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fGrava
Grava as informacoes no banco de dados

@return Nil

@param aRelacio - Array contendo os relacionamentos ( Obrigatório )
@param lDeletar - Indica se e exclusao

@sample
fGrava( aRelacio )

@author Jackson Machado
@since 26/04/2014
/*/
//---------------------------------------------------------------------
Static Function fGrava( aRelacio , lDeletar )

	//Variaveis auxiliares
	Local lRet			:= .T.
	Local j				:= 0
	Local nPos 			:= 0
	Local nGrav 		:= 0
	Local nCont			:= 0
	Local nCodigo		:= 0
	Local nPosDel		:= 0
	Local nIdx			:= 0
	Local cTab			:= ""
	Local cTab2			:= ""
	Local cSeek			:= ""
	Local cSeek2		:= ""
	Local cWhile		:= ""
	Local aColsGrava	:= {}
	Local aHeadGrava	:= {}

	Default lDeletar	:= .F.//Define padrao como nao Exclusao

	For nCont := 1 To Len( aRelacio )//Percorre relacionamentos

		IncProc( aRelacio[ nCont , _nPosNom ] )//Define incremento da barra de processamento

		//Salva tabela e posicao do código do array de relacionamento
		cTab			:= aRelacio[ nCont , _nPosTab ]
		cTab2 		:= aRelacio[ nCont , _nPosTab2 ]
		cCodigo		:= aRelacio[ nCont , _nPosCod ]
		cWhile 		:= cTab + "->" + PrefixoCPO( cTab ) + "_FILIAL == '" + xFilial( cTab ) + "' .AND. " + ;
						cTab + "->" + PrefixoCPO( cTab ) + "_NUMRIS == '" + cRiscoRel + "'"
		If lSigaMdtPs
			cWhile	+= cTab + "->" + PrefixoCPO( cTab ) + "_CLIENT+" + cTab + "->" + PrefixoCPO( cTab ) + "_LOJA = '" + cCliMdtPs + "'"
		EndIf

		If lSigaMdtPs//Caso prestador
			//Altera indice e chave de pesquisa
			If ( nIdx := NGRETORDEM( cTab , PrefixoCPO( cTab ) + "_FILIAL+" + PrefixoCPO( cTab ) + "_CLIENT+" + PrefixoCPO( cTab ) + "_LOJA+" + PrefixoCPO( cTab ) + "_NUMRIS" , .F. ) ) == 0
				nIdx		:= 2
			EndIf
			cSeek	:= cCliMdtPs + cRiscoRel
		Else
			//Define indice e chave de pesquisa padrao
			If ( nIdx := NGRETORDEM( cTab , PrefixoCPO( cTab ) + "_FILIAL+" + PrefixoCPO( cTab ) + "_NUMRIS" , .F. ) ) == 0
				nIdx		:= 1
			EndIf
			cSeek	:= cRiscoRel
		EndIf

		//Salva aCols e aHeader correspondente
		aColsGrava	:= aClone( &( "aCols" + cValToChar( nCont ) ) )
		aHeadGrava	:= aClone( &( "aHeader" + cValToChar( nCont ) ) )

		//Procura a posicao do código
		nCodigo		:= aScan( aHeadGrava , { | x | AllTrim( Upper( x[ 2 ] ) ) == cCodigo } )

		//Salva a posicao correspondente a indicacao de deletados
		nPosDel		:= Len( aHeadGrava ) + 1

		If nCodigo > 0//Caso encontre a posicao de codigo
			If !lDeletar//Caso nao seja para deletar
				//Coloca os deletados por primeiro
				aSORT( aColsGrava , , , { | x , y | x[ nPosDel ] .And. !y[ nPosDel ] } )

				//Define segunda pesquisa
				cSeek2 := If( cTab == "TO9" .And. lTipEpc , If( cTab2 == "ST9" , "1" , "2" ), "" )

				//Posiciona na tabela e percorre o aCols
				dbSelectArea( cTab )
				dbSetOrder( nIdx )
				For nGrav := 1 To Len( aColsGrava )
					If !aColsGrava[ nGrav , nPosDel ] .and. !Empty( aColsGrava[ nGrav , nCodigo ] ) //Caso nao esteja deletada a linha e campo codigo esteja preenchido
						If dbSeek( xFilial( cTab ) + cSeek + cSeek2 + aColsGrava[ nGrav , nCodigo ] ) //Verifica se ja existe a informacao na tabela
							RecLock( cTab , .F. )
						Else
							RecLock( cTab , .T. )
						EndIf
						For j := 1 to FCount()//Percorre todos os campos da tabela gravando as informacoes, caso necessaria inclusao específica, feita condicao via If/ElseIf
							If "_FILIAL" $ Upper( FieldName( j ) )
								FieldPut( j , xFilial( cTab ) )
							ElseIf "_NUMRIS" $ Upper( FieldName( j ) )
								FieldPut( j , cRiscoRel )
							ElseIf "_AGENTE" $ Upper( FieldName( j ) )
								FieldPut( j , cAgentRel )
							ElseIf "_CLIENT" $ Upper( FieldName( j ) )
								FieldPut( j , SA1->A1_COD )
							ElseIf "_LOJA" $ Upper( FieldName( j ) )
								FieldPut( j , SA1->A1_LOJA )
							ElseIf "TO9_OPCEPC" $ Upper( FieldName( j ) )
								FieldPut( j , cSeek2 )
							ElseIf ( nPos := aScan( aHeadGrava , { | x | AllTrim( Upper( x[ 2 ] ) ) == AllTrim( Upper( FieldName( j ) ) ) } ) ) > 0//Caso posicao do campo esteja no aHeader
								FieldPut( j , aColsGrava[ nGrav , nPos ] )
							Endif
						Next j
						( cTab )->( MsUnLock() )
					Else
						If dbSeek( xFilial( cTab ) + cSeek + cSeek2  + aColsGrava[ nGrav , nCodigo ] )//Caso campo esteja deletado e exista na tabela, deleta
							RecLock( cTab , .F. )
							( cTab )->( dbDelete() )
							( cTab )->( MsUnLock() )
						EndIf
					EndIf
				Next nGrav
			EndIf

			//Verifica toda a tabela, para que delete os registros caso este nao estejam no aCols ou seja 'exclusao'
			dbSelectArea( cTab )
			dbSetOrder( nIdx )
			dbSeek( xFilial( cTab ) + cSeek2 + cSeek )
			While ( cTab )->( !Eof() ) .and. &( cWhile )
				If lDeletar .Or. aScan( aColsGrava , { | x | x[ nCodigo ] == &( cCodigo ) .AND. !x[ Len( x ) ] } ) == 0
					RecLock( cTab , .F. )
					( cTab )->( dbDelete() )
					( cTab )->( MsUnLock() )
				Endif
				dbSelectArea( cTab )
				( cTab )->( dbSkip() )
			End
		EndIf
	Next nCont

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fLinhaOk
Validacao de Linha padrao das GetDados

@return - Lógico - Indica se esta tudo correto na linha

@param oFolder	- Objeto do Folder ( Obrigatório )
@param aRelacio - Array contendo os relacionamentos ( Obrigatório )
@parma lFim		- Indica se eh chamado pelo TudoOk
@param nPosic   - Posicao de Relacionamento a ser validado

@sample
fLinhaOK( 1 , aRelacio )

@author Jackson Machado
@since 26/04/2014
/*/
//---------------------------------------------------------------------
Static Function fLinhaOK( oFolder , aRelacio , lFim , nPosic )

	//Variaveis auxiliares
	Local f
	Local aColsOk 	:= {}, aHeadOk := {}
	Local nPosCod 	:= 1, nAt := 1, nPosSec := 0
	Local nCols, nHead
	Local cTabela

	Default lFim 	:= .F.//Define fim como .F.
	Default nPosic	:= oFolder:nOption

	//Salva o aCols e aHeader de acordo com a posicao, o nAt da GetDados posicionada e o código de acordo com sua posicao
	cTabela	:= aRelacio[ nPosic , _nPosTab ]
	aColsOk	:= aClone( &( "oGetDad" + cValToChar( nPosic ) ):aCols )
	aHeadOk	:= aClone( &( "aHeader" + cValToChar( nPosic ) ) )
	nAt			:= &( "oGetDad" + cValToChar( nPosic ) ):nAt
	nPosCod	:= aScan( aHeadOk , { | x | AllTrim( Upper( x[ 2 ] ) ) == aRelacio[ nPosic , _nPosCod ] } )

	//Percorre aCols
	For f:= 1 to Len( aColsOk )
		If !aColsOk[ f , Len( aColsOk[ f ] ) ]

			If lFim .or. f == nAt//Caso seja final ou linha atual

				//Verifica se os campos obrigatórios estão preenchidos
				If Empty( aColsOk[ f , nPosCod ] ) .And. If( lFim , Len( aColsOk ) <> 1 , .T. )
					//Mostra mensagem de Help
					Help( 1 , " " , "OBRIGAT2" , , aHeadOk[ nPosCod , 1 ] , 3 , 0 )
					Return .F.
				Endif

				If cTabela == "TN2"//Define as validações dos campos obrigatórios da faixa periódica
					nPosSec := aScan( aHeadOk , { | x | AllTrim( Upper( x[ 2 ] ) ) == "TN2_FAIXA" } )
					If nPosSec > 0 .And. Empty( aColsOk[ f , nPosSec ] ) .And. If( lFim , Len( aColsOk ) <> 1 , .T. )
						//Mostra mensagem de Help
						Help( 1 , " " , "OBRIGAT2" , , aHeadOk[ nPosSec , 1 ] , 3 , 0 )
						Return .F.
					EndIf
					nPosSec := aScan( aHeadOk , { | x | AllTrim( Upper( x[ 2 ] ) ) == "TN2_TIPOEX" } )
					If nPosSec > 0 .And. Empty( aColsOk[ f , nPosSec ] ) .And. If( lFim , Len( aColsOk ) <> 1 , .T. )
						//Mostra mensagem de Help
						Help( 1 , " " , "OBRIGAT2" , , aHeadOk[ nPosSec , 1 ] , 3 , 0 )
						Return .F.
					EndIf
				EndIf

				If nPosic == 1 // Risco

					DbSelectArea( 'TO0' )
					DbSetOrder( 1 )
					MsSeek( xFilial( 'TO0' ) + aColsOk[ f, 1 ] )

					If !Empty( TO0->TO0_DTFIM ) .And. TN0->TN0_DTAVAL > TO0->TO0_DTFIM

						//---------------------------------------------------
						// "O risco foi avaliado após a data final do laudo"
						// "Não será possível vincular o risco"
						//---------------------------------------------------
						Help( Nil, Nil, STR0025, Nil, AllTrim( TN0->TN0_NUMRIS ) + ' - ' + STR0039 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0040 + '.' } )
						Return .F.

					EndIf

					If !Empty( TN0->TN0_DTELIM ) .And. TN0->TN0_DTELIM < TO0->TO0_DTINIC

						//---------------------------------------------------
						// "O risco foi eliminado antes do início do laudo"
						// "Não será possível vincular o risco"
						//---------------------------------------------------
						Help( Nil, Nil, STR0025, Nil, AllTrim( TN0->TN0_NUMRIS ) + ' - ' + STR0041 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0040 + '.' } )
						Return .F.

					EndIf

				EndIf

			Endif

			//Verifica se é somente LinhaOk
			If f <> nAt .and. !aColsOk[ nAt , Len( aColsOk[ nAt ] ) ]
				If aColsOk[ f , nPosCod ] == aColsOk[ nAt , nPosCod ]
					//Mostra mensagem de Help
					Help( " " , 1 , "JAEXISTINF" , , aHeadOk[ nPosCod , 1 ] )
					Return .F.
				Endif
			Endif
		Endif
	Next f

	//Posiciona tabelas em fim de arquivo
	PutFileInEof( aRelacio[ nPosic , _nPosTab ] )
	PutFileInEof( aRelacio[ nPosic , _nPosTab2 ] )

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fTudoOk
Validacao final da tela

@return - Lógico - Indica se está tudo correto na tela

@param aRelacio - Array contendo os relacionamentos ( Obrigatório )

@sample
fTudoOk( aRelacio )

@author Jackson Machado
@since 26/04/2014
/*/
//---------------------------------------------------------------------
Static Function fTudoOk( aRelacio )

	//Variaveis auxiliares
	Local nCont
	Local lRet := .T.//Indica o retorno

	For nCont := 1 To Len( aRelacio )//Percorre todos os relacionamentos
		&( "aCols" + cValToChar( nCont ) ) := aClone( &( "oGetDad" + cValToChar( nCont ) ):aCols )
		If !fLinhaOK( , aRelacio , .T. , nCont )//Valida todos os Folders
			//Caso encontre inconsistência retorna
			lRet := .F.
			Exit
		EndIf
	Next nCont

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fButton
Adiciona multiplos no relacionamento

@return Nil

@param oFolder 	- Objeto do Folder ( Obrigatório )
@param aRelacio	- Array de relacionamentos ( Obrigatório )

@sample
fButton( oFolder , aRelacio )

@author Jackson Machado
@since 26/04/2014
/*/
//---------------------------------------------------------------------
Static Function fButton( oFolder , aRelacio )

	Local nCps		:= 0
	Local nFolPos	:= oFolder:nOption
	Local cTab		:= aRelacio[ nFolPos , _nPosTab ]
	Local cTabRel	:= aRelacio[ nFolPos , _nPosTab2 ]
	Local aTam		:= {}
	Local aCampos	:= aClone( aRelacio[ nFolPos , _nPosCps ] )
	Local aArea		:= GetArea()//Salva a Area Atual
	Local aAreaAtu	:= {}
	Local cTipo     := ''
	Local cTitu     := ''
	Local cTipEPI	:= SuperGetMv( "MV_MDTPEPI" )

	//Variaveis para montar TRB
	Local cAliasTRB	:= GetNextAlias()
	Local aDBF, aTRB, aIdx, aDescIdx
	Local nIdx

	//Variaveis da Montagem do MarkBrowse
	Local lOK := .F.
	Local lInverte, lRet

	//Definicoes de Objetos
	Local oDialog
	Local oMark

	//Variaveis Privadas
	Private cMarca	:= GetMark()
	Private oGetVal	:= &( "oGetDad" + cValToChar( nFolPos ) )

	//Variaveis da Pesquisa
	Private cPesquisar := Space( 200 )//Valor a ser pesquisado
	Private cCbxPesq   := ""
	Private aCbxPesq //ComboBox com indices de pesquisa
	Private oBtnPesq, oPesquisar//Botao de Pesquisa e Campo para Pesquisa
	Private oCbxPesq //ComboBox de Pesquisa

	lInverte := .F.

	//Valores e Caracteristicas da TRB
	aDBF		:= {}
	aTRB		:= {}
	aIdx		:= {}
	aDescIdx	:= {}

	aAdd( aDBF , { "OK"      , "C" , 02 , 0 } )
	aAdd( aTRB , { "OK"     , NIL , " "	  	 , })

	//Define os campos
	aAreaAtu := GetArea()
	For nCps := 1 To Len( aCampos )

		aTam  := TamSX3( aCampos[ nCps ] )
		cTipo := GetSx3Cache( aCampos[ nCps ], 'X3_TIPO' )
		cTitu := AllTrim( Posicione( 'SX3' , 2 , aCampos[ nCps ] , 'X3Titulo()' ) )
		aAdd( aDBF , { aCampos[ nCps ] , cTipo	, aTam[ 1 ]	, aTam[ 2 ]	} )
		aAdd( aTRB , { aCampos[ nCps ] , NIL 	, cTitu	    ,			} )

	Next nCps

	MDTA232IDX( @aIdx , @aDescIdx , aCampos ) //Realiza a Geracao dos Indices

	aAdd( aIdx , "OK" )
	RestArea( aAreaAtu )

	oTempTRB := FWTemporaryTable():New( cAliasTRB, aDBF )
	For nIdx := 1 To Len( aIdx )
		oTempTRB:AddIndex( RETASC( cValToChar( nIdx ) , 1 , .T. ), StrTokArr( aIdx[nIdx] , "+" ) )
	Next nIdx
	oTempTRB:Create()

	If cTabRel == "SB1"
		dbSelectArea( cTabRel )
		Set Filter To SB1->B1_TIPO == cTipEPI
	EndIf

	dbSelectArea( cTab )

	Processa( { | lEnd | fBuscaReg( cTabRel , cAliasTRB , nFolPos , aCampos , aRelacio[ nFolPos , _nPosCod ] , aRelacio[ nFolPos , _nPosVld ] ) } , STR0022 , STR0023 ) //"Buscando Registros"###"Aguarde"

	dbSelectArea( cAliasTRB )
	dbGoTop()
	If ( cAliasTRB )->(Reccount()) <= 0
		oTempTRB:Delete()
		RestArea( aArea )
		lRefresh := .T.
		Msgstop( STR0024 , STR0025 ) //"Não existem registros cadastrados"###"ATENÇÃO"
		Return .T.
	Endif

	DEFINE MSDIALOG oDialog TITLE OemToAnsi( aRelacio[ nFolPos , _nPosNom ] ) From 64,160 To 580,736 OF oMainWnd Pixel

		//Panel criado para correta disposicao da tela
		oPnlPai := TPanel():New( , , , oDialog , , , , , , , , .F. , .F. )
			oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

			//--- DESCRICAO ( TOPO )
			oPanel := TPanel():New( 0 , 0 , , oPnlPai , , .T. , .F. , , , 0 , 55 , .T. , .F. )
				oPanel:Align := CONTROL_ALIGN_TOP

				@ 8,9.6 TO 45,280 OF oPanel PIXEL

				TSay():New( 19 , 12 , { | | OemtoAnsi( STR0026 ) } , oPanel , , , .F. , .F. , .F. , .T. , CLR_BLACK , CLR_WHITE , 200 , 010 ) //"Estes são os registros cadastrados no sistema."
				TSay():New( 29 , 12 , { | | OemtoAnsi( STR0027 ) } , oPanel , , , .F. , .F. , .F. , .T. , CLR_BLACK , CLR_WHITE , 200 , 010 ) //"Selecione aqueles que foram avaliados no risco."

			//--- PESQUISAR
			//Define as opcoes de Pesquisa
			aCbxPesq := aClone( aDescIdx )
			aAdd( aCbxPesq , STR0028 ) //"Marcados"
			cCbxPesq := aCbxPesq[ 1 ]

			oPnlPesq 		:= TPanel():New( 01 , 01 , , oPnlPai , , , , CLR_BLACK , CLR_WHITE , 50 , 30 , .T. , .T. )
				oPnlPesq:Align	:= CONTROL_ALIGN_TOP

					oCbxPesq := TComboBox():New( 002 , 002 , { | u | If( PCount() > 0 , cCbxPesq := u , cCbxPesq ) } , ;
															aCbxPesq , 200 , 08 , oPnlPesq , , { | | } ;
															, , , , .T. , , , , , , , , , "cCbxPesq" )
						oCbxPesq:bChange := { | | fSetIndex( cAliasTRB , aCbxPesq , @cPesquisar , oMark ) }

					oPesquisar := TGet():New( 015 , 002 , { | u | If( PCount() > 0 , cPesquisar := u , cPesquisar ) } , oPnlPesq , 200 , 008 , "" , { | | .T. } , CLR_BLACK , CLR_WHITE , ,;
											.F. , , .T. /*lPixel*/ , , .F. , { | | .T. }/*bWhen*/ , .F. , .F. , , .F. /*lReadOnly*/ , .F. , "" , "cPesquisar" , , , , .F. /*lHasButton*/ )

					oBtnPesq := TButton():New( 002 , 220 , STR0001 , oPnlPesq , { | | fPesqTRB( cAliasTRB , oMark ) } , ;//"Pesquisar" //"Pesquisar"
															70 , 10 , , , .F. , .T. , .F. , , .F. , , , .F. )

			oMark := MsSelect():New( cAliasTRB , "OK" , , aTRB , @lInverte , @cMarca , { 45 , 5 , 254 , 281 }, , , oPnlPai)
				oMark:oBrowse:lHasMark		:= .T.
				oMark:oBrowse:lCanAllMark	:= .T.
				oMark:oBrowse:bAllMark		:= { | | fInverte( cMarca , cAliasTRB , oMark , .T. ) }//Funcao inverte marcadores
				oMark:bMark	   				:= { | | fInverte( cMarca , cAliasTRB , oMark ) }//Funcao inverte marcadores
				oMark:oBrowse:Align			:= CONTROL_ALIGN_ALLCLIENT

	ACTIVATE MSDIALOG oDialog ON INIT EnchoiceBar(oDialog,{|| lOk := .T. ,oDialog:End()},{|| lOk := .F.,oDialog:End()}) CENTERED

	If lOK
		fGravCols( &( "oGetDad" + cValToChar( nFolPos ) ) , cAliasTRB , aCampos , aRelacio[ nFolPos , _nPosCod ] , aRelacio[ nFolPos , _nPosTab ] , aRelacio[ nFolPos , _nPosCps2 ] )//Funcao para copiar planos a GetDados
	Endif

	oTempTRB:Delete()

	RestArea(aArea)

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fSetIndex
Seta o indice para pesquisa

@return

@param cAliasTRB	- Alias do TRB ( Obrigatório )
@param aCbxPesq		- Indices de pesquisa do markbrowse. ( Obrigatório )
@param cPesquisar	- Valor da Pesquisa ( Obrigatório )
@param oMark		- Objeto do MarkBrowse ( Obrigatório )

@author Jackson Machado
@since 26/04/2014
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
	oPesquisar:Refresh()

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fRetInd
Retorna o indice, em numero, do item selecionado no combobox

@return nIndice - Retorna o valor do Indice

@param aIndMrk - Indices de pesquisa do markbrowse. ( Obrigatório )

@author Jackson Machado
@since 26/04/2014
/*/
//---------------------------------------------------------------------
Static Function fRetInd( aIndMrk )

	Local nIndice := aScan( aIndMrk , { | x | AllTrim( x ) == AllTrim( cCbxPesq ) } )

	// Se o indice nao foi encontrado nos indices pre-definidos, apresenta mensagem
	If nIndice == 0
		ShowHelpDlg( STR0025 ,	{ STR0029 } , 1 , ; //"Atenção"###"Índice não encontrado."
									{ STR0030 } , 1 ) //"Contate o administrador do sistema."
		nIndice := 1
	Endif

Return nIndice
//---------------------------------------------------------------------
/*/{Protheus.doc} fBuscaReg
Realiza a busca dos registros para alimentar o TRB

@return Nil

@param cTabela 	- Tabela a ser pesquisada ( Obrigatório )
@param nFolPos	- Posicao do Folder ( Obrigatório )
@param aCampos  - Campos a serem considerados ( Obrigatório )
@param cCodigo  - Campo de codigo a ser validado ( Obrigatório )
@param bValid - Bloco de Código responsável por validação específica para trazer registros no TRB

@sample
fBuscaReg( "TO1" , cTRB , 1 , { "TO1_LAUDO" , "TO1_NOMLAU" } , 000001 , { | | } )

@author Jackson Machado
@since 26/04/2014
/*/
//---------------------------------------------------------------------
Static Function fBuscaReg( cTabela , cAliasTRB , nFolPos , aCampos , cCodigo , bValid )

	Local nCps		:= 0
	Local nPosCod	:= 1
	Local cCampo	:= ""
	Local cCpsVal	:= ""
	Local cCodRel	:= ""
	Local oGet		:= &( "oGetDad" + cValToChar( nFolPos ) )
	Local aColsOK	:= aClone( oGet:aCols )
	Local aHeadOk	:= aClone( oGet:aHeader )

    nPosCod	:= aScan( aHeadOk , { | x | AllTrim( Upper( x[ 2 ] ) ) == cCodigo } )
	cCodRel := aCampos[ 1 ]

	dbSelectArea( cTabela )
	dbSetOrder( 1 )
	If dbSeek( xFilial( cTabela ) )
		While ( cTabela )->( !Eof() ) .And. ( cTabela )->&( PrefixoCPO( cTabela ) + "_FILIAL" ) == xFilial( cTabela )
			If ValType( bValid ) <> "B" .Or. Eval( bValid )
				RegToMemory( cTabela , .F. )
				RecLock( cAliasTRB , .T. )
				(cAliasTRB)->OK := If( aScan( aColsOk , { | x | AllTrim(x[ nPosCod ]) == AllTrim(&( "M->" + cCodRel )) } ) > 0, cMarca , " " )
				For nCps := 1 To Len( aCampos )
					cCampo := aCampos[ nCps ]
					&( cAliasTRB + "->" + cCampo ) := &( "M->" + cCampo )
				Next nCps
				( cAliasTRB )->( MsUnLock() )
			EndIf
			( cTabela )->( dbSkip() )
		End
	EndIf

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fGravCols
Faz as gravações do TRB para o aCols correspondente

@return Nil

@param oGet			- Objeto da GetDados ( Obrigatório )
@param cAliasTRB 	- Alias do TRB ( Obrigatório )
@param aCampos  	- Campos a serem considerados ( Obrigatório )
@param cCodigo  	- Campo de codigo a ser validado ( Obrigatório )
@param aCampos2  	- Campos a serem verificados no aHeader ( Obrigatório )

@sample
fGravCols( oObj , cTRB , { "TO1_LAUDO" , "TO1_NOMLAU" } , 000001 , "TO1" , { "TO0_LAUDO" , "TO0_NOME" } )

@author Jackson Machado
@since 26/04/2014
/*/
//---------------------------------------------------------------------
Static Function fGravCols( oGet , cAliasTRB , aCampos , cCodigo , cTabela , aCampos2 )

	Local nCols, nCps
	Local nPosCod	:= 1
	Local nPosCps	:= 0
	Local cCpsVal	:= ""
	Local cCodRel	:= ""
	Local cFaixa	:= ""
	Local lNoFaixa	:= .F.
	Local aColsOk	:= {}
	Local aHeadOk	:= {}
	Local aColsTp	:= {}

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
	dbGoTop()
	While ( cAliasTRB )->( !Eof() )
		If !Empty( ( cAliasTRB )->OK ) .AND. aScan( aColsOk , {|x| x[ nPosCod ] == &( cAliasTRB + "->" + cCodRel ) } ) == 0
			If cTabela == "TN2"//Caso seja exame valida as necessidades
				If !lNoFaixa .And. Empty( cFaixa )//Busca a faixa
					fBuscaFaixa( @cFaixa , @lNoFaixa )
				EndIf
			EndIf
			aAdd( aColsOk , aClone( aColsTp[ 1 ] ) )
			For nCps := 1 To Len( aCampos )
				nPosCps := aScan( aHeadOk , { | x | Trim( Upper( x[ 2 ] ) ) == aCampos2[ nCps ] } )
				If nPosCps > 0
					aColsOk[ Len( aColsOk ) , nPosCps ] := &( cAliasTRB + "->" + aCampos[ nCps ] )
				EndIf
			Next nCps
			If cTabela == "TN2"//Caso seja exame precisa atribuir o tipo
				nPosCps := aScan( aHeadOk , { | x | Trim( Upper( x[ 2 ] ) ) == "TN2_TIPOEX" } )
				If nPosCps > 0
					aColsOk[ Len( aColsOk ) , nPosCps ] := "11"//Atribui o tipo padrão 'TODOS'
				EndIf
				nPosCps := aScan( aHeadOk , { | x | Trim( Upper( x[ 2 ] ) ) == "TN2_FAIXA" } )
				If nPosCps > 0 .And. !Empty( cFaixa )
					aColsOk[ Len( aColsOk ) , nPosCps ] := cFaixa//Atribui a faixa pre-selecionada
				EndIf
			EndIf
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

@param cMarca 		- Valor da marca do TRB ( Obrigatório )
@param cAliasTRB	- Alias do TRB ( Obrigatório )
@param oMark		- Objeto do MarkBrowse ( Obrigatório )
@param lAll			- Indica se eh AllMark

@sample
fInverte( "E" , "TRB" , oObj )

@author Jackson Machado
@since 26/04/2014
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

@samples fPesqTRB()

@return Sempre verdadeiro

@param cAliasTRB	- Alias do MarkBrowse ( Obrigatório )
@param oMark 		- Objeto do MarkBrowse ( Obrigatório )

@author Jackson Machado
@since 26/04/2014
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
		ApMsgInfo( STR0031 , STR0025 ) //"Valor não encontrado."###"Atenção"
		oPesquisar:SetFocus()
		lRet := .F.
	EndIf

	// Atualiza markbrowse
	oMark:oBrowse:Refresh(.T.)

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fBuscaFaixa
Faz a busca da faixa periódica dos exames

@samples fBuscaFaixa( "" , .F. )

@return Logico Sempre verdadeiro

@param cFaixa Caracter Variavel que vai receber o valor de retorno da faixa
@param lNoFaixa Logico Variavel que indica se deve buscar a faixa

@author Jackson Machado
@since 26/04/2014
/*/
//---------------------------------------------------------------------
Static Function fBuscaFaixa( cFaixa , lNoFaixa )

	Local lOk
	Local oDlgFai
	Local oPnlTop, oPnlAll, oPnlDlg

	cFaixa := Space( Len( TMQ->TMQ_FAIXA ) )

	DEFINE MSDIALOG oDialog TITLE OemToAnsi( STR0015 ) From 64,160 To 320,736 OF oMainWnd Pixel//"Faixa Periódica - Padrão"

		oPnlDlg := TPanel():New( 0 , 0 , , oDlgFai , , .T. , .F. , , , 0 , 0 , .T. , .F. )
			oPnlDlg:Align := CONTROL_ALIGN_ALLCLIENT

			oPnlTop := TPanel():New( 0 , 0 , , oPnlDlg , , .T. , .F. , , , 0 , 55 , .T. , .F. )
				oPnlTop:Align := CONTROL_ALIGN_TOP

				@ 8,9.6 TO 45,280 OF oPnlTop PIXEL

				TSay():New( 19 , 12 , { | | OemtoAnsi( STR0016 ) } , oPnlTop , , , .F. , .F. , .F. , .T. , CLR_BLACK , CLR_WHITE , 200 , 010 ) //"Escolha uma faixa periódica para os exames."
				TSay():New( 29 , 12 , { | | OemtoAnsi( STR0017 ) } , oPnlTop , , , .F. , .F. , .F. , .T. , CLR_BLACK , CLR_WHITE , 200 , 010 ) //"Caso deseje selecionar mais de uma, feche a janela e insira manualmente."

			oPnlAll := TPanel():New( 0 , 0 , , oPnlDlg , , .T. , .F. , , , 0 , 0 , .T. , .F. )
				oPnlAll:Align := CONTROL_ALIGN_ALLCLIENT

				TSay():New( 019 , 012 , { | | OemtoAnsi( STR0015 ) } , oPnlAll , , , .F. , .F. , .F. , .T. , CLR_BLACK , CLR_WHITE , 200 , 010 ) //"Faixa Periodica - Padrao"
				TGet():New( 015 , 080 , { | u | If( PCount() > 0 , cFaixa := u , cFaixa ) } , oPnlAll , 025 , 010 , "" , { | | If( Empty( cFaixa ) , .T. , ExistCpo( "TMQ" , cFaixa ) ) } , CLR_BLACK , CLR_WHITE , ,;
										.F. , , .T. /*lPixel*/ , , .F. , { | | .T. }/*bWhen*/ , .F. , .F. , , .F. /*lReadOnly*/ , .F. , "TMQ" , "cFaixa" , , , , .T. /*lHasButton*/ )

	ACTIVATE MSDIALOG oDialog ON INIT EnchoiceBar(	oDialog , ;
													{ | | lOk := .T. , oDialog:End() } , ;
													{ | | lOk := .F. , oDialog:End() } ) CENTERED

	If lOk
		If Empty( cFaixa )
			lNoFaixa := .T.
		EndIf
	Else
		lNoFaixa	:= .T.
		cFaixa		:= ""//Força a faixa como vazia para evitar lixo ao confirmar
	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fBuscaFaixa
Faz a busca da faixa periódica dos exames

@samples fBuscaFaixa( "" , .F. )

@return Logico Sempre verdadeiro

@param oFolder
@param aRelacio

@author Jackson Machado
@since 21/05/2014
/*/
//---------------------------------------------------------------------
Static Function fChangeFol( oFolder , aRelacio )

	Local nOption := oFolder:nOption
	Local aPropri := aRelacio[ nOption ]
	Local cTabela := aPropri[ 1 ]
	Local cTabRel := aPropri[ 4 ]

	If cTabela == "TO9"
		aTrocaF3 := {}
		aAdd( aTrocaF3, { "TO9_EPC" , If( cTabRel == "ST9" , "ST9MDT" , "TO4" ) } )
	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT181RELAC
Retorna os relacionamentos do Risco

@type function

@source MDTA180.prx

@author Jackson Machado
@since 14/02/2017

@sample MDT181RELAC

@obs Utilizado no MDTA181 e MDTA180, ao alterar as posições, verificar utilização

@return Array, Array contendo os relacionamentos do risco
/*/
//---------------------------------------------------------------------
Function MDT181RELAC()

	Local aRelacio	:= {}
	Local cTipEPC	:= SuperGetMv( "MV_NG2UEPC" , .F. , "1" )
	Local lTipEpc	:= NGCADICBASE( "TO9_OPCEPC" , "A" , "TO9" , .F. )

	//Definicoes de Relacionamento
	Local bVldPla
	Local bVldMDTO4

	//Adequação do Plano de Ação.
	SG90PLACAO()

	//Define a validação do Plano de Ação
	bVldPla := { | | ( cAliasPA )->&( aFieldPA[ 29 ] ) $ "2/3" .And. If( cAliasPA == "TAA" , TAA->TAA_STATUS <> "3" , .T. ) }

	//Define todos os relacionamentos a serem considerados
	//Caso seja necessário definir um novo relacionamento, basta adicionar a posição no array com as seguintes denominacoes
	//	1 - Tabela de Relacionamento
	//	2 - Descrição do Folder
	//	3 - Campo chave da tabela
	//	4 - Tabela Estrangeira
	//	5 - Campos da Tabela Estrangeira a serem considerados
	//	6 - Campos da Tabela de Relacionamento a serem considerados
	aAdd( aRelacio , { "TO1" , STR0010 , "TO1_LAUDO"	, "TO0"		, { "TO0_LAUDO" 	, "TO0_NOME"	} , { "TO1_LAUDO"	, "TO1_NOMLAU"	} ,			} )//Laudos
	aAdd( aRelacio , { "TNX" , STR0011 , "TNX_EPI" 		, "SB1"		, { "B1_COD"  		, "B1_DESC"		} , { "TNX_EPI"		, "TNX_NOMEPI"	} ,			} ) //"EPI"

	If lTipEpc .And. cTipEPC <> "1"

		bVldMDTO4 := { | | TO4->TO4_TIPCTR == "2" }

		If cTipEPC == "2"
			aAdd( aRelacio , { "TO9" , STR0032 , "TO9_EPC"		, "TO4"		, { "TO4_CONTRO" 	, "TO4_NOMCTR"		} , { "TO9_EPC"		, "TO9_NOMEPC"	} , bVldMDTO4			} ) //"EPC (Medida Controle)"
		Else
			aAdd( aRelacio , { "TO9" , STR0012 , "TO9_EPC"		, "ST9"		, { "T9_CODBEM" 	, "T9_NOME"			} , { "TO9_EPC"		, "TO9_NOMEPC"	} , 			} ) //"EPC (Bem)"
			aAdd( aRelacio , { "TO9" , STR0032 , "TO9_EPC"		, "TO4"		, { "TO4_CONTRO" 	, "TO4_NOMCTR"		} , { "TO9_EPC"		, "TO9_NOMEPC"	} , bVldMDTO4			} ) //"EPC (Medida Controle)"
		EndIf
	Else
		aAdd( aRelacio , { "TO9" , STR0012 , "TO9_EPC"		, "ST9"		, { "T9_CODBEM" 	, "T9_NOME"		} , { "TO9_EPC"		, "TO9_NOMEPC"	} , 		} ) //"EPC (Bem)"
	EndIf

	aAdd( aRelacio , { "TNJ" , STR0014 , "TNJ_CODPLA"	, cAliasPA	, { aFieldPA[2] 	, aFieldPA[3]	} , { "TNJ_CODPLA"	, "TNJ_NOMPLA"	} , bVldPla	} ) //"Planos de Ação"
	aAdd( aRelacio , { "TN2" , STR0013 , "TN2_EXAME"	, "TM4"		, { "TM4_EXAME" 	, "TM4_NOMEXA"	} , { "TN2_EXAME"	, "TN2_NOMEXA"	} ,			} ) //"Exames"

Return aRelacio
