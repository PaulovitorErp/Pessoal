#INCLUDE "mntw005.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW005
Programa para exportar dados para gerar workflow com alerta de
tendencia de falhas de bens.

@type function

@source MNTW005.prw

@author Ricardo Dal Ponte
@since 04/09/2006

	Nota: Atualizado para utilização da função de envio de workflow
	NGSendMail() pois o antigo processo TMailMessage() estava gerando
	problemas recorrentes.
	@author Rodrigo Luan Backes
	@since 01/09/2016
	S.S.: 028780

@sample MNTW005()

@return Lógico
/*/
//---------------------------------------------------------------------
Function MNTW005()

	Local lAMBIE   		:= .F.

	Local aNGBEGINPRM 	:= {}
	Local lRet			:= .F.

	Private lSchedule	:= isBlind()
	Private aVETINR  	:= {}
	Private cMailMsg 	:= ""
	Private cTRB		:= ""
	Private oTmpTRB		:= Nil

	If !lSchedule
		aNGBEGINPRM := NGBEGINPRM()
		Processa( {|| lRet := MNTW005TRB() }, STR0011, STR0019 ) // "Alerta de Tendencias de Falhas" ## "Selecionando Registros..."
	Else
		lRet := MNTW005TRB()
	EndIf

	If lRet

		//WorkFlow de Controle de Qualidade
		If !lSchedule
			Processa( {|| MNTW005F() }, STR0011, STR0031 ) // "Alerta de Tendencias de Falhas" ## "Preparando Workflow..."
			NGRETURNPRM(aNGBEGINPRM)
		Else
			MNTW005F()
		EndIf

	EndIf

	dbSelectArea(cTRB)
	Set Filter To

	dbSelectArea("STJ")
	Set Filter To

	dbSelectArea("STS")
	Set Filter To

	dbSelectArea("TP8")
	Set Filter To

	dbSelectArea("TP0")
	Set Filter To

	dbSelectArea("TPT")
	Set Filter To

	oTmpTRB:Delete()

	If !lSchedule
		NGRETURNPRM(aNGBEGINPRM)
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW005F
Programa para exportar dados para gerar workflow com alerta de
tendencia de falhas de bens.

@type function

@source MNTW005.prw

@author Ricardo Dal Ponte
@since 04/09/2006

	Nota: Atualizado para utilização da função de envio de workflow
	NGSendMail() pois o antigo processo TMailMessage() estava gerando
	problemas recorrentes.
	@author Rodrigo Luan Backes
	@since 01/09/2016
	S.S.: 028780

@sample MNTW005F()

@return Lógico
/*/
//---------------------------------------------------------------------
Function MNTW005F()

	Local i,x,y
	Local lRet			:= .T.
	Local aRegistros	:= {}
	Local aArea			:= GetArea()
	Local cSmtp			:= GetNewPar("MV_RELSERV", "") 	      // Servidor SMTP
	Local cConta		:= GetNewPar("MV_RELAUSR","") 	      // Usuário para autenticação no servidor de e-mail
	Local lAutentica	:= GetNewPar("MV_RELAUTH",.F.)	      // Autenticação (Sim/Não)
	Local cFrom         := SuperGetMV('MV_RELACNT', .F., '' ) // E-mail de Origem

	Local cAssunto   	:= DtoC(MsDate())+" - "+STR0011 //"Alerta de Tendencias de Falhas"
	Local nPos			:= 0
	Local cEMAIL_All	:= ''
	Local cMsgError		:= ''
	Local cMsgSol       := ''

	If !lSchedule
		ProcRegua( 0 )
	EndIf

	//Validações de parâmetros
	Do Case
		Case Empty( cFrom )
			cMsgError := STR0025 // "Envio de E-mail cancelado!"
			cMsgSol   := STR0023 + '.' // "Favor verificar parâmetro MV_RELACNT"
		Case Empty( cSmtp )
			cMsgError := STR0025 // "Envio do e-mail cancelado!"
			cMsgSol   := STR0029 // "Favor verificar parâmetro MV_RELSERV."
		Case lAutentica .And. Empty( cConta )
			cMsgError := STR0025 // "Envio do e-mail cancelado!"
			cMsgSol   := STR0021 + STR0022 //"Verifique os parâmetros de configuração: "##"MV_RELAUSR e MV_RELAUTH."
	EndCase

	If Empty( cMsgError )

		dbSelectArea(cTRB)
		SET FILTER To (cTRB)->QUANTI >= (cTRB)->QTDALE

		dbGoTop()

		While !EoF()

			AADD(aRegistros,{STR0012,; //"BEM: "
			(cTRB)->CODBEM,;
				(cTRB)->NOMBEM,;
				STR0013,;  //"CENTRO DE CUSTO: "
			(cTRB)->CCUSTO,;
				(cTRB)->NCUSTO,;
				STR0014,;  //"CENTRO DE TRABALHO: "
			(cTRB)->CENTRAB,;
				(cTRB)->NOMTRAB,;
				STR0015,;  //"IRREGULARIDADE: "
			(cTRB)->CODIRE,;
				(cTRB)->NOMIRE,;
				STR0016,;  //"QUANTIDADE OCORRENCIAS: "
			(cTRB)->QUANTI,;
				STR0017,;  //"PERIODO DE ANALISE: "
			(cTRB)->DTLIMT,;
				STR0018,;  //"  ATE  "
			dDataBase })

			dbSelectArea(cTRB)
			dbSkip()

		EndDo

		// Validações de registros
		If Len(aRegistros) <= 0

			cMsgError := STR0020 + '. ' + STR0025 //"Não foram encontrados registros de Tendencias de Falhas"##" Envio do e-mail cancelado!"

		Else

			cEMAIL_All := NgEmailWF( '1', 'MNTW005' )

			If Empty( cEMAIL_All )
				cMsgError := STR0026 + ' ' + STR0025 //"Destinatário do E-mail não informado."##"Envio de E-mail cancelado!"
				cMsgSol   := STR0030 // "Favor verificar se o sistema tem responsáveis por filial com e-mail cadastrado na Rotina de Filiais( MNTA855 )."
			EndIf

		EndIf

	EndIf

	If !Empty( cMsgError )

		Help( "", 1, STR0028, , cMsgError, 1, 0, , , , , , { cMsgSol }) // "Atenção!"
		NGWFLog( cMsgError + ' ' + cMsgSol, .T., .T., 'MNTW005' )
		lRet := .F.

	Else

		If ExistBlock("MNTW0051")
			ExecBlock("MNTW0051",.F.,.F.,{aRegistros})
		Else

			cMailMsg := '<html>'
			cMailMsg += '<head>'
			cMailMsg += '<meta http-equiv="Content-Language" content="pt-br">'
			cMailMsg += '<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
			cMailMsg += '<meta name="GENERATOR" content="Microsoft FrontPage 4.0">'
			cMailMsg += '<meta name="ProgId" content="FrontPage.Editor.Document">'
			cMailMsg += '<title>Aviso sobre Solicitação de Serviços</title>'
			cMailMsg += '</head>'

			cMailMsg += '<body bgcolor="#FFFFFF">'

			cMailMsg += '<p><b><font face="Arial"> ' + STR0011 + '</font></b></p>'

			For i := 1 to Len(aRegistros)

				cMailMsg += '<table border=0 WIDTH=100% cellpadding="1">'
				cMailMsg += '	<tr>'
				cMailMsg += '		<td bgcolor="#C0C0C0" align="left" width="100%" height="5"><b><font face="Arial" size="2">' + aRegistros[i,1] + '</font> <font face="Arial" size="2">' + aRegistros[i,2] + ' - ' + aRegistros[i,3] + '</font></b></td>'
				cMailMsg += '	</tr>'

				cMailMsg += '	<tr>'
				cMailMsg += '		<td bgcolor="#EEEEEE" align="left" width="100%" height="5"><font face="Arial" size="1">' + aRegistros[i,4] + '</font> <font face="Arial" size="1">' + aRegistros[i,5] + ' - ' + aRegistros[i,6] + '</font></td>'
				cMailMsg += '	</tr>'

				cMailMsg += '	<tr>'
				cMailMsg += '		<td bgcolor="#EEEEEE" align="left" width="100%" height="5"><font face="Arial" size="1">' + aRegistros[i,7] + '</font> <font face="Arial" size="1">' + aRegistros[i,8] + ' - ' + aRegistros[i,9] + '</font></td>'
				cMailMsg += '	</tr>'

				cMailMsg += '	<tr>'
				cMailMsg += '		<td bgcolor="#EEEEEE" align="left" width="100%" height="5"><font face="Arial" size="1">' + aRegistros[i,10] + '</font> <font face="Arial" size="1">' + aRegistros[i,11] + ' - ' + aRegistros[i,12] + '</font></td>'
				cMailMsg += '	</tr>'

				cMailMsg += '	<tr>'
				cMailMsg += '		<td bgcolor="#EEEEEE" align="left" width="100%" height="5"><font face="Arial" size="1">' + aRegistros[i,13] + '</font> <font face="Arial" size="1">' + cValToChar(aRegistros[i,14]) + '</font></td>'
				cMailMsg += '	</tr>'

				cMailMsg += '	<tr>'
				cMailMsg += '		<td bgcolor="#EEEEEE" align="left" width="100%" height="5"><font face="Arial" size="1">' + aRegistros[i,15] + '</font> <font face="Arial" size="1">' + dToC(aRegistros[i,16]) + '</font><font face="Arial" size="1">' + aRegistros[i,17] + '</font> <font face="Arial" size="1">' +  dToC(aRegistros[i,18]) + '</font></td>'
				cMailMsg += '	</tr>'

				cMailMsg += '	<tr>'
				cMailMsg += '		<td bgcolor=white align="left" width="100%" height="5"><font face="Arial" size="0" color=white> - </font></td>'
				cMailMsg += '	</tr>'
				cMailMsg += '</table>'

			Next i

			cMailMsg += '</body>'
			cMailMsg += '</html>'

			//Função de envio de WorkFlow
			If NGSendMail( , cEMAIL_All + Chr(59), , , OemToAnsi( cAssunto ), , cMailMsg )

				If !lSchedule
					MsgInfo( STR0027 ) // 'Workflow enviado com sucesso!'
				EndIf
				NGWFLog( STR0027, .T., .T., 'MNTW005' ) // 'Workflow enviado com sucesso!'

			EndIf

		EndIf

	EndIf

	RestArea(aArea)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW005TRB
GERACAO DE ARQUIVO TEMPORARIO

@type function

@source MNTW005.prw

@author Ricardo Dal Ponte
@since 04/09/2006

	Nota: Atualizado para utilização da função de envio de workflow
	NGSendMail() pois o antigo processo TMailMessage() estava gerando
	problemas recorrentes.
	@author Rodrigo Luan Backes
	@since 01/09/2016
	S.S.: 028780

@sample MNTW005TRB()

@return Lógico
/*/
//---------------------------------------------------------------------
Function MNTW005TRB()
	Local aDBF, cIndR005
	Local nAlerta
	Local dDtLimit1, dDtLimit2
	Local cFilter1 := ""
	Local cFilter2 := ""
	Local cFilter3 := ""

	If !lSchedule
		ProcRegua( 0 )
	EndIf

	//criacao arquivo temporario
	//----------------------------------------
	aDBF :={{"CODBEM"  ,"C",16,0},;
			{"NOMBEM"  ,"C",40,0},;
			{"CODIRE"  ,"C",03,0},;
			{"NOMIRE"  ,"C",40,0},;
			{"CCUSTO"  ,"C",09,0},;
			{"NCUSTO"  ,"C",40,0},;
			{"CENTRAB" ,"C",06,0},;
			{"NOMTRAB" ,"C",40,0},;
			{"DTLIMT"  ,"D",08,0},;
			{"QTDALE"  ,"N",08,0},;
			{"QUANTI"  ,"N",08,0}}

	//Variavel recebe GetNextAlias()
	cTRB := GetNextAlias()
	//Intancia classe FWTemporaryTable
	oTmpTRB := FWTemporaryTable():New(cTRB, aDBF)
	//Cria indices
	oTmpTRB:AddIndex("Ind01", {"CODBEM","CODIRE"})
	//Cria a tabela temporaria
	oTmpTRB:Create()

	//----------------------------------------
	nAlerta		:= GetMv("MV_NGALERT")
	dDtLimit1	:= dDataBase - nAlerta

	IF dDtLimit1 = dDataBase
		Help( "", 1, STR0028, , STR0032, 1, 0, , , , , , { STR0033 } ) // "ATenção" ## "Período de análise deve ser de pelo menos 1 dia." ## "Favor verificar parâmetro MV_NGALERT."
		Return .F.
	EndIf

	//GERACAO PARA ARQUIVO DE ORDEM DE SERVICO
	dbSelectArea("STJ")

	cFilter1 := "STJ->TJ_PLANO = '000000' .And. "  //ST9->T9_CODBEM
	cFilter1 += "STJ->TJ_TERMINO = 'S' .And. "
	cFilter1 += "STJ->TJ_IRREGU <> '"+Space(Len(STJ->TJ_IRREGU))+"' .And.
	cFilter1 += "(DTOS(STJ->TJ_DTMRFIM) >= "+ValToSql(dDtLimit1)+" .And. DTOS(STJ->TJ_DTMRFIM) <= "+ValToSql(dDataBase)+")"

	SET FILTER To &cFilter1

	dbGoTop()
	While !EoF()
		dbSelectArea(cTRB)
		dbSetOrder(01)

		If !dbSeek(STJ->TJ_CODBEM+STJ->TJ_IRREGU)
			(cTRB)->(dbAppend())
			(cTRB)->CODBEM := STJ->TJ_CODBEM
			(cTRB)->NOMBEM := ""
			(cTRB)->CODIRE := STJ->TJ_IRREGU
			(cTRB)->NOMIRE := ""
			(cTRB)->CCUSTO := ""
			(cTRB)->NCUSTO := ""
			(cTRB)->CENTRAB := ""
			(cTRB)->NOMTRAB := ""
			(cTRB)->QUANTI := 0

			dbSelectArea("TP7")
			dbSetOrder(01)

			If dbSeek(xFilial()+STJ->TJ_IRREGU)
				If TP7->TP7_UNDTMP == "1"
					//Unidade de Dias
					dDtLimit2 := dDataBase - (TP7->TP7_QTDTMP)
				ElseIf TP7->TP7_UNDTMP == "2"
					//Unidade de Mes
					dDtLimit2 := dDataBase - (TP7->TP7_QTDTMP * 30)
				ElseIf TP7->TP7_UNDTMP == "3"
					//Unidade de Ano
					dDtLimit2 := dDataBase - (TP7->TP7_QTDTMP * 365)
				EndIf

				(cTRB)->QTDALE := TP7->TP7_QTDALE
				(cTRB)->NOMIRE := TP7->TP7_NOME
				(cTRB)->DTLIMT := dDtLimit2
			EndIf
		EndIf

		If STJ->TJ_DTMRFIM >= (cTRB)->DTLIMT
			(cTRB)->QUANTI := (cTRB)->QUANTI + 1
		EndIf

		dbSelectArea("STJ")
		dbSkip()
	End

	//GERACAO PARA ARQUIVO DE ORDEM DE SERVICO - HISTORICO
	dbSelectArea("STS")

	cFilter2 := "STS->TS_PLANO = '000000' .And. "
	cFilter2 += "STS->TS_TERMINO = 'S' .And. "
	cFilter2 += "STS->TS_IRREGU <> '"+Space(Len(STS->TS_IRREGU))+"' .And. "
	cFilter2 += "(DTOS(STS->TS_DTMRFIM) >= "+ValToSql(dDtLimit1)+" .And. DTOS(STS->TS_DTMRFIM) <= "+ValToSql(dDataBase)+")"

	SET FILTER To &cFilter2
	dbGoTop()
	While !EoF()
		dbSelectArea(cTRB)
		dbSetOrder(01)

		If !dbSeek(STS->TS_CODBEM+STS->TS_IRREGU)
			(cTRB)->(dbAppend())
			(cTRB)->CODBEM := STS->TS_CODBEM
			(cTRB)->NOMBEM := ""
			(cTRB)->CODIRE := STS->TS_IRREGU
			(cTRB)->NOMIRE := ""
			(cTRB)->CCUSTO := ""
			(cTRB)->NCUSTO := ""
			(cTRB)->CENTRAB := ""
			(cTRB)->NOMTRAB := ""
			(cTRB)->QUANTI := 0

			dbSelectArea("TP7")
			dbSetOrder(01)

			If dbSeek(xFilial()+STS->TS_IRREGU)
				If TP7->TP7_UNDTMP == "1"
					//Unidade de Dias
					dDtLimit2 := dDataBase - (TP7->TP7_QTDTMP)
				ElseIf TP7->TP7_UNDTMP == "2"
					//Unidade de Mes
					dDtLimit2 := dDataBase - (TP7->TP7_QTDTMP * 30)
				ElseIf TP7->TP7_UNDTMP == "3"
					//Unidade de Ano
					dDtLimit2 := dDataBase - (TP7->TP7_QTDTMP * 365)
				EndIf

				(cTRB)->QTDALE := TP7->TP7_QTDALE
				(cTRB)->NOMIRE := TP7->TP7_NOME
				(cTRB)->DTLIMT := dDtLimit2
			EndIf
		EndIf

		If STS->TS_DTMRFIM >= (cTRB)->DTLIMT
			(cTRB)->QUANTI := (cTRB)->QUANTI + 1
		EndIf

		dbSelectArea("STS")
		dbSkip()
	End

	//GERACAO PARA ARQUIVO DE DIGITACAO DO PCP
	dbSelectArea("TP8")

	cFilter3 := "DTOS(TP8->TP8_DTOCOR) >= "+ValToSql(dDtLimit1)+" .And. DTOS(TP8->TP8_DTOCOR) <= "+ValToSql(dDataBase)

	SET FILTER To &cFilter3
	dbGoTop()

	While !EoF()
		dbSelectArea(cTRB)
		dbSetOrder(01)

		If !dbSeek(TP8->TP8_CODBEM+TP8->TP8_CODIRE)
			(cTRB)->(dbAppend())
			(cTRB)->CODBEM := TP8->TP8_CODBEM
			(cTRB)->NOMBEM := ""
			(cTRB)->CODIRE := TP8->TP8_CODIRE
			(cTRB)->NOMIRE := ""
			(cTRB)->CCUSTO := ""
			(cTRB)->NCUSTO := ""
			(cTRB)->CENTRAB := ""
			(cTRB)->NOMTRAB := ""
			(cTRB)->QUANTI := 0

			dbSelectArea("TP7")
			dbSetOrder(01)

			If dbSeek(xFilial()+TP8->TP8_CODIRE)
				If TP7->TP7_UNDTMP == "1"
					//Unidade de Dias
					dDtLimit2 := dDataBase - (TP7->TP7_QTDTMP)
				ElseIf TP7->TP7_UNDTMP == "2"
					//Unidade de Mes
					dDtLimit2 := dDataBase - (TP7->TP7_QTDTMP * 30)
				ElseIf TP7->TP7_UNDTMP == "3"
					//Unidade de Ano
					dDtLimit2 := dDataBase - (TP7->TP7_QTDTMP * 365)
				EndIf

				(cTRB)->QTDALE := TP7->TP7_QTDALE
				(cTRB)->NOMIRE := TP7->TP7_NOME
				(cTRB)->DTLIMT := dDtLimit2
			EndIf
		EndIf

		If TP8->TP8_DTOCOR >= (cTRB)->DTLIMT
			(cTRB)->QUANTI := (cTRB)->QUANTI + 1
		EndIf

		dbSelectArea("TP8")
		dbSkip()
	End

	//GRAVA DETALHES DO ARQUIVO TEMPORARIO
	dbSelectArea(cTRB)
	dbGoTop()

	While !EoF()
		//LEITURA DO NOME DO BEM
		dbSelectArea("ST9")
		dbSetOrder(01)

		If dbSeek(xFilial()+(cTRB)->CODBEM)
			(cTRB)->NOMBEM := ST9->T9_NOME
			(cTRB)->CCUSTO := ST9->T9_CCUSTO
			(cTRB)->CENTRAB:= ST9->T9_CENTRAB
		EndIf

		//LEITURA DO CENTRO DE CUSTO
		dbSelectArea("CTT")
		dbSetOrder(01)

		If dbSeek(xFilial()+(cTRB)->CCUSTO)
			(cTRB)->NCUSTO := CTT->CTT_DESC01
		EndIf

		//LEITURA DO CENTRO DE TRABALHO
		dbSelectArea("SHB")
		dbSetOrder(01)

		If dbSeek(xFilial()+(cTRB)->CENTRAB)
			(cTRB)->NOMTRAB := SHB->HB_NOME
		EndIf

		dbSelectArea(cTRB)
		dbSkip()
	End
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} W005EMAIL
GERACAO DA LISTA DE EMAILS PARA O WORKFLOW

@type function

@source MNTW005.prw

@author Ricardo Dal Ponte
@since 04/09/2006

	Nota: Atualizado para utilização da função de envio de workflow
	NGSendMail() pois o antigo processo TMailMessage() estava gerando
	problemas recorrentes.
	@author Rodrigo Luan Backes
	@since 01/09/2016
	S.S.: 028780

@sample W005EMAIL()

@return Caractere
/*/
//---------------------------------------------------------------------
Function W005EMAIL(cPrograma)
	Local cEmail		:= ""
	Local cEmailC		:= ""
	Local cNgMntRh		:= ""

	//VERIFICA SE EXISTE SISTEMA DE RH VINSULADO
	cNgMntRh := AllTrim(GetMv("MV_NGMNTRH"))

	dbSelectArea("TP0")
	SET FILTER To TP0->TP0_CODPRO = cPrograma
	dbGoTop()

	While !EoF()
		dbSelectArea("TPT")
		SET FILTER To TPT->TPT_CODGRP = TP0->TP0_CODGRP
		dbGoTop()

		While !EoF()
			cCodFun := TPT->TPT_CODFUN

			If cNgMntRh $ "SX"
				//CARREGA EMAIL DO CADASTRO DE FUNCIONARIOS DO SISTEMA DE RH (TABELA SRA)
				dbSelectArea("SRA")
				dbSetOrder(01)
				If dbSeek(xFilial("SRA")+cCodFun)
					If !Empty(SRA->RA_EMAIL)
						cEmail:=AllTrim(SRA->RA_EMAIL)
					EndIf
				EndIf
			EndIf

			If Empty(cEmail)
				//CARREGA EMAIL DO CADASTRO DE FUNCIONARIOS DO SISTEMA DE MNT (TABELA ST1)
				dbSelectArea("ST1")
				dbSetOrder(01)
				If dbSeek(xFilial("ST1")+cCodFun)
					If !Empty(ST1->T1_EMAIL)
						cEmail:=AllTrim(ST1->T1_EMAIL)
					EndIf
				EndIf
			EndIf

			If cEmailC == ""
				cEmailC := cEmail
			Else
				If cEmail <> ""
					cEmailC := cEmailC+";"+cEmail
				EndIf
			EndIf

			cEmail	:= ""

			dbSelectArea("TPT")
			dbSkip()
		End While

		dbSelectArea("TP0")
		dbSkip()
	End While

Return cEmailC

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
