#INCLUDE "PROTHEUS.CH"
#INCLUDE "MNTC415.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC415
Consulta de Disponibilidade de Funcionários.

@type  Function
@author Eduardo Mussi
@since 24/11/17
@version P12
/*/
//---------------------------------------------------------------------
Function MNTC415()

	//Retorna limites da tela para a construcao da tela
	Local aLimiTela := FWGetDialogSize( oMainWnd )

	//Array contendo os Objetos para criação das colunas do Browse.
	Local aColumns	:= {}

	//Arrray contendo Botões em outras ações
	Local aButtons	:= {}

	//Filtro de pesquisa do Browse
	Local aPesq		:= fIndBrw()

	//Colunas que serão apresentadas no Browse.
	Local aFldCon 	:= {"T1_CODFUNC","T1_NOME", "RJ_DESC", "TL_DTINICI", "TL_HOINICI", "TJ_CODBEM", "TL_ORDEM"}

	//Alias utilizado na Query
	Local cAliSTL	:= GetNextAlias()
	Local cAliTTL	:= GetNextAlias()

	//Alias Tabela Temporária
	Local cAliasTRB := GetNextAlias()

	//Variavel para controle
	Local cFiliaCod	:= Space( Len( xFilial( "SRA" ) ) )

	//Nome da Filial escolhida para Consulta
	Local cNomeFil	:= ""

	//Consulta Padrão de Filiais
	Local cF3Pesq	:= "DLB   "

	//Objeto Tabela temporária
	Local oTempTable := fCriaTRB( @cAliasTRB )

	Local oBtnGerar

	//Titulo da Dialog
	Private cCadastro := STR0001

	// Log de Acesso LGPD
	If FindFunction( 'FWPDLogUser' )
		FWPDLogUser( 'MNTC415()' )
	EndIf

	//Busca Funcionários disponiveis
	fLoadBrw( .F., cFiliaCod, @cAliasTRB, @cAliSTL, @cAliTTL )

	//Objetos para criação das colunas do Browse.
	aColumns	:= fGerCol( @cAliasTRB, @aFldCon )

	Define MsDialog oDlg STYLE nOr(WS_POPUP,WS_VISIBLE) From aLimiTela[1], aLimiTela[2] To aLimiTela[3], aLimiTela[4] Pixel

	oPanelAll := TPanel():New(0, 0, Nil, oDlg, Nil, .T., .F., Nil, Nil, 0, 0, .F., .F. )
	oPanelAll:Align := CONTROL_ALIGN_ALLCLIENT

	oPanelTop := TPanel():New(0, 0, Nil, oPanelAll, Nil, .T., .F., Nil, Nil, 0, 29, .F., .F. )
	oPanelTop:Align := CONTROL_ALIGN_TOP

	oPanelBrw := TPanel():New(0, 0, Nil, oPanelAll, Nil, .T., .F., Nil, Nil, 0, 0, .F., .F. )
	oPanelBrw:Align := CONTROL_ALIGN_ALLCLIENT

	oDlg:lEscClose := .F.

	//"Filial"
	oSay  := TSay():New( 007, 010, {|| STR0002 },oPanelTop,,,,,,.T.,,,250,50)
	//Consulta padrão de Filiais
	oGet  := TGet():New( 015, 010, {|u| IIf( PCount() > 0, cFiliaCod := u, cFiliaCod ) }, oPanelTop , 060, 012,, {|| IIf( fNamFil( cFiliaCod, @cNomeFil ), cNomeFil, cNomeFil := "") }, 0,,, .F.,, .T.,, .F., , .F., .F.,, .F., .F., cF3Pesq, cFiliaCod,,,, .T. )
	//Campo Fechado que apresenta nome da filial escolhida no F3
	oGet2 := TGet():New( 015, 070, {|| cNomeFil }, oPanelTop , 150, 012,,, 0,,, .F.,, .T.,, .F., {||.F.}, .F., .F.,, .F., .F., , , , , , .T. )
	oBtnGerar := TButton():New(015, 225, STR0003, oPanelTop, {|| Processa( {|| ( fLoadBrw( .T., cFiliaCod, @cAliasTRB, @cAliSTL, @cAliTTL ),oBrowse:GoTo(1), oBrowse:Refresh())  }, STR0004, STR0005 ) }, ; //"Gerar Consulta" ## "Gerando a Consulta..." ## "Por favor, aguarde..."
									050/*nWidth*/, 014/*nHeight*/, /*uParam8*/, /*oFont*/, /*uParam10*/, ;
									.T./*lPixel*/, /*uParam12*/, /*uParam13*/, /*uParam14*/, /*bWhen*/, ;
									/*uParam16*/, /*uParam17*/)
	//----------------------------------
	// Criação do Browse
	//----------------------------------
	oBrowse := FWBrowse():New()
	oBrowse:SetOwner( oPanelBrw )
	oBrowse:SetColumns( aColumns )
	oBrowse:SetAlias( cAliasTRB )
	oBrowse:SetDataTable()
	oBrowse:SetInsert( .F. )
	oBrowse:SetSeek(, aPesq )
	oBrowse:DisableReport()//Desabilita Impressão
	oBrowse:SetObfuscFields({"T1_NOME"})
	oBrowse:Activate()
	oBrowse:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	aAdd( aButtons, { "", { || fVisual( cAliasTRB, 1 ) }, STR0006 } )
	aAdd( aButtons, { "", { || fVisual( cAliasTRB, 2 ) }, STR0007 } )
	aAdd( aButtons, { "", { || (ReportDef(cAliasTRB),oBrowse:GoTo(1), oBrowse:Refresh()) }, STR0014 } )

	Activate MsDialog oDlg On Init EnchoiceBar(oDlg, {|| oDlg:End() }, {|| oDlg:End() }, .F., aButtons) Centered

	oTempTable:Delete()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fLoadBrw()
Efetua busca dos funcionários disponiveis e passaos resgistros
para o arquivo temporário

@type  Static Function
@author Eduardo Mussi
@since 23/11/17
@version P12
@param	lClearTemp - Lógico	  - .T. Limpa Tabela Temporária
		cFiliaCod  - Caracter - Código da Filial.
		cAliasTRB  - Caracter - Alias Tabela Temporária.
		cAliSTL    - Caracter - Alias utilizado na Query
		cAliTTL    - Caracter - Alias utilizado na Query
/*/
//---------------------------------------------------------------------
Static Function fLoadBrw( lClearTemp, cFiliaCod, cAliasTRB, cAliSTL, cAliTTL )

	Local cQrySTL  := ''
	Local cQryTTL  := ''
	Local lIntRH   := IIf(SuperGetMv("MV_NGMNTRH",.F.,"N") <> "N",.T.,.F.)
	Local lExisTbl := NGCADICBASE( "RJ_DESC" , "A" , "SRJ" , .F. ) .And. NGCADICBASE( "RA_MAT" , "A" , "SRA" , .F. )
	Local lCompTab := NGSX2MODO("SRA") == NGSX2MODO("ST1") //Verifica o compartilhamento das tabela SRA e ST1

	If lClearTemp
		//Limpa Tabela Temporária para apresentar corretamente os dados da consulta
		dbSelectArea(cAliasTRB)
		ZAP
	EndIf

	cQrySTL := " SELECT STL.TL_FILIAL, "
	cQrySTL += "		STL.TL_ORDEM, "
	cQrySTL += "		STL.TL_CODIGO, "
	cQrySTL += "		STL.TL_DTINICI, "
	cQrySTL += "		STL.TL_HOINICI, "
	cQrySTL += "		ST1.T1_CODFUNC "
	cQrySTL += "		FROM " + RetSqlName('STl') + " STL "
	cQrySTL += "			LEFT JOIN " + RetSqlName('ST1') + " ST1 "
	cQrySTL += "			ON ST1.T1_CODFUNC = STL.TL_CODIGO AND ST1.T1_DISPONI = 'S' AND ST1.D_E_L_E_T_ <> '*' "
	cQrySTL += "			WHERE TL_DTINICI = TL_DTFIM "
	cQrySTL += "				AND STL.TL_QUANTID = 0 "
	cQrySTL += "				AND STL.TL_FILIAL = " + ValToSQL(cFiliaCod)
	cQrySTL += "				AND STL.D_E_L_E_T_ <> '*' "
	cQrySTL := ChangeQuery(cQrySTL)
	MPSysOpenQuery( cQrySTL , cAliSTL )

	dbSelectArea(cAliSTL)
	dbGoTop()
	While (cAliSTL)->( !Eof() )

		dbSelectArea(cAliasTRB)
		dbGoTop()
		If !Empty((cAliSTL)->T1_CODFUNC)
			RecLock(cAliasTRB,.T.)
			(cAliasTRB)->T1_FILIAL	:= (cAliSTL)->TL_FILIAL
			(cAliasTRB)->T1_CODFUNC := (cAliSTL)->TL_CODIGO
			(cAliasTRB)->T1_NOME 	:= POSICIONE("ST1", 1, xFilial("ST1") + (cAliSTL)->TL_CODIGO, "T1_NOME")
			If lIntRH .And. lExisTbl
				//Verifica o compartilhamento das tabela SRA e ST1
				If lCompTab
					cFuncSRA := POSICIONE("SRA", 1, xFilial("SRA") + (cAliSTL)->TL_CODIGO, "RA_CODFUNC")
				Else
					cCracha  := POSICIONE("ST1", 1, xFilial("ST1") + (cAliSTL)->TL_CODIGO, "T1_CRACHA")
					cFuncSRA := POSICIONE("SRA", 9, cCracha, "RA_CODFUNC")
				EndIf
				(cAliasTRB)->RJ_DESC := POSICIONE("SRJ", 1, xFilial("SRJ") + cFuncSRA, "RJ_DESC")
			EndIf
			(cAliasTRB)->TL_DTINICI := StoD((cAliSTL)->TL_DTINICI)
			(cAliasTRB)->TL_HOINICI	:= (cAliSTL)->TL_HOINICI
			(cAliasTRB)->TJ_CODBEM	:= POSICIONE("STJ", 1, cFiliaCod + (cAliSTL)->TL_ORDEM, "TJ_CODBEM")
			(cAliasTRB)->TL_ORDEM	:= (cAliSTL)->TL_ORDEM
			(cAliasTRB)->( Msunlock() )
		EndIf
		dbSelectArea(cAliSTL)
		dbSkip()
	EndDo
	(cAliSTL)->(dbCloseArea())

	cQryTTL := " SELECT TTL_FILIAL, "
	cQryTTL += "		TTL_CODFUN, "
	cQryTTL += "		TTL_DTINI, "
	cQryTTL += "		TTL_HRINI "
	cQryTTL += "		FROM " + RetSqlName('TTL')
	cQryTTL += "			WHERE TTL_FILIAL = " + ValToSQL(cFiliaCod)
	cQryTTL += "			  AND TTL_DTFIM = ''
	cQryTTL += "			  AND D_E_L_E_T_ <>  '*' "
	cQryTTL := ChangeQuery(cQryTTL)
	MPSysOpenQuery( cQryTTL , cAliTTL )

	dbSelectArea(cAliTTL)
	dbGoTop()
	While (cAliTTL)->( !Eof() )

		dbSelectArea(cAliasTRB)
		If !Empty((cAliTTL)->TTL_CODFUN)
			RecLock(cAliasTRB,.T.)
			(cAliasTRB)->T1_FILIAL	:= (cAliTTL)->TTL_FILIAL
			(cAliasTRB)->T1_CODFUNC := (cAliTTL)->TTL_CODFUN
			(cAliasTRB)->T1_NOME 	:= POSICIONE("ST1", 1, xFilial("ST1") + (cAliTTL)->TTL_CODFUN, "T1_NOME")
			If lIntRH .And. lExisTbl
				//Verifica o compartilhamento das tabela SRA e ST1
				If lCompTab
					cFuncSRA := POSICIONE("SRA", 1, xFilial("SRA") + (cAliTTL)->TTL_CODFUN, "RA_CODFUNC")
				Else
					cCracha  := POSICIONE("ST1", 1, xFilial("ST1") + (cAliTTL)->TTL_CODFUN, "T1_CRACHA")
					cFuncSRA := POSICIONE("SRA", 9, cCracha, "RA_CODFUNC")
				EndIf
				(cAliasTRB)->RJ_DESC := POSICIONE("SRJ", 1, xFilial("SRJ") + cFuncSRA, "RJ_DESC")
			EndIf
			(cAliasTRB)->TL_DTINICI := StoD((cAliTTL)->TTL_DTINI)
			(cAliasTRB)->TL_HOINICI	:= (cAliTTL)->TTL_HRINI
			(cAliasTRB)->( Msunlock() )
		EndIf
		dbSelectArea(cAliTTL)
		dbSkip()
	EndDo
	(cAliTTL)->(dbCloseArea())

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fGerCol
Gera as Colunas do Browse conforme os campos informados no aFldCon.

@type  Static Function
@author Eduardo Mussi
@since 23/11/17
@version P12
@param  cAliasTRB - Caracter - Alias pela tabela temporária.
		aFldCon   - Array    - Campos que serão apresentados no Browse.
@return oColuna Objeto Objeto da Coluna
@example - fCreateCol( "{ | | ALIAS->CAMPO }" )
/*/
//---------------------------------------------------------------------
Static Function fGerCol( cAliasTRB, aFldCon )

	Local aColu := {}
	Local nInd 	:= 0

	//Cria Colunas do Browse
	For nInd := 1 To Len( aFldCon )
		aAdd( aColu, fCreateCol( "{ | | " + ( cAliasTRB ) + "->" + aFldCon[nInd] + " }", aFldCon[nInd] ) )
	Next nInd

Return aColu

//---------------------------------------------------------------------
/*/{Protheus.doc} fCreateCol
Criação das Colunas do Browse.

@type  Static Function
@author Eduardo Mussi
@since 23/11/17
@version P12
@param  cDadosCol - Caracter, Indica a busca do valor do campo
		cCampoCol - Caracter, Campo a ser criado na coluna do Browse.
@return oColuna Objeto Objeto da Coluna
/*/
//---------------------------------------------------------------------
Static Function fCreateCol( cDadosCol, cCampoCol )

	Local aArea		  := GetArea()
	Local cTitleCol   := ""	//Caracter Indica o titulo do campo
	Local cTipeCol	  := ""	//Caracter Indica o tipo do campo
	Local cPictureCol := ""	//Caracter Indica a Picture do campo
	Local oColumn			//Objeto de criação das colunas do Browse
	Local nTamCol	  := 0	//Numerico Indica o tamanho do campo
	// [LGPD] Caso o usuário não possua acesso ao(s) campo(s), deve-se ofuscá-lo(s)	
	Local lOfuscar := FindFunction( 'FWPDCanUse' ) .And. FwPdCanUse( .T. );
				  	 .And. Len( FwProtectedDataUtil():UsrAccessPDField( __CUSERID, { cCampoCol } ) ) == 0

	//Busca as informações no dicionário
	cTitleCol	:= AllTrim( Posicione("SX3",2, cCampoCol, "X3Titulo()") )
	cTipeCol	:= Posicione("SX3",2, cCampoCol, "X3_TIPO")
	nTamCol		:= Posicione("SX3",2, cCampoCol, "X3_TAMANHO") + Posicione("SX3",2, cCampoCol, "X3_DECIMAL")
	cPictureCol	:= Posicione("SX3",2, cCampoCol, "X3_PICTURE")

	//Ajuste dos nomes das colunas.
	Do Case
		Case STR0020 $ cTitleCol
			cTitleCol := STR0008
		Case STR0021 $ cTitleCol
			cTitleCol := STR0009
		Case STR0022 $ cTitleCol
			cTitleCol := STR0010
	End Case

	//Adiciona as colunas do Browse
	oColumn := FWBrwColumn():New()   //Cria objeto
	oColumn:SetData( &( cDadosCol ) ) //Define valor
	oColumn:SetEdit( .F. )	      	 //Indica se é editavel
	oColumn:SetTitle( cTitleCol )    //Define titulo
	oColumn:SetType( cTipeCol )      //Define tipo
	oColumn:SetSize( nTamCol )	     //Define tamanho
	oColumn:SetPicture( cPictureCol )//Define picture
	If lOfuscar
		oColumn:SetObfuscateCol( .T. ) // Define que coluna será ofuscada
	EndIf 

	RestArea(aArea)

Return oColumn

//---------------------------------------------------------------------
/*/{Protheus.doc} fIndBrw
Define os Filtros de pesquisa do Browse

@type  Static Function
@author Eduardo Mussi
@since 28/11/17
@version P12
@return aPesq - Filtro de pesquisa do Browse
/*/
//---------------------------------------------------------------------
Static Function fIndBrw()

	Local aPesq := {}

	aAdd( aPesq, {STR0011, {{"", "C", 255, 0, "", "@!"} }, 1 } )
	aAdd( aPesq, {STR0008, {{"", "C", 255, 0, "", "@!"} }, 2 } )
	aAdd( aPesq, {STR0009, {{"", "C", 255, 0, "", "@!"} }, 3 } )
	aAdd( aPesq, {STR0010, {{"", "C", 255, 0, "", "@!"} }, 4 } )

Return aPesq

//---------------------------------------------------------------------
/*/{Protheus.doc} fNamFil
Pesquisa nome da Filial a partir do código informado.

@type  Static Function
@author Eduardo Mussi
@since 28/11/17
@version P12
@param  cFiliaCod - Caracter, Código da Filial.
		cNomeFil  - Caracter, Nome da Filial.
/*/
//---------------------------------------------------------------------
Static Function fNamFil( cFiliaCod, cNomeFil )

	Local aArea := GetArea()

	dbSelectArea("SM0")
	dbSetOrder(1)
	If !Empty(cFiliaCod) .And. dbSeek(cEmpAnt + cFiliaCod)
		cNomeFil := SM0->M0_FILIAL
	Else
		NaoVazio()
		Return .F.
	EndIf

	RestArea(aArea)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fCriaTRB
Cria Arquivo temporário.

@type  Static Function
@author Eduardo Mussi
@since 30/11/17
@version P12
@param cAliasTRB - Caracter - Alias Tabela Temporária
/*/
//---------------------------------------------------------------------
Static Function fCriaTRB( cAliasTRB )

	Local aDBF := {}

	//Estrutura de Campos do TRB
	aDBF := {{"T1_FILIAL" , "C", FwSizeFilial(), 0 },;
			 {"T1_CODFUNC", "C", 06, 0},;
			 {"T1_NOME"   , "C", 20, 0},;
			 {"RJ_DESC"   , "C", 20, 0},;
			 {"TL_DTINICI", "D", 08, 0},;
			 {"TL_HOINICI", "C", 08, 0},;
			 {"TJ_CODBEM" , "C", 16, 0},;
			 {"TL_ORDEM"  , "C", 06, 0}}

	//Instancia classe FWTemporaryTable
	oTempTable := FWTemporaryTable():New( cAliasTRB, aDBF )

	//Cria indices
	oTempTable:AddIndex( "1",{"T1_CODFUNC"})
	oTempTable:AddIndex( "2",{"RJ_DESC"}   )
	oTempTable:AddIndex( "3",{"TJ_CODBEM"} )
	oTempTable:AddIndex( "4",{"TL_ORDEM" } )
	oTempTable:Create()

Return oTempTable

//---------------------------------------------------------------------
/*/{Protheus.doc} fVisual
Visualiza O.S. / Funcionário.

@type  Static Function
@author Eduardo Mussi
@since 29/11/17
@version P12

@param	cAliasTRB  - Caracter - Alias Tabela Temporária
		nOperation - Numérico - 1 = Visuliza Funcionário
								2 = Visualiza O.S.
/*/
//---------------------------------------------------------------------
Static Function fVisual( cAliasTRB, nOperation )

	Local aArea := GetArea()

	If !Empty((cAliasTRB)->T1_CODFUNC)

		//Visuliza Funcionário
		If nOperation == 1
			cCadastro := STR0001 + STR0018
			dbSelectArea("ST1")
			dbSetOrder(1)
			DbSeek(xFilial("ST1") + (cAliasTRB)->T1_CODFUNC )
			FWExecView( cCadastro , 'MNTA020' , MODEL_OPERATION_VIEW , , { || .T. } )
		EndIf

		//Visualiza O.S.
		If nOperation == 2
			If !Empty((cAliasTRB)->TL_ORDEM)
				cCadastro := STR0001 + STR0019
				dbSelectArea("STJ")
				dbSetOrder(1)
				DbSeek(xFilial("STJ") + (cAliasTRB)->TL_ORDEM )
				NGCAD01("STJ", Recno(), 2)
			Else
				MsgInfo( STR0012, STR0013 )//"Funcionário selecionado não contém O.S. em aberto" ### "ATENÇÂO"
			EndIf
		EndIf

		cCadastro := STR0001

	EndIf

	RestArea(aArea)
	oBrowse:GoTop()
	oBrowse:Refresh()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Inicia a impressão do Relatório (Definições)

@type  Static Function
@author Eduardo Mussi
@since 03/12/17
@version P12
/*/
//---------------------------------------------------------------------
Static Function ReportDef(cAliasTRB)

	Local oSection1
	// [LGPD] Caso o usuário não possua acesso ao(s) campo(s), deve-se ofuscá-lo(s)
	Local lOfuscar := FindFunction( 'FWPDCanUse' ) .And. FwPdCanUse( .T. );
				   .And. Len( FwProtectedDataUtil():UsrAccessPDField( __CUSERID, { 'T1_NOME' } ) ) == 0

	oReport := TReport():New("MNTC415",STR0001,/*uParam*/,{|oReport| ReportPrint(oReport,cAliasTRB)},, .F.) //"Funcionários Disponiveis

	oSection1 := TRSection():New(oReport,"" ,{" "} )
	TRCell():New(oSection1,"T1_CODFUNC"," ",STR0011, /*Picture*/,12/*Tamanho*/,.T./*lPixel*/,{|| (cAliasTRB)->T1_CODFUNC })
	TRCell():New(oSection1,"T1_NOME",   " ",STR0015, /*Picture*/,30/*Tamanho*/,.T./*lPixel*/,{|| IIf(lOfuscar,;
		FwProtectedDataUtil():ValueAsteriskToAnonymize((cAliasTRB)->T1_NOME), (cAliasTRB)->T1_NOME)})
	TRCell():New(oSection1,"RJ_DESC",   " ",STR0008, /*Picture*/,30/*Tamanho*/,.T./*lPixel*/,{|| (cAliasTRB)->RJ_DESC    })
	TRCell():New(oSection1,"TL_DTINICI"," ",STR0016, /*Picture*/,12/*Tamanho*/,.T./*lPixel*/,{|| (cAliasTRB)->TL_DTINICI })
	TRCell():New(oSection1,"TL_HOINICI"," ",STR0017, /*Picture*/,12/*Tamanho*/,.T./*lPixel*/,{|| (cAliasTRB)->TL_HOINICI })
	TRCell():New(oSection1,"TJ_CODBEM", " ",STR0009, /*Picture*/,25/*Tamanho*/,.T./*lPixel*/,{|| (cAliasTRB)->TJ_CODBEM  })
	TRCell():New(oSection1,"TL_ORDEM",  " ",STR0010, /*Picture*/,08/*Tamanho*/,.T./*lPixel*/,{|| (cAliasTRB)->TL_ORDEM   })

	oReport:PrintDialog()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Adiciona Linhas para impressão

@param oReport   - Objeto   - Indica o objeto do TReport
	   cAliasTRB - Caracter - Alias Tabela Temporária

@author Eduardo Mussi
@since 03/12/2017
/*/
//---------------------------------------------------------------------
Static Function ReportPrint( oReport, cAliasTRB )

	Local aArea 	:= GetArea()
	Local oSection1 := oReport:Section(1)

	oSection1:Init()

	dbSelectArea(cAliasTRB)
	dbGoTop()

	While (cAliasTRB)->( !Eof() )
		oSection1:PrintLine()
		(cAliasTRB)->( dbSkip() )
	Enddo

	oSection1:Finish()

	RestArea(aArea)

Return