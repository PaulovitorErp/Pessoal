/*/{Protheus.doc} User Function STQUANT
P.E. Para Modificar a Quantidade e Valor Unitario 

@type  Function
@author danilo
@since 14/11/2023
@version 1
/*/
User Function STQUANT(param_name)
    
    Local nQuant := ParamIxb[1]
    Local nPrice := ParamIxb[2]
    Local nItemTotal := ParamIxb[3]
    Local cCodProd := ParamIxb[4]

    Conout( "Quantidade: ["+cValToChar(nQuant)+"], Preço: ["+cValToChar(nPrice)+"], Total: ["+cValToChar(nItemTotal)+"], ITEM_CODIGO: ["+cCodProd+"]")

Return {nQuant, nPrice}
