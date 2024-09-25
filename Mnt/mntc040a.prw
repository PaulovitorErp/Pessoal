#INCLUDE 'MNTC040.CH'
#INCLUDE 'PROTHEUS.CH'

//--------------------------------------------------
/*/{Protheus.doc} MNTC040A
Monta um browse dos Motivos de Atraso da O.S

@author Maria Elisandra de paula
@since 18/05/21
@return Nil
/*/
//--------------------------------------------------
Function MNTC040A()
	
    Local cFuncBkp := FunName()
    Local aMenu    := MenuDef()

    SetFunName( 'MNTC040A' )

    NGATRASOS2( aMenu )

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

    Local aReturn := { { STR0010, 'NGVISUAL(,,, "NGCAD01" )', 0, 2 } } // Visualizar 

Return aReturn
