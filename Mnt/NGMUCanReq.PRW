#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "NGMUCH.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} NGMUCanReq
Integracao com mensagem única (cancelamento de requisicao - SC/SA/SD3)
@type function

@author Felipe Nathan Welter
@since 16/07/12

@sample NGMUCanReq( 15, 'SD3', .F. )

@param nRecNo     , Númerico, RECNO do registro a ser cancelado.
@param cTbl       , Caracter, Tabela referente ao registro a ser cancelado.
@param [lShowMsg] , Lógico  , Define se deve apresentar a mensagem de erro.
@param [lRetArr] , Lógico  , Define o tipo de retorno da função ( .T. - Lógico / .F. - Array )
@return aRetCan[1], Lógico  , Define se o processo foi realizado corretamente.
        aRetCan[2], Caracter, Mensagem de erro, caso ocorra.
/*/
//------------------------------------------------------------------------------
Function NGMUCanReq( nRecNo, cTbl, lShowMsg, lRetArr )

	Private cTable   := cTbl
	Private lError   := .T.
	Private aRetCan  := { .T., '' }

	Default lShowMsg := .T.
	Default lRetArr  := .F.

	lError := lShowMsg //Atribuição a variavel que controla a apresentação de msg de erro.

	dbSelectArea( cTbl )
	dbGoTo( nRecNo )

	MsgRun( STR0023, 'CancelRequest', { || FWIntegDef( 'NGMUCANREQ', EAI_MESSAGE_BUSINESS, TRANS_SEND, Nil, 'NGMUCANREQ' ) } ) // Aguarde integração com backoffice...

Return IIf( lRetArr, aRetCan, aRetCan[1] )

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

	Local lRet 		         := .F.
	Local cXMLRet  	         := ''
	Local cError	         := ''
	Local cWarning 	         := ''
	Local cInternalId        := ''
	Local cRequestInternalId := ''
	Local aXml 		         := {}
	Local nX                 := 0

	If nTypeTrans == TRANS_RECEIVE

		If cTypeMessage == EAI_MESSAGE_BUSINESS

			//nao foi necessario implementar esse trecho para integracao

			lRet := .T.
			cXMLRet := '<TAGX>TESTE DE RECEPCAO BUSINESS MESSAGE</TAGX>'

		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE

			oXmlMU := XmlParser(cXML, "_", @cError, @cWarning)

			If oXmlMU <> Nil .And. Empty(cError) .And. Empty(cWarning)

				aXml := NGMUValRes( oXmlMU, STR0032, lError ) // Não foi possível realizar o cancelamento de movimentação interna para este item devido a seguinte inconsistências no backoffice:

				If !aXml[1] //"ERROR"
					lRet    := .T.
					cXMLRet := ''
					aRetCan := { .F., aXml[2] }
				Else //nao ha de-para nessa mensagem
					lRet    := .T.
					aRetCan := { .T., '' }
				EndIf
			EndIf

		ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
			cXMLRet := '1.000'
			lRet := .T.
		Endif

	ElseIf nTypeTrans == TRANS_SEND


		If cTable == "SD3"

			//---------------------------------------------------------------------
			//envia mensagem de baixa de estoque
			//---------------------------------------------------------------------

			//ou a chave unica da tabela SD3 ou talvez deva se usar o DOC (agrupador)
			//cInternalId := SD3->D3_FILIAL+'|'+SD3->D3_OP+'|'+SD3->D3_COD+'|'+SD3->D3_LOCAL
			//cInternalId := SD3->D3_FILIAL+'|'+SD3->D3_NUMSEQ+'|'+SD3->D3_CHAVE+'|'+SD3->D3_COD
			cInternalId := cEmpAnt+'|'+SD3->D3_FILIAL+'|'+SD3->D3_DOC +'|'+'STO'
			cRequestInternalId := cEmpAnt+'|'+SD3->D3_FILIAL+'|'+SD3->D3_NUMSEQ+'|'+SD3->D3_CHAVE+'|'+SD3->D3_COD
			cXMLRet += FWEAIBusRequest("CANCELREQUEST")

			//nesse caso o NUMSEQ e DOC sao iguais a da mensagem de requisicao (baixa)
			cXMLRet += '<BusinessContent>'
				cXMLRet += '	<Code>'                  + SD3->D3_DOC + '</Code>' //Codigo do cancelamento
				cXMLRet += '	<InternalId>'            + cInternalId + '</InternalId>' //Codigo de integracao do cancelamento
				cXMLRet += '	<RequestInternalId>'     + cRequestInternalId + '</RequestInternalId>'  //Codigo de integracao do registro a cancelar
				cXMLRet += '	<Type>'                  + '002' + '</Type>'  //Tipo da entidade a cancelar
				cXMLRet += '	<CancelDateTime>'        + FWTimeStamp ( 3,dDataBase,SubStr(Time(),1,8) ) + '</CancelDateTime>' //Data de cancelamento
				cXMLRet += '	<CancelReason>'          + '' + '</CancelReason>' //Motivo do cancelamento
				cXMLRet += '	<CancelRelatedRequests>' + 'true' + '</CancelRelatedRequests>' //Indica se cancela solicitacoes relacionadas
			cXMLRet += '</BusinessContent>'

			lRet := .T.

		ElseIf cTable == "SC1"

			cInternalId := cEmpAnt+'|'+SC1->C1_FILIAL + '|' + SC1->C1_NUM +'|'+'SC'

			If SuperGetMV("MV_NGMNTCP", .F., "N") == "S"
				cRequestInternalId := cInternalId
			Else
				cRequestInternalId := cEmpAnt+'|'+SC1->C1_FILIAL + '|' + SC1->C1_NUM +'|' + SC1->C1_ITEM + '|' + SC1->C1_LOCAL
			EndIf

			cXMLRet += FWEAIBusRequest("CANCELREQUEST")

			//nesse caso o NUMSEQ e DOC sao iguais a da mensagem de requisicao (baixa)
			cXMLRet += '<BusinessContent>'
				cXMLRet += '	<Code>'                  + SC1->C1_NUM + '</Code>' //Codigo do cancelamento
				cXMLRet += '	<InternalId>'            + cInternalId + '</InternalId>' //Codigo de integracao do cancelamento
				cXMLRet += '	<RequestInternalId>'     + cInternalId + '</RequestInternalId>'  //Codigo de integracao do registro a cancelar
				cXMLRet += '	<Type>'                  + '000' + '</Type>'  //Tipo da entidade a cancelar
				cXMLRet += '	<CancelDateTime>'        + FWTimeStamp ( 3,dDataBase,SubStr(Time(),1,8) ) + '</CancelDateTime>' //Data de cancelamento
				cXMLRet += '	<CancelReason>'          + '' + '</CancelReason>' //Motivo do cancelamento
				cXMLRet += '	<CancelRelatedRequests>' + 'true' + '</CancelRelatedRequests>' //Indica se cancela solicitacoes relacionadas
			cXMLRet += '</BusinessContent>'

			lRet := .T.

		ElseIf cTable == "SCP"

			cInternalId := cEmpAnt+'|'+SCP->CP_FILIAL + '|' + SCP->CP_NUM +'|'+'SA'

			If SuperGetMV( "MV_NGMNTAS",.F.,"2" ) == "1" // caso aglutinação de SA
				cRequestInternalId := cEmpAnt+'|'+xFilial("SCP") + '|' + SCP->CP_NUM + '|' + SCP->CP_ITEM + '|' + SCP->CP_LOCAL
			Else
				cRequestInternalId := cInternalId
			EndIf

			cXMLRet += FWEAIBusRequest("CANCELREQUEST")

			//nesse caso o NUMSEQ e DOC sao iguais a da mensagem de requisicao (baixa)
			cXMLRet += '<BusinessContent>'
				cXMLRet += '	<Code>'                  + SCP->CP_NUM + '</Code>' //Codigo do cancelamento
				cXMLRet += '	<InternalId>'            + cInternalId + '</InternalId>' //Codigo de integracao do cancelamento
				cXMLRet += '	<RequestInternalId>'     + cRequestInternalId + '</RequestInternalId>'  //Codigo de integracao do registro a cancelar
				cXMLRet += '	<Type>'                  + '001' + '</Type>'  //Tipo da entidade a cancelar
				cXMLRet += '	<CancelDateTime>'        + FWTimeStamp ( 3,dDataBase,SubStr(Time(),1,8) ) + '</CancelDateTime>' //Data de cancelamento
				cXMLRet += '	<CancelReason>'          + '' + '</CancelReason>' //Motivo do cancelamento
				cXMLRet += '	<CancelRelatedRequests>' + 'true' + '</CancelRelatedRequests>' //Indica se cancela solicitacoes relacionadas
			cXMLRet += '</BusinessContent>'

			lRet := .T.

		ElseIf cTable == "STJ"

			cInternalId := cEmpAnt+'|'+STJ->TJ_FILIAL + '|' + STJ->TJ_ORDEM +'|'+'OS'

			cXMLRet += FWEAIBusRequest("CANCELREQUEST")

			//nesse caso o NUMSEQ e DOC sao iguais a da mensagem de requisicao (baixa)
			cXMLRet += '<BusinessContent>'
				cXMLRet += '	<Code>'                  + STJ->TJ_ORDEM + '</Code>' //Codigo do cancelamento
				cXMLRet += '	<InternalId>'            + cInternalId + '</InternalId>' //Codigo de integracao do cancelamento
				cXMLRet += '	<RequestInternalId>'     + cInternalId + '</RequestInternalId>'  //Codigo de integracao do registro a cancelar
				cXMLRet += '	<Type>'                  + '003' + '</Type>'  //Tipo da entidade a cancelar
				cXMLRet += '	<CancelDateTime>'        + FWTimeStamp ( 3,dDataBase,SubStr(Time(),1,8) ) + '</CancelDateTime>' //Data de cancelamento
				cXMLRet += '	<CancelReason>'          + '' + '</CancelReason>' //Motivo do cancelamento
				cXMLRet += '	<CancelRelatedRequests>' + 'true' + '</CancelRelatedRequests>' //Indica se cancela solicitacoes relacionadas
			cXMLRet += '</BusinessContent>'

			lRet := .T.

		EndIf

	EndIf

	//ajusta o XML pois com o caracter < o parser espera uma tag XML
	cXmlRet := StrTran(cXmlRet,'< --',':::')

	//Ponto de entrada para alteração do XML
	If ExistBlock("NGMUPE01")
   		cXMLRet := ExecBlock("NGMUPE01",.F.,.F.,{cXmlRet, lRet, "NGMUCanReq", 1, nTypeTrans, cTypeMessage})
	EndIf

Return { lRet, cXMLRet }