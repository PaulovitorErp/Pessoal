#INCLUDE 'MNTC600.CH'
#INCLUDE 'PROTHEUS.CH'

//--------------------------------------------------
/*/{Protheus.doc} MNC600CON
Monta um browse das manutenções do Bem

@author Maria Elisandra de paula
@since 18/05/21
@param [cCodBem], string, código do bem
@return Nil
/*/
//--------------------------------------------------
Function MNTC600A( cCodBem )
	
    Local cFuncBkp := FunName()
    Local aMenu    := MenuDef()
    
    SetFunName( 'MNTC600A' )

    MNC600CON2( cCodBem, aMenu )

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

    Local aReturn := {{ STR0011, 'MNC600FOLD', 0, 2 }} // Visualizar

Return aReturn
