#INCLUDE "MDTP040.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MDTP040   ³ Autor ³ Ricardo Dal Ponte     ³ Data ³ 29/03/4007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta array para Painel de Gestao Tipo 3:                     ³±±
±±³          ³Indice de Anormalidade no Resultado dos Exames                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MDTP040()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAMDI                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDTP040()
Local aRetPanel  := {}
Private cAliasQry  := ""

Pergunte("MDTP040",.F.)

//BUSCA TOTAIS
cAliasQry  := GetNextAlias()
cQuery := " SELECT TM5.TM5_FILIAL, TM5.TM5_INDRES, COUNT(*) AS QTDE "
cQuery += " FROM "+RetSqlName("TM5")+" TM5 "
cQuery += "   WHERE TM5.TM5_FILIAL = '"+xFilial("TM5")+"' "
cQuery += "   AND  (TM5.TM5_DTRESU  >= '"+AllTrim(DTOS(MV_PAR01))+"'"
cQuery += "   AND   TM5.TM5_DTRESU  <= '"+AllTrim(DTOS(MV_PAR02))+"')"
cQuery += "   AND   TM5.TM5_INDRES  <> ''"
cQuery += "   AND TM5.D_E_L_E_T_ <> '*' "
cQuery += "   GROUP BY TM5.TM5_FILIAL, TM5.TM5_INDRES"

cQuery := ChangeQuery(cQuery)
MPSysOpenQuery( cQuery , cAliasQry )

dbSelectArea(cAliasQry)
dbGoTop()

nQTDETOT := 0
nQTDEANO := 0
While !Eof()

   If TM5_INDRES = "1" .Or. TM5_INDRES = "2"
      nQTDETOT += QTDE
   EndIf

   If TM5_INDRES = "2"
      nQTDEANO := QTDE
   EndIf

   dbSelectArea(cAliasQry)
   dbSkip()
End

dbSelectArea(cAliasQry)
dbCloseArea()

If nQTDEANO <> 0 .Or. nQTDETOT <> 0
   nPERCEN := Round(((nQTDEANO /nQTDETOT) *100),0)
Else
   nPERCEN := 0
EndIf

aRetPanel := {STR0003,Alltrim(Str(nPERCEN)),"%",CLR_BLUE,Nil,0,100,nPERCEN}  //"Anormalidade"

Return aRetPanel