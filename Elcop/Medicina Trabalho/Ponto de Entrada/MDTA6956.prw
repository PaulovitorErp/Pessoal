#Include "Protheus.ch" 


User Function MDTA6956()

    
Local lRet := .T.
Local nOpcAuto  // Valor que captura a ação do botão

    // Aqui se faz a verificação da ação
     if nOpcAuto == 2
      MsgStop("Você não pode visualizar", "Atenção")
       lRet := .F. // Impede a ação
   endif

    Return lRet



