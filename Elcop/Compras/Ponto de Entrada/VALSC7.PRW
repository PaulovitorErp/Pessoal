#Include "TOTVS.ch"

User Function zExe297()
    Local aArea      := FWGetArea()
    Local cMensagem  := "Não foi informado o numero de cartão de credito"
    Local cSolucao   := "Selecione o cartão que vai ser efetuado a compra"
    Local cXForpg    :=  SC7->C7_XFORPG
    Local cXNumCard  :=  SC7->C7_XCREDIT



     IF(cXForpg = Alltrim("CC") .AND. EMPTY(cXNumCard))
       //Exibindo a mensagem com Help
    Help(, , "Help", , cMensagem, 1, 0, , , , , , {cSolucao})
     EndIf

     

    FWRestArea(aArea)
Return