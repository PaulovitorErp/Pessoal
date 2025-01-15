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

User Function RCOMA003()

	Local oBrowse

	Private aRotina
	Private cCadastro := 'Cadastro de Disciplinas'

	DbSelectArea("ZB3")

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'ZB3' )
	oBrowse:SetDescription( cCadastro )
	
	oBrowse:Activate()

Return

//-------------------------------------------------------------------
// Definicao do Menu
//-------------------------------------------------------------------
Static Function MenuDef()

	aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar'      ACTION 'VIEWDEF.RCOMA003' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'         ACTION 'VIEWDEF.RCOMA003' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'         ACTION 'VIEWDEF.RCOMA003' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'         ACTION 'VIEWDEF.RCOMA003' OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Copiar'          ACTION 'VIEWDEF.RCOMA003' OPERATION 9 ACCESS 0
	
Return aRotina

//-------------------------------------------------------------------
// Define Modelo de Dados
//-------------------------------------------------------------------
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruZB3  := FWFormStruct( 1, 'ZB3', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oModel
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('RCOMP003', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
	
	// Adiciona ao modelo uma estrutura de formulario de edicao por campo
	oModel:AddFields( 'ZB3MASTER', /*cOwner*/, oStruZB3, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	
	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ "ZB3_FILIAL", "ZB3_CODIGO" })
	
	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( 'Cadastro de Turmas' )
	                                       
Return oModel
 

//-------------------------------------------------------------------
// Define camada de Visão
//-------------------------------------------------------------------
Static Function ViewDef()

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel( 'RCOMA003' )
	Local oView
	
	// Cria a estrutura a ser usada na View
	Local oStruZB3 := FWFormStruct( 2, 'ZB3' )
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados ser· utilizado
	oView:SetModel( oModel )
	
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_ZB3', oStruZB3, 'ZB3MASTER' )
	
	// Cria um "box" horizontal para receber cada elemento da view
	oView:CreateHorizontalBox( 'TOTAL'	, 100 )
	  
	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_ZB3', 'TOTAL' )

Return oView