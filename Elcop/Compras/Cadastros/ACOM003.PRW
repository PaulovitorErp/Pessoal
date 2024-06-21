/* Validação de campo C1_XFABRIC
   verifica na tabela ZCS se existe bloqueio para o produto e fabricante
*/   

#INCLUDE "totvs.ch"

user function ACOM003(cFabrica)                                                                                           
    Local lRet := .T.
    Local cProduto  := aCols[n,AScan(aHeader, {|x| AllTrim(x[2]) == "C1_PRODUTO"})]

    if Posicione("ZCS",2,XFILIAL("ZCS")+cFabrica+cProduto,"ZCS_BLOQ") == "S"
        msginfo("Fabricante Bloqueado para este Produto","Bloqueio")
        lRet := .F.
    endif
return(lRet)
