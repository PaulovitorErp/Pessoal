#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "NGMUCH.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTI494B
Mensagem única para envio dos custos diretos mensais do equipamento.

@author Vitor Emanuel Batista
@param cXML	Variavel com conteudo xml para envio/recebimento.
@param nTypeTrans	Tipo de transacao. (Envio/Recebimento)
@param cTypeMessage	Tipo de mensagem. (Business Type, WhoIs, etc)
@since 11/07/13
@version P11
@return aArray sendo [1]-.T./.F. e [2]-cError
/*/
//---------------------------------------------------------------------
Function MNTI494B(aDirectCosts)

	Local lOldInclui := If( Type("Inclui") == "L", Inclui, Nil )
	Local lOldAltera := If( Type("Altera") == "L", Altera, Nil )

	Local bBlock := { || FWIntegDef("MNTI494B", EAI_MESSAGE_BUSINESS, TRANS_SEND, Nil, "MNTI494B") }

	Default aDirectCosts := {}

	Private aEquipCosts := aClone(aDirectCosts)

	If Type( "oMainWnd" ) == "O"
		MsgRun( "Aguarde integração com backoffice...", "Custo Direto Mensal do Equipamento", bBlock )
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

	Local nX, nCCust, nAppt
	Local lRet     		:= .F.
	Local lMNTI4942 	:= ExistBlock("MNTI4942")
	Local cXMLRet  		:= ""
	Local cError		:= ""
	Local cWarning 		:= ""
	Local cCodBem		:= ""
	Local cMesXML		:= ""
	Local cAnoXML		:= ""
	Local cInternalId	:= ""
	Local cAssetIntID	:= ""
	Local cObs			:= ""
	Local cCodCcust		:= ""
	Local cActivId      := ""
	Local aCCustosInt 	:= {}
	Local aApptsInt   	:= {}
	Local aXml 			:= {}
	Local cCusVer       := RTrim(PmsMsgUVer('COSTCENTER','CTBA030')) //Versão do Centro de Custo
	

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
					lOkAprCst	:= .F.
					lRet    	:= .T.
					cXMLRet  	:= aXml[2]

					NGIntMULog("MNTI494B", cValToChar(nTypeTrans) + "|" + cTypeMessage, cXML)

				Else //"OK"

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

		cXMLRet += FWEAIBusEvent( "ASSETMONTHLYDIRECTCOSTS", 3, { { "AssetInternalId", cAssetIntID } } )

		cXMLRet += '<BusinessContent>'

		cXMLRet += '	<CompanyId>'         + cEmpAnt                          	+ '</CompanyId>'
		cXMLRet += '	<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt          	+ '</CompanyInternalId>'
		cXMLRet += '	<BranchId>'          + cFilAnt                          	+ '</BranchId>'
		cXMLRet += '	<AssetInternalId>'   + cAssetIntID                      	+ '</AssetInternalId>'
		cXMLRet += '	<MonthYear>'         + cMesXML + "/" + Right(cAnoXML, 2)	+ '</MonthYear>'

		cXMLRet += '	<ListOfDirectCost>'

		For nCCust := 1 To Len(aEquipCosts[5])

			aCCustosInt := aEquipCosts[5][nCCust][2]
			cInternalId := cEmpAnt + '|' + cFilAnt + '|' + cCodBem + '|' + aEquipCosts[5][nCCust][1] + '|' + cAnoXML + cMesXML + '|' + 'DC'

			If lMNTI4942
				aCCustosInt := ExecBlock("MNTI4942", .F., .F., { cEmpAnt, cFilAnt, cCodBem, aEquipCosts[5][nCCust][1], cMesXML, cAnoXML, aCCustosInt } )
			EndIf

			cCodCcust := IntCusExt(/*cEmpresa*/,/*cFilial*/,aEquipCosts[5][nCCust][1],cCusVer)[2]

			cXMLRet += '		<DirectCost>'

			cXMLRet += '			<InternalId>'             	        + cInternalId                              	     	        	+ '</InternalId>'
			cXMLRet += '            <CostCenterInternalId>'             + cCodCcust                                                     + '</CostCenterInternalId>'
			cXMLRet += '			<CostCenterCode>'         	        + aEquipCosts[5][nCCust][1]          	     	        	    + '</CostCenterCode>'
			cXMLRet += '			<UnproductiveHoursAmount>'	        + RetCost( aCCustosInt, "UnproductiveHoursAmount"          )	+ '</UnproductiveHoursAmount>'
			cXMLRet += '			<UnproductiveHoursCost>'            + RetCost( aCCustosInt, "UnproductiveHoursCost"            )	+ '</UnproductiveHoursCost>'
			cXMLRet += '			<ProductiveHoursAmount>'            + RetCost( aCCustosInt, "ProductiveHoursAmount"            )	+ '</ProductiveHoursAmount>'
			cXMLRet += '			<ProductiveHoursCost>'              + RetCost( aCCustosInt, "ProductiveHoursCost"              )	+ '</ProductiveHoursCost>'
			cXMLRet += '			<ApportionmentProductiveHoursCost>'	+ "0"															+ '</ApportionmentProductiveHoursCost>'
			cXMLRet += '			<ListOfAppointment>'

			For nAppt := 1 To Len(aEquipCosts[5][nCCust][3])

				aApptsInt := aClone(aEquipCosts[5][nCCust][3][nAppt])

				cXMLRet += '				<Appointment>'
				cXMLRet += '					<InternalId>'               + aApptsInt[1] + '</InternalId>'
				cXMLRet += '					<TaskProjectId>'            + RTrim(aApptsInt[2]) + '</TaskProjectId>'
				cXMLRet += '					<TaskProjectInternalId>'    + ""           + '</TaskProjectInternalId>'
				cXMLRet += '					<StartDateTimeAppointment>' + aApptsInt[4] + '</StartDateTimeAppointment>'
				cXMLRet += '					<EndDateTimeAppointment>'   + aApptsInt[5] + '</EndDateTimeAppointment>'
				If !Empty(aApptsInt[6])
					cActivId := AllTrim( cEmpAnt + "|" + xFilial("TV0")+ "|" + aApptsInt[6] )
				Else
					cActivId := ""
				EndIf
				cXMLRet += '					<ActivityInternalId>'       + cActivId  + '</ActivityInternalId>'
				cXMLRet += '					<ActivityCode>'             + aApptsInt[6] + '</ActivityCode>'
				cXMLRet += '				</Appointment>'

			Next nAppt

			cXMLRet += '			</ListOfAppointment>'

			cXMLRet += '		</DirectCost>'

		Next nCCust

		cXMLRet += '	</ListOfDirectCost>'

		cXMLRet += '</BusinessContent>'

		lRet := .T.

		// Código para testes, gera arquivo de xml na pasta de dicionário
		nHandle := FCreate("CUSTOS_MNTI494B.xml",0)
		FWrite(nHandle,cXMLRet)
		FClose(nHandle)
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