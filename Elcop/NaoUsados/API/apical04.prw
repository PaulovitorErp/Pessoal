#include 'totvs.ch'
#include 'Restful.ch'

user function apical04()
Return

WSRESTFUL APICal04 DESCRIPTION "API Pirecal Estoques - Consulta Kardex" FORMAT "application/json,text/html" 
	WSDATA cLocalEstoque  	as String
    WSDATA cFilEstoque      as String
    WSDATA cCodProduto      as String

	WSMETHOD    GET conKardex ;
    	        DESCRIPTION 'Consulta Kardex'	;
                WSSYNTAX '/APICal04/conKardex/{cFilEstoque}{cLocalEstoque}{cCodProduto}' ;
                PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET conKardex WSRECEIVE cFilEstoque, cLocalEstoque, cCodProduto WSRESTFUL APICal04
	Local lRet 		:= .T.
	Local oResponse	:= JsonObject():New()
    Local cQuery    := ""
	
    //obrigatorio informar o Local de Estoque
    
    IF Empty(Self:cLocalEstoque) .or. Empty(Self:cFilEstoque) .or. empty(self:cCodProduto)
        SetRestFault(400,EncodeUTF8('Obrigatório Informar o Local de Estoque, Filial e Produto'))
        lRet    := .F.
        Return(lRet)
    EndIF

    //Retorna apenas o Tipo Json
	::SetContentType('application/json')
	
    //Query que irá retornar 
    cAliasTop := GetNextAlias()

	cQuery := "SELECT 'NF_E' AS ARQ, SB1.B1_COD PRODUTO, SB1.B1_DESC DESCR, SB1.B1_UM UNID, D1_TES TES, "
    cQuery += "D1_NUMSEQ NUMSEQ, D1_DOC DOCUMENTO, D1_QUANT QUANTIDADE, "
    cQuery += "D1_DTDIGIT DATAMOV "
	cQuery += "FROM "+retSqlName("SB1")+ " SB1, "+retSqlName("SD1") + " SD1, "+retSqlName("SF4") + " SF4 "
	cQuery += "WHERE SB1.B1_COD = SD1.D1_COD AND SD1.D1_FILIAL = '"+self:cFilEstoque+"'	AND "
	cQuery += "SF4.F4_FILIAL = '"+self:cFilEstoque+"' AND SD1.D1_TES = SF4.F4_CODIGO AND "
	cQuery += "SF4.F4_ESTOQUE = 'S'	AND SD1.D1_DTDIGIT >= '"+dtos(dDatabase-30)+"' AND "
	cQuery += "SD1.D1_DTDIGIT <= '"+dtos(dDatabase)+"' AND SD1.D1_ORIGLAN <> 'LF' AND "
	cQuery += "SD1.D1_LOCAL = '"+self:cLocalEstoque+"' AND SD1.D1_COD = '"+self:cCodProduto+"' AND "
	cQuery += "SD1.D_E_L_E_T_ = ' ' AND SF4.D_E_L_E_T_ = ' ' AND SB1.D_E_L_E_T_ = ' ' "
    cQuery += "UNION "
    cQuery += "SELECT 'NF_S' AS ARQ, SB1.B1_COD PRODUTO, SB1.B1_DESC DESCR, SB1.B1_UM UNID, D2_TES TES, "
	cQuery += "D2_NUMSEQ NUMSEQ, D2_DOC DOCUMENTO, D2_QUANT QUANTIDADE,	D2_EMISSAO DATAMOV "
	cQuery += "FROM "+retSqlName("SB1") + " SB1, "+retSqlName("SD2")+ " SD2, "+retSqlName("SF4") + " SF4 "
	cQuery += "WHERE SB1.B1_COD = SD2.D2_COD AND SD2.D2_FILIAL = '"+self:cFilEstoque+"'	AND "
	cQuery += "SF4.F4_FILIAL = '"+self:cFilEstoque+"' AND SD2.D2_TES = SF4.F4_CODIGO AND "
	cQuery += "SF4.F4_ESTOQUE = 'S'	AND	SD2.D2_EMISSAO >= '"+dTos(dDataBase-30)+"'	AND "
	cQuery += "SD2.D2_EMISSAO <= '"+dtos(dDataBase)+"' AND SD2.D2_ORIGLAN <> 'LF' AND "				   
	cQuery += "SD2.D2_LOCAL = '"+self:cLocalEstoque+"' AND SD2.D2_COD = '"+self:cCodProduto+"' AND "
	cQuery += "SD2.D_E_L_E_T_ = ' ' AND SF4.D_E_L_E_T_ = ' ' AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "UNION "
	cQuery += "SELECT (CASE When substring(SD3.D3_CF,1,1) = 'D' Then 'MV_E' Else 'MV_S' End) AS ARQ, "
    cQuery += "SB1.B1_COD PRODUTO, SB1.B1_DESC DESCR, SB1.B1_UM UNID, D3_CF TES, D3_NUMSEQ NUMSEQ, D3_DOC DOCUMENTO, "
    cQuery += "D3_QUANT QUANTIDADE,	D3_EMISSAO DATAMOV "
	cQuery += "FROM "+retSqlName("SB1")+ " SB1, "+retSqlName("SD3") + " SD3 "
	cQuery += "WHERE SB1.B1_COD = SD3.D3_COD AND SD3.D3_FILIAL = '"+self:cFilEstoque+"' AND "
	cQuery += "SD3.D3_EMISSAO >= '"+dTos(dDatabase-30)+"' AND SD3.D3_EMISSAO <= '"+dTos(dDataBase)+"' AND "
	cQuery += "SD3.D3_LOCAL = '"+self:cLocalEstoque+"' AND SD3.D3_COD = '"+self:cCodProduto+"' AND SD3.D3_ESTORNO <> 'S' AND "
    cQuery += "SD3.D_E_L_E_T_ = ' ' AND SB1.D_E_L_E_T_ =' ' "
	cQuery += "ORDER BY DATAMOV DESC, NUMSEQ DESC"
    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)

	conout("Consultando Movimentação de Produtos ==> "+alltrim(self:cLocalEstoque)+"  "+self:cCodProduto )

	oResponse['status'] := 200  // parâmetro que irá retornar com sucesso
	oResponse['dados']	:= {}

	nQtdeReg := 0
	(cAliasTop)->(DbGoTop())
	do While (cAliasTop)->(!Eof())

		if nQtdeReg <= 30
			oJsonCL := JsonObject():New()
		
			oJsonCL['codigoProduto']	:= alltrim((cAliasTop)->PRODUTO)
			oJsonCL['UMProduto'] 	    := alltrim((cAliasTop)->UNID)
			oJsonCL['descProduto']	    := EncodeUTF8(alltrim((cAliasTop)->DESCR) )
			oJsonCL['tipoMovimento']	:= alltrim((cAliasTop)->ARQ)
			ojsonCl['tesMovimento']     := alltrim((cAliasTop)->TES)
			oJsonCl['numSequencia']     := alltrim((cAliasTop)->NUMSEQ)
			oJsonCl['numDocumento']     := alltrim((cAliasTop)->DOCUMENTO)
			oJsonCl['quantidade']       := (cAliasTop)->QUANTIDADE
			oJsoncl['dataMovimento']    := stod((cAliasTop)->DATAMOV)

			aAdd(oResponse['dados'], oJsonCL)
			nQtdeReg++
		else
			exit			
		endif
		(cAliasTop)->(dbSkip())
	EndDo
	
    (cAliasTop)->(DbCloseArea())

	::SetResponse(oResponse:ToJson())

Return lRet 

