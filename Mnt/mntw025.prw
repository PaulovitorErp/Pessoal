#INCLUDE "mntw025.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW025
Programa para enviar workflow de aviso de inclusao de
ss para o responsavel pelo servico.
@type function
@source MNTW025.prw
@author Ricardo Dal Ponte
@since 08/12/2006
@sample MNTW025()
@return Lógico
/*/
//---------------------------------------------------------------------
Function MNTW025(cCDSS, cCCEmp, cCCFil, cTrbW025)

	Local oTmpTRB

	Private cSS			:= cCDSS
	Private dDtProxMan
	Private nQtdAVcto	:= 0
	Private cEMAIL_All	:= ""
	Private cTRB        := IIf(ValType(cTrbW025) <> "U", cTrbW025, GetNextAlias())

	If !Empty(cSS)
		cCodEmp := cCCEmp
		cCodFil := cCCFil
	EndIf

	MNTW025Tmp(@cTRB, @oTmpTRB)
	Processa({ || MNTW025TRB()})

	dbSelectArea(cTRB)
	DbGoTop()

	If RecCount() <= 0
		//Deleta o arquivo temporario fisicamente
		oTmpTRB:Delete()
		Return .F.
	EndIf

	Processa({ || MNTW025F()}) //WorkFlow

	//Deleta o arquivo temporario fisicamente
	oTmpTRB:Delete()
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW025TRB
GERACAO DE ARQUIVO TEMPORARIO

@type function

@source MNTW025.prw

@author Ricardo Dal Ponte
@since 24/11/2006

@sample MNTW025TRB()

@return Lógico
/*/
//---------------------------------------------------------------------
Function MNTW025TRB()

	Local c				:= 0
	Local c1			:= 0
	Local aEMAILS		:= {}
	Local aEMAIL_All	:= {}
	Local aMailTSK		:= {}
	Local cMailTSK		:= ""
	Local cCdResp		:= ""
	Local cNmServ		:= ""
	Local cCodUser		:= ""
	Private cEMAIL1		:= ""
	Private cEMAIL2		:= ""

	dbSelectArea("TQB")
	dbSetOrder(1)
	If dbSeek(xFilial("TQB")+cSS)

		dbSelectArea("TQ3")
		dbSetOrder(1)
		If dbSeek(xFilial("TQ3")+TQB->TQB_CDSERV)
			cCdResp := TQ3->TQ3_CDRESP
			cNmServ := TQ3->TQ3_NMSERV
		EndIf

		PswOrder(2)
		//Usuário responsável pelo Tipo de Serviço
		If PswSeek(cCdResp)
			cCodUser := PswRet(1)[1][1]
			cEMAIL1 := AllTrim(SubStr(UsrRetMail(cCodUser), 1, 50))
		EndIf

		PswOrder(1)
		//Usuário no qual está acessando o sistema
		If PswSeek(TQB->TQB_CDSOLI)
			cCodUser := PswRet(1)[1][1]
			cEMAIL2 := AllTrim(SubStr(UsrRetMail(cCodUser), 1, 50))
		EndIf

		dbSelectArea(cTRB)
		RecLock((cTRB),.T.)
		(cTRB)->SOLICI := TQB->TQB_SOLICI
		(cTRB)->DTABER := TQB->TQB_DTABER
		(cTRB)->HRABER := TQB->TQB_HOABER
		(cTRB)->CDSERV := TQB->TQB_CDSERV
		(cTRB)->NMSERV := cNmServ
		(cTRB)->CDRESP := cCdResp
		(cTRB)->CDSOLI := TQB->TQB_CDSOLI
		(cTRB)->NMSOLI := PadR(UsrRetName(cCodUser),40)
		(cTRB)->CODMSS := TQB->TQB_CODMSS
		(cTRB)->DESMSS := MSMM((cTRB)->CODMSS,80)
		(cTRB)->TIPOSS := TQB->TQB_TIPOSS
		(cTRB)-> (MsUnlock())

		If ExistBlock("MNTW0251")
			//Variaveis que se tem acesso no Ponto de Entrada:
			//(cTRB)->SOLICI  - Número da Solicitação de Serviço (SS)
			//(cTRB)->DTABER  - Data de Abertura
			//(cTRB)->HRABER  - Hora de Abertura
			//(cTRB)->CDSERV  - Código do Serviço
			//(cTRB)->NMSERV  - Nome do Serviço
			//(cTRB)->CDRESP  - Código do Usuário Responsável
			//cEMAIL1      - E-mail do Usuário Responsável
			//(cTRB)->CDSOLI  - Código do Usuário Solicitante
			//(cTRB)->NMSOLI  - Nome do Usuário Solicitante
			//cEMAIL2      - E-mail do Usuário Solicitante
			//(cTRB)->DESMSS  - Solicitação (Descrição)
			//(cTRB)->TIPOSS  - Tipo da SS
			aEMAILS := ACLONE(ExecBlock("MNTW0251",.F.,.F.))
		EndIf

		cEMAIL_All := IIf(!(AllTrim(cEMAIL1) $ AllTrim(cEMAIL2)),AllTrim(cEMAIL1) +";"+ AllTrim(cEMAIL2),AllTrim(cEMAIL1))

		If Len(aEMAILS) > 0
			For c := 1 To Len(aEMAILS)
				cEMAIL_All += ";"+aEMAILS[c]
			Next
		EndIf

		cMailTSK	:= NgEmailWF("1","MNTW025")

		aEMAIL_All	:= StrTokArr( cEMAIL_All, ";" )
		aMailTSK	:= StrTokArr( cMailTSK  , ";" )

		For c1 := 1 To Len(aMailTSK)
			If aScan(aEMAIL_All,{|x| x == aMailTSK[c1] }) == 0
				cEMAIL_All	+= ";" + AllTrim(aMailTSK[c1])
			EndIf
		Next c1

	EndIf

Return .T.

//--------------------------------------------------------------------------------------------------
/*/{Proteus.doc} MNTW025F
Programa para exportar dados para gerar workflow de inclusão de S.S.
@type function

@author Alexandre Santos
@since  28/01/2019

@sample MNTW025F()

@param
@return
/*/
//------------------------------------------------------------------------------------------------
Static Function MNTW025F()

	Local aArea	   := GetArea()
	Local cSubject := OemToAnsi( dToC( MsDate() )+ ' - ' + STR0007 + ' - ' + STR0008 + ' ' + cSS )

	If !Empty( StrTran( cEMAIL_All, ';', '' ) )

		dbSelectArea( cTRB )
		dbSetOrder( 1 )

		If (cTRB)->( !EoF() )

			If FindFunction( 'NGUseTWF' ) .And. NGUseTWF( 'MNTW025' )[1]

				aFields := {;
								{ 'strTitle'        , STR0011                               },; // Solicitação de Serviços - Aviso de Inclusão
								{ 'strSubTitle'     , STR0007 + ' - ' + STR0008 + ' ' + cSS },; // Abertura de Solicitação de Serviço - S.S. 00000
								{ 'head.strNumSol'  , STR0002                               },; // Solicitação
								{ 'head.strDtAber'  , STR0003                               },; // Data
								{ 'head.strHrAber'  , STR0001                               },; // Hora
								{ 'head.strBemLoc'  , STR0014                               },; // Bem/Localização
								{ 'head.strService' , STR0004                               },; // Serviço
								{ 'head.strSolicit' , STR0005                               },; // Solicitante
								{ 'head0.strDescSS' , STR0006                               },; // Detalhes da Solicitação
								{ 'cols.strNumSol'  , (cTRB)->SOLICI                        },;
								{ 'cols.strDtAber'  , dToC( (cTRB)->DTABER )                },;
								{ 'cols.strHrAber'  , (cTRB)->HRABER                        },;
								{ 'cols.strBemLoc'  , MntwBemLoc( (cTRB)->TIPOSS )          },;
								{ 'cols.strSolicit' , (cTRB)->NMSOLI                        },;
								{ 'cols0.strDescSS' , (cTRB)->DESMSS                        },;
								{ 'cols.strService' , (cTRB)->NMSERV                        };
							}

				// Função para criação do objeto da classe TWFProcess responsavel pelo envio de workflows.
				aProcess := NGBuildTWF( cEMAIL_All, 'MNTW025',  cSubject, 'MNTW025', aFields )

				// Consiste se foi possivel a inicialização do objeto TWFProcess.
				If aProcess[1]

					// Função que realiza o envio do workflow conforme definições do objeto passado por parãmetro.
					NGSendTWF( aProcess[2] )

				EndIf

			Else

				// Estrutura HTML do e-mail
				cMailMsg := '<html>'
				cMailMsg += 	'<head>'
				cMailMsg += 		'<meta http-equiv="Content-Language" content="pt-br">'
				cMailMsg += 		'<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'
				cMailMsg += 		'<title>' + STR0011 + '</title>' // Solicitação de Serviços - Aviso de Inclusão
				cMailMsg += 	'</head>'
				cMailMsg += 	'<body bgcolor="#FFFFFF">'
				cMailMsg += 		'<p><b><font face="Arial">' + STR0007 + " - " + STR0008 + " " + cSS + '</font></b></p>' //"Abertura de Solicitação de Serviço"##"S.S."
				cMailMsg += 		'<div align="left">'
				cMailMsg += 			'<table border=0 WIDTH="500" cellpadding="2">'
				cMailMsg += 				'<tr>'
				cMailMsg += 					'<td bgcolor="#C0C0C0" align="left" ><b><font face="Arial" size="2">' + STR0002 + '</font></b></td>' //"Número S.S."
				cMailMsg += 					'<td bgcolor="#C0C0C0" align="left" ><b><font face="Arial" size="2">' + STR0003 + '</font></b></td>' //"Dt. Abertura"
				cMailMsg += 					'<td bgcolor="#C0C0C0" align="left" ><b><font face="Arial" size="2">' + STR0001 + '</font></b></td>' //"Hora"
				cMailMsg += 					'<td bgcolor="#C0C0C0" align="left" ><b><font face="Arial" size="2">' + STR0014 + '</font></b></td>' //"Bem/Localização"
				cMailMsg += 					'<td bgcolor="#C0C0C0" align="left" ><b><font face="Arial" size="2">' + STR0004 + '</font></b></td>' //"Serviço"
				cMailMsg += 					'<td bgcolor="#C0C0C0" align="left" ><b><font face="Arial" size="2">' + STR0005 + '</font></b></td>' //"Solicitante"
				cMailMsg += 				'</tr>'
				cMailMsg += 				'<tr>'
				cMailMsg += 					'<td bgcolor="#EEEEEE" align="left" ><font face="Arial" size="1">' + (cTRB)->SOLICI + '</font></td>' //"Solicitação"
				cMailMsg += 					'<td bgcolor="#EEEEEE" align="left" ><font face="Arial" size="1">' + dToC( (cTRB)->DTABER ) + '</font></td>' //"Dt. Abertura"
				cMailMsg += 					'<td bgcolor="#EEEEEE" align="left" ><font face="Arial" size="1">' + (cTRB)->HRABER + '</font></td>' //"Hora Abertura"
				cMailMsg += 					'<td bgcolor="#EEEEEE" align="left" ><font face="Arial" size="1">' + MNTWBEMLOC( (cTRB)->TIPOSS ) + '</font></td>' //"Nome do Bem"
				cMailMsg += 					'<td bgcolor="#EEEEEE" align="left" ><font face="Arial" size="1">' + (cTRB)->NMSERV + '</font></td>' //"Nome Serviço"
				cMailMsg += 					'<td bgcolor="#EEEEEE" align="left" ><font face="Arial" size="1">' + (cTRB)->NMSOLI + '</font></td>' //"Nome Solicitante"
				cMailMsg += 				'</tr>'
				cMailMsg += 				'<tr>'
				cMailMsg += 					'<td bgcolor="#DDDDDD" align="left" width="100%" colspan="6"><b><font face="Arial" size="2">' + STR0006 + '</b><br>' //"Solicitação"
				cMailMsg += 				'</tr>'
				cMailMsg += 				'<tr>'
				cMailMsg += 					'<td bgcolor="#EEEEEE" align="left" width="100%" colspan="6"><font face="Arial" size="1">' + (cTRB)->DESMSS + '<br>' //"Descrição SS"
				cMailMsg += 				'</tr>'
				cMailMsg += 			'</table>'
				cMailMsg += 		'</div>'
				cMailMsg += 	'</body>'
				cMailMsg += '</html>'

				NGSendMail( , AllTrim(cEMAIL_All) + Chr(59) , , , cSubject, , cMailMsg )	

			EndIf

		EndIf

	Else

		If !IsBlind()

			// Envio do workflow cancelado ## Destinatário para o envio do workflow não foi informado.
			Help( '', 1, STR0012, , STR0013, 2, 0 )

		Else

			// Destinatário para o envio do workflow não foi informado.
			NGWFLog( STR0013, .T. )

		EndIf

	EndIf

	RestArea( aArea )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW025Tmp
Cria tabela temporária
@author bruno.souza
@since 23/02/2017
@version undefined
@param cTrbW025, characters, Alias da tabela temporária
@param oTmpW025, object, Instância da classe FwTemporary Table
@type function
/*/
//---------------------------------------------------------------------
Function MNTW025Tmp(cTrbW025, oTmpW025)

	Local aDBF := {}

	//Numero SS / Data abertura / tipo serviço / Solicitante e descrição do serviço.
	aDBF := {	{"SOLICI" ,"C",TAMSX3("TQB_SOLICI")[1],0},;
				{"DTABER" ,"D",8,0},;
				{"HRABER" ,"C",5,0},;
				{"CDSERV" ,"C",TAMSX3("TQB_CDSERV")[1],0},;
				{"NMSERV" ,"C",25,0},;
				{"CDSOLI" ,"C",TAMSX3("TQB_CDSOLI")[1],0},;
				{"NMSOLI" ,"C",25,0},;
				{"CDRESP" ,"C",Len(TQ3->TQ3_CDRESP),0},;
				{"CODMSS" ,"C",06,0},;
				{"DESMSS" ,"M",80,0},;
				{"TIPOSS" ,"C",TAMSX3("TQB_TIPOSS")[1],0}}

	//Intancia classe FWTemporaryTable
	oTmpW025 := FWTemporaryTable():New( cTrbW025, aDBF )
	//Cria indices
	oTmpW025:AddIndex( "Ind01" , {"SOLICI"} )
	//Cria a tabela temporaria
	oTmpW025:Create()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTWBEMLOC
Descrição do Bem/veículo ou da Localização.

@param cTIPOS - Tipo da SS é de Localização ou Bem/Veículo

@author Marcos Wagner Junior
@since 25/07/2008
@return Caracter - Descrição da Localização ou Bem/Veículo
/*/
//---------------------------------------------------------------------
Static Function MNTWBEMLOC(cTIPOS)

	Local cNOBEMTJ := Space(30)
	Local aOldArea := GetArea()
	Local cEstrut

	If !Empty(TQB->TQB_CODBEM)
		If cTIPOS == "B"
			If ExistCpo("ST9",TQB->TQB_CODBEM)
				dbSelectArea("TAF")
				dbSetOrder(6)
				If dbSeek(xFilial("TAF")+"X"+"1"+TQB->TQB_CODBEM)
					cEstrut := NGLocComp(TQB->TQB_CODBEM,"1")
					cNOBEMTJ := AllTrim(TQB->TQB_CODBEM) + ' - ' + AllTrim(cEstrut)
				Else
					cNOBEMTJ := AllTrim(TQB->TQB_CODBEM) + ' - ' + AllTrim(NGSEEK("ST9",TQB->TQB_CODBEM,1,"T9_NOME"))
				EndIf
			EndIf
		Else
			dbSelectArea("TAF")
			dbSetOrder(7)
			If dbSeek(xFilial("TAF")+"X2"+Substr(TQB->TQB_CODBEM,1,3))
				cEstrut := NGLocComp(Substr(TQB->TQB_CODBEM,1,3),"2")
				cNOBEMTJ := AllTrim(TQB->TQB_CODBEM) + " - " + AllTrim(cEstrut)
			EndIf
		EndIf
	EndIf

	RestArea(aOldArea)

Return cNOBEMTJ
