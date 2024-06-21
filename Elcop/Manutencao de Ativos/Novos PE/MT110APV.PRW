/*
Descrição:
O Ponto de Entrada MT110APV é executado no início da função A110Aprov e indica se a 
rotina de aprovação pode ser executada.
Programa Fonte
MATA110.PRX
Sintaxe
MT110APV - Aprovação da Solicitação de Compras ( < cAlias> , < nReg> ) --> lRet

Recurso será liberado para o Usuário que estiver no Parâmetro
MV_XLIBSOL = luiz.machado

Parâmetros:
*/

User Function MT110APV 
//Local cParam1:=ParamIxb[1]
//Local nParam2:=ParamIxb[2]
Local lRet  :=.F.
Local cTipo := Posicione("SB1",1,XFILIAL("SB1")+SC1->C1_PRODUTO,"B1_TIPO")

if SC1->C1_APROV = "B"
    if cTipo $ "M1-M2-M3" 
        if UPPER(alltrim(cUserName)) $ UPPER(GETMV("MV_XLIBSOL"))
            lRet := .T.
        else
            lRet := .F.
        endif
    else // caso seja outro produto que não M1-M2-M3 compras poderá realizar bloqueios 
        lRet := .T.
    endif
else
    lRet := .T.    
endif
Return(lRet)
