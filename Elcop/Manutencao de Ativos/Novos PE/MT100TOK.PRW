/*
Descrição:
LOCALIZAÇÃO : Function A103Tudok()

EM QUE PONTO : Este P.E. é chamado na função A103Tudok()
Pode ser usado para validar a inclusao da NF.

Esse Ponto de Entrada é chamado 2 vezes dentro da rotina A103Tudok(). 
Para o controle do número de vezes em que ele é chamado foi criada a variável lógica 
lMT100TOK, que quando for definida como (.F.) o ponto de entrada será chamado somente uma vez.
Programa Fonte
MATA103.PRW
Sintaxe
MT100TOK - Valida a inclusão de NF ( < UPAR> ) --> lRet

Parâmetros:
*/
#include "totvs.ch"

user function MT100TOK()
    Local lRet          := .T.
    //Local cCodPro       := aCols[n,AScan(aHeader, {|x| AllTrim(x[2]) == "D1_COD"})]
    //Local cTipForn      := Posicione("SA2",1,XFILIAL("SA2")+CA100FOR+CLOJA,"A2_XTIPO")//retirado Validação 21/01/2024
    Local nIQF          := Posicione("SA2",1,XFILIAL("SA2")+CA100FOR+CLOJA,"A2_XIQF")
    Local nDoc          := Posicione("SA2",1,XFILIAL("SA2")+CA100FOR+CLOJA,"A2_XNOTDOC")
    Local nLicenc       := Posicione("SA2",1,XFILIAL("SA2")+CA100FOR+CLOJA,"A2_XNOTLIC")

    Local dDtaBloq  := Posicione("SA2",1,XFILIAL("SA2")+CA100FOR+CLOJA,"A2_XDTBIQF")

    /*if Posicione("SB1",1,xFilial("SB1")+cCodPro,"B1_TIPO") $ "M1-M2-M3"
        if aCols[n,AScan(aHeader, {|x| AllTrim(x[2]) == "D1_XNOTREC"})] == " "
            MsgAlert("Campo Qualid Receb é obrigatório, para os Tipos de Produtos M1, M2 ou M3","Preencher Campo")
            lRet := .F.
        endif
    endif*///Retirado Validação 09/01/2024

    /*if cTipForn == "O" 
    
        if nIQF = 0 .and. (nDoc > 0 .or. nLicenc > 0 )
            lRet := .T.
        else
            if nIQF <= 50
                if (dDtaBloq + 60) <= dDatabase
                    ZCX->(DbSetOrder(1))
                    if ZCX->(dbSeek(xFilial("ZCX")+CA100FOR+CLOJA))
                        if !(dDatabase >= ZCX->ZCX_DATINI .and. dDatabase <= ZCX->ZCX_DATFIN)
                            msginfo("Fornecedor Bloqueado para Compras IQF <= 50","Bloqueio")
                            lRet := .F.
                        endif
                    else
                        msginfo("Fornecedor Bloqueado para Compras IQF <= 50","Bloqueio")
                        lRet := .F.
                    endif
                else
                    lRet := .T.                
                endif
            elseif nIQF > 50 .and. nIQF <= 59
                    if (dDtaBloq + 30) <= dDatabase
                        ZCX->(DbSetOrder(1))
                        if ZCX->(dbSeek(xFilial("ZCX")+CA100FOR+CLOJA))
                            if !(dDatabase >= ZCX->ZCX_DATINI .and. dDatabase <= ZCX->ZCX_DATFIN)
                                msginfo("Fornecedor Bloqueado para Compras IQF <= 50","Bloqueio")
                                lRet := .F.
                            endif
                        else
                            msginfo("Fornecedor Bloqueado para Compras IQF <= 50","Bloqueio")
                            lRet := .F.
                        endif
                    else
                        lRet := .T.                
                    endif
            endif
        endif
    endif*///retirado Validação 21/01/2024
return(lRet)
