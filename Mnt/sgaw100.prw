#Include 'Protheus.ch'
#Include 'SGAW100.CH'
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

//---------------------------------------------------------------------
/*{Protheus.doc} SGAW100()
Workflow para aviso de Não Conformidades no retorno de critérios de
controle.

@author Juliani Schlickmann Damasceno
@since 24/02/2014
@version 11
@return Nil
/*/
//---------------------------------------------------------------------
Function SGAW100(aWfCrit)

Processa({ || EnvWfCrit(aWfCrit) }) //Processa Workflow

Return

//-----------------------------------------------------------------------
/*{Protheus.doc} EnvWfCrit(aWfCrit)
Envia o WorkFlow

@author Juliani Schlickmann Damasceno
@since 25/02/2014
@version 1.0
*/
//-----------------------------------------------------------------------
Static Function EnvWfCrit(aWfCrit)
Local aArea		:= GetArea()
Local oServer
Local cSmtp		:= GetNewPar("MV_RELSERV","") // Servidor Smtp
Local cAccount		:= GetNewPar("MV_RELAUSR","") // Usuário para autenticação no servidor de email
Local cPass		:= GetNewPar("MV_RELPSW" ,"") // Senha do usuário no servidor de e-mail
Local cCntEmail	:= GetNewPar("MV_RELACNT","") // Conta de e-mail do usuário no servidor de e-mail
Local cPswEmail	:= GetNewPar("MV_RELAPSW" ,"") // Senha do usuário no servidor de e-mail
Local lAutentica	:= GetNewPar("MV_RELAUTH",.F.)// Autenticação (Sim/Não)
Local nSMTPTime 	:= GetNewPar("MV_RELTIME",60) // Timeout no Envio de EMAIL.
Local lSSL 		:= GetNewPar("MV_RELSSL",.T.) // Define se o envio e recebimento de e-mails
Local lTLS 		:= GetNewPar("MV_RELTLS",.T.) // Se o servidor de SMTP possui conexao
Local nSmtpPort	:= GetNewPar("MV_PORSMTP",0) // Porta Servidor Smtp
Local cFrom 		:= GetNewPar("MV_RELFROM","") // E-mail do remetente
Local cTrbWF100  	:= GetNextAlias()
Local oTempTRB

Local cBodyHtml  := ""
Local cRespAtual := ""
Local cEmailResp := ""

Local aFldTrb    	:= {} // Array do TRB

If Empty(cSmtp) .Or. Empty(cAccount) .Or. Empty(cFrom) // Verifica de há servidor SMTP e se o email do usuário no servidor está preenchido.
	Return
EndIf

// Adiciona os campos no TRB.
aFldTrb := {}
Aadd(aFldTrb,{"RESPONS", "C" , NGSX3TAM("TAZ_RESPON"), 0 })
Aadd(aFldTrb,{"EMLRESP", "C" , NGSX3TAM("QAA_EMAIL") , 0 })
Aadd(aFldTrb,{"CODCRIT", "C" , NGSX3TAM("TAZ_CODCRI"), 0 })
Aadd(aFldTrb,{"DESCRIT", "C" , NGSX3TAM("TAZ_DESCRI"), 0 })
Aadd(aFldTrb,{"RESIDUO", "C" , NGSX3TAM("TAX_CODRES"), 0 })
Aadd(aFldTrb,{"RESDESC", "C" , NGSX3TAM("TAX_DESCRE"), 0 })
Aadd(aFldTrb,{"CODOCOR", "C" , NGSX3TAM("TB1_CODOCO"), 0 })
Aadd(aFldTrb,{"LIMMINI", "N" , NGSX3TAM("TAZ_LIMMIN"), 0 })
Aadd(aFldTrb,{"LIMMAXI", "N" , NGSX3TAM("TAZ_LIMMAX"), 0 })
Aadd(aFldTrb,{"UNIMED" , "C" , NGSX3TAM("TAZ_UNIMED"), 0 })
Aadd(aFldTrb,{"QUANTID", "N" , NGSX3TAM("TB1_QTDE")  , 0 })
Aadd(aFldTrb,{"COMPLEM", "M" , NGSX3TAM("TB1_COMPLE"), 0 })

// Cria o índice do TRB e cria o TRB.
oTempTRB := FWTemporaryTable():New( cTrbWF100, aFldTrb )
oTempTRB:AddIndex( "1", {"RESPONS","RESIDUO","CODCRIT"} )
oTempTRB:Create()

FillTrb(aWfCrit, cTrbWF100) // Chama a função que alimenta o TRB.

dbSelectArea(cTrbWF100)
dbSetOrder(1)
dbGoTop()
If !Eof()

	oServer := TMailManager():New() // Objeto de email

	// Verifica a forma de envio e recebimento de email.
	oServer:SetUseSSL(lSSL)
	oServer:SetUseTLS(lTLS)

	// Inicializa o servidor
	nRet := oServer:Init( "", cSmtp , cCntEmail, cPswEmail, , nSmtpPort )

	// Faz a conexão com o servidor.
	If nRet == 0
		nRet := oServer:SetSMTPTimeout( nSMTPTime )
	Endif

	If nRet == 0
		nRet := oServer:SMTPConnect()
	Endif

	// Faz a autenticação do servidor.
	If nRet == 0 .And. lAutentica
		nRet := oServer:SmtpAuth( cAccount, cPass )
	Endif

	// Se haver algum problema desconecta.
	If nRet != 0
		ShowHelpDlg(STR0014, {AllTrim(oServer:GetErrorString(nRet)),1}, { STR0015 } )
		oServer:SMTPDisconnect()
		Return
	Endif

	dbSelectArea(cTrbWF100)
	dbSetOrder(1)
	ProcRegua(RecCount())
	dbGotop()
	While !Eof()

		IncProc()

		// Verifica qual o responsavel atual para o envio do email.
		If (cTrbWF100)->RESPONS <> cRespAtual

			cRespAtual := (cTrbWF100)->RESPONS
			cEmailResp := AllTrim((cTrbWF100)->EMLRESP)

			// Estrutura do Workflow
			cBodyHtml := '		<noscript><b><U><font face="Arial" size=2 color="#FF0000"></font></b>'
			cBodyHtml += '		</noscript>'
			cBodyHtml += '		<p><b><font face="Arial"><u>' + STR0005 + '</u></font></b></p>'
			cBodyHtml += '		<table border=0 WIDTH=100% cellpadding="1">'
			cBodyHtml += '		<tr>'
			cBodyHtml += '   		<td colspan="3" bgcolor="#C0C0C0"><b><font face="Arial" size="2">' + STR0006 + (cTrbWF100)->RESIDUO + " - " + (cTrbWF100)->RESDESC+'</font></b></td>' // "Resíduo: "
			cBodyHtml += '   		<td colspan="4" bgcolor="#C0C0C0"><b><font face="Arial" size="2">' + STR0007 + (cTrbWF100)->CODOCOR + '</font></b></td>' // "Ocorrência: "
			cBodyHtml += '		</tr>'
			cBodyHtml += '		<tr>'
			cBodyHtml += '			<td bgcolor="#C0C0C0" align="center"><font face="Arial" size="2"><b>' + STR0008 + '</font></b></td>' // "Critérios"
			cBodyHtml += '			<td width=47%  bgcolor="#C0C0C0" align="center">
			cBodyHtml += '				<font face="Arial" size="2"><b>' + STR0009 + '</b></font>' // "Descrição"
			cBodyHtml += '			</td>'
			cBodyHtml += '			<td bgcolor="#C0C0C0" align="center"><font face="Arial" size="2"><b>' + STR0010 + '</font></b></td>' // "Lim. Mínimo"
			cBodyHtml += '			<td bgcolor="#C0C0C0" align="center"><font face="Arial" size="2"><b>' + STR0011 + '</font></b></td>' // "Lim. Máximo"
			cBodyHtml += '			<td bgcolor="#C0C0C0" align="center"><font face="Arial" size="2"><b>' + STR0012 + '</font></b></td>' // "Quantidade"
			cBodyHtml += '			<td bgcolor="#C0C0C0" align="center"><font face="Arial" size="2"><b>' + STR0013 + '</b></font></td>' // "Unid. Medida"
			cBodyHtml += '		</tr>'

		EndIf

		cBodyHtml += '		<tr>'
		cBodyHtml += '   		<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + (cTrbWF100)->CODCRIT + '</font></td>'
		cBodyHtml += '   		<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + (cTrbWF100)->DESCRIT + '</font></td>'
		cBodyHtml += '   		<td bgcolor="#EEEEEE" align="center"><font face="Arial" size="1">' + cValToChar((cTrbWF100)->LIMMINI) + '</font></td>'
		cBodyHtml += '   		<td bgcolor="#EEEEEE" align="center"><font face="Arial" size="1">' + cValToChar((cTrbWF100)->LIMMAXI) + '</font></td>'
		cBodyHtml += '   		<td bgcolor="#EEEEEE" align="center"><font face="Arial" size="1">' + cValToChar((cTrbWF100)->QUANTID) + '</font></td>'
		cBodyHtml += '   		<td bgcolor="#EEEEEE" align="center"><font face="Arial" size="1">' + (cTrbWF100)->UNIMED + '</font></td>'
		cBodyHtml += '		</tr>'
		cBodyHtml += '		<tr>'
		cBodyHtml += '   		<td bgcolor="#EEEEEE" colspan=6 align="left"><font face="Arial" size="1">' + (cTrbWF100)->COMPLEM + '</font></td>'
		cBodyHtml += '		</tr>'

		dbSelectArea(cTrbWF100)
		dbSkip()

		// Envia o workflow para o responsável
		If (cTrbWF100)->(Eof()) .Or. (cTrbWF100)->RESPONS <> cRespAtual

			cBodyHtml += '</table>'
			cBodyHtml += '<br><hr>'

			oMessage := TMailMessage():New()
			oMessage:Clear()

			oMessage:cDate 	:= cValToChar( Date() )
			oMessage:cFrom 	:= cAccount
			oMessage:cTo 		:= cEmailResp
			oMessage:cSubject	:= STR0002
			oMessage:cBody   	:= cBodyHtml

			oMessage:Send( oServer )

			cBodyHtml := ""
		Endif

	End

	If nRet == 0
		nRet := oServer:SMTPDisconnect()
	Endif

Endif

oTempTRB:Delete()

RestArea(aArea)

Return

//-----------------------------------------------------------------------
/*Static Function FillTrb
Alimenta tabela temporaria de envio do workflow.

@author Juliani Schlickmann Damasceno
@since 25/02/2014
@version 1.0
*/
//-----------------------------------------------------------------------
Static Function FillTrb(aWfCrit, cTrbWF100)

Local nResiduo, nCriterio

Local aAreaTAZ := TAZ->(GetArea())
Local aAreaQAA := QAA->(GetArea())
Local aAreaTB1 := TB1->(GetArea())
Local aAreaSB1 := SB1->(GetArea())

dbSelectArea("TAZ")
dbSetOrder(1)

dbSelectArea("QAA")
dbSetOrder(1)

dbSelectArea("TB1")
dbSetOrder(1)

dbSelectArea("SB1")
dbSetOrder(1)

For nResiduo := 1 to Len(aWfCrit)
	For nCriterio := 1 to Len(aWfCrit[nResiduo][2])

		If TAZ->(dbSeek(xFilial("TAZ")+aWfCrit[nResiduo][1]+aWfCrit[nResiduo][2][nCriterio][1])) .And. !Empty(TAZ->TAZ_RESPON)

			If QAA->(dbSeek(xFilial("QAA")+TAZ->TAZ_RESPON )) .And. !Empty(QAA->QAA_EMAIL)

				SB1->(dbSeek(xFilial("SB1") + aWfCrit[nResiduo][1]))	// Resíduo
				TB1->(dbSeek(xFilial("TB1") + aWfCrit[nResiduo][2][nCriterio][4] + aWfCrit[nResiduo][2][nCriterio][1])) // Cod. Ocorrencia + Cod. Critério

				dbSelectArea(cTrbWF100)
				dbSetOrder(1)

				// Alimenta o TRB.
				If !dbSeek(TAZ->TAZ_RESPON + aWfCrit[nResiduo][1] + aWfCrit[nResiduo][2][nCriterio][1])
					RecLock(cTrbWF100, .T.)
					(cTrbWF100)->RESPONS := TAZ->TAZ_RESPON
					(cTrbWF100)->EMLRESP := QAA->QAA_EMAIL
					(cTrbWF100)->CODCRIT := aWfCrit[nResiduo][2][nCriterio][1]
					(cTrbWF100)->DESCRIT := TAZ->TAZ_DESCRI
					(cTrbWF100)->RESIDUO := aWfCrit[nResiduo][1]
					(cTrbWF100)->RESDESC := SB1->B1_DESC
					(cTrbWF100)->CODOCOR := aWfCrit[nResiduo][2][nCriterio][4]
					(cTrbWF100)->LIMMINI := TAZ->TAZ_LIMMIN
					(cTrbWF100)->LIMMAXI := TAZ->TAZ_LIMMAX
					(cTrbWF100)->UNIMED  := TAZ->TAZ_UNIMED
					(cTrbWF100)->QUANTID := aWfCrit[nResiduo][2][nCriterio][2]
					(cTrbWF100)->COMPLEM := aWfCrit[nResiduo][2][nCriterio][3]
					(cTrbWF100)->(MsUnLock())
				EndIf
			EndIf
		EndIf
	Next nCriterio
Next nResiduo

RestArea(aAreaTAZ)
RestArea(aAreaQAA)
RestArea(aAreaTB1)
RestArea(aAreaSB1)

Return