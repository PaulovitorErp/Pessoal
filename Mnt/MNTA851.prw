#Include "MNTA851.ch"
#Include "RWMAKE.ch"
#Include "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH" // Integração via Mensagem Única

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA851
Implementação da rotina OAS1A003 (OAS) para o padrão SIGAMNT
Programa de cadastro Atividades por Turno de Trabalho

@author Vitor Emanuel Batista
@since 20/04/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Function MNTA851()

	Local lRet        := .T.
	Local aNGBEGINPRM := {}
	

	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 19, 95 )

		aNGBEGINPRM := NGBEGINPRM() // Guarda conteúdo e declara variáveis padrões

		Private aRotina := MenuDef()
		Private cCadastro  := STR0066 // "Cadastro de Parte Diária"
		Private cPrograma  := "MNTA851"

		Private aZEMPS     := {} // Variável obrigatória para as Perguntas De/Ate Empresa/Filial

		// Tabelas a serem abertas, já que o processo de correção de erros de importação de registros, trabalha como multi filial/empresa
		Private aPrepTbls  := { {"CTT"},{"SH7"},{"SRA"},{"ST9"},{"STP"},{"TPE"},{"TPP"},{"TV0"},{"TV1"},{"TV2"} }

		//Armazena Empresa e Filial Originais
		Private cOrigEmp := cEmpAnt
		Private cOrigFil := cFilAnt

		Private aIndSTJ   := ""
		Private cCondicao := ""

		MNT851PVAR()

		//---------------------------------------------
		// Endereça a funcao de Browse
		//---------------------------------------------

		DbSelectArea( "TV1" )
		DbSetOrder( 01 ) // TV1_FILIAL+TV1_EMPRES+TV1_CODBEM+DTOS( TV1_DTSERV )+TV1_TURNO+TV1_HRINI+TV1_HRFIM

		cCondicao := "TV1_INDERR = '2'" // Apenas registros OK

		MBrowse( 6,1,22,75,"TV1",,,,,,,,,,,,.T.,,cCondicao ) // O Browse deverá exibir todas as filiais

		//---------------------------------------
		// Retorna conteúdo de variáveis padrões
		//---------------------------------------
		NGRETURNPRM( aNGBEGINPRM )

	EndIf
	
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA851GR
Verifica se já existe.

@author Evaldo Cevinscki Jr.
@since 10/05/2010
@version P11
@return true or false, conforme validação
/*/
//---------------------------------------------------------------------
Static Function MNTA851GR( lLinOK,nOpc )

	Local lHlpVisual := !IsInCallStack("MNTI851")
	Local nX         := 0

	Local aColsUse   := If( IsInCallStack( "MNTI851" ),"aCols","oGet:aCols" )
	Local aHeaderUse := If( IsInCallStack( "MNTI851" ),"aHeader","oGet:aHeader" )

	Local aHelpVld   := {}
	Local aRetHlp    := {}

	Default lLinOK := .T.
	Default nOpc   := 0

	// Valida integridade referencial
	If nOpc == 5
		Return NGVALSX9( "TV1",{ "TV2" },.T. )
	EndIf

	nHRINI := GDFIELDPOS( "TV2_HRINI",&( aHeaderUse ) )
	nHRFIM := GDFIELDPOS( "TV2_HRFIM",&( aHeaderUse ) )

	// Valida todas as Atividades
	If lLinOK
		For nX := 1 To Len( &( aColsUse ) )
			n := nX
			If !aTail(&( aColsUse )[n]) //Apenas as nao deletadas
				If !Empty(aRetHlp := MNT851LIOK(.F.))
					aHelpVld := aClone(aRetHlp)
					Exit
				EndIf
			EndIf
		Next nX
	Endif

	n := 1 // Retorna o browse para o primeiro registro
	If Empty(aHelpVld)

		If Inclui
			dbSelectArea( "TV1" )
			dbSetOrder( 01 ) // TV1_FILIAL+TV1_EMPRES+TV1_CODBEM+DTOS( TV1_DTSERV )+TV1_TURNO+TV1_HRINI+TV1_HRFIM
			If dbSeek( xFilial( "TV1" ) + cEmpAnt + M->TV1_CODBEM + DTOS( M->TV1_DTSERV ) + M->TV1_TURNO + M->TV1_HRINI + M->TV1_HRFIM )

					aHelpVld := {"99", "Já existe registro com esta informação", "Troque a chave principal deste registro."} // "Já existe registro com esta informação" ## Troque a chave principal deste registro.

			ElseIf dbSeek( xFilial( "TV1" ) + cEmpAnt + M->TV1_CODBEM + DTOS( M->TV1_DTSERV ) + M->TV1_TURNO )

				While !EoF() .And. TV1->TV1_FILIAL == xFilial( "TV1" ) .And.;
					TV1->TV1_EMPRES == cEmpAnt .And. TV1->TV1_CODBEM == M->TV1_CODBEM .And. ;
					DTOS( TV1->TV1_DTSERV ) == DTOS( M->TV1_DTSERV ) .And. TV1->TV1_TURNO == M->TV1_TURNO

					If ( M->TV1_HRINI >= TV1->TV1_HRFIM .And. M->TV1_HRFIM >= M->TV1_HRINI ) .Or. ;
						( M->TV1_HRFIM <= TV1->TV1_HRINI .And. M->TV1_HRINI <= M->TV1_HRFIM )
						// Registro OK
						dbSelectArea( "TV1" )
						dbSkip()
						Loop
					EndIf

						aHelpVld := {"99",	STR0003,; // "Esta Parte Diária possui horários conflitantes com outra Parte Diária já gravada."
													STR0004,; // "Favor alterar o horário desta Parte Diária, ou cancelar a operação."
													STR0002 } // "Atenção"
						Exit

					dbSelectArea( "TV1" )
					dbSkip()

				End While

			EndIf

			If Empty(aHelpVld) .And. !Empty(aRetHlp := MNT851VLDT())
				aHelpVld := aClone(aRetHlp)
			EndIf

			If Empty(aHelpVld) .And. !Empty(aRetHlp := MNT851VLHR())
				aHelpVld := aClone(aRetHlp)
			Endif

			If Empty(aHelpVld) .And. !Empty(aRetHlp := MNTA851SB())
				aHelpVld := aClone(aRetHlp)
			Endif

			If Empty(aHelpVld) .And. !Empty(aRetHlp := MNTA851CON(1))
				aHelpVld := aClone(aRetHlp)
			Endif

			If Empty(aHelpVld) .And. !Empty(aRetHlp := MNTA851CON(2))
				aHelpVld := aClone(aRetHlp)
			Endif

			If Empty( aHelpVld ) .And. lHlpVisual
				
				/*-----------------------------------+
				| Reporte de contador inicial da PD. |
				+-----------------------------------*/
				NGTRETCON( M->TV1_CODBEM, M->TV1_DTSERV, M->TV1_CONINI, M->TV1_HRINI, 1, , , 'C' )
				
				/*---------------------------------+
				| Reporte de contador final da PD. |
				+---------------------------------*/
				NGTRETCON( M->TV1_CODBEM, IIf( M->TV1_HRFIM < M->TV1_HRINI, M->TV1_DTSERV + 1, M->TV1_DTSERV ),;
					M->TV1_CONFIM, M->TV1_HRFIM, 1, , , 'C' )

			EndIf

			M->TV1_EMPRES := SM0->M0_CODIGO

		ElseIf Altera

			If Empty(aHelpVld) .And. !Empty(aRetHlp := MNT851VLDT())
					aHelpVld := aClone(aRetHlp)
			EndIf

			If Empty(aHelpVld) .And. !Empty(aRetHlp := MNT851VLHR())
				aHelpVld := aClone(aRetHlp)
			Endif

			If Empty(aHelpVld) .And. !Empty(aRetHlp := MNTA851SB())
				aHelpVld := aClone(aRetHlp)
			Endif

			If Empty(aHelpVld) .And. !Empty(aRetHlp := MNTA851BEM()) // Valida Bem controlado por contador e controlado por parte diária
				aHelpVld := aClone(aRetHlp)
			Endif

			// Caso contador diferente do que esta na base ou registro inconsistente
			If TV1->TV1_INDERR == "1"
				If Empty(aHelpVld) .And. !Empty(aRetHlp := MNTA851CON(1))
					aHelpVld := aClone(aRetHlp)
				Endif

				If Empty(aHelpVld) .And. !Empty(aRetHlp := MNTA851CON(2))
					aHelpVld := aClone(aRetHlp)
				Endif
			EndIf

			If Empty(aHelpVld) .And. TV1->TV1_INDERR == "1" // Registro inconsistente
				
				/*-----------------------------------+
				| Reporte de contador inicial da PD. |
				+-----------------------------------*/
				NGTRETCON( M->TV1_CODBEM, M->TV1_DTSERV, M->TV1_CONINI, M->TV1_HRINI, 1, , , 'C' )

				/*---------------------------------+
				| Reporte de contador final da PD. |
				+---------------------------------*/
				NGTRETCON( M->TV1_CODBEM, IIf( M->TV1_HRFIM < M->TV1_HRINI, M->TV1_DTSERV + 1, M->TV1_DTSERV ),;
					M->TV1_CONFIM, M->TV1_HRFIM, 1, , , 'C' )

			EndIf

		EndIf

	Endif

	If lHlpVisual .And. !Empty(aHelpVld)
		ShowHlpVld(aHelpVld)
	Endif

Return If(lHlpVisual, Empty(aHelpVld), aHelpVld)

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT851LIOK
Consiste Linha

@author Evaldo Cevinscki Jr.
@since 10/05/2010
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Function MNT851LIOK(lRetLgc)

	Local aOldArea
	Local nQtd
	Local nI

	Local aHelpVld   := {}
	Local lHlpVisual := !IsInCallStack("MNTI851")

	Local aColsUse   := If( IsInCallStack( "MNTI851" ),"aCols","oGet:aCols" )
	Local aHeaderUse := If( IsInCallStack( "MNTI851" ),"aHeader","oGet:aHeader" )
	Local nLinAtu    := If( IsInCallStack( "MNTI851" ) .And. ( Type( "n" ) == "N" ),n,If( IsInCallStack( "MNTI851" ),0,oGet:nAt ) )

	Default lRetLgc := .T.

	If IsInCallStack( "MNTA851GR" ) .And. !IsInCallStack( "MNTI851" )
		nLinAtu := n
	EndIf

	Store 0 to nQtd

	nCODATI := GDFIELDPOS( "TV2_CODATI",&( aHeaderUse ) )
	nCODFRE := GDFIELDPOS( "TV2_CODFRE",&( aHeaderUse ) )
	nHRINI  := GDFIELDPOS( "TV2_HRINI" ,&( aHeaderUse ) )
	nHRFIM  := GDFIELDPOS( "TV2_HRFIM" ,&( aHeaderUse ) )
	nCONTA  := GDFIELDPOS( "TV2_CONTAD",&( aHeaderUse ) )

	If Empty(aHelpVld)
		aHelpVld := Periodo()
	EndIf

	If Empty(aHelpVld)
		aHelpVld := MNT851CONT(nLinAtu,&( aColsUse )[nLinAtu][nCONTA],M->TV1_CONINI,M->TV1_CONFIM)
	EndIf

	If Empty(aHelpVld) .And. &( aColsUse )[nLinAtu][Len( &( aColsUse )[nLinAtu] )]
		PutFileInEof("TV2")
		Return If(lRetLgc, .T., {})
	EndIf

	// Valida CC
	If Empty(aHelpVld)
		M->TV2_CODFRE := &( aColsUse )[nLinAtu][nCODFRE]
		aHelpVld := MNT851VLGD( "TV2_CODFRE",.F. )
	EndIf

	If Empty(aHelpVld)
		nMax := Len( &( aColsUse )[nLinAtu] )

		cCODATI := &( aColsUse )[nLinAtu][nCODATI]
		cCODFRE := &( aColsUse )[nLinAtu][nCODFRE]
		cHRINI  := &( aColsUse )[nLinAtu][nHRINI]
		cHRFIM  := &( aColsUse )[nLinAtu][nHRFIM]

		aEval( &( aColsUse ),{ |x| If( ( x[nCODATI] + x[nCODFRE] + x[nHRINI] + x[nHRFIM] == cCODATI + cCODFRE + cHRINI + cHRFIM .And. !x[nMax] ),nQtd++, Nil ) } )

		If nQtd > 1 .And. !Empty( cCODATI )
		   aHelpVld := {"99",	"Já existe registro com esta informação"} // "Já existe registro com esta informação" ## Troque a chave principal deste registro.
		Endif

		If !Empty(aHelpVld)
			For nI := 1 To Len( &( aColsUse ) )

				If !&( aColsUse )[nI][Len(&( aColsUse )[nI])] .And. nI <> nLinAtu
					If ( ( cHRINI <  &( aColsUse )[nI][nHRINI] .And. cHRFIM >  &( aColsUse )[nI][nHRINI] ) .Or.;
						(   cHRINI >  &( aColsUse )[nI][nHRINI] .And. cHRINI <  &( aColsUse )[nI][nHRFIM] ) .Or.;
						(   cHRINI == &( aColsUse )[nI][nHRINI] .Or.  cHRFIM == &( aColsUse )[nI][nHRFIM] ) )

						aHelpVld := {"99",STR0005} // "A Hora digitada esta entre outra já informada!"
					EndIf

				Endif
			Next
		Endif
	Endif

	// Verifica se o horario digitado nao esta no cadastro de outra parte diaria
	If Empty(aHelpVld)
		aOldArea  := TV1->( GetArea() )
		nRecAtual := TV1->( Recno() )
		dbSelectArea( "TV1" )
		dbSetOrder(1)
		If dbSeek( xFilial( "TV1" ) + cEmpAnt + M->TV1_CODBEM + DTOS( M->TV1_DTSERV ) + M->TV1_TURNO )

			While !EoF() .And. TV1->TV1_FILIAL == xFilial( "TV1" ) .And. ;
				TV1->TV1_EMPRES == cEmpAnt .And. TV1->TV1_CODBEM == M->TV1_CODBEM .And. ;
				DTOS( TV1->TV1_DTSERV ) == DTOS( M->TV1_DTSERV ) .And. TV1->TV1_TURNO == M->TV1_TURNO

				If ( &( aColsUse )[nLinAtu][nHRINI] >= TV1->TV1_HRFIM .And. &( aColsUse )[nLinAtu][nHRFIM] >= &( aColsUse )[nLinAtu][nHRINI] ) .Or. ;
					( &( aColsUse )[nLinAtu][nHRFIM] <= TV1->TV1_HRINI .And. &( aColsUse )[nLinAtu][nHRINI] <= &( aColsUse )[nLinAtu][nHRFIM] ) .Or. nRecAtual == TV1->( Recno() )
					dbSelectArea( "TV1" ) // Registro OK
					dbSkip()
					Loop
				EndIf

				If lHlpVisual
					If !MsgYesNo( STR0007 + CRLF + CRLF +; //"Esta Atividade está com o horário em conflito com outro cadastro de Parte Diária."
							  STR0008,STR0002 ) //"Deseja confirmar mesmo assim?"###"Atenção"
						aHelpVld := {""}
					EndIf
				Else
					aHelpVld := {"99",	STR0007} // "Esta Atividade está com o horário em conflito com outro cadastro de Parte Diária."
				EndIf

				Exit

				dbSelectArea( "TV1" )
				dbSkip()
			End While

		EndIf

		RestArea( aOldArea )

		ATUHRAEXP(0)
		TotalHoras()

	EndIf

	If lHlpVisual .And. !Empty(aHelpVld)
		ShowHlpVld(aHelpVld)
	Endif

	PutFileInEof("TV2")

Return If(lRetLgc, Empty(aHelpVld), aHelpVld)

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilização do Menu Funcional

@author Evaldo Cevinscki Jr.a
@since 10/05/2010
@version P11
@return aRotina - Estrutura
	[n,1] Nome a aparecer no cabecalho
	[n,2] Nome da Rotina associada
	[n,3] Reservado
	[n,4] Tipo de Transação a ser efetuada:
		1 - Pesquisa e Posiciona em um Banco de Dados
		2 - Simplesmente Mostra os Campos
		3 - Inclui registros no Bancos de Dados
		4 - Altera o registro corrente
		5 - Remove o registro corrente do Banco de Dados
		6 - Alteração sem inclusão de registros
		7 - Cópia
		8 - Imprimir
	[n,5] Nivel de acesso
	[n,6] Habilita Menu Funcional
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina  := {	{ STR0009  , "PesqBrw"   , 0, 1 },;       	// "Pesquisar"
	                    { STR0010  , "MNTA851CAD" , 0, 2 },;       	// "Visualizar"
	                    { STR0011  , "MNTA851CAD" , 0, 3 },;       	// "Incluir"
	                    { STR0012  , "MNTA851CAD" , 0, 4 },;       	// "Alterar"
	                    { STR0013  , "MNTA851EX"  , 0, 5, 3 } }    	// "Excluir"

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA851CAD
Cadastro de Parte Diária.

@param String cAlias: indica alias do cadastro
@param Integer nRecno: indica número do registro
@param Integer nOpcx: indica número da operação
@author André Felipe Joriatti
@since 21/08/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Function MNTA851CAD( cAlias, nRecno, nOpcx )

	Local aArea     := GetArea()
	Local aNao      := {}
	Local aNoFields := {}

	Local oPnlEmpFil := Nil
	Local oFontBold  := tFont():New( "Verdana",,014,.T.,.T. )
	Local oPnlCad    := Nil

	Local nI         := 0 // variável de laço for

	Local aCamposTV1 := {} // Campos MsMget TV1

	Local aButtons   := {} // Botões a serem adicionados na enchoice bar

	Local aHeadTV1   := {}

	Private oGetEmpres  := ""
	Private cGetEmpres  := ""
	Private oGetFilial  := ""
	Private cGetFilial  := ""
	Private nOpca       := 0
	Private cEmprTV1    := TV1->TV1_EMPRES

	// Recupera as chaves das tabelas TV1 e TV2
	Private cChvTV1EOld := If( cValToChar( nOpcx ) $ "4/5",&( "TV1->( " + TV1->( IndexKey( 01 ) ) + " )" ),"" ) // Recupera chave primária da TV1
	Private cChaveTV2   := If( cValToChar( nOpcx ) $ "4/5",&( "TV1->( TV1_FILIAL + TV1_EMPRES+ TV1_CODBEM + DTOS(TV1_DTSERV) )" ),"" ) // Recupera chave primária da TV2
	//If( cValToChar( nOpcx ) $ "45",xFilial( "TV2" ) + TV1->( TV1_EMPRES+TV1_CODBEM+DTOS( TV1_DTSERV )+TV1_TURNO+TV1_HRINI+TV1_HRFIM ),"" ) // Recupera chave de relacionamento TV2

	Private oDlg := Nil // janela da tela do cadastro
	Private oGet := Nil // get dados

	Private aTela   := {}
	Private aGets   := {}
	Private aHeader := {}
	Private aCols   := {}

	Private aSize    := MsAdvSize( ,.F.,430 )
	Private aObjects := {}

	aAdd( aObjects,{ 050,050,.T.,.T. } )
	aAdd( aObjects,{ 100,100,.T.,.T. } )
	aInfo := { aSize[1],aSize[2],aSize[3],aSize[4],0,0 }
	aPosObj := MsObjSize( aInfo,aObjects,.T. )

	cGetEmpres := If( nOpcx == 3,cEmpAnt,TV1->TV1_EMPRES )
	cGetFilial := If( nOpcx == 3,xFilial( "TV1" ),TV1->TV1_FILIAL )

	RegToMemory( "TV1",( nOpcx == 3 ) )
	Inclui := ( nOpcx == 3 )

	// 'Linka' as variáveis de Filial e Empresa com a memória da tabela
	VarRef( "M->TV1_EMPRES","cGetEmpres" )
	VarRef( "M->TV1_FILIAL","cGetFilial" )

	If nOpcx == 4 .And. TV1->TV1_INDERR == "1" // Caso alteração e registro com erro

		// Verifica se Empresa/Filial válidas
		If !fDefEmpFil()
			Return .F.
		EndIf

		// Abre Ambiente da Empresa+Filial conforme conteúdo do registro
		NGPrepTbl( aPrepTbls,cGetEmpres,cGetFilial )

		aZEMPS := { { cGetEmpres,cGetFilial } }

	EndIf

	// Campos que não devem ir na get dados
	aGetNao := { { "TV2_EMPRES" , "M->TV1_EMPRES"},;
				 { "TV2_CODBEM" , "M->TV1_CODBEM"},;
				 { "TV2_DTSERV" , "M->TV1_DTSERV"},;
				 { "TV2_TURNO"  , "M->TV1_TURNO" },;
				 { "TV2_PDIHRI" , "M->TV1_HRINI" },;
				 { "TV2_PDIHRF" , "M->TV1_HRFIM" }}
				 // { "TV2_INDERR" , "2"            },;
				 // { "TV2_MSGERR" , ""             } }

	If IsInCallStack( "MNTA851" )
		aAdd( aGetNao,{ "TV2_INDERR","2" } )
		aAdd( aGetNao,{ "TV2_MSGERR",""  } )
	EndIf

	// Condição enquanto para recuperar dados da TV2
	cGETWHILE := "TV2_FILIAL == xFilial( 'TV2' ) .And. TV2->TV2_EMPRES == cEmprTV1 .And. TV2->TV2_CODBEM == M->TV1_CODBEM .And. "
	cGETWHILE += "DTOS( TV2->TV2_DTSERV ) == DTOS( M->TV1_DTSERV ) .And. TV2->TV2_TURNO == M->TV1_TURNO .And. "
	cGETWHILE += "TV2->TV2_PDIHRI == M->TV1_HRINI .And. TV2->TV2_PDIHRF == M->TV1_HRFIM "

	aNao := {}
	For nI := 1 To Len( aGetNao )
		aAdd( aNao,aGetNao[nI][1] )
	Next nI

	aNoFields := aClone( aNao )

	// Chave de relacionamento TV1 X TV2, sem filial
	cKey := TV1->TV1_EMPRES+TV1->TV1_CODBEM+DTOS( TV1->TV1_DTSERV )+TV1->TV1_TURNO+TV1->TV1_HRINI+TV1->TV1_HRFIM

	// Gera aHeader e aCols da get dados
	FillGetDados( nOpcx,"TV2",1,xFilial( "TV2" )+cKey,{ || },{ || .T. },aNoFields,,,,{ || NGMontaAcols( "TV2",cKey,cGETWHILE ) } )

	If Empty( aCols ) .Or. nOpcx == 3
		aCols := BLANKGETD( aHeader )
		aCols[1][GDFIELDPOS( "TV2_WEBFLE",aHeader )] := "N" // Não webfleet
	EndIf

	// Caso inclusão e registro sem erro
	If nOpcx == 3 .And. M->TV1_INDERR == "2"
		cGetEmpres := cEmpAnt
		cGetFilial := xFilial( "TV1" )
	EndIf

	// Recupera campos da TV1 que devem ser exibidos
	aHeadTV1 := NGHeader("TV1")

	For nI := 1 To Len(aHeadTV1)

		cCampo := aHeadTV1[nI,2]

		If !(((UPPER(cCampo) == "TV1_INDERR" .Or. UPPER(cCampo) == "TV1_MSGERR") .And. IsInCallStack("MNTA851")) .Or.;
			  (UPPER(cCampo) == "TV1_FILIAL" .Or. UPPER(cCampo) == "TV1_EMPRES"))

			aAdd(aCamposTV1,cCampo)

		EndIf

	Next nI

	Define MSDialog oDlg Title OemToAnsi( cCadastro ) From aSize[7],000 To aSize[6],aSize[5] Of oMainWnd Pixel

		//------------------------------------
		// Panel para campos de Empresa/Filial
		//------------------------------------

		If IsInCallStack( "MNTA852" )

			oPnlEmpFil := tPanel():New( 001,001,,oDlg,,,,CLR_BLACK,CLR_WHITE,050,015,.T.,.T. )
			oPnlEmpFil:Align := CONTROL_ALIGN_TOP

				// Empresa
				@ 005,010 Say OemToAnsi( "Empresa: " ) Font oFontBold COLOR CLR_BLACK Of oPnlEmpFil Pixel // "Empresa: "
				oGetEmpres := tGet():New( 004,050,{ |u| __ReadVar := "cGetEmpres",If( PCount() > 0,cGetEmpres := u,cGetEmpres ) },oPnlEmpFil,040,008,"",{ || MNT851VLEF() },CLR_BLACK,CLR_WHITE,,;
						 				.F.,,.T./*lPixel*/,,.F.,{ || Altera .And. ( M->TV1_INDERR == "1" ) }/*bWhen*/,.F.,.F.,,.F./*lReadOnly*/,.F.,"YM0","cGetEmpres",,,,.T./*lHasButton*/ )
				oGetEmpres:bHelp := {|| ShowHelpCpo( "Empresa",;
								  				{ "Selecione a empresa da Parte Diária." },2,; // "Selecione a empresa da Parte Diária."
								  		 		{ "Deve estar cadastrada no sistema para utilização." },2 ) } // "Deve estar cadastrada no sistema para utilização."
				// Filial
				@ 005,110 Say OemToAnsi( "Filial: " ) Font oFontBold COLOR CLR_BLACK Of oPnlEmpFil Pixel // "Filial: "
				oGetFilial := tGet():New( 004,150,{ |u| __ReadVar := "cGetFilial",If( PCount() > 0, cGetFilial := u, cGetFilial ) },oPnlEmpFil,040,008,"",{ || MNT851VLEF( 2 ) },CLR_BLACK,CLR_WHITE,,;
						 				.F.,,.T./*lPixel*/,,.F.,{ || Altera .And. ( M->TV1_INDERR == "1" ) }/*bWhen*/,.F.,.F.,,.F./*lReadOnly*/,.F.,"SM0MOB","cGetFilial",,,,.T./*lHasButton*/ )
				oGetFilial:bHelp := {|| ShowHelpCpo( "Filial",;
								  				{ "Selecione a filial da empresa da Parte Diária." },2,; // "Selecione a filial da empresa da Parte Diária."
								  		 		{ "Deve pertencer a empresa selecionada." },2 ) } // "Deve pertencer a empresa selecionada."

		EndIf

		// Panel para enchoice do cadastro
		oPnlCad := tPanel():New( 000,000,Nil,oDlg,Nil,.T.,.F.,Nil,Nil,000,000,.T.,.F. )
		oPnlCad:Align := CONTROL_ALIGN_ALLCLIENT

		// enchoice do cadastro
		oEnchoice := MsMGet():New( "TV1",nRecno,nOpcx,,,,aCamposTV1,aPosObj[1],,3,,,,oPnlCad )
		oEnchoice:oBox:Align := CONTROL_ALIGN_TOP

		// Get Dados de Atividades da Parte Diária
		oGet := MSNewGetDados():New( aPosObj[2,2],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],GD_INSERT+GD_UPDATE+GD_DELETE,"MNT851LIOK()","AllwaysTrue()",,,,;
								     ,,,,oPnlCad,aHeader,aCols,{ || MNT851CHG() }, )
		oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

		If IsInCallStack( "MNTA852" )
			aAdd( aButtons, { "bmpemerg_mdi.png",{ || fErros851() },"Erros Imp." } )  // "Erros Imp."
		EndIf

	Activate MSDialog oDlg On Init EnchoiceBar( oDlg,{ || nOpca := 1,If( nOpcx == 2,Eval( { || nOpca := 0,oDlg:End(),.T. } ),If( If( nOpcx == 5,.T.,oGet:tudoOK() ),If( nOpcx != 5 .And. !Obrigatorio( aGets,aTela ),nOpca := 0,If( MNTA851GR( ,nOpcx ),oDlg:End(),nOpca := 0 ) ),nOpca := 0 ) ) } , ;
													 { || nOpca := 2,oDlg:End() },,aButtons )

	CursorWait()

	If nOpca == 1
		Begin Transaction
			Processa( { || MNT851GRV( nOpcx ) } )
		End Transaction
	EndIf

	CursorArrow()

	//----------------------------------------------------
	// Caso tenha alterado a empresa, retorna o ambiente
	// para empresa e filial originais
	//----------------------------------------------------
	If ( ( PadR( cGetEmpres,Len( cOrigEmp ) ) + PadR( cGetFilial,Len( cOrigFil ) ) ) != ( cOrigEmp + cOrigFil ) )
		NGPrepTbl( aPrepTbls,cOrigEmp,cOrigFil )
	EndIf

	RestArea( aArea )

Return nOpca

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT851GRV
Grava registro de Parte Diária

@author André Felipe Joriatti
@since 23/08/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Function MNT851GRV( nOpcx )

	Local nI           := 0
	Local nY           := 0
	Local nT           := 0 //Usadas em laço for
	Local nCnt         := 0 //Usado em laço For
	Local nSeqRel      := aScan( oGet:aHeader ,{ |x| AllTrim( Upper( X[2] ) ) == "TV2_SEQREL" } )
	Local aOldArea     := {}
	Local aInicio	   := {}
	Local aFim 		   := {}
	Local lRecLock     := .T.
	Local lContinua    := .T.
	Local lExcluirEOld := .F.
	Local bBlock       := {|| }
	Local cSeqTV2      := ""
	Local cAliasQry    := ""
	Local cField       := ''

	Private aDados := {} //Array contendo os apontamentos que serão excluídas
	Private aRet   := {} //Contém os retornos do envio dos XML para o RM

	//Bloco de código com a chamada do envio da mensagem de integração
	bBlock   := {| | FWIntegDef( 'MNTA851', EAI_MESSAGE_BUSINESS, TRANS_SEND, Nil, 'MNTA851' ) }

	If cGetEmpres != cOrigEmp
		nOpcx := 3
		lExcluirEOld := .T.
	EndIf

	If ( cOrigEmp + cOrigFil ) != ( PadR( cGetEmpres,Len( cOrigEmp ) ) + PadR( cGetFilial,Len( cOrigFil ) ) )
		NGPrepTbl( aPrepTbls,cGetEmpres,cGetFilial ) // Abre empresa conforme variáveis
	EndIf

	//Se for alteração, avalia se houve deleção de atividades da GetDados
	//Se sim, envia mensagem de apontamento para cada um dos appointments que foram deletados
	If nOpcx == 4

		For nCnt := 1 To Len(oGet:aCols)

			If GDDeleted(nCnt, oGet:aHeader, oGet:aCols)	//Verifica se foi deletado

				aAdd(aDados, {M->TV1_CODBEM, M->TV1_DTSERV, oGet:aCols[nCnt][nSeqRel]})

			EndIf

		Next nCnt

	ElseIf nOpcx == 5

		For nCnt := 1 To Len(oGet:aCols)

			aAdd(aDados, {M->TV1_CODBEM, M->TV1_DTSERV, oGet:aCols[nCnt][nSeqRel]})

		Next nCnt

	EndIf

	If !Empty(aDados)
		//Envia informações referente ao apontamento deletado
		//Caso falhe o envio, aborta a operação de exclusão
		If Type("oMainWnd") == "O"
			MsgRun("Aguarde integração com backoffice...", "Appointment", bBlock)
		Else
			Eval(bBlock)
		EndIf
	EndIf

	If !Empty(aRet)
		lContinua := aRet[1]
	EndIf

	If lContinua
		If ( nOpcx == 3 ) .Or. ( nOpcx == 4 )

			M->TV1_INDERR := "2" // Registro OK
			M->TV1_MSGERR := ""  // Limpa mensagens de erro

			// Atualiza tabela do cabeçalho da Parte Diária
			DbSelectArea( "TV1" )
			RecLock( "TV1",( nOpcx == 3 ) )
			For nY := 1 To FCount()
				cField := "M->" + FieldName( nY )
				FieldPut( nY,&( cField ) )
			Next nY
			MsUnLock( "TV1" )

			cSeqTV2 := GetSeqTV2(xFilial("TV2") + M->TV1_EMPRES + M->TV1_CODBEM + DTOS(M->TV1_DTSERV))

			// Inclui registros na get dados
			For nT := 1 To Len( oGet:aCols )

				If GDDeleted( nT,oGet:aHeader,oGet:aCols )

					dbSelectArea("TV2")
					dbSetOrder(4)
					If dbSeek(xFilial("TV2") + M->TV1_EMPRES + M->TV1_CODBEM + Dtos(M->TV1_DTSERV) + oGet:aCols[nT][nSeqRel])
						RecLock("TV2",.F.)
						dbDelete()
						MsUnlock("TV2")
					EndIf
					Loop
				EndIf

				// Inicializa as variáveis de memória para a tabela TV2 de acordo com o conteúdo da linha atual
				For nI := 1 To Len( oGet:aHeader )
					xx := "M->" + oGet:aHeader[nI][2]
					&( xx ) := oGet:aCols[nT][nI]
				Next nI

				// Inicializa as variáveis de memória para campos que não aparecem na get dados
				For nI := 1 To Len( aGetNao )
					xx := "M->" + aGetNao[nI][1]
					yy := aGetNao[nI][2]
					If !Empty( yy )
						&( xx ) := &( yy )
					EndIf
				Next nI

				M->TV2_INDERR := "2" // Registro OK
				M->TV2_MSGERR := ""  // Limpa mensagens de erro

				// Insere registro na TV2 (Atividades) conforme conteúdo das variáveis de memória
				lRecLock := .T.
				If nOpcx == 4
					dbSelectArea("TV2")
					dbSetOrder(4)
					If dbSeek(xFilial("TV2") + M->TV1_EMPRES + M->TV1_CODBEM + DTOS(M->TV1_DTSERV) + oGet:aCols[nT][nSeqRel])
						lRecLock := .F.
					Else
						lRecLock := .T.
					EndIf
				EndIf

				RecLock( "TV2",lRecLock)
				For nI := 1 To FCount()
					cField := "M->" + FieldName( nI )

					//Não deve preencher campos de log de inclusão e alteração
					//Estes campos são preenchidos automaticamente pelo framework da TOTVS
					If !('_USERLGI' $ cField .Or. '_USERLGA' $ cField .Or. ;
						'_USERGI'   $ cField .Or. '_USERGA'  $ cField )

						If "_FILIAL" $ UPPER( cField )
							FieldPut( nI,xFilial( "TV2" ) )
						Else
							FieldPut( nI,&( cField ) )
						EndIf
					EndIf
				Next nI

				If Empty(M->TV2_SEQREL)
					cSeqTv2         := Soma1(cSeqTv2)
					TV2->TV2_SEQREL := cSeqTv2
				EndIf

				MsUnLock( "TV2" )

			Next nT

			If SuperGetMV( "MV_NGPARCO",.F.,"N" ) == "S" .And. IsInCallStack("MNTA852")

				// Atualizar o contador Fim na Parte diária quanto existir mais de uma atividade no dia.

				aInicio	:= GetTv1(TV1->TV1_FILIAL, TV1->TV1_EMPRES, TV1->TV1_CODBEM,TV1->TV1_DTSERV, 1)
				aFim	:= GetTv1(TV1->TV1_FILIAL, TV1->TV1_EMPRES, TV1->TV1_CODBEM,TV1->TV1_DTSERV, 2)

				M->TV1_HRINI    := aInicio	[1]
				M->TV1_CONINI 	:= aInicio	[2]
				M->TV1_HRFIM	:= aFim		[1]
				M->TV1_CONFIM	:= aFim		[2]

				//Atualiza o registro anterior

				cAliasQry := GetNextAlias()

				cQuery := " SELECT * "
				cQuery += " FROM " + RetSQLName("TV1")
				cQuery += " WHERE TV1_FILIAL = '" +TV1->TV1_FILIAL+ "' AND TV1_EMPRES = '" +TV1->TV1_EMPRES+ "'"
				cQuery += " AND  TV1_CODBEM = '" +TV1->TV1_CODBEM+ "' AND D_E_L_E_T_<>'*' "
				cQuery += " AND  TV1_DTSERV || TV1_HRINI < '" + DtoS(TV1->TV1_DTSERV) + TV1->TV1_HRINI +"'"
				cQuery += " ORDER BY (TV1_DTSERV || TV1_HRINI) DESC "

				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
				dbGoTop()

				aOldArea  := TV1->( GetArea() )

				dbSelectArea("TV1")

				Set Filter To

				dbSetOrder(1) //TV1_FILIAL+TV1_EMPRES+TV1_CODBEM+DTOS( TV1_DTSERV )+TV1_TURNO+TV1_HRINI+TV1_HRFIM
				If dbSeek((cAliasQry)->TV1_FILIAL + (cAliasQry)->TV1_EMPRES + (cAliasQry)->TV1_CODBEM + ;
					(cAliasQry)->TV1_DTSERV + (cAliasQry)->TV1_TURNO + (cAliasQry)->TV1_HRINI + (cAliasQry)->TV1_HRFIM )

					If M->TV1_CONINI != (cAliasQry)->TV1_CONFIM
						Reclock("TV1",.F.)
						TV1->TV1_CONFIM := M->TV1_CONINI
						MsUnLock("TV1")
					EndIf
				EndIf

				// Retorna do filtro pardrao da rotina de acerto de PD.
				Mnt852SALI(.T.,.F.)

				(cAliasQry)->(dbCloseArea())
				RestArea( aOldArea )
			EndIf

		ElseIf nOpcx == 5

			// exclusão de registro da Parte Diária
			NGDBAREAORDE( "TV1",01 ) // TV1_FILIAL+TV1_EMPRES+TV1_CODBEM+DTOS( TV1_DTSERV )+TV1_TURNO+TV1_HRINI+TV1_HRFIM
			If DbSeek( cChvTV1EOld )

				// Exclusão das Atividades da Parte Diária
				NGDBAREAORDE( "TV2",04 ) // TV2_FILIAL+ TV2_EMPRES+ TV2_CODBEM + DTOS(TV2_DTSERV)+ TV2_SEQREL
				While TV2->( DbSeek( cChaveTV2 ) )
					NGDELETAREG( "TV2" )
				End While

				dbSelectArea("TV1")
				NGDELETAREG( "TV1" )

			EndIf

		EndIf

		If ExistBlock( "MNTA851B" )
			ExecBlock( "MNTA851B",.F.,.F.,{ nOpcx, M->TV1_FILIAL, M->TV1_EMPRES, M->TV1_CODBEM, M->TV1_DTSERV,;
			oGet:aHeader, oGet:aCols } )
		EndIf

		// Devolve o ambiente para o estado do início da rotina
		NGPrepTbl( aPrepTbls,cOrigEmp,cOrigFil )

		// Caso tenha inserido o registro em empresa nova, então exclui da empresa atual
		If lExcluirEOld

			NGDBAREAORDE( "TV1",01 ) // TV1_FILIAL+TV1_EMPRES+TV1_CODBEM+DTOS( TV1_DTSERV )+TV1_TURNO+TV1_HRINI+TV1_HRFIM
			If DbSeek( cChvTV1EOld )

				NGDBAREAORDE( "TV2",04 ) // TV2_FILIAL+ TV2_EMPRES+ TV2_CODBEM + DTOS(TV2_DTSERV)+ TV2_SEQREL
				While TV2->( DbSeek( cChaveTV2 ) )
					NGDELETAREG( "TV2" )
				End While

				dbSelectArea("TV1")
				NGDELETAREG( "TV1" )

			EndIf

		EndIf

	Else

		MsgInfo(STR0065)	//"Falha no envio dos appointments excluídos sentido Protheus - RM! Abortando processo de deleção."
		Return .F.

	EndIf

	aDados := {}

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA851PLA
Validação da placa

@author Evaldo Cevinscki Jr.
@since 10/05/2010
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MNTA851PLA()

	Local aOldArea := GetArea()
	Local aHelpVld := {}

	If Empty(M->TV1_PLACA)
		Return {}
	Endif

	dbSelectArea( "ST9" )
	dbSetOrder( 14 ) // T9_PLACA+T9_SITBEM
	If !dbSeek( M->TV1_PLACA )
		aHelpVld := {"99",STR0016} // "Placa Invalida."
	Endif

	If Empty(aHelpVld) .And. ST9->T9_TEMCONT != "S"
		aHelpVld := {"99",STR0014} // "Bem não é controlado por contador."
	EndIf

	If Empty(aHelpVld) .And. ST9->T9_PARTEDI != "1"
		aHelpVld := {"99",STR0015 } // "Bem não é controlado por parte diária."
	Endif

	If Empty(aHelpVld)
		cFilBem := ST9->T9_FILIAL
	EndIf

	RestArea( aOldArea )

Return aHelpVld

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA851OPE
Validacao do codigo do Operador

@author Evaldo Cevinscki Jr.
@since 10/05/2010
@version P11
@return Boolean lRETVH: conforme validação do operador
/*/
//---------------------------------------------------------------------
Static Function MNTA851OPE()

	Local lRETVH    := .T.
	Local aArea     := GetArea()
	Local dDEMISSAO := CTOD( "  /  /  " )
	Local cNGMNTRH  := AllTrim( GetMv( "MV_NGMNTRH" ) )

	If !ExistCpo( "SRA",M->TV1_OPERAD,1 )
		Return .F.
	EndIf

	// Integracao com RH

	If cNGMNTRH = "S"

		dbSelectArea( "SRA" )
		dbSetOrder( 13 ) // RA_MAT+RA_FILIAL
		dbSeek( M->TV1_OPERAD )
		M->TV1_NOMEOP := SRA->RA_NOME
		While !EoF() .And. SRA->RA_MAT == M->TV1_OPERAD

			If Empty( SRA->RA_DEMISSA )
				dDEMISSAO := CTOD( "  /  /  " )
				Exit
			EndIf

			If SRA->RA_DEMISSA > dDemissao
			   dDEMISSAO := SRA->RA_DEMISSA
			EndIf

			dbSelectArea( "SRA" )
			dbSkip()
		End While

		IF !Empty( dDEMISSAO ) .And. dDEMISSAO < M->TV1_DTSERV
			HELP( " ",1,STR0006,,STR0017 + CHR( 13 ) + STR0018,3,1 ) //"ATENÇÃO"###"Data Invalida"###"Lançamento após demissão."
			lRETVH := .F.
		EndIf

		dbSelectArea( "SR8" )
		dbSetOrder( 1 )
		dbSeek( xFilial( "SR8" ) + M->TV1_OPERAD )
		If SR8->R8_TIPO = "F"
			If M->TV1_DTSERV > SR8->R8_DATAINI .And. M->TV1_DTSERV < SR8->R8_DATAFIM
				HELP( " ",1,STR0006,,STR0019,3,1 ) //"ATENÇÃO"###"Operador em período de férias!"
		      	lRETVH := .F.
		   EndIf
		EndIf

	EndIf

	RestArea( aArea )

Return lRETVH

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA851TER
Valida se for Terceiro joga "TERC" no codigo do operador

@author Evaldo Cevinscki Jr.
@since 11/05/2010
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MNTA851TER()

	If M->TV1_TERCEI == "1"
		M->TV1_OPERAD := PadR( "TERC", Len( TV1->TV1_NOMEOP ) )
		M->TV1_NOMEOP := Space( Len( TV1->TV1_NOMEOP ) )
	Else
		M->TV1_OPERAD := Space( Len( TV1->TV1_OPERAD ) )
		M->TV1_NOMEOP := Space( Len( TV1->TV1_NOMEOP ) )
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA851CON
Valida os contadores informados

@param Integer nVAR: indica contador
@author Evaldo Cevinscki Jr.
@since 11/05/2010
@version P11
@return true ou false conforme validação
/*/
//---------------------------------------------------------------------
Function MNTA851CON( nVAR )

	Local xRetValid // Variavel pode receber valor Logico ou Lista [Array]
	Local aHelpVld := {}
	Local dDayCnt  := CToD( '' )

	Local nLinhaAtu  := If( IsInCallStack( "MNTI851" ) .And. ( Type( "n" ) == "N" ),n,If( IsInCallStack( "MNTI851" ),0,oGet:nAt ) )

	// Caso o bem não possua contador nao efetua validacoes correspondentes
	If NGSEEK("ST9",M->TV1_CODBEM,1,"T9_TEMCONT") <> "S"
		Return {}
	Endif

	If ReadVar() == "M->TV2_CONTAD"
		If !Positivo()
			aHelpVld := If( lHlpVisual, {""}, {"99", "Contador deve ser positivo."} )
			Return aHelpVld
		EndIf
	EndIf

	If nVAR == 1
		nPosCont := M->TV1_CONINI
		cHrCont	 := M->TV1_HRINI
		dDayCnt  := M->TV1_DTSERV
	ElseIf nVAR == 2
		nPosCont := M->TV1_CONFIM
		cHrCont	 := M->TV1_HRFIM
		dDayCnt  := IIf( M->TV1_HRFIM < M->TV1_HRINI, M->TV1_DTSERV + 1, M->TV1_DTSERV )
	ElseIf nVAR == 3 // Contador da atividade
		aHelpVld := MNT851CONT( nLinhaAtu, M->TV2_CONTAD, M->TV1_CONINI, M->TV1_CONFIM )
		Return aHelpVld
	EndIf

	// Valida limite de contador
	xRetValid := CHKPOSLIM( M->TV1_CODBEM, nPosCont, 1, , lHlpVisual )

	If ( lHlpVisual .And.  !xRetValid )
		aHelpVld := If( lHlpVisual, {""}, {"99", xRetValid[2]} )
	EndIf

	// Valida historico do contador
	xRetValid := NGCHKHISTO( M->TV1_CODBEM, dDayCnt, nPosCont, cHrCont, 1, , lHlpVisual )


	If ( lHlpVisual .And.  !xRetValid ) .Or. ( !lHlpVisual .And. !xRetValid[1] )
		aHelpVld := If( lHlpVisual, {""}, {"99", xRetValid[2]} )
		Return aHelpVld
	EndIf

	// Verifica variacao dia
	xRetValid := NGVALIVARD( M->TV1_CODBEM, nPosCont, dDayCnt, cHrCont, 1, lHlpVisual )

	If ( lHlpVisual .And.  !xRetValid ) .Or. ( !lHlpVisual .And. !xRetValid[1] )
		aHelpVld := If( lHlpVisual, {""}, {"99", xRetValid[2]} )
		Return aHelpVld
	EndIf

Return aHelpVld

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA851EX
Programa de exclusão de Atividade Diária.

@author Evaldo Cevinscki Jr.
@since 11/05/2010
@version P11
@return true ou false conforme validação
/*/
//---------------------------------------------------------------------
Function MNTA851EX(cAlias, nRecno, nOpc)

	Local i, nRet := 1
	Local vVDadoE := { TV1->TV1_CODBEM, TV1->TV1_DTSERV, TV1->TV1_HRINI, TV1->TV1_HRFIM }
	Local aRetTPN := NgFilTPN( TV1->TV1_CODBEM, TV1->TV1_DTSERV, TV1->TV1_HRINI )
	Local cFilTPN := aRetTPN[1]

	Local lHlpVisual := !IsInCallStack("MNTI851") .And. !IsInCallStack("MNTA851CAD")

	Local aAreaTV1 := {}

	If lHlpVisual .And. !MsgYesNo( STR0020, STR0006 ) // "Deseja realmente Excluir esse registro?"###"ATENÇÃO"
	   Return .F.
	EndIf

	dbSelectArea( "TV1" )
	aAreaTV1 := GetArea()

	If cFilTPN = " "
		cFilTPN := TV1->TV1_FILIAL
	EndIf

	If lHlpVisual
		nRet := MNTA851CAD( "TV1",Recno(),5 )
	Endif

	If nRet <> 0
		// Referentes ao primeiro contador
		aARALTC :=  {	'STP','STP->TP_FILIAL','STP->TP_CODBEM',;
	   	            'STP->TP_DTLEITU','STP->TP_HORA','STP->TP_POSCONT',;
							'STP->TP_ACUMCON','STP->TP_VARDIA','STP->TP_VIRACON' }

		aARABEM := { 	'ST9','ST9->T9_POSCONT','ST9->T9_CONTACU', ;
	   	          	'ST9->T9_DTULTAC','ST9->T9_VARDIA' }

		For i := 1 To 2

		    dbSelectArea( aARALTC[1] )
		    dbSetOrder( 5 )
		    If dbSeek( xFilial( aARALTC[1],cFilTPN ) + vVDadoE[1] + DTOS( vVDadoE[2] ) + If( i == 1,vVDadoE[3],vVDadoE[4] ) )

			    nRECNSTP := Recno()
		      	lULTIMOP := .T.
		      	nACUMFIP := 0
		      	nCONTAFP := 0
		      	nVARDIFP := 0
		      	dDTACUFP := CTOD( "  /  /  " )
		      	cHRACU   := "  :  "
		      	dbSkip( -1 )
			   If !EoF() .And. !BoF() .And. &( aARALTC[2]) = xFilial(aARALTC[1],cFilTPN ) .And. ;
			    	&( aARALTC[3] ) == vVDadoE[1]

					nACUMFIP := &( aARALTC[7] )
					dDTACUFP := &( aARALTC[4] )
					nCONTAFP := &( aARALTC[6] )
					nVARDIFP := &( aARALTC[8] )
					cHRACU   := &( aARALTC[5] )

				EndIf

				DbGoTo( nRECNSTP )

				nACUMDEL := STP->TP_ACUMCON

				dbSelectArea( aARALTC[1] )
				RecLock( aARALTC[1],.F. )
				DbDelete()
				MsUnLock( aARALTC[1] )

				MNTA875ADEL( vVDadoE[1],vVDadoE[2],If( i == 1,vVDadoE[3],vVDadoE[4]),1,cFilTPN,cFilTPN )

			EndIf
		Next i

		RestArea( aAreaTV1 )

		If ExistBlock( "MNTA851E" )
			ExecBlock( "MNTA851E",.F.,.F.,{ nRecno } )
		EndIf

	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA851HR
Valida Hora.

@author Evaldo Cevinscki Jr.
@since 11/05/2010
@version P11
@return true or false
/*/
//---------------------------------------------------------------------
Function MNTA851HR( nVar, cVAR )

	Local lVldGet   := !( Str(nVar, 1) $ "1/2" )
	Local aColsVld  := {}
	Local _cHoraIni
	Local _cHoraFim
	Local aHelpVld := {}

	Local aColsUse   := If( IsInCallStack( "MNTI851" ),"aCols","oGet:aCols" )
	Local aHeaderUse := If( IsInCallStack( "MNTI851" ),"aHeader","oGet:aHeader" )
	Local nLinhaAtu  := If( IsInCallStack( "MNTI851" ) .And. ( Type( "n" ) == "N" ),n,If( IsInCallStack( "MNTI851" ),0,oGet:nAt ) )

	Default cVAR := ReadVar()

	If lVldGet
		aColsVld  := aClone( &( aColsUse ) )
		nHrTot := aScan( &( aHeaderUse ),{ |x| AllTrim( Upper( X[2] ) ) == "TV2_TOTHOR" } )
		nHrIni := aScan( &( aHeaderUse ),{ |x| AllTrim( Upper( X[2] ) ) == SubStr( "M->TV2_HRINI",4 ) } )
		nHrFim := aScan( &( aHeaderUse ),{ |x| AllTrim( Upper( X[2] ) ) == SubStr( "M->TV2_HRFIM",4 ) } )
		nMax   := Len( &( aColsUse )[nLinhaAtu] )
	Endif

	If Altera
		If M->TV1_HRINI > M->TV1_HRFIM
			lPodeMaior := .T.
		EndIf
	EndIf

	If !lVldGet .And. AllTrim( M->TV1_HRINI ) == ":" .And. AllTrim( M->TV1_HRFIM ) == ":"
		Return {}
	EndIf

	If !NGVALHORA(&( cVar ), .F.)
		aHelpVld := {"99","Hora inválida."}
		Return aHelpVld
	EndIf

	If lVldGet
		aDel( aColsVld,nLinhaAtu )
		aSize( aColsVld,Len( aColsVld ) - 1 )
		_cHoraIni := If(cVAR == "M->TV2_HRINI",M->TV2_HRINI,&( aColsUse )[nLinhaAtu][nHrIni])
		_cHoraFim := If(cVAR == "M->TV2_HRFIM",M->TV2_HRFIM,&( aColsUse )[nLinhaAtu][nHrFim])
	Endif

	If !lVldGet .And. M->TV1_HRINI == M->TV1_HRFIM
		Return {"99",STR0021} // "'Hora Inicio' e 'Hora Final' deverão ser diferentes!"
	EndIf

	If nVar == 1
		If !Empty(M->TV1_HRFIM)
			If &( cVar ) > M->TV1_HRFIM .And. !lPodeMaior
				If M->TV1_HRFIM <> "00:00"
					Return {"99",STR0022} // "Hora Inicial deve ser menor que Hora Final!"
				EndIf
			EndIf
		EndIf

		ATUHRAEXP( 0 )

	ElseIf nVar == 2

		If &( cVar ) < M->TV1_HRINI .And. !lPodeMaior
			If &( cVar ) <> "00:00"
				Return {"99",STR0024} // "Hora Final deve ser maior que Hora Inicio!"
			EndIf
		EndIf

		ATUHRAEXP( 0 )

	ElseIf nVar == 3

		If !Empty( &( aColsUse )[nLinhaAtu][nHRFIM] )
			If &( cVar ) == &( aColsUse )[nLinhaAtu][nHrFim]
				Return {"99",STR0025} // "Hora Final deve ser maior que Hora Inicio!"
			ElseIf &( cVar ) > &( aColsUse )[nLinhaAtu][nHrFim] .And. !lPodeMaior
				Return {"99",STR0026} // "Hora Inicial deve ser menor que Hora Final!"
			EndIf
		EndIf

		If aSCAN(aColsVld, {|x| &( cVar ) == x[3]                                 .And. !x[nMax]}) > 0 .Or. ;
			aSCAN(aColsVld, {|x| &( cVar ) <= x[3] .And. &( aColsUse )[nLinhaAtu][nHrFim] > x[3]  .And. !x[nMax]}) > 0 .Or. ;
			aSCAN(aColsVld, {|x| &( cVar ) >  x[3] .And. x[4]             >  &( cVar ) .And. !x[nMax]}) > 0
			Return {"99",STR0027} // "A Hora digitada esta entre outra já informada!"
		EndIf
		ATUHRAEXP(nLinhaAtu,M->TV2_HRINI,&( aColsUse )[nLinhaAtu][nHrFim])

	ElseIf nVar == 4

		If &( cVar ) == &( aColsUse )[nLinhaAtu][nHRINI]
			Return {"99",STR0028} // "'Hora Inicio' e 'Hora Termino' deverão ser diferentes!"
		ElseIf &( cVar ) < &( aColsUse )[nLinhaAtu][nHrIni] .And. !lPodeMaior
			Return {"99",STR0029} // "'Hora Inicio' e 'Hora Termino' deverão ser diferentes!"
		Else
			If aSCAN(aColsVld, {|x| &( aColsUse )[nLinhaAtu][nHrIni] <= x[3] .And. &( cVar ) > x[3]             .And. !x[nMax]}) > 0 .Or. ;
				aSCAN(aColsVld, {|x| &( aColsUse )[nLinhaAtu][nHrIni] >  x[3] .And. x[4]  > &( aColsUse )[nLinhaAtu][nHrIni] .And. !x[nMax]}) > 0
				Return {"99",STR0030} // "A Hora digitada esta entre outra já informada!"
			EndIf
		EndIf
		ATUHRAEXP(nLinhaAtu,&( aColsUse )[nLinhaAtu][nHrIni],M->TV2_HRFIM)

	EndIf

	If lVldGet
		If (AllTrim(_cHoraIni) <> ":" .And. !Empty(_cHoraIni)) .And. (AllTrim(_cHoraFim) <> ":" .And. !Empty(_cHoraFim))
			If _cHoraFim > _cHoraIni
				&( aColsUse )[nLinhaAtu][nHrTot] := NTOH( HTON( _cHoraFim ) - HTON( _cHoraIni ) )
			Else
				&( aColsUse )[nLinhaAtu][nHrTot] := NTOH( HTON( "24:00" ) - HTON( _cHoraIni ) + HTON( _cHoraFim ) )
			EndIf

			TotalHoras()

		EndIf
	EndIf

Return aHelpVld

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA851BEM
Validação do bem

@author Marcos Wagner Junior
@since 24/06/2010
@version P11
@return true or false conforme validação
/*/
//---------------------------------------------------------------------
Static Function MNTA851BEM()

	Local aHelpVld := {}

	dbSelectArea( "ST9" )
	dbSetOrder( 16 )
	dbSeek(M->TV1_CODBEM)

	If ST9->T9_TEMCONT != "S"
		aHelpVld := {"99", STR0031} // "Bem não é controlado por contador."
	EndIf

	If Empty(aHelpVld) .And. ST9->T9_PARTEDI != "1"
		aHelpVld := {"99", STR0032} // "Bem não é controlado por parte diária."
	EndIf

Return aHelpVld

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT851CALE
Carrega calendário

@author Marcos Wagner Junior
@since 24/06/2010
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MNT851CALE()

	Local aHelpVld := {}
	Local lHlpVisual := !IsInCallStack("MNTI851")

	Private aDiasSH7 := {}, nDiaSemana := 0

	lPodeMaior := .F.

	If !Empty(M->TV1_DTSERV)
		nDiaSemana := Dow(M->TV1_DTSERV)
	EndIf

	If nDiaSemana == 0
		Return aHelpVld
	EndIf

	If !Empty(M->TV1_TURNO)
		aDiasSH7 := NGCALENDAH(M->TV1_TURNO)
		If Len(aDiasSH7) == 0
			aHelpVld := {"99", STR0033} // "Calendário inválido!"
		EndIf
	Else
		aHelpVld := {"99", STR0034} // "O Turno deve ser preenchido para a validação da Data."
	EndIf

	If Empty(aHelpVld) .And. lHlpVisual

		// lCompleme := M851COMPLE() // Verifica se e' complemento do dia anterior

		If Len( aDiasSH7[nDiaSemana][2] ) > 0 .And. nDiaSemana != 0 // .And. !lCompleme
			nUlturno := Len( aDiasSH7[nDiaSemana][2] )

				M->TV1_HRINI := aDiasSH7[nDiaSemana][2][nUlturno][1]
				M->TV1_HRFIM := aDiasSH7[nDiaSemana][2][nUlturno][2]
				M->TV1_HREXI := aDiasSH7[nDiaSemana][2][nUlturno][1]
				M->TV1_HREXF := aDiasSH7[nDiaSemana][2][nUlturno][2]

			If aDiasSH7[nDiaSemana][2][nUlturno][2] == '24:00'
				nDiaSemana++

				If nDiaSemana > 7
					nDiaSemana := 1
				EndIf

				If Len( aDiasSH7[nDiaSemana][2] ) > 0
						M->TV1_HRFIM := aDiasSH7[nDiaSemana][2][1][2]
						M->TV1_HREXF := aDiasSH7[nDiaSemana][2][1][2]
				EndIf
			EndIf

			// Transforma as Horas 00:00 e 24:00 da Parte Diaria
				If M->TV1_HRINI == "24:00"
					M->TV1_HRINI := "00:00"
			EndIf
				If M->TV1_HRFIM == "24:00"
					If M->TV1_HRINI == "00:00"
						M->TV1_HRFIM := "23:59"
				Else
						M->TV1_HRFIM := "23:59"
				EndIf
			EndIf

			// Transforma as Horas 00:00 e 24:00 do Expediente
				If M->TV1_HREXI == "24:00"
					M->TV1_HREXI := "00:00"
			EndIf
				If M->TV1_HREXF == "24:00"
					If M->TV1_HREXI == "00:00"
						M->TV1_HREXF := "23:59"
				Else
						M->TV1_HREXF := "23:59"
				EndIf
			EndIf

		Else
			If ( Len( aDiasSH7[nDiaSemana][2] ) == 0 ) // .Or. lCompleme
					aHelpVld := {"99", STR0035}
					M->TV1_DTSERV := STOD('  /  /  ')
			Endif
				M->TV1_HRINI := '  :  '
				M->TV1_HRFIM := '  :  '

		Endif

		ATUHRAEXP( 0 )

	Endif

	If Empty(aHelpVld) .And. M->TV1_HRINI > M->TV1_HRFIM
		lPodeMaior := .T.
	Endif

Return aHelpVld

//---------------------------------------------------------------------
/*/{Protheus.doc} TotalHoras
Totaliza variaveis de horas

@author Marcos Wagner Junior
@since 24/06/2010
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function TotalHoras()

	Local nI := 0
	Local nCODATI
	Local nTOTHOR

	If IsInCallStack("MNTI851")
		Return
	Endif

	Store '00:00' To M->TV1_HRATRA, M->TV1_HRACHU, M->TV1_HRAMNT, M->TV1_HRAPLA

	nCODATI := GDFIELDPOS( "TV2_CODATI",oGet:aHeader )
	nTOTHOR := GDFIELDPOS( "TV2_TOTHOR",oGet:aHeader )

	For nI := 1 To Len( oGet:aCols )

		If !oGet:aCols[nI][Len( oGet:aHeader ) + 1]
			If ReadVar() == 'M->TV2_CODATI' .And. oGet:nAt == nI
				cCodAtiv := M->TV2_CODATI
			Else
				cCodAtiv := oGet:aCols[nI][nCODATI]
			EndIf

			dbSelectArea( "TV0" ) // Cadastro de Atividades
			dbSetOrder( 01 ) // TV0_FILIAL+TV0_CODATI

			If dbSeek( xFilial( "TV0" ) + cCodAtiv )
				If TV0->TV0_TIPHOR == '1'
					M->TV1_HRATRA := NTOH( HTON( M->TV1_HRATRA ) + HTON( oGet:aCols[nI][nTOTHOR] ) )
				ElseIf TV0->TV0_TIPHOR == '2'
					M->TV1_HRACHU := NTOH( HTON( M->TV1_HRACHU ) + HTON( oGet:aCols[nI][nTOTHOR] ) )
				ElseIf TV0->TV0_TIPHOR == '3'
					M->TV1_HRAMNT := NTOH( HTON( M->TV1_HRAMNT) + HTON( oGet:aCols[nI][nTOTHOR] ) )
				ElseIf TV0->TV0_TIPHOR == '4'
					M->TV1_HRAPLA := NTOH( HTON( M->TV1_HRAPLA ) + HTON( oGet:aCols[nI][nTOTHOR] ) )
				EndIf
			EndIf
		EndIf
	Next nI

	If IsInCallStack("MNTA852")
		oVisEnc:Refresh()
	ElseIf IsInCallStack("MNTA851")
		oEnchoice:Refresh()
	Endif

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA851TOT
Totaliza variaveis de horas

@author Marcos Wagner Junior
@since 24/06/2010
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MNTA851TOT()
	TotalHoras()
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} Periodo
Verifica se lançamento de parte diária está dentro do turno de trabalho.

@author Marcos Wagner Junior
@since 24/06/2010
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function Periodo()

	Local aHelpVld := {}
	Local lShowMsg := .F.

	Local aColsUse   := If ( IsInCallStack( "MNTI851" ),"aCols","oGet:aCols" )
	Local nLinhAtu   := If( IsInCallStack( "MNTI851" ) .And. ( Type( "n" ) == "N" ),n,If( IsInCallStack( "MNTI851" ),0,oGet:nAt ) )

	If &( aColsUse )[nLinhAtu][Len( &( aColsUse )[nLinhAtu] )]
		Return {}
	EndIf

	If !Empty( &( aColsUse )[nLinhAtu][nHRINI] ) .And. !Empty( &( aColsUse )[nLinhAtu][nHRFIM] ) .And.;
	 ( ( &( aColsUse )[nLinhAtu][nHRFIM] < TV1->TV1_HREXI .Or. &( aColsUse )[nLinhAtu][nHRFIM] > TV1->TV1_HREXF ) .Or. ( &( aColsUse )[nLinhAtu][nHRINI] < TV1->TV1_HREXI .Or. &( aColsUse )[nLinhAtu][nHRINI] > TV1->TV1_HREXF) )
		If !lPodeMaior
			lShowMsg := .T.
		ElseIf ( ( &( aColsUse )[nLinhAtu][nHRINI] > &( aColsUse )[nLinhAtu][nHRFIM] ) .And. ( &( aColsUse )[nLinhAtu][nHRINI] < M->TV1_HRINI ) ) .Or.;
			( ( &( aColsUse )[nLinhAtu][nHRINI] > &( aColsUse )[nLinhAtu][nHRFIM] ) .And. ( &( aColsUse )[nLinhAtu][nHRFIM] > M->TV1_HRFIM ) .And. ( &( aColsUse )[nLinhAtu][nHRINI] >= TV1->TV1_HREXI ) ) .Or. ;
			( ( &( aColsUse )[nLinhAtu][nHRFIM] > TV1->TV1_HREXF ) .And. ( &( aColsUse )[nLinhAtu][nHRINI] < TV1->TV1_HREXI ) )
			lShowMsg := .T.
		Endif
	EndIF

	If lShowMsg
		If lHlpVisual
			If !MsgYesNo(STR0036 + CRLF + "Confirma inclusão?", STR0006) //"Lançamento está fora do turno previsto." ## "Confirma inclusão?" ## "ATENÇÃO"
				aHelpVld := {""}
			Endif
		Else
			aHelpVld := {"99", STR0036} // "Lançamento está fora do turno previsto."
		Endif
	Endif

Return aHelpVld

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT851CHG
Evento Change da GetDados

@author Marcos Wagner Junior
@since 24/06/2010
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MNT851CHG()

	Local nI          := 0
	Local _cMaxHorFim := ''

	If M->TV1_HRINI < M->TV1_HRFIM

		If ValType( nHRINI ) == 'N'
			If Empty( oGet:aCols[oGet:nAt][nHRINI] ) .Or. AllTrim( oGet:aCols[oGet:nAt][nHRINI] ) == ':'
				For nI := 1 To Len( oGet:aCols )
					If !oGet:aCols[nI][Len( aCols[nI] )] .And. oGet:nAt != nI
						If Empty( _cMaxHorFim ) .Or. oGet:aCols[nI][nHRFIM] > _cMaxHorFim
							_cMaxHorFim := oGet:aCols[nI][nHRFIM]
						EndIf
					EndIf
				Next nI
				If !Empty( _cMaxHorFim )
					oGet:aCols[oGet:nAt][nHRINI] := _cMaxHorFim
				EndIf
			EndIf
		EndIf

	Else

		If ValType( nHRINI ) == 'N'
			If Empty( oGet:aCols[oGet:nAt][nHRINI] ) .Or. AllTrim( oGet:aCols[oGet:nAt][nHRINI] ) == ':'
				For nI := 1 To Len( oGet:aCols )
					If !oGet:aCols[nI][Len( oGet:aCols[nI] )] .And. oGet:nAt != nI
						_cMaxHorFim := oGet:aCols[nI][nHRFIM]
					EndIf
				Next nI

				If !Empty( _cMaxHorFim )
					oGet:aCols[oGet:nAt][nHRINI] := _cMaxHorFim
				EndIf
			EndIf
		EndIf

	EndIf

	oGet:oBrowse:Refresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} M851COMPLE
Verifica se o periodo nao eh complemento do dia anterior

@author Marcos Wagner Junior
@since 19/11/2010
@version P11
@return Boolean lRet: conforme validação
/*/
//---------------------------------------------------------------------
Static Function M851COMPLE( _nDiaAtual )

	Local lRet         := .F.
	Local nDiaAnterior := If( nDiaSemana > 2,nDiaSemana - 1,7 )
	Local nUlturnoAnt

	nUlturnoAnt := Len( aDiasSH7[nDiaAnterior][2] )

	If nUlturnoAnt <> 0
		If ( aDiasSH7[nDiaAnterior][2][nUlturnoAnt][2] == '24:00' .And. Len( aDiasSH7[nDiaSemana][2] ) == 1 )
			lRet := .T.
		EndIf
	EndIf

Return .F.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA851SB
Validacao de Data/Hora da Parte Diaria

@param Boolean lVerAtiv: Opcional, indica se é para verificar as atividades
						 default é .F. : não verifica as atividades.
@param Array aTQ2s: Condicional, Define o array com as transferências do Bem
					*Obrigatório se o parametro lVerAtiv for .T.
@author Wagner S. de Lacerda
@since 24/05/2011
@version P11
@return Boolean true or false: conforme validação
/*/
//---------------------------------------------------------------------
Static Function MNTA851SB( lVerAtiv,aTQ2s )

	Local cMsgHlp  := ""
	Local aHelpVld := {}

	Local aTransfs := {}
	Local cCodBem
	Local dData
	Local cHrIni
	Local cHrFim
	Local lShowMsg

	Local nX
	Local nPos

	Default lVerAtiv := .F.
	Default aTQ2s    := {}

	cCodBem := M->TV1_CODBEM
	dData   := M->TV1_DTSERV
	cHrIni  := M->TV1_HRINI
	cHrFim  := M->TV1_HRFIM

	If Len( aTQ2s ) == 0

		If ExistBlock( "MNTA851A" )
			aTransfs := ExecBlock( "MNTA851A",.F.,.F.,{ cCodBem, dData } )
		Else
			aTransfs := MNTA851TRF( cCodBem,dData )
		EndIf

	Else
		aTransfs := aClone( aTQ2s )
	EndIf

	If lVerAtiv .And. lHlpVisual
		For nX := 1 To Len( oGet:aCols )
			//Recebe a MENOR Hora Inicial
			If !aTail( oGet:aCols[nX]) .And. !Empty( oGet:aCols[nX][nHRINI] ) .And. oGet:aCols[nX][nHRINI] < cHrIni
				cHrIni := oGet:aCols[nX][nHRINI]
			EndIf

			// Recebe a MAIOR Hora Final
			If !aTail( oGet:aCols[nX] ) .And. !Empty( oGet:aCols[nX][nHRFIM] ) .And. oGet:aCols[nX][nHRFIM] > cHrFim
				cHrFim := oGet:aCols[nX][nHRFIM]
			EndIf
		Next nX
	EndIf

	//----------------------------------
	// Estrutura de aTransfs
	// [x][1] - Empresa
	// [x][2] - Filial
	// [x][3] - Data Inicial do bem na empresa/filial
	// [x][4] - Hora Inicial do bem na empresa/filial
	// [x][5] - Data Final do bem na empresa/filial
	// [x][6] - Hora Final do bem na empresa/filial
	//----------------------------------

	lShowMsg := .F.

	// Se o bem possuir Transferencias ate a Data
	If Len( aTransfs ) > 0

		// Busca ENTRADAS em branco
		//-----------------------------------------------------------------------------------------------------------------------------------------------
		// Procura por transferencia onde empresa+filial seja igual a empresa atual + filial atual e data inicial esteja vazia
		// e ( data do serviço seja menor que data final do bem na empresa ou ( data serviço seja igual a data final do bem na empresa e maior hora fim
		// das atividades seja menor ou igual a hora final do bem na empresa )
		//-----------------------------------------------------------------------------------------------------------------------------------------------
		nPos := aScan( aTransfs,{ |x| x[1] + x[2] == cEmpAnt + cFilAnt .And. Empty( x[3] ) .And. ( dData < x[5]  .Or. ( dData == x[5] .And. cHrFim <= x[6] ) ) } )
		If nPos > 0 // ENTRADA em branco siginifica que o Bem estava originalmente naquela Empresa/Filial
			Return If( lVerAtiv, {}, MNTA851SB( .T., aTransfs ) ) // Retorna .T. se as atividades tambem estiverem OK
		EndIf

		If !lShowMsg
			// Busca SAIDAS em branco
			nPos := aScan( aTransfs,{ |x| x[1] + x[2] == cEmpAnt + cFilAnt .And. Empty( x[5] ) .And. ( dData > x[3] .Or. ( dData == x[3] .And. cHrIni >= x[4] ) ) } )
			If nPos > 0 // SAIDA em branco siginifica que o Bem ainda se encontra naquela Empresa/Filial
				Return If( lVerAtiv, {}, MNTA851SB( .T., aTransfs ) ) // Retorna .T. se as atividades tambem estiverem OK
			EndIf
		EndIf

		If !lShowMsg
			// Busca o PERIODO em que o Bem estava na Empresa/Filial
			nPos := aScan( aTransfs,{ |x| x[1] + x[2] == cEmpAnt + cFilAnt .And. ( ( dData > x[3] .And. dData < x[5] ) .Or. ( dData == x[3] .And. cHrIni >= x[4] ) .Or. ( dData == x[5] .And. cHrFim <= x[6] ) ) } )
			If nPos > 0
				Return If( lVerAtiv, {}, MNTA851SB( .T., aTransfs ) ) // Retorna .T. se as atividades tambem estiverem OK
			Else
				lShowMsg := .T.
			EndIf
		EndIf

	Else //Se o Bem nao possui Transferencias, apenas valida se o Bem esta Inativo ou Transferido

		dbSelectArea( "ST9" )
		dbSetOrder( 1 ) // T9_FILIAL+T9_CODBEM
		If dbSeek( xFilial( "ST9" ) + cCodBem )

			If ST9->T9_SITBEM == "T"
				cMsgHlp := "Equipamento Transferido."

				If lHlpVisual
					If !MsgYesNo(cMsgHlp + "'" + Chr(13) + Chr(10) + ;
										STR0047, STR0002) //"Confirmar?"###"Atenção"
						aHelpVld := {""}
					EndIf
				Else
					aHelpVld := {"05", cMsgHlp }
				Endif

			ElseIf ST9->T9_SITBEM == "I"
				cMsgHlp := "Equipamento Inativo."

				If lHlpVisual
					If !MsgYesNo(cMsgHlp + "'" + Chr(13) + Chr(10) + ;
										STR0049, STR0002) //"Confirmar?"###"Atenção"
						aHelpVld := {""}
					EndIf
				Else
					aHelpVld := {"04", cMsgHlp }
				Endif

			EndIf
		EndIf

	EndIf

	If lShowMsg
		If !lVerAtiv
			aHelpVld := {""}

			If lHlpVisual
				ShowHelpDlg( STR0050,; //"Data/Hora Inválida"
								{ STR0051+; //"A data/hora é inválida, pois o Bem está ou estava em"
								STR0052 },2,; //" outra Empresa/Filial."
								{ STR0053+; //"Insira uma data/hora em que o Bem se encontra na"
								STR0054 },3 ) //" Empresa/Filial atual. "
			Else
				aHelpVld := {"99", STR0051+STR0052, STR0053+STR0054, STR0050}
			Endif
		Else
			If lHlpVisual
				ShowHelpDlg( STR0055,; //"Atividade Inválida"
								{ STR0056+; //"A hora da atividade é inválida, pois o Bem está ou"
								STR0057 },2,; //" estava em outra Empresa/Filial."
								{ STR0058+; //"Insira uma hora inicial/final em que o Bem se"
								STR0059 },3 ) //" encontra na Empresa/Filial atual. "
			Else
				aHelpVld := {"99", STR0056+STR0057, STR0058+STR0059, STR0055}
			Endif
		EndIf

		Return If( IsInCallStack( "MNTA851GR" ), aHelpVld, {} )
	EndIf

Return aHelpVld

//---------------------------------------------------------------------
/*/{Protheus.doc} ATUHRAEXP
Atualiza o campo "Hora Exped."

@author Marcos Wagner Junior
@since 24/06/2010
@version P11
@return Boolean true.
/*/
//---------------------------------------------------------------------
Static Function ATUHRAEXP( _nLinha,nHraIni,nHraFim )

	Local nI
	Local nHrsDisp := 0

	Local _cHraMin := "", _cHraMax := ""

	Local aColsUse   := {}
	Local aHeaderUse := {}

	If IsInCallStack("MNTI851")
		Return
	Endif
	aColsUse   := If ( IsInCallStack( "MNTI851" ),"aCols","oGet:aCols" )
	aHeaderUse := If ( IsInCallStack( "MNTI851" ),"aHeader","oGet:aHeader" )

	_cHraMin := M->TV1_HREXI
	_cHraMax := M->TV1_HREXF

	//Verifica os Horarios do Cabecalho
	If M->TV1_HRINI < _cHraMin
		_cHraMin := M->TV1_HRINI
	EndIf

	If M->TV1_HRFIM > _cHraMax
		_cHraMax := M->TV1_HRFIM
	EndIf

	nHRINI := GDFIELDPOS( "TV2_HRINI",&( aHeaderUse ) )
	nHRFIM := GDFIELDPOS( "TV2_HRFIM",&( aHeaderUse ) )

	// Verifica os Horarios das Atividades
	For nI := 1 to Len( &( aColsUse ) )

		If nI == _nLinha
			nTV2_HRINI := nHraIni
			nTV2_HRFIM := nHraFim
		Else
			nTV2_HRINI := &( aColsUse )[nI][nHRINI]
			nTV2_HRFIM := &( aColsUse )[nI][nHRFIM]
		EndIf

		If !&( aColsUse )[nI][Len( &( aColsUse )[nI] )] .And. !Empty( nTV2_HRINI ) .And. !Empty( nTV2_HRFIM )

			If M->TV1_HRINI < M->TV1_HRFIM
				If nTV2_HRINI < _cHraMin
					_cHraMin := nTV2_HRINI
				EndIf
				If nTV2_HRFIM > _cHraMax
					_cHraMax := nTV2_HRFIM
				EndIf
			Else
				If ( nTV2_HRINI < nTV2_HRFIM ) .And. ( nTV2_HRINI < M->TV1_HRINI ) .And. ( nTV2_HRFIM < M->TV1_HRINI )
					_cHraMax := nTV2_HRFIM
				Else
					If nTV2_HRINI < _cHraMin
						_cHraMin := nTV2_HRINI
					EndIf
				EndIf
			EndIf
		EndIf

	Next nI

	If !Empty( _cHraMax ) .And. !Empty( _cHraMin )
		If HTON( _cHraMax ) > HTON( _cHraMin )
			nHrsDisp := ( HTON( _cHraMax ) - HTON( _cHraMin ) )
		Else
			nHrsDisp := 24 - HTON( _cHraMin ) + HTON( _cHraMax )
		Endif
	Endif

	M->TV1_HRAEXP := NTOH( nHrsDisp )

	lRefresh := .T.

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT851CONT

@author Marcos Wagner Junior
@since 24/06/2010
@version P11
@return Boolean true or false: conforme validação.
/*/
//---------------------------------------------------------------------
Function MNT851CONT( _nLinhaAtu,_cConAti,_cConIni,_cConFim )

	Local nCONTA
	Local nHrIni
	Local cVarHrAti
	Local nI

	Local _nMaior   := 0
	Local _nMenor   := 0
	Local lWebFleet := .F.
	Local cWebFleet := ""
	Local nWebFleet := 0
	Local aHelpVld  := {}

	Local aColsUse   := If ( IsInCallStack( "MNTI851" ),"aCols","oGet:aCols" )
	Local aHeaderUse := If ( IsInCallStack( "MNTI851" ),"aHeader","oGet:aHeader" )

	// Controle para não validar hora do contador da Atividade caso seja turno quebrado
	Local lTurnoQbr  := ( M->TV1_HRINI > M->TV1_HRFIM )

	nHRINI := GDFIELDPOS( "TV2_HRINI",&( aHeaderUse ) )
	nCONTA := GDFIELDPOS( "TV2_CONTAD",&( aHeaderUse ) )

	cVarHrAti := aColsUse+"[" + AllTrim( STR( _nLinhaAtu ) ) + "][" + AllTrim( STR( nHRINI ) ) + "]"

	nWebFleet := GDFIELDPOS( "TV2_WEBFLE",&( aHeaderUse ) )

	If nWebFleet > 0
		cWebFleet := aColsUse+"[" + AllTrim( STR( _nLinhaAtu ) ) + "][" + AllTrim( STR( nWebFleet ) ) + "]"
		lWebFleet := ( AllTrim( &( cWebFleet ) ) == "S" )
	EndIf

	If _cConAti < _cConIni .Or. _cConAti > _cConFim

		If lWebFleet .Or. ( !lWebFleet .And. !Empty( _cConAti ) )
			aHelpVld := {"99",STR0060} // "O 'Contador At.' deverá estar entre o intervalo do 'Contador In.' e 'Contador Fim'!"
			Return aHelpVld
		EndIf

	EndIf

	If  lWebFleet .Or. ( !lWebFleet .And. !Empty( _cConAti ) )
		For nI := 1 To Len( &( aColsUse ) )

			If _nLinhaAtu != nI .And. &( aColsUse )[nI][nCONTA] <> 0 .And. !&( aColsUse )[nI][Len( &( aHeaderUse ) ) + 1] .And. !&( aColsUse )[_nLinhaAtu][Len( &( aHeaderUse ) ) + 1]
				If &( cVarHrAti ) > &( aColsUse )[nI][nHrIni] // Se a hora da atividade atual for maior que a hora verificada (outra linha)
					If _cConAti < &( aColsUse )[nI][nCONTA] // Contador menor que o da linha verificada
						If !lTurnoQbr .And. ( _nMaior == 0 .Or. _nMaior < &( aColsUse )[nI][nCONTA] )
							_nMaior := &( aColsUse )[nI][nCONTA]
						EndIf
					EndIf
				ElseIf &( cVarHrAti ) < &( aColsUse )[nI][nHrIni] // Se a hora da atividade atual for menor que a hora verificada (outra linha)
					If _cConAti > &( aColsUse )[nI][nCONTA] // Contador maior que o da linha verificada
						If !lTurnoQbr .And. ( _nMenor == 0 .Or. _nMenor > &( aColsUse )[nI][nCONTA] )
							_nMenor := &( aColsUse )[nI][nCONTA]
						EndIf
					EndIf
				EndIf
			EndIf

		Next nI
	EndIf

	If _nMenor <> 0 .Or. _nMaior <> 0
		aHelpVld := {"99",STR0062} // "O contador deverá ser condizente com a ordem do apontamento das atividades."
		Return aHelpVld
	EndIf


Return aHelpVld

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA851TRF
Retorna transferências do bem até a data informada no parametro
dData.

@param String cCodBem: Bem para se verificar as transferencias
@param Date dData: data limite para verificar transferencias
@author André Felipe Joriatti
@since 03/07/2013
@version P11
@return Array aTransfs, estrutura:
	[x][1] - Empresa
	[x][2] - Filial
	[x][3] - Data Inicial do bem na empresa/filial
	[x][4] - Hora Inicial do bem na empresa/filial
	[x][5] - Data Final do bem na empresa/filial
	[x][6] - Hora Final do bem na empresa/filial
/*/
//---------------------------------------------------------------------
Static Function MNTA851TRF( cCodBem,dData )

	Local cOldEmp  := cEmpAnt
	Local cModoTQ2 := NGSX2MODO( "TQ2" )
	Local aEmpFil  := {}
	Local nPos
	Local nX
	Local nY
	Local nLen

	// Armazena atuais dos arquivos
	Local aAreaAtu := GetArea()
	Local aAreaTQ2 := TQ2->( GetArea() )
	Local aAreaSM0 := {}

	Local cEmprOrig
	Local cEmprDest
	Local cFiliOrig
	Local cFiliDest
	Local dDataTrsf
	Local cHoraTrsf
	Local lEncontrou

	Local cEmpresaX
	Local cFilialX

	Local aTabelas := { { "TQ2" } } //  Histórico de transferências do Bem
	Local aTransfs := {}
	Local aOrigem  := {}
	Local aDestino := {}
	Local aTrs     := {}

	// Busca empresas e filiais
	dbSelectArea( "SM0" )
	aAreaSM0 := GetArea()

	// Para futura implementação que dê suporte a transferências de bens entre empresas
	/*DbGoTop()

	While !EoF()

		If cModoTQ2 == "C"
			nPos := aScan( aEmpFil,{ |x| x[1] == SM0->M0_CODIGO } )
			If nPos == 0
				aAdd( aEmpFil,{ SM0->M0_CODIGO,{ If( Empty( SM0->M0_SIZEFIL ), Space( Len( SM0->M0_CODIGO ) ),Space( SM0->M0_SIZEFIL ) ) } } )
			EndIf
		Else
			nPos := aScan( aEmpFil,{ |x| x[1] == SM0->M0_CODIGO } )
			If nPos == 0
				aAdd( aEmpFil,{ SM0->M0_CODIGO,{ SM0->M0_CODFIL } } )
			Else
				aAdd( aEmpFil[nPos][2],SM0->M0_CODFIL )
			EndIf
		EndIf

		dbSelectArea( "SM0" )
		dbSkip()

	End While*/

	//----------------------------------------------------
	// Suporta apenas transferência de bens entre Filiais
	//----------------------------------------------------
	dbSeek( PadR( cEmpAnt,Len( SM0->M0_CODIGO ) ) )
	While !EoF() .And. SM0->M0_CODIGO == PadR( cEmpAnt,Len( SM0->M0_CODIGO ) )

		If cModoTQ2 == "C"
			nPos := aScan( aEmpFil,{ |x| x[1] == SM0->M0_CODIGO } )
			If nPos == 0
				aAdd( aEmpFil,{ SM0->M0_CODIGO,{ If( Empty( SM0->M0_SIZEFIL ), Space( Len( SM0->M0_CODIGO ) ),Space( SM0->M0_SIZEFIL ) ) } } )
			EndIf
		Else
			nPos := aScan( aEmpFil,{ |x| x[1] == SM0->M0_CODIGO } )
			If nPos == 0
				aAdd( aEmpFil,{ SM0->M0_CODIGO,{ SM0->M0_CODFIL } } )
			Else
				aAdd( aEmpFil[nPos][2],SM0->M0_CODFIL )
			EndIf
		EndIf

		dbSelectArea( "SM0" )
		dbSkip()

	End While

	RestArea( aAreaSM0 )

	// Recupera as transferencias do Bem em todas as empresas
	aTrs := {}
	For nX := 1 To Len( aEmpFil )
		NGPrepTbl( aTabelas,aEmpFil[nX][1] )

		For nY := 1 To Len( aEmpFil[nX][2] )

			lEncontrou := .F.

			dDataTrsf := CTOD( "  /  /    " )
			cHoraTrsf := ""

			cEmprOrig := ""
			cFiliOrig := ""
			cEmprDest := ""
			cFiliDest := ""

			dbSelectArea( "TQ2" )
			dbSetOrder( 02 ) // TQ2_FILIAL+TQ2_CODBEM+TQ2_STATUS+DTOS(TQ2_DATATR)+TQ2_HORATR
			If dbSeek( aEmpFil[nX][2][nY] + cCodBem )
				While !EoF() .And. TQ2->TQ2_FILIAL == PadR( aEmpFil[nX][2][nY],Len( TQ2->TQ2_FILIAL ) ) .And. TQ2->TQ2_CODBEM == PadR( cCodBem,Len( TQ2->TQ2_CODBEM ) )

					// If TQ2->TQ2_DATATR <= dDataBase // Considera Transferencias ate e data informada
					If TQ2->TQ2_DATATR <= dData

						dDataTrsf := TQ2->TQ2_DATATR
						cHoraTrsf := TQ2->TQ2_HORATR

						// cEmprOrig := TQ2->TQ2_EMPORI // Para implementação de transferencia de bens entre empresas
						cEmprOrig := cEmpAnt
						cFiliOrig := TQ2->TQ2_FILORI
						// cEmprDest := TQ2->TQ2_EMPDES // Para implementação de transferencia de bens entre empresas
						cEmprDest := cEmpAnt
						cFiliDest := TQ2->TQ2_FILDES

						// Empresa Origem; Filial Origem; Empresa Destino; Filial Destino; Data da Transferencia; Hora da Transferencia
						aAdd( aTrs,{ cEmprOrig,cFiliOrig,cEmprDest,cFiliDest,dDataTrsf,cHoraTrsf } )

					EndIf

					dbSelectArea( "TQ2" )
					dbSkip()

				End While
			EndIf
		Next nY

	Next nX

	// Busca os periodos
	aTransfs := {}
	aOrigem  := {}
	aDestino := {}

	aSort( aTrs,,,{ |x,y| DTOC( x[5] ) + x[6] < DTOC( y[5] ) + y[6] } )

	For nX := 1 To Len( aTrs )
		aAdd( aOrigem ,{ aTrs[nX][1],aTrs[nX][2],aTrs[nX][5],aTrs[nX][6] } ) // SAIDAS
		aAdd( aDestino,{ aTrs[nX][3],aTrs[nX][4],aTrs[nX][5],aTrs[nX][6] } ) // ENTRADAS
	Next nX

	// Organiza os Periodos
	// Array: Empresa; Filial; Data Inicio; Hora Inicio; Data Fim; Hora Fim;
	aTransfs := {}

	If Len( aOrigem ) > 0

		// A primeira SAIDA identifica o proprietario original do Bem
		aAdd( aTransfs,{ aOrigem[1][1],aOrigem[1][2],CTOD( "  /  /    " ),"",aOrigem[1][3],aOrigem[1][4] } )

		For nX := 1 To Len( aDestino )

			cEmpresaX := aDestino[nX][1]
			cFilialX  := aDestino[nX][2]

			aAdd( aTransfs,{ cEmpresaX,cFilialX,aDestino[nX][3],aDestino[nX][4],CTOD( "  /  /    " ),"" } )

			nLen := Len( aTransfs )

			nPos := aScan( aOrigem,{ |x| x[1] + x[2] == cEmpresaX + cFilialX .And. ( x[3] > aTransfs[nLen][3] .Or. ( x[3] == aTransfs[nLen][3] .And. x[4] >= aTransfs[nLen][4] ) ) } )

			If nPos > 0
				aTransfs[nLen][5] := aOrigem[nPos][3]
				aTransfs[nLen][6] := aOrigem[nPos][4]
			EndIf

		Next nX

	EndIf

	//Devolve as tabelas para a Empresa Original
	NGPrepTbl( aTabelas,cOldEmp )

	// Restaura areas iniciais
	RestArea( aAreaTQ2 )
	RestArea( aAreaAtu )

Return aTransfs

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT851VLCP
Validacoes de campos.

@variable lHlpVisual Indica se a validacao esta sendo efetuada em tela,
                  necessitando a apresentacao de help.
                  .T. Help será apresentado. [Default]
                  .F. Nao fara apresentacao de help, o mesmo sera repassado
                      no array de retorno.

@author Hugo R. Pereira
@since 26/06/2013
@version P11
/*/
//---------------------------------------------------------------------
Function MNT851VLCP(cCampo, lShowHlp)

	Default cCampo   := ""
	Default lShowHlp := .T.

	Private lHlpVisual  := !IsInCallStack("MNTI851")
	Private aHlpVld  := {}

	If Empty(cCampo)
		Return If(lShowHlp, Empty(aHlpVld), aHlpVld)
	Endif

	cCampo := Upper(AllTrim(cCampo))

	If cCampo == "TV1_CODBEM"

		MNT851VLBM()

	ElseIf cCampo == "TV1_PLACA"

		MNT851VLPL()

	ElseIf cCampo == "TV1_TURNO"

		MNT851VLTR()

	ElseIf cCampo == "TV1_DTSERV"

		MNT851VLDS()

	ElseIf cCampo == "TV1_HRINI"

		MNT851VLHI()

	ElseIf cCampo == "TV1_CONINI"

		MNT851VLCI()

	ElseIf cCampo == "TV1_HRFIM"

		MNT851VLHF()

	ElseIf cCampo == "TV1_CONFIM"

		MNT851VLCF()

	ElseIf cCampo == "TV1_TERCEI"

		MNT851VLTE()

	ElseIf cCampo == "TV1_OPERAD"

		MNT851VLOP()

	Endif

	If lShowHlp .And. !Empty(aHlpVld)
		ShowHlpVld(aHlpVld)
	Endif

Return If(lShowHlp, Empty(aHlpVld), aHlpVld)

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT851VLBM
Efetua validacao do bem.

@author Hugo R. Pereira
@since 26/06/2013
@version P11
/*/
//---------------------------------------------------------------------
Static Function MNT851VLBM()

	Local aHelpVld := {}

	ExistCpGen( "ST9", M->TV1_CODBEM, 16, { "03", "Equipamento não cadastrado." } )

	If Empty(aHlpVld)
		aHelpVld := MNTA851BEM()
		SetHelpRet( aHelpVld )
	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT851VLPL
Efetua validacao do bem.

@author Hugo R. Pereira
@since 26/06/2013
@version P11
/*/
//---------------------------------------------------------------------
Static Function MNT851VLPL()

	Local aHelpVld := {}

	aHelpVld := MNTA851PLA()
	SetHelpRet( aHelpVld )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT851VLTR
Efetua validacao do bem.

@author Hugo R. Pereira
@since 26/06/2013
@version P11
/*/
//---------------------------------------------------------------------
Static Function MNT851VLTR()

	Local aHelpVld := {}

	ExistCpGen( "SH7", M->TV1_TURNO, 1, { "06", "Turno não cadastrado." } )

	If Empty(aHlpVld)
		ExistChGen("TV1", M->TV1_CODBEM+DTOS(M->TV1_DTSERV)+M->TV1_TURNO, 1, { "99", "Chave ja cadastrada" })
	Endif

	// Atualiza variaveis de memoria (tela) referente ao turno
	If Empty(aHlpVld)
		aHelpVld := MNT851CALE()
		SetHelpRet( aHelpVld )
	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT851VLDS
Efetua validacao do bem.

@author Hugo R. Pereira
@since 26/06/2013
@version P11
/*/
//---------------------------------------------------------------------
Static Function MNT851VLDS()

	Local aHelpVld := {}

	aHelpVld := MNT851VLDT()
	SetHelpRet( aHelpVld )

	If Empty(aHlpVld)
		aHelpVld := MNT851VLHR()
		SetHelpRet( aHelpVld )
	Endif

	If Empty(aHlpVld)
		aHelpVld := MNTA851SB()
		SetHelpRet( aHelpVld )
	Endif

	If Empty(aHlpVld) .And. !VALDT(M->TV1_DTSERV)
		aHlpVld := If(lHlpVisual, {""}, {"99", "A data não deve ser maior que a data atual"} )
	Endif

	If Empty(aHlpVld)
		aHelpVld := MNT851CALE()
		SetHelpRet( aHelpVld )
	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT851VLHI
Efetua validacao do bem.

@author Hugo R. Pereira
@since 26/06/2013
@version P11
/*/
//---------------------------------------------------------------------
Static Function MNT851VLHI()

	Local aHelpVld := {}

	aHelpVld := MNTA851HR(1,'M->TV1_HRINI')
	SetHelpRet( aHelpVld )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT851VLCI
Efetua validacao do bem.

@author Hugo R. Pereira
@since 26/06/2013
@version P11
/*/
//---------------------------------------------------------------------
Static Function MNT851VLCI()

	Local aHelpVld := {}

	aHelpVld := MNTA851CON(1)
	SetHelpRet( aHelpVld )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT851VLHF
Efetua validacao do bem.

@author Hugo R. Pereira
@since 26/06/2013
@version P11
/*/
//---------------------------------------------------------------------
Static Function MNT851VLHF()

	Local aHelpVld := {}

	aHelpVld := MNTA851HR(2,'M->TV1_HRFIM')
	SetHelpRet( aHelpVld )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT851VLCF
Efetua validacao do bem.

@author Hugo R. Pereira
@since 26/06/2013
@version P11
/*/
//---------------------------------------------------------------------
Static Function MNT851VLCF()

	Local aHelpVld := {}

	aHelpVld := MNTA851CON(2)
	SetHelpRet( aHelpVld )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT851VLTE
Efetua validacao do bem.

@author Hugo R. Pereira
@since 26/06/2013
@version P11
/*/
//---------------------------------------------------------------------
Static Function MNT851VLTE()

	PertenGen("12", M->TV1_TERCEI, "TV1_TERCEI")

	If Empty(aHlpVld)
		MNTA851TER()
	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT851VLOP
Efetua validacao do bem.

@author Hugo R. Pereira
@since 26/06/2013
@version P11
/*/
//---------------------------------------------------------------------
Static Function MNT851VLOP()

	If lHlpVisual
		If !MNTA851OPE()
			SetHelpRet( {""} )
		Endif
	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ExistCpGen
Valida existencia de conteudo. ExistCpo generico.
Trata retorno conforme visualizacao.

@param cAlias Tabela a ser verificada.
@param cSeek  Chave de pesquisa.
@param nOrder Ordenacao
@param aHelp  Array contendo help.

@author Hugo R. Pereira
@since 26/06/2013
@version P11
/*/
//---------------------------------------------------------------------
Static Function ExistCpGen(cAlias, cSeek, nOrder, aHelp)

	Local lFound := .T.

	Default aHelp  := {}

	lFound := ExistCpo(cAlias, cSeek, nOrder)

	If !lFound .And. !Empty(aHelp)
		aHlpVld := If(lHlpVisual, {""}, aClone(aHelp) )
	Endif

Return lFound

//---------------------------------------------------------------------
/*/{Protheus.doc} ExistChGen
Valida existencia de chave. ExistChav generico.
Trata retorno conforme visualizacao.

@param cAlias Tabela a ser verificada.
@param cSeek  Chave de pesquisa.
@param nOrder Ordenacao

@author Hugo R. Pereira
@since 26/06/2013
@version P11
/*/
//---------------------------------------------------------------------
Static Function ExistChGen(cAlias, cSeek, nOrder, aHelp)

	Local lChaveOK := .T.

	Default nOrder := 1
	Default aHelp  := {}

	lChaveOK := ExistChav(cAlias, cSeek, nOrder)

	If !lChaveOK .And. !Empty(aHelp)
		aHlpVld := If(lHlpVisual, {""}, aClone(aHelp) )
	Endif

Return lChaveOK

//---------------------------------------------------------------------
/*/{Protheus.doc} PertenGen
Valida existencia de conteudo. Pertence generico.
Trata retorno conforme visualizacao.

@param cCompare Termo a ser comparado com valor.
@param cValue   Valor a ser avaliado.
@param cCampo   Campo referenciado.

@author Hugo R. Pereira
@since 26/06/2013
@version P11
/*/
//---------------------------------------------------------------------
Static Function PertenGen(cCompare, cValue, cCampo)

	Local lPertence := .T.

	lPertence := Pertence(cCompare)

	If !lPertence
		aHlpVld := { "99", "Campo '" + NGRetTitulo(cCampo) + "' inválido." }
	Endif

Return lPertence

//---------------------------------------------------------------------
/*/{Protheus.doc} SetHelpRet
Define conteudo de help.

@param aHelpVld Array de Helps.

@author Hugo R. Pereira
@since 26/06/2013
@version P11
/*/
//---------------------------------------------------------------------
Static Function SetHelpRet(aHelpVld)

	/*
	For nHlp := 1 To Len(aHelpVld)
		aAdd( aHlpVld, aClone(aHelpVld[nHlp]) )
	Next nHlp
	*/

	If !Empty(aHelpVld)
		aHlpVld := aClone(aHelpVld)
	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ShowHlpVld
Apresenta mensagem de tela conforme array repassado.

@param aHelpVld Array contendo help a ser apresentado.
                [1] Problema
                [2] Solucao
                [3] Titulo
@author Hugo R. Pereira
@since 26/06/2013
@version P11
/*/
//---------------------------------------------------------------------
Static Function ShowHlpVld(aHelpVld)

	Local nHlp := Len(aHelpVld)

	If nHlp > 0 .And. !Empty(aHelpVld[1])
		ShowHelpDlg(	  If( nHlp >= 4, aHelpVld[4], STR0002 )    	,; // "Atenção"
							{ If( nHlp >= 2, aHelpVld[2], ""      ) },2	,;
							{ If( nHlp >= 3, aHelpVld[3], ""      ) },2 )
	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT851VLDT
Efetua validacao da data repassada.

@param dData   Data a ser validada.

@author Hugo R. Pereira
@since 26/06/2013
@version P11
/*/
//---------------------------------------------------------------------
Static Function MNT851VLDT(dData)

	Local aHelpVld := {}

	Default dData      := M->TV1_DTSERV

	If ValType(dData) <> "D" .Or. Empty(dData) .Or. dData == CToD("")
		If lHlpVisual
			aHelpVld := {	STR0037,; // "Data Inválida"
								STR0039 } // "Verifique se informou corretamente a data."
		Else
			aHelpVld := { "07", "Data de Início inválida." }
		Endif
	Endif

Return If( IsInCallStack( "MNTA851GR" ) .Or. IsInCallStack( "MNT852VLGR" ), aHelpVld, {} )

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT851VLHR
Efetua validacao da hora repassada.

@param cHora   Hora a ser validada.
@param lHlpVisual Indica se a validacao esta sendo efetuada em tela,
               necessitando a apresentacao de help.
               .T. Help será apresentado. [Default]
               .F. Nao fara apresentacao de help, o mesmo sera repassado
                   no array de retorno.

@author Hugo R. Pereira
@since 26/06/2013
@version P11
/*/
//---------------------------------------------------------------------
Static Function MNT851VLHR(aHora)

	Local aHelpVld := {}
	Local nHora

	Default aHora := { {M->TV1_HRINI, "Hora de Início inválida."}, {M->TV1_HRFIM, "Hora Final inválida."} }

	For nHora := 1 To Len(aHora)
		If Empty(aHora[nHora][1]) .Or. AllTrim(aHora[nHora][1]) == ":" .Or. !NGVALHORA(aHora[nHora][1],.F.)
			If lHlpVisual
				aHelpVld := { "07",	aHora[nHora][2],; // "Hora Inválida"
											STR0042 } 			 // "Verifique se informou corretamente a hora."
			Else
				aHelpVld := { "07", aHora[nHora][2] }
			Endif

		Endif
	Next nHora

Return If( IsInCallStack( "MNTA851GR" ), aHelpVld, {} )

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT851VLGD
Validacoes de campos GetDados. [TV2]

@variable lHlpVisual Indica se a validacao esta sendo efetuada em tela,
                  necessitando a apresentacao de help.
                  .T. Help será apresentado. [Default]
                  .F. Nao fara apresentacao de help, o mesmo sera repassado
                      no array de retorno.

@author Hugo R. Pereira
@since 26/06/2013
@version P11
/*/
//---------------------------------------------------------------------
Function MNT851VLGD(cCampo,lRetLgc)

	Default cCampo  := ""
	Default lRetLgc := .T.

	If Empty(cCampo)
		Return .T.
	Endif

	Private lHlpVisual := !IsInCallStack("MNTI851")
	Private aHlpVld    := {}

	cCampo := Upper(AllTrim(cCampo))

	If cCampo == "TV2_CODATI"

		MNT851VGAT()

	ElseIf cCampo == "TV2_HRINI"

		MNT851VGHI()

	ElseIf cCampo == "TV2_HRFIM"

		MNT851VGHF()

	ElseIf cCampo == "TV2_CODFRE"

		MNT851VGFR()

	ElseIf cCampo == "TV2_CONTAD"

		MNT851VGCT()

	Endif

	If lHlpVisual .And. !Empty(aHlpVld)
		ShowHlpVld(aHlpVld)
	Endif

Return If(lRetLgc, Empty(aHlpVld), aHlpVld)

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT851VGAT
Efetua validacao da data repassada.

@param dData   Data a ser validada.

@author Hugo R. Pereira
@since 26/06/2013
@version P11
/*/
//---------------------------------------------------------------------
Static Function MNT851VGAT()

	ExistCpGen("TV0", M->TV2_CODATI, 1, { "19", "Atividade não Cadastrada." })

	If Empty(aHlpVld) .And. lHlpVisual
		MNTA851TOT()
	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT851VGHI
Efetua validacao da data repassada.

@param dData   Data a ser validada.

@author Hugo R. Pereira
@since 26/06/2013
@version P11
/*/
//---------------------------------------------------------------------
Static Function MNT851VGHI()

	Local aHelpVld := {}

	aHelpVld := MNTA851HR(3,'M->TV2_HRINI')
	SetHelpRet( aHelpVld )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT851VGHF
Efetua validacao da data repassada.

@param dData   Data a ser validada.

@author Hugo R. Pereira
@since 26/06/2013
@version P11
/*/
//---------------------------------------------------------------------
Static Function MNT851VGHF

	Local aHelpVld := {}

	aHelpVld := MNTA851HR(4,'M->TV2_HRFIM')
	SetHelpRet( aHelpVld )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT851VGFR
Efetua validacao da data repassada.

@param dData   Data a ser validada.

@author Hugo R. Pereira
@since 26/06/2013
@version P11
/*/
//---------------------------------------------------------------------
Static Function MNT851VGFR()
	ExistCpGen( "CTT",M->TV2_CODFRE,1,{ "99", "Centro de Custo da Frente de Trabalho inválido." } )
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT851VGCT
Efetua validacao da data repassada.

@param dData   Data a ser validada.

@author Hugo R. Pereira
@since 26/06/2013
@version P11
/*/
//---------------------------------------------------------------------
Static Function MNT851VGCT

	Local aHelpVld := {}

	aHelpVld := MNTA851CON(3)
	SetHelpRet( aHelpVld )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT851PVAR
Efetua validacao da data repassada.

@author Hugo R. Pereira
@since 26/06/2013
@version P11
/*/
//---------------------------------------------------------------------
Function MNT851PVAR()

	_SetOwnerPrvt("lPodeMaior", .F. )
	_SetOwnerPrvt("nCodAti"   , Nil )
	_SetOwnerPrvt("nCodFre"   , Nil )
	_SetOwnerPrvt("nHrIni"    , Nil )
	_SetOwnerPrvt("nHrFim"    , Nil )
	_SetOwnerPrvt("lHlpVisual", !IsInCallStack("MNTI851") )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Funcao de tratamento para o recebimento/envio de mensagem unica de
cadastro de atividades da parte diária.

@author Felipe Nathan Welter
@since 09/07/13
@version P11
@return aArray sendo [1]-.T./.F. e [2]-cError
/*/
//---------------------------------------------------------------------
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)

	aRet := MNTI851(cXml, nTypeTrans, cTypeMessage)

Return aRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fDefEmpFil
Verifica se a Empresa/Filial é valida antes da alteracao
do registro.

@author Wagner S. de Lacerda
@since 08/07/2011
@version P11
@return .T.
/*/
//---------------------------------------------------------------------

Static Function fDefEmpFil()

	Local oDlgDef
	Local oPnlBtn
	Local oPnlDef
	Local lDefOK, lErro

	lErro := ( !MNT851VLEF(,.F.) .Or. !MNT851VLEF(2,.F.) )
	If lErro
		MsgAlert("A Empresa/Filial é inválida. Favor corrigir estas informações primeiro.")
	Else
		Return .T.
	EndIf

	lDefOK := .F.
	DEFINE MSDIALOG oDlgDef TITLE cCadastro FROM 0,0 TO 100,400 COLOR CLR_BLACK, CLR_WHITE OF oMainWnd PIXEL

		//----------
		// Emp/Fil
		//----------
		oPnlDef := TPanel():New(01, 01, , oDlgDef, , , , CLR_BLACK, CLR_WHITE, 50, 15, .T., .T.)
		oPnlDef:Align := CONTROL_ALIGN_ALLCLIENT

			//Empresa
			@ 010,010 SAY OemToAnsi("Empresa:") FONT oFontBold COLOR CLR_BLACK OF oPnlDef PIXEL
			oGetEmpres := TGet():New(009, 050, {|u| __ReadVar := "cGetEmpres", If(PCount() > 0, cGetEmpres := u, cGetEmpres)}, oPnlDef, 040, 008, "", {|| MNT851VLEF()}, CLR_BLACK, CLR_WHITE, ,;
					 				.F., , .T./*lPixel*/, , .F., {|| Altera .And. ( M->TV1_INDERR == "1" ) }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "YM0", "cGetEmpres", , , , .T./*lHasButton*/)
			oGetEmpres:bHelp := {|| ShowHelpCpo("Empresa",;
							  				{"Selecione a empresa da Parte Diária."},2,;
							  		 		{"Deve estar cadastrada no sistema para utilização."},2)}

			//Filial
			@ 010,110 SAY OemToAnsi("Filial:") FONT oFontBold COLOR CLR_BLACK OF oPnlDef PIXEL
			oGetFilial := TGet():New(009, 150, {|u| __ReadVar := "cGetFilial", If(PCount() > 0, cGetFilial := u, cGetFilial)}, oPnlDef, 040, 008, "", {|| MNT851VLEF(2)}, CLR_BLACK, CLR_WHITE, ,;
					 				.F., , .T./*lPixel*/, , .F., {|| Altera .And. ( M->TV1_INDERR == "1" ) } /*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "SM0MOB", "cGetFilial", , , , .T./*lHasButton*/)
			oGetFilial:bHelp := {|| ShowHelpCpo("Filial",;
							  				{"Selecione a filial da empresa da Parte Diária."},2,;
							  		 		{"Deve pertencer a empresa selecionada."},2)}

		//--------
		// Botoes
		//--------
		oPnlBtn := TPanel():New(01, 01, , oDlgDef, , , , CLR_BLACK, CLR_WHITE, 50, 15, .T., .T.)
		oPnlBtn:Align := CONTROL_ALIGN_BOTTOM

			sButton():New(002, 010, 1, {|| lDefOK := .T., oDlgDef:End()}, oPnlBtn, .T.)
			sButton():New(002, 050, 2, {|| lDefOK := .F., oDlgDef:End()}, oPnlBtn, .T.)

	ACTIVATE MSDIALOG oDlgDef CENTERED

	If lDefOK
		lErro := ( !MNT851VLEF(,.F.) .Or. !MNT851VLEF(2,.F.) )
		If lErro
			MsgStop("A Empresa/Filial é inválida!","Atenção")
			// Devolve as Tabelas para a Empresa Atual
			NGPrepTbl(aPrepTbls,cOrigEmp,cOrigFil)
			Return .F.
		EndIf
	Else
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT851VLEF
Valida empresa/filial selecionada.

@param Integer nVld: Opcional;
Indica qual a validacao a executar:
1 - Empresa
2 - Filial (empresa + filial)
Default: 1 - Empresa.

@param lShowMsg -> Opcional.
Define se deve mostrar a mensagem em tela.
.T. -> Mostra a mensagem
.F. -> Nao mostra a mensagem
Default: .T. -> Mostra a mensagem

@author Wagner S. de Lacerda
@since 06/07/2011
@version P11
@return .T.
/*/
//---------------------------------------------------------------------

Function MNT851VLEF(nVld,lShowMsg)

	Local aAcesso := {}
	Local nAcesso := 0
	Local lAcesso := .F.

	Default nVld := 1
	Default lShowMsg := .T.

	aAcesso := aClone( fRetEFUAcces( ,.T. ) ) // aClone( OASRETEF(,.T.) )

	If nVld == 1 // Valida Empresa
		nAcesso := aScan(aAcesso, {|x| AllTrim(x[1]) == AllTrim(cGetEmpres) .Or. x[1] == "ALL" })
		lAcesso := ( nAcesso > 0 )
		lAcesso := .T.
		aVerRet := NGSEEKSM0(cGetEmpres,{"M0_NOME"})
		If !lAcesso .Or. Len(aVerRet) == 0
			If lShowMsg
				MsgStop("A Empresa é inválida.","Atenção")
			EndIf
			If IsInCallStack("MNTA851CAD") .Or. IsInCallStack("fDefEmpFil")
				Return .F.
			EndIf
		EndIf
	Else // Valida Filial
		nAcesso := aScan(aAcesso, {|x| AllTrim(x[1])+AllTrim(x[2]) == AllTrim(cGetEmpres)+AllTrim(cGetFilial) .Or. x[1] == "ALL" })
		lAcesso := ( nAcesso > 0 )
		lAcesso := .T.
		aVerRet := NGSEEKSM0(cGetEmpres+cGetFilial,{"M0_NOME","M0_FILIAL"})
		If !lAcesso .Or. Len(aVerRet) == 0
			If lShowMsg
				MsgStop("A Empresa/Filial é inválida.","Atenção")
			EndIf
			If IsInCallStack("MNTA851CAD") .Or. IsInCallStack("fDefEmpFil")
				Return .F.
			EndIf
		EndIf
	EndIf

	aZEMPS := { {cGetEmpres,cGetFilial} }

	If Type("oGetEmpres") == "O"
		oGetEmpres:Refresh()
		oGetFilial:Refresh()
	EndIf

	NGPrepTbl(aPrepTbls,cGetEmpres,cGetFilial)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fRetEFUAcces
Recebe as empresas e filiais que o usuario possui acesso e retorna
de forma mais organizada.

Essa função é a implementação para o padrão, da função OASRETEF que
se encontra no fonte OAS1UTIL (OAS).
André Felipe Joriatti

@param String cVerCodUsr: Opcional;
Indica um usuario em especifico para
pesquisar.
Default: Usuario Atual.

@param Boolean lShowMsg: Opcional;
Indica se deve mostrar a mensagem.
.T. - Mostra a mensagem
.F. - Nao mostra a mensagem
Default: .F.

@param String cFiltEmp1: Opcional;
Indice a empresa DE para o filtro.
Default: "  "

@param String cFiltFil1: Opcional;
Indice a filial DE para o filtro.
Default: "  "

@param String cFiltEmp2: Opcional;
Indice a empresa ATE para o filtro.
Default: "ZZ"

@param String cFiltFil2: Opcional;
Indice a filial ATE para o filtro.
Default: "ZZ"

@author Wagner S. de Lacerda
@since 23/08/2011
@version P11
@return Array aEmpsFils: array com as empresas/filiais que o usuário
	posssui acesso
/*/
//---------------------------------------------------------------------

Static Function fRetEFUAcces( cVerCodUsr,lShowMsg,cFiltEmp1,cFiltFil1,cFiltEmp2,cFiltFil2 )

	Local aArea      := {}
	Local aUsrAccess := {}
	Local aEmpsFils  := {}

	Local lTemAcesso := .F.
	Local nTodas     := 0

	Local nTAMCODIGO := Len(SM0->M0_CODIGO)
	Local nTAMFILIAL := If(FindFunction("FWSizeFilial"),FWSizeFilial(),2)

	Local cVerCodEmp := ""
	Local cVerCodFil := ""

	Default cVerCodUsr := RetCodUsr()
	Default lShowMsg   := .F.
	Default cFiltEmp1  := Space(nTAMCODIGO)
	Default cFiltFil1  := Space(nTAMFILIAL)
	Default cFiltEmp2  := Replicate("Z",nTAMCODIGO)
	Default cFiltFil2  := Replicate("Z",nTAMFILIAL)

	aUsrAccess := aClone( fAccesEFUSR(cVerCodUsr,lShowMsg) )

	dbSelectArea("SM0")
	aArea := GetArea()

	nTodas := aScan(aUsrAccess, {|x| AllTrim(x) == "@@@@" })

	CursorWait()
	aEmpsFils := {}

	dbSelectArea("SM0")
	dbSetOrder(1)
	dbGoTop()

	While !Eof()

		cVerCodEmp := PADR(SM0->M0_CODIGO,nTAMCODIGO," ")
		cVerCodFil := PADR(SM0->M0_CODFIL,nTAMFILIAL," ")

		If cVerCodEmp < cFiltEmp1 .Or. cVerCodEmp > cFiltEmp2
			dbSelectArea("SM0")
			dbSkip()
			Loop
		ElseIf cVerCodEmp == cFiltEmp1 .And. cVerCodFil < cFiltFil1
			dbSelectArea("SM0")
			dbSkip()
			Loop
		ElseIf cVerCodEmp == cFiltEmp2 .And. cVerCodFil > cFiltFil2
			dbSelectArea("SM0")
			dbSkip()
			Loop
		EndIf

		If nTodas > 0
			lTemAcesso := .T.
		Else
			lTemAcesso := ( aScan(aUsrAccess, {|x| AllTrim(x) == cVerCodEmp+cVerCodFil }) > 0 )
		EndIf

		If lTemAcesso
			aAdd(aEmpsFils, {cVerCodEmp, cVerCodFil})
		EndIf

		dbSelectArea("SM0")
		dbSkip()

	End While

	If nTodas > 0
		aAdd(aEmpsFils, {"ALL","ALL"})
	EndIf

	If Len(aEmpsFils) > 0
		aSort(aEmpsFils, , , {|x,y| x[1]+x[2] < y[1]+y[2] })
	EndIf

	CursorArrow()

	RestArea(aArea)

Return aEmpsFils

//---------------------------------------------------------------------
/*/{Protheus.doc} fAccesEFUSR
Função para buscar as empresas e filiais as quais um determinado
usuario possui acesso.

Essa função é a implementação para o padrão, da função OASACESS que
se encontra no fonte OAS1UTIL (OAS).
André Felipe Joriatti

@param String cVerCodUsr: Opcional;
Indica um usuario em especifico para
pesquisar.
Default: Usuario Atual.

@param Boolean lShowMsg: Opcional;
Indica se deve mostrar a mensagem.
.T. - Mostra a mensagem
.F. - Nao mostra a mensagem
Default: .F.

@author Wagner S. de Lacerda
@since 23/08/2011
@version P11
@return Array aUsrAccess: Array com as empresas/filiais as
	quais o usuario possui acesso.

/*/
//---------------------------------------------------------------------

Static Function fAccesEFUSR( cVerCodUsr,lShowMsg )

	Local aArea      := GetArea()
	Local aUsrAccess := {}
	Local aGroups    := {}
	Local nGroup, nEmpFil
	Local nTotal := 0

	Default cVerCodUsr := RetCodUsr()
	Default lShowMsg   := .F.

	PswOrder(1)
	If PswSeek(cVerCodUsr,.T.)
		dbSelectArea("SM0")
		aArea := GetArea()

		//Verifica se a restrição será pelo grupo de usuários
		If Len(PswRet()[1][10]) > 0 .And. PswRet()[2][11]
			aGroups := PswRet()[1][10]

			//Adiciona as Empresas e Filiais de todos os Grupos do usuário
			For nGroup := 1 To Len(aGroups)
				//Seta no Grupo para buscar informações
				If PswSeek(aGroups[nGroup],.F.)

					//Veifica e adiciona Empresa e Filial permitida para o grupo
					aEmpFil := PswRet()[1][11]
					For nEmpFil := 1 To Len(aEmpFil)
						//Verifica se já não foi adicionado na array
						If aScan(aUsrAccess,aEmpFil[nEmpFil]) == 0
							aAdd(aUsrAccess,aEmpFil[nEmpFil])
						EndIf
					Next nEmpFil
				EndIf
			Next nGroup
		Else
			//Utiliza as restrições direto do usuário
			aUsrAccess := PswRet()[2][6]
		EndIf

		//Verifica se array contem todas as empresas e filiais
		dbSelectArea("SM0")
		dbGoTop()
		dbEval({|| nTotal++},,{|| aScan(aUsrAccess,SM0->M0_CODIGO+SM0->M0_CODFIL) == 0})

		//Se todas as empresas e filiais estiverem na array, troca-se para @@@@
		//Reduzindo a lentidao e nao ocorrendo erro de overflow
		If nTotal == 0
			aUsrAccess := {"@@@@"}
		EndIf
	EndIf


	If lShowMsg .And. Len(aUsrAccess) == 0
		//ApMsgAlert("Usuário não encontrado no cadastro do sistema.")//"Usuário não encontrado no cadastro do sistema."
		Return aUsrAccess
	EndIf

	RestArea(aArea)

Return aUsrAccess

//---------------------------------------------------------------------
/*/{Protheus.doc} WEMPFILTV1
When dos campos TV1_FILIAL e TV1_EMPRES

@author André Felipe Joriatti
@since 22/08/2013
@version P11
@return .T.
/*/
//---------------------------------------------------------------------

Function WEMPFILTV1()
	Local lRet := ( Altera .And. ( TV1->TV1_INDERR == "1" ) )
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fErros851
Tela para visualização dos erros.

@author André Felipe Joriatti
@since 17/09/2013
@version P11
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fErros851()

	Local oDlgInc  := Nil
	Local oGrpBem  := Nil
	Local oGrpLbl  := Nil
	Local oGetErr  := Nil
	Local oTPanel  := Nil
	Local oConfirm := Nil
	Local oCancel  := Nil

	Define MsDialog oDlgInc From 020,000 To 350,400 COLOR CLR_BLACK,CLR_WHITE STYLE;
		nOr( DS_SYSMODAL,WS_MAXIMIZEBOX,WS_POPUP ) Of oMainWnd Pixel // "Erros de Importação"

		oTPanel := tPaintPanel():New( 0,0,0,0,oDlgInc,.F. )
			oTPanel:Align := CONTROL_ALIGN_ALLCLIENT

			// Container do Fundo
			oTPanel:addShape( "id=0;type=1;left=0;top=0;width=510;height=470;gradient=1,0,0,0,180,0.0,#FFFFFF;" + ;
							  "pen-color=#FFFFFF;can-move=0;can-mark=0;is-container=1;" )

			// Gradiente
			oTPanel:addShape( "id=1;type=1;left=1;top=1;width=506;height=470;gradient=1,0,0,0,380,0.0,#FFFFFF,0.1,#FDFBFD,1.0,#CDD1D4;" + ;
							  "pen-width=0;pen-color=#FFFFFF;can-move=0;can-mark=0;is-container=1;" )

		oGrpLbl := tGroup():New( 015,004,030,200,,oTPanel,CLR_BLUE,,.T., )

		@ 019,035 Say "Erros de importação do cabeçalho da parte diária" COLOR CLR_HBLUE Of oGrpLbl Size 200,050 Pixel // "Erros de importação do cabeçalho da parte diária:"

		oGrpBem := tGroup():New( 035,004,150,200,,oTPanel,CLR_BLUE,,.T., )

			oGetErr := tMultiGet():New( 043,010,{ |u| If( PCount() > 0,M->TV1_MSGERR := u,M->TV1_MSGERR ) },oGrpBem,185,100,,,,,,.T.,,,;
				,,,.T.,,,,.T. ,.T.,,,, )
				oGetErr:EnableHScroll( .T. )
				oGetErr:EnableVScroll( .T. )

		Define sButton oConfirm From 160,140 Type 1 Enable Of oTPanel Action ( oDlgInc:End() ) Pixel
			oConfirm:SetCss( CSSButton( .T. ) )

		Define sButton oCancel From 160,170 Type 2 Enable Of oTPanel Action ( oDlgInc:End() ) Pixel
			oCancel:SetCss( CSSButton() )

	Activate MsDialog oDlgInc Centered

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} GetSeqTV2
Verifica ultima sequencia de atividades do dia (TV2)

@author Hamilton Soldati
@since 19/11/2014
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function GetSeqTV2(cKeyTv2)

	Local cSeqTV2 := "000"
	Local aArea := GetArea()
	Local aAreaTV2 := TV2->(GetArea())

	dbSelectArea("TV2")
	dbSetOrder(4)

	SET DELETED OFF

	dbSeek(cKeyTv2)
	While !Eof() .And. cKeyTv2 == TV2->TV2_FILIAL + TV2->TV2_EMPRES + TV2->TV2_CODBEM + DTOS(TV2->TV2_DTSERV)
		cSeqTV2 := TV2->TV2_SEQREL
		dbSkip()
	End

	SET DELETED ON

	RestArea(aAreaTV2)
	RestArea(aArea)

Return cSeqTV2

//---------------------------------------------------------------------
/*/{Protheus.doc} CSSButton
Retorna um CSS personalizado para a classe TButton.
@type function

@author Alexandre Santos
@since 29/10/2021

@param [lFocal], boolean, Indica que o botao será focal.
@return string , CSS utilizado na montagem do botão.
/*/
//---------------------------------------------------------------------
Static Function CSSButton( lFocal )
	
	Local cButton  := 'QPushButton { font: bold }'
	Local lImg     := Len( GetResArray( 'fwstd_btn_focal.png' ) ) > 0

	Default lFocal := .F.

	If lImg

		If lFocal
			cButton += 'QPushButton { border-image: url(rpo:fwstd_btn_focal.png) 3 3 3 3 stretch }'
			cButton += 'QPushButton { color: #FFFFFF } '
		Else
			cButton += 'QPushButton { border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch }'
			cButton += 'QPushButton { color: #024670 } '
		EndIf

	Else

		cButton += 'QPushButton { color: #024670 } '

	EndIf

	cButton += 'QPushButton { border-top-width: 3px }'
	cButton += 'QPushButton { border-left-width: 3px }'
	cButton += 'QPushButton { border-right-width: 3px }'
	cButton += 'QPushButton { border-bottom-width: 3px }'

	If lImg
		
		cButton += 'QPushButton:pressed { color: #FFFFFF } '
		
		If lFocal
			cButton += 'QPushButton:pressed { border-image: url(rpo:fwstd_btn_focal_dld.png) 3 3 3 3 stretch }'
		Else
			cButton += 'QPushButton:pressed { border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch }'
		EndIf

	EndIf

	cButton += 'QPushButton:pressed { border-top-width: 3px }'
	cButton += 'QPushButton:pressed { border-left-width: 3px }'
	cButton += 'QPushButton:pressed { border-right-width: 3px }'
	cButton += 'QPushButton:pressed { border-bottom-width: 3px }'

Return cButton
