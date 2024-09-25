#INCLUDE 'MNTA080.CH'
#INCLUDE 'PROTHEUS.CH'

//--------------------------------------------------------------------
/*/{Protheus.doc} MNA080CON
Aciona função para montar um browse das ordens de servico

@param cCodbem, string, código do bem
@author Maria Elisandra de Paula
@since 18/05/21
@return boolean
/*/
//--------------------------------------------------------------------
Function MNTA080A( cCodbem )

    Local cBkpFun := FunName()
    Local aMenu   := MenuDef()

    SetFunName( 'MNTA080A' )

    MNA080CON2( cCodbem, aMenu )

    SetFunName( cBkpFun )

Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu da rotina

@author Maria Elisandra de Paula
@since 18/05/21
@return array
/*/
//--------------------------------------------------------------------
Static Function MenuDef()


    Local aReturn := {{STR0004,"MNTA080PE" , 0, 1},; //"Pesquisar"
                    {STR0005,"MNT080STF" , 0, 2},; //"Visualizar"
                    {STR0011,"OS080HIST" , 0, 3}}  //"Historico"


Return aReturn
