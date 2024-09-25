#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "NGMUCH.CH"

#DEFINE __WHOIS__ '1.000|1.001' //Versão mensagem suportada pelo adapter
#DEFINE __ADAPT__ 'NGMUSTOLVL' //Adapter
#DEFINE __DESCR__ 'StockLevel' //Nome da mensagem unica

//Declara versões das mensagens utilizadas nos InternalId's
Static cVersao	 := RTrim(PmsMsgUVer('STOCKLEVEL'	, 'NGMUSTOLVL')) //Consulta Saldo
Static cVersaoLoc := RTrim(PmsMsgUVer('WAREHOUSE'	, 'AGRA045')) //Local
Static cVersaoPro := RTrim(PmsMsgUVer('ITEM'		, 'MATA010')) //Produto

//----------------------------------------------------------------------------------------
/*/{Protheus.doc} NGMUStoLvl
Realiza chamada para a função responsável pela integração com mensagem
única (IntegDef) para Consulta de Saldo.
@type function

@author Hugo R. Pereira / Felipe Nathan Welter
@since 18/07/2012

@sample NGMUStoLvl( '08.05', '01', .T., 'M', 'Func001' ) - Mão de Obra
@sample NGMUStoLvl( '01.86', '01', .T. ) - Produto

@param cProduto  , Caracter, Código do produto.
@param cArmazem  , Caracter, Código do local de estoque.
@param [lEmpenho], Lógico  , Indica se deve substrair quantidade empenhada do total.
@param [cTypeIns], Caracter, Indica o tipo de insumo que será consultado.
@param [cInsMOD] , Caracter, Caso seja insumo mão-de-obra, define o código do funcionário.
@param [lNoSeek] , boolean , Indica que não haverá necessidade de confirmação da existência de 
registro realcionado ao produto consultado na SB2.

@return Númerico , Saldo atual do produto consultado ( SB2->B2_QATU ).
/*/
//----------------------------------------------------------------------------------------
Function NGMUStoLvl( cProduto, cArmazem, lEmpenho, cTypeIns, cInsMOD, lNoSeek )

	Local nRetSaldo  := 0

	Private cTypePrd := ''
	Private cCodeMOD := ''
	Private cCodePrd := ''
	Private cWareHou := ''
	Private lAllWH   := .F. // Indica se a consulta será ou não, realizada para o produto em todos os locais de estoque.

	Default lEmpenho := .F.
	Default lNoSeek  := .F.
	Default cTypeIns := ''
	Default cInsMOD  := ''
	
	// Não exige que exista uma SB2 para o produto, sendo criada com o retorno da M.U.
	If lNoSeek

		lAllWH   := .T. // Consulta realizada para o produto em todos os locais de estoque.
		cCodePrd := cProduto

	// Somente processa a M.U. se já existir uma SB2 para o produto.
	Else

		dbSelectArea("SB2")
		dbSetOrder(1)
		If msSeek( FWxFilial( 'SB2' ) + cProduto + cArmazem )
		
			cTypePrd := IIf( !Empty( cTypeIns ), cTypeIns, '' )
			cCodeMOD := IIf( !Empty( cInsMOD ) , cInsMOD , '' )
			cCodePrd := SB2->B2_COD
			cWareHou := SB2->B2_LOCAL

		Else

			/*-------------------------------------------------+
			| Inclui um registro na SB2 para o produto + local |
			+-------------------------------------------------*/
			CriaSB2( cProduto, cArmazem )

			cTypePrd := cTypeIns
			cCodeMOD := cInsMOD
			cCodePrd := SB2->B2_COD
			cWareHou := SB2->B2_LOCAL

		EndIf

		

	EndIf

	MsgRun( STR0023, __DESCR__,	{ || FWIntegDef( __ADAPT__, EAI_MESSAGE_BUSINESS,; // Aguarde integração com backoffice...
		TRANS_SEND, Nil, __ADAPT__ ) } )

	If !lNoSeek

		// Saldo atual retornado pela M.U.
		nRetSaldo := SB2->B2_QATU

		// Dedução da quantidade empenhada, quando solicitado por parâmetro.
		If lEmpenho
			nRetSaldo -= SB2->B2_QEMP  // B2_QEMPN
		EndIf

	EndIf

Return nRetSaldo

//---------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Integracao com Mensagem Unica.
- Consulta de Saldo. [SB2]

@author Hugo R. Pereira
@author Felipe Nathan Welter
@since 18/07/12
@version MP11
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

	//Ponto de entrada para alteração do XML
	If ExistBlock("NGMUPE01")
   		cXMLRet := ExecBlock("NGMUPE01",.F.,.F.,{cXmlRet, lRet, __ADAPT__, 1, nTypeTrans, cTypeMessage})
	EndIf

Return { lRet, cXMLRet }

//-------------------------------------------------------------------
/*/{Protheus.doc} fSendXML
Mensagem de envio

@author  Lucas Guszak
@version P11
@since   21/05/2014
/*/
//-------------------------------------------------------------------
Static Function fSendXML()

	Local lRet        := .T.
	Local cXMLSend    := ""
	Local cInternalId := ""
	Local cLocalEstoq := ""
	Local cProduct    := IIf( !Empty( cTypePrd ), NGMURetIns( cTypePrd, cCodeMOD ), cCodePRD )

	If cVersao == '1.000'
		cInternalId := xFilial( 'SB1' ) + '|' + cProduct
		cLocalEstoq := xFilial( 'NNR' ) + '|' + cWareHou
	Else
		cInternalId := IntProExt( /*cEmpresa*/, /*cFilial*/, cProduct, cVersaoPro )[2]
		cLocalEstoq := IntLocExt( /*cEmpresa*/, /*cFilial*/, cWareHou, cVersaoLoc )[2]
	EndIf

	cXMLSend += FWEAIBusRequest( Upper(__DESCR__) )

	cXMLSend += '<BusinessContent>'
	cXMLSend += '	<RequestItem>'
	cXMLSend += '		<ItemInternalId>'     + cInternalId + '</ItemInternalId>'

	If !lAllWH
		cXMLSend += '	<WarehouseInternalId>'+ cLocalEstoq + '</WarehouseInternalId>'
	EndIf

	cXMLSend += '	</RequestItem>'
	cXMLSend += '</BusinessContent>'

	atualizaSB2() //zera o saldo. caso a consulta online nao esteja operando, a rotina
	//utiliza como procedimento padrao a consulta sobre saldo 0, o que forca a geracao de
	//solicitacao de compra/armazem. e' preferivel que haja solicitacao desnecessãria a ser
	//administrada do que a falta de produto em estoque sem solicitacao de compra

Return {lRet, cXMLSend}

//-------------------------------------------------------------------
/*/{Protheus.doc} fRespXML
Mensagem de retorno

@author  Lucas Guszak
@version P11
@since   21/05/2014
/*/
//-------------------------------------------------------------------
Static Function fRespXML(cXML, nTypeTrans, cTypeMessage)

	Local lRet 		:= .F.
	Local cError 	:= ""
	Local cWarning 	:= ""
	Local cXMLResp 	:= ""
	Local aRetXML 	:= {}
	Local aXml 		:= {}

	oXmlMU := XmlParser(cXML, "_", @cError, @cWarning)

	If oXmlMU <> Nil .And. Empty(cError) .And. Empty(cWarning)
		aXml := NGMUValRes(oXmlMU,"")

		//Retorno da mensagem XML não apresenta problemas, possui cosistencia em outro ambiente integrado
		If aXml[1] // "OK"
			aRetXML	:= fOkRet(oXmlMU, cXML, nTypeTrans, cTypeMessage)
			lRet		:= aRetXML[1]
			cXMLResp	:= aRetXML[2]

		//Retorno da mensagem XML apresenta problemas, não possui cosistencia em outro ambiente integrado
		Else //"ERROR"
			lRet		:= .F.
			cXMLResp	:= aXml[2]
		EndIf
	EndIf

Return {lRet, cXMLResp}

//-------------------------------------------------------------------
/*/{Protheus.doc} fOkRet
Atualiza o estoque com as informacoes do retorno da mensagem, mas se o
retorno for incosistente com o SigaMNT, apresenta erro

@author  Lucas Guszak
@version P11
@since   21/05/2014
/*/
//-------------------------------------------------------------------
Static Function fOkRet(oXmlMU, cXML, nTypeTrans, cTypeMessage)

	Local aAux := {}
	Local lRet := .T.
	Local cObs := ""
	Local cXMLOk := ""

	//Valida e instancia a atualizacao de estoque
	aAux := atualizaSB2(oXmlMU)
	If !aAux[1]
		lRet := aAux[1]
		cXMLOk := aAux[2]
		cObs := STR0015+AllTrim(SB2->B2_COD)+"."+CRLF  //"Problema com o backoffice na consulta de saldo online para o produto "
		cObs += STR0005+cXMLOk  //'Motivo: '
		MsgAlert(cObs+CRLF+STR0007,STR0008)  //"Para mais detalhes consulte o log do EAI."##"Integração BackOffice"
		NGIntMULog(__ADAPT__,cValToChar(nTypeTrans)+"|"+cTypeMessage,cXML)
	Else
		lRet := aAux[1]
	EndIf

Return {lRet, cXMLOk}

//---------------------------------------------------------------------
/*/{Protheus.doc} atualizaSB2
Atualiza o saldo da tabela SB2.

@param oXmlMU	XML recebido no layout StockTurnOver, atualiza saldo com base no arquivo,
            	ou zera saldo no caso de nao passar parametro
@author Felipe Nathan Welter
@author Hugo R. Pereira
@since 18/07/12
@version MP11
@return cError descricao do erro (se houver)
/*/
//---------------------------------------------------------------------
Static Function atualizaSB2(oXmlMU)

	Local nIndex     := 0
	Local cReference := ''
	Local cCloseDate := ''
	Local aRet       := { .T., '' }

	If oXmlMU <> Nil

		//Código do produto de integração RM/DataSul...
		cReference := oXmlMU:_TOTVSMessage:_MessageInformation:_Product:_Name:Text
		cCloseDate := fConverte( oXmlMU:_TOTVSMessage:_ResponseMessage:_ReturnContent, 'D', .F., 'ClosingStockDate' )
		
		If ValType( oXmlMU:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ReturnItem ) == 'A'

			For nIndex := 1 To Len( oXmlMU:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ReturnItem )

				aRet := fUpsertSB2( oXmlMU:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ReturnItem[nIndex], cReference )

				If !aRet[1]
					Loop
				EndIf

			Next nIndex

		Else

			aRet := fUpsertSB2( oXmlMU:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ReturnItem, cReference )

		EndIf

		//-------------------------------------------
		//ATUALIZACAO DA DATA DE FECHAMENTO DE ESTOQUE
		//-------------------------------------------
		If cVersao <> '1.000' .And. cCloseDate <> nil .And. !Empty(cCloseDate)

			//Atualiza data do ultimo fechamento de estoque
			PutMV("MV_ULMES",cCloseDate)
		EndIf

	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fConverte
Converte os valores provenientes do XML

@param   oXml XML recebido no layout ValidateCustomerVendor
@param   cTipoRet Tipo do retorno
@param   cElement Elemento da mensagem.

@author  Lucas Guszak
@version P11
@since   20/05/2014
/*/
//-------------------------------------------------------------------
Static Function fConverte( oXmlMU, cTipoRet, lItem, cElement )

	Local xValor   := If(cTipoRet == "N",0,nil)
	Local cContent := 'oXmlMU:' + '_' + cElement + ':Text'

	If !Empty( &( cContent ) )
		Do Case
			Case cTipoRet == "C"
				xValor := &(cContent)
			Case cTipoRet == "N"
				xValor := Val(&(cContent))
			Case cTipoRet == "D"
				xValor := StrTran(SubStr(&(cContent),1,10),'-','')
			Case cTipoRet == "L"
				xValor := If(&(cContent)=="true",.T.,.F.)
		EndCase
	EndIf

Return xValor

//-------------------------------------------------------------------
/*/{Protheus.doc} fUpsertSB2
Atualiza/Inclui registro na SB2 referente ao produto retornado pela M.U.
@type function

@author  Alexandre Santos
@since   26/04/2021

@param   oXml      , Object, XML recebido pela M.U.
@param   cReference, Referência no De/Para. ( RM ou Protheus )

@return
/*/
//-------------------------------------------------------------------
Static Function fUpsertSB2( oXML, cReference )

	Local cProdIntId  := fConverte( oXml, 'C', .T., 'ItemInternalId'           )
	Local cLocalIntId := fConverte( oXml, 'C', .T., 'WarehouseInternalId'      )
	Local nAvailable  := fConverte( oXml, 'N', .T., 'AvailableStockAmount'     )
	Local nBooked     := fConverte( oXml, 'N', .T., 'BookedStockAmount'        )
	Local nValueOfCSA := fConverte( oXml, 'N', .T., 'ValueOfCurrentStockAmount')
	Local nAverageUIC := fConverte( oXml, 'N', .T., 'AverageUnitItemCost'      )
	
	Local cError      := ''
	Local cFilProd    := ''
	Local cProduto    := ''
	Local cLocal      := ''
	Local aAux        := {}
	Local lRet        := .T.

	If !Empty( cProdIntId ) .And. !Empty( cLocalIntId )

		// Valida De/Para de Produto
		aAux := IntProInt( cProdIntId, cReference, cVersaoPro )
		If !aAux[1]
			lRet   := aAux[1]
			cError := aAux[2]
		Else
			cFilProd := PadR( aAux[2,2], FWSizeFilial() )
			cProduto := PadR( aAux[2,3], TamSX3( 'B2_COD' )[1] )
		EndIf

		// Valida De/Para de Local
		aAux := IntLocInt( cLocalIntId, cReference, cVersaoLoc )
		If !aAux[1]
			lRet   := aAux[1]
			cError := aAux[2]
		Else
			cLocal	:= PadR( aAux[2,3], TamSX3( 'NNR_CODIGO' )[1] )
		EndIf

		// Atualização de saldos dos produtos
		If lRet
			
			dbSelectArea( 'SB2' )
			dbSetOrder( 1 )
			If !dbSeek( NGTROCAFILI( 'SB2', cFilProd ) + cProduto + cLocal )
				CriaSB2( cProduto, cLocal )
			EndIf

			// Somente atualiza para saldos com status disponivel.
			If SB2->B2_STATUS != '2'

				// Atualiza manualmente valores de saldo na tabela SB2
				RecLock("SB2",.F.)
				SB2->B2_QEMP  := nBooked	 // Quantidade Empenhada
				SB2->B2_QATU  := nAvailable  // Saldo Atual
				SB2->B2_VATU1 := nValueOfCSA // ValueOfCurrentStockAmount
				SB2->B2_CM1   := nAverageUIC // AverageUnitItemCost # UnitItemCost
				SB2->( MsUnLock() )
			
			EndIf

		EndIf

	EndIf
	
Return { lRet, cError }
