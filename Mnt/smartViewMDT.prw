#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTSVPront
Função responsável pela chamada do Relatório e da Visão de Dados
de Prontuário Médico.

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
Função responsável pela chamada do Relatório e da Visão de Dados
de Diagnóstico Médico.

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
Função responsável pela chamada do Relatório e da Visão de Dados
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
