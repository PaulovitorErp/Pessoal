/*
Descri��o:
LOCALIZA��O : Function A110GRAVA - Fun��o da Solicita��o de Compras responsavel pela grava��o das SCs.
EM QUE PONTO : No laco de grava��o dos itens da SC na fun��o A110GRAVA, executado ap�s gravar o item da SC,
a cada item gravado da SC o ponto � executado.

Eventos
Programa Fonte MATA110.PRX
Sintaxe MT110GRV ( < PARAMIXB> ) --> Nil

Ativar o Par�metro MV_APROVSC //Desativado

Campo da Solicita��o de Compras que ser� gravado:

C1_APROV para os casos do tipo do produto serem
M1-EPI
M2-EPC
M3-FERRAMENTAS
o conte�do ser� "B" e para os demais ser� "L"

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
