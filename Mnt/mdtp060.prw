#INCLUDE "MDTP060.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MDTP060   ³ Autor ³ Ricardo Dal Ponte     ³ Data ³ 29/03/6007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta array para Painel de Gestao Tipo 1:                     ³±±
±±³          ³ASOS Emitidos (Aptos e Inaptos)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MDTP060()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAMDI                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDTP060()
Local aRetPanel  := {}
Private aValores := {}
Private cAliasQry  := ""

Pergunte("MDTP060",.F.)

//APTOS
cAliasQry  := GetNextAlias()
cQuery := " SELECT COUNT(*) AS QTDE"
cQuery += " FROM "+RetSqlName("TMY")+" TMY "
cQuery += "   WHERE TMY.TMY_FILIAL = '"+xFilial("TMY")+"' "
cQuery += "   AND  (TMY.TMY_DTEMIS  >= '"+AllTrim(DTOS(MV_PAR01))+"'"
cQuery += "   AND   TMY.TMY_DTEMIS  <= '"+AllTrim(DTOS(MV_PAR02))+"')"
cQuery += "   AND   TMY.TMY_INDPAR  = '1' OR TMY.TMY_INDPAR  = '3'"
cQuery += "   AND TMY.D_E_L_E_T_ <> '*' "

cQuery := ChangeQuery(cQuery)
MPSysOpenQuery( cQuery , cAliasQry )

dbSelectArea(cAliasQry)
dbGoTop()

nAPTOS:=0
If !Eof()
   nAPTOS := QTDE
EndIf
Aadd(aRetPanel,{STR0003, Transform(nAPTOS,"@E 999,999"),CLR_RED,{}} ) //"Aptos"

dbSelectArea(cAliasQry)
dbCloseArea()

//INAPTOS
cAliasQry  := GetNextAlias()
cQuery := " SELECT COUNT(*) AS QTDE"
cQuery += " FROM "+RetSqlName("TMY")+" TMY "
cQuery += "   WHERE TMY.TMY_FILIAL = '"+xFilial("TMY")+"' "
cQuery += "   AND  (TMY.TMY_DTEMIS  >= '"+AllTrim(DTOS(MV_PAR01))+"'"
cQuery += "   AND   TMY.TMY_DTEMIS  <= '"+AllTrim(DTOS(MV_PAR02))+"')"
cQuery += "   AND   TMY.TMY_INDPAR  = '2'"
cQuery += "   AND TMY.D_E_L_E_T_ <> '*' "

cQuery := ChangeQuery(cQuery)
MPSysOpenQuery( cQuery , cAliasQry )

dbSelectArea(cAliasQry)
dbGoTop()

nINAPTOS:=0
If !Eof()
   nINAPTOS := QTDE
EndIf
Aadd(aRetPanel,{STR0004, Transform(nINAPTOS,"@E 999,999"),CLR_RED,{}} ) //"Inaptos"

dbSelectArea(cAliasQry)
dbCloseArea()

Return aRetPanel