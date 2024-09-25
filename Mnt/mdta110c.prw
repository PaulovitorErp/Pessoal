#Include "mdta110.ch"
#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA110C
Programa De Doencas

@author  Inacio Luiz Kolling
@since   19/01/2000

@return  Lógico, Verdadeiro quando a fonção for executada normalmente
/*/
//-------------------------------------------------------------------
Function MDTA110C()

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

	If !IsInCallStack( "MDTA110" ) .And. !IsBlind()
		ShowHelpDlg( STR0035, ;          //"ATENÇÃO"
					{ STR0046 }, 1,;     //"Execução não permitida."
					{ STR0047, "" }, 1 ) //"Rotina somente pode ser executada pelo menu de Ocorrências Ficha (MDTA110)."
		Return .F.
	EndIf

	If FindFunction("MDTRESTRI") .And. !MDTRESTRI("MDTA155")
		Return .F.
	Endif
	//Verifica se o funcionario esta demitido
	If !SitFunFicha(TM0->TM0_NUMFIC,.F.,.T.,.T.)
		Return
	Endif

	If SuperGetMv("MV_NG2AUDI",.F.,"2") == "1"
		aAdd(aSMenu,{ STR0030 , "MDTRELHIS('TNA')" })//"Histórico do Registro"
	EndIf

	oldROTINA := aCLONE(aROTINA)

	Private aRotina := MenuDef()

	// Define o cabecalho da tela de atualizacoes

	Private LENUMFIC  := .F.
	Private cCada     := cCadastro
	Private cCadastro := STR0008 //"Doencas"
	SetFunName("MDTA110C")
	cCadastro := OemtoAnsi(cCadastro)
	cAlias    := "TNA"

	cNUMFIC := TM0->TM0_NUMFIC
	M->TNA_NUMFIC := cNUMFIC
	M->TNA_NOMFIC := TM0->TM0_NOMFIC
	Dbselectarea("TM0")
	Dbsetorder(1)
	#IFNDEF WINDOWS
		// Recupera o desenho padrao de atualizacoes
		ScreenDraw("SMT050", 3, 0, 0, 0)

		// Display de dados especificos deste Programa
		SetColor("b/w,,,")
		@ 3, 1 Say cCadastro
	#ENDIF

	DbSelectArea("TNA")

	Set Filter to TNA_FILIAL  == xFILIAL('TNA') .And. TNA_NUMFIC == TM0->TM0_NUMFIC
	//DbSetOrder(nIndexP+1)
	dbSelectArea("TNA")
	DbSeek(xFilial("TNA"))

	mBrowse( 6, 1,22,75,"TNA")

	DbSelectArea("TNA")
	Set Filter to

	dbSetOrder(1)
	DbSeek(xFilial("TNA"))

	aRotina  := aCLONE(oldROTINA)
	cCadastro := cCada

	aSMenu := aClone(aSMenuOld)
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
	Local aRotina := { { STR0004,"AxPesqui" , 0 , 1    },; // "Pesquisar"
					   { STR0005,"VIDOE110" , 0 , 2    },; // "Visualizar"
					   { STR0011,"INDOE110" , 0 , 3    },; // "Incluir"
					   { STR0012,"ALDOE110" , 0 , 4    },; // "Alterar"
					   { STR0013,"EXDOE110" , 0 , 5, 3 } } // "Excluir"


	If !lSigaMdtPs .And. SuperGetMv("MV_NG2AUDI",.F.,"2") == "1"
		aAdd( aRotina , { STR0031,"MDTA991('TNA',{'TNA_NUMFIC','TNA_USERGI'},{'"+TM0->TM0_NUMFIC+"',STOD('"+DTOS(TM0->TM0_DTIMPL)+"')})" , 0 , 3 } )//"Hist. Exc."
	EndIf

Return aRotina