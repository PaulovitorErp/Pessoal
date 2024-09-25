#Include "mdta110.ch"
#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA110A
Programa De Saude

@author  Inacio Luiz Kolling
@since   17/01/2000

@return  Lógico, Verdadeiro quando a fonção for executada normalmente
/*/
//-------------------------------------------------------------------
Function MDTA110A()

	Local aSMenuOld := aClone(aSMenu)

	// Define Array contendo as Rotinas a executar do programa
	// ----------- Elementos contidos por dimensao ------------
	// 1. Nome a aparecer no cabecalho
	// 2. Nome da Rotina associada
	// 3. Usado pela rotina
	// 4. Tipo de Transa‡„o a ser efetuada
	//    1 - Pesquisa e Posiciona em um Banco de Dados
	//    2 - Simplesmente Mostra os Campos
	//    3 - Inclui registros no Bancos de Dados
	//    4 - Altera o registro corrente
	//    5 - Remove o registro corrente do Banco de Dados

	If !(IsInCallStack( "MDTA120" ) .Or. IsInCallStack( "MDTA110" )) .And. !IsBlind()
		ShowHelpDlg( STR0035, ;          //"ATENÇÃO"
					{ STR0046 }, 1,;     //"Execução não permitida."
					{ STR0047, "" }, 1 ) //"A execução dessa rotina somente pode ser executada pelo menu de Ocorrências Ficha (MDTA110)
										 //ou pelo menu Ficha Médica (MDTA120)."

		Return .F.
	EndIf

	If FindFunction("MDTRESTRI")
		If !MDTRESTRI("MDTA114")
			Return .F.
		ElseIf !MDTRESTRI("MDTA115")
			Return .F.
		Endif
	Endif

	//Verifica se o funcionario esta demitido
	If !SitFunFicha(TM0->TM0_NUMFIC,.F.,.T.,.T.)
		Return
	Endif

	If SuperGetMv("MV_NG2AUDI",.F.,"2") == "1"
		aAdd(aSMenu,{ STR0030 , "MDTRELHIS('TMN')" })//"Histórico do Registro"
	EndIf

	Private aRotina := MenuDef()

	oldROTINA := aCLONE(aROTINA)

	// Define o cabecalho da tela de atualizacoes
	Private LENUMFIC  := .F.
	Private cCada     := cCadastro
	Private cCadastro := STR0014 //"Programa de Saude"
	Private cNomfic   := TM0->TM0_NOMFIC

	If lSigaMdtPS
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1")+TM0->TM0_CLIENT+TM0->TM0_LOJA)
		Private cCliMdtPs := SA1->A1_COD+SA1->A1_LOJA
	EndIf

	SetFunName("MDTA110A")
	cCadastro := OemtoAnsi(cCadastro)
	cNUMFIC   := TM0->TM0_NUMFIC
	Dbselectarea("TM0")
	Dbsetorder(1)

	cAlias    := "TMN"

	#IFNDEF WINDOWS
		// Recupera o desenho padrao de atualizacoes
		ScreenDraw("SMT050", 3, 0, 0, 0)

		// Display de dados especificos deste Programa
		SetColor("b/w,,,")
		@ 3, 1 Say cCadastro
	#ENDIF

	DbSelectArea("TMN")

	Set Filter to TMN_FILIAL  == xFILIAL('TMN') .And. TMN_NUMFIC == TM0->TM0_NUMFIC
	dbSelectArea("TMN")
	DbSeek(xFilial("TMN"))

	mBrowse( 6, 1,22,75,"TMN")

	DbSelectArea("TMN")
	Set Filter to

	dbSetOrder(1)
	DbSeek(xFilial("TMN"))

	aRotina   := aCLONE(oldROTINA)
	cCadastro := cCada
	aSMenu    := aClone(aSMenuOld)
	SetFunName("MDTA110")

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de Menu Funcional
@type static function
@author Rafael Diogo Richter
@since 11/01/2007
@return array, opções do menu com o seguinte layout:
				Parametros do array a Rotina:
				1. Nome a aparecer no cabecalho
				2. Nome da Rotina associada
				3. Reservado
				4. Tipo de Transação a ser efetuada:
					1 - Pesquisa e Posiciona em um Banco de Dados
					2 - Simplesmente Mostra os Campos
					3 - Inclui registros no Bancos de Dados
					4 - Altera o registro corrente
					5 - Remove o registro corrente do Banco de Dados
				5. Nivel de acesso
				6. Habilita Menu Funcional

/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local lSigaMdtPS	:=	SuperGetMv("MV_MDTPS",.F.,"N") == "S"
	Local aRotina := { { STR0004,"AxPesqui" , 0 , 1    }, ;  // "Pesquisar"
					   { STR0005,"VIPRG110" , 0 , 2    }, ;  // "Visualizar"
					   { STR0011,"INPRG110" , 0 , 3    }, ;  // "Incluir"
					   { STR0012,"ALPRG110" , 0 , 4    }, ;  // "Alterar"
					   { STR0013,"EXPRG110" , 0 , 5, 3 }  }  // "Excluir"

	If !lSigaMdtPs .And. SuperGetMv("MV_NG2AUDI",.F.,"2") == "1"
		aAdd( aRotina , { STR0031,"MDTA991('TMN',{'TMN_NUMFIC','TMN_USERGI'},{'"+TM0->TM0_NUMFIC+"',STOD('"+DTOS(TM0->TM0_DTIMPL)+"')})" , 0 , 3 } )//"Hist. Exc."
	EndIf

Return aRotina
