#INCLUDE "MNTA935.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//---------------------------------------------------------------------
/*{Protheus.doc} MNTA935
Cadastro de Sintomas para O.S.

@author Maria Elisandra de Paula
@since 09/01/2014
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Function MNTA935()

	Local oBrowse := Nil

	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 19, 95 )

		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias("TTB")
		oBrowse:SetMenuDef("MNTA935")
		oBrowse:SetDescription(STR0001) //Cadastro de Sintomas
		oBrowse:Activate()

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Opções de menu
@type static

@author Maria Elisandra de Paula
@since 09/01/2014

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
		7 - Cópia
		8 - Imprimir
	[n,5] Nivel de acesso
	[n,6] Habilita Menu Funcional

@todo Adicionado manualmente a opção pesquisar de forma paliativa para suporte a opção
visulizar no menu funcional este incidente já foi resolvido pela equipe de framework. porém para versões
anterioeres a 12.1.23 ainda não é incorporada no padrão.
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := FWMVCMenu('MNTA935')

	If GetRPORelease() <= '12.1.017'
		aAdd( aRotina, { STR0002, 'AxPesqui', 0, 1 } )
	EndIf

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Regras de Modelagem da gravacao

@author Maria Elisandra de Paula
@since 09/01/2014
@version P11
@return Nil
*/
//------------------------------------------------------
Static Function ModelDef()
	Local oModel
	Local oStructTTB := FWFormStruct(1,"TTB")


	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("MNTA935", /*bPre*/, /*bValid*/, /*bCommit*/, /*bCancel*/)

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields("MNTA935_TTB", Nil, oStructTTB,/*bPre*/,/*bPost*/,/*bLoad*/)

	oModel:SetDescription(STR0001)//"Cadastro de Sintomas"

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Regras de Interface com o Usuario

@author Maria Elisandra de Paula
@since 09/01/2014
@version P11
@return Nil
/*/
//-------------------------------------------------------------------------------------------------------

Static Function ViewDef()

	Local oModel := FWLoadModel("MNTA935")
	Local oView  := FWFormView():New()

	// Objeto do model a se associar a view.
	oView:SetModel(oModel)

	//Adiciona no nosso View um controle do tipo Formulario (antiga enchoice)
	oView:AddField( "MNTA935_TTB" , FWFormStruct(2,"TTB"), /*cLinkID*/ )	//

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )

	// Associa um View a um box
	oView:SetOwnerView( "MNTA935_TTB" , "MASTER" )

	//Inclusão de itens no Ações Relacionadas de acordo com o NGRightClick
	NGMVCUserBtn(oView)

Return oView
