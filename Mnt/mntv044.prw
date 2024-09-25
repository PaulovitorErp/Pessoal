#INCLUDE "PROTHEUS.CH"
//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTV044
Responsável por realizar o calculo da variável HTMN - Número de horas de
intervenção pelo pessoal de manutenção (manutenção preventiva por tempo
ou por estado, manutenção corretiva e outros serviços - HTMN) para cada
item observado

@param De_Data    , Date     , Data início
@param Ate_Data    , Date     , Ate data
@param De_Bem     , Caracter , De bem início
@param [Ate_Bem]   , Caracter , Ate bem fim
@param De_Ccusto  , Caracter , De centro de custo
@param [Ate_Ccusto], Caracter , Ate centro de custo
@param De_Centra   , Caracter , De centro de trabalho
@param [Ate_Centra] , Caracter , Ate centro de trabalho
@param Con_SobOS   , Caracter , Determina se considera sobreposição de OS
@param Con_Parada  , Caracter , Determina se apenas será considerado OS com parada

@author Guilherme Freudenburg
@since 23/07/2018
@version P12
@return nResult, Numérico, Total de horas improdutivas.
/*/
//------------------------------------------------------------------------------
Function MNTV044(De_Data,Ate_Data,De_Bem,Ate_Bem,De_Ccusto,Ate_Ccusto,;
                 De_Centra,Ate_Centra,Con_SobOS,Con_Parada)

	Local aAreaOld := GetArea() // Salva área posicionada.
	Local nResult  := 0 // Variável que retorná o resultado.
	Local cAliaSTJ := GetNextAlias() // Busca próximo alias.
	Local cQuery   := "" // Variável que seja armazeada a query.
	Local cCodBem  := "" // Código do bem utilizado na comparação de sobreposição.
	Local cHora    := "" // Hora Fim utilizada na sobreposição.
	Local dData    := CToD("") // Data Fim utilizada na sobreposição de OS.

	Default De_Bem    := ""  // De bem início
	Default De_Ccusto := ""  // De centro de custo
	Default De_Centra  := ""  // De centro de trabalho
	Default Con_SobOS  := "2" // Considera sobreposição de OS
	Default Con_Parada := "2" // Considera apenas OS com parada

	cQuery := "SELECT TJ_CODBEM,TJ_DTPRINI,TJ_HOPRINI, "
	cQuery += "TJ_DTPRFIM,TJ_HOPRFIM,TJ_DTMRINI,TJ_HOMRINI,TJ_DTMRFIM,TJ_HOMRFIM,T9_CALENDA, "
    cQuery += " CASE"
	cQuery += "    WHEN RTrim(STJ.TJ_DTPRINI) <> '' THEN STJ.TJ_DTPRINI"
	cQuery += "    ELSE STJ.TJ_DTMRINI"
    cQuery += " END AS IS_DATAINI,"
	cQuery += " CASE"
	cQuery += "    WHEN RTrim(REPLACE(STJ.TJ_HOPRINI, ':', '')) <> '' THEN STJ.TJ_HOPRINI"
    cQuery += "    ELSE STJ.TJ_HOMRINI"
	cQuery += " END AS IS_HORAINI,"
	cQuery += " CASE"
	cQuery += "    WHEN RTrim(STJ.TJ_DTPRFIM) <> '' THEN STJ.TJ_DTPRFIM"
	cQuery += "    ELSE STJ.TJ_DTMRFIM"
	cQuery += " END AS IS_DATAFIM,"
    cQuery += " CASE"
	cQuery += "    WHEN RTrim(REPLACE(STJ.TJ_HOPRFIM, ':', '')) <> '' THEN STJ.TJ_HOPRFIM"
    cQuery += "    ELSE STJ.TJ_HOMRFIM"
    cQuery += " END AS IS_HORAFIM "
	cQuery += "FROM "+RetSqlName("STJ")+" STJ, "+RetSqlName("ST9")+" ST9 "
	cQuery += "WHERE STJ.TJ_FILIAL='"+xFilial("STJ")+"'"
	cQuery += "  AND STJ.TJ_CODBEM >= '"+De_Bem+"'"
	cQuery += " AND STJ.TJ_CODBEM <= '"+Ate_Bem+"'"
	cQuery += " AND STJ.TJ_CCUSTO >= '"+De_Ccusto+"'"
	cQuery += " AND STJ.TJ_CCUSTO <= '"+Ate_Ccusto+"'"
	cQuery += " AND STJ.TJ_CENTRAB >= '"+De_Centra+"'"
	cQuery += " AND STJ.TJ_CENTRAB <= '"+Ate_Centra+"'"
	cQuery += " AND STJ.TJ_TIPOOS = 'B'"
	cQuery += " AND STJ.TJ_TERMINO = 'S' AND STJ.TJ_SITUACA = 'L'"
   	cQuery += " AND ( STJ.TJ_DTPRINI >= '"+Dtos(De_Data)+"' OR STJ.TJ_DTMRINI >= '"+Dtos(De_Data)+"' )"
	cQuery += " AND ( STJ.TJ_DTPRFIM <= '"+Dtos(Ate_Data)+"' OR STJ.TJ_DTMRFIM <= '"+Dtos(Ate_Data)+"' )"
	If Con_Parada == '1' // Considera somente O.S. com parada.
		cQuery += " AND STJ.TJ_DTPRINI <> '' AND STJ.TJ_HOPRINI <> '' AND STJ.TJ_DTPRFIM <> '' AND STJ.TJ_HOPRFIM <> ''"
	EndIf
	cQuery += " AND STJ.TJ_FILIAL = ST9.T9_FILIAL"
	cQuery += " AND STJ.TJ_CODBEM = ST9.T9_CODBEM"
	cQuery += " AND STJ.D_E_L_E_T_ <> '*'"
	cQuery += " AND ST9.D_E_L_E_T_ <> '*'"
	cQuery += " UNION ALL "
	cQuery += "SELECT TS_CODBEM, TS_DTPRINI, TS_HOPRINI,"
	cQuery += " TS_DTPRFIM, TS_HOPRFIM, TS_DTMRINI, TS_HOMRINI, TS_DTMRFIM, TS_HOMRFIM, T9_CALENDA, "
    cQuery += " CASE"
	cQuery += "    WHEN RTrim(STS.TS_DTPRINI) <> '' THEN STS.TS_DTPRINI"
	cQuery += "    ELSE STS.TS_DTMRINI"
    cQuery += " END AS IS_DATAINI,"
	cQuery += " CASE"
	cQuery += "    WHEN RTrim(REPLACE(STS.TS_HOPRINI, ':', '')) <> '' THEN STS.TS_HOPRINI"
    cQuery += "    ELSE STS.TS_HOMRINI"
	cQuery += " END AS IS_HORAINI,"
	cQuery += " CASE"
	cQuery += "    WHEN RTrim(STS.TS_DTPRFIM) <> '' THEN STS.TS_DTPRFIM"
	cQuery += "    ELSE STS.TS_DTMRFIM"
	cQuery += " END AS IS_DATAFIM,"
    cQuery += " CASE"
	cQuery += "    WHEN RTrim(REPLACE(STS.TS_HOPRFIM, ':', '')) <> '' THEN STS.TS_HOPRFIM"
    cQuery += "    ELSE STS.TS_HOMRFIM"
    cQuery += " END AS IS_HORAFIM "
	cQuery += "FROM "+RetSqlName("STS")+" STS, "+RetSqlName("ST9")+" ST9 "
	cQuery += "WHERE STS.TS_FILIAL='"+xFilial("STS")+"'"
	cQuery += "  AND STS.TS_CODBEM >= '"+De_Bem+"'"
	cQuery += " AND STS.TS_CODBEM <= '"+Ate_Bem+"'"
	cQuery += " AND STS.TS_CCUSTO >= '"+De_Ccusto+"'"
	cQuery += " AND STS.TS_CCUSTO <= '"+Ate_Ccusto+"'"
	cQuery += " AND STS.TS_CENTRAB >= '"+De_Centra+"'"
	cQuery += " AND STS.TS_CENTRAB <= '"+Ate_Centra+"'"
	cQuery += " AND STS.TS_TIPOOS = 'B'"
	cQuery += " AND STS.TS_TERMINO = 'S' AND TS_SITUACA = 'L'"
	cQuery += " AND ( STS.TS_DTPRINI >= '"+Dtos(De_Data)+"' OR STS.TS_DTMRINI >= '"+Dtos(De_Data)+"' )"
	cQuery += " AND ( STS.TS_DTPRFIM <= '"+Dtos(Ate_Data)+"' OR STS.TS_DTMRFIM <= '"+Dtos(Ate_Data)+"' )"
	If Con_Parada == '1' // Considera somente O.S. com parada.
		cQuery += " AND STS.TS_DTPRINI <> '' AND STS.TS_HOPRINI <> '' AND STS.TS_DTPRFIM <> '' AND STS.TS_HOPRFIM <> ''"
	EndIf
	cQuery += " AND STS.TS_FILIAL = ST9.T9_FILIAL"
	cQuery += " AND STS.TS_CODBEM = ST9.T9_CODBEM"
	cQuery += " AND STS.D_E_L_E_T_ <> '*'"
	cQuery += " AND ST9.D_E_L_E_T_ <> '*'"
	cQuery += "ORDER BY TJ_CODBEM, TJ_DTMRINI, TJ_HOMRINI, TJ_DTMRFIM, TJ_HOMRFIM"
	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery( cQuery , cAliaSTJ )

	dbSelectArea(cAliaSTJ)
	dbGoTop()
	While (cAliaSTJ)->(!Eof())
		If Con_SobOS == "1" // Caso considere sobreposição de OS.
			If cCodBem <> (cAliaSTJ)->TJ_CODBEM // Caso seja um bem diferente.
				nResult += NGCONVERHORA(NGCALENHORA(SToD((cAliaSTJ)->IS_DATAINI),(cAliaSTJ)->IS_HORAINI,;
							   SToD((cAliaSTJ)->IS_DATAFIM),(cAliaSTJ)->IS_HORAFIM,(cAliaSTJ)->T9_CALENDA),"S","D")
			Else // Caso seja o mesmo bem.
				If (cAliaSTJ)->IS_DATAINI + (cAliaSTJ)->IS_HORAINI <= DToS(dData) + cHora .And.;
					(cAliaSTJ)->IS_DATAFIM + (cAliaSTJ)->IS_HORAFIM >= DToS(dData) + cHora
					nResult += NGCONVERHORA(NGCALENHORA(dData,cHora,;
							   SToD((cAliaSTJ)->IS_DATAFIM),(cAliaSTJ)->IS_HORAFIM,(cAliaSTJ)->T9_CALENDA),"S","D")
				Else
					nResult += NGCONVERHORA(NGCALENHORA(SToD((cAliaSTJ)->IS_DATAINI),(cAliaSTJ)->IS_HORAINI,;
							   SToD((cAliaSTJ)->IS_DATAFIM),(cAliaSTJ)->IS_HORAFIM,(cAliaSTJ)->T9_CALENDA),"S","D")
				EndIf
			EndIf
			cCodBem := (cAliaSTJ)->TJ_CODBEM
			cHora   := (cAliaSTJ)->IS_HORAFIM
			dData   := SToD((cAliaSTJ)->IS_DATAFIM)
		Else
			nResult += NGCONVERHORA(NGCALENHORA(SToD((cAliaSTJ)->IS_DATAINI),(cAliaSTJ)->IS_HORAINI,;
							   SToD((cAliaSTJ)->IS_DATAFIM),(cAliaSTJ)->IS_HORAFIM,(cAliaSTJ)->T9_CALENDA),"S","D")
		EndIf
		(cAliaSTJ)->(dbSkip())
	EndDo
	(cAliaSTJ)->(dbCloseArea())

	RestArea(aAreaOld)

Return nResult
