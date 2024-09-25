#include 'totvs.ch'
#include 'parmtype.ch'
#include 'ngfwstruct.ch'

//redefined in frameworkng.ch **************
#DEFINE __VALID_OBRIGAT__  'O'
#DEFINE __VALID_UNIQUE__   'U'
#DEFINE __VALID_FIELDS__   'F'
#DEFINE __VALID_BUSINESS__ 'B'
#DEFINE __VALID_ALL__      'OUFB'
#DEFINE __VALID_NONE__     ''
//******************************************

#DEFINE ARQUIVO_STRUCT 1
#DEFINE   CAMPO_STRUCT 2
#DEFINE    TIPO_STRUCT 3
#DEFINE TAMANHO_STRUCT 4
#DEFINE DECIMAL_STRUCT 5
#DEFINE  TITULO_STRUCT 6
#DEFINE DESCRIC_STRUCT 7
#DEFINE PICTURE_STRUCT 8
#DEFINE CONTEXT_STRUCT 9
#DEFINE OBRIGAT_STRUCT 10
#DEFINE   VALID_STRUCT 11
#DEFINE VLDUSER_STRUCT 12
#DEFINE    CBOX_STRUCT 13
#DEFINE    SIZE_STRUCT 13

#DEFINE  TITULO_HEADER 1
#DEFINE   CAMPO_HEADER 2
#DEFINE PICTURE_HEADER 3
#DEFINE TAMANHO_HEADER 4
#DEFINE DECIMAL_HEADER 5
#DEFINE   VALID_HEADER 6
#DEFINE   USADO_HEADER 7
#DEFINE    TIPO_HEADER 8
#DEFINE      F3_HEADER 9
#DEFINE CONTEXT_HEADER 10
#DEFINE    CBOX_HEADER 11
#DEFINE RELACAO_HEADER 12
#DEFINE    WHEN_HEADER 13

#DEFINE TABLE_MEMORY 1
#DEFINE FIELD_MEMORY 2
#DEFINE VALUE_MEMORY 3
#DEFINE TOTAL_MEMORY 3

//------------------------------
// Força a publicação do fonte
//------------------------------
Function _NGFWStruct()
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} NGFWStruct
Classe utilizada para armazenar estruturas de dados e permitir operacao
na base atraves de objetos instanciados.

@author Felipe Nathan Welter
@author Vitor Emanuel Batista
@since 22/06/2012
@version P12
/*/
//---------------------------------------------------------------------
CLASS NGFWStruct

	//METODOS PUBLICOS
	METHOD New() CONSTRUCTOR

	Method setAlias(cAlias, aFields)
	Method getAlias()

	METHOD initFields(lInclui)
	METHOD memoryToClass()
	METHOD SubModel(oAuxModel)
	METHOD GridToClass(oAuxModel)
	METHOD classToMemory()

	METHOD setValue(cField,xValue,nLine)
	METHOD getValue(cField)

	METHOD setAliasGrid(cAlias, aFields)
	METHOD getAliasGrid()

	METHOD setHeader(cAlias,aGrid)
	METHOD getHeader(cAlias)

	METHOD setCols(cAlias,aGrid)
	METHOD getCols(cAlias)

	METHOD setRelation(cAlias,aRelation)
	METHOD getRelation(cAlias)

	METHOD setNoDelete(cAlias)
	METHOD getNoDelete()

	METHOD setUnique(cAlias,aUnique)
	METHOD getUnique(cAlias)

	METHOD setUniqueField(cField)

	METHOD getMemory()
	METHOD getStruct()
	METHOD getIndex()

	METHOD setRecNo(cAlias)
	METHOD getRecNo(cAlias)

	Method SetOptional()
	Method IsOptional()
	Method IsFilled()
	Method RemoveField()

	Method GetOwner()
	Method GetChildClass()

	Method setParam()
	Method getParam()

	Method SetRelMemos()
	Method addField()

	//METODOS PRIVADOS
	//--

	//ATRIBUTOS PUBLICOS
	//--

	//ATRIBUTOS PRIVADOS
	DATA aMemory  AS Array INIT {}
	DATA aStruct AS Array INIT {}
	DATA aUnique AS Array INIT {}
	DATA aAlias AS Array INIT {}
	DATA aAliasGRID AS Array INIT {}
	DATA aIndex AS Array INIT {}
	DATA aRecNo AS Array INIT {}
	DATA aHeader AS Array INIT {}
	DATA aCols AS Array INIT {}
	DATA aRelation AS Array INIT {}
	DATA aNoDelete AS Array INIT {}
	DATA aFilled AS Array INIT {}
	DATA aOptional AS Array INIT {}
	DATA aChild 	As Array Init {} //armazena filhos: {tabela, classe, registros (objetos instanciados)}
	DATA aParams As Array Init {}
	DATA aRelMemos As Array Init {} // Armazena os campos de controle de memo que são relacionados -
	                                // Código e Descrição (Posteriomente o frame adciona o conteudo atual do código no array )
	DATA oOwner

ENDCLASS

//---------------------------------------------------------------------
/*/{Protheus.doc} New
Método inicializador da classe.

@author Felipe Nathan Welter
@author Vitor Emanuel Batista
@since 22/06/2012
@version P12
@return Nil
/*/
//---------------------------------------------------------------------
METHOD New(oOwner) CLASS NGFWStruct

	::aMemory    := {}
	::aStruct    := {}
	::aUnique    := {}
	::aAlias     := {}
	::aAliasGrid := {}
	::aIndex     := {}
	::aRecNo     := {}
	::aHeader    :=	{}
	::aCols      :=	{}
	::aRelation  := {}
	::aNoDelete  := {}
	::aFilled    := {}
	::aOptional  := {}
	::oOwner     := oOwner
	::aChild     := {}
	::aParams    := {}
	::aRelMemos  := {}

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} setAlias
Método para identificar a Alias que sera utilizada, carregando a
estrutura inteira da tabela.

@param cAlias Alias a ser carregado na estrutura.
@param aUseFields [opcional, default={}] Campos a considerar no carregamento.
@author Felipe Nathan Welter
@author Vitor Emanuel Batista
@since 22/06/2012
@version P12
@return Nil
/*/
//---------------------------------------------------------------------
METHOD setAlias(cAlias,aUseFields) CLASS NGFWStruct

	Local nX         := 0
	Local aPK        := {}
	Local aIndexList := {}
	Local aFields    := {}
	Local cX2Unico   := ""
	Local aNgHeader  := {}
	Local nTamTot    := 0
	Local nInd       := 0

	Default aUseFields := {}

	paramtype 0 var cAlias as character

	//------------------------------------
	// Verifica se Alias ja foi carregada
	//------------------------------------
	If aScan(::aAlias,cAlias) == 0
		aAdd(::aAlias,cAlias)

		aFields := {}

		//-------------------------------------------
		// Carrega estrutura e inicializa no aStruct
		//-------------------------------------------
		aNgHeader := NGHeader( cAlias ) // Buscar os campos das tabela.
		nTamTot := Len(aNgHeader)
		For nInd := 1 To nTamTot

			aFields := {}

			If ( Empty(aUseFields) .and. asCan(aUseFields, {|x| x == AllTrim(aNgHeader[nInd, 2])}) != 0 ) .Or.;
					aNgHeader[nInd,10] != "V"

				aAdd(::aStruct,Array(13))

				aTail(::aStruct)[ARQUIVO_STRUCT] := Posicione("SX3", 2, aNgHeader[nInd, 2], "X3_ARQUIVO")
				aTail(::aStruct)[  CAMPO_STRUCT] := AllTrim(aNgHeader[nInd, 2])
				aTail(::aStruct)[   TIPO_STRUCT] := aNgHeader[nInd, 8]
				aTail(::aStruct)[TAMANHO_STRUCT] := aNgHeader[nInd, 4]
				aTail(::aStruct)[DECIMAL_STRUCT] := aNgHeader[nInd, 5]
				aTail(::aStruct)[ TITULO_STRUCT] := aNgHeader[nInd, 1]
				aTail(::aStruct)[DESCRIC_STRUCT] := Posicione("SX3", 2, aNgHeader[nInd, 2], "X3Descric()")
				aTail(::aStruct)[PICTURE_STRUCT] := aNgHeader[nInd, 3]
				aTail(::aStruct)[CONTEXT_STRUCT] := aNgHeader[nInd, 10]
				aTail(::aStruct)[OBRIGAT_STRUCT] := If(X3OBRIGAT(aNgHeader[nInd, 2]),"S","N")
				aTail(::aStruct)[  VALID_STRUCT] := aNgHeader[nInd, 6]
				aTail(::aStruct)[VLDUSER_STRUCT] := Posicione("SX3", 2, aNgHeader[nInd, 2], "X3_VLDUSER")
				aTail(::aStruct)[   CBOX_STRUCT] := Posicione("SX3", 2, aNgHeader[nInd, 2], "X3CBox()")
			EndIf

		Next nInd

		//-------------------------------------------
		// Carrega os indicies da estrutura
		//-------------------------------------------
		dbSelectArea("SIX")
		dbSetOrder(01)
		dbSeek(cAlias)
		While !Eof() .And. SIX->INDICE == cAlias
			aAdd(aIndexList,SIX->CHAVE)
			SIX->(dbSkip())
		EndDo
		aAdd(::aIndex,{cAlias,aIndexList})

		//-------------------------------------------
		// Carrega a chave unica
		//-------------------------------------------
		cX2Unico := Posicione("SX2",1,cAlias,"X2_UNICO")

		aPK := StrTokArr(cX2Unico, '+')
		For nX := 1 To Len( aPK )
			aAdd(aFields,AllTrim(StrTran(SubStr(aPK[nX], At('(',aPK[nX])+1) ,')','')) )
		Next nX

		aAdd(::aUnique,{cAlias,cX2Unico,aFields})

		//-------------------------------------------
		// Inicializa o numero do registro
		//-------------------------------------------
		aAdd(::aRecNo,{cAlias,0})

		aAdd(::aOptional,{cAlias,.F.})
		aAdd(::aFilled	,{cAlias,.F.})
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} getAlias
Retorna array da Alias

@author Felipe Nathan Welter
@author Vitor Emanuel Batista
@since 22/06/2012
@version P12
@return array
/*/
//---------------------------------------------------------------------
METHOD getAlias() CLASS NGFWStruct
Return ::aAlias

//---------------------------------------------------------------------
/*/{Protheus.doc} initFields
Metodo que carrega os campos da estrutura.

@param lInclui indica se e' inclusão (X3_RELACAO) ou não (base de dados)
@author Felipe Nathan Welter
@author Vitor Emanuel Batista
@since 22/06/2012
@version P12
@return Nil
/*/
//---------------------------------------------------------------------
METHOD initFields(lInclui) CLASS NGFWStruct

	Local nAlias    := 0
	Local nMemory   := 0
	Local nX        := 0
	Local nInd      := 0
	Local nTot      := 0
	Local cTable    := ""
	Local cFieldCod := ""
	Local cFieldDes := ""
	Local cValue    := ""

	Default lInclui := .T.

	//--------------------------
	// TODO: EXCLUSIVO PROTHEUS - REMOVER
	//--------------------------
	If Type("TIPOACOM") == "U"
		TIPOACOM := .T.
	EndIf

	If Type("LCORRET") == "U"
		LCORRET := .T.
	EndIf

	If lInclui
		SetInclui()
	ElseIf Type("lAltera") == "U"
		SetAltera()
	EndIf

	//------------------------------------------------------
	// Carrega memoria para todas as Alias pre-definidas
	//------------------------------------------------------
	For nAlias := 1 to Len(::aAlias)

		For nX := 1 To Len(::aStruct)

			If ::aStruct[nX,ARQUIVO_STRUCT] == ::aAlias[nAlias]

				//----------------------------------------------------------
				// Verifica se campo da estrutura esta carregado na memoria
				//----------------------------------------------------------
				cCampoSX3 := ::aStruct[nX,CAMPO_STRUCT]
				cArquivSX3:= Posicione("SX3", 2, ::aStruct[nX,CAMPO_STRUCT], "X3_ARQUIVO")
				cRelacSX3 := Posicione("SX3", 2, ::aStruct[nX,CAMPO_STRUCT], "X3_RELACAO")

				nMemory := aScan(::aMemory,{|a| a[FIELD_MEMORY] == AllTrim(cCampoSX3)})

				If nMemory == 0
					aAdd(::aMemory,Array(TOTAL_MEMORY))

					nMemory := Len(::aMemory)

					::aMemory[nMemory][TABLE_MEMORY] := cArquivSX3
					::aMemory[nMemory][FIELD_MEMORY] := AllTrim( cCampoSX3 )
				EndIf

				//----------------------------------------------------------
				// Se for inclusao carrega Inicializador Padrao
				// Se for alteracao carrega conteudo da tabela
				//----------------------------------------------------------
				If lInclui .Or. ( ::IsOptional( cArquivSX3, cCampoSX3 ) .And. ( cArquivSX3 )->( Eof() ) )
					If "_FILIAL" $ cCampoSX3
						::aMemory[nMemory][VALUE_MEMORY] := xFilial(cArquivSX3)
					Else
						If Empty( cRelacSX3 )
							If ::aStruct[nX][TIPO_STRUCT] == "C"
								::aMemory[nMemory][VALUE_MEMORY] := Space( ::aStruct[nX][TAMANHO_STRUCT] )
							ElseIf ::aStruct[nX][TIPO_STRUCT] == "N"
								::aMemory[nMemory][VALUE_MEMORY] := 0
							ElseIf ::aStruct[nX][TIPO_STRUCT] == "D"
								::aMemory[nMemory][VALUE_MEMORY] := CToD(" / /   ")
							Else
								::aMemory[nMemory][VALUE_MEMORY] := ""
							EndIf
						Else
							::aMemory[nMemory][VALUE_MEMORY] := &(cRelacSX3)
						EndIf
					EndIf
				Else

					If ::aStruct[nX, TIPO_STRUCT] != "M" //Caso seja campo memo, não joga o valor.
						::aMemory[nMemory][VALUE_MEMORY] := &(cArquivSX3 + "->" + cCampoSX3)
					EndIf

				EndIf

			EndIf

		Next nX

		// Validação dos campos memos que são relacionados com Código e Descrição
		nTot := Len(::aRelMemos)
		For nInd := 1 To nTot

			cTable    := ::aAlias[nAlias]
			cFieldCod := ::aRelMemos[nInd, 1] // Campo que representa o código na tabela SYP
			cFieldDes := ::aRelMemos[nInd, 2] // Campo memo que representa a descrição

			If FWTabPref(cFieldCod) == cTable .And. FWTabPref(cFieldDes) == cTable // Garante que os campos são da mesma tabela

				nMemory := aScan(::aMemory,{|a| a[FIELD_MEMORY] == AllTrim(cFieldDes)}) // Verifica a posição do campo de descrição
				If nMemory > 0
					cValue                           := ::GetValue(cFieldCod) // Busca o valor do código
					::aRelMemos[nInd, 3]             := cValue                // Grava o código atual para utilizar em possiveis alterações
					::aMemory[nMemory, VALUE_MEMORY] := MsMM(cValue)          // Busca a descrição na tabela SYP
				EndIf

			EndIf

		Next nInd

		//----------------------------------------------------------
		// Carrega o numero do registro (quando nao for inclusão)
		//----------------------------------------------------------
		If !lInclui
			::SetRecNo(::aAlias[nAlias], &(::aAlias[nAlias]+"->(RecNo())") )
		EndIf

	Next nAlias


Return Nil
//---------------------------------------------------------------------
/*/{Protheus.doc} memoryToClass
Metodo para carregar conteudo da memoria de trabalho para a estrutura
da classe.

@author Felipe Nathan Welter
@author Vitor Emanuel Batista
@since 22/06/2012
@version P12
@return Nil
/*/
//---------------------------------------------------------------------
Method memoryToClass() Class NGFWStruct

	Local nAlias, cFieldName, nMemory, xContent, nAliasPos, aRelatAux
	Local cFunType := "Type"
	Local aNgHeader:= {}
	Local nTamTot  := 0
	Local nInd     := 0
	Local cCampoSX3, cArquivSX3, cCBoxSX3, cRelacSX3

	//------------------------------------------------------
	// Carrega memoria para todas as Alias pre-definidas
	//------------------------------------------------------
	For nAlias := 1 to Len(::aAlias)

		aRelatAux := ::GetRelation( ::aAlias[nAlias] )

		aNgHeader := NGHeader( ::aAlias[nAlias] ) // Buscar os campos das tabela.
		nTamTot := Len(aNgHeader)
		For nInd := 1 To nTamTot

			cCampoSX3 := aNgHeader[nInd, 2]
			cArquivSX3:= Posicione("SX3", 2, aNgHeader[nInd, 2], "X3_ARQUIVO")
			cCBoxSX3  := Posicione("SX3", 2, aNgHeader[nInd, 2], "X3CBox()")
			cRelacSX3 := Posicione("SX3", 2, aNgHeader[nInd, 2], "X3_RELACAO")

			//--------------------------------------------------------------------
			// Garante que memoria foi inicializada para ser carregada no aMemory
			//--------------------------------------------------------------------
			If &cFunType.("M->"+AllTrim(cCampoSX3)) <> "U"

				cFieldName := AllTrim(cCampoSX3)

				//----------------------------------------------------------
				// Verifica se campo da estrutura esta carregado na memoria
				//----------------------------------------------------------
				nMemory := aScan(::aMemory,{|a| a[FIELD_MEMORY] == cFieldName})

				//-------------------------------------------------------------------
				// Se nao estiver, cria estrutura na array aMemory, senao reutiliza
				//-------------------------------------------------------------------
				If nMemory == 0
					 aAdd(::aMemory,Array(TOTAL_MEMORY))
					 nMemory := Len(::aMemory)
				EndIf

				xContent := &("M->" + cCampoSX3)

				If aScan( aRelatAux , {|x| Trim(x[1]) == cFieldName }) == 0
					//Indica que foi preenchido o cadastro
					If .Not. Empty( xContent ) .And. Empty( cRelacSX3 ) .And. Empty( cCBoxSX3 )
						nAliasPos := aScan( ::aFilled , {|x| x[1] == cArquivSX3 } )
						::aFilled[nAliasPos][2] := .T.
		 			EndIf
	 			EndIf

				::aMemory[nMemory][TABLE_MEMORY] := cArquivSX3
				::aMemory[nMemory][FIELD_MEMORY] := cFieldName
				::aMemory[nMemory][VALUE_MEMORY] := xContent

			EndIf

		Next nInd


	Next nAlias

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} SubModel
Metodo para carregar conteudo do sub model para a estrutura da classe.

@author NG Informática Ltda.
@since 10/11/2014
@version P12
@return Nil
/*/
//---------------------------------------------------------------------
Method SubModel( oAuxModel ) Class NGFWStruct

	Local nAlias, xContent, nMemory, cFieldName, aRelatAux, nAliasPos
	Local cAlias    := oAuxModel:oFormModelStruct:aTable[1]
	Local oStruct   := oAuxModel:GetStruct()
	Local aCampos   := oStruct:GetFields()
	Local aNgHeader := {}
	Local nTamTot   := 0
	Local nInd      := 0
	Local cArquivSX3:= ""
	Local cCBoxSX3  := ""
	Local cRelacSX3 := ""

	nAlias := aScan(::aAlias,{|x| x == cAlias})
	If nAlias > 0

		::SetRelation( cAlias , oAuxModel:aRelation )
		aRelatAux := ::GetRelation( cAlias )

		aNgHeader := NGHeader( cAlias ) // Buscar os campos das tabela.
		nTamTot := Len(aNgHeader)
		For nInd := 1 To nTamTot

			cArquivSX3:= Posicione("SX3", 2, aNgHeader[nInd, 2], "X3_ARQUIVO")
			cCBoxSX3  := Posicione("SX3", 2, aNgHeader[nInd, 2], "X3CBox()")
			cRelacSX3 := Posicione("SX3", 2, aNgHeader[nInd, 2], "X3_RELACAO")

			cFieldName := AllTrim(aNgHeader[nInd, 2])

			If aScan(aCampos,{|x| AllTrim( x[3] )== cFieldName } ) != 0

				//----------------------------------------------------------
				// Verifica se campo da estrutura esta carregado na memoria
				//----------------------------------------------------------
				nMemory := aScan(::aMemory,{|a| a[FIELD_MEMORY] == cFieldName})

				//-------------------------------------------------------------------
				// Se nao estiver, cria estrutura na array aMemory, senao reutiliza
				//-------------------------------------------------------------------
				If nMemory == 0
					aAdd(::aMemory,Array(TOTAL_MEMORY))
					nMemory := Len(::aMemory)
				EndIf

				nPosField := aScan( aRelatAux , {|x| Trim(x[1]) == cFieldName })
				If '_FILIAL' $ cFieldName
					xContent := xFilial( cArquivSX3 )
				ElseIf nPosField > 0
					xContent := fContent( aRelatAux[nPosField][2] , Self )
				Else
					xContent := oAuxModel:GetValue(cFieldName)

					//Indica que foi preenchido o cadastro
					If .Not. Empty( xContent ) .And. Empty( cRelacSX3 ) .And. Empty( cCBoxSX3 )
						nAliasPos := aScan( ::aFilled , {|x| x[1] == cAlias } )
						::aFilled[nAliasPos][2] := .T.
					EndIf

				EndIf

				::aMemory[nMemory][TABLE_MEMORY] := cAlias
				::aMemory[nMemory][FIELD_MEMORY] := cFieldName
				::aMemory[nMemory][VALUE_MEMORY] := xContent
			EndIf

		Next nInd

		::SetRecNo( cAlias , oAuxModel:nDataId )

	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} classToMemory
Carrega as informacoes da estrutura para a memoria de trabalho.

@author Felipe Nathan Welter
@since 13/02/2013
@version P12
@return Nil
/*/
//---------------------------------------------------------------------
Method classToMemory() Class NGFWStruct

	Local nX

	For nX := 1 To Len(::aMemory)
		_SetNamedPrvt(::aMemory[nX][FIELD_MEMORY],::aMemory[nX][VALUE_MEMORY],ProcName(2))
	Next nX

Return Nil


//---------------------------------------------------------------------
/*/{Protheus.doc} setValue
Carrega informacao em um campo especifico da estrutura de dados.

@param cField Campo da estrutura de dados a ser atualizado
@param xValue Conteúdo para o campo
@param [aKey] indica a chave do registro a ser atualizado no formato {{campo,conteudo}..}
@author Felipe Nathan Welter
@author Vitor Emanuel Batista
@since 13/02/2013
@version P12
@return Nil
@sample oObj:setValue("CAMPO",xConteudo)
@sample oObj:setValue("CAMPO",xConteudo,{{'CHAVE_CAMPO','CHAVE_CONTEUDO'},..})
/*/
//---------------------------------------------------------------------
Method setValue(cField,xValue,aKey) Class NGFWStruct

	Local nX, nY
	Local nMemory

	Local cAliasChild
	Local nAlias, oChild
	Local nHeader, aHeaderAux, nPosField, nCols
	Local aUnique, aRelation, nChildLine, cFieldKey, nFieldKey, nPosKey

	Local aChildKey := {}
	Local lFound    := .F.

	If Empty(aKey)

		//--------------------------------------------------------------------------
		// Classe pai - atualiza direto aMemory
		//--------------------------------------------------------------------------
		nMemory := aScan(::aMemory,{|a| a[FIELD_MEMORY] == AllTrim(cField)})
		If nMemory > 0

			If ::aMemory[nMemory][VALUE_MEMORY] != xValue

				::aMemory[nMemory][VALUE_MEMORY] := xValue
			EndIf
		EndIf

	Else
		//--------------------------------------------------------------------------
		// Classe filho
		//--------------------------------------------------------------------------

		//primeiro procura se campo a atualizar existe no aHeader e qual é o aHeader dentro de self:aHeader (nHeader)
		For nHeader := 1 To Len( ::aHeader )
			aHeaderAux := aClone( ::aHeader[nHeader][2] )
			nPosField  := aScan(aHeaderAux,{|a| a[CAMPO_HEADER] == AllTrim(cField)})
			If nPosField > 0
				Exit
			EndIf
		Next

		If nPosField > 0

			//carrega chave unica da tabela e o relacao (relacionamento entre pai e filho)
			cAliasChild := ::aHeader[nHeader][1]
			aUnique     := ::GetUnique( cAliasChild )
			aRelation   := ::GetRelation( cAliasChild )

			//----------------------------------------------------------------------
			//identifica quais campos não tem preenchimento automatico pelo relacao,
			//pois a busca da chave deve considerar somente esses campos, assim o
			//usuário nao precisa enviar todos em aKey
			//----------------------------------------------------------------------
			For nX := 1 To Len( aUnique )

				//Campo da chave a ser verificado
				cFieldKey := AllTrim( aUnique[nX] )
				nFieldKey := aScan( aRelation , {|x| Trim(x[1]) == cFieldKey })

				//Campos unicos do relacionameto
				If nFieldKey == 0
					aAdd( aChildKey, cFieldKey )
				EndIf
			Next

			If !Empty( ::GetChildClass( cAliasChild ) )

				//--------------------------------------------------------------------------
				// Classe filho - atualiza objeto aChild
				//--------------------------------------------------------------------------
				nAlias := aScan( ::aChild , {|x| x[1] == cAliasChild } )

				If nAlias > 0

					If Len( ::aChild[nAlias][3] ) > 0

						//percorre cada objeto para identificar o que possui a chave correspondente
						For nX := 1 To Len( ::aChild[nAlias][3] )
							oChild := ::aChild[nAlias][3][nX]

							//testa campo a campo da chave
							For nY := 1 To Len(aKey)

								lFound := ( oChild:GetValue( aKey[ nY, 1 ] ) == aKey[ nY, 2 ] )

								If !lFound
									Exit
								EndIf

							Next nY

							If lFound
								Exit  //encontrou o objeto que deve ser alterado
							EndIf

						Next nX

						If lFound
							//não permite realizar a alteração de campos chave
							If asCan(aUnique, {|x| AllTrim(x) == AllTrim(cField) }) == 0
								oChild:SetValue( cField, xValue )
							Else

								// Tentativa de atualizar campo chave ( XXXXXX ) para XXXX
								ExUserException( STR0001 + cField + STR0002 + cAliasChild )

							EndIf
						EndIf

					EndIf
				EndIf

			Else
				//--------------------------------------------------------------------------
				// Classe filho - atualiza aCols
				//--------------------------------------------------------------------------

				//identifica qual posição do self:aCols contem registros da tabela
				nCols := aScan( ::aCols , {|x| x[1] == cAliasChild })
				//----------------------------------------------------------------------
				//verifica cada registro carregado no aCols da classe para identificar
				//qual tem a chave enviada, é o registro a ser alterado (faz tipo dbseek)
				//----------------------------------------------------------------------
				For nChildLine := 1 To Len(::aCols[nCols][2]) //percorre todos os registros da tabela

					lFound := .F.
					For nX := 1 To Len(aChildKey) //verifica campo a campo da chave

						//só usa o campo da chave se estiver dentro do parâmetro aKey (onde está o conteúdo a ser pesquisado)
						nPosKey := aScan(aKey,{|a| a[1] == AllTrim( aChildKey[nX] )})
						If nPosKey > 0

							nField := aScan(aHeaderAux,{|a| a[CAMPO_HEADER] == AllTrim( aChildKey[nX] )})
							lFound := ::aCols[nCols][2][nChildLine][nField] == aKey[nPosKey][2]

							If !lFound
								Exit //se nao achou a chave, pula para o próximo registro aCols
							EndIf
						EndIf

					Next nX

					If lFound
						Exit  //encontrou o registro que deve ser alterado
					EndIf

				Next nChildLine

				If lFound
					//tratamentos especificos conforme o tipo do campo
					If ::aHeader[nHeader][2][nPosField][TIPO_HEADER] == "C"
						xValue := SubStr(xValue,1,::aHeader[nHeader][2][nPosField][TAMANHO_HEADER])
					EndIf
					//atualiza campo
					::aCols[nCols][2][nChildLine][nPosField] := xValue
				EndIf

			EndIf // objeto child ou acols
		EndIf // nposfield
	EndIf // classe pai ou filho

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} getValue
Retorna o conteúdo de um campo da estrutura de dados.

@param cField Campo da estrutura de dados.
@author Felipe Nathan Welter
@author Vitor Emanuel Batista
@since 13/02/2013
@version P12
@return xValue Conteúdo do campo.
/*/
//---------------------------------------------------------------------
METHOD getValue(cField) Class NGFWStruct
	Local nMemory

	paramtype 0 var cField as character

	nMemory := aScan(::aMemory,{|a| a[FIELD_MEMORY] == AllTrim(cField)})

	If nMemory == 0
		
		// GetValue error: 
		ExUserException( STR0003 + cField )

	EndIf

Return ::aMemory[nMemory][VALUE_MEMORY]

//---------------------------------------------------------------------
/*/{Protheus.doc} setUniqueField
Referencia um campo como "não-alterável" na estrutura do objeto.

@param cField Nome do campo na estrutura.
@author Felipe Nathan Welter
@since 25/04/2013
@version P12
@return lAdded Indica se o campo foi adicionado ou não.
@sample oObj:setUniqueField("CAMPO")
@obs Sempre manter compatíveis as regras de campos não-alteráveis com
     as regras de negócio definidas em validBusiness. Ex: aplicar regras
     de validação de contador na -alteração- de um registro de histórico
     de movimentação de bens (TPN) sendo que não é possível alterá-lo.
/*/
//---------------------------------------------------------------------
METHOD setUniqueField(cField) Class NGFWStruct
	Local lAdded := .F.
	Local nPos := 0

	nPos := asCan(::aStruct, { |x| x[CAMPO_STRUCT] == cField} )

	If nPos > 0
		nPos := asCan(::aUnique, { |x| x[1] == ::aStruct[nPos,ARQUIVO_STRUCT] })
		If nPos > 0
			If asCan(::aUnique[nPos,3], { |x| x == cField }) == 0
				aAdd(::aUnique[nPos,3],cField)
				lAdded := .T.
			EndIf
		EndIf
	EndIf

Return lAdded

//---------------------------------------------------------------------
/*/{Protheus.doc} getStruct
Retorna array com a estrutura.

@author Felipe Nathan Welter
@author Vitor Emanuel Batista
@since 22/06/2012
@version P12
@return array
/*/
//---------------------------------------------------------------------
METHOD getStruct() Class NGFWStruct
Return ::aStruct

//---------------------------------------------------------------------
/*/{Protheus.doc} getUnique
Retorna array com as chaves únicas.

@author Felipe Nathan Welter
@since 24/04/2013
@version P12
@return array
/*/
//---------------------------------------------------------------------
METHOD getUnique( cAlias , lKey ) Class NGFWStruct

	Local nUnique := 0
	Local xUniqueAux := {}

	Default lKey := .F.

	If ValType( cAlias ) == 'C'
		nUnique := aScan( ::aUnique , {|x| x[1] == cAlias })
		If nUnique > 0
			If lKey
				//Chave de unica concatenada
				xUniqueAux := ::aUnique[nUnique][2]
			Else
				// Array de campo da chave unica
				xUniqueAux := aClone( ::aUnique[nUnique][3] )
			EndIf
		EndIf
	Else
		xUniqueAux := aClone( ::aUnique )
	EndIf

Return xUniqueAux

//---------------------------------------------------------------------
/*/{Protheus.doc} getMemory
Retorna array com o conteudo na memoria da classe.

@author Felipe Nathan Welter
@author Vitor Emanuel Batista
@since 22/06/2012
@version P12
@return array
/*/
//---------------------------------------------------------------------
METHOD getMemory() Class NGFWStruct
Return ::aMemory

//---------------------------------------------------------------------
/*/{Protheus.doc} getMemory
Retorna array com os indices da classe.

@author Felipe Nathan Welter
@author Vitor Emanuel Batista
@since 18/02/2013
@version P12
@return array
/*/
//---------------------------------------------------------------------
METHOD getIndex() Class NGFWStruct
Return ::aIndex

//---------------------------------------------------------------------
/*/{Protheus.doc} setRecNo
Seta o RecNo() de um alias especificado.

@param cAlias [opcional] Alias especificado para retornar o RecNo()
@param nRecNo RecNo()
@author Felipe Nathan Welter
@since 19/02/2013
@version P12
@return nRecNo
/*/
//---------------------------------------------------------------------
METHOD setRecNo(cAlias,nRecNo) Class NGFWStruct
	Local nPos := 0
	Default cAlias := Alias()
	Default nRecNo := (Alias())->(RecNo())
	nPos := asCan(::aRecNo,{|x| x[1] == cAlias })
	If nPos > 0
		::aRecNo[nPos][2] := nRecNo
	EndIf
Return nRecNo

//---------------------------------------------------------------------
/*/{Protheus.doc} getRecNo
Retorna o RecNo() de um alias especificado, ou o alias atual por default.

@param cAlias Alias especificado para retornar o RecNo()
@author Felipe Nathan Welter
@since 19/02/2013
@version P12
@return nRecNo
/*/
//---------------------------------------------------------------------
METHOD getRecNo(cAlias) Class NGFWStruct
	Local nPos := 0
	Default cAlias := Alias()
	nPos := asCan(::aRecNo,{|x| x[1] == cAlias })
	If nPos > 0
		nPos := ::aRecNo[nPos][2]
	EndIf
Return nPos

//---------------------------------------------------------------------
/*/{Protheus.doc} setAlias
Método para identificar a Alias de Grid que sera utilizada, carregando a
estrutura inteira da tabela.

@param cAlias Alias a ser carregado na estrutura.
@param aUseFields [opcional, default={}] Campos a considerar no carregamento.
@author NG Informática Ltda.
@since 22/06/2012
@version P12
@return Nil
/*/
//---------------------------------------------------------------------
METHOD setAliasGrid(cAlias,aUseFields) CLASS NGFWStruct

	Local nX         := 0
	Local aPK        := {}
	Local aIndexList := {}
	Local aHeaderAux := {}
	Local aFields    := {}
	Local cX2Unico   := ""
	Local aNgHeader  := {}
	Local nTamTot    := 0
	Local nInd       := 0

	Default aUseFields := {}

	paramtype 0 var cAlias as character

	//------------------------------------
	// Verifica se Alias ja foi carregada
	//------------------------------------
	If aScan(::aAliasGrid,cAlias) == 0
		aAdd(::aAliasGrid,cAlias)

		aFields := {}

		aAdd( ::aHeader , { cAlias , {} } )

		//-------------------------------------------
		// Carrega estrutura e inicializa no aStruct
		//-------------------------------------------
		aNgHeader := NGHeader( cAlias ) // Buscar os campos das tabela.
		nTamTot := Len(aNgHeader)
		For nInd := 1 To nTamTot

			aFields := {}

			If ( Empty(aUseFields) .and. asCan(aUseFields, {|x| x == AllTrim(aNgHeader[nInd, 2])}) != 0 ) .Or.;
					aNgHeader[nInd,10] != "V"

				aHeaderAux := Array( 13 )
				aHeaderAux[ TITULO_HEADER] := Posicione("SX3", 2, aNgHeader[nInd, 2], "X3Titulo()")
				aHeaderAux[  CAMPO_HEADER] := AllTrim(aNgHeader[nInd, 2])
				aHeaderAux[PICTURE_HEADER] := aNgHeader[nInd, 3]
				aHeaderAux[TAMANHO_HEADER] := aNgHeader[nInd, 4]
				aHeaderAux[DECIMAL_HEADER] := aNgHeader[nInd, 5]
				aHeaderAux[  VALID_HEADER] := aNgHeader[nInd, 6]
				aHeaderAux[  USADO_HEADER] := aNgHeader[nInd, 7]
				aHeaderAux[   TIPO_HEADER] := aNgHeader[nInd, 8]
				aHeaderAux[     F3_HEADER] := aNgHeader[nInd, 9]
				aHeaderAux[CONTEXT_HEADER] := aNgHeader[nInd, 10]
				aHeaderAux[   CBOX_HEADER] := Posicione("SX3", 2, aNgHeader[nInd, 2], "X3CBox()")
				aHeaderAux[RELACAO_HEADER] := Posicione("SX3", 2, aNgHeader[nInd, 2], "X3_RELACAO")
				aHeaderAux[   WHEN_HEADER] := Posicione("SX3", 2, aNgHeader[nInd, 2], "X3_WHEN")

				aAdd( aTail(::aHeader)[2] , aHeaderAux )

			EndIf

		Next nInd

		//-------------------------------------------
		// Carrega os indicies da estrutura
		//-------------------------------------------
		dbSelectArea("SIX")
		dbSetOrder(01)
		dbSeek(cAlias)
		While !Eof() .And. SIX->INDICE == cAlias
			aAdd(aIndexList,SIX->CHAVE)
			SIX->(dbSkip())
		EndDo
		aAdd(::aIndex,{cAlias,aIndexList})

		//-------------------------------------------
		// Carrega a chave unica
		//-------------------------------------------
		cX2Unico := Posicione("SX2",1,cAlias,"X2_UNICO")

		aPK := StrTokArr(cX2Unico,'+')
		For nX := 1 To Len(aPK)
			aAdd(aFields,AllTrim(StrTran(SubStr(aPK[nX], At('(',aPK[nX])+1) ,')','')))
		Next nX

		aAdd(::aUnique,{cAlias,cX2Unico,aFields})

		//-------------------------------------------
		// Inicializa o numero do registro
		//-------------------------------------------
		aAdd(::aRecNo,{cAlias,0})

	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} memoryToClass
Metodo para carregar conteudo da grid para a estrutura da classe.

@author NG Informática Ltda.
@since 10/11/2014
@version P12
@return Nil
/*/
//---------------------------------------------------------------------
Method gridToClass( oAuxModel ) Class NGFWStruct

	Local cAlias

	If ValType( oAuxModel:oFormModelStruct:aTable[1] ) == 'C'

		cAlias := oAuxModel:oFormModelStruct:aTable[1]

		::SetAliasGrid( cAlias )
		::SetRelation( cAlias , oAuxModel:aRelation )
		//::SetUnique( cAlias , oAuxModel:aUnique )
		::SetHeader( cAlias , oAuxModel:aHeader )
		::SetCols( cAlias , oAuxModel:aCols )

	EndIf

Return Nil

//--------------------------------------------------------------------
/*/{Protheus.doc} setaHeader
Metodo para carregar conteudo do Header da grid para a estrutura
da classe.

@author NG Informática Ltda.
@since 28/10/2014
@version P12
@return Nil
/*/
//--------------------------------------------------------------------
Method setHeader( cAlias , aGrid ) Class NGFWStruct

	Local nPos := 0

	nPos := aScan( ::aHeader , {|x| x[1] == cAlias })

	If nPos > 0
		::aHeader[nPos] := { cAlias , aClone( aGrid ) }
	Else
		aAdd( ::aHeader , { cAlias , aClone( aGrid ) } )
	EndIf

Return Nil

//--------------------------------------------------------------------
/*/{Protheus.doc} setaCols
Metodo para carregar conteudo do aCols da grid para a estrutura
da classe.

@author NG Informática Ltda.
@since 28/10/2014
@version P12
@return Nil
/*/
//--------------------------------------------------------------------
Method setCols( cAlias , aGrid ) Class NGFWStruct

	Local nPos := 0

	nPos := aScan( ::aCols , {|x| x[1] == cAlias })

	If nPos > 0
		::aCols[nPos] := { cAlias , aClone( aGrid ) }
	Else
		aAdd( ::aCols , { cAlias , aClone( aGrid ) } )
	EndIf

Return Nil

//--------------------------------------------------------------------
/*/{Protheus.doc} setRelation
Metodo para carregar relacionamento da grid para a estrutura
da classe.

@author NG Informática Ltda.
@since 28/10/2014
@version P12
@return Nil
/*/
//--------------------------------------------------------------------
Method setRelation( cAlias , aRelation ) Class NGFWStruct

	Local nPos := 0

	nPos := aScan( ::aRelation , {|x| x[1] == cAlias })

	If nPos > 0
		::aRelation[nPos] := { cAlias , aRelation }
	Else
		aAdd( ::aRelation , { cAlias , aRelation } )
	EndIf

Return Nil

//--------------------------------------------------------------------
/*/{Protheus.doc} setNoDelete
Metodo que define quais tabelas não são relacionadas aos alias
carregados na clase, assim, no momento da exclusão tais registros
relacionados que são pertinentes as tableas definidas serão
desconsiderados

@author NG Informática Ltda.
@since 28/10/2014
@version P12
@return Nil
/*/
//--------------------------------------------------------------------
Method setNoDelete( cAlias ) Class NGFWStruct

	If aScan(::aNoDelete , cAlias ) == 0
		aAdd(::aNoDelete , cAlias )
	EndIf

Return Nil

//--------------------------------------------------------------------
/*/{Protheus.doc} getNoDelete
Retorna array com as tabelas não relacionadas

@author NG Informática Ltda.
@since 28/10/2014
@version P12
@return array
/*/
//--------------------------------------------------------------------
METHOD getNoDelete() Class NGFWStruct
Return ::aNoDelete

//--------------------------------------------------------------------
/*/{Protheus.doc} setRelation
Metodo para carregar o unico da grid para a estrutura da classe.

@author NG Informática Ltda.
@since 28/10/2014
@version P12
@return Nil
/*/
//--------------------------------------------------------------------
Method setUnique( cAlias , aUnique ) Class NGFWStruct

	Local nPos     := 0
	Local aArea    := GetArea()
	Local cX2Unico := Posicione("SX2",1,cAlias,"X2_UNICO")

	nPos := aScan(::aUnique,{|x| x[1] == cAlias })
	If nPos > 0
		::aUnique[nPos] := {cAlias,cX2Unico,aUnique}
	Else
		aAdd(::aUnique,{cAlias,cX2Unico,aUnique})
	EndIf

	RestArea( aArea )

Return Nil

//--------------------------------------------------------------------
/*/{Protheus.doc} getaHeader
Retorna array com o cabeçalho da grid.

@author NG Informática Ltda.
@since 28/10/2014
@version P12
@return array
/*/
//--------------------------------------------------------------------
METHOD getAliasGrid() Class NGFWStruct
Return ::aAliasGrid

//--------------------------------------------------------------------
/*/{Protheus.doc} getaHeader
Retorna array com o cabeçalho da grid.

@author NG Informática Ltda.
@since 28/10/2014
@version P12
@return array
/*/
//--------------------------------------------------------------------
METHOD getHeader( cAlias ) Class NGFWStruct

	Local nHeader := 0
	Local aHeaderAux := {}

	If ValType( cAlias ) == 'C'
		nHeader := aScan( ::aHeader , {|x| x[1] == cAlias })
		If nHeader > 0
			aHeaderAux := aClone( ::aHeader[nHeader][2] )
		EndIf
	Else
		aHeaderAux := aClone( ::aHeader )
	EndIf

Return aHeaderAux

//--------------------------------------------------------------------
/*/{Protheus.doc} getMemory
Retorna array com o conteudo da grid.

@author NG Informática Ltda.
@since 28/10/2014
@version P12
@return array
/*/
//---------------------------------------------------------------------
METHOD getCols( cAlias ) Class NGFWStruct

	Local nCols := 0
	Local aColsAux := {}

	If ValType( cAlias ) == 'C'
		nCols := aScan( ::aCols , {|x| x[1] == cAlias })
		If nCols > 0
			aColsAux := aClone( ::aCols[nCols][2] )
		EndIf
	Else
		aColsAux := aClone( ::aCols )
	EndIf


Return aColsAux

//---------------------------------------------------------------------
/*/{Protheus.doc} getaRelation
Retorna array com o relacionamento da grid.

@author NG Informática Ltda.
@since 28/10/2014
@version P12
@return array
/*/
//---------------------------------------------------------------------
METHOD getRelation( cAlias ) Class NGFWStruct

	Local nRelation := 0
	Local aRelatAux := {}

	If ValType( cAlias ) == 'C'
		nRelation := aScan( ::aRelation , {|x| x[1] == cAlias })
		If nRelation > 0
			aRelatAux := aClone( ::aRelation[nRelation][2] )
		EndIf
	Else
		aRelatAux := aClone( ::aRelation )
	EndIf

Return aRelatAux

//---------------------------------------------------------------------
/*/{Protheus.doc} SetOptional
Indica se o preenchimento do Alias é opcional

@author NG Informática Ltda.
@since 01/01/2015
/*/
//---------------------------------------------------------------------
Method SetOptional( cAlias ) Class NGFWStruct
	Local nAliasPos
	nAliasPos := aScan( ::aOptional , {|x| x[1] == cAlias} )
	::aOptional[nAliasPos][2] := .T.
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} IsOptional
Retorna se o preenchimento do Alias é opcional
@method

@author NG Informática Ltda
@since 01/01/2015

@param  cAlias , string, tabela que será verificada.
@param  cField , string, campo que acionou a função.
@return boolean, Define se o preenchimento do alias é opcional.
/*/
//---------------------------------------------------------------------
Method IsOptional( cAlias, cField ) Class NGFWStruct
	
	Default cField := ''

	If Empty( cAlias ) 
		
		// Identificado diferença entre dicionário e base de dados referente ao campo: ( XXXX )
		ExUserException( STR0004 +;
			IIf( !Empty( cField ), STR0005 + Trim( cField ) + ' )', '.' ) )

	EndIf

Return ::aOptional[aScan( ::aOptional , { |x| x[1] == cAlias } ),2]

//---------------------------------------------------------------------
/*/{Protheus.doc} IsFilled
Indica se o cadastro foi preenchido

@author NG Informática Ltda.
@since 01/01/2015
/*/
//---------------------------------------------------------------------
Method IsFilled( cAlias ) Class NGFWStruct
	Local nAliasPos
	nAliasPos := aScan( ::aFilled , {|x| x[1] == cAlias} )
Return ::aFilled[nAliasPos][2]

//---------------------------------------------------------------------
/*/{Protheus.doc} RemoveField
Retira o campo da estrutura do Dicionário para não ser validado.

@author Diego de Oliveira
@since 08/08/2019
/*/
//---------------------------------------------------------------------
Method RemoveField( cField ) Class NGFWStruct

	nRemove := aScan( ::aStruct, { |x| x[CAMPO_STRUCT] == cField } )

	//Caso o campo seja encontrado na estrutura do aStruct ele será retirado
	If nRemove > 0
		aDel(::aStruct, nRemove)
		aSize(::aStruct, Len(::aStruct)-1)
	EndIf

Return ::aStruct

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetOwner
Retorna objeto vigente em outra classe

@author Maria Elisandra de Paula
@since 24/05/2018
@version P12
@return objeto or Nil
@sample oObj:GetOwner()
@obs O retorno será um objeto quando tal for definido pelo SetOwner
/*/
//------------------------------------------------------------------------------
Method GetOwner() Class NGFWStruct
Return ::oOwner
//------------------------------------------------------------------------------
/*/{Protheus.doc} GetChildClass
Retorna o nome da classe do Alias

@author NG Informática Ltda.
@since 28/10/2014
@version P12
@return array
/*/
//------------------------------------------------------------------------------
Method GetChildClass( cAlias ) Class NGFWStruct

	Local nClass := 0
	Local cClassName := ''

	nClass := aScan( ::aChild , {|x| x[1] == cAlias })
	If nClass > 0
		cClassName := ::aChild[nClass][2]
	EndIf

Return cClassName

//-------------------------------------------------------------------
/*/{Protheus.doc} SetParam
Método utilizado para centralizar as chamadas do SuperGetMV.

@author Maicon André Pinheiro
@param  cParam, caracter, Código do parâmetro a ser utilizado
@param  xDefault, undefined, Valor Default caso o parâmetro não exista
@since  30/05/2018
@return Nil
/*/
//-------------------------------------------------------------------
Method setParam(cParam, xDefault) Class NGFWStruct

	If aScan(::aParams, {|x| x[1] == cParam} ) == 0
		aAdd(::aParams, {cParam, SuperGetMV(cParam, .F., xDefault)})
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetParam
Retorna o parâmetro solicitado.

@author Maicon André Pinheiro
@param  cParam, caracter, Código do parâmetro a ser utilizado
@since  30/05/2018
@return xContent
/*/
//-------------------------------------------------------------------
Method getParam(cParam) Class NGFWStruct

	Local xContent := Nil
	Local nParam   := 0

	nParam := aScan(::aParams, {|x| x[1] == cParam} )
	If nParam > 0
		xContent := ::aParams[nParam, 2]
	Else

		// Parâmetro ( XXXX ) não declarado para uso.
		ExUserException( STR0006 + cParam + STR0007 )

	EndIf

Return xContent

//-------------------------------------------------------------------
/*/{Protheus.doc} SetRelMemos
Seta quais campos que tem relacionamento de memo para utilizar a tabela
SYP. Os campos devem pertencer a mesma tabela, bem como estarem relacionados a
alguma tabela pai setada no New do objeto.

@author Maicon André Pinheiro
@param  aRelMemos, array, Matriz onde cada array possui duas posições, sendo:
1. Campo código que irá gravar na SYP;
2. Campo memo virtual que irá carregar o conteúdo da descrição da SYP.

@since  07/06/2018
@return Nil
/*/
//-------------------------------------------------------------------
Method setRelMemos(aRelMemos) Class NGFWStruct

	Local nInd   := 0
	Local nTot   := Len(aRelMemos)
	Local aAlias := ::GetAlias()

	For nInd := 1 To nTot

		If FWTabPref(aRelMemos[nInd, 1]) == FWTabPref(aRelMemos[nInd, 2]) .And.; // Garante que os campos são da mesma tabela
		   aScan(::aAlias, FWTabPref(aRelMemos[nInd, 1])) // Garante que os campos pertencem a alguma das tabelas setado no programa

			aAdd(::aRelMemos, {aRelMemos[nInd, 1], aRelMemos[nInd, 2], " "})

			If !fInStruct(aRelMemos[nInd, 1], Self)
				::addField(aRelMemos[nInd, 1])
			EndIf

			If !fInStruct(aRelMemos[nInd, 2], Self)
				::addField(aRelMemos[nInd, 2])
			EndIf

		Else

			// Tabela não existente na estrutura. ( XXXX )
			ExUserException( STR0008 + FWTabPref( aRelMemos[nInd,1] ) + ' )' )

		EndIf

	Next nInd

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} addField


@author Maicon André Pinheiro
@param  cField, caracter, Campo que deve ser adicionado a estrutura.
@since  07/06/2018
@return Nil
/*/
//-------------------------------------------------------------------
Method addField(cField) Class NGFWStruct

	If aScan(::aStruct,{|a| a[CAMPO_STRUCT] == AllTrim(cField)}) == 0

		dbSelectArea("SX3")
		dbSetOrder(2)
		If dbSeek(cField)

			aAdd(::aStruct,Array(SIZE_STRUCT))

			aTail(::aStruct)[ARQUIVO_STRUCT] := Posicione("SX3",2,cField,"X3_ARQUIVO")
			aTail(::aStruct)[  CAMPO_STRUCT] := AllTrim(Posicione("SX3",2,cField,"X3_CAMPO"))
			aTail(::aStruct)[   TIPO_STRUCT] := Posicione("SX3",2,cField,"X3_TIPO")
			aTail(::aStruct)[TAMANHO_STRUCT] := Posicione("SX3",2,cField,"X3_TAMANHO")
			aTail(::aStruct)[DECIMAL_STRUCT] := Posicione("SX3",2,cField,"X3_DECIMAL")
			aTail(::aStruct)[ TITULO_STRUCT] := X3Titulo()
			aTail(::aStruct)[DESCRIC_STRUCT] := X3Descric()
			aTail(::aStruct)[PICTURE_STRUCT] := Posicione("SX3",2,cField,"X3_PICTURE")
			aTail(::aStruct)[CONTEXT_STRUCT] := Posicione("SX3",2,cField,"X3_CONTEXT")
			aTail(::aStruct)[OBRIGAT_STRUCT] := If(X3OBRIGAT(Posicione("SX3",2,cField,"X3_CAMPO")),"S","N")
			aTail(::aStruct)[  VALID_STRUCT] := Posicione("SX3",2,cField,"X3_VALID")
			aTail(::aStruct)[VLDUSER_STRUCT] := Posicione("SX3",2,cField,"X3_VLDUSER")
			aTail(::aStruct)[   CBOX_STRUCT] := X3CBox()

		EndIf

	EndIf

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} fContent
Retorna conteudo de um relacionamento

@param cContent - Conteudo(Campo, função...)
oObj - Objeto do qual será verificado a existencia do campo
@author NG Informática Ltda.
@since 01/01/2015
/*/
//------------------------------------------------------------------------------
Static Function fContent( cContent , oObj )

	Local xContent
	Local aStruct := oObj:GetStruct()

	If aScan( aStruct , { |x| x[CAMPO_STRUCT] == cContent} ) > 0
		xContent := oObj:GetValue( cContent )
	Else
		xContent := &( cContent )
	EndIf

Return xContent

//------------------------------------------------------------------------------
/*/{Protheus.doc} fInStruct
Verificar se o campo faz parte da estrutura

@param cField, caracter, Campo para verificar se está na estrutura
@author Maicon André Pinheiro
@since 11/06/2018
return
/*/
//------------------------------------------------------------------------------
Static Function fInStruct(cField, oObj)
Return aScan(oObj:aStruct,{|a| AllTrim(a[CAMPO_STRUCT]) == AllTrim(cField)}) > 0
