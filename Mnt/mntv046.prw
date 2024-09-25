#INCLUDE "PROTHEUS.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTV046
Cálculo da variável FTEP - Faturamento da empresa no período.

@param De_Data  , Date    , Data início para filtro na Query
@param Ate_Data  , Date    , Ate data para filtro na Query
@param Fat_Period, Numérico, Faturamento da empresa no período.

@author Wexlei Silveira
@since 25/07/2018
@version P12
@return nResult, Numérico, Soma do faturamento
/*/
//------------------------------------------------------------------------------
Function MNTV046(De_Data, Ate_Data, Fat_Period)

	Local aArea    := GetArea() // Salva área posicionada.
	Local cAlias   := GetNextAlias() // Alias atual.
	Local cQry     := "" // Variável para armazenamento da query.
	Local nResult  := 0 // Variável do resultado.
	Local lSigaFin := SuperGetMv("MV_NGMNTFI",.F.,"N") == "S" // Verificar se está habilitado o Módulo Financeiro.

	Default De_Data   := CToD("")
	Default Fat_Period := 0

	If lSigaFin .And. Fat_Period == 0 // Caso seja integrado ao Financeiro e não foi informado valor no FAT_PERIOD

		cQry := "SELECT SUM(E1_VALOR) AS FATURAMENTO_BRUTO"
		cQry += "  FROM " + RetSqlName("SE1")
		cQry += " WHERE E1_FILIAL = " + ValToSQL(xFilial("SE1"))
		cQry += "   AND E1_VENCREA BETWEEN " + ValToSQL(De_Data) + " AND " + ValToSQL(Ate_Data)
		cQry += "   AND D_E_L_E_T_ <> '*'"

		cQry := ChangeQuery(cQry)
		MPSysOpenQuery(cQry, cAlias)

		dbSelectArea(cAlias)
		nResult := (cAlias)->FATURAMENTO
		(cAlias)->(dbCloseArea())
	Else
		nResult := Fat_Period
	EndIf

	RestArea(aArea)

Return nResult
