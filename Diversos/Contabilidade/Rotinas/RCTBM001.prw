#INCLUDE "rwmake.ch"
 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RCTBM001 º Autor ³ Claudio Ferreira   º Data ³  14/03/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Programa que refaz a tabela CTD - Item contabil, percorre aº±±
±±º          ³ tabela de cliente e fornecedor incluindo os mesmos.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS-GO                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function RCTBM001()        
Local cQry := ''

if msgyesno("Confirma o Reprocessamento dos Itens Contabeis?")
  cQry := "DELETE FROM "+RetSqlName("CTD") + " Where CTD_BOOK  = 'AUTO' "
  TCSqlExec(cQry)
  TCSqlExec("commit")
  Processa({|| RunItem() },"Processando item...")
endif  
Return()

Static Function RunItem()
Local nCont:=0 
// Busca os codigos de Clientes e Fornecedores nas tabelas SA1 e SA2
//cQry := "SELECT DISTINCT 'C'||A1_COD AS CODIGO,"
cQry := "SELECT DISTINCT 'C'||A1_COD||A1_LOJA AS CODIGO,"
cQry +=       " A1_NOME NOME,"
cQry +=       " 'SA1' XALIAS,"
cQry +=       " R_E_C_N_O_ XRECNO"
cQry +=  " FROM "+RetSqlName("SA1")
cQry += " WHERE A1_FILIAL  = '"+xFilial("SA1")+"'"
cQry +=   " AND D_E_L_E_T_ = ' '"
cQry +=  "UNION "
//cQry += "SELECT DISTINCT 'F'||A2_COD AS CODIGO,"
cQry += "SELECT DISTINCT 'F'||A2_COD||A2_LOJA AS CODIGO,"
cQry +=       " A2_NOME NOME,"
cQry +=       " 'SA2' XALIAS,"
cQry +=       " R_E_C_N_O_ XRECNO"
cQry +=  " FROM "+RetSqlName("SA2")
cQry += " WHERE A2_FILIAL  = '"+xFilial("SA2")+"'""
cQry +=   " AND D_E_L_E_T_ = ' '"
cQry +=   " AND A2_COD NOT IN ('UNIAO','ESTADO','MUNIC','INPS','99999999')"
cQry += " ORDER BY CODIGO"        
cQry := ChangeQuery(cQry)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), 'QRY', .F., .T.)
QRY->(dbGoTop())

DBGotop()
dbEval({|| nCont++})
ProcRegua(nCont)
DBGotop() 

CTD->(dbSetOrder(1))

While !QRY->(Eof())
    IncProc()
	If !CTD->(dbSeek(xFilial('CTD')+QRY->CODIGO))      
		dbSelectArea("CTD")
		If RecLock("CTD",.T.)
			CTD->CTD_FILIAL := xFilial("CTD")
			CTD->CTD_ITEM   := QRY->CODIGO
			CTD->CTD_DESC01 := QRY->NOME
			CTD->CTD_CLASSE := "2"
			CTD->CTD_NORMAL := IF(SUBSTR(QRY->CODIGO,1,1)=="F","1","2")
			CTD->CTD_BLOQ   := "2"
			CTD->CTD_DTEXIS := CtoD("01/01/2010")
			CTD->CTD_ITLP   := CTD->CTD_ITEM
			CTD->CTD_CLOBRG := "2"
			CTD->CTD_ACCLVL := "1"
			CTD->CTD_BOOK   := "AUTO"
			MsUnlock("CTD")
		EndIf
	EndIf
	QRY->(dbSkip())
EndDo
  QRY->(dbCloseArea())
Return