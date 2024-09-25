#INCLUDE "MNTA235.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE _nVERSAO 2 //Versao do fonte

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTA235
Cadastro de Grupos de Contas de Email/Funcionarios

@author NG Informática Ltda.
@since 01/01/2015
/*/
//------------------------------------------------------------------------------
Function MNTA235()
	
	Local aNGBeginPrm := NGBeginPrm( _nVERSAO )
	Local oBrowse
	
	Private cCadastro := STR0006 // "Grupos Contas Email/Funcionarios"
	Private aRotina	:= MenuDef()
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( "TPT" )
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
Return FWMVCMenu( "MNTA235" )

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Regras de Modelagem da gravacao

@author NG Informática Ltda.
@since 01/01/2015
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

	Local oModel
	Local oStructTPT := FWFormStruct(1,"TPT")

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("MNTA235")

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields("MNTA235_TPT", Nil, oStructTPT)

	oModel:SetDescription( STR0006 )

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Regras de Interface com o Usuario

@author NG Informática Ltda.
@since 01/01/2015
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

	Local oModel := FWLoadModel("MNTA235")
	Local oView  := FWFormView():New()

	// Objeto do model a se associar a view.
	oView:SetModel(oModel)

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( "MNTA235_TPT" , FWFormStruct(2,"TPT") )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( "MASTER" , 100 )

	// Associa um View a um box
	oView:SetOwnerView( "MNTA235_TPT" , "MASTER" )
	
	// Inclusão de itens no Ações Relacionadas de acordo com o NGRightClick
	NGMVCUserBtn( oView )

Return oView
                                                               
//------------------------------------------------------------------------------
/*/{Protheus.doc} FA235EMAIL
Carrega email do funcionario

@param cCodFun Codigo do Funcionario - Obrigatorio
		cValid	 S ou N					  - Opcional
		
@author Ricardo Dal Ponte
@since 04/09/2006
@version P11
@return cEmail
/*/
//------------------------------------------------------------------------------
 Function fA235Email( cCodFun , cValid )

	Local cEmail:=""
	Local cNgMntRh:=""
	
	//Verifica se existe sistema de RH vinculado
	cNgMntRh := AllTrim( GetMv( "MV_NGMNTRH" ) )
	
	If cNgMntRh $ "SX"
		//Carrega Email do cadastro de funcionarios do sistema de RH (Tabela SRA)
		DbSelectArea( "SRA" )
		DbSetOrder( 1 )
		If Dbseek( xFilial( "SRA" ) + cCodFun )
			If !Empty( SRA->RA_EMAIL )
				cEmail := AllTrim( SRA->RA_EMAIL )
			EndIf
		EndIf
	EndIf
	
	If Empty(cEmail)
		//Carrega Email do cadastro de funcionarios do sistema de MNT (Tabela ST1)
		DbSelectArea( "ST1" )
		DbSetOrder( 1 )
		If Dbseek( xfilial( "ST1" ) + cCodFun )
			If !Empty( ST1->T1_EMAIL )
				cEmail := AllTrim( ST1->T1_EMAIL )
			EndIf
		EndIf
	EndIf
		
	If cValid == "S"
		M->TPT_EMAIL := cEmail
		Return .T.
	EndIf

 Return cEmail

//------------------------------------------------------------------------------
/*/{Protheus.doc} fA235BSDES
Busca a descrição dos campos do browser para apresentar corretamente para os
registro da filial não logada. Visto que a função vDisp não comtempla registros
de outras filiais.

@param cCampo - Campo que está fazendo a busca da descrição.
		
@author Maicon André Pinheiro
@since 13/04/2016
@version P12
@return cDesc - Descrição do cCampo.
/*/
//------------------------------------------------------------------------------
 Function fA235BSDES(cCampo)
 
 	Local cDesc      := ""
 	Local cFilAntBKP := ""
 	
 	If cCampo == 'TPT_DESGRP'
 	
 		cDesc := NGSEEK("TP0",TPT->TPT_CODGRP,1,"TP0_NOMGRP",TPT->TPT_FILIAL) 		
 		
 	ElseIf cCampo == 'TPT_NOMFUN' 	

 		cDesc := NGSEEK("ST1",TPT->TPT_CODFUN,1,"T1_NOME",TPT->TPT_FILIAL)
 		
 	ElseIf cCampo == 'TPT_EMAIL'
 	
 		//É alterado a váriavel cFilAnt, par que ao utilizar o a função 'fA235Email', considere no xFilial
 		//a filial que é utilizada pelo TPT->TPT_FILIAL, e não a filial que está logado.
 		cFilAntBKP := cFilAnt
 		cFilAnt    := TPT->TPT_FILIAL
 		cDesc      := fA235Email(TPT->TPT_CODFUN)
 		cFilAnt    := cFilAntBKP		
 	
 	EndIf

 Return cDesc
