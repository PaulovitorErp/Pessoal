#Include "Protheus.ch"
#Include "MNTR055.ch"

#Define _nSizeFil NGMTAMFIL()

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR055
Relatorio de Eficiência Operacional apresentará as informações da rotina de
Digitação da Parte Diária, considerando o período informado na tela de parâmetros.

@author Vitor Emanuel Batista
@since 22/04/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Function MNTR055()

	Private WNREL   := "MNTR055"
	Private cPERG   := "MNTR055  "
	Private LIMITE  := 155
	Private cDESC1  := STR0001 // "Relatorio de Eficiência Operacional apresentará as informações da rotina de "
	Private cDESC2  := STR0002 // "Digitação da Parte Diária, considerando o período informado na tela de parâmetros."
	Private cDESC3  := ""
	Private cSTRING := "TV1"

	Private aSM0Area := SM0->( GetArea() )
	Private cOldEmp  := cEmpAnt
	Private cOldFil  := cFilAnt

	Private NOMEPROG      := "MNTR055"
	Private TAMANHO       := "G"
	Private aRETURN       := { STR0003,1,STR0004,1,2,1,"",1 }   // "Zebrado"###"Administracao"
	Private TITULO        := STR0005 // "Relatório de Eficiência Operacional"
	Private nTIPO         := 0
	Private nLASTKEY      := 0
	Private CABEC1
	Private CABEC2

	SetKey( VK_F9,{ || NGVersao( "MNTR055", 2 ) } )

	Pergunte( cPERG,.F. )

	//----------------------------------------
	// Envia controle para a funcao SETPRINT
	//----------------------------------------
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
	RptStatus( { |lEND| Imprimir( @lEND,WNREL,TITULO,TAMANHO ) },TITULO )
	DbSelectArea( "TV1" )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} Imprimir
Chamada do relatório.

@author Evaldo Cevinscki Jr.
@since 13/05/2010
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Static Function Imprimir( lEND,WNREL,TITULO,TAMANHO )

	Local aTable    := { { "TV1" },{ "TV2" },{ "TV0" },{ "ST6" },{ "ST9" } }
	Local cAliasQry
	Local cQuery
	Local nX
	Local nZ
	Local _cAtivid := ""
	Local aRECTV1  := {}
	Local oTmpTbl1

	Private cRODATXT := ""
	Private nCNTIMPR := 0
	Private li       := 80
	Private m_pag    := 1
	Private cFiliIni
	Private cTRB := GetNextAlias()

	nTIPO  := IIf( aReturn[4] == 1,15,18 )
	CABEC1 := STR0040 + If( MV_PAR11 == 1,STR0026,"" ) // "                                                  Horas       Horas        Horas         Horas    Horas    Horas     Horas Mec.    Dispon.    Ind. Util.   Ind. Util.   Eficiência    Coeficiente  Custos"###"         Data"
	CABEC2 := STR0027 + If( MV_PAR11 == 1,STR0028,"" ) // "Código            Descrição                       Expediente  Trabalhadas  Manutenção    Chuva    Planej.  Operac.   Disponíveis   Mecânica   Bruta        Líquida      Operacional   Utilização   Manutenção"###"     Serviço"

	/*
	          1         2         3         4         5         6         7         8         9         0         1         2         3        4         5         6
	0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345679012345678901234567890123456
	**********************************************************************************************************************************************************************
													    Relatório de Eficiência Operacional		-		Periodo: 99/99/99 a 99/99/99
	**********************************************************************************************************************************************************************
	                                                  Horas       Horas        Horas         Horas    Horas    Horas     Horas Mec.    Dispon.    Ind. Util.   Ind. Util.   Eficiência    Coeficiente  Custos
	Código            Descrição                       Expediente  Trabalhadas  Manutenção    Chuva    Planej.  Operac.   Disponíveis   Mecânica   Bruta        Líquida      Operacional   Utilização   Manutenção
	**********************************************************************************************************************************************************************
	Negócio: XXXXXXXXXXXXXXXXXXXX
	Família: XXXXXX - XXXXXXXXXXXXXXXXXXXX

	xxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx     99:99        99:99       99:99    99:99     99:99     99:99         99:99

	xxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  99,999.99   99,999.99  99,999.99  99,999.99     99,999.99    999.99       999.99       999.99       999.99  999,999.99  99/99/9999
	xxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  99,999.99   99,999.99  99,999.99  99,999.99     99,999.99    999.99       999.99       999.99       999.99  999,999.99  99/99/9999
	xxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  99,999.99   99,999.99  99,999.99  99,999.99     99,999.99    999.99       999.99       999.99       999.99  999,999.99  99/99/9999

							Total Frente de Trabalho:         99,999.99   99,999.99  99,999.99  99,999.99    999.99       999.99       999.99       999.99  999,999.99

							Total Família: XXXXXX             99,999.99   99,999.99  99,999.99  99,999.99    999.99       999.99       999.99       999.99  999,999.99

							Total da Filial:                  99,999.99   99,999.99  99,999.99  99,999.99    999.99       999.99       999.99       999.99  999,999.99

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
	aAdd( aDBF,{ "TV1HIN"	,"C",5,0 } )
	aAdd( aDBF,{ "TV1HFI"	,"C",5,0 } )
	aAdd( aDBF,{ "HRATFIM"	,"C",5,0 } )
	aAdd( aDBF,{ "HRSEXP"	,"N",9,2 } )
	aAdd( aDBF,{ "HRSDPN"	,"N",9,2 } )
	aAdd( aDBF,{ "HRSHTB"	,"N",9,2 } )
	aAdd( aDBF,{ "HRSMNT"	,"N",9,2 } )
	aAdd( aDBF,{ "HRSCHV"	,"N",9,2 } )
	aAdd( aDBF,{ "HRSPLN"	,"N",9,2 } )
	aAdd( aDBF,{ "CUSMNT"	,"N",9,2 } )
	aAdd( aDBF,{ "TURNO"	,"C",3,0 } )
	aAdd( aDBF,{ "CHAVETV2" ,"C",31,0 } )



	//Intancia classe FWTemporaryTable
	oTmpTbl1 := FWTemporaryTable():New(cTRB, aDBF)
	//Cria indices
	oTmpTbl1:AddIndex( "Ind01" , {"EMPRESA","FILIAL","CODBEM","DTSERV"})
	oTmpTbl1:AddIndex( "Ind02" , {"EMPRESA","FILIAL","CODFAMI"})
	oTmpTbl1:AddIndex( "Ind03" , {"EMPRESA","FILIAL","CODFAMI","CODBEM","DTSERV","TURNO","TV1HIN","TV1HFI"})
	//Cria a tabela temporaria
	oTmpTbl1:Create()

	aEmpFil := EmpDeAte( MV_PAR01,MV_PAR02 )

	cEmpOld := cEmpAnt

	SetRegua( Len( aEmpFil ) )
	For nZ := 1 To Len( aEmpFil )

		_cEmpAnt := aEmpFil[nZ][1]
		cFilAnt  := aEmpFil[nZ][2]
		IncRegua()

		If !NGAliasInDic("STJ",_cEmpAnt) .Or. !NGAliasInDic("TV2",_cEmpAnt) .Or. !NGAliasInDic("TV1",_cEmpAnt) .Or. !NGAliasInDic("ST9",_cEmpAnt) .Or.;
		   !M985ChkTbl( { "STJ","TV2","TV1","ST9" },_cEmpAnt )
			Loop
		EndIf

		cAliasQry := GetNextAlias()
		cQuery := " SELECT A.TV1_FILIAL,A.TV1_CODBEM,A.TV1_DTSERV,A.TV1_TURNO,B.TV2_CODFRE,B.TV2_CODATI,B.TV2_TOTHOR,C.T9_CODBEM,A.TV1_HRAEXP,"
		cQuery += "        B.TV2_HRINI,B.TV2_HRFIM,C.T9_CODFAMI,C.T9_CALENDA,A.TV1_EMPRES,B.TV2_EMPRES,A.TV1_HRFIM,A.TV1_HRINI,A.R_E_C_N_O_"
		cQuery += "   FROM " + RetFullName("TV1",_cEmpAnt) + " A," + RetFullName("TV2",_cEmpAnt) + " B," + RetFullName("ST9",_cEmpAnt) + " C"
		cQuery += "  WHERE A.TV1_INDERR = '2' AND A.TV1_CODBEM = B.TV2_CODBEM AND A.TV1_HRINI = B.TV2_PDIHRI AND A.TV1_CODBEM=C.T9_CODBEM AND C.T9_SITBEM = 'A'"
		cQuery += "    AND A.TV1_DTSERV = B.TV2_DTSERV AND A.TV1_TURNO = B.TV2_TURNO"
		cQuery += "    AND (A.TV1_EMPRES = B.TV2_EMPRES AND A.TV1_FILIAL = B.TV2_FILIAL)"
		cQuery += "    AND (A.TV1_EMPRES||A.TV1_FILIAL) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
		cQuery += "    AND A.TV1_DTSERV BETWEEN '" + DTOS( MV_PAR09 ) + "' AND '" + DTOS( MV_PAR10 ) + "'"
		cQuery += "    AND B.TV2_CODFRE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"
		If MV_PAR11 == 2
			cQuery += "    AND C.T9_CODFAMI BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "'"
		EndIf
		cQuery += "    AND C.T9_CODBEM  BETWEEN '" + MV_PAR07+"' AND '" + MV_PAR08 + "'"
		cQuery += "    AND A.D_E_L_E_T_<>'*' AND B.D_E_L_E_T_<>'*' AND C.D_E_L_E_T_<>'*'"
		cQuery += "  ORDER BY A.TV1_EMPRES,A.TV1_FILIAL,C.T9_CODFAMI,A.TV1_CODBEM,B.TV2_CODFRE,A.TV1_DTSERV,B.TV2_CODATI"

		cQuery := ChangeQuery( cQuery )

		DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T. )

		ProcRegua( LastRec() )

		DbSelectArea( cALIASQRY )
		While !EoF()

			_cAtivid := AllTrim( NGSEEK( "TV0",( cAliasQry )->TV2_CODATI,01,"TV0->TV0_TIPHOR" ) )

			//TV1_FILIAL+TV1_EMPRES+TV1_CODBEM+DTOS( TV1_DTSERV )+TV1_TURNO+TV1_HRINI+TV1_HRFIM
			DbSelectArea(cTRB)
			DbSetOrder( 03 )
			cSeek := _cEmpAnt + ( cALIASQRY )->TV1_FILIAL + ( cALIASQRY )->T9_CODFAMI + ( cALIASQRY )->TV1_CODBEM + ( cALIASQRY )->TV1_DTSERV +;
			( cALIASQRY )->TV1_TURNO + ( cALIASQRY )->TV1_HRINI + ( cALIASQRY )->TV1_HRFIM

			If !DbSeek( cSeek )

				lRecTrue := .T.
				(cTRB)->( DbAppend() )

				(cTRB)->EMPRESA := _cEmpAnt
				(cTRB)->FILIAL	 := ( cALIASQRY )->TV1_FILIAL
				DbSelectArea( "SM0" )
				SM0->( DbSetOrder( 1 ) )

				If MsSeek( _cEmpAnt + ( cALIASQRY )->TV1_FILIAL )
					(cTRB)->NOMFL := SM0->M0_FILIAL
				Else
					(cTRB)->NOMFL := " "
				EndIf

				(cTRB)->CODBEM	 := (cALIASQRY)->TV1_CODBEM
				(cTRB)->CODFAMI := (cALIASQRY)->T9_CODFAMI
				dDtServ 	 := StoD((cALIASQRY)->TV1_DTSERV)
				(cTRB)->HRSDPN  := NGRETHORDDH(NGCALENHORA(dDtServ,"00:00",dDtServ,"24:00",(cALIASQRY)->T9_CALENDA,(cALIASQRY)->TV1_FILIAL))[2]
				(cTRB)->FRENTE	 := (cALIASQRY)->TV2_CODFRE
				(cTRB)->ATIVID	 := (cALIASQRY)->TV2_CODATI
				(cTRB)->DTSERV	 := StoD((cALIASQRY)->TV1_DTSERV)
				(cTRB)->TV1HIN  := (cALIASQRY)->TV1_HRINI
				(cTRB)->TV1HFI  := (cALIASQRY)->TV1_HRFIM
				(cTRB)->HRSEXP	 := HTON((cALIASQRY)->TV1_HRAEXP)
				(cTRB)->HRSHTB	 := 0
				(cTRB)->HRSMNT	 := 0
				(cTRB)->HRSCHV	 := 0
				(cTRB)->HRSPLN	 := 0
				(cTRB)->CUSMNT	 := fR055CUSTO( (cALIASQRY)->TV1_DTSERV,(cALIASQRY)->TV2_HRINI,(cALIASQRY)->TV1_EMPRES,(cALIASQRY)->TV1_FILIAL,(cALIASQRY)->T9_CODBEM )
				(cTRB)->TURNO   := ( cALIASQRY )->TV1_TURNO

				If _cAtivid == '1' //Horas Trabalhadas
					(cTRB)->HRSHTB	:= HTON( (cALIASQRY)->TV2_TOTHOR ) //Htom(NGCALCHCAR((cTRB)->DTSERV,(cALIASQRY)->TV2_HRINI,(cTRB)->DTSERV,(cALIASQRY)->TV2_HRFIM)) / 60
				ElseIf _cAtivid == '3' //Horas Manutencao
	           	(cTRB)->HRSMNT	:= HTON( (cALIASQRY)->TV2_TOTHOR ) //Htom(NGCALCHCAR((cTRB)->DTSERV,(cALIASQRY)->TV2_HRINI,(cTRB)->DTSERV,(cALIASQRY)->TV2_HRFIM)) / 60
				ElseIf _cAtivid == '2' //Horas Chuva
					(cTRB)->HRSCHV	:=	HTON( (cALIASQRY)->TV2_TOTHOR ) //Htom(NGCALCHCAR((cTRB)->DTSERV,(cALIASQRY)->TV2_HRINI,(cTRB)->DTSERV,(cALIASQRY)->TV2_HRFIM)) / 60
				ElseIf _cAtivid == '4' //Horas Planejamento
					(cTRB)->HRSPLN	:=	HTON( (cALIASQRY)->TV2_TOTHOR ) //Htom(NGCALCHCAR((cTRB)->DTSERV,(cALIASQRY)->TV2_HRINI,(cTRB)->DTSERV,(cALIASQRY)->TV2_HRFIM)) / 60
				EndIf
			Else

				lRecTrue := .F.
				RecLock((cTRB),.F. )

				If (cALIASQRY)->TV2_HRINI < (cTRB)->HRATINI
					(cTRB)->HRATINI := (cALIASQRY)->TV2_HRINI
				EndIf

				If (cALIASQRY)->TV2_HRFIM > (cTRB)->HRATFIM
					(cTRB)->HRATFIM := (cALIASQRY)->TV2_HRFIM
				EndIf

				If dDtServ <> STOD((cALIASQRY)->TV1_DTSERV)
					dDtServ     := STOD((cALIASQRY)->TV1_DTSERV)
					(cTRB)->HRSDPN += NGRETHORDDH(NGCALENHORA(dDtServ,"00:00",dDtServ,"24:00",(cALIASQRY)->T9_CALENDA,(cALIASQRY)->TV1_FILIAL))[2]
				EndIf

				If _cAtivid == '1' //Horas Trabalhadas
					(cTRB)->HRSHTB	+= HTON( (cALIASQRY)->TV2_TOTHOR ) //Htom(NGCALCHCAR((cTRB)->DTSERV,(cALIASQRY)->TV2_HRINI,(cTRB)->DTSERV,(cALIASQRY)->TV2_HRFIM)) / 60
				ElseIf _cAtivid == '3' //Horas Manutencao
		  			(cTRB)->HRSMNT	+= HTON( (cALIASQRY)->TV2_TOTHOR ) //Htom(NGCALCHCAR((cTRB)->DTSERV,(cALIASQRY)->TV2_HRINI,(cTRB)->DTSERV,(cALIASQRY)->TV2_HRFIM)) / 60
				ElseIf _cAtivid == '2' //Horas Chuva
					(cTRB)->HRSCHV	+=	HTON( (cALIASQRY)->TV2_TOTHOR ) //Htom(NGCALCHCAR((cTRB)->DTSERV,(cALIASQRY)->TV2_HRINI,(cTRB)->DTSERV,(cALIASQRY)->TV2_HRFIM)) / 60
				ElseIf _cAtivid == '4' //Horas Planejamento
					(cTRB)->HRSPLN	+=	HTON( (cALIASQRY)->TV2_TOTHOR ) //Htom(NGCALCHCAR((cTRB)->DTSERV,(cALIASQRY)->TV2_HRINI,(cTRB)->DTSERV,(cALIASQRY)->TV2_HRFIM)) / 60
				EndIf

			EndIf

			(cTRB)->(MsUnLock())

			DbSelectArea( cALIASQRY )
			DbSkip()
		EndDo

		( cAliasQry )->( DbCloseArea() )

	Next nZ

	cEmpAnt := cEmpOld

	RestArea( aSM0Area )

	cFilAnt := cOldFil

	DbSelectArea(cTRB)
	DbGoTop()
	If RecCount() = 0
		MsgInfo(STR0030,STR0031) //"No existem dados para imprimir o relatrio."###"ATENAO"
		oTmpTbl1:Delete()
		Return .f.
	EndIf

	Processa( { |lEND| f055PROC() },STR0032 )   // "Processando Arquivo..."

	Roda( nCNTIMPR,cRODATXT,TAMANHO )
	Set Filter To
	Set Device To Screen
	If aReturn[5] == 1
		Set Printer To
		dbCommitAll()
		OurSpool(WNREL)
	EndIf
	MS_FLUSH()
	oTmpTbl1:Delete()

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} f055PROC
No fonte especifico era: OASR1PROC
Processa.

@author Evaldo Cevinscki Jr.
@since 13/05/2010
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

// Static Function OASR1PROC()
Static Function f055PROC()

	Local cFil	      := " "
	Local cFam	      := " "
	Local cBem	      := " "
	Local cEmpr       := " "
	Local lJAIMPRIMIU := .T.

	// acumuladores Frente
	Local nTotFtEXP := 0, nTotFtHTB := 0,nTotFtMNT := 0,nTotFtCHV := 0,nTotFtPLN := 0, nTotFtCUS := 0

	// acumuladores Familia
	Local nTotFmEXP := 0, nTotFmHTB := 0,nTotFmMNT := 0,nTotFmCHV := 0,nTotFmPLN := 0, nTotFmCUS := 0

	// acumuladores Filial
	Local nTotFlEXP := 0, nTotFlHTB := 0,nTotFlMNT := 0,nTotFlCHV := 0,nTotFlPLN := 0,nTotFlCUS := 0

	dbSelectArea(cTRB)
	dbSetOrder(3)
	dbGoTop()
	SetRegua(LastRec())
	While !EoF()

		If lJAIMPRIMIU

			SomaLinha(58)
			@ Li,000 Psay STR0033 + DTOC(MV_PAR09) + STR0034 + DTOC(MV_PAR10) //"Perodo: "###" a "
			lJAIMPRIMIU := .F.
			SomaLinha(58)

		EndIf

		If cFil <> (cTRB)->FILIAL

			cFil := (cTRB)->FILIAL
			@ Li,000 PSay STR0035 //"Negcio: "
			@ Li,009 PSay (cTRB)->FILIAL
			@ Li,025 PSay " - " + (cTRB)->NOMFL
			SomaLinha(58)
			SomaLinha(58)

		EndIf

		dbSelectArea(cTRB)
		While !EoF() .And. (cTRB)->FILIAL == cFil

			If cFam <> (cTRB)->CODFAMI .And. MV_PAR11 == 2
				cFam := (cTRB)->CODFAMI
				If !lJAIMPRIMIU
					SomaLinha(58)
				EndIf
			EndIF

			If cBem <> (cTRB)->CODBEM
				cBem := (cTRB)->CODBEM
			EndIf

			dbSelectArea(cTRB)
			While !EoF() .And. cFil == (cTRB)->FILIAL .And. cBem == (cTRB)->CODBEM

				IncRegua()

				If MV_PAR11 == 1
					@ Li,000 Psay (cTRB)->CODBEM
					@ Li,018 Psay NGSEEK("ST9",(cTRB)->CODBEM,1,"SubStr(ST9->T9_NOME,1,30)")
					//@ Li,040 Psay (cTRB)->FRENTE
					@ Li,050+(10-Len(NtoH((cTRB)->HRSEXP))) Psay NTOH((cTRB)->HRSEXP)
					@ Li,063+(10-Len(NtoH((cTRB)->HRSHTB))) Psay NTOH((cTRB)->HRSHTB)
					@ Li,075+(10-Len(NtoH((cTRB)->HRSMNT))) Psay NTOH((cTRB)->HRSMNT)
					@ Li,084+(10-Len(NtoH((cTRB)->HRSCHV))) Psay NTOH((cTRB)->HRSCHV)
					@ Li,095+(10-Len(NtoH((cTRB)->HRSPLN))) Psay NTOH((cTRB)->HRSPLN)
					//Coluna 5
					nHrasOper := (cTRB)->HRSEXP - (cTRB)->HRSMNT - (cTRB)->HRSCHV
					@ Li,104+(10-Len(NtoH(nHrasOper))) Psay NTOH(nHrasOper)
					//Coluna 6
					nHrasMecDi := (cTRB)->HRSEXP - (cTRB)->HRSMNT
					@ Li,118+(10-Len(NtoH(nHrasMecDi))) Psay NTOH(nHrasMecDi)
					//Coluna 7
					nDispMec := (1 - ((cTRB)->HRSMNT / (cTRB)->HRSEXP)) * 100
					@ Li,131 Psay nDispMec Picture "@E 9999.99%"
					//Coluna 8
					@ Li,144 Psay (((cTRB)->HRSHTB / (cTRB)->HRSEXP) * 100) Picture "@E 9999.99%"
					//Coluna 9
					@ Li,157 Psay (((cTRB)->HRSHTB / nHrasOper) * 100) Picture "@E 9999.99%"
					//Coluna 10
					nEficOper := (((cTRB)->HRSHTB / nHrasMecDi) * 100)
					@ Li,171 Psay nEficOper Picture "@E 9999.99%"
					//Coluna 11
					@ Li,185 Psay ((nEficOper / nDispMec) * 100) Picture "@E 9999.99%"
					//Coluna 11
					@ Li,195 Psay (cTRB)->CUSMNT Picture "@E 999,999.99"
					If MV_PAR11 == 1
						@ Li,210 Psay (cTRB)->DTSERV Picture "99/99/9999"
					EndIf

					SomaLinha(58)

				EndIf

				nTotFtEXP += (cTRB)->HRSEXP
				nTotFtHTB += (cTRB)->HRSHTB
				nTotFtMNT += (cTRB)->HRSMNT
				nTotFtCHV += (cTRB)->HRSCHV
				nTotFtPLN += (cTRB)->HRSPLN
				nTotFtCUS += (cTRB)->CUSMNT

				nTotFlEXP += (cTRB)->HRSEXP
				nTotFlHTB += (cTRB)->HRSHTB
				nTotFlMNT += (cTRB)->HRSMNT
				nTotFlCHV += (cTRB)->HRSCHV
				nTotFlPLN += (cTRB)->HRSPLN
				nTotFlCUS += (cTRB)->CUSMNT

				nTotFmEXP += (cTRB)->HRSEXP
				nTotFmHTB += (cTRB)->HRSHTB
				nTotFmMNT += (cTRB)->HRSMNT
				nTotFmCHV += (cTRB)->HRSCHV
				nTotFmPLN += (cTRB)->HRSPLN
				nTotFmCUS += (cTRB)->CUSMNT

				cEmpr 	:= (cTRB)->EMPRESA
				dbSelectArea(cTRB)
				dbSkip()
			EndDo

			If cBem <> (cTRB)->CODBEM .Or. EoF()

				If MV_PAR11 == 1
					SomaLinha(58)
		        	@ Li,010 Psay STR0036 //"Total do Bem: "
		  		Else
					@ Li,000 Psay cBem
					@ Li,018 Psay NGSEEK("ST9",cBem,1,"SubStr(ST9->T9_NOME,1,30)")
		  		EndIf

				@ Li,050+(10-Len(NtoH(nTotFtEXP))) Psay NTOH(nTotFtEXP)
				@ Li,063+(10-Len(NtoH(nTotFtHTB))) Psay NTOH(nTotFtHTB)
				@ Li,075+(10-Len(NtoH(nTotFtMNT))) Psay NTOH(nTotFtMNT)
				@ Li,084+(10-Len(NtoH(nTotFtCHV))) Psay NTOH(nTotFtCHV)
				@ Li,095+(10-Len(NtoH(nTotFtPLN))) Psay NTOH(nTotFtPLN)

				//Coluna 5
				nHrasOper := nTotFtEXP - nTotFtMNT - nTotFtCHV
				@ Li,104+(10-Len(NtoH(nHrasOper))) Psay NTOH(nHrasOper)

				//Coluna 6
				nHrasMecDi := nTotFtEXP - nTotFtMNT
				@ Li,118+(10-Len(NtoH(nHrasMecDi))) Psay NTOH(nHrasMecDi)

				//Coluna 7
				nDispMec := (1 - (nTotFtMNT / nTotFtEXP)) * 100
				@ Li,131 Psay nDispMec Picture "@E 9999.99%"

				//Coluna 8
				@ Li,144 Psay ((nTotFtHTB / nTotFtEXP) * 100) Picture "@E 9999.99%"

				//Coluna 9
				@ Li,157 Psay ((nTotFtHTB / nHrasOper) * 100) Picture "@E 9999.99%"

				//Coluna 10
				nEficOper := ((nTotFtHTB / nHrasMecDi) * 100)
				@ Li,171 Psay nEficOper Picture "@E 9999.99%"

				//Coluna 11
				@ Li,185 Psay ((nEficOper / nDispMec) * 100) Picture "@E 9999.99%"

				//Coluna 12
				@ Li,195 Psay nTotFtCUS Picture "@E 999,999.99"

				nTotFtEXP := 0
				nTotFtHTB := 0
				nTotFtMNT := 0
				nTotFtCHV := 0
				nTotFtPLN := 0
				nTotFtCUS := 0
				SomaLinha(58)
				If MV_PAR11 == 1
					SomaLinha(58)
				EndIf
			EndIf

			If (cFam <> (cTRB)->CODFAMI .And. MV_PAR11 == 2 )  .Or. (EoF() .And. MV_PAR11 == 2)
				SomaLinha(58)
				@ Li,010 Psay STR0037+NGSEEK("ST6",cFam,1,"SubStr(ST6->T6_NOME,1,20)") //"Total Família: "
				@ Li,050+(10-Len(NTOH(nTotFmEXP))) Psay NTOH(nTotFmEXP)
				@ Li,063+(10-Len(NTOH(nTotFmHTB))) Psay NTOH(nTotFmHTB)
				@ Li,075+(10-Len(NTOH(nTotFmMNT))) Psay NTOH(nTotFmMNT)
				@ Li,084+(10-Len(NTOH(nTotFmCHV))) Psay NTOH(nTotFmCHV)
				@ Li,095+(10-Len(NTOH(nTotFmPLN))) Psay NTOH(nTotFmPLN)

				//Coluna 5
				nHrasOper := nTotFmEXP - nTotFmMNT - nTotFmCHV
				@ Li,104+(10-Len(NTOH(nHrasOper))) Psay NTOH(nHrasOper)

				//Coluna 6
				nHrasMecDi := nTotFmEXP - nTotFmMNT
				@ Li,118+(10-Len(NTOH(nHrasMecDi))) Psay NTOH(nHrasMecDi)

				//Coluna 7
				nDispMec := (1 - (nTotFmMNT / nTotFmEXP)) * 100
				@ Li,131 Psay nDispMec Picture "@E 9999.99%"

				//Coluna 8
				@ Li,144 Psay ((nTotFmHTB / nTotFmEXP) * 100) Picture "@E 9999.99%"

				//Coluna 9
				@ Li,157 Psay ((nTotFmHTB / nHrasOper) * 100) Picture "@E 9999.99%"

				//Coluna 10
				nEficOper := ((nTotFmHTB / nHrasMecDi) * 100)
				@ Li,171 Psay nEficOper Picture "@E 9999.99%"

				//Coluna 11
				@ Li,185 Psay ((nEficOper / nDispMec) * 100) Picture "@E 9999.99%"

				//Coluna 12
				@ Li,195 Psay nTotFmCUS Picture "@E 999,999.99"

				nTotFmEXP := 0
				nTotFmHTB := 0
				nTotFmMNT := 0
				nTotFmCHV := 0
				nTotFmPLN := 0
				nTotFmCUS := 0
				SomaLinha(58)
			EndIf

			If cFil <> (cTRB)->FILIAL .Or. Eof()
				SomaLinha(58)
				@ Li,010 Psay STR0038+NGSEEK("SM0",cEmpr+cFil,1,"SM0->M0_FILIAL") //"Total Filial: "
				@ Li,050+(10-Len(NTOH(nTotFlEXP))) Psay NTOH(nTotFlEXP)
				@ Li,063+(10-Len(NTOH(nTotFlHTB))) Psay NTOH(nTotFlHTB)
				@ Li,075+(10-Len(NTOH(nTotFlMNT))) Psay NTOH(nTotFlMNT)
				@ Li,084+(10-Len(NTOH(nTotFlCHV))) Psay NTOH(nTotFlCHV)
				@ Li,095+(10-Len(NTOH(nTotFlPLN))) Psay NTOH(nTotFlPLN)

				//Coluna 5
				nHrasOper := nTotFlEXP - nTotFlMNT - nTotFlCHV
				@ Li,104+(10-Len(NTOH(nHrasOper))) Psay NTOH(nHrasOper)

				//Coluna 6
				nHrasMecDi := nTotFlEXP - nTotFlMNT
				@ Li,118+(10-Len(NTOH(nHrasMecDi))) Psay NTOH(nHrasMecDi)

				//Coluna 7
				nDispMec := (1 - (nTotFlMNT / nTotFlEXP)) * 100
				@ Li,131 Psay nDispMec Picture "@E 9999.99%"

				//Coluna 8
				@ Li,144 Psay ((nTotFlHTB / nTotFlEXP) * 100) Picture "@E 9999.99%"

				//Coluna 9
				@ Li,157 Psay ((nTotFlHTB / nHrasOper) * 100) Picture "@E 9999.99%"

				//Coluna 10
				nEficOper := ((nTotFlHTB / nHrasMecDi) * 100)
				@ Li,171 Psay nEficOper Picture "@E 9999.99%"

				//Coluna 11
				@ Li,185 Psay ((nEficOper / nDispMec) * 100) Picture "@E 9999.99%"

				//Coluna 12
				@ Li,195 Psay nTotFlCUS Picture "@E 999,999.99"

				nTotFlEXP := 0
				nTotFlHTB := 0
				nTotFlMNT := 0
				nTotFlCHV := 0
				nTotFlPLN := 0
				nTotFlCUS := 0
				SomaLinha(58)
			EndIf

		EndDo
		dbSelectArea(cTRB)
		dbSkip()
	EndDo

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR055DT
Valida o parametro até data.

@author Evaldo Cevinscki Jr.
@since 13/05/2010
@version P11
@return Boolean lRet: true ou false conforme validação.
/*/
//---------------------------------------------------------------------

Function MNTR055DT()

	Local lRet := .T.
	If  MV_PAR10 < MV_PAR09
		MsgStop( STR0039 ) // "Data final não pode ser inferior à data inicial!"
		lRet := .F.
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} Somalinha
Função de tratamento de quebra de linha

@author Evaldo Cevinscki Jr.
@since 13/05/2010
@version P11
@return ever true
/*/
//---------------------------------------------------------------------

Static Function Somalinha()

	Local nVerif := If( nTIPO == 15,75,58 )

	Li++
	If Li > nVerif .And. Li <> 81
	   Cabec( titulo,cabec1,cabec2,nomeprog,tamanho,nTipo )
	   Somalinha()
	EndIf

	If Li == 81
		Cabec( titulo,cabec1,cabec2,nomeprog,tamanho,nTipo )
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} Somalinha
Retorna Empresa, Filial de Início e Filial Fim para pesquisa.

@author Evaldo Cevinscki Jr.
@since 13/05/2010
@version P11
@return Array aEmpFil: { empresa,filial início,filial final  }
/*/
//---------------------------------------------------------------------

Static Function EmpDeAte( cDe,cAte )

	Local aEmpFil := {}
	Local aArea   := SM0->( GetArea() )

	dbSelectArea("SM0")
	dbSetOrder(1) // M0_CODIGO + M0_CODFIL
	dbGoTop()
	While !EoF()
		If SM0->M0_CODIGO+SM0->M0_CODFIL < cDe .Or. SM0->M0_CODIGO+SM0->M0_CODFIL > cAte
			dbSkip()
			Loop
		EndIf

		If (nPos := aScan(aEmpFil,{|x| x[1] == SM0->M0_CODIGO})) == 0
			aAdd(aEmpFil,{SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_CODFIL})
		Else
			aEmpFil[nPos][3] := SM0->M0_CODFIL
		EndIf

		dbSelectArea("SM0")
		dbSkip()
	EndDo

	RestArea( aArea )

Return aEmpFil

//---------------------------------------------------------------------
/*/{Protheus.doc} MINMAX055
Retorna a hora Mínima e Máxima da chave

@author Evaldo Cevinscki Jr.
@since 13/05/2010
@version P11
@return Array aRet: { hora mínima,hora máxima,numero indice  }
/*/
//---------------------------------------------------------------------

/*
O nome da função antiga, no específico era: U_OASMINMAX
*/
Function MINMAX055( _nChaveTV2,_cHraMin,_cHraMax )

	Local aOldArea := GetArea()
	Local _cTV1Min := _cHraMin, _cTV1Max := _cHraMax
	Local aRet     := {}

	dbSelectArea("TV2")
	dbSetOrder(01) // TV2_FILIAL+TV2_EMPRES+TV2_CODBEM+DTOS( TV2_DTSERV )+TV2_TURNO+TV2_PDIHRI+TV2_PDIHRF+TV2_HRINI+TV2_CODATI
	If dbSeek(_nChaveTV2)
		While !EoF() .And. TV2->TV2_FILIAL+TV2->TV2_EMPRES+TV2->TV2_CODBEM+DTOS(TV2->TV2_DTSERV)+TV2->TV2_TURNO == _nChaveTV2
			If _cTV1Min < _cTV1Max
				If TV2->TV2_HRINI < _cHraMin
					_cHraMin := TV2->TV2_HRINI
				EndIf
				If TV2->TV2_HRFIM > _cHraMax
					_cHraMax := TV2->TV2_HRFIM
				EndIf
			Else
				If (TV2->TV2_HRINI < TV2->TV2_HRFIM) .AND. (TV2->TV2_HRINI < _cTV1Min) .AND. (TV2->TV2_HRFIM < _cTV1Min)
					_cHraMax := TV2->TV2_HRFIM
				Else
					If TV2->TV2_HRINI < _cHraMin
						_cHraMin := TV2->TV2_HRINI
					EndIf
				EndIf
			EndIf
			dbSkip()
		End While
	EndIf

	If !Empty(_cHraMin) .And. !Empty(_cHraMax)
		aAdd( aRet,{_cHraMin,_cHraMax,_nChaveTV2} )
	EndIf

	RestArea( aOldArea )

Return aRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fR055CUSTO
No fonte específico era OAS1RCUSTO()

Busca o custo de 1 ou mais O.S. no periodo do turno diario

@author Marcos Wagner Junior
@since 06/01/2011
@version P11
@return Numérico _nRETCusto: custo
/*/
//---------------------------------------------------------------------
Static Function fR055CUSTO( _TV1DTSERV,_TV2HRINI,_TV1EMPRES,_TV1FILIAL,_T9CODBEM )

	Local aOldArea   := GetArea()
	Local _nRETCusto := 0

	cAliasCus := GetNextAlias()
	cQueryCus := " 	SELECT D.TJ_FILIAL,D.TJ_ORDEM "
	cQueryCus += "		FROM " + RetFullName("STJ",_cEmpAnt) + " D"
	cQueryCus += "		WHERE D.TJ_CODBEM= '" + _T9CODBEM + "' AND D.TJ_DTMRINI >= '" + _TV1DTSERV + "'"
	cQueryCus += "			AND D.TJ_DTMRINI <= "
	cQueryCus += "			(SELECT MIN(TV2.TV2_DTSERV) FROM " + RetFullName("TV2",_cEmpAnt) + " TV2"
	cQueryCus += "			WHERE TV2.TV2_CODBEM=D.TJ_CODBEM AND TV2.TV2_DTSERV >= '" + _TV1DTSERV + "'"
	cQueryCus += "				AND ('" + _TV1EMPRES + "' = TV2.TV2_EMPRES AND TV2.TV2_FILIAL = '" + _TV1FILIAL + "') AND TV2.D_E_L_E_T_<>'*')"
	cQueryCus += "		AND TJ_TERMINO = 'S' AND D.D_E_L_E_T_<>'*' "

	If MV_PAR12 == 1 // CORRETIVA
		cQueryCus += "	AND D.TJ_PLANO = '000000' "
	ElseIf MV_PAR12 == 2 // PREVENTIVA
		cQueryCus += "	AND D.TJ_PLANO > '000000' "
	EndIf

	cQueryCus := ChangeQuery( cQueryCus )
	dbUseArea( .T., "TOPCONN", TCGenQry( ,,cQueryCus ),cAliasCus, .F., .T. )

	dbSelectArea(cAliasCus)
	dbGoTop()

	While !EoF()
		dbSelectArea("STL")
		dbSetOrder(01)
		dbSeek(xFilial("STL",(cAliasCus)->TJ_FILIAL)+(cAliasCus)->TJ_ORDEM)
		While !EoF() .And. xFilial("STL",(cAliasCus)->TJ_FILIAL) == STL->TL_FILIAL .And. STL->TL_ORDEM == (cAliasCus)->TJ_ORDEM
		   	If STL->TL_SEQRELA <> '0'

					If MV_PAR13 == 1
						nCUSTO := STL->TL_CUSTO
					Else
						nCUSTO    := NGCUSTSTAN( STL->TL_CODIGO,STL->TL_TIPOREG,,,,(cAliasCus)->TJ_FILIAL )[1] // Custo standard
						nQTDHORAS := NGTQUATINS( STL->TL_CODIGO,STL->TL_TIPOREG,STL->TL_USACALE, ;
												 STL->TL_QUANTID,STL->TL_TIPOHOR,STL->TL_DTINICI, ;
												 STL->TL_HOINICI,STL->TL_DTFIM,STL->TL_HOFIM,STL->TL_UNIDADE ,,(cAliasCus)->TJ_FILIAL)[1]
						nCUSTO := nCUSTO * nQTDHORAS
					EndIf

					_nRETCusto += nCUSTO
		      EndIf
			dbSelectArea("STL")
			dbSkip()
		EndDo
		dbSelectArea(cAliasCus)
		dbSkip()
	End While

	(cAliasCus)->(dbCloseArea())

	RestArea( aOldArea )

Return _nRETCusto
