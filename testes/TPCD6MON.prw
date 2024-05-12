/*/{Protheus.doc} User Function TPCD6MON
    (long_description)
    @type  Function
    @author user
    @since 01/09/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function TPCD6MON
    
    Local aRetPEMono := {"","",0,0,0} //c_INDIMP,c_UFORIG,n_PORIG,n_PBIO, nAdRemIcmsRet
    Local cProduto := ParamIxb[1]

    if Alltrim(cProduto) == "006119" //DIESEL B S10
        aRetPEMono := {"0","GO",100,12, 0.9456}
    elseif Alltrim(cProduto) == "006117" //DIESEL B S500
        aRetPEMono := {"0","GO",100,12, 0.9456}
    elseif Alltrim(cProduto) == "006118" //GASOLINA COMUM
        aRetPEMono := {"0","GO",100,27, 1.22}
   // elseif Alltrim(cProduto) == "006120" //ETANOL
     //   aRetPEMono := {"0","GO",100,0, 0}
    endif

Return aRetPEMono
