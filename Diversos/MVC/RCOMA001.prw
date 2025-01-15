#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} RFINA002

Cadastro de Base Premio CLT Comissão

@author Danilo Brito
@since 16/02/2017
@version P12
@param Nao recebe parametros
@return nulo
/*/

User Function RCOMA001()

	Local oBrowse

	Private aRotina
	Private cCadastro := 'Cadastro de Turmas'

	DbSelectArea("ZB1")

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

	ADD OPTION aRotina TITLE 'Visualizar'      ACTION 'VIEWDEF.RCOMA001' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'         ACTION 'VIEWDEF.RCOMA001' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'         ACTION 'VIEWDEF.RCOMA001' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'         ACTION 'VIEWDEF.RCOMA001' OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Copiar'          ACTION 'VIEWDEF.RCOMA001' OPERATION 9 ACCESS 0
	
Return aRotina

//-------------------------------------------------------------------
// Define Modelo de Dados
//-------------------------------------------------------------------
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruZB1  := FWFormStruct( 1, 'ZB1', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oModel
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('RCOMP001', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
	
	// Adiciona ao modelo uma estrutura de formulario de edicao por campo
	oModel:AddFields( 'ZB1MASTER', /*cOwner*/, oStruZB1, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	
	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ "ZB1_FILIAL", "ZB1_CODIGO" })
	
	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( 'Cadastro de Turmas' )
	                                       
Return oModel
 

//-------------------------------------------------------------------
// Define camada de Visão
//-------------------------------------------------------------------
Static Function ViewDef()

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel( 'RCOMA001' )
	Local oView
	
	// Cria a estrutura a ser usada na View
	Local oStruZB1 := FWFormStruct( 2, 'ZB1' )
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados ser· utilizado
	oView:SetModel( oModel )
	
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_ZB1', oStruZB1, 'ZB1MASTER' )
	
	// Cria um "box" horizontal para receber cada elemento da view
	oView:CreateHorizontalBox( 'TOTAL'	, 100 )
	  
	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_ZB1', 'TOTAL' )

Return oView