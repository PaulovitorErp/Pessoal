/*
Descrição:
LOCALIZAÇÃO : Function A110Aprov - Função de aprovação da Solicitação de Compras.

EM QUE PONTO : No inicio da rotina A110Aprov antes da execução da dialog de aprovação da SC, 
utilizado para manipular o Array com os campos da tabela SC1, indicado para adicionar mais campos para a apresentação.

Autor: Sinval
*/

#include "totvs.ch"

User Function MT110CPO()

    Local aNewCpos :=  PARAMIXB[1]  
    
    aAdd(aNewCpos, "C1_OBS")  //-- Adiciona os campos do usuario 

Return aNewCpos
