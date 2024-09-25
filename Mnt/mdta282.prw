#Include "PROTHEUS.CH"
#Include "MDTA282.CH"

#DEFINE _nVersao 2 //Versao do fonte

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA282
Grupo de Atividades Econômicas

@return

@sample MDTA282()   
@author Guilherme Freudenburg 
@since 24/01/2014
/*/
//---------------------------------------------------------------------
Function MDTA282()    
	
	// Armazena as variáveis
	Local aNGBEGINPRM := NGBEGINPRM( _nVersao )
	
	Local oBrowse
		
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( "TOK" )			// Alias da tabela utilizada
	oBrowse:SetMenuDef( "MDTA282" )		// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription( STR0001 )	// Descrição do browse ###"Grupo de Atividades Econômicas"
	oBrowse:Activate()
	 
	//Retorna variaveis  
	NGRETURNPRM(aNGBEGINPRM)
Return 

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Opções de menu 
 
@author Guilherme Freudenburg
@since 29/01/2014
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
//Inicializa MenuDef com todas as opções
Return FWMVCMenu( "MDTA282" )
//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do Modelo (padrão MVC).
 
@author Guilherme Freudenburg
@since 24/01/2014

@return oModel objeto do Modelo MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

//Cria a estrutura a ser usada no Modelo de Dados

Local oStruTOK :=FWFormStruct( 1, 'TOK')
Local oStruTOE :=FWFormStruct( 1, 'TOE')

Local oModel//Modelo de dados que será construido

	//Retira campo obrigatório do Model, já que não será apresentado
	oStruTOE:RemoveField("TOE_GRUPO")

	//Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( "MDTA282" , /*bPre*/ , /*bPos*/ , /*bCommit*/ , /*bCancel*/ )  
 
	//Adiciona ao modelo um componente de formulario
	oModel:AddFields( 'TOKMASTER',/*cOwner*/,oStruTOK)

	//Adiciona ao modelo uma componente de grid
	oModel:AddGrid( 'TOEDETAIL', 'TOKMASTER', oStruTOE )     
 
	//Faz relacionamento entre os componentes do model
	oModel:setRelation( 'TOEDETAIL', { { 'TOE_FILIAL', 'xFILIAL( "TOE" )'}, { 'TOE_GRUPO','TOK_GRUPO' }},/*TOE->( IndexKey( 1 ))*/) 
	oModel:SetPrimaryKey( { "TOK_FILIAL", "TOK_GRUPO" } )
	
	// Liga o controle de nao repeticao de linha
	oModel:GetModel( 'TOEDETAIL' ):SetUniqueLine( { 'TOE_CNAE' } )

	// Indica que é opcional ter dados informados na Grid  
	oModel:GetModel( 'TOEDETAIL' ):SetOptional(.T.)
	
	oModel:GetModel('TOKMASTER' ):SetDescription( STR0001 ) // "Grupos de Atividasdes Econômicas"
	oModel:GetModel('TOEDETAIL' ):SetDescription( STR0002 ) // "Atividades Econômicas" 
	
//Retorna o Modelo de dados  
Return oModel   
	

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da View (padrão MVC).

@author Guilherme Freudenburg
@since 24/01/2014  

@return oView objeto da View MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

//Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado 

Local oModel:= FWLoadModel ( 'MDTA282' )  

//Cria as estruturas a semre usadas na View: 
Local oStruTOK := FWFormStruct(2, 'TOK' )
Local oStruTOE := FWFormStruct(2, 'TOE' )

//Interface de Visualização construida
   
Local oView

	//Define qual Modele de dados será utilizado
	oView := FWFormView():New() 

	// Objeto do model a se associar a view.
	oView:SetModel( oModel )

	//Adiciona o nosso view um controle de tipo formulario (antiga enchoice)
	oView:AddField ('VIEW_TOK', oStruTOK, 'TOKMASTER' )  

	//Adiciona um titulo para o formulário
	oView:EnableTitleView( 'VIEW_TOK' ,STR0003 ) // "Cadastro dos Grupos de Atividasdes Econômicas"

	//Adiciona ao View um controle tipo Grid (antiga getdados)
	oView:AddGrid ( 'VIEW_TOE', oStruTOE, 'TOEDETAIL' )  
	
	//Adiciona um titulo para o grid
	oView:EnableTitleView('VIEW_TOE' , STR0002 ) // "Atividades Econômicas"  

	//Cria um box horizontal para receber cada elemento da View     
	oView:CreateHorizontalBox( 'SUPERIOR', 25)
	oView:CreateHorizontalBox( 'INFERIOR', 75)

	//Relaciona o indentificardor da View com a box para exibição 
	oView:SetOwnerView( 'VIEW_TOK' , 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_TOE' , 'INFERIOR' )  
	
	//Retira campo obrigatório do Model, já que não será apresentado
	oStruTOE:RemoveField("TOE_GRUPO")  
 
//Retorna o modelo visual
Return oView