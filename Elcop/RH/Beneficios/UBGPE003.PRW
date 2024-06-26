#Include "PROTHEUS.CH"
#include "topconn.ch"   
#INCLUDE 'FWMVCDEF.CH' 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � UBGPEU03 � Autor � Adriano Reis        � Data �28/02/2019  ���
�������������������������������������������������������������������������͹��
���Desc.     � Manuten��o Calculo Beneficios                			  ���
�������������������������������������������������������������������������͹��
���Uso       � ELCOP                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function UBGPE003()
             
    Local oBrowse
    Private aRotina := {}

    // Crio o objeto do Browser
    oBrowse := FWmBrowse():New()

    // Defino o Alias
    oBrowse:SetAlias("U03")

    // Informo a descri��o
    oBrowse:SetDescription("Manuten��o Calculo Beneficios")  

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

    ADD OPTION aRotina Title 'Pesquisar'   	        Action 'PesqBrw'          	OPERATION 01 ACCESS 0
    ADD OPTION aRotina Title 'Visualizar'  	        Action 'VIEWDEF.UBGPE003' 	OPERATION 02 ACCESS 0
    ADD OPTION aRotina Title 'Incluir'          	Action 'VIEWDEF.UBGPE003' 	OPERATION 03 ACCESS 0
    ADD OPTION aRotina Title 'Alterar'     	        Action 'VIEWDEF.UBGPE003' 	OPERATION 04 ACCESS 0
    ADD OPTION aRotina Title 'Excluir'     	        Action 'VIEWDEF.UBGPE003' 	OPERATION 05 ACCESS 0
    ADD OPTION aRotina Title 'Imprimir'    	        Action 'VIEWDEF.UBGPE003' 	OPERATION 08 ACCESS 0
    //ADD OPTION aRotina Title 'Copiar'      	    Action 'VIEWDEF.UBGPEU03' 	OPERATION 09 ACCESS 0  
    ADD OPTION aRotina Title 'Importar Planilha Beneficios'           Action 'U_UBGPEI03' 	OPERATION 09 ACCESS 0
    ADD OPTION aRotina Title 'Importar Planilha Regra x Funcionario'  Action 'U_UBGPEI04' 	OPERATION 09 ACCESS 0

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

    Local oStruU03 := FWFormStruct( 1, 'U03', /*bAvalCampo*/, /*lViewUsado*/ )
    Local oModel

    // Cria o objeto do Modelo de Dados
    oModel := MPFormModel():New( 'PBGPE003', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

    // Crio a Enchoice
    oModel:AddFields( 'U03MASTER', /*cOwner*/, oStruU03 )

    // Adiciona a chave primaria da tabela principal
    oModel:SetPrimaryKey({ "U03_FILIAL" , "U03_MAT" , "U03_PERIODO" })    

    // Preencho a descri��o da entidade
    oModel:GetModel('U03MASTER'):SetDescription('Calculo Beneficios:')

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

    Local oStruU03 	:= FWFormStruct(2,'U03')
    Local oModel   	:= FWLoadModel('UBGPE003')
    Local oView

    // Cria o objeto de View
    oView := FWFormView():New()

    // Define qual o Modelo de dados ser� utilizado
    oView:SetModel(oModel)

    oView:AddField('VIEW_U03'	, oStruU03, 'U03MASTER') // cria o cabe�alho

    // Crio os Panel's horizontais 
    oView:CreateHorizontalBox('PANEL_CABECALHO' , 100)

    // Relaciona o ID da View com os panel's
    oView:SetOwnerView('VIEW_U03' , 'PANEL_CABECALHO')

    // Ligo a identificacao do componente
    oView:EnableTitleView('VIEW_U03')

    // Define fechamento da tela ao confirmar a opera��o
    oView:SetCloseOnOk({||.T.})

Return(oView)                         

User Function UBGPEI03()

    MsgAlert("Em Desenvolvimento")

Return()

//Importa SRA
User Function UBGPEI04()

    U_AIMPSRA()

Return()
