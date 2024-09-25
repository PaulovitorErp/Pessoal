#INCLUDE "MNTA530.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE _nVERSAO 2 //Versao do fonte

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTA530
Cadastro de Medidas de Pneus

@author NG Informática Ltda.
@since 01/01/2015
/*/
//------------------------------------------------------------------------------
Function MNTA530()
	
	Local aNGBeginPrm := NGBeginPrm( _nVERSAO )
	Local oBrowse
	
	Private cCadastro := NgSX2Nome( "TQT" ) // "Medidas dos Pneus"
	Private aRotina	:= MenuDef()
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( "TQT" )
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
Return FWMVCMenu( "MNTA530" )

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Regras de Modelagem da gravacao

@author NG Informática Ltda.
@since 01/01/2015
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

	Local oModel
	Local oStructTQT := FWFormStruct(1,"TQT")

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("MNTA530")

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields("MNTA530_TQT", Nil, oStructTQT )

	oModel:SetDescription( NgSX2Nome( "TQT" ) )

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Regras de Interface com o Usuario

@author NG Informática Ltda.
@since 01/01/2015
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

	Local oModel := FWLoadModel("MNTA530")
	Local oView  := FWFormView():New()

	// Objeto do model a se associar a view.
	oView:SetModel(oModel)

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( "MNTA530_TQT" , FWFormStruct(2,"TQT") )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( "MASTER" , 100 )

	// Associa um View a um box
	oView:SetOwnerView( "MNTA530_TQT" , "MASTER" )
	
	// Inclusão de itens no Ações Relacionadas de acordo com o NGRightClick
	NGMVCUserBtn( oView )

Return oView