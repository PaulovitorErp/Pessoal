#INCLUDE "MNTA025.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE _nVERSAO 2 //Versao do fonte
//-----------------------------------------------------------
/*/{Protheus.doc} MNTA025
Programa de Motivos

@author Pablo Servin
@since 07/04/2014
@version MP11
@return Nil
/*/
//-----------------------------------------------------------
Function MNTA025()

	Local aNGBEGINPRM := NGBEGINPRM( _nVERSAO, "MNTA025" )
	Local oBrowse

	oBrowse := FWMBrowse():New()

	oBrowse:SetAlias( "TPJ" ) // Alias da tabela utilizada
	oBrowse:SetMenuDef( "MNTA025" )  // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription( STR0006 ) // Descrição do browse // "Motivo do Atraso"
	oBrowse:Activate()

	NGRETURNPRM(aNGBEGINPRM)

Return Nil

//-----------------------------------------------------------
/*/{Protheus.doc} ModelDef
Interface da rotina

@author Pablo Servin
@since 07/04/2014
@version MP11
@return oModel
/*/
//-----------------------------------------------------------
Static Function ModelDef()

	Local oStruct025 := FWFormStruct( 1, "TPJ" )
	Local oModel
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( "MNTA025", Nil, Nil, Nil, Nil)
	
	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( "MNTA025_TPJ", Nil, oStruct025 )
	oModel:SetPrimaryKeys( {} )
	oModel:SetDescription( STR0006 )
	
Return oModel

//-----------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface da rotina

@author Pablo Servin
@since 07/04/2014
@version MP11
@return oView
/*/
//-----------------------------------------------------------
Static Function ViewDef()

	Local oModel := FWLoadModel( "MNTA025" )
	Local oStruct025 := FWFormStruct( 2, "TPJ" )
	Local oView
	
	oView := FWFormView():New()
	
	// Objeto do model a se associar a view.
	oView:SetModel( oModel )
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( "MNTA025_TPJ" , oStruct025, Nil )
	// Criar um "box" horizontal para receber elementos da view
	oView:CreateHorizontalBox( "TELA", 100 )
	// Associa um View a um box
	oView:SetOwnerView( "MNTA025_TPJ", "TELA" )
	//Inclusão de itens nas Ações Relacionadas de acordo com O NGRightClick
	NGMVCUserBtn(oView) 

Return oView

//-----------------------------------------------------------
/*/{Protheus.doc} MenuDef
Interface da rotina

@author Pablo Servin
@since 07/04/2014
@version MP11
@return FWMVCMenu( "MNTA025" )
/*/
//-----------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "MNTA025" )

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MNT025VLDCPOS
Validação dos campos.

@author Pablo Servin
@since 08/04/2014
@return lRet
/*/
//--------------------------------------------------------------------------------
Function MNT025VLDCPOS( cCampo )

	Local lRet
	
	Do Case
		Case cCampo == 'TPJ_CODMOT'
			lRet := EXISTCHAV( "TPJ", M->TPJ_CODMOT )
		OtherWise 
			lRet := .T.
	End Case

Return lRet
