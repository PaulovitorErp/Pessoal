#INCLUDE "MNTR215.ch"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MNTR215  ³ Autor ³ Marcos Wagner Junior  ³ Data ³16/07/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Analise de Carcaca                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Manutencao de Ativos                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNTR215()

	Local cString	 := "TQB"
	Local cDesc1	 := STR0001 //"Relatório de Análise de Carcaça"
	Local cDesc2	 := ""
	Local cDesc3	 := ""
	Local wnrel		 := "MNT215"
	Local nSizeFil	 := IIf(FindFunction("FWSizeFilial"),FwSizeFilial(),Len(ST9->T9_FILIAL))
	Private aReturn  := { STR0002, 1,STR0003, 2, 2, 1, "",1 } //"Zebrado"###"Administracao"
	Private nLastKey := 0
	Private cPerg    := "MNT215"
	Private Titulo   := STR0001 //"Relatório de Análise de Carcaça"
	Private Tamanho  := "G"

	//+-------------------------------------------------------------+
	//| Variaveis utilizadas                                        |
	//| MV_PAR01     // Status do Pneu                              |
	//| MV_PAR02     // De Medida                                   |
	//| MV_PAR03     // Ate Medida                                  |
	//| MV_PAR04     // De Fabricante                               |
	//| MV_PAR05     // Ate Fabricante                              |
	//| MV_PAR06     // De Tipo Modelo                              |
	//| MV_PAR07     // Ate Tipo Modelo                             |
	//+-------------------------------------------------------------+
	SetKey( VK_F9, { | | NGVersao( "MNTR215" , 2 ) } )

	pergunte(cPerg,.F.)

	//+--------------------------------------------------------------+
	//| Envia controle para a funcao SETPRINT                        |
	//+--------------------------------------------------------------+
	wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"")
	If nLastKey = 27
		Set Filter To
		DbselectArea("TQS")
		Return
	Endif

	SetDefault(aReturn,cString)

	RptStatus({|lEnd| R215Imp(@lEnd,wnRel,titulo,tamanho)},titulo)

	DbselectArea("TQS")
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ R215Imp  ³ Autor ³ Marcos Wagner Junior  ³ Data ³16/07/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o relatório                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTR215                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R215Imp(lEnd,wnRel,titulo,tamanho)
	Local lFirstRec := .t.
	Private li := 80 ,m_pag := 1
	Private Cabec1, Cabec2
	Private cOldMedida := '  ', cOldFabrica := '  ', cOldTipMod := '  ', cOldCodBem := '  '
	Private nomeprog := "MNTR215"
	Private nTotKmOr, nTotKmR1, nTotKmR2, nTotKmR3, nTotKmR4, nTotKmTo
	Private nQtdOR, nQtdR1, nQtdR2, nQtdR3, nQtdR4, nQtdTo
	Private nValOR, nValR1, nValR2, nValR3, nValR4, nValTo
	Private nTotKmOrAN, nTotKmR1AN, nTotKmR2AN, nTotKmR3AN, nTotKmR4AN, nTotKmToAN //Usados apenas no Analitico
	Private nValORAn, nValR1An, nValR2An, nValR3An, nValR4An, nValToAn //Usados apenas no Analitico
	Private cSucata  := GetMV("MV_NGSTARS")
	Private nPneuTotal := 0, nPneuOR := 0, nPneuR1 := 0, nPneuR2 := 0, nPneuR3 := 0, nPneuR4 := 0

	Store 0 to nTotKmOr, nTotKmR1, nTotKmR2, nTotKmR3, nTotKmR4, nTotKmTo
	Store 0 to nQtdOR, nQtdR1, nQtdR2, nQtdR3, nQtdR4, nQtdTo
	Store 0 to nValOR, nValR1, nValR2, nValR3, nValR4, nValTo
	Store 0 to nTotKmOrAN, nTotKmR1AN, nTotKmR2AN, nTotKmR3AN, nTotKmR4AN, nTotKmToAN //Usados apenas no Analitico
	Store 0 to nValORAn, nValR1An, nValR2An, nValR3An, nValR4An, nValToAn //Usados apenas no Analitico

	nTipo := IIF(aReturn[4]==1,15,18)

	If MV_PAR10 == 1
		Cabec1   := STR0009 //"                                                    --------ORIGINAL--------    -----------R1-----------    -----------R2-----------    -----------R3-----------    -----------R4-----------    ---------TOTAL----------"
		Cabec2   := STR0004 //"Medida/Fabricante/Modelo        Pneu                             KM      CPK                 KM      CPK                 KM      CPK                 KM      CPK                 KM      CPK                 KM      CPK"
	Else
		Cabec1   := STR0005 //"                                --------ORIGINAL--------    -----------R1-----------    -----------R2-----------    -----------R3-----------    -----------R4-----------    ---------TOTAL----------"
		Cabec2   := STR0006 //"Medida/Fabricante/Modelo                     KM      CPK                 KM      CPK                 KM      CPK                 KM      CPK                 KM      CPK                 KM      CPK"
	Endif

	/*
	************************************************************************************************************************************
	*<empresa>                                                                                                        Folha..: xxxxx   *
	*SIGA /SCR001/v.P10                            Relatório de Análise de Carcaça                                    DT.Ref.: dd/mm/aa*
	*Hora...: xx:xx:xx                                        Sintetico                                               Emissao: dd/mm/aa*
	*************************************************************************************************************************************
	1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9
	0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345
	--------ORIGINAL--------    -----------R1-----------    -----------R2-----------    -----------R3-----------    -----------R4-----------    ---------TOTAL----------
	Medida/Fabricante/Modelo                     KM      CPK                 KM      CPK                 KM      CPK                 KM      CPK                 KM      CPK                 KM      CPK
	****************************************************************************************************************************************************************************************************
	xxxxxxxxxxxxxxxxxxxx
	xxxxxxxxxxxxxxxxxxxx
	xxxxxxxxxxxxxxxxxxxx
	Totais:     999.999.999.999  999,999    999.999.999.999  999,999    999.999.999.999  999,999    999.999.999.999  999,999    999.999.999.999  999,999    999.999.999.999  999,999
	Média/Qtd:   999.999.999,99    99999     999.999.999,99    99999     999.999.999,99    99999     999.999.999,99    99999     999.999.999,99    99999     999.999.999,99    99999
	*/

	/*
	************************************************************************************************************************************
	*<empresa>                                                                                                        Folha..: xxxxx   *
	*SIGA /SCR001/v.P10                            Relatório de Análise de Carcaça                                    DT.Ref.: dd/mm/aa*
	*Hora...: xx:xx:xx                                        Analitico                                               Emissao: dd/mm/aa*
	*************************************************************************************************************************************
	1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1
	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345
	--------ORIGINAL--------    -----------R1-----------    -----------R2-----------    -----------R3-----------    -----------R4-----------    ---------TOTAL----------
	Medida/Fabricante/Modelo        Pneu                             KM      CPK                 KM      CPK                 KM      CPK                 KM      CPK                 KM      CPK                 KM      CPK
	************************************************************************************************************************************************************************************************************************
	xxxxxxxxxxxxxxxxxxxx
	xxxxxxxxxxxxxxxxxxxx
	xxxxxxxxxxxxxxxxxxxx      xxxxxxxxxxxxxxxx
	Totais:     999.999.999.999  999,999    999.999.999.999  999,999    999.999.999.999  999,999    999.999.999.999  999,999    999.999.999.999  999,999    999.999.999.999  999,999
	Média/Qtd:   999.999.999,99    99999     999.999.999,99    99999     999.999.999,99    99999     999.999.999,99    99999     999.999.999,99    99999     999.999.999,99    99999
	*/

	cAliasQry := GetNextAlias()
	cQuery := " SELECT TQS.TQS_KMOR, TQS.TQS_KMR1, TQS.TQS_KMR2, TQS.TQS_KMR3, TQS.TQS_KMR4, TQS.TQS_MEDIDA, "
	cQuery += " ST9.T9_FABRICA, ST9.T9_TIPMOD, TQS.TQS_CODBEM, TQS.TQS_BANDAA, ST9.T9_VALCPA "
	cQuery += " FROM "+RetSqlName("ST9")+" ST9, "+RetSqlName("TQS")+" TQS "
	cQuery += " WHERE " + NGMODCOMP("ST9", "TQS")
	cQuery += " AND TQS.TQS_FILIAL BETWEEN " + ValToSql(MV_PAR01) + " AND " + ValToSql(MV_PAR02)
	cQuery += " AND ST9.T9_CODBEM = TQS.TQS_CODBEM "
	If MV_PAR03 == 2
		cQuery += " AND ST9.T9_STATUS = " + ValToSql(cSucata)
	ElseIf MV_PAR03 == 3
		cQuery += " AND ST9.T9_STATUS <> " + ValToSql(cSucata)
	Endif
	cQuery += " AND TQS.TQS_MEDIDA BETWEEN " + ValToSql(MV_PAR04) + " AND " + ValToSql(MV_PAR05)
	cQuery += " AND ST9.T9_FABRICA BETWEEN " + ValToSql(MV_PAR06) + " AND " + ValToSql(MV_PAR07)
	cQuery += " AND ST9.T9_TIPMOD BETWEEN " + ValToSql(MV_PAR08) + " AND " + ValToSql(MV_PAR09)
	cQuery += " AND (TQS.TQS_KMOR <> 0 OR TQS.TQS_KMR1 <> 0 OR TQS.TQS_KMR2 <> 0 OR TQS.TQS_KMR3 <> 0 OR TQS.TQS_KMR4 <> 0 ) "
	cQuery += " AND ST9.D_E_L_E_T_ <> '*' "
	cQuery += " AND TQS.D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY TQS.TQS_MEDIDA, ST9.T9_FABRICA, ST9.T9_TIPMOD "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	dbSelectArea(cAliasQry)
	SetRegua(LastRec())
	dbGoTop()
	While !Eof()
		IncRegua()
		If lFirstRec
			lFirstRec := .f.
			NgSomaLi(58)
		Endif

		lImpCab := .f.
		If cOldMedida != (cAliasQry)->TQS_MEDIDA
			@ Li,000 PSay NGSEEK("TQT",(cAliasQry)->TQS_MEDIDA,1,'TQT_DESMED')
			cOldMedida := (cAliasQry)->TQS_MEDIDA
			NgSomaLi(58)
			lImpCab := .t.
		Endif
		If cOldFabrica != (cAliasQry)->T9_FABRICA .OR. lImpCab
			@ Li,003 PSay NGSEEK("ST7",(cAliasQry)->T9_FABRICA,1,"T7_NOME")
			cOldFabrica := (cAliasQry)->T9_FABRICA
			NgSomaLi(58)
			lImpCab := .t.
		Endif
		If cOldTipMod != (cAliasQry)->T9_TIPMOD .OR. lImpCab
			@ Li,006 PSay SubStr(NGSEEK("TQR",(cAliasQry)->T9_TIPMOD,1,"TQR_DESMOD"),1,20)
			cOldTipMod := (cAliasQry)->T9_TIPMOD
			If MV_PAR10 == 2
				NgSomaLi(58)
			Endif
		Endif

		If MV_PAR10 == 1
			If cOldCodBem != (cAliasQry)->TQS_CODBEM
				@ Li,032 PSay (cAliasQry)->TQS_CODBEM
				cOldCodBem := (cAliasQry)->TQS_CODBEM
				Store 0 to nTotKmOr, nTotKmR1, nTotKmR2, nTotKmR3, nTotKmR4, nTotKmTo
				Store 0 to nValOR, nValR1, nValR2, nValR3, nValR4//, nValTo
			Endif
		Endif

		If (cAliasQry)->TQS_BANDAA >= '1'
			nTotKmOr += (cAliasQry)->TQS_KMOR; 	nTotKmOrAN += (cAliasQry)->TQS_KMOR
			nQtdOR   += 1
		Endif
		If (cAliasQry)->TQS_BANDAA >= '2'
			nTotKmR1 += (cAliasQry)->TQS_KMR1; 	nTotKmR1AN += (cAliasQry)->TQS_KMR1
			nQtdR1   += 1
		Endif
		If (cAliasQry)->TQS_BANDAA >= '3'
			nTotKmR2 += (cAliasQry)->TQS_KMR2; 	nTotKmR2AN += (cAliasQry)->TQS_KMR2
			nQtdR2   += 1
		Endif
		If (cAliasQry)->TQS_BANDAA >= '4'
			nTotKmR3 += (cAliasQry)->TQS_KMR3;	nTotKmR3AN += (cAliasQry)->TQS_KMR3
			nQtdR3   += 1
		Endif
		If (cAliasQry)->TQS_BANDAA >= '5'
			nTotKmR4 += (cAliasQry)->TQS_KMR4; nTotKmR4AN += (cAliasQry)->TQS_KMR4
			nQtdR4   += 1
		Endif
		nTotKmTo += (cAliasQry)->TQS_KMOR + (cAliasQry)->TQS_KMR1 + (cAliasQry)->TQS_KMR2 + (cAliasQry)->TQS_KMR3 + (cAliasQry)->TQS_KMR4
		nTotKmToAN += (cAliasQry)->TQS_KMOR + (cAliasQry)->TQS_KMR1 + (cAliasQry)->TQS_KMR2 + (cAliasQry)->TQS_KMR3 + (cAliasQry)->TQS_KMR4
		nQtdTo += 1
		//Carregando o custo dos pneus
		nValOR := (cAliasQry)->T9_VALCPA; nValORAn := (cAliasQry)->T9_VALCPA

		cAliasQry2 := GetNextAlias()
		cQuery := " SELECT STL.TL_DTINICI, STL.TL_HOINICI, STL.TL_CUSTO "
		cQuery += " FROM " + RetSqlName("STJ")+" STJ, "+ RetSqlName("STL")+" STL "
		cQuery += " WHERE STL.TL_FILIAL  = STJ.TJ_FILIAL "
		cQuery += " AND   STL.TL_ORDEM   = STJ.TJ_ORDEM "
		cQuery += " AND   STL.TL_PLANO   = STJ.TJ_PLANO "
		cQuery += " AND   STJ.TJ_CODBEM  = " + ValToSql((cAliasQry)->TQS_CODBEM)
		cQuery += " AND   STL.TL_SEQRELA <> '0' "
		cQuery += " AND   STJ.D_E_L_E_T_ <> '*' "
		cQuery += " AND   STL.D_E_L_E_T_ <> '*' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry2, .F., .T.)
		dbGotop()
		While !Eof()
			cAliasQry3 := GetNextAlias()
			cQuery := " SELECT MAX(TQV.TQV_DTMEDI||TQV.TQV_HRMEDI||TQV.TQV_BANDA) AS BANDA "
			cQuery += " FROM " + RetSqlName("TQV")+" TQV "
			cQuery += " WHERE TQV.TQV_CODBEM = "+ ValToSql((cAliasQry)->TQS_CODBEM)
			cQuery += " AND (TQV.TQV_DTMEDI||TQV.TQV_HRMEDI) <= " + ValToSql((cAliasQry2)->TL_DTINICI+(cAliasQry2)->TL_HOINICI)
			cQuery += " AND TQV.D_E_L_E_T_ <> '*' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry3, .F., .T.)
			dbGotop()
			If !Eof()
				If SubStr((cAliasQry3)->BANDA,14,1) == '1'
					nValOR += (cAliasQry2)->TL_CUSTO; nValORAn += (cAliasQry2)->TL_CUSTO
				ElseIf SubStr((cAliasQry3)->BANDA,14,1) == '2'
					nValR1 += (cAliasQry2)->TL_CUSTO; nValR1An += (cAliasQry2)->TL_CUSTO
				ElseIf SubStr((cAliasQry3)->BANDA,14,1) == '3'
					nValR2 += (cAliasQry2)->TL_CUSTO; nValR2An += (cAliasQry2)->TL_CUSTO
				ElseIf SubStr((cAliasQry3)->BANDA,14,1) == '4'
					nValR3 += (cAliasQry2)->TL_CUSTO; 	nValR3An += (cAliasQry2)->TL_CUSTO
				ElseIf SubStr((cAliasQry3)->BANDA,14,1) == '5'
					nValR4 += (cAliasQry2)->TL_CUSTO; 	nValR4An += (cAliasQry2)->TL_CUSTO
				Endif
			Endif
			(cAliasQry3)->(dbCloseArea())

			dbSelectAreA(cAliasQry2)
			dbSkip()
		End
		(cAliasQry2)->(dbCloseArea())
		nValTo := nValOR + nValR1 + nValR2 + nValR3 + nValR4
		nValToAn := nValORAn + nValR1An + nValR2An + nValR3An + nValR4An
		If MV_PAR10 == 2
			nPneuTotal += nValOR + nValR1 + nValR2 + nValR3 + nValR4
			nPneuOR += nValOR
		Endif
		//Fim
		dbSelectArea(cAliasQry)
		dbSkip()
		MNR215BAN(Eof())

	End

	(cAliasQry)->(dbCloseArea())
	RetIndex("TQS")
	Set Filter To
	Set Device To Screen
	If aReturn[5] == 1
		Set Printer To
		dbCommitAll()
		OurSpool(WNREL)
	EndIf
	MS_FLUSH()

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNR215BAN ³ Autor ³ Marcos Wagner Junior  ³ Data ³16/07/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o relatório                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTR215                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MNR215BAN(lFimArq)
	Private nSomaColu := 0

	If MV_PAR10 == 1
		nSomaColu := 20
	Endif

	If (cOldMedida != (cAliasQry)->TQS_MEDIDA) .OR. (cOldFabrica != (cAliasQry)->T9_FABRICA) .OR.;
	(cOldTipMod != (cAliasQry)->T9_TIPMOD) .OR. lFimArq
		If MV_PAR10 == 1
			MNR125CABA()
			NgSomaLi(58)
			nTotKmOr := nTotKmOrAN; nTotKmR1 := nTotKmR1AN; nTotKmR2 := nTotKmR2AN; nTotKmR3 := nTotKmR3AN; nTotKmR4 := nTotKmR4AN; nTotKmTo := nTotKmToAN
			nValOR := nValORAn; nValR1 := nValR1An; nValR2 := nValR2An; nValR3 := nValR3An; nValR4 := nValR4An
			Store 0 to nTotKmOrAN, nTotKmR1AN, nTotKmR2AN, nTotKmR3AN, nTotKmR4AN, nTotKmToAN
			Store 0 to nValORAn, nValR1An, nValR2An, nValR3An, nValR4An, nValToAn
			nValTo := nPneuTotal
			nValOr := nPneuOR; nValR1 := nPneuR1;	nValR2 := nPneuR2; nValR3 := nPneuR3;	nValR4 := nPneuR4
			nPneuTotal := 0
			nPneuOR := 0; nPneuR1 := 0; nPneuR2 := 0; nPneuR3 := 0; nPneuR4 := 0
		Else
			nValOr := nPneuOR
			nPneuOR := 0
			nValTo := nValOR + nValR1 + nValR2 + nValR3 + nValR4
		Endif
		@ Li,020+nSomaColu PSay STR0007 //"Totais:"
		@ Li,032+nSomaColu PSay PADL(Transform(nTotKmOr,"@E 999,999,999,999"),15)
		@ Li,049+nSomaColu PSay PADL(Transform(nValOR/nTotKmOr,"@E 999.999"),7)
		@ Li,060+nSomaColu PSay PADL(Transform(nTotKmR1,"@E 999,999,999,999"),15)
		@ Li,077+nSomaColu PSay PADL(Transform(nValR1/nTotKmR1,"@E 999.999"),7)
		@ Li,088+nSomaColu PSay PADL(Transform(nTotKmR2,"@E 999,999,999,999"),15)
		@ Li,105+nSomaColu PSay PADL(Transform(nValR2/nTotKmR2,"@E 999.999"),7)
		@ Li,116+nSomaColu PSay PADL(Transform(nTotKmR3,"@E 999,999,999,999"),15)
		@ Li,133+nSomaColu PSay PADL(Transform(nValR3/nTotKmR3,"@E 999.999"),7)
		@ Li,143+nSomaColu PSay PADL(Transform(nTotKmR4,"@E 999,999,999,999"),15)
		@ Li,160+nSomaColu PSay PADL(Transform(nValR4/nTotKmR4,"@E 999.999"),7)
		@ Li,172+nSomaColu PSay PADL(Transform(nTotKmTo,"@E 999,999,999,999"),15)
		@ Li,189+nSomaColu PSay PADL(Transform(nValTo/nTotKmTo,"@E 999.999"),7)

		NgSomaLi(58)
		@ Li,020+nSomaColu PSay STR0008 //"Média/Qtd:"
		@ Li,033+nSomaColu PSay PADL(Transform(nTotKmOr/nQtdOR,"@E 999,999,999.99"),14)
		@ Li,049+nSomaColu PSay PADL(Transform(nQtdOR,"@E 999,999"),7)
		@ Li,061+nSomaColu PSay PADL(Transform(nTotKmR1/nQtdR1,"@E 999,999,999.99"),14)
		@ Li,077+nSomaColu PSay PADL(Transform(nQtdR1,"@E 999,999"),7)
		@ Li,089+nSomaColu PSay PADL(Transform(nTotKmR2/nQtdR2,"@E 999,999,999.99"),14)
		@ Li,105+nSomaColu PSay PADL(Transform(nQtdR2,"@E 999,999"),7)
		@ Li,117+nSomaColu PSay PADL(Transform(nTotKmR3/nQtdR3,"@E 999,999,999.99"),14)
		@ Li,133+nSomaColu PSay PADL(Transform(nQtdR3,"@E 999,999"),7)
		@ Li,144+nSomaColu PSay PADL(Transform(nTotKmR4/nQtdR4,"@E 999,999,999.99"),14)
		@ Li,160+nSomaColu PSay PADL(Transform(nQtdR4,"@E 999,999"),7)
		@ Li,173+nSomaColu PSay PADL(Transform(nTotKmTo/nQtdTo,"@E 999,999,999.99"),14)
		@ Li,189+nSomaColu PSay PADL(Transform(nQtdTo,"@E 999,999"),7)
		Store 0 to nTotKmOr, nTotKmR1, nTotKmR2, nTotKmR3, nTotKmR4, nTotKmTo
		Store 0 to nQtdOR, nQtdR1, nQtdR2, nQtdR3, nQtdR4, nQtdTo
		Store 0 to nValOR, nValR1, nValR2, nValR3, nValR4, nValTo
		NgSomaLi(58)
		NgSomaLi(58)
	ElseIf MV_PAR10 == 1
		MNR125CABA()
	Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNR125CABA³ Autor ³ Marcos Wagner Junior  ³ Data ³16/07/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o conteudo dos pneus (Analitico                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTR215                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MNR125CABA()

	@ Li,052 PSay PADL(Transform(nTotKmOr,"@E 999,999,999,999"),15)
	@ Li,069 PSay PADL(Transform(nValOR/nTotKmOr,"@E 999.999"),7)
	@ Li,080 PSay PADL(Transform(nTotKmR1,"@E 999,999,999,999"),15)
	@ Li,097 PSay PADL(Transform(nValR1/nTotKmR1,"@E 999.999"),7)
	@ Li,108 PSay PADL(Transform(nTotKmR2,"@E 999,999,999,999"),15)
	@ Li,125 PSay PADL(Transform(nValR2/nTotKmR2,"@E 999.999"),7)
	@ Li,136 PSay PADL(Transform(nTotKmR3,"@E 999,999,999,999"),15)
	@ Li,153 PSay PADL(Transform(nValR3/nTotKmR3,"@E 999.999"),7)
	@ Li,163 PSay PADL(Transform(nTotKmR4,"@E 999,999,999,999"),15)
	@ Li,180 PSay PADL(Transform(nValR4/nTotKmR4,"@E 999.999"),7)
	@ Li,192 PSay PADL(Transform(nTotKmTo,"@E 999,999,999,999"),15)
	@ Li,209 PSay PADL(Transform(nValTo/nTotKmTo,"@E 999.999"),7)
	NgSomaLi(58)

	nPneuTotal += nValOR + nValR1 + nValR2 + nValR3 + nValR4
	nPneuOR += nValOR; nPneuR1 += nValR1; 	nPneuR2 += nValR2; nPneuR3 += nValR3; 	nPneuR4 += nValR4

Return