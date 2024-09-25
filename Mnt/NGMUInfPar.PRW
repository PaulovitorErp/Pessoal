#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "NGMUCH.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} NGMUInfPar
Integracao com mensagem unica para o retorno de pagamentos de titulos
a pagar (pedido de compra no backoffice). Utilizada no processo de
baixa de multas, documentos e honorarios.

@author Felipe Nathan Welter
@since 04/06/13
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function NGMUInfPar()

	MsgRun('Aguarde integração com backoffice...','InfoOfParcelValues',;
			{|| FWIntegDef("NGMUINFPAR", EAI_MESSAGE_BUSINESS, TRANS_SEND, Nil, "NGMUINFPAR") })

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Integracao com mensagem unica para o retorno de pagamentos de titulos
a pagar (pedido de compra no backoffice).

@author Felipe Nathan Welter
@since 14/05/13
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )

	Local cXMLRet := ''
	Local lRet := .T.
	Local nX, cError := '', cWarning := ''

	Private cDiscAm     := '0.00'
	Private lMsErroAuto := .F.

	If nTypeTrans == TRANS_RECEIVE

		If cTypeMessage == EAI_MESSAGE_BUSINESS

			oXmlMU := XmlParser(cXML, "_", @cError, @cWarning)

			If oXmlMU <> Nil .And. Empty(cError) .And. Empty(cWarning)

				cIntId     := oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
				cOrdIntId  := oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OrderInternalId:Text
				cParcIntId := oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ParcelInternalId:Text
				cDocIntId  := oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentInternalId:Text
				cDocType   := oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentType:Text
				cDateRef   := oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DateReference:Text
				cParcDueD  := oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ParcelDueDate:Text
				cParcDueD  := SubStr(cParcDueD,1,At(' ',cParcDueD)-1)
				dLastPayD  := SToD( StrTran( SubStr( oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_LastPaymentDate:Text, 1, 10 ), '-', '' ) )
				cParcelAm  := StrTran(oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ParcelAmount:Text,',','.')
				If Type("oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DiscountAmount:Text") <> "U"
					cDiscAm    := StrTran(oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DiscountAmount:Text,',','.')
				EndIf
				cAmounP    := StrTran(oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AmountPaid:Text,',','.')
				cStatus    := oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Status:Text
				cObserv    := oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Observation:Text

				cRefer  := oXmlMU:_TOTVSMessage:_MessageInformation:_Product:_Name:Text
				cAlias  := "SE2"
				cField  := "E2_NUM"
				cValExt := cParcIntId
				cParcela := RTrim(CFGA070Int( cRefer, cAlias, cField, cValExt ))

				If !Empty(cParcela)
					//nao foi  possivel usar StrTokArr pois algumas chaves contém pipe
					aParcela := {} //cEmpAnt|SE2->E2_FILIAL|SE2->E2_PREFIXO|SE2->E2_NUM|SE2->E2_PARCELA|SE2->E2_TIPO|E2_FORNECE|E2_LOJA
					cTxt := cParcela
					aFields := {"","E2_FILIAL","E2_PREFIXO","E2_NUM","E2_PARCELA","E2_TIPO","E2_FORNECE","E2_LOJA"}
					For nX := 1 To 8
						nIni := 1
						nFim := If(nX==1,Len(cEmpAnt),TAMSX3(aFields[nX])[1])
						aAdd(aParcela,SubStr(cTxt,nIni,nFim))
						cTxt := SubStr(cTxt,nFim+2)
					Next nX

					dbSelectArea("SE2")
					dbSetOrder(01)

					oFin := NGIntFin():New()

					If oFin:load({aParcela[2]+aParcela[3]+aParcela[4]+aParcela[5]+aParcela[6]+aParcela[7]+aParcela[8]})

						If cStatus $ "01/02"

							If Val(cAmounP) + Val(cDiscAm) > 0
							//quando é realizado pagamento de juros, multas e etc que nao contabilizam sobre o valor original da parcela
							//pode ocorrer de ser enviado um valor 0. nesse caso o FINA080/baixaParcela() realiza uma baixa total,
							//por isso o MNT nao realiza a baixa mas retorna OK ao backoffice.
								If !oFin:baixaParcela( dLastPayD, cObserv, Val( cAmounP ), Val( cDiscAm ) )

									cXMLRet := oFin:getErrorList()[1]
									lRet := .F.

								EndIf

							EndIf

						ElseIf cStatus $ "00"

							If !oFin:cancelBaixa(dDataBase,cObserv)
								cXMLRet := oFin:getErrorList()[1]
								lRet := .F.
							EndIf

						EndIf

					Else
						cXmlRet := "A parcela não foi localizada."
						lRet := .F.
					EndIf
				Else
					cXmlRet := "A parcela não foi localizada."
					lRet := .F.
				EndIf
			EndIf

		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE

//			cXMLRet := ''
//			lRet := .T.

		ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
			cXMLRet := '1.000'
			lRet := .T.
		EndIf

	ElseIf nTypeTrans == TRANS_SEND
		cXMLRet := ''
		lRet := .T.
	EndIf

	//ajusta o XML pois com o caracter < o parser espera uma tag XML
	cXmlRet := StrTran(cXmlRet,'< --',':::')

Return { lRet, cXMLRet }
