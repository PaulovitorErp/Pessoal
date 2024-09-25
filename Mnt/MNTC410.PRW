#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "MNTC410.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC410
Gráfico de Evolução de Respostas das Etapas de Ordens de Serviço.

@author	Elynton Fellipe Bazzo
@since		05/05/2015
@version	MP12
@return	Nil
/*/
//---------------------------------------------------------------------
Function MNTC410()

	Local aNGBEGINPRM := NGBEGINPRM()


	If Pergunte( "MNT410",.T. )

		//Se os parâmetros da consulta não estiverem preenchidos;
		If Empty( mv_par01 ) .And. Empty( mv_par02 ) .Or. Empty( mv_par03 ) .And. Empty( mv_par04 );
			.Or. Empty( mv_par05 ) .And. Empty( mv_par06 ) .Or. Empty( mv_par07 ) .And. Empty( mv_par08 )
			MsgAlert( STR0067, "MNTC410" ) //"Parâmetros da consulta inválidos."
			Return .F.
		EndIf

		MsgRun( STR0068,STR0069, { || MNT410PROC() }) // "Processando informações..."###"Aguarde"

	EndIf

	NGRETURNPRM( aNGBEGINPRM )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT410PROC
Função que processa o gerencial de respostas por etapas.

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version	MP12
@return	Nil
/*/
//---------------------------------------------------------------------
Static Function MNT410PROC()

	Local aCoors := FWGetDialogSize( oMainWnd ) // Retorna limites da tela para a construcao da tela

	Private aEndBrw := { .F.,.T. } // Variavel de controle para reconstrucao da consulta
	Private oTempST9 //Tabela temporária de Bens
	Private oTempSTJ //Tabela temporária de O.S
	Private oTempSTQ //Tabela temporária de Etapas
	Private oTempQUE //Tabela temporária de Consulta

	If !C410QYNULL( .T. ) // Verifica se, conforme os parametros, a consulta trará registros
		oTempQUE:Delete() // Finaliza tabela temp. de Consulta
		Return
	Endif

	C410CRTTRB() // Constroi tabelas temporarias para controle dos browses da consulta

	Do While !aEndBrw[1] // Refaz tela da consulta, enquanto requisitado
		C410CRTBRW( aCoors ) // Realiza construcao da tela da consulta

		If !aEndBrw[1] .And. aEndBrw[2] // Caso a consulta nao for finalizada, remonta tabelas temporarias com os dados da nova consulta
			C410RBUILD() //Reconstruindo a consulta
		Endif
	End

	// Finaliza tabelas temporarias
	oTempST9:Delete() // Finaliza tabela temp. de Bens
	oTempSTQ:Delete() // Finaliza tabela temp. de Etapas
	oTempSTJ:Delete() // Finaliza tabela temp. de O.S
	oTempQUE:Delete() // Finaliza tabela temp. de Consulta

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} C410RBUILD
Função que reconstroe a consulta.

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version	MP12
@return	Nil
/*/
//---------------------------------------------------------------------
Static Function C410RBUILD()

	// Limpa tabela temporaria de Bens
	C410CLEAR( cAliasBem )

	// Limpa tabela temporaria de Etapas
	C410CLEAR( cAliasEtp )

	// Limpa tabela temporaria de O.S.
	C410CLEAR( cAliasOS )

	C410QYNULL() // Efetua consulta (query), conforme os novos parametros
	IncTrbAt( cAliasQryBrw )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} C410CLEAR
Função que remove todos os registros da tabela.

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version	MP12
@return	Nil
/*/
//---------------------------------------------------------------------
Static Function C410CLEAR( cAlias )

	dbSelectArea( cAlias )
	Set Filter To
	ZAP

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} C410QYNULL
Função que verifica se a consulta obteve registros, conforme parâmetros
repassados.

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version	MP12
@return	lRet
/*/
//---------------------------------------------------------------------
Static Function C410QYNULL( lBuild )

	Local lShowBrw	:= .T. // Verifica se a query abrange registros
	Local lRet		:= .T.

	Default lBuild	:= .F.

	// Verifica se deve criar Alias para as tabelas temporarias das querys
	If lBuild .And. Type( "cAliasQryBrw" ) != "C"
		_SetOwnerPrvt( "cAliasQryBrw" , GetNextAlias() )
		_SetOwnerPrvt( "aEstQry"      , CrtTrbBrw( cAliasQryBrw , "Query" ) )
	Endif

	lShowBrw := C410QRYBRW() // Define query conforme tabela base do browse

	// Informa se a consulta obteve registros, conforme os parametros repassados
	If !lShowBrw
		//"Não foram encontrados resultados para a consulta." ## //"Verifique os parametros desejados."
		ShowHelpDlg( STR0021,{ STR0022 },1,{ STR0023 },1)
		lRet := .F.
	Endif

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} C410CRTBRW
Função que monta a tela da consulta.

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version	MP12
@return	Nil
/*/
//---------------------------------------------------------------------
Static Function C410CRTBRW( aCoors )

	Local oFWLayer
	Local oPanelUp
	Local oPanelDownEtp
	Local oPanelDownOS
	Local bBrwExit	:= {|| oDlgBrw:End() }
	Local nPreVis		:= MV_PAR09

	Private oDlgBrw, oBrowseUp
	Private oBrowseEtp, oBrowseOS

	aEndBrw[1] := .T. // Atualiza variavel de controle de reconstrucao de tela

	Define MsDialog oDlgBrw Title STR0064 From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel //"Respostas de Etapas do Bem"

		oDlgBrw:lEscClose := .F.

		// Container de Browses
		oFWLayer := FWLayer():New()
		oFWLayer:Init(oDlgBrw)

		// Adiciona linha superior
		oFWLayer:AddLine( "LineUp",50,.F. )

		// Adiciona coluna a linha superior
		oFWLayer:AddCollumn( "ColumnUp",100,.F.,"LineUp" )
		oPanelUp := oFWLayer:GetColPanel( "ColumnUp","LineUp" )

		// Browse de Bens
		oBrowseUp := CrtFrmBrw( oPanelUp,STR0074,cAliasBem,aEstBem,"1",.F. ) //"Bens"
		oBrowseUp:AddButton( STR0075, {|| IIF( C410SETPAR(),oDlgBrw:End(), ) } ,,4,,.F. ) //"Parâmetros"
		oBrowseUp:AddButton( STR0030, {|| aEndBrw[1] := .T., oDlgBrw:End() } ,,4,,.F. ) //"Sair"
		oBrowseUp:bChange := {|| ApFltBrw( 1,MV_PAR09 ) }

		// Adiciona linha inferior
		oFWLayer:AddLine( "LineDown",50,.T. )

		// Adiciona coluna a esquerda, na linha inferior
		oFWLayer:AddCollumn("ColumDownEtp" , If(MV_PAR09 != 3, 40, 100), .T., "LineDown")
		oPanelDownEtp := oFWLayer:GetColPanel( "ColumDownEtp","LineDown" )

		// Browse de Etapas do Bem
		oBrowseEtp := CrtFrmBrw( oPanelDownEtp,STR0076,cAliasEtp,aEstEtp,"2",.F. ) //"Etapas do Bem"
		oBrowseEtp:SetFilterDefault("(cAliasEtp)->T9_CODBEM == (cAliasBem)->T9_CODBEM")
		oBrowseEtp:bChange := {|| ApFltBrw( 2,MV_PAR09 ) }

		If !EmptyTrb( cAliasOS )
			oBrowseEtp:AddButton( STR0034, {|| C410GRAPHIC( oBrowseEtp ) } , , 4 , , .F. ) //"Gráfico"
			oBrowseEtp:AddButton( STR0033, {|| Processa( {|| C410VISOS(), STR0032 } )  } , , 4 , , .F. ) ////"Vis. O.S." ## "Listando O.S's..."
		Endif

		// Se a pre visualizacao estiver habilitada
		If MV_PAR09 != 3
			CrtPVisBrw( oFWLayer,@oPanelDownOS,MV_PAR09 )
		Endif

		oBrowseUp:Activate()
		oBrowseEtp:Activate()

		oBrowseUp:SetFocus()

	Activate MsDialog oDlgBrw Center

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} C410SETPAR
Função que remonta a consulta, caso confirmado a alteração dos parâmetros.

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version	MP12
@return	Nil
/*/
//---------------------------------------------------------------------
Static Function C410SETPAR()

	Local cGrupo := Padr( "MNT410",Len(Posicione("SX1", 1, "MNT410", "X1_GRUPO")))
	Local aArea  := GetArea()
	Local aParam := {}
	Local lResp  := .T.
	Local nInd

	aEndBrw[1] := .T.
	aEndBrw[2] := .T.

	If ( lResp := Pergunte( "MNT410" ) )
		aEndBrw[1] := .F.
	Endif

	RestArea( aArea )

Return lResp

//---------------------------------------------------------------------
/*/{Protheus.doc} CrtPVisBrw
Função que monta as colunas e gráfico.

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version	MP12
@return	Nil
/*/
//---------------------------------------------------------------------
Static Function CrtPVisBrw( oFWLayer, oPanelDownOS, nPreVis )

	// Adiciona coluna a direita, na linha inferior
	oFWLayer:AddCollumn( "ColumDownOS",60,.T.,"LineDown" )

	If nPreVis == 1

		_SetOwnerPrvt( "oGraficoBrw",Nil ) // Cria variavel para o objeto TMSGraphic

		oFWLayer:AddWindow( "ColumDownOS","WindowOS",STR0098,100,.F.,.T.,,"LineDown", { || } ) //"Resposta de Etapas da O.S."
		oPanelDownOS := oFWLayer:GetWinPanel( "ColumDownOS","WindowOS","LineDown" )

		// Verifica se a tabela temporaria de O.S. esta vazia
		If !EmptyTrb( cAliasOS )

			// Controi gráfico TMSGraphic
			@ 000, 000 MsGraphic oGraficoBrw Size 0,0 Of oPanelDownOS Pixel
			oGraficoBrw:Align := CONTROL_ALIGN_ALLCLIENT

			// Carrega grafico
			LoadGraphic( oGraficoBrw )

		EndIf

	Else

		// Panel da coluna lateral direita (linha inferior)
		oPanelDownOS := oFWLayer:GetColPanel( "ColumDownOS","LineDown" )

		// Browse de O.S.
		oBrowseOS := CrtFrmBrw( oPanelDownOS,STR0024,cAliasOS,aEstOS,"3",.F. ) //"Ordens de Serviço"
		oBrowseOS:SetFilterDefault( RetFltOS() )
		oBrowseOS:Activate()

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} EmptyTrb
Função que verifica se a tabela temporária de O.S. esta vazia.

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version	MP12
@return	lRet
/*/
//---------------------------------------------------------------------
Static Function EmptyTrb( cAlias )

	Local aArea      := GetArea()
	Local aAreaAlias := (cAlias)->(GetArea())
	Local lRet       := .F.

	// Verfica se esta vazia/fim de arquivo
	dbSelectArea( cAlias )
	dbGoTop()
	lRet := Eof()

	RestArea( aAreaAlias )
	RestArea( aArea )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} ApFltBrw
Função que reaplica filtro no browse de etapas.

@author	Elynton Fellipe Bazzo
@since		23/06/2015
@version	MP12
@return	Nil
/*/
//---------------------------------------------------------------------
Static Function ApFltBrw( nBrw,nPreVis )

	Local aCpntsGrf := {}
	Local cFilterOS := ""

	// Reaplica filtro do browse de etapas
	If nBrw == 1
		oBrowseEtp:CleanFilter()
		oBrowseEtp:ExecuteFilter()
		oBrowseEtp:Refresh()
	EndIf

	If nPreVis == 2

		oBrowseOS:CleanFilter()
		oBrowseOS:ExecuteFilter()
		oBrowseOS:Refresh()

	Else

		cFilterOS := RetFltOS()

		dbSelectArea( cAliasOS )
		Set Filter To
		Set Filter To &cFilterOS

		dbSelectArea( cAliasOS )
		dbGoTop()

		If Type( "oGraficoBrw" ) == "O"
			LoadGraphic( oGraficoBrw )
		EndIf

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} RetFltOS
Função que seta um filtro para a área de trabalho atual.

@author	Elynton Fellipe Bazzo
@since		23/06/2015
@version	MP12
/*/
//---------------------------------------------------------------------
Static Function RetFltOS()
Return " (cAliasOS)->TQ_ETAPA == (cAliasEtp)->TQ_ETAPA .And. (cAliasOS)->TPQ_OPCAO == (cAliasEtp)->TPQ_OPCAO .And. (cAliasOS)->TJ_CODBEM == (cAliasBem)->T9_CODBEM "

//---------------------------------------------------------------------
/*/{Protheus.doc} C410CRTTRB
Função que constrói as tabelas temporarias para controle dos browses
da consulta.

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version	MP12
@return	Nil
/*/
//---------------------------------------------------------------------
Static Function C410CRTTRB( aEstBem,aEstOS,aEstEtp )

	Local aEstTrbs := {}

	_SetOwnerPrvt( "cAliasBem" , GetNextAlias() )
	_SetOwnerPrvt( "cAliasOS"  , GetNextAlias() )
	_SetOwnerPrvt( "cAliasEtp" , GetNextAlias() )

	Processa( {|| ( aEstTrbs := C410TRBESP() ) , STR0077 } ) //"Gerando Consulta..."

	_SetOwnerPrvt( "aEstBem" , aClone(aEstTrbs[1]) )
	_SetOwnerPrvt( "aEstOS"  , aClone(aEstTrbs[2]) )
	_SetOwnerPrvt( "aEstEtp" , aClone(aEstTrbs[3]) )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} C410TRBESP
Função que cria as estruturas de Bens/O.S./Etapas e Registros.

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version	MP12
@return	aEstTrbs
/*/
//---------------------------------------------------------------------
Static Function C410TRBESP()

	Local aEstTrbs := Array( 3 ) //Array de 3 posições.

	ProcRegua( 4 )

	//Incrementa valores na régua de progressão
	IncProc( STR0070 ) //"Construindo estrutura de Bens ..."
	aEstTrbs[1] := CrtTrbBrw( cAliasBem,"ST9" ) // Cria estrutura de Bens   { Alias, IndiceSeek, Columns }

	IncProc( STR0071 ) //"Construindo estrutura de O.S. ..."
	aEstTrbs[2]  := CrtTrbBrw( cAliasOS,"STJ" ) // Cria estrutura de O.S.   { Alias, IndiceSeek, Columns }

	IncProc( STR0072 ) //"Construindo estrutura de Etapas ..."
	aEstTrbs[3] := CrtTrbBrw( cAliasEtp , "STQ" ) // Cria estrutura de Etapas { Alias, IndiceSeek, Columns }

	IncProc( STR0073 ) //"Selecionando Registros ..."
	IncTrbAt( cAliasQryBrw )

Return aEstTrbs

//---------------------------------------------------------------------
/*/{Protheus.doc} CrtFrmBrw
Função que define browse da tabela temporaria em questão.

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version	MP12
@return	oBrowse
/*/
//---------------------------------------------------------------------
Static Function CrtFrmBrw( oOwner, cTitle, cAlias, aEstBrw, cIdBrw, lActivate )

	Local oBrowse

	Default lActivate := .T.

	// Define browse da tabela temporaria em questao
	oBrowse := FWFormBrowse():New()
	oBrowse:SetOwner(oOwner)
	oBrowse:SetDescription(cTitle)

	oBrowse:SetDataTable(.T.)
	oBrowse:SetAlias(cAlias)
	oBrowse:SetTemporary(.T.)

	oBrowse:SetLocate()
	oBrowse:SetSeek(,aEstBrw[3])

	oBrowse:DisableDetails(.T.)
	oBrowse:SetProfileID(cIdBrw)

	oBrowse:SetCacheView(.T.)

	// Define, caso haja, colunas do browse
	If !Empty(aEstBrw[5])
		oBrowse:SetColumns(aEstBrw[5])
	Endif

	// Verifica se deve ativar/efetivar o browse
	If lActivate
		oBrowse:Activate()
	Endif

Return oBrowse

//---------------------------------------------------------------------
/*/{Protheus.doc} CrtTrbBrw
Função que cria tabela temorário para montar o browse.

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version	MP12
@return	{ cAliasTrb, aIndTrb, aIndSeek, aColBrw[2], aColBrw[3] }
/*/
//---------------------------------------------------------------------
Static Function CrtTrbBrw( cAliasTrb, cTable )

	Local aIndexes := RetIndexTb( cTable ) // Indices da tabela em quetao
	Local aIndSeek := {}
	Local aIndTrb  := {}
	Local aColBrw, nInd

	aColBrw := RetFldBrw(cTable, aIndexes, cAliasTrb) 	// Campos (TRB) e Colunas (Browse)

	// Define, atraves dos indices da tabela,
	// os indices de procura e indices da tabela temporaria
	For nInd := 1 To Len(aIndexes)
		aAdd( aIndTrb  , aIndexes[nInd][1] ) // Indices tabela temporaria
		aAdd( aIndSeek , { aIndexes[nInd][2] , { { "" , "C" , 255 , 0 , aIndexes[nInd][2] } } } ) // Indices de pesquisa
	Next nInd

	If cTable == "ST9" //Monta indices da ST9
		oTempST9:= FWTemporaryTable():New( cAliasTrb, aColBrw[2] )
		oTempST9:AddIndex( "1", {"T9_CODBEM"} )
		oTempST9:AddIndex( "2", {"T9_CCUSTO","T9_CODBEM"} )
		oTempST9:AddIndex( "3", {"T9_CODFAMI","T9_CODBEM"} )
		oTempST9:AddIndex( "4", {"T9_CODBEM","T9_NOME"} )
		oTempST9:AddIndex( "5", {"T9_FORNECE","T9_LOJA"} )
		oTempST9:Create()
	ElseIf cTable == "STJ" //Monta indices da STJ
		oTempSTJ:= FWTemporaryTable():New( cAliasTrb, aColBrw[2] )
		oTempSTJ:AddIndex( "1", {"TJ_ORDEM","TJ_PLANO","TJ_CODBEM","TQ_ETAPA","TPQ_OPCAO","TJ_DTRESP"} )
		oTempSTJ:AddIndex( "2", {"TJ_DTRESP","TJ_CODBEM","TQ_ETAPA","TPQ_OPCAO","TJ_ORDEM","TJ_PLANO"} )
		oTempSTJ:AddIndex( "3", {"TJ_TIPOOS","TJ_ORDEM","TJ_PLANO","TJ_CODBEM","TJ_SERVICO"} )
		oTempSTJ:AddIndex( "4", {"TJ_PLANO","TJ_ORDEM","TJ_TIPOOS","TJ_CODBEM"} )
		oTempSTJ:AddIndex( "5", {"TJ_SERVICO","TJ_TIPOOS","TJ_CODBEM"} )
		oTempSTJ:AddIndex( "6", {"TJ_CCUSTO","TJ_CENTRAB","TJ_SERVICO"} )
		oTempSTJ:Create()
	ElseIf cTable ==  "STQ" //Monta indices da STQ
		oTempSTQ:= FWTemporaryTable():New( cAliasTrb, aColBrw[2] )
		oTempSTQ:AddIndex( "1", {"TQ_ETAPA","TPQ_OPCAO","TQ_ORDEM","TQ_PLANO"} )
		oTempSTQ:AddIndex( "2", {"T9_CODBEM","TQ_ETAPA","TPQ_OPCAO","TQ_ORDEM","TQ_PLANO"} )
		oTempSTQ:Create()
	ElseIf cTable ==  "Query"
		oTempQUE:= FWTemporaryTable():New( cAliasTrb, aColBrw[2] )
		oTempQUE:AddIndex( "1", {"T9_CODBEM","TQ_ETAPA","TPQ_OPCAO","TJ_ORDEM","TJ_PLANO"} )
		oTempQUE:Create()
	EndIf

Return { cAliasTrb, aIndTrb, aIndSeek, aColBrw[2], aColBrw[3] }

//---------------------------------------------------------------------
/*/{Protheus.doc} C410QRYBRW
Função que define query conforme tabela base do browse

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version	MP12
@return	lShowBrw
/*/
//---------------------------------------------------------------------
Static Function C410QRYBRW()

	Local cQueryBrw, cKeyQrBem, cKeyQrEtp, nIndOS

	Local aTblQry   := {}
	Local lShowBrw  := .F.

	Store "" To cQueryBrw, cKeyQrBem, cKeyQrEtp

	// Indice de verificacao de O.S. [ Atual ]
	For nIndOS := 1 To 2

		nIndOS := 2 // Define como historico caso segundo indice

		// Define tabelas para execucao da query
		aAdd( aTblQry, { "STJ","STJ.TJ"  } )
		aAdd( aTblQry, { "STQ","STQ.TQ"  } )
		aAdd( aTblQry, { "TPQ","TPQ.TPQ" } )

		// Executa query
		Processa( {|| C410QUERY( aTblQry,STR0099 ) } ) //"Verificando O.S's..."

	Next nIndOS

	dbSelectArea( cAliasQryBrw )
	dbGoTop()
	lShowBrw := (cAliasQryBrw)->(!Eof())

Return lShowBrw

//---------------------------------------------------------------------
/*/{Protheus.doc} C410QUERY
Função que executa a query

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version	MP12
@return	Nil
/*/
//---------------------------------------------------------------------
Static Function C410QUERY( aTblQry,cProcess )

	Local nInd
	Local cAliasQry	:= GetNextAlias()
	Local _cGetDB := TcGetDb() // Verifica qual Banco de Dados está sendo usado
	Local cSubstr := IIF(Upper(_cGetDB) $ 'ORACLE,POSTGRES,INFORMIX' .OR. Upper(_cGetDB) $ 'DB2',"SUBSTR","SUBSTRING")

	Local aPerCon	:= { MV_PAR01,MV_PAR02 }

	ProcRegua( 0 )
	IncProc( cProcess )

	cQueryBrw := " SELECT ST9.T9_CODBEM,  ST9.T9_CCUSTO,  ST9.T9_CODFAMI, ST9.T9_NOME,    ST9.T9_FORNECE, ST9.T9_LOJA, "
	cQueryBrw += "        " + aTblQry[1][2] + "_ORDEM AS TJ_ORDEM, " 		+ aTblQry[1][2] + "_PLANO AS TJ_PLANO,   " 	    + aTblQry[1][2] + "_TIPOOS AS TJ_TIPOOS,  " + aTblQry[1][2] + "_CODBEM AS TJ_CODBEM,  " + aTblQry[1][2] + "_SERVICO AS TJ_SERVICO, " + aTblQry[1][2] + "_CCUSTO AS TJ_CCUSTO, " + aTblQry[1][2] + "_CENTRAB AS TJ_CENTRAB, "
	cQueryBrw += "        " + aTblQry[1][2] + "_DTMPINI AS TJ_DTMPINI, " 	+ aTblQry[1][2] + "_DTMRINI AS TJ_DTMRINI, "	+ aTblQry[1][2] + "_SITUACA AS TJ_SITUACA, " + aTblQry[1][2] + "_DTORIGI AS TJ_DTORIGI, " + aTblQry[1][2] + "_TERMINO AS TJ_TERMINO, " + ValToSql(Space(8)) + " AS TJ_DTRESP, "
	cQueryBrw += "        " + aTblQry[2][2] + "_ORDEM AS TQ_ORDEM, " 		+ aTblQry[2][2] + "_PLANO AS TQ_PLANO, " 		+ aTblQry[2][2] + "_TAREFA AS TQ_TAREFA,  " + aTblQry[2][2] + "_ETAPA AS TQ_ETAPA, "
	cQueryBrw += 		  cSubstr +"(TPA.TPA_DESCRI, 1, 50) AS TPA_NOME, "
	cQueryBrw += "        TPC.TPC_CONDIN, TPC.TPC_CONDOP, TPC.TPC_DESOPC, "
	cQueryBrw += "        " + aTblQry[3][2] + "_RESPOS AS TPQ_RESPOS, " + aTblQry[3][2] + "_OPCAO AS TPQ_OPCAO "

	cQueryBrw += "	FROM   " +  RetSqlName(aTblQry[1][1]) + " " + aTblQry[1][1] + " "

	cQueryBrw += "	       INNER JOIN " +  RetSqlName("ST9") + " ST9 " // Consiste O.S x Bem
	cQueryBrw += "	               ON ( " + aTblQry[1][2] + "_CODBEM = ST9.T9_CODBEM ) "

	cQueryBrw += "	       INNER JOIN " +  RetSqlName(aTblQry[2][1]) + " " + aTblQry[2][1] + " " // Consiste existencia de etapas respondidas para a O.S.
	cQueryBrw += "	               ON ( " + aTblQry[1][2] + "_ORDEM || " + aTblQry[1][2] + "_PLANO = " + aTblQry[2][2] + "_ORDEM || " + aTblQry[2][2] + "_PLANO AND " + aTblQry[2][2] + "_OK <> '' ) "

	cQueryBrw += "	       INNER JOIN " +  RetSqlName(aTblQry[3][1]) + " " + aTblQry[3][1] + " " // Consiste opcoes das etapas respondidas
	cQueryBrw += "	               ON ( ( " + aTblQry[2][2] + "_ORDEM || " + aTblQry[2][2] + "_PLANO || " + aTblQry[2][2] + "_TAREFA || " + aTblQry[2][2] + "_ETAPA = " + aTblQry[3][2] + "_ORDEM || " + aTblQry[3][2] + "_plano || " + aTblQry[3][2] + "_TAREFA || " + aTblQry[3][2] + "_ETAPA ) "

	If MV_PAR09 == 2
		cQueryBrw += "	          AND ( " + aTblQry[3][2] + "_RESPOS <> '0' ) "
	Endif

	cQueryBrw += "	        ) "

	cQueryBrw += "	       INNER JOIN " +  RetSqlName("TPC") + " TPC " // Consiste opcoes das etapas respondidas
	cQueryBrw += "	               ON ( " + aTblQry[3][2] + "_ETAPA || " + aTblQry[3][2] + "_OPCAO = TPC.TPC_ETAPA || TPC.TPC_OPCAO AND TPC.TPC_TIPCAM = 'N' ) "

	cQueryBrw += "	       INNER JOIN " +  RetSqlName("TPA") + " TPA " // Consiste opcoes das etapas respondidas
	cQueryBrw += "	               ON ( TPA.TPA_ETAPA = " + aTblQry[3][2] + "_ETAPA ) "

	cQueryBrw += "	WHERE "

	cQueryBrw += "	  ( ST9.T9_CODBEM BETWEEN  " + ValToSql(MV_PAR03) + " AND " + ValToSql(MV_PAR04) + " ) "

	cQueryBrw += "        AND ( ST9.T9_CODFAMI BETWEEN " + ValToSql( MV_PAR07 ) + " AND " + ValToSql( MV_PAR08 ) + " ) " // Verifica Familia do Bem
	cQueryBrw += "        AND ( " + aTblQry[1][2] + "_PLANO BETWEEN   " + ValToSql( MV_PAR05 ) + " AND " + ValToSql( MV_PAR06 ) + " ) " // Verifica Plano da O.S.
	cQueryBrw += "        AND " + aTblQry[1][2] + "_SITUACA <> 'C' "

	cQueryBrw += "        AND ( ( " + aTblQry[1][2] + "_TERMINO  = 'S' AND  " + aTblQry[1][2] + "_DTMRINI BETWEEN " + ValToSql( aPerCon[1] ) + " AND " + ValToSql( aPerCon[2] ) + " ) OR " // Verifica data de realizacao da O.S., caso finalizada
	cQueryBrw += "              ( " + aTblQry[1][2] + "_TERMINO <> 'S' AND  " + aTblQry[1][2] + "_DTMPINI BETWEEN " + ValToSql( aPerCon[1] ) + " AND " + ValToSql( aPerCon[2] ) + " ) ) "  // Verifica data prevista da O.S., caso nao esteja finalizada

	cQueryBrw += "	       AND ST9.T9_FILIAL   = " + ValToSql( xFilial("ST9") )
	cQueryBrw += "	       AND " + aTblQry[1][2] + "_FILIAL   = " + ValToSql( xFilial(aTblQry[1][1]) )
	cQueryBrw += "	       AND " + aTblQry[2][2] + "_FILIAL   = " + ValToSql( xFilial(aTblQry[2][1]) )
	cQueryBrw += "	       AND " + aTblQry[3][2] + "_FILIAL   = " + ValToSql( xFilial(aTblQry[3][1]) )

	cQueryBrw += "	       AND ST9.D_E_L_E_T_ <> '*' "
	cQueryBrw += "	       AND " + aTblQry[1][1] + ".D_E_L_E_T_ <> '*' "
	cQueryBrw += "	       AND " + aTblQry[2][1] + ".D_E_L_E_T_ <> '*' "
	cQueryBrw += "	       AND " + aTblQry[3][1] + ".D_E_L_E_T_ <> '*' "

	cQueryBrw += "	ORDER BY ST9.T9_CODBEM, " + aTblQry[2][2] + "_ETAPA, " + aTblQry[3][2] + "_OPCAO, " + aTblQry[1][2] + "_ORDEM, " + aTblQry[1][2] + "_PLANO "

	cQueryBrw := ChangeQuery( cQueryBrw )
	MPSysOpenQuery( cQueryBrw , cAliasQry )

	dbSelectArea( cAliasQry )
	dbGoTop()
	While !Eof()

		dbSelectArea( cAliasQryBrw )
		dbSetOrder( 01 )
		If !dbSeek( (cAliasQry)->T9_CODBEM + (cAliasQry)->TQ_ETAPA + (cAliasQry)->TPQ_OPCAO + (cAliasQry)->TJ_ORDEM + (cAliasQry)->TJ_PLANO )
			RecLock( cAliasQryBrw,.T. )

			For nInd := 1 To ( cAliasQryBrw)->( FCount() )
				cFldQry := cAliasQry    + "->"  + ( (cAliasQryBrw)->(FieldName(nInd)) )
				cFldTrb := cAliasQryBrw + "->"  + ( (cAliasQryBrw)->(FieldName(nInd)) )
				Replace &cFldTrb With If( ValType(&cFldTrb) <> "D", &cFldQry, STOD(&cFldQry) )
			Next nInd

			(cAliasQryBrw)->TJ_DTRESP := STOD(If( (cAliasQryBrw)->TJ_TERMINO == 'S', ( cAliasQry)->TJ_DTMRINI,(cAliasQry)->TJ_DTMPINI ))

			(cAliasQryBrw)->(MsUnlock())
		Endif

		dbSelectArea( cAliasQry )
		(cAliasQry)->(dbSkip())

	End While

	(cAliasQry)->(dbCloseArea())

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} IncTrbAt
Função que incrementa alias do markbrowse.

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version	MP12
@return	Nil
/*/
//---------------------------------------------------------------------
Static Function IncTrbAt( cAliasQry )

	Local cKeyQryBem, cKeyQrEtp
	Local lBemCh, lEtpCh

	Store ""  To cKeyQryBem, cKeyQrEtp
	Store .F. To lBemCh, lEtpCh

	dbSelectArea(cAliasQry)
	dbGoTop()

	While (cAliasQry)->(!Eof())

		If ( lBemCh := ChangeKeyQry( 1, @cKeyQryBem, cAliasQry ) )
			IncTrbEsp("ST9", cAliasBem, cAliasQry, .T.)
		Endif

		If ( lEtpCh := ChangeKeyQry( 2, @cKeyQrEtp, cAliasQry, lBemCh ) )
			IncTrbEsp("STQ", cAliasEtp, cAliasQry, .T.)
		Endif

		IncTrbEsp("STJ", cAliasOS, cAliasQry, .T.)

		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbSkip())
	End

	dbSelectArea( cAliasQry )
	ZAP

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ChangeKeyQry
Função que carrega a chave a query.

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version	MP12
@return	lChanged
/*/
//---------------------------------------------------------------------
Static Function ChangeKeyQry( nType, cKeyQuery, cAliasQry, lCondic )

	Local lChanged := .F.
	Local cKeyAtu  := If( nType == 1,(cAliasQry)->T9_CODBEM,(cAliasQry)->TQ_ETAPA + (cAliasQry)->TPQ_OPCAO )

	Default lCondic := .F.

	// Caso a chave tenha sido alterada
	If ( lChanged := ( lCondic .Or. ( cKeyQuery <> cKeyAtu ) ) )
		cKeyQuery := cKeyAtu
	Endif

Return lChanged

//---------------------------------------------------------------------
/*/{Protheus.doc} IncTrbEsp
Função que incrementa alias do markbrowse.

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version	MP12
@return	Nil
/*/
//---------------------------------------------------------------------
Static Function IncTrbEsp( cTable, cAlias, cAliasQry, lVrf )

	Local nInd
	Local cFldQry, cFldTrb, cField

	Default lVrf := .F.

	dbSelectArea(cAliasQry)

	dbSelectArea(cAlias)
	If !lVrf .Or. !SeekKeyTrb(cAlias, cTable, cAliasQry)
		RecLock(cAlias, .T.)

		For nInd := 1 To (cAlias)->( FCount() )
			cFldQry := cAliasQry + "->"  + ( (cAlias)->(FieldName(nInd)) )
			cFldTrb := cAlias    + "->"  + ( (cAlias)->(FieldName(nInd)) )
			Replace &cFldTrb With &cFldQry
		Next nInd

		(cAlias)->(MsUnlock())
	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SeekKeyTrb
Função que seleciona a chave da tabela temporária

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version	MP12
@return	lRet
/*/
//---------------------------------------------------------------------
Static Function SeekKeyTrb( cAlias, cTable, cAliasQry )

	Local nIndOld := (cAlias)->(IndexOrd())
	Local lRet    := .F.

	dbSelectArea(cAlias)

	If cTable == "ST9"

		dbSetOrder(1)
		lRet := dbSeek( (cAliasQry)->TJ_CODBEM )

	ElseIf cTable == "STQ"

		dbSetOrder(2)
		lRet := dbSeek( (cAliasQry)->TJ_CODBEM + (cAliasQry)->TQ_ETAPA + (cAliasQry)->TPQ_OPCAO )

	Else
		lRet := .F.
	Endif

	dbSelectArea(cAlias)
	dbSetOrder(nIndOld)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} RetFldBrw
Função que retorna o folder que será carrgado em tela.

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version	MP12
@return	{ aFields, aFldTrb, aColumns }
/*/
//---------------------------------------------------------------------
Static Function RetFldBrw( cTable,aIndexes,cAliasTrb )

	Local nInd     := 0
	Local aArea    := GetArea()
	Local aColumns := {}
	Local aFields  := {}
	Local aFldTrb  := {}
	Local aFldEsp  := {}
	Local aFldBrw  := RetFldTbl( cTable )
	Local cCampo   := ""
	Local cArquivo := ""
	Local cTitulo  := ""
	Local cPicture := ""
	Local cTipo    := ""
	Local nTamanho := 0
	Local nDecimal := 0

	For nInd := 1 To Len( aFldBrw )
		cCampo   := aFldBrw[nInd,1]
		cArquivo := Posicione("SX3",2,cCampo,"X3_ARQUIVO")
		If !Empty( cArquivo ) .And. (cArquivo)->( FieldPos( cCampo ) ) > 0
			
			If cCampo == 'TPC_DESOPC'

				cTitulo := AllTrim( Posicione( 'SX3', 2, cCampo, 'X3Descric()' ) )

			Else

				cTitulo  := AllTrim( Posicione( 'SX3', 2, cCampo, 'X3Titulo()' ) )
			
			EndIf

			cPicture := X3Picture(cCampo)
			nTamanho := TAMSX3(cCampo)[1]
			nDecimal := TAMSX3(cCampo)[2]
			cTipo    := Posicione("SX3",2,cCampo,"X3_TIPO")
			SetFldTbl( cAliasTrb, { AllTrim(cCampo), cTipo, nTamanho, nDecimal, cPicture, cTitulo }, @aFields,@aFldTrb,@aColumns,aFldBrw[nInd] )
		Else
			aFldEsp := GetFldEsp( aFldBrw[nInd][1] )
			If !Empty( aFldEsp )
				SetFldTbl( cAliasTrb, { aFldEsp[1],aFldEsp[2],aFldEsp[3],aFldEsp[4],aFldEsp[5],aFldEsp[6] }, @aFields,@aFldTrb,@aColumns,aFldBrw[nInd] )
			Endif
		EndIf
	Next nInd

	RestArea( aArea )

Return { aFields, aFldTrb, aColumns }


//---------------------------------------------------------------------
/*/{Protheus.doc} SetFldEsp
Função que adiciona os campos "TJ_DTRESP" e "TPA_NOME" em browse.

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version	MP12
@return	aFldEsp
/*/
//---------------------------------------------------------------------
Static Function SetFldEsp()

	Local aFldEsp := {}

	aAdd( aFldEsp, { "TJ_DTRESP" , "D", 8  , 0, "99/99/9999" , "Dt. Resp." } )
	aAdd( aFldEsp, { "TPA_NOME"  , "C", 50 , 0, ""           , "Descrição" } )

Return aFldEsp


//---------------------------------------------------------------------
/*/{Protheus.doc} GetFldEsp
Função que carrega o folder específico.

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version	MP12
@return	If( nPosFld > 0, aFldEsp[nPosFld], {} )
/*/
//---------------------------------------------------------------------
Static Function GetFldEsp( cField )

	Local aFldEsp := SetFldEsp()
	Local nPosFld := 0

	nPosFld := aScan( aFldEsp, {|x| x[1] == cField } )

Return If( nPosFld > 0, aFldEsp[nPosFld], {} )

//---------------------------------------------------------------------
/*/{Protheus.doc} SetFldTbl
Seleciona o folder que será carregado em tela.

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version	MP12
@return	{ aFields, aFldTrb, aColumns }
/*/
//---------------------------------------------------------------------
Static Function SetFldTbl( cAliasTrb, aField, aFields, aFldTrb, aColumns, aFldBrw )

	Local bData := {|| }
	Local oColumn

	aAdd( aFields , aField[1] )
	aAdd( aFldTrb , { aField[1], aField[2], aField[3], aField[4] } )

	If Len(aFldBrw) < 2 .Or. aFldBrw[2]
		bData := & ( "{|| " + cAliasTrb + "->" + aField[1] + "}" )

		oColumn := FWBrwColumn():New()
		oColumn:SetData(bData)
		oColumn:SetEdit(.F.)
		oColumn:SetTitle( aField[6] )
		oColumn:SetType(aField[2])
		oColumn:SetSize(aField[3])
		oColumn:SetDecimal(aField[4])
		oColumn:SetPicture(aField[5])
		oColumn:SetAlign( If( aField[2] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT ) )

		aAdd( aColumns,oColumn )
	Endif

Return { aFields,aFldTrb,aColumns }

//---------------------------------------------------------------------
/*/{Protheus.doc} RetFldTbl
Função que retorna campos que serão carregados no browse;

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version 	MP12
@return 	aFldBrw
/*/
//---------------------------------------------------------------------
Static Function RetFldTbl( cTable )

	Local aFldBrw := {}

	If cTable == "ST9"

		aFldBrw := {	{ "T9_CODBEM" }, { "T9_NOME" }, { "T9_CCUSTO" }, { "T9_CODFAMI" }, { "T9_FORNECE" }, { "T9_LOJA" } }

	ElseIf cTable == "STQ"

		aFldBrw := { { "TPQ_OPCAO" }, { "TQ_ETAPA" }, { "TPA_NOME" }, { "TPC_DESOPC" }, { "T9_CODBEM", .F. }, { "TQ_ORDEM", .F.}, { "TQ_PLANO", .F.}, { "TPC_CONDOP", .F. }, { "TPC_CONDIN", .F. } }

	ElseIf cTable == "STJ"

		aFldBrw := { 	{ "TPQ_RESPOS" }, { "TJ_ORDEM" }, { "TJ_PLANO" }, { "TJ_SERVICO" }, { "TJ_DTORIGI" }, { "TJ_CODBEM", .F. }, { "TJ_TIPOOS", .F. }, ;
						{ "TJ_CCUSTO", .F. }  , { "TJ_CENTRAB", .F. } , { "TJ_SITUACA", .F. }, { "TJ_TERMINO", .F. }, { "TQ_ETAPA", .F.}, ;
						{ "TJ_DTMPINI", .F. } , { "TJ_DTMRINI", .F. } , { "TJ_DTRESP", .F. }, { "TPQ_OPCAO", .F. }, { "TQ_TAREFA", .F.} }

	ElseIf cTable == "Query"

		aFldBrw := {	{"T9_CODBEM"  , .F.} , {"T9_CCUSTO"  , .F.} , {"T9_CODFAMI" , .F.} , {"T9_NOME"    , .F.} , {"T9_FORNECE", .F.} , {"T9_LOJA"   , .F.} , ;
						{"TJ_ORDEM"   , .F.} , {"TJ_PLANO"   , .F.} , {"TJ_TIPOOS"  , .F.} , {"TJ_CODBEM"  , .F.} , {"TJ_SERVICO", .F.} , {"TJ_CCUSTO" , .F.} , ;
						{"TJ_CENTRAB" , .F.} , {"TJ_DTMPINI" , .F.} , {"TJ_DTMRINI" , .F.} , {"TJ_SITUACA" , .F.} , {"TJ_DTORIGI", .F.} , {"TJ_TERMINO", .F.} , ;
						{"TJ_DTRESP"  , .F.} , {"TQ_ORDEM"   , .F.} , {"TQ_PLANO"   , .F.} , {"TQ_TAREFA"  , .F.} , {"TQ_ETAPA"  , .F.} , {"TPA_NOME"  , .F.} , ;
						{"TPC_CONDIN" , .F.} , {"TPC_CONDOP" , .F.} , {"TPQ_RESPOS" , .F.} , { "TPC_DESOPC", .F.}, {"TPQ_OPCAO"  , .F.} }
	EndIf

Return aFldBrw

//---------------------------------------------------------------------
/*/{Protheus.doc} RetIndexTb
Função que monta os indíces da tabelas ST9/STJ e STQ.

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version 	MP12
@return 	Nil
/*/
//---------------------------------------------------------------------
Static Function RetIndexTb( cTable )

	Local aIndexes := {}

	If cTable == "ST9"

		aIndexes := {	{ "T9_CODBEM"            , STR0084 },; //"Bem"
						{ "T9_CCUSTO+T9_CODBEM"  , STR0085 },; //"Centro de Custo + Bem"
						{ "T9_CODFAMI+T9_CODBEM" , STR0086 },; //"Família + Bem"
						{ "T9_CODBEM+T9_NOME"    , STR0087 },; //"Bem + Descrição"
						{ "T9_FORNECE+T9_LOJA"   , STR0088 }}  //"Fornecedor + Loja"

	ElseIf cTable == "STJ"

		aIndexes := {	{ "TJ_ORDEM+TJ_PLANO+TJ_CODBEM+TQ_ETAPA+TPQ_OPCAO+DTOS(TJ_DTRESP)"   , STR0089 },; //"Ordem + Plano"
						{ "DTOS(TJ_DTRESP)+TJ_CODBEM+TQ_ETAPA+TPQ_OPCAO+TJ_ORDEM+TJ_PLANO"   , STR0090 },; //"Dt. Resposta"
						{ "TJ_TIPOOS+TJ_ORDEM+TJ_PLANO+TJ_CODBEM+TJ_SERVICO"       	         , STR0091 },; //"Tipo O.S. + Ordem + Plano"
						{ "TJ_PLANO+TJ_ORDEM+TJ_TIPOOS+TJ_CODBEM"                            , STR0092 },; //"Plano + Ordem + Tipo O.S."
						{ "TJ_SERVICO+TJ_TIPOOS+TJ_CODBEM"                                   , STR0093 },; //"Serviço + Tipo O.S."
						{ "TJ_CCUSTO+TJ_CENTRAB+TJ_SERVICO"                                  , STR0094 } } //"Centro de Custo + Centro de Trab. + Serviço"

	ElseIf cTable ==  "STQ"

		aIndexes := {	{ "TQ_ETAPA+TPQ_OPCAO+TQ_ORDEM+TQ_PLANO"           , STR0095 },; //"Etapa"
						{ "T9_CODBEM+TQ_ETAPA+TPQ_OPCAO+TQ_ORDEM+TQ_PLANO" , STR0096 } } //"Bem + Etapa"

	ElseIf cTable ==  "Query"

		aIndexes := {	{ "T9_CODBEM+TQ_ETAPA+TPQ_OPCAO+TJ_ORDEM+TJ_PLANO", STR0097 } } //"Bem + Etapa + Opcao + Ordem + Plano"

	EndIf

Return aIndexes

//---------------------------------------------------------------------
/*/{Protheus.doc} C410GRAPHIC
Função que monta a tela do gráfico.

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version 	MP12
@return 	Nil
/*/
//---------------------------------------------------------------------
Function C410GRAPHIC( oBrowseEtp )

	Local oFontUpN1 := TFont():New("Arial",,-14,,.T.)
	Local oFontUpN2 := TFont():New("Arial",,-12,,.F.)

	Local aSize	  := MsAdvSize(.F.)
	Local nLargura  := aSize[5]
	Local nAltura   := aSize[6]
	Local nPosIni   := aSize[7]

	Local aCpntsGrf := {}

	Private oGrafico

	dbSelectArea( cAliasBem )
	dbSelectArea( cAliasEtp )
	dbSelectArea( cAliasOS )

	aCpntsGrf := GetArrGrf()

	Define MsDialog oDlgGrf From nPosIni,0 To nAltura,nLargura Pixel Title STR0034 Color CLR_BLACK,CLR_WHITE //"Gráfico"

		oDlgBrw:lEscClose  := .F.
		oDlgBrw:lMaximized := .T.

		@ 05,005 Say OemToansi( STR0052 ) of oDlgGrf Pixel Font oFontUpN1 //"Bem:"
		@ 05,025 Say AllTrim((cAliasBem)->(T9_CODBEM)) + " - " + AllTrim((cAliasBem)->(T9_NOME)) Of oDlgGrf Pixel Font oFontUpN1

		@ 20,005 Say OemToansi( STR0053 ) of oDlgGrf Pixel Font oFontUpN2 Color CLR_GREEN //"Período:"
		@ 20,29 Say DTOC(aCpntsGrf[8][1]) + " à " + DTOC(aCpntsGrf[8][2]) Of oDlgGrf Pixel Font oFontUpN2 Color CLR_GREEN

		@ 28,005 Say OemToansi( STR0054 ) of oDlgGrf Pixel Font oFontUpN2 Color CLR_GREEN //"Métrica:"
		@ 28,028 Say AllTrim((cAliasEtp)->(TPC_CONDOP)) + " " + AllTrim((cAliasEtp)->TPC_CONDIN) Of oDlgGrf Pixel Font oFontUpN2 Color CLR_GREEN

		@ 42, 000 MsGraphic oGrafico Size nLargura/2,(nAltura/2)- 90 - nPosIni/2 Of oDlgGrf Pixel

		nLinBtn := (nAltura/2) - 30 - nPosIni/2
		nColBtn := nLargura/2

		@ nLinBtn, nColBtn - 305 Button "Zoom +" Size 38,12.5 Of oDlgGrf Pixel Action ( oGrafico:ZoomIn() )
		@ nLinBtn, nColBtn - 255 Button "Zoom -" Size 38,12.5 Of oDlgGrf Pixel Action ( oGrafico:ZoomOut() )

		@ nLinBtn, nColBtn - 205 Button STR0055 Size 42,12.5 Of oDlgGrf Pixel Action Processa( {|| C410VISOS(), STR0032 } ) //"Visualizar OS's"
		@ nLinBtn, nColBtn - 155 Button STR0056 Size 42,12.5 Of oDlgGrf Pixel Action C410PRINT() //"Imprimir"
		@ nLinBtn, nColBtn - 105 Button STR0057 Size 42,12.5 Of oDlgGrf Pixel Action GrafSavBmp( oGrafico ) //"Salvar"
		@ nLinBtn, nColBtn - 55  Button STR0030 Size 42,12.5 Of oDlgGrf Pixel Action oDlgGrf:End() //"Sair"

		LoadGraphic( oGrafico,aCpntsGrf )

	Activate MsDialog oDlgGrf Centered

	dbSelectArea( cAliasOS )
	dbGoTop()

	oBrowseEtp:Refresh()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} AttRngGrf
Função que retorna um array contendo os itens para serem carregados no
gráfico.

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version 	MP12
@return 	aRange
/*/
//---------------------------------------------------------------------
Static Function AttRngGrf( aRange,aPrdGrf )

	Local nValItem := Val( (cAliasOS)->TPQ_RESPOS )
	Local dDtItem  := (cAliasOS)->TJ_DTRESP

	aRange[1] := If( nValItem < aRange[1], nValItem, aRange[1] )
	aRange[2] := If( nValItem > aRange[2], nValItem, aRange[2] )

	aPrdGrf[1] := If( dDtItem < aPrdGrf[1], dDtItem, aPrdGrf[1] )
	aPrdGrf[2] := If( dDtItem > aPrdGrf[2], dDtItem, aPrdGrf[2] )

Return aRange

//---------------------------------------------------------------------
/*/{Protheus.doc} LoadGraphic
Função que monta o gráfico do gerencial.

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version 	MP12
@return 	Nil
/*/
//---------------------------------------------------------------------
Static Function LoadGraphic( oGrafico,aCpntsGrf )

	Local nInd
	Local aRange := { 0, 0 }
	Local cFiltro := ''

	Default aCpntsGrf := {}

	oGrafico:DelSerie(1)
	oGrafico:l3D := .F.

	oGrafico:SetMargins( 25,25,25,25 )

	dbSelectArea( cAliasEtp )

	dbSelectArea( cAliasOS )
	dbGoTop()

	If Empty( aCpntsGrf )
		
		cFiltro := RetFltOS()	
		dbSelectArea( cAliasOS )
		Set Filter To
		Set Filter To &cFiltro
		aCpntsGrf := GetArrGrf()
	
	Endif

	aItemsGrf := aClone( aCpntsGrf[6] )
	aRange    := aClone( aCpntsGrf[7] )

	oGrafico:SetTitle( aCpntsGrf[1] + " - " + aCpntsGrf[2] , , CLR_RED,A_CENTER, GRP_TITLE )
	oGrafico:SetTitle( "", STR0078 + aCpntsGrf[3] + " - " + aCpntsGrf[5] + "  |  " + aCpntsGrf[4], CLR_GREEN, A_LEFTJUST, GRP_TITLE  ) //"Etapa: "

	nSerie := oGrafico:CreateSerie(1, aCpntsGrf[4])

	If nSerie != GRP_CREATE_ERR

		For nInd := 1 To Len( aItemsGrf )
			oGrafico:Add( aItemsGrf[nInd][1],aItemsGrf[nInd][2],aItemsGrf[nInd][3],CLR_RED )
		Next nInd

		oGrafico:SetRangeY( aRange[1],aRange[2] )

		oGrafico:l3D := .T.
		oGrafico:l3D := .F.

		oGrafico:Refresh()

	Else
		ApMsgAlert( STR0080 ) //"Não foi possível gerar a consulta."
	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} GetArrGrf
Função que retorna o conteúdo que será utilizado para a montagem do gráfico.

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version 	MP12
@return 	{Array que será utilizado na montagem do gráfico}
/*/
//---------------------------------------------------------------------
Static Function GetArrGrf()

	Local aArea   := GetArea()
	Local aAreaOS := (cAliasOS)->(GetArea())

	Local aItemsGrf := {}
	Local aPrdGrf   := {}

	dbSelectArea( cAliasBem )
	dbSelectArea( cAliasEtp )

	dbSelectArea( cAliasOS )
	dbSetOrder( 02 )
	dbGoTop()

	aRange  := { 0, Val((cAliasOS)->TPQ_RESPOS) }
	aPrdGrf := { (cAliasOS)->TJ_DTRESP, (cAliasOS)->TJ_DTRESP }

	While !Eof()

		aAdd(aItemsGrf,{ 1, Val( (cAliasOS)->TPQ_RESPOS ), DTOC( (cAliasOS)->TJ_DTRESP ) } )
		AttRngGrf( @aRange, @aPrdGrf )

		(cAliasOS)->(dbSkip())
	End While

	RestArea(aAreaOS)
	RestArea(aArea)

Return { AllTrim((cAliasBem)->T9_CODBEM) , AllTrim((cAliasBem)->T9_NOME), ;
		 AllTrim((cAliasEtp)->TQ_ETAPA), AllTrim((cAliasEtp)->TPQ_OPCAO), AllTrim((cAliasEtp)->TPA_NOME), aItemsGrf, aRange, aPrdGrf }

//---------------------------------------------------------------------
/*/{Protheus.doc} C410PRINT
Função de impressão.

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version 	MP12
@return	Nil
/*/
//---------------------------------------------------------------------
Static Function C410PRINT()

	Local oDlgPrint, oRadOp
	Local nModoImp := 1
	Local lPrint   := .F.

	Local cImgPath := ""
	Local cPathBmp := Alltrim(GetNewPar( "MV_DIRACA","" ))
	Local cDirArq	 := GetTempPath()

	If Empty( cPathBmp )
		//"Parâmetro MV_DIRACA não está definido." ## //"Informe corretamente o parâmetro MV_DIRACA."
		ShowHelpDlg( STR0021, { STR0058 },1,{ STR0059 },1)
		Return
	EndIf

	Define MsDialog oDlgPrint From  0,0 TO 130,250 Title STR0060 Pixel //"Modo de Impressão"

	@ 12,08 Radio oRadOp Var nModoImp Items STR0061, STR0062 Size 70,15 Pixel OF oDlgPrint //"Tela" ## //"Impressora"

	Define SButton From 38,50 Type 1 Enable Of oDlgPrint Action Eval( {|| lPrint := .T., oDlgPrint:End()} ) Pixel
	Define SButton From 38,80 Type 2 Enable Of oDlgPrint Action oDlgPrint:End() Pixel

	Activate MsDialog oDlgPrint Centered

	If lPrint

		If !ExistDir( cDirArq )
			MakeDir( cDirArq )
		EndIf

		oPrintResp	:= TMSPrinter():New(OemToAnsi( STR0063 )) //"Respostas das Etapas do Bem"
		oPrintResp:SetLandScape()

		oGrafico:SaveToImage( "RespEtapasBem.BMP",cPathBmp,"BMP" )
		cImgPath := cPathBmp + "RespEtapasBem.BMP"
		Lin := 75

		oPrintResp:Line( lin,25,lin,3125 )

		Lin += 75

		oPrintResp:StartPage()

		cFileLogo := "lgrl" + SM0->M0_CODIGO + SM0->M0_CODFIL + ".bmp"
		If !File(cFileLogo)
			cFileLogo := "lgrl" + SM0->M0_CODIGO + ".bmp"
		EndIf

		If File(cFileLogo)
			oSend(oPrintResp, "SayBitmap", 100, 100, cFileLogo ,320, 120 )
		Endif

		oPrintResp:Say( lin + 20,1400,STR0064 ) //"Respostas de Etapas do Bem"
		oPrintResp:Say( lin + 45,2900,STR0065 + cValToChar(Date()) ) //"Data: "
		oPrintResp:Say( lin + 80,2900,STR0066 + Time() ) //"Hora: "

		lin += 150
		oPrintResp:Line( lin,25,lin,3125 )

		If File(cImgPath)
			oPrintResp:SayBitmap( lin + 100, 100, cImgPath, 3000, 2000 )
		Endif

		oPrintResp:EndPage()

		If nModoImp == 1
			oPrintResp:Preview()
		Else
			If oPrintResp:Setup()
				oPrintResp:Print()
			Endif
		Endif

		If File( cImgPath )
			Ferase( cImgPath )
		Endif

	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} C410VISOS
Lista as ordens de serviços.

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version 	MP12
@return 	Nil
/*/
//---------------------------------------------------------------------
Function C410VISOS()

	Local oColumn, oFWLayer, oPanelOS
	Local aFldCon  := { "TJ_ORDEM", "TJ_PLANO", "TS_TIPOOS", "TJ_CODBEM", "TJ_NOME", "TJ_DTORIGI" }
	Local aColCon  := {}
	Local aCoors   := FWGetDialogSize( oMainWnd ) // Retorna limites da tela para a construcao da tela
	Local aArea    := GetArea()
	Local aAreaOS  := (cAliasOS)->(GetArea())
	Local aAreaSTJ := STJ->(GetArea())
	Local cCampo   := ""
	Local cArquivo := ""
	Local cTitulo  := ""
	Local cPicture := ""
	Local cTipo    := ""
	Local nInd     := 0
	Local nTot     := 0
	Local nTamanho := 0
	Local nDecimal := 0

	Private oBrowse, oDlgBrw
	Private aOSBrw  := {}

	nTot := Len(aFldCon)
	For nInd := 1 To nTot
		cCampo   := aFldCon[nInd]
		cArquivo := Posicione("SX3",2,cCampo,"X3_ARQUIVO")
		If (cArquivo)->(FieldPos(cCampo)) > 0

			cTitulo  := AllTrim(Posicione("SX3",2,cCampo,"X3Titulo()"))
			cPicture := X3Picture(cCampo)
			nTamanho := TAMSX3(cCampo)[1]
			nDecimal := TAMSX3(cCampo)[2]
			cTipo    := Posicione("SX3",2,cCampo,"X3_TIPO")

			bData := & ( "{|| aOSBrw[oBrowse:nAt][" + cVALTOCHAR(nInd) + "] }" )

			oColumn := FWBrwColumn():New()
			oColumn:SetData(bData)
			oColumn:SetEdit(.F.)
			oColumn:SetTitle(cTitulo)
			oColumn:SetType(cTipo)
			oColumn:SetSize(nTamanho)
			oColumn:SetDecimal(nDecimal)
			oColumn:SetPicture(cPicture)
			oColumn:SetAlign(If(cTipo == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT))

			aAdd(aColCon,oColumn)

		EndIf
	Next nInd

	// Define conteudo a ser apresentado
	DbSelectArea( cAliasOS )
	dbSetOrder( 01 )
	dbGoTop()
	ProcRegua( 0 )
	While !Eof()

		IncProc( STR0031 ) //"Selecionando O.S. ..."

		dbSelectArea( "STJ" )
		dbSetOrder( 01 )
		If dbSeek( xFilial( "STJ" ) + (cAliasOS)->TJ_ORDEM )
			If aScan(aOSBrw, { |x| Trim(Upper(x[1])) == (cAliasOS)->TJ_ORDEM }) == 0
				aAdd( aOSBrw, { (cAliasOS)->TJ_ORDEM, STJ->TJ_PLANO, STJ->TJ_TIPOOS, STJ->TJ_CODBEM, NGSEEK("ST9",STJ->TJ_CODBEM,1,"T9_NOME"), STJ->TJ_DTORIGI })
			Endif
		Else
			dbSelectArea( "STS" )
			dbSetOrder( 01 )
			If dbSeek( xFilial( "STS" ) + (cAliasOS)->TJ_ORDEM )
				If aScan(aOSBrw, { |x| Trim(Upper(x[1])) == (cAliasOS)->TJ_ORDEM }) == 0
					aAdd( aOSBrw, { (cAliasOS)->TJ_ORDEM, STS->TS_PLANO, STS->TS_TIPOOS, STS->TS_CODBEM, NGSEEK("ST9",STS->TS_CODBEM,1,"T9_NOME"), STS->TS_DTORIGI })
				Endif
			Endif
		Endif

		(cAliasOS)->(dbSkip())

	End While

	DbSelectArea( cAliasOS )
	dbSelectArea( "STJ" )

	Define MsDialog oDlgBrw Title STR0024 From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel //"Ordens de Serviço"

		oDlgBrw:lEscClose := .F.

		oFWLayer := FWLayer():New()
		oFWLayer:Init(oDlgBrw)

		oFWLayer:AddLine("LineOS", 100, .F.)

		oFWLayer:AddCollumn("ColumnOS", 100, .F., "LineOS")
		oPanelOS := oFWLayer:GetColPanel("ColumnOS", "LineOS")

		oBrowse := FWFormBrowse():New()

		oBrowse:SetDescription( STR0024 ) //"Ordens de Serviço"
		oBrowse:SetOwner(oPanelOS)
		oBrowse:SetMenuDef("")

		oBrowse:SetDataArray(.T.)
		oBrowse:DisableDetails(.F.)
		oBrowse:SetArray(aOSBrw)

		oBrowse:SetLocate()
		oBrowse:SetColumns(aColCon)

		oBrowse:AddButton( STR0027, {|| C410OPCAO( 3, aOSBrw[oBrowse:nAt][1], aOSBrw[oBrowse:nAt][2] ), } ,, 4 ,, .F. ) //"Etapas"
		oBrowse:AddButton( STR0028, {|| C410OPCAO( 1, aOSBrw[oBrowse:nAt][1], aOSBrw[oBrowse:nAt][2] ), } ,, 4 ,, .F. ) //"Detalhes"
		oBrowse:AddButton( STR0029, {|| C410OPCAO( 2, aOSBrw[oBrowse:nAt][1], aOSBrw[oBrowse:nAt][2] ), } ,, 4 ,, .F. ) //"Visual."
		oBrowse:AddButton( STR0030, {|| oDlgBrw:End() } ,, 4 ,, .F. ) //"Sair"

		oBrowse:Activate()

	Activate MsDialog oDlgBrw Center

	RestArea(aAreaSTJ)
	RestArea(aAreaOS)
	RestArea(aArea)

Return


//---------------------------------------------------------------------
/*/{Protheus.doc} C410OPCAO
Lista as opções das ordens de serviços.

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version 	MP12
@return 	Nil
/*/
//---------------------------------------------------------------------
Function C410OPCAO( nOpc,cOrdem,cPlano )

	Local aArea    := GetArea()
	Local aAreaSTJ := STJ->(GetArea())
	Local cOrdTbl	 := ""
	Local cPlnTbl  := ""

	Private cCadastro := STR0024 //"Ordens de Serviço"
	Private aRotina   := {	{ " " , " "    , 0 , 1 }    ,;
								{ " " , " "    , 0 , 2 }    ,;
								{ " " , " "    , 0 , 3 }    ,;
								{ " " , " "    , 0 , 4 , 0 },;
								{ " " , " "    , 0 , 5 , 3 } }

	If !Empty( cOrdem )

		dbSelectArea( "STJ" )
		dbSetOrder( 01 )
		If dbSeek( xFilial( "STJ" ) + cOrdem + cPlano )
			cOrdTbl := STJ->TJ_ORDEM
			cPlnTbl := STJ->TJ_PLANO
		Else
			dbSelectArea( "STS" )
			dbSetOrder( 01 )
			If dbSeek( xFilial( "STS" ) + cOrdem + cPlano )
				cOrdTbl := STS->TS_ORDEM
				cPlnTbl := STS->TS_PLANO
			Endif
		Endif

		If !Empty( cOrdTbl )

			If nOpc == 1
				C410DETOS( cOrdTbl, cPlnTbl ) //Detalhes
			ElseIf nOpc == 2
				NGCAD01( Alias(), Recno(), 2 ) //Visualizar
			Else
				C410ETAPAS( cOrdTbl, cPlnTbl ) //Etapas
			Endif

		Else
			//"Atenção" ## //"Ordem de Serviço não encontrada." ## //"Verifique a O.S. selecionada."
			ShowHelpDlg( STR0021, { STR0025 },1,{ STR0026 },1)
		Endif

	Endif

	RestArea( aAreaSTJ )
	RestArea( aArea )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} C410DETOS
Função que monta a tela de detalhes das ordens de serviços.

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version 	MP12
@return	Nil
/*/
//---------------------------------------------------------------------
Static Function C410DETOS( cOrdem,Plano )

	Local olddetalhe
	Local cFiltro := ""

	Private cCadastro := OemtoAnsi( STR0039 ) //"Detalhes da Ordem de Serviço"
	Private aBrwTbl   := {}

	aTROCAF3   := {}
	olddetalhe := aCLONE( aROTINA )
	aRotina    := {{ STR0036, "AXPesqui"			, 0, 1},; //"Pesquisar"
	               { STR0037, "MNT410VIS( aBrwTbl )", 0, 2}}  //"Visualizar"

	M->TJ_ORDEM := cOrdem
	M->TJ_PLANO := Plano

	aBrwTbl := { "STL","STL->TL" }

	cFiltro :=  aBrwTbl[2] + "_FILIAL == '" + xFilial(aBrwTbl[1]) + "' .AND. " + aBrwTbl[2] + "_ORDEM == M->TJ_ORDEM .AND. " + aBrwTbl[2] + "_PLANO == M->TJ_PLANO"
	NGNewMBrw( aBrwTbl[1], cFiltro, 1 , aRotina)

	DbSelectArea( aBrwTbl[1] )
	DbSetOrder( 01 )

	aRotina  := aCLONE( olddetalhe )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT410VIS
Função que monta a tela de visualização dos detalhes da ordem de serviço.

@author	Elynton Fellipe Bazzo
@since		13/05/2015
@version	MP12
@return 	Nil
/*/
//---------------------------------------------------------------------
Function MNT410VIS( aBrwTbl )

	Local nPos   := At( ">", aBrwTbl[2] ) + 1
	Local cCpoNm := SubStr( aBrwTbl[2], nPos, Len( aBrwTbl[2] ) - nPos )

	aTROCAF3 := {}

	If STL->TL_TIPOREG == "M"
	   AADD(aTROCAF3,{aBrwTbl[2] + "_CODIGO", "ST1"})
	ElseIf STL->TL_TIPOREG == "E"
	   AADD(aTROCAF3,{aBrwTbl[2] + "_CODIGO", "ST0"})
	ElseIf STL->TL_TIPOREG == "P"
	   AADD(aTROCAF3,{aBrwTbl[2] + "_CODIGO", "SB1"})
	ElseIf STL->TL_TIPOREG == "T"
	   AADD(aTROCAF3,{aBrwTbl[2] + "_CODIGO", "SA2"})
	ElseIf STL->TL_TIPOREG == "F"
	   AADD(aTROCAF3,{aBrwTbl[2] + "_CODIGO", "SH4"})
	Endif

	lCORRET := Val( &( aBrwTbl[2] + "_PLANO" ) ) == 0

	If lCORRET .And. NGUSATARPAD()
		aAdd(aTrocaF3,{aBrwTbl[2] + "_TAREFA","TT9"})
	EndIf

	NGCAD01( aBrwTbl[1],Recno(),2 )

	DbSelectArea( aBrwTbl[1] )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} C410ETAPAS
Função que monta a tela de etapas.

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version 	MP12
@return 	Nil
/*/
//---------------------------------------------------------------------
Static Function C410ETAPAS( cOrdem,Plano )

	Private cCadastro := OemtoAnsi( STR0035 ) //"Etapas O. S. Manutenção"
	Private aBrwTbl   := {}

	OLDETAPAS := aCLONE( aROTINA )
	aROTINA   := {{ STR0036, "AXPesqui"  , 0 , 1},; //"Pesquisar"
	              { STR0037, "NGCAD01"   , 0 , 2},; //"Visualizar"
	              { STR0038, "C410EOP( aBrwTbl )" , 0 , 4} } //"Opções"

	M->TJ_ORDEM := cOrdem
	M->TJ_PLANO := Plano

	aBrwTbl := { "STQ", "STQ->TQ" }

	DbSelectArea(aBrwTbl[1])
	DbSetOrder(01)

	bWHILE := {|| !Eof() .And. &( aBrwTbl[2] + "_ORDEM" ) == M->TJ_ORDEM .And. &( aBrwTbl[2] +  "_PLANO" ) == M->TJ_PLANO}

	bFOR   := {|| &( aBrwTbl[2] + "_FILIAL" ) == xFilial(aBrwTbl[1]) .And. &( aBrwTbl[2] + "_ORDEM" ) == M->TJ_ORDEM .And. ;
					&( aBrwTbl[2] + "_PLANO" )  == M->TJ_PLANO}

	NGCONSULTA("TRBQ", M->TJ_ORDEM + M->TJ_PLANO, bWHILE, bFOR, aRotina,{})

	DbSelectArea( aBrwTbl[1] )
	DbSetOrder( 01 )

	aRotina := aCLONE( oldetapas )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} C410EOP
Opções das etapas da manutenção.

@author 	Elynton Fellipe Bazzo
@since		06/05/2015
@version 	MP12
@return	.T.
/*/
//---------------------------------------------------------------------
Function C410EOP( aBrwEtp )

	Local cAliasOld	:= Alias()
	Local cAliasOE	:= GetNextAlias()
	Local lShowDlg	:= .T.
	Local aBrwOpc	:= { "TPQ","TPQ->TPQ" }

	Local oDlgOE, oTempOE, oListOE, oPnlOE
	Local aFields  := {}

	M->TQ_ORDEM  := &( aBrwEtp[2] + "_ORDEM"  )
	M->TQ_PLANO  := &( aBrwEtp[2] + "_PLANO"  )
	M->TQ_TAREFA := &( aBrwEtp[2] + "_TAREFA" )
	M->TQ_ETAPA  := &( aBrwEtp[2] + "_ETAPA"  )

	aAdd( aFields , { "OPCAO" , "C" , 15 , 0 } )
	aAdd( aFields , { "TIPOO" , "C" , 10 , 0 } )
	aAdd( aFields , { "CONDO" , "C" , 10 , 0 } )
	aAdd( aFields , { "ETAPA" , "C" , 06 , 0 } )
	aAdd( aFields , { "ORDEM" , "C" , 06 , 0 } )
	aAdd( aFields , { "PLANO" , "C" , 06 , 0 } )
	aAdd( aFields , { "TAREFA", "C" , 06 , 0 } )
	aAdd( aFields , { "RESPO" , "C" , 10 , 0 } )
	aAdd( aFields , { "PAREC" , "C" , 10 , 0 } )

	oTempOE:= FWTemporaryTable():New( cAliasOE, aFields )
	oTempOE:AddIndex( "1", {"ETAPA","OPCAO"} )
	oTempOE:Create()

	DbSelectArea( "TPC" )
	dbSetOrder( 01 )
	dbSeek( xFilial( "TPC" ) + M->TQ_ETAPA )
	While !Eof() .And. TPC->TPC_FILIAL = xFilial( "TPC" ) .And. TPC->TPC_ETAPA == M->TQ_ETAPA
	   RecLock( cAliasOE,.T. )
	   (cAliasOE)->ORDEM  := M->TQ_ORDEM
	   (cAliasOE)->PLANO  := M->TQ_PLANO
	   (cAliasOE)->TAREFA := M->TQ_TAREFA
	   (cAliasOE)->ETAPA  := TPC->TPC_ETAPA
	   (cAliasOE)->OPCAO  := TPC->TPC_OPCAO
	   (cAliasOE)->TIPOO  := If( TPC->TPC_TIPRES = "I",STR0042,STR0043 ) //"Informar" ## //"Marcar"
	   (cAliasOE)->CONDO  := TPC->TPC_CONDIN
	   (cAliasOE)->(MsUnLock())

	   dbSelectArea( "TPC" )
	   dbSkip()
	End While

	dbSelectArea( cAliasOE )
	DbGotop()

	dbSelectArea( aBrwOpc[1] )
	dbSetOrder( 01 )
	dbSeek( xFilial( aBrwOpc[1] ) + M->TQ_ORDEM + M->TQ_PLANO + M->TQ_TAREFA + M->TQ_ETAPA )

	While !Eof() .And. &( aBrwOpc[2] + "_FILIAL" ) = xFilial(aBrwOpc[1]) .And. ;
		&( aBrwOpc[2] + "_ORDEM" ) == M->TQ_ORDEM .And. &( aBrwOpc[2] + "_PLANO" ) == M->TQ_PLANO .And. ;
		&( aBrwOpc[2] + "_TAREFA" ) == M->TQ_TAREFA .And. &( aBrwOpc[2] + "_ETAPA" ) == M->TQ_ETAPA

		dbSelectArea( cAliasOE )
		If dbSeek( &( aBrwOpc[2] + "_ETAPA" ) + &( aBrwOpc[2] + "_OPCAO" ) )

			Reclock( cAliasOE,.F. )
			(cAliasOE)->ORDEM  := &( aBrwOpc[2] + "_ORDEM"  )
			(cAliasOE)->PLANO  := &( aBrwOpc[2] + "_PLANO"  )
			(cAliasOE)->TAREFA := &( aBrwOpc[2] + "_TAREFA" )
			(cAliasOE)->RESPO  := &( aBrwOpc[2] + "_RESPOS" )
			(cAliasOE)->PAREC  := If( Empty((cAliasOE)->RESPO), STR0040, STR0041 ) //"Marcou" ## //"Informou"
			(cAliasOE)->(MsUnlock())

		EndIf
		dbSelectArea( aBrwOpc[1] )
		DbSkip()
	End While

	dbSelectArea( cAliasOE )
	DbGotop()
	If Reccount() == 0
	   ShowHelpDlg( STR0021, { STR0045 }, 1,{ STR0044 }, 1) //"Não existem opções para a etapa selecionada." ## //"Verique a etapa selecionada."
	   lShowDlg := .F.
	EndIf

	If lShowDlg
		Define MsDialog oDlgOE Title STR0046 + AllTrim( M->TQ_ETAPA ) + " - " ; //"Opção Resposta Etapa..: "
			+ NGSEEK("TPA",M->TQ_ETAPA,1,"Alltrim(SUBSTR(TPA->TPA_DESCRI,1,30))") + "   O.S..: " + ;
			M->TQ_ORDEM From 0,0 To 400,600 Pixel Of oMainWnd

			oPnlOE := TPanel():New(01,01,,oDlgOE,,,,CLR_BLACK,CLR_WHITE,100,100)
			oPnlOE:Align := CONTROL_ALIGN_ALLCLIENT

				@ 0,0 Listbox oListOE Fields OPCAO	,;
												 TIPOO	,;
												 CONDO	,;
												 PAREC	,;
												 RESPO	;
												 FieldSizes 30,25,50,35,50	;
												 Size 100,100	;
												 HEADERS STR0047	,; //"Opção"
												 STR0048			,; //"Tipo"
												 STR0049			,; //"Base Comp."
												 STR0050			,; //"Tipo Retorno"
												 STR0051			,; //"Resposta"
												 Of oPnlOE

				oListOE:Align := CONTROL_ALIGN_ALLCLIENT

		Activate MsDialog oDlgOE On Init EnchoiceBar( oDlgOE, {|| nopins := 1, oDlgOE:End() }, {|| oDlgOE:End() }) Centered
	EndIf

	oTempOE:Delete() //Exclui a tabela temporária.

	dbSelectArea( cAliasOld )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT410ST9
Consiste os parâmetros De/Até - Bem.

@author	Elynton Fellipe Bazzo
@since		06/05/2015
@version 	MP11
@return	lRet
/*/
//---------------------------------------------------------------------
Function MNT410ST9( nType )

	Local aArea	:= GetArea()
	Local lRet		:= .T.

	If nType == 1 //"De Bem"
		lRet := Empty( mv_par03 ) .Or. Existcpo( 'ST9',mv_par03 )
	ElseIf nType == 2 //"Até Bem"
		lRet := AteCodigo( 'ST9',mv_par03,mv_par04 )
	EndIf

	RestArea( aArea )

Return lRet
