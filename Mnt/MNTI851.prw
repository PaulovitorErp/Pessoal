#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTI851
Funcao de tratamento para o recebimento/envio de mensagem unica de
cadastro de atividades da parte diária.

@param cXML	        - Variavel com conteudo xml para envio/recebimento.
@param nTypeTrans	- Tipo de transacao. (Envio/Recebimento)
@param cTypeMessage	- Tipo de mensagem. (Business Type, WhoIs, etc)

@author Hugo R. Pereira
@since 12/06/13
@version P11
@return aRet Retorno do processo de consumo dos dados no modelo XML.
             [1] Boolean Indica se processo foi efetuado corretamente (.T.)
             [2] String  Indica o erro/problema encontrado durante o processo de importacao.
                 Referencia direta ao primeiro parametro booleano.
/*/
//---------------------------------------------------------------------
Function MNTI851(cXML, nTypeTrans, cTypeMessage)

    Local oListApp
	Local oXmlApp  := Nil

	Local aXMLRet  := {}
    Local cXMLRet  := ""
	Local lRet     := .T.

	Local cError   := ""
	Local cWarning := ""
	Local nI       := 0

	Local cIDApont
	Local nAppoint
	Local oAppointment

	Local aListAppXML   := {}
    Local cAliasTV2	    := "TV2"
	Local cField		:= "TV2_CODBEM"
	Local cInternalID	:= ""
	Local cRefer		:= "RM"

	Private aAppointmentsXML := {}
	Private cRefProduct      := ""
	Private lNGTURNL         := AllTrim(SuperGetMV("MV_NGTURNL",.F.,"2")) == "1" // Se .T. gera inconsistência

	If nTypeTrans == TRANS_RECEIVE // Recebimento

		If cTypeMessage == EAI_MESSAGE_BUSINESS // Tipo Business

			// Converte string xml em objeto
			oXmlApp     := XmlParser(cXML, "_", @cError, @cWarning)
			cRefProduct := oXmlApp:_TOTVSMessage:_MessageInformation:_Product:_Name:Text // Recupera nome do produto envolvido

			// Verifica se o xml foi convertido corretamente
			If oXmlApp <> Nil .And. Empty(cError) .And. Empty(cWarning) .And. ;
				ValType(oListApp := XmlChildEx( oXmlApp:_TOTVSMessage:_BusinessMessage:_BusinessContent, Upper("_ListOfAppointment") )) == "O"

				oAppointment := XmlChildEx( oXmlApp:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAppointment, Upper("_Appointment") )

				If ValType( oAppointment ) <> "U"

					// Consiste para que o no' ListOfAppointment seja sempre um array (Apontamentos)
					If ValType( oXmlApp:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAppointment:_Appointment ) == "O"
						XmlNode2Arr( oXmlApp:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAppointment:_Appointment, "_Appointment" )
					EndIf

					// Recupera lista de itens (Apontamentos) do XML
					aListAppXML := aClone( oXmlApp:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAppointment:_Appointment )

					// Verifica se alguns dos InternalId's ja foi recebido em um processo anterior, caso sim, exclui-o
                    If	Upper(oXmlApp:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT" .Or. ;
                        Upper(oXmlApp:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"

                        For nAppoint := 1 To Len(aListAppXML)

                            // Evidencia no' de Apontamento
                            oAppointment := aListAppXML[nAppoint]
                            cIDApont     := oAppointment:_InternalId:Text

							MNTI851EX(cIDApont) // Exclui apontamento requisitado

                        Next nAppoint

                    Endif

					// Estrutura array de apontamentos, conforme xml recebido
					If Upper(oXmlApp:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"

						aRotSetOpc("TV2",,3) // Define operacao como 'Inclusao'

						aXMLRet := ImportXML(aListAppXML)
						lRet    := aXMLRet[1]
						cXMLRet := aXMLRet[2]

					Endif

				Else

					cXMLRet := "Nenhum apontamento foi enviado."
					lRet    := .F.

				Endif

         Else

         	cXMLRet := "Erro na estrutura XML recebida."
				lRet    := .F.

         EndIf

		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE

			cXMLRet := "Teste De Recepcao Response Message"
			lRet    := .T.

		ElseIf cTypeMessage == EAI_MESSAGE_WHOIS

			cXMLRet := "1.000"
			lRet    := .T.

		EndIf

	ElseIf nTypeTrans == TRANS_SEND

		cXMLRet += FWEAIBusEvent("APPOINTMENT", 5, {{"InternalId", cInternalId}})

		cXMLRet += '<BusinessContent>'

		cXMLRet += '<CompanyId>'         + AllTrim(cEmpAnt) + '</CompanyId>'
		cXMLRet += '<BranchId>'          + AllTrim(cFilAnt) + '</BranchId>'
		cXMLRet += '<CompanyInternalId>' + AllTrim(cEmpAnt + "|" + cFilAnt) + '</CompanyInternalId>'

		cXMLRet += '<ListOfAppointment>'

			For nI := 1 To Len(aDados)

				cValExt	:= cEmpAnt + "|" + cFilAnt + "|" + cEmpAnt + "|" + aDados[nI][1] + "|" + DTOS(aDados[nI][2]) + "|" + aDados[nI][3]
				cValInt	:= RTrim(CFGA070Int(cRefer, cAliasTV2, cField, cValExt))

				If !Empty(cValInt)

					cInternalId := cEmpAnt + "|" + cFilAnt + "|" + cEmpAnt + "|" + aDados[nI][1] + "|" + DTOS(aDados[nI][2]) + "|" + aDados[nI][3]

					cXMLRet += '<Appointment>'
					cXMLRet += '<InternalId>' + cInternalID  + '</InternalId>'
					cXMLRet += '</Appointment>'

				EndIf

			Next nI

		cXMLRet += '</ListOfAppointment>'

		cXMLRet += '</BusinessContent>'

		lRet := .T.

	EndIf

    If lRet
	    cXMLRet := EncodeUTF8(cXMLRet)
    EndIf

Return {lRet, cXMLRet}

//---------------------------------------------------------------------
/*/{Protheus.doc} ImportXML
Realiza processo de importacao dos dados repassados no XML recebido.

@author Hugo R. Pereira
@since 12/06/13
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function ImportXML(aListAppXML)

    Local aXMLRet
    Local cXMLErr       := ""
    Local cXMLImpOK     := ""
    Local cXMLRet       := ""
	Local lXMLRet       := .F.
	Local nAppoint
	Local oAppointment
    Local lRet          := .T.              // Não permite que erros impeditivos sejam gravados pelo PE

    Local nFieldID
    Local nFieldQry

	Local lPE851B := ExistBlock( "MNTI851B" )

	Private aRecsTV1    := {}
	Private nListAppXML := Len(aListAppXML)

	Private aDBF1       := {}               // Campos da Tabela temporaria da TV1
    Private aDBF2       := {}               // Campos da Tabela temporaria da TV2
    Private aRegsOk     := {}               // Apontamentos que não possuem erros
    Private aRegsQry    := {}               // Registros para execução da Query de contador
    Private cTRB1       := GetNextAlias()   // Alias da tabela temporária da TV1
    Private cTRB2       := GetNextAlias()   // Alias da tabela temporária da TV2
    Private cDel        := "*"              // Marcação de exclusão nas tabelas temporarias
    Private oTmpRegT1                       // Tabela temporaria da TV1
    Private oTmpRegT2                       // Tabela temporaria da TV2
	Private nSeqTV2 := 0

	// Replica os Campos da TV1 para tabela temporaria
    dbSelectArea("TV1")
    aDBF1 := dbStruct()

    //Adiciona um campo a mais para a manipulação posterior
    aAdd(aDBF1, {"DELETADO", "C", 01, 0})
    aAdd(aDBF1, {"NREC"    , "N", 10, 0})

	// Adiciona campos virtuais a tabela temporaria
	fAddFldVir("TV1", aDBF1)

   //Intancia classe FWTemporaryTable
    oTmpRegT1  := FWTemporaryTable():New(cTRB1, aDBF1)
    oTmpRegT1:AddIndex("Ind01", {"TV1_FILIAL","TV1_EMPRES","TV1_CODBEM","TV1_DTSERV","TV1_TURNO","TV1_HRINI","TV1_HRFIM"})
    oTmpRegT1:AddIndex("Ind02", {"DELETADO"})
    oTmpRegT1:Create()

    // Replica os Campos da TV2 para tabela temporaria
    dbSelectArea("TV2")
    aDBF2 := dbStruct()

    //Adiciona um campo a mais para a manipulação posterior
    aAdd(aDBF2, {"DELETADO"  , "C", 01, 0})

	// Adiciona campos virtuais a tabela temporaria
	fAddFldVir("TV2", aDBF2)

   //Intancia classe FWTemporaryTable
    oTmpRegT2  := FWTemporaryTable():New(cTRB2, aDBF2)
    oTmpRegT2:AddIndex("Ind01", {"TV2_FILIAL","TV2_EMPRES","TV2_CODBEM","TV2_DTSERV","TV2_TURNO","TV2_PDIHRI","TV2_PDIHRF","TV2_HRINI","TV2_CODATI"})
    oTmpRegT2:AddIndex("Ind02", {"DELETADO"})
    oTmpRegT2:Create()

	For nAppoint := 1 To Len(aListAppXML)

		// Evidencia o Apontamento
		oAppointment := aListAppXML[nAppoint]

		If !Empty(cXMLErr := MNTI851EAP(oAppointment)) // Estrutura apontamentos recebidos
			lRet := .F.
            Exit
		Endif

	Next nAppoint

    If lRet
        // Valida apontamentos
        If Empty(cXMLErr) .And. !Empty(aRecsTV1)
            aXMLRet := MNTI851VAP(aRecsTV1)
            lXMLRet := aXMLRet[1] // .F. Se apresentar erros
            cXMLErr := aXMLRet[2] // Erros encontrados
        Endif

        // Ponto de Entrada que retorna erros para o RM e não executa a gravação na TV1 e TV2
        If !lXMLRet .And. ExistBlock("MNTI851A")
            lXMLRet := ExecBlock("MNTI851A",.F.,.F.,{StrTokArr(cXMLErr,"###")})
        Else
            lXMLRet := .T.
        EndIf

    EndIf

    //Garante que o Xml esteja vazio para iniciar a gravação
    cXMLRet := IIf(lXMLRet, "", cXMLErr)

    // Efetua a gravação na TV1 e TV2
    If lXMLRet

        dbSelectArea(cTRB2) // Exclui apontamento com mesma chave do apontamento recebido
        dbSetOrder(2)
        dbGoTop()
        While !Eof()

            If (cTRB2)->DELETADO == cDel
                dbSelectArea("TV2")
                dbSetOrder(1)
                If dbSeek((cTRB2)->TV2_FILIAL+(cTRB2)->TV2_EMPRES+(cTRB2)->TV2_CODBEM+(cTRB2)->(DTOS(TV2_DTSERV))+(cTRB2)->TV2_TURNO+(cTRB2)->TV2_PDIHRI+(cTRB2)->TV2_PDIHRF+(cTRB2)->TV2_HRINI+(cTRB2)->TV2_CODATI)
                    RecLock("TV2",.F.)
                    dbDelete()
                    TV2->(MsUnLock())
                EndIf
            Else // Grava Registro na TV2 caso não esteja marcarcado como exclusão na cTRB2
                RecLock("TV2",.T.)
                TV2->TV2_FILIAL   := (cTRB2)->TV2_FILIAL
                TV2->TV2_EMPRES   := (cTRB2)->TV2_EMPRES
                TV2->TV2_CODBEM   := (cTRB2)->TV2_CODBEM
                TV2->TV2_DTSERV   := (cTRB2)->TV2_DTSERV
                TV2->TV2_TURNO    := (cTRB2)->TV2_TURNO
                TV2->TV2_CODATI   := (cTRB2)->TV2_CODATI
                TV2->TV2_HRINI    := (cTRB2)->TV2_HRINI
                TV2->TV2_HRFIM    := (cTRB2)->TV2_HRFIM
                TV2->TV2_CODFRE   := (cTRB2)->TV2_CODFRE
                TV2->TV2_TOTHOR   := (cTRB2)->TV2_TOTHOR
                TV2->TV2_PDIHRI   := (cTRB2)->TV2_PDIHRI
                TV2->TV2_PDIHRF   := (cTRB2)->TV2_PDIHRF
                TV2->TV2_CONTAD   := (cTRB2)->TV2_CONTAD
                TV2->TV2_INTTSK   := (cTRB2)->TV2_INTTSK
                TV2->TV2_INDERR   := (cTRB2)->TV2_INDERR
                TV2->TV2_MSGERR   := (cTRB2)->TV2_MSGERR
                TV2->TV2_WEBFLE   := (cTRB2)->TV2_WEBFLE
                TV2->TV2_SEQREL   := (cTRB2)->TV2_SEQREL
                TV2->(MsUnLock())
            EndIf
            dbSelectArea(cTRB2)
            dbSkip()

        EndDo

        dbSelectArea(cTRB1) // Atualiza/Acerta contadores conforme a apropriação em questão
        dbSetOrder(2)
        dbGoTop()
        While !Eof()
            If (cTRB1)->DELETADO == cDel
                dbSelectArea("TV1")
                MNTI851EXC("TV1", (cTRB1)->NREC, 5)
            Else // Grava Registro na TV1 caso não esteja marcarcado como exclusão na cTRB1
            	dbSelectArea("TV1")
            	dbSetOrder(1)
            	If !dbSeek(xFilial("TV1")		+;	// Filial
				    (cTRB1)->TV1_EMPRES			+;	// Empresa
				    (cTRB1)->TV1_CODBEM			+;	// Equipamento
					DTOS((cTRB1)->TV1_DTSERV)	+;	// Data de Inicio
					(cTRB1)->TV1_TURNO  		 ;  // Turno (Equipamento)
		            )
		            
		            RecLock("TV1",.T.)
                Else
                	RecLock("TV1",.F.)
                EndIf
                TV1->TV1_FILIAL   := (cTRB1)->TV1_FILIAL
                TV1->TV1_EMPRES   := (cTRB1)->TV1_EMPRES
                TV1->TV1_CODBEM   := (cTRB1)->TV1_CODBEM
                TV1->TV1_PLACA    := (cTRB1)->TV1_PLACA
                TV1->TV1_TURNO    := (cTRB1)->TV1_TURNO
                TV1->TV1_DTSERV   := (cTRB1)->TV1_DTSERV
                TV1->TV1_HREXI    := (cTRB1)->TV1_HREXI
                TV1->TV1_HREXF    := (cTRB1)->TV1_HREXF
                TV1->TV1_HRINI    := (cTRB1)->TV1_HRINI
                TV1->TV1_CONINI   := (cTRB1)->TV1_CONINI
                TV1->TV1_HRFIM    := (cTRB1)->TV1_HRFIM
                TV1->TV1_CONFIM   := (cTRB1)->TV1_CONFIM
                TV1->TV1_TERCEI   := (cTRB1)->TV1_TERCEI
                TV1->TV1_OPERAD   := (cTRB1)->TV1_OPERAD
                TV1->TV1_NOMEOP   := (cTRB1)->TV1_NOMEOP
                TV1->TV1_OBS1     := (cTRB1)->TV1_OBS1
                TV1->TV1_OBS2     := (cTRB1)->TV1_OBS2
                TV1->TV1_HRAMNT   := (cTRB1)->TV1_HRAMNT
                TV1->TV1_HRATRA   := (cTRB1)->TV1_HRATRA
                TV1->TV1_HRACHU   := (cTRB1)->TV1_HRACHU
                TV1->TV1_HRAPLA   := (cTRB1)->TV1_HRAPLA
                TV1->TV1_HRAEXP   := (cTRB1)->TV1_HRAEXP
                TV1->TV1_INDERR   := (cTRB1)->TV1_INDERR
                TV1->TV1_MSGERR   := (cTRB1)->TV1_MSGERR
                TV1->TV1_WEBFLE   := (cTRB1)->TV1_WEBFLE
                TV1->(MsUnLock())
            EndIf

			// Atualiza a hora inicio e fim da atividade na tabela TV2
			dbSelectArea( 'TV2' )                                         
			dbSetOrder( 1 ) // TV2_FILIAL + TV2_EMPRES + TV2_CODBEM + DTOS( TV2_DTSERV ) + TV2_TURNO + TV2_PDIHRI + TV2_PDIHRF + TV2_HRINI + TV2_CODATI
			If dbSeek( xFilial("TV2") + TV1->TV1_EMPRES + TV1->TV1_CODBEM + DtoS(TV1->TV1_DTSERV) + TV1->TV1_TURNO )
				While !Eof() .And. TV2->TV2_FILIAL == xFilial("TV2") .And. TV2->TV2_EMPRES == TV1->TV1_EMPRES ;
							.And. TV2->TV2_CODBEM == TV1->TV1_CODBEM .And. TV2->TV2_DTSERV == TV1->TV1_DTSERV ;
							.And. TV2->TV2_TURNO == TV1->TV1_TURNO

					Reclock("TV2", .F.)
					TV2->TV2_PDIHRI   := TV1->TV1_HRINI
                	TV2->TV2_PDIHRF   := TV1->TV1_HRFIM
					TV2->(MsUnLock())

					dbSelectArea("TV2")
					dbSkip()
				End
			EndIf

			If lPE851B
				ExecBlock( "MNTI851B",.F.,.F.,{ TV1->TV1_FILIAL, TV1->TV1_EMPRES, TV1->TV1_CODBEM, TV1->TV1_DTSERV,;
				TV1->TV1_TURNO } )
			EndIf

            dbSelectArea(cTRB1)
            dbSkip()
        EndDo

        // Realiza Ajuste do Contador

        For nFieldQry := 1 to Len(aRegsQry)
            fAjustCont( aRegsQry[nFieldQry,1],;
                        aRegsQry[nFieldQry,2],;
                        aRegsQry[nFieldQry,3],;
                        aRegsQry[nFieldQry,4],;
                        aRegsQry[nFieldQry,5],;
                        aRegsQry[nFieldQry,6];
                       )
        Next nFieldQry

        // Estrutura lista de retorno por internalID e grava os registros
        For nFieldID := 1 to Len(aRegsOk)
            cXMLImpOK += MNTI851ATU( aRegsOk[nFieldID,1],;
                                     aRegsOk[nFieldID,2],;
                                     aRegsOk[nFieldID,3],;
                                     aRegsOk[nFieldID,4],;
                                     aRegsOk[nFieldID,5];
                                   )
        Next nFieldID

        // Retorno do InternalId do apontamento cadastrado
        If !Empty(cXMLImpOK)
            cXMLRet := "<ListOfInternalId>"
            cXMLRet += IIf(!Empty(cXMLImpOK), cXMLImpOK, "")
            cXMLRet += "</ListOfInternalId>"
        EndIf

    EndIf

Return {lXMLRet, cXMLRet}

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTI851EAP
Estrutura XML para array de apontamentos.

@param oXmlApp

@author Hugo R. Pereira
@since 12/06/13
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MNTI851EAP(oAppointment)

    Local aTurnoXML
	Local cEmpresaXML
    Local cFilialXML
    Local cIDEmpXML
	Local cCodBarraXML
    Local cIDApont
	Local cCCustoXML
    Local cIDCCustXML
	Local cAtividXML
    Local cIDAtividXML
	Local cTarefaXML
    Local cIDTarefaXML
	Local nHrmXMLIni := 0
	Local nKmXMLIni  := 0
    Local cTotHrXML
    Local nPosTV1
	Local nAppointCnt
    Local nAppCount
	Local cXMLRet 	  := ""
	Local cUniqueKey  := ''
	Local nRecTV1     := 0

	Private cTurnoCal

	// Tags XML
	cEmpresaXML  := cEmpAnt
	cFilialXML   := cFilAnt
	cTarefaXML   := Padr( oAppointment:_TaskProjectId:Text     , TamSX3("TV2_INTTSK")[1]	)
	cCodBarraXML := Padr( oAppointment:_EquipmentBarCode:Text  , TamSX3("T9_BARCODE")[1]	)
	cAtividXML   := Padr( oAppointment:_ActivityCode:Text      , TamSX3("TV2_CODATI")[1]	)
	cCCustoXML   := Padr( oAppointment:_CostCenter:Text        , TamSX3("CTT_CUSTO" )[1]	)
	cAtividXML   := Padr( oAppointment:_ActivityCode:Text      , TamSX3("TV2_CODATI")[1]	)
	nHrmXMLIni   := Val( oAppointment:_Hourmeter:Text )
	If nHrmXMLIni == 0
		nKmXMLIni    := Val( oAppointment:_Kilometers:Text )
	EndIf

	// Internal Id's
	cIDEmpXML    := oAppointment:_CompanyInternalId:Text
	cIDApont     := oAppointment:_InternalId:Text
	cIDCCustXML  := oAppointment:_CostCenterInternalId:Text
	cIDAtividXML := oAppointment:_ActivityInternalId:Text
	cIDTarefaXML := oAppointment:_TaskProjectInternalId:Text

	// Recupera data e hora de formato DateTime do XML
	aSDateTimeXML := GetDateXml(oAppointment:_StartDateTimeAppointment:Text)
	aEDateTimeXML := GetDateXml(oAppointment:_EndDateTimeAppointment:Text)
	aEquipXML     := GetByBCode(cCodBarraXML)

	// Efetua validacoes basicas para o prosseguimento do processo
	If Empty(cCodBarraXML)
		cXMLRet := "[EquipmentBarCode] Código de barras inválido."
	ElseIf Empty(aEquipXML) .Or. Empty(aEquipXML[1])
		cXMLRet := "[EquipmentBarCode] Equipamento não encontrado. Verifique o código de barras enviado."
	ElseIf Empty(aSDateTimeXML) .Or. aSDateTimeXML[1] == CToD("") .Or. ( nDowDate := Dow( aSDateTimeXML[1] ) ) == 0
		cXMLRet := "[StartDateTimeAppointment] Data Início inválida."
	ElseIf Empty(aEDateTimeXML) .Or. aEDateTimeXML[1] == CToD("")
		cXMLRet := "[EndDateTimeAppointment] Data Fim inválida."
	ElseIf Empty(cCCustoXML)
		cXMLRet := "[CostCenter] Centro de Custo inválido."
	Else

		// Turno do Equipamento
		aTurnoXML := GetTurnXML(aEquipXML[1], aSDateTimeXML[1])
		If Empty( aTurnoXML )
			cXMLRet := "[Turno] Turno do equipamento inválido. Verifique o turno no cadastro do equipamento."
		Endif

		// Codigo da Atividade
		If Empty(cXMLRet) .And. Empty(cAtividXML)
			If ( MNT850VPAP()[1] )
				cAtividXML := GetNewPar("MV_NGMBATV", "")
			Else
				cXMLRet := "Para envio de apontamentos produtivos para o SIGAMNT é necessário preencher o parâmetro MV_NGMBATV com uma atividade válida."
			Endif
		Endif
	Endif

	If !Empty(cXMLRet)
		aRecsTV1 := {}

		If Type("nListAppXML") == "N" .And. ( nListAppXML > 1 )
			cXMLRet := 	"Código de Barras '" + AllTrim(cCodBarraXML) + "'" + ;
							If( !Empty(aSDateTimeXML), Space(2) + DTOC(aSDateTimeXML[1]) + Space(1) + aSDateTimeXML[2], "" ) + ": " + cXMLRet
		Endif

		Return cXMLRet
	Endif

	cTurnoCal := oAppointment
	If Type("cTurnoCal:_TurnCalendar") <> 'U'
		If Empty(oAppointment:_TurnCalendar:Text) // Verifica se a TAG está vazia
			If lNGTURNL  //Se estiver, verifica se o parâmetro indica que deva gerar inconsistência nesses casos.
				cXMLRet := "Sistema parametrizado para não aceitar a TAG TurnCalendar vazia. Favor alterar o apontamento ou o parâmetro "+;
				           "MV_NGTURNL caso a validação não atenda a necessidade."
				Return cXMLRet
			Else
				cTurnoCal := aTurnoXML[1] // Se parametro for 2 ou não existir, pega o calendário do bem.
				aTurnoXML := GetTurnXML(aEquipXML[1],aSDateTimeXML[1],cTurnoCal)
			EndIf
		Else
			cTurnoCal := Padr(oAppointment:_TurnCalendar:Text,TamSX3("TV1_TURNO")[1])
			aTurnoXML := GetTurnXML(aEquipXML[1],aSDateTimeXML[1],cTurnoCal)
		EndIf
	Else
		cTurnoCal := aTurnoXML[1]
	EndIf

	nAppointCnt := 1

	If aEDateTimeXML[1] > aSDateTimeXML[1]
		nAppointCnt := 2
	Endif

	aXSDateTimeXML := aClone(aSDateTimeXML)
	aXEDateTimeXML := aClone(aEDateTimeXML)


	For nAppCount := 1 To nAppointCnt

		If nAppointCnt == 2
			aSDateTimeXML := aClone(aXSDateTimeXML)
			aEDateTimeXML := aClone(aXEDateTimeXML)

			If nAppCount == 1
				aEDateTimeXML[1] := aSDateTimeXML[1]
				aEDateTimeXML[2] := "23:59"
			Else
				aSDateTimeXML[1] := aEDateTimeXML[1]
				aSDateTimeXML[2] := "00:00"
				aTurnoXML        := GetTurnXML(aEquipXML[1], aSDateTimeXML[1],cTurnoCal)
			Endif

		Endif

		// Calcula tempo de duracao da atividade (Periodo da Apontamento)
		cTotHrXML := NGCALCHCAR(aSDateTimeXML[1]	,; // Data Inicio
								aSDateTimeXML[2]	,; // Hora Inicio
								aEDateTimeXML[1]    ,; // Data Fim
								aEDateTimeXML[2]     ; // Hora Fim
								)
		dbSelectArea("TV1")
		dbSetOrder(1)
		If dbSeek(xFilial("TV1")			+;	// Filial
				    cEmpAnt					+;	// Empresa
				    aEquipXML[1]			+;	// Equipamento
					DTOS(aSDateTimeXML[1])	+;	// Data de Inicio
					cTurnoCal  				 ;  // Turno (Equipamento)
		            )

			nRecTV1 := TV1->(Recno())

            // Posiciona no Registro corrente
            TV1->(DbGoTo(nRecTV1))
            // Adiciona o registro que devia ter deletado para a tabela com o campo 'Deletado'
            RecLock((cTRB1),.T.)
            (cTRB1)->TV1_FILIAL   := TV1->TV1_FILIAL
            (cTRB1)->TV1_EMPRES   := TV1->TV1_EMPRES
            (cTRB1)->TV1_CODBEM   := TV1->TV1_CODBEM
            (cTRB1)->TV1_PLACA    := TV1->TV1_PLACA
            (cTRB1)->TV1_TURNO    := TV1->TV1_TURNO
            (cTRB1)->TV1_DTSERV   := TV1->TV1_DTSERV
            (cTRB1)->TV1_HREXI    := TV1->TV1_HREXI
            (cTRB1)->TV1_HREXF    := TV1->TV1_HREXF
            (cTRB1)->TV1_HRINI    := TV1->TV1_HRINI
            (cTRB1)->TV1_CONINI   := TV1->TV1_CONINI
            (cTRB1)->TV1_HRFIM    := TV1->TV1_HRFIM
            (cTRB1)->TV1_CONFIM   := TV1->TV1_CONFIM
            (cTRB1)->TV1_TERCEI   := TV1->TV1_TERCEI
            (cTRB1)->TV1_OPERAD   := TV1->TV1_OPERAD
            (cTRB1)->TV1_NOMEOP   := TV1->TV1_NOMEOP
            (cTRB1)->TV1_OBS1     := TV1->TV1_OBS1
            (cTRB1)->TV1_OBS2     := TV1->TV1_OBS2
            (cTRB1)->TV1_HRAMNT   := TV1->TV1_HRAMNT
            (cTRB1)->TV1_HRATRA   := TV1->TV1_HRATRA
            (cTRB1)->TV1_HRACHU   := TV1->TV1_HRACHU
            (cTRB1)->TV1_HRAPLA   := TV1->TV1_HRAPLA
            (cTRB1)->TV1_HRAEXP   := TV1->TV1_HRAEXP
            (cTRB1)->TV1_INDERR   := TV1->TV1_INDERR
            (cTRB1)->TV1_MSGERR   := TV1->TV1_MSGERR
            (cTRB1)->TV1_WEBFLE   := TV1->TV1_WEBFLE
            (cTRB1)->NREC         := nRecTV1

            (cTRB1)->(MsUnLock())

            nRecTV1 := (cTRB1)->(Recno())

		Endif

		//+-----------------------------------------------------------------+
		//| Inclusao do Apontamento recebido como atividade da Parte Diaria |
		//+-----------------------------------------------------------------+
		dbSelectArea( cTRB1 )
		dbSetOrder( 1 ) //TV1_FILIAL + TV1_EMPRES + TV1_CODBEM + TV1_DTSERV + TV1_TURNO + TV1_HRINI + TV1_HRFIM
		If dbSeek( xFilial( 'TV1' ) + cEmpAnt + aEquipXML[1] + DToS( aSDateTimeXML[1] ) + cTurnoCal )

			RecLock( (cTRB1), .F. )
			If HtoM(aEDateTimeXML[2]) > HtoM((cTRB1)->TV1_HRFIM)
				(cTRB1)->TV1_HRFIM  := aEDateTimeXML[2]
			EndIf
			If HtoM(aSDateTimeXML[2]) < HtoM((cTRB1)->TV1_HRINI)
				(cTRB1)->TV1_HRINI  := aSDateTimeXML[2]
			EndIf
			If nHrmXMLIni > 0
				If nHrmXMLIni < (cTRB1)->TV1_CONINI
					(cTRB1)->TV1_CONINI := nHrmXMLIni
				EndIf
				If nHrmXMLIni > (cTRB1)->TV1_CONFIM
					(cTRB1)->TV1_CONFIM := nHrmXMLIni
				EndIf
			Else
				If nKmXMLIni < (cTRB1)->TV1_CONINI
					(cTRB1)->TV1_CONINI := nKmXMLIni
				EndIf
				If nKmXMLIni > (cTRB1)->TV1_CONFIM
					(cTRB1)->TV1_CONFIM := nKmXMLIni
				EndIf
			EndIf
			(cTRB1)->( MsUnlock() )

			nRecTV1 := (cTRB1)->( RecNo() )

		Else

			RecLock((cTRB1), .T.)
			(cTRB1)->TV1_FILIAL := xFilial("TV1")
			(cTRB1)->TV1_EMPRES := cEmpAnt
			(cTRB1)->TV1_CODBEM := aEquipXML[1]
			(cTRB1)->TV1_PLACA  := aEquipXML[2]
			(cTRB1)->TV1_TURNO  := cTurnoCal
			(cTRB1)->TV1_DTSERV := aSDateTimeXML[1]
			(cTRB1)->TV1_HRINI  := aSDateTimeXML[2]
			(cTRB1)->TV1_HRFIM  := aEDateTimeXML[2]
			If nHrmXMLIni > 0
				(cTRB1)->TV1_CONINI := nHrmXMLIni
				(cTRB1)->TV1_CONFIM := nHrmXMLIni
			Else
				(cTRB1)->TV1_CONINI := nKmXMLIni
				(cTRB1)->TV1_CONFIM := nKmXMLIni
			EndIf
			(cTRB1)->TV1_HRAEXP := cTotHrXML
			(cTRB1)->TV1_HRAMNT := "  :  "
			(cTRB1)->TV1_HRATRA := "  :  "
			(cTRB1)->TV1_HRACHU := "  :  "
			(cTRB1)->TV1_HRAPLA := "  :  "
			(cTRB1)->TV1_MSGERR := ""
			(cTRB1)->TV1_INDERR := "2"
			(cTRB1)->TV1_WEBFLE := "N"
			(cTRB1)->TV1_TERCEI := "1"
			(cTRB1)->TV1_OPERAD := "TERC"

			If !Empty(aTurnoXML[2])
				(cTRB1)->TV1_HREXI  := aTurnoXML[2][1]
				(cTRB1)->TV1_HREXF  := aTurnoXML[2][2]
			Endif

			If (cTRB1)->TV1_CONINI == 0
                (cTRB1)->TV1_CONINI := 1
			EndIf

			(cTRB1)->(MsUnlock())

			nRecTV1 := (cTRB1)->(Recno())

		Endif

        // Detalhes/Atividades Parte Diaria
		dbSelectArea( 'TV2' )
		dbSetOrder( 1 ) // TV2_FILIAL + TV2_EMPRES + TV2_CODBEM + TV2_DTSERV + TV2_TURNO + TV2_PDIHRI + TV2_PDIHRF + TV2_HRINI + TV2_CODATI
		If !dbSeek( xFilial( 'TV2' ) + (cTRB1)->TV1_EMPRES + (cTRB1)->TV1_CODBEM + DToS( (cTRB1)->TV1_DTSERV ) +;
			(cTRB1)->TV1_TURNO + (cTRB1)->TV1_HRINI	+ (cTRB1)->TV1_HRFIM + aSDateTimeXML[2] + cAtividXML )

			dbSelectArea( 'TV2' )
			dbSetOrder( 4 ) // TV2_FILIAL+TV2_EMPRES+TV2_CODBEM+DTOS(TV2_DTSERV)+TV2_SEQREL                                                                                                    
			If dbSeek( (cTRB1)->TV1_FILIAL + (cTRB1)->TV1_EMPRES + (cTRB1)->TV1_CODBEM + DToS( (cTRB1)->TV1_DTSERV ) )

				Do While !Eof() .And. (cTRB1)->TV1_FILIAL == TV2->TV2_FILIAL .And. (cTRB1)->TV1_EMPRES == TV2->TV2_EMPRES;
					.And. (cTRB1)->TV1_CODBEM == TV2->TV2_CODBEM .And. DToS( (cTRB1)->TV1_DTSERV ) == DToS( TV2->TV2_DTSERV )

					nSeqTV2 := Val(TV2->TV2_SEQREL)++
					

					TV2->( dbSkip() )

				EndDo

				nSeqTV2++

			Else

				nSeqTV2++

			EndIf

            // Grava registro na Tabela temporaria de Atividades de P. Diaria
			dbSelectArea( cTRB2 )
			dbSetOrder( 1 ) // TV2_FILIAL + TV2_EMPRES + TV2_CODBEM + TV2_DTSERV + TV2_TURNO + TV2_PDIHRI + TV2_PDIHRF + TV2_HRINI + TV2_CODATI
			If !dbSeek( (cTRB1)->TV1_FILIAL + (cTRB1)->TV1_EMPRES + (cTRB1)->TV1_CODBEM + DToS( (cTRB1)->TV1_DTSERV ) +;
				(cTRB1)->TV1_TURNO + (cTRB1)->TV1_HRINI + (cTRB1)->TV1_HRFIM + aSDateTimeXML[2] + cAtividXML )
				
				RecLock( cTRB2, .T. )
					(cTRB2)->TV2_FILIAL := (cTRB1)->TV1_FILIAL
					(cTRB2)->TV2_EMPRES := (cTRB1)->TV1_EMPRES
					(cTRB2)->TV2_CODBEM := (cTRB1)->TV1_CODBEM
					(cTRB2)->TV2_DTSERV := (cTRB1)->TV1_DTSERV
					(cTRB2)->TV2_TURNO  := (cTRB1)->TV1_TURNO
					(cTRB2)->TV2_PDIHRI := (cTRB1)->TV1_HRINI
					(cTRB2)->TV2_PDIHRF := (cTRB1)->TV1_HRFIM
					(cTRB2)->TV2_CODATI := cAtividXML
					(cTRB2)->TV2_HRINI  := aSDateTimeXML[2]
					(cTRB2)->TV2_HRFIM  := aEDateTimeXML[2]
					(cTRB2)->TV2_CODFRE := cCCustoXML
					(cTRB2)->TV2_TOTHOR := cTotHrXML
					If nHrmXMLIni > 0
						(cTRB2)->TV2_CONTAD := nHrmXMLIni
					Else
						(cTRB2)->TV2_CONTAD := nKmXMLIni
					EndIf
					(cTRB2)->TV2_INTTSK := cTarefaXML
					(cTRB2)->TV2_MSGERR := ""
					(cTRB2)->TV2_INDERR := "2"
					(cTRB2)->TV2_WEBFLE := "N"
					(cTRB2)->TV2_SEQREL := StrZero(nSeqTV2, 3)
				(cTRB2)->( MsUnLock() )

			EndIf

			cUniqueKey := (cTRB2)->TV2_FILIAL + (cTRB2)->TV2_EMPRES + (cTRB2)->TV2_CODBEM + DToS( (cTRB2)->TV2_DTSERV ) +;
				(cTRB2)->TV2_SEQREL

		Else

			cUniqueKey := TV2->TV2_FILIAL + TV2->TV2_EMPRES + TV2->TV2_CODBEM + DToS( TV2->TV2_DTSERV ) + TV2->TV2_SEQREL

		EndIf

		// Adiciona Recno do registro da parte diaria para processamento posterior
		If (nPosTV1 := aScan(aRecsTV1, {|x| x[1] == nRecTV1})) == 0
			aAdd(aRecsTV1, {nRecTV1, {}})
			nPosTV1 := Len(aRecsTV1)
		Endif

		aAdd( aRecsTV1[nPosTV1,2], { cUniqueKey, cIDApont } )

	Next nAppCount

Return cXMLRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTI851VAP
Valida apontamentos.

@author Hugo R. Pereira
@since 12/06/13
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MNTI851VAP(aRecsTV1)

	Local nAtivid
	Local nRecTV1

	Local aInconsTV1 := {}
	Local aInconsTV2 := {}

	Local cXMLRet    := ""
    Local cErrosTV1  := ""
    Local cErrosTV2  := ""
	Local lInconsAtv := .F.
    Local nField1
    Local nField2
    Local nAtv1
    Local nAtv2
    Local nAtvs

	Default aRecsTV1  := {}

    Private aCols   := {}
	Private aHeader := {}
	Private n       := 1

	For nRecTV1 := 1 To Len(aRecsTV1)

		If Empty(aRecsTV1[nRecTV1][1])
			Loop
		Endif

		lInconsAtv := .F.
		MNT851PVAR() // Inicializa variaveis Private utilizadas durante o processo de validacao das apropriacoes (MNTA851)

		dbSelectArea(cTRB1)
        dbSetOrder(1)
		dbGoto(aRecsTV1[nRecTV1][1])
		
		dbSelectArea("TV1")
        dbSetOrder(1)
        If dbSeek(xFilial("TV1")		+;	// Filial
				    (cTRB1)->TV1_EMPRES			+;	// Empresa
				    (cTRB1)->TV1_CODBEM			+;	// Equipamento
					DTOS((cTRB1)->TV1_DTSERV)	+;	// Data de Inicio
					(cTRB1)->TV1_TURNO  		 ;  // Turno (Equipamento)
		            )
			//Deleta os contadores para refazer
			MNTI851EXC("TV1", TV1->(Recno()), 5)
		EndIf

        // Joga os campos do registro posicionado na TV1 para os campos da memória para validação na função MNT851VLCP()
        For nField1 := 1 to Len(aDBF1)
            &("M->" + aDBF1[nField1,1]) := &("(cTRB1)->" + aDBF1[nField1,1])
        Next nField1

		aHeader := CabecGetD("TV2", {})
        aCols := {}

        // Faz o mesmo processo da função MakeGetD() mas utilizando a tabela temporaria
        dbSelectArea(cTRB2)
        dbSetOrder(1)
        dbSeek((cTRB1)->TV1_FILIAL+(cTRB1)->TV1_EMPRES+(cTRB1)->TV1_CODBEM+DTOS((cTRB1)->TV1_DTSERV)+(cTRB1)->TV1_TURNO+(cTRB1)->TV1_HRINI+(cTRB1)->TV1_HRFIM)
        While (cTRB2)->TV2_FILIAL+(cTRB2)->TV2_EMPRES+(cTRB2)->TV2_CODBEM+DTOS((cTRB2)->TV2_DTSERV)+(cTRB2)->TV2_TURNO+(cTRB2)->TV2_PDIHRI+(cTRB2)->TV2_PDIHRF == (cTRB1)->TV1_FILIAL+(cTRB1)->TV1_EMPRES+(cTRB1)->TV1_CODBEM+DTOS((cTRB1)->TV1_DTSERV)+(cTRB1)->TV1_TURNO+(cTRB1)->TV1_HRINI+(cTRB1)->TV1_HRFIM
            aAdd(aCols, Array(Len(aHeader)))
            For nField2 := 1 to Len(aHeader)
                aCols[Len(aCols),nField2] := &("(cTRB2)->" + aHeader[nField2,2])
            Next nField2
            aAdd(aCols[Len(aCols)],.F.)
            dbSkip()
        EndDo

        // Consiste que o ultimo contador do bem apontado em dia retroativo seja o inicial do posterior
        SetValuePD(M->TV1_CODBEM, M->TV1_DTSERV, aHeader, aCols, M->TV1_TURNO)

		aInconsTV1 := ValidAppts(.F.) // Verifica Inconsistencias [Cabecalho]
		aInconsTV2 := ValidAppts(.T.) // Verifica Inconsistencias

		// Adiciona erro na posicao de inconsistencia de todos os itens, caso o cabecalho das mesmas tenha alguma inconsistencia
		For nAtivid := 1 To Len(aInconsTV2)
			lInconsAtv := lInconsAtv .Or. Len(aInconsTV2[nAtivid]) > 0 	// Verifica se alguma atividade possui inconsistencia
			If Len(aInconsTV1) > 0
				aAdd( aInconsTV2[nAtivid], "## = Há erros no cabeçalho deste item.")    // Adiciona erro na atividade
			Endif
		Next nAtivid

		If lInconsAtv // Caso alguma atividade possua inconsistencias geradas durante as validacoes
			aAdd(aInconsTV1, "## = Uma ou mais atividades apresentam erros.")
		Endif

        cErrosTV1 := ""
        cErrosTV2 := ""
        // Grava Inconsistencias da TV1 (Cabeçalho)
        If !Empty(aInconsTV1)
            For nAtv1 := 1 to Len(aInconsTV1)
                cErrosTV1 += aInconsTV1[nAtv1] + CRLF
            Next nAtv1
        EndIf

        // Grava Inconsistencias da TV2 (Atividades)
        If !Empty(aInconsTV2)
            For nAtvs := 1 to Len(aInconsTV2)
                For nAtv2 := 1 to Len(aInconsTV2[nAtvs])
                    cErrosTV2 += aInconsTV2[nAtvs,nAtv2] + CRLF
                Next nAtv2
            Next nAtvs
        EndIf

        // Grava inconsistencias no XML de retorno
        If !Empty(cErrosTV1) .Or. !Empty(cErrosTV2)

            cXMLRet += CRLF + "Registro: " + (cTRB1)->TV1_CODBEM + CRLF +;
                       "Data de Servico: " + DTOS((cTRB1)->TV1_DTSERV) + CRLF +;
                       "Hora Inicial: " + (cTRB1)->TV1_HRINI + CRLF +;
                       "Data Final " + (cTRB1)->TV1_HRFIM + CRLF + CRLF
            cXMLRet += cErrosTV1
            cXMLRet += cErrosTV2
            cXMLRet += CRLF + "###" + CRLF
        EndIf

        // Efetua processo de inclusao posteriormente
        aAdd(aRegsOk,{aRecsTV1[nRecTV1], aHeader, aCols, aInconsTV1, aInconsTV2})

	Next nRecTV1

Return {Empty(cXMLRet),cXMLRet}

//---------------------------------------------------------------------
/*/{Protheus.doc} GetDateXml
Retorna valor tipo data a partir de uma string (XML).
Exemplo: 2013-07-19T08:30:00

@param cXmlDateTime

@author Hugo R. Pereira
@since 12/06/13
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function GetDateXml(cXmlDateTime)

	Local dDateXml := CToD("")
	Local cTimeXml := "00:00"
	Local nPosTime := 0

	Default cXmlDateTime := ""

	If !Empty(cXmlDateTime)
		nPosTime := At( "T", cXmlDateTime ) // Verifica posicao do indicador de tempo no formato DateTime

		If nPosTime > 0
			dDateXml := SToD( StrTran( SubStr(cXmlDateTime, 1, nPosTime - 1), "-", "" ) ) // Recupera Data
			cTimeXml := SubStr( cXmlDateTime, nPosTime + 1, 5 ) // Recupera Hora
		Endif
	Endif

Return { dDateXml, cTimeXml }

//---------------------------------------------------------------------
/*/{Protheus.doc} GetByBCode
Retorna dados do equipamento a partir do codigo de barras.
"T9_BARCODE+T9_FILIAL+T9_CODBEM"

@param cBarCode

@author Hugo R. Pereira
@since 12/06/13
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function GetByBCode(cBarCode)

	Local nOrdBarCode := NGRETORDEM("ST9", "T9_BARCODE+T9_FILIAL+T9_CODBEM", .F.)
	Local aEquip      := { Space(TamSx3("T9_CODBEM")[1]), Space(TamSx3("T9_PLACA")[1]) }

	If !Empty(nOrdBarCode) .And. !Empty(cBarCode)
		dbSelectArea("ST9")
		dbSetOrder(nOrdBarCode)
		If dbSeek(cBarCode + xFilial("ST9")) // dbSeek( If(NGSx2Modo("ST9") == "C", xFilial("ST9"), cFilXML) + cBarCode)
			aEquip[1] := ST9->T9_CODBEM
			aEquip[2] := ST9->T9_PLACA
		EndIf
	Endif

Return aEquip

//---------------------------------------------------------------------
/*/{Protheus.doc} GetTurnXML
Retorna turno referente ao periodo repassado.

@author Hugo R. Pereira
@since 12/06/13
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function GetTurnXML(cCodBem, dDataIni, cCalend)

	Local cTurnXML := NGSeek("ST9", cCodBem, 1, "T9_CALENDA")
	Local nDowDate := Dow(dDataIni)

	Local aCalend  := {}
	Local cHrExpIni
	Local cHrExpFim

	Local aTurnXML := {}

	Default cCalend := ""

	If !Empty(cCalend)
		cTurnXML := cCalend
	EndIf

	If Empty(cTurnXML) .Or. Empty( aCalend := aClone( NGCALENDAH(cTurnXML) ) ) .Or. nDowDate == 0
		Return {}
	Endif

	If !Empty(aCalend[nDowDate][2])
		cHrExpIni := aCalend[nDowDate][2][1][1]
		cHrExpFim := aCalend[nDowDate][2][Len(aCalend[nDowDate][2])][2]
		aTurnXML  := { cHrExpIni, cHrExpFim }
	EndIf

Return { cTurnXML, aTurnXML }

//---------------------------------------------------------------------
/*/{Protheus.doc} SetValuePD
Dados Parte Diara Atual.

@author Hugo R. Pereira
@since 12/06/13
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function SetValuePD(cCodBem, dDataIni, aHeader, aCols, cCalend)

	Local nPosAtv := aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "TV2_CODATI" } )
	Local nPosTHr := aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "TV2_TOTHOR" } )
	Local nPosHrI := aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "TV2_HRINI"  } )
	Local nPosHrF := aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "TV2_HRFIM"  } )
	Local nPosHrm := aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "TV2_CONTAD" } )

	Local aTurno  := GetTurnXML(cCodBem, dDataIni, cCalend)

	Local nAtivid
    Local cAliasQry
    Local aOldArea

	Local aInicio	:= {}
	Local aFim 		:= {}

	Private aTotHoras  := { 0, 0, 0, 0, 0 } // Totalizador de horas das atividades: Manutencao, Trabalhadas, Chuva, Planejamento, Expediente

	If !Empty(aTurno[2])
		M->TV1_HREXI := aTurno[2][1]
		M->TV1_HREXF := aTurno[2][2]
	Else
		M->TV1_HREXI := "00:00"
		M->TV1_HREXF := "00:00"
	Endif

	// Transforma as Horas 00:00 e 24:00 do Expediente
	If M->TV1_HREXI == "24:00"
		M->TV1_HREXI := "00:00"
	EndIf

	If M->TV1_HREXF == "24:00"
			M->TV1_HREXF := "23:59"
	EndIf

	// Agrupa hora das atividades conforme tipo da atividade
	For nAtivid := 1 To Len(aCols)
		AddTotal( aCols[nAtivid][nPosAtv], aCols[nAtivid][nPosTHr] )
	Next nAtivid

	// Atualiza total de horas conforme tipo de atividade
	M->TV1_HRATRA := NTOH(aTotHoras[1]) // Trabalhadas
	M->TV1_HRACHU := NTOH(aTotHoras[2]) // Chuva
	M->TV1_HRAMNT := NTOH(aTotHoras[3]) // Manutencao
	M->TV1_HRAPLA := NTOH(aTotHoras[4]) // Planejamento

	// Calcula tempo de expediente baseado no inicio e fim do turno
	M->TV1_HRAEXP := NGCALCHCAR(M->TV1_DTSERV												,;
								M->TV1_HRINI 												,;
								M->TV1_DTSERV + If( M->TV1_HRFIM < M->TV1_HRINI , 1, 0 )	,;
								M->TV1_HRFIM 												;
								)

	If SuperGetMV("MV_NGPARCO",.F.,"N") == "S"

        aAdd(aRegsQry,{(cTRB1)->TV1_FILIAL, (cTRB1)->TV1_EMPRES, (cTRB1)->TV1_CODBEM, (cTRB1)->TV1_DTSERV, (cTRB1)->TV1_HRINI, (cTRB1)->TV1_CONINI})

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidAppts
Consiste apontamento.

@param lAtividades

@author Hugo R. Pereira
@since 12/06/13
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function ValidAppts(lAtividades)

	Local aAreaSM0    := {}
	Local aIncons     := {} // Array de inconsistencia (Return)
	Local aInconsAtv  := {}
	Local nAtivid

	Default lAtividades := .F.

	If !lAtividades // Se nao for o processo de validacao das atividades, cabecalho

		// ------------------------------------------------------------
		// Consistindo Parte Diaria
		// ------------------------------------------------------------

		dbSelectArea("SM0")

		// Verifica se empresa e filial sao validas
		If ValidEmp((cTRB1)->TV1_EMPRES + (cTRB1)->TV1_FILIAL)

			aIncons := GetPartD()

		Else

			aAreaSM0 := SM0->(GetArea())

			dbSelectArea("SM0")
			dbSetOrder(1)
			If dbSeek((cTRB1)->TV1_EMPRES)
				aAdd(aIncons, "01 = Filial Inválida.") // "01 = Filial Inválida."
			Else
				aAdd(aIncons, "02 = Empresa Inválida.") //"02 = Empresa Inválida."
			EndIf

			RestArea(aAreaSM0)

		Endif

		aIncons := OrdIncons(aIncons)

	ElseIf lAtividades

		// ------------------------------------------------------------
		// Consistindo Atividades da Parte Diaria
		// ------------------------------------------------------------

		aInconsAtv := VrfAtvGD(aCols)

		For nAtivid := 1 To Len(aInconsAtv)
			aInconsAtv[nAtivid] := OrdIncons(aInconsAtv[nAtivid])
		Next nAtivid

	EndIf

Return If(!lAtividades, aIncons, aInconsAtv)

//---------------------------------------------------------------------
/*/{Protheus.doc} OrdIncons
Ordena inconsistencias.

@author Hugo R. Pereira
@since 12/06/13
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function OrdIncons(aArrayIncons)
Return aSort( aArrayIncons, , , {|x,y|	SubStr(x, 1, 2) < ;
													SubStr(y, 1, 2) } )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetPartD
Consiste apontamento.

@author Hugo R. Pereira
@since 12/06/13
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function GetPartD()

	Local aOldReadV := ReadVar()

	Local aCampos   := {}
	Local aIncLinGd := {}
	Local aIncons   := {}

	Local cMCampo
	Local nFld

	aCampos := NGCAMPNSX3("TV1", {} , , , .T.)

	// Verifica validacoes de campos
	For nFld := 1 To Len(aCampos)

		cMCampo    	:= "M->" + aCampos[nFld]
		__ReadVar  	:= cMCampo

		aIncLinGd := MNT851VLCP(aCampos[nFld], .F.)

		If !Empty(aIncLinGd)
			aAdd( aIncons, "[" + aIncLinGd[1] + "] = " + aIncLinGd[2] )
		Endif

	Next nFld

	__ReadVar := aOldReadV

Return aIncons

//---------------------------------------------------------------------
/*/{Protheus.doc} VrfAtvGD
Consiste apontamento.

@author Hugo R. Pereira
@since 12/06/13
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function VrfAtvGD(aCols)

	Local aIncLinGd := {}
	Local aIncons   := {}
	Local nLine, nFld

	aInconsAtv := Array( Len(aCols) )
	n          := 1

	dbSelectArea("TV2")

	For nLine := 1 To Len(aCols)

		If aTail(aCols[nLine]) // Apenas as nao deletadas
			Loop
		Endif

		aIncons   := {}
		aIncLinGd := {}
		n         := nLine

		RegToMemory("TV2", .T.)

		// Verifica validacoes de campos
		For nFld := 1 To Len(aHeader)

			&("M->" + aHeader[nFld][2]) := aCols[nLine][nFld]
			If Alltrim(aHeader[nFld][2]) <> 'TV2_CONTAD'
				If !Empty( aIncLinGd := MNT851VLGD(aHeader[nFld][2], .F.) )
					aAdd( aIncons, "[" + aIncLinGd[1] + "] = " + aIncLinGd[2] )
				Endif
			EndIf

		Next nFld

		If !Empty( aIncLinGd := MNT851LIOK(.F.) )
			aAdd( aIncons, "[" + aIncLinGd[1] + "] = " + aIncLinGd[2] )
		EndIf

		aInconsAtv[nLine] := aClone(aIncons)

	Next nLine

Return aInconsAtv

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidEmp
Valida empresa.

@param cVerEmp Empresa a ser validada.

@author Hugo R. Pereira
@since 12/06/13
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function ValidEmp(cVerEmp)

	Local lValidOK := .T.
	Local aArea    := GetArea()
	Local aAreaSM0 := SM0->(GetArea())

	dbSelectArea("SM0")
	dbSetOrder(1)
	lValidOK := dbSeek(cVerEmp)

	RestArea(aAreaSM0)
	RestArea(aArea)

Return lValidOK

//---------------------------------------------------------------------
/*/{Protheus.doc} AddTotal
Calcula as Horas das Atividades.

@author Wagner S. de Lacerda
@since 04/08/2011
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function AddTotal(cAtividade, cTotHoras)

	Local nHoraAtv := 0

	dbSelectArea("TV0")
	dbSetOrder(1)
	If dbSeek( xFilial("TV0") + cAtividade )

		nHoraAtv := HTON(cTotHoras)

		If TV0_TIPHOR == "1"     // Trabalhada
			aTotHoras[1] += nHoraAtv

		ElseIf TV0_TIPHOR == "2" // Chuva
			aTotHoras[2] += nHoraAtv

		ElseIf TV0_TIPHOR == "3" // Manutencao
			aTotHoras[3] += nHoraAtv

		ElseIf TV0_TIPHOR == "4" // Planejamento
			aTotHoras[4] += nHoraAtv

		EndIf

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTI851EX
Exclui apropriacao conforme InternalId repassado.

@param cIDApont InternalId do Apontamento/Apropriacao.

@author Hugo R. Pereira
@since 12/06/13
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MNTI851EX(cInternalIdApp)

	Local cIDApont := AllTrim( CFGA070Int( cRefProduct, "TV2", "TV2_CODBEM" , cInternalIdApp  ) )
	Local cPKeyTV1 := ""
	Local cSeekID  := ""

	If Empty(cIDApont)
		Return
	Endif

	cSeekID := &( StrTran( cIDApont, "|", "+" ) )

	dbSelectArea("TV2")
	dbSetOrder(1)
	If dbSeek( cSeekID )

		cPKeyTV1 := &( "TV2_FILIAL+TV2_EMPRES+TV2_CODBEM+DTOS(TV2_DTSERV)+TV2_TURNO+TV2_PDIHRI+TV2_PDIHRF" )

		RecLock("TV2", .F.)
		dbDelete()
		TV2->(MsUnLock())

	Endif

	dbSelectArea("TV2")
	dbSetOrder(1)
	If !dbSeek( cPKeyTV1 )

		// Apropriacao Diaria
		dbSelectArea("TV1")
		dbSetOrder(1)
		If dbSeek( cPKeyTV1 )

			// Atualiza/Acerta contadores conforme a exclusao da apropriação em questão
			MNTI851EXC("TV1", TV1->(Recno()), 5)

			dbSelectArea("TV1")
			RecLock("TV1", .F.)
			dbDelete()
			TV1->(MsUnLock())

		Endif

	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTI851EXC
Programa de exclusão de Atividade Diária.

@author Evaldo Cevinscki Jr.
@since 11/05/2010
@version P11
@return true ou false conforme validação
/*/
//---------------------------------------------------------------------
Static Function MNTI851EXC(cAlias, nRecno, nOpc)

	Local i, nRet := 1
	Local vVDadoE := { TV1->TV1_CODBEM, TV1->TV1_DTSERV, TV1->TV1_HRINI, TV1->TV1_HRFIM }

	Local aRetTPN := NgFilTPN( TV1->TV1_CODBEM, TV1->TV1_DTSERV, TV1->TV1_HRINI )
	Local cFilTPN := aRetTPN[1]
	Local aAreaTV1 := {}

	dbSelectArea( "TV1" )
	aAreaTV1 := GetArea()

	If cFilTPN = " "
		cFilTPN := TV1->TV1_FILIAL
	EndIf

	// Referentes ao primeiro contador
	aARALTC :=  {	'STP','STP->TP_FILIAL','STP->TP_CODBEM',;
   	            'STP->TP_DTLEITU','STP->TP_HORA','STP->TP_POSCONT',;
						'STP->TP_ACUMCON','STP->TP_VARDIA','STP->TP_VIRACON' }

	aARABEM := { 	'ST9','ST9->T9_POSCONT','ST9->T9_CONTACU', ;
   	          	'ST9->T9_DTULTAC','ST9->T9_VARDIA' }

	For i := 1 To 2

	    dbSelectArea( aARALTC[1] )
	    dbSetOrder( 5 )
	    If dbSeek( xFilial( aARALTC[1],cFilTPN ) + vVDadoE[1] + DTOS( vVDadoE[2] ) + If( i == 1,vVDadoE[3],vVDadoE[4] ) )

		    nRECNSTP := Recno()
	      	lULTIMOP := .T.
	      	nACUMFIP := 0
	      	nCONTAFP := 0
	      	nVARDIFP := 0
	      	dDTACUFP := CTOD( "  /  /  " )
	      	cHRACU   := "  :  "
	      	dbSkip( -1 )
		   If !EoF() .And. !BoF() .And. &( aARALTC[2]) = xFilial(aARALTC[1],cFilTPN ) .And. ;
		    	&( aARALTC[3] ) == vVDadoE[1]

				nACUMFIP := &( aARALTC[7] )
				dDTACUFP := &( aARALTC[4] )
				nCONTAFP := &( aARALTC[6] )
				nVARDIFP := &( aARALTC[8] )
				cHRACU   := &( aARALTC[5] )

			EndIf

			DbGoTo( nRECNSTP )

			nACUMDEL := STP->TP_ACUMCON

			dbSelectArea( aARALTC[1] )
			RecLock( aARALTC[1],.F. )
			DbDelete()
			MsUnLock( aARALTC[1] )

			MNTA875ADEL( vVDadoE[1],vVDadoE[2],If( i == 1,vVDadoE[3],vVDadoE[4]),1,cFilTPN,cFilTPN )

		EndIf
	Next i

	RestArea( aAreaTV1 )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTI851ATU
Inclui apropriação conforme dados recebidos.
PK TV1 : 'TV1_FILIAL+TV1_EMPRES+TV1_CODBEM+DTOS(TV1_DTSERV)+TV1_TURNO+TV1_HRINI+TV1_HRFIM'
PK TV2 : 'TV2_FILIAL+TV2_EMPRES+TV2_CODBEM+DTOS(TV2_DTSERV)+TV2_TURNO+TV2_PDIHRI+TV2_PDIHRF+TV2_HRINI+TV2_CODATI'

@author Hugo R. Pereira
@since 12/06/13
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MNTI851ATU( aRecTV1, aHeader, aCols, aInconsTV1, aInconsTV2 )

    Local aActivity    := {}
	Local cXMLRet      := ""
	Local cValueExt
	Local nAtivid
	Local cHorIniTV1
	Local cHorFimTV1
	Local nColumn
	Local cValCol
	Local nPosTV2

	//-------------------------------------
	// Grava Parte Diaria
	//-------------------------------------

	dbSelectArea(cTRB1)
	dbGoTo( aRecTV1[1] )
    dbSelectArea("TV1")
    dbSetOrder(1)
    If dbSeek((cTRB1)->TV1_FILIAL+(cTRB1)->TV1_EMPRES+(cTRB1)->TV1_CODBEM+(cTRB1)->(DTOS(TV1_DTSERV))+(cTRB1)->TV1_TURNO+(cTRB1)->TV1_HRINI+(cTRB1)->TV1_HRFIM)
        cHorIniTV1 	:= TV1->TV1_HRINI
        cHorFimTV1 	:= TV1->TV1_HRFIM

        RecLock("TV1", .F.)

        TV1->TV1_FILIAL := xFilial("TV1")
        TV1->TV1_EMPRES := cEmpAnt
        TV1->TV1_MSGERR := GetIncons(aInconsTV1)
        TV1->TV1_INDERR := If( !Empty(TV1->TV1_MSGERR), "1", "2" )

        TV1->(MsUnlock())

        // Grava Contadores - mesma funcionalidade do OAS1A003
        If TV1->TV1_INDERR == "2"
            NGTRETCON(TV1->TV1_CODBEM,TV1->TV1_DTSERV,TV1->TV1_CONINI,TV1->TV1_HRINI,1,,,"C")
            If TV1->TV1_DTSERV < dDataBase
                NGTRETCON(TV1->TV1_CODBEM,TV1->TV1_DTSERV,TV1->TV1_CONFIM,TV1->TV1_HRFIM,1,,,"C")
            ElseIf TV1->TV1_DTSERV == dDataBase .And. TV1->TV1_HRFIM <= Time()
                NGTRETCON(TV1->TV1_CODBEM,TV1->TV1_DTSERV,TV1->TV1_CONFIM,TV1->TV1_HRFIM,1,,,"C")
            EndIf
        Endif

        //-------------------------------------
        // Grava Atividades
        //-------------------------------------

        nPosAtv  := aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "TV2_CODATI"} )
        nPosHIni := aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "TV2_HRINI" } )

        For nAtivid := 1 To Len(aCols)

            dbSelectArea("TV2")
            dbSetOrder(1)
            If dbSeek(	xFilial("TV2")					+;
                            TV1->TV1_EMPRES				+;
                            TV1->TV1_CODBEM				+;
                            DTOS(TV1->TV1_DTSERV)		+;
                            TV1->TV1_TURNO					+;
                            cHorIniTV1						+;
                            cHorFimTV1						+;
                            aCols[nAtivid][nPosHIni]	+;
                            aCols[nAtivid][nPosAtv] 	 ;
                        )

                RecLock("TV2",.F.)

                For nColumn := 1 To FCount()
                    nPosCpo := aScan(aHeader, {|x| Upper(AllTrim(x[2])) == Upper(AllTrim(FieldName(nColumn))) } )
                    If nPosCpo > 0
                        FieldPut( nColumn, aCols[nAtivid][nPosCpo] )
                    Endif
                Next nColumn

                TV2->TV2_FILIAL := TV1->TV1_FILIAL
                TV2->TV2_EMPRES := TV1->TV1_EMPRES
                TV2->TV2_CODBEM := TV1->TV1_CODBEM
                TV2->TV2_DTSERV := TV1->TV1_DTSERV
                TV2->TV2_TURNO  := TV1->TV1_TURNO
                TV2->TV2_PDIHRI := TV1->TV1_HRINI
                TV2->TV2_PDIHRF := TV1->TV1_HRFIM
                TV2->TV2_MSGERR := ''
                TV2->TV2_INDERR := If( !Empty(TV2->TV2_MSGERR), "1", "2" )

                TV2->(MsUnlock())

                If ( nPosTV2 := aScan( aRecTV1[2], { |x| x[1] == TV2->TV2_FILIAL + TV2->TV2_EMPRES + TV2->TV2_CODBEM +;
					DToS( TV2->TV2_DTSERV ) + TV2->TV2_SEQREL } ) ) > 0

                    cValueExt :=	TV2->TV2_EMPRES + "|" + TV2->TV2_FILIAL + "|" + TV2->TV2_EMPRES + "|" + TV2->TV2_CODBEM + "|" + DTOS(TV2->TV2_DTSERV)	+ "|" +  TV2->TV2_SEQREL

                    CFGA070Mnt( cRefProduct, "TV2", "TV2_CODBEM", cValueExt, aRecTV1[2][nPosTV2][2], .F., 1 )


                    cXMLRet += "   <InternalId>"                                                            // Tipo de retorno de InternalID
                    cXMLRet += "      <Name>"        + "Appointment" 				+ "</Name>"				// Nome da Entidade detentora dos internalIDs
                    cXMLRet += "      <Origin>"      + aRecTV1[2][nPosTV2][2]	+ "</Origin>"			    // Valor do internalID no sistema de origem
                    cXMLRet += "      <Destination>" + cValueExt						+ "</Destination>"	// Valor do internalID no sistema de destino
                    cXMLRet += "   </InternalId>"

                Endif

            Endif

        Next nAtivid

    EndIf

Return cXMLRet

//---------------------------------------------------------------------
/*/{Protheus.doc} GetIncons
Estrutura inconsistencias encontradas para uma string.

@author Hugo R. Pereira
@since 12/06/13
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function GetIncons(aIncons)

	Local cInconsXML := ""
	Local nIncons

	Default aIncons := {}

	For nIncons := 1 To Len(aIncons)
		cInconsXML += If( nIncons <> 1, CRLF, "" )

		cInconsXML += Replicate("#", 15) + CRLF
		cInconsXML += aIncons[nIncons]   + CRLF
		cInconsXML += Replicate("#", 15) + CRLF
	Next nIncons

Return cInconsXML

//---------------------------------------------------------------------
/*/{Protheus.doc} GetTv1

@author Hamilton Pereira Soldati
@since 11/11/14
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Function GetTv1( cFil, cEmpresa, cCodbem, dData, ntipo )

    Local aValTV1   := {}
    Local cAliasQry

	cAliasQry := GetNextAlias()

	cQueryTV1 := " SELECT TV2_FILIAL, TV2_EMPRES, TV2_CODBEM, TV2_DTSERV,  TV2_HRINI, TV2_HRFIM, TV2_CONTAD"
	cQueryTV1 += " FROM " + RetSQLName("TV2")
	cQueryTV1 += " WHERE TV2_FILIAL = '" + cFil + "' AND TV2_EMPRES = '" +cEmpresa+ "'"
	cQueryTV1 += " AND  TV2_CODBEM = '" +cCodbem+ "' AND D_E_L_E_T_<>'*' "
	cQueryTV1 += " AND  TV2_DTSERV  = '" + DtoS(dData) +" '"
	cQueryTV1 += " ORDER BY TV2_HRINI "
	If nTipo == 2
		cQueryTV1 += " DESC"
	EndIf
	cQueryTV1 := ChangeQuery(cQueryTV1)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryTV1),cAliasQry, .F., .T.)

	dbSelectArea(cAliasQry)

	If nTipo == 2
		aAdd(aValTV1, (cAliasQry)->TV2_HRFIM)
	Else
		aAdd(aValTV1, (cAliasQry)->TV2_HRINI)
	EndIf

    aAdd(aValTV1, (cAliasQry)->TV2_CONTAD)

	(cAliasQry)->(dbCloseArea())

Return aValTV1
//-------------------------------------------------------------------
/*/{Protheus.doc} fAjustCont
Consiste que o ultimo contador do bem apontado no dia anterior seja
o inicial do posterior
@author  Douglas Constancio
@since   23/10/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function fAjustCont(cFil,cEmp,cBem,dDtServ,cHorIni,nContIni)

    Local cAliasQry := GetNextAlias()

    If SuperGetMV("MV_NGPARCO",.F.,"N") == "S"

		cQuery := " SELECT * "
		cQuery += " FROM " + RetSQLName("TV1")
		cQuery += " WHERE TV1_FILIAL = '" +cFil+ "' AND TV1_EMPRES = '" +cEmp+ "'"
		cQuery += " AND  TV1_CODBEM = '" +cBem+ "' AND D_E_L_E_T_<>'*' "
		cQuery += " AND  TV1_DTSERV || TV1_HRINI < '" + DtoS(dDtServ) + cHorIni +"'"
		cQuery += " ORDER BY (TV1_DTSERV || TV1_HRINI) DESC "

		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		dbGoTop()

		aOldArea  := TV1->( GetArea() )

		dbSelectArea("TV1")
		dbSetOrder(1) //TV1_FILIAL+TV1_EMPRES+TV1_CODBEM+DTOS( TV1_DTSERV )+TV1_TURNO+TV1_HRINI+TV1_HRFIM
		If dbSeek((cAliasQry)->TV1_FILIAL + (cAliasQry)->TV1_EMPRES + (cAliasQry)->TV1_CODBEM + ;
			(cAliasQry)->TV1_DTSERV + (cAliasQry)->TV1_TURNO + (cAliasQry)->TV1_HRINI + (cAliasQry)->TV1_HRFIM )

			If nContIni != (cAliasQry)->TV1_CONFIM
				Reclock("TV1",.F.)
				TV1->TV1_CONFIM := nContIni
				MsUnLock("TV1")
			EndIf
		EndIf

		(cAliasQry)->(dbCloseArea())
		RestArea( aOldArea )

    EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} fAddFldVir
Adiciona campos virtuais da tabela existente para o array de campos
da tabela temporaria.
@type function

@author  Douglas P. Constancio
@since   30/10/2017

@param cAliasTbl, Caracter, Alias da tabela que buscará os campos no dicionario.
       aFields  , Array   , Campos que será manipulado.
@return
/*/
//------------------------------------------------------------------------------
Static Function fAddFldVir( cAliasTbl, aFields )

    Local aArea    := GetArea()
    Local aVirtual := {} // Array de campos virtuais da tabela
    Local n        := 1
    Local cOrdem   := Posicione( 'SX3', 1, cAliasTbl, 'X3_ORDEM' )

    Do While !Empty( Posicione( 'SX3', 1, cAliasTbl + cOrdem, 'X3_ORDEM' ) )

	    If Posicione( 'SX3', 1, cAliasTbl + cOrdem, 'X3_CONTEXT' ) == 'V'

            aAdd( aVirtual, Posicione( 'SX3', 1, cAliasTbl + cOrdem, 'X3_CAMPO' ) )

        EndIf

        cOrdem := Soma1Old( cOrdem )

    EndDo

    For n := 1 To Len(aVirtual)
        aAdd(aFields, {aVirtual[n],;
                       Posicione("SX3",2,aVirtual[n],"X3_TIPO"),;
                       Posicione("SX3",2,aVirtual[n],"X3_TAMANHO"),;
                       Posicione("SX3",2,aVirtual[n],"X3_DECIMAL")})
    Next n

    RestArea(aArea)

Return
