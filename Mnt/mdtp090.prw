#INCLUDE "MDTP090.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MDTP090   ³ Autor ³ Ricardo Dal Ponte     ³ Data ³ 29/03/9007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta array para Painel de Gestao Tipo 1:                     ³±±
±±³          ³Despesas com Acidentes de Trabalho                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MDTP090()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAMDI                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDTP090()
Local aRetPanel  := {}
Private aValores := {}
Private cAliasQry  := ""

Pergunte("MDTP090",.F.)

//APTOS
cAliasQry  := GetNextAlias()
cQuery := " SELECT TNL.TNL_TIPDES, SUM(TNM.TNM_VALDES) AS TOTAL "
cQuery += " FROM "+RetSqlName("TNC")+" TNC "
cQuery += "   JOIN "+RetSqlName("TNM")+" TNM ON TNM.TNM_FILIAL = '"+xFilial("TNM")+"' "
cQuery += "   AND TNM.TNM_ACIDEN = TNC.TNC_ACIDEN "
cQuery += "   AND TNM.D_E_L_E_T_ <> '*' "
cQuery += "   JOIN "+RetSqlName("TNL")+" TNL ON TNL.TNL_FILIAL = '"+xFilial("TNL")+"' "
cQuery += "   AND TNL.TNL_CODDES = TNM.TNM_CODDES "
cQuery += "   AND TNL.D_E_L_E_T_ <> '*' "
cQuery += "   WHERE TNC.TNC_FILIAL = '"+xFilial("TNC")+"' "
cQuery += "   AND  (TNC.TNC_DTACID  >= '"+AllTrim(DTOS(MV_PAR01))+"'"
cQuery += "   AND   TNC.TNC_DTACID  <= '"+AllTrim(DTOS(MV_PAR02))+"')"
cQuery += "   AND TNC.D_E_L_E_T_ <> '*' "
cQuery += "   GROUP BY TNL.TNL_TIPDES "

cQuery := ChangeQuery(cQuery)
MPSysOpenQuery( cQuery , cAliasQry )

dbSelectArea(cAliasQry)
dbGoTop()

nTOTAL:=0
nTTMEDI := 0
nTTMATE := 0
nTTPERD := 0
nTTINDE := 0
nTTOUTR := 0

While !Eof()
   If TNL_TIPDES = "1"
      nTTMEDI := TOTAL
   ElseIf TNL_TIPDES = "2"
      nTTMATE := TOTAL
   ElseIf TNL_TIPDES = "3"
      nTTPERD := TOTAL
   ElseIf TNL_TIPDES = "4"
      nTTINDE := TOTAL
   ElseIf TNL_TIPDES = "5"
      nTTOUTR := TOTAL
   EndIf

   nTOTAL += TOTAL

	dbSelectArea(cAliasQry)
	dbSkip()
End

dbSelectArea(cAliasQry)
dbCloseArea()

Aadd(aRetPanel,{STR0003, Transform(nTTMEDI,"@E 999,999.99"),,{}} ) //"Médica"
Aadd(aRetPanel,{STR0004, Transform(nTTMATE,"@E 999,999.99"),,{}} ) //"Material"
Aadd(aRetPanel,{STR0005, Transform(nTTPERD,"@E 999,999.99"),,{}} ) //"Perda Produção"
Aadd(aRetPanel,{STR0006, Transform(nTTINDE,"@E 999,999.99"),,{}} ) //"Indenizações"
Aadd(aRetPanel,{STR0007, Transform(nTTOUTR,"@E 999,999.99"),,{}} ) //"Outros"
Aadd(aRetPanel,{STR0008, Transform(nTOTAL,"@E 999,999.99"),CLR_RED,{}} ) //"Total Geral"
Return aRetPanel