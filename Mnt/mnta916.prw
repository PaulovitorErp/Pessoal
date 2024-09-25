#INCLUDE 'MNTA916.ch'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA916
Grupos x Permissões x Usuários MNTNG

@type function
@author cristiano.kair
@since 24/10/2022

@return Nil
/*/
//---------------------------------------------------------------------
Function MNTA916()

	Local oBrowse

	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 19, 95 )

		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias( 'HP0' )
		oBrowse:SetDescription( STR0004 ) //'Grupos x Permissões x Usuários MNTNG'
		oBrowse:Activate()

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do Menu

@type function
@author cristiano.kair
@since 24/10/2022

@return função com o menu em MVC
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0001 ACTION 'PesqBrw'           OPERATION 1  ACCESS 0 // 'Pesquisar'
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.MNTA916'   OPERATION MODEL_OPERATION_VIEW  ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.MNTA916'   OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // 'Permissões'

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados da rotina

@type function
@author cristiano.kair
@since 24/10/2022

@return objeto, objeto do Modelo MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oModel
	Local oStruHP0 	:= FWFormStruct( 1, 'HP0' )
	Local oStruHP1 	:= FWFormStruct( 1, 'HP1' )
	Local oStruHP2 	:= FWFormStruct( 1, 'HP2' )
	Local aRelacHP1	:= {}
	Local aRelacHP2	:= {}

	oStruHP0:SetProperty( 'HP0_DESCRI', MODEL_FIELD_WHEN, {||.F.} )

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'MNTA916', /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'MNTA916_HP0', /*cOwner*/, oStruHP0 )
	// Adiciona ao modelo uma estrutura de grid
	oModel:AddGrid('MNTA916_HP1','MNTA916_HP0',oStruHP1,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)
	oModel:AddGrid('MNTA916_HP2','MNTA916_HP0',oStruHP2,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)

	// Determina que o preenchimento da Grid não é obrigatório.
	oModel:GetModel('MNTA916_HP1'):SetOptional(.T.)
	oModel:GetModel('MNTA916_HP2'):SetOptional(.T.)

	//Faz a relação entre a tabela PAI(HP0) e FILHO(HP1).
	aAdd(aRelacHP1,{'HP1_FILIAL', "xFilial('HP1')" })
	aAdd(aRelacHP1,{'HP1_CODGRP','HP0_CODIGO'})
	oModel:SetRelation('MNTA916_HP1', aRelacHP1, HP1->(IndexKey(1)))

	//Faz a relação entre a tabela PAI(HP0) e FILHO(HP2).
	aAdd(aRelacHP2,{'HP2_FILIAL', "xFilial('HP2')" })
	aAdd(aRelacHP2,{'HP2_CODGRP','HP0_CODIGO'})
	oModel:SetRelation('MNTA916_HP2', aRelacHP2, HP2->(IndexKey(1)))

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface da rotina

@type function
@author cristiano.kair
@since 24/10/2022

@return objeto, objeto da View MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   := FWLoadModel( 'MNTA916' )
	Local oStruHP0 := FWFormStruct( 2, 'HP0' )
	Local oStruHP2 := FWFormStruct( 2, 'HP2' )
	Local oView    := FWFormView():New()
	Local oTmpTbl1

	oStruHP0:RemoveField( 'HP0_TIPO' )
	oStruHP2:RemoveField( 'HP2_CODGRP' )
	oStruHP2:RemoveField( 'HP2_ACCESS' )

	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	oView:AddField( 'VIEW_HP0', oStruHP0, 'MNTA916_HP0' )
	oView:AddGrid( 'VIEW_USER', oStruHP2, 'MNTA916_HP2' )

	//--------------------------------------------------------------
	//Cria markbrowse para manipular Permissões separadamente
	//--------------------------------------------------------------
	oView:AddOtherObject( 'VIEW_PERM', { |oPanel| fCreateObj( oPanel, @oTmpTbl1 ) } ,;
		{|oPanel| fKillObj( oPanel, @oTmpTbl1 ) }/*bDeActivate*/, /*bRefresh*/)

	//Adiciona um titulo para o formulário
	oView:EnableTitleView( 'VIEW_HP0', STR0004 ) // "Grupos x Permissões x Usuários MNTNG"

	// Criar um "box" horizontal para receber os elementos da view
	oView:CreateHorizontalBox( 'SUPERIOR', 20 )
	oView:CreateHorizontalBox( 'INFERIOR', 80 )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_HP0',  'SUPERIOR' )

	// Criar os componentes "box" vertical para receber os elementos de grid na parte inferior esquerda da tela
	oView:CreateVerticalBox( 'INF_ESQ', 50, 'INFERIOR' )
	oView:SetOwnerView( 'VIEW_PERM', 'INF_ESQ' )

	// Criar os componentes "box" vertical para receber os elementos de grid na parte inferior direita da tela
	oView:CreateVerticalBox( 'INF_DIR', 50, 'INFERIOR' )
	oView:SetOwnerView( 'VIEW_USER', 'INF_DIR' )

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk( {||.T.} )

	//Inclusão de itens no Ações Relacionadas de acordo com o NGRightClick
	NGMVCUserBtn( oView )

Return oView

//--------------------------------------------------------
/*/{Protheus.doc} fCreateObj
Cria markbrowse

@author cristiano.kair
@since 24/10/2022
@param oPanel, objeto, onde o markbrowse será apresentado
@param oTmpTbl1, objeto, tabela temporária
/*/
//--------------------------------------------------------
Static Function fCreateObj( oPanel, oTmpTbl1 )

	Local oModel := FWModelActive()
	Local oModelHP1 := oModel:GetModel('MNTA916_HP1')
	Local nOperation := oModel:GetOperation()
	Local aFieldsMk := {}
	Local aPesq := {}
	Local oMark
	Local cMarca := GetMark()
	Local cTrbTemp := GetNextAlias()

	aAdd( aFieldsMk,{ "Chave", "X5_CHAVE","C", TAMSX3( "X5_CHAVE" )[1], 0})
	aAdd( aFieldsMk,{ "Permissões", "X5_DESCRI","C", TAMSX3( "X5_DESCRI" )[1], 0})

	aAdd( aPesq , { "Chave", { { "X5_CHAVE", "C", TAMSX3('X5_CHAVE')[1], 0, "", "@!" } } } )
	aAdd( aPesq , { "Permissões", { { "X5_DESCRI", "C", TAMSX3('X5_DESCRI')[1], 0, "", "@!" } } } )

	//-------------------------------------------------
	//Cria tabela temporária baseada na HP1 - permissões x Grupos
	//-------------------------------------------------
	fCreateTrb( cTrbTemp, cMarca, nOperation, @oTmpTbl1 )

	//--------------------------
	//Cria markbrowse
	//--------------------------
	oMark := FWMarkBrowse():New()
	oMark:SetOwner( oPanel )
	oMark:SetAlias( cTrbTemp )
	oMark:SetFields( aFieldsMk )
	oMark:SetFieldMark( "OK" )
	oMark:SetMark( cMarca, cTrbTemp, "OK" )
	oMark:SetAllMark({|| oMark:AllMark()  })
	oMark:SetAfterMark( {|| fAfterMark( oModelHP1, cTrbTemp ) } )
	oMark:SetTemporary( .T. )
	oMark:SetMenuDef( "" )
	oMark:DisableConfig()
	oMark:DisableFilter()
	oMark:DisableReport()
	oMark:Activate()

	//----------------------------------------------------
	//desabilita browse nas operações visualizar e excluir
	//----------------------------------------------------
	If cValtochar( nOperation ) $ "15"
		oMark:Disable( .T. )
	EndIf

Return .T.

//--------------------------------------------------------
/*/{Protheus.doc} fCreateTrb
Cria tabela temporária baseada no SX5

@author cristiano.kair
@since 24/10/2022
@param cTrbTemp,    string,     nome da tabela temporária
@param cMarca,      string,     marca utilizada no markbrowse
@param nOperation,  numerico,   operação corrente
@param oTmpTbl1,    objeto,     temporária

/*/
//--------------------------------------------------------
Static Function fCreateTrb( cTrbTemp, cMarca, nOperation, oTmpTbl1 )

	Local aFieldsTrb := {}
	Local cQuery := ""

	aAdd( aFieldsTrb, { "X5_CHAVE", "C", TamSx3( "X5_CHAVE" )[1], 0, ""})
	aAdd( aFieldsTrb, { "X5_DESCRI", "C", TamSx3( "X5_DESCRI" )[1], 0, ""})
	aAdd( aFieldsTrb, { "OK", "C", 2, 0, "" })

	oTmpTbl1 := FWTemporaryTable():New( cTrbTemp, aFieldsTrb )
	oTmpTbl1:AddIndex( "01", { "X5_CHAVE" })
	oTmpTbl1:AddIndex( "02", { "X5_DESCRI" })

	oTmpTbl1:Create()

	cQuery := " SELECT X5_CHAVE, X5_DESCRI, "
	cQuery += " CASE WHEN HP1_CODPER IS NULL THEN ' ' "
	cQuery += " ELSE " + ValToSQL( cMarca ) + " END AS OK "
	cQuery += " FROM " + RetSqlname( "SX5" ) + " SX5 "
	cQuery += " LEFT JOIN " + RetSqlname( "HP1" ) + " HP1 " 
	cQuery += "  ON  HP1.HP1_FILIAL = " + ValToSQL( FWxFilial( "HP1" ) )
	cQuery += "  AND HP1.HP1_CODGRP = " + ValToSQL( HP0->HP0_CODIGO )
	cQuery += "  AND HP1.HP1_CODPER = SX5.X5_CHAVE "
	cQuery += "  AND HP1.D_E_L_E_T_ = ' '"
	cQuery += " WHERE SX5.X5_FILIAL = " + ValToSQL( FWxFilial( "SX5" ) )
	cQuery += "  AND  SX5.X5_TABELA = 'OG'
	cQuery += "  AND  SX5.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY X5_CHAVE "

	SqlToTrb( cQuery, aFieldsTrb, cTrbTemp )

Return

//--------------------------------------------------------
/*/{Protheus.doc} fAfterMark
Ações ao marcar e desmarcar

@author cristiano.kair
@since 24/10/2022
@param oModelHP1, objeto, modelo da grid HP1
@param cTrbTemp, string, nome da trb
@param [lUpdView], boolean, se deve atualizar a view
/*/
//--------------------------------------------------------
Static Function fAfterMark( oModelHP1, cTrbTemp, lUpdView )

	Local nLenGrid := oModelHP1:Length()
	Local oView

	Default lUpdView := .T.

	//--------------------------------------------------------------
	//pesquisa todos os registros da grid, inclusive os deletados
	//--------------------------------------------------------------
	If ( oModelHP1:SeekLine({{ "HP1_CODPER", (cTrbTemp)->X5_CHAVE }}, .T. ))
		If oModelHP1:IsDeleted()
			oModelHP1:UndeleteLine()//quando registro deletado, recupera
		Else
			oModelHP1:DeleteLine() //quando registro não está deletado, deleta
		EndIf
	Else
		If ( nLenGrid == 0 ) ; //se a grid não contém linhas
			.Or. ( nLenGrid > 1 ) ;
				.Or. ( nLenGrid == 1 .And. !Empty( oModelHP1:GetValue( "HP1_CODPER" ))) //grid com apenas uma linha carregada
			oModelHP1:AddLine() //Adiciona uma linha vazia
			nLenGrid++
		EndIf

		//Carrega a linha da grid com a familia marcada/desmarcada
		oModelHP1:GoLine( nLenGrid )
		oModelHP1:SetValue( "HP1_CODPER", (cTrbTemp)->X5_CHAVE )
	EndIf

	If lUpdView
		//---------------------------------------------------
		//Define que view foi modificada
		//para não causar msg de formulário não alterado
		//---------------------------------------------------
		oView := FWViewActive()
		oView:SetModified( .T. )
	EndIf

Return .T.

//--------------------------------------------------------
/*/{Protheus.doc} fKillObj
Ações após desativar objeto

@author cristiano.kair
@since 24/10/2022
@param oPanel, objeto, onde foi criado markbrowse
@param oTmpTbl1, objeto, tabela temporária
/*/
//--------------------------------------------------------
Static Function fKillObj( oPanel, oTmpTbl1 )

	If ValType( oPanel ) == "O"
		oPanel:FreeChildren()
	EndIf

	If Valtype( oTmpTbl1 ) == "O"
		oTmpTbl1:Delete()
	EndIf

Return .T.

//--------------------------------------------------------
/*/{Protheus.doc} MNTA916GAT
Gatilhos da rotina MNTA916

@author cristiano.kair
@since 10/11/2022

/*/
//--------------------------------------------------------
Function MNTA916GAT()

Return UsrFullName(M->HP2_CODUSR)

//--------------------------------------------------------
/*/{Protheus.doc} MNT916REL
Relação da rotina MNTA916

@author cristiano.kair
@since 10/11/2022

/*/
//--------------------------------------------------------
Function MNT916REL()

Return UsrFullName(HP2->HP2_CODUSR)

//--------------------------------------------------------
/*/{Protheus.doc} MNT916VAL
Validação da rotina MNTA916

@author cristiano.kair
@since 10/01/2023
@param [cField]   , string , Campo para validação.

@return lógico, validação do campo
/*/
//--------------------------------------------------------
Function MNT916VAL( cField )

	Local lRet := .T.

	Default cField := ReadVar()

	// Trata a váriavel para validar conteúdo padrão.
	cField := Trim( Upper( SubStr( cField , At( '>' , cField ) + 1 , Len( cField ) ) ) )

	If 'HP2_CODUSR' $ cField

		dbSelectArea( 'HP2' )
		dbSetOrder( 2 ) //HP2_FILIAL+HP2_CODUSR+HP2_CODGRP
		If dbSeek( FWxFilial( 'HP2' ) + M->HP2_CODUSR )

			lRet := .F.
			Help(NIL, NIL, STR0005,;//"Atenção"
				NIL, STR0006 + HP2->HP2_CODGRP, 1, 0, NIL, NIL, NIL, NIL, NIL,)//"Usuário já cadastrado em outro Grupo de Usuários: "

		EndIf

	EndIf

Return lRet
