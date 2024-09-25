#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} SGASVAsproc
Fun��o respons�vel pela chamada do Relat�rio e da Vis�o de Dados
de Aspectos por Processos.
 
@author Matheus Wilbert
@since 06/12/2023
@version P11
@return Nil
/*/
//-------------------------------------------------------------------
Function SGASVAsproc()

    Local lSuccess := .T.
    Local cError   := ''

    lSuccess := totvs.framework.treports.callTReports('ng.sv.sga.aspectosporprocessos',,,,,.F.,,,@cError)

    If !lSuccess
        Conout(cError)
    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SGASVCrit
Fun��o respons�vel pela chamada do Relat�rio e da Vis�o de Dados
de Diagn�stico M�dico.
 
@author Matheus Wilbert
@since 06/12/2023
@version P11
@return Nil
/*/
//-------------------------------------------------------------------
Function SGASVCrit()

    Local lSuccess := .T.
    Local cError   := ''

    lSuccess := totvs.framework.treports.callTReports('ng.sv.sga.aspectosporcriticidade',,,,,.F.,,,@cError)

    If !lSuccess
        Conout(cError)
    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SGASVDes
Fun��o respons�vel pela chamada do Relat�rio e da Vis�o de Dados
de Hist�rico Desempenho.
 
@author Eloisa Anibaletto
@since 03/05/2024
@version P11
@return Nil
/*/
//-------------------------------------------------------------------
Function SGASVDes()

    Local lSuccess := .T.
    Local cError   := ''

    lSuccess := totvs.framework.treports.callTReports('ng.sv.sga.historicodesempenho',,,,,.F.,,,@cError)

    If !lSuccess
        Conout(cError)
    EndIf

Return
