#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "MNTA850.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA850
Cadastro de Atividades da Parte Diária

@author Vitor Emanuel Batista
@since 20/04/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Function MNTA850()

	//---------------------------------------------
	// Guarda conteúdo e declara variáveis padrões
	//---------------------------------------------
	Local aNGBEGINPRM := {}

	Local cCadastro := STR0001 // "Cadastro de Atividades da Parte Diária"

	Local oBrowse

	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 19, 95 )

		aNGBEGINPRM := NGBEGINPRM()

		DbSelectArea( "TV0" )
		DbSetOrder( 01 ) // TV0_FILIAL+TV0_CODATI
		DbGoTop()

		oBrowse := FWMBrowse():New()
			oBrowse:SetAlias("TV0")
			oBrowse:SetMenuDef("MNTA850")
			oBrowse:SetDescription( cCadastro )
			oBrowse:Activate()

		//---------------------------------------
		// Retorna conteúdo de variáveis padrões
		//---------------------------------------
		NGRETURNPRM(aNGBEGINPRM)

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Opções de menu

@author Vitor Emanuel Batista
@since 10/02/2012
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
Return FWMVCMenu( 'MNTA850' )


//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Regras de Modelagem da gravacao

@author Vitor Emanuel Batista
@since 10/02/2012
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oModel

	Local oStructTV0

	oStructTV0 := FWFormStruct(1,"TV0")

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("MNTA850",/*bPre*/,/*bValid*/,/*bCommit*/,  /*bCancel*/)

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields("MNTA850_TV0", Nil, oStructTV0,/*bPre*/,/*bPost*/,/*bLoad*/)

	//Descrição do Model
	oModel:SetDescription(STR0002) // "Atividades"

Return oModel


//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Regras de Interface com o Usuario

@author Vitor Emanuel Batista
@since 20/04/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local oModel := FWLoadModel("MNTA850")
	Local oView  := Nil

	oStruTV0 := FWFormStruct(2,"TV0")

	oView := FWFormView():New()

	// Objeto do model a se associar a view.
	oView:SetModel(oModel)

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( "MNTA850_TV0" , oStruTV0 , /*cLinkID*/ )	//

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )

	// Associa um View a um box
	oView:SetOwnerView( "MNTA850_TV0" , "MASTER" )

	//Inclusão de itens no Ações Relacionadas de acordo com o NGRightClick
	NGMVCUserBtn(oView)

Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Funcao de tratamento para o recebimento/envio de mensagem unica de
cadastro de atividades da parte diária.

@author Felipe Nathan Welter
@since 09/07/13
@version P11
@return aArray sendo [1]-.T./.F. e [2]-cError
/*/
//---------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )

	Local nOpe := If( Inclui, 3, If(Altera, 4, 5) )

Return MNTI850( cXml, nTypeTrans, cTypeMessage, nOpe )

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT851VLAM
Valida envio da mensagem unica de Atividade (Activity).

@author Hugo R. Peereira
@since 09/07/13
@version P11
@return Boolean
/*/
//---------------------------------------------------------------------
Function MNT851VLAM()
Return TV0->TV0_TIPHOR <> "1"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT850VATP
Valida codigo da atividade como sendo produtiva.

@author Hugo R. Peereira
@since 09/07/13
@version P11
@return Boolean
/*/
//---------------------------------------------------------------------
Function MNT850VPAP()

	Local aArea    := GetArea()
	Local aAreaTV0 := TV0->(GetArea())

	Local cCodAtiv := GetNewPar("MV_NGMBATV", "")
	Local cMsgHlp  := ""

	If Empty(cCodAtiv)
		cMsgHlp := "Parâmetro MV_NGMBATV não configurado."
	Endif

	If Empty(cMsgHlp)
		dbSelectArea("TV0")
		dbSetOrder(1)
		If !dbSeek(xFilial("TV0") + cCodAtiv)
			cMsgHlp := "Atividade informada no parâmetro MV_NGMBATV, não encontrada."
		Else
			If TV0->TV0_TIPHOR <> "1"
				cMsgHlp := "Atividade informada no parâmetro MV_NGMBATV, não é produtiva."
			Endif
		Endif
	Endif

	RestArea(aAreaTV0)
	RestArea(aArea)

Return { Empty(cMsgHlp), cMsgHlp }
