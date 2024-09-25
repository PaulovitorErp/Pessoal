#include "Protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SGAV003  ³ Autor ³ Felipe N. Welter      ³ Data ³01/10/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Indicador de Quantidade Faturada de Residuos                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tabelas   ³TAX - Definicao de Residuos                                 ³±±
±±³          ³SD2 - Itens de Venda da NF                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tabelas   ³dDataDe - Data Inicio para Emissao da Nota (SD2)            ³±±
±±³          ³dDataAte - Data Fim para Emissao da Nota                    ³±±
±±³          ³cGrupoDe - Grupo Inicio de Residuos (SB1)                   ³±±
±±³          ³cGrupoAte - Grupo Fim de Residuos                           ³±±
±±³          ³cLocalDe -  Local (Armazem) de Inicio (SD2)                 ³±±
±±³          ³cLocalAte - Local (Armazem) de Fim                          ³±±
±±³          ³cGerDe - Fonte Geradora Inicial (TAX)                       ³±±
±±³          ³cGerAte - Fonte Geradora Final                              ³±±
±±³          ³cResDe - Codigo do Residuo Inicio (TAX)                     ³±±
±±³          ³cResAte - Codigo do Residuo Fim                             ³±±
±±³          ³cCliDe - Codigo Cliente Inicio (SD2)                        ³±±
±±³          ³cCliAte - Codigo Cliente Fim                                ³±±
±±³          ³cGeracaoe - Tipo de Geracao Reciclavel/Nao-Reciclavel/Ambos ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaSGA                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ F.O  ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SGAV003(dDataDe,dDataAte,cGrupoDe,cGrupoAte,cLocalDe,cLocalAte,cGerDe,cGerAte,cResDe,cResAte,cCliDe,cCliAte,cGeracao)

Local nRet := 0
Local cAliasQry, cQuery

Local _cGetDB := TcGetDb()

cAliasQry := GetNextAlias()

cQuery := "SELECT ISNULL(SUM(SD2.D2_QUANT*TB0.TB0_FATOR),0) RESULT FROM "+ RetSQLName("TAX") +" TAX INNER JOIN "+ RetSQLName("SB1")+" "
cQuery += "SB1 ON TAX.TAX_CODRES = SB1.B1_COD "
cQuery += "JOIN "+ RetSQLName("SD2") +" SD2 ON SB1.B1_COD = SD2.D2_COD "

cQuery += "JOIN "+ RetSQLName("TAV") +" TAV ON (TAV.TAV_FILIAL = '"+ xFilial("TAV") +"' AND TAV.TAV_CODNIV = (SELECT MAX(TAV2.TAV_CODNIV) FROM "+RetSqlName("TAV")+" TAV2 "
cQuery += "WHERE TAV2.TAV_FILIAL = '"+ xFilial("TAV") +"' AND TAV2.TAV_CODRES = SD2.D2_COD "
If cLocalDe <> Nil .And. cLocalAte <> Nil
	cQuery += "AND TAV2.TAV_CODNIV BETWEEN '"+cLocalDe+"' AND '"+cLocalAte+"' "
EndIf
cQuery += "AND TAV2.D_E_L_E_T_ = ' ') AND TAV.TAV_CODRES = SD2.D2_COD AND TAV.D_E_L_E_T_ = ' ') "

cQuery += "JOIN "+ RetSQLName("TB0") +" TB0 ON "

If Upper(_cGetDB) == "ORACLE"
	cQuery += "(TB0.TB0_DATA||TB0.TB0_HORA) = (SELECT MAX(TB0_DATA||TB0_HORA) FROM "+RetSqlName("TB0")+" WHERE TB0_CODRES = TAX.TAX_CODRES)"
Else
	cQuery += "(TB0.TB0_DATA||TB0.TB0_HORA) = (SELECT MAX(TB0_DATA||TB0_HORA) FROM "+RetSqlName("TB0")+" WHERE TB0_CODRES = TAX.TAX_CODRES)"
EndIf

cQuery += "WHERE TAX.TAX_FILIAL = '"+ xFilial("TAX") +"' "
cQuery += "AND SD2.D2_FILIAL = '"+ xFilial("SD2") +"' "
cQuery += "AND SB1.B1_FILIAL = '"+ xFilial("SB1") +"' "
cQuery += "AND TB0.TB0_FILIAL = '"+ xFilial("TB0") +"' "
cQuery += " AND TAX.D_E_L_E_T_ = ' ' AND SB1.D_E_L_E_T_ = ' ' AND SD2.D_E_L_E_T_ = ' ' AND TB0.D_E_L_E_T_ = ' ' AND TAV.D_E_L_E_T_ = ' ' "

If cGeracao <> Nil
	If cGeracao $ '12'
		cQuery += "AND TAX.TAX_TPGERA = '"+cGeracao+"'"
	EndIf
EndIf

If dDataDe <> Nil .And. dDataAte <> Nil
	cQuery += "AND SD2.D2_EMISSAO BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' "
EndIf

If cGrupoDe <> Nil .And. cGrupoAte <> Nil
	cQuery += "AND SB1.B1_GRUPO BETWEEN '" + cGrupoDe + "' AND '" + cGrupoAte + "' "
Endif

If cGerDe <> Nil .And. cGerAte <> Nil
	cQuery += " AND TAX.TAX_CODFON BETWEEN '" + cGerDe + "' AND '" + cGerAte + "' "
EndIf

If cResDe <> Nil .And. cResAte <> Nil
	cQuery += " AND TAX.TAX_CODRES BETWEEN '"+cResDe+"' AND '"+cResAte+"' "
EndIf

If cCliDe <> Nil .And. cCliAte <> Nil
	cQuery += "AND SD2.D2_CLIENTE BETWEEN '"+cCliDe+"' AND '"+cCliAte+"' "
EndIf

cQuery := ChangeQuery(cQuery)
MPSysOpenQuery( cQuery , cAliasQry )

dbSelectArea(cAliasQry)
nRet := (cAliasQry)->RESULT

Return nRet