#INCLUDE "MNTA030.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA030
Cadastro de Lubrificantes

@author Pedro Henrique Soares de Souza
@since 24/06/2014
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Function MNTA030()

    Local oBrowse
    Local aNGBEGINPRM := NGBEGINPRM()

    /*--------------------------------------------------------------------
    As variáveis aRotina e cCadastro são utilizadas na função MsDocument
    no fonte MATXFUNC, não retirá-las!
    --------------------------------------------------------------------*/
    Private aRotina     := {}
    Private cCadastro   := STR0001 // "Lubrificantes"

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("TZZ")                 // Alias da tabela utilizada
        oBrowse:SetMenuDef( "MNTA030" )     // Nome do fonte onde está a função MenuDef
        oBrowse:SetDescription( STR0001 )   // Descrição do browse ## "Lubrificantes"

    oBrowse:Activate()

    NGRETURNPRM(aNGBEGINPRM)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Opções de menu

@author Pedro Henrique Soares de Souza
@since 24/06/2014
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

    Local lPyme := If( Type( "__lPyme" ) <> "U", __lPyme, .F. )

    aRotina := {}

    ADD OPTION aRotina TITLE STR0003 ACTION 'PesqBrw'           OPERATION 1  ACCESS 0 // 'Pesquisar'
    ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.MNTA030'   OPERATION 2  ACCESS 0 // 'Visualizar'
    ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.MNTA030'   OPERATION 3  ACCESS 0 // 'Incluir'
    ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.MNTA030'   OPERATION 4  ACCESS 0 // 'Alterar'
    ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.MNTA030'   OPERATION 5  ACCESS 0 // 'Excluir'
    ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.MNTA030'   OPERATION 8  ACCESS 0 // 'Imprimir'
    ADD OPTION aRotina TITLE STR0009 ACTION 'VIEWDEF.MNTA030'   OPERATION 9  ACCESS 0 // 'Copiar'

    If !lPyme
        //Adiciona a opção 'Conhecimento' em Ações Relacionadas
        ADD OPTION aRotina TITLE STR0002 ACTION 'MsDocument' OPERATION 4 ACCESS 0 // "Conhecimento"
    EndIf

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Regras de modelagem da gravação

@author Pedro Henrique Soares de Souza
@since 24/06/2014
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

    Local oModel

    Local oStructTZZ := FWFormStruct( 1, "TZZ" )

    // Cria o objeto do Modelo de Dados
    oModel := MPFormModel():New( "MNTA030", /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/ )

    // Adiciona ao modelo uma estrutura de formulário de edição por campo
    oModel:AddFields( "MNTA030_TZZ", Nil, oStructTZZ,/*bPre*/,/*bPost*/,/*bLoad*/)

    oModel:SetPrimaryKey( { "TZZ_FILIAL", "TZZ_PRODUT" } )

    oModel:SetDescription( STR0001 ) // "Lubrificantes"

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Regras de Interface com o Usuário

@author Pedro Henrique Soares de Souza
@since 10/02/2012
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

    Local oModel := FWLoadModel( "MNTA030" )
    Local oView  := FWFormView():New()

    // Objeto do model a se associar a view.
    oView:SetModel(oModel)

    //Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
    oView:AddField( "MNTA030_TZZ", FWFormStruct( 2, "TZZ" ), /*cLinkID*/ )    //

    // Criar um "box" horizontal para receber algum elemento da view
    oView:CreateHorizontalBox( "MASTER", 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )

    // Associa um View a um box
    oView:SetOwnerView( "MNTA030_TZZ", "MASTER" )
    
    //Inclusão de itens nas Ações Relacionadas de acordo com O NGRightClick
    NGMVCUserBtn(oView)

Return oView
