#INCLUDE 'MNTA915.ch'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA915
Grupos de usuários MNTNG

@type function
@author cristiano.kair
@since 14/10/2022

@return Nil
/*/
//---------------------------------------------------------------------
Function MNTA915()

	Local oBrowse

	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 19, 95 )

        oBrowse := FWMBrowse():New()
        oBrowse:SetAlias( 'HP0' )
        oBrowse:SetDescription( STR0006 ) //'Grupos de usuários MNTNG'
        oBrowse:Activate()

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do Menu

@type function
@author cristiano.kair
@since 14/10/2022

@return função com o menu em MVC
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0001 ACTION 'PesqBrw'           OPERATION 1  ACCESS 0 // 'Pesquisar'
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.MNTA915'   OPERATION MODEL_OPERATION_VIEW  ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.MNTA915'   OPERATION MODEL_OPERATION_INSERT ACCESS 0 // 'Incluir'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.MNTA915'   OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // 'Alterar'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.MNTA915'   OPERATION MODEL_OPERATION_DELETE ACCESS 0 // 'Excluir'

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados da rotina

@type function
@author cristiano.kair
@since 14/10/2022

@return objeto, objeto do Modelo MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oModel
	Local oStruHP0 := FWFormStruct( 1, 'HP0' )

	oModel := MPFormModel():New( 'MNTA915', /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)
	oModel:SetDescription( STR0006 ) //'Grupos de usuários MNTNG'
	oModel:AddFields( 'MNTA915_HP0', /*cOwner*/, oStruHP0 )

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface da rotina

@type function
@author cristiano.kair
@since 14/10/2022

@return objeto, objeto da View MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local oModel := FWLoadModel( 'MNTA915' )
	Local oView
	Local oStrHP0 := FWFormStruct( 2, 'HP0' )

	oStrHP0:RemoveField( 'HP0_TIPO' )

	oView := FWFormView():New()
	oView:SetModel( oModel )

	oView:SetViewCanActivate( {|oView| fVActivate( oView ) } )

	oView:AddField( 'MNTA915_HP0', oStrHP0, /*cLinkID*/ )
	oView:CreateHorizontalBox( 'MASTER', 100)
	oView:SetOwnerView( 'MNTA915_HP0', 'MASTER' )

Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} fVActivate()
Validação para mostrar a tela

@type function
@author cristiano.kair
@since 03/11/2022
@param oView, objeto, view pai

@return lógico, abrirá a tela
/*/
//---------------------------------------------------------------------
Static Function fVActivate( oView )

	If oView:GetOperation() == MODEL_OPERATION_INSERT

		dbSelectArea( 'HP0' )
		dbSetOrder( 1 ) // HP0_FILIAL+HP0_CODIGO
		If !MsSeek( FWxFilial( 'HP0' ) )

			Help(NIL, NIL, STR0007,;//"Atenção"
				NIL, STR0008, 1, 0, NIL, NIL, NIL, NIL, NIL,;//"Identificamos que não há Grupos cadastrados."
				{ STR0009 })//"Caso houver conta no Portal MNTNG com informações cadastradas, deve antes acessá-lo e realizar a importação dos dados."

		EndIf

	EndIf

Return .T.
