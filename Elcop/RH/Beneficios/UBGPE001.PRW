#Include "PROTHEUS.CH"
#include "topconn.ch"   
#INCLUDE 'FWMVCDEF.CH' 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � UBGPE001 � Autor � Adriano Reis        � Data �28/02/2019  ���
�������������������������������������������������������������������������͹��
���Desc.     � Cadastro Regra de Beneficios                				  ���
�������������������������������������������������������������������������͹��
���Uso       � ELCOP                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function UBGPE001()
             
    Local oBrowse
    Private aRotina := {}

    // Crio o objeto do Browser
    oBrowse := FWmBrowse():New()

    // Defino o Alias
    oBrowse:SetAlias("U01")

    // Informo a descri��o
    oBrowse:SetDescription("Cadastro Regra de Beneficios")  

    // Ativo o browser
    oBrowse:Activate()

Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MenuDef � Autor � Adriano Reis         � Data �28/02/2019  ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o que cria os menus									  ���
�������������������������������������������������������������������������͹��
���Uso       � ELCOP                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function MenuDef() 

    Local aRotina := {}

    ADD OPTION aRotina Title 'Pesquisar'   	Action 'PesqBrw'          	OPERATION 01 ACCESS 0
    ADD OPTION aRotina Title 'Visualizar'  	Action 'VIEWDEF.UBGPE001' 	OPERATION 02 ACCESS 0
    ADD OPTION aRotina Title 'Incluir'     	Action 'VIEWDEF.UBGPE001' 	OPERATION 03 ACCESS 0
    ADD OPTION aRotina Title 'Alterar'     	Action 'VIEWDEF.UBGPE001' 	OPERATION 04 ACCESS 0
    ADD OPTION aRotina Title 'Excluir'     	Action 'VIEWDEF.UBGPE001' 	OPERATION 05 ACCESS 0
    ADD OPTION aRotina Title 'Imprimir'    	Action 'VIEWDEF.UBGPE001' 	OPERATION 08 ACCESS 0
    ADD OPTION aRotina Title 'Copiar'      	Action 'VIEWDEF.UBGPE001' 	OPERATION 09 ACCESS 0  

Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ModelDef � Autor � Adriano Reis 		   � Data �28/02/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o que cria o objeto model							  ���
�������������������������������������������������������������������������͹��
���Uso       � ELCOP						     		                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ModelDef()

    Local oStruU01 := FWFormStruct( 1, 'U01', /*bAvalCampo*/, /*lViewUsado*/ )
    Local oModel

    // Cria o objeto do Modelo de Dados
    oModel := MPFormModel():New( 'PBGPE001', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

    // Crio a Enchoice
    oModel:AddFields( 'U01MASTER', /*cOwner*/, oStruU01 )

    // Adiciona a chave primaria da tabela principal
    oModel:SetPrimaryKey({ "U01_FILIAL" , "U01_CODIGO" })    

    // Preencho a descri��o da entidade
    oModel:GetModel('U01MASTER'):SetDescription('Cadastro Regra de Beneficios:')

Return(oModel)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ViewDef � Autor � Adriano Reis � Data �28/02/2019    	  ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o que cria o objeto View							  ���
�������������������������������������������������������������������������͹��
���Uso       � Elcop													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ViewDef()

    Local oStruU01 	:= FWFormStruct(2,'U01')
    Local oModel   	:= FWLoadModel('UBGPE001')
    Local oView

    // Cria o objeto de View
    oView := FWFormView():New()

    // Define qual o Modelo de dados ser� utilizado
    oView:SetModel(oModel)

    oView:AddField('VIEW_U01'	, oStruU01, 'U01MASTER') // cria o cabe�alho

    // Crio os Panel's horizontais 
    oView:CreateHorizontalBox('PANEL_CABECALHO' , 100)

    // Relaciona o ID da View com os panel's
    oView:SetOwnerView('VIEW_U01' , 'PANEL_CABECALHO')

    // Ligo a identificacao do componente
    oView:EnableTitleView('VIEW_U01')

    // Define fechamento da tela ao confirmar a opera��o
    oView:SetCloseOnOk({||.T.})

Return(oView)                         
