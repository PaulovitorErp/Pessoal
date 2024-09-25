#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTSVPront
Fun��o respons�vel pela chamada do Relat�rio e da Vis�o de Dados
de Prontu�rio M�dico.

@author Eloisa Anibaletto
@since 05/12/2023
/*/
//-------------------------------------------------------------------
Function MDTSVPront()

    Local lSuccess := .T.
    Local cError   := ''

    lSuccess := totvs.framework.treports.callTReports( 'ng.sv.mdt.prontuariomedico',,,,,.F.,,,@cError )

    If !lSuccess
        Conout( cError )
    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTSVDiagn
Fun��o respons�vel pela chamada do Relat�rio e da Vis�o de Dados
de Diagn�stico M�dico.

@author Eloisa Anibaletto
@since 05/12/2023
/*/
//-------------------------------------------------------------------
Function MDTSVDiagn()

    Local lSuccess := .T.
    Local cError   := ''

    lSuccess := totvs.framework.treports.callTReports( 'ng.sv.mdt.diagnostico',,,,,.F.,,,@cError )

    If !lSuccess
        Conout( cError )
    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTSVAso
Fun��o respons�vel pela chamada do Relat�rio e da Vis�o de Dados
do ASO.

@author Eloisa Anibaletto
@since 06/12/2023
/*/
//-------------------------------------------------------------------
Function MDTSVAso()

    Local lSuccess := .T.
    Local cError   := ''

    lSuccess := totvs.framework.treports.callTReports( 'ng.sv.mdt.atestadoaso.default.dg',,,,,.F.,,,@cError )

    If !lSuccess
        Conout( cError )
    EndIf

Return
