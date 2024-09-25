#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "NGMUCH.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTI494A
Mensagem única para envio dos custos indiretos mensais do equipamento.

@author Vitor Emanuel Batista
@param cXML	Variavel com conteudo xml para envio/recebimento.
@param nTypeTrans	Tipo de transacao. (Envio/Recebimento)
@param cTypeMessage	Tipo de mensagem. (Business Type, WhoIs, etc)
@since 11/07/13
@version P11
@return aArray sendo [1]-.T./.F. e [2]-cError
/*/
//---------------------------------------------------------------------
Function MNTI494A(aIndirectCosts)

	Local lOldInclui := If( Type("Inclui") == "L", Inclui, Nil )
	Local lOldAltera := If( Type("Altera") == "L", Altera, Nil )

	Local bBlock := { || FWIntegDef("MNTI494A", EAI_MESSAGE_BUSINESS, TRANS_SEND, Nil, "MNTI494A") }

	Default aIndirectCosts := {}

	Private aEquipCosts := aClone(aIndirectCosts)

	If Type( "oMainWnd" ) == "O"
		MsgRun( "Aguarde integração com backoffice...", "Custo Indireto Mensal do Equipamento", bBlock )
	Else
		Eval( bBlock )
	EndIf

	Inclui := lOldInclui
	Altera := lOldAltera

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Integracao com mensagem unica.

@author Felipe Nathan Welter
@since 16/07/12
@version MP11
@return aRet  [1] lRet - Define se o envio foi realizado com sucesso. [.T. = True; .F. = False]
			     [2] cXMLRet - String do conteudo do xml.
/*/
//---------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )

	Local nX, nCCust
	Local lRet     		:= .F.
	Local cXMLRet  		:= ""
	Local cError		:= ""
	Local cWarning 		:= ""
	Local lMNTI4941 	:= ExistBlock("MNTI4941")
	Local cCodBem		:= ""
	Local cMesXML		:= ""
	Local cAnoXML		:= ""
	Local cInternalId	:= ""
	Local cAssetIntID	:= ""
	Local aCCustosInt  	:= {}
	Local aXml 			:= {}

	If nTypeTrans == TRANS_RECEIVE

		If cTypeMessage == EAI_MESSAGE_BUSINESS
			cXMLRet := '<TAGX>TESTE DE RECEPCAO BUSINESS MESSAGE</TAGX>'
			lRet := .T.

		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE

			oXmlMU := XmlParser(cXML, "_", @cError, @cWarning)

			If oXmlMU <> Nil .And. Empty(cError) .And. Empty(cWarning)

				aXml := NGMUValRes(oXmlMU,STR0030)

				If !aXml[1] //"ERROR"

					lApropria 	:= .F.
					lOkAprCst 	:= .F.
					lRet    	:= .T.
					cXMLRet 	:= aXml[2]

					NGIntMULog("MNTI494A", cValToChar(nTypeTrans) + "|" + cTypeMessage, cXML)

				Else // "OK"

					lRet := .T.
					cXMLRet := ''

				EndIf
			EndIf

			cXMLRet := '<TAGX>TESTE DE RECEPCAO RESPONSE MESSAGE</TAGX>'
			lRet := .T.

		ElseIf cTypeMessage == EAI_MESSAGE_WHOIS

			cXMLRet := '<Version>1.000</Version>'
			lRet := .T.

		EndIf

	ElseIf nTypeTrans == TRANS_SEND

		lRet := .F.

		cCodBem := aEquipCosts[1]
		cMesXML := aEquipCosts[2]
		cAnoXML := aEquipCosts[3]

		cAssetIntID := cEmpAnt + "|" + cFilAnt + "|" + cCodBem

		cXMLRet += FWEAIBusEvent( "ASSETMONTHLYUNDIRECTCOSTS", 3, { { "AssetInternalId", cAssetIntID } } )

		cXMLRet += '<BusinessContent>'

		cXMLRet += '	<CompanyId>'         + cEmpAnt                          	+ '</CompanyId>'
		cXMLRet += '	<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt          	+ '</CompanyInternalId>'
		cXMLRet += '	<BranchId>'          + cFilAnt                          	+ '</BranchId>'
		cXMLRet += '	<AssetInternalId>'   + cAssetIntID                      	+ '</AssetInternalId>'
		cXMLRet += '	<MonthYear>'         + cMesXML + "/" + Right(cAnoXML, 2)	+ '</MonthYear>'

		cXMLRet += '	<ListOfIndirectCost>'

		For nCCust := 1 To Len(aEquipCosts[4])

			aCCustosInt := aEquipCosts[4][nCCust][2]
			cInternalId := cEmpAnt + '|' + cFilAnt + '|' + cCodBem + '|' + aEquipCosts[4][nCCust][1] + '|' + cAnoXML + cMesXML + '|' + 'IC'

			If lMNTI4941
				aCCustosInt := ExecBlock("MNTI4941", .F., .F., { cEmpAnt, cFilAnt, cCodBem, aEquipCosts[4][nCCust][1], cMesXML, cAnoXML, aCCustosInt } )
			EndIf

			cXMLRet += '		<IndirectCost>'

			cXMLRet += '			<InternalId>'        + cInternalId                              	+ '</InternalId>'
			cXMLRet += '			<CostCenterCode>'    + AllTrim(aEquipCosts[4][nCCust][1])       	+ '</CostCenterCode>'
			cXMLRet += '			<LaborCost>'         + RetCost( aCCustosInt, "LaborCost"        )	+ '</LaborCost>'
			cXMLRet += '			<InputCost>'         + RetCost( aCCustosInt, "InputCost"        )	+ '</InputCost>'
			cXMLRet += '			<ThirdPartCost>'     + RetCost( aCCustosInt, "ThirdPartCost"    )	+ '</ThirdPartCost>'
			cXMLRet += '			<ToolCost>'          + RetCost( aCCustosInt, "ToolCost"         )	+ '</ToolCost>'
			cXMLRet += '			<RentCost>'          + RetCost( aCCustosInt, "RentCost"         )	+ '</RentCost>'
			cXMLRet += '			<PenaltyCost>'       + RetCost( aCCustosInt, "PenaltyCost"      )	+ '</PenaltyCost>'
			cXMLRet += '			<IncidentCost>'      + RetCost( aCCustosInt, "IncidentCost"     )	+ '</IncidentCost>'
			cXMLRet += '			<PaperCost>'         + RetCost( aCCustosInt, "PaperCost"        )	+ '</PaperCost>'
			cXMLRet += '			<FuelCost>'          + RetCost( aCCustosInt, "FuelCost"         )	+ '</FuelCost>'
			cXMLRet += '			<TotalRentCost>'     + RetCost( aCCustosInt, "TotalRentCost"    )	+ '</TotalRentCost>'
			cXMLRet += '			<HourRentCost>'      + RetCost( aCCustosInt, "HourRentCost"     )	+ '</HourRentCost>'
			cXMLRet += '			<RealHourRentCost>'  + RetCost( aCCustosInt, "RealHourRentCost" )	+ '</RealHourRentCost>'
			cXMLRet += '			<BilledRentCost>'    + RetCost( aCCustosInt, "BilledRentCost"   )	+ '</BilledRentCost>'

			cXMLRet += '		</IndirectCost>'

		Next nCCust

		cXMLRet += '	</ListOfIndirectCost>'

		cXMLRet += '</BusinessContent>'

		lRet := .T.

		// Código para testes, gera arquivo de xml na pasta de dicionário
		nHandle := FCreate( "CUSTOS_MNTI494A.xml",0 )
		FWrite( nHandle,cXMLRet )

	EndIf

	cXMLRet := EncodeUTF8(cXMLRet)

Return { lRet, cXMLRet }

//---------------------------------------------------------------------
/*/{Protheus.doc} RetCost
Funcao de tratamento para o recebimento/envio de mensagem unica de
cadastro de atividades da parte diária.

@author Vitor Emanuel Batista
@param aCCustosInt Array contendo todos os custos do Equipamento no mês
@param cType Tipo a ser localizado na array
@since 12/07/13
@version P11
@return nCusto Custo total do tipo a ser localizado
/*/
//---------------------------------------------------------------------
Static Function RetCost(aCCustosInt,cType)

	Local nPos
	Local nCusto := 0

	nPos := aScan(aCCustosInt,{|x| UPPER(AllTrim(x[1])) == UPPER(AllTrim(cType)) })

	If nPos > 0
		nCusto := aCCustosInt[nPos][2]
	EndIf

Return cValToChar(nCusto)