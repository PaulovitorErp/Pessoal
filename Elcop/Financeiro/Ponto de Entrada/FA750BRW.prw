#Include "Protheus.ch"
 
/*------------------------------------------------------------------------------------------------------*
 | P.E.:  FA750BRW                                                                                      |
 | Desc:  Adiciona a��es relacionadas no Fun��es Contas a Pagar                                         |
 | Links: http://tdn.totvs.com/pages/releaseview.action�pageId=6071251                                  |
 *------------------------------------------------------------------------------------------------------*/
 
User Function FA750BRW()
    Local aRotina:={}
    aAdd(aRotina, { "Consul. Multas"    , "MNTA765" , 0 , 4,15,NIL})
Return aRotina