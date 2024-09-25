#INCLUDE	"Protheus.ch"
#INCLUDE	"TNGPanel.ch"
#INCLUDE	"FWBrowse.ch"

//--------------------------------------------------
// Modos de Ação sobre a Classe
//--------------------------------------------------
#DEFINE		_nModeQry	01	// Modo de CONSULTA
#DEFINE		_nModeEdt	02	// Modo de EDIÇÃO

//--------------------------------------------------
// Posições das Informações do Painel (Array: 'aInfo')
//--------------------------------------------------
Static		__nInfFili		:= 1  // Posição da informação 'Filial'
Static		__nInfCodi		:= 2  // Posição da informação 'Código do Painel'
Static		__nInfNome		:= 3  // Posição da informação 'Nome do Painel'
Static		__nInfUsCd		:= 4  // Posição da informação 'Còdigo do Usuário'
Static		__nInfUsNo		:= 5  // Posição da informação 'Nome do Usuário'
Static		__nInfMdCd		:= 6  // Posição da informação 'Módulo do Painel'
Static		__nInfMdNo		:= 7  // Posição da informação 'Nome do Módulo'
Static		__nInfAtiv		:= 8  // Posição da informação 'Painel Ativo?'
Static		__nInfQtde		:= 8 // Quantidade de Informações

//--------------------------------------------------
// Posições dos Classificações & Indicadores (Array: 'aClassInds')
//--------------------------------------------------
Static		__nCInClas		:= 1 // Posição da 'Classificação'
Static		__nCInNome		:= 2 // Posição do 'Nome da Classificação'
Static		__nCInInds		:= 3 // Posição dos 'Indicadores da Classificação'
Static		__nCInQtde		:= 3 // Quantidade de Itens
Static		__nCInFoCd		:= 1 // Posição do 'Código da Fórmula do Indicador'
Static		__nCInFoNo		:= 2 // Posição do 'Nome da Fórmula do Indicador'

//--------------------------------------------------
// Posições dos Indicadores (Array: 'aIndDef')
//--------------------------------------------------
Static		__nIndForm		:= 1 // Posição do 'Código da F´rmula'
Static		__nIndPnl1		:= 2 // Posição do 'Painel Pai do Indicador'
Static		__nIndTopo		:= 3 // Posição do 'Painel da Borda Topo'
Static		__nIndEsqu		:= 4 // Posição do 'Painel da Borda Esquerda'
Static		__nIndDire		:= 5 // Posição do 'Painel da Borda Direita'
Static		__nIndBaix		:= 6 // Posição do 'Painel da Borda Baixo'
Static		__nIndTitu		:= 7 // Posição do 'Painel do Título'
Static		__nIndPnl2		:= 8 // Posição do 'Painel do Indicador Gráfico'
Static		__nIndGraf		:= 9 // Posição do 'Indicador Gráfico'
Static		__nIndValu		:= 10 // Posição do 'Valor do Indicador'
Static		__nIndQtde		:= 10 // Quantidade de Objetos

//--------------------------------------------------
// Posições das Configurações (Array: 'aConfig')
//--------------------------------------------------
Static		__nCfgTPnl		:= 1 // Posição do 'Título do Painel'
Static		__nCfgTInd		:= 2 // Posição do 'Título dos Indicadores'
Static		__nCfgTota		:= 3 // Posição do 'Totalizadores'
Static		__nCfgThem		:= 4 // Posição da 'Tema'
Static		__nCfgLast		:= 5 // Posição do 'Último Valor'
Static		__nCfgCalc		:= 6 // Posição do 'Cálculo'
Static		__nCfgAnim		:= 7 // Posição do 'Animação'
Static		__nCfgInds		:= 8 // Posição dos 'Indicadores'
Static		__nCfgPars		:= 9 // Posição dos 'Parâmetros'
Static		__nCfgLoad		:= 10 // Posição dos 'Loaded' (dados do indicador carregado para o usuário, de acordo com a rotina)
Static		__nCfgInte		:= 11 // Posição d 'Interface' (tipo de Interface carregado - 1=Gráfica;2=Lista)
Static		__nCfgQtde		:= 11 // Quantidade de Itens

//--------------------------------------------------
// Posições dos Parâmetors (Array: 'aParams')
//--------------------------------------------------
Static		__nParOrde		:= 1 // Posição da 'Ordem'
Static		__nParCodi		:= 2 // Posição do 'Código do Parâmetro'
Static		__nParDesc		:= 3 // Posição da 'Descrição do Parâmetro'
Static		__nParTipo		:= 4 // Posição do 'Tipo do Parâmetro'
Static		__nParTama		:= 5 // Posição do 'Tamanho'
Static		__nParDeci		:= 6 // Posição da 'Decimal'
Static		__nParPict		:= 7 // Posição da 'Formato (Picture)'
Static		__nParTabe		:= 8 // Posição da 'Tabela'
Static		__nParCamp		:= 9 // Posição da 'Campo'
Static		__nParCons		:= 10 // Posição da 'Consulta Padrão'
Static		__nParOpcs		:= 11 // Posição da 'Lista de Opções'
Static		__nParCont		:= 12 // Posição do 'Conteúdo do Parâmetro'
Static		__nParQtde		:= 12 // Quantidade de Itens
Static      __nParObri      := 13 // Posição do "Obrigatoriedade"

//--------------------------------------------------
// Posições dos Parâmetors (Array: 'aSpaceBtn')
//--------------------------------------------------
Static		__nSpcDCfg		:= 1 // Posição da 'Direita - Configurações'
Static		__nSpcDMor		:= 2 // Posição da 'Direita - Mais Opções'
Static		__nSpcDSlc		:= 3 // Posição da 'Direita - Selecionar Indicadores'
Static		__nSpcDCal		:= 4 // Posição da 'Direita - Calcular'
Static		__nSpcDChg		:= 5 // Posição da 'Direita - Modo Gráfico/Lista'
Static		__nSpcQtde		:= 5 // Quantidade de Itens

//--------------------------------------------------
// Posições dos Blocos de Código (Array: 'aCodeBlock')
//--------------------------------------------------
Static		__nBSetPnl		:= 1 // Posição do Bloco para 'Set Panel (definir) o Painel de Indicadores'
Static		__nBLoaFrm		:= 2 // Posição do Bloco para 'Load Formula (carrega fórmula) do Indicador que está sendo carregado para o Painel'
Static		__nBSlcCha		:= 3 // Posição do Bloco para 'Charge (carga) do browse de Seleção de Indicadores'
Static		__nBSlcChg		:= 4 // Posição do Bloco para 'Change (mudança de linha) do browse de Seleção de Indicadores'
Static		__nBSlcViw		:= 5 // Posição do Bloco para 'View (visualização) do browse de Seleção de Indicadores'
Static		__nBMakCad		:= 6 // Posição do Bloco para 'Make Cad (criar cadastro) do Painel de Indicadores'
Static		__nBSavPnl		:= 7 // Posição do Bloco para 'Save Panel (salvar) o Painel de Indicadores'
Static		__nBLoaPnl		:= 8 // Posição do Bloco para 'Load Panel (carregar) o Painel de Indicadores'
Static		__nBDelPnl		:= 9 // Posição do Bloco para 'Delete Panel (deletar) o Painel de Indicadores'
Static		__nBConPnl		:= 10 // Posição do Bloco para 'Consultas os Painéis de Indicadores cadastrados no sistema'
Static		__nBCusPnl		:= 11 // Posição do Bloco para 'Customizações (configurações)' do Painel de Indicadores
Static		__nBActPnl		:= 12 // Posição do Bloco para 'Ativação da Classe' do Painel de Indicadores
Static		__nBEndPnl		:= 13 // Posição do Bloco para 'Finalização do Painel' (bloco de código quando o Painel está criado)
Static		__nBIndFld		:= 14 // Posição do Bloco para 'Campos do Indicador Gráfico'
Static		__nBIndInf		:= 15 // Posição do Bloco para 'Informações do Indicador Gráfico' (clique da direito no indicador)
Static		__nBIndDet		:= 16 // Posição do Bloco para 'Detalhes do Indicador Gráfico' (clique da direito no indicador)
Static		__nBIndLeg		:= 17 // Posição do Bloco para 'Legenda do Indicador Gráfico' (clique da direito no indicador)
Static		__nBQtde		:= 17 // Quantidade de Itens

//--------------------------------------------------
// Posições dos Campos das Informações (Array: 'aFieldInfo')
//--------------------------------------------------
Static		__nFldTitl		:= 1 // Posição do 'Título' do campo
Static		__nFldType		:= 2 // Posição do 'Tipo' do campo
Static		__nFldSize		:= 3 // Posição do 'Tamanho' do campo
Static		__nFldDeci		:= 4 // Posição do 'Decimal' do campo
Static		__nFldPict		:= 5 // Posição da 'Picture' do campo
Static		__nFldComb		:= 6 // Posição do 'ComboBox' do campo
Static		__nFldObli		:= 7 // Posição do 'Obrigatório' do campo
Static		__nFldIDCp		:= 8 // Posição do 'ID' do campo (para help)
Static		__nFldHelp		:= 9 // Posição do 'Help' do campo

//---------------------------------------------------------------------
/*/{Protheus.doc} TNGPanel
Classe para o controle do Painel de Indicadores.

@author Wagner Sobral de Lacerda
@since 30/04/2012

@return Self Objeto do Painel de Indicadores
/*/
//---------------------------------------------------------------------
Class TNGPanel From TPanel

	//--------------------------------------------------
	// ATRIBUTOS
	//--------------------------------------------------
	// Arrays
	DATA	aInfo		AS	ARRAY	INIT	{} // Array contendo as Informações do cadastro do Painel
	DATA	aFieldInfo	AS	ARRAY	INIT	{} // Array contendo os Tamahos (Tamanho + Deimal) para as Informações do cadastro do Painel

	DATA	aClassInds	AS	ARRAY	INIT	{} // Array contendo as Classificações dos Indicadores do Painel
	DATA	aIndDef		AS	ARRAY	INIT	{} // Array contendo as Definições dos Indicadores do Painel
	DATA	aLists		AS	ARRAY	INIT	{} // Array contendo os Browses para o Modo Lista

	DATA	aOtherInds	AS	ARRAY	INIT	{} // Array contendo Indicadores específicos a serem montados
	DATA	aConfig		AS	ARRAY	INIT	{} // Array contendo as Configurações Personalizadas do Painel
	DATA	aParams		AS	ARRAY	INIT	{} // Array contendo os Parâmetros (Perguntas) do Painel

	DATA	aShowCad	AS	ARRAY	INIT	{} // Array contendo os Objetos das Informações do Painel
	DATA	aOptions	AS	ARRAY	INIT	{} // Array contendo os Botões permitidos e não permitidos de "Mais Opções" no Painel

	DATA	aSpaceBtn	AS	ARRAY	INIT	{} // Array contendo os painéis auxiliares de espaço dos botões

	DATA	aCodeBlock	AS	ARRAY	INIT	{} // Array contendo os Blocos de Código do Painel de Indicadores

	// Strings
	DATA	cCodFilia	AS	STRING	INIT	"" // Filial do Painel de Indicadores
	DATA	cCodModul	AS	STRING	INIT	"" // Código do Módulo do Painel de Indicadores
	DATA	cCodPanel	AS	STRING	INIT	"" // Código do Painel de Indicadores

	DATA	cFldOption	AS	STRING	INIT	"" // Código da Classificação selecionada no Folder
	DATA	cLoadFunc	AS	STRING	INIT	"" // Nome da função executada (FunName())
	DATA	cLoadUser	AS	STRING	INIT	"" // Código do Usuário logado no sistema (RetCodUsr())

	// Booleanas
	DATA	lPanel		AS	BOOLEAN	INIT	.F. // Valor lógico que indica se o Painel de Indicadores está montado em tela
	DATA	lActivated	AS	BOOLEAN	INIT	.F. // Valor lógico que indica se o Painel de Indicadores está montado em tela

	DATA	lIsGraphic	AS	BOOLEAN	INIT	.T. // Valor lógico que indica se a apresentação do Painel está no modo "Indicadores Gráficos"
	DATA	lIsList		AS	BOOLEAN	INIT	.F. // Valor lógico que indica se a apresentação do Painel está no modo "Lista"

	DATA	lCanConfig	AS	BOOLEAN	INIT	.T. // Valor lógico que indica se o usuário pode utilizar a Configurações do Painel
	DATA	lCanSelect	AS	BOOLEAN	INIT	.F. // Valor lógico que indica se o usuário pode selecionar os Indicadores do Painel
	DATA	lCanWait	AS	BOOLEAN	INIT	.F. // Valor lógico que indica se o Painel de Espera pode ser visualizado

	DATA	lFixedCad	AS	BOOLEAN	INIT	.F. // Valor lógico que indica se o Painel de Informações do Cadastro está fixado no Painel de Indicadores

	DATA	lEnabled	AS	BOOLEAN	INIT	.F. // Valor lógico que indica se o Painel de Informações está habilitado para manipulação

	// Numéricas
	DATA	nMode		AS	BOOLEAN	INIT	1 // Modo de Ação sobre o Painel de Indicadores

	DATA	nSizeTitBar	AS	BOOLEAN	INIT	1 // Tamanho da Barra do Título
	DATA	nSizeBtnBar	AS	BOOLEAN	INIT	1 // Tamanho da Barra dos Botões
	DATA	nSpacBtnBor	AS	BOOLEAN	INIT	1 // Espaço dado entre o Botão e a Borda de onde estiver
	DATA	nSpacBtnBtn	AS	BOOLEAN	INIT	1 // Espaço dado entre os Botões

	// Objetos
	DATA	oDlgOwner	AS	OBJECT // Dialog Pai dos Objetos
	DATA	oBlackPnl	AS	OBJECT // Painel Preto (meio Transparente)

	DATA	oWaitPnl	AS	OBJECT // Objeto do Painel em Espera (para adicionar um Painel de Indicadores)
	DATA	oWaitAdd	AS	OBJECT // Objeto do Botão de Configurações

	DATA	oMainPnl	AS	OBJECT // Objeto do Painel Principal (Container para os Indicadores)
	DATA	oPanelInd	AS	OBJECT // Objeto do Painel de Indicadores
	DATA	oSplitFoot	AS	OBJECT // Objeto do Splitter entre o Painel de Indicadores e seu Rodapé

	DATA	oTitlePnl	AS	OBJECT // Objeto do Painel com as Informações sobre o Painel de Indicadores
	DATA	oCadPnl		AS	OBJECT // Objeto do Cadastro do Painel de Indicadores
	DATA	oCadTitle	AS	OBJECT // Objeto do Cadastro do Painel de Indicadores
	DATA	oMessPnl	AS	OBJECT // Objeto do Painel com as Mensagens do Painel de Indicadores
	DATA	oTotalPnl	AS	OBJECT // Objeto do Painel com os Totalizadores

	DATA	oFooter		AS	OBJECT // Objeto do Rodapé do Painel de Indicadores montado
	DATA	oFootAtu	AS	OBJECT // Objeto do Botão de Atualização
	DATA	oFootChg	AS	OBJECT // Objeto do Botão de Alterar o modo de Apresentação/Visualização dos Indicadores
	DATA	oFootCal	AS	OBJECT // Objeto do Botão de Calcular
	DATA	oFootCfg	AS	OBJECT // Objeto do Botão de Configurações
	DATA	oFootSlc	AS	OBJECT // Objeto do Botão de Seleção de Indicadores
	DATA	oFootMor	AS	OBJECT // Objeto do Botão de Mais Opções
		DATA	oMorMenu	AS	OBJECT // Objeto do Menu do Botão de Opções

	//--------------------------------------------------
	// MÉTODOS
	//--------------------------------------------------
	Method New(oParent, cSetPanel, cSetFilial, cSetModulo, nSetMode) CONSTRUCTOR // Método Construtor da Classe
	Method Activate() // Método de Ativação de Classe
	Method DeActivate() // Método de Desativação de Classe

	Method SplitFoot() // Executa um Split entre o Painel de Indicadores e o Rodapé
	Method Refresh() // Atualiza o Painel de Indicadores

	//----------
	// Setters
	//----------
	Method SetPanel(cSetPanel, cSetFilial, cSetModulo, aSetEspInds) // Seta o Painel de Indicadores
	Method SetEspInds(aSetEspInds) // Seta os Indicadores Específicos a serem montados
	Method SetParams(aSetParams) // Seta os ParÂmetros do Painel
	Method SetMode(nSetMode) // Seta o Modo de Ação sobre o Painel de Indicadores
	Method SetOptions(aOptions, aNoOptions) // Seta as Opções disponíveis no botão de "Mais Opções" no Painel

	Method SetGraphic(lRefresh) // Seta a Apresentação em modo "Indicadores Gráficos"
	Method SetList(lRefresh) // Seta a Apresentação em modo "Lista"

	Method SetFixedCad(lFixed) // Seta as Informações do Cadastro como Fixas no Painel, ou não
	Method SetTotal(nAmount, nTotal) // Seta os Totalizadores do Indicador
	Method SetCodeBlock(nCodeBlock, bCodeBlock) // Seta um Bloco de Código do Painel de Indicadores
	Method SetFldInfo(aSetFields) // Seta as especificações dos campos do array 'aInfo'
	Method SetInfo() // Seta as Informações do Painel de Indicadores 'aInfo'

	//----------
	// Getters
	//----------
	Method GetPanel() // Retorna o código Painel de Indicadores
	Method GetIndics(nType) // Retorna os Indicadores Específicos montados
	Method GetParams() // Retorna os ParÂmetros do Painel
	Method GetMode() // Retorna o Modo de Ação sobre o Painel de Indicadores
	Method GetOptions(nType) // Retorna as Opções disponíveis no botão de "Mais Opções" no Painel

	Method GetGraphic() // Retorna se a Apresentação está em modo "Indicadores Gráficos"
	Method GetList() // Retorna se a Apresentação está em modo "Lista"

	Method GetFixedCad() // Retorna se as Informações do Cadastro estão Fixas no Painel, ou não
	Method GetTotal() // Retorna o Totalizador atual
	Method GetCodeBlock(nCodeBlock) // Retorna um Bloco de Código do Painel de Indicadores
	Method GetFldInfo() // Retorna as especificações dos campos do array 'Info'
	Method GetInfo() // Retorna as Informações do Painel de Indicadores 'aInfo'

	//----------
	// Criação
	//----------
	Method Create() // Cria o Painel
	Method Blank() // Cria um Painel em Branco

	//----------
	// Configuração
	//----------
	Method Config() // Configura algumas opções de apresentação do Painel
	Method SaveConfig() // Salva as configurações do Painel
	Method LoadConfig() // Carrega as configurações do Painel

	Method Params() // Define os Parâmetros dos Indicadores do Painel (apresenta uma tela para o usuário definir os parÂmetros)
	Method Calculate(lMsgRun, lForceCalc) // Calcula os Indicadores
	Method Charge(nCharge) // Carrega os Valores nos Indicadores (com ou sem animação, dependendo da configuração do usuário)
	Method Print() // Imprime o Painel de Indicadores

	Method SelectPanel() // Seleciona um Painel de Indicadores

	//----------
	// Personalização
	//----------
	Method SelectInds() // Seleciona os Indicadores do Painel
	Method MakeCad(nOption) // Cria uma tela de Cadstro para o Painel de Indicadores

	Method SavePanel() // Salva o Painel de Indicadores
	Method LoadPanel(cCodPanel, cCodFilia, cCodModul) // Carrega o Painel de Indicadores
	Method DelPanel(cCodPanel, cCodFilia, cCodModul) // Deleta o Painel de Indicadores

	//----------
	// Validação
	//----------
	Method IsCreated() // Indica se o Painel está criado
	Method IsBlackPnl() // Indica se o Painel preto está visível
	Method IsMine() // Verifica se o Painel carregado é de autoria do usuário logado no sistema
	Method IsEnabled() // Indica se o Painel está habilitado para manipulaçaõ

	//----------
	// Outros
	//----------
	Method BlackPnl(lVisible) // Mostra/Esconde o Painel Preto (meio transparente)

	Method CanConfig(lCanConfig) // Define se pode ou não utilizar as Configurações do Painel de Indicadores
	Method CanSelect(lCanSelect) // Define se pode ou não selecionar os Indicadores que são apresentados no Painel de Indicadores
	Method CanWait(lCanWait) // Define se pode ou não visualizar o Painel de Espera
	Method CanOptions() // Define as opções de 'Mais Opções' que estão habilitadas

	Method ShowCad(nForceCad) // Mostra as Informações do Cadastro do Painel de Indicadores

	Method Enable() // Habilita a manipulação do Painel
	Method Disable() // Desabilita a manipulação do Painel

	//------------------------------
	// Liberação / Destruição
	//------------------------------
	Method ClearPanel() // Limpa o Painel
	Method Release() // Libera o Painel
	Method Reset() // Reinicializa o Painel em Branco

	Method Destroy() // Destrói o Painel de Indicadores

EndClass

/*/
############################################################################################
##                                                                                        ##
## MÉTODOS: GERAIS                                                                        ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} New
Método Construtor da classe TNGPanel.

@author Wagner Sobral de Lacerda
@since 06/10/2012

@param oParent
	Objeto Pai da classe * Opcional
	Default: Self:Owner() (método)
@param cSetPanel
	Código do Painel de Indicador para carregar * Opcional
	Default: ""
@param cSetFilial
	Código da Filial do Painel de Indicadores * Opcional
	Default: ""
@param cSetModulo
	Código do Módulo do Painel de Indicadores * Opcional
	Default: ""
@param nSetMode
	Código do Modo de Ação sobre o Painel * Opcional
	   1 - Consulta
	   2 - Edição
	Default: _nModeQry (1)

@return Self Objeto do Painel de Indicadores
/*/
//---------------------------------------------------------------------
Method New(oParent, cSetPanel, cSetFilial, cSetModulo, nSetMode) Class TNGPanel
	:New(0, 0, , oParent, , , , CLR_BLACK, CLR_WHITE, 0, 0, .F., .F.) //Inicializa o TPanel Pai da Classe

	// Variáveis auxiliares
	Local oTmpPnl
	Local oTmpBtn
	Local nSpcPnl

	Local oFntBoldPD := TFont():New(, , , , .T.)
	Local oFntBold18 := TFont():New(, , 18, , .T.)

	Local lEnvironme := ( Type("oApp") == "O" )

	// Defaults
	Default oParent    := ::Owner()
	Default cSetPanel  := ""
	Default cSetFilial := ""
	Default cSetModulo := ""
	Default nSetMode   := _nModeQry

	//--- Inicializa os Atributos da Classe
	// Arrays
	::aInfo      := {}
	::aFieldInfo := {}

	::aClassInds := {}
	::aIndDef    := {}
	::aLists     := {}

	::aOtherInds := {}
	::aConfig    := {}
	::aParams    := {}

	::aShowCad := { {}, {} }
	::aOptions := { {}, {} }

	::aSpaceBtn := {}

	::aCodeBlock := Array(__nBQtde)

	// Strings
	::cCodFilia := cSetFilial
	::cCodModul := cSetModulo
	::cCodPanel := cSetPanel

	::cFldOption := ""
	::cLoadFunc  := ""
	::cLoadUser  := ""

	// Booleanas
	::lPanel     := .F.
	::lActivated := .F.

	::lIsGraphic := .T.
	::lIsList    := .F.

	::lCanConfig := .T.
	::lCanSelect := .F.
	::lCanWait   := .F.

	::lFixedCad := .F.

	::lEnabled := .T.

	// Numéricas
	::nMode := nSetMode

	::nSizeTitBar := 012
	::nSizeBtnBar := 012
	::nSpacBtnBor := 005
	::nSpacBtnBtn := 010

	// Objetos
	::oDlgOwner := GetWndDefault()
	::oBlackPnl := Nil

	::oWaitPnl := Nil
	::oWaitAdd := Nil

	::oMainPnl   := Nil
	::oPanelInd  := Nil
	::oSplitFoot := Nil

	::oTitlePnl := Nil
	::oCadPnl   := Nil
	::oCadTitle := Nil
	::oMessPnl  := Nil

	::oFooter  := Nil
	::oFootAtu := Nil
	::oFootChg := Nil
	::oFootCal := Nil
	::oFootCfg := Nil
	::oFootSlc := Nil
	::oFootMor := Nil
		::oMorMenu := Nil

	// Atualiza as Coordenadas do Objeto Pai
	oParent:CoorsUpdate()

	//--------------------------------------------------
	// Painel utilizado para Adicionar um Painel de Indicadores
	//--------------------------------------------------
	::oWaitPnl := TPanel():New(01, 01, , oParent, , , , CLR_BLACK, CLR_WHITE, 100, 100)
	::oWaitPnl:Align := CONTROL_ALIGN_ALLCLIENT
	::oWaitPnl:CoorsUpdate()
	::oWaitPnl:Hide() // Inicia Escondido

		// Botão: Insirir Painel
		::oWaitAdd := TButton():New(003, , STR0001, ::oWaitPnl, {|| ::SelectPanel() },; //"Insira aqui o seu Painel de Indicadores"
										050, 012, , , .F., .T., .F., , .F., , , .F.)
		fSetCSS(0, ::oWaitAdd) // Seta o CSS do botão
		::oWaitAdd:lCanGotFocus := .F.
		::oWaitAdd:cTooltip := STR0002 //"Clique aqui para selecionar um Painel de Indicadores"
		::oWaitAdd:Align := CONTROL_ALIGN_ALLCLIENT

	//--------------------------------------------------
	// Painel do Cadastro
	//--------------------------------------------------
	::oCadPnl := TPanel():New(01, 01, , oParent, , .T., , CLR_BLACK, CLR_WHITE, 220, 100)
	::oCadPnl:Align := CONTROL_ALIGN_LEFT
	::oCadPnl:Hide() // Inicia Escondido

	//--------------------------------------------------
	// Painel Principal (Container) do Painel de Indicadores
	//--------------------------------------------------
	::oMainPnl := TPanel():New(01, 01, , oParent, , , , CLR_BLACK, CLR_WHITE, 100, 100)
	::oMainPnl:Align := CONTROL_ALIGN_ALLCLIENT
	::oMainPnl:CoorsUpdate()
	::oMainPnl:Hide() // Inicia Escondido

		//--------------------------------------------------
		// Painel do Título do Painel de Indicadores
		//--------------------------------------------------
		::oTitlePnl := TPanel():New(01, 01, STR0003, ::oMainPnl, oFntBold18, .T., , CLR_BLACK, CLR_WHITE, 100, ::nSizeTitBar) //"Informações do Cadastro"
		::oTitlePnl:Align := CONTROL_ALIGN_TOP
		::oTitlePnl:CoorsUpdate()
		::oTitlePnl:Hide() // Inicia Escondido

		//--------------------------------------------------
		// Rodapé
		//--------------------------------------------------
		::oFooter := TPanel():New(01, 01, , ::oMainPnl, , , , CLR_BLACK, CLR_WHITE, 100, ::nSizeBtnBar)
		::oFooter:Align := CONTROL_ALIGN_BOTTOM

			::aSpaceBtn := Array(__nSpcQtde)

			nSpcPnl := 005

			//--- Lado DIREITO

			// Painel auxiliar para deixar um espaço entre o botão e a borda do Painel
			oTmpPnl := TPanel():New(01, 01, , ::oFooter, , , , CLR_BLACK, CLR_WHITE, 001, 100)
			oTmpPnl:Align := CONTROL_ALIGN_RIGHT

			// Botão: Configurações
			::oFootCfg := TButton():New(003, , STR0004, ::oFooter, {|| ::Config() },; //"Configurações"
											050, 012, , , .F., .T., .F., , .F., , , .F.)
			fSetCSS(2, ::oFootCfg) // Seta o CSS do botão
			::oFootCfg:lCanGotFocus := .F.
			::oFootCfg:cTooltip := STR0005 //"Acessar as Configurações do Painel"
			::oFootCfg:Align := CONTROL_ALIGN_RIGHT

			// Painel auxiliar para deixar um espaço entre os botões
			::aSpaceBtn[__nSpcDCfg] := TPanel():New(01, 01, , ::oFooter, , , , CLR_BLACK, CLR_WHITE, nSpcPnl, 100)
			::aSpaceBtn[__nSpcDCfg]:Align := CONTROL_ALIGN_RIGHT

			// Botão: Mais Opções
			::oFootMor := TButton():New(003, , STR0006, ::oFooter, {|| Nil },; //"Mais"
											030, 012, , , .F., .T., .F., , .F., , , .F.)
			fSetCSS(2, ::oFootMor) // Seta o CSS do botão
			::oFootMor:lCanGotFocus := .F.
			::oFootMor:cTooltip := STR0007 //"Mais Opções"
			::oFootMor:Align := CONTROL_ALIGN_RIGHT
				// Cria o Menu POPUP
				::oMorMenu := TMenu():New(0/*nTop*/, 0/*nLeft*/, 0/*nHeight*/, 0/*nWidth*/, .T./*lPopUp*/, /*cBmpName*/, ::oDlgOwner/*oWnd*/, ;
										/*nClrNoSelect*/, /*nClrSelect*/, /*cArrowUpNoSel*/, /*cArrowUpSel*/, /*cArrowDownNoSel*/, /*cArrowDownSel*/ )

			// Painel auxiliar para deixar um espaço entre os botões
			::aSpaceBtn[__nSpcDMor] := TPanel():New(01, 01, , ::oFooter, , , , CLR_BLACK, CLR_WHITE, nSpcPnl, 100)
			::aSpaceBtn[__nSpcDMor]:Align := CONTROL_ALIGN_RIGHT

			// Botão: Indicadores
			::oFootSlc := TButton():New(003, , STR0008, ::oFooter, {|| ::SelectInds() },; //"Indicadores"
											050, 012, , , .F., .T., .F., , .F., , , .F.)
			fSetCSS(2, ::oFootSlc) // Seta o CSS do botão
			::oFootSlc:lCanGotFocus := .F.
			::oFootSlc:cTooltip := STR0009 //"Selecionar os Indicadores do Painel"
			::oFootSlc:Align := CONTROL_ALIGN_RIGHT

			// Painel auxiliar para deixar um espaço entre os botões
			::aSpaceBtn[__nSpcDSlc] := TPanel():New(01, 01, , ::oFooter, , , , CLR_BLACK, CLR_WHITE, nSpcPnl, 100)
			::aSpaceBtn[__nSpcDSlc]:Align := CONTROL_ALIGN_RIGHT

			// Painel auxiliar para deixar um espaço entre os botões (deixando deste lado para dar um espaço a mais)
			::aSpaceBtn[__nSpcDChg] := TPanel():New(01, 01, , ::oFooter, , , , CLR_BLACK, CLR_WHITE, nSpcPnl, 100)
			::aSpaceBtn[__nSpcDChg]:Align := CONTROL_ALIGN_RIGHT

			// Botão: Modo Gráfico/Lista
			::oFootChg := TButton():New(003, , "", ::oFooter, {|| If(::GetGraphic(), ::SetList(), ::SetGraphic()) },;
											050, 012, , , .F., .T., .F., , .F., , , .F.)
			fSetCSS(2, ::oFootChg) // Seta o CSS do botão
			::oFootChg:lCanGotFocus := .F.
			::oFootChg:cTooltip := ""
			::oFootChg:Align := CONTROL_ALIGN_RIGHT

			//--- Lado ESQUERDO

			// Painel auxiliar para deixar um espaço entre o botão e a borda do Painel
			oTmpPnl := TPanel():New(01, 01, , ::oFooter, , , , CLR_BLACK, CLR_WHITE, 001, 100)
			oTmpPnl:Align := CONTROL_ALIGN_LEFT

			// Botão: Atualizar
			::oFootAtu := TButton():New(003, , STR0010, ::oFooter, {|| ::Refresh() },; //"Atualizar"
											050, 012, , , .F., .T., .F., , .F., , , .F.)
			fSetCSS(2, ::oFootAtu) // Seta o CSS do botão
			::oFootAtu:lCanGotFocus := .F.
			::oFootAtu:cTooltip := STR0011 //"Atualizar o Painel de Indicadores"
			::oFootAtu:Align := CONTROL_ALIGN_LEFT

			// Painel auxiliar para deixar um espaço entre os botões
			::aSpaceBtn[__nSpcDCal] := TPanel():New(01, 01, , ::oFooter, , , , CLR_BLACK, CLR_WHITE, (nSpcPnl*2), 100)
			::aSpaceBtn[__nSpcDCal]:Align := CONTROL_ALIGN_LEFT

			// Botão: Calcular
			::oFootCal := TButton():New(003, , STR0012, ::oFooter, {|| ::Calculate(, .T.) },; //"Calcular"
											050, 012, , , .F., .T., .F., , .F., , , .F.)
			fSetCSS(2, ::oFootCal) // Seta o CSS do botão
			::oFootCal:lCanGotFocus := .F.
			::oFootCal:cTooltip := STR0013 //"Calcular os Indicadores"
			::oFootCal:Align := CONTROL_ALIGN_LEFT

		//--------------------------------------------------
		// Splitter do Rodapé
		//--------------------------------------------------
		::oSplitFoot := TButton():New(001, , STR0014, ::oMainPnl, {|| ::SplitFoot() },; //"Inibir Rodapé"
										050, 006, , , .F., .T., .F., , .F., , , .F.)
		fSetCSS(1, ::oSplitFoot) // Seta o CSS do botão
		::oSplitFoot:lCanGotFocus := .F.
		::oSplitFoot:Align := CONTROL_ALIGN_BOTTOM

		//--------------------------------------------------
		// Painel de Mensagens
		//--------------------------------------------------
		::oMessPnl := TPanel():New(01, 01, "", ::oMainPnl, oFntBoldPD, , , CLR_BLACK, CLR_WHITE, 100, 010)
		::oMessPnl:Align := CONTROL_ALIGN_BOTTOM
		::oMessPnl:Hide() // Inicia Escondido

			// Botão: Fechar
			oTmpBtn := TBtnBmp2():New(001, 001, 20, 20, "BR_CANCEL", , , , {|| ::oMessPnl:Hide() }, ::oMessPnl, OemToAnsi(STR0015)) //"Fechar"
			oTmpBtn:lCanGotFocus := .F.
			oTmpBtn:Align := CONTROL_ALIGN_RIGHT

		//--------------------------------------------------
		// Painel de Totalizadores (Total de Indicadores)
		//--------------------------------------------------
		::oTotalPnl := TPanel():New(01, 01, "", ::oMainPnl, oFntBoldPD, , , CLR_GRAY, CLR_WHITE, 100, 010)
		::oTotalPnl:Align := CONTROL_ALIGN_BOTTOM
		::oTotalPnl:Hide() // Inicia Escondido

		//--------------------------------------------------
		// Painel de Indicadores
		//--------------------------------------------------
		::oPanelInd := TPanel():New(01, 01, , ::oMainPnl, , , , CLR_BLACK, CLR_WHITE, 100, 100)
		::oPanelInd:Align := CONTROL_ALIGN_ALLCLIENT

	//--------------------------------------------------
	// Inicializa o Ambiente, caso seja uma chamada fora do ambiente
	//--------------------------------------------------
	If lEnvironme
		::cLoadFunc := AllTrim( FunName() )
		::cLoadUser := AllTrim( RetCodUsr() )
	EndIf
	If !lEnvironme .Or. Empty(::cLoadFunc)
		::cLoadFunc := "FUNCTION" // Para testes!
	EndIf
	If !lEnvironme .Or. Empty(::cLoadUser)
		::cLoadUser := "000000" // Para testes!
	EndIf

	// Inicializa as Informações do Painel
	::aInfo := Array(__nInfQtde)
	::aInfo[__nInfFili] := ""
	::aInfo[__nInfCodi] := ""
	::aInfo[__nInfNome] := ""
	::aInfo[__nInfUsCd] := ""
	::aInfo[__nInfUsNo] := ""
	::aInfo[__nInfMdCd] := ""
	::aInfo[__nInfMdNo] := ""
	::aInfo[__nInfAtiv] := "2"
	// Inicializa os Tamnahos e Decimais  das Informações do Painel
	::aFieldInfo := Array(__nInfQtde)
	::aFieldInfo[__nInfFili] := Nil
	::aFieldInfo[__nInfCodi] := Nil
	::aFieldInfo[__nInfNome] := Nil
	::aFieldInfo[__nInfUsCd] := Nil
	::aFieldInfo[__nInfUsNo] := Nil
	::aFieldInfo[__nInfMdCd] := Nil
	::aFieldInfo[__nInfMdNo] := Nil
	::aFieldInfo[__nInfAtiv] := Nil

	// Zera o Cadastro
	::aShowCad := { {}, {} }

	// Seta Opções Padrões
	::SetOptions()

	// Cria um Painel Preto (meio Transparente) no Dialog Principal
	::BlackPnl(.F.)

	// Inicia no modo Gráfico
	::SetGraphic()

Return Self

//---------------------------------------------------------------------
/*/{Protheus.doc} Activate
Ativa a classe.

@author Wagner Sobral de Lacerda
@since 18/05/2012

@return .T./.F.
/*/
//---------------------------------------------------------------------
Method Activate() Class TNGPanel

	// Variáveis da Classe
	Local nMode := ::GetMode()

	// Variáveis de Bloco de Código
	Local bActivate := ::GetCodeBlock(__nBActPnl)

	// Variáveis auxiliares
	Local aActivate := {}
	Local uAuxVld := Nil
	Local nX := 0

	//----------------------------------------
	//Validações para a Ativação da Classe
	//----------------------------------------
	//-- Valida o preenchimento das Informações dos Campos
	uAuxVld := aClone( ::GetFldInfo() )
	For nX := 1 To Len(uAuxVld)
		If ValType(uAuxVld[nX]) <> "A"
			fShowMsg(STR0016 + " TNGPanel." + CRLF + CRLF + ; //"Não foram definidas as especificações dos campos para a classe"
						STR0017, "A") //"Favor contatar o administrador do sistema."
			Return .F.
		EndIf
	Next nX

	//----------------------------------------
	// Indica que a Classe está Ativada
	//----------------------------------------
	::lActivated := .T.

	// Carrega Painel para Ativar, caso exista (retorno do bloco de código)
	If ValType(bActivate) == "B"
		aActivate := Eval(bActivate, nMode)
		If Len(aActivate) > 0
			::cCodFilia := aActivate[1]
			::cCodPanel := aActivate[2]
			::cLoadUser := aActivate[3]
			::cLoadFunc := aActivate[4]

			// Cria um Default para as configurações
			fCfgDefault(Self)
		EndIf
	EndIf

	// Realiza a carga inicial, para verificar se já há alguma Painel para carregar (depois as configurações serão carregadas novamente de acordo com o Painel, no método CREATE)
	::LoadConfig()

	//--------------------------------------------------
	// Seta a Painel de Indicadores a carregar
	//--------------------------------------------------
	::SetPanel()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} DeActivate
Desativa a classe.

@author Wagner Sobral de Lacerda
@since 18/05/2012

@return .T.
/*/
//---------------------------------------------------------------------
Method DeActivate() Class TNGPanel

	// Indica que a classe está Desativada
	::lActivated := .F.

	// Limpa o Painel
	::ClearPanel()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SplitFoot
Método que Mostra/Inibe o Rodapé.

@author Wagner Sobral de Lacerda
@since 30/04/2012

@return .T.
/*/
//---------------------------------------------------------------------
Method SplitFoot() Class TNGPanel

	If ::oFooter:lVisible
		::oFooter:Hide()
		::oSplitFoot:cTitle := OemToAnsi(STR0018) //"Mostrar o Rodapé"
	Else
		::oFooter:Show()
		::oSplitFoot:cTitle := OemToAnsi(STR0019) //"Inibir o Rodapé"
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} Refresh
Método que define o Painel para a classe.

@author Wagner Sobral de Lacerda
@since 30/04/2012

@return .T.
/*/
//---------------------------------------------------------------------
Method Refresh() Class TNGPanel

	// Variáveis da Classe
	Local aIndics := aClone( ::GetIndics() )

	//----------
	// Executa
	//----------
	// Atualiza as Coordenadas do Painel Principal
	::oMainPnl:CoorsUpdate()
	::oPanelInd:CoorsUpdate()

	If ::IsCreated() .Or. Len(aIndics) > 0
		// Mostra Painel
		::BlackPnl(.T.)

		//----------
		// Atualiza
		//----------
		MsgRun(STR0020, STR0021, {|| ::Create() }) //"Atualizando Painel de Indicadores..." ## "Por favor, aguarde..."

		// Esconde Painel
		::BlackPnl(.F.)
	EndIf

Return .T.

/*/
############################################################################################
##                                                                                        ##
## MÉTODOS: SET                                                                           ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} SetPanel
Método que define o Painel para a classe.

@author Wagner Sobral de Lacerda
@since 30/04/2012

@param cSetPanel
	Código do Painel de Indicador para carregar * Opcional
	Default: ::cCodPanel
@param cSetFilial
	Código da Filial do Painel de Indicadores * Opcional
	Default: ::cCodFilia
@param cSetModulo
	Código do Módulo do Painel de Indicadores * Opcional
	Default: ::cCodModul
@param aSetEspInds
	Array com Indicadores específicos a serem montados * Opcional
	   ATENÇÃO: se este parâmetro for passado, os indicadores da base
	   não serão carregados; somente os do array serão!
	Default: ::GetIndics(2)

@return lReturn
/*/
//---------------------------------------------------------------------
Method SetPanel(cSetPanel, cSetFilial, cSetModulo, aSetEspInds) Class TNGPanel

	// Variáveis da Classe
	Local nMode := ::GetMode()

	// Variáveis auxiliares
	Local aRetBlock := {}

	// Variáveis de Bloco de Código
	Local bSetPanel := ::GetCodeBlock(__nBSetPnl)
	Local bEndPanel := ::GetCodeBlock(__nBEndPnl)

	// Variável do Retorno
	Local lReturn := .T.

	// Defaults
	Default cSetPanel  := ::cCodPanel
	Default cSetFilial := ::cCodFilia
	Default cSetModulo := ::cCodModul
	Default aSetEspInds := aClone( ::GetIndics(2) )

	//----------
	// Valida
	//----------
	If ( nMode == _nModeQry .And. Empty(cSetPanel) ) .Or. ( nMode == _nModeEdt .And. Empty(cSetPanel) .And. Len(aSetEspInds) == 0 )
		lReturn := .F.
	EndIf

	// Mostra Painel
	::BlackPnl(.T.)

	// Limpa as Informações
	::aInfo := {}
	// Limpa as Classificações
	::aClassInds := {}
	// Limpa os ParÂmetros
	::aParams := {}
	// Seta os Indicadores específicos
	::SetEspInds(aSetEspInds)

	// Apenas em Modo de Consulta E se o Painel estiver Ativado E o Ambiente está atualizado
	If lReturn
		// Coloca o cursor do mouse em estado de espera
		CursorWait()

		If ValType(bSetPanel) == "B"
			aRetBlock := Eval(bSetPanel, cSetPanel, cSetFilial, cSetModulo, aSetEspInds)
			// Seta as Informações
			::SetInfo( aClone(aRetBlock[1]) )
			// Limpa as Classificações
			::aClassInds := aClone(aRetBlock[2])
			// Seta os ParÂmetros
			::aParams := aClone(aRetBlock[3])
		EndIf

		// Coloca o cursor do mouse em estado normal
		CursorArrow()
	EndIf

	// Define os conteúdos Default
	If Len(::aInfo) == 0
		// Informações
		::SetInfo(,.T.)
	EndIf
	// Definições do Painel
	::cCodPanel := ::aInfo[__nInfCodi]
	::cCodFilia := ::aInfo[__nInfFili]
	::cCodModul := ::aInfo[__nInfMdCd]

	// Define Modo de Ação
	If !IsInCallStack("SETMODE")
		::SetMode()
	EndIf

	// Se o Cadastro estiver fixado no Painel, atualiza suas informações
	If ::GetFixedCad()
		::SetFixedCad()
	EndIf

	// Executa um Bloco de Código após o painel ter sido criado
	If ValType(bEndPanel) == "B"
		Eval(bEndPanel, Self, lReturn)
	EndIf

	// Esconde Painel
	::BlackPnl(.F.)

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} SetEspInds
Método que define os Indicadores específicos que devem ser carregados.

@author Wagner Sobral de Lacerda
@since 21/05/2012

@param aSetEspInds
	Array com Indicadores específicos a serem montados * Opcional
	Default: {}

@return .T.
/*/
//---------------------------------------------------------------------
Method SetEspInds(aSetEspInds) Class TNGPanel

	// Defaults
	Default aSetEspInds := aClone( ::GetIndics(2) )

	// Seta os Indicadores
	If ValType(aSetEspInds) == "A"
		::aOtherInds := aClone( aSetEspInds )
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SetParams
Método que define o Painel para a classe.

@author Wagner Sobral de Lacerda
@since 30/04/2012

@param aSetParams
	Indica o Array de Parâmetros para seta no Painel: * Obrigatório
	   [1] - Código do Parâmetro
	   [2] - Conteúdo

@return .T.
/*/
//---------------------------------------------------------------------
Method SetParams(aSetParams) Class TNGPanel

	// Variáveis de Controle
	Local xGetVal := Nil
	Local nPar := 0, nScan := 0

	// Defaults
	Default aSetParams := {}

	// Valida
	If Len(aSetParams) == 0
		Return .F.
	EndIf

	//------------------------------
	// Define os ParÂmetros
	//------------------------------
	For nPar := 1 To Len(aSetParams)
		nScan := aScan(::aParams, {|x| AllTrim(x[__nParCodi]) == AllTrim(aSetParams[nPar][1]) })
		If nScan > 0
			xGetVal := fConvPar(aSetParams[nPar][2], ::aParams[nScan][__nParTipo], ::aParams[nScan][__nParTama], ::aParams[nScan][__nParDeci], ::aParams[nScan][__nParCodi])
			::aParams[nScan][__nParCont] := xGetVal
		EndIf
	Next nPar

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SetMode
Método que define o Modo de Ação sobre a classe.

@author Wagner Sobral de Lacerda
@since 16/05/2012

@param nSetMode
	Código do Modo de Ação sobre o Painel * Opcional
	   1 - Consulta
	   2 - Edição
	Default: ::nMode

@return .T.
/*/
//---------------------------------------------------------------------
Method SetMode(nSetMode) Class TNGPanel

	// Variável auxiliar do Painel preto para armazenar o seu estado inicial (utilizado para: se já estava visível, então a rotina/função anterior é responsável por escondâ-lo também)
	Local lBlackVisi := ::IsBlackPnl()

	// Defaults
	Default nSetMode := ::GetMode()

	// Mostra Painel
	If !lBlackVisi
		::BlackPnl(.T.)
	EndIf

	// Verifica o Mode de Ação
	If nSetMode == _nModeQry
		::nMode := _nModeQry
	ElseIf nSetMode == _nModeEdt
		::nMode := _nModeEdt
	EndIf

	// Seta a manipulação do Painel de Indicadores
	If ::IsEnabled()
		::Enable()
	Else
		::Disable()
	EndIf

	// Se não estiver no processo de criação do Painel
	If !IsInCallStack("CREATE")
		// Carrega Configurações
		::LoadConfig()

		// Se estiver ativada a classe
		If ::lActivated
			If ::IsCreated()
				// Atualiza o Painel
				::Refresh()
			Else
				// Seta o Painel
				::SetPanel()
				// Cria o Painel
				MsgRun(STR0022, STR0021, {|| ::Create() }) //"Criando Painel de Indicadores..." ## "Por favor, aguarde..."
			EndIf
		EndIf
	EndIf

	// Esconde Painel
	If !lBlackVisi
		::BlackPnl(.F.)
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SetOptions
Método que seta as Opções disponíveis no botão de "Mais Opções" no Painel

@author Wagner Sobral de Lacerda
@since 06/06/2012

@param aOptions
	Indica as Opções que devem ser habilitadas * Opcional
	   "ALL"   - Todas as opções habilitadas
	   "INFO"  - Informações do Cadastro
	   "NEW"   - Novo
	   "SAVE"  - Salvar
	   "LOAD"  - Carregar
	   "DELET" - Excluir/Deletar
	Default: {"ALL"} (todas)
@param aNoOptions
	Indica as Opções que devem ser desabilitadas (sobrepondo as habilitadas) * Opcional
	   "NONE"  - Nenhuma opção habilitada
	   "INFO"  - Informações do Cadastro
	   "NEW"   - Novo
	   "SAVE"  - Salvar
	   "LOAD"  - Carregar
	   "DELET" - Excluir/Deletar
	Default: {} (não desabilita nenhum)

@return .T.
/*/
//---------------------------------------------------------------------
Method SetOptions(aOptions, aNoOptions) Class TNGPanel

	// Defaults
	Default aOptions   := {"ALL"}
	Default aNoOptions := {}

	// Define os parâmetros caso sejam arrays não definidos
	If Len(aOptions) == 0
		aOptions := {"ALL"}
	EndIf

	// Define o atributo
	::aOptions := { aClone( aOptions ), aClone( aNoOptions ) }

	// Se a classe já estiver ativada, então recarrega as opções no botões 'Mais'
	If ::lActivated
		::CanOptions()
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SetGraphic
Método que seta a Apresentação em modo "Indicadores Gráficos"

@author Wagner Sobral de Lacerda
@since 25/05/2012

@param lRefresh
	Indica se deve atualizar o Painel de Indicadores * Opcional
	   .T. - Atualiza
	   .F. - Não atualiza
	Default: .T.

@return .T.
/*/
//---------------------------------------------------------------------
Method SetGraphic(lRefresh) Class TNGPanel

	// Defaults
	Default lRefresh := .T.

	//----------
	// Executa
	//----------
	// Define variáveis do modo de apresnetação
	::lIsGraphic := .T.
	::lIsList    := .F.

	// Atualiza o Botão
	::oFootChg:SetText(STR0023) //"Modo Lista"
	::oFootChg:cToolTip := STR0024 //"Alterar a visualização dos Indicadores para o modo Lista"

	// Salva as configurações
	::SaveConfig()

	// Atualiza o Painel
	If lRefresh
		::Refresh()
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SetList
Método que seta a Apresentação em modo "Lista"

@author Wagner Sobral de Lacerda
@since 25/05/2012

@param lRefresh
	Indica se deve atualizar o Painel de Indicadores * Opcional
	   .T. - Atualiza
	   .F. - Não atualiza
	Default: .T.

@return .T.
/*/
//---------------------------------------------------------------------
Method SetList(lRefresh) Class TNGPanel

	// Defaults
	Default lRefresh := .T.

	//----------
	// Executa
	//----------
	// Define variáveis do modo de apresnetação
	::lIsGraphic := .F.
	::lIsList    := .T.

	// Atualiza o Botão
	::oFootChg:SetText(STR0025) //"Modo Gráfico"
	::oFootChg:cToolTip := STR0026 //"Alterar a visualização dos Indicadores para o modo Gráfico"

	// Salva as configurações
	::SaveConfig()

	// Atualiza o Painel
	If lRefresh
		::Refresh()
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SetFixedCad
Método que seta as Informações do Cadastro como Fixas no Painel, ou não.

@author Wagner Sobral de Lacerda
@since 31/05/2012

@param lFixed
	Indica se deve fixar ou não as Informações do Cadastro * Opcional
	   .T. - Fixar
	   .F. - Desafixar
	Default: ::GetFixedCad()

@return .T.
/*/
//---------------------------------------------------------------------
Method SetFixedCad(lFixed, lRefresh) Class TNGPanel

	// Defaults
	Default lFixed   := ::GetFixedCad()
	Default lRefresh := .F.

	// Define a fixação
	::lFixedCad := lFixed

	// Executa
	If lFixed
		::oCadPnl:Show() // Mostra o Painel do Cadsatro

		::ShowCad() // Atualiza o Cadastro
	Else
		::oCadPnl:Hide() // Esconde o Painel do Cadsatro
	EndIf
	::CanOptions() // Atualiza as opções do botões de Mais Opções

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SetTotal
Método que seta os Totalizadores do Painel.

@author Wagner Sobral de Lacerda
@since 06/06/2012

@param nAmount
	Indica a quantidade de Indicadores no Folder atual * Opcional
	Default: Quantidade de indicadores na classificação do folder atual
@param nTotal
	Indica a quantidade de Indicadores no Folder atual * Opcional
	Default: Quantidade de total de indicadores (de todas as classificações)

@return .T.
/*/
//---------------------------------------------------------------------
Method SetTotal(nAmount, nTotal) Class TNGPanel

	// Variáveis de Controle
	Local nClass := aScan(::aClassInds, {|x| x[__nCInClas] == ::cFldOption })
	Local nX := 0

	Local cPicture := "@E 999,999,999"

	// Define a quantidade atual
	If Type("nAmount") == "U"
		nAmount := 0
		If nClass > 0
			nAmount := Len(::aClassInds[nClass][__nCInInds])
		EndIf
	EndIf

	// Define a quantidade Total
	If Type("nTotal") == "U"
		nTotal := 0
		For nX := 1 To Len(::aClassInds)
			nTotal += Len(::aClassInds[nX][__nCInInds])
		Next nX
	EndIf

	// Define a mensagem
	::oTotalPnl:SetText(STR0027 + " " + AllTrim(Transform(nAmount,cPicture)) + " / " + AllTrim(Transform(nTotal,cPicture))) //"Total de Indicadores:"

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SetCodeBlock
Método que seta um Bloco de Código para o Painel de Indicadores.

@author Wagner Sobral de Lacerda
@since 08/08/2012

@param nCodeBlock
	Indica qual o Bloco de Código que será definido * Obrigatório
	   1 - Definição do Painel de Indicadores (SetPanel)
	   	* parâmetro 1: Código do Painel de Indicadores
	   	* parâmetro 2: Filial
	   	* parâmetro 3: Módulo
	   	* parâmetro 4: Código de Indicadores carregados via array
	   2 - Executa a mudança d linha do browse de Seleção de Indicadores (Change)
	   	* parâmetro 1: Objeto do Indicador Gráfico (TNGIndicator)
	   	* parâmetro 2: Código da Fórmula
	   3 - Carga inicial do browse de Seleção de Indicadores (Charge)
	   	* não recebe parâmetros
	   4 - Executa a mudança de linha do browse de Seleção de Indicadores (Change)
	   	* parâmetro 1: Objeto do Browse
	   	* parâmetro 2: Objeto do Preview (TNGIndicator)
	   	* parâmetro 3: Array com a Clissificação e seus Indicadores
	   5 - Executa a visualização da linha do browse de Seleção de Indicadores (View)
	   	* parâmetro 1: Objeto do Browse
	   	* parâmetro 3: Array com a Clissificação e seus Indicadores
@param bCodeBlock
	Bloco de Código * Obrigatório

@return .T./.F.
/*/
//---------------------------------------------------------------------
Method SetCodeBlock(nCodeBlock, bCodeBlock) Class TNGPanel

	// Valida se pode setar o bloco de código
	If nCodeBlock <= 0 .Or. nCodeBlock > __nBQtde
		Return .F.
	EndIf

	// Seta o Bloco de Código
	::aCodeBlock[nCodeBlock] := bCodeBlock

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SetFldInfo
Método que seta o Tamanho dos campos do array 'aInfo'

@author Wagner Sobral de Lacerda
@since 09/08/2012

@param aSetFields
	Array com o Tamanho e Decimal dos campos * Opcional
	Default: ::GetFldInfo()

@return .T./.F.
/*/
//---------------------------------------------------------------------
Method SetFldInfo(aSetFields) Class TNGPanel

	// Variáveis auxiliares
	Local nLen := 0

	// Defaults
	Default aSetFields := aClone( ::GetFldInfo() )

	// Define os Tamnahos e Decimais das Informações do Painel
	nLen := Len(aSetFields)

	If nLen >= __nInfFili // Filial
		::aFieldInfo[__nInfFili] := aClone( aSetFields[__nInfFili] )
	EndIf
	If nLen >= __nInfCodi // Código do Painel
		::aFieldInfo[__nInfCodi] := aClone( aSetFields[__nInfCodi] )
	EndIf
	If nLen >= __nInfNome // Nome do Painel
		::aFieldInfo[__nInfNome] := aClone( aSetFields[__nInfNome] )
	EndIf
	If nLen >= __nInfUsCd // Código do Usuário
		::aFieldInfo[__nInfUsCd] := aClone( aSetFields[__nInfUsCd] )
	EndIf
	If nLen >= __nInfUsNo // Nome do Usuário
		::aFieldInfo[__nInfUsNo] := aClone( aSetFields[__nInfUsNo] )
	EndIf
	If nLen >= __nInfMdCd // Código do Módulo
		::aFieldInfo[__nInfMdCd] := aClone( aSetFields[__nInfMdCd] )
	EndIf
	If nLen >= __nInfMdNo // Nome do Módulo
		::aFieldInfo[__nInfMdNo] := aClone( aSetFields[__nInfMdNo] )
	EndIf
	If nLen >= __nInfAtiv // Painel está Ativo ou Inativo
		::aFieldInfo[__nInfAtiv] := aClone( aSetFields[__nInfAtiv] )
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SetInfo
Método que seta as Informações do Painel (array 'aInfo').

@author Wagner Sobral de Lacerda
@since 18/08/2012

@param aSetInfo
	Array com o as informações do Painel * Opcional
	Default: ::GetInfo()
@param aSetInfo
	Indica se deve setar as informações vazias * Opcional
	   .T. - Setar vazio
	   .F. - Não setar vazio, setando então de acordo com o array 'aSetInfo'
	Default: .F.

@return .T./.F.
/*/
//---------------------------------------------------------------------
Method SetInfo(aSetInfo, lEmpty) Class TNGPanel

	// Variáveis da classe
	Local aFieldInfo := aClone( ::GetFldInfo() )

	// Variáveis auxiliares
	Local nLen := 0

	// Defaults
	Default aSetInfo := aClone( ::GetInfo() )
	Default lEmpty   := .F.

	//----------
	// Executa
	//----------
	::aInfo := Array(__nInfQtde)

	nLen := Len(aSetInfo)

	If lEmpty
		//----------------------------------------
		// Seta as Informações em Branco
		//----------------------------------------
		::aInfo[__nInfFili] := PADR(::cCodFilia,aFieldInfo[__nInfFili][__nFldSize]," ") // 'Filial'
		::aInfo[__nInfCodi] := PADR(::cCodPanel,aFieldInfo[__nInfCodi][__nFldSize]," ") // 'Código do Painel'
		::aInfo[__nInfNome] := Space(aFieldInfo[__nInfNome][__nFldSize]) // 'Nome do Painel'
		::aInfo[__nInfUsCd] := Space(aFieldInfo[__nInfUsCd][__nFldSize]) // 'Còdigo do Usuário'
		::aInfo[__nInfUsNo] := Space(aFieldInfo[__nInfUsNo][__nFldSize]) // 'Nome do Usuário'
		::aInfo[__nInfMdCd] := PADR(::cCodModul,aFieldInfo[__nInfMdCd][__nFldSize]," ") // 'Módulo do Painel'
		::aInfo[__nInfMdNo] := Space(aFieldInfo[__nInfMdNo][__nFldSize]) // 'Nome do Módulo'
		::aInfo[__nInfAtiv] := "1" // 'Painel Ativo?' (1=Sim;2=Não)
	Else
		//----------------------------------------
		// Seta as Informações de acordo com o Array
		//----------------------------------------
		If nLen >= __nInfFili .And. ValType(aSetInfo[__nInfFili]) <> "U"
			::aInfo[__nInfFili] := aSetInfo[__nInfFili] // 'Filial'
		EndIf
		If nLen >= __nInfCodi .And. ValType(aSetInfo[__nInfCodi]) <> "U"
			::aInfo[__nInfCodi] := aSetInfo[__nInfCodi] // 'Código do Painel'
		EndIf
		If nLen >= __nInfNome .And. ValType(aSetInfo[__nInfNome]) <> "U"
			::aInfo[__nInfNome] := aSetInfo[__nInfNome] // 'Nome do Painel'
		EndIf
		If nLen >= __nInfUsCd .And. ValType(aSetInfo[__nInfUsCd]) <> "U"
			::aInfo[__nInfUsCd] := aSetInfo[__nInfUsCd] // 'Còdigo do Usuário'
		EndIf
		If nLen >= __nInfUsNo .And. ValType(aSetInfo[__nInfUsNo]) <> "U"
			::aInfo[__nInfUsNo] := aSetInfo[__nInfUsNo] // 'Nome do Usuário'
		EndIf
		If nLen >= __nInfMdCd .And. ValType(aSetInfo[__nInfMdCd]) <> "U"
			::aInfo[__nInfMdCd] := aSetInfo[__nInfMdCd] // 'Módulo do Painel'
		EndIf
		If nLen >= __nInfMdNo .And. ValType(aSetInfo[__nInfMdNo]) <> "U"
			::aInfo[__nInfMdNo] := aSetInfo[__nInfMdNo] // 'Nome do Módulo'
		EndIf
		If nLen >= __nInfAtiv .And. ValType(aSetInfo[__nInfAtiv]) <> "U"
			::aInfo[__nInfAtiv] := aSetInfo[__nInfAtiv] // 'Painel Ativo?' (1=Sim;2=Não)
		EndIf
	EndIf

Return .T.

/*/
############################################################################################
##                                                                                        ##
## MÉTODOS: GET                                                                           ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} GetPanel
Método que retorna o código do Painel de Indicadores carregado.

@author Wagner Sobral de Lacerda
@since 04/05/2012

@return ::cCodPanel
/*/
//---------------------------------------------------------------------
Method GetPanel() Class TNGPanel
Return ::cCodPanel

//---------------------------------------------------------------------
/*/{Protheus.doc} GetIndics
Método que retorna os Indicadores específicos carregados.

@author Wagner Sobral de Lacerda
@since 21/05/2012

@param nType
	Indica o tipo de retorno: * Opcional
	   0 - Ambos
	   1 - Opções permitidas
	   2 - Opcções não permitidas
	Default: 0

@return aRetIndics
/*/
//---------------------------------------------------------------------
Method GetIndics(nType) Class TNGPanel

	// Array de Retorno
	Local aRetIndics := {}

	// Variáveis de Controle
	Local nInd := 0, nScan := 0

	// Defaults
	Default nType := 0

	//--- Armazena no array de retorno os indicadores que o usuário deseja que retorno
	// Indicadores do Painel (originalmente)
	If nType == 0 .Or. nType == 1
		For nInd := 1 To Len(::aIndDef)
			// Adiciona somente se não existir
			If aScan(aRetIndics, {|x| AllTrim(x) == AllTrim(::aIndDef[nInd][__nIndForm]) }) == 0
				aAdd(aRetIndics, ::aIndDef[nInd][__nIndForm])
			EndIf
		Next nInd
	EndIf
	// Indicadores Específicos carregados
	If nType == 0 .Or. nType == 2
		For nInd := 1 To Len(::aOtherInds)
			// Adiciona somente se não existir
			If aScan(aRetIndics, {|x| AllTrim(x) == AllTrim(::aOtherInds[nInd]) }) == 0
				aAdd(aRetIndics, ::aOtherInds[nInd])
			EndIf
		Next nInd
	EndIf

Return aRetIndics

//---------------------------------------------------------------------
/*/{Protheus.doc} GetParams
Método que retorna os Parâmetros do Painel de Indicadores.

@author Wagner Sobral de Lacerda
@since 04/05/2012

@return ::cCodPanel
/*/
//---------------------------------------------------------------------
Method GetParams() Class TNGPanel
Return ::aParams

//---------------------------------------------------------------------
/*/{Protheus.doc} GetMode
Método que retorna o Modo de Ação sobre a classe.

@author Wagner Sobral de Lacerda
@since 16/05/2012

@return ::nMode
/*/
//---------------------------------------------------------------------
Method GetMode() Class TNGPanel
Return ::nMode

//---------------------------------------------------------------------
/*/{Protheus.doc} GetOptions
Método que retorna as Opções disponíveis no botão de "Mais Opções" no Painel.

@author Wagner Sobral de Lacerda
@since 06/06/2012

@param nType
	Indica o tipo de retorno: * Opcional
	   0 - Ambos
	   1 - Opções permitidas
	   2 - Opcções não permitidas
	Default: 0

@return aRetOptions
/*/
//---------------------------------------------------------------------
Method GetOptions(nType) Class TNGPanel

	// Array de Retorno
	Local aRetOptions := {}

	// Variáveis de Controle
	Local nX := 0

	// Defaults
	Default nType := 0

	//--- Armazena no array de retorno as opções permitidas/não permitidas
	// Opções permitidas
	If nType == 0
		For nX := 1 To Len(::aOptions)
			aAdd(aRetOptions, aClone(::aOptions[nX]))
		Next nX
	ElseIf nType >= Len(::aOptions)
		aRetOptions := aClone( ::aOptions[nType] )
	EndIf

Return aRetOptions

//---------------------------------------------------------------------
/*/{Protheus.doc} GetGraphic
Método que retorna se a Apresentação está em modo "Indicadores Gráficos"

@author Wagner Sobral de Lacerda
@since 25/05/2012

@return ::lIsGraphic
/*/
//---------------------------------------------------------------------
Method GetGraphic() Class TNGPanel
Return ::lIsGraphic

//---------------------------------------------------------------------
/*/{Protheus.doc} GetList
Método que retorna se a Apresentação está em modo "Lista"

@author Wagner Sobral de Lacerda
@since 25/05/2012

@return ::lIsList
/*/
//---------------------------------------------------------------------
Method GetList() Class TNGPanel
Return ::lIsList

//---------------------------------------------------------------------
/*/{Protheus.doc} GetFixedCad
Método que retorna se as Informações do Cadastro estão Fixas no Painel,
ou não.

@author Wagner Sobral de Lacerda
@since 31/05/2012

@return ::lFixedCad
/*/
//---------------------------------------------------------------------
Method GetFixedCad() Class TNGPanel
Return ::lFixedCad

//---------------------------------------------------------------------
/*/{Protheus.doc} GetTotal
Método que retorno o Totalizador atual.

@author Wagner Sobral de Lacerda
@since 08/08/2012

@return cTotal
/*/
//---------------------------------------------------------------------
Method GetTotal() Class TNGPanel

	// Variável do retorno
	Local cTotal := ::oTotalPnl:GetText()

Return cTotal

//---------------------------------------------------------------------
/*/{Protheus.doc} GetCodeBlock
Método que retorna um Bloco de Código do Painel de Indicadores.

@author Wagner Sobral de Lacerda
@since 08/08/2012

@return uCodeBlock
/*/
//---------------------------------------------------------------------
Method GetCodeBlock(nCodeBlock) Class TNGPanel

	// Variável do retorno
	Local uCodeBlock := Nil

	If nCodeBlock > 0 .And. nCodeBlock <= __nBQtde
		uCodeBlock := ::aCodeBlock[nCodeBlock]
	EndIf

Return uCodeBlock

//---------------------------------------------------------------------
/*/{Protheus.doc} GetFldInfo
Método que retorna o Tamanho e Decimal dos campos do array 'aInfo'.

@author Wagner Sobral de Lacerda
@since 09/08/2012

@return ::aFieldInfo
/*/
//---------------------------------------------------------------------
Method GetFldInfo() Class TNGPanel
Return ::aFieldInfo

//---------------------------------------------------------------------
/*/{Protheus.doc} GetInfo
Método que retorna as Informações do Painel de Indicadores carregado.

@author Wagner Sobral de Lacerda
@since 04/05/2012

@return ::aInfo
/*/
//---------------------------------------------------------------------
Method GetInfo() Class TNGPanel
Return ::aInfo

/*/
############################################################################################
##                                                                                        ##
## MÉTODOS: VALIDAÇÕES DE EXISTÊNCIA                                                      ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} IsCreated
Método que indica se existe e está criado um Painel de Indicadores.

@author Wagner Sobral de Lacerda
@since 08/05/2012

@return .T./.F.
/*/
//---------------------------------------------------------------------
Method IsCreated() Class TNGPanel

	// Verifica os dados do Painel
	// A variavel ::cCodFilia não é mais verificada devido esta poder ser compartilhada
	If Empty(::cCodPanel) .Or. Empty(::cCodModul)
		Return .F.
	EndIf

	// Verifica se está criado
	If !::lPanel
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} IsBlackPnl
Método que indica se o Painel Preto está visível (.T.) ou invisível (.F.).

@author Wagner Sobral de Lacerda
@since 01/06/2012

@return .T./.F.
/*/
//---------------------------------------------------------------------
Method IsBlackPnl() Class TNGPanel
Return ::oBlackPnl:lVisible

//---------------------------------------------------------------------
/*/{Protheus.doc} IsMine
Método que verifica se o Painel carregado é de autoria do usuário
logado no sistema

@author Wagner Sobral de Lacerda
@since 13/06/2012

@param lShowMsg
	Indica se devo mostrar mensagem em tela * Opcional
	   .T. - Mostra
	   .F. - Não mostra
	Default: .T.

@return .T./.F.
/*/
//---------------------------------------------------------------------
Method IsMine() Class TNGPanel

	// Variável do retorno
	Local lReturn := .T.

	// Variáeveis auxiliares
	Local lCanHandle := .T.

	//----------
	// Valida
	//----------
	If !Empty(::aInfo[__nInfUsCd]) .And. ::cLoadUser <> ::aInfo[__nInfUsCd] // Usuário atual diferente do autor do Painel
		lCanHandle := .F.
	EndIf

	If !lCanHandle
		If FWIsAdmin()
			If MsgYesNo(STR0028 + CRLF + CRLF + ; //"O Painel atual não é de sua autoria."
				STR0029, STR0030) //"Deseja realmente executar esta opereção utilizando sua autoridade como Administrador?" ## "Atenção"
				lCanHandle := .T.
			EndIf
		EndIf
	EndIf

	If !lCanHandle
		fShowMsg(STR0031, "I") //"Este Painel não é de sua autoria. Portanto, você não pode alterá-lo nem excluí-lo."
		lReturn := .F.
	EndIf

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} IsEnabled
Método que verifica se o Painel de Indicadores está habilitado para
manipulação.

@author Wagner Sobral de Lacerda
@since 18/08/2012

@return ::lEnabled
/*/
//---------------------------------------------------------------------
Method IsEnabled() Class TNGPanel
Return ::lEnabled

/*/
############################################################################################
##                                                                                        ##
## MÉTODOS: CONSTRUÇÃO DO PAINÉL DE INDICADORES                                           ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} Create
Método que cria o Painel de Indicadores.

@author Wagner Sobral de Lacerda
@since 30/04/2012

@return .T./.F.
/*/
//---------------------------------------------------------------------
Method Create() Class TNGPanel

	// Objetos auxiliares na montagem do Painel
	Local oFolder, nFolder
	Local oScroll
	Local oFntBold := TFont():New(, , , , .T.)
	Local oTmpPnl

	// Variáveis auxiliares na montagem do Painel
	Local aFolder := {}

	Local aInd := {}
	Local nClass := 0, nInd := 0, nLen := 0, nScan := 0

	Local nClrText := CLR_BLACK
	Local nClrBack := CLR_WHITE

	Local nPosLin, nPosCol, nIncCol

	Local nWidPnl, nHeiPnl
	Local nWidInd, nHeiInd

	Local nQtdLinAtu
	Local nIndPorLin
	Local nMinPorLin := 1

	// Variáveis específicas da montagem em modo Lista
	Local oFWBrowse, aFWBrowse := {}
	Local aHeader := {}, nHeader := 0
	Local aColunas := {}, oColuna

	Local cArrTitulo := ""
	Local cArrTipo   := ""
	Local nArrTamanh := 0
	Local nArrDecima := 0
	Local cArrPictur := ""
	Local cSetData   := ""

	// Variáveis de Definição do Painel da Classe
	Local cSetPanel  := ::cCodPanel
	Local cSetFilial := ::cCodFilia
	Local cSetModulo := ::cCodModul

	// Variáveis de Bloco de Código
	Local bLoadFormu := ::GetCodeBlock(__nBLoaFrm)
	Local bFields    := ::GetCodeBlock(__nBIndFld)
	Local bInform    := ::GetCodeBlock(__nBIndInf)
	Local bDetail    := ::GetCodeBlock(__nBIndDet)
	Local bLegend    := ::GetCodeBlock(__nBIndLeg)

	// Limpa o Painel para criar um novo
	::ClearPanel()

	// Veririca se a Classe está ativada
	If !::lActivated
		Return .F.
	EndIf

	//----------
	// Monta
	//----------
	If Len(::aClassInds) > 0
		// Define o Folder
		For nClass := 1 To Len(::aClassInds)
			aAdd(aFolder, ::aClassInds[nClass][__nCInNome])
		Next nClass

		// Monta o Folder
		oFolder := TFolder():New(01, 01, aFolder, aFolder, ::oPanelInd, 1, CLR_BLACK, CLR_WHITE, .T., , 100, 100)
		oFolder:bChange := {|| If( Len(::aClassInds) >= oFolder:nOption, ::cFldOption := ::aClassInds[oFolder:nOption][__nCInClas], ::cFldOption := ""), ;
								::SetTotal() }
		//oFolder:bChange := {|| fChangeFolder(oFolder, Self) }
		oFolder:Align := CONTROL_ALIGN_ALLCLIENT

		nFolder := aScan(::aClassInds, {|x| x[__nCInClas] == ::cFldOption })
		If nFolder > 0
			oFolder:SetOption(nFolder)
		EndIf

		For nClass := 1 To Len(::aClassInds)
			// Atualiza as coordenadas da aba
			oFolder:aDialogs[nClass]:CoorsUpdate()

			If ::GetGraphic()
				//------------------------------
				// Modo: Gráfico
				//------------------------------
				// Cria um Scroll para a Aba
				oScroll := TScrollBox():New(oFolder:aDialogs[nClass], 0, 0, 0, 0, .T., .T., .F.)
				oScroll:nClrPane := CLR_WHITE
				oScroll:Align := CONTROL_ALIGN_ALLCLIENT
				oScroll:CoorsUpdate()

				nWidPnl := ( ::oPanelInd:nClientWidth * 0.50 )
				nHeiPnl := ( ::oPanelInd:nClientHeight * 0.50 )

				// Definições da criação dos indicadores
				nPosLin := 0
				nPosCol := 0
				nWidInd := 140
				nHeiInd := 150

				// Quantidade de Indicadores por linha
				nIndPorLin := Int( (nWidPnl / nWidInd) )
				If nIndPorLin < nMinPorLin
					nIndPorLin := nMinPorLin
				EndIf
				nQtdLinAtu := 0

				// Incremento da Coluna para separar os Indicadores (calcula com o resto de espaço que não está ocupado por Indicadores)
				nIncCol := ( nWidPnl - (nWidInd * nIndPorLin) ) / nIndPorLin

				// Recebe os Indicadores
				aInd := aClone(::aClassInds[nClass][__nCInInds])
				// Monta os Indicadores
				For nInd := 1 To Len(aInd)

					nQtdLinAtu++
					If nQtdLinAtu > nIndPorLin
						nPosLin += ( nHeiInd + 010 )
						nPosCol := 0

						nQtdLinAtu := 1
					EndIf
					If nQtdLinAtu == 1
						nPosCol := ( nIncCol * 0.30 )
					ElseIf nQtdLinAtu > 1
						nPosCol += ( nWidInd + nIncCol )
					EndIf

					// Adiciona os Objetos (e Relacionados) do Indicador
					aAdd(::aIndDef, Array(__nIndQtde))
					nLen := Len(::aIndDef)

					// Còdigo do Indicador (Fórmula)
					::aIndDef[nLen][__nIndForm] := aInd[nInd][__nCInFoCd]
					// Cria um Painel para ser container do Indicador
					::aIndDef[nLen][__nIndPnl1] := TPanel():New(nPosLin, nPosCol, , oScroll, , , , CLR_BLACK, CLR_WHITE, nWidInd, nHeiInd, .F., .F.)

						// Borda Baixo
						::aIndDef[nLen][__nIndTopo] := TPanel():New(001, 001, , ::aIndDef[nLen][__nIndPnl1], , , , nClrText, nClrBack, 001, 001, .F., .F.)
						::aIndDef[nLen][__nIndTopo]:Align := CONTROL_ALIGN_TOP

						// Borda Esquerda
						::aIndDef[nLen][__nIndEsqu] := TPanel():New(001, 001, , ::aIndDef[nLen][__nIndPnl1], , , , nClrText, nClrBack, 001, 001, .F., .F.)
						::aIndDef[nLen][__nIndEsqu]:Align := CONTROL_ALIGN_LEFT

						// Borda Direita
						::aIndDef[nLen][__nIndDire] := TPanel():New(001, 001, , ::aIndDef[nLen][__nIndPnl1], , , , nClrText, nClrBack, 001, 001, .F., .F.)
						::aIndDef[nLen][__nIndDire]:Align := CONTROL_ALIGN_RIGHT

						// Borda Baixo
						::aIndDef[nLen][__nIndBaix] := TPanel():New(001, 001, , ::aIndDef[nLen][__nIndPnl1], , , , nClrText, nClrBack, 001, 001, .F., .F.)
						::aIndDef[nLen][__nIndBaix]:Align := CONTROL_ALIGN_BOTTOM

						// Painel auxiliar para o Indicador
						oTmpPnl := TPanel():New(nPosLin, nPosCol, , ::aIndDef[nLen][__nIndPnl1], , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
						oTmpPnl:Align := CONTROL_ALIGN_ALLCLIENT

							// Painel do Título
							::aIndDef[nLen][__nIndTitu] := TPanel():New(001, 001, aInd[nInd][__nCInFoNo], oTmpPnl, oFntBold, .T., , nClrText, nClrBack, 100, 012, .F., .F.)
							::aIndDef[nLen][__nIndTitu]:Align := CONTROL_ALIGN_TOP

							// Painel do Indicador
							::aIndDef[nLen][__nIndPnl2] := TPanel():New(001, 001, , oTmpPnl, , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
							::aIndDef[nLen][__nIndPnl2]:Align := CONTROL_ALIGN_ALLCLIENT

								//--------------------
								// Monta o Indicador
								//--------------------
								// Instancia a classe
								::aIndDef[nLen][__nIndGraf] := TNGIndicator():New(/*nTop*/, /*nLeft*/, 1/*nZoom*/, ::aIndDef[nLen][__nIndPnl2]/*oParent*/, /*nWidth*/, /*nHeight*/, ;
																	/*nClrFooter*/, /*cContent*/, /*cStyle*/, .F./*lScroll*/, .T./*lCenter*/)
								// Desenha o Indicador
								::aIndDef[nLen][__nIndGraf]:Indicator()

								// Desabilita a atualização automática do indicador
								::aIndDef[nLen][__nIndGraf]:Refresh(.F.)

								// Define a Fórmula
								If ValType(bLoadFormu) == "B"
									Eval(bLoadFormu, ::aIndDef[nLen][__nIndGraf], aInd[nInd][__nCInFoCd])
								EndIf
								// Define os Campos
								If ValType(bFields) == "B"
									::aIndDef[nLen][__nIndGraf]:SetFields( Eval(bFields) )
								EndIf
								// Define as Informações
								If ValType(bInform) == "B"
									::aIndDef[nLen][__nIndGraf]:SetCodeBlock(3, bInform)
								EndIf
								// Define os Detalhes
								If ValType(bDetail) == "B"
									::aIndDef[nLen][__nIndGraf]:SetCodeBlock(4, bDetail)
								EndIf
								// Define a Legenda
								If ValType(bLegend) == "B"
									::aIndDef[nLen][__nIndGraf]:SetCodeBlock(5, bLegend)
								EndIf

								// Desabilita as Configurações do Indicador
								::aIndDef[nLen][__nIndGraf]:CanConfig(.F.)
								// Desabilita o Zoom do Indicador
								::aIndDef[nLen][__nIndGraf]:CanZoom(.F.)

								// Valor do Indicador
								::aIndDef[nLen][__nIndValu] := ::aIndDef[nLen][__nIndGraf]:GetVals()[1]
								::aIndDef[nLen][__nIndGraf]:SetValue( ::aIndDef[nLen][__nIndValu] )

								// Habilita a atualização automática e já atualiza o indicador
								::aIndDef[nLen][__nIndGraf]:Refresh(.T.)

				Next nInd
			ElseIf ::GetList()
				//------------------------------
				// Modo: Lista
				//------------------------------
				// Define o Cabeçalho
				aHeader := {}
				aAdd(aHeader, {STR0032, "C",  40, 0, "@!"}) //"Cód. Indicador"
				aAdd(aHeader, {STR0033, "C", 254, 0, "@!"}) //"Indicador"
				aAdd(aHeader, {STR0034, "N",  20, 2, "@E 999,999,999,999.99"}) //"Valor"

				// Recebe os Indicadores
				aInd := aClone(::aClassInds[nClass][__nCInInds])
				// Define Conteúdo
				aFWBrowse := {}
				For nInd := 1 To Len(aInd)
					aAdd(aFWBrowse, {aInd[nInd][__nCInFoCd], aInd[nInd][__nCInFoNo], 0})

					// Adiciona os Objetos (e Relacionados) do Indicador
					aAdd(::aIndDef, Array(__nIndQtde))
					nLen := Len(::aIndDef)

					// Còdigo do Indicador (Fórmula)
					::aIndDef[nLen][__nIndForm] := aInd[nInd][__nCInFoCd]
					::aIndDef[nLen][__nIndValu] := 0
				Next nInd

				// Monta o Browse
				aAdd(::aLists, Nil)
				nLen := Len(::aLists)

				::aLists[nLen] := FWBrowse():New()
				::aLists[nLen]:SetOwner(oFolder:aDialogs[nClass])
				::aLists[nLen]:SetDataArray()
				::aLists[nLen]:SetLineHeight(35)
				::aLists[nLen]:SetFontBrowse( TFont():New( , , 14, , .F.) )
				// Máximo de 4 Caracteres para o ID do Profile do Browse
				::aLists[nLen]:SetProfileID("MAIN")

				::aLists[nLen]:SetLocate()
				::aLists[nLen]:SetDelete(.F., {|| .F.})

				aColunas := {}
				For nHeader := 1 To Len(aHeader)
					cArrTitulo := aHeader[nHeader][1]
					cArrTipo   := aHeader[nHeader][2]
					nArrTamanh := aHeader[nHeader][3]
					nArrDecima := aHeader[nHeader][4]
					cArrPictur := aHeader[nHeader][5]

					oColuna := FWBrwColumn():New()
					oColuna:SetAlign( If(cArrTipo == "N", CONTROL_ALIGN_RIGHT, CONTROL_ALIGN_LEFT) )

					cSetData := "{|oFWBrowse| oFWBrowse:Data():GetArray()[oFWBrowse:AT()][" + cValToChar(nHeader) + "] }"
					oColuna:SetData( &(cSetData) )

					oColuna:SetEdit( .F. )
					oColuna:SetSize( nArrTamanh + nArrDecima )
					oColuna:SetTitle( cArrTitulo )
					oColuna:SetType( cArrTipo )
					oColuna:SetPicture( cArrPictur )

					aAdd(aColunas, oColuna)
				Next nHeader
				::aLists[nLen]:SetColumns(aColunas)
				::aLists[nLen]:Activate()
				::aLists[nLen]:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
				::aLists[nLen]:SetArray(aFWBrowse)
				::aLists[nLen]:lHeaderClick := .F.
				::aLists[nLen]:Refresh()
			EndIf

		Next nClass
		// Executa o change para atualizar as variáveis
		Eval(oFolder:bChange)

		// Indica que montou o Painel
		::lPanel := .T.
	Else
		oTmpPnl := TPanel():New(01, 01, STR0035, ::oPanelInd, oFntBold, .T., , CLR_GRAY, CLR_WHITE, 100, 100) //"Não há Indicadores para o Painel"
		oTmpPnl:Align := CONTROL_ALIGN_ALLCLIENT
	EndIf

	// Define Modo de Ação
	::SetMode()

	If ::IsCreated()
		// Carrega as Configurações
		::LoadConfig()
		// Atualiza os Indicadores, forçando o Set dos valores (não animando)
		::Charge(2)
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} Blank
Método que cria o Painel de Indicadores em Branco.

@author Wagner Sobral de Lacerda
@since 29/05/2012

@return lReturn
/*/
//---------------------------------------------------------------------
Method Blank() Class TNGPanel

	// Variável do Retorno
	Local lReturn := .T.

	// Caso um Painel já esteja criado
	If ::IsCreated()
		// Pergunta se quer realmente criar um novo, sem salvar qualquer alteração realizada
		If !MsgYesNo(STR0036 + CRLF + CRLF + ; //"Já existe um Painel de Indicadores carregado."
					STR0037, STR0030) //"Deseja realmente criar um novo Painel em branco?" ## "Atenção"
			lReturn := .F.
		EndIf
	EndIf

	//--------------------
	// Novo em Branco
	//--------------------
	If lReturn
		::Reset()
	EndIf

Return lReturn

/*/
############################################################################################
##                                                                                        ##
## MÉTODOS: CONFIGURAÇÃO DO PAINÉL                                                        ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} Config
Método que Configura algumas opções de aprensetação do Painel.

@author Wagner Sobral de Lacerda
@since 30/04/2012

@return .T./.F.
/*/
//---------------------------------------------------------------------
Method Config() Class TNGPanel

	// Variáveis da janela
	Local oDlgCfg
	Local cDlgCfg := OemToAnsi(STR0038) //"Configurações do Painel"
	Local lDlgCfg := .F.
	Local oPnlCfg
	Local oBlackCfg // Painel preto do dialog

	Local nLargura := 500
	Local nAltura  := 300

	Local oPnlCabec
	Local oPnlParam
	Local oPnlAcoes
	Local oPnlBtn

	Local oTmpGroup
	Local oTmpCheck
	Local oTmpButtn

	// Variáveis para montar a tela mais facilmente
	Local nLinIni, nColIni
	Local nPosLin, nPosCol

	Local nSizeAco

	// Variáveis do estado atual
	Local aOldConfig := aClone( ::aConfig )
	Local aOldParams := aClone( ::aParams )
	Local lOldFixed  := ::GetFixedCad()
	Local nPar, nScan

	// Variável auxiliar do Painel preto para armazenar o seu estado inicial (utilizado para: se já estava visível, então a rotina/função anterior é responsável por escondâ-lo também)
	Local lBlackVisi := ::IsBlackPnl()

	// Variáveis de Paâmetros (PR - Parâmetro)
	Private lPr_TitPnl := ::aConfig[__nCfgTPnl]
	Private lPr_TitInd := ::aConfig[__nCfgTInd]
	Private lPr_Totalz := ::aConfig[__nCfgTota]
	Private lPr_Tema   := ::aConfig[__nCfgThem]
	Private lPr_LastV  := ::aConfig[__nCfgLast]
	Private lPr_Calc   := ::aConfig[__nCfgCalc]
	Private lPr_Anima  := ::aConfig[__nCfgAnim]
	Private nPr_Quanti := 7 // Quantidade total de parâmetros

	// Controle de Marcação
	Private oCt_MrkAll := Nil // Objeto do controle
	Private lCt_MrkAll := .T. // Controle: Marcar (.T.) / Desmarcar (.F.)

	// Mostra Painel
	If !lBlackVisi
		::BlackPnl(.T.)
	EndIf

	//----------
	// Monta
	//----------
	lDlgCfg := .F.
	DEFINE MSDIALOG oDlgCfg TITLE cDlgCfg FROM 0,0 TO nAltura,nLargura OF ::oDlgOwner STYLE WS_POPUPWINDOW PIXEL //nOr(DS_SYSMODAL,WS_MAXIMIZEBOX,WS_POPUP)

		// Painel principal do Dialog
		oPnlCfg := TPanel():New(01, 01, , oDlgCfg, , , , CLR_BLACK, CLR_WHITE, 100, 008)
		oPnlCfg:Align := CONTROL_ALIGN_ALLCLIENT

			// Painel do Cabeçalho (para o botão 'X' - Fechar)
			oPnlCabec := TPanel():New(01, 01, , oPnlCfg, , , , CLR_BLACK, CLR_WHITE, 100, 007)
			oPnlCabec:Align := CONTROL_ALIGN_TOP

				// Botão: Fechar
				oTmpButtn := TBtnBmp2():New(001, 001, 20, 20, "BR_CANCEL", , , , {|| lDlgCfg := .F., oDlgCfg:End() }, oPnlCabec, OemToAnsi(STR0015)) //"Fechar"
				oTmpButtn:lCanGotFocus := .F.
				oTmpButtn:Align := CONTROL_ALIGN_RIGHT

			nLinIni := 002
			nColIni := 005

			nSizeAco := 070

			// Painel dos Parâmetros
			oPnlParam := TPanel():New(01, 01, , oPnlCfg, , , , CLR_BLACK, CLR_WHITE, 100, 100)
			oPnlParam:Align := CONTROL_ALIGN_ALLCLIENT

				// GroupBox
				nPosLin := nLinIni
				nPosCol := nColIni
				oTmpGroup := TGroup():New(nPosLin, nPosCol, (oPnlParam:nClientHeight * 0.50)-015, (nLargura * 0.50)-nSizeAco, OemToAnsi(STR0004), oPnlParam, , , .T.) //"Configurações"

					nPosCol := (nColIni + 005)

					//--- itens DE CIMA PARA BAIXO

					// Mostra o Título do Indicador?
					nPosLin += 10
					oTmpCheck := TCheckBox():New(nPosLin, nPosCol, STR0039, {|| lPr_TitPnl }, oPnlParam, 150, 015, , {|| lPr_TitPnl := !lPr_TitPnl, fConfigMrk(oCt_MrkAll, .F.) }, , , , , , .T., , ,) //"Exibir o Título do Painel de Indicadores?"

					// Mostra o Título do Indicador?
					nPosLin += 15
					oTmpCheck := TCheckBox():New(nPosLin, nPosCol, STR0040, {|| lPr_TitInd }, oPnlParam, 150, 015, , {|| lPr_TitInd := !lPr_TitInd, fConfigMrk(oCt_MrkAll, .F.) }, , , , , , .T., , ,) //"Exibir o Título de cada Indicador?"

					// Mostra os Totalizadores?
					nPosLin += 15
					oTmpCheck := TCheckBox():New(nPosLin, nPosCol, STR0041, {|| lPr_Totalz }, oPnlParam, 150, 015, , {|| lPr_Totalz := !lPr_Totalz, fConfigMrk(oCt_MrkAll, .F.) }, , , , , , .T., , ,) //"Exibir os Totalizadores do Painel?"

					// Mostra as Bordas do Indicador?
					nPosLin += 15
					oTmpCheck := TCheckBox():New(nPosLin, nPosCol, STR0042, {|| lPr_Tema }, oPnlParam, 150, 015, , {|| lPr_Tema := !lPr_Tema, fConfigMrk(oCt_MrkAll, .F.) }, , , , , , .T., , ,) //"Exibir configurações do Tema da versão do Protheus?"

					// Atualiza Automaticamente?
					nPosLin += 15
					oTmpCheck := TCheckBox():New(nPosLin, nPosCol, STR0043, {|| lPr_LastV }, oPnlParam, 150, 015, , {|| lPr_LastV := !lPr_LastV, fConfigMrk(oCt_MrkAll, .F.) }, , , , , , .T., , ,) //"Armazenar os Valores dos Indicadores do Painel?"

					// Novos Cálculos dos Indicadores?
					nPosLin += 15
					oTmpCheck := TCheckBox():New(nPosLin, nPosCol, STR0044, {|| lPr_Calc }, oPnlParam, 150, 015, , {|| lPr_Calc := !lPr_Calc, fConfigMrk(oCt_MrkAll, .F.) }, , , , , , .T., , ,) //"Habilitar novos Cálculos para os Indicadores?"

					// Habilita Animação?
					nPosLin += 15
					oTmpCheck := TCheckBox():New(nPosLin, nPosCol, STR0045, {|| lPr_Anima }, oPnlParam, 150, 015, , {|| lPr_Anima := !lPr_Anima, fConfigMrk(oCt_MrkAll, .F.) }, , , , , , .T., , ,) //"Habilitar a Animação dos Indicadores?"

					//--- itens DE BAIXO PARA CIMA

					// Marcar/Desmarcar Todas
					nPosLin := (oPnlParam:nClientHeight * 0.50)-032
					oCt_MrkAll := TButton():New(nPosLin, nPosCol, "", oPnlParam, {|| fConfigMrk(oCt_MrkAll, .T.) },;
													050, 012, , , .F., .T., .F., , .F., , , .F.)
					fSetCSS(3, oCt_MrkAll) // Seta o CSS do botão
					oCt_MrkAll:cTooltip := ""
					oCt_MrkAll:lCanGotFocus := .F.
					fConfigMrk(oCt_MrkAll, .F.)

			// Painel das Opções de Operações (Ações)
			oPnlAcoes := TPanel():New(01, 01, , oPnlCfg, , , , CLR_BLACK, CLR_WHITE, nSizeAco, 100)
			oPnlAcoes:Align := CONTROL_ALIGN_RIGHT

				// GroupBox
				nPosLin := nLinIni
				nPosCol := nColIni
				oTmpGroup := TGroup():New(nPosLin, nPosCol, (oPnlParam:nClientHeight * 0.50)-015, nSizeAco-nPosCol, OemToAnsi(STR0046), oPnlAcoes, , , .T.) //"Relacionados"

					nPosCol := (nColIni + 005)

					//--- botões DE CIMA PARA BAIXO

					// Botão: ParÂmetros
					nPosLin += 010
					oTmpButtn := TButton():New(nPosLin, nPosCol, STR0047, oPnlAcoes, {|| oBlackCfg:Show(), ::Params(), oBlackCfg:Hide() },; //"Parâmetros"
													050, 012, , , .F., .T., .F., , .F., , , .F.)
					fSetCSS(3, oTmpButtn) // Seta o CSS do botão
					oTmpButtn:cTooltip := STR0048 //"Selecionar os Parâmetros do Painel"
					oTmpButtn:lCanGotFocus := .F.

					// Botão: Relatório
					nPosLin += 020
					oTmpButtn := TButton():New(nPosLin, nPosCol, STR0049, oPnlAcoes, {|| oBlackCfg:Show(),;
						If( ::lIsList, MsgInfo( STR0106, STR0030 ), ::Print() ), oBlackCfg:Hide() },;
													050, 012, , , .F., .T., .F., , .F., , , .F.)
					fSetCSS(3, oTmpButtn) // Seta o CSS do botão
					oTmpButtn:cTooltip := STR0050 //"Imprimir em tela o relatório do Painel"
					oTmpButtn:lCanGotFocus := .F.

					//--- botões DE BAIXO PARA CIMA

					// Botão: Liberar
					nPosLin := (oPnlParam:nClientHeight * 0.50)-032
					oTmpButtn := TButton():New(nPosLin, nPosCol, STR0051, oPnlAcoes, {|| oBlackCfg:Show(), If(::Release(), oDlgCfg:End(), oBlackCfg:Hide()) },; //"Liberar"
													050, 012, , , .F., .T., .F., , .F., , , .F.)
					fSetCSS(3, oTmpButtn) // Seta o CSS do botão
					oTmpButtn:cTooltip := STR0052 //"Liberar o Painel"
					oTmpButtn:lCanGotFocus := .F.

					// Botão: Informações
					nPosLin -= 020
					oTmpButtn := TButton():New(nPosLin, nPosCol, STR0053, oPnlAcoes, {|| oBlackCfg:Show(), ::ShowCad(2), oBlackCfg:Hide() },; //"Informações"
													050, 012, , , .F., .T., .F., , .F., , , .F.)
					fSetCSS(3, oTmpButtn) // Seta o CSS do botão
					oTmpButtn:cTooltip := STR0054 //"Informações do Cadastro do Painel"
					oTmpButtn:lCanGotFocus := .F.

			// Painel auxiliar para deixar um espaço entre o Painel de botões e a borda inferior da janela
			oTmpPnl := TPanel():New(01, 01, , oPnlCfg, , , , CLR_BLACK, CLR_WHITE, 100, (::nSpacBtnBor/2))
			oTmpPnl:Align := CONTROL_ALIGN_BOTTOM

			// Painel dos botões
			oPnlBtn := TPanel():New(01, 01, , oPnlCfg, , , , CLR_BLACK, CLR_WHITE, 100, ::nSizeBtnBar)
			oPnlBtn:Align := CONTROL_ALIGN_BOTTOM

				// Painel auxiliar para deixar um espaço entre o botão e a borda da direita da janela
				oTmpPnl := TPanel():New(01, 01, , oPnlBtn, , , , CLR_BLACK, CLR_WHITE, ::nSpacBtnBor, 100)
				oTmpPnl:Align := CONTROL_ALIGN_RIGHT

				// Botão: Voltar
				oTmpButtn := TButton():New(001, 001, STR0055, oPnlBtn, {|| lDlgCfg := .F., oDlgCfg:End() },; //"Cancelar"
												040, 012, , , .F., .T., .F., , .F., , , .F.)
				fSetCSS(5, oTmpButtn) // Seta o CSS do botão
				oTmpButtn:lCanGotFocus := .F.
				oTmpButtn:cTooltip := STR0056 //"Cancelar Configurações"
				oTmpButtn:Align := CONTROL_ALIGN_RIGHT

				// Painel auxiliar para deixar um espaço entre os botões
				oTmpPnl := TPanel():New(01, 01, , oPnlBtn, , , , CLR_BLACK, CLR_WHITE, ::nSpacBtnBtn, 100)
				oTmpPnl:Align := CONTROL_ALIGN_RIGHT

				// Botão: Confirmar
				oTmpButtn := TButton():New(001, 001, STR0057, oPnlBtn, {|| lDlgCfg := .T., oDlgCfg:End() },; //"Confirmar"
												040, 012, , , .F., .T., .F., , .F., , , .F.)
				fSetCSS(4, oTmpButtn) // Seta o CSS do botão
				oTmpButtn:lCanGotFocus := .F.
				oTmpButtn:cTooltip := STR0058 //"Confirmar Configurações"
				oTmpButtn:Align := CONTROL_ALIGN_RIGHT

		// Painel preto temporário, apenas para dar contraste quando um novo dialog for aberta em cima deste
		oBlackCfg := TPanel():New(0, 0, , oDlgCfg, , , , , SetTransparentColor(CLR_BLACK,75), nLargura, nAltura, .F., .F.)
		oBlackCfg:Align := CONTROL_ALIGN_ALLCLIENT
		oBlackCfg:Hide()

	ACTIVATE MSDIALOG oDlgCfg CENTERED

	// Se confirmou
	If lDlgCfg
		// Atualiza as Configurações
		::aConfig[__nCfgTPnl] := lPr_TitPnl
		::aConfig[__nCfgTInd] := lPr_TitInd
		::aConfig[__nCfgTota] := lPr_Totalz
		::aConfig[__nCfgThem] := lPr_Tema
		::aConfig[__nCfgLast] := lPr_LastV
		::aConfig[__nCfgCalc] := lPr_Calc
		::aConfig[__nCfgAnim] := lPr_Anima

		// Salva as configurações
		::SaveConfig()
		// Carrega as configurações salvas
		::LoadConfig()

		// Se alterou algum parâmetros, recalculo o Indicador
		For nPar := 1 To Len(::aParams)
			nScan := aScan(aOldParams, {|x| x[__nParCodi] == ::aParams[nPar][__nParCodi] .And. x[__nParCont] <> ::aParams[nPar][__nParCont] })
			If nScan > 0
				::Calculate()
				Exit
			EndIf
		Next nPar
	Else
		// Devole as configurações
		::aConfig := aClone( aOldConfig )
		// Devolve os parâmetros
		::aParams := aClone( aOldParams )
		// Devolve o estado do cadastro (fixado ou não)
		If lOldFixed <> ::GetFixedCad()
			::SetFixedCad(lOldFixed)
		EndIf
	EndIf

	// Esconde Painel
	If !lBlackVisi
		::BlackPnl(.F.)
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fConfigMrk
Define o Texto do Botão de Marcar/Desmarcar as configurações.

@author Wagner Sobral de Lacerda
@since 01/06/2012

@param oBtn
	Objeto do Botão * Obrigatório
@param lFixed
	Indica se o Painel está fixado ou não * Obrigatório
	   .T. - Está fixado
	   .F. - Não está fixado

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fConfigMrk(oBtn, lExec)

	// Variáveis de Controle
	Local nQuantMark := 0

	// Defaults
	Default lExec := .T.

	// Define as Marcações
	If lExec
		// Inverte controle
		lCt_MrkAll := !lCt_MrkAll

		// Define configurações de acordo com o controle
		lPr_TitPnl := lCt_MrkAll
		lPr_TitInd := lCt_MrkAll
		lPr_Totalz := lCt_MrkAll
		lPr_Tema   := lCt_MrkAll
		lPr_LastV  := lCt_MrkAll
		lPr_Calc   := lCt_MrkAll
		lPr_Anima  := lCt_MrkAll
	Else
		// Define controle de acordo com as configurações disponíveis
		If lPr_TitPnl
			nQuantMark++
		EndIf
		If lPr_TitInd
			nQuantMark++
		EndIf
		If lPr_Totalz
			nQuantMark++
		EndIf
		If lPr_Tema
			nQuantMark++
		EndIf
		If lPr_LastV
			nQuantMark++
		EndIf
		If lPr_Calc
			nQuantMark++
		EndIf
		If lPr_Anima
			nQuantMark++
		EndIf

		// Se todos eles estiverem marcados, o botão deve ficar como "Todos Marcados" e habilitar a "Desmarcação"
		If nQuantMark == nPr_Quanti
			lCt_MrkAll := .T.
		Else // Se nem todos estiverem marcados, então o botão deve ficar como "Todos Desmarcados" e habilitar a "Marcação"
			lCt_MrkAll := .F.
		EndIf
	EndIf

	// Define o botão
	If lCt_MrkAll
		// Se estiver marcado, pode dermarcar
		oBtn:SetText(STR0059) //"Desmarcar Todas"
		oBtn:cTooltip := STR0060 //"Desmarcar todas as configurações"
	Else
		// Se estiver desmarcado, pode marcar
		oBtn:SetText(STR0061) //"Marcar Todas"
		oBtn:cTooltip := STR0062 //"Marcar todas as configurações"
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SaveConfig
Método que Salva as Configurações do Painel.

@author Wagner Sobral de Lacerda
@since 02/05/2012

@return lReturn
/*/
//---------------------------------------------------------------------
Method SaveConfig() Class TNGPanel

	// Variáveis da Classe
	Local nMode := ::GetMode()

	// Variável do Retorno
	Local lReturn := .F.

	// Apenas pode-se usufruir das configurações personalizadas em modo de Consulta e se a classe estiver permitindo o seu uso
	If nMode == _nModeQry .And. ::lCanConfig
		// Inicializa o Arquivo de Configuração (caso não exista)
		lReturn := fDefineCfg(Self, 1)
	EndIf

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} LoadConfig
Método que Carrega as Configurações do Painel.

@author Wagner Sobral de Lacerda
@since 02/05/2012

@return lReturn
/*/
//---------------------------------------------------------------------
Method LoadConfig() Class TNGPanel

	// Variáveis da Classe
	Local aFieldInfo := aClone( ::GetFldInfo() )
	Local nMode := ::GetMode()

	// Variável das configurações carregadas
	Local aLoad := {}
	Local nX := 0, nScan := 0

	// Variáveis auxliares
	Local cAuxTitle := ""

	Local aColors  := {}
	Local nClrText := 0
	Local nClrBack := 0

	// Variável do Retorno
	Local lReturn := .F.

	// Apenas pode carregar configurações se a Classe estiver Ativada
	If !::lActivated
		Return .F.
	EndIf

	// Apenas pode-se usufruir das configurações personalizadas em modo de Consulta e se a classe estiver permitindo o seu uso
	If nMode == _nModeQry .And. ::lCanConfig
		// Inicializa o Arquivo de Configuração (caso não exista)
		aLoad := aClone( fDefineCfg(Self, 2) )
	EndIf

	//------------------------------
	// Carrega Configurações
	//------------------------------
	If Len(aLoad) > 0
		// Recria o Array de configurações
		::aConfig := Array(__nCfgQtde)
		::aConfig[__nCfgInte] := aLoad[__nCfgInte]
		::aConfig[__nCfgTPnl] := aLoad[__nCfgTPnl]
		::aConfig[__nCfgTInd] := aLoad[__nCfgTInd]
		::aConfig[__nCfgTota] := aLoad[__nCfgTota]
		::aConfig[__nCfgThem] := aLoad[__nCfgThem]
		::aConfig[__nCfgLast] := aLoad[__nCfgLast]
		::aConfig[__nCfgCalc] := aLoad[__nCfgCalc]
		::aConfig[__nCfgAnim] := aLoad[__nCfgAnim]
		::aConfig[__nCfgInds] := aClone( aLoad[__nCfgInds] )
		::aConfig[__nCfgPars] := aClone( aLoad[__nCfgPars] )
		::aConfig[__nCfgLoad] := aClone( aLoad[__nCfgLoad] )
			// Filial
			::aConfig[__nCfgLoad][1] := If(ValType(::aConfig[__nCfgLoad][1]) <> "U", ::aConfig[__nCfgLoad][1], "")
			::aConfig[__nCfgLoad][1] := PADR(::aConfig[__nCfgLoad][1], aFieldInfo[__nInfFili][__nFldSize], " ")
			// Código do Painel
			::aConfig[__nCfgLoad][2] := If(ValType(::aConfig[__nCfgLoad][2]) <> "U", ::aConfig[__nCfgLoad][2], "")
			::aConfig[__nCfgLoad][2] := PADR(::aConfig[__nCfgLoad][2], aFieldInfo[__nInfCodi][__nFldSize], " ")
			// Módulo
			::aConfig[__nCfgLoad][3] := If(ValType(::aConfig[__nCfgLoad][3]) <> "U", ::aConfig[__nCfgLoad][3], "")
			::aConfig[__nCfgLoad][3] := PADR(::aConfig[__nCfgLoad][3], aFieldInfo[__nInfMdCd][__nFldSize], " ")

		lReturn := .T.
	Else
		// Cria um Default para as configurações
		fCfgDefault(Self)
		lReturn := .F.
	EndIf

	//--------------------
	// Atualiza o Painel
	//--------------------
	// Define o Painel de Indicadores caso não esteja carregado
	If Empty(::cCodPanel)
		::cCodFilia := ::aConfig[__nCfgLoad][1] // Filial
		::cCodPanel := ::aConfig[__nCfgLoad][2] // Código do Painel
		::cCodModul := ::aConfig[__nCfgLoad][3] // Módulo
	EndIf

	// Indica as cores utilizada no Painel (de acordo com o Tema)
	aColors  := If(::aConfig[__nCfgThem], aClone( NGCOLOR() ), {CLR_BLACK, CLR_WHITE}) // Mostra as Bordas?
	nClrText := aColors[1]
	nClrBack := aColors[2]

	// Mostra o Título Painel de Indicadores
	If ::aConfig[__nCfgTPnl]
		// Título
		cAuxTitle := AllTrim(::aInfo[__nInfNome])
		If nMode == _nModeEdt
			cAuxTitle += ( If(!Empty(cAuxTitle), " - ", "") + STR0063 ) //"Edição"
		EndIf

		::oTitlePnl:SetText(cAuxTitle/*cText*/)
		::oTitlePnl:SetColor(nClrText/*nClrFore*/, nClrBack/*nClrBack*/)
		::oTitlePnl:Show()
	Else
		::oTitlePnl:Hide()
	EndIf
	// Informações do Cadastro
	If ::GetFixedCad()
		::ShowCad(1) // Atualiza o Cadastro
	EndIf

	// Define as Configurações se o Painel já estiver criado
	If ::IsCreated()
		// Atualiza os Valores dos Indicadores
		For nX := 1 To Len(::aConfig[__nCfgInds])
			nScan := aScan(::aIndDef, {|x| AllTrim(x[__nIndForm]) == AllTrim(::aConfig[__nCfgInds][nX][1]) })
			If nScan > 0
				::aIndDef[nScan][__nIndValu] := ::aConfig[__nCfgInds][nX][2]
			EndIf
		Next nX

		// Atualiza os Objetos do Painel
		If ::GetGraphic()
			For nX := 1 To Len(::aIndDef)
				// Título
				If ::aConfig[__nCfgTInd]
					::aIndDef[nX][__nIndTitu]:Show()
				Else
					::aIndDef[nX][__nIndTitu]:Hide()
				EndIf
				::aIndDef[nX][__nIndTitu]:SetColor(nClrText/*nClrFore*/, nClrBack/*nClrBack*/)

				// Bordas
				::aIndDef[nX][__nIndTopo]:SetColor(nClrText/*nClrFore*/, nClrBack/*nClrBack*/) // Topo
				::aIndDef[nX][__nIndEsqu]:SetColor(nClrText/*nClrFore*/, nClrBack/*nClrBack*/) // Esquerda
				::aIndDef[nX][__nIndDire]:SetColor(nClrText/*nClrFore*/, nClrBack/*nClrBack*/) // Direita
				::aIndDef[nX][__nIndBaix]:SetColor(nClrText/*nClrFore*/, nClrBack/*nClrBack*/) // Baixo

				::aIndDef[nX][__nIndGraf]:oFooter:SetColor(nClrText/*nClrFore*/, nClrBack/*nClrBack*/) // Cor do rodapé do Indicador Gráfico
			Next nInd
		EndIf
	EndIf

	// Define os Parâmetros
	For nX := 1 To Len(::aConfig[__nCfgPars])
		nScan := aScan(::aParams, {|x| AllTrim(x[__nParCodi]) == AllTrim(::aConfig[__nCfgPars][nX][1]) })
		If nScan > 0
			::aParams[nScan][__nParCont] := fConvPar(::aConfig[__nCfgPars][nX][2], ::aParams[nScan][__nParTipo], ::aParams[nScan][__nParTama], ::aParams[nScan][__nParDeci], ::aParams[nScan][__nParCodi])
		EndIf
	Next nX

	// Mostra os Totalizadores
	If ::aConfig[__nCfgTota] .And. ::IsCreated()
		::SetTotal() // Define os totalizadores
		::oTotalPnl:Show()
	Else
		::oTotalPnl:Hide()
	EndIf

	// Define a Interface
	If lReturn
		If ::aConfig[__nCfgInte] == "1" // Gráfica
			::SetGraphic(.F.)
		ElseIf ::aConfig[__nCfgInte] == "2" // Lista
			::SetList(.F.)
		EndIf
	EndIf

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} fCfgDefault
Funcção auxiliar que cria um conteúdo padrão para o array de
Configurações do Painel de Indicadores.

@author Wagner Sobral de Lacerda
@since 02/05/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fCfgDefault(oClassPanel)

	// Variáveis da classe
	Local aFieldInfo := aClone( oClassPanel:GetFldInfo() )

	//--------------------
	// Cria Default
	//--------------------
	oClassPanel:aConfig := Array(__nCfgQtde)
	oClassPanel:aConfig[__nCfgInte] := "1" // 1=Gráfica
	oClassPanel:aConfig[__nCfgTPnl] := .T.
	oClassPanel:aConfig[__nCfgTInd] := .F.
	oClassPanel:aConfig[__nCfgTota] := .F.
	oClassPanel:aConfig[__nCfgThem] := .F.
	oClassPanel:aConfig[__nCfgLast] := .T.
	oClassPanel:aConfig[__nCfgCalc] := .F.
	oClassPanel:aConfig[__nCfgAnim] := .F.
	oClassPanel:aConfig[__nCfgInds] := {}
	oClassPanel:aConfig[__nCfgPars] := {}
	oClassPanel:aConfig[__nCfgLoad] := {	Space(aFieldInfo[__nInfFili][__nFldSize]), ; // Filial
											Space(aFieldInfo[__nInfCodi][__nFldSize]), ; // Código do Painel
											Space(aFieldInfo[__nInfMdCd][__nFldSize]) } // Módulo

Return .T.

/*/
############################################################################################
##                                                                                        ##
## MÉTODOS: CONFIGURAÇÃO DE PARÂMETROS                                                    ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} Params
Método que apresenta uma tela de configuração dos Parâmetros do Painel.

@author Wagner Sobral de Lacerda
@since 03/05/2012

@return .T.
/*/
//---------------------------------------------------------------------
Method Params() Class TNGPanel

	// Variáveis da janela
	Local oDlgPar
	Local cDlgPar  := OemToAnsi(STR0064) //"Parâmetros do Painel"
	Local lDlgPar  := .F.
	Local lRPORel17:= GetRPORelease() <= '12.1.017'
	Local oPnlPar

	Local oPnlCabec
	Local oScroll
	Local oTmpSay, oTmpGet
	Local oPnlBtn
	Local nSizeBtn := 012

	Local oFntNorm13 := TFont():New(, , 13, , .F.)

	Local nLargura := 450
	Local nAltura  := 0
	Local nMaxAlt  := 450
	Local nMinAlt  := 150
	Local nCalcAlt := ( Len(::aParams) * 45 )// Altura calculada de acordo com a quantidade de parâmetros

	Local nPosLin, nLinIni
	Local nPosCol

	// Variável auxiliar do Painel preto para armazenar o seu estado inicial (utilizado para: se já estava visível, então a rotina/função anterior é responsável por escondâ-lo também)
	Local lBlackVisi := ::IsBlackPnl()

	// Variáveis da montagem dos objetos
	Local cAuxDescri := ""
	Local cAuxSay    := ""
	Local cAuxSetGet := ""
	Local cAuxPictur := ""
	Local cAuxF3     := ""
	Local cAuxHelp   := ""

	Local aAuxItens := {}
	Local cAuxClick := ""

	Local cCalcSize, nCalcSize
	Local nParam

	// Variáveis de Controle dos dados Informados em tela
	Private aGetParams := Array( Len(::aParams) )
	Private aTotParams := aClone(::aParams)

	// Mostra Painel
	If !lBlackVisi
		::BlackPnl(.T.)
	EndIf

	//----------
	// Monta
	//----------
	nAltura := If(nCalcAlt < nMinAlt, nMinAlt, If(nCalcAlt > nMaxAlt, nMaxAlt, nCalcAlt))

	lDlgPar := .F.
	DEFINE MSDIALOG oDlgPar TITLE cDlgPar FROM 0,0 TO nAltura,nLargura OF ::oDlgOwner STYLE WS_POPUPWINDOW PIXEL

		// Painel principal do Dialog
		oPnlPar := TPanel():New(01, 01, , oDlgPar, , , , CLR_BLACK, CLR_WHITE, 100, 008)
		oPnlPar:Align := CONTROL_ALIGN_ALLCLIENT

			// Painel do Cabeçalho (para o botão 'X' - Fechar)
			oPnlCabec := TPanel():New(01, 01, , oPnlPar, , , , CLR_BLACK, CLR_WHITE, 100, 008)
			oPnlCabec:Align := CONTROL_ALIGN_TOP

				// Botão: Fechar
				oTmpButtn := TBtnBmp2():New(001, 001, 20, 20, "BR_CANCEL", , , , {|| lDlgPar := .F., oDlgPar:End() }, oPnlCabec, OemToAnsi(STR0015)) //"Fechar"
				oTmpButtn:lCanGotFocus := .F.
				oTmpButtn:Align := CONTROL_ALIGN_RIGHT

			nLinIni := 008

			// Cria um Group Box para conter os parâmetros
			oTmpGroup := TGroup():New(nLinIni+005, 005, (oPnlPar:nClientHeight * 0.50)-015, (oPnlPar:nClientWidth * 0.50)-005, cDlgPar, oPnlPar, , , .T.)

			// Scroll para os parâmetros
			oScroll := TScrollBox():New(oPnlPar, nLinIni+015, 015, (oPnlPar:nClientHeight * 0.50)-045, (oPnlPar:nClientWidth * 0.50)-025, .T., .F., .F.)
			oScroll:nClrPane := CLR_WHITE
			oScroll:CoorsUpdate()

				nPosLin := 005
				nPosCol := 005

				// Monta os parâmetros
				For nParam := 1 To Len(::aParams)

					cAuxDescri := StrTran(::aParams[nParam][__nParDesc], "'", "")
					cAuxDescri := StrTran(cAuxDescri, '"', "")

					//----------
					// Título
					//----------
					cAuxSay := "{|| '" + cAuxDescri + "' }"

					If !lRPORel17 .And. Len(::aParams[nParam]) > 12 // Caso seja versão maior que 12.1.17
						oTmpSay := TSay():New((nPosLin+001), nPosCol, &(cAuxSay), oScroll, , oFntNorm13, , ;
											, ,.T., IIf(::aParams[nParam][__nParObri], CLR_BLUE, CLR_BLACK ), CLR_WHITE, 150, 015)
					Else
						oTmpSay := TSay():New((nPosLin+001), nPosCol, &(cAuxSay), oScroll, , oFntNorm13, , ;
											, ,.T., CLR_BLACK, CLR_WHITE, 150, 015)

					EndIf
					//----------
					// Get
					//----------
					nCalcSize := 080 // Tamanho fixo para todos os campos
					cCalcSize := cValToChar(nCalcSize)

					aGetParams[nParam] := ::aParams[nParam][__nParCont]

					cAuxSetGet := "{|u| If(PCount() > 0, aGetParams[" + cValToChar(nParam) + "] := u, aGetParams[" + cValToChar(nParam) + "])}"
					cAuxPictur := "'" + ::aParams[nParam][__nParPict] + "'"
					cAuxF3     := "'" + ::aParams[nParam][__nParCons] + "'"
					cAuxHelp   := "{|| ShowHelpCpo('" + ::aParams[nParam][__nParCodi] + "', {'" + cAuxDescri + "'}, 2, {}, 2) } "

					If ::aParams[nParam][__nParTipo] == "3" // Lógico
						cAuxSetGet := "{|| aGetParams[" + cValToChar(nParam) + "] }"
						cAuxClick  := "{|| aGetParams[" + cValToChar(nParam) + "] := !aGetParams[" + cValToChar(nParam) + "] }"

						oTmpGet := TCheckBox():New(nPosLin, ((oScroll:nClientWidth*0.50)-015-nCalcSize), "", &(cAuxSetGet), oScroll, &(cCalcSize), 008, , &(cAuxClick), oFntNorm13, , , , , .T., , ,)

					ElseIf ::aParams[nParam][__nParTipo] == "6" // Lista de Opções
						aAuxItens := StrTokArr( AllTrim(::aParams[nParam][__nParOpcs]), ";")

						oTmpGet := TComboBox():New(nPosLin, ((oScroll:nClientWidth*0.50)-015-nCalcSize), &(cAuxSetGet), aAuxItens, &(cCalcSize), 008, oScroll, , /*bChange*/, /*bValid*/, , , .T./*lPixel*/, , , , {|| .T. }/*bWhen*/)

					Else
						oTmpGet := TGet():New(nPosLin, ((oScroll:nClientWidth*0.50)-015-nCalcSize), &(cAuxSetGet), oScroll, &(cCalcSize), 008, &(cAuxPictur), ;
												{|| .T. }, CLR_BLACK, CLR_WHITE, oFntNorm13, ;
								 				.F., , .T./*lPixel*/, , .F., {|| .T. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., &(cAuxF3), "", , , , .T./*lHasButton*/)



				 	EndIf
					oTmpGet:bHelp := &(cAuxHelp)

					// Incrementa a Linha
					nPosLin += 015

				Next nParam

			// Painel auxiliar para deixar um espaço entre o Painel de botões e a borda inferior da janela
			oTmpPnl := TPanel():New(01, 01, , oPnlPar, , , , CLR_BLACK, CLR_WHITE, 100, (::nSpacBtnBor/2))
			oTmpPnl:Align := CONTROL_ALIGN_BOTTOM

			// Painel dos botões
			oPnlBtn := TPanel():New(01, 01, , oPnlPar, , , , CLR_BLACK, CLR_WHITE, 100, ::nSizeBtnBar)
			oPnlBtn:Align := CONTROL_ALIGN_BOTTOM

				// Painel auxiliar para deixar um espaço entre o botão e a borda da direita da janela
				oTmpPnl := TPanel():New(01, 01, , oPnlBtn, , , , CLR_BLACK, CLR_WHITE, ::nSpacBtnBor, 100)
				oTmpPnl:Align := CONTROL_ALIGN_RIGHT

				// Botão: Confirmar
				oTmpButtn := TButton():New(001, 001, STR0015, oPnlBtn, {|| lDlgPar := .F., oDlgPar:End() },; //"Fechar"
												030, 012, , , .F., .T., .F., , .F., , , .F.)
				fSetCSS(3, oTmpButtn) // Seta o CSS do botão
				oTmpButtn:lCanGotFocus := .F.
				oTmpButtn:cTooltip := STR0015 //"Fechar"
				oTmpButtn:Align := CONTROL_ALIGN_RIGHT

				// Painel auxiliar para deixar um espaço entre os botões
				oTmpPnl := TPanel():New(01, 01, , oPnlBtn, , , , CLR_BLACK, CLR_WHITE, ::nSpacBtnBtn, 100)
				oTmpPnl:Align := CONTROL_ALIGN_RIGHT

				// Botão: Fechar
				If !lRPORel17 .And. Len(::aParams[1]) > 12 // Caso seja versão maior que 12.1.17
					oTmpButtn := TButton():New(001, 001, STR0065, oPnlBtn, {|| lDlgPar := tngPaValid(), IIF( lDlgPar, oDlgPar:End(), lDlgPar := .F.) },; //"Definir"
												040, 012, , , .F., .T., .F., , .F., , , .F.)
				Else
					oTmpButtn := TButton():New(001, 001, STR0065, oPnlBtn, {|| lDlgPar := .T., oDlgPar:End() },; //"Definir"
												040, 012, , , .F., .T., .F., , .F., , , .F.)
				EndIf

				fSetCSS(4, oTmpButtn) // Seta o CSS do botão
				oTmpButtn:lCanGotFocus := .F.
				oTmpButtn:cTooltip := STR0066 //"Definir os Parâmetros selecionados"
				oTmpButtn:Align := CONTROL_ALIGN_RIGHT

	ACTIVATE MSDIALOG oDlgPar CENTERED

	// Se confirmou
	If lDlgPar
		// Atualiza conteúdo dos parâmetros
		For nParam := 1 To Len(::aParams)
			::aParams[nParam][__nParCont] := aGetParams[nParam]
		Next nParam
	EndIf

	// Esconde Painel
	If !lBlackVisi
		::BlackPnl(.F.)
	EndIf

Return .T.

/*/
############################################################################################
##                                                                                        ##
## MÉTODOS: CALCULAR OS INDICADORES                                                       ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} Calculate
Método que executa o Cálculo dos Indicadores do Painel.

@author Wagner Sobral de Lacerda
@since 04/05/2012

@param lMsgRun
	Indica se deve mostrar uma Mensagem de "Em Execução" * Opcional
	   .T. - Mostra a mensgagem
	   .F. - Não mostra
	Default: .T.
@param lForceCalc
	Indica se deve forçar o cálcula, desconsiderando as configurações que
	habilitam ou desabiliam novos cálculos * Opcional
	   .T. - Força o cálculo
	   .F. - Não força, utiliza configurações
	Default: .F.

@return .T.
/*/
//---------------------------------------------------------------------
Method Calculate(lMsgRun, lForceCalc) Class TNGPanel

	// Variáveis de Controle para o Cálculo
	Local aParams := {}
	Local nParam

	Local nValor
	Local nInd

	Local oNGKPI

	Local lRPORel17:= GetRPORelease() <= '12.1.017' // Determina a release utilizada.

	// Defaults
	Default lMsgRun    := .T.
	Default lForceCalc := .F.

	If !lRPORel17
		oNGKPI  := NGKPI():New()
	EndIf

	// Verifica se pode Calcular
	If ::aConfig[__nCfgCalc] .Or. lForceCalc
		// Mostra a mensagem de em execução (chamada RECURSIVA)
		If lMsgRun
			MsgRun(STR0067, STR0021, {|| ::Calculate(.F., lForceCalc) }) //"Calculando os Indicadores..." ## "Por favor, aguarde..."
		Else // Senão, executa o cálculo
			//--------------------
			// Parâmetros
			//--------------------
			For nParam := 1 To Len(::aParams)
				aAdd(aParams, {AllTrim(::aParams[nParam][__nParCodi]), ::aParams[nParam][__nParCont]})
			Next nParam

			//--------------------
			// Calcula
			//--------------------
			If !lRPORel17
				// Determina a operação selecionada.
				oNGKPI:setOperation(4)

				// Cálculo do Indicador
				oNGKPI:setIndParams(aParams) // Carrega os valores para a classe

				For nInd := 1 To Len(::aIndDef)

					nValor := oNGKPI:getKPI(::aIndDef[nInd][__nIndForm]) // Executa o cálculo do indicador

					If ValType(nValor) == "N"
						::aIndDef[nInd][__nIndValu] := nValor
					ElseIf ValType(nValor) == "C"
						::aIndDef[nInd][__nIndValu] := HtoN(nValor)
					ElseIf nValor == Nil
						oNGKPI:showHelp()
						nValor := 0
					EndIf

				Next nInd

				// Elimina o objeto da memória.
				oNGKPI:Free()
			Else
				For nInd := 1 To Len(::aIndDef)
					nValor := NGIndAuto(Val(::cCodModul), ::aIndDef[nInd][__nIndForm], aParams, .F.)
					If ValType(nValor) == "N"
						::aIndDef[nInd][__nIndValu] := nValor
					EndIf
				Next nInd
			EndIf

			//--------------------
			// Atualiza
			//--------------------
			::Charge()

			// Se estiver habilitado para armazenar o último valor calculado, então salva
			If ::aConfig[__nCfgLast]
				::SaveConfig()
			EndIf
		EndIf
	EndIf

Return .T.

/*/
############################################################################################
##                                                                                        ##
## MÉTODOS: CARREGAR OS INDICADORES                                                       ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} Charge
Carrega os Valores nos Indicadores (com ou sem animação, dependendo da
configuração do usuário)

@author Wagner Sobral de Lacerda
@since 03/05/2012

@param nCharge
	Indica se deve carregar com: * Opcional
	   0 - Animação ou Set, dependendo do parâmetro
	   1 - Forçar Animação (desconsiderar parÂmetro)
	   2 - Forçar Set (desconsiderar parÂmetro)

@return .T.
/*/
//---------------------------------------------------------------------
Method Charge(nCharge) Class TNGPanel

	// Variáveis de Controle para a Animação
	Local aAnimacao  := {}, aValores := {}
	Local nAnimacao  := 0
	Local nValAtual  := 0 , nGetVal  := 0, nMaiorVal := 0, nMenorVal := 0
	Local nIncrement := 0
	Local nPassos := 0, nRazao := 0
	Local nInd := 0, nLen := 0

	// Variáveis de Controle para as Listas
	Local aArray := {}
	Local nList := 0, nScan := 0

	Local lAnimando := .F., lSetVal := .F.

	// Variáveis de Controle de Processamento (Se estiver muito demorada, a animação deve ser suspensa)
	Local cTimeInit := ""
	Local cTimeElap := ""

	// Defaults
	Default nCharge := 0

	//----------
	// Executa
	//----------
	// Apenas se for em modo de apresentação Gráfico
	If ::GetGraphic()
		//------------------------------
		// Modo Gráfico
		//------------------------------
		If ( nCharge == 0 .And. ::aConfig[__nCfgAnim] ) .Or. nCharge == 1

			//------------------------------
			// Anima do mínimo para o atual
			//------------------------------
			// Busca os Valorese calcula um incremento para a animação de cada indicador
			aAnimacao := Array( Len(::aIndDef), 2 )
			nPassos   := 100 - ( 20 * Int( ( Len(::aIndDef) / 3 ) ) )
			// 100 é o ideal, mas para cada 3 Indicadores, diminui a quantidade de passos em 10
			If nPassos < 10 // Mínimo de passos
				nPassos := 10
			EndIf
			For nInd := 1 To Len(::aIndDef)
				// Recebe os valores do Indicador
				aValores := aClone( ::aIndDef[nInd][__nIndGraf]:GetVals() )
				nLen := Len(aValores)

				// Calcula incremento
				aAnimacao[nInd][1] := ( aValores[nLen] / nPassos ) // Incremente até o valor Máximo
				aAnimacao[nInd][2] := ( ::aIndDef[nInd][__nIndValu] / nPassos ) // Incremento até o valor a setar, utiliza caso ultrapasse o máximo
			Next nInd

			//--------------------
			// Animação (1 = Decrescente; 2 = Crescente)
			//--------------------
			cTimeInit := Time()
			For nAnimacao := 1 To 2
				lAnimando := .T.
				While lAnimando

					// Inicia indicando que nenhum valor foi setado
					lSetVal := .F.

					For nInd := 1 To Len(::aIndDef)
						nGetVal    := ::aIndDef[nInd][__nIndGraf]:GetValue() // Valor Atual
						nMenorVal  := ::aIndDef[nInd][__nIndGraf]:GetVals()[1] // Valor Mínimo
						nMaiorVal  := aTail(::aIndDef[nInd][__nIndGraf]:GetVals()) // Valor Máximo

						// Define Incremento
						nIncrement := If(nGetVal < nMaiorVal, aAnimacao[nInd][1], aAnimacao[nInd][2]) // Incremento atual

						// Tipo de Animação
						If nAnimacao == 1 // Decrescente

							// Decremento é fixo
							nIncrement := ( nIncrement * -3 ) // 3 vezes mais rápido

							// Inicia o Valor a partir do máximo
							If nGetVal > nMaiorVal
								::aIndDef[nInd][__nIndGraf]:SetValue( nMaiorVal )
								nGetVal := nMaiorVal
							EndIf
							// Executa Decremento
							If (nGetVal + nIncrement) > nMenorVal
								::aIndDef[nInd][__nIndGraf]:SetValue( (nGetVal + nIncrement) )
								lSetVal := .T. // Indica que setou um valor
							Else
								If nGetVal <> nMenorVal
									::aIndDef[nInd][__nIndGraf]:SetValue( nMenorVal )
								EndIf
							EndIf

						ElseIf nAnimacao == 2 // Crescente

							// Valor Atual a Setar
							nValAtual := ::aIndDef[nInd][__nIndValu]

							// Se o valor estiver quase se aproximando do que deve ser, então começa a "frear" o processo
							If nGetVal > 0
								nRazao := ( nValAtual / nGetVal )
								If nRazao < 1.2
									nIncrement := ( nIncrement * 0.20 )
								ElseIf nRazao < 1.5
									nIncrement := ( nIncrement * 0.50 )
								EndIf
							EndIf

							// Executa Incremento
							If (nGetVal + nIncrement) <= nValAtual
								::aIndDef[nInd][__nIndGraf]:SetValue( (nGetVal + nIncrement) )
								lSetVal := .T. // Indica que setou um valor
							Else
								If nGetVal <> nValAtual
									::aIndDef[nInd][__nIndGraf]:SetValue( nValAtual )
								EndIf
							EndIf

						EndIf
					Next nInd

					// Recebe o Tempo decorrido desde o Início da Animação
					cTimeElap := ElapTime(cTimeInit, Time())
					// Verifica se ainda deve animar
					If !lSetVal .Or. cTimeElap > "00:00:03" // Se não setou nenhum valor OU se estiver demorando mais do que 3 segundos, encerra a animação
						lAnimando := .F.
					EndIf

					// Atualiza
					ProcessMessages()
				End
			Next nAnimacao

			// Tem a certeza de que os indicadores estão com os valores corretos e Atualiza a posição que indica o Valor do Indicador
			For nInd := 1 To Len(::aIndDef)
				nGetVal := ::aIndDef[nInd][__nIndGraf]:GetValue()

				If nGetVal <> ::aIndDef[nInd][__nIndValu]
					::aIndDef[nInd][__nIndGraf]:SetValue( ::aIndDef[nInd][__nIndValu] )
				EndIf
			Next nInd
			ProcessMessages()

		ElseIf ( nCharge == 0 .And. !::aConfig[__nCfgAnim] ) .Or. nCharge == 2

			//------------------------------
			// Apenas seta os valores
			//------------------------------
			For nInd := 1 To Len(::aIndDef)
				::aIndDef[nInd][__nIndGraf]:SetValue( ::aIndDef[nInd][__nIndValu] )
			Next nInd

		EndIf
	ElseIf ::GetList()
		//------------------------------
		// Modo Lista
		//------------------------------

		// Percorre as Listas (Folders)
		For nList := 1 To Len(::aLists)
			// Recebe o Array
			aArray := aClone( ::aLists[nList]:Data():GetArray() )

			// Busca os Indicadores
			For nInd := 1 To Len(aArray)
				nScan := aScan(::aIndDef, {|x| x[__nIndForm] == aArray[nInd][1] })
				If nScan > 0
					aArray[nInd][3] := ::aIndDef[nScan][__nIndValu]
				EndIf
			Next nInd

			// Atualiza
			::aLists[nList]:SetArray(aArray)
			::aLists[nList]:Refresh()
		Next nList

	EndIf

Return .T.

/*/
############################################################################################
##                                                                                        ##
## MÉTODOS: RELATÓRIO                                                                     ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} Print
Método que imprime o Painel de Indicadores.

@author Wagner Sobral de Lacerda
@since 03/05/2012

@return .T./.F.
/*/
//---------------------------------------------------------------------
Method Print() Class TNGPanel

	// Variáveis do Relatório
	Local aGetVal := {}
	Local xGetVal := Nil
	Local cTemp := ""
	Local nX := 0, nY := 0, nScan := 0, nAT := 0

	Local cTempPath  := GetTempPath()
	Local cTmpImg    := "TempTNGIndicador"
	Local cTmpExt    := ".PNG"
	Local cTmpBitmap := ""
	Local nColAux    := 0
	Local nQtdAtuLin := 0
	Local nQtdPorLin := 0

	Private oPrint
	Private nLinha   := 080
	Private nColuna  := 100
	Private nPagina  := 0
	Private nSizeImg := 100

	Private oFnt12B := TFont():New(, , 12, , .T., , , , .F., .F.)
	Private oFnt10N := TFont():New(, , 10, , .F., , , , .F., .F.)
	Private oFnt08N := TFont():New(, , 08, , .F., , , , .F., .F.)

	Private aInfo := aClone( ::GetInfo() )
	Private cClassCabec := ""

	// Se não possuir interface, então não pode executar
	If !fHasInterface()
		Return .F.
	EndIf

	//----------
	// Impressão
	//----------

	// Instancia a classe do Relatório
	oPrint := TMSPrinter():New(STR0068 + " " + ::cCodPanel) //"Relatório do Painel de Indicadores:"
	oPrint:SetPortrait() // define Retrato
	oPrint:SetPaperSize(9) // A4

	//--- Cabeçalho: Informações Gerais
	fPrintCabec()

	//--- Parâmetros
	oPrint:Say(nLinha, nColuna, STR0047, oFnt12B) //"Parâmetros"
	For nX := 1 To Len(::aParams)
		fSomaLinha()
		xGetVal := fConvPar(::aParams[nX][__nParCont], "C", ::aParams[nX][__nParTama], ::aParams[nX][__nParDeci], ::aParams[nX][__nParCodi])
		If ::aParams[nX][__nParTipo] == "4" // Data
			xGetVal := DTOC(STOD(xGetVal))
		ElseIf ::aParams[nX][__nParTipo] == "6" // Lista de Opções
			aGetVal := StrTokArr(::aParams[nX][__nParOpcs], ";")
			For nScan := 1 To Len(aGetVal)
				nAT := AT("=", aGetVal[nScan])
				If nAT > 0
					cTemp := SubStr(aGetVal[nScan],1,(nAT-1))
					If cTemp == xGetVal
						xGetVal := SubStr(aGetVal[nScan],(nAT+1))
					EndIf
				EndIf
			Next nScan
		EndIf
		oPrint:Say(nLinha, nColuna+100, AllTrim(::aParams[nX][__nParDesc]) + ": " + xGetVal, oFnt10N)
	Next nX

	//--- Indicadores
	nSizeImg := 900 // Quantidade de linhas utilizadas pela imagem

	nQtdAtuLin := 9
	nQtdPorLin := 2
	For nX := 1 To Len(::aClassInds)
		cClassCabec := STR0069 + " " + ::aClassInds[nX][__nCInNome] // Cabeçalho //"Indicadores da Classificação:"
		fSomaLinha(9999) // Força uma Quebra de Página

		nColAux := nColuna
		For nY := 1 To Len(::aClassInds[nX][3])
			nScan := aScan(::aIndDef, {|x| AllTrim(x[__nIndForm]) == AllTrim(::aClassInds[nX][__nCInInds][nY][__nCInFoCd]) })
			If nScan > 0
				// Valor do Indicador
				xGetVal := ::aIndDef[nScan][__nIndGraf]:GetValue(.T.)

				// Imagem Temporária
				cTmpBitmap := Upper( cTempPath + cTmpImg + cValToChar(nX) + cValToChar(nY) + cTmpExt )
				If File(cTmpBitmap)
					FErase(cTmpBitmap)
				EndIf

				Self:aIndDef[nScan][__nIndGraf]:oTPPanel:SaveToPng(	0, 0, Self:aIndDef[nScan][__nIndGraf]:oTPPanel:nClientWidth, Self:aIndDef[nScan][__nIndGraf]:oTPPanel:nClientHeight, cTmpBitmap ) //cFileTarget

				//Para a thread corrente até salvar todas as imagens.
				While !File(cTmpBitmap)
					Sleep( 1000 )
				End While

				// Imprime
				nQtdAtuLin++
				nColAux += (nSizeImg+200)
				If nQtdAtuLin > nQtdPorLin
					fSomaLinha()

					nQtdAtuLin := 1
					nColAux    := nColuna
				EndIf
				oPrint:Say(nLinha, nColAux+100, ::aClassInds[nX][__nCInInds][nY][__nCInFoNo], oFnt12B, nSizeImg, , , 0)
				oPrint:SayBitMap(nLinha+060, nColAux+050, Upper( cTmpBitmap ), (nSizeImg-100), (nSizeImg-100))
				If nQtdAtuLin == nQtdPorLin .And. (nY+1) <= Len(::aClassInds[nX][__nCInInds]) // Se for o último da linha e houver mais ainda a imprimir
					fSomaLinha(nSizeImg)
				EndIf
			EndIf
		Next nY
	Next nX

	//--- Finaliza Impressão
	oPrint:EndPage()
	oPrint:Preview()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fPrintCabec
Funcção auxiliar para Imprimir o Cabeçalho no Relatório.

@author Wagner Sobral de Lacerda
@since 07/05/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fPrintCabec()

	// Logo do sistema
	Local cLogo := NGLOCLOGO()

	// Inicia a Página
	oPrint:StartPage()
	nLinha := 100

	//----------
	// Cabeçalho
	//----------
	oPrint:Line(nLinha, nColuna, nLinha, (oPrint:nHorzRes()-nColuna))
	fSomaLinha()
	If File(cLogo)
		oPrint:SayBitMap(nLinha, nColuna, cLogo, 335, 185)
	EndIf
	oPrint:Say(nLinha, (oPrint:nHorzRes()-400), STR0070 + " " + DTOC(dDataBase), oFnt08N) //"Data:"
	oPrint:Say(nLinha+060, (oPrint:nHorzRes()-400), STR0071 + " " + SubStr(Time(),1,5), oFnt08N) //"Hora:"

	oPrint:Say(nLinha, nColuna+400, STR0072 + " " + aInfo[__nInfCodi] + " - " + aInfo[__nInfNome], oFnt12B) //"Painel de Indicadores:"
	fSomaLinha()
	oPrint:Say(nLinha, nColuna+400, STR0073 + " " + aInfo[__nInfFili] + " - " + FWFilialName(, aInfo[__nInfFili], 1), oFnt10N) //"Filial:"
	fSomaLinha()
	oPrint:Say(nLinha, nColuna+400, STR0074 + " " + aInfo[__nInfUsCd] + " - " + aInfo[__nInfUsNo], oFnt10N) //"Usuário:"
	oPrint:Say(nLinha, nColuna+1400, STR0075 + " " + aInfo[__nInfMdNo], oFnt10N) //"Módulo:"
	fSomaLinha()
	oPrint:Line(nLinha, nColuna, nLinha, (oPrint:nHorzRes()-nColuna))
	fSomaLinha()
	fSomaLinha()

	// Cabeçalho Auxiliar
	If !Empty(cClassCabec)
		oPrint:Say(nLinha, nColuna, cClassCabec, oFnt12B)
		fSomaLinha()
		oPrint:Line(nLinha, nColuna, nLinha, (oPrint:nHorzRes()-nColuna))
	EndIf

	// Página
	nPagina++
	oPrint:Line((oPrint:nVertRes()-260), nColuna, (oPrint:nVertRes()-260), (oPrint:nHorzRes()-nColuna))
	oPrint:Say((oPrint:nVertRes()-200), (oPrint:nHorzRes()-400), STR0076 + " "+ PADL(nPagina,2,"0"), oFnt08N) //"Página:"

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fSomaLinha
Funcção auxiliar para Incrementar a Linha no Relatório.

@author Wagner Sobral de Lacerda
@since 07/05/2012

@param nLinhas
	Indica a quantidade de linhas a incrementar * Opcional
	Default: 060

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fSomaLinha(nLinhas)

	// Defaults
	Default nLinhas := 080

	//--------------------
	// Incrementa
	//--------------------
	nLinha += nLinhas

	//--------------------
	// Quebra Página
	//--------------------
	If (nLinha + nSizeImg + 100) > oPrint:nVertRes()
		oPrint:EndPage()
		fPrintCabec()
	EndIf

Return .T.

/*/
############################################################################################
##                                                                                        ##
## MÉTODOS: SELECIONAR UM PAINÉL DE INDICADORES                                           ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} SelectPanel
Método que seleciona um Painel de Indicadores para a classe.

@author Wagner Sobral de Lacerda
@since 04/05/2012

@return lReturn
/*/
//---------------------------------------------------------------------
Method SelectPanel() Class TNGPanel

	// Variáveis de Controle
	Local aSelect := {}

	// Variável do Retorno
	Local lReturn := .F.

	//----------
	// Consulta
	//----------
	aSelect := fSelectPanel(Self)
	// Carrega
	If Len(aSelect) > 0
		If ::LoadPanel(aSelect[1]/*cCodPanel*/, aSelect[2]/*cCodFilia*/, aSelect[3]/*cCodModul*/)
			::SaveConfig()
			lReturn := .T.
		EndIf
	EndIf

Return lReturn

/*/
############################################################################################
##                                                                                        ##
## MÉTODOS: PERSONALIZAÇÃO                                                                ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} SelectInds
Método que seleciona os Indicadores do Painel.

@author Wagner Sobral de Lacerda
@since 21/05/2012

@return lDlgSelect
/*/
//---------------------------------------------------------------------
Method SelectInds() Class TNGPanel

	// Variável do Retorno
	Local lReturn := .F.

	// Variáveis da Janela
	Local oDlgSelect, lDlgSelect := .F.
	Local cDlgSelect := OemToAnsi(STR0077) //"Selecione os Indicadores"
	Local oPnlSelect

	Local oPnlMenu
	Local oPnlBrw
	Local oPnlDesc

	Local oTmpPnl, oTmpBtn

	Local aColors  := aClone( NGCOLOR() )
	Local nClrText := aColors[1]
	Local nClrBack := aColors[2]

	// Variáveis do Browse
	Local aColunas := {}, oColuna
	Local aHeader := {}, aFolder := {}
	Local lMark := .F., aMark := {}
	Local nX := 0, nY := 0, nScan := 0

	Local cArrTitulo := ""
	Local cArrTipo   := ""
	Local nArrTamanh := 0
	Local nArrDecima := 0
	Local cArrPictur := ""
	Local cSetData   := ""

	Local aRetBlock := {}

	// Variáveis PRIVATE do Browse
	Private oFolder
	Private aFWBrowse
	Private aClassific
	Private oPreview

	// Variáveis de Bloco de Código
	Private bBrwSlcCha := ::GetCodeBlock(__nBSlcCha)
	Private bBrwSlcChg := ::GetCodeBlock(__nBSlcChg)
	Private bBrwSlcViw := ::GetCodeBlock(__nBSlcViw)

	// Coloca o cursor do mouse em estado de espera
	CursorWait()

	//--------------------
	// Monta o Array
	//--------------------
	// Cabeçalho e Conteúdo
	If ValType(bBrwSlcCha) == "B"
		aRetBlock  := Eval(bBrwSlcCha)
		aHeader    := aClone(aRetBlock[1])
		aClassific := aClone(aRetBlock[2])
	EndIf
	If Len(aHeader) == 0 .Or. Len(aClassific) == 0
		fShowMsg(STR0078, "I") //"Não há Indicadores disponíveis para serem selcionados."
		Return .F.
	EndIf

	// Define quais indicadores já estão marcados
	For nX := 1 To Len(aClassific)
		For nY := 1 To Len(aClassific[nX][3])
			lMark := ( aScan(::aIndDef, {|x| AllTrim(x[__nIndForm]) == AllTrim(aClassific[nX][3][nY][1]) }) > 0 )
			aClassific[nX][3][nY][6] := lMark
		Next nY
	Next nX

	//--------------------
	// Monta a Janela
	//--------------------
	lDlgSelect := .F.
	DEFINE MSDIALOG oDlgSelect TITLE cDlgSelect FROM 0,0 TO 500,900 OF ::oDlgOwner PIXEL

		// Painel principal do Dialog
		oPnlSelect := TPanel():New(01, 01, , oDlgSelect, , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
		oPnlSelect:Align := CONTROL_ALIGN_ALLCLIENT

			// Folder
			aSort(aClassific, , , {|x,y| x[1] < y[1] })
			aFolder := {}
			For nX := 1 To Len(aClassific)
				aAdd(aFolder, AllTrim(aClassific[nX][2]))
				aSort(aClassific[nX][3], , , {|x,y| x[1] < y[1] })
			Next nX
			oFolder := TFolder():New(01, 01, aFolder, aFolder, oPnlSelect, 1, CLR_BLACK, CLR_WHITE, .T., , 100, 100)
			oFolder:bChange := {|| Eval(aFWBrowse[oFolder:nOption]:bChange) }
			oFolder:Align := CONTROL_ALIGN_ALLCLIENT

			aFWBrowse := Array(Len(oFolder:aDialogs))
			For nX := 1 To Len(oFolder:aDialogs)
				// Painel do Menu Lateral
				oPnlMenu := TPanel():New(01, 01, , oFolder:aDialogs[nX], , , , nClrText, nClrBack, 012, 100, .F., .F.)
				oPnlMenu:Align := CONTROL_ALIGN_LEFT

					// Painel auxiliar para dar um espaço
					oTmpPnl := TPanel():New(01, 01, , oPnlMenu, , , , nClrText, nClrBack, 100, 012)
					oTmpPnl:Align := CONTROL_ALIGN_TOP

					// Botão: Visualizar
					oTmpBtn := TBtnBmp2():New(01, 01, 27, 30, "ng_ico_visual", , , , &("{|| fSlcBrwVis( "+cValToChar(nX)+" ) }"), oPnlMenu, OemToAnsi("Visualizar"), , .T.)
					oTmpBtn:Align := CONTROL_ALIGN_TOP

				// Painel do Browse
				oPnlBrw := TPanel():New(01, 01, , oFolder:aDialogs[nX], , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
				oPnlBrw:Align := CONTROL_ALIGN_ALLCLIENT

					//--------------------
					// Browse de Marcação
					//--------------------
					aFWBrowse[nX] := FWBrowse():New()
					aFWBrowse[nX]:SetOwner(oPnlBrw)
					aFWBrowse[nX]:SetDataArray()
					// Máximo de 4 Caracteres para o ID do Profile do Browse
					aFWBrowse[nX]:SetProfileID("INDS") // Deixando o mesmo ID, faz com que as configurações sejam as mesmas para os browses

					aFWBrowse[nX]:SetLocate()
					aFWBrowse[nX]:SetDelete(.F., {|| .F.})

					// Colunas
					aFWBrowse[nX]:AddMarkColumns(&("{|| fSlcBrwMrk( "+cValToChar(nX)+" ) }"), ;
													&("{|oBrowse| fSlcBrwClk( "+cValToChar(nX)+" ) }"), ;
													&("{|oBrowse| fSlcBrwClk( "+cValToChar(nX)+", .T. ) }") )
					aFWBrowse[nX]:SetDoubleClick(&("{|| fSlcBrwClk( "+cValToChar(nX)+" ) }"))

					aColunas := {}
					For nY := 1 To Len(aHeader)
						cArrTitulo := aHeader[nY][1]
						cArrTipo   := aHeader[nY][2]
						nArrTamanh := aHeader[nY][3]
						nArrDecima := aHeader[nY][4]
						cArrPictur := aHeader[nY][5]

						oColuna := FWBrwColumn():New()
						oColuna:SetAlign( If(cArrTipo == "N", CONTROL_ALIGN_RIGHT, CONTROL_ALIGN_LEFT) )

						cSetData := "{|| aClassific[" + cValToChar(nX) + "][3][aFWBrowse[" + cValToChar(nX) + "]:AT()][" + cValToChar(nY) + "] }"
						oColuna:SetData( &(cSetData) )

						oColuna:SetEdit( .F. )
						oColuna:SetSize( nArrTamanh + nArrDecima )
						oColuna:SetTitle( cArrTitulo )
						oColuna:SetType( cArrTipo )
						oColuna:SetPicture( cArrPictur )

						aAdd(aColunas, oColuna)
					Next nY
					aFWBrowse[nX]:SetColumns(aColunas)
					aFWBrowse[nX]:Activate()
					aFWBrowse[nX]:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
					aFWBrowse[nX]:SetArray(aClassific[nX][3])
					aFWBrowse[nX]:SetChange(&("{|| fSlcBrwChg( "+cValToChar(nX)+" ) }"))
					aFWBrowse[nX]:Refresh()
			Next nX

			// Painel da Descrição
			oPnlDesc := TPanel():New(01, 01, , oPnlSelect, , , , CLR_BLACK, CLR_WHITE, 150, 100, .F., .F.)
			oPnlDesc:Align := CONTROL_ALIGN_RIGHT

				// Pré-Visualização (Preview) do Indicador
				oPreview := TNGIndicator():New(/*nTop*/, /*nLeft*/, 1/*nZoom*/, oPnlDesc/*oParent*/, /*nWidth*/, /*nHeight*/, ;
													/*nClrFooter*/, /*cContent*/, /*cStyle*/, .F./*lScroll*/, .T./*lCenter*/)
				oPreview:Preview()

		// Executa o Change do browse, para iniciar a tela de acordo com o registro posicionado
		Eval(aFWBrowse[1]:bChange)

		// Coloca o cursor do mouse em estado normal
		CursorArrow()

	ACTIVATE MSDIALOG oDlgSelect ON INIT EnchoiceBar(oDlgSelect, {|| lDlgSelect := .T., oDlgSelect:End() }, {|| lDlgSelect := .F., oDlgSelect:End() }) CENTERED

	// Se confirmou
	If lDlgSelect
		// Armazena os Indicadores Marcados
		aMark := {}
		For nX := 1 To Len(aClassific)
			For nY := 1 To Len(aClassific[nX][3])
				If aClassific[nX][3][nY][6]
					aAdd(aMark, aClassific[nX][3][nY][1])
				EndIf
			Next nY
		Next nX
		// Seta para o Painel de Indicadores (Pré-Visualização)
		::SetPanel(, , , aMark)
	EndIf

Return lDlgSelect

//---------------------------------------------------------------------
/*/{Protheus.doc} fSlcBrwMrk
Carrega a marcação do browse.

@author Wagner Sobral de Lacerda
@since 27/04/2012

@param nClass
	Indica o número identificador da Classificação * Obrigatório

@return cRetMarca
/*/
//---------------------------------------------------------------------
Static Function fSlcBrwMrk(nClass)

	// Variáveis de controle
	Local cComMarca := "LBOK"
	Local cSemMarca := "LBNO"
	Local cRetMarca := ""

	Local nATBrw := aFWBrowse[nClass]:AT()

	// Define a Marca
	cRetMarca := If(aClassific[nClass][3][nATBrw][6], cComMarca, cSemMarca)

Return cRetMarca

//---------------------------------------------------------------------
/*/{Protheus.doc} fSlcBrwClk
Executa o clique sobre a Marcação.

@author Wagner Sobral de Lacerda
@since 27/04/2012

@param nClass
	Indica o número identificador da Classificação * Obrigatório
@param lHeadClick
	Indica se a ação do clique é a do clique no Header * Opcional
	Default: .F.

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fSlcBrwClk(nClass, lHeadClick)

	// Variáveis de controle
	Local nATBrw := aFWBrowse[nClass]:AT()

	Local lMarca := .F.
	Local nScan := 0, nX := 0

	If !lHeadClick
		// Inverte a definição de marcação
		aClassific[nClass][3][nATBrw][6] := !aClassific[nClass][3][nATBrw][6]
	Else
		nScan := aScan(aClassific[nClass][3], {|x| !x[6] })
		If nScan > 0
			lMarca := .T.
		EndIf

		// Atribui a definição de marcação
		For nX := 1 To Len(aClassific[nClass][3])
			aClassific[nClass][3][nX][6] := lMarca
		Next nX
	EndIf

	// Atualiza o Browse
	If lHeadClick
		aFWBrowse[nClass]:GoTop()
		aFWBrowse[nClass]:Refresh()
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fSlcBrwChg
Executa o Change do Browse.

@author Wagner Sobral de Lacerda
@since 27/04/2012

@param nClass
	Indica o número identificador da Classificação * Obrigatório

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fSlcBrwChg(nClass)

	// Executa Bloco de Código na mundança de linha do browse
	If ValType(bBrwSlcChg) == "B"
		Eval(bBrwSlcChg, aFWBrowse[nClass], oPreview, aClassific[nClass])
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fSlcBrwVis
Visualiza o item do browse.

@author Wagner Sobral de Lacerda
@since 27/04/2012

@param nClass
	Indica o número identificador da Classificação * Obrigatório

@return lReturn
/*/
//---------------------------------------------------------------------
Static Function fSlcBrwVis(nClass)

	// Variável do retorno
	Local lReturn := .F.

	// Se não possuir interface, então não pode executar
	If !fHasInterface()
		Return .F.
	EndIf

	// Executa Bloco de Código na visualização da linha do browse
	If ValType(bBrwSlcViw) == "B"
		lReturn := Eval(bBrwSlcViw, aFWBrowse[nClass], aClassific[nClass])
	EndIf

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} MakeCad
Método que monta uma tela de Cadastro do Painel de Indicadores.

@author Wagner Sobral de Lacerda
@since 24/05/2012

@param nOption
	Número da Opção do Cadastro * Obrigatório
	   2 - Visualizar
	   3 - Incluir
	   4 - Alterar
	   5 - Excluir

@return aReturn
/*/
//---------------------------------------------------------------------
Method MakeCad(nOption) Class TNGPanel

	// Variável do Retorno do Cadastro
	Local aReturn := {}

	// Variáveis de Bloco de Código
	Local bMakeCad := ::GetCodeBlock(__nBMakCad)

	// Variáveis auxiliares
	Local nX := 0, nCad := 0

	//--- Verifica se o usuário tem autorização para manipular o cadastro
	If nOption <> 3 .And. ::IsCreated()
		If !::IsMine()
			Return aReturn
		EndIf
	EndIf

	If ValType(bMakeCad) == "B"
		aReturn := Eval(bMakeCad, nOption, aClone(::aInfo))
	EndIf

	If Len(aReturn) > 0 .And. aReturn[1]
		// Atualiza as Informações do Painéis
		::aInfo := Array(__nInfQtde)
		If Len(aReturn[2]) == Len(::aInfo)
			::SetInfo( aClone(aReturn[2]) )
		EndIf

		// Atualiza informações dos Cadastros (fixado ou não), caso exista um sendo apresentado
		For nX := 1 To 2
			If Len(::aShowCad[nX]) > 0
				// Atualiza os Objetos GET
				For nCad := 1 To Len(::aShowCad[nX])
					If ValType(::aShowCad[nX][nCad][1]) == "O"
						::aShowCad[nX][nCad][1]:bSetGet := &("{|| '" + ::aInfo[::aShowCad[nX][nCad][2]] + "' }")
						If ::aShowCad[nX][nCad][1]:ClassName() == "TGET"
							::aShowCad[nX][nCad][1]:CtrlRefresh()
						Else
							::aShowCad[nX][nCad][1]:Refresh()
						EndIf
					EndIf
				Next nCad
			EndIf
		Next nX
	EndIf

Return aReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} SavePanel
Método que Salva o Painel de Indicadores de acordo com os parâmetros.

@author Wagner Sobral de Lacerda
@since 23/05/2012

@return lReturn
/*/
//---------------------------------------------------------------------
Method SavePanel() Class TNGPanel

	// Variáveis de Controle
	Local aRetModulos := aClone( RetModName() )
	Local aIndics := {}
	Local nX := 0

	Local lNewCad := .F.

	// Variável do Retorno
	Local aReturn := {}
	Local lReturn := .T.

	// Variáveis do Painel
	Local cCodPanel := ::cCodPanel
	Local cCodFilia := ::cCodFilia
	Local cCodModul := ::cCodModul
	Local cNamPanel := ::aInfo[__nInfNome]

	// Variáveis de Bloco de Código
	Local bSavePanel := ::GetCodeBlock(__nBSavPnl)
	Local bLoadPanel := ::GetCodeBlock(__nBLoaPnl)

	//------------------------------
	// Validações Obrigatórias
	//------------------------------
	// Código
	If Empty(cCodPanel)
		lNewCad := .T.
	EndIf
	// Filial
	If lReturn
		If !Empty(cCodFilia) .And. !FWFilExist(/*cEmpresa*/, cCodFilia/*cFilial*/)
			lNewCad := .T.
		EndIf
	EndIf
	// Módulo
	If lReturn
		If Empty(cCodModul)
			lNewCad := .T.
		ElseIf aScan(aRetModulos, {|x| Str(x[1],2) == cCodModul }) == 0
			lNewCad := .T.
		EndIf
	EndIf
	// Nome
	If lReturn
		If Empty(cNamPanel)
			lNewCad := .T.
		EndIf
	EndIf

	//----------
	// Cadastro
	//----------
	If lReturn
		// Novo Cadastro
		If lNewCad
			lReturn := .F.
			aReturn := aClone( ::MakeCad(3) )
			If aReturn[1]
				If Len(aReturn[2]) == Len(::aInfo)
					::SetInfo( aClone(aReturn[2]) )
				EndIf
				lReturn := .T.
			EndIf
		ElseIf !::IsMine() // Verifica se o Painel é de autoria do usuário logado
			lReturn := .F.
		EndIf
	EndIf

	//----------
	// Gravação
	//----------
	If lReturn
		// Salva o Painel de Indicadores
		If ValType(bSavePanel) == "B"
			lReturn := Eval(bSavePanel, aClone(::GetInfo()), aClone(::GetIndics()))
		Else
			lReturn := .F.
		EndIf
	EndIf

	// Se salvou, carrega o Painel
	If lReturn
		::LoadPanel(::aInfo[__nInfCodi], ::aInfo[__nInfFili], ::aInfo[__nInfMdCd])
	EndIf

	// Define mensagem
	::oMessPnl:Show()
	::oMessPnl:SetText(If(lReturn, STR0081, STR0082)) //"Painel salvo com sucesso." ## "Não foi possível salvar o Painel."
	::oMessPnl:SetColor(If(lReturn, CLR_GREEN, CLR_RED), CLR_WHITE)

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} LoadPanel
Método que Carrega o Painel de Indicadores de acordo com os parâmetros.

@author Wagner Sobral de Lacerda
@since 23/05/2012

@param cCodPanel
	Código do Painel de Indicadores * Opcional
	Default: ::cCodPanel
@param cCodFilia
	Filial do Painel de Indicadores * Opcional
	Default: ::cCodFilia
@param cCodModul
	Módulo do Painel de Indicadores * Opcional
	Default: ::cCodModul

@return lReturn
/*/
//---------------------------------------------------------------------
Method LoadPanel(cCodPanel, cCodFilia, cCodModul) Class TNGPanel

	// Variável do Retorno
	Local lReturn := .T.

	// Variáveis de Bloco de Código
	Local bLoadPanel := ::GetCodeBlock(__nBLoaPnl)

	// Defaults
	Default cCodPanel := ::cCodPanel
	Default cCodFilia := ::cCodFilia
	Default cCodModul := ::cCodModul

	//----------
	// Carrega
	//----------
	// Carrega o Painel de Indicadores
	If ValType(bLoadPanel) == "B"
		lReturn := Eval(bLoadPanel, cCodPanel, cCodFilia, cCodModul)
	Else
		lReturn := .F.
	EndIf
	If lReturn
		// Como será selecionado da base um Painel de Indicadores, zera os Indicadores "específicos"
		::SetEspInds({})

		// Carrega
		::SetPanel(cCodPanel, cCodFilia, cCodModul)
	EndIf

	// Define mensagem
	::oMessPnl:Show()
	::oMessPnl:SetText(If(lReturn, STR0083, STR0084)) //"Painel carregado com sucesso." ## "Não foi possível carregar o Painel."
	::oMessPnl:SetColor(If(lReturn, CLR_GREEN, CLR_RED), CLR_WHITE)

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} DelPanel
Método que Deleta o Painel de Indicadores de acordo com os parâmetros.

@author Wagner Sobral de Lacerda
@since 23/05/2012

@param cCodPanel
	Código do Painel de Indicadores * Opcional
	Default: ::cCodPanel
@param cCodFilia
	Filial do Painel de Indicadores * Opcional
	Default: ::cCodFilia
@param cCodModul
	Módulo do Painel de Indicadores * Opcional
	Default: ::cCodModul

@return lReturn
/*/
//---------------------------------------------------------------------
Method DelPanel(cCodPanel, cCodFilia, cCodModul) Class TNGPanel

	// Variável do Retorno
	Local lReturn := .T.

	// Variáveis de Bloco de Código
	Local bDelPanel := ::GetCodeBlock(__nBDelPnl)

	// Defaults
	Default cCodPanel := ::cCodPanel
	Default cCodFilia := ::cCodFilia
	Default cCodModul := ::cCodModul

	// Se não existe um Painel criado, então não há o que deletar
	If Empty(cCodPanel)
		fShowMsg(STR0085, "I") //"Não há nenhum Painel criado para excluir."
		lReturn := .F.
	EndIf

	// Verifica se o Painel é de autoria do usuário logado
	If lReturn
		lReturn := ::IsMine()
	EndIf

	// Pergunta se deseja realmente excluir o Painel
	If lReturn
		lReturn := MsgYesNo(STR0086 + CRLF + CRLF + "(" + STR0087 + " '" + cCodPanel + "')", STR0030) //"Deseja realmente excluir este Painel de Indicadores?" ## "Código do Painel:" ## "Atenção"
	EndIf

	//----------
	// Exclusão
	//----------
	If lReturn
		// Salva o Painel de Indicadores
		If ValType(bDelPanel) == "B"
			lReturn := Eval(bDelPanel, cCodPanel, cCodFilia, cCodModul)
		Else
			lReturn := .F.
		EndIf

		If lReturn
			// Reseta
			::Reset()
		EndIf
	EndIf

	// Define mensagem
	::oMessPnl:Show()
	::oMessPnl:SetText(If(lReturn, STR0088, STR0089)) //"Painel excluído com sucesso." ## "Não foi possível excluir o Painel."
	::oMessPnl:SetColor(If(lReturn, CLR_GREEN, CLR_RED), CLR_WHITE)

Return lReturn

/*/
############################################################################################
##                                                                                        ##
## MÉTODOS: OUTROS                                                                        ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} BlackPnl
Método que Mostra/Esconde um Painel Preto sobre o Dialog.

@author Wagner Sobral de Lacerda
@since 16/05/2012

@param lVisible
	Indica se deve mostrar ou esconder o Painel: * Opcional
	   .T. - Mostra
	   .F. - Esconde
	Default: .T.

@return .T.
/*/
//---------------------------------------------------------------------
Method BlackPnl(lVisible) Class TNGPanel

	// Se ainda não existir, cria
	If ValType(::oBlackPnl) <> "O"
		// Cria um Painel Preto (meio Transparente) no Dialog Principal
		::oBlackPnl := TPanel():New(0, 0, , ::oDlgOwner, , , , , SetTransparentColor(CLR_BLACK,70), ::oDlgOwner:nClientWidth, ::oDlgOwner:nClientHeight, .F., .F.)
	EndIf

	// Define visibilidade do Painel Preto
	If lVisible
		::oBlackPnl:Show()
	Else
		::oBlackPnl:Hide()
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} CanConfig
Método que define se as Configurações do Painel de Indicadores estão
habilitadas.

@author Wagner Sobral de Lacerda
@since 18/05/2012

@param lCanConfig
	Indica se pode utilizar as Configurações do Painel de Indicadores: * Opcional
	   .T. - Mostra
	   .F. - Esconde
	Default: ::lCanConfig

@return .T.
/*/
//---------------------------------------------------------------------
Method CanConfig(lCanConfig) Class TNGPanel

	// Defaults
	Default lCanConfig := ::lCanConfig

	// Indica que é apenas Pré-Visualização
	::lCanConfig := lCanConfig

	//--------------------------------------------------
	// Habilita ou Desabilita as Configurações
	//--------------------------------------------------
	If ::lCanConfig
		::oFootCfg:Show()
		::aSpaceBtn[__nSpcDCfg]:Show() // Espaço em branco

		::oFootCal:Show()
		::aSpaceBtn[__nSpcDCal]:Show() // Espaço em branco
	Else
		::oFootCfg:Hide()
		::aSpaceBtn[__nSpcDCfg]:Hide() // Espaço em branco

		::oFootCal:Hide()
		::aSpaceBtn[__nSpcDCal]:Hide() // Espaço em branco
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} CanSelect
Método que define se podem ser selecionados os Indicadores que aparecem
no Painel de Indicadores.
* Observação: Se pode selecionar Indicadores, então também pode salvá-los,
por isto o botão de Mais Opções é habilitada quando a Seleção de Indicadores
está habilitada

@author Wagner Sobral de Lacerda
@since 21/05/2012

@param lCanSelect
	Indica se permite selecionar os Indicadores * Opcional
	   .T. - Permite
	   .F. - Não permite
	Default: ::lCanSelect

@return .T.
/*/
//---------------------------------------------------------------------
Method CanSelect(lCanSelect) Class TNGPanel

	// Defaults
	Default lCanSelect := ::lCanSelect

	// Indica que é apenas Pré-Visualização
	::lCanSelect := lCanSelect

	//--------------------------------------------------
	// Habilita ou Desabilita a Seleção dos Indicadores
	//--------------------------------------------------
	::CanOptions() // Mostra ou Esconde as opções do botão 'Mais'
	If ::lCanSelect
		::oFootSlc:Show()
		::aSpaceBtn[__nSpcDSlc]:Show() // Espaço em branco
	Else
		::oFootSlc:Hide()
		::aSpaceBtn[__nSpcDSlc]:Hide() // Espaço em branco
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} CanWait
Método que define se o Painel de Espera pode ser visualizado.

@author Wagner Sobral de Lacerda
@since 21/05/2012

@param CanWait
	Indica se permite visualizar o Painel de Espera * Opcional
	   .T. - Permite
	   .F. - Não permite
	Default: ::lCanWait

@return .T.
/*/
//---------------------------------------------------------------------
Method CanWait(lCanWait) Class TNGPanel

	// Defaults
	Default lCanWait := ::lCanWait

	// Indica que é apenas Pré-Visualização
	::lCanWait := lCanWait

	//--------------------------------------------------
	// Habilita ou Não o Painel de 'Em Espera'
	//--------------------------------------------------
	// Se não puder fica 'Em Espera', mostra o Painel Principal
	If !::lCanWait
		::oWaitPnl:Hide() // Esconde o Painel de Espera
		::oMainPnl:Show() // Mostra o Painel Principal
	Else // Se puder esperar
		// Se o Painel de Indicadores estiver criado, mostra ele
		If ::IsCreated()
			::oWaitPnl:Hide() // Esconde o Painel de Espera
			::oMainPnl:Show() // Mostra o Painel Principal
		Else // Senão, mostra o Painel 'Em Espera'
			::oMainPnl:Hide() // Esconde o Painel Principal
			::oWaitPnl:Show() // Mostra o Painel de Espera
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} CanOptions
Método que Habilita ou Desabilita as Opções do botão de 'Mais Opções'.

@author Wagner Sobral de Lacerda
@since 24/05/2012

@return .T.
/*/
//---------------------------------------------------------------------
Method CanOptions() Class TNGPanel

	// Variáveis da Classe
	Local nMode := ::GetMode()

	// Variáveis dos Itens do Menu
	Local oItem

	Local lCad   := .F.
	Local lNew   := .F.
	Local lSave  := .F.
	Local lLoad  := .F.
	Local lDelet := .F.

	// Variáveis de Controle
	Local lHasOption := .F.

	// Variáveis das Opções
	Local aOptions   := aClone( ::GetOptions()[1] )
	Local aNoOptions := aClone( ::GetOptions()[2] )

	//--------------------
	// Define Opções
	//--------------------
	// Define opções habilitadas
	If aScan(aOptions, {|x| x == "ALL" }) > 0
		lCad   := .T.
		lNew   := .T.
		lSave  := .T.
		lLoad  := .T.
		lDelet := .T.
	Else
		lCad   := ( aScan(aOptions, {|x| Upper(AllTrim(x)) == "INFO" }) > 0 )
		lNew   := ( aScan(aOptions, {|x| Upper(AllTrim(x)) == "NEW" }) > 0 )
		lSave  := ( aScan(aOptions, {|x| Upper(AllTrim(x)) == "SAVE" }) > 0 )
		lLoad  := ( aScan(aOptions, {|x| Upper(AllTrim(x)) == "LOAD" }) > 0 )
		lDelet := ( aScan(aOptions, {|x| Upper(AllTrim(x)) == "DELET" }) > 0 )
	EndIf
	// Verifica se há opções
	lHasOption := ( lCad .Or. lNew .Or. lSave .Or. lLoad .Or. lDelet )

	// Define opções desabilitadas (sobreponde as habilitadas)
	If aScan(aNoOptions, {|x| x == "NONE" }) > 0
		lCad   := .F.
		lNew   := .F.
		lSave  := .F.
		lLoad  := .F.
		lDelet := .F.
	Else
		If aScan(aNoOptions, {|x| Upper(AllTrim(x)) == "INFO" }) > 0
			lCad := .F.
		EndIf
		If aScan(aNoOptions, {|x| Upper(AllTrim(x)) == "NEW" }) > 0
			lNew := .F.
		EndIf
		If aScan(aNoOptions, {|x| Upper(AllTrim(x)) == "SAVE" }) > 0
			lSave := .F.
		EndIf
		If aScan(aNoOptions, {|x| Upper(AllTrim(x)) == "LOAD" }) > 0
			lLoad := .F.
		EndIf
		If aScan(aNoOptions, {|x| Upper(AllTrim(x)) == "DELET" }) > 0
			lDelet := .F.
		EndIf
	EndIf
	// Verifica se há opções
	lHasOption := ( lCad .Or. lNew .Or. lSave .Or. lLoad .Or. lDelet )

	// Limpa o Menu (o método 'Reset()' também destrói os objetos "itens" do menu
	::oMorMenu:Reset()

	// Adiciona ou Remove Itens no Menu (somente se tiver opções e seja possível selecionar indicadores, o que significa que pode também salvá-los, carregá-los, etc.)
	If lHasOption .And. ::lCanSelect
		If lCad .And. !::GetFixedCad()
			oItem := TMenuItem():New(::oDlgOwner, STR0053, , , , {|| ::ShowCad() }, ; //"Informações"
										, , , , , , , , .T.)
			::oMorMenu:Add(oItem)
		EndIf
		If lNew
			oItem := TMenuItem():New(::oDlgOwner, STR0090, , , , {|| ::Blank() }, ; //"Novo"
										, , , , , , , , .T.)
			::oMorMenu:Add(oItem)
		EndIf
		If lSave
			oItem := TMenuItem():New(::oDlgOwner, STR0091, , , , {|| ::SavePanel() }, ; //"Salvar"
										, , , , , , , , .T.)
			::oMorMenu:Add(oItem)
		EndIf
		If lLoad
			oItem := TMenuItem():New(::oDlgOwner, STR0092, , , , {|| ::SelectPanel() }, ; //"Carregar"
										, , , , , , , , .T.)
			::oMorMenu:Add(oItem)
		EndIf
		If lDelet
			oItem := TMenuItem():New(::oDlgOwner, STR0093, , , , {|| ::DelPanel() }, ; //"Excluir"
										, , , , , , , , .T.)
			::oMorMenu:Add(oItem)
		EndIf

		// Seta POPUP
		::oFootMor:SetPopupMenu(::oMorMenu)
		// Mostra o Botão
		::oFootMor:Show()
		::aSpaceBtn[__nSpcDMor]:Show() // Espaço em branco
	Else // Senão
		// Esconde o Botão
		::oFootMor:Hide()
		::aSpaceBtn[__nSpcDMor]:Hide() // Espaço em branco
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} ShowCad
Método que mostra as Informações do Cadastro do Painel de Indicadores.

@author Wagner Sobral de Lacerda
@since 30/05/2012

@param nForceCad
	Indica se deve forçar a montagem do Cadastro: * Opcional
	   1 - Fixado no Painel
	   2 - Novo dialog
	Default: 0 (nenhum)

@return .T./.F.
/*/
//---------------------------------------------------------------------
Method ShowCad(nForceCad) Class TNGPanel

	// Variáveis da Janela
	Local oDlgInfo
	Local cDlgInfo := OemToAnsi(STR0054) //"Informações do Cadastro do Painel"
	Local oPnlInfo

	Local nLargura := 450
	Local nAltura  := 320

	Local oPnlCabec
	Local oPnlCad
	Local oPnlBtn
	Local nSizeBtn := 012

	Local nHeiCad := 0

	// Variáveis auxiliares
	Local oTmpPnl
	Local oTmpButtn

	Local nCad := 0

	// Variável auxiliar do Painel preto para armazenar o seu estado inicial (utilizado para: se já estava visível, então a rotina/função anterior é responsável por escondâ-lo também)
	Local lBlackVisi := ::IsBlackPnl()

	// Defaults
	Default nForceCad := 0

	// Não executa se não estiver Ativado
	If !::lActivated
		Return .F.
	EndIf

	//----------
	// Monta
	//----------
	// Cadastro fixado no Painel?
	If ::GetFixedCad() .Or. nForceCad == 1
		If Len(::aShowCad[1]) == 0
			// Libera os filhos
			::oCadPnl:FreeChildren()

			// Painel to título
			::oCadTitle := TPanel():New(01, 01, STR0053, ::oCadPnl, ::oTitlePnl:oFont, .T., , CLR_BLACK, CLR_WHITE, 100, ::nSizeTitBar) //"Informações"
			::oCadTitle:Align := CONTROL_ALIGN_TOP
			::oCadTitle:CoorsUpdate()

			// Painel do Cadastro
			oPnlCad := TPanel():New(01, 01, , ::oCadPnl, , , , CLR_BLACK, CLR_WHITE, 100, 160)
			oPnlCad:Align := CONTROL_ALIGN_TOP

				// Monta o Cadastro
				::aShowCad[1] := aClone( fShowCad(oPnlCad, Self) )

			// Painel dos botões
			oPnlBtn := TPanel():New(01, 01, , ::oCadPnl, , , , CLR_BLACK, CLR_WHITE, 100, ::nSizeBtnBar)
			oPnlBtn:Align := CONTROL_ALIGN_TOP

				//--- Lado DIREITO

				// Painel auxiliar para deixar um espaço entre o botão e a borda da direita da janela
				oTmpPnl := TPanel():New(01, 01, , oPnlBtn, , , , CLR_BLACK, CLR_WHITE, ::nSpacBtnBor, 100)
				oTmpPnl:Align := CONTROL_ALIGN_RIGHT

				// Botão: Desafixar
				oTmpButtn := TButton():New(001, 001, STR0094, oPnlBtn, {|| ::SetFixedCad(.F.) },; //"Desafixar"
												030, 012, , , .F., .T., .F., , .F., , , .F.)
				fSetCSS(3, oTmpButtn) // Seta o CSS do botão
				oTmpButtn:lCanGotFocus := .F.
				oTmpButtn:cTooltip := STR0095 //"Desafixar o Cadastro do Painel"
				oTmpButtn:Align := CONTROL_ALIGN_RIGHT

				//--- Lado ESQUERDO

				// Painel auxiliar para deixar um espaço entre o botão e a borda da direita da janela
				oTmpPnl := TPanel():New(01, 01, , oPnlBtn, , , , CLR_BLACK, CLR_WHITE, ::nSpacBtnBor, 100)
				oTmpPnl:Align := CONTROL_ALIGN_LEFT

				// Botão: Editar
				oTmpButtn := TButton():New(001, 001, STR0097, oPnlBtn, {|| ::MakeCad(4) },; //"Editar"
												030, 012, , , .F., .T., .F., , .F., , , .F.)
				fSetCSS(6, oTmpButtn) // Seta o CSS do botão
				oTmpButtn:lCanGotFocus := .F.
				oTmpButtn:cTooltip := STR0098 //"Editar o Cadastro"
				oTmpButtn:Align := CONTROL_ALIGN_LEFT

			// Painel auxiliar para deixar um espaço entre os botões a a borda inferior da janela
			oTmpPnl := TPanel():New(01, 01, , ::oCadPnl, , , , CLR_BLACK, CLR_WHITE, 100, (::nSpacBtnBor/2))
			oTmpPnl:Align := CONTROL_ALIGN_TOP
		EndIf

		// Atualiza o Título
		::oCadTitle:SetColor(::oTitlePnl:nClrText/*nClrFore*/, ::oTitlePnl:nClrPane/*nClrBack*/)
		If ::oTitlePnl:lVisible
			::oCadTitle:Show()
		Else
			::oCadTitle:Hide()
		EndIf

		// Atualiza os Objetos GET
		For nCad := 1 To Len(::aShowCad[1])
			::aShowCad[1][nCad][1]:bSetGet := &("{|| '" + ::aInfo[::aShowCad[1][nCad][2]] + "' }")
			If ::aShowCad[1][nCad][1]:ClassName() == "TGET"
				::aShowCad[1][nCad][1]:CtrlRefresh()
			Else
				::aShowCad[1][nCad][1]:Refresh()
			EndIf
		Next nCad
	EndIf
	// Cadastro não fixado?
	If !::GetFixedCad() .Or. nForceCad == 2
		// Mostra Painel
		If !lBlackVisi
			::BlackPnl(.T.)
		EndIf

		// Monta Janela
		DEFINE MSDIALOG oDlgInfo TITLE cDlgInfo FROM 0,0 TO nAltura,nLargura OF ::oDlgOwner STYLE WS_POPUPWINDOW PIXEL

			// Painel principal do Dialog
			oPnlInfo := TPanel():New(01, 01, , oDlgInfo, , , , CLR_BLACK, CLR_WHITE, 100, 008)
			oPnlInfo:Align := CONTROL_ALIGN_ALLCLIENT

				// Painel do Cabeçalho (para o botão 'X' - Fechar)
				oPnlCabec := TPanel():New(01, 01, , oPnlInfo, , , , CLR_BLACK, CLR_WHITE, 100, 008)
				oPnlCabec:Align := CONTROL_ALIGN_TOP

					// Botão: Fechar
					oTmpButtn := TBtnBmp2():New(001, 001, 20, 20, "BR_CANCEL", , , , {|| oDlgInfo:End() }, oPnlCabec, OemToAnsi(STR0015)) //"Fechar"
					oTmpButtn:lCanGotFocus := .F.
					oTmpButtn:Align := CONTROL_ALIGN_RIGHT

				// Painel do Cadastro
				oPnlCad := TPanel():New(01, 01, , oPnlInfo, , , , CLR_BLACK, CLR_WHITE, 100, 100)
				oPnlCad:Align := CONTROL_ALIGN_ALLCLIENT

					// Monta o Cadastro
					::aShowCad[2] := aClone( fShowCad(oPnlCad, Self) )

				// Painel auxiliar para deixar um espaço entre o Painel de botões e a borda inferior da janela
				oTmpPnl := TPanel():New(01, 01, , oPnlInfo, , , , CLR_BLACK, CLR_WHITE, 100, (::nSpacBtnBor/2))
				oTmpPnl:Align := CONTROL_ALIGN_BOTTOM

				// Painel dos botões
				oPnlBtn := TPanel():New(01, 01, , oPnlInfo, , , , CLR_BLACK, CLR_WHITE, 100, ::nSizeBtnBar)
				oPnlBtn:Align := CONTROL_ALIGN_BOTTOM

					//--- Lado DIREITO

					// Painel auxiliar para deixar um espaço entre o botão e a borda da direita da janela
					oTmpPnl := TPanel():New(01, 01, , oPnlBtn, , , , CLR_BLACK, CLR_WHITE, ::nSpacBtnBor, 100)
					oTmpPnl:Align := CONTROL_ALIGN_RIGHT

					// Botão: Ok
					oTmpButtn := TButton():New(001, 001, STR0099, oPnlBtn, {|| oDlgInfo:End() },; //"Pronto"
													030, 012, , , .F., .T., .F., , .F., , , .F.)
					fSetCSS(4, oTmpButtn) // Seta o CSS do botão
					oTmpButtn:lCanGotFocus := .F.
					oTmpButtn:cTooltip := STR0099 //"Pronto"
					oTmpButtn:Align := CONTROL_ALIGN_RIGHT

					// Painel auxiliar para deixar um espaço entre os botões
					oTmpPnl := TPanel():New(01, 01, , oPnlBtn, , , , CLR_BLACK, CLR_WHITE, ::nSpacBtnBtn, 100)
					oTmpPnl:Align := CONTROL_ALIGN_RIGHT

					// Botão: Fixar/Desafixar
					oTmpButtn := TButton():New(001, 001, If(!::GetFixedCad(),STR0100,STR0094), oPnlBtn, {|oBtn| ::SetFixedCad(!::GetFixedCad(), ), fShowBtn(oBtn, ::GetFixedCad()) },; //"Fixar" ## "Desafixar"
													030, 012, , , .F., .T., .F., , .F., , , .F.)
					fSetCSS(3, oTmpButtn) // Seta o CSS do botão
					oTmpButtn:lCanGotFocus := .F.
					oTmpButtn:cTooltip := If(!::GetFixedCad(),STR0101,STR0095) //"Fixar o Cadastro no Painel" ## "Desafixar o Cadastro do Painel"
					oTmpButtn:Align := CONTROL_ALIGN_RIGHT

					//--- Lado ESQUERDO

					// Painel auxiliar para deixar um espaço entre o botão e a borda da direita da janela
					oTmpPnl := TPanel():New(01, 01, , oPnlBtn, , , , CLR_BLACK, CLR_WHITE, ::nSpacBtnBor, 100)
					oTmpPnl:Align := CONTROL_ALIGN_LEFT

					// Botão: Editar
					oTmpButtn := TButton():New(001, 001, STR0097, oPnlBtn, {|| ::MakeCad(4) },; //"Editar"
													030, 012, , , .F., .T., .F., , .F., , , .F.)
					fSetCSS(6, oTmpButtn) // Seta o CSS do botão
					oTmpButtn:lCanGotFocus := .F.
					oTmpButtn:cTooltip := STR0098 //"Editar o Cadastro"
					oTmpButtn:Align := CONTROL_ALIGN_LEFT

		ACTIVATE MSDIALOG oDlgInfo CENTERED

		// Limpa o array do Cadastro da tela, porque como o Dialog foi encerrado, os objetos foram destruídos
		::aShowCad[2] := {}

		// Esconde Painel
		If !lBlackVisi
			::BlackPnl(.F.)
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fShowBtn
Define o Texto do Botão de Fixar/Desafixar, de acordo com a ação dele.

@author Wagner Sobral de Lacerda
@since 01/06/2012

@param oBtn
	Objeto do Botão * Obrigatório
@param lFixed
	Indica se o Painel está fixado ou não * Obrigatório
	   .T. - Está fixado
	   .F. - Não está fixado

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fShowBtn(oBtn, lFixed)

	// Define o botão
	If lFixed
		oBtn:SetText(STR0094) //"Desafixar"
		oBtn:cTooltip := STR0095 //"Desafixar o Cadastro do Painel"
	Else
		oBtn:SetText(STR0100) //"Fixar"
		oBtn:cTooltip := STR0101 //"Fixar o Cadastro no Painel"
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fShowCad
Monta as Informações do Cadastro do Painel de Indicadores.

@author Wagner Sobral de Lacerda
@since 31/05/2012

@param oObjPai
	Objeto Pai que conterá as informações * Obrigatório
@param oClassPanel
	Objeto da Classe TNGPanel (Paniél de Indicadores) * Obrigatório

@return aObjects
/*/
//---------------------------------------------------------------------
Static Function fShowCad(oObjPai, oClassPanel)

	// Variáveis da Classe
	Local aInfo := aClone( oClassPanel:GetInfo() )
	Local aFldInfo := aClone( oClassPanel:GetFldInfo() )
	Local nMode := oClassPanel:GetMode()

	// Variáveis para aulixar na montagem da Tela
	Local oPnlPai
	Local oScrAll

	Local aShow := {}
	Local nShow := 0

	Local oTmpGroup
	Local oTmpSay
	Local oTmpGet
	Local oTmpFntBold := TFont():New(, , , ,.T.)

	Local nPosLin
	Local nPosCol

	Local cAuxTitle  := ""
	Local cAuxSetGet := ""
	Local cAuxPictur := ""
	Local cAuxHelp   := ""
	Local aAuxCBox   := ""

	Local cCalcSize  := ""
	Local nCalcSize  := 0
	Local nCpo := 0

	// Variável do Retorno
	Local aObjects := {}

	//--- Define Array para montar as Informações
	For nCpo := 1 To Len(aFldInfo)
		nCalcSize := CalcFieldSize(aFldInfo[nCpo][__nFldType], aFldInfo[nCpo][__nFldSize], aFldInfo[nCpo][__nFldDeci], aFldInfo[nCpo][__nFldPict], aFldInfo[nCpo][__nFldTitl])
		aAdd(aShow, {	aFldInfo[nCpo][__nFldTitl], ; // [1] - Título
						aFldInfo[nCpo][__nFldType], ; // [2] - Tipo de Conteúdo
						aInfo[nCpo]               , ; // [3] - Conteúdo
						nCalcSize                 , ; // [4] - Tamanho da GET
						aFldInfo[nCpo][__nFldPict], ; // [5] - Picture
						aFldInfo[nCpo][__nFldIDCp], ; // [6] - Campo
						aFldInfo[nCpo][__nFldComb], ; // [7] - ComboBox
						aFldInfo[nCpo][__nFldObli], ; // [8] - Obrigatório?
						aFldInfo[nCpo][__nFldHelp], ; // [9] - Help
						nCpo                       }) // [10] (aTail para facilitar) - Número da posição no array 'aInfo'
	Next nCpo

	//----------
	// Monta
	//----------
	// Libera os filhos do objeto pai
	oObjPai:FreeChildren()
	oObjPai:CoorsUpdate()

	// Painel Pai
	oPnlPai := TPanel():New(01, 01, , oObjPai, , , , CLR_BLACK, CLR_WHITE, 100, 100)
	oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT
	oPnlPai:CoorsUpdate()

		// GroupBox das Informações
		oTmpGroup := TGroup():New(005, 005, (oPnlPai:nClientHeight * 0.50)-015, (oPnlPai:nClientWidth * 0.50)-005, OemToAnsi(STR0054), oPnlPai, , , .T.) //"Informações do Cadastro do Painel"

			// Painel All com as Informações
			oScrAll := TScrollBox():New(oPnlPai, 015, 015, (oPnlPai:nClientHeight * 0.50)-035, (oPnlPai:nClientWidth * 0.50)-025, .T., .T., .F.)
			oScrAll:nClrPane := CLR_WHITE
			oScrAll:CoorsUpdate()

				nPosLin := 005
				nPosCol := 005

				// Monta o array em tela
				For nShow := 1 To Len(aShow)
					cAuxTitle  := "{|| '" + aShow[nShow][1] + "' }"
					If aShow[nShow][2] == "C"
						cAuxSetGet := "{|| '" + aShow[nShow][3] + "' }"
					ElseIf aShow[nShow][2] == "N"
						cAuxSetGet := "{|| " + cValToChar(aShow[nShow][3]) + " }"
					EndIf
					cAuxPictur := "'" + aShow[nShow][5] + "'"

					cAuxHelp   := "{|| ShowHelpCpo('" + aShow[nShow][6] + "', {'" + aShow[nShow][9] + "'}, 2, {}, 2) }"
					cCalcSize  := cValToChar(aShow[nShow][4])

					// SAY
					oTmpSay := TSay():New(nPosLin, nPosCol, &(cAuxTitle), oScrAll, , If(aShow[nShow][8], oTmpFntBold, ), , ;
											, ,.T., CLR_BLACK, CLR_WHITE, 150, 015)
					// GET
					If !Empty(aShow[nShow][7])
						aAuxCBox   := StrTokArr(aShow[nShow][7], ";")

						oTmpGet := TComboBox():New((nPosLin-001), (nPosCol+050), &(cAuxSetGet), aAuxCBox, &(cCalcSize), 008, oScrAll, , /*bChange*/, /*bValid*/, , , .T./*lPixel*/, , , , {|| .F. }/*bWhen*/)
					Else
						oTmpGet := TGet():New((nPosLin-001), (nPosCol+050), &(cAuxSetGet), oScrAll, &(cCalcSize), 008, &(cAuxPictur), ;
												{|| .T. }, CLR_BLACK, CLR_WHITE, , ;
								 				.F., , .T./*lPixel*/, , .F., {|| .T. }/*bWhen*/, .F., .F., , .T./*lReadOnly*/, .F., "", "", , , , .T./*lHasButton*/)
					EndIf
					oTmpGet:bHelp := &(cAuxHelp)

					// Adiciona ao retorno {Objeto, Número da posição no Array aInfo}
					aAdd(aObjects, { oTmpGet, aTail(aShow[nShow]) })

					// Incrementa a Linha
					nPosLin += 015
				Next nShow

Return aObjects

//---------------------------------------------------------------------
/*/{Protheus.doc} Enable
Método que Habilita a manipulação do Painel de Indicadores.

@author Wagner Sobral de Lacerda
@since 18/08/2012

@return .T./.F.
/*/
//---------------------------------------------------------------------
Method Enable() Class TNGPanel

	// Variáveis da Classe
	Local nMode := ::GetMode()

	//----------
	// Executa
	//----------
	If nMode == _nModeQry
		//--- Modo de CONSULTA
		::oFootAtu:Show()

		::CanConfig(.T.) // Permite Configurar
		::CanSelect(.F.) // Não permite Selecionar Indicadores
		::CanWait(.T.) // Permite ficar 'Em Espera' quando não há um Painel de Indicadores selecionado
	ElseIf nMode == _nModeEdt
		//--- Modo de EDIÇÃO
		::oFootAtu:Hide()

		::CanConfig(.F.) // Não permite Configurar
		::CanSelect(.T.) // Permite Selecionar Indicadores
		::CanWait(.F.) // Não permite ficar 'Em Espera' quando não há um Painel de Indicadores selecionado
	EndIf

	// Indica que o Painel de Indicadores está Habilitado
	::lEnabled := .T.

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} Disable
Método que Desabilita a manipulação do Painel de Indicadores.

@author Wagner Sobral de Lacerda
@since 18/08/2012

@return .T./.F.
/*/
//---------------------------------------------------------------------
Method Disable() Class TNGPanel

	// Desabilita caso esteja Habilitado
	::oFootAtu:Hide()

	::CanConfig(.F.) // Não permite Configurar
	::CanSelect(.F.) // Não permite Selecionar Indicadores
	::CanWait(.F.) // Não permite ficar 'Em Espera' quando não há um Painel de Indicadores selecionado

	// Indica que o Painel de Indicadores está Desabilitado
	::lEnabled := .F.

Return .T.

/*/
############################################################################################
##                                                                                        ##
## MÉTODOS: DESTRUIÇÃO DO PAINÉL                                                          ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} ClearPanel
Método que limpa o Painel de Indicadores.

@author Wagner Sobral de Lacerda
@since 30/04/2012

@return .T./.F.
/*/
//---------------------------------------------------------------------
Method ClearPanel() Class TNGPanel

	// Variável de Controle
	Local nInd := 0

	// Destrói os Indicadores Montados
	For nInd := 1 To Len(::aIndDef)
		If ValType(::aIndDef[nInd][__nIndGraf]) == "O" .And. ::aIndDef[nInd][__nIndGraf]:ClassName() == "TNGINDICATOR"
			::aIndDef[nInd][__nIndGraf]:Destroy()
		EndIf
	Next nInd

	// Limpa o Painel de Indicadores
	::oPanelInd:FreeChildren()

	// Limpa o array
	::aIndDef := {}

	// Indica que limpou o Painel em tela
	::lPanel := .F.

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} Release
Método que libera o Painel atual para que um novo possa ser selecionado.

@author Wagner Sobral de Lacerda
@since 07/05/2012

@return lReturn
/*/
//---------------------------------------------------------------------
Method Release() Class TNGPanel

	// Variável do Retorno
	Local lReturn := .T.

	// Pergunta se realmente deseja liberar o Painel
	If !MsgYesNo(STR0102 + CRLF + ; //"Deseja realmente liberar o Painel de Indicadores atual?"
				STR0103 + CRLF + CRLF + ; //"Se confirmar, este Painel não estará mais automaticamente disponível para consulta. Se desejar consultá-lo, você deverá adicioná-lo novamente."
				STR0104, STR0030) //"Confirmar liberação?" ## "Atenção"
		lReturn := .F.
	EndIf

	//----------
	// Liberação
	//----------
	If lReturn
		// Reinicia em Branco
		::Reset()

		lReturn := .T.
	EndIf

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} Reset
Reinicializa o Painel de Indicadores em Branco.

@author Wagner Sobral de Lacerda
@since 29/05/2012

@return lReturn
/*/
//---------------------------------------------------------------------
Method Reset() Class TNGPanel

	// Limpa o Painel de Indicadores
	::ClearPanel()

	// Deleta Configurações
	fDefineCfg(Self, 3)

	// Esconde Mensagem
	::oMessPnl:Hide()

	// Limpa o Painel carregado
	::cCodFilia := Space(12)
	::cCodModul := Space(02)
	::cCodPanel := Space(06)

	// Salva
	::SaveConfig()

	// Seta o Painel, em branco
	::SetPanel()

	lReturn := .T.

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} Destroy
Método que destrói o objeto Painel de Indicadores.

@author Wagner Sobral de Lacerda
@since 18/08/2011

@return .T. Painel destruído; .F. caso não
/*/
//---------------------------------------------------------------------
Method Destroy() Class TNGPanel

	::oWaitPnl:FreeChildren()
	MsFreeObj(::oWaitPnl)

	::oCadPnl:FreeChildren()
	MsFreeObj(::oCadPnl)

	::oMainPnl:FreeChildren()
	MsFreeObj(::oMainPnl)

	Self:FreeChildren()
	MsFreeObj(Self)

Return .T.

/*/
############################################################################################
##                                                                                        ##
## FUNÇÕES AUXILIARES PARA A CLASSE                                                       ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} fSetCSS
Define um CSS para um botão.

@author Wagner Sobral de Lacerda
@since 02/05/2012

@param nEstilo
	Indica o estilo do CSS de acordo com o botão: * Obrigatório
	   0 - Botão em Espera
	   1 - Rodapé
	   2 - Botões do Rodapé
	   3 - Botões Normais
	   4 - Botões de Confirmar
	   5 - Botões de Cancelar
	   6 - Botões de Link
@param oObjBtn
	Referencia o Objeto do Botão (TButton) * Obrigatório

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fSetCSS(nEstilo, oObjBtn)

	// Variáveis das Cores em Hexadecimal a serem aplicadas
	Local cUsaBack1 := "", cUsaBack2 := "", cUsaBack3 := ""
	Local cUsaFore1 := "", cUsaFore2 := "", cUsaFore3 := ""
	Local cUsaBord1 := "", cUsaBord2 := "", cUsaBord3 := ""
	Local cUsaGrad1 := "", cUsaGrad2 := "", cUsaGrad3 := ""

	// Variáveis da Fonte
	Local cFontSize   := "12"
	Local cFontWeight := "bold"
	Local cBordRadius := "3"

	// Variável de Decorações da Fonte
	Local lUnderline := ( nEstilo == 6 )

	//----------------------------------------
	// Define as cores a serem utilizadas
	//----------------------------------------
	If nEstilo == 0
		//------------------------------
		// Botão em Espera
		//------------------------------

		cFontSize   := "14"
		cFontWeight := "bold"
		cBordRadius := "0"

		cUsaGrad1 := "#F5F5F5" // WhiteSmoke
		cUsaGrad2 := "#FFFFFF" // White
		cUsaGrad3 := "#FFFFFF" // White

		cUsaBack1 := "#DCDCDC" // Gainsboro
		cUsaBack2 := "#E8E8E8" // Grey91
		cUsaBack3 := "#F5F5F5" // WhiteSmoke

		cUsaFore1 := "#828282" // Grey51
		cUsaFore2 := "#000000" // Black
		cUsaFore3 := "#000000" // Black

		cUsaBord1 := "#D3D3D3" // LightGray
		cUsaBord2 := "#D3D3D3" // LightGray
		cUsaBord3 := "#708090" // SlateGrey

	ElseIf nEstilo == 1
		//------------------------------
		// Barra do Rodapé
		//------------------------------

		cFontSize   := "10"
		cFontWeight := "normal"
		cBordRadius := "0"

		cUsaGrad1 := "#F8F8FF" // GhostWhite
		cUsaGrad2 := "#F8F8FF" // GhostWhite
		cUsaGrad3 := "#F8F8FF" // GhostWhite

		cUsaBack1 := "#F4F4F4" // Personalizado - Cinza Claro
		cUsaBack2 := "#FFFAFA" // Snow
		cUsaBack3 := "#E8E8E8" // Gray91

		cUsaFore1 := "#BEBEBE" // Grey
		cUsaFore2 := "#000000" // Black
		cUsaFore3 := "#000000" // Black

		cUsaBord1 := "#D3D3D3" // LightGray
		cUsaBord2 := "#D3D3D3" // LightGray
		cUsaBord3 := "#D3D3D3" // LightGray

	ElseIf nEstilo == 2
		//------------------------------
		// Botões do Rodapé
		//------------------------------

		cBordRadius := "2"

		cUsaGrad1 := "#FAFAFA" // Cinza Claro -  Personalizado (RGB: 250,250,250)
		cUsaGrad2 := "#FDFDFD" // Cinza Claro -  Personalizado (RGB: 253,253,253)
		cUsaGrad3 := "#FDFDFD" // Cinza Claro -  Personalizado (RGB: 253,253,253)

		cUsaBack1 := "#F3F3F3" // Cinza Claro -  Personalizado(RGB: 243,243,243)
		cUsaBack2 := "#E6E6E6" // Cinza Claro -  Personalizado(RGB: 230,230,230)
		cUsaBack3 := "#E6E6E6" // Cinza Claro -  Personalizado(RGB: 230,230,230)

		cUsaFore1 := "#999999" // Cinza Escuro -  Personalizado(RGB: 153,153,153)
		cUsaFore2 := "#787878" // Cinza Escuro -  Personalizado(RGB: 120,120,120)
		cUsaFore3 := "#787878" // Cinza Escuro -  Personalizado(RGB: 120,120,120)

		cUsaBord1 := "#D3D3D3" // LightGray
		cUsaBord2 := "#BEBEBE" // Grey
		cUsaBord3 := "#828282" // Grey51

	ElseIf nEstilo == 3
		//------------------------------
		// Botões Normais
		//------------------------------

		cFontSize   := "11"
		cFontWeight := "normal"

		cUsaGrad1 := "#F8F8FF" // GhostWhite
		cUsaGrad2 := "#F8F8FF" // GhostWhite
		cUsaGrad3 := "#F8F8FF" // GhostWhite

		cUsaBack1 := "#ECECEC" // Cinza Claro - Personalizado
		cUsaBack2 := "#E6E6E6" // Cinza Claro - Personalizado
		cUsaBack3 := "#E6E6E6" // Cinza Claro - Personalizado

		cUsaFore1 := "#4F4F4F" // Grey31
		cUsaFore2 := "#000000" // Black
		cUsaFore3 := "#000000" // Black

		cUsaBord1 := "#D3D3D3" // LightGray
		cUsaBord2 := "#BEBEBE" // Grey
		cUsaBord3 := "#828282" // Grey51

	ElseIf nEstilo == 4
		//------------------------------
		// Botões de Confirmar
		//------------------------------

		cUsaGrad1 := "#7AA8FF" // RoyalBlue1 - Personalizado (mais claro para contraste + 50 em RG)
		cUsaGrad2 := "#ACDAFF" // RoyalBlue1 - Personalizado (mais claro para contraste + 100 em RG)
		cUsaGrad3 := "#ACDAFF" // RoyalBlue1 - Personalizado (mais claro para contraste + 100 em RG)

		cUsaBack1 := "#4876FF" // RoyalBlue1
		cUsaBack2 := "#436EEE" // RoyalBlue2
		cUsaBack3 := "#436EEE" // RoyalBlue2

		cUsaFore1 := "#FFFFFF" // White
		cUsaFore2 := "#FFFFFF" // White
		cUsaFore3 := "#FFFFFF" // White

		cUsaBord1 := "#D3D3D3" // LightGray
		cUsaBord2 := "#BEBEBE" // Grey
		cUsaBord3 := "#6495ED" // CornflowerBlue

	ElseIf nEstilo == 5
		//------------------------------
		// Botões de Cancelar
		//------------------------------

		cUsaGrad1 := "#FF9579" // Tomato1 - Personalizado (mais claro para contraste + 50 em GB)
		cUsaGrad2 := "#FFC7AB" // Tomato1 - Personalizado (mais claro para contraste + 100 em GB)
		cUsaGrad3 := "#FFC7AB" // Tomato1 - Personalizado (mais claro para contraste + 100 em GB)

		cUsaBack1 := "#FF6347" // Tomato1
		cUsaBack2 := "#EE5C42" // Tomato2
		cUsaBack3 := "#EE5C42" // Tomato2

		cUsaFore1 := "#FFFFFF" // White
		cUsaFore2 := "#FFFFFF" // White
		cUsaFore3 := "#FFFFFF" // White

		cUsaBord1 := "#D3D3D3" // LightGray
		cUsaBord2 := "#BEBEBE" // Grey
		cUsaBord3 := "#CD4F39" // Tomato3

	ElseIf nEstilo == 6
		//------------------------------
		// Botões de Link
		//------------------------------

		cFontSize   := "11"
		cFontWeight := "normal"

		cUsaGrad1 := "#FFFFFF" // White
		cUsaGrad2 := "#FFFFFF" // White
		cUsaGrad3 := "#FFFFFF" // White

		cUsaBack1 := "#FFFFFF" // White
		cUsaBack2 := "#FFFFFF" // White
		cUsaBack3 := "#FFFFFF" // White

		cUsaFore1 := "#4F4F4F" // Grey31
		cUsaFore2 := "#000000" // Black
		cUsaFore3 := "#9C9C9C" // Grey61

		cUsaBord1 := "#FFFFFF" // White
		cUsaBord2 := "#FFFFFF" // White
		cUsaBord3 := "#FFFFFF" // White

	EndIf

	//--------------------
	// Seta o CSS
	//--------------------
	/*
	oObjBtn:SetCSS("QPushButton{ background-color: " + cUsaBack1 + "; color: " + cUsaFore1 + "; font-size: " + cFontSize + "px; font-weight: " + cFontWeight + "; border: 1px solid " + cUsaBord1 + "; border-radius: " + cBordRadius + "px; } " + ;
					"QPushButton:Hover{ background-color: " + cUsaBack2 + "; color: " + cUsaFore2 + "; border: 1px solid " + cUsaBord2 + "; } " + ;
					"QPushButton:Pressed{ background-color: " + cUsaBack3 + "; color: " + cUsaFore3 + "; border: 1px solid " + cUsaBord3 + "; } ")
	*/
	oObjBtn:SetCSS("QPushButton{ background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1 stop: 0 " + cUsaGrad1 + ", stop: 0.4 " + cUsaBack1 + "); color: " + cUsaFore1 + "; font-size: " + cFontSize + "px; font-weight: " + cFontWeight + "; border: 1px solid " + cUsaBord1 + "; border-radius: " + cBordRadius + "px; " + If(lUnderline, "text-decoration: underline;", "") + " } " + ;
					"QPushButton:Hover{ background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1 stop: 0 " + cUsaGrad2 + ", stop: 0.4 " + cUsaBack2 + "); color: " + cUsaFore2 + "; border: 1px solid " + cUsaBord2 + "; " + If(lUnderline, "text-decoration: underline;", "") + " } " + ;
					"QPushButton:Pressed{ background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1 stop: 0 " + cUsaGrad3 + ", stop: 0.4 " + cUsaBack3 + "); color: " + cUsaFore3 + "; border: 1px solid " + cUsaBord3 + "; " + If(lUnderline, "text-decoration: underline;", "") + " } ")

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fDefineCfg
Cria um arquivo de configuração para o Painel carregado.

@author Wagner Sobral de Lacerda
@since 02/05/2012

@param oClassPanel
	Objeto da Classe TNGPanel (Paniél de Indicadores) * Obrigatório
@param nOption
	Indica a Opção a ser executada pela função * Opcional
	   1 - Save (Salvar os dados)
	   2 - Load (Carregar os dados)
	   3 - Delete (Deleta os dados)
	Default: 2

@return uReturn
/*/
//---------------------------------------------------------------------
Static Function fDefineCfg(oClassPanel, nOption)

	// Variáveis da Classe
	Local cCodFunc  := oClassPanel:cLoadFunc
	Local cCodUser  := oClassPanel:cLoadUser
	Local cCodPanel := oClassPanel:cCodPanel
	Local cCodFilia := oClassPanel:cCodFilia
	Local cCodModul := oClassPanel:cCodModul
	Local aConfig   := oClassPanel:aConfig
	Local aIndDef   := oClassPanel:aIndDef
	Local aParams   := aClone( oClassPanel:GetParams() )

	// Variáveis de Bloco de Código
	Local bCustomiz := oClassPanel:GetCodeBlock(__nBCusPnl)

	// Variáveis da Configuração
	Local aCustom := {}
	Local nInds := 0, nPars := 0, nScanAux := 0, nLenAux := 0

	Local cParTipo := ""

	// Variáveis das Posições da Customização
	Local nCodUsuari := 0
	Local nCodPainel := 0
	Local nCodFuncao := 0
	Local nCodFilial := 0
	Local nCodModulo := 0
	Local nAllIndics := 0
	Local nAllParams := 0
	Local nAllCustom := 0

	// Variável do Retorno
	Local uReturn := Nil

	// Defaults
	Default nOption := 2

	//------------------------------
	// Verifica Função e Usuário
	//------------------------------
	If Empty(cCodFunc)
		cCodFunc := AllTrim( FunName() )
	EndIf
	If Empty(cCodUser)
		cCodUser := AllTrim( RetCodUsr() )
	EndIf

	//------------------------------
	// Verifica Painel
	//------------------------------
	// NÃO pode Salvar nem Carregar sem o Código do Painel
	If Empty(cCodPanel)
		uReturn := If(nOption == 1, .F., {})
		Return uReturn
	EndIf

	//------------------------------
	// Estrutura do Conteúdo
	//------------------------------
	aCustom := {}
	aAdd(aCustom, {"CODEUSER"  , cCodUser } ) // [01] - Código do Usuário do Sistema
	aAdd(aCustom, {"CODEPANEL" , cCodPanel} ) // [03] - Código do Painel de Indicadores
	aAdd(aCustom, {"CODEFUNC"  , cCodFunc } ) // [03] - Código da Função Pai
	aAdd(aCustom, {"CODEBRANCH", cCodFilia} ) // [04] - Código do Painel de Indicadores
	aAdd(aCustom, {"CODEMODULE", cCodModul} ) // [05] - Código do Painel de Indicadores
	aAdd(aCustom, {"INDICATORS", {}       } ) // [06] - Array com as Indicadores do Painel de Indicadores
	For nInds := 1 To Len(aIndDef)
		aAdd(aCustom[6][2], {aIndDef[nInds][__nIndForm], aIndDef[nInds][__nIndValu], "N"} ) // [06][02][nInds] - Fórmula do Indicador
	Next nInds
	aAdd(aCustom, {"PARAMETERS", {}       } ) // [07] - Array com as Parâmetros do Painel de Indicadores
	For nPars := 1 To Len(aParams)
		cParTipo := aParams[nPars][__nParTipo]
		Do Case
			Case cParTipo == "2"
				cParTipo := "N"
			Case cParTipo == "3"
				cParTipo := "L"
			Case cParTipo == "4"
				cParTipo := "D"
			Otherwise
				cParTipo := "C"
		EndCase
		aAdd(aCustom[7][2], {aParams[nPars][__nParCodi], aParams[nPars][__nParCont], cParTipo} ) // [07][02][nPars] - ParÇametro do Painel de Indicadores
	Next nPars
	aAdd(aCustom, {"CUSTOM"    , {}       } ) // [08] - Array com as Customizações
		aAdd(aCustom[8][2], {"INTERFACE" , If(oClassPanel:GetGraphic(), "1", "2"), "C"} ) // [08][02][01] - Tipo da Interface
		aAdd(aCustom[8][2], {"TITLEPANEL", If(aConfig[__nCfgTPnl], "1", "0"), "C"} ) // [08][02][02] - Tótulo do Painel de Indicadores
		aAdd(aCustom[8][2], {"TITLEINDS" , If(aConfig[__nCfgTInd], "1", "0"), "C"} ) // [08][02][03] - Tótulo dos Indicadores do Painel
		aAdd(aCustom[8][2], {"TOTALIZERS", If(aConfig[__nCfgTota], "1", "0"), "C"} ) // [08][02][04] - Exibir Totalizadores
		aAdd(aCustom[8][2], {"THEME"     , If(aConfig[__nCfgThem], "1", "0"), "C"} ) // [08][02][05] - Exibir configurações do Tema do Protheus
		aAdd(aCustom[8][2], {"LASTVALUES", If(aConfig[__nCfgLast], "1", "0"), "C"} ) // [08][02][06] - Armazenar os últimos Valores calculados nos Indicadores do Painel
		aAdd(aCustom[8][2], {"CALCULATE" , If(aConfig[__nCfgCalc], "1", "0"), "C"} ) // [08][02][07] - Indica se pode realizar novos Cálculos nos Indicadores do Painel
		aAdd(aCustom[8][2], {"ANIMATE"   , If(aConfig[__nCfgAnim], "1", "0"), "C"} ) // [08][02][08] - Indica se pode executar a Animação dos Indicaodres do Painel

	//-- Já define as principais posições utilizadas
	nCodUsuari := aScan(aCustom, {|x| AllTrim(x[1]) == "CODEUSER"  })
	nCodPainel := aScan(aCustom, {|x| AllTrim(x[1]) == "CODEPANEL" })
	nCodFuncao := aScan(aCustom, {|x| AllTrim(x[1]) == "CODEFUNC"  })
	nCodFilial := aScan(aCustom, {|x| AllTrim(x[1]) == "CODEBRANCH"})
	nCodModulo := aScan(aCustom, {|x| AllTrim(x[1]) == "CODEMODULE"})
	nAllIndics := aScan(aCustom, {|x| AllTrim(x[1]) == "INDICATORS"})
	nAllParams := aScan(aCustom, {|x| AllTrim(x[1]) == "PARAMETERS"})
	nAllCustom := aScan(aCustom, {|x| AllTrim(x[1]) == "CUSTOM"    })

	//------------------------------
	// Executa a Opção
	//------------------------------
	If ValType(bCustomiz) == "B"
		uReturn := Eval(bCustomiz, aCustom, nOption)
	EndIf
	If nOption == 2
		//----------
		// Load
		//----------
		uReturn := Array(__nCfgQtde)

		//----------------------------------------
		// Indicador atualmente Carregado
		//----------------------------------------
		uReturn[__nCfgLoad] := Array(3)
		uReturn[__nCfgLoad][1] := aCustom[nCodFilial][2]
		uReturn[__nCfgLoad][2] := aCustom[nCodPainel][2]
		uReturn[__nCfgLoad][3] := aCustom[nCodModulo][2]

		//----------------------------------------
		// Confiugrações
		//----------------------------------------
		//--- Tipo de Interface
		uReturn[__nCfgInte] := .T.
		nScanAux := aScan(aCustom[nAllCustom][2], {|x| AllTrim(x[1]) == "INTERFACE" })
		If nScanAux > 0
			uReturn[__nCfgInte] := AllTrim(aCustom[nAllCustom][2][nScanAux][2])
		EndIf

		//--- Título do Painel de Indicadores
		uReturn[__nCfgTPnl] := .T.
		nScanAux := aScan(aCustom[nAllCustom][2], {|x| AllTrim(x[1]) == "TITLEPANEL" })
		If nScanAux > 0
			uReturn[__nCfgTPnl] := ( AllTrim(aCustom[nAllCustom][2][nScanAux][2]) == "1" )
		EndIf

		//--- Título dos Indicadores
		uReturn[__nCfgTInd] := .T.
		nScanAux := aScan(aCustom[nAllCustom][2], {|x| AllTrim(x[1]) == "TITLEINDS" })
		If nScanAux > 0
			uReturn[__nCfgTInd] := ( AllTrim(aCustom[nAllCustom][2][nScanAux][2]) == "1" )
		EndIf

		//--- Totalizadores
		uReturn[__nCfgTota] := .T.
		nScanAux := aScan(aCustom[nAllCustom][2], {|x| AllTrim(x[1]) == "TOTALIZERS" })
		If nScanAux > 0
			uReturn[__nCfgTota] := ( AllTrim(aCustom[nAllCustom][2][nScanAux][2]) == "1" )
		EndIf

		//--- Tema do Protheus
		uReturn[__nCfgThem] := .T.
		nScanAux := aScan(aCustom[nAllCustom][2], {|x| AllTrim(x[1]) == "THEME" })
		If nScanAux > 0
			uReturn[__nCfgThem] := ( AllTrim(aCustom[nAllCustom][2][nScanAux][2]) == "1" )
		EndIf

		//--- Último Valor
		uReturn[__nCfgLast] := .T.
		nScanAux := aScan(aCustom[nAllCustom][2], {|x| AllTrim(x[1]) == "LASTVALUES" })
		If nScanAux > 0
			uReturn[__nCfgLast] := ( AllTrim(aCustom[nAllCustom][2][nScanAux][2]) == "1" )
		EndIf

		//--- Cálculo
		uReturn[__nCfgCalc] := .T.
		nScanAux := aScan(aCustom[nAllCustom][2], {|x| AllTrim(x[1]) == "CALCULATE" })
		If nScanAux > 0
			uReturn[__nCfgCalc] := ( AllTrim(aCustom[nAllCustom][2][nScanAux][2]) == "1" )
		EndIf

		//--- Animação
		uReturn[__nCfgAnim] := .T.
		nScanAux := aScan(aCustom[nAllCustom][2], {|x| AllTrim(x[1]) == "ANIMATE" })
		If nScanAux > 0
			uReturn[__nCfgAnim] := ( AllTrim(aCustom[nAllCustom][2][nScanAux][2]) == "1" )
		EndIf

		//----------------------------------------
		// Indicadores do Painel e seus Valores
		//----------------------------------------
		//--- Indicadores
		uReturn[__nCfgInds] := {}
		For nInds := 1 To Len(aCustom[nAllIndics][2])
			nScanAux := aScan(uReturn[__nCfgInds], {|x| AllTrim(x[1]) == AllTrim(aCustom[nAllIndics][2][nInds][1]) })
			If nScanAux == 0
				aAdd(uReturn[__nCfgInds], {AllTrim(aCustom[nAllIndics][2][nInds][1]), 0}) // 1=Fórmula ; 2=Valor
				nLenAux := Len(uReturn[__nCfgInds])

				// Último Valor?
				If uReturn[__nCfgLast]
					uReturn[__nCfgInds][nLenAux][2] := aCustom[nAllIndics][2][nInds][2]
				EndIf
			EndIf
		Next nInds

		//----------------------------------------
		// Parâmetros do Painel e seus Valores
		//----------------------------------------
		//--- Parâmetros
		uReturn[__nCfgPars] := {}
		For nPars := 1 To Len(aCustom[nAllParams][2])
			nScanAux := aScan(uReturn[__nCfgPars], {|x| AllTrim(x[1]) == AllTrim(aCustom[nAllParams][2][nPars][1]) })
			If nScanAux == 0
				aAdd(uReturn[__nCfgPars], {AllTrim(aCustom[nAllParams][2][nPars][1]), aCustom[nAllParams][2][nPars][2]}) // 1=Parâmetro ; 2=Conteúdo
			EndIf
		Next nPars
	EndIf

Return uReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} fConvPar
Converte o valor de uma variável de acordo com o tipo do PARÂMETRO.

@author Wagner Sobral de Lacerda
@since 07/05/2012

@param [xValue]   , Variável, Valor atual
@param [cTipoConv], Caracter, Tipo de Dado para conversão
@param [nTamanho] , Numérico, Tamanho desejado para o valor convertido
@param [nDecimal] , Numérico, Decimal desejado para o valor convertido
@param cCodPar    , Caracter, Representa o código do parâmetro

@return xConvert
/*/
//---------------------------------------------------------------------
Static Function fConvPar(xValue, cTipoConv, nTamanho, nDecimal, cCodPar)

	// Variáveis para a Convertsão
	Local xConvert := xValue
	Local cTipo    := ValType(xConvert)

	Default cCodPar := ""

	//----------
	// Converte
	//----------
	Do Case

		Case cTipoConv == "1" .Or. cTipoConv == "5" .Or. cTipoConv == "C" // para Caractere OU Campo

			If cTipo == "C"
				If !Empty(cCodPar) .And. "ATE_" $ cCodPar // Caso seja 'Caracter' e seja com código 'ATE'
					xConvert := Replicate('Z',nTamanho)
				Else
					xConvert := PADR(xConvert, (nTamanho + nDecimal), " ")
				Endif
			ElseIf cTipo == "D"
				xConvert := DTOS(xConvert)
			ElseIf cTipo == "L"
				xConvert := If(xConvert, "1", "0") // Binário ("1"=Verdadeiro; "0"=Falso)
			ElseIf cTipo == "N"
				xConvert := cValToChar(xConvert)
			EndIf

		Case cTipoConv == "2" .Or. cTipoConv == "N" // para Numérico

			If cTipo == "C"
				xConvert := Val(xConvert)
			EndIf

		Case cTipoConv == "3" .Or. cTipoConv == "L" // para Lógico

			If cTipo == "C"
				xConvert := If(xConvert == "1", .T., .F.) // Binário (1=Verdadeiro; 0=Falso)
			EndIf

		Case cTipoConv == "4" .Or. cTipoConv == "D" // para Data

			If cTipo == "C"
				xConvert := STOD(xConvert)
			EndIf

			If Empty(xConvert) // Caso não tenha data preenchida.
				xConvert := dDataBase // Preenche com a data atual.
			EndIf

		Case cTipoConv == "6" // para Lista de Opções

			If cTipo == "C"
				xConvert := SubStr(xConvert, 1, 1)
			EndIf

	EndCase

Return xConvert

//---------------------------------------------------------------------
/*/{Protheus.doc} fShowMsg
Função auxilixar da classe TNGPanel:
Mostra uma mensagem em tela.
Se houver um tela, será apresentado um Help(), senão, uma Msg()

@author Wagner Sobral de Lacerda
@since 15/02/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fShowMsg(cMsg, cType)

	Local cTitulo := STR0030 //"Atenção"
	Local nAlerta := ""

	// Defaults
	Default cMsg  := ""
	Default cType := ""

	If !IsBlind()
		Help(Nil, Nil, cTitulo, Nil, cMsg, 1, 0)
	Else

		Do Case
			Case cType == "I" // Informativo
				nAlerta := 64 // MB_ICONASTERISK
			Case cType == "E" // Erro
				nAlerta := 16 // MB_ICONHAND
			Otherwise // Alerta
				nAlerta := 48 // MB_ICONEXCLAMATION
		EndCase
		MessageBox(cMsg, cTitulo, nAlerta)
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fHasInterface
Função auxilixar da classe TNGPanel:
Verifica se a interface com o usuário foi criada, retornando falso
caso não tenha sido, bem como uma mensagem.

@author Wagner Sobral de Lacerda
@since 15/02/2012

@param lShowMsg
	Indica se deve mostrar ou não a mensagem * Opcional
	   .T. - Mostra
	   .F. - Não mostra
	Default: .T.

@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fHasInterface(lShowMsg)

	// Defaults
	Default lShowMsg := .T.

	// Verifica Interface
	If IsBlind()
		fShowMsg(STR0105 + CRLF + CRLF +; //"Não é possível executar a ação pois a interface com o usuário não foi devidamente criada."
				STR0096, "E") //"Se esta funcionalidade já foi executada anteriormente nestas mesmas condições, favor comunicar o Administrador do Sistema."
		Return .F.
	EndIf

Return .T.

/*/
############################################################################################
##                                                                                        ##
## FUNÇÕES AUXILIARES PARA A CONSULTA PERSONALIZADA AOS PANÉIS CADASTRADOS                ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} fSelectPanel
Função da Consulta de Painéis de Indicadores.

@author Wagner Sobral de Lacerda
@since 14/06/2012

@return aReturn
/*/
//---------------------------------------------------------------------
Static Function fSelectPanel(oTNGPanel)

	// Variável do Retorno
	Local aReturn := {}

	// Variáveis de Bloco de Código
	Local bConsPnls := oTNGPanel:GetCodeBlock(__nBConPnl)

	// Seleciona o Painel de Indicadores
	If ValType(bConsPnls) == "B"
		aReturn := Eval(bConsPnls)
	EndIf

Return aReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} tngPaValid
Validação da Tela de Parametros dos indicadores
@author  Vitor Bonet
@since   17/09/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function tngPaValid()

Local nTamTot   := Len(aTotParams)
Local nParam    := 0

// Varre todos os parametros, encontra os obrigatórios e verifica se estão preenchidos.
For nParam := 1 To nTamTot
	If aTotParams[nParam][__nParObri]
		If Empty(aGetParams[nParam] )
			fShowMsg(STR0107, "I") // "Existem parâmetros obrigtórios não preenchidos."
			Return .F.
		EndIf
	EndIf
Next nParam

Return .T.
