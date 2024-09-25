#INCLUDE "MNTC125.ch"
#INCLUDE "PROTHEUS.CH"

// Constantes para opção de impressão da rotina
#DEFINE _IMP_ESTRUTURA_RODADO_       1
#DEFINE _IMP_ANALISE_TECNICA_        2
#DEFINE _IMP_HISTORICO_MOVIMENTACAO_ 3

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC125
Consulta Gerencial de Pneu

@author Vitor Emanuel Batista
@since 27/07/2010

@param cPneu, Caractere, Código do Pneu para montagem da consulta automática
@return Nil
/*/
//---------------------------------------------------------------------
Function MNTC125(cPneu)

	// Bloco de codigo para abrir a empresa 99
	Local lOpened := .T.
	Local lTudOk  := .F.
	Local xPrepar := If(Type("oMainWnd")!="O",MsgRun( "Preparando Variaveis" , "Aguarde..." , {|| lOpened := !AbreEmpresa() }),Nil)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Guarda conteudo e declara variaveis padroes ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aNGBEGINPRM := {}

	//-----------------------------------------------
	// Declaracao dos objetos
	//-----------------------------------------------
	Local oDlg, oImg, oTBtnBmp
	Local oPanelSup, oPnlSupAux, oPnlSupLat, oPnlBtn
	Local oPnlRef, oPnlCus, oPnlMov, oPnlAna, oPnlBemPai
	Local oSplitter, oSpltCen, oSpltInf
	Local oTFont := TFont():New(,,14,,.T.)

	//-----------------------------------------------
	// Opcoes do Folder
	//-----------------------------------------------
	Local aFolder := {STR0001,STR0002} // "Histórico"###"Bem Pai"

	Local lOkImg

	Local cPneuAtu:= ""

	Local lVldBem := .T.

	// Variáveis para montar os Pneus no Controle de Recapes
	Local aPneBandas := MNTA221Bds()
	Local cAuxVrPrev := "", cAuxVrReal := ""
	Local nX := 0, nLen := 0

	Local oScroll, nMenosLin := 0, nMenosCol := 0
	Local nLinBmp, nColBmp, nLinSay, nColSay, nLinPre, nColPre, nLinRea, nColRea

	//-----------------------------------------------
	// Variaveis de Largura/Altura da Janela
	//-----------------------------------------------
	Local aSize    := If(lOpened,MsAdvSize(,.f.,430),{0,0,0,0,(GetScreenRes()[1]-7),(GetScreenRes()[2]-85),120})
	Local nLargura := aSize[5]
	Local nAltura  := aSize[6]

	Local lUsaScroll := .F.
	Local nAuxColuna := 0
	Local cFldFocus  := ""
	Local lFrota     := .F.

	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 95 )

		aNGBEGINPRM := NGBEGINPRM()
		lFrota      := IIF( FindFunction('MNTFrotas'), MNTFrotas(), SuperGetMV( 'MV_NGMNTFR', .F., 'N' ) == 'S' )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se a Empresa utiliza Gestao de Frota³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lFrota
			MsgStop(STR0003) //"Não é possível utilizar esta rotina pois a empresa corrente não utiliza Gestão de Frota"
			Return
		ElseIf GetNewPar("MV_NGPNEUS","N") == "N"
			MsgStop(STR0004) //"Não é possível utilizar esta rotina pois a empresa corrente não utiliza Controle de Pneus"
			Return
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica e exporta imagens do Rodados³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Processa({ |lEnd| lOkImg := MNTA232IMG() },STR0005)	 // //"Aguarde.. Exportando Imagens..."
		If !lOkImg //Verifica imagens no RPO e exporta para pasta no Temp
			MsgStop(	STR0006+CHR(13)+CHR(13)+; //"Existem algumas imagens necessárias para a utilização desta rotina que não foram encontradas."
			STR0007,STR0008) //"Favor alertar o administrador para que o sistema seja atualizado corretamente."###"NÃO CONFORMIDADE"
			Return .F.
		EndIf

		Private n := 1
		Private lMaisVidas := MNTA221Vds()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caminho da imagem da Placa no %TEMP% ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Private cImgPlaca := GetTempPath()+"rodados"+If(isSRVunix(),"/","\")+"NG_RODADOS_PLACA.PNG"
		//Mercosul - Mercado Comum do Sul
		Private cDirImg		:= GetTempPath() + "rodados" + If(isSRVunix(),"/","\")
		Private cImgPlMerc  := lower(cDirImg + "ng_rodados_mercosul_placa.png")
		Private cImgPlRuss  := lower(cDirImg + "ng_rodados_russia_placa.png")
		Private cImgBand    := cDirImg
		Private cLogMerc    := lower(cDirImg + "ng_rodados_logo_mercosul.png")

		Private oTPaintPnl

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Variaveis com informacoes do Pneu ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Private cPneu125:= If(!Empty(cPneu),cPneu,Space(Len(ST9->T9_CODBEM)))
		Private cDescri := Space(40)
		Private cStatus := Space(2)
		Private nSulco  := 0.00
		Private dDtMeat := CTOD("  /  /  ")
		Private cHrMeat := Space(5)
		Private cDOT    := Space(4)
		Private cBanda  := Space(2)
		Private cMedida := Space(20)
		Private cDesenh := Space(10)
		Private cBemPai := Space(16)
		Private cNomePai:= Space(40)
		Private cTModPai:= Space(10)
		Private cDModPai:= Space(20)
		Private cFamiPai:= Space(6)
		Private cNFamPai:= Space(40)
		Private nContAcu:= 0.00

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valor Total do Historico de Custo    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Private nValorCus := 0

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca Km acumulado do Bem Pai em que está o pneu ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Private nKmBemPai := 0

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Conteudo do KM Previsto por Banda    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Private nPrevOR := 0
		Private nPrev1R := 0
		Private nPrev2R := 0
		Private nPrev3R := 0
		Private nPrev4R := 0
		Private nPrev5R := 0
		Private nPrev6R := 0
		Private nPrev7R := 0
		Private nPrev8R := 0
		Private nPrev9R := 0

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Conteudo do KM Realizado por Banda   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Private nRealOR := 0
		Private nReal1R := 0
		Private nReal2R := 0
		Private nReal3R := 0
		Private nReal4R := 0
		Private nReal5R := 0
		Private nReal6R := 0
		Private nReal7R := 0
		Private nReal8R := 0
		Private nReal9R := 0

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Indica Data de Proximo Recape ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Private dProxRec := CTOD("  /  /  ")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Indica se existe Esquema Padrao Grafico      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Private l232 := .F.

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Objeto para imprimir a estrutura do Bem Pai  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Private oTBtnImp

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Objetos do ListBox ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Private oListMov
		Private oListCus
		Private oListRef
		Private oListAna

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Variávei de Pontos de Entrada               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Private aMNTC1251 := { { 0, {} }, { 0, {} } }, lMNTC1251 := .F.

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Array com as estruturas das TRB dos ListBox ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Private aDBFMov := {}
		Private aDBFCus := {}
		Private aDBFRef := {}
		Private aDBFAna := {}

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Nome da Alias utilizadas pelos ListBox ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Private cTrbMov := GetNextAlias()
		Private cTrbCus := GetNextAlias()
		Private cTrbRef := GetNextAlias()
		Private cTrbAna := GetNextAlias()

		Private oTmpTRB1
		Private oARQTR110
		Private oTmpTRB2
		Private oTmpTRB3
		Private oTmpTRB4

		//-----------------------------------------------------------
		//Varivel utilizada na função NGFILT232 ( favor não retirar )
		//-----------------------------------------------------------
		Private LRODZSXB := .F.

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cria tabelas temporarias para os ListBox³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		CriaTRBRef()
		CriaTRBMov()
		CriaTRBCus()
		CriaTRBAna()

		Private cCadastro := STR0009 //"Gerencial de Pneu"

		SetVisual()
		Define MsDialog oDlg Title cCadastro From aSize[7],0 To nAltura,nLargura COLOR CLR_BLACK,CLR_WHITE Pixel

		oDlg:lMaximized := .T.
		oDlg:lEscClose  := .F.
		If Type("oMainWnd") != "O"
			oMainWnd := oDlg
		EndIf

		oPanel := TPanel():New(0,0,,oDlg,,,,,,0,0,.F.,.F.)
		oPanel:Align := CONTROL_ALIGN_ALLCLIENT

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Panel superior contendo dados do Pneu ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPanelSup := TPanel():New(0,0,,oPanel,,,,,,0,82,.F.,.F.)
		oPanelSup:Align := CONTROL_ALIGN_TOP

		@ 07,10 Say NGRetTitulo('TQS_CODBEM') Of oPanelSup Color CLR_HBLUE Pixel
		@ 05,45 MsGet oCodBem Var cPneu125 Of oPanelSup Size 70,09 Picture "@!" Valid If(lVldBem,ValidPneu(cPneu125,@cPneuAtu),.T.) F3 'NGPNEU' Pixel HASBUTTON //When Empty(cPneu)
		oCodBem:bHelp := { || ShowHelpCpo(NGRetTitulo('TQS_CODBEM'), ;
		{STR0060},1,;//"Código do pneu a ser feita a consulta."
		{},1)  }

		@ 07,125 Say NGRetTitulo('TQS_DESBEM') Of oPanelSup Pixel
		@ 05,160 MsGet cDescri Of oPanelSup Size 120,09 Picture "@!" When .F. Pixel

		@ 19,10 Say NGRetTitulo('T9_STATUS') Of oPanelSup Pixel
		@ 17,45 MsGet cStatus Of oPanelSup Size 70,09 Picture "@!" When .F. Pixel

		@ 19,125 Say NGRetTitulo('TQS_SULCAT') Of oPanelSup Pixel
		@ 17,160 MsGet nSulco Of oPanelSup Size 30,09 Picture "@E 999.99" When .F. HASBUTTON Pixel

		@ 31,10 Say NGRetTitulo('TQS_DTMEAT') Of oPanelSup Pixel
		@ 29,45 MsGet dDtMeat Of oPanelSup Size 50,09 Picture "99/99/99" When .F. HASBUTTON Pixel

		@ 31,125 Say NGRetTitulo('TQS_HRMEAT') Of oPanelSup Pixel
		@ 29,160 MsGet cHrMeat Of oPanelSup Size 15,09 Picture "99:99" When .F. Pixel

		@ 43,10 Say NGRetTitulo('TQS_DOT') Of oPanelSup Pixel
		@ 41,45 MsGet cDOT Of oPanelSup Size 20,09 Picture "@!" When .F. Pixel

		@ 43,125 Say NGRetTitulo('TQS_BANDAA') Of oPanelSup Pixel
		@ 41,160 MsGet cBanda Of oPanelSup Size 25,09 Picture "@!" When .F. Pixel

		@ 55,10 Say NGRetTitulo('TQS_DESMED') Of oPanelSup Pixel
		@ 53,45 MsGet cMedida Of oPanelSup Size 70,09 Picture "@!" When .F. Pixel

		@ 55,125 Say NGRetTitulo('T9_CONTACU') Of oPanelSup Pixel
		@ 53,160 MsGet nContAcu Of oPanelSup Size 55,09 Picture "@E 999,999,999,999" When .F. HASBUTTON Pixel

		@ 67,10 Say NGRetTitulo('TQS_DESENH') Of oPanelSup Pixel
		@ 65,45 MsGet cDesenh Of oPanelSup Size 70,09 Picture "@!" When .F. Pixel

		//Get para perca de foco do campo de Pneu
		@ -99,-99 MsGet oGetTmp Var cFldFocus Of oPanelSup

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Panel lateral direito com informacoes de Recapes ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPnlSupAux := TPanel():New(0,0,,oPanelSup,,,,,CLR_WHITE,2,0,.F.,.F.)
		oPnlSupAux:Align := CONTROL_ALIGN_RIGHT

		oPnlSupLat := TPanel():New(0,0,,oPanelSup,,,,,CLR_WHITE,200,0,.F.,.F.)
		oPnlSupLat:Align := CONTROL_ALIGN_RIGHT
		oPnlSupLat:CoorsUpdate()

		oPnlSupAux := TPanel():New(0,0,,oPnlSupLat,,,,,CLR_WHITE,0,2,.F.,.F.)
		oPnlSupAux:Align := CONTROL_ALIGN_TOP

		oPnlSupAux := TPanel():New(0,0,,oPnlSupLat,,,,,RGB(67,70,87),0.5,0,.F.,.F.)
		oPnlSupAux:Align := CONTROL_ALIGN_RIGHT

		oPnlSupAux := TPanel():New(0,0,,oPnlSupLat,,,,,RGB(67,70,87),0.5,0,.F.,.F.)
		oPnlSupAux:Align := CONTROL_ALIGN_LEFT

		oPnlSupAux := TPanel():New(0,0,,oPnlSupLat,,,,,RGB(67,70,87),0,0.5,.F.,.F.)
		oPnlSupAux:Align := CONTROL_ALIGN_BOTTOM

		oPnlSupAux := TPanel():New(0,0,STR0020,oPnlSupLat,oTFont,.T.,,CLR_WHITE,RGB(67,70,87),0,12,.F.,.F.) //'Controle de Recapes'
		oPnlSupAux:Align := CONTROL_ALIGN_TOP

		lUsaScroll := ( lMaisVidas .Or. ExistBlock("MNTC1251") ) // Ponto de Entrada está abaixo deste trecho de código
		If lUsaScroll
			oScroll := TScrollBox():new(oPnlSupLat, 0, 0, 10, 10, .T. , .T., .F.)
			oScroll:Align := CONTROL_ALIGN_ALLCLIENT
			oScroll:CoorsUpdate()

			nMenosLin := 15
			nMenosCol := 2
		EndIf

		//--------------------------------------------------------------------------------
		// Ponto de Entrada para manipular os objetos superiores da Consulta (Painél do Topo, o que contém os campos, o o Painél do Controle de Recapes)
		//--------------------------------------------------------------------------------
		If ExistBlock("MNTC1251")
			aMNTC1251 := ExecBlock("MNTC1251", .F., .F., {oPanelSup, If(lUsaScroll, oScroll, oPnlSupLat), "cPneu125"})
			If ValType(aMNTC1251) == "A" .And. Len(aMNTC1251) >= 2 .And. ;
			Len(aMNTC1251[1]) >= 2 .And. ValType(aMNTC1251[1][1]) == "N" .And. ValType(aMNTC1251[1][2]) == "A" .And. ;
			Len(aMNTC1251[2]) >= 2 .And. ValType(aMNTC1251[2][1]) == "N" .And. ValType(aMNTC1251[2][2]) == "A"
				lMNTC1251 := .T.
			EndIf
		EndIf

		TSay():New(16-nMenosLin,023-nMenosCol,{||STR0021},If(lUsaScroll, oScroll, oPnlSupLat),,oTFont,,,,.T.,CLR_BLACK,CLR_WHITE,050,15) //'Banda'
		TSay():New(16-nMenosLin,062-nMenosCol,{||STR0022},If(lUsaScroll, oScroll, oPnlSupLat),,oTFont,,,,.T.,CLR_BLACK,CLR_WHITE,050,15) //'Previsto'
		TSay():New(16-nMenosLin,105-nMenosCol,{||STR0023},If(lUsaScroll, oScroll, oPnlSupLat),,oTFont,,,,.T.,CLR_BLACK,CLR_WHITE,050,15) //'Realizado'
		nAuxColuna := 150-nMenosCol
		If lMNTC1251 .And. aMNTC1251[2][1] > nAuxColuna
			nAuxColuna := aMNTC1251[2][1] + 010
		EndIf
		TSay():New(16-nMenosLin,nAuxColuna,{||STR0024},If(lUsaScroll, oScroll, oPnlSupLat),,oTFont,,,,.T.,CLR_BLACK,CLR_WHITE,050,15) //'Próximo Recape'

		// Mostra Recapes
		nLinSay := 27
		nColSay := 5
		nLinBmp := (nLinSay-2)
		nColBmp := 15

		nLinPre := nLinBmp
		nColPre := 55
		nLinRea := nLinBmp
		nColRea := 100
		For nX := 1 To Len(aPneBandas)

			// Define as varíaveis para mostrar
			cAuxVrPrev := ""
			cAuxVrReal := ""
			Do Case
				Case aPneBandas[nX][1] == "1" // Original
				cAuxVrPrev := "nPrevOR"
				cAuxVrReal := "nRealOR"
				Case aPneBandas[nX][1] == "2" // Recape 1
				cAuxVrPrev := "nPrev1R"
				cAuxVrReal := "nReal1R"
				Case aPneBandas[nX][1] == "3" // Recape 2
				cAuxVrPrev := "nPrev2R"
				cAuxVrReal := "nReal2R"
				Case aPneBandas[nX][1] == "4" // Recape 3
				cAuxVrPrev := "nPrev3R"
				cAuxVrReal := "nReal3R"
				Case aPneBandas[nX][1] == "5" // Recape 4
				cAuxVrPrev := "nPrev4R"
				cAuxVrReal := "nReal4R"
				Case aPneBandas[nX][1] == "6" // Recape 5
				cAuxVrPrev := "nPrev5R"
				cAuxVrReal := "nReal5R"
				Case aPneBandas[nX][1] == "7" // Recape 6
				cAuxVrPrev := "nPrev6R"
				cAuxVrReal := "nReal7R"
				Case aPneBandas[nX][1] == "8" // Recape 7
				cAuxVrPrev := "nPrev7R"
				cAuxVrReal := "nReal7R"
				Case aPneBandas[nX][1] == "9" // Recape 8
				cAuxVrPrev := "nPrev8R"
				cAuxVrReal := "nReal8R"
				Case aPneBandas[nX][1] == "A" // Recape 9
				cAuxVrPrev := "nPrev9R"
				cAuxVrReal := "nReal9R"
			EndCase

			// Say
			TSay():New((nLinSay-nMenosLin), (nColSay-nMenosCol), &("{|| '"+aPneBandas[nX][3]+"' }"), If(lUsaScroll, oScroll, oPnlSupLat), , oTFont, ;
			, , , .T., CLR_BLACK, CLR_WHITE, 50, 15)
			// Imagem
			oImg := TBitmap():New((nLinBmp-nMenosLin), (nColBmp-nMenosCol), 40, 10, aPneBandas[nX][4], , .T., If(lUsaScroll, oScroll, oPnlSupLat), ;
			, , .F., .F., , , .F., , .T., , .F.)
			oImg:lStretch:= .T.
			oImg:nHeight := 23.2
			oImg:nWidth  := 64

			// Previsto
			TGet():New((nLinPre-nMenosLin), (nColPre-nMenosCol), &("{|| "+cAuxVrPrev+" }"), If(lUsaScroll, oScroll, oPnlSupLat), 040, 008, "@E 999,999,999", {|| .T. }, CLR_BLACK, CLR_WHITE, ,;
			.F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "", , , , .F./*lHasButton*/)
			// Realizado
			TGet():New((nLinRea-nMenosLin), (nColRea-nMenosCol), &("{|| "+cAuxVrReal+" }"), If(lUsaScroll, oScroll, oPnlSupLat), 040, 008, "@E 999,999,999", {|| .T. }, CLR_BLACK, CLR_WHITE, ,;
			.F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "", , , , .F./*lHasButton*/)

			// Próxima linha
			nLinSay += 11
			nLinBmp := (nLinSay-2)
			nLinPre := nLinBmp
			nLinRea := nLinBmp
		Next nX

		nAuxColuna := 148-nMenosCol
		If lMNTC1251 .And. aMNTC1251[2][1] > nAuxColuna
			nAuxColuna := aMNTC1251[2][1] + 010
		EndIf
		@ 25-nMenosLin,nAuxColuna MsGet dProxRec Of If(lUsaScroll, oScroll, oPnlSupLat) Size 50,07 Picture "99/99/99" When .F. HASBUTTON Pixel

		nAuxColuna := 155-nMenosCol
		If lMNTC1251 .And. aMNTC1251[2][1] > nAuxColuna
			nAuxColuna := aMNTC1251[2][1] + 017
		EndIf
		oImg := tBitmap():New(49-nMenosLin,nAuxColuna,040,040,"NG_RODADOS_RECAPE",,.T.,If(lUsaScroll, oScroll, oPnlSupLat),,,.F.,.F.,,,.F.,,.T.,,.F.)
		oImg:lStretch:= .T.
		oImg:nHeight := 76.8
		oImg:nWidth  := 76.8

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Folder contendo Historico e Detalhes do Pneu ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oTFolder := TFolder():New( 0,0,aFolder,,oPanel,,,,.T.,,260,184 )
		oTFolder:Align := CONTROL_ALIGN_ALLCLIENT
		oTFolder:bWhen := {|| !Empty(cPneu125)}

		oSplitter := TSplitter():New( 0, 0, oTFolder:aDialogs[1], 0, 0, 1 )
		oSplitter:Align := CONTROL_ALIGN_ALLCLIENT
		oSplitter:nClrPane := RGB(67,70,87)

		oSpltCen := TSplitter():New( 0, 0, oSplitter, nLargura/4, nAltura/4 - 70, 1 )
		oSpltCen:Align := CONTROL_ALIGN_TOP
		oSpltCen:SetOrient(0)

		oPnlRef := TPanel():New(0,0,,oSpltCen,,,,,RGB(67,70,87),nLargura/4 - 17,0,.F.,.F.)
		oPnlRef:Align := CONTROL_ALIGN_LEFT

		oPnlSupAux := TPanel():New(0,0,,oPnlRef,,,,CLR_WHITE,RGB(67,70,87),0,12,.F.,.F.)
		oPnlSupAux:Align := CONTROL_ALIGN_TOP

		TSay():New(2,2,{||STR0025},oPnlSupAux,,oTFont,,,,.T.,CLR_WHITE,CLR_WHITE,200,20) //'Reformas'

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ListBox das Reformas ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea(cTrbRef)
		@ 0,0 Listbox oListRef Fields (cTrbRef)->TR7_DTRECI,(cTrbRef)->TR7_HRRECI,;
		(cTrbRef)->A2_NOME,(cTrbRef)->CONTROD,PADL(Transform((cTrbRef)->TR8_VALOR,"@E 999999.99"),9);
		Headers STR0026,STR0027,STR0028,STR0029,STR0030 ; //'Data'#'Hora'#'Reformadora'#'Contador Rodado'#'Valor'
		Of oPnlRef Size nLargura/4 - 17,285 On DblClick VisualTrb("TR7",cTrbRef)
		oListRef:cAlias:= cTrbRef
		oListRef:Align := CONTROL_ALIGN_ALLCLIENT

		oPnlCus := TPanel():New(0,0,,oSpltCen,,,,,RGB(67,70,87),nLargura/4 -17,0,.F.,.F.)
		oPnlCus:Align := CONTROL_ALIGN_RIGHT

		oPnlSupAux := TPanel():New(0,0,,oPnlCus,,,,CLR_WHITE,RGB(67,70,87),0,12,.F.,.F.)
		oPnlSupAux:Align := CONTROL_ALIGN_TOP

		TSay():New(2,2,{||STR0031},oPnlSupAux,,oTFont,,,,.T.,CLR_WHITE,CLR_WHITE,200,20) //'Custos'

		oSayCus := TSay():New(2,2,{|| STR0032 + PADL(Transform(nValorCus,"@E 999,999,999,999.999"),18)},oPnlSupAux,,oTFont,.T.,,,.T.,CLR_WHITE,CLR_WHITE,50,20) //"Total"
		oSayCus:Align := CONTROL_ALIGN_RIGHT

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ListBox dos Custos   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea(cTrbCus)
		@ 0,0 Listbox oListCus Fields (cTrbCus)->TIPO,(cTrbCus)->TJ_ORDEM,(cTrbCus)->TJ_DTMRFIM,(cTrbCus)->TJ_HOMRFIM,PADR(Transform((cTrbCus)->VALOR,"@E 999,999,999,999.999"),18);
		Headers STR0033,STR0034,STR0026,STR0027,STR0030 Of oPnlCus Size nLargura/4 ,285 On DblClick VisualTrb("STJ",cTrbCus) //'Tipo'##'Ordem'##'Data'##'Hora'##'Valor'
		oListCus:cAlias    := cTrbCus
		oListCus:Align := CONTROL_ALIGN_ALLCLIENT

		oSpltInf := TSplitter():New( 0, 0, oSplitter, nLargura/4, nAltura/4 - 70, 1 )
		oSpltInf:Align := CONTROL_ALIGN_TOP
		oSpltInf:SetOrient(0)

		oPnlMov := TPanel():New(0,0,,oSpltInf,,,,,RGB(67,70,87),nLargura/4 -17,0,.F.,.F.)
		oPnlMov:Align := CONTROL_ALIGN_LEFT

		oPnlSupAux := TPanel():New(0,0,,oPnlMov,,,,CLR_WHITE,RGB(67,70,87),0,12,.F.,.F.)
		oPnlSupAux:Align := CONTROL_ALIGN_TOP

		TSay():New(2,2,{|| STR0035},oPnlSupAux,,oTFont,,,,.T.,CLR_WHITE,CLR_WHITE,200,20) //'Histórico de Movimentação'

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ListBox do Historico de Movimentacoes ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea(cTrbMov)
		@ 0,0 Listbox oListMov ;
		Fields (cTrbMov)->TZ_BEMPAI,(cTrbMov)->TZ_LOCALIZ,(cTrbMov)->TZ_DATAMOV,(cTrbMov)->TZ_HORAENT,;
		(cTrbMov)->TZ_DATASAI,(cTrbMov)->TZ_HORASAI,(cTrbMov)->KMENTRADA,If(Empty((cTrbMov)->TZ_DATASAI),nKmBemPai,(cTrbMov)->KMSAIDA),;
		If(Empty((cTrbMov)->TZ_DATASAI),nKmBemPai - (cTrbMov)->KMENTRADA,(cTrbMov)->KMSAIDA - (cTrbMov)->KMENTRADA),;
		If(Empty((cTrbMov)->TZ_DATASAI),nContAcu,(cTrbMov)->KMPNEU),(cTrbMov)->T8_NOME;
		Headers STR0036,STR0037,STR0038,STR0039,STR0040,STR0041,STR0061,STR0062,STR0042,STR0065,STR0063 ; //'Bem Pai'##'Localização'##'Dt. Entrada'##'Hr. Entrada'##'Dt. Saída'##'Hr. Saída'##'Contador Pneu'##'Km Entrada'##'Km Saída'##"Motivo"
		Of oPnlMov Size nLargura/4 - 17,285 FieldSizes Nil,35,35,35,35,35 On DblClick VisualTrb("STZ",cTrbMov)
		oListMov:cAlias    := cTrbMov
		oListMov:Align := CONTROL_ALIGN_ALLCLIENT

		oPnlAna := TPanel():New(0,0,,oSpltInf,,,,,RGB(67,70,87),nLargura/4 -17,0,.F.,.F.)
		oPnlAna:Align := CONTROL_ALIGN_LEFT

		oPnlSupAux := TPanel():New(0,0,,oPnlAna,,,,CLR_WHITE,RGB(67,70,87),0,12,.F.,.F.)
		oPnlSupAux:Align := CONTROL_ALIGN_TOP

		TSay():New(2,2,{|| STR0043},oPnlSupAux,,oTFont,,,,.T.,CLR_WHITE,CLR_WHITE,200,20) //'Análise Técnica'

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ListBox das Analises Tecnicas ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea(cTrbAna)
		@ 0,0 Listbox oListAna ;
		Fields (cTrbAna)->TR4_DTANAL,(cTrbAna)->TR4_HRANAL,NGRETSX3BOX("TR4_DESTIN",Trim((cTrbAna)->TR4_DESTIN)),;
		Transform((cTrbAna)->TR4_SULCO,"@E 999.99"),(cTrbAna)->TR4_PAREC ;
		Headers STR0044,STR0045,STR0046,STR0047,STR0048 ; //'Data Analise'##'Hora Analise'##'Destino Pneu'##'Prof. Sulco'##'Parecer'
		Of oPnlAna Size nLargura/4 ,285 FieldSizes 35,35,35,35,35,35 On DblClick VisualTrb("TR4",cTrbAna)
		oListAna:cAlias    := cTrbAna
		oListAna:Align := CONTROL_ALIGN_ALLCLIENT

		//Barra Lateral Esquerda - Botoes
		oPnlBtn := TPanel():New(0,0,,oDlg,,,,,RGB(67,70,87),13,0,.F.,.F.)
		oPnlBtn:Align := CONTROL_ALIGN_LEFT

		oTBtnBmp  := TBtnBmp():NewBar("ng_ico_visual","ng_ico_visual",,,,{|| VisualPneu(cPneu125)},,oPnlBtn,,{|| !Empty(cPneu125)})
		oTBtnBmp:cToolTip := STR0010 //"Visualizar Cadastro de Bens"
		oTBtnBmp:Align    := CONTROL_ALIGN_TOP

		oTBtnBmp  := TBtnBmp():NewBar("ng_ico_sulco","ng_ico_sulco",,,,{|| MNTA080SUH(cPneu125)},,oPnlBtn,,{|| !Empty(cPneu125)})
		oTBtnBmp:cToolTip := STR0011 //"Histórico de Sulco"
		oTBtnBmp:Align    := CONTROL_ALIGN_TOP

		oTBtnImp  := TBtnBmp():NewBar("ng_ico_imp","ng_ico_imp",,,,{|| NGIMPCPNEU( cPneu125,oMainWnd ) },,oPnlBtn,,{|| !Empty(cPneu125)})
		oTBtnImp:cToolTip := STR0067 // "Relatórios Pneu"
		oTBtnImp:Align    := CONTROL_ALIGN_TOP
		// oTBtnImp:Hide() // botão deve aparecer sempre a partir da implementação S.S.: 019464

		oTBtnBmp  := TBtnBmp():NewBar("ng_ico_grafpizza","ng_ico_grafpizza",,,,{|| GraphKMxMM(cPneu125)},,oPnlBtn,,{|| !Empty(cPneu125)})
		oTBtnBmp:cToolTip := STR0013 //"Gráfico de Km x MM"
		oTBtnBmp:Align    := CONTROL_ALIGN_TOP

		oTBtnBmp  := TBtnBmp():NewBar("ng_ico_refresh","ng_ico_refresh",,,,{|| MsgRun(STR0014,STR0015,{|| LoadPneu(cPneu125)})},,oPnlBtn,,{|| !Empty(cPneu125)}) //"Coletando Dados..."###"Aguarde..."
		oTBtnBmp:cToolTip := STR0016 //"Atualizar Informações"
		oTBtnBmp:Align    := CONTROL_ALIGN_TOP
		SETKEY(VK_F5,{|| If(!Empty(cPneu125),MsgRun(STR0014,STR0015,{|| LoadPneu(cPneu125)}),Nil)}) //"Coletando Dados..."##"Aguarde..."

		oTBtnBmp  := TBtnBmp():NewBar("ng_ico_calc","ng_ico_calc",,,,{|| Calculadora()},,oPnlBtn)
		oTBtnBmp:cToolTip := STR0049 //"Calculadora"
		oTBtnBmp:Align    := CONTROL_ALIGN_TOP


		oTBtnBmp  := TBtnBmp():NewBar("ng_ico_final","ng_ico_final",,,,{|| If(MsgYesNo(STR0017,STR0018),(lVldBem:= .F.,oDlg:End()),.F.)},,oPnlBtn) //### //"Deseja realmente sair?"###"Atenção"
		oTBtnBmp:cToolTip := STR0019 //"Sair"
		oTBtnBmp:Align    := CONTROL_ALIGN_TOP

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Itens do Folder de Detalhes ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		oPnlSupAux := TPanel():New(0,0,,oTFolder:aDialogs[2],,,,CLR_WHITE,RGB(67,70,87),0,12,.F.,.F.)
		oPnlSupAux:Align := CONTROL_ALIGN_TOP

		TSay():New(2,2,{|| STR0050},oPnlSupAux,,oTFont,,,,.T.,CLR_WHITE,CLR_WHITE,200,20) // 'Informações do Bem Pai'

		oPnlBemPai := TPanel():New(0,0,,oTFolder:aDialogs[2],,,,,CLR_WHITE,,45,.F.,.F.)
		oPnlBemPai:Align := CONTROL_ALIGN_TOP

		@ 07,10 Say NGRetTitulo('T9_CODBEM') Of oPnlBemPai Pixel
		@ 05,45 MsGet cBemPai Of oPnlBemPai Size 70,09 Picture "@!" When .F. Pixel

		@ 07,125 Say NGRetTitulo('T9_NOME') Of oPnlBemPai Pixel
		@ 05,160 MsGet cNomePai Of oPnlBemPai Size 120,09 Picture "@!" When .F. Pixel

		@ 19,10 Say NGRetTitulo('T9_TIPMOD') Of oPnlBemPai Pixel
		@ 17,45 MsGet cTModPai Of oPnlBemPai Size 35,09 Picture "@!" When .F. Pixel

		@ 19,125 Say NGRetTitulo('T9_DESMOD') Of oPnlBemPai Pixel
		@ 17,160 MsGet cDModPai Of oPnlBemPai Size 120,09 Picture "@!" When .F. Pixel

		@ 31,10 Say NGRetTitulo('T9_CODFAMI') Of oPnlBemPai Pixel
		@ 29,45 MsGet cFamiPai Of oPnlBemPai Size 35,09 Picture "@!" When .F. Pixel

		@ 31,125 Say NGRetTitulo('T9_NOMFAMI') Of oPnlBemPai Pixel
		@ 29,160 MsGet cNFamPai Of oPnlBemPai Size 120,09 Picture "@!" When .F. Pixel


		oTPlaca := TPaintPanel():new(0,300,124,45,oPnlBemPai,.f.)

		oPnlSupAux := TPanel():New(0,0,,oTFolder:aDialogs[2],,,,CLR_WHITE,RGB(67,70,87),0,12,.F.,.F.)
		oPnlSupAux:Align := CONTROL_ALIGN_TOP

		TSay():New(2,2,{|| STR0051},oPnlSupAux,,oTFont,,,,.T.,CLR_WHITE,CLR_WHITE,200,20) //'Esquema de Rodados'

		oScrollBox := TScrollBox():New(oTFolder:aDialogs[2],0,0,0,0,.T.,.T.,.F.)
		oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT
		oScrollBox:Refresh()

		Activate MsDialog oDlg On Init (oTFolder:HidePage(2),oTFolder:ShowPage(1),If(!Empty(cPneu) .And. !ValidPneu(cPneu125,@cPneuAtu),oDlg:End(),.T.))


		oTmpTRB1:Delete()
		oARQTR110:Delete()
		oTmpTRB2:Delete()
		oTmpTRB3:Delete()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Retorna conteudo de variaveis padroes       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		NGRETURNPRM(aNGBEGINPRM)
	
	EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VisualTrb  ³Autor ³ Vitor Emanuel Batista ³ Data ³02/08/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Visualiza registro de qualquer ListBox pelo NGCAD01         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cAlias- Tabela do Banco de dados                            ³±±
±±³          ³cTrb  - Tabela temporaria do ListBox                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTC125                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function VisualTrb(cAlias,cTrb)

	If (cTrb)->RECNO > 0
		dbSelectArea(cAlias)
		dbGoTo((cTrb)->RECNO)
		If !Eof()
			NGCAD01(cAlias,Recno(),2)
		EndIf
	EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ValidPneu  ³Autor ³ Vitor Emanuel Batista ³ Data ³02/08/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Valida a existencia e carrega dados do Pneu informado       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cPneu - Codigo do Pneu                                      ³±±
±±³          ³cPneuAtu- Pneu atual preenchido                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTC125                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidPneu(cPneu,cPneuAtu)

	If cPneu != cPneuAtu

		dbSelectArea("ST9")
		dbSetOrder(1)
		If !dbSeek(xFilial("ST9")+cPneu) .Or. ST9->T9_CATBEM != "3" //.Or. ST9->T9_SITBEM != "A"
			Help(" ",1,"REGNOIS")
			Return .F.
		EndIf

		cPneuAtu := cPneu

		//--------------------------------------------------
		// Coloca o Ponteiro do Mouse em Estado de Espera
		//--------------------------------------------------
		CursorWait()

		MsgRun(STR0014,STR0015,{|| LoadPneu(cPneu)}) // "Coletando Dados..."##"Aguarde..."

		oListRef:SetFocus()
		// oTFolder:Refresh()
		lRefresh := .T.
		//--------------------------------------------------
		// Restaura o Estado do Cursor
		//--------------------------------------------------
		CursorArrow()
	EndIf
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LoadPneu   ³Autor ³ Vitor Emanuel Batista ³ Data ³27/07/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carrega dados de todas as TRB e informacoes adicionais      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cPneu - Indica o Pneu a carregar os dados                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTC125                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LoadPneu(cPneu)

	Local cLocal, cPlaca
	Local l232Tmp := l232
	Local cBemPai := Space(Len(ST9->T9_CODBEM))

	Local aPneBandas := MNTA221Bds()
	Local aAtuVars := {}, cAuxVrPrev := "", cAuxVrReal := ""
	Local nX := 0

	Local cLocMerc  := ""
	Local cLocRuss  := ""
	local cTamFont  := "7"
	Local nPlacaZ   := Str(18)

	// Verificação de data e país para utilização da nova placa do mercosul
	If CPAISLOC == "BRA" .And. dToS(DDATABASE) >= "20170101"
		cLocMerc := "BRASIL"
		cImgBand := lower(cImgBand + "ng_rodados_merc_band_bra.png")
	ElseIf CPAISLOC == "ARG" .And. dToS(DDATABASE) >= "20160101"
		cLocMerc := "REPUBLICA ARGENTINA"
		cImgBand := lower(cImgBand + "ng_rodados_merc_band_arg.png")
	ElseIf CPAISLOC == "PAR" .And. dToS(DDATABASE) >= "20160101"
		cLocMerc := "REPUBLICA DEL PARAGUAY"
		cImgBand := lower(cImgBand + "ng_rodados_merc_band_pry.png")
	ElseIf CPAISLOC == "VEN" .And. dToS(DDATABASE) >= "20160101"
		cLocMerc := "REPUBLICA BOLIVARIANA DE VENEZUELA"
		cImgBand := lower(cImgBand + "ng_rodados_merc_band_ven.png")
		cTamFont := "6"
	ElseIf CPAISLOC == "URU" .And. dToS(DDATABASE) >= "20160101"
		cLocMerc := "URUGUAY"
		cImgBand := lower(cImgBand + "ng_rodados_merc_band_ury.png")
	ElseIf CPAISLOC == "URS"
		cLocRuss	:= "RUS"
		cImgBand	:= lower(cImgBand + "ng_rodados_russia_band.png")
		cImgPlaca	:= lower(cDirImg + "ng_rodados_russia_placa.png")
	EndIf

	If !Empty(cPneu)

		// Define as variáveis a atualizar
		For nX := 1 To Len(aPneBandas)
			Do Case
				Case aPneBandas[nX][1] == "1" // Original
				cAuxVrPrev := "nPrevOR"
				cAuxVrReal := "nRealOR"
				Case aPneBandas[nX][1] == "2" // Recape 1
				cAuxVrPrev := "nPrev1R"
				cAuxVrReal := "nReal1R"
				Case aPneBandas[nX][1] == "3" // Recape 2
				cAuxVrPrev := "nPrev2R"
				cAuxVrReal := "nReal2R"
				Case aPneBandas[nX][1] == "4" // Recape 3
				cAuxVrPrev := "nPrev3R"
				cAuxVrReal := "nReal3R"
				Case aPneBandas[nX][1] == "5" // Recape 4
				cAuxVrPrev := "nPrev4R"
				cAuxVrReal := "nReal4R"
				Case aPneBandas[nX][1] == "6" // Recape 5
				cAuxVrPrev := "nPrev5R"
				cAuxVrReal := "nReal5R"
				Case aPneBandas[nX][1] == "7" // Recape 6
				cAuxVrPrev := "nPrev6R"
				cAuxVrReal := "nReal7R"
				Case aPneBandas[nX][1] == "8" // Recape 7
				cAuxVrPrev := "nPrev7R"
				cAuxVrReal := "nReal7R"
				Case aPneBandas[nX][1] == "9" // Recape 8
				cAuxVrPrev := "nPrev8R"
				cAuxVrReal := "nReal8R"
				Case aPneBandas[nX][1] == "A" // Recape 9
				cAuxVrPrev := "nPrev9R"
				cAuxVrReal := "nReal9R"
			EndCase

			//        1      2                     3                      4                  5
			// Array: Banda, Variável do Previsto, Variável do Realizado, Campo do Km Atual, Campo do Km Esperado
			aAdd(aAtuVars, {aPneBandas[nX][1], cAuxVrPrev, cAuxVrReal, ;
			FWTabPref(aPneBandas[nX][2])+"->"+aPneBandas[nX][2], FWTabPref(aPneBandas[nX][5])+"->"+aPneBandas[nX][5]})
		Next nX

		// Posiciona os registros nas tabelas ST9 e TQS
		dbSelectArea("TQS")
		dbSetOrder(1)
		dbSeek(xFilial("TQS")+cPneu)

		dbSelectArea("ST9")
		dbSetOrder(1)
		dbSeek(xFilial("ST9")+cPneu)

		//--------------------------------------------------
		// Busca Km acumulado do Bem Pai em que está o pneu
		//--------------------------------------------------
		cBemPai   := NGSEEK( 'STC', TQS->TQS_CODBEM, 3, 'STC->TC_CODBEM' )
		nKmBemPai := NGSEEK( 'ST9', cBemPai, 1, 'T9_CONTACU' )

		cDescri := ST9->T9_NOME
		cStatus := NGSEEK("TQY",ST9->T9_STATUS,1,"TQY->TQY_DESTAT")
		nSulco  := TQS->TQS_SULCAT
		dDtMeat := TQS->TQS_DTMEAT
		cHrMeat := TQS->TQS_HRMEAT
		cDOT    := TQS->TQS_DOT
		cBanda  := NGRETSX3BOX("TQS_BANDAA",TQS->TQS_BANDAA)
		cMedida := NGSEEK("TQT",TQS->TQS_MEDIDA,1,"TQT->TQT_DESMED")
		nContAcu:= ST9->T9_CONTACU
		cDesenh := TQS->TQS_DESENH

		// Atualiza variáveis de 'Realizado'
		For nX := 1 To Len(aAtuVars)
			&(aAtuVars[nX][3]) := &(aAtuVars[nX][4])
		Next nX

		dbSelectArea("TQX")
		dbSetOrder(1)
		dbSeek(xFilial("TQX")+TQS->TQS_MEDIDA+ST9->T9_TIPMOD)

		dbSelectArea("TQU")
		dbSetOrder(1)
		dbSeek(xFilial("TQU")+TQS->TQS_DESENH+ST9->T9_FABRICA)

		// Atualiza variáveis de 'Previsto'
		For nX := 1 To Len(aAtuVars)
			If aAtuVars[nX][1] == "1"
				&(aAtuVars[nX][2]) := &(aAtuVars[nX][5])
			ElseIf TQS->TQS_BANDAA >= aAtuVars[nX][1]
				dbSelectArea("TQU")
				dbSetOrder(1)
				If dbSeek(xFilial("TQU")+RetDesenho(cPneu,aAtuVars[nX][1])+ST9->T9_FABRICA)
					&(aAtuVars[nX][2]) := TQX->TQX_KMESPO * (&(aAtuVars[nX][5]) / 100)
				EndIf
			EndIf
		Next nX

		dProxRec := ProxRecape()

		LoadTrbRef(cPneu)
		LoadTrbMov(cPneu)
		LoadTrbCus(cPneu)
		LoadTrbAna(cPneu)

		If Type("oTPaintPnl") == "O"
			oTPaintPnl:Free()
		EndIf

		oTPaintPnl := ImpRodados(cPneu,oScrollBox,.F.)

		// Bloqueia o segundo Folder caso nao tenha Esquema Padrao Grafico
		If l232Tmp != l232
			If l232
				oTFolder:ShowPage(2)
				// oTBtnImp:Show() // botão deve aparecer sempre a partir da implementação S.S.: 019464
			Else
				oTFolder:HidePage(2)
				// oTBtnImp:Hide() // botão deve aparecer sempre a partir da implementação S.S.: 019464
			EndIf
			oTFolder:ShowPage(1)
		EndIf

		oTPlaca:ClearAll()
		If l232 .And. !Empty(ST9->T9_PLACA)
			// Ja esta posicionado no ST9 do Bem Pai
			cLocal := Trim(ST9->T9_UFEMPLA) + " - " + Trim(Substr(ST9->T9_CIDEMPL,1,15))
			cPlaca := Trim(ST9->T9_PLACA)

			// Verificação de data e país para utilização da nova placa do mercosul
			If !Empty(cPlaca) .And. !Empty(cLocMerc) .And. !Empty(cImgPlMerc) .And. ((dToS(DDATABASE) >= "20160101" .And. CPAISLOC $ "ARG-PAR-VEN-URU") .Or. (dToS(DDATABASE) >= "20170101" .And. CPAISLOC = "BRA"))

				oTPlaca:addShape(	"id=0;type=1;left=0;top=0;width=248;height=90;gradient=1,0,0,0,0,0.0,#FFFFFF;"+;
				"pen-width=0;pen-color=#FFFFFF;is-container=1;")

				oTPlaca:addShape(	"id=1;type=8;left=0;top=0;width=85;height=38;image-file="+;
				cImgPlMerc+";can-move=0;can-deform=0;can-mark=0;is-container=1")

				oTPlaca:addShape(	"id=2;type=7;left="+Str(38)+";top="+nPlacaZ+";width=175;height=60;text="+;
				cLocMerc+";font=FE Engschrift,"+cTamFont+",1,0,3;pen-color=#FFFFFF;pen-width=1;is-container=0")

				oTPlaca:addShape(	"id=3;type=8;left="+Str(215)+";top="+Str(11)+";width=85;height=38;image-file="+;
				cImgBand+";can-move=0;can-deform=0;can-mark=0;is-container=1")

				oTPlaca:addShape(	"id=4;type=8;left="+Str(10)+";top="+Str(10)+";width=85;height=38;image-file="+;
				cLogMerc+";can-move=0;can-deform=0;can-mark=0;is-container=1")

				oTPlaca:addShape(	"id=3;type=7;left="+Str(10)+";top="+Str(34)+";width=230;height=50;text="+;
				cPlaca+";font=FE Engschrift,30,1,0,3;pen-color=#000000;pen-width=1;is-container=0")

				// Forma antiga de exibição de placa
			ElseIf !Empty(cPlaca) .And. ((dToS(DDATABASE) <= "20160101" .And. CPAISLOC $ "ARG-PAR-VEN-URU") .Or. (dToS(DDATABASE) <= "20170101" .And. CPAISLOC = "BRA"))

				oTPlaca:addShape(	"id=0;type=1;left=0;top=0;width=248;height=90;gradient=1,0,0,0,0,0.0,#FFFFFF;pen-width=0;pen-color=#FFFFFF;is-container=1;")
				oTPlaca:addShape(	"id=1;type=8;left=0;top=0;width=85;height=38;image-file="+lower(cImgPlaca)+";can-move=0;can-deform=0;can-mark=0;is-container=1")
				oTPlaca:addShape(	"id=2;type=7;left="+Str(38)+";top="+Str(17)+";width=175;height=60;text="+cLocal+";font=Verdana,10,1,0,3;pen-color=#000000;pen-width=1;is-container=0")
				oTPlaca:addShape(	"id=3;type=7;left="+Str(10)+";top="+Str(34)+";width=230;height=50;text="+cPlaca+";font=Verdana,23,1,0,3;pen-color=#000000;pen-width=1;is-container=0")
			ElseIf  !Empty(cPlaca) .And. !Empty(cImgPlRuss) .And. CPAISLOC = "URS"

				oTPlaca:addShape("id=0;type=1;left=0;top=0;width=248;height=90;"+;
								"gradient=1,0,0,0,0,0.0,#FFFFFF;pen-width=0;"+;
								"pen-color=#FFFFFF;is-container=1;")
				// Placa modelo Rússia
				oTPlaca:addShape("id=1;type=8;left=0;top=0;width=85;height=38;"+;
								"image-file="+cImgPlRuss+";can-move=0;can-deform=0;"+;
								"can-mark=0;is-container=1")
				// Localização
				oTPlaca:addShape("id=2;type=7;left="+Str(108)+";top="+Str(57)+";width=175;"+;
								"height=60;text="+cLocRuss+";font=Arial,14,1,0,3;"+;
								"pen-width=1;is-container=0")
				// Números referente a macroregião na Rússia (a ser estudado)
				oTPlaca:addShape("id=3;type=7;left="+Str(115)+";top="+Str(25)+";width=175;"+;
								"height=60;text="+'105'+";font=Arial,17,1,0,3;"+;
								"pen-width=1;is-container=0")
				// Bandeira
				oTPlaca:addShape("id=4;type=8;left="+Str(217)+";top="+Str(60)+";width=25;"+;
								"height=38;image-file="+cImgBand+";can-move=0;can-deform=0;"+;
								"can-mark=0;is-container=0")
				// Placa do bem
				oTPlaca:addShape("id=5;type=7;left=-25;top="+Str(30)+";width=230;"+;
								"height=50;text="+cPlaca+";font=FE Engschrift,23,1,0,3;"+;
								"pen-color=#000000;pen-width=1;is-container=0")
			EndIf
		EndIf

		//--------------------------------------------------------------------------------
		// Ponto de Entrada para atualizar os objetos adicionados pelo P.E. MNTA1251
		//--------------------------------------------------------------------------------
		If ExistBlock("MNTC1252")
			ExecBlock("MNTC1252", .F., .F., {cPneu, If(lMNTC1251,aMNTC1251[1][2],{}), If(lMNTC1251,aMNTC1251[2][2],{})})
		EndIf
	EndIf
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CriaTRBRef ³Autor ³ Vitor Emanuel Batista ³ Data ³05/08/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cria TRB do ListBox do Historico de Movimentacao            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTC125                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CriaTRBRef()

	Private AVETINR := {}

	aAdd(aDBFRef,{ "TR7_DTRECI" , "D" , 08 , 0 })
	aAdd(aDBFRef,{ "TR7_HRRECI" , "C" , 05 , 0 })
	aAdd(aDBFRef,{ "A2_NOME"    , "C" , 40 , 0 })
	aAdd(aDBFRef,{ "CONTROD"    , "N" , 09 , 0 })
	aAdd(aDBFRef,{ "TR8_VALOR"  , "N" , 09 , 2 })
	aAdd(aDBFRef,{ "RECNO"      , "N" , 16 , 0 })

	oTmpTRB1 := FWTemporaryTable():New(cTrbRef, aDBFRef)
	oTmpTRB1:AddIndex("Ind01", {"TR7_DTRECI"})
	oTmpTRB1:Create()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LoadTrbRef ³Autor ³ Vitor Emanuel Batista ³ Data ³05/08/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carrega dados da TRB do Historico de Movimentacao           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cPneu - Indica o Pneu a carregar os dados                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTC125                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LoadTrbRef(cPneu)
	Local cQuery
	Local cQryAlias
	Local nAcunCon
	Local cGetDB := TcGetDb()
	Local cIsNull

	dbSelectArea(cTrbRef)
	ZAP

	If cGetDB == "ORACLE"
		cIsNull := "NVL
	ElseIf "DB2" $ cGetDB .Or. cGetDB == "POSTGRES"
		cIsNull := "COALESCE"
	Else
		cIsNull := "ISNULL"
	EndIf

	cQryAlias := GetNextAlias()
	cQuery := " SELECT TR7_DTRECI, TR7_HRRECI ,A2_NOME, TR8_VALOR , TR7.R_E_C_N_O_ AS RECNO,
	cQuery += cIsNull+"((SELECT TP_ACUMCON FROM " + RetSqlName("STP") + " STP"
	cQuery += "    WHERE TP_CODBEM = TR8_CODBEM AND TP_DTLEITU||TP_HORA = "
	cQuery += "      (SELECT MAX(TP_DTLEITU||TP_HORA) AS DATAHORA FROM " + RetSqlName("STP")
	cQuery += "       WHERE TP_CODBEM = TR8_CODBEM AND (TP_DTLEITU||TP_HORA) <= (TR7_DTRECI||TR7_HRRECI)"
	cQuery += "          AND D_E_L_E_T_ <> '*' AND TP_FILIAL = "+ValToSql(xFilial("STP")) + ")"
	cQuery += "      AND STP.D_E_L_E_T_ <> '*' AND TP_FILIAL = "+ValToSql(xFilial("STP")) + "),0) AS TP_ACUMCON"
	cQuery += " FROM " + RetSqlName("TR8") + " TR8"
	cQuery += " INNER JOIN " + RetSqlName("TR7") + " TR7 ON TR7.D_E_L_E_T_ <> '*' AND TR7_FILIAL = "+ValToSql(xFilial("TR7"))
	cQuery += "     AND TR7_LOTE = TR8_LOTE AND TR7_DTRECI <> '        ' AND TR7_HRRECI <> '     '"
	cQuery += "     AND TR7_SERVIC = "+ValToSql(PadR(AllTrim(GetMv("MV_NGSEREF")),6))
	cQuery += " LEFT JOIN  " + RetSqlName("SA2") + " SA2 ON SA2.D_E_L_E_T_ <> '*' AND A2_FILIAL = "+ValToSql(xFilial("SA2"))
	cQuery += "     AND A2_COD = TR7_FORNEC AND A2_LOJA = TR7_LOJA"
	cQuery += " WHERE TR8.D_E_L_E_T_ <> '*' AND TR8_FILIAL = "+ValToSql(xFilial("TR7"))
	cQuery += "     AND TR8_CODBEM = "+ValToSql(cPneu)
	cQuery += " ORDER BY TR7_DTRECI,TR7_HRRECI"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cQryAlias, .F., .T.)

	dbSelectArea(cQryAlias)
	dbGoTop()
	While !Eof()
		RecLock(cTrbRef,.T.)
		(cTrbRef)->TR7_DTRECI := STOD((cQryAlias)->TR7_DTRECI)
		(cTrbRef)->TR7_HRRECI := (cQryAlias)->TR7_HRRECI
		(cTrbRef)->A2_NOME    := (cQryAlias)->A2_NOME
		(cTrbRef)->TR8_VALOR  := (cQryAlias)->TR8_VALOR
		(cTrbRef)->RECNO      := (cQryAlias)->RECNO
		nAcunCon := (cQryAlias)->TP_ACUMCON
		(cQryAlias)->(dbSkip())
		If (cQryAlias)->(!Eof())
			(cTrbRef)->CONTROD := (cQryAlias)->TP_ACUMCON - nAcunCon
		Else
			dbSelectArea("ST9")
			dbSetOrder(1)
			dbSeek(xFilial("ST9")+cPneu)
			(cTrbRef)->CONTROD := ST9->T9_CONTACU - nAcunCon
		EndIf

		MsUnLock()
		dbSelectArea(cQryAlias)
	EndDo

	(cQryAlias)->(dbCloseArea())
	(cTrbRef)->(dbGoTop())
	oListRef:Refresh()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CriaTRBMov ³Autor ³ Vitor Emanuel Batista ³ Data ³27/07/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cria TRB do ListBox do Historico de Movimentacao            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTC125                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CriaTRBMov()

	// Cria a TRB de movimentações do Pneu
	R881CriaTRB()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LoadTrbMov ³Autor ³ Vitor Emanuel Batista ³ Data ³27/07/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carrega dados da TRB do Historico de Movimentacao           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cPneu - Indica o Pneu a carregar os dados                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTC125                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LoadTrbMov(cPneu)

	// Local cQuery

	dbSelectArea(cTrbMov)
	ZAP

	/*cQuery := " SELECT TZ_BEMPAI,TZ_LOCALIZ,TZ_DATAMOV,TZ_HORAENT,TZ_DATASAI,"
	cQuery += "        TZ_HORASAI,T8_NOME,STZ.R_E_C_N_O_,"
	cQuery += " (SELECT MAX(TP_ACUMCON) FROM "+RetSqlName("STP") + " STP1 "
	cQuery += "  WHERE STP1.D_E_L_E_T_ <> '*' AND TP_FILIAL = "+ValToSql(xFilial("STP"))
	cQuery += "    AND TP_CODBEM = TZ_BEMPAI AND (TP_DTLEITU||TP_HORA) <= (TZ_DATAMOV||TZ_HORAENT)) AS KMENTRADA,"
	cQuery += " (SELECT MAX(TP_ACUMCON) FROM "+RetSqlName("STP") + " STP2 "
	cQuery += "  WHERE STP2.D_E_L_E_T_ <> '*' AND TP_FILIAL = "+ValToSql(xFilial("STP"))
	cQuery += "    AND TP_CODBEM = TZ_BEMPAI AND (TP_DTLEITU||TP_HORA) <= (TZ_DATASAI||TZ_HORASAI)) AS KMSAIDA,"
	cQuery += " (SELECT MAX(TP_ACUMCON) FROM "+RetSqlName("STP") + " STP3 "
	cQuery += "  WHERE STP3.D_E_L_E_T_ <> '*' AND TP_FILIAL = "+ValToSql(xFilial("STP"))
	cQuery += "    AND TP_CODBEM = TZ_CODBEM AND (TP_DTLEITU||TP_HORA) <= (TZ_DATASAI||TZ_HORASAI)) AS KMPNEU"
	cQuery += " FROM " + RetSqlName("STZ") + " STZ"
	cQuery += " LEFT JOIN " + RetSqlName("ST8") + " ST8 ON ST8.D_E_L_E_T_ <> '*' AND T8_FILIAL = "+ValToSql(xFilial("ST8"))
	cQuery += "     AND T8_CODOCOR = TZ_CAUSA"
	cQuery += " WHERE STZ.D_E_L_E_T_ <> '*' AND TZ_FILIAL = "+ValToSql(xFilial("STZ"))
	cQuery += "   AND TZ_CODBEM = "+ValToSql(cPneu)
	cQuery += " ORDER BY TZ_FILIAL,TZ_CODBEM,TZ_DATAMOV,TZ_HORAENT"

	SqlToTrb(cQuery,aDBFMov,cTrbMov)*/

	// Carrega movimentações do Pneu
	R881Load( cPneu )

	(cTrbMov)->(dbGoTop())
	oListMov:Refresh()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CriaTRBMov ³Autor ³ Vitor Emanuel Batista ³ Data ³27/07/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cria TRB do ListBox do Historico de Movimentacao            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTC125                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CriaTRBCus()

	Private AVETINR := {}

	aAdd(aDBFCus,{ "TIPO"  , "C" , 9  , 0 })
	aAdd(aDBFCus,{ "TJ_ORDEM" , "C" , Len(STJ->TJ_ORDEM) , 0 })
	aAdd(aDBFCus,{ "TJ_DTMRFIM" , "D" , 08 , 0 })
	aAdd(aDBFCus,{ "TJ_HOMRFIM" , "C" , 05 , 0 })
	aAdd(aDBFCus,{ "VALOR" , "N" , TAMSX3("T9_VALCPA ")[1] , 2 })
	aAdd(aDBFCus,{ "RECNO" , "N" , 16 , 0 })

	oTmpTRB2 := FWTemporaryTable():New(cTrbCus, aDBFCus)
	oTmpTRB2:AddIndex("Ind01", {"TJ_ORDEM"})
	oTmpTRB2:Create()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LoadTrbCus ³Autor ³ Vitor Emanuel Batista ³ Data ³27/07/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carrega dados da TRB do Custo do Pneu                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cPneu - Indica o Pneu a carregar os dados                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTC125                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LoadTrbCus(cPneu)
	Local cQuery
	Local lCustFer  := NGCADICBASE("TJ_CUSTFER","A","STJ",.F.)

	dbSelectArea(cTrbCus)
	ZAP

	dbSelectArea("ST9")
	dbSetOrder(1)
	dbSeek(xFilial("ST9")+cPneu)
	RecLock(cTrbCus,.T.)
	(cTrbCus)->TIPO       := STR0052 //"AQUISIÇÃO"
	(cTrbCus)->TJ_ORDEM   := "       "
	(cTrbCus)->TJ_DTMRFIM := ST9->T9_DTCOMPR
	(cTrbCus)->TJ_HOMRFIM := "  :  "
	(cTrbCus)->VALOR      := ST9->T9_VALCPA

	cQuery := " SELECT TJ_SERVICO AS TIPO,TJ_ORDEM,TJ_DTMRFIM,TJ_HOMRFIM,"
	cQuery += "       (TJ_CUSTMDO+TJ_CUSTMAT+TJ_CUSTMAA+TJ_CUSTMAS+TJ_CUSTTER"+If(lCustFer,"+TJ_CUSTFER)",")")+" AS VALOR,"
	cQuery += "        R_E_C_N_O_ AS RECNO FROM " + RetSqlName("STJ")
	cQuery += " WHERE D_E_L_E_T_ <> '*' AND TJ_CODBEM = "+ValToSql(cPneu)
	cQuery += "   AND TJ_FILIAL = "+ValToSql(xFilial("STJ"))
	cQuery += "   AND TJ_TERMINO = 'S' AND TJ_SITUACA = 'L'"
	cQuery += " ORDER BY TJ_FILIAL,TJ_TIPOOS,TJ_CODBEM,TJ_TERMINO,TJ_DTMRFIM"

	SqlToTrb(cQuery,aDBFCus,cTrbCus)

	nValorCus := 0
	dbSelectArea(cTrbCus)
	dbGoTop()
	While !Eof()
		nValorCus += (cTrbCus)->VALOR
		dbSkip()
	EndDo

	(cTrbCus)->(dbGoTop())
	oListCus:Refresh()


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CriaTRBAna ³Autor ³ Vitor Emanuel Batista ³ Data ³02/08/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cria TRB do ListBox da Analise Tecnica                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTC125                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CriaTRBAna()

	Private AVETINR := {}

	aAdd(aDBFAna,{ "TR4_DTANAL"  , "D" , 08  , 0 })
	aAdd(aDBFAna,{ "TR4_HRANAL"  , "C" , 05 , 0 })
	aAdd(aDBFAna,{ "TR4_DESTIN"  , "C" , 20 , 0 })
	aAdd(aDBFAna,{ "TR4_SULCO"   , "N" , 06 , 2 })
	aAdd(aDBFAna,{ "TR4_PAREC"   , "C" , 80 , 0 })
	aAdd(aDBFAna,{ "RECNO"       , "N" , 16 , 0 })

	oTmpTRB3 := FWTemporaryTable():New(cTrbAna, aDBFAna)
	oTmpTRB3:AddIndex("Ind01", {"TR4_DTANAL"})
	oTmpTRB3:Create()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LoadTrbAna ³Autor ³ Vitor Emanuel Batista ³ Data ³02/08/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carrega dados da TRB da Analise Tecnica                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cPneu - Indica o Pneu a carregar os dados                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTC125                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LoadTrbAna(cPneu)
	Local cQuery

	dbSelectArea(cTrbAna)
	ZAP

	cQuery := " SELECT TR4_DTANAL,TR4_HRANAL,TR4_DESTIN,TR4_SULCO,TR4_PAREC,R_E_C_N_O_ AS RECNO FROM " + RetSqlName("TR4")
	cQuery += " WHERE D_E_L_E_T_ <> '*' AND TR4_FILIAL = "+ValToSql(xFilial("TR4"))
	cQuery += "   AND TR4_CODBEM = "+ValToSql(cPneu)
	cQuery += " ORDER BY TR4_FILIAL,TR4_CODBEM,TR4_DTANAL,TR4_HRANAL"

	SqlToTrb(cQuery,aDBFAna,cTrbAna)

	(cTrbAna)->(dbGoTop())
	oListAna:Refresh()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VisualPneu ³Autor ³ Vitor Emanuel Batista ³ Data ³27/07/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Visualiza cadastro de Bens do Pneu informado                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cPneu - Indica o Pneu a ser visualizado                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTC125                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function VisualPneu(cPneu)

	dbSelectArea("ST9")
	dbSetOrder(1)
	If dbSeek(xFilial("ST9")+cPneu)
		MNTA080CAD( 'ST9' , ST9->( Recno() ) , 2 )
	EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ImpRodados ³Autor ³ Vitor Emanuel Batista ³ Data ³27/07/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Visualiza cadastro de Bens do Pneu informado                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cPneu - Indica o Pneu a ser visualizado                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTC125                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpRodados(cPneu,oParse,lPrint)

	Local oTPanel

	l232 := .F.
	//Procuta o Pai do Pneu na Estrutura
	dbSelectArea("STC")
	dbSetOrder(3)
	If dbSeek(xFilial("STC")+cPneu)
		dbSelectArea("ST9")
		dbSetOrder(1)
		If dbSeek(xFilial("ST9")+ STC->TC_CODBEM)
			If !Empty(NGSEEK("TQ0",ST9->T9_CODFAMI+ST9->T9_TIPMOD,1,"TQ0->TQ0_CODEST"))
				l232 := .T.
			EndIf
		EndIf
	EndIf

	cBemPai := ST9->T9_CODBEM
	cNomePai:= ST9->T9_NOME
	cTModPai:= ST9->T9_TIPMOD
	cDModPai:= NGSEEK("TQR",ST9->T9_TIPMOD,1,"TQR->TQR_DESMOD")
	cFamiPai:= ST9->T9_CODFAMI
	cNFamPai:= NGSEEK("ST6",ST9->T9_CODFAMI,1,"ST6->T6_NOME")

	If l232
		oTPanel := MNTA232IMP(ST9->T9_CODBEM,oParse,lPrint)

		If !lPrint
			nTop := (oParse:nClientHeight/2 - oTPanel:nClientHeight/2)
			nLeft:= (oParse:nClientWidth/2 - oTPanel:nClientWidth/2)
			oTPanel:nTop  := If(nTop <= 0,3,nTop)
			oTPanel:nLeft := If(nLeft <= 0,3,nLeft)
		EndIf

	EndIf

	If lPrint .And. !l232
		MsgInfo( STR0066 ) // "Pneu não se encontra em uma estrutura."
	EndIf

Return oTPanel

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³RetDesenho ³Autor ³ Vitor Emanuel Batista ³ Data ³10/08/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna o desenho do pneu de acordo com a vida dele         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cPneu - Indica o Pneu a ser visualizado                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTC125                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetDesenho(cPneu,cBanda)

	Local aArea := GetArea()
	Local cQuery
	Local cQryAlias := GetNextAlias()
	Local cDesenho  := Space(Len(TQV->TQV_DESENH))


	cQuery := " SELECT TQV_DESENH FROM " + RetSqlName("TQV")
	cQuery += " WHERE D_E_L_E_T_ <> '*' AND TQV_FILIAL = "+ValToSql(xFilial("TQV"))
	cQuery += "     AND TQV_DESENH <> '          ' AND TQV_CODBEM = "+ValToSql(cPneu)
	cQuery += "     AND TQV_BANDA = " + ValToSql(cBanda)
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cQryAlias, .F., .T.)

	If !Eof()
		cDesenho := (cQryAlias)->TQV_DESENH
	EndIf

	(cQryAlias)->(dbCloseArea())
	RestArea(aArea)

Return cDesenho

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GraphKMxMM ³Autor ³ Vitor Emanuel Batista ³ Data ³10/08/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera grafico de Km x MM                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cPneu - Indica o Pneu a ser visualizado                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTC125                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GraphKMxMM(cPneu)

	Local cQryAlias := GetNextAlias()
	Local cQuery
	Local cTitulo
	Local aDBF := {}
	Local cTrb := GetNextAlias()
	Local aLegenda := {STR0053} //"Original"
	Local lGrafico   := .T.
	Local nTotalAcum := 0

	dbSelectArea("TQS")
	dbSetOrder(1)
	dbSeek(xFilial("TQS")+cPneu)

	Private aVetInr := {}

	cQuery := " SELECT (TQV_DTMEDI||TQV_HRMEDI) AS DTHR,TQV_SULCO, TQV_BANDA, TQV_DESENH,"
	cQuery += " (SELECT MAX(TP_ACUMCON) FROM " + RetSqlName("STP")
	cQuery += "  WHERE D_E_L_E_T_ <> '*' AND TP_FILIAL = "+ValToSql(xFilial("STP"))
	cQuery += "    AND (TP_DTLEITU||TP_HORA) <= (TQV_DTMEDI||TQV_HRMEDI) AND TP_CODBEM = TQV_CODBEM) AS ACUMCON"
	cQuery += " FROM " + RetSqlName("TQV")
	cQuery += " WHERE D_E_L_E_T_ <> '*' AND TQV_FILIAL = "+ValToSql(xFilial("TQV"))
	cQuery += "     AND TQV_CODBEM = "+ValToSql(cPneu)
	cQuery += " ORDER BY TQV_SULCO DESC " //TQV_DTMEDI,TQV_HRMEDI"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cQryAlias, .F., .T.)

	aDBF := {}
	aAdd(aDBF,{ "CODIGO" , "C" , 16 , 0 })
	aAdd(aDBF,{ "DESCRI" , "C" , 30 , 0 })
	aAdd(aDBF,{ "ORIGI"  , "N" , 12 , 0 })
	If TQS->TQS_BANDAA >= '2'
		aAdd(aDBF,{ "VIDA1"  , "N" , 12 , 0 })
		aAdd(aLegenda,STR0054) //"1 Vida"
	EndIf
	If TQS->TQS_BANDAA >= '3'
		aAdd(aDBF,{ "VIDA2"  , "N" , 12 , 0 })
		aAdd(aLegenda,STR0055) //"2 Vida"
	EndIf
	If TQS->TQS_BANDAA >= '4'
		aAdd(aDBF,{ "VIDA3"  , "N" , 12 , 0 })
		aAdd(aLegenda,STR0056) //"3 Vida"
	EndIf
	If TQS->TQS_BANDAA >= '5'
		aAdd(aDBF,{ "VIDA4"  , "N" , 12 , 0 })
		aAdd(aLegenda,STR0057) //"4 Vida"
	EndIf

	oTmpTRB4 := FWTemporaryTable():New(cTrb, aDBF)
	oTmpTRB4:AddIndex("Ind01", {"DESCRI"})
	oTmpTRB4:AddIndex("Ind02", {"CODIGO"})
	oTmpTRB4:Create()

	dbSelectArea(cQryAlias)
	While !Eof()

		nTotalAcum += (cQryAlias)->ACUMCON

		nAcumCon := If(Empty((cQryAlias)->ACUMCON),0,(cQryAlias)->ACUMCON)
		dbSelectArea(cTrb)
		dbSetOrder(2)
		If !dbSeek(cValToChar(Int((cQryAlias)->TQV_SULCO)))
			RecLock(cTrb,.T.)
			(cTrb)->CODIGO := cValToChar(Int((cQryAlias)->TQV_SULCO))
			(cTrb)->DESCRI := (cQryAlias)->DTHR
			If (cQryAlias)->TQV_BANDA == '1'
				(cTrb)->ORIGI   := nAcumCon
			ElseIf (cQryAlias)->TQV_BANDA == '2' .And. TQS->TQS_BANDAA >= '2'
				(cTrb)->VIDA1   := nAcumCon
			ElseIf (cQryAlias)->TQV_BANDA == '3' .And. TQS->TQS_BANDAA >= '3'
				(cTrb)->VIDA2   := nAcumCon
			ElseIf (cQryAlias)->TQV_BANDA == '4' .And. TQS->TQS_BANDAA >= '4'
				(cTrb)->VIDA3   := nAcumCon
			ElseIf (cQryAlias)->TQV_BANDA == '5' .And. TQS->TQS_BANDAA >= '5'
				(cTrb)->VIDA4   := nAcumCon
			EndIf
			MsUnLock()
		Else
			If ((cQryAlias)->TQV_BANDA == '1' .And. nAcumCon > (cTrb)->ORIGI) .Or. ;
			((cQryAlias)->TQV_BANDA == '2' .And. TQS->TQS_BANDAA >= '2' .And. nAcumCon > (cTrb)->VIDA1) .Or. ;
			((cQryAlias)->TQV_BANDA == '3' .And. TQS->TQS_BANDAA >= '3' .And. nAcumCon > (cTrb)->VIDA2) .Or. ;
			((cQryAlias)->TQV_BANDA == '4' .And. TQS->TQS_BANDAA >= '4' .And. nAcumCon > (cTrb)->VIDA3) .Or. ;
			((cQryAlias)->TQV_BANDA == '5' .And. TQS->TQS_BANDAA >= '5' .And. nAcumCon > (cTrb)->VIDA4)

				If (cQryAlias)->TQV_BANDA == '1'
					(cTrb)->ORIGI  := nAcumCon
				ElseIf (cQryAlias)->TQV_BANDA == '2'
					(cTrb)->VIDA1  := nAcumCon
				ElseIf (cQryAlias)->TQV_BANDA == '3'
					(cTrb)->VIDA2  := nAcumCon
				ElseIf (cQryAlias)->TQV_BANDA == '4'
					(cTrb)->VIDA3  := nAcumCon
				ElseIf (cQryAlias)->TQV_BANDA == '5'
					(cTrb)->VIDA4  := nAcumCon
				EndIf
			EndIf
		EndIf
		dbSelectArea(cQryAlias)
		dbSkip()
	EndDo

	dbSelectArea(cTrb)
	While !Eof()
		RecLock(cTrb,.F.)
		(cTrb)->DESCRI := STR0058 //"Milímetros"
		MsUnLock()
		dbSkip()
	EndDo

	(cTrb)->(dbSetOrder(1))
	(cQryAlias)->(dbCloseArea())

	If Empty(nTotalAcum) .Or. nTotalAcum == 0 //Testa se o pneu ja rodou.
		lGrafico := .F.
	EndIf

	If lGrafico
		cTitulo := STR0013 //"Gráfico de Km x MM"
		cTxt := NGGRAFICO(" "+cTitulo," "," ",cTitulo,STR0059,aLegenda,"A",cTrb,,'0') //'Sulco'
	Else
		MsgInfo(STR0064) //Não há dados para geração do gráfico
	EndIf

	(cTrb)->(dbCloseArea())

	oTmpTRB4:Delete()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ProxRecape ³Autor ³ Vitor Emanuel Batista ³ Data ³10/08/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna a proxima data de recape para o pneu                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTC125                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProxRecape()

	Local cQuery
	Local cQryAlias := GetNextAlias()
	Local dDtIni, nSulIni, dDtFim, nSulFim
	Local dDtProx
	Local nSulco, nVaria, nDias

	cQuery := " SELECT TQV_DTMEDI,TQV_SULCO FROM " + RetSqlName("TQV")
	cQuery += " WHERE D_E_L_E_T_ <> '*' AND TQV_FILIAL = "+ValToSql(xFilial("TQV"))
	cQuery += "     AND TQV_CODBEM = " + ValToSql(TQS->TQS_CODBEM)
	cQuery += "     AND TQV_BANDA  = " + ValToSql(TQS->TQS_BANDAA)
	cQuery += " ORDER BY TQV_DTMEDI,TQV_HRMEDI"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cQryAlias, .F., .T.)

	If !Eof()
		dDtIni := STOD((cQryAlias)->TQV_DTMEDI)
		nSulIni:= (cQryAlias)->TQV_SULCO

		dbSkip()
		While !Eof()
			dDtFim := STOD((cQryAlias)->TQV_DTMEDI)
			nSulFim:= (cQryAlias)->TQV_SULCO
			dbskip()
		EndDo

		If !Empty(dDtFim)

			nDias := dDtFim - dDtIni
			nSulco:= nSulIni - nSulFim

			nVaria  := nSulco / nDias
			If nVaria > 0
				dDtProx := dDataBase + ((TQS->TQS_SULCAT - 2) / nVaria)
				Return dDtProx
			EndIf

		EndIf

	EndIf

Return CTOD("  /  /  ")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AbreEmpresa³Autor ³ Vitor Emanuel Batista ³ Data ³18/02/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Abre empresa com SIX, SX2 e SX3                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AbreEmpresa()

	Local lOpen  := .F.
	Local cCodEmp  := ""
	Local cCodFil  := ""
	Local aTable   := {"ST9","ST6","STJ","TPY","STB","DA3"}

	//Abre tabelas necessarias
	If !(Type("oMainWnd")=="O")
		Private cAcesso := ""
		Private cPaisLoc:= ""

		cCodEmp := 'T3'
		cCodFil := 'M RJ 01 '

		RPCSetType(3) //Nao utiliza licensa
		//Abre empresa/filial/modulo/arquivos
		RPCSetEnv(cCodEmp,cCodFil,"","","MNT","",aTable)

		lOpen := .T.
	EndIf

Return lOpen

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIMPCPNEU
Seleciona tipo de relatório para pneu informado no parametro

@param String cPneu: indica código do bem pneu
@param Object oMainWnd: indica objeto pai da tela de seleção da impressão
@author André Felipe Joriatti
@since 27/02/2014
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Function NGIMPCPNEU( cPneu,oMainWnd )

	Local oDlgCons   := Nil
	Local lPrint     := IsInCallStack( "MNTC125" ) // alterar conforme a necessidade da chamada
	Local oRadMenu   := Nil
	Local nRadio     := 1
	Local aItens     := {}
	Local oGrpRadio  := Nil
	Local lOKImpPneu := .F.

	aAdd( aItens,"Estrutura do Rodado" ) // "Estrutura do Rodado"
	aAdd( aItens,"Análise Técnica" ) // "Análise Técnica"
	aAdd( aItens,"Histórico de Movimentação" ) // "Histórico de Movimentação"

	Define MsDialog oDlgCons Title OemToAnsi( "Impressão" ) From 020,000 To 200,300 Of oMainWnd Pixel // "Impressão"

	oGrpRadio := tGroup():New( 010,006,070,145,,oDlgCons,CLR_BLUE,,.T., )

	oRadMenu := tRadMenu():New( 025,012,aItens,{ |u| Iif( PCount() == 0,nRadio,nRadio := u ) },;
	oGrpRadio,,,,,"Selecione o tipo de Impressão",,,080,020,,,,.T., ) // "Selecione o tipo de Impressão"
	oRadMenu:SetOption( 1 )

	// Ok
	SButton():New( 075,087,1,{ || lOKImpPneu := .T., oDlgCons:End() },oDlgCons,.T.,"Confirmar Impressão." ) // "Confirmar Impressão."

	// Cancelar
	SButton():New( 075,117,2,{ || oDlgCons:End() },oDlgCons,.T.,"Cancelar Impressão." ) // "Cancelar Impressão."

	Activate MsDialog oDlgCons Centered

	If lOKImpPneu

		Do Case

			Case nRadio == _IMP_ESTRUTURA_RODADO_

			ImpRodados( cPneu,oMainWnd,lPrint )
			Case nRadio == _IMP_ANALISE_TECNICA_

			MNTR163( cPneu )
			Case nRadio == _IMP_HISTORICO_MOVIMENTACAO_

			fRelHstPneu( cPneu )
		EndCase

	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fRelHstPneu
Imprime relatório de histórico de movimentação do pneu informado no
parametro

@param String cPneu: indica código do bem pneu
@author André Felipe Joriatti
@since 27/02/2014
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fRelHstPneu( cPneu )
	MNTR881( cPneu )
Return Nil
