#Include "mdta110.ch"
#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA110B
Programa De Restricoes

@author  Inacio Luiz Kolling
@since   19/01/2000

@return  Lógico, Verdadeiro quando a fonção for executada normalmente
/*/
//-------------------------------------------------------------------
Function MDTA110B()

	// Guarda conteudo e declara variaveis padroes
	Local aNGBEGINPRM := If(!IsInCallStack("MDTA110"), NGBEGINPRM("MDTA110"), {})
	Local aSMenuOld := aClone(aSMenu)

	If !(IsInCallStack( "MDTA200" ) .Or. IsInCallStack( "MDTA110" )) .And. !IsBlind()
		ShowHelpDlg( STR0035, ;          //"ATENÇÃO"
					{ STR0046 }, 1,;     //"Execução não permitida."
					{ STR0048, "" }, 1 ) //"A execução dessa rotina somente pode ser executada pelo menu de Ocorrências Ficha (MDTA110)
										 //ou pelo menu Programa de geracao de ASO (MDTA200)."
		Return .F.
	EndIf

	If FindFunction("MDTRESTRI") .And. !MDTRESTRI("MDTA050")
		Return .F.
	EndIf

	//Verifica se o funcionario esta demitido
	If !SitFunFicha(TM0->TM0_NUMFIC,.F.,.T.,.T.)
		Return
	EndIf

	If SuperGetMv("MV_NG2AUDI",.F.,"2") == "1"
		aAdd(aSMenu,{ STR0030 , "MDTRELHIS('TMF')" })//"Histórico do Registro"
	EndIf

	oldROTINA := aCLONE(aROTINA)
	Private aRotina := MenuDef()

	Private LENUMFIC  := .F.
	Private cCada     := cCadastro
	Private cCadastro := STR0007 //"Restricoes"

	SetFunName("MDTA110B")
	cCadastro := OemtoAnsi(cCadastro)

	cAlias    := "TMF"

	cNUMFIC := TM0->TM0_NUMFIC
	cNomfic := TM0->TM0_NOMFIC
	aRelac := {{"TMF_NOMFIC","cNomFic"},;
				{"TMF_NUMFIC","cNumfic"}}

	Dbselectarea("TM0")
	Dbsetorder(1)

	DbSelectArea("TMF")
	//Condição deverá ser em SQL
	//Realiza o filtro no Funcionário selecionado para trazer somente as consultas dele.
	cFilBrwTMF := "TMF_FILIAL = " + ValToSQL( xFilial( 'TMF' ) ) + " AND TMF_NUMFIC = " +  ValToSQL( TM0->TM0_NUMFIC )

	DbSeek(xFilial("TMF"))
	dbSetOrder(1)
	mBrowse( 6 , 1 , 22 , 75 , "TMF" , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , cFilBrwTMF )

	DbSelectArea("TMF")
	dbSetOrder(1)
	If DbSeek( xFilial("TMF") + TMF->TMF_NUMFIC + TMF->TMF_RESTRI )
	
		oView := FWViewActive()
		oModel:= FWModelActive()
		oModel:lModify:= .T.
		oModel:lValid := .F.
		oView:ApplyModifyToViewByModel(oModel)

	EndIf

	aRotina   := aCLONE(oldROTINA)
	cCadastro := cCada

	// Retorna conteudo de variaveis padroes
	NGRETURNPRM(aNGBEGINPRM)
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
	Local aRotina := { {  STR0004,"AxPesqui" , 0 , 1    }, ; // "Pesquisar"
					   {  STR0005,"VIRES110" , 0 , 2    }, ; // "Visualizar"
					   {  STR0011,"INRES110" , 0 , 3    }, ; // "Incluir"
					   {  STR0012,"ALRES110" , 0 , 4    }, ; // "Alterar"
					   {  STR0013,"EXRES110" , 0 , 5, 3 }  } // "Excluir"

	If !lSigaMdtPs .And. SuperGetMv("MV_NG2AUDI",.F.,"2") == "1"
		aAdd( aRotina , {  STR0031,"MDTA991('TMF',{'TMF_NUMFIC','TMF_USERGI'},{'"+TM0->TM0_NUMFIC+"',STOD('"+DTOS(TM0->TM0_DTIMPL)+"')})" , 0 , 3 } )//"Hist. Exc."
	EndIf

Return aRotina
