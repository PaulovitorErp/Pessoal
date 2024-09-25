#INCLUDE "mntw030.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW030
Programa para enviar workflow de resumo de SS para o
executante da SS

@type function

@source MNTW030.prw

@author Ricardo Dal Ponte
@since 11/12/2006

	Nota: Atualizado para utilização da função de envio de workflow
	NGSendMail() pois o antigo processo TMailMessage() estava gerando
	problemas recorrentes.
	@author Rodrigo Luan Backes
	@since 05/09/2016
	S.S.: 028780

@sample MNTW030()

@return Lógico
/*/
//---------------------------------------------------------------------
Function MNTW030()

	Private lFacilit 	:= .F.
	Private oTmpTbl
	Private cTrb 		:= GetNextAlias()

	lFacilit := IIf(GETMV('MV_NG1FAC') == '1', .T., .F.)

	Processa({ || MNTW030TRB()})
	Processa({ || MNTW030F()})

	//Deleta o arquivo temporario fisicamente
	oTmpTbl:Delete()

Return  .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW030TRB
GERACAO DE ARQUIVO TEMPORARIO

@type function

@source MNTW030.prw

@author Ricardo Dal Ponte
@since 24/11/2006

	Nota: Atualizado para utilização da função de envio de workflow
	NGSendMail() pois o antigo processo TMailMessage() estava gerando
	problemas recorrentes.
	@author Rodrigo Luan Backes
	@since 05/09/2016
	S.S.: 028780

@sample MNTW030TRB()

@return Lógico
/*/
//---------------------------------------------------------------------
Function MNTW030TRB()
	Local i
	Local cCodFunc, dDataDist, cHoraDist
	Local aDBF
	Local aExecutantes := {}
	Local cMailTSK := ""

	aDBF := {	{"SOLICI" ,"C",16,0},;
				{"ORDEM" ,"C",6,0},;
				{"DTABER" ,"D",8,0},;
				{"HRABER" ,"C",5,0},;
				{"DTDIST" ,"D",8,0},;
				{"HRDIST" ,"C",5,0},;
				{"CDSERV" ,"C",6,0},;
				{"NMSERV" ,"C",25,0},;
				{"CDSOLI" ,"C",TamSX3("TQB_CDSOLI")[1],0},;
				{"NMSOLI" ,"C",25,0},;
				{"TIPOSS" ,"C",15,0},;
				{"CODBEM" ,"C",16,0},;
				{"RAMAL" ,"C",10,0},;
				{"CDEXEC" ,"C",If(!lFacilit,TamSX3("TQB_CDEXEC")[1],TamSX3("T1_CODFUNC")[1]),0},;
				{"NMEXEC" ,"C",40,0},;
				{"PRIORI" ,"C",1,0},;
				{"DESPRI" ,"C",5,0},;
				{"EMAIL"  ,"C",200,0},;
				{"CODMSS" ,"C",06,0},;
				{"DESMSS" ,"M",80,0}}

	oTmpTbl := FWTemporaryTable():New(cTrb, aDBF)
	oTmpTbl:AddIndex("Ind01", {"CDEXEC","SOLICI"})
	oTmpTbl:Create()

	dbSelectArea("TQB")
	dbSetOrder(12)
	dbseek(xFilial("TQB")+"D")
	ProcRegua(RecCount())
	While !EoF() .And. xFilial("TQB")+"D" == TQB->TQB_FILIAL+TQB->TQB_SOLUCA

		IncProc()

		aExecutantes := {}

		If !lFacilit
			dbSelectArea("TQ4")
			dbSetOrder(01)
			If dbSeek(xFilial("TQ4")+TQB->TQB_CDEXEC)
				aExecutantes := {{TQB->TQB_CDEXEC, TQ4->TQ4_NMEXEC, AllTrim(TQ4->TQ4_EMAIL1)}}
			EndIf
		Else
			dbSelectArea("TUR")
			dbSetOrder(1)
			dbSeek(xFilial("TUR")+TQB->TQB_SOLICI)
			While !EoF() .And. xFilial("TUR")+TQB->TQB_SOLICI == TUR->TUR_FILIAL+TUR->TUR_SOLICI
				If Empty(TUR->TUR_DTFINA) .And. TUR->TUR_TIPO != "3"
					If TUR->TUR_TIPO == "1"
						dbSelectArea("TP4")
						dbSetOrder(1)
						If dbSeek(NGTROCAFILI("TP4",TUR->TUR_FILATE)+Trim(TUR->TUR_CODATE))
							cCodFunc := TP4->TP4_CODRES
						EndIf
					Else
						cCodFunc := Trim(TUR->TUR_CODATE)
					EndIf
					dbSelectArea("ST1")
					dbSetOrder(1)
					If dbSeek(NGTROCAFILI("ST1",TUR->TUR_FILATE)+cCodFunc)
						aAdd(aExecutantes, {ST1->T1_CODFUNC, ST1->T1_NOME, AllTrim(ST1->T1_EMAIL)} )
					EndIf
				EndIf
				dbSelectArea("TUR")
				dbSkip()
			End
			dDataDist := TQB->TQB_DTABER
			cHoraDist := TQB->TQB_HOABER
			//Procura por follow up de distribuicao
			dbSelectArea("TUM")
			dbSetOrder(2)
			If dbSeek(xFilial("TUM")+Padr("04",TAMSX3("TUM_CODFOL")[1])+TQB->TQB_SOLICI)
				dDataDist := TUM->TUM_DTINIC
				cHoraDist := TUM->TUM_HRINIC
			EndIf
		EndIf

		For i:=1 To Len(aExecutantes)
			RecLock((cTrb),.T.)

			(cTrb)->ORDEM  := TQB->TQB_ORDEM
			(cTrb)->RAMAL  := TQB->TQB_RAMAL
			(cTrb)->PRIORI := TQB->TQB_PRIORI
			(cTrb)->DESPRI := NGRETSX3BOX("TQB_PRIORI",TQB->TQB_PRIORI)
			(cTrb)->SOLICI := TQB->TQB_SOLICI
			(cTrb)->DTABER := TQB->TQB_DTABER
			(cTrb)->HRABER := TQB->TQB_HOABER
			(cTrb)->CDSERV := TQB->TQB_CDSERV
			(cTrb)->CDSOLI := TQB->TQB_CDSOLI
			(cTrb)->TIPOSS := NGRETSX3BOX("TQB_TIPOSS",TQB->TQB_TIPOSS)
			(cTrb)->CODBEM := TQB->TQB_CODBEM
			(cTrb)->CODMSS := TQB->TQB_CODMSS
			(cTrb)->DESMSS := MSMM((cTrb)->CODMSS,80)
			(cTrb)->NMSOLI := UsrRetName(TQB->TQB_CDSOLI)

			dbSelectArea("TQ3")
			dbSetOrder(1)
			If dbSeek(xFilial("TQ3")+TQB->TQB_CDSERV)
				(cTrb)->NMSERV := TQ3->TQ3_NMSERV
			EndIf

			If lFacilit
				(cTrb)->DTDIST := dDataDist
				(cTrb)->HRDIST := cHoraDist
			EndIf
			(cTrb)->CDEXEC := aExecutantes[i][1]
			(cTrb)->NMEXEC := aExecutantes[i][2]
			cMailTSK := NgEmailWF("1","MNTW030")

			(cTrb)->EMAIL := IIf(!(AllTrim(aExecutantes[i][3]) $ Upper( cMailTSK )), AllTrim(aExecutantes[i][3]) + ";" + cMailTSK, cMailTSK)
			(cTrb)->(MsUnlock())
		Next i

		dbSelectArea("TQB")
		dbSkip()
	End

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW030F
Programa para exportar dados para gerar workflow com
alerta de Ordem de servico atrasada.

@type function

@source MNTW030.prw

@author Ricardo Dal Ponte
@since 24/11/2006

	Nota: Atualizado para utilização da função de envio de workflow
	NGSendMail() pois o antigo processo TMailMessage() estava gerando
	problemas recorrentes.
	@author Rodrigo Luan Backes
	@since 05/09/2016
	S.S.: 028780

@sample MNTW030F()

@return Lógico
/*/
//---------------------------------------------------------------------
Function MNTW030F()
	Local cExecutante := ""

	Private cArquivo 	:= "MNTW030_01.htm"
	Private cDir 		:= AllTrim(GetMV("MV_WFDIR"))
	Private cNmExec		:= ""
	Private cMailExec	:= ""
	Private aRegistros 	:= {}

	//Coloco a barra no final do parametro do diretorio
	If Substr(cDir,Len(cDir),1) != "\"
		cDir += "\"
	EndIf

	//Verifico se existe o arquivo de workflow
	If !File(cDir+cArquivo)
		Msgstop(">>> "+STR0012+Space(1)+cDir+cArquivo) //"Nao foi encontrado o arquivo"
		Return .F.
	EndIf

	dbSelectArea(cTrb)
	dbSetOrder(1)
	dbGoTop()
	ProcRegua(LastRec())
	While !EoF()

		aRegistros := {}
		cExecutante := (cTrb)->CDEXEC
		cNmExec := AllTrim((cTrb)->NMEXEC)
		cMailExec := AllTrim((cTrb)->EMAIL)

		While !EoF() .And. cExecutante == (cTrb)->CDEXEC
			IncProc()

			If lFacilit
				aAdd(aRegistros,{STR0013,; //"Prioridade"
								 STR0014,; //"Servico"
								 STR0015,; //"Numero SS"
								 STR0016,; //"Dt. Abertura"
								 STR0007,; //"Hora"
								 STR0017,; //"Solicitante"
								 "Dt. Distribução",;
								 "Hora",;
								(cTrb)->TIPOSS,;
								Space(3)+STR0020,; //"Solicitação:"
							    (cTrb)->DESPRI,;
								(cTrb)->NMSERV,;
								(cTrb)->SOLICI,;
								(cTrb)->DTABER,;
								(cTrb)->HRABER,;
								(cTrb)->NMSOLI,;
								(cTrb)->DTDIST,;
								(cTrb)->HRDIST,;
								(cTrb)->CODBEM,;
								(cTrb)->DESMSS;
							};
			)
			Else
				aAdd(aRegistros,{STR0013,; //"Prioridade"
								 STR0014,; //"Servico"
								 STR0015,; //"Numero SS"
								 STR0016,; //"Dt. Abertura"
								 STR0007,; //"Hora"
								 STR0017,; //"Solicitante"
								 STR0018,; //"Ramal"
								 STR0019,; //"OS"
								 (cTrb)->TIPOSS,;
								 Space(3)+STR0020,; //"Solicitação:"
								 (cTrb)->DESPRI,;
								 (cTrb)->NMSERV,;
								 (cTrb)->SOLICI,;
								 (cTrb)->DTABER,;
								 (cTrb)->HRABER,;
								 (cTrb)->NMSOLI,;
								 (cTrb)->RAMAL,;
								 (cTrb)->ORDEM,;
								 (cTrb)->CODBEM,;
								 (cTrb)->DESMSS;
							};
			)
			EndIf

			dbSelectArea(cTrb)
			dbSkip()
		End

		If Len(aRegistros) > 0 .And. !Empty(cMailExec)
			MNTW030ENV()
		EndIf
	End

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW030ENV
Envia email para executante da solicitacao de servico

@type function

@source MNTW030.prw

@author Ricardo Dal Ponte
@since 12/12/2006

	Nota: Atualizado para utilização da função de envio de workflow
	NGSendMail() pois o antigo processo TMailMessage() estava gerando
	problemas recorrentes.
	@author Rodrigo Luan Backes
	@since 05/09/2016
	S.S.: 028780

@sample MNTW030ENV()

@return Lógico
/*/
//---------------------------------------------------------------------
Function MNTW030ENV()

	Local aArea			:= GetArea()
	Local cSmtp			:= GetNewPar("MV_RELSERV", "") 	// Servidor SMTP
	Local cConta		:= GetNewPar("MV_RELAUSR","") 	// Usuário para autenticação no servidor de e-mail
	Local cCntEmail		:= GetNewPar("MV_RELACNT","")	// Conta de e-mail do usuário no servidor de e-mail
	Local lAutentica	:= GetNewPar("MV_RELAUTH",.F.)	// Autenticação (Sim/Não)
	Local nSmtpPort		:= GetNewPar("MV_PORSMTP",0)	// Porta Servidor SMTP
	Local cAssunto   	:= DtoC(MsDate())+" - "+STR0021 //"Relação de SS em Aberto"
	Local i 			:= 0
	Local lUPD87		:= NGCADICBASE("TSK_TIPUSE","A","TSK",.F.)
	Local nPos			:= 0
	Local cEMAIL_All	:= ""

	If (nPos := At(":",cSmtp)) <> 0
		nSmtpPort		:= Val( SubStr( cSmtp, nPos+1, Len( cSmtp ) ) )
		cSmtp			:= SubStr( cSmtp, 1, nPos-1 )
	EndIf

	dbSelectArea(cTrb)
	dbSetOrder(1)
	ProcRegua(LastRec())

	If Len(aRegistros) = 0 .Or. Empty(cCntEmail)
		Return .T.
	EndIf

	//Estrutura HTML do e-mail
	cMailMsg := '<html>'
	cMailMsg += '<head>'
	cMailMsg += '<meta http-equiv="Content-Language" content="pt-br">'
	cMailMsg += '<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
	cMailMsg += '<title>Solicitação de Serviços - Resumo de Pendências para Executante</title>'
	cMailMsg += '</head>'
	cMailMsg += '<body bgcolor="#FFFFFF">'
	cMailMsg += '<p><b><font face="Arial" size=2>' + STR0021 + '</font></b></p>'
	cMailMsg += '<b><font face="Arial" size=1>' + STR0022 + ": " + cNmExec + '</font></b>'
	cMailMsg += '<div align="left">'
	cMailMsg += '<table border=0 WIDTH="850" cellpadding="2">'

	ProcRegua(Len(aRegistros))

	For i := 1 To Len(aRegistros)
		cMailMsg += '<tr>'
		cMailMsg += '	<td bgcolor="#C0C0C0" align="left" ><b><font face="Arial" size="2">' + aRegistros[i,1] + '</font></b></td>' //"Prioridade"
		cMailMsg += '	<td bgcolor="#C0C0C0" align="left" ><b><font face="Arial" size="2">' + aRegistros[i,2] + '</font></b></td>' //"Servico"
		cMailMsg += '	<td bgcolor="#C0C0C0" align="left" ><b><font face="Arial" size="2">' + aRegistros[i,3] + '</font></b></td>' //"Numero SS"
		cMailMsg += '	<td bgcolor="#C0C0C0" align="left" ><b><font face="Arial" size="2">' + aRegistros[i,4] + '</font></b></td>' //"Dt. Abertura"
		cMailMsg += '	<td bgcolor="#C0C0C0" align="left" ><b><font face="Arial" size="2">' + aRegistros[i,5] + '</font></b></td>' //"Hora"
		cMailMsg += '	<td bgcolor="#C0C0C0" align="left" ><b><font face="Arial" size="2">' + aRegistros[i,6] + '</font></b></td>' //"Solicitante"
		cMailMsg += '	<td bgcolor="#C0C0C0" align="left" ><b><font face="Arial" size="2">' + aRegistros[i,7] + '</font></b></td>' //"Dt. Distribução"
		cMailMsg += '	<td bgcolor="#C0C0C0" align="left" ><b><font face="Arial" size="2">' + aRegistros[i,8] + '</font></b></td>' //"Hora"
		cMailMsg += '	<td bgcolor="#C0C0C0" align="left" ><b><font face="Arial" size="2">' + aRegistros[i,9] + '</font></b></td>' //"Bem            "
		cMailMsg += '<tr>'
		cMailMsg += '	<td bgcolor="#EEEEEE" align="left" ><font face="Arial" size="1">' + aRegistros[i,11] + '</font></td>'
		cMailMsg += '	<td bgcolor="#EEEEEE" align="left" ><font face="Arial" size="1">' + aRegistros[i,12] + '</font></td>'
		cMailMsg += '	<td bgcolor="#EEEEEE" align="left" ><font face="Arial" size="1">' + aRegistros[i,13] + '</font></td>'
		cMailMsg += '	<td bgcolor="#EEEEEE" align="left" ><font face="Arial" size="1">' + dToC(aRegistros[i,14]) + '</font></td>'
		cMailMsg += '	<td bgcolor="#EEEEEE" align="left" ><font face="Arial" size="1">' + aRegistros[i,15] + '</font></td>'
		cMailMsg += '	<td bgcolor="#EEEEEE" align="left" ><font face="Arial" size="1">' + aRegistros[i,16] + '</font></td>'
		If lFacilit
			cMailMsg += '	<td bgcolor="#EEEEEE" align="left" ><font face="Arial" size="1">' + dToC(aRegistros[i,17]) + '</font></td>'
		Else
			cMailMsg += '	<td bgcolor="#EEEEEE" align="left" ><font face="Arial" size="1">' + aRegistros[i,17] + '</font></td>'
		EndIf
		cMailMsg += '	<td bgcolor="#EEEEEE" align="left" ><font face="Arial" size="1">' + aRegistros[i,18] + '</font></td>'
		cMailMsg += '	<td bgcolor="#EEEEEE" align="left" ><font face="Arial" size="1">' + aRegistros[i,19] + '</font></td>'
		cMailMsg += '<tr>'
		cMailMsg += '	<td bgcolor="#DDDDDD" align="left" width="100%" colspan="9"><b><font face="Arial" size="2">' + aRegistros[i,10] + '</font></b></td>' //"   Solicitação:"
		cMailMsg += '<tr>'
		cMailMsg += '	<td bgcolor="#EEEEEE" align="left" width="100%" colspan="9"><font face="Arial" size="1">' + aRegistros[i,20] + '</font></td>'
		ProcRegua(Len(aRegistros))
		cMailMsg += '<tr>'
		cMailMsg += '	<td bgcolor="white" align="left" width="100%" colspan="9" height:5.00pt><b><font face="Arial" color="white" size="2">_</font></b></td>'
		cMailMsg += '</tr>'
	Next i

	cMailMsg += '</table>'
	cMailMsg += '</div>'
	cMailMsg += '</body>'
	cMailMsg += '</html>'

	If !Empty(cMailExec) .And. !(AllTrim(cMailExec) $ cEMAIL_All)
		cEMAIL_All 		:= AllTrim(cMailExec)
	ElseIf !Empty(cCntEmail) .And. !(AllTrim(cCntEmail) $ cEMAIL_All)
		cEMAIL_All 		:= AllTrim(cCntEmail)
	Else
		ShowHelpDlg(STR0033, {STR0031 + STR0028 + STR0029 + "."}, 2, {STR0030}, 1)//"Destinatário do E-mail não informado."##" Favor, verificar parâmetro MV_RELACNT"##"ou se o funcionário possui E-mail cadastrado no sistema."##"Envio de E-mail cancelado!"
	EndIf

	// Validação SMTP, se não informado, cancela envio de WF
	If Empty(cSmtp)
		MsgInfo(STR0032 + STR0030) //"Servidor SMTP não informado! Favor, verificar parâmetro MV_RELSERV."##" Envio do e-mail cancelado!"
		Return .F.
	EndIf

	If lAutentica .And. Empty(cConta)
		MsgInfo(STR0026 + STR0027 + STR0030) //"Verifique os parâmetros de configuração: "##"MV_RELAUSR e MV_RELAUTH."##" Envio do e-mail cancelado!"
		Return .F.
	EndIf

	//Função de envio de WorkFlow
	NGSendMail( , cEMAIL_All + Chr(59) , , , OemToAnsi( cAssunto ) , , cMailMsg )

	RestArea(aArea)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Execução de Parâmetros na Definição do Schedule

@return aParam, Array, Conteudo com as definições de parâmetros para WF

@sample SchedDef()

@author Cauê Girardi Petri
@since 16/09/2022
/*/
//---------------------------------------------------------------------
Static Function SchedDef()
Return {"P", "PARAMDEF", "", {}, "Param"}

