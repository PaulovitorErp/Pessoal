/* Ponto de Entrada para Marcar o Flag de Multi Naturezas quando
    o T�tulo for inclu�do como Multi Naturezas 

UTILIZA��O: FINA750 -> FINA080
*/    
#INCLUDE "protheus.ch"

user function F080MNAT()
local lRet := .F.

if (SE2->E2_PREFIXO $ "MAN" .AND. alltrim(SE2->E2_TIPO) $ "RC-TX-BOL-FT-TF-CT") .or. (SE2->E2_PREFIXO $ "IOF-JUR")
    if SE2->E2_MULTNAT <> "1"
        lRet := .F.
    else
        lRet := .T.
    endif
endiF
return(lRet)
 