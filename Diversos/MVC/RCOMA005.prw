#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} RFATA002

//Cadastro de Produtos X Licenças

@author danilo
@since 07/02/2018
@version 1.0
@return Nil

@type function
/*/
User function RCOMA005()

	Local oBrowse

	Private aRotina
	Private cCadastro := 'Cadastro Turma Vs Aluno Vs Notas'

	DbSelectArea("ZB1")
	DbSelectArea("ZB6")
	DbSelectArea("ZB7")

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'ZB1' )
	oBrowse:SetDescription( cCadastro )
	
	oBrowse:Activate()

Return

//-------------------------------------------------------------------
// Definicao do Menu
//-------------------------------------------------------------------
Static Function MenuDef()

	aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar'      ACTION 'VIEWDEF.RCOMA005' OPERATION 2 ACCESS 0
	//ADD OPTION aRotina TITLE 'Incluir'         ACTION 'VIEWDEF.RCOMA005' OPERATION 3 ACCESS 0
	//ADD OPTION aRotina TITLE 'Excluir'         ACTION 'VIEWDEF.RCOMA005' OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Matricular'      ACTION 'VIEWDEF.RCOMA005' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Copiar'          ACTION 'VIEWDEF.RCOMA005' OPERATION 9 ACCESS 0

Return aRotina

//-------------------------------------------------------------------
// Define Modelo de Dados
//-------------------------------------------------------------------
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	//Local oStruZB1  := FWFormStruct( 1, 'SB1', {|cCampo| Alltrim(cCampo) $ "B1_COD,B1_DESC" },/*lViewUsado*/ )
	Local oStruZB1  := FWFormStruct( 1, 'ZB1', /*bAvalCampo*/,/*lViewUsado*/ ) //FWFormStruct( 1, 'SB1', {|cCampo| Alltrim(cCampo) $ "B1_COD,B1_DESC" },/*lViewUsado*/ )
	Local oStruZB6  := FWFormStruct( 1, 'ZB6', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oStruZB7  := FWFormStruct( 1, 'ZB7', /*bAvalCampo*/,/*lViewUsado*/ )
	
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('RCOMT005', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
								
	// Adiciona ao modelo uma estrutura de formulario de edicao por campo
	oModel:AddFields( 'ZB1MASTER', /*cOwner*/, oStruZB1, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ "ZB1_FILIAL", "ZB1_CODIGO" })

	// Adiciona ao modelo uma componente de grid
	oModel:AddGrid( 'ZB6DETAIL', 'ZB1MASTER', oStruZB6 , /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	oModel:AddGrid( 'ZB7DETAIL', 'ZB6DETAIL', oStruZB7 , /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	
	// Faz relacionamento entre os componentes do model
	oModel:SetRelation( 'ZB6DETAIL', { {'ZB6_FILIAL', 'ZB1_FILIAL'}, {'ZB6_CODTUR', 'ZB1_CODIGO'} }, ZB6->( IndexKey( 1 ) ) )//tarcisio duvida
	oModel:SetRelation( 'ZB7DETAIL', { {'ZB7_FILIAL', 'ZB1_FILIAL'}, {'ZB7_CODTUR', 'ZB1_CODIGO'}, {'ZB7_RA', 'ZB6_RA'} }, ZB7->( IndexKey( 1 ) ) )//tarcisio duvida

	
	// Liga o controle de nao repeticao de linha
	oModel:GetModel( 'ZB6DETAIL' ):SetUniqueLine( { 'ZB6_RA' } )//tarcisio duvida
	oModel:GetModel( 'ZB7DETAIL' ):SetUniqueLine( { 'ZB7_CODDIS' } )//tarcisio duvida

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( 'Turmas Vs Aluno' )

	// Adiciona a descrição dos Componentes do Modelo de Dados
	oModel:GetModel( 'ZB6DETAIL' ):SetDescription( 'Turmas Vs Aluno' )
	oModel:GetModel( 'ZB7DETAIL' ):SetDescription( 'Notas Vs Aluno' )
	
	// tira obrigatoriedade de incluir linha
	oModel:GetModel( 'ZB6DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'ZB7DETAIL' ):SetOptional(.T.)

Return oModel

//-------------------------------------------------------------------
// Define camada de Visão
//-------------------------------------------------------------------
Static Function ViewDef()

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel( 'RCOMA005' )
	Local oView

	// Cria a estrutura a ser usada na View
	//Local oStruSB1 := FWFormStruct( 2, 'SB1', {|cCampo| Alltrim(cCampo) $ "B1_COD,B1_DESC" },/*lViewUsado*/ )
	Local oStruZB1 := FWFormStruct( 2, 'ZB1', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oStruZB6 := FWFormStruct( 2, 'ZB6', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oStruZB7 := FWFormStruct( 2, 'ZB7', /*bAvalCampo*/,/*lViewUsado*/ )
	
	//removo as pastas
	//oStruSB1:aFolders := {}

	// Remove campos da estrutura
	oStruZB7:RemoveField('ZB7_RA')
	oStruZB7:RemoveField('ZB7_FILIAL')
	oStruZB7:RemoveField('ZB7_CODTUR')


	
	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados ser· utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_ZB1', oStruZB1, 'ZB1MASTER' )

	//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oView:AddGrid( 'VIEW_ZB6', oStruZB6, 'ZB6DETAIL' )
	oView:AddGrid( 'VIEW_ZB7', oStruZB7, 'ZB7DETAIL' )

	// Cria um "box" horizontal para receber cada elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR'	, 20 )
	oView:CreateHorizontalBox( 'MEIO'		, 40 )
	oView:CreateHorizontalBox( 'INFERIOR'	, 40 )

	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_ZB1', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_ZB6', 'MEIO' )
	oView:SetOwnerView( 'VIEW_ZB7', 'INFERIOR' )

	
	// titulo dos componentes
	oView:EnableTitleView('VIEW_ZB6' , /*'item'*/)
	oView:EnableTitleView('VIEW_ZB7' , /*'item'*/)

	
	//coloca cabeçalho apenas para visualizar.
	oView:SetOnlyView("ZB1MASTER")

Return oView