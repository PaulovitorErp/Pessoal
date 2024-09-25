
//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTV034
Retorna a qtde de solicitacoes realizadas ou abertas.

@author Marcos Wagner Junior
@since 19/01/2011
@version P12

@param De_Data      , Date     , Data início.
@param Ate_Data     , Date     , Até data.
@param De_Bem       , Caracter , De bem início.
@param [Ate_Bem]    , Caracter , Até bem fim.
@param De_Locali    , Caracter , De Localização.
@param Ate_Locali   , Caracter , Até Localização.
@param De_Ccusto    , Caracter , De centro de custo.
@param [Ate_Ccusto] , Caracter , Até centro de custo.
@param De_CenTra    , Caracter , De centro de trabalho.
@param [Ate_CenTra] , Caracter , Até centro de trabalho.
@param De_Solici    , Caracter , De Solicitante.
@param Ate_Solici   , Caracter , Até Solicitante.
@param Sit_Solici   , Caracter , Situação da Solicitação.

@return nResult, Numérico, Custo das horas de manutencao preventivas
/*/
//------------------------------------------------------------------------------
Function MNTV034(De_Data,Ate_Data,De_Bem,Ate_Bem,De_Locali,Ate_Locali,De_Ccusto,Ate_Ccusto,De_CenTra,Ate_CenTra,De_Solici,Ate_Solici,Sit_Solici)

Local aAreaOLD   := GetArea(), nRetQtde := 0, cTQBSOLICI := ''
Local De_BemL    := If(De_Bem    = Nil,Space(NGSEEKDIC("SX3","TQB_CODBEM",2,"X3_TAMANHO")),De_Bem)
Local De_LocaliL := If(De_Locali = Nil,Space(NGSEEKDIC("SX3","TQB_LOCALI",2,"X3_TAMANHO")),De_Locali)
Local De_CcustoL := If(De_Ccusto = Nil,Space(NGSEEKDIC("SX3","TQB_CCUSTO",2,"X3_TAMANHO")),De_Ccusto)
Local De_CenTraL := If(De_CenTra = Nil,Space(NGSEEKDIC("SX3","TQB_CENTRA",2,"X3_TAMANHO")),De_CenTra)
Local De_SoliciL := If(De_Solici = Nil,Space(NGSEEKDIC("SX3","QAA_LOGIN" ,2,"X3_TAMANHO")),De_Solici)
Local aAuxOS := {}

// Variáveis de Histórico de Indicadores
Local lMV_HIST := NGI6MVHIST()
Local aParams := {}
Local cCodIndic := "MNTV034"
Local nResult := 0

// Armazena os Parâmetros
If lMV_HIST
	aParams := {}
	aAdd(aParams, {"DE_DATA"   , De_Data})
	aAdd(aParams, {"ATE_DATA"  , Ate_Data})
	aAdd(aParams, {"DE_BEM"    , De_Bem})
	aAdd(aParams, {"ATE_BEM"   , Ate_Bem})
	aAdd(aParams, {"DE_LOCALI" , De_Locali})
	aAdd(aParams, {"ATE_LOCALI", Ate_Locali})
	aAdd(aParams, {"DE_CCUSTO" , De_Ccusto})
	aAdd(aParams, {"ATE_CCUSTO", Ate_Ccusto})
	aAdd(aParams, {"DE_CENTRA" , De_CenTra})
	aAdd(aParams, {"ATE_CENTRA", Ate_CenTra})
	aAdd(aParams, {"DE_SOLICI" , De_Solici})
	aAdd(aParams, {"ATE_SOLICI", Ate_Solici})
	aAdd(aParams, {"SIT_SOLICI", Sit_Solici})
	NGI6PREPPA(aParams, cCodIndic)
EndIf

cAliasQry := GetNextAlias()
// Query
If lMV_HIST
	cQuery := "SELECT * "
Else
	cQuery := "SELECT TQB.TQB_SOLICI "
EndIf
cQuery += " FROM "+RetSqlName("TQB")+" TQB "
cQuery += " WHERE TQB.TQB_FILIAL = '"+xFilial("TQB")+"' AND TQB.D_E_L_E_T_ <> '*' "
If ValType(De_BemL) == "C" .and. ValType(Ate_Bem) == "C"
	cQuery += " AND TQB.TQB_CODBEM >= '"+De_BemL+"' AND TQB.TQB_CODBEM <= '"+Ate_Bem+"' "
Endif
If ValType(De_LocaliL) == "C" .and. ValType(Ate_Locali) == "C"
	cQuery += " AND TQB.TQB_LOCALI >= '"+De_LocaliL+"' AND TQB.TQB_LOCALI <= '"+Ate_Locali+"' "
Endif
If ValType(De_CcustoL) == "C" .and. ValType(Ate_Ccusto) == "C"
	cQuery += " AND TQB.TQB_CCUSTO >= '"+De_CcustoL+"' AND TQB.TQB_CCUSTO <= '"+Ate_Ccusto+"' "
Endif
If ValType(De_CenTraL) == "C" .and. ValType(Ate_CenTra) == "C"
	cQuery += " AND TQB.TQB_CENTRA >= '"+De_CenTraL+"' AND TQB.TQB_CENTRA <= '"+Ate_CenTra+"' "
Endif
If ValType(De_SoliciL) == "C" .and. ValType(Ate_Solici) == "C"
	cQuery += " AND TQB.TQB_CDSOLI BETWEEN '" +De_SoliciL+ "' AND '" +Ate_Solici+"' "
Endif
If Sit_Solici == '1' .OR. Sit_Solici == '2'
	If Sit_Solici == '1'
		cQuery += " AND TQB.TQB_SOLUCA = 'A' "
	ElseIf Sit_Solici == '2'
		cQuery += " AND TQB.TQB_SOLUCA = 'D' "
	Endif
	If ValType(De_Data) == "D"
		cQuery += " AND TQB.TQB_DTABER >= '"+Dtos(De_Data)+"' "
	Endif
	If ValType(Ate_Data) == "D"
		cQuery += " AND TQB.TQB_DTABER <= '"+Dtos(Ate_Data)+"' "
	Endif
ElseIf Sit_Solici == '3' .OR. Sit_Solici == '4'
	cQuery += " AND TQB.TQB_SOLUCA = 'E' "
	If ValType(De_Data) == "D"
		cQuery += " AND TQB.TQB_DTFECH >= '"+Dtos(De_Data)+"' "
	Endif
	If ValType(Ate_Data) == "D"
		cQuery += " AND TQB.TQB_DTFECH <= '"+Dtos(Ate_Data)+"' "
	Endif
Endif
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
NGI6PREPDA(cAliasQry, cCodIndic)

dbSelectArea(cAliasQry)
dbGoTop()
While !Eof()
  	nRetQtde += 1
	cTQBSOLICI += 	"'"+(cAliasQry)->TQB_SOLICI+"'"
	dbSkip()
	If !Eof()
		cTQBSOLICI += ","
	Endif
End
(cAliasQry)->(dbCloseArea())

If Empty(cTQBSOLICI)
	NGI6PREPVA(cCodIndic, nResult)
	Return nResult
Endif

If Sit_Solici == '3' .OR. Sit_Solici == '4'
	nSSGeraOs := 0
	If AllTrim(GetNewPar("MV_NGMULOS","N")) == "S"
		cAliasTT7 := GetNextAlias()
		// Query
		If lMV_HIST
			cQueryTT7 := "SELECT * "
		Else
			cQueryTT7 := "SELECT COUNT(DISTINCT(TT7.TT7_FILIAL||TT7.TT7_SOLICI)) AS TT7COUNT "
		EndIf
		cQueryTT7 += " FROM "+RetSqlName("TT7")+" TT7 "
		cQueryTT7 += " WHERE TT7.TT7_FILIAL = '"+xFilial("TT7")+"' AND TT7.D_E_L_E_T_ <> '*' "
		cQueryTT7 += " AND   TT7.TT7_SOLICI IN (" + cTQBSOLICI + ")"
		cQueryTT7 := ChangeQuery(cQueryTT7)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryTT7),cAliasTT7, .F., .T.)
		NGI6PREPDA(cAliasTT7, cCodIndic)
		dbSelectArea(cAliasTT7)
		dbGoTop()
		If lMV_HIST
			aAuxBens := {}
			While !Eof()
				If aScan(aAuxOS, {|x| x == (cAliasTT7)->TT7_FILIAL+(cAliasTT7)->TT7_SOLICI }) == 0
					nSSGeraOs++
					aAdd(aAuxOS, (cAliasTT7)->TT7_FILIAL+(cAliasTT7)->TT7_SOLICI)
				EndIf
				dbSkip()
			End
		Else
			If !Eof()
				nSSGeraOs := (cAliasTT7)->TT7COUNT
			Endif
		EndIf
		(cAliasTT7)->(dbCloseArea())
	Else
		cAliasSTJ := GetNextAlias()
		// Query
		If lMV_HIST
			cQuerySTJ := "SELECT * "
		Else
			cQuerySTJ := "SELECT COUNT(DISTINCT(STJ.TJ_SOLICI)) AS STJCOUNT "
		EndIf
		cQuerySTJ += " FROM "+RetSqlName("STJ")+" STJ "
		cQuerySTJ += " WHERE STJ.TJ_FILIAL = '"+xFilial("STJ")+"' AND STJ.D_E_L_E_T_ <> '*' "
		cQuerySTJ += " AND   STJ.TJ_SOLICI IN (" + cTQBSOLICI + ")"
		cQuerySTJ := ChangeQuery(cQuerySTJ)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuerySTJ),cAliasSTJ, .F., .T.)
		NGI6PREPDA(cAliasSTJ, cCodIndic)
		dbSelectArea(cAliasSTJ)
		dbGoTop()
		If lMV_HIST
			aAuxBens := {}
			While !Eof()
				If aScan(aAuxOS, {|x| x == (cAliasSTJ)->TJ_SOLICI }) == 0
					nSSGeraOs++
					aAdd(aAuxOS, (cAliasSTJ)->TJ_SOLICI)
				EndIf
				dbSkip()
			End
		Else
			If !Eof()
				nSSGeraOs := (cAliasSTJ)->STJCOUNT
			Endif
		EndIf
		(cAliasSTJ)->(dbCloseArea())
	Endif

	If Sit_Solici == '3'
		nRetQtde := nSSGeraOs
	ElseIf Sit_Solici == '4'
		nRetQtde -= nSSGeraOs
	endif

Endif

// RESULTADO
nResult := nRetQtde
NGI6PREPVA(cCodIndic, nResult)

RestArea(aAreaOLD)
Return nResult