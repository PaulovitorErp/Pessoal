#INCLUDE "Mdta675.ch"
#Include "Protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MDTA675  ³ Autor ³ Thiago Olis Machado   ³ Data ³ 03/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Cadastro do Plano de Acao por Acidente         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDTA675

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Armazena variaveis p/ devolucao (NGRIGHTCLICK) 							  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aNGBEGINPRM := NGBEGINPRM( )

	aVARNAO := {}
	aGETNAO := { { "TNZ_ACIDEN" , "M->TNC_ACIDEN" }}
	cGETWHILE := "TNZ->TNZ_FILIAL == xFilial('TNZ') .AND. M->TNC_ACIDEN == TNZ->TNZ_ACIDEN"
	cGETMAKE  := "TNC->TNC_ACIDEN"
	cGETKEY   := "TNC->TNC_ACIDEN + M->TNZ_CAUSA"
	cGETALIAS := "TNZ"
	cTUDOOK   := " MDT675LIN()"
	cLINOK    := "MDT675LIN() .AND. PutFileInEof('TNZ')"
	aRELAC    := { { "TNC_NUMFIC" , "MDT640FIC()" }}

	lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )

	PRIVATE aRotina := MenuDef()
	PRIVATE cCadastro
	Private cCliMdtPs := Space(Len(SA1->A1_COD+SA1->A1_LOJA))

	//Obriga a rodar upadate para unificação do plano de ação
	//passando a utilizar a tabela TAA ao invés da TNI.
	If !NGCADICBASE("TAA_UNIMED","A","TAA",.F.)
		If lSigaMdtPS
			If !NGINCOMPDIC("UPDMDTPS","XXXX",.F.)
				Return .F.
			EndIf
		Else
			If !NGINCOMPDIC("UPDMDT90","TIHZW3",.F.)
				Return .F.
			EndIf
		EndIf
	EndIf

	If lSigaMdtps
		cCadastro := OemtoAnsi(STR0015)  //"Clientes"

		DbSelectArea("SA1")
		DbSetOrder(1)

		mBrowse( 6, 1,22,75,"SA1")
	Else

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define o cabecalho da tela de atualizacoes                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Private aCHKDEL := {}, bNGGRAVA
		Private aCHOICE := {}
		Private nFunc := 1
		Private cPrograma := "MDTA675"
		Private lFicha := .t.
		cCadastro := OemtoAnsi(STR0007) //"Plano de Acao X Acidente"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³aCHKDEL array que verifica a INTEGRIDADE REFERENCIAL na exclu-³
		//³s„o do registro.                                              ³
		//³                                                              ³
		//³1 - Chave de pesquisa                                         ³
		//³2 - Alias de pesquisa                                         ³
		//³3 - ordem de pesquisa                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//aCHKDEL :={ {'TNS->TNS_MANDAT'    , "TNR", 1}}

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Endereca a funcaO de BRoWSE                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("TNC")
		DbSetorder(1)
		mBrowse( 6, 1,22,75,"TNC")

	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Devolve variaveis armazenadas (NGRIGHTCLICK) 							  	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	NGRETURNPRM( aNGBEGINPRM )

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MD675INV ³ Autor ³ Thiago Olis Machado   ³ Data ³ 03/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Cadastro de Investigacao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MD675INV()

	Local oldChoice := aClone(aChoice)

	Private aRotina := { { STR0001 , "AxPesqui"  , 0 , 1},; //"Pesquisar"
						{ STR0002 , "NGCAD01"   , 0 , 2},; //"Visualizar"
						{ STR0008 , "NGCAD01"   , 0 , 3},; //"Incluir"
						{ STR0013 , "NGCAD01"   , 0 , 4},; //"Alterar"
						{ STR0010 , "NGCAD01"   , 0 , 5, 3}}  //"Excluir"

	Private cCadastro := OemtoAnsi(STR0003) //"Investigacao"
	Private aCHKDEL := {}, bNGGRAVA

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³aCHKDEL array que verifica a INTEGRIDADE REFERENCIAL na exclu-³
	//³s„o do registro.                                              ³
	//³                                                              ³
	//³1 - Chave de pesquisa                                         ³
	//³2 - Alias de pesquisa                                         ³
	//³3 - ordem de pesquisa                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//aCHKDEL :={ {'TNS->TNS_MANDAT'    , "TNR", 1}}

	aChoice := {}

	aChoice := NGCAMPNSX3("TNU")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcaO de BRoWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbSelectArea("TNU")
	If lSigaMdtPS
		Set Filter To cCliMdtps+TNC->TNC_ACIDEN == TNU->TNU_CLIENT+TNU->TNU_LOJA+TNU->TNU_ACIDEN
	Else
		Set Filter To TNC->TNC_ACIDEN == TNU->TNU_ACIDEN
	Endif
	dbSetOrder(1)

	mBrowse( 6, 1,22,75,"TNU")
	Set Filter To
	aChoice := oldChoice

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MD675ATO ³ Autor ³ Thiago Olis Machado   ³ Data ³ 03/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Cadastro de Atos Inseguros                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MD675ATO()

	Local oldChoice := aClone(aChoice)

	Private aRotina := { { STR0001 , "AxPesqui"  , 0 , 1},; //"Pesquisar"
						{ STR0002 , "NGCAD01"   , 0 , 2},; //"Visualizar"
						{ STR0008 , "NGAUTINC"  , 0 , 3},; //"Incluir"
						{ STR0010 , "EX675ATO"  , 0 , 4, 3}}  //"Excluir"

	Private cCadastro := OemtoAnsi(STR0004) //"Ato Inseguro"
	Private aCHKDEL := {}, bNGGRAVA

	nFunc := 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³aCHKDEL array que verifica a INTEGRIDADE REFERENCIAL na exclu-³
	//³s„o do registro.                                              ³
	//³                                                              ³
	//³1 - Chave de pesquisa                                         ³
	//³2 - Alias de pesquisa                                         ³
	//³3 - ordem de pesquisa                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//aCHKDEL :={ {'TNS->TNS_MANDAT'    , "TNR", 1}}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcaO de BRoWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aChoice := {}

	aChoice := NGCAMPNSX3("TNZ")

	dbSelectArea("TNZ")

	If lSigaMdtps
		Set Filter To TNZ->TNZ_INDCAU == "1" .AND. TNC->TNC_ACIDEN == TNZ->TNZ_ACIDEN .AND. TNZ->(TNZ_CLIENT+TNZ_LOJA) == cCliMdtps
		dbSetOrder(3)  //TNZ_FILIAL+TNZ_CLIENT+TNZ_LOJA+TNZ_ACIDEN+TNZ_CAUSA
	Else
		Set Filter To TNZ->TNZ_INDCAU == "1" .AND. TNC->TNC_ACIDEN == TNZ->TNZ_ACIDEN
		dbSetOrder(1)  //TNZ_FILIAL+TNZ_ACIDEN+TNZ_CAUSA
	Endif

	mBrowse( 6, 1,22,75,"TNZ")
	Set Filter To

	aChoice := oldChoice

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGAUTINC ³ Autor ³ Anonimo               ³ Data ³ ??/??/?? ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclui um novo ato inseguro                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGAUTINC()

	bNGGRAVA := {||NGCHKCAU()}
	M->TNC_ACIDEN := TNC->TNC_ACIDEN

	aRelac := {{"TNZ_ACIDEN","M->TNC_ACIDEN"}}
	If lSigaMdtps
		AADD := ( aRelac, {"TNZ_CLIENT", "SA1->A1_COD"} )
		AADD := ( aRelac, {"TNZ_LOJA"  , "SA1->A1_LOJA"} )
	Endif

	lRet := NGCAD01("TNZ",Recno(),3)

	If lRet == 1
	RecLock("TNZ",.f.)
	TNZ->TNZ_INDCAU := "1"
	MsUnlock("TNZ")

	EndIF

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MD675CON ³ Autor ³ Thiago Olis Machado   ³ Data ³ 03/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Cadastro de Condicoes Inseguras                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MD675CON()

	Local oldChoice := aClone(aChoice)

	Private aRotina := { { STR0001 , "AxPesqui"  , 0 , 1},; //"Pesquisar"
						{ STR0002 , "NGCAD01"   , 0 , 2},; //"Visualizar"
						{ STR0008 , "NGCONINC"  , 0 , 3},; //"Incluir"
						{ STR0010 , "EX675CON"  , 0 , 4, 3}}  //"Excluir"

	Private cCadastro := OemtoAnsi(STR0011) //"Condicao Insegura"
	Private aCHKDEL := {}, bNGGRAVA

	nFunc := 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³aCHKDEL array que verifica a INTEGRIDADE REFERENCIAL na exclu-³
	//³s„o do registro.                                              ³
	//³                                                              ³
	//³1 - Chave de pesquisa                                         ³
	//³2 - Alias de pesquisa                                         ³
	//³3 - ordem de pesquisa                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//aCHKDEL :={ {'TNS->TNS_MANDAT'    , "TNR", 1}}

	aChoice := {}

	aChoice := NGCAMPNSX3("TNZ")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BRoWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("TNZ")

	If lSigaMdtps
		Set Filter To TNZ->TNZ_INDCAU == "2" .AND. TNC->TNC_ACIDEN == TNZ->TNZ_ACIDEN .AND. TNZ->(TNZ_CLIENT+TNZ_LOJA) == cCliMdtps
		dbSetOrder(3)  //TNZ_FILIAL+TNZ_CLIENT+TNZ_LOJA+TNZ_ACIDEN+TNZ_CAUSA
	Else
		Set Filter To TNZ->TNZ_INDCAU == "2"  .AND. TNC->TNC_ACIDEN == TNZ->TNZ_ACIDEN
		dbSetOrder(1)  //TNZ_FILIAL+TNZ_ACIDEN+TNZ_CAUSA
	Endif

	mBrowse( 6, 1,22,75,"TNZ")
	Set Filter To
	aChoice := oldChoice
	nFunc := 1

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGCONINC ³ Autor ³ Anonimo               ³ Data ³ ?        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclui uma nova condicao insegura                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGCONINC()

	bNGGRAVA := {||NGCHKCAU()}
	M->TNC_ACIDEN := TNC->TNC_ACIDEN

	aRelac := {{"TNZ_ACIDEN","M->TNC_ACIDEN"}}
	If lSigaMdtps
		AADD( aRelac, {"TNZ_CLIENT","SA1->A1_COD"} )
		AADD( aRelac, {"TNZ_LOJA"  ,"SA1->A1_LOJA"} )
	Endif

	lRet := NGCAD01("TNZ",Recno(),3)

	If lRet == 1
		RecLock("TNZ",.f.)
		TNZ->TNZ_INDCAU := "2"
		MsUnlock("TNZ")
	EndIF

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MD675PLA ³ Autor ³ Thiago Olis Machado   ³ Data ³ 03/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Cadastro do Plano de Acao por Acidente         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MD675PLA()

	Local oldChoice := aClone(aChoice)

	Private aRotina := { { STR0001 , "AxPesqui"  , 0 , 1},; //"Pesquisar"
						{ STR0002 , "NGCAD01"   , 0 , 2},; //"Visualizar"
						{ STR0008 , "NGCAD01"   , 0 , 3},; //"Incluir"
						{ STR0010 , "EX675PLA"  , 0 , 4, 3}}  //"Excluir"

	Private cCadastro := OemtoAnsi(STR0012) //"Plano de Acao por Acidente"
	Private aCHKDEL := {}, bNGGRAVA := {|| CHKPLA675()}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³aCHKDEL array que verifica a INTEGRIDADE REFERENCIAL na exclu-³
	//³s„o do registro.                                              ³
	//³                                                              ³
	//³1 - Chave de pesquisa                                         ³
	//³2 - Alias de pesquisa                                         ³
	//³3 - ordem de pesquisa                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//aCHKDEL :={ {'TNS->TNS_MANDAT'    , "TNR", 1}}

	aChoice := {}

	aChoice := NGCAMPNSX3("TNZ")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BRoWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbSelectArea("TNT")

	If lSigaMdtps
		Set Filter To TNT->TNT_ACIDEN == TNC->TNC_ACIDEN .AND. TNT->(TNT_CLIENT+TNT_LOJA) == cCliMdtps
	Else
		Set Filter To TNT->TNT_ACIDEN == TNC->TNC_ACIDEN
	Endif
	dbSetOrder(1)

	mBrowse( 6, 1,22,75,"TNT")
	Set Filter To

	aChoice := oldChoice

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ INCPLA675 ³ Autor ³ Anonimo              ³ Data ³ ?        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclui uma nova providencia p/ acidente CIPA               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function INCPLA675()

	Local cAlias := Alias()
	Local cOrder := Indexord()
	Local cRecno := Recno()
	Local oldChoice := aClone(aChoice)

	RollBackSX8()

	aChoice := {}

	aChoice := NGCAMPNSX3("TNT")

	lRET  := NGCAD01("TNT",recno(),3)

	Dbselectarea(cAlias)
	Dbsetorder(cOrder)
	Dbgoto(cRecno)
	aChoice := oldChoice

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGINDCAU ³ Autor ³ Anonimo               ³ Data ³ ?        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o campo TND_INDCAU                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGINDCAU()

	If nFunc = 1 .and. TND->TND_INDCAU = "1"
	Return .t.
	ElseIf nFunc = 2 .and. TND->TND_INDCAU = "2"
	Return .t.
	EndIf

Return .f.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGCHKCAU ³ Autor ³ Anonimo               ³ Data ³ ?        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o campo TND_INDCAU                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGCHKCAU()

	If nFunc = 1 .and. TND->TND_INDCAU = "1"
	Return .t.
	ElseIf nFunc = 1 .AND. TND->TND_INDCAU = "2"
	Help(" ",1,"NAOATO")
	Return .f.
	EndIf

	If nFunc = 2 .and. TND->TND_INDCAU = "2"
	Return .t.
	ElseIf nFunc = 2 .AND. TND->TND_INDCAU = "1"
	Help(" ",1,"NAOCAUSA")
	Return .f.
	EndIf

Return .f.

//FUNCOES DE EXCLUSAO

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³EX675INV  ³ Autor ³Denis Hyroshi de Souza ³ Data ³ 20/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclui Registro                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function EX675INV(cAli, nRecno, nOpcx)

	Local aOLD := aCLONE(aROTINA)

	PRIVATE aRotina := { { STR0001, "AxPesqui"  , 0 , 1},; //"Pesquisar"
						{ STR0002, "AxPesqui"  , 0 , 1},; //"Visualizar"
						{ STR0003, "AxPesqui"  , 0 , 1},; //"Incluir"
						{ STR0013, "AxPesqui"  , 0 , 1},; //"Alterar"
						{ STR0005, "AxPesqui"  , 0 , 1}}  //"Excluir"

	PRIVATE aTELA[0][0],aGETS[0],aHeader[0],nUsado:=0
	nOpc := 5

	DbSelectArea("TNU")
	DbSetOrder(1)

	//M->TNX_NUMRIS := TNX->TNX_NUMRIS
	lRET  := NGCAD01("TNU",recno(),5)

	aROTINA := aCLONE(aOLD)

	lRefresh := .T.

	DbSelectArea("TNU")
	DbGoTop()

Return NIL
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³EX675ATO  ³ Autor ³Denis Hyroshi de Souza ³ Data ³ 20/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclui Registro                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function EX675ATO(cAli, nRecno, nOpcx)

	Local aOLD := aCLONE(aROTINA)

	PRIVATE aRotina := { { STR0001, "AxPesqui"  , 0 , 1},; //"Pesquisar"
						{ STR0002, "AxPesqui"  , 0 , 1},; //"Visualizar"
						{ STR0003, "AxPesqui"  , 0 , 1},; //"Incluir"
						{ STR0013, "AxPesqui"  , 0 , 1},; //"Alterar"
						{ STR0005, "AxPesqui"  , 0 , 1}}  //"Excluir"

	PRIVATE aTELA[0][0],aGETS[0],aHeader[0],nUsado:=0
	nOpc := 5


	DbSelectArea("TNZ")
	If lSigaMdtps
		DbSetOrder(3) //TNZ_FILIAL+TNZ_CLIENT+TNZ_LOJA+TNZ_ACIDEN+TNZ_CAUSA
	Else
		DbSetOrder(1) //TNZ_FILIAL+TNZ_ACIDEN+TNZ_CAUSA
	Endif

	//M->TNX_NUMRIS := TNX->TNX_NUMRIS
	lRET  := NGCAD01("TNZ",recno(),5)

	aROTINA := aCLONE(aOLD)

	lRefresh := .T.

	DbSelectArea("TNZ")
	DbGoTop()

Return NIL
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³EX675CON  ³ Autor ³Denis Hyroshi de Souza ³ Data ³ 20/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclui Registro                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function EX675CON(cAli, nRecno, nOpcx)

	Local aOLD := aCLONE(aROTINA)

	PRIVATE aRotina := { { STR0001, "AxPesqui"  , 0 , 1},; //"Pesquisar"
						{ STR0002, "AxPesqui"  , 0 , 1},; //"Visualizar"
						{ STR0003, "AxPesqui"  , 0 , 1},; //"Incluir"
						{ STR0013, "AxPesqui"  , 0 , 1},; //"Alterar"
						{ STR0005, "AxPesqui"  , 0 , 1} } //"Excluir"

	PRIVATE aTELA[0][0],aGETS[0],aHeader[0],nUsado:=0
	nOpc := 5


	DbSelectArea("TNZ")
	If lSigaMdtps
		DbSetOrder(3) //TNZ_FILIAL+TNZ_CLIENT+TNZ_LOJA+TNZ_ACIDEN+TNZ_CAUSA
	Else
		DbSetOrder(1) //TNZ_FILIAL+TNZ_ACIDEN+TNZ_CAUSA
	Endif

	//M->TNX_NUMRIS := TNX->TNX_NUMRIS
	lRET  := NGCAD01("TNZ",recno(),5)

	aROTINA := aCLONE(aOLD)

	lRefresh := .T.

	DbSelectArea("TNZ")
	DbGoTop()

Return NIL
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³EX675PLA  ³ Autor ³Denis Hyroshi de Souza ³ Data ³ 20/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclui Registro                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function EX675PLA(cAli, nRecno, nOpcx)

	Local aOLD := aCLONE(aROTINA)
	Local bOldGra := bNgGrava

	PRIVATE aRotina := { { STR0001, "AxPesqui"  , 0 , 1},; //"Pesquisar"
						{ STR0002, "AxPesqui"  , 0 , 1},; //"Visualizar"
						{ STR0003, "AxPesqui"  , 0 , 1},; //"Incluir"
						{ STR0013, "AxPesqui"  , 0 , 1},; //
						{ STR0005, "AxPesqui"  , 0 , 1}}  //"Excluir"

	PRIVATE aTELA[0][0],aGETS[0],aHeader[0],nUsado:=0
	nOpc := 5


	DbSelectArea("TNT")
	DbSetOrder(1)
	bNgGrava := NIL
	//M->TNX_NUMRIS := TNX->TNX_NUMRIS
	lRET  := NGCAD01("TNT",recno(),5)

	aROTINA := aCLONE(aOLD)
	bNgGrava := bOldGra
	lRefresh := .T.

	DbSelectArea("TNT")
	DbGoTop()

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MenuDef  ³ Autor ³ Rafael Diogo Richter  ³ Data ³29/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Utilizacao de Menu Funcional.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaMDT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados         ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ F.O  ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

	Local lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )
	Local aRotina

	If lSigaMdtps
		aRotina := { { STR0001,   "AxPesqui"  , 0 , 1},; //"Pesquisar"
					{ STR0002,   "NGCAD01"   , 0 , 2},; //"Visualizar"
					{ STR0016,   "MDT675TNC" , 0 , 4} } //"Acidentes"
	Else
		aRotina :=	{ { STR0001 ,	"AxPesqui"   , 0 , 1},; //"Pesquisar"
					{ STR0002 ,	"NGCAD01"    , 0 , 2},; //"Visualizar"
					{ STR0003 ,	"MD675INV"   , 0 , 4},;//"Investigacao"
					{ STR0004 ,	"NGCAD02"   , 0 , 4},; //"Ato Inseguro"
					{ STR0005 ,	"MD675CON"   , 0 , 4},; //"Cond. Inseg."
					{ STR0006 ,	"MD675PLA"   , 0 , 4}} //"Plano Acao."
	Endif

Return aRotina
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MDT675TNC ³ Autor ³Andre Perez Alvarez    ³ Data ³ 23/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta um browse com os acidentes.                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDT675TNC()

	Local aArea	:= GetArea()
	Local oldROTINA := aCLONE(aROTINA)
	Local oldCad := cCadastro

	cCliMdtPs := SA1->A1_COD+SA1->A1_LOJA

	aRotina :=	{ { STR0001 ,	"AxPesqui"   , 0 , 1},; //"Pesquisar"
				{ STR0002 ,	"NGCAD01"    , 0 , 2},; //"Visualizar"
				{ STR0003 ,	"MD675INV"   , 0 , 4},; //"Investigacao"
				{ STR0004 ,	"MD675ATO"   , 0 , 4},; //"Ato Inseguro"
				{ STR0005 ,	"MD675CON"   , 0 , 4},; //"Cond. Inseg."
				{ STR0006 ,	"MD675PLA"   , 0 , 4}}  //"Plano Acao"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define o cabecalho da tela de atualizacoes                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private cCadastro := OemtoAnsi(STR0007) //"Plano de Acao X Acidente"
	Private aCHKDEL := {}, bNGGRAVA
	Private nFunc := 1
	Private cPrograma := "MDTA675"
	Private lFicha := .t.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³aCHKDEL array que verifica a INTEGRIDADE REFERENCIAL na exclu-³
	//³s„o do registro.                                              ³
	//³                                                              ³
	//³1 - Chave de pesquisa                                         ³
	//³2 - Alias de pesquisa                                         ³
	//³3 - ordem de pesquisa                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//aCHKDEL :={ {'TNS->TNS_MANDAT'    , "TNR", 1}}

	aCHOICE := {}

	aChoice := NGCAMPNSX3("TNC")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcaO de BRoWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("TNC")
	Set Filter To TNC->(TNC_CLIENT+TNC_LOJA) == cCliMdtps
	DbSetorder(1)  //TNC_FILIAL+TNC_CLIENT+TNC_LOJA+TNC_ACIDEN
	mBrowse( 6, 1,22,75,"TNC")

	DbSelectArea("TNC")
	Set Filter To

	aROTINA := aCLONE(oldROTINA)
	RestArea(aArea)
	cCadastro := oldCad

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MDT675VCIP³ Autor ³ Denis                 ³ Data ³ 25/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo TNT_MANDAT, TNT_CODPLA, TNZ_CAUSA, TNU_MANDAT ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDT675VCIP(nTipoVld)

	Local lPrest := .F.

	SG90PLACAO()//Adequação do Plano de Ação.

	If Type("cCliMdtPs") == "C"
		If !Empty(cCliMdtPs)
			lPrest := .T.
		Endif
	Endif

	If nTipoVld == 1 //Valida TNT_MANDAT
		If lPrest
			Return (EXISTCPO("TNN",M->TNT_CLIENT+M->TNT_LOJA+M->TNT_MANDAT,3))
		Else
			Return (EXISTCPO("TNN",M->TNT_MANDAT,1))
		Endif
	ElseIf nTipoVld == 2 //Valida TNT_CODPLA
		lRetPA := .T.
		If lPrest
			lRetPA := (EXISTCPO(cAliasPA,cCliMdtps+M->TNT_CODPLA,5) .AND. EXISTCHAV("TNT",cCliMdtps+M->TNT_ACIDEN+M->TNT_MANDAT+M->TNT_CODPLA,4))
		Else
			lRetPA := (EXISTCPO(cAliasPA,M->TNT_CODPLA,1) .AND. EXISTCHAV("TNT",M->TNT_ACIDEN+M->TNT_MANDAT+M->TNT_CODPLA,1))
		Endif
		If lRetPA .And. NGCADICBASE(aFieldPA[29],"A",cAliasPA,.F.)
			dbSelectArea(cAliasPA)
			dbSetOrder(If(lPrest,5,1))
			dbSeek(xFilial(cAliasPA)+If(lPrest,cCliMdtps,"")+M->TNT_CODPLA)
			If !((cAliasPA)->&(aFieldPA[29]) $ "1/3")
				lRetPA := .F.
				Help( ' ', 1, STR0017, , STR0022, 2, 0, , , , , , { STR0023 } )
			Endif
		Endif
		Return lRetPA
	ElseIf nTipoVld == 3 //Valida TNU_MANDAT
		If lPrest
			Return (EXISTCPO("TNN",cCliMdtps+M->TNU_MANDAT,3) .AND. EXISTCHAV("TNU",cCliMdtps+M->TNU_ACIDEN+M->TNU_MANDAT,2))
		Else
			Return (EXISTCPO("TNN",M->TNU_MANDAT,1) .AND. EXISTCHAV("TNU",M->TNU_ACIDEN+M->TNU_MANDAT,1))
		Endif
	ElseIf nTipoVld == 4 //Valida TNZ_CAUSA
		If lPrest
			Return (EXISTCPO("TND",cCliMdtps+M->TNZ_CAUSA,3) .AND. EXISTCHAV("TNZ",cCliMdtps+M->TNZ_ACIDEN+M->TNZ_CAUSA,3))
		Else
			Return (EXISTCPO("TND",M->TNZ_CAUSA,1).AND.EXISTCHAV("TNZ",M->TNZ_ACIDEN+M->TNZ_CAUSA,1))
		Endif
	Endif

Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MDT675INI1³ Autor ³ Denis                 ³ Data ³ 25/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inicializador do TNT_NOMPLA e TNZ_NOME                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDT675INI1(cTabVld,nTipoVld)

	Local lPrest := .F.

	SG90PLACAO()//Adequação do Plano de Ação.

	If Type("cCliMdtPs") == "C"
		If !Empty(cCliMdtPs)
			lPrest := .T.
		Endif
	Endif

	If cTabVld == cAliasPA
		If nTipoVld == 1 //Relacao
			If lPrest
				Return Posicione(cAliasPA,5,xFilial(cAliasPA)+cCliMdtps+TNT->TNT_CODPLA,aFieldPA[3])
			Else
				Return Posicione(cAliasPA,1,xFilial(cAliasPA)+TNT->TNT_CODPLA,aFieldPA[3])
			Endif
		Else			 //Browse
			If lPrest
				Return Posicione(cAliasPA,5,xFilial(cAliasPA)+cCliMdtps+TNT->TNT_CODPLA,aFieldPA[3])
			Else
				Return Posicione(cAliasPA,1,xFilial(cAliasPA)+TNT->TNT_CODPLA,aFieldPA[3])
			Endif
		Endif
	ElseIf cTabVld == "TND"
		If nTipoVld == 1 //Relacao
			If lPrest
				Return Posicione("TND",3,xFilial("TND")+cCliMdtps+M->TNZ_CAUSA,"TND_NOME")
			Else
				Return Posicione("TND",1,xFilial("TND")+M->TNZ_CAUSA,"TND_NOME")
			Endif
		Else			 //Browse
			If lPrest
				Return Posicione("TND",3,xFilial("TND")+cCliMdtps+TNZ->TNZ_CAUSA,"TND_NOME")
			Else
				Return Posicione("TND",1,xFilial("TND")+TNZ->TNZ_CAUSA,"TND_NOME")
			Endif
		Endif
	Endif

Return Space(20)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CHKPLA675 ³ Autor ³ Jackson Machado       ³ Data ³ 02/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validação na inclusão do plano de ação                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CHKPLA675()

	dbSelectArea("TNT")
	dbSetOrder(1)
	If dbSeek(xFilial("TNT")+M->TNT_ACIDEN+M->TNT_MANDAT+M->TNT_CODPLA)
		Help("",1,"JAGRAVADO")
		Return .F.
	Endif

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT675ACID
Retorna a descrição do acidente.
Uso Genérico

@return
@param 	cCodAcid - Recebe o codigo do acidente.

@author Rodrigo Soledade
@since 24/10/2013
/*/
//---------------------------------------------------------------------
Function MDT675ACID(cCodAcid)

	Local cDesCid := Space(40)
	Default cCodAcid := Space(6)

	If !Empty(cCodAcid)
		cDesCid := NGSEEK("TNC",cCodAcid,1,"TNC->TNC_DESACI")
	EndIf

Return cDesCid

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT675LIN
Funcção para verificar a linha GetDados

@author Guilherme Freudenburg
@since 11/03/2014
/*/
//---------------------------------------------------------------------
Function MDT675LIN()

	Local nx:=0
	Local lRet:=.T.
	Local nCOD

	nCOD    := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TNZ_CAUSA"})

	IF !Empty(aCols)
		For nx:=1 To Len(aCols)
			If n <> nx
				If aCols[nx,nCOD] == aCols[n,nCOD] .AND. ( !aCols[nx,Len(aCols[nx])] .AND. !aCols[n,Len(aCols[n])] )
					ShowHelpDlg(STR0017,{STR0018},2,{STR0019},2)//ATENÇÃO ## "Já existe uma Causa com este código." ## "Favor informar um outro código."
					lRet:=.F.
				Endif
			Endif
		Next nx
	Endif
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT675VAL
Função para alterar validção do campo TNZ_CAUSA

@author Guilherme Freudenburg
@since 11/03/2014
/*/
//---------------------------------------------------------------------
Function MDT675VAL()

Return EXISTCPO("TND",M->TNZ_CAUSA).AND.EXISTCHAV("TNZ",TNC->TNC_ACIDEN+M->TNZ_CAUSA).AND.NGCHKCAU()
