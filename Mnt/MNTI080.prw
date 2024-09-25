#Include "Protheus.CH"
#Include "FWADAPTEREAI.CH"
#Include "NGMUCH.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTI080
Integração via mensagem única do cadastro de Bens

@param String cXml: indica conteúdo da mensagem única
@param Integer nTypeTrans: indica tipo de transação
@param String cTypeMessage: indica tipo de mensagem

Obs.: o array aParamMensUn usado pela integração trata-se de uma variável private que deverá ser declarada
	na rotina que faz uso da integração. Estrutura:
	aParamMensUn[1] := Recno() // Indica numero do registro
	aParamMensUn[2] := nOPCAO  // Indica tipo de operação que esta invocando a mensagem unica
	aParamMensUn[3] := .F.     // Indica que se deve recuperar dados da memória
	aParamMensUn[4] := 1       // Indica se deve inativar o bem (1 ativo,2 - inativo)

@author André Felipe Joriatti
@since 21/06/2013
@version P11
@return { lRet, cXMLRet }: Boolean lRet: indica que foi transferido, executado com sucesso
 						   String cXMLRet: indica conteúdo da mensagem única a ser transferida
/*/
//---------------------------------------------------------------------

Function MNTI080( cXml,nTypeTrans,cTypeMessage )

	Local lRet     := .F.
	Local cXMLRet  := ""
	Local cError   := ""
	Local cWarning := ""
	Local cErroIns := ""
	Local nX       := 0

	Local cInternalId   := ""
	Local cCodUnidMed   := ""
	Local nCpcty        := 0
	Local cUnimedCpProd := ""
	Local cFilialST9    := ""
	Local cFilialTPE    := ""
	Local nEvent        := 0
	Local cDescFamil    := ""
	Local dPurchaseDt   := CTOD( "" )

	Local nOpcx2  := 0
	Local nStatus := 0

	Local cPrefixST9 := ""
	Local cPrefixTPE := ""

	Local cCT    := "" // Usado para identificar o Centro de Trabalho Destino
	Local cCC    := "" // Usado para identificar o Centro de Custo Destino
	Local nCont1 := 0  // Usado para identificar o contador 1
	Local nCont2 := 0  // Usado para identificar o contador 2

	Local cAliasGet := GetNextAlias()
	Local lUnid1ST6 := NGCADICBASE( "T6_UNIDAD1","A","ST6",.F. )

	Local aXml := {}

	DbSelectArea( "ST9" )
	If Type( "aParamMensUn" ) != "A"

		aParamMensUn    := Array( 4 )
		aParamMensUn[1] := ST9->( RecNo() )
		aParamMensUn[2] := 3
		aParamMensUn[3] := .F.
		aParamMensUn[4] := 1

	EndIf

	nOpcx2  := aParamMensUn[2]
	nStatus := aParamMensUn[4]

	cPrefixST9 := If( aParamMensUn[3],"M","ST9" )
	cPrefixTPE := If( aParamMensUn[3],"M","TPE" )

	// Posiciona no registro conforme recno informado nos parametros
	ST9->( DbGoTo( aParamMensUn[1] ) )

	// Inicia processamentos de recebimento/transferencia

	// Indica transação de recebimento
	If nTypeTrans == TRANS_RECEIVE

		// Indica que se está recebendo uma mensagem de negócio (mensagem única com dados de integração)
		// Não será implementado neste momento.
		If cTypeMessage == EAI_MESSAGE_BUSINESS

			lRet    := .F.
			cXMLRet := ""

		// Indica que se esta recebendo uma mensagem do tipo Response, ou seja, resultado do processamento síncrono
		// de uma BusinessMessage enviada
		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE

			oXmlMU := XmlParser( cXML, "_", @cError, @cWarning )

			If oXmlMU <> Nil .And. Empty(cError) .And. Empty(cWarning)

				aXml := NGMUValRes(oXmlMU,STR0004)

				If !aXml[1] //"ERROR" - Houve erro no recebedor da minha BusinessMessage
					lRet     := .F.
					cXMLRet  := aXml[2]

					NGIntMULog( "MNTI080",cValToChar( nTypeTrans ) + "|" + cTypeMessage,cXML )

				Else // "OK" - A BusinessMessage que enviei esta foi processada e esta ok

					// Tabela De/Para
					xObj := oXmlMU:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId
					cRefer  := oXmlMU:_TOTVSMessage:_MessageInformation:_Product:_Name:Text
					cAlias  := "ST9"
					cField  := "T9_CODBEM"
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


		ElseIf cTypeMessage == EAI_MESSAGE_WHOIS // Tipo de solicitação para recuperar a versão

			cXMLRet := "1.002"
			lRet    := .T.

		Endif

	ElseIf nTypeTrans == TRANS_SEND // Tipo de Transação do tipo envio de dados

		//-------------------------------------
		// Gera mensagem com cadastro do Bem
		//-------------------------------------
		cFilialST9 := If( cPrefixST9 == "M",xFilial( "ST9" ),ST9->T9_FILIAL )
		cFilialTPE := If( cPrefixST9 == "M",xFilial( "TPE" ),TPE->TPE_FILIAL )
		DbSelectArea( "ST9" )
		cInternalId := cEmpAnt + "|" + cFilialST9 + "|" + &( cPrefixST9 + "->T9_CODBEM" )
		cCodUnidMed := If ( lUnid1ST6,NGSEEK( "ST6",&( cPrefixST9 + "->T9_CODFAMI" ),01,"ST6->T6_UNIDAD1" ),"" )
		dPurchaseDt := &( cPrefixST9 + "->T9_DTCOMPR" )

		nCpcty        := NGSEEK( "TQR",&( cPrefixST9 + "->T9_TIPMOD"  ),01,"TQR->TQR_CPPROD" ) // Capacidade Produtiva
		cUnimedCpProd := NGSEEK( "TQR",&( cPrefixST9 + "->T9_TIPMOD"  ),01,"TQR->TQR_UNPROD" ) // Unidade Capacidade Produtiva
		cDescFamil    := NGSEEK( "ST6",&( cPrefixST9 + "->T9_CODFAMI" ),01,"ST6->T6_NOME"    ) // Desricao da Familia

		nEvent := If ( nOpcx2 == 5,nOpcx2,4 )
		cXMLRet += FWEAIBusEvent( "EQUIPMENT",nEvent,{ { "InternalId", cInternalId } } )

		cCC := &( cPrefixST9 + "->T9_CCUSTO"  )
		cCT := &( cPrefixST9 + "->T9_CENTRAB" )

		nCont1 := &( cPrefixST9 + "->T9_POSCONT" )

		If IsInCallStack( "MNTA550" ) .And. nStatus == 1
			cCT    := M->TQ2_CENTRA
			cCC    := M->TQ2_CCUSTO
			nCont1 := M->TQ2_POSCON
			nCont2 := M->TQ2_POSCO2
		ElseIf IsInCallStack( "MNTA470" )
			cCC    := M->TPN_CCUSTO
			cCT    := M->TPN_CTRAB
			nCont1 := M->TPN_POSCON
			nCont2 := M->TPN_POSCO2
		EndIf

		//-------------------------------------------------------------------------------------------------------------------------------
		// Algumas linhas abaixo ( onde se usava as funções do framework totvs para obtenção de códigos a partir da tabela de/para ) foram
		// comentadas e a chave foi gerada manualmente, visto que a mensagem unica MNTI080 está sendo desenvolvida para o cliente na v10
		// e a v10 não possui suporte para as funções de de/para
		//-------------------------------------------------------------------------------------------------------------------------------
		cXMLRet += "<BusinessContent>"

			cXMLRet += "<CompanyId>"                       + AllTrim( cEmpAnt ) + "</CompanyId>"
			cXMLRet += "<BranchId>"                        + AllTrim( cFilAnt ) + "</BranchId>"
			cXMLRet += "<CompanyInternalId>"               + AllTrim( cEmpAnt + "|" + cFilAnt ) + "</CompanyInternalId>"
			cXMLRet += "<InternalId>"                      + AllTrim( cInternalId ) + "</InternalId>"
			cXMLRet += "<Code>"                            + AllTrim( &( cPrefixST9 + "->T9_CODBEM" ) ) + "</Code>"
			cXMLRet += "<Description>"                     + AllTrim( &( cPrefixST9 + "->T9_NOME"   ) ) + "</Description>"
			cXMLRet += "<WorkCenterCode>"                  + AllTrim( cCT ) + "</WorkCenterCode>"
			cXMLRet += "<WorkCenterInternalId>"            + AllTrim( cEmpAnt + "|" + cFilAnt + "|" + cCT ) + "</WorkCenterInternalId>"
			cXMLRet += "<ModelCode>"                       + AllTrim( &( cPrefixST9 + "->T9_TIPMOD" ) ) + "</ModelCode>"
			cXMLRet += "<ModelInternalId>"                 + AllTrim( cEmpAnt + "|" + cFilAnt + "|" + &( cPrefixST9 + "->T9_TIPMOD" ) ) + "</ModelInternalId>"
			cXMLRet += "<UnitOfMeasureCode>"               + AllTrim( cCodUnidMed ) + "</UnitOfMeasureCode>"
			cXMLRet += "<UnitOfMeasureInternalId>"         + AllTrim( cEmpAnt + "|" + cFilAnt + "|" + cCodUnidMed ) + "</UnitOfMeasureInternalId>"
			cXMLRet += "<PropertyEquipmentType>"           + AllTrim( "1" ) + "</PropertyEquipmentType>" // Chumbado 1 para indicar que se trata de equipamento próprio
			cXMLRet += "<OperationalCategoryCode>"         + AllTrim( &( cPrefixST9 + "->T9_CODFAMI" ) + "|" + cDescFamil ) + "</OperationalCategoryCode>"
			cXMLRet += "<OperationalCategoryInternalId>"   + AllTrim( cEmpAnt + "|" + cFilAnt + "|" + &( cPrefixST9 + "->T9_CODFAMI" ) ) + "</OperationalCategoryInternalId>"
			cXMLRet += "<CostCenterCode>"                  + AllTrim( cCC ) + "</CostCenterCode>"
			cXMLRet += "<CostCenterInternalId>"            + AllTrim( cEmpAnt + "|" + xFilial( "CTT", cFilAnt ) + "|" + cCC ) + "</CostCenterInternalId>"
			cXMLRet += "<AlternativeCostCenterCode>"       + "</AlternativeCostCenterCode>"
			cXMLRet += "<AlternativeCostCenterInternalId>" + "</AlternativeCostCenterInternalId>"
			cXMLRet += "<CustomerVendorCode>"              + AllTrim( &( cPrefixST9 + "->T9_FORNECE" ) ) + "</CustomerVendorCode>"
			cXMLRet += "<CustomerVendorInternalId>"        + AllTrim( cEmpAnt + "|" + cFilAnt + "|" + &( cPrefixST9 + "->T9_FORNECE" ) ) + "</CustomerVendorInternalId>"
			cXMLRet += "<OperativeGroupCode>"              + "</OperativeGroupCode>"
			cXMLRet += "<SituationStatus>"                 + AllTrim( If( nStatus == 1,"1","2" ) ) + "</SituationStatus>" // 1 - Ativo ou Disponível, 2 - Inativo ou Indisponível
			cXMLRet += "<DefaultSiteCode>"                 + "</DefaultSiteCode>"
			cXMLRet += "<AssetCode>"                       + AllTrim( &( cPrefixST9 + "->T9_CODIMOB" ) ) + "</AssetCode>"
			cXMLRet += "<OperatorType>"                    + "</OperatorType>"
			cXMLRet += "<CapacityProductive>"              + AllTrim( cValToChar( nCpcty ) ) + "</CapacityProductive>"
			cXMLRet += "<UnitCapacityProductive>"          + AllTrim( cUnimedCpProd ) + "</UnitCapacityProductive>"
			cXMLRet += "<BarCode>"                         + AllTrim( &( cPrefixST9 + "->T9_BARCODE" ) ) + "</BarCode>"

			cXMLRet += "<DocumentsInformations>"
				cXMLRet += "<ManufactureYear>"  + AllTrim( &( cPrefixST9 + "->T9_ANOFAB" ) )               + "</ManufactureYear>"
				cXMLRet += "<ModelsYear>"       + AllTrim( &( cPrefixST9 + "->T9_ANOMOD" ) )              + "</ModelsYear>"
				cXMLRet += "<EquipmentPlate>"   + AllTrim( &( cPrefixST9 + "->T9_PLACA" ) )               + "</EquipmentPlate>"
				cXMLRet += "<EquipmentChassis>" + AllTrim( &( cPrefixST9 + "->T9_CHASSI" ) )               + "</EquipmentChassis>"
				cXMLRet += "<RenavamNumber>"    + AllTrim( &( cPrefixST9 + "->T9_RENAVAM" ) )            + "</RenavamNumber>"
				cXMLRet += "<PurchaseDate>"     + AllTrim( If( Empty(dPurchaseDt), "", FWTimeStamp( 3,  dPurchaseDt, "00:00:00" ) )  )    + "</PurchaseDate>"
				cXMLRet += "<PurchaseValue>"    + AllTrim( cValToChar( &( cPrefixST9 + "->T9_VALCPA" ) ) ) + "</PurchaseValue>"
			cXMLRet += "</DocumentsInformations>"

			cXMLRet += "<ListOfCounterInformation>"

				cXMLRet += "<CounterInformation>"
				cXMLRet += "<CounterNumber>"                  + "1" + "</CounterNumber>"
					cXMLRet += "<CurrentCounter>"                 + AllTrim( cValToChar( nCont1 ) ) + "</CurrentCounter>"
					cXMLRet += "<AccrudeCounter>"                 + AllTrim( cValToChar( &( cPrefixST9 + "->T9_CONTACU" ) ) ) + "</AccrudeCounter>"
					cXMLRet += "<CounterAverageVariation>"        + AllTrim( cValToChar( &( cPrefixST9 + "->T9_VARDIA" )  ) ) + "</CounterAverageVariation>"
					cXMLRet += "<CounterUpperLimit>"              + AllTrim( cValToChar( &( cPrefixST9 + "->T9_LIMICON" ) ) ) + "</CounterUpperLimit>"
					cXMLRet += "<CounterUnitOfMeasureCode>"       + AllTrim( cCodUnidMed ) + "</CounterUnitOfMeasureCode>"
					cXMLRet += "<CounterUnitOfMeasureInternalId>" + AllTrim( cEmpAnt + "|" + cFilAnt + "|" + cCodUnidMed ) + "</CounterUnitOfMeasureInternalId>"
					cXMLRet += "</CounterInformation>"

					If NGIFDBSEEK( "TPE",&( cPrefixST9 + "->T9_CODBEM" ),01 ) // TPE - Segundo Contador

						nCont2     := If( IsInCallStack( "MNTA550" ),nCont2,&( cPrefixTPE + "->TPE_POSCON" ) )
						cPrefixTPE := If( IsInCallStack( "MNTA550" ),"TPE","M" )

						cXMLRet += "<CounterInformation>"
							 cXMLRet += "<CounterNumber>"                  + "2" + "</CounterNumber>"
							 cXMLRet += "<CurrentCounter>"                 + AllTrim( cValToChar( nCont2 ) ) + "</CurrentCounter>"
							 cXMLRet += "<AccrudeCounter>"                 + AllTrim( cValToChar( &( cPrefixTPE + "->TPE_CONTAC" ) ) ) + "</AccrudeCounter>"
							 cXMLRet += "<CounterAverageVariation>"        + AllTrim( cValToChar( &( cPrefixTPE + "->TPE_VARDIA" ) ) ) + "</CounterAverageVariation>"
							 cXMLRet += "<CounterUpperLimit>"              + AllTrim( cValToChar( &( cPrefixTPE + "->TPE_LIMICO" ) ) ) + "</CounterUpperLimit>"
							 cXMLRet += "<CounterUnitOfMeasureCode>"       + AllTrim( cCodUnidMed ) + "</CounterUnitOfMeasureCode>"
							 // cXMLRet += "<CounterUnitOfMeasureInternalId>" + IntUndExt( ,,cCodUnidMed )[2] + "</CounterUnitOfMeasureInternalId>"
							 cXMLRet += "<CounterUnitOfMeasureInternalId>" + AllTrim(  cEmpAnt + "|" + cFilAnt + "|" + cCodUnidMed ) + "</CounterUnitOfMeasureInternalId>"
						cXMLRet += "</CounterInformation>"
					EndIf
				cXMLRet += "</ListOfCounterInformation>
			cXMLRet += "</BusinessContent>"

			lRet := .T.

			If lRet

				aRotinas := {}
				aAdd(aRotinas, "MNTA080")
				aAdd(aRotinas, "MNTA084")
				aAdd(aRotinas,"NGUTIL05")
				aAdd(aRotinas,"NGUTIL02")
				aAdd(aRotinas, "NGMNT00")
				aAdd(aRotinas,"NGATFMNT")
				aAdd(aRotinas, "MNTA998")
				aAdd(aRotinas, "MNTA550")
				aAdd(aRotinas, "MNTA470")
				aAdd(aRotinas, "MNTA232")
				aAdd(aRotinas, "MNTA231")
				aAdd(aRotinas, "MNTA230")
				aAdd(aRotinas, "MNTA170")
				aAdd(aRotinas, "MNTA098")
				aAdd(aRotinas, "MNTA090")

				nContador := 1
				While nContador <= Len( aRotinas )
					If IsInCallStack( aRotinas[nContador] )
						If nOpcx2 == 3 // Inclusão
							nHandle := FCreate( "MU_INCLUSAO_" + aRotinas[nContador] + cAliasGet + ".xml",0 )
						ElseIf nOpcx2 == 4 .Or.  nOpcx2 == 6 // Alteração (ou Inativação.)
							nHandle := FCreate( "MU_ALTERACAO_" + aRotinas[nContador] + cAliasGet + ".xml",0 )
						ElseIf nOpcx2 == 5 // Exclusão
							nHandle := FCreate( "MU_EXCLUSAO_" + aRotinas[nContador] + cAliasGet + ".xml",0 )
						EndIf
						FWrite( nHandle,cXMLRet )
					EndIf
					nContador++
				End While
			EndIf
	EndIf

	// Atualiza variavel de efetivacao da mensagem
	If Type("lMuEquip") == "L"
		lMuEquip := lRet
	Endif

	cXMLRet := EncodeUTF8(cXMLRet)

Return { lRet, cXMLRet }