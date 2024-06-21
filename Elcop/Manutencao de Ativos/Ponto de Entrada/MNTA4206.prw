/*
Ponto de Entrada que permite a inclus�o de campos na rotina de OS Corretiva. 
Incluir os Campos:
TJ_DTMPFIM - Data Fim para t�rmino na OS
TJ_HOMPFIM - Hora fim para t�rmino da OS
*/
#Include 'Protheus.ch'

User Function MNTA4206()

AAdd(aChoice,"TJ_DTMPFIM") 
AAdd(aChoice,"TJ_HOMPFIM") 
AAdd(aChoice,"TJ_XCODFOR") 
AAdd(aChoice,"TJ_XDESCFO") 



Return .T.