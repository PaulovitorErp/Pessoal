#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWBROWSE.CH'

//-----------------------------------------------------------------------
/*/{Protheus.doc} MNTC795
Consulta de Bem

@type function

@author Wagner S. de Lacerda
@since 01/09/2011

@param cParCodBem, Caractere, Indica o Codigo do Bem

@return L๓gico, Sempre verdadeiro
/*/
//-----------------------------------------------------------------------
Function MNTC795(cParCodBem)

	//------------------------------------------------------
	// Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	//------------------------------------------------------
	Local aNGBEGINPRM := NGBEGINPRM()

	Local nCorIntro
	Local oFont1Norm, oFont1Bold, oFont2

	Default cParCodBem := ""

	Private oDlgIntro, oBmpIntro, oMeter
	Private oSayIntro1, oSayIntro2, oSayMeter, oSayVersao
	Private nMeter, nMeterTot

	Private aAreaIni   := GetArea()
	Private aRotina    := aClone( MenuDef() )
	Private cCadastro  := OemToAnsi("Consulta de Bem")

	// A partir do release 12.1.33, o parโmetro MV_NGMNTFR serแ descontinuado
	// Haverแ modulo especํfico para a gestใo de Frotas no padrใo do produto
	Private lFrota     := IIf( FindFunction('MNTFrotas'), MNTFrotas(), SuperGetMV( 'MV_NGMNTFR', .F., 'N' ) == 'S' ) // Integracao com Frota
	Private lUsaIntTMS := lFrota .And. AllTrim( SuperGetMv( "MV_NGMNTMS", .F., .F., "N" ) ) == "S" // Integracao com TMS
	Private lUsaIntTQS := lFrota .And. AllTrim( SuperGetMv( "MV_NGPNEUS", .F., .F., "N" ) ) == "S" // Integracao com TQS (Pneus)
	Private lTT8Existe := NGCADICBASE("TT8_FILIAL","D","TT8",.F.)

	Private lDesTMS := .F., lLePlaca := .F., lLerTQS := .F.  //Utilizadas no Dicionario da Dados

	Private cPerg  := "MNC795" //Pergunta SX1 a rotina
	Private cGrupo := ""

	Private aSize    := MsAdvSize(.T.) //.T. - Tem EnchoiceBar
	Private nLargura := 0
	Private nAltura  := 0

	INCLUI := .F.
	ALTERA := .F.

	aSMenu := NGRIGHTCLICK("MNTC795")

	//-----------------------------------------------------------------------
	// Parametrizacao da Consulta (Perguntas do dicionario SX1):
	// MV_PAR01 - De Data MTBF/MTTR
	// MV_PAR02 - At้ Data MTBF/MTTR ?
	// MV_PAR03 - Hist๓rico MTBF/MTTR ?
	// MV_PAR04 - De Data Custos ?
	// MV_PAR05 - At้ Data Custos ?
	// MV_PAR06 - Hist๓rico Custos ?
	// MV_PAR07 - Tipos Man. Custos ?
	// MV_PAR08 - De Data Ranking ?
	// MV_PAR09 - At้ Data Ranking ?
	// MV_PAR10 - Hist๓rico Ranking ?
	//+-----------------------------------------------------------------------
	Pergunte(cPerg,.F.)

	//------------------
	// Inicio
	//------------------
	nMeter    := 0
	nMeterTot := 8

	nCorIntro := RGB(0, 74, 119)

	oFont1Norm := TFont():New("Arial", , 16, , .F., , , , , , .T.)
	oFont1Bold := TFont():New("Arial", , 24, , .T., , , , , , .T.)
	oFont2 := TFont():New( , , 12)

	DEFINE MSDIALOG oDlgIntro FROM 005,005 TO 415,690 COLOR CLR_BLACK,CLR_WHITE OF oMainWnd PIXEL ;
	STYLE nOr(DS_SYSMODAL,WS_MAXIMIZEBOX,WS_POPUP)

	oBmpIntro := TBitmap():New(0, 0, 20, 20, , "ng_intro_consultaos", .T., , , , .F., .F., , , .T., , .F., , .F.)
	oBmpIntro:lTransparent := .F.
	oBmpIntro:Align := CONTROL_ALIGN_ALLCLIENT

	oSayIntro1 := TSay():New(144, 162, {|| OemToAnsi("Consulta de")}, oBmpIntro, , oFont1Norm, , ; //"Consulta de"
	, , .T., nCorIntro, , 150, 030)

	oSayIntro2 := TSay():New(150, 168, {|| OemToAnsi("Bem")}, oBmpIntro, , oFont1Bold, , ; //"Bem"
	, , .T., nCorIntro, , 150, 030)

	oSayMeter := TSay():New(180, 130, {|| OemToAnsi("Iniciando Programa")+"..."}, oBmpIntro, , , , ; //"Iniciando Programa"
	, , .T., CLR_RED, , 150, 030)

	oMeter := TMeter():New(194, 128, {|u| If(PCount() > 0, nMeter := u, nMeter)},;
	100, oBmpIntro, 100, 008, , .T.)
	oMeter:SetTotal(nMeterTot)
	oMeter:Set(nMeter)
	oMeter:SetCSS("QProgressBar {margin:0px; background-color:#CDD1D4; border: 1px solid #CDD1D4;")

	oSayVersao := TSay():New(198, 313, {|| "v" + cValToChar()}, oBmpIntro, , oFont2, , ;
	, , .T., CLR_WHITE, , 150, 030)

	ACTIVATE MSDIALOG oDlgIntro ON INIT ( Eval({|| MNTC795BEM(cParCodBem)}),oDlgIntro:End() ) CENTERED

	//---------------------------------------------------
	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	//---------------------------------------------------
	NGRETURNPRM(aNGBEGINPRM)

	If Len(aAreaIni) > 0
		RestArea(aAreaIni)
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMenuDef   บAutor  ณWagner S. de Lacerdaบ Data ณ  01/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Utilizacao de Menu Funcional.                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Array com opcoes da rotina.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ  Parametros do array a Rotina:                             บฑฑ
ฑฑบ          ณ  1. Nome a aparecer no cabecalho                           บฑฑ
ฑฑบ          ณ  2. Nome da Rotina associada                               บฑฑ
ฑฑบ          ณ  3. Reservado                                              บฑฑ
ฑฑบ          ณ  4. Tipo de Transacao a ser efetuada:                      บฑฑ
ฑฑบ          ณ      1 - Pesquisa e Posiciona em um Banco de Dados         บฑฑ
ฑฑบ          ณ      2 - Simplesmente Mostra os Campos                     บฑฑ
ฑฑบ          ณ      3 - Inclui registros no Bancos de Dados               บฑฑ
ฑฑบ          ณ      4 - Altera o registro corrente                        บฑฑ
ฑฑบ          ณ      5 - Remove o registro corrente do Banco de Dados      บฑฑ
ฑฑบ          ณ 5. Nivel de acesso                                         บฑฑ
ฑฑบ          ณ 6. Habilita Menu Funcional                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()

	Local aRot

	aRot := {{ "Pesquisar" , "AxPesqui", 0 , 1},;     //"Pesquisar"
	{ "Visualizar", "NGCAD01" , 0 , 2},;     //"Visualizar"
	{ "Incluir"   , "NGCAD01" , 0 , 3},;     //"Incluir"
	{ "Alterar"   , "NGCAD01" , 0 , 4},;     //"Alterar"
	{ "Excluir"   , "NGCAD01" , 0 , 5, 3}	} //"Excluir"

Return aRot

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMNC795VLD บAutor  ณWagner S. de Lacerdaบ Data ณ  27/10/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao das Perguntas do dicionario SX1.                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nParam -> Obrigatorio;                                     บฑฑ
ฑฑบ          ณ           Indica qual parametro deve ser validado:         บฑฑ
ฑฑบ          ณ              1 - De Data MTBF e MTTR                       บฑฑ
ฑฑบ          ณ              2 - Ate Data MTBF e MTTR                      บฑฑ
ฑฑบ          ณ              4 - De Data Custos do Bem x Familia           บฑฑ
ฑฑบ          ณ              5 - Ate Data Custos do Bem x Familia          บฑฑ
ฑฑบ          ณ              7 - De Data Ranking dos Tipos de Manutencao   บฑฑ
ฑฑบ          ณ              8 - Ate Data Ranking dos Tipos de Manutencao  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNC795VLD(nParam)

	Local dVarDeDt  := CTOD("")
	Local dVarAteDt := CTOD("")
	Local lValidDe  := .T.

	Local aVarManut := {}
	Local cVarManut := ""
	Local nX := 0

	If nParam == 7
		cVarManut := MV_PAR07

		If Empty(cVarManut)
			ShowHelpDlg("Aten็ใo",;
			{"O tipo de manuten็ใo ้ invแlido."},2,;
			{"Favor preencher o tipo de manuten็ใo."},2)
			Return .F.
		Else
			aVarManut := aClone( StrTokArr(cVarManut,";") )

			nX := 0
			aEval(aVarManut, {|cVal| nX++, aVarManut[nX] := AllTrim(cVal) })
			If aScan(aVarManut , {|x| x <> "1" .And. x <> "2" .And. x <> "3" }) > 0
				ShowHelpDlg("Aten็ใo",;
				{"O tipo de manuten็ใo ้ invแlido."},2,;
				{"Favor preencher o tipo de manuten็ใo com apenas os valores '1', '2', e/ou '3' (separando-os com ';' caso selecione mais de um)."},2)
				Return .F.
			EndIf
		EndIf
	Else
		If nParam == 1 .Or. nParam == 2
			dVarDeDt  := MV_PAR01
			dVarAteDt := MV_PAR02

			lValidDe := ( nParam == 1 )
		ElseIf nParam == 4 .Or. nParam == 5
			dVarDeDt  := MV_PAR04
			dVarAteDt := MV_PAR05

			lValidDe := ( nParam == 4 )
		ElseIf nParam == 8 .Or. nParam == 9
			dVarDeDt  := MV_PAR08
			dVarAteDt := MV_PAR09

			lValidDe := ( nParam == 8 )
		EndIf

		If lValidDe
			If Empty(dVarDeDt)
				Return .T.
			ElseIf dVarDeDt > dDataBase
				ShowHelpDlg("Aten็ใo",;
				{"A data ้ invแlida."},2,;
				{"Favor selecionar um data inferior ou igual เ Data Atual."},2)
				Return .F.
			ElseIf !Empty(dVarAteDt) .And. dVarDeDt > dVarAteDt
				ShowHelpDlg("Aten็ใo",;
				{"A data ้ invแlida."},2,;
				{"Favor selecionar um data inferior ou igual เ Data 'At้'."},2)
				Return .F.
			EndIf
		Else
			If Empty(dVarAteDt)
				Return .T.
			ElseIf dVarAteDt > dDataBase
				ShowHelpDlg("Aten็ใo",;
				{"A data ้ invแlida."},2,;
				{"Favor selecionar um data inferior ou igual เ Data Atual."},2)
				Return .F.
			ElseIf !Empty(dVarDeDt) .And. dVarAteDt < dVarDeDt
				ShowHelpDlg("Aten็ใo",;
				{"A data ้ invแlida."},2,;
				{"Favor selecionar um data superior ou igual เ Data 'De'."},2)
				Return .F.
			EndIf
		EndIf
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMNTC795BEMบAutor  ณWagner S. de Lacerdaบ Data ณ  01/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta a tela da Consulta de Bem.                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cParCodBem -> Opcional;                                    บฑฑ
ฑฑบ          ณ               Indica o Codigo do Bem                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC795BEM(cParCodBem)

	Local aTempColor
	Local oTempGet

	Default cParCodBem := ""

	/* Variaveis da Janela */
	Private aAreaST9 := {}
	Private aAreaTPE := {}
	Private aAreaDA3 := {}
	Private aAreaTQS := {}
	Private aAcessoChg := {} //Variavel para controlar se o usuario ja acessou determinado dialog

	Private lTemCaract := .F. //Indica se o Bem possui Dados nas 'Caracteristicas'
	Private lTemPecRep := .F. //Indica se o Bem possui Dados nas 'Pecas de Reposicao'
	Private lTemIntTMS := .F. //Indica se o Bem possui Dados na DA3 (Integracao com TMS)
	Private lTemIntPne := .F. //Indica se o Bem possui Dados na TQS (Integracao com Pneu)
	Private lTemComVei := .F. //Indica se o Bem possui Dados no 'Complemento Veiculo'
	Private lTemManute := .F. //Indica se o Bem possui Dados na 'Manutencao'
	Private lTemManOrd := .F. //Indica se o Bem possui Dados na 'Ordem de Servico da Manutencao'
	Private lTemOrdemS := .F. //Indica se o Bem possui Dados na 'Historico de Ordem de Servico'
	Private lTemEstrut := .F. //Indica se o Bem possui Dados na 'Movimentacoes na Estrutura'
	Private lTemMovime := .F. //Indica se o Bem possui Dados na 'Movimentacoes do Bem'

	Private lBemConta1 := .F. //Indica se o Bem possui o Contador 1
	Private lBemConta2 := .F. //Indica se o Bem possui o Contador 2

	Private cTabela := "ST9"
	Private nCorCabec
	Private nCorFore, nCorBack
	/**/

	/* Variaveis Padroes da Rotina */
	Private oDlgCBEM, oBlackPnl
	Private aCBEMBtns, bCBEMOk, bCBEMCanc
	Private oPnlDlgBem
	Private oFontNorm, oFontBold
	Private lCBEMAtu := Nil //Variavel que define se pode atualizar a consulta (F5)
	/**/

	/* Variaveis do FWLayer */
	Private oLayerBem
	Private oMenuLater
	Private oCabecalho
	Private oConsulta
	/**/

	/* Variaveis do Cabecalho */
	Private oCbcPnlPai, oCbcScroll
	Private oCodigoBem, cCodigoBem, cOldCodBem
	Private oNomeBem  , cNomeBem
	Private oCodModBem, cCodModBem, oNomModBem, cNomModBem
	Private oCodFamBem, cCodFamBem, oNomFamBem, cNomFamBem
	Private cCodCatBem, oNomCatBem, cNomCatBem
	Private cCodSitBem, oNomSitBem, cNomSitBem
	Private oCodStaBem, cCodStaBem, oNomStaBem, cNomStaBem
	Private oCodTurBem, cCodTurBem, oNomTurBem, cNomTurBem
	Private oPrioriBem, cPrioriBem
	/**/

	/* Variaveis da Consulta (Conteudo) */
	Private oConPnlPai
	Private oConObjTmp
	Private oConAtual , cConAtual

	Private oConInfo00
	Private oI00Say

	Private oConInfo01
	Private oI01Folder //Folder dos Dados Cadastrais
	Private nI01Bem, nI01Crt, nI01PeR, nI01TMS, nI01Pne, nI01CoV //Numero de cada Folder principal
	Private oI01Bem, aI01Bem
	Private oI01Crt, aI01CrtHea, aI01CrtCol
	Private oI01PeR, aI01PeRHea, aI01PeRCol
	Private oI01TMS
	Private oI01Pne
	Private oI01CoV, aI01CoV
	Private oI01FichaT //Ficha Tecnica
	Private oI01FcTMnu
	Private oI01FcT, aI01FcT
	Private oI01Contad //Contador
	Private oI01Cnt1Say, oI01Cnt2Say
	Private oI01Cnt1Pai, oI01Cnt1Mnu
	Private oI01Cnt1, aI01Cnt1
	Private oI01Cnt2Pai, oI01Cnt2Mnu
	Private oI01Cnt2, aI01Cnt2

	Private oConInfo02
	Private oI02TNGPnl

	Private oConInfo03
	Private oI03ManPai, oI03ManRod
	Private oI03Man, aI03ManHea, aI03ManCol
	Private oI03OrdPai, oI03OrdRod
	Private oI03Ord, aI03OrdHea, aI03OrdCol, dI03DeDt, dI03AteDt, lI03OrdHis

	Private oConInfo04
	Private oI04OrdPai, oI04OrdRod
	Private oI04Ord, aI04OrdHea, aI04OrdCol, cI04Filtro, cI04FilSTJ, cI04FilSTS

	Private oConInfo05
	Private oI05EstPai, oI05EstSay, oI05EstRod
	Private oI05Est, aI05EstHea, aI05EstCol
	Private oI05MovPai, oI05MovSay, oI05MovRod
	Private oI05Mov, aI05MovHea, aI05MovCol
	/**/

	/* Variaveis do Resumo do Bem */
	Private oResPnlPai, oResScroll
	Private oResCodBem, oResNomBem
	/**/

	/* Variaveis do Menu Lateral */
	Private oMnuPnlPai
	Private oTree, aTreeNivs
	/**/

	MNTC795INI() //Inicializa as Variaveis

	//Fontes
	oFontNorm := TFont():New(, , 14, .T., .F.)
	oFontBold := TFont():New(, , 16, .T., .T.)

	//Cores
	nCorCabec := CLR_BLACK

	aTempColor := aClone( NGCOLOR() )
	nCorFore := aTempColor[1]
	nCorBack := aTempColor[2]

	//Define Teclas de Atalho
	SETKEY(VK_F5, {|| MNTC795ATU() }) //F5: Atualiza a Tela

	//Botos adicionais da EnchoiceBar
	aCBEMBtns := {}
	aAdd(aCBEMBtns, { "reload", {|| MNTC755ATU()}, OemToAnsi("Atualizar Consulta"), OemToAnsi("Atualizar") })

	//Blocos de Codigo dos botoes de Confirmar e Fechar
	bCBEMOk   := {|| oDlgCBEM:End() }
	bCBEMCanc := {|| oDlgCBEM:End() }

	//Nao permite atualizar a consulta (deixando a variavel como nao criada - isto afeta a mensagem em tela)
	lCBEMAtu := Nil

	//Introducao
	nMeter++
	oMeter:Set(nMeter)
	oSayMeter:SetText(OemToAnsi("Carregando Objetos")+"...")
	oSayMeter:CtrlRefresh()

	DEFINE MSDIALOG oDlgCBEM TITLE cCadastro FROM aSize[7],0 TO aSize[6],aSize[5] COLOR CLR_BLACK, CLR_WHITE OF oMainWnd PIXEL

	oDlgCBEM:lEscClose := .F.

	oDlgCBEM:lMaximized := .T.

	dbSelectArea("ST9")
	PutFileInEof("ST9")
	RegToMemory("ST9",.F.)

	dbSelectArea("TPE")
	PutFileInEof("TPE")
	RegToMemory("TPE",.F.)

	dbSelectArea("DA3")
	PutFileInEof("DA3")
	RegToMemory("DA3",.F.)

	dbSelectArea("TQS")
	PutFileInEof("TQS")
	RegToMemory("TQS",.F.)

	//Painel do Dialog
	oPnlDlgBem := TPanel():New(01, 01, , oDlgCBEM, , , , CLR_BLACK, CLR_WHITE, 1000, 1000)
	oPnlDlgBem:Align := CONTROL_ALIGN_ALLCLIENT

	//+------------------+
	//| Layer            |
	//+------------------+
	oLayerBem := FWLayer():New()
	oLayerBem:Init(oPnlDlgBem, .F.)

	fLayout() //Cria o Layout da Tela

	//+------------------+
	//| Cabecalho        |
	//+------------------+
	//Painel Pai do Cabecalho
	oCbcPnlPai := TPanel():New(01, 01, , oCabecalho, , , , CLR_BLACK, CLR_WHITE, 100, 100)
	oCbcPnlPai:Align := CONTROL_ALIGN_ALLCLIENT
	oCbcPnlPai:CoorsUpdate()

	//Scroll do Cabecalho
	oCbcScroll := TScrollBox():New(oCbcPnlPai, 0, 0, (oCbcPnlPai:nClientHeight * 0.50), (oCbcPnlPai:nClientWidth * 0.50), .T., .T., .T.)

	//--- Codigo do Bem
	@ 005,010 SAY OemToAnsi("Bem"+":") FONT oFontBold COLOR nCorCabec OF oCbcScroll PIXEL
	oCodigoBem := TGet():New(004, 040, {|u| If(PCount() > 0, cCodigoBem := u, cCodigoBem)}, oCbcScroll, 080, 008, X3Picture("T9_CODBEM"),;
	{|| MNTC795VBE(), fAtuMemory("ST9"), fAtuMemory("TPE"), fAtuMemory("DA3"), fAtuMemory("TQS") }, nCorCabec, CLR_WHITE, oFontNorm,;
	.F., , .T./*lPixel*/, , .F., {|| If(Empty(cParCodBem),.T.,.F.) }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "ST9", "cCodigoBem", , , , .T./*lHasButton*/)
	oCodigoBem:bHelp := {|| ShowHelpCpo("Bem",;
	{"C๓digo do Bem"+"."},2,;
	{},2)}
	//--- Nome do Bem
	oNomeBem := TGet():New(004, 130, {|| cNomeBem}, oCbcScroll, 150, 008, X3Picture("T9_NOME"), {|| .T. }, nCorCabec, CLR_WHITE, oFontNorm,;
	.F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "cNomeBem", , , , .F./*lHasButton*/)
	oNomeBem:bHelp := {|| ShowHelpCpo("Nome do Bem",;
	{"Nome do Bem"+"."},2,;
	{},2)}

	//Campo utilizado apenas para chumbar o foco para fora do campo do Bem, executando assim o seu 'Valid' - DEVE ESTAR EM OUTRO OBJETO, POR CAUSO DO SCROLL.
	oTempGet := TGet():New(004, 1000+nLargura, {|| }, oCbcPnlPai, 040, 008, "@!", {|| }, CLR_BLACK, CLR_WHITE, oFontNorm,;
	.F., , .T./*lPixel*/, , .F., {|| .T. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "", , , , /*lHasButton*/)

	//--- Modelo do Bem
	@ 020,010 SAY OemToAnsi("Modelo"+":") FONT oFontNorm COLOR nCorCabec OF oCbcScroll PIXEL
	oCodModBem := TGet():New(019, 040, {|| cCodModBem}, oCbcScroll, 060, 008, X3Picture("TQR_TIPMOD"), {|| .T. }, nCorCabec, CLR_WHITE, oFontNorm,;
	.F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "cCodModBem", , , , .F./*lHasButton*/)
	oCodModBem:bHelp := {|| ShowHelpCpo("Modelo",;
	{"C๓digo do Modelo do Bem"+"."},2,;
	{},2)}
	//--- Nome do Modelo do Bem
	oNomModBem := TGet():New(019, 130, {|| cNomModBem}, oCbcScroll, 150, 008, X3Picture("TQR_DESMOD"), {|| .T. }, nCorCabec, CLR_WHITE, oFontNorm,;
	.F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "cNomModBem", , , , .F./*lHasButton*/)
	oNomModBem:bHelp := {|| ShowHelpCpo("Nome Modelo",;
	{"Nome do Modelo do Bem"+"."},2,;
	{},2)}

	//--- Familia do Bem
	@ 035,010 SAY OemToAnsi("Famํlia"+":") FONT oFontNorm COLOR nCorCabec OF oCbcScroll PIXEL
	oCodFamBem := TGet():New(034, 040, {|| cCodFamBem}, oCbcScroll, 060, 008, X3Picture("T6_CODFAMI"), {|| .T. }, nCorCabec, CLR_WHITE, oFontNorm,;
	.F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "cCodFamBem", , , , .F./*lHasButton*/)
	oCodFamBem:bHelp := {|| ShowHelpCpo("Familia",;
	{"C๓digo da Famํlia do Bem"+"."},2,;
	{},2)}
	//--- Nome da Familia do Bem
	oNomFamBem := TGet():New(034, 130, {|| cNomFamBem}, oCbcScroll, 150, 008, X3Picture("T6_NOME"), {|| .T. }, nCorCabec, CLR_WHITE, oFontNorm,;
	.F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "cNomFamBem", , , , .F./*lHasButton*/)
	oNomFamBem:bHelp := {|| ShowHelpCpo("Nome Familia",;
	{"Nome da Famํlia do Bem"+"."},2,;
	{},2)}

	//--- Turno do Bem
	@ 050,010 SAY OemToAnsi("Turno"+":") FONT oFontNorm COLOR nCorCabec OF oCbcScroll PIXEL
	oCodTurBem := TGet():New(049, 040, {|| cCodTurBem}, oCbcScroll, 040, 008, X3Picture("H7_CODIGO"), {|| .T. }, nCorCabec, CLR_WHITE, oFontNorm,;
	.F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "cCodTurBem", , , , .F./*lHasButton*/)
	oCodTurBem:bHelp := {|| ShowHelpCpo("Turno",;
	{"C๓digo do Turno do Bem"+"."},2,;
	{},2)}
	//--- Nome do Turno do Bem
	oNomTurBem := TGet():New(049, 130, {|| cNomTurBem}, oCbcScroll, 120, 008, X3Picture("H7_DESCRI"), {|| .T. }, nCorCabec, CLR_WHITE, oFontNorm,;
	.F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "cNomTurBem", , , , .F./*lHasButton*/)
	oNomTurBem:bHelp := {|| ShowHelpCpo("Nome Turno",;
	{"Nome do Turno do Bem"+"."},2,;
	{},2)}

	//--- Categoria do Bem
	@ 005,300 SAY OemToAnsi("Categoria"+":") FONT oFontNorm COLOR nCorCabec OF oCbcScroll PIXEL
	oNomCatBem := TGet():New(004, 340, {|| cNomCatBem}, oCbcScroll, 100, 008, X3Picture("T9_CATBEM"), {|| .T. }, nCorCabec, CLR_WHITE, oFontNorm,;
	.F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "cNomCatBem", , , , .F./*lHasButton*/)
	oNomCatBem:bHelp := {|| ShowHelpCpo("Categoria",;
	{"Categoria do Bem"+"."},2,;
	{},2)}

	//--- Situacao do Bem
	@ 020,300 SAY OemToAnsi("Situa็ใo"+":") FONT oFontNorm COLOR nCorCabec OF oCbcScroll PIXEL
	oNomSitBem := TGet():New(019, 340, {|| cNomSitBem}, oCbcScroll, 060, 008, X3Picture("TQY_DESTAT"), {|| .T. }, nCorCabec, CLR_WHITE, oFontNorm,;
	.F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "cNomSitBem", , , , .F./*lHasButton*/)
	oNomSitBem:bHelp := {|| ShowHelpCpo("Situacao",;
	{"Situa็ใo do Bem"+"."},2,;
	{},2)}

	//--- Status do Bem
	@ 035,300 SAY OemToAnsi("Status"+":") FONT oFontNorm COLOR nCorCabec OF oCbcScroll PIXEL
	oCodStaBem := TGet():New(034, 340, {|| cCodStaBem}, oCbcScroll, 040, 008, X3Picture("TQY_STATUS"), {|| .T. }, nCorCabec, CLR_WHITE, oFontNorm,;
	.F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "cCodStaBem", , , , .F./*lHasButton*/)
	oCodStaBem:bHelp := {|| ShowHelpCpo("Status",;
	{"C๓digo do Status do Bem"+"."},2,;
	{},2)}
	oNomStaBem := TGet():New(034, 390, {|| cNomStaBem}, oCbcScroll, 120, 008, X3Picture("TQY_DESTAT"), {|| .T. }, nCorCabec, CLR_WHITE, oFontNorm,;
	.F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "cNomStaBem", , , , .F./*lHasButton*/)
	oNomStaBem:bHelp := {|| ShowHelpCpo("Nome Status",;
	{"Nome do Status do Bem"+"."},2,;
	{},2)}

	//--- Prioridade do Bem
	@ 050,300 SAY OemToAnsi("Prioridade"+":") FONT oFontNorm COLOR nCorCabec OF oCbcScroll PIXEL
	oPrioriBem := TGet():New(049, 340, {|| cPrioriBem}, oCbcScroll, 040, 008, X3Picture("T9_PRIORID"), {|| .T. }, nCorCabec, CLR_WHITE, oFontNorm,;
	.F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "cPrioriBem", , , , .F./*lHasButton*/)
	oPrioriBem:bHelp := {|| ShowHelpCpo("Prioridade",;
	{"Prioridade do Bem"+"."},2,;
	{},2)}

	//------------------------------------------------------------------------------------------------------------------------//

	//+------------------+
	//| Menu Lateral     |
	//+------------------+
	//Painel Pai do Menu Lateral
	oMnuPnlPai := TPanel():New(01, 01, , oMenuLater, , , , CLR_BLACK, CLR_WHITE, 100, 100)
	oMnuPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

	//--- Painel Pai do Resumo do Bem
	oResPnlPai := TPanel():New(01, 01, , oMnuPnlPai, , , , CLR_BLACK, nCorBack, 100, 060)
	oResPnlPai:Align := CONTROL_ALIGN_TOP

	//Scroll do Resumo
	oResScroll := TScrollBox():New(oResPnlPai, 0, 0, (oResPnlPai:nClientHeight * 0.50), (oResPnlPai:nClientWidth * 0.49), .F., .T., .T.)

	//Painel de Fundo do Resumo
	oPnlTempX := TPanel():New(01, 01, , oResScroll, , , , CLR_BLACK, nCorBack, 170/*(oResPnlPai:nClientWidth * 0.55)*/, (oResPnlPai:nClientHeight * 0.50))

	//--- Codigo do Bem
	@ 005,005 SAY OemToAnsi("Bem"+":") FONT oFontBold COLOR nCorCabec OF oPnlTempX PIXEL
	oResCodBem := TGet():New(015, 005, {|u| If(PCount() > 0, cCodigoBem := u, cCodigoBem)}, oPnlTempX, 080, 008, X3Picture("T9_CODBEM"),;
	{|| MNTC795VBE(), fAtuMemory("ST9"), fAtuMemory("TPE"), fAtuMemory("DA3"), fAtuMemory("TQS") }, nCorCabec, CLR_WHITE, oFontNorm,;
	.F., , .T./*lPixel*/, , .F., {|| If(Empty(cParCodBem),.T.,.F.) }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "ST9", "cCodigoBem", , , , .T./*lHasButton*/)
	oResCodBem:bHelp := {|| ShowHelpCpo("Bem",;
	{"C๓digo do Bem"+"."},2,;
	{},2)}
	//--- Nome do Bem
	oResNomBem := TGet():New(030, 005, {|| cNomeBem}, oPnlTempX, 150, 008, X3Picture("T9_NOME"), {|| .T. }, nCorCabec, CLR_WHITE, oFontNorm,;
	.F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "cNomeBem", , , , .F./*lHasButton*/)
	oResNomBem:bHelp := {|| ShowHelpCpo("Nome do Bem",;
	{"Nome do Bem"+"."},2,;
	{},2)}

	//--- Arvore do Menu Lateral
	oTree := DbTree():New(01, 01, 100, 100, oMnuPnlPai, , , .T.)
	oTree:bChange := {|| fTreeChg(), fAtuMemory("ST9"), fAtuMemory("TPE"), fAtuMemory("DA3"), fAtuMemory("TQS") }

	oTree:Align := CONTROL_ALIGN_ALLCLIENT

	//------------------------------------------------------------------------------------------------------------------------//

	//+------------------+
	//| Consulta         |
	//+------------------+
	//Painel Pai da Consulta
	oConPnlPai := TPanel():New(01, 01, , oConsulta, , , , CLR_BLACK, CLR_WHITE, 100, 100)
	oConPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

	//Objeto para conter o SAY da Identificacao
	oConObjTmp := TPanel():New(01, 01, , oConPnlPai, , , , , nCorBack, 100, 10)
	oConObjTmp:Align := CONTROL_ALIGN_TOP

	//Identificacao do que esta' sendo visualizado atualmente
	cConAtual := "Bem"
	oConAtual := TSay():New(001, 012, {|| OemToAnsi(cConAtual)}, oConObjTmp, , oFontBold, , ;
	, ,.T., nCorFore, , 150, 010)

	//Introducao
	nMeter++
	oMeter:Set(nMeter)
	oSayMeter:CtrlRefresh()
	MNTC795I00() //Estrutura do Bem

	//Introducao
	nMeter++
	oMeter:Set(nMeter)
	oSayMeter:CtrlRefresh()
	MNTC795I01() //Dados Cadastrais

	//Introducao
	nMeter++
	oMeter:Set(nMeter)
	oSayMeter:CtrlRefresh()
	MNTC795I02() //Indicadores

	//Introducao
	nMeter++
	oMeter:Set(nMeter)
	oSayMeter:CtrlRefresh()
	MNTC795I03() //Manutencoes

	//Introducao
	nMeter++
	oMeter:Set(nMeter)
	oSayMeter:CtrlRefresh()
	MNTC795I04() //Historico de O.S.

	//Introducao
	nMeter++
	oMeter:Set(nMeter)
	oSayMeter:CtrlRefresh()
	MNTC795I05() //Historico de Movimentacoes

	//------------------------------------------------------------------------------------------------------------------------//

	//Introducao
	nMeter++
	oMeter:Set(nMeter)
	oSayMeter:SetText(OemToAnsi("Finalizando Configura็ใo")+"...")
	oSayMeter:CtrlRefresh()

	//------------------------------------------------------------------------------------------------------------------------//

	//--- Carrega a Arvore do Menu Lateral
	fInitTree()
	fTreeChg()

	//--- Esconde a Introducao
	oBmpIntro:Hide()

	//--- Foca o Codigo do Bem
	oCodigoBem:SetFocus()

	//--- Define o Cabecalho a ser mostrado
	If oCabecalho:lVisible
		oResPnlPai:Hide() //Esconde o Resumo do Cabecablho
	Else
		oResPnlPai:Show() //Mostra o Resumo do Cabecablho
	EndIf

	//Permite atualizar a consulta
	lCBEMAtu := .T.

	ACTIVATE MSDIALOG oDlgCBEM ON INIT EnchoiceBar(oDlgCBEM, bCBEMOk, bCBEMCanc, , aCBEMBtns)

	//Devolve Teclas de Atalho
	SETKEY(VK_F5, {|| })

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfLayout   บAutor  ณWagner S. de Lacerdaบ Data ณ  01/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria o Layout da tela da Consulta de Bem.                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fLayout()

	//Linhas
	oLayerBem:AddLine("Linha_Cabecalho", 025, .F.)
	oLayerBem:AddLine("Linha_Consulta" , If(nAltura > 800,070,068), .F.)

	//Colunas
	oLayerBem:AddCollumn("Coluna_Cabecalho", 100, .F., "Linha_Cabecalho")
	oLayerBem:AddCollumn("Coluna_Menu"     , 020, .F., "Linha_Consulta")
	oLayerBem:AddCollumn("Coluna_Consulta" , 080, .F., "Linha_Consulta")

	//Janela do Cabecalho
	oLayerBem:AddWindow("Coluna_Cabecalho", "Janela_Cabecalho", OemToAnsi("Cabe็alho"), 100,;
	.F., .F., /*bAction*/, "Linha_Cabecalho", /*bGotFocus*/)

	//Janela do Menu
	oLayerBem:AddWindow("Coluna_Menu", "Janela_Menu", OemToAnsi("Menu"), 100,;
	.F., .F., /*bAction*/, "Linha_Consulta", /*bGotFocus*/)

	//Janela da Consulta
	oLayerBem:AddWindow("Coluna_Consulta", "Janela_Consulta", OemToAnsi("Consulta"), 100,;
	.F., .F., /*bAction*/, "Linha_Consulta", /*bGotFocus*/)

	//Split do Cabcecalho
	oLayerBem:SetLinSplit("Linha_Cabecalho", CONTROL_ALIGN_BOTTOM, {|| fRefrshWnd(.T.)} )
	//Split do Menu
	oLayerBem:SetColSplit("Coluna_Menu", CONTROL_ALIGN_RIGHT, "Linha_Consulta", {|| fRefrshWnd()} )

	//Objetos
	oCabecalho := oLayerBem:GetWinPanel("Coluna_Cabecalho", "Janela_Cabecalho", "Linha_Cabecalho")
	oMenuLater := oLayerBem:GetWinPanel("Coluna_Menu"     , "Janela_Menu"     , "Linha_Consulta" )
	oConsulta  := oLayerBem:GetWinPanel("Coluna_Consulta" , "Janela_Consulta" , "Linha_Consulta" )

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMNTC795I00บAutor  ณWagner S. de Lacerdaบ Data ณ  10/01/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta a Informacao da Estrutura do Bem.                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC795I00()

	If Type("oConInfo00") <> "O"
		//Painel Pai da Informacao - Estrutura do Bem
		oConInfo00 := TPanel():New(01, 01, , oConPnlPai, , , , CLR_BLACK, CLR_WHITE, 1000, 1000)
		oConInfo00:Align := CONTROL_ALIGN_ALLCLIENT
	Else
		oConInfo00:FreeChildren()
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMNTC795I01บAutor  ณWagner S. de Lacerdaบ Data ณ  06/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta a Informacao dos Dados Cadastrais.                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC795I01()

	Local aPos     := {}
	Local aPrompts := {}, nPrompt
	Local aDialogs := {}
	Local nX := 0

	Local oObjSplit
	Local oTmpPnlSay

	Local aFcTMenu
	Local aCntMenu

	//Painel Pai da Informacao - Dados Cadastrais
	oConInfo01 := TPanel():New(01, 01, , oConPnlPai, , , , CLR_BLACK, CLR_WHITE, 1000, 1000)
	oConInfo01:Align := CONTROL_ALIGN_ALLCLIENT

	//+----------------------------+
	//| Dados Cadastrais           |
	//+----------------------------+
	nI01Bem := 0
	nI01Crt := 0
	nI01PeR := 0
	nI01TMS := 0
	nI01Pne := 0
	nI01CoV := 0

	nPrompt := 0
	aPrompts := {}

	aAdd(aPrompts, "Bem")
	nPrompt++
	nI01Bem := nPrompt

	aAdd(aPrompts, "Caracterํsticas")
	nPrompt++
	nI01Crt := nPrompt

	aAdd(aPrompts, "Pe็as de Reposi็ใo")
	nPrompt++
	nI01PeR := nPrompt

	If lUsaIntTMS
		aAdd(aPrompts, "TMS")
		nPrompt++
		nI01TMS := nPrompt
	EndIf

	If lUsaIntTQS
		aAdd(aPrompts, "Pneu")
		nPrompt++
		nI01Pne := nPrompt
	EndIf

	aAdd(aPrompts, "Complemento Veํculo")
	nPrompt++
	nI01CoV := nPrompt

	aDialogs := aClone( aPrompts )

	//--- Folder dos Dados Cadastrais
	oI01Folder := TFolder():New(01, 01, aPrompts, aDialogs, oConInfo01, 1, CLR_BLACK, CLR_WHITE, .T., , 1000, 1000)
	oI01Folder:Align := CONTROL_ALIGN_ALLCLIENT

	For nX := 1 To Len(oI01Folder:aDialogs)
		oI01Folder:aDialogs[nX]:oFont := oDlgCBEM:oFont
	Next nX

	oI01Folder:bChange := {|| fI01Entra() }

	//-- Define posi็๕es do MsMGet
	aPos := {0,0,(oConInfo01:nClientHeight*0.50),(oConInfo01:nClientWidth*0.50)}

	//------------------------------------------------------------------------------------------------------------------------//
	aGets := {}
	aTela := {}
	//--- Bem
	oI01Bem := MsMGet():New(cTabela,RecNo(),2,/*aCRA*/,/*cLetras*/,/*cTexto*/,aI01Bem/*aChoice*/,aPos/*aPos*/,/*aCpos*/,;
	3/*nModelo*/,/*nColMens*/,/*cMensagem*/,/*cTudoOk*/,oI01Folder:aDialogs[nI01Bem]/*oDlg*/,/*lF3*/,.T./*lMemoria*/,.F./*lColumn*/,;
	/*caTela*/,/*lNoFolder*/,/*lProperty*/,/*aField*/)
	oI01Bem:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	//------------------------------------------------------------------------------------------------------------------------//

	//--- Caracteristicas
	oI01Crt := fMontaBrw(@aI01CrtHea, @aI01CrtCol, @oI01Folder:aDialogs[nI01Crt])
	oI01Crt:SetArray(aI01CrtCol)
	oI01Crt:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	//------------------------------------------------------------------------------------------------------------------------//

	//--- Pecas de Reposicao
	oI01PeR := fMontaBrw(@aI01PeRHea, @aI01PeRCol, @oI01Folder:aDialogs[nI01PeR])
	oI01PeR:SetArray(aI01PeRCol)
	oI01PeR:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	//------------------------------------------------------------------------------------------------------------------------//
	aGets := {}
	aTela := {}
	If lUsaIntTMS
		//--- TMS
		oI01TMS := MsMGet():New("DA3",RecNo(),2,/*aCRA*/,/*cLetras*/,/*cTexto*/,/*aChoice*/,aPos/*aPos*/,/*aCpos*/,;
		3/*nModelo*/,/*nColMens*/,/*cMensagem*/,/*cTudoOk*/,oI01Folder:aDialogs[nI01TMS]/*oDlg*/,/*lF3*/,.T./*lMemoria*/,.F./*lColumn*/,;
		/*caTela*/,/*lNoFolder*/,/*lProperty*/,/*aField*/)
		oI01TMS:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	EndIf

	//------------------------------------------------------------------------------------------------------------------------//
	aGets := {}
	aTela := {}
	If lUsaIntTQS
		//--- Pneu
		oI01Pne := MsMGet():New("TQS",RecNo(),2,/*aCRA*/,/*cLetras*/,/*cTexto*/,/*aChoice*/,aPos/*aPos*/,/*aCpos*/,;
		3/*nModelo*/,/*nColMens*/,/*cMensagem*/,/*cTudoOk*/,oI01Folder:aDialogs[nI01Pne]/*oDlg*/,/*lF3*/,.T./*lMemoria*/,.F./*lColumn*/,;
		/*caTela*/,/*lNoFolder*/,/*lProperty*/,/*aField*/)
		oI01Pne:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	EndIf

	//------------------------------------------------------------------------------------------------------------------------//
	aGets := {}
	aTela := {}
	//--- Complemento Veiculo
	oI01CoV := MsMGet():New("ST9",RecNo(),2,/*aCRA*/,/*cLetras*/,/*cTexto*/,aI01CoV/*aChoice*/,aPos/*aPos*/,/*aCpos*/,;
	3/*nModelo*/,/*nColMens*/,/*cMensagem*/,/*cTudoOk*/,oI01Folder:aDialogs[nI01CoV]/*oDlg*/,/*lF3*/,.T./*lMemoria*/,.F./*lColumn*/,;
	/*caTela*/,/*lNoFolder*/,/*lProperty*/,/*aField*/)
	oI01CoV:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	//------------------------------------------------------------------------------------------------------------------------//

	//+----------------------------+
	//| Ficha Tecnica              |
	//+----------------------------+
	//--- Painel da Ficha Tecnica
	oI01FichaT := TPanel():New(01, 01, , oConInfo01, , , , CLR_BLACK, CLR_WHITE, 100, 100)
	oI01FichaT:Align := CONTROL_ALIGN_ALLCLIENT

	//--- Ficha Tecnica
	oI01FcT := MsMGet():New("ST9",RecNo(),2,/*aCRA*/,/*cLetras*/,/*cTexto*/,aI01FcT/*aChoice*/,aPos/*aPos*/,/*aCpos*/,;
	3/*nModelo*/,/*nColMens*/,/*cMensagem*/,/*cTudoOk*/,oI01FichaT/*oDlg*/,/*lF3*/,.T./*lMemoria*/,.F./*lColumn*/,;
	/*caTela*/,/*lNoFolder*/,/*lProperty*/,/*aField*/)
	oI01FcT:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	//Menu do Clique da Direita
	aFcTMenu := {	{"ฺltimas Pe็as de Reposi็ใo","!NGCallStack('MNTA080PER',.T.) .And. MNTA080PER(cCodigoBem)"},;
	{"Curva da Banheira","!NGCallStack('MNTC085',.T.) .And. MNTC085(cCodigoBem)"},;
	{"Curva de Custos","!NGCallStack('MNTC075',.T.) .And. MNTC075(cCodigoBem)"}	}
	//Clique da Direita
	NGPOPUP(aFcTMenu,@oI01FcTMnu,oI01FcT:oBox)
	oI01FcT:oBox:bRClicked:= { |o,x,y| oI01FcTMnu:Activate(x,y,oI01FcT:oBox)}

	//------------------------------------------------------------------------------------------------------------------------//

	//+----------------------------+
	//| Contador                   |
	//+----------------------------+
	//--- Painel dos Contadores
	oI01Contad := TPanel():New(01, 01, , oConInfo01, , , , CLR_BLACK, CLR_WHITE, 100, 100)
	oI01Contad:Align := CONTROL_ALIGN_ALLCLIENT

	//Splitter da Tela
	oObjSplit := TSplitter():New(01, 01, oI01Contad, 10, 10)
	oObjSplit:SetOrient(0)
	oObjSplit:Align := CONTROL_ALIGN_ALLCLIENT

	//Menu do Clique da Direita
	aCntMenu := {	{"Hist๓rico de Contadores","!NGCallStack('MNTA080HCO',.T.) .And. MNTA080HCO(cCodigoBem)"},;
	{"Grแfico de Varia็ใo","!NGCallStack('MNTC095',.T.) .And. MNTC095(cCodigoBem)"}	}

	//------------------------------------------------------------------------------------------------------------------------//

	//Painel Temporario do Contador 1
	oI01Cnt1Pai := TPanel():New(01, 01, , oObjSplit, , , , CLR_BLACK, CLR_WHITE, 100, 100)
	oI01Cnt1Pai:Align := CONTROL_ALIGN_ALLCLIENT

	//Objeto para dar um Espaco entre os Titulos, contedo um SAY
	oI01Cnt1Say := TPanel():New(01, 01, "", oI01Cnt1Pai, oFontBold, .T., , CLR_BLACK, CLR_WHITE, 100, 010)
	oI01Cnt1Say:Align := CONTROL_ALIGN_TOP

	//Objeto para conter o SAY do Contador 1
	oTmpPnlSay := TPanel():New(01, 01, , oI01Cnt1Pai, , , , , nCorBack, 100, 010)
	oTmpPnlSay:Align := CONTROL_ALIGN_TOP
	TSay():New(001, 012, {|| OemToAnsi("1บ Contador")}, oTmpPnlSay, , oFontBold, , ;
	, ,.T., nCorFore, , 150, 010)

	//--- Contador 1
	oI01Cnt1 := MsMGet():New("ST9",RecNo(),2,/*aCRA*/,/*cLetras*/,/*cTexto*/,aI01Cnt1/*aChoice*/,aPos/*aPos*/,/*aCpos*/,;
	3/*nModelo*/,/*nColMens*/,/*cMensagem*/,/*cTudoOk*/,oI01Cnt1Pai/*oDlg*/,/*lF3*/,.T./*lMemoria*/,.F./*lColumn*/,;
	/*caTela*/,/*lNoFolder*/,/*lProperty*/,/*aField*/)
	oI01Cnt1:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	//Clique da Direita
	NGPOPUP(aCntMenu,@oI01Cnt1Mnu,oI01Cnt1:oBox)
	oI01Cnt1:oBox:bRClicked:= { |o,x,y| oI01Cnt1Mnu:Activate(x,y,oI01Cnt1:oBox)}

	//------------------------------------------------------------------------------------------------------------------------//

	//Painel Temporario do Contador 1
	oI01Cnt2Pai := TPanel():New(01, 01, , oObjSplit, , , , CLR_BLACK, CLR_WHITE, 100, 100)
	oI01Cnt2Pai:Align := CONTROL_ALIGN_ALLCLIENT

	//Objeto para dar um Espaco entre os Titulos, contedo um SAY
	oI01Cnt2Say := TPanel():New(01, 01, "", oI01Cnt2Pai, oFontBold, .T., , CLR_BLACK, CLR_WHITE, 100, 010)
	oI01Cnt2Say:Align := CONTROL_ALIGN_TOP

	//Objeto para conter o SAY do Contador 1
	oTmpPnlSay := TPanel():New(01, 01, , oI01Cnt2Pai, , , , , nCorBack, 100, 010)
	oTmpPnlSay:Align := CONTROL_ALIGN_TOP
	TSay():New(001, 012, {|| OemToAnsi("2บ Contador")}, oTmpPnlSay, , oFontBold, , ;
	, ,.T., nCorFore, , 150, 010)

	//--- Contador 2
	oI01Cnt2 := MsMGet():New("TPE",RecNo(),2,/*aCRA*/,/*cLetras*/,/*cTexto*/,aI01Cnt2/*aChoice*/,aPos/*aPos*/,/*aCpos*/,;
	3/*nModelo*/,/*nColMens*/,/*cMensagem*/,/*cTudoOk*/,oI01Cnt2Pai/*oDlg*/,/*lF3*/,.T./*lMemoria*/,.F./*lColumn*/,;
	/*caTela*/,/*lNoFolder*/,/*lProperty*/,/*aField*/)
	oI01Cnt2:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	//Clique da Direita
	NGPOPUP(aCntMenu,@oI01Cnt2Mnu,oI01Cnt2:oBox)
	oI01Cnt2:oBox:bRClicked:= { |o,x,y| oI01Cnt2Mnu:Activate(x,y,oI01Cnt2:oBox)}

	//------------------------------------------------------------------------------------------------------------------------//

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMNTC795I02บAutor  ณWagner S. de Lacerdaบ Data ณ  20/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta a Informacao dos Indicadores.                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC795I02()

	//--- Painel Pai da Informacao - Indicadores
	If Type("oConInfo02") <> "O"
		oConInfo02 := TPanel():New(01, 01, , oConPnlPai, , , , CLR_BLACK, CLR_WHITE, 1000, 1000)
		oConInfo02:Align := CONTROL_ALIGN_ALLCLIENT
	Else
		oConInfo02:FreeChildren()
	EndIf
	oConInfo02:CoorsUpdate()

	//------------------------------------------------------------------------------------------------------------------------//

	// Painel de Indicadores
	If FindFunction("NGI8TNGPnl")
		oI02TNGPnl := NGI8TNGPnl(oConInfo02)
	EndIf

	//------------------------------------------------------------------------------------------------------------------------//

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMNTC795I03บAutor  ณWagner S. de Lacerdaบ Data ณ  20/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta a Informacao das Manutencoes.                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC795I03()

	Local oObjSplit
	Local oTmpPnlSay, oTmpPnlMnu
	Local oTmpPnlMan, oTmpPnlOrd, oTmpBtn

	//Painel Pai da Informacao - Manutencoes
	oConInfo03 := TPanel():New(01, 01, , oConPnlPai, , , , CLR_BLACK, CLR_WHITE, 1000, 1000)
	oConInfo03:Align := CONTROL_ALIGN_ALLCLIENT

	//Splitter da Tela
	oObjSplit := TSplitter():New(01, 01, oConInfo03, 10, 10)
	oObjSplit:SetOrient(1)
	oObjSplit:Align := CONTROL_ALIGN_ALLCLIENT

	//------------------------------------------------------------------------------------------------------------------------//

	//+----------------------------+
	//| Manutencoes                |
	//+----------------------------+

	//Painel Pai das Manutencoes
	oI03ManPai := TPanel():New(01, 01, , oObjSplit, , , , CLR_BLACK, CLR_WHITE, 1000, 1000)
	oI03ManPai:Align := CONTROL_ALIGN_ALLCLIENT

	//Painel do Menu Lateral
	oTmpPnlMnu := TPanel():New(01, 01, , oI03ManPai, , , , CLR_WHITE, nCorBack, 012, 100)
	oTmpPnlMnu:Align := CONTROL_ALIGN_LEFT
	//Botao para visualizar a Manutencao
	oTmpBtn := TBtnBmp2():New(01, 01, 27, 30, "ng_ico_visual", , , , {|| fI03Botao(1) }, oTmpPnlMnu, OemToAnsi("Visualizar"))
	oTmpBtn:Align := CONTROL_ALIGN_TOP

	//Objeto Rodape
	oTmpPnlSay := TPanel():New(01, 01, , oI03ManPai, , , , nCorFore, nCorBack, 120, 010)
	oTmpPnlSay:Align := CONTROL_ALIGN_BOTTOM
	oI03ManRod := TPanel():New(01, 01, "", oTmpPnlSay, oFontNorm, .T., , nCorFore, nCorBack, 120, 010)
	oI03ManRod:Align := CONTROL_ALIGN_RIGHT

	//--- Browse das Manutencoes
	oI03Man := fMontaBrw(@aI03ManHea, @aI03ManCol, @oI03ManPai)
	oI03Man:SetArray(aI03ManCol)
	oI03Man:SetChange({|| Processa({|| fCarrOS(2) },"Aguarde"+"...") })
	oI03Man:bLDblClick := {|| fI03Botao(1) }
	oI03Man:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	//------------------------------------------------------------------------------------------------------------------------//

	//+----------------------------+
	//| Ordens de Servico          |
	//+----------------------------+

	//Painel Pai das Ordens de Servico da Manutencao
	oI03OrdPai := TPanel():New(01, 01, , oObjSplit, , , , CLR_BLACK, CLR_WHITE, 1000, 1000)
	oI03OrdPai:Align := CONTROL_ALIGN_ALLCLIENT

	//Painel Pai do Menu Lateral
	oTmpPnlMnu := TPanel():New(01, 01, , oI03OrdPai, , , , CLR_WHITE, nCorBack, 012, 100)
	oTmpPnlMnu:Align := CONTROL_ALIGN_LEFT
	//Botao para visualizar a O.S.
	oTmpBtn := TBtnBmp2():New(01, 01, 27, 30, "ng_ico_visual", , , , {|| fI03Botao(2) }, oTmpPnlMnu, OemToAnsi("Visualizar"))
	oTmpBtn:Align := CONTROL_ALIGN_TOP
	//Botao para selecionar o periodo para carregar as O.S.'s
	oTmpBtn := TBtnBmp2():New(01, 01, 27, 30, "ng_ico_historico", , , , {|| fI03Botao(3) }, oTmpPnlMnu, OemToAnsi("Selecionar Perํodo"))
	oTmpBtn:Align := CONTROL_ALIGN_TOP

	//Objeto Rodape
	oTmpPnlSay := TPanel():New(01, 01, , oI03OrdPai, , , , nCorFore, nCorBack, 120, 010)
	oTmpPnlSay:Align := CONTROL_ALIGN_BOTTOM
	oI03OrdRod := TPanel():New(01, 01, "", oTmpPnlSay, oFontNorm, .T., , nCorFore, nCorBack, 120, 010)
	oI03OrdRod:Align := CONTROL_ALIGN_RIGHT

	//--- Browse das Ordens de Servico da Manutencao
	oI03Ord := fMontaBrw(@aI03OrdHea[1], @aI03OrdCol, @oI03OrdPai)
	oI03Ord:SetArray(aI03OrdCol)
	oI03Ord:bLDblClick := {|| fI03Botao(2) }
	oI03Ord:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	//------------------------------------------------------------------------------------------------------------------------//

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMNTC795I04บAutor  ณWagner S. de Lacerdaบ Data ณ  06/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta a Informacao do Historico de Ordem de Servico.       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC795I04()

	Local oTmpPnlSay, oTmpPnlMnu
	Local oTmpBtn

	//Painel Pai da Informacao - Historico de Ordens de Servico
	oConInfo04 := TPanel():New(01, 01, , oConPnlPai, , , , CLR_BLACK, CLR_WHITE, 1000, 1000)
	oConInfo04:Align := CONTROL_ALIGN_ALLCLIENT

	//Objeto Rodape
	oTmpPnlSay := TPanel():New(01, 01, , oConInfo04, , , , nCorFore, nCorBack, 120, 010)
	oTmpPnlSay:Align := CONTROL_ALIGN_BOTTOM
	oI04OrdRod := TPanel():New(01, 01, "", oTmpPnlSay, oFontNorm, .T., , nCorFore, nCorBack, 120, 010)
	oI04OrdRod:Align := CONTROL_ALIGN_RIGHT

	//------------------------------------------------------------------------------------------------------------------------//

	//Painel Pai do Menu Lateral
	oTmpPnlMnu := TPanel():New(01, 01, , oConInfo04, , , , CLR_WHITE, nCorBack, 012, 100)
	oTmpPnlMnu:Align := CONTROL_ALIGN_LEFT
	//Botao para visualizar a O.S.
	oTmpBtn := TBtnBmp2():New(01, 01, 27, 30, "ng_ico_visual", , , , {|| fI04Botao(1) }, oTmpPnlMnu, OemToAnsi("Visualizar"))
	oTmpBtn:Align := CONTROL_ALIGN_TOP
	//Botao para selecionar o filtro para carregar as O.S.'s
	oTmpBtn := TBtnBmp2():New(01, 01, 27, 30, "ng_ico_filtro1", , , , {|| fI04Botao(2) }, oTmpPnlMnu, OemToAnsi("Selecionar Filtro"))
	oTmpBtn:Align := CONTROL_ALIGN_TOP

	//------------------------------------------------------------------------------------------------------------------------//

	//Painel Pai das Ordens de Servico
	oI04OrdPai := TPanel():New(01, 01, , oConInfo04, , , , CLR_WHITE, nCorBack, 100, 100)
	oI04OrdPai:Align := CONTROL_ALIGN_ALLCLIENT

	//--- Browse com as O.S.'s
	oI04Ord := fMontaBrw(@aI04OrdHea[1], @aI04OrdCol, @oI04OrdPai)
	oI04Ord:SetArray(aI04OrdCol)
	oI04Ord:bLDblClick := {|| fI04Botao(1) }
	oI04Ord:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	//------------------------------------------------------------------------------------------------------------------------//

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMNTC795I05บAutor  ณWagner S. de Lacerdaบ Data ณ  06/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta a Informacao do Historico de Movimentacoes.          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC795I05()

	Local oObjSplit
	Local oTmpPnlSay, oTmpPnlMnu
	Local oTmpPnlEst, oTmpPnlMov

	//Painel Pai da Informacao - Historico de Movimentacoes
	oConInfo05 := TPanel():New(01, 01, , oConPnlPai, , , , CLR_BLACK, CLR_WHITE, 1000, 1000)
	oConInfo05:Align := CONTROL_ALIGN_ALLCLIENT

	//Splitter da Tela
	oObjSplit := TSplitter():New(01, 01, oConInfo05, 10, 10)
	oObjSplit:SetOrient(0)
	oObjSplit:Align := CONTROL_ALIGN_ALLCLIENT

	//------------------------------------------------------------------------------------------------------------------------//

	//ษออออออออออออออออออออออออออออป
	//บ Movimentacoes da Estrutura บ
	//ศออออออออออออออออออออออออออออผ

	//Painel Pai das Manutencoes
	oI05EstPai := TPanel():New(01, 01, , oObjSplit, , , , CLR_BLACK, CLR_WHITE, 1000, 1000)
	oI05EstPai:Align := CONTROL_ALIGN_ALLCLIENT

	//Objeto para dar um Espaco entre os Titulos, contedo um SAY
	oI05EstSay := TPanel():New(01, 01, "", oI05EstPai, oFontBold, .T., , CLR_BLACK, CLR_WHITE, 100, 010)
	oI05EstSay:Align := CONTROL_ALIGN_TOP

	//Objeto para conter o SAY da Movimentacao da Estrutura
	oTmpPnlSay := TPanel():New(01, 01, , oI05EstPai, , , , , nCorBack, 100, 010)
	oTmpPnlSay:Align := CONTROL_ALIGN_TOP
	TSay():New(001, 012, {|| OemToAnsi("Estrutura")}, oTmpPnlSay, , oFontBold, , ;
	, ,.T., nCorFore, , 150, 010)

	//Painel do Menu Lateral
	oTmpPnlMnu := TPanel():New(01, 01, , oI05EstPai, , , , CLR_WHITE, nCorBack, 012, 100)
	oTmpPnlMnu:Align := CONTROL_ALIGN_LEFT
	//Botao para visualizar a Movimentacao da Estrutura
	oTmpBtn := TBtnBmp2():New(01, 01, 27, 30, "ng_ico_visual", , , , {|| fI05Botao(1) }, oTmpPnlMnu, OemToAnsi("Visualizar"))
	oTmpBtn:Align := CONTROL_ALIGN_TOP

	//--- Browse das Manutencoes
	oI05Est := fMontaBrw(@aI05EstHea, @aI05EstCol, @oI05EstPai)
	oI05Est:SetArray(aI05EstCol)
	oI05Est:bLDblClick := {|| fI05Botao(1) }
	oI05Est:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	//Objeto Rodape
	oTmpPnlSay := TPanel():New(01, 01, , oI05EstPai, , , , nCorFore, nCorBack, 120, 010)
	oTmpPnlSay:Align := CONTROL_ALIGN_BOTTOM
	oI05EstRod := TPanel():New(01, 01, "", oTmpPnlSay, oFontNorm, .T., , nCorFore, nCorBack, 120, 010)
	oI05EstRod:Align := CONTROL_ALIGN_RIGHT

	//------------------------------------------------------------------------------------------------------------------------//

	//+----------------------------+
	//| Movimentacoes do Bem       |
	//+----------------------------+

	//Painel Pai das Ordens de Servico da Manutencao
	oI05MovPai := TPanel():New(01, 01, , oObjSplit, , , , CLR_BLACK, CLR_WHITE, 1000, 1000)
	oI05MovPai:Align := CONTROL_ALIGN_ALLCLIENT

	//Objeto para dar um Espaco entre os Titulos, contedo um SAY
	oI05MovSay := TPanel():New(01, 01, "", oI05MovPai, oFontBold, .T., , CLR_BLACK, CLR_WHITE, 100, 010)
	oI05MovSay:Align := CONTROL_ALIGN_TOP

	//Objeto para conter o SAY da Movimentacao do Bem
	oTmpPnlSay := TPanel():New(01, 01, , oI05MovPai, , , , , nCorBack, 100, 010)
	oTmpPnlSay:Align := CONTROL_ALIGN_TOP
	TSay():New(001, 012, {|| OemToAnsi("Bem")}, oTmpPnlSay, , oFontBold, , ;
	, ,.T., nCorFore, , 150, 010)

	//Painel Pai do Menu Lateral
	oTmpPnlMnu := TPanel():New(01, 01, , oI05MovPai, , , , CLR_WHITE, nCorBack, 012, 100)
	oTmpPnlMnu:Align := CONTROL_ALIGN_LEFT
	//Botao para visualizar a Movimentacao do Bem
	oTmpBtn := TBtnBmp2():New(01, 01, 27, 30, "ng_ico_visual", , , , {|| fI05Botao(2) }, oTmpPnlMnu, OemToAnsi("Visualizar"))
	oTmpBtn:Align := CONTROL_ALIGN_TOP

	//--- Browse das Ordens de Servico da Manutencao
	oI05Mov := fMontaBrw(@aI05MovHea, @aI05MovCol, @oI05MovPai)
	oI05Mov:SetArray(aI05MovCol)
	oI05Mov:bLDblClick := {|| fI05Botao(2) }
	oI05Mov:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	//Objeto Rodape
	oTmpPnlSay := TPanel():New(01, 01, , oI05MovPai, , , , nCorFore, nCorBack, 120, 010)
	oTmpPnlSay:Align := CONTROL_ALIGN_BOTTOM
	oI05MovRod := TPanel():New(01, 01, "", oTmpPnlSay, oFontNorm, .T., , nCorFore, nCorBack, 120, 010)
	oI05MovRod:Align := CONTROL_ALIGN_RIGHT

	//------------------------------------------------------------------------------------------------------------------------//

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfRefrshWndบAutor  ณWagner S. de Lacerdaบ Data ณ  25/10/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza a disposicao dos objetos em tela (utilizado em    บฑฑ
ฑฑบ          ณ caso de mudanca no dimensionamento da tela)                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T. -> Redimensionamento efetuado.                         บฑฑ
ฑฑบ          ณ .F. -> Nao foi possivel redimensionar os objetos.          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ lChgCabec -> Opcional;                                     บฑฑ
ฑฑบ          ณ              Indica se deve trocar o cabecalho:            บฑฑ
ฑฑบ          ณ                 .T. - Troca o cabecalho                    บฑฑ
ฑฑบ          ณ                 .F. - Nao troca o cabecalho                บฑฑ
ฑฑบ          ณ              Default: .F.                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fRefrshWnd(lChgCabec)

	Local cCargoAnt  := oTree:GetCargo()

	fBlackPnl()

	Default lChgCabec := .F.

	//+----------------------------+
	//| Cabecalho                  |
	//+----------------------------+
	If lChgCabec
		If oCabecalho:lVisible
			oResPnlPai:Hide()
		Else
			oResPnlPai:Show()
		EndIf
	EndIf

	//+----------------------------+
	//| Finalizacao                |
	//+----------------------------+
	//Seleciona o Nivel Originalmente setado
	oTree:TreeSeek(cCargoAnt)
	fTreeChg() //Executa o Change da Tree

	fBlackPnl(.F.)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMNTC795SAIบAutor  ณWagner S. de Lacerdaบ Data ณ  01/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Acao de Confirmar/Cancelar a Consulta de Bem.              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC795SAI()

	oDlgCOS:End()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ SECAO: PRINCIPAL - FIM                                                บฑฑ
ฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ SECAO: FUNCOES DOS OBJETOS PRINCIPAIS DA TELA - INICIO                บฑฑ
ฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfI01Entra บAutor  ณWagner S. de Lacerdaบ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza as atualizacoes em tela necessarias ao entrar num  บฑฑ
ฑฑบ          ณ folder de Dados Cadastrais.                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fI01Entra()

	Local aArea := GetArea()

	If oI01Folder:nOption == nI01Bem //Bem
		If Len(aAreaST9) > 0
			RestArea(aAreaST9)
		EndIf
	ElseIf oI01Folder:nOption == nI01Crt //Caracteristicas
		oI01Crt:SetFocus()
		fAtuFWBrw(@oI01Crt)
	ElseIf oI01Folder:nOption == nI01PeR //Pecas de Reposicao
		oI01PeR:SetFocus()
		fAtuFWBrw(@oI01PeR)
	ElseIf lUsaIntTMS .And. oI01Folder:nOption == nI01TMS //Pneu
		If Len(aAreaDA3) > 0
			RestArea(aAreaDA3)
		EndIf
	ElseIf lUsaIntTQS .And. oI01Folder:nOption == nI01Pne //Pneu
		If Len(aAreaTQS) > 0
			RestArea(aAreaTQS)
		EndIf
	ElseIf oI01Folder:nOption == nI01CoV //Complemento Veiculo
		If Len(aAreaST9) > 0
			RestArea(aAreaST9)
		EndIf
	EndIf

	If Len(aArea) > 0
		RestArea(aArea)
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfI03Botao บAutor  ณWagner S. de Lacerdaบ Data ณ  20/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Clique do botao das Manutencoes.                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nBtn -> Obrigatorio;                                       บฑฑ
ฑฑบ          ณ         Indica qual botao recebeu o clique.                บฑฑ
ฑฑบ          ณ          1 - Visualizar Manutencao                         บฑฑ
ฑฑบ          ณ          2 - Visualizar Ordem de Servico                   บฑฑ
ฑฑบ          ณ          3 - Periodo da Ordem de Servico                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fI03Botao(nBtn)

	Local aArea := GetArea()
	Local cMsg := ""

	Local oDlgPeriod := Nil
	Local oPnlPrdALL := Nil, oPnlPrdBOT := Nil, oObjTemp := Nil
	Local oTmpBtnOk  := Nil, oTmpBtnCa := Nil

	Local nTFSERVICO := aScan(aI03ManHea, {|x| Upper(AllTrim(x[2])) == "TF_SERVICO" })
	Local nTFSEQRELA := aScan(aI03ManHea, {|x| Upper(AllTrim(x[2])) == "TF_SEQRELA" })

	Local nTJORDEM := aScan(aI03OrdHea[1], {|x| Upper(AllTrim(x[2])) == "TJ_ORDEM" })
	Local nTJPLANO := aScan(aI03OrdHea[1], {|x| Upper(AllTrim(x[2])) == "TJ_PLANO" })

	Local dPrdDeDt   := dI03DeDt
	Local dPrdAteDt  := dI03AteDt
	Local lPrdHist   := lI03OrdHis
	Local lOkPeriod  := .F.

	If nBtn <> 1 .And. !lTemManute //Se estiver tentando alguma acao que nao seja a de Visualizar a Manutencao
		Return .F.
	EndIf

	fBlackPnl()

	cMsg := ""
	If nBtn == 1 //Visualizar Manutencao
		If nTFSERVICO > 0 .And. nTFSEQRELA > 0
			dbSelectArea("STF")
			dbSetOrder(1)
			If dbSeek(xFilial("STF")+cCodigoBem+aI03ManCol[oI03Man:AT()][nTFSERVICO]+aI03ManCol[oI03Man:AT()][nTFSEQRELA])
				NG120FOLD("STF",RecNo(),2)
			Else
				cMsg := "Nใo foi possํvel encontrar o cadastro da "+"Manuten็ใo"+"."
			EndIf
		Else
			cMsg := "Nใo hแ dados suficientes para buscar a"+" "+"Manuten็ใo"+" "+"selecionada"+"."
		EndIf
	ElseIf nBtn == 2 //Visualizar Ordem de Servico
		If nTJORDEM > 0 .And. nTJPLANO > 0
			dbSelectArea("STJ")
			dbSetOrder(1)
			If dbSeek(xFilial("STJ")+aI03OrdCol[oI03Ord:AT()][nTJORDEM]+aI03OrdCol[oI03Ord:AT()][nTJPLANO])
				If FindFunction("MNTC755")
					MNTC755(STJ->TJ_ORDEM)
				Else
					NGCAD01("STJ",RecNo(),2)
				EndIf
			Else
				cMsg := "Nใo foi possํvel encontrar o cadastro da "+"Ordem de Servi็o"+"."
			EndIf

			If !Empty(cMsg)
				dbSelectArea("STS")
				dbSetOrder(1)
				If dbSeek(xFilial("STS")+aI03OrdCol[oI03Ord:AT()][nTJORDEM]+aI03OrdCol[oI03Ord:AT()][nTJPLANO])
					cMsg := ""

					If FindFunction("MNTC755")
						MNTC755(STS->TS_ORDEM)
					Else
						NGCAD01("STS",RecNo(),2)
					EndIf
				EndIf
			EndIf
		Else
			cMsg := "Nใo hแ dados suficientes para buscar a"+" "+"Ordem de Servi็o"+" "+"selecionada"+"."
		EndIf
	ElseIf nBtn == 3 //Periodo da Ordem de Servico
		lOkPeriod := .F.
		DEFINE MSDIALOG oDlgPeriod TITLE OemToAnsi("Perํodo") FROM 0,0 TO 200,250 OF oMainWnd PIXEL ;
		STYLE nOr(DS_SYSMODAL,WS_MAXIMIZEBOX,WS_POPUP)

		//ALL
		oPnlPrdALL := TPanel():New(01, 01, , oDlgPeriod, , , , CLR_BLACK, CLR_WHITE, 100, 100)
		oPnlPrdALL:Align := CONTROL_ALIGN_ALLCLIENT

		//De Data
		@ 015,010 SAY OemToAnsi("De Data"+":") FONT oFontNorm COLOR CLR_BLACK OF oPnlPrdALL PIXEL
		oObjTemp := TGet():New(014, 050, {|u| If(PCount() > 0, dPrdDeDt := u, dPrdDeDt)}, oPnlPrdALL, 060, 008, "99/99/9999",;
		{|| fIZZVldDt(1,dPrdDeDt,dPrdAteDt) }, CLR_BLACK, , ,;
		.F., , .T., , .F., {|| !lPrdHist }, .F., .F., , .F., .F., , "dPrdDeDt", , , , .T./*lHasButton*/)
		oObjTemp:bHelp := {|| ShowHelpCpo("De Data",;
		{"Data inicial para a filtrar a consulta."},2,;
		{},2)}

		//Ate Data
		@ 030,010 SAY OemToAnsi("At้ Data"+":") FONT oFontNorm COLOR CLR_BLACK OF oPnlPrdALL PIXEL
		oObjTemp := TGet():New(029, 050, {|u| If(PCount() > 0, dPrdAteDt := u, dPrdAteDt)}, oPnlPrdALL, 060, 008, "99/99/9999",;
		{|| fIZZVldDt(2,dPrdDeDt,dPrdAteDt) }, CLR_BLACK, , ,;
		.F., , .T., , .F., {|| !lPrdHist }, .F., .F., , .F., .F., , "dPrdAteDt", , , , .T./*lHasButton*/)
		oObjTemp:bHelp := {|| ShowHelpCpo("Ate Data",;
		{"Data final para a filtrar a consulta."},2,;
		{},2)}

		//Todo o Historico
		TCheckBox():New(050, 050, "Todo o Hist๓rico", {|| lPrdHist }, oPnlPrdALL, 100, 015, , {|| lPrdHist := !lPrdHist, oTmpBtnOk:SetFocus() }, , , , , , .T., , ,)

		//BOT
		oPnlPrdBOT := TPanel():New(01, 01, , oDlgPeriod, , , , CLR_BLACK, CLR_WHITE, 100, 020)
		oPnlPrdBOT:Align := CONTROL_ALIGN_BOTTOM

		//Botao OK
		oTmpBtnOk := SButton():New(003, 060, 1, {|| lOkPeriod := .T., If(fIZZVldDt(0,dPrdDeDt,dPrdAteDt), oDlgPeriod:End(), lOkPeriod := .F.) }, oPnlPrdBOT, .T., , )
		//Botao Cancelar
		oTmpBtnCa := SButton():New(003, 095, 2, {|| lOkPeriod := .F., oDlgPeriod:End() }, oPnlPrdBOT, .T., , )

		ACTIVATE MSDIALOG oDlgPeriod CENTERED
	EndIf

	//Mensagem em caso de erro
	If !Empty(cMsg)
		MsgInfo(cMsg,"Aten็ใo")
	EndIf

	fBlackPnl(.F.)

	If Len(aArea) > 0
		RestArea(aArea)
	EndIf

	If nBtn == 3 .And. lOkPeriod //Periodo da Ordem de Servico
		dI03DeDt   := dPrdDeDt
		dI03AteDt  := dPrdAteDt
		lI03OrdHis := lPrdHist

		Processa({|| fCarrOS(2) },"Aguarde"+"...")
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfI04Botao บAutor  ณWagner S. de Lacerdaบ Data ณ  26/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Clique do botao do Historico de Ordem de Servico.          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nBtn -> Obrigatorio;                                       บฑฑ
ฑฑบ          ณ         Indica qual botao recebeu o clique.                บฑฑ
ฑฑบ          ณ          1 - Visualizar Ordem de Servico                   บฑฑ
ฑฑบ          ณ          2 - Periodo da Ordem de Servico                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fI04Botao(nBtn)

	Local aArea := GetArea()
	Local cMsg := ""

	Local aBuildCpos := {}
	Local cFiltroOLD := cI04Filtro
	Local nX := 0

	Local nTJORDEM := aScan(aI04OrdHea[1], {|x| Upper(AllTrim(x[2])) == "TJ_ORDEM" })
	Local nTJPLANO := aScan(aI04OrdHea[1], {|x| Upper(AllTrim(x[2])) == "TJ_PLANO" })

	fBlackPnl()

	cMsg := ""
	If nBtn == 1 //Visualizar Ordem de Servico
		If nTJORDEM > 0 .And. nTJPLANO > 0
			dbSelectArea("STJ")
			dbSetOrder(1)
			If dbSeek(xFilial("STJ")+aI04OrdCol[oI04Ord:AT()][nTJORDEM]+aI04OrdCol[oI04Ord:AT()][nTJPLANO])
				If FindFunction("MNTC755")
					MNTC755(STJ->TJ_ORDEM)
				Else
					NGCAD01("STJ",RecNo(),2)
				EndIf
			Else
				cMsg := "Nใo foi possํvel encontrar o cadastro da "+"Ordem de Servi็o"+"."
			EndIf

			If !Empty(cMsg)
				dbSelectArea("STS")
				dbSetOrder(1)
				If dbSeek(xFilial("STS")+aI04OrdCol[oI04Ord:AT()][nTJORDEM]+aI04OrdCol[oI04Ord:AT()][nTJPLANO])
					cMsg := ""

					If FindFunction("MNTC755")
						MNTC755(STS->TS_ORDEM)
					Else
						NGCAD01("STS",RecNo(),2)
					EndIf
				EndIf
			EndIf
		Else
			cMsg := "Nใo hแ dados suficientes para buscar a"+" "+"Ordem de Servi็o"+" "+"selecionada"+"."
		EndIf
	ElseIf nBtn == 2 //Filtro das Ordens de Servico
		aBuildCpos := {}
		For nX := 1 To Len(aI04OrdHea[1])
			aAdd(aBuildCpos, aI04OrdHea[1][nX][2])
		Next nX

		cI04Filtro := BuildExpr("STJ", /*oWnd*/, cI04Filtro, .F., /*bOk - nao funciona*/, /*oDlg*/, aBuildCpos,;
		/*cDesc*/, /*nRow*/, /*nCol*/, /*aCampo*/, /*lVisibleTopFilter*/, /*lExpBtn*/, /*cTopFilter*/)

		fI04Filtro() //Monta a Expressao do Filtro para a STJ e STS
	EndIf

	//Mensagem em caso de erro
	If !Empty(cMsg)
		MsgInfo(cMsg,"Aten็ใo")
	EndIf

	fBlackPnl(.F.)

	If Len(aArea) > 0
		RestArea(aArea)
	EndIf

	If nBtn == 2 .And. cI04Filtro <> cFiltroOLD //Filtro das Ordens de Servico
		Processa({|| fCarrOS(1) },"Aguarde"+"...")
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfI04FiltroบAutor  ณWagner S. de Lacerdaบ Data ณ  26/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o filtro a partir de uma expressao.                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fI04Filtro()

	Local nX := 0

	If Empty(cI04Filtro)
		cI04FilSTJ := "{|| .T. }"
		cI04FilSTS := "{|| .T. }"
	Else
		cI04FilSTJ := "{|| "+cI04Filtro+" }"
		cI04FilSTS := "{|| "+cI04Filtro+" }"
		For nX := 1 To Len(aI04OrdHea[1])
			//Este filtro sera' utilizado na funcao fCarrOS() para filtrar as O.S.'s
			cI04FilSTJ := StrTran(cI04FilSTJ, AllTrim(aI04OrdHea[1][nX][2]), "aColsSTJ[nX]["+cValToChar(nX)+"]")
			cI04FilSTS := StrTran(cI04FilSTJ, AllTrim(aI04OrdHea[1][nX][2]), "aColsSTS[nX]["+cValToChar(nX)+"]")
		Next nX
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfI05Botao บAutor  ณWagner S. de Lacerdaบ Data ณ  26/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Clique do botao do Historico de Movimentacoes.             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nBtn -> Obrigatorio;                                       บฑฑ
ฑฑบ          ณ         Indica qual botao recebeu o clique.                บฑฑ
ฑฑบ          ณ          1 - Visualizar Movimentacao da Estrutura          บฑฑ
ฑฑบ          ณ          2 - Visualizar Movimentacao do Bem                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fI05Botao(nBtn)

	Local aArea := GetArea()
	Local cMsg := ""

	Local nTZCODBEM  := aScan(aI05EstHea, {|x| Upper(AllTrim(x[2])) == "TZ_CODBEM" })
	Local nTZDATAMOV := aScan(aI05EstHea, {|x| Upper(AllTrim(x[2])) == "TZ_DATAMOV" })
	Local nTZTIPOMOV := aScan(aI05EstHea, {|x| Upper(AllTrim(x[2])) == "TZ_TIPOMOV" })
	Local nTZHORAENT := aScan(aI05EstHea, {|x| Upper(AllTrim(x[2])) == "TZ_HORAENT" })

	Local nTPNDTINIC := aScan(aI05MovHea, {|x| Upper(AllTrim(x[2])) == "TPN_DTINIC" })
	Local nTPNHRINIC := aScan(aI05MovHea, {|x| Upper(AllTrim(x[2])) == "TPN_HRINIC" })

	fBlackPnl()

	cMsg := ""
	If nBtn == 1 //Visualizar Movimentacao da Estrutura
		If nTZCODBEM > 0 .And. nTZDATAMOV > 0 .And. nTZTIPOMOV > 0 .And. nTZHORAENT > 0
			dbSelectArea("STZ")
			dbSetOrder(1)
			If dbSeek(xFilial("STZ")+aI05EstCol[oI05Est:AT()][nTZCODBEM]+DTOS(aI05EstCol[oI05Est:AT()][nTZDATAMOV])+aI05EstCol[oI05Est:AT()][nTZTIPOMOV]+aI05EstCol[oI05Est:AT()][nTZHORAENT])
				NGCAD01("STZ",RecNo(),2)
			Else
				cMsg := "Nใo foi possํvel encontrar o cadastro da "+"Movimenta็ใo da Estrutura"+"."
			EndIf
		Else
			cMsg := "Nใo hแ dados suficientes para buscar a"+" "+"Movimenta็ใo da Estrutura"+" "+"selecionada"+"."
		EndIf
	ElseIf nBtn == 2 //Visualizar Movimentacao do Bem
		If nTPNDTINIC > 0 .And. nTPNHRINIC > 0
			dbSelectArea("TPN")
			dbSetOrder(1)
			If dbSeek(xFilial("TPN")+cCodigoBem+DTOS(aI05MovCol[oI05Mov:AT()][nTPNDTINIC])+aI05MovCol[oI05Mov:AT()][nTPNHRINIC])
				NGCAD01("TPN",RecNo(),2)
			Else
				cMsg := "Nใo foi possํvel encontrar o cadastro da "+"Movimenta็ใo do Bem"+"."
			EndIf
		Else
			cMsg := "Nใo hแ dados suficientes para buscar a"+" "+"Movimenta็ใo do Bem"+" "+"selecionada"+"."
		EndIf
	EndIf

	//Mensagem em caso de erro
	If !Empty(cMsg)
		MsgInfo(cMsg,"Aten็ใo")
	EndIf

	fBlackPnl(.F.)

	If Len(aArea) > 0
		RestArea(aArea)
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfAtuFWBrw บAutor  ณWagner S. de Lacerdaบ Data ณ  29/08/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza o Objeto do FW Browse.                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oObj -> Obrigatorio;                                       บฑฑ
ฑฑบ          ณ         Define o objeto para atualizar.                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fAtuFWBrw(oObj)

	CursorWait()

	oObj:oBrowse:CoorsUpdate()
	oObj:Refresh()

	CursorArrow()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfIZZVldDt บAutor  ณWagner S. de Lacerdaบ Data ณ  26/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida as Datas Iniciais e Finais dos objetos.             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nVldDt -> Opcional;                                        บฑฑ
ฑฑบ          ณ           Indica qual data deve ser validada.              บฑฑ
ฑฑบ          ณ            0 - Ambas (De Data e Ate Data)                  บฑฑ
ฑฑบ          ณ            1 - De Data somente                             บฑฑ
ฑฑบ          ณ            2 - Ate Data somente                            บฑฑ
ฑฑบ          ณ           Default: 0.                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fIZZVldDt(nVldDt, dParDeDt, dParAteDt)

	Default nVldDt := 0

	If nVldDt == 0 .Or. nVldDt == 1 //De Data
		If Empty(dParDeDt)
			/*
			ShowHelpDlg("Data Invแlida",;
			{"A data inicial estแ vazia."},2,;
			{"Favor preencher a data inicial."},2)
			Return .F.
			*/
			Return .T.
		ElseIf dParDeDt > dDataBase
			ShowHelpDlg("Data Invแlida",;
			{"A data inicial nใo pode ser superior เ atual."},2,;
			{"Favor selecionar uma data adequada, que seja inferior เ data atual."},2)
			Return .F.
		ElseIf !Empty(dParAteDt) .And. dParDeDt > dParAteDt
			ShowHelpDlg("Data Invแlida",;
			{"A data inicial nใo pode ser superior เ final."},2,;
			{"Favor selecionar uma data que seja inferior, ou igual, เ data final."},2)
			Return .F.
		EndIf
	EndIf
	If nVldDt == 0 .Or. nVldDt == 2 //Ate Data
		If Empty(dParAteDt)
			/*
			ShowHelpDlg("Data Invแlida",;
			{"A data final estแ vazia."},2,;
			{"Favor preencher a data final."},2)
			Return .F.
			*/
			Return .T.
		ElseIf dParAteDt > dDataBase
			ShowHelpDlg("Data Invแlida",;
			{"A data final nใo pode ser superior เ atual."},2,;
			{"Favor selecionar uma data adequada, que seja inferior เ data atual."},2)
			Return .F.
		ElseIf !Empty(dParDeDt) .And. dParAteDt < dParDeDt
			ShowHelpDlg("Data Invแlida",;
			{"A data final nใo pode ser inferior เ inicial."},2,;
			{"Favor selecionar uma data que seja superior, ou igual, เ data inicial."},2)
			Return .F.
		EndIf
	EndIf

	If nVldDt == 0 //Valida ambas as datas (De Data - Ate Data)
		If dParAteDt < dParDeDt
			ShowHelpDlg("Data Invแlida",;
			{"A data final nใo pode ser inferior เ inicial."},2,;
			{"Favor selecionar uma data que seja superior, ou igual, เ data inicial."},2)
			Return .F.
		EndIf
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ SECAO: FUNCOES DOS OBJETOS PRINCIPAIS DA TELA - FIM                   บฑฑ
ฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ SECAO: FUNCOES DA ARVORE - INICIO                                     บฑฑ
ฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfInitTree บAutor  ณWagner S. de Lacerdaบ Data ณ  06/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inicializa/Carrega a Arvore do Menu Lateral.               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fInitTree()

	Local cTopNivTree := "", cNivTree := ""
	Local cNivAtu  := ""

	aTreeNivs := {}

	oTree:BeginUpdate() //Inicia a atualizacao da Arvore

	oTree:Reset() //Limpa a Tree

	//Adiciona o Nivel inicial da Arvore - BEM
	cNivAtu := fTreeNxtNv()
	cTopNivTree := "BEM_000."+cNivAtu
	oTree:AddTree(OemToAnsi("Bem"+Space(30)), .F., "engrenagem", "engrenagem", , , cTopNivTree)
	aAdd(aTreeNivs, cTopNivTree)

	If !Empty(cCodigoBem)
		//Adiciona o Nivel - Dados Cadstrais
		cNivAtu := fTreeNxtNv(Val(cNivAtu))
		cNivTree := "DAD_000."+cNivAtu

		oTree:TreeSeek(cTopNivTree)
		oTree:AddItem(OemToAnsi("Dados Cadastrais"), cNivTree, "copyuser", "copyuser", , , 2)
		aAdd(aTreeNivs, cNivTree)

		//Adiciona o Nivel - Ficha Tecnica
		cNivAtu := fTreeNxtNv(Val(cNivAtu))
		oTree:TreeSeek(cNivTree)
		oTree:AddItem(OemToAnsi("Ficha T้cnica"), "DAD_001."+cNivAtu, "clips", "clips", , , 2)
		aAdd(aTreeNivs, "DAD_001."+cNivAtu)

		//Adiciona o Nivel - Contador
		cNivAtu := fTreeNxtNv(Val(cNivAtu))
		oTree:TreeSeek(cNivTree)
		oTree:AddItem(OemToAnsi("Contador"), "DAD_002."+cNivAtu, "clock01", "clock01", , , 2)
		aAdd(aTreeNivs, "DAD_002."+cNivAtu)

		//Adiciona o Nivel - Indicadores
		cNivAtu := fTreeNxtNv(Val(cNivAtu))
		cNivTree := "IND_000."+cNivAtu

		oTree:TreeSeek(cTopNivTree)
		oTree:AddItem(OemToAnsi("Indicadores"), cNivTree, "graf3d", "graf3d", , , 2)
		aAdd(aTreeNivs, cNivTree)

		//Adiciona o Nivel - Manutencoes
		cNivAtu := fTreeNxtNv(Val(cNivAtu))
		cNivTree := "MAN_000."+cNivAtu

		oTree:TreeSeek(cTopNivTree)
		oTree:AddItem(OemToAnsi("Manuten็๕es"), cNivTree, "instrume", "instrume", , , 2)
		aAdd(aTreeNivs, cNivTree)

		//Adiciona o Nivel - Historico de O.S.
		cNivAtu := fTreeNxtNv(Val(cNivAtu))
		cNivTree := "HOS_000."+cNivAtu

		oTree:TreeSeek(cTopNivTree)
		oTree:AddItem(OemToAnsi("Hist๓rico de O.S."), cNivTree, "historic", "historic", , , 2)
		aAdd(aTreeNivs, cNivTree)

		//Adiciona o Nivel - Historico de O.S.
		cNivAtu := fTreeNxtNv(Val(cNivAtu))
		cNivTree := "HM0_000."+cNivAtu

		oTree:TreeSeek(cTopNivTree)
		oTree:AddItem(OemToAnsi("Hist๓rico de Movimenta็๕es"), cNivTree, "estomovi", "estomovi", , , 2)
		aAdd(aTreeNivs, cNivTree)
	EndIf

	oTree:EndUpdate() //Finaliza a atualizacao da Arvore

	oTree:PTRefresh() //Atualiza os Niveis

	oTree:EndTree()   //Encerra a Arvore (e' diferente de destruir)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfTreeNxtNvบAutor  ณWagner S. de Lacerdaบ Data ณ  06/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Recebe o proximo Nivel da Arvore.                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fTreeNxtNv(nNivel)

	Local cNivAtual := ""

	Default nNivel := 0

	cNivAtual := PADL(nNivel,3,"0")
	cNivAtual := If(FindFunction("Soma1Old"),Soma1Old(cNivAtual),Soma1(cNivAtual))

Return cNivAtual

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfTreeChg  บAutor  ณWagner S. de Lacerdaบ Data ณ  06/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Recebe o proximo Nivel da Arvore.                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fTreeChg()

	Local cTreeCargo := "", cNivArv := "", cNumNivArv := ""
	Local nAT1 := 0, nAT2 := 0

	//Recebe o Nivel Atual na Arvore
	cTreeCargo := oTree:GetCargo()

	nAT1 := AT("_", cTreeCargo)
	cNivArv := SubStr(cTreeCargo, 1, (nAT1-1))

	nAT2 := AT(".", cTreeCargo)
	cNumNivArv := SubStr(cTreeCargo, (nAT1+1), (nAT1-1))

	//Esconde todos os Paineis
	If Type("oConInfo00") == "O"
		oConInfo00:Hide()
	EndIf
	If Type("oConInfo01") == "O"
		oConInfo01:Hide()
	EndIf
	If Type("oConInfo02") == "O"
		oConInfo02:Hide()
	EndIf
	If Type("oConInfo03") == "O"
		oConInfo03:Hide()
	EndIf
	If Type("oConInfo04") == "O"
		oConInfo04:Hide()
	EndIf
	If Type("oConInfo05") == "O"
		oConInfo05:Hide()
	EndIf

	Do Case
		Case cNivArv == "BEM"
		cConAtual := "Bem"
		If Type("oConInfo00") == "O"
			oConInfo00:Show()
		EndIf
		aAcessoChg[1] := .T.
		Case cNivArv == "DAD"
		cConAtual := "Dados Cadastrais"
		If Type("oConInfo01") == "O"
			oConInfo01:Show()

			oI01Folder:Hide()
			oI01FichaT:Hide()
			oI01Contad:Hide()

			fAtuMemory("ST9")
			fAtuMemory("TPE")
			fAtuMemory("DA3")
			fAtuMemory("TQS")

			If cNumNivArv == "000"
				oI01Folder:Show()
			ElseIf cNumNivArv == "001"
				cConAtual += " \ "+"Ficha T้cnica"
				oI01FichaT:Show()
			ElseIf cNumNivArv == "002"
				cConAtual += " \ "+"Contador"
				oI01Contad:Show()
			EndIf

			aAcessoChg[2] := .T.
		EndIf
		Case cNivArv == "IND"
		cConAtual := "Indicadores"
		If Type("oConInfo02") == "O"
			oConInfo02:Show()
		EndIf
		Case cNivArv == "MAN"
		cConAtual := "Manuten็๕es"
		If Type("oConInfo03") == "O"
			oConInfo03:Show()

			oI03Man:SetFocus()
			fAtuFWBrw(@oI03Man)
			If lTemManute
				oI03OrdPai:Show()
				If !aAcessoChg[4] //Ja' acessou este Dialog para este Bem?
					Processa({|| fCarrOS(2) },"Aguarde"+"...")
					fAtuFWBrw(@oI03Ord)
				EndIf
			Else
				oI03OrdPai:Hide()
			EndIf

			aAcessoChg[4] := .T.
		EndIf
		Case cNivArv == "HOS"
		cConAtual := "Hist๓rico de O.S."
		If Type("oConInfo04") == "O"
			oConInfo04:Show()

			If !aAcessoChg[5] //Ja' acessou este Dialog para este Bem?
				Processa({|| fCarrOS(1) },"Aguarde"+"...")
				fAtuFWBrw(@oI04Ord)
			EndIf

			aAcessoChg[5] := .T.
		EndIf
		Case cNivArv == "HM0"
		cConAtual := "Hist๓rico de Movimenta็๕es"
		If Type("oConInfo05") == "O"
			oConInfo05:Show()

			fAtuFWBrw(@oI05Est)
			fAtuFWBrw(@oI05Mov)

			aAcessoChg[6] := .T.
		EndIf
	EndCase

	oConAtual:CtrlRefresh()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ SECAO: FUNCOES DA ARVORE - FIM                                        บฑฑ
ฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ SECAO: FUNCOES DIVERSAS - INICIO                                      บฑฑ
ฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMNTC795ATUบAutor  ณWagner S. de Lacerdaบ Data ณ  01/11/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza a Consulta com o Bem selecionado.                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC795ATU()

	Local cCargoAnt := ""

	If Type("lCBEMAtu") <> "L"
		MsgInfo("Nใo ้ possํvel atualizar a Consulta de Bem enquanto ela nao estiver totalmente carregada."+CRLF+CRLF+;
		"Por favor, aguarde a Consulta ser carrega antes de tentar atualizแ-la.","Aten็ใo")
		Return .F.
	EndIf

	If !lCBEMAtu
		MsgInfo("Nใo ้ possํvel atualizar a Consulta de Bem enquanto o usuแrio estiver com ela em uso."+CRLF+CRLF+;
		"Para atualizar, primeiro feche todas as janelas adicionais abertas, deixando somente a tela principal da Consulta visํvel.","Aten็ใo")
		Return .F.
	EndIf

	cCargoAnt := oTree:GetCargo()
	MNTC795VBE()
	//Seleciona o Nivel selecionado anteriormente
	oTree:TreeSeek(cCargoAnt)
	fTreeChg()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMNTC795INIบAutor  ณWagner S. de Lacerdaบ Data ณ  06/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inicializa as Variaveis.                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC795INI()

	Local aAux := {}, nAux := 0
	Local aNao := {}

	//Define todos os Dialogs principais como NAO acessados ainda
	aAcessoChg := {.F., .F., {.F.,.F.,.F.}, .F., .F., .F.}

	//ษออออออออออออออออออออออออออออป
	//บ Cabecalho                  บ
	//ศออออออออออออออออออออออออออออผ

	cCodigoBem := Space( TAMSX3("T9_CODBEM")[1] )
	cOldCodBem := cCodigoBem
	cNomeBem   := Space( TAMSX3("T9_NOME")[1] )
	cCodModBem := Space( TAMSX3("TQR_TIPMOD")[1] )
	cNomModBem := Space( TAMSX3("TQR_DESMOD")[1] )
	cCodFamBem := Space( TAMSX3("T6_CODFAMI")[1] )
	cNomFamBem := Space( TAMSX3("T6_NOME")[1] )
	cCodCatBem := Space( TAMSX3("T9_CATBEM")[1] )
	cNomCatBem := Space( TAMSX3("T9_CATBEM")[1] )
	cCodSitBem := Space( TAMSX3("T9_SITBEM")[1] )
	cNomSitBem := Space( TAMSX3("T9_SITBEM")[1] )
	cCodStaBem := Space( TAMSX3("TQY_STATUS")[1] )
	cNomStaBem := Space( TAMSX3("TQY_DESTAT")[1] )
	cCodTurBem := Space( TAMSX3("H7_CODIGO")[1] )
	cNomTurBem := Space( TAMSX3("H7_DESCRI")[1] )
	cPrioriBem := Space( TAMSX3("T9_PRIORID")[1] )

	//ษออออออออออออออออออออออออออออป
	//บ Dados Cadastrais           บ
	//ศออออออออออออออออออออออออออออผ
	//--- Bem
	aI01Bem := aClone( MNTC795MON(10) )

	//--- Complemento Veiculo
	aI01CoV := aClone( MNTC795MON(15) )

	//--- Ficha Tecnica
	aI01FcT := aClone( MNTC795MON(16) )

	//--- Contador 1
	aI01Cnt1 := aClone( MNTC795MON(17) )

	//--- Contador 2
	aI01Cnt2 := aClone( MNTC795MON(18) )

	//--- Caracteristicas
	aNao := {"TB_CODBEM"}
	aI01CrtHea := CABECGETD("STB", aNao, 2)
	aI01CrtCol := aClone( MNTC795MON(11) )

	//--- Pecas de Reposicao
	aNao := {"TPY_CODBEM"}
	aI01PeRHea := CABECGETD("TPY", aNao, 2)
	aI01PeRCol := aClone( MNTC795MON(12) )

	//+----------------------------+
	//| Manutencoes                |
	//+----------------------------+
	lI03OrdHis := .F. //Nao considera o historico (inicialmente)

	//--- Manutencoes
	aAux := {	"TF_SERVICO", "TF_NOMSERV", "TF_SEQRELA",;
	"TF_NOMEMAN", "TF_CODAREA", "TF_NOMAREA",;
	"TF_TIPO"   , "TF_NOMTIPO", "TF_PRIORID" } //Campos que devem aparecer
	aNao := aClone( NGCAMPNSX3("STF",aAux) )
	nAux := 0
	aEval(aNao, {|| nAux++, aNao[nAux] := AllTrim(aNao[nAux]) })
	aI03ManHea := CABECGETD("STF", aNao, 2)
	aI03ManCol := aClone( MNTC795MON(30) )

	//--- Ordens de Servico da Manutencao
	aI03OrdHea := { {}, {} }
	dI03AteDt  := dDataBase
	dI03DeDt   := dI03AteDt - (30 * 6) //6 meses
	lI03OrdHis := .F.

	aAux := {	"TJ_ORDEM"  , "TJ_PLANO"  , "TJ_DTORIGI",;
	"TJ_SERVICO", "TJ_NOMSERV", "TJ_SEQRELA",;
	"TJ_DTMPINI", "TJ_HOMPINI", "TJ_DTMPFIM", "TJ_HOMPFIM",;
	"TJ_DTMRINI", "TJ_HOMRINI", "TJ_DTMRFIM", "TJ_HOMRFIM",;
	"TJ_TERMINO", "TJ_SITUACA" } //Campos que devem aparecer
	aNao := aClone( NGCAMPNSX3("STJ",aAux) )
	nAux := 0
	aEval(aNao, {|| nAux++, aNao[nAux] := AllTrim(aNao[nAux]) })
	aI03OrdHea[1] := CABECGETD("STJ", aNao, 2)
	aI03OrdCol := aClone( MNTC795MON(31) )

	aAux := {	"TS_ORDEM"  , "TS_PLANO"  , "TS_DTORIGI",;
	"TS_SERVICO", "TS_NOMSERV", "TS_SEQRELA",;
	"TS_DTMPINI", "TS_HOMPINI", "TS_DTMPFIM", "TS_HOMPFIM",;
	"TS_DTMRINI", "TS_HOMRINI", "TS_DTMRFIM", "TS_HOMRFIM",;
	"TS_TERMINO", "TS_SITUACA" } //Campos que devem aparecer
	aNao := aClone( NGCAMPNSX3("STS",aAux) )
	nAux := 0
	aEval(aNao, {|| nAux++, aNao[nAux] := AllTrim(aNao[nAux]) })
	aI03OrdHea[2] := CABECGETD("STS", aNao, 2)

	//+----------------------------+
	//| Historico de O.S.          |
	//+----------------------------+
	aI04OrdHea := { {}, {} }

	//--- Ordem de Servico (STJ)
	aAux := {	"TJ_ORDEM"  , "TJ_PLANO"  , "TJ_DTORIGI",;
	"TJ_SERVICO", "TJ_NOMSERV", "TJ_SEQRELA",;
	"TJ_TIPO"   , "TJ_NOMTIPO", "TJ_CODAREA", "TJ_NOMAREA",;
	"TJ_CCUSTO" , "TJ_NOMCUST", "TJ_POSCONT",;
	"TJ_DTMPINI", "TJ_HOMPINI", "TJ_DTMPFIM", "TJ_HOMPFIM",;
	"TJ_DTMRINI", "TJ_HOMRINI", "TJ_DTMRFIM", "TJ_HOMRFIM",;
	"TJ_TERMINO", "TJ_SITUACA" } //Campos que devem aparecer
	aNao := aClone( NGCAMPNSX3("STJ",aAux) )
	nAux := 0
	aEval(aNao, {|| nAux++, aNao[nAux] := AllTrim(aNao[nAux]) })
	aI04OrdHea[1] := CABECGETD("STJ", aNao, 2)
	aI04OrdCol := aClone( MNTC795MON(40) )

	//--- Ordem de Servico do Historico (STS)
	aAux := {	"TS_ORDEM"  , "TS_PLANO"  , "TS_DTORIGI",;
	"TS_SERVICO", "TS_NOMSERV", "TS_SEQRELA",;
	"TS_TIPO"   , "TS_NOMTIPO", "TS_CODAREA", "TS_NOMAREA",;
	"TS_CCUSTO" , "TS_NOMCUST", "TS_POSCONT",;
	"TS_DTMPINI", "TS_HOMPINI", "TS_DTMPFIM", "TS_HOMPFIM",;
	"TS_DTMRINI", "TS_HOMRINI", "TS_DTMRFIM", "TS_HOMRFIM",;
	"TS_TERMINO", "TS_SITUACA" } //Campos que devem aparecer
	aNao := aClone( NGCAMPNSX3("STS",aAux) )
	nAux := 0
	aEval(aNao, {|| nAux++, aNao[nAux] := AllTrim(aNao[nAux]) })
	aI04OrdHea[2] := CABECGETD("STS", aNao, 2)

	cI04Filtro := "Year(TJ_DTMPINI) >= Year(dDataBase)"
	fI04Filtro() //Monta a Expressao do Filtro para a STJ e STS

	//+----------------------------+
	//| Historico de Movimentacoes |
	//+----------------------------+
	//--- Estrutura
	aNao := {"TZ_BEMPAI"}

	aI05EstHea := CABECGETD("STZ", aNao, 2)
	aI05EstCol := aClone( MNTC795MON(50) )

	//--- Bem
	aNao := {"TPN_CODBEM"}

	aI05MovHea := CABECGETD("TPN", aNao, 2)
	aI05MovCol := aClone( MNTC795MON(51) )

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMNTC795VBEบAutor  ณWagner S. de Lacerdaบ Data ณ  01/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida o Bem e Carrega os dados.                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC795VBE()

	If IsInCallStack("MNTC795SAI") .Or. IsInCallStack("SAFEEVAL") //SAFEEVAL e' utilizado no Confirmar da EnchoiceBar
		Return .T.
	EndIf

	If cCodigoBem == cOldCodBem .And. !IsInCallStack("MNTC795ATU")
		Return .T.
	EndIf

	//Valida o Bem
	dbSelectArea("ST9")
	If !ExistCpo("ST9",cCodigoBem,1)
		Return .F.
	EndIf

	aAreaST9 := GetArea()
	aAreaTPE := {}
	aAreaDA3 := {}
	aAreaTQS := {}

	lTemCaract := .F.
	lTemPecRep := .F.
	lTemIntTMS := .F.
	lTemIntPne := .F.
	lTemComVei := .F.
	lTemManute := .F.
	lTemManOrd := .F.
	lTemOrdemS := .F.
	lTemEstrut := .F.
	lTemMovime := .F.

	CursorWait()

	/* Recebe os Dados da ST9 */
	cNomeBem   := ST9->T9_NOME

	cCodModBem := ST9->T9_TIPMOD
	cNomModBem := NGSEEK("TQR",cCodModBem,1,"TQR_DESMOD")

	cCodFamBem := ST9->T9_CODFAMI
	cNomFamBem := NGSEEK("ST6",cCodFamBem,1,"T6_NOME")

	cCodCatBem := ST9->T9_CATBEM
	cNomCatBem := AllTrim( NGRetSX3Box("T9_CATBEM",cCodCatBem) )

	cCodSitBem := ST9->T9_SITBEM
	cNomSitBem := AllTrim( NGRetSX3Box("T9_SITBEM",cCodSitBem) )

	cCodStaBem := ST9->T9_STATUS
	cNomStaBem := NGSEEK("TQY",cCodStaBem,1,"TQY_DESTAT")

	cCodTurBem := ST9->T9_CALENDA
	cNomTurBem  := NGSEEK("SH7",cCodTurBem,1,"H7_DESCRI")

	cPrioriBem := ST9->T9_PRIORID
	/**/

	/* Atualiza os Objetos do Cabecalho */
	oCodigoBem:CtrlRefresh()
	oNomeBem:CtrlRefresh()

	oCodModBem:CtrlRefresh()
	oNomModBem:CtrlRefresh()

	oCodFamBem:CtrlRefresh()
	oNomFamBem:CtrlRefresh()

	oNomCatBem:CtrlRefresh()
	oNomSitBem:CtrlRefresh()
	oNomStaBem:CtrlRefresh()

	oCodTurBem:CtrlRefresh()
	oNomTurBem:CtrlRefresh()

	oPrioriBem:CtrlRefresh()
	/**/

	CursorArrow()

	//Define todos os Dialogs principais como NAO acessados ainda
	aAcessoChg := {.F., .F., {.F.,.F.,.F.}, .F., .F., .F.}

	fAtualizar() //Atualiza a Consulta

	//Finaliza a Validacao
	If ST9->T9_CATBEM == "3"
		lDesTMS  := .F.
		lLePlaca := .F.
	Else
		lDesTMS  := .T.
		lLePlaca := .T.
	EndIf

	oI01Folder:SetOption(nI01Bem)

	cOldCodBem := cCodigoBem

	fInitTree()
	If ValType(oI00Say) == "O"
		oTree:TreeSeek(aTreeNivs[2])
	Else
		oTree:TreeSeek(aTreeNivs[1])
	EndIf
	oTree:SetFocus()
	fTreeChg()

	If Len(aAreaST9) > 0
		RestArea(aAreaST9)
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfAtualizarบAutor  ณWagner S. de Lacerdaบ Data ณ  06/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza o Conteudo da Consulta de Bem.                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fAtualizar()

	fBlackPnl()

	//+----------------------------+
	//บ Atualiza os Objetos        |
	//+----------------------------+
	fAtuObjs() //Deve atualizar antes para reinicializar os objetos (mais utilizado quando carregando outro Bem)

	//+----------------------------+
	//บ Estrutura do Bem           |
	//+----------------------------+
	MsgRun("Processando"+" "+"Estrutura do Bem"+"...", "Aguarde"+"...", {|| fProcI00() } )

	//+----------------------------+
	//บ Dados Cadastrais           |
	//+----------------------------+
	MsgRun("Processando"+" "+"Dados Cadastrais"+"...", "Aguarde"+"...", {|| fProcI01() } )

	//+----------------------------+
	//| Indicadores                |
	//+----------------------------+
	fProcI02()

	//+----------------------------+
	//| Manutencoes                |
	//+----------------------------+
	MsgRun("Processando"+" "+"Manuten็๕es"+"...", "Aguarde"+"...", {|| fProcI03() } )

	//+----------------------------+
	//| Historico de O.S.          |
	//+----------------------------+
	MsgRun("Processando"+" "+"Hist๓rico de O.S."+"...", "Aguarde"+"...", {|| fProcI04() } )

	//+----------------------------+
	//| Historico de Movimentacoes |
	//+----------------------------+
	MsgRun("Processando"+" "+"Hist๓rico de Movimenta็๕es"+"...", "Aguarde"+"...", {|| fProcI05() } )

	//+----------------------------+
	//| Atualiza os Objetos        |
	//+----------------------------+
	fAtuObjs() //Deve atualizar aqui tambem para iniciar os objetos com seus novos dados

	//+----------------------------+
	//| Habilita/Desabilita Folder |
	//+----------------------------+
	MNTC795HAB()

	fBlackPnl(.F.)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfProcI00  บAutor  ณWagner S. de Lacerdaบ Data ณ  10/01/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processa os Dados Cadastrais.                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fProcI00()

	// Variแveis auxiliares
	Local cBemPai := ""
	Local lBemPai := .F.
	Private cAliasSTC := GetNextAlias()
	Private aVETINR   := {}
	Private aIndSTC   := {}
	Private lGFrota
	Private lTipMod
	Private lStatus
	Private cStatus
	Private aDBFSTC
	Private oTempSTC
	Private lSequeSTC := NGCADICBASE( "TC_SEQUEN","A","STC",.F. ) //Verifica se existe o campo TC_SEQUEN no dicionแrio ou base dados.

	// Libera filhos do painel
	oConInfo00:FreeChildren()

	// Recebe Pai da Estrutura
	cBemPai := NGBEMPAI(cCodigoBem)
	lBemPai := !Empty(cBemPai)

	// Monta Estrutura
	dbSelectArea("STC")
	dbSetOrder(1)
	If dbSeek(xFilial("STC") + If(lBemPai, cBemPai, cCodigoBem))
		// Variแveis do MNTA090
		lGFrota := IIf(FindFunction('MNTFrotas'), MNTFrotas(), SuperGetMv("MV_NGMNTFR",.F.," ") == 'S' .And. SuperGetMv("MV_NGPNEUS",.F.," ") == 'S')
		lTipMod := GetRPORelease() >= '12.1.033' .Or. lGFrota
		lStatus := NGCADICBASE('TQY_STATUS','A','TQY',.f.)
		cStatus := If(lStatus,Space(Len(ST9->T9_STATUS)),Space(2))

		aDBFSTC   := {{"TC_FILIAL","C",If(FindFunction("FwSizeFilial"),FwSizeFilial(),2),0},{"TC_CODBEM","C",16,0},{"TC_NOME","C",40,0}}

		oTempSTC := FWTemporaryTable():New(cAliasSTC, aDBFSTC)
		oTempSTC:AddIndex("Ind01", {"TC_FILIAL","TC_CODBEM"})
		oTempSTC:Create()

		// Grava o ๚nico registro na TRB
		RecLock(cAliasSTC, .T.)
		(cAliasSTC)->TC_FILIAL := STC->TC_FILIAL
		(cAliasSTC)->TC_CODBEM := STC->TC_CODBEM
		(cAliasSTC)->TC_NOME   := NGSEEK("ST9", STC->TC_CODBEM, 1, "T9_NOME")
		MsUnlock()
		(cAliasSTC)->( dbGoTop() )

		// Monta
		NG090PROCES("STC", RecNo(), 2, oConInfo00)

		//NGDELETRB(cAliasSTC,cARQTEMP)
		oTempSTC:Delete()
	Else
		oI00Say := TSay():New(001, 012, {|| OemToAnsi("Bem nใo possui estrutura.")}, oConInfo00, , , , ;
		, ,.T., CLR_BLACK, , 150, 010)
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfProcI01  บAutor  ณWagner S. de Lacerdaบ Data ณ  19/10/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processa os Dados Cadastrais.                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fProcI01()

	Local uAuxText

	//Verifica se o Bem possui os contadores
	If Len(aAreaST9) > 0
		RestArea(aAreaST9)
	EndIf

	lBemConta1 := .F.
	If ST9->T9_TEMCONT <> "N"
		lBemConta1 := .T.
	EndIf

	uAuxText := AllTrim( NGRetSX3Box("T9_TEMCONT",ST9->T9_TEMCONT) )
	oI01Cnt1Say:SetText(OemToAnsi(uAuxText))
	oI01Cnt1Say:SetColor(If(ST9->T9_TEMCONT <> "N",CLR_GREEN,CLR_RED), CLR_WHITE)
	oI01Cnt1Say:Refresh()

	lBemConta2 := .T.
	If !NGIFDBSEEK("TPE", cCodigoBem, 1)
		lBemConta2 := .F.
		PutFileInEof("TPE")
	EndIf
	aAreaTPE := GetArea()

	uAuxText := If(lBemConta2,"Bem possui Segundo Contador","Bem nใo possui Segundo Contador")
	oI01Cnt2Say:SetText(OemToAnsi(uAuxText))
	oI01Cnt2Say:SetColor(If(lBemConta2,CLR_GREEN,CLR_RED), CLR_WHITE)
	oI01Cnt2Say:Refresh()

	//--- Caracteristicas
	dbSelectArea("STB")
	dbSetOrder(1)
	aI01CrtCol := MAKEGETD("STB", cCodigoBem, aI01CrtHea,;
	"ST9->T9_FILIAL + ST9->T9_CODBEM  == '"+xFilial("STB")+cCodigoBem+"'", , .F.)
	If Len(aI01CrtCol) == 0
		aI01CrtCol := aClone( MNTC795MON(11) )
	EndIf
	lTemCaract := .F.
	If Len(aI01CrtCol) > 0 .And. !Empty(aI01CrtCol[1][1])
		lTemCaract := .T.
	EndIf

	//--- Pecas Reposicao
	dbSelectArea("TPY")
	dbSetOrder(1)
	aI01PeRCol := MAKEGETD("TPY", cCodigoBem, aI01PeRHea,;
	"TPY->TPY_FILIAL + TPY->TPY_CODBEM == '"+xFilial("TPY")+cCodigoBem+"'", , .F.)
	If Len(aI01PeRCol) == 0
		aI01PeRCol := aClone( MNTC795MON(12) )
	EndIf
	lTemPecRep := .F.
	If Len(aI01PeRCol) > 0 .And. !Empty(aI01PeRCol[1][1])
		lTemPecRep := .T.
	EndIf

	//--- TMS
	If lUsaIntTMS
		If Len(aAreaST9) > 0
			RestArea(aAreaST9)
		EndIf

		lTemIntTMS := .T.
		If !NGIFDBSEEK("DA3", cCodigoBem+ST9->T9_CODTMS, 5)
			lTemIntTMS := .F.
			PutFileInEof("DA3")
		EndIf
		aAreaDA3 := GetArea()
	EndIf

	//--- Pneu
	If lUsaIntTQS
		lTemIntPne := .T.
		If !NGIFDBSEEK("TQS", cCodigoBem, 1)
			lTemIntPne := .F.
			PutFileInEof("TQS")
		EndIf
		aAreaTQS := GetArea()
	EndIf

	//--- Complemento Veiculo
	lTemComVei := ( cCodCatBem == "2" .Or. cCodCatBem == "4" )

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfProcI02  บAutor  ณWagner S. de Lacerdaบ Data ณ  19/10/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processa os Indicadores.                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fProcI02()

	Local aSetParams := {}

	If ValType(oI02TNGPnl) == "O"
		If !IsInCallStack("fRefrshWnd") //Se nao estiver atualizando os objetos em tela
			oI02TNGPnl:Refresh()
		EndIf
		aAdd(aSetParams, {"DE_BEM", cCodigoBem})
		aAdd(aSetParams, {"ATE_BEM", cCodigoBem})
		aAdd(aSetParams, {"DE_DATA", dDataBase-180})
		aAdd(aSetParams, {"ATE_DATA", dDataBase})
		oI02TNGPnl:SetParams(aSetParams)
		oI02TNGPnl:Calculate()
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfProcI03  บAutor  ณWagner S. de Lacerdaบ Data ณ  19/10/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processa as Manutencoes.                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fProcI03()

	Local uAuxText

	//--- Manutencoes
	dbSelectArea("STF")
	dbSetOrder(1)
	aI03ManCol := MAKEGETD("STF", cCodigoBem, aI03ManHea,;
	"STF->TF_FILIAL + STF->TF_CODBEM  == '"+xFilial("STF")+cCodigoBem+"'", , .F.)
	If Len(aI03ManCol) == 0
		aI03ManCol := aClone( MNTC795MON(30) )
	EndIf
	lTemManute := .F.
	If Len(aI03ManCol) > 0 .And. !Empty(aI03ManCol[1][1])
		lTemManute := .T.
	EndIf

	uAuxText := "Quantidade de Registros:"+" "+Transform(If(lTemManute,Len(aI03ManCol),0),"@E 999,999,999")
	oI03ManRod:SetText(OemToAnsi(uAuxText))
	oI03ManRod:Refresh()

	Processa({|| fCarrOS(2) },"Aguarde"+"...")

	aAcessoChg[4] := .T.

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfProcI04  บAutor  ณWagner S. de Lacerdaบ Data ณ  19/10/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processa o Historico de Ordem de Servico.                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fProcI04()

	Processa({|| fCarrOS(1) },"Aguarde"+"...")

	aAcessoChg[5] := .T.

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfProcI05  บAutor  ณWagner S. de Lacerdaบ Data ณ  19/10/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processa o Historico de Movimentacoes.                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fProcI05()

	Processa({|| fCarrMov(1) },"Aguarde"+"...")
	Processa({|| fCarrMov(2) },"Aguarde"+"...")

	aAcessoChg[6] := .T.

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfAtuObjs  บAutor  ณWagner S. de Lacerdaบ Data ณ  27/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza os objetos da tela.                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fAtuObjs()

	Local nSeqRela := TAMSX3("TF_SEQRELA")[1]

	Local nTBCARACTE := aScan(aI01CrtHea, {|x| Upper(AllTrim(x[2])) == "TB_CARACTE" })

	Local nTPYCODPRO := aScan(aI01PeRHea, {|x| Upper(AllTrim(x[2])) == "TPY_CODPRO" })

	Local nTFSERVICO := aScan(aI03ManHea, {|x| Upper(AllTrim(x[2])) == "TF_SERVICO" })
	Local nTFSEQRELA := aScan(aI03ManHea, {|x| Upper(AllTrim(x[2])) == "TF_SEQRELA" })

	//--- Bem
	oI01Bem:Refresh()

	//--- Caracteristicas
	If nTBCARACTE > 0
		aSort(aI01CrtCol, , , {|x,y| x[nTBCARACTE] <  y[nTBCARACTE] })
	EndIf

	oI01Crt:SetArray(aI01CrtCol)
	oI01Crt:GoTop()
	oI01Crt:Refresh()

	//--- Pecas de Reposicao
	If nTPYCODPRO > 0
		aSort(aI01PeRCol, , , {|x,y| x[nTPYCODPRO] <  y[nTPYCODPRO] })
	EndIf
	oI01PeR:SetArray(aI01PeRCol)
	oI01PeR:GoTop()
	oI01PeR:Refresh()

	//--- TMS
	If lUsaIntTMS
		oI01TMS:Refresh()
	EndIf

	//--- Pneu
	If lUsaIntTQS
		oI01Pne:Refresh()
	EndIf

	//--- Complemento Veiculo
	oI01CoV:Refresh()

	//--- Ficha Tecnica
	oI01FcT:Refresh()

	//--- Contadores
	oI01Cnt1:Refresh()
	oI01Cnt2:Refresh()

	//--- Manutencoes
	If nTFSERVICO > 0 .And. nTFSEQRELA > 0
		aSort(aI03ManCol, , , {|x,y| x[nTFSERVICO]+PADL(x[nTFSEQRELA],nSeqRela,"0") <  y[nTFSERVICO]+PADL(y[nTFSEQRELA],nSeqRela,"0") })
	EndIf
	oI03Man:SetArray(aI03ManCol)
	oI03Man:GoTop()
	oI03Man:Refresh()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} fAtuMemory
Atualiza as variaveis de Memoria da Tela.
@author  Wagner S. de Lacerda
@since   09/09/2011
@param cTable, caractere, Indica a tabela a ser usada
@return l๓gico, .T.
@version P12
/*/
//-------------------------------------------------------------------
Static Function fAtuMemory(cTable)

	Local cField 		:= ""
	Local cLoad 		:= ""
	Local cRead 		:= ""
	Local cContext 		:= ""
	Local cRelacao 		:= ""
	Local cArquivo 		:= ""
	Local cCampo	 	:= ""
	Local nInd			:= 0
	Local nTamTot		:= 0
	Local lValida 		:= .F.
	Local aNgHeader		:= {}

	Private aHeader	:= {}

	If cTable == "ST9" .And. Len(aAreaST9) > 0
		lValida := .T.
		RestArea(aAreaST9)

	ElseIf cTable == "TPE" .And. lBemConta2 .And. Len(aAreaTPE) > 0
		lValida := .T.
		RestArea(aAreaTPE)

	ElseIf cTable == "DA3" .And. lUsaIntTMS .And. Len(aAreaDA3) > 0
		lValida := .T.
		RestArea(aAreaDA3)

	ElseIf cTable == "TQS" .And. lUsaIntTQS .And. Len(aAreaTQS) > 0
		lValida := .T.
		RestArea(aAreaTQS)

	EndIf

	If lValida

		aNgHeader := NGHeader(cTable,,.F.)
		nTamTot := Len(aNgHeader)

		For nInd := 1 To nTamTot

			cCampo := aNgHeader[nInd,2]
	        cContext 	:= Posicione("SX3",2,cCampo,"X3_CONTEXT")
			cRelacao 	:= Posicione("SX3",2,cCampo,"X3_RELACAO")
			cArquivo 	:= Posicione("SX3",2,cCampo,"X3_ARQUIVO")
			cLoad 		:= "M->"+AllTrim(cCampo)

	        If cContext == "V"
				cRead := AllTrim(cRelacao)
			Else
				cRead := AllTrim(cArquivo)+"->"+AllTrim(cCampo)
			EndIf

			&(cLoad) := &(cRead)

		Next nInd

	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMNTC795HABบAutor  ณWagner S. de Lacerdaบ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Habilita/Desabilita os Folders conforme possuam, ou nao,   บฑฑ
ฑฑบ          ณ dados para apresentar.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nMonta -> Obrigatorio;                                     บฑฑ
ฑฑบ          ณ           Indica o que deve montar.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC795HAB()

	//ษออออออออออออออออออออออออออออป
	//บ Dados Cadastrais           บ
	//ศออออออออออออออออออออออออออออผ
	If Len(aAreaST9) > 0
		RestArea(aAreaST9)
	EndIf

	//--- Caracteristicas
	oI01Folder:aEnable(nI01Crt,lTemCaract)

	//--- Pecas de Reposicao
	oI01Folder:aEnable(nI01PeR,lTemPecRep)

	//--- TMS
	If lUsaIntTMS
		oI01Folder:aEnable(nI01TMS,lTemIntTMS)
	EndIf

	//--- Pneu
	If lUsaIntTQS
		oI01Folder:aEnable(nI01Pne,lTemIntPne)
	EndIf

	//--- Complemento Veiculo
	oI01Folder:aEnable(nI01CoV, lTemComVei)

	//--- Contadores
	If lBemConta1
		oI01Cnt1:Show()
	Else
		oI01Cnt1:Hide()
	EndIf
	If lBemConta2
		oI01Cnt2:Show()
	Else
		oI01Cnt2:Hide()
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMNTC795MONบAutor  ณWagner S. de Lacerdaบ Data ณ  01/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta os dados de certas variaveis (aChoice, aCols, ...)   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nMonta -> Obrigatorio;                                     บฑฑ
ฑฑบ          ณ           Indica o que deve montar.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC795MON(nMonta)

	Local aNao   := {}, aAux := {}
	Local aMonta := {}
	Local nCont := 0

	If nMonta == 10 //Dados Cadastrais - Bem
		aAdd(aNao,"T9_CODTMS")
		aAdd(aNao,"T9_PLACA")
		If !lTT8Existe
			aAdd(aNao,"T9_CAPMAX")
			aAdd(aNao,"T9_MEDIA")
		EndIf
		aAdd(aNao,"T9_TIPVEI")
		aAdd(aNao,"T9_CHASSI")
		aAdd(aNao,"T9_VALANO")
		aAdd(aNao,"T9_CORVEI")
		aAdd(aNao,"T9_DESCOR")
		aAdd(aNao,"T9_CIDEMPL")
		aAdd(aNao,"T9_UFEMPLA")
		aAdd(aNao,"T9_RENAVAM")
		aAdd(aNao,"T9_NRMOTOR")
		aAdd(aNao,"T9_CEREVEI")

		If ExistBlock("MNTA080A")
			aAux := aClone( ExecBlock("MNTA080A",.F.,.F.) )
			For nCont := 1 To Len(aAux)
				aAdd(aNao,aAux[nCont])
			Next nCont
		EndIf

		aMonta := aClone( NGCAMPNSX3("ST9",aNao) )
	ElseIf nMonta == 11 //Dados Cadastrais - Caracteristicas
		aMonta := BLANKGETD(aI01CrtHea)
	ElseIf nMonta == 12 //Dados Cadastrais - Pecas de Reposicao
		aMonta := BLANKGETD(aI01PeRHea)
	ElseIf nMonta == 13 //Dados Cadastrais - TMS
		aMonta := aClone( NGCAMPNSX3("DA3",aNao) )
	ElseIf nMonta == 14 //Dados Cadastrais - Pneu
		aMonta := aClone( NGCAMPNSX3("TQS",aNao) )
	ElseIf nMonta == 15 //Dados Cadastrais - Complemento Veiculo
		aAdd(aMonta,"T9_CODTMS")
		aAdd(aMonta,"T9_PLACA")
		If !lTT8Existe
			aAdd(aMonta,"T9_CAPMAX")
			aAdd(aMonta,"T9_MEDIA")
		EndIf
		aAdd(aMonta,"T9_TIPVEI")
		aAdd(aMonta,"T9_CHASSI")
		aAdd(aMonta,"T9_VALANO")
		If NGCADICBASE("T9_CORVEI","D","ST9",.F.)
			aAdd(aMonta,"T9_CORVEI")
			aAdd(aMonta,"T9_DESCOR")
			aAdd(aMonta,"T9_CIDEMPL")
			aAdd(aMonta,"T9_UFEMPLA")
			aAdd(aMonta,"T9_RENAVAM")
			aAdd(aMonta,"T9_NRMOTOR")
			aAdd(aMonta,"T9_CEREVEI")
		EndIf

		If ExistBlock("MNTA080B")
			aAux := aClone( ExecBlock("MNTA080B",.F.,.F.) )
			For nCont := 1 To Len(aAux)
				aAdd(aMonta,aAux[nCont])
			Next nCont
		EndIf
	ElseIf nMonta == 16 //Dados Cadastrais - Ficha Tecnica
		aAdd(aMonta,"T9_TIPMOD")
		aAdd(aMonta,"T9_DESMOD")
		aAdd(aMonta,"T9_FABRICA")
		aAdd(aMonta,"T9_NOMFABR")
		aAdd(aMonta,"T9_MODELO")
		aAdd(aMonta,"T9_SERIE")
		aAdd(aMonta,"T9_DTCOMPR")
		aAdd(aMonta,"T9_PRGARAN")
		aAdd(aMonta,"T9_UNGARAN")
		aAdd(aMonta,"T9_DTGARAN")
	ElseIf nMonta == 17 //Dados Cadastrais - Contador 1
		aAdd(aMonta,"T9_TPCONTA")
		aAdd(aMonta,"T9_POSCONT")
		aAdd(aMonta,"T9_DTULTAC")
		aAdd(aMonta,"T9_CONTACU")
		aAdd(aMonta,"T9_VARDIA")
		aAdd(aMonta,"T9_LIMICON")
		aAdd(aMonta,"T9_PERACOM")
		aAdd(aMonta,"T9_UNIACOM")
	ElseIf nMonta == 18 //Dados Cadastrais - Contador 2
		aAdd(aMonta,"TPE_TPCONT")
		aAdd(aMonta,"TPE_POSCON")
		aAdd(aMonta,"TPE_DTULTA")
		aAdd(aMonta,"TPE_CONTAC")
		aAdd(aMonta,"TPE_VARDIA")
		aAdd(aMonta,"TPE_LIMICO")
		aAdd(aMonta,"TPE_VIRADA")
		aAdd(aMonta,"TPE_CONTGA")
	ElseIf nMonta == 30 //Manutencoes
		aMonta := BLANKGETD(aI03ManHea)
	ElseIf nMonta == 31 //Ordens de Servico da Manutencao
		aMonta := BLANKGETD(aI03OrdHea[1])
	ElseIf nMonta == 40 //Historico de Ordem de Servico
		aMonta := BLANKGETD(aI04OrdHea[1])
	ElseIf nMonta == 50 //Historico de Movimentacao da Estrutura
		aMonta := BLANKGETD(aI05EstHea)
	ElseIf nMonta == 51 //Historico de Movimentacao do Bem
		aMonta := BLANKGETD(aI05MovHea)
	EndIf

Return aMonta

//-------------------------------------------------------------------
/*/{Protheus.doc} fMontaBrw
Monta o FWBrowse a partir do dicionario.

@author  Wagner S. de Lacerda
@since   08/09/2011
@param aHeader, array, Define o aHeader do Browse.
@param aCols, array, Define o aCols do Browse.
@param oObjPai, objeto, Define o objeto Pai do Browse.
@return oFWBrowse, Objeto do Browse.
/*/
//-------------------------------------------------------------------
Static Function fMontaBrw(aHeader, aCols, oObjPai)

	Local oFWBrowse
	Local cData
	Local aColunas, oColuna
	Local nX

	oFWBrowse := FWBrowse():New()
	oFWBrowse:SetOwner(oObjPai)
	oFWBrowse:SetDataArray()
	oFWBrowse:SetInsert(.F.)

	oFWBrowse:SetLineHeight(16)

	oFWBrowse:DisableConfig() //Desabilita 'Configurar'
	oFWBrowse:DisableFilter() //Desabilita 'Filtrar'
	oFWBrowse:DisableLocate() //Desabilita 'Localizar'
	oFWBrowse:DisableReport() //Desabilita 'Impressao'
	oFWBrowse:DisableSaveConfig() //Desabilita 'Salvar a Configuracao'

	// Monta o Browse
	aColunas := {}
	For nX := 1 To Len(aHeader)

		If posicione("SX3",2,aHeader[nx,2],"X3_CAMPO") <> ""
			oColuna := FWBrwColumn():New()
			oColuna:SetAlign( If(Posicione("SX3",2,aHeader[nX][2],"X3_TIPO") == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )

			If !Empty(X3CBOX(aHeader[nX][2]))
				cData := "{|| AllTrim( NGRetSX3Box('"+ aHeader[nX][2]+ "',aCols[oFWBrowse:AT()]["+cValToChar(nX)+"]) ) }"
			Else
				cData := "{|| aCols[oFWBrowse:AT()]["+cValToChar(nX)+"] }"
			EndIf
			oColuna:SetData( &(cData) )

			oColuna:SetEdit( .F. )
			oColuna:SetPicture( X3Picture(aHeader[nX][2]) )
			oColuna:SetSize( TAMSX3(aHeader[nX][2])[1] )
			oColuna:SetTitle( X3Titulo(aHeader[nX][2]) )
			oColuna:SetType( Posicione("SX3",2,aHeader[nX][2],"X3_TIPO") )

			aAdd(aColunas, oColuna)
		EndIf
	Next nX

	oFWBrowse:SetColumns(aColunas)

	oFWBrowse:Activate()

Return oFWBrowse

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfBlackPnl บAutor  ณWagner S. de Lacerdaบ Data ณ  20/04/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Habilita/Desabilita a tela com um Painel Preto.            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ lVisible -> Opcional;                                      บฑฑ
ฑฑบ          ณ             Define a visibilidade do Painel Preto.         บฑฑ
ฑฑบ          ณ             Default: .T. -> Visivel                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fBlackPnl(lVisible)

	Default lVisible := .T.

	If Type("oBlackPnl") <> "O"
		oBlackPnl := TPanel():New(0, 0, , oDlgCBEM, , , , , SetTransparentColor(CLR_BLACK,70), nLargura, nAltura, .F., .F.)
		oBlackPnl:Hide()
	EndIf

	If lVisible
		oBlackPnl:Show()
		//Nao permite atualizar a consulta
		lCBEMAtu := .T.
	Else
		oBlackPnl:Hide()
		//Permite atualizar a consulta
		lCBEMAtu := .T.
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfCarrOS   บAutor  ณWagner S. de Lacerdaบ Data ณ  20/04/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega as Ordens de Servico.                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nCarrega -> Obrigatorio;                                   บฑฑ
ฑฑบ          ณ             Indica como deve ser o carregamento de O.S.'s: บฑฑ
ฑฑบ          ณ              1 - Ordens de Servico do Historico            บฑฑ
ฑฑบ          ณ              2 - Ordem de Servico da Manutencao            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fCarrOS(nCarrega)

	Local cSeekSTJ   := ""
	Local cSeekSTS   := ""
	Local cCondicSTJ := ""
	Local cCondicSTS := ""
	Local nOrder     := 1

	Local aColsSTJ := {}, aColsSTS := {}, aColsTemp := {}
	Local nX       := 0
	Local uAuxText

	Local nTFSERVICO := 0

	Local nTJORDEM   := 0
	Local nTJPLANO   := 0
	Local nTJDTMPINI := 0

	If nCarrega == 1 //O.S.'s do Historico
		nTJORDEM   := aScan(aI04OrdHea[1], {|x| Upper(AllTrim(x[2])) == "TJ_ORDEM" })
		nTJPLANO   := aScan(aI04OrdHea[1], {|x| Upper(AllTrim(x[2])) == "TJ_PLANO" })
		nTJDTMPINI := aScan(aI04OrdHea[1], {|x| Upper(AllTrim(x[2])) == "TJ_DTMPINI" })
	ElseIf nCarrega == 2 //O.S.'s da Manutencao
		If oI03Man:AT() == 0
			Return .F.
		EndIf

		nTFSERVICO := aScan(aI03ManHea, {|x| Upper(AllTrim(x[2])) == "TF_SERVICO" })

		nTJORDEM   := aScan(aI03OrdHea[1], {|x| Upper(AllTrim(x[2])) == "TJ_ORDEM" })
		nTJPLANO   := aScan(aI03OrdHea[1], {|x| Upper(AllTrim(x[2])) == "TJ_PLANO" })
		nTJDTMPINI := aScan(aI03OrdHea[1], {|x| Upper(AllTrim(x[2])) == "TJ_DTMPINI" })
	Else
		Return .F.
	EndIf

	If nCarrega == 1 //O.S.'s do Historico
		cSeekSTJ   := "B"+cCodigoBem //A funcao MAKEGETD ja utiliza o xFilial()
		cSeekSTS   := "B"+cCodigoBem //A funcao MAKEGETD ja utiliza o xFilial()
		nOrder     := 2

		cCondicSTJ := "STJ->TJ_FILIAL == '"+xFilial("STJ")+"' .And. STJ->TJ_TIPOOS == 'B' .And. STJ->TJ_CODBEM == '"+cCodigoBem+"'"
		cCondicSTS := "STS->TS_FILIAL == '"+xFilial("STS")+"' .And. STS->TS_TIPOOS == 'B' .And. STS->TS_CODBEM == '"+cCodigoBem+"'"
	ElseIf nCarrega == 2 //O.S.'s da Manutencao
		cSeekSTJ   := aI03ManCol[oI03Man:AT()][nTFSERVICO]+"B"+cCodigoBem //A funcao MAKEGETD ja utiliza o xFilial()
		cSeekSTS   := aI03ManCol[oI03Man:AT()][nTFSERVICO]+"B"+cCodigoBem //A funcao MAKEGETD ja utiliza o xFilial()
		nOrder     := 4

		cCondicSTJ := "STJ->TJ_FILIAL == '"+xFilial("STJ")+"' .And. STJ->TJ_SERVICO == '"+aI03ManCol[oI03Man:AT()][nTFSERVICO]+"' .And. STJ->TJ_TIPOOS == 'B' .And. STJ->TJ_CODBEM == '"+cCodigoBem+"'"
		cCondicSTS := "STS->TS_FILIAL == '"+xFilial("STS")+"' .And. STS->TS_SERVICO == '"+aI03ManCol[oI03Man:AT()][nTFSERVICO]+"' .And. STS->TS_TIPOOS == 'B' .And. STS->TS_CODBEM == '"+cCodigoBem+"'"
	EndIf

	aColsTemp := {}
	ProcRegua(2)

	dbSelectArea("STJ")
	dbSetOrder(nOrder)
	aColsSTJ := MAKEGETD("STJ", cSeekSTJ, If(nCarrega == 1, aI04OrdHea[1], aI03OrdHea[1]), cCondicSTJ, , .F.)
	IncProc("Buscando"+" "+"Ordem de Servi็o"+"...")

	dbSelectArea("STS")
	dbSetOrder(nOrder)
	aColsSTS := MAKEGETD("STS", cSeekSTS, If(nCarrega == 1, aI04OrdHea[2], aI03OrdHea[2]), cCondicSTS, , .F.)
	IncProc("Buscando"+" "+"Ordem de Servi็o"+"...")

	//--- Adiciona ao array do browse
	ProcRegua(Len(aColsSTS))
	For nX := 1 To Len(aColsSTS)
		IncProc("Processando"+" "+"Ordem de Servi็o"+"...")

		If nCarrega == 1 //O.S.'s do Historico
			If !Eval( &(cI04FilSTS) )
				Loop
			EndIf
		ElseIf nCarrega == 2 //O.S.'s da Manutencao
			If nTJDTMPINI > 0 .And. !lI03OrdHis //Nao carregar todo o historico
				If aColsSTS[nX][nTJDTMPINI] < dI03DeDt .Or. aColsSTS[nX][nTJDTMPINI] > dI03AteDt
					Loop
				EndIf
			EndIf
		EndIf

		aAdd(aColsTemp, aColsSTS[nX])
	Next nX

	ProcRegua(Len(aColsSTJ))
	For nX := 1 To Len(aColsSTJ)
		IncProc("Processando"+" "+"Ordem de Servi็o"+"...")

		If nCarrega == 1 //O.S.'s do Historico
			If !Eval( &(cI04FilSTJ) )
				Loop
			EndIf
		ElseIf nCarrega == 2 //O.S.'s da Manutencao
			If nTJDTMPINI > 0 .And. !lI03OrdHis //Nao carregar todo o historico
				If aColsSTJ[nX][nTJDTMPINI] < dI03DeDt .Or. aColsSTJ[nX][nTJDTMPINI] > dI03AteDt
					Loop
				EndIf
			EndIf
		EndIf

		aAdd(aColsTemp, aColsSTJ[nX])
	Next nX

	If nCarrega == 1 //O.S.'s do Historico
		aI04OrdCol := aClone( aColsTemp )

		lTemOrdemS := .T.
		If Len(aI04OrdCol) == 0
			aI04OrdCol := aClone( MNTC795MON(40) )
			lTemOrdemS := .F.
		EndIf

		If nTJORDEM > 0 .And. nTJPLANO > 0
			aSort(aI04OrdCol, , , {|x,y| x[nTJORDEM]+x[nTJPLANO] < y[nTJORDEM]+y[nTJPLANO] })
		EndIf
		oI04Ord:SetArray(aI04OrdCol)
		oI04Ord:GoTop()
		oI04Ord:Refresh()

		uAuxText := "Quantidade de Registros:"+" "+Transform(If(lTemOrdemS,Len(aI04OrdCol),0),"@E 999,999,999")
		oI04OrdRod:SetText(OemToAnsi(uAuxText))
		oI04OrdRod:Refresh()
	ElseIf nCarrega == 2 //O.S.'s da Manutencao
		aI03OrdCol := aClone( aColsTemp )

		lTemManOrd := .T.
		If Len(aI03OrdCol) == 0
			aI03OrdCol := aClone( MNTC795MON(31) )
			lTemManOrd := .F.
		EndIf

		If nTJORDEM > 0 .And. nTJPLANO > 0
			aSort(aI03OrdCol, , , {|x,y| x[nTJORDEM]+x[nTJPLANO] < y[nTJORDEM]+y[nTJPLANO] })
		EndIf
		oI03Ord:SetArray(aI03OrdCol)
		oI03Ord:GoTop()
		oI03Ord:Refresh()

		uAuxText := "Quantidade de Registros:"+" "+Transform(If(lTemManOrd,Len(aI03OrdCol),0),"@E 999,999,999")
		oI03OrdRod:SetText(OemToAnsi(uAuxText))
		oI03OrdRod:Refresh()
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfCarrMov  บAutor  ณWagner S. de Lacerdaบ Data ณ  26/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega as Movimentacoes do Bem/Esturutra do Bem.          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nCarrega -> Obrigatorio;                                   บฑฑ
ฑฑบ          ณ             Indica como deve ser o carregamento das Movi-  บฑฑ
ฑฑบ          ณ             mentacoes.                                     บฑฑ
ฑฑบ          ณ              1 - Movimentacoes da Estrutura                บฑฑ
ฑฑบ          ณ              2 - Movimentacoes do Bem                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC795                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fCarrMov(nCarrega)

	Local uAuxText

	If nCarrega == 1 //Movimentacoes da Estrutura
		dbSelectArea("STZ")
		dbSetOrder(4)
		aI05EstCol := MAKEGETD("STZ", cCodigoBem, aI05EstHea, "STZ->TZ_BEMPAI == '"+cCodigoBem+"'", , .F.)

		lTemEstrut := .T.
		If Len(aI05EstCol) == 0
			aI05EstCol := aClone( MNTC795MON(50) )
			lTemEstrut := .F.
		EndIf

		oI05Est:SetArray(aI05EstCol)
		oI05Est:GoTop()
		oI05Est:Refresh()

		uAuxText := If(lTemEstrut,"Bem possui Estrutura","Bem nใo possui Estrutura")
		oI05EstSay:SetText(OemToAnsi(uAuxText))
		oI05EstSay:SetColor(If(lTemEstrut,CLR_GREEN,CLR_RED), CLR_WHITE)
		oI05EstSay:Refresh()

		uAuxText := "Quantidade de Registros:"+" "+Transform(If(lTemEstrut,Len(aI05EstCol),0),"@E 999,999,999")
		oI05EstRod:SetText(OemToAnsi(uAuxText))
		oI05EstRod:Refresh()
	ElseIf nCarrega == 2 //Movimentacoes do Bem
		dbSelectArea("TPN")
		dbSetOrder(1)
		aI05MovCol := MAKEGETD("TPN", cCodigoBem, aI05MovHea, "TPN->TPN_CODBEM == '"+cCodigoBem+"'", , .F.)

		lTemMovime := .T.
		If Len(aI05MovCol) == 0
			aI05MovCol := aClone( MNTC795MON(51) )
			lTemMovime := .F.
		EndIf

		oI05Mov:SetArray(aI05MovCol)
		oI05Mov:GoTop()
		oI05Mov:Refresh()

		uAuxText := If(lTemMovime,"Bem possui Movimenta็ใo","Bem nใo possui Movimenta็ใo")
		oI05MovSay:SetText(OemToAnsi(uAuxText))
		oI05MovSay:SetColor(If(lTemMovime,CLR_GREEN,CLR_RED), CLR_WHITE)
		oI05MovSay:Refresh()

		uAuxText := "Quantidade de Registros:"+" "+Transform(If(lTemMovime,Len(aI05MovCol),0),"@E 999,999,999")
		oI05MovRod:SetText(OemToAnsi(uAuxText))
		oI05MovRod:Refresh()
	Else
		Return .F.
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ SECAO: FUNCOES DIVERSAS - FIM                                         บฑฑ
ฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
