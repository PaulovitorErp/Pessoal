#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "NGMUCH.CH"

Function NGMUAmpPat(nRecSN4,nRecSN1,nRecSTJ)

	Private lAmpliou := .F.

	dbSelectArea("SN4")
	dbGoTo(nRecSN4)

	dbSelectArea("SN1")
	dbGoTo(nRecSN1)

	dbSelectArea("STJ")
	dbGoTo(nRecSTJ)

	//altera a variavel lAmpliou
	MsgRun('Aguarde integração com backoffice...','AssetsValuation',;
			{|| FWIntegDef("NGMUAMPPAT", EAI_MESSAGE_BUSINESS, TRANS_SEND, Nil, "NGMUAMPPAT") })

Return lAmpliou

//---------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Integracao com mensagem unica (baixa de estoque)

@author Felipe Nathan Welter
@since 16/07/12
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )

	Local nX
	Local lRet        := .F.
	Local cXMLRet     := ""
	Local cError      := ""
	Local cWarning    := ""
	Local cInternalId := ""
	Local aXml   	  := {}

	If nTypeTrans == TRANS_RECEIVE

		If cTypeMessage == EAI_MESSAGE_BUSINESS

			cXMLRet := '<TAGX>TESTE DE RECEPCAO BUSINESS MESSAGE</TAGX>'
			lRet := .T.

		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE

			oXmlMU   := XmlParser(cXML, "_", @cError, @cWarning)

			If oXmlMU <> Nil .And. Empty(cError) .And. Empty(cWarning)

				aXml := NGMUValRes(oXmlMU,STR0013)

				If !aXml[1]

					lAmpliou := .F.
					lRet     := .T.
					cXMLRet  := aXml[2]

					NGIntMULog("NGMUAMPPAT",cValToChar(nTypeTrans)+"|"+cTypeMessage,cXML)

				Else

					lAmpliou := .T.
					lRet     := .T.
					cXMLRet  := ''

				EndIf

			EndIf

		ElseIf cTypeMessage == EAI_MESSAGE_WHOIS

			cXMLRet := '1.000'
			lRet := .T.

		EndIf

	ElseIf nTypeTrans == TRANS_SEND

		//---------------------------------------------------------------------
		//envia mensagem de baixa de estoque
		//---------------------------------------------------------------------

		cInternalId := cEmpAnt+'|'+SN4->N4_FILIAL+'|'+SN4->N4_IDMOV

		cXMLRet += FWEAIBusEvent( "ASSETSVALUATION", 3, { { "InternalId", cInternalId } } )

		cXMLRet += '<BusinessContent>'
		cXMLRet += '	<Code>'              + SN4->N4_IDMOV + '</Code>' //Codigo do movimento de ampliacao do valor do ativo/bem
		cXMLRet += '	<InternalId>'        + cInternalId + '</InternalId>' //InternalId da ampliacao patrimonial
		cXMLRet += '	<CompanyId>'         + cEmpAnt + '</CompanyId>' //Empresa
		cXMLRet += '	<BranchId>'          + cFilAnt + '</BranchId>' //Filial
		cXMLRet += '	<CompanyInternalId>' + cEmpAnt+'|'+cFilAnt + '</CompanyInternalId>' //InternalId da Empresa
		cXMLRet += '	<AssetInternalId>' 	 + cEmpAnt+'|'+AllTrim(NGTROCAFILI("SN1",SN4->N4_FILIAL))+"|"+AllTrim(SN4->N4_CBASE)+"|"+AllTrim(SN4->N4_ITEM) + '</AssetInternalId>' //codigo do ativo que se deseja ampliar o valor
		cXMLRet += '	<RegisterDateTime>'  + FWTimeStamp ( 3,SN4->N4_DATA, '00:00:00' ) + '</RegisterDateTime>' //data de ampliacao do valor do ativo
		cXMLRet += '	<CalculationType>'  	+ '001' + '</CalculationType>'  //forma de calculo do valor a ser acrescido
											//001 - utilizado valor nominal a ser multiplicado pela quantidade, caso seja maior que 1
											//002 - utilizado valor nominal a ser rateado pela quantidade, caso seja maior que 1
											//003 - utilizado valor percentual a ser rateado pela quantidade, caso seja maior que 1
		cXMLRet += '	<AssetAccounting>' 	+ '' + '</AssetAccounting>'  //indica se ha contabilizacao da ampliacao do valor do ativo
		cXMLRet += '	<Value>' 				+ cValToChar(SN4->N4_VLROC1) + '</Value>' //valor nominal a ser acrescido no valor do ativo
		cXMLRet += '	<Percentual>'    	 	+ '' + '</Percentual>'  //percentual do valor a ser acrescido no valor do ativo
		cXMLRet += '	<Quantity>'     		+ '1' + '</Quantity>'  //quantidade
		cXMLRet += '	<Observation>'       + '' + '</Observation>'  //observacao
		cXMLRet += '</BusinessContent>'

		lRet := .T.

	EndIf

	//ajusta o XML pois com o caracter < o parser espera uma tag XML
	cXmlRet := StrTran(cXmlRet,'< --',':::')

	//Ponto de entrada para alteração do XML
	If ExistBlock("NGMUPE01")
   		cXMLRet := ExecBlock("NGMUPE01",.F.,.F.,{cXmlRet, lRet, "NGMUAmpPat", 1, nTypeTrans, cTypeMessage})
	Endif

Return { lRet, cXMLRet }