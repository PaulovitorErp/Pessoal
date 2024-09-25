#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "NGMUCH.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} NGMUCanMnO
Integracao com mensagem unica (cancelamento de OS)

@author Felipe Nathan Welter
@since 16/07/12
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function NGMUCanMnO(nRecNo)

	Private lOKCANCEL := .T.

	dbSelectArea("STJ")
	dbGoTo(nRecNo)
	If STJ->TJ_SITUACA == 'P'
		Return .T.
	EndIf

	MsgRun('Aguarde integração com backoffice...','CancelMaintenanceOrder',;
			{|| aReturn := FWIntegDef("NGMUCANMNO", EAI_MESSAGE_BUSINESS, TRANS_SEND, Nil, "NGMUCANMNO") })

Return lOKCancel

//---------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Integracao com mensagem unica (cancelamento de requisicao)

@author Felipe Nathan Welter
@since 16/07/12
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )

	Local lRet 		:= .F.
	Local cXMLRet  	:= ''
	Local cError	:= ''
	Local cWarning 	:= ''
	Local aXml 		:= {}
	Local nX

	Local cInternalId := ''

	If nTypeTrans == TRANS_RECEIVE

		If cTypeMessage == EAI_MESSAGE_BUSINESS
			cXMLRet := '<TAGX>TESTE DE RECEPCAO RESPONSE MESSAGE</TAGX>'
			lRet := .T.

		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE

			oXmlMU := XmlParser(cXML, "_", @cError, @cWarning)

			If oXmlMU <> Nil .And. Empty(cError) .And. Empty(cWarning)

				aXml := NGMUValRes(oXmlMU, STR0021)

				If !aXml[1] //"ERROR"

					lRet 	  := .T.  //falso para nao cancelar a OS
					lOKCANCEL := .F.
					cXMLRet   := aXml[2]

					NGIntMULog("NGMUCANMNO",cValToChar(nTypeTrans)+"|"+cTypeMessage,cXML)

				Else //"OK"

					lRet := .T.
					cXMLRet := ''

				EndIf
			EndIf

		ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
			cXMLRet := '1.000'
			lRet := .T.
		Endif

	ElseIf nTypeTrans == TRANS_SEND

		cInternalId := cEmpAnt+'|'+STJ->TJ_FILIAL + '|' + STJ->TJ_ORDEM +'|'+'OS'

		cXMLRet += FWEAIBusRequest("CANCELMAINTENANCEORDER")

				//nesse caso o NUMSEQ e DOC sao iguais a da mensagem de requisicao (baixa)
		cXMLRet += '<BusinessContent>'
			cXMLRet += '	<Code>'                  + STJ->TJ_ORDEM + '</Code>' //Codigo do cancelamento
			cXMLRet += '	<InternalId>'            + cInternalId + '</InternalId>' //Codigo de integracao do cancelamento
			cXMLRet += '	<MaintenanceOrderInternalId>' + cInternalId + '</MaintenanceOrderInternalId>'
			cXMLRet += '	<Type>'                  + '003' + '</Type>'  //Tipo da entidade a cancelar
			cXMLRet += '	<CancelDateTime>'        + FWTimeStamp ( 3,dDataBase,SubStr(Time(),1,8) ) + '</CancelDateTime>' //Data de cancelamento
			cXMLRet += '	<CancelReason>'          + '' + '</CancelReason>' //Motivo do cancelamento
			cXMLRet += '	<CancelRelatedRequests>' + 'true' + '</CancelRelatedRequests>' //Indica se cancela solicitacoes relacionadas
		cXMLRet += '</BusinessContent>'

		lRet := .T.

	EndIf

	//ajusta o XML pois com o caracter < o parser espera uma tag XML
	cXmlRet := StrTran(cXmlRet,'< --',':::')

	//Ponto de entrada para alteração do XML
	If ExistBlock("NGMUPE01")
   		cXMLRet := ExecBlock("NGMUPE01",.F.,.F.,{cXmlRet, lRet, "NGMUCanMnO", 1, nTypeTrans, cTypeMessage})
	Endif

Return { lRet, cXMLRet }