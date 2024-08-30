#Include "Protheus.ch" 

User Function MDTA6952()
    Local lRet := .T.

    MsgStop("Você não pode visualizar", "Atenção")
    lRet := .F. // Impede a ação

    Return lRet
