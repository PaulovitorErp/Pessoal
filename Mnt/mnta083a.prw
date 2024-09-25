#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'MNTA080.CH'

//----------------------------------------------------------------------------------------
/*/{Protheus.doc} MNTA083A
Aciona browser de histórico de sulco ou status de pneu

@author Maria Elisandra de Paula
@since 14/05/2021

@param cTire, string, código do pneu
@param cTable, string, tabela a ser apresentada
@param cFilter, string, filtro do browser
@param cDesc, string, descrição da rotina

@return boolean
/*/
//----------------------------------------------------------------------------------------
Function MNTA083A( cTire, cTable, cFilter, cDesc )

    Local cFuncBkp := FunName()
	Local aMenu    := MenuDef()
	Local lOk      := .F.

    SetFunName( 'MNTA083A' )

	lOk := MNTA080SU2( cTire, cTable, cFilter, cDesc, aMenu )

    SetFunName( cFuncBkp )

Return lOk

//------------------------------------------
/*/{Protheus.doc} MenuDef
Opções do menu

@author NG Informática Ltda.
@since 01/01/2015
@return array
/*/
//------------------------------------------
Static Function MenuDef()

    Local aReturn:= { { STR0005 , 'NGCAD01' , 0 , 2 } } // 'Visualizar'

Return aReturn
