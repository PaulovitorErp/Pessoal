/* Ponto de entrada para Selecionar o checkbox M�ltiplas naturezas no momento da baixa
   dos t�tulos como border�
*/

#INCLUDE "PROTHEUS.CH"

User Function F090MNAT   

    Local aArea := GetArea()
    Local lRet := .T.
    
    RestArea(aArea)
Return lRet
