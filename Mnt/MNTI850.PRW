#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "NGMUCH.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Funcao de tratamento para o recebimento/envio de mensagem unica de
cadastro de atividades da parte diária.

@author Felipe Nathan Welter
@param cXML	Variavel com conteudo xml para envio/recebimento.
@param nTypeTrans	Tipo de transacao. (Envio/Recebimento)
@param cTypeMessage	Tipo de mensagem. (Business Type, WhoIs, etc)
@since 09/07/13
@version P11
@return aArray sendo [1]-.T./.F. e [2]-cError
/*/
//---------------------------------------------------------------------
Function MNTI850( cXML, nTypeTrans, cTypeMessage, nOpe )

	Local lRet        := .F.
	Local cXMLRet     := ""
	Local cError      := ""
	Local cWarning    := ""
	Local cInternalId := ""
	Local nOperation  := nOpe
	Local nX          := 0
	Local aXml		  := {}

	Private oXmlM850 := Nil
	Private oTV0     := Nil

	If nTypeTrans == TRANS_RECEIVE
		If cTypeMessage == EAI_MESSAGE_BUSINESS

			oXmlM850 := XmlParser(cXml, "_", @cError, @cWarning)
			If oXmlM850 <> Nil .And. Empty(cError) .And. Empty(cWarning)

				//carrega dados do XML
				oTV0 := oXmlM850:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT

				//carrega model para gravar dados
				oModel := FWLoadModel( "MNTA850" )

				If Type("oTV0:_CODE") <> "U"

					//------------------------------------------------------------------------------------------
					If Upper(oXmlM850:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"

						//carrega operacao para o model
						TV0->(dbSetOrder(01))
						If TV0->(dbSeek(xFilial("TV0")+oTV0:_CODE:Text))
							nOperation := MODEL_OPERATION_UPDATE
						Else
							nOperation := MODEL_OPERATION_INSERT
						EndIf

						//carrega model para gravar dados
						oModel:SetOperation( nOperation )
						lRet := oModel:Activate()

						If lRet

							If nOperation == MODEL_OPERATION_INSERT
								If Type("oTV0:_CODE") <> "U"
									lRet := oModel:SetValue( "MNTA850" + '_TV0', 'TV0_CODATI', oTV0:_CODE:Text)
								EndIf
							EndIf

							If lRet .And. Type("oTV0:_DESCRIPTION") <> "U"
								lRet := oModel:SetValue( "MNTA850" + '_TV0', 'TV0_NOME', oTV0:_DESCRIPTION:Text)
							EndIf
						EndIf

					ElseIf Upper(oXmlM850:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"

						//carrega model para gravar dados
						TV0->(dbSetOrder(01))
						If !TV0->(dbSeek(xFilial("TV0")+oTV0:_CODE:Text))
							lRet := .F.
							cXmlRet := 'Registro não localizado'
						Else
							oModel:SetOperation( MODEL_OPERATION_DELETE )
							lRet := oModel:Activate()
						EndIf

					EndIf

					//------------------------------------------------------------------------------------------
					//grava os dados
					If lRet
						If ( lRet := oModel:VldData() )
							lRet := oModel:CommitData()
						EndIf
					EndIf

					//------------------------------------------------------------------------------------------
					//verifica a existencia de erros pos-gravacao
					If oModel:isActive()
						If !lRet
							aErro   := oModel:GetErrorMessage()
							cXMLRet := AllToChar( aErro[5] ) + ':' //[5] Id do erro
							cXMLRet += AllToChar( aErro[6] )  //[6] mensagem do erro
							cXMLRet += AllToChar( aErro[7] )  //[7] mensagem da solução
						EndIf
						oModel:DeActivate()
					EndIf

				Else
					lRet := .F.
					cXMLRet := 'Falha ao manipular XML'
				EndIf

			Else
				lRet := .F.
				cXMLRet := 'Falha ao manipular XML'

			EndIf

		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE

			// cXMLRet := '<TAGX>TESTE DE RECEPCAO RESPONSE MESSAGE</TAGX>'

			oXmlMU := XmlParser( cXML, "_", @cError, @cWarning )

			If oXmlMU <> Nil .And. Empty(cError) .And. Empty(cWarning)

			aXml := NGMUValRes(oXmlMU,STR0004)

				If !aXml[1] //"ERROR" - Houve erro no recebedor da minha BusinessMessage

					lRet     := .F.
					cXMLRet  := aXml[2]

					NGIntMULog( "MNTI850",cValToChar( nTypeTrans ) + "|" + cTypeMessage,cXML )

				Else //"OK" - A BusinessMessage que enviei esta foi processada e esta ok

					// Tabela De/Para
					xObj := oXmlMU:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId
					cRefer  := oXmlMU:_TOTVSMessage:_MessageInformation:_Product:_Name:Text
					cAlias  := "TV0"
					cField  := "TV0_CODATI"
					If Type( "xObj" ) == "A"
						For nX := 1 To Len( xObj )
							cValExt := xObj[nX]:_Destination:Text
							cValInt := xObj[nX]:_Origin:Text
							lDelete := .F.
							nOrdem  := 1
							CFGA070Mnt( cRefer,cAlias,cField,cValExt,cValInt,lDelete,nOrdem )
						Next nX
					Else
						cValExt := xObj:_Destination:Text
						cValInt := xObj:_Origin:Text
						lDelete := .F.
						nOrdem  := 1
						CFGA070Mnt( cRefer,cAlias,cField,cValExt,cValInt,lDelete,nOrdem )
					EndIf
					lRet     := .T.
					cXMLRet  := ""
				EndIf
			EndIf

		ElseIf cTypeMessage == EAI_MESSAGE_WHOIS

			lRet := .T.
			cXMLRet := '1.000'
		EndIf

	ElseIf nTypeTrans == TRANS_SEND

		cInternalId := cEmpAnt + '|' + TV0->TV0_FILIAL + '|' + TV0->TV0_CODATI

		cXMLRet += FWEAIBusEvent( 'ACTIVITY', nOperation, { { "InternalId", cInternalId } } )

		cXMLRet += '<BusinessContent>'

		cXMLRet += '	<CompanyId>'         + cEmpAnt                 	+ '</CompanyId>'
		cXMLRet += '	<BranchId>'          + cFilAnt                 	+ '</BranchId>'
		cXMLRet += '	<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt	+ '</CompanyInternalId>'
		cXMLRet += '	<InternalId>'        + cInternalId             	+ '</InternalId>'
		cXMLRet += '	<Code>'				   + TV0->TV0_CODATI 	     	+ '</Code>'
		cXMLRet += '	<Description>' 	   + TV0->TV0_NOME 				+ '</Description>'

		cXMLRet += '</BusinessContent>'

		lRet := .T.

	EndIf

	cXMLRet := EncodeUTF8(cXMLRet)

Return { lRet, cXMLRet }