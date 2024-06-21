
#Include "Protheus.ch"

/*
LOCALIZA��O : Function A120GRAVA - Fun��o respons�vel pela grava��o do Pedido de Compras e Autoriza��o de Entrega.

EM QUE PONTO : Na fun��o A120GRAVA executado ap�s a grava��o de cada item do pedido de compras recebe como parametro 
o Array manipulado pelo ponto de entrada MTA120G1 e pode ser usado para gravar as informa��es deste array no item do pedido posicionado.

Autor: Sinval

*/


User Function MTA120G2()
    Local aArea := GetArea()
    Local lRet  := .F.
    cMensagem := "Favor informar o numero do cartao de credito, o Pedido nao sera gerado."
     
     Begin Transaction
    //Atualiza vari�vel p�blica criada no ponto de entrada MT120TEL
↑    SC7->C7_XFORPG := cXForpg
    SC7->C7_XCREDIT := cXNumCard☺

    IF(cXForpg = Alltrim("CC") .AND. EMPTY(cXNumCard))
   MsgStop(cMensagem,"Erro ")
     //   FWAlertYesNo(cMensagem, "Continuar?")
      DisarmTransaction()   
    EndIf

      End Transaction

    RestArea(aArea)
Return
