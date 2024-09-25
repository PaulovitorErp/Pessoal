#INCLUDE "MNTW210.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW210
Workflow - Garantias Vencidas/A Vencer

@type function

@source MNTW210.prw

@author Marcos Wagner Junior
@since 13/08/2008

	Nota: Atualizado para utilização da função de envio de workflow
	NGSendMail() pois o antigo processo TMailMessage() estava gerando
	problemas recorrentes.
	@author Rodrigo Luan Backes
	@since 05/09/2016
	@author Bruno Lobo de Souza
	@since 05/09/2016
	S.S.: 028780

@sample MNTW210()

@return Lógico
/*/
//---------------------------------------------------------------------
Function MNTW210(_cMV_PAR)

	Private cPerg := "MNW210"
	Private aPerg   :={}
	Private cMV_PAR01, cMV_PAR02

	If !Pergunte(cPerg,.T.)
		Return
	EndIf

	cMV_PAR01 := MV_PAR01
	cMV_PAR02 := MV_PAR02

	MNTW210F()

Return  .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW210F
Envio do Workflow

@type function

@source MNTW210.prw

@author Marcos Wagner Junior
@since 13/08/2008

	Nota: Atualizado para utilização da função de envio de workflow
	NGSendMail() pois o antigo processo TMailMessage() estava gerando
	problemas recorrentes.
	@author Rodrigo Luan Backes
	@since 05/09/2016
	@author Bruno Lobo de Souza
	@since 05/09/2016
	S.S.: 028780

@sample MNTW210F()

@return Lógico
/*/
//---------------------------------------------------------------------
Function MNTW210F()

	Local lRetu			:= .T.
	Local aRegistros	:= {}
	Local i				:= 0
	Local cMailMsg		:= ""
	Local cEmail		:= ""
	Local cEMAIL_All	:= ""
	Local cAssunto		:= dtoc(MsDate()) + " - " + STR0009 //"Garantias Vencidas/A Vencer"
	Local cSmtp			:= GetNewPar("MV_RELSERV", "") 	//Servidor SMTP
	Local cConta		:= GetNewPar("MV_RELAUSR","") 	// Usuário para autenticação no servidor de e-mail
	Local cCntEmail		:= GetNewPar("MV_RELACNT","")	// Conta de e-mail do usuário no servidor de e-mail
	Local lAutentica	:= GetNewPar("MV_RELAUTH",.F.)	// Autenticação (Sim/Não)
	Local nSmtpPort		:= GetNewPar("MV_PORSMTP",0)	// Porta Servidor SMTP

	If (nPos := At(":",cSmtp)) <> 0
		nSmtpPort	:= Val( SubStr( cSmtp, nPos+1, Len( cSmtp ) ) )
		cSmtp		:= SubStr( cSmtp, 1, nPos-1 )
	EndIf

	dbSelectArea("ST9")
	dbSetOrder(01)
	dbGoTop()
	dbSeek(xFilial("ST9"))
	While !EoF() .And. ST9->T9_FILIAL == xFilial("ST9")
		If !Empty(ST9->T9_DTGARAN) .And. ST9->T9_DTGARAN >= cMV_PAR01 .And. ST9->T9_DTGARAN <= cMV_PAR02
			aAdd(aRegistros,{	ST9->T9_CODBEM,;
									ST9->T9_NOME,;
									ST9->T9_DTCOMPR,;
									ST9->T9_PRGARAN,;
									NGRETSX3BOX("T9_UNGARAN",ST9->T9_UNGARAN),;
									ST9->T9_DTGARAN,;
									ST9->T9_DTINSTA})
		EndIf

		dbSelectArea("ST9")
		dbSkip()
	End

	If Len(aRegistros) = 0
		ApMsgAlert(STR0017) //"Não existem dados para enviar o workflow!"
		Return .T.
	EndIf
	If ExistBlock("MNTW2101")
		ExecBlock("MNTW2101",.F.,.F.,{aRegistros})
		Return lRetu
	Else
		aSORT(aRegistros,,,{|x,y| Dtos(x[6])+x[1] < Dtos(y[6])+y[1] })

		cMailMsg := '<html>'
		cMailMsg += '	<head>'
		cMailMsg += '		<meta http-equiv="Content-Language" content="pt-br">'
		cMailMsg += '		<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
		cMailMsg += '		<meta name="GENERATOR" content="Microsoft FrontPage 4.0">'
		cMailMsg += '		<meta name="ProgId" content="FrontPage.Editor.Document">'
		cMailMsg += '		<title>Documentos Vencidos/A Vencer</title>'
		cMailMsg += '	</head>'
		cMailMsg += '	<body bgcolor="#FFFFFF">'
		cMailMsg += '		<p><b><font face="Arial">'+STR0009+'</font></b></p>'
		cMailMsg += '		<div align="left">'
		cMailMsg += '			<table border=0 WIDTH=100% cellpadding="2">'
		cMailMsg += '				<tr>'
		cMailMsg += '					<td bgcolor="#C0C0C0" align="center" width="60"><b><font face="Arial" size="2">'+STR0013+'</font></b></td>'
		cMailMsg += '					<td bgcolor="#C0C0C0" align="center" width="135" ><b><font face="Arial" size="2">'+STR0014+'</font></b></td>'
		cMailMsg += '					<td bgcolor="#C0C0C0" align="center" width="85" ><b><font face="Arial" size="2">'+STR0011+'</font></b></td>'
		cMailMsg += '					<td bgcolor="#C0C0C0" align="center" width="85" ><b><font face="Arial" size="2">'+STR0018+'</font></b></td>'
		cMailMsg += '					<td bgcolor="#C0C0C0" align="center" width="85" ><b><font face="Arial" size="2">'+STR0015+'</font></b></td>'
		cMailMsg += '					<td bgcolor="#C0C0C0" align="center" width="85" ><b><font face="Arial" size="2">'+STR0012+'</font></b></td>'
		cMailMsg += '				</tr>'
		cMailMsg += '				</u>'

		For i := 1 to Len(aRegistros)
			cMailMsg += '				<tr>'
			cMailMsg += '					<td bgcolor="#EEEEEE" align="center" width="60"><b><font face="Arial" size="1">'+aRegistros[i,1]+'</font></b></td>'
			cMailMsg += '					<td bgcolor="#EEEEEE" align="center" width="135" ><b><font face="Arial" size="1">'+aRegistros[i,2]+'</font></b></td>'
			cMailMsg += '					<td bgcolor="#EEEEEE" align="center" width="85" ><b><font face="Arial" size="1">'+DtoC(aRegistros[i,3])+'</font></b></td>'
			cMailMsg += '					<td bgcolor="#EEEEEE" align="center" width="85" ><b><font face="Arial" size="1">'+DtoC(aRegistros[i,7])+'</font></b></td>'
			cMailMsg += '					<td bgcolor="#EEEEEE" align="center" width="75" ><b><font face="Arial" size="1">'+Alltrim(Str(aRegistros[i,4]))+' - '+Alltrim(aRegistros[i,5])+'</font></b></td>'
			cMailMsg += '					<td bgcolor="#EEEEEE" align="center" width="75" ><b><font face="Arial" size="1">'+DtoC(aRegistros[i,6])+'</font></b></td>'
			cMailMsg += '				</tr>'
		Next i

		cMailMsg += '			</table>'
		cMailMsg += '		</div>'
		cMailMsg += '		<U>'
		cMailMsg += '		<br><hr>'
		cMailMsg += '	</body>'
		cMailMsg += '</html>'

		cEmail		:= NgEmailWF("1","MNTW210")

		If !Empty(cEmail)
			cEMAIL_All := cEmail
		ElseIf !Empty(cCntEmail)
			cEMAIL_All := cCntEmail
		Else
			ShowHelpDlg(STR0022, {STR0026 + STR0023 + "."}, 2, {STR0025}, 1)//"Destinatário do E-mail não informado."##" Favor, verificar parâmetro MV_RELACNT"##" ou se o funcionário possui E-mail cadastrado no sistema."##"Envio de E-mail cancelado!"
		EndIf

		If Empty(cSmtp)
			MsgInfo(STR0027 + STR0025) //"Servidor SMTP não informado! Favor, verificar parâmetro MV_RELSERV."##" Envio do e-mail cancelado!"
			Return .F.
		EndIf

		If lAutentica .And. Empty(cConta)
			MsgInfo(STR0028 + STR0021 + STR0025) //"Verifique os parâmetros de configuração: "##"MV_RELAUSR e MV_RELAUTH."##" Envio do e-mail cancelado!"
			Return .F.
		EndIf

		lRetu := NGSendMail(, cEMAIL_All,,, cAssunto,, cMailMsg )

		If lRetu
			MsgInfo(STR0016)
		EndIf
	EndIf

Return lRetu