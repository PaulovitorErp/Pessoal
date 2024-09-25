#include 'protheus.ch'
#include 'mntc510.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC510H
Motivos de atraso

@author Maria Elisandra de Paula
@since 26/03/2021
@return Nil
/*/
//---------------------------------------------------------------------
Function MNTC510H()

    Local cTrb      := IIf( Type( '_cTrb' ) != 'U', _cTrb, '' ) 
	Local cAliasTrb := GetNextAlias()
	Local cFuncBkp  := FunName()
    Local aMenu     := Menudef()
	Local cKey      := ''
	Local bWhile
	Local bFor

    SetFunName( 'MNTC510H' )

    Private cCadastro := STR0003 // 'Manutenção'

    If Alias() $ 'STS' .And. !Empty( STS->TS_ORDEM )

        M->TS_ORDEM := STS->TS_ORDEM

        DbSelectArea( 'TQ6' )
        DbSetOrder( 02 )

        cKey     := M->TS_ORDEM
        bWHILE 	 := {|| !Eof() .And. TQ6->TQ6_ORDEM == M->TS_ORDEM }
        bFOR     := {|| TQ6_FILIAL  == xFilial( 'TQ6' ) }
        aTrocaF3 := {}

        If Val( STS->TS_PLANO ) == 0 .And. NGUSATARPAD()
            aAdd( aTrocaF3,{ 'TT_TAREFA', 'TT9' } )
        EndIf

        NGCONSULTA( cAliasTrb, cKEY, bWHILE, bFOR, aMenu, {},,,,,,, .F. )

        DbSelectArea( 'TQ6' )
        DbSetOrder( 02 )
        aTrocaF3:= {}

    ElseIf !Empty( STJ->TJ_ORDEM ) .And. Empty( cTrb )

        M->TJ_ORDEM := STJ->TJ_ORDEM

        DbSelectArea('TPL')
        DbSetOrder(1)

        cKey := M->TJ_ORDEM

        bWHILE := {|| !Eof() .And. TPL->TPL_ORDEM == M->TJ_ORDEM }
        bFOR   := {|| TPL_FILIAL  == xFilial('TPL') }
        aTrocaF3    := {}

        If Val(STJ->TJ_PLANO) == 0 .And. NGUSATARPAD()
            aAdd( aTrocaF3, { 'TL_TAREFA', 'TT9' } )
        EndIf

        NGCONSULTA( cAliasTrb, cKEY, bWHILE, bFOR, aMenu, {},,,,,,, .F. )

        DbSelectArea('TPL')
        DbSetOrder(1)
        aTrocaF3:= {}

    ElseIf !Empty((_cTrb)->TJ_ORDEM)

        M->TJ_ORDEM := (_cTrb)->TJ_ORDEM

        DbSelectArea('TPL')
        DbSetOrder(1)

        cKey := M->TJ_ORDEM

        bWHILE := {|| !Eof() .And. TPL->TPL_ORDEM == M->TJ_ORDEM }
        bFOR   := {|| TPL_FILIAL  == xFilial('TPL') }
        aTrocaF3    := {}

        If Val((_cTrb)->TJ_PLANO) == 0 .And. NGUSATARPAD()
            aAdd( aTrocaF3, { 'TL_TAREFA', 'TT9' } )
        EndIf

        NGCONSULTA( cAliasTrb, cKEY, bWHILE, bFOR, aMenu, {},,,,,,, .F. )

        DbSelectArea('TPL')
        DbSetOrder(1)
        aTrocaF3 := {}

    EndIf

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

Return { { STR0002, 'MNTC510GE', 0, 2 } } // 'Visualizar'
