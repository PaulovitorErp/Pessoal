#INCLUDE "PROTHEUS.CH"

/*
#############################################################################
#############################################################################
## Programa  | MNTA415 |Autor|  ANDRE CASTILHO		    |Data|  03/03/2024 ##
##=========================================================================##
## Desc.| PONTO DE ENTRADA RETORNA CODIGO FORNECEDOR NA BAIXA O.S          ##
##=========================================================================##
## Uso       | Elcop	                                               	   ##
#############################################################################
#############################################################################
*/

User Function MNTA4352()
 
    Local cQuery
    Local cAliasQry := GetNextAlias()
    Local nRetorno  := ParamIXB[1]
 
    cAliasQry := GetNextAlias()
     
    cQuery := " SELECT CP_PREREQU FROM " + RetSqlName( "SCP" )
    cQuery += " WHERE SUBSTRING(CP_OP, 1, 6)  = '" + STJ->TJ_ORDEM + "'"
    cQuery += " AND CP_PREREQU = 'S' "
    cQuery += " AND D_E_L_E_T_ <> '*' "
     
    cQuery := ChangeQuery(cQuery)
     
    dbUseArea( .T., "TOPCONN", TCGENQRY(,, cQuery), cAliasQry, .F., .T.)
  
    dbSelectArea( cAliasQry )
    If (cAliasQry)->CP_PREREQU == "S"
        MsgInfo( "A O.S. não poderá ser finalizada pois existe uma S.A para o produto." )
        nRetorno := 2
    EndIf
     
    (cAliasQry)->( dbCloseArea() )
     
Return nRetorn



/*
User Function MNTA41502()

Local aAreaSD1  := SD1->(GetArea())
Local aAreas 	:= getArea()  

if (EMPTY(TJ_XCODFOR)) 

  DBSelectArea("SD1")
   SD1->(DbSetOrder(1))
if !Empty(alltrim(SD1->D1_OP)) .and. !Empty(alltrim(SD1->D1_ORDEM))
			STJ->(DbSetOrder(1))
			STJ->(DbSeek(xFilial("STJ")+SD1->D1_ORDEM))
            STJ->(Reclock("STJ",.T.))
            STJ->TJ_XCODFOR := SD1->D1_ORDEM
            	If !MsUnlock()
                        Alert("erro ao desbloquear registro!")
                EndIf
        DbCloseArea("SD1")
 EndIf 
EndIf

	RestArea(aAreaSD1)
    RestArea(aAreas)

    Return 
