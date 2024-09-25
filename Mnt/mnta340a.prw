#INCLUDE 'mnta340a.ch'
#INCLUDE 'protheus.ch'

//---------------------------------------------------------------------------
/*/{Protheus.doc} MNTA340A
Confirmação individual do plano de manutenção.
@type function

@author Alexandre Santos
@since 15/03/2022
/*/
//---------------------------------------------------------------------------
Function MNTA340A()

	Local aDbf         := {}
	Local oTmpTbl1
	Local oTmpTbl2
	Local oTmpTbl3
	Local oTmpTbl4
	Local oTmpTbl5

	Private cTRBZ	   := GetNextAlias()
	Private cTRBW	   := GetNextAlias()
	Private cTRB340	   := GetNextAlias()
	Private cTRBSTA340 := GetNextAlias()
	Private cTRBSTK340 := GetNextAlias()
	Private cORDEMSTJ  := Space( Len( STJ->TJ_ORDEM ) )
	Private aRotina    := MenuDef()

	M->TI_PLANO   := STI->TI_PLANO
	M->TI_DATAPLA := STI->TI_DATAPLA
	aSIM          := {}

	SetFunName( 'MNTA340A' ) // Assume a função posicionada como principal

    /*------------------------------------------------------------+
    | Gera as tabelas temporarias para o processo de confirmação. |
    +------------------------------------------------------------*/
    MNTA340TRB( @oTmpTbl1, @oTmpTbl2, @oTmpTbl3, @oTmpTbl4, @oTmpTbl5, @aDbf )

    /*-----------------------------------------------+
    | Carrega as infrmações nas tabelas temporarias. |
    +-----------------------------------------------*/
    Processa( { |lEnd| NG340TRB( 3 ) } )

	MV_PAR01 := 1
	lCONT    := .T.
	MV_AUX   := MV_PAR01
	cMarca   := GetMark()
	lINVERTE := .F.
	lMARCA   := .T.

	/*-------------------------------------------------------------+
    | Cria markbrowse para escolher as ordens que serão liberadas. |
    +-------------------------------------------------------------*/
	MNTA340DLG( aDbf, cMarca, cTRB340 )

	/*-----------------------------------+
    | Grava as infrmações em definitivo. |
    +-----------------------------------*/
	If MNTA340SAV( 3 )

		/*-----------------------------------+
    	| Imprime problemas do planejamento. |
    	+-----------------------------------*/
		MNTA340PROB( .T. ) 

	EndIf

	oTmpTbl3:Delete()
	oTmpTbl4:Delete()
	oTmpTbl5:Delete()
	oTmpTbl1:Delete()
	oTmpTbl2:Delete()

	SetFunName( 'MNTA340' ) // Retorna a função chamadora como principal

Return

//---------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional
@type function

@author Alexandre Santos
@since 15/03/2022

@return aRotina, array, [1] - Nome apresentado no cabeçalho.
						[2] - Rotina associada.
						[3] - Reservado.
						[4] - Tipo de transação a ser efetuada:
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

	Local aRotina := {  { STR0001, 'a340ALTVL', 0, 2 },; // Visualizar
						{ STR0002, 'a340ALTDT', 0, 4 },; // Alterar Data
                        { STR0003, 'MNTA340B' , 0, 9 } } // Liber. Planos
			
Return aRotina
