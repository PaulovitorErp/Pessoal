#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'SGAA531.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} SGAA531
Rotina de disposição final de resíduos (não perigosos)

@author  Bruno Lobo de Souza
@since   21/02/2018
@type    function
@version 12.1.20
/*/
//-------------------------------------------------------------------
Function SGAA531()

	Local aArea := GetArea()
	Local oBrowse

	If GetRpoRelease() < "12.1.023" .Or. TH3->(ColumnPos("TH3_CODCOM")) <= 0
		MsgInfo(STR0027, STR0028)
		Return .F.
	EndIf

	Private oEvent := sgaa531a():New()
	Private oMarkDis
	Private oMarkSel
	Private oTempDIS
	Private oTempSEL
	Private oTempTable
	Private cTRBDIS	:= GetNextAlias()
	Private cTRBSEL	:= GetNextAlias()
	Private aDBF	:= {}

	//Cria os TRB's que serão utilizados durante o processo de seleção
	fCreateTRB()

	//Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	//Setando a tabela de disposição final de resíduos
	oBrowse:SetAlias("TH3")

	//Setando a descrição da rotina
	oBrowse:SetDescription(STR0001)

	//Ativa a Browse
	oBrowse:Activate()

	oTempDIS:Delete()
	oTempSEL:Delete()

	RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Criação do menu MVC

@author  Bruno Lobo de Souza
@since   21/02/2018
@sample  MenuDef()
@source  SGAA751
@type    function
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	//Adicionando opções
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.SGAA531' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //"Visualizar" OPERATION 1
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.SGAA531' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //"Incluir" OPERATION 3
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.SGAA531' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //"Excluir" OPERATION 5

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Criação do modelo de dados MVC

@author  Bruno Lobo de Souza
@since   21/02/2018
@sample  ModelDef()
@source  SGAA751
@type    function
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oModel	:= Nil
	Local oStruTH3	:= FWFormStruct(1, "TH3")
	Local oStruTH4	:= FWFormStruct(1, "TH4")

	oEvent := IIf( ValType(oEvent) == "O", oEvent, sgaa531a():New() )
	//Criando o modelo
	oModel := MPFormModel():New("SGAA531")

	//Atribuindo formulários para o modelo
	oModel:AddFields("FORMTH3",/*cOwner*/, oStruTH3)

	//Atribuindo grid para o modelo
	oModel:AddGrid("GRIDTH4", "FORMTH3", oStruTH4)

	//Setando a chave primária da rotina
	oModel:SetPrimaryKey({"TH3_FILIAL", "TH3_CODCOM"})

	//Adicionando descrição ao modelo
	oModel:SetDescription(STR0019 + STR0001)

	//Setando a descrição do formulário
	oModel:GetModel("FORMTH3"):SetDescription(STR0018 + STR0001)

	//Determina a relação do SubModel
	oModel:SetRelation("GRIDTH4",;
						{{"TH4_FILIAL", "xFilial('TH4')"}, {"TH4_CODCOM", "TH3_CODCOM"}},;
						TH4->(IndexKey(1)))

	//Instala o evento de Integração com Ocorrência (TB0) e Estoque (SIGAEST)
	oModel:InstallEvent("sgaa531a",, oEvent)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Fornece uma interface gráfica para um mode

@author  Bruno Lobo de Souza
@since   21/02/2018
@sample  ViewDef()
@type    Function
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	//Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
	Local oModel := FWLoadModel("SGAA531")

	//Criação da estrutura de dados utilizada na interface do cadastro de Autor
	Local oStruTH3 := FWFormStruct(2, "TH3")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}

	//Criando oView como nulo
	Local oView := Nil

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Atribuindo formulários para interface
	oView:AddField("VIEW_TH3", oStruTH3, "FORMTH3")
	oView:AddOtherObject("VIEW_TH4" /*cFormModelID*/,;
		{|oPanel| fOtherInfo(oPanel, oView)}/*bActivate*/,;
		{|oPanel| If(ValType(oPanel) == "O", oPanel:FreeChildren(), )}/*bDeActivate*/, /*bRefresh*/)

	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA", 45)
	oView:CreateHorizontalBox("MARK", 55)

	//Colocando título do formulário
	oView:EnableTitleView("VIEW_TH3", STR0001)
	oView:EnableTitleView("VIEW_TH4", STR0006)

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	//Ação de interface do campo (após validação)
	oView:SetFieldAction("TH3_TIPDES", {|oView, cIDView, cField, xValue|;
										fRfrshOco(oView, cIDView, cField, xValue)})
	oView:SetFieldAction("TH3_CODTIP", {|oView, cIDView, cField, xValue|;
										fRfrshOco(oView, cIDView, cField, xValue)})

	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_TH3", "TELA")
	oView:SetOwnerView("VIEW_TH4", "MARK")

	//Executa ação ao confirmar a tela
	oView:SetViewAction("BUTTONOK", {|oView| fBuscaValue(oView)})

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} fOtherInfo
Adiciona um painel onde é possível adicionar componentes que não sejam MVC.

@author  Bruno Lobo de Souza
@since   02/03/2018
@sample  fOtherInfo(oPanel, oView)
@param   oPanel, object, ID do painel otherObject
@param   oView, object, ID da view na qual se encontra o painel otherObject
@type    function
/*/
//-------------------------------------------------------------------
Static Function fOtherInfo(oPanel, oView)

	Local nOperation := oView:GetOperation()
	Local oPnlTLeft
	Local oPnlTRight
	Local oPnlBtn

	Local oBtnFilter
	Local oBtnNext
	Local oBtnPrev
	Local oBtnTotal

	Local cMarca  	 := GetMark()
	Local lInverte	 := .F.
	Local aMRK		 := {}
	Local aFldFilter := {}

	//Array com os campos para criação do msSelect
	aAdd(aMRK, {"TRB_OK"	, Nil, " ",} )
	aAdd(aMRK, {"TRB_CODOCO", Nil, RetTitle("TH4_CODOCO")})
	aAdd(aMRK, {"TRB_CODRES", Nil, RetTitle("TAX_CODRES")})
	aAdd(aMRK, {"TRB_NOMRES", Nil, RetTitle("TAX_DESCRE")})
	aAdd(aMRK, {"TRB_PESOTO", Nil, RetTitle("TH4_PESOUT")})
	aAdd(aMRK, {"TRB_UNIMED", Nil, RetTitle("TH4_UNIMED")})
	aAdd(aMRK, {"TRB_DATA"  , Nil, RetTitle("TB0_DATA")})

	//Array com os campos apresentados no filtro
	aAdd(aFldFilter, {RetTitle("TH4_CODOCO"), "TRB_CODOCO", "C",;
						TAMSX3("TH4_CODOCO")[1], 0, PesqPict("TH4", "TH4_CODOCO")})
	aAdd(aFldFilter, {RetTitle("TAX_CODRES"), "TRB_CODRES", "C",;
						TAMSX3("TAX_CODRES")[1], 0, PesqPict("TAX", "TAX_CODRES")})
	aAdd(aFldFilter, {RetTitle("TAX_DESCRE"), "TRB_NOMRES", "C",;
						TAMSX3("B1_DESC")[1], 0, PesqPict("TAX", "TAX_DESCRE")})
	aAdd(aFldFilter, {RetTitle("TH4_PESOUT"), "TRB_PESOTO", "N",;
						TAMSX3("TH4_PESOUT")[1], 0, PesqPict("TH4", "TH4_PESOUT")})
	aAdd(aFldFilter, {RetTitle("TH4_UNIMED"), "TRB_UNIMED", "C",;
						TAMSX3("TH4_UNIMED")[1], 0, PesqPict("TH4", "TH4_UNIMED")})
	aAdd(aFldFilter, {RetTitle("TB0_DATA"), "TRB_DATA", "D",;
						TAMSX3("TB0_DATA")[1], 0, PesqPict("TB0", "TB0_DATA")})

	oPnlTLeft := TPanel():New(0, 0,, oPanel,,,, CLR_BLUE, CLR_RED, 323, 0, .F., .F.)
		oPnlTLeft:Align := CONTROL_ALIGN_LEFT
		oPnlLTop := TPanel():New(0, 0, STR0007, oPnlTLeft,,,, CLR_BLUE, CLR_WHITE, 0, 10, .F., .F.)
			oPnlLTop:Align := CONTROL_ALIGN_TOP

		oMarkDis := MsSelect():New(cTRBDIS, "TRB_OK",, aMRK, @lInverte, @cMarca,;
									{0, 0, 1000, 1000},,, oPnlTLeft,,)
			oMarkDis:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
			If Str( nOperation, 1 ) $ "2/5"
				oMarkDis:bMark := {|| ClearMark(cTRBDIS, cMarca)}
			Else
				oMarkDis:oBrowse:bAllMark := {|| InvMark(cMarca, cTRBDIS)}
				oMarkDis:bMark := {|| ValidMark(cTRBDIS)}
			EndIf

	oPnlBtn := TPanel():New( 0, 0,, oPanel,,,,, CLR_WHITE, 13, 0, .F., .F. )
		oPnlBtn:Align := CONTROL_ALIGN_LEFT
		@ 135, 0 BTNBMP oBtnFilter Resource "FILTRO" Size 29, 29 Pixel Of oPnlBtn Noborder Pixel;
			Action NGFILTEMP(cTRBDIS, aFldFilter), oMarkDis:oBrowse:Refresh(), oMarkSel:oBrowse:Refresh() WHEN Inclui .Or. Altera
		@ 165, 0 BTNBMP oBtnNext Resource "PGNEXT" Size 29, 29 Pixel Of oPnlBtn Noborder Pixel;
			Action fTrocaOco(cTRBDIS, cTRBSEL, .T.) WHEN Inclui .Or. Altera
		@ 195, 0 BTNBMP oBtnPrev Resource "PGPREV" Size 29, 29 Pixel Of oPnlBtn Noborder Pixel;
			Action fTrocaOco(cTRBSEL, cTRBDIS, .F.) WHEN Inclui .Or. Altera
		@ 225, 0 BTNBMP oBtnTotal Resource "CALCULADORA" Size 29, 29 Pixel Of oPnlBtn Noborder Pixel;
			Action fTotal(cTRBSEL, cTRBDIS) WHEN Inclui .Or. Altera .Or. nOperation == 1

	oPnlTRight := TPanel():New(0, 0,, oPanel,,,, CLR_BLUE, CLR_RED, 0, 10, .F., .F.)
		oPnlTRight:Align := CONTROL_ALIGN_ALLCLIENT
		oPnlRTop := TPanel():New(0, 0, STR0008, oPnlTRight,,,, CLR_BLUE, CLR_WHITE, 0, 10, .F., .F.)
			oPnlRTop:Align := CONTROL_ALIGN_TOP

		oMarkSel := MsSelect():New(cTRBSEL, "TRB_OK",, aMRK, @lInverte, @cMarca,;
									{0, 0, 1000, 1000},,, oPnlTRight,,)
			oMarkSel:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
			If Str(nOperation, 1) $ "2/5"
				oMarkSel:bMark := {|| ClearMark(cTRBSEL, cMarca)}
			Else
				oMarkSel:oBrowse:bAllMark := {|| InvMark(cMarca, cTRBSEL)}
				oMarkSel:bMark := {|| ValidMark(cTRBSEL, cMarca)}
			EndIf

	SG531RES(nOperation)

	oView:Refresh()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} InvMark
Inverte marcações

@author  Bruno Lobo de Souza
@since   02/03/2018
@sample  InvMark(cMarca, cTRBSEL)
@param   cMarca, caracter, marcação do markbrowse
@param   cTRB, caracter, alias do arquivo temporário utilizado no mark
@type    static function
/*/
//-------------------------------------------------------------------
Static Function InvMark(cMarca, cTRB)

	Local nRecno

	dbSelectArea(cTRB)
	nRecno := Recno()
	DbGoTop()
	While !Eof()
		(cTRB)->TRB_OK := If(!Empty( (cTRB)->TRB_OK ), " ", cMarca)
		dbSkip()
	End

	dbGoTo( nRecno )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} ClearMark
Limpa a marcação dos registros atuais.

@param cTRBDIS - Tabela temporária
@author Gabriel Werlich
@since 21/11/2014
@version 11/12
@return .T.
/*/
//---------------------------------------------------------------------
Static Function ClearMark(cTRB, cOK)

	dbSelectArea(cTRB)
	RecLock(cTRB, .F.)
	(cTRB)->TRB_OK := Space(Len(cOK))
	(cTRB)->(MsUnlock())

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidMark
Valida a ocorrência no momento da marcação
@type  Static Function

@author Bruno Lobo de Souza
@since 03/05/2018
@version 12.1.17+

@param cTRB, caracter, arquivo temporário do mark
@param cMarca, caracter, caracter de marcação

@return lRet, boolean, se o registro marcado for valido, retorna verdadeiro

/*/
//---------------------------------------------------------------------
Static Function ValidMark(cTRB, cMarca)

	Local lRet :=  .T.
	Local cCodRes

	If !Empty(M->TH3_TIPDES) .And. !Empty(M->TH3_CODTIP)
		dbSelectArea(cTRB)
		cCodRes := Posicione("TB0", 1, xFilial("TB0") + (cTRB)->TRB_CODOCO, "TB0_CODRES")
		dbSelectArea("TB7")
		dbSetOrder(1)
		If !dbSeek(xFilial("TB7") + cCodRes + M->TH3_TIPDES + M->TH3_CODTIP)
			lRet := .F.
			Help(,, 'Help',, STR0016 +;
				CRLF + CRLF + STR0017, 1, 0)
			(cTRB)->TRB_OK := " "
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SG531RES
Carrega TRBs da Composição da Carga para Transporte

@author  Bruno Lobo de Souza
@since   02/03/2018
@sample  SG531RES(3)
@param   nOperation, numeric, operação realizada ex.: inclusão
@type    function
/*/
//-------------------------------------------------------------------
Function SG531RES(nOperation, cWhere)

	Local cQuery
	Default cWhere := ""

	dbSelectArea(cTRBDIS)
	ZAP
	dbSelectArea(cTRBSEL)
	ZAP

	If nOperation <> 3
		cQuery := " SELECT TH4.TH4_CODOCO AS TRB_CODOCO, "
		cQuery += "	TH4.TH4_PESOUT AS TRB_PESOTO, TB0.TB0_CODRES AS TRB_CODRES, "
		cQuery += " TH4.TH4_UNIMED AS TRB_UNIMED, TB0.TB0_DATA AS TRB_DATA "
		cQuery += " FROM " + RetSqlName("TH4") + " TH4 "
		cQuery += " INNER JOIN " + RetSqlName("TB0") + " TB0 ON "
		cQuery += " TB0.TB0_FILIAL = " + ValToSQL(xFilial("TB0")) + " AND "
		cQuery += " TB0.TB0_CODOCO = TH4.TH4_CODOCO AND TB0.D_E_L_E_T_ <> '*' "
		cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON "
		cQuery += " SB1.B1_FILIAL = " + ValToSQL(xFilial("SB1")) + " AND SB1.B1_COD = TB0.TB0_CODRES"
		cQuery += " WHERE TH4.TH4_FILIAL = " + ValToSql(xFilial("TH4"))
		cQuery += " AND TH4.TH4_CODCOM = " + ValToSql(M->TH3_CODCOM)
		cQuery += " AND TH4.D_E_L_E_T_ <> '*' "
		SqlToTrb(cQuery, aDBF, cTRBSEL)
	Else
		cQuery := " SELECT TB0.TB0_CODOCO AS TRB_CODOCO, "
		cQuery += " TB0.TB0_CODRES AS TRB_CODRES, SB1.B1_DESC AS TRB_NOMRES,"
		cQuery += " (TB0.TB0_QTDE-TB0.TB0_QTDDES) AS TRB_PESOTO,"
		cQuery += " TB0.TB0_UNIMED AS TRB_UNIMED, TB0.TB0_DATA AS TRB_DATA"
		cQuery += " FROM " + RetSqlName("TB0") + " TB0"
		cQuery += " INNER JOIN " + RetSqlName("TAX") + " TAX"
		cQuery += " ON TB0.TB0_FILIAL = TAX.TAX_FILIAL"
		cQuery += " AND TB0.TB0_CODRES = TAX.TAX_CODRES"
		cQuery += " INNER JOIN " + RetSqlName("TCS") + " TCS"
		cQuery += " ON TAX.TAX_CLASSE = TCS.TCS_CLASSE"
		cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1"
		cQuery += " ON TAX.TAX_CODRES = SB1.B1_COD"
		If !Empty(cWhere)
			cQuery += " INNER JOIN " + RetSqlName("TB7") + " TB7"
			cQuery += " ON TAX.TAX_FILIAL = TB7.TB7_FILIAL"
			cQuery += " AND TAX.TAX_CODRES = TB7.TB7_CODRES"
			cQuery += cWhere
		EndIf
		cQuery += " WHERE TB0.TB0_FILIAL = " + ValToSql(xFilial("TB0"))
		cQuery += " AND TB0.TB0_QTDE > TB0.TB0_QTDDES"
		cQuery += " AND TAX.TAX_FILIAL = " + ValToSql(xFilial("TAX"))
		cQuery += " AND TCS.TCS_PERIGO <> '1'"
		cQuery += " AND TB0.D_E_L_E_T_ <> '*'"
		cQuery += " AND TAX.D_E_L_E_T_ <> '*'"
		cQuery += " AND TCS.D_E_L_E_T_ <> '*'"
		If !Empty(cWhere)
			cQuery += " AND TB7.D_E_L_E_T_ <> '*'"
		EndIf
		SqlToTrb(cQuery, aDBF, cTRBDIS)
	EndIf

	(cTRBSEL)->(dbGoTop())
	(cTRBDIS)->(dbGoTop())
	If nOperation == 3
		oMarkDis:oBrowse:Refresh()
		oMarkSel:oBrowse:Refresh()
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} fTrocaOco
Passa as ocorrencias de um lado para outro da tela

@author  Bruno Lobo de Souza
@since   05/03/2018
@sample  fTrocaOco( cTRBDIS, cTRBSEL, .T. )
@param   cTRBDe, caracter, tabela temporaria origem
@param	 cTRBPara, caracter, tabela temporaria destino
@param	 lSoma, boolean, indica se incrementa o peso
@type    function
/*/
//-------------------------------------------------------------------
Static Function fTrocaOco(cTRBDe, cTRBPara, lSoma)

	Local oModel	:= FWModelActive()
	Local oModelTH4	:= oModel:GetModel("GRIDTH4")
	Local oView		:= FWViewActive()

	dbSelectArea(cTRBDe)
	dbGoTop()
	While !Eof()
		If !Empty((cTRBDe)->TRB_OK)
			dbSelectArea(cTRBPara)
			dbSetOrder(1)
			If dbSeek((cTRBDe)->TRB_CODOCO)
				RecLock(cTRBPara, .F.)
				(cTRBPara)->TRB_PESOTO += (cTRBDe)->TRB_PESOTO
			Else
				RecLock(cTRBPara, .T.)
				(cTRBPara)->TRB_OK     := (cTRBDe)->TRB_OK
				(cTRBPara)->TRB_CODOCO := (cTRBDe)->TRB_CODOCO
				(cTRBPara)->TRB_CODRES := (cTRBDe)->TRB_CODRES
				(cTRBPara)->TRB_NOMRES := (cTRBDe)->TRB_NOMRES
				(cTRBPara)->TRB_PESOTO := (cTRBDe)->TRB_PESOTO
				(cTRBPara)->TRB_UNIMED := (cTRBDe)->TRB_UNIMED
				(cTRBPara)->TRB_DATA   := (cTRBDe)->TRB_DATA
			EndIf
			MsUnLock()

			If lSoma
				oModelTH4:AddLine()
				oModelTH4:SetValue("TH4_CODCOM", M->TH3_CODCOM)
				oModelTH4:SetValue("TH4_CODOCO", (cTRBPara)->TRB_CODOCO)
				oModelTH4:SetValue("TH4_PESOUT", (cTRBPara)->TRB_PESOTO)
				oModelTH4:SetValue("TH4_UNIMED", (cTRBPara)->TRB_UNIMED)
			ElseIf oModelTH4:SeekLine({{"TH4_CODCOM", M->TH3_CODCOM},;
										{"TH4_CODOCO", (cTRBDe)->TRB_CODOCO}})
				oModelTH4:DeleteLine()
			EndIf

			dbSelectArea(cTRBDe)
			RecLock(cTRBDe , .F.)
			(cTRBDe)->(dbDelete())
			(cTRBDe)->(MsUnLock())
		EndIf
		dbSkip()
	End

	dbSelectArea(cTRBDe)
	dbGoTop()
	dbSelectArea(cTRBPara)
	dbGoTop()
	oMarkDis:oBrowse:Refresh()
	oMarkSel:oBrowse:Refresh()

	oView:Refresh()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} fBuscaValue
Apresenta tela para seleção do almoxarifado

@author  Jackson Machado
@since   27/03/2018
@sample  fBuscaValue(oView)
@param   oView, object, instância da view
@type    function
/*/
//-------------------------------------------------------------------
Static Function fBuscaValue(oView)

	Local nOco
	Local i
	Local nPos
	Local nOperation	:= oView:GetOperation()
	Local oModel		:= FWModelActive()
	Local oModelTH4		:= oModel:GetModel("GRIDTH4")
	Local aSaveLines	:= FwSaveRows()
	Local aLocEst		:= {}
	Local lOk
	Local oPnlAll
	Local oPnlTop

	Private oGetMov
	Private aHeader := {}
	Private aCols	:= {}
	Private aSim	:= {"TB4_CODOCO", "TB4_CODDES", "TB4_DESCDE", "TB4_QUANTI",;
						"TB4_UNIMED", "TB4_LOTECT", "TB4_NUMLOT", "TB4_DTVALI"}

	If nOperation <> 5 .And. SuperGetMV("MV_NGSGAES", .F., "N" ) <> "N"

		aHeader := CabecGetD("TB4", {})

		For nOco := 1 To oModelTH4:Length()
			oModelTH4:GoLine(nOco)
			dbSelectArea("TB4")
			dbSetOrder(1)
			dbSeek(xFilial("TB4") + oModelTH4:GetValue("TH4_CODOCO"))
			While !Eof() .And. xFilial("TB4") +;
				oModelTH4:GetValue("TH4_CODOCO") == TB4->TB4_FILIAL + TB4->TB4_CODOCO
				aAdd(aLocEst, BlankGetD(aHeader)[1])
				For i := 1 To Len(aSim)
					nPos := GdFieldPos(aSim[i])
					If nPos > 0
						If aSim[i] == "TB4_CODOCO"
							aLocEst[Len(aLocEst)][nPos] := TB4->TB4_CODOCO
						ElseIf aSim[i] == "TB4_CODDES"
							aLocEst[Len(aLocEst)][nPos] := TB4->TB4_CODDES
						ElseIf aSim[i] == "TB4_DESCDE"
							dbSelectArea("TB2")
							dbSetOrder(1)
							If dbSeek(xFilial("TB2")+TB4->TB4_CODDES)
								If TB2->TB2_TIPO == "1"
									aLocEst[Len(aLocEst)][nPos] := TB2->TB2_DESLOC
								Else
									aLocEst[Len(aLocEst)][nPos] := SA2->A2_NOME
								Endif
							Endif
						ElseIf aSim[i] == "TB4_UNIMED"
							aLocEst[Len(aLocEst)][nPos] := oModelTH4:GetValue("TH4_UNIMED")
						Endif
					Endif
				Next i
				dbSelectArea("TB4")
				dbSkip()
			End

			If Len(aLocEst) > 1
				aCols := aClone(aLocEst)
			EndIf
		Next nOco

		If Len(aCols) > 0

			//------------- Define tela -------------
			DEFINE MSDIALOG oDlgMov TITLE "" From 6.5, 10 To 29, 115 Of oMainWnd Style DS_MODALFRAME
			oDlgMov:lEscClose := .F.
			oPnlAll := TPanel():New(0, 0, Nil, oDlgMov, Nil, .T., .F., Nil, Nil, 0, 0, .T., .F.)
				oPnlAll:Align := CONTROL_ALIGN_ALLCLIENT

			oPnlTop := TPanel():New( 00, 00,, oPnlAll,,,, NGColor()[1], NGColor()[2], 200, 200, .F., .F.)
				oPnlTop:Align	:= CONTROL_ALIGN_TOP
				oPnlTop:nHeight := 20

			@ 002, 004 Say OemToAnsi( STR0009 ) Of oPnlTop Pixel //"Preencha abaixo as quantidades do resíduo que serão retiradas de cada Armazém."

			oGetMov := MsNewGetDados():New(40, 1, 125, 315, (GD_INSERT+GD_UPDATE+GD_DELETE), ;
							{ | | .T. }, { | | .T. },,,, 9999,,,, oPnlAll, aHeader, aCols)
				oGetMov:oBrowse:Refresh()
				oGetMov:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

			ACTIVATE MSDIALOG oDlgMov ON INIT;
			EnchoiceBar(oDlgMov, {|| lOk := .T., If(!ValIntEst(), lOk := .F., oDlgMov:End())},;
			{|| lOk := .F., MsgInfo(STR0005)}) Centered
		EndIf

		oEvent:aTB4Sch := aClone(aCols)

		FwRestRows(aSaveLines)
	EndIf

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} ValIntEst

Valida a integração com o estoque.

@author  Bruno Lobo de Souza
@since   10/04/2018
@sample  ValIntEst()
@type    Function
/*/
//-------------------------------------------------------------------
Static Function ValIntEst()

	Local i
	Local nPosQtd	:= gdFieldPos("TB4_QUANTI")
	Local nPosOco	:= gdFieldPos("TB4_CODOCO")
	Local nPosValue := 0
	Local cText		:= ""
	Local lRet		:= .T.
	Local oModel	:= FWModelActive()
	Local oModelTH4	:= oModel:GetModel("GRIDTH4")
	Local aValues	:= {}

	//Soma as quantidades de cada local de estoque
	For i := 1 To Len(oGetMov:aCols)
		If (nPosValue := aScan(aValues, {|x| x[1] == oGetMov:aCols[i][nPosOco]})) > 0
			aValues[nPosValue][2] += oGetMov:aCols[i][nPosQtd]
		Else
			aAdd(aValues, {oGetMov:aCols[i][nPosOco], oGetMov:aCols[i][nPosQtd]})
		EndIf
	Next i

	//Compara as quantidades dos diferentes locais de estoque somadas com a quantidade informada na ocorrência
	For i := 1 To Len(aValues)
		If oModelTH4:SeekLine({{"TH4_CODOCO", aValues[i][1]}})
			If aValues[i][2] <> oModelTH4:GetValue("TH4_PESOUT")

				If i == 1
					cText := STR0011 + CHR(10) //"O peso informado para a(s) ocorrência(s) difere(m) do peso utilizado na composição da carga."
				EndIf
				cText += CHR(10) + STR0012 + oModelTH4:GetValue("TH4_CODOCO") //"O peso informado para a(s) ocorrência(s) difere(m) do peso utilizado na composição da carga."
				cText += STR0013 + AllTrim(Transform(aValues[i][2],PesqPict("TH4","TH4_PESOUT"))) //"Para a ocorrência "
				cText += STR0014 + AllTrim(Transform(oModelTH4:GetValue("TH4_PESOUT"),PesqPict("TH4","TH4_PESOUT"))) //", deveria ter sido informado - "

				lRet := .F.
			EndIf
		EndIf
	Next i
	If !Empty(cText)
		cText += CHR(10) + CHR(10) + STR0015 //"Atenção"
		NGMSGMEMO(STR0010, cText)
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fTotal

Totalizadores

@type    static function

@author  Bruno Lobo de Souza
@since   08/06/2018

@return .T., sempre verdadeiro
/*/
//-------------------------------------------------------------------
Static Function fTotal()

	Local cAliasTot := GetNextAlias()
	Local oTempTable
	Local oDlgTotal
	Local oPanel
	Local oBrw
	Local cAliasTot := fGetTotal(@oTempTable, cAliasTot)
	Local aColumns := {}

	oDlgTotal := TDialog():New(180, 180, 550, 1300, STR0025,,,,, CLR_BLACK, CLR_WHITE,,, .T.)
		oPanel := TPanel():New(0, 0, Nil, oDlgTotal, Nil, .T., .F., Nil, Nil, 0, 0, .T., .F.)
			oPanel:Align := CONTROL_ALIGN_ALLCLIENT

			aAdd(aColumns,{STR0020, {|| (cAliasTot)->CODRES}, "C",;
				PesqPict("TAX", "TAX_CODRES"), 1, 0, 0})
			aAdd(aColumns,{STR0021, {|| (cAliasTot)->DESRES}, "C",;
				PesqPict("TAX", "TAX_DESCRE"), 1, 0, 0})
			aAdd(aColumns,{STR0022, {|| (cAliasTot)->UNIMED}, "C",;
				PesqPict("TH4", "TH4_UNIMED"), 1, 0, 0})
			aAdd(aColumns,{STR0023, {|| (cAliasTot)->QTDDIS}, "N",;
				PesqPict("TH4", "TH4_PESOUT"), 2, 0, 0})
			aAdd(aColumns,{STR0024, {|| (cAliasTot)->QTDSEL}, "N",;
				PesqPict("TH4", "TH4_PESOUT"), 2, 0, 0})

			oBrw := FWFormBrowse():New()
				oBrw:SetOwner(oPanel)
				oBrw:SetDescription(STR0026)
				oBrw:SetDataTable(.T.)
				oBrw:SetAlias(cAliasTot)
				oBrw:SetTemporary(.T.)
				oBrw:DisableDetails()
				oBrw:SetColumns(aColumns)
				oBrw:Activate(oPanel)

	oDlgTotal:Activate(,,, .T., {||.T.},, {||})

	oTempTable:Delete()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetTotal

Busca valores

@type	Static Function

@author  Bruno Lobo de Souza
@since   11/06/2018

@return cAliasTot, caracter, alias da tabela temporária de totalizadores
/*/
//-------------------------------------------------------------------
Static Function fGetTotal( oTempTable , cAliasTot )

	Local aDbfTot := {}
	Local n
	Local aArea := GetArea()

	aAdd(aDbfTot, {"CODRES", "C", TamSX3("TAX_CODRES")[1], 0})
	aAdd(aDbfTot, {"DESRES", "C", TamSX3("B1_DESC")[1], 0})
	aAdd(aDbfTot, {"UNIMED", "C", TamSX3("TH4_UNIMED")[1], 0})
	aAdd(aDbfTot, {"QTDDIS", "N", TamSX3("TH4_PESOUT")[1]+1, TamSX3("TH4_PESOUT")[2]})
	aAdd(aDbfTot, {"QTDSEL", "N", TamSX3("TH4_PESOUT")[1]+1, TamSX3("TH4_PESOUT")[2]})

	oTempTable := FWTemporaryTable():New(cAliasTot, aDbfTot)
		oTempTable:AddIndex("1", {"CODRES"})
		oTempTable:Create()

	For n := 1 To 2
		cTemp := IIf(n == 1, cTRBDIS, cTRBSEL)
		dbSelectArea(cTemp)
		dbGoTop()
		While !(cTemp)->(Eof())
			dbSelectArea(cAliasTot)
			dbSetOrder(1)
			If dbSeek((cTemp)->TRB_CODRES)
				RecLock(cAliasTot, .F.)
					If n == 1
						(cAliasTot)->QTDDIS += (cTemp)->TRB_PESOTO
					Else
						(cAliasTot)->QTDSEL += (cTemp)->TRB_PESOTO
					EndIf
				MsUnlock()
			Else
				RecLock(cAliasTot, .T.)
					(cAliasTot)->CODRES := (cTemp)->TRB_CODRES
					(cAliasTot)->DESRES := (cTemp)->TRB_NOMRES
					(cAliasTot)->UNIMED := (cTemp)->TRB_UNIMED
					If n == 1
						(cAliasTot)->QTDDIS := (cTemp)->TRB_PESOTO
					Else
						(cAliasTot)->QTDSEL := (cTemp)->TRB_PESOTO
					EndIf
				MsUnlock()
			EndIf

			(cTemp)->(dbSkip())
		EndDo
	Next n
	RestArea(aArea)

Return cAliasTot

//-------------------------------------------------------------------
/*/{Protheus.doc} fRfrshOco

Atualiza grid(TH4) de acordo com os campos de 'Tipo' (TH3_TIPDES)
e 'Cod. Tipo' (TH3_CODTIP)

@type    static function

@author  Bruno Lobo de Souza
@since   13/06/2018

@param   oView, object, objeto da view
@param   cIDView, caracter, identificador (ID) da view
@param   cField, caracter, identificador (ID) do campo
@param   xValue, undefined, conteúdo Do campo

@return .T., boolean, sempre verdadeiro
/*/
//-------------------------------------------------------------------
Static Function fRfrshOco(oView, cIDView, cField, xValue)

	Local nOperation := oView:GetOperation()
	Local oModel	 := FWModelActive()
	Local oModelTH3	 := oModel:GetModel("FORMTH3")
	Local cWhere	 := ""

	If !IsInCallStack("SQLTOTRB")
		If cField == "TH3_TIPDES"
			cWhere := " AND TB7.TB7_TIPO = " + ValToSql(xValue)
		Else
			cWhere := " AND TB7.TB7_TIPO = " + ValToSql(oModelTH3:GetValue("TH3_TIPDES"))
			cWhere += " AND TB7.TB7_CODTIP = " + ValToSql(xValue)
		EndIf

		SG531RES(nOperation,cWhere)
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT531TPD

Validação dos campos referentes a destinação TH3_TIPDES e TH3_CODTIP

@type  Function
@author Bruno Lobo de Souza
@since 14/06/2018
@return lRet, boolean, return_description
/*/
//-------------------------------------------------------------------
Function MDT531When(cField)

	Local lRet     := .T.

	Default cField := Readvar()

	lRet := Type("cTRBSEL") <> "C" .Or. Select(cTRBSEL) == 0 .Or. (cTRBSEL)->(Eof())

	If cField == "TH3_CODTIP" .And. lRet
		lRet := !Empty(M->TH3_TIPDES)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fCreateTRB

Cria tabelas temporárias

@type    static function

@author  Bruno Lobo de Souza
@since   18/06/2018

@return nil
/*/
//-------------------------------------------------------------------
Static Function fCreateTRB()

	//Array com os campos para criação da tabela temporária
	aAdd(aDBF, {"TRB_OK"	, "C", 2, 0 } )
	aAdd(aDBF, {"TRB_CODOCO", "C", TAMSX3("TH4_CODOCO")[1], 0})
	aAdd(aDBF, {"TRB_CODRES", "C", TAMSX3("TAX_CODRES")[1], 0})
	aAdd(aDBF, {"TRB_NOMRES", "C", TAMSX3("B1_DESC")[1], 0})
	aAdd(aDBF, {"TRB_PESOTO", "N", TAMSX3("TH4_PESOUT")[1], TAMSX3("TH4_PESOUT" )[2]})
	aAdd(aDBF, {"TRB_UNIMED", "C", TAMSX3("TH4_UNIMED")[1], 0})
	aAdd(aDBF, {"TRB_DATA"  , "D", TAMSX3("TB0_DATA")[1]  , TAMSX3("TB0_DATA")[2]})

	oTempDIS := FWTemporaryTable():New(cTRBDIS, aDBF)
		oTempDIS:AddIndex("1", {"TRB_CODOCO"})
		oTempDIS:Create()

	oTempSEL := FWTemporaryTable():New(cTRBSEL, aDBF)
		oTempSEL:AddIndex("1", { "TRB_CODOCO"})
		oTempSEL:Create()

Return
