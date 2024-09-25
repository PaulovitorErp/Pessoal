#INCLUDE "MDTP010.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MDTP010   ³ Autor ³ Ricardo Dal Ponte     ³ Data ³ 26/03/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta array para Painel de Gestao Tipo 5:                     ³±±
±±³          ³Acidentes por Centro de Custo                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MDTP010()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAMDI                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDTP010()
Local aRetPanel  := {}
Local aCabec     := {STR0001,STR0002,STR0003} //"Centro de Custo"###"Descrição"###"Quantidade"
Local aAlign     := {"LEFT","LEFT","RIGHT"}
Private cCTTSI3 := If(CtbInUse(), "CTT", "SI3")
Private aValores := {}
Private cAliasQry  := GetNextAlias()

Pergunte("MDTP010",.F.)

If cCTTSI3 = "CTT"
	cQuery := " SELECT TNC.TNC_FILIAL, TNC.TNC_CC, CTT.CTT_DESC01, COUNT(*) AS QTDE "
	cQuery += " FROM "+RetSqlName("TNC")+" TNC "
	cQuery += "   LEFT JOIN "+RetSqlName("CTT")+" CTT ON CTT.CTT_FILIAL = '"+xFilial("CTT")+"' "
	cQuery += "   AND CTT.CTT_CUSTO = TNC.TNC_CC "
	cQuery += "   AND CTT.D_E_L_E_T_ <> '*' "
	cQuery += "   WHERE TNC.TNC_FILIAL = '"+xFilial("TNC")+"' "
	cQuery += "   AND  (TNC.TNC_DTACID  >= '"+AllTrim(DTOS(MV_PAR01))+"'"
	cQuery += "   AND   TNC.TNC_DTACID  <= '"+AllTrim(DTOS(MV_PAR02))+"')"
	cQuery += "   AND TNC.D_E_L_E_T_ <> '*' "
	cQuery += "   GROUP BY TNC.TNC_FILIAL, TNC.TNC_CC, CTT.CTT_DESC01"
	cQuery += "   ORDER BY QTDE DESC, CTT.CTT_DESC01"
Else
	cQuery := " SELECT TNC.TNC_FILIAL, TNC.TNC_CC, SI3.I3_DESC, COUNT(*) AS QTDE "
	cQuery += " FROM "+RetSqlName("TNC")+" TNC "
	cQuery += "   LEFT JOIN "+RetSqlName("SI3")+" SI3 ON SI3.I3_FILIAL = '"+xFilial("SI3")+"' "
	cQuery += "   AND SI3.I3_CUSTO = TNC.TNC_CC "
	cQuery += "   AND SI3.D_E_L_E_T_ <> '*' "
	cQuery += "   WHERE TNC.TNC_FILIAL = '"+xFilial("TNC")+"' "
	cQuery += "   AND  (TNC.TNC_DTACID  >= '"+AllTrim(DTOS(MV_PAR01))+"'"
	cQuery += "   AND   TNC.TNC_DTACID  <= '"+AllTrim(DTOS(MV_PAR02))+"')"
	cQuery += "   AND TNC.D_E_L_E_T_ <> '*' "
	cQuery += "   GROUP BY TNC.TNC_FILIAL, TNC.TNC_CC, SI3.I3_DESC"
	cQuery += "   ORDER BY QTDE DESC, SI3.I3_DESC"
Endif

cQuery := ChangeQuery(cQuery)
MPSysOpenQuery( cQuery , cAliasQry )

dbSelectArea(cAliasQry)
dbGoTop()

While !Eof()
   If cCTTSI3 = "CTT"
      Aadd(aValores,{TNC_CC,CTT_DESC01,QTDE})
   Else
      Aadd(aValores,{TNC_CC,I3_DESC,QTDE})
   EndIf

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