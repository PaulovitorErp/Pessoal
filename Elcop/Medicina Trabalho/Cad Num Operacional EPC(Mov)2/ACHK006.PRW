#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'topconn.ch'
#Include 'tbiconn.ch'
#Include 'APWizard.ch'

#Define ENTER 	Chr(13) + Chr(10)
                                        
/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ACHK007.prw ¦ Autor ¦ Sinval Gedolin ¦ Data ¦ Janeiro/2021 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descrição ¦ Tela de Cadastrodo Num Operacional x EPC           	      ¦¦¦
¦¦¦          ¦ 															  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Objetivo  ¦ 			                                                  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/ 

User Function ACHK007()

	Local oBrowse
	Local aArea := (GetArea())

	//Instânciando FWMBrowse - Somente com dicionário de dados dadadas
	oBrowse := FWmBrowse():New()

	//Setando a tabela
	oBrowse:SetAlias( 'ZCA' )

	//Setando a descrição da rotina
	oBrowse:SetDescription('Número Operacional')
 	oBrowse:SetDetails(.F., {||})
	oBrowse:SetWalkThru(.F.)
	oBrowse:SetAmbiente(.T.) 

	//Adiciona Legenda
	//oBrowse:AddLegend( "ZA0_DIVERG $ ' N'", "GREEN"	, "Sem Divergência"   )
	//oBrowse:AddLegend( "ZA0_DIVERG $ 'S'", "RED"   , "Com Divergência" )

	//Ativa a Browse
	oBrowse:Activate()
	RestArea(aArea)

Return

//----------------------------MenuDef---------------------------------------
/*
Define as operações que serão realizadas pela aplicação.
Na MenuDef da aplicação instanciamos a interface (View) de outra aplicação
*/

Static Function MenuDef()

	Local aRotina := {}

	// Faz referencia a uma VIEWDEF             
	ADD OPTION aRotina TITLE 'Pesquisar'  		ACTION 'PesqBrw'         OPERATION 1 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar' 		Action 'VIEWDEF.ACHK007' OPERATION 2 ACCESS 0
	//ADD OPTION aRotina Title 'Incluir'    		Action 'VIEWDEF.ACHK007' OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'EPCs'     		Action 'VIEWDEF.ACHK007' OPERATION 4 ACCESS 0
	//ADD OPTION aRotina Title 'Excluir'    		Action 'VIEWDEF.ACHK007' OPERATION 5 ACCESS 0
//	ADD OPTION aRotina Title 'Imp MCM Mapa'    	Action 'U_CXMR01()' OPERATION 5 ACCESS 0

Return aRotina

//----------------------------ModelDef---------------------------------------

/*
Define a regra de negócios propriamente dita onde são definidas
* Todas as entidades (tabelas) que farão parte do modelo de dados (Model); 
* Regras de dependência entre as entidades;
* Validações (de campos e aplicação);
* Persistência dos dados (gravação).
*/

Static Function ModelDef()
	Local aArea := GetArea()

	//Cria a estrutura a ser usada no Modelo de Dados
	//							   <nType>, <cAliasSX2>, [bSX3]
	Local oStruZCA := FWFormStruct(1 , 'ZCA', )
	Local oStruZCB := FWFormStruct(1 , 'ZCB', )
    
	//Cria o objeto do Modelo de Dados
	Local oModel := MPFormModel():New('ACHK007A', /*bPre*/, /*bPos*/, /*bCommit*/, /*bCancel*/)

   	//Criação de um componente de formulário no Modelo de Dados (AddFields)
	oModel:AddFields('ZCA_MASTER', 			  , oStruZCA, /*bPre*/, /*bPos*/, /*bLoad*/)

	oModel:AddGrid('ZCB_MODEL'	 ,'ZCA_MASTER', oStruZCB,/*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)       

	//Check List x Grupos de Perguntas
	oModel:SetRelation('ZCB_MODEL', {{'ZCB_FILIAL', 'XFilial("ZCA")'},;
	 								 {'ZCB_NUMOPE' , 'ZCA_NUMOPE'   } },;
	 								 ZCB->(IndexKey(1)))

	//Controle de não repetição de Linha
	oModel:GetModel( 'ZCB_MODEL' ):SetUniqueLine( { 'ZCB_FILIAL', 'ZCB_NUMOPE', 'ZCB_ITEM' } )
		
	//Adicionando descrição ao modelo
	oModel:SetDescription('Cadastro de Num Operacional x EPC')

	//Descrição dos componentes do modelo de dados (SetDescription)
	//Setando a descrição do formulário
	oModel:GetModel('ZCA_MASTER'):SetDescription('Numero Operacional')
	oModel:GetModel('ZCB_MODEL'):SetDescription('Numero Operacional x EPC')
	
	//A Chave Primária é obrigatória, caso não tenha defina um array vazio
	oModel:SetPrimaryKey({'ZCA_FILIAL'}, {'ZCA_NUMOPE'}) // ZA0_FILIAL+ZA0_CARGA   
	
	oStruZCA:SetProperty("ZCA_NUMOPE",MODEL_FIELD_WHEN	,{|| .F. })
	oStruZCA:SetProperty("ZCA_DESCRI",MODEL_FIELD_WHEN	,{|| .F. })
	oStruZCA:SetProperty("ZCA_NUMCON",MODEL_FIELD_WHEN	,{|| .F. })
	oStruZCA:SetProperty("ZCA_CODCLI",MODEL_FIELD_WHEN	,{|| .F. })
	oStruZCA:SetProperty("ZCA_LOJA"	 ,MODEL_FIELD_WHEN	,{|| .F. })
	oStruZCA:SetProperty("ZCA_FILCLI",MODEL_FIELD_WHEN	,{|| .F. })

	RestArea(aArea)
Return oModel

//------------------------------ViewDef-------------------------------------
/*
Define como será a interface (construção da interface) e portanto como o usuario interage com o modelo (Model)
recebe dados informado pelo usuario e fornece ao modelo (modelDef).
*/
Static Function ViewDef()

	Local aArea := GetArea()

	//Cria a estrutura a ser usada na View
	//Construção da interface de visualização. Cria o objeto de View ... Iniciando a construção da interface
	Local oView 	:= FWFormView():New()

	//Cria um objeto de modelo de dados no ModelDef() do fonte informado
	Local oModel 	:= FWLoadModel('ACHK007')

	Local oStruZCA  := FWFormStruct(2 , 'ZCA', {|x|chkCampo('ZCA',alltrim(x))})
	Local oStruZCB  := FWFormStruct(2 , 'ZCB', {|x|chkCampo('ZCB',alltrim(x))})

	//Definimos qual o modelo de dados (Model) que será utilizado na interface (View)
	oView:SetModel(oModel)

	//Adiciona na nossa View um controle do tipo formulário (antiga Enchoice)
	oView:AddField('ZCA_VIEW', oStruZCA, 'ZCA_MASTER')
	
	oView:AddGrid('ZCB_VIEW', oStruZCB , 'ZCB_MODEL')

	// Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'ID_HBOX_SUPERIOR' 	, 20 )    
	oView:CreateHorizontalBox( 'ID_HBOX_INFERIOR'	, 80 )    

	// Quebra em 2 "box" vertical para receber algum elemento da view
	oView:CreateVerticalBox( 'BI_TOT',100, 'ID_HBOX_INFERIOR' )
	
	// Relaciona o identificador (ID) da View com o "box" para exibicao
	oView:SetOwnerView( 'ZCA_VIEW', 'ID_HBOX_SUPERIOR'  )
	
	oView:SetOwnerView( 'ZCB_VIEW' , 'BI_TOT' )

	// Liga a identificacao do componente
	oView:EnableTitleView('ZCA_MASTER', 'Numero Operacional')
	oView:EnableTitleView('ZCB_MODEL' , 'Numero Operacional x EPC')

//	oView:SetFieldAction("ZA0_CARGA"  , {|oView, oModel| addLinha(oView, oModel) } )
//	oView:SetFieldAction("ZA1_QTDCED" , {|oView, oModel| addAtualiza(oView, oModel)})

    oView:AddIncrementField( 'ZCB_VIEW', 'ZCB_ITEM' )

	oView:SetViewProperty("ZCB_VIEW" , "GRIDVSCROLL", {.F.})	
	
	RestArea(aArea)
Return oView
          

/* Define quais campos poderão ou não aparecer nos forms */
static function chkCampo(cAlias,cCampo)
Local lReturn := .T.

if cAlias == "ZA0"
	if alltrim(cCampo) $ "ZA0_DTINC-ZA0_USERIN-ZA0_CODMOT-ZA0_DIVERG-ZA0_VLRTOT-ZA0_VLRDIF"
		lReturn := .F.
	else
		lReturn := .T.	
	endif
endif

if cAlias == "ZCB"
	if alltrim(cCampo) $ "ZCB_NUMOPE-ZCB_LOCDEV"
		lReturn := .F.
	else
		lReturn := .T.	
	endif
endif

return(lReturn)


/* Gatilho para Pegar o Valor da Carga, é realizada conforma o Formas do Pedido 
Uma das possibilidades do valor da Carga não coincidir com o Relatório, poder ser pedidos de troca ou bonificação */
/*
user function fGatCarga()
Local nValCarga := 0
Local _aAreas	:= getArea()                   
Local aFormas	:= {}         

DAK->(DbSetOrder(1))
if DAK->(DbSeek(xFilial("DAK")+ M->ZA0_CARGA))
	nValCarga	:= DAK->DAK_VALOR

	aFormas := OsFormasPg(DAK->DAK_COD,DAK->DAK_SEQCAR)
	if Len(aFormas) == 0
		nValCarga := DAK->DAK_VALOR
	else
		nValCarga := 0
		AEval(aFormas,{|x|nValCarga += x[5]})
	endIf
endif

RestArea(_aAreas)

return(nValCarga)                                                 
*/
