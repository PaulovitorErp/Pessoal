#INCLUDE "MDTC990.ch"
#Include "Protheus.ch"
#Include "Colors.ch"

//Variaveis de ListBox (Filial)
#DEFINE _nEMPRES_ 1
#DEFINE _nFILIAL_ 2
#DEFINE _nNOMFIL_ 3
#DEFINE _nDTENTR_ 4
#DEFINE _nDTSAID_ 5
#DEFINE _nMATRIC_ 6
#DEFINE _nRECFIL_ 7

//Variaveis de ListBox (Folders)
#DEFINE _nEXAMES_ 1
#DEFINE _nPSAUDE_ 2
#DEFINE _nATEMED_ 3
#DEFINE _nATEASO_ 4
#DEFINE _nDIAMED_ 5
#DEFINE _nQUESTI_ 6
#DEFINE _nATEENF_ 7
#DEFINE _nVACINA_ 8
#DEFINE _nRESTRI_ 9
#DEFINE _nDOENCA_ 10
#DEFINE _nACIDEN_ 11

//Definicoes fixas de tamanho
#DEFINE _nQTDTIT_ 15//Quantidade de caracteres utilizados no titulo
#DEFINE _nQTDSEP_ 75//Quantidade de caracteres de separacao de campos

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTC990
Consulta do Historico Pregresso do Funcionario

@return

@param cFicha - Codigo da Ficha Medica a ser considerada no historico

@sample
MDTC990( "000000000001" )

@author Jackson Machado
@since 06/02/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDTC990( cFicha )

	//-------------------------------------------------
	// Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	//-------------------------------------------------
	Local aNGBEGINPRM 	:= NGBEGINPRM( )

	Private aRotina   	:= MenuDef()
	Private cCadastro 	:= STR0001 //"Histórico Pregresso"

	Default cFicha    	:= If( IsInCallStack( "MDTA110" ) , TM0->TM0_NUMFIC , "" )

	If Empty( cFicha )
		mBrowse( 6 , 1 , 22 , 75 , "TM0" , , , , , , fFichaCor() )
	Else
		MDTCH990( cFicha )
	EndIf

	//-------------------------------------------------
	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	//-------------------------------------------------
	NGRETURNPRM(aNGBEGINPRM)

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} MDTCH990
Monta consulta do Historico

@return

@param cFicha - Indica a ficha médica que será considerada para o histórico

@sample
MDTCH990( '000000000001' )

@author Jackson Machado
@since 06/02/2013
/*/
//---------------------------------------------------------------------
Function MDTCH990( cFicha )

	//Variaveis de Controle
	Local nReg 		:= 0 //Indica o recno no registro para utilizacao na Enchoice
	Local nItens	:= 0 //Contador de For
	Local lChange	:= .F.

	//Variaveis de List
	Local aItens 	:= {}//Array com os itens do List de Filial
	Local aTamanho	:= {}//Array com os tamanhos dos itens do List de Filial
	Local aFiliais 	:= {}//Array com todas as filiais do funcionario
	Local aInforms	:= {}//Array onde ira ter todas as opcoes - Criado array unico de posicoes correspondente a quantidade de tabelas
	Local aObjetos	:= {}//Array onde ira guardar todos os objetos - Criado array unico de posicoes correspondente a quantidade de tabelas
	Local aTabelas	:= {}//Array com todas as tabelas utilizadas
	Local aTabSeg	:= {}//Array com todas as tabelas secundarias utilizadas na abertura de empresa
	Local aRotList	:= {}//Array com todas a rotinas de cada tabelas

	//Array de propriedades - Criado array unico de posicoes correspondente a quantidade de tabelas
	Local aPropFol  := {}//Array contendo todas as propriedades de campos
	Local aTamFol	:= {}//Array contendo todos os tamanhos dos campos dos Lists de Informacoes do Funcionario
	Local aItensFol	:= {}//Array contendo todos os itens dos campos dos Lists de Informacoes do Funcionario
	Local aCamFol	:= {}//Array contendo todos os campos dos Lists de Informacoes do Funcionario

	//Variaveis de Folder
	Local aTitles	:= {}//Titulos
	Local aPages	:= {}//Paginas

	//Variaveis de tamanho de tela
	Local lEnchBar	:= .T. // Indica se a janela de diálogo possuirá enchoicebar
	Local lPadrao	:= .F. // Indica se a janela deve respeitar as medidas padrões do Protheus (.T.) ou usar o máximo disponível (.F.)
	Local nMinY		:= 430 // Altura mínima da janela
	Local aSize 	:= MsAdvSize( lEnchBar , lPadrao , nMinY )
	Local aObjects 	:= {}
	Local aInfo 	:= {}
	Local aPosObj 	:= {}

	//Definicao de cores
	Local aCores := NGCOLOR()

	//Define objetos de tela
	//Dialogs
	Local oDialog
	//Paineis
	Local oPnlPai, oPnlTop, oPnlBottom
	Local oPnlRight, oPnlLeft
	Local oPnlDesc1, oPnlDesc2
	//Lists
	Local oList
	//Lists do Folder
	Local oListLExa, oListLPSa, oListLAtM
	Local oListLAtA, oListLDia, oListLQue
	Local oListLAtE, oListLVac, oListLRes
	Local oListLDoe, oListLAci
	//Enchoices
	Local oEnchoice
	//Folder
	Local oFolder
	//Paineis do Folder
	Local oPnlLExa, oPnlLPSa, oPnlLAtM
	Local oPnlLAtA, oPnlLDia, oPnlLQue
	Local oPnlLAtE, oPnlLVac, oPnlLRes
	Local oPnlLDoe, oPnlLAci

	Private lSigaMdtps := .F.//Define prestador de servico como falso, funcionalidade nao disponivel

    //Caso ficha nao seja passada inicializa ela vazia
	Default cFicha := ""

	//Verifica a existencia das variaveis de tela, caso existam, limpa
	If Type("aGets") == "A"
		aGets := {}
	EndIf
	If Type("aTela") == "A"
		aTela := {}
	EndIf

	//Define as tabelas que serao utilizadas
	aAdd( aTabelas , "TM5" )
	aAdd( aTabelas , "TMN" )
	aAdd( aTabelas , "TNY" )
	aAdd( aTabelas , "TMY" )
	aAdd( aTabelas , "TMT" )
	aAdd( aTabelas , "TMI" )
	aAdd( aTabelas , "TL5" )
	aAdd( aTabelas , "TL9" )
	aAdd( aTabelas , "TMF" )
	aAdd( aTabelas , "TNA" )
	aAdd( aTabelas , "TNC" )

	//Define as tabelas dependentes que serao utilizadas
	aAdd( aTabSeg , { "TM0" , 1 } )
	aAdd( aTabSeg , { "SA1" , 1 } )
	aAdd( aTabSeg , { "SA2" , 1 } )
	aAdd( aTabSeg , { "SRA" , 1 } )
	aAdd( aTabSeg , { "SR8" , 1 } )
	aAdd( aTabSeg , { "TM4" , 1 } )
	aAdd( aTabSeg , { "TMR" , 1 } )
	aAdd( aTabSeg , { "TLG" , 1 } )
	aAdd( aTabSeg , { "TMO" , 1 } )
	aAdd( aTabSeg , { "TMC" , 1 } )
	aAdd( aTabSeg , { "TM9" , 1 } )
	aAdd( aTabSeg , { "TM4" , 1 } )
	aAdd( aTabSeg , { "TN4" , 1 } )
	aAdd( aTabSeg , { "TM8" , 1 } )
	aAdd( aTabSeg , { "TM1" , 1 } )
	aAdd( aTabSeg , { "TM2" , 1 } )
	aAdd( aTabSeg , { "TNP" , 1 } )
	aAdd( aTabSeg , { "TMK" , 1 } )
	aAdd( aTabSeg , { "SP6" , 1 } )
	aAdd( aTabSeg , { "SRJ" , 1 } )
	aAdd( aTabSeg , { "TKI" , 1 } )
	aAdd( aTabSeg , { "TKJ" , 1 } )
	aAdd( aTabSeg , { "TKK" , 1 } )
	aAdd( aTabSeg , { "TMG" , 1 } )
	aAdd( aTabSeg , { "TMH" , 1 } )
	aAdd( aTabSeg , { "TME" , 1 } )
	aAdd( aTabSeg , { "TL6" , 1 } )
	aAdd( aTabSeg , { "TL7" , 1 } )
	aAdd( aTabSeg , { "TL8" , 1 } )
	aAdd( aTabSeg , { "TNG" , 1 } )
	aAdd( aTabSeg , { "TNH" , 1 } )
	aAdd( aTabSeg , { "TNL" , 1 } )
	aAdd( aTabSeg , { "TNM" , 1 } )
	aAdd( aTabSeg , { "TNM" , 1 } )
	aAdd( aTabSeg , { "TOI" , 1 } )
	aAdd( aTabSeg , { "TOJ" , 1 } )
	aAdd( aTabSeg , { "CTT" , 1 } )
	aAdd( aTabSeg , { "TN5" , 1 } )
	aAdd( aTabSeg , { "TO4" , 1 } )
	aAdd( aTabSeg , { "TNE" , 1 } )
	aAdd( aTabSeg , { "TLZ" , 1 } )
	aAdd( aTabSeg , { "TMS" , 1 } )
	aAdd( aTabSeg , { "TMW" , 1 } )
	aAdd( aTabSeg , { "TMU" , 1 } )
	aAdd( aTabSeg , { "TOG" , 1 } )
	aAdd( aTabSeg , { "TK0" , 1 } )
	aAdd( aTabSeg , { "TMD" , 1 } )
	aAdd( aTabSeg , { "TY3" , 1 } )

	//Define as Rotinas de cada tabela para validacao pelo SBIS
	aAdd( aRotList , "MDTA120" )
	aAdd( aRotList , "MDTA115" )
	aAdd( aRotList , "MDTA685" )
	aAdd( aRotList , "MDTA200" )
	aAdd( aRotList , "MDTA155" )
	aAdd( aRotList , "MDTA145" )
	aAdd( aRotList , "MDTA161" )
	aAdd( aRotList , "MDTA530" )
	aAdd( aRotList , "MDTA110" )
	aAdd( aRotList , "MDTA110" )
	aAdd( aRotList , "MDTA640" )

	//Valida se pode utilizar a rotina
	If !fValRot( aTabelas )
		Return
	EndIf

	//Caso Prestador de Serviço, histórico eh diferente, portanto esta rotina nao eh utilizada
	If SuperGetMv("MV_MDTPS",.F.,"N") == "S"
		ShowHelpDlg( STR0002 , ; //"ATENÇÃO"
					{ STR0003 } , 2 , ; //"Opção não disponível para Prestador de Serviço."
					{ STR0004 } , 2 ) //"Favor contate administrador de sistema."
		Return
	EndIf

	//Monta heranca no array de objetos
	aAdd( aObjetos , oPnlLExa )
	aAdd( aObjetos , oPnlLPSa )
	aAdd( aObjetos , oPnlLAtM )
	aAdd( aObjetos , oPnlLAtA )
	aAdd( aObjetos , oPnlLDia )
	aAdd( aObjetos , oPnlLQue )
	aAdd( aObjetos , oPnlLAtE )
	aAdd( aObjetos , oPnlLVac )
	aAdd( aObjetos , oPnlLRes )
	aAdd( aObjetos , oPnlLDoe )
	aAdd( aObjetos , oPnlLAci )

	//Montagem dos itens do List de Filiais
	//Titulos
	aAdd( aItens , STR0005 ) //"Empresa"
	aAdd( aItens , STR0006 ) //"Filial"
	aAdd( aItens , STR0007 ) //"Nome"
	aAdd( aItens , STR0008 ) //"Dt. Inicio"
	aAdd( aItens , STR0009 ) //"Dt. Final"
	aAdd( aItens , STR0010 ) //"Matrícula"

	//Tamanhos
	aAdd( aTamanho , 30 )
	aAdd( aTamanho , 30 )
	aAdd( aTamanho , 120 )
	aAdd( aTamanho , 30 )
	aAdd( aTamanho , 30 )
	aAdd( aTamanho , 30 )

	//Recebe as propriedades dos Lists de Informacoes
	aPropFol	:= fRetProp( aTabelas ) //Retornas as Propriedades dos Folders ( 1 - Itens ; 2 - Tamanhos ; 3 - Campos )
	aItensFol	:= aPropFol[ 1 ]//Retorna o cabeçalho de cada item
	aTamFol		:= aPropFol[ 2 ]//Retorna o tamanho de cada item
	aCamFol		:= aPropFol[ 3 ]//Retorna os campos de cada item

	//Montagem das Abas do Folder
	//Titulos
	aAdd( aTitles , OemToAnsi( STR0011 ) ) //"Exames"
	aAdd( aTitles , OemToAnsi( STR0012 ) ) //"Prog. Saúde"
	aAdd( aTitles , OemToAnsi( STR0013 ) ) //"Atest. Med."
	aAdd( aTitles , OemToAnsi( STR0014 ) ) //"ASO's"
	aAdd( aTitles , OemToAnsi( STR0015 ) ) //"Diag. Med."
	aAdd( aTitles , OemToAnsi( STR0016 ) ) //"Questionários"
	aAdd( aTitles , OemToAnsi( STR0017 ) ) //"Atend. Enfer."
	aAdd( aTitles , OemToAnsi( STR0018 ) ) //"Vacinas"
	aAdd( aTitles , OemToAnsi( STR0019 ) ) //"Restrições"
	aAdd( aTitles , OemToAnsi( STR0020 ) ) //"Doenças"
	aAdd( aTitles , OemToAnsi( STR0021 ) ) //"Acidentes"
	//Paginas
	aAdd( aPages , "Header 1" )
	aAdd( aPages , "Header 2" )
	aAdd( aPages , "Header 3" )
	aAdd( aPages , "Header 4" )
	aAdd( aPages , "Header 5" )
	aAdd( aPages , "Header 6" )
	aAdd( aPages , "Header 7" )
	aAdd( aPages , "Header 8" )
	aAdd( aPages , "Header 9" )
	aAdd( aPages , "Header 10" )
	aAdd( aPages , "Header 11" )

	//Definicoes de tamanho de tela
	aAdd( aObjects, { 100, 100, .T., .T. } )
	aAdd( aObjects, { 315,  70, .T., .T. } )
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3 , 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .F. )

	//----------------------------------------
	// Definicoes de tabela e ambiente
	//----------------------------------------

	//Caso ficha medica vazia, pega a ficha medica posicionada
	If Empty( cFicha ) .Or. cFicha == "TM0"
		cFicha := TM0->TM0_NUMFIC
	Else
		dbSelectArea( "TM0" )
		dbSetOrder( 1 )
		dbSeek( xFilial("TM0") + cFicha )
	EndIf

	dbSelectArea( "SRA" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "SRA" , TM0->TM0_FILFUN ) + TM0->TM0_MAT )

	nReg := TM0->( Recno() )//Salva o recno da ficha médica

    //Define como visualizacao
    aRotSetOpc( "TM0" , @nReg , 2 )

    //----------------------------------------
	// Fim das Definicoes de tabela e ambiente
	//----------------------------------------

	//Realiza a busca das filiais do funcionario
	aFiliais := fBuscaHist()

	If Len( aFiliais ) <= 0//Caso nao possua filiais antigas, exibe mensagem e sai da rotina
		MsgStop( STR0022 ) //"Não há dados para montagem da consulta."
		Return
	EndIf

	//Chama funcao da troca de linha das filiais para montar a primeira carga de informacoes
	MsgRun( STR0023 , , ; //"Processando Registros"
			{ || fChange( aTabelas , aCamFol , @aInforms , aFiliais , 1 , , , aRotList , aTabSeg ) } )


	Define MsDialog oDialog Title OemToAnsi( cCadastro ) From aSize[ 7 ] , 0 To aSize[ 6 ] , aSize[ 5 ] Of oMainWnd Pixel
		//Panel criado para correta disposicao da tela
		oPnlPai := TPanel():New( , , , oDialog , , , , , , , , .F. , .F. )
			oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

			//-------------------------------------------------------------------------
			// Elementos da parte superior da tela (Informacoes da Ficha e Historico)
			//-------------------------------------------------------------------------
			oPnlTop := TPanel():New( , , , oPnlPai , , , , , , , 160 , .F. , .F. )
	        	oPnlTop:Align := CONTROL_ALIGN_TOP

	            //Enchoice de Informacoes da Ficha
	        	oPnlLeft := TPanel():New( , , , oPnlTop , , , , , , aSize[ 5 ] / 4 , , .F. , .F. )
	        		oPnlLeft:Align := CONTROL_ALIGN_LEFT
		        	oPnlDesc1 := TPanel():New( , , , oPnlLeft , , , , , aCores[ 2 ] , , 20 , .T. , .F. )
						oPnlDesc1:Align := CONTROL_ALIGN_TOP
						TSay():New( 05 , 10 , { | | STR0024 } , oPnlDesc1 , , , , , , .T. , aCores[ 1 ] ) //"Dados da Ficha Médica"

		        	//Monta enchoice de visualizacao da ficha medica
		        	oEnchoice := MsmGet():New( "TM0" , nReg , 2 , , , , , , , , , , , oPnlLeft )
		        		oEnchoice:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	        	//Lista com o historico de Filiais
	        	oPnlRight := TPanel():New( , , , oPnlTop , , , , , , , , .F. , .F. )
	             	oPnlRight:Align := CONTROL_ALIGN_ALLCLIENT
		             	oPnlDesc2 := TPanel():New( , , , oPnlRight , , , , , aCores[ 2 ] , , 20 , .T. , .F. )
						oPnlDesc2:Align := CONTROL_ALIGN_TOP
						TSay():New( 05 , 10 , { | | STR0025 } , oPnlDesc2 , , , , , , .T. , aCores[ 1 ] )//"Listagem das Filiais do Funcionário"

	             	// Monta listagem das filiais
	             	// Obs: no bloco de codigo bChange, foi criada a verificao com o lChange pois estava chamando tambem apos a criacao
	             	// visto que a funcao deveria ser chamada apenas na primeira troca, desta forma estava causando mau-funcionamento
	             	// (P.O.G.)
	             	oList := TWBrowse():New( 00 , 00 , 1000 , 1000 , , aItens , aTamanho ,;
	             			 oPnlRight , , , ,;
	             			 { | | If( lChange , ;
	             			 			MsgRun( STR0023 , , ; //"Processando Registros"
	             			 			{ || oDialog:Disable() , fChange( aTabelas , aCamFol , @aInforms , aFiliais , oList:nAt , ;
	             			 			oFolder , aObjetos , aRotList , aTabSeg ) , oDialog:Enable() } ), ;
	             			 			lChange := .T. ) , oList:SetFocus() } , ;
	             			 , , , , , , , .T. , , .T. , , .F. , , , )
	             	 	oList:SetArray( aFiliais )//Seta o array de filiais
	             	 	oList:bLine := { | |	{	aFiliais[ oList:nAt , _nEMPRES_ ] , ;
													aFiliais[ oList:nAt , _nFILIAL_ ] , ;
													aFiliais[ oList:nAt , _nNOMFIL_ ] , ;
													aFiliais[ oList:nAt , _nDTENTR_ ] , ;
													aFiliais[ oList:nAt , _nDTSAID_ ] , ;
													aFiliais[ oList:nAt , _nMATRIC_ ] } }//Define a visualizacao de cada posicao
						oList:Align := 	CONTROL_ALIGN_ALLCLIENT
	        //-------------------------------------------------------------------------
			// Elementos da parte inferior da tela (Folders)
			//-------------------------------------------------------------------------
			oPnlBottom := TPanel():New( 00 , 00 , , oPnlPai , , , , , , 00 , 00 , .F. , .F. )
		        oPnlBottom:Align := CONTROL_ALIGN_ALLCLIENT

		        //Criacao do Folder
		        oFolder := TFolder():New( 00 , 00 , aTitles , aPages , oPnlBottom , , , , .F. , .F. , 1000 , 1000 , )
					oFolder:Align 		:= CONTROL_ALIGN_ALLCLIENT
					oFolder:bChange 	:= { | | fAtuObj( aObjetos , oFolder:nOption ) }
					//---------------------------
					// Montagem de Folders
					//---------------------------
					For nItens := 1 To Len( aTabelas )

						//Monta os botoes na lateral
						fMontaBtnVis( @aObjetos[ nItens ] , oFolder:aDialogs[ nItens ] , aCores , oFolder , ;
										@aObjetos , aInforms , aTabelas , aFiliais , oList , aTamFol , aCamFol , aTabSeg )

						If nItens == _nEXAMES_//Caso posicao corresponde a posicao de exames, adiciona bota de resultado
							oBtnRes  := TBtnBmp():NewBar( "ng_ico_exame1" , "ng_ico_exame1" , , , , ;
												{|| fResultado( oFolder:nOption , aObjetos , aInforms , aFiliais , oList ) } ,;
												, aObjetos[ nItens ] , , ,;
												STR0026 , , , , , "" ) //"Resultado"
								oBtnRes:Align  := CONTROL_ALIGN_TOP
						ElseIf nItens == _nDIAMED_ .Or. nItens == _nATEENF_//Caso posicao coresponde a posicao de diagnostico ou enfermagem, adiciona o botao de medicamentos
							oBtnMed  := TBtnBmp():NewBar( "ng_ico_medica3" , "ng_ico_medica3" , , , , ;
												{|| fMedicamentos( oFolder:nOption , aObjetos , aInforms , aFiliais , oList ) } ,;
												, aObjetos[ nItens ] , , ,;
												STR0027 , , , , , "" ) //"Medicamentos"
							oBtnMed:Align  := CONTROL_ALIGN_TOP
						EndIf

						//Monta o objeto de list
						fMontaList( @aObjetos[ nItens ] , oFolder:aDialogs[ nItens ] , aItensFol[ nItens ] , ;
									aTamFol[ nItens ] , nItens , @aInforms )

					Next nItens

					//Verificacoes finais para desabilitar folders sem informacoes
					fDesabilita( oFolder , aInforms )

	Activate MsDialog oDialog Centered On Init EnchoiceBar( oDialog , {|| oDialog:End() } , {|| oDialog:End() } )

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de Menu Funcional.

@return aRotina  - 	Array com as opções de menu.
					Parametros do array a Rotina:
					1. Nome a aparecer no cabecalho
					2. Nome da Rotina associada
					3. Reservado
					4. Tipo de Transa‡„o a ser efetuada:
						1 - Pesquisa e Posiciona em um Banco de Dados
						2 - Simplesmente Mostra os Campos
						3 - Inclui registros no Bancos de Dados
						4 - Altera o registro corrente
						5 - Remove o registro corrente do Banco de Dados
					5. Nivel de acesso
					6. Habilita Menu Funcional

@sample
MenuDef()

@author Jackson Machado
@since 06/02/2013
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := { 	{ STR0028 , "AxPesqui" , 0 , 1 } , ; //"Pesquisa"
				  		{ STR0029 , "MDTCH990" , 0 , 2 } } //"Histórico"

Return aRotina
//---------------------------------------------------------------------
/*/{Protheus.doc} fBuscaHist
Função que realiza a busca das filiais no historico do funcionario

@return Array - Contem as filiais no formato { 'EMPRESA' , 'FILIAL' , 'NOME' , dDataInicio , dDataFim }

@sample
fBuscaHist()

@author Jackson Machado
@since 13/02/2013
/*/
//---------------------------------------------------------------------
Static Function fBuscaHist()

	Local nFil      := 0 //Contador do FOR
	Local nRecno	:= 0 //Salva o Recno
	Local cCondCus	:= Space( Len( SRA->RA_CC ) ) //Condicao de validacao da troca de centro de custo
	Local cCondALL	:= Space( 10 ) //Condicao principal da pesquisa
	Local cKeyEmp	:= cEmpAnt //Chave Empresa
	Local cKeyFil	:= SRA->RA_FILIAL //Chave Filial
	Local cKeyMat	:= SRA->RA_MAT //Chave Matricula
	Local cKeyCus	:= SRA->RA_CC //Chave Centro Custo
	Local dDtFimF	:= If( Empty( SRA->RA_DEMISSA ) , dDataBase , SRA->RA_DEMISSA ) //Data de controle das saídas
	Local dDtEntr	:= SToD( Space( 8 ) ) //Data de Controle das entradas
	Local dINITMP	:= SRA->RA_ADMISSA //Data Admissao
	Local lPrimeiro	:= .T. //Indica se eh primeiro registro computado
	Local lEncerra	:= .F. // Verifica se acabou o historico de setores
	Local aFiliais 	:= {} //Filiais do Funcionario - Nesta funcao o RECNO eh incluida no Array para possivel reordenacao
	Local aArea		:= GetArea()//Salva a area de trabalho atual

	While !lEncerra
		//Reseta variaveis para iniciar a verificacao a cada passagem e reducao de datas
		lPrimeiro 	:= .T.
		dDtEntr		:= SToD( Space( 8 ) )
		cCondCus  	:= cKeyCus
		cCondALL  	:= cKeyEmp + Padr( cKeyFil , Len( SRE->RE_FILIALD ) ) + cKeyMat
		Dbselectarea( "SRE" )
		Dbsetorder( 2 )//RE_EMPP + RE_FILIALP + RE_MATP
		Dbseek( cCondALL )//EMPRESA + FILIAL + MATRICULA
		While !eof() .and. cCondALL == SRE->RE_EMPP + SRE->RE_FILIALP + SRE->RE_MATP

				//Caso for transferido para mesma empresa, filial, matricula e C.C. desconsidera o registro
				If SRE->RE_EMPP == SRE->RE_EMPD .And. SRE->RE_FILIALP == SRE->RE_FILIALD .And. ;
					SRE->RE_MATP == SRE->RE_MATD .And. SRE->RE_CCP == SRE->RE_CCD
					Dbselectarea( "SRE" )
					Dbskip()
					Loop
				Endif

	            // Verifica se data eh superior a data fim ou inferior a data inicial, caso seja desconsidera
				If SRE->RE_DATA >= dDtFimF .Or. SRE->RE_DATA < dINITMP
					Dbselectarea( "SRE" )
					Dbskip()
					Loop
				Endif

				//Caso seja centro de custo diferente da chave, desconsidera
				If SRE->RE_CCP != cCondCus
					Dbselectarea( "SRE" )
					Dbskip()
					Loop
				Endif

				//Caso for primeira registro da chave, adiciona no array e salva novos valores para a chave
				If lPrimeiro
					cKeyEmp := SRE->RE_EMPD
					cKeyFil := SRE->RE_FILIALD
					cKeyMat := SRE->RE_MATD
					cKeyCus := SRE->RE_CCD
					dDtEntr := SRE->RE_DATA
					nRecno	:= SRE->( RECNO() )
					aADD( aFiliais , { 	SRE->RE_EMPP , ;//Empresa
										SRE->RE_FILIALP , ; //Filial
										FWFilialName( SRE->RE_EMPP , SRE->RE_FILIALP , 2 ) , ; //Nome completo
										dDtEntr , ; //Data de entrada
										dDtFimF , ; //Data de Saída
										SRE->RE_MATP , ; //Matricula
										SRE->( RECNO() ) } )
				Else
					// Caso seja segundo registro da chave, verifica se a data salva eh superior a atual
					// caso seja, adiciona a data de entrada a tada atual e troca o recno
					If SRE->RE_DATA < aFiliais[ Len( aFiliais ) ][ 4 ]
						cKeyEmp := SRE->RE_EMPD
						cKeyFil := SRE->RE_FILIALD
						cKeyMat := SRE->RE_MATD
						cKeyCus := SRE->RE_CCD
						dDtEntr := SRE->RE_DATA
						nRecno	:= SRE->( RECNO() )
						aFiliais[ Len( aFiliais ) ][ _nDTENTR_ ] := SRE->RE_DATA
						aFiliais[ Len( aFiliais ) ][ _nRECFIL_ ] := SRE->( RECNO() )
					Endif
				Endif

				lPrimeiro := .F.//Identifica que jah fez a primeira verificacao

				Dbselectarea("SRE")
				Dbskip()
		End
		If lPrimeiro
			// Caso seja primeira verifica encerra o processo, indica que acho um registro e computa o ultimo registro da SRE
			// desde que a data de inicio seja menor que a ultima data fim
			lEncerra   := .T.
			If dINITMP <= dDtFimF
				aADD(aFiliais,{ 	cKeyEmp , ; //Empresa
									cKeyFil , ; //Filial
									FWFilialName( cKeyEmp , cKeyFil , 2 ) , ; //Nome completo
									dINITMP , ; //Data de entrada
									dDtFimF , ; //Data de Saída
									cKeyMat , ; //Matricula
									nRecno - 1 } )
			Endif
		Else
			//Caso jah tenha computado o registro, salva a data fim como sendo a ultima data de entrada e continua verificando
			dDtFimF := dDtEntr
	    Endif
	End

	// Caso tenha adicionado alguma filial, ordena pelo RECNO e retira este do array
	// (necessario retirar o RECNO pois array eh utilizado no listbox)
	If Len( aFiliais ) > 0
		aFiliais := aSort( aFiliais , , , { | x , y | x[ Len( aFiliais[ 1 ] ) ] < y[ Len( aFiliais[ 1 ] ) ] } )
		For nFil := 1 To Len( aFiliais )
			aDel( aFiliais[ nFil ] , Len( aFiliais[ nFil ] ) )
			aSize( aFiliais[ nFil ] , Len( aFiliais[ nFil ] ) - 1 )
		Next nFil
	EndIf

	//Retira a ultima posicao do array pois esta corresponde a empresa/filial atual nao sendo necessario
	aDel( aFiliais , Len( aFiliais ) )
	aSize( aFiliais , Len( aFiliais ) - 1 )

	//Retornar a area salva
	RestArea( aArea )

Return aFiliais
//---------------------------------------------------------------------
/*/{Protheus.doc} fMontaBtnVis
Funcao que realiza a montagem do painel padrao com o botao de visualizacao

@return

@param oObj 	- Objeto no qual sera criado o panel
@param oPai 	- Objeto aonde sera criado o panel
@param aCores 	- Array contendo as cores predefinidas
@param oFolder	- Objeto de Folder onde esta criando
@param aObjects - Array contendo todos os objetos criados
@param aInforms - Array contendo todas as informacoes
@param aTabelas	- Tabelas utilizadas
@param aFiliais - Array com as Filiais do Funcionario
@param oFil		- Objeto de List das Filiais
@param aTam		- Array contendo os tamanhos dos campos
@param aCps		- Array contendo os campos de cada tabela
@param aTabSeg	- Array com as tabelas secundarias a serem abertas pela empresa

@sample
fMontaBtnVis( @oObj , oPai , aCores , oFolder, aObjetos , aInformacoes , aTbl , aFil , oFil , aTam , aCps , aTabSeg )

@author Jackson Machado
@since 14/02/2013
/*/
//---------------------------------------------------------------------
Static Function fMontaBtnVis( oObj , oPai , aCores , oFolder , aObjects , aInforms , aTabelas , aFiliais , oFil , aTam , aCps , aTabSeg )
    //Objetos (Botoes)
    Local oBtnVis, oBtnImp

    //Cria um objeto panel para utilizacao dos botoes de opcao
	oObj := TPanel():New( , , , oPai , , , , , aCores[ 2 ] , 12 , , .F. , .F. )
		oObj:Align := CONTROL_ALIGN_LEFT

	    //Cria o botao de visualizacao
		oBtnVis  := TBtnBmp():NewBar( "ng_ico_visual" , "ng_ico_visual" , , , , ;
										{|| fVisualiza( oFolder:nOption , aObjects , aInforms , aTabelas , aFiliais , oFil , aTabSeg ) } ,;
										 , oObj , , , STR0030 , , , , , "" ) //"Visualizar Item"
			oBtnVis:Align  := CONTROL_ALIGN_TOP
		//Cria o botao de impressao
		oBtnImp  := TBtnBmp():NewBar( "ng_ico_imp" , "ng_ico_imp" , , , , ;
										{|| fImprimir( oFolder:nOption , aObjects , aInforms , aTabelas , ;
										aFiliais , oFil , aCps , aTam , aTabSeg ) } , , oObj , , , STR0031 , , , , , "" ) //"Imprimir"
			oBtnImp:Align  := CONTROL_ALIGN_TOP

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fVisualiza
Funcao de visualizacao Generica

@return

@param nTipVis 	- Indica qual folder foi selecionado
@param aObj 	- Array de Objetos para busca da posicao selecionada
@param aInforms	- Array contendo as informacoes
@param aTabelas	- Tabelas utilizadas
@param aFiliais - Array com as Filiais do Funcionario
@param oFil		- Objeto de List das Filiais
@param aTabSeg	- Array com as tabelas secundarias a serem abertas pela empresa

@sample
fVisualiza( 1 , aObjetos , aInformacoes , aTabelas  , aFiliais , oFil , aTabSeg )

@author Jackson Machado
@since 14/02/2013
/*/
//---------------------------------------------------------------------
Static Function fVisualiza( nTipVis , aObj , aInforms , aTabelas , aFiliais , oFil , aTabSeg )

	Local nTbl			:= 0
	Local nAt			:= 0
	Local nFil			:= oFil:nAt
	Local nOrdTMI 		:= NGRETORDEM( "TMI" , "TMI_FILIAL+TMI_NUMFIC+TMI_QUESTI+DTOS(TMI_DTREAL)+TMI_QUESTA+TMI_RESPOS" , .F. )
	Local cFichaOld
	Local cTabela		:= ""
	Local cEmpAtu		:= ""
	Local cFilAtu		:= ""
	Local cKey			:= ""//Chave de pesquisa da tabela TMI
	Local cAntEmp		:= cEmpAnt
	Local cAntFil		:= cFilAnt
	Local oObjeto 		:= aObj[ nTipVis ]
	Local aTmpGet
	Local aTmpTel
	Local aTabPrep		:= {}
	Local aInformacoes	:= aInforms[ nTipVis ]
	Local aArea			:= GetArea()
	Local aAreaTM0		:= TM0->( GetArea() )
	Local aAreaXXX		:= {}

    If Type("aGets") == "A"
		aTmpGet 		:= aClone( aGets )
		aGets 			:= {}
	EndIf
	If Type("aTela") == "A"
		aTmpTel 		:= aClone( aTela )
		aTela 			:= {}
	EndIf

	//Posiciona na Ficha Medica
    cFichaOld	:= fRetFicha( aFiliais , nFil ,.F. )

    //Salva as informacoes iniciais
    cEmpAtu := aFiliais[ nFil , _nEMPRES_ ]
	cFilAtu := aFiliais[ nFil , _nFILIAL_ ]

	If cEmpAtu <> cAntEmp .or. cFilAtu <> cAntFil//Caso empresa/filial diferente da atual, prepara ambiente
		//Ajusta tabelas para utilizacao caso troque empresa/filial
		For nTbl := 1 To Len( aTabelas )
			cTabela := aTabelas[ nTbl ]
			//Procura o primeiro indice composto por FILIAL+NUMFIC para utilizar uma pesquisa 'padrao' para todas as tabelas
			nIdx 	:= NGRETORDEM( cTabela , cTabela + "_FILIAL+" + cTabela + "_NUMFIC" , .F. )
			aAdd( aTabPrep , { aTabelas[ nTbl ] , nIdx } )
		Next nTbl

		For nTbl := 1 To Len( aTabSeg )
			aAdd( aTabPrep , aTabSeg[ nTbl ] )
		Next nTbl

		NGPrepTBL( aTabPrep , cEmpAtu , cFilAtu )

		cEmpAnt := cEmpAtu
	EndIf

	nAt := oObjeto:nAt //Verifica a posicao atual do objeto

	cTabela := aTabelas[ nTipVis ] //Salva a tabela a ser utilizada

	aAreaXXX := ( cTabela )->( GetArea() )

	//Posiciona corretamente a TM0 para correta visualizacao caso Nome da Ficha esteja disponivel
	dbSelectArea( "TM0" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "TM0" , SubStr( cFilAtu , 1 , Len( xFilial( "TM0" ) ) ) ) + cFichaOld )

	If cTabela == "TMI"//Caso seja tabela TMI, traz o cadastro de visualizacao correto
		nOrdTMI := If( nOrdTMI > 0 , nOrdTMI , 3 )

		dbSelectArea( cTabela )
		dbGoTo( aInformacoes[ nAt , Len( aInformacoes[ nAt ] ) ] )//Posiciona no registro do list
		cKey := TMI->TMI_FILIAL + TMI->TMI_NUMFIC + TMI->TMI_QUESTI + DTOS( TMI->TMI_DTREAL )//Salva a chave de pesquisa

		//Posiciona corretamente na tabela
		dbSelectArea( cTabela )
		dbSetOrder( nOrdTMI )
		dbGoTop()
		dbSeek( cKey )

		MDTA145CAD( cTabela , ( cTabela )->( Recno() ) , 1 )
	Else
		dbSelectArea( cTabela )
		dbGoTo( aInformacoes[ nAt , Len( aInformacoes[ nAt ] ) ] )
		NGCAD01( cTabela , ( cTabela )->( Recno() ) , 2 )
	EndIf

	If cEmpAtu <> cAntEmp .or. cFilAtu <> cAntFil//Caso empresa/filial diferente da atual, prepara ambiente
		NGPrepTBL( aTabPrep , cAntEmp , cAntFil )
		cEmpAnt := cAntEmp
	EndIf

	If ValType(aTmpGet) == "A"
		aGets := aClone( aTmpGet )
	EndIf
	If ValType(aTmpTel) == "A"
		aTela := aClone( aTmpTel )
	EndIf

	RestArea( aAreaXXX )
	RestArea( aAreaTM0 )
	RestArea( aArea )

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fImprimir
Funcao de impressao Generica

@return

@param nTipVis 	- Indica qual folder foi selecionado
@param aObj 	- Array de Objetos para busca da posicao selecionada
@param aInforms	- Array contendo as informacoes
@param aTabelas	- Tabelas utilizadas
@param aFiliais - Array com as Filiais do Funcionario
@param oFil		- Objeto de List das Filiais
@param aCps		- Array contendo os campos de cada tabela
@param aTabSeg	- Array com as tabelas secundarias a serem abertas pela empresa

@sample
fVisualiza( 1 , aObjetos , aInformacoes , aTabelas  , aFiliais , oFil , aCps , aTam  , aTabSeg )

@author Jackson Machado
@since 14/02/2013
/*/
//---------------------------------------------------------------------
Static Function fImprimir( nTipVis , aObj , aInforms , aTabelas , aFiliais , oFil , aCps , aTam , aTabSeg )
	Local nTbl			:= 0
	Local nAt			:= 0
	Local nFil          := oFil:nAt
	Local nTipSel		:= 1
	Local cFichaOld
	Local cTabela		:= ""
	Local cEmpAtu		:= ""
	Local cFilAtu		:= ""
	Local cAntEmp		:= cEmpAnt
	Local cAntFil		:= cFilAnt
	Local oObjeto 		:= aObj[ nTipVis ]
	Local aDados		:= {}
	Local aTabPrep		:= {}
	Local aInformacoes	:= aInforms[ nTipVis ]
	Local aArea			:= GetArea()
	Local aAreaTM0		:= TM0->( GetArea() )
	Local aAreaXXX		:= {}
	Local lRet			:= .F.

    //Posiciona na Ficha Medica
    cFichaOld	:= fRetFicha( aFiliais , nFil , .F. )
    //Salva as informacoes iniciais
    cEmpAtu := aFiliais[ nFil , _nEMPRES_ ]
	cFilAtu := aFiliais[ nFil , _nFILIAL_ ]

	If cEmpAtu <> cAntEmp .or. cFilAtu <> cAntFil//Caso empresa/filial diferente da atual, prepara ambiente
		//Ajusta tabelas para utilizacao caso troque empresa/filial
		For nTbl := 1 To Len( aTabelas )
			cTabela := aTabelas[ nTbl ]
			//Procura o primeiro indice composto por FILIAL+NUMFIC para utilizar uma pesquisa 'padrao' para todas as tabelas
			nIdx 	:= NGRETORDEM( cTabela , cTabela + "_FILIAL+" + cTabela + "_NUMFIC" , .F. )
			aAdd( aTabPrep , { aTabelas[ nTbl ] , nIdx } )
		Next nTbl

		For nTbl := 1 To Len( aTabSeg )
			aAdd( aTabPrep , aTabSeg[ nTbl ] )
		Next nTbl

		NGPrepTBL( aTabPrep , cEmpAtu , cFilAtu )
		cEmpAnt := cEmpAtu
	EndIf

	nAt := oObjeto:nAt

	cTabela := aTabelas[ nTipVis ]

	aAreaXXX := ( cTabela )->( GetArea() )

	//Posiciona corretamente a TM0 para correta visualizacao caso Nome da Ficha esteja disponivel
	dbSelectArea( "TM0" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "TM0" , SubStr( cFilAtu , 1 , Len( xFilial( "TM0" ) ) ) ) + cFichaOld )

	dbSelectArea( cTabela )
	dbGoTo( aInformacoes[ nAt , Len( aInformacoes[ nAt ] ) ] )

	fDefTipImp( @nTipSel , @lRet )

	If lRet
		// Caso tabela for de questionario
		// quando selecionado modelo 'Cadastro', chama funcao de impresao do questionario
		If cTabela == "TMI" .AND. nTipSel == 2

			aDados := {}

			//Posiciona no Registro
			dbSelectArea( cTabela )
	   		dbGoTo( aInformacoes[ nAt , Len( aInformacoes[ nAt ] ) ] )

			//Monta os dados de acordo com o relatorio - Chumbado pois o quesitonario quando desta forma tambem sera chumbado
			aAdd( aDados , TMI->TMI_QUESTI )
		 	aAdd( aDados , TMI->TMI_QUESTI )
		  	aAdd( aDados , TMI->TMI_NUMFIC )
		  	aAdd( aDados , TMI->TMI_NUMFIC )
		  	aAdd( aDados , 2 )// Filtrar questoes ?
		 	aAdd( aDados , TMI->TMI_DTREAL )
		 	aAdd( aDados , TMI->TMI_DTREAL )
		  	aAdd( aDados , 1 )// Tipo impressao ?
		  	aAdd( aDados , 1 )// Perguntas por linhas ?

			IMPMDT410( aDados )
		Else
			//Funcao padrao de impressao
			fImpCad( cTabela , nTipSel , aCps[ nTipVis ] , aInformacoes , aTam[ nTipVis ] , aInformacoes[ nAt , Len( aInformacoes[ nAt ] ) ] )
		EndIf

		If cEmpAtu <> cAntEmp .or. cFilAtu <> cAntFil//Caso empresa/filial diferente da atual, prepara ambiente
			NGPrepTBL( aTabPrep , cAntEmp , cAntFil )
			cEmpAnt := cAntEmp
		EndIf
	EndIf

	RestArea( aAreaXXX )
	RestArea( aAreaTM0 )
	RestArea( aArea )

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fMontaList
Funcao para montagem dos ListBox de informacoes

@return

@param oObj 	- Indica qual folder foi selecionado
@param oPai 	- Array de Objetos para busca da posicao selecionada
@param aItens	- Array contendo os itens do cabeçalho
@param aTamanho	- Array contendo os tamanhos do cabeçalho
@param nOpcao	- Valor do folder onde esta sendo criado
@param aInfos	- Array contendo as informacoes

@sample
fMontaList( oObjChild , oObjPai , aItens , aTam , 1 , aInformacoes )

@author Jackson Machado
@since 14/02/2013
/*/
//---------------------------------------------------------------------
Static Function fMontaList( oObj , oPai , aItens , aTamanho , nOpcao , aInfos )

    //Array para salvar a informacao do list
    Local aArray := {}

    //Salva o array com as informacoes relacionados ao folder setado
    aArray := aInfos[ nOpcao ]

    //Cria o list box se ajustanto ao tamanho total da tela
	oObj := TWBrowse():New( 00 , 00 , 1000 , 1000 , , aItens , aTamanho ,;
        oPai , , , ,{ | |  } , , , , , , , , .T. , , .T. , , .F. , , , )
        oObj:SetArray( aArray )//Define o array de listbox
        // Criada funcao no bLine para trativa correta da posicao, pois cada list possui uma quantidade
        // diferentes de posicoes e ao trocar a filial, deve-se atualiza o objeto, atualizado o list e o bLine
 		oObj:bLine := { | | fRetLine( aArray , oObj:nAt ) }
	oObj:Align := 	CONTROL_ALIGN_ALLCLIENT

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fRetLine
Retorna as informcaoes a serem apresentadas na linha

@return aRet		- Array contendo as informacoes a serem apresentadas na linha

@param aPosicioes	- Informacoes do array do listbox
@param nPosicao 	- Posicao atual do listbox

@sample
fRetLine( aArray , 1 )

@author Jackson Machado
@since 14/02/2013
/*/
//---------------------------------------------------------------------
Static Function fRetLine( aPosicoes , nPosicao )

	Local nCount 	:= 1 //Contador do For
	Local aRet		:= {}//Retorno para o bLine do List

	// Utiliza a estrutura de repeticao For para 'jogar' no retorno a quantidade correta de posicoes
	For nCount := 1 To Len( aPosicoes[ nPosicao ] )
		aAdd( aRet , aPosicoes[ nPosicao , nCount ] )
	Next nCount

Return aRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fRetProp
Retorna as propriedades de cada tabela

@return aRet		- Array bidimensional contendo as propriedade ( 1 - Informacoes ; 2 - Tamanhos )

@param aTabelas		- Tabelas a serem pesquisadas

@sample
fRetProp( aTables )

@author Jackson Machado
@since 14/02/2013
/*/
//---------------------------------------------------------------------
Static Function fRetProp( aTabelas )

	Local nTbl			:= 0//Contador do For
	Local nTMI			:= 0//Contador do For - Caso tabela TMI
	Local nTamanho		:= 0//Tamanho do Campo
	Local cTabela		:= ""//Tabela utilizada
	Local aArea 		:= GetArea()
	Local aCpsTMI		:= { "TMI_DTREAL" , "TMI_QUESTI" , "TMI_NOMQUE" }
	Local aCpsTAB		:= {}
	Local aTam          := {}
	Local cCampo		:= ''
	Local cTitulo		:= ''
	Local cUsado        := ''
	Local aTamCpo       := {}
	Local nCps          := 0
	//Array de retornos
	Local aInformacoes  := {}//Titulos
	Local aTamanhos		:= {}//Tamanho dos Campos
	Local aCampos		:= {}//Campos do SX3

	//Percorre todas as tabelas
	For nTbl := 1 To Len( aTabelas )

		cTabela := aTabelas[ nTbl ]//Salva a tabela que esta sendo utilizada

		//Para cada tabela adiciona uma posicao nos arrays de retorno
		aAdd( aCampos		, {} )
		aAdd( aInformacoes	, {} )
		aAdd( aTamanhos		, {} )

		If cTabela == "TMI" //Caso seja a tabela de questionarios, chumba os campos que irao aparecer

			For nCps := 1 To Len(aCpsTMI)

				cCampo  := aCpsTMI[ nCps ]
				cTitulo := Posicione( "SX3", 2, cCampo, "X3Titulo()" )
				cUsado  := GetSx3Cache( cCampo, "X3_USADO" )
				aTamCpo := TAMSX3(cCampo )

				nTamanho := If( Len( AllTrim( cTitulo ) ) > aTamCpo[1] , Len( cTitulo ) , aTamCpo[1] ) * 4

				aAdd( aCampos[ Len(aCampos) ]			, cCampo   )
				aAdd( aInformacoes[ Len(aInformacoes) ] , cTitulo  )
				aAdd( aTamanhos[ Len(aTamanhos) ]		, nTamanho )

			Next nCps

		Else

			aCpsTAB := APBuildHeader(cTabela)

			For nCps := 1 To Len(aCpsTAB)

				cCampo  := aCpsTAB[ nCps, 2 ]
				cTitulo := Posicione( "SX3", 2, cCampo, "X3Titulo()" )
				cUsado  := GetSx3Cache( cCampo, "X3_USADO" )
				aTamCpo := TAMSX3(cCampo )

				If GetSx3Cache( cCampo, "X3_BROWSE" ) == 'S' .And. !("NUMFIC" $ cCampo .Or. "NOMFIC" $ cCampo )

					// Pra tamanho do campo, verifica se o titulo é maior que o tamanho, caso seja, considera o titulo,
					// caso nao, multiplica-se o tamanho  por 4 para adequacao de caracter
					nTamanho := If( Len( AllTrim( cTitulo ) ) > aTamCpo[1] , Len( cTitulo ) , aTamCpo[1] ) * 4
					aAdd( aCampos[ Len(aCampos) ]			, cCampo   )
					aAdd( aInformacoes[ Len(aInformacoes) ] , cTitulo  )
					aAdd( aTamanhos[ Len(aTamanhos) ]		, nTamanho )

				EndIf

			Next nCps

		EndIf

		//Adiciona campo de RECNO como padrao para as tabelas
		aAdd( aCampos[ Len(aCampos) ]			, "RECNO" )
		aAdd( aInformacoes[ Len(aInformacoes) ] , "Recno" )
		aAdd( aTamanhos[ Len(aTamanhos) ]		, 10      )

	Next nTbl

	RestArea( aArea )

Return { aInformacoes , aTamanhos , aCampos }//Retorna os 3 arrays

//---------------------------------------------------------------------
/*/{Protheus.doc} fChange
Função chamada ao trocar de linha no ListBox - Alimenta o array com as informacoes do funcionario

@return Lógico - Sempre verdadeiro

@param aTabelas		- Tabelas a serem pesquisadas
@param aCampos		- Campos a serem considerados no array
@param aInformacoes	- Array onde serao armazenadas todas as informacoes
@param aFiliais		- Array contendo todas as filiais
@param nPosFil		- Valor da posicao da filial no Array aFiliais
@param oFolder		- Objeto Folder para verificar se habilita/desabilita abas
@param aObjetos		- Array de Objetos de ListBox
@param aRotList		- Array com as rotinas a serem verificadas
@param aTabSeg		- Array com as tabelas secundarias a serem abertas pela empresa

@sample
fChange( aTables , aCps , @aInfo , aFil , 1 , oFolder , aObjetos )

@author Jackson Machado
@since 14/02/2013
/*/
//---------------------------------------------------------------------
Static Function fChange( aTabelas , aCampos , aInformacoes , aFiliais , nPosFil , oFolder , aObjetos , aRotList , aTabSeg )

	Local nTbl 	   		:= 0//Contador de tabelas
	Local nCps 			:= 0//Contador de Campos
	Local nIdx      	:= 0//Variavel que recebera os indices de cada tabela
	Local cTabela		:= ""//Salva a tabela que esta sendo utilizada
	Local cEmpList  	:= ""//Salva a empresa que esta sendo utilizada
	Local cFilList		:= ""//Salva a filial que esta sendo utilizada
	Local cAntEmp		:= cEmpAnt
    Local cAntFil		:= cFilAnt
	Local cFichaOld 	:= fRetFicha( aFiliais , nPosFil )
	Local cCampVal		:= ""//Variavel que recebera o campo de usuario de inclusao caso este exista na tabela
	Local cComboBox		:= ""//Variavel que recebera o valor do combobox caso campo deste tipo
	Local xInform  		:= ""//Vaviavel que recebera o valor do campo da tabela. Criada como x pois podera receber todos os valores (C,D,L,N)
	Local dDtEntra		:= dDataBase//Salva a data de entrada que esta sendo utilizada
	Local dDtSaida		:= dDataBase//Salva a data de saida que esta sendo utilizada
	Local dDtValid  	:= dDataBase//Salva a data para validacao
	Local aTabPrep		:= {}//Armazena as tabelas preparadas para varredura de busca
	Local aTabTbl		:= {}//Armazena as tabelas preparadas para abertura de ambiente em nova empresa/filial
	Local aArea			:= GetArea()
	Local aAreaTM0		:= TM0->( GetArea() )
	Local oObj //Variavel que ira receber o valor correspondente ao objeto do list
	Local lNG2Seg       := SuperGetMV( "MV_NG2SEG" , .F. , "2" )

	// Define os dois ultimos objetos como caracter "-1" pois como funcao chamada para criar os array antes da montagem da tela
	// atualizacoes dos objetos so serao dadas na troca de linha
	Default oFolder 	:= "-1"
	Default aObjetos	:= "-1"

	If ValType( oFolder ) == "O"
		oFolder:SetOption( 1 )//Seta o folder na primeira posicao para nao dar erro
	EndIf

	//Salva as informacoes iniciais
	cEmpList := aFiliais[ nPosFil , _nEMPRES_ ]
	cFilList := aFiliais[ nPosFil , _nFILIAL_ ]
	dDtEntra := aFiliais[ nPosFil , _nDTENTR_ ]
	dDtSaida := aFiliais[ nPosFil , _nDTSAID_ ]

	//Ajusta tabelas para utilizacao caso troque empresa/filial
	For nTbl := 1 To Len( aTabelas )
		cTabela := aTabelas[ nTbl ]
		//Procura o primeiro indice composto por FILIAL+NUMFIC para utilizar uma pesquisa 'padrao' para todas as tabelas
		nIdx 	:= NGRETORDEM( cTabela , cTabela + "_FILIAL+" + cTabela + "_NUMFIC" , .F. )
		aAdd( aTabPrep , { aTabelas[ nTbl ] , nIdx } )
	Next nTbl

	//Salva as tabelas principais preparadas
	aTabTbl := aClone( aTabPrep )

	For nTbl := 1 To Len( aTabSeg )
		aAdd( aTabTbl , aTabSeg[ nTbl ] )
	Next nTbl

	If cEmpList <> cAntEmp .or. cFilList <> cAntFil//Caso empresa/filial diferente da atual, prepara ambiente
		NGPrepTBL( aTabTbl , cEmpList , cFilList )
		cEmpAnt := cEmpList
	EndIf

	aInformacoes := {}//Zera o array de informacoes

	//Percorre tabela por tabela para adicionar no array
	For nTbl := 1 To Len( aTabPrep )
		cTabela := aTabPrep[ nTbl , 1 ]

		//A cada nova tabela, adiciona uma posicao no array de informacoes
		aAdd( aInformacoes , {} )

		nIdx := aTabPrep[ nTbl , 2 ] //Recebe o indice

		//Verifica se possui algum registro nesta empresa
		dbSelectArea( cTabela )
		dbSetOrder( nIdx )

		If dbSeek( xFilial( cTabela , SubStr( cFilList , 1 , Len( xFilial( cTabela ) ) ) ) + cFichaOld ) .AND. ;
			If( lNG2Seg == "1" , ;
				MDTVALUSR( aRotList[ nTbl ] , cUserName ) , .T. ) .AND. fValRotUsr( aRotList[ nTbl ] )

			//Caso possua, percorre todos os registros daquela FILIAL+NUMFIC
			While ( cTabela )->( !Eof() ) .AND. ;
				&( cTabela + "_FILIAL == '" + ;
						xFilial( cTabela , SubStr( cFilList , 1 , Len( xFilial( cTabela ) ) ) ) + "' .AND. " + ;
						cTabela + "_NUMFIC == '" + cFichaOld + "'" )
				// Verifica se existe o campo de usuario de inclusao, caso exista, valida se registro foi incluso
				// entre as datas onde o funcionario estava na filial, caso nao exista, considera o registro
				cCampVal := ""

				If ( cTabela )->( FieldPos( PrefixoCpo( cTabela ) + "_USERGI" ) ) > 0
					cCampVal := cTabela + "_USERGI"
				EndIf

				If ( cTabela )->( FieldPos( PrefixoCpo( cTabela ) + "_USERLGI" ) ) > 0
					cCampVal := cTabela + "_USERGI"
				EndIf
				If !Empty( cCampVal )
					dDtValid := MDTDATALO( cTabela + "->" + cCampVal )
					If dDtValid > dDtSaida .AND. dDtValid < dDtEntra
						( cTabela )->( dbSkip() )
						Loop
					EndIf
				EndIf

				//Caso for Tabela TMI e já estiver contido chave no array, nao adiciona
				If cTabela == "TMI" .AND. aScan( aInformacoes[ nTbl ] , { | x | x[ 1 ] == &( aCampos[ nTbl , 1 ] ) .AND. ;
																					x[ 2 ] == &( aCampos[ nTbl , 2 ] ) } ) > 0
					( cTabela )->( dbSkip() )
					Loop
				EndIf

				//Para cada registro, adiciona uma posicao no array de informacoes na tabela atual
				aAdd( aInformacoes[ nTbl ] , {} )

				//Percorre todos os campos localizados no browse para adicionar o valor
				For nCps := 1 To Len( aCampos[ nTbl ] )
					// Caso campo nao seja virtual, verifica se eh combobox, caso seja, pega o valor do combo, caso nao
					// executa este para receber o valor
					If NGSEEKDIC( "SX3" , aCampos[ nTbl , nCps ] , 2 , "X3_CONTEXT" ) <> "V" .OR. ;
						"RECNO" $ Upper( aCampos[ nTbl , nCps ] )
					 	cComboBox := NGSEEKDIC( "SX3" , aCampos[ nTbl , nCps ] , 2 , "X3_CBOX" )
					 	If !Empty( cComboBox )//Caso combobox preenchido, indica campo combo
					 		xInform := NGRETSX3BOX( aCampos[ nTbl , nCps ] , &( cTabela + "->" + aCampos[ nTbl , nCps ] ) )
					 	ElseIf "RECNO" $ Upper( aCampos[ nTbl , nCps ] ) //Caso seja o Recno, pega o valor do recno
					 		xInform := &( cTabela + "->( Recno() )" )
					 	Else
					 		xInform := &( cTabela + "->" + aCampos[ nTbl , nCps ] )//Pega o valor da execucao do campo
					 	EndIf
					Else
						// Caso campo seja virtual, verifica se possui relacao, caso possua, utiliza o inicializador padrao
						If !Empty( NGSEEKDIC( "SX3" , aCampos[ nTbl , nCps ] , 2 , "X3_RELACAO" ) )
							xInform := InitPad( NGSEEKDIC( "SX3" , aCampos[ nTbl , nCps ] , 2 , "X3_RELACAO" ) )
						Else
							// Caso nao possua relacao, joga espacos vazios correspondentes ao tamanho do campo
						 	xInform := Space( NGSEEKDIC( "SX3" , aCampos[ nTbl , nCps ] , 2 , "X3_TAMANHO" ) )
						EndIf
					EndIf
					//Adiciona a informacao do campo no array
					aAdd( aInformacoes[ nTbl , Len( aInformacoes[ nTbl ] ) ] , xInform )
				Next nCps

				( cTabela )->( dbSkip() )
			End
		EndIf
		If Len( aInformacoes[ nTbl ] ) == 0
			// Caso nao possua registro na tabela, adiciona uma posicao no array de informacoes na tabela atual,
			// apos percorre todos os campos e vai jogando valores vazios com os tamanhos correspondentes destes
			aAdd( aInformacoes[ nTbl ] , {} )

			For nCps := 1 To Len( aCampos[ nTbl ] )
				If "RECNO" $ aCampos[ nTbl , nCps ]//Caso seja o Recno, chumba o valor deste
					aAdd( aInformacoes[ nTbl , Len( aInformacoes[ nTbl ] ) ] , Space( 10 ) )
				Else //Caso campo normal, passa vazio com o tamanho total deste
					aAdd( aInformacoes[ nTbl , Len( aInformacoes[ nTbl ] ) ] , ;
						Space( NGSEEKDIC( "SX3" , aCampos[ nTbl , nCps ] , 2 , "X3_TAMANHO" ) ) )
				EndIf
			Next nCps
		EndIf

		//Caso tenha o array de objetos, refaz os lists
		If ValType(aObjetos) == "A"
			oObj 	:= aObjetos[ nTbl ]
			oObj:SetArray( aInformacoes[ nTbl ] )//Seta novamente o array
			//Ao refazer o bLine, necessita pegar o array jah setado no objeto juntamente com a linha posicionada
			//para isso, verifica o folder selecionado e passa o array correspondente a esse (P.O.G.)
			oObj:bLine := { | | fRetLine( aObjetos[ oFolder:nOption ]:aArray , aObjetos[ oFolder:nOption ]:nAt ) }
			oObj:Refresh()
		EndIf

	Next nTbl

	If cEmpList <> cAntEmp .or. cFilList <> cAntFil//Caso tenha troca de empresa/filial, retorna para a atual
		NGPrepTBL( aTabTbl , cAntEmp , cAntFil )
		cEmpAnt := cAntEmp
	EndIf

	If ValType(oFolder) == "O"//Caso tenha o objeto de folder, habilita/desabilita as abas
		fDesabilita( oFolder , aInformacoes )
	EndIf

	RestArea( aAreaTM0 )
	RestArea( aArea )

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fRetFicha
Retorna a ficha medica correta do funcionario

@return cFichaMedica - Codigo da Ficha Medica

@param aTabelas	- Filiais a serem verificadas
@param nPosFil	- Posicao da filial a ser verificada

@sample
fRetFicha( aFiliais , 1 )

@author Jackson Machado
@since 14/02/2013
/*/
//---------------------------------------------------------------------
Static Function fRetFicha( aFiliais , nPosFil , lRetTM0 )

	Local nPosic		:= nPosFil//Salva a posicao atual da filial
	Local cFichaMedica	:= ""//Inicia o numero da ficha com branco
	Local cEmpList 		:= aFiliais[ nPosFil , _nEMPRES_ ]//Salva empresa a ser verificada
	Local cFilList 		:= aFiliais[ nPosFil , _nFILIAL_ ]//Salva filial a ser verificada
	Local cMatricula	:= aFiliais[ nPosFil , _nMATRIC_ ]//Salva matricula a ser verificada
	Local cAntEmp		:= cEmpAnt
    Local cAntFil		:= cFilAnt
	Local aArea			:= GetArea()
	Local aAreaTM0		:= TM0->( GetArea() )

	//Verifica a posicao da filial e continua ateh a ultima
	While nPosic <= Len( aFiliais )
		If cEmpList <> cAntEmp .or. cFilList <> cAntFil//Caso seja empresa/filial diferente da atual, abre a TM0 correspondente
			NGPrepTBL( { { "TM0" , 11 } } , cEmpList , cFilList )
			cEmpAnt := cEmpList
		EndIf

		//Verifica se encontra a ficha medica correspondente a matricula nesta filial, caso encontre, utiliza a ficha encontrada
		//caso nao encontre passa para a proxima filial para verifica se encontra
		dbSelectArea( "TM0" )
		dbSetOrder( 11 )
		If dbSeek( xFilial( "TM0" , SubStr( cFilList , 1 , Len( xFilial( "TM0" ) ) ) ) + cMatricula )
	 		cFichaMedica := TM0->TM0_NUMFIC//Salva a ficha medica encontrada
	 		Exit
		Else
			nPosic++
			If Len( aFiliais ) >= nPosic //Caso tamanho seja menor ou igual ao array utiliza, trato para nao ocorrer erro
				cEmpList 	:= aFiliais[ nPosic , _nEMPRES_ ]//Salva empresa a ser verificada
				cFilList 	:= aFiliais[ nPosic , _nFILIAL_ ]//Salva filial a ser verificada
				cMatricula	:= aFiliais[ nPosic , _nMATRIC_ ]//Salva matricula a ser verificada
			EndIf
		EndIf

		If cEmpList <> cAntEmp .or. cFilList <> cAntFil//Retorna para filial atual
			NGPrepTBL( { { "TM0" , 11 } } , cAntEmp , cAntFil )
			cEmpAnt := cAntEmp
		EndIf
	End

	If cEmpList <> cAntEmp .or. cFilList <> cAntFil//Retorna para filial atual
		NGPrepTBL( { { "TM0" , 11 } } , cAntEmp , cAntFil )
		cEmpAnt := cAntEmp
	EndIf

	If !lRetTM0
		RestArea( aAreaTM0 )
	EndIf
	RestArea( aArea )

Return cFichaMedica//Retorna o numero da ficha
//---------------------------------------------------------------------
/*/{Protheus.doc} fDesabilita
Verifica as informacoes para desabilitar os arrays vazios

@return

@param oFolder	- Objeto do Folder de Criacao
@param aInforms	- Array com as Informacoes

@sample
fRetFicha( oObj , aInformacoes )

@author Jackson Machado
@since 14/02/2013
/*/
//---------------------------------------------------------------------
Static Function fDesabilita( oFolder , aInforms )

    Local nPosic 	:= 1 //Define a posicao inicial do Folder
	Local nInfo		:= 0 //Contador das informacoes
	Local lVer		:= .T.

	// Foram realizadas duas verificacoes de FOR pois apos desabilitar a aba nao alterava corretamente
	// deixando o folder na aba correta porem o conteudo desta, na aba desabilitada
	For nInfo := 1 To Len( aInforms )
		//Caso array nao for vazio ou tenha apenas uma posicao e a primeira informacao desta nao esteja vazia, aba eh valida
		If !( Len( aInforms[ nInfo ] ) <= 0 .OR. ( Len( aInforms[ nInfo ] ) == 1 .AND. Empty( aInforms[ nInfo , 1 , 1 ] ) ) )
			If lVer //Verifica a primeira posicao habilitada
				lVer	:= .F.
				nPosic 	:= nInfo
				Exit
			EndIf
		EndIf
	Next nInfo

	//Habilita o Folder todo para não dar problema no Objeto
	oFolder:Enable()

	oFolder:SetOption( nPosic )//Seta o folder na primeira posicao habilitada

	If lVer//Caso nao encontre uma posicao habilitada, desabilita o folder todo
		oFolder:Disable()
	Else
		//Caso encontre uma posicao habilitada, habilita apenas as posicioes com conteudo
		For nInfo := 1 To Len( aInforms )
			// Caso array for vazio ou tenha apenas uma posicao e a primeira posicao desta esteja vazia, desabilita aba,
			// caso contrario habilita
			If Len( aInforms[ nInfo ] ) <= 0 .OR. ( Len( aInforms[ nInfo ] ) == 1 .AND. Empty( aInforms[ nInfo , 1 , 1 ] ) )
				oFolder:aEnable( nInfo , .F. )
			Else
				oFolder:aEnable( nInfo , .T. )
			EndIf
		Next nInfo
    EndIf

	//Atualiza o objeto
	oFolder:Refresh()

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fValRot
Valida se pode utilizar a rotina
Comentada a parte de validacao das tabelas para que caso futuramente seja implementada jah esteja feita corretamente

@return Lógico - Retorna verdadeiro caso possa ser utilizada a rotina

@param aTabelas - Array contendo as tabelas a serem verificadas

@sample
fRetFicha( aTabelas )

@author Jackson Machado
@since 18/02/2013
/*/
//---------------------------------------------------------------------
Static Function fValRot( aTabelas )

	Local cDescMemo	:= ""
	Local lRet		:= .T.
	Local lRetPar	:= .T.

	//Verifica se transferencia automatica esta ativada
    If cValToChar( SuperGetMv( "MV_NG2TRAN" , .F. , "1" ) ) == "1"
    	lRetPar := .F.
    EndIf

	If !lRetPar //.Or. !Empty( cTabelas )//Se parametro ativado ou alguma tabela compartilhada exibe o erro

     	lRet := .F.//Retorno fica falso

     	cDescMemo += STR0036 + CHR( 13 ) + CHR( 10 )//Mensagem padrao //"Para utilização desta funcionalidade:"

     	If !lRetPar
        	cDescMemo += STR0037 + CHR( 13 ) + CHR( 10 )//Caso parametro ativado //"O parâmetro MV_NG2TRAN deve estar desativado."
		EndIf

		NGMSGMEMO( STR0038 , cDescMemo ) //"Não Conformidade"

	EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fImpCad
Realiza a Impressao

@return

@param cTabela 		- Tabela a ser impressa
@param nTipSel 		- Tipo de Selecao ( 1 - Listagem; 2 - Cadastro
@param aCps			- Campos da Tabela
@param aInformacoes - Informacoes da Tabela
@param aTam			- Tamanho dos campos da tabela
@param nReg			- Codigo do Registro Posicionado

@sample
fRetFicha( aTabelas )

@author Jackson Machado
@since 18/02/2013
/*/
//---------------------------------------------------------------------
Static Function fImpCad( cTabela , nTipSel , aCps , aInformacoes , aTam , nReg )

    Local cString
	Local wnrel   		:= "MDTC990" //Nome do Relatorio
	Local limite  		:= 220 // Limite do Relatório
	//Descricao inicial
	Local cDesc1  		:= If( nTipSel == 1 , STR0039 , STR0040 )//"Listagem dos Registros"###"Cadastro do Registro"
	//Segunda descricao
	Local cDesc2  		:= If( nTipSel == 1 , STR0041 , ; //"Através deste relatório é possível retirar uma listagem dos registros exibidos."
												STR0042 ) //"Através deste relatório é possível visualizar o cadastro do registro."
	Local cDesc3  		:= "" //Terceira descricao
	Local aPosicoes		:= {} //Array contendo as posicoes
	Local aCabecs		:= {} //Array contendo os cabecalhos

	Private nomeprog 	:= "MDTR990"//Define o nome do programa
	Private tamanho  	:= "G"//Define o tamanho do relatorio
	//Define as propriedades do relatorio
	Private aReturn  	:= { STR0043 , 1 , STR0044 , 2 , 2 , 1 , "" , 1 } //"Zebrado"###"Administracao"
	//Define o titulo do relatorio
	Private titulo   	:= If( nTipSel == 1 , STR0039 , STR0040 )//"Listagem dos Registros"###"Cadastro do Registro"
	Private nTipo    	:= 0 //Define o tipo de acordo com as propriedades
	Private nLastKey 	:= 0 //Variavel de controle dos botoes do SetPrint
	Private cabec1, cabec2 //Cabecalhos

	aCabecs 			:= fMontaCabec( cTabela , @aPosicoes , aCps , aTam , @limite , @tamanho )//Monta os cabecalhos

	cabec1 				:= If( nTipSel == 1 , aCabecs[ 1 ] , " " )//Caso selecao for Listagem, salva primeiro cabecalho
	cabec2 				:= If( nTipSel == 1 , aCabecs[ 2 ] , " " )//Caso selecao for Listagem, salva segundo cabecalho

	cString 			:= cTabela//Salva a tabela a ser utilizada

	//-----------------------------------------
	// Envia controle para a funcao SETPRINT
	//-----------------------------------------
	wnrel := "MDTC990"
	wnrel := SetPrint( cString , wnrel , " " , titulo , cDesc1 , cDesc2 , cDesc3 , .F. , "" )

	If nLastKey == 27//Caso cancele
		Set Filter to
		Return
	Endif

	SetDefault( aReturn , cString )//Verifica os valores padroes de impressao

	If nLastKey == 27 //Caso cancele
		Set Filter to
		Return
	Endif

	//Chama funcao de impressao
	RptStatus( { | lEnd | fImprime( @lEnd , wnRel , titulo , tamanho , aInformacoes , nTipSel , aCps , aPosicoes , cTabela, nReg ) }, titulo )

	//Libera arquivo de impressao
	Set Filter To
	Set device to Screen
	If aReturn[ 5 ] == 1//Caso impressao seja em tela
	   Set Printer To
	   dbCommitAll()
	   OurSpool( wnrel )
	Endif
	MS_FLUSH()

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fMontaCabec
Monta os cabecalhos

@param cTabela 		- Tabela a ser impressa
@param aPos 		- Array contendo as posicioes a serem impressas
@param aCampos		- Campos da Tabela
@param aTam			- Tamanho dos campos da tabela
@param nLimite		- Limite de Tamanho do Relatorio
@param cTam			- Tamanho do Relatorio

@sample
fMontaCabec()

@author Jackson Machado
@since 18/02/2013
/*/
//---------------------------------------------------------------------
Static Function fMontaCabec( cTabela , aPos , aCampos , aTam , nLimite , cTam )

	//Contadores
	Local nCps		:= 0 //Campos
	Local nLin		:= 0 //Linhas
	Local nTam		:= 0 //Tamanho
	Local nCabec	:= 1 //Cabecalhos
	Local aArea		:= GetArea()

	//Cabecalhos
	Private cCabec1 := ""
	Private cCabec2 := ""

	For nCps := 1 To Len( aCampos )//Percorre todos os campos
		If nCabec > 2//Caso campos ultrapassem cabecalho 2, sai
		 	Exit
		EndIf
		If !( "RECNO" $ aCampos[ nCps ] )//Recno esta contido na array de campos, porem nao eh impresso
			aAdd( aPos , nLin )//Salva posicao no array de posicoes
			nTam	:= aTam[ nCps ]//Salva o tamanho
			If NGSEEKDIC( "SX3" , aCampos[ nCps ] , 2 , "X3_TIPO" ) == "D" //Caso tipo data, seta tamanho padrao
				nTam := 12
			ElseIf NGSEEKDIC( "SX3" , aCampos[ nCps ] , 2 , "X3_TIPO" ) == "N"
				//Caso tipo numerico, verifica se eh maior que 12 (tamanho do titulo)
				nTam := NGSEEKDIC( "SX3" , aCampos[ nCps ] , 2 , "X3_TAMANHO" )
				nTam := If( nTam > 12 , nTam , 12 )
			ElseIf nTam > 20 .AND. NGSEEKDIC( "SX3" , aCampos[ nCps ] , 2 , "X3_TIPO" ) == "C"//Caso tipo caracter, seta tamanho padrao
				nTam := 20
			EndIf
			nTam 	+= 2//Da um espacamento padrao entre cada campo
			If nLimite > nLin+nTam //Caso linha+tamanho nao ultrapassem o limente, incrementa contador da linha
				nLin += nTam
			Else
				//Caso ultrapasse, incrementa para segundo cabecalho
				nCabec ++
				If nCabec <= 2
					&( "cCabec"+cValToChar( nCabec ) ) += Space( 20 )//Salva espacamento padrao
					aPos[ Len( aPos ) ] := 20//Seleciona ultima posicao como 20
					nLin := 20 + nTam  //Salva para a proxima posicao
				EndIf
			EndIf
			If nCabec <= 2 //Caso cabecalho esteja dentro do tamanho, salva
				&( "cCabec"+cValToChar( nCabec ) ) += Padr( AllTrim( NGSEEKDIC( "SX3" , aCampos[ nCps ] , 2 , "X3Titulo()" ) ) , nTam )
			EndIf
		EndIf
	Next nCps

	If nCabec <= 2//Caso cabecalho esteja dentro do tamanho, adiciona ultima posicao no array de posicoes
		aAdd( aPos , nLin )
	EndIf

	RestArea( aArea )

Return { cCabec1 , cCabec2 }
//---------------------------------------------------------------------
/*/{Protheus.doc} fImprime
Imprime o relatório

@return

@param lEnd			- Indica se abortou opercao
@param wnRel		- Arquivo de saida	do relatorio
@param titulo		- Titulo do Relatorio
@param tamanho		- Tamanho do Relatorio
@param nTipSel 		- Tipo de Selecao ( 1 - Listagem; 2 - Cadastro
@param aInformacoes - Informacoes da Tabela
@param aCampos		- Campos da Tabela
@param aPos 		- Array contendo as posicioes a serem impressas
@param cTabela 		- Tabela a ser impressa
@param nReg			- Codigo do Registro Posicionado

@sample
fImprime()

@author Jackson Machado
@since 18/02/2013
/*/
//---------------------------------------------------------------------
Static Function fImprime( lEnd , wnRel , titulo , tamanho , aInformacoes , nTipSel , aCps , aPos , cTabela , nReg )

	Local nZ//Contador
	Local nPosicao 	:= 000 //Posicao de impressao
	Local nList 	:= 0, nCps := 0 //Contadores
	Local nCntImpr 	:= 0 //Variavel para controle do Relatorio
	Local xImpTemp 	:= "" //Variavel de impressao
	Local cRodaTxt 	:= "" //Variavel para controle do Relatorio
	Local aCampos  	:= {}
	//-------------------------------------------------
	// Contadores de linha e pagina
	//-------------------------------------------------
	Private Li := 80 , m_pag := 1

	If nTipSel == 1
		For nList := 1 To Len( aInformacoes )//Percorre todas as informacoes
			SomaLinha( .T. , nCntImpr, cRodaTxt, tamanho )//Realiza o primeiro incremento de linha
			For nCps := 1 To Len( aCps )//Percorre todos os campos da tabela
				If nCps <= Len( aPos )//Caso posicao do campo eixsta nas posicoes a serem impressas
					If nCps > 1 .AND. aPos[ nCps ] < aPos[ nCps - 1 ]
						//Sendo diferente da primeira posicao, verifica se a anterior eh maior que atual, caso seja, indica incremento de linha
						SomaLinha( , nCntImpr, cRodaTxt, tamanho )
					EndIf
					If !( "RECNO" $ aCps[ nCps ] )//Recno esta contido na array de campos, porem nao eh impresso
						xImpTemp := aInformacoes[ nList , nCps ]//Salva a informacao
						If NGSEEKDIC( "SX3" , aCps[ nCps ] , 2 , "X3_TIPO" ) == "C"//Caso seja caracter
							If Empty( xImpTemp )//Se for vazio imprime espaco em branco por problema em impressao de relatorio (P.O.G.)
								@ Li , aPos[ nCps ] Psay " " Picture PesqPict( cTabela , aCps[ nCps ] )
							ElseIf Len( AllTrim( xImpTemp ) ) > 20//Caso tamanho seja maior que 20, realiza um substr
								@ Li , aPos[ nCps ] Psay SubStr( xImpTemp , 1 , 20 ) Picture PesqPict( cTabela , aCps[ nCps ] )
							Else
								//Caso esteja tudo certo, imprime
								@ Li , aPos[ nCps ] Psay AllTrim( xImpTemp ) Picture PesqPict( cTabela , aCps[ nCps ] )
							EndIf
						Else
							//Caso seja diferente de caracter, apenas imprime
							@ Li , aPos[ nCps ] Psay xImpTemp Picture PesqPict( cTabela , aCps[ nCps ] )
						EndIf
					EndIf
				EndIf
			Next nCps
		Next nList
	Else
		dbSelectArea( cTabela )
		dbGoTo( nReg )

		aRotSetOpc( cTabela , nReg , 2 ) //Inicializa variaveis para modo de visualizacao (Ex: INCLUI e ALTERA)

		RegToMemory( cTabela , .F. )  //Inicializa variaveis de memoria (M->)

		aCampos := NGCAMPNSX3( cTabela ) //Retorna os campos do SX3 da tabela

		SomaLinha( .T. , nCntImpr, cRodaTxt, tamanho )//Realiza o primeiro incremento de linha

		For nZ := 1 To Len(aCampos) //Percorre todos os campos

			dbSelectArea( "SX3" )
			dbSetOrder( 2 )
			dbSeek( aCampos[ nZ ] )//Posiciona no campo do SX3

			fImpCampo( Li , @nPosicao , aCampos , nZ , cTabela , nCntImpr, cRodaTxt, tamanho ) //Funcao de impressao dos campos da tabela

			If nPosicao > 145 //Caso posicao ultrapasse o limete zera e pula linha
				nPosicao := 000
				SomaLinha( , nCntImpr, cRodaTxt, tamanho )
			Else
				nPosicao += _nQTDSEP_//Incremento padrao de distancia de campos
			Endif

		Next nZ
	EndIf

	//Imprime o ultimo rodape antes da saida
	Roda( nCntImpr , cRodaTxt , tamanho )

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} Somalinha
Controle de saltos de paginas e linhas

@return

@param lPrimeiro 	- Indica se eh a primeira passagem
@param nCntImpr		- Contador de impressao ( Parametro Reservado da Funcao Roda )
@param cRodaTxt		- Texto de Impressao do Rodape ( Parametro Reservado da Funcao Roda )
@param tamanho		- Indica o tamanho do Relatorio
@sample
Somalinha()

@author Jackson Machado
@since 18/02/2013
/*/
//---------------------------------------------------------------------
Static Function Somalinha( lPrimeiro , nCntImpr , cRodaTxt , tamanho )

	Default lPrimeiro := .F.

    Li++
    If Li > 58
    	If !lPrimeiro//Caso nao seja a primeira passagem imprime o rodape quando troca pagina
    		Roda( nCntImpr , cRodaTxt , tamanho )
    	EndIf
        Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo,,.F.)
    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fRetCampos
Retorna os campos do SX3 de um determinado ALIAS
Uso Genérico

@return

@param nLin 	- Posicao da Linha de Impressao
@param nPos		- Posicao da Coluna de Impressa
@param aCampos 	- Campos para Impressao
@param nZ		- Posicao a ser impressa
@param cAlias	- Alias de impressao
@param nCntImpr	- Contador de impressao ( Parametro Reservado da Funcao Roda )
@param cRodaTxt	- Texto de Impressao do Rodape ( Parametro Reservado da Funcao Roda )
@param tamanho	- Tamanho do Relatório

@sample
fImpCampo( 08 , 00 , aCampos , 1 , "TM5" , 1 , " " , "G" )

@author Jackson Machado
@since 21/08/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fImpCampo( nLin , nPos , aCampos , nZ , cAlias , nCntImpr , cRodaTxt , tamanho )

	Local nLinTotal := 0
	Local nContLine := 1
	Local xValCpo   := ""
	Local xImprime  := ""
	Local cCampo    := aCampos[ nZ ]
	Local cTitulo   := Posicione( 'SX3' , 2 , cCampo, "X3Titulo()" )
	Local cContex   := GetSx3Cache( cCampo, "X3_CONTEXT" )
	Local cTipo     := GetSx3Cache( cCampo, "X3_TIPO"    )
	Local cPicture  := X3Picture( cCampo )//Salva picture do campo

	If Empty( cPicture )//Caso campo nao possua picture, utiliza picture generica
		cPicture := "@S55"
	EndIf

	@ nLin , nPos PSay AllTrim( cTitulo ) + ": " Picture "@S15"//Imprime titulo do campo

	If cContex <> "V"//Caso campo nao seja virtual

		xValCpo  := ( cAlias )->&( cCampo ) //Salva valor do campo

		If cTipo == "C"//Caso tipo caracter, verifica se tem combo, se tiver imprime valor do campo caso nao, imprime valor do campo
			If Empty( GetSx3Cache( cCampo, "X3_CBOX" ) )
		   		xImprime := SubStr( xValCpo , 1 , 55 )
		 	Else
		 		xImprime := SubStr( NGRETSX3BOX( cCampo , xValCpo ) , 1 , 55 )//Imprime o valor do combobox
		 	EndIf
		ElseIf cTipo == "N"//Caso numerico, imprime o valor do campo
			xImprime := xValCpo
		ElseIf cTipo == "D"//Caso data, converte para caracter para entao imprimir
			xImprime := DTOC( xValCpo )
		ElseIf cTipo == "M"//Caso memo, imprime o tamanho de 55 caracteres e quebra linha a cada continuidade
			nLinTotal := MlCount( xValCpo , 55 )
			While nContLine <= nLinTotal
				If nContLine <> 1
					SomaLinha( , nCntImpr, cRodaTxt, tamanho )
				EndIf
				nLin := Li
				xImprime  := MemoLine( xValCpo , 55 , nContLine )
				@ nLin,nPos + _nQTDTIT_ PSay If( !Empty( xImprime ) , xImprime , " " ) Picture "@S55"
				nContLine++
			End
			If nContLine > 1
				nPos := 500 //Caso campo memo ocupe mais de uma linha, estoura o contador de colunas para zerar
			Endif
		ElseIf cTipo == "L"//Caso logico, imprime valor correspondente
			If xValCpo
				xImprime := "Verdadeiro"
			Else
				xImprime := "Falso"
			Endif
		EndIf

	Else
		//Caso campo virtual, verifica se tem inicializador padrao e seleciona o valor
		xValCpo := InitPad( GetSx3Cache( cCampo, "X3_RELACAO" ) )

		If cTipo == "C"//Caso caracter, pega apenas o tamanho de 55 caracteres
			xImprime := SubStr( xValCpo , 1 , 55 )
		ElseIf cTipo == "M"//Caso memo, imprime o tamanho de 55 caracteres e quebra linha a cada continuidade
			nLinTotal := MlCount( xValCpo , 55 )
			While nContLine <= nLinTotal
				If nContLine <> 1
					SomaLinha( , nCntImpr, cRodaTxt, tamanho )
				EndIf
				nLin := Li
				xImprime  := MemoLine( xValCpo , 55 , nContLine )
				@ nLin,nPos + _nQTDTIT_ PSay If( !Empty( xImprime ) , xImprime , " " ) Picture "@S55"
				nContLine++
			End
			If nContLine > 1
				nPos := 500 //Caso campo memo ocupe mais de uma linha, estoura o contador de colunas para zerar
			EndIf
		Else
			xImprime := xValCpo
		EndIf

	EndIf

	If cTipo <> "M"//Caso diferente de Memo, imprime na posicao correta
		@ nLin , nPos + _nQTDTIT_ Psay If( !Empty( xImprime ) , xImprime , " " ) Picture cPicture
	EndIf

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fResultado
Exibe o resultado do Exame
Uso Genérico

@return

@param nFolder		- Aba selecionada do Folder
@param aObjetos 	- Array de Objetos
@param aInformacoes	- Array das informacoes
@param aFiliais		- Array com as Filiais do Funcionario
@param oFil	   		- Objeto de List das Filiais

@sample
fResultado( 1 , aObj , aInfo , aFil , 1 )

@author Jackson Machado
@since 19/02/2013
/*/
//---------------------------------------------------------------------
Static Function fResultado( nFolder , aObjetos , aInformacoes  , aFiliais , oFil )

	Local nAt		:= 0
	Local nFil		:= oFil:nAt
	Local cEmpAtu	:= ""
    Local cFilAtu	:= ""
    Local cAntEmp	:= cEmpAnt
    Local cAntFil	:= cFilAnt
	Local aInfos	:= aInformacoes[ nFolder ]//Seleciona as informacoes de acordo com o folder
	Local oObj		:= aObjetos[ nFolder ]//Seleciona o objeto correto do list
	Local aTabPrep	:= {}
	Local aRotOld	:= aClone( aRotina )//Salva o aRotina
	//Salva todas as areas relacionadas
	Local aArea		:= GetArea()
	Local aAreaTM0	:= TM0->( GetArea() )
	Local aAreaTM5	:= TM5->( GetArea() )
	Local aAreaTM9	:= TM9->( GetArea() )
	Local aAreaTM4	:= TM4->( GetArea() )
	Local aAreaTN4	:= TN4->( GetArea() )
	Local aAreaTM8	:= TM8->( GetArea() )

	//Prepara as tabelas
	aAdd( aTabPrep , { "TM0" , 1 } )
	aAdd( aTabPrep , { "TM5" , 1 } )
	aAdd( aTabPrep , { "TM9" , 1 } )
	aAdd( aTabPrep , { "TM4" , 1 } )
	aAdd( aTabPrep , { "TN4" , 1 } )
	aAdd( aTabPrep , { "TM8" , 1 } )

	//Salva as informacoes iniciais
    cEmpAtu := aFiliais[ nFil , _nEMPRES_ ]
	cFilAtu := aFiliais[ nFil , _nFILIAL_ ]

	If cEmpAtu <> cAntEmp .or. cFilAtu <> cAntFil//Caso empresa/filial diferente da atual, prepara ambiente
		NGPrepTBL( aTabPrep , cEmpAtu , cFilAtu )
		cEmpAnt := cEmpAtu
	EndIf

	//Define um novo aRotina padrao para nao ocorrer erro
	aRotina 	:=	{ { STR0045 ,   "AxPesqui"	, 0 , 1},;  //"Pesquisar"
                      { STR0046 ,   "NGCAD01"	, 0 , 2},;  //"Visualizar"
                      { STR0047 ,   "NGCAD01"	, 0 , 3},;  //"Incluir"
                      { STR0048 ,   "NGCAD01"   	, 0 , 4},;  //"Alterar"
                      { STR0049 ,   "NGCAD01"   	, 0 , 5, 3} }  //"Excluir"

	nAt := oObj:nAt//Salva a posicao atual

	//Posiciona na TM5
	dbSelectArea( "TM5" )
	dbGoTo( aInfos[ nAt , Len( aInfos[ nAt ] ) ] )

	dbSelectArea( "TM0" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "TM0" , SubStr( cFilAtu , 1 , Len( xFilial( "TM0" ) ) ) ) + TM5->TM5_NUMFIC )

	If Empty(TM5->TM5_DTRESU)//Caso nao tenha resulta, exibe mensagem
		ShowHelpDlg( "NORESUL" , 	{ STR0051 } , 2 , ;//"Exame não possui resultado."
									{ STR0052 } )//"Resultado de exame apenas será apresentado para exames com 'Data de Resultado' preenchida."
	Else
		//Chama funcao de realizacao de exame
		REXAME120()
	EndIf

    If cEmpAtu <> cAntEmp .or. cFilAtu <> cAntFil//Caso empresa/filial diferente da atual, prepara ambiente
		NGPrepTBL( aTabPrep , cAntEmp , cAntFil )
		cEmpAnt := cAntEmp
	EndIf

    //Retorna o aRotina
	aRotina := aClone( aRotOld )
	//Retorna todas as areas selecionadas
	RestArea(aAreaTM0)
	RestArea(aAreaTM5)
	RestArea(aAreaTM9)
	RestArea(aAreaTM4)
	RestArea(aAreaTN4)
	RestArea(aAreaTM8)
	RestArea(aArea)

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fAtuObj
Atualiza o ListBox do Folder selecionado
Uso Genérico

@return

@param aObjetos - Array de Objetos
@param nPosic	- Aba selecionada do Folder

@sample
fImpCampo( aObj , 1 )

@author Jackson Machado
@since 19/02/2013
/*/
//---------------------------------------------------------------------
Static Function fAtuObj( aObjetos , nPosic )

	aObjetos[ nPosic ]:Refresh()//Atualiza o Objeto
	aObjetos[ nPosic ]:SetFocus()

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fMedicamentos
Exibe os medicamentos do Diagnostico ou do Atendimento de Enfermagem

@return

@param nFolder		- Aba selecionada do Folder
@param aObjetos 	- Array de Objetos
@param aInformacoes	- Array das informacoes
@param aFiliais		- Array com as Filiais do Funcionario
@param oFil	   		- Objeto de List das Filiais

@sample
fMedicamentos( 1 , aObj , aInfo , aFil , 1 )

@author Jackson Machado
@since 19/02/2013
/*/
//---------------------------------------------------------------------
Static Function fMedicamentos( nFolder , aObjetos , aInformacoes , aFiliais , oFil )

	Local nAt		:= 0
	Local nFil		:= oFil:nAt
	Local cEmpAtu	:= ""
	Local cFilAtu	:= ""
	Local cAntEmp	:= cEmpAnt
	Local cAntFil	:= cFilAnt
	Local aInfos	:= aInformacoes[ nFolder ]//Seleciona as informacoes de acordo com o folder
	Local oObj		:= aObjetos[ nFolder ]//Seleciona o objeto correto do list
	Local aTabPrep	:= {}
	Local aRotOld	:= aClone( aRotina )//Salva o aRotina
	Local cCadOld	:= cCadastro
	//Salva todas as areas relacionadas
	Local aArea		:= GetArea()
	Local aAreaTM0	:= TM0->( GetArea() )
	Local aAreaTM2	:= TM2->( GetArea() )
	Local aAreaTMT	:= TMT->( GetArea() )
	Local aAreaTY3	:= TY3->( GetArea() )

	//Cria variavel para Filtro da Tabela
	Private cFilMed := ""
	Private cTabMed := ""

	If !MDTVALUSR( "MDTA010" , cUserName ) .AND. SuperGetMV("MV_NG2SEG",.F.,"2") == "1"
		Return
	Endif

	//Prepara as tabelas
	aAdd( aTabPrep , { "TM0" , 1 } )
	aAdd( aTabPrep , { "TMT" , 1 } )
	aAdd( aTabPrep , { "TM2" , 1 } )
	aAdd( aTabPrep , { "TM1" , 1 } )
	aAdd( aTabPrep , { "TY3" , 1 } )

	//Salva as informacoes iniciais
    cEmpAtu := aFiliais[ nFil , _nEMPRES_ ]
	cFilAtu := aFiliais[ nFil , _nFILIAL_ ]

	If cEmpAtu <> cAntEmp .or. cFilAtu <> cAntFil//Caso empresa/filial diferente da atual, prepara ambiente
		NGPrepTBL( aTabPrep , cEmpAtu , cFilAtu )
		cEmpAnt := cEmpAtu
	EndIf

	//Define um novo aRotina padrao para nao ocorrer erro
	aRotina 	:=	{ { STR0045 ,   "AxPesqui"	, 0 , 1},;  //"Pesquisar"
                      { STR0046 ,   "NGCAD01"	, 0 , 2 } , ;//"Visualizar"
                      { STR0031 ,   "MDT990IMP"	, 0 , 3 } }  //"Imprimir"

	nAt := oObj:nAt//Salva a posicao atual

    //Define o novo cadastro
	cCadastro := STR0050 //"Medicamentos Utilizados"
	cCadastro := OemtoAnsi(cCadastro)

	If nFolder == _nATEENF_

		//Define a tabela de Medicamentos a ser utilizada
		cTabMed := "TY3"

		//Posiciona na TL5
		dbSelectArea( "TL5" )
		dbGoTo( aInfos[ nAt , Len( aInfos[ nAt ] ) ] )

		//Posicona na tabela de Medicamentos e Filtra Corretamente
		cFilMed := "TY3->TY3_FILIAL == xFilial( 'TY3' , SubStr( '"+cFilAtu+"' , 1 , Len( xFilial( 'TY3' ) ) ) )	.AND. "
		cFilMed += "TY3->TY3_NUMFIC == TL5->TL5_NUMFIC	.AND. "
		cFilMed += "TY3->TY3_DTATEN == TL5->TL5_DTATEN 	.AND. "
		cFilMed += "TY3->TY3_HRATEN == TL5->TL5_HRATEN  	.AND. "
		cFilMed += "TY3->TY3_INDICA == TL5->TL5_INDICA"

		//Chave de Busca
		cKeySch := TL5->TL5_NUMFIC + DTOS( TL5->TL5_DTATEN ) + TL5->TL5_HRATEN + TL5->TL5_INDICA

	Else

		//Define a tabela de Medicamentos a ser utilizada
		cTabMed := "TM2"

		//Posiciona na TMT
		dbSelectArea( "TMT" )
		dbGoTo( aInfos[ nAt , Len( aInfos[ nAt ] ) ] )

		//Posicona na tabela de Medicamentos e Filtra Corretamente
		cFilMed := "TM2->TM2_FILIAL == xFilial( 'TM2' , SubStr( '"+cFilAtu+"' , 1 , Len( xFilial( 'TM2' ) ) ) )	.AND. "
		cFilMed += "TM2->TM2_NUMFIC == TMT->TMT_NUMFIC	.AND. "
		cFilMed += "TM2->TM2_DTCONS == TMT->TMT_DTCONS	.AND. "
		cFilMed += "TM2->TM2_HRCONS == TMT->TMT_HRCONS "

		//Chave de Busca
		cKeySch := TMT->TMT_NUMFIC + DTOS( TMT->TMT_DTCONS ) + TMT->TMT_HRCONS
	EndIf

	dbSelectArea( cTabMed )
	Set Filter To &( cFilMed )

    If ( cTabMed )->( !dbSeek( xFilial( cTabMed , SubStr( cFilAtu , 1 , Len( xFilial( cTabMed ) ) ) ) + cKeySch ) )
		ShowHelpDlg( "NOMEDIC" , 	{ STR0053 } , 2 , ;//"Não existem medicamentos."
									{ STR0054 } )//"Para este diagnístico não foram ministrados/receitados medicamentos."
	Else
		mBrowse( 6 , 1 , 22 , 75 , cTabMed )
	EndIf

	//Posicona na tabela de Medicamentos e DesFiltra Corretamente
	DbSelectArea( cTabMed )
	Set Filter To

	//Retorna o aRotina
	aRotina 	:= aClone( aRotOld )
	cCadastro	:= cCadOld

	If cEmpAtu <> cAntEmp .or. cFilAtu <> cAntFil//Caso empresa/filial diferente da atual, prepara ambiente
		NGPrepTBL( aTabPrep , cAntEmp , cAntFil )
		cEmpAnt := cAntEmp
	EndIf

	//Retorna todas as areas selecionadas
	RestArea(aAreaTM0)
	RestArea(aAreaTM2)
	RestArea(aAreaTMT)
	RestArea(aAreaTY3)
	RestArea(aArea)

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fValRotUsr
Valida se o usuario tem acesso a uma determinada rotina

@return Lódigo - Caso tenha acesso retorna verdadeiro, caso nao, falso

@param cRotValid - Rotina a ser validada

@sample
fMedicamentos( "MDTA005" )

@author Jackson Machado
@since 19/02/2013
/*/
//---------------------------------------------------------------------
Static Function fValRotUsr( cRotValid )

Return MPUserHasAccess(cRotValid,2)
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT990IMP
Funcao para impressao dos medicamentos

@return

@sample
MDT990IMP()

@author Jackson Machado
@since 19/02/2013
/*/
//---------------------------------------------------------------------
Function MDT990IMP()
	Local nTipSel		:= 1
	Local cString
	Local wnrel   		:= "MDTC990" //Nome do Relatorio
	Local limite  		:= 220 // Limite do Relatório
	Local cDesc1  		:= ""//Descricao inicial
	Local cDesc2  		:= ""//Segunda descricao
	Local cDesc3  		:= "" //Terceira descricao
	Local aPosicoes	:= {} //Array contendo as posicoes
	Local aCabecs		:= {} //Array contendo os cabecalhos
	Local aPropFol		:= {}
	Local aCps			:= {}
	Local aTam			:= {}
	Local lRet			:= .F.

	Private nomeprog 	:= "MDTR990"//Define o nome do programa
	Private tamanho  	:= "G"//Define o tamanho do relatorio
	//Define as propriedades do relatorio
	Private aReturn  	:= { STR0043 , 1 , STR0044 , 2 , 2 , 1 , "" , 1 } //"Zebrado"###"Administracao"
	//Define o titulo do relatorio
	Private titulo   	:= If( nTipSel == 1 , STR0039 , STR0040 )//"Listagem dos Registros"###"Cadastro do Registro"
	Private nTipo    	:= 0 //Define o tipo de acordo com as propriedades
	Private nLastKey 	:= 0 //Variavel de controle dos botoes do SetPrint
	Private cabec1, cabec2 //Cabecalhos

	SetBrwCHGAll( .F. ) // nao apresentar a tela para informar a filial

	fDefTipImp( @nTipSel , @lRet )

	If lRet

	   	aPropFol	:= fRetProp( { cTabMed } ) //Retornas as Propriedades dos Folders ( 1 - Itens ; 2 - Tamanhos ; 3 - Campos )
		aTam		:= aPropFol[ 2 , 1 ]//Retorna o tamanho de cada item
		aCps		:= aPropFol[ 3 , 1 ]//Retorna os campos de cada item

		cDesc1  		:= If( nTipSel == 1 , STR0039 , STR0040 )//"Listagem dos Registros"###"Cadastro do Registro"
		cDesc2  	:= If( nTipSel == 1 , STR0041 , ;//"Através deste relatório é possível retirar uma listagem dos registros exibidos."
											STR0042 ) //"Através deste relatório é possível visualizar o cadastro do registro."
		titulo   	:= If( nTipSel == 1 , STR0039 , STR0040 )//"Listagem dos Registros"###"Cadastro do Registro"
		aCabecs 	:= fMontaCabec( cTabMed , @aPosicoes , aCps , aTam , @limite , @tamanho )//Monta os cabecalhos

		cabec1 		:= If( nTipSel == 1 , aCabecs[ 1 ] , " " )//Caso selecao for Listagem, salva primeiro cabecalho
		cabec2 		:= If( nTipSel == 1 , aCabecs[ 2 ] , " " )//Caso selecao for Listagem, salva segundo cabecalho

		cString 	:= cTabMed//Salva a tabela a ser utilizada

		//-----------------------------------------
		// Envia controle para a funcao SETPRINT
		//-----------------------------------------
		wnrel := "MDTC990"
		wnrel := SetPrint( cString , wnrel , " " , titulo , cDesc1 , cDesc2 , cDesc3 , .F. , "" )

		If nLastKey == 27//Caso cancele
			Return
		Endif

		SetDefault( aReturn , cString )//Verifica os valores padroes de impressao

		If nLastKey == 27 //Caso cancele
			Return
		Endif

		//Chama funcao de impressao
		RptStatus( { | lEnd | fImpMed( @lEnd , wnRel , titulo , tamanho , nTipSel , aCps , aPosicoes ) }, titulo )

		//Libera arquivo de impressao
		Set device to Screen
		If aReturn[ 5 ] == 1//Caso impressao seja em tela
		   Set Printer To
		   dbCommitAll()
		   OurSpool( wnrel )
		Endif
		MS_FLUSH()
	EndIf

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fImpMed
Imprime o relatório dos medicamentos

@return

@param lEnd			- Indica se abortou opercao
@param wnRel		- Arquivo de saida	do relatorio
@param titulo		- Titulo do Relatorio
@param tamanho		- Tamanho do Relatorio
@param nTipSel 		- Tipo de Selecao ( 1 - Listagem; 2 - Cadastro

@sample
fImpMed()

@author Jackson Machado
@since 18/02/2013
/*/
//---------------------------------------------------------------------
Static Function fImpMed( lEnd , wnRel , titulo , tamanho , nTipSel , aCps , aPos )

	Local nZ//Contador
	Local nPosicao 	:= 000 //Posicao de impressao
	Local nList 	:= 0, nCps := 0 //Contadores
	Local nCntImpr 	:= 0 //Variavel para controle do Relatorio
	Local xImpTemp 	:= "" //Variavel de impressao
	Local cTipTemp	:= ""//Definicoes de Tipo
	Local cRodaTxt 	:= "" //Variavel para controle do Relatorio
	Local aCampos  	:= {}
	//-------------------------------------------------
	// Contadores de linha e pagina
	//-------------------------------------------------
	Private Li := 80 , m_pag := 1

	If nTipSel == 1
		dbSelectArea( cTabMed )
		Set Filter To &( cFilMed )
		dbGoTop()
		While ( cTabMed )->( !Eof() )
			SomaLinha( .T. , nCntImpr, cRodaTxt, tamanho )//Realiza o primeiro incremento de linha
			For nCps := 1 To Len( aCps )//Percorre todos os campos da tabela
					If !( "RECNO" $ aCps[ nCps ] )//Recno esta contido na array de campos, porem nao eh impresso
					If NGSEEKDIC( "SX3" , aCps[ nCps ] , 2 , "X3_CONTEXT" ) <> "V"//Caso campo nao seja virtual
						cTipTemp := NGSEEKDIC( "SX3" , aCps[ nCps ] , 2 , " 	X3_TIPO" )
						xImpTemp := ( cTabMed )->&( aCps[ nCps ] ) //Salva valor do campo
						If cTipTemp == "C"//Caso tipo caracter, verifica se tem combo, se tiver imprime valor do campo caso nao, imprime valor do campo
							If Empty( NGSEEKDIC( "SX3" , aCps[ nCps ] , 2 , "X3_CBOX" ) )
						   		xImpTemp := SubStr( xImpTemp , 1 , 55 )
						 	Else
						 		xImpTemp := SubStr( NGRETSX3BOX( aCps[ nCps ] , xImpTemp ) , 1 , 55 )//Imprime o valor do combobox
						 	Endif
						ElseIf cTipTemp == "N"//Caso numerico, imprime o valor do campo
							xImpTemp := xImpTemp
						ElseIf cTipTemp == "D"//Caso data, converte para caracter para entao imprimir
							xImpTemp := DTOC( xImpTemp )
						ElseIf cTipTemp == "L"//Caso logico, imprime valor correspondente
							If xImpTemp
								xImpTemp := "Verdadeiro"
							Else
								xImpTemp := "Falso"
							Endif
						Endif
					Else

						xCampo := GetSx3Cache( aCps[ nCps ], 'X3_RELACAO' )
						If GetSx3Cache( aCps[ nCps ], 'X3_TIPO' ) == "C"//Caso caracter, pega apenas o tamanho de 55 caracteres
							xImpTemp := SubStr( xCampo , 1 , 55 )
						EndIf

					Endif

					If NGSEEKDIC( "SX3" , aCps[ nCps ] , 2 , "X3_TIPO" ) <> "M"//Caso seja diferente de Memo
						If NGSEEKDIC( "SX3" , aCps[ nCps ] , 2 , "X3_TIPO" ) == "C"//Caso seja caracter
							If Empty( xImpTemp )//Se for vazio imprime espaco em branco por problema em impressao de relatorio (P.O.G.)
								@ Li , aPos[ nCps ] Psay " " Picture PesqPict( cTabMed , aCps[ nCps ] )
							ElseIf Len( AllTrim( xImpTemp ) ) > 20//Caso tamanho seja maior que 20, realiza um substr
								@ Li , aPos[ nCps ] Psay SubStr( xImpTemp , 1 , 20 ) Picture PesqPict( cTabMed , aCps[ nCps ] )
							Else
								//Caso esteja tudo certo, imprime
								@ Li , aPos[ nCps ] Psay AllTrim( xImpTemp ) Picture PesqPict( cTabMed , aCps[ nCps ] )
							EndIf
						Else
							//Caso seja diferente de caracter, apenas imprime
							@ Li , aPos[ nCps ] Psay xImpTemp Picture PesqPict( cTabMed , aCps[ nCps ] )
						EndIf
					EndIf
				EndIf
			Next nCps
			( cTabMed )->( dbSkip() )
		End
	Else
		nReg := ( cTabMed )->( Recno() )

		aRotSetOpc( cTabMed , nReg , 2 ) //Inicializa variaveis para modo de visualizacao (Ex: INCLUI e ALTERA)

		RegToMemory( cTabMed , .F. )  //Inicializa variaveis de memoria (M->)

		aCampos := NGCAMPNSX3( cTabMed ) //Retorna os campos do SX3 da tabela

		SomaLinha( .T. , nCntImpr, cRodaTxt, tamanho )//Realiza o primeiro incremento de linha

		For nZ := 1 To Len(aCampos) //Percorre todos os campos

			dbSelectArea( "SX3" )
			dbSetOrder( 2 )
			dbSeek( aCampos[ nZ ] )//Posiciona no campo do SX3

			fImpCampo( Li , @nPosicao , aCampos , nZ , cTabMed , nCntImpr, cRodaTxt, tamanho ) //Funcao de impressao dos campos da tabela

			If nPosicao > 145 //Caso posicao ultrapasse o limete zera e pula linha
				nPosicao := 000
				SomaLinha( , nCntImpr, cRodaTxt, tamanho )
			Else
				nPosicao += _nQTDSEP_//Incremento padrao de distancia de campos
			Endif

		Next nZ
	EndIf

	//Imprime o ultimo rodape antes da saida
	Roda( nCntImpr , cRodaTxt , tamanho )

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fDefTipImp
Define o tipo de impresao

@return

@param nTipSel - Variavel de Controle do Tipo de Impressao
@param lRet		- Variavel de Controle dos Botoes

@sample
MDT990IMP()

@author Jackson Machado
@since 19/02/2013
/*/
//---------------------------------------------------------------------
Static Function fDefTipImp( nTipSel , lRet )

	Local oDlgSel, oRadOp

	DEFINE MSDIALOG oDlgSel FROM 0 , 0 TO 150 , 320 TITLE STR0032 PIXEL //"Selecione o Modelo do Relatório"

		@ 10 , 10 TO 55 , 150 LABEL STR0033 of oDlgSel Pixel //"Modelo do Relatório"
		@ 25 , 14 RADIO oRadOp VAR nTipSel ITEMS STR0034 , STR0035 SIZE 70 , 15 PIXEL OF oDlgSel //"Listagem"###"Cadastro"

		DEFINE SBUTTON FROM 59,90  TYPE 1 ENABLE OF oDlgSel ACTION EVAL( { | | lRET := .T. , oDlgSel:End() } )
		DEFINE SBUTTON FROM 59,120 TYPE 2 ENABLE OF oDlgSel ACTION oDlgSel:End()

	ACTIVATE MSDIALOG oDlgSel CENTERED

Return