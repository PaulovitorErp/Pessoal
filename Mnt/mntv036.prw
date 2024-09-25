/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MNTV036    ³ Autor ³ Marcos Wagner Junior  ³ Data ³19/01/2011³±±
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
Function MNTV036(De_Data,Ate_Data,De_Ccusto,Ate_Ccusto,De_CenTra,Ate_CenTra,De_Area,Ate_Area,De_Bem,Ate_Bem,;
                 De_Servico,Ate_Servico,De_Plano,Ate_Plano,De_TpMnt,Ate_TpMnt,Sit_OS,Tip_Ordem,Termino_OS)
Local aAreaOLD    := GetArea(), nQtdOS := 0
Local De_CcustoL  := If(De_Ccusto = Nil,Space(NGSEEKDIC("SX3","TJ_CCUSTO",2,"X3_TAMANHO")),De_Ccusto)
Local De_CenTraL  := If(De_CenTra = Nil,Space(NGSEEKDIC("SX3","TJ_CENTRAB",2,"X3_TAMANHO")),De_CenTra)
Local De_AreaL    := If(De_Area = Nil,Space(NGSEEKDIC("SX3","TJ_CODAREA",2,"X3_TAMANHO")),De_Area)
Local De_BemL     := If(De_Bem = Nil,Space(NGSEEKDIC("SX3","TJ_CODBEM",2,"X3_TAMANHO")),De_Bem)
Local De_ServicL  := If(De_Servico = Nil,Space(NGSEEKDIC("SX3","TJ_SERVICO",2,"X3_TAMANHO")),De_Servico)
Local De_PlanoL   := If(De_Plano = Nil,Space(NGSEEKDIC("SX3","TJ_PLANO",2,"X3_TAMANHO")),De_Plano)
Local De_TpMntL   := If(De_TpMnt = Nil,Space(NGSEEKDIC("SX3","TJ_TIPO",2,"X3_TAMANHO")),De_TpMnt)

// Variáveis de Histórico de Indicadores
Local lMV_HIST := NGI6MVHIST()
Local aParams := {}
Local cCodIndic := "MNTV036"
Local nResult := 0

// Armazena os Parâmetros
If lMV_HIST
	aParams := {}
	aAdd(aParams, {"DE_DATA"    , De_Data})
	aAdd(aParams, {"ATE_DATA"   , Ate_Data})
	aAdd(aParams, {"DE_CCUSTO"  , De_Ccusto})
	aAdd(aParams, {"ATE_CCUSTO" , Ate_Ccusto})
	aAdd(aParams, {"DE_CENTRA"  , De_CenTra})
	aAdd(aParams, {"ATE_CENTRA" , Ate_CenTra})
	aAdd(aParams, {"DE_AREA"    , De_Area})
	aAdd(aParams, {"ATE_AREA"   , Ate_Area})
	aAdd(aParams, {"DE_BEM"     , De_Bem})
	aAdd(aParams, {"ATE_BEM"    , Ate_Bem})
	aAdd(aParams, {"DE_SERVICO" , De_Servico})
	aAdd(aParams, {"ATE_SERVICO", Ate_Servico})
	aAdd(aParams, {"DE_PLANO"   , De_Plano})
	aAdd(aParams, {"ATE_PLANO"  , Ate_Plano})
	aAdd(aParams, {"DE_TPMNT"   , De_TpMnt})
	aAdd(aParams, {"ATE_TPMNT"  , Ate_TpMnt})
	aAdd(aParams, {"SIT_OS"     , Sit_OS})
	aAdd(aParams, {"TIP_ORDEM"  , Tip_Ordem})
	aAdd(aParams, {"TERMINO_OS" , Termino_OS})
	NGI6PREPPA(aParams, cCodIndic)
EndIf

cAliasQry := GetNextAlias()
// Query
If lMV_HIST
	cQuery := "SELECT * "
Else
	cQuery := "SELECT COUNT(*) AS STJCOUNT "
EndIf
cQuery += " FROM "+RetSqlName("STJ")+" STJ "
cQuery += " INNER JOIN "+RetSqlName("ST4")+" ST4 "
cQuery += " ON ST4.T4_SERVICO = STJ.TJ_SERVICO AND ST4.D_E_L_E_T_<> '*' AND ST4.T4_FILIAL='"+xFilial("ST4")+"' "
cQuery += " INNER JOIN "+RetSqlName("STE")+" STE "
cQuery += " ON STE.TE_TIPOMAN = ST4.T4_TIPOMAN AND STE.D_E_L_E_T_<> '*' AND STE.TE_FILIAL='"+xFilial("STE")+"' "
cQuery += "WHERE STJ.TJ_FILIAL='"+xFilial("STJ")+"' AND "
If ValType(De_CcustoL) == "C" .AND. ValType(Ate_Ccusto) == "C"
	cQuery += "STJ.TJ_CCUSTO >= '"+De_CcustoL+"' AND STJ.TJ_CCUSTO <= '"+Ate_Ccusto+"' AND "
Endif
If ValType(De_CenTraL) == "C" .and. ValType(Ate_CenTra) == "C"
	cQuery += "STJ.TJ_CENTRAB >= '"+De_CenTraL+"' AND STJ.TJ_CENTRAB <= '"+Ate_CenTra+"' AND "
Endif
If ValType(De_AreaL) == "C" .and. ValType(Ate_Area) == "C"
	cQuery += "STJ.TJ_CODAREA >= '"+De_AreaL+"' AND STJ.TJ_CODAREA <= '"+Ate_Area+"' AND "
Endif
If ValType(De_BemL) == "C" .and. ValType(Ate_Bem) == "C"
	cQuery += "STJ.TJ_CODBEM >= '"+De_BemL+"' AND STJ.TJ_CODBEM <= '"+Ate_Bem+"' AND "
Endif
If ValType(De_ServicL) == "C" .and. ValType(Ate_Servico) == "C"
	cQuery += "STJ.TJ_SERVICO >= '"+De_ServicL+"' AND STJ.TJ_SERVICO <= '"+Ate_Servico+"' AND "
Endif
If ValType(De_PlanoL) == "C" .and. ValType(Ate_Plano) == "C"
	cQuery += "STJ.TJ_PLANO >= '"+De_PlanoL+"' AND STJ.TJ_PLANO <= '"+Ate_Plano+"' AND "
Endif
If ValType(De_TpMntL) == "C" .and. ValType(Ate_TpMnt) == "C"
	cQuery += "STJ.TJ_TIPO >= '"+De_TpMntL+"' AND STJ.TJ_TIPO <= '"+Ate_TpMnt+"' AND "
Endif
If ValType(Sit_OS) == "C"
	If Sit_OS == '1'
		cQuery += "STJ.TJ_SITUACA = 'P' AND "
	ElseIf Sit_OS == '2'
		cQuery += "STJ.TJ_SITUACA = 'L' AND "
	ElseIf Sit_OS == '3'
		cQuery += "STJ.TJ_SITUACA = 'C' AND "
	Endif
Endif
If ValType(Termino_OS) == "C"
	If Termino_OS == '1'
		cQuery += "STJ.TJ_TERMINO = 'S' AND "
	ElseIf Termino_OS == '2'
		cQuery += "STJ.TJ_TERMINO = 'N' AND "
	Endif
Endif
If ValType(De_Data) == "D"
	cQuery += "STJ.TJ_DTMPINI >= '"+Dtos(De_Data)+"' AND "
Endif
If ValType(Ate_Data) == "D"
	cQuery += "STJ.TJ_DTMPFIM <= '"+Dtos(Ate_Data)+"' AND "
Endif
If ValType(Tip_Ordem) == "C"
	If Tip_Ordem == "1"
		cQuery += "STE.TE_CARACTE = 'C' AND "
		cQuery += "STJ.TJ_ORDEPAI = '' AND "
		cQuery += "STJ.TJ_LUBRIFI <> 'S' AND "
	ElseIf Tip_Ordem == "2"
		cQuery += "STE.TE_CARACTE = 'P' AND "
		cQuery += "STJ.TJ_LUBRIFI <> 'S' AND "
	Endif
Endif
cQuery += "STJ.D_E_L_E_T_<>'*' "  
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
NGI6PREPDA(cAliasQry, cCodIndic)

dbSelectArea(cAliasQry)
dbGoTop()
If lMV_HIST
	While !Eof()
		nQtdOS++
		dbSkip()
	End
Else
	If !Eof()
		nQtdOS := (cAliasQry)->STJCOUNT
	EndIf
EndIf
(cAliasQry)->(dbCloseArea())

// RESULTADO
nResult := nQtdOS
NGI6PREPVA(cCodIndic, nResult)

RestArea(aAreaOLD)
Return nResult