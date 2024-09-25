#INCLUDE	"Protheus.ch"
#INCLUDE	"FWMVCDEF.CH"
#INCLUDE	"MNTA616.ch"

//---------------------------------------------------------------------
/*/ MNTA616
Cadastro complementar da Integração ExcelBr.

TABELAS:
TQF - Postos
TQI - Tanques
TQJ - Bombas
TR0 - Integração ExcelBr

@author Wagner Sobral de Lacerda
@since 30/01/2012

@return .T.
/*/
//---------------------------------------------------------------------
Function MNTA616()

	//------------------------------
	// Armazena as variáveis
	//------------------------------
	Local aNGBEGINPRM := NGBEGINPRM()

	Local oBrowse // Variável do Browse

	Private cCadastro := OemToAnsi(STR0001) // "Integração ExcelBr"

	Private aVCpoTQF := {} // Variável de exceção de campos na View da TQF
	Private aVCpoTR0 := {} // Variável de exceção de campos na View da TR0

	// Variáveis Private utilizadas nas consultas SXB
	Private cPosto  := ""
	Private cLoja   := ""
	Private cTanque := ""

	//-------------------------------
	// Valida a execução do programa
	//-------------------------------
	If !MNTA616OP()
		Return .F.
	EndIf

	// Monta o array com a exceção de campos
	fCposExcep()

	//----------------
	// Monta o Browse
	//----------------
	dbSelectArea("TQF")
	dbSetOrder(1)
	dbGoTop()

	// Instanciamento da Classe de Browse
	oBrowse := FWMBrowse():New()

		// Definição da tabela do Browse
		oBrowse:SetAlias("TQF")

		// Descrição do Browse
		oBrowse:SetDescription(cCadastro)

		// Menu Funcional relacionado ao Browse
		oBrowse:SetMenuDef("MNTA616")

	// Ativação da Classe
	oBrowse:Activate()
	//----------------
	// Fim do Browse
	//----------------

	//------------------------------
	// Devolve as variáveis armazenadas
	//------------------------------
	NGRETURNPRM(aNGBEGINPRM)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do Menu (padrão MVC).

@author Wagner Sobral de Lacerda
@since 30/01/2012

@return aRotina array com o Menu MVC
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	// Variável do Menu
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.MNTA616" OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.MNTA616" OPERATION 4 ACCESS 0 // "Conversão DE/PARA"
	ADD OPTION aRotina TITLE STR0004 ACTION "MNTA616EXT" OPERATION 4 ACCESS 0 // "Informações Extras"

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA616OP
Valida o programa, verificando se é possível executá-lo. (MNTA616Open)
* Está função pode ser utilizada por outras rotinas.

@author Wagner Sobral de Lacerda
@since 30/01/2012

@return .T. caso o programa possa ser executado; .F. no caso de uma falha e o programa não puder ser executado
/*/
//---------------------------------------------------------------------
Function MNTA616OP()

	Local aTables := {}

	Local lParam  := ( SuperGetMv("MV_NGDPST9",.F.,"0") == "2" )
	Local cMotTra := AllTrim(SuperGetMv("MV_NGMOTTR"))

	Private lHelp := .F. // Variável private para o função 'FWAliasInDic()' mostrar (.T.) ou nao (.F.) uma mensagem de Help caso a tabela nao exista

	DbSelectArea("TTX")
	DbSetOrder(01)
	If !DbSeek(xFilial("TTX")+(cMotTra))
		MsgInfo(STR0022+CRLF+CRLF+STR0023) //"Não existe cadastrado um registro de Motivo de Transferência igual ao definido no parametro MV_NGMOTTR (Código do Motivo de Transferências de Combustível)."##"Configure corretamente o parâmetro para continuar."
		Return .F.
	EndIf

	If !lParam
		MsgInfo(STR0024) //"Para o correto funcionamento do processo ExcelBr, o parâmetro MV_NGDPST9 que indica se podera duplicar código do Bem deve estar configurado com o valor 2(Por Filial)."
		Return .F.
	EndIf

	// Verifica se o compartilhamento dessas tabelas (TQF e TR0) estão iguais.
	aTables := {"TQF", "TQI", "TQJ", "TR0"}
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

	//Exceção de campos na View da tabela TR0
	aVCpoTQF := {}

	//Exceção de campos na View da tabela TR0
	aVCpoTR0 := {}

	aAdd(aVCpoTR0, "TR0_FILIAL")
	aAdd(aVCpoTR0, "TR0_CODPOS")
	aAdd(aVCpoTR0, "TR0_LOJPOS")

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
@since 30/01/2012

@return oModel objeto do Modelo MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruTQF := FWFormStruct(1, "TQF", /*bAvalCampo*/, /*lViewUsado*/)
	Local oStruTR0 := FWFormStruct(1, "TR0", /*bAvalCampo*/, /*lViewUsado*/)

	// Modelo de dados que será construído
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("MNTA616", /*bPreValid*/, /*bPosValid*/, /*bFormCommit*/, /*bFormCancel*/)

		//--------------------------------------------------
		// Componentes do Modelo
		//--------------------------------------------------

		// Adiciona ao modelo um componente de Formulário Principal
		oModel:AddFields("TQFMASTER"/*cID*/, /*cIDOwner*/, oStruTQF/*oModelStruct*/, /*bPre*/, /*bPost*/, /*bLoad*/) // Cadastro do Posto

		// Adiciona ao modelo um componente de Grid, com o "TQFMASTER" como Owner
		oModel:AddGrid("TR0TERMINAL"/*cID*/, "TQFMASTER"/*cIDOwner*/, oStruTR0/*oModelStruct*/, /*bLinePre*/, {|oModelGrid| fMLinTermi(oModelGrid) }/*bLinePost*/, /*bPre*/, {|oModelGrid| fMAllTermi(oModelGrid) }/*bPost*/, /*bLoad*/) // Relação Terminal x Bomba

			// Define a Relação do modelo do Terminal com o Principal (Postos)
			oModel:SetRelation("TR0TERMINAL"/*cIDGrid*/,;
								{ {"TR0_FILIAL", 'xFilial("TR0")'}, {"TR0_CODPOS", "TQF_CODIGO"}, {"TR0_LOJPOS", "TQF_LOJA"} }/*aConteudo*/,;
								TR0->( IndexKey(1) )/*cIndexOrd*/)

		// Adiciona a descrição do Modelo de Dados (Geral)
		oModel:SetDescription(STR0001/*cDescricao*/) // "Integração ExcelBr"

			//--------------------------------------------------
			// Definições do Modelo do Posto
			//--------------------------------------------------

			// Adiciona a descrição do Modelo de Dados TQF
			oModel:GetModel("TQFMASTER"):SetDescription("Posto"/*cDescricao*/)

				// Define que o modelo não será atualizado / gravado
				oModel:GetModel("TQFMASTER"):SetOnlyQuery(.T.)

				// Define que o Modelo é somente de visualização
				oModel:GetModel("TQFMASTER"):SetOnlyView(.T.)

			//--------------------------------------------------
			// Definições do Modelo do Terminal X Bomba
			//--------------------------------------------------

			// Adiciona a descrição do Modelo de Dados TR0
			oModel:GetModel("TR0TERMINAL"):SetDescription(STR0005/*cDescricao*/) // "Relação Terminal x Bomba"

				// Altera as propriedades do Modelo
				oStruTR0:SetProperty("*", MODEL_FIELD_WHEN, {|oModel, cCampo, xValue, nLine| fLoadVars(oModel, cCampo, xValue, nLine) })

				// Define que o Modelo não é obrigatório
				oModel:GetModel("TR0TERMINAL"):SetOptional(.T.)

				// Define qual a chave única por Linha no browse
				oModel:GetModel("TR0TERMINAL"):SetUniqueLine({"TR0_TERMIN", "TR0_BOMPOS"})

		//------------------------------
		// Definição de When dos Campos Empresa e Filial
		//------------------------------
		//oModel:AddRules( 'TR0TERMINAL', 'TR0_BOMPOS', 'TR0TERMINAL', 'TR0_TANPOS', 3 )

Return oModel

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
@since 30/01/2012

@return oView objeto da View MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oModel := FWLoadModel("MNTA616")

	// Cria a estrutura a ser usada na View
	Local oStruTQF := FWFormStruct(2, "TQF", {|cCampo| fStructCpo(cCampo, "TQF") }/*bAvalCampo*/, /*lViewUsado*/)
	Local oStruTR0 := FWFormStruct(2, "TR0", {|cCampo| fStructCpo(cCampo, "TR0") }/*bAvalCampo*/, /*lViewUsado*/)

	// Interface de visualização construída
	Local oView

	// Cria o objeto de View
	oView := FWFormView():New()

		// Define qual o Modelo de dados será utilizado na View
		oView:SetModel(oModel)

		//--------------------------------------------------
		// Componentes da View
		//--------------------------------------------------

		// Adiciona no View um controle do tipo formulário (antiga Enchoice)
		oView:AddField("VIEW_TQFMASTER"/*cFormModelID*/, oStruTQF/*oViewStruct*/, "TQFMASTER"/*cLinkID*/, /*bValid*/)

		// Adiciona no View um controle do tipo Grid (antiga Getdados)
		oView:AddGrid("VIEW_TR0TERMINAL"/*cFormModelID*/, oStruTR0/*oViewStruct*/, "TR0TERMINAL"/*cLinkID*/, /*bValid*/)

		// Cria os componentes "box" horizontais para receberem elementos da View
		oView:CreateHorizontalBox("BOX_POSTO"  /*cID*/, 040/*nPercHeight*/, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)
		oView:CreateHorizontalBox("BOX_EXCELBR"/*cID*/, 060/*nPercHeight*/, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)

		// Relaciona o identificador (ID) da View com o "box" para exibição
		oView:SetOwnerView("VIEW_TQFMASTER"  /*cFormModelID*/, "BOX_POSTO"/*cIDUserView*/)
		oView:SetOwnerView("VIEW_TR0TERMINAL"/*cFormModelID*/, "BOX_EXCELBR"/*cIDUserView*/)

			// Define os Títulos das Views
			oView:EnableTitleView("VIEW_TQFMASTER"  , /*cTitle*/, /*nColor*/)
			oView:EnableTitleView("VIEW_TR0TERMINAL", /*cTitle*/, /*nColor*/)

		//--------------------------------------------------
		// Definições finais da View
		//--------------------------------------------------

		// Retira da estrutura da View os campos de relação com o Pai ('SetRelation()')
		oStruTR0:RemoveField("TR0_FILIAL")
		oStruTR0:RemoveField("TR0_CODPOS")
		oStruTR0:RemoveField("TR0_LOJPOS")

		// Ações de Pós-Validação dos Campos da View
		oView:SetFieldAction("TR0_TANPOS"/*cIDField*/, {|oView, cIDView, cField, xValue| fFieldAction(oView, cIDView, cField, xValue) }/*bAction*/)
		oView:SetFieldAction("TR0_BOMPOS"/*cIDField*/, {|oView, cIDView, cField, xValue| fFieldAction(oView, cIDView, cField, xValue) }/*bAction*/)

		// Define se pode inicializar a View
		oView:SetViewCanActivate({|| fVActivate() })

		//Inclusão de itens nas Ações Relacionadas de acordo com O NGRightClick
		NGMVCUserBtn(oView)

Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} fFieldAction
Define uma ação a ser executada quando um campo é Alterado/Validado
com sucesso.

@author Wagner Sobral de Lacerda
@since 29/02/2012

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

	Local oModelTR0 := oView:GetModel("TR0TERMINAL")

	If cField == "TR0_TANPOS"
		oModelTR0:LoadValue('TR0_BOMPOS',Space(TAMSX3("TR0_BOMPOS")[1]))
		oModelTR0:LoadValue('TR0_TERMIN',Space(TAMSX3("TR0_TERMIN")[1]))
	ElseIf cField == "TR0_BOMPOS"
		oModelTR0:LoadValue('TR0_TERMIN',Space(TAMSX3("TR0_TERMIN")[1]))
	EndIf

	oView:Refresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fStructCpo
Valida os campos da estrutura do Modelo ou View.

@author Wagner Sobral de Lacerda
@since 30/01/2012

@param cCampo
	Campo atual sendo verificado na estrutura * Obrigatório
@param cEstrutura
	Tabela da estrutura sendo carregada * Obrigatório

@return .T. caso o campo seja valido; .F. se nao for valido
/*/
//---------------------------------------------------------------------
Static Function fStructCpo(cCampo, cEstrutura)

	Local aExcecao := {}

	// Recebe os campos de exceção
	If cEstrutura == "TQF"
		aExcecao := aClone( aVCpoTQF )
	ElseIf cEstrutura == "TR0"
		aExcecao := aClone( aVCpoTR0 )
	EndIf

	// Valida o Campo
	If aScan(aExcecao, {|x| AllTrim(x) == AllTrim(cCampo) }) > 0
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fLoadVars
Carrega as Variáveis Private da rotina.

@author Wagner Sobral de Lacerda
@since 31/01/2012

@param oModelGrid
	Objeto do Grid * Opcional
	Default: Nil

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fLoadVars(oModelGrid, cCampo, xValue, nLine)

	Default oModelGrid := Nil

	// Carrega as variáveis padrões da rotina
	cPosto  := TQF->TQF_CODIGO
	cLoja   := TQF->TQF_LOJA
	cTanque := ""

	// Carrega as variáveis do Grid
	If ValType(oModelGrid) == "O"
		If oModelGrid:GetID() == "TR0TERMINAL"
			If oModelGrid:GetLine() > 0
				cTanque := oModelGrid:GetValue("TR0_TANPOS")
			EndIf
		EndIf
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
/*/{Protheus.doc} fVActivate
Valida se pode ativar a View.
-> Se puder, já carrega as variáveis necessárias.

@author Wagner Sobral de Lacerda
@since 30/01/2012

@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fVActivate()

	// Carrega Variáveis
	fLoadVars()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fMLinTermi
Pós-validação da Linha do browse de Terminal X Bomba.

@author Wagner Sobral de Lacerda
@since 30/01/2012

@param oModelGrid
	Objeto do modelo de dados do browse * Obrigatório

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fMLinTermi(oModelGrid)

	Local aAreaTR0   := TR0->( GetArea() )
	Local aSaveLines := FWSaveRows()

	Local oModelTR0 := oModelGrid

	Local cTitBOMPOS := ""
	Local cTitTERMIN := ""

	Local cLinTanque := ""
	Local cLinBomba  := ""
	Local cLinTermin := ""

	Local cMsgErro  := ""
	Local nQtdPosto := 0
	Local nQtdDiff  := 0

	Local lRetorno := .T.

	//--------------------
	// Valida a Linha
	//--------------------
	If !oModelTR0:IsDeleted() .And. (oModelTR0:IsInserted() .Or. oModelTR0:IsUpdated())
		// Busca o título dos campos para a mensagem em tela
		dbSelectArea("SX3")
		dbSetOrder(2)
		If dbSeek("TR0_BOMPOS")
			cTitBOMPOS := AllTrim( X3Titulo() )
		EndIf
		If dbSeek("TR0_TERMIN")
			cTitTERMIN := AllTrim( X3Titulo() )
		EndIf

		// Recebe os valores da linha
		cLinTanque := oModelTR0:GetValue("TR0_TANPOS")
		cLinBomba  := oModelTR0:GetValue("TR0_BOMPOS")
		cLinTermin := oModelTR0:GetValue("TR0_TERMIN")

		// Valida o tanque
		If lRetorno
			If !MNTA616TAN(2, cLinTanque)
				lRetorno := .F.
			EndIf
		EndIf

		// Valida a bomba
		If lRetorno
			If !MNTA616BOM(2, cLinBomba)
				lRetorno := .F.
			EndIf
		EndIf

		// Verifica duplicidade de registros na base
		If lRetorno
			If oModelTR0:IsInserted() .Or. oModelTR0:IsUpdated()
				dbSelectArea("TR0")
				dbSetOrder(1)
				dbSeek(xFilial("TR0") + cLinTermin + cLinBomba, .T.)
				While !Eof() .And. TR0->TR0_FILIAL == xFilial("TR0") .And. TR0->TR0_TERMIN == cLinTermin .And. TR0->TR0_BOMPOS == cLinBomba

					If TR0->TR0_CODPOS == M->TQF_CODIGO
						nQtdPosto++
					Else
						nQtdDiff++
					EndIf

					dbSelectArea("TR0")
					dbSkip()
				End

				If Empty(cMsgErro)
					// Se for um linha nova, não pode haver nenhum registro igual
					If oModelTR0:IsInserted()
						lRetorno := ( nQtdPosto == 0 .And. nQtdDiff == 0 )
					Else // Se for uma linha atualizada, só pode haver um registro igual E PARA O MESMO POSTO, caso contrário, está sendo duplicado
						lRetorno := ( nQtdPosto <= 1 .And. nQtdDiff == 0 )
					EndIf
				EndIf

				// Mostra a Mensagem de Erro
				If !lRetorno
					Help(" ", 1, STR0006, Nil,STR0007 + CRLF + cTitBOMPOS+": '" + cLinBomba + "'" + CRLF + cTitTERMIN+": '" + cLinTermin + "'",1, 0)
					lRetorno := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aAreaTR0)
	FWRestRows(aSaveLines)

Return lRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} fMAllTermi
Pós-validação da 'TudoOK' do browse de Terminal X Bomba.

@author Wagner Sobral de Lacerda
@since 30/01/2012

@param oModelGrid
	Objeto do modelo de dados do browse * Obrigatório

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fMAllTermi(oModelGrid)

	Local aAreaTR0   := TR0->( GetArea() )
	Local aSaveLines := FWSaveRows()

	Local oModelTR0 := oModelGrid
	Local nQuantid  := oModelTR0:Length()
	Local nX := 0, nScan := 0
	Local aTerminal  := {} // Variável para armazenar os Terminais e as quantidades de Bombas para cada terminal
	Local cTerminal  := ""
	Local nMaxBombas := 9
	Local nPosTERMIN := 1 // Posição do Terminal no array 'aTerminal'
	Local nPosQUANTI := 2 // Posição da Quantidade de Bombas no array 'aTerminal'

	Local lRetorno := .T.

	//------------------------------
	// Valida todas as linhas
	//------------------------------
	If lRetorno
		If nQuantid > 0
			For nX := 1 To nQuantid
				If !lRetorno
					Exit
				EndIf

				oModelTR0:GoLine(nX)

				If !oModelTR0:IsDeleted()
					cTerminal := oModelTR0:GetValue("TR0_TERMIN")

					// Valida a Linha
					If !fMLinTermi(oModelTR0)
						lRetorno := .F.
					EndIf

					// Adiciona o Terminal para validação posterior
					nScan := aScan(aTerminal, {|x| x[nPosTERMIN] == cTerminal })
					If nScan == 0
						aAdd(aTerminal, {cTerminal, 1})
					Else
						aTerminal[nScan][nPosQUANTI]++
					EndIf
				EndIf
			Next nX
		EndIf
	EndIf

	//------------------------------
	// Valida a quantidade de Bombas por Terminal (cada terminal pode controlar no máximo 9 bombas)
	//------------------------------
	If lRetorno
		// Recebe os Terminais já cadastrados na base de dados (filtrando pelos informados em tela), e a quantidade de bombas relacionadas
		For nX := 1 To Len(aTerminal)
			dbSelectArea("TR0")
			dbSetOrder(1)
			dbSeek(xFilial("TR0") + aTerminal[nX][nPosTERMIN])
			While !Eof() .And. TR0->TR0_FILIAL == xFilial("TR0") .And. TR0->TR0_TERMIN == aTerminal[nX][nPosTERMIN]

				aTerminal[nX][nPosQUANTI]++

				dbSelectArea("TR0")
				dbSkip()
			End
		Next nX

		nScan := aScan(aTerminal, {|x| x[nPosQUANTI] > nMaxBombas })
		If nScan > 0
			Help(" ", 1, STR0006, Nil,; // "Atenção"
				STR0008 + " '" + AllTrim(aTerminal[nScan][nPosTERMIN]) + "'." + CRLF + ; // "Inconsistência para o Terminal"
				STR0009 + " " + cValToChar(nMaxBombas) + ".",; // "Quantidade máxima de bombas que cada terminal pode controlar:"
				1, 0)
			lRetorno := .F.
		EndIf
	EndIf

	RestArea(aAreaTR0)
	FWRestRows(aSaveLines)

Return lRetorno

/*/
############################################################################################
##                                                                                        ##
## FUNÇÕES UTILIZADAS NO DICIONÁRIO DE DADOS / MODELO DE DADOS                            ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA616TAN
Função para validar o Tanque do Posto.

@author Wagner Sobral de Lacerda
@since 30/01/2012

@param nTipo
	Indica se a validação é: * Obrigatório
	1 - Pela MEMÓRIA
	2 - Pelo parâmetro
@param cConteudo
	Conteúdo da coluna Tanque.

@return .T./.F.
/*/
//---------------------------------------------------------------------
Function MNTA616TAN(nTipo, cConteudo)

	Default nTipo := 1
	//Default cConteudo := ""

	// Receba o conteúdo do Tanque
	If nTipo == 1
		cTanque := M->TR0_TANPOS
	Else
		cTanque := cConteudo
	EndIf

	// Se for um Posto Interno
	If M->TQF_TIPPOS == "2"
		// Valida o conteúdo do Tanque
		If !ExistCpo("TQI", M->TQF_CODIGO + M->TQF_LOJA + cTanque, 1)
			Return .F.
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA616BOM
Função para validar a Bomba do Posto.

@author Wagner Sobral de Lacerda
@since 30/01/2012

@param nTipo
	Indica se a validação é: * Obrigatório
	1 - Pela MEMÓRIA
	2 - Pelo parâmetro
@param cConteudo
	Conteúdo da coluna Bomba.

@return .T./.F.
/*/
//---------------------------------------------------------------------
Function MNTA616BOM(nTipo, cConteudo)

	Local aBombas   := {"1", "2", "3", "4", "5", "6", "7", "8", "9"}
	Local cBomba    := ""
	Local cMsg      := ""
	Local nTamBomba := 1
	Local nX := 0

	Default nTipo := 1
	Default cConteudo := ""

	// Receba o conteúdo da Bomba
	If nTipo == 1
		cBomba := PadR(M->TR0_BOMPOS,TAMSX3("TR0_BOMPOS")[1])
	Else
		cBomba := PadR(cConteudo,TAMSX3("TR0_BOMPOS")[1])
	EndIf


	// Se for um Posto Interno
	If M->TQF_TIPPOS == "2"
		// Valida o conteúdo da Bomba
		If !ExistCpo("TQJ", PadR(M->TQF_CODIGO,TAMSX3("TQJ_CODPOS")[1]) + PadR(M->TQF_LOJA,TAMSX3("TQJ_LOJA")[1]) + PadR(cTanque,TAMSX3("TQJ_TANQUE")[1]) + cBomba, 1)
			Return .F.
		EndIf
	EndIf

	// Valida o tamanho (caractere) da Bomba de acordo com o sistema GTFrota
	If Len( AllTrim(cBomba) ) > nTamBomba
		cMsg := STR0010 + CRLF // "De acordo com o sistema GTFrota, a Bomba deve possuir apenas um dígito."

		Help(" ", 1, STR0006, Nil, cMsg, 1, 0) // "Atenção"
		Return .F.
	EndIf

	// Valida as bombas possíveis de acordo com o sitema GTFrota
	If aScan(aBombas, {|x| x == AllTrim(cBomba) }) == 0
		cMsg := STR0011 + " " + CRLF // "De acordo com o sistema GTFrota, as Bombas possíveis são:"
		For nX := 1 To Len(aBombas)
			cMsg += "'" + aBombas[nX] + "'"

			If nX < Len(aBombas)
				cMsg += ";"
			Else
				cMsg += "." + CRLF
			EndIf
		Next nX
			ShowHelpDlg(STR0006,{cMsg},1,;  //"Atenção"
					  {STR0020,""},1) //"Informe uma bomba válida."
		Return .F.
	EndIf

Return .T.

/*/
############################################################################################
##                                                                                        ##
## FUNÇÕES DAS INFORMAÇÕES EXTRAS                                                         ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA616EXT
Função para definir o conteúdo das Informações Extras.

@author Wagner Sobral de Lacerda
@since 05/06/2012

@return .T.
/*/
//---------------------------------------------------------------------
Function MNTA616EXT(nTipo, cConteudo)

	// Salva as áreas atuais
	Local aAreaSX3 := SX3->( GetArea() )
	Local aAreaTR0 := TR0->( GetArea() )

	// Variáveis da janela
	Local oDlgExtra
	Local cDlgExtra := OemToAnsi(STR0004) // "Informações Extras"
	Local lDlgExtra := .F.
	Local oPnlExtra

	Local oPnlMsg
	Local oPnlDef

	Local oTmpGroup
	Local oTmpCombo
	Local aExtras := {}
	Local nExtra := 0

	Private cTerminalE := ""
	Private cBombalE   := ""

	//--- Define array de informações extras
	dbSelectArea("SX3")
	dbSetOrder(2)
	dbSeek("TR0_EXTRA")
	aExtras := StrTokArr( AllTrim(X3CBox()), ";" )

	//--- Define coteúdo inicial
	// Terminal
	dbSelectArea("TR0")
	dbSetOrder(1) // Filial + Terminal + Bomba
	If dbSeek(xFilial("TR0") + "#")
		cTerminalE := TR0->TR0_EXTRA
	Else
		cTerminalE := SubStr(aExtras[1],1,1)
	EndIf
	// Bomba
	dbSelectArea("TR0")
	dbSetOrder(2) // Filial + Bomba + Terminal
	If dbSeek(xFilial("TR0") + "#")
		cBombaE    := TR0->TR0_EXTRA
	Else
		cBombaE    := SubStr(aExtras[1],1,1)
	EndIf

	//----------
	// Monta
	//----------
	DEFINE MSDIALOG oDlgExtra TITLE cDlgExtra FROM 0,0 TO 300,600 OF oMainWnd PIXEL

		// Painél principal do Dialog
		oPnlExtra := TPanel():New(01, 01, , oDlgExtra, , , , CLR_BLACK, CLR_WHITE, 100, 100)
		oPnlExtra:Align := CONTROL_ALIGN_ALLCLIENT

			// Painél da mensagem
			oPnlMsg := TPanel():New(01, 01, , oPnlExtra, , , , CLR_BLACK, CLR_WHITE, 100, 070)
			oPnlMsg:Align := CONTROL_ALIGN_TOP

				// Mensagem
				@ 010,015 SAY OemToAnsi(STR0012) COLOR CLR_GRAY OF oPnlMsg PIXEL // "Quando na importação de abastecimentos da ExcelBr via painél On-Line, são apresentadas 5 (cinco)"
				@ 020,005 SAY OemToAnsi(STR0013) COLOR CLR_GRAY OF oPnlMsg PIXEL // "informações extras para a digitação do usuário."
				@ 030,015 SAY OemToAnsi(STR0014) COLOR CLR_GRAY OF oPnlMsg PIXEL // "Para o Protheus, é necessário saber em quais destas informações o usuário digitou o Terminal e a"
				@ 040,005 SAY OemToAnsi(STR0015) COLOR CLR_GRAY OF oPnlMsg PIXEL // "Bomba do posto de destino na realização de uma Transferência de Combustível."
				@ 055,015 SAY OemToAnsi(STR0016) COLOR CLR_RED OF oPnlMsg PIXEL // "Favor informar a relação de Terminal e Bomba nas informações extras:"

			// Painél da definição da relação Terminal x Bomba com as Informações Extras
			oPnlDef := TPanel():New(01, 01, , oPnlExtra, , , , CLR_BLACK, CLR_WHITE, 100, 100)
			oPnlDef:Align := CONTROL_ALIGN_ALLCLIENT

				// Group Box
				oTmpGroup := TGroup():New(01, 01, 10, 10, STR0017, oPnlDef, , , .T.) // "Terminal x Bomba nas Informações Extras"
				oTmpGroup:Align := CONTROL_ALIGN_ALLCLIENT

				// Terminal Destino
				@ 025,010 SAY OemToAnsi(STR0018) COLOR CLR_HBLUE OF oPnlDef PIXEL // "Terminal de Destino é representado pela coluna:"
				oTmpCombo := TComboBox():New(024, 135, {|u| If(PCount() > 0, cTerminalE := u, cTerminalE) }, aExtras, 080, 008, oPnlDef, , /*bChange*/, /*bValid*/, , , .T./*lPixel*/, , , , {|| .T. }/*bWhen*/)
				oTmpCombo:bHelp := {|| Help("TR0_TERMIN") }

				// Bomba Destino
				@ 040,010 SAY OemToAnsi(STR0019) COLOR CLR_HBLUE OF oPnlDef PIXEL // "Bomba de Destino é representado pela coluna:"
				oTmpCombo := TComboBox():New(039, 135, {|u| If(PCount() > 0, cBombaE := u, cBombaE) }, aExtras, 080, 008, oPnlDef, , /*bChange*/, /*bValid*/, , , .T./*lPixel*/, , , , {|| .T. }/*bWhen*/)
				oTmpCombo:bHelp := {|| Help("TR0_BOMPOS") }

	ACTIVATE MSDIALOG oDlgExtra ON INIT EnchoiceBar(oDlgExtra, {|| lDlgExtra := .T., oDlgExtra:End() }, {|| lDlgExtra := .F., oDlgExtra:End() }) CENTERED

	// Se confirmou
	If lDlgExtra
		//--- Grava a posição do Terminal
		dbSelectArea("TR0")
		dbSetOrder(1) // Filial + Terminal + Bomba
		If !dbSeek(xFilial("TR0") + "#")
			RecLock("TR0", .T.)
			TR0->TR0_FILIAL := xFilial("TR0")
			TR0->TR0_CODPOS := ""
			TR0->TR0_LOJPOS := ""
			TR0->TR0_TANPOS := ""
			TR0->TR0_BOMPOS := ""
			TR0->TR0_TERMIN := "#"
		Else
			RecLock("TR0", .F.)
		EndIf
		TR0->TR0_EXTRA := cTerminalE // Campo utilizada para indicar a Informação Extra
		MsUnlock("TR0")

		//--- Grava a posição da Bomba
		dbSelectArea("TR0")
		dbSetOrder(2) // Filial + Bomba + Terminal
		If !dbSeek(xFilial("TR0") + "#")
			RecLock("TR0", .T.)
			TR0->TR0_FILIAL := xFilial("TR0")
			TR0->TR0_CODPOS := ""
			TR0->TR0_LOJPOS := ""
			TR0->TR0_TANPOS := ""
			TR0->TR0_BOMPOS := "#"
			TR0->TR0_TERMIN := ""
		Else
			RecLock("TR0", .F.)
		EndIf
		TR0->TR0_EXTRA := cBombaE // Campo utilizada para indicar a Informação Extra
		MsUnlock("TR0")
	EndIf

	//Devolve as áreas
	RestArea(aAreaSX3)
	RestArea(aAreaTR0)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT616FILXB
Função para definir o conteúdo das Informações Extras.

@author Wagner Sobral de Lacerda
@since 05/06/2012

@return
/*/
//---------------------------------------------------------------------
Function MNT616FILXB()
Local lRet := .F.

cTanque := PadR(cTanque	,TAMSX3("TQJ_TANQUE")[1])
cPOSTO 	:= PadR(TQF->TQF_CODIGO	,TAMSX3("TQJ_CODPOS")[1])
cLOJA 	:= PadR(TQF->TQF_LOJA	,TAMSX3("TQJ_LOJA")[1])

lRet := TQJ->TQJ_CODPOS == cPOSTO .AND. TQJ->TQJ_LOJA == cLOJA .AND. TQJ->TQJ_TANQUE == cTANQUE
If lRet
	If  IsInCallStack( "MNTA616" )
		lRet := AllTrim( TQJ->TQJ_BOMBA ) $ "1/2/3/4/5/6/7/8/9"
	Else
		lRet := .T.
	EndIf
EndIf

Return lRet
