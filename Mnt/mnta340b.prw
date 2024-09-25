#INCLUDE 'mnta340b.ch'
#INCLUDE 'protheus.ch'

//---------------------------------------------------------------------------
/*/{Protheus.doc} MNTA340B
Browse de O.S. liberadas em outros planos
@type function

@author Alexandre Santos
@since 15/03/2022
/*/
//---------------------------------------------------------------------------
Function MNTA340B()
    
    Local aAreaAP      := GetArea()
    Local aTRB2        := {}
    Local cCall        := FunName()
    
    Private cCadastro  := STR0001 // O.S. liberadas em outros planos
    Private aRotina    := MenuDef()
    
    SetFunName( 'MNTA340B' ) // Assume a função posicionada como principal

    aAdd( aTRB2, { STR0002, 'ORDEM'  , 'C', 06, 0, '@!' } ) // Ordem
    aAdd( aTRB2, { STR0003, 'PLANO'  , 'C', 06, 0, '@!' } ) // Plano
    aAdd( aTRB2, { STR0004, 'CODBEM' , 'C', 16, 0, '@!' } ) // Bem
    aAdd( aTRB2, { STR0005, 'SERVICO', 'C', 06, 0, '@!' } ) // Serviço
    aAdd( aTRB2, { STR0006, 'SEQRELA', 'C', 03, 0, '@!' } ) // Sequ~encia
    aAdd( aTRB2, { STR0007, 'ORDEML' , 'C', 06, 0, '@!' } ) // O.S. Liberada
    aAdd( aTRB2, { STR0008, 'PLANOL' , 'C', 06, 0, '@!' } ) // Plano Liberado
    aAdd( aTRB2, { STR0009, 'DTORIGI', 'D', 08, 0, '99/99/99' } ) // Data Orig

    MBrowse( 6, 1, 22, 75, cTRBZ, aTRB2 )

    SetFunName( cCall ) // Retorna a função chamadora como principal

    RestArea( aAreaAP )

Return

//---------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional
@type function

@author Alexandre Santos
@since 15/03/2022

@return aRotina, array, [1] - Nome apresentado no cabeÃ§alho.
						[2] - Rotina associada.
						[3] - Reservado.
						[4] - Tipo de transaÃ§Ã£o a ser efetuada:
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

	Local aRotina := {  { STR0010, 'NGPESQTRB( cTRBZ, { cChavTr }, 33, cPesq )'   , 0, 1 },; // Pesquisar
						{ STR0011, 'MNT340VL( (cTRBZ)->ORDEM + (cTRBZ)->PLANO )'  , 0, 2 },; // Vis. O.S. Plano
                        { STR0012, 'MNT340VL( (cTRBZ)->ORDEML + (cTRBZ)->PLANOL )', 0, 2 },; // Vis. O.S. Liber.
                        { STR0013, 'MNT340IL'                                     , 0, 4 } } // Imprimir
			
Return aRotina
