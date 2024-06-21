#include 'protheus.ch'
#include 'Restful.ch'

WSRESTFUL apical03 DESCRIPTION "API Pirecal Estoques - Consulta Usuários" FORMAT "application/json,text/html" 
	WSDATA cCodigo  as String 

	WSMETHOD    GET  conUsuarios ;
                DESCRIPTION 'Consulta Usuários' ;
                WSSYNTAX '/apical03/conUsuarios/{cCodigo}' ;
                PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET conUsuarios WSRECEIVE cCodigo WSRESTFUL apical03
	Local lRet 		:= .T.
	Local oResponse	:= JsonObject():New()
    Local cQuery    := ""
	Local cEOL 		:= Chr(13)+Chr(10)
    Local lExist    := .F.
	
	/*
    obrigatorio informar o Código do usuário
    */
    IF Empty(Self:cCodigo)
        SetRestFault(400,EncodeUTF8('O Parâmetro Código é obrigatório'))
        lRet    := .F.
        Return(lRet)
    EndIF

    //Retorna apenas o Tipo Json
	::SetContentType('application/json')
	
    //Query que irá retornar o Check-list
    cAliasTop := GetNextAlias()

    if SELECT(cAliasTop) > 0
        (cAliasTop)->(DbCloseArea())
    endif

    cQuery := "SELECT SZE.SZE_CODUSR, SZE.SZE_FILUSR, SZE.SZE_USERID, SZE.SZE_NOME, SZE.SZE_CC, "+cEOL
    cQuery += "SZE.SZE_LOCAL, SZE.SZE_NOMSOL, SZE.SZE_SENHA                                     "+cEOL                    
    cQuery += "FROM "+retSqlName("SZE") + " SZE                                                 "+cEOL
    cQuery += "WHERE SZE.D_E_L_E_T_ = ' '                                                       "+cEOL
    cQuery += "AND SZE.SZE_CODUSR = '"+self:cCodigo+"'                                          "+cEOL
    cQuery += "AND SZE.SZE_ATIVO = 'S'                                                          "+cEOL
    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)

	conout("Consulta Usuário")

    oResponse['status']     := 200  // parâmetro que irá retornar com sucesso
    oResponse['usuario']	:= {}

    (cAliasTop)->(DbGoTop())
    do While (cAliasTop)->(!Eof())

        oJson := JsonObject():New()
            
        oJson['filialUsuario']	    := alltrim((cAliasTop)->SZE_FILUSR)
        oJson['usuarioProtheus'] 	:= alltrim((cAliasTop)->SZE_USERID)
        oJson['nomeUsuario']        := EncodeUTF8(alltrim((cAliasTop)->SZE_NOME))
        oJson['centroCusto']        := alltrim((cAliasTop)->SZE_CC)
        oJson['localUsuario']       := (cAliasTop)->SZE_LOCAL
        oJson['nomeSolicitante']    := alltrim((cAliasTop)->SZE_NOMSOL)
        oJson['senhaUsuario']       := alltrim((cAliasTop)->SZE_SENHA)

        aAdd(oResponse['usuario'], oJson)
        
        lExist := .T.

        (cAliasTop)->(dbSkip())
    EndDo

    if lExist
        ::SetResponse(oResponse:ToJson())
        lRet := .T.
	else
		lRet := .F.
		SetRestFault(400, EncodeUTF8("Usuário Não Cadastrado"))
    endif	

    (cAliasTop)->(dbCloseArea())
    
Return lRet 
