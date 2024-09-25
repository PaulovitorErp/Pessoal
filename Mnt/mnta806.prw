#INCLUDE 'MNTA806.ch'
#INCLUDE 'TOTVS.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA806
Cadastro de Documentos Obrigatorios por Veículo
@type function

@author	Alexandre Santos
@since	25/03/2019

@return .T.
/*/
//---------------------------------------------------------------------
Function MNTA806()

	Local aNGBEGINPRM  := NGBEGINPRM() // Guarda conteudo e declara variaveis padroes
	Local cFilter      := ''
	Local aCores       := {	{ "ST9->T9_SITBEM == 'A' .And. ST9->T9_SITMAN == 'A'", 'BR_VERDE'    },;
	                        { "ST9->T9_SITBEM == 'A' .And. ST9->T9_SITMAN == 'I'", 'BR_AMARELO'  },;
	                        { "ST9->T9_SITBEM == 'I' .And. ST9->T9_SITMAN == 'A'", 'BR_AZUL'     },;
	                        { "ST9->T9_SITBEM == 'I' .And. ST9->T9_SITMAN == 'I'", 'BR_VERMELHO' },;
	                        { "ST9->T9_SITBEM == 'T'"                            , 'BR_CINZA'    } }

	Private cCadastro  := OemtoAnsi( STR0001 ) // Cadastro de Documentos Obrigatórios por Veículo
	Private cParSE2Doc := NGFI1DUP() // Retorna conteudo do parametro MV_1DUP
	Private bNGGrava   := { || MNTA805GRA() }
	Private aRotina    := MenuDef()
	Private aChkDel    := {}
	Private lExiste    := .T.
	Private lVencim    := .T.
	Private lConPag    := .T.
	Private lIntegTMS  := ( AllTrim( SuperGetMv( 'MV_NGMNTMS', .F., 'N' ) ) <> 'N' )

	// Verifica se existe integração com módulo SIGAFIN.
	Private lIntFin    := ( AllTrim( SuperGetMv( 'MV_NGMNTFI', .F., 'N' ) ) == 'S' )

	dbSelectArea( 'ST9' )
	dbSetOrder( 1 )
	dbGoTop()
	If ExistBlock( 'MNTA8051' )
		cFilter := ExecBlock( 'MNTA8051', .F., .F. )
	Else
		cFilter := "T9_CATBEM = '2' OR T9_CATBEM = '4'"
	EndIf

	cFilter += 'AND T9_FILIAL = ' + ValToSQL( xFilial( 'ST9' ) ) // Exibe somente veículos da mesma filial.

	SetBrwCHGAll( .F. ) // Inibe a tela de escolha da Filial

	mBrowse( 6, 1, 22, 75, 'ST9',,,,,, aCores,,,,,,,, cFilter )

	dbSelectArea( 'ST9' )
	Set Filter To

	NGRETURNPRM( aNGBEGINPRM ) 	// Retorna conteudo de variaveis padroes

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de Menu Funcional.
@type static

@author	Alexandre Santos
@since	25/03/2019

@return Array,  [1] - Nome que é apresentado no cabeçalho.
				[2] - Nome da rotina associada.
				[3] - Reservado.
				[4] - Tipo de transação a ser efetuada.
				[5] - Nível de acesso.
				[6] - Habilita menu funcional.
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := { { STR0002, 'AxPesqui' , 0, 1,, .F. },; // Pesquisar
					   { STR0004, 'MNTA805'  , 0, 3,, .F. },; // Documentos
					   { STR0003, 'NG805LEGE', 0, 7,, .F. } } // Legenda

	// Ponto de entrada para adicionar opções ao menu funcional.
	If ExistBlock( 'MNTA8053' )

		aRotina := ExecBlock( 'MNTA8053', .F., .F., { aRotina } )

	EndIf

Return aRotina
