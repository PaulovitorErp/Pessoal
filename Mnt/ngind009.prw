#INCLUDE	"Protheus.ch"
#INCLUDE	"NGIND009.ch"
#INCLUDE	"FWBrowse.ch"
#INCLUDE	"FWMVCDEF.CH"

#DEFINE _nVERSAO 1 //Versao do fonte

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND009
Histórico de Indicadores.

@author Wagner Sobral de Lacerda
@since 17/09/2012

@return lExecute
/*/
//---------------------------------------------------------------------
Function NGIND009()
	
	//------------------------------
	// Armazena as variáveis
	//------------------------------
	Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)
	
	Local lExecute := .T. // Variável para identificar se pode ou não executar esta rotina
	Local oBrowse // Variável do Browse
	
	//-------------------------------
	// Valida a execução do programa
	//-------------------------------
	lExecute := NGIND007OP()
	
	If lExecute
		// Declara as Variáveis PRIVATE
		NGIND009VR()
		
		//----------------
		// Monta o Browse
		//----------------
		dbSelectArea("TZB")
		dbSetOrder(1)
		dbGoTop()
		
		// Instanciamento da Classe de Browse
		oBrowse := FWMBrowse():New()
			
			// Definição da tabela do Browse
			oBrowse:SetAlias("TZE")
			
			// Descrição do Browse
			oBrowse:SetDescription(cCadastro)
			
			// Menu Funcional relacionado ao Browse
			oBrowse:SetMenuDef("NGIND009")
			
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
@since 18/09/2012

@return aRotina array com o Menu MVC
/*/
//---------------------------------------------------------------------
Static Function MenuDef()
	
	// Variável do Menu
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0001 ACTION "VIEWDEF.NGIND009" OPERATION 2 ACCESS 0 //"Visualizar"
	
Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} fCposExcep
Monta o Array com a excecao de campos para o Modelo/View.

@author Wagner Sobral de Lacerda
@since 24/01/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fCposExcep()
	
	// Exceção de campos na View da tabela TZG
	aVCpoTZF := {}
	aAdd(aVCpoTZF, "TZF_CODIGO")
	
	// Exceção de campos na View da tabela TZF
	aVCpoTZG := {}
	aAdd(aVCpoTZG, "TZG_CODIGO")
	
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
@since 18/09/2012

@return oModel objeto do Modelo MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()
	
	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruTZE := FWFormStruct(1, "TZE", /*bAvalCampo*/, /*lViewUsado*/)
	Local oStruTZF := FWFormStruct(1, "TZF", /*bAvalCampo*/, /*lViewUsado*/)
	Local oStruTZG := FWFormStruct(1, "TZG", /*bAvalCampo*/, /*lViewUsado*/)
	
	// Modelo de dados que será construído
	Local oModel
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("NGIND009", /*bPreValid*/, /*bPosValid*/, /*bFormCommit*/, /*bFormCancel*/)
		
		//--------------------------------------------------
		// Componentes do Modelo
		//--------------------------------------------------
		
		// Adiciona ao modelo um componente de Formulário Principal
		oModel:AddFields("TZEMASTER"/*cID*/, /*cIDOwner*/, oStruTZE/*oModelStruct*/, /*bPre*/, /*bPost*/, /*bLoad*/)
		
		// Adiciona ao modelo um componente de Grid, com o "TZBMASTER" como Owner
		oModel:AddGrid("TZFDATA"/*cID*/, "TZEMASTER"/*cIDOwner*/, oStruTZF/*oModelStruct*/, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)
			// Define a Relação do modelo das F´rmulas com o Principal (Indicador Gráfico)
			oModel:SetRelation("TZFDATA"/*cIDGrid*/,;
								{ {"TZF_FILIAL", 'xFilial("TZE")'}, {"TZF_CODIGO", "TZE_CODIGO"} }/*aConteudo*/,;
								TZF->( IndexKey(3) )/*cIndexOrd*/)
		
		// Adiciona ao modelo um componente de Grid, com o "TZBMASTER" como Owner
		oModel:AddGrid("TZGPARAMS"/*cID*/, "TZEMASTER"/*cIDOwner*/, oStruTZG/*oModelStruct*/, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)
			// Define a Relação do modelo das F´rmulas com o Principal (Indicador Gráfico)
			oModel:SetRelation("TZGPARAMS"/*cIDGrid*/,;
								{ {"TZG_FILIAL", 'xFilial("TZE")'}, {"TZG_CODIGO", "TZE_CODIGO"} }/*aConteudo*/,;
								TZG->( IndexKey(3) )/*cIndexOrd*/)
		
		// Adiciona a descrição do Modelo de Dados (Geral)
		oModel:SetDescription(STR0002/*cDescricao*/) //"Histórico de Indicadores"
			
			//--------------------------------------------------
			// Definições do Modelo
			//--------------------------------------------------
			
			// Adiciona a descrição do Modelo de Dados TZB
			oModel:GetModel("TZEMASTER"):SetDescription(STR0003/*cDescricao*/) //"Histórido de Resultados"
			
			// Adiciona a descrição do Modelo de Dados TZC
			oModel:GetModel("TZFDATA"):SetDescription(STR0004/*cDescricao*/) //"Histórico de Dados"
			
			// Adiciona a descrição do Modelo de Dados TZC
			oModel:GetModel("TZGPARAMS"):SetDescription(STR0005/*cDescricao*/) //"Histórico de Parâmetros"
	
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
@since 18/09/2012

@return oView objeto da View MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()
	
	// Dimensionamento de Tela
	Local aScreen  := aClone( GetScreenRes() )
	Local nAltura  := aScreen[2]
	
	Local aPorcen := {}
	Local nPixels := If(nAltura >= 1024, 400, 350) // Pixels para o cabeçalho
	
	// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oModel := FWLoadModel("NGIND009")
	
	// Cria a estrutura a ser usada na View
	Local oStruTZE := FWFormStruct(2, "TZE", /*bAvalCampo*/, /*lViewUsado*/)
	Local oStruTZF := FWFormStruct(2, "TZF", {|cCampo| fStructCpo(cCampo, "TZF") }/*bAvalCampo*/, /*lViewUsado*/)
	Local oStruTZG := FWFormStruct(2, "TZG", {|cCampo| fStructCpo(cCampo, "TZG") }/*bAvalCampo*/, /*lViewUsado*/)
	
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
		oView:AddField("VIEW_TZEMASTER"/*cFormModelID*/, oStruTZE/*oViewStruct*/, "TZEMASTER"/*cLinkID*/, /*bValid*/)
		
		// Adiciona no View um controle do tipo Grid (antiga Getdados)
		oView:AddGrid("VIEW_TZFDATA"/*cFormModelID*/, oStruTZF/*oViewStruct*/, "TZFDATA"/*cLinkID*/, /*bValid*/)
		
		// Adiciona no View um controle do tipo Grid (antiga Getdados)
		oView:AddGrid("VIEW_TZGPARAMS"/*cFormModelID*/, oStruTZG/*oViewStruct*/, "TZGPARAMS"/*cLinkID*/, /*bValid*/)
		
		//--------------------------------------------------
		// Layout
		//--------------------------------------------------
		
		// Cria os componentes "box" horizontais para receberem elementos da View
		aPorcen := Array(2)
		aPorcen[1] := ( (nPixels * 100) / nAltura ) // Quero 'nPixels' para a Altura
		aPorcen[2] := ( 100 - aPorcen[1] )
		oView:CreateHorizontalBox("BOX_SUPERIOR"/*cID*/, aPorcen[1]/*nPercHeight*/, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)
		oView:CreateHorizontalBox("BOX_INFERIOR"/*cID*/, aPorcen[2]/*nPercHeight*/, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)
			
			//Cria os componentes "box" verticais dentro do box horizontal
			oView:CreateVerticalBox("BOX_INFERIOR_ESQ"/*cID*/, 050/*nPercHeight*/, "BOX_INFERIOR"/*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)
			oView:CreateVerticalBox("BOX_INFERIOR_DIR"/*cID*/, 050/*nPercHeight*/, "BOX_INFERIOR"/*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)
				
				// Cria os componentes "box" horizontais, dentro dos verticais
				oView:CreateHorizontalBox("BOX_DATA"  /*cID*/, 100/*nPercHeight*/, "BOX_INFERIOR_ESQ"/*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)
				oView:CreateHorizontalBox("BOX_PARAMS"/*cID*/, 100/*nPercHeight*/, "BOX_INFERIOR_DIR"/*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)
		
		// Relaciona o identificador (ID) da View com o "box" para exibição
		oView:SetOwnerView("VIEW_TZEMASTER"/*cFormModelID*/, "BOX_SUPERIOR"/*cIDUserView*/)
		oView:SetOwnerView("VIEW_TZFDATA"  /*cFormModelID*/, "BOX_DATA"    /*cIDUserView*/)
		oView:SetOwnerView("VIEW_TZGPARAMS"/*cFormModelID*/, "BOX_PARAMS"  /*cIDUserView*/)
		
		// Adiciona um Título para a View
		oView:EnableTitleView("VIEW_TZEMASTER"/*cFormModelID*/, /*cTitle*/, /*nColor*/)
		oView:EnableTitleView("VIEW_TZFDATA"  /*cFormModelID*/, /*cTitle*/, /*nColor*/)
		oView:EnableTitleView("VIEW_TZGPARAMS"/*cFormModelID*/, /*cTitle*/, /*nColor*/)
		
Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} fStructCpo
Valida os campos da estrutura do Modelo ou View.

@author Wagner Sobral de Lacerda
@since 19/09/2012

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
	If cEstrutura == "TZF"
		aExcecao := aClone( aVCpoTZF )
	ElseIf cEstrutura == "TZG"
		aExcecao := aClone( aVCpoTZG )
	EndIf
	
	// Valida o Campo
	If aScan(aExcecao, {|x| AllTrim(x) == AllTrim(cCampo) }) > 0
		Return .F.
	EndIf
	
Return .T.

/*/
############################################################################################
##                                                                                        ##
## FUNÇÕES AUXILIARES DA ROTINA                                                           ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND008VR
Declara as variáveis Private utilizadas no Histórico de Indicadores.
* Lembrando que essas variáveis ficam declaradas somente para a função
que é Pai imediata desta.

@author Wagner Sobral de Lacerda
@since 18/09/2012

@return .T.
/*/
//---------------------------------------------------------------------
Function NGIND009VR()
	
	//------------------------------
	// Declara as variáveis
	//------------------------------
	
	// Variável do Cadastro
	_SetOwnerPrvt("cCadastro", OemToAnsi(STR0002)) //"Histórico de Indicadores"
	
	// Exceção de Campos
	_SetOwnerPrvt("aVCpoTZF", {}) // Variável de exceção de campos na View da TZF
	_SetOwnerPrvt("aVCpoTZG", {}) // Variável de exceção de campos na View da TZG
	
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
/*/{Protheus.doc} NGIND009IP
Função para INICIALIZADOR PADRÃO.

@author Wagner Sobral de Lacerda
@since 19/09/2012

@param cCampo
	ID do Campo do dicionário SX3 * Obrigatório

@return cIniPad
/*/
//---------------------------------------------------------------------
Function NGIND007IP(cCampo)
	
	// Variável do Retorno 'INICIALIZADOR PADRÃO'
	Local cIniPad := ""
	
	// Defaults
	Default cCampo := ""
	
	//----------
	// Executa
	//----------
	If cCampo == "TZE_NOMFOR"
		cIniPad := If(INCLUI, "", Posicione("TZ5", 1, TZE->TZE_FILIAL+TZE->TZE_MODULO+TZE->TZE_INDIC, "TZ5_NOME"))
	EndIf
	
Return cIniPad

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND009IB
Função para INICIALIZADOR do BROWSE.

@author Wagner Sobral de Lacerda
@since 19/09/2012

@param cCampo
	ID do Campo do dicionário SX3 * Obrigatório

@return cIniBrw
/*/
//---------------------------------------------------------------------
Function NGIND007IB(cCampo)
	
	// Variável do Retorno 'INICIALIZADOR do BROWSE'
	Local cIniBrw := ""
	
	// Defaults
	Default cCampo := ""
	
	//----------
	// Executa
	//----------
	If cCampo == "TZE_NOMFOR"
		cIniBrw := Posicione("TZ5", 1, TZE->TZE_FILIAL+TZE->TZE_MODULO+TZE->TZE_INDIC, "TZ5_NOME")
	EndIf
	
Return cIniBrw