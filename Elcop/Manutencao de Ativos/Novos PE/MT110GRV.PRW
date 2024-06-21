/*
Descrição:
LOCALIZAÇÃO : Function A110GRAVA - Função da Solicitação de Compras responsavel pela gravação das SCs.
EM QUE PONTO : No laco de gravação dos itens da SC na função A110GRAVA, executado após gravar o item da SC,
a cada item gravado da SC o ponto é executado.

Eventos
Programa Fonte MATA110.PRX
Sintaxe MT110GRV ( < PARAMIXB> ) --> Nil

Ativar o Parâmetro MV_APROVSC //Desativado

Campo da Solicitação de Compras que será gravado:

C1_APROV para os casos do tipo do produto serem
M1-EPI
M2-EPC
M3-FERRAMENTAS
o conteúdo será "B" e para os demais será "L"

"L" = Liberado 
"R" = Rejeitado 
"B" = Bloqueado
*/
#include "Protheus.ch"

User Function MT110GRV()
//Local lExp1 :=  PARAMIXB[1]
Local cTipo := Posicione("SB1",1,XFILIAL("SB1")+SC1->C1_PRODUTO,"B1_TIPO")

if !cTipo $ "M1-M2-M3"
    SC1->(RecLock("SC1",.F.))
    SC1->C1_APROV := "L"
    SC1->(MsUnlock())
endif

Return
