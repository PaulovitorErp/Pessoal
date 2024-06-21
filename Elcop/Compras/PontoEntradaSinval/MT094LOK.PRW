/* ponto de Entrada na liberação/aprovação do Pedido de Compras / AE 

    Será verificado se o fornecedor possui IQF > 50
    Na ocorrência de IQF < 50, será necessário liberação do Sistema.

*/

User Function MT094LOK() 
    Local lRetorno := .T. 
    Local cFornecedor   := POSICIONE("SC7",1,SCR->(CR_FILIAL+CR_NUM),"C7_FORNECE")
    Local cLojaFor      := POSICIONE("SC7",1,SCR->(CR_FILIAL+CR_NUM),"C7_LOJA")
    Local nIQF          := POSICIONE("SA2",1,xFilial("SA2")+cFornecedor+cLojaFor,"A2_XIQF")
    Local cTipForn      := Posicione("SA2",1,XFILIAL("SA2")+cFornecedor+cLojaFor,"A2_XTIPO")
    Local dDtaBloq      := Posicione("SA2",1,XFILIAL("SA2")+cFornecedor+cLojaFor,"A2_XDTBIQF")
    Local nDoc          := Posicione("SA2",1,XFILIAL("SA2")+cFornecedor+cLojaFor,"A2_XNOTDOC")
    Local nLicenc       := Posicione("SA2",1,XFILIAL("SA2")+cFornecedor+cLojaFor,"A2_XNOTLIC")

    if cTipForn == "O" 

        if nIQF = 0 .and. (nDoc > 0 .or. nLicenc > 0)
            lRetorno := .T.
        else    
            if nIQF <= 50
                if (dDtaBloq + 60) <= dDatabase
                    ZCX->(DbSetOrder(1))
                    if ZCX->(dbSeek(xFilial("ZCX")+cFornecedor+cLojaFor))
                        if !(dDatabase >= ZCX->ZCX_DATINI .and. dDatabase <= ZCX->ZCX_DATFIN)
                            msginfo("Fornecedor Bloqueado para Compras IQF <= 50","Bloqueio")
                            lRetorno := .F.
                        endif
                    else
                        msginfo("Fornecedor Bloqueado para Compras IQF <= 50","Bloqueio")
                        lRetorno := .F.
                    endif
                else
                    lRetorno := .T.                
                endif
            elseif nIQF > 50 .and. nIQF <= 59
                    if (dDtaBloq + 30) <= dDatabase
                        ZCX->(DbSetOrder(1))
                        if ZCX->(dbSeek(xFilial("ZCX")+cFornecedor+cLojaFor))
                            if !(dDatabase >= ZCX->ZCX_DATINI .and. dDatabase <= ZCX->ZCX_DATFIN)
                                msginfo("Fornecedor Bloqueado para Compras IQF <= 50","Bloqueio")
                                lRetorno := .F.
                            endif
                        else
                            msginfo("Fornecedor Bloqueado para Compras IQF <= 50","Bloqueio")
                            lRetorno := .F.
                        endif
                    else
                        lRetorno := .T.                
                    endif
            endif
        endif
    endif

Return(  lRetorno ) 
