#Include "Protheus.ch"
#Include "MNTR065.CH"

#DEFINE _nSizeFil NGMTAMFIL()

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR065
Relatório de horas por atividades da parte diária

@author Evaldo Cevinscki Jr.
@author Implementado no produto padrão André Felipe Joriatti
@since 05/12/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Function MNTR065

	Private WNREL    := "MNTR065"
	Private cPERG    := "MNTR065   "
	Private LIMITE   := 132
	Private cDESC1   := STR0001 // "Relatorio de Horas por Atividade apresentará a relação entre as horas acumuladas "
	Private cDESC2   := STR0002 // "no periodo filtrado de determinada atividade em relação as horas disponíveis."
	Private cDESC3   := ""
	Private cSTRING  := "TV1"
	Private aSM0Area := SM0->( GetArea() )
	Private cOldEmp  := cEmpAnt
	Private cOldFil  := cFilAnt

	Private NOMEPROG := "MNTR065"
	Private TAMANHO  := "M"
	Private aRETURN  := { STR0003,1,STR0004,1,2,1,"",1 }   // "Zebrado" ### "Administracao"
	Private TITULO   := STR0005 // "Relatório de Horas por Atividade"
	Private nTIPO    := 0
	Private nLASTKEY := 0
	Private CABEC1   := Nil
	Private CABEC2   := Nil

	SETKEY( VK_F9,{ || NGVersao( "MNTR065",1 ) } )

	/*
	Variaveis utilizadas para parametros
	mv_par01 // De Motorista
	mv_par02 // Ate Motorista
	mv_par03 // De Data
	mv_par04 // Ate Data
	mv_par05 // De Rota
	mv_par06 // Ate Rota
	mv_par07 // De Veiculo
	mv_par08 // Ate Veiculo
	mv_par09 // De Empresa/Filial
	mv_par10 // Ate Empresa/Filial
	*/

	Pergunte( cPERG,.F. )

	//------------------------------------------
	// Envia controle para a funcao SETPRINT
	//------------------------------------------
	WNREL := SetPrint( cSTRING,WNREL,cPERG,TITULO,cDESC1,cDESC2,cDESC3,.F.,"" )

	If nLASTKEY = 27
		Set Filter To
		DbSelectArea( "TV1" )
		RestArea( aSM0Area )
		cEmpAnt := cOldEmp
		cFilAnt := cOldFil
		Return Nil
	EndIf

	SetDefault( aReturn,cSTRING )
	RptStatus( { |lEND| R065Imp( @lEND,WNREL,TITULO,TAMANHO ) },TITULO )

	DbSelectArea( "TV1" )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR065
Impressão do relatório

@author Evaldo Cevinscki Jr.
@autor Implementado no produto padrão André Felipe Joriatti
@since 05/12/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Static Function R065Imp( lEND,WNREL,TITULO,TAMANHO )

	Local aTable    := { { "TV1" },{ "TV2" },{ "TV0" },{ "ST6" },{ "ST9" } }
	Local cAliasQry
	Local cQuery
	Local nX
	Local nZ
	Local aRECTV1 := {}
	Local cFilAte := ''
	Local oTmpTbl1
	Local nIndex  := 2

	Private cRODATXT := ""
	Private nCNTIMPR := 0
	Private li       := 80
	Private m_pag    := 1
	Private cFiliIni
	Private aHrsHTB  := {}
	Private cTRB := GetNextAlias()

	nTIPO  := IIf( aReturn[4] == 1,15,18 )

	If MV_PAR11 == 3
		CABEC1 := "                                                                          Horas       Horas       Participação"
		CABEC2 := STR0021 // "Código            Descrição                                               Atividade   Disponiv.   da Atividade"
	Else
		CABEC1 := "                                                            Horas         Horas       Horas       Participação"
		CABEC2 := STR0022 //"Código            Descrição                                 Trabalhadas   Atividade   Disponiv.   da Atividade"
	EndIf

	/*
			  1         2         3         4         5         6         7         8         9         0         1         2         3
	0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
	*************************************************************************************************************************************
																Relatório de Horas por Atividade
	*************************************************************************************************************************************
																Horas         Horas       Horas       Participação
	Código            Descrição                                 Trabalhadas   Atividade   Disponiv.   da Atividade
	*************************************************************************************************************************************
	Negócio: XXXXXXXXXXXXXXXXXXXX                                               Atividade: XXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	Período: 99/99/9999 a 99/99/9999
	Família: XXXXXX - XXXXXXXXXXXXXXXXXXXX

	xxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   999,999.99  999,999.99  999,999.99    9,999.99%
	xxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   999,999.99  999,999.99  999,999.99    9,999.99%
	xxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   999,999.99  999,999.99  999,999.99    9,999.99%
	xxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   999,999.99  999,999.99  999,999.99    9,999.99%
	xxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   999,999.99  999,999.99  999,999.99    9,999.99%

							Total Atividade:                           999,999.99   999,999.99  999,999.99   9,999.99%

	*/

	aDBF := {}
	aAdd( aDBF,{ "EMPRESA"	,"C",2,0 } )
	aAdd( aDBF,{ "FILIAL"	,"C",_nSizeFil,0 } )
	aAdd( aDBF,{ "NOMFL"	,"C",15,0 } )
	aAdd( aDBF,{ "CODBEM"	,"C",16,0 } )
	aAdd( aDBF,{ "CODFAMI"	,"C",6,0 } )
	aAdd( aDBF,{ "FRENTE"	,"C",NGSX3TAM( "T9_CCUSTO" ),0 } )
	aAdd( aDBF,{ "ATIVID"	,"C",3,0 } )
	aAdd( aDBF,{ "DTSERV"	,"D",8,0 } )
	aAdd( aDBF,{ "HRATINI"	,"C",5,0 } )
	aAdd( aDBF,{ "HRATFIM"	,"C",5,0 } )
	aAdd( aDBF,{ "HRSDPN"	,"N",9,2 } )
	aAdd( aDBF,{ "HRSHTB"	,"N",9,2 } )
	aAdd( aDBF,{ "HRSATI"	,"N",9,2 } )
	aAdd( aDBF,{ "CHAVETV2" ,"C",31,0 } )

	// Instancia classe FWTemporaryTable
	oTmpTbl1 := FWTemporaryTable():New(cTRB,aDBF)
	// Cria indices
	oTmpTbl1:AddIndex("Ind01", {"ATIVID","EMPRESA","FILIAL" } )
	oTmpTbl1:AddIndex("Ind02", {"ATIVID","EMPRESA","FILIAL","CODBEM"})
	oTmpTbl1:AddIndex("Ind03", {"ATIVID","EMPRESA","FILIAL","CODFAMI"})
	
	// Cria a tabela temporaria
	oTmpTbl1:Create()

	cAliasQry := GetNextAlias()

	// A temporary table não aceita a inclusão de um indice que utilize parte de um já existente.
	// Tratativa para que seja possivel utilizar o indice ATIVID + EMPRESA + FILIAL
	If MV_PAR11 == 1
		nIndex := 3
	ElseIf MV_PAR11 == 3
		nIndex := 1
	EndIf

	aEmpFil := 	f065RetEmp( MV_PAR01,MV_PAR02 )
	cEmpOld := cEmpAnt
	SetRegua( Len( aEmpFil ) )
	For nZ := 1 To Len( aEmpFil )

		_cEmpAnt := aEmpFil[nZ][1]
		cFilAnt  := aEmpFil[nZ][2]

		If Len(aEmpFil[nZ]) > 2
			cFilAte := aEmpFil[nZ][3]
		Else
			cFilAte := aEmpFil[nZ][2]
		EndIf

		IncRegua()

		If !NGAliasInDic("TV1",_cEmpAnt) .Or. !NGAliasInDic("TV2",_cEmpAnt) .Or. !NGAliasInDic("ST9",_cEmpAnt) .Or. !NGAliasInDic("TV0",_cEmpAnt) .Or.;
			!M985ChkTbl( { "TV1","TV2","ST9","TV0" },_cEmpAnt )
			Loop
		EndIf

		cQuery := " SELECT A.TV1_FILIAL,A.TV1_CODBEM,A.TV1_DTSERV,A.TV1_TURNO,B.TV2_CODFRE,B.TV2_CODATI,B.TV2_HRINI,B.TV2_HRFIM,C.T9_CODFAMI,"
		cQuery += "        C.T9_CALENDA,A.TV1_EMPRES,B.TV2_EMPRES,D.TV0_TIPHOR,A.TV1_HRFIM,A.TV1_HRINI,A.R_E_C_N_O_,B.TV2_TOTHOR,D.TV0_CODATI"
		cQuery += "   FROM " + RetFullName("TV1",_cEmpAnt) + " A," + RetFullName("TV2",_cEmpAnt) + " B," + RetFullName("ST9",_cEmpAnt) + " C," +;
		                       RetFullName("TV0",_cEmpAnt) + " D"
		cQuery += "  WHERE A.TV1_CODBEM = B.TV2_CODBEM AND A.TV1_HRINI = B.TV2_PDIHRI AND A.TV1_CODBEM=C.T9_CODBEM AND C.T9_SITBEM = 'A'"
		cQuery += "    AND A.TV1_DTSERV = B.TV2_DTSERV AND A.TV1_TURNO = B.TV2_TURNO"
		cQuery += "    AND A.TV1_EMPRES = B.TV2_EMPRES AND A.TV1_FILIAL = B.TV2_FILIAL"
		cQuery += "    AND A.TV1_FILIAL BETWEEN '" + cFilAnt + "' AND '" + cFilAte + "'"
		cQuery += "    AND A.TV1_DTSERV BETWEEN '" + DTOS( MV_PAR09 ) + "' AND '" + DTOS( MV_PAR10 ) + "'"
		cQuery += "    AND B.TV2_CODFRE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"
		cQuery += "    AND B.TV2_CODATI BETWEEN '" + MV_PAR12 + "' AND '" + MV_PAR13 + "'"

		If MV_PAR11 == 1
			cQuery += "    AND C.T9_CODFAMI BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "'"
		EndIf
		cQuery += "    AND C.T9_CODBEM  BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "'"

		cQuery += "    AND B.TV2_CODATI = D.TV0_CODATI "
		cQuery += "    AND A.D_E_L_E_T_ <> '*' AND B.D_E_L_E_T_<>'*' AND C.D_E_L_E_T_<>'*' AND D.D_E_L_E_T_<>'*'"
		cQuery += "  ORDER BY B.TV2_CODATI,A.TV1_EMPRES,A.TV1_FILIAL,C.T9_CODFAMI,A.TV1_CODBEM,A.TV1_DTSERV"
		cQuery := ChangeQuery( cQuery )

		DbUseArea( .T., "TOPCONN", TCGenQry( ,,cQuery ),cAliasQry, .F., .T. )

		ProcRegua( LastRec() )

		aRecTRBR := {}

		DbSelectArea( cALIASQRY )
		While !EoF()

			If MV_PAR11 == 2
				cSeek := ( cALIASQRY )->TV2_CODATI + _cEmpAnt + ( cALIASQRY )->TV1_FILIAL + ( cALIASQRY )->TV1_CODBEM
			ElseIf MV_PAR11 == 1
				cSeek := ( cALIASQRY )->TV2_CODATI + _cEmpAnt + ( cALIASQRY )->TV1_FILIAL+( cALIASQRY )->T9_CODFAMI
			Else
				cSeek := ( cALIASQRY )->TV2_CODATI + _cEmpAnt + ( cALIASQRY )->TV1_FILIAL
			EndIf

			nDifHrsTV1 := HTON( ( cALIASQRY )->TV1_HRFIM ) - HTON( ( cALIASQRY )->TV1_HRINI )
			DbSelectArea(cTRB)
			DbSetOrder( nIndex )
			If !DbSeek( cSeek )
				lRecTrue := .T.
				(cTRB)->(DbAppend())

				(cTRB)->EMPRESA	:= _cEmpAnt
				(cTRB)->FILIAL		:= ( cALIASQRY )->TV1_FILIAL
				DbSelectArea( "SM0" )
				SM0->( DbSetOrder( 1 ) )
				If MsSeek( _cEmpAnt + ( cALIASQRY )->TV1_FILIAL )
					(cTRB)->NOMFL := SM0->M0_FILIAL
				Else
					(cTRB)->NOMFL := " "
				EndIf
				(cTRB)->CODBEM	:= ( cALIASQRY )->TV1_CODBEM
				(cTRB)->CODFAMI	:= ( cALIASQRY )->T9_CODFAMI
				dDtServ 		:= STOD((cALIASQRY)->TV1_DTSERV )
				(cTRB)->FRENTE	:= ( cALIASQRY )->TV2_CODFRE
				(cTRB)->ATIVID	:= ( cALIASQRY )->TV2_CODATI
				(cTRB)->DTSERV	:= STOD((cALIASQRY )->TV1_DTSERV)
				(cTRB)->HRATINI	:= ( cALIASQRY )->TV2_HRINI
				(cTRB)->HRATFIM	:= ( cALIASQRY )->TV2_HRFIM
				(cTRB)->HRSHTB	:= 0

				(cTRB)->HRSDPN := fRetHrsDRes( cALIASQRY )

				If ( cALIASQRY )->TV0_TIPHOR == "1" // Horas Trabalhadas
					(cTRB)->HRSHTB	:= HTON( ( cALIASQRY )->TV2_TOTHOR )
				EndIf
				If ( ( cALIASQRY )->TV0_TIPHOR == "1" .And. ( cALIASQRY )->TV0_CODATI == ( cALIASQRY )->TV2_CODATI) .Or. ( ( cALIASQRY )->TV0_TIPHOR != "1" )
					(cTRB)->HRSATI	:= HTON( ( cALIASQRY )->TV2_TOTHOR )
				EndIf
			Else
				lRecTrue := .F.
				RecLock((cTRB),.F. )
				If dDtServ <> STOD( ( cALIASQRY )->TV1_DTSERV )
					dDtServ := STOD( ( cALIASQRY )->TV1_DTSERV )
				EndIf
				If ( cALIASQRY )->TV0_TIPHOR == "1" // Horas Trabalhadas
					(cTRB)->HRSHTB	+= HTON( ( cALIASQRY )->TV2_TOTHOR )
				EndIf
				If (( cALIASQRY )->TV0_TIPHOR == "1" .And. ( cALIASQRY )->TV0_CODATI == ( cALIASQRY )->TV2_CODATI)  .Or. ( ( cALIASQRY )->TV0_TIPHOR != "1" )
					(cTRB)->HRSATI += HTON( ( cALIASQRY )->TV2_TOTHOR )
				EndIf
			EndIf

			nPos := aScan( aRECTV1,{ |x| x == ( cALIASQRY )->( TV1_FILIAL+TV1_EMPRES+TV1_CODBEM+TV1_DTSERV+TV1_TURNO+TV1_HRINI+TV1_HRFIM ) } )
			nPos := 1
			If nPOS == 0

				(cTRB)->CHAVETV2 := ( cALIASQRY )->( TV1_FILIAL + TV1_EMPRES + TV1_CODBEM + TV1_DTSERV + TV1_TURNO )

				aMinMax := MINMAX055( (cTRB)->CHAVETV2,( cALIASQRY )->TV1_HRINI,( cALIASQRY )->TV1_HRFIM )
				If Len( aMinMax ) > 0
					If HTON( aMinMax[1][2] ) > HTON( aMinMax[1][1] )
						nHrsDisp := ( HTON( aMinMax[1][2] ) - HTON( aMinMax[1][1] ) )
					Else
						nHrsDisp := 24 - HTON(aMinMax[1][1] ) + HTON( aMinMax[1][2] )
					EndIf

					If lRecTrue
						(cTRB)->HRSDPN := nHrsDisp
					Else
						(cTRB)->HRSDPN += nHrsDisp
					EndIf
					nHrsDisp := 0
				EndIf

				aAdd( aRECTV1,( cALIASQRY )->( TV1_FILIAL+TV1_EMPRES+TV1_CODBEM+TV1_DTSERV+TV1_TURNO+TV1_HRINI+TV1_HRFIM ) )
			EndIf

			(cTRB)->(MsUnLock())

			// Acumula Horas Trabalhadas por Familia ou Bem
			If ( cALIASQRY )->TV0_TIPHOR == "1"
				nHTB := (cTRB)->HRSHTB
				nPos := aScan( aHrsHTB,{|x| x[1] == SubStr( cSeek,4,Len( cSeek ) ) } )
				If nPos <> 0
					aHrsHTB[nPos][2] := nHTB
				Else
				   aAdd( aHrsHTB,{ SubStr( cSeek,4,Len( cSeek ) ),nHTB } )
				EndIf
			EndIf

			DbSelectArea( cALIASQRY )
			DbSkip()
		End While
		( cALIASQRY )->( DbCloseArea() )

	Next nZ

	RestArea( aSM0Area )
	cEmpAnt := cEmpOld
	cFilAnt := cOldFil

	DbSelectArea(cTRB)
	DbGoTop()
	If RecCount() = 0
		MsgInfo( STR0024,STR0025 ) //"Não existem dados para imprimir o relatório."###"ATENÇAO"
		oTmpTbl1:Delete()
		Return .F.
	EndIf

	Processa( { |lEND| fProc065() },STR0026 ) // "Processando Arquivo..."

	RODA( nCNTIMPR,cRODATXT,TAMANHO )
	Set Filter To
	Set Device To Screen
	If aReturn[5] == 1
		Set Printer To
		dbCommitAll()
		OurSpool( WNREL )
	EndIf
	MS_FLUSH()

	oTmpTbl1:Delete()

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fProc065
Impressão do relatório

@author Evaldo Cevinscki Jr.
@autor Implementado no produto padrão André Felipe Joriatti
@since 05/12/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Static Function fProc065()

	Local cFil	      := " "
	Local cFam	      := " "
	Local cAti	      := " "
	Local cEmpr       := " "
	Local lJAIMPRIMIU := .T.
	Local lRet        := .T.

	// Acumuladores
	Local nTotHTB     := 0
	Local nTotATI     := 0
	Local nTotDPN     := 0
	Local nI          := 0

	DbSelectArea(cTRB)
	DbSetOrder( MV_PAR11 )
	DbGoTop()
	SetRegua( LastRec() )
	While !Eof()

		If MV_PAR11 != 3
			If cAti <> (cTRB)->ATIVID .Or. cFil <> (cTRB)->FILIAL .Or. cEmpr <> (cTRB)->EMPRESA
				If !Empty( cAti ) .Or. !Empty( cFil ) .Or. !Empty( cEmpr )
					Li := 80
				EndIf
				SomaLinha()
				cAti	:= (cTRB)->ATIVID
				cFil 	:= (cTRB)->FILIAL
				cEmpr := (cTRB)->EMPRESA
			EndIf
		Else
			If nI == 0 .Or. cAti <> (cTRB)->ATIVID
				cAti  := (cTRB)->ATIVID
				cFil  := (cTRB)->FILIAL
				cEmpr := (cTRB)->EMPRESA
				If nI == 0
					SomaLinha()
					nI++
				EndIf
			EndIf
		EndIf

		DbSelectArea(cTRB)
		While !Eof() .And. ( ( MV_PAR11 != 3 .And. cAti == (cTRB)->ATIVID .And. (cTRB)->EMPRESA == cEmpr .And. (cTRB)->FILIAL == cFil ) .Or.;
								 ( MV_PAR11 == 3 .And. cAti == (cTRB)->ATIVID ) )
			IncRegua()
			nHTB := 0
			If MV_PAR11 == 1
				@ Li,000 PSay (cTRB)->CODFAMI
				@ Li,018 PSay NGSEEK( "ST6",(cTRB)->CODFAMI,1,"ST6->T6_NOME" )
				nPos := aScan( aHrsHTB,{ |x| x[1] == (cTRB)->EMPRESA + (cTRB)->FILIAL + (cTRB)->CODFAMI } )
			ElseIf MV_PAR11 == 2
				@ Li,000 PSay (cTRB)->CODBEM
				@ Li,018 PSay NGSEEK( "ST9",(cTRB)->CODBEM,1,"ST9->T9_NOME" )
				nPos := aScan( aHrsHTB,{ |x| x[1] == (cTRB)->EMPRESA + (cTRB)->FILIAL + (cTRB)->CODBEM } )
			Else
				@ Li,000 PSay (cTRB)->ATIVID
				@ Li,018 PSay NGSEEK( "TV0",(cTRB)->ATIVID,1,"TV0->TV0_NOME" )
				nPos := aScan( aHrsHTB,{ |x| x[1] == (cTRB)->EMPRESA + (cTRB)->FILIAL } )
			EndIf

			If nPos <> 0
				nHTB := aHrsHTB[nPos][2]
			EndIf

			If MV_PAR11 != 3
				@ Li,061 + ( 10 - Len( NTOH( nHTB ) ) ) PSay NTOH( nHTB )
			EndIf

			@ Li,073 + ( 10 - Len( NTOH( (cTRB)->HRSATI ) ) ) PSay NTOH( (cTRB)->HRSATI )
			@ Li,085 + ( 10 - Len( NTOH( (cTRB)->HRSDPN ) ) ) PSay NTOH( (cTRB)->HRSDPN )
			nEficAt	:= ( (cTRB)->HRSATI / (cTRB)->HRSDPN ) * 100 // Horas disponíveis
			@ Li,099 PSay nEficAt Picture "@E 9,999.99%"

			nTotHTB += nHTB
			nTotATI += (cTRB)->HRSATI
			If MV_PAR11 == 3
				nTotDPN := (cTRB)->HRSDPN
			Else
				nTotDPN += (cTRB)->HRSDPN
			EndIf

			cEmpr 	:= (cTRB)->EMPRESA
			If MV_PAR11 != 3
				SomaLinha( 58 )
			EndIf

			DbSelectArea(cTRB)
			DbSkip()

		End While
		If ( MV_PAR11 != 3 .And. cAti <> (cTRB)->ATIVID ) .Or. (cTRB)->EMPRESA <> cEmpr .Or. (cTRB)->FILIAL <> cFil .Or. EoF()

			If MV_PAR11 == 3
				SomaLinha( 58 )
			EndIf

			@ Li,010 PSay STR0027 // "Total...: "
			If MV_PAR11 != 3
				@ Li,061 + ( 10 - Len( NTOH( nTotHTB ) ) ) PSay NTOH( nTotHTB )
			Endif
			@ Li,073 + ( 10 - Len( NTOH( nTotATI ) ) ) PSay NTOH( nTotATI )
			@ Li,085 + ( 10 - Len( NTOH( nTotDPN ) ) ) PSay NTOH( nTotDPN )
			nEficAt	:= ( nTotATI / nTotDPN ) * 100
			@ Li,099 PSay nEficAt Picture "@E 9,999.99%"

			nTotHTB := 0
			nTotATI := 0
			nTotDPN := 0
			SomaLinha( 58 )
			SomaLinha( 58 )

		ElseIf MV_PAR11 == 3
			SomaLinha( 58 )
		EndIf

	End While

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} VLDDT065
Valida o parametro ate data

@author Evaldo Cevinscki Jr.
@autor Implementado no produto padrão André Felipe Joriatti
@since 05/12/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Function VLDDT065()

	lRet := .T.

	If  MV_PAR10 < MV_PAR09
		MsgStop( STR0028 ) // "Data final não pode ser inferior à data inicial!"
		lRet := .F.
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} VLDDT065
Controle de quebra de linha e cabecalho

@author Evaldo Cevinscki Jr.
@autor Implementado no produto padrão André Felipe Joriatti
@since 05/12/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Static Function Somalinha()

	Local nVerif := If( nTIPO == 15,75,58 )
	Local lRet   := .T.

	Li++

	If Li > nVerif .And. Li <> 81
	   Cabec( titulo,cabec1,cabec2,nomeprog,tamanho,nTipo )
	   Somalinha()
	EndIf
	If Li == 81
		Cabec( titulo,cabec1,cabec2,nomeprog,tamanho,nTipo )
		If MV_PAR11 != 3
			@ Li,000 PSay STR0029 //"Negócio: "
			@ Li,009 PSay (cTRB)->FILIAL
			@ Li,025 PSay " - " + (cTRB)->NOMFL
			@ Li,076 PSay STR0030  //"Atividade:"
			@ Li,087 PSay (cTRB)->ATIVID + " - "
			@ Li,093 PSay NGSEEK( "TV0",(cTRB)->ATIVID,1,"TV0->TV0_NOME" )
			Somalinha()
		EndIf
		@ Li,000 Psay STR0031 + DTOC( MV_PAR09 ) + STR0032 + DTOC( MV_PAR10 ) // "Período: "###" a "
		Somalinha()
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} VLDDT065
Retorna Empresa , Filial de Inicio e Filial Fim para pesq.

@author Evaldo Cevinscki Jr.
@autor Implementado no produto padrão André Felipe Joriatti
@since 05/12/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Static Function f065RetEmp( cDe,cAte )

	Local aEmpFil := {}
	Local aArea   := SM0->( GetArea() )

	DbSelectArea( "SM0" )
	DbSetOrder( 1 )
	DbGoTop()
	While !EoF()
		If SM0->M0_CODIGO+SM0->M0_CODFIL < cDe .Or. SM0->M0_CODIGO+SM0->M0_CODFIL > cAte
			DbSkip()
			Loop
		EndIf

		If ( nPos := aScan( aEmpFil,{ |x| x[1] == SM0->M0_CODIGO } ) ) == 0
			aAdd( aEmpFil,{ SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_CODFIL } )
		Else
			aEmpFil[nPos][3] := SM0->M0_CODFIL
		EndIf

		DbSelectArea( "SM0" )
		DbSkip()
	End While

	RestArea(aArea)

Return aEmpFil

//---------------------------------------------------------------------
/*/{Protheus.doc} fRetHrsDRes
Recupera total de horas em Parte Diária conforme o parametro
para indicar se deve filtrar por Bem, Família e/ou somente por Filial

@param String cALIASQRY: indica o alias da query executada no relatório
@author André Felipe Joriatti
@since 18/12/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Static Function fRetHrsDRes( cALIASQRY )

	Local cAliasSQL := GetNextAlias()
	Local cQuery    := ""
	Local nTotHrs   := 0

	cQuery := "SELECT TV1_FILIAL,TV1_EMPRES,TV1_CODBEM,TV1_DTSERV,TV1_TURNO,TV1_HRINI,TV1_HRFIM FROM " + RETSQLNAME( "TV1" )
	cQuery += " WHERE TV1_FILIAL = '" + ( cALIASQRY )->( TV1_FILIAL ) + "' AND TV1_EMPRES = '" + ( cALIASQRY )->( TV1_EMPRES ) + "'"
	cQuery += " AND TV1_DTSERV BETWEEN '" + DTOS( MV_PAR09 ) + "' AND '" + DTOS( MV_PAR10 ) + "'"
	cQuery += " AND TV1_CODBEM IN( SELECT T9_CODBEM FROM " + RETSQLNAME( "ST9" ) + " WHERE T9_CODFAMI = '" + ( cALIASQRY )->T9_CODFAMI + "'" + ;
			" AND T9_FILIAL = '" + xFilial( "ST9" ) + "' AND D_E_L_E_T_ != '*' )"
	cQuery += " AND D_E_L_E_T_ != '*'"

	If MV_PAR11 == 1 .Or. MV_PAR11 == 3
		cQuery += " AND TV1_CODBEM BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "'"
	ElseIf MV_PAR11 == 2
		cQuery += " AND TV1_CODBEM = '" + ( cALIASQRY )->TV1_CODBEM + "'"
	EndIf

	cQuery := ChangeQuery( cQuery )

	DbUseArea( .T., "TOPCONN",TCGenQry( ,,cQuery ),cAliasSQL,.F.,.T. )

	While !EoF()
		nTotHrs += HTON( ( cAliasSQL )->TV1_HRFIM ) - HTON( ( cAliasSQL )->TV1_HRINI )
		NGDBSELSKIP( cAliasSQL )
	End While

Return nTotHrs