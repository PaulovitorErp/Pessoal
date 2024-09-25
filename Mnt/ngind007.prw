#INCLUDE	"Protheus.ch"
#INCLUDE	"NGIND007.ch"
#INCLUDE	"FWBrowse.ch"
#INCLUDE	"FWMVCDEF.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND007
Cadastro/Configuração de Indicadores Gráficos.

@author Wagner Sobral de Lacerda
@since 24/01/2012

@return .T.
/*/
//---------------------------------------------------------------------
Function NGIND007()

	//------------------------------
	// Armazena as variáveis
	//------------------------------
	Local aNGBEGINPRM := NGBEGINPRM()

	Local lExecute := .T. // Variável para identificar se pode ou não executar esta rotina
	Local oBrowse // Variável do Browse

	//-------------------------------
	// Valida a execução do programa
	//-------------------------------
	lExecute := NGIND007OP()

	If lExecute
		// Declara as Variáveis PRIVATE
		NGIND007VR()

		//----------------
		// Monta o Browse
		//----------------
		dbSelectArea("TZ9")
		dbSetOrder(1)
		dbGoTop()

		// Instanciamento da Classe de Browse
		oBrowse := FWMBrowse():New()

			// Definição da tabela do Browse
			oBrowse:SetAlias("TZ9")

			// Definição da Legenda
			NGIND007LG(@oBrowse)

			// Definição do Filtro
			NGIND007FL(@oBrowse)

			// Descrição do Browse
			oBrowse:SetDescription(cCadastro)

			// Menu Funcional relacionado ao Browse
			oBrowse:SetMenuDef("NGIND007")

		// Ativação da Classe
		oBrowse:Activate()
		//----------------
		// Fim do Browse
		//----------------
	EndIf

	//------------------------------
	// Devolve as variáveis armazenadas
	//------------------------------
	NGRETURNPRM(aNGBEGINPRM)

Return lExecute

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do Menu (padrão MVC).

@author Wagner Sobral de Lacerda
@since 24/01/2012

@return aRotina array com o Menu MVC
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	// Variável do Menu
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0001 ACTION "VIEWDEF.NGIND007" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.NGIND007" OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.NGIND007" OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.NGIND007" OPERATION 5 ACCESS 0 //"Excluir"
	//ADD OPTION aRotina TITLE "Imprimir"   ACTION "VIEWDEF.NGIND007" OPERATION 8 ACCESS 0 //Podemos permitir imprimir, num futuro próximo

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND007OP
Valida o programa, verificando se é possível executá-lo. (NGIND007Open)
* Está função pode ser utilizada por outras rotinas.

@author Wagner Sobral de Lacerda
@since 24/01/2012

@return lReturn .T. caso o programa possa ser executado; .F. no caso de uma falha e o programa não puder ser executado
/*/
//---------------------------------------------------------------------
Function NGIND007OP()

	// Variável que armazena as tabelas para validação
	Local aTables := {"TZ1", "TZ2", "TZ3", "TZ4", "TZ5", "TZ6", "TZ7", "TZ9", "TZA", "TZB", "TZC", "TZD", "TZE", "TZF", "TZG", "TZH"}
	Local nTbl := 0

	// Variável private para o função 'FWAliasInDic()' mostrar (.T.) ou não (.F.) uma mensagem de Help caso a tabela não exista
	Private lHelp := .F.

	// Verifica se o Ambiente possui a atualização dos Indicadores Gráficos
	For nTbl := 1 To Len(aTables)
		If !FWAliasInDic(aTables[nTbl])
			NGINCOMPDIC("UPDIND02", "SEM BOLETIM", .F.)
			Return .F.
		EndIf
	Next nTbl

	// Verifica se o compartilhamento dessas tabelas estão iguais.
	If !NGCHKCOMP(aTables, .T.)
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fCposExcep
Monta o Array com a excecao de campos para o Modelo/View.

@author Wagner Sobral de Lacerda
@since 24/01/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fCposExcep()

	// Salva as Áres atuais
	Local nTamTot 	:= 0
	Local nInd    	:= 0
	Local aNgHeader	:= {}

	dbSelectArea("SX3")
	dbSetOrder(2)

	//Exceção de campos na View da tabela TZ9
	aVCpoTZ9 := {}

	aAdd(aVCpoTZ9, "TZ9_CODDES")

	aAdd(aVCpoTZ9, "TZ9_MODELO")
	aAdd(aVCpoTZ9, "TZ9_TIPCON")

	aAdd(aVCpoTZ9, "TZ9_SECMIN")
	aAdd(aVCpoTZ9, "TZ9_SECMAX")

	//Buscar os campos das tabela.
	aNgHeader := NGHeader("TZ9",,.F.)
	nTamTot := Len(aNgHeader)
	For nInd := 1 To nTamTot
		If "TZ9_VAL" $ AllTrim(aNgHeader[nInd,2]) .Or. "TZ9_LEG" $ AllTrim(aNgHeader[nInd,2]) .Or.;
			"TZ9_SOMB" $ AllTrim(aNgHeader[nInd,2]) .Or. "TZ9_COR" $ AllTrim(aNgHeader[nInd,2])
			aAdd(aVCpoTZ9, AllTrim(aNgHeader[nInd,2]))
		EndIf
	Next nInd

	//Exceção de campos na View da tabela TZA
	aVCpoTZA := {}

	aAdd(aVCpoTZA, "TZA_CODGRA")

Return .T.

/*/
############################################################################################
##                                                                                        ##
## DEFINIÇÃO DO < MODELO > * MVC                                                          ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do Modelo (padrão MVC).

@author Wagner Sobral de Lacerda
@since 24/01/2012

@return oModel objeto do Modelo MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruTZ9 := FWFormStruct(1, "TZ9", /*bAvalCampo*/, /*lViewUsado*/)
	Local oStruTZA := FWFormStruct(1, "TZA", /*bAvalCampo*/, /*lViewUsado*/)

	// Modelo de dados que será construído
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("NGIND007", /*bPreValid*/, {|oModel| fMPosValid(oModel) }/*bPosValid*/, {|oModel| fMCommit(oModel) }/*bFormCommit*/, /*bFormCancel*/)

		// Valida a Ativação do Modelo
		oModel:SetVldActivate({|oModel| fMActivate(oModel) }/*bBloclVld*/)

		//--------------------------------------------------
		// Componentes do Modelo
		//--------------------------------------------------

		// Adiciona ao modelo um componente de Formulário Principal
		oModel:AddFields("TZ9MASTER"/*cID*/, /*cIDOwner*/, oStruTZ9/*oModelStruct*/, /*bPre*/, /*bPost*/, /*bLoad*/) // Cadastro do Indicador Gráfico

		// Adiciona ao modelo um componente de Grid, com o "TZ9MASTER" como Owner
		oModel:AddGrid("TZAFORMULAS"/*cID*/, "TZ9MASTER"/*cIDOwner*/, oStruTZA/*oModelStruct*/, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/) // Fórmulas relacionadas ao Indicador Gráfico

			// Define a Relação do modelo das F´rmulas com o Principal (Indicador Gráfico)
			oModel:SetRelation("TZAFORMULAS"/*cIDGrid*/,;
								{ {"TZA_FILIAL", 'xFilial("TZ9")'}, {"TZA_CODGRA", "TZ9_CODIGO"} }/*aConteudo*/,;
								TZA->( IndexKey(1) )/*cIndexOrd*/)

		// Adiciona a descrição do Modelo de Dados (Geral)
		oModel:SetDescription(STR0005/*cDescricao*/) //"Indicadores Gráficos"

			//--------------------------------------------------
			// Definições do Modelo do Indicador Gráfico
			//--------------------------------------------------

			// Adiciona a descrição do Modelo de Dados TZ9
			oModel:GetModel("TZ9MASTER"):SetDescription(STR0006/*cDescricao*/) //"Indicador Gráfico"

			//--------------------------------------------------
			// Definições do Modelo das Fórmulas
			//--------------------------------------------------

			// Adiciona a descrição do Modelo de Dados TZA
			oModel:GetModel("TZAFORMULAS"):SetDescription(STR0007/*cDescricao*/) //"Fórmulas do Indicador Gráfico"

				// Define que o Modelo não é obrigatório
				oModel:GetModel("TZAFORMULAS"):SetOptional(.T.)

				// Define qual a chave única por Linha no browse
				oModel:GetModel("TZAFORMULAS"):SetUniqueLine({"TZA_CODIND"})

		//------------------------------
		// Definição de campos MEMO VIRTUAIS
		//------------------------------

		FWMemoVirtual(oStruTZ9, { {"TZ9_CODDES", "TZ9_DESCRI"} } )

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} fMCommit
Gravação manual do Modelo de Dados.

@author Wagner Sobral de Lacerda
@since 02/03/2012

@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fMCommit(oModel)

	// Operação de ação sobre o Modelo
	Local nOperation := oModel:GetOperation()

	// Modelos
	Local oModelTZ9 := oModel:GetModel("TZ9MASTER")

	// Dados do Modelo
	Local cCodigo := oModelTZ9:GetValue("TZ9_CODIGO")

	//--------------------------------------------------
	// Gravação do Modelo de Dados
	//--------------------------------------------------
	FWFormCommit(oModel)

	//--------------------------------------------------
	// Gravação Personalizada
	//--------------------------------------------------

	If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
		// Salva as Configurações do Indicador Gráfico
		NGI7SavCfg(oPreview, cCodigo, xFilial("TZ9"))
	EndIf

Return .T.

/*/
############################################################################################
##                                                                                        ##
## DEFINIÇÃO DA < VIEW > * MVC                                                            ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da View (padrão MVC).

@author Wagner Sobral de Lacerda
@since 24/01/2012

@return oView objeto da View MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oModel := FWLoadModel("NGIND007")

	// Cria a estrutura a ser usada na View
	Local oStruTZ9 := FWFormStruct(2, "TZ9", {|cCampo| fStructCpo(cCampo, "TZ9") }/*bAvalCampo*/, /*lViewUsado*/)
	Local oStruTZA := FWFormStruct(2, "TZA", {|cCampo| fStructCpo(cCampo, "TZA") }/*bAvalCampo*/, /*lViewUsado*/)

	// Interface de visualização construída
	Local oView

	// Cria o objeto de View
	oView := FWFormView():New()

		// Define qual o Modelo de dados será utilizado na View
		oView:SetModel(oModel)

		// Valida a Inicialização da View
		oView:SetViewCanActivate({|oView| fVActivate(oView) }/*bBloclVld*/)

		//--------------------------------------------------
		// Estrutura da View
		//--------------------------------------------------
		// TZ9
		//oStruTZ9:RemoveField("TZ9_CODDES")

		//--------------------------------------------------
		// Componentes da View
		//--------------------------------------------------

		// Adiciona no View um controle do tipo formulário (antiga Enchoice)
		oView:AddField("VIEW_TZ9MASTER"/*cFormModelID*/, oStruTZ9/*oViewStruct*/, "TZ9MASTER"/*cLinkID*/, /*bValid*/)

		// Adiciona no View um controle do tipo Grid (antiga Getdados)
		oView:AddGrid("VIEW_TZAFORMULAS"/*cFormModelID*/, oStruTZA/*oViewStruct*/, "TZAFORMULAS"/*cLinkID*/, /*bValid*/)

		//--------------------------------------------------
		// Layout
		//--------------------------------------------------

		// Cria os componentes "box" horizontais para receberem elementos da View
		oView:CreateHorizontalBox("BOX_SUPERIOR"/*cID*/, 050/*nPercHeight*/, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)
		oView:CreateHorizontalBox("BOX_INFERIOR"/*cID*/, 050/*nPercHeight*/, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)

			//Cria os componentes "box" verticais dentro do box horizontal
			oView:CreateVerticalBox("BOX_INFERIOR_ESQ"/*cID*/, 050/*nPercHeight*/, "BOX_INFERIOR"/*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)
			oView:CreateVerticalBox("BOX_INFERIOR_DIR"/*cID*/, 050/*nPercHeight*/, "BOX_INFERIOR"/*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)

				// Cria os componentes "box" horizontais, dentro dos verticais
				oView:CreateHorizontalBox("BOX_IND_INFERIOR_FORMULA"/*cID*/, 100/*nPercHeight*/, "BOX_INFERIOR_ESQ"/*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)
				oView:CreateHorizontalBox("BOX_IND_INFERIOR_PREVIEW"/*cID*/, 100/*nPercHeight*/, "BOX_INFERIOR_DIR"/*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)

					// Adiciona um "outro" tipo de objeto, o qual não faz necessariamente parte do modelo
					oView:AddOtherObject("VIEW_INDIC"/*cFormModelID*/, {|oPanel| fOtherPrew(oPanel) }/*bActivate*/, {|oPanel| fFreeOther(oPanel) }/*bDeActivate*/, /*bRefresh*/)

		// Relaciona o identificador (ID) da View com o "box" para exibição
		oView:SetOwnerView("VIEW_TZ9MASTER"  /*cFormModelID*/, "BOX_SUPERIOR"/*cIDUserView*/)
		oView:SetOwnerView("VIEW_TZAFORMULAS"/*cFormModelID*/, "BOX_IND_INFERIOR_FORMULA"/*cIDUserView*/)
		oView:SetOwnerView("VIEW_INDIC"      /*cFormModelID*/, "BOX_IND_INFERIOR_PREVIEW"/*cIDUserView*/)

		// Adiciona um Título para a View
		oView:EnableTitleView("VIEW_TZ9MASTER"  /*cFormModelID*/, STR0006/*cTitle*/, /*nColor*/) //"Indicador Gráfico"
		oView:EnableTitleView("VIEW_INDIC"      /*cFormModelID*/, STR0008/*cTitle*/, /*nColor*/) //"Pré-Visualização"
		oView:EnableTitleView("VIEW_TZAFORMULAS"/*cFormModelID*/, STR0009/*cTitle*/, /*nColor*/) //"Fórmulas"

		//--------------------------------------------------
		// Ações da View (não refletem no Modelo de Dados, logo, não interferem na regra de negócio)
		//--------------------------------------------------

		// Define uma ação a ser executada na View quando a validação de um campo do Modelo for Efetuada
		oView:SetFieldAction("TZ9_TITULO"/*cIDField*/, {|oView, cIDView, cField, xValue| fFieldAction(oView, cIDView, cField, xValue) }/*bAction*/)
		oView:SetFieldAction("TZ9_SUBTIT"/*cIDField*/, {|oView, cIDView, cField, xValue| fFieldAction(oView, cIDView, cField, xValue) }/*bAction*/)
		oView:SetFieldAction("TZ9_DESCRI"/*cIDField*/, {|oView, cIDView, cField, xValue| fFieldAction(oView, cIDView, cField, xValue) }/*bAction*/)

		oView:SetFieldAction("TZ9_ATIVO" /*cIDField*/, {|oView, cIDView, cField, xValue| fFieldAction(oView, cIDView, cField, xValue) }/*bAction*/)

Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} fStructCpo
Valida os campos da estrutura do Modelo ou View.

@author Wagner Sobral de Lacerda
@since 24/01/2012

@param cCampo
	Campo atual sendo verificado na estrutura * Obrigatório
@param cEstrutura
	Tabela da estrutura sendo carregada * Obrigatório

@return .T. caso o campo seja valido; .F. se nao for valido
/*/
//---------------------------------------------------------------------
Static Function fStructCpo(cCampo, cEstrutura)

	// Variável de cópia do array de Exceções
	Local aExcecao := {}

	// Recebe os campos de exceção
	If cEstrutura == "TZ9"
		aExcecao := aClone( aVCpoTZ9 )
	ElseIf cEstrutura == "TZA"
		aExcecao := aClone( aVCpoTZA )
	EndIf

	// Valida o Campo
	If aScan(aExcecao, {|x| AllTrim(x) == AllTrim(cCampo) }) > 0
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fFieldAction
Define uma ação a ser executada quando um campo é Alterado/Validado
com sucesso.

@author Wagner Sobral de Lacerda
@since 03/02/2012

@param oView
	Objeto da View * Obrigatório
@param cIDView
	ID da da View * Obrigatório
@param cField
	Campo acionado * Obrigatório
@param xValue
	Valor atual do campo * Obrigatório

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fFieldAction(oView, cIDView, cField, xValue)

	// Salva as Áres atuais
	Local aAreaTZ9 := TZ9->( GetArea() )
	Local aAreaTZA := TZA->( GetArea() )

	// Variáveis de 'Action'
	Local aChgPreview := {}
	Local aChgOthers  := {}

	// Define os campos que devem atualizar o Preview
	aAdd(aChgPreview, "TZ9_TITULO")
	aAdd(aChgPreview, "TZ9_SUBTIT")
	aAdd(aChgPreview, "TZ9_DESCRI")
	aAdd(aChgPreview, "TZ9_ATIVO" )

	//------------------------------
	// Atualiza o objeto Preview
	//------------------------------
	If aScan(aChgPreview, {|x| x == cField }) > 0
		fPrewAtu(oView)
	EndIf

	// Devolve as Áres
	RestArea(aAreaTZ9)
	RestArea(aAreaTZA)

Return .T.

/*/
############################################################################################
##                                                                                        ##
## DEFINIÇÃO DOS "OTHER OBJECT" PARA A VIEW DO * MVC                                      ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} fOtherPrew
Monta a Preview (pré-visualização) do Indicador Gráfico.

@author Wagner Sobral de Lacerda
@since 24/01/2012

@param oPanel
	Painel pai dos objetos * Obrigatório

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fOtherPrew(oPanel)

	// Salva as Áres atuais
	Local aAreaTZ9 := TZ9->( GetArea() )
	Local aAreaTZA := TZA->( GetArea() )

	// Dados do Modelo
	Local cValCodigo := FWFldGet("TZ9_CODIGO")

	// Variáveis para montar o Indicador Gráfico
	Local oPnlPai := Nil

	// Painel Pai do Preview
	oPnlPai := TPanel():New(01, 01, , oPanel, , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
	oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

		// Monta o Preview do Indicador
		oPreview := TNGIndicator():New(/*nTop*/, /*nLeft*/, 1/*nZoom*/, oPnlPai/*oParent*/, /*nWidth*/, /*nHeight*/, ;
										/*nClrFooter*/, /*cContent*/, /*cStyle*/, /*lScroll*/, .T./*lCenter*/)
		oPreview:SetFields(NGI7Fields())
		oPreview:Indicator() // Cria o Indicador em Tela
		If INCLUI
			oPreview:SetRClick(.F.)
		Else
			// Carrega as Configurações para o Indicador Gráfico em tela
			NGI7LoaCfg(@oPreview, cValCodigo, xFilial("TZ9"), .F.)
			If !ALTERA
				oPreview:CanConfig(.F.)
			EndIf
		EndIf
		oPreview:SetCodeBlock(2, {|lOk| fPrewAfter(lOk) }) // Após a tela de Configuração do Indicador
		oPreview:SetValue( aTail(oPreview:GetVals()) )

	// Devolve as Áres
	RestArea(aAreaTZ9)
	RestArea(aAreaTZA)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fPrewAtu
Atualiza o Preview do Indicador Gráfico.

@author Wagner Sobral de Lacerda
@since 26/01/2012

@param oView
	Objeto da View * Opcional
@param cIDView
	Identificador (ID) da View * Opcional (Obrigatório quando passar o objeto oView)
@param cField
	Identificador (ID) do Campo * Opcional
@param xValue
	Conteúdo do Campo * Opcional

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fPrewAtu(oView)

	// Salva as Áres atuais
	Local aAreaTZ9 := TZ9->( GetArea() )
	Local aAreaTZA := TZA->( GetArea() )

	// Modelos
	Local oModelTZ9 := oView:GetModel("TZ9MASTER")

	// Dados do Modelo
	Local cTitulo := oModelTZ9:GetValue("TZ9_TITULO")
	Local cSubtit := oModelTZ9:GetValue("TZ9_SUBTIT")

	// Variáveis para atualização do Indicador
	Local aDescricao := {}
	Local aTextos    := {}

	//----------------------------
	// Carrega Variáveis
	//----------------------------
	// Título e Subtítulo
	aAdd(aTextos, cTitulo)
	aAdd(aTextos, cSubtit)

	// Descrição
	aAdd(aDescricao, "")
	aAdd(aDescricao, "")
	aAdd(aDescricao, "")

	//----------------------------
	// Atualiza o objeto Preview
	//----------------------------
	oPreview:Refresh(.F.) // Desabilita o Refresh

	oPreview:SetTexts(aTextos)
	oPreview:SetDesc(aDescricao)

	oPreview:Refresh(.T.) // Habilita o Refresh, e já o executa

	// Devolve as Áres
	RestArea(aAreaTZ9)
	RestArea(aAreaTZA)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fPrewAfter
Personalização após a tela de Configuração do Indicador.

@author Wagner Sobral de Lacerda
@since 11/04/2012

@param lOk
	Indica como a tela foi encerrada: * Obrigatório
	   .T. - através de Confirmação
	   .F. - através de Cancelamento

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fPrewAfter(lOk)

	// Modelos
	Local oView     := FWViewActive(oBkpView)
	Local oModelTZ9 := oView:GetModel("TZ9MASTER")

	// Dados do Modelo
	Local cOldTitulo := FWFldGet("TZ9_TITULO")

	// Dados do Indicador
	Local aTextos := aClone( oPreview:GetTexts() )

	// Verifica se alterou o formulário
	If lOk
		// Atualiza os Textos
		oModelTZ9:SetValue("TZ9_TITULO", aTextos[1])
		oModelTZ9:SetValue("TZ9_SUBTIT", aTextos[2])

		// Se atualizou mas não houve alteração no formulário
		If !oModelTZ9:IsModified()
			oView:SetModified(.T./*lSet*/)
			// Força uma atualização no formulário
			oModelTZ9:SetValue("TZ9_TITULO", "ZZZ")
			oModelTZ9:SetValue("TZ9_TITULO", cOldTitulo)
		EndIf
	EndIf

	oView:Refresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fFreeOther
Destroi os objetos dos 'Other Objetcs'.

@author Wagner Sobral de Lacerda
@since 24/01/2012

@param oPanel
	Painel pai dos objetos * Obrigatório

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fFreeOther(oPanel)

	// Destrói o Indicador
	If Type("oPreview") == "O" .And. oPreview:ClassName() == "TNGINDICATOR"
		oPreview:Destroy()
	EndIf

	// Libera os componentes Filhos do painel
	If ValType(oPanel) == "O"
		oPanel:FreeChildren()
	EndIf

Return .T.

/*/
############################################################################################
##                                                                                        ##
## DEFINIÇÃO DAS VALIDAÇÕES * MVC                                                         ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} fMActivate
Valida a ativação do modelo de dados.

@author Wagner Sobral de Lacerda
@since 24/01/2012

@param oModel
	Objeto do modelo de dados * Obrigatório

@return lReturn
/*/
//---------------------------------------------------------------------
Static Function fMActivate(oModel)

	// Operação de ação sobre o Modelo
	Local nOperation := oModel:GetOperation()

	// Variáveis auxiliares do Help
	Local cAuxHelp01 := ""

	// Variável do Retorno
	Local lReturn := .T.

	//------------------------------
	// Valida a Ativação do Modelo
	//------------------------------
	If nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE // Alteração ou Exclusão

		If nOperation == MODEL_OPERATION_UPDATE
			cAuxHelp01 := STR0011 //"Este registro não pode ser alterado porque não pertence a este módulo."
		Else
			cAuxHelp01 := STR0012 //"Este registro não pode ser excluído porque não pertence a este módulo."
		EndIf

		If TZ9->TZ9_MODULO <> Str(nModulo,2) // Módulo
			Help(Nil, Nil, STR0013, Nil, cAuxHelp01, 1, 0) //"Atenção"
			lReturn := .F.
		EndIf

	EndIf

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} fVActivate
Valida se pode ativar a View.

@author Wagner Sobral de Lacerda
@since 30/01/2012

@return lReturn .T. pode inicializar; .F. não pode
/*/
//---------------------------------------------------------------------
Static Function fVActivate(oView)

	// Operação de ação sobre o Modelo
	Local nOperation := oView:GetOperation()

	// Variáveis auxiliares do Help
	Local cAuxHelp01 := ""

	// Variável do Retorno
	Local lReturn := .T.

	//------------------------------
	// Valida a Ativação da View
	//------------------------------
	If nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE // Alteração ou Exclusão

		cAuxHelp01 := STR0015 //"Este registro não pode ser excluído porque seu proprietário é o"
		cAuxHelp01 +=  " '" + AllTrim( NGRETSX3BOX("TZ9_PROPRI",TZ9->TZ9_PROPRI) ) + "'."

		If TZ9->TZ9_PROPRI == "1" // Protheus
			If nOperation == MODEL_OPERATION_DELETE // Impede a deleção do indicador
				Help(Nil, Nil, STR0013, Nil, cAuxHelp01, 1, 0) // "Atenção"
				lReturn := .F.
			EndIf
		EndIf

	EndIf

	// Armazena um backup da view
	oBkpView := oView

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} fMPosValid
Pós-validação do modelo de dados.

@author Wagner Sobral de Lacerda
@since 24/01/2012

@param oModel
	Objeto do modelo de dados * Obrigatório

@return lReturn
/*/
//---------------------------------------------------------------------
Static Function fMPosValid(oModel)

	// Salva as Áres atuais
	Local aAreaTZ9 := TZ9->( GetArea() )
	Local aAreaTZA := TZA->( GetArea() )

	// Operação de ação sobre o Modelo
	Local nOperation := oModel:GetOperation()

	// Modelos
	Local oModelTZ9 := oModel:GetModel("TZ9MASTER")
	Local oModelTZA := oModel:GetModel("TZAFORMULAS")

	// Variável do Retorno
	Local lReturn := .T.

	//----------
	// Valida
	//----------
	If nOperation <> MODEL_OPERATION_DELETE // Diferente de Exclusão

		If nOperation == MODEL_OPERATION_INSERT // Inclusão

			// O Código do Usuário deve estar preenchido quando o Proprietário for 'Usuário'
			If oModelTZ9:GetValue("TZ9_PROPRI") == "2"
				If Empty(oModelTZ9:GetValue("TZ9_USCAD"))
					Help(Nil, Nil, STR0013, Nil,;
						STR0016 + " '" + AllTrim( NGRETSX3BOX("TZ9_PROPRI",TZ9->TZ9_PROPRI) ) + "'",; //"O Usuário é uma informação obrigatória quando o proprietário do Indicador é"
						1, 0) //"Atenção"
					lReturn := .F.
				EndIf
			EndIf
		EndIf

		// Valida Modelo TZ9
		If !oModelTZ9:VldData()
			lReturn := .F.
		EndIf

		// Valida Modelo TZA
		If !oModelTZA:VldData()
			lReturn := .F.
		EndIf

	EndIf

	// Devolve as Áres
	RestArea(aAreaTZ9)
	RestArea(aAreaTZA)

Return lReturn

/*/
############################################################################################
##                                                                                        ##
## FUNÇÕES AUXILIARES DA ROTINA                                                           ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND007LG
Função para adicionar uma Legenda padronizada ao browse de
Indicadores Gráficos (tabela TZ9)

@author Wagner Sobral de Lacerda
@since 24/01/2012

@param oObjBrw
	Objeto do FWMBrowse * Obrigatório

@return .T.
/*/
//---------------------------------------------------------------------
Function NGIND007LG(oObjBrw)

	// Variável do retorno
	Local lRetorno := .F.

	// Defaults
	Default oObjBrw := Nil

	//----------
	// Legenda
	//----------
	If ValType(oObjBrw) == "O" .And. MethIsMemberOf(oObjBrw,"ClassName")
		If Upper(oObjBrw:ClassName()) == "FWMBROWSE" .And. oObjBrw:Alias() == "TZ9"
			oObjBrw:AddLegend("TZ9_ATIVO == '1'", "GREEN", STR0017) //"Ativo"
			oObjBrw:AddLegend("TZ9_ATIVO == '2'", "RED"  , STR0018) //"Inativo"

			lRetorno := .T.
		EndIf
	EndIf

Return lRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND007FL
Função para adicionar um Filtro padronizado ao browse de
Indicadores Gráficos (tabela TZ9)

@author Wagner Sobral de Lacerda
@since 24/01/2012

@param oObjBrw
	Objeto do FWMBrowse * Obrigatório

@return .T.
/*/
//---------------------------------------------------------------------
Function NGIND007FL(oObjBrw)

	// Variável do retorno
	Local lRetorno := .F.

	// Defaults
	Default oObjBrw := Nil

	//----------
	// Legenda
	//----------
	If ValType(oObjBrw) == "O" .And. MethIsMemberOf(oObjBrw,"ClassName")
		If Upper(oObjBrw:ClassName()) == "FWMBROWSE" .And. oObjBrw:Alias() == "TZ9"
			oObjBrw:SetFilterDefault("TZ9_MODULO == '" + Str(nModulo,2) + "'")

			lRetorno := .T.
		EndIf
	EndIf

Return lRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND007VR
Declara as variáveis Private utilizadas no Indicador Gráfico.
* Lembrando que essas variáveis ficam declaradas somente para a função
que é Pai imediata desta.

@author Wagner Sobral de Lacerda
@since 03/02/2012

@param lUseDefault
	Indica se deve definir os conteúdos default das variáveis * Opcional
	   .T. - Define conteúdos Default
	   .F. - Não define conteúdos Default
	Default: .T.

@return .T.
/*/
//---------------------------------------------------------------------
Function NGIND007VR(lUseDefault)

	// Salva as Áres atuais
	Local aAreaTZ9 := TZ9->( GetArea() )
	Local aAreaTZA := TZA->( GetArea() )

	// Defaults
	Default lUseDefault := .T.

	//------------------------------
	// Declara as variáveis
	//------------------------------
	// Variável do Cadastro
	_SetOwnerPrvt("cCadastro", OemToAnsi(STR0005)) //"Indicadores Gráficos"

	// Variável da Consulta SXB Genérica
	_SetOwnerPrvt("cMntGenFun", "NGIND007M1()")
	_SetOwnerPrvt("cMntGenRet", "NGIND007M2()")
	_SetOwnerPrvt("cRetModulo", Str(nModulo,2))

	_SetOwnerPrvt("aVCpoTZ9", {}) // Variável de exceção de campos na View da TZ9
	_SetOwnerPrvt("aVCpoTZA", {}) // Variável de exceção de campos na View da TZA

	_SetOwnerPrvt("oPreview", Nil) // Objeto Preview (pré-visualização) do Indicador
	_SetOwnerPrvt("oBkpView", Nil) // Objeto da View Atual do cadstro do Indicador

	// Devolve as Áres
	RestArea(aAreaTZ9)
	RestArea(aAreaTZA)

	//------------------------------
	// Define conteúdos Default
	//------------------------------
	// Monta o array com a exceção de campos
	fCposExcep()

Return .T.

/*/
############################################################################################
##                                                                                        ##
## FUNÇÕES UTILIZADAS NO DICIONÁRIO DE DADOS / MODELO DE DADOS                            ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND007M1
Função para criar a Consulta de Módulos.

@author Wagner Sobral de Lacerda
@since 03/02/2012

@return .T.
/*/
//---------------------------------------------------------------------
Function NGIND007M1()

	// Salva as Áres atuais
	Local aAreaTZ9 := TZ9->( GetArea() )
	Local aAreaTZA := TZA->( GetArea() )

	// Variáveis do Browse
	Local oDlgConMod := Nil, oPnlAll := Nil, oPnlBot  := Nil, oBtnConfir := Nil, oBtnCancel := Nil
	Local oBrwConMod := Nil, oColuna := Nil, aColunas := {}

	// Variáveis de controlo dos módulos
	Local aInfoUser  := {}
	Local nNumModulo := 0
	Local nX := 0, nPos := 0

	Local aModUser := {}
	Local nRetOk   := 0

	//----------------------------------------
	// Módulos que o usuário possui acesso
	//----------------------------------------
	aModUser := aClone( NGUserMod() )

	//----------------------------------------
	// Tela da Consulta
	//----------------------------------------
	nRetOk := 0
	DEFINE MSDIALOG oDlgConMod TITLE OemToAnsi(STR0019) FROM 0,0 TO 350,800 OF oMainWnd PIXEL //"Módulos Acessíveis"

		// Painal ALL do Browse
		oPnlAll := TPanel():New(01, 01, , oDlgConMod, , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
		oPnlAll:Align := CONTROL_ALIGN_ALLCLIENT

			// Monta o Browse
			oBrwConMod := FWBrowse():New(oPnlAll)

			oBrwConMod:SetDataArray()
			oBrwConMod:SetInsert(.F.) // Desabilita a Inserção de registros
			oBrwConMod:DisableReport() // Desabilita a Impressão
			oBrwConMod:SetLocate() // Habilita a Localização de registros
			oBrwConMod:SetSeek() // Habilita a Pesquisa de registros

			//oBrwConMod:SetLineHeight(16)

			aColunas := {}
				// Coluna: Número do Módulo (Código)
				oColuna := FWBrwColumn():New()
				oColuna:SetAlign(CONTROL_ALIGN_LEFT)
				oColuna:SetData({|| aModUser[oBrwConMod:AT()][1] })
				oColuna:SetEdit(.F.)
				oColuna:SetSize(10)
				oColuna:SetTitle(STR0020) //"Código"
				oColuna:SetType("N")

				aAdd(aColunas, oColuna)

				// Coluna: Nome do Módulo
				oColuna := FWBrwColumn():New()
				oColuna:SetAlign(CONTROL_ALIGN_LEFT)
				oColuna:SetData({|| aModUser[oBrwConMod:AT()][2] })
				oColuna:SetEdit( .F. )
				oColuna:SetSize(15)
				oColuna:SetTitle(STR0021) //"Nome"
				oColuna:SetType("C")

				aAdd(aColunas, oColuna)

				// Coluna: Descrição do Módulo
				oColuna := FWBrwColumn():New()
				oColuna:SetAlign(CONTROL_ALIGN_LEFT)
				oColuna:SetData({|| aModUser[oBrwConMod:AT()][3] })
				oColuna:SetEdit( .F. )
				oColuna:SetSize(40)
				oColuna:SetTitle(STR0022) //"Descrição"
				oColuna:SetType("C")

				aAdd(aColunas, oColuna)

			oBrwConMod:SetColumns(aColunas)
			oBrwConMod:SetArray(aModUser)

			oBrwConMod:Activate()
			oBrwConMod:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
			oBrwConMod:SetDoubleClick({|| Eval(oBtnConfir:bAction) })

		// Painel BOT dos Botões
		oPnlBot := TPanel():New(01, 01, , oDlgConMod, , , , CLR_BLACK, CLR_WHITE, 100, 016, .F., .F.)
		oPnlBot:Align := CONTROL_ALIGN_BOTTOM

			// Botão de OK
			oBtnConfir := TButton():New(002, 010, "Ok", oPnlBot, {|| nRetOk := oBrwConMod:AT(), oDlgConMod:End() },;
											040, 012, , , .F., .T., .F., , .F., , , .F.)

			// Botão de Cancelar
			oBtnCancel := TButton():New(002, 060, STR0023, oPnlBot, {|| nRetOk := 0, oDlgConMod:End() },; //"Cancelar"
											040, 012, , , .F., .T., .F., , .F., , , .F.)


	ACTIVATE MSDIALOG oDlgConMod CENTER

	If nRetOk > 0
		cRetModulo := Str(aModUser[nRetOk][1],2)
	Else
		cRetModulo := Str(nModulo,2)
	EndIf

	// Devolve as Áres
	RestArea(aAreaTZ9)
	RestArea(aAreaTZA)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND007M2
Função do retorno da Consulta de Módulos.

@author Wagner Sobral de Lacerda
@since 03/02/2012

@return cReturn Conteúdo (em caractere) do Módulo
/*/
//---------------------------------------------------------------------
Function NGIND007M2()

	// Salva as Áres atuais
	Local aAreaTZ9 := TZ9->( GetArea() )
	Local aAreaTZA := TZA->( GetArea() )

	// Variável do Retorno
	Local cReturn := Space(TAMSX3("TZ9_MODULO")[1])

	// Recebe o Retorno
	If ValType(cRetModulo) == "C"
		cReturn := cRetModulo
	EndIf

	// Devolve as Áres
	RestArea(aAreaTZ9)
	RestArea(aAreaTZA)

Return cReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND007MD
Função para validar o Módulo do Indicador Gráfico.

@author Wagner Sobral de Lacerda
@since 03/02/2012

@return lReturn
/*/
//---------------------------------------------------------------------
Function NGIND007MD()

	// Salva as Áres atuais
	Local aAreaTZ9 := TZ9->( GetArea() )
	Local aAreaTZA := TZA->( GetArea() )

	// Módulos que o usuário possui acesso
	Local aModUser := aClone( NGUserMod() )

	// Dados do Modelo
	Local cValModulo := Str(nModulo,2)

	// Variável do Retorno
	Local lReturn := .T.

	//----------
	// Valida
	//----------
	If aScan(aModUser, {|x| Str(x[1],2) == cValModulo }) == 0
		Help(Nil, Nil, STR0013, Nil, STR0024, 1, 0) //"Atenção" ## "O Módulo selecionado é inválido porque ou não existe, ou você não possui permissão de acesso à ele."
		lReturn := .F.
	EndIf

	// Devolve as Áres
	RestArea(aAreaTZ9)
	RestArea(aAreaTZA)

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND007FO
Função para validar a Fórmula relacionada ao Indicador Gráfico.

@author Wagner Sobral de Lacerda
@since 09/04/2012

@return lReturn
/*/
//---------------------------------------------------------------------
Function NGIND007FO()

	// Salva as Áres atuais
	Local aAreaTZ9 := TZ9->( GetArea() )
	Local aAreaTZA := TZA->( GetArea() )

	// Dados do Modelo
	Local cValCodigo := FWFldGet("TZ9_CODIGO")
	Local cValModulo := Str(nModulo,2)
	Local cValFormul := FWFldGet("TZA_CODIND")

	// Variáveis da query
	Local cQryAlias := ""
	Local cQryDupli := ""

	// Variável do Retorno
	Local lReturn := .T.

	//----------
	// Valida
	//----------
	If !ExistCpo("TZ5", cValModulo + cValFormul, 1)
		lReturn := .F.
	EndIf

	// Duplicidade com outros cadastros de Indicadores Gráficos
	If lReturn
		// Query de registros duplicados (fórmulas já cadastrados para outro Indicador Gráfico)
		cQryAlias := GetNextAlias()

		// SELECT
		cQryDupli := "SELECT "
		cQryDupli += " TZA.TZA_CODGRA AS CODGRA, "
		cQryDupli += " COUNT(*) AS DUPLIC "
		// FROM
		cQryDupli += "FROM " + RetSQLName("TZA") + " TZA "
		//WHERE
		cQryDupli += "WHERE "
		cQryDupli += " TZA.TZA_CODIND = " + ValToSQL(cValFormul) + " "
		cQryDupli += " AND TZA.TZA_CODGRA <> " + ValToSQL(cValCodigo) + " "
		cQryDupli += " AND TZA.D_E_L_E_T_ <> '*' "
		// GROUP BY
		cQryDupli += "GROUP BY "
		cQryDupli += " TZA.TZA_CODGRA "

		// Executa a Query
		cQryDupli := ChangeQuery(cQryDupli)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryDupli), cQryAlias, .T., .T.)

		// Verifica se há registro duplicados
		dbSelectArea(cQryAlias)
		dbGoTop()
		While !Eof()
			If (cQryAlias)->DUPLIC > 0
				Help(Nil, Nil, STR0013, Nil,;
					STR0025 + " '" + AllTrim( (cQryAlias)->CODGRA ) + "'.",; //"Esta Fórmula não pode ser vinculada a este Indicador Gráfico porque ela já está relacionada a outro indicador, de código"
					1, 0) //"Atenção"
				lReturn := .F.
			EndIf

			dbSelectArea(cQryAlias)
			dbSkip()
		End
		dbSelectArea(cQryAlias)
		dbCloseArea()
	EndIf

	// Devolve as Áres
	RestArea(aAreaTZ9)
	RestArea(aAreaTZA)

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND007FO
Função para retornar o ComboBox do campo Modelo do Indicador Gráfico.
("TZ9_MODELO")

@author Wagner Sobral de Lacerda
@since 29/08/2012

@return uReturn
/*/
//---------------------------------------------------------------------
Function NGIND007BX(nTypeRet)

	// Variável do Retorno
	Local uReturn := Nil

	// Variáveis do ComboBox
	Local cComboBox := STR0026
	Local aComboBox := StrTokArr(cComboBox, ";")

	// Defaults
	Default nTypeRet := 1

	// Define o retorno
	If nTypeRet == 1
		uReturn := cComboBox
	ElseIf nTypeRet == 2
		uReturn := aComboBox
	EndIf

Return uReturn

/*/
############################################################################################
##                                                                                        ##
## FUNÇÕES PARA MANIPULAÇÃO DA CLASSE 'TNGIndicator'                                      ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} NGI7SavCfg
Função que salva as Configurações do Indicador.
* ATENÇÃO: apenas SALVA no Indicador que já existe
(não cria um registro, somente altera)

@author Wagner Sobral de Lacerda
@since 25/01/2012

@param oObjIndic
	Objeto do Indicador Gráfico * Obrigatório
@param cCodIndic
	Código do Indicador Gráfico para salvar o Indicador * Opcional
	Default: oObjIndic:cLoadIndic (Código do Indicador atualmente carregado)
@param cCodFilial
	Código da Filial para salvar o Indicador * Opcional
	Default: oObjIndic:cLoadFilia (Filial atualmente carregada para o Indicador)

@return .T. Configuração salva; .F. caso não
/*/
//---------------------------------------------------------------------
Function NGI7SavCfg(oObjIndic, cCodIndic, cCodFilial) // SaveConfig

	// Salva as Áres atuais
	Local aAreaTZ9 := {}

	// Variáveis das definições do Indicador
	Local cStyle   := oObjIndic:GetStyle()
	Local cContent := oObjIndic:GetContent()

	Local aConfig    := aClone( oObjIndic:GetConfig()  )
	Local aCores     := aClone( oObjIndic:GetColors()  )
	Local aDescricao := aClone( oObjIndic:GetDesc()    )
	Local aSombras   := aClone( oObjIndic:GetShadows() )
	Local aTextos    := aClone( oObjIndic:GetTexts()   )
	Local aValores   := aClone( oObjIndic:GetVals()    )
	Local nQtdeVals  := oObjIndic:nMaxVals

	// Variável do Retorno
	Local lReturn := .F.

	// Defaults
	Default cCodIndic  := oObjIndic:cLoadIndic
	Default cCodFilial := oObjIndic:cLoadFilia

	// Define o tamanho código do Indicador Gráfico
	cCodIndic := PADR(cCodIndic, TAMSX3("TZ9_CODIGO")[1], " ")

	// Armazena a área atual
	aAreaTZ9 := TZ9->( GetArea() )

	// Se o ambiente estiver aberto, atualiza o registro na tabela de Indicadores Gráficos
	dbSelectArea("TZ9")
	dbSetOrder(1)
	If dbSeek(cCodFilial+cCodIndic)

		BEGIN TRANSACTION //Inicializa a Transação

			// Trava o registro para alteração
			RecLock("TZ9", .F.)

			// Título e Subtítulo
			TZ9->TZ9_TITULO := aTextos[1]
			TZ9->TZ9_SUBTIT := aTextos[2]

			// Legenda das Seções
			TZ9->TZ9_LEGMIN := aDescricao[1]
			TZ9->TZ9_LEGMED := aDescricao[2]
			TZ9->TZ9_LEGMAX := aDescricao[3]

			// Estilo (modelo)
			TZ9->TZ9_MODELO := cStyle

			// Tipo de Conteúdo
			TZ9->TZ9_TIPCON := cContent

			// Configurações das Seções
			TZ9->TZ9_SECMIN := aConfig[3][1][2] // Porcentagem
			TZ9->TZ9_SECMAX := aConfig[3][2][2] // Porcentagem

			// Valores
			TZ9->TZ9_VAL01 := If(nQtdeVals >= 1, aValores[1], 0)
			TZ9->TZ9_VAL02 := If(nQtdeVals >= 2, aValores[2], 0)
			TZ9->TZ9_VAL03 := If(nQtdeVals >= 3, aValores[3], 0)
			TZ9->TZ9_VAL04 := If(nQtdeVals >= 4, aValores[4], 0)
			TZ9->TZ9_VAL05 := If(nQtdeVals >= 5, aValores[5], 0)
			TZ9->TZ9_VAL06 := If(nQtdeVals >= 6, aValores[6], 0)
			TZ9->TZ9_VAL07 := If(nQtdeVals >= 7, aValores[7], 0)

			// Sombreamento ("1=Sim;2=Não")
			TZ9->TZ9_SOMB01 := If(aSombras[1], "1", "2")
			TZ9->TZ9_SOMB02 := If(aSombras[2], "1", "2")
			TZ9->TZ9_SOMB03 := If(aSombras[3], "1", "2")

			// Cores
			TZ9->TZ9_COR01 := aCores[1]
			TZ9->TZ9_COR02 := aCores[2]
			TZ9->TZ9_COR03 := aCores[3]
			TZ9->TZ9_COR04 := aCores[4]
			TZ9->TZ9_COR05 := aCores[5]
			TZ9->TZ9_COR06 := aCores[6]
			TZ9->TZ9_COR07 := aCores[7]
			TZ9->TZ9_COR08 := aCores[8]
			TZ9->TZ9_COR09 := aCores[9]
			TZ9->TZ9_COR10 := aCores[10]
			TZ9->TZ9_COR11 := aCores[11]
			TZ9->TZ9_COR12 := aCores[12]
			TZ9->TZ9_COR13 := aCores[13]
			TZ9->TZ9_COR14 := aCores[14]

			// Libera o registro travado
			MsUnlock("TZ9")

		END TRANSACTION // Encerra a Transação

		lReturn := .T.

	EndIf

	// Devolve a área
	RestArea(aAreaTZ9)

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} NGI7LoaCfg
Função que carrega as Configurações do Indicador.

@author Wagner Sobral de Lacerda
@since 25/01/2012

@param oObjIndic
	Objeto do Indicador Gráfico * Obrigatório
@param cCodIndic
	Código do Indicador Gráfico para carregar o Indicador * Obrigatório
@param cCodFilial
	Código da Filial para carregar o Indicador * Opcional
	Default: xFilial("TZ9")
@param lShowMsg
	Indica se deve mostrar mensagem em tela * Opcional
	   .T. - Mostra mensagem
	   .F. - Não mostra
	Default: .T.

@return .T. Configuração carregada; .F. caso não
/*/
//---------------------------------------------------------------------
Function NGI7LoaCfg(oObjIndic, cCodIndic, cCodFilial, lShowMsg) // LoadConfig

	// Salva as Áres atuais
	Local aAreaTZ9 := {}

	// Variáveis das definições do Indicador (não carregará caso não encontre o Indicador na base de dados)
	Local cStyle   := oObjIndic:GetStyle()
	Local cContent := oObjIndic:GetContent()
	Local cModLoad := ""

	Local aConfig    := aClone( oObjIndic:GetConfig()  )
	Local aCores     := {}
	Local aDescricao := {}
	Local aSombras   := {}
	Local aTextos    := {}
	Local aValores   := {}
	Local nQtdeVals  := 7 // Vamos utilizar a quantidade máxima

	// Variável do Retorno
	Local lReturn := .F.

	// Defaults
	Default cCodIndic  := ""
	Default cCodFilial := ""
	Default lShowMsg   := .T.

	// Define o código da filial
	cCodFilial := If(Empty(cCodFilial), xFilial("TZ9"), cCodFilial)

	// Define o código do Indicador Gráfico
	cCodIndic := PADR(cCodIndic, TAMSX3("TZ9_CODIGO")[1], " ")

	// Armazena a área atual
	aAreaTZ9 := TZ9->( GetArea() )

	// Busca o indicador na tabela de Indicadores Gráficos
	dbSelectArea("TZ9")
	dbSetOrder(1)
	If dbSeek(cCodFilial + cCodIndic)

		// Módulo
		cModLoad := TZ9->TZ9_MODULO

		// Título e Subtítulo
		aTextos := Array(3)
		aTextos[1] := TZ9->TZ9_TITULO
		aTextos[2] := TZ9->TZ9_SUBTIT
		// Descrição
		aDescricao := Array(3)
		aDescricao[1] := TZ9->TZ9_LEGMIN
		aDescricao[2] := TZ9->TZ9_LEGMED
		aDescricao[3] := TZ9->TZ9_LEGMAX

		// Estilo (modelo)
		cStyle := TZ9->TZ9_MODELO

		// Tipo de Conteúdo
		cContent := TZ9->TZ9_TIPCON

		// Configurações das Seções (este array já está pre-definido, não precisando criá-lo então com a função 'Array()')
		aConfig[3][1][2] := Round(TZ9->TZ9_SECMIN,2) // Porcentagem
		aConfig[3][2][2] := Round(TZ9->TZ9_SECMAX,2) // Porcentagem

		// Valores
		aValores := Array(nQtdeVals)
		If Len(aValores) >= nQtdeVals
			aValores[1] := Round(TZ9->TZ9_VAL01,2)
		EndIf
		If Len(aValores) >= nQtdeVals
			aValores[2] := Round(TZ9->TZ9_VAL02,2)
		EndIf
		If Len(aValores) >= nQtdeVals
			aValores[3] := Round(TZ9->TZ9_VAL03,2)
		EndIf
		If Len(aValores) >= nQtdeVals
			aValores[4] := Round(TZ9->TZ9_VAL04,2)
		EndIf
		If Len(aValores) >= nQtdeVals
			aValores[5] := Round(TZ9->TZ9_VAL05,2)
		EndIf
		If Len(aValores) >= nQtdeVals
			aValores[6] := Round(TZ9->TZ9_VAL06,2)
		EndIf
		If Len(aValores) >= nQtdeVals
			aValores[7] := Round(TZ9->TZ9_VAL07,2)
		EndIf

		// Sombreamento ("1=Sim;2=Não")
		aSombras := Array(3)
		aSombras[1] := ( AllTrim(TZ9->TZ9_SOMB01) == "1" )
		aSombras[2] := ( AllTrim(TZ9->TZ9_SOMB02) == "1" )
		aSombras[3] := ( AllTrim(TZ9->TZ9_SOMB03) == "1" )

		// Cores
		aCores := Array(14)
		aCores[1] := SubStr(TZ9->TZ9_COR01, 1, 7)
		aCores[2] := SubStr(TZ9->TZ9_COR02, 1, 7)
		aCores[3] := SubStr(TZ9->TZ9_COR03, 1, 7)
		aCores[4] := SubStr(TZ9->TZ9_COR04, 1, 7)
		aCores[5] := SubStr(TZ9->TZ9_COR05, 1, 7)
		aCores[6] := SubStr(TZ9->TZ9_COR06, 1, 7)
		aCores[7] := SubStr(TZ9->TZ9_COR07, 1, 7)
		aCores[8] := SubStr(TZ9->TZ9_COR08, 1, 7)
		aCores[9] := SubStr(TZ9->TZ9_COR09, 1, 7)
		aCores[10] := SubStr(TZ9->TZ9_COR10, 1, 7)
		aCores[11] := SubStr(TZ9->TZ9_COR11, 1, 7)
		aCores[12] := SubStr(TZ9->TZ9_COR12, 1, 7)
		aCores[13] := SubStr(TZ9->TZ9_COR13, 1, 7)
		aCores[14] := SubStr(TZ9->TZ9_COR14, 1, 7)

		lReturn := .T.

	EndIf

	// Devolve a área
	RestArea(aAreaTZ9)

	// Atualiza o Indicador Gráfico
	oObjIndic:cLoadFormu := ""
	If lReturn

		// Bloqueia a Atualiação do Indicador
		oObjIndic:Refresh(.F.)

		// Variáveis identificadores de que o Indicador foi carregado
		oObjIndic:cLoadIndic := cCodIndic
		oObjIndic:cLoadFilia := cCodFilial
		oObjIndic:cLoadModul := cModLoad

		// Inicializa o Indicador (ou Reinicializa) para poder prepará-lo para as configurações carregadas
		oObjIndic:Initialize()

		// Seta as definições do Indicador
		oObjIndic:SetStyle(cStyle)
		oObjIndic:SetContent(cContent)

		oObjIndic:SetConfig(aConfig)
		oObjIndic:SetColors(aCores)
		oObjIndic:SetShadows(aSombras)
		oObjIndic:SetTexts(aTextos)
		oObjIndic:SetDesc(aDescricao)
		oObjIndic:SetVals(aValores)

		// Atualiza o Indicador
		oObjIndic:Refresh(.T.)

	Else

		// Variáveis identificadores de que o Indicador foi carregado
		oObjIndic:cLoadIndic := ""
		oObjIndic:cLoadFilia := ""
		oObjIndic:cLoadModul := ""

		// Mensagem
		If lShowMsg
			Help(Nil, Nil, STR0013, Nil, STR0027 + ":" + CRLF + ; //"Atenção" ## "Não foi possível carregar o cadastro do Indicador Gráfico"
					STR0028 + ": '" + cCodFilial + "'" + CRLF + ; //"Filial"
					STR0020 + ": '" + cCodIndic + "'", 1, 0) //"Código"
		EndIf

	EndIf

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} NGI7LoaFrm
Função que carrega uma Fórmula para o Indicador.

@author Wagner Sobral de Lacerda
@since 23/04/2012

@param oObjIndic
	Objeto do Indicador Gráfico * Obrigatório
@param cCodFormul
	Código da Fórmula para carregar no Indicador * Obrigatório
@param cCodFilial
	Código da Filial para carregar a Fórmula * Opcional
	Default: xFilial("TZA")
@param cCodModul
	Código do Módulo da Fórmula para carregar no Indicador * Opcional
	Default: Str(nModulo,2)
@param lShowMsg
	Indica se deve mostrar mensagem em tela * Opcional
	   .T. - Mostra mensagem
	   .F. - Não mostra
	Default: .T.

@return .T./.F.
/*/
//---------------------------------------------------------------------
Function NGI7LoaFrm(oObjIndic, cCodFormul, cCodFilial, cCodModul, lShowMsg) // LoadFormul

	// Salva as Áres atuais
	Local aAreaTZ5 := {}
	Local aAreaTZ9 := {}
	Local aAreaTZA := {}

	// Variáveis das definições do Indicador
	Local aDescricao := {}
	Local aTextos    := {}

	Local cNomeFormu := ""

	// Variável do Retorno
	Local lReturn := .F.

	// Defaults
	Default cCodFormul := ""
	Default cCodFilial := ""
	Default cCodModul  := ""
	Default lShowMsg   := .T.

	// Se o Indicador Gráfico não estiver carregado, carrega
	If Empty(oObjIndic:cLoadIndic)
		cCodFilial := If(Empty(cCodFilial), xFilial("TZA"), cCodFilial)
		cCodModul  := If(Empty(cCodModul), Str(nModulo,2), cCodModul)

		aAreaTZ9 := TZ9->( GetArea() )
		aAreaTZA := TZA->( GetArea() )
		dbSelectArea("TZA")
		dbSetOrder(2)
		dbSeek(cCodFilial + cCodFormul, .T.)
		While !Eof() .And. TZA->TZA_FILIAL == cCodFilial .And. TZA->TZA_CODIND == cCodFormul
			dbSelectArea("TZ9")
			dbSetOrder(1)
			If dbSeek(TZA->TZA_FILIAL + TZA->TZA_CODGRA) .And. TZ9->TZ9_MODULO == cCodModul
				NGI7LoaCfg(oObjIndic, TZA->TZA_CODGRA, TZA->TZA_FILIAL, lShowMsg)
				Exit
			EndIf

			dbSelectArea("TZA")
			dbSkip()
		End
		RestArea(aAreaTZ9)
		RestArea(aAreaTZA)
	EndIf

	// Se o Indicador Gráfico estiver carregado
	If !Empty(oObjIndic:cLoadIndic)
		// Armazena a área atual
		aAreaTZ5 := TZ5->( GetArea() )

		// Variáveis das definições do Indicador
		aDescricao := aClone( oObjIndic:GetDesc() )
		aTextos    := aClone( oObjIndic:GetTexts() )

		// Busca o indicador na tabela de Indicadores Gráficos
		dbSelectArea("TZ5")
		dbSetOrder(1)
		If dbSeek(oObjIndic:cLoadFilia + oObjIndic:cLoadModul + cCodFormul)
			// Título e Subtítulo
			aTextos[1] := TZ5->TZ5_CODIND

			lReturn := .T.
		EndIf

		// Devolve a área
		RestArea(aAreaTZ5)
	EndIf

	If lReturn

		// Bloqueia a Atualiação do Indicador
		oObjIndic:Refresh(.F.)

		// Atualiza a variável da Fórmula carregada
		oObjIndic:cLoadFormu := cCodFormul

		// Seta as definições do Indicador
		oObjIndic:SetTexts(aTextos)
		oObjIndic:SetDesc(aDescricao)
		oObjIndic:SetTooltip(cNomeFormu)

		// Atualiza o Indicador
		oObjIndic:Refresh(.T.)

	Else

		// Mensagem
		If lShowMsg
			Help(Nil, Nil, cCodFormul, Nil, STR0029 + ":" + CRLF + ; //"Não foi possível carregar o cadastro da Fórmula"
					STR0028 + ": '" + oObjIndic:cLoadFilia + "'" + CRLF + ; //"Filial"
					STR0020 + ": '" + cCodFormul + "'", 1, 0) //"Código"
		EndIf

		Return .F.

	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} NGI7Fields
Executa a 'SetFields' do Indicador Gráfico.
* Define as especificações dos campos do array 'aFields', propriedade
da classe TNGIndicator.

@author Wagner Sobral de Lacerda
@since 28/08/2012

@return aFields
/*/
//---------------------------------------------------------------------
Function NGI7Fields() // SetFields

	// Variável do Retorno
	Local aFieldInfo := {}

	// Variáveis dos campos para buscar
	Local aCposX3 := {}
	Local nCpo := 0

	// Variáveis auxiliares
	Local cIDCampo := ""
	Local cTitulo  := ""

	//-- Define os campos
	aAdd(aCposX3, "TZ9_TITULO") // Posição '__nFldTitl'
	aAdd(aCposX3, "TZ9_SUBTIT") // Posição '__nFldSubt'
	aAdd(aCposX3, "TZ9_LEGMIN") // Posição '__nFldLeg1'
	aAdd(aCposX3, "TZ9_LEGMED") // Posição '__nFldLeg2'
	aAdd(aCposX3, "TZ9_LEGMAX") // Posição '__nFldLeg3'
	aAdd(aCposX3, "TZ9_MODELO") // Posição '__nFldModl'
	aAdd(aCposX3, "TZ9_TIPCON") // Posição '__nFldTipC'

	//----------------------------------------
	// Define os Tamanhos e Decimais
	//----------------------------------------
	For nCpo := 1 To Len(aCposX3)
		dbSelectArea("SX3")
		dbSetOrder(2)
		dbSeek(aCposX3[nCpo])

		cIDCampo  := aCposX3[nCpo]
		cTitulo   := AllTrim( If("_LEG" $ cIDCampo, X3Descric(), X3Titulo()) )
		cAuxSoluc := AllTrim( StrTran(GetHlpSoluc(cIDCampo)[1],CRLF," ") )

		// Adiciona no array
		aAdd(aFieldInfo, {	cTitulo                 , ; // [1] - Título
							Posicione("SX3",2,aCposX3[nCpo],"X3_TAMANHO")         , ; // [2] - Tamanho
							Posicione("SX3",2,aCposX3[nCpo],"X3_DECIMAL")         , ; // [3] - Decimal
							AllTrim(Posicione("SX3",2,aCposX3[nCpo],"X3_PICTURE")), ; // [4] - Picture
							AllTrim(X3CBox())        }) // [5] - ComboBox
	Next nCpo

Return aFieldInfo

//---------------------------------------------------------------------
/*/{Protheus.doc} NGI7Info
Função que carrega as Informações do Indicador Gráfico.

@author Wagner Sobral de Lacerda
@since 28/08/2012

@param oObjIndic
	Objeto do Indicador Gráfico * Obrigatório

@return .T.
/*/
//---------------------------------------------------------------------
Function NGI7Info(oObjIndic) // Information

	// Variáveis do objeto
	Local aInfo := aClone( oObjIndic:GetInfo() )
	Local nInfo := 0

	// Variáveis da Janela
	Local oDlgInf
	Local cDlgInf := OemToAnsi(STR0030) //"Informações"

	Local oBackground
	Local oBtnFechar
	Local nFIM_LIN, nFIM_COL

	Local cAuxSay := ""
	Local cAuxGet := "", lIsChar := .F.
	Local nAuxSiz := 0, nMinSiz := 40
	Local nLin, nCol

	//--------------------
	// Monta as Informações
	//--------------------
	DEFINE MSDIALOG oDlgInf TITLE cDlgInf FROM 0,0 TO 340,450 OF oMainWnd STYLE WS_POPUPWINDOW PIXEL

		// Tamanhos Finais
		nFIM_LIN := ( oDlgInf:nClientHeight * 0.50 )
		nFIM_COL := ( oDlgInf:nClientWidth * 0.50 )

		// Background
		oBackground := fRClkBack(@oDlgInf)

			// Botão: Fechar
			oBtnFechar := TBtnBmp2():New(001, ((nFIM_COL*2)-020), 20, 20, "BR_CANCEL", , , , {|| oDlgInf:End() }, oBackground, OemToAnsi(STR0031)) //"Fechar"
			oBtnFechar:lCanGotFocus := .F.

			// GroupBox
			TGroup():New(010, 005, (nFIM_LIN-005), (nFIM_COL-005), STR0032, oBackground, , , .T., ) //"Informações sobre o Objeto"

				// Monta as Informações do Objeto
				nLin := 025
				nCol := 015
				For nInfo := 1 To Len(aInfo)
					//--- Mensagem
					cAuxSay := "{|| '" + aInfo[nInfo][1]+":" + "' }"
					TSay():New(nLin+001, nCol, &(cAuxSay), oBackground, , , , , , .T., CLR_BLACK, , 150, 012)

					//--- Conteúdo
					lIsChar := ValType(aInfo[nInfo][2]) == "C"
					nAuxSiz := ( Len(aInfo[nInfo][2]) * 5 )
					If nAuxSiz < nMinSiz
						nAuxSiz := nMinSiz
					EndIf

					cAuxGet := "{|| " + If(lIsChar,"'","") + aInfo[nInfo][2] + If(lIsChar,"'","") + " }"
					TGet():New((nLin-001), (nCol+090), &(cAuxGet), oBackground, nAuxSiz, 008, "",;
								{|| .T. }, , , ,;
								.F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "", , , , .T./*lHasButton*/)

					// Incrementa a linha
					nLin += 15
				Next nInfo

	ACTIVATE MSDIALOG oDlgInf CENTERED

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} NGI7Detail
Função que carrega os Detalhes do Indicador Gráfico.

@author Wagner Sobral de Lacerda
@since 28/08/2012

@param oObjIndic
	Objeto do Indicador Gráfico * Obrigatório

@return .T./.F.
/*/
//---------------------------------------------------------------------
Function NGI7Detail(oObjIndic) // LoadFormul

	// Salva as Áres atuais
	Local aAreaSX3 := SX3->( GetArea() )

	// Variáveis do Objeto
	Local cCodIndic  := oObjIndic:cLoadIndic
	Local cCodFilial := oObjIndic:cLoadFilia
	Local cCodModulo := oObjIndic:cLoadModul
	Local cCodFormul := oObjIndic:cLoadFormu

	// Variáveis da Query
	Local cQryAlias := ""
	Local cQryLegen := ""

	// Variáveis da Janela
	Local oDlgDet
	Local cDlgDet := OemToAnsi(STR0033) //"Detalhamento"

	Local oBackground
	Local oBtnFechar
	Local nFIM_LIN, nFIM_COL

	Local cAuxSay, cAuxGet, cAuxPic, cAuxSiz, oAuxFnt
	Local nLin, nCol

	Local aFields
	Local aPosTZ9 := 0
	Local aPosTZ5 := 0
	Local lFirst := .F.
	Local nX := 0


	//--------------------
	// Busca os Detalhes
	//--------------------
	cQryAlias := GetNextAlias()

	// SELECT
	cQryLegen := "SELECT "
	cQryLegen += " TZ9.TZ9_CODIGO, "
	cQryLegen += " TZ9.TZ9_TITULO, "
	cQryLegen += " TZ9.TZ9_SUBTIT, "
	cQryLegen += " TZ5.TZ5_CODIND, "
	cQryLegen += " TZ5.TZ5_NOME, "
	cQryLegen += " TZ5.TZ5_UNIMED "
	// FROM 'TZ9'
	cQryLegen += "FROM " + RetSQLName("TZ9") + " TZ9 "
	// INNER JOIN 'TZA'
	cQryLegen += "INNER JOIN " + RetSQLName("TZA") + " TZA "
	cQryLegen += " ON ( "
	cQryLegen += "  TZA.TZA_CODGRA = TZ9.TZ9_CODIGO "
	cQryLegen += "  AND TZA.TZA_FILIAL = TZ9.TZ9_FILIAL "
	cQryLegen += "  AND TZA.TZA_CODIND = " + ValToSQL(cCodFormul) + " "
	cQryLegen += "  AND TZA.D_E_L_E_T_ <> '*' "
	cQryLegen += " ) "
	// INNER JOIN 'TZ5'
	cQryLegen += "INNER JOIN " + RetSQLName("TZ5") + " TZ5 "
	cQryLegen += " ON ( "
	cQryLegen += "  TZ5.TZ5_CODIND = TZA.TZA_CODIND "
	cQryLegen += "  AND TZ5.TZ5_MODULO = TZ9.TZ9_MODULO "
	cQryLegen += "  AND TZ5.TZ5_CODIND = " + ValToSQL(cCodFormul) + " "
	cQryLegen += "  AND TZ5.D_E_L_E_T_ <> '*' "
	cQryLegen += " ) "
	//WHERE
	cQryLegen += "WHERE "
	cQryLegen += " TZ9.TZ9_CODIGO = " + ValToSQL(cCodIndic) + " "
	cQryLegen += " AND TZ9.TZ9_FILIAL = " + ValToSQL(cCodFilial) + " "
	cQryLegen += " AND TZ9.TZ9_MODULO = " + ValToSQL(cCodModulo) + " "
	cQryLegen += " AND TZ9.D_E_L_E_T_ <> '*' "

	// Executa a Query
	cQryLegen := ChangeQuery(cQryLegen)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryLegen), cQryAlias, .T., .T.)

	//--------------------
	// Monta os Detalhes
	//--------------------
	dbSelectArea(cQryAlias)
	dbGoTop()
	If Eof()
		Help(Nil, Nil, STR0013, Nil, STR0034, 1, 0) //"Atenção" ## "Não foi encontrado nenhum detalhamento para este indicador."
		Return .F.
	Else
		//--------------------
		// Monta os Campos
		//--------------------
		// Define o array de campos (ID do campo ; Título ; Picture ; Tamanho do objeto 'Get')
		aFields := {}
		aAdd(aFields, {"TZ9_CODIGO", "", "", 0})
		aAdd(aFields, {"TZ9_TITULO", "", "", 0})
		aAdd(aFields, {"TZ9_SUBTIT", "", "", 0})
		aAdd(aFields, {"TZ5_CODIND", "", "", 0})
		aAdd(aFields, {"TZ5_NOME"  , "", "", 0})
		aAdd(aFields, {"TZ5_UNIMED", "", "", 0})

		// Define até qual posição corresponde a cade tabela no array 'aFields'
		aPosTZ9 := {1,3}
		aPosTZ5 := {4,6}

		// Calcula o tamanho dos objetos 'Get'
		For nX := 1 To Len(aFields)
			dbSelectArea("SX3")
			dbSetOrder(2)
			If dbSeek(aFields[nX][1])
				aFields[nX][2] := AllTrim(X3Titulo())
				aFields[nX][3] := AllTrim(Posicione("SX3",2,aFields[nX][1],"X3_PICTURE"))

				aFields[nX][4] := CalcFieldSize( AllTrim(Posicione("SX3",2,aFields[nX][1],"X3_TIPO")), Posicione("SX3",2,aFields[nX][1],"X3_TAMANHO"),;
					Posicione("SX3",2,aFields[nX][1],"X3_DECIMAL"), aFields[nX][3], aFields[nX][2] )
			EndIf
		Next nX

		//--------------------
		// Monta a Janela
		//--------------------
		DEFINE MSDIALOG oDlgDet TITLE cDlgDet FROM 0,0 TO 350,600 OF oMainWnd STYLE WS_POPUPWINDOW PIXEL

			// Tamanhos Finais
			nFIM_LIN := Round( ( oDlgDet:nClientHeight * 0.50 ) ,0)
			nFIM_COL := Round( ( oDlgDet:nClientWidth * 0.50 ) ,0)

			// Background
			oBackground := fRClkBack(@oDlgDet)

				// Botão: Fechar
				oBtnFechar := TBtnBmp2():New(001, ((nFIM_COL*2)-020), 20, 20, "BR_CANCEL", , , , {|| oDlgDet:End() }, oBackground, OemToAnsi(STR0031)) //"Fechar"
				oBtnFechar:lCanGotFocus := .F.

				// GroupBox
				TGroup():New(010, 005, (nFIM_LIN-005), (nFIM_COL-005), STR0033, oBackground, , , .T., ) //"Detalhamento"

					oAuxFnt := TFont():New(,,,,.T.) // Fonte em Negrito
					nCol := 015 // Coluna Inicial

					//------------------------------
					// Indicador Gráfico
					//------------------------------
					nLin := 025 // Linha Inicial
					// GroupBox
					TGroup():New(nLin, nCol, ((nFIM_LIN/2)-005), (nFIM_COL-015), STR0006, oBackground, , , .T., ) //"Indicador Gráfico"

						// Botão: Visualizar o Cadastro
						TButton():New(((nFIM_LIN/2)-022), (nFIM_COL-060), STR0035, oBackground, {|| fRClkVCad("TZ9", oObjIndic) },; //"Ver Cadastro"
										040, 012, , , .F., .T., .F., , .F., , , .F.)

						// Monta os Campos
						lFirst := .T.
						For nX := aPosTZ9[1] To aPosTZ9[2]
							// Incrementa a Linha
							nLin += 015

							// SAY
							cAuxSay := "{|| '" + aFields[nX][2] + ":" + "' }"
							TSay():New(nLin, (nCol+010), &(cAuxSay), oBackground, , If(lFirst,oAuxFnt,Nil), , , , .T., CLR_BLACK, , 150, 012)

							// GET
							cAuxGet := "{|| (cQryAlias)->" + aFields[nX][1] + " }"
							cAuxPic := "'" + aFields[nX][3] + "'"
							cAuxSiz := cValToChar(aFields[nX][4])
							TGet():New((nLin-001), (nCol+050), &(cAuxGet), oBackground, &(cAuxSiz), 008, &(cAuxPic),;
										{|| .T. }, , , , .F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "", , , , .T./*lHasButton*/)

							If lFirst
								lFirst := .F.
							EndIf
						Next nX

					//------------------------------
					// Fórmula
					//------------------------------
					nLin := ((nFIM_LIN/2)+005) // Linha Inicial
					// GroupBox
					TGroup():New(nLin, nCol, ((nFIM_LIN)-025), (nFIM_COL-015), "Fórmula", oBackground, , , .T., )

						// Botão: Visualizar o Cadastro
						TButton():New(((nFIM_LIN)-042), (nFIM_COL-060), STR0035, oBackground, {|| fRClkVCad("TZ5", oObjIndic) },; //"Ver Cadastro"
										040, 012, , , .F., .T., .F., , .F., , , .F.)

						// Monta os Campos
						lFirst := .T.
						For nX := aPosTZ5[1] To aPosTZ5[2]
							// Incrementa a Linha
							nLin += 015

							// SAY
							cAuxSay := "{|| '" + aFields[nX][2] + ":" + "' }"
							TSay():New(nLin, (nCol+010), &(cAuxSay), oBackground, , If(lFirst,oAuxFnt,Nil), , , , .T., CLR_BLACK, , 150, 012)

							// GET
							cAuxGet := "{|| (cQryAlias)->" + aFields[nX][1] + " }"
							cAuxPic := "'" + aFields[nX][3] + "'"
							cAuxSiz := cValToChar(aFields[nX][4])
							TGet():New((nLin-001), (nCol+050), &(cAuxGet), oBackground, &(cAuxSiz), 008, &(cAuxPic),;
										{|| .T. }, , , , .F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "", , , , .T./*lHasButton*/)

							If lFirst
								lFirst := .F.
							EndIf
						Next nX

		ACTIVATE MSDIALOG oDlgDet CENTERED
	EndIf

	dbSelectArea(cQryAlias)
	dbCloseArea()

	// Devolve as Áres
	RestArea(aAreaSX3)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} NGI7Legend
Função que carrega a Legenda do Indicador Gráfico.

@author Wagner Sobral de Lacerda
@since 27/08/2012

@param oObjIndic
	Objeto do Indicador Gráfico * Obrigatório

@return .T.
/*/
//---------------------------------------------------------------------
Function NGI7Legend(oObjIndic) // LoadFormul

	// Variáveis do Objeto
	Local cCodIndic  := oObjIndic:cLoadIndic
	Local cCodFilial := oObjIndic:cLoadFilia
	Local cCodModulo := oObjIndic:cLoadModul
	Local cCodFormul := oObjIndic:cLoadFormu

	// Variáveis da Legenda
	Local aLegenda := {}
	Local nLeg := 0

	// Variáveis da Query
	Local cQryAlias := ""
	Local cQryLegen := ""

	// Variáveis da Janela
	Local oDlgLeg
	Local cDlgLeg := OemToAnsi(STR0036) //"Legenda"
	Local oPnlLeg

	Local oPnlImg
	Local oObjImg

	Local oPnlAll
	Local oPnlMsg
	Local oPnlIte

	Local oPnlTmp
	Local cAuxSay
	Local aClrLeg

	Local nLin, nCol

	//--------------------
	// Busca a Legenda
	//--------------------
	cQryAlias := GetNextAlias()

	// SELECT
	cQryLegen := "SELECT "
	cQryLegen += " TZ9.TZ9_COR02 AS COR_SECMIN, "
	cQryLegen += " TZ9.TZ9_LEGMIN AS LEG_SECMIN, "
	cQryLegen += " TZ9.TZ9_COR03 AS COR_SECMED, "
	cQryLegen += " TZ9.TZ9_LEGMED AS LEG_SECMED, "
	cQryLegen += " TZ9.TZ9_COR04 AS COR_SECMAX, "
	cQryLegen += " TZ9.TZ9_LEGMAX AS LEG_SECMAX "
	// FROM 'TZ9'
	cQryLegen += "FROM " + RetSQLName("TZ9") + " TZ9 "
	// INNER JOIN 'TZA'
	cQryLegen += "INNER JOIN " + RetSQLName("TZA") + " TZA "
	cQryLegen += " ON ( "
	cQryLegen += "  TZA.TZA_CODGRA = TZ9.TZ9_CODIGO "
	cQryLegen += "  AND TZA.TZA_FILIAL = TZ9.TZ9_FILIAL "
	cQryLegen += "  AND TZA.TZA_CODIND = " + ValToSQL(cCodFormul) + " "
	cQryLegen += "  AND TZA.D_E_L_E_T_ <> '*' "
	cQryLegen += " ) "
	//WHERE
	cQryLegen += "WHERE "
	cQryLegen += " TZ9.TZ9_CODIGO = " + ValToSQL(cCodIndic) + " "
	cQryLegen += " AND TZ9.TZ9_FILIAL = " + ValToSQL(cCodFilial) + " "
	cQryLegen += " AND TZ9.TZ9_MODULO = " + ValToSQL(cCodModulo) + " "
	cQryLegen += " AND TZ9.D_E_L_E_T_ <> '*' "

	// Executa a Query
	cQryLegen := ChangeQuery(cQryLegen)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryLegen), cQryAlias, .T., .T.)

	dbSelectArea(cQryAlias)
	dbGoTop()
	If !Eof()
		// Armazena as Legendas
		aAdd(aLegenda, {AllTrim((cQryAlias)->COR_SECMIN), AllTrim((cQryAlias)->LEG_SECMIN)})
		aAdd(aLegenda, {AllTrim((cQryAlias)->COR_SECMED), AllTrim((cQryAlias)->LEG_SECMED)})
		aAdd(aLegenda, {AllTrim((cQryAlias)->COR_SECMAX), AllTrim((cQryAlias)->LEG_SECMAX)})

		// Se houver legenda em branco, definie um conteúdo default
		aEval(aLegenda, {|x| If(Empty(x[2]), x[2] := STR0037,) }) //"Não disponível."
	End
	dbSelectArea(cQryAlias)
	dbCloseArea()

	//--------------------
	// Monta a Legenda
	//--------------------
	If Len(aLegenda) == 0
		Help(Nil, Nil, STR0013, Nil, STR0038, 1, 0) //"Atenção" ## "Não foi encontrado nenhuma legenda para este indicador."
		Return .F.
	Else
		//--------------------
		// Monta a Janela
		//--------------------
		DEFINE MSDIALOG oDlgLeg TITLE cDlgLeg FROM 0,0 TO 150,400 OF oMainWnd PIXEL

			// Painel pricipal do Dialog
			oPnlLeg := TPanel():New(01, 01, , oDlgLeg, , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
			oPnlLeg:Align := CONTROL_ALIGN_ALLCLIENT

				// Painel da Imagem
				oPnlImg := TPanel():New(01, 01, , oPnlLeg, , , , CLR_BLACK, CLR_WHITE, 050, 100, .F., .F.)
				oPnlImg:Align := CONTROL_ALIGN_LEFT

					// Imagem
					oObjImg := TBitmap():New (0/*nTop*/, 0/*nLeft*/, 10/*nWidth*/, 10/*nHeight*/, "backgroundblacklotus"/*cResName*/, /*cBmpFile*/, ;
							   			.T./*lNoBorder*/, oPnlImg/*oWnd*/, /*bLClicked*/, /*bRClicked*/, .F./*lScroll*/, .T./*lStretch*/, ;
										/*oCursor*/, /*uParam14*/, /*uParam15*/, /*bWhen*/, .T./*lPixel*/, ;
										/*bValid*/, /*uParam19*/, /*uParam20*/, /*uParam21*/ )
					oObjImg:Align := CONTROL_ALIGN_ALLCLIENT


				// Painel da Legenda
				oPnlAll := TPanel():New(01, 01, , oPnlLeg, , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
				oPnlAll:Align := CONTROL_ALIGN_ALLCLIENT


					// Painel da Mensagem
					oPnlMsg := TPanel():New(01, 01, , oPnlAll, , , , CLR_BLACK, CLR_WHITE, 100, 020, .F., .F.)
					oPnlMsg:Align := CONTROL_ALIGN_TOP

						// Mensagem
						@ 005,005 SAY OemToAnsi(STR0036) FONT TFont():New(,,18,,.T.) OF oPnlMsg PIXEL //"Legenda"
						@ 006.5,040 SAY "(" + OemToAnsi(STR0039 + " " + AllTrim(cCodFormul)) + ")" FONT TFont():New(,,12,,.F.) OF oPnlMsg PIXEL //"Fórmula:"
						TGroup():New(015, 01, 018, (oPnlMsg:nClientWidth*0.50), , oPnlMsg, , , .T., )

					// Painel os Itens
					oPnlIte := TPanel():New(01, 01, , oPnlAll, , , , CLR_BLACK, CLR_WHITE, 100, 020, .F., .F.)
					oPnlIte:Align := CONTROL_ALIGN_ALLCLIENT

						// Monta os Itens da Legenda
						nLin := 005
						nCol := 010
						For nLeg := 1 To Len(aLegenda)
							// Painel por trás da cor da seção
							oPnlTmp := TPanel():New(nLin, nCol, , oPnlIte, , , , CLR_BLACK, CLR_BLACK, 015, 010, .F., .F.)
							// Painel da cor da seção
							aClrLeg := NGHEXRGB( SubStr(aLegenda[nLeg][1],2) )
							TPanel():New(nLin+0.5, nCol+0.5, , oPnlIte, , , , CLR_BLACK, RGB(aClrLeg[1],aClrLeg[2],aClrLeg[3]), 014, 009, .F., .F.)

							// Descrição da Legenda
							cAuxSay := "{|| OemToAnsi('" + aLegenda[nLeg][2] + "') }"
							TSay():New(nLin+001, nCol+020, &(cAuxSay), oPnlIte, , , , , , .T., CLR_BLACK, , 150, 012)

							// Incrementa a linha
							nLin += 015
						Next nLeg

		ACTIVATE MSDIALOG oDlgLeg CENTERED
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fRClkBack
Função que retorna o BITMAP de fundo utilizado nos painéis do
clique da direita sobre o Indicador Gráfico.

@author Wagner Sobral de Lacerda
@since 28/08/2012

@param oPnlPai
	Objeto do Painel pai * Obrigatório

@return oBitmap
/*/
//---------------------------------------------------------------------
Static Function fRClkBack(oPnlPai)

	// Variável do retorno
	Local oBitmap

	// Imagem do Background
	oBitmap := TBitmap():New(0/*nTop*/, 0/*nLeft*/, 10/*nWidth*/, 10/*nHeight*/, "fw_degrade_menu"/*cResName*/, /*cBmpFile*/, ;
					   			.T./*lNoBorder*/, oPnlPai/*oWnd*/, /*bLClicked*/, /*bRClicked*/, .F./*lScroll*/, .T./*lStretch*/, ;
								/*oCursor*/, /*uParam14*/, /*uParam15*/, /*bWhen*/, .T./*lPixel*/, ;
								/*bValid*/, /*uParam19*/, /*uParam20*/, /*uParam21*/ )
	oBitmap:Align := CONTROL_ALIGN_ALLCLIENT

Return oBitmap

//---------------------------------------------------------------------
/*/{Protheus.doc} fRClkVCad
Função que Visualiza o cadastro da tabela do clique da direita sobre o
Indicador Gráfico.

@author Wagner Sobral de Lacerda
@since 29/08/2012

@param cAliasCad
	Tabela do cadastro * Obrigatório
@param oObjIndic
	Objeto do Indicador Gráfico * Obrigatório

@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fRClkVCad(cAliasCad, oObjIndic)

	// Variáveis de armazenamento de estado anterior
	Local aOldRotina := Nil
	Local cOldCadast := Nil
	Local lOldINCLUI := Nil
	Local lOldALTERA := Nil

	//------------------------------
	// Armazena variáveis anteriores
	//------------------------------
	If Type("aRotina") == "A"
		aOldRotina := aClone( aRotina )
	Else
		Private aRotina := {}
	EndIf
	If Type("cCadastro") == "C"
		cOldCadast := cCadastro
	Else
		Private cCadastro := ""
	EndIf
	If Type("INCLUI") == "L"
		lOldINCLUI := INCLUI
	Else
		Private INCLUI := .T.
	EndIf
	If Type("ALTERA") == "L"
		lOldALTERA := ALTERA
	Else
		Private ALTERA := .T.
	EndIf

	// Define 'aRotina'
	aAdd(aRotina, {"", "", 0, 1})
	aAdd(aRotina, {"", "", 0, 2})
	aAdd(aRotina, {"", "", 0, 3})
	aAdd(aRotina, {"", "", 0, 4})
	aAdd(aRotina, {"", "", 0, 5})

	// Define 'INCLUI' e 'ALTERA'
	INCLUI := .F.
	ALTERA := .F.

	//--------------------
	// Monta o Cadastro
	//--------------------
	MsgRun(STR0040, STR0041, {|| fRClkECad(cAliasCad, oObjIndic) }) //"Visualizando o cadastro..." ## "Por favor, aguarde..."

	// Devolve variáveis
	If Type("aOldRotina") == "A"
		aRotina := aClone( aOldRotina )
	EndIf
	If Type("cOldCadast") == "C"
		cCadastro := cOldCadast
	EndIf
	If Type("lOldINCLUI") == "L"
		INCLUI := lOldINCLUI
	EndIf
	If Type("lOldALTERA") == "L"
		ALTERA := lOldALTERA
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fRClkECad
Função que Executa a visualização do cadastro da tabela do clique da
direita sobre o Indicador Gráfico.

@author Wagner Sobral de Lacerda
@since 29/08/2012

@param cAliasCad
	Tabela do cadastro * Obrigatório
@param oObjIndic
	Objeto do Indicador Gráfico * Obrigatório

@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fRClkECad(cAliasCad, oObjIndic)

	// Variáveis do Objeto
	Local cCodIndic  := oObjIndic:cLoadIndic
	Local cCodFilial := oObjIndic:cLoadFilia
	Local cCodModulo := oObjIndic:cLoadModul
	Local cCodFormul := oObjIndic:cLoadFormu

	// Variáveis da Busca do registro
	Local nIndice := 1
	Local cChave  := ""

	//------------------------------
	// Visualiza o Cadastro
	//------------------------------
	If cAliasCad == "TZ5"
		cChave := xFilial("TZ5",cCodFilial) + cCodModulo + cCodFormul

		cCadastro := OemToAnsi(STR0042) //"Cadastro da Fórmula"
	ElseIf cAliasCad == "TZ9"
		cChave := xFilial("TZ9",cCodFilial) + cCodIndic

		cCadastro := OemToAnsi(STR0043) //"Cadastro do Indicador Gráfico"
	EndIf

	dbSelectArea(cAliasCad)
	dbSetOrder(nIndice)
	If !dbSeek(cChave)
		Help(Nil, Nil, STR0013, Nil, STR0010, 1, 0) //"Atenção" ## "Não foi possível encontrar o cadastro."
		Return .F.
	Else
		If cAliasCad == "TZ5"
			//--- Executa a View
			NGIND5IN("TZ5", RecNo(), 2)
		ElseIf cAliasCad == "TZ9"
			// Declara as Variáveis PRIVATE
			NGIND007VR()

			//--- Executa a View
			FWExecView(cCadastro/*cTitulo*/, "NGIND007"/*cPrograma*/, MODEL_OPERATION_VIEW/*nOperation*/, /*oDlg*/, /*bCloseOnOk*/, ;
						/*bOk*/, /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/)
		EndIf
	EndIf

Return .T.
