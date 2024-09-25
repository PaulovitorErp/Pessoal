#INCLUDE "mnta295.ch"
#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA295B
Visualiza Ordens de Servi�o

@author Cau� Girardi Petri
@since 05/02/2024

/*/
//-------------------------------------------------------------------

Function MNTA295A()

    Local cBkpFun := FunName()
    Local aRotinaBkp := aRotina

    aRotina := MenuDef()

    SetFunName( 'MNTA295A' )

	dbSelectArea("STJ")
	dbSetOrder(01)
	dbSeek(xFilial("STJ")+(cTRBC295)->ORDEM+(cTRBC295)->PLANO)

	NGCAD01("STJ",Recno(),2)

    SetFunName( cBkpFun )

    aRotina := aRotinaBKP

Return
