#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "NGMUCH.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} NGMUStoTuO
Integracao com mensagem unica (baixa de estoque)

@param nRecNo	numero do registro
@param nOpc		tabela
@param lMem		busca dados da memoria, default = .F.
@author Felipe Nathan Welter
@since 16/07/12
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function NGMUStoTuO(nRecNo,cTbl,lMem)

	Default lMem := .F.

	Private lBaixaOK := .F.
	Private lMemory := lMem

	dbSelectArea(cTbl)
	If nRecNo <> Nil
		dbGoTo(nRecNo)
	EndIf

	MsgRun(STR0024,'StockTurnover',; //'Aguarde integração com backoffice...'
			{|| FWIntegDef("NGMUSTOTUO", EAI_MESSAGE_BUSINESS, TRANS_SEND, Nil, "NGMUSTOTUO") })

Return lBaixaOK

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

	Local nX, nI
	Local nItem       := 0

	Local lRet        := .F.
	Local lTemOS      := .F.

	Local cXMLRet     := ""
	Local cError      := ""
	Local cWarning    := ""
	Local cErroIns    := ""
	Local cInternalId := ""
	Local cRetResp    := ""

	Local aSTL        := {}
	Local aRetId      := {}
	Local aIntValID   := {}
	Local aInsumosRM  := {}
	Local aXml        := {}

	Local cCCusto     := ""
	Local cProdUnit   := ""
	Local cMainOrCod  := ""
	Local cCodExt     := ""

	If nTypeTrans == TRANS_RECEIVE

		If cTypeMessage == EAI_MESSAGE_BUSINESS

			oXmlMU := XmlParser(cXML, "_", @cError, @cWarning)

			If oXmlMU <> Nil .And. Empty(cError) .And. Empty(cWarning)

				//---------------------------------------------------------------------
				// Recebe mensagem, gera insumo e realiza baixa de estoque no Protheus
				//---------------------------------------------------------------------
				If Upper(oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"

					// Verifica se o valor contido no objeto é composto por mais de um registro (array).
					If Type("oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfStockTurnoverItem:_StockTurnoverItem") == "A"
						// Identifica a quantidade de itens.
						nItem := Len(oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfStockTurnoverItem:_StockTurnoverItem)

						For nX := 1 To nItem
							//Busca o De/Para. No XML o Registro é denominado de InternalID pois é o InternalID do RM, na Visão do Protheus ele é o ExternalID.
							cCodExt := oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfStockTurnoverItem:_StockTurnoverItem[nX]:_InternalId:Text //ExternalID da STL

							If !Empty(cCodExt)
								fDelRegs(cCodExt) //Exclusão de registros XXF, SD3 e STL
							EndIf
						Next nX
					Else
						//Busca o De/Para. No XML o Registro é denominado de InternalID pois é o InternalID do RM, na Visão do Protheus ele é o ExternalID.
						cCodExt := oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfStockTurnoverItem:_StockTurnoverItem:_InternalId:Text //ExternalID da STL

						If !Empty(cCodExt)
							fDelRegs(cCodExt) //Exclusão de registros XXF, SD3 e STL
						EndIf
					EndIf

					//carrega numero da Ordem de Servico pelo InternalId
					cAlias  := "STJ"
					cField  := "TJ_ORDEM"
					cRefer  := oXmlMU:_TOTVSMessage:_MessageInformation:_Product:_Name:Text
					cValExt := oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_MainOrderInternalId:Text
					cOrdem  := fGetOrder(cRefer,cValExt,cAlias,cField)

					dbSelectArea("STJ")
					dbSetOrder(01)
					If dbSeek(xFilial("STJ")+cOrdem)

						//Carrega array de insumos do outro sistema
						If Type("oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfStockTurnoverItem:_StockTurnoverItem") == "A"
							aInsumosRM := oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfStockTurnoverItem:_StockTurnoverItem
						ElseIf Type("oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfStockTurnoverItem:_StockTurnoverItem") == "O"
							aInsumosRM := { oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfStockTurnoverItem:_StockTurnoverItem }
						EndIf

						//Adequa para array de insumos do Protheus
						For nX := 1 To Len(aInsumosRM)

							aAdd(aSTL,{/*01-ordem*/STJ->TJ_ORDEM,;
											/*02-plano*/STJ->TJ_PLANO,;
											/*03-tipo*/NGSEEK("STE",STJ->TJ_TIPO,1,"TE_CARACTE"),;
											/*04-codbem*/Nil,;
											/*05-servico*/Nil,;
											/*06-seq*/Nil,;
											/*07-tarefa*/'0',;
											/*08-tipo insumo*/'P',;
											/*09-codigo insumo*/aInsumosRM[nX]:_ItemInternalId:Text,;
											/*10-quantidade*/Val(aInsumosRM[nX]:_Quantity:Text),;
											/*11-unidade*/Upper(aInsumosRM[nX]:_UnitOfMeasureInternalId:Text),;
											/*12-destino*/'A',;
											/*13-descricao*/STR0003,;  //'Integracao Mensagem Única'
											/*14-data inicio*/oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterDateTime:Text,;
											/*15-hora inicio*/oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterDateTime:Text,;
											/*16-gera F ou E*/'F',;
											/*17-local*/aInsumosRM[nX]:_WarehouseInternalId:Text,;
											/*18-lote*/'',;
											/*19-sub-lote*/'',;
											/*20-data validade lote*/'',;
											/*21-pLocaliz*/'',;
											/*22-percentual execucao*/0,;
											/*23-usa calendario*/'N',;
											/*24-tem garantia*/'N',;
											/*25-*/'',;
											/*26-*/'',;
											/*27-*/'',;
											/*28-*/'',;
											/*29-movimenta estoque*/.T.,;
											/*30-custo unitario*/Val(aInsumosRM[nX]:_UnitPrice:Text) * Val(aInsumosRM[nX]:_Quantity:Text),;
											/*31-Numero S.A.*/'',;
											/*32-Item S.A.*/'',;
											/*33-Numero S.C.*/'',;
											/*34-Item S.C.*/''})

							//Busca código do produto na tabela de/para
							cRefer  := oXmlMU:_TOTVSMessage:_MessageInformation:_Product:_Name:Text
							cAlias  := "SB1"
							cField  := "B1_COD"
							cValExt := aSTL[nX, 9]

							aSTL[nX,9] := IntProInt( cValExt, cRefer, /*cVersao*/ )

							//Buscar o código e item da S.A. ou S.C.
							fNumSaSc(@aSTL[nx], aInsumosRM[nX]:_RequestItemInternalId:Text )

							If aSTL[nX,9][1]
								aSTL[nX,9] := {aSTL[nX,9][2,2], aSTL[nX,9][2,3]}
								If Len(aSTL[nX,9]) == 2
									aSTL[nX,9] := aSTL[nX,9][2]
								Else
									lRet := .F.
									cXMLRet := STR0033 + cValToChar(nX) //"Produto não encontrado para o item "
								EndIf
							Else
								lRet := .F.
								cXMLRet := STR0033 + cValToChar(nX) //"Produto não encontrado para o item "
							EndIf

							//nos casos em que o backoffice faz aplicacao direta de insumo Terceiro
							If AllTrim(aSTL[nX,9]) == AllTrim(GetNewPar("MV_PRODTER",""))
								aSTL[nX,8] := "T"
							EndIf

							//busca codigo do armazem na tabela de/para
							cRefer  := oXmlMU:_TOTVSMessage:_MessageInformation:_Product:_Name:Text
							cAlias  := "NNR"
							cField  := "NNR_CODIGO"
							cValExt := aSTL[nX,17]
							aSTL[nX,17] := IntLocInt( cValExt, cRefer, /*cVersao*/)
							If aSTL[nX,17][1]
								aSTL[nX,17] := {aSTL[nX,17][2,2],aSTL[nX,17][2,3]}

								If Len(aSTL[nX,17]) == 2
									aSTL[nX,17] := aSTL[nX,17][2]
								Else
									lRet := .F.
									cXMLRet := STR0034 + cValToChar(nX) //"Local de estoque não encontrado para o item "
								EndIf
							Else
								lRet := .F.
								cXMLRet := STR0034 + cValToChar(nX) //"Local de estoque não encontrado para o item "
							EndIf

							//formata campos de data e hora
							aSTL[nX,14] := StrTokArr(SubStr(aSTL[nX,14],1,At('T',aSTL[nX,14])-1),'-')
							aSTL[nX,14] := CTOD(aSTL[nX,14][3]+'/'+aSTL[nX,14][2]+'/'+aSTL[nX,14][1])
							aSTL[nX,15] := SubStr(aSTL[1,15],At('T',aSTL[1,15])+1,5)
							//ajusta campo unidade de medida
							aUniMed := IntUndInt(aSTL[nX,11],cRefer,/*cVersao*/)
							If aUniMed[1]
								aSTL[nX,11] := Upper(aUniMed[2,3])
							EndIf

							If !Empty(cXMLRet)
								Exit
							EndIf

						Next nX

						//---------------------------------------------------------------------
						//grava os insumos no MNT
						If Empty(cXMLRet)

							For nX := 1 To Len(aSTL)
								cErroIns := ''
								If !NGRETINS(aSTL[nX,1],aSTL[nX,2],aSTL[nX,3],aSTL[nX,4],aSTL[nX,5],aSTL[nX,6],aSTL[nX,7],aSTL[nX,8],;
												aSTL[nX,9],aSTL[nX,10],aSTL[nX,11],aSTL[nX,12],aSTL[nX,13],aSTL[nX,14],aSTL[nX,15],aSTL[nX,16],;
												aSTL[nX,17],aSTL[nX,18],aSTL[nX,19],aSTL[nX,20],aSTL[nX,21],aSTL[nX,22],aSTL[nX,23],aSTL[nX,24],;
												aSTL[nX,25],aSTL[nX,26],aSTL[nX,27],aSTL[nX,28],aSTL[nX,29],@cErroIns,aSTL[nX,30],.F.,,,,,,,;
												aSTL[nX,31],aSTL[nX,32],aSTL[nX,33],aSTL[nX,34])
									cXMLRet := STR0035 + cErroIns + STR0036 + aSTL[nX,9] //"  problema no NGRETINS: " ## " - Produto: "
								Else

									lRet := .T.

									//armazena id in e out
									dbSelectArea("SD3")
									dbSetOrder(04)
									If dbSeek(xFilial("SD3")+STL->TL_NUMSEQ)
										cInternalId := cEmpAnt+'|'+SD3->D3_FILIAL+'|'+SD3->D3_NUMSEQ+'|'+SD3->D3_CHAVE+'|'+SD3->D3_COD
										//cInternalId := SD3->D3_FILIAL+'|'+SD3->D3_OP+'|'+SD3->D3_COD+'|'+SD3->D3_LOCAL
										aAdd(aRetId,{/*in*/cInternalId,/*out*/aInsumosRM[nX]:_InternalId:Text})
									EndIf
								EndIf
							Next nX

							If !Empty(aRetId)
								//---------------------------------------------------------------------
								cXMLRet += '<ListOfInternalId>' //<!-- Lista de retorno por internalID -->

								cValInt := oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
								cValExt := cEmpAnt+'|'+SD3->D3_FILIAL+'|'+SD3->D3_DOC +'|'+'STO'
								//monta mensagem de retorno
								cXMLRet += '   <InternalId>'//<!--Tipo de retorno de InternalID -->
								cXMLRet += '      <Name>'+'StockTurnover'+'</Name>'// <!-- Nome da Entidade detentora dos internalIDs -->
								cXMLRet += '      <Origin>'+cValInt+'</Origin>'//<!-- Valor do internalID no sistema de origem -->
								cXMLRet += '      <Destination>'+cValExt+'</Destination>'//<!-- Valor do internalID no sistema de destino -->
								cXMLRet += '   </InternalId>'
								//	aAdd(aRetId,{/*in*/cValExt,/*out*/cValInt})

								For nX := 1 To Len(aRetId)

									//grava relacionamento na tabela de/para
									cRefer  := oXmlMU:_TOTVSMessage:_MessageInformation:_Product:_Name:Text
									cAlias  := "SD3"
									cField  := "D3_DOC"
									cValInt := aRetId[nX,1]
									cValExt := aRetId[nX,2]
									lDelete := .F.
									nOrdem  := 1
									CFGA070Mnt( cRefer, cAlias, cField, cValExt, cValInt, lDelete, nOrdem )

									//monta mensagem de retorno
									cXMLRet += '   <InternalId>'//<!--Tipo de retorno de InternalID -->
									cXMLRet += '      <Name>'+'StockTurnoverItem'+'</Name>'// <!-- Nome da Entidade detentora dos internalIDs -->
									cXMLRet += '      <Origin>'+cValExt+'</Origin>'//<!-- Valor do internalID no sistema de origem -->
									cXMLRet += '      <Destination>'+cValInt+'</Destination>'//<!-- Valor do internalID no sistema de destino -->
									cXMLRet += '   </InternalId>'

								Next nX
								cXMLRet += '</ListOfInternalId>'
							EndIf
						EndIf

					Else
						lRet := .F.
						cXMLRet := STR0037 //"Ordem de Serviço não encontrada."
					EndIf

				EndIf
			EndIf

		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE

			oXmlMU := XmlParser(cXML, "_", @cError, @cWarning)

			If oXmlMU <> Nil .And. Empty(cError) .And. Empty(cWarning)

				aXml := NGMUValRes(oXmlMU,STR0004)

				If !aXml[1] //"ERROR"
					//--poderia posicionar pelo numseq mas nao grava NUMSEQ antes de integrar com NGATUERP
					//--considera-se que ja esta posicionado no STL gerado
					//Consistencia de fechamento do estoque
					If NGCHKMESFE(STL->TL_DTINICI,STL->TL_TIPOREG,.F.)
						//Deleta o insumo e integra‡Æo com a microsiga
						If !NGDELINTEG(STL->TL_ORDEM,STL->TL_PLANO,STL->TL_TAREFA,STL->TL_TIPOREG,STL->TL_CODIGO,STL->TL_SEQRELA)
							aXml[2] := aXml[2] + " ["+STR0006+"]"  //"problema na exclusao do insumo"
						EndIf
					EndIf

					lBaixaOK := .F.
					lRet := .T.
					cXMLRet := aXml[2]

					NGIntMULog("NGMUSTOTUO",cValToChar(nTypeTrans)+"|"+cTypeMessage,cXML)

				Else //"OK"
					// Tabela De/Para
					xObj := oXmlMU:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId
					cRefer  := oXmlMU:_TOTVSMessage:_MessageInformation:_Product:_Name:Text
					cAlias  := "SD3"
					cField  := "D3_DOC"
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
					lBaixaOK := .T.
					lRet := .T.
					cXMLRet := ''
				EndIf
			EndIf

		ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
			cXMLRet := '1.006'
			lRet := .T.
		Endif

	ElseIf nTypeTrans == TRANS_SEND

		//---------------------------------------------------------------------
		//envia mensagem de baixa de estoque
		//---------------------------------------------------------------------

		//ou a chave unica da tabela SD3 ou talvez deva se usar o DOC (agrupador)
		//cInternalId := SD3->D3_FILIAL+'|'+SD3->D3_OP+'|'+SD3->D3_COD+'|'+SD3->D3_LOCAL
		If lMemory
			cType := If( SubStr(M->D3_CF,1,2) == "RE", '000' , '001')
			cInternalId := cEmpAnt+'|'+M->D3_FILIAL+'|'+M->D3_DOC +'|'+'STO'
		Else
			cType := If( SubStr(SD3->D3_CF,1,2) == "RE", '000' , '001')
			cInternalId := cEmpAnt+'|'+SD3->D3_FILIAL+'|'+SD3->D3_DOC +'|'+'STO'
		EndIf

		//verifica se a baixa esta relacionada a uma OS
		lTemOS := If(lMemory,!Empty(M->D3_ORDEM),!Empty(SD3->D3_ORDEM))
		cMainOrCod := If(lTemOS,If(lMemory,M->D3_ORDEM,SD3->D3_ORDEM),'')

		cXMLRet += FWEAIBusEvent( "STOCKTURNOVER", 3, { { "InternalId", cInternalId } } )
		                                                    '
		cXMLRet += '<BusinessContent>'
		cXMLRet += '	<Code>'              + If(lMemory,M->D3_DOC,SD3->D3_DOC) + '</Code>' //Codigo da movimentacao de estoque
		cXMLRet += '	<InternalId>'        + cInternalId + '</InternalId>' //InternalId da movimentacao, que eh propagado para o pedido e NF
		cXMLRet += '	<Number>'            + If(lMemory,M->D3_DOC,SD3->D3_DOC) + '</Number>'  //Numero da movimentacao
		cXMLRet += '	<Type>'              + cType + '</Type>'  //tipo de movimentacao: 000=BaixaDeEstoque
		cXMLRet += '	<CompanyId>'         + cEmpAnt + '</CompanyId>' //Empresa
		cXMLRet += '	<BranchId>'          + cFilAnt + '</BranchId>' //Filial
		cXMLRet += '	<CompanyInternalId>' + cEmpAnt+'|'+cFilAnt + '</CompanyInternalId>' //InternalId da Empresa
		cXMLRet += '	<Series>'            + '' + '</Series>' //serie da movimentacao, utilizada como agrupador, propagada no pedido e NF
		cXMLRet += '	<RegisterDateTime>'  + FWTimeStamp ( 3,If(lMemory,M->D3_EMISSAO,SD3->D3_EMISSAO),'00:00:00' ) + '</RegisterDateTime>' //data de emissao da solicitacao
		//--considera-se que ja esta posicionado no STL gerado
		cXMLRet += '	<DeliveryDateTime>'  + IIf( lTemOS, FWTimeStamp( 3, IIf( lMemory, M->D3_EMISSAO, SD3->D3_EMISSAO ), '00:00:00' ),;
													FWTimeStamp( 3, dDataBase, Time() ) ) + '</DeliveryDateTime>'  //data de entrega ou previsao de entrega
		cXMLRet += '	<AbatementDateTime>'   + '' + '</AbatementDateTime>'  //data de deducao no contrato (TOP)
		cXMLRet += '	<ProjectInternalId>'   + '' + '</ProjectInternalId>' //id de integracao do projeto
		cXMLRet += '	<MainOrderCode>'       + cMainOrCod  + '</MainOrderCode>'  //codigo da ordem  (OP ou *OS*) que originou a movimentacao
		cXMLRet += '	<MainOrderInternalId>' + If(lTemOS,cEmpAnt+'|'+NGTROCAFILI("STJ",If(lMemory,M->D3_FILIAL,SD3->D3_FILIAL))+"|"+If(lMemory,M->D3_ORDEM,SD3->D3_ORDEM)+'|'+'OS','') +'</MainOrderInternalId>'
		cXMLRet += '	<EquipmentCode>'       + fMUStocObs(cMainOrCod)    + '</EquipmentCode>' //Código do Equipamento/ Bem

		If lMemory
			cInternalId := cEmpAnt+'|'+M->D3_FILIAL+'|'+M->D3_NUMSEQ+'|'+M->D3_CHAVE+'|'+M->D3_COD
		Else
			cInternalId := cEmpAnt+'|'+SD3->D3_FILIAL+'|'+SD3->D3_NUMSEQ+'|'+SD3->D3_CHAVE+'|'+SD3->D3_COD
		EndIf

		cProduto := If(lMemory,M->D3_COD,SD3->D3_COD)
		//Tratamento especial para insumo mao-de-obra
		If SubStr(cProduto,1,3) == "MOD"
			//cProduto := NGMURetIns("M", cProduto)

			cRefer  := "PROTHEUS"
			cAlias  := "ST1"
			cField  := "T1_CCUSTO"
			cValInt := cProduto
			cValExt := RTrim(CFGA070Ext( cRefer, cAlias, cField, cValInt ))

			If !Empty(cValExt)
				cProduto := cValExt
				cProdUnit := NGSEEK("SB1",cProduto,1,"B1_UM")
			EndIf
		Else
			cProdUnit := If(lMemory,M->D3_UM,SD3->D3_UM)
		EndIf

		cProduto := IntProExt(/*cEmpresa*/,/*cFilial*/,cProduto)[2]
		cCCusto  := If(lMemory,M->D3_CC,SD3->D3_CC)

		cXMLRet += '	<ListOfStockTurnoverItem>' //lista de itens da movimentacao de estoque
			cXMLRet += '	   <StockTurnoverItem>'
			cXMLRet += '	      <Code>'                       + '' + '</Code>' //codigo do item da movimentacao (sequencial para o RM)
			cXMLRet += '	      <InternalId>'                 + cInternalId + '</InternalId>' //internalId do item da movimentacao
			cXMLRet += '	      <ItemInternalId>'             + cProduto + '</ItemInternalId>' //id de integracao do produto
			cXMLRet += '	      <ItemReserveInternalId>'      + '' + '</ItemReserveInternalId>' //id de integracao da reserva a ser consumida
			cXMLRet += '	      <ItemReferenceCode>'          + '' + '</ItemReferenceCode>' //codigo de referencia do produto
			cXMLRet += '	      <UnitPrice>'                  + cValToChar(If(lMemory,M->D3_CUSTO1/M->D3_QUANT,SD3->D3_CUSTO1/SD3->D3_QUANT)) + '</UnitPrice>' //preco unitario
			cXMLRet += '	      <TotalPrice>'                 + cValToChar(If(lMemory,M->D3_CUSTO1,SD3->D3_CUSTO1)) + '</TotalPrice>' //preco total do item
			cXMLRet += '	      <Quantity>'                   + cValToChar(If(lMemory,M->D3_QUANT,SD3->D3_QUANT)) + '</Quantity>' //quantidade
			cXMLRet += '	      <UnitOfMeasureInternalId>'    + IntUndExt(/*cEmpresa*/,/*cFilial*/,cProdUnit)[2] + '</UnitOfMeasureInternalId>' //id de integracao da unidade de medida
			//cXMLRet += '	      <WarehouseInternalId>'        + xFilial("NNR")+"|"+If(lMemory,M->D3_LOCAL,SD3->D3_LOCAL) + '</WarehouseInternalId>'  //id de integracao do local de estoque (armazem)
			cXMLRet += '	      <WarehouseInternalId>'        + IntLocExt(/*cEmpresa*/,/*cFilial*/,If(lMemory,M->D3_LOCAL,SD3->D3_LOCAL))[2] + '</WarehouseInternalId>'  //id de integracao do local de estoque (armazem)
			//--considera-se que ja esta posicionado no STL gerado
			cXMLRet += '	      <DeliveryDateTime>'           + IIf( lTemOS, FWTimeStamp( 3, IIf( lMemory, M->D3_EMISSAO, SD3->D3_EMISSAO ), '00:00:00' ),;
																					FWTimeStamp( 3, dDataBase, Time() ) ) + '</DeliveryDateTime>' //data de entrega ou previsao de entrega do item
			//cXMLRet += '	      <CostCenterInternalId>'       + If(lMemory,M->D3_CC,SD3->D3_CC) + '</CostCenterInternalId>' //id de integracao do centro de custo
			cXMLRet += '	      <CostCenterInternalId>'       + If(!Empty(cCCusto),IntCusExt(/*cEmpresa*/,/*cFilial*/,cCCusto)[2],"")  + '</CostCenterInternalId>' //id de integracao do centro de custo
			cXMLRet += '	      <AccountantAcountInternalId>' + '' + '</AccountantAcountInternalId>' //id de integracao da conta contabil
			cXMLRet += '	      <MainOrderCode>'              + If(lTemOS,If(lMemory,M->D3_ORDEM,SD3->D3_ORDEM),'')  + '</MainOrderCode>' //codigo da ordem (*OP* ou OS) que originou a movimentacao
//			cXMLRet += '		   <MainOrderInternalId>'		+ If(lTemOS,cEmpAnt+'|'+NGTROCAFILI("STJ",If(lMemory,M->D3_FILIAL,SD3->D3_FILIAL))+"|"+If(lMemory,M->D3_ORDEM,SD3->D3_ORDEM) +'|'+'OS','') +'</MainOrderInternalId>'
			cXMLRet += '	      <ProjectInternalId>'          + '' + '</ProjectInternalId>' //id de integracao do projeto
			cXMLRet += '	      <TaskInternalId>'             + '' + '</TaskInternalId>' //id de integracao da tarefa
			cXMLRet += '	      <Observation>'                + '' + '</Observation>' //observacao
//			cXMLRet += '	      <Event>'                + '' + '</Event>' //observacao

			cXMLRet += '	      <ListOfApportionStockTurnoverItem>' //Rateio do item da movimentacao
			cXMLRet += '	      </ListOfApportionStockTurnoverItem>'

			cXMLRet += '      </StockTurnoverItem>'

		cXMLRet += '   </ListOfStockTurnoverItem>'
		cXMLRet += '</BusinessContent>'

		lRet := .T.

	EndIf

	//ajusta o XML pois com o caracter < o parser espera uma tag XML
	cXmlRet := StrTran(cXmlRet,'< --',':::')

	//Ponto de entrada para alteração do XML
	If ExistBlock("NGMUPE01")
   		cXMLRet := ExecBlock("NGMUPE01",.F.,.F.,{cXmlRet, lRet, "NGMUStoTuO", 1, nTypeTrans, cTypeMessage})
	Endif

Return { lRet, cXMLRet }

//---------------------------------------------------------------------
/*/{Protheus.doc} fMUStocObs
Busca o equipamento para enviar na tag de observação.

@param cXMLAnt	XML que da mensagem de Stock Turn Over
@author Maicon André Pinheiro
@since 10/04/2017
@version MP12
@return cObs
/*/
//---------------------------------------------------------------------
Static Function fMUStocObs(cMainOrCod)

	Local aArea   := GetArea()
	Local cFrota  := ""
	Local cObs    := ""

	Do Case
		Case !Empty(cMainOrCod)

			dbSelectArea("STJ")
			dbSetOrder(01)
			If dbSeek(xFilial("STJ")+cMainOrCod)
				cObs := AllTrim(STJ->TJ_CODBEM)
			EndIf

		Case cPrograma == "MNTA655"

			If !Empty(M->TQN_FROTA)
				cFrota := M->TQN_FROTA
				cObs   := AllTrim(cFrota)
			EndIf

		Case cPrograma == "MNTA656"

			If Type("oBrw1:aCols[n][nPOSFROTA]") == "C" .And. !Empty(oBrw1:aCols[n][nPOSFROTA])
				cObs := AllTrim(oBrw1:aCols[n][nPOSFROTA])
			EndIf

		Case cPrograma == "MNTA600"

			If !Empty(M->TR4_CODBEM)
				cFrota := M->TR4_CODBEM
				cObs   := AllTrim(cFrota)
			EndIf

		Case cPrograma == "MNTA660" .Or. cPrograma == "MNTA635" .Or. cPrograma == "MNTA670"

			If !Empty(TQN->TQN_FROTA)
				cObs := AllTrim(TQN->TQN_FROTA)
			EndIf

		Case cPrograma == "MNTA690"

			If Type("cBemStoTuO") == "C" .And. !Empty(cBemStoTuO)
				cObs := AllTrim(cBemStoTuO)
			EndIf
		Case cPrograma == 'MNTA681'
			
			cObs := ST9->T9_CODBEM

	EndCase

	RestArea(aArea)

Return cObs

//--------------------------------------------------------------------------//
/*/{Protheus.doc} fDelRegs

Localiza e armazena os números de sequência utilizados pelos registros da
mensagem e deleta todos os dados relacionados nas tabelas XXF, SD3 e STL.
Tratamento realizado pois o RM envia mensagens de upsert tanto na inclusão
como na alteração e exclusão de itens.

@type  Function
@author Maicon André Pinheiro
@since 09/02/2018
@version P12
@param cCodExt - C - External ID.
@return True
/*/
//--------------------------------------------------------------------------//
Function fDelRegs(cCodExt)

	Local aIntValID  := {}
	Local cReferXXF  := "RM" + Space( Posicione("SX3",2, "XXF_REFER","X3_TAMANHO") - 2 )
	Local cFieldXXF  := "D3_DOC" + Space( Posicione("SX3",2, "XXF_FIELD","X3_TAMANHO") - 6)
	Local cIntValXXF := ""
	Local cMainOrCod := ""
	Local lInvertido := .F.

	//Busca a chave interna do registro a ser editado.
	cIntValXXF := CFGA070Int(cReferXXF,"SD3",cFieldXXF,cCodExt)

	//Caso não encontrou verifica se não está com a chave invertida, pois por um tempo o sistema estava gravando invertido a chave.
	If Empty(cIntValXXF)
		cIntValXXF := CFGA070Ext(cReferXXF,"SD3",cFieldXXF,cCodExt)
		lInvertido := .T.
	EndIf

	If !Empty(cIntValXXF)

		aAdd(aIntValID,StrTokArr(cIntValXXF,"|"))

		If lInvertido
			CFGA070Mnt(cReferXXF,"SD3",cFieldXXF,cIntValXXF,cCodExt,.T.) //Deleta o De/Para.
		Else
			CFGA070Mnt(cReferXXF,"SD3",cFieldXXF,cCodExt,cIntValXXF,.T.) //Deleta o De/Para.
		EndIf

		If Len(aIntValID[1]) >= 3 //Trativa de segurança.

			dbSelectArea("SD3")
			dbSetOrder(4)//D3_FILIAL + D3_NUMSEQ + D3_COD + D3_CHAVE
			While SD3->(dbSeek(xFilial("SD3") + aIntValID[1][3]))

				SD3->(RecLock("SD3",.F.))
				SD3->(dbDelete())
				SD3->(MsUnlock())
				SD3->(dbSkip())

			EndDo

			dbSelectArea("STL")
			dbSetOrder(7) //TL_FILIAL + TL_NUMSEQ
			While STL->(dbSeek(xFilial("STL") + aIntValID[1][3]))

				STL->(RecLock("STL",.F.))
				STL->(dbDelete())
				STL->(MsUnlock())
				STL->(dbSkip())

			EndDo
		EndIf
	EndIf

Return .T.

//--------------------------------------------------------------------------
/*/{Protheus.doc} fGetOrder

Busca o código da OS, pela InternalId enviado pelo RM.


@param cRefer     , Caracter, Referência de onde está vindo o valor. Ex. RM.
@param cInternalID, Caracter, Código do InternalId que será usado para pesquisa.
@param cAlias     , Caracter, Alias da tabela que será usada para pesquisa.
@param cField     , Caracter, Campo da tabela que será usado para pesquisa.

@type  Function
@author Guilherme Freudenburg
@since 19/08/2019

@return Caracter, Código da OS.
/*/
//--------------------------------------------------------------------------
Static Function fGetOrder(cRefer,cInternalID,cAlias,cField)

	Local cOrdemCom := ""
	Local aOrdem := {}

	cOrdemCom := CFGA070Int(cRefer, cAlias, cField, cInternalID)
	aOrdem := Separa(cOrdemCom, '|')

Return SubStr(aOrdem[3],1,TAMSX3("TJ_ORDEM")[1])

//--------------------------------------------------------------------------
/*/{Protheus.doc} fNumSaSc

Busca o código da solicitação de compras ou armazem para preencher no insumo.

@param aSTL,    Array,    Array com os dados dos insumo.
@param cValExt, Caracter, Chave estrangeira da S.A. ou S.C.

@type  Function
@author Tainã Alberto Cardoso
@since 04/03/2021

@return Nil.
/*/
//--------------------------------------------------------------------------
Static Function fNumSaSc(aSTL, cValExt)

	Local cAliasTar  := ''
	Local cValInt    := ''
	Local lSCP       := .F.
	Local lSC1       := .F.
	Local cCondQuery := '%%'
	Local aValInt    := {}

	Default aSTL := {}
	Default cValExt := ''
	
	//Busca se existe S.A. relacionada
	cValInt := CFGA070Int( 'RM', 'SCP', 'CP_NUM', cValExt,RetSqlName("SCP") )
	If !Empty(cValint)
		lSCP := .T.
	Else
		//Busca se existe S.C. relacionada	
		cValInt := CFGA070Int( 'RM', 'SC1', 'C1_NUM', cValExt,RetSqlName("SC1") )
		If !Empty(cValint)
			lSC1 := .T.
		EndIf
	EndIf

	aValInt := StrTokArr( cValint, "|" )
	If lSCP
		aSTL[31] := aValInt[3]
		aSTL[32] := aValInt[4]
		cCondQuery := '% STL.TL_NUMSA = ' + ValtoSql( aValInt[3] ) + ' AND STL.TL_ITEMSA = ' + ValtoSql( aValInt[4] ) + '%'
	ElseIf lSC1
		aSTL[33] := aValInt[3]
		aSTL[34] := aValInt[4]
		cCondQuery := '% STL.TL_NUMSC = ' + ValtoSql( aValInt[3] ) + ' AND STL.TL_ITEMSC = ' + ValtoSql( aValInt[4] ) + '%'
	EndIf

	If lSCP .Or. lSC1
		cAliasTar := GetNextAlias()
		//Busca a tarefa prevista no insumo através da S.A. ou S.C.
		BeginSQL Alias cAliasTar
			
			SELECT STL.TL_TAREFA, STL.TL_DESTINO
				FROM %table:STL% STL
			WHERE STL.TL_ORDEM = %exp:aSTL[1]%
				AND STL.TL_FILIAL = %xfilial:STL%
				AND STL.%NotDel%
				AND %exp:cCondQuery%
		EndSQL
			
		If (cAliasTar)->( !EoF() )
			aSTL[7]  := (cAliasTar)->TL_TAREFA
		EndIf

		(cAliasTar)->(dbCloseArea())
	EndIf

Return
