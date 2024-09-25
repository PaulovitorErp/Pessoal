#Include 'MDTA056.ch'
#Include 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"

#DEFINE _nVersao 2

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA056
Questionário de Produto Químico

@author Taina Alberto Cardoso - Refeito por: Gabriel Augusto Werlich
@since 19/04/13 - Revisão: 20/08/15
@return Nil
/*/
//---------------------------------------------------------------------
Function MDTA056()

	// Armazena as variáveis
	Local aNGBEGINPRM := NGBEGINPRM( _nVersao )
	Local oBrowse
	
	//Valida acesso a rotina
	If !AliasInDic("TIB")
		If !NGINCOMPDIC("UPDMDT78","THFTE6",.T.)
	  		Return .F.
		EndIf
	EndIf
	
	oBrowse := FWMBrowse():New()
		oBrowse:SetAlias( "TIB" )			// Alias da tabela utilizada
		oBrowse:SetMenuDef( "MDTA056" )	// Nome do fonte onde esta a função MenuDef
		oBrowse:SetDescription( STR0001 )	// Descrição do browse ###"Cadastro de Questionario Quimico"
	oBrowse:Activate()
	
	// Devolve as variáveis armazenadas
	NGRETURNPRM(aNGBEGINPRM)

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do Modelo (padrão MVC).

@author Gabriel Augusto Werlich
@since 20/08/15

@return oModel objeto do Modelo MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStructTIB := FWFormStruct( 1 ,"TIB" , /*bAvalCampo*/ , /*lViewUsado*/ )
	Local oStructTIC := FWFormStruct( 1 ,"TIC" , /*bAvalCampo*/ , /*lViewUsado*/ )

	// Modelo de dados que será construído
	Local oModel
	
	// Cria o objeto do Modelo de Dados
	// cID     Identificador do modelo 
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New( "MDTA056" , /*bPre*/ , { | oModel | fMPosValid( oModel ) } /*bPost*/ , /*bCommit*/ , /*bCancel*/ )
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
		oModel:AddFields( "TIBMASTER" , Nil , oStructTIB , /*bPre*/ , /*bPost*/ , /*bLoad*/ )

		oModel:AddGrid( "TICDETAIL" , "TIBMASTER" ,oStructTIC , /*bPre*/ , , /*bLoad*/ )
		
		oModel:SetRelation( 'TICDETAIL', { { 'TIC_FILIAL', 'xFilial( "TIC" )' },{ 'TIC_CODIGO', 'TIB_CODIGO' }},TIC->( IndexKey( 1 ) ) )
				
			// Adiciona a descrição do Modelo de Dados (Geral)
			oModel:SetDescription( STR0001 /*cDescricao*/ ) // "Cadastro de Questionario Quimico"
			
			// Adiciona a descricao do Componente do Modelo de Dados
			oModel:GetModel( "TIBMASTER" ):SetDescription( STR0001 ) //"Cadastro de Questionario Quimico"
			oModel:GetModel( "TICDETAIL" ):SetDescription( STR0001 ) //"Cadastro de Questionario Quimico"
			
			//Não copia os campos do array
			oModel:GetModel( 'TIBMASTER' ):SetFldNoCopy( {/*'TIB_CODPRO',*/'TIB_DESPRO', 'TIB_GRUPRO'} )
			
			oModel:GetModel( "TICDETAIL" ):SetOptional( .T. )
			
			//"Valida chave duplicada em uma linha da getdados
			oModel:GetModel( "TICDETAIL" ):SetUniqueLine( {"TIC_CODGRU", "TIC_ORDEM"} ) 

Return oModel
//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da View (padrão MVC).

@author Gabriel Augusto Werlich
@since 20/08/15

@return oView objeto da View MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()
	
	// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oModel := FWLoadModel( "MDTA056" )
	
	// Cria a estrutura a ser usada na View
	Local oStructTIB := FWFormStruct( 2 , "TIB" , /*bAvalCampo*/ , /*lViewUsado*/ )
	Local oStructTIC := FWFormStruct( 2 , "TIC" , /*bAvalCampo*/ , /*lViewUsado*/ )
	
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
		oView:AddField( "TIBMASTER" , oStructTIB )
		oView:AddGrid( "TICDETAIL" , oStructTIC )
		
			//Adiciona um titulo para o formulário
			oView:EnableTitleView( "TIBMASTER" , STR0001 )	// Descrição do browse ###"Cadastro de Questionario Quimico"
			// Cria os componentes "box" horizontais para receberem elementos da View
			// cID		  	Id do Box a ser utilizado 
			// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
			// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
			// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
			// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
			// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
			oView:CreateHorizontalBox( "SUPERIOR" , 30,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
			oView:CreateHorizontalBox( "INFERIOR" , 70,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
		
		// Associa um View a um box
		oView:SetOwnerView( "TIBMASTER" , "SUPERIOR" )
		oView:SetOwnerView( "TICDETAIL" , "INFERIOR" )

Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do Menu (padrão MVC).

@author Gabriel Augusto Werlich
@since 20/08/15

@return aRotina array com o Menu MVC
/*/
//---------------------------------------------------------------------
Static Function MenuDef()
//Inicializa MenuDef com todas as opções
Return FWMVCMenu( "MDTA056" )
//---------------------------------------------------------------------
/*/{Protheus.doc} fMPosValid
Validação da tela (Antigo TudoOk)

@author Gabriel Augusto Werlich
@since 20/08/15

@return lRet - .T. / .F. 
/*/
//---------------------------------------------------------------------
Static Function fMPosValid( oModel )
    
	Local lRet			:= .T.
	Local aAreaTIB	:= TIB->( GetArea() )
	Local nOperation	:= oModel:GetOperation() // Operação de ação sobre o Modelo

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
	aCHKSQL := NGRETSX9( "TIB" )

	// Recebe relação do Cadastro - Formato:
	// 1 - Chave
	// 2 - Alias
	// 3 - Ordem (Índice)
	aAdd(aCHKDEL, { "TIB->TIB_CODIGO" , "TID" , 1 } )

	If nOperation == MODEL_OPERATION_DELETE //Exclusão

		If !NGCHKDEL( "TIB" )
			lRet := .F.
		EndIf

		If lRet .And. !NGVALSX9( "TIB" , {} , .T. , .T. )
			lRet := .F.
		EndIf

	EndIf

	RestArea( aAreaTIB )

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT056TIPO
Validação da tela (Antigo TudoOk)

@author Gabriel Augusto Werlich
@since 20/08/15

@return lRet - .T. / .F. 
/*/
//---------------------------------------------------------------------
Function MDT056VAL(nParam)
	Local lRet := .T.
	
	If nParam == 1 .And. Empty(M->TIC_TIPO)
		lRet := .F.
		Help( , , "ATENÇÃO" , , STR0011 , 4 , 0 )//###"O campo 'Tipo' não pode estar vazio!"
	ElseIf nParam == 2 .And. Empty(M->TIC_OBRIG)
		lRet := .F.
		Help( , , "ATENÇÃO" , , STR0012 , 4 , 0 )//###"O campo 'Obrigatório' não pode estar vazio!"
	EndIf
Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT056TIPO
Busca o X3_RELACAO dos respectivos campos, se não for inclusão ou cópia.

@author Gabriel Augusto Werlich
@since 20/08/15
@param nParam - 1/2

@return cDesc - Descrição do Relacao
/*/
//---------------------------------------------------------------------
Function MDTREL056(nParam)
Local cDesc := "", cExec := ""
Local oModel := FWModelActive()
Local nOperation := oModel:GetOperation()

cExec := If( nParam == 1 , "SB1->(VDISP(TIB->TIB_CODPRO,'B1_DESC'))" , "SB1->(VDISP(TIB->TIB_CODPRO,'B1_GRUPO'))" )

If OMODEL:ACONTROLS[4] <> 6 .Or. nOperation == 3	
	cDesc := &( cExec )	
EndIf 

Return cDesc     