#include 'totvs.ch'
#include 'Restful.ch'

user function apical02()
Return

WSRESTFUL APICal02 DESCRIPTION "API Pirecal Estoques - Consulta Locais de Estoques" FORMAT "application/json,text/html" 
	WSDATA cFilEstoque  as String Optional

    WSMETHOD    GET conLocalEstoque ;
            	DESCRIPTION 'Consulta Locais de Estoques' ;
                WSSYNTAX '/APICal02/conLocalEstoque/{cFilEstoque}'    ;       
                PRODUCES APPLICATION_JSON

	WSMETHOD	POST incInventario ;
				DESCRIPTION 'Inclusão da Digitação de Inventário' ;
				WSSYNTAX '/APICal02/incInventario' ;
				PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET conLocalEstoque WSRECEIVE cFilEstoque WSRESTFUL APICal02
	Local lRet 		:= .T.
	Local oResponse	:= JsonObject():New()
    Local cQuery    := ""
	Local cEOL 		:= Chr(13)+Chr(10)

    //Retorna apenas o Tipo Json
	::SetContentType('application/json')
	
    //Query que irá retornar o Local de Estoque
    cAliasTop := GetNextAlias()
    cQuery := "SELECT NNR.NNR_CODIGO, NNR.NNR_DESCRI    	"+cEOL
    cQuery += "FROM "+retSqlName("NNR") + " NNR				"+cEOL
    cQuery += "WHERE NNR.D_E_L_E_T_ = ' '               	"+cEOL
	//cQuery += "AND NNR.NNR_FILIAL = '"+Self:cFilEstoque+"'  "+cEOL
	cQuery += "ORDER BY NNR_CODIGO      					"+cEOL
    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)

	conout("Consultando Locais de Estoques")

	oResponse['status'] := 200  // parâmetro que irá retornar com sucesso
	oResponse['dados']	:= {}

	cCodigoCL := ""
	(cAliasTop)->(DbGoTop())
	do While (cAliasTop)->(!Eof())
		oJsonCL := JsonObject():New()
		
		oJsonCL['localEstoque']	:= (cAliasTop)->NNR_CODIGO
        oJsonCl['nomeEstoque']  := EncodeUTF8(alltrim((cAliasTop)->NNR_DESCRI))
		
		aAdd(oResponse['dados'], oJsonCL)

		(cAliasTop)->(dbSkip())
	EndDo
	
    (cAliasTop)->(DbCloseArea())

	::SetResponse(oResponse:ToJson())

Return lRet 

//MV_CONTINV deverá estar como .F. para não controlar contagem
WSMETHOD POST incInventario WSRECEIVE WSSERVICE APICal02
	Local lRet 		:= .T.
	Local cJson		:= ::getContent()
	Local aRet 		:= {}
	Local oResponse, oJson
	
	::SetContentType() 
	
	conout("Movimentação para Inventário")
	
	oResponse	:= JsonObject():New()
	oJson		:= JsonObject():New()
	
	oJson:FromJson(cJson)
	
	aRet		:= restInventario(oJson)   
	
	If aRet[1]
		oResponse['status'] := aRet[3]
		oResponse['message']:= aRet[2]
		::SetResponse(oResponse:toJson())
	Else
		lRet := .F.
		SetRestFault(aRet[3], aRet[2])
	EndIf

Return lRet

Static Function restInventario(oJson)
	Local aRet 			:= {}
    Local aVetor	    := {}
    Local lMsErroAuto   := .F.
    Local nOper         := oJson["B7_OPERACAO"]

	aVetor := 	{ 	{"B7_FILIAL" , oJson["B7_FILIAL"]	, Nil	},;
					{"B7_DATA"	 , oJson["B7_DATA"]		, Nil	},;
					{"B7_DTVALID", oJson["B7_DTVALID"]	, Nil	},;
					{"B7_DOC"    , oJson["B7_DOC"]		, Nil	},;	
					{"B7_COD"	 , oJson["B7_COD"]		, Nil	},; 
					{"B7_TIPO"	 , POSICIONE("SB1",1,XFILIAL("SB1")+oJson["B7_COD"],"B1_TIPO"),Nil},;
					{"B7_LOCAL"  , oJson["B7_LOCAL"]	, Nil	},;
					{"B7_QUANT"	 , oJson["B7_QUANT"]	, Nil	},; 
					{"B7_LOTECTL", oJson["B7_LOTECTL"]	, Nil	},;
					{"INDEX"	 , 1					, Nil   } }
		
	MSExecAuto({|x,y,z| mata270(x,y,z)}, aVetor, .F., nOper)
        
    If lMsErroAuto
        RollBackSX8()

        cErro := MostraErro("\spool", cArqLog)
        cErro := TrataErro(cErro)
        aRet    := {.F., cErro, 400}
    Else
        ConfirmSx8()
        aRet    := {.T., EncodeUTF8("Movimentação Realizada com Sucesso"),200}
    EndIf    

Return(aRet)

