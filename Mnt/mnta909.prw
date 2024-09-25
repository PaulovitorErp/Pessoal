#INCLUDE "MNTA909.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-----------------------------------------------------------
/*/{Protheus.doc} MNTA909
Manutenção da tabela de Complemento de Usuários

@author Lucas Guszak
@since 04/07/2014
@version MP11
@return Nil
/*/
//-----------------------------------------------------------
Function MNTA909()

	Local aNGBEGINPRM := NGBEGINPRM(, "MNTA909" )
	Local oBrowse

	//Verifica se o update de facilities foi aplicado
	If !FindFunction("MNTUPDFAC") .or. !MNTUPDFAC()
		NGRETURNPRM(aNGBEGINPRM)
		Return .F.
	Endif

	MNTA909TUF()

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( "TUF" ) // Alias da tabela utilizada
	oBrowse:SetMenuDef( "MNTA909" )  // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription( STR0001 ) // Descrição do browse // "Complemento de Usuários"
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

	Local oStruct909 := FWFormStruct( 1, "TUF" )
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( "MNTA909", Nil, Nil, Nil, Nil)

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( "MNTA909_TUF", Nil, oStruct909 )
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

	Local oModel := FWLoadModel( "MNTA909" )
	Local oStruct909 := FWFormStruct( 2, "TUF" )
	Local oView

	oView := FWFormView():New()

	// Objeto do model a se associar a view.
	oView:SetModel( oModel )
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( "MNTA909_TUF" , oStruct909, Nil )
	// Criar um "box" horizontal para receber elementos da view
	oView:CreateHorizontalBox( "TELA", 100 )
	// Associa um View a um box
	oView:SetOwnerView( "MNTA909_TUF", "TELA" )

	//Inclusão de itens nas Ações Relacionadas de acordo com O NGRightClick
	NGMVCUserBtn(oView)

Return oView

//-----------------------------------------------------------
/*/{Protheus.doc} MenuDef
Interface da rotina

@author Lucas Guszak
@since 04/07/2014
@version MP11
@return FWMVCMenu( "MNTA909" )
/*/
//-----------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.MNTA909' OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.MNTA909' OPERATION 4 ACCESS 0 //"Alterar"

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA909TUF
Faz carga automatica da tabela TUF com os usuarios do sistema

@author Roger Rodrigues
@since 03/11/2011
@version MP10/MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function MNTA909TUF()

	Local aArea  := GetArea()
	Local aUsers := {}
	Local i
	Local lFacilit := If(FindFunction("MNTINTFAC"), MNTINTFAC(), .F.)

	If !lFacilit
		Return Nil
	EndIf

	aUsers := FWSFALLUSERS()

	If Len(aUsers) != TUF->(Reccount())
		For i:=1 to Len(aUsers)
			dbSelectArea("TUF")
			dbSetOrder(1)
			If !dbSeek(xFilial("TUF")+aUsers[i][2])
				RecLock("TUF",.T.)
				TUF->TUF_FILIAL := xFilial("TUF")
				TUF->TUF_CODUSR := aUsers[i][2]
				MsUnlock("TUF")
			Endif
		Next i

		dbSelectArea("TUF")
		dbSetOrder(1)
		dbSeek(xFilial("TUF"))
		While !Eof() .and. xFilial("TUF") == TUF->TUF_FILIAL
			If aScan(aUsers, {|x| x[2] == TUF->TUF_CODUSR}) == 0
				RecLock("TUF",.F.)
				dbDelete()
				MsUnlock("TUF")
			EndIf
			dbSelectArea("TUF")
			dbSkip()
		End
	EndIf
	RestArea(aArea)

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT909REL
Retorna conteudo dos campos virtuais da tabela

@param cCampo Campo do conteudo a ser retornado
@param lIniBrw Indica se é chamado pelo Browse

@author Roger Rodrigues
@since 03/11/2011
@version MP10/MP11
@return xRetorno
/*/
//---------------------------------------------------------------------
Function MNT909REL(cCampo, lIniBrw, cCodUsr)

	Local xRetorno := ""
	Local aRetPsw := {}
	Default lIniBrw := .F.
	Default cCodUsr := TUF->TUF_CODUSR

	PswOrder(1)
	If PswSeek(cCodUsr)
		aRetPsw := PswRet()
	Endif
	dbSelectArea("TUF")
	dbSetOrder(1)
	dbSeek(xFilial("TUF")+cCodUsr)
	If Len(aRetPsw) > 0
		If cCampo == "TUF_LOGUSR"
			xRetorno := aRetPsw[1][2]
		ElseIf cCampo == "TUF_NOMUSR"
			xRetorno := aRetPsw[1][4]
		ElseIf cCampo == "TUF_DEPUSR"
			xRetorno := aRetPsw[1][12]
		ElseIf cCampo == "TUF_CARUSR"
			xRetorno := aRetPsw[1][13]
		ElseIf cCampo == "TUF_EMAUSR"
			xRetorno := aRetPsw[1][14]
		ElseIf cCampo == "TUF_RAMUSR"
			If (Empty(TUF->TUF_RAMUSR) .or. Inclui) .and. !Empty(aRetPsw[1][20])
				xRetorno := aRetPsw[1][20]
			ElseIf !Inclui
				xRetorno := TUF->TUF_RAMUSR
			Endif
		ElseIf cCampo == "TUF_TE1USR"
			xRetorno := TUF->TUF_TE1USR
		ElseIf cCampo == "TUF_TE2USR"
			xRetorno := TUF->TUF_TE2USR
		Endif
	Endif

Return xRetorno
