#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MNTV037    ³ Autor ³ Jackson Machado         ³ Data ³24/10/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Quantidade rodada em relacao aos parametros (PNEUS)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ De_Data    - Data inicio                                     ³±±
±±³          ³ Ate_Data   - Ate data                                        ³±±
±±³          ³ De_Ccusto  - De centro de custo                              ³±±
±±³          ³ Ate_Ccusto - Ate centro de custo                             ³±±
±±³          ³ De_CenTra  - De centro de trabalho                           ³±±
±±³          ³ Ate_CenTra - Ate sentro de trabalho                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³ nQtdRod  - Quantidade Rodada (PNEUS)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNTV037(De_Data,Ate_Data,De_Ccusto,Ate_Ccusto,De_CenTra,Ate_CenTra,De_Familia,Ate_Familia)
Local aAreaOLD   := GetArea(), nQtdRod := 0
Local De_CcustoL := If(De_Ccusto  = Nil,Space(NGSEEKDIC("SX3","TQN_CCUSTO",2,"X3_TAMANHO")),De_Ccusto)
Local De_CenTraL := If(De_CenTra  = Nil,Space(NGSEEKDIC("SX3","TQN_CENTRA",2,"X3_TAMANHO")),De_CenTra) 
Local De_FamiliaL:= If(De_Familia = Nil,Space(NGSEEKDIC("SX3","T9_CODFAMI",2,"X3_TAMANHO")),De_Familia) 
Local aAuxSTP := {}, nScan := 0, nX := 0

// Variáveis de Histórico de Indicadores
Local lMV_HIST := NGI6MVHIST()
Local aParams := {}
Local cCodIndic := "MNTV037"
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
	aAdd(aParams, {"DE_FAMILIA" , De_Familia})
	aAdd(aParams, {"ATE_FAMILIA", Ate_Familia})
	NGI6PREPPA(aParams, cCodIndic)
EndIf

If ValType(De_Data) != "D" .or. ValType(Ate_Data) != "D"
	NGI6PREPVA(cCodIndic, nResult)
	Return nResult
Endif

cAliasQry := GetNextAlias()
// Query
If lMV_HIST
	cQuery := " SELECT * "
Else
	cQuery := " SELECT STP.TP_FILIAL, STP.TP_CODBEM, STP.TP_ACUMCON "
EndIf
cQuery += " FROM "+RetSQLName("STP")+" STP "
cQuery += " INNER JOIN "+RetSQLName("ST9")+" ST9 ON "
cQuery += " ( "
cQuery += " ST9.T9_CODBEM = STP.TP_CODBEM "
cQuery += " AND ST9.T9_CATBEM = '3' "
If ValType(De_FamiliaL) == "C"
	cQuery += " AND ST9.T9_CODFAMI >= " + ValToSQL(De_FamiliaL) + " "
EndIf
If ValType(Ate_Familia) == "C"
	cQuery += " AND ST9.T9_CODFAMI <= " + ValToSQL(Ate_Familia) + " "
EndIf
cQuery += "  AND ST9.D_E_L_E_T_ <> '*' "
cQuery += " ) "
cQuery += " WHERE "
cQuery += " STP.TP_FILIAL = " + ValToSQL(xFilial("STP")) + " "
cQuery += " AND STP.TP_DTLEITU BETWEEN " + ValToSQL(De_Data) + " AND " + ValToSQL(Ate_Data) + " "
If ValType(De_CcustoL) == "C"
	cQuery += " AND STP.TP_CCUSTO >= " + ValToSQL(De_CcustoL) + " "
EndIf
If ValType(Ate_Ccusto) == "C"
	cQuery += " AND STP.TP_CCUSTO <= " + ValToSQL(Ate_Ccusto) + " "
EndIf
If ValType(De_CenTraL) == "C"
	cQuery += " AND STP.TP_CENTRAB >= " + ValToSQL(De_CenTraL) + " "
EndIf
If ValType(Ate_CenTra) == "C"
	cQuery += " AND STP.TP_CENTRAB <= " + ValToSQL(Ate_CenTra) + " "
EndIf
cQuery += " AND STP.TP_TEMCONT <> 'N' "
cQuery += " AND STP.TP_TIPOLAN IN ('A','I') "
cQuery += " AND STP.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY STP.TP_FILIAL,STP.TP_CODBEM,STP.TP_DTLEITU,STP.TP_HORA "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
NGI6PREPDA(cAliasQry, cCodIndic)
                                           
dbSelectArea(cAliasQry)
dbGoTop()
While !Eof()
	nScan := aScan(aAuxSTP, {|x| x[1] == (cAliasQry)->TP_CODBEM })
	If nScan == 0
		aAdd(aAuxSTP, {(cAliasQry)->TP_CODBEM, {}})
		nScan := Len(aAuxSTP)
	EndIf
	aAdd(aAuxSTP[nScan][2], (cAliasQry)->TP_ACUMCON)
	dbSkip()
End
(cAliasQry)->(dbCloseArea())
For nX := 1 To Len(aAuxSTP)
	If Len(aAuxSTP[nX][2]) > 1
		nQtdRod += ( aAuxSTP[nX][2][Len(aAuxSTP[nX][2])] - aAuxSTP[nX][2][Len(aAuxSTP[nX][2])-1] )
	EndIf
Next nX

// RESULTADO
nResult := nQtdRod
NGI6PREPVA(cCodIndic, nResult)

RestArea(aAreaOLD)
Return nResult