#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "NGMUCH.CH"

#DEFINE __WHOIS__ '1.000|1.001|2.000' //Versão mensagem suportada pelo adapter
#DEFINE __ADAPT__ 'NGMUTRAREQ' //Adapter
#DEFINE __DESCR__ 'TraceabilityRequest' //Nome da mensagem unica

//---------------------------------------------------------------------
/*/{Protheus.doc} NGMUTRAREQ
Realiza chamada para a funcao responsavel pela integracao com mensagem
unica (IntegDef) para Consulta o Status de S.A. e S.C.

@author Tainã Alberto Cardoso
@since 23/05/17

@param [cTSol]  , Caracter, Tipo da solicitação : S.A. ou S.C.
@param [cCodS]  , Caracter, Código da solicitação
@param [cFil]   , Caracter, Filial a S.A. ou S.C.
@param [lMem]   , Lógico  , Indica se o registro é da memória ou da base de dados
@param [cItemSa], Caracter, Item da S.A.(Aplica-se somente a S.A.)
@param [nQuant] , Numérico, Indica nova a quantidade da S.A.
@param [cLocPro], Caracter, Almoxarifado.

@return Lógico, define se a mensagem obteve êxito
/*/
//---------------------------------------------------------------------
Function NGMUTRAREQ(cTSol, cCodS, cFil, lMem, cItemSa ,nQuant, cLocPro)

	Local cValInt := ""
	Local cValExt := ""

	Default cTSol   := ""
	Default cCodS   := ""
	Default cFil    := ""
	Default lMem    := .F.
	Default nQuant  := 0
	Default cItemSa := ''
	Default cLocPro := ''

	Private cTipSol    := If( cTSol == "SCP", "001","000" )
	Private cCodSol    := cCodS
	Private nSCPQUA    := nQuant
	Private cItemId    := cItemSa
	Private lMensag    := lMem
	Private cFilSol    := cFil
	Private cLocItem   := cLocPro
	Private lRetStatus := .F.

	cValInt := cEmpAnt + '|' +cFilSol + '|' + cCodSol + '|' +"SA"

	cValExt := RTrim(CFGA070Ext( "RM", "SCP", "CP_NUM", cValInt))

	If Empty(cValExt)
		Return .T.
	EndIf

	//chamada do integdef
	MsgRun(STR0023,__DESCR__,; //'Aguarde integração com backoffice...'
			{|| FWIntegDef(__ADAPT__, EAI_MESSAGE_BUSINESS, TRANS_SEND, Nil, __ADAPT__) })


Return lRetStatus

//---------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Integracao com Mensagem Unica.
- Consulta de Status S.A. e S.C.

@param cXML 		XML em string da mensagem de TraceabilityRequest
@param nTypeTrans 	tipo de de transferencia TRANS_RECEIVE ou TRANS_SEND
@param cTypeMessage tipo de mensagem do outro sistema EAI_MESSAGE_BUSINESS

@author Tainça Alberto Cardoso
@since 23/05/17
@version MP12
@return aRet  [1] lRet - Define se o envio foi realizado com sucesso. [.T. = True; .F. = False]
			  [2] cXMLRet - String do conteudo do xml.
/*/
//---------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )

	Local lRet := .F.
	Local cXMLRet := ""
	Local aRetXML := {}

	//Recebimento de mensagem XML de outro sistema
	If nTypeTrans == TRANS_RECEIVE

		//Mensagem enviada de outro sistema
		If cTypeMessage == EAI_MESSAGE_BUSINESS
			lRet    := .T.
			cXMLRet := ''

		//Retorno da mensagem XML enviada para outro sistema
		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
			aRetXML := fRespXML(cXML, nTypeTrans, cTypeMessage)
			lRet	 := aRetXML[1]
			lRetStatus := aRetXML[1]
			cXMLRet := aRetXML[2]

		//Versão da mensagem suportada pelo Adapter
		ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
			lRet    := .T.
			cXMLRet += __WHOIS__
		Endif

	//Envio de mensagem XML para outro sistema
	ElseIf nTypeTrans == TRANS_SEND
		aRetXML := fSendXML()
		lRet	 := aRetXML[1]
		cXMLRet := aRetXML[2]
	EndIf

	//ajusta o XML pois com o caracter < o parser espera uma tag XML
	cXmlRet := StrTran(cXmlRet,'< --',':::')

Return { lRet, cXMLRet }

//-------------------------------------------------------------------
/*/{Protheus.doc} fSendXML
Mensagem de envio

@author  Tainã Alberto Cardoso
@version P12
@since   23/05/2017
/*/
//-------------------------------------------------------------------
Static Function fSendXML()

	Local cXMLSend := ""
	Local cInternalId := ""
	Local cIntItemId  := ""
	Local nEvent := 3

	// Caso o adapter possuir o versionamento 2.000 utiliza layout atualizado da mensagem
	If RTrim(PmsMsgUVer('TRACEABILITYREQUEST', 'NGMUTRAREQ')) == '2.000'

		cInternalId := cEmpAnt + '|' +cFilSol + '|' + cCodSol
		cIntItemId  := cInternalId + '|' + cItemId + '|' + cLocItem

		cXMLSend := ''
		cXMLSend += FWEAIBusEvent( "TRACEABILITYREQUEST", nEvent, { { "InternalId", cInternalId } } )
		cXMLSend += '<BusinessContent>'
		cXMLSend += '	<RastreabilityItem>
		cXMLSend += '<CompanyInternalId>' +cEmpAnt+ '|' +cFilant + '</CompanyInternalId>'
		cXMLSend += '<CompanyId>' +cEmpAnt+ '</CompanyId>'
		cXMLSend += '<BranchId>' +cFilant+ '</BranchId>'
		cXMLSend += '<Type>' +cTipSol+ '</Type>'
		cXMLSend += '<RequestItemInternalId>' +cIntItemId+ '</RequestItemInternalId>'
		cXMLSend += ' <Quantity>'+ cValToChar( nSCPQUA ) + '</Quantity>'
		cXMLSend += '	</RastreabilityItem>
		cXMLSend += '</BusinessContent>'

	Else

		cInternalId := cEmpAnt + '|' +cFilSol + '|' + cCodSol + '|' +"SA"

		cXMLSend := ''
		cXMLSend += FWEAIBusEvent( "TRACEABILITYREQUEST", nEvent, { { "InternalId", cInternalId } } )
		cXMLSend += '<BusinessContent>'
		cXMLSend += '	<RastreabilityItem>
		cXMLSend += '<CompanyId>' +cEmpAnt+ '</CompanyId>'
		cXMLSend += '<CompanyInternalId>' +cEmpAnt+ '|' +cFilant + '</CompanyInternalId>'
		cXMLSend += '<InternalId>' +cInternalId+ '</InternalId>'
		cXMLSend += '<Type>' +cTipSol+ '</Type>'
		cXMLSend += '	</RastreabilityItem>
		cXMLSend += '</BusinessContent>'

	EndIf

Return {.T., cXMLSend}

//-------------------------------------------------------------------
/*/{Protheus.doc} fRespXML
Mensagem de retorno

@param cXML 		XML em string da mensagem de TraceabilityRequest
@param nTypeTrans 	tipo de de transferencia TRANS_RECEIVE ou TRANS_SEND
@param cTypeMessage tipo de mensagem do outro sistema EAI_MESSAGE_BUSINESS

@author  Tainã Alberto Cardoso
@version P12
@since   23/05/2017
/*/
//-------------------------------------------------------------------
Static Function fRespXML(cXML, nTypeTrans, cTypeMessage)

	Local lRet := .F.
	Local cError := ""
	Local cWarning := ""
	Local cXMLResp := ""
	Local aRetXML := {}

	oXmlMU := XmlParser(cXML, "_", @cError, @cWarning)

	If oXmlMU <> Nil .And. Empty(cError) .And. Empty(cWarning)

		//Retorno da mensagem XML não apresenta problemas, possui cosistencia em outro ambiente integrado
		If Upper(oXmlMU:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK"
			aRetXML	:= fOkRet(oXmlMU, cXML, nTypeTrans, cTypeMessage)
			lRet		:= aRetXML[1]
			cXMLResp	:= aRetXML[2]

		//Retorno da mensagem XML apresenta problemas, não possui cosistencia em outro ambiente integrado
		ElseIf Upper(oXmlMU:_TOTVSMESSAGE:_RESPONSEMESSAGE:_PROCESSINGINFORMATION:_STATUS:Text) == "ERROR"
			aRetXML	:= fErrorRet(oXmlMU, cXML, nTypeTrans, cTypeMessage)
			lRet		:= aRetXML[1]
			cXMLResp	:= aRetXML[2]
		EndIf
	EndIf

Return {lRet, cXMLResp}

//-------------------------------------------------------------------
/*/{Protheus.doc} fOkRet
Atualiza o estoque com as informacoes do retorno da mensagem, mas se o
retorno for incosistente com o SigaMNT, apresenta erro

@param oXmlMU		XML recebido no layout TraceabilityRequest
@param cXML 		XML em string da mensagem de TraceabilityRequest
@param nTypeTrans 	tipo de de transferencia TRANS_RECEIVE ou TRANS_SEND
@param cTypeMessage tipo de mensagem do outro sistema EAI_MESSAGE_BUSINESS

@author  Tainã Alberto Cardoso
@version P12
@since   23/05/2017
/*/
//-------------------------------------------------------------------
Static Function fOkRet(oXmlMU, cXML, nTypeTrans, cTypeMessage)

	Local aAux := {}
	Local lRet := .T.
	Local cObs := ""
	Local cXMLOk := ""

	//Valida e instancia a atualizacao de estoque
	aAux := fStatusSol(oXmlMU)
	If !aAux[1]
		lRet := aAux[1]
		cXMLOk := aAux[2]
		cObs := "Problema em alterar ou deletar o Insumo" + CHR(13)
		cObs += STR0005+cXMLOk  //'Motivo: '
		If lMensag
			MsgAlert(cObs+CRLF+STR0007,STR0008)  //"Para mais detalhes consulte o log do EAI."##"Integração BackOffice"
		EndIf
		NGIntMULog(__ADAPT__,cValToChar(nTypeTrans)+"|"+cTypeMessage,cXML)
	Else
		lRet := aAux[1]
	EndIf

Return {lRet, cXMLOk}

//-------------------------------------------------------------------
/*/{Protheus.doc} fErrorRet
Apresenta erro no retorno

@param oXmlMU	XML recebido no layout TraceabilityRequest
@param cXML 	XML em string da mensagem de TraceabilityRequest
@param nTypeTrans 	tipo de de transferencia TRANS_RECEIVE ou TRANS_SEND
@param cTypeMessage tipo de mensagem do outro sistema EAI_MESSAGE_BUSINESS

@author  Tainã Alberto Cardoso
@version P12
@since   23/05/2017
/*/
//-------------------------------------------------------------------
Static Function fErrorRet(oXmlMU, cXML, nTypeTrans, cTypeMessage)

	Local xObj
	Local nX := 0
	Local cObs := ""
	Local cXMLError := ""

	cObs := STR0015+AllTrim(SB2->B2_COD)+"."+CRLF  //"Problema com o backoffice na consulta de saldo online para o produto "
	cObs += STR0005  //'Motivo: '
	xObj := oXmlMU:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message
	cObs += NGMUError( xObj )

	cXMLError := cObs

	MsgAlert(cObs+CRLF+STR0007,STR0008)  //"Para mais detalhes consulte o log do EAI."##"Integração BackOffice"
	NGIntMULog(__ADAPT__,cValToChar(nTypeTrans)+"|"+cTypeMessage,cXML)

Return {.F., cXMLError}

//---------------------------------------------------------------------
/*/{Protheus.doc} fStatusSol
Verificar o Status da solicitação

@param oXmlMU	XML recebido no layout TraceabilityRequest

@author Tainã Alberto Cardoso

@since 23/05/17
@version MP12
@return cError descricao do erro (se houver)
/*/
//---------------------------------------------------------------------
Static Function fStatusSol(oXmlMU)

	Local cRetObs  := ''
	Local lRet := .T.

	If oXmlMU <> Nil

		//Verificar se possui bloqueio na movimentação
		If Upper(oXmlMU:_TOTVSMESSAGE:_RESPONSEMESSAGE:_RETURNCONTENT:_STATUSMOV:_TMOVSTATUS:_STATUS:Text) == "0"

			lRet := .F.
			cRetObs := oXmlMU:_TOTVSMESSAGE:_RESPONSEMESSAGE:_RETURNCONTENT:_STATUSMOV:_TMOVSTATUS:_DESCRIPTION:Text

		EndIf

	EndIf


Return {lRet, cRetObs}
