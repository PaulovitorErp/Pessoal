/* 

Fonte incluído para o Gatilho na inclusão do fornecedor, 
será preenchido o IQF do fornecedor conforme as notas de DOC e Licenças 

*/   

#INCLUDE "totvs.ch"

user function ACOM008()                                                                                           
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

    if cTipForn == "O" .and. nIQF <= 50 
        ZCX->(DbSetOrder(1))
        if ZCX->(dbSeek(xFilial("ZCX")+cFornecedor+cLoja))
            if !(dDatabase >= ZCX->ZCX_DATINI .and. dDatabase <= ZCX->ZCX_DATFIN)
                msginfo("Fornecedor Bloqueado para Compras IQF <= 50","Bloqueio")
                lRet:= .F.
            endif
        else
            msginfo("Fornecedor Bloqueado para Compras IQF <= 50","Bloqueio")
            lRet:= .F.
        endif
    endif

return(lRet)
