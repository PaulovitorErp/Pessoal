#INCLUDE "MNTW035.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "fileio.ch"

Static cProgram := 'MNTW035'

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW035
Programa para enviar workflow para o solicitante da SS
Este e enviado no encerramento da SS

@type function

@source MNTW035.prw

@author Ricardo Dal Ponte
@since 11/12/2006

@sample MNTW035()

@return Lógico
/*/
//---------------------------------------------------------------------
Function MNTW035(nRecTQB)

	MNTW035F(nRecTQB, cEmpAnt, cFilAnt, .F.)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW035F
Envio do Workflow

@type function

@source MNTW035.prw

@author Ricardo Dal Ponte
@since 24/11/2006
@param nRecTQB, numerico, reclock do registro na TQB
@param cEmpAtu, caractere, empresa
@param cFilAtu, caractere, filial
@param lJob, logica, indica se está sendo executado com startjob

@sample MNTW035F()

@return Lógico
/*/
//---------------------------------------------------------------------
Function MNTW035F(nRecTQB, cEmpAtu, cFilAtu, lJob)

	Local oProcess
	Local nQtdWF		:= 1
	Local nWF			:= 1
	Local nX			:= 0
	Local nTot			:= 0
	Local cEmail		:= ""
	Local cCodss		:= ""
	Local cNomeUsu		:= ""
	Local cMailTSK		:= ""
	Local cCodUsr		:= ""
	Local aRegistros	:= {}
	Local aQuestionario	:= {}
	Local lAdd			:= .F.
	Local lTUQ			:= .F.
	Local lMNTW0352		:= ExistBlock("MNTW0352")
	Local lMNTW0353 	:= ExistBlock("MNTW0353")

	/* Variaveis do Link */
	Local cArquivo		:= ""
	Local cArqHTML		:= "MNTW035_02.htm"
	Local cDir			:= ""
	Local cHTTP			:= ""
	Local cPasta		:= "ss"
	Local cCodProcesso	:= "WFF035"
	Local cHTTPDir		:= ""
	Local cHTTPSS		:= ""
	Local cBARRAS		:= IIf(isSRVunix(),"/","\")
	Local cHTTPSS1		:= ""
	Local cHtmlModelo	:= ""
	Local cArqModelo	:= ""
	Local cHtmlBkp		:= ""
	Local cDirArq		:= ""
	Local cRootPath		:= ""
	Local cRetMail      := ""

	Private cMemoObr	:= ""

	Default lJob := .T.

	If lJob

		RPCSetType(3) //Nao utiliza licença
		RPCSetEnv(cEmpAtu,cFilAtu,"","","MNT")

	EndIf

	cCodUsr 	:= RetCodUsr()
	lTUQ		:= SuperGetMv("MV_NG1FAC",.F.,"2") == '1' //Facilities
	cArquivo	:= IIf(lTUQ, "MNTW035_03.htm", "MNTW035_01.htm")
	cDir		:= AllTrim(SuperGetMv("MV_WFDIR",.F.))
	cHTTP		:= AllTrim(SuperGetMv("MV_NGWFHT",.F.,"http://127.0.0.1:8080"))
	cHTTPDir	:= AllTrim(SuperGetMv("MV_WFDHTTP",.F.,""))
	cHTTPSS		:= cHTTPDir+"\messenger\emp"+cEmpAtu+"\"+cPasta
	cRootPath	:= AllTrim(GetSrvProfString("RootPath",cBARRAS))
	lPesq		:= AllTrim(GetNewPar("MV_NGPSATI","N")) == "S" //Pesquisa de Satisfação

	//Coloco a barra no final do parametro do diretorio
	If Substr(cDir,Len(cDir),1) != cBARRAS
		cDir += cBARRAS
	EndIf
	//Coloco a barra no final do parametro do diretorio
	If Substr(cRootPath,Len(cRootPath),1) != cBARRAS
		cRootPath += cBARRAS
	EndIf

	// Arquivo html template utilizado para montagem da aprovação
	cHtmlModelo := cDir+cArquivo

	//Verifica se existe o arquivo de workflow
	If !File(cHtmlModelo)
		Return .F.
	EndIf

	//Posiciona na TQB para verificar campo vazio TQB->TQB_CDCANC
	dbSelectArea("TQB")
	dbSetOrder(1)
	dbGoTo(nRecTQB)
	If Empty(AllTrim(TQB->TQB_CDCANC)) //Se utiliza pesquisa de satisfação das solicitações de serviços e se não é cancelamento;
		nQtdWF++
	EndIf

	For nWF := 1 To nQtdWF
		dbSelectArea("TQB")
		dbSetOrder(1)
		dbGoTo(nRecTQB)
		If !Empty(TQB->TQB_SOLICI)
			cCodSS := TQB->TQB_SOLICI

			cMailTSK := NgEmailWF( "1", cProgram )

			cRetMail := UsrRetMail(TQB->TQB_CDSOLI)

			If cRetMail $ cMailTSK
				cEmail := cMailTSK
			ElseIf cMailTSK $ cRetMail
				cEmail := cRetMail
			Else
				cEmail := cRetMail + ";" + cMailTSK
			EndIf

			cNomeUsu := PadR(UsrRetName(TQB->TQB_CDSOLI),40)

			If !lTUQ .And. Empty(AllTrim(TQB->TQB_CDCANC))
				aAdd(aRegistros,{	STR0012,; //"Numero SS"
									STR0013,; //"Dt Abertura"
									STR0014,; //"Servico"
									STR0015,; //"Solicitante"
									STR0016+":",; //"Solicitação"
									STR0017,; //"Dt Fechto"
									STR0018,; //"Hr Fechto"
									STR0019,; //"Duração"
									IIf( TQB->TQB_TIPOSS == "B", STR0022 , STR0023),;//"Bem"##"Localização"
									STR0020+":",; //"Solução"
									TQB->TQB_SOLICI,;
									TQB->TQB_DTABER,;
									NGSEEK("TQ3",TQB->TQB_CDSERV,1,"TQ3->TQ3_NMSERV"),;
									cNomeUsu,;
									MSMM(TQB->TQB_CODMSS,80),;
									TQB->TQB_DTFECH,;
									TQB->TQB_HOFECH,;
									TQB->TQB_TEMPO,;
									TQB->TQB_CODBEM,;
									MSMM(TQB->TQB_CODMSO,80)})
			ElseIf lTUQ .And. Empty(AllTrim(TQB->TQB_CDCANC))
				aAdd(aRegistros,{	RetTitle("TQB_SOLICI"),;
									RetTitle("TQB_DTABER"),;
									RetTitle("TQB_HOABER"),;
									RetTitle("TQB_CDSERV"),;
									RetTitle("TQB_CDSOLI"),;
									RetTitle("TQB_CODBEM"),;
									RetTitle("TQB_DTFECH"),;
									RetTitle("TQB_HOFECH"),;
									RetTitle("TQB_DESCSS"),;
									RetTitle("TQB_DESCSO"),;
									TQB->TQB_SOLICI,;
									TQB->TQB_DTABER,;
									TQB->TQB_HOABER,;
									NGSEEK("TQ3",TQB->TQB_CDSERV,1,"TQ3->TQ3_NMSERV"),;
									cNomeUsu,;
									TQB->TQB_CODBEM,;
									TQB->TQB_DTFECH,;
									TQB->TQB_HOFECH,;
									MSMM(TQB->TQB_CODMSS,80),;
									MSMM(TQB->TQB_CODMSO,80)})

				MNT307RES("","","",@aQuestionario,.T.,TQB->TQB_SEQQUE,.T.)

				cStrHtml	:= ""
				cStrHTML1	:= ""
				cGrupo		:= ""
				cHtmlBkp	:= "MNTW035_03_"+Trim(TQB->TQB_FILIAL)+TQB->TQB_SOLICI+".htm"
				cDirArq		:= StrTran(cDir+"emp"+cEmpAtu+cBarras+cPasta+cBarras,cBarras+cBarras,cBarras)
				cArqModelo	:= cDirArq+cHtmlBkp

				If !ExistDir(cDirArq)
					FWMakeDir(cDirArq)
				EndIf

				//__CopyFile(<endereco arquivo>,<endereco destino>)
				__copyfile( cHtmlModelo        ,cArqModelo)

				cHtmlModelo := StrTran(cArqModelo,cRootPath,"")
				cHtmlModelo := IIf(Substr(cHtmlModelo,1,1) != cBarras, cBarras+cHtmlModelo, cHtmlModelo)

				If nWF > 1
					If File(cArqModelo)
						nHdlArq := FOPEN(cArqModelo,0)
						FT_FUSE(cArqModelo)
						FT_FGOTOP()
						While (!FT_FEof())
							cStrHTML += FT_FREADLN()+CRLF
							FT_FSKIP()
						EndDo
						FT_FUSE()
						cStrHTML += '<div style="padding-top: 15px;">'+CRLF
						cStrHTML += '<table border="1" style="width:800px; background-color:#EEEEEE; border-color: white;">'
						cStrHTML += '	<tr>'
						cStrHTML += '		<td class="tdTitGrupo">'
						cStrHTML += '			PESQUISA DE SATISFA&Ccedil;&Atilde;O/QUALIDADE'
						cStrHTML += '		</td>'
						cStrHTML += '	</tr>'
						If Len(aQuestionario) > 0
							For nX := 1 To Len(aQuestionario)

								If cGrupo <> aQuestionario[nX,3]
									cGrupo := aQuestionario[nX,3]
									cStrHTML += '	<tr>'+CRLF
									cStrHTML += '		<td class="tdTitGrupo">'+CRLF
									cStrHTML += NGSEEK("TUN",aQuestionario[nX,3],1,"TUN_DESCRI")+CRLF
									cStrHTML += '		</td>'+CRLF
									cStrHTML += '	</tr>'+CRLF
								EndIf

								cStrHTML += '	<tr> '+CRLF
								cStrHTML += '		<td class="tdPergunta">  '+CRLF
								cStrHTML += aQuestionario[nX,2]+CRLF
								cStrHTML += "		</td> "+CRLF
								cStrHTML += "	</tr> "+CRLF
								cStrHTML += "	<tr>  "+CRLF
								cStrHTML += '		<td class="tdResposta">'+CRLF
								If aQuestionario[nX,6]
									nTot++
									lAdd := fAddLis(aQuestionario[nX,4],@cStrHTML,.T.,nTot)
								Else
									nTot++
									lAdd := fAddLis(aQuestionario[nX,4],@cStrHTML,.F.,nTot)
								EndIf
								If aQuestionario[nX,7]
									nTot++
									fAddMemo(aQuestionario[nX,10],@cStrHTML,nTot, lAdd)
								EndIf
								cStrHTML += "		</td> "+CRLF
								cStrHTML += "	</tr> "+CRLF
							Next nX
						EndIf
						cStrHTML += "	<tr>"+CRLF
						cStrHTML += '		<td style="height:28px; background-color:#CCCCCC;">'+CRLF
						cStrHTML += '			<input type="submit" name="Submit" value="Enviar">'+CRLF
						cStrHTML += "		</td>"+CRLF
						cStrHTML += "	</tr>"+CRLF
						cStrHTML += "</table>"+CRLF
						cStrHTML += "</div>"+CRLF
						/*As 3 Tags abaixo nao sao fechadas, pois o protheus gera javascript sozinho se o form estiver fechado
						cStrHTML += "</form>"+CRLF
						cStrHTML += "</body>"+CRLF
						cStrHTML += "</html>"+CRLF*/
						FT_FUSE(cArqModelo)
						FWRITE(nHdlArq, cStrHTML)
						FT_FUSE()
						FCLOSE(nHdlArq)

						nRetFERASE	:= FERASE(cArqModelo)	// Apaga o arquivo
						nHandle		:= FCREATE(cArqModelo)	// Cria o arquivo

						FT_FUSE(cArqModelo)
						FWrite(nHandle, cStrHTML)		// Insere texto no arquivo
						FT_FUSE()
						FClose(nHandle)					// Fecha arquivo
					Else
						aRegistros := {}
					EndIf
				EndIf
			//Quando é cancelamento de SS sem Facilities
			ElseIf !lTUQ .And. !Empty(AllTrim(TQB->TQB_CDCANC))
				aAdd(aRegistros,{	STR0012,; //"Numero SS"
									STR0013,; //"Dt Abertura"
									STR0014,; //"Servico"
									STR0015,; //"Solicitante"
									STR0016+":",; //"Solicitação"
									STR0056,; //"Dt Canc."
									STR0057,; //"Hr Canc."
									STR0019,; //"Duração"
									IIf( TQB->TQB_TIPOSS == "B", STR0022 , STR0023),;//"Bem"##"Localização"
									STR0059+":",; //"Motivo Canc."
									TQB->TQB_SOLICI,;
									TQB->TQB_DTABER,;
									NGSEEK("TQ3",TQB->TQB_CDSERV,1,"TQ3->TQ3_NMSERV"),;
									cNomeUsu,;
									MSMM(TQB->TQB_CODMSS,80),;
									TQB->TQB_DTCANC,;
									TQB->TQB_HRCANC,;
									TQB->TQB_TEMPO,;
									TQB->TQB_CODBEM,;
									MSMM(TQB->TQB_CDCANC,80)})
			//Quando é cancelamento de SS com Facilities
			ElseIf lTUQ .And. !Empty(AllTrim(TQB->TQB_CDCANC))
				aAdd(aRegistros,{	RetTitle("TQB_SOLICI"),;
									RetTitle("TQB_DTABER"),;
									RetTitle("TQB_HOABER"),;
									RetTitle("TQB_CDSERV"),;
									RetTitle("TQB_CDSOLI"),;
									RetTitle("TQB_CODBEM"),;
									RetTitle("TQB_DTCANC"),;
									RetTitle("TQB_HRCANC"),;
									RetTitle("TQB_DESCSS"),;
									RetTitle("TQB_CDCANC"),;
									TQB->TQB_SOLICI,;
									TQB->TQB_DTABER,;
									TQB->TQB_HOABER,;
									NGSEEK("TQ3",TQB->TQB_CDSERV,1,"TQ3->TQ3_NMSERV"),;
									cNomeUsu,;
									TQB->TQB_CODBEM,;
									TQB->TQB_DTCANC,;
									TQB->TQB_HRCANC,;
									MSMM(TQB->TQB_CODMSS,80),;
									MSMM(TQB->TQB_CDCANC,80)})

			EndIf
		EndIf

		//Ponto de entrada para inclusão de novos campos no Workflow de fechamaneto de S.S.
		If lMNTW0352
			aRegistros	:= ExecBlock( "MNTW0352", .F., .F., {aRegistros}  )
		EndIf

		If Len(aRegistros) == 0 .Or. Empty(cEmail)
			Return .T.
		EndIf

		// Inicialize a classe TWFProcess e assinale a variável objeto oProcess:
		oProcess := TWFProcess():New(cCodProcesso, IIf(Empty(AllTrim(TQB->TQB_CDCANC)),STR0024,STR0058))//"Encerramento de Solicitação de Serviço"
		NGWFLog( STR0025 + " - " + oProcess:fProcessID, .T., , cProgram ) //"Processo Iniciado"

		// Crie uma tarefa.
		oProcess:NewTask("Executando WF035", cHtmlModelo)
		NGWFLog( STR0026 + " - " + oProcess:fTaskID, , , cProgram ) //"Tarefa Iniciada"

		// Repasse o texto do assunto criado para a propriedade especifica do processo.
		oProcess:cSubject := DTOC(dDataBase)+" - "+ IIf(Empty(AllTrim(TQB->TQB_CDCANC)),STR0010,STR0058) +" - "+STR0011+" "+cCodSS //"Encerramento de Solicitação de Serviço"###"SS"

		// Informe o endereço eletrônico do destinatário. cPasta grava o arquivo htm e cEmail para enviar o workflow
		If nWF == 1
			oProcess:cTo := cPasta + ";" + cEmail
		Else
			oProcess:cTo := cPasta
		EndIf

		// Obtem o código do usuario protheus.
		oProcess:UserSiga := RetCodUsr()

		If nWF > 1
			// Informe o nome da função de retorno a ser executada quando a mensagem de
			// respostas retornarem ao Workflow:
			oProcess:bReturn := "U_W035RESP(1)"

			// Informe o nome da função do tipo timeout que será executada se houver um timeout
			// ocorrido para esse processo. Neste exemplo, será executada 5 minutos após o envio
			// do e-mail para o destinatário. Caso queira-se aumentar ou diminuir o tempo, altere
			// os valores das variáveis: nDias, nHoras e nMinutos.
			oProcess:bTimeOut := {{"U_W035RESP(2)", 0, 0, 10}}
		EndIf

		If !lTUQ
			aAdd(oProcess:oHtml:ValByName("it1.strSOLICI") , aRegistros[1,1])
			aAdd(oProcess:oHtml:ValByName("it1.strDTABER") , aRegistros[1,2])
			aAdd(oProcess:oHtml:ValByName("it1.strNMSERV") , aRegistros[1,3])
			aAdd(oProcess:oHtml:ValByName("it1.strNMSOLI") , aRegistros[1,4])

			aAdd(oProcess:oHtml:ValByName("it3.strDESMSS") , aRegistros[1,5])

			aAdd(oProcess:oHtml:ValByName("it1.strDTFECH") , aRegistros[1,6])
			aAdd(oProcess:oHtml:ValByName("it1.strHOFECH") , aRegistros[1,7])
			aAdd(oProcess:oHtml:ValByName("it1.strTEMPO")  , aRegistros[1,8])
			aAdd(oProcess:oHtml:ValByName("it1.strCODBEM") , aRegistros[1,9])

			aAdd(oProcess:oHtml:ValByName("it5.strDESCSO") , aRegistros[1,10])

			aAdd(oProcess:oHtml:ValByName("it2.strSOLICI") , aRegistros[1,11])
			aAdd(oProcess:oHtml:ValByName("it2.strDTABER") , aRegistros[1,12])
			aAdd(oProcess:oHtml:ValByName("it2.strNMSERV") , aRegistros[1,13])
			aAdd(oProcess:oHtml:ValByName("it2.strNMSOLI") , aRegistros[1,14])

			aAdd(oProcess:oHtml:ValByName("it4.strDESMSS") , aRegistros[1,15])

			aAdd(oProcess:oHtml:ValByName("it2.strDTFECH") , aRegistros[1,16])
			aAdd(oProcess:oHtml:ValByName("it2.strHOFECH") , aRegistros[1,17])
			aAdd(oProcess:oHtml:ValByName("it2.strTEMPO")  , aRegistros[1,18])
			aAdd(oProcess:oHtml:ValByName("it2.strCODBEM") , aRegistros[1,19])

			aAdd(oProcess:oHtml:ValByName("it6.strDESCSO") , aRegistros[1,20])

		Else
			aAdd(oProcess:oHtml:ValByName("it1.strSOLICI") , aRegistros[1,1])
			aAdd(oProcess:oHtml:ValByName("it1.strDTABER") , aRegistros[1,2])
			aAdd(oProcess:oHtml:ValByName("it1.strHOABER") , aRegistros[1,3])
			aAdd(oProcess:oHtml:ValByName("it1.strNMSERV") , aRegistros[1,4])
			aAdd(oProcess:oHtml:ValByName("it1.strNMSOLI") , aRegistros[1,5])
			aAdd(oProcess:oHtml:ValByName("it1.strCODBEM") , aRegistros[1,6])
			aAdd(oProcess:oHtml:ValByName("it1.strDTFECH") , aRegistros[1,7])
			aAdd(oProcess:oHtml:ValByName("it1.strHOFECH") , aRegistros[1,8])
			aAdd(oProcess:oHtml:ValByName("it3.strDESMSS") , aRegistros[1,9])
			aAdd(oProcess:oHtml:ValByName("it5.strDESCSO") , aRegistros[1,10])

			aAdd(oProcess:oHtml:ValByName("it2.strSOLICI") , aRegistros[1,11])
			aAdd(oProcess:oHtml:ValByName("it2.strDTABER") , aRegistros[1,12])
			aAdd(oProcess:oHtml:ValByName("it2.strHOABER") , aRegistros[1,13])
			aAdd(oProcess:oHtml:ValByName("it2.strNMSERV") , aRegistros[1,14])
			aAdd(oProcess:oHtml:ValByName("it2.strNMSOLI") , aRegistros[1,15])
			aAdd(oProcess:oHtml:ValByName("it2.strCODBEM") , aRegistros[1,16])
			aAdd(oProcess:oHtml:ValByName("it2.strDTFECH") , aRegistros[1,17])
			aAdd(oProcess:oHtml:ValByName("it2.strHOFECH") , aRegistros[1,18])

			aAdd(oProcess:oHtml:ValByName("it4.strDESMSS") , aRegistros[1,19])
			aAdd(oProcess:oHtml:ValByName("it6.strDESCSO") , aRegistros[1,20])

			oProcess:oHtml:ValByName("strMemoObr", cMemoObr)
		EndIf

		//Ponto de entrada para inclusão de novos campos no Workflow de fechamaneto de S.S.
		If lMNTW0353
			oProcess := ExecBlock( "MNTW0353", .F., .F. , {oProcess,aRegistros} )
		EndIf

		If !ExistDir(cHTTPSS)
			FWMakeDir(cHTTPSS)
		EndIf

		If nWF == 1
			// Verificar se é possível utilizar StartJob para todo processo posterior a isso
			cMailID := oProcess:Start()
			NGWFLog( STR0029 + " - " + oProcess:fProcessID + " | " + "ID" + " - " + cMailID + " | " + STR0030 + ": " + cHTTPSS, , , cProgram ) //"Processo Enviado"###"Destino"
			NGWFLog( STR0031 + oProcess:cSubject, , , cProgram ) // "Descrição: "

		Else
			If lPesq
				cMailID := oProcess:Start()
				NGWFLog( STR0029 + " - " + oProcess:fProcessID + " | " + "ID" + " - " + cMailID + " | " + STR0030 + ": " + cHTTPSS, , , cProgram ) //"Processo Enviado"###"Destino"
				NGWFLog( STR0031 + oProcess:cSubject, , , cProgram ) // "Descrição: "

				oProcess:cTo := cPasta + ";" + cEmail

				/* Envia o link */
				If SubStr(cHTTP,Len(cHTTP),1) <> "/"
					If SubStr(cHTTP,1,1) == '"'
						cHTTP := SubStr(cHTTP,2,Len(cHTTP)-2) + "/"
					Else
						cHTTP += "/"
					EndIf
				EndIf

				//Substitui "\" por "/" para utilizar no link de pesquisa e satisfação.
				cHTTPSS1  := StrTran(cHTTPSS,"\","/")

				oProcess:NewTask("Viabilizando Link",cDir+cArqHTML)
				NGWFLog( STR0026 + " - " + oProcess:fTaskID, , , cProgram ) //"Tarefa Iniciada"

				oProcess:cSubject := STR0033 //"Pesquisa de Satisfação de S.S."

				// Informe o endereço eletrônico do destinatário. cPasta grava o arquivo htm e cEmail para enviar o workflow
				oProcess:cTo := cEmail

				oProcess:UserSiga := "000000"

				oHTML := oProcess:oHTML

				oHTML:ValByName("usuario", cNomeUsu)
				oHTML:ValByName("ss", cCodSS)
				oHTML:ValByName("ss_link", cHTTP + cHTTPSS1 +"/"+cMailID+".htm")
				oHTML:ValByName("desc_link", "Empresa: " + cEmpAtu + " / "+"Filial: " + cFilAtu) //"Empresa: "###"Filial: "
				oHTML:ValByName("ss_texto", cHTTP + cHTTPSS1 + "/" + cMailID+".htm")
				oHTML:ValByName("saudacoes", Padr(UsrRetName(cCodUsr),40))

				cLinkID := oProcess:Start()
				NGWFLog( STR0034 + " - " + oProcess:fProcessID + " | " + "ID" + " - " + cLinkID + " | " + STR0030 + ": " + oProcess:cTo, , , cProgram ) // "Processo Enviado"###"Destino: "
				NGWFLog( STR0031 + oProcess:cSubject, , .T., cProgram )
			EndIf
		EndIf
	Next nWF

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} W035RESP
Grava Retorno do Workflow

@type function

@source MNTW035.prw

@author Ricardo Dal Ponte
@since 02/01/2007

@sample W035RESP()

@return Lógico
/*/
//---------------------------------------------------------------------
User Function W035RESP(nOpc, oProcess)

	Local nX		:= 0
	Local nY		:= 0
	Local nZZ		:= 0
	Local nTot		:= 0
	Local nPos		:= 0
	Local nCont		:= 0
	Local nRet		:= 1
	Local c_PSAP	:= ""
	Local c_PSAN	:= ""
	Local cCodSS	:= ""
	Local c_Obs1	:= ""
	Local c_Obs2	:= ""
	Local a_CPOS 	:= {}
	Local a_CNTD	:= {}
	Local aQuest	:= {}
	Local aTUQs		:= {}
	Local aQuestionario := {}
	Local lTUQ		:= SuperGetMv("MV_NG1FAC",.F.,"2") == '1' //Facilities
	Local lRPORel17 := IIf(GetRPORelease() <= '12.1.017', .T., .F.)
	Local oTQB

	NGWFLog( STR0031 + oProcess:cSubject, .T., , cProgram ) //"Descrição: "
	NGWFLog( STR0035 + " - " + oProcess:fProcessID, , , cProgram ) //"Processo Reinicializado para Retorno"
	NGWFLog( STR0036 + " - " + oProcess:fTaskID, , , cProgram ) //"Tarefa Reinicializada para Retorno"

	If nOpc == 2
		NGWFLog( STR0040 + " - " + oProcess:fProcessID, ,.T. , cProgram ) //"Processo Finalizado por Timeout"
		oProcess:Finish()
		Return .T.
	EndIf

	cCodSS := Substr(oProcess:oHtml:RetByName('it2.strSOLICI')[1],1,6)

	dbSelectarea("TQB")
	dbSetorder(1)

	If dbSeek(xFilial("TQB")+cCodSS)
		If lTUQ
			aArea := GetArea()
			dbSelectArea("TUQ")
			dbSetOrder(1)
			If dbSeek( xFilial("TUQ")+TQB->TQB_SEQQUE )
				aAdd(aQuest,TUQ->TUQ_TIPO)
				aAdd(aQuest,TUQ->TUQ_QUESTI)
				aAdd(aQuest,TUQ->TUQ_LOJA)
			EndIf

			RestArea(aArea)
			MNT307RES("","","",@aQuestionario,.T.,TQB->TQB_SEQQUE,.T.)
			Begin Transaction
				For nX := 1 To Len(aQuestionario)
					aRespost := {}
					If aQuestionario[nX,6] //Radio
						If !Empty(oProcess:oHtml:RetByName("OPCAO"+cValToChar(nRet)+"RAD")) .and.;
								(nPos := aScan(aQuestionario[nX,4],{|x| Substr(x,1,1) == Substr(oProcess:oHtml:RetByName("OPCAO"+cValToChar(nRet)+"RAD"),1,1)})) > 0
							aAdd( aRespost , Trim(aQuestionario[nX,4,nPos]))
						EndIf
					Else
						For nY := 1 To Len(aQuestionario[nX,4]) //Check
							If !Empty(oProcess:oHtml:RetByName("OPCAO"+cValToChar(nRet)+"CHK"+SubStr(aQuestionario[nX,4,nY],1,1))) .and.;
									oProcess:oHtml:RetByName("OPCAO"+cValToChar(nRet)+"CHK"+SubStr(aQuestionario[nX,4,nY],1,1)) == ".T."
								aAdd( aRespost , Trim(aQuestionario[nX,4,nY]))
							EndIf
						Next nY
					EndIf
					If aQuestionario[nX,7] //Adiciona campo memo para gravação
						nRet++
						If !Empty(oProcess:oHtml:RetByName("MEMO"+cValToChar(nRet)))
							aQuestionario[nX,10] := oProcess:oHtml:RetByName("MEMO"+cValToChar(nRet))
							aAdd( aRespost , "#" )
						EndIf
					EndIf
					For nZZ := 1 To Len(aRespost)
						dbSelectArea("TUQ")
						dbSetOrder(1)
						If dbSeek( xFilial("TUQ")+TQB->TQB_SEQQUE+aQuest[1]+aQuest[2]+aQuest[3]+aQuestionario[nX,1] ) .And. aRespost[nZZ] != "#"
							RecLock("TUQ",.F.)
							TUQ->TUQ_RESPOS := aRespost[nZZ]
							TUQ->TUQ_VALOR  := A307RETVAL(aQuest[1]+aQuest[2]+aQuest[3]+aQuestionario[nX,1],aRespost[nZZ])
						Else
							RecLock("TUQ",.T.)
							TUQ->TUQ_FILIAL := xFilial("TUQ")
							TUQ->TUQ_SEQUEN := TQB->TQB_SEQQUE
							TUQ->TUQ_TIPO   := aQuest[1]
							TUQ->TUQ_QUESTI := aQuest[2]
							TUQ->TUQ_LOJA   := aQuest[3]
							TUQ->TUQ_QUESTA := aQuestionario[nX,1]
							TUQ->TUQ_RESPOS := aRespost[nZZ]
							TUQ->TUQ_VALOR  := A307RETVAL(aQuest[1]+aQuest[2]+aQuest[3]+aQuestionario[nX,1],aRespost[nZZ])
							TUQ->TUQ_PERGUN := SubStr(aQuestionario[nX,2],2)
							TUQ->TUQ_ORDEM  := aQuestionario[nX,9]
							TUQ->TUQ_CODGRU := aQuestionario[nX,3]
							TUQ->TUQ_TPLIST := IIf(aQuestionario[nX,6],"1","2")
							TUQ->TUQ_ONMEMO := IIf(aQuestionario[nX,7],"1","2")
							TUQ->TUQ_PERGUT := SubStr(aQuestionario[nX,5],1,250)
							TUQ->TUQ_2PERGU := SubStr(aQuestionario[nX,5],251)
						EndIf
						TUQ->(MsUnLock())
						If aRespost[nZZ] == "#"
							MSMM(,,,aQuestionario[nX,10],1,,,"TUQ","TUQ_CODCOM")
						EndIf
						aAdd(aTUQs , TUQ->(Recno()) )
					Next nZZ
					nRet++
				Next nX

				dbSelectArea("TQB")
				dbSetOrder(1)
				dbSeek(xFilial("TQB")+cCodSS)
				RecLock("TQB",.F.)
				TQB->TQB_SATISF := "1"
				MsUnlock("TQB")

				dbSelectArea("TUQ")
				dbSetOrder(1)
				If dbSeek( xFilial("TUQ") + TQB->TQB_SEQQUE )
					While !EoF() .and. xFilial("TUQ") == TUQ->TUQ_FILIAL .and. TQB->TQB_SEQQUE == TUQ->TUQ_SEQUEN

						If TUQ->TUQ_QUESTA == Replicate("#",Len(TUQ->TUQ_QUESTA)) .Or. TUQ->TUQ_QUESTA == Replicate("@",Len(TUQ->TUQ_QUESTA))
							dbSelectArea("TUQ")
							dbSkip()
							Loop
						EndIf
						If aScan(aTUQs, {|x| x == TUQ->(Recno()) }) == 0
							dbSelectArea("TUQ")
							RecLock("TUQ",.F.)
							dbDelete()
							TUQ->(MsUnLock())
						EndIf
						dbSelectArea("TUQ")
						dbSkip()
					End
				EndIf
			End Transaction
		Else

			If !lRPORel17
				// Instância a classe de geração de S.S.
				oTQB := MntSR():New()

				// Determina que a operação selecionada será alteração.
				oTQB:setOperation(4)

				// Não será apresentando as mensagens.
				oTQB:setAsk(.F.)

				// Posiciona no registro utilizado.
				oTQB:Load({xFilial("TQB") + cCodSS})

				c_PSAP := oProcess:oHtml:RetByName("WFPSAP")
				c_PSAN := oProcess:oHtml:RetByName("WFPSAN")
				c_Obs1 := oProcess:oHtml:RetByName("WFOBSPRA")
				c_Obs2 := oProcess:oHtml:RetByName("WFOBSATE")

				If ExistBlock("MNTW0351")
					a_CPOS :=  ACLONE(ExecBlock("MNTW0351",.F.,.F.))
				EndIf

				If Len(a_CPOS) > 0
					a_CNTD := Array(Len(a_CPOS))
					For nCont := 1 To Len(a_CPOS)
						a_CNTD[nCont] := oProcess:oHtml:RetByName(a_CPOS[nCont][1])
					Next
				EndIf

				If Len(a_CPOS) > 0
					For nCont := 1 To Len(a_CPOS)
						oTQB:setValue(a_CPOS[nCont][2], SubStr(a_CNTD[nCont], 1,1))
					Next
				EndIf

				// Define os valores necessários para permitir o Resposta da Satisfação da S.S.
				oTQB:setValue("TQB_PSAP", Substr(c_PSAP, 1,1))
				oTQB:setValue("TQB_PSAN", Substr(c_PSAN, 1,1))

				If NGCADICBASE("TQB_OBSPRA","A","TQB",.F.) .And. !Empty(c_Obs1)
					oTQB:setValue("TQB_OBSPRA", c_Obs1)
				ElseIf !Empty(c_Obs1)
					NGWFLog(STR0044+" '"+STR0045+"'. "+STR0046) //"Erro ao receber a Observacao"###"Prazo"###"Campo nao existe no dicionario/base"
				EndIf

				If NGCADICBASE("TQB_OBSATE","A","TQB",.F.) .And. !Empty(c_Obs2)
					oTQB:setValue("TQB_OBSATE", c_Obs2)
				ElseIf !Empty(c_Obs2)
					NGWFLog(STR0044+" '"+STR0047+"'. "+STR0046) //"Erro ao receber a Observacao"###"Necessidade"###"Campo nao existe no dicionario/base"
				EndIf

				// Verifica se o registro é válido para o fechamento.
				If oTQB:valid()
					// Realiza o fechamento da solicitação.
					oTQB:upsert()
				EndIf
				// Fecha o objeto.
				oTQB:Free()
			Else

				RecLock("TQB",.F.)
				c_PSAP := oProcess:oHtml:RetByName("WFPSAP")
				c_PSAN := oProcess:oHtml:RetByName("WFPSAN")
				c_Obs1 := oProcess:oHtml:RetByName("WFOBSPRA")
				c_Obs2 := oProcess:oHtml:RetByName("WFOBSATE")

				If ExistBlock("MNTW0351")
					a_CPOS :=  ACLONE(ExecBlock("MNTW0351",.F.,.F.))
				EndIf
				If Len(a_CPOS) > 0
					a_CNTD := Array(Len(a_CPOS))
					For nCont := 1 To Len(a_CPOS)
						a_CNTD[nCont] := oProcess:oHtml:RetByName(a_CPOS[nCont][1])
					Next
				EndIf

				If Len(a_CPOS) > 0
					For nCont := 1 To Len(a_CPOS)
						TQB->&(a_CPOS[nCont][2]) := SubStr(a_CNTD[nCont], 1,1)
					Next
				EndIf

				If !Empty(c_PSAP)
					TQB->TQB_PSAP := Substr(c_PSAP, 1,1)
				EndIf

				If !Empty(c_PSAN)
					TQB->TQB_PSAN := Substr(c_PSAN, 1,1)
				EndIf

				If NGCADICBASE("TQB_OBSPRA","A","TQB",.F.) .And. !Empty(c_Obs1)
					TQB->TQB_OBSPRA := c_Obs1
				ElseIf !Empty(c_Obs1)
					NGWFLog( STR0044 + " '" + STR0045 + "'. " + STR0046, , , cProgram ) //"Erro ao receber a Observacao"###"Prazo"###"Campo nao existe no dicionario/base"
				EndIf

				If NGCADICBASE("TQB_OBSATE","A","TQB",.F.) .And. !Empty(c_Obs2)
					TQB->TQB_OBSATE := c_Obs2
				ElseIf !Empty(c_Obs2)
					NGWFLog( STR0044 + " '" + STR0047 + "'. " + STR0046, , , cProgram ) //"Erro ao receber a Observacao"###"Necessidade"###"Campo nao existe no dicionario/base"
				EndIf

				MsUnlock("TQB")
			EndIf
		EndIf
	EndIf
	NGWFLog( STR0043 + " - " + oProcess:fProcessID, , .T., cProgram ) //"Processo Finalizado com Sucesso"
	oProcess:Finish()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fAddLis
Adiciona campo radio ou check

@type function

@source MNTW035.prw

@author Jackson Machado
@since 24/02/2012

@sample fAddLis()

@return Lógico
/*/
//---------------------------------------------------------------------
Static Function fAddLis(aArray,cHTML,lRad,nTot)

	Local nX := 0
	Local cTipo := "radio"
	Local cOpcao:= ""
	Local lAdd  := .F.

	Default lRad := .T.

	If !lRad
		cTipo := "checkbox"
	EndIf

	For nX := 1 To Len(aArray)
		lAdd  := .T.
		If lRad
			cOpcao := cValToChar(nTot)+"RAD"
			cHTML += "<INPUT TYPE='"+cTipo+"' NAME='%OPCAO"+cOpcao+"%' ID='OPCAO"+cOpcao+"' VALUE='"+Substr(aArray[nX],1,1)+"'> "+SubStr(aArray[nX],3)+CRLF
		Else
			cOpcao := cValToChar(nTot)+"CHK"+Substr(aArray[nX],1,1)
			cHTML += "<INPUT TYPE='"+cTipo+"' NAME='OPCAO"+cOpcao+"' ID='OPCAO"+cOpcao+"' VALUE='%OPCAO"+cOpcao+"%'> "+SubStr(aArray[nX],3)+CRLF
		EndIf
	Next nX

Return lAdd

//---------------------------------------------------------------------
/*/{Protheus.doc} fAddMemo
Adiciona campo memo

@type function

@source MNTW035.prw

@author Jackson Machado
@since 24/04/2012

@sample fAddMemo()

@return
/*/
//---------------------------------------------------------------------
Static Function fAddMemo(aArray,cHTML,nTot,lAdd)

	cHTML += '<p style="padding-left: 3px; padding-bottom: 5px;">'
	cHTML += "<textarea name='MEMO"+cValToChar(nTot)+"' ID='MEMO"+cValToChar(nTot)+"' rows='4' cols='94'>%MEMO"+cValToChar(nTot)+"%</textarea><br>"+CRLF
	cHTML += "</p>"

	If !lAdd
		cMemoObr += "MEMO"+cValToChar(nTot)+";"
	EndIf

Return
