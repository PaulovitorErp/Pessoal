#INCLUDE "Protheus.ch"
#INCLUDE "FWBrowse.ch"
#INCLUDE "MNTC420.ch"
#INCLUDE "RWMake.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC420
Consulta dos Equipamentos com Menor Disponibilidade.

@author	Elynton Fellipe Bazzo
@since		29/05/2015
@return	.T.
/*/
//---------------------------------------------------------------------
Function MNTC420()

	//------------------------------
	// Armazena as variáveis
	//------------------------------
	Local aNGBEGINPRM := NGBEGINPRM( )

	// Variáveis do Dialog
	Private oDlgRank
	Private oPnlRank
	Private aSize := MsAdvSize( .F. ) // .T. - Tem EnchoiceBar

	// Variáveis PRIVATE
	MNT420VR()

	// F4: Pergunta
	SETKEY( VK_F4, {|| fAskSX1() })

	//--------------------
	// Monta o Dialog
	//--------------------
	DEFINE MSDIALOG oDlgRank TITLE cCadastro FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL

		// Não permite fechar a janela através da tecla <ESC>
		oDlgRank:lEscClose := .F.

		// Painél principal do Dialog
		oPnlRank := TPanel():New(01, 01, , oDlgRank, , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
		oPnlRank:Align := CONTROL_ALIGN_ALLCLIENT

		// Monta o Layout
		oLayerRank := FWLayer():New()
		oLayerRank:Init(oPnlRank, .F.)
		fLayout()

	ACTIVATE MSDIALOG oDlgRank ON INIT ( fAskSX1() ) CENTERED

	//------------------------------
	// Devolve as variáveis armazenadas
	//------------------------------
	NGRETURNPRM( aNGBEGINPRM )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT420VR
Declara as variáveis Private utilizadas no Painél de Indicadores.
* Lembrando que essas variáveis ficam declaradas somente para a função
que é Pai imediata desta.

@author	Elynton Fellipe Bazzo
@since		29/05/2015
@return	.T.
/*/
//---------------------------------------------------------------------
Static Function MNT420VR()


	//------------------------------
	// Declara Variáveis PRIVATE
	//------------------------------

	// Variável do Cadastro
	_SetOwnerPrvt( "cCadastro",OemToAnsi( STR0001 )) //"Consulta de Equipamentos com Menor Disponibilidade"

	// Variável da Pergunta
	_SetOwnerPrvt( "cPerg","MNT420" )
	_SetOwnerPrvt( "nQtdEquips",20 )

	// Variáveis dos Objetos do Layout
	_SetOwnerPrvt( "oLayerRank", Nil ) // FWLayer
	_SetOwnerPrvt( "oPnlLista" , Nil ) // Painél da 'Lista' (Janela)
	_SetOwnerPrvt( "oPnlBrowse", Nil ) // Painél do objeto do Browse
	_SetOwnerPrvt( "oPnlGrafi" , Nil ) // Painél do 'Gráfico' (Janela)
	_SetOwnerPrvt( "oPnlChart" , Nil ) // Painél do objeto do Gráfico

	// Variáveis do Browse
	_SetOwnerPrvt( "oRankBrw", Nil )
	_SetOwnerPrvt( "nBrwNUMERO", 1 ) // Posição da coluna 'Número'
	_SetOwnerPrvt( "nBrwEQUIPA", 2 ) // Posição da coluna 'Equipamento'
	_SetOwnerPrvt( "nBrwLOCALI", 3 ) // Posição da coluna 'Localização'
	_SetOwnerPrvt( "nBrwDISPON", 4 ) // Posição da coluna 'Disponibilidade'
	_SetOwnerPrvt( "nBrwDESCLO", 5 ) // Posição da coluna 'Descrição da Localização'
	_SetOwnerPrvt( "nBrwEXTERN", 6 ) // Posição da coluna 'Externo'

	// Variável do Gráfico
	_SetOwnerPrvt( "oRankGrf", Nil)

	// Variável que indica a Média Geral de disponibilidade
	_SetOwnerPrvt( "oMedGeral", Nil )
	_SetOwnerPrvt( "nMedGeral", 0.0 )

	// Variável que indica a Meta de disponibilidade
	_SetOwnerPrvt( "nTotNMeta", 0.0 )
	_SetOwnerPrvt( "oTotNMeta", Nil )
	_SetOwnerPrvt( "nTotPorce", 0.0 )
	_SetOwnerPrvt( "oTotPorce", Nil )
	_SetOwnerPrvt( "\", 0.0 ) // Total de Equipamentos abaixo da meta

	//------------------------------
	// Define conteúdos
	//------------------------------

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fLayout
Monta o layout da tela.

@author	Elynton Fellipe Bazzo
@since		01/06/2015
@return	.T.
/*/
//---------------------------------------------------------------------
Static Function fLayout()

	// Linhas
	oLayerRank:AddLine( "Linha_Consulta",100,.F./*lFixed*/ )

	// Colunas
	oLayerRank:AddCollumn( "Coluna_Consulta",100,.F./*lFixed*/,"Linha_Consulta" )

	// Janela da Lista - "Lista dos Equipamentos com Menor Disponibilidade no Período"
	oLayerRank:AddWindow( "Coluna_Consulta", "Janela_Lista", STR0002, 50,;
						.T./*lEnable*/, .F./*lFixed*/, {|| fProcessa(.F.) }/*bAction*/, "Linha_Consulta", /*bGotFocus*/)

	// Janela do Gráfico - "Gráfico dos Equipamentos com Menor Disponibilidade no Período"
	oLayerRank:AddWindow( "Coluna_Consulta", "Janela_Grafico",STR0003, 45,;
						.T./*lEnable*/, .F./*lFixed*/, {|| fProcessa(.F.) }/*bAction*//*bAction*/, "Linha_Consulta", /*bGotFocus*/)

	// Objetos
	oPnlLista := oLayerRank:GetWinPanel( "Coluna_Consulta","Janela_Lista"  ,"Linha_Consulta" )
	oPnlGrafi := oLayerRank:GetWinPanel( "Coluna_Consulta","Janela_Grafico","Linha_Consulta" )

	//--- Monta a Consulta
	fMontaCons()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fMontaCons
Monta a Consulta.

@author	Elynton Fellipe Bazzo
@since		01/06/2015
@return	.T.
/*/
//---------------------------------------------------------------------
Static Function fMontaCons()

	// Variáveis auxiliares
	Local oPnlBrw
	Local oPnlGrf

	//----------
	// Monta
	//----------
	// Painél do Browse
	oPnlBrw := TPanel():New(01, 01, , oPnlLista, , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
	oPnlBrw:Align := CONTROL_ALIGN_ALLCLIENT
	oPnlBrw:CoorsUpdate()

	// Monta o Browse
	fMontaBrw( oPnlBrw )

	// Painél do Gráfico
	oPnlGrf := TPanel():New(01, 01, , oPnlGrafi, , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
	oPnlGrf:Align := CONTROL_ALIGN_ALLCLIENT
	oPnlGrf:CoorsUpdate()

	// Monta Gráfico
	fMontaGrf( oPnlGrf )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fMontaBrw
Monta o Browse.

@author	Elynton Fellipe Bazzo
@since		01/06/2015
@param		oObjPai - Indica o Objeto Pai * Obrigatório
@return	.T.
/*/
//---------------------------------------------------------------------
Static Function fMontaBrw( oObjPai )

	// Variáveis auxiliares
	Local oPnlPai
	Local oPnlMed

	Local aHeader := {}, nHeader := 0
	Local aColunas := {}, oColuna
	Local cArrTitulo := ""
	Local cArrTipo   := ""
	Local nArrTamanh := 0
	Local nArrDecima := 0
	Local cArrPictur := ""
	Local aBrowse    := {}

	Local oFntPDBold := TFont():New( , , , , .T.)
	
	//--- Cabeçalho do Browse
	aAdd(aHeader, { STR0004, "N", 3, 0, "@E 999"}) // Coluna 1 - "Número"
	aAdd(aHeader, { STR0005, "C", TAMSX3("T9_CODBEM")[1], 0, PesqPict("ST9", "T9_CODBEM", )}) // Coluna 2 - "Equipamento"
	aAdd(aHeader, { STR0006, "C", TAMSX3("TC_CODBEM")[1], 0, PesqPict("STC", "TC_CODBEM", )}) // Coluna 3 - "Localização"
	aAdd(aHeader, { STR0007, "N", 10, 0, "@E 999.99"}) // Coluna 4 - "Disponibilidade (%)"
	aAdd(aHeader, { STR0008, "C", TAMSX3("T9_NOME")[1], 0, PesqPict("ST9", "T9_NOME", )}) // Coluna 5 - "Descrição da Localização"
	aAdd(aHeader, { STR0009, "C", 01, 0, "@!"}) // Coluna 6 - "Externo"

	//----------
	// Monta
	//----------
	// Painél pai dos objetos
	oPnlPai := TPanel():New(01, 01, , oObjPai, , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
	oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT
	oPnlPai:CoorsUpdate()

	// Painél do Browse
	oPnlBrowse := TPanel():New(01, 01, , oPnlPai, , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
	oPnlBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	// Browse
	oRankBrw := FWBrowse():New()
	oRankBrw:SetOwner(oPnlBrowse)
	oRankBrw:SetDataArray()

	oRankBrw:SetLocate()
	oRankBrw:SetDelete(.F., {|| .F.})
	oRankBrw:DisableReport()
	oRankBrw:DisableConfig()

	aColunas := {}
	aBrowse  := { Array(Len(aHeader)) }
	For nHeader := 1 To Len(aHeader)
		cArrTitulo := aHeader[nHeader][1]
		cArrTipo   := aHeader[nHeader][2]
		nArrTamanh := aHeader[nHeader][3]
		nArrDecima := aHeader[nHeader][4]
		cArrPictur := aHeader[nHeader][5]

		oColuna := FWBrwColumn():New()
		oColuna:SetAlign( If(cArrTipo == "N", CONTROL_ALIGN_RIGHT, CONTROL_ALIGN_LEFT) )

		cSetData := "{|oFWBrowse| fBrwSetData(oFWBrowse, " + cValToChar( nHeader ) + " ) }"
		oColuna:SetData( &(cSetData) )

		oColuna:SetEdit( .F. )
		oColuna:SetSize( nArrTamanh + nArrDecima )
		oColuna:SetTitle( cArrTitulo )
		oColuna:SetType( cArrTipo )
		oColuna:SetPicture( cArrPictur )
		oColuna:SetHeaderClick({||  }) // Desabilita o clique no cabeçalho

		aAdd(aColunas, oColuna)

		aBrowse[1][nHeader] := If(cArrTipo == "N", 0, If(cArrTipo == "D", CTOD(""), " "))
	Next nHeader
	oRankBrw:SetColumns(aColunas)
	oRankBrw:Activate()
	oRankBrw:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oRankBrw:SetArray(aBrowse)
	oRankBrw:Refresh()

	// Painél da Média
	oPnlMed := TPanel():New(01, 01, , oPnlPai, , , , CLR_BLACK, CLR_WHITE, 100, 15, .F., .F.)
	oPnlMed:Align := CONTROL_ALIGN_BOTTOM

	// Média Geral
	@ 002,010 SAY OemToAnsi( STR0010 ) FONT oFntPDBold OF oPnlMed PIXEL //"Média Geral:"
	oMedGeral := TSay():New(002, 050, {|| nMedGeral }, oPnlMed, , , , , ,.T., CLR_BLACK, CLR_WHITE, 150, 010)

	// Total Equipamentos com Menor Disponibilidade
	@ 002,100 SAY OemToAnsi( STR0011 + "     %: " ) FONT oFntPDBold OF oPnlMed PIXEL //"Total de Equipamentos com disponibilidade menor que "
	oTotPorce := TSay():New(002, 254, {|| nTotPorce }, oPnlMed, , , , , ,.T., CLR_BLACK, CLR_WHITE, 150, 010)
	oTotNMeta := TSay():New(002, 275, {|| nTotNMeta }, oPnlMed, , , , , ,.T., CLR_BLACK, CLR_WHITE, 150, 010)

	//"Parâmetros"
	oButPart := TButton():New(002, 565, STR0042,oPnlMed,{|| Processa({|| fAskSX1() })}, 50, 12,,,,.T.)

	//"Sair"
	oButEnd  := TButton():New(002, 505, STR0043,oPnlMed,{|| Processa({|| oDlgRank:End() })}, 50, 12,,,,.T.)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fBrwSetData
Seta a data do registro do browse.

@author	Elynton Fellipe Bazzo
@since		01/06/2015
@param		oFWBrowse - Indica o objeto do FWBrowse * Obrigatório
@param		nHeader - Indica a posição do cabeçalho * Obrigatório
@return	uSetData
/*/
//---------------------------------------------------------------------
Static Function fBrwSetData( oFWBrowse,nHeader )

	// Variáveis auxiliares
	Local nAT      := oFWBrowse:AT()
	Local aBrowse  := oFWBrowse:Data():GetArray()
	Local uSetData := Nil

	// Data
	If nAT <= Len(aBrowse)
		uSetData := aBrowse[nAT][nHeader]
	EndIf

Return uSetData

//---------------------------------------------------------------------
/*/{Protheus.doc} fMontaGrf
Monta o Gráfico.

@author	Elynton Fellipe Bazzo
@since		01/06/2015
@param		oObjPai - Indica o Objeto Pai * Obrigatório
@return	.T.
/*/
//---------------------------------------------------------------------
Static Function fMontaGrf( oObjPai )

	// Variáveis auxiliares
	Local oPnlPai

	//----------
	// Monta
	//----------
	// Painél pai dos objetos
	oPnlPai := TPanel():New(01, 01, , oObjPai, , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
	oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT
	oPnlPai:CoorsUpdate()

	// Painél do Gráfico
	oPnlChart := TPanel():New(01, 01, , oPnlPai, , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
	oPnlChart:Align := CONTROL_ALIGN_ALLCLIENT

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fAskSX1
Realiza a Pergunta ('Pergunte()').

@author	Elynton Fellipe Bazzo
@since	01/06/2015
@return	.T.
/*/
//---------------------------------------------------------------------
Static Function fAskSX1()

	If Pergunte( cPerg,.T. )
		MsgRun( STR0034,STR0035, {|| fProcessa() }) //"Processando Consulta..." - "Por favor, aguarde..."
	Endif

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT420DT
Validação da Pergunta: De/Até Data.

@author	Elynton Fellipe Bazzo
@since		29/05/2015
@param		nDeAte - Indica qual é a validação: * Obrigatório
				1 - Pergunta 'De'
	   			2 - Pergunta 'Até'

@return lRetorno
/*/
//---------------------------------------------------------------------
Function MNT420DT( nDeAte )

	// Variável do Retorno
	Local lRetorno := .T.

	//----------
	// Valida
	//----------
	If nDeAte == 1 // 'De'

		If Empty( MV_PAR01 )
			Help( Nil,Nil,STR0032,Nil,STR0036,1,0 ) //"Atenção" - "A Data Inicial deve ser preenchida."
			lRetorno := .F.
		ElseIf !Empty( MV_PAR02 ) .And. MV_PAR01 > MV_PAR02
			Help( Nil,Nil,STR0032,Nil,STR0037,1,0 ) //"Atenção" - "A Data Inicial deve ser menor ou igual à Data Final"
			lRetorno := .F.
		EndIf

	ElseIf nDeAte == 2 // 'Até'

		If Empty( MV_PAR02 )
			Help( Nil,Nil,STR0032,Nil,STR0038,1,0 ) //"Atenção" - "A Data Final deve ser preenchida."
			lRetorno := .F.
		ElseIf MV_PAR02 < MV_PAR01
			Help( Nil,Nil,STR0032,Nil,STR0039,1,0 ) //"Atenção" - "A Data Final deve ser maior ou igual à Data Inicial"
			lRetorno := .F.
		EndIf

	EndIf

Return lRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT420CC
Validação da Pergunta: De/Até Centro de Custo.

@author	Elynton Fellipe Bazzo
@since		29/05/2015
@param 		nDeAte - Indica qual é a validação: * Obrigatório
	   				1 - Pergunta 'De'
	   				2 - Pergunta 'Até'

@return lRetorno
/*/
//---------------------------------------------------------------------
Function MNT420CC( nDeAte )

	// Variável do Retorno
	Local lRetorno := .T.

	//----------
	// Valida
	//----------
	If nDeAte == 1 // 'De'

		If !Empty( MV_PAR03 ) .And. !ExistCpo( "CTT", MV_PAR03, 1 )
			lRetorno := .F.
		EndIf

	ElseIf nDeAte == 2 // 'Até'

		If !AteCodigo( "CTT",MV_PAR03,MV_PAR04,TAMSX3( "CTT_CUSTO" )[1] )
			lRetorno := .F.
		EndIf

	EndIf

Return lRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT420FA
Validação da Pergunta: De/Até Família.

@author	Elynton Fellipe Bazzo
@since		29/05/2015

@param nDeAte - Indica qual é a validação: * Obrigatório
	   			1 - Pergunta 'De'
	   			2 - Pergunta 'Até'

@return lRetorno
/*/
//---------------------------------------------------------------------
Function MNT420FA( nDeAte )

	// Variável do Retorno
	Local lRetorno := .T.

	//----------
	// Valida
	//----------
	If nDeAte == 1 // 'De'

		If !Empty( MV_PAR05 ) .And. !ExistCpo( "ST6", MV_PAR05, 1 )
			lRetorno := .F.
		EndIf

	ElseIf nDeAte == 2 // 'Até'

		If !AteCodigo( "ST6", MV_PAR05, MV_PAR06, TAMSX3( "T6_CODFAMI" )[1] )
			lRetorno := .F.
		EndIf

	EndIf

Return lRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT420CT
Validação da Pergunta: De/Até centro de trabalho.

@author Vitor Bonet
@since 06/09/2018

@param nDeAte - Indica qual é a validação: * Obrigatório
	   			1 - Pergunta 'De'
	   			2 - Pergunta 'Até'

@return lRetorno
/*/
//---------------------------------------------------------------------
Function MNT420CT( nDeAte )

	// Variável do Retorno
	Local lRetorno := .T.

	//----------
	// Valida
	//----------
	If nDeAte == 1 // 'De'

		If !Empty( MV_PAR05 ) .And. !ExistCpo( "SHB", MV_PAR05, 1 )
			lRetorno := .F.
		EndIf

	ElseIf nDeAte == 2 // 'Até'

		If !AteCodigo( "SHB",MV_PAR05,MV_PAR06 )
			lRetorno := .F.
		EndIf

	EndIf

Return lRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} fProcessa
Processamento da Consulta.

@author	Elynton Fellipe Bazzo
@since		01/06/2015
@param		lProcessa - Indica se deve processar a nova consulta ou apenas
atualizar os objetos * Opcional
	   			.T. - Gera nova consulta
	   			.F. - Apenas atualiza os objetos
				Default: .T.
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fProcessa( lProcessa )

	// Variáveis de atualização
	Local aFWBrowse := {}, aProcessa := {}, nLen := 0, nX := 0
	Local oFWChart
	Local nSerie
	Local nMTBF := 0
	Local nMTTR := 0

	// Variáveis da Query
	Local cQryAlias := ""
	Local cQryExec  := ""

	// Variáveis dos Parâmetros SX1
	Local dMV_DeData := If(!Empty( MV_PAR01 ), MV_PAR01, Nil)
	Local dMV_AtData := If(!Empty( MV_PAR02 ), MV_PAR02, Nil)
	Local cMV_DeCCus := If(!Empty( MV_PAR03 ), MV_PAR03, Space(TAMSX3( "CTT_CUSTO" )[1]))
	Local cMV_AtCCus := If(!Empty( MV_PAR04 ), MV_PAR04, Replicate("Z",TAMSX3( "CTT_CUSTO" )[1]))
	Local cMV_ConCal := If(!Empty( MV_PAR07 ), cValToChar( MV_PAR07 ), Nil)
	Local cMV_DeCTra
	Local cMV_AtCTra
	Local cMV_DeFamB
	Local cMV_AtFamB

	// Variáveis auxiliares
	Local cBemAtu := ""
	Local cBemPai := "", cEmBranco := "-"

	// Verifica a versão do Release utilizado.
	Local lRPORel17 := GetRPORelease() <= '12.1.017'

	// Variáveis para Classe NGKPI
	Local oNGKPI
	Local aParams := {}

	// Defaults
	Default lProcessa := .T.

	If !lRPORel17 // Caso seja uma release maior que 12.1.17
		oNGKPI     := NGKPI():New()
		cMV_DeCTra := If(!Empty( MV_PAR05 ), MV_PAR05, Space(TAMSX3( "HB_COD" )[1]))
		cMV_AtCTra := If(!Empty( MV_PAR06 ), MV_PAR06, Replicate("Z",TAMSX3( "HB_COD" )[1]))
	Else
		cMV_DeFamB := If(!Empty( MV_PAR05 ), MV_PAR05, Space(TAMSX3( "T6_CODFAMI" )[1]))
		cMV_AtFamB := If(!Empty( MV_PAR06 ), MV_PAR06, Replicate("Z",TAMSX3( "T6_CODFAMI" )[1]))
	EndIf

	//----------
	// Processa
	//----------

	If lProcessa
		nMedGeral := 0 // Média Geral
		nTotNMeta := 0 // Total abaixo da meta

		// Alias da Query
		cQryAlias := GetNextAlias()

		// SELECT
		cQryExec := "SELECT ST9.T9_CODBEM, ST9.T9_NOME, "
		cQryExec += "	( SELECT COUNT(STJTERC.TJ_TERCEIR) FROM " + RetSQLName( "STJ" ) + " STJTERC "
		cQryExec += "   WHERE STJTERC.TJ_FILIAL = " + ValToSQL( xFilial( "STJ",xFilial( "ST9" ))) + " "
		cQryExec += "	AND STJTERC.TJ_CODBEM = ST9.T9_CODBEM "
		If !Empty( dMV_DeData ) // De Data
			cQryExec += "	AND STJTERC.TJ_DTPRINI >= " + ValToSQL( dMV_DeData ) + " "
		EndIf
		If !Empty( dMV_AtData ) // Até Data
			cQryExec += "	AND STJTERC.TJ_DTPRINI <= " + ValToSQL( dMV_AtData ) + " "
		EndIf
		cQryExec += "	AND STJTERC.TJ_TERCEIR = '2' "
		cQryExec += "	AND STJTERC.D_E_L_E_T_ = ' ' ) AS TERCEIRO "
		// FROM 'ST9'
		cQryExec += "FROM "
		cQryExec += " " + RetSQLName( "ST9" ) + " ST9 "
		// LEFT JOIN 'STJ'
		cQryExec += "LEFT JOIN "
		cQryExec += " " + RetSQLName( "STJ" ) + " STJ ON ( "
		cQryExec += " STJ.TJ_FILIAL = " + ValToSQL( xFilial( "STJ",xFilial( "ST9" ))) + " "
		cQryExec += " AND STJ.TJ_CODBEM = ST9.T9_CODBEM "
		If !Empty(dMV_DeData) // De Data
			cQryExec += " AND STJ.TJ_DTPRINI >= " + ValToSQL( dMV_DeData ) + " "
		EndIf
		If !Empty(dMV_AtData) // Até Data
			cQryExec += " AND STJ.TJ_DTPRINI <= " + ValToSQL( dMV_AtData ) + " "
		EndIf
		cQryExec += " AND STJ.TJ_SITUACA = 'L' AND STJ.TJ_TERMINO = 'S' "
		cQryExec += " AND STJ.D_E_L_E_T_ = ' ' ) "
		// WHERE
		cQryExec += "WHERE ST9.T9_FILIAL = " + ValToSQL( xFilial( "ST9" )) + " "
		If !Empty(cMV_DeCCus) // De Centro de Custo
			cQryExec += " AND ST9.T9_CCUSTO >= " + ValToSQL( cMV_DeCCus ) + " "
		EndIf
		If !Empty(cMV_AtCCus) // Até Centro de Custo
			cQryExec += " AND ST9.T9_CCUSTO <= " + ValToSQL( cMV_AtCCus ) + " "
		EndIf
		If !lRPORel17 // Caso seja uma release maior que 12.1.17
			If !Empty(cMV_DeCTra) // De Centro de Trabalho
				cQryExec += " AND ST9.T9_CENTRAB >= " + ValToSQL( cMV_DeCTra ) + " "
			EndIf
			If !Empty(cMV_AtCTra) // Até Centro de Trabalho
				cQryExec += " AND ST9.T9_CENTRAB <= " + ValToSQL( cMV_AtCTra ) + " "
			EndIf
		Else
			If !Empty(cMV_DeFamB) // De Família
				cQryExec += " AND ST9.T9_CODFAMI >= " + ValToSQL( cMV_DeFamB ) + " "
			EndIf
			If !Empty(cMV_AtFamB) // Até Família
				cQryExec += " AND ST9.T9_CODFAMI <= " + ValToSQL( cMV_AtFamB ) + " "
			EndIf
		EndIf
		cQryExec += " AND ST9.D_E_L_E_T_ = ' ' "
		// GROUP BY
		cQryExec += "GROUP BY "
		cQryExec += " ST9.T9_CODBEM, ST9.T9_NOME "
		// ORDER BY
		cQryExec += "ORDER BY "
		cQryExec += " ST9.T9_CODBEM "

		// Verifica a sintaxe da query de acordo com o Banco de Dados
		cQryExec := ChangeQuery( cQryExec )
		// Executa a Query no Banco
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryExec), cQryAlias, .T., .T.)

		dbSelectArea( cQryAlias )
		dbGoTop()
		While !Eof() //Percorre o laço de repetição

			lProcessa := .T.

			dbSelectArea( "STJ" )
			dbSetOrder( 12 ) //TJ_FILIAL+TJ_TIPOOS+TJ_CODBEM+TJ_TERMINO+DTOS(TJ_DTMRFIM)
			If dbSeek( xFilial( "STJ" ) + "B" + (cQryAlias)->T9_CODBEM + "S" )
				If STJ->TJ_TERMINO <> 'S' //Ordem de Serviço Terminada
					lProcessa := .F.
				Else
					If dMV_DeData > STJ->TJ_DTPRINI .Or. dMV_AtData < STJ->TJ_DTPRINI //Se estiver fora do período conf. parâmetros informados
						lProcessa := .F.
					EndIf
				EndIf
			ElseIf !dbSeek( xFilial( "STJ" ) + "B" + (cQryAlias)->T9_CODBEM + "S" )
				lProcessa := .F.
			EndIf

			If lProcessa
				aAdd( aProcessa,Array( Len( oRankBrw:aColumns )))
				nLen := Len( aProcessa )

				cBemAtu := (cQryAlias)->T9_CODBEM //Código do Bem
				aProcessa[nLen][nBrwNUMERO] := 0 //Número da posição do Bem
				aProcessa[nLen][nBrwEQUIPA] := cBemAtu //Código do Bem

				//Localização do pai imediato na estrutura de bens (TC_LOCALIZ);
				aProcessa[nLen][nBrwLOCALI] := AllTrim( Posicione( "STC",3, xFilial( "STC" ) + cBemAtu, "TC_LOCALIZ" ))

				If Empty( aProcessa[nLen][nBrwLOCALI] ) //Se não existir Localização;
					aProcessa[nLen][nBrwLOCALI] := cEmBranco //"-"
				EndIf

				// Utilização da Classe de indicadores NGKPI
				aParams := {{"DE_DATA"   , dMV_DeData},;
							{"ATE_DATA"  , dMV_AtData},;
							{"DE_BEM"    , cBemAtu   },;
							{"ATE_BEM"   , cBemAtu   },;
							{"DE_CCUSTO" , cMV_DeCCus},;
							{"ATE_CCUSTO", cMV_AtCCus},;
							{"DE_CENTRA" , cMV_DeCTra},;
							{"ATE_CENTRA", cMV_AtCTra}}

				// Cálculo do Indicador de disponibilidade
				oNGKPI:setIndParams(aParams) // Carrega os valores para a classe

				aProcessa[nLen,nBrwDISPON] :=  oNGKPI:getKPI("DISP")  // Executa o cálculo do indicador

				// Exibe Error da Classe se Houver.
				If aProcessa[nLen][nBrwDISPON] == Nil
					oNGKPI:showHelp()
					aProcessa[nLen][nBrwDISPON] := 0
				EndIf

				// Elimina o objeto da memória.
				oNGKPI:Free()

				cBemPai := aProcessa[nLen][nBrwLOCALI] // Pai da Estrutura = Pai Imediato
				If Empty( cBemPai ) .Or. AllTrim( cBemPai ) == cEmBranco
					cBemPai := NGBEMPAI( cBemAtu ) // Pai da Estrutura = Pai da Estrutura
					If Empty( cBemPai )
						cBemPai := cBemAtu // Pai da Estrutura = O Próprio Bem
					EndIf
				EndIf

				aProcessa[nLen][nBrwDESCLO] := AllTrim( Posicione( "TPS", 1, xFilial( "TPS" ) + cBemPai, "TPS_NOME" )) //Descrição Localização
				aProcessa[nLen][nBrwEXTERN] := IIF( (cQryAlias)->TERCEIRO > 0,"X"," " ) //Terceiro

				// Já quantifica a Média Geral e também a Meta
				nMedGeral += aProcessa[nLen][nBrwDISPON]
				If aProcessa[nLen][nBrwDISPON] < MV_PAR09
					nTotNMeta++
				EndIf
			EndIf

			dbSelectArea( cQryAlias )
			dbSkip()
		End While

		// Finaliza o cálculo da Média Geral
		nMedGeral := Round(( nMedGeral / Len( aProcessa )),2 )

		// Ordena por ordem de Menor -> Maior disponibilidade
		aSort(aProcessa, , , {|x,y| Transform(x[nBrwDISPON],"@E 999.99")+x[nBrwEQUIPA] < Transform(y[nBrwDISPON],"@E 999.99")+y[nBrwEQUIPA] })

		If MV_PAR08 == 1
			nQtdEquips := 20 // Quantidade de 20 Equipamentos
		ElseIf MV_PAR08 == 2
			nQtdEquips := 40 // Quantidade de 40 Equipamentos
		ElseIf MV_PAR08 == 3
			nQtdEquips := 60 // Quantidade de 60 Equipamentos
		ElseIf MV_PAR08 == 4
			nQtdEquips := 80 // Quantidade de 80 Equipamentos
		ElseIf MV_PAR08 == 5
			nQtdEquips := 100 // Quantidade de 100 Equipamentos
		EndIf

		// Repassa para o Array do Browse
		For nX := 1 To Len( aProcessa )
			If nX > nQtdEquips
				Exit
			EndIf
			aProcessa[nX][nBrwNUMERO] := nX
			aAdd(aFWBrowse, aClone( aProcessa[nX] ))
		Next nX

		// Seta o Array do Browse
		oRankBrw:SetArray( aFWBrowse )
	EndIf

	// Atualiza a Média Geral
	oMedGeral:SetText( cValToChar( nMedGeral ) + "%" )

	// Atualiza a porcentagem de equipamentos com menor disponibilidade
	oTotPorce:SetText( cValToChar( MV_PAR09 ))

	// Atualiza a quantidade de equipamentos, conforme porcentagem informada.
	oTotNMeta:SetText( cValToChar( nTotNMeta ))

	// Atualiza o Browse
	oRankBrw:GoTop()
	oRankBrw:Refresh()
	aFWBrowse := aClone( oRankBrw:Data():GetArray() )

	// Libera os filhos do painél do gráfico e Atualiza o Gráfico
	oPnlChart:FreeChildren()
	oPnlChart:CoorsUpdate()

	// Monta o Gráfico
	oFWChart := FWChartFactory():New()
	oRankGrf := oFWChart:GetInstance( BARCHART )
	oRankGrf:Init( oPnlChart,.T.,.T. )
	oRankGrf:SetTitle( STR0040,CONTROL_ALIGN_CENTER ) // "Equipamentos - Relação com menor disponibilidade"
	oRankGrf:SetLegend( CONTROL_ALIGN_RIGHT )
	oRankGrf:SetMask( "*@* %" )
	oRankGrf:SetPicture( "@E 999.99" )
	For nSerie := 1 To Len( aFWBrowse )
		oRankGrf:AddSerie( aFWBrowse[nSerie][nBrwEQUIPA],aFWBrowse[nSerie][nBrwDISPON] )
	Next nSerie
	oRankGrf:SetMinY( 0 ) // Valor Mínimo do Eixo Y
	oRankGrf:SetMaxY( 90 ) // Valor Máximo do Eixo Y (a classe sempre coloca um +10 neste 90, fechando então, 100)
	oRankGrf:Build()

	If Len( aProcessa ) <= 0 // Se não possuem registros para gerar a consulta
		Alert( STR0041 ) // Exibe a mensagem: "Não possuem dados cadastrados para exibir a consulta."
		fAskSX1() // Executa a função que realiza novamente a pergunta ao usuário.
	EndIf

Return .T.

//---------------------------------------------------------------------|
/*/{Protheus.doc} fCopyMat
Função que realiza a cópia de uma matriz.

@author	Elynton Fellipe Bazzo
@since		09/06/2015
@return	aAux
/*/
//---------------------------------------------------------------------|
Static Function fCopyMat( aMat,nFim )

	Local aAux
	Local nX, nY

	aAux := Array( nFim,6 )

	For nX := 1 To nFim
		For nY:=1 To 6
		    aAux[nX][nY] := aMat[nX][nY]
		Next
	Next

Return aAux
