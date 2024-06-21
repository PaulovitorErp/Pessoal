//Bibliotecas
#Include 'Protheus.ch'
#Include 'RwMake.ch'
 
/*------------------------------------------------------------------------------------------------------*
 | P.E.:  M410PVNF                                                                                      |
 | Desc:  Valida��o na chamada do Prep Doc Sa�da no A��es Relacionadas do Pedido de Venda               |
 | Links: http://tdn.totvs.com/pages/releaseview.action�pageId=6784152                                  |
 *------------------------------------------------------------------------------------------------------*/
 
User Function M410PVNF()
    Local lRet := .T.
    Local aArea := GetArea()
    Local aAreaC5 := SC5->(GetArea())
    Local aAreaC6 := SC6->(GetArea())
     
    //Se tiver em branco o campo, n�o permite prosseguir
    If Empty(SC5->C5_ESTPRES)
        lRet := .F.
    EndIf
     
    RestArea(aAreaC6)
    RestArea(aAreaC5)
    RestArea(aArea)
Return lRet
