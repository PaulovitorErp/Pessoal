#INCLUDE "PROTHEUS.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTV047
Quantidade de total O.S, com Bens que possuam apenas 1 O.S (Número total de corretivas).

@param De_Data, Data, Data início
@param Ate_Data, Data, Data fim
@param De_Bem, Caractere, Bem início
@param [Ate_Bem], Caractere, Bem fim
@param De_Ccusto, Caractere, Centro de custo início
@param [Ate_Ccusto], Caractere, Centro de custo fim
@param De_CenTra, Caractere, Centro de trabalho início
@param [Ate_CenTra], Caractere, Centro de trabalho fim

@author Vitor Bonet
@since 15/08/2018
@version P12
@return nResult, Numérico, Quantidade de O.S.
/*/
//------------------------------------------------------------------------------
Function MNTV047(De_Data,Ate_Data,De_Bem,Ate_Bem,De_Ccusto,Ate_Ccusto,;
                 De_CenTra,Ate_CenTra)

	Local aArea     := GetArea()
	Local aParams   := {}
	Local cCodIndic := "MNTV047"
	Local cAliasOS  := GetNextAlias()
	Local nResult   := 0

	Default De_Bem    := ""
	Default De_Ccusto := ""
	Default De_CenTra := ""

	// Armazena os Parâmetros
	If NGI6MVHIST()

		aParams := {}
		aAdd(aParams, {"DE_DATA"   , De_Data})
		aAdd(aParams, {"ATE_DATA"  , Ate_Data})
		aAdd(aParams, {"DE_BEM"    , De_Bem})
		aAdd(aParams, {"ATE_BEM"   , Ate_Bem})
		aAdd(aParams, {"DE_CCUSTO" , De_Ccusto})
		aAdd(aParams, {"ATE_CCUSTO", Ate_Ccusto})
		aAdd(aParams, {"DE_CENTRA" , De_CenTra})
		aAdd(aParams, {"ATE_CENTRA", Ate_CenTra})
		NGI6PREPPA(aParams, cCodIndic)

	EndIf

	cQuery := "SELECT SUM(QTDOS) QTDOS"
	cQuery += "  FROM ("
	cQuery += "        SELECT Count(TJ_ORDEM) + Count(TS_ORDEM) AS QTDOS"
	cQuery += "          FROM " + RetSqlName("STJ") + " STJ"
	cQuery += "          LEFT JOIN " + RetSqlName("STS") + " STS"
	cQuery += "            ON STJ.TJ_FILIAL = STS.TS_FILIAL"
	cQuery += "           AND STJ.TJ_CODBEM = STS.TS_CODBEM"
	cQuery += "           AND TS_CODBEM BETWEEN " + ValToSQL(De_Bem) + " AND " + ValToSQL(Ate_Bem)
	cQuery += "           AND TS_CCUSTO BETWEEN " + ValToSQL(De_Ccusto) + " AND " + ValToSQL(Ate_Ccusto)
	cQuery += "           AND TS_CENTRAB BETWEEN " + ValToSQL(De_CenTra) + " AND " + ValToSQL(Ate_CenTra)
	cQuery += "           AND TS_TIPOOS = 'B'"
	cQuery += "           AND TS_TERMINO = 'S'"
	cQuery += "           AND TS_SITUACA = 'L'"
	cQuery += "           AND TS_PLANO = '000000'"
	cQuery += "           AND TS_DTMRINI >= " + ValToSQL(De_Data)
	cQuery += "           AND TS_DTMRFIM <= " + ValToSQL(Ate_Data)
	cQuery += "           AND STS.D_E_L_E_T_ <> '*'"
	cQuery += "         WHERE TJ_FILIAL = " + ValToSQL(xFilial("STJ"))
	cQuery += "           AND TJ_CODBEM BETWEEN " + ValToSQL(De_Bem) + " AND " + ValToSQL(Ate_Bem)
	cQuery += "           AND TJ_CCUSTO BETWEEN " + ValToSQL(De_Ccusto) + " AND " + ValToSQL(Ate_Ccusto)
	cQuery += "           AND TJ_CENTRAB BETWEEN " + ValToSQL(De_CenTra) + " AND " + ValToSQL(Ate_CenTra)
	cQuery += "           AND TJ_TIPOOS = 'B'"
	cQuery += "           AND TJ_TERMINO = 'S'"
	cQuery += "           AND TJ_SITUACA = 'L'"
	cQuery += "           AND TJ_PLANO = '000000'"
	cQuery += "           AND TJ_DTMRINI >= " + ValToSQL(De_Data)
	cQuery += "           AND TJ_DTMRFIM <= " + ValToSQL(Ate_Data)
	cQuery += "           AND STJ.D_E_L_E_T_ <> '*'"
	cQuery += "         GROUP BY STJ.TJ_CODBEM, STS.TS_CODBEM"
	cQuery += "        HAVING COUNT(STJ.TJ_ORDEM) = 1 OR COUNT(STS.TS_ORDEM) = 1 ) QTDOS"

	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery(cQuery, cAliasOS)
	NGI6PREPDA(cAliasOS, cCodIndic)

	dbSelectArea(cAliasOS)

	nResult = (cAliasOS)->QTDOS

	dbSelectArea(cAliasOS)
	dbCloseArea()

	// RESULTADO
	NGI6PREPVA(cCodIndic, nResult)

	RestArea(aArea)

Return nResult
