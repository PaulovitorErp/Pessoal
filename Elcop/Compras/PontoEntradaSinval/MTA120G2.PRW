/*
LOCALIZAÇÃO : Function A120GRAVA - Função responsável pela gravação do Pedido de Compras e Autorização de Entrega.

EM QUE PONTO : Na função A120GRAVA executado após a gravação de cada item do pedido de compras recebe como parametro 
o Array manipulado pelo ponto de entrada MTA120G1 e pode ser usado para gravar as informações deste array no item do pedido posicionado.

Autor: Sinval

*/

#Include "Protheus.ch"

User Function MTA120G2()
    Local aArea := GetArea()
     
    //Atualiza variável pública criada no ponto de entrada MT120TEL
    SC7->C7_XFORPG := cXForpg
     
    RestArea(aArea)
Return
