#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
#Include "MDTA998.CH"

#DEFINE _nVersao 3 //Versao do fonte

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA998
Cadastro de Grupos de Perguntas do novo Questionario IPS

@author André Felipe Joriatti
@since 09/07/2013
@version MP11
@return lRet
/*/
//---------------------------------------------------------------------

Function MDTA998()

	//---------------------------------------------
	// Guarda conteúdo e declara variáveis padrões
	//---------------------------------------------

	Local aNGBEGINPRM := NGBEGINPRM( _nVersao )

	Local cCadastro   := STR0001 // "Grupo de Perguntas"
	Local oBrowse     := Nil

	If !MDT999COMPQ()

		//---------------------------------------
		// Retorna conteúdo de variáveis padrões
		//---------------------------------------
		NGRETURNPRM( aNGBEGINPRM )

		Return Nil
	EndIf

	DbSelectArea( "TJ4" )
	DbSetOrder( 01 ) // TJ4_FILIAL+TJ4_CODGRU
	DbGoTop()

	oBrowse := FWMBrowse():New()
		oBrowse:SetAlias( "TJ4" )
		oBrowse:SetMenuDef( "MDTA998" )
		oBrowse:SetDescription( cCadastro )
		oBrowse:Activate()

	//---------------------------------------
	// Retorna conteúdo de variáveis padrões
	//---------------------------------------
	NGRETURNPRM( aNGBEGINPRM )
	
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Opções de menu

@author André Felipe Joriatti
@since 09/07/2013
@version P11
@return aRotina - Estrutura
	[n,1] Nome a aparecer no cabecalho
	[n,2] Nome da Rotina associada
	[n,3] Reservado
	[n,4] Tipo de Transação a ser efetuada:
		1 - Pesquisa e Posiciona em um Banco de Dados
		2 - Simplesmente Mostra os Campos
		3 - Inclui registros no Bancos de Dados
		4 - Altera o registro corrente
		5 - Remove o registro corrente do Banco de Dados
		6 - Alteração sem inclusão de registros
		7 - Cópia
		8 - Imprimir
	[n,5] Nivel de acesso
	[n,6] Habilita Menu Funcional
/*/
//---------------------------------------------------------------------

Static Function MenuDef()
	// Inicializa MenuDef com todas as opções
Return FWMVCMenu( "MDTA998" )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Regras de Modelagem da gravacao

@author André Felipe Joriatti
@since 09/07/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Static Function ModelDef()

	Local oModel

	Local oStructTJ4

	oStructTJ4 := FWFormStruct( 1,"TJ4" )

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( "MDTA998",/*bPre*/,/*bValidInfo*/,/*bCommit*/,  /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( "MDTA998_TJ4", Nil, oStructTJ4,/*bPre*/,/*bPost*/,/*bLoad*/ )

	// Descrição do Model
	oModel:SetDescription( STR0008 ) // "Grupos de Perguntas"

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Regras de Interface com o Usuario

@author André Felipe Joriatti
@since 09/07/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Static Function ViewDef()

	Local oModel := FWLoadModel( "MDTA998" )
	Local oView  := Nil

	oStruTJ4 := FWFormStruct( 2,"TJ4" )
	
	oView := FWFormView():New()
	
	// Objeto do model a se associar a view.
	oView:SetModel( oModel )

	// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( "MDTA998_TJ4" , oStruTJ4 , /*cLinkID*/ )	//
	
	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )

	// Associa um View a um box
	oView:SetOwnerView( "MDTA998_TJ4" , "MASTER" )
	
	// Inclusão de itens no Ações Relacionadas de acordo com o NGRightClick
	NGMVCUserBtn( oView )

Return oView
//---------------------------------------------------------------------
/*/{Protheus.doc} FILSXBTJ4()
Filtra consulta padrão TJ4.

@author Guilherme Benkendorf
@since 06/10/2014
@return Boolean lRet: conforme o filtro executado.
@version MP11
/*/
//---------------------------------------------------------------------
Function FILSXBTJ4()

	Local lRet := .T.

	If IsInCallStack( "MDTA992CAD" )
		lRet := AllTrim( NGSeek( "TJ3" , TJ4->TJ4_CODGRU + M->TI5_QUESTI, 4 , "TJ3_QUESTI" ) ) == AllTrim( M->TI5_QUESTI ) .And. TJ4->TJ4_TIPREG <> "2"
	EndIf		
Return lRet