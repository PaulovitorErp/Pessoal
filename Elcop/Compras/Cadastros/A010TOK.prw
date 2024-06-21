#Include "Protheus.ch"
 
/*------------------------------------------------------------------------------------------------------*
 | P.E.:  A010TOK                                                                                       |
 | Desc:  Confirma��o do cadastro de produtos                                                           |
 |  *--------------------------------------------------------------------------------------------------*/
 
User Function A010TOK()
    Local aArea := GetArea()
    Local aAreaB1 := SB1->(GetArea())
    Local xRet := .F.
     
    //Se for inclus�o
   If INCLUI
		if __cUserID$SuperGetMv("MV_XUSRPRO")
			xRet := .T.
		endif    
   elseif ALTERA
		if __cUserID$SuperGetMv("MV_XUSRPRO")
			xRet := .T.
		endif
   elseif lCopia
		if __cUserID$SuperGetMv("MV_XUSRPRO")
			xRet := .T.
		endif
    EndIf
     
    If xRet == .F.
		FWAlertHelp("N�o � permitido Inclus�o/Altera��o/C�pia do Produto! Procure o departamento Responsavel!","MV_XUSRPRO")
    endif
     
    RestArea(aAreaB1)
    RestArea(aArea)
Return xRet
