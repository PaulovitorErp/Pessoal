#INCLUDE 'MNTC600.CH'
#INCLUDE 'PROTHEUS.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTC600C
Browser de insumos com menu padrão

@author Maria Elisandra de Paula
@since 18/05/21
@return nil
/*/
//-------------------------------------------------------------------
Function MNTC600C()

    Local cBkpFun := FunName()
    Local aMenu   := MenuDef()

    SetFunName( 'MNTC600C' ) // Seta rotina para identificar as restrições de acesso

    MNTCOSDE2( aMenu ) // Aciona rotina principal com menu padrão do fonte

    SetFunName( cBkpFun ) // Retorna backup de nome da rotina

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Retorna menu da rotina

@author Maria Elisandra de Paula
@since 18/05/21
@return array
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

    Local aReturn := { { STR0011, 'MNT600VS()', 0, 2 } }   // 'Visualizar'

Return aReturn
