#INCLUDE 'MNTA471.ch'
#INCLUDE 'TOTVS.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA471
Movimentacao de bens.
@type function

@author	Alexandre Santos
@since	26/03/2019

@return Nil
/*/
//---------------------------------------------------------------------
Function MNTA471()

	Local aNGBeginPrm := {}

	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 19, 95 )

		aNGBeginPrm       := NGBeginPrm() // Guarda conteudo e declara variaveis padroes

		Private cCadastro := OemToAnsi( STR0001 ) // Cadastro de Bens
		Private aRotina   := MenuDef()

		dbSelectArea( 'ST9' )
		dbSetOrder( 1 )

		mBrowse( 6, 1, 22, 75, 'ST9',,,,,,,,,,,,,, "T9_MOVIBEM = 'S'" )

		dbSelectArea('ST9')
		Set Filter To

		NGReturnPrm( aNGBeginPrm )

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de Menu Funcional.
@type static

@author	Alexandre Santos
@since	25/03/2019

@return Array,  [1] - Nome que é apresentado no cabeçalho.
				[2] - Nome da rotina associada.
				[3] - Reservado.
				[4] - Tipo de transação a ser efetuada.
				[5] - Nível de acesso.
				[6] - Habilita menu funcional.
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina :={ { STR0002, 'NGCAD01' , 0, 2 },; // Visualizar
					  { STR0003, 'MNTA470' , 0, 2 } } // Movimentação

Return aRotina
