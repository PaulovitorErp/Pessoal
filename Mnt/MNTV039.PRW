#INCLUDE	"Protheus.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTV039
Indicador: Quantidade de S.S.'s Encerradas e Canceladas.

@author Wagner Sobral de Lacerda
@since 15/10/2012

@return nTotSS
/*/
//---------------------------------------------------------------------
Function MNTV039(De_Data,Ate_Data,De_Bem,Ate_Bem,De_Locali,Ate_Locali,De_Ccusto,Ate_Ccusto,;
						De_Servico,Ate_Servico,De_CenTra,Ate_CenTra)
	
	// Salva a área anterior
	Local aAreaOLD := GetArea()
	
	// Variável do Retorno
	Local nTotSS := 0
	
	// Variável do Facilities
	Local lFacilit := If(FindFunction("MNTINTFAC"), MNTINTFAC(), .F.)
	
	// Variáveis da Query
	Local cQryAlias := ""
	Local cQryExec  := ""
	
	// Variáveis de Histórico de Indicadores
	Local lMV_HIST := NGI6MVHIST()
	Local aParams := {}
	Local cCodIndic := "MNTV039"
	Local nResult := 0
	
	// Armazena os Parâmetros
	If lMV_HIST
		aParams := {}
		aAdd(aParams, {"DE_DATA"    , De_Data})
		aAdd(aParams, {"ATE_DATA"   , Ate_Data})
		aAdd(aParams, {"DE_BEM"     , De_Bem})
		aAdd(aParams, {"ATE_BEM"    , Ate_Bem})
		aAdd(aParams, {"DE_LOCALI"  , De_Locali})
		aAdd(aParams, {"ATE_LOCALI" , Ate_Locali})
		aAdd(aParams, {"DE_CCUSTO"  , De_Ccusto})
		aAdd(aParams, {"ATE_CCUSTO" , Ate_Ccusto})
		aAdd(aParams, {"DE_SERVICO" , De_Servico})
		aAdd(aParams, {"ATE_SERVICO", Ate_Servico})
		aAdd(aParams, {"DE_CENTRA"  , De_CenTra})
		aAdd(aParams, {"ATE_CENTRA" , Ate_CenTra})
		NGI6PREPPA(aParams, cCodIndic)
	EndIf
	
	//-- Verifica se pode executar o Indicador
	If !lFacilit
		NGI6PREPVA(cCodIndic, nResult)
		Return nResult
	EndIf
	
	//------------------------------
	// Busca as S.S.'s
	//------------------------------
	//-- Tabela Temporária
	cQryAlias := GetNextAlias()
	
	//-- Query
	// SELECT
	cQryExec := "SELECT "
	If lMV_HIST
		cQryExec += " * "
	Else
		cQryExec += " COUNT(TQB.TQB_SOLICI) AS QUANTSS "
	EndIf
	// FROM "TQB"
	cQryExec += "FROM " + RetSQLName("TQB") + " TQB "
	// WHERE
	cQryExec += "WHERE "
	cQryExec += " TQB.TQB_FILIAL = " + ValToSQL(xFilial("TQB")) + " "
	cQryExec += " AND TQB.TQB_SOLUCA IN ('E', 'C') " // Apenas "Encerradas" e "Canceladas"
		// Data
		If ValType(De_Data) == "D"
			cQryExec += " AND TQB.TQB_DTABER >= " + ValToSQL(De_Data) + " "
		EndIf
		If ValType(Ate_Data) == "D"
			cQryExec += " AND TQB.TQB_DTABER <= " + ValToSQL(Ate_Data) + " "
		EndIf
		// Bem
		If ValType(De_Bem) == "C"
			cQryExec += " AND TQB.TQB_CODBEM >= " + ValToSQL(De_Bem) + " "
		EndIf
		If ValType(Ate_Bem) == "C"
			cQryExec += " AND TQB.TQB_CODBEM <= " + ValToSQL(Ate_Bem) + " "
		EndIf
		// Localização
		If ValType(De_Locali) == "C"
			cQryExec += " AND TQB.TQB_LOCALI >= " + ValToSQL(De_Locali) + " "
		EndIf
		If ValType(Ate_Locali) == "C"
			cQryExec += " AND TQB.TQB_LOCALI <= " + ValToSQL(Ate_Locali) + " "
		EndIf
		// Centro de Custo
		If ValType(De_Ccusto) == "C"
			cQryExec += " AND TQB.TQB_CCUSTO >= " + ValToSQL(De_Ccusto) + " "
		EndIf
		If ValType(Ate_Ccusto) == "C"
			cQryExec += " AND TQB.TQB_CCUSTO <= " + ValToSQL(Ate_Ccusto) + " "
		EndIf
		// Tipo de Serviço
		If ValType(De_Servico) == "C"
			cQryExec += " AND TQB.TQB_CDSERV >= " + ValToSQL(De_Servico) + " "
		EndIf
		If ValType(Ate_Servico) == "C"
			cQryExec += " AND TQB.TQB_CDSERV <= " + ValToSQL(Ate_Servico) + " "
		EndIf
		// Centro de Trabalho
		If ValType(De_CenTra) == "D"
			cQryExec += " AND TQB.TQB_CENTRA >= " + ValToSQL(De_CenTra) + " "
		EndIf
		If ValType(Ate_CenTra) == "D"
			cQryExec += " AND TQB.TQB_CENTRA <= " + ValToSQL(Ate_CenTra) + " "
		EndIf
	cQryExec += " AND TQB.D_E_L_E_T_ <> '*' "
	
	// Verifica a Sintaxe da Query de acordo com o Banco de Dados
	cQryExec := ChangeQuery(cQryExec)
	//-- Executa a Query
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryExec), cQryAlias, .F., .T.)
	NGI6PREPDA(cQryAlias, cCodIndic)
	
	//------------------------------
	// Calcula S.S.'s no Prazo
	//------------------------------
	dbSelectArea(cQryAlias)
	dbGoTop()
	If lMV_HIST
		While !Eof()
			nTotSS++
			dbSkip()
		End
	Else
		If !Eof()
			nTotSS := (cQryAlias)->QUANTSS
		EndIf
	EndIf
	dbSelectArea(cQryAlias)
	dbCloseArea()
	
	// RESULTADO
	nResult := nTotSS
	NGI6PREPVA(cCodIndic, nResult)
	
	// Devolve a área
	RestArea(aAreaOLD)
	
Return nResult