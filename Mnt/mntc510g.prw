#include 'protheus.ch'
#include 'mntc510.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC510G
Problemas da ordem

@author Maria Elisandra de Paula
@since 26/03/2021
@return Nil
/*/
//---------------------------------------------------------------------
Function MNTC510G()

	Local cAliasTrb := GetNextAlias()
	Local cFuncBkp  := FunName()
    Local aMenu     := Menudef()
	Local cKey      := ''
	Local bWhile
	Local bFor
	Local bWhile2
	Local bFor2
	Local bDBFFUNC

    SetFunName( 'MNTC510G' )

    Private cCadastro := STR0015 // 'Historico dos Problemas'

    // Garante o correto posicionamento na tabela STJ conforme registros da tabela temporária.
    If Type( '_cTrb' ) != 'U' .And. Select( _cTrb ) > 0
		
        dbSelectArea( 'STJ' )
		dbSetOrder( 4 ) // TJ_FILIAL + TJ_SERVICO + TJ_TIPOOS + TJ_CODBEM + TJ_SEQRELA + TJ_ORDEM + TJ_PLANO
		dbSeek( xFilial( 'STJ' ) + (_cTRB)->TJ_SERVICO + (_cTRB)->TJ_TIPOOS + (_cTRB)->TJ_CODBEM +;
            (_cTRB)->TJ_SEQRELA + (_cTRB)->TJ_ORDEM )
		
	EndIf

    M->TJ_ORDEM := STJ->TJ_ORDEM
    M->TJ_PLANO := STJ->TJ_PLANO
    cKey        := M->TJ_ORDEM + M->TJ_PLANO
    aTrocaF3    := {}

    dbSelectArea('STF')
    dbSetOrder(1)
    dbSeek( xFilial('STF') + STJ->TJ_CODBEM + STJ->TJ_SERVICO + STJ->TJ_SEQRELA )
    If Val( STJ->TJ_PLANO ) == 0 .And. NGUSATARPAD()
        aAdd( aTrocaF3, { 'TL_TAREFA', 'TT9' } )
    EndIf

    DbSelectArea('STV')
    DbSetOrder(01)
    bWHILE2 := {|| !Eof() .And. STV->TV_ORDEM == M->TJ_ORDEM .And. STV->TV_PLANO == M->TJ_PLANO }
    bFor2   := {|| TV_FILIAL == xFilial('STV') .And. TV_ORDEM  == M->TJ_ORDEM .And. TV_PLANO  == M->TJ_PLANO }
    bDBFFUNC := {|| NG510PROC('TA_', 'TV_', 'STV', cKey, bWHILE2, bFor2 ) }

    DbSelectArea('STA')
    DbSetOrder(01)
    bWHILE := {|| !Eof() .And. STA->TA_ORDEM == M->TJ_ORDEM .And. STA->TA_PLANO == M->TJ_PLANO }
    bFor   := {|| TA_FILIAL == xFilial('STA') .And. TA_ORDEM  == m->TJ_ORDEM .And. TA_PLANO  == m->TJ_PLANO }

    NGCONSULTA( cAliasTrb, cKey, bWHILE, bFor, aMenu, {}, bDBFFUNC,,,,,, .F. )
    DbSelectArea('STA')
    DbSetOrder(01)

    aTrocaF3:= {}

    SetFunName( cFuncBkp )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} Menudef
Menu da rotina

@author Maria Elisandra de Paula
@since 26/03/21
@return array
/*/
//---------------------------------------------------------------------
Static Function Menudef()

Return { { STR0002, 'MNTC510GE', 0, 2 } }  // 'Visualizar'
