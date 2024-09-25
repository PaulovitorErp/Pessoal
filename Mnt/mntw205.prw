#INCLUDE "MNTW205.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW205
Workflow - Multas Vencidas/A Vencer
@type function

@author Marcos Wagner Junior
@since 13/08/2008

@sample MNTW205()

@param
@return Lógico, Define se o workflow foi enviado com êxito.

@obs Reescrito por: Alexandre Santos, 11/04/2019.
/*/
//---------------------------------------------------------------------
Function MNTW205()

	Local cMail := MntRetMail( , 'MNTW205' )

Return IIf( !Empty( cMail ), MNTW205F( cMail ), .F. )

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW205F
Envio do Workflow
@type function

@author Marcos Wagner Junior
@since 13/08/2008

@sample MNTW205F( 'perug@email.com' )

@param  cMail , Caracter, E-mails que seram destino para o workflow.
@return Lógico, Define se o workflow foi enviado com êxito.
/*/
//---------------------------------------------------------------------
Function MNTW205F( cMail )

	Local lRet		 := .T.
	Local aRegistros := {}
	Local i			 := 0
	Local cMailMsg	 := ''
	Local cAssunto	 := DtoC( MsDate() ) + ' - ' + STR0009 // Multas Vencidas/A Vencer

	dbSelectArea("TRX")
	dbSetOrder(01)
	dbSeek(xFilial("TRX"))
	dbGoTop()
	While !EoF() .And. TRX->TRX_FILIAL == xFilial("TRX")

		If !Empty(TRX->TRX_DTVECI) .And. TRX->TRX_DTVECI <= dDATABASE .And. TRX->TRX_PAGTO == '2'

			aAdd(aRegistros,{	TRX->TRX_MULTA,;
								TRX->TRX_PLACA,;
								TRX->TRX_CODBEM,;
								NGSEEK("ST9",TRX->TRX_CODBEM,1,'T9_NOME'),;
								TRX->TRX_NUMAIT,;
								TRX->TRX_DTVECI,;
								Transform(TRX->TRX_VALOR,"@E 999,999,999.99")})

		EndIf
		dbSelectArea("TRX")
		dbSkip()
	End

	If Len( aRegistros ) == 0

		If FindFunction( 'NGLogMsg' )
			NGLogMsg( STR0019, '', , 'WARN', 'MNTW205' ) // Não existem dados para enviar o workflow!
		Else
			MsgAlert( STR0019 )
		EndIf
		lRet := .F.

	ElseIf ExistBlock( 'MNTW2051' )

		ExecBlock( 'MNTW2051', .F., .F., { aRegistros } )
		lRet := .T.

	Else

		aSort(aRegistros,,,{|x,y| DtoS(x[6])+x[1] < DtoS(y[6])+y[1] })

		cMailMsg := '<html>'
		cMailMsg += '<head>'
		cMailMsg += '<meta http-equiv="Content-Language" content="pt-br">'
		cMailMsg += '<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
		cMailMsg += '<meta name="GENERATOR" content="Microsoft FrontPage 4.0">'
		cMailMsg += '<meta name="ProgId" content="FrontPage.Editor.Document">'
		cMailMsg += '<title>Documentos Vencidos/A Vencer</title>'
		cMailMsg += '</head>'
		cMailMsg += '<body bgcolor="#FFFFFF">'
		cMailMsg += '<p><b><font face="Arial">'+STR0009+'</font></b></p>'
		cMailMsg += '<div align="left">'
		cMailMsg += '<table border=0 WIDTH=100% cellpadding="2">'
		cMailMsg += '<tr>'
		cMailMsg += '	<td bgcolor="#C0C0C0" align="center" width="40" ><b><font face="Arial" size="2">'+STR0011+'</font></b></td>'
		cMailMsg += '	<td bgcolor="#C0C0C0" align="center" width="40" ><b><font face="Arial" size="2">'+STR0012+'</font></b></td>'
		cMailMsg += '	<td bgcolor="#C0C0C0" align="center" width="110"><b><font face="Arial" size="2">'+STR0013+'</font></b></td>'
		cMailMsg += '	<td bgcolor="#C0C0C0" align="center" width="85" ><b><font face="Arial" size="2">'+STR0014+'</font></b></td>'
		cMailMsg += '	<td bgcolor="#C0C0C0" align="center" width="85" ><b><font face="Arial" size="2">'+STR0015+'</font></b></td>'
		cMailMsg += '	<td bgcolor="#C0C0C0" align="center" width="75" ><b><font face="Arial" size="2">'+STR0016+'</font></b></td>'
		cMailMsg += '	<td bgcolor="#C0C0C0" align="center" width="75" ><b><font face="Arial" size="2">'+STR0017+'</font></b></td>'
		cMailMsg += '</tr>'
		cMailMsg += '</u>'

		For i := 1 To Len(aRegistros)
			cMailMsg += '<tr>'
			cMailMsg += '	<td bgcolor="#EEEEEE" align="center" width="40" ><b><font face="Arial" size="1">'+aRegistros[i,1]+'</font></b></td>'
			cMailMsg += '	<td bgcolor="#EEEEEE" align="center" width="40" ><b><font face="Arial" size="1">'+aRegistros[i,2]+'</font></b></td>'
			cMailMsg += '	<td bgcolor="#EEEEEE" align="center" width="110"><b><font face="Arial" size="1">'+aRegistros[i,3]+'</font></b></td>'
			cMailMsg += '	<td bgcolor="#EEEEEE" align="center" width="85" ><b><font face="Arial" size="1">'+aRegistros[i,4]+'</font></b></td>'
			cMailMsg += '	<td bgcolor="#EEEEEE" align="center" width="85" ><b><font face="Arial" size="1">'+aRegistros[i,5]+'</font></b></td>'
			cMailMsg += '	<td bgcolor="#EEEEEE" align="center" width="75" ><b><font face="Arial" size="1">'+DtoC(aRegistros[i,6])+'</font></b></td>'
			cMailMsg += '	<td bgcolor="#EEEEEE" align="center" width="75" ><b><font face="Arial" size="1">'+aRegistros[i,7]+'</font></b></td>'
			cMailMsg += '</tr>'
		Next i

		cMailMsg += '</table>'
		cMailMsg += '</div>'
		cMailMsg += '<U>'
		cMailMsg += '<br><hr>'
		cMailMsg += '</body>'
		cMailMsg += '</html>'

		lRet := NGSendMail( , cMail,,, cAssunto,, cMailMsg )

		If lRet

			If FindFunction( 'NGLogMsg' )
				NGLogMsg( STR0018, '', , 'INFO', 'MNTW205' ) // Workflow enviado!
			Else
				MsgInfo( STR0018 ) // Workflow enviado!
			EndIf

		EndIf

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Execução de Parâmetros na Definição do Schedule
@type static

@author Alexandre Santos
@since 04/07/2018

@return Array, Conteudo com as definições de parâmetros para WF
/*/
//---------------------------------------------------------------------
Static Function SchedDef()
Return { 'P', 'PARAMDEF', '', {}, 'Param' }
