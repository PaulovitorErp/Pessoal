/*
Descri��o:
O Ponto de Entrada MT110APV � executado no in�cio da fun��o A110Aprov e indica se a 
rotina de aprova��o pode ser executada.
Programa Fonte
MATA110.PRX
Sintaxe
MT110APV - Aprova��o da Solicita��o de Compras ( < cAlias> , < nReg> ) --> lRet

Recurso ser� liberado para o Usu�rio que estiver no Par�metro
MV_XLIBSOL = luiz.machado

Par�metros:
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
    else // caso seja outro produto que n�o M1-M2-M3 compras poder� realizar bloqueios 
        lRet := .T.
    endif
else
    lRet := .T.    
endif
Return(lRet)
