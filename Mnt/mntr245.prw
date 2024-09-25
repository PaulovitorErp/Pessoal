#INCLUDE "MNTR245.ch"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTR245
Relatorio de Analise de Desenho

@author  Marcos Wagner Junior
@since   22/07/2009
@version P11/P12
/*/
//-------------------------------------------------------------------
Function MNTR245()

	Local cString    := "TQS"
	Local cDesc1     := STR0001 //"RelatÛrio de An·lise de Desenho"
	Local cDesc2     := ""
	Local cDesc3     := ""
	Local wnrel      := "MNR245"

	Private aReturn  := { STR0002, 1,STR0003, 2, 2, 1, "",1 } //"Zebrado"###"Administracao"
	Private nLastKey := 0
	Private cPerg    := "MNR245"
	Private Titulo   := STR0001 //"RelatÛrio de An·lise de Desenho"
	Private Tamanho  := "G"

	//+-------------------------------------------------------+
	//| Variaveis utilizadas                                  |
	//| MV_PAR01     // Status do Pneu                        |
	//| MV_PAR02     // De Medida                             |
	//| MV_PAR03     // Ate Medida                            |
	//| MV_PAR04     // De Tipo Modelo                        |
	//| MV_PAR05     // Ate Tipo Modelo                       |
	//| MV_PAR06     // Tipo de Relatorio                     |
	//+-------------------------------------------------------+

	Pergunte(cPerg,.F.)
	//-------------------------------------------------------
	// Envia controle para a funcao SETPRINT
	//-------------------------------------------------------
	wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"")

	If nLastKey = 27
		Set Filter To
		DbselectArea("TQS")
		Return
	Endif

	SetDefault(aReturn,cString)

	RptStatus({|lEnd| R245Imp(@lEnd,wnRel,titulo,tamanho)},titulo)

	DbselectArea("TQS")
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} R245Imp
Imprime o relatÛrio

@author  Marcos Wagner Junior
@since   22/07/2009
@version P11/P12
@param	 lEnd,    LÛgico,   Controle de Encerramento do RelatÛrio
@param	 wnRel,   Caracter, CÛdigo do RelatÛrio
@param	 titulo,  Caracter, TÌtulo do RelatÛrio
@param	 tamanho, Caracter, Tamanho do RelatÛrio

@return lRet, LÛgico, Caso n„o encontre registros para impress„o .F.

/*/
//-------------------------------------------------------------------
Static Function R245Imp(lEnd,wnRel,titulo,tamanho)

	Local lFirstRec := .T.
	Local lRet		:= .F.

	Private li := 80 ,m_pag := 1
	Private Cabec1, Cabec2
	Private cOldMedida := '  ', cOldDesenh := '  ', cOldCodBem := '  '
	Private nomeprog := "MNTR245"
	Private nTotKmR1, nTotKmR2, nTotKmR3, nTotKmR4, nTotKmTo
	Private nQtdR1, nQtdR2, nQtdR3, nQtdR4, nQtdTo
	Private nValR1, nValR2, nValR3, nValR4, nValTo
	Private nTotKmR1AN, s, nTotKmR3AN, nTotKmR4AN, nTotKmToAN //Usados apenas no Analitico
	Private nValR1An, nValR2An, nValR3An, nValR4An, nValToAn //Usados apenas no Analitico
	Private cSucata  := GetMV("MV_NGSTARS")
	Private nPneuTotal := 0, nPneuR1 := 0, nPneuR2 := 0, nPneuR3 := 0, nPneuR4 := 0

	Store 0 to nTotKmR1, nTotKmR2, nTotKmR3, nTotKmR4, nTotKmTo
	Store 0 to nQtdR1, nQtdR2, nQtdR3, nQtdR4, nQtdTo
	Store 0 to nValR1, nValR2, nValR3, nValR4, nValTo
	Store 0 to nTotKmR1AN, nTotKmR2AN, nTotKmR3AN, nTotKmR4AN, nTotKmToAN //Usados apenas no Analitico
	Store 0 to nValR1An, nValR2An, nValR3An, nValR4An, nValToAn //Usados apenas no Analitico

	nTipo := IIF(aReturn[4]==1,15,18)

	If MV_PAR06 == 1
		Cabec1   := STR0004 //"                                              -----------R1-----------    -----------R2-----------    -----------R3-----------    -----------R4-----------    ---------TOTAL----------"
		Cabec2   := STR0005 //"Medida/Desenho            Pneu                             KM      CPK                 KM      CPK                 KM      CPK                 KM      CPK                 KM      CPK"
	Else
		Cabec1   := STR0006 //"                                -----------R1-----------    -----------R2-----------    -----------R3-----------    -----------R4-----------    ---------TOTAL----------"
		Cabec2   := STR0007 //"Medida/Desenho                               KM      CPK                 KM      CPK                 KM      CPK                 KM      CPK                 KM      CPK"
	Endif

	/*
	************************************************************************************************************************************
	*<empresa>                                                                                                        Folha..: xxxxx   *
	*SIGA /SCR001/v.P10                            RelatÛrio de An·lise de Desenho                                    DT.Ref.: dd/mm/aa*
	*Hora...: xx:xx:xx                                        Analitico                                               Emissao: dd/mm/aa*
	*************************************************************************************************************************************
	1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8
	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567
	-----------R1-----------    -----------R2-----------    -----------R3-----------    -----------R4-----------    ---------TOTAL----------
	Medida/Desenho            Pneu                             KM      CPK                 KM      CPK                 KM      CPK                 KM      CPK                 KM      CPK
	********************************************************************************************************************************************************************************************
	xxxxxxxxxxxxxxxxxxxx
	xxxxxxxxxxxxxxxxxxxx   xxxxxxxxxxxxxxxx
	Totais:     999.999.999.999  999,999    999.999.999.999  999,999    999.999.999.999  999,999    999.999.999.999  999,999    999.999.999.999  999,999
	MÈdia/Qtd:   999.999.999,99    99999     999.999.999,99    99999     999.999.999,99    99999     999.999.999,99    99999     999.999.999,99    99999
	*/


	/*
	************************************************************************************************************************************
	*<empresa>                                                                                                        Folha..: xxxxx   *
	*SIGA /SCR001/v.P10                            RelatÛrio de An·lise de Desenho                                    DT.Ref.: dd/mm/aa*
	*Hora...: xx:xx:xx                                        Sintetico                                               Emissao: dd/mm/aa*
	*************************************************************************************************************************************
	1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6
	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567
	-----------R1-----------    -----------R2-----------    -----------R3-----------    -----------R4-----------    ---------TOTAL----------
	Medida/Desenho                               KM      CPK                 KM      CPK                 KM      CPK                 KM      CPK                 KM      CPK
	************************************************************************************************************************************************************************
	xxxxxxxxxxxxxxxxxxxx
	xxxxxxxxxxxxxxxxxxxx
	Totais:     999.999.999.999  999,999    999.999.999.999  999,999    999.999.999.999  999,999    999.999.999.999  999,999    999.999.999.999  999,999
	MÈdia/Qtd:   999.999.999,99    99999     999.999.999,99    99999     999.999.999,99    99999     999.999.999,99    99999     999.999.999,99    99999
	*/

	cAliasQry := GetNextAlias()
	cQuery := " SELECT TQS.TQS_KMR1, TQS.TQS_KMR2, TQS.TQS_KMR3, TQS.TQS_KMR4, TQS.TQS_MEDIDA, "
	cQuery += " TQS.TQS_DESENH, TQS.TQS_CODBEM, TQS.TQS_BANDAA, ST9.T9_VALCPA "
	cQuery += " FROM "+RetSqlName("ST9")+" ST9, "+RetSqlName("TQS")+" TQS "
	If NGSX2MODO("ST9") == NGSX2MODO("TQS")
		cQuery += " WHERE ST9.T9_FILIAL = TQS.TQS_FILIAL "
	Else
		cQuery += " WHERE TQS.TQS_FILIAL = '"+xFilial("TQS")+"'"
	EndIf
	cQuery += " AND ST9.T9_CODBEM = TQS.TQS_CODBEM "
	If MV_PAR01 == 2
		cQuery += " AND ST9.T9_STATUS = '"+cSucata+"'"
	ElseIf MV_PAR01 == 3
		cQuery += " AND ST9.T9_STATUS <> '"+cSucata+"'"
	Endif
	cQuery += " AND TQS.TQS_MEDIDA >= '"+MV_PAR02+"'"
	cQuery += " AND TQS.TQS_MEDIDA <= '"+MV_PAR03+"'"
	cQuery += " AND TQS.TQS_DESENH >= '"+MV_PAR04+"'"
	cQuery += " AND TQS.TQS_DESENH <= '"+MV_PAR05+"'"
	cQuery += " AND (TQS.TQS_KMR1 <> 0 OR TQS.TQS_KMR2 <> 0 OR TQS.TQS_KMR3 <> 0 OR TQS.TQS_KMR4 <> 0 ) "
	cQuery += " AND TQS.TQS_BANDAA > '1' "
	cQuery += " AND ST9.D_E_L_E_T_ <> '*' "
	cQuery += " AND TQS.D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY TQS.TQS_MEDIDA, TQS.TQS_DESENH "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	dbSelectArea(cAliasQry)
	SetRegua(LastRec())
	dbGoTop()
	While (cAliasQry)->( !EoF() )
		IncRegua()
		If lFirstRec
			lFirstRec := .F.
			lRet 	  := .T.
			NgSomaLi(58)
		Endif

		lImpCab := .f.
		If cOldMedida != (cAliasQry)->TQS_MEDIDA
			@ Li,000 PSay NGSEEK("TQT",(cAliasQry)->TQS_MEDIDA,1,'TQT_DESMED')
			cOldMedida := (cAliasQry)->TQS_MEDIDA
			NgSomaLi(58)
			lImpCab := .t.
		Endif
		If cOldDesenh != (cAliasQry)->TQS_DESENH .OR. lImpCab
			@ Li,006 PSay (cAliasQry)->TQS_DESENH
			cOldDesenh := (cAliasQry)->TQS_DESENH
			If MV_PAR06 == 2
				NgSomaLi(58)
			Endif
		Endif

		If MV_PAR06 == 1
			If cOldCodBem != (cAliasQry)->TQS_CODBEM
				@ Li,026 PSay (cAliasQry)->TQS_CODBEM
				cOldCodBem := (cAliasQry)->TQS_CODBEM
				Store 0 to nTotKmR1, nTotKmR2, nTotKmR3, nTotKmR4, nTotKmTo
				Store 0 to nValR1, nValR2, nValR3, nValR4//, nValTo
			Endif
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
		nTotKmTo += (cAliasQry)->TQS_KMR1 + (cAliasQry)->TQS_KMR2 + (cAliasQry)->TQS_KMR3 + (cAliasQry)->TQS_KMR4
		nTotKmToAN += (cAliasQry)->TQS_KMR1 + (cAliasQry)->TQS_KMR2 + (cAliasQry)->TQS_KMR3 + (cAliasQry)->TQS_KMR4
		nQtdTo += 1
		//Carregando o custo dos pneus
		cAliasQry2 := GetNextAlias()
		cQuery := " SELECT STL.TL_DTINICI, STL.TL_HOINICI, STL.TL_CUSTO "
		cQuery += " FROM " + RetSqlName("STJ")+" STJ, "+ RetSqlName("STL")+" STL "
		cQuery += " WHERE STL.TL_FILIAL  = STJ.TJ_FILIAL "
		cQuery += " AND   STL.TL_ORDEM   = STJ.TJ_ORDEM "
		cQuery += " AND   STL.TL_PLANO   = STJ.TJ_PLANO "
		cQuery += " AND   STJ.TJ_CODBEM  = '"+(cAliasQry)->TQS_CODBEM+"'"
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
			cQuery += " WHERE TQV.TQV_CODBEM = '"+(cAliasQry)->TQS_CODBEM+"'"
			cQuery += " AND (TQV.TQV_DTMEDI||TQV.TQV_HRMEDI) <= '"+(cAliasQry2)->TL_DTINICI+(cAliasQry2)->TL_HOINICI+"'"
			cQuery += " AND TQV.D_E_L_E_T_ <> '*' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry3, .F., .T.)
			dbGotop()
			If !Eof()
				If SubStr((cAliasQry3)->BANDA,14,1) == '2'
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
		nValTo := nValR1 + nValR2 + nValR3 + nValR4
		nValToAn := nValR1An + nValR2An + nValR3An + nValR4An
		If MV_PAR06 == 2
			nPneuTotal += nValR1 + nValR2 + nValR3 + nValR4
		Endif
		//Fim
		dbSelectArea(cAliasQry)
		dbSkip()
		MNR245BAN(Eof())
	EndDo

	If !lRet
		MsgInfo(STR0026, STR0027)// "N„o existem dados para montar o relatÛrio."###"ATEN«√O"
	EndIf

	(cAliasQry)->(dbCloseArea())
	RetIndex("TQS")
	Set Filter To
	Set Device To Screen
	If aReturn[5] == 1 .And. lRet
		Set Printer To
		dbCommitAll()
		OurSpool(WNREL)
	EndIf
	MS_FLUSH()

Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥MNR245BAN ≥ Autor ≥ Marcos Wagner Junior  ≥ Data ≥22/07/2009≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Imprime o relatÛrio                                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ MNTR245                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function MNR245BAN(lFimArq)
	Private nSomaColu := 0

	If MV_PAR06 == 1
		nSomaColu := 14
	Endif

	If (cOldMedida != (cAliasQry)->TQS_MEDIDA) .OR. (cOldDesenh != (cAliasQry)->TQS_DESENH) .OR. lFimArq
		If MV_PAR06 == 1
			MNR125CABA()
			NgSomaLi(58)
			nTotKmR1 := nTotKmR1AN; nTotKmR2 := nTotKmR2AN; nTotKmR3 := nTotKmR3AN; nTotKmR4 := nTotKmR4AN; nTotKmTo := nTotKmToAN
			nValR1 := nValR1An; nValR2 := nValR2An; nValR3 := nValR3An; nValR4 := nValR4An
			Store 0 to nTotKmR1AN, nTotKmR2AN, nTotKmR3AN, nTotKmR4AN, nTotKmToAN
			Store 0 to nValR1An, nValR2An, nValR3An, nValR4An, nValToAn
			nValTo := nPneuTotal
			nValR1 := nPneuR1;	nValR2 := nPneuR2; nValR3 := nPneuR3;	nValR4 := nPneuR4
			nPneuTotal := 0
			nPneuR1 := 0; nPneuR2 := 0; nPneuR3 := 0; nPneuR4 := 0
		Else
			nValTo := nValR1 + nValR2 + nValR3 + nValR4
		Endif
		@ Li,020+nSomaColu PSay STR0008 //"Totais:"
		@ Li,032+nSomaColu PSay PADL(Transform(nTotKmR1,"@E 999,999,999,999"),15)
		@ Li,049+nSomaColu PSay PADL(Transform(nValR1/nTotKmR1,"@E 999.999"),7)
		@ Li,060+nSomaColu PSay PADL(Transform(nTotKmR2,"@E 999,999,999,999"),15)
		@ Li,077+nSomaColu PSay PADL(Transform(nValR2/nTotKmR2,"@E 999.999"),7)
		@ Li,088+nSomaColu PSay PADL(Transform(nTotKmR3,"@E 999,999,999,999"),15)
		@ Li,105+nSomaColu PSay PADL(Transform(nValR3/nTotKmR3,"@E 999.999"),7)
		@ Li,116+nSomaColu PSay PADL(Transform(nTotKmR4,"@E 999,999,999,999"),15)
		@ Li,133+nSomaColu PSay PADL(Transform(nValR4/nTotKmR4,"@E 999.999"),7)
		@ Li,144+nSomaColu PSay PADL(Transform(nTotKmTo,"@E 999,999,999,999"),15)
		@ Li,161+nSomaColu PSay PADL(Transform(nValTo/nTotKmTo,"@E 999.999"),7)

		NgSomaLi(58)
		@ Li,020+nSomaColu PSay STR0009 //"MÈdia/Qtd:"
		@ Li,033+nSomaColu PSay PADL(Transform(nTotKmR1/nQtdR1,"@E 999,999,999.99"),14)
		@ Li,049+nSomaColu PSay PADL(Transform(nQtdR1,"@E 999,999"),7)
		@ Li,061+nSomaColu PSay PADL(Transform(nTotKmR2/nQtdR2,"@E 999,999,999.99"),14)
		@ Li,077+nSomaColu PSay PADL(Transform(nQtdR2,"@E 999,999"),7)
		@ Li,089+nSomaColu PSay PADL(Transform(nTotKmR3/nQtdR3,"@E 999,999,999.99"),14)
		@ Li,105+nSomaColu PSay PADL(Transform(nQtdR3,"@E 999,999"),7)
		@ Li,117+nSomaColu PSay PADL(Transform(nTotKmR4/nQtdR4,"@E 999,999,999.99"),14)
		@ Li,133+nSomaColu PSay PADL(Transform(nQtdR4,"@E 999,999"),7)
		@ Li,145+nSomaColu PSay PADL(Transform(nTotKmTo/nQtdTo,"@E 999,999,999.99"),14)
		@ Li,161+nSomaColu PSay PADL(Transform(nQtdTo,"@E 999,999"),7)
		Store 0 to nTotKmR1, nTotKmR2, nTotKmR3, nTotKmR4, nTotKmTo
		Store 0 to nQtdR1, nQtdR2, nQtdR3, nQtdR4, nQtdTo
		Store 0 to nValR1, nValR2, nValR3, nValR4, nValTo
		NgSomaLi(58)
		NgSomaLi(58)
	ElseIf MV_PAR06 == 1
		MNR125CABA()
	Endif

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥MNR125CABA≥ Autor ≥ Marcos Wagner Junior  ≥ Data ≥22/07/2009≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Imprime o conteudo dos pneus (Analitico                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ MNTR245                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function MNR125CABA()

	@ Li,046 PSay PADL(Transform(nTotKmR1,"@E 999,999,999,999"),15)
	@ Li,063 PSay PADL(Transform(nValR1/nTotKmR1,"@E 999.999"),7)
	@ Li,074 PSay PADL(Transform(nTotKmR2,"@E 999,999,999,999"),15)
	@ Li,091 PSay PADL(Transform(nValR2/nTotKmR2,"@E 999.999"),7)
	@ Li,102 PSay PADL(Transform(nTotKmR3,"@E 999,999,999,999"),15)
	@ Li,119 PSay PADL(Transform(nValR3/nTotKmR3,"@E 999.999"),7)
	@ Li,130 PSay PADL(Transform(nTotKmR4,"@E 999,999,999,999"),15)
	@ Li,147 PSay PADL(Transform(nValR4/nTotKmR4,"@E 999.999"),7)
	@ Li,158 PSay PADL(Transform(nTotKmTo,"@E 999,999,999,999"),15)
	@ Li,175 PSay PADL(Transform(nValTo/nTotKmTo,"@E 999.999"),7)
	NgSomaLi(58)

	nPneuTotal += nValR1 + nValR2 + nValR3 + nValR4
	nPneuR1 += nValR1; 	nPneuR2 += nValR2; nPneuR3 += nValR3; 	nPneuR4 += nValR4

Return