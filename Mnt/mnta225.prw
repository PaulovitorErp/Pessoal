#INCLUDE "MNTA225.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE _nVERSAO 2 //Versao do fonte

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTA225
Cadastro de Grupos de Contas de E-mail

@author NG Informática Ltda.
@since 01/01/2015
/*/
//------------------------------------------------------------------------------
Function MNTA225()
	
	Local aNGBeginPrm := NGBeginPrm( _nVERSAO )
	Local oBrowse
	
	Private cCadastro := NgSX2Nome( "TP0" ) // "Grupos Contas Email"
	Private aRotina	:= MenuDef()
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( "TP0" )
	oBrowse:SetDescription( cCadastro )
	oBrowse:Activate()
	
	NGReturnPrm( aNGBeginPrm )
	
Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Interface da rotina

@author NG Informática Ltda.
@since 01/01/2015
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
// Inicializa MenuDef com todas as opções
Return FWMVCMenu( "MNTA225" )

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Regras de Modelagem da gravacao

@author NG Informática Ltda.
@since 01/01/2015
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

	Local oModel
	Local oStructTP0 := FWFormStruct(1,"TP0")

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("MNTA225")

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields("MNTA225_TP0", Nil, oStructTP0 )

	oModel:SetDescription( NgSX2Nome( "TP0" ) )

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Regras de Interface com o Usuario

@author NG Informática Ltda.
@since 01/01/2015
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

	Local oModel := FWLoadModel("MNTA225")
	Local oView  := FWFormView():New()

	// Objeto do model a se associar a view.
	oView:SetModel(oModel)

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( "MNTA225_TP0" , FWFormStruct(2,"TP0") )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( "MASTER" , 100 )

	// Associa um View a um box
	oView:SetOwnerView( "MNTA225_TP0" , "MASTER" )
	
	// Inclusão de itens no Ações Relacionadas de acordo com o NGRightClick
	NGMVCUserBtn( oView )

Return oView