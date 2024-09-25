#INCLUDE "MDTP030.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MDTP030   ³ Autor ³ Ricardo Dal Ponte     ³ Data ³ 29/03/3007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta array para Painel de Gestao Tipo 1:                     ³±±
±±³          ³Dias sem Acidentes                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MDTP030()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAMDI                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDTP030()
Local aRetPanel  := {}
Private aValores := {}
Private cAliasQry  := ""

//DIAS SEM ACIDENTES COM VITIMAS
cAliasQry  := GetNextAlias()
cQuery := " SELECT TNC.TNC_FILIAL, TNC.TNC_ACIDEN, TNC.TNC_DTACID "
cQuery += " FROM "+RetSqlName("TNC")+" TNC "
cQuery += "   WHERE TNC.TNC_FILIAL = '"+xFilial("TNC")+"' "
cQuery += "   AND   TNC.TNC_DTACID  <= '"+AllTrim(DTOS(dDataBase))+"'"
cQuery += "   AND   TNC.TNC_VITIMA  = '1' OR TNC.TNC_VITIMA  = '3'"
cQuery += "   AND TNC.D_E_L_E_T_ <> '*' "
cQuery += "   ORDER BY TNC_DTACID DESC"

cQuery := ChangeQuery(cQuery)
MPSysOpenQuery( cQuery , cAliasQry )

dbSelectArea(cAliasQry)
dbGoTop()

nDias:=0
If !Eof()
   nDias := dDatabase - STOD(TNC_DTACID)
EndIf
Aadd(aRetPanel,{STR0001, Transform(nDias,"@E 999,999"),CLR_RED,{}} ) //"Com Vítima"

dbSelectArea(cAliasQry)
dbCloseArea()


//DIAS SEM ACIDENTES COM AFASTAMENTOS
cAliasQry  := GetNextAlias()
cQuery := " SELECT TNC.TNC_FILIAL, TNC.TNC_ACIDEN, TNC.TNC_DTACID "
cQuery += " FROM "+RetSqlName("TNC")+" TNC "
cQuery += "   WHERE TNC.TNC_FILIAL = '"+xFilial("TNC")+"' "
cQuery += "   AND   TNC.TNC_DTACID  <= '"+AllTrim(DTOS(dDataBase))+"'"
cQuery += "   AND   TNC.TNC_AFASTA  = '1'"
cQuery += "   AND TNC.D_E_L_E_T_ <> '*' "
cQuery += "   ORDER BY TNC_DTACID DESC"

cQuery := ChangeQuery(cQuery)
MPSysOpenQuery( cQuery , cAliasQry )

dbSelectArea(cAliasQry)
dbGoTop()

nDias:=0
If !Eof()
   nDias := dDatabase - STOD(TNC_DTACID)
EndIf
Aadd(aRetPanel,{STR0002, Transform(nDias,"@E 999,999"),CLR_BLUE,{}} ) //"Com Afastamento"

dbSelectArea(cAliasQry)
dbCloseArea()


//DIAS SEM ACIDENTES TODOS
cAliasQry  := GetNextAlias()
cQuery := " SELECT TNC.TNC_FILIAL, TNC.TNC_ACIDEN, TNC.TNC_DTACID "
cQuery += " FROM "+RetSqlName("TNC")+" TNC "
cQuery += "   WHERE TNC.TNC_FILIAL = '"+xFilial("TNC")+"' "
cQuery += "   AND   TNC.TNC_DTACID  <= '"+AllTrim(DTOS(dDataBase))+"'"
cQuery += "   AND TNC.D_E_L_E_T_ <> '*' "
cQuery += "   ORDER BY TNC_DTACID DESC"

cQuery := ChangeQuery(cQuery)
MPSysOpenQuery( cQuery , cAliasQry )

dbSelectArea(cAliasQry)
dbGoTop()

nDias:=0
If !Eof()
   nDias := dDatabase - STOD(TNC_DTACID)
EndIf
Aadd(aRetPanel,{STR0003, Transform(nDias,"@E 999,999"),CLR_BLUE,{}} ) //"Todos"

dbSelectArea(cAliasQry)
dbCloseArea()

Return aRetPanel