#include "TOTVS.CH"

user function MT131FOR()
    Local aForn     := aClone(ParamIxb)
    Local aFornNew  := {}
    Local aFornRet  := {}
    Local aItem
    Local nIQF      := 0
//			aadd(aFornec,{ aUltFor[nCntFor][1],aUltFor[nCntFor][2],aUltFor[nCntFor][3],"SA2",SA2->(Recno())})

    for aItem := 1 to len(aForn[1])

        nIQF := Posicione("SA2",1,XFILIAL("SA2")+aForn[1][aitem][1]+aForn[1][aItem][2],"A2_XIQF")

        aAdd( aFornNew, { aForn[1][aitem][1], aForn[1][aItem][2], aForn[1][aItem][3], "SA2", aForn[1][aItem][4] })

    next

    aAdd(aFornRet,aFornNew)

return(aFornRet[1])
