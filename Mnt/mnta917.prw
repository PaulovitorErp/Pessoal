#INCLUDE 'MNTA917.ch'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA917
Grupos x Permissões x Usuários MNTNG

@type function
@author cristiano.kair
@since 24/10/2022

@return Nil
/*/
//---------------------------------------------------------------------
Function MNTA917()

	Local oBrowse

	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 19, 95 )

		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias( 'HP0' )
		oBrowse:SetDescription( STR0004 ) //'Filtros X Grupos MNTNG'
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
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.MNTA917'   OPERATION MODEL_OPERATION_VIEW  ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.MNTA917'   OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // 'Filtros'

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
	Local oStruHP3 	:= FWFormStruct( 1, 'HP3' )

	oStruHP0:SetProperty( 'HP0_DESCRI', MODEL_FIELD_WHEN, {||.F.} )

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'MNTA917', /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'MNTA917_HP0', /*cOwner*/, oStruHP0 )
	// Adiciona ao modelo uma estrutura de grid
	oModel:AddGrid('MNTA917_HP3','MNTA917_HP0',oStruHP3,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)

	// Determina que o preenchimento da Grid não é obrigatório.
	oModel:GetModel('MNTA917_HP3'):SetOptional(.T.)

	// Determina que a Grid suporta até 99999 registros
	oModel:GetModel('MNTA917_HP3'):SetMaxLine(99999)

	//Faz a relação entre a tabela PAI(HP0) e FILHO(HP3).
	oModel:SetRelation('MNTA917_HP3', {{'HP3_FILIAL','HP0_FILIAL'}, {'HP3_CODGRP','HP0_CODIGO'}}, HP3->(IndexKey(1)))

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

	Local oModel   := FWLoadModel( 'MNTA917' )
	Local oStruHP0 := FWFormStruct( 2, 'HP0' )
	Local oView    := FWFormView():New()
	
	oStruHP0:RemoveField( 'HP0_TIPO' )

	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	oView:AddField( 'VIEW_HP0', oStruHP0, 'MNTA917_HP0' )

	//Adiciona um titulo para o formulário
	oView:EnableTitleView( 'VIEW_HP0', STR0004 ) // 'Filtros X Grupos MNTNG'

	// Criar um 'box' horizontal para receber os elementos da view
	oView:CreateHorizontalBox( 'SUPERIOR', 20 )
	oView:CreateVerticalBox( 'BOX_HP0', 100, 'SUPERIOR' )
	oView:CreateHorizontalBox( 'INFERIOR', 80 )

    oView:CreateFolder( 'PASTAS', 'INFERIOR')

    oView:SetOwnerView('VIEW_HP0','BOX_HP0')

	fViewST6( oView )
	fViewCTT( oView )
	fViewSTD( oView )
	fViewST4( oView )
	fViewSBM( oView )
	fViewSA2( oView )
	fViewSH4( oView )

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk( {||.T.} )

Return oView

//----------------------------------------
/*/{Protheus.doc} fViewST6
Cria View de Famílias (ST6)

@author cristiano.kair
@since 24/11/2022

@param oView, objeto, view da rotina

/*/
//----------------------------------------
Static Function fViewST6( oView )

	Local oTmpTblST6

	//--------------------------------------------------------------
	//Cria markbrowse para manipular Família(ST6) separadamente
	//--------------------------------------------------------------
	oView:AddOtherObject( 'VIEW_ST6', { |oPanel| fCreateObj( oPanel, @oTmpTblST6, 'ST6' ) } ,;
		{|oPanel| fKillObj( oPanel, @oTmpTblST6 ) }/*bDeActivate*/, /*bRefresh*/)

    oView:AddSheet( 'PASTAS', 'PASTA_ST6', STR0005 )//'Família'

    oView:CreateHorizontalBox( 'BOX_ST6', 100, /*owner*/, /*lUsePixel*/, 'PASTAS', 'PASTA_ST6' )
    oView:SetOwnerView( 'VIEW_ST6', 'BOX_ST6' )

Return

//----------------------------------------
/*/{Protheus.doc} fViewCTT
Cria View de Centro de Custo(CTT)

@author cristiano.kair
@since 24/11/2022

@param oView, objeto, view da rotina

/*/
//----------------------------------------
Static Function fViewCTT( oView )

	Local oTmpTblCTT

	//--------------------------------------------------------------
	//Cria markbrowse para manipular Centro de Custo(CTT) separadamente
	//--------------------------------------------------------------
	oView:AddOtherObject( 'VIEW_CTT', { |oPanel| fCreateObj( oPanel, @oTmpTblCTT, 'CTT' ) } ,;
		{|oPanel| fKillObj( oPanel, @oTmpTblCTT ) }/*bDeActivate*/, /*bRefresh*/)

    oView:AddSheet( 'PASTAS', 'PASTA_CTT', STR0006 )//'Centro de Custo'

    oView:CreateHorizontalBox( 'BOX_CTT', 100, /*owner*/, /*lUsePixel*/, 'PASTAS', 'PASTA_CTT' )
    oView:SetOwnerView( 'VIEW_CTT', 'BOX_CTT' )

Return

//----------------------------------------
/*/{Protheus.doc} fViewSTD
Cria View de Área da Manutenção (STD)

@author cristiano.kair
@since 24/11/2022

@param oView, objeto, view da rotina

/*/
//----------------------------------------
Static Function fViewSTD( oView )

	Local oTmpTblSTD

	//--------------------------------------------------------------
	//Cria markbrowse para manipular Área da Manutenção (STD) separadamente
	//--------------------------------------------------------------
	oView:AddOtherObject( 'VIEW_STD', { |oPanel| fCreateObj( oPanel, @oTmpTblSTD, 'STD' ) } ,;
		{|oPanel| fKillObj( oPanel, @oTmpTblSTD ) }/*bDeActivate*/, /*bRefresh*/)

    oView:AddSheet('PASTAS','PASTA_STD',STR0007)//'Área da Manutenção'

    oView:CreateHorizontalBox( 'BOX_STD', 100, /*owner*/, /*lUsePixel*/, 'PASTAS', 'PASTA_STD')
    oView:SetOwnerView( 'VIEW_STD', 'BOX_STD' )

Return

//----------------------------------------
/*/{Protheus.doc} fViewST4
Cria View de Serviço (ST4)

@author cristiano.kair
@since 24/11/2022

@param oView, objeto, view da rotina

/*/
//----------------------------------------
Static Function fViewST4( oView )

	Local oTmpTblST4

	//--------------------------------------------------------------
	//Cria markbrowse para manipular Serviço (ST4) separadamente
	//--------------------------------------------------------------
	oView:AddOtherObject( 'VIEW_ST4', { |oPanel| fCreateObj( oPanel, @oTmpTblST4, 'ST4' ) } ,;
		{|oPanel| fKillObj( oPanel, @oTmpTblST4 ) }/*bDeActivate*/, /*bRefresh*/)

    oView:AddSheet('PASTAS','PASTA_ST4',STR0008)//'Serviço '

    oView:CreateHorizontalBox( 'BOX_ST4', 100, /*owner*/, /*lUsePixel*/, 'PASTAS', 'PASTA_ST4')
    oView:SetOwnerView( 'VIEW_ST4', 'BOX_ST4' )

Return

//----------------------------------------
/*/{Protheus.doc} fViewSBM
Cria View de Grupo de Produtos (SBM)

@author cristiano.kair
@since 24/11/2022

@param oView, objeto, view da rotina

/*/
//----------------------------------------
Static Function fViewSBM( oView )

	Local oTmpTblSBM

	//--------------------------------------------------------------
	//Cria markbrowse para manipular Grupo de Produtos (SBM) separadamente
	//--------------------------------------------------------------
	oView:AddOtherObject( 'VIEW_SBM', { |oPanel| fCreateObj( oPanel, @oTmpTblSBM, 'SBM' ) } ,;
		{|oPanel| fKillObj( oPanel, @oTmpTblSBM ) }/*bDeActivate*/, /*bRefresh*/)

    oView:AddSheet( 'PASTAS', 'PASTA_SBM', STR0009 )//'Grupo de Produtos'

    oView:CreateHorizontalBox( 'BOX_SBM', 100, /*owner*/, /*lUsePixel*/, 'PASTAS', 'PASTA_SBM' )
    oView:SetOwnerView( 'VIEW_SBM', 'BOX_SBM' )

Return

//----------------------------------------
/*/{Protheus.doc} fViewSA2
Cria View de Terceiro (SA2)

@author cristiano.kair
@since 24/11/2022

@param oView, objeto, view da rotina

/*/
//----------------------------------------
Static Function fViewSA2( oView )

	Local oTmpTblSA2

	//--------------------------------------------------------------
	//Cria markbrowse para manipular Terceiro (SA2) separadamente
	//--------------------------------------------------------------
	oView:AddOtherObject( 'VIEW_SA2', { |oPanel| fCreateObj( oPanel, @oTmpTblSA2, 'SA2' ) } ,;
		{|oPanel| fKillObj( oPanel, @oTmpTblSA2 ) }/*bDeActivate*/, /*bRefresh*/)

    oView:AddSheet( 'PASTAS', 'PASTA_SA2', STR0010 )//'Terceiro '

    oView:CreateHorizontalBox( 'BOX_SA2', 100, /*owner*/, /*lUsePixel*/, 'PASTAS', 'PASTA_SA2' )
    oView:SetOwnerView( 'VIEW_SA2', 'BOX_SA2' )

Return

//----------------------------------------
/*/{Protheus.doc} fViewSH4
Cria View de Famílias (ST6)

@author cristiano.kair
@since 24/11/2022

@param oView, objeto, view da rotina

/*/
//----------------------------------------
Static Function fViewSH4( oView )

	Local oTmpTblSH4

	//--------------------------------------------------------------
	//Cria markbrowse para manipular Ferramenta (SH4) separadamente
	//--------------------------------------------------------------
	oView:AddOtherObject( 'VIEW_SH4', { |oPanel| fCreateObj( oPanel, @oTmpTblSH4, 'SH4' ) } ,;
		{|oPanel| fKillObj( oPanel, @oTmpTblSH4 ) }/*bDeActivate*/, /*bRefresh*/)

    oView:AddSheet( 'PASTAS', 'PASTA_SH4', STR0011 )//'Ferramenta'

    oView:CreateHorizontalBox( 'BOX_SH4', 100, /*owner*/, /*lUsePixel*/, 'PASTAS', 'PASTA_SH4' )
    oView:SetOwnerView( 'VIEW_SH4', 'BOX_SH4' )

Return

//--------------------------------------------------------
/*/{Protheus.doc} fCreateObj
Cria markbrowse

@author cristiano.kair
@since 24/10/2022
@param oPanel, objeto, onde o markbrowse será apresentado
@param oTmpTbl, objeto, tabela temporária
@param cTabela, caracter, tabela de origem
/*/
//--------------------------------------------------------
Static Function fCreateObj( oPanel, oTmpTbl, cTabela )

	Local oModel := FWModelActive()
	Local nOperation := oModel:GetOperation()
	Local aFieldsMk := {}
	Local aPesq := {}
	Local oMark
	Local cMarca := GetMark()
	Local cTrbTemp := GetNextAlias()
	Local aDadosTrb := {{'ST6','T6_CODFAMI'	,'T6_NOME'	 },;
						{'CTT','CTT_CUSTO'	,'CTT_DESC01'},;
						{'STD','TD_CODAREA'	,'TD_NOME'	 },;
						{'ST4','T4_SERVICO'	,'T4_NOME'	 },;
						{'SBM','BM_GRUPO'	,'BM_DESC'	 },;
						{'SA2','A2_COD'		,'A2_NOME'	 },;
						{'SH4','H4_CODIGO'	,'H4_DESCRI' }}
	Local nVetorTrb  := AScan(aDadosTrb, {|x| x[1] == cTabela })
	Local cDescriTit := AllTrim( Posicione( 'SX3', 2, aDadosTrb[nVetorTrb][2], 'X3Descric()') )
	Local cDescriNom := AllTrim( Posicione( 'SX3', 2, aDadosTrb[nVetorTrb][3], 'X3Descric()') )

	aAdd( aFieldsMk,{ cDescriTit, aDadosTrb[nVetorTrb][2],'C', TAMSX3( aDadosTrb[nVetorTrb][2] )[1],0 })
	aAdd( aFieldsMk,{ cDescriNom, aDadosTrb[nVetorTrb][3],'C', TAMSX3( aDadosTrb[nVetorTrb][3] )[1],0 })

	aAdd( aPesq , { cDescriTit, { { aDadosTrb[nVetorTrb][2], 'C', TAMSX3( aDadosTrb[nVetorTrb][2])[1], 0, '', '@!' } } } )
	aAdd( aPesq , { cDescriNom, { { aDadosTrb[nVetorTrb][3], 'C', TAMSX3( aDadosTrb[nVetorTrb][3])[1], 0, '', '@!' } } } )

	fCreateTrb( cTrbTemp, cMarca, nOperation, @oTmpTbl, cTabela )

	//--------------------------
	//Cria markbrowse
	//--------------------------
	oMark := FWMarkBrowse():New()
	oMark:SetOwner( oPanel )
	oMark:SetAlias( cTrbTemp )
	oMark:SetFields( aFieldsMk )
	oMark:SetFieldMark( 'OK' )
	oMark:SetMark( cMarca, cTrbTemp, 'OK' )
	oMark:SetAllMark({|| oMark:AllMark()  })
	oMark:SetAfterMark( {|| fAfterMark( oModel, cTrbTemp,, cTabela ) } )
	oMark:SetTemporary( .T. )
	oMark:SetMenuDef( '' )
	oMark:DisableConfig()
	oMark:DisableFilter()
	oMark:DisableReport()
	oMark:SetSeek( .T., aPesq )
	oMark:Activate()

	//----------------------------------------------------
	//desabilita browse nas operações visualizar e excluir
	//----------------------------------------------------
	If cValtochar( nOperation ) $ '15'
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
@param oTmpTbl,    objeto,     temporária
@param cTabela, caracter, tabela de origem

/*/
//--------------------------------------------------------
Static Function fCreateTrb( cTrbTemp, cMarca, nOperation, oTmpTbl, cTabela )

	Local aFieldsTrb := {}
	Local cQuery := ''
	Local aDadosTrb := {{'ST6','T6_FILIAL'	 ,'T6_CODFAMI'	,'T6_NOME'	 },;
						{'CTT','CTT_FILIAL'	 ,'CTT_CUSTO'	,'CTT_DESC01'},;
						{'STD','TD_FILIAL'	 ,'TD_CODAREA'	,'TD_NOME'	 },;
						{'ST4','T4_FILIAL'	 ,'T4_SERVICO'	,'T4_NOME'	 },;
						{'SBM','BM_FILIAL'	 ,'BM_GRUPO'	,'BM_DESC'	 },;
						{'SA2','A2_FILIAL'	 ,'A2_COD'		,'A2_NOME'	 },;
						{'SH4','H4_FILIAL'	 ,'H4_CODIGO'	,'H4_DESCRI' }}

	Local nVetorTrb := AScan(aDadosTrb, {|x| x[1] == cTabela })

	aAdd( aFieldsTrb, { aDadosTrb[nVetorTrb][3], 'C', TamSx3( aDadosTrb[nVetorTrb][3] )[1], 0, ''})
	aAdd( aFieldsTrb, { aDadosTrb[nVetorTrb][4], 'C', TamSx3( aDadosTrb[nVetorTrb][4] )[1], 0, '' })
	aAdd( aFieldsTrb, { 'OK', 'C', 2,0, '' })

	oTmpTbl := FWTemporaryTable():New( cTrbTemp, aFieldsTrb )
	oTmpTbl:AddIndex( '01', { aDadosTrb[nVetorTrb][3] })
	oTmpTbl:AddIndex( '02', { aDadosTrb[nVetorTrb][4] })

	oTmpTbl:Create()

	cQuery := ' SELECT ' + aDadosTrb[nVetorTrb][3] + ', ' + aDadosTrb[nVetorTrb][4] + ', '
	cQuery += " CASE WHEN HP3_CODE <> ' ' THEN ' ' "
	cQuery += " ELSE " + ValToSQL( cMarca ) + "END AS OK "
	cQuery += " FROM " + RetSqlname( cTabela ) + " TRB "
	cQuery += " LEFT JOIN " + RetSqlname( "HP3" ) + " HP3 " 
	cQuery += "  ON  HP3.HP3_FILIAL = " + ValToSQL( FWxFilial( "HP3" ) )
	cQuery += "  AND HP3.HP3_FILORI = " + "TRB." + aDadosTrb[nVetorTrb][2]
	cQuery += "  AND HP3.HP3_CODGRP = " + ValToSQL( HP0->HP0_CODIGO )
	cQuery += "  AND HP3.HP3_TABLE  = " + ValToSQL( cTabela )
	cQuery += "  AND HP3.HP3_CODE   = TRB." + aDadosTrb[nVetorTrb][3]
	cQuery += "  AND HP3.D_E_L_E_T_ = ' '"
	cQuery += " WHERE  TRB." + aDadosTrb[nVetorTrb][2] + " = " + ValToSQL( FWxFilial( cTabela ) )
	cQuery += " AND TRB.D_E_L_E_T_  = ' '"
	cQuery += " ORDER BY " + aDadosTrb[nVetorTrb][3]

	SqlToTrb( cQuery, aFieldsTrb, cTrbTemp )

Return

//--------------------------------------------------------
/*/{Protheus.doc} fAfterMark
Ações ao marcar e desmarcar

@author cristiano.kair
@since 24/10/2022
@param oModel, objeto, modelo de dados
@param cTrbTemp, string, nome da trb
@param [lUpdView], boolean, se deve atualizar a view
@param cTabela, caracter, tabela de origem

/*/
//--------------------------------------------------------
Static Function fAfterMark( oModel, cTrbTemp, lUpdView, cTabela )

	Local oModelHP3 := oModel:GetModel('MNTA917_HP3')
	Local nLenGrid  := oModelHP3:Length()
	Local oView
	Local aDadosTrb := {{'ST6','(cTrbTemp)->T6_CODFAMI'},;
						{'CTT','(cTrbTemp)->CTT_CUSTO'},;
						{'STD','(cTrbTemp)->TD_CODAREA'},;
						{'ST4','(cTrbTemp)->T4_SERVICO'},;
						{'SBM','(cTrbTemp)->BM_GRUPO'},;
						{'SA2','(cTrbTemp)->A2_COD'},;
						{'SH4','(cTrbTemp)->H4_CODIGO'}}

	Local nVetorTrb := AScan(aDadosTrb, {|x| x[1] == cTabela })
	Local cValor	:= &(aDadosTrb[nVetorTrb][2])

	Default lUpdView := .T.

	//--------------------------------------------------------------
	//pesquisa todos os registros da grid, inclusive os deletados
	//--------------------------------------------------------------
	If ( oModelHP3:SeekLine({{ 'HP3_CODE', cValor }}, .T. ))
		If oModelHP3:IsDeleted()
			oModelHP3:UndeleteLine()//quando registro deletado, recupera
		Else
			oModelHP3:DeleteLine() //quando registro não está deletado, deleta
		EndIf
	Else
		If ( nLenGrid == 0 ) ; //se a grid não contém linhas
			.Or. ( nLenGrid > 1 ) ;
			.Or. ( nLenGrid == 1 .And. !Empty( oModelHP3:GetValue( 'HP3_CODE' ))) //grid com apenas uma linha carregada
			oModelHP3:AddLine() //Adiciona uma linha vazia
			nLenGrid++
		EndIf
		
		//Carrega a linha da grid com a familia marcada/desmarcada
		oModelHP3:GoLine( nLenGrid )
		oModelHP3:SetValue( 'HP3_FILIAL', FWxFilial('HP3') )
		oModelHP3:SetValue( 'HP3_CODGRP', HP0->HP0_CODIGO )
		oModelHP3:SetValue( 'HP3_TABLE', cTabela )
		oModelHP3:SetValue( 'HP3_CODE', cValor )
		oModelHP3:SetValue( 'HP3_FILORI', FWxFilial( cTabela ) )

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
@param oTmpTbl, objeto, tabela temporária
/*/
//--------------------------------------------------------
Static Function fKillObj( oPanel, oTmpTbl )

	If ValType( oPanel ) == 'O'
		oPanel:FreeChildren()
	EndIf

	If Valtype( oTmpTbl ) == 'O'
		oTmpTbl:Delete()
	EndIf

Return .T.
