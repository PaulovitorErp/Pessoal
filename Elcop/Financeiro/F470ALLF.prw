#include 'protheus.ch'
#include 'parmtype.ch'

//Bibliotecas
#Include "Totvs.ch"
 
/*/{Protheus.doc} F470ALLF
Define o filtro de filial no FINR470 (Extrato Banc�rio)
@author Atilio
@since 20/11/2019
@version 1.0
@return lRet, .T. se for para trazer dados de todas as filiais e .F. se filtrar apenas a filial corrente
@type function
@see https://tdn.totvs.com/pages/releaseview.action?pageId=6071573
/*/
 
User Function F470ALLF()
    Local aArea := GetArea()
    Local lRet  := MsgYesNo("Deseja ver lan�amento de todas as filiais?", "Aten��o")
     
    RestArea(aArea)
Return lRet