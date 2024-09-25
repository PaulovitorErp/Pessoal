#INCLUDE "MNTW215.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW215
Programa para exportar dados para gerar workflow com alerta de
Ordem de servico atrasada.

@author Ricardo Dal Ponte
@since 02/10/2006
/*/
//---------------------------------------------------------------------
Function MNTW215(_cPlano,_aOrdem)

	Local aNGBEGINPRM 	:= NGBEGINPRM()
	Local aOldArea   	:= GetArea()

	Private AVETINR  	:= {}
	Private oTmpTRB215
	Private cTRB215		:= ""

	MNTW215TRB(_cPlano,_aOrdem)

	//------------------------------------------------
	//Retorna conteudo de variaveis padroes
	//------------------------------------------------
	NGRETURNPRM(aNGBEGINPRM)

	RestArea(aOldArea)

Return  .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW215TRB
GERACAO DE ARQUIVO TEMPORARIO

@author Ricardo Dal Ponte
@since 04/09/2006
/*/
//---------------------------------------------------------------------
Function MNTW215TRB(_cPlano,_aOrdem)

	Local aDBF 		:= {}
	Local cIndR010	:= ""
	Local _cWhile 	:= '.T.'
	Local nI		:= 0

	//----------------------------------------
	//Criacao arquivo temporario
	//----------------------------------------
	aAdd(aDBF, {"ORDEM"  ,"C",06,0})
	aAdd(aDBF, {"PLANO"  ,"C",06,0})
	aAdd(aDBF, {"SERVICO","C",06,0})
	aAdd(aDBF, {"NOMSERV","C",40,0})
	aAdd(aDBF, {"CODBEM" ,"C",16,0})
	aAdd(aDBF, {"NOMBEM" ,"C",40,0})
	aAdd(aDBF, {"CCUSTO" ,"C",09,0})
	aAdd(aDBF, {"NCUSTO" ,"C",40,0})
	aAdd(aDBF, {"PRIORID","C",03,0})
	aAdd(aDBF, {"DTPREV" ,"D",08,0})
	aAdd(aDBF, {"HRPREV" ,"C",05,0})

	//Variavel recebe GetNextAlias()
	cTRB215 := GetNextAlias()

	//Intancia classe FWTemporaryTable
	oTmpTRB215 := FWTemporaryTable():New( cTRB215, aDBF )
	//Cria indices
	oTmpTRB215:AddIndex( "Ind01" , {"PLANO","ORDEM"} )
	//Cria a tabela temporaria
	oTmpTRB215:Create()

	dbSelectArea("STJ")
	If ValType(_cPlano) != "U"
		dbSetOrder(03)
		dbSeek(xFilial("STJ")+_cPlano)
		_cWhile := 'STJ->TJ_FILIAL == xFilial("STJ") .And. STJ->TJ_PLANO == "' + _cPlano + '"'
		_aOrdem := {'0'}
	EndIf

	For nI := 1 to Len(_aOrdem)
		If ValType(_cPlano) == "U" //Busca a OS
			dbSelectArea("STJ")
			dbSetOrder(01)
			dbSeek(xFilial("STJ")+_aOrdem[nI])
			_cWhile := '.T.'
		EndIf
		While &(_cWhile)
			If STJ->TJ_SITUACA == "L"
				RecLock(cTRB215,.T.)
				(cTRB215)->PLANO   := STJ->TJ_PLANO
				(cTRB215)->ORDEM   := STJ->TJ_ORDEM
				(cTRB215)->CODBEM  := STJ->TJ_CODBEM
				(cTRB215)->NOMBEM  := If(STJ->TJ_TIPOOS = "B",NGSEEK("ST9",STJ->TJ_CODBEM,1,"T9_NOME"),;
										  NGSEEK("TAF","X2"+Substr(STJ->TJ_CODBEM,1,3),7,"TAF_NOMNIV"))
				(cTRB215)->SERVICO := STJ->TJ_SERVICO
				(cTRB215)->NOMSERV := NGSEEK("ST4",STJ->TJ_SERVICO,1,'T4_NOME')
				(cTRB215)->CCUSTO  := STJ->TJ_CCUSTO
				(cTRB215)->NCUSTO  := NGSEEK("CTT",STJ->TJ_CCUSTO,1,'CTT_DESC01')
				(cTRB215)->PRIORID := STJ->TJ_PRIORID
				(cTRB215)->DTPREV  := STJ->TJ_DTMPINI
				(cTRB215)->HRPREV  := STJ->TJ_HOMPINI
				(cTRB215)->(MsUnLock())
			EndIf
			If ValType(_cPlano) != "U"
				dbSelectArea("STJ")
				dbSkip()
			Else
				_cWhile := '.F.'
			EndIf
		End
	Next

	MNTW215F()

	//Deleta o arquivo temporario fisicamente
	oTmpTRB215:Delete()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW215F
Programa para exportar dados para gerar workflow com alerta de
Ordem de servico atrasada.

@author Ricardo Dal Ponte
@since 04/09/2006
/*/
//---------------------------------------------------------------------
Function MNTW215F()

	Local lRetu := .T.
	Local aRegistros := {}

	dbSelectArea(cTRB215)
	dbGotop()
	dbSetOrder(01)
	ProcRegua(LastRec())

	nRegs := 0
	While !Eof()
	   IncProc()

	   aADD(aRegistros,{(cTRB215)->ORDEM,;
						(cTRB215)->PLANO,;
	                    (cTRB215)->CODBEM,;
	                    (cTRB215)->NOMBEM,;
	                    (cTRB215)->SERVICO,;
	                    (cTRB215)->NOMSERV,;
	                    (cTRB215)->CCUSTO,;
	                    (cTRB215)->NCUSTO,;
	                    (cTRB215)->PRIORID,;
	                    (cTRB215)->DTPREV,;
	                    (cTRB215)->HRPREV})

	  dbSelectArea(cTRB215)
	  dbSkip()
	End

	//envio de workflow menor que 1000 registros ou a diferenca que ultrapassou a ultima milhar
	If Len(aRegistros) > 0
		MNTW10SEND(aRegistros)
	EndIf

Return lRetu

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW10SEND
Funcao de envio do workflow

@author Evaldo Cevinscki
@since 12/04/2010
/*/
//---------------------------------------------------------------------
Static Function MNTW10SEND(aRegistros)

	Local cSubject 	:= DToC(MsDate())+STR0013 //" - O.S. Liberada"
	Local cTo		:= NgEmailWF("1","MNTW215") // parâmetro '1-oficina'
	Local nCont 	:= 1 //Variável que controla a quantidade de linhas do workflow.
	Local nI		:= 1 //Variável que controla a quantidade de registros.
	Local lQuebra	:= .F.
	Local lMNTW2151	:= ExistBlock("MNTW2151")

	If Empty(cTo)
		Return .T.
	EndIf

	While nI <= Len(aRegistros)

		cBody := '<html>'
		cBody += '<head>'
		cBody += '<meta http-equiv="Content-Language" content="pt-br">'
		cBody += '<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
		cBody += '<meta name="GENERATOR" content="Microsoft FrontPage 4.0">'
		cBody += '<meta name="ProgId" content="FrontPage.Editor.Document">'
		cBody += '<title>Aviso sobre Solicitação de Serviços</title>'
		cBody += '</head>'
		cBody += '<body bgcolor="#FFFFFF">'
		cBody += '<noscript><b><U><font face="Arial" size=2 color="#FF0000"></font></b>'
		cBody += '</noscript>'
		cBody += '<p><b><font face="Arial"> '+STR0012+'</font></b></p>' //"O.S. Liberada"
		cBody += '<table border=0 WIDTH=100% cellpadding="1">'
		cBody += '<tr>'
		cBody += '   <td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">'+STR0014+'</font></b></td>' //"Ordem"
		cBody += '   <td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">'+STR0022+'</font></b></td>' //"Plano"
		cBody += '   <td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">'+STR0015+'</font></b></td>' //"Bem"
		cBody += '   <td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">'+STR0016+'</font></b></td>' //"Descrição"
		cBody += '   <td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">'+STR0023+'</font></b></td>' //"Serviço"
		cBody += '   <td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">'+STR0016+'</font></b></td>' //"Descrição"
		cBody += '   <td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">'+STR0017+'</font></b></td>' //"Centro de Custo"
		cBody += '   <td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">'+STR0016+'</font></b></td>' //"Descrição"
		cBody += '   <td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">'+STR0024+'</font></b></td>' //"Prioridade"
		cBody += '   <td bgcolor="#C0C0C0" align="center"><b><font face="Arial" size="2">'+STR0018+'</font></b></td>' //"Data Prev. Início"
		cBody += '   <td bgcolor="#C0C0C0" align="center"><b><font face="Arial" size="2">'+STR0019+'</font></b></td>' //"Hora Prev. Início"
		ProcRegua(Len(aRegistros))

		lQuebra := .F.
		While nI <= Len(aRegistros) .And. !lQuebra

			IncProc()
			cBody += '<tr>'
			cBody += '   <td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">'+aRegistros[nI,1]+'</font></td>'
			cBody += '   <td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">'+aRegistros[nI,2]+'</font></td>'
			cBody += '   <td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">'+aRegistros[nI,3]+'</font></td>'
			cBody += '   <td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">'+aRegistros[nI,4]+'</font></td>'
			cBody += '   <td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">'+aRegistros[nI,5]+'</font></td>'
			cBody += '   <td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">'+aRegistros[nI,6]+'</font></td>'
			cBody += '   <td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">'+aRegistros[nI,7]+'</font></td>'
			cBody += '   <td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">'+aRegistros[nI,8]+'</font></td>'
			cBody += '   <td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">'+aRegistros[nI,9]+'</font></td>'
			cBody += '   <td bgcolor="#EEEEEE" align="center"><font face="Arial" size="1">'+DToC(aRegistros[nI,10])+'</font></td>'
			cBody += '   <td bgcolor="#EEEEEE" align="center"><font face="Arial" size="1">'+cValToChar(aRegistros[nI,11])+'</font></td>'
			cBody += '</tr>'

			If nCont == 950 .Or. nI == Len(aRegistros) //quantidade de linhas do array suportada até "quebrar" o workflow em partes ou se for o ultimo registro.

				cBody += '</tr>'
				cBody += '</table>'
				cBody += '<br><hr>'
				cBody += '</body>'
				cBody += '</html>'

				If lMNTW2151
					cBody := ExecBlock("MNTW2151",.F.,.F.,{cBody}) //altera o layout do WF
				EndIf

				//Função de envio de WorkFlow "Solicitacao de Servico - "
				NGSendMail( , cTo+Chr(59) , , , OemToAnsi(cSubject) , , cBody )//"Solicitacao de Servico - "

				nCont := 0
				lQuebra := .T.

			EndIf
			nI++
			nCont++
		End
	End

Return .T.
