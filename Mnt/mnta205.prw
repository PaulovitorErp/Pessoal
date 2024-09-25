#INCLUDE "mnta205.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"   

#DEFINE _nVERSAO 1 //Versao do fonte
//-----------------------------------------------------------
/*/{Protheus.doc} MNTA205
Programa de Tipos de Irregularidades 

@author Pablo Servin
@since 07/04/2014
@version MP11
@return
/*/
//-------------------------------------------------------------
Function MNTA205()

	Local aNGBEGINPRM := NGBEGINPRM( _nVERSAO, "MNTA205" )
	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	
	oBrowse:SetAlias( "TP7" ) // Alias da tabela utilizada
	oBrowse:SetMenuDef( "MNTA205" ) // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription( STR0006 )  // Descrição do browse // "Tipos de Irregularidades"
	
	// Checa se parâmetro de irregularidade está habilitado (MV_NGTNDFL)
	If !NGCHKIRREG()
		Return Nil
	EndIf
	
	oBrowse:Activate()
	
	NGRETURNPRM(aNGBEGINPRM) // Retorna variáveis padrões.
	
Return Nil

//-----------------------------------------------------------
/*/{Protheus.doc} ModelDef
Regras da modelagem da gravação

@author Pablo Servin
@since 07/04/2014
@version MP11
@return oModel
/*/
//-------------------------------------------------------------
Static Function ModelDef()
	
	Local oStruct205 := FWFormStruct( 1, "TP7" )
	Local oModel
	
	oModel := MPFormModel():New( "MNTA205", Nil, Nil, Nil, Nil)
	oModel:AddFields( "MNTA205_TP7", Nil, oStruct205 )
	oModel:SetPrimaryKey( {} )
	oModel:SetDescription( STR0006 )
	oModel:GetModel( "MNTA205_TP7" ):SetDescription( STR0006 )

Return oModel

//-----------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface da rotina

@author Pablo Servin
@since 07/04/2014
@version MP11
@return oView
/*/
//-------------------------------------------------------------
Static Function ViewDef()

	Local oModel := FWLoadModel( "MNTA205" )
	Local oStruct205 := FWFormStruct( 2, "TP7" )
	Local oView
	
	oView := FWFormView():New()
	
	// Objeto do model a se associar a view.	
	oView:SetModel( oModel )
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)	
	oView:AddField( "MNTA205_TP7", oStruct205, Nil)
	// Criar um "box" horizontal para receber elementos da view
	oView:CreateHorizontalBox( "TELA", 100 )
	// Associa um View a um box
	oView:SetOwnerView( "MNTA205_TP7", "TELA" )
	//Inclusão de itens nas Ações Relacionadas de acordo com O NGRightClick
	NGMVCUserBtn(oView)
	
Return oView

//-----------------------------------------------------------
/*/{Protheus.doc} ViewDef
Menu de opções padrões.

@author Pablo Servin
@since 07/04/2014
@version MP11
@return FWMVCMenu( "MNTA205" )
/*/
//-------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "MNTA205" )

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MNT205VLDCPOS
Validação dos campos.

@author Pablo Servin
@since 08/04/2014
@return lRet
/*/
//--------------------------------------------------------------------------------
Function MNT205VLDCPOS( cCampo )
	
	Local lRet
	
	Do Case 
		Case cCampo == 'TP7_CODIRE'
			lRet := EXISTCHAV("TP7",M->TP7_CODIRE) .AND. FreeForuse("TP7",M->TP7_CODIRE)
		Case cCampo == 'TP7_GRAVID'
			lRet := NaoVazio()
		Case cCampo == 'TP7_UNDTMP'
			lRet := NaoVazio()
		OtherWise 
			lRet := .T.			
	End Case

Return lRet
