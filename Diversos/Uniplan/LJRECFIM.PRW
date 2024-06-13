#include "protheus.ch"
#INCLUDE 'totvs.ch' 

User Function LJRECFIM()

Local _aParams := PARAMIXB 

If  PARAMIXB[1] == '2'
DbSelectArea("SE5")
DbSetOrder(1)	

    MsgInfo("Passou Aqui!", "Atenção")   

Endif

Return 
