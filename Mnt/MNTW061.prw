#INCLUDE "MNTW061.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW061
Workflow de aviso de inclusão de notificação.
@type function

@author Diego de Oliveira
@since 14/12/2016

@sample MNTW061( '0001' )

@param  cNotif, Caracter, Número da multa incluida.
@return Lógico, Define se o workflow foi enviado com êxito.

@obs Reescrito por: Alexandre Santos, 11/04/2019.
/*/
//---------------------------------------------------------------------
Function MNTW061( cNotif )

	Local cMail := ''
	Local lRet  := .T.

	dbSelectArea( 'TRX' )
	dbSetOrder( 1 )
	If !dbSeek( xFilial( 'TRX' ) + cNotif )

		lRet := .F.

	Else

		cMail := MntRetMail( TRX->TRX_PLACA, 'MNTW061' )

		If !Empty( cMail )

			Processa( { || MNTW061F( cMail ) } )

		Else

			lRet := .F.

		EndIf

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW061F
Envio do Workflow
@type function

@author Diego de Oliveira
@since 14/12/2016

@sample MNTW060F( 'perug@email.com' )

@param  cMail , Caracter, E-mails que seram destino para o workflow.
@return Lógico, Define se o workflow foi enviado com êxito.
/*/
//---------------------------------------------------------------------
Function MNTW061F( cMail )

	Local aArea		 := GetArea()
	Local cBodyHtml  := ''
	Local aRegistros := {}
	Local lRet 	     := .T.

	dbSelectArea("DA4")
	dbSetOrder(1)
	cMotorista := ""
	If dbSeek(xfilial("DA4")+TRX->TRX_CODMO)
		cMotorista := DA4->DA4_NOME
	EndIf

	If !Empty(cMotorista)
		cStrTEXTO1 := STR0008 + " " + cMotorista + " " + STR0009 + ":" //"O motorista Sr."###"cometeu o seguinte ato infracional"
	Else
		cStrTEXTO1 := STR0031 + ":" //"O motorista não foi informado no ato infracional"
	EndIf
	cStrTEXTO2 := STR0010 + " " + ; //"Caso o infrator queira recorrer da notificação, o mesmo deverá entrar em contato"
    	          STR0011 + "."		//"com a Gestão de Riscos para as devidas orientações."

	cTRX_DTINFR := DTOC(TRX->TRX_DTINFR)
	cTRX_RHINFR := TRX->TRX_RHINFR
	cTRX_LOCAL  := TRX->TRX_LOCAL
	cTRX_CIDINF := TRX->TRX_CIDINF
	cTRX_UFINF  := TRX->TRX_UFINF

	dbSelectArea("ST9")
	dbSetOrder(14)

	cNOMBEM := ""
	cPLACA := ""
	If dbSeek(TRX->TRX_PLACA)
		cNOMBEM := Alltrim(ST9->T9_NOME)
		cPLACA := Alltrim(ST9->T9_PLACA)
	Endif

	cTRX_Frota  := cPLACA+" - "+ cNOMBEM

	cTRX_NUMAIT := TRX->TRX_NUMAIT
	cTRX_CODINF := TRX->TRX_CODINF

	dbSelectArea("TSH")
	dbSetOrder(1)

	cTRX_DESART := ""
	cTRX_PONTOS := ""
	If dbSeek(xfilial("TSH")+TRX->TRX_CODINF)
	   cTRX_DESART := Alltrim(TSH->TSH_DESART)
	   cTRX_PONTOS := TSH->TSH_PONTOS
	EndIf

	dbSelectArea("TRX")
	cTRX_DESOBS := IIf(FieldPos('TRX_MMSYP') > 0, MSMM(TRX->TRX_MMSYP, 80), IIf(FieldPos('TRX_OBS') > 0, TRX->TRX_OBS, " "))

	aAdd(aRegistros,{;
						STR0012,; //"Data Infração"
						STR0013,; //"Horário"
	                  	STR0014,; //"Local"
	                  	STR0015,;  //"Município"
	                  	STR0016,; //"UF"
	                  	STR0017,; //"Placa/Veículo"
	                  	STR0018,; //"Auto de Infração"
	                  	STR0019,; //"Infração"
	                  	STR0020,; //"Descrição"
	                  	STR0021,; //"Observação"
	                  	STR0022,; //"Pontos"
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
	ElseIf FindFunction( 'NGUseTWF' ) .And. NGUseTWF( 'MNTW061' )[1]
		aCampos := {;
						{ 'cSubTitulo'      , DtoC(MsDate()) + ' - ' + STR0023 },; // Aviso de Inclusão de Notificação
						{ 'it1.TEXTO1' 		, cStrTEXTO1 },; // O motorista Sr."###"cometeu o seguinte ato infracional #OU# O motorista não foi informado no ato infracional
						{ 'it2.TRX_DTINFR'  , STR0012 },; // Data Infração
						{ 'it2.TRX_RHINFR'  , STR0013 },; // Horário
						{ 'it2.TRX_LOCAL'   , STR0014 },; // Local
						{ 'it2.TRX_CIDINF'  , STR0015 },; // Município
						{ 'it2.TRX_UFINF'   , STR0016 },; // UF
						{ 'it2.TRX_Frota'   , STR0017 },; // Placa/Veículo
						{ 'it2.TRX_NUMAIT'  , STR0018 },; // Auto de Infração
						{ 'it4.TRX_CODINF'  , STR0019 },; // Infração
						{ 'it4.TRX_DESART'  , STR0020 },; // Descrição
						{ 'it4.TRX_DESOBS'  , STR0021 },; // Observação
						{ 'it4.TRX_PONTOS'  , STR0022 },; // Pontos
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
		aProcessos := NGBuildTWF( cMail, 'MNTW061', STR0023, 'MNTW061', aCampos )

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
		cBodyHtml += '<title>'+ STR0023 + '</title>' //"Aviso de Inclusão de Notificação"
		cBodyHtml += '</head>'

		cBodyHtml += '<noscript><b><U><font face="Arial" size=2 color="#FF0000"></font></b>'
		cBodyHtml += '</noscript>'

		cBodyHtml += '<p><b><font face="Arial">' + DtoC(MsDate()) + " - " + STR0023 + '</font></b></p>' //"Aviso de Inclusão de Notificação"
		cBodyHtml += '</u>'

		cBodyHtml += '<table border=0 WIDTH=100% cellpadding="1">'
		cBodyHtml += '<tr>'
		cBodyHtml += '<p><font face="Arial" size="2">' + cStrTEXTO1 + '</font></p>'
		cBodyHtml += '</tr>'
		cBodyHtml += '</table>'
		cBodyHtml += '<table border=0 WIDTH=100% cellpadding="1">'
		cBodyHtml += '<tr>'
		cBodyHtml += '<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + aRegistros[1,1] + '</font></b></td>'
		cBodyHtml += '<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + aRegistros[1,2] + '</font></b></td>'
		cBodyHtml += '<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + aRegistros[1,3] + '</font></b></td>'
		cBodyHtml += '<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + aRegistros[1,4] + '</font></b></td>'
		cBodyHtml += '<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + aRegistros[1,5] + '</font></b></td>'
		cBodyHtml += '<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + aRegistros[1,6] + '</font></b></td>'
		cBodyHtml += '<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + aRegistros[1,7] + '</font></b></td>'
		cBodyHtml += '<tr>'
		cBodyHtml += '<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aRegistros[1,12] + '</font></td>'
		cBodyHtml += '<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aRegistros[1,13] + '</font></td>'
		cBodyHtml += '<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aRegistros[1,14] + '</font></td>'
		cBodyHtml += '<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aRegistros[1,15] + '</font></td>'
		cBodyHtml += '<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aRegistros[1,16] + '</font></td>'
		cBodyHtml += '<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aRegistros[1,17] + '</font></td>'
		cBodyHtml += '<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aRegistros[1,18] + '</font></td>'
		cBodyHtml += '</tr>'

		cBodyHtml += '</table>'
		cBodyHtml += '&nbsp;'
		cBodyHtml += '<table border=0 WIDTH=655 cellpadding="1">'

		cBodyHtml += '<tr>'
		cBodyHtml += '<td bgcolor="#EEEEEE" align="left" width="157"><b><font face="Arial" size="2">' + aRegistros[1,8] + '</font></b></td>'
		cBodyHtml += '<td bgcolor="#EEEEEE" align="left" width="420"><font face="Arial" size="1">' + aRegistros[1,19] + '</font></td>'
		cBodyHtml += '<tr>'
		cBodyHtml += '<td bgcolor="#EEEEEE" align="left" width="157"><b><font face="Arial" size="2">' + aRegistros[1,9] + '</font></b></td>'
		cBodyHtml += '<td bgcolor="#EEEEEE" align="left" width="420"><font face="Arial" size="1">' + aRegistros[1,20] + '</font></td>'
		cBodyHtml += '<tr>'
		cBodyHtml += '<td bgcolor="#EEEEEE" align="left" width="157"><b><font face="Arial" size="2">' + aRegistros[1,10] + '</font></b></td>'
		cBodyHtml += '<td bgcolor="#EEEEEE" align="left" width="420"><font face="Arial" size="1">' + aRegistros[1,21] + '</font></td>'
		cBodyHtml += '<tr>'
		cBodyHtml += '<td bgcolor="#EEEEEE" align="left" width="157"><b><font face="Arial" size="2">' + aRegistros[1,11] + '</font></b></td>'
		cBodyHtml += '<td bgcolor="#EEEEEE" align="left" width="420"><font face="Arial" size="1">' + aRegistros[1,22] + '</font></td>'
		cBodyHtml += '</table>'
		cBodyHtml += '<br><hr>'

		//Função de envio de WorkFlow
		lRet := NGSendMail( , cMail, , , STR0023, , cBodyHtml ) //"Aviso de Inclusão de Notificação"

		If lRet
			MsgInfo( STR0024 + ': ' + Lower( cMail ), STR0025 ) //"Aviso de Inclusão de Notificação enviado para"###"Atenção"
		EndIf
	EndIf

	RestArea( aArea )

Return lRet