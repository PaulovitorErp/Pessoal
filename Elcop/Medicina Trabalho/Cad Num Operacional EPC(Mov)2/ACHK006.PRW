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
���Programa  � ACHK007.prw � Autor � Sinval Gedolin � Data � Janeiro/2021 ���
��+----------+------------------------------------------------------------���
���Descri��o � Tela de Cadastrodo Num Operacional x EPC           	      ���
���          � 															  ���
��+----------+------------------------------------------------------------���
���Objetivo  � 			                                                  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 

User Function ACHK007()

	Local oBrowse
	Local aArea := (GetArea())

	//Inst�nciando FWMBrowse - Somente com dicion�rio de dados dadadas
	oBrowse := FWmBrowse():New()

	//Setando a tabela
	oBrowse:SetAlias( 'ZCA' )

	//Setando a descri��o da rotina
	oBrowse:SetDescription('N�mero Operacional')
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
	ADD OPTION aRotina Title 'Visualizar' 		Action 'VIEWDEF.ACHK007' OPERATION 2 ACCESS 0
	//ADD OPTION aRotina Title 'Incluir'    		Action 'VIEWDEF.ACHK007' OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'EPCs'     		Action 'VIEWDEF.ACHK007' OPERATION 4 ACCESS 0
	//ADD OPTION aRotina Title 'Excluir'    		Action 'VIEWDEF.ACHK007' OPERATION 5 ACCESS 0
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
	Local oStruZCA := FWFormStruct(1 , 'ZCA', )
	Local oStruZCB := FWFormStruct(1 , 'ZCB', )
    
	//Cria o objeto do Modelo de Dados
	Local oModel := MPFormModel():New('ACHK007A', /*bPre*/, /*bPos*/, /*bCommit*/, /*bCancel*/)

   	//Cria��o de um componente de formul�rio no Modelo de Dados (AddFields)
	oModel:AddFields('ZCA_MASTER', 			  , oStruZCA, /*bPre*/, /*bPos*/, /*bLoad*/)

	oModel:AddGrid('ZCB_MODEL'	 ,'ZCA_MASTER', oStruZCB,/*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)       

	//Check List x Grupos de Perguntas
	oModel:SetRelation('ZCB_MODEL', {{'ZCB_FILIAL', 'XFilial("ZCA")'},;
	 								 {'ZCB_NUMOPE' , 'ZCA_NUMOPE'   } },;
	 								 ZCB->(IndexKey(1)))

	//Controle de n�o repeti��o de Linha
	oModel:GetModel( 'ZCB_MODEL' ):SetUniqueLine( { 'ZCB_FILIAL', 'ZCB_NUMOPE', 'ZCB_ITEM' } )
		
	//Adicionando descri��o ao modelo
	oModel:SetDescription('Cadastro de Num Operacional x EPC')

	//Descri��o dos componentes do modelo de dados (SetDescription)
	//Setando a descri��o do formul�rio
	oModel:GetModel('ZCA_MASTER'):SetDescription('Numero Operacional')
	oModel:GetModel('ZCB_MODEL'):SetDescription('Numero Operacional x EPC')
	
	//A Chave Prim�ria � obrigat�ria, caso n�o tenha defina um array vazio
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
Define como ser� a interface (constru��o da interface) e portanto como o usuario interage com o modelo (Model)
recebe dados informado pelo usuario e fornece ao modelo (modelDef).
*/
Static Function ViewDef()

	Local aArea := GetArea()

	//Cria a estrutura a ser usada na View
	//Constru��o da interface de visualiza��o. Cria o objeto de View ... Iniciando a constru��o da interface
	Local oView 	:= FWFormView():New()

	//Cria um objeto de modelo de dados no ModelDef() do fonte informado
	Local oModel 	:= FWLoadModel('ACHK007')

	Local oStruZCA  := FWFormStruct(2 , 'ZCA', {|x|chkCampo('ZCA',alltrim(x))})
	Local oStruZCB  := FWFormStruct(2 , 'ZCB', {|x|chkCampo('ZCB',alltrim(x))})

	//Definimos qual o modelo de dados (Model) que ser� utilizado na interface (View)
	oView:SetModel(oModel)

	//Adiciona na nossa View um controle do tipo formul�rio (antiga Enchoice)
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

if cAlias == "ZCB"
	if alltrim(cCampo) $ "ZCB_NUMOPE-ZCB_LOCDEV"
		lReturn := .F.
	else
		lReturn := .T.	
	endif
endif

return(lReturn)


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
