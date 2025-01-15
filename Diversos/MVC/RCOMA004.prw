#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} RFATA002

//Cadastro de Produtos X Licen�as

@author danilo
@since 07/02/2018
@version 1.0
@return Nil

@type function
/*/
User function RCOMA004()

	Local oBrowse

	Private aRotina
	Private cCadastro := 'Cadastro Turma Vs Aluno'

	DbSelectArea("ZB1")
	DbSelectArea("ZB6")

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

	ADD OPTION aRotina TITLE 'Visualizar'      ACTION 'VIEWDEF.RCOMA004' OPERATION 2 ACCESS 0
	//ADD OPTION aRotina TITLE 'Incluir'         ACTION 'VIEWDEF.RCOMA004' OPERATION 3 ACCESS 0
	//ADD OPTION aRotina TITLE 'Excluir'         ACTION 'VIEWDEF.RCOMA004' OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Matricular'      ACTION 'VIEWDEF.RCOMA004' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Copiar'          ACTION 'VIEWDEF.RCOMA004' OPERATION 9 ACCESS 0

Return aRotina

//-------------------------------------------------------------------
// Define Modelo de Dados
//-------------------------------------------------------------------
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	//Local oStruZB1  := FWFormStruct( 1, 'SB1', {|cCampo| Alltrim(cCampo) $ "B1_COD,B1_DESC" },/*lViewUsado*/ )
	Local oStruZB1  := FWFormStruct( 1, 'ZB1', /*bAvalCampo*/,/*lViewUsado*/ ) //FWFormStruct( 1, 'SB1', {|cCampo| Alltrim(cCampo) $ "B1_COD,B1_DESC" },/*lViewUsado*/ )
	Local oStruZB6  := FWFormStruct( 1, 'ZB6', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('RCOMT004', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
								
	// Adiciona ao modelo uma estrutura de formulario de edicao por campo
	oModel:AddFields( 'ZB1MASTER', /*cOwner*/, oStruZB1, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ "ZB1_FILIAL", "ZB1_CODIGO" })

	// Adiciona ao modelo uma componente de grid
	oModel:AddGrid( 'ZB6DETAIL', 'ZB1MASTER', oStruZB6 , /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Faz relacionamento entre os componentes do model
	oModel:SetRelation( 'ZB6DETAIL', { {'ZB6_FILIAL', 'ZB1_FILIAL'}, {'ZB6_CODTUR', 'ZB1_CODIGO'} }, ZB6->( IndexKey( 1 ) ) )//tarcisio duvida

	// Liga o controle de nao repeticao de linha
	oModel:GetModel( 'ZB6DETAIL' ):SetUniqueLine( { 'ZB6_RA' } )//tarcisio duvida

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( 'Turmas Vs Aluno' )

	// Adiciona a descri��o dos Componentes do Modelo de Dados
	oModel:GetModel( 'ZB6DETAIL' ):SetDescription( 'Turmas Vs Aluno' )

	// tira obrigatoriedade de incluir linha
	oModel:GetModel( 'ZB6DETAIL' ):SetOptional(.T.)

Return oModel

//-------------------------------------------------------------------
// Define camada de Vis�o
//-------------------------------------------------------------------
Static Function ViewDef()

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel( 'RCOMA004' )
	Local oView

	// Cria a estrutura a ser usada na View
	//Local oStruSB1 := FWFormStruct( 2, 'SB1', {|cCampo| Alltrim(cCampo) $ "B1_COD,B1_DESC" },/*lViewUsado*/ )
	Local oStruZB1 := FWFormStruct( 2, 'ZB1', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oStruZB6 := FWFormStruct( 2, 'ZB6', /*bAvalCampo*/,/*lViewUsado*/ )
	
	//removo as pastas
	//oStruSB1:aFolders := {}

	// Remove campos da estrutura
	//oStruSZ2:RemoveField( 'Z2_PROD' )

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados ser� utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_ZB1', oStruZB1, 'ZB1MASTER' )

	//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oView:AddGrid( 'VIEW_ZB6', oStruZB6, 'ZB6DETAIL' )

	// Cria um "box" horizontal para receber cada elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR'	, 20 )
	oView:CreateHorizontalBox( 'INFERIOR'	, 80 )

	// Relaciona o identificador (ID) da View com o "box" para exibi��o
	oView:SetOwnerView( 'VIEW_ZB1', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_ZB6', 'INFERIOR' )

	// titulo dos componentes
	oView:EnableTitleView('VIEW_ZB6' , /*'item'*/)

	//coloca cabe�alho apenas para visualizar.
	oView:SetOnlyView("ZB1MASTER")

Return oView