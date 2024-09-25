#INCLUDE "MNTA285.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-----------------------------------------------------------
/*/{Protheus.doc} MNTA285
Programa de Tipo de Servicos da S.S.

@author Lucas Guszak
@since 04/07/2014
@version MP11
@return Nil
/*/
//-----------------------------------------------------------
Function MNTA285()

	Local aNGBeginPrm := {}
	Local oBrowse

	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 19, 95 )

		aNGBeginPrm := NGBeginPrm()

		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias( "TQ3" ) // Alias da tabela utilizada
		oBrowse:SetMenuDef( "MNTA285" )  // Nome do fonte onde esta a função MenuDef
		oBrowse:SetDescription( STR0001 ) // Descrição do browse // "Tipo de Servicos da SS"
		oBrowse:Activate()

		NGReturnPrm( aNGBeginPrm )

	EndIf

Return

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

	Local oStruct285 := FWFormStruct( 1, "TQ3" )
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( "MNTA285", Nil, Nil, Nil, Nil)

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( "MNTA285_TQ3", Nil, oStruct285 )
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

	Local oModel := FWLoadModel( "MNTA285" )
	Local oStruct285 := FWFormStruct( 2, "TQ3" )
	Local oView
	Private lFacilities := SuperGetMv("MV_NG1FAC",.F.,"2") == '1'

	oView := FWFormView():New()

	// Objeto do model a se associar a view.
	oView:SetModel( oModel )
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( "MNTA285_TQ3" , oStruct285, Nil )
	// Criar um "box" horizontal para receber elementos da view
	oView:CreateHorizontalBox( "TELA", 100 )
	// Associa um View a um box
	oView:SetOwnerView( "MNTA285_TQ3", "TELA" )

	//Remove o campo quando não habilitado ao Facilities
	If lFacilities
		oStruct285:RemoveField("TQ3_PESQST")
	EndIf
	
	oStruct285:RemoveField("TQ3_DISTRI")

	//Inclusão de itens nas Ações Relacionadas de acordo com O NGRightClick
	NGMVCUserBtn(oView)

Return oView

//-----------------------------------------------------------
/*/{Protheus.doc} MenuDef
Interface da rotina

@author Lucas Guszak
@since 04/07/2014
@version MP11
@return FWMVCMenu( "MNTA285" )
/*/
//-----------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "MNTA285" )

//-----------------------------------------------------------
/*/{Protheus.doc} MNTA285EX
Executantes da Solicitacao de Servico

@author Ricardo Dal Ponte
@since 07/11/2006
@version MP11
@return .T.
/*/
//-----------------------------------------------------------
Function MNTA285EX(cTipo)

	Local cAlias := Alias()
	Local cSavOrd := IndexOrd()
	Local cCodUser := CriaVar("AN_USER")
	Local nLen
	PswOrder(2)

	If cTipo == "1"
	   If PswSeek(M->TQ3_CDRESP)
		   cCodUser := PswRet(1)[1][1]
		Else
			//MsgStop(STR0007,STR0008) //"Usuário não cadastrado."###"ATENÇÃO"
			Return .F.
	   EndIf
	Else
	   If PswSeek(TQ3->TQ3_CDRESP)
		   cCodUser := PswRet(1)[1][1]
	   EndIf
	Endif

	dbSelectArea(cAlias)
	dbSetOrder(cSavOrd)

	If cTipo == "1" .Or. cTipo == "2"
	   cNMEXEC := Alltrim(SubStr(UsrFullName(cCodUser), 1, 40))
	   nLen := 40-len(cNMEXEC)
	   M->TQ3_NMRESP := cNMEXEC+Space(nLen)
	Endif

	If cTipo == "1" .Or. cTipo == "3"
	   cEMAIL1 := Alltrim(SubStr(UsrRetMail(cCodUser), 1, 50))
	   nLen := 50-len(cEMAIL1)
	   M->TQ3_EMAIL := cEMAIL1+Space(nLen)
	EndIf

	If cTipo == "2"
		Return M->TQ3_NMRESP
	Endif

	If cTipo == "3"
		Return M->TQ3_EMAIL
	Endif

Return .T.
