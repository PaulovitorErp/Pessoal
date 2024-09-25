#include "Totvs.ch"
#INCLUDE "mdta890.ch"

//Define posicoes do array de tabelas
#DEFINE _nPosTab 1
#DEFINE _nPosNom 2
#DEFINE _nPosCod 3
#DEFINE _nPosTab2 4
#DEFINE _nPosCps 5
#DEFINE _nPosCps2 6
#DEFINE _nPosTab3 7
//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA890
Adequação de Tabelas para o eSocial
Realiza a montagem de uma tela que tem o intuito de facilitar o usuário
o vínculo com as informações do eSocial

@return

@sample MDTA890()

@author Jackson Machado
@since 18/02/2016
/*/
//---------------------------------------------------------------------
Function MDTA890()

	//Variaveis a serem utilizadas para montagem da tela
	Local nTabelas	:= 0
	Local lOk		:= .F.
	Local aNao		:= {}
	Local aColor	:= NGCOLOR()
	Local aArea		:= GetArea() //Salva a area de trabalho atual
	Local aButtons	:= { { STR0455, { || MDTTrcUMed() }, STR0455, STR0455 } } //"Unidade de Medida"

	//Variaveis de tamanho de tela
	Local lEnchBar	:= .T. // Indica se a janela de diálogo possuirá enchoicebar
	Local lPadrao	:= .F. // Indica se a janela deve respeitar as medidas padrões do Protheus (.T.) ou usar o máximo disponível (.F.)
	Local nMinY		:= 430 // Altura mínima da janela
	Local aSize 	:= MsAdvSize( lEnchBar, lPadrao, nMinY )
	Local aObjects 	:= {}
	Local aInfo 	:= {}
	Local aPosObj 	:= {}

	//Define variaveis dos folders
	Local nContFol	:= 0
	Local aTitles	:= {}
	Local aPages	:= {}

	//Define os Objetos
	Local oDialog
	Local oPnlPai
	Local oFolder

	//Definicoes de Relacionamento
	Local aRelacio		:= {}

	//Define um novo aRotina padrao para nao ocorrer erro
	Private aRotina 	:=	{ { "Pesquisar", "AxPesqui", 0, 1 }, ;
			                  { "Visualizar", "NGCAD01", 0, 2 }, ;
			                  { "Incluir", "NGCAD01", 0, 3 }, ;
			                  { "Alterar", "NGCAD01", 0, 4 }, ;
			                  { "Excluir", "NGCAD01", 0, 5, 3 } }

	If !AliasInDic( "C98" ) .Or. !AliasInDic( "TYG" )
		MsgInfo( STR0444 ) //"Ambiente inconsistente para as adequações do eSocial."
	Else
		//Define todos os relacionamentos a serem considerados
		//Caso seja necessário definir um novo relacionamento, basta adicionar a posição no array com as seguintes denominacoes
		//	1 - Tabela de Relacionamento
		//	2 - Descrição do Folder
		//	3 - Campo chave da tabela
		//	4 - Tabela Estrangeira
		//	5 - Campos da Tabela do MDT a serem considerados
		//	6 - Campos editáveis
		//  7 - Tabela Estrangeira Secundária
		aAdd( aRelacio, { "TMA", STR0445, "TMA_AGENTE", "C98", NGCAMPNSX3( "TMA", aNao ), 	{ "TMA_ESOC"	} } ) //"Agentes"
		aAdd( aRelacio, { "TNG", STR0446, "TNG_TIPACI", "C8K", NGCAMPNSX3( "TNG", aNao ), 	{ IIf( X3USO( GetSx3Cache( "TNG_ESOC", "X3_USADO" ) ), "TNG_ESOC", "TNG_ESOC1" )	} } ) //"Tipo Acidente"
		aAdd( aRelacio, { "TNH", STR0447, "TNH_CODOBJ", "C8J", NGCAMPNSX3( "TNH", aNao ), 	{ "TNH_ESOC"	} } ) //"Objetos Causadores"
		aAdd( aRelacio, { "TOI", STR0448, "TOI_CODPAR", "C8I", NGCAMPNSX3( "TOI", aNao ), 	{ "TOI_ESOC"	} } ) //"Parte do Corpo"
		aAdd( aRelacio, { "TOJ", STR0449, "TOJ_CODLES", "C8M", NGCAMPNSX3( "TOJ", aNao ), 	{ "TOJ_ESOC"	} } ) //"Natureza Lesão"

		//Valida se todas as tabelas relacionais existem, caso nao exista, deleta do array
		For nTabelas := Len( aRelacio ) To 1 Step -1
			If !AliasInDic( aRelacio[ nTabelas, _nPosTab ] )
				aDel( aRelacio, nTabelas )
				aSize( aRelacio, Len( aRelacio ) - 1 )
			EndIf
		Next nTabelas

		//Define modo de alteracao para a Tabela
		INCLUI := .F.
		ALTERA := .T.

		//Definicoes de tamanho de tela
		aAdd( aObjects, { 100, 100, .T., .T. } )
		aAdd( aObjects, { 315, 70, .T., .T. } )
		aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
		aPosObj := MsObjSize( aInfo, aObjects, .F. )

		//Define os valores dos folders
		For nContFol := 1 To Len( aRelacio )
			aAdd( aTitles, aRelacio[ nContFol, _nPosNom ] )
			aAdd( aPages, "Header " + cValToChar( nContFol ) )
			&( "aCols" + cValToChar( nContFol ) ) := {}
			&( "aHeader" + cValToChar( nContFol ) ) := {}
			&( "oGetDad" + cValToChar( nContFol ) ) := Nil
		Next nContFol

		//Realiza a busca das informacoes dos aCols
		Processa( { | lEnd | fBusca( aRelacio ) }, STR0451 ) //"Carregando Informações"

		//Monta a Tela
		Define MsDialog oDialog Title OemToAnsi( STR0452 ) From aSize[ 7 ], 0 To aSize[ 6 ], aSize[ 5 ] Of oMainWnd Pixel //"De/Para de Tabelas eSocial"

			//Panel criado para correta disposicao da tela
			oPnlPai := TPanel():New( , , , oDialog, , , , , , , , .F., .F. )
				oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

				//Rodapé indicativo
				oPnlRod := TPanel():New( , , , oPnlPai, , , , , aColor[ 2 ], , 10, .F., .F. )
			   		oPnlRod:Align := CONTROL_ALIGN_BOTTOM
			   		//Monta o Texto indicativo do Rodapé
			   		TSay():New( 2, 4, { || OemtoAnsi( STR0453 ) }, oPnlRod, , , .F., .F., .F., .T., aColor[ 1 ], , 600, 008 ) //"Informe todos os valores para integração entre MDT x TAF (eSocial)."

				//Redefine as variaveis para montar as GetDados corretamente
				INCLUI := .F.
				ALTERA := .T.

				//Folder - Parte Inferior
				oFolder := TFolder():New( 00, 00, aTitles, aPages, oPnlPai, , , , .F., .F., 1000, 1000, )
					oFolder:Align 		:= CONTROL_ALIGN_ALLCLIENT
					oFolder:bSetOption 	:= { | nOption | fChangeOption( nOption, aRelacio ) }
					//Realiza a montagem das abas dos folders
					For nContFol := 1 To Len( aRelacio )
						cTab := aRelacio[ nContFol, _nPosTab ]
						//Monta a GetDados de acordo com o Folder
						dbSelectArea( cTab )
						PutFileInEof( cTab )
						&( "oGetDad" + cValToChar( nContFol ) )  := MsNewGetDados():New( 0, 0, 1000, 1000, IIf( !INCLUI .And. !ALTERA, 0, GD_INSERT + GD_UPDATE ), ;
																		{ | | fLinhaOK( oFolder, aRelacio ) }, { | | .T. }, , aRelacio[ nContFol, _nPosCps2 ], , Len( &( "aCols" + cValToChar( nContFol ) ) ), , , , oFolder:aDialogs[ nContFol ], ;
																		&( "aHeader" + cValToChar( nContFol ) ), &( "aCols" + cValToChar( nContFol ) ) )
							&( "oGetDad" + cValToChar( nContFol ) ):oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
							&( "oGetDad" + cValToChar( nContFol ) ):oBrowse:Refresh()

					Next nContFol

		//Ativacao do Dialog
		Activate MsDialog oDialog Centered On Init EnchoiceBar( oDialog, { || lOk := .T., IIf( fTudoOk( aRelacio ), oDialog:End(), lOk := .F. ) }, { || lOk := .F., oDialog:End() }, , aButtons )

		If lOk//Caso confirmacao da tela, realiza gravacao dos dadods
			Processa( { | lEnd | fGrava( aRelacio ) }, STR0454 ) //"Gravando Informações"
		EndIf
	EndIf

	//Retorna a Area de Trabalho
	RestArea( aArea )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fChangeOption
Monta os arrays de aCols e aHeader

@return Nil

@param aRelacio Array Array contendo os relacionamentos ( Obrigatório )
@param nOption Numérico, opção de inclusão alteração ou exclusão

@sample fChangeOption( nOption , aRelacio )

@author Jackson Machado
@since 18/02/2016
/*/
//---------------------------------------------------------------------
Static Function fChangeOption( nOption, aRelacio )

	RegToMemory( aRelacio[ nOption, _nPosTab ], .T. )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fBusca
Monta os arrays de aCols e aHeader

@return Nil

@param aRelacio Array Array contendo os relacionamentos ( Obrigatório )

@sample fBusca( aRelacio )

@author Jackson Machado
@since 18/02/2016
/*/
//---------------------------------------------------------------------
Static Function fBusca( aRelacio )

	//Variaveis basicas
	Local nCont		:= 0
	Local cTab 		:= ""

	//Variaveis para montagem do aCols e aHeader
	Local nPosBlql  := 0
	Local nInd		:= 0
	Local cFilif    := ""
	Local cWhileGet	:= ""
	Local aNoFields	:= {}

	//Estrutura para busca padrao
	For nCont := 1 To Len( aRelacio )//Percorre relacionamentos

		IncProc( aRelacio[ nCont, _nPosNom ] )//Define incremento da barra de processamento

		//Zera o aCols e aHeader ( Genéricos )
		aCols := {}
		aHeader := {}

		cTab := aRelacio[ nCont, _nPosTab ]//Salva a Tabela

		// Define os campos que nao apareceram da GetDados
		aNoFields := {}
		aAdd( aNoFields, PrefixoCPO( cTab ) + "_FILIAL" )
		If cTab == "TMA"
			aAdd( aNoFields, "TMA_DESCRI" )
			aAdd( aNoFields, "TMA_TIPADI" )
			aAdd( aNoFields, "TMA_AVALIA" )
			aAdd( aNoFields, "TMA_CLASSI" )
			aAdd( aNoFields, "TMA_FONTES" )
			aAdd( aNoFields, "TMA_TRANSM" )
			aAdd( aNoFields, "TMA_PROPAG" )
			aAdd( aNoFields, "TMA_TIPENT" )
			aAdd( aNoFields, "TMA_ENTRAD" )
			aAdd( aNoFields, "TMA_PATOGE" )
			aAdd( aNoFields, "TMA_VIRULE" )
			aAdd( aNoFields, "TMA_PERSIS" )
			aAdd( aNoFields, "TMA_ESTUDO" )
			aAdd( aNoFields, "TMA_VIASTR" )
			aAdd( aNoFields, "TMA_PATSYP" )
			aAdd( aNoFields, "TMA_MPATOG" )
			aAdd( aNoFields, "TMA_SINSYP" )
			aAdd( aNoFields, "TMA_MSINTO" )
		EndIf

		//Estrutura padrao de repeticao da tabela
		cWhileGet	:= cTab + "->" + PrefixoCPO( cTab ) + "_FILIAL == '" + xFilial( cTab ) + "'"
		//Define Indice e Chave de Pesquisa
		nInd		:= 1
		nPosBlql    := ( cTab )->( FieldPos( PrefixoCPO( cTab ) + "_MSBLQL" ) )
		cFilif      := IIf( nPosBlql > 0, cTab + "->" + PrefixoCPO( cTab ) + "_MSBLQL <> '1'", ".T." )

		//Realiza a montagem do aCols e aHeader
		dbSelectArea( cTab )
		dbSetOrder( nInd )
		FillGetDados( 4, cTab, nInd, "", { || }, { || .T. }, aNoFields, , , , { || NGMontaaCols( cTab, "", cWhileGet, cFilif ) } )

		//Salva o aCols e aHeader ( Genérico ) no aCols e aHeader correspondente
		&( "aCols" + cValToChar( nCont ) )		:= aClone( aCols )
		&( "aHeader" + cValToChar( nCont ) )	:= aClone( aHeader )

	Next nCont

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fGrava
Grava as informacoes no banco de dados

@return Nil

@param aRelacio Arra Array contendo os relacionamentos ( Obrigatório )
@param lDeletar Lógico Indica se e exclusao

@sample fGrava( aRelacio )

@author Jackson Machado
@since 18/02/2016
/*/
//---------------------------------------------------------------------
Static Function fGrava( aRelacio, lDeletar )

	//Variaveis auxiliares
	Local nj
	Local nPos 			:= 0
	Local nGrav 		:= 0
	Local nCont			:= 0
	Local nCodigo		:= 0
	Local nPosSec		:= 0
	Local nPosDel		:= 0
	Local nPosSoc       := 0
	Local nPosSoc1      := 0
	Local nIdx			:= 0
	Local cTab			:= ""
	Local cWhile		:= ""
	Local cSecCmp		:= ""
	Local aColsGrava	:= {}
	Local aHeadGrava	:= {}

	Default lDeletar	:= .F.//Define padrao como nao Exclusao

	//Define indice e chave de pesquisa padrao
	nIdx	:= 1

	For nCont := 1 To Len( aRelacio )//Percorre relacionamentos

		IncProc( aRelacio[ nCont, _nPosNom ] )//Define incremento da barra de processamento

		//Salva tabela e posicao do código do array de relacionamento
		cTab 		:= aRelacio[ nCont, _nPosTab ]
		cCodigo		:= aRelacio[ nCont, _nPosCod ]
		cWhile 		:= cTab + "->" + PrefixoCPO( cTab ) + "_FILIAL == '" + xFilial( cTab ) + "'"
		//Salva aCols e aHeader correspondente
		aColsGrava	:= aClone( &( "aCols" + cValToChar( nCont ) ) )
		aHeadGrava	:= aClone( &( "aHeader" + cValToChar( nCont ) ) )

		//Procura a posicao do código
		nCodigo		:= aScan( aHeadGrava, { | x | AllTrim( Upper( x[ 2 ] ) ) == cCodigo } )
		nPosSec		:= 0
		nPosSoc     := aScan( aHeadGrava, { | x | AllTrim( Upper( x[ 2 ] ) ) == PrefixoCPO( aRelacio[ nCont, _nPosTab ] ) + "_ESOC" } )
		nPosSoc1    := aScan( aHeadGrava, { | x | AllTrim( Upper( x[ 2 ] ) ) == PrefixoCPO( aRelacio[ nCont, _nPosTab ] ) + "_ESOC1" } )
		//Salva a posicao correspondente a indicacao de deletados
		nPosDel		:= Len( aHeadGrava ) + 1

		If nCodigo > 0//Caso encontre a posicao de codigo
			If !lDeletar//Caso nao seja para deletar
				//Coloca os deletados por primeiro
				aSORT( aColsGrava, , , { | x, y | x[ nPosDel ] .And. !y[ nPosDel ] } )

				//Posiciona na tabela e percorre o aCols
				dbSelectArea( cTab )
				dbSetOrder( nIdx )
				For nGrav := 1 To Len( aColsGrava )
					If !aColsGrava[ nGrav, nPosDel ] .And. !Empty( aColsGrava[ nGrav, nCodigo ] ) //Caso nao esteja deletada a linha e campo codigo esteja preenchido
						If dbSeek( xFilial( cTab ) + aColsGrava[ nGrav, nCodigo ] + IIf( nPosSec > 0, aColsGrava[ nGrav, nPosSec ], "" ) ) //Verifica se ja existe a informacao na tabela
							RecLock( cTab, .F. )
						Else
							RecLock( cTab, .T. )
						EndIf
						For nj := 1 to FCount()//Percorre todos os campos da tabela gravando as informacoes, caso necessaria inclusao específica, feita condicao via If/ElseIf
							If "_FILIAL" $ Upper( FieldName( nj ) )
								FieldPut( nj, xFilial( cTab ) )
							ElseIf ( nPos := aScan( aHeadGrava, { | x | AllTrim( Upper( x[ 2 ] ) ) == AllTrim( Upper( FieldName( nj ) ) ) } ) ) > 0//Caso posicao do campo esteja no aHeader
								FieldPut( nj, aColsGrava[ nGrav, nPos ] )
							Endif
						Next nj
						( cTab )->( MsUnLock() )
					Else
						If dbSeek( xFilial( cTab ) + aColsGrava[ nGrav, nCodigo ] + IIf( nPosSec > 0, aColsGrava[ nGrav, nPosSec ], "" ) )//Caso campo esteja deletado e exista na tabela, deleta
							RecLock( cTab, .F. )
							( cTab )->( dbDelete() )
							( cTab )->( MsUnLock() )
						EndIf
					EndIf
				Next nGrav
			EndIf

			//Verifica toda a tabela, para que delete os registros caso este nao estejam no aCols ou seja 'exclusao'
			dbSelectArea( cTab )
			dbSetOrder( nIdx )
			dbSeek( xFilial( cTab ) )
			While ( cTab )->( !Eof() ) .And. &( cWhile )
				If lDeletar .Or. aScan( aColsGrava, { | x | x[ nCodigo ] == &( cCodigo ) .And. IIf( nPosSec > 0, x[ nPosSec ] == &( cSecCmp ), .T. ) .And. !x[ Len( x ) ] } ) == 0
					RecLock( cTab, .F. )
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

@return - Lógico Indica se esta tudo correto na linha

@param oFolder	Objeto Objeto do Folder ( Obrigatório )
@param aRelacio Array Array contendo os relacionamentos ( Obrigatório )
@param lFim		Logico Indica se eh chamado pelo TudoOk
@param nPosic   Numerico Posicao de Relacionamento a ser validado

@sample fLinhaOK( 1 , aRelacio )

@author Jackson Machado
@since 18/02/2016
/*/
//---------------------------------------------------------------------
Static Function fLinhaOK( oFolder, aRelacio, lFim, nPosic )

	//Variaveis auxiliares
	Local lRet	   := .T.
	Local aColsOk  := {}
	Local aHeadOk  := {}
	Local nPosCod  := 1
	Local nAt	   := 1
	Local nPosSec  := 0
	Local nPosSoc  := 0
	Local nPosSoc1 := 0
	Local nf

	Default lFim := .F. //Define fim como .F.
	Default nPosic := oFolder:nOption

	//Não valida os Agentes pois podem ter códigos do eSocial duplicados
	If aRelacio[ nPosic, 1 ] <> "TMA"

		//Salva o aCols e aHeader de acordo com a posicao, o nAt da GetDados posicionada e o código de acordo com sua posicao
		aColsOk	 := aClone( &( "oGetDad" + cValToChar( nPosic ) ):aCols )
		aHeadOk	 := aClone( &( "aHeader" + cValToChar( nPosic ) ) )
		nAt		 := &( "oGetDad" + cValToChar( nPosic ) ):nAt
		nPosCod	 := aScan( aHeadOk, { | x | AllTrim( Upper( x[ 2 ] ) ) == aRelacio[ nPosic, _nPosCod ] } )
		nPosSoc  := aScan( aHeadOk, { | x | AllTrim( Upper( x[ 2 ] ) ) == PrefixoCPO( aRelacio[ nPosic, _nPosTab ] ) + "_ESOC" } )
		nPosSoc1 := aScan( aHeadOk, { | x | AllTrim( Upper( x[ 2 ] ) ) == PrefixoCPO( aRelacio[ nPosic, _nPosTab ] ) + "_ESOC1" } )

		//Caso for validação dos tipos de acidente
		If !X3USO( GetSx3Cache( "TNG_ESOC", "X3_USADO" ) ) //Caso o campo TNG_ESOC não esteja em uso
			If aRelacio[ nPosic, 1 ] == "TNG"
				nPosSoc := nPosSoc1 //Adiciona o campo TNG_ESOC1 para validação, pois o TNG_ESOC não é mais utilizado
			EndIf
		EndIf

		//Percorre aCols
		For nf:= 1 to Len( aColsOk )
			If !aColsOk[ nf, Len( aColsOk[ nf ] ) ]
				//Verifica se é somente LinhaOk
				If nf <> nAt .And. !aColsOk[ nAt, Len( aColsOk[ nAt ] ) ]
					If aColsOk[ nf, nPosCod ] == aColsOk[ nAt, nPosCod ] .And. IIf( nPosSec > 0, aColsOk[ nf, nPosSec ] == aColsOk[ nAt, nPosSec ], .T. )
						//Mostra mensagem de Help
						Help( " ", 1, "JAEXISTINF", , aHeadOk[ nPosCod, 1 ] )
						lRet := .F.
						Exit
					Endif
					If lRet .And. nPosSoc > 0 .And. ;
						!Empty( aColsOk[ nf, nPosSoc ] ) .And. ;
						!Empty( aColsOk[ nAt, nPosSoc ] ) .And. ; //Se os códigos do eSocial estiverem preenchidos
						aColsOk[ nf, nPosSoc ] == aColsOk[ nAt, nPosSoc ]
							Help( " ", 1, "JAEXISTINF", , aHeadOk[ nPosSoc, 1 ] ) //Emite mensagem de que o registro é duplicado
							lRet := .F.
							Exit
					EndIf
				Endif
			Endif
		Next nf

		//Posiciona tabelas em fim de arquivo
		PutFileInEof( aRelacio[ nPosic, _nPosTab ] )
		PutFileInEof( aRelacio[ nPosic, _nPosTab2 ] )
		If Len( aRelacio[ nPosic ] ) >= _nPosTab3
			PutFileInEof( aRelacio[ nPosic, _nPosTab3 ] )
		EndIf

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fTudoOk
Validacao final da tela

@return lRet Lógico Indica se está tudo correto na tela

@param aRelacio Array contendo os relacionamentos ( Obrigatório )

@sample fTudoOk( aRelacio )

@author Jackson Machado
@since 18/02/2016
/*/
//---------------------------------------------------------------------
Static Function fTudoOk( aRelacio )

	//Variaveis auxiliares
	Local nCont
	Local lRet := .T.//Indica o retorno

	For nCont := 1 To Len( aRelacio )//Percorre todos os relacionamentos
		&( "aCols" + cValToChar( nCont ) ) := aClone( &( "oGetDad" + cValToChar( nCont ) ):aCols )
		If !fLinhaOK( , aRelacio, .T., nCont )//Valida todos os Folders
			//Caso encontre inconsistência retorna
			lRet := .F.
			Exit
		EndIf
	Next nCont

Return lRet
