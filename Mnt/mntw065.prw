#INCLUDE "MNTW065.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW065
Workflow de aviso de geração de advertência de multa
@type function

@author Ricardo Dal Ponte
@since 16/04/2007

@sample MNTW065( '0001' )

@param  cMulta, Caracter, Número da multa incluida.
@return Lógico, Define se o workflow foi enviado com êxito.

@obs Reescrito por: Alexandre Santos, 11/04/2019.
/*/
//---------------------------------------------------------------------
Function MNTW065( cMulta )

	Local cMail     := MntRetMail( , 'MNTW065' )
	Local cLeasp    := Trim( SuperGetmv( 'MV_NGLEASP' ) )
	Local lRet      := .T.

	Private cDirJPG := '\workflow\RW065'

	If Empty( cMail )

		lRet := .F.

	Else

		dbSelectArea( 'TRX' )
		dbSetOrder( 1 )
		If !dbSeek( xFilial( 'TRX' ) + cMulta )

			lRet := .F.

		Else

			dbSelectArea( 'ST9' )
			dbSetOrder( 14 )
			If dbSeek( TRX->TRX_PLACA )

				If ST9->T9_STATUS == cLeasp

					dbSelectArea( 'TSJ' )
					dbSetOrder( 1 )
					If dbseek( xFilial( 'TSJ' ) + ST9->T9_CODBEM )
						lRet := .F.
					EndIf

				EndIf

			EndIf

			Processa( { || MNTW065F( cMail ) } )

		EndIf

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW065F
Envio do Workflow

@type function

@source MNTW065.prw

@author Ricardo Dal Ponte
@since 09/04/2007
@version 1.0

	Nota: Atualizado para utilização da função de envio de workflow
	NGSendMail() pois o antigo processo TMailMessage() estava gerando
	problemas recorrentes.
	@author Bruno Lobo de Souza
	@since 05/09/2016
	@author Rodrigo Luan Backes
	@since 05/09/2016
	S.S.: 028780

@sample MNTW065F()

@return Lógico
/*/
//---------------------------------------------------------------------
Function MNTW065F( cMail )

	Local lRet       := .T.
	Local aRegistros := {}
	Local i			 := 0
	Local cMailMsg	 := ''
	Local cAnexo	 := ''
	Local cAssunto	 := STR0023 // Aviso de Inclusão de Sinistro
	Local cTitulo	 := DtoC( MsDate() ) + ' - ' + STR0022 // Aviso de Inclusão de Sinistro
	Local cBodyHtml  := ""

	MNTW065REL()

	dbSelectArea("DA4")
	dbSetOrder(1)
	cMotorista := ""
	If dbSeek(xFilial("DA4")+TRX->TRX_CODMO)
	   cMotorista := DA4->DA4_NOME
	EndIf

	cStrTEXTO1 := STR0009+" "+cMotorista+" "+STR0010+":" //"O motorista Sr."###"cometeu o seguinte ato infracional"
	cStrTEXTO2 := STR0011 //"Imprimir o documento em anexo e encaminhar a Gestão de Riscos, assinado pelo Infrator."

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
		cNOMBEM := AllTrim(ST9->T9_NOME)
		cPLACA := AllTrim(ST9->T9_PLACA)
	EndIf

	cTRX_Frota  := cPLACA+" - "+ cNOMBEM

	cTRX_NUMAIT := TRX->TRX_NUMAIT
	cTRX_CODINF := TRX->TRX_CODINF

	dbSelectArea("TSH")
	dbSetOrder(1)

	cTRX_DESART := ""
	cTRX_PONTOS := ""
	If dbSeek(xFilial("TSH")+TRX->TRX_CODINF)
	   cTRX_DESART := AllTrim(TSH->TSH_DESART)
	   cTRX_PONTOS := TSH->TSH_PONTOS
	EndIf

	dbSelectArea("TRX")
	cTRX_DESOBS := If(FieldPos('TRX_MMSYP') > 0,NGMEMOSYP(TRX->TRX_MMSYP),If(FieldPos('TRX_OBS')>0,TRX->TRX_OBS," "))

	aAdd(aRegistros,{STR0012,; //"Data Infração"
	                  STR0013,; //"Horário"
	                  STR0014,; //"Local"
	                  STR0015,; //"Município"
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
							cTRX_PONTOS})

	If Len( aRegistros ) == 0

		lRet := .F.

	Else

		cMailMsg := '<html>'
		cMailMsg += '<head>'
		cMailMsg += '<meta http-equiv="Content-Language" content="pt-br">'
		cMailMsg += '<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
		cMailMsg += '<meta name="GENERATOR" content="Microsoft FrontPage 4.0">'
		cMailMsg += '<meta name="ProgId" content="FrontPage.Editor.Document">'
		cMailMsg += '<title>'+cAssunto+'</title>'
		cMailMsg += '</head>'
		cMailMsg += '<body bgcolor="#FFFFFF">'
		cMailMsg += '<p><b><font face="Arial">'+cAssunto+'</font></b></p>'
		cMailMsg += '</u>'
		cMailMsg += '<table border=0 WIDTH=100% cellpadding="1">'
		cMailMsg += '<tr>'
		cMailMsg += '	<p><font face="Arial" size="2">'+cStrTEXTO1+'</font></p>'
		cMailMsg += '</tr>'
		cMailMsg += '</table>'
		cMailMsg += '<table border=0 WIDTH=100% cellpadding="1">'
		cMailMsg += '<tr>'
		cMailMsg += '	<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">'+aRegistros[1,1]+'</font></b></td>'
		cMailMsg += '	<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">'+aRegistros[1,2]+'</font></b></td>'
		cMailMsg += '	<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">'+aRegistros[1,3]+'</font></b></td>'
		cMailMsg += '	<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">'+aRegistros[1,4]+'</font></b></td>'
		cMailMsg += '	<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">'+aRegistros[1,5]+'</font></b></td>'
		cMailMsg += '	<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">'+aRegistros[1,6]+'</font></b></td>'
		cMailMsg += '	<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">'+aRegistros[1,7]+'</font></b></td>'
		cMailMsg += '<tr>'
		cMailMsg += '	<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">'+aRegistros[1,12]+'</font></td>'
		cMailMsg += '	<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">'+aRegistros[1,13]+'</font></td>'
		cMailMsg += '	<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">'+aRegistros[1,14]+'</font></td>'
		cMailMsg += '	<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">'+aRegistros[1,15]+'</font></td>'
		cMailMsg += '	<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">'+aRegistros[1,16]+'</font></td>'
		cMailMsg += '	<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">'+aRegistros[1,17]+'</font></td>'
		cMailMsg += '	<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">'+aRegistros[1,18]+'</font></td>'
		cMailMsg += '</tr>'
		cMailMsg += '</table>'
		cMailMsg += '&nbsp;'
		cMailMsg += '<table border=0 WIDTH=655 cellpadding="1">'
		cMailMsg += '<tr>'
		cMailMsg += '	<td bgcolor="#EEEEEE" align="left" width="157"><b><font face="Arial" size="2">'+aRegistros[1,8]+'</font></b></td>'
		cMailMsg += '	<td bgcolor="#EEEEEE" align="left" width="420"><font face="Arial" size="1">'+aRegistros[1,19]+'</font></td>'
		cMailMsg += '<tr>'
		cMailMsg += '	<td bgcolor="#EEEEEE" align="left" width="157"><b><font face="Arial" size="2">'+aRegistros[1,9]+'</font></b></td>'
		cMailMsg += '	<td bgcolor="#EEEEEE" align="left" width="420"><font face="Arial" size="1">'+aRegistros[1,20]+'</font></td>'
		cMailMsg += '<tr>'
		cMailMsg += '	<td bgcolor="#EEEEEE" align="left" width="157"><b><font face="Arial" size="2">'+aRegistros[1,10]+'</font></b></td>'
		cMailMsg += '	<td bgcolor="#EEEEEE" align="left" width="420"><font face="Arial" size="1">'+aRegistros[1,21]+'</font></td>'
		cMailMsg += '<tr>'
		cMailMsg += '	<td bgcolor="#EEEEEE" align="left" width="157"><b><font face="Arial" size="2">'+aRegistros[1,11]+'</font></b></td>'
		cMailMsg += '	<td bgcolor="#EEEEEE" align="left" width="420"><font face="Arial" size="1">'+aRegistros[1,22]+'</font></td>'
		cMailMsg += '</tr>'
		cMailMsg += '</table>'
		cMailMsg += '&nbsp;'
		cMailMsg += '<table border=0 WIDTH=100% cellpadding="1">'
		cMailMsg += '<tr>'
		cMailMsg += '<p><font face="Arial" size="2" color="#FF0000"><b>'+cStrTEXTO2+'</b></font></p>'
		cMailMsg += '</tr>'
		cMailMsg += '<U>'
		cMailMsg += '<U><hr>'
		cMailMsg += '</body>'

		cAssunto := DtoC( MsDate() ) + ' - ' + STR0023 // Aviso de Advertência Disciplinar

		If File( cDirJPG + '_pag1.jpg' )
			cAnexo := cDirJPG + '_pag1.jpg'
		Else
			MsgAlert( STR0053 ) // Anexo não encontrado!
			lRet := .F.
		EndIf

		If lRet
			//Função de envio de WorkFlow
			lRet := NGSendMail( , cMail,,, cAssunto, cAnexo, cMailMsg )

			If lRet
				MsgInfo( STR0025 + ': ' + STR0023 + '!' ) // 'Aviso de Advertência Disciplinar enviado para'
			EndIf

		EndIf

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW065REL
Rotina de impressao do relatorio

@type function

@source MNTW065.prw

@author Ricardo Dal Ponte
@since 16/03/2007
@version 1.0

@sample MNTW065REL()

@return Lógico
/*/
//---------------------------------------------------------------------
Function MNTW065REL()

	Local ix

	Private oFont11, oFontCourier
	Private oPrint := TMSPrinter():New( OemToAnsi("") )

	aLinha := {}
	aMedida := {}
	nLinha := 0
	nMedida := 0

	lin := 270

	oPrint:SetPortrait() //Default Retrato

	oFont11  := TFont():New("ARIAL",11,11,,.F.,,,,.F.,.F.)
	oFont11B := TFont():New("ARIAL",11,11,,.T.,,,,.T.,.F.)
	oFont16  := TFont():New("ARIAL",16,16,,.T.,,,,.T.,.T.)
	oFontCourier  := TFont():New("COURIER NEW",10,10,,.F.,,,,.F.,.F.)

	nColFim := 2350

	oPrint:StartPage()

	oPrint:Say(230,830,STR0026,oFont16) //"ADVERTÊNCIA DISCIPLINAR"

	cMOMatric:= TRX->TRX_CODMO

	dbSelectArea("DA4")
	dbSetOrder(1)

	cMONome  := ""
	If dbSeek(xFilial("DA4")+cMOMatric)
		cMONome  := AllTrim(DA4->DA4_NOME)
	EndIf

	cNumctps   := ""
	cSeriectps := ""

	dbSelectArea("SRA")
	dbSetOrder(01)
	If dbSeek(xFilial("SRA")+cMOMatric)
		cNumctps   := AllTrim(SRA->RA_NUMCP)
		cSeriectps := AllTrim(SRA->RA_SERCP)
	EndIf

	If Empty(cNumctps)
		cNumctps   := '____________________'
	EndIf

	If Empty(cSeriectps)
		cSeriectps := '__________'
	EndIf

	cStrREL := STR0027+". "+cMONome+" "+STR0028+" "+cMOMatric+", "+STR0029+" "+cNumctps+" - "+STR0030+" "+cSeriectps+" "+; //"O Sr(a)"###"matrícula"###"CTPS Nº"###"Série"
	STR0031 //"fica neste ato, ADVERTIDO que não deverá mais praticar o seguinte ato ou omissão:"


	nLinhas := MlCount(cStrREL, 95)

	nLine  := 0
	nColna := 0

	For ix := 1 to nLinhas
		oPrint:Say(500+nLine,250-nColna, Memoline(cStrREL, 95, ix), oFont11)
		nColna := 100
		nLine += 60
	Next ix

	cData := DTOC(TRX->TRX_DTINFR)

	cStrREL := STR0032+" "+cData+" "+STR0033+" "+Time()+" "+STR0034+" "+AllTrim(TRX->TRX_LOCAL)+", "+AllTrim(TRX->TRX_UFINF)+", "+STR0035+" "+; //"No dia"###"as"###"horas no local"###"foi multado pela autoridade"
	STR0036+":" //"por descumprir à seguinte norma de trânsito"

	nLinhas := MlCount(cStrREL, 95)

	nLine  := 0
	nColna := 0

	For ix := 1 to nLinhas
		oPrint:Say(700+nLine,250-nColna, Memoline(cStrREL, 95, ix), oFont11B)
		nColna := 100
		nLine += 60
	Next ix

	dbSelectArea("TSH")
	dbSetOrder(1)

	cStrREL := ""
	If dbSeek(xFilial("TSH")+TRX->TRX_CODINF)
		cStrREL := UPPER(AllTrim(TSH->TSH_DESART))
	EndIf

	nLinhas := MlCount(cStrREL, 95)

	nLine  := 0
	nColna := 0

	For ix := 1 to nLinhas
		oPrint:Say(900+nLine,250-nColna, Memoline(cStrREL, 95, ix), oFont11B)
		nColna := 100
		nLine += 60
	Next ix


	cStrREL := STR0037+" "+; //"Todas as normas de trânsito deverãos ser fielmente obedecidas, sendo que a repétição"
	STR0038+" "+; //"de tal ocorrência ou de qualquer outra, contraria às normas da Empresa, provocada por V. Sa., poderá ensejar novas"
	STR0039 //"punições ou mesmo demissão por justa causa."

	nLinhas := MlCount(cStrREL, 95)

	nLine  := 0
	nColna := 0

	For ix := 1 to nLinhas
		oPrint:Say(1250+nLine,250-nColna, Memoline(cStrREL, 95, ix), oFont11)
		nColna := 100
		nLine += 60
	Next ix

	oPrint:Say(1450,250 ,STR0040,oFont11) //"Informamos que esta ADVERTÊNCIA DISCIPLINAR será lançada em sua Ficha de Registro de Empregado."

	cDIA    := Substr(DTOC(dDataBase), 1, 2)
	cMESEXT := MesExtenso(dDataBase)
	cANO    := Substr(DTOS(dDataBase), 1, 4)

	dbSelectArea("SM0")
	dbSetOrder(1)
	cNomeFil := ""
	cCIDENT  := ""
	cESTENT  := ""
	If MsSeek(cEmpAnt+TRX->TRX_FILIAL)
		cNomeFil := AllTrim(SM0->M0_NOMECOM)
		cCIDENT  := AllTrim(SM0->M0_CIDENT)
		cESTENT  := AllTrim(SM0->M0_ESTENT)
	EndIf

	oPrint:Say(1650,250 ,cCIDENT+" - "+cESTENT+", "+cDIA+" "+STR0041+" "+cMESEXT+" "+STR0041+" "+cANO+".",oFont11) //"de"###"de"

	oPrint:Line(1850,250,1850,1800)
	oPrint:Line(1851,250,1851,1800)

	oPrint:Say(1871,250 ,cNomeFil+".",oFont11)

	oPrint:Say(1980,250 ,STR0042,oFont11) //"Declaro para os devidos fins, que estou ciente dos termos desta ADVERTÊNCIA DISCIPLINAR."
	oPrint:Line(2180,250,2180,1800)
	oPrint:Line(2181,250,2181,1800)
	oPrint:Say(2191,250 ,STR0043,oFont11) //"Recusou-se a assinar"

	oPrint:Say(2600,250 ,STR0044,oFont11) //"Testemunhas:"
	oPrint:Line(2750,250,2750,1000)
	oPrint:Line(2751,250,2751,1000)
	oPrint:Line(2750,1300,2750,2050)
	oPrint:Line(2751,1300,2751,2050)
	oPrint:Say(2770,250 ,STR0045,oFont11) //"Nome:"
	oPrint:Say(2770,1300,STR0045,oFont11) //"Nome:"
	oPrint:Say(2830,250 ,STR0046,oFont11) //"CPF/MF:"
	oPrint:Say(2830,1300,STR0046,oFont11) //"CPF/MF:"

	oPrint:EndPage()
	oPrint:SaveAllAsJpeg(cDirJPG)
	oPrint:End()

Return