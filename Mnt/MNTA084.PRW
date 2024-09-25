#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MNTA084.CH"

Static oST9 := Nil
Static cCatFrota := ''

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTA084
Cadastro de veículos
@type function

@author NG Informática Ltda.
@since 01/01/2015

@param
@return
/*/
//------------------------------------------------------------------------------
Function MNTA084()

	Local aNGBeginPrm := {}
	Local oBrowse

	// Validation
	Local lValid	  := .T.
	Local cError	  := ''
	Local cSolution   := ''
	Local lMNTA0844   := .F.

	//Filtro Browse
	Local cFiltro	:= "ST9->T9_CATBEM $ '24'"

	// View
	Private cCadastro := STR0001 //"Cadastro de Veiculos"
	Private lFrota	  := .F.
	Private nOptRot   := 3
	Private cCatOrig  := "" //Categoria original do veículo. Usado para controlar uma mudança de integrado ao TMS para não integrado.
	Private aArrayTMS := {} //Array de bkp que possuí os registros de TMS caso o cCatOrig seja '2'.

	//Variaveis utilizadas na colsulta de OS referente ao bem correte
	Private TIPOACOM  := .F.
	Private TIPOACOM2 := .F.
	Private lSITUACA  := .F.

	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 19, 88, 95 )

		aNGBeginPrm := NGBeginPrm()
		lMNTA0844   := ExistBlock( 'MNTA0844' )
		lFrota      := IIf( GetRPORelease() >= '12.1.033', MNTFrotas(), SuperGetMv( 'MV_NGMNTFR', .F., 'N' ) == 'S' )
		TIPOACOM    := M->T9_TEMCONT <> 'N'
		TIPOACOM2   := M->TPE_SITUAC <>  2

		// Initial Validations
		If !lFrota
			lValid    := .F.
			cError    := STR0002 //'Para cadastro de veículos, precisa integração com frotas através do parâmetro MV_NGMNTFR.'
			cSolution := STR0003 //'Acessar o módulo configurador SIGACFG e efetuar a alteração do parâmetro.'
		EndIf

		If !NGCADICBASE('T6_CATBEM','A','ST6',.F.) //!NGCHKDIC( 2,, "T6_CATBEM" )
			lValid    := .F.
			cError    := STR0045 //'Para cadastro de veículos, precisa da ultima release 12.1.7.'
			cSolution := STR0046 //'Atualizar o ambiente.'
		EndIf

		If lValid

			//Caso possua o ponto de entrada 'MNTA0842' deverá trocar para o modelo MVC.
			If !FindFunction('U_MNTA084') .And. (FindFunction('U_MNTA0841') .Or. FindFunction('U_MNTA0842'))
				MsgInfo( STR0051, STR0050 ) // 'O ponto de entrada "MNTA0842" deve ser alterado conforme o novo modelo. Favor pesquisar a ISSUE MNG-6281 no TDN.'##'PONTO DE ENTRADA MNTA0842'
			EndIf

			If lMNTA0844
				cFiltro += ExecBlock("MNTA0844",.F.,.F.)
			EndIf
			//Initializes Browse
			oBrowse := FWMBrowse():New()
			oBrowse:SetAlias("ST9")
			oBrowse:SetDescription( cCadastro )
			oBrowse:SetFilterDefault( cFiltro )
			oBrowse:SetMenuDef("MNTA084")
			LegendST9( oBrowse )
			oBrowse:Activate()
		ElseIf !Empty( cError )
			//Show error
			Help( " ",1,STR0016,,cError + CRLF + cSolution,3,1 ) //"NAO CONFORMIDADE"
		EndIf

		NGReturnPrm( aNGBeginPrm )

	EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Options Menu

@author NG Informática Ltda.
@since 01/01/2015
@version P12
@return Array
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina Title STR0004 Action 'MNTA084CAD(1)'   OPERATION 2 ACCESS 0   //'Visualizar'
	ADD OPTION aRotina Title STR0005 Action 'MNTA084CAD(3)'   OPERATION 3 ACCESS 0   //'Incluir'
	ADD OPTION aRotina Title STR0006 Action 'MNTA084CAD(4)'   OPERATION 4 ACCESS 0   //'Alterar'
	ADD OPTION aRotina Title STR0007 Action 'MNTA084CAD(5)'   OPERATION 5 ACCESS 141 //'Excluir'
	ADD OPTION aRotina Title STR0008 Action 'MNTA080INA()'    OPERATION 6 ACCESS 0   //'Inativar'
	ADD OPTION aRotina Title STR0009 Action 'VIEWDEF.MNTA084' OPERATION 8 ACCESS 0   //'Imprimir'
	ADD OPTION aRotina Title STR0010 Action 'MNTA084CAD(9)'   OPERATION 9 ACCESS 0   //'Copiar'
	ADD OPTION aRotina Title STR0057 Action 'VIEWDEF.MNTA087' OPERATION 4 ACCESS 0   //'Incluir Estrutura'

	If ExistBlock("MNTA0843")
		aRotina := ExecBlock("MNTA0843",.F.,.F.,{ aRotina } )
	EndIf

	If Type("__lPyme") == "U" .Or. !__lPyme
		ADD OPTION aRotina Title STR0011 Action 'MsDocument' OPERATION 4 ACCESS 0 //"Conhecimento"
	EndIf

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} fOpenView
Direciona o cadastro conforme a categoria do veiculo

@author NG Informática Ltda.
@since 01/01/2015
@version P12
@return Array
/*/
//------------------------------------------------------------------------------
Function MNTA084CAD( nOperation )

	Local lValid     := .T.
	Local cError     := ''
	Local cSolution  := ''
	Local cRotinaST9, oExecView

	If nOperation != 3
		cCatFrota := ST9->T9_CATBEM
		cCatOrig  := cCatFrota
	EndIf

	nOptRot := nOperation

	dbSelectArea("DA3")
	dbSetOrder(1)
	dbSeek(xFilial("DA3")+ST9->T9_CODTMS) //Reposiciona a DA3 para verificar o relacionamento do TMS

	If lValid

		oExecView := FWViewExec():New()
		oExecView:SetTitle( STR0001 ) // "Cadastro de Veiculos"
		oExecView:SetSource( "MNTA084" )
		oExecView:SetOK( {|| .T.} )
		oExecView:SetModal(.F.)
		oExecView:SetOperation( nOperation )
		oExecView:OpenView( .F. )

	ElseIf .Not. Empty( cError )
		//----------------------------------------------------------------------
		// Show error
		//----------------------------------------------------------------------
		Help( " ",1,STR0016,,cError + CRLF + cSolution,3,1 ) //"NAO CONFORMIDADE"
	EndIF

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Data Model

@author NG Informática Ltda.
@since 01/01/2015
@version P12
@return oModel
/*/
//------------------------------------------------------------------------------
Static Function ModelDef

	Local oModel
    Local lUltTMS   := (GetNewPar("MV_NGMNTMS","N") == "S") //Indica utilização do TMS

	//--------------------------------------------------------------------------
	// Main Model
	//--------------------------------------------------------------------------
	Local bPosValid := {|oModel| ValidInfo(oModel) } // Final Validation
	Local bCommit	:= {|oModel| CommitInfo(oModel)} // Gravação do formulario
	Local bCancel	:= {|oModel| ValCancel(oModel)} // Gravação do formulario

	//Create object of the data model
	oModel := MPFormModel():New('MNTA084',,bPosValid,bCommit,bCancel)

	//Adds the description of the data model
	oModel:SetDescription(STR0001) //"Cadastro de Veículos"

	//Asset
	ModelST9(oModel)

	//Details
	ModelSTB(oModel)

	//Spare Parts
	ModelTPY(oModel)

	//Tank
	ModelTT8(oModel)

	//Counter
	ModelTPE(oModel)

	//TMS
	If lUltTMS //Se possui integração com TMS cria o Modal do mesmo.
		ModelDA3(oModel)
	EndIf

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelST9
Data Model ST9 - Asset

@author NG Informática Ltda.
@since 01/01/2015
@version P12
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function ModelST9( oModel )

	Local aFldNoCopy := {}
	Local cAlias     := 'ST9'
	Local cModelId   := oModel:cId + '_' + cAlias
	Local oModelAux  := Nil
	Local oStructAux := FWFormStruct( 1, cAlias ) // Cria a estrutura a ser usada no Modelo de Dados

	oStructAux:SetProperty("T9_CATBEM", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD,"'4'"))

	// O campo T9_TIPMOD não é obrigatório no dicionário, mas torna-se obrigatório para o módulo SIGAGFR
	oStructAux:SetProperty("T9_TIPMOD", MODEL_FIELD_OBRIGAT, .T.)

	// Remove campos
	oStructAux:RemoveField("T9_LOCPAD")
	oStructAux:RemoveField("T9_CAPMAX")
	oStructAux:RemoveField("T9_MEDIA" )

	//Ponto de entrada para remover campos da tela
	If ExistBlock("MNTA0845")
		ExecBlock("MNTA0845",.F.,.F.,{1,cAlias,oStructAux})
	EndIf

	// Define campos que não podem ser copiados
	aAdd( aFldNoCopy, 'T9_CODIMOB' )
	aAdd( aFldNoCopy, 'T9_POSCONT' )
	aAdd( aFldNoCopy, 'T9_DTULTAC' )
	aAdd( aFldNoCopy, 'T9_CONTACU' )
	aAdd( aFldNoCopy, 'T9_VARDIA'  )
	aAdd( aFldNoCopy, 'T9_LIMICON' )
	aAdd( aFldNoCopy, 'T9_ESTRUTU' )
	aAdd( aFldNoCopy, 'T9_STATUS'  )
	aAdd( aFldNoCopy, 'T9_PLACA'   )
	aAdd( aFldNoCopy, 'T9_SITMAN'  )
	aAdd( aFldNoCopy, 'T9_SITBEM'  )
	aAdd( aFldNoCopy, 'T9_DTBAIXA' )
	aAdd( aFldNoCopy, 'T9_MTBAIXA' )
	aAdd( aFldNoCopy, 'T9_COMPRAD' )
	aAdd( aFldNoCopy, 'T9_DTVENDA' )
	aAdd( aFldNoCopy, 'T9_NFVENDA' )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( cModelId , , oStructAux )

	// Retorna componente especifico
	oModelAux := oModel:GetModel( cModelId )

	// Adiciona lista de campos ao modelo
	oModelAux:SetFldNoCopy( aFldNoCopy )

	// Adiciona a descricao do Componente do Modelo de Dados
	oModelAux:SetDescription( NgSX2Nome( cAlias ) )

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelTT8
Modelo de dados da TT8

@author NG Informática Ltda.
@since 01/01/2015
@version P12
@return Nil
/*/
//------------------------------------------------------------------------------
Function ModelTT8( oModel )

	Local oModelAux
	Local aRelation := {}
	Local aUnique := {}
	Local cAlias := "TT8"
	Local cModelId := oModel:cId + '_' + cAlias

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStructAux := FWFormStruct( 1, cAlias )

	// Validação de linha TT8
	Local bLinePost := {|oModelGrid| LineTT8Vld( oModelGrid ) }
	Local bPre      := {|oModelGrid , nAt, cAction| LineTT8Del( oModelGrid , nAt , cAction ) }

	// Isso se faz necessário para que o campo possa ser alterado,
	// devido ao LG os campos chaves não podem mais ser alterados
	oStructAux:SetProperty( 'TT8_TPCONT', MODEL_FIELD_KEY, .F. )

	// Define relacionamento entre ST9 e TT8
	aAdd( aRelation , { 'TT8_FILIAL' , 'xFilial( "TT8" )' } )
	aAdd( aRelation , { 'TT8_CODBEM' , 'T9_CODBEM' } )

	//Ponto de entrada para remover campos da tela
	If ExistBlock("MNTA0845")
		ExecBlock("MNTA0845",.F.,.F.,{1,cAlias,oStructAux})
	EndIf

	// Indica qual a chave que não pode repetir na grid
	aAdd( aUnique , 'TT8_CODCOM' )
	aAdd( aUnique , 'TT8_TPCONT' )

	If oStructAux:GetFieldPos('TT8_TIPO') > 0
		aAdd( aUnique , 'TT8_TIPO' )
	EndIf

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddGrid( cModelId , oModel:cId + '_ST9' , oStructAux ,  , bLinePost ,  , bPre )

	// Retorna submodelo
	oModelAux := oModel:GetModel( cModelId )

	// Faz relaciomaneto entre os compomentes do model
	oModelAux:SetRelation( aRelation , ( cAlias )->( IndexKey( 1 ) ) )

	// Indica que o submodelo deve trabalhar com acols/aheader
	oModelAux:SetUseOldGrid(.T.)

	// Liga o controle de nao repeticao de linha
	oModelAux:SetUniqueLine( aUnique )

	// Indica que é opcional ter dados informados na Grid
	oModelAux:SetOptional(.T.)

	// Adiciona a descricao do Componente do Modelo de Dados
	oModelAux:SetDescription( NgSX2Nome( cAlias ) )

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDA3
Modelo de dados da aba de integração com o TMS.

@author Maicon André Pinheiro
@since 25/09/2017
@version P12
@return
/*/
//------------------------------------------------------------------------------
Static Function ModelDA3(oModel)

	Local aFldNoCopy, aRelation, aUnique, oModelAux, oStructAux, cAlias

	//TMS
	cAlias := 'DA3'

	// Cria a estrutura a ser usada no Modelo de Dados
	oStructAux := FWFormStruct( 1, cAlias )

	//Seta o When de todos os campos de Integração com o TMS para permitir edição apenas se for igual a 2-Frota integrada ao TMS.
	oStructAux:SetProperty("*",MODEL_FIELD_WHEN   ,{||M->T9_CATBEM == "2"})

	//Seta todos os campos de integração com o TMS como não obrigatório e valida os mesmos na mão.
	oStructAux:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)

	//Força alguns campos especiificos do TMS como não permitido para alteração em nenhuma situação.
	oStructAux:SetProperty("DA3_COD"   ,MODEL_FIELD_WHEN,{||.F.})
	oStructAux:SetProperty("DA3_CODBEM",MODEL_FIELD_WHEN,{||.F.})
	oStructAux:SetProperty("DA3_PLACA" ,MODEL_FIELD_WHEN,{||.F.})

	//Ponto de entrada para remover campos da tela
	If ExistBlock("MNTA0845")
		ExecBlock("MNTA0845",.F.,.F.,{1,cAlias,oStructAux})
	EndIf

	// Define relacionamento entre ST9 e DA3
	aRelation := {}
	aAdd(aRelation,{"DA3_FILIAL","xFilial('DA3')"})
	aAdd(aRelation,{"DA3_CODBEM","T9_CODBEM"})

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields(oModel:cId + '_' + cAlias,oModel:cId + '_ST9',oStructAux)

	oModelAux := oModel:GetModel(oModel:cId + '_' + cAlias)

	// Faz relaciomaneto entre os compomentes do model
	oModelAux:SetRelation(aRelation,(cAlias)->(IndexKey(5)))

	// Adiciona a descricao do Componente do Modelo de Dados
	oModelAux:SetDescription(NgSX2Nome(cAlias))

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface da rotina

@author NG Informática Ltda.
@since 01/01/2015
@version P12
@return oView
/*/
//------------------------------------------------------------------------------
Static Function ViewDef

	Local oView
    Local aWhenBtn
	Local oModel := FWLoadModel( 'MNTA084' )
    Local lUltTMS   := (GetNewPar("MV_NGMNTMS","N") == "S") //Indica utilização do TMS

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	// Cria Box na view
	oView:CreateHorizontalBox( 'MAIN', 100 )

	// Cria Folder na view
	oView:CreateFolder( 'MAIN_FOLDER' , 'MAIN' )

	//Asset
	ViewST9(oView,oModel)

	//Details
	ViewSTB(oView,oModel)

	//Spare Parts
	ViewTPY(oView,oModel)

	//Counter
	ViewCounter(oView,oModel)

	//Tank
	ViewTT8(oView,oModel)

	//TMS
	If lUltTMS //Se possui integração com TMS cria o View do mesmo.
		ViewDA3(oView,oModel)
	EndIf

	//--------------------------------------------------------------------------
	// Complementos
	//--------------------------------------------------------------------------
	aWhenBtn := WhenBtn()

	//Inclusão de itens no Ações Relacionadas de acordo com o NGRightClick
	NGMVCUserBtn(oView , , , aWhenBtn )

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewST9
View from ST9

@author NG Informática Ltda.
@since 01/01/2015
@version P12
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function ViewST9( oView , oModel )

	Local cAlias  := 'ST9'
    Local lUltTMS := (GetNewPar("MV_NGMNTMS","N") == "S") //Indica utilização do TMS

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStructAux := FWFormStruct( 2 , cAlias )

	oStructAux:SetProperty("T9_CODBEM", MVC_VIEW_TITULO  , STR0017 ) // 'Veículo'
	oStructAux:SetProperty("T9_NOME"  , MVC_VIEW_TITULO  , STR0018 ) // 'Nome Veíc.'

	//Ponto de entrada para remover campos da tela
	If ExistBlock("MNTA0845")
		ExecBlock("MNTA0845",.F.,.F.,{2,cAlias,oStructAux})
	EndIf

	If lUltTMS //Se integrado com o TMS o veículo pode ser selecionado apenas entre as opções 2 ou 4.
		oStructAux:SetProperty("T9_CATBEM", MVC_VIEW_COMBOBOX,{"2=Frota integrada ao TMS","4=Frota nao integrada ao TMS"})
	EndIf

	oStructAux:RemoveField("T9_LOCPAD")
	oStructAux:RemoveField("T9_CAPMAX")
	oStructAux:RemoveField("T9_MEDIA")

	If !lUltTMS //Se não integrado remove o campo de categoria do bem da tela pois o mesmo só poderar se CATBEM == 4
		oStructAux:RemoveField("T9_CATBEM")
	EndIf

	oStructAux:RemoveField("TPE_CODBEM")

	// Remove todos os campos do agrupamento de contador
	FilterField(oStructAux , '004' , .T.)

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_' + cAlias , oStructAux , oModel:cId + '_' + cAlias )

	// Cria pastas nas folders
	oView:AddSheet( 'MAIN_FOLDER', 'ABA_' + cAlias , 'Bem' )

	// Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'BOX_' + cAlias , 100,,, 'MAIN_FOLDER', 'ABA_' + cAlias )

	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_' + cAlias , 'BOX_' + cAlias )

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewTT8
View from TT8

@author NG Informática Ltda.
@since 01/01/2015
@version P12
@return Nil
/*/
//------------------------------------------------------------------------------
Function ViewTT8( oView , oModel )

	Local cAlias := "TT8"

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStructAux := FWFormStruct( 2 , cAlias )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddGrid( 'VIEW_' + cAlias , oStructAux , oModel:cId + '_' + cAlias )

	//Ponto de entrada para remover campos da tela
	If ExistBlock("MNTA0845")
		ExecBlock("MNTA0845",.F.,.F.,{2,cAlias,oStructAux})
	EndIf

	//Adiciona um titulo para o grid
	oView:EnableTitleView('VIEW_' + cAlias , STR0019 ) // "Informações de Tanque"

	// Cria pastas nas folders
	oView:AddSheet( 'MAIN_FOLDER', 'ABA_' + cAlias , STR0020 ) // 'Tanque'

	// Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'BOX_' + cAlias , 100,,, 'MAIN_FOLDER', 'ABA_' + cAlias )

	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_' + cAlias , 'BOX_' + cAlias )

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDA3
Interface da aba de integração com o TMS.

@author NG Informática Ltda.
@since 01/01/2015
@version P12
@return
/*/
//------------------------------------------------------------------------------
Static Function ViewDA3(oView,oModel)

	Local cAlias     := 'DA3'
	Local oStructAux := FWFormStruct(2,cAlias)

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_' + cAlias , oStructAux , oModel:cId + '_' + cAlias )

	//Ponto de entrada para remover campos da tela
	If ExistBlock("MNTA0845")
		ExecBlock("MNTA0845",.F.,.F.,{2,cAlias,oStructAux})
	EndIf

	//Adiciona um titulo para o grid
	oView:EnableTitleView('VIEW_' + cAlias , STR0001 ) // "Informações de Integração TMS"

	// Cria pastas nas folders
	oView:AddSheet( 'MAIN_FOLDER', 'ABA_' + cAlias , "Integração TMS" ) // "Integração TMS"

	// Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'BOX_' + cAlias , 100,,, 'MAIN_FOLDER', 'ABA_' + cAlias )

	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_' + cAlias , 'BOX_' + cAlias )

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} ValidInfo
Validação ao confirmar tela

@author NG Informática Ltda.
@since 01/01/2015
@version P12
@return Bool
/*/
//------------------------------------------------------------------------------
Static Function ValidInfo( oModel )

	// Inicializa classe
	oST9 := MntVeiculo():New()

	// Carrega a classe com modelo de dados
	oST9:ModelToClass( oModel )

	// Executa validação final
	oST9:Valid()

	// Se houver, apresenta erro
	oST9:ShowHelp()

Return oST9:IsValid()

//------------------------------------------------------------------------------
/*/{Protheus.doc} CommitInfo
Grava todas as informações

@author NG Informática Ltda.
@since 01/01/2015
@version P12
@return Bool
/*/
//------------------------------------------------------------------------------
Static Function CommitInfo( oModel )

	Local lIntTec 	 := .F.
	Local lAltLin    := .F.
	Local lMnt084    := ExistBlock("MNTA084")
	Local nX         := 0
	Local nLenSub    := Len(oModel:AallSubModels) //Verificar se possui SubModelos.
	Local lReturn    := .T.
	Local aHeadStr   := {}
	Local cError     := ''
	Local cNotImpMsg := ''
	Local cGetPost   := ''
	Local cResponse  := ''
	Local cBroBot    := SuperGetMV( 'MV_NGBROBO', .F., '')
	Local nStatus    := 0
	Local oParser

	If nLenSub > 0 .And. lMnt084//Caso possua Sub-Modelos
		For nX := 1 To nLenSub //Percorre todos.
			If oModel:AallSubModels[nX]:cId == 'MNTA080_STB' .Or.; //Verifica os modelos que possuem grid.
				oModel:AallSubModels[nX]:cId == 'MNTA080_TPY' .Or.;
				oModel:AallSubModels[nX]:cId == 'MNTA080_TT8'
				If Len(oModel:AallSubModels[nX]:GetLinesChanged()) > 0 //Caso possua alguma linha alterada.
					lAltLin := .T.
					Exit
				EndIf
			EndIf
		Next nX
	EndIf

	If lMnt084
		ExecBlock("MNTA084",.F.,.F.,{oModel,'FORMCOMMITTTSPRE','MNTA084',lAltLin})
	EndIf

	DbSelectArea('AA3')
	lIntTEC := FindFunction("At040ImpST9") .And. ( AA3->(FieldPos('AA3_CODBEM')) > 0 )

	Do Case
		Case oST9:IsUpsert() //Upsert - Executa inclusão ou alteração do cadastro

			If oST9:Upsert() .And. oST9:IsInsert()
				ConfirmSX8()
			EndIf

		Case oST9:IsDelete() // Delete - Executa exclusão do cadastro
			oST9:Delete()
	Endcase

	If lMnt084
		ExecBlock("MNTA084",.F.,.F.,{oST9,'MODELCOMMITTTS','MNTA084'})
	EndIf

	If oModel:GetOperation() == MODEL_OPERATION_INSERT .And. !Empty( cBroBot ) .And. !Empty( oModel:GetValue( 'MNTA084_ST9', 'T9_PLACA' ) );
		.And. !Empty( oModel:GetValue( 'MNTA084_ST9', 'T9_RENAVAM' ) ) .And. !Empty( oModel:GetValue( 'MNTA084_ST9', 'T9_UFEMPLA' ) )
		
		aHeadStr   := { 'token: ' + cBroBot, 'Content-Type: application/json; charset=UTF-8' } 

		cGetPost := '{ "plate":"'   + oModel:GetValue( 'MNTA084_ST9', 'T9_PLACA' )   + '",'
		cGetPost += '  "renavam":"' + oModel:GetValue( 'MNTA084_ST9', 'T9_RENAVAM' ) + '",'
		cGetPost += '  "uf":"'      + oModel:GetValue( 'MNTA084_ST9', 'T9_UFEMPLA' ) + '"}'

		cResponse := HTTPPost( 'https://api.platform.brobot.com.br/api/v2/vehicles', /*cGetParms*/, cGetPost, /*nTimeOut*/, aHeadStr )
		
		// Verificar e tratar o retorno para quando existir erros de processos.
		nStatus   := HTTPGetStatus( cError )

		If nStatus == 403
			
			cNotImpMsg := STR0060 + CRLF //'Token informado no parâmetro MV_NGBROBO está incorreto!'
			
			If FWJsonDeserialize( cResponse, @oParser ) .And. AttIsMemberOf( oParser, 'Data' ) .And. AttIsMemberOf( oParser:Data, 'Errors' )
				cNotImpMsg += DecodeUTF8( oParser:Data:Errors[ 1 ] )
			EndIf
			
			// Adiciona mensagem de erro
			oModel:SetErrorMessage( 'MNTA084_ST9', , , , STR0059, cNotImpMsg ) // Atenção
			lReturn := .F.
			
		ElseIf nStatus != 201
			
			// Salva mensagem de retorno da API
			If FWJsonDeserialize( cResponse, @oParser ) .And. AttIsMemberOf( oParser, 'Errors' )
				cNotImpMsg += DecodeUTF8( oParser:Errors[ 1 ] )
			EndIf
			
			// Adiciona mensagem de erro
			oModel:SetErrorMessage( 'MNTA084_ST9', , , , STR0059, cNotImpMsg ) // 'Atenção'
			lReturn := .F.
		EndIf

	EndIf

	// Se houver, apresenta erro
	oST9:ShowHelp()
	
	If lReturn
	
		// se houver integração com SIGATEC - Gestão de Serviços
		If lIntTEC .And. oModel:GetOperation() == MODEL_OPERATION_UPDATE
			At040BmxBa()
		EndIf

		If lMnt084
			ExecBlock("MNTA084",.F.,.F.,{oModel,'FORMCOMMITTTSPOS','MNTA084',lAltLin})
		EndIf

		//Ponto de entrada executado após gravações
		If lMnt084
			ExecBlock("MNTA084",.F.,.F.,{oST9,'MODELCOMMITNTTS','MNTA084'})
		EndIf

	EndIf

	// Limpa classe
	oST9:Free()

Return lReturn

//------------------------------------------------------------------------------
/*/{Protheus.doc} LineTT8Vld
Validação de linha - Tanque

@author NG Informática Ltda.
@since 01/01/2015
@version P12
@return Bool
/*/
//------------------------------------------------------------------------------
Static Function LineTT8Vld( oModelGrid )

	Local lValid	:= .T.
	Local cError	:= ''
	Local cSolution	:= ''
	Local cSolutAdd	:= ''
	Local cFieldObg	:= ''

	If oModelGrid:IsDeleted()
		DBSelectArea( 'TQN' )
		DBSetOrder( 1 )
		DBSeek( xFilial( 'TQN' ) + M->T9_CODBEM )
		While .Not. TQN->( Eof() ) .And.;
		TQN->TQN_FILIAL == xFilial( 'TQN' ) .And.;
		TQN->TQN_FROTA == M->T9_CODBEM
			If 	TQN->TQN_CODCOM == FWFldGet('TT8_CODCOM')
				cError := STR0021 // "Não é possível excluir o tanque, pois já existe um abastecimento."
				lValid := .F.
				Exit
			EndIf
			TQN->( dbSkip() )
		End
	Else

		If Empty( FWFldGet('TT8_CODCOM') )
			cFieldObg := 'TT8_CODCOM'
		ElseIf Empty( FWFldGet('TT8_CAPMAX') )
			cFieldObg := 'TT8_CAPMAX'
		ElseIf Empty( FWFldGet('TT8_MEDIA') )
			cFieldObg := 'TT8_MEDIA'
		ElseIf Empty( FWFldGet('TT8_TPCONT') ) .And. ( M->T9_TEMCONT == "S" .Or. .Not. Empty( M->TPE_POSCON ) )
			cFieldObg := 'TT8_TPCONT'
			cSolutAdd += STR0022 + Space(1) // ", pois o bem possui controle por contador"
			If M->T9_TEMCONT == "S"
				cSolutAdd += "1"
			ElseIf .Not. Empty( M->TPE_POSCON )
				cSolutAdd += "2"
			EndIf
		EndIf

		If .Not. Empty( cFieldObg )
			lValid := .F.
			cError := STR0023 + Space(1) // "O campo"
			cError += RetTitle( cFieldObg ) + Space(1)
			cError += STR0024 + CRLF //"não foi informado."
			cSolution := STR0025 + Space(1) + RetTitle( cFieldObg ) //"Informe o campo"
			cSolution += cSolutAdd
		EndIf

		If lValid

			If FwFldGet('TT8_TIPO') == '1'

				If Empty( NGSEEK("TQM",AllTrim( FwFldGet('TT8_CODCOM') ),1,"TQM_CODCOM") )

					lValid := .F.
					Help(" ",1,"REGNOIS")

				EndIf

			Else

				If Empty( NGSEEK("TZZ",AllTrim( FwFldGet('TT8_CODCOM') ),1,"TZZ_PRODUT") )

					lValid := .F.
					Help(" ",1,"REGNOIS")

				EndIf

			EndIf 

		EndIf

	EndIf

	If .Not. Empty( cError )
		Help( " ",1,STR0016,,cError + CRLF + cSolution,3,1 ) //"NAO CONFORMIDADE"
	EndIf

Return lValid

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTA084VLD
Validação de campos

@author NG Informática Ltda.
@since 01/01/2015
@version P12
@return Bool
/*/
//------------------------------------------------------------------------------
Function MNTA084VLD( cField )

	// Variaveis de retorno
	Local xContent
	Local lValid   := .T.
	Local cError   := ''
	Local aAreaST9 := {}
	Local aTrigger := {}

	Private lFlagSCnt := NGCADICBASE("TPE_SITUAC", "A", "TPE", .F.) //Indica se é possível ativar/desativar segundo contador

	// Campo a ser validado
	Default cField := ReadVar()

	//--------------------------------------------------------------------------
	// T9_CODTMS - Codigo TMS
	//--------------------------------------------------------------------------
	If 'T9_CODTMS' $ cField

		If (Inclui .And. M->T9_CATBEM == "2") .Or. (!Inclui .And. cCatOrig <> M->T9_CATBEM .And. M->T9_CATBEM == "2")
			//Se for inclusão só irá validar TMS se for CATBEM == 2 (TMS)
			//Se não for inclusão, e o usuário está mudando a categoria do veículo, só irá validar se CATBEM == 2 (TMS). Se não era TMS e começou a ser integrado
			//fará a validação como se fosse uma inclusão de TMS
			//Dessa forma, se ele era TMS e passou a ser não integrado ao TMS não validará ou já era e continuou sendo, não necessita validação.

			If Empty( M->T9_CODBEM )
				lValid := .F.
				cError := STR0026 //"O código do bem deve ser informardo antes do código do TMS."
			ElseIf .Not. Empty( M->T9_CODTMS) .And. NGIFdbSeek('ST9',M->T9_CODTMS,15)
				lValid := .F.
				cError := STR0027 //"Ja existe Bem com o Codigo do TMS relacionado."
			ElseIf NGIFdbSeek('DA3',M->T9_CODBEM,5)
				lValid := .F.
				cError := STR0028 //"Ja existe TMS com o Codigo do Bem relacionado."
			EndIf

			If lValid
				fLoadTms1( @aTrigger )
			EndIf
		EndIf

	//--------------------------------------------------------------------------
	// T9_PLACA - Placa
	//--------------------------------------------------------------------------
	ElseIf 'T9_PLACA' $ cField

		If .Not. Empty( M->T9_PLACA )
			//TODO: Não permitir informar uma placa de veiculo TMS quando a categoria for 4
			aAreaST9 := ST9->( GetArea() )

			DBSelectArea( 'ST9' )
			DBSetOrder( 1 )
			DBSeek( xFilial('ST9') + M->T9_CODBEM )
			nRecno := ST9->( Recno() )

			DBSelectArea( 'ST9' )
			DBSetOrder( 14 )
			DBSeek( M->T9_PLACA + 'A' )
			If ST9->( Found() ) .And. ( ST9->( Recno() ) != nRecno .Or. Inclui )
				Help(" ",1,"JAGRAVADO",,NGRETTITULO("T9_PLACA"),5,1)
				lValid := .F.
			EndIf

			RestArea( aAreaST9 )

			If lValid .And. M->T9_CATBEM == '2'
				fLoadTMS2( @aTrigger )
			EndIf

		EndIf

		If ALTERA .And. M->T9_PLACA != ST9->T9_PLACA

			MsgAlert( STR0058,; // Ao alterar o conteúdo do campo placa, todo o histórico vinculado a está placa em tabelas relacionadas será afetado.
				STR0059 ) // Atenção

		EndIf

	//--------------------------------------------------------------------------
	// T9_TIPVEI - Tipo Veiculo
	//--------------------------------------------------------------------------
	ElseIf 'T9_TIPVEI' $ cField

		lValid := ExistCpo( 'DUT' , M->T9_TIPVEI )

		If lValid .And. M->T9_CATBEM == '2' .And. .Not. Empty( M->T9_TIPVEI )
			aAdd( aTrigger , { 'DA3' , 'DA3_TIPVEI' , M->T9_TIPVEI }  )
		EndIf

	//--------------------------------------------------------------------------
	// T9_ANOMOD - Ano Modelo
	//--------------------------------------------------------------------------
	ElseIf 'T9_ANOMOD' $ cField

		If M->T9_CATBEM == '2'

			aRet := fValidYear( M->T9_ANOMOD , 'M' )
			lValid	:= aRet[1]
			cError := aRet[2]

			If lValid .And. Val( M->T9_ANOMOD ) > Year( Date() )
				If !MsgYesNo(STR0029+CRLF+STR0030) //"Ano do modelo e maior do que o ano atual" ## "Confirma?"
					Return .F.
				Endif
			Endif

			If lValid
				xContent := M->T9_ANOMOD
			Else
				xContent := Space(Tamsx3('T9_ANOMOD')[1])
			EndIf
			aAdd( aTrigger , { 'DA3' , 'DA3_ANOMOD' , xContent }  )
		Endif

	//--------------------------------------------------------------------------
	// T9_ANOFAB - Ano Fabricação
	//--------------------------------------------------------------------------
	ElseIf 'T9_ANOFAB' $ cField

		aRet	:= fValidYear( M->T9_ANOFAB , 'F' )
		lValid	:= aRet[1]
		cError := aRet[2]

		If M->T9_CATBEM == '2'
			If lValid
				xContent := M->T9_ANOFAB
			Else
				xContent := Space(Tamsx3('DA3_ANOFAB')[1])
			EndIf
			aAdd( aTrigger , { 'DA3' , 'DA3_ANOFAB' , xContent }  )
		EndIf

	//--------------------------------------------------------------------------
	// T9_CHASSI - Chassi
	//--------------------------------------------------------------------------
	ElseIf 'T9_CHASSI' $ cField

		If M->T9_CATBEM == '2'
			aAdd( aTrigger , { 'DA3' , 'DA3_CHASSI' , M->T9_CHASSI }  )
		Endif

	//--------------------------------------------------------------------------
	// TT8_TPCONT - Tipo contador
	//--------------------------------------------------------------------------
	ElseIf 'TT8_TPCONT' $ cField

		If Empty( M->TT8_TPCONT )
		ElseIf .Not. Pertence( '12' , M->TT8_TPCONT )
			lValid := .F.
		Else

			cMenTPC := Space(1)
			If M->T9_TEMCONT == "S" .Or. .Not. Empty( M->TPE_POSCON )
				If M->TT8_TPCONT == "1" .And. M->T9_TEMCONT != "S"
					cMenTPC := "1"
				ElseIf M->TT8_TPCONT == "2" .And. Empty( M->TPE_POSCON )
					cMenTPC := "2"
				EndIf
			ElseIf M->T9_TEMCONT != "S" .And. .Not. Empty( M->TT8_TPCONT )
				cMenTPC := IIf(M->TT8_TPCONT == "1","1", "2")
			EndIf
			If !Empty( cMenTPC ) .And. !aCols[n][Len(aCols[n])]
				cError := STR0031 + Space(1) //"Bem"
				cError += AllTrim( M->T9_CODBEM ) + Space(1)
				cError += STR0032 + Space(1) //"não tem"
				If M->TT8_TPCONT == "1"
					cError += STR0033 //"Contador 1"
				Else
					cError += STR0034 //"Contador 2"
				EndIf
				lValid := .F.
			EndIf

			If lValid .And. lFlagSCnt
				If M->TT8_TPCONT == "2" .And. M->TPE_SITUAC == "2"
					lValid := .F.
					cError := "Não é possível adicionar tanque para o segundo contador pois o mesmo foi desativado."
				EndIf
			EndIf

		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// Apresenta erro
	//--------------------------------------------------------------------------
	If !Empty( cError )
		Help( " ",1,STR0016,,cError,3,1 ) //"NAO CONFORMIDADE"
	EndIf

	//--------------------------------------------------------------------------
	// Executa gatilhos
	//--------------------------------------------------------------------------
	ExecTrigger( aTrigger )

Return lValid

//------------------------------------------------------------------------------
/*/{Protheus.doc} fLoadTms1
Carrega os dados do TMS

@author NG Informática Ltda.
@since 01/01/2015
@version P12
@return Bool
/*/
//------------------------------------------------------------------------------
Static Function fLoadTms1( aTrigger )

	Local nField, cFieldName
	Local aOldArea := GetArea()
	Default aTrigger := {}

	// Se for informado e existir TMS
	If .Not. Empty(M->T9_CODTMS) .And. NGIFDBSEEK('DA3',M->T9_CODTMS,1)
		aAdd( aTrigger , { 'ST9' , 'T9_TIPVEI' 	, DA3->DA3_TIPVEI } )
		aAdd( aTrigger , { 'ST9' , 'T9_ANOMOD' 	, DA3->DA3_ANOMOD } )
		aAdd( aTrigger , { 'ST9' , 'T9_ANOFAB' 	, DA3->DA3_ANOFAB } )
		aAdd( aTrigger , { 'ST9' , 'T9_CHASSI' 	, DA3->DA3_CHASSI } )
		aAdd( aTrigger , { 'ST9' , 'T9_PLACA' 	, DA3->DA3_PLACA  } )
		aAdd( aTrigger , { 'ST9' , 'T9_RENAVAM' , DA3->DA3_RENAVA } )
		aAdd( aTrigger , { 'ST9' , 'T9_CORVEI' 	, DA3->DA3_CORVEI } )
		aAdd( aTrigger , { 'ST9' , 'T9_CIDEMPL' , DA3->DA3_MUNPLA } )
		aAdd( aTrigger , { 'ST9' , 'T9_UFEMPLA' , DA3->DA3_ESTPLA } )
		For nField := 1 To Fcount()
			cFieldName := Fieldname(nField)
			aAdd( aTrigger , { 'DA3' , cFieldName , DA3->(FieldGet(nField)) }  )
		Next
		aAdd( aTrigger , { 'DA3' , 'DA3_DESCMO' , NGSEEK("DA4",DA3->DA3_MOTORI,1,"SubStr(DA4_NOME,1,40)") }  )
		aAdd( aTrigger , { 'DA3' , 'DA3_DESCFO' , NGSEEK("SA2",DA3->DA3_CODFOR+DA3->DA3_LOJFOR,1,"SubStr(A2_NOME,1,40)") }  )
		aAdd( aTrigger , { 'DA3' , 'DA3_DESMAR' , NGSEEK("SX5","M6"+DA3->DA3_MARVEI,1,"SubStr(X5_DESCRI,1,30)") }  )
		aAdd( aTrigger , { 'DA3' , 'DA3_DESCOR' , NGSEEK("SX5","M7"+DA3->DA3_CORVEI,1,"SubStr(X5_DESCRI,1,30)") }  )
		aAdd( aTrigger , { 'DA3' , 'DA3_DESTIP' , NGSEEK("DUT",DA3->DA3_TIPVEI,1,"SubStr(DUT_DESCRI,1,30)") }  )
		aAdd( aTrigger , { 'DA3' , 'DA3_CODBEM' , M->T9_CODBEM }  )
	Else
		aAdd( aTrigger , { 'ST9' , 'T9_TIPVEI' 	, Space( Tamsx3('T9_TIPVEI' )[1])})
		aAdd( aTrigger , { 'ST9' , 'T9_ANOMOD' 	, Space( Tamsx3('T9_ANOMOD' )[1])})
		aAdd( aTrigger , { 'ST9' , 'T9_ANOFAB' 	, Space( Tamsx3('T9_ANOFAB' )[1])})
		aAdd( aTrigger , { 'ST9' , 'T9_CHASSI' 	, Space( Tamsx3('T9_CHASSI' )[1])})
		aAdd( aTrigger , { 'ST9' , 'T9_PLACA' 	, Space( Tamsx3('T9_PLACA'  )[1])})
		aAdd( aTrigger , { 'ST9' , 'T9_RENAVAM' , Space( Tamsx3('T9_RENAVAM')[1])})
		aAdd( aTrigger , { 'ST9' , 'T9_CORVEI' 	, Space( Tamsx3('T9_CORVEI' )[1])})
		aAdd( aTrigger , { 'ST9' , 'T9_CIDEMPL' , Space( Tamsx3('T9_CIDEMPL')[1])})
		aAdd( aTrigger , { 'ST9' , 'T9_UFEMPLA' , Space( Tamsx3('T9_UFEMPLA')[1])})
		aAdd( aTrigger , { 'ST9' , 'T9_DESCOR'  , Space( Tamsx3('T9_DESCOR' )[1])})
		aAdd( aTrigger , { 'ST9' , 'T9_CODTMS'  , Space( Tamsx3('T9_CODTMS' )[1])})
		fUpdateTms( @aTrigger )
		aAdd( aTrigger , { 'DA3' , 'DA3_CODBEM'  , M->T9_CODBEM } )
	Endif
	RestArea(aOldArea)
Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} fLoadTMS2
Carrega os dados do TMS

@author NG Informática Ltda.
@since 01/01/2015
@version P12
@return Bool
/*/
//------------------------------------------------------------------------------
Static Function fLoadTMS2( aTrigger )

	Local nField, cFieldName
	Default aTrigger := {}

	If NGIFDBSEEK( 'DA3' , M->T9_PLACA , 3 )
		M->T9_CODTMS  := DA3->DA3_COD
		M->T9_TIPVEI  := DA3->DA3_TIPVEI
		M->T9_ANOMOD  := DA3->DA3_ANOMOD
		M->T9_ANOFAB  := DA3->DA3_ANOFAB
		M->T9_CHASSI  := DA3->DA3_CHASSI
		M->T9_RENAVAM := DA3->DA3_RENAVA
		aAdd( aTrigger , { 'ST9' , 'T9_CODTMS' 	, DA3->DA3_COD } )
		aAdd( aTrigger , { 'ST9' , 'T9_TIPVEI' 	, DA3->DA3_TIPVEI } )
		aAdd( aTrigger , { 'ST9' , 'T9_ANOMOD' 	, DA3->DA3_ANOMOD } )
		aAdd( aTrigger , { 'ST9' , 'T9_ANOFAB' 	, DA3->DA3_ANOFAB } )
		aAdd( aTrigger , { 'ST9' , 'T9_CHASSI' 	, DA3->DA3_CHASSI } )
		aAdd( aTrigger , { 'ST9' , 'T9_RENAVAM' , DA3->DA3_RENAVA } )
	EndIf

	If .Not. Empty( M->T9_CODTMS ) .And. NGIFDBSEEK('DA3',M->T9_CODTMS+M->T9_PLACA,4)

		For nField := 1 To Fcount()
			cFieldName := Fieldname(nField)
			aAdd( aTrigger , { 'DA3' , cFieldName , DA3->(FieldGet(nField)) }  )
		Next
		aAdd( aTrigger , { 'DA3' , 'DA3_DESCMO' , NGSEEK("DA4",DA3->DA3_MOTORI,1,"SubStr(DA4_NOME,1,40)") }  )
		aAdd( aTrigger , { 'DA3' , 'DA3_DESCFO' , NGSEEK("SA2",DA3->DA3_CODFOR+DA3->DA3_LOJFOR,1,"SubStr(A2_NOME,1,40)") }  )
		aAdd( aTrigger , { 'DA3' , 'DA3_DESMAR' , NGSEEK("SX5","M6"+DA3->DA3_MARVEI,1,"SubStr(X5_DESCRI,1,30)") }  )
		aAdd( aTrigger , { 'DA3' , 'DA3_DESCOR' , NGSEEK("SX5","M7"+DA3->DA3_CORVEI,1,"SubStr(X5_DESCRI,1,30)") }  )
		aAdd( aTrigger , { 'DA3' , 'DA3_DESTIP' , NGSEEK("DUT",DA3->DA3_TIPVEI,1,"SubStr(DUT_DESCRI,1,30)") }  )
	Else
		fUpdateTms( @aTrigger )
	EndIf
	aAdd( aTrigger , { 'DA3' , 'DA3_PLACA'  , M->T9_PLACA } )

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} fUpdateTms
Atualiza o folder do TMS

@author NG Informática Ltda.
@since 01/01/2015
@version P12
@return Bool
/*/
//------------------------------------------------------------------------------
Static Function fUpdateTms( aTrigger )

	Local nField, cFieldName, xContent
	Local aOldArea := GetArea()
	Default aTrigger := {}

	NGSETIFARQUI("DA3","F",1)

	For nField := 1 To Fcount()
		cFieldName := Fieldname(nField)
		If cFieldName == "DA3_FILATU"
			xContent := xFilial("DA3")
		ElseIf cFieldName == "DA3_STATUS"
			xContent := "1"
		Else
			xContent := DA3->(FieldGet(nField))
		EndIf
		aAdd( aTrigger , { 'DA3' , cFieldName , xContent }  )
	Next

	If !NGIFDBSEEK('DA3',M->T9_CODTMS,1)
		aAdd( aTrigger , { 'DA3' , 'DA3_DESCMO' , Space( Tamsx3('DA3_DESCMO')[1]	) }  )
		aAdd( aTrigger , { 'DA3' , 'DA3_DESCFO' , Space( Tamsx3('DA3_DESCFO')[1]	) }  )
		aAdd( aTrigger , { 'DA3' , 'DA3_DESMAR' , Space( Tamsx3('DA3_DESMAR')[1]	) }  )
		aAdd( aTrigger , { 'DA3' , 'DA3_DESCOR' , Space( Tamsx3('DA3_DESCOR')[1]	) }  )
		aAdd( aTrigger , { 'DA3' , 'DA3_DESTIP' , Space( Tamsx3('DA3_DESTIP')[1]	) }  )
		aAdd( aTrigger , { 'DA3' , 'DA3_COD' 	, M->T9_CODTMS }  )
		aAdd( aTrigger , { 'DA3' , 'DA3_PLACA' 	, M->T9_PLACA }  )
		aAdd( aTrigger , { 'DA3' , 'DA3_CODBEM' , M->T9_CODBEM }  )
		aAdd( aTrigger , { 'DA3' , 'DA3_FROVEI' , "1" }  )
		aAdd( aTrigger , { 'DA3' , 'DA3_TIPVEI' , IIF(!Empty(M->DA3_TIPVEI),M->DA3_TIPVEI,M->T9_TIPVEI) }  )
		aAdd( aTrigger , { 'DA3' , 'DA3_ATIVO' 	, "1" }  )
		aAdd( aTrigger , { 'DA3' , 'DA3_FILBAS' , XFilial("ST9") }  )
		aAdd( aTrigger , { 'DA3' , 'DA3_CC' 	, M->T9_CCUSTO }  )
		aAdd( aTrigger , { 'DA3' , 'DA3_CODFOR' , IIF(!Empty(M->DA3_CODFOR),M->DA3_CODFOR,M->T9_FORNECE) }  )
		aAdd( aTrigger , { 'DA3' , 'DA3_LOJFOR' , IIF(!Empty(M->DA3_LOJFOR),M->DA3_LOJFOR,M->T9_LOJA) }  )
		aAdd( aTrigger , { 'DA3' , 'DA3_DESCFO' , IIF(!Empty(M->DA3_DESCFO),M->DA3_DESCFO,M->T9_NOMFORN) }  )
		aAdd( aTrigger , { 'DA3' , 'DA3_DESC'	, M->T9_NOME }  )
		aAdd( aTrigger , { 'DA3' , 'DA3_UNNEG' 	, SubStr(M->T9_CCUSTO,1 ,2) }  )
		aAdd( aTrigger , { 'DA3' , 'DA3_UNREG' 	, SubStr(M->T9_CCUSTO,3 ,3) }  )
		aAdd( aTrigger , { 'DA3' , 'DA3_SEGMER' , SubStr(M->T9_CCUSTO,6 ,3) }  )
		aAdd( aTrigger , { 'DA3' , 'DA3_TIPSER' , SubStr(M->T9_CCUSTO,9 ,3) }  )
		aAdd( aTrigger , { 'DA3' , 'DA3_TIPRER' , SubStr(M->T9_CCUSTO,12,3) }  )
		aAdd( aTrigger , { 'DA3' , 'DA3_RENAVA' , M->T9_RENAVAM }  )
	Endif
	RestArea(aOldArea)

Return .t.

//------------------------------------------------------------------------------
/*/{Protheus.doc} fValidYear
Consistencia do ano

@param cYear   - Ano									- Obrigatorio
		cType  - Tipo (M = Modelo,F = Fabricacao	- Obrigatorio

@author NG Informática Ltda.
@since 01/01/2015
@version P12
@return Array
/*/
//------------------------------------------------------------------------------
Static Function fValidYear( cYear , cType )

	Local cError := ''
	Local nCaracter := 0
	Local aValid := { .T. , Space(1) }

	If Len( AllTrim( cYear ) ) < 4 .And. M->T9_CATBEM == "2"
		cError := STR0035 + Space(1) //"Ano"
		If cType == "M"
			cError += STR0036 //"do modelo"
		Else
			cError += STR0037 //"de fabricacao"
		EndIf
		cError += Space(1) + STR0038 //"invalido"
	Endif

	If Empty( cError ) .And. .Not. Empty( cYear )
		For nCaracter := 1 To Len( cYear )
			If .Not. IsDigit( Substr( cYear , nCaracter , 1 ) )
				cError := STR0035 + Space(1) //"Ano"
				If cType == "M"
					cError += STR0036 //"do modelo"
				Else
					cError += STR0037 //"de fabricacao"
				EndIf
				cError += Space(1) + STR0038 //"invalido"
				Exit
			Endif
		Next
		If Empty( cError ) .And. cType = "F"
			If Val( cYear ) > Year( Date() )
				cError := STR0035 + Space(1) //"Ano"
				If cType == "M"
					cError += STR0036 //"do modelo"
				Else
					cError += STR0037 //"de fabricacao"
				EndIf
				cError += Space(1) + STR0039 //"devera ser menor ou igual ao ano atual"
			Endif
		Endif
	Endif

	If .Not. Empty( cError )
		aValid := { .F. , cError }
	Endif

Return aValid

//------------------------------------------------------------------------------
/*/{Protheus.doc} fTipoFrota
Carrega tela para selecao da Frota

@author NG Informática Ltda.
@since 01/01/2015
@version P12
@return Bool
/*/
//------------------------------------------------------------------------------
Static Function fTipoFrota()

	Local lRet := .F.
	Local oDlg1, oTipoFrota
	Local oFont14  := TFont():New("Arial",8,14,,.t.,,.f.,,.f.,.f.)
	Local cTipoFrota := ''
	Local aTipoFrota := {}

	aAdd( aTipoFrota , STR0040 ) //"Frota não integrada ao TMS"
	aAdd( aTipoFrota , STR0041 ) //"Frota integrada ao TMS"

	DEFINE MSDIALOG oDlg1 Title STR0042; //"Categoria do Veículo"
	FROM 20,0 TO 120,250 Of oMainWnd Pixel

	@ 06,005 Say STR0043 SIZE 280,08 Of oDlg1 Pixel Font oFont14 //"Tipo Frota ?"
	@ 14,005 MSCOMBOBOX oTipoFrota VAR cTipoFrota ITEMS aTipoFrota;
	SIZE 100,12 OF oDlg1 Pixel On CHANGE ()

	@ 30,060 Button STR0044 Of oDlg1 Size 50,12 Pixel; //"Confirmar"
	Action (lRet := .T.,oDLG1:End())

	Activate MsDialog oDLG1 Centered

	If cTipoFrota == aTipoFrota[1]
		cCatFrota := '4'
	ElseIf cTipoFrota == aTipoFrota[2]
		cCatFrota := '2'
	EndIf

Return lRet

//----------------------------------------------------------------
/*/{Protheus.doc} MNT084DCMB
Consiste alteração do combustível relacionado ao tanque do veículo.

@author Juliani Schlickmann Damasceno
@since	16/02/2016

@return lRet
/*/
//----------------------------------------------------------------
Function MNT084DCMB(nOpc)

	Local cError		:= ''
	Local lRet			:= .T.
	Local oGetIdAbast	:= FWMODELACTIVE()

	Local cTipCom		:= FWFldGet('TT8_TIPO')
	Local aArea			:= GetArea()

	If cTipCom == "1"
		// Busca o recno do abastecimento para utilizar o combustivel da base na verificação
		recnoTT8 := oGetIdAbast:GetModel(oGetIdAbast:cId + '_TT8'):GetDataId()
		DBSelectArea( "TT8" )
		dbGoTo(recnoTT8)
		cCombOld := TT8->TT8_CODCOM

		DBSelectArea( 'TQN' )
		DBSetOrder( 1 )
		DBSeek( xFilial( 'TQN' ) + M->T9_CODBEM )
		While .Not. TQN->( Eof() ) .And.;
				TQN->TQN_FILIAL == xFilial( 'TQN' ) .And.;
				TQN->TQN_FROTA == M->T9_CODBEM
			If 	TQN->TQN_CODCOM == AllTrim(cCombOld) .And. AllTrim(FWFldGet('TT8_CODCOM')) <> AllTrim(cCombOld)
				cError := STR0047 // "Não é possível alterar o tanque, pois já existe um abastecimento."
				lRet := .F.
				Exit
			EndIf
			TQN->( dbSkip() )
		End
	ElseIf cTipCom == "2"
		// Busca o recno do insumo da OS para utilizar o produto da base na verificação
		//recnoTT8 := oGetIdAbast:GetModel("MNTA084_TT8"):GetDataId()
		recnoTT8 := oGetIdAbast:GetModel(oGetIdAbast:cId+"_TT8"):GetDataId()
		DBSelectArea( "TT8" )
		dbGoTo(recnoTT8)
		cCombOld := TT8->TT8_CODCOM

		DBSelectArea( 'STL' )
		DBSetOrder( 2 )	// TL_FILIAL+TL_TIPOREG+TL_SEQRELA+TL_CODIGO
		If DBSeek( xFilial( "STL" ) + "P" + "1  " + cCombOld )
			While .Not. STL->( Eof() ) .And. xFilial( "STL" ) + cCombOld == STL->TL_FILIAL + STL->TL_CODIGO
				dbSelectArea( "STJ" )
				dbSetOrder( 1 )	// TJ_FILIAL+TJ_ORDEM+TJ_PLANO+TJ_TIPOOS+TJ_CODBEM
				If dbSeek( xFilial( "STJ" ) + STL->TL_ORDEM + STL->TL_PLANO + "B" + M->T9_CODBEM )
					If STL->TL_CODIGO == cCombOld .And. FWFldGet('TT8_CODCOM') <> cCombOld
						If nOpc == 2
							cError	:= STR0021 // "Não é possível excluir o tanque, pois já existe um abastecimento."
						Else
							cError	:= STR0047 // "Não é possível alterar o tanque, pois já existe um abastecimento."
							lRet	:= .F.
							Exit
						EndIf
					EndIf
				EndIf
				STL->( dbSkip() )
			End
		EndIf
	EndIf

	If .Not. Empty( cError )
		Help( " ",1,STR0016,,cError,3,1 ) //"NAO CONFORMIDADE"
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Funcao de tratamento para o recebimento/envio de mensagem unica de
cadastro de Bens.

@param String cXml: indica conteúdo da mensagem única
@param Integer nTypeTrans: indica tipo de transação
@param String cTypeMessage: indica tipo de mensagem
@param Array aParam: indica parametros passados pela rotina que invocou a integração
aParam[1]: *Integer nRecNo: indica número do registro da ST9 para transferencia
aParam[2]: *Integer nOpc: indica tipo de operação que invocou a integração
aParam[3]: *Boolean lMemory: indica se deve recuperar dados de variaveis de memória ou referenciado pelo Alias
aParam[4]: *Integer nSitStatus: indica status do registro se ativo ou inativo (em caso de exclusão por exemplo)
@author André Felipe Joriatti
@since 11/07/2013
@version P11
@return aArray sendo [1]-.T./.F. e [2] - cError
/*/
//------------------------------------------------------------------------------
Static Function IntegDef( cXML , nTypeTrans , cTypeMessage , cVersionRec )

	Local aRet := {}

	aRet := MNTI080( cXml , nTypeTrans , cTypeMessage )

Return aRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT080TT8
Filtra Lubrificantes ou Combustíveis na TT8.

Nomenclatura MNT080 pois na versão 11 é utilizado no MNTA080.

@return Nil
@sample

@author Rodrigo Luan Backes
@since 08/06/2016
@version 1.0
@return Lógico, Indica se busca ou não a descrição do aditivo.
/*/
//---------------------------------------------------------------------
Function MNT080TT8()
	Local lCONDP	:= .F.
	Local nTipoCom	:= FWFldGet('TT8_TIPO')

	If nTipoCom == '2'

		lCONDP := CONPAD1(NIL,NIL,NIL,"TZZ   ",NIL,NIL,.F.)

		If lCONDP //Se confirmou a consulta
			M->TT8_CODCOM		:= TZZ->TZZ_PRODUT
		EndIf

	Else

		lCONDP := CONPAD1(NIL,NIL,NIL,"TQMCOM",NIL,NIL,.F.)

		If lCONDP //Se confirmou a consulta
			M->TT8_CODCOM		:= TQM->TQM_CODCOM
		EndIf

	EndIf

Return lCONDP

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT080TT8V
Validação do campo TT8_CODCOM conforme Lubrificantes ou Combustíveis.

Nomenclatura MNT080 pois na versão 11 é utilizado no MNTA080.

@return lRet
@sample

@author Rodrigo Luan Backes
@since 08/06/2016
@version 1.0
/*/
//---------------------------------------------------------------------
Function MNT080TT8V()

	Local lRet		:= .T.

	If FWFldGet('TT8_TIPO') == '2'
		If !EXISTCPO('TZZ',M->TT8_CODCOM) .Or. !MNT084DCMB(1)
			lRet := .F.
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT080TT8R
Retorno do filtro de Lubrificantes ou Combustíveis na TT8.

Nomenclatura MNT080 pois na versão 11 é utilizado no MNTA080.

@return cTT8Ret
@sample

@author Rodrigo Luan Backes
@since 08/06/2016
@version 1.0
/*/
//---------------------------------------------------------------------
Function MNT080TT8R()
	Local nTipoCom	:= FWFldGet('TT8_TIPO')
	Local cTT8Ret	:= ""

	If nTipoCom == "2"

		M->TT8_NOMCOM	:= SUBSTR(NGSEEK("TZZ", AllTrim(M->TT8_CODCOM), 1, "TZZ_DESCRI"),1,20)
		cTT8Ret			:= TZZ->TZZ_PRODUT

	Else

		M->TT8_NOMCOM	:= SUBSTR(NGSEEK("TQM", AllTrim(M->TT8_CODCOM), 1, "TQM_NOMCOM"),1,20)
		cTT8Ret			:= TQM->TQM_CODCOM

	EndIf


Return cTT8Ret

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT080TT8G
Retorno do gatilho de Lubrificantes ou Combustíveis na TT8.

Nomenclatura MNT080 pois na versão 11 é utilizado no MNTA080.

@return cTT8Ret
@sample

@author Rodrigo Luan Backes
@since 22/07/2016
@version 1.0
/*/
//---------------------------------------------------------------------
Function MNT080TT8G(nGat)

	Local nTipoCom	:= ""
	Local cTT8Ret	:= ""
	Default nGat	:= 1

	If nGat == 1
		nTipoCom := FWFldGet('TT8_TIPO')
	ElseIf !INCLUI
		nTipoCom := TT8->TT8_TIPO
	EndIf

	If nGat == 1
		If nTipoCom == "2"
			cTT8Ret			:= SUBSTR(NGSEEK("TZZ", AllTrim(M->TT8_CODCOM), 1, "TZZ_DESCRI"),1,20)
		ElseIf nTipoCom == "1"
			cTT8Ret			:= SUBSTR(NGSEEK("TQM", AllTrim(M->TT8_CODCOM), 1, "TQM_NOMCOM"),1,20)
		Else
			cTT8Ret			:= ""
		EndIf
	Else
		If nTipoCom == "2"
			cTT8Ret			:= SUBSTR(NGSEEK("TZZ", AllTrim(TT8->TT8_CODCOM), 1, "TZZ_DESCRI"),1,20)
		ElseIf nTipoCom == "1"
			cTT8Ret			:= SUBSTR(NGSEEK("TQM", AllTrim(TT8->TT8_CODCOM), 1, "TQM_NOMCOM"),1,20)
		Else
			cTT8Ret			:= ""
		EndIf
	EndIf

/*	If INCLUI
		cTT8Ret			:= ""
	EndIf*/

Return cTT8Ret


//------------------------------------------------------------------------------
/*/{Protheus.doc} LineTT8Del
Validação de deleção da linha - Tanque

@author Rodrigo Luan Backes
@since 27/07/2016
@version P12
@return Bool
/*/
//------------------------------------------------------------------------------
Static Function LineTT8Del( oModelGrid , nLinha , cAction )

	Local lValid	:= .T.
	Local cError	:= ''

	Local cCombOld	:= FWFldGet('TT8_CODCOM')
	Local cTipCom	:= FWFldGet('TT8_TIPO')

	If cAction == "DELETE"
		If cTipCom == "2"
			DBSelectArea( 'STL' )
			DBSetOrder( 2 )	// TL_FILIAL+TL_TIPOREG+TL_SEQRELA+TL_CODIGO
			If DBSeek( xFilial( "STL" ) + "P" + "1  " + cCombOld )
				While .Not. STL->( Eof() ) .And. xFilial( "STL" ) + cCombOld == STL->TL_FILIAL + STL->TL_CODIGO
					dbSelectArea( "STJ" )
					dbSetOrder( 1 )	// TJ_FILIAL+TJ_ORDEM+TJ_PLANO+TJ_TIPOOS+TJ_CODBEM
					If dbSeek( xFilial( "STJ" ) + STL->TL_ORDEM + STL->TL_PLANO + "B" + M->T9_CODBEM )
						cError	:= STR0021 // "Não é possível excluir o tanque, pois já existe um abastecimento."
						lValid	:= .F.
						Exit
					EndIf
					STL->( dbSkip() )
				End
			EndIf
		EndIf
	EndIf

	If .Not. Empty( cError )
		Help( " ",1,STR0016,,cError + CRLF ,3,1 ) //"NAO CONFORMIDADE"
	EndIf

Return lValid

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT080TT8T
Retorno dos gatilhos na alteração do campo TT8_TIPO para que zere o
restante dos campos.

@return cTT8Ret
@sample

@author Rodrigo Luan Backes
@since 22/07/2016
@version 1.0
/*/
//---------------------------------------------------------------------
Function MNT080TT8T()

	//Função comentada, pois a princípio não serve ao propósito
	//para a qual foi criada, porém como foi liberada será mantida por hora.
	/*Local nTipoCom	:= GDFieldPos( "TT8_TIPO" )
	Local lRet		:= .F.

	If aCols[n][nTipoCom] != M->TT8_TIPO
		lRet				:= .T.
	EndIf*/

Return .T.// lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ValCancel
Função de validação de quando cancelado o processo.
@type static

@author Guilherme Freudenburg
@since 26/03/2018

@param  oModel, Objeto, Objeto principal da rotina, contem os valores informados.
@return lRet  , Lógico, Retorna a verificação do ponto de entrada.
/*/
//------------------------------------------------------------------------------
Static Function ValCancel( oModel )

	Local lRet := .T.

	RollBackSX8()

	If ExistBlock( 'MNTA084' )
		lRet := ExecBlock( 'MNTA084', .F., .F., {oModel, 'FORMCANCEL', 'MNTA084'} )
	EndIf

Return lRet
