/** {Protheus.doc} ANFF004
Log das Transa��es de Envio para as Lojas e Retornos para a F�brica
Sendo:
@Uso: Projeto NF
@Origem: 	

*/

#Include "Totvs.ch"
#Include "FwMvcDef.ch"

User Function APIR001()

Private oBrowse 	:= FwMBrowse():New()				//Variavel de Browse 

//Alias do Browse
oBrowse:SetAlias('ZZA')
//Descri��o da Parte Superior Esquerda do Browse
oBrowse:SetDescripton("Cadastro de Usu�rios") 

//Habilita os Bot�es Ambiente e WalkThru
oBrowse:SetWalkThru(.T.)

//Desabilita os Detalhes da parte inferior do Browse
oBrowse:DisableDetails()
          	
//Ativa o Browse
oBrowse:Activate()

Return

Static Function MenuDef()
Local aMenu :=	{}
	
ADD OPTION aMenu TITLE 'Pesquisar'  ACTION 'PesqBrw'       		OPERATION 1 ACCESS 0
ADD OPTION aMenu TITLE 'Visualizar' ACTION 'VIEWDEF.APIR001'	OPERATION 2 ACCESS 0
ADD OPTION aMenu TITLE 'Incluir'    ACTION 'VIEWDEF.APIR001' 	OPERATION 3 ACCESS 0
ADD OPTION aMenu TITLE 'Excluir'    ACTION 'VIEWDEF.APIR001' 	OPERATION 5 ACCESS 0
ADD OPTION aMenu TITLE 'Imprimir'   ACTION 'VIEWDEF.APIR001'	OPERATION 6 ACCESS 0
	
Return(aMenu)


Static Function ModelDef()
//Retorna a Estrutura do Alias passado como Parametro (1=Model,2=View)
Local oStruct	:=	FWFormStruct(1,"ZZA") 
Local oModel

//Instancia do Objeto de Modelo de Dados
oModel	:=	MpFormModel():New('APIR001A',/*Pr�-Valida��o*/ ,/*Pos-Validacao*/;
                                       ,/*Commit*/,/*Cancel*/)

//Adiciona um modelo de Formulario de Cadastro Similar � Enchoice ou Msmget
oModel:AddFields('ZZA_MASTER', /*cOwner*/, oStruct, /*bPreValidacao*/;
                       , /*bPosValidacao*/, /*bCarga*/ )

//Adiciona Descricao do Modelo de Dados
oModel:SetDescription( 'Cadastro de Usu�rios' )

//Adiciona Descricao do Componente do Modelo de Dados      
oModel:GetModel( 'ZZA_MASTER' ):SetDescription( 'Cadastro de Usu�rios' )

//A Chave Prim�ria � obrigat�ria, caso n�o tenha defina um array vazio
oModel:SetPrimaryKey({'ZZA_FILIAL','ZZA_CODUSR'})  

Return(oModel)

/* VIEW */
Static Function ViewDef()
Local oStruct	:=	FWFormStruct(2,"ZZA") 	//Retorna a Estrutura do Alias passado
                                            // como Parametro (1=Model,2=View)
Local oModel	:=	FwLoadModel('APIR001')	//Retorna o Objeto do Modelo de Dados 
Local oView		:=	FwFormView():New()      //Instancia do Objeto de Visualiza��o

//Define o Modelo sobre qual a Visualizacao sera utilizada
oView:SetModel(oModel)	

//Vincula o Objeto visual de Cadastro com o modelo 
oView:AddField( 'ZZA_VIEW', oStruct, 'ZZA_MASTER')

//Define o Preenchimento da Janela
oView:CreateHorizontalBox( 'ID_BOX_ALL'  , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'ZZA_VIEW', 'ID_BOX_ALL' )

Return(oView)                       

/*
___________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � ANFF004A.prw � Autor � Sinval         � Data �    08/2021  ���
��+----------+------------------------------------------------------------���
���Descri��o � Ponto de Entrada da Rotina                                 ���
���			 � 															  ���
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

User Function APIR001A

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
