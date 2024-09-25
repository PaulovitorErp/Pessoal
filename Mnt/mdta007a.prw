#Include 'mdta007a.ch'
#include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} mdta007a
Monta o Browse da rotina.

@author	Gabriel Sokacheski
@since 21/03/2023

/*/
//-------------------------------------------------------------------
Function mdta007a()

    Local aBrw          := {}
    Local aTRB          := {}

    Private oMark       := FWMarkBrowse():New()
    Private oTempTable  
    
    Private cAliasTRB   := ''
    Private cNomTabTRB  := ''

    Private MV_NG2ATM0  := SuperGetMv( 'MV_NG2ATM0', .F., '3' )
    Private MV_NG2BIOM  := SuperGetMv( 'MV_NG2BIOM', .F., '2' )
    Private MV_NG2FICH  := SuperGetMv( 'MV_NG2FICH', .F., '2' )

    fTabTM0( @cAliasTRB, @oTempTable, @aTRB, @aBrw )

    cNomTabTRB := oTempTable:GetRealName()

    oMark:SetAlias( cAliasTRB ) // Define da tabela a ser utilizada
    oMark:SetFields( aBrw ) // Define os campos apresentados em tela
    oMark:SetFieldMark( 'TM0_OK' ) // Define o campo que sera utilizado para a marcação
    oMark:SetDescription( STR0001 ) // "Ficha médica"
    oMark:SetMenuDef( 'mdta007a' )
    oMark:DisableReport()
    oMark:SetIgnoreARotina( .T. )

    oMark:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Define as opções da rotina.

@author	Gabriel Sokacheski
@since 21/03/2023

@return	aRotina, contendo as opções da rotina
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

    Local aRotina := {}

    aAdd( aRotina, { STR0002, 'VIEWDEF.mdta007a', 0, 1, 0, Nil } ) // "Visualizar"
    aAdd( aRotina, { STR0003, 'fFichaSel()', 0, 2, 0, Nil } ) // "Selecionar"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface da rotina.

@author	Gabriel Sokacheski
@since 21/03/2023

@return	oView, contendo a interface.
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

    Local oView := FWLoadView( 'mdta007' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} fFichaSel
Retorna a ficha médica selecionada

@author	Gabriel Sokacheski
@since 21/03/2023

@return, cFicha, número da ficha médica selecionada
/*/
//-------------------------------------------------------------------
Function fFichaSel()

    Local cMarca    := oMark:Mark() // Retorna identificador do markBrowse
    Local cQuery    := GetNextAlias()

    Local nRegistros := 0

    BeginSQL Alias cQuery
		SELECT
            TM0_NUMFIC
		FROM
            %temp-table:cNomTabTRB%
		WHERE
            TM0_OK = %exp:cMarca%
			AND %notDel%
	EndSQL

    ( cQuery )->( DbGoTop() )

    While ( cQuery )->( !Eof() )

        cFicha := ( cQuery )->( TM0_NUMFIC )
        nRegistros += 1

        ( cQuery )->( DbSkip() )

    End

    ( cQuery )->( DbCloseArea() )

    If nRegistros > 1

        //---------------------------------------------------------------
        // Mensagens:
        // "Atenção"
        // "Foi marcado mais de um registro"
        // "Marque somente um registro"
        //---------------------------------------------------------------
        Help( Nil, Nil, STR0004, Nil, STR0005 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0006 + '.' } )

    Else

        CloseBrowse()

    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fTabTM0
Criação do tabela temporária para o MarkBrowse

@author	Eloisa Anibaletto
@since 19/04/2024

@param cAliasTRB, nome da tabela temporária
@param oTempTable, tabela temporária
@param aTRB, array com os campos da tabela temporária
@param aBrw, array com os campos para o MarkBrowse
/*/
//-------------------------------------------------------------------
Static Function fTabTM0( cAliasTRB, oTempTable, aTRB, aBrw )

    Local aAreaTM0  := GetArea( "TM0" )

    cAliasTRB       := GetNextAlias()
    oTempTable      := FwTemporaryTable():New( cAliasTRB )

    aAdd( aTRB, { "TM0_NUMFIC", "C", TamSx3( "TM0_NUMFIC" )[1], 0 } )
	aAdd( aTRB, { "TM0_CANDID", "C", TamSx3( "TM0_CANDID" )[1], 0 } )
    aAdd( aTRB, { "TM0_FILFUN", "C", TamSx3( "TM0_FILFUN" )[1], 0 } )
    aAdd( aTRB, { "TM0_MAT"   , "C", TamSx3( "TM0_MAT"    )[1], 0 } )
    aAdd( aTRB, { "TM0_NUMDEP", "C", TamSx3( "TM0_NUMDEP" )[1], 0 } )
    aAdd( aTRB, { "TM0_NOMFIC", "C", TamSx3( "TM0_NOMFIC" )[1], 0 } )
	aAdd( aTRB, { "TM0_OK"    , "C",                         2, 0 } )

    aAdd( aBrw, { FWX3Titulo( "TM0_NUMFIC" ), "TM0_NUMFIC", "C", TamSx3( "TM0_NUMFIC" )[1], 0, "@!" } )
	aAdd( aBrw, { FWX3Titulo( "TM0_CANDID" ), "TM0_CANDID", "C", TamSx3( "TM0_CANDID" )[1], 0, "@!" } )
    aAdd( aBrw, { FWX3Titulo( "TM0_FILFUN" ), "TM0_FILFUN", "C", TamSx3( "TM0_FILFUN" )[1], 0, "@!" } )
    aAdd( aBrw, { FWX3Titulo( "TM0_MAT"    ), "TM0_MAT"   , "C", TamSx3( "TM0_MAT"    )[1], 0, "@!" } )
    aAdd( aBrw, { FWX3Titulo( "TM0_NUMDEP" ), "TM0_NUMDEP", "C", TamSx3( "TM0_NUMDEP" )[1], 0, "@!" } )
    aAdd( aBrw, { FWX3Titulo( "TM0_NOMFIC" ), "TM0_NOMFIC", "C", TamSx3( "TM0_NOMFIC" )[1], 0, "@!" } )

    oTempTable:SetFields( aTRB )
    oTempTable:AddIndex( "01", { "TM0_NUMFIC" } )
    oTempTable:Create()

    DbSelectArea( "TM0" )
    ( "TM0" )->( DbSetOrder( 10 ) )

    If ( "TM0" )->( DbSeek( xFilial( "TM0" ) + M->RA_CIC ) )

        While ( "TM0" )->( !Eof() ) .And. xFilial( "TM0" ) = TM0->TM0_FILIAL .And. M->RA_CIC == TM0->TM0_CPF;
            .And. FwCheckSX9( "TM0", Nil, { "TKD", "TMY", "TM5" }, Nil, .F. )

            DbSelectArea( cAliasTRB )
            RecLock( cAliasTRB, .T. )
                ( cAliasTRB )->TM0_NUMFIC	:= TM0->TM0_NUMFIC
                ( cAliasTRB )->TM0_NOMFIC	:= TM0->TM0_NOMFIC
                ( cAliasTRB )->TM0_CANDID	:= TM0->TM0_CANDID
                ( cAliasTRB )->TM0_FILFUN	:= TM0->TM0_FILFUN
                ( cAliasTRB )->TM0_MAT	    := TM0->TM0_MAT
                ( cAliasTRB )->TM0_NUMDEP	:= TM0->TM0_NUMDEP
            ( cAliasTRB )->( MsUnLock() )

            ( "TM0" )->( DbSkip() )

        End

    EndIf

    RestArea( aAreaTM0 )

Return
