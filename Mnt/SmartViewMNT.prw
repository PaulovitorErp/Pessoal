#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTSVwOS
Função responsável pela chamada do Relatório e da Visão de Dados
de Ordens de Serviço no Smart View.
@type Classe
 
@author João Ricardo Santini Zandoná
@since 28/09/2023
@version P11
@return Nil
/*/
//-------------------------------------------------------------------
Function MNTSVwOS()

    Local lSuccess := .T.
    Local cError   := ''

    lSuccess := totvs.framework.treports.callTReports('ng.sv.mnt.os',,,,,.F.,,,@cError)

    If !lSuccess
        Conout(cError)
    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTSVwAba
Função responsável pela chamada do Relatório e da Visão de Dados
de Abastecimentos no Smart View.
@type Classe
 
@author João Ricardo Santini Zandoná
@since 28/09/2023
@version P11
@return Nil
/*/
//-------------------------------------------------------------------
Function MNTSVwAba()

    Local lSuccess := .T.
    Local cError   := ''

    lSuccess := totvs.framework.treports.callTReports('ng.sv.mnt.abast',,,,,.F.,,,@cError)

    If !lSuccess
        Conout(cError)
    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTSVwMul
Função responsável pela chamada do Relatório e da Visão de Dados
de Multas no Smart View.
@type Classe
 
@author João Ricardo Santini Zandoná
@since 28/09/2023
@version P11
@return Nil
/*/
//-------------------------------------------------------------------
Function MNTSVwMul()

    Local lSuccess := .T.
    Local cError   := ''

    lSuccess := totvs.framework.treports.callTReports('ng.sv.mnt.multas',,,,,.F.,,,@cError)

    If !lSuccess
        Conout(cError)
    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTSVwMulS
Função responsável pela chamada do Relatório e da Visão de Dados
de Multas Simplificado no Smart View.
@type Classe
 
@author João Ricardo Santini Zandoná
@since 28/09/2023
@version P11
@return Nil
/*/
//-------------------------------------------------------------------
Function MNTSVwMulS()

    Local lSuccess := .T.
    Local cError   := ''

    lSuccess := totvs.framework.treports.callTReports('ng.sv.mnt.multass',,,,,.F.,,,@cError)

    If !lSuccess
        Conout(cError)
    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTSVwSS
Função responsável pela chamada do Relatório e da Visão de Dados
de Solicitações de serviço no Smart View.
@type Classe
 
@author João Ricardo Santini Zandoná
@since 28/09/2023
@version P11
@return Nil
/*/
//-------------------------------------------------------------------
Function MNTSVwSS()

    Local lSuccess := .T.
    Local cError   := ''

    lSuccess := totvs.framework.treports.callTReports('ng.sv.mnt.ss',,,,,.F.,,,@cError)

    If !lSuccess
        Conout(cError)
    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTSVwPneu
Função responsável pela chamada do Relatório e da Visão de Dados
de Pneus no Smart View.
@type Classe
 
@author João Ricardo Santini Zandoná
@since 28/09/2023
@version P11
@return Nil
/*/
//-------------------------------------------------------------------
Function MNTSVwPneu()

    Local lSuccess := .T.
    Local cError   := ''

    lSuccess := totvs.framework.treports.callTReports('ng.sv.mnt.pneus',,,,,.F.,,,@cError)

    If !lSuccess
        Conout(cError)
    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTSVwMANAVENC
Função responsável pela chamada do Relatório e da Visão de Dados
de Manutenções a Vencer no Smart View.
@type Classe
 
@author João Ricardo Santini Zandoná
@since 11/01/2023
@version P11
@return Nil
/*/
//-------------------------------------------------------------------
Function MNTSVwMANAVENC()

    Local lSuccess := .T.
    Local cError   := ''

    lSuccess := totvs.framework.treports.callTReports('ng.sv.mnt.manutavenc',,,,,.F.,,,@cError)

    If !lSuccess
        Conout(cError)
    EndIf

Return
