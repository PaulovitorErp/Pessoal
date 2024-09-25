#INCLUDE "MDTA880.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE _nVersao 2 //Versao do fonte

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA880
Programa de Cadastro Nacional dos Estabelecimentos de Saúde

@return

@sample MDTA880()  

@author Guilherme Benkendorf
@since 03/01/14
/*/
//---------------------------------------------------------------------
Function MDTA880()
	
	// Armazena as variáveis
	Local aNGBEGINPRM := NGBEGINPRM( _nVersao )  
	Local oBrowse
	
	If !NGCADICBASE("TOI_ESOC","A","TOI",.F.)
		If !NGINCOMPDIC("UPDMDT84","TPMUF0",.F.)
			//  Devolve variaveis armazenadas (NGRIGHTCLICK)
			NGRETURNPRM(aNGBEGINPRM)   
	  		Return .F.
		EndIf
	EndIf	
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( "TIL" )			// Alias da tabela utilizada
	oBrowse:SetMenuDef( "MDTA880" )	// Nome do fonte onde esta a função MenuDef
	// Descrição do browse
	oBrowse:SetDescription( STR0001 )	//"Cadastro Nacional de Estabelecimento de Saúde (CNES)"
	oBrowse:Activate()
	
	// Devolve as variáveis armazenadas  
	NGRETURNPRM(aNGBEGINPRM)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do Menu (padrão MVC).

@author Jackson Machado
@since 13/09/13

@return aRotina array com o Menu MVC
/*/
//---------------------------------------------------------------------
Static Function MenuDef()
//Inicializa MenuDef com todas as opções
Return FWMVCMenu( "MDTA880" )
//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do Modelo (padrão MVC).

@author Guilherme Benkendorf
@since 03/01/14

@return oModel objeto do Modelo MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()
    
    // Cria a estrutura a ser usada no Modelo de Dados
	Local oStructTIL := FWFormStruct( 1 ,"TIL" , /*bAvalCampo*/ , /*lViewUsado*/ )
	
	// Modelo de dados que será construído
	Local oModel
	
	// Cria o objeto do Modelo de Dados
	// cID     Identificador do modelo 
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New( "MDTA880" , /*bPre*/ , { | oModel | fMPosValid( oModel ) } /*bPos*/ , /*bCommit*/ , /*bCancel*/ )
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
		oModel:AddFields( "TILMASTER" , Nil , oStructTIL , /*bPre*/ , /*bPost*/ , /*bLoad*/ )
		// Adiciona a descrição do Modelo de Dados (Geral)
		oModel:SetDescription( STR0001 )	//"Cadastro Nacional de Estabelecimento de Saúde (CNES)" /*cDescricao*/ )
		// Adiciona a descricao do Componente do Modelo de Dados
		oModel:GetModel( "TILMASTER" ):SetDescription( STR0001 )//"Cadastro Nacional de Estabelecimento de Saúde (CNES)"
			
Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da View (padrão MVC).

@author Guilherme Benkendorf
@since 03/01/14

@return oView objeto da View MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()
	
	// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oModel := FWLoadModel( "MDTA880" )
	
	// Cria a estrutura a ser usada na View
	Local oStructTIL := FWFormStruct( 2 , "TIL" , /*bAvalCampo*/ , /*lViewUsado*/ )
	
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
		oView:AddField( "VIEW_TIL" , oStructTIL , "TILMASTER" )
		//Adiciona um titulo para o formulário
		// Descrição do browse
		oView:EnableTitleView( "VIEW_TIL" , STR0001 )//"Cadastro Nacional de Estabelecimento de Saúde (CNES)"
		// Cria os componentes "box" horizontais para receberem elementos da View
		// cID		  	Id do Box a ser utilizado 
		// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
		// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
		// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
		// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
		// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
		oView:CreateHorizontalBox( "TELATIL" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
		// Associa um View a um box
		oView:SetOwnerView( "VIEW_TIL" , "TELATIL" )
		
		//Inclusão de itens no Ações Relacionadas de acordo com o NGRightClick
		NGMVCUserBtn(oView)

Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} fMPosValid
Pós-validação do modelo de dados.

@author Guilherme Benkendorf
@since 03/01/14

@param oModel - Objeto do modelo de dados (Obrigatório)

@return Lígico - Retorna verdadeiro caso validacoes estejam corretas
/*/
//---------------------------------------------------------------------
Static Function fMPosValid( oModel )
    
	Local lRet			:= .T.
	
	Local aAreaTIL		:= TIL->( GetArea() )

	Local nOperation	:= oModel:GetOperation() // Operação de ação sobre o Modelo
	Local oModelTIL	:= oModel:GetModel( "TILMASTER" )

	Private aCHKSQL 	:= {} // Variável para consistência na exclusão (via SX9)
	Private aCHKDEL 	:= {} // Variável para consistência na exclusão (via Cadastro)

	// Recebe SX9 - Formato:
	// 1 - Domínio (tabela)
	// 2 - Campo do Domínio
	// 3 - Contra-Domínio (tabela)
	// 4 - Campo do Contra-Domínio
	// 5 - Condição SQL
	// 6 - Comparação da Filial do Domínio
	// 7 - Comparação da Filial do Contra-Domínio
	aCHKSQL := NGRETSX9( "TIL" )

	// Recebe relação do Cadastro - Formato:
	// 1 - Chave
	// 2 - Alias
	// 3 - Ordem (Índice)
	//aAdd(aCHKDEL, { "TIL->TIL_CODRES" , TABELA , IDX } )

	If nOperation == MODEL_OPERATION_DELETE //Exclusão

		If !NGCHKDEL( "TIL" )
			lRet := .F.
		EndIf

		If lRet .And. !NGVALSX9( "TIL" , {} , .T. , .T. )
			lRet := .F.
		EndIf

	EndIf

	RestArea( aAreaTIL )

Return lRet