#Include "FILEIO.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "NGMUCH.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Integracao com mensagem unica (ordem de servico)

@param nRecNo	numero do registro da STJ
@param nOpc		operacao (3=incluir;4=alterar)
@param lMem		busca dados da memoria, default = .F.
@param lRea     indica se é reabertura de O.S., default = .F.
@author Felipe Nathan Welter
@author Hugo Rizzo Pereira
@since 16/07/12
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function NGMUMntOrd(nRecNo,nOpc,lMem,aMUInsumo,lRea)

    /*No caso de leitura de variaveis de memoria (parâmetro lMempara qualquer novo campo
    a ser adicionado na mensagem deve se verificar se está sendo carregado em todas as
    rotinas que chamam a mensagem NGMUMntOrd.*/
	
	Local lOldInclui := IIf( Type("Inclui") == "L", Inclui, Nil )
	Local lOldAltera := IIf( Type("Altera") == "L", Altera, Nil )
	Local cOldOrdem  := IIf( Type("cOrdem") == "C", cOrdem, Nil )
	
	Default lMem := .F.
	Default aMUInsumo := {}
	Default lRea := .F.
	
	//define variavel de retorno de sucesso/erro
	Private lOKOS    := .F.
	Private lMemory  := lMem
	Private aInsumos := aMUInsumo
	Private lReabre  := lRea
	
	If !lMemory
		dbSelectArea("STJ")
		dbGoTo(nRecNo)
	EndIf
	
	setInclui(.F.)
	setAltera(.F.)
	
	If nOpc == 3
		setInclui()
	ElseIf nOpc == 4
		setAltera()
	EndIf
	
	MsgRun('Aguarde integração com backoffice...','MaintenanceOrder',;
			{|| FWIntegDef("NGMUMNTORD", EAI_MESSAGE_BUSINESS, TRANS_SEND, Nil, "NGMUMNTORD") })
	
	//considerando que na inclusao dos insumos e' feita a consulta de saldo, os custos 
	//ja' sao atualizados, entao nao ha' necessidade de consulta-los novamente
	If !lMemory .And. STJ->TJ_SITUACA == "L" .And. STJ->TJ_TERMINO == "N" .And. !lReabre
		NGMUAtuCus(STJ->TJ_ORDEM)
	EndIf
	
	Inclui := lOldInclui
	Altera := lOldAltera
	cOrdem := cOldOrdem

Return lOKOS

//---------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Integracao com Mensagem Unica.

@author Hugo R. Pereira
@since 18/07/12
@version MP11
@return aRet  Vetor contendo avaliação de sucesso do processo, e o XML gerado em formato de string.{ lRet, cXMLRet }
			  [1] lRet - Define se a operacao foi realizada com sucesso. [.T. = True; .F. = False]
			  [2] cXMLRet - String do conteudo do xml.
/*/
//---------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )

	Local cXMLRet       := ""
	Local cInternalId   := ""
	Local cSolInterId   := ""
	Local cAssetCode    := ""
	Local cError        := "" 
	Local cWarning      := ""
	Local cProduto      := ""
	Local nX            := 0
	Local nIns          := 0
	Local cStatus       := ""
	Local cObsSTJ       := ""
	Local cLocalEst     := ""
	Local cCodProd      := ""
	Local cProdFer      := SuperGetMV('MV_PRODFER', .F., "")
	Local nEvent        := If(Type("Inclui") == "L", If(!Inclui .And. !Altera,5,3), Nil)
	Local lRet          := .F.
	Local aSTL          := {}
	Local dDtOrder      

	Private lMSHelpAuto := .T. // Não apresenta erro em tela
	Private lMSErroAuto := .F. // Caso a variavel torne-se .T. apos MsExecAuto, apresenta erro em tela
	
	Private aInsumos := IIf(Type('aInsumos') != 'A', {}, aInsumos)
	
	If nTypeTrans == TRANS_RECEIVE
		
		If cTypeMessage == EAI_MESSAGE_BUSINESS
			
			oXmlMU := XmlParser(cXML, "_", @cError, @cWarning)
			If oXmlMU <> Nil .And. Empty(cError) .And. Empty(cWarning)
				aRet := ReceiveOprt(oXmlMU,nEvent) // Efetua processo de recebimento de mensagem
				lRet := aRet[1]
				cXMLRet := aRet[2]
			EndIf
		
		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
			
			oXmlMU := XmlParser(cXML, "_", @cError, @cWarning)
			If oXmlMU <> Nil .And. Empty(cError) .And. Empty(cWarning)
				If Upper(oXmlMU:_TOTVSMESSAGE:_RESPONSEMESSAGE:_PROCESSINGINFORMATION:_STATUS:Text) == "ERROR"
					If "<EVENT>UPSERT</EVENT>" $ Upper(oXmlMU:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text)
						cObs := STR0009+CRLF  //'Inconsistência no backoffice.'
					Else
						cObs := STR0009+CRLF  //'Inconsistência no backoffice.'
					EndIf
					cObs += 'Motivo: '
					xObj := oXmlMU:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message
					cObs += NGMUError( xObj )
					
					//busca codigo do produto na tabela de/para
					cRefer  := oXmlMU:_TOTVSMessage:_MessageInformation:_Product:_Name:Text
					cAlias  := "STJ"
					cField  := "TJ_ORDEM"
					cValInt := cEmpAnt+'|'+STJ->TJ_FILIAL+"|"+STJ->TJ_ORDEM+'|'+'OS'
					cValExt := RTrim(CFGA070Ext( cRefer, cAlias, cField, cValInt ))
					
					MsgAlert(cObs+CRLF+STR0007,STR0008)  //"Para mais detalhes consulte o log do EAI."##"Integração BackOffice"
					lRet := .T.
					lOKOS := .F.
					cXMLRet := cObs
					
					NGIntMULog("NGMUMNTORD",cValToChar(nTypeTrans)+"|"+cTypeMessage,cXML)
					
				ElseIf Upper(oXmlMU:_TOTVSMESSAGE:_RESPONSEMESSAGE:_PROCESSINGINFORMATION:_STATUS:Text) == "OK"
					// Tabela De/Para
					If "<EVENT>UPSERT</EVENT>" $ Upper(oXmlMU:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text)
						xObj := oXmlMU:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId
						cRefer  := oXmlMU:_TOTVSMessage:_MessageInformation:_Product:_Name:Text
						cAlias  := "STJ"
						cField  := "TJ_ORDEM"
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
						lRet := .T.
						lOKOS := .T.
						cXMLRet := ''
						
					Else

						lRet := .T.
						lOKOS := .T.
						cXMLRet := ''
					EndIf
					
				EndIf
			EndIf
			
		ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
			cXMLRet := '1.002'
			lRet := .T.
		Endif
		
	ElseIf nTypeTrans == TRANS_SEND

		If lMemory
			cInternalId	:= cEmpAnt+'|'+ xFilial("STJ") + '|' + M->TJ_ORDEM +'|'+'OS'
			cT9CODIMOB  := NGSEEK("ST9", M->TJ_CODBEM, 1, "T9_CODIMOB") // Retorna AssetInternalId (Codigo do Ativo relacionado ao Bem)
			cT9CODIMOB  := If(Empty(cT9CODIMOB),'',SubStr(cT9CODIMOB,1,TAMSX3("N1_CBASE")[1]) + '|' + SubStr(cT9CODIMOB,TAMSX3("N1_CBASE")[1]+1))   
			cAssetCode	:= If(Empty(cT9CODIMOB),'',cEmpAnt+'|'+xFilial("SN1")+'|'+cT9CODIMOB)
			cObsSTJ		:= M->TJ_OBSERVA  // Retorna Observacao
            cCodBemSTJ  := AllTrim(M->TJ_CODBEM)
        Else
			cInternalId	:= cEmpAnt+'|'+STJ->TJ_FILIAL + '|' + STJ->TJ_ORDEM +'|'+'OS'
			cT9CODIMOB  := NGSEEK("ST9", STJ->TJ_CODBEM, 1, "T9_CODIMOB") // Retorna AssetInternalId (Codigo do Ativo relacionado ao Bem)
			cT9CODIMOB  := If(Empty(cT9CODIMOB),'',SubStr(cT9CODIMOB,1,TAMSX3("N1_CBASE")[1]) + '|' + SubStr(cT9CODIMOB,TAMSX3("N1_CBASE")[1]+1))
			cAssetCode	:= If(Empty(cT9CODIMOB),'',cEmpAnt+'|'+xFilial("SN1")+'|'+cT9CODIMOB)
			cObsSTJ		:= If( NGCADICBASE("TJ_MMSYP","A","STJ",.F.),	MSMM(STJ->TJ_MMSYP,80), STJ->TJ_OBSERVA )  // Retorna Observacao, validando SYP
            cCodBemSTJ  := AllTrim(STJ->TJ_CODBEM)
        EndIf
		
		cSolInterId	:= RetUserID(lMemory)  // Retorna UserRequesterInternalId
		
		// ----------------------------------------------
		// Status:
		// 000 = Nao iniciada
		// 001 = Em andamento
		// 002 = Finalizada
		// 003 = A Faturar
		// 004 = Faturada
		// 999 = Cancelada (Nao efetua o cancelamento)
		// ----------------------------------------------
		
		If lMemory
			If M->TJ_SITUACA == "L" .And. M->TJ_TERMINO == "N"
				cStatus := '001'
			ElseIf M->TJ_SITUACA == "L" .And. M->TJ_TERMINO == "S"
				cStatus := '003'
			EndIf
		Else
			If STJ->TJ_SITUACA == "L" .And. STJ->TJ_TERMINO == "N"
				cStatus := '001'
			ElseIf STJ->TJ_SITUACA == "L" .And. STJ->TJ_TERMINO == "S"
				cStatus := '003'
			EndIf
		EndIf
		
		dbSelectArea("TPE")
		dbSetOrder(1)
		n2nCnt := 0
		If lMemory
			If dbSeek(xFilial("TPE")+M->TJ_CODBEM)
				n2nCnt := M->TJ_POSCON2
				n2nCnt := If(Empty(n2nCnt),TPE->TPE_POSCON,n2nCnt)
			EndIf
		Else
			If dbSeek(xFilial("TPE")+STJ->TJ_CODBEM)
				n2nCnt := TPE->TPE_POSCON
			EndIf
		EndIf
		
		dbSelectArea("ST9")
		dbSetOrder(01)
		n1nCnt := 0
		If lMemory
			n1nCnt := M->TJ_POSCONT
			If Empty(n1nCnt)
				If dbSeek(xFilial("ST9")+M->TJ_CODBEM)
					n1nCnt := ST9->T9_POSCONT
				EndIf
			EndIf
		Else
			n1nCnt := STJ->TJ_POSCONT
			If Empty(n1nCnt)
				If dbSeek(xFilial("ST9")+STJ->TJ_CODBEM)
					n1nCnt := ST9->T9_POSCONT
				EndIf
			EndIf
		EndIf
		
		cPrj := ''
		If !Empty(If(lMemory,M->TJ_INTPRJ,STJ->TJ_INTPRJ))
			aPrj := IntPrjExt(/*cEmpresa*/,/*cFilial*/,If(lMemory,M->TJ_INTPRJ,STJ->TJ_INTPRJ))
			cPrj := If(aPrj[1],aPrj[2],'')
		EndIf
		
		cTsk := ''
		If !Empty(If(lMemory,M->TJ_INTPRJ,STJ->TJ_INTPRJ))
			aTsk := IntPrjExt(/*cEmpresa*/,/*cFilial*/,If(lMemory,M->TJ_INTPRJ,STJ->TJ_INTPRJ))
			cTsk := If(aTsk[1],aTsk[2],'')
		EndIf

		/*
			Durante o processo de finalização da O.S. assume-se a data de manutenção real inicio como data origem para envio ao RM
			visto que não é possivel lançamento de insumos retroativos no RM. 
		*/
		If cStatus == '003'
			dDtOrder := IIf( lMemory, M->TJ_DTMRINI, STJ->TJ_DTMRINI )
		Else
			dDtOrder := IIf( lMemory, M->TJ_DTORIGI, STJ->TJ_DTORIGI )
		EndIf
		
		cXMLRet += FWEAIBusEvent( "MAINTENANCEORDER", nEvent, { { "InternalId", cInternalId } } )
		
		cXMLRet += '<BusinessContent>'
		cXMLRet += 		'<Code>'                      + If(lMemory,M->TJ_ORDEM,STJ->TJ_ORDEM)     + '</Code>
		cXMLRet += 		'<InternalId>'                + cInternalId                               + '</InternalId>
		cXMLRet += 		'<Number>'                    + If(lMemory,M->TJ_ORDEM,STJ->TJ_ORDEM)     + '</Number>
        cXMLRet += 		'<CompanyId>'                 + cEmpAnt                                   + '</CompanyId>
		cXMLRet += 		'<BranchId>'                  + cFilAnt                                   + '</BranchId>
		cXMLRet += 		'<CompanyInternalId>'         + cEmpAnt + '|' + cFilAnt                   + '</CompanyInternalId>
		cXMLRet += 		'<AssetInternalId>' 	      + cAssetCode                                + '</AssetInternalId>
		cXMLRet += 		'<EquipmentCode>'             + cCodBemSTJ                                + '</EquipmentCode>
        cXMLRet += 		'<UserRequesterCode>'         + If(lMemory,M->TJ_USUARIO,STJ->TJ_USUARIO) + '</UserRequesterCode>
		cXMLRet += 		'<AccountableUserInternalID>' + cSolInterId                               + '</AccountableUserInternalID>
		cXMLRet += 		'<RegisterDateTime>'          + FWTimeStamp( 3, dDtOrder, '00:00:00' )    + '</RegisterDateTime>
		cXMLRet += 		'<MaintenanceServiceCode>'    + If(lMemory,M->TJ_SERVICO,STJ->TJ_SERVICO) + '</MaintenanceServiceCode>
		cXMLRet += 		'<FirstCounter>'              + cValToChar(n1nCnt)                        + '</FirstCounter>
		cXMLRet += 		'<SecondCounter>'             + cValToChar(n2nCnt)                        + '</SecondCounter>
		cXMLRet += 		'<ProjectInternalId>'         + cPrj                                      + '</ProjectInternalId>
		cXMLRet += 		'<TaskInternalId>'            + cTsk                                      + '</TaskInternalId>
		cXMLRet += 		'<Status>'                    + cStatus  				                  + '</Status>'
		cXMLRet += 		'<Observation>'               + AllTrim( _NoTags( cObsSTJ ) )	          + '</Observation>

		If !lMemory
			If nEvent != 5
							
				dbSelectArea("STL")
				dbSetOrder(01)
				dbSeek(xFilial("STL")+STJ->TJ_ORDEM+STJ->TJ_PLANO,.T.)
				While STL->(!Eof()) .And. STL->TL_FILIAL == xFilial("STL") .And.;
						STL->TL_ORDEM == STJ->TJ_ORDEM .And. STL->TL_PLANO == STJ->TJ_PLANO
					
					// Verifica Insumos da O.S. Corrente
					If STL->TL_TIPOREG $ "P/T/M/F" .And. Val(STL->TL_SEQRELA) > 0
						
						cProduto := NGMURetIns(STL->TL_TIPOREG, STL->TL_CODIGO) // Retorna Produto
						
						cCodProd := cProduto
						
						cProduto := IntProExt(/*cEmpresa*/,/*cFilial*/,cProduto)[2]
						
						If aScan( aSTL, {|x| x[3] == cProduto } ) == 0
						
							cInternalId := cEmpAnt+'|'+STL->TL_FILIAL + '|' + STL->TL_ORDEM + '|' + STL->TL_PLANO + '|' + STL->TL_TAREFA + '|' + STL->TL_TIPOREG + '|' + TL_CODIGO + '|' + STL->TL_SEQRELA + '|' + STL->TL_SEQTARE
							
							//Verifica qual o local de estoque a ser utilizado
							Do Case
								//Caso o tipo de registro seja produto ou terceiros utiliza a função IntLocExt()
								Case STL->TL_TIPOREG $ 'P/T'
									cLocalEst := STL->TL_LOCAL
								
								//Caso o tipo de registro seja MDO carrega o local onde a baixa foi realizada
								Case STL->TL_TIPOREG == 'M'
									cLocalEst := NGSEEK('SD3', TL_NUMSEQ, 4, "D3_LOCAL")
																		
									If Empty(cLocalEst) .And. !Empty(cCodProd)
										cLocalEst	:= NGSEEK('SB1', cCodProd, 1, "B1_LOCPAD")
									EndIf
								
								//Caso o tipo de registro seja Ferramenta busca o local do produto contido no parâmetro MV_PRODFER
								Case STL->TL_TIPOREG == 'F'
									cLocalEst	:= NGSEEK('SB1', cProdFer, 1, "B1_LOCPAD")
							EndCase
						
							aAdd(aSTL, {	If(!lReabre,"UPSERT","DELETE")				, ; // Event
											STL->TL_CODIGO								, ; // Code
											cInternalId									, ; // InternalId
											cProduto										, ; // ItemInternalId
											cValToChar(STL->TL_CUSTO/STL->TL_QUANTID)	, ; // UnitPrice
											cValToChar(STL->TL_CUSTO)					, ; // TotalPrice
											cValToChar(STL->TL_QUANTID)					, ; // Quantity
											;//NGTROCAFILI("SAH",STL->TL_FILIAL)+"|"+STL->TL_UNIDADE, ; // UnitOfMeasureInternalId
											IntUndExt(/*cEmpresa*/,/*cFilial*/,STL->TL_UNIDADE)[2], ; // UnitOfMeasureInternalId
											;//NGTROCAFILI("NNR",STL->TL_FILIAL)+"|"+STL->TL_LOCAL								, ; // WarehouseInternalId
											IntLocExt(/*cEmpresa*/,/*cFilial*/,cLocalEst)[2], ;// WarehouseInternalId
											STL->TL_DTINICI								, ; // InitialDateTime
											STL->TL_HOINICI								, ; // HoraInicial
											STL->TL_DTFIM								, ; // FinalDateTime
											STL->TL_HOFIM								  ; // HoraFinal
							} )
							
						Else
							aSTL[nPos,5] := cValToChar( Val(aSTL[nPos,5]) + STL->TL_CUSTO )
							aSTL[nPos,6] := cValToChar( Val(aSTL[nPos,6]) + STL->TL_QUANTID )
							aSTL[nPos,4] := cValToChar( Val(aSTL[nPos,5]) / Val(aSTL[nPos,6]) )
						EndIf
						
					EndIf
					
					STL->(dbSkip())
				EndDo
					
				If Altera
				
					For nIns := 1 To Len(aInsumos)
						
						cInternalId := cEmpAnt+'|'+aInsumos[nIns][1] + '|' + aInsumos[nIns][2] + '|' + aInsumos[nIns][3] + '|' + aInsumos[nIns][4] + '|'
						cInternalId += aInsumos[nIns][5] + '|' + aInsumos[nIns][6] + '|' + aInsumos[nIns][7] + '|' + aInsumos[nIns][8]
						
						cProduto    := NGMURetIns(aInsumos[nIns][5], aInsumos[nIns][6]) // Retorna Produto
						cProduto := IntProExt(/*cEmpresa*/,/*cFilial*/,cProduto)[2]
						
						aAdd(aSTL, {	"DELETE"											, ; // [1] Event
										aInsumos[nIns][6]									, ; // [2] Code
										cInternalId											, ; // [3] InternalId
										cProduto												, ; // [4] ItemInternalId
										cValToChar(aInsumos[nIns][9]/aInsumos[nIns][10])	, ; // [5] UnitPrice
										cValToChar(aInsumos[nIns][9])						, ; // [6] TotalPrice
										cValToChar(aInsumos[nIns][10])						, ; // [7] Quantity
										;//NGTROCAFILI("SAH",SB1->B1_FILIAL)+"|"+aInsumos[nIns][11], ; // [8] UnitOfMeasureInternalId
										IntUndExt(/*cEmpresa*/,/*cFilial*/,aInsumos[nIns][11])[2], ; // [8] UnitOfMeasureInternalId
										;//NGTROCAFILI("NNR",SB1->B1_FILIAL)+"|"+aInsumos[nIns][12], ; // [9] WarehouseInternalId
										IntLocExt(/*cEmpresa*/,/*cFilial*/,aInsumos[nIns][12])[2], ; // [9] WarehouseInternalId
										aInsumos[nIns][13]									, ; // [10] InitialDateTime
										aInsumos[nIns][14]									, ; // [11] HoraInicial
										aInsumos[nIns][15]									, ; // [12] FinalDateTime
										aInsumos[nIns][16]  								  ; // [13] HoraFinal
						} )
								
					Next nIns
				
				Endif
			    
				cXMLRet += '	<ListOfMaintenanceOrderItem>' // Itens da O.S. [Insumos]
				
				For nX := 1 To Len(aSTL)
					cXMLRet += '	   <MaintenanceOrderItem>'
					
					cXMLRet += '	      <Event>'					 + aSTL[nx,1]	+ '</Event>' 					// Codigo do item da apropriacao
					cXMLRet += '	      <Code>'					 + '' 			+ '</Code>' 					// Codigo do item da apropriacao
					cXMLRet += '	      <InternalId>'				 + aSTL[nX,3] 	+ '</InternalId>'  				// InternalId do item da apropriacao
					cXMLRet += '	      <ItemInternalId>'			 + aSTL[nX,4] 	+ '</ItemInternalId>' 			// Id de integracao do produto
					cXMLRet += '	      <ItemReferenceCode>'		 + '1' 			+ '</ItemReferenceCode>' 		// Codigo de referencia do item
					cXMLRet += '	      <UnitPrice>'				 + aSTL[nX,5] 	+ '</UnitPrice>' 				// Preco unitario
					cXMLRet += '	      <TotalPrice>'				 + aSTL[nX,6] 	+ '</TotalPrice>' 				// Preco total do item
					cXMLRet += '	      <Quantity>'				 + aSTL[nX,7] 	+ '</Quantity>' 				// Quantidade
					cXMLRet += '	      <UnitOfMeasureInternalId>' + aSTL[nX,8] 	+ '</UnitOfMeasureInternalId>'	// Id de integracao da unidade de medida
					cXMLRet += '	      <WarehouseInternalId>'	 + aSTL[nX,9] 	+ '</WarehouseInternalId>' 		// Id de integracao do local de estoque (armazem)
					cXMLRet += '	      <InitialDateTime>'		 + FWTimeStamp ( 3, aSTL[nX,10], aSTL[nX,11]  + ":00" ) + '</InitialDateTime>' // Data de Inicio do Item
					cXMLRet += '	      <FinalDateTime>'			 + FWTimeStamp ( 3, aSTL[nX,12], aSTL[nX,13] + ":00" ) + '</FinalDateTime>' // Data de Término do Item
					cXMLRet += '	      <ProjectInternalId>'		 + cPrj + '</ProjectInternalId>' 		// Id de integracao do projeto
					cXMLRet += '	      <TaskInternalId>'			 + cTsk + '</TaskInternalId>' 			// Id da integracao da tarefa
					cXMLRet += '	      <Observation>'			 + '' 			+ '</Observation>' 				// Observacao
					
					cXMLRet += '	      <ListOfApportionMaintenanceOrderItem>'
					cXMLRet += '	      </ListOfApportionMaintenanceOrderItem>'
					
					cXMLRet += '      </MaintenanceOrderItem>'
				Next nX
				
				cXMLRet += '   </ListOfMaintenanceOrderItem>'
				
				cXMLRet += '   <ListOfApportionMaintenanceOrder>'
				cXMLRet += '   </ListOfApportionMaintenanceOrder>'
				
				lRet := .T.
			Else
				lRet := .T.
			EndIf
		EndIf

		cXMLRet += '</BusinessContent>'
		
		lRet := .T.
				
	EndIf
	
	//ajusta o XML pois com o caracter < o parser espera uma tag XML
	cXmlRet := StrTran(cXmlRet,'< --',':::')
	
	//Ponto de entrada para alteração do XML
	If ExistBlock("NGMUPE01")
   		cXMLRet := ExecBlock("NGMUPE01",.F.,.F.,{cXmlRet, lRet, "NGMUMntOrd", 1, nTypeTrans, cTypeMessage})
	Endif
	
Return { lRet, cXMLRet }

//---------------------------------------------------------------------
/*/{Protheus.doc} RetUserID
Retorna ID do Solicitante em questao.
Utilizado para a tag UserRequesterInternalId.

@author Felipe Nathan Welter
@author Hugo Rizzo Pereira
@since 18/07/12
@version MP11
@return cInternalID ID formado a apatir dos dados do usuario do solicitante.
/*/
//---------------------------------------------------------------------
Static Function RetUserID(lMem)

    Local cInternalID := ""
    Local aArea       := GetArea()

    Default lMem := .F.

    PswOrder(2)
    PswSeek(If(lMem,M->TJ_USUARIO,STJ->TJ_USUARIO), .T.)
    aPswRet := PswRet(1)

    cInternalID := cEmpAnt+'|'+aPswRet[1,1] + '|' + aPswRet[1,2]

    RestArea(aArea)

Return cInternalID

//---------------------------------------------------------------------
/*/{Protheus.doc} ReceiveOprt
Efetua processamento de recebimento da mensagem unica de O.S.

@author Felipe Nathan Welter
@author Hugo Rizzo Pereira
@since 18/07/12
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function ReceiveOprt(oXmlMU, nEvent)

	Local cFilSTJ := ""
	Local cOrdem  := ""
	Local lRet    := .F.
	Local cXMLRet := ''
	
	cRefer  := oXmlMU:_TOTVSMessage:_MessageInformation:_Product:_Name:Text
	cAlias  := "STJ"
	cField  := "TJ_ORDEM"
	cOrdem := oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
	cOrdem := CFGA070Int( cRefer, cAlias, cField, cOrdem )
	aOrdem := StrTokArr(cOrdem,'|')
	
	If !Empty(aOrdem) .And. Len(aOrdem) == 4 //emprsa+filial+ordem+'|OS'
		cFilSTJ := aOrdem[2]
		cOrdem := SubStr(aOrdem[3],1,TAMSX3("TJ_ORDEM")[1])
		
		cStatus := 	oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Status:Text
		
		dbSelectArea("STJ")
		dbSetOrder(01)
		If dbSeek(NGTROCAFILI("STJ",cFilSTJ)+cOrdem)
			If cStatus == "004"
				If STJ->TJ_TERMINO == "S" .And. STJ->TJ_SITUACA == "L"
					RecLock("STJ",.F.)
					STJ->TJ_FATURA := "1"
					MsUnLock("STJ")
					
					//atualiza os custos da OS
					NGMUAtuCus(STJ->TJ_ORDEM,.T.)
					
					cXMLRet := ''
					lRet := .T.
				Else
					cXMLRet := STR0017  //"Ordem de serviço não enviada para faturamento"
					lRet := .F.
				EndIf
			Else
				cXMLRet := STR0018  //"Status não reconhecido"
				lRet := .F.
			EndIf
		Else
			cXMLRet := STR0019  //"Ordem de serviço não encontrada"
			lRet := .F.
		EndIf
	Else
		cXMLRet := STR0020  //"Ordem de serviço não encontrada"
		lRet := .F.
	EndIf
	
Return {lRet,cXMLRet}
