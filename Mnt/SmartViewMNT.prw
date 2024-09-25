#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTSVwOS
Fun��o respons�vel pela chamada do Relat�rio e da Vis�o de Dados
de Ordens de Servi�o no Smart View.
@type Classe
 
@author Jo�o Ricardo Santini Zandon�
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
Fun��o respons�vel pela chamada do Relat�rio e da Vis�o de Dados
de Abastecimentos no Smart View.
@type Classe
 
@author Jo�o Ricardo Santini Zandon�
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
Fun��o respons�vel pela chamada do Relat�rio e da Vis�o de Dados
de Multas no Smart View.
@type Classe
 
@author Jo�o Ricardo Santini Zandon�
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
Fun��o respons�vel pela chamada do Relat�rio e da Vis�o de Dados
de Multas Simplificado no Smart View.
@type Classe
 
@author Jo�o Ricardo Santini Zandon�
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
Fun��o respons�vel pela chamada do Relat�rio e da Vis�o de Dados
de Solicita��es de servi�o no Smart View.
@type Classe
 
@author Jo�o Ricardo Santini Zandon�
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
Fun��o respons�vel pela chamada do Relat�rio e da Vis�o de Dados
de Pneus no Smart View.
@type Classe
 
@author Jo�o Ricardo Santini Zandon�
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
Fun��o respons�vel pela chamada do Relat�rio e da Vis�o de Dados
de Manuten��es a Vencer no Smart View.
@type Classe
 
@author Jo�o Ricardo Santini Zandon�
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
