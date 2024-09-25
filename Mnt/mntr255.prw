#INCLUDE "MNTR255.ch"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MNTR255  ³ Autor ³ Marcos Wagner Junior  ³ Data ³ 04/08/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Recapador (Pneus)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAMNT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNTR255()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Guarda conteudo e declara variaveis padroes ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aNGBEGINPRM := NGBEGINPRM(1)

	Local cString    := "TQS"
	Local cDesc1     := STR0001 //"Relatório de Recapador"
	Local cDesc2     := ""
	Local cDesc3     := ""
	Local wnrel      := "MNTR255"

	Private aReturn  := { STR0002, 1,STR0003, 2, 2, 1, "",1 } //"Zebrado"###"Administracao"
	Private nLastKey := 0
	Private cPerg    := "MNR255"
	Private Titulo   := STR0001 //"Relatório de Recapador"
	Private Tamanho  := "G"
	
	//+--------------------------------------------------------------+
	//| Variaveis utilizadas                                         |
	//| MV_PAR01    |   Status do Pneu                               |
	//| MV_PAR02    |   De Medida                                    |
	//| MV_PAR03    |   Ate Medida                                   |
	//| MV_PAR04    |   De Tipo Modelo                               |
	//| MV_PAR05    |   Ate Tipo Modelo                              |
	//| MV_PAR06    |   De Fornecedor                                |
	//| MV_PAR07    |   Ate Fornecedor                               |
	//| MV_PAR08    |   Tipo de Relatorio                            |
	//+--------------------------------------------------------------+

	pergunte(cPerg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"")

	If nLastKey = 27
		Set Filter To
		DbselectArea("TQS")
		NGRETURNPRM(aNGBEGINPRM)
		Return
	Endif

	SetDefault(aReturn,cString)

	RptStatus({|lEnd| R255Imp(@lEnd,wnRel,titulo,tamanho)},titulo)

	DbselectArea("TQS")
	NGRETURNPRM(aNGBEGINPRM)
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ R255Imp  ³ Autor ³ Marcos Wagner Junior  ³ Data ³ 04/08/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o relatório                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MNTR255                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R255Imp(lEnd,wnRel,titulo,tamanho)
	Local lFirstRec := .t.
	Local _cGetDB := TcGetDb()
	Private li := 80 ,m_pag := 1
	Private Cabec1, Cabec2
	Private cOldRecapa := '  ', cOldMedida := '  ', cOldDesenh := '  ', cOldCodBem := '  '
	Private nomeprog := "MNTR255"
	Private nTotKmR1, nTotKmR2, nTotKmR3, nTotKmR4, nTotKmTo
	Private nQtdR1, nQtdR2, nQtdR3, nQtdR4, nQtdTo
	Private nValR1, nValR2, nValR3, nValR4, nValTo
	Private cSucata  := GetMV("MV_NGSTARS")
	Private nTotKmR1An := 0, nTotKmR2An := 0, nTotKmR3An := 0, nTotKmR4An := 0 //Analitico
	Private nValR1An := 0, nValR2An := 0, nValR3An := 0, nValR4An := 0 //Analitico

	Store 0 to nTotKmR1, nTotKmR2, nTotKmR3, nTotKmR4, nTotKmTo
	Store 0 to nQtdR1, nQtdR2, nQtdR3, nQtdR4, nQtdTo
	Store 0 to nValR1, nValR2, nValR3, nValR4, nValTo

	nTipo := IIF(aReturn[4]==1,15,18)

	If MV_PAR08 == 1
		Cabec1   := STR0004 //"                                                              -----------R1-----------    -----------R2-----------    -----------R3-----------    -----------R4-----------    ---------TOTAL----------"
		Cabec2   := STR0005 //"Recapador/Medida/Desenho  Bem                                              KM      CPK                 KM      CPK                 KM      CPK                 KM      CPK                 KM      CPK"
	Else
		Cabec1   := STR0006 //"                                     -----------R1-----------    -----------R2-----------    -----------R3-----------    -----------R4-----------    ---------TOTAL----------"
		Cabec2   := STR0007 //"Recapador/Medida/Desenho                          KM      CPK                 KM      CPK                 KM      CPK                 KM      CPK                 KM      CPK"
	Endif

	/*
	************************************************************************************************************************************
	*<empresa>                                                                                                        Folha..: xxxxx   *
	*SIGA /SCR001/v.P10                                Relatório de Recapador                                         DT.Ref.: dd/mm/aa*
	*Hora...: xx:xx:xx                                        Analitico                                               Emissao: dd/mm/aa*
	*************************************************************************************************************************************
	1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6       
	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567
	-----------R1-----------    -----------R2-----------    -----------R3-----------    -----------R4-----------    ---------TOTAL----------
	Recapador/Medida/Desenho  Bem                                              KM      CPK                 KM      CPK                 KM      CPK                 KM      CPK                 KM      CPK

	************************************************************************************************************************************************************************
	xxxxxxxxxxxxxxxxxxxx
	xxxxxxxxxxxxxxxxxxxx
	xxxxxxxxxx          xxxxxxxxxxxxxxxx   Totais:          999.999.999.999  999,999    999.999.999.999  999,999    999.999.999.999  999,999    999.999.999.999  999,999    999.999.999.999  999,999
	Média/Qtd:        999.999.999,99    99999     999.999.999,99    99999     999.999.999,99    99999     999.999.999,99    99999     999.999.999,99    99999



	************************************************************************************************************************************
	*<empresa>                                                                                                        Folha..: xxxxx   *
	*SIGA /SCR001/v.P10                                Relatório de Recapador                                         DT.Ref.: dd/mm/aa*
	*Hora...: xx:xx:xx                                        Sintetico                                               Emissao: dd/mm/aa*
	*************************************************************************************************************************************
	1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6       
	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567
	-----------R1-----------    -----------R2-----------    -----------R3-----------    -----------R4-----------    ---------TOTAL----------
	Recapador/Medida/Desenho                          KM      CPK                 KM      CPK                 KM      CPK                 KM      CPK                 KM      CPK
	************************************************************************************************************************************************************************
	xxxxxxxxxxxxxxxxxxxx
	xxxxxxxxxxxxxxxxxxxx
	xxxxxxxxxx    Totais:          999.999.999.999  999,999    999.999.999.999  999,999    999.999.999.999  999,999    999.999.999.999  999,999    999.999.999.999  999,999
	Média/Qtd:        999.999.999,99    99999     999.999.999,99    99999     999.999.999,99    99999     999.999.999,99    99999     999.999.999,99    99999
	*/

	cAliasQry := GetNextAlias()
	cQuery := " SELECT STL.TL_DTFIM, STL.TL_HOFIM, STL.TL_CUSTO, STJ.TJ_CODBEM, TQS.TQS_CODBEM, TQS.TQS_MEDIDA, "
	cQuery += " TQS.TQS_BANDAA, TQS.TQS_KMR1, TQS.TQS_KMR2, TQS.TQS_KMR3, TQS.TQS_KMR4, TR7.TR7_FORNEC, TR7.TR7_LOJA,  "
	If Upper(_cGetDB) $ 'ORACLE,POSTGRES,INFORMIX' .OR. Upper(_cGetDB) $ 'DB2'
		cQuery += " SUBSTR((SELECT MAX(TQV.TQV_DTMEDI||TQV.TQV_HRMEDI||TQV.TQV_BANDA) "
	Else
		cQuery += " SUBSTRING((SELECT MAX(TQV.TQV_DTMEDI+TQV.TQV_HRMEDI+TQV.TQV_BANDA) "
	Endif
	cQuery += " FROM "+RetSqlName("TQV")+" TQV "
	cQuery += " WHERE TQV.TQV_CODBEM = TQS.TQS_CODBEM "
	cQuery += " AND TQV.TQV_DESENH BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"' "
	cQuery += " AND STL.TL_DTFIM||STL.TL_HOFIM >= TQV.TQV_DTMEDI||TQV.TQV_HRMEDI "
	cQuery += " AND TQV.D_E_L_E_T_ <> '*'),14,1) AS BANDA, "
	If Upper(_cGetDB) $ 'ORACLE,POSTGRES,INFORMIX' .OR. Upper(_cGetDB) $ 'DB2'
		cQuery += " SUBSTR((SELECT MAX(TQV.TQV_DTMEDI||TQV.TQV_HRMEDI||TQV.TQV_DESENH) "
	Else
		cQuery += " SUBSTRING((SELECT MAX(TQV.TQV_DTMEDI+TQV.TQV_HRMEDI+TQV.TQV_DESENH) "
	Endif
	cQuery += " FROM "+RetSqlName("TQV")+" TQV "
	cQuery += " WHERE TQV.TQV_CODBEM = TQS.TQS_CODBEM "
	cQuery += " AND TQV.TQV_DESENH BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"' "
	cQuery += " AND STL.TL_DTFIM||STL.TL_HOFIM >= TQV.TQV_DTMEDI||TQV.TQV_HRMEDI "
	cQuery += " AND TQV.D_E_L_E_T_ <> '*'),14,10) AS DESENHO "
	cQuery += " FROM "+RetSqlName("STL")+" STL "
	cQuery += " JOIN "+RetSqlName("STJ")+" STJ "
	cQuery += "   ON STJ.TJ_FILIAL = STL.TL_FILIAL AND STJ.TJ_ORDEM = STL.TL_ORDEM AND STJ.TJ_PLANO = STL.TL_PLANO "
	cQuery += "   AND STJ.D_E_L_E_T_ <> '*' "
	cQuery += " JOIN "+RetSqlName("TR8")+" TR8 "
	cQuery += "   ON TR8.TR8_ORDEM = STJ.TJ_ORDEM AND TR8.D_E_L_E_T_ <> '*' "
	cQuery += " JOIN "+RetSqlName("TR7")+" TR7 "
	cQuery += "   ON TR7.TR7_LOTE = TR8.TR8_LOTE AND TR7.D_E_L_E_T_ <> '*' AND  TR7.TR7_FORNEC BETWEEN '"+MV_PAR06+"' AND '"+MV_PAR07+"' "
	cQuery += " JOIN "+RetSqlName("TQS")+" TQS "
	cQuery += "   ON TQS.TQS_CODBEM = TR8.TR8_CODBEM AND TQS.D_E_L_E_T_ <> '*' "
	cQuery += "   AND TQS.TQS_MEDIDA BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' "
	cQuery += "   AND (TQS.TQS_KMR1 <> 0 OR TQS.TQS_KMR2 <> 0 OR TQS.TQS_KMR3 <> 0 OR TQS.TQS_KMR4 <> 0 ) "
	cQuery += " JOIN "+RetSqlName("ST9")+" ST9 "
	cQuery += "   ON ST9.T9_FILIAL = TQS.TQS_FILIAL AND ST9.T9_CODBEM = TQS.TQS_CODBEM AND ST9.D_E_L_E_T_ <> '*' "
	cQuery += " WHERE STL.TL_SEQRELA <> '0' "
	If MV_PAR01 == 2
		cQuery += " AND ST9.T9_STATUS = '"+cSucata+"'"
	ElseIf MV_PAR01 == 3
		cQuery += " AND ST9.T9_STATUS <> '"+cSucata+"'"
	Endif
	cQuery += "  AND TQS.TQS_BANDAA > '1' "
	cQuery += "  AND STL.D_E_L_E_T_ <> '*' "
	cQuery += "  ORDER BY TR7.TR7_FORNEC, TR7.TR7_LOJA, TQS.TQS_MEDIDA, DESENHO, TQS.TQS_CODBEM "
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

		If cOldRecapa != (cAliasQry)->TR7_FORNEC+(cAliasQry)->TR7_LOJA
			@ Li,000 PSay NGSEEK("SA2",(cAliasQry)->TR7_FORNEC+(cAliasQry)->TR7_LOJA,1,'A2_NOME')
			NgSomaLi(58)
		Endif
		If cOldMedida != (cAliasQry)->TQS_MEDIDA
			@ Li,003 PSay NGSEEK("TQT",(cAliasQry)->TQS_MEDIDA,1,'TQT_DESMED')
			NgSomaLi(58)
		Endif
		If cOldDesenh != (cAliasQry)->DESENHO
			@ Li,006 PSay (cAliasQry)->DESENHO
			//NgSomaLi(58)
		Endif

		If cOldCodBem != (cAliasQry)->TQS_CODBEM .OR. ((cOldRecapa != (cAliasQry)->TR7_FORNEC+(cAliasQry)->TR7_LOJA .OR.;
		cOldMedida != (cAliasQry)->TQS_MEDIDA .OR. cOldDesenh != (cAliasQry)->DESENHO) .AND. cOldCodBem == (cAliasQry)->TQS_CODBEM)

			If MV_PAR08 == 1
				@ Li,026 PSay (cAliasQry)->TQS_CODBEM
				Store 0 to nTotKmR1, nTotKmR2, nTotKmR3, nTotKmR4, nTotKmTo
				Store 0 to nValR1, nValR2, nValR3, nValR4//, nValTo
			Endif

			If (cAliasQry)->TQS_BANDAA >= '2'
				nTotKmR1 += (cAliasQry)->TQS_KMR1
				nQtdR1   += 1
			Endif
			If (cAliasQry)->TQS_BANDAA >= '3'
				nTotKmR2 += (cAliasQry)->TQS_KMR2
				nQtdR2   += 1
			Endif
			If (cAliasQry)->TQS_BANDAA >= '4'
				nTotKmR3 += (cAliasQry)->TQS_KMR3
				nQtdR3   += 1
			Endif
			If (cAliasQry)->TQS_BANDAA >= '5'
				nTotKmR4 += (cAliasQry)->TQS_KMR4
				nQtdR4   += 1
			Endif
			nQtdTo += 1
			cOldCodBem := (cAliasQry)->TQS_CODBEM
		Endif
		cOldRecapa := (cAliasQry)->TR7_FORNEC+(cAliasQry)->TR7_LOJA
		cOldMedida := (cAliasQry)->TQS_MEDIDA
		cOldDesenh := (cAliasQry)->DESENHO

		If (cAliasQry)->BANDA == '2'
			nValR1 += (cAliasQry)->TL_CUSTO
		ElseIf (cAliasQry)->BANDA == '3'
			nValR2 += (cAliasQry)->TL_CUSTO
		ElseIf (cAliasQry)->BANDA == '4'
			nValR3 += (cAliasQry)->TL_CUSTO
		ElseIf (cAliasQry)->BANDA == '5'
			nValR4 += (cAliasQry)->TL_CUSTO
		Endif

		//Fim
		dbSelectArea(cAliasQry)
		dbSkip()
		MNR255BAN(Eof())
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
±±³Fun‡„o    ³MNR255BAN ³ Autor ³ Marcos Wagner Junior  ³ Data ³ 04/08/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o relatório                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTR255                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MNR255BAN(lFimArq)
	Private nSomaColu := 0

	If MV_PAR08 == 1
		nSomaColu := 25
		If cOldCodBem != (cAliasQry)->TQS_CODBEM .OR. ((cOldRecapa != (cAliasQry)->TR7_FORNEC+(cAliasQry)->TR7_LOJA .OR.;
		cOldMedida != (cAliasQry)->TQS_MEDIDA .OR. cOldDesenh != (cAliasQry)->DESENHO) .AND. cOldCodBem == (cAliasQry)->TQS_CODBEM)
			MNR255CABA()
			NgSomaLi(58)
		Endif
	Endif

	If (cOldRecapa != (cAliasQry)->TR7_FORNEC+(cAliasQry)->TR7_LOJA .OR. cOldMedida != (cAliasQry)->TQS_MEDIDA) .OR.;
	(cOldDesenh != (cAliasQry)->DESENHO) .OR. lFimArq
		If MV_PAR08 == 1
			nValR1 := nValR1An; nValR2 := nValR2An; nValR3 := nValR3An; nValR4 := nValR4An
			nTotKmR1 := nTotKmR1An; nTotKmR2 := nTotKmR2An; nTotKmR3 := nTotKmR3An; nTotKmR4 := nTotKmR4An
			Store 0 to nTotKmR1An, nTotKmR2An, nTotKmR3An, nTotKmR4An, nTotKmTo
			Store 0 to nValR1An, nValR2An, nValR3An, nValR4An
		Endif
		nValTo := nValR1 + nValR2 + nValR3 + nValR4
		nTotKmTo := nTotKmR1 + nTotKmR2 + nTotKmR3 + nTotKmR4

		@ Li,024+nSomaColu PSay STR0008 //"Totais:"
		@ Li,037+nSomaColu PSay PADL(Transform(nTotKmR1,"@E 999,999,999,999"),15)
		@ Li,054+nSomaColu PSay PADL(Transform(nValR1/nTotKmR1,"@E 999.999"),7)
		@ Li,065+nSomaColu PSay PADL(Transform(nTotKmR2,"@E 999,999,999,999"),15)
		@ Li,082+nSomaColu PSay PADL(Transform(nValR2/nTotKmR2,"@E 999.999"),7)
		@ Li,093+nSomaColu PSay PADL(Transform(nTotKmR3,"@E 999,999,999,999"),15)
		@ Li,110+nSomaColu PSay PADL(Transform(nValR3/nTotKmR3,"@E 999.999"),7)
		@ Li,121+nSomaColu PSay PADL(Transform(nTotKmR4,"@E 999,999,999,999"),15)
		@ Li,138+nSomaColu PSay PADL(Transform(nValR4/nTotKmR4,"@E 999.999"),7)
		@ Li,149+nSomaColu PSay PADL(Transform(nTotKmTo,"@E 999,999,999,999"),15)
		@ Li,166+nSomaColu PSay PADL(Transform(nValTo/nTotKmTo,"@E 999.999"),7)

		NgSomaLi(58)
		@ Li,024+nSomaColu PSay STR0009 //"Média/Qtd:"
		@ Li,038+nSomaColu PSay PADL(Transform(nTotKmR1/nQtdR1,"@E 999,999,999.99"),14)
		@ Li,054+nSomaColu PSay PADL(Transform(nQtdR1,"@E 999,999"),7)
		@ Li,066+nSomaColu PSay PADL(Transform(nTotKmR2/nQtdR2,"@E 999,999,999.99"),14)
		@ Li,082+nSomaColu PSay PADL(Transform(nQtdR2,"@E 999,999"),7)
		@ Li,094+nSomaColu PSay PADL(Transform(nTotKmR3/nQtdR3,"@E 999,999,999.99"),14)
		@ Li,110+nSomaColu PSay PADL(Transform(nQtdR3,"@E 999,999"),7)
		@ Li,122+nSomaColu PSay PADL(Transform(nTotKmR4/nQtdR4,"@E 999,999,999.99"),14)
		@ Li,138+nSomaColu PSay PADL(Transform(nQtdR4,"@E 999,999"),7)
		@ Li,150+nSomaColu PSay PADL(Transform(nTotKmTo/nQtdTo,"@E 999,999,999.99"),14)
		@ Li,166+nSomaColu PSay PADL(Transform(nQtdTo,"@E 999,999"),7)
		Store 0 to nTotKmR1, nTotKmR2, nTotKmR3, nTotKmR4, nTotKmTo
		Store 0 to nQtdR1, nQtdR2, nQtdR3, nQtdR4, nQtdTo
		Store 0 to nValR1, nValR2, nValR3, nValR4, nValTo
		NgSomaLi(58)
		NgSomaLi(58)
	Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNR255CABA³ Autor ³ Marcos Wagner Junior  ³ Data ³ 04/08/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o conteudo dos pneus (Analitico)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTR215                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MNR255CABA()

	nValTo := nValR1 + nValR2 + nValR3 + nValR4
	nTotKmTo := nTotKmR1 + nTotKmR2 + nTotKmR3 + nTotKmR4

	@ Li,037+nSomaColu PSay PADL(Transform(nTotKmR1,"@E 999,999,999,999"),15)
	@ Li,054+nSomaColu PSay PADL(Transform(nValR1/nTotKmR1,"@E 999.999"),7)
	@ Li,065+nSomaColu PSay PADL(Transform(nTotKmR2,"@E 999,999,999,999"),15)
	@ Li,082+nSomaColu PSay PADL(Transform(nValR2/nTotKmR2,"@E 999.999"),7)
	@ Li,093+nSomaColu PSay PADL(Transform(nTotKmR3,"@E 999,999,999,999"),15)
	@ Li,110+nSomaColu PSay PADL(Transform(nValR3/nTotKmR3,"@E 999.999"),7)
	@ Li,121+nSomaColu PSay PADL(Transform(nTotKmR4,"@E 999,999,999,999"),15)
	@ Li,138+nSomaColu PSay PADL(Transform(nValR4/nTotKmR4,"@E 999.999"),7)
	@ Li,149+nSomaColu PSay PADL(Transform(nTotKmTo,"@E 999,999,999,999"),15)
	@ Li,166+nSomaColu PSay PADL(Transform(nValTo/nTotKmTo,"@E 999.999"),7)

	nValR1An += nValR1; nValR2An += nValR2; nValR3An += nValR3; nValR4An += nValR4
	nTotKmR1An += nTotKmR1; nTotKmR2An += nTotKmR2; nTotKmR3An += nTotKmR3; nTotKmR4An += nTotKmR4

Return