#INCLUDE "PROTHEUS.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTV045
Cálculo da variável VLRP - Valor de compra desse equipamento novo (valor de reposição).

@param De_Bem    , Caractere, Bem de início para filtro na Query
@param Ate_Bem   , Caractere, Ate Bem para filtro na Query
@param De_Ccusto , Caractere, Centro de Custo início para filtro na Query
@param Ate_Ccusto, Caractere, Ate Centro de Custo para filtro na Query

@author Vitor Bonet
@since 07/08/2018
@version P12
@return nResult, Numérico, Soma do valor de compra
/*/
//------------------------------------------------------------------------------
Function MNTV045(De_Bem, Ate_Bem, De_Ccusto, Ate_Ccusto)

	Local aArea   := GetArea()
	Local cAlias  := GetNextAlias()
	Local cQry    := ""
	Local nResult := 0

	Default De_Bem    := "" // De bem início
	Default De_Ccusto := "" // De centro de custo

	cQry := "SELECT SUM(VLTO) AS VALOR_TOTAL"
	cQry += " FROM ( SELECT"
	cQry += "        CASE"
	cQry += "        WHEN T9_CODESTO IS NULL THEN T9_VALCPA"
	cQry += "        WHEN SB1.B1_CUSTD <> 0 THEN SB1.B1_CUSTD"
	cQry += "        ELSE T9_VALCPA END AS VLTO"
	cQry += "        FROM " + RetSqlName("ST9") + " ST9"
	cQry += "        LEFT JOIN " + RetSqlName("SB1") + " SB1 ON ST9.T9_CODESTO = SB1.B1_COD"
	cQry += "        AND SB1.B1_FILIAL = " + ValToSQL(xFilial("SB1"))
    cQry += "        AND SB1.D_E_L_E_T_ <> '*'"
	cQry += "	     WHERE T9_FILIAL = " + ValToSQL(xFilial("ST9"))
	cQry += "	     AND T9_CODBEM BETWEEN " + ValToSQL(De_Bem) + " AND " + ValToSQL(Ate_Bem)
	cQry += "	     AND T9_CCUSTO BETWEEN " + ValToSQL(De_Ccusto) + " AND " + ValToSQL(Ate_Ccusto)
	cQry += "	     AND ST9.D_E_L_E_T_ <> '*' )VLTO"

	cQry := ChangeQuery(cQry)
	MPSysOpenQuery(cQry, cAlias)

	dbSelectArea(cAlias)

	nResult := (cAlias)->VALOR_TOTAL

	(cAlias)->(dbCloseArea())

	RestArea(aArea)

Return nResult
