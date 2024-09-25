#INCLUDE "Protheus.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTV038
Indicador: Quantidade de S.S.'s Atendidas NO PRAZO.

@author Wagner Sobral de Lacerda
@since 15/10/2012

@return nTotSSPrazo
/*/
//---------------------------------------------------------------------
Function MNTV038(De_Data,Ate_Data,De_Bem,Ate_Bem,De_Locali,Ate_Locali,De_Ccusto,Ate_Ccusto,;
				 De_Servico,Ate_Servico,De_CenTra,Ate_CenTra)

	// Salva a área anterior
	Local aAreaOLD := GetArea()

	// Variável do Retorno
	Local nTotSSPrazo := 0

	// Variável do Facilities
	Local lFacilit := If(FindFunction("MNTINTFAC"), MNTINTFAC(), .F.)

	// Variáveis da Query
	Local cQryAlias := ""
	Local cQryExec  := ""

	// Variáveis do Cálculo
	Local dDtAber := CTOD("")
	Local cHrAber := ""
	Local dDtInic := CTOD("")
	Local cHrInic := ""

	Local cTempoMaxi := "", nTempoMaxi := 0
	Local cTempoInic := "", nTempoInic := 0

	Local aSSProc  := {}
	Local lNoPrazo := .F.

	// Variáveis de Histórico de Indicadores
	Local lMV_HIST  := NGI6MVHIST()
	Local aParams   := {}
	Local cCodIndic := "MNTV038"
	Local nResult   := 0

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
		cQryExec += " TQB.TQB_SOLICI, TQB.TQB_DTABER, TQB.TQB_HOABER, "
		cQryExec += " TUM.TUM_DTINIC, TUM.TUM_HRINIC, "
		cQryExec += " TU9.TU9_TMPMAX "
	EndIf
	// FROM "TQB"
	cQryExec += "FROM " + RetSQLName("TQB") + " TQB "
	// LEFT JOIN "TU9"
	cQryExec += "LEFT JOIN " + RetSQLName("TU9") + " TU9 ON ( "
	If FWModeAccess("TU9",1) == FWModeAccess("TQB",2) .And. FWModeAccess("TU9",2) == FWModeAccess("TQB",2) .And. FWModeAccess("TU9",3) == FWModeAccess("TQB",3)
		cQryExec += " TU9.TU9_FILIAL = TQB.TQB_FILIAL "
	Else
		cQryExec += " TU9.TU9_FILIAL = " + ValToSQL(xFilial("TU9")) + " "
	EndIf
	cQryExec += " AND TQB.TQB_CRITIC BETWEEN TU9.TU9_PERCIN AND TU9.TU9_PERCFI "
	cQryExec += " AND TU9.D_E_L_E_T_ <> '*' "
	cQryExec += ") "
	// INNER JOIN "TUM"
	cQryExec += "LEFT JOIN " + RetSQLName("TUM") + " TUM ON ( "
	If FWModeAccess("TUM",1) == FWModeAccess("TQB",2) .And. FWModeAccess("TUM",2) == FWModeAccess("TQB",2) .And. FWModeAccess("TUM",3) == FWModeAccess("TQB",3)
		cQryExec += " TUM.TUM_FILIAL = TQB.TQB_FILIAL "
	Else
		cQryExec += " TUM.TUM_FILIAL = " + ValToSQL(xFilial("TUM")) + " "
	EndIf
	cQryExec += " AND TUM.TUM_SOLICI = TQB.TQB_SOLICI "
	cQryExec += " AND TUM.TUM_CODFOL = '09' " // Apenas "Atendimento"
	cQryExec += " AND TUM.D_E_L_E_T_ <> '*' "
	cQryExec += ") "
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
	While !Eof()
		// Considera apenas S.S. distintas (pois o cálculo é feito apenas com o primeiro atendimento)
		If aScan(aSSProc, {|x| x == (cQryAlias)->TQB_SOLICI }) == 0
			aAdd(aSSProc, (cQryAlias)->TQB_SOLICI)

			// Atribui Falso para o atendimento no prazo
			lNoPrazo := .F.

			// Data/Hora de Abertura da S.S.
			dDtAber := STOD( (cQryAlias)->TQB_DTABER )
			cHrAber := IIf(Alltrim((cQryAlias)->TQB_HOABER) == ":", "", (cQryAlias)->TQB_HOABER)
			// Data/Hora de Início do Primeiro Atendimento
			dDtInic := STOD( (cQryAlias)->TUM_DTINIC )
			cHrInic := IIf(Alltrim((cQryAlias)->TUM_HRINIC) == ":", "", (cQryAlias)->TUM_HRINIC)

			// Se a Data/Hora de Atendimento for menor que a Data/Hora de Abertura, então considera como atendida no prazo
			If dDtInic < dDtAber .Or. ( dDtInic == dDtAber .And. cHrInic < cHrAber )
				lNoPrazo := .T.
			Else
				// Tempo máximo para o primeiro atendimento
				cTempoMaxi := (cQryAlias)->TU9_TMPMAX
				If Empty(cTempoMaxi)
					lNoPrazo := .T. // Se não houver criticidade definida, considera a S.S. como atendida no prazo
				Else
					nTempoMaxi := HTON(cTempoMaxi)

					// Tempo decorrido até o início do atendimento
					cTempoInic := NGCALCHCAR(dDtAber, cHrAber, dDtInic, cHrInic)
					nTempoInic := HTON(cTempoInic)

					// Se o tempo até o primeiro atendimento for menor que o tempo máximo, então a S.S. foi atendida dentro do prazo
					If nTempoInic < nTempoMaxi
						lNoPrazo := .T.
					EndIf
				Endif
			EndIf

			// Incrementa Quantidade de S.S.'s atendidas no prazo
			If lNoPrazo
				nTotSSPrazo++
			EndIf
		EndIf

		dbSelectArea(cQryAlias)
		dbSkip()
	End
	dbSelectArea(cQryAlias)
	dbCloseArea()

	// RESULTADO
	nResult := nTotSSPrazo
	NGI6PREPVA(cCodIndic, nResult)

	// Devolve a área
	RestArea(aAreaOLD)

Return nResult
