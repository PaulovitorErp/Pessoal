#Include "MDTA680.ch"
#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA680
Programa de Cadastro do Emitentes de Atestado

@return

@sample MDTA680()

@author Thiago Olis Machado - Refeito por: Jackson Machado
@since 22/06/01 - Revisão: 09/09/13
/*/
//---------------------------------------------------------------------
Function MDTA680()

	//Armazena as variáveis
	Local aNGBEGINPRM := NGBEGINPRM()
	Local oBrowse

	oBrowse := FWMBrowse():New()
		oBrowse:SetAlias( "TNP" ) //Alias da tabela utilizada
		oBrowse:SetMenuDef( "MDTA680" ) //Nome do fonte onde esta a função MenuDef
		oBrowse:SetDescription( STR0006 ) //Descrição do browse ###"Medicos Externos"
	oBrowse:Activate()

	// Devolve as variáveis armazenadas
	NGRETURNPRM( aNGBEGINPRM )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do Menu (padrão MVC).

@author Jackson Machado
@since 05/09/13

@return aRotina array com o Menu MVC
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	//Inicializa MenuDef com todas as opções

Return FWMVCMenu( "MDTA680" )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do Modelo (padrão MVC).

@author Jackson Machado
@since 05/09/13

@return oModel objeto do Modelo MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

    // Cria a estrutura a ser usada no Modelo de Dados
	Local oStructTNP := FWFormStruct( 1, "TNP", /*bAvalCampo*/, /*lViewUsado*/ )

	// Modelo de dados que será construído
	Local oModel

	// Cria o objeto do Modelo de Dados
	// cID     Identificador do modelo
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New( "MDTA680", /*bPre*/, { | oModel | fMPosValid( oModel ) } /*bPost*/, { | oModel | fMCommit( oModel ) }, /*bCancel*/ )

		//--------------------------------------------------
		// Componentes do Modelo
		//--------------------------------------------------
		// Adiciona ao modelo um componente de Formulário Principal
		// cId          Identificador do modelo
		// cOwner       Identificador superior do modelo
		// oModelStruct Objeto com  a estrutura de dados
		// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
		// bPost        Code-Block de validação do formulário de edição
		// bLoad        Code-Block de carga dos dados do formulário de edição
		oModel:AddFields( "TNPMASTER", Nil, oStructTNP, /*bPre*/, /*bPost*/, /*bLoad*/ )
			// Adiciona a descrição do Modelo de Dados (Geral)
			oModel:SetDescription( STR0006 ) //"Medicos Externos"
			// Adiciona a descricao do Componente do Modelo de Dados
			oModel:GetModel( "TNPMASTER" ):SetDescription( STR0006 ) //"Medicos Externos"

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da View (padrão MVC).

@author Jackson Machado
@since 05/09/13

@return oView objeto da View MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oModel := FWLoadModel( "MDTA680" )

	// Cria a estrutura a ser usada na View
	Local oStructTNP := FWFormStruct( 2, "TNP", /*bAvalCampo*/, /*lViewUsado*/ )

	// Interface de visualização construída
	Local oView

	// Cria o objeto de View
	oView := FWFormView():New()
		// Objeto do model a se associar a view.
		oView:SetModel( oModel )
		// Adiciona no View um controle do tipo formulário (antiga Enchoice)
		// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
		// oStruct - Objeto do model a se associar a view.
		// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
		oView:AddField( "VIEW_TNP", oStructTNP, "TNPMASTER" )
			//Adiciona um titulo para o formulário
			oView:EnableTitleView( "VIEW_TNP", STR0006 ) //Descrição do browse ###"Medicos Externos"
			// Cria os componentes "box" horizontais para receberem elementos da View
			// cID		  	Id do Box a ser utilizado
			// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
			// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
			// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
			// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
			// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
			oView:CreateHorizontalBox( "TELATNP", 100, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )
		// Associa um View a um box
		oView:SetOwnerView( "VIEW_TNP", "TELATNP" )

Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} fMPosValid
Pós-validação do modelo de dados.

@author Jackson Machado
@since 05/09/13

@param oModel - Objeto do modelo de dados (Obrigatório)

@return Lígico - Retorna verdadeiro caso validacoes estejam corretas
/*/
//---------------------------------------------------------------------
Static Function fMPosValid( oModel )

	Local lRet := .T.

	Local aAreaTNP := TNP->( GetArea() )

	Local nOperation := oModel:GetOperation() // Operação de ação sobre o Modelo
	Local oModelTNP	 := oModel:GetModel( "TNPMASTER" )

	Private aCHKSQL := {} // Variável para consistência na exclusão (via SX9)
	Private aCHKDEL := {} // Variável para consistência na exclusão (via Cadastro)

	// Recebe SX9 - Formato:
	// 1 - Domínio (tabela)
	// 2 - Campo do Domínio
	// 3 - Contra-Domínio (tabela)
	// 4 - Campo do Contra-Domínio
	// 5 - Condição SQL
	// 6 - Comparação da Filial do Domínio
	// 7 - Comparação da Filial do Contra-Domínio
	aCHKSQL := NGRETSX9( "TNP" )

	// Recebe relação do Cadastro - Formato:
	// 1 - Chave
	// 2 - Alias
	// 3 - Ordem (Índice)
	aAdd( aCHKDEL, { "TNP->TNP_EMITEN", "TNY", 4 } )

	If nOperation == MODEL_OPERATION_DELETE //Exclusão
		If !NGCHKDEL( "TNP" )
			lRet := .F.
		EndIf

		If lRet .And. !NGVALSX9( "TNP", {}, .T., .T. )
			lRet := .F.
		EndIf
	Else
		lRet := MDTObriEsoc( "TNP", , oModelTNP ) //Verifica se campos obrigatórios ao eSocial estão preenchidos
	EndIf

	RestArea( aAreaTNP )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fMCommit
Define funcao de alteracao para replicar o usuario (SBIS)
Uso MDTA680

@return Nil

@sample
fMCommit()

@author Jackson Machado
@since 21/08/2012
/*/
//---------------------------------------------------------------------
Static Function fMCommit( oModel )

	Local lIndFun	 := NGCADICBASE( "TNP_INDFUN", "A", "TNP", .F. )
	Local nOperation := oModel:GetOperation() //Operação de ação sobre o Modelo
	Local oModelTNP	 := oModel:GetModel( "TNPMASTER" )

	FWFormCommit( oModel )

	If nOperation == MODEL_OPERATION_UPDATE //Alterar

		If TNP->( FieldPos( "TNP_USUARI" ) ) > 0 .And. ( ( lIndFun .And. ( TNP->TNP_INDFUN == "1" .Or. TNP->TNP_INDFUN == "6") ) .Or. !lIndFun )
			dbSelectarea( "TMK" )
			dbSetorder( 1 )
			If dbSeek( xFilial( "TMK" ) + TNP->TNP_EMITEN ) .And. ( TMK->TMK_INDFUN == "1" .Or. TMK->TMK_INDFUN == "6" ) .And. Empty( TMK->TMK_USUARI )
				RecLock( "TMK", .F. )
				TMK->TMK_USUARI := TNP->TNP_USUARI
				TMK->( MsUnLock() )
			EndIf
		EndIf

	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT680WHEN
When dos campos da tabela TNP
Uso MDTA680

@return Nil

@sample
fMCommit()

@author Alessandro Smaha
@since 09/04/13
/*/
//---------------------------------------------------------------------
Function MDT680WHEN( cCampo )

	Local lRet := .T.
	Local cCodiUsr := RetCodUsr()
	Local cUsrPerm := SuperGetMv( "MV_NG2USR", .F., "000000" )

	If cCampo == "TNP_USUARI" .And. NGCADICBASE( "TNP_USUARI", "A", "TNP", .F. )
		If !( cCodiUsr $ cUsrPerm )
			lRet := .F.
		EndIf
	EndIf

	If lRet .And. SuperGetMV( "MV_NG2SEG", .F., "2" ) == "1" .And. ALTERA .And. Alltrim( cCampo ) == "TNP_NOME"

		//TNY - Atestados Médicos
		DbSelectArea( "TNY" )
		TNY->( DbSetOrder( 4 ) )
		lRet := !TNY->( DbSeek( xFilial( "TNY" ) + M->TNP_EMITEN ) )

	EndIf

Return lRet
