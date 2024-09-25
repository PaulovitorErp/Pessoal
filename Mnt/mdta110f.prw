#Include "mdta110.ch"
#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA110F
Atestados do Funcionario Selecionado

@author  Denis Hyroshi de Souza
@since   11/11/2004

@return  Lógico, Verdadeiro quando a fonção for executada normalmente
/*/
//-------------------------------------------------------------------
Function MDTA110F()

	Local aNGBEGINPRM := NGBEGINPRM(,"MDTA685")
	Local aAreaTTM0 := TM0->(GetArea())

	Private lENumFic := .F.
	Private cCadastro := OemtoAnsi(STR0023) // "Atestado Medico"
	Private sNOMFIC := TM0->TM0_NOMFIC
	Private sNUMFIC := TM0->TM0_NUMFIC
	Private aRelac := {{"TNY_NOMFIC","sNOMFIC"},;
				       {"TNY_NUMFIC","sNUMFIC"}}

	Private lInt_AfaGpe := SuperGetMv( "MV_NGMDTAF" , .F. , "N" ) == "S"
	Private nDiasFecha  := 0
	Private lInt_PonGpe := If( FindFunction( "MDT685VPON" ) , MDT685VPON( lInt_AfaGpe , @nDiasFecha ) , If( lInt_AfaGpe , .T. , .F. ) )
	Private lFicha := .F.
	Private nIndSR8 := f685RetOrder("SR8", "R8_FILIAL+R8_NATEST")
	Private lCpoSr8 := .F.
	Private lCpoIndSr8 := .F.
	Private aNgButton := {}
	Private aTROCAF3 := {}

	oldROTINA := aCLONE(aROTINA)
	Private cCadant := cCadastro
	Private aRotina := MenuDef()

	If !IsInCallStack( "MDTA110" ) .And. !IsBlind()
		ShowHelpDlg( STR0035, ;          //"ATENÇÃO"
					{ STR0046 }, 1,;     //"Execução não permitida."
					{ STR0047, "" }, 1 ) //"Rotina somente pode ser executada pelo menu de Ocorrências Ficha (MDTA110)."
		Return .F.
	EndIf

	If FindFunction("MDTRESTRI") .And. !MDTRESTRI("MDTA685")
		Return .F.
	EndIf

	// Verifica se o funcionario esta demitido
	If !SitFunFicha( TM0->TM0_NUMFIC, .F., .T., .T. )
		NGRETURNPRM(aNGBEGINPRM)
		Return Nil
	EndIf

	SetFunName("MDTA110F")
	aCbrowold := acbrowse

	If ExistBlock("MDTPERMISS")
		acbrowse :=  ExecBlock("MDTPERMISS",.F.,.F.)
	EndIf

	If SR8->(FieldPos("R8_NATEST")) > 0
		lCpoSr8 := .T.

		If nIndSR8 > 0
			lCpoIndSr8 := .T.
		EndIf

	EndIf

	If !FindFunction( "MDT685VPON" )

		If Alltrim(GETMV("MV_NGMDTAF")) == "S"
			lInt_PonGpe := .T.
		EndIf

		Var_Aux := SuperGetMv("MV_NG2DFP",.F.,0)
		nDiasFecha := If(ValType(Var_Aux)=="C",Val(Var_Aux),Var_Aux)

	EndIf

	aAdd(aNgButton, { "BMPCONS", {||MdtPesqCid()}, STR0018 + "C.I.D.", "C.I.D." } ) // "Pesquisar"
	aAdd(aTROCAF3, { "TNY_CID", "TMR" } )

	Dbselectarea("TM0")
	Dbsetorder(1)

	If lSigaMdtPS
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1")+TM0->TM0_CLIENT+TM0->TM0_LOJA)
		Private cCliMdtPs := SA1->A1_COD+SA1->A1_LOJA
	EndIf

	dbSelectArea("TNY")
	dbSetOrder(1)
	Set Filter to TNY->TNY_FILIAL == xFilial("TNY") .And. TNY->TNY_NUMFIC == sNUMFIC
	mBrowse(6,1,22,75,"TNY")

	dbSelectArea("TNY")
	dbSetOrder(1)

	RestArea(aAreaTTM0)
	aRelac := NIL
	aROTINA   := aCLONE(oldROTINA)
	cCadastro := cCadant
	acbrowse  := acbrowold

	NGRETURNPRM(aNGBEGINPRM)
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
	Local aRotina := { { STR0004, "AxPesqui"      , 0 , 1    },; // "Pesquisar"
					   { STR0005, "MDT110ATES(1)" , 0 , 2    },; // "Visualizar"
					   { STR0011, "MDT110ATES(3)" , 0 , 3    },; // "Incluir"
					   { STR0012, "MDT110ATES(4)" , 0 , 4    },; // "Alterar"
					   { STR0013, "MDT110ATES(5)" , 0 , 5, 3 },; // "Excluir"
					   { STR0022, "MDT685IMP"     , 0 , 2    } } // "Imprimir"

	If !lSigaMdtPs .And. SuperGetMv("MV_NG2AUDI",.F.,"2") == "1"
		aAdd( aRotina , { STR0031,"MDTA991('TNY')" , 0 , 3 } ) // "Hist. Exc."
	EndIf
Return aRotina
