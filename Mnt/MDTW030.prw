#INCLUDE "MDTW030.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "Ap5Mail.ch"

#DEFINE _nVERSAO 1 //Versao do fonte

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTW030
Workflow de Comunicação com o Sesmt

@return

@param cTable Caracter Tabela Inclusa
@param cChkCod Caracter Codigo Incluso
@param nOperation Numérico, informa qual é o tipo de operação realizada.

@sample MDTW030( 'SRJ' , '00001', 3 )

@author Jackson Machado
@since 01/04/2016
/*/
//---------------------------------------------------------------------
Function MDTW030( cTable , cChkCod, nOperation )

	Processa( { | | fProcessWF( cTable , cChkCod, nOperation ) } )//Processa Workflow

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fProcessWF
Realiza o processamento e envio do WorkFlow

@return lRet Logico  Indica se processou o WF

@param cTable Caracter Indica a Tabela que foi inclusa
@param cChkCod Caracter Indica o Codigo que foi incluso

@sample fProcessWF( 'SRJ' , '00001' )

@author Jackson Machado
@since 01/04/2016
/*/
//---------------------------------------------------------------------
Static Function fProcessWF( cTable , cChkCod, nOperation )

    Local lRet		:= .T.

	//Variaveis de email
	Local cBody		:= ""
	Local cServer   := AllTrim( GetMV( "MV_RELSERV" , , " " ) )
	Local cAccount  := AllTrim( GetMV( "MV_RELACNT" , , " " ) )
	Local cPassword := AllTrim( GetMV( "MV_RELPSW"  , , " " ) )
	Local cUserAut  := AllTrim( GetMV( "MV_RELAUSR" , , cAccount ) )//Usuário para Autenticação no Servidor de Email
	Local cPassAut  := AllTrim( GetMV( "MV_RELAPSW" , , cPassword ) )//Senha para Autenticação no Servidor de Email
	Local lSmtpAuth := GetMv( "MV_RELAUTH" , , .F. )
	Local cFrom     := cAccount
	Local lComSESMT := SuperGetMv( "MV_NG2COSE" , .F. , "2" ) == "1"
	Local lOk       := .T.
	Local lAutOk    := .F.
	Local cEmails	:= ""
	Local cAssunto	:= ""
	Local aUsuario  := {}
	Local cDescric  := ""

	//Codigo do processo
	Local cCodProcesso 	:= "WMDT030"
	Local oProcess

	//Área atual
	Local aArea 		:= GetArea()

	Default cTable 		:= ""
	Default cChkCod		:= ""

	If lComSESMT//Verifica se deve fazer a comunicação com o SESMT
		//Verifica os componentes do SESMT que devem receber o e-mail
		cEmails := SuperGetMv( "MV_NG2WFSE" )//Caso tenha informado os e-mails de SESMT no parâmetro usa o parâmetro

		If Empty( cEmails )
			dbSelectArea( "TMK" )
			dbSetOrder( 1 )

			If dbSeek( xFilial( "TMK" ) )

				While TMK->( !EoF() ) .And. xFilial( "TMK" ) == TMK->TMK_FILIAL

					If TMK->TMK_SESMT == "1" .And. !Empty( TMK->TMK_EMAIL )
						cEmails += AllTrim( TMK->TMK_EMAIL ) + ";"
					EndIf

					TMK->( dbSkip() )
				End

			EndIf

		EndIf

		If !Empty( cEmails ) .And. fChkEnv( cTable , cChkCod )

			// Verifica se existe o SMTP Server
			If 	Empty(cServer) .Or. ( ( Empty(cAccount) .Or. Empty(cPassword) ) .And. lSmtpAuth )
				ShowHelpDlg( STR0001 , ; //"ATENÇÃO"
								{ STR0002 } , 2 , ; //"Configurações de envio de WF incorretas."
								{ STR0003 } , 2 ) //"Verificar parâmetros MV_RELSERV, MV_RELACNT e MV_RELPSW."
				lRet := .F.
			EndIf

			If lRet
				PswOrder(1)
				PswSeek(__CUSERID,.T.)
				aUsuario := PswRet(1)

				dbSelectArea( cTable )
				dbSetOrder( 1 )
				dbSeek( xFilial( cTable ) + cChkCod )

				// Monta estrutura do corpo da mensagem
				If cTable == "CTT"
					cAssunto  := IIf( nOperation == 3, STR0004, IIf( nOperation == 4, STR0025, STR0026 )) //"Inclusão / Alteração / Exclusão de Centro de Custo"
					cValueCad := AllTrim( cChkCod ) + " - " + AllTrim( M->CTT_DESC01 )
					cDescric  := STR0005 + DTOC(MsDate())+ IIf( nOperation == 3, STR0006, IIf( nOperation == 4, STR0027, STR0028 )) + cValueCad + "." //"Na data de "###" foi cadastrado um novo Centro de Custo no sistema: "
				ElseIf cTable == "SQ3"
					cAssunto  := STR0007 //"Inclusão de novo Cargo"
					cValueCad := AllTrim( cChkCod ) + " - " + AllTrim( SQ3->Q3_DESCSUM )
					cDescric  := STR0005 + DTOC(MsDate())+ STR0008 + cValueCad + "." //"Na data de "###" foi cadastrado um novo Cargo no sistema: "
				ElseIf cTable == "SQG"
					cAssunto  := STR0009 //"Inclusão de novo Currículo para o Candidato"
					cValueCad := cChkCod
					cDescric  := STR0005 + DTOC(MsDate())+ STR0010 + AllTrim( TM0->TM0_NOMFIC ) + STR0011 + AllTrim( cValueCad ) + STR0012 + AllTrim( TM0->TM0_NUMFIC ) + "." //"Na data de "###" foi adicionado um novo Currículo para o candidato "###", inscrito no C.P.F. "###" e com Ficha Médica de número "
				ElseIf cTable == "SQA"
					dbSelectArea( "SQ3" )
					dbSetOrder( 1 )
					dbSeek( xFilial( "SQ3" ) + SQA->QA_CARGO )
					cAssunto  := STR0013 //"Inclusão de novo Descritivo de Cargo"
					cValueCad := AllTrim( SQA->QA_CARGO ) + " - " + AllTrim( SQ3->Q3_DESCSUM )
					cDescric  := STR0005 + DTOC(MsDate())+ STR0014 + cValueCad + "." //"Na data de "###" foi cadastrado um novo Descritivo de Cargo para o Cargo no sistema: "
				ElseIf cTable == "SQB"
					cAssunto  := STR0015 //"Inclusão de novo Departamento"
					cValueCad := AllTrim( SQB->QB_DEPTO ) + " - " + AllTrim( SQB->QB_DESCRIC )
					cDescric  := STR0005 + DTOC(MsDate())+ STR0016 + cValueCad + "." //"Na data de "###" foi cadastrado um novo Departamento no sistema: "
				ElseIf cTable == "SRJ"
					cAssunto  := STR0017 //"Inclusão de nova Função"
					cValueCad := AllTrim( SRJ->RJ_FUNCAO ) + " - " + AllTrim( SRJ->RJ_DESC )
					cDescric  := STR0005 + DTOC(MsDate())+ STR0018 + cValueCad + "." //"Na data de "###" foi cadastrada uma nova Função no sistema: "
				EndIf

				cBody := "<html>"
				cBody += "<head>"
				cBody += "<meta http-equiv='Content-Language' content='pt-br'>"
				cBody += "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>"
				cBody += "<title>" + cAssunto + "</title>"
				cBody += "</head>"
				cBody += "<body bgcolor='#FFFFFF'>"
				cBody += "<p><b><font face='Arial'>" + cAssunto + "</font></b></p>"
				cBody += "<p>" + STR0019 + "</p>" //"Prezado(s),"
				cBody += "<p>" + cDescric + "</p>"
				cBody += "<p>" + STR0020 + "</p>" //"Favor tomar as devidas providências para avaliação e efetuar os cadastros necessários."
				cBody += "<br><hr>"
				cBody += "</body>"
				cBody += "</html>"

				CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOk

					If !lAutOk

						If ( lSmtpAuth )
							lAutOk := MailAuth(cUserAut,cPassAut)
						Else
							lAutOk := .T.
						EndIf

					EndIf

					If lOk .And. lAutOk
						SEND MAIL FROM cFrom TO cEmails SUBJECT AllTrim( cAssunto ) BODY cBody Result lOk

						If lOk
							MsgInfo( STR0021 ) //"E-mail enviado com sucesso para o SESMT!"
						Else
							GET MAIL ERROR cErro
							MsgStop( STR0022 + Chr( 13 ) + Chr( 10 ) + cErro , STR0023 ) //"Não foi possível enviar o Email."###"AVISO"
							lRet := .F.
						EndIf

					Else
						GET MAIL ERROR cErro
						MsgStop( STR0024 + Chr( 13 ) + Chr( 10 ) + cErro , STR0023 ) //"Erro na conexão com o SMTP Server."###"AVISO"
						lRet := .F.
					EndIf

				DISCONNECT SMTP SERVER

			EndIf

		EndIf

	EndIf

	RestArea( aArea )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fChkEnv
Faz as validações para envio do WF

@return lRet Logico  Indica se deve enviar o WF

@param cTable Caracter Indica a Tabela que foi inclusa
@param cChkCod Caracter Indica o Codigo que foi incluso

@sample fChkEnv( 'SRJ' , '00001' )

@author Jackson Machado
@since 01/04/2016
/*/
//---------------------------------------------------------------------
Static Function fChkEnv( cTable , cChkCod )

	Local lRet := .T.

	If cTable == "SQG"
		dbSelectArea( "TM0" )
		dbSetOrder( 10 )
		lRet := dbSeek( xFilial( "TM0" ) + cChkCod )
	EndIf

Return lRet