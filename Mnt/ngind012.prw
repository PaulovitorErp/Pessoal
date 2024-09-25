#INCLUDE	"Protheus.ch"
#INCLUDE	"NGIND012.ch"
#INCLUDE	"FWBrowse.ch"
#INCLUDE	"FWMVCDEF.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND012
Cadastro de Permissão de Acesso aos Paineis de Indicadores Gráficos.

@author Wagner Sobral de Lacerda
@since 10/12/2012

@return .T.
/*/
//---------------------------------------------------------------------
Function NGIND012()

	//------------------------------
	// Armazena as variáveis
	//------------------------------
	Local aNGBEGINPRM := NGBEGINPRM()

	Local lExecute := .T. // Variável para identificar se pode ou não executar esta rotina
	Local oBrowse // Variável do Browse

	// Log de Acesso LGPD
	If FindFunction( 'FWPDLogUser' )
		FWPDLogUser( 'NGIND012()' )
	EndIf

	//-------------------------------
	// Valida a execução do programa
	//-------------------------------
	lExecute := NGIND007OP()

	If lExecute
		// Declara as Variáveis PRIVATE
		NGIND012VR()

		//----------------
		// Monta o Browse
		//----------------
		dbSelectArea("TZB")
		dbSetOrder(1)
		dbGoTop()

		// Instanciamento da Classe de Browse
		oBrowse := FWMBrowse():New()

			// Definição da tabela do Browse
			oBrowse:SetAlias("TZB")

			// Definição da Legenda
			NGIND008LG(@oBrowse)

			// Definição do Filtro
			NGIND008FL(@oBrowse)

			// Descrição do Browse
			oBrowse:SetDescription(cCadastro)

			// Menu Funcional relacionado ao Browse
			oBrowse:SetMenuDef("NGIND012")

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
@since 10/12/2012

@return aRotina array com o Menu MVC
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	// Variável do Menu
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0001 ACTION "VIEWDEF.NGIND012" OPERATION 4 ACCESS 0 //"Permissões"

Return aRotina

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
@since 10/12/2012

@return oModel objeto do Modelo MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruTZB := FWFormStruct(1, "TZB", /*bAvalCampo*/, /*lViewUsado*/)
	Local oTZHUsers  := FWFormStruct(1, "TZH", /*bAvalCampo*/, /*lViewUsado*/)
	Local oTZHGroups := FWFormStruct(1, "TZH", /*bAvalCampo*/, /*lViewUsado*/)

	// Modelo de dados que será construído
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("NGIND012", /*bPreValid*/, {|oModel| fMPosValid(oModel) }/*bPosValid*/, /*bFormCommit*/, /*bFormCancel*/)

		//--------------------------------------------------
		// Estrutura da View
		//--------------------------------------------------
		// TZH (Usuários)
		oTZHUsers:SetProperty("TZH_USRGRP" , MODEL_FIELD_VALID, {|| NGIND012VL("1") })
		oTZHUsers:SetProperty("TZH_CODPNL" , MODEL_FIELD_OBRIGAT, .F. )
		oTZHUsers:SetProperty("TZH_TIPO" , MODEL_FIELD_OBRIGAT, .F. )

		// TZH (Grupos)
		oTZHGroups:SetProperty("TZH_USRGRP" , MODEL_FIELD_VALID, {|| NGIND012VL("2")} )
		oTZHGroups:SetProperty("TZH_CODPNL" , MODEL_FIELD_OBRIGAT, .F. )
		oTZHGroups:SetProperty("TZH_TIPO" , MODEL_FIELD_OBRIGAT, .F. )

		//--------------------------------------------------
		// Componentes do Modelo
		//--------------------------------------------------

		// Adiciona ao modelo um componente de Formulário Principal
		oModel:AddFields("TZBMASTER"/*cID*/, /*cIDOwner*/, oStruTZB/*oModelStruct*/, /*bPre*/, /*bPost*/, /*bLoad*/)

		// Adiciona ao modelo um componente de Grid
		oModel:AddGrid("TZHUSERS"/*cID*/, "TZBMASTER"/*cIDOwner*/, oTZHUsers/*oModelStruct*/, /*bLinePre*/, /*bLinePost*/, /*bPre*/, {|oGrid| fGridPos(oGrid) }/*bPost*/, {|oGrid| fGridLoad(oGrid) }/*bLoad*/)

			// Define a Relação do modelo Filho com o Principal
			oModel:SetRelation("TZHUSERS"/*cIDGrid*/,;
								{ {"TZH_FILIAL", "xFilial('TZH')"}, {"TZH_CODPNL", "TZB_CODIGO"} }/*aConteudo*/,;
								TZH->( IndexKey(1) )/*cIndexOrd*/)

			oModel:GetModel( 'TZHUSERS' ):SetLoadFilter( { { 'TZH_TIPO', "'1'" } } )

		// Adiciona ao modelo um componente de Grid
		oModel:AddGrid("TZHGROUPS"/*cID*/, "TZBMASTER"/*cIDOwner*/, oTZHGroups/*oModelStruct*/, /*bLinePre*/, /*bLinePost*/, /*bPre*/, {|oGrid| fGridPos(oGrid) }/*bPost*/, {|oGrid| fGridLoad(oGrid) }/*bLoad*/)

			// Define a Relação do modelo Filho com o Principal
			oModel:SetRelation("TZHGROUPS"/*cIDGrid*/,;
								{ {"TZH_FILIAL", 'xFilial("TZH")'}, {"TZH_CODPNL", "TZB_CODIGO"} }/*aConteudo*/,;
								TZH->( IndexKey(1) )/*cIndexOrd*/)

			oModel:GetModel( 'TZHGROUPS' ):SetLoadFilter( { { 'TZH_TIPO', "'2'" } } )

		// Adiciona a descrição do Modelo de Dados (Geral)
		//oModel:SetDescription(cCadastro/*cDescricao*/)

			//--------------------------------------------------
			// Definições do Modelo do Painel de Indicadores
			//--------------------------------------------------

			// Adiciona a descrição do Modelo
			oModel:GetModel("TZBMASTER"):SetDescription(STR0002/*cDescricao*/) //"Painel de Indicadores"

				// Apenas Visualização
				oModel:GetModel("TZBMASTER"):SetOnlyView(.T.)

			//--------------------------------------------------
			// Definições do Modelo dos Usuários/Grupos
			//--------------------------------------------------

			// Adiciona a descrição do Modelo
			oModel:GetModel("TZHUSERS"):SetDescription(STR0003/*cDescricao*/) //"Usuários"

				// Define qual a chave única por Linha no browse
				oModel:GetModel("TZHUSERS"):SetUniqueLine({"TZH_USRGRP"})

				// Indica que o preenchimento é opcional
				oModel:GetModel("TZHUSERS"):SetOptional(.T.)

			// Adiciona a descrição do Modelo
			oModel:GetModel("TZHGROUPS"):SetDescription(STR0004/*cDescricao*/) //"Grupos de Usuários"

				// Define qual a chave única por Linha no browse
				oModel:GetModel("TZHGROUPS"):SetUniqueLine({"TZH_USRGRP"})

				// Indica que o preenchimento é opcional
				oModel:GetModel("TZHGROUPS"):SetOptional(.T.)

		//--------------------------------------------------
		// Gatilhos Manuais
		//--------------------------------------------------
		// FwStruTrigger(cDom, cCDom, cRegra, lSeek, cAlias, nOrdem, cChave, cCondic)
		aTrigUsers := FWStruTrigger("TZH_USRGRP", "TZH_NOME", 'NGIND012TR("1", "TZH_USRGRP", "TZH_NOME")', .F., " ", 0, ' ')
		oTZHUsers:AddTrigger(	aTrigUsers[1],; // [01] identificador (ID) do campo de origem
								aTrigUsers[2],; // [02] identificador (ID) do campo de destino
								aTrigUsers[3],; // [03] Bloco de código de validação da execução do gatilho
								aTrigUsers[4] ) // [04] Bloco de código de execução do gatilho
		aTrigGroups := FWStruTrigger("TZH_USRGRP", "TZH_NOME", 'NGIND012TR("2", "TZH_USRGRP", "TZH_NOME")', .F., " ", 0, ' ')
		oTZHGroups:AddTrigger(	aTrigGroups[1],; // [01] identificador (ID) do campo de origem
								aTrigGroups[2],; // [02] identificador (ID) do campo de destino
								aTrigGroups[3],; // [03] Bloco de código de validação da execução do gatilho
								aTrigGroups[4] ) // [04] Bloco de código de execução do gatilho

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} fGridPos
Pós-Validação da GetDados.

@author Wagner Sobral de Lacerda
@since 10/12/2012

@param oGrid
	Objeto do Modelo de Dados * Obrigatório

@return lReturn
/*/
//---------------------------------------------------------------------
Function fGridPos(oGrid)

	// Salva as Áres atuais
	Local aAreaTZB := TZB->( GetArea() )
	Local aAreaTZH := TZH->( GetArea() )

	// Variáveis do Modelo
	Local cCodPnl := FWFldGet("TZB_CODIGO")
	Local cTipo   := ""
	Local aHeader := oGrid:aHeader

	Local nTZHTIPO := aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "TZH_TIPO" })

	// Variáveis auxiliares
	Local nLinha := 0
	Local nMaxLinhas := oGrid:Length()

	//-- Tipo
	If oGrid:cID == "TZHUSERS" // Usuários
		cTipo := "1"
	ElseIf oGrid:cID == "TZHGROUPS" // Grupos
		cTipo := "2"
	EndIf

	//------------------------------
	// Atualiza Conteúdo do aCols
	//------------------------------
	For nLinha := 1 To nMaxLinhas
		oGrid:GoLine(nLinha)
		If !oGrid:IsDeleted()
			If nTZHTIPO > 0
				oGrid:LoadValue("TZH_TIPO", cTipo)
			EndIf
		EndIf
	Next nLinha

	// Devolve as Áres
	RestArea(aAreaTZB)
	RestArea(aAreaTZH)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fGridLoad
Carrega o Conteúdo da GetDados.

@author Wagner Sobral de Lacerda
@since 10/12/2012

@param oGrid
	Objeto do Modelo de Dados * Obrigatório

@return lReturn
/*/
//---------------------------------------------------------------------
Function fGridLoad(oGrid)

	// Salva as Áres atuais
	Local aAreaTZB := TZB->( GetArea() )
	Local aAreaTZH := TZH->( GetArea() )

	// Variáveis do Modelo
	Local cCodPnl := FWFldGet("TZB_CODIGO")
	Local cTipo   := ""
	Local aHeader := oGrid:aHeader
	Local aLoad   := {}

	// Variáveis auxiliares
	Local nHeader := 0, nCols := 0

	//-- Tipo
	If oGrid:cID == "TZHUSERS" // Usuários
		cTipo := "1"
	ElseIf oGrid:cID == "TZHGROUPS" // Grupos
		cTipo := "2"
	EndIf

	//----------
	// Busca
	//----------
	dbSelectArea("TZH")
	dbSetOrder(1)
	dbSeek(xFilial("TZH") + cCodPnl + cTipo)
	While !Eof() .And. TZH->TZH_FILIAL == xFilial("TZH") .And. TZH->TZH_CODPNL == cCodPnl .And. TZH->TZH_TIPO == cTipo

		aAdd(aLoad, {RecNo(),  Array(Len(aHeader))})
		nCols := Len(aLoad)
		For nHeader := 1 To Len(aHeader)
			If ValType("TZH->"+aHeader[nHeader][2]) <> "U"
				If aHeader[nHeader][10] <> "V"
					aLoad[nCols][2][nHeader] := &("TZH->"+aHeader[nHeader][2])
				Else
					If AllTrim(aHeader[nHeader][2]) == "TZH_NOME"
						aLoad[nCols][2][nHeader] := NGIND012RE( TZH->TZH_TIPO, TZH->TZH_USRGRP, .T. )
					EndIf
				EndIf
			EndIf
		Next nHeader

		dbSelectArea("TZH")
		dbSkip()
	End

	// Devolve as Áres
	RestArea(aAreaTZB)
	RestArea(aAreaTZH)

Return aLoad

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
@since 10/12/2012

@return oView objeto da View MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oModel := FWLoadModel("NGIND012")

	// Cria a estrutura a ser usada na View
	Local oStruTZB := FWFormStruct(2, "TZB", /*bAvalCampo*/, /*lViewUsado*/)
	Local oTZHUsers  := FWFormStruct(2, "TZH", /*bAvalCampo*/, /*lViewUsado*/)
	Local oTZHGroups := FWFormStruct(2, "TZH", /*bAvalCampo*/, /*lViewUsado*/)

	// Interface de visualização construída
	Local oView

	// Variáveis do Gatilho (Trigger)
	Local aTrigUsers := {}
	Local aTrigGroups := {}

	// Cria o objeto de View
	oView := FWFormView():New()

		// Define qual o Modelo de dados será utilizado na View
		oView:SetModel(oModel)

		// Valida a Inicialização da View
		oView:SetViewCanActivate({|oView| fVActivate(oView) }/*bBloclVld*/)

		//--------------------------------------------------
		// Estrutura da View
		//--------------------------------------------------
		// TZH (Usuários)
		oTZHUsers:RemoveField("TZH_CODPNL")
		oTZHUsers:RemoveField("TZH_TIPO")
		oTZHUsers:SetProperty("TZH_USRGRP" , MVC_VIEW_LOOKUP, "USR")
		// TZH (Grupos)
		oTZHGroups:RemoveField("TZH_CODPNL")
		oTZHGroups:RemoveField("TZH_TIPO")
		oTZHGroups:SetProperty("TZH_USRGRP" , MVC_VIEW_LOOKUP, "GRP")

		//--------------------------------------------------
		// Componentes da View
		//--------------------------------------------------

		// Adiciona no View um controle do tipo formulário (antiga Enchoice)
		oView:AddField("VIEW_TZBMASTER"/*cFormModelID*/, oStruTZB/*oViewStruct*/, "TZBMASTER"/*cLinkID*/, /*bValid*/)

		// Adiciona no View um controle do tipo Grid (antiga Getdados)
		oView:AddGrid("VIEW_TZHUSERS"/*cFormModelID*/, oTZHUsers/*oViewStruct*/, "TZHUSERS"/*cLinkID*/, /*bValid*/)

		// Adiciona no View um controle do tipo Grid (antiga Getdados)
		oView:AddGrid("VIEW_TZHGROUPS"/*cFormModelID*/, oTZHGroups/*oViewStruct*/, "TZHGROUPS"/*cLinkID*/, /*bValid*/)

		//--------------------------------------------------
		// Layout
		//--------------------------------------------------

		// Cria os componentes "box" horizontais para receberem elementos da View
		oView:CreateHorizontalBox("BOX_SUPERIOR"/*cID*/, 030/*nPercHeight*/, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)
		oView:CreateHorizontalBox("BOX_INFERIOR"/*cID*/, 070/*nPercHeight*/, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)

			// Cria Folder
			oView:CreateFolder("FOLDER"/*cIDFolder*/, "BOX_INFERIOR"/*cIDOwner*/)
				oView:AddSheet("FOLDER"/*cIDFolder*/, "SHEET_01"/*cIDSheet*/, STR0003/*cTitle*/, /*bAction*/) //"Usuários"
				oView:AddSheet("FOLDER"/*cIDFolder*/, "SHEET_02"/*cIDSheet*/, STR0005/*cTitle*/, /*bAction*/) //"Grupos"

				// Cria os componentes "box" horizontais
				oView:CreateHorizontalBox("BOX_INFERIOR_01"/*cID*/, 100/*nPercHeight*/, /*cIDOwner*/, /*lFixPixel*/, "FOLDER"/*cIDFolder*/, "SHEET_01"/*cIDSheet*/)
				oView:CreateHorizontalBox("BOX_INFERIOR_02"/*cID*/, 100/*nPercHeight*/, /*cIDOwner*/, /*lFixPixel*/, "FOLDER"/*cIDFolder*/, "SHEET_02"/*cIDSheet*/)

		// Relaciona o identificador (ID) da View com o "box" para exibição
		oView:SetOwnerView("VIEW_TZBMASTER"/*cFormModelID*/, "BOX_SUPERIOR"/*cIDUserView*/)
		oView:SetOwnerView("VIEW_TZHUSERS" /*cFormModelID*/, "BOX_INFERIOR_01"/*cIDUserView*/)
		oView:SetOwnerView("VIEW_TZHGROUPS"/*cFormModelID*/, "BOX_INFERIOR_02"/*cIDUserView*/)

		// Adiciona um Título para a View
		oView:EnableTitleView("VIEW_TZBMASTER"/*cFormModelID*/, /*cTitle*/, /*nColor*/)
		oView:EnableTitleView("VIEW_TZHUSERS" /*cFormModelID*/, /*cTitle*/, /*nColor*/)
		oView:EnableTitleView("VIEW_TZHGROUPS"/*cFormModelID*/, /*cTitle*/, /*nColor*/)

Return oView

/*/
############################################################################################
##                                                                                        ##
## DEFINIÇÃO DAS VALIDAÇÕES * MVC                                                         ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} fMPosValid
Pós-validação do modelo de dados.

@author Wagner Sobral de Lacerda
@since 10/12/2012

@param oModel
	Objeto do modelo de dados * Obrigatório

@return lReturn
/*/
//---------------------------------------------------------------------
Static Function fMPosValid(oModel)

	// Salva as Áres atuais
	Local aAreaTZB := TZB->( GetArea() )
	Local aAreaTZH := TZH->( GetArea() )

	// Operação de ação sobre o Modelo
	Local nOperation := oModel:GetOperation()

	// Modelos
	Local oTZHUsers  := oModel:GetModel("TZHUSERS")
	Local oTZHGroups := oModel:GetModel("TZHGROUPS")

	// Variável do Retorno
	Local lReturn := .T.

	//----------
	// Valida
	//----------
	If nOperation <> MODEL_OPERATION_DELETE // Diferente de Exclusão

		// Valida Modelo TZH (Usuários)
		If !oTZHUsers:VldData()
			lReturn := .F.
		EndIf

		// Valida Modelo TZH (Grupos)
		If !oTZHGroups:VldData()
			lReturn := .F.
		EndIf

	EndIf

	// Devolve as Áres
	RestArea(aAreaTZB)
	RestArea(aAreaTZH)

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} fVActivate
Valida se pode ativar a View.

@author Wagner Sobral de Lacerda
@since 10/12/2012

@return lReturn .T. pode inicializar; .F. não pode
/*/
//---------------------------------------------------------------------
Static Function fVActivate(oView)

	// Operação de ação sobre o Modelo
	Local nOperation := oView:GetOperation()

	// Variável do Retorno
	Local lReturn := .T.

	//------------------------------
	// Valida a Ativação da View
	//------------------------------
	If nOperation <> MODEL_OPERATION_INSERT // Diferente de Inclusão

		If !FWIsAdmin() .And. AllTrim(TZB->TZB_CODUSU) <> AllTrim(RetCodUsr()) // Usuário não é nem Administrador e nem o Proprietário
			Help(Nil, Nil, STR0006, Nil, STR0007, 1, 0) //"Atenção" ## "Este registro não pode ser manipulado pois o Usuário não é Administrador e nem o Proprietário do Painel de Indicadores."
			lReturn := .F.
		EndIf

	EndIf

	// Armazena um backup da view
	oBkpView := oView

Return lReturn

/*/
############################################################################################
##                                                                                        ##
## FUNÇÕES AUXILIARES DA ROTINA                                                           ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND012VR
Declara as variáveis Private utilizadas na Permissão de Acesso aos
Painéis de Indicadores.
* Lembrando que essas variáveis ficam declaradas somente para a função
que é Pai imediata desta.

@author Wagner Sobral de Lacerda
@since 10/12/2012

@return .T.
/*/
//---------------------------------------------------------------------
Function NGIND012VR()

	// Salva as Áres atuais
	Local aAreaTZB := TZB->( GetArea() )
	Local aAreaTZH := TZH->( GetArea() )

	//------------------------------
	// Declara as variáveis
	//------------------------------
	// Variável do Cadastro
	_SetOwnerPrvt("cCadastro", OemToAnsi(STR0008)) //"Permissão de Acesso aos Painéis"

	// Variável da Consulta SXB Genérica
	_SetOwnerPrvt("a012Groups", {})

	//------------------------------
	// Define conteúdos
	//------------------------------
	a012Groups := aClone( fGetGroups() )

	// Devolve as Áres
	RestArea(aAreaTZB)
	RestArea(aAreaTZH)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetGroups
Retorna um Array com os Grupos de Usuários do Sistema.

@author Wagner Sobral de Lacerda
@since 10/12/2012

@return aGetGroups
/*/
//---------------------------------------------------------------------
Static Function fGetGroups()

	// Variável do Retorno
	Local aGetGroups := {}

	// Variáveis auxiliares
	Local aAllGroups := AllGroups()
	Local nX := 0

	//----------
	// Busca
	//----------
	For nX := 1 To Len(aAllGroups)
		aAdd(aGetGroups, {aAllGroups[nX][1][1], aAllGroups[nX][1][2]}) // Código ; Nome
	Next nX

Return aGetGroups

//---------------------------------------------------------------------
/*/{Protheus.doc} NGI8HasAce
Verifica se o Usuário, ou Grupo, tem acesso ao Painel de Indicadores.

@author Wagner Sobral de Lacerda
@since 10/12/2012

@return .T.
/*/
//---------------------------------------------------------------------
Function NGIND012AC(cCodFilial, cCodPainel, cTipo, cCodUsrGrp)

	// Salva as Áres atuais
	Local aAreaOld := GetArea()

	// Variável do Retorno
	Local lAcesso := .F.

	//-- Verifica se o Usuário tem acesso
	dbSelectArea("TZB")
	dbSetOrder(1)
	If dbSeek(xFilial("TZB",cCodFilial) + cCodPainel)
		If cTipo == "1" // 1=Usuário;2=Grupo
			lAcesso := ( AllTrim(TZB->TZB_CODUSU) == AllTrim(cCodUsrGrp) )
		EndIf
		If !lAcesso
			dbSelectArea("TZH")
			dbSetOrder(1)
			lAcesso := dbSeek(xFilial("TZH",cCodFilial) + cCodPainel + cTipo + cCodUsrGrp)
		EndIf
	EndIf

	// Devolve as Áres
	RestArea(aAreaOld)

Return lAcesso

/*/
############################################################################################
##                                                                                        ##
## FUNÇÕES UTILIZADAS NO DICIONÁRIO DE DADOS / MODELO DE DADOS                            ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND012VL
Função da Validação dos Usuários ou Grupos.

@author Wagner Sobral de Lacerda
@since 10/12/2012

@param cTipo
	Tipo de Validação * Obrigatório
	   "1" - Usuário
	   "2" - Grupo

@return lReturn
/*/
//---------------------------------------------------------------------
Function NGIND012VL(cTipo)

	// Modelos
	Local oView := FWViewActive()
	Local oTZHUsers
	Local oTZHGroups

	// Variáveis do Modelo
	Local cCodigo := ""

	// Salva as Variáveis
	Local aSaveLines := FWSaveRows()

	// Variável do Retorno
	Local lReturn := .T.

	// Defaults
	Default cTipo := "1"

	//----------
	// Valida
	//----------
	If cTipo == "1"
		//----------
		// Usuário
		//----------
		oTZHUsers := oView:GetModel("TZHUSERS")
		cCodigo   := oTZHUsers:GetValue("TZH_USRGRP")
		lReturn := UsrExist( cCodigo )

	ElseIf cTipo == "2"
		//----------
		// Grupo
		//----------
		oTZHGroups := oView:GetModel("TZHGROUPS")
		cCodigo    := oTZHGroups:GetValue("TZH_USRGRP")
		lReturn :=  aScan(a012Groups, {|x| AllTrim(x[1]) == AllTrim(cCodigo) }) > 0

	EndIf

	// Devolve as variáveis
	FWRestRows(aSaveLines)

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND012TR
Função do Gatilho dos Usuários ou Grupos.

@author Wagner Sobral de Lacerda
@since 10/12/2012

@param cTipo
	Tipo de Validação * Obrigatório
	   "1" - Usuário
	   "2" - Grupo
@param cDominio
	Campo de Domínio * Obrigatório
@param cContra
	Campo de Contra Domínio * Obrigatório

@return cTrigger
/*/
//---------------------------------------------------------------------
Function NGIND012TR(cTipo, cDominio, cContra)

	// Modelos
	Local oView
	Local oTZHUsers
	Local oTZHGroups

	// Variáveis do Modelo
	Local cCodigo := ""

	// Variável do Retorno
	Local cTrigger := " "

	// Defaults
	Default cDominio := ""
	Default cContra  := ""

	//----------
	// Executa
	//----------
	If cDominio == "TZH_USRGRP" .And. cContra == "TZH_NOME"

		oView := FWViewActive()

		If cTipo == "1"
			//----------
			// Usuário
			//----------
			oTZHUsers := oView:GetModel("TZHUSERS")
			cCodigo   := oTZHUsers:GetValue("TZH_USRGRP")

		ElseIf cTipo == "2"
			//----------
			// Grupo
			//----------
			oTZHGroups := oView:GetModel("TZHGROUPS")
			cCodigo    := oTZHGroups:GetValue("TZH_USRGRP")
		EndIf
		cTrigger := NGIND012RE( cTipo, cCodigo, .T. )

	EndIf

Return cTrigger

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND012RE
Função do Gatilho dos Usuários ou Grupos.

@author Wagner Sobral de Lacerda
@since 10/12/2012

@param cTipo, string, Tipo de Validação: '1'-Usuário;'2'-Grupo
@param cCodigo, string, código do Usuário/Grupo
@param [lCarrega], boolean, se retorno deve ter conteúdo

@return string, nome do grupo ou usuário
/*/
//---------------------------------------------------------------------
Function NGIND012RE( cTipo, cCodigo, lCarrega )

	Local nTamSx3 := TAMSX3("TZH_NOME")[1]
	Local cInit   := Space( nTamSx3 )

	Default lCarrega := .F.

	If lCarrega
		If cTipo == "1" // Nome do usuário
			cInit := Padr( UsrFullName( cCodigo ), nTamSx3 )
		ElseIf cTipo == "2" // Nome do Grupo
			cInit := Padr( GrpRetName( cCodigo ), nTamSx3 )
		EndIf
	EndIf

Return cInit

