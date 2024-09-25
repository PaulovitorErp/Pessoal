#INCLUDE "MNTW200.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

Static lNewSX1 := .F.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW200
Workflow - Documentos Vencidos/A Vencer

@type function

@source MNTW200.prx

@author Marcos Wagner Junior
@since 13/08/2008

@sample MNTW200()

@return Lógico
/*/
//---------------------------------------------------------------------
Function MNTW200()

	Local lOk  := .T.

	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 95 )

		dbSelectArea( 'SX1' )
		dbSetOrder( 1 ) // Grupo + Ordem
		If ( lNewSX1 := msSeek( 'MNTW200' ) )

			If !IsBlind()

				lOk := Pergunte( 'MNTW200', .T. )

			EndIf

		EndIf

		If lOk
			
			MNTW200F()
		
		EndIf

	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW200F
Envio do Workflow

@type function

@source MNTW200.prx

@author Marcos Wagner Junior
@since 13/08/2008

@sample MNTW200F()

@return Lógico
/*/
//---------------------------------------------------------------------
Function MNTW200F()

	Local cCntEmail		:= GetNewPar("MV_RELACNT","")	// Conta de e-mail do usuário no servidor de e-mail
	Local cAssunto   	:= DtoC(MsDate())+" - "+STR0009 //"Documentos Vencidos/A Vencer"
	Local aRegistros 	:= {}
	Local cEMAIL_All	:= ""
	Local cEmailTAB 	:= NGEmailWF( '5', 'MNTW200' )
	Local lEmailRet		:= .T.
	Local cAlsDcto      := GetNextAlias()

	If lNewSX1 .And. MV_PAR01 == 2

		BeginSQL Alias cAlsDcto

			SELECT
				TS1.TS1_PLACA ,
				TS1.TS1_CODBEM,
				TS1.TS1_DOCTO ,
				TS1.TS1_DTVALI,
				ST9.T9_NOME   ,
				TS0.TS0_NOMDOC
			FROM
				%table:TS1% TS1
			INNER JOIN
				%table:ST9% ST9 ON
					ST9.T9_FILIAL = %xFilial:ST9%  AND
					ST9.T9_CODBEM = TS1.TS1_CODBEM AND
					ST9.%NotDel%
			INNER JOIN
				%table:TS0% TS0 ON
					TS0.TS0_FILIAL = %xFilial:TS0% AND
					TS0.TS0_DOCTO  = TS1.TS1_DOCTO AND
					TS0.%NotDel%
			WHERE
				TS1.TS1_FILIAL  = %xFilial:TS1%   AND
				TS1.TS1_DTVALI <= %exp:dDATABASE% AND
				TS1.%NotDel%
			ORDER BY
				TS1.TS1_DTVALI

		EndSQL

		While (cAlsDcto)->( !EoF() )

			aAdd( aRegistros, { (cAlsDcto)->TS1_PLACA, (cAlsDcto)->TS1_CODBEM, (cAlsDcto)->T9_NOME, (cAlsDcto)->TS1_DOCTO, (cAlsDcto)->TS0_NOMDOC,;
				Nil, Nil, Nil, DToC( SToD( (cAlsDcto)->TS1_DTVALI ) ) } )

			(cAlsDcto)->( dbSkip() )

		End

		(cAlsDcto)->( dbCloseArea() )

	Else 
		
		dbSelectArea("TS2")
		dbSetOrder(01)
		dbSeek(xFilial("TS2"))
		dbGoTop()
		While !EoF()
			If TS2->TS2_FILIAL == xFilial("TS2")

				dbSelectArea("TS0")
				dbSetOrder(01)
				dbSeek(xFilial("TS0")+TS2->TS2_DOCTO)

				If Empty(TS2->TS2_DTPGTO) .And. Empty(TS2->TS2_NOTFIS) .And. TS2->TS2_DTVENC <= dDATABASE
					aAdd(aRegistros,{	TS2->TS2_PLACA,;
						TS2->TS2_CODBEM,;
						NGSEEK("ST9",TS2->TS2_CODBEM,1,'T9_NOME'),;
						TS2->TS2_DOCTO,;
						TS0->TS0_NOMDOC,;
						DToC( TS2->TS2_DTVENC ),;
						TS2->TS2_PARCEL,;
						Transform(TS2->TS2_VALOR,"@E 999,999.99"),;
						TS2->TS2_DTVENC } )
				EndIf

			EndIf

			dbSelectArea("TS2")
			dbSkip()
		End

		aSort( aRegistros, , , { |x,y| DToS( x[9] ) + x[1] < DToS( y[9] ) + y[1] } )

	EndIf

	If Len(aRegistros) = 0
		ApMsgAlert(STR0019) //"Não existem dados para enviar o workflow!"
		Return .T.
	EndIf

	If ExistBlock("MNTW2001")
		ExecBlock("MNTW2001",.F.,.F.,{aRegistros})
		Return lRetu
	Else

		/*--------------------------------+
		| Monta corpo do workflow em HTML |
		+--------------------------------*/
		cMailMsg := fGetHTML( aRegistros )

	EndIf

	If !Empty(cEmailTAB)
		cEMAIL_All 		:= cEmailTAB
	ElseIf !Empty(cCntEmail)
		cEMAIL_All 		:= cCntEmail
	Else
		ShowHelpDlg(STR0028, {STR0026 + STR0022 + "."}, 2, {STR0024}, 1)//"Destinatário do E-mail não informado."##" Favor, verificar parâmetro MV_RELACNT"##"ou se o funcionário possui E-mail cadastrado no sistema."##"Envio de E-mail cancelado!"
	EndIf

	//Função de envio de WorkFlow
	lEmailRet := NGSendMail( , cEMAIL_All + Chr(59) , , , OemToAnsi( cAssunto ) , , cMailMsg )

	If lEmailRet
		MsgInfo(STR0009 + STR0029 + ": " + cEMAIL_All + "!") //"Documentos Vencidos/A Vencer"##" enviados para"
	EndIf

Return lEmailRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetHTML
Monta o corpo do workflow no formato HTML.
@type function

@author Alexandre Santos
@since 15/09/2022

@param aInfos, array, Informações referente aos documentos:
						[1] string, Placa do Veículo.
						[2] string, Código do Bem.
						[3] string, Nome do Bem.
						[4] string, Código do Documento.
						[5] string, Nome do Documento.
						[6] string, Data de Vencimento do Pagamento.
						[7] string, Parcela.
						[8] string, Valor
						[9] string, Data de Validade do Documento.

@return string, Corpo do workflow no formato HTML.
/*/
//---------------------------------------------------------------------
Static Function fGetHTML( aInfos )

	Local cHTML := ''
	Local nInd1 := 0

	cHTML := '<html>'
	cHTML += 	'<head>'
	cHTML += 		'<meta http-equiv="Content-Language" content="pt-br">'
	cHTML += 		'<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
	cHTML += 		'<meta name="GENERATOR" content="Microsoft FrontPage 4.0">'
	cHTML += 		'<meta name="ProgId" content="FrontPage.Editor.Document">'
	cHTML += 		'<title>' + STR0009 + '</title>' // Documentos Vencidos/A Vencer
	cHTML += 	'</head>'
	cHTML += 	'<body bgcolor="#FFFFFF">'
	cHTML += 		'<table border=0 WIDTH=100% cellpadding="1">'
	cHTML += 			'<tr>'
	cHTML += 				'<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + STR0011 + '</font></b></td>' // Placa
	cHTML += 				'<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + STR0012 + '</font></b></td>' // Bem
	cHTML += 				'<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + STR0013 + '</font></b></td>' // Descrição
	cHTML += 				'<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + STR0014 + '</font></b></td>' // Documento
	cHTML += 				'<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + STR0013 + '</font></b></td>' // Descrição

	If lNewSX1 .And. MV_PAR01 == 2

		cHTML += 			'<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + STR0030 + '</font></b></td>' // Data Validade

	Else

		cHTML += 			'<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + STR0015 + '</font></b></td>' // Dt. Vencimento
		cHTML += 			'<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + STR0016 + '</font></b></td>' // Parcela
		cHTML += 			'<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + STR0017 + '</font></b></td>' // Valor

	EndIf

	cHTML += 			'</tr>'

	ProcRegua( Len( aInfos ) )

	For nInd1 := 1 To Len( aInfos )

		IncProc()

		cHTML += 		'<tr>'
		cHTML += 			'<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aInfos[nInd1,1] + '</font></td>'
		cHTML += 			'<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aInfos[nInd1,2] + '</font></td>'
		cHTML += 			'<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aInfos[nInd1,3] + '</font></td>'
		cHTML += 			'<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aInfos[nInd1,4] + '</font></td>'
		cHTML += 			'<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aInfos[nInd1,5] + '</font></td>'

		If lNewSX1 .And. MV_PAR01 == 2
			
			cHTML += 		'<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aInfos[nInd1,9] + '</font></td>'
			
		Else

			cHTML += 		'<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aInfos[nInd1,6] + '</font></td>'
			cHTML += 		'<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aInfos[nInd1,7] + '</font></td>'
			cHTML += 		'<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aInfos[nInd1,8] + '</font></td>'

		EndIf

		cHTML += 		'</tr>'

	Next nInd1

	cHTML += 		'</table>'
	cHTML += 	'<br><hr>'
	cHTML += 	'</body>'
	cHTML += '</html>'

Return cHTML

//---------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Execução de Parâmetros na Definição do Schedule
@type function

@author Alexandre Santos
@since 15/09/2022

@return Array, Conteudo com as definições de parâmetros para WF
/*/
//---------------------------------------------------------------------
Static Function SchedDef()

	Local cPerg := 'PARAMDEF'

	dbSelectArea( 'SX1' )
	dbSetOrder( 1 ) // Grupo + Ordem
	If msSeek( 'MNTW200' )

		cPerg := 'MNTW200'

	EndIf

Return { 'P', cPerg, '', {}, }
