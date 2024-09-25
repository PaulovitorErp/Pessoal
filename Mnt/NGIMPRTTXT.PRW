#Include "Protheus.ch"

#Define _nVersao 01

Function _NGIMPRTTXT()
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIMPRTTXT
Classe para trabalhar com importação de arquivos de texto

@author André Felipe Joriatti
@since 23/10/2013
@version P11
/*/
//---------------------------------------------------------------------

Class NGIMPRTTXT

	Data aFieldPos      As Array
	Data cDir           As String
	Data cFile          As String
	Data cAliasClass    As String
	Data aLinha         As Array
	Data aInsRec        As Array
	Data aDefaults      As Array
	Data aFieldsClass   As Array // Indica todos os campos da tabela que estarão presentes no processo de importação
	Data aMemoFields    As Array
	Data cValidFunction As String
	Data aFieldsEx      As Array
	Data aRegistros     As Array
	Data cSeparador     As String
	Data cInsFunc       As String
	Data nPulaLinha     As Integer Init 0
	Data nIniAnoData    As Integer Init 0
	Data nQtdAnoData    As Integer Init 0
	Data nIniMesData    As Integer Init 0
	Data nQtdMesData    As Integer Init 0
	Data nIniDiaData    As Integer Init 0
	Data nQtdDiaData    As Integer Init 0

	Method New() Constructor
	Method setFieldPos( cField,nPos )
	Method loadPersistence()
	Method setAlias( cAliasClass )
	Method getChvOrd( nOrdem )
	Method getFieldPos( cField )
	Method getInsertRecnos()
	Method setDefaultValue( cField,cDfltVal )
	Method getFieldValue( cField )
	Method addFieldClass( cField )
	Method haveDflVal( cField )
	Method loadMemory()
	Method setDir( cDir )
	Method setFile( cFile )
	Method valueMemo( cField )
	Method MemoFieldPos( cCampo )
	Method setMemoCodField( cCampoCod,cMacroConteudo )
	Method setValidReg( cValFunc )
	Method getValidReg()
	Method setFieldsExAut( aCampos )
	Method getRegistros()
	Method setSeparador( cSep )
	Method setInsFunction( cInsFunction )
	Method setSkip( nPular )
	Method setPosAnoCpoData( nIni,nQtde )
	Method setPosMesCpoData( nIni,nQtde )
	Method setPosDiaCpoData( nIni,nQtde )

EndClass

//---------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da classe usada para gerenciar a importação e 
exportação de dados para uMov.me

@author André Felipe Joriatti
@since 23/10/2013
@version P11
@return NGIMPRTTXT
	Sample: oUmovMe := NGIMPRTTXT():New()
/*/
//---------------------------------------------------------------------

Method New() Class NGIMPRTTXT

	::aFieldPos      := {}
	::cDir           := ""
	::cFile          := ""
	::cAliasClass    := ""
	Self:aLinha      := {}
	::aInsRec        := {}
	::aDefaults      := {}
	::aFieldsClass   := {}
	::aMemoFields    := {}
	::cValidFunction := ".T."
	::aFieldsEx      := {}
	::aRegistros     := {}
	::cSeparador     := ";" // Por padrão separador ';'
	::cInsFunc       := ""
	::nPulaLinha     := 0
	::nIniAnoData    := 0
	::nQtdAnoData    := 0
	::nIniMesData    := 0
	::nQtdMesData    := 0
	::nIniDiaData    := 0
	::nQtdDiaData    := 0

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} New
Método para setar as posições dos campos da tabela segundo os valores
do arquivo importado

@author André Felipe Joriatti
@since 23/10/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Method setFieldPos( cField,nPos ) Class NGIMPRTTXT

	If aScan( ::aFieldPos,{ |x| AllTrim( x[1] ) == AllTrim( cField ) } ) == 0
		aAdd( ::aFieldPos,{ cField,nPos } )
		::addFieldClass( cField )
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} loadPersistence
Método para persistir os dados do arquivo importado na base.

@author André Felipe Joriatti
@since 23/10/2013
@version P11
@return Boolean [1]lRet: indica que obteve sucesso na importação dos dados
		String  [2]cMensagem: indica mensagem de erro
/*/
//---------------------------------------------------------------------

Method loadPersistence() Class NGIMPRTTXT

	Local lRet        := .T.
	Local cLinhaAtu   := ""
	Local cMensagem   := ""
	Local lExecute    := .T.
	Local nI          := 0
	Local nT          := 0
	Local nSaveSX8SQT := GETSX8LEN() // Recupera a quantidade de números atualmente registrados

	If ( nHandle := FT_FUSE( AllTrim( ::cDir + "\" + ::cFile ) ) ) < 1 // Abertura do arquivo de leitura

		lRet := .F.
		cMensagem := "Não foi possível abrir o arquivo"

	Else

		nTot := FT_FLASTREC()
		FT_FGOTOP() // Posiciona na linha de cabeçalho

		// Pula linhas antes de começar a ler o arquivo
		For nI := 1 To ::nPulaLinha
			FT_FSKIP()
		Next nI

		BEGIN TRANSACTION

			nTot := 0

			While !FT_FEOF()

				nTot++

				If Len( FT_FREADLN() ) < 1023

					cLinhaAtu := FT_FREADLN()

				Else
					cLinhaAtu := ""

					lExecute := .T.
					While lExecute

						lExecute  := !( Len( FT_FREADLN() ) < 1023 )
						cLinhaAtu += FT_FREADLN()

					End While

				EndIf

				// Explode a string cLinhaAtu em um array conforme ::cSeparador,
				// não foi usado strtokarr devido mau funcionamento detectado no mesmo..
				Self:aLinha := NGEXPLSTR( cLinhaAtu,::cSeparador )

				// Inicia variáveis de memória da Tabela
				For nI := 1 To Len( ::aFieldsClass )
					&( "M->" + ::aFieldsClass[nI] ) := CriaVar( ::aFieldsClass[nI],.F. )
				Next nI

				// Carrega dados da linha atual e valores default para a memória
				::loadMemory()

				If Len( ::aFieldsEx ) == 0
					DbSelectArea( ::cAliasClass )
					DbSetOrder( 01 )
					If !DbSeek( ::getChvOrd( 01 ) ) .And. &( ::getValidReg() )
					
						If Empty( ::cInsFunc )
	
							RecLock( ::cAliasClass,.T. )
							For nI := 1 To Len( ::aFieldsClass )
								cCampo := AllTrim( ::aFieldsClass[nI] )
		
								If ( ::MemoFieldPos( cCampo ) > 0 ) // Tratamento para campos de código memo
									MSMM( ,80,,::valueMemo( cCampo ),1,,,::cAliasClass,cCampo )
								Else // Demais campos
									&( ::cAliasClass + "->" + cCampo ) := &( "M->" + cCampo )
								EndIf
							Next nI
							MsUnLock( ::cAliasClass )
		
							// Efetiva o consumo dos números que tenham sido reservados pelo processo
							While ( GETSX8LEN() > nSaveSX8SQT )
								CONFIRMSX8()
							End While
						Else
							&( ::cInsFunc ) // Invoca função para inclusão conforme configuração prévia
						EndIf

						aAdd( ::aInsRec,( ::cAliasClass )->( RecNo() ) )

					EndIf
				Else
					aAdd( ::aRegistros,{} )
					For nI := 1 To Len( ::aFieldsEx )
						aAdd( ::aRegistros[Len( ::aRegistros )],{ ::aFieldsEx[nI],&( "M->" + ::aFieldsEx[nI] ),Nil } )
					Next nI
				EndIf

				FT_FSKIP()

			End While

			FT_FUSE() // Fecha arquivo de leitura

		END TRANSACTION

	EndIf

Return { lRet,cMensagem }

//---------------------------------------------------------------------
/*/{Protheus.doc} setAlias
Configura o alias em que a classe vai trabalhar a importação
de registros

@param String cAliasClass: indica o alias de trabalho
@author André Felipe Joriatti
@since 24/10/2013
@version P11
@return Nil, ever Nil
/*/
//---------------------------------------------------------------------

Method setAlias( cAliasClass ) Class NGIMPRTTXT
	::cAliasClass := cAliasClass
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} getChvOrd
Retorna chave conforme a ordem informada, recuperando valores a partir
do array de linha conforme as posições dos campos componentes da chave

@param Int nOrdem: indica a ordem do SIX que se deseja recuperar valores 
do array que contém a linha atual
@author André Felipe Joriatti
@since 24/10/2013
@version P11
@return String cKey: chave conforme a ordem informada
/*/
//---------------------------------------------------------------------

Method getChvOrd( nOrdem ) Class NGIMPRTTXT

	Local cKey       := ""
	Local aCamposChv := {}
	Local nI         := 0

	DbSelectArea( ::cAliasClass )
	DbSetOrder( nOrdem )
	aCamposChv := StrTokArr( ( ::cAliasClass )->( IndexKey() ),"+" )

	For nI := 1 To Len( aCamposChv )
		cKey += PadR( &( "M->" + aCamposChv[nI] ),TAMSX3( AllTrim( aCamposChv[nI] ) )[1] )
	Next nI

Return cKey

//---------------------------------------------------------------------
/*/{Protheus.doc} getFieldPos
Recupera posição do campo na linha atualmente posicionada no arquivo

@param String cField: indica campo que se deseja recuperar posição
do array que contém a linha atual
@author André Felipe Joriatti
@since 24/10/2013
@version P11
@return Int nPos: indica a posição do campo informado no parametro
/*/
//---------------------------------------------------------------------

Method getFieldPos( cField ) Class NGIMPRTTXT

	Local nPos   := 0
	Local nOrdem := 0

	If ( nPos := aScan( ::aFieldPos,{ |x| AllTrim( x[1] ) == AllTrim( cField ) } ) ) > 0
		nOrdem := ::aFieldPos[nPos][2]
	EndIf

Return nOrdem

//---------------------------------------------------------------------
/*/{Protheus.doc} getInsertRecnos
Recupera array com os recnos de todos os registros inseridos

@author André Felipe Joriatti
@since 24/10/2013
@version P11
@return Array aInsRec: indica array de rencnos dos registros inseridos
/*/
//---------------------------------------------------------------------

Method getInsertRecnos() Class NGIMPRTTXT
Return ::aInsRec

//---------------------------------------------------------------------
/*/{Protheus.doc} setDefaultValue
Permite setar um valor padrão para os campos do arquivo que será 
importado, sendo que esse valor será executado com macro substituição.

@param String cField: indica o campo da tabela que irá receber
valor padrão
@param String cDfltVal: indica o valor padrão a ser executado via 
macro substituição na hora de atribuir valor ao campo no novo registro
@author André Felipe Joriatti
@since 24/10/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Method setDefaultValue( cField,cDfltVal ) Class NGIMPRTTXT

	If aScan( ::aDefaults,{ |x| AllTrim( x ) == AllTrim( cField ) } ) == 0
		aAdd( ::aDefaults,{ cField,cDfltVal } )
		::addFieldClass( cField )
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} getFieldValue
Recupera o valor do campo de acordo com a linha atualmente posicionada.
Serve apenas para aqueles campos que não possuam valor default e estão
no próprio arquivo a ser importado

@param String cField: indica o campo que se deseja recuperar o valor.
@author André Felipe Joriatti
@since 28/10/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Method getFieldValue( cField ) Class NGIMPRTTXT
Return Self:aLinha[::getFieldPos( cField )]

//---------------------------------------------------------------------
/*/{Protheus.doc} addFieldClass
Carrega um campo novo no array de campos da classe

@author André Felipe Joriatti
@since 30/10/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Method addFieldClass( cField ) Class NGIMPRTTXT

	If aScan( ::aFieldsClass,{ |x| AllTrim( x ) == AllTrim( cField ) } ) == 0
		aAdd( ::aFieldsClass,AllTrim( cField ) )
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} haveDflVal
Verifica se campo possui valor padrão

@param String cField: indica o campo que se deseja verificar
@author André Felipe Joriatti
@since 30/10/2013
@version P11
@return Integer: position of field in array of default values
/*/
//---------------------------------------------------------------------
Method haveDflVal( cField ) Class NGIMPRTTXT
Return aScan( ::aDefaults,{ |x| AllTrim( x[1] ) == AllTrim( cField ) } )

//---------------------------------------------------------------------
/*/{Protheus.doc} loadMemory
Carrega dados da linha atualmente posicionada para variáveis de memória 
da tabela

@author André Felipe Joriatti
@since 30/10/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Method loadMemory() Class NGIMPRTTXT

	Local cCampo   := ""
	Local xVal     := Nil
	Local cTipoSX3 := ""
	Local nI       := 0
	Local nPosFld  := 0

	// Carrega linha atualmente posicionada na memória
	For nI := 1 To Len( ::aFieldsClass )

		cCampo   := ::aFieldsClass[nI]

		If ::MemoFieldPos( cCampo ) == 0 // Se não existe como campo de código do memo
			xVal     := Nil
			cTipoSX3 := NGSEEKDIC( "SX3",cCampo,02,"SX3->X3_TIPO" )

			If ( nPosFld := ::haveDflVal( cCampo ) ) > 0
				xVal := &( ::aDefaults[nPosFld][2] )
			Else

				Do Case
					Case cTipoSX3 == "D"
						xVal := STOD( SubStr( ::getFieldValue( cCampo ),::nIniAnoData,::nQtdAnoData ) + ; // YYYY
										SubStr( ::getFieldValue( cCampo ),::nIniMesData,::nQtdMesData ) + ; // MM
										SubStr( ::getFieldValue( cCampo ),::nIniDiaData,::nQtdDiaData ) ) // DD

					Case cTipoSX3 == "N"
						xVal := CTON( ::getFieldValue( cCampo ) )
					OtherWise
						xVal := ::getFieldValue( cCampo )
				EndCase

			EndIf

			&( "M->" + ::aFieldsClass[nI] ) := xVal
		EndIf

	Next nI

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} setDir
Configura a propriedade do objeto que contém o diretório de busca do 
arquivo

@param String cDir: indica o caminho do diretório que contém os arquivos
a serem importados
@author André Felipe Joriatti
@since 30/10/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Method setDir( cDir ) Class NGIMPRTTXT
	::cDir := cDir
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} setFile
Configura a propriedade do objeto que armazena o arquivo a ser importado

@param String cFile: indica o nome do arquivo a ser importado
a serem importados
@author André Felipe Joriatti
@since 30/10/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Method setFile( cFile ) Class NGIMPRTTXT
	::cFile := cFile
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} setMemoCodField
Configura um campo como sendo campo de código de memo da SYP

@param String cCampoCod: indica campo de código do memo da SYP
@param String cMacroConteudo: indica conteúdo que será macro 
executado e lançado para SYP
@author André Felipe Joriatti
@since 30/10/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Method setMemoCodField( cCampoCod,cMacroConteudo ) Class NGIMPRTTXT

	If ( aScan( ::aMemoFields,{ |x| AllTrim( x[1] ) == AllTrim( cCampoCod ) } ) == 0 )
		aAdd( ::aMemoFields,{ cCampoCod,cMacroConteudo } )
		::addFieldClass( cCampoCod ) // Adiciona campo no array de campos utilizados pela classe
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MemoFieldPos
Recupera posição do campo no array de campos que recebem código
de SYP

@param String cCampo: indica campo que se deseja recuperar a posição 
@author André Felipe Joriatti
@since 30/10/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Method MemoFieldPos( cField ) Class NGIMPRTTXT
Return aScan( ::aMemoFields,{ |x| AllTrim( x[1] ) == AllTrim( cField ) } )

//---------------------------------------------------------------------
/*/{Protheus.doc} valueMemo
Recupera conteúdo que será colocado na SYP para o campo código de SYP 
informado no parametro

@param String cField: indica campo que se deseja recuperar o conteúdo
macro executado
@author André Felipe Joriatti
@since 30/10/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Method valueMemo( cField ) Class NGIMPRTTXT

	Local nPos   := aScan( ::aMemoFields,{ |x| AllTrim( x[1] ) == AllTrim( cField ) } )
	Local cValue := ""

	If ( nPos > 0 )
		cValue := &( ::aMemoFields[nPos][2] )
	EndIf

Return cValue

//---------------------------------------------------------------------
/*/{Protheus.doc} setValidReg
Configura atributo da classe que armazena o nome da função de validação
de registros a serem importados, essa função será executada para cada 
registro que deve ser importado e dentro dela pode-se usar a memória 
dos campos da tabela que está sendo importada

@param String cValFunc: indica o nome da função
@author André Felipe Joriatti
@since 05/11/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Method setValidReg( cValFunc ) Class NGIMPRTTXT
	::cValidFunction := cValFunc
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} getValidReg
Retorna o nome da função de validação de registros importados

@author André Felipe Joriatti
@since 05/11/2013
@version P11
@return String cValidFunction: indica a função de validação de registros
que será executada por macro substituição
/*/
//---------------------------------------------------------------------

Method getValidReg() Class NGIMPRTTXT
Return ::cValidFunction

//---------------------------------------------------------------------
/*/{Protheus.doc} getRegistros
Retorna array de registros carregados no formato:
{ 
  1º Registro: { { campo,valor },{ campo,valor } },
  2º Registro: { { campo,valor },{ campo,valor } }
}
Para entidades que insiram dados via exec auto

@author André Felipe Joriatti
@since 05/11/2013
@version P11
@return Array aRegistros: indica array de registros
/*/
//---------------------------------------------------------------------

Method getRegistros() Class NGIMPRTTXT
Return ::aRegistros

//---------------------------------------------------------------------
/*/{Protheus.doc} setFieldsExAut
Configura campos que deverão ser retornados para inclusão via execauto

@author André Felipe Joriatti
@since 13/11/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Method setFieldsExAut( aCampos ) Class NGIMPRTTXT
	::aFieldsEx := aClone( aCampos )
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} setSeparador
Configura carácter separador de campos no arquivo de texto
*por padrão o separador de campos da classe é ';'

@param String cSep: indica o separador de campos
@author André Felipe Joriatti
@since 29/11/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Method setSeparador( cSep ) Class NGIMPRTTXT
	::cSeparador := cSep
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} setInsFunction
Configura função de inclusão que será executada para cada linha do 
arquivo.
Para uso dessa funcionalidade é obrigatório configurador a função de 
validação por meio do método setValidReg( cValFunc )

@param String cInsFunction: indica função que será executada para 
inclusão (essa função deve manipular os dados da memória da tabela)
@author André Felipe Joriatti
@since 29/11/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Method setInsFunction( cInsFunction ) Class NGIMPRTTXT
	::cInsFunc := cInsFunction
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} setSkip
Indica quantas linhas deve pular no arquivo antes de começar a ler
as linhas do mesmo, por exemplo setSkip( 1 ) para pular a primeira 
linha (no caso da primeira linha ser a linha de cabeçalho do 
arquivo)

@param Integer nPular: indica quantas linhas deve pular
@author André Felipe Joriatti
@since 29/11/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Method setSkip( nPular ) Class NGIMPRTTXT
	::nPulaLinha := nPular
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} setPosAnoCpoData
Configura as posições de início do valor de ano e total de casas para o 
campo de ano

@param Integer nIni: indica a posição inicial do valor de ano
@param Integer nQtde: indica quantidade de casas ocupadas pelo campo de ano
@author André Felipe Joriatti
@since 29/11/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Method setPosAnoCpoData( nIni,nQtde ) Class NGIMPRTTXT
	::nIniAnoData := nIni
	::nQtdAnoData := nQtde
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} setPosMesCpoData
Configura as posições de início e total para valor de mês no campo de 
data

@param Integer nIni: indica a posição inicial do valor de mês
@param Integer nQtde: indica quantidade de casas ocupadas pelo campo de mês
@author André Felipe Joriatti
@since 29/11/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Method setPosMesCpoData( nIni,nQtde ) Class NGIMPRTTXT
	::nIniMesData := nIni
	::nQtdMesData := nQtde
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} setPosDiaCpoData
Configura as posições de início e total para o valor de dia no campo de data

@param Integer nIni: indica a posição inicial do valor de dia
@param Integer nQtde: indica quantidade de casas ocupadas pelo campo de dia
@author André Felipe Joriatti
@since 29/11/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Method setPosDiaCpoData( nIni,nQtde ) Class NGIMPRTTXT
	::nIniDiaData := nIni
	::nQtdDiaData := nQtde
Return Nil