/*
Descrição:
O ponto entrada F240MARK altera as posições dos campos de tela MarkBrowse fonte (FINA240.prx)
Programa Fonte
FINA240.PRX
Sintaxe
F240MARK - Altera posição de campos em FINA240. ( [ ] ) --> aRet
*/

#include "PROTHEUS.CH"

user function F240MARK 
    Local aArea     := GetArea()
    Local aRetClone := PARAMIXB
    Local aCamposPri:= {"E2_OK", "E2_FILIAL", "E2_NUM", "E2_TIPO", "E2_NOMFOR", "E2_FORNECE", "E2_LOJA","E2_VENCREA","E2_VALOR"}
    Local aRet      := {}
    Local nPos      := 1
    Local nPosPri   := 1

    for nPosPri := 1 to len(aCamposPri)
        for nPos := 1 to len(aRetClone)
            if aCamposPri[nPosPri] = alltrim(aRetClone[nPos][1])
                aAdd(aRet, {aRetClone[nPos][1], aRetClone[nPos][2], aRetClone[nPos][3], aRetClone[nPos][4] })
            endif
        next
    next 

    for nPos := 1 to len(aRetClone)
        if Ascan(aCamposPri, alltrim(aRetClone[nPos][1]) )== 0 
            aAdd(aRet, {aRetClone[nPos][1], aRetClone[nPos][2], aRetClone[nPos][3], aRetClone[nPos][4] })
        endif
    next

    RestArea(aArea)

Return(aRet)
