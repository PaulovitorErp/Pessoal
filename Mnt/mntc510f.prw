#include 'protheus.ch'
#include 'mntc510.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC510F
Etapas da ordem

@author Inacio Luiz Kolling
@since 02/07/97
@obs refeito por Maria Elisandra de Paula em 24/03/2021
@return Nil
/*/
//---------------------------------------------------------------------
Function MNTC510F()

	Local cAliasTrb := GetNextAlias()
	Local cFuncBkp  := FunName()
    Local aMenu     := Menudef()
	Local cKey      := ''
    Local cKeyTX    := ''
	Local bWhile
	Local bFor
	Local bWhile2
	Local bFor2
	Local bDBFFUNC

    SetFunName( 'MNTC510F' )

	Private cCadastro := STR0021 // 'Historico das Etapas'

    If Type( '_cTrb' ) <> 'U' .And. Select( _cTrb ) > 0
        DbSelectArea('STJ')
        DbSetOrder(1) //TJ_FILIAL+TJ_ORDEM+TJ_PLANO+TJ_TIPOOS+TJ_CODBEM+TJ_SERVICO+TJ_SEQRELA
        DbSeek( xFilial('STJ') + (_cTrb)->TJ_ORDEM + (_cTrb)->TJ_PLANO + (_cTrb)->TJ_TIPOOS + (_cTrb)->TJ_CODBEM )
    EndIf

    M->TJ_ORDEM := STJ->TJ_ORDEM
    M->TJ_PLANO := STJ->TJ_PLANO
    cKeyTX      := M->TJ_ORDEM+M->TJ_PLANO
    cKey        := M->TJ_ORDEM+M->TJ_PLANO
    aTrocaF3    := {}

    If Val( STJ->TJ_PLANO ) == 0 .And. NGUSATARPAD()
        aAdd( aTrocaF3, { 'TL_TAREFA', 'TT9' } )
    EndIf

    DbSelectArea('STX')
    DbSetOrder(01)
    bWhile2  := {|| !Eof() .And. STX->TX_ORDEM == M->TJ_ORDEM .And. STX->TX_PLANO == M->TJ_PLANO }
    bFor2    := {|| TX_FILIAL == xFilial('STX') .And. TX_ORDEM   == M->TJ_ORDEM .And. TX_PLANO == M->TJ_PLANO }
    bDBFFUNC := {|| NG510PROC( 'TQ_', 'TX_', 'STX', cKeyTX, bWhile2, bFor2 ) }

    DbSelectArea('STQ')
    DbSetOrder(01)
    bWhile := {|| !Eof() .And. STQ->TQ_ORDEM == M->TJ_ORDEM .And. STQ->TQ_PLANO == M->TJ_PLANO }
    bFor   := {|| TQ_FILIAL  == xFilial("STQ") .And. TQ_ORDEM   == M->TJ_ORDEM .And. TQ_PLANO == M->TJ_PLANO }

    NGCONSULTA( cAliasTrb, cKey, bWhile, bFor, aMenu, {}, bDBFFUNC,,,,,, .F. )

    DbSelectArea('STQ')
    DbSetOrder(01)

    aTrocaF3:= {}

    SetFunName( cFuncBkp )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} Menudef
Menu da rotina

@author Inacio Luiz Kolling
@since 02/07/97
@obs refeito por Maria Elisandra de Paula em 26/03/2021
@return array
/*/
//---------------------------------------------------------------------
Static Function Menudef()

    Local aMenu := { { STR0002, 'MNTC510GE', 0, 2 },; // 'Visualizar'
                    { STR0022, 'TPQRespos', 0, 4 } }  // 'Resposta Etapa'

Return aMenu
