#INCLUDE "mdta555.ch"
#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA555
Programa de Cadastro de Ordens de Inspecao

@author  Andre E. Perez Alvarez
@since   25/10/06
@sample  MDTA555()

@return  Lógico, Sempre verdadeiro
/*/
//-------------------------------------------------------------------
Function MDTA555()

	// Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	Local aNGBEGINPRM := NGBEGINPRM()

	Local cFilBlock := ""

	Private lSigaMdtPS	:= IIf( SuperGetMv( "MV_MDTPS", .F., "N" ) == "S", .T., .F. )
	Private aRotina		:= MenuDef()
	Private aCHKDEL		:= {}
	Private bNGGRAVA	:= {}
	Private bFiltraBrw	:= { || NIL }
	Private aChoice		:= {}
	Private aNao		:= {}
	Private aIndexTLD	:= {}

	// Variaveis parametro NGCAD02
	Private nLinhas   := 0
	Private aVARNAO   := {}
	Private aGETNAO   := {}
	Private cGETMAKE  := ""
	Private cGETKEY   := ""
	Private cGETWHILE := ""
	Private cGETALIAS := ""
	Private cTUDOOK   := ""
	Private cLINOK    := ""
	Private aTROCAF3  := {}
	Private cCateg    := ""

	If !NGCADICBASE( "TK6_EVENTO", "D", "TK6", .F. )
		If !NGINCOMPDIC( "UPDMDT04", "000000173022010" )
			Return .F.
		EndIf
	EndIf

	If lSigaMdtps
		//Define o cabecalho da tela de atualizacoes
		cCadastro := OemtoAnsi( STR0056 ) //"Clientes"

		//Endereca a funcao de BROWSE
		DbSelectArea( "SA1" )
		DbSetOrder( 1 )
		mBrowse( 6, 1, 22, 75, "SA1" )
	Else
		//Define o cabecalho da tela de atualizacoes
		cCadastro := OemtoAnsi( STR0006 ) //"Ordens de Inspeção"
		cPrograma := "MDTA555"

		Begin Sequence

			dbSelectArea( "TLD" )
			// Filtra somente as ordens de inspecao pendentes
			cFiltra := 'TLD_SITUAC == "1" .And. '
			cFiltra += 'TLD_FILIAL == "' + xFilial( "TLD" ) + '"'

			If ExistBlock( "MDTA5551" )
   				cFilBlock := cValToChar( ExecBlock( "MDTA5551", .F., .F. ) )
    			cFiltra += cFilBlock
			EndIf

			bFiltraBrw := { || FilBrowse( "TLD", @aIndexTLD, @cFiltra ) }
			Eval( bFiltraBrw )

			dbGoTop()
			mBrowse( 6, 1, 22, 75, "TLD" )

			// Restaura Filtro
			dbSelectarea( "TLD" )
			EndFilBrw( "TLD", aIndexTLD )

		End Sequence
	EndIf

	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	NGRETURNPRM( aNGBEGINPRM )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT555Inc
Monta a tela para inclusao/alteracao/exclusao de ordem de inspecao.

@author  Roger Rodrigues
@since   25/10/2006
@sample  MDT555Inc( cALIAS, nREG, nOPCX )

@param   cALIAS, nREG, nOPCX, caracter, número, número
@return  Número, nOpca
/*/
//-------------------------------------------------------------------
Function MDT555Inc( cALIAS, nREG, nOPCX )

	Local aAreaTLD := TLD->( GetArea() )
	Local nOpca := 0

	Private lFinaliza := .F. //When do campo TLD_DTREAL

	If nOpcx <> 2
		aNao := { "TLD_SUBGAT", "TLD_SUBDIF", "TLD_MANGOT", "TLD_VALSEG", "TLD_VALCOM", "TLD_VALCIL", "TLD_PINTUR", "TLD_MANOME", "TLD_HIDROS",;
				  "TLD_RECARG", "TLD_USAINC", "TLD_USAINS", "TLD_DIVERS", "TLD_DTRECA", "TLD_CODUSU", "TLD_NOMUSU", "TLD_CC", "TLD_DTREAL" }
	EndIf

	aChoice := NGCAMPNSX3( "TLD", aNao ) //Define campos que aparecerão na tela

	If nOpcx <> 2
		nOpca := NGCAD01( "TLD", nReg, nOpcx )
	Else
		// Define as condicoes do NGCAD02
		MDTA555DEF()

		// Habilita apenas a Visualizacao
		cTUDOOK := "AllwaysFalse()"
		cLINOK := "AllwaysFalse()"

		nOpca := NGCAD02( cAlias, nReg, nOpcx, , nLinhas )
	EndIf

	If nOpca == 1

		//Se for prestador grava o codigo do cliente
		If lSigaMdtps .And. nOpcx == 3
			RecLock( "TLD", .F. )
			TLD->TLD_CLIENT := SA1->A1_COD
			TLD->TLD_LOJA   := SA1->A1_LOJA
			MsUnlock( "TLD" )
		EndIf

		// Grava os Eventos
		If nOpcx == 3
			MDTA555GRA( TLD->TLD_ORDEM, TLD->TLD_CODTIP )
		ElseIF nOpcx == 5
			MDTA555DEL( TLD->TLD_ORDEM )
		EndIf
	Else
		RestArea( aAreaTLD )
	EndIf

Return nOpca

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT555Fim
Monta a tela de finalizacao de ordem de inspecao.

@author  Andre E. Perez Alvarez
@since   24/10/2006
@sample  MDT555Fim( cALIAS, nREG, nOPCX )

@param  cALIAS, nREG, nOPCX, caracter, número, número
@return  Número, nOpca
/*/
//-------------------------------------------------------------------
Function MDT555Fim( cALIAS, nREG, nOPCX )

	Local aAreaTLD	:= TLD->( GetArea() )
	Local nOpca		:= 0
	Local nCont		:= 0
	Local lRecarga	:= .F.

	//Variaveis de Indice
	Local nIndexTLA, cSeekTLA
	Local aCampos := { "TLD_SUBGAT", "TLD_SUBDIF", "TLD_MANGOT", "TLD_VALSEG", "TLD_VALCOM", "TLD_VALCIL", "TLD_PINTUR", "TLD_MANOME", "TLD_HIDROS",;
					   "TLD_RECARG", "TLD_USAINC", "TLD_USAINS", "TLD_DIVERS" }

	Private lFinaliza := .T.
	Private aRelac := { { "TLD_SITUAC", "'2'" }, { "TLD_DTREAL", "dDataBase" } }
	Private lUpd := NGCADICBASE( "TLC_CATEGO", "A", "TLC", .F. )

	If NGCADICBASE( "TLD_RECEBI", "A", "TLD", .F. )
		aAdd( aRelac, { "TLD_RECEBI", "'1'" } )
	EndIf

	//Carrega incializador padrão dos campos
	For nCont := 1 To Len( aCampos )
		If ExistIni( aCampos[ nCont ] )
			aAdd( aRelac, { aCampos[ nCont ], AllTrim( GetSx3Cache( aCampos[ nCont ], 'X3_RELACAO' ) ) } )
		EndIf
	Next nCont

	//Modo de alteração
	nOpcx := 4
	SetAltera( .T. )

	// Define as condicoes do NGCAD02
	MDTA555DEF()

	nOpca := NGCAD02( cAlias, nReg, nOpcx, , nLinhas )

	If nOpca == 1 //Se confirmou
		If lUpd
			If TLD->TLD_CATEGO == "1"

				//Verifica se foi realizada a recarga do extintor através do evento padrão "010 - RECARREGADO"
				dbSelectArea( "TK5" )
				dbSetOrder( 1 ) //TK5_FILIAL + TK5_ORDEM + TK5_EVENTO
				If dbSeek( xFilial( "TK5" ) + TLD->TLD_ORDEM + "010" ) .And. TK5->TK5_REALIZ = '1'
					lRecarga := .T.
				EndIf

				If lSigaMdtps
					nIndexTLA := 7
					cSeekTLA  := TLD->TLD_CLIENT + TLD->TLD_LOJA + TLD->TLD_CODEXT
				Else
					nIndexTLA := 1
					cSeekTLA  := TLD->TLD_CODEXT
				EndIf

				//Atualiza data da ultima recarga e ultima manutencao
				dbSelectArea( "TLA" )
				dbSetOrder( nIndexTLA )
				If dbSeek( xFilial( "TLA" ) + cSeekTLA )
					RecLock( "TLA", .F. )
					If lRecarga .And. TLA->TLA_DTRECA < TLD->TLD_DTREAL
						TLA->TLA_DTRECA := TLD->TLD_DTREAL
					EndIf
					If TLA->TLA_DTMANU < TLD->TLD_DTREAL
						TLA->TLA_DTMANU := TLD->TLD_DTREAL
					EndIf
					MsUnlock( "TLA" )
				EndIf

			ElseIf TLD->TLD_CATEGO == "2"

				//Atualiza data da ultima manutencao
				dbSelectArea( "TKS" )
				dbSetOrder( 1 )
				If dbSeek( xFilial( "TKS" ) + TLD->TLD_CODEXT )
					RecLock( "TKS", .F. )
					If TKS->TKS_DTMANU < TLD->TLD_DTREAL
						TKS->TKS_DTMANU := TLD->TLD_DTREAL
					EndIf
					MsUnlock( "TKS" )
				EndIf

			EndIf
		Else
			//Verifica se foi realizada a recarga do extintor através do evento padrão "010 - RECARREGADO"
			dbSelectArea( "TK5" )
			dbSetOrder( 1 ) //TK5_FILIAL + TK5_ORDEM + TK5_EVENTO
			If dbSeek( xFilial( "TK5" ) + TLD->TLD_ORDEM + "010" ) .And. TK5->TK5_REALIZ = '1'
				lRecarga := .T.
			EndIf

			If lSigaMdtps
				nIndexTLA := 7
				cSeekTLA  := TLD->TLD_CLIENT + TLD->TLD_LOJA + TLD->TLD_CODEXT
			Else
				nIndexTLA := 1
				cSeekTLA  := TLD->TLD_CODEXT
			EndIf

			//Atualiza data da ultima recarga e ultima manutencao
			dbSelectArea( "TLA" )
			dbSetOrder( nIndexTLA )
			If dbSeek( xFilial( "TLA" ) + cSeekTLA )
				RecLock( "TLA", .F. )
				If lRecarga .And. TLA->TLA_DTRECA < TLD->TLD_DTREAL
					TLA->TLA_DTRECA := TLD->TLD_DTREAL
				EndIf
				If TLA->TLA_DTMANU < TLD->TLD_DTREAL
					TLA->TLA_DTMANU := TLD->TLD_DTREAL
				EndIf
				MsUnlock( "TLA" )
			EndIf
		EndIf
	EndIf

	RestArea( aAreaTLD )

Return nOpca

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT555REA
Monta a tela de reabertura de ordem de inspecao.

@author  Roger Rodrigues
@since   07/06/2010
@sample  MDT555REA( cALIAS, nREG, nOPCX )

@param   cALIAS, nREG, nOPCX, caracter, número, número
@return  Número, nOpca
/*/
//-------------------------------------------------------------------
Function MDT555REA( cALIAS, nREG, nOPCX )

	Local aAreaTLD := TLD->( GetArea() )
	Local nOpca := 0
	Local OldRot := aClone( aRotina )
	Local aNaoRea := { "TLD_SUBGAT", "TLD_SUBDIF", "TLD_MANGOT", "TLD_VALSEG", "TLD_VALCOM", "TLD_VALCIL", "TLD_PINTUR", "TLD_MANOME", "TLD_HIDROS",;
					   "TLD_RECARG", "TLD_USAINC", "TLD_USAINS", "TLD_DIVERS", "TLD_DTRECA", "TLD_CODUSU", "TLD_NOMUSU", "TLD_CC", "TLD_DTREAL" }

	Private lFinaliza := .T.
	Private aRelac := { { "TLD_SITUAC", "'1'" }, { "TLD_DTREAL", "STOD('')" }, { "TLD_CODUSU", "''" } }
	Private dDataReal := TLD->TLD_DTREAL
	Private lUpd := NGCADICBASE( "TLC_CATEGO", "A", "TLC", .F. )
	Private dNewDat := STOD( SPACE( 8 ) )

	aChoice := NGCAMPNSX3( "TLD", aNaoRea )//Define campos que aparecerão na tela

	aRotina := { { STR0001, "AxPesqui", 0, 1 },; //"Pesquisar"
				 { STR0002, "MDT555REA", 0, 2 },; //"Visualizar"
	             { STR0003, "MDT555REA", 0, 3 },; //"Incluir"
	             { STR0004, "MDT555REA", 0, 4 },; //"Alterar"
	             { STR0005, "MDT555REA", 0, 5 } }  //"Excluir"

	//Modo de alteração
	nOpcx := 4
	SetAltera( .T. )

	nOpca := NGCAD01( cAlias, nReg, nOpcx )

	If nOpca == 1
		aArea := GetArea()
		If lUpd
			If TLD->TLD_CATEGO == "1"
				nIndexTLA := 1
				cSeekTLA := TLD->TLD_CODEXT
				If lSigaMdtps
					nIndexTLA := 7
					cSeekTLA := TLD->TLD_CLIENT + TLD->TLD_LOJA + TLD->TLD_CODEXT
				EndIf
				//Atualiza data da ultima recarga e ultima manutencao
				dbSelectArea( "TLA" )
				dbSetOrder( nIndexTLA )
				If dbSeek( xFilial( "TLA" ) + cSeekTLA )
					If TLA->TLA_DTMANU == dDataReal
						dbSelectArea( "TLD" )
						dbSetOrder( 2 )
						If dbSeek( xFilial( "TLD" ) + TLA->TLA_CODEXT )
							While !Eof() .And. TLA->TLA_CODEXT == TLD->TLD_CODEXT
								If  TLD->TLD_CATEGO <> "1"
									dbSkip()
									Loop
								EndIf
							    If Empty( dNewDat ) .Or. dNewDat < TLD->TLD_DTREAL
							    	dNewDat := TLD->TLD_DTREAL
							    EndIf
								dbSelectArea( "TLD" )
								dbSkip()
							End
						EndIf
					 	RecLock( "TLA", .F. )
					 	TLA->TLA_DTMANU := dNewDat
						MsUnlock( "TLA" )
					EndIf
				EndIf
			ElseIf TLD->TLD_CATEGO == "2"
				dbSelectArea( "TKS" )
				dbSetOrder( 1 )
				If dbSeek( xFilial( "TKS" ) + TLD->TLD_CODEXT )
					If TKS->TKS_DTMANU == dDataReal
						dbSelectArea( "TLD" )
						dbSetOrder( 2 )
						If dbSeek( xFilial( "TLD" ) + TKS->TKS_CODCJN )
							While !Eof() .And. TKS->TKS_CODCJN == TLD->TLD_CODEXT
								If  TLD->TLD_CATEGO <> "2"
									dbSkip()
									Loop
								EndIf
							    If Empty( dNewDat ) .Or. dNewDat < TLD->TLD_DTREAL
							    	dNewDat := TLD->TLD_DTREAL
							    EndIf
								dbSelectArea( "TLD" )
								dbSkip()
							End
						EndIf
					 	RecLock( "TKS", .F. )
					 	TKS->TKS_DTMANU := dNewDat
						MsUnlock( "TKS" )
					EndIf
				EndIf
			EndIf
		Else
			nIndexTLA := 1
			cSeekTLA := TLD->TLD_CODEXT
			If lSigaMdtps
				nIndexTLA := 7
				cSeekTLA := TLD->TLD_CLIENT + TLD->TLD_LOJA + TLD->TLD_CODEXT
			EndIf
			//Atualiza data da ultima recarga e ultima manutencao
			dbSelectArea( "TLA" )
			dbSetOrder( nIndexTLA )
			If dbSeek( xFilial( "TLA" ) + cSeekTLA )
				If TLA->TLA_DTMANU == dDataReal
					dbSelectArea( "TLD" )
					dbSetOrder( 2 )
					If dbSeek( xFilial( "TLD" ) + TLA->TLA_CODEXT )
						While !Eof() .And. TLA->TLA_CODEXT == TLD->TLD_CODEXT
						    If Empty( dNewDat ) .Or. dNewDat < TLD->TLD_DTREAL
						    	dNewDat := TLD->TLD_DTREAL
						    EndIf
							dbSelectArea( "TLD" )
							dbSkip()
						End
					EndIf
				 	RecLock( "TLA", .F. )
				 	TLA->TLA_DTMANU := dNewDat
					MsUnlock( "TLA" )
				EndIf
			EndIf
		EndIf
		RestArea( aArea )
	EndIf

	aRotina := aClone( OldRot )
	RestArea( aAreaTLD )

Return nOpca

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT555Cor
Define o sinaleiro para a situação das ordens de serviço.

@author  Andre E. Perez Alvarez
@since   26/10/2006
@sample  MDT555Cor()

@return Array, aCores
/*/
//-------------------------------------------------------------------
Function MDT555Cor()

	Local aCores := { { "TLD->TLD_SITUAC == '1'", 'BR_VERMELHO' },; //Pendente
					  { "TLD->TLD_SITUAC == '2'", 'BR_VERDE' },; //Finalizada
					  { "TLD->TLD_SITUAC == '3'", 'BR_AZUL' } } //Cancelada

Return aCores

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT555LEG
Cria uma janela contendo a legenda da mBrowse.

@author  Andre E. Perez Alvarez
@since   27/10/2006
@sample  MDT555LEG()

@return Lógico, Sempre verdadeiro
/*/
//-------------------------------------------------------------------
Function MDT555LEG()

	BrwLegenda( cCadastro, STR0042, { { "BR_VERDE", OemToAnsi( STR0038 ) },; //"Finalizada"
	                                { "BR_AZUL", OemToAnsi( STR0039 ) } } ) //"Cancelada"

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT555His
Monta um browse com as ordens de inspecao finalizadas.

@author  Andre E. Perez Alvarez
@since   25/10/2006
@sample  MDT555His( cALIAS, nREG, nOPCX )

@param   Arg1 - Alias da tabela
         Arg2 - Numero do registro
         Arg3 - Opcao escolhida
@return  Lógico, Sempre verdadeiro
/*/
//-------------------------------------------------------------------
Function MDT555His( cALIAS, nREG, nOPCX )

	Local nRecno := TLD->( Recno() )
	Local aOldRotina := Aclone( aRotina )
	Local aTLDIndex := {}
	Local cFilBlock := ""

	Private bBrwFiltra := {|| Nil }

	// Define as condicoes do NGCAD02
	MDTA555DEF()

	aRotina :=	{ { STR0001, "AxPesqui", 0, 1 },; //"Pesquisar"
	              { STR0002, "NGCAD02", 0, 2 },; //"Visualizar"
	              { STR0059, "MDT555REA", 0, 4 },; //"Reabrir"
	              { STR0042, "MDT555LEG", 0, 8 } } //"Legenda"

	Begin Sequence

		//Filtra somente ordens de inspecao finalizadas e canceladas
		dbSelectArea( "TLD" )
		Set Filter To

		cFiltraRh := 'TLD_SITUAC != "1" .And. '
		cFiltraRh += 'TLD_FILIAL == "' + xFilial( "TLD" ) + '"'
		If lSigaMdtps
			cFiltraRh += ' .And. TLD_CLIENT + TLD_LOJA == "' + cCliMdtps + '" '
		EndIf

		If ExistBlock( "MDTA5551" )
   			cFilBlock := cValToChar( ExecBlock( "MDTA5551", .F., .F. ) )
    		cFiltraRH += cFilBlock
		EndIf

		bBrwFiltra := { || FilBrowse( "TLD", @aTLDIndex, @cFiltraRH ) }
		Eval( bBrwFiltra )

		TLD->( dbGoTop() )

		mBrowse( 6, 1, 22, 75, "TLD", , , , , , MDT555Cor() )

		//Filtra somente as ordens de inspecao pendentes
		dbSelectArea( "TLD" )
		Set Filter To
		Eval( bFiltraBrw )
		dbGoTo( nRecno )

	End Sequence

	aRotina := Aclone( aOldRotina )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT555Date
Valida a data real.

@author  Andre E. Perez Alvarez
@since   05/02/2007
@sample  MDT555Date()

@return  Lógico, Sempre verdadeiro
/*/
//-------------------------------------------------------------------
Function MDT555Date()

	If M->TLD_DTREAL > dDataBase
		Help( " ", 1, "NGATENCAO", , STR0055, 3, 1 )  //"A data de realização da inspeção não pode ser maior que a data atual."
		Return .F.
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de Menu Funcional.

@type    static function

@author  Andre Perez Alvarez
@since   05/01/2008

@return aRotina, array, Array com opcoes da rotina.
@obs Parametros do array a Rotina:
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

	Local lSigaMdtPS := IIf( SuperGetMv( "MV_MDTPS", .F., "N" ) == "S", .T., .F. )
	Local aRotina

	If lSigaMdtps
		aRotina := { { STR0001, "AxPesqui", 0, 1},; //"Pesquisar"
		             { STR0002, "NGCAD01", 0, 2},; //"Visualizar"
		             { STR0057, "MDT555TLD", 0, 4} } //"Ordens de Inspeção"
	Else

		aRotina := { { STR0001, "AxPesqui", 0, 1 },; //"Pesquisar"
	                 { STR0002, "MDT555Inc", 0, 2 },; //"Visualizar"
	                 { STR0003, "MDT555Inc", 0, 3 },; //"Incluir"
	                 { STR0004, "MDT555Inc", 0, 4 },; //"Alterar"
	                 { STR0005, "MDT555Inc", 0, 5 },; //"Excluir"
	                 { STR0007, "MDT555Fim", 0, 4 },; //"Finalizar"
	                 { STR0054, "MDT555His", 0, 3 } } //"Encerradas"
	EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT555TLD
Mostra os extintores do cliente.

@author  Andre E. Perez Alvarez
@since   04/02/2008
@sample  MDT555TLD( cAlias, nReg, nOpcx )

@param   cALIAS, nREG, nOPCX, caracter, número, número
@return  Nil
/*/
//-------------------------------------------------------------------
Function MDT555TLD( cAlias, nReg, nOpcx )

	Local aArea	:= GetArea()
	Local oldROTINA := aCLONE( aROTINA )
	Local oldCad := cCadastro

	cCliMdtPs := SA1->A1_COD + SA1->A1_LOJA

	aRotina := { { STR0001, "AxPesqui", 0, 1 },; //"Pesquisar"
	             { STR0002, "MDT555Inc", 0, 2 },; //"Visualizar"
	             { STR0003, "MDT555Inc", 0, 3 },; //"Incluir"
	             { STR0004, "MDT555Inc", 0, 4 },; //"Alterar"
	             { STR0005, "MDT555Inc", 0, 5 },; //"Excluir"
	             { STR0007, "MDT555Fim", 0, 6 },; //"Finalizar"
	             { STR0054, "MDT555His", 0, 3 } } //"Encerradas"

	//Define o cabecalho da tela de atualizacoes
	cCadastro := OemtoAnsi( STR0006 ) //"Ordens de Inspeção"
	cPrograma := "MDTA555"

	// Filtra somente as ordens de inspecao pendentes
	dbSelectArea( "TLD" )
	cFiltra := 'TLD_SITUAC == "1" .And. '
	cFiltra += 'TLD_FILIAL == "' + xFilial( "TLD" ) + '"'
	cFiltra += ' .And. TLD_CLIENT + TLD_LOJA == "' + cCliMdtps + '" '
	bFiltraBrw := { || FilBrowse( "TLD", @aIndexTLD, @cFiltra ) }
	Eval( bFiltraBrw )
	dbGoTop()
	mBrowse( 6, 1, 22, 75, "TLD" )

	// Restaura Filtro
	dbSelectarea( "TLD" )
	EndFilBrw( "TLD", aIndexTLD )

	aROTINA := aCLONE( oldROTINA )
	RestArea( aArea )
	cCadastro := oldCad

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT55CBOX
Valida campo Situacao.

@author  Denis
@since   08/05/2010
@sample  MDT55CBOX(cTLD_SITUAC)

@param   cTLD_SITUAC, caracter
@return  Lógico, sempre verdadeiro
/*/
//-------------------------------------------------------------------
Function MDT55CBOX( cTLD_SITUAC )

	If Substr( cTLD_SITUAC, 1, 1 ) == "2" .And. Altera
		MsgInfo( STR0058 ) //"Para finalizar uma ordem de inspeção, deve ser utilizado o botão 'Finalizar'."
		Return .F.
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA555DEF
Define as variaveis utilizadas para montar o NGCAD02 e a GetDados.
@author  Wagner S. de Lacerda
@since    08/06/2010
@sample  MDTA555DEF()

@return  Lógico, Sempre verdadeiro
/*/
//-------------------------------------------------------------------
Function MDTA555DEF()

	/* Define a quantidade maxima de linhas */
	nLinhas := 0

	dbSelectArea( "TK6" )
	dbGoTop()
	While !Eof() .And. TK6->TK6_FILIAL == xFilial( "TK6" )

		If TK6->TK6_INSPEC == TLD->TLD_CODTIP
			nLinhas++
		EndIf

		dbSelectArea( "TK6" )
		dbSkip()
	End

	/* Define os campos que aparecerao na tela */
	aCHOICE := {}

	/* Define os campos que nao serao mostrados em tela, mas serao gravados */
	aVARNAO := {}

	/* Define os campos que nao devem ser chamados na GetDados */
	aGETNAO := { {"TK5_ORDEM", "TLD->TLD_ORDEM"} }

	/* Define a variavel de pesquisa (sem filial) da GetDados */
	cGETMAKE  := "TLD->TLD_ORDEM"

	/* Define a chave de pesquisa (sem filial) da GetDados */
	cGETKEY := "M->TLD_ORDEM + M->TK5_EVENTO"

	/* Define a expressao while da chave de pesquisa da GetDados */
	cGETWHILE := "TK5->TK5_FILIAL == xFilial('TK5') .And. TK5->TK5_ORDEM == TLD->TLD_ORDEM"

	/* Define o nome do alias  da GetDados */
	cGETALIAS := "TK5"

	/* Define a validacao geral da GetDados */
	cTUDOOK := "AllwaysTrue()"

	/* Define a validacao da linha atual  da GetDados */
	cLINOK := "AllwaysTrue()"

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA555GRA
Grava os Eventos de acordo com o Tipo de Inspecao (TK6).

@author  Wagner S. de Lacerda
@since   10/06/2010
@sample   MDTA555GRA( cOrdem, cInspec )

@param   cOrdem - Obrigatorio - Indica a Ordem de Inspecao.
         cInspec - Obrigatorio - Indica o Tipo de Inspecao.
@return  Lógico, Sempre verdadeiro
/*/
//-------------------------------------------------------------------
Function MDTA555GRA( cOrdem, cInspec )

	Local nEvePad := 13 // Quantidade de eventos padroes
	Local nCont   := 0  // Contador do 'For'
	Local aEveTip := {} // Eventos do Tipo de Inspecao
	Local n13eve  := IIf( SuperGetMv( "MV_NG2EV13", .F., "S" ) == "S", .T., .F. )

	If !n13eve
		nEvePad := 0
	EndIf

	/* Busca os eventos do Tipo de Inspecao (TK6) */
	dbSelectArea( "TK6" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "TK6" ) + cInspec )
	While !Eof() .And. TK6->TK6_FILIAL + TK6->TK6_INSPEC == xFilial( "TK6" ) + cInspec
		dbSelectArea( "TK5" )
		dbSetOrder( 1 )
		If !dbSeek( xFilial( "TK5" ) + cOrdem + TK6->TK6_EVENTO )
			aAdd( aEveTip, TK6->TK6_EVENTO )
		EndIf
		dbSelectArea( "TK6" )
		dbSkip()
	End

	If nEvePad > 0 .Or. Len( aEveTip ) == 0
		/* Busca os eventos da inspecao padroes da NR23. */
		dbSelectArea( "TK4" )
		dbSetOrder( 1 )
		dbSeek( xFilial( "TK4" ) )
		While !Eof() .And. TK4->TK4_FILIAL == xFilial( "TK4" ) .And. Val( TK4->TK4_CODIGO ) <= nEvePad
			If aScan( aEveTip, { |x| x == TK4->TK4_CODIGO } ) == 0
				aAdd( aEveTip, TK4->TK4_CODIGO )
			EndIf
			dbSelectArea( "TK4" )
			dbSkip()
		End
	EndIf

	/* Grava os eventos encontrados nos Eventos da Ordem de Inspecao (TK5) */
	If Len( aEveTip ) > 0
		dbSelectArea( "TK5" )
		For nCont := 1 To Len( aEveTip )
			dbSelectArea( "TK5" )
			dbSetOrder( 1 )
			If !dbSeek( xFilial( "TK5" ) + cOrdem + aEveTip[nCont] )
				RecLock( "TK5", .T. )
				TK5->TK5_FILIAL := xFilial( "TK5" )
				TK5->TK5_ORDEM  := cOrdem
				TK5->TK5_EVENTO := aEveTip[nCont]
				TK5->TK5_REALIZ := "2"
				MsUnlock( "TK5" )
			EndIf
		Next nCont
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA555DEL
Deleta os Eventos de acordo com a Ordem de Inspecao (TLD).
@author  Wagner S. de Lacerda
@since   10/06/2010
@sample  MDTA555DEL(cOrdem)

@param   cOrdem - Obrigatorio - Indica a Ordem de Inspecao.
@return  Lógico, Sempre verdadeiro
/*/
//-------------------------------------------------------------------
Function MDTA555DEL( cOrdem )

	dbSelectArea( "TK5" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "TK5" ) + cOrdem )
	While !Eof() .And. TK5->( TK5_FILIAL + TK5_ORDEM ) == xFilial( "TK5" ) + cOrdem
		RecLock( "TK5", .F. )
		dbDelete()
		MsUnlock( "TK5" )
		dbSelectArea( "TK5" )
		dbSkip()
	End

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA555REL
Carrega o inicializador padrao do campo TK65DESCRI.

@author  Wagner S. de Lacerda
@since   10/06/2010
@sample  MDTA555REL()

@return  Caracter, cRel
/*/
//-------------------------------------------------------------------
Function MDTA555REL()

	Local cRel   := "" // conteudo do X3_RELACAO
	Local nCont  := 0  // contador do 'For'
	Local cEvent := "" // recebe o evento da aCols
	Local nPos   := aScan( aHeader, { |x| AllTrim( Upper( X[2] ) ) == "TK5_EVENTO" } ) // Coluna do campo

	If Len( aCols ) > 0
		For nCont := 1 To Len( aCols )
			cEvent := aCols[nCont][nPos]
			cRel   := NGSEEK( "TK4", cEvent, 1, "TK4->TK4_DESCRI" )
		Next nCont
	EndIf

Return cRel

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT555VLDX
Valida codigo TLD_CODEXT e TLD_CODTIP

@author  Denis
@since   21/06/10
@sample   MDT555VLDX(nTipoVld)

@param   nTipoVld, número
@return  Lógico, sempre verdadeiro
/*/
//-------------------------------------------------------------------
Function MDT555VLDX( nTipoVld )

	Local lPrest := .F.

	If Type( "cCliMdtPs" ) == "C"
		If !Empty( cCliMdtPs )
			lPrest := .T.
		EndIf
	EndIf

	If nTipoVld == 1
		If lPrest
			Return ( NaoVazio() .And. ExistCPO( "TLA", cCliMdtps + M->TLD_CODEXT, 7 ) )
		Else
			Return ( NaoVazio() .And. ExistCPO( "TLA", M->TLD_CODEXT, 1 ) )
		EndIf
	ElseIf nTipoVld == 2
		If lPrest
			Return ( NaoVazio() .And. ExistCPO( "TLB", cCliMdtps + M->TLD_CODTIP, 3 ) )
		Else
			Return ( NaoVazio() .And. ExistCPO( "TLB", M->TLD_CODTIP, 1 ) )
		EndIf
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT555R1
Mostra a descricao da extintor.

@author  Andre E. Perez Alvarez
@since   06/02/08
@sample  MDT555R1(lIniBrw)

@param   lIniBrw - .T. - Descricao deve ser mostrada no browse
    	 lIniBrw - .F. - Descricao deve ser mostrada na tela cadastral
@return  Caracter, cDesc
/*/
//-------------------------------------------------------------------
Function MDT555R1( lIniBrw )

	Local cDesc := " "
	Local aArea := GetArea()
	Local lPrest := .F.
	Local nOrd := 1

	Private lUpd := NGCADICBASE( "TLC_CATEGO", "A", "TLC", .F. )

	If Type( "cCliMdtPs" ) == "C"
		If !Empty( cCliMdtPs )
			lPrest := .T.
		EndIf
	EndIf

	If lUpd
		If lIniBrw
			If TLD->TLD_CATEGO == "2"
				nOrd := NGRETORDEM( "TKS", "TKS_FILIAL+TKS_CODCJN", .F. )
			EndIf
		Else
			If M->TLD_CATEGO == "2"
				nOrd := NGRETORDEM( "TKS", "TKS_FILIAL+TKS_CODCJN", .F. )
			EndIf
		EndIf
	EndIf

	If lPrest
		If lIniBrw
			cDesc := Posicione( "TLA", 7, xFilial( "TLA" ) + cCliMdtps + TLD->TLD_CODEXT, "TLA_DESCRI" )
			If lUpd
				If TLD->TLD_CATEGO == "2"
					cDesc := Posicione( "TKS", nOrd, xFilial( "TKS" ) + cCliMdtps + TLD->TLD_CODEXT, "TKS_DESCJN" )
				EndIf
			EndIf
		Else
			cDesc := Posicione( "TLA", 7, xFilial( "TLA" ) + cCliMdtps + M->TLD_CODEXT, "TLA_DESCRI" )
			If lUpd
				If M->TLD_CATEGO == "2"
					cDesc := Posicione( "TKS", nOrd, xFilial( "TKS" ) + cCliMdtps + M->TLD_CODEXT, "TKS_DESCJN" )
				EndIf
			EndIf
		EndIf
	Else
		If lIniBrw
			cDesc := Posicione( "TLA", 1, xFilial( "TLA" ) + TLD->TLD_CODEXT, "TLA_DESCRI" )
			If lUpd
				If TLD->TLD_CATEGO == "2"
					cDesc := Posicione( "TKS", nOrd, xFilial( "TKS" ) + TLD->TLD_CODEXT, "TKS_DESCJN" )
				EndIf
			EndIf
		Else
			cDesc := Posicione( "TLA", 1, xFilial( "TLA" ) + M->TLD_CODEXT, "TLA_DESCRI" )
			If lUpd
				If M->TLD_CATEGO == "2"
					cDesc := Posicione( "TKS", nOrd, xFilial( "TKS" ) + M->TLD_CODEXT, "TKS_DESCJN" )
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea( aArea )

Return cDesc

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT555R2
Mostra a descricao da tipo de inspecao.

@author  Andre E. Perez Alvarez
@since   06/02/2008
@sample  MDT555R2(lIniBrw)

@param   lIniBrw - .T. - Descricao deve ser mostrada no browse
		 lIniBrw - .F. - Descricao deve ser mostrada na tela cadastral
@return  Caracter, cDesc
/*/
//-------------------------------------------------------------------
Function MDT555R2( lIniBrw )

	Local cDesc := " "
	Local aArea := GetArea()
	Local lPrest := .F.

	If Type( "cCliMdtPs" ) == "C"
		If !Empty( cCliMdtPs )
			lPrest := .T.
		EndIf
	EndIf

	If lPrest
		If lIniBrw
			cDesc := Posicione( "TLB", 3, xFilial( "TLB" ) + cCliMdtps + TLD->TLD_CODTIP, 'TLB_DESCRI' )
		Else
			cDesc := Posicione( "TLB", 3, xFilial( "TLB" ) + cCliMdtps + M->TLD_CODTIP, 'TLB_DESCRI' )
		EndIf
	Else
		If lIniBrw
			cDesc := Posicione( "TLB", 1, xFilial( "TLB" ) + TLD->TLD_CODTIP, 'TLB_DESCRI' )
		Else
			cDesc := Posicione( "TLB", 1, xFilial( "TLB" ) + M->TLD_CODTIP, 'TLB_DESCRI' )
		EndIf
	EndIf

	RestArea( aArea )

Return cDesc

//-------------------------------------------------------------------
/*/{Protheus.doc} A555TROF3
Funcao para Troca do F3.

@author  Jackson Machado
@since   25/05/2011
@sample  A555TROF3()

@return  Lógico, Sempre verdadeiro
/*/
//-------------------------------------------------------------------
Function A555TROF3()

	aTROCAF3 := {}

	If M->TLD_CATEGO == "1"
	   AADD( aTROCAF3, { "TLD_CODEXT", "TLA" } )
	ElseIf M->TLD_CATEGO == "2"
	   AADD( aTROCAF3, { "TLD_CODEXT", "TKS" } )
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} A555CHKCOD
Consiste o codigo do campo de código do sistema de extinção.

@author  Jackson Machado
@since   25/05/2011
@sample  A555CHKCOD()

@return  Lógico, Sempre verdadeiro
/*/
//-------------------------------------------------------------------
Function A555CHKCOD()

	Local aAreaTLD := TOA->( GetArea() )

	M->TLD_DESEXT := Space( 20 )

	If M->TLD_CATEGO = "1"
	   If !TLA->( Dbseek( xFilial( "TLA" ) + M->TLD_CODEXT ) )
	      MsgStop( STR0060, STR0061 )//"Extintor não cadastrado."###"ATENÇÃO"
	      Return .F.
	   EndIf
	   M->TLD_DESEXT := TLA->TLA_DESCRI
	ElseIf M->TLD_CATEGO = "2"
	   If !TKS->( Dbseek( xFilial( "TKS" ) + M->TLD_CODEXT ) )
	      MsgStop( STR0062, STR0061 )//"Conjunto Hidráulico não cadastrado."###"ATENÇÃO"
	      Return .F.
	   EndIf
	   M->TLD_DESEXT := TKS->TKS_DESCJN
	EndIf

	RestArea( aAreaTLD )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} A555LIMPA
Limpa os campos em tela.

@author  Jackson Machado
@since   23/11/11
@sample  A555LIMPA()

@return  Lógico, Sempre verdadeiro
/*/
//-------------------------------------------------------------------
Function A555LIMPA()

	If M->TLD_CATEGO <> cCateg .And. INCLUI
		If !Empty( cCateg )
			M->TLD_CODEXT := SPACE( 10 )
			M->TLD_DESEXT := SPACE( 20 )
			M->TLD_CODTIP := SPACE( 10 )
			M->TLD_DESTIP := SPACE( 20 )
		EndIf
		cCateg := M->TLD_CATEGO
		If Type( "oEnchoice" ) == "O"
			oEnchoice:Refresh()
		EndIf
	EndIf

Return .T.
