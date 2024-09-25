#INCLUDE "MDTA232.ch"
#INCLUDE "Protheus.CH"

//Define posicoes do array de tabelas
#DEFINE _nPosTab 1
#DEFINE _nPosNom 2
#DEFINE _nPosCod 3
#DEFINE _nPosTab2 4
#DEFINE _nPosCps 5
#DEFINE _nPosCps2 6

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA232
Rotina para vinculos do Laudo

@return

@sample
MDTA232()

@author Jackson Machado
@since 18/07/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDTA232()

	//----------------------------------------------
	// Guarda conteudo e declara variaveis padroes
	//----------------------------------------------
	Local aNGBEGINPRM := NGBEGINPRM()

	If !( "TO5_CODFUN" $ NGSEEKDIC( "SX2" , "TO5" , 1 , "X2_UNICO" ) )
	 	NGINCOMPDIC( "UPDMDT87" , "THVZJN" )
	Else
		//Variaveis padroes
		Private aRotina   	:= MenuDef()
		Private cCadastro 	:= ""
		Private lSigaMdtPs	:= If( SuperGetMv("MV_MDTPS",.F.,"N") == "S" , .T. , .F. )
		Private cCliMdtPs	:= ""
		Private cTIPOPL := "SESMT"

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
@since 18/07/2013
/*/
//---------------------------------------------------------------------
Static Function MenuDef( lSigaMdtPs )

	Local aRotina :={}

	//Define os parametros
	Default lSigaMdtPs := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S" , .T. , .F. )

	If lSigaMdtPs//Caso prestador de servico
		aAdd( aRotina , { STR0001 , "AxPesqui"	, 0 , 1 } ) //"Pesquisar"
		aAdd( aRotina , { STR0002 , "NGCAD01"	, 0 , 2 } ) //"Visualizar"
		aAdd( aRotina , { STR0003 , "MDT232CLI"	, 0 , 4 } ) //"Laudos"
	Else
		aAdd( aRotina , { STR0001 , "AxPesqui"	, 0 , 1 } ) //"Pesquisar"
		aAdd( aRotina , { STR0002 , "NGCAD01" 	, 0 , 2 } ) //"Visualizar"
		aAdd( aRotina , { STR0004 , "MDT232REL"	, 0 , 4 } ) //"Relacionamentos"
	EndIf

Return aRotina
//---------------------------------------------------------------------
/*/{Protheus.doc} fBrowse
Montagem padrao de Browse

@return Nil

@param lPrimeiro - Indica se deve monta o Broese de prestador

@sample
fBrowse()

@author Jackson Machado
@since 18/07/2013
/*/
//---------------------------------------------------------------------
Static Function fBrowse( lPrimeiro )

	//Definicoes basicas
	Local cAlias		:= "TO0"
	Local cFiltro		:= ""
	Local bCondBrw := {|| }
	Local cCondBrw := ""

	Default lPrimeiro	:= .F.//Caso nao seja passado parametro, indica ser a primeira montagem

	cCadastro 	:= STR0005 //"Relacionamento de Laudos"

	If lSigaMdtPs//Caso prestador de servico
		If lPrimeiro//Quando eh primeira montagem limpa o filtro e troca o alias
			cAlias		:= "SA1"
			cFiltro	:= ""
			cCadastro 	:= STR0006 //"Clientes"
		Else
			//Quando segunda montagem adiciona o Filtro na Tabela de Laudos
			cFiltro	:= "TO0->TO0_CLIENT+TO0->TO0_LOJA = '" + cCliMdtPs + "'"
		EndIf
	EndIf

	If 	nModulo == 35
		bCondBrw := {|| Empty(TO0->TO0_TIPREL) .Or. TO0->TO0_TIPREL $ "1/2/3/4/5/6/7/8/A/C" }
		cCondBrw := "Empty(TO0->TO0_TIPREL) .Or. TO0->TO0_TIPREL $ '1/2/3/4/5/6/7/8/A/C'"
	EndIf

	//Enderacao a funcao de browse
	dbSelectArea( cAlias )
	dbSetOrder( 1 )
	If !Empty( cFiltro )//Caso tenha o filtro, executa
		Set Filter To &( cFiltro )
	EndIf
	If !Empty(bCondBrw) .And. !Empty(cCondBrw)
		dbSetFilter(bCondBrw,cCondBrw)
	EndIf
	mBrowse( 6 , 1 , 22 , 75 , cAlias )//Monta o Browse

	//Retorna a tabela ao estado original
	dbSelectArea( cAlias )
	Set Filter To

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT232CLI
Faz a montagem do Browse de acordo com o Prestador de Serviço

@return Nil

@sample
MDT232CLI()

@author Jackson Machado
@since 18/07/2013
/*/
//---------------------------------------------------------------------
Function MDT232CLI()

    Local aRotOld	:= aClone( aRotina )//Salva o aRotina atual

    aRotina			:= MenuDef( .F. )//Alimenta aRotina com as novas opcoes

	cCliMdtPs		:= SA1->A1_COD + SA1->A1_LOJA//Salva o cliente atual

	fBrowse()//Monta o Browse de acordo com os Laudos do Cliente

	aRotina			:= aClone( aRotOld )//Retorna o aRotina

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT232REL
Montagem da tela padrao

@return Nil

@sample
MDT232REL()

@author Jackson Machado
@since 18/07/2013
/*/
//---------------------------------------------------------------------
Function MDT232REL()

	//Variaveis a serem utilizadas para montagem da tela
	Local nReg		:= TO0->( Recno() )
	Local nTabelas	:= 0
	Local lOk		:= .F.
	Local lTipRel	:= NGCADICBASE("TO0_TIPREL","A","TO0",.F.)
	Local aNao		:= {}
	Local aChoice	:= {}
	Local aColor	:= NGCOLOR()
	Local aRotOld	:= aClone( aRotina )//Salva o aRotina
	Local aArea	:= GetArea()//Salva a area de trabalho atual

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
	Local oFolder, oEnchoice

	//Definicoes de Relacionamento
	Local aRelacio		:= {}

	//Define variavel pardao que recebera o valor do código do Laudo
	Private cLaudoRel	:= TO0->TO0_LAUDO

	//Variaveis de Tratativa
	Private cTipPE	  := "X"//Indicativo de Módulo para P.E.

	If Empty(TO0->TO0_TIPREL) .Or. ( TO0->TO0_TIPREL == "A")
		cTIPOPL := ""
	ElseIf TO0->TO0_TIPREL $ "9/B"
		cTIPOPL := "SGA"
	Else
		cTIPOPL := "SESMT"
	EndIf

	SG90PLACAO()//Adequação do Plano de Ação.

	//Define um novo aRotina padrao para nao ocorrer erro
	aRotina 	:=	{ { STR0001 ,   "AxPesqui"	, 0 , 1},; //"Pesquisar"
                      { STR0002 ,   "NGCAD01"		, 0 , 2},; //"Visualizar"
                      { STR0007 ,   "NGCAD01"		, 0 , 3},; //"Incluir"
                      { STR0008 ,   "NGCAD01"		, 0 , 4},; //"Alterar"
                      { STR0009 ,   "NGCAD01"		, 0 , 5, 3} } //"Excluir"

	//Define todos os relacionamentos a serem considerados
	//Caso seja necessário definir um novo relacionamento, basta adicionar a posição no array com as seguintes denominacoes
	//	1 - Tabela de Relacionamento
	//	2 - Descrição do Folder
	//	3 - Campo chave da tabela
	//	4 - Tabela Estrangeira
	//	5 - Campos da Tabela Estrangeira a serem considerados
	//	6 - Campos da Tabela de Relacionamento a serem considerados
	aAdd( aRelacio , { "TO1" , STR0010 , "TO1_NUMRIS"	, "TN0" , { "TN0_NUMRIS" 	, "TN0_NOMAGE"		} , { "TO1_NUMRIS", "TO1_NOMRIS" } } ) //"Riscos"
	aAdd( aRelacio , { "TO2" , STR0011 , "TO2_EQPTO"	, "TM7" , { "TM7_EQPTO" 	, "TM7_NOEQTO"		} , { "TO2_EQPTO"	, "TO2_NOEQTO" } } ) //"Equipamentos"
	aAdd( aRelacio , { "TO3" , STR0012 , "TO3_CONTRO"	, "TO4" , { "TO4_CONTRO" 	, "TO4_NOMCTR"		} , { "TO3_CONTRO", "TO3_NOMCTR" } } ) //"Medidas de Controle"
	aAdd( aRelacio , { "TO5" , STR0013 , "TO5_CODAMB"	, "TNE" , { "TNE_CODAMB" 	, "TNE_NOME" 		} , { "TO5_CODAMB", "TO5_NOMAMB" } } ) //"Locais"
	aAdd( aRelacio , { "TOZ" , STR0014 , "TOZ_PLANO"	, cAliasPA , { aFieldPA[2] 	, aFieldPA[3]	} , { "TOZ_PLANO"	, "TOZ_NOMPLA" } } ) //"Planos de Ação"

	If !lSigaMdtPs
		aAdd( aRelacio , { "TJG" , STR0015 + " MDT"	, "TJG_CODPLA" , "TJK" , { "TBB_CODPLA" , "TBB_DESPLA" } , { "TJG_CODPLA" , "TJG_DESPLA" } } ) //"Planos Emergenciais"
		aAdd( aRelacio , { "TJG" , STR0015 + " SGA"	, "TJG_CODPLA" , "TBB" , { "TBB_CODPLA" , "TBB_DESPLA" } , { "TJG_CODPLA" , "TJG_DESPLA" } } ) //"Planos Emergenciais"
	EndIf
	aAdd( aRelacio , { "TJA" , STR0016 , "TJA_CODLEG"	, "TA0" , { "TA0_CODLEG"	, "TA0_EMENTA"						} , { "TJA_CODLEG", "TJA_EMENTA"					} } ) //"Requisitos"
	aAdd( aRelacio , { "TIF" , STR0017 , "TIF_QUEST"	, "TIB" , { "TIB_CODIGO"	, "TIB_DESCRI"						} , { "TIF_QUEST"	, "TIF_DESQUE"						} } ) //"Quest. Prod. Químico"
	aAdd( aRelacio , { "TIG" , STR0032 , "TIG_CODFAM"	, "ST6" , { "T6_CODFAMI"	, "T6_NOME"						} , { "TIG_CODFAM", "TIG_NOMFAM"					} } ) //"Família"
	aAdd( aRelacio , { "TI9" , STR0033 , "TI9_CODEQP"	, "ST9" , { "T9_CODBEM"		, "T9_NOME" 						} , { "TI9_CODEQP", "TI9_DESEQP" 					} } ) //"Equip. Rad."
	aAdd( aRelacio , { "TIA" , STR0034 , "TIA_CODPRO"	, "TMO" , { "TMO_CODPRO"	, "TMO_NOMPRO" , "TMO_DESPRO"	} , { "TIA_CODPRO", "TIA_NOMPRO" , "TIA_DESPRO"	} } ) //"Prog. Saúde"

	//Valida se todas as tabelas relacionais existem, caso nao exista, deleta do array
	For nTabelas := Len( aRelacio ) To 1 Step -1
		If !AliasInDic( aRelacio[ nTabelas , _nPosTab ] )
			aDel( aRelacio , nTabelas )
			aSize( aRelacio , Len( aRelacio ) - 1 )
		EndIf
	Next nTabelas

	//Define modo de alteracao para a Tabela
	aRotSetOpc( "TO0" , @nReg , 4 )
	RegToMemory( "TO0" , .F. )
	INCLUI := .F.
	ALTERA := .T.

	//aChoice recebe os campos que serao apresentados na tela
	If lTipRel
		aNao    := { "TO0_MMSYP2" , "TO0_DESC2" , "TO0_DESCRI" }
	Endif
	aChoice := NGCAMPNSX3( "TO0" , aNao )

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
	            //Monta a Enchoice de Laudos
				oEnchoice:= MsMGet():New( "TO0" , TO0->( Recno() ) , 2 , , , , aChoice , { 12 , 0 , aSize[ 6 ] / 2 , aSize[ 5 ] / 2 } , , , , , , oPnlTop )
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

		    	oFolder:bChange := { | | fChange( oFolder , aRelacio ) }

	//Ativacao do Dialog
	Activate MsDialog oDialog Centered On Init EnchoiceBar( oDialog , { | | lOk := .T. , If( fTudoOk( aRelacio ) , oDialog:End() , lOk := .F. ) } , { | | lOk := .F. , oDialog:End() } )

	If lOk//Caso confirmacao da tela, realiza gravacao dos dadods

		Processa( { | lEnd | fGrava( aRelacio ) } , STR0021 ) //"Gravando Informações"

		//-----------------------------------------------------------------
		// Realiza a integração das informações do evento S-2240 ao Governo
		//-----------------------------------------------------------------
		If FindFunction( 'MdtEsoFun' )
			MdtEsoFun()
		EndIf

	EndIf

	If AliasInDic( "TJG" )
		dbSelectArea( "TJG" )
		dbSetOrder( 1 )
		Set Filter To
	EndIf

	dbSelectArea( "TBB" )
	dbSetOrder( 1 )
	Set Filter To

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
@since 18/07/2013
/*/
//---------------------------------------------------------------------
Static Function fBusca( aRelacio )

	//Variaveis basicas
	Local nCont		:= 0
	Local cTab 		:= ""

	//Variaveis para montagem do aCols e aHeader
	Local nInd		:= 0
	Local cKeyGet	:= ""
	Local cWhileGet	:= ""
	Local aNoFields	:= {}

	//Estrutura para busca padrao
	For nCont := 1 To Len( aRelacio )//Percorre relacionamentos

		IncProc( aRelacio[ nCont , _nPosNom ] )//Define incremento da barra de processamento

		//Zera o aCols e aHeader ( Genéricos )
		aCols := {}
		aHeader := {}

		cTab := aRelacio[ nCont , _nPosTab ]//Salva a Tabela

		// Define os campos que nao apareceram da GetDados
		aAdd( aNoFields , PrefixoCPO( cTab ) + "_LAUDO" )
		aAdd( aNoFields , PrefixoCPO( cTab ) + "_NOMLAU" )
		aAdd( aNoFields , PrefixoCPO( cTab ) + "_FILIAL" )

		//Campos específicos de cada tabela a serem tratados em separado
		If cTab == "TO5"
			aAdd( aNoFields , "TO5_SEQUEN" )
		EndIf

		//Estrutura padrao de repeticao da tabela
		cWhileGet:= cTab + "->" + PrefixoCPO( cTab ) + "_FILIAL == '" + xFilial( cTab ) + "' .AND. " + ;
						cTab + "->" + PrefixoCPO( cTab ) + "_LAUDO == '" + cLaudoRel + "'"

		If lSigaMdtPs//Caso seja prestador
			//Define que os campos de cliente e loja nao iram aparecer na GetDados
			aAdd( aNoFields , PrefixoCPO( cTab ) + "_CLIENT" )
			aAdd( aNoFields , PrefixoCPO( cTab ) + "_LOJA" )

			//Altera Indice, Chave de Pesquisa e Repeticao padrao da Tabela
			If ( nInd := NGRETORDEM( cTab , PrefixoCPO( cTab ) + "_FILIAL+" + PrefixoCPO( cTab ) + "_CLIENT+" + PrefixoCPO( cTab ) + "_LOJA+" + PrefixoCPO( cTab ) + "_LAUDO" , .F. ) ) == 0
				nInd		:= 2
			EndIf
			cKeyGet		:= "cCliMdtPs + cLaudoRel"
			cWhileGet	+= cTab + "->" + PrefixoCPO( cTab ) + "_CLIENT+" + cTab + "->" + PrefixoCPO( cTab ) + "_LOJA = '" + cCliMdtPs + "'"
		Else
			//Define Indice e Chave de Pesquisa
			nInd		:= 1
			cKeyGet		:= "cLaudoRel"
			If cTab == "TJG" .And. AliasInDic( "TJG" )//Verifica se esta na tabela de Plano Emergencial e se tem integração com o Plano Emergencial de SGA
				dbSelectArea( "TJG" )
				dbSetOrder( 1 )
				If aRelacio[ nCont , _nPosTab2 ] == "TBB"//Caso tabela secundaria seja de SGA filtra de acordo
					Set Filter To NGSEEK( "TBB" , TJG->TJG_CODPLA , 1 , "TBB_MODULO" ) == "1"
				Else//Caso tabela secundaria seja de MDT filtra de acordo
					Set Filter To NGSEEK( "TBB" , TJG->TJG_CODPLA , 1 , "TBB_MODULO" ) == "2"
				EndIf
			EndIf
		EndIf

		//Realiza a montagem do aCols e aHeader
		dbSelectArea( cTab )
		dbSetOrder( nInd )
		FillGetDados( 4 , cTab , nInd , cKeyGet , { | | } , { | | .T. } , aNoFields , , , , ;
						{ | | NGMontaaCols( cTab , &cKeyGet , cWhileGet ) } )

		//Salva o aCols e aHeader ( Genérico ) no aCols e aHeader correspondente
		&( "aCols" + cValToChar( nCont ) )		:= aClone( aCols )
		&( "aHeader" + cValToChar( nCont ) )	:= aClone( aHeader )

		If cTab == "TJG" .And. AliasInDic( "TJG" )//Caso tenha integração com o Plano Emergencial de SGA e esteja na tabela de Planos Emergenciais, retorna o filtro
			dbSelectArea( "TJG" )
			dbSetOrder( 1 )
			Set Filter To
		EndIf

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
@since 18/07/2013
/*/
//---------------------------------------------------------------------
Static Function fGrava( aRelacio , lDeletar )

	//Variaveis auxiliares
	Local j
	Local nPos 			:= 0
	Local nGrav 		:= 0
	Local nCont			:= 0
	Local nCodigo		:= 0
	Local nPosSec		:= 0
	Local nPosDel		:= 0
	Local nIdx			:= 0
	Local cTab			:= ""
	Local cSeek			:= ""
	Local cWhile		:= ""
	Local cSecCmp		:= ""
	Local aColsGrava	:= {}
	Local aHeadGrava	:= {}

	Default lDeletar	:= .F.//Define padrao como nao Exclusao

	If lSigaMdtPs//Caso prestador
		//Altera indice e chave de pesquisa
		If ( nInd := NGRETORDEM( cTab , PrefixoCPO( cTab ) + "_FILIAL+" + PrefixoCPO( cTab ) + "_CLIENT+" + PrefixoCPO( cTab ) + "_LOJA+" + PrefixoCPO( cTab ) + "_LAUDO" , .F. ) ) == 0
			nInd		:= 2
		EndIf
		cSeek	:= cCliMdtPs + cLaudoRel
	Else
		//Define indice e chave de pesquisa padrao
		nIdx	:= 1
		cSeek	:= cLaudoRel
	EndIf

	For nCont := 1 To Len( aRelacio )//Percorre relacionamentos

		IncProc( aRelacio[ nCont , _nPosNom ] )//Define incremento da barra de processamento

		//Salva tabela e posicao do código do array de relacionamento
		cTab 		:= aRelacio[ nCont , _nPosTab ]
		cCodigo		:= aRelacio[ nCont , _nPosCod ]
		cWhile 		:= cTab + "->" + PrefixoCPO( cTab ) + "_FILIAL == '" + xFilial( cTab ) + "' .AND. " + ;
						cTab + "->" + PrefixoCPO( cTab ) + "_LAUDO == '" + cLaudoRel + "'"
		If lSigaMdtPs
			cWhile	+= cTab + "->" + PrefixoCPO( cTab ) + "_CLIENT+" + cTab + "->" + PrefixoCPO( cTab ) + "_LOJA = '" + cCliMdtPs + "'"
		EndIf

		//Salva aCols e aHeader correspondente
		aColsGrava	:= aClone( &( "aCols" + cValToChar( nCont ) ) )
		aHeadGrava	:= aClone( &( "aHeader" + cValToChar( nCont ) ) )

		//Procura a posicao do código
		nCodigo		:= aScan( aHeadGrava , { | x | AllTrim( Upper( x[ 2 ] ) ) == cCodigo } )
		nPosSec		:= 0
		If cTab == "TO5"
			nPosSec := aScan( aHeadGrava , { | x | AllTrim( Upper( x[ 2 ] ) ) == "TO5_CODFUN" } )
			cSecCmp := "TO5_CODFUN"
		ElseIf cTab == "TJG"
			//Reforca o Filtro na TJG
			dbSelectArea( "TBB" )
			dbSetOrder( 1 )
			If aRelacio[ nCont , _nPosTab2 ] == "TBB"//Caso tabela secundaria seja de SGA filtra de acordo
				cTipPE := "1"
			Else//Caso tabela secundaria seja de MDT filtra de acordo
				cTipPE := "2"
			EndIf
			Set Filter To TBB->TBB_MODULO == cTipPE

			If AliasInDic( "TJG" )
				dbSelectArea( "TJG" )
				dbSetOrder( 1 )
				Set Filter To NGSEEK( "TBB" , TJG->TJG_CODPLA , 1 , "TBB_MODULO" ) == cTipPE
			EndIf
		EndIf
		//Salva a posicao correspondente a indicacao de deletados
		nPosDel		:= Len( aHeadGrava ) + 1

		If nCodigo > 0//Caso encontre a posicao de codigo
			If !lDeletar//Caso nao seja para deletar
				//Coloca os deletados por primeiro
				aSORT( aColsGrava , , , { | x , y | x[ nPosDel ] .And. !y[ nPosDel ] } )

				//Posiciona na tabela e percorre o aCols
				dbSelectArea( cTab )
				dbSetOrder( nIdx )
				For nGrav := 1 To Len( aColsGrava )
					If !aColsGrava[ nGrav , nPosDel ] .and. !Empty( aColsGrava[ nGrav , nCodigo ] ) //Caso nao esteja deletada a linha e campo codigo esteja preenchido
						If dbSeek( xFilial( cTab ) + cSeek + aColsGrava[ nGrav , nCodigo ] + If( nPosSec > 0 , aColsGrava[ nGrav , nPosSec ] , "" ) ) //Verifica se ja existe a informacao na tabela
							RecLock( cTab , .F. )
						Else
							RecLock( cTab , .T. )
						EndIf
						For j := 1 to FCount()//Percorre todos os campos da tabela gravando as informacoes, caso necessaria inclusao específica, feita condicao via If/ElseIf
							If "_FILIAL" $ Upper( FieldName( j ) )
								FieldPut( j , xFilial( cTab ) )
							ElseIf "_LAUDO" $ Upper( FieldName( j ) )
								FieldPut( j , cLaudoRel )
							ElseIf "_CLIENT" $ Upper( FieldName( j ) )
								FieldPut( j , SA1->A1_COD )
							ElseIf "_LOJA" $ Upper( FieldName( j ) )
								FieldPut( j , SA1->A1_LOJA )
							ElseIf ( nPos := aScan( aHeadGrava , { | x | AllTrim( Upper( x[ 2 ] ) ) == AllTrim( Upper( FieldName( j ) ) ) } ) ) > 0//Caso posicao do campo esteja no aHeader
								FieldPut( j , aColsGrava[ nGrav , nPos ] )
							Endif
						Next j
						( cTab )->( MsUnLock() )
					Else
						If dbSeek( xFilial( cTab ) + cSeek + aColsGrava[ nGrav , nCodigo ] + If( nPosSec > 0 , aColsGrava[ nGrav , nPosSec ] , "" ) )//Caso campo esteja deletado e exista na tabela, deleta
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
			dbSeek( xFilial( cTab ) + cSeek )
			While ( cTab )->( !Eof() ) .and. &( cWhile )
				If lDeletar .Or. aScan( aColsGrava , { | x | x[ nCodigo ] == &( cCodigo ) .AND. If( nPosSec > 0 , x[ nPosSec ] == &( cSecCmp ) , .T. ) .AND. !x[ Len( x ) ] } ) == 0
					RecLock( cTab , .F. )
					( cTab )->( dbDelete() )
					( cTab )->( MsUnLock() )
				Endif
				dbSelectArea( cTab )
				( cTab )->( dbSkip() )
			End
		EndIf
	Next nCont

Return
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
@since 18/07/2013
/*/
//---------------------------------------------------------------------
Static Function fLinhaOK( oFolder , aRelacio , lFim , nPosic )

	//Variaveis auxiliares
	Local f
	Local aColsOk 	:= {}, aHeadOk := {}
	Local nPosCod 	:= 1, nAt := 1, nPosSec := 0

	Default lFim 	:= .F.//Define fim como .F.
	Default nPosic	:= oFolder:nOption

	//Salva o aCols e aHeader de acordo com a posicao, o nAt da GetDados posicionada e o código de acordo com sua posicao
	aColsOk	:= aClone( &( "oGetDad" + cValToChar( nPosic ) ):aCols )
	aHeadOk	:= aClone( &( "aHeader" + cValToChar( nPosic ) ) )
	nAt		:= &( "oGetDad" + cValToChar( nPosic ) ):nAt
	nPosCod	:= aScan( aHeadOk , { | x | AllTrim( Upper( x[ 2 ] ) ) == aRelacio[ nPosic , _nPosCod ] } )
	If aRelacio[ nPosic , _nPosTab ] == "TO5"
		nPosSec := aScan( aHeadOk , { | x | AllTrim( Upper( x[ 2 ] ) ) == "TO5_CODFUN" } )
	EndIf

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

				If nPosSec > 0 .And. Empty( aColsOk[ f , nPosSec ] ) .And. Empty( aColsOk[ f , nPosCod ] ) .And. If( lFim , Len( aColsOk ) <> 1 , .T. )
					//Mostra mensagem de Help
					Help( 1 , " " , "OBRIGAT2" , , aHeadOk[ nPosCod , 1 ] , 3 , 0 )
					Return .F.
				EndIf

				If nPosic == 1 // Risco

					DbSelectArea( 'TN0' )
					DbSetOrder( 1 )
					MsSeek( xFilial( 'TN0' ) + aColsOk[ f, 1 ] )

					If !Empty( TO0->TO0_DTFIM ) .And. TN0->TN0_DTAVAL > TO0->TO0_DTFIM

						//---------------------------------------------------
						// "O risco foi avaliado após a data final do laudo"
						// "Não será possível vincular o risco"
						//---------------------------------------------------
						Help( Nil, Nil, STR0025, Nil, AllTrim( aColsOk[ f, 1 ] ) + ' - ' + STR0035 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0036 + '.' } )
						Return .F.

					EndIf

					If !Empty( TN0->TN0_DTELIM ) .And. TN0->TN0_DTELIM < TO0->TO0_DTINIC

						//---------------------------------------------------
						// "O risco foi eliminado antes do início do laudo"
						// "Não será possível vincular o risco"
						//---------------------------------------------------
						Help( Nil, Nil, STR0025, Nil, AllTrim( aColsOk[ f, 1 ] ) + ' - ' + STR0037 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0036 + '.' } )
						Return .F.

					EndIf

				EndIf

			Endif
			//Verifica se é somente LinhaOk
			If f <> nAt .and. !aColsOk[ nAt , Len( aColsOk[ nAt ] ) ]
				If aColsOk[ f , nPosCod ] == aColsOk[ nAt , nPosCod ] .And. If( nPosSec > 0 , aColsOk[ f , nPosSec ] == aColsOk[ nAt , nPosSec ] , .T. )
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
@since 18/07/2013
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
/*/{Protheus.doc} fChange
Função chamada na Troca de Folder

@return Nil

@param oFolder 	- Objeto do Folder ( Obrigatório )
@param aRelacio	- Array de relacionamentos ( Obrigatório )

@sample
fButton( oFolder , aRelacio )

@author Jackson Machado
@since 18/07/2013
/*/
//---------------------------------------------------------------------
Static Function fChange( oFolder , aRelacio )

	Local nPosFol := oFolder:nOption

	If aRelacio[ nPosFol , _nPosTab ] == "TJG"//Verifica se esta em uma aba correspondente a tabela TJG
		dbSelectArea( "TBB" )
		dbSetOrder( 1 )
		If aRelacio[ nPosFol , _nPosTab2 ] == "TBB"//Caso tabela secundaria seja de SGA filtra de acordo
			Set Filter To TBB->TBB_MODULO == "1"
			cTipPE := "1"
		Else//Caso tabela secundaria seja de MDT filtra de acordo
			Set Filter To TBB->TBB_MODULO == "2"
			cTipPE := "2"
		EndIf
	Else
		dbSelectArea( "TBB" )
		dbSetOrder( 1 )
		Set Filter To
		cTipPE := "X"
	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fButton
Adiciona multiplos no relacionamento

@return Nil

@param oFolder 	- Objeto do Folder ( Obrigatório )
@param aRelacio	- Array de relacionamentos ( Obrigatório )

@sample
fButton( oFolder , aRelacio )

@author Jackson Machado
@since 18/07/2013
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
	Local nIdx		:= 0
	Local cTipo     := ''
	Local cTitu     := ''

	//Variaveis para montar TRB
	Local cAliasTRB	:= GetNextAlias()
	Local aDBF, aTRB, aIdx, aDescIdx

	//Variaveis da Montagem do MarkBrowse
	Local lOK := .F.
	Local lInverte, lRet

	//Definicoes de Objetos
	Local oDialog
	Local oMark
	Local oPnlTot

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

		aTam  := TAMSX3( aCampos[ nCps ] )
		cTipo := GetSx3Cache( aCampos[ nCps ] ,'X3_TIPO' )
		cTitu := AllTrim( Posicione( 'SX3' , 2 , aCampos[ nCps ] , 'X3Titulo()' ) )
		aAdd( aDBF , { aCampos[ nCps ] , cTipo	, aTam[ 1 ]	, aTam[ 2 ]	} )
		aAdd( aTRB , { aCampos[ nCps ] , NIL 	, cTitu   	,			} )

	Next nCps

	MDTA232IDX( @aIdx , @aDescIdx , aCampos )//Realiza a Geracao dos Indices

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

	Processa( { | lEnd | fBuscaReg( cTabRel , cAliasTRB , nFolPos , aCampos , aRelacio[ nFolPos , _nPosCod ] ) } , STR0022 , STR0023 ) //"Buscando Registros"###"Aguarde"

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

		oPnlTot := TPanel():New( , , , oDialog , , , , , , , , .F. , .F. )
			oPnlTot:Align := CONTROL_ALIGN_ALLCLIENT

		//--- DESCRICAO ( TOPO )
		oPanel := TPanel():New( 0 , 0 , , oPnlTot , , .T. , .F. , , , 0 , 55 , .T. , .F. )
			oPanel:Align := CONTROL_ALIGN_TOP

			@ 8,9.6 TO 45,280 OF oPanel PIXEL

			TSay():New( 19 , 12 , { | | OemtoAnsi( STR0026 ) } , oPanel , , , .F. , .F. , .F. , .T. , CLR_BLACK , CLR_WHITE , 200 , 010 ) //"Estes são os registros cadastrados no sistema."
			TSay():New( 29 , 12 , { | | OemtoAnsi( STR0027) } , oPanel , , , .F. , .F. , .F. , .T. , CLR_BLACK , CLR_WHITE , 200 , 010 ) //"Selecione aqueles que foram avaliados no laudo."

		//--- PESQUISAR
		//Define as opcoes de Pesquisa
		aCbxPesq := aClone( aDescIdx )
		aAdd( aCbxPesq , STR0028 ) //"Marcados"
		cCbxPesq := aCbxPesq[ 1 ]

		oPnlPesq 		:= TPanel():New( 01 , 01 , , oPnlTot , , , , CLR_BLACK , CLR_WHITE , 50 , 30 , .T. , .T. )
			oPnlPesq:Align	:= CONTROL_ALIGN_TOP

				oCbxPesq := TComboBox():New( 002 , 002 , { | u | If( PCount() > 0 , cCbxPesq := u , cCbxPesq ) } , ;
														aCbxPesq , 200 , 08 , oPnlPesq , , { | | } ;
														, , , , .T. , , , , , , , , , "cCbxPesq" )
					oCbxPesq:bChange := { | | fSetIndex( cAliasTRB , aCbxPesq , @cPesquisar , oMark ) }

				oPesquisar := TGet():New( 015 , 002 , { | u | If( PCount() > 0 , cPesquisar := u , cPesquisar ) } , oPnlPesq , 200 , 008 , "" , { | | .T. } , CLR_BLACK , CLR_WHITE , ,;
										.F. , , .T. /*lPixel*/ , , .F. , { | | .T. }/*bWhen*/ , .F. , .F. , , .F. /*lReadOnly*/ , .F. , "" , "cPesquisar" , , , , .F. /*lHasButton*/ )

				oBtnPesq := TButton():New( 002 , 220 , STR0001 , oPnlPesq , { | | fPesqTRB( cAliasTRB , oMark ) } , ;//"Pesquisar" //"Pesquisar"
														70 , 10 , , , .F. , .T. , .F. , , .F. , , , .F. )

		oMark := MsSelect():New( cAliasTRB , "OK" , , aTRB , @lInverte , @cMarca , { 45 , 5 , 180 , 281 } )
			oMark:oBrowse:lHasMark		:= .T.
			oMark:oBrowse:lCanAllMark	:= .T.
			oMark:oBrowse:bAllMark		:= { | | fInverte( cMarca , cAliasTRB , oMark , .T. ) }//Funcao inverte marcadores
			oMark:bMark	   				:= { | | fInverte( cMarca , cAliasTRB , oMark ) }//Funcao inverte marcadores
			oMark:oBrowse:Align			:= CONTROL_ALIGN_BOTTOM

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
@since 18/07/2013
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

@return nIndice - Retorna o valor do Indice

@param aIndMrk - Indices de pesquisa do markbrowse. ( Obrigatório )

@author Hugo R. Pereira
@since 07/01/2013
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

@sample
fButton( "TN0" , 1 , { "TN0_NUMRIS" , "TN0_NOMAGE" } , "TN0_NUMRIS" )

@author Jackson Machado
@since 18/07/2013
/*/
//---------------------------------------------------------------------
Static Function fBuscaReg( cTabela , cAliasTRB , nFolPos , aCampos , cCodigo )

	Local nCps		:= 0
	Local nPosCod	:= 1
	Local nPosSec	:= 0
	Local cCampo	:= ""
	Local cCpsVal	:= ""
	Local cCodRel	:= ""
	Local oGet		:= &( "oGetDad" + cValToChar( nFolPos ) )
	Local aColsOK	:= aClone( oGet:aCols )
	Local aHeadOk	:= aClone( oGet:aHeader )

    nPosCod	:= aScan( aHeadOk , { | x | AllTrim( Upper( x[ 2 ] ) ) == cCodigo } )
	If cTabela == "TNE"
		cCpsVal := "Space( " + cValToChar( TAMSX3( "TO5_CODFUN" )[ 1 ] ) + " )"
		nPosSec := aScan( aHeadOk , { | x | AllTrim( Upper( x[ 2 ] ) ) == "TO5_CODFUN" } )
	ElseIf cTabela == "TJK"
		cTabela := "TBB"
		//Reforça o Filtro
		dbSelectArea( cTabela )
		dbSetOrder( 1 )
		Set Filter To TBB->TBB_MODULO == cTipPE
	ElseIf cTabela == "TBB"
		//Reforça o Filtro
		dbSelectArea( cTabela )
		dbSetOrder( 1 )
		Set Filter To TBB->TBB_MODULO == cTipPE
	ElseIf cTabela == "TN0"
		If NGCADICBASE( "TO0_FINALI","A","TO0" , .F. ) .And. !Empty( TO0->TO0_FINALI ) .And. TO0->TO0_TIPREL == "3"
			cTIPADI := "NGSEEK( 'TMA' , TN0->TN0_AGENTE , 1 , 'TMA_TIPADI' )"
			//Reforça o Filtro
			dbSelectArea( cTabela )
			dbSetOrder( 1 )
			Set Filter To TO0->TO0_FINALI == &cTIPADI .Or. TO0->TO0_FINALI == "3" .And. Empty( &cTIPADI )
		EndIf
	ElseIf cTabela == "TAA"
		dbSelectArea( cTabela )
		dbSetOrder( 1 )
		If !Empty(M->TO0_TIPREL)
			If nModulo == 35 .And. M->TO0_TIPREL <> "A"
				Set Filter To TAA->TAA_TIPOPL $ "2/3"
			ElseIf nModulo == 56 .And. M->TO0_TIPREL <> "A"
				Set Filter To TAA->TAA_TIPOPL $ "4/5"
			EndIf
	EndIf
	EndIf
	cCodRel := aCampos[ 1 ]

	dbSelectArea( cTabela )
	dbSetOrder( 1 )
	If dbSeek( xFilial( cTabela ) )
		While ( cTabela )->( !Eof() ) .AND. ( cTabela )->&( PrefixoCPO( cTabela ) + "_FILIAL" ) == xFilial( cTabela )
			RegToMemory( cTabela , .F. )
			RecLock( cAliasTRB , .T. )
			(cAliasTRB)->OK     := If( aScan( aColsOk , { | x | x[ nPosCod ] == &( "M->" + cCodRel ) .And. If( nPosSec > 0 , x[ nPosSec ] == &( cCpsVal ) , .T. ) } ) > 0, cMarca , " " )
			For nCps := 1 To Len( aCampos )
				cCampo := aCampos[ nCps ]
				&( cAliasTRB + "->" + cCampo ) := &( "M->" + cCampo )
			Next nCps
			( cAliasTRB )->( MsUnLock() )
			( cTabela )->( dbSkip() )
		End
	EndIf

	dbSelectArea( cTabela )
	dbSetOrder( 1 )
	Set Filter To

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
fButton( "TN0" , 1 , { "TN0_NUMRIS" , "TN0_NOMAGE" } , "TN0_NUMRIS" )

@author Jackson Machado
@since 18/07/2013
/*/
//---------------------------------------------------------------------
Static Function fGravCols( oGet , cAliasTRB , aCampos , cCodigo , cTabela , aCampos2 )

	Local nCols, nCps
	Local nPosCod := 1
	Local nPosSec := 0
	Local nPosCps := 0
	Local cCpsVal := ""
	Local cCodRel := ""
	Local aColsOk := {}
	Local aHeadOk := {}
	Local aColsTp := {}

	aColsOk := aClone( oGet:aCols )
	aHeadOk := aClone( oGet:aHeader )
	aColsTp := BLANKGETD( aHeadOk )

	nPosCod := aScan( aHeadOk , { | x | Trim( Upper( x[ 2 ] ) ) == cCodigo } )
	If cTabela == "TO5"
		cCpsVal := "Space( " + cValToChar( TAMSX3( "TO5_CODFUN" )[ 1 ] ) + " )"
		nPosSec := aScan( aHeadOk , { | x | Trim( Upper( x[ 2 ] ) ) == "TO5_CODFUN" } )
	EndIf
	cCodRel := aCampos[ 1 ]

	For nCols := Len( aColsOk ) To 1 Step -1 //Deleta do aColsOk os registros - não marcados; não estiver encontrado
		dbSelectArea( cAliasTRB )
		dbSetOrder( 1 )
		If !dbSeek( aColsOK[ nCols , nPosCod ] ) .OR. Empty( ( cAliasTRB )->OK )
			If nPosSec == 0 .Or. aColsOK[ nCols , nPosSec ] == &( cCpsVal )
				aDel( aColsOk , nCols )
				aSize( aColsOk , Len( aColsOk ) - 1 )
			EndIf
		EndIf
	Next nCols

	dbSelectArea( cAliasTRB )
	dbGoTop()
	While ( cAliasTRB )->( !Eof() )
		If !Empty( ( cAliasTRB )->OK ) .AND. aScan( aColsOk , {|x| x[ nPosCod ] == &( cAliasTRB + "->" + cCodRel ) .And. If( nPosSec > 0 , x[ nPosSec ] == &( cCpsVal ) , .T. ) } ) == 0
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

@param cMarca 		- Valor da marca do TRB ( Obrigatório )
@param cAliasTRB	- Alias do TRB ( Obrigatório )
@param oMark		- Objeto do MarkBrowse ( Obrigatório )
@param lAll			- Indica se eh AllMark

@sample
fInverte( "E" , "TRB" )

@author Jackson Machado
@since 18/07/2013
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
/*/{Protheus.doc} MDTA232IDX
Realiza a montagem dos Indices
Faz esta montagem com base em uma Permutação de Len(aCampos)!, para
realizar a montagem utiliza-se da seguinte lógica:
Salva o primeiro valor (Ex. 1234)
Percorre este número da direita para a esquerda até encontrar uma
verificação onde o número da direita seja maior que o da esquerda
(Ex.: 34)
Quando encontrar, verifica o número da esquerda e procura em todos
os números já vistos, qual corresponde ao primeiro logo superior a
ele (No caso de exemplo, terá verifica o 3 e o 4, como considerará
o 3 como base por ser o da esquerda, receberá o 4 como logo superior)
Jogará na posição do número da esquerda, este valor logo superior
(No caso de exemplo, verificará a posição do 3 e jogará o 4 no seu
lugar)
Para então pegar o restante dos números verificados e posiciona-los
em ordem crescente após a string( Ou seja, colocará 124 e pegar o 3
que sobrou, colocando depois 1243)
Em um exemplo posicionado posterior a mesma sequência, por exemplo
3241 se comportará da seguinte forma:
Localizará que, da direita para a esquerda, o 'maior que o da esquerda'
será o 24
Foram verificados os valores 241, porém será salvo o valor 4
O valor 4 será jogado na posição onde está o valor 2, ficando 34
Os outros números verificados serão ordenados de foram crescente,
ficando 12, para entao serem concatenados (3412)
Lógica baseada no algorítimo contido no site
http://ipb.pt/~mar/MD2011.12/Cap3_2.pdf, acessado na data desta função.

@return Nil

@param aIdx, Array, Receberá os indices
@param aDescIdx, Array, Receberá as descrições dos indices
@param aCampos, Array, Campos que serao considerados

@sample
fButton( oFolder , aRelacio )

@author Jackson Machado e Guilherme Benkendorf
@since 23/07/2013
/*/
//---------------------------------------------------------------------
Function MDTA232IDX( aIdx , aDescIdx , aCampos )

	//Variaveis locais
	Local nX, nY, nCont

	//Variaveis para montagem de indice
	Local cIdx		:= ""
	Local cDescIdx	:= ""
	Local cTmp		:= ""

	//Variaveis para calculo da permutacao
	Local nFator	:= 0  // Indica o fatorial calculado
	Local nPos		:= 0  // Contador de Posicao
	Local nPosVal	:= 0  // Posicao a ser validada
	Local nAt		:= 0  // Posicao na String
	Local cVal1		:= "" // Valor comparativo direita
	Local cVal2		:= "" // Valor compartivo esquerda
	Local cValor	:= "" // Valor final
	Local cProxVal	:= "" // Proximo valor a ser visto
	Local aVistos	:= {} // Valores já comparados
	Local aValores	:= {} // Valores gerados
	Local aArray	:= {} // Array temporário de posicoes

	//Define um array padrao de todas as posicoes de campo
	For nCont := 1 To Len( aCampos )
		aAdd( aArray , nCont )
	Next nCont

	//Percorre todos os valores
	For nCont := 1 To Len( aArray )
		//Realiza o calculo de fatorial
		If nCont <> 1
			nFator *= nCont
		Else
			nFator := nCont
		EndIf
		//Concatena o primeiro valor (Ex.: 1234)
		cValor += RETASC( cValToChar( nCont ) , 1 , .T. )
	Next nCont

	//Percorre todos os valores até 'fechar' o fatorial
	For nX := 1 To nFator
		//Zera o array de valores vistos
		aVistos := {}
		//Adiciona o ultimo valor verificado
		aAdd( aValores , cValor )
		//Salva como posicao inicial o tamanho da string
		nPos := Len( cValor )
		While nPos >= 1//Continua até chegar a primeira posicao
			//Salva o 'ultimo' valor e o 'anterior' (Ex.: cVal1 receberá 4 e cVal2 receberá 3)
			cVal1 := SubStr( cValor , nPos , 1 )
			cVal2 := SubStr( cValor , nPos - 1 , 1 )

			//Adiciona a posicao no array de vistos (Ex.: {4})
			aAdd( aVistos , cVal1 )
			nPosSub := nPos - 1//Salva posicao para 'corte'
			If cVal1 > cVal2//Caso 'ultima' posicao for maior que 'anterior'
				aAdd( aVistos , cVal2 )//Adiciona posicao verificada no array de vistos (Ex.: {4,3})
				aVistos := aSort( aVistos , , , { | x , y | x < y } )//Ordena o array de numeros vistos em ordem crescente (Ex.: {3,4})
				nPosVal := aScan( aVistos , { | x | x == cVal2 } )//Qual a posicao do valor a ser validado (Ex. receberá a posicao 1)
				nAt := At( aVistos[ nPosVal ] , cValor )//Verifica onde ele está na string (Ex.: está na posicao 3)
				cProxVal := SubStr( cValor , 1 , nAt - 1 )//Salva até posicao anterior (Ex.: Salvará 12 )

				nPosVal += 1//Verifica o próximo valor
				cProxVal += aVistos[ nPosVal ]//Salva este valor na String (Ex.: Salvará 124)
				//Retira o valor do array (Ex.: {3,4} passará para {3})
				aDel( aVistos , nPosVal )
				aSize( aVistos , Len( aVistos ) - 1 )
				For nY := 1 To Len( aVistos )//Salva os valores em ordem crescente na string (Ex.: Ao final ficará 1243)
					cProxVal += aVistos[ nY ]
				Next nY
				Exit
			EndIf
			nPos--//Caso valor nao seja válido, diminui uma posicao de verificacao da string
		End
		cValor := cProxVal//Salva o próximo valor

	Next nX

	For nCont := 1 To Len( aValores )//Percorre os valores encontrados
		cIdx		:= ""
		cDescIdx	:= ""
		cTmp		:= aValores[ nCont ]//Salva o valor a ser verificado (Ex.: 1234)
		While !Empty( cTmp )//Enquando nao for fazio o valor
			If !Empty( cIdx )//Caso seja a partir da segunda verificacao, concatena com '+'
				cIdx += "+"
			EndIf
			If !Empty( cDescIdx )//Caso seja a partir da segunda verificacao, concatena com '+'
				cDescIdx += "+"
			EndIf
			//Posicao no campo do SX3
			dbSelectArea( "SX3" )
			dbSetOrder( 2 )
			dbSeek( aCampos[ Val( SubStr( cTmp , 1 , 1 ) ) ] )//(Ex.: aCampos := { "CAMPO1" , "CAMPO2" }; pega a posicao correspondente no cTmp (1); posiciona no "CAMPO1" no SX3)
			cIdx 		+= aCampos[ Val( SubStr( cTmp , 1 , 1 ) ) ]//Salva o valor do titulo correspondente ao campo
			cDescIdx	+= AllTrim( X3Titulo() )//Salva o valor do titulo correspondente ao campo
			cTmp 		:= SubStr( cTmp , 2 )//Retira uma posicao da string
		End
		aAdd( aIdx 		, cIdx		)//Salva o indice montado no array de indices
		aAdd( aDescIdx	, cDescIdx	)//Salva o indice montado no array de indices
	Next nCont

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fPesqTRB
Funcao de Pesquisar no Browse.

@samples fPesqTRB()

@return Sempre verdadeiro

@param cAliasTRB	- Alias do MarkBrowse ( Obrigatório )
@param oMark 		- Objeto do MarkBrowse ( Obrigatório )

@author Jackson Machado
@since 29/04/2013
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
/*/{Protheus.doc} MDT232PLA
Responsavel por realizar a validação do campo TJG_CODPLA.

@type function

@source MDTA232.prw

@author Guilherme Freudenburg
@since 09/05/2017

@sample MDT232PLA()

@return lRet,Lógico, Retorna verdadeiro quando função estiver correta
/*/
//---------------------------------------------------------------------
Function MDT232PLA()

	Local lRet := .T.

	If Type( 'cTipPE' ) == 'C' .And. cTipPE <> Posicione( "TBB" , 1 , xFilial("TBB") + M->TJG_CODPLA , "TBB_MODULO" )
		Help(" ",1,"REGNOIS") //Registro não existe, caso seja de outro módulo.
		lRet := .F.
	EndIf

Return lRet
