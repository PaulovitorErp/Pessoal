#INCLUDE "mntw010.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW010
Programa para exportar dados para gerar workflow com
alerta de Ordem de servico atrasada.

@author Alexandre Santos
@since 27/06/2018

@sample MNTW010()

@param
@return
/*/
//---------------------------------------------------------------------
Function MNTW010()

	Local aNGBEGINPRM := {}
	Local cEmail	  := ''
	Local lSchedule	  := IsBlind()

	Private cTrb1	  := GetNextAlias()
	Private cTrb2	  := GetNextAlias()

	//Abre ambiente ou carrega variaveis do ambiente
	If !lSchedule
		aNGBEGINPRM :=	NGBEGINPRM()
	EndIf

	cEmail := NgEmailWF("1","MNTW010")

	//Fecha ambiente ou encerra variaveis do ambiente
	If !lSchedule
		Processa({||MNTW010TRB(cEmail)})
		NGRETURNPRM(aNGBEGINPRM)
	Else
		MNTW010TRB(cEmail)
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW010TRB
GERACAO DE ARQUIVO TEMPORARIO

@type function

@source MNTW010.prw

@author Ricardo Dal Ponte
@since 04/09/2006

	Nota: Atualizado para utilização da função de envio de workflow
	NGSendMail() pois o antigo processo TMailMessage() estava gerando
	problemas recorrentes.
	@author Rodrigo Luan Backes
	@since 05/09/2016
	S.S.: 028780

@sample MNTW010TRB()

@return Lógico
/*/
//---------------------------------------------------------------------
Function MNTW010TRB(cEmail)

	Local aDBF
	Local aIndR010
	Local nAlerta
	Local cDescMot
	Local oTmpTbl1
	Local oTmpTbl2

	//criação arquivo temporário
	//----------------------------------------
	aDBF := {	{"DTLIMT"  ,"D" ,08 ,0 },;
				{"CODBEM"  ,"C" ,16 ,0 },;
				{"NOMBEM"  ,"C" ,40 ,0 },;
				{"CCUSTO"  ,"C" ,09 ,0 },;
				{"NCUSTO"  ,"C" ,40 ,0 },;
				{"ORDEMM"  ,"C" ,06 ,0 },;
				{"PDESCR"  ,"C" ,10 ,0 },;
				{"PLANO"   ,"C" ,06 ,0 }}

	aIndR010 := {"DTLIMT","CODBEM","ORDEMM"}
	oTmpTbl1 := FWTemporaryTable():New( cTrb1, aDBF )
	oTmpTbl1:AddIndex( "Ind01" , aIndR010 )
	oTmpTbl1:Create()

	//----------------------------------------

	//GERACAO PARA ARQUIVO DE ORDEM DE SERVICO
	dbSelectArea("STJ")
	SET FILTER To STJ->TJ_FILIAL == xFilial("STJ") .And. ;
		STJ->TJ_DTMPFIM <= dDataBase .And. !Empty(STJ->TJ_DTMPFIM) .And. STJ->TJ_TERMINO == "N" .And. STJ->TJ_SITUACA == "L"
	dbGoTop()
	While !EoF()

		dbSelectArea(cTrb1)
		dbSetOrder(01)

		If !Dbseek(DTOS(STJ->TJ_DTMPFIM)+STJ->TJ_CODBEM+STJ->TJ_ORDEM)
			(cTrb1)->(DbAppend())
			(cTrb1)->CODBEM := STJ->TJ_CODBEM

			(cTrb1)->NOMBEM := If(STJ->TJ_TIPOOS = "B",NGSEEK("ST9",STJ->TJ_CODBEM,1,"T9_NOME"),;
				NGSEEK("TAF","X2"+Substr(STJ->TJ_CODBEM,1,3),7,"TAF_NOMNIV"))

			(cTrb1)->CCUSTO := ""
			(cTrb1)->NCUSTO := ""
			(cTrb1)->PLANO  := STJ->TJ_PLANO
			(cTrb1)->ORDEMM := STJ->TJ_ORDEM

			if STJ->TJ_PLANO == "000000"
				(cTrb1)->PDESCR  := STR0006 //"Corretivo"
			Else
				(cTrb1)->PDESCR  := STR0007 //"Preventivo"
			EndIf

			(cTrb1)->DTLIMT := STJ->TJ_DTMPFIM
		End If

		dbSelectArea("STJ")
		dbSkip()
	End While


	dbSelectArea("STJ")
	Set Filter To

	//GRAVA DETALHES DO ARQUIVO TEMPORARIO
	dbSelectArea(cTrb1)
	dbGoTop()

	ProcRegua(LastRec())

	While !EoF()
		IncProc()

		//LEITURA DO CENTRO DE CUSTO DO BEM
		dbSelectArea("ST9")
		dbSetOrder(01)

		If Dbseek(xFilial()+(cTrb1)->CODBEM)
			(cTrb1)->CCUSTO := ST9->T9_CCUSTO
		EndIf

		//LEITURA DO NOME DO CENTRO DE CUSTO
		dbSelectArea("CTT")
		dbSetOrder(01)

		If Dbseek(xFilial()+(cTrb1)->CCUSTO)
			(cTrb1)->NCUSTO := CTT->CTT_DESC01
		EndIf

		dbSelectArea(cTrb1)
		dbSkip()
	End

	//Geração de arquivo temporário MOTIVO.
	MNTW10TRB(@oTmpTbl2)
	MNTW010F(cEmail)

	//Deleta os arquivos temporarios fisicamente
	oTmpTbl1:Delete()
	oTmpTbl2:Delete()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW010F
Programa para exportar dados referente ao workflow.
@type function

@author Ricardo Dal Ponte
@since 04/09/2006

@sample MNTW010F( 'teste@teste.com' )

@param  cEmail, Caracter, Destinatário do workflow.
@return Lógico, Define se o processo foi realizado com exito.
/*/
//---------------------------------------------------------------------
Function MNTW010F( cEmail )

	Local lRet 		 := .T.
	Local aRegistros := {}
	Local aMotivosOs := {}
	Local nPosOS

	dbSelectArea(cTrb1)
	dbGotop()
	dbSetOrder(01)
	ProcRegua(LastRec())

	nRegs := 0
	Do While (cTrb1)->( !EoF() )
		IncProc()

		AADD(aRegistros,{	STR0019,; //"Data Prevista"
		STR0020,; //"Bem"
		STR0021,; //"Nome do Bem"
		STR0022,; //"Numero da OS"
		STR0023,; //"Plano"
		(cTrb1)->DTLIMT,;
		(cTrb1)->CODBEM,;
		(cTrb1)->NOMBEM,;
		(cTrb1)->ORDEMM,;
		(cTrb1)->PLANO+" - "+(cTrb1)->PDESCR})

		dbSelectArea( cTrb2 )
		DbGoTop()
		dbSetOrder( 01 )
		ProcRegua( LastRec() )
		dbSeek( (cTrb1)->ORDEMM )
		While !EoF() .And. (cTrb1)->ORDEMM == (cTrb2)->ORDEM
			IncProc()

			If( nPosOS := aScan(aMotivosOs,{|x| x[1] ==  (cTrb1)->ORDEMM })) == 0
				AADD( aMotivosOs,	{ (cTrb2)->ORDEM, {} })
				nPosOS := Len( aMotivosOs )
			EndIf

			aAdd( aMotivosOs[nPosOS][2], {	(cTrb2)->MOTIVO,;
				(cTrb2)->DESCRI,;
				(cTrb2)->DTINIC,;
				(cTrb2)->HRINIC,;
				(cTrb2)->DTFIM ,;
				(cTrb2)->HRFIM})
			dbSelectArea( cTrb2 )
			dbSkip()

		End

		//faz o envio de workflow a cada 300 registros, quando o volume eh muito grande
		nRegs++
		If nRegs > 300

			lRet  := MNTW10SEND( aRegistros, aMotivosOs, .F., cEmail )
			nRegs := 0
			aRegistros := {}
			aMotivosOs := {}

			// Caso ocorra erro no envio em algum lote, encerra o processo dos demais envios.
			If !lRet
				Exit
			EndIf

		EndIf

		(cTrb1)->( dbSkip() )

	EndDo

	//envio de workflow menor que 300 registros ou a diferenca que ultrapassou a ultima milhar
	If Len( aRegistros ) > 0
		lRet := MNTW10SEND( aRegistros, aMotivosOs, .T., cEmail )
	EndIf

Return lRet

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} MNTW10SEND
Funcao de envio do workflow
@type function

@author Evaldo Cevinscki Jr.
@since 12/04/2010

@sample MNTW10SEND( aReg, aMotiOS, .F., 'teste@teste.com' )

@param aRegistros, Array   , Registros que compõe o workflow enviado.
@param aMotivosOs, Array   , Registros de motivos de atraso da O.S.
@param lUltimo   , Lógico  , Define se é o ultimo lote de 500 registros de envio.
@param cEmail    , Caracter, E-mails de destinatário.
@return Lógico   , Define se o envio do workflow foi enviado com sucesso.
/*/
//-----------------------------------------------------------------------------------
Static Function MNTW10SEND( aRegistros, aMotivosOs, lUltimo, cEmail )

	Local i			 := 0
	Local n			 := 0
	Local nPosOs	 := 0
	Local aMotivos	 := {}
	Local lRet		 := .T.
	Local cAssunto	 := dtoc(MsDate())+" - "+STR0018+" "+STR0019+" : "+DtoC(aRegistros[1,6])+" - "+DtoC(aRegistros[Len(aRegistros),6]) //"OS em Atraso"
	Local cBody      := ""
	Local lNoInter   := IsBlind()

	Default aMotivosOs	:= {}

	cBody := "<body>"
	cBody += '<meta http-equiv="Content-Language" content="pt-br">'
	cBody += '<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
	cBody += '<meta name="GENERATOR" content="Microsoft FrontPage 4.0">'
	cBody += '<meta name="ProgId" content="FrontPage.Editor.Document">'
	cBody += '<title>'+STR0032+'</title>' //"Aviso sobre Solicitação de Serviços"
	cBody += '</head>'
	cBody += '<body bgcolor="#FFFFFF">'
	cBody += '</noscript>'
	cBody += '<p><b><U><font face="Arial">'+STR0033+'</font></b></p>' //"OS em Atraso"

	For i := 1 to Len( aRegistros )
		IncProc()
		cBody += '<table border=0 WIDTH=100% cellpadding="1">' // MAIN TABLE
		cBody += '<tr>' //CABEÇALHO - ORDENS DE SERVIÇO
		cBody += '<td border="1" width="20%" bgcolor="#C0C0C0" align="center"><b><font face="Arial"    size="2">'+STR0034+'</font></b></td>' //Data Prevista
		cBody += '<td border="1" width="20%" cellspacing="1"   bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">'+STR0020+'</font></b></td>' //Bem
		cBody += '<td border="1" width="20%" cellspacing="1"   bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">'+STR0021+'</font></b></td>' //Nome do Bem
		cBody += '<td border="1" width="20%" cellspacing="1"   bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">'+STR0022+'</font></b></td>' //Número da OS
		cBody += '<td border="1" width="20%" cellspacing="1"   bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">'+STR0023+'</font></b></td>' //Plano
		cBody += '</tr>'

		cBody += '<tr>' //CONTEÚDO - ORDENS DE SERVIÇO
		cBody += '<td border="1" width="20%" bgcolor="#EEEEEE" align="center"><font face="Arial" size="1">'+DToC(aRegistros[i,6])+'</font></td>'
		cBody += '<td border="1" width="20%" bgcolor="#EEEEEE" align="left"><font   face="Arial" size="1">'+aRegistros[i,7]+'</font></td>'
		cBody += '<td border="1" width="20%" bgcolor="#EEEEEE" align="left"><font   face="Arial" size="1">'+aRegistros[i,8]+'</font></td>'
		cBody += '<td border="1" width="20%" bgcolor="#EEEEEE" align="left"><font   face="Arial" size="1">'+aRegistros[i,9]+'</font></td>'
		cBody += '<td border="1" width="20%" bgcolor="#EEEEEE" align="left"><font   face="Arial" size="1">'+aRegistros[i,10]+'</font></td>'
		cBody += '</tr>'

		If (nPosOs := aScan(aMotivosOs,{|x| x[1] == aRegistros[i,9] })) > 0
			aMotivos := aClone(aMotivosOs[nPosOs][2])
			IncProc()
			cBody += '<tr>' //CABEÇALHO - MOTIVOS DE ATRASO DAS O.S.
			cBody += '<td colspan="5">'
			cBody += '<table border=0 align="right" WIDTH=90% cellpadding="1">'
			cBody += '<td border="1" width="10%"   bgcolor="#C0C0C0" align="center"><b><font color="white" face="Arial" size="2">'+STR0025+'</font></b></td>' //Motivo
			cBody += '<td border="1" width="40.5%" bgcolor="#C0C0C0"ç align="left"><b><font   color="white" face="Arial" size="2">'+STR0026+'</font></b></td>' //Descrição
			cBody += '<td border="1" width="10%"   bgcolor="#C0C0C0" align="left"><b><font   color="white" face="Arial" size="2">'+STR0027+'</font></b></td>' //Data Início
			cBody += '<td border="1" width="10%"   bgcolor="#C0C0C0" align="left"><b><font   color="white" face="Arial" size="2">'+STR0028+'</font></b></td>' //Hora Início
			cBody += '<td border="1" width="10%"   bgcolor="#C0C0C0" align="left"><b><font   color="white" face="Arial" size="2">'+STR0029+'</font></b></td>' //Data Fim
			cBody += '<td border="1" width="10%"   bgcolor="#C0C0C0" align="left"><b><font   color="white" face="Arial" size="2">'+STR0030+'</font></b></td>' //Hora Fim
			cBody += '</tr>'
			For n := 1 To Len( aMotivos )
				cBody += '<tr>' //CONTEÚDO - MOTIVOS DE ATRASO DAS O.S.
				cBody += '<td border="1" width="10%"   bgcolor="#FFFAFA" align="center"><font face="Arial" size="1" width="33%">'+aMotivos[n,1]+'</font></td>'
				cBody += '<td border="1" width="40.5%" bgcolor="#FFFAFA" align="left"><font   face="Arial" size="1">'+aMotivos[n,2]+'</font></td>'
				cBody += '<td border="1" width="10%"   bgcolor="#FFFAFA" align="left"><font   face="Arial" size="1">'+DToC(aMotivos[n,3])+'</font></td>'
				cBody += '<td border="1" width="10%"   bgcolor="#FFFAFA" align="left"><font   face="Arial" size="1">'+aMotivos[n,4]+'</font></td>'
				cBody += '<td border="1" width="10%"   bgcolor="#FFFAFA" align="left"><font   face="Arial" size="1">'+DToC(aMotivos[n,5])+'</font></td>'
				cBody += '<td border="1" width="10%"   bgcolor="#FFFAFA" align="left"><font   face="Arial" size="1">'+aMotivos[n,6]+'</font></td>'
				cBody += '</tr>'
			Next
			cBody += '</table>'
			cBody += '</td>'
			cBody += '</tr>'
		Else
			cBody += '<tr>' //CABEÇALHO - SEM MOTIVOS DE ATRASO DAS O.S.
			cBody += '<td colspan="5">'
			cBody += '<table border=0 align="right" WIDTH=90% cellpadding="1">'
			cBody += '<tr>'
			cBody += '<td bgcolor="#C0C0C0" align="left"><b><font color="white" face="Arial" size="2">'+STR0025+'</font></b></td>' //Motivo
			cBody += '</tr>'
			cBody += '<tr>' //CONTEÚDO - SEM MOTIVOS DE ATRASO DAS O.S.
			cBody += '<td bgcolor="#FFFAFA" align="left"><font face="Arial" size="1">'+STR0031+'</font></td>' //"Não foram cadastrados motivo(s) para a Ordem de Serviço."
			cBody += '</tr>'
			cBody += '</table>'
			cBody += '</td>'
			cBody += '</tr>'
		EndIf
		cBody += "</table>"
	Next

	cBody += "</body>"

	If Empty( cEmail )

		If FindFunction( 'NGLogMsg' )
			NGLogMsg( STR0041, , , 'WARN', 'MNTW010' ) // Destinatário do E-mail não informado. # Atenção!
		ElseIf !lNoInter
			MsgAlert( STR0041 ) // Destinatário do E-mail não informado.
		EndIf
		lRet := .F.

	Else

		lRet := NGSendMail( , AllTrim( cEmail ), , , OemToAnsi( cAssunto ),, cBody,,,,,,, 'MNTW010' )

	EndIf

	If lUltimo .And. lRet

		If FindFunction( 'NGLogMsg' )
			NGLogMsg( STR0024, , , 'INFO', 'MNTW010' ) // Workflow enviado com sucesso!
		ElseIf !lNoInter
			MsgInfo( STR0024 ) // Workflow enviado com sucesso!
		EndIf

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW10TRB
Geração de arquivo temporário.

@type function

@source MNTW010.prw

@author Elynton Fellipe Bazzo
@since 22/11/2013

	Nota: Atualizado para utilização da função de envio de workflow
	NGSendMail() pois o antigo processo TMailMessage() estava gerando
	problemas recorrentes.
	@author Rodrigo Luan Backes
	@since 05/09/2016
	S.S.: 028780

@sample MNTW10TRB()

@return Lógico
/*/
//---------------------------------------------------------------------
Static Function MNTW10TRB(oTmpTbl2)

	Local aDBF2, cInd

	//criação arquivo temporário
	//----------------------------------------
	aDBF2 :={{"DTINIC" ,"D" ,08 ,0 },;
			  {"ORDEM"  ,"C" ,06 ,0 },;
			  {"MOTIVO" ,"C" ,04 ,0 },;
	          {"DESCRI" ,"C" ,40 ,0 },;
	          {"HRINIC" ,"C" ,05 ,0 },;
	          {"DTFIM"  ,"D" ,08 ,0 },;
	          {"HRFIM"  ,"C" ,05 ,0 }}

	aInd	 := {"ORDEM","DTINIC","HRINIC"}
	oTmpTbl2 := FWTemporaryTable():New( cTrb2, aDBF2 )
	oTmpTbl2:AddIndex( "Ind01" , aInd )
	oTmpTbl2:Create()

	//GERACAO PARA ARQUIVO DE ORDEM DE SERVICO
	dbSelectArea("STJ")
	SET FILTER To STJ->TJ_FILIAL == xFilial("STJ") .And. ;
					  STJ->TJ_DTMPFIM <= dDataBase .And. !Empty(STJ->TJ_DTMPFIM) .And. STJ->TJ_TERMINO == "N" .And. STJ->TJ_SITUACA == "L"
	dbGoTop()
	While !EoF()
		//LEITURA DOS MOTIVOS DE ATRASOS DAS ORDENS DE SERVICO.
		dbSelectArea( "TPL" )//Motivos Atraso OS
		dbSetOrder(1)//TPL_FILIAL+TPL_ORDEM+TPL_CODMOT
		If dbSeek( xFilial("TPL")+STJ->TJ_ORDEM )
			While TPL->TPL_ORDEM == STJ->TJ_ORDEM
				dbSelectArea( "TPJ" )
				dbSetOrder( 01 )
				If dbSeek(xFilial( "TPJ" )+TPL->TPL_CODMOT)
					cDescMot := TPJ->TPJ_DESMOT
				EndIf
				dbSelectArea( cTrb2 )
				RecLock( cTrb2, .T. )
				(cTrb2)->ORDEM  := TPL->TPL_ORDEM
				(cTrb2)->MOTIVO := TPL->TPL_CODMOT
				(cTrb2)->DESCRI := cDescMot
				(cTrb2)->DTINIC := TPL->TPL_DTINIC
				(cTrb2)->HRINIC := TPL->TPL_HOINIC
				(cTrb2)->DTFIM  := TPL->TPL_DTFIM
				(cTrb2)->HRFIM  := TPL->TPL_HOFIM
				MsUnlock( cTrb2 )
				dbSelectArea( "TPL" )
				dbSkip()
			End
		EndIf

		dbSelectArea("STJ")
		dbSkip()
	End

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Execução de Parâmetros na Definição do Schedule
@type static

@author Alexandre Santos
@since 04/07/2018

@sample SchedDef()

@param
@return Array, Conteudo com as definições de parâmetros para WF
/*/
//---------------------------------------------------------------------
Static Function SchedDef()
Return { 'P', 'PARAMDEF', '', {}, 'Param' }