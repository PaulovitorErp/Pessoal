/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MNTV035    ³ Autor ³ Marcos Wagner Junior  ³ Data ³19/01/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula a qtde de solicitacoes realizadas ou abertas         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ De_Data  - Data inicio                                       ³±±
±±³          ³ Ate_Data - Ate data                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³ nCusto   - Custo das horas de manutencao preventivas         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNTV035(De_Data,Ate_Data,De_Bem,Ate_Bem,De_Locali,Ate_Locali,De_Ccusto,Ate_Ccusto,;
						De_Area,Ate_Area,De_Servico,Ate_Servico,De_CenTra,Ate_CenTra)
Local aAreaOLD   := GetArea(), nQtdSolici := 0
Local De_BemL    := If(De_Bem     = Nil,Space(NGSEEKDIC("SX3","TQB_CODBEM",2,"X3_TAMANHO")),De_Bem)
Local De_LocaliL := If(De_Locali  = Nil,Space(NGSEEKDIC("SX3","TQB_LOCALI",2,"X3_TAMANHO")),De_Locali)
Local De_CcustoL := If(De_Ccusto  = Nil,Space(NGSEEKDIC("SX3","TQB_CCUSTO",2,"X3_TAMANHO")),De_Ccusto)
Local De_AreaL   := If(De_Area    = Nil,Space(NGSEEKDIC("SX3","TJ_CODAREA",2,"X3_TAMANHO")),De_Area)
Local De_ServicL := If(De_Servico = Nil,Space(NGSEEKDIC("SX3","TJ_SERVICO",2,"X3_TAMANHO")),De_Servico)
Local De_CenTraL := If(De_CenTra  = Nil,Space(NGSEEKDIC("SX3","TQB_CENTRA",2,"X3_TAMANHO")),De_CenTra)

// Variáveis de Histórico de Indicadores
Local lMV_HIST := NGI6MVHIST()
Local aParams := {}
Local cCodIndic := "MNTV035"
Local nResult := 0

Local lMulOS := AllTrim(GetNewPar("MV_NGMULOS","N")) == "S"
Local cAliasSTj := GetNextAlias()

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
	aAdd(aParams, {"DE_AREA"    , De_Area})
	aAdd(aParams, {"ATE_AREA"   , Ate_Area})
	aAdd(aParams, {"DE_SERVICO" , De_Servico})
	aAdd(aParams, {"ATE_SERVICO", Ate_Servico})
	aAdd(aParams, {"DE_CENTRA"  , De_CenTra})
	aAdd(aParams, {"ATE_CENTRA" , Ate_CenTra})
	NGI6PREPPA(aParams, cCodIndic)
EndIf

If lMulOS

	// Query
	If lMV_HIST
		cQuerySTJ := "SELECT * "
	Else
		cQuerySTJ := "SELECT COUNT(*) AS STJCOUNT "
	EndIf
	cQuerySTJ += " FROM "+RetSqlName("STJ")+" STJ "

	cQuerySTJ += " JOIN "+RetSqlName("TT7")+" TT7 "
	cQuerySTJ += " ON TT7.TT7_FILIAL = '"+xFilial("TT7")+"' AND TT7.D_E_L_E_T_ <> '*' "
	cQuerySTJ += " AND STJ.TJ_ORDEM = TT7.TT7_ORDEM  AND STJ.TJ_PLANO = TT7.TT7_PLANO

	cQuerySTJ += " JOIN " +RetSqlName("TQB")+ " TQB "
	cQuerySTJ += " ON TT7.TT7_SOLICI = TQB.TQB_SOLICI "
	cQuerySTJ += " WHERE STJ.TJ_FILIAL = '"+xFilial("STJ")+"' AND STJ.D_E_L_E_T_ <> '*' "

	If ValType(De_AreaL) == "C" .and. ValType(Ate_Area) == "C"
		cQuerySTJ += " AND STJ.TJ_CODAREA >= '"+De_AreaL+"' AND STJ.TJ_CODAREA <= '"+Ate_Area+"' "
	Endif
	If ValType(De_ServicL) == "C" .and. ValType(Ate_Servico) == "C"
		cQuerySTJ += " AND STJ.TJ_SERVICO >= '"+De_ServicL+"' AND STJ.TJ_SERVICO <= '"+Ate_Servico+"' "
	Endif

	cQuerySTJ += " AND TQB.TQB_FILIAL = '"+xFilial("TQB")+"' AND TQB.D_E_L_E_T_ <> '*' "
	If ValType(De_BemL) == "C" .and. ValType(Ate_Bem) == "C"
		cQuerySTJ += " AND TQB.TQB_CODBEM >= '"+De_BemL+"' AND TQB.TQB_CODBEM <= '"+Ate_Bem+"' "
	Endif

	If ValType(De_LocaliL) == "C" .and. ValType(Ate_Locali) == "C"
		cQuerySTJ += " AND TQB.TQB_LOCALI >= '"+De_LocaliL+"' AND TQB.TQB_LOCALI <= '"+Ate_Locali+"' "
	Endif

	If ValType(De_CcustoL) == "C" .and. ValType(Ate_Ccusto) == "C"
		cQuerySTJ += " AND TQB.TQB_CCUSTO >= '"+De_CcustoL+"' AND TQB.TQB_CCUSTO <= '"+Ate_Ccusto+"' "
	Endif

	If ValType(De_CenTraL) == "C" .and. ValType(Ate_CenTra) == "C"
		cQuerySTJ += " AND TQB.TQB_CENTRA >= '"+De_CenTraL+"' AND TQB.TQB_CENTRA <= '"+Ate_CenTra+"' "
	Endif

	If ValType(De_Data) == "D"
		cQuerySTJ += " AND TQB.TQB_DTABER >= '"+Dtos(De_Data)+"' "
	Endif

	If ValType(Ate_Data) == "D"
		cQuerySTJ += " AND TQB.TQB_DTABER <= '"+Dtos(Ate_Data)+"' "
	Endif

Else

	// Query
	If lMV_HIST
		cQuerySTJ := "SELECT * "
	Else
		cQuerySTJ := "SELECT COUNT(*) AS STJCOUNT "
	EndIf
	cQuerySTJ += " FROM "+RetSqlName("STJ")+" STJ "
	cQuerySTJ += " JOIN " +RetSqlName("TQB")+ " TQB ON STJ.TJ_SOLICI = TQB.TQB_SOLICI "
	cQuerySTJ += " WHERE STJ.TJ_FILIAL = '"+xFilial("STJ")+"' AND STJ.D_E_L_E_T_ <> '*' "

	If ValType(De_AreaL) == "C" .and. ValType(Ate_Area) == "C"
		cQuerySTJ += " AND STJ.TJ_CODAREA >= '"+De_AreaL+"' AND STJ.TJ_CODAREA <= '"+Ate_Area+"' "
	Endif
	If ValType(De_ServicL) == "C" .and. ValType(Ate_Servico) == "C"
		cQuerySTJ += " AND STJ.TJ_SERVICO >= '"+De_ServicL+"' AND STJ.TJ_SERVICO <= '"+Ate_Servico+"' "
	Endif

	cQuerySTJ += " AND TQB.TQB_FILIAL = '"+xFilial("TQB")+"' AND TQB.D_E_L_E_T_ <> '*' "
	If ValType(De_BemL) == "C" .and. ValType(Ate_Bem) == "C"
		cQuerySTJ += " AND TQB.TQB_CODBEM >= '"+De_BemL+"' AND TQB.TQB_CODBEM <= '"+Ate_Bem+"' "
	Endif

	If ValType(De_LocaliL) == "C" .and. ValType(Ate_Locali) == "C"
		cQuerySTJ += " AND TQB.TQB_LOCALI >= '"+De_LocaliL+"' AND TQB.TQB_LOCALI <= '"+Ate_Locali+"' "
	Endif

	If ValType(De_CcustoL) == "C" .and. ValType(Ate_Ccusto) == "C"
		cQuerySTJ += " AND TQB.TQB_CCUSTO >= '"+De_CcustoL+"' AND TQB.TQB_CCUSTO <= '"+Ate_Ccusto+"' "
	Endif

	If ValType(De_CenTraL) == "C" .and. ValType(Ate_CenTra) == "C"
		cQuerySTJ += " AND TQB.TQB_CENTRA >= '"+De_CenTraL+"' AND TQB.TQB_CENTRA <= '"+Ate_CenTra+"' "
	Endif

	If ValType(De_Data) == "D"
		cQuerySTJ += " AND TQB.TQB_DTABER >= '"+Dtos(De_Data)+"' "
	Endif

	If ValType(Ate_Data) == "D"
		cQuerySTJ += " AND TQB.TQB_DTABER <= '"+Dtos(Ate_Data)+"' "
	Endif
EndIf

cQuerySTJ := ChangeQuery(cQuerySTJ)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuerySTJ),cAliasSTJ, .F., .T.)
NGI6PREPDA(cAliasSTJ, cCodIndic)
dbSelectArea(cAliasSTJ)
dbGoTop()
If lMV_HIST
	While !Eof()
		nQtdSolici++
		dbSkip()
	End
Else
	If !Eof()
		nQtdSolici += (cAliasSTJ)->STJCOUNT
	Endif
EndIf
(cAliasSTJ)->(dbCloseArea())

// RESULTADO
nResult := nQtdSolici
NGI6PREPVA(cCodIndic, nResult)

RestArea(aAreaOLD)

Return nResult