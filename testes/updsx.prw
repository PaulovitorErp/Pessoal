#INCLUDE "protheus.ch"

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

#DEFINE CSSBOTAO	"QPushButton { color: #024670; "+;
"    border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"+;
"QPushButton:pressed {	color: #FFFFFF; "+;
"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"

//--------------------------------------------------------------------
/*/{Protheus.doc} UPDSX

Função de update de dicionários para compatibilização

@author UPDATE gerado automaticamente
@since  04/10/2023
@obs    Gerado por EXPORDIC - V.7.5.3.3 EFS / Upd. V.5.4.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function UPDSX( cEmpAmb, cFilAmb )
Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS"
Local   cDesc1    := "Esta rotina tem como função fazer  a atualização  dos dicionários do Sistema ( SX?/SIX )"
Local   cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja não podem haver outros"
Local   cDesc3    := "usuários  ou  jobs utilizando  o sistema.  É EXTREMAMENTE recomendavél  que  se  faça"
Local   cDesc4    := "um BACKUP  dos DICIONÁRIOS  e da  BASE DE DADOS antes desta atualização, para"
Local   cDesc5    := "que caso ocorram eventuais falhas, esse backup possa ser restaurado."
Local   cDesc6    := ""
Local   cDesc7    := ""
Local   cMsg      := ""
Local   lOk       := .F.
Local   lAuto     := ( cEmpAmb <> NIL .or. cFilAmb <> NIL )

Private oMainWnd  := NIL
Private oProcess  := NIL

#IFDEF TOP
    TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top
#ENDIF

__cInterNet := NIL
__lPYME     := .F.

Set Dele On

// Mensagens de Tela Inicial
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
aAdd( aSay, cDesc4 )
aAdd( aSay, cDesc5 )
//aAdd( aSay, cDesc6 )
//aAdd( aSay, cDesc7 )

// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

If lAuto
	lOk := .T.
Else
	FormBatch(  cTitulo,  aSay,  aButton )
EndIf

If lOk

	If GetVersao(.F.) < "12" .OR. ( FindFunction( "MPDicInDB" ) .AND. !MPDicInDB() )
		cMsg := "Este update NÃO PODE ser executado neste Ambiente." + CRLF + CRLF + ;
				"Os arquivos de dicionários se encontram em formato ISAM" + " (" + GetDbExtension() + ") " + "Os arquivos de dicionários se encontram em formato ISAM" + " " + ;
				"para atualizar apenas ambientes com dicionários no Banco de Dados."

		If lAuto
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( "LOG DA ATUALIZAÇÃO DOS DICIONÁRIOS" )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( cMsg )
			ConOut( DToC(Date()) + "|" + Time() + cMsg )
		Else
			MsgInfo( cMsg )
		EndIf

		Return NIL
	EndIf

	If lAuto
		aMarcadas :={{ cEmpAmb, cFilAmb, "" }}
	Else
		aMarcadas := EscEmpresa()
	EndIf

	If !Empty( aMarcadas )
		If lAuto .OR. MsgNoYes( "Confirma a atualização dos dicionários ?", cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas, lAuto ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
			oProcess:Activate()

			If lAuto
				If lOk
					MsgStop( "Atualização realizada.", "UPDSX" )
				Else
					MsgStop( "Atualização não realizada.", "UPDSX" )
				EndIf
				dbCloseAll()
			Else
				If lOk
					Final( "Atualização realizada." )
				Else
					Final( "Atualização não realizada." )
				EndIf
			EndIf

		Else
			Final( "Atualização não realizada." )

		EndIf

	Else
		Final( "Atualização não realizada." )

	EndIf

EndIf

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSTProc

Função de processamento da gravação dos arquivos

@author UPDATE gerado automaticamente
@since  04/10/2023
@obs    Gerado por EXPORDIC - V.7.5.3.3 EFS / Upd. V.5.4.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSTProc( lEnd, aMarcadas, lAuto )
Local   aInfo     := {}
Local   aRecnoSM0 := {}
Local   cAux      := ""
Local   cFile     := ""
Local   cFileLog  := ""
Local   cMask     := "Arquivos Texto" + "(*.TXT)|*.txt|"
Local   cTCBuild  := "TCGetBuild"
Local   cTexto    := ""
Local   cTopBuild := ""
Local   lOpen     := .F.
Local   lRet      := .T.
Local   nI        := 0
Local   nPos      := 0
Local   nRecno    := 0
Local   nX        := 0
Local   oDlg      := NIL
Local   oFont     := NIL
Local   oMemo     := NIL

Private aArqUpd   := {}

If ( lOpen := MyOpenSm0(.T.) )

	dbSelectArea( "SM0" )
	dbGoTop()

	While !SM0->( EOF() )
		// Só adiciona no aRecnoSM0 se a empresa for diferente
		If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 ;
		   .AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0
			aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO } )
		EndIf
		SM0->( dbSkip() )
	End

	SM0->( dbCloseArea() )

	If lOpen

		For nI := 1 To Len( aRecnoSM0 )

			If !( lOpen := MyOpenSm0(.F.) )
				MsgStop( "Atualização da empresa " + aRecnoSM0[nI][2] + " não efetuada." )
				Exit
			EndIf

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( "LOG DA ATUALIZAÇÃO DOS DICIONÁRIOS" )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )
			AutoGrLog( " Dados Ambiente" )
			AutoGrLog( " --------------------" )
			AutoGrLog( " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt )
			AutoGrLog( " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " DataBase...........: " + DtoC( dDataBase ) )
			AutoGrLog( " Data / Hora Ínicio.: " + DtoC( Date() )  + " / " + Time() )
			AutoGrLog( " Environment........: " + GetEnvServer()  )
			AutoGrLog( " StartPath..........: " + GetSrvProfString( "StartPath", "" ) )
			AutoGrLog( " RootPath...........: " + GetSrvProfString( "RootPath" , "" ) )
			AutoGrLog( " Versão.............: " + GetVersao(.T.) )
			AutoGrLog( " Usuário TOTVS .....: " + __cUserId + " " +  cUserName )
			AutoGrLog( " Computer Name......: " + GetComputerName() )

			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				AutoGrLog( " " )
				AutoGrLog( " Dados Thread" )
				AutoGrLog( " --------------------" )
				AutoGrLog( " Usuário da Rede....: " + aInfo[nPos][1] )
				AutoGrLog( " Estação............: " + aInfo[nPos][2] )
				AutoGrLog( " Programa Inicial...: " + aInfo[nPos][5] )
				AutoGrLog( " Environment........: " + aInfo[nPos][6] )
				AutoGrLog( " Conexão............: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) ) )
			EndIf
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )

			If !lAuto
				AutoGrLog( Replicate( "-", 128 ) )
				AutoGrLog( "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF )
			EndIf

			oProcess:SetRegua1( 8 )

			//------------------------------------
			// Atualiza o dicionário SX2
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de arquivos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX2()

			//------------------------------------
			// Atualiza o dicionário SX3
			//------------------------------------
			FSAtuSX3()

			//------------------------------------
			// Atualiza o dicionário SIX
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de índices" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSIX()

			oProcess:IncRegua1( "Dicionário de dados" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			oProcess:IncRegua2( "Atualizando campos/índices" )

			// Alteração física dos arquivos
			__SetX31Mode( .F. )

			If FindFunction(cTCBuild)
				cTopBuild := &cTCBuild.()
			EndIf

			For nX := 1 To Len( aArqUpd )

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					If ( ( aArqUpd[nX] >= "NQ " .AND. aArqUpd[nX] <= "NZZ" ) .OR. ( aArqUpd[nX] >= "O0 " .AND. aArqUpd[nX] <= "NZZ" ) ) .AND.;
						!aArqUpd[nX] $ "NQD,NQF,NQP,NQT"
						TcInternal( 25, "CLOB" )
					EndIf
				EndIf

				If Select( aArqUpd[nX] ) > 0
					dbSelectArea( aArqUpd[nX] )
					dbCloseArea()
				EndIf

				X31UpdTable( aArqUpd[nX] )

				If __GetX31Error()
					Alert( __GetX31Trace() )
					MsgStop( "Ocorreu um erro desconhecido durante a atualização da tabela : " + aArqUpd[nX] + ". Verifique a integridade do dicionário e da tabela.", "ATENÇÃO" )
					AutoGrLog( "Ocorreu um erro desconhecido durante a atualização da estrutura da tabela : " + aArqUpd[nX] )
				EndIf

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					TcInternal( 25, "OFF" )
				EndIf

			Next nX

			//------------------------------------
			// Atualiza o dicionário SX6
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de parâmetros" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX6()

			//------------------------------------
			// Atualiza o dicionário SX7
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de gatilhos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX7()

			//------------------------------------
			// Atualiza os helps
			//------------------------------------
			oProcess:IncRegua1( "Helps de Campo" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuHlp()

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time() )
			AutoGrLog( Replicate( "-", 128 ) )

			RpcClearEnv()

		Next nI

		If !lAuto

			cTexto := LeLog()

			Define Font oFont Name "Mono AS" Size 5, 12

			Define MsDialog oDlg Title "Atualização concluida." From 3, 0 to 340, 417 Pixel

			@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			oMemo:oFont     := oFont

			Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
			Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
			MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel

			Activate MsDialog oDlg Center

		EndIf

	EndIf

Else

	lRet := .F.

EndIf

Return lRet


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX2

Função de processamento da gravação do SX2 - Arquivos

@author UPDATE gerado automaticamente
@since  04/10/2023
@obs    Gerado por EXPORDIC - V.7.5.3.3 EFS / Upd. V.5.4.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX2()
Local aEstrut   := {}
Local aSX2      := {}
Local cAlias    := ""
Local cCpoUpd   := "X2_ROTINA /X2_UNICO  /X2_DISPLAY/X2_SYSOBJ /X2_USROBJ /X2_POSLGT /"
Local cEmpr     := ""
Local cPath     := ""
Local nI        := 0
Local nJ        := 0

AutoGrLog( "Ínicio da Atualização" + " SX2" + CRLF )

aEstrut := { "X2_CHAVE"  , "X2_PATH"   , "X2_ARQUIVO", "X2_NOME"   , "X2_NOMESPA", "X2_NOMEENG", "X2_MODO"   , ;
             "X2_TTS"    , "X2_ROTINA" , "X2_PYME"   , "X2_UNICO"  , "X2_DISPLAY", "X2_SYSOBJ" , "X2_USROBJ" , ;
             "X2_POSLGT" , "X2_CLOB"   , "X2_AUTREC" , "X2_MODOEMP", "X2_MODOUN" , "X2_MODULO" }


dbSelectArea( "SX2" )
SX2->( dbSetOrder( 1 ) )
SX2->( dbGoTop() )
cPath := SX2->X2_PATH
cPath := IIf( Right( AllTrim( cPath ), 1 ) <> "\", PadR( AllTrim( cPath ) + "\", Len( cPath ) ), cPath )
cEmpr := Substr( SX2->X2_ARQUIVO, 4 )

//
// Tabela SZO
//
aAdd( aSX2, { ;
	'SZO'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'SZO'+cEmpr																, ; //X2_ARQUIVO
	'COMPLEMENTOS DE COMBUSTIVEIS'											, ; //X2_NOME
	'COMPLEMENTOS DE COMBUSTIVEIS'											, ; //X2_NOMESPA
	'COMPLEMENTOS DE COMBUSTIVEIS'											, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela SZZ
//
aAdd( aSX2, { ;
	'SZZ'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'SZZ'+cEmpr																, ; //X2_ARQUIVO
	'MENSAGENS'																, ; //X2_NOME
	'MENSAGENS'																, ; //X2_NOMESPA
	'MENSAGENS'																, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela U00
//
aAdd( aSX2, { ;
	'U00'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'U00'+cEmpr																, ; //X2_ARQUIVO
	'MANUTENCAO DE BOMBAS'													, ; //X2_NOME
	'MANUTENCAO DE BOMBAS'													, ; //X2_NOMESPA
	'MANUTENCAO DE BOMBAS'													, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela U01
//
aAdd( aSX2, { ;
	'U01'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'U01'+cEmpr																, ; //X2_ARQUIVO
	'MANUTENCAO LACRE'														, ; //X2_NOME
	'MANUTENCAO LACRE'														, ; //X2_NOMESPA
	'MANUTENCAO LACRE'														, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela U02
//
aAdd( aSX2, { ;
	'U02'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'U02'+cEmpr																, ; //X2_ARQUIVO
	'MANUTENCAO BICO'														, ; //X2_NOME
	'MANUTENCAO BICO'														, ; //X2_NOMESPA
	'MANUTENCAO BICO'														, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela U03
//
aAdd( aSX2, { ;
	'U03'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'U03'+cEmpr																, ; //X2_ARQUIVO
	'CABECALHO ALCADA'														, ; //X2_NOME
	'CABECALHO ALCADA'														, ; //X2_NOMESPA
	'CABECALHO ALCADA'														, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela U04
//
aAdd( aSX2, { ;
	'U04'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'U04'+cEmpr																, ; //X2_ARQUIVO
	'ITENS ALCADA DESCONTO'													, ; //X2_NOME
	'ITENS ALCADA DESCONTO'													, ; //X2_NOMESPA
	'ITENS ALCADA DESCONTO'													, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela U0A
//
aAdd( aSX2, { ;
	'U0A'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'U0A'+cEmpr																, ; //X2_ARQUIVO
	'Tipo de Preco Base'													, ; //X2_NOME
	'Tipo de Preco Base'													, ; //X2_NOMESPA
	'Tipo de Preco Base'													, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela U0B
//
aAdd( aSX2, { ;
	'U0B'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'U0B'+cEmpr																, ; //X2_ARQUIVO
	'Tabela de Preco Base'													, ; //X2_NOME
	'Tabela de Preco Base'													, ; //X2_NOMESPA
	'Tabela de Preco Base'													, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela U0C
//
aAdd( aSX2, { ;
	'U0C'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'U0C'+cEmpr																, ; //X2_ARQUIVO
	'Itens Tabela de Preco Base'											, ; //X2_NOME
	'Itens Tabela de Preco Base'											, ; //X2_NOMESPA
	'Itens Tabela de Preco Base'											, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela U0D
//
aAdd( aSX2, { ;
	'U0D'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'U0D'+cEmpr																, ; //X2_ARQUIVO
	'Alcadas Diversas'														, ; //X2_NOME
	'Alcadas Diversas'														, ; //X2_NOMESPA
	'Alcadas Diversas'														, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela U0E
//
aAdd( aSX2, { ;
	'U0E'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'U0E'+cEmpr																, ; //X2_ARQUIVO
	'Log Liberacao por Alcada'												, ; //X2_NOME
	'Log Liberacao por Alcada'												, ; //X2_NOMESPA
	'Log Liberacao por Alcada'												, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela U0F
//
aAdd( aSX2, { ;
	'U0F'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'U0F'+cEmpr																, ; //X2_ARQUIVO
	'MOTIVO DE DEVOLUCAO'													, ; //X2_NOME
	'MOTIVO DE DEVOLUCAO'													, ; //X2_NOMESPA
	'MOTIVO DE DEVOLUCAO'													, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela U0G
//
aAdd( aSX2, { ;
	'U0G'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'U0G'+cEmpr																, ; //X2_ARQUIVO
	'Hist. Itens Tabela de P. Base'											, ; //X2_NOME
	'Hist. Itens Tabela de P. Base'											, ; //X2_NOMESPA
	'Hist. Itens Tabela de P. Base'											, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela U0H
//
aAdd( aSX2, { ;
	'U0H'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'U0H'+cEmpr																, ; //X2_ARQUIVO
	'Hist. Movim. Processos Venda'											, ; //X2_NOME
	'Hist. Movim. Processos Venda'											, ; //X2_NOMESPA
	'Hist. Movim. Processos Venda'											, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'S'																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela U0I
//
aAdd( aSX2, { ;
	'U0I'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'U0I'+cEmpr																, ; //X2_ARQUIVO
	'Historico de Vendas LMC'												, ; //X2_NOME
	'Historico de Vendas LMC'												, ; //X2_NOMESPA
	'Historico de Vendas LMC'												, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela U0J
//
aAdd( aSX2, { ;
	'U0J'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'U0J'+cEmpr																, ; //X2_ARQUIVO
	'Log Exclusao Faturas'													, ; //X2_NOME
	'Log Exclusao Faturas'													, ; //X2_NOMESPA
	'Log Exclusao Faturas'													, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela U25
//
aAdd( aSX2, { ;
	'U25'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'U25'+cEmpr																, ; //X2_ARQUIVO
	'NEGOCIACAO DE PRECOS'													, ; //X2_NOME
	'NEGOCIACAO DE PRECOS'													, ; //X2_NOMESPA
	'NEGOCIACAO DE PRECOS'													, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela U44
//
aAdd( aSX2, { ;
	'U44'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'U44'+cEmpr																, ; //X2_ARQUIVO
	'NEGOCIACAO DE PAGAMENTO'												, ; //X2_NOME
	'NEGOCIACAO DE PAGAMENTO'												, ; //X2_NOMESPA
	'NEGOCIACAO DE PAGAMENTO'												, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela U52
//
aAdd( aSX2, { ;
	'U52'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'U52'+cEmpr																, ; //X2_ARQUIVO
	'NEGOCIACAO PAGTO POR CLIENTES'											, ; //X2_NOME
	'NEGOCIACAO PAGTO POR CLIENTES'											, ; //X2_NOMESPA
	'NEGOCIACAO PAGTO POR CLIENTES'											, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela U53
//
aAdd( aSX2, { ;
	'U53'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'U53'+cEmpr																, ; //X2_ARQUIVO
	'ITENS NEGOCIACAO PGTO POR CLIE'										, ; //X2_NOME
	'ITENS NEGOCIACAO PGTO POR CLIE'										, ; //X2_NOMESPA
	'ITENS NEGOCIACAO PGTO POR CLIE'										, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela U56
//
aAdd( aSX2, { ;
	'U56'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'U56'+cEmpr																, ; //X2_ARQUIVO
	'CABECALHO DA REQUISICAO'												, ; //X2_NOME
	'CABECALHO DA REQUISICAO'												, ; //X2_NOMESPA
	'CABECALHO DA REQUISICAO'												, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela U57
//
aAdd( aSX2, { ;
	'U57'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'U57'+cEmpr																, ; //X2_ARQUIVO
	'PARCELAS DA REQUISICAO'												, ; //X2_NOME
	'PARCELAS DA REQUISICAO'												, ; //X2_NOMESPA
	'PARCELAS DA REQUISICAO'												, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela U59
//
aAdd( aSX2, { ;
	'U59'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'U59'+cEmpr																, ; //X2_ARQUIVO
	'ESTOQUE DE EXPOSICAO'													, ; //X2_NOME
	'ESTOQUE DE EXPOSICAO'													, ; //X2_NOMESPA
	'ESTOQUE DE EXPOSICAO'													, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela U65
//
aAdd( aSX2, { ;
	'U65'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'U65'+cEmpr																, ; //X2_ARQUIVO
	'CONCENTRADORAS'														, ; //X2_NOME
	'CONCENTRADORAS'														, ; //X2_NOMESPA
	'CONCENTRADORAS'														, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela U68
//
aAdd( aSX2, { ;
	'U68'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'U68'+cEmpr																, ; //X2_ARQUIVO
	'CARTAO IDENTFID'														, ; //X2_NOME
	'CARTAO IDENTFID'														, ; //X2_NOMESPA
	'CARTAO IDENTFID'														, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela U69
//
aAdd( aSX2, { ;
	'U69'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'U69'+cEmpr																, ; //X2_ARQUIVO
	'LOG TROCA DE CLIENTES NO CF'											, ; //X2_NOME
	'.'																		, ; //X2_NOMESPA
	'.'																		, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela U72
//
aAdd( aSX2, { ;
	'U72'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'U72'+cEmpr																, ; //X2_ARQUIVO
	'MEDIDOR DE TANQUE'														, ; //X2_NOME
	'MEDIDOR DE TANQUE'														, ; //X2_NOMESPA
	'MEDIDOR DE TANQUE'														, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela U88
//
aAdd( aSX2, { ;
	'U88'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'U88'+cEmpr																, ; //X2_ARQUIVO
	'CONFIGURAR FATURAMENTO'												, ; //X2_NOME
	'CONFIGURAR FATURAMENTO'												, ; //X2_NOMESPA
	'CONFIGURAR FATURAMENTO'												, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela U92
//
aAdd( aSX2, { ;
	'U92'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'U92'+cEmpr																, ; //X2_ARQUIVO
	'TABELA DE RECADOS'														, ; //X2_NOME
	'TABELA DE RECADOS'														, ; //X2_NOMESPA
	'TABELA DE RECADOS'														, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela U98
//
aAdd( aSX2, { ;
	'U98'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'U98'+cEmpr																, ; //X2_ARQUIVO
	'ADM. FIN. X LAYOUT (CAB)'												, ; //X2_NOME
	'ADM. FIN. X LAYOUT (CAB)'												, ; //X2_NOMESPA
	'ADM. FIN. X LAYOUT (CAB)'												, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela U99
//
aAdd( aSX2, { ;
	'U99'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'U99'+cEmpr																, ; //X2_ARQUIVO
	'ITENS ADM. FIN. X LAYOUT'												, ; //X2_NOME
	'ITENS ADM. FIN. X LAYOUT'												, ; //X2_NOMESPA
	'ITENS ADM. FIN. X LAYOUT'												, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela UB1
//
aAdd( aSX2, { ;
	'UB1'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'UB1'+cEmpr																, ; //X2_ARQUIVO
	'MARGENS LUCRO NEGOCIADAS'												, ; //X2_NOME
	'MARGENS LUCRO NEGOCIADAS'												, ; //X2_NOMESPA
	'MARGENS LUCRO NEGOCIADAS'												, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela UB4
//
aAdd( aSX2, { ;
	'UB4'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'UB4'+cEmpr																, ; //X2_ARQUIVO
	'NUMERACAO LMC'															, ; //X2_NOME
	'NUMERACAO LMC'															, ; //X2_NOMESPA
	'NUMERACAO LMC'															, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela UC0
//
aAdd( aSX2, { ;
	'UC0'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'UC0'+cEmpr																, ; //X2_ARQUIVO
	'COMPENSACAO - CAB'														, ; //X2_NOME
	'COMPENSACAO - CAB'														, ; //X2_NOMESPA
	'COMPENSACAO - CAB'														, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela UC1
//
aAdd( aSX2, { ;
	'UC1'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'UC1'+cEmpr																, ; //X2_ARQUIVO
	'COMPENSACAO - FORMAS'													, ; //X2_NOME
	'COMPENSACAO - FORMAS'													, ; //X2_NOMESPA
	'COMPENSACAO - FORMAS'													, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela UC2
//
aAdd( aSX2, { ;
	'UC2'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'UC2'+cEmpr																, ; //X2_ARQUIVO
	'ACESSO FUNCOES CUSTOMIZ.'												, ; //X2_NOME
	'ACESSO FUNCOES CUSTOMIZ.'												, ; //X2_NOMESPA
	'ACESSO FUNCOES CUSTOMIZ.'												, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela UC3
//
aAdd( aSX2, { ;
	'UC3'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'UC3'+cEmpr																, ; //X2_ARQUIVO
	'Segmentos Limite Credito'												, ; //X2_NOME
	'Segmentos Limite Credito'												, ; //X2_NOMESPA
	'Segmentos Limite Credito'												, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela UC4
//
aAdd( aSX2, { ;
	'UC4'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'UC4'+cEmpr																, ; //X2_ARQUIVO
	'Limites Cliente por Segmento'											, ; //X2_NOME
	'Limites Cliente por Segmento'											, ; //X2_NOMESPA
	'Limites Cliente por Segmento'											, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela UC5
//
aAdd( aSX2, { ;
	'UC5'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'UC5'+cEmpr																, ; //X2_ARQUIVO
	'Filial X Segmentos Limite'												, ; //X2_NOME
	'Filial X Segmentos Limite'												, ; //X2_NOMESPA
	'Filial X Segmentos Limite'												, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela UCA
//
aAdd( aSX2, { ;
	'UCA'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'UCA'+cEmpr																, ; //X2_ARQUIVO
	'CARGA SOBRE REGISTRO'													, ; //X2_NOME
	'CARGA SOBRE REGISTRO'													, ; //X2_NOMESPA
	'CARGA SOBRE REGISTRO'													, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela UF1
//
aAdd( aSX2, { ;
	'UF1'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'UF1'+cEmpr																, ; //X2_ARQUIVO
	'CADASTRO DE LOTE DE CHEQUE TRO'										, ; //X2_NOME
	'CADASTRO DE LOTE DE CHEQUE TRO'										, ; //X2_NOMESPA
	'CADASTRO DE LOTE DE CHEQUE TRO'										, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela UF2
//
aAdd( aSX2, { ;
	'UF2'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'UF2'+cEmpr																, ; //X2_ARQUIVO
	'CHEQUES TROCO'															, ; //X2_NOME
	'CHEQUES TROCO'															, ; //X2_NOMESPA
	'CHEQUES TROCO'															, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela UF6
//
aAdd( aSX2, { ;
	'UF6'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'UF6'+cEmpr																, ; //X2_ARQUIVO
	'CLASSE CLIENTE'														, ; //X2_NOME
	'CLASSE CLIENTE'														, ; //X2_NOMESPA
	'CLASSE CLIENTE'														, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela UH6
//
aAdd( aSX2, { ;
	'UH6'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'UH6'+cEmpr																, ; //X2_ARQUIVO
	'REGRA CALCULO SUBST TRIB NF'											, ; //X2_NOME
	'REGRA CALCULO SUBST TRIB NF'											, ; //X2_NOMESPA
	'REGRA CALCULO SUBST TRIB NF'											, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela UH7
//
aAdd( aSX2, { ;
	'UH7'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'UH7'+cEmpr																, ; //X2_ARQUIVO
	'ITENS REGRA CALCULO SUBST TRIB'										, ; //X2_NOME
	'ITENS REGRA CALCULO SUBST TRIB'										, ; //X2_NOMESPA
	'ITENS REGRA CALCULO SUBST TRIB'										, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela UH8
//
aAdd( aSX2, { ;
	'UH8'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'UH8'+cEmpr																, ; //X2_ARQUIVO
	'SERVICOS PRESTADOS FORNECEDOR'											, ; //X2_NOME
	'SERVICOS PRESTADOS FORNECEDOR'											, ; //X2_NOMESPA
	'SERVICOS PRESTADOS FORNECEDOR'											, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela UH9
//
aAdd( aSX2, { ;
	'UH9'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'UH9'+cEmpr																, ; //X2_ARQUIVO
	'ITENS SERIVICOS PRESTADOS'												, ; //X2_NOME
	'ITENS SERIVICOS PRESTADOS'												, ; //X2_NOMESPA
	'ITENS SERIVICOS PRESTADOS'												, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela UI0
//
aAdd( aSX2, { ;
	'UI0'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'UI0'+cEmpr																, ; //X2_ARQUIVO
	'PRECOS NEGOCIADOS VLS'													, ; //X2_NOME
	'PRECOS NEGOCIADOS VLS'													, ; //X2_NOMESPA
	'PRECOS NEGOCIADOS VLS'													, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela UI1
//
aAdd( aSX2, { ;
	'UI1'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'UI1'+cEmpr																, ; //X2_ARQUIVO
	'FORNEC. PRECOS NEGOCIADOS VLS'											, ; //X2_NOME
	'FORNEC. PRECOS NEGOCIADOS VLS'											, ; //X2_NOMESPA
	'FORNEC. PRECOS NEGOCIADOS VLS'											, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela UIB
//
aAdd( aSX2, { ;
	'UIB'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'UIB'+cEmpr																, ; //X2_ARQUIVO
	'PRODUTOS PRECOS NEGOCIADOS VLS'										, ; //X2_NOME
	'PRODUTOS PRECOS NEGOCIADOS VLS'										, ; //X2_NOMESPA
	'PRODUTOS PRECOS NEGOCIADOS VLS'										, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela UIC
//
aAdd( aSX2, { ;
	'UIC'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'UIC'+cEmpr																, ; //X2_ARQUIVO
	'VALES SERVICO'															, ; //X2_NOME
	'VALES SERVICO'															, ; //X2_NOMESPA
	'VALES SERVICO'															, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela Z01
//
aAdd( aSX2, { ;
	'Z01'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'Z01'+cEmpr																, ; //X2_ARQUIVO
	'Gerenciador de Integração'												, ; //X2_NOME
	'Gerenciador de Integração'												, ; //X2_NOMESPA
	'Gerenciador de Integração'												, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela Z02
//
aAdd( aSX2, { ;
	'Z02'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'Z02'+cEmpr																, ; //X2_ARQUIVO
	'Cadastro de Sub Grupos'												, ; //X2_NOME
	'Cadastro de Sub Grupos'												, ; //X2_NOMESPA
	'Cadastro de Sub Grupos'												, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela Z03
//
aAdd( aSX2, { ;
	'Z03'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'Z03'+cEmpr																, ; //X2_ARQUIVO
	'Controle de Fechament Caixa'											, ; //X2_NOME
	'Controle de Fechament Caixa'											, ; //X2_NOMESPA
	'Controle de Fechament Caixa'											, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela Z04
//
aAdd( aSX2, { ;
	'Z04'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'Z04'+cEmpr																, ; //X2_ARQUIVO
	'Dados Inventário x Saldo'												, ; //X2_NOME
	'Dados Inventário x Saldo'												, ; //X2_NOMESPA
	'Dados Inventário x Saldo'												, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela ZC0
//
aAdd( aSX2, { ;
	'ZC0'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZC0'+cEmpr																, ; //X2_ARQUIVO
	'CABEC. HISTORICO DE COBRANÇA'											, ; //X2_NOME
	'CABEC. HISTORICO DE COBRANÇA'											, ; //X2_NOMESPA
	'CABEC. HISTORICO DE COBRANÇA'											, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	'ZC0_FILIAL+ZC0_CODNEG'													, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	'1'																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela ZC1
//
aAdd( aSX2, { ;
	'ZC1'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZC1'+cEmpr																, ; //X2_ARQUIVO
	'ITENS - NEGOCIAÇÃO DE COBRANÇA'										, ; //X2_NOME
	'ITENS - NEGOCIAÇÃO DE COBRANÇA'										, ; //X2_NOMESPA
	'ITENS - NEGOCIAÇÃO DE COBRANÇA'										, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	'ZC1_FILIAL+ZC1_CODNEG+ZC1_ITENEG'										, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	'1'																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela ZE0
//
aAdd( aSX2, { ;
	'ZE0'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZE0'+cEmpr																, ; //X2_ARQUIVO
	'Cad. Tanques Fisicos'													, ; //X2_NOME
	'Cad. Tanques Fisicos'													, ; //X2_NOMESPA
	'Cad. Tanques Fisicos'													, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela ZE3
//
aAdd( aSX2, { ;
	'ZE3'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZE3'+cEmpr																, ; //X2_ARQUIVO
	'CABECALHO DE CRC'														, ; //X2_NOME
	'CABECALHO DE CRC'														, ; //X2_NOMESPA
	'CABECALHO DE CRC'														, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela ZE4
//
aAdd( aSX2, { ;
	'ZE4'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZE4'+cEmpr																, ; //X2_ARQUIVO
	'ITENS CRC'																, ; //X2_NOME
	'ITENS CRC'																, ; //X2_NOMESPA
	'ITENS CRC'																, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela ZE5
//
aAdd( aSX2, { ;
	'ZE5'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZE5'+cEmpr																, ; //X2_ARQUIVO
	'CAD. AMOSTRAS CRC'														, ; //X2_NOME
	'CAD. AMOSTRAS CRC'														, ; //X2_NOMESPA
	'CAD. AMOSTRAS CRC'														, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela ZE6
//
aAdd( aSX2, { ;
	'ZE6'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZE6'+cEmpr																, ; //X2_ARQUIVO
	'Cab. Volumetria Tanque'												, ; //X2_NOME
	'Cab. Volumetria Tanque'												, ; //X2_NOMESPA
	'Cab. Volumetria Tanque'												, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela ZE7
//
aAdd( aSX2, { ;
	'ZE7'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZE7'+cEmpr																, ; //X2_ARQUIVO
	'Itens Volumetria Tanque'												, ; //X2_NOME
	'Itens Volumetria Tanque'												, ; //X2_NOMESPA
	'Itens Volumetria Tanque'												, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela ZL1
//
aAdd( aSX2, { ;
	'ZL1'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZL1'+cEmpr																, ; //X2_ARQUIVO
	'Orçamento'																, ; //X2_NOME
	'Presupuesto'															, ; //X2_NOMESPA
	'Quotation'																, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'S'																		, ; //X2_PYME
	'ZL1_FILIAL+ZL1_NUM'													, ; //X2_UNICO
	'ZL1_NUM+ZL1_CLIENTE+ZL1_LOJA'											, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	'1'																		, ; //X2_POSLGT
	'1'																		, ; //X2_CLOB
	'2'																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela ZL2
//
aAdd( aSX2, { ;
	'ZL2'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZL2'+cEmpr																, ; //X2_ARQUIVO
	'Itens do Orçamento'													, ; //X2_NOME
	'Ítems del Presupuesto'													, ; //X2_NOMESPA
	'Quotation Items'														, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'S'																		, ; //X2_PYME
	'ZL2_FILIAL+ZL2_NUM+ZL2_ITEM'											, ; //X2_UNICO
	'ZL2_NUM+ZL2_ITEM+ZL2_DESCRI'											, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	'1'																		, ; //X2_POSLGT
	'1'																		, ; //X2_CLOB
	'2'																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela ZL4
//
aAdd( aSX2, { ;
	'ZL4'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZL4'+cEmpr																, ; //X2_ARQUIVO
	'Condição Negociada'													, ; //X2_NOME
	'Condición Negociada'													, ; //X2_NOMESPA
	'Condition Negotiated'													, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'S'																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	'ZL4_NUM+ZL4_DATA+ZL4_FORMA+ZL4_VALOR'									, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	'1'																		, ; //X2_POSLGT
	'1'																		, ; //X2_CLOB
	'2'																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela ZZA
//
aAdd( aSX2, { ;
	'ZZA'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZZA'+cEmpr																, ; //X2_ARQUIVO
	'Inventário - Registros Importa'										, ; //X2_NOME
	'Inventário - Registros Importa'										, ; //X2_NOMESPA
	'Inventário - Registros Importa'										, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela ZZL
//
aAdd( aSX2, { ;
	'ZZL'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZZL'+cEmpr																, ; //X2_ARQUIVO
	'REGRAS DE VALIDACAO DO XML'											, ; //X2_NOME
	'REGRAS DE VALIDACAO DO XML'											, ; //X2_NOMESPA
	'REGRAS DE VALIDACAO DO XML'											, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'S'																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	97																		} ) //X2_MODULO

//
// Tabela ZZM
//
aAdd( aSX2, { ;
	'ZZM'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZZM'+cEmpr																, ; //X2_ARQUIVO
	'LOG DE OCORRENCIAS VAL. XML'											, ; //X2_NOME
	'LOG DE OCORRENCIAS VAL. XML'											, ; //X2_NOMESPA
	'LOG DE OCORRENCIAS VAL. XML'											, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'S'																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	97																		} ) //X2_MODULO

//
// Tabela ZZS
//
aAdd( aSX2, { ;
	'ZZS'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZZS'+cEmpr																, ; //X2_ARQUIVO
	'EXPRESSOES VAL. XML'													, ; //X2_NOME
	'EXPRESSOES VAL. XML'													, ; //X2_NOMESPA
	'EXPRESSOES VAL. XML'													, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'S'																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	97																		} ) //X2_MODULO

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX2 ) )

dbSelectArea( "SX2" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX2 )

	oProcess:IncRegua2( "Atualizando Arquivos (SX2) ..." )

	If !SX2->( dbSeek( aSX2[nI][1] ) )

		If !( aSX2[nI][1] $ cAlias )
			cAlias += aSX2[nI][1] + "/"
			AutoGrLog( "Foi incluída a tabela " + aSX2[nI][1] )
		EndIf

		RecLock( "SX2", .T. )
		For nJ := 1 To Len( aSX2[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				If AllTrim( aEstrut[nJ] ) == "X2_ARQUIVO"
					FieldPut( FieldPos( aEstrut[nJ] ), SubStr( aSX2[nI][nJ], 1, 3 ) + cEmpAnt +  "0" )
				Else
					FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
				EndIf
			EndIf
		Next nJ
		MsUnLock()

	Else

		If  !( StrTran( Upper( AllTrim( SX2->X2_UNICO ) ), " ", "" ) == StrTran( Upper( AllTrim( aSX2[nI][12]  ) ), " ", "" ) )
			RecLock( "SX2", .F. )
			SX2->X2_UNICO := aSX2[nI][12]
			MsUnlock()

			If MSFILE( RetSqlName( aSX2[nI][1] ),RetSqlName( aSX2[nI][1] ) + "_UNQ"  )
				TcInternal( 60, RetSqlName( aSX2[nI][1] ) + "|" + RetSqlName( aSX2[nI][1] ) + "_UNQ" )
			EndIf

			AutoGrLog( "Foi alterada a chave única da tabela " + aSX2[nI][1] )
		EndIf

		RecLock( "SX2", .F. )
		For nJ := 1 To Len( aSX2[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				If PadR( aEstrut[nJ], 10 ) $ cCpoUpd
					FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
				EndIf

			EndIf
		Next nJ
		MsUnLock()

	EndIf

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX2" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX3

Função de processamento da gravação do SX3 - Campos

@author UPDATE gerado automaticamente
@since  04/10/2023
@obs    Gerado por EXPORDIC - V.7.5.3.3 EFS / Upd. V.5.4.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX3()
Local aEstrut   := {}
Local aSX3      := {}
Local cAlias    := ""
Local cAliasAtu := ""
Local cMsg      := ""
Local cSeqAtu   := ""
Local cX3Campo  := ""
Local cX3Dado   := ""
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nPosArq   := 0
Local nPosCpo   := 0
Local nPosOrd   := 0
Local nPosSXG   := 0
Local nPosTam   := 0
Local nPosVld   := 0
Local nSeqAtu   := 0
Local nTamSeek  := Len( SX3->X3_CAMPO )

AutoGrLog( "Ínicio da Atualização" + " SX3" + CRLF )

aEstrut := { { "X3_ARQUIVO", 0 }, { "X3_ORDEM"  , 0 }, { "X3_CAMPO"  , 0 }, { "X3_TIPO"   , 0 }, { "X3_TAMANHO", 0 }, { "X3_DECIMAL", 0 }, { "X3_TITULO" , 0 }, ;
             { "X3_TITSPA" , 0 }, { "X3_TITENG" , 0 }, { "X3_DESCRIC", 0 }, { "X3_DESCSPA", 0 }, { "X3_DESCENG", 0 }, { "X3_PICTURE", 0 }, { "X3_VALID"  , 0 }, ;
             { "X3_USADO"  , 0 }, { "X3_RELACAO", 0 }, { "X3_F3"     , 0 }, { "X3_NIVEL"  , 0 }, { "X3_RESERV" , 0 }, { "X3_CHECK"  , 0 }, { "X3_TRIGGER", 0 }, ;
             { "X3_PROPRI" , 0 }, { "X3_BROWSE" , 0 }, { "X3_VISUAL" , 0 }, { "X3_CONTEXT", 0 }, { "X3_OBRIGAT", 0 }, { "X3_VLDUSER", 0 }, { "X3_CBOX"   , 0 }, ;
             { "X3_CBOXSPA", 0 }, { "X3_CBOXENG", 0 }, { "X3_PICTVAR", 0 }, { "X3_WHEN"   , 0 }, { "X3_INIBRW" , 0 }, { "X3_GRPSXG" , 0 }, { "X3_FOLDER" , 0 }, ;
             { "X3_CONDSQL", 0 }, { "X3_CHKSQL" , 0 }, { "X3_IDXSRV" , 0 }, { "X3_ORTOGRA", 0 }, { "X3_TELA"   , 0 }, { "X3_POSLGT" , 0 }, { "X3_IDXFLD" , 0 }, ;
             { "X3_AGRUP"  , 0 }, { "X3_MODAL"  , 0 }, { "X3_PYME"   , 0 } }

aEval( aEstrut, { |x| x[2] := SX3->( FieldPos( x[1] ) ) } )


//
// Campos Tabela SA1
//
aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'EW'																	, ; //X3_ORDEM
	'A1_XOBSFAT'															, ; //X3_CAMPO
	'M'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Obs.Faturame'															, ; //X3_TITULO
	'Obs.Faturame'															, ; //X3_TITSPA
	'Obs.Faturame'															, ; //X3_TITENG
	'Observacoes Faturamento'												, ; //X3_DESCRIC
	'Observacoes Faturamento'												, ; //X3_DESCSPA
	'Observacoes Faturamento'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela SLW
//
aAdd( aSX3, { ;
	'SLW'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'LW_XNOME'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	40																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nome Caixa'															, ; //X3_TITULO
	'Nome Caixa'															, ; //X3_TITSPA
	'Nome Caixa'															, ; //X3_TITENG
	'Nome Caixa'															, ; //X3_DESCRIC
	'Nome Caixa'															, ; //X3_DESCSPA
	'Nome Caixa'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	'Posicione("SA6",1,xFilial("SA6")+SLW->LW_OPERADO,"A6_NOME")'			, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SLW'																	, ; //X3_ARQUIVO
	'20'																	, ; //X3_ORDEM
	'LW_XFLTCX'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	9																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Sobra/Falta'															, ; //X3_TITULO
	'Sobra/Falta'															, ; //X3_TITSPA
	'Sobra/Falta'															, ; //X3_TITENG
	'Sobra/Falta'															, ; //X3_DESCRIC
	'Sobra/Falta'															, ; //X3_DESCSPA
	'Sobra/Falta'															, ; //X3_DESCENG
	'@E 999,999.99'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela U03
//
aAdd( aSX3, { ;
	'U03'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'U03_GRUPO'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Grp. Usuario'															, ; //X3_TITULO
	'Grp. Usuario'															, ; //X3_TITSPA
	'Grp. Usuario'															, ; //X3_TITENG
	'Grupo de usuario'														, ; //X3_DESCRIC
	'Grupo de usuario'														, ; //X3_DESCSPA
	'Grupo de usuario'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'GRP'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'  xxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	"IIF(INCLUI .AND. FUNNAME()=='TRETA037',U_TRETA37D(1),.T.)"				, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'Empty(M->U03_USER)'													, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	''																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'U03'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'U03_USER'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Usuario'																, ; //X3_TITULO
	'Usuario'																, ; //X3_TITSPA
	'Usuario'																, ; //X3_TITENG
	'Usuario'																, ; //X3_DESCRIC
	'Usuario'																, ; //X3_DESCSPA
	'Usuario'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'USR'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'  xxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	"IIF(INCLUI .AND. FUNNAME()=='TRETA037',U_TRETA37D(1),.T.)"				, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'Empty(M->U03_GRUPO)'													, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	''																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela U92
//
aAdd( aSX3, { ;
	'U92'																	, ; //X3_ARQUIVO
	'13'																	, ; //X3_ORDEM
	'U92_PERMAN'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Permanente?'															, ; //X3_TITULO
	'Permanente?'															, ; //X3_TITSPA
	'Permanente?'															, ; //X3_TITENG
	'Recado Permanente?'													, ; //X3_DESCRIC
	'Recado Permanente?'													, ; //X3_DESCSPA
	'Recado Permanente?'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'  xxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Sim;2=Nao'															, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'U92'																	, ; //X3_ARQUIVO
	'16'																	, ; //X3_ORDEM
	'U92_VISUAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Visualizacao'															, ; //X3_TITULO
	'Visualizacao'															, ; //X3_TITSPA
	'Visualizacao'															, ; //X3_TITENG
	'Momento Visualizacao'													, ; //X3_DESCRIC
	'Momento Visualizacao'													, ; //X3_DESCSPA
	'Momento Visualizacao'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	"'1'"																	, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'  xxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Ambos;2=Abertura;3=Fechamento'										, ; //X3_CBOX
	'1=Ambos;2=Abertura;3=Fechamento'										, ; //X3_CBOXSPA
	'1=Ambos;2=Abertura;3=Fechamento'										, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela U98
//
aAdd( aSX3, { ;
	'U98'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'U98_OPERAD'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Operadora'																, ; //X3_TITULO
	'Operadora'																, ; //X3_TITSPA
	'Operadora'																, ; //X3_TITENG
	'Codigo da Operadora'													, ; //X3_DESCRIC
	'Codigo da Operadora'													, ; //X3_DESCSPA
	'Codigo da Operadora'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'MDERED'																, ; //X3_F3
	0																		, ; //X3_NIVEL
	'  xxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Vazio() .Or. U_TR18VlRD(M->U98_OPERAD)'								, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela UH8
//
aAdd( aSX3, { ;
	'UH8'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'UH8_FORNEC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Fornecedor'															, ; //X3_TITULO
	'Fornecedor'															, ; //X3_TITSPA
	'Fornecedor'															, ; //X3_TITENG
	'Fornecedor'															, ; //X3_DESCRIC
	'Fornecedor'															, ; //X3_DESCSPA
	'Fornecedor'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SA2A'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'  xxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	"ExistCpo('SA2') .And. ExistChav('UH8',M->UH8_FORNEC+FwFldGet('UH8_LOJA'))"	, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'INCLUI'																, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'001'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'UH8'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'UH8_LOJA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Loja'																	, ; //X3_TITULO
	'Loja'																	, ; //X3_TITSPA
	'Loja'																	, ; //X3_TITENG
	'Loja'																	, ; //X3_DESCRIC
	'Loja'																	, ; //X3_DESCSPA
	'Loja'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'  xxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	"ExistChav('UH8',FwFldGet('UH8_FORNEC')+M->UH8_LOJA)"					, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'INCLUI'																, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'002'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME


//
// Atualizando dicionário
//
nPosArq := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ARQUIVO" } )
nPosOrd := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ORDEM"   } )
nPosCpo := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_CAMPO"   } )
nPosTam := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_TAMANHO" } )
nPosSXG := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_GRPSXG"  } )
nPosVld := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_VALID"   } )

aSort( aSX3,,, { |x,y| x[nPosArq]+x[nPosOrd]+x[nPosCpo] < y[nPosArq]+y[nPosOrd]+y[nPosCpo] } )

oProcess:SetRegua2( Len( aSX3 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )
cAliasAtu := ""

For nI := 1 To Len( aSX3 )

	//
	// Verifica se o campo faz parte de um grupo e ajusta tamanho
	//
	If !Empty( aSX3[nI][nPosSXG] )
		SXG->( dbSetOrder( 1 ) )
		If SXG->( MSSeek( aSX3[nI][nPosSXG] ) )
			If aSX3[nI][nPosTam] <> SXG->XG_SIZE
				aSX3[nI][nPosTam] := SXG->XG_SIZE
				AutoGrLog( "O tamanho do campo " + aSX3[nI][nPosCpo] + " NÃO atualizado e foi mantido em [" + ;
				AllTrim( Str( SXG->XG_SIZE ) ) + "]" + CRLF + ;
				" por pertencer ao grupo de campos [" + SXG->XG_GRUPO + "]" + CRLF )
			EndIf
		EndIf
	EndIf

	SX3->( dbSetOrder( 2 ) )

	If !( aSX3[nI][nPosArq] $ cAlias )
		cAlias += aSX3[nI][nPosArq] + "/"
		aAdd( aArqUpd, aSX3[nI][nPosArq] )
	EndIf

	If !SX3->( dbSeek( PadR( aSX3[nI][nPosCpo], nTamSeek ) ) )

		//
		// Busca ultima ocorrencia do alias
		//
		If ( aSX3[nI][nPosArq] <> cAliasAtu )
			cSeqAtu   := "00"
			cAliasAtu := aSX3[nI][nPosArq]

			dbSetOrder( 1 )
			SX3->( dbSeek( cAliasAtu + "ZZ", .T. ) )
			dbSkip( -1 )

			If ( SX3->X3_ARQUIVO == cAliasAtu )
				cSeqAtu := SX3->X3_ORDEM
			EndIf

			nSeqAtu := Val( RetAsc( cSeqAtu, 3, .F. ) )
		EndIf

		nSeqAtu++
		cSeqAtu := RetAsc( Str( nSeqAtu ), 2, .T. )

		RecLock( "SX3", .T. )
		For nJ := 1 To Len( aSX3[nI] )
			If     nJ == nPosOrd  // Ordem
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), cSeqAtu ) )

			ElseIf aEstrut[nJ][2] > 0
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), aSX3[nI][nJ] ) )

			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		AutoGrLog( "Criado campo " + aSX3[nI][nPosCpo] )

	EndIf

	oProcess:IncRegua2( "Atualizando Campos de Tabelas (SX3) ..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSIX

Função de processamento da gravação do SIX - Indices

@author UPDATE gerado automaticamente
@since  04/10/2023
@obs    Gerado por EXPORDIC - V.7.5.3.3 EFS / Upd. V.5.4.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSIX()
Local aEstrut   := {}
Local aSIX      := {}
Local lAlt      := .F.
Local lDelInd   := .F.
Local nI        := 0
Local nJ        := 0

AutoGrLog( "Ínicio da Atualização" + " SIX" + CRLF )

aEstrut := { "INDICE" , "ORDEM" , "CHAVE", "DESCRICAO", "DESCSPA"  , ;
             "DESCENG", "PROPRI", "F3"   , "NICKNAME" , "SHOWPESQ" }

//
// Tabela DH8
//
aAdd( aSIX, { ;
	'DH8'																	, ; //INDICE
	'5'																		, ; //ORDEM
	'DH8_FILIAL+DH8_BOMBA+DH8_NROLAC'										, ; //CHAVE
	'Bomba+Nro.Lacre'														, ; //DESCRICAO
	'Surtidor+Nº Lacre'														, ; //DESCSPA
	'Bomba+Nº Lacre'														, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Tabela LLC
//
aAdd( aSIX, { ;
	'LLC'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'LLC_FILIAL+LLC_UF+LLC_CLASPR+LLC_CLASCL'								, ; //CHAVE
	'LLC_FILIAL+LLC_UF+LLC_CLASPR+LLC_CLASCL'								, ; //DESCRICAO
	'LLC_FILIAL+LLC_UF+LLC_CLASPR+LLC_CLASCL'								, ; //DESCSPA
	'LLC_FILIAL+LLC_UF+LLC_CLASPR+LLC_CLASCL'								, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'LLC'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'LLC_FILIAL+LLC_UF+LLC_DATADE+LLC_DATAAT+LLC_CLASPR+LLC_CLASCL'			, ; //CHAVE
	'LLC_FILIAL+LLC_UF+LLC_DATADE+LLC_DATAAT+LLC_CLASPR+LLC_CLASCL'			, ; //DESCRICAO
	'LLC_FILIAL+LLC_UF+LLC_DATADE+LLC_DATAAT+LLC_CLASPR+LLC_CLASCL'			, ; //DESCSPA
	'LLC_FILIAL+LLC_UF+LLC_DATADE+LLC_DATAAT+LLC_CLASPR+LLC_CLASCL'			, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'LLC'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'LLC_FILIAL+LLC_CLASPR+LLC_CLASCL'										, ; //CHAVE
	'LLC_FILIAL+LLC_CLASPR+LLC_CLASCL'										, ; //DESCRICAO
	'LLC_FILIAL+LLC_CLASPR+LLC_CLASCL'										, ; //DESCSPA
	'LLC_FILIAL+LLC_CLASPR+LLC_CLASCL'										, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela LLG
//
aAdd( aSIX, { ;
	'LLG'																	, ; //INDICE
	'4'																		, ; //ORDEM
	'LLG_FILIAL+DTOS(LLG_DATACO)+LLG_HORACO'								, ; //CHAVE
	'Data Complet+Hora Complet'												, ; //DESCRICAO
	'Fecha Compl.+Hora Complet'												, ; //DESCSPA
	'Data Complet+Hora Complet'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'LLG'																	, ; //INDICE
	'6'																		, ; //ORDEM
	'LLG_FILIAL+DTOS(LLG_DATACO)+LLG_NUM+LLG_ID+LLG_PDV'					, ; //CHAVE
	'Data Complet+Orcamento+ID.+PDV'										, ; //DESCRICAO
	'Fecha Compl.+Orcamento+ID.'											, ; //DESCSPA
	'Data Complet+Orcamento+ID.'											, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'LLG'																	, ; //INDICE
	'7'																		, ; //ORDEM
	'LLG_FILIAL+DTOS(LLG_DATACO)+LLG_NUM+LLG_PDV'							, ; //CHAVE
	'Data Complet+Orcamento+PDV'											, ; //DESCRICAO
	'Fecha Compl.+Orcamento+PDV'											, ; //DESCSPA
	'Data Complet+Orcamento+PDV'											, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'LLG'																	, ; //INDICE
	'8'																		, ; //ORDEM
	'LLG_FILIAL+LLG_SITUA'													, ; //CHAVE
	'Situa'																	, ; //DESCRICAO
	'Situa'																	, ; //DESCSPA
	'Situa'																	, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'LLG'																	, ; //INDICE
	'9'																		, ; //ORDEM
	'LLG_FILIAL+LLG_CONCEN+LLG_LADO+LLG_NLOGIC+DTOS(LLG_DTORIG)+LLG_HORACO+STR(LLG_QTDLT)', ; //CHAVE
	'Concentrador+Lado Bomba+Num. Logico+Dt Original+Hora+Quantidade'		, ; //DESCRICAO
	'Concentrador+Lado Bomba+Num. Logico+Dt Original+Hora+Quantidade'		, ; //DESCSPA
	'Concentrador+Lado Bomba+Num. Logico+Dt Original+Hora+Quantidade'		, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'LEG_001'																, ; //NICKNAME
	''																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'LLG'																	, ; //INDICE
	'A'																		, ; //ORDEM
	'LLG_FILIAL+LLG_CODBIA+STR(LLG_NENCER)+LLG_CODIGO'						, ; //CHAVE
	'Cod. Bico+Encerrante+Sequencia'										, ; //DESCRICAO
	'Cod. Bico+Encerrante+Sequencia'										, ; //DESCSPA
	'Cod. Bico+Encerrante+Sequencia'										, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'LEG_002'																, ; //NICKNAME
	''																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'LLG'																	, ; //INDICE
	'B'																		, ; //ORDEM
	'LLG_FILIAL+LLG_CONCEN+LLG_LEITUR'										, ; //CHAVE
	'Concentrador+N. Leitura'												, ; //DESCRICAO
	'Concentrador+N. Leitura'												, ; //DESCSPA
	'Concentrador+N. Leitura'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'LEG_003'																, ; //NICKNAME
	''																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'LLG'																	, ; //INDICE
	'C'																		, ; //ORDEM
	'LLG_FILIAL+DTOS(LLG_DATACO)+LLG_PROD+LLG_CODBIA+LLG_TANQUE'			, ; //CHAVE
	'Dt. Abast.+Produto+Cod. Bico Ab+Tanque'								, ; //DESCRICAO
	'Fecha Compl.+Produto+Cod. Mang.Ap+Tanque'								, ; //DESCSPA
	'Data Complet+Produto+Cod. Mang.Ap+Tanque'								, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela LLI
//
aAdd( aSIX, { ;
	'LLI'																	, ; //INDICE
	'6'																		, ; //ORDEM
	'LLI_FILIAL+LLI_BOMBA+LLI_BICO'											, ; //CHAVE
	'Bomba+Bico'															, ; //DESCRICAO
	'Surtidor+Manguera'														, ; //DESCSPA
	'Bomba+Manguera'														, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Tabela SE5
//
aAdd( aSIX, { ;
	'SE5'																	, ; //INDICE
	'O'																		, ; //ORDEM
	'E5_FILIAL+DTOS(E5_DATA)+E5_BANCO+E5_NUMMOV+E5_XPDV+E5_XESTAC'			, ; //CHAVE
	'Data+Banco+NumMov+Pdv+Estacao'											, ; //DESCRICAO
	'Data+Banco+NumMov+Pdv+Estacao'											, ; //DESCSPA
	'Data+Banco+NumMov+Pdv+Estacao'											, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'PDV01'																	, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela SF2
//
aAdd( aSIX, { ;
	'SF2'																	, ; //INDICE
	'K'																		, ; //ORDEM
	'F2_FILIAL+F2_CHVNFE'													, ; //CHAVE
	'Chave NFe'																, ; //DESCRICAO
	'Clave eFact'															, ; //DESCSPA
	'NFe Key'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'F2CHVNFE'																, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Tabela SLI
//
aAdd( aSIX, { ;
	'SLI'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'LI_FILIAL+LI_ALIAS+LI_MSG'												, ; //CHAVE
	'Alias+Mensagem'														, ; //DESCRICAO
	'Alias+Mensaje'															, ; //DESCSPA
	'Alias+Mensaje'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'XREPLICA'																, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SLI'																	, ; //INDICE
	'4'																		, ; //ORDEM
	'LI_FILIAL+LI_TIPO+DTOS(LI_DATA)+LI_HORA'								, ; //CHAVE
	'Monitorament+Data+Hora'												, ; //DESCRICAO
	'Monitoreo+Fecha+Hora'													, ; //DESCSPA
	'Monitoring+Fecha+Hora'													, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'FIDELID'																, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela SY6
//
aAdd( aSIX, { ;
	'SY6'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'Y6_FILIAL + Y6_SIGSE4'													, ; //CHAVE
	'C.Pagto SIGA'															, ; //DESCRICAO
	'C.Pagto SIGA'															, ; //DESCSPA
	'C.Pagto SIGA'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'CONDPAGSE4'															, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Tabela SZO
//
aAdd( aSIX, { ;
	'SZO'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZO_FILIAL+ZO_CODCOMB'													, ; //CHAVE
	'Codigo'																, ; //DESCRICAO
	'Codigo'																, ; //DESCSPA
	'Codigo'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SZO'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'ZO_FILIAL+ZO_DESCRI+ZO_CODCOMB'										, ; //CHAVE
	'Desc. Comb.'															, ; //DESCRICAO
	'Desc. Comb.'															, ; //DESCSPA
	'Desc. Comb.'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela SZZ
//
aAdd( aSIX, { ;
	'SZZ'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZZ_FILIAL+ZZ_TIPODOC+ZZ_DOC+ZZ_SERIE+ZZ_CLIFOR+ZZ_LOJA+ZZ_CODMENS+ZZ_SEQMENS', ; //CHAVE
	'TIPODOC+COD NF+SERIE+CLIFOR+LOJA+CODMENS+SEQUENCIA'					, ; //DESCRICAO
	'TIPODOC+COD NF+SERIE+CLIFOR+LOJA+CODMENS+SEQUENCIA'					, ; //DESCSPA
	'TIPODOC+COD NF+SERIE+CLIFOR+LOJA+CODMENS+SEQUENCIA'					, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	''																		} ) //SHOWPESQ

//
// Tabela TQI
//
aAdd( aSIX, { ;
	'TQI'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'TQI_FILIAL+TQI_TANQUE+TQI_PRODUT'										, ; //CHAVE
	'Tanque+Produto'														, ; //DESCRICAO
	'Tanque+Producto'														, ; //DESCSPA
	'Tank+Producto'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'TQI'																	, ; //INDICE
	'4'																		, ; //ORDEM
	'TQI_FILIAL+TQI_PRODUT'													, ; //CHAVE
	'Produto'																, ; //DESCRICAO
	'Producto'																, ; //DESCSPA
	'Product'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela TQJ
//
aAdd( aSIX, { ;
	'TQJ'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'TQJ_FILIAL+TQJ_BOMBA'													, ; //CHAVE
	'Bomba'																	, ; //DESCRICAO
	'Bomba'																	, ; //DESCSPA
	'Pump'																	, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Tabela U00
//
aAdd( aSIX, { ;
	'U00'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'U00_FILIAL+U00_NUMSEQ'													, ; //CHAVE
	'Intervencao'															, ; //DESCRICAO
	'Intervencao'															, ; //DESCSPA
	'Intervencao'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'U00'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'U00_FILIAL+DTOS(U00_DTINT)'											, ; //CHAVE
	'Dt intervenc'															, ; //DESCRICAO
	'Dt intervenc'															, ; //DESCSPA
	'Dt intervenc'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'U00'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'U00_FILIAL+DTOS(U00_DTINT)+U00_BOMBA'									, ; //CHAVE
	'Dt intervenc+Bomba'													, ; //DESCRICAO
	'Dt intervenc+Bomba'													, ; //DESCSPA
	'Dt intervenc+Bomba'													, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela U01
//
aAdd( aSIX, { ;
	'U01'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'U01_FILIAL+U01_NUMSEQ+U01_LACRE'										, ; //CHAVE
	'Codigo+Lacre'															, ; //DESCRICAO
	'Codigo+Lacre'															, ; //DESCSPA
	'Codigo+Lacre'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela U02
//
aAdd( aSIX, { ;
	'U02'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'U02_FILIAL+U02_NUMSEQ+U02_SEQBIC'										, ; //CHAVE
	'Codigo+Sequencia'														, ; //DESCRICAO
	'Codigo+Sequencia'														, ; //DESCSPA
	'Codigo+Sequencia'														, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'U02'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'U02_FILIAL+U02_NUMSEQ+U02_BICO'										, ; //CHAVE
	'Codigo+Bico'															, ; //DESCRICAO
	'Codigo+Bico'															, ; //DESCSPA
	'Codigo+Bico'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela U03
//
aAdd( aSIX, { ;
	'U03'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'U03_FILIAL+U03_GRUPO+U03_USER'											, ; //CHAVE
	'Grp. Usuario+Usuario'													, ; //DESCRICAO
	'Grp. Usuario+Usuario'													, ; //DESCSPA
	'Grp. Usuario+Usuario'													, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela U04
//
aAdd( aSIX, { ;
	'U04'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'U04_FILIAL+U04_GRUPO+U04_USER+U04_ITEM'								, ; //CHAVE
	'Grp. Usuario+Usuario+Item'												, ; //DESCRICAO
	'Grp. Usuario+Usuario+Item'												, ; //DESCSPA
	'Grp. Usuario+Usuario+Item'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Tabela U0A
//
aAdd( aSIX, { ;
	'U0A'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'U0A_FILIAL+U0A_FORPAG+U0A_CONDPG+U0A_ADMFIN'							, ; //CHAVE
	'Form+Cond+Adm Fin'														, ; //DESCRICAO
	'Form+Cond+Adm Fin'														, ; //DESCSPA
	'Form+Cond+Adm Fin'														, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela U0B
//
aAdd( aSIX, { ;
	'U0B'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'U0B_FILIAL+U0B_PRODUT'													, ; //CHAVE
	'Prod'																	, ; //DESCRICAO
	'Prod'																	, ; //DESCSPA
	'Prod'																	, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela U0C
//
aAdd( aSIX, { ;
	'U0C'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'U0C_FILIAL+U0C_PRODUT+U0C_FORPAG+U0C_CONDPG+U0C_ADMFIN'				, ; //CHAVE
	'Prod+Form+Cond+Adm Fin'												, ; //DESCRICAO
	'Prod+Form+Cond+Adm Fin'												, ; //DESCSPA
	'Prod+Form+Cond+Adm Fin'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela U0D
//
aAdd( aSIX, { ;
	'U0D'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'U0D_FILIAL+U0D_GRUPO+U0D_USER'											, ; //CHAVE
	'Grp. Usuario+Usuario'													, ; //DESCRICAO
	'Grp. Usuario+Usuario'													, ; //DESCSPA
	'Grp. Usuario+Usuario'													, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'U0D'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'U0D_FILIAL+U0D_GRUPO'													, ; //CHAVE
	'Grp. Usuario'															, ; //DESCRICAO
	'Grp. Usuario'															, ; //DESCSPA
	'Grp. Usuario'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'U0D'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'U0D_FILIAL+U0D_USER'													, ; //CHAVE
	'Usuario'																, ; //DESCRICAO
	'Usuario'																, ; //DESCSPA
	'Usuario'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Tabela U0E
//
aAdd( aSIX, { ;
	'U0E'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'U0E_FILIAL+U0E_CHAVE+DTOS(U0E_DATA)+U0E_HORA'							, ; //CHAVE
	'Chave Rot.+Data+Hora'													, ; //DESCRICAO
	'Chave Rot.+Data+Hora'													, ; //DESCSPA
	'Chave Rot.+Data+Hora'													, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'U0E'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'U0E_FILIAL+U0E_CHAVE+U0E_DOC+DTOS(U0E_DATA)+U0E_HORA'					, ; //CHAVE
	'Chave Rot.+Documento+Data+Hora'										, ; //DESCRICAO
	'Chave Rot.+Documento+Data+Hora'										, ; //DESCSPA
	'Chave Rot.+Documento+Data+Hora'										, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela U0F
//
aAdd( aSIX, { ;
	'U0F'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'U0F_FILIAL+U0F_CODIGO'													, ; //CHAVE
	'Codigo'																, ; //DESCRICAO
	'Codigo'																, ; //DESCSPA
	'Codigo'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela U0G
//
aAdd( aSIX, { ;
	'U0G'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'U0G_FILIAL+U0G_PRODUT+U0G_FORPAG+U0G_CONDPG+U0G_ADMFIN+DTOS(U0G_DTINIC)+U0G_HRINIC', ; //CHAVE
	'Prod+Form+Cond+Adm Fin+Data Inicio+Hora Inicio'						, ; //DESCRICAO
	'Prod+Form+Cond+Adm Fin+Data Inicio+Hora Inicio'						, ; //DESCSPA
	'Prod+Form+Cond+Adm Fin+Data Inicio+Hora Inicio'						, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela U0H
//
aAdd( aSIX, { ;
	'U0H'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'U0H_FILIAL+U0H_OPERAD+U0H_NUMMOV+U0H_ESTACA+U0H_SERIE+U0H_PDV+DTOS(U0H_DTABER)+U0H_HRABER', ; //CHAVE
	'Operador+Movimento+Codigo Est.+Serie+PDV+Abertura+Hora abertur'		, ; //DESCRICAO
	'Operador+Movimento+Codigo Est.+Serie+PDV+Abertura+Hora abertur'		, ; //DESCSPA
	'Operador+Movimento+Codigo Est.+Serie+PDV+Abertura+Hora abertur'		, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela U0I
//
aAdd( aSIX, { ;
	'U0I'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'U0I_FILIAL+DTOS(U0I_DATA)+U0I_PROD+U0I_TANQUE+U0I_BICO'				, ; //CHAVE
	'Data LMC+Produto+Tanque+Bico'											, ; //DESCRICAO
	'Data LMC+Produto+Tanque+Bico'											, ; //DESCSPA
	'Data LMC+Produto+Tanque+Bico'											, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela U0J
//
aAdd( aSIX, { ;
	'U0J'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'U0J_FILIAL+U0J_PREFIX+U0J_NUM+U0J_PARCEL+U0J_TIPO'						, ; //CHAVE
	'Prefixo+Numero+Parcela+Tipo'											, ; //DESCRICAO
	'Prefixo+Numero+Parcela+Tipo'											, ; //DESCSPA
	'Prefixo+Numero+Parcela+Tipo'											, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela U25
//
aAdd( aSIX, { ;
	'U25'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'U25_FILIAL+U25_REPLIC'													, ; //CHAVE
	'ID REPLICA'															, ; //DESCRICAO
	'ID REPLICA'															, ; //DESCSPA
	'ID REPLICA'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'U25'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'U25_FILIAL+U25_PRODUT+U25_CLIENT+U25_LOJA+U25_GRPCLI+U25_FORPAG+U25_CONDPG+U25_ADMFIN+U25_EMITEN+U25_LOJEMI+U25_PLACA+DTOS(U25_DTINIC)+U25_HRINIC', ; //CHAVE
	'Prod+Cli+Loja+GrpCli+Form+Cond+Adm Fin+Emit+Loja E+Placa+Dt Ini+Hr Ini'	, ; //DESCRICAO
	'Prod+Cli+Loja+GrpCli+Form+Cond+Adm Fin+Emit+Loja E+Placa+Dt Ini+Hr Ini'	, ; //DESCSPA
	'Prod+Cli+Loja+GrpCli+Form+Cond+Adm Fin+Emit+Loja E+Placa+Dt Ini+Hr Ini'	, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'U25'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'U25_FILIAL+U25_CLIENT+U25_LOJA+U25_GRPCLI+U25_PRODUT+U25_FORPAG+U25_CONDPG+U25_ADMFIN+U25_EMITEN+U25_LOJEMI+U25_PLACA+DTOS(U25_DTINIC)+U25_HRINIC', ; //CHAVE
	'Cli+Loja+GrpCli+Prod+Form+Cond+Adm Fin+Emit+Loja E+Placa+Dt Ini+Hr Ini'	, ; //DESCRICAO
	'Cli+Loja+GrpCli+Prod+Form+Cond+Adm Fin+Emit+Loja E+Placa+Dt Ini+Hr Ini'	, ; //DESCSPA
	'Cli+Loja+GrpCli+Prod+Form+Cond+Adm Fin+Emit+Loja E+Placa+Dt Ini+Hr Ini'	, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela U44
//
aAdd( aSIX, { ;
	'U44'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'U44_FILIAL+U44_FORMPG+U44_CONDPG'										, ; //CHAVE
	'Forma Pgto+Cond Pgto'													, ; //DESCRICAO
	'Forma Pgto+Cond Pgto'													, ; //DESCSPA
	'Forma Pgto+Cond Pgto'													, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela U52
//
aAdd( aSIX, { ;
	'U52'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'U52_FILIAL+U52_CODCLI+U52_LOJA+U52_GRPVEN+U52_CLASSE+U52_SATIV1'		, ; //CHAVE
	'Cliente+Loja+Grp.Clientes+Classe+Segmento'								, ; //DESCRICAO
	'Cliente+Loja+Grp.Clientes+Classe+Segmento'								, ; //DESCSPA
	'Cliente+Loja+Grp.Clientes+Classe+Segmento'								, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'U52'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'U52_FILIAL+U52_CODCLI+U52_LOJA'										, ; //CHAVE
	'Cliente+Loja'															, ; //DESCRICAO
	'Cliente+Loja'															, ; //DESCSPA
	'Cliente+Loja'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'U52'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'U52_FILIAL+U52_GRPVEN'													, ; //CHAVE
	'Grp.Clientes'															, ; //DESCRICAO
	'Grp.Clientes'															, ; //DESCSPA
	'Grp.Clientes'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'U52'																	, ; //INDICE
	'4'																		, ; //ORDEM
	'U52_FILIAL+U52_CLASSE'													, ; //CHAVE
	'Classe'																, ; //DESCRICAO
	'Classe'																, ; //DESCSPA
	'Classe'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'U52'																	, ; //INDICE
	'5'																		, ; //ORDEM
	'U52_FILIAL+U52_SATIV1'													, ; //CHAVE
	'Segmento'																, ; //DESCRICAO
	'Segmento'																, ; //DESCSPA
	'Segmento'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela U53
//
aAdd( aSIX, { ;
	'U53'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'U53_FILIAL+U53_CODCLI+U53_LOJA+U53_GRPVEN+U53_CLASSE+U53_SATIV1+U53_ITEM'	, ; //CHAVE
	'Cliente+Loja+Grp.Clientes+Classe+Segmento+Item'						, ; //DESCRICAO
	'Cliente+Loja+Grp.Clientes+Classe+Segmento+Item'						, ; //DESCSPA
	'Cliente+Loja+Grp.Clientes+Classe+Segmento+Item'						, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'U53'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'U53_FILIAL+U53_FORMPG+U53_CONDPG'										, ; //CHAVE
	'Form Pagto+Cond Pagto'													, ; //DESCRICAO
	'Form Pagto+Cond Pagto'													, ; //DESCSPA
	'Form Pagto+Cond Pagto'													, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'U53'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'U53_FILIAL+U53_FORMPG+U53_CONDPG+U53_CODCLI+U53_LOJA'					, ; //CHAVE
	'Form Pagto+Cond Pagto+Cod Cli+Loja Cli'								, ; //DESCRICAO
	'Form Pagto+Cond Pagto+Cod Cli+Loja Cli'								, ; //DESCSPA
	'Form Pagto+Cond Pagto+Cod Cli+Loja Cli'								, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela U56
//
aAdd( aSIX, { ;
	'U56'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'U56_FILIAL+U56_PREFIX+U56_CODIGO'										, ; //CHAVE
	'Prefixo Req.+Codigo'													, ; //DESCRICAO
	'Prefixo Req.+Codigo'													, ; //DESCSPA
	'Prefixo Req.+Codigo'													, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'U56'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'U56_FILIAL+U56_CODCLI+U56_LOJA'										, ; //CHAVE
	'Cliente+Loja'															, ; //DESCRICAO
	'Cliente+Loja'															, ; //DESCSPA
	'Cliente+Loja'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'U56'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'U56_FILIAL+U56_BANCO+U56_AGENCI+U56_NUMCON'							, ; //CHAVE
	'Banco+Agencia+Nro Conta'												, ; //DESCRICAO
	'Banco+Agencia+Nro Conta'												, ; //DESCSPA
	'Banco+Agencia+Nro Conta'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela U57
//
aAdd( aSIX, { ;
	'U57'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'U57_FILIAL+U57_PREFIX+U57_CODIGO+U57_PARCEL'							, ; //CHAVE
	'Prefixo Req.+Codigo+Parcela'											, ; //DESCRICAO
	'Prefixo Req.+Codigo+Parcela'											, ; //DESCSPA
	'Prefixo Req.+Codigo+Parcela'											, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'U57'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'U57_FILIAL+DTOS(U57_DATAMO)+U57_XOPERA+U57_XNUMMO+U57_XPDV+U57_XESTAC'		, ; //CHAVE
	'Dt Movimento+Operador+Num. Movimen+PDV+Estacao'						, ; //DESCRICAO
	'Dt Movimento+Operador+Num. Movimen+PDV+Estacao'						, ; //DESCSPA
	'Dt Movimento+Operador+Num. Movimen+PDV+Estacao'						, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Tabela U59
//
aAdd( aSIX, { ;
	'U59'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'U59_FILIAL+U59_LOCAL+U59_PRODUT'										, ; //CHAVE
	'Local+Produto'															, ; //DESCRICAO
	'Local+Produto'															, ; //DESCSPA
	'Local+Produto'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'U59'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'U59_FILIAL+U59_PRODUT'													, ; //CHAVE
	'Produto'																, ; //DESCRICAO
	'Produto'																, ; //DESCSPA
	'Produto'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela U65
//
aAdd( aSIX, { ;
	'U65'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'U65_FILIAL+U65_CODIGO'													, ; //CHAVE
	'Codigo'																, ; //DESCRICAO
	'Codigo'																, ; //DESCSPA
	'Codigo'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela U68
//
aAdd( aSIX, { ;
	'U68'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'U68_FILIAL+U68_CODIGO'													, ; //CHAVE
	'Codigo'																, ; //DESCRICAO
	'Codigo'																, ; //DESCSPA
	'Codigo'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'U68'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'U68_FILIAL+U68_VEND'													, ; //CHAVE
	'Vendedor'																, ; //DESCRICAO
	'Vendedor'																, ; //DESCSPA
	'Vendedor'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'U68'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'U68_FILIAL+U68_NUM'													, ; //CHAVE
	'Num. Cartao'															, ; //DESCRICAO
	'Num. Cartao'															, ; //DESCSPA
	'Num. Cartao'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'U68'																	, ; //INDICE
	'4'																		, ; //ORDEM
	'U68_FILIAL+U68_CONCEN+U68_NUM'											, ; //CHAVE
	'Concentrador + Num. Cartao'											, ; //DESCRICAO
	'Concentrador + Num. Cartao'											, ; //DESCSPA
	'Concentrador + Num. Cartao'											, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Tabela U69
//
aAdd( aSIX, { ;
	'U69'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'U69_FILIAL+U69_DATA+U69_HORA+U69_DOC+U69_SERIE'						, ; //CHAVE
	'Data+Hora+Cupom fical+Serie'											, ; //DESCRICAO
	'Data+Hora+Cupom fical+Serie'											, ; //DESCSPA
	'Data+Hora+Cupom fical+Serie'											, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Tabela U72
//
aAdd( aSIX, { ;
	'U72'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'U72_FILIAL+U72_CODIGO'													, ; //CHAVE
	'Codigo'																, ; //DESCRICAO
	'Codigo'																, ; //DESCSPA
	'Codigo'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Tabela U88
//
aAdd( aSIX, { ;
	'U88'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'U88_FILIAL+U88_FORMAP+U88_CLIENT+U88_LOJA'								, ; //CHAVE
	'Forma pgto.+Cliente+Loja'												, ; //DESCRICAO
	'Forma pgto.+Cliente+Loja'												, ; //DESCSPA
	'Forma pgto.+Cliente+Loja'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'U88'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'U88_FILIAL+U88_CLIENT+U88_LOJA'										, ; //CHAVE
	'Cliente+Loja'															, ; //DESCRICAO
	'Cliente+Loja'															, ; //DESCSPA
	'Cliente+Loja'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'U88'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'U88_FILIAL+U88_NOME'													, ; //CHAVE
	'Nome'																	, ; //DESCRICAO
	'Nome'																	, ; //DESCSPA
	'Nome'																	, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela U92
//
aAdd( aSIX, { ;
	'U92'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'U92_FILIAL+U92_CODIGO'													, ; //CHAVE
	'Codigo'																, ; //DESCRICAO
	'Codigo'																, ; //DESCSPA
	'Codigo'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela U98
//
aAdd( aSIX, { ;
	'U98'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'U98_FILIAL+U98_OPERAD+U98_CODIGO'										, ; //CHAVE
	'Operadora+Cod.Layout'													, ; //DESCRICAO
	'Operadora+Cod.Layout'													, ; //DESCSPA
	'Operadora+Cod.Layout'													, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'U98'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'U98_FILIAL+U98_CODIGO+U98_OPERAD'										, ; //CHAVE
	'Cod.Layout+Operadora'													, ; //DESCRICAO
	'Cod.Layout+Operadora'													, ; //DESCSPA
	'Cod.Layout+Operadora'													, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela U99
//
aAdd( aSIX, { ;
	'U99'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'U99_FILIAL+U99_OPERAD+U99_CODIGO+U99_ITEM'								, ; //CHAVE
	'Operadora+Item+Cod.Layout'												, ; //DESCRICAO
	'Operadora+Item+Cod.Layout'												, ; //DESCSPA
	'Operadora+Item+Cod.Layout'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'U99'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'U99_FILIAL+U99_OPERAD+U99_CAMPO+U99_CODIGO'							, ; //CHAVE
	'Operadora+Campo+Cod.Layout'											, ; //DESCRICAO
	'Operadora+Campo+Cod.Layout'											, ; //DESCSPA
	'Operadora+Campo+Cod.Layout'											, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela UB1
//
aAdd( aSIX, { ;
	'UB1'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'UB1_FILIAL+UB1_PRODUT+UB1_GRPPRO+UB1_CLIENT+UB1_LOJA+UB1_GRPCLI+UB1_FORPAG+UB1_CONDPG+UB1_ADMFIN+UB1_EMITEN+UB1_LOJEMI+DTOS(UB1_DTINIC)+UB1_HRINIC', ; //CHAVE
	'Prod+GrpPro+Cli+Loja+GrpCli+Forma+Cond+Adm Fin+Emit+Loja Em+Data+Hora'		, ; //DESCRICAO
	'Prod+GrpPro+Cli+Loja+GrpCli+Forma+Cond+Adm Fin+Emit+Loja Em+Data+Hora'		, ; //DESCSPA
	'Prod+GrpPro+Cli+Loja+GrpCli+Forma+Cond+Adm Fin+Emit+Loja Em+Data+Hora'		, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'UB1'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'UB1_FILIAL+UB1_CLIENT+UB1_LOJA+UB1_GRPCLI+UB1_PRODUT+UB1_GRPPRO+UB1_FORPAG+UB1_CONDPG+UB1_ADMFIN+UB1_EMITEN+UB1_LOJEMI+DTOS(UB1_DTINIC)+UB1_HRINIC', ; //CHAVE
	'Cli+Loja+GrpCli+Prod+GrpPro+Forma+Cond+Adm Fin+Emit+Loja Em+Data+Hora'		, ; //DESCRICAO
	'Cli+Loja+GrpCli+Prod+GrpPro+Forma+Cond+Adm Fin+Emit+Loja Em+Data+Hora'		, ; //DESCSPA
	'Cli+Loja+GrpCli+Prod+GrpPro+Forma+Cond+Adm Fin+Emit+Loja Em+Data+Hora'		, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'UB1'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'UB1_FILIAL+UB1_REPLIC'													, ; //CHAVE
	'ID REPLICA'															, ; //DESCRICAO
	'ID REPLICA'															, ; //DESCSPA
	'ID REPLICA'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Tabela UB4
//
aAdd( aSIX, { ;
	'UB4'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'UB4_FILIAL+UB4_CODIGO'													, ; //CHAVE
	'Codigo'																, ; //DESCRICAO
	'Codigo'																, ; //DESCSPA
	'Codigo'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'UB4'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'UB4_FILIAL+UB4_DESCRI+UB4_COMPET'										, ; //CHAVE
	'Descricao+Competencia'													, ; //DESCRICAO
	'Descricao+Competencia'													, ; //DESCSPA
	'Descricao+Competencia'													, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'UB4'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'UB4_FILIAL+UB4_PROD+UB4_NUMERO'										, ; //CHAVE
	'Produto+Numero'														, ; //DESCRICAO
	'Produto+Numero'														, ; //DESCSPA
	'Produto+Numero'														, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela UC0
//
aAdd( aSIX, { ;
	'UC0'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'UC0_FILIAL+UC0_NUM'													, ; //CHAVE
	'Num Comp.'																, ; //DESCRICAO
	'Num Comp.'																, ; //DESCSPA
	'Num Comp.'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'UC0'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'UC0_FILIAL+DTOS(UC0_DATA)+UC0_NUM'										, ; //CHAVE
	'Data Comp.+Num Comp.'													, ; //DESCRICAO
	'Data Comp.+Num Comp.'													, ; //DESCSPA
	'Data Comp.+Num Comp.'													, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'UC0'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'UC0_FILIAL+DTOS(UC0_DATA)+UC0_OPERAD+UC0_NUMMOV+UC0_PDV+UC0_ESTACA'	, ; //CHAVE
	'Data Comp.+Operador+Num. Movimen+PDV+Estacao'							, ; //DESCRICAO
	'Data Comp.+Operador+Num. Movimen+PDV+Estacao'							, ; //DESCSPA
	'Data Comp.+Operador+Num. Movimen+PDV+Estacao'							, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Tabela UC1
//
aAdd( aSIX, { ;
	'UC1'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'UC1_FILIAL+UC1_NUM+UC1_FORMA+UC1_SEQ'									, ; //CHAVE
	'Num Comp.+Forma Pgto+Seq. Parcela'										, ; //DESCRICAO
	'Num Comp.+Forma Pgto+Seq. Parcela'										, ; //DESCSPA
	'Num Comp.+Forma Pgto+Seq. Parcela'										, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela UC2
//
aAdd( aSIX, { ;
	'UC2'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'UC2_FILIAL+UC2_GRUPO+UC2_USER+UC2_ROTINA'								, ; //CHAVE
	'Grupo User+Usuario+Rotina'												, ; //DESCRICAO
	'Grupo User+Usuario+Rotina'												, ; //DESCSPA
	'Grupo User+Usuario+Rotina'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'UC2'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'UC2_FILIAL+UC2_ROTINA+UC2_USER+UC2_GRUPO'								, ; //CHAVE
	'Rotina+Usuario+Grupo User'												, ; //DESCRICAO
	'Rotina+Usuario+Grupo User'												, ; //DESCSPA
	'Rotina+Usuario+Grupo User'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela UC3
//
aAdd( aSIX, { ;
	'UC3'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'UC3_FILIAL+UC3_COD'													, ; //CHAVE
	'Cod.Segmento'															, ; //DESCRICAO
	'Cod.Segmento'															, ; //DESCSPA
	'Cod.Segmento'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'UC3'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'UC3_FILIAL+UC3_DESC'													, ; //CHAVE
	'Descrição'																, ; //DESCRICAO
	'Descrição'																, ; //DESCSPA
	'Descrição'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela UC4
//
aAdd( aSIX, { ;
	'UC4'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'UC4_FILIAL+UC4_CLIENT+UC4_LOJA+UC4_SEG'								, ; //CHAVE
	'Cod.Cliente+Loja Cliente+Segmento'										, ; //DESCRICAO
	'Cod.Cliente+Loja Cliente+Segmento'										, ; //DESCSPA
	'Cod.Cliente+Loja Cliente+Segmento'										, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'UC4'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'UC4_FILIAL+UC4_GRUPO+UC4_SEG'											, ; //CHAVE
	'Grupo Cli.+Segmento'													, ; //DESCRICAO
	'Grupo Cli.+Segmento'													, ; //DESCSPA
	'Grupo Cli.+Segmento'													, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'UC4'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'UC4_FILIAL+UC4_CLIENT+UC4_LOJA+UC4_GRUPO+UC4_SEG'						, ; //CHAVE
	'Cod.Cliente+Loja Cliente+Grupo Cli.+Segmento'							, ; //DESCRICAO
	'Cod.Cliente+Loja Cliente+Grupo Cli.+Segmento'							, ; //DESCSPA
	'Cod.Cliente+Loja Cliente+Grupo Cli.+Segmento'							, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela UC5
//
aAdd( aSIX, { ;
	'UC5'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'UC5_FILIAL+UC5_COD+UC5_FILERP'											, ; //CHAVE
	'Cod.Segmento+Filial'													, ; //DESCRICAO
	'Cod.Segmento+Filial'													, ; //DESCSPA
	'Cod.Segmento+Filial'													, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'UC5'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'UC5_FILIAL+UC5_FILERP'													, ; //CHAVE
	'Filial'																, ; //DESCRICAO
	'Filial'																, ; //DESCSPA
	'Filial'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'UC5'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'UC5_FILIAL+UC5_CNPJ'													, ; //CHAVE
	'CNPJ'																	, ; //DESCRICAO
	'CNPJ'																	, ; //DESCSPA
	'CNPJ'																	, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela UCA
//
aAdd( aSIX, { ;
	'UCA'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'UCA_FILIAL+UCA_ALIORI+UCA_ALIRET'										, ; //CHAVE
	'Alias Origem+Alias Retorn'												, ; //DESCRICAO
	'Alias Origem+Alias Retorn'												, ; //DESCSPA
	'Alias Origem+Alias Retorn'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela UF1
//
aAdd( aSIX, { ;
	'UF1'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'UF1_FILIAL+UF1_COD+UF1_AGENCI+UF1_NUMCON+UF1_SEQUEN'					, ; //CHAVE
	'Banco+Nro Agencia+Nro Conta+Sequencia'									, ; //DESCRICAO
	'Banco+Nro Agencia+Nro Conta+Sequencia'									, ; //DESCSPA
	'Banco+Nro Agencia+Nro Conta+Sequencia'									, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela UF2
//
aAdd( aSIX, { ;
	'UF2'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'UF2_FILIAL+UF2_BANCO+UF2_AGENCI+UF2_CONTA+UF2_SEQUEN+UF2_NUM'			, ; //CHAVE
	'Banco+Agencia+Conta+Sequencia+Nro Cheque'								, ; //DESCRICAO
	'Banco+Agencia+Conta+Sequencia+Nro Cheque'								, ; //DESCSPA
	'Banco+Agencia+Conta+Sequencia+Nro Cheque'								, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'UF2'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'UF2_FILIAL+UF2_BANCO+UF2_AGENCI+UF2_CONTA+UF2_NUM'						, ; //CHAVE
	'Banco+Agencia+Conta+Nro Cheque'										, ; //DESCRICAO
	'Banco+Agencia+Conta+Nro Cheque'										, ; //DESCSPA
	'Banco+Agencia+Conta+Nro Cheque'										, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'UF2'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'UF2_FILIAL+UF2_DOC+UF2_SERIE+UF2_PDV'									, ; //CHAVE
	'Num. Cupom+Serie+Pdv'													, ; //DESCRICAO
	'Num. Cupom+Serie+Pdv'													, ; //DESCSPA
	'Num. Cupom+Serie+Pdv'													, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'UF2'																	, ; //INDICE
	'4'																		, ; //ORDEM
	'UF2_FILIAL+UF2_CODBAR'													, ; //CHAVE
	'Cod Barras'															, ; //DESCRICAO
	'Cod Barras'															, ; //DESCSPA
	'Cod Barras'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'UF2'																	, ; //INDICE
	'5'																		, ; //ORDEM
	'UF2_FILIAL+UF2_NUM+UF2_BANCO+UF2_AGENCI+UF2_CONTA'						, ; //CHAVE
	'Nro Cheque+Banco+Agencia+Conta'										, ; //DESCRICAO
	'Nro Cheque+Banco+Agencia+Conta'										, ; //DESCSPA
	'Nro Cheque+Banco+Agencia+Conta'										, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Tabela UF6
//
aAdd( aSIX, { ;
	'UF6'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'UF6_FILIAL+UF6_CODIGO'													, ; //CHAVE
	'Codigo'																, ; //DESCRICAO
	'Codigo'																, ; //DESCSPA
	'Codigo'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'UF6'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'UF6_FILIAL+UF6_DESC'													, ; //CHAVE
	'Descricao'																, ; //DESCRICAO
	'Descricao'																, ; //DESCSPA
	'Descricao'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela UH6
//
aAdd( aSIX, { ;
	'UH6'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'UH6_FILIAL+UH6_CODIGO'													, ; //CHAVE
	'Codigo'																, ; //DESCRICAO
	'Codigo'																, ; //DESCSPA
	'Codigo'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'UH6'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'UH6_FILIAL+UH6_PROD'													, ; //CHAVE
	'Produto'																, ; //DESCRICAO
	'Produto'																, ; //DESCSPA
	'Produto'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'UH6'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'UH6_FILIAL+UH6_DESC'													, ; //CHAVE
	'Descricao'																, ; //DESCRICAO
	'Descricao'																, ; //DESCSPA
	'Descricao'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela UH7
//
aAdd( aSIX, { ;
	'UH7'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'UH7_FILIAL+UH7_CODIGO+UH7_ITEM+UH7_EST'								, ; //CHAVE
	'Codigo+Item+Estado'													, ; //DESCRICAO
	'Codigo+Item+Estado'													, ; //DESCSPA
	'Codigo+Item+Estado'													, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'UH7'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'UH7_FILIAL+UH7_CODIGO+UH7_EST'											, ; //CHAVE
	'Codigo+Estado'															, ; //DESCRICAO
	'Codigo+Estado'															, ; //DESCSPA
	'Codigo+Estado'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela UH8
//
aAdd( aSIX, { ;
	'UH8'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'UH8_FILIAL+UH8_FORNEC+UH8_LOJA'										, ; //CHAVE
	'Fornecedor+Loja'														, ; //DESCRICAO
	'Fornecedor+Loja'														, ; //DESCSPA
	'Fornecedor+Loja'														, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela UH9
//
aAdd( aSIX, { ;
	'UH9'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'UH9_FILIAL+UH9_FORNEC+UH9_LOJA+UH9_PRODUT'								, ; //CHAVE
	'Fornecedor+Loja+Produto'												, ; //DESCRICAO
	'Fornecedor+Loja+Produto'												, ; //DESCSPA
	'Fornecedor+Loja+Produto'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Tabela UI0
//
aAdd( aSIX, { ;
	'UI0'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'UI0_FILIAL+UI0_GRPCLI+UI0_CLIENT+UI0_LOJA'								, ; //CHAVE
	'Grupo cli+Cliente+Loja'												, ; //DESCRICAO
	'Grupo cli+Cliente+Loja'												, ; //DESCSPA
	'Grupo cli+Cliente+Loja'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela UI1
//
aAdd( aSIX, { ;
	'UI1'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'UI1_FILIAL+UI1_GRPCLI+UI1_CLIENT+UI1_LOJA+UI1_FORNEC+UI1_LOJAFO'		, ; //CHAVE
	'Grupo cli+Cliente+Loja+Fornecedor+Loja'								, ; //DESCRICAO
	'Grupo cli+Cliente+Loja+Fornecedor+Loja'								, ; //DESCSPA
	'Grupo cli+Cliente+Loja+Fornecedor+Loja'								, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Tabela UIB
//
aAdd( aSIX, { ;
	'UIB'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'UIB_FILIAL+UIB_GRPCLI+UIB_CLIENT+UIB_LOJA+UIB_FORNEC+UIB_LOJAFO+UIB_PRODUT', ; //CHAVE
	'Grp Cliente+Cliente+Loja Cliente+Fornecedor+Loja Fornece+Produto'		, ; //DESCRICAO
	'Grp Cliente+Cliente+Loja Cliente+Fornecedor+Loja Fornece+Produto'		, ; //DESCSPA
	'Grp Cliente+Cliente+Loja Cliente+Fornecedor+Loja Fornece+Produto'		, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'UIB'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'UIB_FILIAL+UIB_GRPCLI+UIB_CLIENT+UIB_LOJA+UIB_PRODUT'					, ; //CHAVE
	'Grp Cliente+Cliente+Loja Cliente+Produto'								, ; //DESCRICAO
	'Grp Cliente+Cliente+Loja Cliente+Produto'								, ; //DESCSPA
	'Grp Cliente+Cliente+Loja Cliente+Produto'								, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Tabela UIC
//
aAdd( aSIX, { ;
	'UIC'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'UIC_FILIAL+UIC_AMB+UIC_CODIGO'											, ; //CHAVE
	'Filial+Ambiente+Codigo'												, ; //DESCRICAO
	'Filial+Ambiente+Codigo'												, ; //DESCSPA
	'Filial+Ambiente+Codigo'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'UIC'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'UIC_FILIAL+UIC_FORNEC+UIC_LOJAF'										, ; //CHAVE
	'Fornecedor+Loja'														, ; //DESCRICAO
	'Fornecedor+Loja'														, ; //DESCSPA
	'Fornecedor+Loja'														, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'UIC'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'UIC_FILIAL+UIC_NOMEF'													, ; //CHAVE
	'Nome'																	, ; //DESCRICAO
	'Nome'																	, ; //DESCSPA
	'Nome'																	, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela Z01
//
aAdd( aSIX, { ;
	'Z01'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'Z01_FILIAL+Z01_CODIGO+Z01_SEQ'											, ; //CHAVE
	'Código+Sequência'														, ; //DESCRICAO
	'Código+Sequência'														, ; //DESCSPA
	'Código+Sequência'														, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'Z01'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'Z01_FILIAL+Z01_ALIAS+Z01_CHAVE'										, ; //CHAVE
	'Alias+Chave Alias'														, ; //DESCRICAO
	'Alias+Chave Alias'														, ; //DESCSPA
	'Alias+Chave Alias'														, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Tabela Z02
//
aAdd( aSIX, { ;
	'Z02'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'Z02_FILIAL+Z02_CODSBM'													, ; //CHAVE
	'Filial+Grupo Prod.'													, ; //DESCRICAO
	'Filial+Grupo Prod.'													, ; //DESCSPA
	'Filial+Grupo Prod.'													, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'Z02'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'Z02_FILIAL+Z02_CODIGO'													, ; //CHAVE
	'Cod.SubGrp'															, ; //DESCRICAO
	'Cod.SubGrp'															, ; //DESCSPA
	'Cod.SubGrp'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Tabela Z03
//
aAdd( aSIX, { ;
	'Z03'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'Z03_FILIAL+Z03_COD'													, ; //CHAVE
	'Codigo'																, ; //DESCRICAO
	'Codigo'																, ; //DESCSPA
	'Codigo'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'Z03'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'Z03_FILIAL+Z03_ID'														, ; //CHAVE
	'ID do Fecham'															, ; //DESCRICAO
	'ID do Fecham'															, ; //DESCSPA
	'ID do Fecham'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'Z03'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'Z03_FILIAL+Z03_DTAB'													, ; //CHAVE
	'Dt Abertura'															, ; //DESCRICAO
	'Dt Abertura'															, ; //DESCSPA
	'Dt Abertura'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'Z03'																	, ; //INDICE
	'4'																		, ; //ORDEM
	'Z03_FILIAL+Z03_DTFECH'													, ; //CHAVE
	'Dt Fechament'															, ; //DESCRICAO
	'Dt Fechament'															, ; //DESCSPA
	'Dt Fechament'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'Z03'																	, ; //INDICE
	'5'																		, ; //ORDEM
	'Z03_FILIAL+Z03_DTPROC'													, ; //CHAVE
	'Dt Processam'															, ; //DESCRICAO
	'Dt Processam'															, ; //DESCSPA
	'Dt Processam'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela Z04
//
aAdd( aSIX, { ;
	'Z04'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'Z04_FILIAL+Z04_CODDOC'													, ; //CHAVE
	'Codigo Doc.'															, ; //DESCRICAO
	'Codigo Doc.'															, ; //DESCSPA
	'Codigo Doc.'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Tabela ZC0
//
aAdd( aSIX, { ;
	'ZC0'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZC0_FILIAL+ZC0_CODNEG'													, ; //CHAVE
	'Codigo'																, ; //DESCRICAO
	'Codigo'																, ; //DESCSPA
	'Codigo'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'ZC0'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'ZC0_FILIAL+ZC0_DATNEG+ZC0_DOCCLI'										, ; //CHAVE
	'Data+CGC/CPF'															, ; //DESCRICAO
	'Data+CGC/CPF'															, ; //DESCSPA
	'Data+CGC/CPF'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'ZC0'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'ZC0_FILIAL+ZC0_USRNEG+ZC0_DOCCLI'										, ; //CHAVE
	'Usuário+CGC/CPF'														, ; //DESCRICAO
	'Usuário+CGC/CPF'														, ; //DESCSPA
	'Usuário+CGC/CPF'														, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'ZC0'																	, ; //INDICE
	'4'																		, ; //ORDEM
	'ZC0_FILIAL+ZC0_DOCCLI+ZC0_DATNEG'										, ; //CHAVE
	'CGC/CPF+Data'															, ; //DESCRICAO
	'CGC/CPF+Data'															, ; //DESCSPA
	'CGC/CPF+Data'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela ZC1
//
aAdd( aSIX, { ;
	'ZC1'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZC1_FILIAL+ZC1_CODNEG+ZC1_ITENEG'										, ; //CHAVE
	'Codigo+Item'															, ; //DESCRICAO
	'Codigo+Item'															, ; //DESCSPA
	'Codigo+Item'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'ZC1'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'ZC1_FILIAL+ZC1_GRPORI+ZC1_FILORI+ZC1_CODCLI+ZC1_LOJCLI'				, ; //CHAVE
	'Grupo Origem+Filial Orig+Cod.Cliente+Loja Cliente'						, ; //DESCRICAO
	'Grupo Origem+Filial Orig+Cod.Cliente+Loja Clinete'						, ; //DESCSPA
	'Grupo Origem+Filial Orig+Cod.Cliente+Loja Clinete'						, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'ZC1'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'ZC1_FILIAL+ZC1_GRPORI+ZC1_FILORI+ZC1_PREFIX+ZC1_TITULO+ZC1_PARCEL+ZC1_TIPO', ; //CHAVE
	'Grupo Origem+Filial Orig+Prefixo+Titulo+Percela+Tipo'					, ; //DESCRICAO
	'Grupo Origem+Filial Orig+Prefixo+Titulo+Percela+Tipo'					, ; //DESCSPA
	'Grupo Origem+Filial Orig+Prefixo+Titulo+Percela+Tipo'					, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'ZC1'																	, ; //INDICE
	'4'																		, ; //ORDEM
	'ZC1_FILIAL+ZC1_CODCLI+ZC1_FILORI+ZC1_PREFIX+ZC1_TITULO+ZC1_PARCEL+ZC1_TIPO', ; //CHAVE
	'Cod.Cliente+Filial Orig+Prefixo+Titulo+Percela+Tipo'					, ; //DESCRICAO
	'Cod.Cliente+Filial Orig+Prefixo+Titulo+Percela+Tipo'					, ; //DESCSPA
	'Cod.Cliente+Filial Orig+Prefixo+Titulo+Percela+Tipo'					, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela ZE0
//
aAdd( aSIX, { ;
	'ZE0'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZE0_FILIAL+ZE0_TANQUE'													, ; //CHAVE
	'Nr Tanque'																, ; //DESCRICAO
	'Nr Tanque'																, ; //DESCSPA
	'Nr Tanque'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela ZE3
//
aAdd( aSIX, { ;
	'ZE3'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZE3_FILIAL+ZE3_NUMERO'													, ; //CHAVE
	'Numero CRC'															, ; //DESCRICAO
	'Numero CRC'															, ; //DESCSPA
	'Numero CRC'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'ZE3'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'ZE3_FILIAL+ZE3_PEDIDO'													, ; //CHAVE
	'Nr Pedido'																, ; //DESCRICAO
	'Nr Pedido'																, ; //DESCSPA
	'Nr Pedido'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Tabela ZE4
//
aAdd( aSIX, { ;
	'ZE4'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZE4_FILIAL+ZE4_NUMERO+ZE4_PRODUT+ZE4_SEQ'								, ; //CHAVE
	'Numero CRC+Produto+Sequencia'											, ; //DESCRICAO
	'Numero CRC+Produto+Sequencia'											, ; //DESCSPA
	'Numero CRC+Produto+Sequencia'											, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'ZE4'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'ZE4_FILIAL+ZE4_TANQUE'													, ; //CHAVE
	'Grupo Tanque'															, ; //DESCRICAO
	'Tanque'																, ; //DESCSPA
	'Tanque'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'ZE4'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'ZE4_FILIAL+ZE4_NUMERO+ZE4_PEDIDO+ZE4_ITEMPE+ZE4_SEQ+ZE4_ITEM'			, ; //CHAVE
	'Numero CRC+Pedido de Cp+Item Pedido+Sequencia+Item'					, ; //DESCRICAO
	'Numero CRC+Pedido de Cp+Item Pedido+Sequencia+Item'					, ; //DESCSPA
	'Numero CRC+Pedido de Cp+Item Pedido+Sequencia+Item'					, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Tabela ZE5
//
aAdd( aSIX, { ;
	'ZE5'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZE5_FILIAL+ZE5_PEDIDO+ZE5_ITEMPE+ZE5_LACRAM'							, ; //CHAVE
	'Filial + Pedido de compra+Item Pedido+LacreAmostra'					, ; //DESCRICAO
	'Nr CRC+Nr.Comparime+Sucursal+Pedido Comp+Item Pedido+LacreAmostra'		, ; //DESCSPA
	'Nr CRC+Nr.Comparime+Sucursal+Pedido Comp+Item Pedido+LacreAmostra'		, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela ZE6
//
aAdd( aSIX, { ;
	'ZE6'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZE6_FILIAL+ZE6_TABELA'													, ; //CHAVE
	'Cod. Tabela'															, ; //DESCRICAO
	'Cod. Tabela'															, ; //DESCSPA
	'Cod. Tabela'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela ZE7
//
aAdd( aSIX, { ;
	'ZE7'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZE7_FILIAL+ZE7_CODIGO+STR(ZE7_MEDIDA)'									, ; //CHAVE
	'Codigo+Medida'															, ; //DESCRICAO
	'Codigo+Medida'															, ; //DESCSPA
	'Codigo+Medida'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela ZZA
//
aAdd( aSIX, { ;
	'ZZA'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZZA_FILIAL+ZZA_CODDOC'													, ; //CHAVE
	'Cod. Docume.'															, ; //DESCRICAO
	'Cod. Docume.'															, ; //DESCSPA
	'Cod. Docume.'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Tabela ZZL
//
aAdd( aSIX, { ;
	'ZZL'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZZL_FILIAL+ZZL_SEQ'													, ; //CHAVE
	'Seq.'																	, ; //DESCRICAO
	'Seq.'																	, ; //DESCSPA
	'Seq.'																	, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela ZZM
//
aAdd( aSIX, { ;
	'ZZM'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZZM_FILIAL+ZZM_OPERAC+ZZM_DOC+ZZM_SERIE+ZZM_FORNEC+ZZM_LOJA+ZZM_TIPO'		, ; //CHAVE
	'Operacao+Nota Fiscal+Serie NF+Fornecedor+Loja Forn.+Tipo NF'			, ; //DESCRICAO
	'Operacao+Nota Fiscal+Serie NF+Fornecedor+Loja Forn.+Tipo NF'			, ; //DESCSPA
	'Operacao+Nota Fiscal+Serie NF+Fornecedor+Loja Forn.+Tipo NF'			, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela ZZS
//
aAdd( aSIX, { ;
	'ZZS'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZZS_FILIAL+ZZS_TIPO+ZZS_ESCOPO+ZZS_ORDEM+ZZS_CAMPO'					, ; //CHAVE
	'Tipo+Escopo+Ordem+Campo'												, ; //DESCRICAO
	'Tipo+Escopo+Ordem+Campo'												, ; //DESCSPA
	'Type+Scope+Order+Field'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSIX ) )

dbSelectArea( "SIX" )
SIX->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSIX )

	lAlt    := .F.
	lDelInd := .F.

	If !SIX->( dbSeek( aSIX[nI][1] + aSIX[nI][2] ) )
		AutoGrLog( "Índice criado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] )
	Else
		lAlt := .T.
		aAdd( aArqUpd, aSIX[nI][1] )
		If !StrTran( Upper( AllTrim( CHAVE )       ), " ", "" ) == ;
		    StrTran( Upper( AllTrim( aSIX[nI][3] ) ), " ", "" )
			AutoGrLog( "Chave do índice alterado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] )
			lDelInd := .T. // Se for alteração precisa apagar o indice do banco
		EndIf
	EndIf

	RecLock( "SIX", !lAlt )
	For nJ := 1 To Len( aSIX[nI] )
		If FieldPos( aEstrut[nJ] ) > 0
			FieldPut( FieldPos( aEstrut[nJ] ), aSIX[nI][nJ] )
		EndIf
	Next nJ
	MsUnLock()

	dbCommit()

	If lDelInd
		TcInternal( 60, RetSqlName( aSIX[nI][1] ) + "|" + RetSqlName( aSIX[nI][1] ) + aSIX[nI][2] )
	EndIf

	oProcess:IncRegua2( "Atualizando índices ..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SIX" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX6

Função de processamento da gravação do SX6 - Parâmetros

@author UPDATE gerado automaticamente
@since  04/10/2023
@obs    Gerado por EXPORDIC - V.7.5.3.3 EFS / Upd. V.5.4.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX6()
Local aEstrut   := {}
Local aSX6      := {}
Local cAlias    := ""
Local cMsg      := ""
Local lContinua := .T.
Local lReclock  := .T.
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nTamFil   := Len( SX6->X6_FIL )
Local nTamVar   := Len( SX6->X6_VAR )

AutoGrLog( "Ínicio da Atualização" + " SX6" + CRLF )

aEstrut := { "X6_FIL"    , "X6_VAR"    , "X6_TIPO"   , "X6_DESCRIC", "X6_DSCSPA" , "X6_DSCENG" , "X6_DESC1"  , ;
             "X6_DSCSPA1", "X6_DSCENG1", "X6_DESC2"  , "X6_DSCSPA2", "X6_DSCENG2", "X6_CONTEUD", "X6_CONTSPA", ;
             "X6_CONTENG", "X6_PROPRI" , "X6_VALID"  , "X6_INIT"   , "X6_DEFPOR" , "X6_DEFSPA" , "X6_DEFENG" , ;
             "X6_PYME"   }

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	''																		, ; //X6_VAR
	''																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	''																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_TABPAD'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Preco Padrao para digitacao de vendas.'								, ; //X6_DESCRIC
	'Precio estandar para el ingreso de ventas.'							, ; //X6_DSCSPA
	'Standard price for sales typing.'										, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'001'																	, ; //X6_CONTEUD
	'001'																	, ; //X6_CONTSPA
	'001'																	, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	'1'																		, ; //X6_DEFPOR
	'1'																		, ; //X6_DEFSPA
	'1'																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_XCNATCC'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Natureza financeira para Cartao da Compensação'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1010601002'															, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	''																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_XFILORI'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita o uso do campo E1_FILORIG para encontrar'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'os registros da SF2.'													, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_XSEE'																, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Recno do SEE padrao para emissao boletos posto'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'4'																		, ; //X6_CONTEUD
	'4'																		, ; //X6_CONTSPA
	'4'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0101'																	, ; //X6_FIL
	'TP_ACTCF'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita funcionalidade de carta frete no PDV (def'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'ault .F.)'																, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0101'																	, ; //X6_FIL
	'TP_ACTCHT'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita funcionalidade de cheque troco no PDV (de'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'fault .F.)'															, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0101'																	, ; //X6_FIL
	'TP_ACTCMP'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita funcionalidade de compensação no PDV (def'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'ault .F.)'																, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0101'																	, ; //X6_FIL
	'TP_ACTCT'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita funcionalidade de CTF no PDV'									, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0101'																	, ; //X6_FIL
	'TP_ACTDP'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita funcionalidade de depósito no PDV (defaul'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	't .F.)'																, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0101'																	, ; //X6_FIL
	'TP_ACTNP'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita funcionalidade de nota a prazo no PDV (de'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'fault .F.)'															, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0101'																	, ; //X6_FIL
	'TP_ACTSQ'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita funcionalidade de saque no PDV (default .'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'F.)'																	, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0101'																	, ; //X6_FIL
	'TP_ACTVLH'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita funcionalidade de vale haver no PDV (defa'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'ult .F.)'																, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0101'																	, ; //X6_FIL
	'TP_MYSEGLC'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Define a qual segmento pertence a filial'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'001'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0101009'																, ; //X6_FIL
	'MV_TABPAD'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Preco Padrao para digitacao de vendas.'								, ; //X6_DESCRIC
	'Precio estandar para el ingreso de ventas.'							, ; //X6_DSCSPA
	'Standard price for sales typing.'										, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'002'																	, ; //X6_CONTEUD
	'002'																	, ; //X6_CONTSPA
	'002'																	, ; //X6_CONTENG
	''																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0102'																	, ; //X6_FIL
	'TP_ACTNP'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita funcionalidade de nota a prazo no PDV (de'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	''																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0103'																	, ; //X6_FIL
	'TP_ACTCMP'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita funcionalidade de compensação no PDV (def'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	''																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0103'																	, ; //X6_FIL
	'TP_ACTDP'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita funcionalidade de depósito no PDV (defaul'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	''																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0103'																	, ; //X6_FIL
	'TP_ACTNP'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita funcionalidade de nota a prazo no PDV (de'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	''																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0103'																	, ; //X6_FIL
	'TP_ACTSQ'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita funcionalidade de saque no PDV (default .'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	''																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0103'																	, ; //X6_FIL
	'TP_MYSEGLC'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Define a qual segmento pertence a filial'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'002'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	''																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0103009'																, ; //X6_FIL
	'MV_TABPAD'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Preco Padrao para digitacao de vendas.'								, ; //X6_DESCRIC
	'Precio estandar para el ingreso de ventas.'							, ; //X6_DSCSPA
	'Standard price for sales typing.'										, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'001'																	, ; //X6_CONTEUD
	'001'																	, ; //X6_CONTSPA
	'001'																	, ; //X6_CONTENG
	''																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX6 ) )

dbSelectArea( "SX6" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX6 )
	lContinua := .F.
	lReclock  := .F.

	If !SX6->( dbSeek( PadR( aSX6[nI][1], nTamFil ) + PadR( aSX6[nI][2], nTamVar ) ) )
		lContinua := .T.
		lReclock  := .T.
		AutoGrLog( "Foi incluído o parâmetro " + aSX6[nI][1] + aSX6[nI][2] + " Conteúdo [" + AllTrim( aSX6[nI][13] ) + "]" )
	EndIf

	If lContinua
		If !( aSX6[nI][1] $ cAlias )
			cAlias += aSX6[nI][1] + "/"
		EndIf

		RecLock( "SX6", lReclock )
		For nJ := 1 To Len( aSX6[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX6[nI][nJ] )
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()
	EndIf

	oProcess:IncRegua2( "Atualizando Arquivos (SX6) ..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX6" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX7

Função de processamento da gravação do SX7 - Gatilhos

@author UPDATE gerado automaticamente
@since  04/10/2023
@obs    Gerado por EXPORDIC - V.7.5.3.3 EFS / Upd. V.5.4.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX7()
Local aEstrut   := {}
Local aAreaSX3  := SX3->( GetArea() )
Local aSX7      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nTamSeek  := Len( SX7->X7_CAMPO )

AutoGrLog( "Ínicio da Atualização" + " SX7" + CRLF )

aEstrut := { "X7_CAMPO", "X7_SEQUENC", "X7_REGRA", "X7_CDOMIN", "X7_TIPO", "X7_SEEK", ;
             "X7_ALIAS", "X7_ORDEM"  , "X7_CHAVE", "X7_PROPRI", "X7_CONDIC" }

//
// Campo U03_GRUPO
//
aAdd( aSX7, { ;
	'U03_GRUPO'																, ; //X7_CAMPO
	'501'																	, ; //X7_SEQUENC
	'SubStr(GrpRetName(M->U03_GRUPO),1,TamSX3("U03_DESGRP")[1])'			, ; //X7_REGRA
	'U03_DESGRP'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo U03_USER
//
aAdd( aSX7, { ;
	'U03_USER'																, ; //X7_CAMPO
	'501'																	, ; //X7_SEQUENC
	'SubStr(UsrFullName(M->U03_USER),1,TamSX3("U03_DESUSR")[1])'			, ; //X7_REGRA
	'U03_DESUSR'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo U98_OPERAD
//
aAdd( aSX7, { ;
	'U98_OPERAD'															, ; //X7_CAMPO
	'501'																	, ; //X7_SEQUENC
	'SUBSTR(POSICIONE("MDE",1,XFILIAL("MDE")+M->U98_OPERAD,"MDE_DESC"),1,TamSX3("U98_NOME")[1])', ; //X7_REGRA
	'U98_NOME'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo UH8_FORNEC
//
aAdd( aSX7, { ;
	'UH8_FORNEC'															, ; //X7_CAMPO
	'501'																	, ; //X7_SEQUENC
	'SubStr(SA2->A2_NOME,1,TamSX3("UH8_NOME")[1])'							, ; //X7_REGRA
	'UH8_NOME'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SA2'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	"XFILIAL('SA2')+M->UH8_FORNEC+M->UH8_LOJA"								, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'UH8_FORNEC'															, ; //X7_CAMPO
	'502'																	, ; //X7_SEQUENC
	'SA2->A2_CGC'															, ; //X7_REGRA
	'UH8_CGC'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo UH8_LOJA
//
aAdd( aSX7, { ;
	'UH8_LOJA'																, ; //X7_CAMPO
	'501'																	, ; //X7_SEQUENC
	'SubStr(SA2->A2_NOME,1,TamSX3("UH8_NOME")[1])'							, ; //X7_REGRA
	'UH8_NOME'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SA2'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	"XFILIAL('SA2')+M->UH8_FORNEC+M->UH8_LOJA"								, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'UH8_LOJA'																, ; //X7_CAMPO
	'502'																	, ; //X7_SEQUENC
	'SA2->A2_CGC'															, ; //X7_REGRA
	'UH8_CGC'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX7 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )

dbSelectArea( "SX7" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX7 )

	If !SX7->( dbSeek( PadR( aSX7[nI][1], nTamSeek ) + aSX7[nI][2] ) )

		AutoGrLog( "Foi incluído o gatilho " + aSX7[nI][1] + "/" + aSX7[nI][2] )

		RecLock( "SX7", .T. )
		For nJ := 1 To Len( aSX7[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX7[nI][nJ] )
			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		If SX3->( dbSeek( SX7->X7_CAMPO ) )
			RecLock( "SX3", .F. )
			SX3->X3_TRIGGER := "S"
			MsUnLock()
		EndIf

	EndIf
	oProcess:IncRegua2( "Atualizando Arquivos (SX7) ..." )

Next nI

RestArea( aAreaSX3 )

AutoGrLog( CRLF + "Final da Atualização" + " SX7" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuHlp

Função de processamento da gravação dos Helps de Campos

@author UPDATE gerado automaticamente
@since  04/10/2023
@obs    Gerado por EXPORDIC - V.7.5.3.3 EFS / Upd. V.5.4.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuHlp()
Local aHlpPor   := {}
Local aHlpEng   := {}
Local aHlpSpa   := {}

AutoGrLog( "Ínicio da Atualização" + " " + "Helps de Campos" + CRLF )


oProcess:IncRegua2( "Atualizando Helps de Campos ..." )

//
// Helps Tabela SA1
//
aHlpPor := {}
aAdd( aHlpPor, 'Observacoes Faturamento' )

aHlpEng := {}
aAdd( aHlpEng, 'Observacoes Faturamento' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Observacoes Faturamento' )

PutSX1Help( "PA1_XOBSFAT", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XOBSFAT" )

//
// Helps Tabela SLW
//
aHlpPor := {}
aAdd( aHlpPor, 'Nome Caixa' )

aHlpEng := {}
aAdd( aHlpEng, 'Nome Caixa' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Nome Caixa' )

PutSX1Help( "PLW_XNOME  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "LW_XNOME" )

aHlpPor := {}
aAdd( aHlpPor, 'Sobra/Falta' )

aHlpEng := {}
aAdd( aHlpEng, 'Sobra/Falta' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Sobra/Falta' )

PutSX1Help( "PLW_XFLTCX ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "LW_XFLTCX" )

//
// Helps Tabela U03
//
//
// Helps Tabela U92
//
//
// Helps Tabela U98
//
//
// Helps Tabela UH8
//
AutoGrLog( CRLF + "Final da Atualização" + " " + "Helps de Campos" + CRLF + Replicate( "-", 128 ) + CRLF )

Return {}


//--------------------------------------------------------------------
/*/{Protheus.doc} EscEmpresa
Função genérica para escolha de Empresa, montada pelo SM0

@return aRet Vetor contendo as seleções feitas.
             Se não for marcada nenhuma o vetor volta vazio

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function EscEmpresa()

//---------------------------------------------
// Parâmetro  nTipo
// 1 - Monta com Todas Empresas/Filiais
// 2 - Monta só com Empresas
// 3 - Monta só com Filiais de uma Empresa
//
// Parâmetro  aMarcadas
// Vetor com Empresas/Filiais pré marcadas
//
// Parâmetro  cEmpSel
// Empresa que será usada para montar seleção
//---------------------------------------------
Local   aRet      := {}
Local   aSalvAmb  := GetArea()
Local   aSalvSM0  := {}
Local   aVetor    := {}
Local   cMascEmp  := "??"
Local   cVar      := ""
Local   lChk      := .F.
Local   lOk       := .F.
Local   lTeveMarc := .F.
Local   oNo       := LoadBitmap( GetResources(), "LBNO" )
Local   oOk       := LoadBitmap( GetResources(), "LBOK" )
Local   oDlg, oChkMar, oLbx, oMascEmp, oSay
Local   oButDMar, oButInv, oButMarc, oButOk, oButCanc

Local   aMarcadas := {}


If !MyOpenSm0(.F.)
	Return aRet
EndIf


dbSelectArea( "SM0" )
aSalvSM0 := SM0->( GetArea() )
dbSetOrder( 1 )
dbGoTop()

While !SM0->( EOF() )

	If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0
		aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
	EndIf

	dbSkip()
End

RestArea( aSalvSM0 )

Define MSDialog  oDlg Title "" From 0, 0 To 280, 395 Pixel

oDlg:cToolTip := "Tela para Múltiplas Seleções de Empresas/Filiais"

oDlg:cTitle   := "Selecione a(s) Empresa(s) para Atualização"

@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", "Empresa" Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 112, 10 CheckBox oChkMar Var  lChk Prompt "Todos" Message "Marca / Desmarca"+ CRLF + "Todos" Size 40, 007 Pixel Of oDlg;
on Click MarcaTodos( lChk, @aVetor, oLbx )

// Marca/Desmarca por mascara
@ 113, 51 Say   oSay Prompt "Empresa" Size  40, 08 Of oDlg Pixel
@ 112, 80 MSGet oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
Message "Máscara Empresa ( ?? )"  Of oDlg
oSay:cToolTip := oMascEmp:cToolTip

@ 128, 10 Button oButInv    Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Inverter Seleção" Of oDlg
oButInv:SetCss( CSSBOTAO )
@ 128, 50 Button oButMarc   Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Marcar usando" + CRLF + "máscara ( ?? )"    Of oDlg
oButMarc:SetCss( CSSBOTAO )
@ 128, 80 Button oButDMar   Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Desmarcar usando" + CRLF + "máscara ( ?? )" Of oDlg
oButDMar:SetCss( CSSBOTAO )
@ 112, 157  Button oButOk   Prompt "Processar"  Size 32, 12 Pixel Action (  RetSelecao( @aRet, aVetor ), IIf( Len( aRet ) > 0, oDlg:End(), MsgStop( "Ao menos um grupo deve ser selecionado", "UPDSX" ) ) ) ;
Message "Confirma a seleção e efetua" + CRLF + "o processamento" Of oDlg
oButOk:SetCss( CSSBOTAO )
@ 128, 157  Button oButCanc Prompt "Cancelar"   Size 32, 12 Pixel Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) ;
Message "Cancela o processamento" + CRLF + "e abandona a aplicação" Of oDlg
oButCanc:SetCss( CSSBOTAO )

Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
dbSelectArea( "SM0" )
dbCloseArea()

Return  aRet


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaTodos
Função auxiliar para marcar/desmarcar todos os ítens do ListBox ativo

@param lMarca  Contéudo para marca .T./.F.
@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} InvSelecao
Função auxiliar para inverter a seleção do ListBox ativo

@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function InvSelecao( aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} RetSelecao
Função auxiliar que monta o retorno com as seleções

@param aRet    Array que terá o retorno das seleções (é alterado internamente)
@param aVetor  Vetor do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function RetSelecao( aRet, aVetor )
Local  nI    := 0

aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
	EndIf
Next nI

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaMas
Função para marcar/desmarcar usando máscaras

@param oLbx     Objeto do ListBox
@param aVetor   Vetor do ListBox
@param cMascEmp Campo com a máscara (???)
@param lMarDes  Marca a ser atribuída .T./.F.

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0

For nZ := 1 To Len( aVetor )
	If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
		If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
			aVetor[nZ][1] := lMarDes
		EndIf
	EndIf
Next

oLbx:nAt := nPos
oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} VerTodos
Função auxiliar para verificar se estão todos marcados ou não

@param aVetor   Vetor do ListBox
@param lChk     Marca do CheckBox do marca todos (referncia)
@param oChkMar  Objeto de CheckBox do marca todos

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MyOpenSM0

Função de processamento abertura do SM0 modo exclusivo

@author UPDATE gerado automaticamente
@since  04/10/2023
@obs    Gerado por EXPORDIC - V.7.5.3.3 EFS / Upd. V.5.4.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MyOpenSM0( lShared )
Local lOpen := .F.
Local nLoop := 0

If FindFunction( "OpenSM0Excl" )
	For nLoop := 1 To 20
		If OpenSM0Excl(,.F.)
			lOpen := .T.
			Exit
		EndIf
		Sleep( 500 )
	Next nLoop
Else
	For nLoop := 1 To 20
		dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )

		If !Empty( Select( "SM0" ) )
			lOpen := .T.
			dbSetIndex( "SIGAMAT.IND" )
			Exit
		EndIf
		Sleep( 500 )
	Next nLoop
EndIf

If !lOpen
	MsgStop( "Não foi possível a abertura da tabela " + ;
	IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATENÇÃO" )
EndIf

Return lOpen


//--------------------------------------------------------------------
/*/{Protheus.doc} LeLog

Função de leitura do LOG gerado com limitacao de string

@author UPDATE gerado automaticamente
@since  04/10/2023
@obs    Gerado por EXPORDIC - V.7.5.3.3 EFS / Upd. V.5.4.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function LeLog()
Local cRet  := ""
Local cFile := NomeAutoLog()
Local cAux  := ""

FT_FUSE( cFile )
FT_FGOTOP()

While !FT_FEOF()

	cAux := FT_FREADLN()

	If Len( cRet ) + Len( cAux ) < 1048000
		cRet += cAux + CRLF
	Else
		cRet += CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		cRet += "Tamanho de exibição maxima do LOG alcançado." + CRLF
		cRet += "LOG Completo no arquivo " + cFile + CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		Exit
	EndIf

	FT_FSKIP()
End

FT_FUSE()

Return cRet


/////////////////////////////////////////////////////////////////////////////
