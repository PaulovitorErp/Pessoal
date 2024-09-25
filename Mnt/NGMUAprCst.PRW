#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "NGMUCH.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} NGMUAprCst
Integracao com mensagem unica (apropriacao de custo)

@param nRecNo RecNo do registro que se deseja apropriar
@param nOpc opcao de evento 3(incluir)/4(alterar)=upsert 5=delete(nao implementado)
@param cTable tabela do registro que sera apropriado (STJ,STP,TPP)
@param aFields
@author Felipe Nathan Welter
@since 16/07/12
@version MP11
@return aRet  [1] lRet - Define se o envio foi realizado com sucesso. [.T. = True; .F. = False]
			  [2] cXMLRet - String do conteudo do xml.
/*/
//---------------------------------------------------------------------
Function NGMUAprCst(nRecNo,nOpc,cTable,aFields)

	Local lOldInclui := If(Type("Inclui")<>"U",Inclui,Nil)
	Local lOldAltera := If(Type("Altera")<>"U",Altera,Nil)

	Private cTbl := cTable
	Private aFieldsXML := aFields
	Private lApropria

	Private lOkAprCst := .F.

	dbSelectArea(cTable)
	dbGoTo(nRecNo)

	setInclui(.F.)
	setAltera(.F.)

	If nOpc == 3
		setInclui()
	ElseIf nOpc == 4
		setAltera()
	EndIf

	MsgRun('Aguarde integração com backoffice...','AppointmentCost',;
			{|| FWIntegDef("NGMUAPRCST", EAI_MESSAGE_BUSINESS, TRANS_SEND, Nil, "NGMUAPRCST") })

	Inclui := lOldInclui
	Altera := lOldAltera

Return lOkAprCst

//---------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Integracao com mensagem unica (apropriacao de custo)

@author Felipe Nathan Welter
@since 16/07/12
@version MP11
@return aRet  [1] lRet - Define se o envio foi realizado com sucesso. [.T. = True; .F. = False]
			  [2] cXMLRet - String do conteudo do xml.
/*/
//---------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )

	Local nX
	Local lRet 		:= .F.
	Local cXMLRet 	:= ""
	Local aSTL 		:= {}
	Local aXml 		:= {}
	Local nEvent 	:= If(Type("Inclui")<>"U", If(!Inclui .And. !Altera,5,3), Nil) //3=baixa;5=cancelamento
	Local cError 	:= '', cWarning := ''

	If nTypeTrans == TRANS_RECEIVE

		If cTypeMessage == EAI_MESSAGE_BUSINESS
			cXMLRet := '<TAGX>TESTE DE RECEPCAO BUSINESS MESSAGE</TAGX>'
			lRet := .T.

		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE

			oXmlMU 	:= XmlParser(cXML, "_", @cError, @cWarning)

			If oXmlMU <> Nil .And. Empty(cError) .And. Empty(cWarning)

				aXml := NGMUValRes(oXmlMU,STR0014)

				If !aXml[1] //"ERROR"

					lApropria := .F.
					lOkAprCst := .F.
					lRet := .T.
					cXMLRet := aXml[2]

					NGIntMULog("NGMUAPRCST",cValToChar(nTypeTrans)+"|"+cTypeMessage,cXML)

				Else //"OK"

					If Inclui .Or. Altera
						// grava na tabela de-para
						xObj := oXmlMU:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId
						cRefer  := oXmlMU:_TOTVSMessage:_MessageInformation:_Product:_Name:Text
						cAlias  := "STJ"
						cField  := "TJ_APROPRI"
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

					lApropria := .T.
					lOkAprCst := .T.
					lRet := .T.
					cXMLRet := ''
				EndIf
			EndIf

		ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
			cXMLRet := '1.000'
			lRet := .T.

		EndIf

	ElseIf nTypeTrans == TRANS_SEND


		If cTbl == "STJ"

			//posiciona no bem
			dbSelectArea("ST9")
			dbSetOrder(01)
			dbSeek(xFilial("ST9")+STJ->TJ_CODBEM)

			cInternalId := cTbl+'|'+cEmpAnt+'|'+STJ->TJ_FILIAL+'|'+STJ->TJ_ORDEM+'|'+STJ->TJ_PLANO
			//'|'+STJ->TJ_TIPOOS+'|'+STJ->TJ_CODBEM+'|'+STJ->TJ_SERVICO+'|'+STJ->TJ_SEQRELA

			//carrega os campos de codigo do projeto e tarefa (do array aFields ou do registro posicionado)
			nPos := asCan(aFieldsXML,{|x| x[1]=="ProjectInternalId"})
			cPrj := If(nPos>0,aFieldsXML[nPos,2],'')
			cPrj := If(NGCADICBASE("TJ_INTPRJ","A","STJ",.F.),If(Empty(STJ->TJ_INTPRJ),cPrj,STJ->TJ_INTPRJ),cPrj)
			nPos := asCan(aFieldsXML,{|x| x[1]=="TaskInternalId"})
			cTsk := If(nPos>0,aFieldsXML[nPos,2],'')
			cTsk := If(NGCADICBASE("TJ_INTTSK","A","STJ",.F.),If(Empty(STJ->TJ_INTTSK),cTsk,STJ->TJ_INTTSK),cTsk)
			//carrega tarefa e projeto
			cTsk := IntTrfExt(/*cEmpresa*/,/*cFilial*/,cPrj,/*cRevisao*/,cTsk)[2]
			cPrj := IntPrjExt(/*cEmpresa*/,/*cFilial*/,cPrj)[2]

			//montagem da mensagem unica
			cXMLRet += FWEAIBusEvent( "APPOINTMENTCOST", nEvent, { { "InternalId", cInternalId } } )

			cXMLRet += '<BusinessContent>'
			cXMLRet += '	<Code>'              + cTbl+STJ->TJ_ORDEM + '</Code>' //Codigo da apropriacao
			cXMLRet += '	<InternalId>'        + cInternalId + '</InternalId>' //InternalId
			cXMLRet += '	<Number>'            + cTbl+STJ->TJ_ORDEM + '</Number>' //Numero da apropriacao, que eh propagado para o pedido e a nota fiscal
			cXMLRet += '	<CompanyId>'         + cEmpAnt + '</CompanyId>'  //Empresa
			cXMLRet += '	<BranchId>'          + cFilAnt + '</BranchId>'  //Filial
			cXMLRet += '	<CompanyInternalId>' + cEmpAnt+'|'+cFilAnt + '</CompanyInternalId>' //InternalId da empresa
			cXMLRet += '	<RegisterDateTime>'  + FWTimeStamp ( 3,STJ->TJ_DTMRFIM,STJ->TJ_HOMRFIM+':00' ) + '</RegisterDateTime>'  //Data da apropriacao
			cXMLRet += '	<AbatementDateTime>' + '' + '</AbatementDateTime>' //Data de deducao no contrato (muito utilizado em integracao com TOP
			cXMLRet += '	<ProjectInternalId>' + cPrj + '</ProjectInternalId>' //Id de integracao do projeto
			cXMLRet += '	<MainOrderCode>'     + STJ->TJ_ORDEM + '</MainOrderCode>' //Codigo da ordem (OP ou OS) que originou a solicitacao
			cXMLRet += '	<MainOrderInternalId>'+ cEmpAnt+'|'+xFilial("STJ") + '|' + STJ->TJ_ORDEM +'|'+'OS' + '</MainOrderInternalId>' //Codigo da ordem (OP ou OS) que originou a solicitacao
			cXMLRet += '	<Observation>'       + '' + '</Observation>' //Observacao

			If nEvent != 5

				dbSelectArea("STL")
				dbSetOrder(01)
				dbSeek(xFilial("STL")+STJ->TJ_ORDEM+STJ->TJ_PLANO,.T.)
				While STL->(!Eof()) .And. STL->TL_FILIAL == xFilial("STL") .And.;
						STL->TL_ORDEM == STJ->TJ_ORDEM .And. STL->TL_PLANO == STJ->TJ_PLANO

					If STL->TL_TIPOREG $ "P/T/M/F" .And. STL->TL_SEQRELA <> "0  "

						cProduto := NGMURetIns(STL->TL_TIPOREG, STL->TL_CODIGO)
						cProduto := IntProExt(/*cEmpresa*/,/*cFilial*/,cProduto,/*cVersao*/)[2]

						nPos := asCan(aSTL,{|x| x[3] == cProduto})

						If nPos == 0
							aAdd(aSTL, {/*Code*/StrZero(Val(STL->TL_SEQRELA),3),;
											/*InternalId*/cEmpAnt+'|'+STL->TL_FILIAL+'|'+STL->TL_ORDEM+'|'+STL->TL_PLANO+'|'+STL->TL_TAREFA+'|'+STL->TL_TIPOREG+'|'+TL_CODIGO+'|'+STL->TL_SEQRELA+'|'+STL->TL_SEQTARE,;
											/*ItemInternalId*/+cProduto,;
											/*UnitPrice*/cValToChar(STL->TL_CUSTO/STL->TL_QUANTID),;
											/*TotalPrice*/cValToChar(STL->TL_CUSTO),;
											/*Quantity*/cValToChar(STL->TL_QUANTID),;
											;///*UnitOfMeasureInternalId*/NGTROCAFILI("SAH",STL->TL_FILIAL)+"|"+STL->TL_UNIDADE,;
											/*UnitOfMeasureInternalId*/IntUndExt(/*cEmpresa*/,/*cFilial*/,STL->TL_UNIDADE)[2],;
											;///*WarehouseInternalId*/NGTROCAFILI("NNR",STL->TL_FILIAL)+"|"+STL->TL_LOCAL,;
											/*WarehouseInternalId*/IntLocExt(/*cEmpresa*/,/*cFilial*/,STL->TL_LOCAL)[2],;
											/*RegisterDateTime*/FWTimeStamp(3,STJ->TJ_DTMRFIM,STJ->TJ_HOMRFIM+':00'),;
											;///*CostCenterInternalId*/xFilial("CTT")+"|"+ST9->T9_CCUSTO,;
											/*CostCenterInternalId*/IntCusExt(/*cEmpresa*/,/*cFilial*/,ST9->T9_CCUSTO)[2],;
											/*AccountantAcountInternalId*/'';
							} )
						Else
							aSTL[nPos,5] := cValToChar( Val(aSTL[nPos,5]) + STL->TL_CUSTO )
							aSTL[nPos,6] := cValToChar( Val(aSTL[nPos,6]) + STL->TL_QUANTID )
							aSTL[nPos,4] := cValToChar( Val(aSTL[nPos,5]) / Val(aSTL[nPos,6]) )
						EndIf

					EndIf

					STL->(dbSkip())
				EndDo

				cXMLRet += '	<ListOfAppointmentCostItem>' //Itens da apropriacao
				For nX := 1 To Len(aSTL)
					cXMLRet += '	   <AppointmentCostItem>'
					cXMLRet += '	      <Code>'                       + aSTL[nX,1] + '</Code>' //Codigo do item da apropriacao
					cXMLRet += '	      <InternalId>'                 + aSTL[nX,2] + '</InternalId>' //InternalId do item da apropriacao
					cXMLRet += '	      <ItemInternalId>'             + aSTL[nX,3] + '</ItemInternalId>' //Id de integracao do produto
					cXMLRet += '	      <ItemReferenceCode>'          + '' + '</ItemReferenceCode>' //Codigo de referencia do item
					cXMLRet += '	      <UnitPrice>'                  + aSTL[nX,4] + '</UnitPrice>' //Preco unitario
					cXMLRet += '	      <TotalPrice>'                 + aSTL[nX,5] + '</TotalPrice>' //Preco total do item
					cXMLRet += '	      <Quantity>'                   + aSTL[nX,6] + '</Quantity>' //Quantidade
					cXMLRet += '	      <UnitOfMeasureInternalId>'    + aSTL[nX,7] + '</UnitOfMeasureInternalId>' //Id de integracao da unidade de medida
					cXMLRet += '	      <WarehouseInternalId>'        + aSTL[nX,8] + '</WarehouseInternalId>' //Id de integracao do local de estoque (armazem)
					cXMLRet += '	      <RegisterDateTime>'           + aSTL[nX,9] + '</RegisterDateTime>' //Data de apropriacao do item
					cXMLRet += '	      <CostCenterInternalId>'       + aSTL[nX,10] + '</CostCenterInternalId>' //Id de integracao do centro de custo
					cXMLRet += '	      <AccountantAcountInternalId>' + aSTL[nX,11] + '</AccountantAcountInternalId>' //Id de integracao da conta contabil
					cXMLRet += '	      <MainOrderCode>'              + STJ->TJ_ORDEM + '</MainOrderCode>' //Codigo da ordem (OP ou OS) que originou a solicitacao
					cXMLRet += '	      <MainOrderInternalId>'		+ cEmpAnt+'|'+xFilial("STJ") + '|' + STJ->TJ_ORDEM +'|'+'OS' + '</MainOrderInternalId>' //Codigo da ordem (OP ou OS) que originou a solicitacao
					cXMLRet += '	      <ProjectInternalId>'          + cPrj + '</ProjectInternalId>' //Id de integracao do projeto
					cXMLRet += '	      <TaskInternalId>'             + cTsk + '</TaskInternalId>' //Id da integracao da tarefa
					cXMLRet += '	      <Observation>'                + '' + '</Observation>' //Observacao

					cXMLRet += '	      <ListOfApportionAppointmentCostItem>' //Rateio do item da movimentacao
					cXMLRet += '	      </ListOfApportionAppointmentCostItem>'

					cXMLRet += '      </AppointmentCostItem>'
				Next nX
				cXMLRet += '   </ListOfAppointmentCostItem>'

				lRet := .T.

			Else
				lRet := .T.

			EndIf

		ElseIf cTbl == "STP" .Or. cTbl == "TPP"

			If cTbl == "STP"
				cInternalId := cTbl+'|'+cEmpAnt+'|'+STP->TP_FILIAL+'|'+STP->TP_ORDEM+'|'+STP->TP_PLANO+'|'+STP->TP_CODBEM+'|'+DTOS(STP->TP_DTORIGI)
			ElseIf cTbl = "TPP"
				cInternalId := cTbl+'|'+cEmpAnt+'|'+TPP->TPP_FILIAL+'|'+TPP->TPP_ORDEM+'|'+TPP->TPP_PLANO+'|'+TPP->TPP_CODBEM+'|'+DTOS(TPP->TPP_DTORIG)
			EndIf

			nPos := asCan(aFieldsXML,{|x| x[1]=="ProjectInternalId"})
			cPrj := If(nPos>0,aFieldsXML[nPos,2],'')
			nPos := asCan(aFieldsXML,{|x| x[1]=="TaskInternalId"})
			cTsk := If(nPos>0,aFieldsXML[nPos,2],'')
			//carrega tarefa e projeto
			cTsk := IntTrfExt(/*cEmpresa*/,/*cFilial*/,cPrj,/*cRevisao*/,cTsk)[2]
			cPrj := IntPrjExt(/*cEmpresa*/,/*cFilial*/,cPrj)[2]

			If cTbl == "STP"
				aArray := {STP->TP_ORDEM,STP->TP_DTREAL,STP->TP_HORA}
			ElseIf cTbl == "TPP"
				aArray := {TPP->TPP_ORDEM,TPP->TPP_DTREAL,TPP->TPP_HORA}
			EndIf

			//montagem da mensagem unica
			cXMLRet += FWEAIBusEvent( "APPOINTMENTCOST", nEvent, { { "InternalId", cInternalId } } )

			cXMLRet += '<BusinessContent>'
			cXMLRet += '	<Code>'              + cTbl+aArray[1] + '</Code>' //Codigo da apropriacao
			cXMLRet += '	<InternalId>'        + cInternalId + '</InternalId>' //InternalId
			cXMLRet += '	<Number>'            + cTbl+aArray[1] + '</Number>' //Numero da apropriacao, que eh propagado para o pedido e a nota fiscal
			cXMLRet += '	<CompanyId>'         + cEmpAnt + '</CompanyId>'  //Empresa
			cXMLRet += '	<BranchId>'          + cFilAnt + '</BranchId>'  //Filial
			cXMLRet += '	<CompanyInternalId>' + cEmpAnt+'|'+cFilAnt + '</CompanyInternalId>' //InternalId da empresa
			cXMLRet += '	<RegisterDateTime>'  + FWTimeStamp ( 3,aArray[2],aArray[3]+':00' ) + '</RegisterDateTime>'  //Data da apropriacao
			cXMLRet += '	<AbatementDateTime>' + '' + '</AbatementDateTime>' //Data de deducao no contrato (muito utilizado em integracao com TOP
			cXMLRet += '	<ProjectInternalId>' + cPrj + '</ProjectInternalId>' //Id de integracao do projeto
			cXMLRet += '	<MainOrderCode>'     + '' + '</MainOrderCode>' //Codigo da ordem (OP ou OS) que originou a solicitacao
			cXMLRet += '	<MainOrderInternalId>' + '' + '</MainOrderInternalId>' //Codigo da ordem (OP ou OS) que originou a solicitacao
			cXMLRet += '	<Observation>'       + '' + '</Observation>' //Observacao

			If nEvent != 5

				dbSelectArea("TUT")
				dbSetOrder(01)

				If cTbl == "STP"

					cProd := cLocal := cUM := cLP := ''
					nPreco := nKmRodado := 0

					//carrega indicador de uso associado ao contador 1
					If dbSeek(xFilial("TUT")+STP->TP_CODBEM+'1')
						If TUT->TUT_CLSPRE == '1'
							nPreco := TUT->TUT_VALOR
							cProd  := TUT->TUT_CODPRO
							cLocal := TUT->TUT_LOCAL
						ElseIf TUT->TUT_CLSPRE == '2'
							dbSelectArea("ST9")
							dbSetOrder(01)
							dbSeek(xFilial("ST9")+STP->TP_CODBEM)
							nPreco := ST9->T9_CUSTOHO
							cProd  := TUT->TUT_CODPRO
							cLocal := TUT->TUT_LOCAL
						ElseIf TUT->TUT_CLSPRE == '3'
							dbSelectArea("SB1")
							dbSetOrder(01)
							If dbSeek(xFilial("SB1")+TUT->TUT_CODPRO)
								nPreco := SB1->B1_CUSTD
							EndIf
							cProd  := TUT->TUT_CODPRO
							cLocal := TUT->TUT_LOCAL
						ElseIf TUT->TUT_CLSPRE == '4'
							dbSelectArea("SB2")
							dbSetOrder(01)
							If dbSeek(xFilial("SB2")+TUT->TUT_CODPRO+TUT->TUT_LOCAL)
								nPreco := SB2->B2_CM1
							EndIf
							cProd  := TUT->TUT_CODPRO
							cLocal := TUT->TUT_LOCAL
						EndIf

						//carrega contador rodado
						cCodBem := STP->TP_CODBEM
						nKmRodado := STP->TP_ACUMCON
						dbSelectArea("STP")
						dbSetOrder(05)
						dbSkip(-1)
						If xFilial("STP") == STP->TP_FILIAL .And. cCodBem == STP->TP_CODBEM
							nKmRodado -= STP->TP_ACUMCON
						Else
							nKmRodado := 0
						EndIf
						dbSkip()

						//carrega dados do produto
						dbSelectArea("SB1")
						dbSetOrder(01)
						If dbSeek(xFilial("SB1")+cProd)
							cUM := SB1->B1_UM
							//cLP := NGTROCAFILI("NNR",SB1->B1_FILIAL)+"|"+SB1->B1_LOCPAD
							cLP := IntLocExt(/*cEmpresa*/,/*cFilial*/,SB1->B1_LOCPAD)[2]
						EndIf

					EndIf

					aArray :=  {/*Code*/'001',;
								/*InternalId*/cEmpAnt+'|'+STP->TP_FILIAL+'|'+STP->TP_ORDEM+'|'+STP->TP_PLANO+'|'+STP->TP_CODBEM+'|'+DTOS(STP->TP_DTORIGI),;
								;///*ItemInternalId*/xFilial("SB1")+'|'+cProd,;
								/*ItemInternalId*/IntProExt(/*cEmpresa*/,/*cFilial*/,cProd,/*cVersao*/)[2],;
								/*UnitPrice*/cValToChar(nPreco),;
								/*TotalPrice*/cValToChar(nKmRodado*nPreco),;
								/*Quantity*/cValToChar(nKmRodado),;
								;///*UnitOfMeasureInternalId*/NGTROCAFILI("SAH",SB1->B1_FILIAL)+"|"+cUM,;
								/*UnitOfMeasureInternalId*/IntUndExt(/*cEmpresa*/,/*cFilial*/,cUM)[2],;
								/*WarehouseInternalId*/cLP,;
								/*RegisterDateTime*/FWTimeStamp(3,STP->TP_DTLEITU,STP->TP_HORA+':00'),;
								/*CostCenterInternalId*/'',;
								/*AccountantAcountInternalId*/'';
								}

				ElseIf cTbl == "TPP"

					cProd := cLocal := cUM := cLP := ''
					nPreco := nKmRodado := 0

					//carrega indicador de uso associado ao contador 2
					If dbSeek(xFilial("TUT")+STP->TP_CODBEM+'2')
						If TUT->TUT_CLSPRE == '1'
							nPreco := TUT->TUT_VALOR
							cProd  := TUT->TUT_CODPRO
							cLocal := TUT->TUT_LOCAL
						ElseIf TUT->TUT_CLSPRE == '2'
							dbSelectArea("ST9")
							dbSetOrder(01)
							dbSeek(xFilial("ST9")+STP->TP_CODBEM)
							nPreco := ST9->T9_CUSTOHO
							cProd  := TUT->TUT_CODPRO
							cLocal := TUT->TUT_LOCAL
						ElseIf TUT->TUT_CLSPRE == '3'
							dbSelectArea("SB1")
							dbSetOrder(01)
							If dbSeek(xFilial("SB1")+TUT->TUT_CODPRO)
								nPreco := SB1->B1_CUSTD
							EndIf
							cProd  := TUT->TUT_CODPRO
							cLocal := TUT->TUT_LOCAL
						ElseIf TUT->TUT_CLSPRE == '4'
							dbSelectArea("SB2")
							dbSetOrder(01)
							If dbSeek(xFilial("SB2")+TUT->TUT_CODPRO+TUT->TUT_LOCAL)
								nPreco := SB2->B2_CM1
							EndIf
							cProd  := TUT->TUT_CODPRO
							cLocal := TUT->TUT_LOCAL
						EndIf

						//carrega contador rodado
						cCodBem := TPP->TPP_CODBEM
						nKmRodado := TPP->TPP_ACUMCO
						dbSelectArea("TPP")
						dbSetOrder(05)
						dbSkip(-1)
						If xFilial("TPP") == TPP->TPP_FILIAL .And. cCodBem == TPP->TPP_CODBEM
							nKmRodado -= TPP->TPP_ACUMCO
						Else
							nKmRodado := 0
						EndIf
						dbSkip()

						//carrega dados do produto
						dbSelectArea("SB1")
						dbSetOrder(01)
						If dbSeek(xFilial("SB1")+cProd)
							cUM := SB1->B1_UM
							//cLP := NGTROCAFILI("NNR",SB1->B1_FILIAL)+"|"+SB1->B1_LOCPAD
							cLP := IntLocExt(/*cEmpresa*/,/*cFilial*/,SB1->B1_LOCPAD)[2]
						EndIf

					EndIf

					aArray :=  {/*Code*/'001',;
								/*InternalId*/cEmpAnt+'|'+TPP->TPP_FILIAL+'|'+TPP->TPP_ORDEM+'|'+TPP->TPP_PLANO+'|'+TPP->TPP_CODBEM+'|'+DTOS(TPP->TPP_DTORIG),;
								;///*ItemInternalId*/xFilial("SB1")+'|'+cProd,;
								/*ItemInternalId*/IntProExt(/*cEmpresa*/,/*cFilial*/,cProd,/*cVersao*/)[2],;
								/*UnitPrice*/cValToChar(nPreco),;
								/*TotalPrice*/cValToChar(nKmRodado*nPreco),;
								/*Quantity*/cValToChar(nKmRodado),;
								;///*UnitOfMeasureInternalId*/NGTROCAFILI("SAH",SB1->B1_FILIAL)+"|"+cUM,;
								/*UnitOfMeasureInternalId*/IntUndExt(/*cEmpresa*/,/*cFilial*/,cUM)[2],;
								/*WarehouseInternalId*/cLP,;
								/*RegisterDateTime*/FWTimeStamp(3,TPP->TPP_DTLEIT,TPP->TPP_HORA+':00'),;
								/*CostCenterInternalId*/'',;
								/*AccountantAcountInternalId*/'';
								}

				EndIf

				cXMLRet += '	<ListOfAppointmentCostItem>' //Itens da apropriacao
				If !Empty(aArray)
					cXMLRet += '	   <AppointmentCostItem>'
					cXMLRet += '	      <Code>'                       + aArray[1] + '</Code>' //Codigo do item da apropriacao
					cXMLRet += '	      <InternalId>'                 + aArray[2] + '</InternalId>' //InternalId do item da apropriacao
					cXMLRet += '	      <ItemInternalId>'             + aArray[3] + '</ItemInternalId>' //Id de integracao do produto
					cXMLRet += '	      <ItemReferenceCode>'          + '' + '</ItemReferenceCode>' //Codigo de referencia do item
					cXMLRet += '	      <UnitPrice>'                  + aArray[4] + '</UnitPrice>' //Preco unitario
					cXMLRet += '	      <TotalPrice>'                 + aArray[5] + '</TotalPrice>' //Preco total do item
					cXMLRet += '	      <Quantity>'                   + aArray[6] + '</Quantity>' //Quantidade
					cXMLRet += '	      <UnitOfMeasureInternalId>'    + aArray[7] + '</UnitOfMeasureInternalId>' //Id de integracao da unidade de medida
					cXMLRet += '	      <WarehouseInternalId>'        + aArray[8] + '</WarehouseInternalId>' //Id de integracao do local de estoque (armazem)
					cXMLRet += '	      <RegisterDateTime>'           + aArray[9] + '</RegisterDateTime>' //Data de apropriacao do item
					cXMLRet += '	      <CostCenterInternalId>'       + aArray[10] + '</CostCenterInternalId>' //Id de integracao do centro de custo
					cXMLRet += '	      <AccountantAcountInternalId>' + aArray[11] + '</AccountantAcountInternalId>' //Id de integracao da conta contabil
					cXMLRet += '	      <MainOrderCode>'              + '' + '</MainOrderCode>' //Codigo da ordem (OP ou OS) que originou a solicitacao
					cXMLRet += '	      <MainOrderInternalId>'        + '' + '</MainOrderInternalId>' //Codigo da ordem (OP ou OS) que originou a solicitacao
					cXMLRet += '	      <ProjectInternalId>'          + cPrj + '</ProjectInternalId>' //Id de integracao do projeto
					cXMLRet += '	      <TaskInternalId>'             + cTsk + '</TaskInternalId>' //Id da integracao da tarefa
					cXMLRet += '	      <Observation>'                + '' + '</Observation>' //Observacao

					cXMLRet += '	      <ListOfApportionAppointmentCostItem>' //Rateio do item da movimentacao
					cXMLRet += '	      </ListOfApportionAppointmentCostItem>'

					cXMLRet += '      </AppointmentCostItem>'
				EndIf
				cXMLRet += '   </ListOfAppointmentCostItem>'

				lRet := .T.

			Else
				lRet := .T.

			EndIf

		EndIf

		cXMLRet += '</BusinessContent>'

	EndIf

	//ajusta o XML pois com o caracter < o parser espera uma tag XML
	cXmlRet := StrTran(cXmlRet,'< --',':::')

	//Ponto de entrada para alteração do XML
	If ExistBlock("NGMUPE01")
   		cXMLRet := ExecBlock("NGMUPE01",.F.,.F.,{cXmlRet, lRet, "NGMUAprCst", 1, nTypeTrans, cTypeMessage})
	Endif

Return { lRet, cXMLRet }