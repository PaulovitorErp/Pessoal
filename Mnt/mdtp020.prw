#INCLUDE "MDTP020.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MDTP020   ³ Autor ³ Ricardo Dal Ponte     ³ Data ³ 26/03/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta array para Painel de Gestao Tipo 5:                     ³±±
±±³          ³Acidentes por Parte Atingida                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MDTP020()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAMDI                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDTP020()
Local aRetPanel  := {}
Local aCabec     := {STR0001,STR0002,STR0003} //"Parte Atingida"###"Descrição"###"Quantidade"
Local aAlign     := {"LEFT","LEFT","RIGHT"}
Private aValores := {}
Private cAliasQry  := GetNextAlias()

Pergunte("MDTP020",.F.)

cQuery := " SELECT TNC.TNC_FILIAL, TNC.TNC_CODPAR, TOI.TOI_DESPAR, COUNT(*) AS QTDE "
cQuery += " FROM "+RetSqlName("TNC")+" TNC "
cQuery += "   LEFT JOIN "+RetSqlName("TOI")+" TOI ON TOI.TOI_FILIAL = '"+xFilial("TOI")+"' "
cQuery += "   AND TOI.TOI_CODPAR = TNC.TNC_CODPAR "
cQuery += "   AND TOI.D_E_L_E_T_ <> '*' "
cQuery += "   WHERE TNC.TNC_FILIAL = '"+xFilial("TNC")+"' "
cQuery += "   AND  (TNC.TNC_DTACID  >= '"+AllTrim(DTOS(MV_PAR01))+"'"
cQuery += "   AND   TNC.TNC_DTACID  <= '"+AllTrim(DTOS(MV_PAR02))+"')"
cQuery += "   AND   TNC.TNC_CODPAR  <> ''"
cQuery += "   AND TNC.D_E_L_E_T_ <> '*' "
cQuery += "   GROUP BY TNC.TNC_FILIAL, TNC.TNC_CODPAR, TOI.TOI_DESPAR"
cQuery += "   ORDER BY QTDE DESC, TOI.TOI_DESPAR"

cQuery := ChangeQuery(cQuery)
MPSysOpenQuery( cQuery , cAliasQry )

dbSelectArea(cAliasQry)
dbGoTop()

While !Eof()
   Aadd(aValores,{TNC_CODPAR,TOI_DESPAR,QTDE})

   dbSelectArea(cAliasQry)
   dbSkip()
End

dbSelectArea(cAliasQry)
dbCloseArea()

If Len(aValores) = 0
   Aadd(aValores,{"","",0})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche array do Painel de Gestao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRetPanel := {/*cClick*/, aCabec, aValores, aAlign}

Return aRetPanel