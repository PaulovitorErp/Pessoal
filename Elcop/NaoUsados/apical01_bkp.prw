#include 'totvs.ch'
#include 'Restful.ch'
#INCLUDE "APWEBSRV.CH" 
#INCLUDE "topconn.ch"
#INCLUDE "TBICONN.CH"  

user function apical01()
Return

WSRESTFUL APICal01 DESCRIPTION "API Pirecal Estoques - Consulta Produtos" FORMAT "application/json,text/html" 
	WSDATA localEstoque  	as String
    WSDATA cFilEstoque      as String

	WSMETHOD    GET conProdutos ;
    	        DESCRIPTION 'Consulta Cadastro de Produtos'	;
                WSSYNTAX '/APICal01/conProdutos/{cFilEstoque}{localEstoque}' ;
                PRODUCES APPLICATION_JSON

	WSMETHOD    POST baixaEstoque ;
         		DESCRIPTION 'Baixa de Estoque' 	;
                WSSYNTAX '/APICal01/baixaEstoque' ;
                PRODUCES APPLICATION_JSON
END WSRESTFUL

WSMETHOD GET conProdutos WSRECEIVE cFilEstoque, localEstoque WSRESTFUL APICal01
	Local lRet 		:= .T.
	Local oResponse	:= JsonObject():New()
    Local cQuery    := ""
	Local cEOL 		:= Chr(13)+Chr(10)
    Local nSaldo    := 0
	
    //obrigatorio informar o Local de Estoque
    
    IF Empty(Self:localEstoque) .or. Empty(Self:cFilEstoque)
        SetRestFault(400,EncodeUTF8('Obrigatório Informar o Local de Estoque e Filial'))
        lRet    := .F.
        Return(lRet)
    EndIF

    //Retorna apenas o Tipo Json
	::SetContentType('application/json')
	
    //Query que irá retornar 
    cAliasTop := GetNextAlias()
    cQuery := "SELECT SB1.B1_COD, SB1.B1_UM, SB1.B1_DESC, SB2.B2_LOCAL, NNR.NNR_DESCRI, SB2.B2_QATU          "+cEOL
    cQuery += "FROM "+retSqlName("SB1") + " SB1 															 "+cEOL
    cQuery += "INNER JOIN "+retSqlName("SB2") + " SB2 ON (SB2.D_E_L_E_T_ = ' ' AND SB2.B2_LOCAL = '"+alltrim(self:localEstoque)+"' "+cEOL
    cQuery += " AND SB2.B2_COD = SB1.B1_COD AND SB2.B2_FILIAL = '"+self:cFilEstoque+"' )                     "+cEOL
    cQuery += "INNER JOIN "+retSqlName("NNR") + " NNR ON (NNR.D_E_L_E_T_ = ' ' AND NNR.NNR_CODIGO = SB2.B2_LOCAL "+cEOL
    cQuery += "AND NNR.NNR_FILIAL = '"+self:cFilEstoque+"')                                                  "+cEOL
    cQuery += "WHERE SB1.D_E_L_E_T_ = ' '                               									 "+cEOL
	cQuery += "ORDER BY B1_COD                                   											 "+cEOL
    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)

	conout("Consultando Produtos no Local de Estoque ==> "+alltrim(self:localEstoque) )

	oResponse['status'] := 200  // parâmetro que irá retornar com sucesso
	oResponse['dados']	:= {}

	cCodigoCL := ""
	(cAliasTop)->(DbGoTop())
	do While (cAliasTop)->(!Eof())

		if SB2->(DbSeek(xFilial("SB2")+(cAliasTop)->B1_COD+alltrim(self:localEstoque) ))
			nSaldo := SB2->(saldoSB2())
        else
            nSaldo := 0
        endif

		oJsonCL := JsonObject():New()
		
		oJsonCL['codigoProduto']	:= alltrim((cAliasTop)->B1_COD)
		oJsonCL['UMProduto'] 	    := alltrim((cAliasTop)->B1_UM)
		oJsonCL['descProduto']	    := EncodeUTF8(alltrim((cAliasTop)->B1_DESC ) )
        oJsonCL['localEstoque']     := (cAliasTop)->B2_LOCAL
        oJsonCl['nomeEstoque']      := EncodeUTF8(alltrim((cAliasTop)->NNR_DESCRI) )
		oJsonCL['saldoDisponivel']	:= nSaldo
		
        aAdd(oResponse['dados'], oJsonCL)
		(cAliasTop)->(dbSkip())
	EndDo
	
    (cAliasTop)->(DbCloseArea())

	::SetResponse(oResponse:ToJson())

Return lRet 

WSMETHOD POST baixaEstoque WSRECEIVE WSSERVICE APICal01
	Local lRet 		:= .T.
	Local cJson		:= ::getContent()
	Local aRet 		:= {}
	Local oResponse, oJson

	Local cCodEmp		:= "01"  
	Local cCodFil		:= "0101"

	
	RpcSetType(3)
	Reset Environment
	lConnect := RpcSetEnv(cCodEmp,cCodFil) 
    
	::SetContentType() 
	
	conout("Incluindo Baixa no Estoque")
	
	oResponse	:= JsonObject():New()
	oJson		:= JsonObject():New()
	
	oJson:FromJson(cJson)
	
	aRet		:= restMovimento(oJson)   
	
	If aRet[1]
		oResponse['status'] := aRet[3]
		oResponse['message']:= aRet[2]
		::SetResponse(oResponse:toJson())
	Else
		lRet := .F.
		SetRestFault(aRet[3], aRet[2])
	EndIf

Return lRet


Static Function restMovimento(oJson)
	Local aRet 			:= {}
    Local aCabecalho    := {}
    Local aItens        := {}
    Local aItem         := {}
    
    Local nOper         := val(oJson["D3_OPERACAO"])
    Local ExpA1         := {}

    Private lAutoErrNoFile := .T.
    private lMsErroAuto    := .F.

    if nOper = 3  // Inclusão

        /*  aadd(aCabecalho, { "D3_FILIAL"  , oJson["D3_FILIAL"]    , NIL}) //01-FILIAL
            aadd(aCabecalho, { "D3_TM"      , oJson["D3_TM"]        , NIL}) //02-TM
            aadd(aCabecalho, { "D3_EMISSAO" , oJson["D3_EMISSAO"]   , NIL}) //03-EMISSAO
            aadd(aCabecalho, { "D3_CC"      , oJson["D3_CC"]        , NIL}) //04-CENTRO DE CUSTO
            
        aAdd(aItens,    {   {"D3_COD"       , oJson["D3_COD"]       , NIL},;    //01-Produto
                            {"D3_LOCAL"     , oJson["D3_LOCAL"]     , NIL},;    //02-Local
                            {"D3_QUANT"     , oJson["D3_QUANT"]     , NIL},;    //03-Quantidade
                            {"D3_LOTECTL"   , oJson["D3_LOTECTL"]   , NIL}})    //04-Endereo
        */
 /*
		aAdd(ExpA1,{,;//                {"D3_FILIAL"	,oJson["D3_FILIAL"]         , NIL} ,;
        			{"D3_TM"		,oJson["D3_TM"]             , NIL} ,;
					{"D3_COD"		,oJson["D3_COD"]	        , NIL} ,;
                    {"D3_LOCAL"		,oJson["D3_LOCAL"]	        , NIL} ,;   //{"D3_NUMSEQ"	,SD3->D3_NUMSEQ , NIL},; {"D3_CF"		,SD3->D3_CF     , NIL},;
                    {"D3_QUANT"		,oJson["D3_QUANT"]          , NIL} ,;   //{"D3_LOTECTL"   ,oJson["D3_LOTECTL"]    , NIL} ,;                    
                    {"D3_EMISSAO"	,ddatabase                  , NIL} })  // CTOD(oJson["D3_EMISSAO"])

////					{"INDEX"		,3				        , NIL} })
*/				

        aItem := {}
        aadd(aItem,{"D3_FILIAL" , Alltrim(oJson["D3_FILIAL"])  ,NIL})
        aadd(aItem,{"D3_TM"     , Alltrim(oJson["D3_TM"])      ,NIL})
        aadd(aItem,{"D3_COD"    , oJson["D3_COD"]              ,NIL})
        aadd(aItem,{"D3_QUANT"  , oJson["D3_QUANT"]            ,NIL})
        aadd(aItem,{"D3_LOCAL"  , Alltrim(oJson["D3_LOCAL"])   ,NIL})
        aadd(aItem,{"D3_EMISSAO", CTOD(oJson["D3_EMISSAO"])    ,NIL})

		MSExecAuto({|x,y| mata240(x,y)},aItem,3)
		

     /*   aCabecalho := {{"D3_DOC" ,NextNumero("SD3",2,"D3_DOC",.T.), NIL},;
                         { "D3_FILIAL"  , oJson["D3_FILIAL"]    , NIL},;
                {"D3_TM" ,oJson["D3_TM"] , NIL},;
                {"D3_CC" ,oJson["D3_CC"], NIL},;
                {"D3_EMISSAO" ,oJson["D3_EMISSAO"], NIL}}


        aItens:={{"D3_COD" ,oJson["D3_COD"] ,NIL},;
        {"D3_UM" ,oJson["D3_UM"] ,NIL},; 
        {"D3_QUANT" ,oJson["D3_QUANT"] ,NIL},;
        {"D3_LOCAL" ,oJson["D3_LOCAL"] ,NIL},;
        {"D3_LOTECTL" ,oJson["D3_LOTECTL"] ,NIL},;
        {"D3_LOCALIZ" , oJson["D3_LOCALIZ"] ,NIL}}
     */

            
      //  MSExecAuto({|X,Y,Z| MATA241(X,Y,Z)}, aCabecalho, aItens, nOper)
        
        If lMsErroAuto
            RollBackSX8()

            cErro := MostraErro("\spool", cArqLog, 400)
            cErro := TrataErro(cErro)
            aRet    := {.F., cErro}
        Else
            ConfirmSx8()
            aRet    := {.T., EncodeUTF8("Baixa realizada com Sucesso"), 200}
        EndIf    

    elseif nOper = 6

            SD3->(DbSetOrder(3))//D3_FILIAL, D3_COD, D3_LOCAL, D3_NUMSEQ, 
            if SD3->(DbSeek(oJson["D3_FILIAL"]+;
                        PadR(oJson["D3_COD"]     ,TamSx3("D3_COD")[1]) +;
                        PadR(oJson["D3_LOCAL"]  ,TamSx3("D3_LOCAL")[1]) +;
                        PadR(oJSon["D3_NUMSEQ"] ,TamSx3("D3_NUMSEQ")[1]) ))
                
                aCabecalho  := {    {"D3_TM"        ,SD3->D3_TM         , nil},;
                                    {"D3_EMISSAO"   ,SD3->D3_EMISSAO    , nil} }

                aItem      := {     {"D3_COD"     ,SD3->D3_COD          ,nil},;
                                    {"D3_UM"      ,SD3->D3_UM           ,nil},;
                                    {"D3_QUANT"   ,SD3->D3_QUANT        ,nil},;
                                    {"D3_LOCAL"   ,SD3->D3_LOCAL        ,nil},;
                                    {"D3_LOTECTL" ,SD3->D3_LOTECTL      ,nil} }
                
                aadd(aItens, aItem)

                MSExecAuto({|x,y,z| MATA241(x,y,z)}, aCabecalho, aItens, 6)

                If lMsErroAuto
                    RollBackSX8()

                    cErro := MostraErro("\spool", cArqLog)
                    cErro := TrataErro(cErro)
                    aRet    := {.F., cErro,400}
                else
                    ConfirmSx8()
                    aRet    := {.T., EncodeUTF8("Estorno realizado com Sucesso"),200}
                endIf
            else
                aRet    := {.F., EncodeUTF8("Lançamento Não Encontrado"),401}
            endif
    else
        aRet    := {.F., EncodeUTF8("Operação Não Permitida"),402}
    endif

Return(aRet)

