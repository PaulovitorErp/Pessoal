#Include "MNTW060.ch"
#Include "RWMAKE.CH"
#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW060
Workflow de aviso de inclusão de multa
@type function

@author Ricardo Dal Ponte
@since 09/04/2007

@sample MNTW060( '0001' )

@param  cMulta, Caracter, Número da multa incluida.
@return Lógico, Define se o workflow foi enviado com êxito.

@obs Reescrito por: Alexandre Santos, 11/04/2019.
/*/
//---------------------------------------------------------------------
Function MNTW060( cMulta )

	Local cMail := ''
	Local lRet  := .T.

	dbSelectArea( 'TRX' )
	dbSetOrder( 1 )
	If !dbSeek( xFilial( 'TRX' ) + cMulta )

		lRet := .F.

	Else

		cMail := MntRetMail( TRX->TRX_PLACA, 'MNTW060' )

		If !Empty( cMail )

			Processa( { || MNTW060F( cMail ) } )

		Else

			lRet := .F.

		EndIf

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW060F
Envio do Workflow
@type function

@author Ricardo Dal Ponte
@since 09/04/2007

@sample MNTW060F( 'perug@email.com' )

@param  cMail , Caracter, E-mails que seram destino para o workflow.
@return Lógico, Define se o workflow foi enviado com êxito.
/*/
//---------------------------------------------------------------------
Function MNTW060F( cMail )

	Local aArea		 := GetArea()
	Local aRegistros := {}
	Local aCampos	 := {}
	Local aProcessos := {}

	Local cBodyHtml  := ''

	Local lRet       := .T.

	dbSelectArea("DA4")
	dbSetOrder(1)
	cMotorista := ""

	If dbSeek(xFilial("DA4") + TRX->TRX_CODMO)
		cMotorista := DA4->DA4_NOME
	EndIf

	If !Empty(cMotorista)
		cStrTEXTO1 := STR0009+" "+cMotorista+" "+STR0010+":" //"O motorista Sr."###"cometeu o seguinte ato infracional"
	Else
		cStrTEXTO1 := STR0037+":" //"O motorista não foi informado no ato infracional"
	EndIf
	cStrTexto2 := STR0011 + " " + ; //"Caso o infrator queira recorrer da multa, o mesmo deverá entrar em contato"
	              STR0012 + "."		//"com a Gestão de Riscos para as devidas orientações."

	cTRX_DTINFR := DTOC(TRX->TRX_DTINFR)
	cTRX_RHINFR := TRX->TRX_RHINFR
	cTRX_LOCAL  := TRX->TRX_LOCAL
	cTRX_CIDINF := TRX->TRX_CIDINF
	cTRX_UFINF  := TRX->TRX_UFINF

	dbSelectArea("ST9")
	dbSetOrder(14)

	cNomBem := ""
	cPlaca := ""

	If dbSeek(TRX->TRX_PLACA)
		cNomBem := AllTrim(ST9->T9_NOME)
		cPlaca  := AllTrim(ST9->T9_PLACA)
	EndIf

	cTRX_Frota  := cPlaca + " - " + cNomBem

	cTRX_NUMAIT := TRX->TRX_NUMAIT
	cTRX_CODINF := TRX->TRX_CODINF

	dbSelectArea("TSH")
	dbSetOrder(1)

	cTRX_DESART := ""
	cTRX_PONTOS := ""

	If dbSeek(xFilial("TSH") + TRX->TRX_CODINF)
		cTRX_DESART := AllTrim(TSH->TSH_DESART)
		cTRX_PONTOS := TSH->TSH_PONTOS
	EndIf

	dbSelectArea("TRX")
	cTRX_DESOBS := IIf(FieldPos('TRX_MMSYP') > 0, MSMM(TRX->TRX_MMSYP, 80), IIf(FieldPos('TRX_OBS') > 0, TRX->TRX_OBS, " "))

	aAdd(aRegistros, {;
							STR0013,; //"Data Infração"
							STR0014,; //"Horário"
							STR0015,; //"Local"
							STR0016,; //"Município"
							STR0017,; //"UF"
							STR0018,; //"Placa/Veículo"
							STR0019,; //"Auto de Infração"
							STR0020,; //"Infração"
							STR0021,; //"Descrição"
							STR0022,; //"Observação"
							STR0023,; //"Pontos"
							cTRX_DTINFR,;
							cTRX_RHINFR,;
							cTRX_LOCAL,;
							cTRX_CIDINF,;
							cTRX_UFINF,;
							cTRX_Frota,;
							cTRX_NUMAIT,;
							cTRX_CODINF,;
							cTRX_DESART,;
							cTRX_DESOBS,;
							cTRX_PONTOS;
					};
		)

	If Len( aRegistros ) == 0
		lRet := .F.
	ElseIf FindFunction( 'NGUseTWF' ) .And. NGUseTWF( 'MNTW060' )[1]
		aCampos := {;
						{ 'cSubTitulo'      , DtoC(MsDate()) + ' - ' + STR0024 },; // Aviso de Inclusão de Multa
						{ 'it1.TEXTO1' 		, cStrTEXTO1 },; // O motorista Sr."###"cometeu o seguinte ato infracional #OU# O motorista não foi informado no ato infracional
						{ 'it2.TRX_DTINFR'  , STR0013 },; // Data Infração
						{ 'it2.TRX_RHINFR'  , STR0014 },; // Horário
						{ 'it2.TRX_LOCAL'   , STR0015 },; // Local
						{ 'it2.TRX_CIDINF'  , STR0016 },; // Município
						{ 'it2.TRX_UFINF'   , STR0017 },; // UF
						{ 'it2.TRX_Frota'   , STR0018 },; // Placa/Veículo
						{ 'it2.TRX_NUMAIT'  , STR0019 },; // Auto de Infração
						{ 'it4.TRX_CODINF'  , STR0020 },; // Infração
						{ 'it4.TRX_DESART'  , STR0021 },; // Descrição
						{ 'it4.TRX_DESOBS'  , STR0022 },; // Observação
						{ 'it4.TRX_PONTOS'  , STR0023 },; // Pontos
						{ 'it3.TRX_DTINFR'  , cTRX_DTINFR },;
						{ 'it3.TRX_RHINFR'  , cTRX_RHINFR },;
						{ 'it3.TRX_LOCAL'   , cTRX_LOCAL },;
						{ 'it3.TRX_CIDINF'  , cTRX_CIDINF },;
						{ 'it3.TRX_UFINF'   , cTRX_UFINF },;
						{ 'it3.TRX_Frota'   , cTRX_Frota },;
						{ 'it3.TRX_NUMAIT'  , cTRX_NUMAIT },;
						{ 'it5.TRX_CODINF'  , cTRX_CODINF },;
						{ 'it5.TRX_DESART'  , cTRX_DESART },;
						{ 'it5.TRX_DESOBS'  , cTRX_DESOBS },;
						{ 'it5.TRX_PONTOS'  , cTRX_PONTOS };
					}

		// Função para criação do objeto da classe TWFProcess responsavel pelo envio de workflows.
		aProcessos := NGBuildTWF( cMail, 'MNTW060', STR0024, 'MNTW060', aCampos ) 

		// Consiste se foi possivel a inicialização do objeto TWFProcess.
		If aProcessos[1]
			// Função que realiza o envio do workflow conforme definições do objeto passado por parãmetro.
			NGSendTWF( aProcessos[2] )
		EndIf
	Else
		cBodyHtml += '<html>'
		cBodyHtml += '<head>'
		cBodyHtml += '<meta http-equiv="Content-Language" content="pt-br">'
		cBodyHtml += '<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
		cBodyHtml += '<meta name="GENERATOR" content="Microsoft FrontPage 4.0">'
		cBodyHtml += '<meta name="ProgId" content="FrontPage.Editor.Document">'
		cBodyHtml += '<title>'+ STR0024 + '</title>' //"Aviso de Inclusão de Multa"
		cBodyHtml += '</head>'

		cBodyHtml += '<noscript><b><U><font face="Arial" size=2 color="#FF0000"></font></b>'
		cBodyHtml += '</noscript>'

		cBodyHtml += '<p><b><font face="Arial">' + DtoC(MsDate()) + " - " + STR0024 + '</font></b></p>' //"Aviso de Inclusão de Multa"
		cBodyHtml += '</u>'

		cBodyHtml += '<table border=0 WIDTH=100% cellpadding="1">'
		cBodyHtml += '<tr>'
		cBodyHtml += '<p><font face="Arial" size="2">' + cStrTEXTO1 + '</font></p>'
		cBodyHtml += '</tr>'
		cBodyHtml += '</table>'
		cBodyHtml += '<table border=0 WIDTH=100% cellpadding="1">'
		cBodyHtml += '<tr>'
		cBodyHtml += 	'<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + aRegistros[1,1] + '</font></b></td>'
		cBodyHtml += 	'<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + aRegistros[1,2] + '</font></b></td>'
		cBodyHtml += 	'<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + aRegistros[1,3] + '</font></b></td>'
		cBodyHtml += 	'<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + aRegistros[1,4] + '</font></b></td>'
		cBodyHtml += 	'<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + aRegistros[1,5] + '</font></b></td>'
		cBodyHtml += 	'<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + aRegistros[1,6] + '</font></b></td>'
		cBodyHtml += 	'<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + aRegistros[1,7] + '</font></b></td>'
		cBodyHtml += '<tr>'
		cBodyHtml += 	'<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aRegistros[1,12] + '</font></td>'
		cBodyHtml += 	'<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aRegistros[1,13] + '</font></td>'
		cBodyHtml += 	'<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aRegistros[1,14] + '</font></td>'
		cBodyHtml += 	'<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aRegistros[1,15] + '</font></td>'
		cBodyHtml += 	'<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aRegistros[1,16] + '</font></td>'
		cBodyHtml += 	'<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aRegistros[1,17] + '</font></td>'
		cBodyHtml += 	'<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aRegistros[1,18] + '</font></td>'
		cBodyHtml += '</tr>'

		cBodyHtml += '</table>'
		cBodyHtml += '&nbsp;'
		cBodyHtml += '<table border=0 WIDTH=655 cellpadding="1">'

		cBodyHtml += '<tr>'
		cBodyHtml += 	'<td bgcolor="#EEEEEE" align="left" width="157"><b><font face="Arial" size="2">' + aRegistros[1,8] + '</font></b></td>'
		cBodyHtml += 	'<td bgcolor="#EEEEEE" align="left" width="420"><font face="Arial" size="1">' + aRegistros[1,19] + '</font></td>'
		cBodyHtml += '<tr>'
		cBodyHtml += 	'<td bgcolor="#EEEEEE" align="left" width="157"><b><font face="Arial" size="2">' + aRegistros[1,9] + '</font></b></td>'
		cBodyHtml += 	'<td bgcolor="#EEEEEE" align="left" width="420"><font face="Arial" size="1">' + aRegistros[1,20] + '</font></td>'
		cBodyHtml += '<tr>'
		cBodyHtml += 	'<td bgcolor="#EEEEEE" align="left" width="157"><b><font face="Arial" size="2">' + aRegistros[1,10] + '</font></b></td>'
		cBodyHtml += 	'<td bgcolor="#EEEEEE" align="left" width="420"><font face="Arial" size="1">' + aRegistros[1,21] + '</font></td>'
		cBodyHtml += '<tr>'
		cBodyHtml += 	'<td bgcolor="#EEEEEE" align="left" width="157"><b><font face="Arial" size="2">' + aRegistros[1,11] + '</font></b></td>'
		cBodyHtml += 	'<td bgcolor="#EEEEEE" align="left" width="420"><font face="Arial" size="1">' + aRegistros[1,22] + '</font></td>'
		cBodyHtml += 	'</table>'
		cBodyHtml += 	'<br><hr>'

		lRet := NGSendMail( , cMail , , , STR0024 , , cBodyHtml ) // Aviso de Inclusão de Multa

		If lRet
			MsgInfo( STR0026 + ': ' + Lower( cMail ), STR0027 ) // Aviso de Inclusão de Multa enviado para # Atenção
		EndIf
	EndIf

	RestArea( aArea )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MntRetMail
Monta string com e-mails de destino para o workflow.
@type function

@author Alexandre Santos
@since 11/04/2019

@sample MntRetMail( 'PLA-1234' )

@param  cBoard , Caracter, Placa do veículo vinculado a multa.
@return cReturn, Caracter, E-mails de destino para o workflow.
/*/
//---------------------------------------------------------------------
Function MntRetMail( cBoard, cWorkflow )

	Local aArea    := GetArea()
	Local cMailRsp := Trim( SuperGetMv( 'MV_NGRESMU' ) )
	Local cLeasP   := Trim( SuperGetmv( 'MV_NGLEASP' ) )
	Local cMail    := NgEmailWF( '3', cWorkflow )

	If cWorkflow $ 'MNTW060#MNTW061'

		dbSelectArea( 'ST9' )
		dbSetOrder( 14 ) // T9_PLACA + T9_SITBEM
		If dbSeek( cBoard )

			If cLeasP == ST9->T9_STATUS

				dbSelectArea( 'TSJ' )
				dbSetOrder( 1 )
				If dbSeek( xFilial( 'TSJ' ) + ST9->T9_CODBEM )

					If !Empty( TSJ->TSJ_EMAIL ) .And. !( TSJ->TSJ_EMAIL $ cMail )

					cMail += Trim( TSJ->TSJ_EMAIL ) + ';'

					EndIf

				EndIf

			EndIf

		EndIf

	EndIf

	// Executa ponto de entrada para alteração de destinatário.
	If cWorkflow == 'MNTW060'

		// Ponto de entrada para alterar destinatário de email de multas
		If ExistBlock( 'MNTW0601' )
			cMail := ExecBlock( 'MNTW0601', .F., .F., cMail )
		EndIf

	ElseIf cWorkflow == 'MNTW061'

		//Ponto de entrada para alterar destinatário de email de notificações
		If ExistBlock( 'MNTW0611' )
			cMail := ExecBlock( 'MNTW0611', .F., .F., cMail )
		EndIf

	EndIf

	// Inclui o e-mail do responsável por multas nos e-mails de destinatário.
	If !Empty( cMailRsp ) .And. !( cMailRsp $ cMail )

		cMail += cMailRsp

	EndIf

	// Remove ponto e virgula excedente.
	If SubStr( cMail, Len( cMail ) ) == ';'
		cMail := SubStr( cMail, 1, Len( cMail ) - 1 )
	EndIf

	RestArea( aArea )

Return cMail
