#Include "Protheus.ch" 

User Function MDTA6952()
    Local lRet := .T.

    MsgStop("Voc� n�o pode visualizar", "Aten��o")
    lRet := .F. // Impede a a��o

    Return lRet
