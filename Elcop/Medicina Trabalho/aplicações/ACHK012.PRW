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
¦¦¦Programa  ¦ ACHK012.prw ¦ Autor ¦ Sinval Gedolin ¦ Data ¦ Janeiro/2021 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descrição ¦ Tela de Cadastrodo Grupo NUm Operacional x EPC     	      ¦¦¦
¦¦¦          ¦ 															  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Objetivo  ¦ 			                                                  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/ 

User Function ACHK012()

	Local oBrowse
	Local aArea := (GetArea())

	//Instânciando FWMBrowse - Somente com dicionário de dados dadadas
	oBrowse := FWmBrowse():New()

	//Setando a tabela
	oBrowse:SetAlias( 'ZCF' )

	//Setando a descrição da rotina
	oBrowse:SetDescription('Grupo do Número Operacional')
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
	ADD OPTION aRotina Title 'Visualizar' 		Action 'VIEWDEF.ACHK012' OPERATION 2 ACCESS 0
	//ADD OPTION aRotina Title 'Incluir'    		Action 'VIEWDEF.ACHK006' OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'EPCs'     		Action 'VIEWDEF.ACHK012' OPERATION 4 ACCESS 0
	//ADD OPTION aRotina Title 'Excluir'    		Action 'VIEWDEF.ACHK006' OPERATION 5 ACCESS 0
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
	Local oStruZCF := FWFormStruct(1 , 'ZCF', )
	Local oStruZCG := FWFormStruct(1 , 'ZCG', )
    
	//Cria o objeto do Modelo de Dados
	Local oModel := MPFormModel():New('ACHK012A', /*bPre*/, /*bPos*/, /*bCommit*/, /*bCancel*/)

   	//Criação de um componente de formulário no Modelo de Dados (AddFields)
	oModel:AddFields('ZCF_MASTER', 			  , oStruZCF, /*bPre*/, /*bPos*/, /*bLoad*/)

	oModel:AddGrid('ZCG_MODEL'	 ,'ZCF_MASTER', oStruZCG,/*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)       

	//Check List x Grupos de Perguntas
	oModel:SetRelation('ZCG_MODEL', {{'ZCG_FILIAL', 'XFilial("ZCF")'},;
	 								 {'ZCG_CODGRU' , 'ZCF_CODGRU'   } },;
	 								 ZCG->(IndexKey(1)))

	//Controle de não repetição de Linha
	oModel:GetModel( 'ZCG_MODEL' ):SetUniqueLine( { 'ZCG_FILIAL', 'ZCG_CODGRU', 'ZCG_CODEPC' } )
		
	//Adicionando descrição ao modelo
	oModel:SetDescription('Cadastro de Grupo Num Operacional x EPC')

	//Descrição dos componentes do modelo de dados (SetDescription)
	//Setando a descrição do formulário
	oModel:GetModel('ZCF_MASTER'):SetDescription('Grupo Numero Operacional')
	oModel:GetModel('ZCG_MODEL'):SetDescription('Grupo Numero Operacional x EPC')
	
	//A Chave Primária é obrigatória, caso não tenha defina um array vazio
	oModel:SetPrimaryKey({'ZCF_FILIAL'}, {'ZCF_CODGRU'}) // ZA0_FILIAL+ZA0_CARGA   
	
//	oStruZCA:SetProperty("ZCA_NUMOPE",MODEL_FIELD_WHEN	,{|| .F. })
//	oStruZCA:SetProperty("ZCA_DESCRI",MODEL_FIELD_WHEN	,{|| .F. })
//	oStruZCA:SetProperty("ZCA_NUMCON",MODEL_FIELD_WHEN	,{|| .F. })

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
	Local oModel 	:= FWLoadModel('ACHK012')

	Local oStruZCF  := FWFormStruct(2 , 'ZCF', {|x|chkCampo('ZCF',alltrim(x))})
	Local oStruZCG  := FWFormStruct(2 , 'ZCG', {|x|chkCampo('ZCG',alltrim(x))})

	//Definimos qual o modelo de dados (Model) que será utilizado na interface (View)
	oView:SetModel(oModel)

	//Adiciona na nossa View um controle do tipo formulário (antiga Enchoice)
	oView:AddField('ZCF_VIEW', oStruZCF, 'ZCF_MASTER')
	
	oView:AddGrid('ZCG_VIEW', oStruZCG, 'ZCG_MODEL')

	// Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'ID_HBOX_SUPERIOR' 	, 20 )    
	oView:CreateHorizontalBox( 'ID_HBOX_INFERIOR'	, 80 )    

	// Quebra em 2 "box" vertical para receber algum elemento da view
	oView:CreateVerticalBox( 'BI_TOT',100, 'ID_HBOX_INFERIOR' )
	
	// Relaciona o identificador (ID) da View com o "box" para exibicao
	oView:SetOwnerView( 'ZCF_VIEW', 'ID_HBOX_SUPERIOR'  )
	
	oView:SetOwnerView( 'ZCG_VIEW' , 'BI_TOT' )

	// Liga a identificacao do componente
	oView:EnableTitleView('ZCF_MASTER', 'Grupo Numero Operacional')
	oView:EnableTitleView('ZCG_MODEL' , 'Grupo Numero Operacional x EPC')

//	oView:SetFieldAction("ZA0_CARGA"  , {|oView, oModel| addLinha(oView, oModel) } )
//	oView:SetFieldAction("ZA1_QTDCED" , {|oView, oModel| addAtualiza(oView, oModel)})

    oView:AddIncrementField( 'ZCG_VIEW', 'ZCG_ITEM' )

//	oView:SetViewProperty("ZCG_VIEW" , "GRIDVSCROLL", {.F.})	
	
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

if cAlias == "ZCG"
	if alltrim(cCampo) $ "ZCG_CODGRU"
		lReturn := .F.
	else
		lReturn := .T.	
	endif
endif

return(lReturn)

/*
___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ACHK004A.prw ¦ Autor ¦ Sinval         ¦ Data ¦    01/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Ponto de Entrada da Rotina Cadastro do Número Operacional  ¦¦¦
¦¦¦          ¦ 															  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Objetivo  ¦                                            				  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

/*
IDs dos Pontos de Entrada
-------------------------

MODELPRE 			Antes da alteração de qualquer campo do modelo. (requer retorno lógico)
MODELPOS 			Na validação total do modelo (requer retorno lógico)

FORMPRE 			Antes da alteração de qualquer campo do formulário. (requer retorno lógico)
FORMPOS 			Na validação total do formulário (requer retorno lógico)

FORMLINEPRE 		Antes da alteração da linha do formulário GRID. (requer retorno lógico)
FORMLINEPOS 		Na validação total da linha do formulário GRID. (requer retorno lógico)

MODELCOMMITTTS 		Apos a gravação total do modelo e dentro da transação
MODELCOMMITNTTS 	Apos a gravação total do modelo e fora da transação

FORMCOMMITTTSPRE 	Antes da gravação da tabela do formulário
FORMCOMMITTTSPOS 	Apos a gravação da tabela do formulário

FORMCANCEL 			No cancelamento do botão.

BUTTONBAR 			Para acrescentar botoes a ControlBar

MODELVLDACTIVE 		Para validar se deve ou nao ativar o Model

Parametros passados para os pontos de entrada:
PARAMIXB[1] - Objeto do formulário ou model, conforme o caso.
PARAMIXB[2] - Id do local de execução do ponto de entrada
PARAMIXB[3] - Id do formulário

Se for uma FORMGRID
PARAMIXB[4] - Linha da Grid
PARAMIXB[5] - Acao da Grid
*/

User Function ACHK012A

	Local nQtdElIXB		:= 0
	Local oObj			:= ''
	Local cIdPonto		:= ''
	Local cIdModel		:= ''
	Local cClasse		:= ''
	Local nOper 		:= 0          
	Local xRet			:= .T.   
    
	If PARAMIXB <> Nil
		nQtdElIXB	:= Len(PARAMIXB)
		oObj 		:= PARAMIXB[1]
		cIdPonto	:= PARAMIXB[2]
		cIdModel	:= PARAMIXB[3]
		cClasse 	:= Iif(oObj<>Nil, oObj:ClassName(), '')	// Nome da classe utilizada na rotina (FWFORMFIELD - Formulário, FWFORMGRID - Grid)
		nOper 		:= oObj:getOperation()  

		If cIdPonto == 'MODELVLDACTIVE' 

		ElseIf cIdPonto == 'BUTTONBAR'

		ElseIf cIdPonto == 'FORMPRE'

		ElseIf cIdPonto == 'FORMPOS'
				
		ElseIf cIdPonto == 'FORMLINEPRE'    
		
		ElseIf cIdPonto == 'FORMLINEPOS'
				
		ElseIf cIdPonto == 'MODELPRE'

		ElseIf cIdPonto == 'MODELPOS'
		
		ElseIf cIdPonto == 'FORMCOMMITTTSPRE'         
				
		ElseIf cIdPonto == 'FORMCOMMITTTSPOS'

		ElseIf cIdPonto == 'MODELCOMMITTTS'

		ElseIf cIdPonto == 'MODELCOMMITNTTS'

  		ElseIf cIdPonto == 'MODELCANCEL'

		EndIf

	EndIf

Return xRet















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


