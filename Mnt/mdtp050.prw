#INCLUDE "MDTP050.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MDTP050   ³ Autor ³ Ricardo Dal Ponte     ³ Data ³ 29/03/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta array para Painel de Gestao Tipo 5:                     ³±±
±±³          ³Ocorrencias de Doencas Ocupacionais                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MDTP050()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAMDI                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDTP050()
Local aRetPanel  := {}
Local aCabec     := {STR0001,STR0002,STR0003} //"CID"###"Descrição da Doença"###"Qtde. Ocorrências"
Local aAlign     := {"LEFT","LEFT","RIGHT"}
Private aValores := {}
Private cAliasQry  := ""

Pergunte("MDTP050",.F.)

cAliasQry  := GetNextAlias()
cQuery := " SELECT TNA.TNA_FILIAL, TNA.TNA_CID, TMR.TMR_DOENCA, COUNT(*) AS QTDE "
cQuery += " FROM "+RetSqlName("TNA")+" TNA "
cQuery += "   LEFT JOIN "+RetSqlName("TMR")+" TMR ON TMR.TMR_FILIAL = '"+xFilial("TMR")+"' "
cQuery += "   AND TMR.TMR_CID = TNA.TNA_CID "
cQuery += "   AND TMR.D_E_L_E_T_ <> '*' "
cQuery += "   WHERE TNA.TNA_FILIAL   = '"+xFilial("TNA")+"' "
cQuery += "   AND  (TNA.TNA_DTINIC  >= '"+AllTrim(DTOS(MV_PAR01))+"'"
cQuery += "   AND   TNA.TNA_DTFIM   <= '"+AllTrim(DTOS(MV_PAR02))+"')"
cQuery += "   AND TNA.D_E_L_E_T_ <> '*' "
cQuery += "   GROUP BY TNA.TNA_FILIAL, TNA.TNA_CID, TMR.TMR_DOENCA"
cQuery += "   ORDER BY QTDE DESC, TMR.TMR_DOENCA"

cQuery := ChangeQuery(cQuery)
MPSysOpenQuery( cQuery , cAliasQry )

dbSelectArea(cAliasQry)
dbGoTop()

While !Eof()
   Aadd(aValores,{TNA_CID,TMR_DOENCA,QTDE})

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