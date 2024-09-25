#INCLUDE "MNTA306.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE _nVERSAO 1 //Versao do fonte
//-----------------------------------------------------------
/*/{Protheus.doc} MNTA306
Programa de Grupo de Perguntas

@author Lucas Guszak
@since 04/07/2014
@version MP11
@return Nil
/*/
//-----------------------------------------------------------
Function MNTA306()

	Local aNGBEGINPRM := NGBEGINPRM( _nVERSAO, "MNTA306" )
	Local oBrowse
	
	//Verifica se o update de facilities foi aplicado
	If !FindFunction("MNTUPDFAC") .or. !MNTUPDFAC()
		Return Nil
	Endif
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( "TUN" ) // Alias da tabela utilizada
	oBrowse:SetMenuDef( "MNTA306" )  // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription( STR0001 ) // Descrição do browse // "Grupo de Perguntas"
	oBrowse:Activate()

	NGRETURNPRM(aNGBEGINPRM)

Return Nil

//-----------------------------------------------------------
/*/{Protheus.doc} ModelDef
Interface da rotina

@author Lucas Guszak
@since 04/07/2014
@version MP11
@return oModel
/*/
//-----------------------------------------------------------
Static Function ModelDef()

	Local oStruct306 := FWFormStruct( 1, "TUN" )
	Local oModel
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( "MNTA306", Nil, Nil, Nil, Nil)
	
	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( "MNTA306_TUN", Nil, oStruct306 )
	oModel:SetPrimaryKeys( {} )
	oModel:SetDescription( STR0001 )
	
Return oModel

//-----------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface da rotina

@author Lucas Guszak
@since 04/07/2014
@version MP11
@return oView
/*/
//-----------------------------------------------------------
Static Function ViewDef()

	Local oModel := FWLoadModel( "MNTA306" )
	Local oStruct306 := FWFormStruct( 2, "TUN" )
	Local oView
	
	oView := FWFormView():New()
	
	// Objeto do model a se associar a view.
	oView:SetModel( oModel )
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( "MNTA306_TUN" , oStruct306, Nil )
	// Criar um "box" horizontal para receber elementos da view
	oView:CreateHorizontalBox( "TELA", 100 )
	// Associa um View a um box
	oView:SetOwnerView( "MNTA306_TUN", "TELA" )
	//Inclusão de itens nas Ações Relacionadas de acordo com O NGRightClick 
	NGMVCUserBtn(oView)

Return oView

//-----------------------------------------------------------
/*/{Protheus.doc} MenuDef
Interface da rotina

@author Lucas Guszak
@since 04/07/2014
@version MP11
@return FWMVCMenu( "MNTA306" )
/*/
//-----------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "MNTA306" )
