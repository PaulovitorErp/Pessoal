#Include "Protheus.ch"
#Include "NGFWERROR.CH"

//redefined in frameworkng.ch **************
#DEFINE __VALID_OBRIGAT__  'O'
#DEFINE __VALID_UNIQUE__   'U'
#DEFINE __VALID_FIELDS__   'F'
#DEFINE __VALID_BUSINESS__ 'B'
#DEFINE __VALID_ALL__      'OUFB'
#DEFINE __VALID_NONE__     ''
//******************************************

//------------------------------
// Força a publicação do fonte
//------------------------------
Function _NGFWError()
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NGFWError
Classe responsavel por armazenar uma listagem de erros.

@author Felipe Nathan Welter
@author Vitor Emanuel Batista
@since 22/06/2012
@version P12
/*/
//------------------------------------------------------------------------------
Class NGFWError

	// Metodos Publicos
	Method New() CONSTRUCTOR

	Method getErrorList()
	Method getAskList()
	Method getInfoList()

	// Metodos Privados
	Method addError()
	Method addAsk()
	Method addInfo()
	Method clearList()
	Method msgRequired()

	// Atributos Privados
	Data aError As Array
	Data aAsk   As Array
	Data aInfo  As Array

EndClass

//------------------------------------------------------------------------------
/*/{Protheus.doc} New
Método inicializador da classe.

@author Felipe Nathan Welter
@author Vitor Emanuel Batista
@since 22/06/2012
@version P12
@return Nil
/*/
//------------------------------------------------------------------------------
Method New() Class NGFWError

	::aError := {}
	::aAsk   := {}
	::aInfo  := {}

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} addError
Método que adiciona um erro no objeto.

@param cError Descrição do erro.
@author Felipe Nathan Welter
@author Vitor Emanuel Batista
@since 22/06/2012
@version P12
@obs método chamado nos métodos de validação (validBusiness e afins)
@return Nil
/*/
//------------------------------------------------------------------------------
Method addError(cError) Class NGFWError

	aAdd(::aError,cError)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} addAsk
Método que adiciona uma pergunta yes/no no objeto.

@param cError Descrição da pergunta yes/no.
@author Felipe Nathan Welter
@since 26/09/2017
@version P12
@obs método chamado nos métodos de validação (validBusiness e afins)
@return Nil
/*/
//------------------------------------------------------------------------------
Method addAsk(cAsk) Class NGFWError

	aAdd(::aAsk,cAsk)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} addInfo
Método que adiciona uma mensagem de processamento na classe, que pode ser
acessada após a finalização do upsert no programa chamador. Exemplo é a geração
de um registro e retorno de mensagem com seu código, ou uma lista de log
do processamento realizado.

@param cInfo, caracter, Descrição de mensagens informativas.
@author Maicon André Pinheiro
@since  11/06/2018
@obs método chamado nos métodos de gravação (upsert, delete e afins)
@return Nil
/*/
//------------------------------------------------------------------------------
Method addInfo(cInfo) Class NGFWError

	aAdd(::aInfo,cInfo)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} getErrorList
Método que retorna a lista completa de erros.

@author Felipe Nathan Welter
@author Vitor Emanuel Batista
@since 22/06/2012
@version P12
@return array Lista dos erros gerados.
/*/
//------------------------------------------------------------------------------
Method getErrorList() Class NGFWError
Return ::aError

//------------------------------------------------------------------------------
/*/{Protheus.doc} getAskList
Método que retorna a lista completa de mensagens yes/no.

@author Felipe Nathan Welter
@since 26/09/2017
@version P12
@return array Lista das mensagens yes/no.
/*/
//------------------------------------------------------------------------------
Method getAskList() Class NGFWError
Return ::aAsk

//------------------------------------------------------------------------------
/*/{Protheus.doc} getInfoList
Método que retorna a lista completa de mensagens informativas

@author Maicon André Pinheiro
@since  11/06/2018
@return Self:aInfo, array, Lista das mensagens informativas.
/*/
//------------------------------------------------------------------------------
Method getInfoList() Class NGFWError
Return ::aInfo

//------------------------------------------------------------------------------
/*/{Protheus.doc} ClearList
Método que limpa a lista de erros.

@author Felipe Nathan Welter
@since 17/04/2013
@version P12
@return Nil
/*/
//------------------------------------------------------------------------------
Method clearList() Class NGFWError

	::aError := {}
	::aAsk   := {}
	::aInfo  := {}

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} msgRequired
Método que concatena mensagem de campo obrigatório.

@author NG Informática Ltda.
@since 01/01/2015
/*/
//------------------------------------------------------------------------------
Method msgRequired( cFieldReq , nLine ) Class NGFWError

	Local cMessage
	Default nLine := 0
	cMessage := STR0001 + Space(1) + Trim( RetTitle( cFieldReq ) ) //"O campo"
	cMessage += " (" + cFieldReq + STR0002 //") não foi preenchido"
	If nLine > 0
		cMessage += CRLF + Space(1) + STR0003 //"Linha:"
		cMessage += Space(1) + cValToChar( nLine )
	EndIf

Return cMessage