/* Ponto de entrada para Selecionar o checkbox Múltiplas naturezas no momento da baixa
   dos títulos como borderô
*/

#INCLUDE "PROTHEUS.CH"

User Function F090MNAT   

    Local aArea := GetArea()
    Local lRet := .T.
    
    RestArea(aArea)
Return lRet
