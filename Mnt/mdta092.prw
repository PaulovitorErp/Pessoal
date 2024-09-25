#include 'mdta092.ch'
#include 'protheus.ch'
#include 'fwmvcdef.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} mdta092
Cadastro de tarefas para candidato via ficha m�dica

@author Gabriel Sokacheski
@since 27/03/2023

/*/
//---------------------------------------------------------------------
Function mdta092()

	Local oBrowse

	If AMiIn( 35 ) // Somente autorizado para SIGAMDT

		oBrowse := FWMBrowse():New()

		oBrowse:SetAlias( 'TM0' )
		oBrowse:SetMenuDef( 'MDTA092' )
		oBrowse:SetFilterDefault( 'Empty( TM0->TM0_MAT )' )
		oBrowse:SetDescription( STR0001 ) // "Ficha m�dica"

		oBrowse:Activate()

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Defini��o do menu

@author Gabriel Sokacheski
@since 27/03/2023

@return aRotina, menu da rotina
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	aAdd( aRotina, { STR0002, 'ViewDef.mdta092', 0, 2, 0 } ) // "Visualizar"
    aAdd( aRotina, { STR0003, 'ViewDef.mdta092', 0, 4, 0 } ) // "Tarefas"

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do Modelo

@author Gabriel Sokacheski
@since 27/03/2023

@return oModel, modelo em MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oStructTM0  := FWFormStruct( 1, 'TM0' )
    Local oStructTKD  := FWFormStruct( 1, 'TKD' )
	Local oModel    := MPFormModel():New( 'MDTA092', Nil, { | oModel | Mdta007Val( oModel ) } )

	oStructTKD:AddTrigger( 'TKD_CODTAR', 'TKD_NOMTAR', { || .T. }, { || SubStr( Posicione( 'TN5', 1, xFilial( 'TN5' ) + M->TKD_CODTAR, 'TN5_NOMTAR' ), 1, 20 ) } )

    oModel:AddFields( 'TM0MASTER', Nil, oStructTM0 )
    oModel:AddGrid( 'TKDDETAIL', 'TM0MASTER', oStructTKD, Nil, { | oStructTKD | fValLin( oModel ) } )
    oModel:SetRelation( 'TKDDETAIL', { { 'TKD_FILIAL', 'xFilial( "TKD" )' }, { 'TKD_NUMFIC', 'TM0_NUMFIC' } } )
    oModel:SetDescription( STR0001 ) // "Ficha m�dica"
    oModel:GetModel( 'TM0MASTER' ):SetDescription( STR0001 ) // "Ficha m�dica"
    oModel:GetModel( 'TKDDETAIL' ):SetDescription( STR0003 ) // "Tarefas"
	oModel:GetModel( 'TKDDETAIL' ):SetDelAllLine( .T. )

    // Bloqueia a edi��o dos campos
	oStructTM0:SetProperty( 'TM0_CANDID'	, MODEL_FIELD_WHEN, { || .F. } )
    oStructTM0:SetProperty( 'TM0_MAT' 		, MODEL_FIELD_WHEN, { || .F. } )
    oStructTM0:SetProperty( 'TM0_NUMDEP' 	, MODEL_FIELD_WHEN, { || .F. } )
	oStructTM0:SetProperty( 'TM0_DTIMPL' 	, MODEL_FIELD_WHEN, { || .F. } )

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o da view

@author Gabriel Sokacheski
@since 27/03/2023

@return oView, view em MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

    Local oModel    	:= FWLoadModel( 'MDTA092' )
    Local oStructTM0	:= FWFormStruct( 2, 'TM0' )
    Local oStructTKD  	:= FWFormStruct( 2, 'TKD' )
    Local oView     	:= FWFormView():New()

    oView:SetModel( oModel )
    oView:AddField( 'VIEW_TM0', oStructTM0, 'TM0MASTER' )
    oView:AddGrid( 'VIEW_TKD', oStructTKD, 'TKDDETAIL' )

	If !FwIsInCallStack( 'MDTA410' )
        oView:CreateHorizontalBox( 'SUPERIOR', 40 )
        oView:CreateHorizontalBox( 'INFERIOR', 60 )
    Else
        oView:CreateHorizontalBox( 'SUPERIOR', 0 )
        oView:CreateHorizontalBox( 'INFERIOR', 100 )
    EndIf

    oView:SetOwnerView( 'VIEW_TM0', 'SUPERIOR' )
    oView:SetOwnerView( 'VIEW_TKD', 'INFERIOR' )
	oView:SetCloseOnOk( { || .T. } ) // Remove bot�o salvar e criar novo

    // Campos removidos da tela
    oStructTM0:RemoveField( 'TM0_CLIENT' )
    oStructTM0:RemoveField( 'TM0_LOJA' )
    oStructTM0:RemoveField( 'TM0_NOMCLI' )
    oStructTM0:RemoveField( 'TM0_OK' )
	oStructTKD:RemoveField( 'TKD_NUMFIC' )
	oStructTKD:RemoveField( 'TKD_NOMFIC' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} Mdta092X3V
Fun��o utilizada no X3_VALID dos campos da rotina

@author Gabriel Sokacheski
@since 27/03/2023

@param cCampo, nome do campo a ser validado

@return lRet, retorno da valida��o do campo
/*/
//-------------------------------------------------------------------
Function Mdta092X3V( cCampo )

	Local lRet      := .T.

    Local oModel    := FWModelActive()
    Local oMaster   := oModel:GetModel( 'TM0MASTER' )
	Local oGrid		:= oModel:GetModel( 'TKDDETAIL' )

    If !Empty( oGrid:GetValue( cCampo ) )

        Do Case
            Case cCampo == 'TKD_CODTAR'
                lRet := ExistCpo( 'TN5', oGrid:GetValue( 'TKD_CODTAR' ) )
			Case cCampo == 'TKD_DTINIC'
				fValIni( @lRet, oModel, oMaster, oGrid )
			Case cCampo == 'TKD_DTTERM'
				fValFim( @lRet, oModel, oMaster, oGrid )
        End Case

    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fValIni
Valida o campo TKD_DTINIC

@author Gabriel Sokacheski
@since 27/03/2023

@param, lRet, retorno da fun��o
@param, oModel, modelo de dados
@param, oMaster, objeto do modelo
@param, oGrid, objeto da grid

/*/
//-------------------------------------------------------------------
Static Function fValIni( lRet, oModel, oMaster, oGrid )

	Local dInicio	:= oGrid:GetValue( 'TKD_DTINIC' )
	Local dFim 		:= oGrid:GetValue( 'TKD_DTTERM' )

	If dInicio < oMaster:GetValue( 'TM0_DTIMPL' )

		//---------------------------------------------------------------------------------------
		// Mensagens:
		// "Aten��o"
		// "Data inv�lida"
		// "A data de in�cio deve ser maior ou igual que a data de implementa��o da ficha m�dica"
		//----------------------------------------------------------------------------------------
		Help( Nil, Nil, STR0004, Nil, STR0007 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0008 + '.' } )

		lRet := .F.

	ElseIf !Empty( dFim ) .And. dInicio > dFim

		//---------------------------------------------------------------------------------------
		// Mensagens:
		// "Aten��o"
		// "Data inv�lida"
		// "A data de fim deve ser maior ou igual a data de in�cio"
		//----------------------------------------------------------------------------------------
		Help( Nil, Nil, STR0004, Nil, STR0007 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0009 + '.' } )

		lRet := .F.

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fValFim
Valida o campo TKD_DTTERM

@author Gabriel Sokacheski
@since 27/03/2023

@param, lRet, retorno da fun��o
@param, oModel, modelo de dados
@param, oMaster, objeto do modelo
@param, oGrid, objeto da grid

/*/
//-------------------------------------------------------------------
Static Function fValFim( lRet, oModel, oMaster, oGrid )

	Local dInicio	:= oGrid:GetValue( 'TKD_DTINIC' )
	Local dFim 		:= oGrid:GetValue( 'TKD_DTTERM' )

	If !Empty( dInicio ) .And. dInicio > dFim

		//---------------------------------------------------------------------------------------
		// Mensagens:
		// "Aten��o"
		// "Data inv�lida"
		// "A data de fim deve ser maior ou igual a data de in�cio"
		//----------------------------------------------------------------------------------------
		Help( Nil, Nil, STR0004, Nil, STR0007 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0009 + '.' } )

		lRet := .F.

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fValLin
Valida a linha da grid

@author Gabriel Sokacheski
@since 27/03/2023

@param oModel, modelo de dados da grid

@return lRet, retorna da valida��o
/*/
//-------------------------------------------------------------------
Static Function fValLin( oModel )

	Local oGrid 	:= oModel:GetModel( 'TKDDETAIL' )

	Local cTarefa	:= oGrid:GetValue( 'TKD_CODTAR' )

	Local dInicio 	:= oGrid:GetValue( 'TKD_DTINIC' )

	Local lRet 		:= .T.

	Local nLinha 	:= 0
	Local nLinAtu	:= oGrid:GetLine()

	If Empty( dInicio )

		//-----------------------------
		// Mensagens:
		// "Aten��o"
		// "Data de in�cio vazia"
		// "Preencha a data de in�cio"
		//-----------------------------
		Help( Nil, Nil, STR0004, Nil, STR0005 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0006 + '.' } )

		lRet := .F.

	Else

		For nLinha := 1 To oGrid:Length()

			oGrid:GoLine( nLinha )

			If nLinAtu != nLinha .And. oGrid:GetValue( 'TKD_CODTAR' ) == cTarefa .And. oGrid:GetValue( 'TKD_DTINIC' ) == dInicio

				//---------------------------------------------------------------------------------------
				// Mensagens:
				// "Aten��o"
				// "O registro j� existe"
				// "Verifique o registro j� existe com a mesma tarefa e data de in�cio informadas"
				//----------------------------------------------------------------------------------------
				Help( Nil, Nil, STR0004, Nil, STR0010 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0011 + '.' } )

				lRet := .F.

				Exit

			EndIf

		Next nLinha

		oGrid:GoLine( nLinAtu )

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Mdta092X3R
Fun��o utilizada no X3_RELACAO dos campos da rotina

@author Gabriel Sokacheski
@since 15/05/2023

@param cCampo, nome do campo a ser verificado

@return xValor, conte�do a ser recebido no campo
/*/
//-------------------------------------------------------------------
Function Mdta092X3R( cCampo )

    Local xValor    := ''

	Do Case
		Case cCampo == 'TKD_NUMFIC'
			xValor := TM0->TM0_NUMFIC
		Case cCampo == 'TKD_NOMFIC'
			xValor := TM0->TM0_NOMFIC
		Case cCampo == 'TKD_NOMTAR' .And. !Empty( TKD->TKD_CODTAR )
			xValor := Posicione( 'TN5', 1, xFilial( 'TN5' ) + TKD->TKD_CODTAR, 'TN5_NOMTAR' )
	End Case

Return xValor
