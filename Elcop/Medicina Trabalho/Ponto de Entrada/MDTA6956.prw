#Include "Protheus.ch" 


User Function MDTA6956()

    
Local lRet := .T.
Local nOpcAuto  // Valor que captura a a��o do bot�o

    // Aqui se faz a verifica��o da a��o
     if nOpcAuto == 2
      MsgStop("Voc� n�o pode visualizar", "Aten��o")
       lRet := .F. // Impede a a��o
   endif

    Return lRet



