#INCLUDE 'MNTC605.CH'
#INCLUDE 'PROTHEUS.CH'

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC605A
Monta um browse das manutencoes do Bem

@author Inacio Luiz Kolling
@since 02/07/97
@obs refeito por Maria Elisandra de Paula em 24/03/2021
@return Nil
/*/
//---------------------------------------------------------------------
Function MNTC605A()

    Local cAliasTrb := GetNextAlias()
    Local cFuncBkp  := FunName()
    Local aMenu     := Menudef()
    Local bWhile
    Local bFor

    SetFunName( 'MNTC605A' )

    Private cCadastro := OEMTOANSI( STR0005 ) // 'Manutencoes do Bem'

    dbSelectArea('STF')
    dbSetOrder(1)

    bWhile := {|| !Eof() .AND. STF->TF_CODBEM == ST9->T9_CODBEM}
    bFor   := {|| TF_FILIAL  == xFilial('STF') }

    NGCONSULTA( cAliasTrb, ST9->T9_CODBEM, bWhile, bFor, aMenu, {},,,,,,, .F. )

    dbSelectArea('STF')
    dbSetOrder(1)

    SetFunName( cFuncBkp )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} Menudef
Menu da rotina

@author Maria Elisandra de Paula
@since 24/03/2021
@return array
/*/
//---------------------------------------------------------------------
Static Function Menudef()

Return { { STR0002, 'MNC600FOLD', 0, 2 } }  // 'Visualizar'
