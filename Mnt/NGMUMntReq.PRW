#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "NGMUCH.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Integracao com mensagem unica (solicitacao de servico)

@author Hugo R. Pereira
@since 16/07/12
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function NGMUMntReq(nRecTQB, nOpcTQB)

/*	Local lOldInclui := If( Type("Inclui") == "L", Inclui, Nil )
	Local lOldAltera := If( Type("Altera") == "L", Altera, Nil )

	dbSelectArea("TQB")
	dbGoTo(nRecTQB)

	setInclui(.F.)
	setAltera(.F.)

	If nOpcTQB == 3
		setInclui()
	ElseIf nOpcTQB == 4
		setAltera()
	EndIf

	FWIntegDef("NGMUMNTREQ")

	Inclui := lOldInclui
	Altera := lOldAltera*/

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Integracao com mensagem unica (solicitacao de servico)

@author Hugo R. Pereira
@since 16/07/12
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )

	Local cXMLRet, cInternalId, cSolInterId, cAssetCode, cMServico, cError, cWarning, cIdSolic
	Local lNewSol := .F.

	Local nEvent     := If(Type("Inclui") == "L", If(!Inclui .And. !Altera,5,3), Nil)
	Local aSolicAuto := {}
	Local nOpcEvent  := 3
	Local lRet       := .F.

	Local nCount
	Local cLogErro 	:= ""
	Local aErroAuto	:= {}

	Store "" to cXMLRet, cInternalId, cSolInterId, cAssetCode, cMServico, cError, cWarning, cIdSolic

	// Variaveis utilizadas para o MsExecAuto
	Private lMSHelpAuto := .t. // Não apresenta erro em tela
	Private lMSErroAuto := .f. // Caso a variavel torne-se .T. apos MsExecAuto, apresenta erro em tela

	If nTypeTrans == TRANS_RECEIVE

		If cTypeMessage == EAI_MESSAGE_BUSINESS

			oXmlMU := XmlParser(cXML, "_", @cError, @cWarning) // Recupera conteudo do xml

			If oXmlMU <> Nil .And. Empty(cError) .And. Empty(cWarning) // Caso o xml tenha sido obtido corretamente

				nOpcEvent := If(Upper(oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT",;
								If(Empty(cIdSolic := KeyDP( oXmlMU, nOpcEvent, .F. )), 3, 4) ,;
								If(Upper(oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE",;
								If(Empty(cIdSolic := KeyDP( oXmlMU, nOpcEvent, .F. )), 0, 5), 0))

				cIdSolic := StrTran(cIdSolic,'|','')
				dbSelectArea("TQB")
				dbSetOrder(1)
				dbSeek(cIdSolic)

				If nOpcEvent != 5
					aSolicAuto := LoadSolic(oXmlMU, nOpcEvent)
				Endif

				aRotSetOpc("TQB",,nOpcEvent)

				If nOpcEvent == 4 .Or. nOpcEvent == 5
					RegToMemory("TQB",.F.)
				EndIf

				MSExecAuto( {|x,z,y,w| MNTA280(x,z,y,w)},,, aSolicAuto, nOpcEvent )

				If !lMsErroAuto
					lRet := .T.
					cXMLRet += SaveListId(oXmlMU, nOpcEvent)
				Else

					aErroAuto := GetAutoGRLog()
					For nCount := 1 To Len(aErroAuto)
						cLogErro += StrTran(StrTran(aErroAuto[nCount],"<",""),"-","") + (" ")
					Next nCount

					// Monta XML de Erro de execução da rotina automatica.
					lRet := .F.
					cXMLRet := "erro - " + cLogErro //'<Message Message="'+ "Erro -03x2 " + cLogErro + '" code="b1" type="Error"></Message>'

				Endif

			EndIf

		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
			//cXMLRet := '<TAGX>TESTE DE RECEPCAO RESPONSE MESSAGE</TAGX>'
			lRet := .T.

/*			oXmlMU := XmlParser(cXML, "_", @cError, @cWarning)
			If oXmlMU <> Nil .And. Empty(cError) .And. Empty(cWarning)
				If Upper(oXmlMU:_TOTVSMESSAGE:_RESPONSEMESSAGE:_PROCESSINGINFORMATION:_STATUS:Text) == "ERROR"

					aAdd(aSolicAuto,{"TQB_SOLICI",TQB->TQB_SOLICI})

					MSExecAuto( {|x,z,y,w| MNTA280(x,z,y,w)},,, aSolicAuto , 5 )

				EndIf
			EndIf
*/
		ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
			cXMLRet := '1.000'
			lRet := .T.
		Endif

	ElseIf nTypeTrans == TRANS_SEND

/*		cXMLRet := '<BusinessMessage>'

		cInternalId := TQB->TQB_FILIAL + '|' + TQB->TQB_SOLICI
		cSolInterId	:= RetUserID() // Retorna UserRequesterInternalId
		cAssetCode  := AllTrim(NGSEEK("ST9", TQB->TQB_CODBEM, 1, "T9_CODIMOB")) // Retorna AssetInternalId (Codigo do Ativo relacionado ao Bem)
		cMServico   := MSMM(TQB->TQB_CODMSS)

		cXMLRet += FWEAIBusEvent( "MAINTENANCEREQUEST", nEvent, { { "InternalId", cInternalId } } )

		cXMLRet += '<BusinessContent>'

		cXMLRet += '	<Code>'              				+ TQB->TQB_SOLICI + '</Code>'
		cXMLRet += '	<InternalId>'        				+ cInternalId + '</InternalId>'
		cXMLRet += '	<CompanyId>'         				+ cEmpAnt + '</CompanyId>'
		cXMLRet += '	<BranchId>'          				+ cFilAnt + '</BranchId>'
		cXMLRet += '	<CompanyInternalId>' 				+ cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
		cXMLRet += '	<AssetInternalId>'   				+ cAssetCode + '</AssetInternalId>'
		cXMLRet += '	<RegisterDateTime>'  				+ FWTimeStamp ( 3, TQB->TQB_DTABER, TQB->TQB_HOABER + ':00' ) + '</RegisterDateTime>'
		cXMLRet += '	<MaintenanceServiceDescription>'	+ cMServico + '</MaintenanceServiceDescription>'
		cXMLRet += '	<UserRequesterCode>'   				+ TQB->TQB_CDSOLI + '</UserRequesterCode>'
		cXMLRet += '	<AccountableUserInternalID>' 		+ cSolInterId + '</AccountableUserInternalID>'
		cXMLRet += '	<ProjectInternalId>' 				+ '' + '</ProjectInternalId>'
		cXMLRet += '	<TaskInternalId>'    				+ '' + '</TaskInternalId>'
		cXMLRet += '	<Observation>'       				+ '' + '</Observation>'

		cXMLRet += '</BusinessContent>'

		cXMLRet += '</BusinessMessage>'

		conout("  MaintenanceRequest: send")
		lRet := .T. */

	EndIf

	//ajusta o XML pois com o caracter < o parser espera uma tag XML
	cXmlRet := StrTran(cXmlRet,'< --',':::')

	//Ponto de entrada para alteração do XML
	/*(If ExistBlock("NGMUPE01")
   		cXMLRet := ExecBlock("NGMUPE01",.F.,.F.,{cXmlRet, lRet, "NGMUMntReq" ,1})
	Endif*/

Return { lRet, cXMLRet }

//---------------------------------------------------------------------
/*/{Protheus.doc} RetUserID
Retorna ID do Solicitante em questao.
Utilizado para a tag UserRequesterInternalId.

@author Hugo R. Pereira
@since 18/07/12
@version MP11
@return cInternalID ID formado a apatir dos dados do usuario do solicitante.
/*/
//---------------------------------------------------------------------
Static Function RetUserID()

	Local cInternalID := ""
	Local aArea := GetArea()

	PswOrder(2)
	PswSeek(TQB->TQB_CDSOLI, .T.)
	aPswRet := PswRet(1)

	cInternalID := cEmpAnt+'|'+aPswRet[1,1] + '|' + aPswRet[1,2]

	RestArea(aArea)

Return cInternalID

//---------------------------------------------------------------------
/*/{Protheus.doc} SaveListId
Persiste dados na tabela De/Para

@author Hugo R. Pereira
@since 18/07/12
@version MP11
@return cInternalID ID formado a apatir dos dados do usuario do solicitante.
/*/
//---------------------------------------------------------------------
Static Function SaveListId(oXmlMU, nOpcEvent)
Return KeyDP( oXmlMU, nOpcEvent )

//---------------------------------------------------------------------
/*/{Protheus.doc} KeyDP
Persiste dados na tabela De/Para

@author Hugo R. Pereira
@since 18/07/12
@version MP11
@return cInternalID ID formado a apatir dos dados do usuario do solicitante.
/*/
//---------------------------------------------------------------------
Static Function KeyDP(oXmlMU, nOpcEvent, lCommit)

	Local cReturn := ''

	Local cValInt, lDelete
	Local cAlias  := "TQB"
	Local cField  := "TQB_SOLICI"
	Local cRefer  := oXmlMU:_TOTVSMessage:_MessageInformation:_Product:_Name:Text
	Local cValExt := oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text

	Default lCommit := .T.

	If lCommit
		lDelete := (nOpcEvent == 5)
		cValInt := TQB->TQB_FILIAL + '|' + TQB->TQB_SOLICI

		CFGA070Mnt( cRefer, cAlias, cField, cValExt, cValInt, lDelete, 1 )

		cReturn := '<ListOfInternalId>'

		cReturn += '   <InternalId>'
		cReturn += '      <Name>MaintenanceRequest</Name>'
		cReturn += '      <Origin>'      + cValExt + '</Origin>'
		cReturn += '      <Destination>' + cValInt + '</Destination>'
		cReturn += '   </InternalId>'

		cReturn += '</ListOfInternalId>'
	Else
		cReturn := CFGA070Int( cRefer, cAlias, cField, cValExt )
	Endif

Return cReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} LoadSolic
Persiste dados na tabela De/Para

@author Hugo R. Pereira
@since 18/07/12
@version MP11
@return cInternalID ID formado a apatir dos dados do usuario do solicitante.
/*/
//---------------------------------------------------------------------
Static Function LoadSolic(oXmlMU, nOpcEvent)

Local aSolic := {}
Local cRefer := oXmlMU:_TOTVSMessage:_MessageInformation:_Product:_Name:Text

If nOpcEvent == 3 .Or. nOpcEvent == 4
	If nOpcEvent == 3

		aSolic := {	{"TQB_CODBEM", oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AssetInternalId:Text , Nil},;				// Codigo do Bem a ser relacionado na Solicitação de Serviço
						{"TQB_RAMAL" , "0000" , Nil},;  // Ramal do funcionario que abriu a solicitação de Serviço
						{"TQB_DESCSS", oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_MaintenanceServiceDescription:Text, Nil},; // Descrição da Solicitação
						{"TQB_INTPRJ", oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ProjectInternalId:Text, Nil},;
						{"TQB_INTTSK", oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TaskInternalId:Text, Nil}}

//		aSolic[4,2] := IntPrjInt(aSolic[4,2], cRefer, /*cVersao*/)
//		aSolic[4,2] := If(aSolic[4,2][1],StrTokArr(aSolic[4,2][2],'|')[3],'')
//		aSolic[5,2] := IntTrfInt(aSolic[5,2], cRefer, /*cVersao*/)
//		aSolic[5,2] := If(aSolic[5,2][1],StrTokArr(aSolic[5,2][2],'|')[3],'')

	ElseIf nOpcEvent == 4

		aSolic := {	{"TQB_CODBEM", oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AssetInternalId:Text , Nil},;				// Codigo do Bem a ser relacionado na Solicitação de Serviço
						{"TQB_RAMAL" , "0000" , Nil},; 	// Ramal do funcionario que abriu a solicitação de Serviço
						{"TQB_DESCSS", oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_MaintenanceServiceDescription:Text, Nil},; // Descrição da Solicitação
						{"TQB_INTPRJ", oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ProjectInternalId:Text, Nil},;
						{"TQB_INTTSK", oXmlMU:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TaskInternalId:Text, Nil}}

//		aSolic[4,2] := IntPrjInt(aSolic[4,2], cRefer, /*cVersao*/)
//		aSolic[4,2] := If(aSolic[4,2][1],StrTokArr(aSolic[4,2][2],'|')[3],'')
//		aSolic[5,2] := IntTrfInt(aSolic[5,2], cRefer, /*cVersao*/)
//		aSolic[5,2] := If(aSolic[5,2][1],StrTokArr(aSolic[5,2][2],'|')[3],'')

	EndIf

	dbSelectArea("SN1")
	dbSetOrder(1)
	If dbSeek(xFilial("SN1")+aSolic[1,2])
		aSolic[1,2] := SN1->N1_CODBEM
	EndIf

EndIf

Return aSolic