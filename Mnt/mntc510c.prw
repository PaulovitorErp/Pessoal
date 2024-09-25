#include 'protheus.ch'
#include 'mntc510.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC510C
Manutenções stf - busca pela st9

@author Maria Elisandra de Paula
@since 26/03/21
@type function
/*/
//---------------------------------------------------------------------
Function MNTC510C()

    Local cAliasTrb := GetNextAlias()
    Local cFuncBkp  := FunName()
    Local aMenu     := Menudef()
    Local bWhile
    Local bFor

    SetFunName( 'MNTC510C' )

    DbSelectArea( 'STF' )
    DbSetOrder(1)

    bWhile   := {|| !Eof() .And. STF->TF_CODBEM == ST9->T9_CODBEM}
    bFor     := {|| TF_FILIAL == xFilial( 'STF' ) .And. TF_CODBEM == ST9->T9_CODBEM}

    NGCONSULTA( cAliasTrb, ST9->T9_CODBEM, bWhile, bFor, aMenu, {},,,,,,, .F. )
    DbSelectArea( 'STF' )
    DbSetOrder(1)

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

    Local aRotina := {{ STR0002, 'MNC600FOLD', 0, 2 },; // 'Visualizar'
			          { STR0004, 'OsHistori' , 0, 3 } }  // 'Historico'

Return aRotina
