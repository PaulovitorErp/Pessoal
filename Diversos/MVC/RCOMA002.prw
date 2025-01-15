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

User Function RCOMA002()

	Local oBrowse

	Private aRotina
	Private cCadastro := 'Cadastro de Alunos'

	DbSelectArea("ZB2")

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'ZB2' )
	oBrowse:SetDescription( cCadastro )
	
	oBrowse:Activate()

Return

//-------------------------------------------------------------------
// Definicao do Menu
//-------------------------------------------------------------------
Static Function MenuDef()

	aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar'      ACTION 'VIEWDEF.RCOMA002' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'         ACTION 'VIEWDEF.RCOMA002' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'         ACTION 'VIEWDEF.RCOMA002' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'         ACTION 'VIEWDEF.RCOMA002' OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Copiar'          ACTION 'VIEWDEF.RCOMA002' OPERATION 9 ACCESS 0
	
Return aRotina

//-------------------------------------------------------------------
// Define Modelo de Dados
//-------------------------------------------------------------------
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruZB2  := FWFormStruct( 1, 'ZB2', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oModel
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('RCOMP002', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
	
	// Adiciona ao modelo uma estrutura de formulario de edicao por campo
	oModel:AddFields( 'ZB2MASTER', /*cOwner*/, oStruZB2, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	
	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ "ZB2_FILIAL", "ZB2_RA" })
	
	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( 'Cadastro de Alunos' )
	                                       
Return oModel
 

//-------------------------------------------------------------------
// Define camada de Visão
//-------------------------------------------------------------------
Static Function ViewDef()

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel( 'RCOMA002' )
	Local oView
	
	// Cria a estrutura a ser usada na View
	Local oStruZB2 := FWFormStruct( 2, 'ZB2' )
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados ser· utilizado
	oView:SetModel( oModel )
	
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_ZB2', oStruZB2, 'ZB2MASTER' )
	
	// Cria um "box" horizontal para receber cada elemento da view
	oView:CreateHorizontalBox( 'TOTAL'	, 100 )
	  
	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_ZB2', 'TOTAL' )

Return oView