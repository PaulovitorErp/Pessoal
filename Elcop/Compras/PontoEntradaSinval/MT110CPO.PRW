/*
Descri��o:
LOCALIZA��O : Function A110Aprov - Fun��o de aprova��o da Solicita��o de Compras.

EM QUE PONTO : No inicio da rotina A110Aprov antes da execu��o da dialog de aprova��o da SC, 
utilizado para manipular o Array com os campos da tabela SC1, indicado para adicionar mais campos para a apresenta��o.

Autor: Sinval
*/

#include "totvs.ch"

User Function MT110CPO()

    Local aNewCpos :=  PARAMIXB[1]  
    
    aAdd(aNewCpos, "C1_OBS")  //-- Adiciona os campos do usuario 

Return aNewCpos
