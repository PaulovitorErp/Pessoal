#INCLUDE 'mnta340c.ch'
#INCLUDE 'protheus.ch'

//---------------------------------------------------------------------------
/*/{Protheus.doc} MNTA340C
Browse de O.S. liberadas com sucesso.
@type function

@author Alexandre Santos
@since 18/03/2022
/*/
//---------------------------------------------------------------------------
Function MNTA340C()
    
    Local aAreaAT      := GetArea()
    Local oBrowse      := Nil
    
    Private aRotina    := MenuDef()
    
    SetFunName( 'MNTA340C' ) // Assume a funÁ„o posicionada como principal

    oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( 'STJ' )
	oBrowse:SetDescription( STR0001 + Space( 1 ) + STI->TI_PLANO ) // O.S. liberadas para o plano XXXXXX
	oBrowse:SetFilterDefault( 'STJ->TJ_PLANO == STI->TI_PLANO' )
	oBrowse:Activate()

    SetFunName( 'MNTA340' ) // Retorna a funÁ„o chamadora como principal

    RestArea( aAreaAT )

Return

//---------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional
@type function

@author Alexandre Santos
@since 15/03/2022

@return aRotina, array, [1] - Nome apresentado no cabe√ßalho.
						[2] - Rotina associada.
						[3] - Reservado.
						[4] - Tipo de transa√ß√£o a ser efetuada:
							1 - Pesquisa e Posiciona em um Banco de Dados
      						2 - Simplesmente Mostra os Campos
      						3 - Inclui registros no Bancos de Dados
      						4 - Altera o registro corrente
      						5 - Remove o registro corrente do Banco de Dados
      					[5] - Nivel de acesso.
      					[6] - Habilita menu funcional.
/*/
//---------------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {  { STR0002, 'NGCAD01' , 0, 2 },; // Vis. O.S. plano
						{ STR0003, 'MNTA340B', 0, 2 } } // Liber. Planos
			
Return aRotina
