#INCLUDE 'MNTC600.CH'
#INCLUDE 'PROTHEUS.CH'

//--------------------------------------------------
/*/{Protheus.doc} MNTC600D
Monta um browse ocorrências da ordem

@author Maria Elisandra de paula
@since 18/05/21
@return Nil
/*/
//--------------------------------------------------
Function MNTC600D()
	
    Local cFuncBkp := FunName()
    Local aMenu    := MenuDef()
    
    SetFunName( 'MNTC600D' )

    MNTCOCOR2( aMenu )

    SetFunName( cFuncBkp )

Return 

//--------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu da rotina

@author Maria Elisandra de paula
@since 18/05/21
@return array
/*/
//--------------------------------------------------
Static Function MenuDef()

    Local aReturn := { { STR0011, 'NGVISUAL(,,, "NGCAD01" )', 0, 2 } } // Visualizar 

Return aReturn
