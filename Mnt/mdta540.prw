#INCLUDE "mdta540.ch"
#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA540
Programa de Cadastro de Extintores

@author  Ricardo Dal Ponte
@since   13/10/2006
/*/
//-------------------------------------------------------------------
Function MDTA540()

	// Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	Local aNGBEGINPRM := NGBEGINPRM()

	Private lSigaMdtPS	:= IIf( SuperGetMv( "MV_MDTPS", .F., "N" ) == "S", .T., .F. )
	Private aCHKDEL		:= {}
	Private bNGGRAVA	:= {}
	Private aRotina		:= MenuDef()

	If AMiIn( 35 ) // Somente autorizado para SIGAMDT

		If lSigaMdtps
			// Define o cabecalho da tela de atualizacoes
			cCadastro := OemtoAnsi( STR0007 )  //"Clientes"
			aCHKDEL := { { 'TLA->TLA_CLIENT + TLA->TLA_LOJA + TLA->TLA_CODEXT', "TLD", 9 } }

			//Endereca a funcao de BROWSE
			dbSelectArea( "SA1" )
			dbSetOrder( 1 )
			mBrowse( 6, 1, 22, 75, "SA1" )
		Else
			// Define o cabecalho da tela de atualizacoes
			cCadastro := OemtoAnsi( STR0006 ) //"Extintores"
			aCHKDEL := { { 'TLA->TLA_CODEXT', "TLD", 2 } }

			// Endereca a funcao de BROWSE
			dbSelectArea( "TLA" )
			dbSetOrder( 1 )
			If ExistBlock( "MDTA5401" ) .And. ExistBlock( "MDTA5402" )
				mBrowse( 6, 1, 22, 75, "TLA", , , , , , ExecBlock( "MDTA5401", .F., .F. ) )
			Else
				mBrowse( 6, 1, 22, 75, "TLA" )
			EndIf
		EndIf
	EndIf

	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	NGRETURNPRM( aNGBEGINPRM )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT540BRW
Inicializa o browse

@author  Andre E. Perez Alvarez
@since   27/11/2006
/*/
//-------------------------------------------------------------------
Function MDT540BRW( lIniBrw )

	Local cDesc
	Local cAlias := "SI3"
	Local cDescr := "I3_DESC"
	Local aArea  := GetArea()

	If Alltrim( GETMV( "MV_MCONTAB" ) ) == "CTB"
		cAlias := "CTT"
		cDescr := "CTT_DESC01"
	EndIf

	If lIniBrw
		cDesc := Posicione( cAlias, 1, xFilial( cAlias ) + TLA->TLA_CC, cDescr )
	Else
		cDesc := Posicione( cAlias, 1, xFilial( cAlias ) + M->TLA_CC, cDescr )
	EndIf

	RestArea( aArea )

Return cDesc

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de Menu Funcional

@return	aRotina, Array, Array com opcoes da rotina

@obs	Parâmetros do array aRotina
1- Nome a aparecer no cabecalho
2- Nome da Rotina associada
3- Reservado
4- Tipo de Transa‡„o a ser efetuada:
	1 - Pesquisa e Posiciona em um Banco de Dados
    2 - Simplesmente Mostra os Campos
    3 - Inclui registros no Bancos de Dados
    4 - Altera o registro corrente
    5 - Remove o registro corrente do Banco de Dados
5- Nivel de acesso
6- Habilita Menu Funcional

@author  Andre Perez Alvarez
@since   05/01/2008
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local lSigaMdtPS := IIf( SuperGetMv( "MV_MDTPS", .F., "N" ) == "S", .T., .F. )
	Local aRotina

	If lSigaMdtps
		aRotina := { { STR0001, "AxPesqui", 0, 1 }, ; //"Pesquisar"
					{ STR0002, "NGCAD01", 0, 2 },; //"Visualizar"
					{ STR0008, "MDT540EX", 0, 4 } } //"Extintores"
	Else
		aRotina :=	{ { STR0001, "AxPesqui", 0, 1 }, ; //"Pesquisar"
					{  STR0002, "NGCAD01", 0, 2 }, ; //"Visualizar"
					{  STR0003, "NGCAD01", 0, 3 }, ; //"Incluir"
					{  STR0004, "NGCAD01", 0, 4 }, ; //"Alterar"
					{  STR0005, "NGCAD01", 0, 5, 3 } } //"Excluir"

		// Ponto de Entrada Legenda Extintores
		If ExistBlock( "MDTA5401" ) .And. ExistBlock( "MDTA5402" )
			aAdd( aRotina, { "Legenda", "ExecBlock('MDTA5402',.F.,.F.)", 0, 6 } )
		EndIf

	EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT540EX
Mostra os extintores do cliente

@author  Andre E. Perez Alvarez
@since   04/02/2008
/*/
//-------------------------------------------------------------------
Function MDT540EX( cAlias, nReg, nOpcx )

	Local aArea		:= GetArea()
	Local oldROTINA	:= aCLONE( aROTINA )
	Local oldCad	:= cCadastro
	cCliMdtPs		:= SA1->A1_COD + SA1->A1_LOJA

	aRotina := { { STR0001, "AxPesqui", 0, 1 }, ; //"Pesquisar"
				{ STR0002, "NGCAD01", 0, 2 }, ; //"Visualizar"
				{ STR0003, "NGCAD01", 0, 3 }, ; //"Incluir"
				{ STR0004, "NGCAD01", 0, 4 }, ; //"Alterar"
				{ STR0005, "NGCAD01", 0, 5, 3 } } //"Excluir"

	// Ponto de Entrada Legenda Extintores
	If ExistBlock( "MDTA5401" ) .And. ExistBlock( "MDTA5402" )
		aAdd( aRotina, { "Legenda", "ExecBlock('MDTA5402',.F.,.F.)", 0, 6 } )
	EndIf


	//Define o cabecalho da tela de atualizacoes
	Private cCadastro := OemtoAnsi( STR0008 ) //"Extintores"
	Private aCHKDEL := {}
	Private bNGGRAVA

	//Endereca a funcao de BROWSE
	dbSelectArea( "TLA" )
	Set Filter To TLA->( TLA_CLIENT + TLA_LOJA ) == cCliMdtps
	dbSetOrder( 7 ) //Filial + Cliente + Loja + Cod Extintor

	If ExistBlock( "MDTA5401" ) .And. ExistBlock( "MDTA5402" )
		mBrowse( 6, 1, 22, 75, "TLA", , , , , , ExecBlock( "MDTA5401", .F., .F. ) )
	Else
		mBrowse( 6, 1, 22, 75, "TLA" )
	EndIf

	dbSelectArea( "TLA" )
	Set Filter To

	aROTINA := aCLONE( oldROTINA )
	RestArea( aArea )
	cCadastro := oldCad

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT540VEXT
Valida codigo Extintor

@author  Denis
@since   21/06/2010
/*/
//-------------------------------------------------------------------
Function MDT540VEXT()

	Local lPrest := .F.

	If Type( "cCliMdtPs" ) == "C"
		If !Empty( cCliMdtPs )
			lPrest := .T.
		EndIf
	EndIf

	If lPrest
		Return EXISTCHAV( "TLA", cCliMdtps + M->TLA_CODEXT, 7 )
	Else
		Return EXISTCHAV( "TLA", M->TLA_CODEXT )
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT540WCC
When do campo TLA_CC

@author  Jackson Machado
@since   17/01/2012
/*/
//-------------------------------------------------------------------
Function MDT540WCC()

	Local aArea := GetArea()

	If SuperGetMv( 'MV_NGMDTAT', .F., '2' ) == '1'
		If !Empty( M->TLA_ATIFIX ) .And. !Empty( M->TLA_CC )
			If NGIFDBSEEK( "SN3", M->TLA_ATIFIX, 1 )
				If SN3->N3_CUSTBEM == M->TLA_CC
					RestArea( aArea )
					Return .F.
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea( aArea )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA540AT
Realiza integração do ativo fixo

@author  Jackson Machado
@since   17/01/2012
/*/
//-------------------------------------------------------------------
Function MDTA540AT()

	Local nOrdTLA := NGRETORDEM( "TLA", "TLA_FILIAL + TLA_ATIFIX", .F. )

	If NGCADICBASE( "TLA_ATIFIX", "A", "TLA", .F. )
		dbSelectArea( "TLA" )
		dbSetOrder( nOrdTLA )
		If dbSeek( xFilial( "TLA" ) + SN1->N1_CBASE + SN1->N1_ITEM )
			If NGIFDBSEEK( "SN3", TLA->TLA_ATIFIX, 1 )
				RecLock( "TLA", .F. )
				TLA->TLA_CC := IIf( !Empty( SN3->N3_CUSTBEM ), SN3->N3_CUSTBEM, TLA->TLA_CC )
				MsUnLock( "TLA" )
			EndIf
		EndIf
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} VA540AT
Validação do ativo fixo

@author  Jackson Machado
@since   17/01/2012
/*/
//-------------------------------------------------------------------
Function VA540AT()

	Local nOrdTLA := NGRETORDEM( "TLA", "TLA_FILIAL + TLA_ATIFIX", .F. )
	Local aArea := GetArea()

	If NGIFDBSEEK( "TLA", M->TLA_ATIFIX, nOrdTLA ) .And. TLA->TLA_CODEXT <> M->TLA_CODEXT
		MsgInfo( STR0009 + " " + Alltrim( TLA->TLA_CODEXT ) + "." + CHR( 13 ) + ; //"Ativo Fixo já cadastrado para o extintor "
				STR0010 + ".", STR0013 ) //"Informe outro código de Ativo Fixo"#"ATENÇÃO"
		RestArea( aArea )
		Return .F.
	EndIf
	If NGIFDBSEEK( "SN1", M->TLA_ATIFIX, 1 ) .And. SN1->N1_QUANTD <> 1
		MsgInfo( STR0011 + Chr(13) + ; //"O relacionamento do Ativo Fixo com o Extintor nao pode ser realizado. O campo"
				STR0012 + ".", STR0013 ) //"'Quantidade' no cadastro do Ativo Fixo e diferente de 1."#"ATENÇÃO"
		RestArea( aArea )
		Return .F.
	EndIf

	RestArea( aArea )

Return .T.

//---------------------------------------------------------------------
/*/ {Protheus.doc} vPesoVzCh
Valida o peso inserida nos campos TLA_PESOVZ e TLA_PESOCH.

@sample vldPecen()

@author Kawan Tácito Soares
@since 10/09/2013
/*/
//---------------------------------------------------------------------
Function vPesoVzCh()

	Local nPesoVaz := IIf( Type( "M->TLA_PESOVZ" ) = "N", M->TLA_PESOVZ, 0 )
	Local nPesoChe := IIf( Type( "M->TLA_PESOCH" ) = "N", M->TLA_PESOCH, 0 )

	If nPesoVaz > nPesoChe .And. ( !Empty( nPesoChe ) .And. !Empty( nPesoVaz ) )
		ShowHelpDlg( STR0013, { STR0014 }, 1, { STR0015 }, 2 )
		Return .F.
	EndIf

Return .T.
