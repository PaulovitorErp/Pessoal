#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "NGMUCH.CH"

//Declara versão das mensagens utilizadas nos CustomerInternalId
Static cVerCusto := RTrim( PmsMsgUVer( 'CUSTOMERVENDOR', 'MATA020' ) ) // Identifica versão do Fornecedor

//---------------------------------------------------------------------
/*/{Protheus.doc} NGMUOrder
Integracao com mensagem unica (pedido de compra).
> utilizada na conciliacao de NF de abastecimento externo.
> utilizada na geracao de multas, documentos e honorários.

@author Felipe Nathan Welter
@since 14/05/13

@param nRecNo  , numeric, numero do registro base para integracao
@param cTbl    , string , Codigo da tabela.
@param lMem    , boolean, Indica se busca conteudo da memoria (desabilitado)
@param nOpc    , numeric, Indica operacao de inclusao/alteracao/exclusao
@param aIt     , array  , Itens do pedido
@param aParc   , array  , Indica utilizacao de parcelamento (desabilitado) obrigatorio quando SE2*
@param cRelated, string , Indica a tabela do MNT relacionada com a multa (TRX/TS2), utilizado apenas quando cTBL eh "SE2"
@param [aInfos], array  , Informações complementares enviadas na integração:
							[1], numeric, Valor de Desconto.
							[2], string , Observação.

@return Nil
/*/
//---------------------------------------------------------------------
Function NGMUOrder( nRecNo, cTbl, lMem, nOpc, aIt, aParc, cRelated, aInfos )

	Local lOldInclui  := If( Type("Inclui") == "L", Inclui, Nil )
	Local lOldAltera  := If( Type("Altera") == "L", Altera, Nil )
	Local cOldOrdem   := If( Type("cOrdem") == "C", cOrdem, Nil )

	Default aInfos    := { 0.00, '' }
	Default lMem      := .F.

	Private lMemory   := .F.
	Private aItens    := aIt
	Private aParcs    := aParc
	Private cRelat    := cRelated
	Private cTable    := cTbl
	Private lOkPC     := .F.
	Private cDescoTRX := cValToChar( aInfos[1] )
	Private cObserTRX := aInfos[2]

	If !lMemory
		dbSelectArea(cTbl)
		dbGoTo(nRecNo)
	EndIf

	setInclui(.F.)
	setAltera(.F.)

	If nOpc == 3
		setInclui()
	ElseIf nOpc == 4
		setAltera()
	EndIf

	MsgRun('Aguarde integração com backoffice...','Order',;
			{|| FWIntegDef("NGMUORDER", EAI_MESSAGE_BUSINESS, TRANS_SEND, Nil, "NGMUORDER") })

	Inclui := lOldInclui
	Altera := lOldAltera
	cOrdem := cOldOrdem

Return lOkPC

//---------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Integracao com mensagem unica (pedido de compra)

@author Felipe Nathan Welter
@since 14/05/13
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )

	Local cXMLRet, cInternalId, cSolInterId, cAssetCode, cError, cWarning, cProduto, nX, nIns
	Local cStatus, cLocalEst, cProdFer, cCodProd
	Local aXml 	:= {}

	Local nEvent		:= If(Type("Inclui") == "L", If(!Inclui .And. !Altera,5,3), Nil)
	Local lRet			:= .F.
	Local aSTL			:= {}

	Store "" To cXMLRet, cInternalId, cSolInterId, cAssetCode, cError
	Store "" To cWarning, cProduto, cLocalEst, cStatus

	If nTypeTrans == TRANS_RECEIVE

		If cTypeMessage == EAI_MESSAGE_BUSINESS
			lRet := .T.
			cXmlRet := ''

		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE

			oXmlMU := XmlParser(cXML, "_", @cError, @cWarning)

			If oXmlMU <> Nil .And. Empty(cError) .And. Empty(cWarning)

				aXml := NGMUValRes(oXmlMU,STR0009)

				If !aXml[1] //"ERROR"

					lRet := .T.
					lOkPC := .F.
					cXMLRet := aXml[2]

					NGIntMULog("NGMUORDER",cValToChar(nTypeTrans)+"|"+cTypeMessage,cXML)

				Else //"OK"
					// Tabela De/Para

					If Inclui .Or. Altera
						xObj := oXmlMU:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId
						cRefer  := oXmlMU:_TOTVSMessage:_MessageInformation:_Product:_Name:Text
						If cTable == "SC7"
							cAlias  := "SC7"
							cField  := "C7_NUM"
						ElseIf cTable == "SE2"
							cAlias := "SE2"
							cField := "E2_NUM"
						EndIf
						If Type("xObj") == "A"
							For nX := 1 To Len(xObj)
								cValExt := xObj[nX]:_Destination:Text
								cValInt := xObj[nX]:_Origin:Text
								lDelete := .F.
								nOrdem  := 1
								CFGA070Mnt( cRefer, cAlias, cField, cValExt, cValInt, lDelete, nOrdem )
							Next nX
						Else
							cValExt := xObj:_Destination:Text
							cValInt := xObj:_Origin:Text
							lDelete := .F.
							nOrdem  := 1
							CFGA070Mnt( cRefer, cAlias, cField, cValExt, cValInt, lDelete, nOrdem )
						EndIf
					EndIf

					lRet := .T.
					lOkPC := .T.
					cXMLRet := ''
				EndIf
			EndIf


		ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
			cXMLRet := '4.010'
			lRet := .T.
		EndIf

	ElseIf nTypeTrans == TRANS_SEND

		If cTable == "SC7"

			nC7_ITEM    := aSCan(aItens[1], {|x| AllTrim(x[1]) == "C7_ITEM"})
			nC7_PRODUTO := aSCan(aItens[1], {|x| AllTrim(x[1]) == "C7_PRODUTO"})
			nC7_UM      := aSCan(aItens[1], {|x| AllTrim(x[1]) == "C7_UM"})
			nC7_QUANT   := aSCan(aItens[1], {|x| AllTrim(x[1]) == "C7_QUANT"})
			nC7_PRECO   := aSCan(aItens[1], {|x| AllTrim(x[1]) == "C7_PRECO"})
			nC7_CC      := aSCan(aItens[1], {|x| AllTrim(x[1]) == "C7_CC"})

			cInternalId := cEmpAnt+'|'+SC7->C7_FILIAL + '|' + SC7->C7_NUM +'|'+'PC'

			cXMLRet += FWEAIBusEvent( "ORDER", nEvent, { { "InternalId", cInternalId } } )

			cXMLRet += '<BusinessContent>'

			cXMLRet += '	<OrderId>'              		+ SC7->C7_NUM + '</OrderId>'
			cXMLRet += '	<InternalId>'        			+ cInternalId 				+ '</InternalId>'
			cXMLRet += '	<CompanyId>'         			+ cEmpAnt 					+ '</CompanyId>'
			cXMLRet += '	<BranchId>'          			+ cFilAnt 					+ '</BranchId>'
			cXMLRet += '	<CompanyInternalId>' 			+ cEmpAnt + '|' + cFilAnt 	+ '</CompanyInternalId>'
			cXMLRet += '	<RegisterDate>'		  			+ DTOC(SC7->C7_EMISSAO) + '</RegisterDate>'
			cXMLRet += '	<ordertypecode>'				+ '001' + '</ordertypecode>'
			cXMLRet += '	<RegisterHour>'		  			+ Time() + '</RegisterHour>'
			cXMLRet += '	<CustomerCode>'					+ SC7->C7_FORNECE + '</CustomerCode>'
			cXMLRet += '	<CustomerInternalId>'			+ IntForExt(/*cEmpresa*/,/*cFilial*/,SC7->C7_FORNECE,SC7->C7_LOJA,cVerCusto)[2] + '</CustomerInternalId>'
			cXMLRet += '	<PaymentTermCode>'				+ SC7->C7_COND + '</PaymentTermCode>'
			cXMLRet += '	<PaymentConditionInternalId>'	+ IntConExt(/*cEmpresa*/,/*cFilial*/,SC7->C7_COND)[2] + '</PaymentConditionInternalId>'

			cXMLRet += '	<SalesOrderItens>'
			For nX := 1 To Len(aItens)
				cXMLRet += '		<Item>'
				cXmlRet += '			<CompanyId>' 			+ cEmpAnt+ '</CompanyId>'
				cXmlRet += '			<BranchId>' 			+ cFilAnt + '</BranchId>'
				cXmlRet += '			<OrderItem>' 			+ aItens[nX,nC7_ITEM,2] + '</OrderItem>'
				cXmlRet += '			<InternalId>' 			+ cEmpAnt + '|' + cFilAnt + '|' + aItens[nX,nC7_ITEM,2] + '</InternalId>'
				cXmlRet += '			<ItemInternalId>' 		+ IntProExt(/*cEmpresa*/,/*cFilial*/,aItens[nX,nC7_PRODUTO,2])[2] + '</ItemInternalId>'
				cXmlRet += '			<UnitOfMeasureInternalId>' + IntUndExt(/*cEmpresa*/,/*cFilial*/,aItens[nX,nC7_UM,2])[2] + '</UnitOfMeasureInternalId>'
				cXmlRet += '			<Quantity>' 			+ cValToChar(aItens[nX,nC7_QUANT,2]) + '</Quantity>'
				cXmlRet += '			<UnityPrice>' 			+ cValToChar(aItens[nX,nC7_PRECO,2],2) + '</UnityPrice>'
				cXmlRet += '			<TotalPrice>'			+ cValToChar(aItens[nX,nC7_QUANT,2]*aItens[nX,nC7_PRECO,2]) + '</TotalPrice>'
				If nC7_CC > 0
					cXmlRet += '			<CostCenterCode>' 		  + aItens[nX,nC7_CC,2] + '</CostCenterCode>'
					cXmlRet += '			<CostCenterInternalId >'  + IntCusExt(/*cEmpresa*/,/*cFilial*/,aItens[nX,nC7_CC,2])[2] + '</CostCenterInternalId >'
				EndIf
				cXMLRet += '		</Item>'
			Next nX
			cXMLRet += '	</SalesOrderItens>'

			cXMLRet += '</BusinessContent>'

			lRet := .T.

		ElseIf cTable == "SE2"

			If cRelat == "TRX"
				cPROD  := AllTrim(GetNewPar("MV_PRODTRX",""))
				cUM    := NGSEEK('SB1',cPROD,1,'B1_UM')
			ElseIf cRelat == "TS2"
				cPROD  := AllTrim(GetNewPar("MV_PRODTS2",""))
				cUM    := NGSEEK('SB1',cPROD,1,'B1_UM')
			ElseIf cRelat == "TS8"
				cPROD  := AllTrim(GetNewPar("MV_PRODTS8",""))
				cUM    := NGSEEK('SB1',cPROD,1,'B1_UM')
			EndIf

			nVALOR := 0
			aEval(aParcs, {|x| nVALOR += x[2]})

			cInternalId := cEmpAnt+'|'+SE2->E2_FILIAL + '|' + SE2->E2_NUM +'|'+'PP'

			cXMLRet += FWEAIBusEvent( "ORDER", nEvent, { { "InternalId", cInternalId } } )

			cXMLRet += '<BusinessContent>'

			cXMLRet += '	<OrderId>'              		+ SE2->E2_NUM + '</OrderId>'
			cXMLRet += '	<InternalId>'        			+ cInternalId 				+ '</InternalId>'
			cXMLRet += '	<CompanyId>'         			+ cEmpAnt 					+ '</CompanyId>'
			cXMLRet += '	<BranchId>'          			+ cFilAnt 					+ '</BranchId>'
			cXMLRet += '	<CompanyInternalId>' 			+ cEmpAnt + '|' + cFilAnt 	+ '</CompanyInternalId>'
			cXMLRet += '	<RegisterDate>'		  			+ DTOC(SE2->E2_EMISSAO) + '</RegisterDate>'
			cXMLRet += '	<ordertypecode>'				+ '000' + '</ordertypecode>'
			cXMLRet += '	<RegisterHour>'		  			+ Time() + '</RegisterHour>'
			cXMLRet += '	<CustomerCode>'					+ SE2->E2_FORNECE + '</CustomerCode>'
			cXMLRet += '	<CustomerInternalId>'			+ IntForExt(/*cEmpresa*/,/*cFilial*/,SE2->E2_FORNECE,SE2->E2_LOJA,cVerCusto)[2] + '</CustomerInternalId>'
			
			cXMLRet += 		'<Observation>' + cObserTRX + '</Observation>'

			cXmlRet += 		'<Discounts>'
			cXmlRet += 			'<Discount>' + cDescoTRX + '</Discount>'
			cXmlRet += 		'</Discounts>'

			cXMLRet += '	<SalesOrderItens>'
			cXMLRet += '		<Item>'
			cXmlRet += '			<CompanyId>' 			+ cEmpAnt+ '</CompanyId>'
			cXmlRet += '			<BranchId>' 			+ cFilAnt + '</BranchId>'
			cXmlRet += '			<OrderItem>' 			+ '001' + '</OrderItem>'
			cXmlRet += '			<InternalId>' 			+ cInternalId + '|' + '001' + '</InternalId>'
			cXmlRet += '			<ItemInternalId>' 		+ IntProExt(/*cEmpresa*/,/*cFilial*/,cPROD)[2] + '</ItemInternalId>'
			cXmlRet += '			<UnitOfMeasureInternalId>' + IntUndExt(/*cEmpresa*/,/*cFilial*/,cUM)[2] + '</UnitOfMeasureInternalId>'
			cXmlRet += '			<Quantity>' 			+ cValToChar(Round( 1 ,2)) + '</Quantity>'
			cXmlRet += '			<UnityPrice>' 			+ cValToChar(nVALOR) + '</UnityPrice>'
			cXmlRet += '			<TotalPrice>'			+ cValToChar(nVALOR) + '</TotalPrice>'
			
			If !Empty(SE2->E2_CCD)
				cXmlRet += '			<CostCenterCode>' 		  + SE2->E2_CCD + '</CostCenterCode>'
				cXmlRet += '			<CostCenterInternalId >'  + IntCusExt(/*cEmpresa*/,/*cFilial*/,SE2->E2_CCD)[2] + '</CostCenterInternalId >'
			EndIf

			cXMLRet += '		</Item>'
			cXMLRet += '	</SalesOrderItens>'

			cXMLRet += '	<PAYMENTPLAN>'
			
			For nX := 1 To Len(aParcs)
				cParcIntId := cEmpAnt + '|' + SE2->E2_FILIAL + '|' + SE2->E2_PREFIXO + '|' + SE2->E2_NUM + '|' +;
									aParcs[nX,3]/*SE2->E2_PARCELA*/ + '|' + SE2->E2_TIPO + '|' + SE2->E2_FORNECE + '|' + SE2->E2_LOJA
				cXMLRet += '		<TERM>'
				cXmlRet += '			<InternalId>' 					+ cParcIntId + '</InternalId>'
				cXmlRet += '			<datereference>' 				+ DTOC(SE2->E2_EMISSAO) + '</datereference>'
				cXmlRet += '			<termduedate>' 				+ DTOC(aParcs[nX,1]/*SE2->E2_VENCTO*/) + '</termduedate>'
				cXmlRet += '			<termamount>' 					+ cValToChar(aParcs[nX,2]/*SE2->E2_VALOR*/) + '</termamount>'
				cXMLRet += '		</TERM>'
			Next nX

			cXMLRet += '	</PAYMENTPLAN>'
			cXMLRet += '</BusinessContent>'

			lRet := .T.

		EndIf

	EndIf

	//ajusta o XML pois com o caracter < o parser espera uma tag XML
	cXmlRet := StrTran(cXmlRet,'< --',':::')

	//Ponto de entrada para alteração do XML
	If ExistBlock("NGMUPE01")
   		cXMLRet := ExecBlock("NGMUPE01",.F.,.F.,{cXmlRet, lRet, "NGMUOrder", 1, nTypeTrans, cTypeMessage})
	EndIf

Return { lRet, cXMLRet }
