#INCLUDE "MDTP070.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MDTP070   ³ Autor ³ Ricardo Dal Ponte     ³ Data ³ 29/03/7007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta array para Painel de Gestao Tipo 1:                     ³±±
±±³          ³Planos de Acoes da CIPA (Abertas/Fechadas)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MDTP070()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAMDI                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDTP070()
Local aRetPanel  := {}
Local lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )
Private aValores := {}
Private cAliasQry  := ""

SG90PLACAO()//Adequação do Plano de Ação

Pergunte("MDTP070",.F.)

//APTOS
cAliasQry  := GetNextAlias()
cQuery := " SELECT " + cAliasPA + "." + aFieldPA[20]
cQuery += " FROM "+RetSqlName("TNN")+" TNN "
cQuery += "   JOIN "+RetSqlName("TNV")+" TNV ON TNV.TNV_FILIAL = '"+xFilial("TNV")+"' "
cQuery += "   AND TNV.TNV_MANDAT = TNN.TNN_MANDAT "
cQuery += "   AND TNV.D_E_L_E_T_ <> '*' "
cQuery += "   JOIN "+RetSqlName( cAliasPA )+ " " + cAliasPA + " ON " + cAliasPA + "." + aFieldPA[1] + " = '" + xFilial( cAliasPA ) + "' "
cQuery += "   AND " + cAliasPA + "." + aFieldPA[2] + " = TNV.TNV_CODPLA "
cQuery += "   AND " + cAliasPA + ".D_E_L_E_T_ <> '*' "
cQuery += "   WHERE TNN.TNN_FILIAL = '"+xFilial("TNN")+"' "
cQuery += "   AND  TNN.TNN_MANDAT  = '"+AllTrim(MV_PAR01)+"'"
cQuery += "   AND TNN.D_E_L_E_T_ <> '*' "

cQuery := ChangeQuery(cQuery)
MPSysOpenQuery( cQuery , cAliasQry )

dbSelectArea(cAliasQry)
dbGoTop()

nTTABER := 0
nTTFECH := 0

While (cAliasQry)->( !Eof() )
	If (cAliasQry)->( &(aFieldPA[20]) ) < 100
		nTTABER += 1
	Else
		nTTFECH += 1
	Endif

	dbSelectArea(cAliasQry)
	dbSkip()
End

dbSelectArea(cAliasQry)
dbCloseArea()

Aadd(aRetPanel,{STR0002, Transform(nTTABER,"@E 999,999"),,{}} ) //"Aberto(s)"
Aadd(aRetPanel,{STR0003, Transform(nTTFECH,"@E 999,999"),,{}} ) //"Fechado(s)"
Return aRetPanel