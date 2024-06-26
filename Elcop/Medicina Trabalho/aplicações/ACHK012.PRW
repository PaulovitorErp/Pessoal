#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'topconn.ch'
#Include 'tbiconn.ch'
#Include 'APWizard.ch'

#Define ENTER 	Chr(13) + Chr(10)
                                        
/*
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � ACHK012.prw � Autor � Sinval Gedolin � Data � Janeiro/2021 ���
��+----------+------------------------------------------------------------���
���Descri��o � Tela de Cadastrodo Grupo NUm Operacional x EPC     	      ���
���          � 															  ���
��+----------+------------------------------------------------------------���
���Objetivo  � 			                                                  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 

User Function ACHK012()

	Local oBrowse
	Local aArea := (GetArea())

	//Inst�nciando FWMBrowse - Somente com dicion�rio de dados dadadas
	oBrowse := FWmBrowse():New()

	//Setando a tabela
	oBrowse:SetAlias( 'ZCF' )

	//Setando a descri��o da rotina
	oBrowse:SetDescription('Grupo do N�mero Operacional')
 	oBrowse:SetDetails(.F., {||})
	oBrowse:SetWalkThru(.F.)
	oBrowse:SetAmbiente(.T.) 

	//Adiciona Legenda
	//oBrowse:AddLegend( "ZA0_DIVERG $ ' N'", "GREEN"	, "Sem Diverg�ncia"   )
	//oBrowse:AddLegend( "ZA0_DIVERG $ 'S'", "RED"   , "Com Diverg�ncia" )

	//Ativa a Browse
	oBrowse:Activate()
	RestArea(aArea)

Return

//----------------------------MenuDef---------------------------------------
/*
Define as opera��es que ser�o realizadas pela aplica��o.
Na MenuDef da aplica��o instanciamos a interface (View) de outra aplica��o
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
Define a regra de neg�cios propriamente dita onde s�o definidas
* Todas as entidades (tabelas) que far�o parte do modelo de dados (Model); 
* Regras de depend�ncia entre as entidades;
* Valida��es (de campos e aplica��o);
* Persist�ncia dos dados (grava��o).
*/

Static Function ModelDef()
	Local aArea := GetArea()

	//Cria a estrutura a ser usada no Modelo de Dados
	//							   <nType>, <cAliasSX2>, [bSX3]
	Local oStruZCF := FWFormStruct(1 , 'ZCF', )
	Local oStruZCG := FWFormStruct(1 , 'ZCG', )
    
	//Cria o objeto do Modelo de Dados
	Local oModel := MPFormModel():New('ACHK012A', /*bPre*/, /*bPos*/, /*bCommit*/, /*bCancel*/)

   	//Cria��o de um componente de formul�rio no Modelo de Dados (AddFields)
	oModel:AddFields('ZCF_MASTER', 			  , oStruZCF, /*bPre*/, /*bPos*/, /*bLoad*/)

	oModel:AddGrid('ZCG_MODEL'	 ,'ZCF_MASTER', oStruZCG,/*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)       

	//Check List x Grupos de Perguntas
	oModel:SetRelation('ZCG_MODEL', {{'ZCG_FILIAL', 'XFilial("ZCF")'},;
	 								 {'ZCG_CODGRU' , 'ZCF_CODGRU'   } },;
	 								 ZCG->(IndexKey(1)))

	//Controle de n�o repeti��o de Linha
	oModel:GetModel( 'ZCG_MODEL' ):SetUniqueLine( { 'ZCG_FILIAL', 'ZCG_CODGRU', 'ZCG_CODEPC' } )
		
	//Adicionando descri��o ao modelo
	oModel:SetDescription('Cadastro de Grupo Num Operacional x EPC')

	//Descri��o dos componentes do modelo de dados (SetDescription)
	//Setando a descri��o do formul�rio
	oModel:GetModel('ZCF_MASTER'):SetDescription('Grupo Numero Operacional')
	oModel:GetModel('ZCG_MODEL'):SetDescription('Grupo Numero Operacional x EPC')
	
	//A Chave Prim�ria � obrigat�ria, caso n�o tenha defina um array vazio
	oModel:SetPrimaryKey({'ZCF_FILIAL'}, {'ZCF_CODGRU'}) // ZA0_FILIAL+ZA0_CARGA   
	
//	oStruZCA:SetProperty("ZCA_NUMOPE",MODEL_FIELD_WHEN	,{|| .F. })
//	oStruZCA:SetProperty("ZCA_DESCRI",MODEL_FIELD_WHEN	,{|| .F. })
//	oStruZCA:SetProperty("ZCA_NUMCON",MODEL_FIELD_WHEN	,{|| .F. })

	RestArea(aArea)
Return oModel

//------------------------------ViewDef-------------------------------------
/*
Define como ser� a interface (constru��o da interface) e portanto como o usuario interage com o modelo (Model)
recebe dados informado pelo usuario e fornece ao modelo (modelDef).
*/
Static Function ViewDef()

	Local aArea := GetArea()

	//Cria a estrutura a ser usada na View
	//Constru��o da interface de visualiza��o. Cria o objeto de View ... Iniciando a constru��o da interface
	Local oView 	:= FWFormView():New()

	//Cria um objeto de modelo de dados no ModelDef() do fonte informado
	Local oModel 	:= FWLoadModel('ACHK012')

	Local oStruZCF  := FWFormStruct(2 , 'ZCF', {|x|chkCampo('ZCF',alltrim(x))})
	Local oStruZCG  := FWFormStruct(2 , 'ZCG', {|x|chkCampo('ZCG',alltrim(x))})

	//Definimos qual o modelo de dados (Model) que ser� utilizado na interface (View)
	oView:SetModel(oModel)

	//Adiciona na nossa View um controle do tipo formul�rio (antiga Enchoice)
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
          

/* Define quais campos poder�o ou n�o aparecer nos forms */
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
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � ACHK004A.prw � Autor � Sinval         � Data �    01/2021  ���
��+----------+------------------------------------------------------------���
���Descri��o � Ponto de Entrada da Rotina Cadastro do N�mero Operacional  ���
���          � 															  ���
��+----------+------------------------------------------------------------���
���Objetivo  �                                            				  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

/*
IDs dos Pontos de Entrada
-------------------------

MODELPRE 			Antes da altera��o de qualquer campo do modelo. (requer retorno l�gico)
MODELPOS 			Na valida��o total do modelo (requer retorno l�gico)

FORMPRE 			Antes da altera��o de qualquer campo do formul�rio. (requer retorno l�gico)
FORMPOS 			Na valida��o total do formul�rio (requer retorno l�gico)

FORMLINEPRE 		Antes da altera��o da linha do formul�rio GRID. (requer retorno l�gico)
FORMLINEPOS 		Na valida��o total da linha do formul�rio GRID. (requer retorno l�gico)

MODELCOMMITTTS 		Apos a grava��o total do modelo e dentro da transa��o
MODELCOMMITNTTS 	Apos a grava��o total do modelo e fora da transa��o

FORMCOMMITTTSPRE 	Antes da grava��o da tabela do formul�rio
FORMCOMMITTTSPOS 	Apos a grava��o da tabela do formul�rio

FORMCANCEL 			No cancelamento do bot�o.

BUTTONBAR 			Para acrescentar botoes a ControlBar

MODELVLDACTIVE 		Para validar se deve ou nao ativar o Model

Parametros passados para os pontos de entrada:
PARAMIXB[1] - Objeto do formul�rio ou model, conforme o caso.
PARAMIXB[2] - Id do local de execu��o do ponto de entrada
PARAMIXB[3] - Id do formul�rio

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
		cClasse 	:= Iif(oObj<>Nil, oObj:ClassName(), '')	// Nome da classe utilizada na rotina (FWFORMFIELD - Formul�rio, FWFORMGRID - Grid)
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















/* Gatilho para Pegar o Valor da Carga, � realizada conforma o Formas do Pedido 
Uma das possibilidades do valor da Carga n�o coincidir com o Relat�rio, poder ser pedidos de troca ou bonifica��o */
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


