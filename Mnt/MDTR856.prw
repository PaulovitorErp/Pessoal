#INCLUDE "MDTR856.ch"
#include 'Totvs.ch'
#INCLUDE "MSOLE.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR856
Relatório Geral de Ergonomia
Laudo Ergonômico - NR17

@return Nil

@sample MDTR856()

@author Jackson Machado
@since 29/09/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDTR856()
	//--------------------------------------------------
	// Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	//--------------------------------------------------
	Local aNGBEGINPRM 		:= NGBEGINPRM( )
	Local lSigaMdtPS		:= SuperGetMv("MV_MDTPS",.F.,"N") == "S"

	//Variáveis padrões de Relatório
	Local i
	Local cDesc1
	Local cDesc2
	Local cDesc3
	Private wnrel  			:= "MDTR856"
	Private nomeprog 		:= "MDTR856"
	Private tamanho  		:= "M"
	Private aReturn  		:= { STR0001 , 1 , STR0002 , 1 , 2 , 1 , "" , 1 } //"Zebrado"###"Administracao"
	Private nTipo    		:= 0
	Private nLastKey 		:= 0
	Private cabec1, cabec2
	Private titulo			:= STR0003 //"Laudo Ergonômico de Trabalho"
	Private aRiscErg		:= {}

	//Define diretórios a serem utilizados
	Private cPathBmp		:= AllTrim( SuperGetMv( "MV_DIRACA" , .F. , "" ) ) // Path do arquivo logo .bmp do cliente
	Private cPathEst		:= AllTrim( SuperGetMv( "MV_DIREST" , .F. , "" ) ) // Path do arquivo a ser armazenado na estação de trabalho

	//Variáveis de Controle
	Private cFiltroF		:= Alltrim( SuperGetMv( "MV_NGCATFU" , .F. , "" ) )//Define filtro dos funcionários
	Private lMdtUnix		:= If( GetRemoteType() == 2 .Or. IsSrvUnix() , .T. , .F. ) //Verifica se servidor ou estacao é Linux
	Private nQtdFunT		:= 0 //Salva quantidade de funcionários
	Private dDeLaudo		:= "",	dAteLaudo := ""//Indica as datas de início e termino do Laudo
	Private aImagens		:= {} //Salva as imagens impressão
	Private lCabec856		:= .F. //Considera impressão de cabeçalho
	Private aTipoInsc		:= {}

	//Define variáveis de Empresa e Filial
	Private cSMCOD			:= If( FindFunction( "FWGrpCompany" ) , FWGrpCompany() , SM0->M0_CODIGO )
	Private cSMFIL			:= If( FindFunction( "FWCodFil" ) , FWCodFil() , SM0->M0_CODFIL )

	//Define filtros por Centro de Custo
	Private cCCFilter		:= ""
	Private lMdtUmCC		:= lMDT190UMCC()
	Private nSizeSI3		:= If( ( TAMSX3( "I3_CUSTO" )[ 1 ] ) < 1 , 9 , ( TAMSX3( "I3_CUSTO" )[ 1 ] ) )
	Private nSizeCli		:= If( ( TAMSX3( "A1_COD" )[ 1 ] ) < 1 , 6 , ( TAMSX3( "A1_COD" )[ 1 ] ) )
	Private nSizeLoj		:= If( ( TAMSX3( "A1_LOJA" )[ 1 ] ) < 1 , 2 , ( TAMSX3( "A1_LOJA" )[ 1 ] ) )
	Private cAliasCC		:= "SI3"
	Private cDescrCC		:= "SI3->I3_DESC"
	Private nModeloImp := 1

	If AllTrim( SuperGetMv( "MV_MCONTAB" , .F. , "" ) ) == "CTB"
		cAliasCC := "CTT"
		cDescrCC := "CTT->CTT_DESC01"
	Endif

	//Define a Descrição do Relatório
	cDesc1  := STR0004 //"Laudo Ergonômico de Trabalho: "
	cDesc2  := STR0005 //"Atraves dos parametros selecionar os itens que devem ser considerados"
	cDesc3  := STR0006 //"no Relatorio.                                                        "

	//Define a Inscrição
	aTipoInsc := fTipoINSC()
	If Empty( aTipoInsc[ 1 ] )
		aTipoInsc[ 1 ] := "C.G.C."
	EndIf

	If NGCADICBASE( "TMA_PATSYP" , "A" , "TMA" , .F. )//Somente realiza a impressão com a criação dos campos

		//Define as perguntas
		Pergunte( "MDTR856" , .F. )
		//-----------------------------------------------------
		// Envia controle para a funcao SETPRINT
		//-----------------------------------------------------
		wnrel := SetPrint( "TO0" , wnrel , "MDTR856" , titulo , cDesc1 , cDesc2 , cDesc3 , .F. , "" )

		If nLastKey <> 27//Caso seja diferen de Cancelar
			SetDefault( aReturn , "TO0" )
			If nLastKey <> 27//Caso seja diferen de Cancelar

				//Posiciona no Laudo em Questão
				dbSelectArea( "TO0" )
				dbSetOrder( 1 )
				dbseek( xFilial( "TO0" ) + mv_par01 )
				dDeLaudo := TO0->TO0_DTINIC
				If !Empty( TO0->TO0_DTFIM )
					dAteLaudo := TO0->TO0_DTFIM
				Else
					dAteLaudo := dDatabase
				EndIf

				//Se houver consistência de Centro de Custo
				If lMdtUmCC
					cCCFilter := TO0->TO0_CC
				Endif

				//Carrega todos os Riscos
				aRiscErg := aClone( fGetRisco() )

				nModeloImp := mv_par03

				//Realiza a impressão conforme tipo selecionado
				If mv_par03 == 1
					RptStatus( { | lEnd | fImpPadr() } , titulo )
				ElseIf mv_par03 == 2
					RptStatus( { | lEnd | fImpGraf() } , titulo )
				Else
					RptStatus( { | lEnd | fImpWORD() } , titulo )
				EndIf
			Else
				Set Filter to
			EndIf
		Else
			Set Filter to
		Endif
	Else
		//Exibe mensagem de incompatibilidade
		NGINCOMPDIC( "UPDMDTC4" , "XXXXXX" , .F. )
	EndIf

	//Realiza a deleção das imagens salvas
	For i := 1 to Len( aImagens )
		If File( aImagens[ i , 1 ] + "JPG" )
			FErase( aImagens[ i , 1 ] + "JPG" )  //Apaga imagem extraida do repositorio
		EndIf
		If File( aImagens[ i , 1 ] + "BMP" )
			FErase( aImagens[ i , 1 ] + "BMP" )  //Apaga imagem extraida do repositorio
		EndIf
	Next i

	//--------------------------------------------------
	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	//--------------------------------------------------
	NGRETURNPRM(aNGBEGINPRM)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT856SX1
Validação das Perguntas - Dicionário - SX1

@return lRet Logico Retorna verdadeiro quando valor da pergunta está correto

@param nPerg Numérico Indica a pergunta que esta sendo validada

@sample MDT856SX1( 1 )

@author Jackson Machado
@since 29/09/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDT856SX1( nPerg )

	Local lRet		:= .T.

	Default nPerg	:= 0

	If nPerg == 1 // Laudo ?
		lRet := ExistCPO( "TO0" , mv_par01 )
	ElseIf nPerg == 2// Coordenador ?
		lRet := ExistCPO( "TMK" , mv_par02 )
	ElseIf nPerg == 5// Arquivo ?
		lRet := NaoVazio()
	EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fImpPadr
Realiza a impressão do relatório padrão

@return Nil

@sample fImpPadr()

@author Jackson Machado
@since 29/09/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fImpPadr()

	//Define variáveis do controle de impressão do relatório padrão
	Local nX
	Local nLenMemo	:= 0
	Local nPerMemo	:= 0
	Local cMemo 	:= " ",cTitulo := " ",cTexto := " "
	Local lEof 		:= .F.


	//Define variáveis privadas padrões de controle de impressão
	Private lPrint		:= .T.
	Private lPrin2		:= .T.
	Private lFirst		:= .T.
	Private lJumpCab	:= .T.
	Private lIdentar	:= .F.

	//---------------------------------------
	// Contadores de linha e pagina
	//---------------------------------------
	Private li := 80 , m_pag := 1

	//---------------------------------------
	// Verifica se deve comprimir ou nao
	//---------------------------------------
	nTipo  := If( aReturn[ 4 ] == 1 , 15 , 18 )

	cabec1 := " "
	cabec2 := " "

	//Reposiciona corretamente no Laudo
	dbSelectArea( "TO0" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "TO0" ) + mv_par01 )

	//Busca as informações da Empresa para impressão da Capa
	dbSelectArea( "SM0" )
	dbSetOrder( 1 )
	dbSeek( cSMCOD + cSMFIL )

	cCidade   := AllTrim( SM0->M0_CIDCOB ) + If( !Empty( SM0->M0_ESTCOB ) , "-" + SM0->M0_ESTCOB , " " )
	cCidadeRe := Capital( AllTrim( SM0->M0_CIDCOB ) )
	cEmp_Nome := SM0->M0_NOMECOM
	cEmp_Cnpj := aTipoInsc[ 2 ]//SM0->M0_CGC
	cEmp_Endr := SM0->M0_ENDCOB
	cEmp_Bair := SM0->M0_BAIRCOB
	cEmp_Insc := SM0->M0_INSC
	cEmp_Cnae := SM0->M0_CNAE

	//Imprime a Capa do Relatório
	SomaLinha()
	SomaLinha()
	SomaLinha()
	SomaLinha()
	@ Li , 000 PSay "                                     "+STR0003 //"LAUDO ERGONÔMICO DE TRABALHO"
	Somalinha()
	Somalinha()
	Somalinha()
	@ Li , 000 Psay STR0026 + " : " + cEmp_Nome //"NOME DA EMPRESA"
	SomaLinha()
	@ Li , 000 Psay STR0027 + " : " + cEmp_Endr //"ENDERECO"
	SomaLinha()
	@ Li , 000 Psay STR0028 + " : " + cCidade //"CIDADE"
	SomaLinha()
	@ Li , 000 Psay STR0029 + " : " + cEmp_Bair //"BAIRRO"
	SomaLinha()
	@ Li , 000 Psay aTipoInsc[1] + " " + cEmp_Cnpj
	SomaLinha()
	@ Li , 000 Psay STR0030 + " : "+ cEmp_Insc //"INSCRIÇÃO ESTADUAL"
	SomaLinha()
	@ Li , 000 Psay STR0031 + " : " + cEmp_Cnae //"CNAE"
	SomaLinha()
	@ Li , 000 Psay STR0032 + " : " + TO0->TO0_GRISCO //"GRAU DE RISCO"
	SomaLinha()
	nQtdFunT := fQtdFunRis()//Retorna quantidade de funcionarios expostos a riscos
	@ Li , 000 Psay STR0033+" : " + AllTrim( Str( If( nQtdFunT == 0 , TO0->TO0_QTDFUN , nQtdFunT ) , 9 ) ) //"Nº de Funcionários"
	If lMdtUmCC .And. !Empty( cCCFilter )
		dbSelectArea( cAliasCC )
		dbSetOrder( 1 )
		If dbSeek( xFilial( cAliasCC ) + cCCFilter )
			SomaLinha()
			@ Li , 000 Psay STR0024 + ": " + &( cDescrCC ) //"Centro de Custo"
		Endif
	Endif
	SomaLinha()
	SomaLinha()
	SomaLinha()

	//Inicia validação do Memo cadastrado
	cMemo := Alltrim( TO0->TO0_DESCRI )
	If NGCADICBASE( "TO0_MMSYP2" , "A" , "TO0" , .F. )
		If !Empty( TO0->TO0_MMSYP2 )
			cMMSYP2 := MSMM( TO0->TO0_MMSYP2 , 80 )
			If !Empty( cMMSYP2 )
				If !Empty( cMemo )
					cMemo += Chr( 13 ) + Chr( 10 )
				Endif
				cMemo += cMMSYP2
			Endif
		Endif
	ElseIf NGCADICBASE( "TO0_DESC2" , "A" , "TO0" , .F. )
		If !Empty( TO0->TO0_DESC2 )
			If !Empty( cMemo )
				cMemo += Chr( 13 ) + Chr( 10 )
			Endif
			cMemo += Alltrim( TO0->TO0_DESC2 )
		Endif
	Endif

	SetRegua( 100 )
	nLenMemo := Len( cMemo )
	nPerMemo := 0

	While !lEof //Utiliza variável lEof para indicar quando Memo vazio e finalização da Impressão
		If Empty( cMemo )  //Memo vazio
			lEof := .T.
			Exit
		Else
			//Verifica impressão de Título
			nPos1 := At( "#" , cMemo ) //Inicio de um Titulo

			If nPos1 > 1//Caso definição de título (#) não esteja contida na primeira expressão
				cTexto := AllTrim( SubStr( cMemo , 1 , nPos1 - 1 ) ) //Considera como impressão o texto do início até antes da #
				cMemo  := AllTrim( SubStr( cMemo , nPos1 ) ) //Salva a partir da #
				fImpDoc856( AllTrim( cTexto ) )//Realiza a impressão do Texto
				fRegua( nLenMemo , @nPerMemo , Len( cMemo ) ) //Incrementa Regua
				Loop
			ElseIf nPos1 == 1 //Existe # //Caso definição de título (#) contida na primeira expressão
				cMemo   := AllTrim( SubStr( cMemo , nPos1 + 1 ) )//Considera o memo após a #
				nPos1   := At( "#" , cMemo )//Localiza próximo título (#)
				cTitulo := AllTrim( SubStr( cMemo , 1 , nPos1 - 1 ) )//Considera como impressão o texto do início até antes da #
				cMemo   := AllTrim( SubStr( cMemo , nPos1 + 1 ) )//Salva a partir da #

				nPos1   := At( "#" , cMemo )//Verifica se há mais títulos a serem impressos
				If nPos1 > 0 // Caso haja mais títulos
					cTexto := AllTrim( SubStr( cMemo , 1 , nPos1 - 1 ) )//Considera o título para impressão
					cMemo  := AllTrim( SubStr( cMemo , nPos1 ) )//Salva a partir da #
				Else
					cTexto := AllTrim( cMemo )//Considera todo o memo
					cMemo  := " "//Zera o Memo
					lEof   := .T.//Encerra a impressão
				Endif
			Else //Caso nao exista # imprime todo o campo Memo
				//IMPRIME TEXTO
				fImpDoc856( AllTrim( cMemo ) )
				lEof := .T.
				Exit
			Endif

			//IMPRIME TITULO
			If !Empty( cTitulo )
				fImpHea856( cTitulo )
			Endif

			//IMPRIME TEXTO
			If !Empty( cTexto )
				lPrint := .T.
				lPrin2 := .T.
				fImpDoc856( AllTrim( cTexto ) )
			Endif

		Endif

		fRegua( nLenMemo , @nPerMemo , Len( cMemo ) ) //Incrementa Regua

	End

	//Verifica se há termo vinculado ao Laudo
	cTxtMemo := " "
	dbSelectArea( "TMZ" )
	dbSetOrder( 1 )
	If dbSeek( xFilial( "TMZ" ) + TO0->TO0_TERMO )
		cTxtMemo := TMZ->TMZ_DESCRI
	EndIf

	//Imprime as informações do Coordenador
	dbSelectArea( "TMK" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "TMK" ) + Mv_par02 )

	If Li != 6 //Se o cursor estiver na primeira linha nao eh necessario criar uma nova pagina
		li := 80
		Somalinha()
	Endif

	@li,048 Psay STR0034 //"RESPONSÁVEIS TÉCNICOS"
	For nX := 1 to 3
		Somalinha()
	Next nX
	fImpDoc856( Alltrim( cTxtMemo ) )
	Somalinha()
	Somalinha()
	Somalinha()
	@ Li , 000 Psay ( STR0035 + ": " + AllTrim( SubStr( TMK->TMK_NOMUSU , 1 , 40 ) ) ) //"COORDENADOR"
	Somalinha()
	@ Li , 000 Psay (STR0036 + ": " + AllTrim( TMK->TMK_REGMTB ) ) //"REG.SSST"
	If !Empty( TMK->TMK_NUMENT )
		Somalinha()
		@ Li , 000 Psay ( If( Empty( TMK->TMK_ENTCLA ) , "" , AllTrim( TMK->TMK_ENTCLA ) + ": " ) + AllTrim( TMK->TMK_NUMENT ) )
	End If
	If FieldPos( "TMK_TELUSU" ) > 0
		Somalinha()
		@ Li , 000 Psay ( STR0037 + ": " + AllTrim( TMK->TMK_TELUSU ) ) //"FONE"
	Endif
	If FieldPos("TMK_ENDUSU") > 0
		Somalinha()
		@ Li , 000 Psay ( STR0038 + ": " + AllTrim( TMK->TMK_ENDUSU ) ) //"ENDEREÇO"
	Endif

	//Imprime as informações do Responsável
	dbSelectArea( "TMK" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "TMK" ) + TO0->TO0_CODUSU )

	SomaLinha()
	SomaLinha()
	@ Li , 000 Psay (STR0039 + ": " + AllTrim( SubStr( TMK->TMK_NOMUSU , 1 , 40 ) ) ) //"RESPONSÁVEL"
	If !Empty( TMK->TMK_NUMENT )
		Somalinha()
		@ Li , 000 Psay ( If( Empty( TMK->TMK_ENTCLA ) , "" , AllTrim( TMK->TMK_ENTCLA ) + ": " ) + AllTrim( TMK->TMK_NUMENT ) )
	End If
	If FieldPos( "TMK_TELUSU" ) > 0
		Somalinha()
		@ Li , 000 Psay (STR0040 + ": " + AllTrim( TMK->TMK_TELUSU ) ) //"FONE "
	Endif
	If FieldPos("TMK_ENDUSU") > 0
		Somalinha()
		@ Li , 000 Psay ( STR0038 + ": " + AllTrim( TMK->TMK_ENDUSU ) ) //"ENDEREÇO"
	Endif

	//Imprime a finalização do Laudo com Cidade, Data e Assinatura
	For nX := 1 to 3
		Somalinha()
	Next nX
	@ Li , 000 Psay cCidadeRe + ", " + StrZero( Day( dDataBase ) , 2 ) + STR0041 + MesExtenso( dDataBase ) + STR0041 + ; //" de "###" de "
				StrZero( Year( dDataBase ) , 4 ) + "."
	Somalinha()
	@ Li , 000 Psay ( STR0042 + ": " + AllTrim( Transform( Date() , "99/99/9999" ) ) ) //"DATA"
	For nX := 1 to 5
		Somalinha()
	Next nX
	Somalinha()
	@li,000 Psay ( STR0043 + ": " + "___________________________________________" ) //"Ass."


	//--------------------------------------------------------
	// Devolve a condicao original do arquivo principal
	//--------------------------------------------------------
	RetIndex( "TO0" )
	Set Filter To
	Set Device to Screen
	If aReturn[ 5 ] = 1
		Set Printer To
		dbCommitAll()
		OurSpool(wnrel)
	EndIf

	MS_FLUSH()

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fImpGraf
Realiza a impressão do relatório gráfico

@return Nil

@sample fImpGraf()

@author Jackson Machado
@since 29/09/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fImpGraf()

	//Define variáveis do controle de impressão do relatório gráfico
	Local nX
	Local nLenMemo	:= 0
	Local nPerMemo	:= 0
	Local cMemo 	:= " ",cTitulo := " ",cTexto := " "
	Local lEof 		:= .F.

	//Define variáveis privadas padrões de controle de impressão
	Private lPrint := .t.
	Private lPrin2 := .t.
	Private lFirst := .t.
	Private lJumpCab := .t.
	Private lIdentar := .f.
	Private nPaginaG   := 0

	//Define as fontes de Impressão
	Private oFont08		:= TFont():New( "Verdana" , 08 , 08 , , .F. , , , , .F. , .F. )
	Private oFont08b	:= TFont():New( "Verdana" , 08 , 08 , , .T. , , , , .F. , .F. )
	Private oFont10b	:= TFont():New( "Verdana" , 10 , 10 , , .T. , , , , .F. , .F. )
	Private oFont10		:= TFont():New( "Verdana" , 10 , 10 , , .F. , , , , .F. , .F. )
	Private oFont12b	:= TFont():New( "Verdana" , 12 , 12 , , .T. , , , , .F. , .F. )
	Private oFont12 	:= TFont():New( "Verdana" , 12 , 12 , , .F. , , , , .F. , .F. )
	Private oFont12bs	:= TFont():New( "Verdana" , 12 , 12 , , .T. , , , , .T. , .T. )
	Private oFont12s	:= TFont():New( "Verdana" , 12 , 12 , , .F. , , , , .T. , .T. )
	Private oFont28b	:= TFont():New( "Verdana" , 28 , 28 , , .T. , , , , .F. , .F. )
	Private oFont50b	:= TFont():New( "Verdana" , 50 , 50 , , .T. , , , , .F. , .F. )

	//------------------------------------
	// Contadores de linha e pagina
	//------------------------------------
	PRIVATE lin := 9999 ,m_pag := 1

	//Caminho do Logo.bmp
	Private cStartDir := AllTrim( GetSrvProfString( "StartPath" , "\" ) )
	Private cStartLogo := " "

	//Definição inicial da impressão
	oPrintErg := TMSPrinter():New( OemToAnsi( STR0003 ) ) //"LAUDO ERGONÔMICO DE TRABALHO"
	oPrintErg:Setup()
	oPrintErg:SetPortrait()// Seta Retrato como padrão

	If File( cStartDir + "LGRL" + cSMCOD + cSMFIL + ".BMP" )
		cStartLogo := cStartDir + "LGRL" + cSMCOD + cSMFIL + ".BMP"
	ElseIf File( cStartDir + "LGRL" + cSMCOD + ".BMP")
		cStartLogo := cStartDir + "LGRL" + cSMCOD + ".BMP"
	Endif

	//------------------------------------
	// Verifica se deve comprimir ou nao
	//------------------------------------
	nTipo  := If( aReturn[ 4 ] == 1 , 15 , 18 )

	cabec1 := " "
	cabec2 := " "

	//Reposiciona corretamente no Laudo
	dbSelectArea( "TO0" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "TO0" ) + Mv_par01 )

	//Busca as informações da Empresa para impressão da Capa
	dbSelectArea( "SM0" )
	dbSetOrder( 1 )
	dbSeek( cSMCOD + cSMFIL )

	cCidade   := AllTrim( SM0->M0_CIDCOB ) + If( !Empty( SM0->M0_ESTCOB ) , "-" + SM0->M0_ESTCOB , " " )
	cCidadeRe := Capital( AllTrim( SM0->M0_CIDCOB ) )
	cEmp_Nome := SM0->M0_NOMECOM
	cEmp_Cnpj := aTipoInsc[ 2 ]//SM0->M0_CGC
	cEmp_Endr := SM0->M0_ENDCOB
	cEmp_Bair := SM0->M0_BAIRCOB
	cEmp_Insc := SM0->M0_INSC
	cEmp_Cnae := SM0->M0_CNAE

	//Imprime a Capa do Relatório
    cTitErgon := " "
	cTitErgon := STR0003 //"Laudo Ergonômico de Trabalho"

	SomaLinha(150)
	oPrintErg:Say( 1200 , 400 , MemoLine( cTitErgon , 30 , 1 ) , oFont28b )
	oPrintErg:Say( 1400 , 980 , MemoLine( cTitErgon , 30 , 2 ) , oFont28b )

	oPrintErg:Say( 2340 , 150 , STR0044 + ":" , oFont12b ) //"EMPRESA"
	oPrintErg:Say( 2340 , 600 , cEmp_Nome , oFont12 )
	oPrintErg:Say( 2420 , 150 , aTipoInsc[1] + " " , oFont12b )
	oPrintErg:Say( 2420 , 600 , cEmp_Cnpj , oFont12 )
	oPrintErg:Say( 2500 , 150 , Upper(STR0028) + ":" , oFont12b ) //"Cidade"
	oPrintErg:Say( 2500 , 600 , cCidade,oFont12)

	lin := 9999 //Forçar quebra de pagina
	Somalinha( 150 )
	oPrintErg:Say( lin , 150 , "1. " + STR0045 , oFont12b ) //"IDENTIFICAÇÃO DA EMPRESA"
	Somalinha( 80 )
	oPrintErg:Say( lin , 150 , STR0046 + ":" , oFont10b ) //"Razão Social"
	oPrintErg:Say( lin , 600 , cEmp_Nome , oFont10 )
	SomaLinha()
	oPrintErg:Say( lin , 150 , aTipoInsc[ 1 ] + " " , oFont10b ) //"CNPJ :"
	oPrintErg:Say( lin , 600 , cEmp_Cnpj , oFont10 )
	SomaLinha()
	oPrintErg:Say( lin , 150 , STR0030 + ":" , oFont10b ) //"Inscrição Estadual"
	oPrintErg:Say( lin , 600 , cEmp_Insc , oFont10 )
	SomaLinha()
	oPrintErg:Say( lin , 150 , STR0038 + ":" , oFont10b ) //"Endereço"
	oPrintErg:Say( lin , 600 , cEmp_Endr , oFont10 )
	SomaLinha()
	oPrintErg:Say( lin , 150 , STR0029 + ":" , oFont10b ) //"Bairro"
	oPrintErg:Say( lin , 600 , cEmp_Bair , oFont10 )
	SomaLinha()
	oPrintErg:Say( lin , 150 , STR0028 + ":" , oFont10b ) //"Cidade"
	oPrintErg:Say( lin , 600 , cCidade , oFont10 )
	SomaLinha()
	oPrintErg:Say( lin , 150 , STR0031+":" , oFont10b ) //"CNAE"
	oPrintErg:Say( lin , 600 , cEmp_Cnae , oFont10 )
	SomaLinha()
	oPrintErg:Say( lin , 150 , STR0032 + ":" , oFont10b ) //"Grau de Risco"
	oPrintErg:Say( lin , 600 , TO0->TO0_GRISCO , oFont10 )
	SomaLinha()
	oPrintErg:Say( lin , 150 , STR0033 + ":" , oFont10b ) //"Nº de Funcionários"
	nQtdFunT := fQtdFunRis()//Retorna quantidade de funcionarios expostos a riscos
	oPrintErg:Say( lin , 600 , Alltrim( Str( If( nQtdFunT == 0 , TO0->TO0_QTDFUN , nQtdFunT ) , 9 ) ) , oFont10 )
	If lMdtUmCC .And. !Empty( cCCFilter )
		dbSelectArea( cAliasCC )
		dbSetOrder( 1 )
		If dbSeek( xFilial( cAliasCC ) + cCCFilter )
			SomaLinha()
			oPrintErg:Say( lin , 150 , STR0024 + ":" , oFont10b ) //"Centro de Custo"
			oPrintErg:Say( lin , 600 , &( cDescrCC ) , oFont10 )
		Endif
	Endif
	Somalinha(120)

	//Inicia validação do Memo cadastrado
	cMemo := Alltrim( TO0->TO0_DESCRI )
	If NGCADICBASE( "TO0_MMSYP2" , "A" , "TO0" , .F. )
		If !Empty( TO0->TO0_MMSYP2 )
			cMMSYP2 := MSMM( TO0->TO0_MMSYP2 , 80 )
			If !Empty( cMMSYP2 )
				If !Empty( cMemo )
					cMemo += Chr( 13 ) + Chr( 10 )
				Endif
				cMemo += cMMSYP2
			Endif
		Endif
	ElseIf NGCADICBASE( "TO0_DESC2" , "A" , "TO0" , .F. )
		If !Empty( TO0->TO0_DESC2 )
			If !Empty( cMemo )
				cMemo += Chr( 13 ) + Chr( 10 )
			Endif
			cMemo += Alltrim( TO0->TO0_DESC2 )
		Endif
	Endif

	SetRegua( 100 )
	nLenMemo := Len( cMemo )
	nPerMemo := 0

	While !lEof //Utiliza variável lEof para indicar quando Memo vazio e finalização da Impressão
		If Empty( cMemo )  //Memo vazio
			lEof := .T.
			Exit
		Else
			//Verifica impressão de Título
			nPos1 := At( "#" , cMemo ) //Inicio de um Titulo

			If nPos1 > 1//Caso definição de título (#) não esteja contida na primeira expressão
				cTexto := AllTrim( SubStr( cMemo , 1 , nPos1 - 1 ) )//Considera como impressão o texto do início até antes da #
				cMemo  := AllTrim( SubStr( cMemo , nPos1 ) )//Salva a partir da #
				fImpDoc856( AllTrim( cTexto ) )//Realiza a impressão do Texto
				fRegua( nLenMemo , @nPerMemo , Len( cMemo ) ) //Incrementa Regua
				Loop
			ElseIf nPos1 == 1 //Existe #//Caso definição de título (#) contida na primeira expressão
				cMemo   := AllTrim( SubStr( cMemo , nPos1 + 1 ) )//Considera o memo após a #
				nPos1   := At( "#" , cMemo )//Localiza próximo título (#)
				cTitulo := AllTrim( SubStr( cMemo , 1 , nPos1 - 1 ) )//Considera como impressão o texto do início até antes da #
				cMemo   := AllTrim( SubStr( cMemo , nPos1 + 1 ) )//Salva a partir da #

				nPos1   := At( "#" , cMemo )//Verifica se há mais títulos a serem impressos
				If nPos1 > 0// Caso haja mais títulos
					cTexto := AllTrim( SubStr( cMemo , 1 , nPos1 - 1 ) )//Considera o título para impressão
					cMemo  := AllTrim( SubStr( cMemo , nPos1 ) )//Salva a partir da #
				Else
					cTexto := AllTrim( cMemo )//Considera todo o memo
					cMemo  := " "//Zera o Memo
					lEof   := .T.//Encerra a impressão
				Endif
			Else //Caso nao exista # imprime todo o campo Memo
				//IMPRIME TEXTO
				fImpDoc856( AllTrim( cMemo ) )
				lEof := .T.
				Exit
			Endif

			//IMPRIME TITULO
			If !Empty( cTitulo )
				fImpHea856( cTitulo )
			Endif

			//IMPRIME TEXTO
			If !Empty( cTexto )
				lPrint := .T.
				lPrin2 := .T.
				fImpDoc856( Alltrim( cTexto ) )
			Endif

		Endif

		fRegua( nLenMemo , @nPerMemo , Len( cMemo ) ) //Incrementa Regua

	End

	//Verifica se há termo vinculado ao Laudo
	cTxtMemo := " "
	dbSelectArea( "TMZ" )
	dbSetOrder( 1 )
	IF dbSeek( xFilial( "TMZ" ) + TO0->TO0_TERMO )
		cTxtMemo := TMZ->TMZ_DESCRI
	Endif

	//Imprime as informações do Coordenador
	dbSelectArea( "TMK" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "TMK" ) + Mv_par02 )

	If Lin != 300 //Se o cursor estiver na primeira linha nao eh necessario criar uma nova pagina
		Lin := 9999
		Somalinha()
	Endif
	oPrintErg:Say( lin , 1000 , STR0034 , oFont12b ) //"RESPONSÁVEIS TÉCNICOS"
	Somalinha( 180 )
	fImpDoc856( AllTrim( cTxtMemo ) )
	Somalinha(180)
	oPrintErg:Say( lin , 100 , STR0035 + ":" , oFont12b ) //"COORDENADOR"
	oPrintErg:Say( lin , 600 , AllTrim( SubStr( TMK->TMK_NOMUSU , 1 , 40 ) ) , oFont12 )
	Somalinha()
	oPrintErg:Say( lin , 100 , STR0036 + ":" , oFont12b ) //"REG.SSST"
	oPrintErg:Say( lin , 600 , AllTrim( TMK->TMK_REGMTB ) , oFont12 )
  	If !Empty( TMK->TMK_NUMENT )
  		Somalinha()
  		oPrintErg:Say( lin , 100 , If( Empty( TMK->TMK_ENTCLA ) , "" , AllTrim( TMK->TMK_ENTCLA ) + ": " ) , oFont12b )
  		oPrintErg:Say( lin , 600 , AllTrim( TMK->TMK_NUMENT ) , oFont12 )
  	End If
	If TMK->( FieldPos( "TMK_TELUSU" ) ) > 0
		Somalinha()
		oPrintErg:Say( lin , 100 , STR0037+":" , oFont12b ) //"FONE"
		oPrintErg:Say( lin , 600 , AllTrim( TMK->TMK_TELUSU ) , oFont12 )
	Endif
	If TMK->(FieldPos("TMK_ENDUSU")) > 0
		Somalinha()
		oPrintErg:Say( lin , 100 , STR0038 + ":" , oFont12b ) //"ENDEREÇO"
		oPrintErg:Say( lin , 600 , AllTrim( TMK->TMK_ENDUSU ) , oFont12 )
	Endif

	//Imprime as informações do Responsável
	dbSelectArea( "TMK" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "TMK" ) + TO0->TO0_CODUSU )
	SomaLinha( 120 )
	oPrintErg:Say( lin , 100 , STR0039 + ": " , oFont12b ) //"RESPONSÁVEL"
	oPrintErg:Say( lin , 600 , AllTrim( SubStr( TMK->TMK_NOMUSU , 1 , 40 ) ) , oFont12 )
	If !Empty( TMK->TMK_NUMENT )
		Somalinha()
		oPrintErg:Say( lin , 100 , If( Empty( TMK->TMK_ENTCLA ) , "" , Alltrim( TMK->TMK_ENTCLA ) + ": " ) , oFont12b )
		oPrintErg:Say( lin , 600 , AllTrim( TMK->TMK_NUMENT ) , oFont12 )
	End If
	If TMK->( FieldPos( "TMK_TELUSU" ) ) > 0
		Somalinha()
		oPrintErg:Say( lin , 100 , STR0037 + ": " , oFont12b ) //"FONE"
		oPrintErg:Say( lin , 600 , AllTrim( TMK->TMK_TELUSU ) , oFont12 )
	Endif
	If TMK->( FieldPos( "TMK_ENDUSU" ) ) > 0
		Somalinha()
		oPrintErg:Say( lin , 100 , STR0038 + ":" , oFont12b ) //"ENDEREÇO"
		oPrintErg:Say( lin , 600 , Alltrim( TMK->TMK_ENDUSU ) , oFont12 )
	Endif

	//Imprime a finalização do Laudo com Cidade, Data e Assinatura
	Somalinha(180)
	cTxtTmp := cCidadeRe + ", " + StrZero( Day( dDataBase ) , 2 ) + STR0041 + MesExtenso( dDataBase ) + STR0041 + StrZero( Year( dDataBase ) , 4 ) + "." //" de "###" de "
	oPrintErg:Say( lin , 100 , cTxtTmp , oFont12b )
	Somalinha()
	oPrintErg:Say( lin , 100 , STR0042 + ":" , oFont12b ) //"DATA"
	oPrintErg:Say( lin , 300 , AllTrim( Transform( Date() , "99/99/9999" ) ) , oFont12 )
	Somalinha(300)
	oPrintErg:Say( lin , 100 , STR0043 + ": " + "___________________________________________" , oFont12 ) //"Ass."

	//Identifica a forma de impressão do Relatório (Tela ou Spool)
	If aReturn[ 5 ] == 1
		oPrintErg:Preview()
	Else
		oPrintErg:Print()
	EndIf

	//----------------------------------------------------------
	// Devolve a condicao original do arquivo principal
	//----------------------------------------------------------
	RetIndex( "TO0" )
	Set Filter To

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fImpWORD
Realiza a impressão do relatório WORD

@return Nil

@sample fImpWORD()

@author Jackson Machado
@since 29/09/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fImpWORD()

	//Define variáveis do controle de impressão do relatório WORD
	Local nResp
	Local nLinha, nLinhasMemo
	Local nLenMemo	:= 0
	Local nPerMemo	:= 0
	Local lImpress
	Local lEof		:= .F.
	Local aRespRel  := {}, aUsuSX5

	//Define variáveis de Controle dos Arquivos
	Local cTmpWord
	Local cRootPath
	Local cFileLogo
	Local cArqSaida
	Local cWordExt  := ".dot"
	Local cArqDot	:= "ergonomia"// Nome do arquivo modelo do Word
	Local cMemo		:= " ",cTitulo := " ",cTexto := " "
	Local cBarraRem	:= "\"
	Local cBarraSrv	:= "\"
	Local cArqBmp	:= "LGRL" + cSMCOD + cSMFIL + ".BMP" //Nome do arquivo logo do cliente
	Local cArqBmp2	:= "LGRL" + cSMCOD + ".BMP" //Nome do arquivo logo do cliente
	Local cPathDot	:= cPathBmp //Path do arquivo modelo do Word
	Local cPathBm2	:= cPathBmp
	Local oWordTmp

	//Define variáveis privadas padrões de controle de impressão
	Private lCriaIndice := .F.
	Private cVar		:= "cVAR" , nVar := 1
	Private cVar1		:= "cTIT" , nVar1 := 1
	Private lPrint		:= .T.
	Private lPrin2		:= .T.
	Private lFirst		:= .T.
	Private lJumpCab	:= .T.
	Private lIdentar	:= .F.
	Private oWord

	//---------------------------------
	// Verifica versão do Word
	//---------------------------------
	oWordTmp := OLE_CreateLink( 'TMsOleWord97' )//Cria link como Word
	cTmpWord := OLE_GetProperty( oWordTmp, '209' )
	OLE_CloseLink( oWordTmp ) //Fecha link
	If Valtype( cTmpWord ) == "C"
		If "12" $ cTmpWord
			cWordExt := ".dotm"
		Endif
	Endif

	//Salva extensão correta
	cArqDot += cWordExt

	//Realiza consistência das barras para utilização correta do Sistema Operacional
	If GetRemoteType() == 2  //Estacao com Sistema Operacional Unix
		cBarraRem := "/"
	Endif
	If IsSrvUnix()//Servidor e da família Unix (linux, solaris, free-bsd, hp-ux, etc.)
		cBarraSrv := "/"
	Endif

	//Monta Localização dos Arquivos
	cPathDot += If( Substr( cPathDot , Len( cPathDot ) , 1 ) != cBarraSrv , cBarraSrv , "" ) + cArqDot
	cPathEst += If( Substr( cPathEst , Len( cPathEst ) , 1 ) != cBarraRem , cBarraRem , "" )

	cPathBmp += If( Substr( cPathBmp , Len( cPathBmp ) , 1 ) != cBarraSrv , cBarraSrv , "" ) + cArqBmp
	cPathBm2 += If( Substr( cPathBm2 , Len( cPathBm2 ) , 1 ) != cBarraSrv , cBarraSrv , "" ) + cArqBmp2

	//Cria diretório se não existir
	MontaDir( cPathEst )

	//Se existir .dot na estacao, apaga!
	If File( cPathEst + cArqDot )
		FErase( cPathEst + cArqDot )
	EndIf
	If File( cPathDot )
		CpyS2T( cPathDot , cPathEst , .T. )
		// Copia do Server para o Remote, é necessário
		// Para que o WordView e o próprio Word possam preparar o arquivo para impressão e
		// ou visualização .... Copia o DOT que esta no ROOTPATH Protheus para o PATH da
		// estação , por exemplo C:\WORDTMP
		//__copyfile(cPathDot,cPathEst+cArqDot)
		//Logo
		//Se existir .bmp na estação, apaga!
		If File( cPathBmp )
			If File( cPathEst + cArqBmp )
				FErase( cPathEst + cArqBmp )
			EndIf
			__copyfile( cPathBmp , cPathEst + cArqBmp )
		ElseIf File( cPathBm2 )
			If File( cPathEst + cArqBmp2 )
				FErase( cPathEst + cArqBmp2 )
			EndIf
			__copyfile( cPathBm2 , cPathEst + cArqBmp2 )
			cArqBmp := cArqBmp2
		EndIf
		nQtdFunT := fQtdFunRis()//Retorna quantidade de funcionarios expostos a riscos

		lImpress 	:= mv_par04 == 1//Verifica se a saida sera em Impressora (1) ou Tela (2)
		cArqSaida	:= If( Empty( mv_par05 ) , "Documento1" , AllTrim( mv_par05 ) )// Nome do arquivo de saida

		oWord		:= OLE_CreateLink( "TMsOleWord97" )//Cria link como Word

		OLE_NewFile( oWord , cPathEst + cArqDot )//Abrindo o arquivo modelo automaticamente

		If lImpress //Impressao via Impressora
			OLE_SetProperty( oWord , oleWdVisible , .F. )
			OLE_SetProperty( oWord , oleWdPrintBack , .T. )
		Else //Impressao na Tela(Arquivo)
			OLE_SetProperty( oWord , oleWdVisible ,  .F. )
			OLE_SetProperty( oWord , oleWdPrintBack , .F. )
		EndIf

		//Busca Informações da Empresa
		dbselectarea( "SM0" )
		dbsetorder( 1 )
		dbseek( cSMCOD + cSMFIL )
		cCidade   	:= Alltrim( SM0->M0_CIDCOB ) + If( !Empty( SM0->M0_ESTCOB ) , "-" + SM0->M0_ESTCOB , " " )
		cEmp_Nome	:= SM0->M0_NOMECOM
		cEmp_Cnpj	:= aTipoInsc[ 2 ]//SM0->M0_CGC
		cEmp_Endr	:= SM0->M0_ENDCOB
		cEmp_Bair	:= SM0->M0_BAIRCOB
		cEmp_Insc	:= SM0->M0_INSC
		cEmp_Cnae	:= SM0->M0_CNAE
		cEmp_Unop	:= " "
		cMatriz		:= " "
		cEmp_GRisco	:= TO0->TO0_GRISCO
		cNum_Func 	:= Alltrim( Str( If( nQtdFunT == 0 , TO0->TO0_QTDFUN , nQtdFunT ) , 9 ) )

		//Imprime Logo
		cFileLogo := cPathEst + cArqBmp
		If !lMdtUnix //Se for Windows
			If File( cFileLogo )
				OLE_SetDocumentVar( oWord , "Cria_Var" , cFileLogo )
				OLE_ExecuteMacro( oWord , "Insere_logo" )
			Endif
		Endif

		//Dados Empresa
		OLE_SetDocumentVar( oWord , "Empresa" , cEmp_Nome )
		OLE_SetDocumentVar( oWord , "tipoInsc" , aTipoInsc[ 1 ] )
		OLE_ExecuteMacro( oWord , "Com_Negrito" )
		OLE_SetDocumentVar( oWord , "CGC" , cEmp_Cnpj )
		OLE_SetDocumentVar( oWord , "Ie" , cEmp_Insc )
		OLE_SetDocumentVar( oWord , "Cnae" , cEmp_Cnae )
		OLE_SetDocumentVar( oWord , "GRisco" , cEmp_GRisco )
		OLE_SetDocumentVar( oWord , "Cidade" , cCidade )
		OLE_SetDocumentVar( oWord , "Endereco" , cEmp_Endr )
		OLE_SetDocumentVar( oWord , "Bairro" , cEmp_Bair )
		OLE_SetDocumentVar( oWord , "cNum_Func" , cNum_Func )
		If lMdtUmCC .And. !Empty( cCCFilter )
			dbSelectArea( cAliasCC )
			dbSetOrder( 1 )
			If dbSeek( xFilial( cAliasCC ) + cCCFilter )
				OLE_SetDocumentVar( oWord , "CapaCC" , &( cDescrCC ) )
			Else
				OLE_ExecuteMacro( oWord , "Deleta_Linha" )//Deleta linha da tabela
			Endif
		Else
			OLE_ExecuteMacro( oWord , "Deleta_Linha" )//Deleta linha da tabela
		Endif
		OLE_SetDocumentVar(oWord , "RazaoSocial" , cMatriz )
		If Empty( TO0->TO0_DTVALI )
			OLE_SetDocumentVar( oWord , "Validade" , " " )
		Else
			OLE_SetDocumentVar( oWord , "Validade" , Upper( MesExtenso( TO0->TO0_DTVALI ) ) + "/" + StrZero( Year( TO0->TO0_DTVALI ) , 4 ) )
		Endif

		OLE_ExecuteMacro( oWord , "NewPage" )

		//Inicia validação do Memo cadastrado
		cMemo := Alltrim( TO0->TO0_DESCRI )
		If NGCADICBASE( "TO0_MMSYP2" , "A" , "TO0" , .F. )
			If !Empty( TO0->TO0_MMSYP2 )
				cMMSYP2 := MSMM( TO0->TO0_MMSYP2 , 80 )
				If !Empty( cMMSYP2 )
					If !Empty( cMemo )
						cMemo += Chr( 13 ) + Chr( 10 )
					Endif
					cMemo += cMMSYP2
				Endif
			Endif
		ElseIf NGCADICBASE( "TO0_DESC2" , "A" , "TO0" , .F. )
			If !Empty( TO0->TO0_DESC2 )
				If !Empty( cMemo )
					cMemo += Chr( 13 ) + Chr( 10 )
				Endif
				cMemo += Alltrim( TO0->TO0_DESC2 )
			Endif
		Endif

		SetRegua( 100 )
		nLenMemo := Len( cMemo )
		nPerMemo := 0

		While !lEof
			OLE_ExecuteMacro( oWord , "Atualiza" )

			If Empty( cMemo )//Memo vazio
				lEof := .T.
				Exit
			Else
				//Verifica impressão de Título
				nPos1 := At( "#" , cMemo )//Inicio de um Titulo

				If nPos1 > 1//Caso definição de título (#) não esteja contida na primeira expressão
					cTexto := AllTrim( SubStr( cMemo , 1 , nPos1 - 1 ) )//Considera como impressão o texto do início até antes da #
					cMemo  := AllTrim( SubStr( cMemo , nPos1 ) )//Salva a partir da #
					fImpDoc856( AllTrim( cTexto ) )//Realiza a impressão do Texto
					fRegua( nLenMemo , @nPerMemo , Len( cMemo ) ) //Incrementa Regua
					Loop
				ElseIf nPos1 == 1 //Existe #//Caso definição de título (#) contida na primeira expressão
					cMemo   := AllTrim( SubStr( cMemo , nPos1 + 1 ) )//Considera o memo após a #
					nPos1   := At( "#" , cMemo )//Localiza próximo título (#)
					cTitulo := AllTrim( SubStr( cMemo , 1 , nPos1 - 1 ) )//Considera como impressão o texto do início até antes da #
					cMemo   := AllTrim( SubStr( cMemo , nPos1 + 1 ) )//Salva a partir da #

					nPos1   := At( "#" , cMemo )//Verifica se há mais títulos a serem impressos
					If nPos1 > 0// Caso haja mais títulos
						cTexto := AllTrim( SubStr( cMemo , 1 , nPos1 - 1 ) )//Considera o título para impressão
						cMemo  := AllTrim( SubStr( cMemo , nPos1 ) )//Salva a partir da #
					Else
						cTexto := AllTrim( cMemo )//Considera todo o memo
						cMemo  := " "//Zera o Memo
						lEof   := .T.//Encerra a impressão
					Endif
				Else //Caso nao exista # imprime todo o campo Memo
					//IMPRIME TEXTO
					fImpDoc856( AllTrim( cMemo ) )
					lEof := .T.
					Exit
				Endif


				//IMPRIME TITULO
				If !Empty( cTitulo )
					lCabec856 := .T.
			   		fImpHea856( cTitulo , , .T. )
					If !Empty( cTexto )
						nTexto		:= 0
						nLinhasMemo	:= MlCount( cTexto , 10 )

						For nLinha := 1 to nLinhasMemo
						    cTextTemp := MemoLine( cTexto , 10 , nLinha )
						    If !Empty( cTextTemp )
						    	nTexto := At( "@" , AllTrim( cTextTemp ) )
						    	Exit
						    Endif
						Next Linha

						If nTexto == 0
							OLE_ExecuteMacro( oWord , "SomaLinha" )
							OLE_ExecuteMacro( oWord , "SomaLinha" )
						Endif
					Endif
				Endif

				lPrint := .t.
				lPrin2 := .t.
				fImpDoc856( Alltrim( cTexto ) )

			Endif

			fRegua( nLenMemo , @nPerMemo , Len( cMemo ) ) //Incrementa Regua

		End

		//Verifica se há termo vinculado ao Laudo
		cTxtMemo := " "
		dbSelectArea( "TMZ" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "TMZ" ) + TO0->TO0_TERMO )
			cTxtMemo := TMZ->TMZ_DESCRI
		EndIf

		aUsuSX5 := {}
		aAdd( aUsuSX5 , { "1" , STR0047 } ) //"Médico(a) do Trabalho"
		aAdd( aUsuSX5 , { "2" , STR0048 } ) //"Enfermeiro(a) do Trabalho"
		aAdd( aUsuSX5 , { "3" , STR0049 } ) //"Auxiliar de Enfermagem do Trabalho"
		aAdd( aUsuSX5 , { "4" , STR0050 } ) //"Engenheiro(a) de Segurança do Trabalho"
		aAdd( aUsuSX5 , { "5" , STR0051 } ) //"Técnico(a) de Segurança do Trabalho"
		aAdd( aUsuSX5 , { "6" , STR0052 } )  //"Médico(a)"
		aAdd( aUsuSX5 , { "7" , STR0053 } ) //"Enfermeiro(a)"
		aAdd( aUsuSX5 , { "8" , STR0054 } ) //"Auxiliar de Enfermagem"
		aAdd( aUsuSX5 , { "9" , STR0055 } ) //"Técnico(a) de Enfermagem do Trabalho"
		aAdd( aUsuSX5 , { "A" , STR0056 } ) //"Fisioterapeuta"

		aRespRel := { TO0->TO0_CODUSU , Mv_par02 }

		//Imprime as informações do Responsável e Coordenador
		nInfoDoc := 0
		cMemoUsu := ""
		For nResp := 1 To Len( aRespRel )
			dbSelectArea( "TMK" )
			dbSetOrder( 1 )
			If dbSeek( xFilial( "TMK" ) + aRespRel[ nResp ] ) .And. ;
					( nResp == 1 .Or. aRespRel[ 1 ] <> aRespRel[ nResp ] )
				cMemoUsu += TMK->TMK_NOMUSU + "@#$" + "#*"
				nInfoDoc++
				nPosUs := aScan( aUsuSX5 , { | x | x[ 1 ] == TMK->TMK_INDFUN } )
				If nPosUs > 0
					cMemoUsu += aUsuSX5[ nPosUs , 2 ] + "#*"
				Else
					dbSelectArea( "SX5" )
					dbSetOrder( 1 )
					If dbSeek( xFilial( "SX5" ) + "P1" + TMK->TMK_INDFUN )
						cMemoUsu += X5Descri() + "#*"
					Else
						cMemoUsu += " " + "#*"
					EndIf
				Endif
				nInfoDoc++
				If !Empty( TMK->TMK_NUMENT )
					cMemoUsu += If( Empty( TMK->TMK_ENTCLA ) , "" , Alltrim( TMK->TMK_ENTCLA ) + ": " ) + TMK->TMK_NUMENT + "#*"
					nInfoDoc++
				Endif
				If !Empty( TMK->TMK_REGMTB )
					cMemoUsu += STR0057 + TMK->TMK_REGMTB + "#*" //"Reg. DSST/MTE.: "
					nInfoDoc++
				Endif
			Endif
		Next nResp

		//Realiza a impressão através da macro Table_Responsavel
		If nInfoDoc > 0
			OLE_ExecuteMacro( oWord , "Somalinha" )
			OLE_ExecuteMacro( oWord , "Somalinha" )
			OLE_SetDocumentVar( oWord , "Tabela" , cMemoUsu )
			OLE_SetDocumentVar( oWord , "Linhas" , nInfoDoc )
			OLE_ExecuteMacro( oWord , "Table_Responsavel" )
		Endif

		//Zera variáveis ocultas
		OLE_SetDocumentVar( oWord , "Cria_Var"	, Space( 1 ) ) //Limpa campo oculto do documento
		OLE_SetDocumentVar( oWord , "Tabela"	, Space( 1 ) ) //Limpa campo oculto do documento
		OLE_SetDocumentVar( oWord , "Tabela2"	, Space( 1 ) ) //Limpa campo oculto do documento
		OLE_SetDocumentVar( oWord , "Linhas"	, Space( 1 ) ) //Limpa campo oculto do documento

   		//Realiza a criação do índice
   		If lCriaIndice
			OLE_ExecuteMacro( oWord , "Cria_Indice" )//"Cria o indice"
		Endif
		OLE_ExecuteMacro( oWord , "Atualiza" ) //Executa a macro que atualiza os campos do documento

		If lCriaIndice
			OLE_ExecuteMacro( oWord , "AtualizaIndice" )//"Atualiza Indice"
		Endif
		OLE_ExecuteMacro( oWord , "Begin_Text" ) //Posiciona o cursor no inicio do documento

		cRootPath := GetPvProfString( GetEnvServer() , "RootPath" , "ERROR" , GetADV97() )
		cRootPath := If( Right( cRootPath , 1 ) == cBarraSRV , SubStr( cRootPath , 1 , Len( cRootPath ) - 1 ) , cRootPath )

		If lImpress //Impressao via Impressora
			OLE_SetProperty( oWord , "208" , .F. )
			OLE_PrintFile( oWord , "ALL" , , , 1 )
		Else //Impressao na Tela(Arquivo)
			OLE_SetProperty( oWord , oleWdVisible , .T. )
			OLE_ExecuteMacro( oWord , "Maximiza_Tela" )
			If !lMdtUnix //Se for windows
				If fDiretorio( cRootPath + cBarraSRV + "SPOOL" + cBarraSRV )
					OLE_SaveAsFile( oWord , cRootPath + cBarraSRV + "SPOOL" + cBarraSRV + cArqSaida , , , .F. , oleWdFormatDocument )
				ElseIf fDiretorio( cPathEst )
					OLE_SaveAsFile( oWord , cPathEst + cArqSaida , , , .F. , oleWdFormatDocument )
				Else
					OLE_SaveAsFile( oWord , cPathEst + cArqSaida , , , .F. , oleWdFormatDocument )
				Endif
			Endif
			MsgInfo( STR0058 ) //"Alterne para o programa do Ms-Word para visualizar o documento ou clique no botao para fechar."
		EndIf

		OLE_CloseFile( oWord ) //Fecha o documento
		OLE_CloseLink( oWord ) //Fecha o documento
	Else
		MsgStop( STR0059 + Chr( 10 ) + STR0060 , STR0061 ) //"O arquivo ergonomia.dot não foi encontrado no servidor."###"Verificar o parâmetro 'MV_DIRACA'."###"ATENÇÃO"
	EndIf

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fQtdFunRis
Contabiliza a quantidade de funcionarios expostos a riscos

@return Numerico Quantidade de Funcionários Expostos a Riscos

@sample fQtdFunRis()

@author Jackson Machado
@since 29/09/2014
/*/
//---------------------------------------------------------------------
Static Function fQtdFunRis()

	//Variáveis de Controle
	Local nFunc		:= 0 , nInd  := 1, n
	Local cCusto	:= "", cFunc := "" , cTar := ""
	Local cMat		:= " " , cSeek := " " , cCond := ""
	Local lRet		:= .T.
	Local lAll		:= .F.
	Local aCateg	:= {}
	Local aFunc		:= {}

	//Define as categorias a serem filtradas
	aCateg := fSubCateg( cFiltroF )
	For n := 1 to Len( aCateg )
		cCond += " AND RA_CATFUNC <> " + ValToSQL( aCateg[n] )
	Next

	//Se achar Centro de Custo/Função/Tarefa * considera todos
	dbSelectArea( "TN0" )
	dbSetOrder( 5 )
	If dbSeek( xFilial( "TN0" ) + PadR( "*" , Len( TN0_CC ) ) + PadR( "*" , Len( TN0_CODFUN ) ) + PadR( "*" , Len( TN0_CODTAR ) ) )
		While TN0->( !Eof() ) .And. PadR( "*" , Len( TN0_CC ) ) == TN0->TN0_CC .And. ;
				PadR( "*" , Len( TN0_CODFUN ) ) == TN0->TN0_CODFUN .And. ;
				PadR( "*" , Len( TN0_CODTAR ) ) == TN0->TN0_CODTAR

			dbSelectArea( "TMA" )
			dbSetOrder( 1 )
			dbSeek( xFilial( "TMA" ) + TN0->TN0_AGENTE )

			If TMA->TMA_GRISCO == "4"
				lAll := .T.
				Exit
			EndIf
			TN0->( dbSkip() )
		End
	EndIf

	If lAll
		//Faz uma Query para buscar todos os Funcionários
		cTabSRA := RetSqlName( "SRA" )
		cFilSRA := xFilial( "SRA" )
		cAliasSRA := GetNextAlias()

		cQuery := "SELECT COUNT(*) AS TOTAL "
		cQuery += "FROM " + cTabSRA + " "
		cQuery += "WHERE (RA_SITFOLH != 'D' OR RA_DEMISSA > " + ValToSQL( dDeLaudo ) + ")"
		cQuery += "AND RA_ADMISSA < " + ValToSQL( dAteLaudo ) + " AND RA_FILIAL = " + ValToSQL( cFilSRA ) + " AND D_E_L_E_T_ != '*'"
		If !Empty( cCond )
			cQuery += cCond
		Endif
		cQuery := ChangeQuery( cQuery )

		MPSysOpenQuery( cQuery , cAliasSRA )
		dbSelectArea( cAliasSRA )
		dbGoTop()
		nFunc := ( cAliasSRA )->TOTAL
		( cAliasSRA )->( dbCloseArea() )
	Else
		//Caso não ache um risco 'Todos', percorre todos os Riscos
		dbSelectArea( "TN0" )
		dbSetOrder( 1 )
		dbSeek( xFilial( "TN0" ) )
		While TN0->( !Eof() ) .And. xFilial( "TN0" ) == TN0->TN0_FILIAL

			dbSelectArea( "TMA" )
			dbSetOrder( 1 )
			dbSeek( xFilial( "TMA" ) + TN0->TN0_AGENTE )

			//Valida se o Mapa Risco é igual a CIPA
			If TN0->TN0_MAPRIS == "1" .Or. TMA->TMA_GRISCO <> "4"
				dbSelectArea("TN0")
				dbSkip()
				Loop
			Endif

			//Verifiac se o risco é considerado no Laudo
			dbSelectArea( "TO1" )
			dbSetOrder( 1 )
			dbGoTop()
			If !dbSeek( xFilial( "TO1" ) + mv_par01 + TN0->TN0_NUMRIS )
				dbSelectArea( "TN0" )
				dbSkip()
				Loop
			EndIf

			//Realiza a Busca pela Chave = Centro de Custo + Função + Tarefa
			dbSelectArea( "TN0" )
			cCusto	:= TN0->TN0_CC
			cFunc	:= TN0->TN0_CODFUN
			cTar	:= TN0->TN0_CODTAR

			If Alltrim( cCusto ) == "*"
				If Alltrim( cFunc ) == "*"
					If Alltrim( cTar ) == "*"
						//Caso caia na condição de 'Todos', zera a quantidade
						nFunc := 0
						Exit
					Else
						//Caso tenha uma tarefa específica, busca todos os funcionários da Tarefa
						dbSelectArea( "TN6" )
						dbSetOrder( 01 )
						dbSeek( xFilial( "TN6" ) + cTar )//Verifica quantidade da tarefa
						While TN6->( !Eof() ) .And. xFilial( "TN6" ) == TN6->TN6_FILIAL .And. ;
								TN6->TN6_CODTAR == cTar
							dbSelectArea( "SRA" )
							dbSetOrder( 01 )
							If dbSeek( xFilial( "SRA" ) + TN6->TN6_MAT )  .And. ;
									TN6->TN6_DTINIC <= dDatabase          .And. ;
									( TN6->TN6_DTTERM >= dDatabase .Or. Empty( TN6->TN6_DTTERM ) )//Valida as datas de início e fim

								//Verifica se não esta demitido nem admitido posterior ao laudo e se está no array
								If !fConsistFunc()
									dbSelectArea( "SRA" )
									dbSkip()
									Loop
								Endif
								If aScan( aFunc , { | x | Trim( Upper( x[ 1 ] ) ) == Trim( Upper( SRA->RA_MAT ) ) } ) == 0 .And. ;
										!( SRA->RA_CATFUNC $ cFiltroF )
									aAdd( aFunc , { SRA->RA_MAT } )
								EndIf
							EndIf
							dbSelectArea( "TN6" )
							dbSkip()
							Loop
						End

						lRet := .F.
						//Volta ao loop principal
						dbSelectArea( "TN0" )
						dbSkip()
						Loop
					EndIf
				Else
					lRet 	:= .T.
					nInd	:= 7 //Ordenar pelo Codigo da Funcao
					cSeek	:= cFunc
					cField	:= "SRA->RA_CODFUNC"
				EndIf
			Else
				lRet		:= .T.
				nInd		:= 2 //Ordenar pelo Codigo do Centro de Custo
				cSeek 		:= cCusto
				cField		:= "SRA->RA_CC"
			EndIf

			If lRet
				//Percorre SRA com chave (CC ou Função)
				dbSelectArea( "SRA" )
				dbSetOrder( nInd )
				dbSeek( xFilial( "SRA" ) + cSeek )
				While SRA->( !Eof() ) .And. xFilial( "SRA" ) == SRA->RA_FILIAL .And. &cField == cSeek
					//Verifica se não esta demitido nem admitido posterior ao laudo
					If !fConsistFunc()
						dbSelectArea( "SRA" )
						dbSkip()
						Loop
					Endif

					lFunc := .F.
					//Se estiver por Função
					If nInd == 7
						If Alltrim( cTar ) == "*"//Se todas as Tarefas
							If aScan( aFunc , { | x | Trim( Upper( x[ 1 ] ) ) == Trim( Upper( SRA->RA_MAT ) ) } ) == 0
								aAdd( aFunc , { SRA->RA_MAT } )
							EndIf
							//Volta ao Loop da SRA
							dbSelectArea("SRA")
							dbSkip()
							Loop
						Else
							lFunc := .T.//Indice que deve verificar tarefa
						EndIf
					Else//Se for por CC
						If SRA->RA_CODFUNC == cFunc .or. Alltrim( cFunc ) == "*"
							If Alltrim( cTar ) == "*"
								If aScan( aFunc , { | x | Trim( Upper( x[ 1 ] ) ) == Trim( Upper( SRA->RA_MAT ) ) } ) == 0
									aAdd( aFunc , { SRA->RA_MAT } )
								EndIf
								dbSelectArea( "SRA" )//Volta ao Loop da SRA
								dbSkip()
								Loop
							Else
								lFunc := .T.//Indice que deve verificar Tarefa
							EndIf
						EndIf
					EndIf

					//Verifica por Tarefa
					If lFunc
						dbSelectArea( "TN6" )
						dbSetOrder( 01 )
						dbSeek( xFilial( "TN6" ) + cTar + SRA->RA_MAT )
						While TN6->( !Eof() ) .And. xFilial( "TN6" ) == TN6->TN6_FILIAL .And. ;
								TN6->TN6_MAT == SRA->RA_MAT .and. TN6->TN6_CODTAR == cTar

							If TN6->TN6_DTINIC <= dDatabase .And. ;
								( TN6->TN6_DTTERM >= dDatabase .Or. Empty( TN6->TN6_DTTERM ) )//Valida as datas de início e fim
								If aScan( aFunc , { | x | Trim( Upper( x[ 1 ] ) ) == Trim( Upper( SRA->RA_MAT ) ) } ) == 0
									aAdd( aFunc , { SRA->RA_MAT } )
								EndIf
								Exit//Volta ao loop da SRA
							EndIf

							dbSelectArea( "TN6" )
							dbSkip()
							Loop
						End
					EndIf

					dbSelectArea( "SRA" )
					dbSkip()
					Loop
				End
			EndIf

			dbSelectArea( "TN0" )
			dbSkip()
			Loop
		End

		nFunc := Len( aFunc )
	EndIf

Return nFunc
//---------------------------------------------------------------------
/*/{Protheus.doc} fSubCateg
Carrega no array os tipos de categoria do funcionario

@return aCateg Array Array contendo os tipos de categorias

@param cCateg Caracter Indica o Combo a ser considerado

@sample fSubCateg( "A,B,C" )

@author Jackson Machado
@since 29/09/2014
/*/
//---------------------------------------------------------------------
Static Function fSubCateg( cCateg )

	Local aCateg := {}
	Local nPos

	If !Empty( cCateg )
		If Substr( cCateg , 1 , 1 ) == ","
			cCateg := Substr( cCateg , 2 )
		Endif
		If Substr( cCateg , Len( cCateg ) , 1 ) != ","
			cCateg += ","
		Endif
		cCateg := AllTrim( cCateg )

		While .T.
			nPos := At( "," , cCateg )
			If nPos > 0
				If !Empty( SubStr( cCateg , 1 , nPos - 1 ) ) .And. Substr( cCateg , 1 , nPos - 1 ) != ","
					aAdd( aCateg , SubStr( cCateg , 1 , nPos - 1 ) )
				Endif
				cCateg := SubStr( cCateg , nPos + 1 )
			Else
				Exit
			Endif
		End
	Endif

Return aCateg
//---------------------------------------------------------------------
/*/{Protheus.doc} fRegua
Processa regua

@return Nil

@param nLenMemo Numerico Tamanho Anterior do Memo
@param nPerMemo Numerico Percentual de Incremento
@param nLenAtual Numerico Tamanho Atual do Memo

@sample fRegua( nLenMemo , @nPerMemo , Len( cMemo ) )

@author Jackson Machado
@since 29/09/2014
/*/
//---------------------------------------------------------------------
Static Function fRegua( nLenMemo, nPerMemo, nLenAtual )

	Local nLenOld := ( 100 - nPerMemo ) * ( nLenMemo / 100 ) //Calcula Len anterior
	Local nDiff := nLenOld - nLenAtual
	Local nFor , nPercent

	If nDiff > 0
		//Porcentagem que processou neste Loop
		nPercent := Round( ( 100 / nLenMemo ) * nDiff , 0 )
		//Porcentagem processada
		nPerMemo += nPercent
		If nPercent >= 1 .and. nPercent <= 100
			For nFor := 1 To nPercent
				IncRegua()
			Next nFor
		Endif
	Endif

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fConsistFunc
Realiza a consistência padrão do funcionário

@return lRet Lógico Retorna verdadeiro quando funcionário pode ser utilizado

@sample fRegua( nLenMemo , @nPerMemo , Len( cMemo ) )

@author Jackson Machado
@since 29/09/2014
/*/
//---------------------------------------------------------------------
Static Function fConsistFunc()
	Local lAfast := .F.
	Local lRet   := .T.

	//Afastados anteriores ao período vigente do laudo e que continuam afastados
	If FindFunction( "MDTChkSR8" )
		lAfast := MDTChkSR8( "SR8" , 1 , ;//Na Ver12 alterar verificação para MDTChkSR8
								xFilial( "SR8" ) + SRA->RA_MAT , ;
								"xFilial( 'SR8' ) + SRA->RA_MAT == SR8->R8_FILIAL + SR8->R8_MAT" , ;
								TO0->TO0_DTINIC , ;
								dAteLaudo )
	Else
		dbSelectArea( "SR8" )
		dbSetOrder( 1 )  //R8_FILIAL+R8_MAT+DTOS(R8_DATAINI)+R8_TIPO
		dbSeek( xFilial("SR8") + SRA->RA_MAT )
		While !Eof() .and. xFilial( "SR8" ) + SRA->RA_MAT == SR8->R8_FILIAL+SR8->R8_MAT
			If SR8->R8_DATAINI <= TO0->TO0_DTINIC .And. ( SR8->R8_DATAFIM >= dAteLaudo .Or. Empty( SR8->R8_DATAFIM ) )
				lAfast := .T.
				Exit
			Endif
			dbSelectArea( "SR8" )
			dbSkip()
		End
	EndIf

	If lAfast
		lRet   := .F.
	EndIf
	//Transferidos/Demitidos antes da vigência
	If ( SRA->RA_SITFOLH == "D/T" ) .Or. ;
		( !Empty( SRA->RA_DEMISSA ) .And. SRA->RA_DEMISSA <= dDeLaudo )
		lRet   := .F.
	EndIf
	If SRA->RA_ADMISSA > dAteLaudo
		lRet   := .F.
	EndIf
	If SRA->RA_CATFUNC $ cFiltroF //Indica as Categorias Funcionais que nao aparecerao no PPRA
		lRet   := .F.
	Endif

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fDiretorio
Verifica se o diretorio existe.

@return lDir Lógico Retorna verdadeiro se o diretório existe

@param cCaminho Caracter Caminho a ser verificado

@sample fDiretorio( 'C:\' )

@author Jackson Machado
@since 29/09/2014
/*/
//---------------------------------------------------------------------
Static Function fDiretorio( cCaminho )

	Local lDir		:= .F.
	Local cBarras	:= If( IsSrvUnix() , "/" , "\" )
	Local cBarrad	:= If( IsSrvUnix() , "//" , "\\" )

	//Valida o caminho conforme servidor
	If !Empty( cCaminho ) .And. !( cBarrad $ cCaminho )
		cCaminho := AllTrim( cCaminho )
		If Right( cCaminho , 1 ) == cBarras
			cCaminho := SubStr( cCaminho , 1 , Len( cCaminho ) - 1 )
		Endif
		lDir :=( aScan( Directory( cCaminho , "D" ) , { | _Vet | "D" $ _Vet[ 5 ] } ) > 0 )
	EndIf

Return lDir
//---------------------------------------------------------------------
/*/{Protheus.doc} fImpDoc856
Realiza a impressão do conteúdo do Texto

@return Sempre verdadeiro

@param _cTexto Caracter Texto a ser impresso (Obrigatório)
@param lSaltaLin Lógico Indica se deve pular linha
@param lEsquerda Lógico Indica se deve alinhar a esquerda
@param lBackSpc Lógico Indica se deve executar um BackSpace
@param nMaisCol Numérico Identifica se deve adicionar mais linhas a impressão
@param nTermLin Numérico Identifica o termino da linha

@sample fImpDoc856( 'TEXTO' )

@author Jackson Machado
@since 29/09/2014
/*/
//---------------------------------------------------------------------
Static Function fImpDoc856(_cTexto,lSaltaLin,lEsquerda,lBackSpc,nMaisCol,nTermLin)

	//Define variáveis padrões para impressão
	Local nArroba,LinhaCor
	Local nPosTemp
	Local nPosTxt	:= 0
	Local cTitExe
	Local cTextoNew	:= _cTexto
	Local cTxtMemo	:= _cTexto
	Local cCNS 		:= " "
	Local lTexto	:= .T.

	Private lFirst		:= .T.

	Default lEsquerda	:= .F.  //Alinhar à esquerda
	Default lBackSpc 	:= .F.
	Default nMaisCol	:= 0    //Adiciona colunas para impressão
	Default nTermLin	:= If( mv_par03 == 1 , 120 , 90  ) // Delimita o termino da linha

	//Imprime Texto
	lJumpCab := .f. //Somalinha do Titulo de Relatorio
	While lTexto //Define que enquanto houver texto realiza a impressão
		//Verifica impressão de Atalho
		nArroba := At( "@" , cTxtMemo )
		If nArroba > 1//Caso definição de atalho (@) não esteja contida na primeira expressão
			cTextoNew	:= Alltrim( SubStr( cTxtMemo , 1 , nArroba - 1 ) )//Considera como impressão o atalho do início até antes do @
			cTxtMemo	:= Alltrim( SubStr( cTxtMemo , nArroba ) )//Salva a partir do @
			fImpDoc856( Alltrim( cTextoNew ) )//Realiza a impressão do Atalho
			Loop
		ElseIf nArroba == 1 //Existe @//Caso definição de atalho (@) contida na primeira expressão
			cTxtMemo 	:= Alltrim( SubStr( cTxtMemo , nArroba + 1 ) )//Considera o memo após a @
			nArroba  	:= At( "@" , cTxtMemo )//Localiza próximo atalho (@)
			cTitExe  	:= Alltrim( SubStr( cTxtMemo , 1 , nArroba - 1 ) )//Considera como impressão o atalho do início até antes do @
			fProcTexto( cTitExe )//Processa o texto novamente
			lCabec856	:= .F.
			cTxtMemo	:= Alltrim( SubStr( cTxtMemo , nArroba + 1 ) )//Salva a partir do @

			nArroba		:= At( "@" , cTxtMemo )//Verifica se há mais atalhos a serem impressos
			If nArroba > 0// Caso haja mais atalhos
				cTextoNew := Alltrim( SubStr( cTxtMemo , 1 , nArroba - 1 ) )//Considera o atalho para impressão
				cTxtMemo  := Alltrim( SubStr( cTxtMemo , nArroba ) )//Salva a partir do @
				fImpDoc856( Alltrim( cTextoNew ) )//Realiza a impressão do Atalho
				Loop
			Endif
		Endif

		If ( nPosTxt := At( Chr( 13 ) + Chr( 10 ) , cTxtMemo ) ) == 0//Verifica se não há mais quebras
			lTexto		:= .F.//Encerra a impressão
			cTextoNew	:= Alltrim( cTxtMemo )//Zera o memo
		Else
			cTextoNew	:= Alltrim( SubStr( cTxtMemo , 1 , nPosTxt - 1 ) )//Considera como impressão o atalho do início até antes da quebra
			cTxtMemo	:= Alltrim( SubStr( cTxtMemo , nPosTxt + 2 ) )//Salva a partir da quebra
			If Len( cTxtMemo ) == 0//Caso chegue ao final do memo
				lTexto := .F.//Encerra a impressão
			Endif
		Endif

		//Zera o Texto
		If Empty( cTextoNew )
			cTextoNew := " "
		Endif

		If mv_par03 == 1 //Impressão Padrão
			nAddLi := 0 + nMaisCol//Verifica se deve considerar mais colunas para impressão
			//Caso necessite identar indica como inicial em 5
			If lIdentar
				nAddLi := 5
			Endif
			lPrimeiro := .t.
			nLinhasMemo := MlCount( cTextoNew , nTermLin )

			//Percorre todas as linhas do memo
			For LinhaCor := 1 to nLinhasMemo
			    If lPrimeiro
					@ Li,005 + nAddLi PSay ( MemoLine( cTextoNew , nTermLin , LinhaCor ) )
					lPrimeiro := .F.
				Else
					@ Li,000 + nAddLi PSay ( MemoLine( cTextoNew , nTermLin , LinhaCor ) )
				EndIf
				Somalinha()
			Next LinhaCor
		ElseIf mv_par03 == 3 .And. cTextoNew <> " "//Impressão Word e texto não vazio
			//Inicia variável de texto
			cVar1 := "cTXT" + Strzero( nVar1 , 6 )
			OLE_SetDocumentVar( oWord , "Cria_Var" , cVar1 )
			nVar1++

			//Realizar salto de linha conforme necessário
			If lPrint .And. !lFirst
				OLE_ExecuteMacro( oWord , "Somalinha" )
				lPrint := .F.
			Endif
			If lPrin2 .And. !lFirst
				OLE_ExecuteMacro( oWord , "Somalinha" )
			Endif

			If lSaltaLin
				OLE_ExecuteMacro( oWord , "Somalinha" )
			Endif

			//Identa caso necessário
			If lIdentar .and. !lFirst
				OLE_ExecuteMacro( oWord , "Identar" )
			Endif

			OLE_ExecuteMacro( oWord , "Cria_Txt2" )

			//Verifica se há algum estilo a ser aplicado no Texto
			If ( "{" $ cTextoNew ) .And.  ( "}" $ cTextoNew )
				nPosTemp	:= At( "}" , cTextoNew )
				cCNS		:= Substr( cTextoNew , 1 , nPosTemp )
				cTextoNew	:= Substr( cTextoNew , nPosTemp + 1 )
			Endif

			//Aplicação de Negrito
			If ( "N" $ Upper( cCNS ) ) //N=Negrito
				OLE_ExecuteMacro( oWord , "Com_Negrito" )
			Else
				OLE_ExecuteMacro( oWord , "Sem_Negrito" )
			Endif

			//Aplicação de Centralizado
			If ( "C" $ Upper( cCNS ) ) //C=Centralizar
				OLE_ExecuteMacro( oWord , "Centralizar" )
			Else
				OLE_ExecuteMacro( oWord , "Justificar" )
			Endif

			//Aplicação de Sublinhado
			If ( "S" $ Upper( cCNS ) ) //S=Sublinhar
				OLE_ExecuteMacro( oWord , "Com_Sublinhar" )
			Else
				OLE_ExecuteMacro( oWord , "Sem_Sublinhar" )
			Endif

			//Realiza BackSpace caso necessário
			If lBackSpc .And. lFirst
				OLE_ExecuteMacro( oWord , "BackSpace" )
			Endif

			lPrin2 := .T.
			lFirst := .F.

			//Mantem alinhamento na esquerda
			If lEsquerda
				OLE_ExecuteMacro( oWord , "Alinhar_Esquerda" )
			Endif

			OLE_SetDocumentVar( oWord , cVar1 , cTextoNew )
		ElseIf mv_par03 == 2//Impressão Padrão
			nAddLi		:= 0 + nMaisCol//Verifica se deve considerar mais colunas para impressão
			nDifCarac	:= 0
			//Caso necessite identar indica como inicial em 150
			If lIdentar
				nAddLi		:= 150
				nDifCarac	:= 7
			Endif

			//Percorre todas as linhas do memo
			lPrimeiro	:= .T.
			nLinhasMemo	:= MlCount( cTextoNew , nTermLin - nDifCarac )
			For LinhaCor := 1 to nLinhasMemo
				Somalinha()
				If lPrimeiro
			    	oPrintErg:Say( lin , 300 + nAddLi , MemoLine( cTextoNew , nTermLin - nDifCarac , LinhaCor ) , oFont10 )
					lPrimeiro := .f.
				Else
					oPrintErg:Say( lin , 150 + nAddLi , MemoLine( cTextoNew , nTermLin - nDifCarac , LinhaCor ) , oFont10 )
				EndIf
			Next LinhaCor
		Endif
	End
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fImpHea856
Realiza a impressão do título do Texto

@return Sempre verdadeiro

@param _cTit Caracter Texto a ser impresso (Obrigatório)
@param lJump Lógico Indica se deve pular linha
@param lIndice Lógico Indica se deve estar no índice

@sample fImpHea856( 'TEXTO' )

@author Jackson Machado
@since 29/09/2014
/*/
//---------------------------------------------------------------------
Static Function fImpHea856( _cTit , lJump , lIndice )

	//Define variáveis para impressão do cabeçalho
	Local nPosTemp
	Local nLinhasMemo
	Local LinhaCor
	Local _cTitulo := _cTit
	Local cCNS := " "
	Local lJumper

	Default lJump	:= .F.
	Default lIndice	:= .F.

	lJumper := If( !lJump , lJumpCab , lJump )

	If mv_par03 == 1
		//Verifica se há algum estilo a ser aplicado no Texto
		If ( "{" $ _cTitulo ) .And.  ( "}" $ _cTitulo )
			nPosTemp	:= At( "}" , _cTitulo )
			cCNS		:= SubStr( _cTitulo , 1 , nPosTemp )
			_cTitulo	:= SubStr( _cTitulo , nPosTemp + 1 )
		Endif

		//Realiza a impressão do Título
		Somalinha()
		@ Li , 000 PSay _cTitulo
		SomaLinha()
	ElseIf mv_par03 == 2
		//Verifica se há algum estilo a ser aplicado no Texto
		If ( "{" $ _cTitulo ) .And.  ( "}" $ _cTitulo )
			nPosTemp := At( "}" , _cTitulo )
			cCNS     := SubStr( _cTitulo , 1 , nPosTemp )
			_cTitulo := SubStr( _cTitulo , nPosTemp + 1 )
		Endif

		//Realiza um for para impressão do título
		nLinhasMemo := MlCount( _cTitulo , 90 )
		For LinhaCor := 1 to nLinhasMemo
			SomaLinha()
			nColImp := 150
			cTxtImp := AllTrim( MemoLine( _cTitulo , 90 , LinhaCor ) )
			//Aplicação de Centralizado
			If ( "C" $ Upper( cCNS ) ) //C=Centralizar
				nDiff := Round( ( 90 - Len( cTxtImp ) ) / 2 , 0 )
				If nDiff > 0
					nColImp := 150 + ( nDiff * 23.3 )
				Endif
			Endif
			//Aplicação de Negrito
			If ( "N" $ Upper( cCNS ) ) //N=Negrito
				If ( "S" $ Upper( cCNS ) ) //S=Sublinhar
					oPrintErg:Say( lin , nColImp , cTxtImp , oFont12bs )
				Else
					oPrintErg:Say( lin , nColImp , cTxtImp , oFont12b )
				Endif
			Else
				//Aplicação de Sublinhado
				If ( "S" $ Upper( cCNS ) ) //S=Sublinhar
					oPrintErg:Say( lin , nColImp , cTxtImp , oFont12s )
				Else
					oPrintErg:Say( lin , nColImp , cTxtImp , oFont12 )
				Endif
			Endif
		Next LinhaCor
	Else
		lFirst := .f.////Somalinha do texto

		//Cria variável para impressão
		cVar := "cTIT" + StrZero( nVar , 6 )
		nVar++
		OLE_SetDocumentVar( oWord , "Cria_Var" , cVar )

		//Salta página caso necessário
		If !lJumper
			OLE_ExecuteMacro( oWord , "Somalinha" )
		Endif
		lJumpCab := .F.//Somalinha do Titulo de Relatorio
		OLE_ExecuteMacro( oWord , "Somalinha" )

		//Verifica se há algum estilo a ser aplicado no Texto
		If ( "{" $ _cTitulo ) .And. ( "}" $ _cTitulo )
			nPosTemp := At( "}" , _cTitulo )
			cCNS     := SubStr( _cTitulo , 1 , nPosTemp )
			_cTitulo := SubStr( _cTitulo , nPosTemp + 1 )
		Endif

		//Verifica se deve ser consideerado em algum índice e define corretamente
		//Caso não, apenas realiza a impressão do titulo
		If lIndice
			If ( "1" $ Upper( cCNS ) )//Titulo 1
				lCriaIndice := .T.
				OLE_ExecuteMacro( oWord , "Cria_TituloUsuario" )
			ElseIf( "2" $ Upper( cCNS ) )//2=Titulo 2
				lCriaIndice := .T.
				OLE_ExecuteMacro( oWord , "Cria_TituloUsuario2" )
			ElseIf( "3" $ Upper( cCNS ) )//2=Titulo 3
				lCriaIndice := .T.
				OLE_ExecuteMacro( oWord , "Cria_TituloUsuario3" )
			ElseIf( "4" $ Upper( cCNS ) )//2=Titulo 4
				lCriaIndice := .T.
				OLE_ExecuteMacro( oWord , "Cria_TituloUsuario4" )
		    Else
		    	OLE_ExecuteMacro( oWord , "Cria_Titulo" )
		    Endif
		Else
			OLE_ExecuteMacro( oWord , "Cria_Titulo" )
		EndIf

		//Aplicação de Negrito
		If ( "N" $ Upper( cCNS ) ) //N=Negrito
			OLE_ExecuteMacro( oWord , "Com_Negrito" )
		Else
			OLE_ExecuteMacro( oWord , "Sem_Negrito" )
		Endif

		//Aplicação de Centralizado
		If ( "C" $ Upper( cCNS ) ) //C=Centralizar
			OLE_ExecuteMacro( oWord , "Centralizar" )
		Else
			OLE_ExecuteMacro( oWord , "Justificar" )
		Endif

		//Aplicação de Sublinhado
		If ( "S" $ Upper( cCNS ) ) //S=Sublinhar
			OLE_ExecuteMacro( oWord , "Com_Sublinhar" )
		Else
			OLE_ExecuteMacro( oWord , "Sem_Sublinhar" )
		Endif

		//Define o documento
		OLE_SetDocumentVar( oWord , cVar , _cTitulo )

		//Caso tenha indice salta pagina
		If lIndice
			Somalinha()
		Endif
	Endif

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fProcTexto
Processa o conteúdo do Texto

@return Sempre verdadeiro

@param _cTexto Caracter Texto a ser impresso (Obrigatório)

@sample fProcTexto( 'TEXTO' )

@author Jackson Machado
@since 29/09/2014
/*/
//---------------------------------------------------------------------
Static Function fProcTexto(_cTitExe)

	//Define variáveis de controle
	Local nPos1, nFor, nPosPE
	Local nTipo 	:= 1//Indica se é um atalho (1), imagem (2) ou arquivo (3)
	Local cTitTemp
	Local cTitExe 	:= _cTitExe
	Local aRetPE

	cTitTemp := _cTitExe

	//Verifica se há alguma imagem definida no Texto
	nPos1    := At( "!" , cTitTemp )
	If nPos1 > 0
		cTitTemp := Alltrim( SubStr( cTitTemp , nPos1 + 1 ) )
		nPos1    := At( "!" , cTitTemp )
		If nPos1 > 0
			cTitTemp := SubStr( cTitTemp , 1 , nPos1 - 1 )
			nTipo := 2
		Endif
	Endif

	//Verifica se há algum arquivo definido no texto
	If nTipo == 1
		cTitTemp := _cTitExe
		nPos1    := At( "%" , cTitTemp )
		If nPos1 > 0
			cTitTemp := AllTrim( SubStr( cTitTemp , nPos1 + 1 ) )
			nPos1    := At( "%" , cTitTemp )
			If nPos1 > 0
				cTitTemp := SubStr( cTitTemp , 1 , nPos1 - 1 )
				nTipo := 3
			Endif
		Endif
	Endif

	Begin Sequence
		If ExistBlock( 'MDTR8561' ) //Ponto de Entrada padrão para executar atalhos Customizados
			aRetPE := ExecBlock('MDTR8561',.F.,.F., {mv_par04, nModeloImp, cTitExe} )
			If ValType( aRetPE ) == "A"
				nPosPE := aScan( aRetPE , { | x | Alltrim( x[ 1 ] ) == Alltrim( cTitExe ) .And. Alltrim( cTitExe ) == Alltrim( x[ 1 ] ) } )
				If nPosPE > 0
					&(aRetPE[ nPosPE , 2 ] )
					Break
				Endif
			Endif
		Endif

		//Considera o que deve ser impresso
		If nTipo == 2
			fImagem( cTitTemp )
		ElseIf nTipo == 3
			fArquivo( cTitTemp )
		ElseIf "LOCAIS" $ Upper( cTitExe ) .or. "LOCAL" $ Upper( cTitExe )
			If "QUADRO" $ Upper( cTitExe )
				fLocal( 2 )
			Else
				fLocal( 1 )
			Endif
		ElseIf "RISCO" $ Upper( cTitExe )
			fRisco()
		ElseIf "QUADRO MEDIDA CONTROLE" $ Upper( cTitExe )
			fMedQuadro()
		ElseIf "CONTROLE" $ Upper( cTitExe )
			fControle()
		ElseIf "SESMT" $ Upper( cTitExe )
			fSesmt()
		ElseIf "QUESTIONARIO" $ Upper( cTitExe )
			fQuestionario()
		ElseIf "FUNCIONARIOS X FUNCAO" $ Upper( cTitExe )
			fFuncFun()
		ElseIf "FUNCOES" $ Upper( cTitExe )
			fFuncoes()
		//Específicas de Ergonomia
		ElseIf "FUNCAO X TAREFA" $ Upper( cTitExe )
			fFunTar()
		ElseIf "AGENTE X MEDIDA" $ Upper( cTitExe )
			fAgeMed()
		ElseIf "QUADRO AGENTE" $ Upper( cTitExe )
			fQdrAgente()
		ElseIf "PAGINA"	$ Upper( cTitExe )
			If mv_par03 == 1
				li := 80
				SomaLinha()
			ElseIf mv_par03 == 2
				lin := 9999
				SomaLinha()
			Else
				OLE_ExecuteMacro( oWord , "NewPage" )
				lJumpCab := .T.
			Endif
		ElseIf "NAO-EXPOSTOS" $ Upper(cTitExe)
			fNaoExpostos()
		EndIf
	End Sequence

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fImagem
Funcao para inserir imagem no doc

@return Nil

@param cTitTemp Caracter Texto da Imagem (Obrigatório)

@sample fImagem( 'IMG' )

@author Jackson Machado
@since 29/09/2014
/*/
//---------------------------------------------------------------------
Static Function fImagem( cTitTemp )

	Local nPos
	Local cFileArq	:= ""
	Local cBarraSrv	:= "\"

	If mv_par03 == 3 .And. mv_par06 <> 2 //Se nao for em formato WORD ou parâmetro estiver configurado para não impressão de imagem, nao imprime

		If IsSrvUnix()//Servidor é da família Unix (linux, solaris, free-bsd, hp-ux, etc.)
			cBarraSrv := "/"
		EndIf

		nPos := Rat( cBarraSrv , cTitTemp )
		If nPos > 0
			cFileArq := AllTrim( SubStr( cTitTemp , nPos + 1 ) )
		EndIf

		CpyS2T( AllTrim( cTitTemp ) , cPathEst , .T. )//Copia do Server para o Remote, é necessario

		//Verifica se a imagem foi extraida correta e realiza a impressão
		If File( cPathEst + cFileArq )
			OLE_ExecuteMacro( oWord , "Somalinha" )
			OLE_SetDocumentVar( oWord , "Cria_Var" , cPathEst + cFileArq )
			OLE_ExecuteMacro( oWord , "Insere_img" )
		EndIf
	EndIf

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fArquivo
Funcao para inserir documentos no doc

@return Nil

@param cTitTemp Caracter Texto do Documento (Obrigatório)

@sample fImagem( 'DOC' )

@author Jackson Machado
@since 29/09/2014
/*/
//---------------------------------------------------------------------
Static Function fArquivo( cTitTemp )

	Local nPos
	Local cFileArq	:= ""
	Local cBarraSrv	:= "\"

	If mv_par03 == 3 //Se nao for em formato WORD, nao imprime

		If IsSrvUnix()//Servidor é da família Unix (linux, solaris, free-bsd, hp-ux, etc.)
			cBarraSrv := "/"
		EndIf

		nPos := Rat( cBarraSrv , cTitTemp )
		If nPos > 0
			cFileArq := AllTrim( SubStr( cTitTemp , nPos + 1 ) )
		EndIf

		CpyS2T( AllTrim( cTitTemp ) , cPathEst , .T. )//Copia do Server para o Remote, é necessario

		//Verifica se o arquivo foi salvo correto e realiza a impressão
		If File( cPathEst + cFileArq )
			OLE_ExecuteMacro( oWord , "Somalinha" )
			OLE_SetDocumentVar( oWord , "Cria_Var" , cPathEst + cFileArq )
			OLE_ExecuteMacro( oWord , "Insere_doc" )
		EndIf
	EndIf

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} SomaLinha
Incrementa Linha e Controla Salto de Pagina

@return Nil

@param nLin__ Numerico Quantidade de Linhas para Salto no Relatório Gráfico

@sample SomaLinha( 60 )

@author Jackson Machado
@since 29/09/2014
/*/
//---------------------------------------------------------------------
Static Function SomaLinha( nLin__ , lLinTbl )

	Default lLinTbl := .F.

	//Realiza salto de página
	If mv_par03 == 3
		OLE_ExecuteMacro( oWord , "Somalinha" )//Executa macro de somalinha
	ElseIf mv_par03 == 1
		//Realiza salto padrão
	    Li++
	    If Li > 58
	       Cabec( titulo , cabec1 , cabec2 , nomeprog , tamanho , nTipo , , .F. )
	    EndIf
	ElseIf mv_par03 == 2
		//Realiza salto gráfico
		If ValType( nLin__ ) == "N"
		    Lin += nLin__
		Else
			Lin += 60
		Endif
	    If Lin > 3100
	    	If lLinTbl
	    		oPrintErg:Line( lin , 150 , lin , 2300 )
	    	EndIf
		    Lin := 300
		    If nPaginaG > 0
			    oPrintErg:EndPage()
			Endif
			oPrintErg:StartPage()
			nPaginaG++
			If nPaginaG != 1
				oPrintErg:Say( 100 , 2320 , Alltrim( Str( nPaginaG , 10 ) ) , oFont08 )
			Endif
			If !Empty( cStartLogo ) .And. File( cStartLogo )
				oPrintErg:SayBitMap( 100 , 150 , cStartLogo , 300 , 150 )
		    EndIf
		    If lLinTbl
		    	oPrintErg:Line( lin + 60 , 150 , lin + 60 , 2300 )
		    	Lin += 60
		    EndIf
		Endif
	Endif

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} Sente_Upper
Transforma a primeira palavra de uma sentença em maiúscula

@return cTextoAux Caracter Retorna o texto formatado

@param cTexto Caracter Texto a ser formatado

@sample Sente_Upper( 'texto' )

@author Jackson Machado
@since 29/09/2014
/*/
//---------------------------------------------------------------------
Static Function Sente_Upper(cTexto)

	Local cTextoNew := SubStr( cTexto , 1 , 1 ) + Lower( SubStr( cTexto , 2 ) )
	Local cTextoAux := ""

	//Percorre todo o texto com a finalidade de deixar somente o primeiro caracter da sentença
	//(entre pontos '.') maiúsculo
	While .T.

		nPos := At( ". " , cTextoNew )
		If nPos > 0
			cTextoAux += SubStr( cTextoNew , 1 , nPos + 1 )
			cTextoNew := Upper( SubStr( cTextoNew , nPos + 2 , 1 ) ) + SubStr( cTextoNew , nPos + 3 )
		Else
			cTextoAux += cTextoNew
			Exit
		Endif

	End

Return cTextoAux
//----------------------------------------------------------------------------------------
// INÍCIO DA IMPRESSÃO DOS ATALHOS
//----------------------------------------------------------------------------------------
//---------------------------------------------------------------------
/*/{Protheus.doc} fControle
Imprime as Medidas de COntrole do Laudo

@return Sempre Verdadeiro

@sample fControle()

@author Jackson Machado
@since 29/09/2014
/*/
//---------------------------------------------------------------------
Static Function fControle()

	Local aArea := GetArea()

	//Percorre todas as Medidas de Controle vinculadas ao laudo
	//Caso seja Word, imprime conforme definição de variavel, caso for padrão, realiza impressão em linha
	dbSelectArea( "TO3" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "TO3" ) + TO0->TO0_LAUDO )
	While TO0->( !Eof() ) .And. xFilial( "TO3" ) + TO0->TO0_LAUDO == TO3->TO3_FILIAL + TO3->TO3_LAUDO
		dbSelectArea( "TO4" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "TO4" ) + TO3->TO3_CONTRO )
			lPrint := .t.
			If mv_par03 != 3
				fImpDoc856( Capital( AllTrim( TO4->TO4_NOMCTR ) ) + ": " + Alltrim( TO3->TO3_DESCRI ) )
			Else
				cVar1 := "cTXT" + Strzero( nVar1 , 6 )
				OLE_ExecuteMacro( oWord , "Nao_Identar" )
				OLE_SetDocumentVar( oWord , "Cria_Var" , cVar1 )
				nVar1++
				OLE_ExecuteMacro( oWord , "Somalinha" )
				OLE_ExecuteMacro( oWord , "Somalinha" )
				OLE_ExecuteMacro( oWord , "Cria_Titulo" )
				OLE_ExecuteMacro( oWord , "Com_Negrito" )
				OLE_SetDocumentVar( oWord , cVar1 , Capital( AllTrim( TO4->TO4_NOMCTR ) ) + ": " )

				fImpDoc856( Alltrim( TO3->TO3_DESCRI ) , .F. , .T. )
			Endif
		Endif
		dbSelectArea( "TO3" )
		dbSkip()
	End

	RestArea( aArea )

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fLocal
Imprime os Locais do Laudo

@return Sempre Verdadeiro

@param nTipoQdr Numerico Indica se imprime o Quadro (Obrigatório)

@sample fLocal( 1 )

@author Jackson Machado
@since 29/09/2014
/*/
//---------------------------------------------------------------------
Static Function fLocal( nTipoQdr )

	//Define variáveis de controle
	Local i
	Local nRegs		:= 0
	Local cImgImp
	Local cDescAmb
	Local cMemo		:= ""
	Local lCpoDesc	:= If( NGCADICBASE("TNE_MEMODS","D","TNE",.F.) , .T. , .F. )
	Local aArea		:= GetArea()

	lPula := .F.

	//Percorre todos os Locais vinculadas ao laudo
	//Caso nTipoQdr seja 1, imprime linearmente, caso seja 2 imprime em formato de Quadro
	dbSelectArea( "TO5" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "TO5" ) + TO0->TO0_LAUDO )
	While TO5->( !Eof() ) .And. xFilial( "TO5" ) + TO0->TO0_LAUDO == TO5->TO5_FILIAL + TO5->TO5_LAUDO

		dbSelectArea( "TNE" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "TNE" ) + TO5->TO5_CODAMB )

			lPrint := .T.
			If mv_par03 <> 3
				If lCpoDesc
					cDescAmb := Alltrim( TNE->TNE_MEMODS )
				Else
					cDescAmb := AllTrim( TNE->TNE_DESAMB ) + " " + AllTrim( TNE->TNE_DESAM1 ) + " " + AllTrim( TNE->TNE_DESAM2 ) + " " + AllTrim( TNE->TNE_DESAM3 ) + " " + AllTrim( TNE->TNE_DESAM4 )
					cDescAmb := Sente_Upper( cDescAmb )
				EndIf

				If mv_par03 == 1

					lPrimeiro   := .T.
					nTamanho    := 135 - Len( STR0062 + ": " ) //"Descricao do Ambiente"
					nLinhasMemo := MlCount( AllTrim( TNE->TNE_NOME ) , nTamanho )

					//Percorre o memo e realiza a impressão linear
					For i := 1 To nLinhasMemo
						If lPrimeiro
							@ Li , 000 PSay STR0063 + ": " //"Nome do Ambiente"
							lPrimeiro := .F.
						EndIf
						@ Li , 000 + Len( STR0064 + ": " ) PSay MemoLine( Alltrim( TNE->TNE_NOME ) , nTamanho , i ) //"Descricao do Ambiente"
						Somalinha()
					Next i

					lPrimeiro   := .T.
					nLinhasMemo := MlCount( cDescAmb , nTamanho )

					//Percorre o memo e realiza a impressão linear
					For i := 1 To nLinhasMemo
						If lPrimeiro
							@ Li , 000 pSay STR0064 + ": " //"Descricao do Ambiente"
							lPrimeiro := .F.
						EndIf
						@ Li , 000 + Len( STR0064 + ": " ) PSay MemoLine( cDescAmb , nTamanho , i ) //"Descricao do Ambiente"
						Somalinha()
					Next i

					Somalinha()

				ElseIf mv_par03 == 2

				   lPrimeiro := .T.
				   nDifCarac := 0
					If lIdentar
						nDifCarac := 7
					Endif
					nTamanho    := 72 - nDifCarac
					nLinhasMemo := MlCount( AllTrim( TNE->TNE_NOME ) , nTamanho )

					//Percorre o memo e realiza a impressão linear
					For i := 1 To nLinhasMemo
						If lPrimeiro
							oPrintErg:Say( lin , 150 , STR0063 + ": " , oFont10 ) //"Nome do Ambiente"
							lPrimeiro := .F.
						EndIf
						oPrintErg:Say( lin , 600 , MemoLine( AllTrim( TNE->TNE_NOME ) , nTamanho , i ) , oFont10 )
						Somalinha()
					Next i

					lPrimeiro   := .T.
					nLinhasMemo := MlCount( cDescAmb , nTamanho )

					//Percorre o memo e realiza a impressão linear
					For i := 1 To nLinhasMemo
						If lPrimeiro
							oPrintErg:Say( lin , 150 , STR0064 + ": " , oFont10 ) //"Descricao do Ambiente"
							lPrimeiro := .F.
						EndIf
						oPrintErg:Say( lin , 600 , MemoLine( cDescAmb , nTamanho , i ) , oFont10 )
						Somalinha()
					Next i

					Somalinha()

					//Caso ambiente possua imagem e for para imprimir imagem, realiza a impressão
					// Extrai do repositorio a imagem relacionada ao Ambiente Fisico e atribui o path do
					// arquivo extraido a variavel cImgImp
					If !Empty(TNE->TNE_BITMAP) .And. mv_par06 <> 2
						cImgImp := NGImgExtract( TNE->TNE_BITMAP, cPathEst )
						If !Empty( cImgImp )
							Somalinha()
							//Caso a página esteja no fim cria nova página para não truncar imagem
							If lin > 2160
								lin := 3001
								Somalinha()
							Endif
							cImgImp := Substr( cImgImp , 1 , At( "." , cImgImp ) )
							If File( cImgImp + "JPG" )
								cImgImp += "JPG"
							ElseIf File( cImgImp + "JPEG" )
								cImgImp += "JPEG"
							ElseIf File( cImgImp + "PNG" )
								cImgImp += "PNG"
							ElseIf File( cImgImp + "BMP" )
								cImgImp += "BMP"
							Endif
							oPrintErg:SayBitmap( lin + 10 , 200 , cImgImp , 1600 , 800 )
							//Verifica os arquivos criados para deletar depois
							If aScan( aImagens , { | x | Upper( AllTrim( x[ 1 ] ) ) == Upper( AllTrim( cImgImp ) ) } ) == 0
								aAdd( aImagens , { cImgImp } )
							Endif
							lin += 820
						Endif
					Endif
				Endif
			ElseIf nTipoQdr == 1 //Modelo Word - Sem Quadro
				////////////// Nome do Ambiente
				cVar1 := "cTXT" + StrZero( nVar1 , 6 )
				OLE_SetDocumentVar( oWord , "Cria_Var" , cVar1 )
				nVar1++
				OLE_ExecuteMacro( oWord , "Somalinha" )
				OLE_ExecuteMacro( oWord , "Somalinha" )
				OLE_ExecuteMacro( oWord , "Cria_Titulo" )
				OLE_ExecuteMacro( oWord , "Com_Negrito" )
				OLE_ExecuteMacro( oWord , "Alinhar_Esquerda" )
				OLE_SetDocumentVar( oWord , cVar1 , STR0063 + ":" ) //"Nome do Ambiente"

				cVar1 := "cTXT" + StrZero( nVar1 , 6 )
				OLE_SetDocumentVar( oWord , "Cria_Var" , cVar1 )
				nVar1++
				OLE_ExecuteMacro( oWord , "Cria_Texto" )
				OLE_ExecuteMacro( oWord , "Sem_Negrito" )
				OLE_ExecuteMacro( oWord , "Alinhar_Descricao" )
				OLE_SetDocumentVar( oWord , cVar1 , Capital( AllTrim( TNE->TNE_NOME ) ) )
				OLE_ExecuteMacro( oWord , "Somalinha" )

				////////////// Descrição do ambiente
				cVar1 := "cTXT" + StrZero( nVar1 , 6 )
				OLE_SetDocumentVar( oWord , "Cria_Var" , cVar1 )
				nVar1++
				OLE_ExecuteMacro( oWord , "Cria_Titulo" )
				OLE_ExecuteMacro( oWord , "Com_Negrito" )
				OLE_ExecuteMacro( oWord , "Alinhar_Esquerda" )
				OLE_SetDocumentVar( oWord , cVar1 , STR0065 + ":" ) //"Descrição do Ambiente"

				If lCpoDesc
					cDescAmb := Alltrim( TNE->TNE_MEMODS )
				Else
					cDescAmb := AllTrim( TNE->TNE_DESAMB ) + " " + AllTrim( TNE->TNE_DESAM1 ) + " " + AllTrim( TNE->TNE_DESAM2 ) + " " + AllTrim( TNE->TNE_DESAM3 ) + " " + AllTrim( TNE->TNE_DESAM4 )
					cDescAmb := Sente_Upper( cDescAmb )
				Endif

				cVar1 := "cTXT" + StrZero( nVar1 , 6 )
				OLE_SetDocumentVar( oWord , "Cria_Var" , cVar1 )
				nVar1++
				OLE_ExecuteMacro( oWord , "Cria_Texto" )
				OLE_ExecuteMacro( oWord , "Sem_Negrito" )
				OLE_ExecuteMacro( oWord , "Alinhar_Descricao" )
				OLE_SetDocumentVar( oWord , cVar1 , cDescAmb )
				OLE_ExecuteMacro( oWord , "Somalinha" )

				OLE_ExecuteMacro( oWord , "Retornar_Alinhamento" )

				//Caso ambiente possua imagem e for para imprimir imagem, realiza a impressão
				// Extrai do repositorio a imagem relacionada ao Ambiente Fisico e atribui o path do
				// arquivo extraido a variavel cImgImp
				If !Empty( TNE->TNE_BITMAP ) .And. mv_par06 <> 2
					cImgImp := NGImgExtract( TNE->TNE_BITMAP , cPathEst )
					If !Empty( cImgImp )
						cImgImp := Substr( cImgImp , 1 , At( "." , cImgImp ) )
						If File( cImgImp + "JPG" )
							cImgImp += "JPG"
						ElseIf File( cImgImp + "JPEG" )
							cImgImp += "JPEG"
						ElseIf File( cImgImp + "PNG" )
							cImgImp += "PNG"
						ElseIf File( cImgImp + "BMP" )
							cImgImp += "BMP"
						Endif
						OLE_ExecuteMacro( oWord , "Somalinha" )
						OLE_SetDocumentVar( oWord , "Cria_Var" , cImgImp )
						OLE_ExecuteMacro( oWord , "Insere_figura" )//Insere a imagem no documento Word
						OLE_ExecuteMacro( oWord , "Somalinha" )
						If aScan( aImagens , { | x | Upper( AllTrim( x[ 1 ] ) ) == Upper( AllTrim( SubStr( cImgImp , 1 , At( "." , cImgImp ) ) ) ) } ) == 0
							aADD( aImagens , { SubStr( cImgImp , 1 , At( "." , cImgImp ) ) } )
						Endif
						FErase( cImgImp )  //Apaga imagem extraida do repositorio
					EndIf
				Endif
			ElseIf nTipoQdr == 2 //Modelo Word - Com Quadro
				If lCpoDesc
					cDescAmb := Alltrim( TNE->TNE_MEMODS )
				Else
					cDescAmb := AllTrim( TNE->TNE_DESAMB ) + " " + AllTrim( TNE->TNE_DESAM1 ) + " " + AllTrim( TNE->TNE_DESAM2 ) + " " + AllTrim( TNE->TNE_DESAM3 ) + " " + AllTrim( TNE->TNE_DESAM4 )
					cDescAmb := Sente_Upper( cDescAmb )
				Endif
				cMemo += Alltrim( TNE->TNE_NOME ) + "#*"
				cMemo += cDescAmb + "#*"
				nRegs ++
			Endif
		Endif

		dbSelectArea( "TO5" )
		dbSkip()
	End

	If mv_par03 == 3 .And. nTipoQdr == 2 .And. nRegs > 0 //Modelo Word - Com Quadro
		OLE_ExecuteMacro( oWord , "Somalinha" )
		OLE_SetDocumentVar( oWord ,"Tabela" , cMemo )
		OLE_SetDocumentVar( oWord ,"Linhas" , nRegs )
		OLE_ExecuteMacro( oWord , "Table_Local" )
		OLE_ExecuteMacro( oWord , "Somalinha" )
	Endif

	RestArea( aArea )

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fMedQuadro
Imprime as Medadias Corretivas recomendadas em um Quadro contendo as Recomendações e Metas

@return Sempre Verdadeiro

@sample fMedQuadro()

@author Jackson Machado
@since 29/09/2014
/*/
//---------------------------------------------------------------------
Static Function fMedQuadro()

	//Define variáveis de controle
	Local nFor
	Local nRegs				:= 0
	Local nLin 				:= 10
	Local nLinhasMemo		:= 0
	Local nLinhaCorrente	:= 0
	Local nPulaLinha 		:= 60
	Local cLinhasMemo 		:= ""
	Local cMemo 			:= ""
	Local lFirst 			:= .T.
	Local aMedMod3 			:= {}
	Local aArea 			:= GetArea()

	//Percorre todas as Medidas de Controle vinculadas ao laudo
	//Realiza a impressão do Quadro conforme definição
	dbSelectArea( "TO3" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "TO3" ) + TO0->TO0_LAUDO )
	While TO3->( !Eof() ) .And. xFilial( "TO3" ) + TO0->TO0_LAUDO == TO3->TO3_FILIAL + TO3->TO3_LAUDO

		dbSelectArea( "TO4" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "TO4" ) + TO3->TO3_CONTRO )

			nRegs++

			If mv_par03 == 1
				If lFirst
					//     1         2         3         4         5         6         7         8         9        10        11        12        13
			  		//456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
					//Recomendações:                                                                           Metas:
					//12345678901234567890123456789012345678901234567890123456789012345678901234567890         1234567890123456789012345678901234567890
					Somalinha()
					@ Li , 004 Psay STR0066 //"Recomendações:                                                                           Metas:"
					lFirst := .F.
				Endif
				Somalinha()
				@ Li , 004 Psay TO4->TO4_NOMCTR
				nLinhasMemo := MlCount( AllTrim( TO4->TO4_DESCRI ) , 40 )
				cLinhasMemo := AllTrim( TO4->TO4_DESCRI )
				nLinha := 093
				//Percorre o memo e realiza a impressão das descrições
				For nLinhaCorrente := 1 to nLinhasMemo
					If !Empty( MemoLine( cLinhasMemo , 40 , nLinhaCorrente ) )
				   		@ Li , nLinha Psay MemoLine( cLinhasMemo , 40 , nLinhaCorrente )
				   		Somalinha()
					Endif
			    Next
			ElseIf mv_par03 == 2
				aAdd( aMedMod3 , { Alltrim( TO4->TO4_DESCRI ) , Alltrim( TO4->TO4_NOMCTR ) } )
			Else
				cMemo += Alltrim( TO4->TO4_DESCRI ) + "#*"
				cMemo += Alltrim( TO4->TO4_NOMCTR ) + "#*"
			Endif

		Endif

		dbSelectArea( "TO3" )
		dbSkip()
	End


	If nRegs > 0
		If mv_par03 == 1
			Somalinha()
		ElseIf mv_par03 == 2
			For nFor := 1 To Len( aMedMod3 )
				If nFor == 1
					If lin + 120 > 3000
						lin := 9999
					Endif
					Somalinha()
					oPrintErg:Line( lin , 150 , lin , 2300 )
					oPrintErg:Line( lin + 60 , 150 , lin + 60 , 2300 )
					oPrintErg:Line( lin,150 , lin + 60 , 150 )
					oPrintErg:Say( lin + 10 , 900 , STR0067 , oFont08b ) //"Metas"
					oPrintErg:Line( lin , 1700 , lin + 60 , 1700 )
					oPrintErg:Say( lin + 10 , 1850 , STR0068 , oFont08b ) //"Embasamento"
					oPrintErg:Line( lin , 2300 , lin + 60 , 2300 )
				Endif
				Somalinha()
				oPrintErg:Say( If( nFor == 1 , lin + 10 , lin + nPulaLinha ) , 1710 , SubStr( aMedMod3[ nFor , 2 ] , 1 , 37 ) , oFont08 )
				//Verifica a quantidade de linhas
				nLinhasMemo := MlCount( AllTrim( aMedMod3[ nFor , 1 ] ) , 100 )
				cLinhasMemo := AllTrim( aMedMod3[ nFor , 1 ] )
				For nLinhaCorrente := 1 to nLinhasMemo //Faz a impressão utilizando a quebra de linhas
					If !Empty( MemoLine( cLinhasMemo , 100 , nLinhaCorrente ) )
						oPrintErg:Say( lin + nLin , 160 , MemoLine( cLinhasMemo , 100 , nLinhaCorrente ) , oFont08 )
						nLin := nLin + 50
						nPulaLinha :=nLin
					Endif
			    Next nLinhaCorrente

				If lin == 300
					oPrintErg:Line( lin , 150 , lin , 2300 )
				Endif

				oPrintErg:Line( lin + nPulaLinha + 50 , 150 , lin + nPulaLinha + 50 , 2300 )
				oPrintErg:Line( lin , 150 , lin + nPulaLinha + 50 , 150 )

				oPrintErg:Line( lin , 1700 , lin + nPulaLinha + 50 , 1700 )
				oPrintErg:Line( lin , 2300 , lin + nPulaLinha + 50 , 2300 )
			Next nFor

			//Trata para que a variavel de controle de linha esteja correta
			lin := lin + nPulaLinha + 110
	    Else
	    	OLE_ExecuteMacro( oWord , "Somalinha" )
			OLE_ExecuteMacro( oWord , "Somalinha" )
			OLE_SetDocumentVar( oWord , "Tabela" , cMemo )
			OLE_SetDocumentVar( oWord , "Linhas" , nRegs )
			OLE_ExecuteMacro( oWord ,"Table_MedCorretiva" )
			OLE_ExecuteMacro( oWord ,"Somalinha" )
	    	OLE_ExecuteMacro( oWord ,"Somalinha" )
	    EndIf
	Else
		If mv_par03 == 3
			OLE_ExecuteMacro( oWord , "Somalinha" )
			OLE_ExecuteMacro( oWord , "Somalinha" )
		Endif
	Endif

	RestArea( aArea )

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fQuestionario
Imprime os Questionários Relacionados ao Laudo

@return Sempre Verdadeiro

@sample fQuestionario()

@author Jackson Machado
@since 29/09/2014
/*/
//---------------------------------------------------------------------
Static Function fQuestionario()

	Local nLinCorre , nLinhaMemo
	Local nPosResp
	Local cCodQuest
	Local cNomQuest
	Local cReinPer , cTipList , nNumRet
	Local cDescric, cCombo
	Local cSaveQuest	:= ""
	Local lCombo2		:= NGCADICBASE( "TMH_COMBO2" , "D" , "TMH" , .F. )
	Local lRespos		:= NGCADICBASE( "TMH_RESPOS" , "D" , "TMH" , .F. )
	Local aCombo

	dbSelectArea( "TOX" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "TOX" ) + TO0->TO0_LAUDO )
	While TOX->( !Eof() ) .And. xFilial( "TOX" ) + TO0->TO0_LAUDO == TOX->TOX_FILIAL + TOX->TOX_LAUDO
		nNumRet		:= 0
		cCodQuest	:= TOX->TOX_QUESTI
		cNomQuest	:= NgSeek("TMG",TOX->TOX_QUESTI,1,"TMG->TMG_NOMQUE")
		If mv_par03 == 1
			SomaLinha()

			//Questionário xxxxxx - xxxxxxxxxxxxxxxxxxxxxxxxx - Realização: xx/xx/xx
			@ Li,004 Psay STR0069 + AllTrim( TOX->TOX_QUESTI ) + " - " + ; //"Questionário "
				  AllTrim( cNomQuest ) + " - " + STR0070 + DtoC( TOX->TOX_DTREAL ) //"Realização: "
			SomaLinha()
			@ Li,008 Psay STR0071 + ": " //"Perguntas"
			SomaLinha()

			While TOX->( !Eof() ) .And. ;
				xFilial("TOX") + TO0->TO0_LAUDO == TOX->TOX_FILIAL + TOX->TOX_LAUDO .And. ;
				TOX->TOX_QUESTI == cCodQuest
	   			dbSelectArea( "TMH" )
	    		dbSetOrder( 1 )
	    		If dbSeek( xFilial( "TMH" ) + TOX->TOX_QUESTI + TOX->TOX_QUESTA )

		   			cNumQuest	:= TOX->TOX_QUESTA
		   			cTipList	:= TMH->TMH_TPLIST
		   			cQuestao	:= TMH->TMH_PERGUN
		   			cDescric	:= ""

		   			If lRespos
		   				cCombo := AllTrim( TMH->TMH_RESPOS )
		   			ElseIf lCombo2
			    		cCombo := AllTRIM( TMH->TMH_COMBO + TMH->TMH_COMBO2 )
	    			Else
	    				cCombo := AllTRIM( TMH->TMH_COMBO )
	    			EndIf
	    			aCombo := StrTokArr( cCombo , ";" )

	    			@ Li , 008 Psay TOX->TOX_QUESTA + " - " + cQuestao
	    			SomaLinha()

	    			@ Li , 012 Psay STR0072 + ": " //"Resposta(s)"

		   			While TOX->( !Eof() ) .And. ;
						xFilial("TOX") + TO0->TO0_LAUDO == TOX->TOX_FILIAL + TOX->TOX_LAUDO .And. ;
						TOX->TOX_QUESTI == cCodQuest .And. TOX->TOX_QUESTA == cNumQuest

						If Alltrim( TOX->TOX_RESPOS ) <> "#" .And. ;
							( nPosResp := ( aScan( aCombo , { | x | SubStr( x , 1 ,1 ) == TOX->TOX_RESPOS } ) ) ) > 0
			    			SomaLinha()
			    			@ Li , 016 Psay SubStr( aCombo[ nPosResp ] , 3 , Len( aCombo[ nPosResp ] ) )
			    		Else
			    			cDescric := TOX->TOX_DESCRI
			    		EndIf

			    		dbSelectArea( "TOX" )
	    				dbSkip()
		    		End

		    		If TMH->TMH_ONMEMO == "1" .And. !Empty( cDescric )
		    			Somalinha()
		    			@ Li , 012 Psay STR0073 + ": "   //"Observação"
	    				nLinhaMemo := MlCount( cDescric , 90 )
						For nLinCorre := 1 To nLinhaMemo
							IF( nLinCorre <> 1 , SomaLinha() , )
							@ Li , 025 Psay MemoLine( cDescric , 90 , nLinCorre )
						Next nLinCorre
		    		EndIf
				EndIf
	    		SomaLinha()
	    	End

		ElseIf mv_par03 == 2
			SomaLinha()
			//Questionário xxxxxx - xxxxxxxxxxxxxxxxxxxxxxxxx - Realização: xx/xx/xx
			fImpHea856( Alltrim(  STR0069 + AllTrim( TOX->TOX_QUESTI ) + " - " + ;  //"Questionário "
							   AllTrim( cNomQuest ) + " - " + STR0074 + ": " + DtoC( TOX->TOX_DTREAL ) ) ) //"Realização"
			SomaLinha()
			oPrintErg:Say(lin,300,STR0071 + ": ",oFont12) //"Perguntas"
			SomaLinha()

			While TOX->( !Eof() ) .And. ;
				xFilial( "TOX" ) + TO0->TO0_LAUDO == TOX->TOX_FILIAL+TOX->TOX_LAUDO .And. ;
				TOX->TOX_QUESTI == cCodQuest

	   			dbSelectArea( "TMH" )
	    		dbSetOrder( 1 )
	    		If dbSeek( xFilial( "TMH" ) + TOX->TOX_QUESTI + TOX->TOX_QUESTA )

		   			cNumQuest	:= TOX->TOX_QUESTA
		   			cTipList	:= TMH->TMH_TPLIST
		   			cQuestao	:= TMH->TMH_PERGUN
		   			cDescric	:= ""

		   			If lRespos
		   				cCombo := AllTrim( TMH->TMH_RESPOS )
		   			ElseIf lCombo2
			    		cCombo := AllTRIM( TMH->TMH_COMBO + TMH->TMH_COMBO2 )
	    			Else
	    				cCombo := AllTRIM( TMH->TMH_COMBO )
	    			EndIf
	    			aCombo := StrTokArr( cCombo , ";" )

	    			oPrintErg:Say( lin , 300 , TOX->TOX_QUESTA + " - " + cQuestao , oFont10 )
	    			SomaLinha()

	    			oPrintErg:Say( lin , 450 , STR0072 + ": " , oFont10 ) //"Resposta(s)"

	    			While TOX->( !Eof() ) .And. ;
						xFilial("TOX") + TO0->TO0_LAUDO == TOX->TOX_FILIAL + TOX->TOX_LAUDO .And. ;
						TOX->TOX_QUESTI == cCodQuest .And. TOX->TOX_QUESTA == cNumQuest

						If Alltrim( TOX->TOX_RESPOS ) <> "#" .And. ;
							( nPosResp := ( aScan( aCombo , { | x | SubStr( x , 1 ,1 ) == TOX->TOX_RESPOS } ) ) ) > 0
							SomaLinha()
			    			oPrintErg:Say( lin , 450 , SubStr( aCombo[ nPosResp ] , 3 , Len( aCombo[ nPosResp ] ) ) , oFont10 )
			    		Else
			    			cDescric := TOX->TOX_DESCRI
			    		EndIf

			    		dbSelectArea( "TOX" )
	    				dbSkip()
		    		End

		    		If TMH->TMH_ONMEMO == "1" .And. !Empty( cDescric )
		    			Somalinha()
		    			oPrintErg:Say( lin , 450 , STR0073 + ": " , oFont10 ) //"Observação"
	    				nLinhaMemo := MlCount( cDescric , 90 )
						For nLinCorre := 1 To nLinhaMemo
							IF( nLinCorre <> 1 , SomaLinha() , )
							oPrintErg:Say( lin , 660 , MemoLine( cDescric , 90 , nLinCorre ) , oFont10 )
						Next nLinCorre
		    		EndIf
		    	EndIf
		    	SomaLinha()
	    	End

		Else

			//Questionário xxxxxx - xxxxxxxxxxxxxxxxxxxxxxxxx - Realização: xx/xx/xx
			fImpHea856( AllTrim(  STR0069 + AllTrim( TOX->TOX_QUESTI ) + " - " + ;  //"Questionário "
							   AllTrim( cNomQuest ) + " - " + STR0074 + ": " + DtoC(TOX->TOX_DTREAL) ))  //"Realização"

			//"Perguntas: "
			cVar1 := "cTXT" + StrZero( nVar1 , 6 )
			OLE_SetDocumentVar( oWord , "Cria_Var" , cVar1 )
			nVar1++
			OLE_ExecuteMacro( oWord , "Somalinha" )
			OLE_ExecuteMacro( oWord , "Cria_Texto" )
			OLE_ExecuteMacro( oWord , "Sem_Negrito" )
			OLE_SetDocumentVar( oWord , cVar1 , "Perguntas" + ": " )

			While TOX->( !Eof() ) .And. ;
				xFilial( "TOX" ) + TO0->TO0_LAUDO == TOX->TOX_FILIAL + TOX->TOX_LAUDO .And. ;
				TOX->TOX_QUESTI == cCodQuest
	   			dbSelectArea( "TMH" )
	    		dbSetOrder( 1 )
	    		If dbSeek( xFilial( "TMH" ) + TOX->TOX_QUESTI + TOX->TOX_QUESTA )

		   			cNumQuest	:= TOX->TOX_QUESTA
		   			cTipList	:= TMH->TMH_TPLIST
		   			cQuestao	:= TMH->TMH_PERGUN
		   			cDescric	:= ""

		   			If lRespos
		   				cCombo := AllTrim( TMH->TMH_RESPOS )
		   			ElseIf lCombo2
			    		cCombo := AllTRIM( TMH->TMH_COMBO + TMH->TMH_COMBO2 )
	    			Else
	    				cCombo := AllTRIM( TMH->TMH_COMBO )
	    			EndIf
	    			aCombo := StrTokArr( cCombo , ";" )
	    			cVar1 := "cTXT" + StrZero( nVar1 , 6 )
					OLE_SetDocumentVar( oWord , "Cria_Var" , cVar1 )
					nVar1++
					OLE_ExecuteMacro( oWord , "Somalinha" )
					OLE_ExecuteMacro( oWord , "Cria_Texto" )
					OLE_ExecuteMacro( oWord , "Sem_Negrito" )
					OLE_SetDocumentVar( oWord , cVar1 , TOX->TOX_QUESTA + " - " + cQuestao )

	    			cVar1 := "cTXT" + StrZero( nVar1 , 6 )
					OLE_SetDocumentVar( oWord , "Cria_Var" , cVar1 )
					nVar1++
					OLE_ExecuteMacro( oWord , "Somalinha" )
					OLE_ExecuteMacro( oWord , "Cria_Texto" )
					OLE_ExecuteMacro( oWord , "Sem_Negrito" )
					OLE_SetDocumentVar( oWord , cVar1 , Space( 3 ) + STR0072 + ": " ) //"Resposta(s)"

	    			While TOX->( !Eof() ) .And. ;
						xFilial("TOX") + TO0->TO0_LAUDO == TOX->TOX_FILIAL + TOX->TOX_LAUDO .And. ;
						TOX->TOX_QUESTI == cCodQuest .And. TOX->TOX_QUESTA == cNumQuest

						If Alltrim( TOX->TOX_RESPOS ) <> "#" .And. ;
							( nPosResp := ( aScan( aCombo , { | x | SubStr( x , 1 ,1 ) == TOX->TOX_RESPOS } ) ) ) > 0
							cVar1 := "cTXT" + StrZero( nVar1 , 6 )
							OLE_SetDocumentVar( oWord , "Cria_Var" , cVar1 )
							nVar1++
							OLE_ExecuteMacro( oWord , "Somalinha" )
							OLE_ExecuteMacro( oWord , "Cria_Texto" )
							OLE_ExecuteMacro( oWord , "Sem_Negrito" )
							OLE_SetDocumentVar( oWord , cVar1 , Space( 6 ) + SubStr( aCombo[ nPosResp ] , 3 , Len( aCombo[ nPosResp ] ) ) )
			    		Else
			    			cDescric := TOX->TOX_DESCRI
			    		EndIf

			    		dbSelectArea( "TOX" )
	    				dbSkip()
		    		End

		    		If TMH->TMH_ONMEMO == "1" .And. !Empty( cDescric )
		    			cVar1 := "cTXT" + StrZero( nVar1 , 6 )
						OLE_SetDocumentVar( oWord , "Cria_Var" , cVar1 )
						nVar1++
						OLE_ExecuteMacro( oWord , "Somalinha" )
						OLE_ExecuteMacro( oWord , "Cria_Texto" )
						OLE_ExecuteMacro( oWord , "Sem_Negrito" )
						OLE_SetDocumentVar( oWord , cVar1 , Space( 3 ) + STR0073 + ": " ) //"Observação"
	    				nLinhaMemo := MlCount( cDescric , 90 )
						For nLinCorre := 1 To nLinhaMemo
							IF( nLinCorre <> 1 , SomaLinha() , )
							cVar1 := "cTXT" + StrZero( nVar1 , 6 )
							OLE_SetDocumentVar( oWord , "Cria_Var" , cVar1 )
							nVar1++
							OLE_ExecuteMacro( oWord , "Somalinha" )
							OLE_ExecuteMacro( oWord , "Cria_Texto" )
							OLE_ExecuteMacro( oWord , "Sem_Negrito" )
							OLE_SetDocumentVar( oWord , cVar1 , Space( 6 ) + MemoLine( cDescric , 90 , nLinCorre ) )

						Next nLinCorre
		    		EndIf
		    	EndIf
				OLE_ExecuteMacro( oWord , "Somalinha" )
		    End
		EndIf

	End

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fRisco
Imprime os Riscos que estão vinculados ao Laudo com Todos os Funcionários Expostos

@return Sempre Verdadeiro

@sample fRisco()

@author Jackson Machado
@since 29/09/2014
/*/
//---------------------------------------------------------------------
Static Function fRisco()

	Local i		:= 0
	Local aTN0	:= {}
	Local aArea	:= GetArea()

	lPula := .F.

	aTN0 := aClone( aRiscErg )

	For i := 1 To Len( aTN0 )
		dbSelectArea( "TN0" )
		dbSetOrder( 1 )
		dbSeek( xFilial( "TN0" ) + aTN0[ i , 1 ] )

		dbSelectArea( "TMA" )
		dbSetOrder( 1 )
		dbSeek( xFilial( "TMA" ) + TN0->TN0_AGENTE )

		fImpRisco()
	Next i
	If lPula
		If mv_par03 != 3
			Somalinha()
		Else
			OLE_ExecuteMacro( oWord , "Somalinha" )
		EndIf
	EndIf

	RestArea( aArea )

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fGetRisco
Seleciona os Riscos do Laudo

@return aRiscos Array Array contendo os Riscos do Laudo

@sample fGetRisco()

@author Jackson Machado
@since 29/09/2014
/*/
//---------------------------------------------------------------------
Static Function fGetRisco()

	Local cNomCC, cNomFun, cNomTar
	Local cNomFin, cNomAge
	Local aRiscos := {}

	dbSelectArea( "TO1" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "TO1" ) + TO0->TO0_LAUDO )
	While TO1->( !EoF() ) .And. xFilial( "TO1" ) + TO0->TO0_LAUDO == TO1->TO1_FILIAL + TO1->TO1_LAUDO
		dbSelectArea( "TN0" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "TN0" ) + TO1->TO1_NUMRIS ) .And. TN0->TN0_MAPRIS != "1"//Valida se o Mapa Risco é diferente de CIPA ### Autor: Jackson Machado ### Data: 10/02/2011
			dbSelectArea( "TMA" )
			dbSetOrder( 1 )
			If dbSeek( xFilial( "TMA" ) + TN0->TN0_AGENTE ) .And. TMA->TMA_GRISCO == "4"
				If cAliasCC == "CTT"
			        cNomCC  := AllTrim( NGSEEK( "CTT" , TN0->TN0_CC , 1 , "CTT_DESC01" ) )
				Else
			        cNomCC  := AllTrim( NGSEEK( "SI3" , TN0->TN0_CC , 1 , "I3_DESC" ) )
				Endif
				cNomFun := AllTrim( NGSEEK( "SRJ" , TN0->TN0_CODFUN , 1 , "RJ_DESC" ) )
				cNomTar := AllTrim( SubStr( NGSEEK( "TN5" , TN0->TN0_CODTAR , 1 , "TN5_NOMTAR" ) , 1 , 40 ) )
				cNomFon := AllTrim( NGSEEK( "TN7" , TN0->TN0_FONTE , 1 , "TN7_NOMFON" ) )
				cNomAge := AllTrim( TMA->TMA_NOMAGE )
				aAdd( aRiscos , { 	TN0->TN0_NUMRIS , TN0->TN0_CC , cNomCC , TN0->TN0_CODFUN , ;
								cNomFun , TN0->TN0_CODTAR , cNomTar , TN0->TN0_AGENTE , cNomAge , ;
								TN0->TN0_FONTE , cNomFon } )
	        EndIf
		Endif
		dbSelectArea( "TO1" )
		dbsetOrder( 1 )
		dbSkip()
	EndDo

	If mv_par07 == 2
		aSort( aRiscos , , , { | x , y | x[ 9 ] + x[ 1 ] < y[ 9 ] + y[ 1 ] } ) //"Cód. Agente de risco"
	ElseIf mv_par07 == 3
		aSort( aRiscos , , , { | x , y | x[ 11 ] + x[ 1 ] < y[ 11 ] + y[ 1 ] } ) //"Cód. Fonte geradora"
	ElseIf mv_par07 == 4
		aSort( aRiscos , , , { | x , y | x[ 3 ] + x[ 5 ] + x[ 1 ] < y[ 3 ] + y[ 5 ] + y[ 1 ] } )//"Cód. Centro de custo"
	ElseIf mv_par07 == 5
		aSort( aRiscos , , , { | x , y | x[ 5 ] + x[ 3 ] + x[ 1 ] < y[ 5 ] + y[ 3 ] + y[ 1 ] } )//"Cód. Função"
	Else
		aSort( aRiscos , , , { | x , y | x[ 1 ] < y[ 1 ] } )
	Endif

Return aRiscos
//---------------------------------------------------------------------
/*/{Protheus.doc} fImpRisco
Imprime as Informações do Risco

@return Sempre Verdadeiro

@sample fRisco()

@author Jackson Machado
@since 29/09/2014
/*/
//---------------------------------------------------------------------
Static Function fImpRisco()

	Local nX, nLinhas , nTam, i
	Local nInd, nCps

	Local lUPDMDTA9 	:= NGCADICBASE( "TMA_CLASSI" , "A" , "TMA" , .F. ) //Verifica se o UPDATE UPDMDTA9 foi executado.

	Local cImgImp		:= ""
	Local cComExp		:= ""

	Local aAtividades	:= {}
	Local aTMACombo 	:= PPPMDTCbox("TMA_GRISCO"," ",1)

	Private cGrau_Risco	:= " "
	Private aFuncRisco	:= {}

	//Realiza todos os posicionamentos
	dbSelectArea( "TO1" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "TO1" ) + TO0->TO0_LAUDO + TN0->TN0_NUMRIS )
	dbSelectArea( "TN7" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "TN7" ) + TN0->TN0_FONTE )
	dbSelectArea( cAliasCC )
	dbSetOrder( 1 )
	dbSeek( xFilial( cAliasCC ) + TN0->TN0_CC )
	dbSelectArea( "SRJ" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "SRJ" ) + TN0->TN0_CODFUN )
	dbSelectArea( "TN5" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "TN5" ) + TN0->TN0_CODTAR )
	dbSelectArea( "TNE" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "TNE" ) + TN0->TN0_CODAMB )

	If AliasInDic( "TJF" )
		dbSelectArea( "TJF" )
		dbSetOrder( 1 )
		dbSeek( xFilial( "TJF" ) + TN0->TN0_NUMRIS )
	EndIf

	lPrin2 := .F.
	lPrint := .F.

	//Define os campos que deverao ser impressos, suas condicionais e formas de impressao
	// 					Campo   			Nome   Condicional  								  Impressao 													   Array Combo   Imagem
	aCampos := { 	{ "TMA->TMA_NOMAGE" , STR0075 , ".T." 										, "" 															, "" 			, "" } , ; //"Agente"
					{ "TMA->TMA_GRISCO" , STR0076 , ".T." 										, "cGrau_Risco" 												, "" 			, "" } , ; //"Risco"
					{ "TN7->TN7_NOMFON" , STR0023 , ".T." 										, "" 															, "" 			, "TN7->TN7_BITMAP" } , ; //"Fonte Geradora"
					{ "TN0->TN0_CC" 	, STR0024 , ".T." 										, "If(Alltrim(TN0->TN0_CC)=='*','Todos',Capital(&cDescrCC))" 	, "" 			, "" } , ; //"Centro de Custo"
					{ "TN0->TN0_CODFUN" , STR0025 , "Alltrim(TN0->TN0_CODFUN) != '*'" 			, "SRJ->RJ_DESC" 												, "" 			, "" } , ; //"Função"
					{ "TN0->TN0_CODTAR" , STR0077 , "Alltrim(TN0->TN0_CODTAR) != '*'" 			, "TN5->TN5_NOMTAR" 											, "" 			, "" } , ; //"Tarefa"
					{ "TNE->TNE_NOME" 	, STR0078 , ".T." 										, "" 															, "" 			, "TNE->TNE_BITMAP" } , ; //"Ambiente"
					{ "TN0->TN0_DTAVAL" , STR0079 , ".T."										, "" 															, "" 			, "" } , ; //"Data de Avaliação"
					{ "TN0->TN0_QTAGEN" , STR0080 , ".T." 										, "Alltrim( Str( TN0->TN0_QTAGEN ) ) + ' ' + TN0->TN0_UNIMED" 	, "" 			, "" } , ; //"Quantidade do Agente de Risco"
					{ "TN0->TN0_SIMBOL" , STR0081 , "TN0->(FieldPos('TN0_SIMBOL')) > 0" 		, "" 															, "" 			, "" } , ; //"Símbolos"
					{ "TN0->TN0_INDEXP" , STR0082 , "TN0->(FieldPos('TN0_INDEXP')) > 0" 		, "'3'" 														, "TN0_INDEXP" 	, "" } , ; //"Tipo de Exposição"
					{ "TN0->TN0_COMEXP" , STR0083 , "NGCADICBASE('TN0_COMEXP','A','TN0',.F.)" 	, "" 															, "" 			, "" } , ; //"Compl. Exposição"
					{ "TO1->TO1_RECOME" , STR0084 , ".T." 										, "" 															, "" 			, "" } ; //"Recomendação"
					}

	//Define a impressão do Grau de Risco
	cGrau_Risco := " "
	If Len( aTMACombo ) == 0
		Do Case
		Case TMA->TMA_GRISCO == "1" ; cGrau_Risco := STR0085 //"Físico"
		Case TMA->TMA_GRISCO == "2" ; cGrau_Risco := STR0086 //"Químico"
		Case TMA->TMA_GRISCO == "3" ; cGrau_Risco := STR0087 //"Biológico"
		Case TMA->TMA_GRISCO == "4" ; cGrau_Risco := STR0088 //"Ergonômico"
		Case TMA->TMA_GRISCO == "5" ; cGrau_Risco := STR0089 //"Acidente"
		Case TMA->TMA_GRISCO == "6" ; cGrau_Risco := STR0090 //"Mecânico"
		Case TMA->TMA_GRISCO == "7" ; cGrau_Risco := STR0132 //"Perigoso"
		End Case
	Else
		If (nIND := aScan(aTMAcombo,{|x| Upper(Substr(x,1,1)) == Substr(TMA->TMA_GRISCO,1,1)})) > 0
			cGrau_Risco := Substr(aTMAcombo[nIND],3)
		Endif
	Endif

	//Realiza a impressão dos campos pertinentes ao risco
	For nCps := 1 To Len( aCampos )
		If &( aCampos[ nCps , 3 ] )
			//Define valor de Impressão
			cValImp := " "
			If !Empty( aCampos[ nCps , 4 ] ) .And. Empty( aCampos[ nCps , 5 ] )
				cValImp := cValToChar( &( aCampos[ nCps , 4 ] ) )
			ElseIf !Empty( aCampos[ nCps , 5 ] )
				cValImp := &( aCampos[ nCps , 1 ] )
				If !Empty( cValImp )
					cValImp := AllTrim( Capital( NGRetSX3Box( aCampos[ nCps , 5 ] , cValImp ) ) )
				Else
					cValImp := AllTrim( Capital( NGRetSX3Box( aCampos[ nCps , 5 ] , &( aCampos[ nCps , 4 ] ) ) ) )
				EndIf
			Else
				cValImp := cValToChar( &( aCampos[ nCps , 1 ] ) )
			EndIf

			//Define se haverá imagem impressa
			cImgImp := &( aCampos[ nCps , 6 ] )
			If !Empty( cImgImp ) .And. nImpImage <> 2
				cImgImp := NGImgExtract( cImgImp , cPathEst )
				If File(cImgImp+"JPG")
					cImgImp += "JPG"
				ElseIf File(cImgImp+"JPEG")
					cImgImp += "JPEG"
				ElseIf File(cImgImp+"PNG")
					cImgImp += "PNG"
				ElseIf File(cImgImp+"BMP")
					cImgImp += "BMP"
				Endif

			//Verifica os arquivos criados para deletar depois
				If aScan( aImagens , { | x | Upper( AllTrim( x[ 1 ] ) ) == Upper( AllTrim( cImgImp ) ) } ) == 0
					aAdd( aImagens , { cImgImp } )
				Endif
			Else
				cImgImp := ""
			EndIf

			If mv_par03 == 1
				Somalinha()
				@ Li , 005 Psay aCampos[ nCps , 2 ] + ":"
				nLinhasMemo := MlCount( cValImp , 80 )
				//Percorre o memo e realiza a impressão linear
				For i := 1 To nLinhasMemo
					SomaLinha()
					@ Li , 036 PSay MemoLine( cValImp , 80 , i )
				Next i
			ElseIf mv_par03 == 2
				Somalinha()
				oPrintErg:Say( lin , 200 , aCampos[ nCps , 2 ] + ":" , oFont10b )
				nLinhasMemo := MlCount( cValImp , 80 )
				//Percorre o memo e realiza a impressão linear
				For i := 1 To nLinhasMemo
					SomaLinha()
					oPrintErg:Say( lin , 850 , MemoLine( cValImp , 80 , i ) , oFont10 )
				Next i
				If !Empty( cImgImp )
					Somalinha()

					//Caso a página esteja no fim cria nova página para não truncar imagem
					If lin > 2160
						lin := 3001
						Somalinha()
					Endif
					oPrintErg:SayBitmap( lin + 10 , 200 , cImgImp , 1600 , 800 )
					lin += 820
				Endif
			ElseIf mv_par03 == 3
				cVar1 := "cTXT" + StrZero( nVar1 , 6 )
				OLE_SetDocumentVar( oWord , "Cria_Var" , cVar1 )
				nVar1++
				OLE_ExecuteMacro( oWord , "Somalinha" )
				OLE_ExecuteMacro( oWord , "Somalinha" )
				OLE_ExecuteMacro( oWord , "Cria_Texto" )
				OLE_ExecuteMacro( oWord , "Com_Negrito" )
				OLE_SetDocumentVar( oWord , cVar1 , aCampos[ nCps , 2 ] + ":" )

				cVar1 := "cTXT" + StrZero( nVar1 , 6 )
				OLE_SetDocumentVar( oWord , "Cria_Var" , cVar1 )
				nVar1++
				OLE_ExecuteMacro( oWord , "Cria_Txt2" )
				OLE_ExecuteMacro( oWord , "Sem_Negrito" )
				OLE_SetDocumentVar( oWord , cVar1 , cValImp )

				// Extrai do repositorio a imagem relacionada a Fonte Geradora e atribui o path do
				// arquivo extraido a variavel cImgImp
				If !Empty( cImgImp ) .And. nImpImage <> 2
					OLE_ExecuteMacro( oWord , "Somalinha" )
					OLE_SetDocumentVar( oWord , "Cria_Var" , cImgImp )
					OLE_ExecuteMacro( oWord , "Insere_figura2" )    //Insere a imagem no documento Word
					FErase( cImgImp )  //Apaga imagem extraida do repositorio
				EndIf
			EndIf
		EndIf
	Next nCps
	SomaLinha()

	lControLi := .f.

	fGetFunc()//Funcao que acumula o total de funcionarios expostos e carrega array com a relação dos funcionários

	//Funcionarios expostos
	lPrim := .t.
	aSort( aFuncRisco , , , { | x , y | x[ 2 ] < y[ 2 ] } )
	For nInd := 1 to Len( aFuncRisco )//Array contendo os funcionarios expostos ao risco - alimentada na funcao fGetFunc()

		If mv_par03 == 1
			If lPrim
				Somalinha()
				@ Li , 005 Psay STR0091 + ":" //"Funcionários expostos ao Risco"
				Somalinha()
				@ Li , 005 Psay STR0092 //"Matrícula   Nome"
				Somalinha()
				lPrim := .F.
			EndIf
			@ Li , 005 Psay aFuncRisco[ nInd , 1 ]
			@ Li , 017 Psay aFuncRisco[ nInd , 2 ]
			Somalinha()
		ElseIf mv_par03 == 2
			If lPrim
				Somalinha()
				oPrintErg:Say( lin , 200 , STR0091 + ":" , oFont10b ) //"Funcionários expostos ao Risco"
				Somalinha()
				oPrintErg:Say( lin , 200 , STR0093 , oFont10b ) //"Matrícula"
				oPrintErg:Say( lin , 600 , STR0094 , oFont10b ) //"Nome"
				Somalinha()
				lPrim := .f.
			EndIf
			oPrintErg:Say( lin , 200 , aFuncRisco[ nInd , 1 ] , oFont10 )
			oPrintErg:Say( lin , 600 , aFuncRisco[ nInd , 2 ] , oFont10 )
			Somalinha()
		ElseIf mv_par03 == 3
			If lPrim
				cVar1 := "cTXT" + StrZero( nVar1 , 6 )
				OLE_SetDocumentVar( oWord , "Cria_Var" , cVar1 )
				nVar1++
				OLE_ExecuteMacro( oWord ,"Somalinha" )
				OLE_ExecuteMacro( oWord ,"Cria_Texto" )
				OLE_ExecuteMacro( oWord ,"Com_Negrito" )
				OLE_SetDocumentVar( oWord , cVar1 , STR0091 + ":" ) //"Funcionários expostos ao Risco"
				lPrim := .f.
			EndIf

			cVar1 := "cTXT" + StrZero( nVar1 , 6 )
			OLE_SetDocumentVar( oWord , "Cria_Var" , cVar1 )
			nVar1++
			OLE_ExecuteMacro( oWord , "Somalinha" )
			OLE_ExecuteMacro( oWord , "Cria_Texto" )
			OLE_ExecuteMacro( oWord , "Com_Negrito" )
			OLE_SetDocumentVar( oWord , cVar1 , STR0093 + ":" ) //"Matrícula"

			cVar1 := "cTXT" + StrZero( nVar1 , 6 )
			OLE_SetDocumentVar( oWord , "Cria_Var" , cVar1 )
			nVar1++
			OLE_ExecuteMacro( oWord , "Cria_Texto" )
			OLE_ExecuteMacro( oWord , "Sem_Negrito" )
			OLE_SetDocumentVar( oWord , cVar1 , aFuncRisco[ nInd , 1 ] )

			cVar1 := "cTXT" + StrZero( nVar1 , 6 )
			OLE_SetDocumentVar( oWord , "Cria_Var" , cVar1 )
			nVar1++
			OLE_ExecuteMacro( oWord , "Somalinha" )
			OLE_ExecuteMacro( oWord , "Cria_Texto" )
			OLE_ExecuteMacro( oWord , "Com_Negrito" )
			OLE_SetDocumentVar( oWord , cVar1 , STR0094 + ":" ) //"Nome"


			cVar1 := "cTXT" + StrZero( nVar1 , 6 )
			OLE_SetDocumentVar( oWord , "Cria_Var" , cVar1 )
			nVar1++
			If Len( aFuncRisco[ nInd , 1 ] ) < 6
				OLE_ExecuteMacro( oWord , "Cria_Txt3" )
			Else
				OLE_ExecuteMacro( oWord , "Cria_Texto" )
			EndIf
			OLE_ExecuteMacro( oWord , "Sem_Negrito" )
			OLE_SetDocumentVar( oWord , cVar1 , Capital( aFuncRisco[ nInd , 2 ] ) )
			OLE_ExecuteMacro( oWord , "Somalinha" )
		Endif
	Next
	lPula := .t.

	If lControLi
		If mv_par03 <> 3
			//If Li != 6 //Se o cursor estiver na primeira linha nao eh necessario criar uma nova pagina
			Somalinha()
			//Endif
		ElseIf mv_par03 == 3
			OLE_ExecuteMacro( oWord , "Somalinha" )
		Endif
	Endif

	lPula := .t.

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fGetFunc
Traz a Lista de Funcionários Expostos ao Risco

@return Sempre Verdadeiro

@sample fGetFunc()

@author Jackson Machado
@since 29/09/2014
/*/
//---------------------------------------------------------------------
Static Function fGetFunc()

	Local lExist	:= .F.
	Local lRet		:= .F.

	Local nInd		:= 2 //Ordenar pelo Codigo do Centro de Custo
	Local cSeek		:= ""
	Local cField	:= "SRA->RA_CC"

	If AllTrim( TN0->TN0_CC ) == "*"
		If AllTrim( TN0->TN0_CODFUN ) == "*"
			If AllTrim( TN0->TN0_CODTAR ) == "*"
				dbSelectArea( "SRA" )
				dbSetOrder( 1 )
				dbSeek( xFilial( "SRA" ) )
				While SRA->( !EoF() ) .And. xFilial( "SRA" ) == SRA->RA_FILIAL
					If fConsistFunc()
						If aScan( aFuncRisco , { | x | x[ 1 ] == SRA->RA_MAT } ) == 0
							aAdd( aFuncRisco , { SRA->RA_MAT , SRA->RA_NOME } )
							lExist := .T.
						Endif
					EndIf
					dbSelectArea( "SRA" )
					dbSkip()
				End
			Else
				dbSelectArea( "TN6" )
				dbSetOrder(01)
				dbSeek( xFilial( "TN6" ) + TN0->TN0_CODTAR )
				While TN6->( !EoF() ) .And. xFilial( "TN6" ) == TN6->TN6_FILIAL .And. ;
					TN6->TN6_CODTAR == TN0->TN0_CODTAR
					dbSelectArea( "SRA" )
					dbSetOrder( 1 )
					If dbSeek( xFilial( "SRA" ) + TN6->TN6_MAT) .And. ;
					   			TN6->TN6_DTINIC <= dDatabase 	.And. ;
					   			( TN6->TN6_DTTERM >= dDatabase 	.Or. Empty( TN6->TN6_DTTERM ) )

						If fConsistFunc()
							If aScan( aFuncRisco , { | x | x[ 1 ] == SRA->RA_MAT } ) == 0
								aAdd( aFuncRisco , { SRA->RA_MAT , SRA->RA_NOME } )
								lExist := .T.
							Endif
						EndIf

					EndIf
					dbSelectArea( "TN6" )
					dbSkip()
				End
			EndIf
			lRet := .F.
		Else
			lRet	:= .T.
			nInd	:= 7 //Ordenar pelo Codigo da Funcao
			cSeek	:= TN0->TN0_CODFUN
			cField	:= "SRA->RA_CODFUNC"
		EndIf
	Else
		lRet	:= .T.
		nInd	:= 2 //Ordenar pelo Codigo do Centro de Custo
		cSeek	:= TN0->TN0_CC
		cField	:= "SRA->RA_CC"
	EndIf

	If lRet
		dbSelectArea( "SRA" )
		dbSetOrder( nInd )
		dbSeek( xFilial( "SRA" ) + cSeek , .T. )
		While SRA->( !EoF() ) .And. xFilial( "SRA" ) == SRA->RA_FILIAL .And. &cField == cSeek
			If !fConsistFunc()
				dbSelectArea( "SRA" )
				dbSkip()
				Loop
			EndIf
			lFunc := .f.
			If nInd == 7
				If Alltrim( TN0->TN0_CODTAR ) == "*"
					If aScan( aFuncRisco , { | x | x[ 1 ] == SRA->RA_MAT } ) == 0
						aAdd( aFuncRisco , { SRA->RA_MAT , SRA->RA_NOME } )
						lExist := .T.
					Endif
					dbSelectArea( "SRA" )
					dbSkip()
					Loop
				Else
					lFunc := .T.
				EndIf
			Else
				If SRA->RA_CODFUNC == TN0->TN0_CODFUN .Or. AllTrim( TN0->TN0_CODFUN ) == "*"
					If AllTrim( TN0->TN0_CODTAR ) == "*"
						If aScan( aFuncRisco , { | x | x[ 1 ] == SRA->RA_MAT } ) == 0
							aAdd( aFuncRisco , { SRA->RA_MAT , SRA->RA_NOME } )
							lExist := .T.
						Endif
						dbSelectArea( "SRA" )
						dbSkip()
						Loop
					Else
						lFunc := .T.
					EndIf
				EndIf
			EndIf

			If lFunc
				dbSelectArea( "TN6" )
				dbSetOrder( 1 )
				dbSeek( xFilial( "TN6" ) + TN0->TN0_CODTAR + SRA->RA_MAT )
				While TN6->( !EoF() ) .And. xFilial( "TN6" ) == TN6->TN6_FILIAL .And.;
				      TN6->TN6_MAT == SRA->RA_MAT .And. TN6->TN6_CODTAR == TN0->TN0_CODTAR

					If fConsistFunc()
						If aScan( aFuncRisco , { | x | x[ 1 ] == SRA->RA_MAT } ) == 0
							aAdd( aFuncRisco , { SRA->RA_MAT , SRA->RA_NOME } )
							lExist := .t.
						Endif
						Exit
					EndIf
					dbSelectArea( "TN6" )
					dbSkip()
				End

			EndIf

			dbSelectArea( "SRA" )
			dbSkip()
		End
	EndIf

Return lExist
//---------------------------------------------------------------------
/*/{Protheus.doc} fSesmt
Imprimi os componentes do Sesmt

@return Sempre Verdadeiro

@sample fSesmt()

@author Jackson Machado
@since 29/09/2014
/*/
//---------------------------------------------------------------------
Static Function fSesmt()

	//Contadores
	Local nFor
	Local nMedTrab := 0, nEnfTrab := 0, nAuxTrab := 0
	Local nEngSeg := 0, nTecSeg := 0, nMedico := 0
	Local nEnferm := 0, nAuxEnf := 0

	//Array de Componentes
	Local aSesmt := {}
	Local aArea := GetArea()

	dbSelectArea( "TMK" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "TMK" ) )
	While TMK->( !Eof() ) .And. xFilial( "TMK" ) == TMK->TMK_FILIAL
		If TMK->TMK_SESMT == "2"//Não computa quando Usuário não fizer parte do SESMT
			dbSelectArea( "TMK" )
			dbSkip()
			Loop
		Endif

		//Separa pelas Funções
		If TMK->TMK_INDFUN == "1"
			nMedTrab ++
		ElseIf TMK->TMK_INDFUN == "2"
			nEnfTrab ++
		ElseIf TMK->TMK_INDFUN == "3"
			nAuxTrab ++
		ElseIf TMK->TMK_INDFUN == "4"
			nEngSeg ++
		ElseIf TMK->TMK_INDFUN == "5"
			nTecSeg ++
		Endif

		dbSelectArea("TMK")
		dbSkip()
	End

	nCSesmt	:= 0
	cMemo	:= ""

	//Realiza a impressão da Quantidade por Função
	If nMedTrab > 0
		nCSesmt++
		cMemo += STR0096 + "#*" //"Médicos do Trabalho"
		cMemo += AllTrim( Str( nMedTrab , 3 ) )+"#*"
		If mv_par03 == 1
			fImpDoc856( STR0097 + AllTrim( Str( nMedTrab , 3 ) ) ) //"Médicos do Trabalho: "
		Endif
		aAdd( aSesmt , { STR0096 , nMedTrab } ) //"Médicos do Trabalho"
	Endif
	If nEnfTrab > 0
		nCSesmt++
		cMemo += STR0098+"#*" //"Enfermeiros do Trabalho"
		cMemo += AllTrim( Str( nEnfTrab , 3 ) )+"#*"
		If mv_par03 == 1
			fImpDoc856( STR0099 + AllTrim( Str( nEnfTrab , 3 ) ) ) //"Enfermeiros do Trabalho: "
		Endif
		aAdd( aSesmt , { STR0098 , nEnfTrab } ) //"Enfermeiros do Trabalho"
	Endif
	If nAuxTrab > 0
		nCSesmt++
		cMemo += STR0100+"#*"  //"Auxiliares de Enfermagem do Trabalho"
		cMemo += AllTrim( Str( nAuxTrab , 3 ) ) + "#*"
		If mv_par03 == 1
			fImpDoc856( STR0101 + AllTrim( Str( nAuxTrab , 3 ) ) ) //"Auxiliares de Enfermagem do Trabalho: "
		Endif
		aAdd( aSesmt , { STR0100 , nAuxTrab } ) //"Auxiliares de Enfermagem do Trabalho"
	Endif
	If nEngSeg > 0
		nCSesmt++
		cMemo += STR0102+"#*" //"Engenheiros de Segurança do Trabalho"
		cMemo += AllTrim( Str( nEngSeg , 3 ) ) + "#*"
		If mv_par03 == 1
			fImpDoc856( STR0103 + AllTrim( Str( nEngSeg , 3 ) ) ) //"Engenheiros de Segurança do Trabalho: "
		Endif
		aAdd( aSesmt , { STR0102 , nEngSeg } ) //"Engenheiros de Segurança do Trabalho"
	Endif
	If nTecSeg > 0
		nCSesmt++
		cMemo += STR0104+"#*" //"Técnicos de Segurança do Trabalho"
		cMemo += Alltrim( Str( nTecSeg , 3 ) ) + "#*"
		If mv_par03 == 1
			fImpDoc856( STR0105 + AllTrim( Str( nTecSeg , 3 ) ) ) //"Técnicos de Segurança do Trabalho: "
		Endif
		aAdd( aSesmt , { STR0104 , nTecSeg } ) //"Técnicos de Segurança do Trabalho"
	Endif

	//Realiza a impressão da tabela quanto relatório não for Padrão
	If nCSesmt > 0
		//Para realatório Word, atribui os valores nas variáveis de documento
		//e executa a macro Table_Sesmt
		If mv_par03 == 3
			OLE_ExecuteMacro( oWord , "Somalinha" )
			OLE_ExecuteMacro( oWord , "Somalinha" )
			OLE_SetDocumentVar( oWord,"Tabela" , cMemo )
			OLE_SetDocumentVar( oWord,"Linhas" , nCSesmt )
			OLE_ExecuteMacro( oWord , "Table_Sesmt" )
			OLE_ExecuteMacro( oWord , "Somalinha" )
			OLE_ExecuteMacro( oWord , "Somalinha" )

		//Para relatório Gráfico realiza a impressão de linha por linha
		//executando a criação do Box de contorno
		ElseIf mv_par03 == 2 .and. Len(aSesmt) > 0
			aSort( aSesmt , , , { | x , y | x[ 1 ] < y[ 1 ] } )
			//Força salto de página quando próximo do final da página
			If lin + 420 > 3000
				lin := 9999
			Endif

			//Percorre todos os componentes
			For nFor := 1 To Len( aSesmt )
				If nFor == 1 //Caso for a primeira execução, realiza a impressão do cabeçalho
					Somalinha()
					oPrintErg:Box( lin , 150 , lin + 120 , 2300 )
					oPrintErg:Line( lin + 60 , 150 , lin + 60 , 2300 )
					oPrintErg:Line( lin + 60 , 1580 , lin + 120 , 1580 )
					oPrintErg:Say( lin + 5 , 800 , STR0106 , oFont12b ) //"QUADRO DE COMPONENTES DO SESMT"
					Somalinha()
					oPrintErg:Say( lin + 10 , 810 , STR0025 , oFont10b ) //"Função"
					oPrintErg:Say( lin + 10 , 1820 , STR0107 , oFont10b ) //"Quantidade"
				Endif
				Somalinha()
		        If lin == 300
					oPrintErg:Line( lin , 150 , lin , 2300 )
				Endif
				oPrintErg:Line( lin + 60 , 150 , lin + 60 , 2300 )
				oPrintErg:Line( lin , 150 , lin + 60 , 150 )
				oPrintErg:Line( lin , 1580 , lin + 60 , 1580 )
				oPrintErg:Line( lin , 2300 , lin + 60 , 2300 )
				oPrintErg:Say( lin + 10 , 170 , aSesmt[ nFor , 1 ] , oFont10 )
				oPrintErg:Say( lin + 10 , 1930 , Alltrim( Str( aSesmt[ nFor , 2 ] , 6 ) ) , oFont10 )
			Next nFor
		Endif
	Else
		//Caso não possua nenhum componente para impressão, deixa um espaço em branco
		If mv_par03 == 3
			OLE_ExecuteMacro( oWord , "Somalinha" )
			OLE_ExecuteMacro( oWord , "Somalinha" )
		Endif
	Endif

	RestArea( aArea )

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fFuncoes
Imprime Listagem de Funções

@return Sempre Verdadeiro

@sample fFuncoes()

@author Jackson Machado
@since 29/09/2014
/*/
//---------------------------------------------------------------------
Static Function fFuncoes()

	Local aArea    := GetArea()
	Local lGrava := .F.
	Local aFuncoes := {}
	Local i

	dbSelectarea( "SRJ" )
	dbSetOrder( 3 )
	dbGoTop()
	While SRJ->( !EoF() ) .And. xFilial( "SRJ" ) == SRJ->RJ_FILIAL

		Dbselectarea( "SRA" )
		Dbsetorder( 7 )
		Dbseek( xFilial( "SRA" ) + SRJ->RJ_FUNCAO )
		While SRA->( !EoF() ) .And. xFilial( "SRA" ) + SRJ->RJ_FUNCAO == SRA->RA_FILIAL + SRA->RA_CODFUNC

			//Verifica se não esta demitido nem admitido posterior ao laudo e se está no array
			If !fConsistFunc()
				dbSelectArea( "SRA" )
				Dbskip()
				Loop
			EndIf
			If aScan(aFuncoes,{|x| x[1] == SRJ->RJ_FUNCAO}) == 0
				dbSelectArea("SRJ")
				aAdd( aFuncoes , { 	SRJ->RJ_FUNCAO , ;
									SRJ->RJ_DESC , ;
									If( ( SRJ->( FieldPos( "RJ_MEMOATI" ) ) > 0 ) , ;
									SRJ->RJ_MEMOATI , ;
									( NgSeek( "SQ3" , SRJ->RJ_CARGO , 1 , "MSMM(SQ3->Q3_DESCDET)" ) ) ) } )

			EndIf
			dbSelectArea( "SRA" )
			dbSkip()
		End

		dbSelectArea("SRJ")
		dbSkip()
		Loop
	End

	//Imprime caso tenha funções
	If Len( aFuncoes ) > 0
		For i := 1 To Len( aFuncoes )
			fImpHea856( "{NS}" + aFuncoes[ i , 2 ] )
			If mv_par03 == 3
				OLE_ExecuteMacro( oWord , "Somalinha" )
			EndIf

			lIdentar := .f.

			fImpDoc856( STR0108 + aFuncoes[ i , 3 ] ) //"Objetivo do Cargo: "

			If mv_par03 == 2
				Somalinha()
			EndIf
		Next i
	EndIf

	If mv_par03 == 1
		Somalinha()
	ElseIf mv_par03 == 3
		OLE_ExecuteMacro( oWord , "Somalinha" )
		OLE_ExecuteMacro( oWord , "Somalinha" )
	Endif

	dbSelectArea( "SRJ" )
	dbSetOrder( 1 )

	RestArea( aArea )

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fFuncFun
Imprime Listagem de Funcionários por Funções

@return Sempre Verdadeiro

@sample fFuncFun()

@author Jackson Machado
@since 29/09/2014
/*/
//---------------------------------------------------------------------
Static Function fFuncFun()

	Local nFor
	Local nContFun	:= 0
	Local nContTOT	:= 0
	Local nRegs		:= 0
	Local cMemo		:= ""
	Local lFirst	:= .T.
	Local aFunMod3	:= {}
	Local aArea		:= GetArea()

	dbSelectArea( "SRJ" )
	dbSetOrder( 3 )
	dbSeek( xFilial( "SRJ" ) )
	While SRJ->( !EoF() ) .And. xFilial( "SRJ" ) == SRJ->RJ_FILIAL
		nContFun := 0
		dbSelectArea( "SRA" )
		dbSetOrder( 7 )
		dbSeek( xFilial( "SRA" ) + SRJ->RJ_FUNCAO )
		While SRJ->( !EoF() ) .and. xFilial("SRA")+SRJ->RJ_FUNCAO == SRA->RA_FILIAL+SRA->RA_CODFUNC
			// busca transferidos e afastados dentro da vigencia e fora. considerando ou nao.
			If !fConsistFunc()
				dbSelectArea( "SRA" )
				dbSkip()
				Loop
			EndIf
			nContFun++
			dbSelectArea( "SRA" )
			dbSkip()
		End
		dbSelectArea( "SRA" )
		dbSetOrder( 1 )
		If nContFun > 0
			nContTOT += nContFun
			nRegs++
			If mv_par03 == 1
				If lFirst
					Somalinha()
					@ Li , 000 Psay STR0109 //"Funcionários x Função: Função                                   Qtde. Funcionários"
					lFirst := .F.
				Endif
				Somalinha()
				@ Li , 023 Psay SubStr( SRJ->RJ_DESC , 1  , 35 )
				@ Li , 074 Psay nContFun Picture "99999999"
			ElseIf mv_par03 == 2
				aAdd( aFunMod3 , { SRJ->RJ_DESC , Str( nContFun , 7 ) } )
			Else
				cMemo += SRJ->RJ_DESC + "#*"
				cMemo += Str( nContFun , 7 ) + "#*"
			Endif
		Endif

		dbSelectArea( "SRJ" )
		dbSkip()
	End


	If nRegs > 0
		If mv_par03 == 1
			Somalinha()
			@ Li , 023 Psay STR0110 //"Total"
			@ Li , 074 Psay nContTOT Picture "99999999"
		ElseIf mv_par03 == 2
			For nFor := 1 To Len( aFunMod3 )
				If nFor == 1
					If lin+120 > 3000
						lin := 9999
					Endif
					Somalinha()
					oPrintErg:Line( lin , 150 , lin , 1500 )
					oPrintErg:Line( lin + 60 , 150 , lin + 60 , 1500 )
					oPrintErg:Line( lin , 150 , lin + 60 , 150 )
					oPrintErg:Say( lin + 10 , 550 , STR0025 , oFont08b ) //"Função"
					oPrintErg:Line( lin , 1000 , lin + 60 , 1000 )
					oPrintErg:Say( lin + 10 , 1025 , STR0111 , oFont08b ) //"Número de Trabalhadores"
					oPrintErg:Line( lin , 1500 , lin + 60 , 1500 )
				Endif
				Somalinha()
				If lin == 300
					oPrintErg:Line( lin , 150 , lin , 1500 )
				Endif
				oPrintErg:Line( lin + 60 , 150 , lin + 60 , 1500 )
				oPrintErg:Line( lin , 150 , lin + 60 , 150 )
				oPrintErg:Say( lin + 10 , 160 , aFunMod3[ nFor , 1 ] , oFont08 )
				oPrintErg:Line( lin , 1000 , lin + 60 , 1000 )
				oPrintErg:Say( lin + 10 , 1480 , aFunMod3[ nFor , 2 ] , oFont08 , , , , 1 )
				oPrintErg:Line( lin,1500,lin+60,1500)
				If nFor == Len( aFunMod3 )
					Somalinha()
					If lin == 300
						oPrintErg:Line( lin , 150 , lin , 1500 )
					Endif
					oPrintErg:Line( lin + 60 , 150 , lin + 60 , 1500 )
					oPrintErg:Line( lin , 150 , lin + 60 , 150 )
					oPrintErg:Say( lin + 10 , 160 , STR0110 , oFont08b ) //"TOTAL"
					oPrintErg:Line( lin , 1000 , lin + 60 , 1000 )
					oPrintErg:Say( lin + 10 , 1480 , Str( nContTOT , 7 ) , oFont08 , , , , 1 )
					oPrintErg:Line( lin , 1500 , lin + 60 , 1500 )
				Endif
			Next nFor
		Else
			cMemo += STR0110 + "#*" //"Total"
			cMemo += Str( nContTOT , 7 ) + "#*"
			nRegs++

			OLE_ExecuteMacro( oWord , "Somalinha" )
			OLE_ExecuteMacro( oWord , "Somalinha" )
			OLE_SetDocumentVar( oWord , "Tabela" , cMemo )
			OLE_SetDocumentVar( oWord , "Linhas" , nRegs )
			OLE_ExecuteMacro( oWord , "Table_Funcionario" )
			OLE_ExecuteMacro( oWord , "Somalinha" )
			OLE_ExecuteMacro( oWord , "Somalinha" )
		Endif
	Else
		If mv_par03 == 3
			OLE_ExecuteMacro( oWord , "Somalinha" )
			OLE_ExecuteMacro( oWord , "Somalinha" )
		Else
			Somalinha()
		Endif
	EndIf

	dbSelectArea( "SRJ" )
	dbSetOrder( 1 )

	RestArea( aArea )

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fQdrAgente
Imprime um quadro com os agentes e fontes por Centro de Custo

@return Sempre Verdadeiro

@sample fQdrAgente()

@author Jackson Machado
@since 29/09/2014
/*/
//---------------------------------------------------------------------
Static Function fQdrAgente()

	Local i
	Local nLinha, nLinhasMemo
	Local nRisc 	:= 0, nRegs := 0
	Local cAgente	:= "", cFonte := "", cMemo := ""
	Local aRiscos	:= aClone( aRiscErg )

	//Ordena os riscos pelo agente
	aSort( aRiscos , , , { | x , y | x[ 8 ] + x[ 10 ] < y[ 8 ] + y[ 10 ] } )

	For nRisc := 1 To Len( aRiscos )
		If cAgente <> aRiscos[ nRisc , 8 ] .And. cFonte <> aRiscos[ nRisc , 11 ]
			cAgente := aRiscos[ nRisc , 8 ]
			cFonte := aRiscos[ nRisc , 11 ]
			dbSelectArea( "TMA" )
			dbSetOrder( 1 )
			dbSeek( xFilial( "TMA" ) + aRiscos[ nRisc , 8 ] )

			dbSelectArea( "TN7" )
			dbSetOrder( 1 )
			dbSeek( xFilial( "TN7" ) + aRiscos[ nRisc , 10 ] )

			If mv_par03 == 1
				SomaLinha()
				@ Li , 001 PSay STR0075 + ": " + aRiscos[ nRisc , 9 ] //"Agente"
				SomaLinha()
				@ Li , 001 PSay STR0023 + ": " + aRiscos[ nRisc , 11 ] //"Fonte Geradora"
				nTamanho    := 100 - Len( STR0112 + ": " ) //"Patologia"
				cPatologia := MsMM( TMA->TMA_PATSYP , 80 )
				nLinhasMemo := MlCount( cPatologia , nTamanho )
				//Percorre o memo e realiza a impressão linear
				For i := 1 To nLinhasMemo
					If i == 1
						SomaLinha()
						@ Li , 001 PSay STR0112 + ": " //"Patologia"
					Else
						SomaLinha()
					EndIf
					@ Li , 000 + Len( STR0112 + ": " ) PSay MemoLine( cPatologia , nTamanho , i ) //"Patologia"
				Next i

				nTamanho    := 100 - Len( STR0113 + ": " ) //"Sintomatologia"
				cSintomato := MsMM( TMA->TMA_SINSYP , 80 )
				nLinhasMemo := MlCount( cSintomato , nTamanho )
				//Percorre o memo e realiza a impressão linear
				For i := 1 To nLinhasMemo
					If i == 1
						SomaLinha()
						@ Li , 001 PSay STR0113 + ": " //"Sintomatologia"
					Else
						SomaLinha()
					EndIf
					@ Li , 000 + Len( STR0113 + ": " ) PSay MemoLine( cSintomato , nTamanho , i ) //"Sintomatologia"
				Next i
			ElseIf mv_par03 == 2
				If nRisc == 1
					Somalinha( , .T.)
					oPrintErg:Box( lin , 0150 , lin + 60 , 2300 )
					oPrintErg:Line( lin , 0600 , lin + 60 , 0600 )
					oPrintErg:Line( lin , 1000 , lin + 60 , 1000 )
					oPrintErg:Line( lin , 1650 , lin + 60 , 1650 )
					oPrintErg:Say( lin + 10 , 0375 , STR0075 , oFont08b , , , , 2 ) //"Agente"
					oPrintErg:Say( lin + 10 , 0800 , STR0114 , oFont08b , , , , 2 ) //"Fonte"
					oPrintErg:Say( lin + 10 , 1325 , STR0112 , oFont08b , , , , 2 ) //"Patologia"
					oPrintErg:Say( lin + 10 , 1975 , STR0113 , oFont08b , , , , 2 ) //"Sintomatologia"

					cAgente		:= aRiscos[ nRisc , 9 ]
					cFonte		:= aRiscos[ nRisc , 11 ]
					cPatologia 	:= MsMM( TMA->TMA_PATSYP , 80 )
					cSintomato 	:= MsMM( TMA->TMA_SINSYP , 80 )

					nLimFor := MlCount( cAgente , 20 )
					nLimFor := If( nLimFor > MlCount( cFonte , 20 ) , nLimFor , MlCount( cFonte , 20 ) )
					nLimFor := If( nLimFor > MlCount( cPatologia , 40 ) , nLimFor , MlCount( cPatologia , 40 ) )
					nLimFor := If( nLimFor > MlCount( cSintomato , 40 ) , nLimFor , MlCount( cSintomato , 40 ) )

					For i := 1 To nLimFor
						Somalinha( , .T.)
						oPrintErg:Line( lin , 0150 , lin + 60 , 0150 )
						oPrintErg:Line( lin , 0600 , lin + 60 , 0600 )
						oPrintErg:Line( lin , 1000 , lin + 60 , 1000 )
						oPrintErg:Line( lin , 1650 , lin + 60 , 1650 )
						oPrintErg:Line( lin , 2300 , lin + 60 , 2300 )
						If !Empty( MemoLine( cAgente , 20 , i ) )
							oPrintErg:Say( lin + 10 , 170 , MemoLine( cAgente , 20 , i ) , oFont08 )
						EndIf
						If !Empty( MemoLine( cFonte , 20 , i ) )
							oPrintErg:Say( lin + 10 , 620 , MemoLine( cFonte , 20 , i ) , oFont08 )
						EndIf
						If !Empty( MemoLine( cPatologia , 40 , i ) )
							oPrintErg:Say( lin + 10 , 1020 , MemoLine( cPatologia , 40 , i ) , oFont08 )
						EndIf
						If !Empty( MemoLine( cSintomato , 40 , i ) )
							oPrintErg:Say( lin + 10 , 1670 , MemoLine( cSintomato , 40 , i ) , oFont08 )
						EndIf
					Next i
					oPrintErg:Line( lin + 60 , 150 , lin + 60 , 2300 )
				EndIf
			Else
				cMemo += aRiscos[ nRisc , 9 ] + "#*"
				cMemo += aRiscos[ nRisc , 11 ] + "#*"
				cMemo += AllTrim( MsMM( TMA->TMA_PATSYP , 80 ) ) + "#*"
				cMemo += AllTrim( MsMM( TMA->TMA_SINSYP , 80 ) ) + "#*"
				nRegs++
			EndIf
		EndIf
	Next nRisc

	If mv_par03 == 3 .And. nRegs > 0
		OLE_ExecuteMacro( oWord , "Somalinha" )
		OLE_ExecuteMacro( oWord , "Somalinha" )
		OLE_SetDocumentVar( oWord , "Tabela" , cMemo )
		OLE_SetDocumentVar( oWord , "Linhas" , nRegs )
		OLE_ExecuteMacro( oWord , "Quadro_Agente" )
		OLE_ExecuteMacro( oWord , "Somalinha" )
		OLE_ExecuteMacro( oWord , "Somalinha" )
	Else
		Somalinha()
	EndIf

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fFunTar
Imprime um quadro com as funções e tarefas por centro de custo

@return Sempre Verdadeiro

@sample fFunTar()

@author Jackson Machado
@since 29/09/2014
/*/
//---------------------------------------------------------------------
Static Function fFunTar()

	Local i
	Local nFun, nTar
	Local nPosCC, nPosFun, nPosTar
	Local nImp1, nImp2, nImp3
	Local nRisc 	:= 0, nRegs := 0
	Local nCorte	:= 25
	Local cMemo 	:= "", cCusto := "", cFuncao := "", cTarefa := ""
	Local cFunImp	:= ""
	Local lAllCTT	:= .T.
	Local aRiscos	:= aClone( aRiscErg )
	Local aRisImp	:= {}

	//Ordena os riscos pelo agente
	aSort( aRiscos , , , { | x , y | x[ 2 ] + x[ 4 ] + x[ 6 ] < y[ 2 ] + y[ 4 ] + y[ 6 ] } )

	For nRisc := 1 To Len( aRiscos )
		If AllTrim( aRiscos[ nRisc , 2 ] ) <> "*"
			If ( nPosCC := aScan( aRisImp , { | x | x[ 1 ] == aRiscos[ nRisc , 2 ] } ) ) == 0
				aAdd( aRisImp , { aRiscos[ nRisc , 2 ] , {} } )
				nPosCC := Len( aRisImp )
			EndIf
			If AllTrim( aRiscos[ nRisc , 4 ] ) == "*"
				dbSelectArea( "SRJ" )
				dbSetOrder( 1 )
				dbSeek( xFilial( "SRJ" ) )
				While SRJ->( !Eof() ) .And. SRJ->RJ_FILIAL == xFilial( "SRJ" )
					If ( nPosFun := aScan( aRisImp , { | x | x[ nPosCC , 2 , 1 ] == SRJ->RJ_FUNCAO } ) ) == 0
						aAdd( aRisImp[ nPosCC , 2 ] , { SRJ->RJ_FUNCAO , {} } )
						nPosFun := Len( aRisImp[ nPosCC , 2 ] )
					EndIf

					aTarTemp := aClone( aRisImp[ nPosCC , 2 , nPosFun , 2 ] )

					If AllTrim( aRiscos[ nRisc , 6 ] ) == "*"
						dbSelectArea( "TN5" )
						dbSetOrder( 1 )
						dbSeek( xFilial( "TN5" ) )
						While TN5->( !Eof() ) .And. TN5->TN5_FILIAL == xFilial( "TN5" )
							If ( nPosTar := aScan( aTarTemp , { | x | x == TN5->TN5_CODTAR } ) ) == 0
								aAdd( aRisImp[ nPosCC , 2 , nPosFun , 2 ] , TN5->TN5_CODTAR )
							EndIf
							TN5->( dbSkip() )
						End
					Else
						If ( nPosTar := aScan( aTarTemp , { | x | x == aRiscos[ nRisc , 6 ] } ) ) == 0
							aAdd( aRisImp[ nPosCC , 2 , nPosFun , 2 ] , aRiscos[ nRisc , 6 ] )
						EndIf
					EndIf

					SRJ->( dbSkip() )
				End
			Else
				aFuncTmp := aClone( aRisImp[ nPosCC , 2 ] )
				If ( nPosFun := aScan( aFuncTmp , { | x | x[ 1 ] == aRiscos[ nRisc , 4 ] } ) ) == 0
					aAdd( aRisImp[ nPosCC , 2 ] , { aRiscos[ nRisc , 4 ] , {} } )
					nPosFun := Len( aRisImp[ nPosCC , 2 ] )
				EndIf

				aTarTemp := aClone( aRisImp[ nPosCC , 2 , nPosFun , 2 ] )

				If AllTrim( aRiscos[ nRisc , 6 ] ) == "*"
					dbSelectArea( "TN5" )
					dbSetOrder( 1 )
					dbSeek( xFilial( "TN5" ) )
					While TN5->( !Eof() ) .And. TN5->TN5_FILIAL == xFilial( "TN5" )
						If ( nPosTar := aScan( aTarTemp , { | x | x == TN5->TN5_CODTAR } ) ) == 0
							aAdd( aRisImp[ nPosCC , 2 , nPosFun , 2 ] , TN5->TN5_CODTAR )
						EndIf
						TN5->( dbSkip() )
					End
				Else
					If ( nPosTar := aScan( aTarTemp , { | x | x == aRiscos[ nRisc , 6 ] } ) ) == 0
						aAdd( aRisImp[ nPosCC , 2 , nPosFun , 2 ] , aRiscos[ nRisc , 6 ] )
					EndIf
				EndIf
			EndIf
		Else
			If lAllCTT
				dbSelectArea( "CTT" )
				dbSetOrder( 1 )
				dbSeek( xFilial( "CTT" ) )
				While CTT->( !Eof() ) .And. CTT->CTT_FILIAL == xFilial( "CTT" )
					If aScan( aRisImp , { | x | x[ 1 ] == aRiscos[ nRisc , 2 ] } ) == 0
						aAdd( aRisImp , { aRiscos[ nRisc , 2 ] , {} } )
					EndIf
					CTT->( dbSkip() )
				End
			EndIf
			lAllCTT := .F.

			If AllTrim( aRiscos[ nRisc , 4 ] ) == "*"
				dbSelectArea( "SRJ" )
				dbSetOrder( 1 )
				dbSeek( xFilial( "SRJ" ) )
				While SRJ->( !Eof() ) .And. SRJ->RJ_FILIAL == xFilial( "SRJ" )

					For nFun := 1 To Len( aRisImp )
						aFuncTmp := aClone( aRisImp[ nFun , 2 ] )
						If ( nPosFun := aScan( aFuncTmp , { | x | x[ 1 ] == SRJ->RJ_FUNCAO } ) ) == 0
							aAdd( aRisImp[ nFun , 2 ] , { SRJ->RJ_FUNCAO , {} } )
							nPosFun := Len( aRisImp[ nFun , 2 ] )
						EndIf

						aTarTemp := aClone( aRisImp[ nFun , 2 , nPosFun , 2 ] )

						If AllTrim( aRiscos[ nRisc , 6 ] ) == "*"
							dbSelectArea( "TN5" )
							dbSetOrder( 1 )
							dbSeek( xFilial( "TN5" ) )
							While TN5->( !Eof() ) .And. TN5->TN5_FILIAL == xFilial( "TN5" )
								If ( nPosTar := aScan( aTarTemp , { | x | x == TN5->TN5_CODTAR } ) ) == 0
									aAdd( aRisImp[ nFun , 2 , nPosFun , 2 ] , TN5->TN5_CODTAR )
								EndIf
								TN5->( dbSkip() )
							End
						Else
							If ( nPosTar := aScan( aTarTemp , { | x | x == aRiscos[ nRisc , 6 ] } ) ) == 0
								aAdd( aRisImp[ nFun , 2 , nPosFun , 2 ] , aRiscos[ nRisc , 6 ] )
							EndIf
						EndIf
					Next nFun

					SRJ->( dbSkip() )
				End
			Else
				For nFun := 1 To Len( aRisImp )
					aFuncTmp := aClone( aRisImp[ nFun , 2 ] )
					If ( nPosFun := aScan( aFuncTmp , { | x | x[ 1 ] == aRiscos[ nRisc , 4 ] } ) ) == 0
						aAdd( aRisImp[ nFun , 2 ] , { aRiscos[ nRisc , 4 ] , {} } )
						nPosFun := Len( aRisImp[ nFun , 2 ] )
					EndIf

					aTarTemp := aClone( aRisImp[ nFun , 2 , nPosFun , 2 ] )

					If AllTrim( aRiscos[ nRisc , 6 ] ) == "*"
						dbSelectArea( "TN5" )
						dbSetOrder( 1 )
						dbSeek( xFilial( "TN5" ) )
						While TN5->( !Eof() ) .And. TN5->TN5_FILIAL == xFilial( "TN5" )
							If ( nPosTar := aScan( aTarTemp , { | x | x == TN5->TN5_CODTAR } ) ) == 0
								aAdd( aRisImp[ nFun , 2 , nPosFun , 2 ] , TN5->TN5_CODTAR )
							EndIf
							TN5->( dbSkip() )
						End
					Else
						If ( nPosTar := aScan( aTarTemp , { | x | x == aRiscos[ nRisc , 6 ] } ) ) == 0
							aAdd( aRisImp[ nFun , 2 , nPosFun , 2 ] , aRiscos[ nRisc , 6 ] )
						EndIf
					EndIf
				Next nFun
			EndIf
		EndIf
	Next nRisc

	If Len( aRisImp ) > 0
		If mv_par03 == 3
			For nImp1 := 1 To Len( aRisImp )
				nRegs	:= 0
				cMemo	:= ""
				cCusto	:= aRisImp[ nImp1 , 1 ]
				If AllTrim( cCusto ) == "*"
					cMemo += STR0124//"Todos"
				Else
					dbSelectArea( "CTT" )
					dbSetOrder( 1 )
					dbSeek( xFilial( "CTT" ) + cCusto )
					cMemo += Upper( STR0024 ) + ": " + AllTrim( cCusto ) + " - " + Capital( CTT->CTT_DESC01 ) + "#*" + "#*" + "#*" + "#*" + "#*" //"Centro de Custo"
				EndIf

				cMemo += 	Upper( STR0025 ) + "#*" + ; //"Função"
							Upper( STR0077 ) + "#*" + ; //"Tarefa"
							Upper( STR0115 ) + "#*" + ; //"Descrição"
							Upper( STR0116 ) + "#*" + ; //"Tempo"
							Upper( STR0117 ) + "#*" //"Vestimenta"
				nRegs++
				For nImp2 := 1 To Len( aRisImp[ nImp1 , 2 ] )
					cFuncao := aRisImp[ nImp1 , 2 , nImp2 , 1 ]
					dbSelectArea( "SRJ" )
					dbSetOrder( 1 )
					dbSeek( xFilial( "SRJ" ) + cFuncao )
					cFunImp := AllTrim( cFuncao ) + " - " + Capital( SRJ->RJ_DESC ) + "#*"

					For nImp3 := 1 To Len( aRisImp[ nImp1 , 2 , nImp2 , 2 ] )
						cTarefa := aRisImp[ nImp1 , 2 , nImp2 , 2 , nImp3 ]

						cMemo += cFunImp
						dbSelectArea( "TN5" )
						dbSetOrder( 1 )
						dbSeek( xFilial( "TN5" ) + cTarefa )

						cMemo += AllTrim( cTarefa ) + " - " + AllTrim( Capital( TN5->TN5_NOMTAR ) ) + "#*"
						If TN5->( FieldPos( "TN5_DESCRI" ) ) > 0
							cMemo += Capital( TN5->TN5_DESCRI ) + "#*"
						Else
							cMemo += AllTrim( Capital( TN5->TN5_DESTAR + TN5->TN5_DESCR1 + TN5->TN5_DESCR2 + TN5->TN5_DESCR3 + TN5->TN5_DESCR4 ) ) + "#*"
						EndIf
						cMemo += TN5->TN5_HRDIA + "#*"
						cMemo += AllTrim( MsMM( TN5->TN5_VESSYP , 80 ) ) + "#*"

						nRegs++
					Next nImp3
				Next nImp2
				OLE_ExecuteMacro( oWord , "Somalinha" )
				OLE_ExecuteMacro( oWord , "Somalinha" )
				OLE_SetDocumentVar( oWord , "Tabela" , cMemo )
				OLE_SetDocumentVar( oWord , "Linhas" , nRegs )
				OLE_ExecuteMacro( oWord , "Funcao_Tarefa" )
				OLE_ExecuteMacro( oWord , "Somalinha" )
				OLE_ExecuteMacro( oWord , "Somalinha" )
			Next nImp1
		ElseIf mv_par03 == 2
			For nImp1 := 1 To Len( aRisImp )
				nRegs	:= 0
				cMemo	:= ""
				cCusto	:= aRisImp[ nImp1 , 1 ]
				dbSelectArea( "CTT" )
				dbSetOrder( 1 )
				dbSeek( xFilial( "CTT" ) + cCusto )
				Somalinha()
				oPrintErg:Box( lin , 150 , lin + 60 , 2300 )
				If AllTrim( cCusto ) == "*"
					oPrintErg:Say( lin + 10 , 175 , Upper( STR0024 ) + ": " + STR0124 , oFont08b ) //"Todos"
				Else
					oPrintErg:Say( lin + 10 , 175 , Upper( STR0024 ) + ": " + AllTrim( cCusto ) + " - " + Capital( CTT->CTT_DESC01 ) , oFont08b ) //"Centro de Custo"
				EndIf
				Somalinha( , .T.)
				oPrintErg:Line( lin + 60 , 150 , lin + 60 , 2300 )
				oPrintErg:Line( lin , 0150 , lin + 60 , 0150 )
				oPrintErg:Line( lin , 0580 , lin + 60 , 0580 )
				oPrintErg:Line( lin , 1010 , lin + 60 , 1010 )
				oPrintErg:Line( lin , 1440 , lin + 60 , 1440 )
				oPrintErg:Line( lin , 1870 , lin + 60 , 1870 )
				oPrintErg:Line( lin , 2300 , lin + 60 , 2300 )
				oPrintErg:Say( lin + 10 , 0365 , STR0025 , oFont08b , , , , 2 ) //"Função"
				oPrintErg:Say( lin + 10 , 0795 , STR0077 , oFont08b , , , , 2 ) //"Tarefa"
				oPrintErg:Say( lin + 10 , 1225 , STR0115 , oFont08b , , , , 2 ) //"Descrição"
				oPrintErg:Say( lin + 10 , 1655 , STR0118 , oFont08b , , , , 2 ) //"Hora"
				oPrintErg:Say( lin + 10 , 2085 , STR0119 , oFont08b , , , , 2 ) //"Vestimentas"
				For nImp2 := 1 To Len( aRisImp[ nImp1 , 2 ] )
					cFuncao := aRisImp[ nImp1 , 2 , nImp2 , 1 ]
					dbSelectArea( "SRJ" )
					dbSetOrder( 1 )
					dbSeek( xFilial( "SRJ" ) + cFuncao )
					cFunImp := AllTrim( cFuncao ) + " - " + AllTrim( Capital( SRJ->RJ_DESC ) )
					nLimFun := MlCount( cFunImp , nCorte )
					nCntFun := 0

					For nImp3 := 1 To Len( aRisImp[ nImp1 , 2 , nImp2 , 2 ] )
						cTarefa := aRisImp[ nImp1 , 2 , nImp2 , 2 , nImp3 ]
						dbSelectArea( "TN5" )
						dbSetOrder( 1 )
						dbSeek( xFilial( "TN5" ) + cTarefa )

						cTarefa := AllTrim( cTarefa ) + " - " + AllTrim( Capital( TN5->TN5_NOMTAR ) )
						If TN5->( FieldPos( "TN5_DESCRI" ) ) > 0
							cDescri := Capital( TN5->TN5_DESCRI )
						Else
							cDescri := AllTrim( Capital( TN5->TN5_DESTAR + TN5->TN5_DESCR1 + TN5->TN5_DESCR2 + TN5->TN5_DESCR3 + TN5->TN5_DESCR4 ) )
						EndIf
						cHora := TN5->TN5_HRDIA
						cVestim := AllTrim( MsMM( TN5->TN5_VESSYP , 80 ) )

						nLimFor := MlCount( cTarefa , nCorte )
						nLimFor := If( nLimFor > MlCount( cDescri , nCorte ) , nLimFor , MlCount( cDescri , nCorte ) )
						nLimFor := If( nLimFor > MlCount( cHora , nCorte ) , nLimFor , MlCount( cHora , nCorte ) )
						nLimFor := If( nLimFor > MlCount( cVestim , nCorte ) , nLimFor , MlCount( cVestim , nCorte ) )

						For i := 1 To nLimFor
							Somalinha( , .T.)
							oPrintErg:Line( lin , 0150 , lin + 60 , 0150 )
							oPrintErg:Line( lin , 0580 , lin + 60 , 0580 )
							oPrintErg:Line( lin , 1010 , lin + 60 , 1010 )
							oPrintErg:Line( lin , 1440 , lin + 60 , 1440 )
							oPrintErg:Line( lin , 1870 , lin + 60 , 1870 )
							oPrintErg:Line( lin , 2300 , lin + 60 , 2300 )
							If nCntFun < nLimFun .And. !Empty( MemoLine( cFunImp , nCorte , nCntFun + 1 ) )
								nCntFun++
								oPrintErg:Say( lin + 10 , 170 , MemoLine( cFunImp , nCorte , nCntFun ) , oFont08 )
							EndIf
							If !Empty( MemoLine( cTarefa , nCorte , i ) )
								oPrintErg:Say( lin + 10 , 590 , MemoLine( cTarefa , nCorte , i ) , oFont08 )
							EndIf
							If !Empty( MemoLine( cDescri , nCorte , i ) )
								oPrintErg:Say( lin + 10 , 1030 , MemoLine( cDescri , nCorte , i ) , oFont08 )
							EndIf
							If !Empty( MemoLine( cHora , nCorte , i ) )
								oPrintErg:Say( lin + 10 , 1460 , MemoLine( cHora , nCorte , i ) , oFont08 )
							EndIf
							If !Empty( MemoLine( cVestim , nCorte , i ) )
								oPrintErg:Say( lin + 10 , 1890 , MemoLine( cVestim , nCorte , i ) , oFont08 )
							EndIf
						Next i
						If nImp3 <> Len( aRisImp[ nImp1 , 2 , nImp2 , 2 ] ) .Or. ;
							nLimFun < nCntFun
							oPrintErg:Line( lin + 60 , 580 , lin + 60 , 2300 )
						EndIf
					Next nImp3
					If nCntFun + 1 <= nLimFun
						For i := nCntFun + 1 To nLimFun
							If nCntFun <> nLimFun
								Somalinha( , .T.)
							EndIf
							oPrintErg:Line( lin , 0150 , lin + 60 , 0150 )
							oPrintErg:Line( lin , 0580 , lin + 60 , 0580 )
							oPrintErg:Line( lin , 1010 , lin + 60 , 1010 )
							oPrintErg:Line( lin , 1440 , lin + 60 , 1440 )
							oPrintErg:Line( lin , 1870 , lin + 60 , 1870 )
							oPrintErg:Line( lin , 2300 , lin + 60 , 2300 )
							If !Empty( MemoLine( cFunImp , nCorte , i ) )
								oPrintErg:Say( lin + 10 , 170 , MemoLine( cFunImp , nCorte , i ) , oFont08 )
								nCntFun++
							EndIf
						Next i
					EndIf
					oPrintErg:Line( lin + 60 , 150 , lin + 60 , 2300 )
				Next nImp2
			Next nImp1
		ElseIf mv_par03 == 1
			For nImp1 := 1 To Len( aRisImp )
				cCusto	:= aRisImp[ nImp1 , 1 ]
				dbSelectArea( "CTT" )
				dbSetOrder( 1 )
				dbSeek( xFilial( "CTT" ) + cCusto )
				SomaLinha()
				If AllTrim( cCusto ) == "*"
					@ Li , 001 PSay Upper( STR0024 ) + ": " + STR0124 //"Todos"
				Else
					@ Li , 001 PSay Upper( STR0024 ) + ": " + AllTrim( cCusto ) + " - " + Capital( CTT->CTT_DESC01 ) //"Centro de Custo"
				EndIf

				For nImp2 := 1 To Len( aRisImp[ nImp1 , 2 ] )
					cFuncao := aRisImp[ nImp1 , 2 , nImp2 , 1 ]
					dbSelectArea( "SRJ" )
					dbSetOrder( 1 )
					dbSeek( xFilial( "SRJ" ) + cFuncao )
					SomaLinha()
					@ Li , 015 PSay Upper( STR0025 ) + ": " + AllTrim( cFuncao ) + " - " + Capital( SRJ->RJ_DESC ) //"Função"

					For nImp3 := 1 To Len( aRisImp[ nImp1 , 2 , nImp2 , 2 ] )

						cTarefa := aRisImp[ nImp1 , 2 , nImp2 , 2 , nImp3 ]

						dbSelectArea( "TN5" )
						dbSetOrder( 1 )
						dbSeek( xFilial( "TN5" ) + cTarefa )

						SomaLinha()
						@ Li , 030 PSay Upper( STR0077 ) + ": " + AllTrim( cTarefa ) + " - " + SubStr( AllTrim( Capital( TN5->TN5_NOMTAR ) ) , 1 , 80 ) //"Tarefa"
						If TN5->( FieldPos( "TN5_DESCRI" ) ) > 0
							cMemo := Capital( TN5->TN5_DESCRI )
						Else
							cMemo := AllTrim( Capital( TN5->TN5_DESTAR + TN5->TN5_DESCR1 + TN5->TN5_DESCR2 + TN5->TN5_DESCR3 + TN5->TN5_DESCR4 ) )
						EndIf
						nTamanho    := 100 - Len( STR0115 + ": " ) //"Descrição"
						nLinhasMemo := MlCount( cMemo , nTamanho )
						//Percorre o memo e realiza a impressão linear
						For i := 1 To nLinhasMemo
							If i == 1
								SomaLinha()
								@ Li , 030 PSay STR0115 + ": " //"Descrição"
							Else
								SomaLinha()
							EndIf
							@ Li , 030 + Len( STR0115 + ": " ) PSay MemoLine( cMemo , nTamanho , i ) //"Descrição"
						Next i
						SomaLinha()
						@ Li , 030 PSay STR0116 + ": " + TN5->TN5_HRDIA //"Tempo"


						cVetimen := MsMM( TN5->TN5_VESSYP , 80 )
						nTamanho    := 100 - Len( STR0117 + ": " ) //"Vestimenta"
						nLinhasMemo := MlCount( cVetimen , nTamanho )
						//Percorre o memo e realiza a impressão linear
						For i := 1 To nLinhasMemo
							If i == 1
								SomaLinha()
								@ Li , 030 PSay STR0117 + ": " //"Vestimenta"
							Else
								SomaLinha()
							EndIf
							@ Li , 030 + Len( STR0117 + ": " ) PSay MemoLine( cVetimen , nTamanho , i ) //"Vestimenta"
						Next i
						If nImp3 <> Len( aRisImp[ nImp1 , 2 , nImp2 , 2 ] )
							SomaLinha()
						EndIf
					Next nImp3
				Next nImp2
			Next nImp1
			Somalinha()
		EndIf
	EndIf
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fAgeMed
Imprime um quadro com os agentes e medidas por centro de custo

@return Sempre Verdadeiro

@sample fAgeMed()

@author Jackson Machado
@since 29/09/2014
/*/
//---------------------------------------------------------------------
Static Function fAgeMed()

	Local i
	Local nRisc		:= 0, nRegs	:= 0, nAge := 0
	Local nPosCC	:= 0
	Local nCorte	:= 25
	Local cMemo 	:= "", cCusto := ""
	Local lAllCTT	:= .T.
	Local lMedida := .F.
	Local aAgentes	:= {}, aAgeImp := {}
	Local aRiscos	:= aClone( aRiscErg )

	//Ordena os riscos pelo agente
	aSort( aRiscos , , , { | x , y | x[ 1 ] + x[ 8 ]  < y[ 1 ] + x[ 8 ] } )

	For nRisc := 1 To Len( aRiscos )
		If aRiscos[ nRisc , 2 ] == "*"
			If lAllCTT
				dbSelectArea( "CTT" )
				dbSetOrder( 1 )
				dbSeek( xFilial( "CTT" ) )
				While CTT->( !Eof() ) .And. CTT->CTT_FILIAL == xFilial( "CTT" )
					If ( nPosCC := aScan( aAgentes , { | x | x[ 1 ] == aRiscos[ nRisc , 2 ] } ) ) == 0
						aAdd( aAgentes , { aRiscos[ nRisc , 2 ] , {} } )
						nPosCC := Len( aAgentes )
					EndIf
					aAdd( aAgentes[ nPosCC , 2 ] , aRiscos[ nRisc , 1 ] )
					CTT->( dbSkip() )
				End
			EndIf
			lAllCTT := .F.
		Else
			If ( nPosCC := aScan( aAgentes , { | x | x[ 1 ] == aRiscos[ nRisc , 2 ] } ) ) == 0
				aAdd( aAgentes , { aRiscos[ nRisc , 2 ] , {} } )
				nPosCC := Len( aAgentes )
			EndIf
			aAdd( aAgentes[ nPosCC , 2 ] , aRiscos[ nRisc , 1 ] )
		EndIf

	Next nRisc

	For nAge := 1 To Len( aAgentes )
		cMemo := ""
		nRegs := 0
		cCusto	:= aAgentes[ nAge , 1 ]
		dbSelectArea( "CTT" )
		dbSetOrder( 1 )
		dbSeek( xFilial( "CTT" ) + cCusto )

		If mv_par03 == 1
			SomaLinha()
			@ Li , 001 PSay Upper( STR0024 ) + ": " + AllTrim( cCusto ) + " - " + Capital( CTT->CTT_DESC01 ) //"Centro de Custo"
		ElseIf mv_par03 == 2
			Somalinha()
			oPrintErg:Box( lin , 150 , lin + 60 , 2300 )
			oPrintErg:Say( lin + 10 , 175 , Upper( STR0024 ) + ": " + AllTrim( cCusto ) + " - " + Capital( CTT->CTT_DESC01 ) , oFont08b ) //"Centro de Custo"
		Else
			cMemo += Upper( STR0024 ) + ": " + AllTrim( cCusto ) + " - " + Capital( CTT->CTT_DESC01 ) + "#*" + "#*" + "#*" + "#*" + "#*" //"Centro de Custo"

			cMemo += 	Upper( STR0075 ) + "#*" + ; //"Agente"
						Upper( STR0120 ) + "#*" + ; //"Situação Encontrada"
						Upper( STR0121 ) + "#*" + ; //"Situação Desejada"
						Upper( STR0122 ) + "#*" + ;  //"Situação Ergonômica"
						Upper( STR0123 ) + "#*" //"Medida(s) Aplicada(s)"
		EndIf

		nRegs++
		aAgeImp := aAgentes[ nAge , 2 ]
		For nRisc := 1 To Len( aAgeImp )
			dbSelectArea( "TN0" )
			dbSetOrder( 1 )
			dbSeek( xFilial( "TN0" ) + aAgeImp[ nRisc ] )

			dbSelectArea( "TMA" )
			dbSetOrder( 1 )
			dbSeek( xFilial( "TMA" ) + TN0->TN0_AGENTE )

			If mv_par03 == 1
				SomaLinha()
				@ Li , 015 PSay STR0075 + ": " + AllTrim( Capital( TMA->TMA_NOMAGE ) ) + " - " + TN0->TN0_NUMRIS //"Agente"
				//SomaLinha()
				cSituacao 	:= MsMM( TN0->TN0_SITSYP , 80 )
				If Empty( cSituacao )
					cSituacao := cValToChar( TN0->TN0_QTAGEN ) + TN0->TN0_UNIMED
				EndIf
				nTamanho    := 100 - Len( STR0120 + ": " ) //"Situação Encontrada"
				nLinhasMemo := MlCount( cSituacao , nTamanho )
				//Percorre o memo e realiza a impressão linear
				For i := 1 To nLinhasMemo
					If i == 1
						SomaLinha()
						@ Li , 015 PSay STR0120 + ": " //"Situação Encontrada"
					Else
						SomaLinha()
					EndIf
					@ Li , 015 + Len( STR0120 + ": " ) PSay MemoLine( cSituacao , nTamanho , i ) //"Situação Encontrada"
				Next i

				cSituacao 	:= MsMM( TN0->TN0_SI2SYP , 80 )
				nTamanho    := 100 - Len( STR0121 + ": " ) //"Situação Desejada"
				nLinhasMemo := MlCount( cSituacao , nTamanho )
				//Percorre o memo e realiza a impressão linear
				For i := 1 To nLinhasMemo
					If i == 1
						SomaLinha()
						@ Li , 015 PSay STR0121 + ": " //"Situação Desejada"
					Else
						SomaLinha()
					EndIf
					@ Li , 015 + Len( STR0121 + ": " ) PSay MemoLine( cSituacao , nTamanho , i ) //"Situação Desejada"
				Next i

				SomaLinha()
				@ Li , 015 PSay STR0122 + ": " + NGRETSX3BOX( "TN0_SITUAC" , TN0->TN0_SITUAC ) //"Situação Ergonômica"
			ElseIf mv_par03 == 2
				cMemo := ""
			Else
				cMemo += AllTrim( Capital( TMA->TMA_NOMAGE ) ) + " - " + TN0->TN0_NUMRIS + "#*"
				If Empty( MsMM( TN0->TN0_SITSYP , 80 ) )
					cMemo += cValToChar( TN0->TN0_QTAGEN ) + TN0->TN0_UNIMED + "#*"
				Else
					cMemo += AllTrim( MsMM( TN0->TN0_SITSYP , 80 ) ) + "#*"
				EndIf
				cMemo += AllTrim( MsMM( TN0->TN0_SI2SYP , 80 ) ) + "#*"
				cMemo += NGRETSX3BOX( "TN0_SITUAC" , TN0->TN0_SITUAC ) + "#*"
			EndIf

			dbSelectArea( "TJF" )
			dbSetOrder( 1 )
			dbSeek( xFilial( "TJF" ) + TN0->TN0_NUMRIS )
			lMedida := .F.
			While TJF->( !Eof() ) .And. TJF->TJF_FILIAL == xFilial( "TJF" ) .And. TJF->TJF_NUMRIS == TN0->TN0_NUMRIS

				dbSelectArea( "TO4" )
				dbSetOrder( 1 )
				dbSeek( xFilial( "TO4" ) + TJF->TJF_MEDCON )

				cMemo += AllTrim( Capital( TO4->TO4_NOMCTR ) )+ "; "

				TJF->( dbSkip() )
				lMedida := .T.
			End
			If lMedida
				cMemo := AllTrim( cMemo )
				cMemo := SubStr( cMemo , 1 , Len( cMemo ) - 1 )
			EndIf
			If mv_par03 == 1
				nTamanho    := 100 - Len( STR0123 + ": " ) //"Medida(s) Aplicada(s)"
				nLinhasMemo := MlCount( cMemo , nTamanho )
				//Percorre o memo e realiza a impressão linear
				For i := 1 To nLinhasMemo
					If i == 1
						SomaLinha()
						@ Li , 015 PSay STR0123 + ": " //"Medida(s) Aplicada(s)"
					Else
						SomaLinha()
					EndIf
					@ Li , 015 + Len( STR0123 + ": " ) PSay MemoLine( cMemo , nTamanho , i ) //"Medida(s) Aplicada(s)"
				Next i
				SomaLinha()
			ElseIf mv_par03 == 2
				If nRisc == 1
					Somalinha( , .T.)
					oPrintErg:Box( lin , 0150 , lin + 60 , 2300 )
					oPrintErg:Line( lin , 0580 , lin + 60 , 0580 )
					oPrintErg:Line( lin , 1010 , lin + 60 , 1010 )
					oPrintErg:Line( lin , 1440 , lin + 60 , 1440 )
					oPrintErg:Line( lin , 1870 , lin + 60 , 1870 )
					oPrintErg:Say( lin + 10 , 0365 , STR0075 , oFont08b , , , , 2 ) //"Agente"
					oPrintErg:Say( lin + 10 , 0795 , STR0120 , oFont08b , , , , 2 ) //"Situação Encontrada"
					oPrintErg:Say( lin + 10 , 1225 , STR0121 , oFont08b , , , , 2 ) //"Situação Desejada"
					oPrintErg:Say( lin + 10 , 1655 , STR0122 , oFont08b , , , , 2 ) //"Situação Ergonômica"
					oPrintErg:Say( lin + 10 , 2085 , STR0123 , oFont08b , , , , 2 ) //"Medida(s) Aplicada(s)"
				EndIf
				cAgente := AllTrim( Capital( TMA->TMA_NOMAGE ) ) + " - " + TN0->TN0_NUMRIS
				cEncontra := AllTrim( MsMM( TN0->TN0_SITSYP , 80 ) )
				If Empty( cEncontra )
					cEncontra := cValToChar( TN0->TN0_QTAGEN ) + TN0->TN0_UNIMED
				EndIf
				cDeseja := AllTrim( MsMM( TN0->TN0_SI2SYP , 80 ) )
				cErgonom := NGRETSX3BOX( "TN0_SITUAC" , TN0->TN0_SITUAC )
				cMedida := cMemo

				nLimFor := MlCount( cAgente , nCorte )
				nLimFor := If( nLimFor > MlCount( cEncontra , nCorte ) , nLimFor , MlCount( cEncontra , nCorte ) )
				nLimFor := If( nLimFor > MlCount( cDeseja , nCorte ) , nLimFor , MlCount( cDeseja , nCorte ) )
				nLimFor := If( nLimFor > MlCount( cErgonom , nCorte ) , nLimFor , MlCount( cErgonom , nCorte ) )
				nLimFor := If( nLimFor > MlCount( cMedida , nCorte ) , nLimFor , MlCount( cMedida , nCorte ) )

				For i := 1 To nLimFor
					Somalinha( , .T.)
					oPrintErg:Line( lin , 0150 , lin + 60 , 0150 )
					oPrintErg:Line( lin , 0580 , lin + 60 , 0580 )
					oPrintErg:Line( lin , 1010 , lin + 60 , 1010 )
					oPrintErg:Line( lin , 1440 , lin + 60 , 1440 )
					oPrintErg:Line( lin , 1870 , lin + 60 , 1870 )
					oPrintErg:Line( lin , 2300 , lin + 60 , 2300 )
					If !Empty( MemoLine( cAgente , nCorte , i ) )
						oPrintErg:Say( lin + 10 , 170 , MemoLine( cAgente , nCorte , i ) , oFont08 )
					EndIf
					If !Empty( MemoLine( cEncontra , nCorte , i ) )
						oPrintErg:Say( lin + 10 , 590 , MemoLine( cEncontra , nCorte , i ) , oFont08 )
					EndIf
					If !Empty( MemoLine( cDeseja , nCorte , i ) )
						oPrintErg:Say( lin + 10 , 1030 , MemoLine( cDeseja , nCorte , i ) , oFont08 )
					EndIf
					If !Empty( MemoLine( cErgonom , nCorte , i ) )
						oPrintErg:Say( lin + 10 , 1460 , MemoLine( cErgonom , nCorte , i ) , oFont08 )
					EndIf
					If !Empty( MemoLine( cMedida , nCorte , i ) )
						oPrintErg:Say( lin + 10 , 1890 , MemoLine( cMedida , nCorte , i ) , oFont08 )
					EndIf
				Next i
				oPrintErg:Line( lin + 60 , 150 , lin + 60 , 2300 )
			Else
				cMemo +=  + "#*"
				nRegs++
			EndIf
		Next nRisc

		If mv_par03 == 3
			OLE_ExecuteMacro( oWord , "Somalinha" )
			OLE_ExecuteMacro( oWord , "Somalinha" )
			OLE_SetDocumentVar( oWord , "Tabela" , cMemo )
			OLE_SetDocumentVar( oWord , "Linhas" , nRegs )
			OLE_ExecuteMacro( oWord , "Table_AgenteMedida" )
			OLE_ExecuteMacro( oWord , "Somalinha" )
			OLE_ExecuteMacro( oWord , "Somalinha" )
		Else
			SomaLinha()
		EndIf

	Next nAge

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} fNaoExpostos
Busca e imprime as informações do atalho dos funcionarios não
expostos aos riscos do laudo

@type Function
@author Gabriel Sokacheski
@since 23/03/2021

/*/
//-------------------------------------------------------------------
Static Function fNaoExpostos()

	Local aFun := {}
	Local aRiscos := {}
	Local aFunRis := {}

	Local cFun := ''
	Local cTar := ''
	Local cDep := ''
	Local cLaudo := TO0->TO0_LAUDO
	Local cCenCus := ''
	Local cAliasRis := GetNextAlias()
	Local cAliasFun := GetNextAlias()
	Local cListaFun := ''

	Local nI := 0
	Local nX := 0
	Local nTipo := mv_par08
	Local nLinhas := 0

	nTipo := IIf( Empty( nTipo ), 1, nTipo ) // Caso não exista a pergunta no dicionário

	BeginSQL Alias cAliasRis
		SELECT
			TN0.TN0_NUMRIS, TMA.TMA_NOMAGE, TMA.TMA_GRISCO, TN7.TN7_NOMFON, CTT.CTT_DESC01, SRJ.RJ_DESC,
			TN5.TN5_NOMTAR, SQB.QB_DESCRIC, TNE.TNE_NOME, TN0.TN0_DTAVAL, TN0.TN0_QTAGEN, V3F.V3F_DESCRI,
			TN0.TN0_INDEXP, TN0.TN0_CC, TN0.TN0_CODFUN, TN0.TN0_CODTAR, TN0.TN0_DEPTO, TO1.TO1_RECOME
		FROM
			%table:TO0% TO0
				INNER JOIN %table:TO1% TO1 ON
					TO0.TO0_LAUDO = TO1.TO1_LAUDO
					AND %xFilial:TO1% = TO1.TO1_FILIAL
					AND TO1.%NotDel%
				INNER JOIN %table:TN0% TN0 ON
					TO1.TO1_NUMRIS = TN0.TN0_NUMRIS
					AND %xFilial:TN0% = TN0.TN0_FILIAL
					AND TN0.TN0_MAPRIS != '1'
					AND TN0.%NotDel%
				INNER JOIN %table:TMA% TMA ON
					TN0.TN0_AGENTE = TMA.TMA_AGENTE
					AND %xFilial:TMA% = TMA.TMA_FILIAL
					AND TMA.%NotDel%
				INNER JOIN %table:TN7% TN7 ON
					TN0.TN0_FONTE = TN7.TN7_FONTE
					AND %xFilial:TN7% = TN7.TN7_FILIAL
					AND TN7.%NotDel%
				LEFT JOIN %table:CTT% CTT ON
					TN0.TN0_CC = CTT.CTT_CUSTO
					AND %xFilial:CTT% = CTT.CTT_FILIAL
					AND CTT.%NotDel%
				LEFT JOIN %table:SRJ% SRJ ON
					TN0.TN0_CODFUN = SRJ.RJ_FUNCAO
					AND %xFilial:SRJ% = SRJ.RJ_FILIAL
					AND SRJ.%NotDel%
				LEFT JOIN %table:TN5% TN5 ON
					TN0.TN0_CODTAR = TN5.TN5_CODTAR
					AND %xFilial:TN5% = TN5.TN5_FILIAL
					AND TN5.%NotDel%
				LEFT JOIN %table:SQB% SQB ON
					TN0.TN0_DEPTO = SQB.QB_DEPTO
					AND %xFilial:SQB% = SQB.QB_FILIAL
					AND SQB.%NotDel%
				LEFT JOIN %table:TNE% TNE ON
					TN0.TN0_CODAMB = TNE.TNE_CODAMB
					AND %xFilial:TNE% = TNE.TNE_FILIAL
					AND TNE.%NotDel%
				LEFT JOIN %table:V3F% V3F ON
					TN0.TN0_UNIMED = V3F.V3F_CODIGO
					AND %xFilial:V3F% = V3F.V3F_FILIAL
					AND V3F.%NotDel%
		WHERE
			TO0.TO0_FILIAL = %xFilial:TO0%
			AND TO0.TO0_LAUDO = %exp:cLaudo%
			AND TO0.TO0_TIPREL = 'C'
			AND ( TN0.TN0_CC = CTT.CTT_CUSTO OR TN0.TN0_CC = '*' )
			AND ( TN0.TN0_CODFUN = SRJ.RJ_FUNCAO OR TN0.TN0_CODFUN = '*' )
			AND ( TN0.TN0_CODTAR = TN5.TN5_CODTAR OR TN0.TN0_CODTAR = '*' )
			AND ( TN0.TN0_DEPTO = SQB.QB_DEPTO OR TN0.TN0_DEPTO = '*' )
			AND TO0.%NotDel%
		ORDER BY TN0.TN0_NUMRIS
	EndSQL

	dbSelectArea( cAliasRis )
	dbGoTop()

	While !Eof()

		If aScan( aRiscos, { | x | x[ 1 ] == TN0_NUMRIS } ) == 0

			cFun := IIf( AllTrim( TN0_CODFUN ) == '*', STR0155, RJ_DESC ) // "Todas"
			cTar := IIf( AllTrim( TN0_CODTAR ) == '*', STR0155, TN5_NOMTAR ) // "Todas"
			cDep := IIf( AllTrim( TN0_DEPTO ) == '*', STR0124, QB_DESCRIC ) // "Todos"
			cCenCus := IIf( AllTrim( TN0_CC ) == '*', STR0124, CTT_DESC01 ) // "Todos"

			aAdd( aRiscos, {;
				TN0_NUMRIS,;
				TMA_NOMAGE,;
				TMA_GRISCO,;
				TN7_NOMFON,;
				cCenCus,;
				cFun,;
				cTar,;
				cDep,;
				TNE_NOME,;
				TN0_DTAVAL,;
				TN0_QTAGEN,;
				TN0_INDEXP,;
				TO1_RECOME,;
				V3F_DESCRI;
			} )

		EndIf

		( cAliasRis )->( dbSkip() )

	End

	( cAliasRis )->( dbCloseArea() )

	BeginSQL Alias cAliasFun
		SELECT
			TN0.TN0_NUMRIS, TM0.TM0_NUMFIC, SRA.RA_MAT, SRA.RA_NOME
		FROM
			%table:SRA% SRA
				INNER JOIN %table:TO0% TO0 ON
					%exp:cLaudo% = TO0.TO0_LAUDO
					AND %xFilial:TO0% = TO0.TO0_FILIAL
					AND TO0.TO0_TIPREL = 'C'
					AND TO0.%NotDel%
				INNER JOIN %table:TO1% TO1 ON
					TO0.TO0_LAUDO = TO1.TO1_LAUDO
					AND %xFilial:TO1% = TO1.TO1_FILIAL
					AND TO1.%NotDel%
				INNER JOIN %table:TN0% TN0 ON
					TO1.TO1_NUMRIS = TN0.TN0_NUMRIS
					AND %xFilial:TN0% = TN0.TN0_FILIAL
					AND TN0.TN0_MAPRIS != '1'
					AND TN0.%NotDel%
				LEFT JOIN %table:TM0% TM0 ON
					SRA.RA_MAT = TM0.TM0_MAT
					AND %xFilial:TM0% = TM0.TM0_FILIAL
					AND TM0.%NotDel%
		WHERE
			SRA.RA_FILIAL = %xFilial:SRA%
			AND ( SRA.RA_SITFOLH != 'D' OR SRA.RA_DEMISSA > %exp:dAteLaudo% )
			AND SRA.RA_ADMISSA < %exp:dAteLaudo%
			AND SRA.%NotDel%
			AND CONCAT( SRA.RA_MAT, TN0.TN0_NUMRIS ) NOT IN (
				SELECT
					CONCAT( SRA.RA_MAT, TN0.TN0_NUMRIS )
				FROM
					%table:SRA% SRA
						INNER JOIN %table:TO0% TO0 ON
							%exp:cLaudo% = TO0.TO0_LAUDO
							AND %xFilial:TO0% = TO0.TO0_FILIAL
							AND TO0.TO0_TIPREL = 'C'
							AND TO0.%NotDel%
						INNER JOIN %table:TO1% TO1 ON
							TO0.TO0_LAUDO = TO1.TO1_LAUDO
							AND %xFilial:TO1% = TO1.TO1_FILIAL
							AND TO1.%NotDel%
						INNER JOIN %table:TN0% TN0 ON
							TO1.TO1_NUMRIS = TN0.TN0_NUMRIS
							AND %xFilial:TN0% = TN0.TN0_FILIAL
							AND TN0.TN0_MAPRIS != '1'
							AND TN0.%NotDel%
						LEFT JOIN %table:TN6% TN6 ON
							SRA.RA_MAT = TN6.TN6_MAT
							AND %xFilial:TN6% = TN6.TN6_FILIAL
							AND TN6.TN6_CODTAR = TN0.TN0_CODTAR
							AND (
								( TN6.TN6_DTTERM = '' AND TN0.TN0_DTELIM = '' )
								OR (
									TN6.TN6_DTTERM != '' AND TN0.TN0_DTELIM != ''
									AND NOT(
										( TN6.TN6_DTINIC < TN0.TN0_DTAVAL AND TN6.TN6_DTTERM < TN0.TN0_DTAVAL )
										OR ( TN6.TN6_DTINIC > TN0.TN0_DTELIM AND TN6.TN6_DTTERM > TN0.TN0_DTELIM )
									)
								)
								OR (
									TN6.TN6_DTTERM != '' AND TN0.TN0_DTELIM = ''
									AND NOT( TN6.TN6_DTINIC < TN0.TN0_DTAVAL AND TN6.TN6_DTTERM < TN0.TN0_DTAVAL )
								)
								OR (
									TN6.TN6_DTTERM = '' AND TN0.TN0_DTELIM != ''
									AND NOT( TN0.TN0_DTAVAL < TN6.TN6_DTINIC AND TN0.TN0_DTELIM < TN6.TN6_DTINIC )
								)
							)
							AND TN6.%NotDel%
				WHERE
					SRA.RA_FILIAL = %xFilial:SRA%
					AND SRA.RA_SITFOLH != 'D'
					AND SRA.RA_DEMISSA = ''
					AND ( SRA.RA_ADMISSA <= TN0.TN0_DTELIM OR TN0.TN0_DTELIM = '' )
					AND ( SRA.RA_CC = TN0.TN0_CC OR TN0.TN0_CC = '*' )
					AND ( SRA.RA_CODFUNC = TN0.TN0_CODFUN OR TN0.TN0_CODFUN = '*' )
					AND ( SRA.RA_DEPTO = TN0.TN0_DEPTO OR TN0.TN0_DEPTO = '*' )
					AND ( TN6.TN6_CODTAR = TN0.TN0_CODTAR OR TN0.TN0_CODTAR = '*' )
					AND SRA.%NotDel%
			)
		GROUP BY TN0.TN0_NUMRIS, TM0.TM0_NUMFIC, SRA.RA_MAT, SRA.RA_NOME
		ORDER BY TN0.TN0_NUMRIS
	EndSQL

	dbSelectArea( cAliasFun )
	dbGoTop()

	While !Eof()

		aAdd( aFun, {;
			TN0_NUMRIS,;
			TM0_NUMFIC,;
			RA_MAT,;
			RA_NOME;
		} )

		( cAliasFun )->( dbSkip() )

	End

	( cAliasFun )->( dbCloseArea() )

	For nI := 1 To Len( aRiscos )

		aFunRis := {}

		For nX := 1 To Len( aFun )

			If aFun[ nX, 1 ] == aRiscos[ nI, 1 ]
				aAdd( aFunRis, aFun[ nX ] )
			EndIf

		Next

		aAdd( aRiscos[ nI ], AllTrim( Str( Len( aFunRis ) ) ) ) // Quantidade de funcionários
		aAdd( aRiscos[ nI ], aFunRis ) // Informações dos funcionários

	Next

	If mv_par07 == 2
		aSort( aRiscos, /*nInicio*/, /*nCont*/, { | x, y | x[ 2 ] < y[ 2 ] } ) // Agente de risco
	ElseIf mv_par07 == 3
		aSort( aRiscos, /*nInicio*/, /*nCont*/, { | x, y | x[ 4 ] < y[ 4 ] } ) // Fonte geradora
	ElseIf mv_par07 == 4
		aSort( aRiscos, /*nInicio*/, /*nCont*/, { | x, y | x[ 5 ] < y[ 5 ] } ) // Centro de custo
	ElseIf mv_par07 == 5
		aSort( aRiscos, /*nInicio*/, /*nCont*/, { | x, y | x[ 6 ] < y[ 6 ] } ) // Função
	EndIf

	For nI := 1 To Len( aRiscos )

		// Só imprime os riscos que contém funcionários não expostos
		If Val( aRiscos[ nI, 15 ] ) > 0

			cListaFun := ''

			// Impressão do atalho
			If nModeloImp == 3

				OLE_SetDocumentVar( oWord, 'cAgente', AllTrim( aRiscos[ nI, 2 ] ) )

				If aRiscos[ nI, 3 ] == '1'
					OLE_SetDocumentVar( oWord, 'cTipo', STR0085 )
				ElseIf aRiscos[ nI, 3 ] == '2'
					OLE_SetDocumentVar( oWord, 'cTipo', STR0086 )
				ElseIf aRiscos[ nI, 3 ]== '3'
					OLE_SetDocumentVar( oWord, 'cTipo', STR0087 )
				ElseIf aRiscos[ nI, 3 ]== '4'
					OLE_SetDocumentVar( oWord, 'cTipo', STR0088 )
				ElseIf aRiscos[ nI, 3 ] == '5'
					OLE_SetDocumentVar( oWord, 'cTipo', STR0089 )
				ElseIf aRiscos[ nI, 3 ] == '6'
					OLE_SetDocumentVar( oWord, 'cTipo', STR0090 )
				ElseIf aRiscos[ nI, 3 ] == '7'
					OLE_SetDocumentVar( oWord, 'cTipo', STR0134 )
				Else
					OLE_SetDocumentVar( oWord, 'cTipo', STR0135 )
				EndIf

				OLE_SetDocumentVar( oWord, 'cFonte', AllTrim( aRiscos[ nI, 4 ] ) )
				OLE_SetDocumentVar( oWord, 'cCenCus', AllTrim( aRiscos[ nI, 5 ] ) )
				OLE_SetDocumentVar( oWord, 'cFuncao', AllTrim( aRiscos[ nI, 6 ] ) )
				OLE_SetDocumentVar( oWord, 'cTarefa', AllTrim( aRiscos[ nI, 7 ] ) )
				OLE_SetDocumentVar( oWord, 'cDep', AllTrim( aRiscos[ nI, 8 ] ) )

				If Empty( aRiscos[ nI, 9 ] )
					OLE_SetDocumentVar( oWord, 'cAmb', STR0135 )
				Else
					OLE_SetDocumentVar( oWord, 'cAmb', AllTrim( aRiscos[ nI, 9 ] ) )
				EndIf

				OLE_SetDocumentVar( oWord, 'dDtAval', Dtoc( Stod( aRiscos[ nI, 10 ] ) ) )

				If aRiscos[ nI, 11 ] > 0
					If Empty( aRiscos[ nI, 14 ] )
						OLE_SetDocumentVar( oWord, 'cQtdAgen', AllTrim( cValToChar( aRiscos[ nI, 11 ] ) ) )
					Else
						OLE_SetDocumentVar( oWord, 'cQtdAgen', AllTrim( cValToChar( aRiscos[ nI, 11 ] ) ) + ' (' + AllTrim( aRiscos[ nI, 14 ] ) + ')' )
					EndIf
				Else
					OLE_SetDocumentVar( oWord, 'cQtdAgen', AllTrim( cValToChar( aRiscos[ nI, 11 ] ) ) )
				EndIf

				If aRiscos[ nI, 12 ] == '1'
					OLE_SetDocumentVar( oWord, 'cTipoExp', STR0136 )
				ElseIf aRiscos[ nI, 12 ] == '2'
					OLE_SetDocumentVar( oWord, 'cTipoExp', STR0137 )
				ElseIf aRiscos[ nI, 12 ] == '3'
					OLE_SetDocumentVar( oWord, 'cTipoExp', STR0138 )
				ElseIf aRiscos[ nI, 12 ] == '4'
					OLE_SetDocumentVar( oWord, 'cTipoExp', STR0139 )
				ElseIf aRiscos[ nI, 12 ] == '5'
					OLE_SetDocumentVar( oWord, 'cTipoExp', STR0140 )
				Else
					OLE_SetDocumentVar( oWord, 'cTipoExp', STR0135 )
				EndIf

				If Empty( aRiscos[ nI, 13 ] )
					OLE_SetDocumentVar( oWord, 'cRec', STR0135 )
				Else
					OLE_SetDocumentVar( oWord, 'cRec', AllTrim( aRiscos[ nI, 13 ] ) )
				EndIf

				If nTipo == 1 // Sintético

					OLE_SetDocumentVar( oWord, 'nQtdLin', 12 ) // Quantidade de linhas necessárias para a tabela
					OLE_SetDocumentVar( oWord, 'cFun', aRiscos[ nI, 15 ] )

					OLE_ExecuteMacro( oWord, 'nao_expostos_sintetico' )

				Else // Analítico

					// Funcionários
					For nX := 1 To Len( aRiscos[ nI, 16 ] )

						If Empty( aRiscos[ nI, 16, nX, 2 ] )
							cListaFun += STR0135 + '*' + AllTrim( aRiscos[ nI, 16, nX, 3 ] ) + '*' + AllTrim( aRiscos[ nI, 16, nX, 4 ] ) + '#'
						Else
							cListaFun += AllTrim( aRiscos[ nI, 16, nX, 2 ] ) + '*' + AllTrim( aRiscos[ nI, 16, nX, 3 ] ) + '*' + AllTrim( aRiscos[ nI, 16, nX, 4 ] ) + '#'
						EndIf

					Next

					OLE_SetDocumentVar( oWord, 'nQtdLin', 13 + Val( aRiscos[ nI, 15 ] ) ) // Quantidade de linhas necessárias para a tabela
					OLE_SetDocumentVar( oWord, 'cFun', cListaFun )

					OLE_ExecuteMacro( oWord, 'nao_expostos_analitico' )

				EndIf

			ElseIf nModeloImp == 1

				SomaLinha()
				@ Li, 005 Psay STR0141
				@ Li, 035 Psay AllTrim( aRiscos[ nI, 2 ] )

				SomaLinha()
				@ Li, 005 Psay STR0142
				@ Li, 035 Psay Dtoc( Stod( aRiscos[ nI, 10 ] ) )

				SomaLinha()
				@ Li, 005 Psay STR0143
				@ Li, 035 Psay AllTrim( aRiscos[ nI, 4 ] )

				SomaLinha()
				@ Li, 005 Psay STR0144
				@ Li, 035 Psay AllTrim( aRiscos[ nI, 5 ] )

				SomaLinha()
				@ Li, 005 Psay STR0145
				@ Li, 035 Psay AllTrim( aRiscos[ nI, 6 ] )

				SomaLinha()
				@ Li, 005 Psay STR0146
				@ Li, 035 Psay AllTrim( aRiscos[ nI, 7 ] )

				SomaLinha()
				@ Li, 005 Psay STR0147
				@ Li, 035 Psay AllTrim( aRiscos[ nI, 8 ] )

				SomaLinha()
				@ Li, 005 Psay STR0148
				If Empty( aRiscos[ nI, 9 ] )
					@ Li, 035 Psay STR0135
				Else
					@ Li, 035 Psay AllTrim( aRiscos[ nI, 9 ] )
				EndIf

				SomaLinha()
				@ Li, 005 Psay STR0149
				If aRiscos[ nI, 3 ] == '1'
					@ Li, 035 Psay STR0085
				ElseIf aRiscos[ nI, 3 ] == '2'
					@ Li, 035 Psay STR0086
				ElseIf aRiscos[ nI, 3 ]== '3'
					@ Li, 035 Psay STR0087
				ElseIf aRiscos[ nI, 3 ]== '4'
					@ Li, 035 Psay STR0088
				ElseIf aRiscos[ nI, 3 ] == '5'
					@ Li, 035 Psay STR0089
				ElseIf aRiscos[ nI, 3 ] == '6'
					@ Li, 035 Psay STR0090
				ElseIf aRiscos[ nI, 3 ] == '7'
					@ Li, 035 Psay STR0134
				Else
					@ Li, 035 Psay STR0135
				EndIf

				SomaLinha()
				@ Li, 005 Psay STR0150

				If aRiscos[ nI, 11 ] > 0
					If Empty( aRiscos[ nI, 14 ] )
						@ Li, 035 Psay AllTrim( cValToChar( aRiscos[ nI, 11 ] ) )
					Else
						@ Li, 035 Psay AllTrim( cValToChar( aRiscos[ nI, 11 ] ) )  + ' (' + AllTrim( aRiscos[ nI, 14 ] ) + ')'
					EndIf
				Else
					@ Li, 035 Psay AllTrim( cValToChar( aRiscos[ nI, 11 ] ) )
				EndIf

				SomaLinha()
				@ Li, 005 Psay STR0151
				If aRiscos[ nI, 12 ] == '1'
					@ Li, 035 Psay STR0136
				ElseIf aRiscos[ nI, 12 ] == '2'
					@ Li, 035 Psay STR0137
				ElseIf aRiscos[ nI, 12 ] == '3'
					@ Li, 035 Psay STR0138
				ElseIf aRiscos[ nI, 12 ] == '4'
					@ Li, 035 Psay STR0139
				ElseIf aRiscos[ nI, 12 ] == '5'
					@ Li, 035 Psay STR0140
				Else
					@ Li, 035 Psay STR0135
				EndIf

				SomaLinha()
				@ Li, 005 Psay STR0152

				SomaLinha()

				nLinhas := MlCount( AllTrim( aRiscos[ nI, 13 ] ), 100 )

				For nX := 1 To nLinhas
					@ Li, 005 Psay MemoLine( AllTrim( aRiscos[ nI, 13 ] ), 100, nX )
					SomaLinha()
				Next nX

				If Empty( aRiscos[ nI, 13 ] )
					@ Li, 005 Psay STR0135
					SomaLinha()
				EndIf

				If nTipo == 1

					@ Li, 005 Psay STR0153 + ': ' + aRiscos[ nI, 15 ]
					SomaLinha()

				Else

					@ Li, 005 Psay STR0153
					SomaLinha()

					SomaLinha()
					@ Li, 005 Psay STR0154
					@ Li, 027 Psay STR0093
					@ Li, 046 Psay STR0094

					SomaLinha()
					// Funcionários
					For nX := 1 To Len( aRiscos[ nI, 16 ] )

						If Empty( aRiscos[ nI, 16, nX, 2 ] )
							@ Li, 005 Psay STR0135
						Else
							@ Li, 005 Psay AllTrim( aRiscos[ nI, 16, nX, 2 ] )
						EndIf

						@ Li, 027 Psay AllTrim( aRiscos[ nI, 16, nX, 3 ] )
						@ Li, 046 Psay AllTrim( aRiscos[ nI, 16, nX, 4 ] )
						SomaLinha()

					Next

				EndIf

			ElseIf nModeloImp == 2

				SomaLinha()
				oPrintErg:Box( lin, 150 , lin + 60, 2300 )
				oPrintErg:Say( lin, 1150, STR0076, oFont10b )

				SomaLinha()
				oPrintErg:Box( lin, 150 , lin + 60, 2300 )
				oPrintErg:Say( lin, 170, STR0141, oFont10b )
				oPrintErg:Say( lin, 850, AllTrim( aRiscos[ nI, 2 ] ), oFont10 )

				SomaLinha()
				oPrintErg:Box( lin, 150 , lin + 60, 2300 )
				oPrintErg:Say( lin, 170, STR0142, oFont10b )
				oPrintErg:Say( lin, 850, Dtoc( Stod( aRiscos[ nI, 10 ] ) ), oFont10 )

				SomaLinha()
				oPrintErg:Box( lin, 150 , lin + 60, 2300 )
				oPrintErg:Say( lin, 170, STR0143, oFont10b )
				oPrintErg:Say( lin, 850, AllTrim( aRiscos[ nI, 4 ] ), oFont10 )

				SomaLinha()
				oPrintErg:Box( lin, 150 , lin + 60, 2300 )
				oPrintErg:Say( lin, 170, STR0144, oFont10b )
				oPrintErg:Say( lin, 850, AllTrim( aRiscos[ nI, 5 ] ), oFont10 )

				SomaLinha()
				oPrintErg:Box( lin, 150 , lin + 60, 2300 )
				oPrintErg:Say( lin, 170, STR0145, oFont10b )
				oPrintErg:Say( lin, 850, AllTrim( aRiscos[ nI, 6 ] ), oFont10 )

				SomaLinha()
				oPrintErg:Box( lin, 150 , lin + 60, 2300 )
				oPrintErg:Say( lin, 170, STR0146, oFont10b )
				oPrintErg:Say( lin, 850, AllTrim( aRiscos[ nI, 7 ] ), oFont10 )

				SomaLinha()
				oPrintErg:Box( lin, 150 , lin + 60, 2300 )
				oPrintErg:Say( lin, 170, STR0147, oFont10b )
				oPrintErg:Say( lin, 850, AllTrim( aRiscos[ nI, 8 ] ), oFont10 )

				SomaLinha()
				oPrintErg:Box( lin, 150 , lin + 60, 2300 )
				oPrintErg:Say( lin, 170, STR0148, oFont10b )
				If Empty( aRiscos[ nI, 9 ] )
					oPrintErg:Say( lin, 850, STR0135, oFont10 )
				Else
					oPrintErg:Say( lin, 850, AllTrim( aRiscos[ nI, 9 ] ), oFont10 )
				EndIf

				SomaLinha()
				oPrintErg:Box( lin, 150 , lin + 60, 2300 )
				oPrintErg:Say( lin, 170, STR0149, oFont10b )

				If aRiscos[ nI, 3 ] == '1'
					oPrintErg:Say( lin, 850, STR0085, oFont10 )
				ElseIf aRiscos[ nI, 3 ] == '2'
					oPrintErg:Say( lin, 850, STR0086, oFont10 )
				ElseIf aRiscos[ nI, 3 ]== '3'
					oPrintErg:Say( lin, 850, STR0087, oFont10 )
				ElseIf aRiscos[ nI, 3 ]== '4'
					oPrintErg:Say( lin, 850, STR0088, oFont10 )
				ElseIf aRiscos[ nI, 3 ] == '5'
					oPrintErg:Say( lin, 850, STR0089, oFont10 )
				ElseIf aRiscos[ nI, 3 ] == '6'
					oPrintErg:Say( lin, 850, STR0090, oFont10 )
				ElseIf aRiscos[ nI, 3 ] == '7'
					oPrintErg:Say( lin, 850, STR0134, oFont10 )
				Else
					oPrintErg:Say( lin, 850, STR0135, oFont10 )
				EndIf

				SomaLinha()
				oPrintErg:Box( lin, 150 , lin + 60, 2300 )
				oPrintErg:Say( lin, 170, STR0150, oFont10b )

				If aRiscos[ nI, 11 ] > 0
					If Empty( aRiscos[ nI, 14 ] )
						oPrintErg:Say( lin, 850, AllTrim( cValToChar( aRiscos[ nI, 11 ] ) ), oFont10 )
					Else
						oPrintErg:Say( lin, 850, AllTrim( cValToChar( aRiscos[ nI, 11 ] ) )   + ' (' + AllTrim( aRiscos[ nI, 14 ] ) + ')', oFont10 )
					EndIf
				Else
					oPrintErg:Say( lin, 850, AllTrim( cValToChar( aRiscos[ nI, 11 ] ) ), oFont10 )
				EndIf

				SomaLinha()
				oPrintErg:Box( lin, 150 , lin + 60, 2300 )
				oPrintErg:Say( lin, 170, STR0151, oFont10b )

				If aRiscos[ nI, 12 ] == '1'
					oPrintErg:Say( lin, 850, STR0136, oFont10 )
				ElseIf aRiscos[ nI, 12 ] == '2'
					oPrintErg:Say( lin, 850, STR0137, oFont10 )
				ElseIf aRiscos[ nI, 12 ] == '3'
					oPrintErg:Say( lin, 850, STR0138, oFont10 )
				ElseIf aRiscos[ nI, 12 ] == '4'
					oPrintErg:Say( lin, 850, STR0139, oFont10 )
				ElseIf aRiscos[ nI, 12 ] == '5'
					oPrintErg:Say( lin, 850, STR0140, oFont10 )
				Else
					oPrintErg:Say( lin, 850, STR0135, oFont10 )
				EndIf

				SomaLinha()

				nLinhas := MlCount( AllTrim( aRiscos[ nI, 13 ] ), 100 )
				oPrintErg:Box( lin, 150 , lin + 120 + 60 * IIf( nLinhas > 0, nLinhas, 1 ), 2300 )
				oPrintErg:Say( lin, 170, STR0152, oFont10b )
				SomaLinha()
				SomaLinha()

				For nX := 1 To nLinhas
					oPrintErg:Say( lin, 170, MemoLine( AllTrim( aRiscos[ nI, 13 ] ), 100, nX ), oFont10 )
					SomaLinha()
				Next nX

				If Empty( aRiscos[ nI, 13 ] )
					oPrintErg:Say( lin, 170, STR0135, oFont10 )
					SomaLinha()
				EndIf

				If nTipo == 1

					oPrintErg:Box( lin, 150 , lin + 60, 2300 )
					oPrintErg:Say( lin, 170, STR0153 + ': ', oFont10b )
					oPrintErg:Say( lin, 850, aRiscos[ nI, 15 ], oFont10 )
					SomaLinha()

				Else

					oPrintErg:Box( lin, 150 , lin + 60, 2300 )
					oPrintErg:Say( lin, 950, STR0153, oFont10b )

					SomaLinha()
					oPrintErg:Box( lin, 150 , lin + 60, 2300 )
					oPrintErg:Say( lin, 205, STR0154, oFont10b )
					oPrintErg:line( lin, 500, lin + 60, 500 )
					oPrintErg:Say( lin, 610, STR0093, oFont10b )
					oPrintErg:line( lin, 900, lin + 60, 900 )
					oPrintErg:Say( lin, 1550, STR0094, oFont10b )

					SomaLinha()

					// Funcionários
					For nX := 1 To Len( aRiscos[ nI, 16 ] )

						oPrintErg:Box( lin, 150 , lin + 60, 2300 )
						oPrintErg:line( lin, 500, lin + 60, 500 )
						oPrintErg:line( lin, 900, lin + 60, 900 )

						If Empty( aRiscos[ nI, 16, nX, 2 ] )
							oPrintErg:Say( lin, 170, STR0135, oFont10 )
						Else
							oPrintErg:Say( lin, 170, AllTrim( aRiscos[ nI, 16, nX, 2 ] ), oFont10 )
						EndIf

						oPrintErg:Say( lin, 520, AllTrim( aRiscos[ nI, 16, nX, 3 ] ), oFont10 )
						oPrintErg:Say( lin, 920, AllTrim( aRiscos[ nI, 16, nX, 4 ] ), oFont10 )
						SomaLinha()

					Next

				EndIf

			EndIf

		EndIf

	Next

Return
