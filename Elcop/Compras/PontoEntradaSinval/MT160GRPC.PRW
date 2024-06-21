/*
	Ponto de Entrada na geração da SC7 Apos confirmar cotação de compras.
    Ponto de Entrada para atualizar a data de entrega do pedido de compras gerado.

    dDatabase + 3 + Prazo de Entrega  MATA121 E MATA120 
*/

#include 'Protheus.ch'
#include 'TOPConn.ch'
#include 'Rwmake.ch'
#include "TbiConn.ch"
#include "TbiCode.ch"

User Function MT160GRPC()

	Local cNumOS 	:= Posicione("SC1",6,SC7->(C7_FILIAL+C7_NUM+C7_ITEM+C7_PRODUTO),"C1_OS")
	Local cCodBem 	:= Posicione("STJ",1,xFilial("STJ")+cNumOS,"TJ_CODBEM")
	Local cPlaca 	:= Posicione("ST9",1,xFilial("ST9")+cCodBem,"T9_PLACA")

	SC7->C7_XOBS 	:= SC1->C1_OBS
	SC7->C7_DATPRF 	:= dDataBase + GETMV("MV_XDIASPC") + SC8->C8_PRAZO
	SC7->C7_XPLACA 	:= cPlaca

Return()
