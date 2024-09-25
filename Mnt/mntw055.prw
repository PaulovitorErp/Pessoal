#INCLUDE "MNTW055.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW055
Workflow de aviso de inclusao de sinistro

@type function

@source MNTW055.prw

@author Ricardo Dal Ponte
@since 03/04/2007

	Nota: Atualizado para utilização da função de envio de workflow
	NGSendMail() pois o antigo processo TMailMessage() estava gerando
	problemas recorrentes.
	@author Rodrigo Luan Backes
	@since 13/09/2016
	@author Bruno Lobo de Souza
	@since 13/09/2016
	S.S.: 028780

@sample MNTW055()

@return Lógico
/*/
//---------------------------------------------------------------------
Function MNTW055(c_FILIAL)

	Local cCntEmail		:= GetNewPar("MV_RELACNT","")

	Private cEmail 		:= NgEmailWF("4","MNTW055")
	Private cARQ1
	Private aVETINR  	:= {}
	Private cEmailSin 	:= AllTrim(GetMv("MV_NGRESIN"))

	If !Empty(cEmailSin)
		If !(AllTrim(cEmailSin) $ cEmail)
			cEmail := AllTrim(cEmail) + ";" + AllTrim(cEmailSin)
		EndIf
	EndIf

	If !Empty(cCntEmail)
		If !(AllTrim(cCntEmail) $ cEmail)
			cEmail := AllTrim(cEmail) + ";" + AllTrim(cCntEmail)
		EndIf
	EndIf

	Processa({ || MNTW055F()})

Return  .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW055F
Envio do Workflow

@type function

@source MNTW055.prw

@author Ricardo Dal Ponte
@since 24/11/2006

	Nota: Atualizado para utilização da função de envio de workflow
	NGSendMail() pois o antigo processo TMailMessage() estava gerando
	problemas recorrentes.
	@author Rodrigo Luan Backes
	@since 13/09/2016
	@author Bruno Lobo de Souza
	@since 13/09/2016
	S.S.: 028780

@sample MNTW055F()

@return Lógico
/*/
//---------------------------------------------------------------------
Function MNTW055F()

	Local cArquivo		:= "MNTW055.htm"
	Local cDir			:= Alltrim(GetMV("MV_WFDIR"))
	Local aRegistros	:= {}
	Local i				:= 0
	Local cSmtp			:= GetNewPar("MV_RELSERV", "") 	//Servidor SMTP
	Local cConta		:= GetNewPar("MV_RELAUSR","") 	// Usuário para autenticação no servidor de e-mail
	Local lAutentica	:= GetNewPar("MV_RELAUTH",.F.)	// Autenticação (Sim/Não)
	Local nSmtpPort		:= GetNewPar("MV_PORSMTP",0)	// Porta Servidor SMTP
	Local cAssunto		:= STR0022 //"Aviso de Inclusão de Sinistro"
	Local cTitulo		:= DtoC(MsDate())+" - "+STR0022 //"Aviso de Inclusão de Sinistro"
	Local cBodyHtml  	:= ""
	Local lEmailRet		:= .T.

	If (nPos := At(":",cSmtp)) <> 0
		nSmtpPort	:= Val( SubStr( cSmtp, nPos+1, Len( cSmtp ) ) )
		cSmtp		:= SubStr( cSmtp, 1, nPos-1 )
	EndIf

	cTRH_NUMSIN := M->TRH_NUMSIN
	cTRH_DTACID := DTOC(M->TRH_DTACID)
	cTRH_HRACID := M->TRH_HRACID
	cTRH_EVENTO := M->TRH_EVENTO
	cTRH_CODBEM := M->TRH_CODBEM

	dbSelectArea("ST9")
	dbSetOrder(1)

	cTRH_NOMBEM := ""
	If dbSeek(xFilial("ST9")+M->TRH_CODBEM)
		cTRH_NOMBEM := ST9->T9_NOME
	EndIf

	cTRH_TIPACI := ""

	cTRH_TIPACI := Posicione("SX5", 1, xFilial("SX5")+"AF"+M->TRH_TIPACI, "X5Descri()")

	cTRH_PLACA  := M->TRH_PLACA

	If M->TRH_GRAVID = "1"
		cTRH_GRAVID := STR0009 //"Leve"
	ElseIf M->TRH_GRAVID = "2"
		cTRH_GRAVID := STR0010 //"Médio"
	ElseIf M->TRH_GRAVID = "3"
		cTRH_GRAVID := STR0011 //"Grave"
	ElseIf M->TRH_GRAVID = "4"
		cTRH_GRAVID := STR0012 //"Gravíssimo"
	ElseIf Empty(M->TRH_GRAVID)
		cTRH_GRAVID := ""
	EndIf

	aAdd(aRegistros,{	STR0013,; //"Sinistro"
						STR0014,; //"Dt.Acid."
						STR0015,; //"Hr.Acid."
						STR0016,;  //"Evento"
						STR0017,; //"Bem"
						STR0018,; //"Descrição do Bem"
						STR0019,; //"Placa"
						STR0020,; //"Tp.Evento"
						STR0021,; //"Gravidade"
						cTRH_NUMSIN,;
						cTRH_DTACID,;
						cTRH_HRACID,;
						cTRH_EVENTO,;
						cTRH_CODBEM,;
						cTRH_NOMBEM,;
						cTRH_PLACA,;
						cTRH_TIPACI,;
						cTRH_GRAVID;
					})

	If Len(aRegistros) = 0 .Or. Empty(cEmail)
		Return .T.
	EndIf

	cBodyHtml += '<html>'
	cBodyHtml += '<head>'
	cBodyHtml += '<meta http-equiv="Content-Language" content="pt-br">'
	cBodyHtml += '<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
	cBodyHtml += '<meta name="GENERATOR" content="Microsoft FrontPage 4.0">'
	cBodyHtml += '<meta name="ProgId" content="FrontPage.Editor.Document">'
	cBodyHtml += '<title>' + cAssunto + '</title>'
	cBodyHtml += '</head>'

	cBodyHtml += '<body bgcolor="#FFFFFF">'

	cBodyHtml += '<p><b><font face="Arial">' + cAssunto + '</font></b></p>'
	cBodyHtml += '<table border=0 WIDTH=100% cellpadding="1">'
	cBodyHtml += '<tr>'
	cBodyHtml += '   <td bgcolor="#C0C0C0" align="center"><b><font face="Arial" size="2">' + aRegistros[1,1] + ' </font></b></td>'
	cBodyHtml += '   <td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + aRegistros[1,2] + ' </font></b></td>'
	cBodyHtml += '   <td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + aRegistros[1,3] + ' </font></b></td>'
	cBodyHtml += '   <td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + aRegistros[1,4] + ' </font></b></td>'
	cBodyHtml += '   <td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + aRegistros[1,5] + ' </font></b></td>'
	cBodyHtml += '   <td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + aRegistros[1,6] + ' </font></b></td>'
	cBodyHtml += '   <td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + aRegistros[1,7] + ' </font></b></td>'
	cBodyHtml += '   <td bgcolor="#C0C0C0" align="Center"><b><font face="Arial" size="2">' + aRegistros[1,8] + ' </font></b></td>'
	cBodyHtml += '   <td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + aRegistros[1,9] + ' </font></b></td>'
	cBodyHtml += '<tr>'
	ProcRegua(Len(aRegistros))

	For i := 1 To Len(aRegistros)
		IncProc()
		cBodyHtml += '   <td bgcolor="#EEEEEE" align="center"><font face="Arial" size="1">' + aRegistros[i,10] + ' </font></td>'
		cBodyHtml += '   <td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aRegistros[i,11] + ' </font></td>'
		cBodyHtml += '   <td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aRegistros[i,12] + ' </font></td>'
		cBodyHtml += '   <td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aRegistros[i,13] + ' </font></td>'
		cBodyHtml += '   <td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aRegistros[i,14] + ' </font></td>'
		cBodyHtml += '   <td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aRegistros[i,15] + ' </font></td>'
		cBodyHtml += '   <td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aRegistros[i,16] + ' </font></td>'
		cBodyHtml += '   <td bgcolor="#EEEEEE" align="center"><font face="Arial" size="1">' + aRegistros[i,17] + ' </font></td>'
		cBodyHtml += '   <td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aRegistros[i,18] + ' </font></td>'
	Next

	cBodyHtml += '</tr>'
	cBodyHtml += '</tr>'
	cBodyHtml += '</table>'
	cBodyHtml += '<br><hr>'
	cBodyHtml += '</body>'
	cBodyHtml += '</html>'

	//Valida destinatário, se não informado, cancela envio de WF
	If Empty(cEmail)
		ShowHelpDlg(STR0026, {STR0029}, 1, {STR0030}, 1)//"Atenção"##"Problema no envio de Workflow!"##"Destinatário do E-mail não informado! Favor, verificar parâmetro MV_RELACNT. Envio do e-mail cancelado!"
		Return .F.
	EndIf

	// Validação SMTP, se não informado, cancela envio de WF
	If Empty(cSmtp)
		ShowHelpDlg(STR0026, {STR0029}, 1, {STR0027}, 1)//"Atenção"##"Problema no envio de Workflow!"##"Servidor SMTP não informado! Favor, verificar parâmetro MV_RELSERV. Envio do e-mail cancelado!"
		Return .F.
	EndIf

	If lAutentica .And. Empty(cConta)
		ShowHelpDlg(STR0026, {STR0029}, 1, {STR0028}, 1)//"Atenção"##"Problema no envio de Workflow!"##"Verifique os parâmetros de configuração: MV_RELAUSR e MV_RELAUTH. Envio do e-mail cancelado!"
		Return .F.
	EndIf

	IF cEmail <> ""
		//Função de envio de WorkFlow
		lEmailRet := NGSendMail( , cEmail , , , cTitulo , , cBodyHtml ) //"Exclusão de Solicitação de Serviço"###"SS"
		If lEmailRet
			MsgInfo( STR0025 + ": " + cEmail + "!" ) //"Aviso de Inclusão de Sinistro enviado para"
		EndIf
	EndIf

Return lEmailRet