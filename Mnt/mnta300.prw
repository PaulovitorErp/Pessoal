#INCLUDE "MNTA300.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE _nVERSAO 1 //Versao do fonte
//-----------------------------------------------------------
/*/{Protheus.doc} MNTA300
Programa de Executantes da Solicitacao de Servico

@author Lucas Guszak
@since 04/07/2014
@version MP11
@return Nil
/*/
//-----------------------------------------------------------
Function MNTA300()

	Local aNGBEGINPRM := NGBEGINPRM( _nVERSAO, "MNTA300" )
	Local oBrowse
	
	//Verifica se o update de facilities foi aplicado
	If FindFunction("MNTUPDFAC") .And. MNTUPDFAC(.F.)
		ShowHelpDlg(STR0007, {STR0008},1,{STR0009}) //"ATENÇÃO" ## "O sistema está utilizando o Módulo Facilities. Desta forma, os executantes das solicitações de serviços são os funcionários da manutenção." ## "Será redirecionado para o cadastro de funcionários."
		MNTA020()
		Return .F.
	Endif
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( "TQ4" ) // Alias da tabela utilizada
	oBrowse:SetMenuDef( "MNTA300" )  // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription( STR0001 ) // Descrição do browse // "Executantes da Solicitacao de Servico"
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

	Local oStruct300 := FWFormStruct( 1, "TQ4" )
	Local oModel
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( "MNTA300", Nil, Nil, Nil, Nil)
	
	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( "MNTA300_TQ4", Nil, oStruct300 )
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

	Local oModel := FWLoadModel( "MNTA300" )
	Local oStruct300 := FWFormStruct( 2, "TQ4" )
	Local oView
	
	oView := FWFormView():New()
	
	// Objeto do model a se associar a view.
	oView:SetModel( oModel )
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( "MNTA300_TQ4" , oStruct300, Nil )
	// Criar um "box" horizontal para receber elementos da view
	oView:CreateHorizontalBox( "TELA", 100 )
	// Associa um View a um box
	oView:SetOwnerView( "MNTA300_TQ4", "TELA" )
	//Inclusão de itens nas Ações Relacionadas de acordo com O NGRightClick
  NGMVCUserBtn(oView)

Return oView

//-----------------------------------------------------------
/*/{Protheus.doc} MenuDef
Interface da rotina

@author Lucas Guszak
@since 04/07/2014
@version MP11
@return FWMVCMenu( "MNTA300" )
/*/
//-----------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "MNTA300" )

//-----------------------------------------------------------
/*/{Protheus.doc} MNTA300EX
Executantes da Solicitacao de Servico

@author Ricardo Dal Ponte
@since 07/11/2006
@version MP11
@return .T.
/*/
//-----------------------------------------------------------
Function MNTA300EX(cTipo)

	Local cAlias := Alias()
	Local cSavOrd := IndexOrd()
	Local cCodUser := CriaVar("AN_USER")
	Local nLen
	
	PswOrder(2)
	
	If cTipo == "1"
	   If PswSeek(M->TQ4_CDEXEC)
		   cCodUser := PswRet(1)[1][1]
	   EndIf
	Else
	   If PswSeek(TQ4->TQ4_CDEXEC)
		   cCodUser := PswRet(1)[1][1]
	   EndIf
	Endif
	
	dbSelectArea(cAlias)
	dbSetOrder(cSavOrd)
	
	If cTipo == "1" .Or. cTipo == "2"
	   cNMEXEC := Alltrim(SubStr(UsrFullName(cCodUser), 1, 40))
	   nLen := 40-len(cNMEXEC)
	   M->TQ4_NMEXEC := cNMEXEC+Space(nLen)
	Endif
	
	If cTipo == "1" .Or. cTipo == "3"
	   cEMAIL1 := Alltrim(SubStr(UsrRetMail(cCodUser), 1, 50))
	   nLen := 50-len(cEMAIL1)
	   M->TQ4_EMAIL1 := cEMAIL1+Space(nLen)   
	EndIf
	
	If cTipo == "2"
		Return M->TQ4_NMEXEC
	Endif
	
	If cTipo == "3"
		Return M->TQ4_EMAIL1
	Endif
	
Return .T.
