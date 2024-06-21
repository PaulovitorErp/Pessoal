/* 
Validação para Liberar Fornecedores com IQF menor que 50%

Nota de 00 a 50 pontos: O Fornecedor será bloqueado não tendo autorização para fornecer para ELCOP, 
        por um período de 60 dias, exceto em casos de produtos específicos que devem ser autorizados 
        pela Diretoria em um cadastro a ser realizado no sistema Protheus com os devidos registros e justificativas.

Nota de 51 a 59 pontos: O Fornecedor será bloqueado temporariamente por 30 (trinta) dias, 
        havendo a necessidade de compras deste fornecedor no período de bloqueio, 
        somente a diretoria poderá liberar o mesmo por um período determinado.

Nota de 60 a 69 pontos: O Fornecedor será advertido de sua baixa avaliação, 
        como forma de se atentar para as causas que lhe atribuiu baixa nota de avaliação.

Nota acima de 70 pontos: O Fornecedor será considerado apto e bem qualificado.

Campo para registro da Data do Bloqueio do IQF => A2_XDTBIQF, será gravada no momento da geração do IQF
*/   

#INCLUDE "totvs.ch"

user function ACOM007()                                                                                           
    Local lRet      := .T.
    Local cFornecedor
    Local cLoja
    Local nIQF  
    Local cTipForn 
    Local oModel 	:= FWModelActive()                
	Local oModelSC8	:= oModel:GetModel('SC8DETAIL')

    cFornecedor := oModelSC8:GetValue('C8_FORNECE')     //aCols[n,AScan(aHeader, {|x| AllTrim(x[2]) == "C8_FORNEC"})]
    cLoja       := oModelSC8:GetValue('C8_LOJA')        //aCols[n,AScan(aHeader, {|x| AllTrim(x[2]) == "C8_LOJA"  })]
    cTipForn    := Posicione("SA2",1,XFILIAL("SA2")+cFornecedor+cLoja,"A2_XTIPO")
    nIQF        := Posicione("SA2",1,XFILIAL("SA2")+cFornecedor+cLoja,"A2_XIQF")
    dDtaBloq    := Posicione("SA2",1,XFILIAL("SA2")+cFornecedor+cLoja,"A2_XDTBIQF")

    if cTipForn == "O" 
    
        if nIQF <= 50
            if (dDtaBloq + 60) <= dDatabase
                ZCX->(DbSetOrder(1))
                if ZCX->(dbSeek(xFilial("ZCX")+cFornecedor+cLoja))
                    if !(dDatabase >= ZCX->ZCX_DATINI .and. dDatabase <= ZCX->ZCX_DATFIN)
                        msginfo("Fornecedor Bloqueado para Compras IQF <= 50","Bloqueio")
                        lRet := .F.
                    endif
                else
                    msginfo("Fornecedor Bloqueado para Compras IQF <= 50","Bloqueio")
                    lRet := .F.
                endif
            else
                lRet := .T.                
            endif
        elseif nIQF > 50 .and. nIQF <= 59
                if (dDtaBloq + 30) <= dDatabase
                    ZCX->(DbSetOrder(1))
                    if ZCX->(dbSeek(xFilial("ZCX")+cFornecedor+cLoja))
                        if !(dDatabase >= ZCX->ZCX_DATINI .and. dDatabase <= ZCX->ZCX_DATFIN)
                            msginfo("Fornecedor Bloqueado para Compras IQF <= 50","Bloqueio")
                            lRet := .F.
                        endif
                    else
                        msginfo("Fornecedor Bloqueado para Compras IQF <= 50","Bloqueio")
                        lRet := .F.
                    endif
                else
                    lRet := .T.                
                endif
        endif
    endif

return(lRet)
