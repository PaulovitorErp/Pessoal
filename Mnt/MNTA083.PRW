#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MNTA083.CH"

Static oST9 := Nil
Static lWhenEst := .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTA083
Cadastro de Pneus

@author NG Informática Ltda.
@since 01/01/2015
@version P12
@return Nil
/*/
//------------------------------------------------------------------------------
Function MNTA083()

	Local aNGBeginPrm := NGBeginPrm()
	Local oBrowse

	// Validation
	Local lValid	:= .T.
	Local cError	:= ''
	Local cSolution := ''
	Local lMNTA0833 := IIf( ExistBlock("MNTA0833"), .T., .F.)

	//Filtro Browse - somente pneus com o status diferente de 'Aguardando marcação de fogo'
	Local cFiltro	:= "ST9->T9_CATBEM == '3'"
	Local cStaFog   := Alltrim( SuperGetMv( 'MV_NGSTAFG', .F., '' ) )

	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 95 )

		// View
		Private cCadastro := STR0001 // "Cadastro de Pneus"
		Private lFrota	  := IIf( GetRPORelease() >= '12.1.033', MNTFrotas(), SuperGetMv( 'MV_NGMNTFR', .F., 'N' ) == 'S' )
		Private nOptRot   := 3

		//Variaveis utilizadas na consulta de OS referente ao bem corrente
		Private TIPOACOM  := IIF(M->T9_TEMCONT <> "N",.T.,.F.)
		Private TIPOACOM2 := IIF(M->TPE_SITUAC <>  2 ,.T.,.F.)
		Private lSITUACA  := .F.

		//--------------------------------------------------------------------------------------------------------------
		// Os pneus com status aguardando marcação de fogo só serão apresentados na rotina mnta086 - classificação
		//--------------------------------------------------------------------------------------------------------------
		If !Empty(cStaFog) .And. TQZ->( FieldPos("TQZ_NUMSEQ") ) > 0
			cFiltro	+= " .And. ST9->T9_STATUS != '" + cStaFog + "'"
		EndIf

		//Initial Validations
		If !lFrota
			lValid    := .F.
			cError    := STR0002 //'Para cadastro de pneus, precisa integração com frotas através do parâmetro MV_NGMNTFR.'
			cSolution := STR0003 //'Acessar o módulo configurador SIGACFG e efetuar a alteração do parâmetro.'
		ElseIf GetNewPar('MV_NGPNEUS','N') <> 'S'
			lValid    := .F.
			cError    := STR0004 //'Para cadastro de pneus, precisa integração com pneus através do parâmetro MV_NGPNEUS.'
			cSolution := STR0005 //'Acessar o módulo configurador SIGACFG e efetuar a alteração do parâmetro.'
		EndIf

		If !NGCADICBASE('T6_CATBEM','A','ST6',.F.)
			lValid    := .F.
			cError    := STR0025 //'Para cadastro de veículos, precisa da ultima release 12.1.7.'
			cSolution := STR0026 //'Atualizar o ambiente.'
		EndIf

		If lValid

			//Caso possua o ponto de entrada 'MNTA0832' ou 'MNTA0831' deverá trocar para o modelo MVC.
			If !FindFunction('U_MNTA083') .And. (FindFunction('U_MNTA0831') .Or. FindFunction('U_MNTA0832'))
				MsgInfo( STR0036, STR0035 ) // 'Os pontos de entrada "MNTA0831" e "MNTA0832" devem ser alterados conforme o novo modelo. Favor pesquisar a ISSUE MNG-6626 para o ponto de entrada "MNTA0831" e a ISSUE MNG-6281 para o ponto de entrada "MNTA0832" no TDN.' ## 'PONTO DE ENTRADA'
			EndIf

			If lMNTA0833
				cFiltro += ExecBlock("MNTA0833",.F.,.F.)
			EndIf

			//Initializes Browse
			oBrowse := FWMBrowse():New()
			oBrowse:SetAlias( 'ST9' )
			oBrowse:SetDescription( cCadastro )
			oBrowse:SetFilterDefault( cFiltro )
			oBrowse:SetMenuDef('MNTA083')
			LegendST9( oBrowse )
			oBrowse:Activate()
		ElseIf !Empty( cError )
			//Show error
			Help( " ",1,STR0006,,cError + CRLF + cSolution,3,1 ) // "NAO CONFORMIDADE"
		EndIf
	EndIf

	NGReturnPrm( aNGBeginPrm )

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

	Local aRotina := {} //FWMVCMenu( "MNTA083" )

	ADD OPTION aRotina Title STR0028 Action 'MNTA080CAD("ST9",ST9->(Recno()),2,"3")' OPERATION 2 ACCESS 0   // 'Visualizar'
	ADD OPTION aRotina Title STR0029 Action 'MNTA080CAD("ST9",,3,"3")'               OPERATION 3 ACCESS 0   // 'Incluir'
	ADD OPTION aRotina Title STR0030 Action 'MNTA080CAD("ST9",ST9->(Recno()),4,"3")' OPERATION 4 ACCESS 0   // 'Alterar'
	ADD OPTION aRotina Title STR0031 Action 'MNTA080CAD("ST9",ST9->(Recno()),5,"3")' OPERATION 5 ACCESS 141 // 'Excluir'
	ADD OPTION aRotina Title STR0007 Action 'MNTA080INA()'                           OPERATION 6 ACCESS 0   //'Inativar'
	ADD OPTION aRotina Title STR0032 Action 'VIEWDEF.MNTA083'                        OPERATION 8 ACCESS 0   // 'Imprimir'
	ADD OPTION aRotina Title STR0033 Action 'MNTA080CAD("ST9",ST9->(Recno()),9,"3")' OPERATION 9 ACCESS 0   // 'Copiar'

	//----------------------------------------------------------------
	// Verifica se o campo TQZ_NUMSEQ existe
	// Verifica se função que abre tela de modelo existe no rpo
	//----------------------------------------------------------------
	If FindFunction( 'MNTA085SI' ) .And.;
		Select('ST9') > 0 .And. TQZ->( FieldPos('TQZ_NUMSEQ') ) > 0

		ADD OPTION aRotina Title 'Inclusão Múltipla' Action 'MNT083MULT()' OPERATION 3 ACCESS 0 //'Inclusão Múltipla' STR0038

	EndIf

	If ExistBlock("MNTA0834")
		aRotina := ExecBlock("MNTA0834",.F.,.F.,{aRotina})
	EndIf

	If Type("__lPyme") == "U" .Or. !__lPyme
		ADD OPTION aRotina Title STR0008 Action 'MsDocument' OPERATION 4 ACCESS 0 //"Conhecimento"
	EndIf

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Data model

@author NG Informática Ltda.
@since 01/01/2015
@version P12
@return oModel
/*/
//------------------------------------------------------------------------------
Static Function ModelDef

	Local oModel
	Local bPreValid	 := {|oModel| PreValida(oModel)	}  // Validação inicial
	Local bPosValid	 := {|oModel| ValidInfo(oModel)	}  // Validação final
	Local bCommit	 := {|oModel| CommitInfo(oModel) } // Gravação do formulario
	Local bCancel    := {|oModel| ValCancel(oModel) } // Bloco de Código para Cancelamento

	// Creates the data model of the object
	oModel := MPFormModel():New('MNTA083',, bPosValid, bCommit, bCancel )

	// Validate model activation
	oModel:SetVldActivate( bPreValid )

	// Adds the description of the Data Model
	oModel:SetDescription( STR0001 ) // "Cadastro de Pneus"

	// Asset
	ModelST9( oModel )

	// Details
	ModelSTB(oModel)

	// Tire
	ModelTQS( oModel )

	// Second Counter
	ModelTPE(oModel)

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelST9
Data Model from ST9

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
	Local oStructAux := FWFormStruct( 1, cAlias ) //Cria a estrutura a ser usada no Modelo de Dados
	Local aPe836     := {}
	Local nIndex     := 0

	//Altera a propriedade dos campos
	oStructAux:SetProperty('T9_CATBEM', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD,'"3"'))

	// O campo T9_TIPMOD não é obrigatório no dicionário, mas torna-se obrigatório para o módulo SIGAGFR
	oStructAux:SetProperty("T9_TIPMOD", MODEL_FIELD_OBRIGAT, .T.)

	//Remove campos de Veiculos
	oStructAux:RemoveField("T9_CODTMS" )
	oStructAux:RemoveField("T9_PLACA"  )
	oStructAux:RemoveField("T9_CAPMAX" )
	oStructAux:RemoveField("T9_MEDIA"  )
	oStructAux:RemoveField("T9_TIPVEI" )
	oStructAux:RemoveField("T9_CHASSI" )
	oStructAux:RemoveField("T9_CORVEI" )
	oStructAux:RemoveField("T9_DESCOR" )
	oStructAux:RemoveField("T9_CIDEMPL")
	oStructAux:RemoveField("T9_UFEMPLA")
	oStructAux:RemoveField("T9_RENAVAM")
	oStructAux:RemoveField("T9_NRMOTOR")
	oStructAux:RemoveField("T9_CEREVEI")
	oStructAux:RemoveField("T9_MEDMIN" )

	//Ponto de entrada para remover campos da tela
	If ExistBlock("MNTA0835")
		ExecBlock("MNTA0835",.F.,.F.,{1,cAlias,oStructAux})
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
	aAdd( aFldNoCopy, 'T9_SITMAN'  )
	aAdd( aFldNoCopy, 'T9_SITBEM'  )
	aAdd( aFldNoCopy, 'T9_DTBAIXA' )
	aAdd( aFldNoCopy, 'T9_MTBAIXA' )
	aAdd( aFldNoCopy, 'T9_COMPRAD' )
	aAdd( aFldNoCopy, 'T9_DTVENDA' )
	aAdd( aFldNoCopy, 'T9_NFVENDA' )

	//Ponto de entrada para determinar campos que não serão copiados
	If ExistBlock("MNTA0836")
		aPe836 := ExecBlock("MNTA0836",.F.,.F.,{'ST9'})

		If ValType( aPe836 ) == 'A'
			For nIndex := 1 To Len( aPe836 )
				If Ascan( aFldNoCopy, aPe836[nIndex] ) == 0
					aAdd( aFldNoCopy, aPe836[nIndex] )
				EndIf
			Next nIndex
		EndIf

	EndIf

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
/*/{Protheus.doc} ModelTQS
Modelo de dados da TQS

@author NG Informática Ltda.
@since 01/01/2015
@version P12
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function ModelTQS( oModel )

	Local oModelAux
	Local aFldNoCopy := {}
	Local aRelation  := {}
	Local cAlias     := 'TQS'
	Local cModelId   := oModel:cId + '_' + cAlias
	Local aPe836     := {}
	Local nIndex     := 0

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStructAux := FWFormStruct( 1, cAlias )

	// Altera para não-obrigatórios os campos do relacionamento
	oStructAux:SetProperty( 'TQS_CODBEM' , MODEL_FIELD_OBRIGAT, .F. )

	//Ponto de entrada para remover campos da tela
	If ExistBlock("MNTA0835")
		ExecBlock("MNTA0835",.F.,.F.,{1,cAlias,oStructAux})
	EndIf

	// Define relacionamento entre ST9 e STB
	aAdd( aRelation , { 'TQS_FILIAL' , 'xFilial( "TQS" )' } )
	aAdd( aRelation , { 'TQS_CODBEM' , 'T9_CODBEM' } )

	// Define campos que não podem ser copiados
	aAdd( aFldNoCopy, 'TQS_PLACA' )
	aAdd( aFldNoCopy, 'TQS_POSIC' )
	aAdd( aFldNoCopy, 'TQS_KMOR' )
	aAdd( aFldNoCopy, 'TQS_KMR1' )
	aAdd( aFldNoCopy, 'TQS_KMR2' )
	aAdd( aFldNoCopy, 'TQS_KMR3' )
	aAdd( aFldNoCopy, 'TQS_KMR4' )
	aAdd( aFldNoCopy, 'TQS_BANDAA' )

	//Ponto de entrada para determinar campos que não serão copiados
	If ExistBlock("MNTA0836")
		aPe836 := ExecBlock("MNTA0836",.F.,.F.,{'TQS'})

		If ValType( aPe836 ) == 'A'
			For nIndex := 1 To Len( aPe836 )
				If Ascan( aFldNoCopy, aPe836[nIndex] ) == 0
					aAdd( aFldNoCopy, aPe836[nIndex] )
				EndIf
			Next nIndex
		EndIf
	EndIf

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( cModelId , oModel:cId + '_ST9' , oStructAux )

	oModelAux := oModel:GetModel( cModelId )

	oModelAux:SetFldNoCopy( aFldNoCopy )

	// Faz relaciomaneto entre os compomentes do model
	oModelAux:SetRelation( aRelation , ( cAlias )->( IndexKey( 1 ) ) )

	// Adiciona a descricao do Componente do Modelo de Dados
	oModelAux:SetDescription( NgSX2Nome( cAlias ) )

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

	Local oView, aWhenBtn
	Local oModel := FWLoadModel( 'MNTA083' )

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	// Cria Box na view
	oView:CreateHorizontalBox( 'MAIN', 100 )

	// Cria Folder na view
	oView:CreateFolder( 'MAIN_FOLDER' , 'MAIN' )

	// Asset
	ViewST9( oView , oModel )

	// Details
	ViewSTB( oView , oModel )

	// Tire
	ViewTQS( oView , oModel )

	// Counter
	ViewCounter( oView , oModel )

	// Complementos
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

	Local cAlias := 'ST9'

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStructAux := FWFormStruct( 2 , cAlias )

	oStructAux:SetProperty( 'T9_CODBEM'	, MVC_VIEW_TITULO , STR0009 ) // 'Pneu'
	oStructAux:SetProperty( 'T9_NOME'	, MVC_VIEW_TITULO , STR0010 ) // 'Nome Pneu'

	oStructAux:RemoveField("T9_CODTMS")
	oStructAux:RemoveField("T9_PLACA")
	oStructAux:RemoveField("T9_CAPMAX")
	oStructAux:RemoveField("T9_MEDIA")
	oStructAux:RemoveField("T9_TIPVEI")
	oStructAux:RemoveField("T9_CHASSI")
	oStructAux:RemoveField("T9_CORVEI")
	oStructAux:RemoveField("T9_DESCOR")
	oStructAux:RemoveField("T9_CIDEMPL")
	oStructAux:RemoveField("T9_UFEMPLA")
	oStructAux:RemoveField("T9_RENAVAM")
	oStructAux:RemoveField("T9_NRMOTOR")
	oStructAux:RemoveField("T9_CEREVEI")
	oStructAux:RemoveField("T9_MEDMIN")
	oStructAux:RemoveField("T9_CATBEM")

	//Ponto de entrada para remover campos da tela
	If ExistBlock("MNTA0835")
		ExecBlock("MNTA0835",.F.,.F.,{2,cAlias,oStructAux})
	EndIf

	// Remove todos os campos do agrupamento de contador
	FilterField( oStructAux , '004' , .T. )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_' + cAlias , oStructAux , oModel:cId + '_' + cAlias )

	// Cria pastas nas folders
	oView:AddSheet( 'MAIN_FOLDER', 'ABA_' + cAlias , STR0011 ) //'Bem'

	// Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'BOX_' + cAlias , 100,,, 'MAIN_FOLDER', 'ABA_' + cAlias )

	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_' + cAlias , 'BOX_' + cAlias )

	SetKey(VK_F4, {|| fShowSB2() })

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} fShowSB2
Consulta de estoque

@author NG Informática Ltda.
@since 01/01/2015
@version P12
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function fShowSB2()

	Local oView := FwViewActive()

	If ValType( oView ) == 'O' .And. oView:GetFolderActive( "MAIN_FOLDER" , 2 )[2] == STR0011
		MntViewSB2( 'P' , M->T9_CODESTO )
	EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewTQS
View from TQS

@author NG Informática Ltda.
@since 01/01/2015
@version P12
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function ViewTQS( oView , oModel )

	Local cAlias := 'TQS'

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStructAux := FWFormStruct( 2 , cAlias )

	oStructAux:RemoveField("TQS_CODBEM")
	oStructAux:RemoveField("TQS_DESBEM")

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_' + cAlias , oStructAux , oModel:cId + '_' + cAlias )

	// Cria pastas nas folde
	oView:AddSheet( 'MAIN_FOLDER', 'ABA_' + cAlias , STR0009 ) //'Pneu'

	// Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'BOX_' + cAlias , 100,,, 'MAIN_FOLDER', 'ABA_' + cAlias )

	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_' + cAlias , 'BOX_' + cAlias )

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreValida
Pre validação para abertura do cadastro

@author NG Informática Ltda.
@since 01/01/2015
@version P12
@return Bool
/*/
//------------------------------------------------------------------------------
Static Function PreValida( oModel )

	lWhenEst := .T.

	//Indica que controla hist. do estoque dos pneus
	If oModel:GetOperation() == 4

		cQryAlias := GetNextAlias()
		cQuery := " SELECT COUNT(*) AS TOTAL FROM " + RetSqlName("TQZ")
		cQuery += " WHERE  TQZ_CODBEM = '" + ST9->T9_CODBEM + "' "
		cQuery += " AND TQZ_PRODUT <> ' ' "
		cQuery += " AND TQZ_ALMOX <> ' ' "
		cQuery += " AND D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cQryAlias, .F., .T.)
		dbSelectArea(cQryAlias)
		If (cQryAlias)->TOTAL > 1
			lWhenEst := .F.
		EndIf
		(cQryAlias)->(dbCloseArea())
	EndIf

Return .T.

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
	oST9 := MntPneu():New

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
Static Function CommitInfo(oModel)

	Local lAltLin    := .F.
	Local lMnt083   := ExistBlock("MNTA083")
	Local nX         := 0
	Local nLenSub    := Len(oModel:AallSubModels) //Verificar se possui SubModelos.

	If nLenSub > 0 .And. lMnt083//Caso possua Sub-Modelos
		For nX := 1 To nLenSub //Percorre todos.
			If oModel:AallSubModels[nX]:cId == 'MNTA083_STB'  //Verifica os modelos que possuem grid.
				If Len(oModel:AallSubModels[nX]:GetLinesChanged()) > 0 //Caso possua alguma linha alterada.
					lAltLin := .T.
					Exit
				EndIf
			EndIf
		Next nX
	EndIf

	If lMnt083
		ExecBlock("MNTA083",.F.,.F.,{oModel,'FORMCOMMITTTSPRE','MNTA083',lAltLin})
	EndIf

	Do Case
		Case oST9:IsUpsert() //Upsert - Executa inclusão ou alteração do cadastro

			If oST9:Upsert() .And. oST9:IsInsert()
				ConfirmSX8()
			EndIf

		Case oST9:IsDelete() // Delete - Executa exclusão do cadastro
			oST9:Delete()
	Endcase

	If lMnt083
		ExecBlock("MNTA083",.F.,.F.,{oST9,'MODELCOMMITTTS','MNTA083'})
	EndIf

	// Se houver, apresenta erro
	oST9:ShowHelp()

	If lMnt083
		ExecBlock("MNTA083",.F.,.F.,{oModel,'FORMCOMMITTTSPOS','MNTA083',lAltLin})
	EndIf

	//Ponto de entrada executado após gravações
	If lMnt083
		ExecBlock("MNTA083",.F.,.F.,{oST9,'MODELCOMMITNTTS','MNTA083'})
	EndIf

	// Limpa classe
	oST9:Free()

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNT083WHEN
Define modo de edição de Campos

@author NG Informática Ltda.
@since 01/01/2015
@version P12
@return lOpenField - Indica se campo ficará aberto
/*/
//------------------------------------------------------------------------------
Function MNT083WHEN( cField )

	Local lOpenField := .T.
	Local lTemRI := .F.
	Local nCharIni, nCharEnd
	Local cAliasQry := ''

	Default cField := ReadVar()

	//--------------------------------------------------------------------------
	// Tratamento do nome de campo
	//--------------------------------------------------------------------------
	If '>' $ cField
		nCharIni	:= At( '>' , cField ) + 1
		nCharEnd	:= Len( cField )
		cField		:= SubStr( cField , nCharIni , nCharEnd )
		cField		:= Upper( cField )
		cField		:= Trim( cField )
	EndIf

	//--------------------------------------------------------------------------
	// TQS_EIXO/TQS_TIPEIX/TQS_PLACA/TQS_POSIC
	//--------------------------------------------------------------------------
	If cField $ "TQS_EIXO/TQS_TIPEIX/TQS_PLACA/TQS_POSIC"

		If .Not. Empty( M->T9_STATUS )
			lTemRI := ( GetNewPar('MV_NGSTARI','') == M->T9_STATUS )
		EndIf

		lOpenField :=  ( lTemRI .Or. ( M->T9_STATUS == GetNewPar('MV_NGSTAPL') .And. ( Inclui .Or. IsInCallStack( 'MNTA086' ) ) ) .Or.;
						Empty(M->T9_STATUS) .Or. IsInCallStack( 'Commit087' ) )

	//--------------------------------------------------------------------------
	// TQS_DTMEAT/TQS_HRMEAT/TQS_BANDAA
	//--------------------------------------------------------------------------
	ElseIf cField $ "TQS_DTMEAT/TQS_HRMEAT/TQS_BANDAA"

		If Altera .And.;
			!IsInCallStack('MNTA086') .And. ; // classificação de pneus
			( Empty( M->T9_STATUS ) .Or. GetNewPar('MV_NGSTARI','') != M->T9_STATUS )
			lOpenField := .F.
		EndIf

	//--------------------------------------------------------------------------
	// TQS_SULCAT - Sulco
	//--------------------------------------------------------------------------
	ElseIf cField $ "TQS_SULCAT"

		If !Inclui
		
			cAliasQry := getNextAlias()
			
			BeginSql Alias cAliasQry
				SELECT COUNT(TQV_CODBEM) TOTAL FROM %Table:TQV% TQV
					WHERE TQV.TQV_FILIAL = %xFilial:TQV% AND
					TQV.TQV_CODBEM = %exp:M->TQS_CODBEM% AND
					TQV.%NotDel%
			EndSql

			If (cAliasQry)->(TOTAL) > 1
				lOpenField := .F.
			EndIF

			(cAliasQry)->(dbCloseArea())

		EndIf

	//--------------------------------------------------------------------------
	// TQS_DESENH - Desenho
	//--------------------------------------------------------------------------
	ElseIf cField $ "TQS_DESENH"

		lOpenField := ( M->TQS_BANDAA > '1' )

	//--------------------------------------------------------------------------
	// TQS_KMOR - Banda Original
	//--------------------------------------------------------------------------
	ElseIf cField $ "TQS_KMOR"

		lOpenField := ( .Not. Empty( M->TQS_BANDAA ) )

	//--------------------------------------------------------------------------
	// TQS_KMR1 - Banda 2
	//--------------------------------------------------------------------------
	ElseIf cField $ "TQS_KMR1

		lOpenField := ( M->TQS_BANDAA > '1' )

	//--------------------------------------------------------------------------
	// TQS_KMR2 - Banda 3
	//--------------------------------------------------------------------------
	ElseIf cField $ "TQS_KMR2"

		lOpenField := ( M->TQS_BANDAA > '2' )

	//--------------------------------------------------------------------------
	// TQS_KMR3 - Banda 4
	//--------------------------------------------------------------------------
	ElseIf cField $ "TQS_KMR3"

		lOpenField := ( M->TQS_BANDAA > '3' )

	//--------------------------------------------------------------------------
	// TQS_KMR4 - Banda 5
	//--------------------------------------------------------------------------
	ElseIf cField $ "TQS_KMR4"

		lOpenField := ( M->TQS_BANDAA > '4' )

	//--------------------------------------------------------------------------
	// Campos de estoque
	//--------------------------------------------------------------------------
	ElseIf cField $ "T9_CODESTO/T9_LOCPAD"

		lOpenField := lWhenEst

		cStatusTire := GetNewPar("MV_NGSTAEU")
		cStatusTire += "/" + GetNewPar("MV_NGSTAER")
		cStatusTire += "/" + GetNewPar("MV_NGSTARS")
		cStatusTire += "/" + GetNewPar("MV_NGSTAEN")
		cStatusTire += "/" + GetNewPar("MV_NGSTEST")

		If IsIncallStack( 'MNTA085' ) // Gera pneus a partir de NF
			cStatusTire += "/" + Alltrim( SuperGetMv( 'MV_NGSTAFG', .F., '' ) )
		EndIf

		If lOpenField .And. M->T9_CATBEM == '3' .And. .Not. Empty( M->T9_STATUS )

			If GetNewPar("MV_NGMNTES","N") == 'S' .And.;
			GetNewPar("MV_NGPNEST","N") == 'S' .And.;
			.Not. ( M->T9_STATUS $ cStatusTire )

				lOpenField := .F.
			ElseIf M->T9_STATUS $ GetNewPar("MV_NGSTAPL")
				lOpenField := .F.
			EndIf
		EndIf
	EndIf

Return lOpenField

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTA083VLD
Field Validation

@author NG Informática Ltda.
@since 01/01/2015
@version P12
@return Bool
/*/
//------------------------------------------------------------------------------
Function MNTA083VLD( cField )

	// Return variables
	Local lValid := .T.
	Local cError := ''
	Local aArea  := {}
	Local aTrigger := {}

	// Campo a ser validado
	Default cField := ReadVar()

	//--------------------------------------------------------------------------
	// Tratamento do nome de campo
	//--------------------------------------------------------------------------
	If '>' $ cField
		nCharIni	:= At( '>' , cField ) + 1
		nCharEnd	:= Len( cField )
		cField		:= SubStr( cField , nCharIni , nCharEnd )
		cField		:= Upper( cField )
		cField		:= Trim( cField )
	EndIf

	//--------------------------------------------------------------------------
	// T9_CODESTO - Stock
	//--------------------------------------------------------------------------
	If 'T9_CODESTO' $ cField

		If .Not. Empty( M->T9_CODESTO )
			lValid := ExistCpo( 'SB1' , M->T9_CODESTO )
		EndIf

	//--------------------------------------------------------------------------
	// T9_LOCPAD - WareHouse
	//--------------------------------------------------------------------------
	ElseIf 'T9_LOCPAD' $ cField

		If !Empty( M->T9_LOCPAD ) .And. !ExistCpo( 'NNR' , M->T9_LOCPAD )
			lValid := .F.
		EndIf

	//--------------------------------------------------------------------------
	// TQS_DTMEAT - Data Sulco Atual
	//--------------------------------------------------------------------------
	ElseIf 'TQS_DTMEAT' $ cField

		lValid := VALDT( M->TQS_DTMEAT )

		If dDataBase == M->TQS_DTMEAT .And. SubStr(Time(),1,5) < M->TQS_HRMEAT
			aAdd( aTrigger , { 'TQS' , 'TQS_HRMEAT' , '  :  ' }  )
		EndIf

	//--------------------------------------------------------------------------
	// TQS_HRMEAT - Hora Medição Sulco
	//--------------------------------------------------------------------------
	ElseIf 'TQS_HRMEAT' $ cField

		If .Not. NGVALHORA(M->TQS_HRMEAT,.T.)
			lValid := .F.
		ElseIf dDataBase == M->TQS_DTMEAT .And. SubStr(Time(),1,5) < M->TQS_HRMEAT
			cError := STR0016 //"Hora informada deverá ser menor que a hora atual!"
			lValid := .F.
		EndIf

	//--------------------------------------------------------------------------
	// TQS_BANDAA - Banda do Pneu
	//--------------------------------------------------------------------------
	ElseIf 'TQS_BANDAA' $ cField

		If Altera .And. M->TQS_BANDAA < TQS->TQS_BANDAA
			cError := STR0017 + Space(1) //"Banda deverá ser maior do que a"
			cError += STR0018 + CRLF //"Banda atual"
			cError += STR0018 + "..: " //"Banda atual"
			cError += NGRETSX3BOX("TQS_BANDAA",TQS->TQS_BANDAA)
			lValid := .F.
		EndIf

	//--------------------------------------------------------------------------
	// TQS_PLACA - Placa do Veiculo Pai
	//--------------------------------------------------------------------------
	ElseIf 'TQS_PLACA' $ cField

		If !Empty(M->TQS_PLACA)

			dbSelectArea( 'ST9' )
			dbSetOrder( 14 )
			dbSeek( M->TQS_PLACA + 'A' )
			If .Not. Found()
				lValid := .F.
				cError := STR0019 //"Placa informada não existe no cadastro de Bens."
			ElseIf ST9->T9_FILIAL <> xFilial("ST9")
				lValid := .F.
				cError := STR0027 //"Não é possível aplicar o pneu em um veículo de outra filial."
			EndIf

			If lValid .And. !Empty( M->TQS_POSIC )
				cError := AlExists( M->TQS_PLACA, M->TQS_POSIC )
				lValid := Empty( cError )
			EndIf

			If lValid .And. M->T9_TEMCONT == 'P'
				aAdd( aTrigger , { 'ST9' , 'T9_POSCONT' , ST9->T9_POSCONT }  )
			EndIf

			NGDBAREAORDE("ST9",1)
		EndIf

	//--------------------------------------------------------------------------
	// TQS_DOT - Data de Fabricação
	//--------------------------------------------------------------------------
	ElseIf 'TQS_DOT' $ cField

		If !Empty(M->TQS_DOT)
			cSemFab := Left(M->TQS_DOT,2) //semana de fabricacao
			dAnoFab := CToD("01/01/"+Right(M->TQS_DOT,2)) //ano de fabricacao
			cSemCor := StrZero(NGSEMANANO(dDataBase),2) //semana corrente
			dAnoCor := CToD("01/01/"+Right(cValToChar(YEAR(dDataBase)),2))  //ano corrente

			cDotM := AllTrim( M->TQS_DOT )
			If Len( cDotM ) < Len( M->TQS_DOT )
				lValid := .F.
				cError := STR0020 + Space(1) //"Não foi preenchito corretamente o campo"
				cError += NGRETTITULO("TQS_DOT")
			EndIf

			If lValid .And. !NGSOCARACTER(cSemFab,"D",.F.)[1]
				lValid := .F.
				cError := STR0021 //"Semana de fabricação é invalida."

			EndIf

			cAnoCor := Right( cDotM , 2 )
			If lValid .And. !NGSOCARACTER(cAnoCor,"D",.F.)[1]
				lValid := .F.
				cError := STR0022 //"Ano de fabricação inválido."
			EndIf

			If lValid .And. Val(cSemFab) > 0 .AnD. Val(cSemFab) <= 53 //total de semanas por ano (365/7)
				If dAnoFab == dAnoCor
					If cSemFab > cSemCor
						lValid := .F.
						cError := STR0023 //"Semana de fabricação "
						cError += "(" + cSemFab + ")" + Space(1)
						cError += STR0024 + Space(1) //"deve ser igual ou menor à semana corrente"
						cError += "(" + cSemCor + ")."
					EndIf
				ElseIf dAnoFab > dAnoCor
					lValid := .F.
					cError := STR0012 //"Ano de fabricação deve ser igual ou menor ao ano corrente."
				EndIf
			ElseIf lValid
				lValid := .F.
				If Val( cSemFab ) > 52
					cError := STR0013 //"Semana de fabricação ultrapassa o limite de semanas por ano."
				Else
					cError := STR0014 //"Semana de fabricação inválida."
				EndIf
			EndIf
		EndIf

	//--------------------------------------------------------------------------
	// TQS_POSIC - Posição Pneu
	//--------------------------------------------------------------------------
	ElseIf 'TQS_POSIC' $ cField

		If !ExistCpo('TPS',M->TQS_POSIC) .Or. !MNTA083TPS(.F.)
			lValid := .F.
		Else
			aArea := GetArea()
			dbSelectArea( 'ST9' )
			dbSetOrder( 14 )
			If !Empty(M->TQS_PLACA) .And.;
				ST9->( dbSeek( M->TQS_PLACA + 'A' ) ) .And.;
				NGIFdbSeek('STC',ST9->T9_CODBEM+ST9->T9_TIPMOD+"B"+M->TQS_POSIC,6) .And.;
				M->TQS_CODBEM <> STC->TC_COMPONE
				lValid := .F.
				cError := STR0015 //"Localização já existe."
			EndIf
			If lValid
				cError := AlExists( M->TQS_PLACA, M->TQS_POSIC )
				lValid := Empty( cError )
			EndIf
			dbSelectArea('ST9')
			dbSetOrder(1)
			RestArea(aArea)

		EndIf

	//--------------------------------------------------------------------------
	// TQS_KMOR - Km Percor Or
	//--------------------------------------------------------------------------
	ElseIf 'TQS_KMOR' $ cField

		lValid := Positivo()

	//--------------------------------------------------------------------------
	// TQS_KMR1 - Km Banda R1
	//--------------------------------------------------------------------------
	ElseIf 'TQS_KMR1' $ cField

		lValid := Positivo()

	//--------------------------------------------------------------------------
	// TQS_KMR2 - Km Banda R2
	//--------------------------------------------------------------------------
	ElseIf 'TQS_KMR2' $ cField

		lValid := Positivo()

	//--------------------------------------------------------------------------
	// TQS_KMR3 - Km Banda R3
	//--------------------------------------------------------------------------
	ElseIf 'TQS_KMR3' $ cField
	
		lValid := Positivo()

	//--------------------------------------------------------------------------
	// TQS_KMR4 - Km Banda R4
	//--------------------------------------------------------------------------
	ElseIf 'TQS_KMR4' $ cField

		lValid := Positivo()

	//--------------------------------------------------------------------------
	// TQS_SULCAT - Sulco Atual
	//--------------------------------------------------------------------------
	ElseIf 'TQS_SULCAT' $ cField

		lValid := Positivo()

	EndIf

	//--------------------------------------------------------------------------
	// Show error
	//--------------------------------------------------------------------------
	If .Not. Empty( cError )
		Help( " ",1,STR0006,,cError,3,1 )//"NAO CONFORMIDADE"
	EndIf

	//--------------------------------------------------------------------------
	// Run trigger
	//--------------------------------------------------------------------------
	ExecTrigger( aTrigger )

	If lValid
		ExecTrig( cField )
	EndIf

Return lValid

//---------------------------------------------------------------------------
/*/{Protheus.doc} MNTA083TPS
Cria o filtro para a consulta padrão TPSEST

@param	lWhVld	, Lógico, Verifica se a validação é para filtro de conpad ou valid
@return lRet 	, Lógico, .T. para execução do filtro na consulta padrão TTMCC.

@sample MNTA083TPS()
@author Alexandre Santos
@since 24/11/2017
/*/
//---------------------------------------------------------------------------
Function MNTA083TPS(lFilVld)

	Local cFilter	:= ""
	Local cCodFam	:= ""
	Local cCodMod	:= ""
	Local nX		:= 0
	Local lRet		:= .F.

	Default lFilVld 	:= .F.

	If !Empty(M->TQS_PLACA)

		dbSelectArea("ST9")
		dbSetOrder(14)
		If dbSeek(M->TQS_PLACA)
			cCodFam := ST9->T9_CODFAMI
			cCodMod := ST9->T9_TIPMOD

			dbSelectArea("TQ1")
			dbSetOrder(1)
			dbSeek(xFilial("TQ1") + cCodFam + cCodMod)
			While !Eof() .And. xFilial("TQ1") + cCodFam + cCodMod == TQ1->TQ1_FILIAL + TQ1->TQ1_DESENH + TQ1->TQ1_TIPMOD

				cFilter := ""

				For nX:= 1 to TQ1->TQ1_QTDPNE
					If lFilVld //Filtro CONPAD
						If nX == TQ1->TQ1_QTDPNE
							cFilter += "TPS->TPS_CODLOC == TQ1->TQ1_LOCPN" + AllTrim(Str(nX))
						Else
							cFilter += "TPS->TPS_CODLOC == TQ1->TQ1_LOCPN" + AllTrim(Str(nX)) + " .Or. "
						EndIf
					Else //Valid
						If nX == TQ1->TQ1_QTDPNE
							cFilter += "M->TQS_POSIC == TQ1->TQ1_LOCPN" + AllTrim(Str(nX))
						Else
							cFilter += "M->TQS_POSIC == TQ1->TQ1_LOCPN" + AllTrim(Str(nX)) + " .Or. "
						EndIf
					EndIf
				Next

				If &(cFilter)
					lRet := .T.
					Exit
				EndIf

				TQ1->(dbSkip())
			End

			If !lRet
				Help('',1,STR0006,,STR0034,1,0) //NAO CONFORMIDADE
			EndIf
		EndIf
	EndIf

Return lRet

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

	If ExistBlock( 'MNTA083' )
		lRet := ExecBlock( 'MNTA083', .F., .F., {oModel, 'FORMCANCEL', 'MNTA083'} )
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AlExists
Verifica a existencia de um pneu na posição

@type static
@author Maria Elisandra de Paula
@since 03/10/20

@param cPlate, string, placa do veículo
@return cError , string, descrição do erro
/*/
//------------------------------------------------------------------------------
Static Function AlExists( cPlate, cPosition )

	Local cError    := ''
	Local cAliasQry := GetNextAlias()
	Local cStFire   := Alltrim( SuperGetMv( 'MV_NGSTAFG', .F., '' ) )

	BeginSQL Alias cAliasQry

		SELECT TQS.TQS_CODBEM
		FROM %table:TQS% TQS
		JOIN %table:ST9% ST9
			ON ST9.T9_CODBEM = TQS.TQS_CODBEM
			AND ST9.T9_STATUS = %exp:cStFire%
			AND ST9.T9_CATBEM = '3'
			AND ST9.T9_FILIAL = %xFilial:ST9%
			AND ST9.%NotDel%
		WHERE TQS.TQS_FILIAL = %xFilial:TQS%
			AND TQS.%NotDel%
			AND TQS_POSIC = %exp:cPosition%
			AND TQS_PLACA = %exp:cPlate%
	EndSQL

	If !(cAliasQry)->( Eof() )
		cError += STR0037 + ': ' + Alltrim((cAliasQry)->TQS_CODBEM) // 'Já existe um pneu aplicado na posição e placa informados'
	EndIf

	(cAliasQry)->( dbCloseArea() )

Return cError

//---------------------------------------------------------------------------------
/*/{Protheus.doc} MNT083MULT
Gera múltiplos pneus

@author Maria Elisandra de Paula
@since 03/12/2020
@return Nil
/*/
//---------------------------------------------------------------------------------
Function MNT083MULT()

	Local cSimilar := Space( TamSx3('T9_CODBEM')[1] )
    Local cName    := Space( TamSx3('T9_NOME')[1] )
	Local nAmount  := 0
	Local oDlg
	Local oAmount
    Local oSimilar
    Local oName

	//--------------------------------------------------------------------------------------------
	// Trecho abaixo apresenta tela para usuário informar quantidade de pneus e um pneu similar
	//--------------------------------------------------------------------------------------------
	oDlg := FWDialogModal():New()
		oDlg:SetBackground( .T. )	 // .T. -> Escurece o fundo da janela
		oDlg:SetTitle( STR0038 ) 	//'Inclusão Múltipla'
		oDlg:SetEscClose( .F. )		//Permite fechar a tela com o ESC
		oDlg:SetSize( 100, 425 ) 	//Cria a tela maximizada (chamar sempre antes do CreateDialog)
		oDlg:EnableFormBar( .T. )

		oDlg:CreateDialog() //cria a janela (cria os paineis)
		oPanel := oDlg:getPanelMain()

		oDlg:createFormBar()//cria barra de botoes

		@ 10,05 Say STR0039 Of oPanel Pixel //'Quantidade'
		@ 18,05 MSget oAmount Var nAmount Picture '999999' size 30,12 Of oPanel Pixel

		@ 10,55 Say STR0040 Of oPanel Pixel //'Pneu Similar'
		@ 18,55 MSget oSimilar Var cSimilar Picture '@!' SIZE 120,12 VALID VldSimMult( nAmount, cSimilar, @cName ) F3 'PNEUSI' Of oPanel Pixel HasButton

        @ 10,205 Say STR0010 Of oPanel Pixel //Nome Pneu
		@ 18,205 MsGet oName Var cName Picture '@!' size 180,12 When .F. Of oPanel Pixel

		oDlg:AddButton( STR0041	,{|| IIf( VldOkMult( nAmount ) .And.; //'Confirmar'
										CreateTire( cSimilar, nAmount ), oDlg:Deactivate(), ) } , STR0041, , .T., .F., .T., ) //'Confirmar'
		oDlg:AddButton( STR0042,{|| oDlg:Deactivate() }, STR0042, , .T., .F., .T., ) //'Sair'

		oDlg:SetInitBlock( {|| oAmount:SetFocus() } )

	oDlg:Activate()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} VldSimMult
Validações do campo similar da rotina inclusão multipla

@param nAmount, numerico, valor do campo quantidade
@param cSimilar, string, valor do campo similar
@param cName, string, nome do pneu
@author Maria Elisandra de Paula
@since 27/11/2020
@return boolean
/*/
//---------------------------------------------------------------------
Static Function VldSimMult( nAmount, cSimilar, cName )

	Local lRet := .T.

	If !Empty( cSimilar )
		lRet := ExistCpo( 'ST9', cSimilar )

		If lRet

			cName := NGSEEK('ST9', cSimilar, 1, 'T9_NOME')

			If NGSEEK('ST9',cSimilar,1,'T9_CATBEM') != '3'

				lRet := .F.
				Help( '', 1, STR0006 ,, STR0043 ,3,1 ) //'Não Conformidade'/'O bem informado não é um pneu.'

			EndIf
		
		EndIf

	EndIf


Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} VldOkMult
Validações ao confirmar primeira tela de inclusão multipla

@param nAmount, numerico, valor do campo quantidade
@author Maria Elisandra de Paula
@since 21/12/2020
@return boolean
/*/
//---------------------------------------------------------------------
Static Function VldOkMult( nAmount )

    Local lRet := .T.

    If nAmount <= 0

		Help( '', 1, STR0006,, STR0044,3,1 ) //'Não Conformidade'/'Informe a quantidade de pneus a gerar.'
		lRet := .F.

    EndIf

Return lRet


//---------------------------------------------------------------------
/*/{Protheus.doc} CreateTire
Aciona tela de pneus para rotina inclusão multipla com régua progresso

@param cSimilar, string, valor do campo similar
@param nAmount, numerico, quantidade de pneus a gerar
@author Maria Elisandra de Paula
@since 11/12/2020
@return boolean
/*/
//---------------------------------------------------------------------
Static Function CreateTire( cSimilar, nAmount )

	Local lRet := .T.

	FWMsgRun(  , {|| lRet := CreateMult( cSimilar, nAmount ) }, STR0045, STR0046 ) //'Aguarde'/'Processando Dados...'

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} CreateMult
Aciona tela de pneus para rotina inclusão múltipla

@param cSimilar, string, código do pneu similar
@param nAmount, numérico, quantidade de pneus a gerar
@author Maria Elisandra de Paula
@since 27/11/2020
@return boolean
/*/
//---------------------------------------------------------------------
Static Function CreateMult( cSimilar, nAmount )

    Local aModelTire := { {}, {}, {}, {} }
	Local cError     := ''
    Local oView      := FWFormView():New()
	Local aReturn    := {}
	Local lRet       := .T.
	Local aValues    := {}

	aAdd( aValues, { 'T9_STATUS',  Alltrim( SuperGetMv( 'MV_NGSTAFG', .F., '' ) ) } )
	aAdd( aValues, { 'T9_DTGARAN',  CTOD("  /  /    ") })
	aAdd( aValues, { 'T9_DTCOMPR',  CTOD("") } )
	aAdd( aValues, { 'T9_ESTRUTU', 'N'  } )
	aAdd( aValues, { 'T9_SERIE',   '' } )
	aAdd( aValues, { 'T9_FORNECE', '' } )
	aAdd( aValues, { 'T9_VALCPA',  0 } )
	aAdd( aValues, { 'T9_NFCOMPR', '' } )
	aAdd( aValues, { 'T9_SITMAN',  'A' } )
	aAdd( aValues, { 'T9_PARTEDI', '2' } )

	//----------------------------------------------------------
	// Tela de pneus
	//----------------------------------------------------------
	aReturn := MNTA085SI( oView, Nil, cSimilar, aValues, @aModelTire,, 3 )

	cError := aReturn[1] // descrição do erro caso exista
	lRet   := aReturn[2] // .T. se confirmou; .F. cancelou a tela de pneus

	//--------------------------------------------------------
	// Confirmou a tela de pneus e não há erro de validação
	//--------------------------------------------------------
	If lRet .And. Empty( cError )

		lRet := CommitMult( cSimilar, nAmount, aModelTire )

	ElseIf !Empty( cError )

		lRet := .F.
		Help(' ',1, STR0006,, cError ,2,0)

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} CommitMult
Gravação de pneus na inclusão multipla

@param cSimilar, string, código do pneu similar
@param nAmount, numérico, quantidade de pneus a gerar
@param aModelTire, array, armazena dados do pneu modelo
@author Maria Elisandra de Paula
@since 27/11/2020
@return boolean
/*/
//---------------------------------------------------------------------
Static Function CommitMult( cSimilar, nAmount, aModelTire )

	Local aTires     := {}
	Local lValid     := .F.
	Local nIndex     := 0
	Local cStFire    := Alltrim( SuperGetMv( 'MV_NGSTAFG', .F., '' ) )
	Local cXCodBem   := ''
	Local oModelPneu

	If !Empty( cSimilar )
		dbSelectArea('ST9')
		dbSetOrder(1)
		dbSeek( xFilial('ST9') + cSimilar )
	EndIf

	//-----------------------------------------------------
	// Cria MODELO de pneu
	//-----------------------------------------------------
	oModelPneu := FWLoadModel( 'MNTA083' )
	oModelPneu:SetOperation( 3 )
	oModelPneu:Activate( !Empty( cSimilar ) )
	oModelPneu := MNT085BKP( oModelPneu, 2, aModelTire )[2] // recupera informações do pneu modelo

	//----------------------------------------
	// Código do primeiro pneu a ser gerado
	//----------------------------------------
	cXCodBem := oModelPneu:GetValue( oModelPneu:cId + '_ST9', 'T9_CODBEM')

	For nIndex := 1 To nAmount

		lValid := .T.

		//----------------------------------------------------
		// busca próximo código do bem
		//----------------------------------------------------
		If nIndex > 1
			cXCodBem := MNTA85NEXT( cXCodBem )
			lValid := oModelPneu:SetValue( oModelPneu:cId + '_ST9', 'T9_CODBEM', cXCodBem )
		EndIf

		Begin Transaction

			//------------------------------------------------------------
			// Caso passe por validação faz gravação pela classe MVC
			//------------------------------------------------------------
			 lValid := lValid .And. oModelPneu:VldData() .And. oModelPneu:CommitData()

			If lValid

				//--------------------------------------------------------
				// Armazena código do pneu para mostrar posteriormente
				//--------------------------------------------------------
				aAdd( aTires, { cXCodBem, Alltrim( oModelPneu:GetValue( oModelPneu:cId + '_ST9', 'T9_STATUS') ) })

			Else

				//-----------------------------------------------------------------------
				// Grava tabelas manualmente - quando não passou pela validação
				//-----------------------------------------------------------------------
				MNTA085REC( oModelPneu, cXCodBem, cStFire )

				//--------------------------------------------------------
				// Armazena código do pneu para mostrar posteriormente
				//--------------------------------------------------------
				aAdd( aTires, { cXCodBem, cStFire } )

			EndIf

		End Transaction

	Next nIndex

	//----------------------------------------
	// Apresenta tela de pneus gerados
	//----------------------------------------
	MNT085SHOW( aTires )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA083REL
Relacao do campo TQS_NOMPAI

@author Cauê Girardi
@since 06/10/22
@param cCampo, String, Campo a receber seu relacao 
@return cReturn
/*/
//---------------------------------------------------------------------
Function MNTA083REL(cCampo)

Local cReturn	:= ''
Local aArea		:= ST9->( GetArea() )

If cCampo == 'TQS_PLACA'

	If(!Inclui).AND.(!Empty(M->TQS_PLACA))

		cReturn := Posicione('ST9',14,M->TQS_PLACA,'T9_NOME')

	EndIf
	
EndIF

RestArea( aArea )

Return cReturn
