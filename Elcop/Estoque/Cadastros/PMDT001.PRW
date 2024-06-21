/* 

Consulta dos Laudos POR Produto tabela TNF (funcionários x EPI)
Valida se está válido

*/   

#INCLUDE "totvs.ch"

user function PMDT001(cCodLaudo,cCodProd)                                                                                           
    Local lRet      := .T.
    //Local nPosProd := AScan(aHeader,{|x| AllTrim(x[2]) == "TNF_COD" })

    ZCW->(DbSetOrder(1))
    if ZCW->(dbSeek(xFilial("ZCW") + cCodLaudo))
        if ZCW->ZCW_DTAVAL <= dDatabase
            msginfo("PMDT001-Laudo Vencido, em "+dtoc(ZCW->ZCW_DTAVAL),"Laudo")            
            lRet := .F.
        endif

        if cCodProd = "1"
            if ZCW->ZCW_COD <> aCols[n][GdFieldPos( "TNF_CODEPI" )]
                msginfo("PMDT001-Laudo refere-se a Outro Material "+ZCW->ZCW_COD,"Laudo")            
                lRet := .F.
            endif
        else
            if ZCW->ZCW_COD <> FwFldGet('ZCB_COD')
                msginfo("PMDT001-Laudo refere-se a Outro Material "+ZCW->ZCW_COD,"Laudo")            
                lRet := .F.
            endif
        endif
    else
        msginfo("PMDT001-Laudo Não Cadastrado","Laudo")
        lRet := .F.
    endif       
return(lRet)

