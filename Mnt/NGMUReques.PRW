#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "NGMUCH.CH"

Static cSC1Item := ''

//---------------------------------------------------------------------
/*/{Protheus.doc} NGMUReques
Integracao com mensagem unica (cancelamento de requisicao)

@param nRecNo   , Numérico,	Recno do registro selecionado.
@param cTbl	    , Caracter, Código da tabela - SCP ou SC1.
@param [lMem]   , Lógico  ,	Indica se vai user memória ou registro do banco.
@param nOpc     , Numérico,	Numero da operação.
@param [cTipIns], Caracter,	Indica o tipo de insumo.
@param [aSCPNum], Caracter,	Indica os itens da S.A. que será deletados.
@param [cSC1Del], string  ,	Indica o item da S.C. que será deletado.

@author Felipe Nathan Welter
@since 16/07/12
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function NGMUReques( nRecNo, cTbl, lMem, nOpc, cTipIns, aSCPNum, cSC1Del )

	Local lOldInclui := IIf(Type("Inclui") == "L", Inclui, Nil)
	Local lOldAltera := IIf(Type("Altera") == "L", Altera, Nil)
	Local cOldOrdem  := IIf(Type("cOrdem") == "C", cOrdem, Nil)

	Default lMem    := .F.
	Default cTipIns := 'P'
	Default aSCPNum := {}
	Default cSC1Del := ''

	Private lMemory    := lMem
	Private cTable     := cTbl
	Private lOKREQ     := .F.
	Private cTipInsumo := cTipIns
	Private lMDT	   := nModulo == 35
	Private aCCPNUMIT  := aSCPNum
	Private nOption    := nOpc

	If !lMemory
		dbSelectArea(cTbl)
		dbGoTo(nRecNo)
	EndIf

	cSC1Item := cSC1Del

	setInclui(.F.)
	setAltera(.F.)

	If nOpc == 3
		setInclui()
	ElseIf nOpc == 4
		setAltera()
	EndIf

	MsgRun('Aguarde integração com backoffice...','Request',;
			{|| FWIntegDef("NGMUREQUES", EAI_MESSAGE_BUSINESS, TRANS_SEND, Nil, "NGMUREQUES") })

	Inclui := lOldInclui
	Altera := lOldAltera
	cOrdem := cOldOrdem

Return lOKREQ

//---------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Integracao com mensagem unica (cancelamento de requisicao)

@author Felipe Nathan Welter
@since 16/07/12
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )

    Local nX
	Local cXMLRet       := ""
	Local lRet          := .T.
	Local cSolInterId   := ''
    Local cError        := ''
	Local cNumSC        := ''
    Local cWarning      := ''
    Local cSTJOrdem     := ''
	Local cCodBemSTJ    := '' // Codigo do Bem da STJ para Tag <EquipmentCode>
    Local cObserv       := ''
	Local cTitle	    := ''
	Local cCCusto       := ''
	Local aXml		    := {}
	Local aIntegC1      := {}
	Local aAreaSC1      := {}
	Local nTamSTJ       := 0
	Local nEvent        := 0
	Local dDtEmiss      := CToD( '' )

	Private cProduto	:= ''
	Private cInternalId	:= ''

	If nTypeTrans == TRANS_RECEIVE

		If cTypeMessage == EAI_MESSAGE_BUSINESS
			lRet := .T.
			cXmlRet := ''

		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE

			cTitle := STR0010+" '"+AllTrim(VIRTINSUMO(STL->TL_TIPOREG,STL->TL_CODIGO))+"' "+STR0011

			oXmlMU := XmlParser(cXML, "_", @cError, @cWarning)

			If oXmlMU <> Nil .And. Empty(cError) .And. Empty(cWarning)

				aXml := NGMUValRes(oXmlMU,cTitle)

				If !aXml[1] //"ERROR"
					If nEvent <> Nil .And. nEvent == 3 //Deleta os insumos se for um Upsert
						//Consistencia de fechamento do estoque
						If NGCHKMESFE(STL->TL_DTINICI,STL->TL_TIPOREG,.F.)
							//Deleta o insumo e integra‡Æo com a microsiga
							If !NGDELINTEG(STL->TL_ORDEM,STL->TL_PLANO,STL->TL_TAREFA,STL->TL_TIPOREG,STL->TL_CODIGO,STL->TL_SEQRELA)
								aXml[2] := aXml[2] + " ["+STR0012+"] " //"houve problema na exclusão do insumo"
								NGIFDBSEEK("SCP",STL->TL_PRODUTO+STL->TL_NUMSA+STL->TL_ITEMSA,2)
								cNumCP := SCP->CP_NUM
							EndIf
						EndIf
					EndIf

					lRet    := .T.
					lOKREQ  := .F.
					cXMLRet := aXml[2]

					NGIntMULog("NGMUREQUES",cValToChar(nTypeTrans)+"|"+cTypeMessage,cXML)

				Else //"OK"

					// Tabela De/Para
					If Inclui .Or. Altera
						xObj := oXmlMU:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId
						cRefer  := oXmlMU:_TOTVSMessage:_MessageInformation:_Product:_Name:Text
						If cTable == "SCP"
							cAlias  := "SCP"
							cField  := "CP_NUM"
						ElseIf cTable == "SC1"
							cAlias  := "SC1"
							cField  := "C1_NUM"
						EndIf
						If Type("xObj") == "A"
							For nX := 1 To Len(xObj)
								cValExt := xObj[nX]:_Destination:Text
								cValInt := xObj[nX]:_Origin:Text
								lDelete := .F.
								nOrdem  := 1
								CFGA070Mnt( cRefer, cAlias, cField, cValExt, cValInt, lDelete, nOrdem )
								If lMdt
									aRegMdt := StrTokArr( cValExt , "|" )
									cMdtStatus := If( Len( aRegMdt ) >= 5 , aRegMdt[5] , "" )
									cMdtReserva:= cValInt
								EndIf
							Next nX
						Else
							cValExt := xObj:_Destination:Text
							cValInt := xObj:_Origin:Text
							lDelete := .F.
							nOrdem  := 1
							CFGA070Mnt( cRefer, cAlias, cField, cValExt, cValInt, lDelete, nOrdem )
							If lMdt
								aRegMdt := StrTokArr( cValExt , "|" )
								cMdtStatus := If( Len( aRegMdt ) >= 5 , aRegMdt[5] , "" )
								cMdtReserva:= cValInt
							EndIf
						EndIf
					EndIf

					lRet := .T.
					lOKREQ := .T.
					cXMLRet := ''
				EndIf
			EndIf


		ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
			cXMLRet := '1.010'
			lRet := .T.
		EndIf

	ElseIf nTypeTrans == TRANS_SEND

		If cTable == "SC1"

			If !Empty( cSC1Item )

				/*---------------------------------------------------------------------------------------+
				| Nas situações que o cSC1Item encontra-se preenchido, o evento é considerado alteração. |
				+---------------------------------------------------------------------------------------*/
				nEvent := 4

				If !fQntSC1( SC1->C1_NUM, SC1->C1_ITEM )

					/*---------------------------------------------------------------------------------+
					| Por se tratar do ultimo registro para esta S.C. o evento é considerado exclusão. |
					+---------------------------------------------------------------------------------*/
					nEvent := 5

				EndIf

			ElseIf Type( 'INCLUI' ) == 'L'

				/*-----------------------------------------------------------------------------------------------------------+
				| Quando alterar ou incluir o evento sempre será de inclusão, qualquer outra situação o evento é de deleção. |
				+-----------------------------------------------------------------------------------------------------------*/
				nEvent := IIf( INCLUI .Or. ALTERA, 3, 5 ) 

			EndIf
			
			aAreaSC1  := SC1->( GetArea() )

			lTemConPg := IIf(lMemory,!Empty(M->C1_CONDPAG),!Empty(SC1->C1_CONDPAG))
			nTamSTJ   := TAMSX3( 'TJ_ORDEM' )[1]

            cSTJOrdem  := SubStr(IIf(lMemory,M->C1_OP,SC1->C1_OP),1,TAMSX3("TJ_ORDEM")[1])
            cCodBemSTJ := NGSEEK("STJ", cSTJOrdem, 1, "TJ_CODBEM")

			If lMemory
				cInternalId := cEmpAnt+'|'+M->C1_FILIAL + '|' + M->C1_NUM +'|'+'SC'
                cObserv     := AllTrim(M->C1_OBS)

				/*--------------------------------------------------------------------------------------------------+
				| A data de emissão sempre deve ser a menor entre todos os itens da S.C. sendo assim o valor é pego |
				| do primeiro item da S.C.                                                                          |
				+--------------------------------------------------------------------------------------------------*/
				dDtEmiss    := NgSeek( 'SC1', M->C1_NUM  , 1, 'C1_EMISSAO' )

			Else
				cInternalId := cEmpAnt+'|'+SC1->C1_FILIAL + '|' + SC1->C1_NUM +'|'+'SC'
                cObserv     := AllTrim(SC1->C1_OBS)

				/*--------------------------------------------------------------------------------------------------+
				| A data de emissão sempre deve ser a menor entre todos os itens da S.C. sendo assim o valor é pego |
				| do primeiro item da S.C.                                                                          |
				+--------------------------------------------------------------------------------------------------*/
				dDtEmiss    := NgSeek( 'SC1', SC1->C1_NUM, 1, 'C1_EMISSAO' )

			EndIf

			cSolInterId	:= RetUserID(lMemory) // Retorna UserRequesterInternalId

			cOSId := cEmpAnt + '|' + NGTROCAFILI( 'STJ', IIf( lMemory, M->C1_FILIAL, SC1->C1_FILIAL ) ) + '|' +;
			         SubStr( IIf( lMemory, M->C1_OP, SC1->C1_OP ), 1, nTamSTJ ) + '|' + 'OS'

			cXMLRet += FWEAIBusEvent( "REQUEST", nEvent, { { "InternalId", cInternalId } } )

			cXMLRet += '<BusinessContent>'

			cXMLRet += '	<Code>'              			+ If(lMemory,M->C1_NUM,SC1->C1_NUM) + '</Code>'
			cXMLRet += '	<InternalId>'        			+ cInternalId 				+ '</InternalId>'
			cXMLRet += '	<Number>'            			+ If(lMemory,M->C1_NUM,SC1->C1_NUM) + '</Number>'
			cXMLRet += '	<Type>'              			+ '000' 					+ '</Type>'
            cXMLRet += '	<CompanyId>'         			+ cEmpAnt 					+ '</CompanyId>'
			cXMLRet += '	<BranchId>'          			+ cFilAnt 					+ '</BranchId>'
			cXMLRet += '	<CompanyInternalId>' 			+ cEmpAnt + '|' + cFilAnt 	+ '</CompanyInternalId>'
			cXMLRet += '	<UserRequesterCode>'  			+ If(lMemory,M->C1_SOLICIT,SC1->C1_SOLICIT) + '</UserRequesterCode>'
			cXMLRet += '	<UserRequesterInternalId>'  	+  cSolInterId				+  '</UserRequesterInternalId>'
			cXMLRet += '	<Series>'              			+ '' 						+ '</Series>'
			cXMLRet += '	<RegisterDateTime>'  			+ FWTimeStamp ( 3, dDtEmiss, '00:00:00' ) + '</RegisterDateTime>'
			cXMLRet += '	<DeliveryDateTime>'  			+ '' 						+ '</DeliveryDateTime>'
			cXMLRet += '	<AbatementDateTime>' 			+ '' 						+ '</AbatementDateTime>'
			cXMLRet += '	<PaymentConditionInternalId>' + If(lTemConPg,;
										IntConExt(/*cEmpresa*/,/*cFilial*/,If(lMemory,M->C1_CONDPAG,SC1->C1_CONDPAG))[2], '') + '</PaymentConditionInternalId>'
			cXMLRet += '	<ProjectInternalId>' 			+ '' 						+ '</ProjectInternalId>'
			cXMLRet += '	<MainOrderCode>'     			+ SubStr(If(lMemory,M->C1_OP,SC1->C1_OP),1,TAMSX3("TJ_ORDEM")[1]) + '</MainOrderCode>'
			cXMLRet += '	<MainOrderInternalId>' 			+ cOSId                     + '</MainOrderInternalId>'
            cXMLRet += '    <EquipmentCode>'                + AllTrim(cCodBemSTJ)               + '</EquipmentCode>'
			cXMLRet += '	<Observation>'       			+ cObserv + '</Observation>'

			cXMLRet += '<ListOfRequestItem>'

			// Deleção de um item da S.C. no XML independente de aglutinação ou não.
			If !lMemory

				cNumSC  := SC1->C1_NUM

				/* Necessario refazer o posicionamento, pois é importante garantir que estja posicionado no primeiro item
				 da solicitação de compras. */
				dbSelectArea( 'SC1' )
				dbSetOrder( 1 )
				dbSeek( xFilial( 'SC1' ) + cNumSC )
				Do While SC1->( !EoF() ) .And. xFilial( 'SC1' ) == SC1->C1_FILIAL .And. SC1->C1_NUM == cNumSC

					cProduto    := IntProExt( /*cEmpresa*/, /*cFilial*/, NGMURetIns( cTipInsumo, SC1->C1_PRODUTO ) )[2]
					cCCusto     := IIf( !Empty( SC1->C1_CC ), IntCusExt( /*cEmpresa*/, /*cFilial*/, SC1->C1_CC )[2], '' )
					cInternalId := cEmpAnt + '|' + SC1->C1_FILIAL + '|' + SC1->C1_NUM + '|' + SC1->C1_ITEM + '|' +;
					               SC1->C1_ITEMGRD

					aIntegC1 := {;
									SC1->C1_ITEM                                             ,;
									cInternalId                                              ,;
									cProduto                                                 ,;
									''                                                       ,;
									cValToChar( SC1->C1_PRECO )                              ,;
									cValToChar( SC1->C1_TOTAL )                              ,;
									cValToChar( SC1->C1_QUANT )                              ,;
									IntUndExt( /*cEmpresa*/, /*cFilial*/, SC1->C1_UM )[2]    ,;
									IntLocExt( /*cEmpresa*/, /*cFilial*/, SC1->C1_LOCAL )[2] ,;
									FWTimeStamp( 3, SC1->C1_DATPRF, '00:00:00' )             ,;
									cCCusto                                                  ,;
									''                                                       ,;
									SubStr( SC1->C1_OP, 1, nTamSTJ )                         ,;
									cOSId                                                    ,;
									''                                                       ,;
									''                                                       ,;
									AllTrim( cObserv )                                        ;
			           			}


					fRequestSC( @cXMLRet, aIntegC1 )

					SC1->( dbSkip() )

				EndDo

			Else

				cProduto    := IntProExt( /*cEmpresa*/, /*cFilial*/, NGMURetIns( cTipInsumo, M->C1_PRODUTO ) )[2]
				cCCusto     := IIf( !Empty( M->C1_CC ), IntCusExt( /*cEmpresa*/, /*cFilial*/, M->C1_CC )[2], '' )
				cInternalId := cEmpAnt + '|' + M->C1_FILIAL + '|' + M->C1_NUM + '|' + M->C1_ITEM + '|' +;
					            M->C1_ITEMGRD

				aIntegC1 := {;
								M->C1_ITEM                                             ,;
								cInternalId                                            ,;
								cProduto                                               ,;
								''                                                     ,;
								cValToChar( M->C1_PRECO )                              ,;
								cValToChar( M->C1_TOTAL )                              ,;
								cValToChar( M->C1_QUANT )                              ,;
								IntUndExt( /*cEmpresa*/, /*cFilial*/, M->C1_UM )[2]    ,;
								IntLocExt( /*cEmpresa*/, /*cFilial*/, M->C1_LOCAL )[2] ,;
								FWTimeStamp( 3, M->C1_DATPRF, '00:00:00' )             ,;
								cCCusto                                                ,;
								''                                                     ,;
								SubStr( M->C1_OP, 1, nTamSTJ )                         ,;
								cOSId                                                  ,;
								''                                                     ,;
								''                                                     ,;
								AllTrim( cObserv )                                      ;
							}


				fRequestSC( @cXMLRet, aIntegC1 )

			EndIf

			cXMLRet += '</ListOfRequestItem>'

			cXMLRet += '<ListOfApportionRequest>'
			cXMLRet += '</ListOfApportionRequest>'
			cXMLRet += '</BusinessContent>'

			lRet := .T.

			RestArea( aAreaSC1 )

		ElseIf cTable == "SCP"

			If nOption == 5

				/*----------------------------------------------------------------------+
				| No processo de exclusão, por padrão o evento é considerado alteração. |
				+----------------------------------------------------------------------*/
				nEvent := 4

				If SuperGetMV( 'MV_NGMNTAS',.F., '2' ) == '2' .Or. !fQntSCP()

					/*-------------------------------------------------------------------------------------+
					| Quando se tratar do último registro para esta S.A. o evento é marcado como exclusão. |
					+-------------------------------------------------------------------------------------*/
					nEvent := 5

				EndIf
			
			Else

				/*---------------------------------------------------------------+
				| Nos demais processos o evendo respeita a operação do processo. |
				+---------------------------------------------------------------*/
				nEvent := nOption

			EndIf

            cSTJOrdem  := SubStr(IIf(lMemory,M->CP_OP,SCP->CP_OP),1,TAMSX3("TJ_ORDEM")[1])
            cCodBemSTJ := NGSEEK("STJ", cSTJOrdem, 1, "TJ_CODBEM")

			If lMemory
				cInternalId := cEmpAnt+'|'+ M->CP_FILIAL + '|' + M->CP_NUM +'|'+'SA'
			    cObserv     := AllTrim(M->CP_OBS)

            Else
				cInternalId := cEmpAnt+'|'+ SCP->CP_FILIAL + '|' + SCP->CP_NUM +'|'+'SA'
                cObserv     := AllTrim(SCP->CP_OBS)
			EndIf

			cSolInterId	:= RetUserID(lMemory) // Retorna UserRequesterInternalId

			cOSId := cEmpAnt+'|'+NGTROCAFILI("STJ",If(lMemory,M->CP_FILIAL,SCP->CP_FILIAL)) + "|"  + SubStr(If(lMemory,M->CP_OP,SCP->CP_OP),1,TAMSX3("TJ_ORDEM")[1]) +'|'+'OS'

			cXMLRet += FWEAIBusEvent( "REQUEST", nEvent, { { "InternalId", cInternalId } } )

			cXMLRet += '<BusinessContent>'

			cXMLRet += '	<Code>'              			+ If(lMemory,M->CP_NUM,SCP->CP_NUM) + '</Code>'
			cXMLRet += '	<InternalId>'        			+ cInternalId 				+ '</InternalId>'
			cXMLRet += '	<Number>'            			+ If(lMemory,M->CP_NUM,SCP->CP_NUM) + '</Number>'
			cXMLRet += '	<Type>'              			+ '001' 					+ '</Type>'
            cXMLRet += '	<CompanyId>'         			+ cEmpAnt 					+ '</CompanyId>'
			cXMLRet += '	<BranchId>'          			+ cFilAnt 					+ '</BranchId>'
			cXMLRet += '	<CompanyInternalId>' 			+ cEmpAnt + '|' + cFilAnt 	+ '</CompanyInternalId>'
			cXMLRet += '	<UserRequesterCode>'  			+ If(lMemory,M->CP_SOLICIT,SCP->CP_SOLICIT) + '</UserRequesterCode>'
			cXMLRet += '	<UserRequesterInternalId>'  	+ cSolInterId	 			+  '</UserRequesterInternalId>'
			If lMDT
				cSerie := cMDTSerie
				cXMLRet += '	<Series>'              			+ cSerie 						+ '</Series>'
			Else
				cXMLRet += '	<Series>'              			+ '' 						+ '</Series>'
			EndIf
			cXMLRet += '	<RegisterDateTime>'  			+ FWTimeStamp ( 3, If(lMemory,M->CP_EMISSAO,SCP->CP_EMISSAO), '00:00:00' ) + '</RegisterDateTime>'
			cXMLRet += '	<DeliveryDateTime>'  			+ '' 						+ '</DeliveryDateTime>'
			cXMLRet += '	<AbatementDateTime>' 			+ '' 						+ '</AbatementDateTime>'
			cXMLRet += '	<PaymentConditionInternalId>'   + '' 						+ '</PaymentConditionInternalId>'
			cXMLRet += '	<ProjectInternalId>' 			+ '' 						+ '</ProjectInternalId>'
			cXMLRet += '	<MainOrderCode>'     			+ SubStr(If(lMemory,M->CP_OP,SCP->CP_OP),1,TAMSX3("TJ_ORDEM")[1]) + '</MainOrderCode>'
			cXMLRet += '	<MainOrderInternalId>' 			+ cOSId                     + '</MainOrderInternalId>'
			cXMLRet += '    <EquipmentCode>'                + AllTrim(cCodBemSTJ)       + '</EquipmentCode>'
            cXMLRet += '	<Observation>'	   				+ cObserv                   + '</Observation>'
			If lMDT
				cXMLRet += '	<Origin>'	   					+ 'NG'                   	+ '</Origin>'
            EndIf

			cXMLRet += '<ListOfRequestItem>'

			// Agrega tag de request item para o corpo da mensagem
			If !lMDT .And. SuperGetMV( "MV_NGMNTAS",.F.,"2" ) == "1" // caso aglutinação de SA
				If !lMemory
					cNumSA := SCP->CP_NUM
					NGIFDBSEEK( "SCP",SCP->CP_NUM,01,.F. ) // Garante que ele irá
					While !EoF() .And. SCP->( CP_FILIAL+CP_NUM ) == xFilial( "SCP" ) + cNumSA

						cProduto := NGMURetIns(cTipInsumo, SCP->CP_PRODUTO) // Retorna Produto
						cProduto := IntProExt(/*cEmpresa*/,/*cFilial*/,cProduto)[2]

						cInternalId := cEmpAnt+'|'+xFilial("SCP") + '|' + SCP->CP_NUM + '|' + SCP->CP_ITEM + '|' + SCP->CP_LOCAL

						fReqItem( @cXMLRet )
						NGDBSELSKIP( "SCP" )

					End While
				Else
					cNumSA := M->CP_NUM

					cProduto := NGMURetIns(cTipInsumo, M->CP_PRODUTO) // Retorna Produto
					cProduto := IntProExt(/*cEmpresa*/,/*cFilial*/,cProduto)[2]

					cInternalId := cEmpAnt+'|'+xFilial("SCP") + '|' + M->CP_NUM + '|' + M->CP_ITEM + '|' + M->CP_LOCAL

					fReqItem( @cXMLRet )

				EndIf
			Else // Caso sem aglutinação
				If lMdt
					cProduto := If(lMemory,M->CP_PRODUTO,SCP->CP_PRODUTO) // Retorna Produto
				Else
					cProduto := NGMURetIns(cTipInsumo, If(lMemory,M->CP_PRODUTO,SCP->CP_PRODUTO)) // Retorna Produto
				EndIf

				cProduto := IntProExt(/*cEmpresa*/,/*cFilial*/,cProduto)[2]

				fReqItem( @cXMLRet )
			EndIf

			cXMLRet += '</ListOfRequestItem>'

			cXMLRet += '<ListOfApportionRequest>'
			cXMLRet += '</ListOfApportionRequest>'
			cXMLRet += '</BusinessContent>'

			lRet := .T.

		EndIf

	EndIf

	//ajusta o XML pois com o caracter < o parser espera uma tag XML
	cXmlRet := StrTran(cXmlRet,'< --',':::')

	//Ponto de entrada para alteração do XML
	If ExistBlock("NGMUPE01")
   		cXMLRet := ExecBlock("NGMUPE01",.F.,.F.,{cXmlRet, lRet, "NGMUReques", 1, nTypeTrans, cTypeMessage})
	Endif

Return { lRet , cXmlRet }

//---------------------------------------------------------------------
/*/{Protheus.doc} RetUserID
Retorna ID do Solicitante em questao.
Utilizado para a tag UserRequesterInternalId.

@author Hugo Rizzo Pereira
@since 18/07/12
@version MP11
@return cInternalID ID formado a apatir dos dados do usuario do solicitante.
/*/
//---------------------------------------------------------------------
Static Function RetUserID(lMem)

	Local cInternalID := ""
	Local aArea       := GetArea()

	PswOrder(2)
	If cTable == "SC1"
		PswSeek(If(lMem,M->C1_SOLICIT,SC1->C1_SOLICIT), .T.)
	ElseIf cTable == "SCP"
		PswSeek(If(lMem,M->CP_SOLICIT,SCP->CP_SOLICIT), .T.)
	EndIf
	aPswRet := PswRet(1)

	cInternalID := cEmpAnt+'|'+aPswRet[1,1] + '|' + aPswRet[1,2]

	RestArea(aArea)

Return cInternalID

//---------------------------------------------------------------------
/*/{Protheus.doc} fReqItem
Gera tag do requestitem

@author Pedro Soares
@since 22/10/2013
@version MP11
@return Nil: ever Nil
/*/
//---------------------------------------------------------------------

Static Function fReqItem( cXMLRet )

	Local nPosItem := aScan( aCCPNUMIT, {|x| x[1]  == If(lMemory,M->CP_ITEM,SCP->CP_ITEM)  } )

	cXMLRet += '	<RequestItem>'
	If !Empty(aCCPNUMIT) .And. nPosItem > 0

		// ACCPNUMIT[3] é a quantidade do insumo a ser processada
		// Caso a quantidade seja maior que zero o evento será uma alteração,
		// Caso for zero será uma deleção
		If Len( aCCPNUMIT[nPosItem] ) == 3 .And. aCCPNUMIT[ nPosItem, 3 ] != 0

			cXMLRet += '   		<Event>upsert</Event>'

		Else

			cXMLRet += '   		<Event>delete</Event>'

		EndIf
	EndIf
	cXMLRet += '   		<Code>'						+ If(lMemory,M->CP_ITEM,SCP->CP_ITEM) 		+ '</Code>'
	cXMLRet += '   		<InternalId>'					+ cInternalId		+ '</InternalId>'
	cXMLRet += '   		<ItemInternalId>'				+ cProduto + '</ItemInternalId>'
	cXMLRet += '   		<ItemReferenceCode>'  		+ '' 	+ '</ItemReferenceCode>'
	cXMLRet += '   		<TotalPrice>'			   		+ '0'				+ '</TotalPrice>'
	cXMLRet += '   		<Quantity>'					+ cValToChar(If(lMemory,M->CP_QUANT,SCP->CP_QUANT)) + '</Quantity>'
	cXMLRet += '   		<UnitOfMeasureInternalId>'	+ IntUndExt(/*cEmpresa*/,/*cFilial*/,+If(lMemory,M->CP_UM,SCP->CP_UM))[2] + '</UnitOfMeasureInternalId>'
	cXMLRet += '   		<WarehouseInternalId>'		+ IntLocExt(/*cEmpresa*/,/*cFilial*/,If(lMemory,M->CP_LOCAL,SCP->CP_LOCAL))[2] + '</WarehouseInternalId>'
	cXMLRet += '   		<DeliveryDateTime>'			+ FWTimeStamp ( 3, If(lMemory,M->CP_DATPRF,SCP->CP_DATPRF), Time() ) + '</DeliveryDateTime>'

	If lMDT
		cXMLRet += '   		<CostCenterInternalId>'		+ IntCusExt(/*cEmpresa*/,/*cFilial*/,SRA->RA_CC)[2] + '|' //Empresa+Filial+Centro de Custo
		cXMLRet +=    		cEmpAnt + '|' + xFilial( "SQB" ) + '|' + SRA->RA_DEPTO + '</CostCenterInternalId>' //Empresa
	Else
		cXMLRet += '   		<CostCenterInternalId>'		+ IntCusExt(/*cEmpresa*/,/*cFilial*/,If(lMemory,M->CP_CC,SCP->CP_CC))[2] + '</CostCenterInternalId>'
	EndIf
	cXMLRet += '   		<AccountantAcountInternalId>'	+ '' 				+ '</AccountantAcountInternalId>'
	If lMDT
		cXMLRet += '   		<MainOrderCode>'			+ '' + '</MainOrderCode>'
		cXMLRet += '   		<MainOrderInternalId>' 		+ '' + '</MainOrderInternalId>'
	Else
		cXMLRet += '   		<MainOrderCode>'				+ SubStr(If(lMemory,M->CP_OP,SCP->CP_OP),1,TAMSX3("TJ_ORDEM")[1]) 		+ '</MainOrderCode>'
		cXMLRet += '   		<MainOrderInternalId>' 		+ cOSId + '</MainOrderInternalId>'
	EndIf
	cXMLRet += '   		<ProjectInternalId>'			+ ''				+ '</ProjectInternalId>'
	If lMdt .And. Type("cMdtNumRes") == "C"
		cXMLRet += '   		<TaskInternalId>'				+ cMdtNumRes		+ '</TaskInternalId>'
	Else
		cXMLRet += '   		<TaskInternalId>'				+ ''				+ '</TaskInternalId>'
	EndIf
	cXMLRet += '   		<Observation>'	   			+ If(lMemory,M->CP_OBS,SCP->CP_OBS) + '</Observation>'
	cXMLRet += '   		<ListOfApportionRequestItem>'
	cXMLRet += '   		</ListOfApportionRequestItem>'
	cXMLRet += '	</RequestItem>'

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} fRequestSC
Complementa o XML com a lista de itens para a solicitação de compra.
@type static

@author Alexandre Santos
@since 16/05/2019

@sample fRequestSC( cXMLRet, aInteg )

@param  cXMLRet, Caracter, XML estruturado até o momento.
@param  aInteg , Array   , Lista de informações referente aos itens da SC.
@return
/*/
//-------------------------------------------------------------------------
Static Function fRequestSC( cXMLRet, aInteg )

	cXMLRet += '<RequestItem>'

	/*----------------------------------------------------------------------------------------------------+
	| Verifica se o ITEM SC for igual ao cSC1Item, neste caso inclui a TAG <Event> para deleção do item. |
	+----------------------------------------------------------------------------------------------------*/
	If cSC1Item == aInteg[1]

		cXMLRet += '<Event>delete</Event>'
	
	Else
		
		cXMLRet += '<Event>upsert</Event>'

	EndIf

	cXMLRet += 		'<Code>'                       + aInteg[1]  + '</Code>'
	cXMLRet += 		'<InternalId>'                 + aInteg[2]  + '</InternalId>'
	cXMLRet += 		'<ItemInternalId>'             + aInteg[3]  + '</ItemInternalId>'
	cXMLRet += 		'<ItemReferenceCode>'          + aInteg[4]  + '</ItemReferenceCode>'
	cXMLRet += 		'<UnitPrice>'		           + aInteg[5]  + '</UnitPrice>'
	cXMLRet += 		'<TotalPrice>'                 + aInteg[6]  + '</TotalPrice>'
	cXMLRet += 		'<Quantity>'		           + aInteg[7]  + '</Quantity>'
	cXMLRet += 		'<UnitOfMeasureInternalId>'    + aInteg[8]  + '</UnitOfMeasureInternalId>'
	cXMLRet += 		'<WarehouseInternalId>'		   + aInteg[9]  + '</WarehouseInternalId>'
	cXMLRet += 		'<DeliveryDateTime>'		   + aInteg[10] + '</DeliveryDateTime>'
	cXMLRet += 		'<CostCenterInternalId>'	   + aInteg[11] + '</CostCenterInternalId>'
	cXMLRet += 		'<AccountantAcountInternalId>' + aInteg[12]	+ '</AccountantAcountInternalId>'
	cXMLRet += 		'<MainOrderCode>'			   + aInteg[13] + '</MainOrderCode>'
	cXMLRet += 		'<MainOrderInternalId>'        + aInteg[14] + '</MainOrderInternalId>'
	cXMLRet += 		'<ProjectInternalId>'		   + aInteg[15] + '</ProjectInternalId>'
	cXMLRet += 		'<TaskInternalId>'			   + aInteg[16] + '</TaskInternalId>'
	cXMLRet += 		'<Observation>'	   			   + aInteg[17] + '</Observation>'
	cXMLRet += 		'<ListOfApportionRequestItem>'
	cXMLRet += 		'</ListOfApportionRequestItem>'
	cXMLRet += '</RequestItem>'

Return

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} fQntSC1
Verifica a quantidade de itens presentes em uma mesma S.C.
@type function

@author Alexandre Santos
@since 05/09/2022

@param 	cNumSC , string, Número da solicitação de compras.
@param	cItemSC, string, Item da solicitação de compras.

@return boolean, Indica se existe outros itens na mesma S.C.
/*/
//---------------------------------------------------------------------------------------------
Static Function fQntSC1( cNumSC, cItemSC )

	Local cAlsSC1 := GetNextAlias()
	Local lRet    := .T.

	BeginSQL Alias cAlsSC1

		SELECT
			COUNT( SC1.C1_NUM ) AS QTDE_REG
		FROM
			%table:SC1% SC1
		WHERE
			SC1.C1_FILIAL = %xFilial:SC1% AND
			SC1.C1_NUM    = %exp:cNumSC%  AND
			SC1.C1_ITEM  <> %exp:cItemSC% AND
			SC1.%NotDel%

	EndSQL

	// Existem mais de um registro associado a está S.C.
	lRet := (cAlsSC1)->QTDE_REG > 0

	(cAlsSC1)->( dbCloseArea() ) 
	
Return lRet

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} fQntSC1
Verifica a quantidade de itens presentes em uma mesma S.C.
@type function

@author Alexandre Santos
@since 05/09/2022

@param 	cNumSC , string, Número da solicitação de compras.
@param	cItemSC, string, Item da solicitação de compras.

@return boolean, Indica se existe outros itens na mesma S.C.
/*/
//---------------------------------------------------------------------------------------------
Static Function fQntSCP()

	Local cNumSCP := ''
	Local cNotIN  := '%AND SCP.CP_ITEM NOT IN ( '    
	Local cAlsSCP := GetNextAlias()
	Local nInd    := 0
	Local lRet    := .T.

	If lMemory
		cNumSCP := M->CP_NUM
	Else
		cNumSCP := SCP->CP_NUM
	EndIf

	For nInd := 1 To Len( aCCPNUMIT )
		
		If nInd > 1
			cNotIN += ','
		EndIf

		cNotIN += ValToSQL( aCCPNUMIT[nInd,1] )

	Next nInd

	cNotIN += ' )%'

	BeginSQL Alias cAlsSCP

		SELECT
			COUNT( SCP.CP_NUM ) AS QTDE_REG
		FROM
			%table:SCP% SCP
		WHERE
			SCP.CP_FILIAL = %xFilial:SCP% AND
			SCP.CP_NUM    = %exp:cNumSCP% AND
			SCP.%NotDel%
			%exp:cNotIN%

	EndSQL

	// Existem mais de um registro associado a está S.C.
	lRet := (cAlsSCP)->QTDE_REG > 0

	(cAlsSCP)->( dbCloseArea() ) 
	
Return lRet
