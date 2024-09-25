#include 'mdta007b.ch'
#include 'protheus.ch'
#include 'fwmvcdef.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} mdta007b
Cadastro de tarefas para funcionário via ficha médica

@author Gabriel Sokacheski
@since 23/03/2023

/*/
//---------------------------------------------------------------------
Function mdta007b()

    Local oBrowse

    If AMiIn( 35 ) // Somente autorizado para SIGAMDT

        oBrowse := FWMBrowse():New()

        oBrowse:SetAlias( 'TM0' )
        oBrowse:SetMenuDef( 'mdta007b' )
        oBrowse:SetFilterDefault( '!Empty( TM0->TM0_MAT )' )
        oBrowse:SetDescription( STR0001 ) // "Ficha médica"

        oBrowse:Activate()

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu

@author Gabriel Sokacheski
@since 23/03/2023

@return aRotina, menu da rotina
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

    aAdd( aRotina, { STR0003, 'ViewDef.mdta007b', 0, 2, 0 } ) // "Visualizar"
    aAdd( aRotina, { STR0002, 'ViewDef.mdta007b', 0, 4, 0 } ) // "Tarefas"

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do Modelo

@author Gabriel Sokacheski
@since 23/03/2023

@return oModel, modelo em MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oStructTM0    := FWFormStruct( 1, 'TM0' )
    Local oStructTN6    := FWFormStruct( 1, 'TN6' )
	Local oModel        := MPFormModel():New( 'mdta007b', Nil, { | oModel | mdta007Val( oModel ) } )
    Local oEvent		:= mdta090a():New()

    oStructTN6:AddTrigger( 'TN6_CODTAR', 'TN6_NOMTAR', { || .T. }, { || SubStr( Posicione( 'TN5', 1, xFilial( 'TN5' ) + M->TN6_CODTAR, 'TN5_NOMTAR' ), 1, 20 ) } )

    oModel:AddFields( 'TM0MASTER', Nil, oStructTM0 )
    oModel:AddGrid( 'TN6DETAIL', 'TM0MASTER', oStructTN6 )
    oModel:SetRelation( 'TN6DETAIL', { { 'TN6_FILIAL', 'xFilial( "TN6" )' }, { 'TN6_MAT', 'TM0_MAT' } }, ( 'TN6' )->( IndexKey( 1 ) ) )
    oModel:SetDescription( STR0001 ) // "Ficha médica"
    oModel:GetModel( 'TM0MASTER' ):SetDescription( STR0001 ) // "Ficha médica"
    oModel:GetModel( 'TN6DETAIL' ):SetDescription( STR0002 ) // "Tarefas"
    oModel:GetModel( 'TN6DETAIL' ):SetDelAllLine( .T. )

    // Gatilhos da rotina
    oStructTN6:AddTrigger( 'TN6_CODTAR', 'TN6_MAT', { || .T. }, { || TM0->TM0_MAT } )

    // Bloqueia a edição dos campos
    oStructTM0:SetProperty( 'TM0_MAT'       , MODEL_FIELD_WHEN, { || .F. } )
    oStructTM0:SetProperty( 'TM0_NUMDEP'    , MODEL_FIELD_WHEN, { || .F. } )

    oModel:InstallEvent( "mdta090a", Nil, oEvent )

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da view

@author Gabriel Sokacheski
@since 23/03/2023

@return oView, view em MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

    Local oModel        := FWLoadModel( 'mdta007b' )
    Local oStructTM0    := FWFormStruct( 2, 'TM0' )
    Local oStructTN6    := FWFormStruct( 2, 'TN6' )
    Local oView         := FWFormView():New()

    oView:SetModel( oModel )
    oView:AddField( 'VIEW_TM0', oStructTM0, 'TM0MASTER' )
    oView:AddGrid( 'VIEW_TN6', oStructTN6, 'TN6DETAIL' )

    If !FwIsInCallStack( 'MDTA410' )
        oView:CreateHorizontalBox( 'SUPERIOR', 40 )
        oView:CreateHorizontalBox( 'INFERIOR', 60 )
    Else
        oView:CreateHorizontalBox( 'SUPERIOR', 0 )
        oView:CreateHorizontalBox( 'INFERIOR', 100 )
    EndIf

    oView:SetOwnerView( 'VIEW_TM0', 'SUPERIOR' )
    oView:SetOwnerView( 'VIEW_TN6', 'INFERIOR' )
    oView:SetCloseOnOk( { || .T. } ) // Remove botão salvar e criar novo

    // Campos removidos da tela
    oStructTM0:RemoveField( 'TM0_CLIENT' )
    oStructTM0:RemoveField( 'TM0_LOJA' )
    oStructTM0:RemoveField( 'TM0_NOMCLI' )
    oStructTM0:RemoveField( 'TM0_OK' )
    oStructTN6:RemoveField( 'TN6_MAT' )
    oStructTN6:RemoveField( 'TN6_NOME' )

Return oView
