#INCLUDE "MNTW045.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW045
Programa para enviar workflow de aviso de exclusao de SS para o solicitante.
@type function
@source MNTW045.prw
@author Felipe N. Welter
@since 10/07/2009

	Nota: Atualizado para utilização da função de envio de workflow
	NGSendMail() pois o antigo processo TMailMessage() estava gerando
	problemas recorrentes.
	@author Rodrigo Luan Backes
	@since 09/09/2016
	@author Bruno Lobo de Souza
	@since 09/09/2016
	S.S.: 028780

@sample MNTW045()

@return Lógico
/*/
//---------------------------------------------------------------------
Function MNTW045(cCDSS, cCCEmp, cCCFil, cTrbW045, aDbfW045)

	Local oTmpQry
	Local lRet          := .T.

	Private cSS			:= cCDSS
	Private dDtProxMan
	Private nQtdAVcto	:= 0
	Private lAMBIE		:= .F.
	Private cCodEmp		:= ""
	Private cCodFil		:= ""
	Private cEmail		:= ""
	Private aVETINR     := {}
	Private aDBF		:= IIf(ValType(aDbfW045) <> "U", aDbfW045, {})
	Private cAliasQry	:= IIf(ValType(cTrbW045) <> "U", cTrbW045, GetNextAlias())

	If !Empty(cSS)
		cCodEmp := cCCEmp
		cCodFil := cCCFil
	EndIf

	MNTW045Tmp(@cAliasQry, @oTmpQry, aDBF)
	Processa( { || lRet := MNTW045TRB() } )

	If lRet
	
		dbSelectArea(cAliasQry)
		dbGotop()

		If RecCount() <= 0
			lRet :´= .F.
		Else
			Processa({ || MNTW045F()}) //WorkFlow
		EndIf

	EndIf

	//Deleta o arquivo temporario fisicamente
	oTmpQry:Delete()

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW045TRB
GERACAO DE ARQUIVO TEMPORARIO

@type function

@source MNTW045.prw

@author Ricardo Dal Ponte
@since 24/11/2006

	Nota: Atualizado para utilização da função de envio de workflow
	NGSendMail() pois o antigo processo TMailMessage() estava gerando
	problemas recorrentes.
	@author Rodrigo Luan Backes
	@since 09/09/2016
	@author Bruno Lobo de Souza
	@since 09/09/2016
	S.S.: 028780

@sample MNTW045TRB()

@return Lógico
/*/
//---------------------------------------------------------------------
Function MNTW045TRB()

	Private cEMAIL := ""

	cQuery := "SELECT TQB.TQB_SOLICI AS SOLICI, TQB.TQB_DTABER AS DTABER, TQB.TQB_HOABER AS HRABER, TQB.TQB_CDSERV AS CDSERV,"
	cQuery += " TQB.TQB_CDSOLI AS CDSOLI, TQB.TQB_CODMSS AS CODMSS"
	//cQuery += " TQ3.TQ3_NMSERV AS NMSERV"
	cQuery += " FROM "+RetSQLName("TQB")+" TQB"
	//cQuery += " LEFT JOIN "+RetSQLName("TQ3")+" TQ3 ON TQ3.TQ3_CDSERV = TQB.TQB_CDSERV"
	cQuery += " WHERE TQB.TQB_SOLICI = '"+cSS+"' "
	cQuery += " AND TQB.TQB_FILIAL = '"+xFilial("TQB")+"'"

	//Quando se usa SqlToTrb nao se usa ChangeQuery junto
	SqlToTrb(cQuery,aDBF,cAliasQry)

	//GRAVA DETALHES DO ARQUIVO TEMPORARIO
	dbSelectArea(cAliasQry)
	dbGotop()
	RecLock((cAliasQry),.F.)
	aUser := {}
	PswOrder(1)
	//LEITURA DO NOME DO SOLICITANTE
	If PswSeek((cAliasQry)->CDSOLI)
		cCodUser := PswRet(1)[1][1]
		cNMSOLI := AllTrim(SubStr(UsrRetName(cCodUser),1,40))
		nLen := 40-Len(cNMSOLI)
		(cAliasQry)->NMSOLI := cNMSOLI+Space(nLen)
		cEMAIL := AllTrim(SubStr(UsrRetMail(cCodUser),1,50))
	EndIf
	cEMAIL += IIF(Empty(cEMAIL),"",";") + NgEmailWF("1","MNTW045")

	(cAliasQry)->DESMSS := MSMM045((cAliasQry)->CODMSS)
	nLen := 100-Len(cEMAIL)

	// Define limite máximo para string contando e-mails de destinatário.
	If Len( cEMAIL ) > 250

		Help( , , 'NGMAILSIZE', , STR0026,; // O somatório do tamanho de todos os e-mail de destinatário supera 250 caracteres, assim podendo ocasionar inconsistências no processo de envio.
			 1, 0, , , , , , { STR0027 } )  // Para maiores detalhes verificar o KCS: MP - MNT - Existe um limite de e-mails destinatários para um workflow?
		Return .F.

	EndIf

	(cAliasQry)->EMAIL := cEMAIL+Space(nLen)
	MsUnLock(cAliasQry)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW045F
Programa para exportar dados para gerar workflow com alerta de Ordem
de servico atrasada.

@type function

@source MNTW045.prw

@author Ricardo Dal Ponte
@since 24/11/2006

	Nota: Atualizado para utilização da função de envio de workflow
	NGSendMail() pois o antigo processo TMailMessage() estava gerando
	problemas recorrentes.
	@author Rodrigo Luan Backes
	@since 09/09/2016
	@author Bruno Lobo de Souza
	@since 09/09/2016
	S.S.: 028780

@sample MNTW045F()

@return Lógico
/*/
//---------------------------------------------------------------------
Function MNTW045F()

	Local aRegistros	:= {}
	Local cSmtp			:= GetNewPar("MV_RELSERV", "")	// Servidor SMTP
	Local cConta		:= GetNewPar("MV_RELAUSR", "")	// Usuário para autenticação no servidor de email
	Local lAutentica	:= GetNewPar("MV_RELAUTH", .F.)	// Autenticação (Sim/Não)
	Local nSmtpPort		:= GetNewPar("MV_PORSMTP", 0)	// Porta Servidor SMTP
	Local cBodyHtml  	:= ""
	Local cEMAILENV 	:= "" //Variável de responsável pelo recebimento do email para evitar inconsistência na execução do process de envio de WF
	Local cAssunto		:= DtoC(MsDate()) + " - " + STR0014 + " - " + STR0015 + " " + cSS //"Exclusão de Solicitação de Serviço"###"SS"
	Local cINFO			:= STR0016 + DtoC(dDataBase) + STR0017 + SubStr(Time(),1,5) + ; //"Exclusão relizada em "###", às "
								STR0018 + AllTrim(SubStr(UsrRetName(RetCodUsr()), 1, 40)) + " - " + ;//" pelo usuário: "
								AllTrim(SubStr(UsrFullName(RetCodUsr()), 1, 30)) + "."

	dbSelectArea(cAliasQry)
	ProcRegua(LastRec())

	While !EoF()
		IncProc()
		cEMAILENV := AllTrim((cAliasQry)->EMAIL)
		aAdd(aRegistros,{	STR0009,; //"Numero SS"
							STR0010,; //"Dt. Abertura"
							STR0007,; //"Hora"
							STR0011,; //"Servico"
							STR0012,; //"Solicitante"
							"   "+STR0013+":",; //"Solicitação"
							(cAliasQry)->SOLICI,;
							(cAliasQry)->DTABER,;
							(cAliasQry)->HRABER,;
							NGSEEK("TQ3",(cAliasQry)->CDSERV,1,"TQ3_NMSERV"),; //(cAliasQry)->NMSERV,;
							(cAliasQry)->NMSOLI,;
							(cAliasQry)->DESMSS;
						})
		dbSelectArea(cAliasQry)
		dbskip()
	End

	If Len(aRegistros) = 0 .Or. Empty(cEMAILENV)
		Return .T.
	EndIf

	If (nPos := At(":",cSmtp)) <> 0
		nSmtpPort	:= Val( SubStr( cSmtp, nPos+1, Len( cSmtp ) ) )
		cSmtp		:= SubStr( cSmtp, 1, nPos-1 )
	EndIf

	cBodyHtml += '<html>'
	cBodyHtml += '<head>'
	cBodyHtml += '<meta http-equiv="Content-Language" content="pt-br">'
	cBodyHtml += '<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
	cBodyHtml += '<meta name="GENERATOR" content="Microsoft FrontPage 4.0">'
	cBodyHtml += '<meta name="ProgId" content="FrontPage.Editor.Document">'
	cBodyHtml += '<title>Solicitação de Serviços - Aviso de Inclusão</title>'
	cBodyHtml += '</head>'
	cBodyHtml += '<body bgcolor="#FFFFFF">'
	cBodyHtml += '<p><b><u><font face="Arial">' + STR0014 + " - " + STR0015 + " " + cSS + '</font></u></b></p>'
	cBodyHtml += '<p><font face="Arial" size=2>' + cINFO + '</font></p>'
	cBodyHtml += '<div align="left">'
	cBodyHtml += '<table border=0 WIDTH="1000" cellpadding="2">'
	cBodyHtml += '<tr>'
	cBodyHtml += '   <td bgcolor="#C0C0C0" align="left" ><b><font face="Arial" size="2">' + aRegistros[1,1] + '</font></b></td>'
	cBodyHtml += '   <td bgcolor="#C0C0C0" align="left" ><b><font face="Arial" size="2">' + aRegistros[1,2] + '</font></b></td>'
	cBodyHtml += '   <td bgcolor="#C0C0C0" align="left" ><b><font face="Arial" size="2">' + aRegistros[1,3] + '</font></b></td>'
	cBodyHtml += '   <td bgcolor="#C0C0C0" align="left" ><b><font face="Arial" size="2">' + aRegistros[1,4] + '</font></b></td>'
	cBodyHtml += '   <td bgcolor="#C0C0C0" align="left" ><b><font face="Arial" size="2">' + aRegistros[1,5] + '</font></b></td>'
	cBodyHtml += '</tr>'
	cBodyHtml += '<tr>'
	cBodyHtml += '   <td bgcolor="#EEEEEE" align="left" ><font face="Arial" size="1">' + aRegistros[1,7] + '</font></td>'
	cBodyHtml += '   <td bgcolor="#EEEEEE" align="left" ><font face="Arial" size="1">' + dToC(aRegistros[1,8]) + '</font></td>'
	cBodyHtml += '   <td bgcolor="#EEEEEE" align="left" ><font face="Arial" size="1">' + aRegistros[1,9] + '</font></td>'
	cBodyHtml += '   <td bgcolor="#EEEEEE" align="left" ><font face="Arial" size="1">' + aRegistros[1,10] + '</font></td>'
	cBodyHtml += '   <td bgcolor="#EEEEEE" align="left" ><font face="Arial" size="1">' + aRegistros[1,11] + '</font></td>'
	cBodyHtml += '   <tr>'
	cBodyHtml += '      <td bgcolor="#DDDDDD" align="left" width="800" colspan="7"><b><font face="Arial" size="2">' + aRegistros[1,6] + '</b><br>'
	cBodyHtml += '   <tr>'
	cBodyHtml += '      <td bgcolor="#EEEEEE" align="left" width="800" colspan="7"><font face="Arial" size="1">' + aRegistros[1,12] + '<br>'
	cBodyHtml += '   </tr>'
	cBodyHtml += '</table>'
	cBodyHtml += '</div>	'
	cBodyHtml += '<p><br>'
	cBodyHtml += '</p>'
	cBodyHtml += '<hr>'
	cBodyHtml += '</body>'
	cBodyHtml += '</html>'

	//Valida destinatário, se não informado, cancela envio de WF
	If Empty(cEMAILENV)
		ShowHelpDlg(STR0020, {STR0024}, 1, {STR0025}, 1)//"Atenção"##"Problema no envio de Workflow!"##"Destinatário do E-mail não informado! Favor, verificar parâmetro MV_RELACNT. Envio do e-mail cancelado!"
		Return .F.
	EndIf

	// Validação SMTP, se não informado, cancela envio de WF
	If Empty(cSmtp)
		ShowHelpDlg(STR0020, {STR0024}, 1, {STR0022}, 1)//"Atenção"##"Problema no envio de Workflow!"##"Servidor SMTP não informado! Favor, verificar parâmetro MV_RELSERV. Envio do e-mail cancelado!"
		Return .F.
	EndIf

	If lAutentica .And. Empty(cConta)
		ShowHelpDlg(STR0020, {STR0024}, 1, {STR0023}, 1)//"Atenção"##"Problema no envio de Workflow!"##"Verifique os parâmetros de configuração: MV_RELAUSR e MV_RELAUTH. Envio do e-mail cancelado!"
		Return .F.
	EndIf

	//Função de envio de WorkFlow
	lEmailRet := NGSendMail( , cEMAILENV , , , cAssunto , , cBodyHtml ) //"Exclusão de Solicitação de Serviço"###"SS"

Return lEmailRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MSMM045
Função para pegar o conteúdo do campo memo da tabela SYP.

@type function

@source MNTW045.prw

@author Felipe N. Welter
@since 10/07/2009

	Nota: Atualizado para utilização da função de envio de workflow
	NGSendMail() pois o antigo processo TMailMessage() estava gerando
	problemas recorrentes.
	@author Rodrigo Luan Backes
	@since 09/09/2016
	@author Bruno Lobo de Souza
	@since 09/09/2016
	S.S.: 028780

@sample MSMM045()

@return Lógico
/*/
//---------------------------------------------------------------------
Function MSMM045(cMEMO)

	Local aAreaBkp      := GetArea()
	Local cAliQry		:= GetNextAlias()
	Local nPos2			:= 0
	Local nPos			:= 0
	Local cMemoSYP		:= ""
	Local cQuerySYP		:= ""

	cQuerySYP := "SELECT * FROM " + RetSQLName("SYP") + " WHERE YP_CHAVE = '" + cMEMO + "'"
	cQuerySYP := ChangeQuery(cQuerySYP)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuerySYP),cAliQry, .F., .T.)
	dbGoTop()

	Do While !EoF()

		nPos := At("\13\10",Subs(FieldGet(4),1,86))
		If ( nPos == 0 )
			cLine := RTrim(Subs(FieldGet(4),1,80))
			If ( nPos2 := At("\14\10", cLine) ) > 0
				cMemoSYP += StrTran( cLine, "\14\10", Space(6) )
			Else
				cMemoSYP += cLine
			EndIf
		Else
			cMemoSYP += Subs(FieldGet(4),1,nPos-1) + CRLF
		EndIf
		dbSkip()
	EndDo

	(cAliQry)->(dbCloseArea())

	RestArea(aAreaBkp)

Return cMemoSYP

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW045Tmp
Cria tabela temporária
@author bruno.souza
@since 24/02/2017
@version undefined
@param cTrbW045, characters, Alias da tabela temporária
@param oTmpW045, object, Instância da classe FwTemporary Table
@type function
/*/
//---------------------------------------------------------------------
Function MNTW045Tmp(cTrbW045, oTmpW045, aDbfW045)

	dbSelectArea("TQB")
	aAdd(aDbfW045,{"SOLICI" ,"C",16,0})
	aAdd(aDbfW045,{"DTABER" ,"D",8,0})
	aAdd(aDbfW045,{"HRABER" ,"C",5,0})
	aAdd(aDbfW045,{"CDSERV" ,"C",6,0})
	aAdd(aDbfW045,{"NMSERV" ,"C",25,0})
	aAdd(aDbfW045,{"CDSOLI" ,"C",06,0})
	aAdd(aDbfW045,{"NMSOLI" ,"C",25,0})
	aAdd(aDbfW045,{"CODMSS" ,"C",06,0})
	aAdd(aDbfW045,{"DESMSS" ,"M",80,0})
	aAdd( aDbfW045, { 'EMAIL', 'C', 250, 0 } )

	//Intancia classe FWTemporaryTable
	oTmpW045 := FWTemporaryTable():New( cTrbW045, aDbfW045 )
	//Cria indices
	oTmpW045:AddIndex( "Ind01" , {"SOLICI"} )
	//Cria a tabela temporaria
	oTmpW045:Create()

Return
