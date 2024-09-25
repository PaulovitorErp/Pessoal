#Include "MNTA550.ch"
#Include "Protheus.ch"
#Include "FWADAPTEREAI.CH" // Integração via Mensagem Única

#Define DS_MODALFRAME 128 //Estilo que retira o X da janela

Static lRel12133   := GetRPORelease() >= '12.1.033'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MNTA550  ³ Autor ³ Ricardo Dal Ponte     ³ Data ³30/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Transferencia de bem                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

/*
TABELAS ENVOLVIDAS NESTE PROGRAMA

Tabelas do MNT
ST0 - ESPECIALIDADES
ST1 - FUNCIONARIOS
ST4 - SERVICOS DE MANUTENCAO
ST5 - TAREFAS DA MANUTENCAO
ST6 - FAMILIA DE BENS
ST7 - FABRICANTE DE BEM
ST9 - BEM
STB - DETALHES DO BEM
STC - ESTRUTURA
STF - MANUTENCAO
STG - DETALHES DE MANUTENCAO
STH - ETAPAS DA MANUTENCAO
STM - DEPENDENCIAS DA MANUTENCAO
STP - ORDENS SERVICO ACOMPANHAMENTO
STZ - MOVIMENTACAO DE BENS
TQR - TIPOS DE MODELOS
TP1 - OPCOES DA ETAPA DA MANUTENCAO
TPA - ETAPAS GENERICAS
TPC - OPCOES DA ETAPA GENERICA
TPE - SEGUNDO CONTADOR DO BEM
TPY - PECAS DE REPOSICAO
TPJ - MOTIVOS
TPN - UTILIZACAO DE BENS
TPP - O.S. ACOMPANHAMENTO CONTADOR 2
TPR - CARACTERISTICAS
TPS - LOCALIZACAO

Tabelas do Gestao de Frotas
TQQ - INCONSISTENCIAS DE ABASTECIMENTO
TQS - CADASTRO DE PNEUS
TQT - MEDIDAS DE PNEUS
TQR - TIPOS DE MODELOS
TQY - STATUS
TQU - DESENHO DE PNEUS
DA3 - TMS (Veiculos)
M7(SX5) - COR DE VEICULOS
12(SX5 - UF EMPLACAMENTO
DUT - TIPO DE VEICULOS
TS3 - VEICULOS PENHORADOS
TSJ - LEASING DE VEICULOS
TT8 - TANQUE DO BEM
TQV - HISTORICO DE SULCO DE PNEUS
TQZ - HISTORICO DE STATUS DE PNEUS

Tabelas Microsiga
AC9 - BANCO DO CONHECIMENTO
CTT / SI3- CENTRO DE CUSTO
QDH - DOCUMENTOS
SA1 - CADASTRO DE CLIENTES
SA2 - CADASTRO DE FORNECEDORES
SAH - CADASTRO DE UNIDADES DE MEDIDA
SB1 - DESCRICAO GENERICA DO PRODUTO
SHB - CENTRO DE TRABALHO
SH1 - RECURSOS
SH4 - FERRAMENTAS
SH7 - CALENDARIO
SN1 - ATIVO FIXO
*/
Function MNTA550(aAutoTrans, lTransAuto)

	Local aArea		  := {}
	Local aNGBeginPrm := {}
	Local cMenIni	  := ''
	Local cConPadST9  := 'ST9'
	Local lTrans      := .F.
	Local bOk		         // Variável para guardar conteúdo de verificação ao se pressionar o botão de confirmação
	Local bCancel	         // Variável para guardar conteúdo de verificação ao se pressionar o botão de cancelamento
	Local lTemInc := .T.

	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 19 )

		aArea       := GetArea()
		aNGBeginPrm := NGBeginPrm()
		cMenIni     := Space( 1 )

		dbSelectArea( 'SXB' )
		dbSetOrder( 1 ) // XB_ALIAS + XB_TIPO + XB_SEQ + XB_COLUNA

		If lRel12133 .And. nModulo == 19 .And. dbSeek( 'ST9MNT' )

			/*----------------------------------------------------------+
			| Consulta padrão de bens, filtrada pela categoria 1 - Bens |
			+----------------------------------------------------------*/
			cConPadST9 := 'ST9MNT'

		EndIf

		//Parametro de Autoexec
		Private lAtfExecAuto := ( ValType(aAutoTrans) == "A" )
		Private lTAuto 		 := IIf(lTransAuto <> NIL, lTransAuto, .f.)

		/*------------------------------------------------------------------------------------------------
		Esta validação foi adicionada porque a rotina MNTA693 (Construção Civil) utiliza MSExecAuto ATF060
		para transferir bens entre filiais, não havendo necessidade de utilizar a rotina MNTA550
		(quando esta é chamada pela rotina ATF060).
		------------------------------------------------------------------------------------------------*/
		If IsInCallStack("MNTA693")
			Return .T.
		ElseIf IsInCallStack("ATFA060") //Caso a transferência seja realizada pelo ATF, não permite transferir bens do Construção Civil
			If NGSEEK( "ST9", aAutoTrans[4], 1, "T9_CATBEM" ) == "4" .And. GetNewPar( "MV_NGMNTCC", "N" ) == "S"
				msgstop( STR0204 + " " + STR0205, STR0002 )
				Return .F.
			EndIf
		Else
			Private oTmpTblSTZ //Tabela temporaria (STZ) - Movimentacao de Bens
			Private oTmpTblSTC //Tabela temporaria (STC) - Estrutura
			Private oTmpTblIn  //Tabela de Inconsistencias
			Private oTmpTblx   //Tabela de STC do NGESTRUTRB
			fNgCrtTemp(@oTmpTblSTZ,@oTmpTblSTC,@oTmpTblIn, @oTmpTblx)
		EndIf

		Private	cAliTRBIn := oTmpTblIn:GetAlias()
		Private lFechaWin := .T.

		//Variavel de filial
		Private cOldFil 	:= cFilAnt
		Private cBEMREL		:= ""
		Private cFILORI 	:= ""
		Private cFILDES 	:= ""
		Private cMODO   	:= ""
		Private cIniCCUSTO  := ""
		Private cINICENTRAB := ""
		Private lVerFil 	:= .F.
		Private lBEMRPLACE  := .F.

		//-------------------------------------------------------------------------------------
		//Variáveis para verificar tipo de compartilhamento das tabelas envolvidas no processo
		//-------------------------------------------------------------------------------------

		//Tabelas do Sigamnt Padrao
		Private lST0exclus := .F.
		Private lST1exclus := .F.
		Private lST4exclus := .F.
		Private lST5exclus := .F.
		Private lST6exclus := .F.
		Private lST7exclus := .F.
		Private lST9exclus := .F.
		Private lSTBexclus := .F.
		Private lSTCexclus := .F.
		Private lSTFexclus := .F.
		Private lSTGexclus := .F.
		Private lSTHexclus := .F.
		Private lSTMexclus := .F.
		Private lSTPexclus := .F.
		Private lSTZexclus := .F.

		Private lTP1exclus := .F.
		Private lTPAexclus := .F.
		Private lTPCexclus := .F.
		Private lTPEexclus := .F.
		Private lTPYexclus := .F.
		Private lTPJexclus := .F.
		Private lTPNexclus := .F.
		Private lTPPexclus := .F.
		Private lTPRexclus := .F.
		Private lTPSexclus := .F.
		Private lTQ2exclus := .F.
		Private lTS3exclus := .F.
		Private lTSJexclus := .F.

		//Tabelas de Gestao de Frotas
		Private lTQQexclus	 := .F.
		Private lTQSexclus	 := .F.
		Private lTQVexclus	 := .F.
		Private lTQZexclus	 := .F.
		Private lTQTexclus	 := .F.
		Private lTQRexclus	 := .F.
		Private lTQYexclus	 := .F.
		Private lTQUexclus	 := .F.
		Private lDA3exclus	 := .F.
		Private lTT8exclus	 := .F.
		Private lTQMexclus	 := .F.
		Private lM7SX5exclus := .F.
		Private l12SX5exclus := .F.
		Private lDUTexclus	 := .F.

		Private lTT8Tanque := NGCADICBASE("TT8_FILIAL","A","TT8",.F.) //Verifica se existe tabela de Tanque
		Private lTS3Table  := NGCADICBASE("TS3_FILIAL","A","TS3",.F.) //Verifica se existe tabela de Veiculos Penhorados
		Private lTSJTable  := NGCADICBASE("TSJ_FILIAL","A","TSJ",.F.) //Verifica se existe tabela de Leasing
		Private lTQVTable  := NGCADICBASE("TQV_FILIAL","A","TQV",.F.) //Verifica se existe tabela de Historico de Sulco de Pneus
		Private lTQZTable  := NGCADICBASE("TQZ_FILIAL","A","TQZ",.F.) //Verifica se existe tabela de Historico de Status de Pneus

		//Tabelas da Microsiga
		Private cF3CTTSI3  := IIf(CtbInUse(), "CTT", "SI3")
		Private lAC9exclus := .F.
		Private lACBexclus := .F.
		Private lCTTexclus := .F.
		Private lSI3exclus := .F.
		Private lQDHexclus := .F.
		Private lSA1exclus := .F.
		Private lSA2exclus := .F.
		Private lSAHexclus := .F.
		Private lSB1exclus := .F.
		Private lSHBexclus := .F.
		Private lSH1exclus := .F.
		Private lSH4exclus := .F.
		Private lSH7exclus := .F.
		Private lSN1exclus := .F.

		//-------------------------------------------------------------------------
		//Variáveis para carregar a filial considerando compartilhado e exclusivo
		//-------------------------------------------------------------------------

		//Tabelas do Sigamnt Padrao
		Private cFilTrST0  := ""
		Private cFilTrST1  := ""
		Private cFilTrST4  := ""
		Private cFilTrST5  := ""
		Private cFilTrST6  := ""
		Private cFilTrST7  := ""
		Private cFilTrST9  := ""
		Private cFilTrSTB  := ""
		Private cFilTrSTC  := ""
		Private cFilTrSTF  := ""
		Private cFilTrSTG  := ""
		Private cFilTrSTH  := ""
		Private cFilTrSTM  := ""
		Private cFilTrSTP  := ""
		Private cFilTrSTZ  := ""
		Private cFilTrTP1  := ""
		Private cFilTrTPA  := ""
		Private cFilTrTPC  := ""
		Private cFilTrTPE  := ""
		Private cFilTrTPY  := ""
		Private cFilTrTPJ  := ""
		Private cFilTrTPN  := ""
		Private cFilTrTPP  := ""
		Private cFilTrTPR  := ""
		Private cFilTrTPS  := ""
		Private cFilTrTQ2  := ""
		Private cFilTrTS3  := ""
		Private cFilOriTS3 := ""
		Private cFilTrTSJ  := ""
		Private cFilOriTSJ := ""

		//Tabelas de Gestao de Frotas
		Private cFilTrTQQ  := ""
		Private cFilTrTQS  := ""
		Private cFilTrTQV  := ""
		Private cFilTrTQZ  := ""
		Private cFilTrTQT  := ""
		Private cFilTrTQR  := ""
		Private cFilTrTQY  := ""
		Private cFilTrTQU  := ""
		Private cFilTrDA3  := ""
		Private cFilTrTT8  := ""
		Private cFilTSX5M7 := ""
		Private cFilTSX512 := ""
		Private cFilTrDUT  := ""

		//Tabelas da Microsiga
		Private cFilTrAC9 := ""
		Private cFilTrACB := ""
		Private cFilTrCTT := ""
		Private cFilTrSI3 := ""
		Private cFilTrQDH := ""
		Private cFilTrSA1 := ""
		Private cFilTrSA2 := ""
		Private cFilTrSAH := ""
		Private cFilTrSB1 := ""
		Private cFilTrSHB := ""
		Private cFilTrSH1 := ""
		Private cFilTrSH4 := ""
		Private cFilTrSH7 := ""
		Private cFilTrSN1 := ""

		Private cNomFilA, cNomFilT, cEmpreAt, cNomCCus, cNomCTra, cCausaRemC, cNomeCau

		Private vBemEst	:= {}
		Private aVetInr	:= {}
		Private aPKey	:= {}

		Private lDoctSTH	:= .F.
		Private TipoAcom	:= .F.
		Private TipoAcom2	:= .F.

		Private oMemo
		Private oDLGA //Declaração do objeto usado no MSDIALOG para montagem da tela

		Store '' To cNomFilA, cNomFilT, cEmpreAt, cNomCCus, cNomCTra, cCausaRemC, cNomeCau

		//---------------------------------------------------------------
		//Verificação de Dicionário
		//---------------------------------------------------------------
		dbSelectArea("SX3")
		dbSetOrder(1)
		If !dbSeek("TQ2")
			cMenIni := "SX3"
		EndIf

		If Empty(cMenIni)
			dbSetOrder(2)
			If !dbSeek("TQ2_CCUSTO")
				MsgInfo(STR0001,STR0002) //"Problema no dicionario SX3 .. Campo TQ2_CCUSTO nao encontrado"###"ATENCAO"
				Return .T.
			EndIf

			If !dbSeek("TQ2_CENTRA")
				MsgInfo(STR0003,STR0002) //"Problema no dicionario SX3 .. Campo TQ2_CENTRA nao encontrado"###"ATENCAO"
				Return .T.
			EndIf
		EndIf

		If dbSeek("TH_DOCTO")
			lDOCTSTH := .T.
		EndIf

		dbSetOrder(1)
		If Empty(cMenIni)
			dbSelectArea("SX2")
			dbSetOrder(1)
			If !dbSeek("TQ2")
				cMenIni := "SX2"
			EndIf
		EndIf

		If Empty(cMenIni)
			dbSelectArea("SIX")
			dbSetOrder(1)
			If !dbSeek("TQ2")
				cMenIni := "SIX"
			EndIf
		EndIf

		If !Empty(cMenIni)
			MsgInfo(STR0004+" "+cMenIni,STR0002)  //"Arquivo\Tabela TQ2 nao presente no"###"ATENCAO"
			Return .T.
		EndIf

		dbSelectArea("TQ2")
		If Select("TQ2") == 0
			MsgInfo(STR0005,STR0002)  //"Arquivo\Tabela TQ2 nao esta em uso (aberta)"###"ATENCAO"
			Return .T.
		EndIf

		//Gestão de Frotas
		Private lOSObr	:= (GetNewPar("MV_NGINFOS","1") = "1")		//Obriga digitar O.S
		Private lTMSInt	:= (GetNewPar("MV_NGMNTMS","N") $ "S/P")	//Integracao com TMS
		Private lTQSInt	:= (GetNewPar("MV_NGPNEUS","N") = "S")		//Integracao com TQS
		// A partir do release 12.1.33, o parâmetro MV_NGMNTFR será descontinuado
		// Haverá modulo específico para a gestão de Frotas no padrão do produto
		
		Private cBemTr	:= GetNewPar("MV_NGBEMTR","")  //Status do bem transferido
		Private nOpcax	:= 3

		cEmpreAt      := IIf( FindFunction("FWGrpCompany"), FWGrpCompany(), SM0->M0_CODIGO )

		cNomFilA      := AllTrim(SM0->M0_FILIAL) + " / " + AllTrim(SM0->M0_NOME)

		cNomFilT      := Space( Len(cNomFilA) )
		cCausaRemC    := Space( TamSX3('TZ_CAUSA')[1] )
		cNomeCau      := Space(20)

		M->TQ2_CODBEM := Space( TamSX3('T9_CODBEM')[1] )
		M->TQ2_FILORI := IIf( FindFunction("FWCodFil"), FWCodFil(), SM0->M0_CODFIL )
		M->TQ2_FILDES := IIf( FindFunction("FWSizeFilial"), Space( FWSizeFilial() ), Space( Len(TQ2->TQ2_FILIAL) ) )
		M->TQ2_DATATR := dDataBase
		M->TQ2_HORATR := SubStr( Time(), 1, 5 )
		M->TQ2_ORDEMT := Space( TamSX3('TJ_ORDEM')[1] )
		M->TQ2_POSCON := 0
		M->TQ2_POSCO2 := 0
		M->TQ2_MOTTRA := Space( 1000 )
		M->TQ2_CCUSTO := Space( TamSX3('TJ_CCUSTO' )[1] )
		M->TQ2_CENTRA := Space( TamSX3('TJ_CENTRAB')[1] )

		//Consistencia do modo de criacao da tabelas/arquivos
		If !A550MO()
			Return .T.
		EndIf

		//---------------------------------------------------------------
		//Carrega modo exclusivo ou compatilhado das tabelas
		//---------------------------------------------------------------
		A550X2MOD()

		//---------------------------------------------------------------
		//Verificacao se houveram inconsistencias para a transferencia
		//---------------------------------------------------------------
		If !A550CHKINC(.F.)
			If lAtfExecAuto
				Return .F.
			Else
				Return .T.
			EndIf
		EndIf

		lVerFil := IIf( cF3CTTSI3 == "CTT", lCTTexclus, IIf(cF3CTTSI3 == "SI3",lSI3exclus,.F.) )

		If lAtfExecAuto

			//Carrega a descrição da nova filial
			dbSelectArea("SM0")
			dbSetOrder(1)
			If dbSeek(cEMPREAT+aAutoTrans[3])
				cNOMFILT := Alltrim(SM0->M0_FILIAL)+" / "+Alltrim(SM0->M0_NOME)
			EndIf

			//Verifica se o bem possui uma estrutura(tanto quanto pai como filho)
			If NGIFDBSEEK('STC',aAutoTrans[4],1) .Or. NGIFDBSEEK('STC',aAutoTrans[4],3)
				MsgInfo("O Bem "+ AllTrim(aAutoTrans[4]) + " está numa estrutura, sendo assim não é possível continuar com a transferência.")
				Return .F.
			EndIf

			//Verifica se o bem possui contador
			dbSelectArea("ST9")
			dbSetOrder(1)
			If dbSeek(xFilial("ST9") + aAutoTrans[4] )

				If ST9->T9_TEMCONT == "S"
					TIPOACOM := .T.
				EndIf
				//FindFunction remover na release GetRPORelease() >= '12.1.027'
				If FindFunction("MNTCont2")
					TIPOACOM2 := MNTCont2(xFilial("TPE"), aAutoTrans[4] )
				Else
					//Verica se o bem utiliza segundo contador
					dbSelectArea("TPP")
					dbSetOrder(2)
					TIPOACOM2 := dbSeek(xFilial("TPP") + aAutoTrans[4] )
				EndIf

			EndIf

			//Carrega a decrição do novo centro de custo
			cNomCCus := NGSEEK('CTT', aAutoTrans[5][1], 1, 'CTT->CTT_DESC01', aAutoTrans[3])

			M->TQ2_DATATR := aAutoTrans[1]
			M->TQ2_HORATR := aAutoTrans[2]
			M->TQ2_FILDES := aAutoTrans[3]
			M->TQ2_CODBEM := aAutoTrans[4]
			M->TQ2_CCUSTO := aAutoTrans[5][1]
			M->TQ2_FILORI := aAutoTrans[6]

			//Carrega filial de cada tabela das transações
			A550XFILI()

			dbSelectArea("SM0")
			dbSetOrder(1)
			If dbSeek(cEMPREAT+M->TQ2_FILORI)
				cNOMFILA := Alltrim(SM0->M0_FILIAL)+" / "+Alltrim(SM0->M0_NOME)
			EndIf

		EndIf

		//---------------------------------------------------------------
		//Montagem da tela
		//---------------------------------------------------------------
		nOpcax := 3

		bOk := {||If(!A550CONOK(oDlga),nOpcazx := 0,oDLGA:End())} //Armazenamento da validação de confirmação
		bCancel := {|| nOpcaX := 1 , IIf( lAtfExecAuto, IIf (MsgYesNo("O processo de tranferência será interrompido. Confirma?" ), oDLGA:End(), .T.), oDLGA:End() )} //Armazenamento da validação de cancelamento

		While (nOpcax <> 1)

			DEFINE MSDIALOG oDLGA From 90,190 To 580,575 Title OemToAnsi(STR0006) Pixel Style DS_MODALFRAME  //"Dados para a TRANSFERENCIA"
			//Style define um modelo a ser utilizado pela janela do MSDIALOG.
			//O estilo 128 retira o X do topo superior direito da janela, impedindo
			//o usuário de pular validações que devem ser realizadas ao cancelar/fechar
			//a rotina.

			oDLGA:lEscClose := .F.

			@ 2.6,01.0 Say OemtoAnsi(STR0007) SIZE 80,10 COLOR CLR_HBLUE  //"Codigo do bem"
			@ 2.6,07.4 MsGet M->TQ2_CODBEM  Picture '@!' Size 60,10 F3 cConPadST9 Valid ExistCpo("ST9",M->TQ2_CODBEM) .And. A550COBEM() When !lAtfExecAuto HASBUTTON

			@ 3.7,01.0 Say OemtoAnsi(STR0008) SIZE 80,10 COLOR CLR_HBLUE  //"Filial Atual do Bem"
			@ 3.7,07.4 MsGet M->TQ2_FILORI Picture '@!' Size 42,10 When .F.
			@ 3.7,12.7 MsGet cNOMFILA Picture '@!' Size 86,10 When .f.

			@ 5.0,01.0 Say OemtoAnsi(STR0009) SIZE 80,10 COLOR CLR_HBLUE  //"Nova Filial do Bem"
			@ 5.0,07.4 MsGet M->TQ2_FILDES Picture '@!' Size 42,10 F3 "XM0" Valid A550FILI() When !lAtfExecAuto HASBUTTON
			@ 5.0,13.3 MsGet cNOMFILT Picture '@!' Size 86,10 When .f.

			@ 6.1,01.0 Say OemtoAnsi(STR0010) SIZE 80,10 COLOR CLR_HBLUE  //"Centro de Custo"
			@ 6.1,07.4 MsGet oCCusto Var M->TQ2_CCUSTO Picture '@!' Size 33,10 F3 cF3CTTSI3 Valid A550CCUS() When !lAtfExecAuto HASBUTTON

			If !Empty(M->TQ2_CODBEM)

				oCCusto:bGotFocus  := {|| fTrocaFil(2) }
			
			EndIf

			oCCusto:bLostFocus := {|| fTrocaFil(1) }

			@ 6.1,13.3 MsGet cNOMCCUS Picture '@!' Size 85,10 When .f.

			@ 7.4,01.0 Say OemtoAnsi(STR0011) SIZE 80,10  //"Centro Trabalho"
			@ 7.4,07.4 MsGet oCTrab Var M->TQ2_CENTRA Picture '@!' Size 45,10 F3 "SHB" Valid A550CENTR() HASBUTTON
			@ 7.4,13.3 MsGet cNOMCTRA Picture '@!' Size 85,10 When .f.

			If !Empty(M->TQ2_CODBEM)

				oCTrab:bGotFocus  := {|| fTrocaFil(2) }

			EndIf

			oCTrab:bLostFocus := {|| fTrocaFil(1) }
			
			@ 8.5,01.0 Say OemtoAnsi(STR0012) SIZE 80,10 COLOR CLR_HBLUE  //"Data Transferencia"
			@ 8.5,07.4 MsGet M->TQ2_DATATR Picture '99/99/99' Size 42,10 Valid Naovazio()  When !lAtfExecAuto HASBUTTON
			@ 8.5,13.6 Say OemtoAnsi(STR0013) SIZE 80,10 COLOR CLR_HBLUE  //"Hora"
			@ 8.5,15.3 MsGet M->TQ2_HORATR Picture '99:99' Size 20,10 Valid NGVALHORA(M->TQ2_HORATR,.T.) .And. MNTA550CCB(M->TQ2_CODBEM, M->TQ2_DATATR, M->TQ2_HORATR) When !lAtfExecAuto

			/* Objeto Say somente é colorido de azul, quando acionado via SIGAATF, visto que pelo SIGAMNT
			o bem é selecionado após a montagem da tela.*/
			If TIPOACOM

				@ 9.6,01.0 Say OemtoAnsi( STR0014 ) SIZE 80,10 COLOR CLR_HBLUE  // Contador 1

			Else

				@ 9.6,01.0 Say OemtoAnsi( STR0014 ) SIZE 80,10                  // Contador 1

			EndIf

			@ 9.6,07.4 MsGet M->TQ2_POSCON Picture '@E 999,999,999' Size 45,10 When TIPOACOM .And. ;
				(!FindFunction("NGBlCont") .Or. NGBlCont( M->TQ2_CODBEM )) Valid CHKPOSLIM(M->TQ2_CODBEM,M->TQ2_POSCON,1) .And. Positivo()

			/* Objeto Say somente é colorido de azul, quando acionado via SIGAATF, visto que pelo SIGAMNT
			o bem é selecionado após a montagem da tela.*/
			If TIPOACOM2

				@ 11.0,01.0 Say OemtoAnsi( STR0015 ) SIZE 80,10 COLOR CLR_HBLUE  // Contador 2

			Else

				@ 11.0,01.0 Say OemtoAnsi( STR0015 ) SIZE 80,10                  // Contador 2

			EndIf

			@ 11.0,07.4 MsGet M->TQ2_POSCO2 Picture '@E 999,999,999' Size 45,10 When TIPOACOM2 Valid CHKPOSLIM(M->TQ2_CODBEM,M->TQ2_POSCO2,2) .And. Positivo()

			If lOSObr
				@ 12.0,01.0 Say OemtoAnsi(STR0016) SIZE 80,10 COLOR CLR_HBLUE  //"Ordem de Servico"
			Else
				@ 12.0,01.0 Say OemtoAnsi(STR0016) SIZE 80,10  //"Ordem de Servico"
			EndIf

			@ 12.0,07.4 MsGet M->TQ2_ORDEMT Picture '@!' Size 30,10 F3 "STJ" Valid A550CONOS() HASBUTTON

			@ 13.0,01.0 Say OemtoAnsi( STR0017 ) SIZE 80,10 // Causa Remoc.
			@ 13.0,07.4 MsGet CCAUSAREMC Picture '@!' Size 30,10 F3 "STN" Valid A550CRECOM() HASBUTTON
			@ 13.1,13.0 MsGet cNOMECAU  Picture '@!' Size 87,10 When .f.

			@ 14.2,01.0 Say OemToAnsi(STR0018) SIZE 80,10 COLOR CLR_HBLUE  //"Motivo da Tranferencia"
			@ 15.3,01.0 GET oMemo Var M->TQ2_MOTTRA MEMO SIZE 180,042 MEMO

			ACTIVATE MSDIALOG oDLGA ON INIT EnchoiceBar(oDLGA, bOk, bCancel,,,) CENTERED

		End

		If nOpcax <> 1 .And. !lFechaWin
			Return !lAtfExecAuto
		ElseIf lFechaWin
			Return .F.
		EndIf

		aBemTra := NGCOMPEST(M->TQ2_CODBEM, "B", .F., .F., .F.)

		//---------------------------------------------------------------
		//Executa testes antes da gravação final
		//---------------------------------------------------------------

		//---------------------------------------------------------------
		//Cadastro de Bens
		//---------------------------------------------------------------
		lTemInc := A550GTDD() // Valida se as tabelas precisam estar compartilhadas
		A550ST9T() // Bem
		A550STBT() // Características do Bem
		A550TPYT() // Peças de Reposição do Bem
		A550TQMT() // Combustível

		//---------------------------------------------------------------
		//Cadastro de Manutencao
		//---------------------------------------------------------------
		A550STFT() //Manutenção
		A550ST5T() //Tarefas da Manutenção
		A550STGT() //Detalhes da Manutenção
		A550STHT() //Etapas da Manutenção
		A550TP1T() //Opções das Etapa de Manutenção

		If lCTTexclus
			A550CTTT(aAutoTrans) //Centros de Custo
		EndIf

		//---------------------------------------------------------------
		//Verifica se houveram inconsistências para a transferência
		//---------------------------------------------------------------
		If !lTemInc
		
			If!A550CHKINC(.F.)
				
				fNgDelTemp()
				Return .F.
			
			EndIf

		Else

			If !A550CHKINC(.T.)
				If !lTransAuto
					fNgDelTemp()
				EndIf
				Return .T.
			EndIf

		EndIf

		// Efetiva a operação de transferência
		If !IsBlind()
			Processa( { || lTrans := A550GRAV() }, STR0213, STR0214 ) // Processando... ## Realizando transferência...
		Else
			lTrans := A550GRAV()
		EndIf

		If lTrans .And. !IsInCallStack("ATFA060")

			If ExistBlock( 'MNTA5503' )
				ExecBlock( 'MNTA5503', .F., .F., { M->TQ2_CODBEM, M->TQ2_DATATR, M->TQ2_HORATR } )
			EndIf

			MsgInfo(STR0019+"!", STR0020) //"Operacao de transferencia realizada com sucesso" ## "PARECER FINAL"

		EndIf
		//---------------------------------------------------------------

		NGRETURNPRM(aNGBEGINPRM)

		RestArea(aArea)

	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} A550TRAS
Faz a transferência dos componentes da estrutura do bem

@author Inácio Luiz Kolling
@since 22/11/2004
@param nREGCONT1, numérico, recno da ST9 do bem pai
@param nREGCONT2, numérico, recno da TPE do bem pai
@return
/*/
//---------------------------------------------------------------------
Function A550TRAS(nREGCONT1,nREGCONT2)

	Local cCENTRAB		:= ""
	Local lPIMSINT		:= SuperGetMV("MV_PIMSINT",.F.,.F.)
	Local lMNTA5501		:= ExistBlock("MNTA5501")
	Local i				:= 0
	Local nn			:= 0
	Local nCONTAD1		:= 0
	Local nCONTAD2		:= 0
	Local nField		:= 1
	Local aCamposSt9	:= {}
	Local cAliTRBSTZ 	:= oTmpTblSTZ:GetAlias()
	Local cAliTRBSTC 	:= oTmpTblSTC:GetAlias()
	Local cTRBSTRU		:= oTmpTblx:GetAlias()

	//Hora de inclusao na estrutura
	cHORAINC := MTOH(HTOM(M->TQ2_HORATR)+1)

	// Monta a estrutura do bem
	NGESTRUTRB(M->TQ2_CODBEM,"B",cTRBSTRU,@oTmpTblx,.F.)

	dbSelectArea(cTRBSTRU)
	dbgotop()
	If Reccount() > 0

		If TIPOACOM .And. nREGCONT1 > 0
			dbSelectArea("ST9")
			dbGoto(nREGCONT1)
			If ST9->T9_POSCONT > 0
				A550GRVHIS(ST9->T9_CODBEM,ST9->T9_POSCONT,ST9->T9_VARDIA,;
				ST9->T9_DTULTAC,ST9->T9_CONTACU,ST9->T9_VIRADAS,;
				cHORAINC ,1,"C")
			EndIf
		EndIf

		If TIPOACOM2 .And. nREGCONT2 > 0
			dbSelectArea("TPE")
			dbGoto(nREGCONT2)
			If TPE->TPE_POSCON > 0
				A550GRVHIS(TPE->TPE_CODBEM,TPE->TPE_POSCON,TPE->TPE_VARDIA,;
				TPE->TPE_DTULTA,TPE->TPE_CONTAC,TPE->TPE_VIRADA,;
				cHORAINC,2,"C")
			EndIf
		EndIf

		dbSelectArea(cTRBSTRU)

		While !Eof()

			DbselectArea("ST9")
			DbsetOrder(1)
			Dbseek(xFilial("ST9",M->TQ2_FILORI)+(cTRBSTRU)->TC_COMPONE)

			// Apos selecionar o bem de oirgem, copia todas as informaçõe para posretiormente ser recriado na filial de destino.
			// Obs.: Foi criar uma array, pois as duas outras formas de criar (por tabela temporaria usando dbUseArea ou temporarytable)
			// tem reflexos negativos, dbUseArea não cria os campos memo na estrututa e a temporarytable gera instrução de create tables
			// e isto em Oracle não permite o controle de transação (Bengin Transaction)
			For nField := 1 To ST9->( FCount() )
				AAdd(aCamposSt9,{ FieldName(nField), ST9->&(FieldName(nField))})
			Next nField

			Dbseek(xFilial("ST9",M->TQ2_FILDES)+(cTRBSTRU)->TC_COMPONE)

			Reclock("ST9", !Found())

			For nField := 1 To len(aCamposSt9)
				If FieldName(nField) == aCamposSt9[nField][1]
					If ST9->T9_RECFERR == "F"
						If !lSH4exclus
							ST9->T9_RECFERR	:= aCamposSt9[nField][2]
						Else
							ST9->T9_RECFERR := ""
						EndIf
					ElseIf ST9->T9_RECFERR == "R"
						If !lSH1exclus
							ST9->T9_RECFERR	:= aCamposSt9[nField][2]
						Else
							ST9->T9_RECFERR	:= ""
						EndIf
					Else
						ST9->&( FieldName(nField) ) := aCamposSt9[nField][2]
					EndIf
				EndIf
			Next nField

			aCamposSt9 := {}

			ST9->T9_CORVEI  	:=	If (lM7SX5exclus,"",ST9->T9_CORVEI)
			ST9->T9_UFEMPLA  	:=	If (l12SX5exclus,"",ST9->T9_UFEMPLA)	
			ST9->T9_CODIMOB		:= 	If (lSN1exclus .And. !lBemAtivo,"",ST9->T9_CODIMOB)

			ST9->T9_FILIAL  	:= 	xFilial("ST9",M->TQ2_FILDES)
			ST9->T9_CCUSTO  	:=	M->TQ2_CCUSTO
			ST9->T9_CENTRAB		:=	M->TQ2_CENTRA

			If ST9->T9_TEMCONT $ "PI" // somente atualiza quando é controlado pelo pai ou imediato
				ST9->T9_POSCONT := M->TQ2_POSCON
				ST9->T9_DTULTAC := M->TQ2_DATATR
			EndIf

			ST9->T9_DTBAIXA 	:= CTOD("")
			ST9->T9_SITBEM  	:= "A"
			ST9->T9_SITMAN 		:= "A"
			ST9->T9_DTVENDA 	:= CTOD("")
			ST9->T9_COMPRAD 	:= Space(Len(ST9->T9_COMPRAD))
			ST9->T9_NFVENDA		:= Space(Len(ST9->T9_NFVENDA))

			MsUnlock()

			//Altera o status do bem filho na filial de origem
			dbSelectArea("ST9")
			dbSetOrder(01)
			If dbSeek(xFilial("ST9",M->TQ2_FILORI)+(cTRBSTRU)->TC_COMPONE)
				RecLock("ST9",.F.)
				ST9->T9_SITMAN := "I"
				ST9->T9_SITBEM := "T"
				
				If !Empty(cBEMTR)

					ST9->T9_STATUS := cBEMTR
				
				EndIf
				
				MsUnLock("ST9")
			
			EndIf

			//Ponto de entrada para gravar campos da tabela ST9
			If lMNTA5501
				ExecBlock("MNTA5501",.F.,.F.,{ST9->T9_FILIAL, ST9->T9_CODBEM})
			EndIf

			//Integracao com TMS
			If ST9->T9_CATBEM == "2"
				//Altera DA3_FILBAS da filial Origem
				If !lDA3exclus
					dbSelectArea("DA3")
					dbSetOrder(03)
					If dbSeek(xFilial("DA3")+ST9->T9_PLACA)
						RecLock("DA3",.F.)
						DA3->DA3_FILBAS := cFilTrST9
						MsUnLock("DA3")
					EndIf
				EndIf
				//Altera T9_CODTMS se houver TMS associado no destino
				If lDA3exclus
					dbSelectArea("DA3")
					dbSetOrder(03)
					If dbSeek(M->TQ2_FILDES+ST9->T9_PLACA)
						RecLock("ST9",.F.)
						ST9->T9_CODTMS := DA3->DA3_COD
						MsUnLock("ST9")
					EndIf
				EndIf
			EndIf

			If ST9->T9_TEMCONT != "N"
				//Registro de inclusao no bem
				dbSelectArea("STP")
				dbSetOrder(02)
				If !dbSeek(cFilTrSTP+ST9->T9_CODBEM)
					If ST9->T9_POSCONT > 0
						A550GRVHIS(ST9->T9_CODBEM,ST9->T9_POSCONT,ST9->T9_VARDIA,;
						M->TQ2_DATATR,ST9->T9_CONTACU,ST9->T9_VIRADAS,;
						M->TQ2_HORATR,1,"I")
					EndIf
					dbSelectArea("ST9")
					RecLock("ST9",.f.)
					ST9->T9_DTULTAC := M->TQ2_DATATR
					MsUnLock("ST9")
				EndIf

				//----------------------------------------------
				// Grava segundo contador do componente
				//----------------------------------------------
				dbSelectArea("TPE")
				dbSetOrder(1)
				If dbSeek( xfilial("TPE") + (cTRBSTRU)->TC_COMPONE ) .And. TPE->TPE_SITUAC == "1"
					fGravaTPE( (cTRBSTRU)->TC_COMPONE )
				EndIf

			EndIf

			// Baixa da estrutura STC
			dbSelectArea("STC")
			dbSetOrder(1)
			If dbSeek(Xfilial("STC")+(cTRBSTRU)->TC_CODBEM+(cTRBSTRU)->TC_COMPONE)

				dbSelectArea(cAliTRBSTC)
				RecLock(cAliTRBSTC,.T.)
				For i := 1 TO FCOUNT()
					pp   := "STC->"+ FieldName(i)
					vl   := cAliTRBSTC + "->" + FieldName(i)
					&vl. := &pp.
				Next i
				MsUnLock(cAliTRBSTC)

				dbSelectArea("STC")
				RecLock("STC",.F.)
				Dbdelete()
				MsUnLock("STC")

				// Baixa da estrutura STZ
				lSTZ := .F.
				dbSelectArea("STZ")
				dbSetOrder(1)
				If dbSeek(Xfilial("STZ")+(cTRBSTRU)->TC_COMPONE+"E")
					While !Eof() .And. STZ->TZ_FILIAL == xFILIAL("STZ") .And.;
					STZ->TZ_CODBEM == (cTRBSTRU)->TC_COMPONE

						If Empty(STZ->TZ_DATASAI)

							lSTZ := .T.

							dbSelectArea(cAliTRBSTZ)
							RecLock(cAliTRBSTZ,.T.)
							For i := 1 TO FCOUNT()
								pp   := "STZ->"+ FieldName(i)
								vl   := cAliTRBSTZ + "->" + FieldName(i)
								&vl. := &pp.
							Next i
							MsUnLock(cAliTRBSTZ)

							dbSelectArea("STZ")
							RecLock("STZ",.F.)
							STZ->TZ_TIPOMOV := "S"
							STZ->TZ_DATASAI := M->TQ2_DATATR
							STZ->TZ_CONTSAI := (cTRBSTRU)->TC_CONTBE1
							STZ->TZ_CAUSA   := cCAUSAREMC
							STZ->TZ_CONTSA2 := (cTRBSTRU)->TC_CONTBE2
							STZ->TZ_HORASAI := M->TQ2_HORATR
							MsUnLock("STZ")
							nCONT1TZ := STZ->TZ_CONTSAI
							nCONT2TZ := STZ->TZ_CONTSA2

							dbSelectArea("ST9")
							dbSetOrder(1)
							If dbSeek(xFilial("ST9")+(cTRBSTRU)->TC_COMPONE)
								RecLock("ST9",.F.)
								ST9->T9_ESTRUTU := "N"
								MsUnLock("ST9")
							EndIf
							Exit
						EndIf
						dbSelectArea("STZ")
						dbskip()
					End
				EndIf

				//Cria um novo stc com a nova filial
				dbSelectarea("STC")
				RecLock("STC",.T.)
				For i := 1 TO FCOUNT()

					nn := FieldName(i)
					pp := "STC->"+ FieldName(i)
					vl := cAliTRBSTC + "->" + FieldName(i)

					If nn == "TC_ LOCALIZ"
						If !lTPSexclus
							&pp. := &vl.
						EndIf
					Else
						&pp. := &vl.
					EndIf
				Next i
				STC->TC_FILIAL  := cFilTrSTC
				STC->TC_DATAINI := M->TQ2_DATATR
				MsUnLock("STC")

				If lSTZ
					//Cria um novo stz com a nova filial
					dbSelectarea("STZ")
					RecLock("STZ",.T.)
					For i := 1 TO FCOUNT()
						pp := "STZ->"+ FieldName(i)
						vl := cAliTRBSTZ + "->" + FieldName(i)
						&pp. := &vl.
					Next i
					STZ->TZ_FILIAL  := cFilTrSTZ
					STZ->TZ_DATAMOV := M->TQ2_DATATR
					STZ->TZ_HORAENT := cHORAINC
					STZ->TZ_POSCONT := nCONT1TZ
					STZ->TZ_POSCON2 := nCONT2TZ
					MsUnLock("STZ")

					If ST9->T9_TEMCONT <> "N"
						//Contador 1
						If STZ->TZ_POSCONT > 0
							A550GRVHIS(ST9->T9_CODBEM,ST9->T9_POSCONT,ST9->T9_VARDIA,;
							M->TQ2_DATATR,ST9->T9_CONTACU,ST9->T9_VIRADAS,;
							cHORAINC,1,"C")

							dbSelectArea("ST9")
							RecLock("ST9",.f.)
							ST9->T9_DTULTAC := M->TQ2_DATATR
							MsUnLock("ST9")
						EndIf

						//Contador 2
						If STZ->TZ_POSCON2 > 0
							A550GRVHIS(TPE->TPE_CODBEM,TPE->TPE_POSCON,TPE->TPE_VARDIA,;
							M->TQ2_DATATR,TPE->TPE_CONTAC,TPE->TPE_VIRADA,;
							cHORAINC,2,"C")

							dbSelectArea("TPE")
							RecLock("TPE",.f.)
							TPE->TPE_DTULTA := M->TQ2_DATATR
							MsUnLock("TPE")
						EndIf
					EndIf
				EndIf

				//---------------------------------------------------
				//HISTORICO DE MOVIMENTACAO DE CENTRO DE CUSTO
				nCONTAD1 := 0
				nCONTAD2 := 0

				dbSelectArea("STZ")
				dbSetOrder(1)
				If dbSeek(cFilTrSTZ+STC->TC_COMPONE)
					While !Eof() .And. STZ->TZ_FILIAL = cFilTrSTZ .And. STZ->TZ_CODBEM == STC->TC_COMPONE
						If STZ->TZ_TIPOMOV = 'E'
							nCONTAD1 := STZ->TZ_POSCONT
							nCONTAD2 := STZ->TZ_POSCON2
							Exit
						EndIf
						dbSelectArea("STZ")
						dbskip()
					End
				EndIf

				cCENTRAB := M->TQ2_CENTRA
				dbSelectArea("TPN")
				dbSetOrder(1)
				If !dbSeek(cFilTrTPN+(cTRBSTRU)->TC_COMPONE+M->TQ2_CCUSTO+cCENTRAB+DTOS(M->TQ2_DATATR)+M->TQ2_HORATR)
					RecLock("TPN",.T.)
					TPN->TPN_FILIAL := cFilTrTPN
					TPN->TPN_CODBEM := (cTRBSTRU)->TC_COMPONE
					TPN->TPN_DTINIC := M->TQ2_DATATR
					TPN->TPN_HRINIC := M->TQ2_HORATR
					TPN->TPN_CCUSTO := M->TQ2_CCUSTO
					TPN->TPN_CTRAB  := cCENTRAB
					TPN->TPN_UTILIZ := "U"
					TPN->TPN_POSCON := nCONTAD1
					TPN->TPN_POSCO2 := nCONTAD2
					MsUnLock("TPN")

					//Funcao de integracao com o PIMS atraves do EAI
					If lPIMSINT .And. FindFunction("NGIntPIMS")
						NGIntPIMS("TPN",TPN->(RecNo()),3)
					EndIf
				EndIf
				//---------------------------------------------------

				//----------------------------------------------------------
				//Cria Historico de Movimentacao da Estrutura Organizacional
				aAreaTCJ := GetArea()
				If NGCADICBASE('TCJ_CODNIV','D','TCJ',.F.)
					If NGIFDBSEEK('TAF',"X1"+ST9->T9_CODBEM,6)
						If !NGIFDBSEEK('TCJ',TAF->TAF_CODNIV+TAF->TAF_NIVSUP+"T"+DTOS(dDataBase)+Time(),1)
							RecLock("TCJ",.T.)
							TCJ->TCJ_FILIAL := xFilial("TCJ")
							TCJ->TCJ_CODNIV := TAF->TAF_CODNIV
							TCJ->TCJ_DESNIV := SubStr(TAF->TAF_NOMNIV,1,40)
							TCJ->TCJ_NIVSUP := TAF->TAF_NIVSUP
							TCJ->TCJ_TIPROC := "T"
							TCJ->TCJ_DATA   := dDatabase
							TCJ->TCJ_HORA   := Time()
							MsUnLock("TCJ")
						EndIf
					EndIf
				EndIf
				RestArea(aAreaTCJ)

			EndIf
			A550TCARA( (cTRBSTRU)->TC_COMPONE) //Faz a tranferencia das caracteristicas
			A550TREPO( (cTRBSTRU)->TC_COMPONE) //Faz a tranferencia das pecas de reposicao
			A550BANCON( (cTRBSTRU)->TC_CODBEM + (cTRBSTRU)->TC_COMPONE, 'STC', xFilial( 'STC' ), cEmpAnt, cFilTrSTC, cEmpAnt )//Faz a tranferencia do banco do conhecimento da estrutura
			A550BANCON( (cTRBSTRU)->TC_COMPONE, 'ST9', xFilial( 'ST9' ), cEmpAnt, cFilTrST9, cEmpAnt ) //Faz a tranferencia do banco do conhecimento do bem
			A550TANQUE((cTRBSTRU)->TC_COMPONE) //Faz tranferencia do tanque de combustivel
			
			If lTS3Table
			
				A550PENHOR((cTRBSTRU)->TC_COMPONE,xFilial("TS3")) //Faz transferencia dos registros de veiculo penhorado
			
			Endif
			
			If lTSJTable
			
				A550LEASIN((cTRBSTRU)->TC_COMPONE,xFilial("TSJ")) //Faz transferencia dos registros de leasing de veiculos
			
			Endif
			
			If lTQSInt .And. ( NgSeek( 'ST9', (cTRBSTRU)->TC_COMPONE, 1, 'T9_CATBEM' ) == '3' )
			
				A550PNEUS( (cTRBSTRU)->TC_COMPONE )//Faz a tranferencia de pneus quando integrado com frotas
			
			EndIf

			A550TMANU((cTRBSTRU)->TC_COMPONE,xFilial("STF")) //Faz a tranferencia da manutencao

			dbSelectArea(cTRBSTRU)
			dbskip()
		EndDO
		// Ao final da Leitura apaga todos os dados da tabela pois por conta do oracle não podemos excluir mais a tabela no meio de uma transação
		// dessa forma se for transferencia em lote irá limpar a tabela para a proxima transferência.
		//ZAP
	EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³A550FILI  ³ Autor ³ In cio Luiz Kolling   ³ Data ³22/11/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consistencia dos bens para troca                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A550FILI()

	cNomFilT := Space( Len(cNomFilA) )

	If Empty(M->TQ2_FILDES)
		Return .T.
	EndIf

	If M->TQ2_FILDES = M->TQ2_FILORI
		MsgInfo(STR0021,STR0022)  //"Nova filial do bem devera ser diferente da filial atual"###"NAO CONFORMIDADE"
		Return .F.
	EndIf

	dbSelectArea("SM0")
	dbSetOrder(1)
	If !dbSeek(cEMPREAT+M->TQ2_FILDES)
		MsgInfo(STR0023,STR0022) //"Nova filial do bem nao existe para a empresa atual"###"NAO CONFORMIDADE"
		Return .f.
	EndIf

	cNomFilT := AllTrim(SM0->M0_FILIAL) + " / " + Alltrim(SM0->M0_NOME)

	//--------------------------------------------
	//Carrega filial de cada tabela de transações
	//--------------------------------------------
	A550XFILI()

	If lVerFil
		If !Empty(M->TQ2_CCUSTO)
			If !A550CCUS(.F.)
				cNomCCus		:= Space( 40 )
				cNomCTra		:= Space( 30 )
				M->TQ2_CCUSTO := Space( TamSX3('TQ2_CCUSTO')[1] )
				M->TQ2_CENTRA := Space( TamSX3('TQ2_CENTRA')[1] )
			EndIf
		EndIf

		If !Empty(M->TQ2_CENTRA)
			If !A550CENTR(.F.)
				M->TQ2_CENTRA	:= Space( TamSX3('TQ2_CENTRA')[1] )
				cNomCTra		:= Space( 30 )
			EndIf
		EndIf
	EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³A550CONOK ³ Autor ³ In cio Luiz Kolling   ³ Data ³22/11/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consistencia final antes da transferencia                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A550CONOK(oDlg)
	Local cMENOKF := Space(1)
	Local zz, aBEMTRA := {}

	//CARREGA FILIAL DE CADA TABELA DAS TRANSACOES
	A550XFILI()

	// P.E. PARA INCLUSÃO DE TRATATIVAS ANTES DAS VALIDAÇÕES PARA TRANSFERÊNCIA.
	If ExistBlock( 'MNTA5500' )

		cMenOkF := ExecBlock( 'MNTA5500', .F., .F., { M->TQ2_CODBEM } )

	EndIf

	//VERIFICACAO DO CENTRO DE CUSTO
	If Empty( cMENOKF ) .And. Empty(M->TQ2_CCUSTO)

		MsgInfo(STR0024,STR0022) //"Centro de custo nao informado."###"NAO CONFORMIDADE"
		Return .f.

	ElseIf Empty( cMENOKF )

		//VERIFICACAO DO CENTRO DE CUSTO
		If !A550CCUS(,.T.)
			Return .f.
		EndIf

	EndIf

	//VERIFICACAO DO CENTRO DE TRABALHO
	If Empty( cMENOKF ) .And. !A550CENTR(,.T.)
		Return .F.
	EndIf

	//VERIFICACAO DE CAMPOS OBRIGATORIOS
	If Empty( cMENOKF ) .And. ( Empty( M->TQ2_FILDES ) .Or. Empty( M->TQ2_DATATR ) .Or. Empty( M->TQ2_HORATR ) .Or.;
		IIf( lOSObr, Empty( M->TQ2_ORDEMT ), .F. ) .Or. M->TQ2_POSCON == 0 .Or. M->TQ2_POSCO2 == 0 .Or. Empty( M->TQ2_MOTTRA ) )

		Do Case

			Case ( M->TQ2_POSCON == 0 .And. TIPOACOM )

				/* O campo contador 1 não foi informado ou contém o valor zero. Como este bem possui o controle por contador,
				o campo torna-se de preenchimento obrigatório.*/
				cMenOkF := STR0220 + STR0219

			Case ( M->TQ2_POSCO2 == 0 .And. TIPOACOM2 )

				/* O campo contador 2 não foi informado ou contém o valor zero. Como este bem possui o controle por contador,
				o campo torna-se de preenchimento obrigatório.*/
				cMenOkF := STR0221 + STR0219

			Case ( Empty( M->TQ2_FILDES ) .Or. Empty( M->TQ2_DATATR ) .Or. Empty( M->TQ2_HORATR ) )

				// Um ou mais dos campos obrigatórios ( TQ2_FILDES, TQ2_DATATR ou TQ2_HORATR ) não foram informados.
				cMenOkF := STR0025

			Case IIf( lOSObr, Empty( M->TQ2_ORDEMT ), .F. )

				// Conforme definido no parâmetro MV_NGINFOS, o campo ordem de serviço deve ser informado.
				cMenOkF := STR0223

			Case Empty( M->TQ2_MOTTRA )

				// O campo obrigatório motivo de transferência não foi informado.
				cMenOkF := STR0222

		EndCase

	EndIf

	// Validação da Data
	If Empty(cMENOKF) .And. M->TQ2_DATATR > dDataBase
		Help(" ", 1, "DATAINVAL")
		Return .F.
	EndIf
	// Validação da Hora
	If Empty(cMENOKF) .And. M->TQ2_DATATR == dDataBase .And. M->TQ2_HORATR > SubStr(Time(),1,5)
		Help(" ", 1, "HORAINVALI")
		Return .F.
	EndIf

	If Empty(cMENOKF) .And. Empty(cCAUSAREMC)
		dbSelectArea("STC")
		dbSetOrder(01)
		If dbSeek(xFilial("STC")+M->TQ2_CODBEM)
			cMENOKF := STR0026+CHR(13); //"Codigo da Causa de Remocao nao informado. E obrigatorio informar a Causa de"
			+STR0027 //"Remocao quando o bem da tranferencia possui estrutura de bens."
		EndIf
	EndIf

	If Empty(cMENOKF)
		dbSelectArea("TQ2")
		dbSetOrder(1)
		If dbSeek(xFilial("TQ2")+M->TQ2_CODBEM)
			While !Eof() .And. TQ2->TQ2_filial = xFilial("TQ2") .And.;
			TQ2->TQ2_CODBEM = M->TQ2_CODBEM
				dULTDTR := TQ2->TQ2_DATATR
				cULTHTR := TQ2->TQ2_HORATR
				Dbskip()
			End
			If M->TQ2_DATATR < dULTDTR
				cMENOKF := STR0028+chr(13);  //"Data da transferencia e menor do que a data da ultima"
				+STR0029+"."+chr(13)+chr(13);  //"transferencia do bem"
				+STR0030+"...: "+Dtoc(M->TQ2_DATATR)+chr(13);  //"Data informada"
				+STR0031+".: "+Dtoc(dULTDTR)  //"Data Ul. transfer"
			ElseIf M->TQ2_DATATR = dULTDTR
				If M->TQ2_HORATR <= cULTHTR
					cMENOKF := STR0032+chr(13);  //"Hora da transferencia e menor do que a hora da ultima"
					+STR0029+"."+chr(13)+chr(13);  //"transferencia do bem"
					+STR0033+"...: "+M->TQ2_HORATR+chr(13);  //"Hora informada"
					+STR0034+".: "+cULTHTR   //"Hora Ul. transfer"
				EndIf
			EndIf
		EndIf
	EndIf

	lBEMRPLACE := .F.
	// Existencia do bem na nova filial
	If Empty(cMENOKF)
		dbSelectArea("ST9")
		dbSetOrder(1)
		If dbSeek(cFilTrST9+M->TQ2_CODBEM)
			If ST9->T9_SITBEM = "A"
				cMENOKF := STR0035 //"Ja existe um Bem cadastrado e Ativo para a nova filial."
			Else
				lBEMRPLACE := .T.
			EndIf
		EndIf
	EndIf

	If Empty(cMENOKF)
		dbSelectArea("STJ")
		dbSetOrder(2)
		If dbSeek(Xfilial("STJ")+"B"+M->TQ2_CODBEM)
			While !Eof() .And. STJ->TJ_FILIAL = xFILIAL("STJ") .And. STJ->TJ_TIPOOS = "B" .And.;
			STJ->TJ_CODBEM = M->TQ2_CODBEM
				If STJ->TJ_TERMINO = "N" .And. STJ->TJ_SITUACA $ "LP"
					cMENOKF := STR0038+" "+ Alltrim(M->TQ2_CODBEM)+" "+STR0039+chr(13);  //"Bem"###"nao podera ser transferido, existem"
					+STR0040  //"ordens de servicos liberadas e/ou pendentes."
					Exit
				EndIf
				Dbskip()
			End
		EndIf
	EndIf

	aBEMTRA := NGCOMPEST(M->TQ2_CODBEM,"B",.F.,.F.,.F.)
	If Empty(cMENOKF) //Validas as OS dos componentes da estrutura
		lTEMSTC := .F.
		dbSelectArea("STC")
		dbSetOrder(3)
		If dbSeek(Xfilial("STC")+M->TQ2_CODBEM)
			lTEMSTC := .T.
		EndIf

		If !lTEMSTC

			dbSetOrder(1)
			If dbSeek(xFilial("STC")+M->TQ2_CODBEM)

				For zz := 1 To Len(aBEMTRA)
					dbSelectArea("STJ")
					dbSetOrder(2)
					If dbSeek(xFilial("STJ")+"B"+aBEMTRA[zz])
						While !Eof() .And. STJ->TJ_FILIAL = xFilial("STJ") .And. STJ->TJ_TIPOOS = "B" .And.;
						STJ->TJ_CODBEM = aBEMTRA[zz]
							If STJ->TJ_TERMINO = "N" .And. STJ->TJ_SITUACA $ "LP"
								cMENOKF := STR0038+" "+ Alltrim(M->TQ2_CODBEM)+" "+STR0041+chr(13);  //"Bem"###"nao podera ser transferido, existem ordens de"
								+STR0042+" "+Alltrim(aBEMTRA[zz])+"."   //"servicos liberadas e/ou pendentes para o componente"
								Exit
							EndIf
							dbSkip()
						End
					EndIf
				Next zz

			EndIf
		EndIf
		If lTEMSTC
			cMENOKF := STR0038+" "+ Alltrim(M->TQ2_CODBEM)+" "+STR0043+chr(13);  //"Bem"###"nao podera ser transferido, ja faz"
			+STR0044+chr(13)+chr(13);  //"parte de uma estrutura e/ou nao e pai da estrutura."
			+STR0045 //"O processo sera cancelado."
		EndIf
	EndIf

	//Consiste OS de acompanhamento abertas para o bem pai e componentes
	If Empty(cMENOKF)
		dbSelectArea("TQA")
		dbSetOrder(2)
		If dbSeek(xFilial("TQA")+M->TQ2_CODBEM)
			While !Eof() .And. TQA->TQA_FILIAL = xFILIAL("TQA") .And. TQA->TQA_CODBEM = M->TQ2_CODBEM
				If TQA->TQA_TERMIN = "N" .And. TQA->TQA_SITUAC $ "LP"
					cMENOKF := STR0038+" "+ Alltrim(M->TQ2_CODBEM)+" "+STR0039+chr(13);  //"Bem"###"nao podera ser transferido, existem"
					+STR0046 //"ordens de acompanhamento liberadas e/ou pendentes."
					Exit
				EndIf
				Dbskip()
			End
		EndIf
	EndIf

	If Empty(cMENOKF)
		For zz := 1 To Len(aBEMTRA)
			dbSelectArea("TQA")
			dbSetOrder(2)
			If dbSeek(xFilial("TQA")+aBEMTRA[zz])
				While !Eof() .And. TQA->TQA_FILIAL = xFILIAL("TQA") .And. TQA->TQA_CODBEM = aBEMTRA[zz]
					If TQA->TQA_TERMIN = "N" .And. TQA->TQA_SITUAC $ "LP"
						cMENOKF := STR0038+" "+ Alltrim(M->TQ2_CODBEM)+" "+STR0041+chr(13);  //"Bem"###"nao podera ser transferido, existem ordens de"
						+STR0047+" "+Alltrim(aBEMTRA[zz])+"."   //"acompanhamento liberadas e/ou pendentes para o componente"
						Exit
					EndIf
					dbSkip()
				End
			EndIf
		Next zz
	EndIf

	// Consiste as inconsistencias de abastecimentos
	If Empty(cMENOKF)
		dbSelectArea("ST9")
		dbSetOrder(1)
		If dbSeek(xFilial("ST9")+M->TQ2_CODBEM)
			If !Empty(ST9->T9_PLACA)
				dbSelectArea("TQQ")
				dbSetOrder(3)
				If dbSeek(xFilial("TQQ")+ST9->T9_PLACA)
					cMENOKF := STR0038 + " " + Alltrim(M->TQ2_CODBEM) + STR0208 + ST9->T9_PLACA; //"O Bem" ## " com placa "
					+ STR0209 + chr(13); //" não poderá ser transferido, devido a existência de abastecimento importados  com inconsistência."
					+ STR0210 //" Para analisar as inconsistências deverá acessar a rotina de Analise de Consistência (MNTA700) e realize o acerto para prosseguir na transferência."
				EndIf
			EndIf
		EndIf

		If Empty(cMENOKF)
			For zz := 1 To Len(aBEMTRA)
				dbSelectArea("ST9")
				dbSetOrder(1)
				If dbSeek(xFilial("ST9")+aBEMTRA[zz])
					If !Empty(ST9->T9_PLACA)
						dbSelectArea("TQQ")
						dbSetOrder(3)
						If dbSeek(xFilial("TQQ")+ST9->T9_PLACA)
							cMENOKF := STR0038+" "+ Alltrim(M->TQ2_CODBEM)+" "+STR0048+chr(13);  //"Bem"###"nao podera ser transferido, foi encontrado registros"
							+STR0050+" "+Alltrim(aBEMTRA[zz])+"."  //"de abastecimentos inconsistentes para o componente"
						EndIf
					EndIf
				EndIf
			Next zz
		EndIf
	EndIf

	// Consiste as solicitacoes de servico abertas
	If Empty(cMENOKF)
		dbSelectArea("TQB")
		dbSetOrder(5)
		If dbSeek(xFilial("TQB")+M->TQ2_CODBEM)
			While !Eof() .And. TQB->TQB_FILIAL == xFilial("TQB") .And. TQB->TQB_CODBEM == M->TQ2_CODBEM

				If TQB->TQB_SOLUCA $ "AD"
					cMENOKF := STR0038+" "+ Alltrim(M->TQ2_CODBEM)+" "+STR0051+chr(13);  //"Bem"###"nao podera ser transferido, exitem Solicitacoes de Servico"
					+STR0052 //"Aguardando Análise e/ou Distribuida."
					Exit
				EndIf
				dbSkip()
			End
		EndIf

		If Empty(cMENOKF)
			For zz := 1 To Len(aBEMTRA)
				dbSelectArea("TQB")
				dbSetOrder(5)
				If dbSeek(xFilial("TQB")+aBEMTRA[zz])
					While !Eof() .And. TQB->TQB_FILIAL == xFilial("TQB") .And. TQB->TQB_CODBEM == aBEMTRA[zz]

						If TQB->TQB_SOLUCA $ "AD"
							cMENOKF := STR0038+" "+ Alltrim(M->TQ2_CODBEM)+" "+STR0053+chr(13);  //"Bem"###"nao podera ser transferido, existem Solicitacoes de Servico Aguardando"
							+STR0054+" "+Alltrim(aBEMTRA[zz])+"."  //"Analise e/ou Distribuida para o componente"
							Exit
						EndIf
						dbSkip()
					End
				EndIf
			Next zz
		EndIf

	EndIf

	If !Empty(cMENOKF)
		MsgInfo(cMENOKF,STR0002) //"ATENCAO"
		Return .F.
	EndIf

	//Cheka data/hora de transferencia com o ultimo acompanhamento do bem (contador 1/contador 2)
	If !A550CKCON()
		Return .F.
	EndIf

	//---------------------------------------------------------------------------------
	// verifica se há pneus na estrutura com status aguardando marcação de fogo
	//---------------------------------------------------------------------------------
	If FindFunction( 'MNTAGFOGO' ) .And. !Empty( MNTAGFOGO( M->TQ2_CODBEM ) )
		Return .F.
	EndIf

	nOpcaX := 1

	lFechaWin := .F.

	//-------------------------------------------------------------
	// Integração via mensagem única no processo de transferencia
	//-------------------------------------------------------------
	If FindFunction("MN080INTMB") .And. MN080INTMB(M->TQ2_CODBEM, 2)

		If NGIFDBSEEK( "ST9",PadR( M->TQ2_CODBEM,TAMSX3( "T9_CODBEM" )[1] ),01,.F. )
			Inclui := .F.
			Altera := .T.
			RegToMemory( "ST9",.F. )

			nRegNum := ST9->( Recno() )

			//--------------------------------------------
			// Primeiro realiza integração para inativar o
			// Bem na empresa/filial atual
			//--------------------------------------------

			// Define array private que será usado dentro da integração
			aParamMensUn    := Array( 4 )
			aParamMensUn[1] := nRegNum // Indica numero do registro
			aParamMensUn[2] := 4       // Indica tipo de operação que esta invocando a mensagem unica
			aParamMensUn[3] := .F.     // Indica que se deve recuperar dados da memória
			aParamMensUn[4] := 2       // Indica se deve inativar o bem (1 ativo,2 - inativo)

			lMuEquip := .F.
			bBlock   := { || FWIntegDef( "MNTA080",EAI_MESSAGE_BUSINESS,TRANS_SEND,Nil,"MNTA080" ) }
			If Type( "oMainWnd" ) == "O"
				MsgRun( "Aguarde integração com backoffice...","Equipment",bBlock )
			Else
				Eval( bBlock )
			EndIf

			If !lMuEquip
				Return .F.
			EndIf

			//--------------------------------------------------------
			// Integração para ativar o bem na empresa/filial Destino
			//--------------------------------------------------------

			aTbls       := { { "ST9" } }
			cOldFilIntg := cFilAnt
			nTamFil     := If( FindFunction( "FwSizeFilial" ),FwSizeFilial(),2 )

			NGPREPTBL( aTbls,cEmpAnt,PadR( M->TQ2_FILDES,nTamFil ) ) // Abre Empresa/Filial destino

			// Define array private que será usado dentro da integração
			aParamMensUn    := Array( 4 )
			aParamMensUn[1] := nRegNum // Indica numero do registro
			aParamMensUn[2] := 4       // Indica tipo de operação que esta invocando a mensagem unica
			aParamMensUn[3] := .T.     // Indica que se deve recuperar dados da memória
			aParamMensUn[4] := 1       // Indica se deve inativar o bem (1 ativo,2 - inativo)

			lMuEquip := .F.
			bBlock   := { || FWIntegDef( "MNTA080",EAI_MESSAGE_BUSINESS,TRANS_SEND,Nil,"MNTA080" ) }
			If Type( "oMainWnd" ) == "O"
				MsgRun( "Aguarde integração com backoffice...","Equipment",bBlock )
			Else
				Eval( bBlock )
			EndIf

			If !lMuEquip
				Return .F.
			EndIf

			NGPREPTBL( aTbls,cEmpAnt,cOldFilIntg ) // Restaura Empresa/Filial

		EndIf

	EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³A550MO    ³ Autor ³ In cio Luiz Kolling   ³ Data ³22/11/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consistencia do modo de criacao da tabelas/arquivos         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A550MO()

	Local xx, xz
	Private cMENMOD  := Space(1)

	Private aARQEXC  := {}
	Private aARQCOM  := {}

	AAdd(aARQEXC,{"TPN",STR0058}) //"TPN - MOVIMENTACOES DE CENTRO DE CUSTO"
	AAdd(aARQEXC,{"ST9",STR0059}) //"ST9 - BEM"
	AAdd(aARQEXC,{"STP",STR0060}) //"STP - HISTORICO DE CONTADOR 1"
	AAdd(aARQEXC,{"TPP",STR0062}) //"TPP - HISTORICO DE CONTADOR 2"
	AAdd(aARQEXC,{"TPE",STR0061}) //"TPE - SEGUNDO CONTADOR DO BEM"
	AAdd(aARQEXC,{"STB",STR0063}) //"STB - CARACTERISTICAS DO BEM"
	AAdd(aARQEXC,{"TPY",STR0064}) //"TPY - PECAS DE REPOSICAO"
	AAdd(aARQEXC,{"STC",STR0065}) //"STC - ESTRUTURA DE BENS"
	AAdd(aARQEXC,{"STZ",STR0066}) //"STZ - MOVIMENTACAO DE ESTRUTURA"
	AAdd(aARQEXC,{"STF",STR0067}) //"STF - MANUTENCOES DO BEM"
	AAdd(aARQEXC,{"ST5",STR0068}) //"ST5 - TAREFAS DA MANUTENCAO"
	AAdd(aARQEXC,{"STM",STR0069}) //"STM - DEPENDENCIA DA MANUTENCAO"
	AAdd(aARQEXC,{"STG",STR0070}) //"STG - INSUMOS DA MANUTENCAO"
	AAdd(aARQEXC,{"STH",STR0071}) //"STH - ETAPAS DA MANUTENCAO"
	AAdd(aARQEXC,{"TP1",STR0072}) //"TP1 - OPCOES DA ETAPA DA MANUTENCAO"
	If lTQSInt
		AAdd(aARQEXC,{"TQS",STR0073}) //"TQS - COMPLEMENTO BENS - PNEUS"
		AAdd(aARQEXC,{"TQV",STR0195}) //"TQV - HIST. DE SULCO DE PNEUS"
		AAdd(aARQEXC,{"TQZ",STR0196}) //"TQZ - HISTORICO DE STATUS DE PNEUS"
		AAdd(aARQCOM,{"TQY",STR0118}) //"TQY - STATUS"
		AAdd(aARQCOM,{"TQU",STR0156}) //"TQU - CODIGO DESENHO"
	EndIf
	AAdd(aARQCOM,{"ST6",STR0074}) //"ST6 - FAMILIA DE BENS"
	AAdd(aARQCOM,{"SH7",STR0077}) //"SH7 - CALENDARIOS"
	AAdd(aARQCOM,{"ST4",STR0078}) //"ST4 - SERVICOS DE MANUTENCAO"
	If lTQSInt 
		AAdd(aARQCOM,{"TQT",STR0079}) //"TQT - MEDIDAS DE PNEUS "
	EndIf
	AAdd(aARQCOM,{"TQ2",STR0080}) //"TQ2 - HISTORICO MOVIMEN. ENTRE FILIAIS"

	// modo de acesso
	For xz := 1 To Len(aARQEXC)
		If FWModeAccess(aARQEXC[xz][1],3) <> "E"
			A550GLOG(STR0081, aARQEXC[xz][2],M->TQ2_FILORI,"X", "")  //"Esta Tabela/Arquivo deve estar em modo exclusivo"
			A550GLOG("","","","","")
		EndIf
	Next xz

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A550CONOS ³ Autor ³ In cio Luiz Kolling   ³ Data ³22/11/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consistencia da ordem de servico                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A550CONOS()
	Local cMENORD := Space(1), cMOTIVO := Space(1)

	If !lOSObr .And. Empty(M->TQ2_ORDEMT)
		Return .T.
	EndIf

	lOSTRANS := .T.

	dbSelectArea("STJ")
	dbSetOrder(1)
	If !dbSeek(Xfilial("STJ")+M->TQ2_ORDEMT)
		cMENORD := STR0083 //"Ordem de servico nao cadastrada."
	EndIf

	If Empty(cMENORD)
		If stj->tj_codbem <> M->TQ2_CODBEM
			cMOTIVO := STR0084 //"Ordem de servico nao pertence ao bem."
			lOSTRANS := .F.
		Else
			If stj->tj_situaca # "L" .And. stj->tj_termino # "S"
				cMOTIVO := STR0085 //"Ordem de servico nao liberada/terminada."
				lOSTRANS := .F.
			EndIf
		EndIf
	EndIf

	If Empty(cMENORD)
		If !lOSTRANS
			cMENORD := STR0086+chr(13);  //"Transferencia nao pode ser executada, pois nao foi realizado"
			+STR0087+chr(13)+chr(13);  //"o servico de checagem da transferencia"
			+STR0088+chr(13)+chr(13)+cMOTIVO  //"MOTIVO:"
		EndIf
	EndIf

	If !Empty(cMENORD)
		MsgInfo(cMENORD,STR0089) //"NAO COMFORMIDADE"
		Return .F.
	EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A550COBEM ³ Autor ³ Elisangela Costa      ³ Data ³18/01/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se o bem tem contador proprio                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A550COBEM()

Local lBemAtivo := GetMv("MV_NGMNTAT") $ "1#3"

	If !lVerFil
		M->TQ2_CCUSTO := Space(Len(stj->tj_ccusto))
		M->TQ2_CENTRA := Space(Len(stj->tj_centrab))
	Endif

	dbSelectArea("ST9")
	dbSetOrder(01)
	If dbSeek(xFILIAL("ST9")+M->TQ2_CODBEM)

		If ST9->T9_SITBEM <> "A"
			If ST9->T9_SITBEM == "I"
				MsgInfo(STR0090,STR0022)   //"Situacao do bem inativo, nao pode ser transferido."###"NAO CONFORMIDADE"
			ElseIf ST9->T9_SITBEM == "T"
				MsgInfo(STR0186,STR0022)   //"Situacao do bem 'Transferido', nao pode ser transferido."###"NAO CONFORMIDADE"
			EndIf
			Return .F.
		EndIf

		If lRel12133 .And. nModulo == 19 .And. ST9->T9_CATBEM != '1'

			// Este código não corresponde a um bem. ## Deve ser utilizado o módulo SIGAGFR para realziar sua tranferência.
			Help( '', 1, 'CODBEM', , STR0225, 3, 1, , , , , , { STR0226 } )
			Return .F.

		EndIf

		If ST9->T9_CATBEM == "4" .And. GetNewPar( "MV_NGMNTCC", "N" ) == "S"
			MsgInfo( STR0206 + CRLF + STR0207, STR0022 )
		EndIf

		TIPOACOM  := If(ST9->T9_TEMCONT = "S",.T.,.F.)
		//FindFunction remover na release GetRPORelease() >= '12.1.027'
		If FindFunction("MNTCont2")
			TIPOACOM2 := MNTCont2(xFilial("TPE"), ST9->T9_CODBEM)
		Else
			TIPOACOM2 := If(TPE->(dbSeek(xFILIAL("TPE")+ST9->T9_CODBEM)),.T.,.F.)
		EndIf

	EndIf

	//Valida MV_NGBEMTR
	cMsg := ""
	lCatOK := .T.
	nRecST9 := ST9->(RecNo())
	If !Empty(cBEMTR)
		dbSelectArea("TQY")
		dbSetOrder(01)
		If dbSeek(xFilial("TQY")+cBEMTR)
			If !Empty(TQY->TQY_CATBEM) .And. TQY->TQY_CATBEM != ST9->T9_CATBEM
				lCatOK := .F.
			Else
				dbSelectArea("STC")
				dbSetOrder(01)
				dbSeek(xFilial("STC")+M->TQ2_CODBEM)
				While !Eof() .And. STC->TC_CODBEM == M->TQ2_CODBEM
					dbSelectArea("ST9")
					dbSetOrder(01)
					If dbSeek(xFILIAL("ST9")+STC->TC_COMPONE)
						If !Empty(TQY->TQY_CATBEM) .And. TQY->TQY_CATBEM != ST9->T9_CATBEM
							lCatOK := .F.
						EndIf
					EndIf
					dbSelectArea("STC")
					dbSkip()
				EndDo
			EndIf
			If !lCatOK
				cMsg := STR0187+CHR(13) //"Categoria do status informada no parametro MV_NGBEMTR nao é genérica"
				cMsg += STR0188+CHR(13) //"nem corresponde as categorias da familia. Para realizar a transferencia é"
				cMsg += STR0189+CHR(13) //"necessário que este parâmetro esteja associado a um status cadastrado,"
				cMsg += STR0190 //"com a categoria dos componentes da estrutura ou em branco."
			EndIf
			dbSelectArea("ST9")
			dbGoTo(nRecST9)
		Else
			cMsg := STR0191+CHR(13) //"Nao existe status correspondente ao parametro MV_NGBEMTR. Para realizar "
			cMsg += STR0192+CHR(13) //"a transferencia é necessário que este parâmetro esteja associado a um status"
			cMsg += STR0193 //"cadastrado, com a categoria dos componentes da estrutura ou em branco."
		EndIf
	Else
		cMsg := STR0194+CHR(13) //"Parametro MV_NGBEMTR (para status 'Transferido') está vazio. Para realizar "
		cMsg += STR0192+CHR(13) //"a transferencia é necessário que este parâmetro esteja associado a um status"
		cMsg += STR0193 //"cadastrado, com a categoria dos componentes da estrutura ou em branco."
	EndIf

	//---------------------------------------------------------------------------------
	// verifica se há pneus na estrutura com status aguardando marcação de fogo
	//---------------------------------------------------------------------------------
	If Empty(cMsg) .And. FindFunction( 'MNTAGFOGO' ) .And. !Empty( MNTAGFOGO( M->TQ2_CODBEM ) )
		Return .F.
	EndIf

	If !Empty(cMsg)
		MsgInfo(cMsg)
		Return .F.
	EndIf

	If !TIPOACOM
		M->TQ2_POSCON := 0
	EndIf
	If !TIPOACOM2
		M->TQ2_POSCO2 := 0
	EndIf
	If !lVerFil
		M->TQ2_CCUSTO := ST9->T9_CCUSTO
		M->TQ2_CENTRA := ST9->T9_CENTRAB
	Endif

	cIniCCUSTO  := ST9->T9_CCUSTO
	cINICENTRAB := ST9->T9_CENTRAB

	If !Empty(NGSEEK( "ST9", M->TQ2_CODBEM, 1, "T9_CODIMOB")) .And. lBemAtivo
		//Verifica se o bem possui uma estrutura(tanto quanto pai como filho)
		If NGIFDBSEEK('STC',M->TQ2_CODBEM,1) .Or. NGIFDBSEEK('STC',M->TQ2_CODBEM,3)
			MsgInfo(STR0038 + AllTrim(M->TQ2_CODBEM) + STR0211) //" Bem XXXXX está numa estrutura, sendo assim não é possível continuar com a transferência."
			Return .F.
		EndIf
	EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A550CKCON ³ Autor ³ Elisangela Costa      ³ Data ³18/01/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Cheka se a data/hora de transferencia do bem pai e componen-³±±
±±³          ³tes com contador proprio e maior que o ultimo lancamento de ³±±
±±³          ³historico.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³A550CONOK                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A550CKCON()
	Local zx := 0, vVETCON := {}

	If TIPOACOM
		//Verifica se a data/hora e maior que o ultimo lancamento do historico
		vVETCON := A550CBEM(M->TQ2_CODBEM,M->TQ2_DATATR,M->TQ2_HORATR,1)
		If !Empty(vVETCON)
			If !MsgStop(STR0091  + chr(13);   //"Data/hora de transferencia e menor ou igual que o ultimo acompanhamento"
			+STR0092                                                         + chr(13)+chr(13);   //"do contador 1."
			+STR0038+"...............:  " + Alltrim(vVETCON[1])                             + chr(13);  //"Bem"
			+STR0093+".:  "      + Dtoc(vVETCON[2])                                + chr(13);   //"Dt.Ult.Acomp"
			+STR0013+"..............:  " + vVETCON[3]                                      + chr(13) ;   //"Hora"
			+STR0094+".......:  " + Str(vVETCON[4],9)                                  + chr(13)+ chr(13);   //"Contador"
			+STR0095           + chr(13);   //"Data e hora de transferencia deve ser maior que o ultimo acomp."
			+STR0096           + chr(13);   //"do bem a ser transferido e todos os componentes pertencentes a "
			+STR0097,STR0002)  //"a estrutura controlados por contador proprio."###"ATENCAO"

				Return .F.
			EndIf
		EndIf

	EndIf

	If TIPOACOM2
		//Verifica se a data/hora e maior que o ultimo lancamento do historico
		vVETCON := A550CBEM(M->TQ2_CODBEM,M->TQ2_DATATR,M->TQ2_HORATR,2)
		If !Empty(vVETCON)
			If !MsgStop(STR0091  + chr(13);   //"Data/hora de transferencia e menor ou igual que o ultimo acompanhamento"
			+STR0098                                                          + chr(13)+chr(13);  //"do contador 2."
			+STR0038+"...............:  " + Alltrim(vVETCON[1])                          + chr(13);   //"Bem"
			+STR0093+".:  "      + Dtoc(vVETCON[2])                             + chr(13);  //"Dt.Ult.Acomp"
			+STR0013+"..............:  " + vVETCON[3]                                 + chr(13) ;   //"Hora"
			+STR0094+".......:  " + Str(vVETCON[4],9)                                 + chr(13)+ chr(13);   //"Contador"
			+STR0095          + chr(13);   //"Data e hora de transferencia deve ser maior que o ultimo acomp."
			+STR0096         + chr(13);   //"do bem a ser transferido e todos os componentes pertencentes a "
			+STR0097,STR0002)   //"a estrutura controlados por contador proprio."###"ATENCAO"

				Return .F.
			EndIf
		EndIf
	EndIf

	dbSelectArea("STC")
	dbSetOrder(01)
	If dbSeek(xFilial("STC")+M->TQ2_CODBEM)
		aBEMTRA := NGCOMPEST(M->TQ2_CODBEM,"B",.F.,.F.,.F.)

		For zx := 1 To Len(aBEMTRA)
			dbSelectArea("ST9")
			dbSetOrder(01)
			If dbSeek(xFilial("ST9")+aBEMTRA[zx])
				If ST9->T9_TEMCONT = "S"

					//Verifica se a data/hora e maior que o ultimo lancamento do historico
					vVETCON := A550CBEM(ST9->T9_CODBEM,M->TQ2_DATATR,M->TQ2_HORATR,1)
					If !Empty(vVETCON)
						If !MsgStop(STR0099  + chr(13);   //"Data/hora de transferencia e menor ou igual que o ultimo acompanhamento do "
						+STR0100+"..:"                                             + chr(13)+chr(13);   //"contador 1 do componente"
						+STR0101+"..:  " + Alltrim(vVETCON[1])                                   + chr(13);  //"Componente"
						+STR0093+".:  "      + Dtoc(vVETCON[2])                                + chr(13);   //"Dt.Ult.Acomp"
						+STR0013+"..............:  " + vVETCON[3]                                      + chr(13) ;  //"Hora"
						+STR0094+".......:  "    + Str(vVETCON[4],9)                               + chr(13)+ chr(13); //"Contador"
						+STR0095              + chr(13);   //"Data e hora de transferencia deve ser maior que o ultimo acomp."
						+STR0102               + chr(13);  //"do componente pertencente a estrutura controlado por contador"
						+STR0103,STR0002)   //"proprio."###"ATENCAO"

							Return .F.
						EndIf
					EndIf

					dbSelectArea("TPE")
					dbSetOrder(01)
					If dbSeek(xFilial("TPE")+aBEMTRA[zx])
						//Verifica se a data/hora e maior que o ultimo lancamento do historico
						vVETCON := A550CBEM(ST9->T9_CODBEM,M->TQ2_DATATR,M->TQ2_HORATR,2)
						If !Empty(vVETCON)
							If !MsgStop(STR0099  + chr(13);   //"Data/hora de transferencia e menor ou igual que o ultimo acompanhamento do "
							+STR0104+"..:"                                             + chr(13)+chr(13);   //"contador 2 do componente"
							+STR0101+"..:  " + Alltrim(vVETCON[1])                                  + chr(13);  //"Componente"
							+STR0093+".:  "      + Dtoc(vVETCON[2])                               + chr(13);   //"Dt.Ult.Acomp"
							+STR0013+"..............:  " + vVETCON[3]                                     + chr(13) ; //"Hora"
							+STR0094+".......:  "    + Str(vVETCON[4],9)                              + chr(13)+ chr(13);  //"Contador"
							+STR0095             + chr(13);   //"Data e hora de transferencia deve ser maior que o ultimo acomp."
							+STR0102              + chr(13);   //"do componente pertencente a estrutura controlado por contador"
							+STR0103,STR0002)  //"proprio."###"ATENCAO"
								Return .F.
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		Next zx
	EndIf

	//Consiste o reporter de contador1 e 2
	//Contador 1
	If TIPOACOM .And. M->TQ2_POSCON > 0
		If !NGCHKHISTO(M->TQ2_CODBEM,M->TQ2_DATATR,M->TQ2_POSCON,M->TQ2_HORATR,1,,.T.)
			Return .F.
		EndIf
		If !NGVALIVARD(M->TQ2_CODBEM,M->TQ2_POSCON,M->TQ2_DATATR,M->TQ2_HORATR,1,.T.)
			Return .F.
		EndIf
	EndIf

	//Contador 2
	If TIPOACOM2 .And. M->TQ2_POSCO2 > 0
		If !NGCHKHISTO(M->TQ2_CODBEM,M->TQ2_DATATR,M->TQ2_POSCO2,M->TQ2_HORATR,2,,.T.)
			Return .F.
		EndIf
		If !NGVALIVARD(M->TQ2_CODBEM,M->TQ2_POSCO2,M->TQ2_DATATR,M->TQ2_HORATR,2,.T.)
			Return .F.
		EndIf
	EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A550CBEM  ³ Autor ³ Elisangela Costa      ³ Data ³18/01/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consistencia em relacao ao ultimo lancamento de contador    ³±±
±±³          ³considerando os componentes tambem da estrutura que tem     ³±±
±±³          ³contador proprio.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³A550CONOK                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A550CBEM(cCODBEM,dDATACON,cHORACON,nTCONT)

	Local vARQUI := If(nTCONT = 1,{ 'STP','stp->tp_filial','stp->tp_codbem','stp->tp_dtleitu',;
	'stp->tp_hora',"stp->tp_poscont"},;
	{'TPP','tpp->tpp_filial','tpp->tpp_codbem','tpp->tpp_dtleit',;
	'tpp->tpp_hora',"tpp->tpp_poscon"})

	Local vARREGI := {}

	nREGISHI := 0
	dbSelectArea(vARQUI[1])
	dbSetOrder(5)
	If dbSeek(xFilial(vARQUI[1])+cCODBEM+DTOS(dDATACON)+cHORACON)
		//            Bem         Data          Hora         Cotador
		vARREGI := {&(vARQUI[3]),&(vARQUI[4]),&(vARQUI[5]),&(vARQUI[6])}

	Else
		dbSeek(xFilial(vARQUI[1])+cCODBEM+DTOS(dDATACON)+cHORACON,.T.)
		If Eof()
			Dbskip(-1)
		Else
			If &(vARQUI[2]) = xFILIAL(vARQUI[1]) .And. &(vARQUI[3]) <> cCODBEM
				Dbskip(-1)
			EndIf
		EndIf

		If &(vARQUI[2]) = xFILIAL(vARQUI[1]) .And. &(vARQUI[3]) = cCODBEM

			//Procura o ultimo lancamento de historico do contador
			nREULTRE := Recno()
			While !Eof() .And. &(vARQUI[2]) = xFILIAL(vARQUI[1]) .And. &(vARQUI[3]) = cCODBEM
				nREULTRE := Recno()
				dbSelectArea(vARQUI[1])
				DbSkip()
			End

			dbSelectArea(vARQUI[1])
			DbGoto(nREULTRE)
			If dDATACON = &(vARQUI[4])
				If cHORACON < &(vARQUI[5])
					//            Bem         Data          Hora         Cotador
					vARREGI := {&(vARQUI[3]),&(vARQUI[4]),&(vARQUI[5]),&(vARQUI[6])}
				EndIf
			Else
				If dDATACON < &(vARQUI[4])
					//            Bem         Data          Hora         Cotador
					vARREGI := {&(vARQUI[3]),&(vARQUI[4]),&(vARQUI[5]),&(vARQUI[6])}
				EndIf
			EndIf

		EndIf
	EndIf
Return vARREGI

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³A550GRVHIS³ Autor ³Elisangela Costa       ³ Data ³20/01/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera registro de historico ( STP e TPP)                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cVBEM   - C¢digo do bem                        - Obrigat¢rio³±±
±±³          ³nVCONT  - Valor do contador                    - Obrigat¢rio³±±
±±³          ³nVVARD  - Valor da varia‡ao dia                - Obrigat¢rio³±±
±±³          ³dVDLEIT - Data da leitura                      - Obrigat¢rio³±±
±±³          ³nVACUM  - Valor do contador acumulado          - Obrigat¢rio³±±
±±³          ³nVIRACO - N£mero de viradas                    - Obrigat¢rio³±±
±±³          ³cVHORA  - Hora do lancamento                   - Obrigat¢rio³±±
±±³          ³nTIPOC  - Tipo do contador ( 1/2 )             - Obrigat¢rio³±±
±±³          ³cTIPOL  - Tipo de lancamento                   - Obrigat¢rio³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A550GRVHIS(cVBEM,nVCONT,nVVARD,dVDLEIT,nVACUM,nVIRACO,cVHORA,;
	nTIPOC,cTIPOL)
	Local cPLATP := Replicate('0',Len(STP->TP_ORDEM))
	Local cLANTP := If(cTIPOL = Nil .Or. Empty(cTIPOL),"C",cTIPOL)
	Local cOSSTP := ""

	Local cOldEmpAnt := cEmpAnt
	Local cOldFilAnt := cFilAnt
	Local aTabelas   := { {"STP"}, {"TPP"} }

	Local lApropri := NGCADICBASE("TP_APROPRI","A","STP",.F.) .And. NGCADICBASE("TPP_APROPR","A","TPP",.F.) .And. AllTrim(GetNewPar("MV_NGINTER","N")) == "M"
	Local cApropri := '2'

	// Prepara nova Empresa/Filial
	NGPrepTbl(aTabelas, cEmpAnt, cFilTrSTP)

	// Recebe Ordem de Serviço
	cOSSTP := If(nTIPOC = 1,GETSXENUM('STP','TP_ORDEM'),GETSXENUM('TPP','TPP_ORDEM'))
	ConfirmSX8()
	If nTIPOC == 1
		dbSelectArea("STP")
		dbSetOrder(1)
		While dbSeek(cFilTrSTP + cOSSTP + cPLATP + cVBEM + DTOS(dDataBase))
			cOSSTP := GETSXENUM('STP','TP_ORDEM')
			ConfirmSX8()
		End
	Else
		dbSelectArea("TPP")
		dbSetOrder(1)
		While dbSeek(cFilTrTPP + cOSSTP + cPLATP + cVBEM)
			cOSSTP := GETSXENUM('TPP','TPP_ORDEM')
			ConfirmSX8()
		End
	EndIf

	// Grava Histórico
	dbSelectArea("ST9")
	dbSetOrder(1)
	dbSeek(cFilTrST9+cVBEM)
	If nTIPOC = 1

		If lApropri
			cApropri := If(MNA385APR(cVBEM,dVDLEIT,cVHORA,1,.T.),'1','2')
		EndIf

		dbSelectArea('STP')
		RecLock("STP",.T.)
		STP->TP_FILIAL  := cFilTrSTP
		STP->TP_ORDEM   := cOSSTP
		STP->TP_PLANO   := cPLATP
		STP->TP_CODBEM  := cVBEM
		STP->TP_CCUSTO  := ST9->T9_CCUSTO
		STP->TP_CENTRAB := ST9->T9_CENTRAB
		STP->TP_DTORIGI := dDataBase
		STP->TP_DTREAL  := dDataBase
		STP->TP_POSCONT := nVCONT
		STP->TP_VARDIA  := nVVARD
		STP->TP_DTULTAC := dVDLEIT
		STP->TP_DTLEITU := dVDLEIT
		STP->TP_SITUACA := "L"
		STP->TP_TERMINO := "S"
		STP->TP_USULEI  := If(Len(STP->TP_USULEI) > 15,cUsername,Substr(cUsuario,7,15))
		STP->TP_TEMCONT := ST9->T9_TEMCONT
		STP->TP_ACUMCON := nVACUM
		STP->TP_VIRACON := nVIRACO
		STP->TP_HORA    := cVHORA
		STP->TP_TIPOLAN := cLANTP
		If lApropri
			STP->TP_APROPRI := cApropri
		EndIf
		MsUnLock("STP")
	Else
		nACUMPP := nVACUM
		nVVARDP := nVVARD
		dbSelectArea("TPE")
		dbSetOrder(1)
		If dbSeek(cFilTrTPE+cVBEM)
			dbSelectArea("TPP")
			dbSetOrder(2)
			If !dbSeek(cFilTrTPP+cVBEM)
				nACUMPP := TPE->TPE_CONTAC
				nVVARDP := TPE->TPE_VARDIA
			EndIf
		Else
			dbSelectArea("TPP")
			dbSetOrder(2)
			If !dbSeek(cFilTrTPP+cVBEM)
				nACUMPP := 0
				nVVARDP := 1
			EndIf
		EndIf

		dbSelectArea("TPP")
		dbSetOrder(5)
		RecLock("TPP",.T.)
		TPP->TPP_FILIAL := cFilTrTPP
		TPP->TPP_ORDEM  := cOSSTP
		TPP->TPP_PLANO  := cPLATP
		TPP->TPP_CODBEM := cVBEM
		TPP->TPP_CCUSTO := ST9->T9_CCUSTO
		TPP->TPP_CENTRA := ST9->T9_CENTRAB
		TPP->TPP_DTORIG := dDataBase
		TPP->TPP_DTREAL := dDataBase
		TPP->TPP_POSCON := nVCONT
		TPP->TPP_VARDIA := nVVARDP
		TPP->TPP_DTULTA := dVDLEIT
		TPP->TPP_DTLEIT := dVDLEIT
		TPP->TPP_SITUAC := "L"
		TPP->TPP_TERMIN := "S"
		TPP->TPP_USULEI := If(Len(TPP->TPP_USULEI) > 15,cUsername,Substr(cUsuario,7,15))
		TPP->TPP_ACUMCO := nACUMPP
		TPP->TPP_VIRACO := nVIRACO
		TPP->TPP_HORA   := cVHORA
		TPP->TPP_TIPOLA := cLANTP
		MsUnLock("TPP")
	EndIf

	// Devolve Empresa/Filial anterior
	NGPrepTbl(aTabelas, cOldEmpAnt, cOldFilAnt)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A550CCUS  ³ Autor ³ In cio Luiz Kolling   ³ Data ³22/02/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consistencia do centro de custo                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A550CCUS(lMsg,lFim)

	Default lMsg := .T.
	Default lFim := .F.

	If !lFim .and. lMsg .and. Empty(M->TQ2_CCUSTO)
		cNOMCCUS := ""
		Return .T.
	Endif

	dbSelectArea("CTT")
	dbSetOrder(1)
	cNOMCCUS := ""
	If !dbSeek(cFilTrCTT+M->TQ2_CCUSTO) .Or. CTT_BLOQ == "1"
		If lMsg .Or. !lVerFil
			MsgInfo(STR0105,STR0022) //"Centro de Custo invalido."###"NAO CONFORMIDADE"
			If !lFim .And. lVerFil
				fTrocaFil(2)
			Endif
		Endif
		Return .F.
	Else
		cNOMCCUS := Alltrim(CTT->CTT_DESC01)
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A550CENTR ³ Autor ³ In cio Luiz Kolling   ³ Data ³22/02/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consistencia do  centro de trabalho                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A550CENTR(lMsg,lFim)
	Default lMsg := .T.
	cNOMCTRA := ""
	If !Empty(M->TQ2_CENTRA)

		dbSelectArea("SHB")
		dbSetOrder(1)
		If !dbSeek(cFilTrSHB+M->TQ2_CENTRA)
			If lMsg
				MsgInfo(STR0106,STR0022)   //"Centro de trabalho nao cadastrado para a filial de destino."###"NAO CONFORMIDADE"
				If !lFim .and. lVerFil
					fTrocaFil(2)
				Endif
			Endif
			Return .f.
		Else
			cNOMCTRA := SHB->HB_NOME

			If SHB->HB_CC <> M->TQ2_CCUSTO
				cNOMCTRA := ""
				If lMsg
					Help(" ",1,"CCUSTOTRAB")
					If !lFim .and. lVerFil
						fTrocaFil(2)
					Endif
				Endif
				Return .F.
			EndIf
		EndIf

	EndIf
Return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} A550TMANU
Copia as manutenções de uma filial para enviar a outra

@author  Hamilton Pereira Soldati
@since   06/06/2018
@version P12
@param cCODBEMTRA, caracter, codigo do bem, Obrigatório
@param cFilOri, caracter, codigo da filial origem do bem transferido, esta variavel advem do campo N4_FILORIG, Obrigatório
@param cFilDest, caracter, codigo da filial destino do bem transferido, esta variavel advem do campo N4_FILIAL, Não Obrigatório
@param lexclui, logico, indica se é uma exclusão da transferecia, caso .F. será considarado como inclusão, .T. exclusão, Não Obrigatório
/*/
//-------------------------------------------------------------------

Function A550TMANU(cCODBEMTRA, cFilOri, cFilDest, lExclui)

	Local cQuery     := ""
	Local cAliTRBTP1 := GetNextAlias()
	Local cAliTRBSTH := GetNextAlias()
	Local cAliTRBSTG := GetNextAlias()
	Local cAliTRBSTM := GetNextAlias()
	Local cAliTRBST5 := GetNextAlias()
	Local cAliTRBSTF := GetNextAlias()
	Local lSEQSTF    := IIf(NGVerify("STF"),.T.,.F.)
	Local lSEQST5    := IIf(NGVerify("ST5"),.T.,.F.)
	Local lSEQSTM    := IIf(NGVerify("STM"),.T.,.F.)
	Local lSEQSTG    := IIf(NGVerify("STG"),.T.,.F.)
	Local lSEQSTH    := IIf(NGVerify("STH"),.T.,.F.)
	Local lSEQTP1    := IIf(NGVerify("TP1"),.T.,.F.)
	Local lPROBSTG   := .F.
	Local i
	Local nn
	local aCopyMnt   := {}
	Local cChave     := ""
	local nField     := 0
	Local lTPAexclus := FWModeAccess("TPA",3) == "E"
	Local lST0exclus := FWModeAccess("ST0",3) == "E"
	Local lSB1exclus := FWModeAccess("SB1",3) == "E"
	Local lSAHexclus := FWModeAccess("SAH",3) == "E"
	Local lSH4exclus := FWModeAccess("SH4",3) == "E"
	Local lSA2exclus := FWModeAccess("SA2",3) == "E"
	Local lQDHexclus := FWModeAccess("QDH",3) == "E"
	Local cFilOriNew := ""
	Local cFilDestNew:= ""

	Default lExclui := .F.
	Default cFilOri	:= xFilial("STF",M->TQ2_FILORI)
	Default cFilDest:= xFilial("STF",M->TQ2_FILDES)

	dbSelectArea("STF")
	dbSetOrder(1)

	If lExclui
		cFilOriNew 	:= cFilDest // Se for exclusão deve atualizar a filial de origem
		cFilDestNew := cFilOri  // Se for exclusão deve atualizar a filial de destino
	Else
		cFilOriNew 	:= cFilOri
		cFilDestNew := cFilDest
	EndIf

	MsSeek(xFilial("STF",cFilOriNew) + cCODBEMTRA ) // Posiciona na primeira manutenção da filial origem

	// Percorre todas as manutenções para copia-las.
	If !Eof() .Or. !Bof()
		While STF->TF_FILIAL == xFilial("STF",cFilOriNew) .And. STF->TF_CODBEM == cCODBEMTRA
			// Grava na matrix aCopyMnt todas as manutenções para que seja transferida a filial destino.
			cChave := STF->TF_CODBEM + STF->TF_SERVICO + STF->TF_SEQRELA
			AAdd(aCopyMnt,{cChave,{}})
			For nField := 1 To STF->( FCount())
				AAdd(aCopyMnt[Len(aCopyMnt)][2],{FieldName(nField), STF->&(FieldName(nField))})
			Next nField

			//Inativa a manutenção na filial Origem
			RecLock("STF",.F.)
			STF->TF_ATIVO := "N"
			MsUnLock("STF")

			dbSelectArea("STF")
			dbSkip()
		End
	EndIf

	// Cria as manutenções na filial de destino
	For i := 1 To len(aCopyMnt)
		DbSelectArea("STF")
		DbSetOrder(01)
		If !MsSeek(xFilial("STF",cFilDestNew) + aCopyMnt[i][1]) // aCopyMnt[1] contem a chave unica da STF copiada.
			RecLock("STF",.T.)
		Else
			RecLock("STF",.F.)
		EndIf

		For nField := 1 To len(aCopyMnt[i][2])
			If FieldName(nField) == aCopyMnt[i][2][nField][1]
				STF->&( FieldName(nField)) := aCopyMnt[i][2][nField][2]
			EndIf
		Next nField
		STF->TF_FILIAL := xFilial("STF",cFilDestNew)
		STF->TF_ATIVO  := "S"
		STF->(MsUnLock())
		A550BANCON( STF->TF_CODBEM + STF->TF_SERVICO + STF->TF_SEQRELA, 'STF', xFilial( 'STF' ), cEmpAnt, xFilial( 'STF', cFilDestNew ), cEmpAnt )//Faz a tranferencia do banco do conhecimento

	Next i

	//Cria tabela temporaria copiando as tarefas da manutenção da filial origem
	cQuery := " SELECT * "
	cQuery += "   FROM " + RetSqlName("ST5")
	cQuery += "  WHERE T5_FILIAL  =  " + ValToSQL(xFilial("ST5",cFilOriNew))
	cQuery += "    AND T5_CODBEM  =  " + ValToSQL(cCODBEMTRA)
	cQuery += "    AND D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliTRBST5, .F., .T.)

	//DELETE REGISTRO NA FILIAL DE DESTINO
	dbSelectArea("ST5")
	dbSetOrder(1)
	dbSeek(xFilial("ST5",cFilOriNew)+cCODBEMTRA)
	While !Eof() .And. ST5->T5_FILIAL == xFilial("ST5",cFilOriNew) .And. ST5->T5_CODBEM == cCODBEMTRA
		RecLock("ST5",.F.)
		ST5->(dbDelete())
		ST5->(MsUnLock())
		dbSelectArea('ST5')
		DbSkip()
	EndDo

	//Cria as tarefas na filial de destino
	dbSelectArea(cAliTRBST5)
	dbGotop()
	While !Eof()
		dbSelectArea("ST5")
		cSEQST5 := If(lSEQST5,(cAliTRBST5)->T5_SEQRELA,STR((cAliTRBST5)->T5_SEQUENC,3))
		If !dbSeek(xFilial("ST5",cFilDestNew)+(cAliTRBST5)->T5_CODBEM+(cAliTRBST5)->T5_SERVICO+cSEQST5+(cAliTRBST5)->T5_TAREFA)
			//Cria um novo ST5 com a nova filial
			RecLock("ST5",.T.)
			For i := 1 TO FCOUNT()
				nn := FieldName(i)
				pp := "ST5->"+ FieldName(i)
				vl := cAliTRBST5 + "->" + FieldName(i)

				If nn == "T5_DOCTO" .Or. nn == "T5_DOCFIL"
					If !lQDHexclus
						&pp. := &vl.
					EndIf
				Else
					&pp. := &vl.
				EndIf
			Next i
			ST5->T5_FILIAL := xFilial("ST5",cFilDestNew)
			ST5->(MsUnLock())
		EndIf
		dbSelectArea(cAliTRBST5)
		dbSkip()
	EndDo

	(cAliTRBST5)->(dbCloseArea())

	//Cria tabela temporaria com as dependencias da manutenção na filial de origem
	cQuery := " SELECT * "
	cQuery += "   FROM " + RetSqlName("STM")
	cQuery += "  WHERE TM_FILIAL  =  " + ValToSQL(xFilial("STM",cFilOriNew))
	cQuery += "    AND TM_CODBEM  =  " + ValToSQL(cCODBEMTRA)
	cQuery += "    AND D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliTRBSTM, .F., .T.)

	//DELETE REGISTRO NA FILIAL DE DESTINO
	dbSelectArea("STM")
	dbSetOrder(1)
	dbSeek(xFilial("STM",cFilOriNew)+cCODBEMTRA)
	While !Eof() .And. STM->TM_FILIAL == xFilial("STM",cFilOriNew) .And. STM->TM_CODBEM == cCODBEMTRA
		RecLock("STM",.F.)
		STM->(dbDelete())
		STM->(MsUnLock())
		dbSelectArea("STM")
		dbSkip()
	EndDo

	//CRIA NOVOS REGISTROS NA FILIAL DE DESTINO
	dbSelectArea(cAliTRBSTM)
	dbGotop()
	While !Eof()
		dbSelectArea("STM")
		cSEQSTM := If(lSEQSTM,(cAliTRBSTM)->TM_SEQRELA,STR((cAliTRBSTM)->TM_SEQUENC,3))
		If !dbSeek(xFilial("STM",cFilDestNew)+(cAliTRBSTM)->TM_CODBEM+(cAliTRBSTM)->TM_SERVICO+cSEQSTM+(cAliTRBSTM)->TM_TAREFA+(cAliTRBSTM)->TM_DEPENDE)
			//Cria um novo STM com a nova filial
			RecLock("STM",.T.)
			For i := 1 TO FCOUNT()
				pp := "STM->"+ FieldName(i)
				vl := cAliTRBSTM + "->" + FieldName(i)
				&pp. := &vl.
			Next i
			STM->TM_FILIAL := xFilial("STM",cFilDestNew)
			STM->(MsUnLock())
		EndIf
		dbSelectArea(cAliTRBSTM)
		dbSkip()
	EndDo

	(cAliTRBSTM)->(dbCloseArea())

	//CRIA ARQUIVO TEMPORARIO COM OS DADOS DA FILIAL DE ORIGEM
	cQuery := " SELECT * "
	cQuery += "   FROM " + RetSqlName("STG")
	cQuery += "  WHERE TG_FILIAL  =  " + ValToSQL(xFilial("STG",cFilOriNew))
	cQuery += "    AND TG_CODBEM  =  " + ValToSQL(cCODBEMTRA)
	cQuery += "    AND D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliTRBSTG, .F., .T.)

	//DELETE REGISTRO NA FILIAL DE DESTINO
	dbSelectArea("STG")
	dbSetOrder(1)
	dbSeek(xFilial("STG",cFilOriNew)+cCODBEMTRA)
	While !Eof() .And. STG->TG_FILIAL == xFilial("STG",cFilOriNew) .And. STG->TG_CODBEM == cCODBEMTRA
		RecLock("STG",.F.)
		STG->(dbDelete())
		STG->(MsUnLock())
		dbSelectArea("STG")
		dbSkip()
	EndDo

	//CRIA NOVOS REGISTROS NA FILIAL DE DESTINO
	dbSelectArea(cAliTRBSTG)
	dbGotop()
	While !Eof()
		dbSelectArea("STG")
		cSEQSTG := If(lSEQSTG,(cAliTRBSTG)->TG_SEQRELA,STR((cAliTRBSTG)->TG_SEQUENC,3))
		If !dbSeek(xFilial("STG",cFilDestNew)+(cAliTRBSTG)->TG_CODBEM+(cAliTRBSTG)->TG_SERVICO+cSEQSTG+(cAliTRBSTG)->TG_TAREFA+(cAliTRBSTG)->TG_TIPOREG+(cAliTRBSTG)->TG_CODIGO)

			lPROBSTG := .F.
			If (cAliTRBSTG)->TG_TIPOREG == "M" .And. lST1exclus
				lPROBSTG := .T.

			ElseIf (cAliTRBSTG)->TG_TIPOREG == "E" .And. lST0exclus
				lPROBSTG := .T.

			ElseIf (cAliTRBSTG)->TG_TIPOREG == "P" .And. (lSB1exclus .Or. lSAHexclus)
				lPROBSTG := .T.

			ElseIf (cAliTRBSTG)->TG_TIPOREG == "F" .And. lSH4exclus
				lPROBSTG := .T.

			ElseIf (cAliTRBSTG)->TG_TIPOREG == "T" .And. lSA2exclus
				lPROBSTG := .T.
			EndIf

			If lPROBSTG
				//Inativa a manutencao e nao grava o insumo na filial destino
				dbSelectArea("STF")
				dbSetOrder(01)
				If dbSeek(xFilial("STF",cFilDestNew)+(cAliTRBSTG)->TG_CODBEM+(cAliTRBSTG)->TG_SERVICO+cSEQSTG)
					RecLock("STF",.F.)
					STF->TF_ATIVO := "N"
					STF->(MsUnLock())
				EndIf
				dbSelectArea(cAliTRBSTG)
				dbSkip()
				Loop
			EndIf

			//Cria um novo STG com a nova filial
			dbSelectArea("STG")
			RecLock("STG",.T.)
			For i := 1 TO FCOUNT()
				pp := "STG->"+ FieldName(i)
				vl := cAliTRBSTG + "->" + FieldName(i)
				&pp. := &vl.
			Next i
			STG->TG_FILIAL := xFilial("STG",cFilDestNew)
			STG->(MsUnLock())

		EndIf
		dbSelectArea(cAliTRBSTG)
		dbSkip()
	EndDo
	(cAliTRBSTG)->(dbCloseArea())

	//CRIA ARQUIVO TEMPORARIO COM OS DADOS DA FILIAL DE ORIGEM
	If lTPAexclus
		//DELETA REGISTRO NA FILIAL DE DESTINO
		dbSelectArea("STH")
		dbSetOrder(1)
		dbSeek(xFilial("STH",cFilOriNew)+cCODBEMTRA)
		While !Eof() .And. STH->TH_FILIAL == xFilial("STH",cFilOriNew) .And. STH->TH_CODBEM == cCODBEMTRA
			RecLock("STH",.F.)
			STH->(dbDelete())
			STH->(MsUnLock())

			//Inativa a manutencao e nao grava o insumo na filial destino
			dbSelectArea("STF")
			dbSetOrder(01)
			If dbSeek(xFilial("STF",cFilOriNew)+STH->TH_CODBEM+STH->TH_SERVICO+If(lSEQSTH,STH->TH_SEQRELA,STR(STH->TH_SEQUENC,3)))
				RecLock("STF",.F.)
				STF->TF_ATIVO := "N"
				STF->(MsUnLock())
			EndIf

			dbSelectArea("STH")
			dbSkip()
		End
	Else

		cQuery := " SELECT * "
		cQuery += "   FROM " + RetSqlName("STH")
		cQuery += "  WHERE TH_FILIAL  =  " + ValToSQL(xFilial("STH",cFilOriNew))
		cQuery += "    AND TH_CODBEM  =  " + ValToSQL(cCODBEMTRA)
		cQuery += "    AND D_E_L_E_T_ <> '*' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliTRBSTH, .F., .T.)

		//CRIA NOVOS REGISTROS NA FILIAL DE DESTINO
		dbSelectArea(cAliTRBSTH)
		dbGotop()
		
		While (cAliTRBSTH)->( !EoF() )

			dbSelectArea("STH")
			cSEQSTH := If(lSEQSTH,(cAliTRBSTH)->TH_SEQRELA,STR((cAliTRBSTH)->TH_SEQUENC,3))
			If !dbSeek(xFilial("STH",cFilDestNew)+(cAliTRBSTH)->TH_CODBEM+(cAliTRBSTH)->TH_SERVICO+cSEQSTH+(cAliTRBSTH)->TH_TAREFA+(cAliTRBSTH)->TH_ETAPA)
				//Cria um novo STH com a nova filial
				RecLock("STH",.T.)
				For i := 1 TO FCOUNT()

					nn := FieldName(i)
					pp := "STH->"+ FieldName(i)
					vl := cAliTRBSTH + "->" + FieldName(i)

					If nn == "TF_DOCTO" .Or. nn == "TF_DOCFIL"
						If !lQDHexclus
							&pp. := &vl.
						EndIf
					Else
						&pp. := &vl.
					EndIf
				Next i
				STH->TH_FILIAL := xFilial("STH",cFilDestNew)
				STH->(MsUnLock())
			
			EndIf
			
			(cAliTRBSTH)->( dbSkip() )
		
		End
		(cAliTRBSTH)->(dbCloseArea())

		//DELETE REGISTRO NA FILIAL DE DESTINO
		dbSelectArea("STH")
		dbSetOrder(1)
		dbSeek(xFilial("STH",cFilOriNew)+cCODBEMTRA)
		While !Eof() .And. STH->TH_FILIAL == xFilial("STH",cFilOriNew) .And. STH->TH_CODBEM == cCODBEMTRA
			RecLock("STH",.F.)
			STH->(dbDelete())
			STH->(MsUnLock())
			dbSelectArea("STH")
			dbSkip()
		End

	EndIf

	//CRIA ARQUIVO TEMPORARIO COM OS DADOS DA FILIAL DE ORIGEM
	If lTPAexclus
		//DELETE REGISTRO NA FILIAL DE DESTINO
		dbSelectArea("TP1")
		dbSetOrder(1)
		dbSeek(xFilial("TP1",cFilOriNew)+cCODBEMTRA)
		While !Eof() .And. TP1->TP1_FILIAL == xFilial("TP1",cFilOriNew) .And. TP1->TP1_CODBEM == cCODBEMTRA
			RecLock("TP1",.F.)
			TP1->(dbDelete())
			TP1->(MsUnLock())

			//Inativa a manutencao e nao grava o insumo na filial destino
			dbSelectArea("STF")
			dbSetOrder(01)
			If dbSeek(xFilial("STF",cFilOriNew)+TP1->TP1_CODBEM+TP1->TP1_SERVIC+If(lSEQTP1,TP1->TP1_SEQREL,STR(TP1->TP1_SEQUEN,3)))
				RecLock("STF",.F.)
				STF->TF_ATIVO := "N"
				STF->(MsUnLock())
			EndIf

			dbSelectArea("TP1")
			dbSkip()
		EndDo
	Else

		cQuery := " SELECT * "
		cQuery += "   FROM " + RetSqlName("TP1")
		cQuery += "  WHERE TP1_FILIAL =  " + ValToSQL(xFilial("TP1",cFilOriNew))
		cQuery += "    AND TP1_CODBEM =  " + ValToSQL(cCODBEMTRA)
		cQuery += "    AND D_E_L_E_T_ <> '*' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliTRBTP1, .F., .T.)

		//DELETE REGISTRO NA FILIAL DE DESTINO
		dbSelectArea("TP1")
		dbSetOrder(1)
		dbSeek(xFilial("TP1",cFilOriNew)+cCODBEMTRA)
		While !Eof() .And. TP1->TP1_FILIAL == xFilial("TP1",cFilOriNew) .And. TP1->TP1_CODBEM == cCODBEMTRA
			RecLock("TP1",.F.)
			TP1->(dbDelete())
			TP1->(MsUnLock())
			dbSelectArea("TP1")
			dbSkip()
		End

		//CRIA NOVOS REGISTROS NA FILIAL DE DESTINO
		dbSelectArea(cAliTRBTP1)
		dbGotop()
		While !Eof()
			dbSelectArea("TP1")
			cSEQTP1 := If(lSEQTP1,(cAliTRBTP1)->TP1_SEQREL,STR((cAliTRBTP1)->TP1_SEQUEN,3))
			If !dbSeek(xFilial("TP1",cFilDestNew)+(cAliTRBTP1)->TP1_CODBEM+(cAliTRBTP1)->TP1_SERVIC+cSEQTP1+(cAliTRBTP1)->TP1_TAREFA+(cAliTRBTP1)->TP1_ETAPA+(cAliTRBTP1)->TP1_OPCAO)
				//Cria um novo TP1 com a nova filial

				If !Empty((cAliTRBTP1)->TP1_BEMIMN)
					dbSelectArea("ST9")
					dbSetOrder(1)
					If !dbSeek(xFilial("ST9",cFilDestNew)+(cAliTRBTP1)->TP1_BEMIMN)

						//Inativa a manutencao e nao grava o insumo na filial destino
						dbSelectArea("STF")
						dbSetOrder(01)
						If dbSeek(xFilial("STF",cFilDestNew)+(cAliTRBTP1)->TP1_CODBEM+(cAliTRBTP1)->TP1_SERVIC+If(lSEQTP1,(cAliTRBTP1)->TP1_SEQREL,STR((cAliTRBTP1)->TP1_SEQUEN,3)))
							RecLock("STF",.F.)
							STF->TF_ATIVO := "N"
							STF->(MsUnLock())
						EndIf

						dbSelectArea(cAliTRBTP1)
						dbSkip()
						Loop
					EndIf
				EndIf

				dbSelectArea("TP1")
				RecLock("TP1",.T.)
				For i := 1 TO FCOUNT()
					pp := "TP1->"+ FieldName(i)
					vl := cAliTRBTP1 + "->" + FieldName(i)
					&pp. := &vl.
				Next i
				TP1->TP1_FILIAL := xFilial("TP1",cFilDestNew)
				TP1->(MsUnLock())

			EndIf
			dbSelectArea(cAliTRBTP1)
			dbSkip()
		End
		(cAliTRBTP1)->(dbCloseArea())
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A550TCARA  ³ Autor ³ Ricardo Dal Ponte     ³ Data ³27/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Transferencia das caracteristicas                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A550TCARA(cCODBTRANF)

	Local cAliTRBSTB := GetNextAlias()
	Local i
	Local cQuery

	// Faz copia do STB da filial Origem
	cQuery := " SELECT * "
	cQuery += " FROM " + RetSqlName("STB") + ""
	cQuery += " WHERE TB_FILIAL = '" + xFilial("STB",M->TQ2_FILORI) + "' AND TB_CODBEM = '"+ cCODBTRANF +"' "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliTRBSTB, .F., .T.)

	While !Eof()

		DbselectArea("STB")
		DbsetOrder(1)
		If !Dbseek(xFilial("STB",M->TQ2_FILDES)+(cAliTRBSTB)->TB_CODBEM+(cAliTRBSTB)->TB_CARACTE)
			// 1. Carrega variaveis de memória de todos os campos (padrões e de usuário) da tabela STB.
			// 2. Caso o seek da linha 1150 tenha encontrado o registro conforme chave,
			RecLock("STB",.T.)
			For i := 1 TO FCOUNT()
				pp := "STB->"+ FieldName(i)
				vl := cAliTRBSTB + "->" + FieldName(i)
				&pp. := &vl.
			Next i
			STB->TB_FILIAL := xFilial("STB",M->TQ2_FILDES)
			STB->(MsUnLock())
		EndIf
		dbSelectArea(cAliTRBSTB)
		dbSkip()
	End

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A550TREPO ³ Autor ³ Ricardo Dal Ponte     ³ Data ³23/10/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Transferencia das pecas de reposicao                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A550TREPO(cCODBTRANF)

	Local cAliTRBTPY := GetNextAlias()
	Local cQuery     := ""
	Local i
	Local nn

	If lSB1exclus .Or. lSAHexclus
		//DELETE REGISTRO NA FILIAL DE DESTINO
		dbSelectArea("TPY")
		dbSetOrder(1)
		dbSeek(cFilTrTPY+cCODBTRANF)
		While !Eof() .And. TPY->TPY_FILIAL == cFilTrTPY .And. TPY->TPY_CODBEM == cCODBTRANF
			RecLock("TPY",.F.)
			TPY->(dbDelete())
			TPY->(MsUnLock())
			dbSelectArea("TPY")
			dbSkip()
		End
	Else

		// Faz uma copia do TPY
		cQuery := " SELECT * "
		cQuery += "   FROM " + RetSqlName("TPY") + ""
		cQuery += "  WHERE TPY_FILIAL  =  " + ValToSQL(xFilial("TPY"))
		cQuery += "    AND TPY_CODBEM  =  " + ValToSQL(cCODBTRANF)
		cQuery += "    AND D_E_L_E_T_ <> '*' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliTRBTPY, .F., .T.)

		//DELETE REGISTRO NA FILIAL DE DESTINO
		dbSelectArea("TPY")
		dbSetOrder(1)
		dbSeek(cFilTrTPY+cCODBTRANF)
		While !Eof() .And. TPY->TPY_FILIAL == cFilTrTPY .And. TPY->TPY_CODBEM == cCODBTRANF
			RecLock("TPY",.F.)
			TPY->(dbDelete())
			TPY->(MsUnLock())
			dbSelectArea("TPY")
			dbSkip()
		End

		//CRIA NOVOS REGISTROS NA FILIAL DE DESTINO
		dbSelectArea(cAliTRBTPY)
		dbGotop()
		While !Eof()
			dbSelectArea("TPY")
			If !dbSeek(cFilTrTPY+(cAliTRBTPY)->TPY_CODBEM+(cAliTRBTPY)->TPY_CODPRO)
				//Cria um novo TPY com a nova filial
				RecLock("TPY",.T.)
				For i := 1 TO FCOUNT()

					nn := FieldName(i)
					pp := "TPY->"+ FieldName(i)
					vl := cAliTRBTPY + "->" + FieldName(i)

					If nn == "TPY_LOCGAR"
						If !lTPSexclus
							&pp. := &vl.
						EndIf
					Else
						&pp. := &vl.
					EndIf
				Next i
				TPY->TPY_FILIAL := cFilTrTPY
				TPY->(MsUnLock())
			EndIf
			dbSelectArea(cAliTRBTPY)
			dbSkip()
		End

	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A550TANQUE³ Autor ³Vitor Emanuel Batista  ³ Data ³11/03/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Transferencia do tanque de combustivel (TT8)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A550TANQUE(cCODBTRANF)

	Local i
	Local nn
	Local cAliTRBTT8 := GetNextAlias() //TT8
	Local cQuery     := ""

	If lTQMexclus .And. lTT8Tanque
		//DELETE REGISTRO NA FILIAL DE DESTINO
		dbSelectArea( 'TT8' )
		dbSetOrder( 1 )
		dbSeek( cFilTrTT8 + cCODBTRANF )
		While !Eof() .And. TT8->TT8_FILIAL == cFilTrTT8 .And. TT8->TT8_CODBEM == cCODBTRANF
			RecLock("TT8",.F.)
			TT8->(dbDelete())
			TT8->(MsUnLock())
			dbSelectArea("TT8")
			dbSkip()
		End

	ElseIf lTT8Tanque

		//CRIA ARQUIVO TEMPORARIO COM OS DADOS DA FILIAL DE ORIGEM
		cQuery := " SELECT * "
		cQuery += "   FROM " + RetSqlName("TT8") + ""
		cQuery += "  WHERE TT8_FILIAL  =  " + ValToSQL(xFilial("TT8"))
		cQuery += "    AND TT8_CODBEM  =  " + ValToSQL(cCODBTRANF)
		cQuery += "    AND D_E_L_E_T_ <> '*' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliTRBTT8, .F., .T.)

		//DELETE REGISTRO NA FILIAL DE DESTINO
		dbSelectArea("TT8")
		DbSetOrder(1)
		dbSeek(cFilTrTT8+cCODBTRANF)
		While !Eof() .And. TT8->TT8_FILIAL == cFilTrTT8 .And. TT8->TT8_CODBEM == cCODBTRANF
			RecLock("TT8",.F.)
			TT8->(dbDelete())
			TT8->(MsUnLock())
			dbSelectArea("TT8")
			dbSkip()
		End

		//CRIA NOVOS REGISTROS NA FILIAL DE DESTINO
		dbSelectArea(cAliTRBTT8)
		dbGotop()
		While !Eof()

			dbSelectArea("TT8")
			dbSetOrder(1)
			If !dbSeek(cFilTrTT8+(cAliTRBTT8)->TT8_CODBEM+(cAliTRBTT8)->TT8_CODCOM)

				//Cria um novo TT8 com a nova filial
				RecLock("TT8",.T.)
				For i := 1 TO FCOUNT()

					nn := FieldName(i)
					pp := "TT8->"+ FieldName(i)
					vl := cAliTRBTT8 + "->" + FieldName(i)

					&pp. := &vl.

				Next i
				TT8->TT8_FILIAL := cFilTrTT8
				TT8->(MsUnLock())

			EndIf
			dbSelectArea(cAliTRBTT8)
			dbSkip()
		End

	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} A550PENHOR
Transferencia dos registros de penhor (TS3)

@author  Hamilton Pereira Soldati
@since   06/06/2018
@version P12
@param cCODBTRANF, caracter, codigo do bem, Obrigatório
@param cFilOri, caracter, codigo da filial origem do bem transferido, esta variavel advem do campo N4_FILORIG, Obrigatório
@param cFilDest, caracter, codigo da filial destino do bem transferido, esta variavel advem do campo N4_FILIAL, Não Obrigatório
@param lexclui, logico, indica se é uma exclusão da transferecia, caso .F. será considarado como inclusão, .T. exclusão, Não Obrigatório
/*/
//-------------------------------------------------------------------
Function A550PENHOR(cCODBTRANF,cFilOri,cFilDest,lexclui)

	Local i
	Local nn
	Local cAliTRBTS3 := GetNextAlias()
	Local cQuery     := ""
	Local cFilOriNew := ""
	Local cFilDestNew:= ""

	Default cFilOri	:= xFilial("TS3",M->TQ2_FILORI)
	Default cFilDest:= xFilial("TS3",M->TQ2_FILDES)
	Default lExclui := .F.

	If lExclui
		cFilOriNew 	:= cFilDest // Se for exclusão deve atualizar a filial de origem
		cFilDestNew := cFilOri  // Se for exclusão deve atualizar a filial de destino
	Else
		cFilOriNew 	:= cFilOri
		cFilDestNew := cFilDest
	EndIf

	//CRIA ARQUIVO TEMPORARIO COM OS DADOS DA FILIAL DE ORIGEM
	cQuery := " SELECT * "
	cQuery += "   FROM " + RetSqlName("TS3")
	cQuery += "  WHERE TS3_FILIAL  =  " + ValToSQL(xFilial("TS3",cFilOriNew))
	cQuery += "    AND TS3_CODBEM  =  " + ValToSQL(cCODBTRANF)
	cQuery += "    AND D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliTRBTS3, .F., .T.)

	//DELETE REGISTRO NA FILIAL DE DESTINO
	dbSelectArea("TS3")
	dbSetOrder(1)
	dbSeek(xFilial("ST3",cFilOriNew)+cCODBTRANF)
	While !Eof() .And. TS3->TS3_FILIAL == xFilial("ST3",cFilOriNew) .And. TS3->TS3_CODBEM == cCODBTRANF
		RecLock("TS3",.F.)
		TS3->(dbDelete())
		TS3->(MsUnLock())
		dbSelectArea("TS3")
		dbSkip()
	EndDo

	//CRIA NOVOS REGISTROS NA FILIAL DE ORIGEM
	dbSelectArea(cAliTRBTS3)
	dbGotop()
	While !Eof()
		lGrava := .T.
		dbSelectArea("TS3")
		dbSetOrder(01)
		dbSeek(xFilial("TS3",cFilDestNew)+(cAliTRBTS3)->TS3_CODBEM)
		While !Eof() .And. xFilial("TS3",cFilDestNew) == TS3->TS3_FILIAL .And. (cAliTRBTS3)->TS3_CODBEM == TS3->TS3_CODBEM
			lGrava := If((cAliTRBTS3)->TS3_DTIND == TS3->TS3_DTIND,.F.,lGrava)
			dbSelectArea("TS3")
			dbSkip()
		EndDo
		If lGrava
			//Cria um novo TS3 com a nova filial
			RecLock("TS3",.T.)
			For i := 1 TO FCOUNT()
				pp := "TS3->"+ FieldName(i)
				vl := cAliTRBTS3 + "->" + FieldName(i)
				xConteudo := &(vl)
				If ValType(xConteudo) != "M"
					FieldPut(i, &vl.)
				EndIf
			Next i
			TS3->TS3_FILIAL := xFilial("TS3",cFilDestNew)
			TS3->(MsUnLock())
			dbSelectArea(cAliTRBTS3)
			dbSkip()
		End
	EndDo

Return .T.

/*/{Protheus.doc} A550LEASIN
Transferencia dos registros de leasing (TSJ)

@author  Hamilton Pereira Soldati
@since   06/06/2018
@version P12
@param cCODBTRANF, caracter, codigo do bem, Obrigatório
@param cFilOri, caracter, codigo da filial origem do bem transferido, esta variavel advem do campo N4_FILORIG, Obrigatório
@param cFilDest, caracter, codigo da filial destino do bem transferido, esta variavel advem do campo N4_FILIAL, Não Obrigatório
@param lexclui, logico, indica se é uma exclusão da transferecia, caso .F. será considarado como inclusão, .T. exclusão, Não Obrigatório
/*/
//-------------------------------------------------------------------
Function A550LEASIN(cCODBTRANF,cFilOri, cFilDest, lexclui)

	Local i
	Local cAliTRBTSJ := GetNextAlias()
	Local cQuery     := ""
	Local cFilOriNew := ""
	Local cFilDestNew:= ""

	Default cFilOri	:= xFilial("TSJ",M->TQ2_FILORI)
	Default cFilDest:= xFilial("TSJ",M->TQ2_FILDES)
	Default lExclui := .F.

	If lExclui
		cFilOriNew 	:= cFilDest // Se for exclusão deve atualizar a filial de origem
		cFilDestNew := cFilOri  // Se for exclusão deve atualizar a filial de destino
	Else
		cFilOriNew 	:= cFilOri
		cFilDestNew := cFilDest
	EndIf

	//CRIA ARQUIVO TEMPORARIO COM OS DADOS DA FILIAL DE ORIGEM
	cQuery := " SELECT * "
	cQuery += "   FROM " + RetSqlName("TSJ")
	cQuery += "  WHERE TSJ_FILIAL  =  " + ValToSQL(xFilial("TSJ",cFilOriNew))
	cQuery += "    AND TSJ_CODBEM  =  " + ValToSQL(cCODBTRANF)
	cQuery += "    AND D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliTRBTSJ, .F., .T.)

	//DELETE REGISTRO NA FILIAL DE DESTINO
	dbSelectArea("TSJ")
	dbSetOrder(1)
	dbSeek(xFilial("TSJ",cFilOriNew)+cCODBTRANF)
	While !Eof() .And. TSJ->TSJ_FILIAL == xFilial("TSJ",cFilOriNew) .And. TSJ->TSJ_CODBEM == cCODBTRANF
		RecLock("TSJ",.F.)
		TSJ->(dbDelete())
		TSJ->(MsUnLock())
		dbSelectArea("TSJ")
		dbSkip()
	EndDo

	//CRIA NOVOS REGISTROS NA FILIAL DE DESTINO
	dbSelectArea(cAliTRBTSJ)
	dbGotop()
	While !Eof()

		dbSelectArea("TSJ")
		dbSetOrder(03)
		If !dbSeek(xFilial("TSJ",cFilDestNew)+(cAliTRBTSJ)->TSJ_CODBEM+(cAliTRBTSJ)->TSJ_DTINIC)
			//Cria um novo TSJ com a nova filial
			RecLock("TSJ",.T.)
			For i := 1 TO FCOUNT()
				pp   := "TSJ->" + FieldName(i)
				vl   := cAliTRBTSJ + "->" + FieldName(i)
				xConteudo := &(vl)
				If ValType(xConteudo) != "M"
					FieldPut(i, &vl.)
				EndIf
				//&pp. := &vl.
			Next i

			TSJ->TSJ_FILIAL := xFilial("TSJ",cFilDestNew)
			TSJ->(MsUnLock())
		EndIf
		dbSelectArea(cAliTRBTSJ)
		dbSkip()
	EndDo

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A550BANCON³ Autor ³ Ricardo Dal Ponte     ³ Data ³27/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Transferencia do banco do conhecimento                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCODBEMCON - Codigo da entidade                             ³±±
±±³          ³cTABENTID  - Entidade                                       ³±±
±±³          ³cFILCOENT  - Filial Corrente da Entidade                    ³±±
±±³          ³cFILDESEN  - Filial destino da entidade                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A550BANCON( cCode, cTable, cSourBran, cSourComp, cDestBran, cDestComp )

	Local cAlsAC9  := GetNextAlias()
	Local cAlsACB  := ''
	Local cRoot    := Trim( GetSrvProfString( 'RootPath', '\' ) )
	Local cPathDoc := SuperGetMV( 'MV_DIRDOC', .F., '' ) + '\'
	Local cPathCoS := 'co' + cSourComp + '\'
	Local cPathBrS := IIf( lACBexclus, 'br' + Trim( cSourBran ), 'shared' ) + '\'
	Local cPathS   := Lower( cRoot + cPathDoc + cPathCoS + cPathBrS )
	Local cPathCoD := 'co' + cDestComp + '\'
	Local cPathBrD := IIf( lACBexclus, 'br' + Trim( cDestBran ), 'shared' ) + '\'
	Local cPathD   := Lower( cRoot + cPathDoc + cPathCoD + cPathBrD )
	Local cFile    := ''
	Local nIndex   := 0
	Local xQuery
	Local xTable

	BeginSQL Alias cAlsAC9

		SELECT * FROM %table:AC9%
		WHERE
			AC9_FILIAL = %xFilial:AC9%   AND
			AC9_ENTIDA = %exp:cTable%    AND
			AC9_FILENT = %exp:cSourBran% AND
			AC9_CODENT = %exp:cCode%     AND
			%NotDel%

	EndSQL

	Do While (cAlsAC9)->( !EoF() )

		dbSelectArea( 'AC9' )
		dbSetOrder( 1 ) // AC9_FILIAL + AC9_CODOBJ + AC9_ENTIDA + AC9_FILENT + AC9_CODENT
		If !dbSeek( cFilTrAC9 + (cAlsAC9)->AC9_CODOBJ + (cAlsAC9)->AC9_ENTIDA + cDestBran + (cAlsAC9)->AC9_CODENT )

			// Cria um novo registro na tabela AC9 para a filial destino.
			RecLock( 'AC9', .T. )

				For nIndex := 1 To FCount()

					xTable   := 'AC9->' + FieldName( nIndex )
					xQuery   := (cAlsAC9) + '->' + FieldName( nIndex )
					&xTable. := &xQuery.

				Next nIndex

				AC9->AC9_FILIAL := cFilTrAC9
				AC9->AC9_FILENT := cDestBran

			AC9->( MsUnLock() )

			// Caso possua registro na tabela ACB na filial origem e não possua o mesmo registro na filial destino realiza a cópia.
			dbSelectArea( 'ACB' )
			dbSetOrder( 1 ) // ACB_FILIAL + ACB_CODOBJ
			If dbSeek( xFilial( 'ACB' ) + (cAlsAC9)->AC9_CODOBJ ) .And. !dbSeek( cFilTrACB + (cAlsAC9)->AC9_CODOBJ )

				cAlsACB := GetNextAlias()

				BeginSQL Alias cAlsACB

					SELECT * FROM %table:ACB% WHERE ACB_FILIAL = %xFilial:ACB% AND ACB_CODOBJ = %exp:(cAlsAC9)->AC9_CODOBJ%

				EndSQL

				Do While (cAlsACB)->( !EoF() )

					RecLock( 'ACB', .T. )

						For nIndex := 1 To FCOUNT()

							xTable   := 'ACB->'+ FieldName( nIndex )
							xQuery   := '(cAlsACB)->' + FieldName( nIndex )
							&xTable. := &xQuery.

						Next nIndex

						ACB->ACB_FILIAL := cFilTrACB

					ACB->( MsUnLock() )

					(cAlsACB)->( dbSkip() )

				EndDo

				(cAlsACB)->( dbCloseArea() )

			EndIf

			// Caso não exista cria o diretório para alocar base de conhecimento da filial destino.
			If !ExistDir( cPathD )
				MakeDir( cPathD )
			EndIf

			// Define o nome do arquivo para cópia.
			cFile := Trim( Posicione( 'ACB', 1, xFilial( 'ACB' ) + AC9->AC9_CODOBJ, 'ACB_OBJETO' ) )

			// Realiza a cópia da base de conhecimento para o diretório da filial destino.
			__CopyFile( cPathS + cFile, cPathD + cFile )

		EndIf

		(cAlsAC9)->( dbSkip() )

	EndDo

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} A550PNEUS
Transferência de pneus.
@type function

@author Ricardo Dal Ponte
@since 23/10/2006

@sample A550PNEUS( 'PNEU001' )

@param  cCODBTRANF, Caracter, Código do pneus que será transferido.
@return Lógico    , Define se o processo foi realizado com êxito.
/*/
//------------------------------------------------------------------------------
Function A550PNEUS( cCODBTRANF )

	Local cQuery     := ""
	Local cAliTRBTQS := GetNextAlias()
	Local cAliTRBTQV := GetNextAlias()
	Local cAliTRBTQZ := GetNextAlias()
	Local i
	Local nn
	Local lRet       := .T.

	//CRIA ARQUIVO TEMPORARIO COM OS DADOS DA FILIAL DE ORIGEM
	cQuery := " SELECT * "
	cQuery += "   FROM " + RetSqlName("TQS") + ""
	cQuery += "  WHERE TQS_FILIAL  =  " + ValToSQL(xFilial("TQS"))
	cQuery += "    AND TQS_CODBEM  =  " + ValToSQL(cCODBTRANF)
	cQuery += "    AND D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliTRBTQS, .F., .T.)

	dbSelectArea(cAliTRBTQS)
	dbGotop()
	If (cAliTRBTQS)->(!Eof())

		If lTQVTable
			// Faz uma copia do TQV
			cQuery := " SELECT * "
			cQuery += "   FROM " + RetSqlName("TQV") + ""
			cQuery += "  WHERE TQV_FILIAL  =  " + ValToSQL(xFilial("TQV"))
			cQuery += "    AND TQV_CODBEM  =  " + ValToSQL(cCODBTRANF)
			cQuery += "    AND D_E_L_E_T_ <> '*' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliTRBTQV, .F., .T.)
		EndIf

		If lTQZTable
			// Faz uma copia do TQZ
			cQuery := " SELECT * "
			cQuery += "   FROM " + RetSqlName("TQZ") + ""
			cQuery += "  WHERE TQZ_FILIAL  =  " + ValToSQL(xFilial("TQZ"))
			cQuery += "    AND TQZ_CODBEM  =  " + ValToSQL(cCODBTRANF)
			cQuery += "    AND D_E_L_E_T_ <> '*' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliTRBTQZ, .F., .T.)
		EndIf
	Else
		lRet := .F.
	EndIf

	If lRet

		//CRIA NOVOS REGISTROS NA FILIAL DE DESTINO - TQS
		dbSelectArea(cAliTRBTQS)
		dbGotop()
		While !Eof()

			dbSelectArea("TQS")
			If !dbSeek(cFilTrTQS+(cAliTRBTQS)->TQS_CODBEM)

				//Cria um novo TQS com a nova filial
				RecLock("TQS",.T.)
				For i := 1 TO FCOUNT()
					nn := FieldName(i)
					pp := "TQS->"+ FieldName(i)
					vl := cAliTRBTQS + "->" + FieldName(i)
					FieldPut(i, &vl.)	
				Next i
				TQS->TQS_FILIAL := cFilTrTQS
				TQS->(MsUnLock())

			Else

				RecLock("TQS",.F.)

				For i := 1 TO FCOUNT()

					nn := FieldName(i)
					pp := "TQS->"+ FieldName(i)
					vl := cAliTRBTQS + "->" + FieldName(i)

					If nn <> "TQS_FILIAL"

						If ValType( &pp. ) == 'D'
							&pp. := StoD( &vl. )
						Else
							&pp. := &vl.
						EndIf

					EndIf

				Next i

				TQS->(MsUnLock())

			EndIf

			dbSelectArea(cAliTRBTQS)
			dbSkip()

		End

		If lTQVTable
			//CRIA NOVOS REGISTROS NA FILIAL DE DESTINO - TQV
			dbSelectArea(cAliTRBTQV)
			dbGotop()
			While !Eof()

				dbSelectArea( 'TQV' )
				dbSetOrder( 1 ) // TQV_FILIAL + TQV_CODBEM + TQV_DTMEDI + TQV_HRMEDI + TQV_BANDA
				If !dbSeek( cFilTrTQV + (cAliTRBTQV)->TQV_CODBEM + (cAliTRBTQV)->TQV_DTMEDI + (cAliTRBTQV)->TQV_HRMEDI +;
				            (cAliTRBTQV)->TQV_BANDA )

					//Cria um novo TQV com a nova filial
					RecLock("TQV",.T.)
					For i := 1 TO FCOUNT()

						nn := FieldName(i)
						pp := "TQV->"+ FieldName(i)
						vl := cAliTRBTQV + "->" + FieldName(i)

						If ValType( &pp. ) == 'D'
							&pp. := StoD( &vl. )
						Else
							&pp. := &vl.
						EndIf

					Next i

					TQV->TQV_FILIAL := cFilTrTQV
					TQV->(MsUnLock())

				Else

					RecLock("TQV",.F.)

					For i := 1 TO FCOUNT()

						nn := FieldName(i)
						pp := "TQV->"+ FieldName(i)
						vl := cAliTRBTQV + "->" + FieldName(i)

						If nn <> "TQV_FILIAL"

							If ValType( &pp. ) == 'D'
								&pp. := StoD( &vl. )
							Else
								&pp. := &vl.
							EndIf

						EndIf

					Next i

					TQV->(MsUnLock())

				EndIf

				dbSelectArea(cAliTRBTQV)
				dbSkip()

			End
		EndIf

		If lTQZTable

			//CRIA NOVOS REGISTROS NA FILIAL DE DESTINO - TQZ
			dbSelectArea(cAliTRBTQZ)
			dbGotop()
			While !Eof()

				dbSelectArea( 'TQZ' )
				dbSetOrder( 1 ) // TQZ_FILIAL + TQZ_CODBEM + TQZ_DTSTAT + TQZ_HRSTAT + TQZ_STATUS
				If !dbSeek( cFilTrTQZ + (cAliTRBTQZ)->TQZ_CODBEM + (cAliTRBTQZ)->TQZ_DTSTAT + (cAliTRBTQZ)->TQZ_HRSTAT +;
				            (cAliTRBTQZ)->TQZ_STATUS )

					//Cria um novo TQZ com a nova filial
					RecLock("TQZ",.T.)
					For i := 1 TO FCOUNT()

						nn := FieldName(i)
						pp := "TQZ->"+ FieldName(i)
						vl := cAliTRBTQZ + "->" + FieldName(i)

						If ValType( &pp. ) == 'D'
							&pp. := StoD( &vl. )
						Else
							&pp. := &vl.
						EndIf

					Next i

					TQZ->TQZ_FILIAL := cFilTrTQZ
					TQZ->(MsUnLock())

				Else

					RecLock("TQZ",.F.)

					For i := 1 TO FCOUNT()

						nn := FieldName(i)
						pp := "TQZ->"+ FieldName(i)
						vl := cAliTRBTQZ + "->" + FieldName(i)

						If nn <> "TQZ_FILIAL"

							If ValType( &pp. ) == 'D'
								&pp. := StoD( &vl. )
							Else
								&pp. := &vl.
							EndIf

						EndIf

					Next i

					TQZ->(MsUnLock())

				EndIf

				dbSelectArea(cAliTRBTQZ)
				dbSkip()

			End

		EndIf

	EndIf

	(cAliTRBTQS)->( dbCloseArea() )
	(cAliTRBTQV)->( dbCloseArea() )
	(cAliTRBTQZ)->( dbCloseArea() )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A550ST9T  ³ Autor ³ Ricardo Dal Ponte     ³ Data ³26/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao ST9 - BEM                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A550ST9T()

	Local zz := 0

	dbSelectArea( 'ST9' )
	dbSetOrder( 1 )
	If dbSeek( xFilial( 'ST9' ) + M->TQ2_CODBEM )

		If lM7SX5exclus .And. !Empty(ST9->T9_CORVEI)
			A550GLOG(STR0119+" "+ Alltrim(ST9->T9_CORVEI) + " "+STR0108, STR0059, M->TQ2_FILORI,M->TQ2_FILDES, lM7SX5exclus)   //"M7(SX5) - COR VEICULO"###"TABELA NAO COMPART.,CODIGO SERA GRAV. EM BRANCO NA FILIAL DEST."###"ST9 - BEM"
			A550GLOG("","","","","")
		EndIf

		If l12SX5exclus .And. !Empty(ST9->T9_UFEMPLA)
			A550GLOG(STR0120+" "+ Alltrim(ST9->T9_UFEMPLA) + " "+STR0108, STR0059, M->TQ2_FILORI,M->TQ2_FILDES, l12SX5exclus)   //"12(SX5) - UNID.FEDERAT."###"TABELA NAO COMPART.,CODIGO SERA GRAV. EM BRANCO NA FILIAL DEST."###"ST9 - BEM"
			A550GLOG("","","","","")
		EndIf

		//Carrega Filial de Origem do TS3
		If !Empty(ST9->T9_PLACA)
			dbSelectArea("TS3")
			cFilOriTS3 := A525FILIAL(ST9->T9_PLACA)
		EndIf

		//Carrega Filial de Origem do TSJ
		If !Empty(ST9->T9_PLACA)
			dbSelectArea("TSJ")
			cFilOriTSJ := A755FILIAL(ST9->T9_PLACA)
		EndIf

	EndIf

	//Valida os componentes da Estrutura
	For zz := 1 To Len(aBEMTRA)
		dbSelectArea("ST9")
		dbSetOrder(01)
		If dbSeek(xFilial("ST9")+aBEMTRA[zz])

			If lM7SX5exclus .And. !Empty(ST9->T9_CORVEI)
				A550GLOG(STR0119+" "+ Alltrim(ST9->T9_CORVEI) + " "+STR0123+Alltrim(aBEMTRA[zz]), STR0059, M->TQ2_FILORI,M->TQ2_FILDES, lM7SX5exclus)   //"M7(SX5) - COR VEICULO"###"TABELA NAO COMPART.,COD.SERA GRAV. EM BRANCO FILIAL DEST. PARA COMP: "###"ST9 - BEM"
				A550GLOG("","","","","")
			EndIf

			If l12SX5exclus .And. !Empty(ST9->T9_UFEMPLA)
				A550GLOG(STR0120+" "+ Alltrim(ST9->T9_UFEMPLA) + " "+STR0123+Alltrim(aBEMTRA[zz]), STR0059, M->TQ2_FILORI,M->TQ2_FILDES, l12SX5exclus)   //"12(SX5) - UNID.FEDERAT."###"TABELA NAO COMPART.,COD.SERA GRAV. EM BRANCO FILIAL DEST. PARA COMP: "###"ST9 - BEM"
				A550GLOG("","","","","")
			EndIf

		EndIf
	Next zz

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A550STFT  ³ Autor ³ Ricardo Dal Ponte     ³ Data ³26/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao STF - MANUTENCAO                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A550STFT()

	Local zz := 0

	If !lQDHexclus
		Return .T.
	EndIf

	dbSelectArea("STF")
	dbSetOrder(1)
	dbSeek(xFilial("STF")+M->TQ2_CODBEM)
	While !Eof() .And. STF->TF_FILIAL == xFilial("STF") .And. STF->TF_CODBEM == M->TQ2_CODBEM

		//VALIDACAO DO DOCUMENTO
		If lQDHexclus .And. !Empty(STF->TF_DOCTO)
			A550GLOG(STR0127+" "+ Alltrim(STF->TF_DOCTO) + " "+STR0108, STR0128, M->TQ2_FILORI, M->TQ2_FILDES, lQDHexclus)   //"QDH - COD.PROCED."###"TABELA NAO COMPART.,CODIGO SERA GRAV. EM BRANCO NA FILIAL DEST."###"STF - MANUTENCAO"
			A550GLOG("","","","","")
		EndIf
		dbSkip()

	End

	//Valida os componentes da Estrutura
	For zz := 1 To Len(aBEMTRA)

		dbSelectArea("STF")
		dbSetOrder(1)
		dbSeek(xFilial("STF")+aBEMTRA[zz])
		While !Eof() .And. STF->TF_FILIAL == xFilial("STF") .And. STF->TF_CODBEM == aBEMTRA[zz]

			//VALIDACAO DO DOCUMENTO
			If lQDHexclus .And. !Empty(STF->TF_DOCTO)
				A550GLOG(STR0127+" "+ Alltrim(STF->TF_DOCTO) + " "+STR0123+Alltrim(aBEMTRA[zz]), STR0128, M->TQ2_FILORI, M->TQ2_FILDES, lQDHexclus)   //"QDH - COD.PROCED."###"TABELA NAO COMPART.,COD.SERA GRAV. EM BRANCO FILIAL DEST. PARA COMP: "###"STF - MANUTENCAO"
				A550GLOG("","","","","")
			EndIf
			dbSkip()
		End

	Next zz

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A550ST5T  ³ Autor ³ Ricardo Dal Ponte     ³ Data ³26/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao ST5 - TAREFAS DA MANUTENCAO                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A550ST5T()

	Local zz := 0

	If !lQDHexclus
		Return .T.
	EndIf

	dbSelectArea("ST5")
	dbSetOrder(1)
	dbSeek(xFilial("ST5")+M->TQ2_CODBEM)
	While !Eof() .And. ST5->T5_FILIAL == xFilial("ST5") .And. ST5->T5_CODBEM == M->TQ2_CODBEM

		//VALIDACAO DO DOCUMENTO
		If lQDHexclus .And. !Empty(ST5->T5_DOCTO)
			A550GLOG(STR0127+" "+ Alltrim(ST5->T5_DOCTO) + " "+STR0108, STR0129, M->TQ2_FILORI, M->TQ2_FILDES, lQDHexclus)   //"QDH - COD.PROCED."###"TABELA NAO COMPART.,CODIGO SERA GRAV. EM BRANCO NA FILIAL DEST."###"ST5 - TAREFAS"
			A550GLOG("","","","","")
		EndIf
		dbSkip()

	End

	//Valida os componentes da Estrutura
	For zz := 1 To Len(aBEMTRA)

		dbSelectArea("ST5")
		dbSetOrder(1)
		dbSeek(xFilial("ST5")+aBEMTRA[zz])
		While !Eof() .And. ST5->T5_FILIAL == xFilial("ST5") .And. ST5->T5_CODBEM == aBEMTRA[zz]

			//VALIDACAO DO DOCUMENTO
			If lQDHexclus .And. !Empty(ST5->T5_DOCTO)
				A550GLOG(STR0127+" "+ Alltrim(ST5->T5_DOCTO) + " "+STR0123+Alltrim(aBEMTRA[zz]), STR0129,M->TQ2_FILORI, M->TQ2_FILDES, lQDHexclus)   //"QDH - COD.PROCED."###"TABELA NAO COMPART.,COD.SERA GRAV. EM BRANCO FILIAL DEST. PARA COMP: "###"ST5 - TAREFAS"
				A550GLOG("","","","","")
			EndIf
			dbSkip()
		End

	Next zz

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A550STGT  ³ Autor ³ Ricardo Dal Ponte     ³ Data ³26/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao STG - DETALHES DA MANUTENCAO                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A550STGT()
	Local zz := 0
	Local lCOMST1 := .F., lCOMST0 := .F., lCOMSB1 := .F., lCOMSH4 := .F., lCOMSA2 := .F.,lCOMSAH := .F.

	If !lST1exclus  .And.  !lST0exclus .And. !lSB1exclus .And. !lSAHexclus .And. !lSH4exclus .And. !lSA2exclus
		Return .T.
	EndIf

	dbSelectArea("STG")
	dbSetOrder(1)
	dbSeek(xFilial("STG")+M->TQ2_CODBEM)
	While !Eof() .And. STG->TG_FILIAL == xFilial("STG") .And. STG->TG_CODBEM == M->TQ2_CODBEM

		If lCOMST1 .And. lCOMST0 .And. lCOMSB1 .And. lCOMSH4 .And. lCOMSA2 .And. lCOMSAH
			Exit
		EndIf

		If !lCOMST1 .And. lST1exclus .And. STG->TG_TIPOREG == "M" //Mao de obra
			lCOMST1 := .T.
			A550GLOG(STR0130, STR0131, M->TQ2_FILORI, M->TQ2_FILDES, lST1exclus)   //"ST1 - FUNCION.-TABELA N/ COMPART.,NAO SERA GRAV.INSUMO MAO OBRA NA FILIAL DEST., MANUT. FICARA INATIVA."###"STG - INSUMOS."
			A550GLOG("","","","","")
		EndIf

		If !lCOMST0 .And. lST0exclus .And. STG->TG_TIPOREG == "E" //Especialidade
			lCOMST0 := .T.
			A550GLOG(STR0132, STR0131, M->TQ2_FILORI, M->TQ2_FILDES, lST0exclus)   //"ST0 - ESPECIAL.-TABELA N/ COMPART.,NAO SERA GRAV.INSUMO ESPEC. NA FILIAL DEST., MANUT. FICARA INATIVA."###"STG - INSUMOS."
			A550GLOG("","","","","")
		EndIf

		If STG->TG_TIPOREG == "P" //Produto
			If !lCOMSB1 .And. lSB1exclus
				lCOMSB1 := .T.
				A550GLOG(STR0133, STR0131, M->TQ2_FILORI, M->TQ2_FILDES, lSB1exclus)   //"SB1 - PRODUTO-TABELA N/ COMPART.,NAO SERA GRAV.INSUMO PRODUTO NA FILIAL DEST., MANUT. FICARA INATIVA."###"STG - INSUMOS."
				A550GLOG("","","","","")
			EndIf

			If !lCOMSAH .And. lSAHexclus
				lCOMSAH := .T.
				A550GLOG(STR0134, STR0131, M->TQ2_FILORI, M->TQ2_FILDES, lSAHexclus)   //"SAH - UNIDADE MED.-TABELA N/ COMPART.,NAO SERA GRAV.INSUMO PRODUTO NA FILIAL DEST., MANUT. FICARA INATIVA."###"STG - INSUMOS."
				A550GLOG("","","","","")
			EndIf
		EndIf

		If !lCOMSH4 .And. lSH4exclus .And. STG->TG_TIPOREG == "F" //Ferramenta
			lCOMSH4 := .T.
			A550GLOG(STR0135, STR0131, M->TQ2_FILORI, M->TQ2_FILDES, lSH4exclus)   //"SH4 - FERRAMENTA-TABELA N/ COMPART.,NAO SERA GRAV.INSUMO FERRAM. NA FILIAL DEST., MANUT. FICARA INATIVA."###"STG - INSUMOS."
			A550GLOG("","","","","")
		EndIf

		If !lCOMSA2 .And. lSA2exclus .And. STG->TG_TIPOREG == "T" //Terceiros
			lCOMSA2 := .T.
			A550GLOG(STR0136, STR0131, M->TQ2_FILORI, M->TQ2_FILDES, lSA2exclus)   //"SA2 - FORNECEDORES-TABELA N/ COMPART.,NAO SERA GRAV.INSUMO TERC. NA FILIAL DEST., MANUT. FICARA INATIVA."###"STG - INSUMOS."
			A550GLOG("","","","","")
		EndIf

		dbSkip()
	End

	//Valida os componentes da Estrutura
	For zz := 1 To Len(aBEMTRA)

		If lCOMST1 .And. lCOMST0 .And. lCOMSB1 .And. lCOMSH4 .And. lCOMSA2 .And. lCOMSAH
			Exit
		EndIf

		dbSelectArea("STG")
		dbSetOrder(1)
		dbSeek(xFilial("STG")+aBEMTRA[zz])
		While !Eof() .And. STG->TG_FILIAL == xFilial("STG") .And. STG->TG_CODBEM == aBEMTRA[zz]

			If lCOMST1 .And. lCOMST0 .And. lCOMSB1 .And. lCOMSH4 .And. lCOMSA2 .And. lCOMSAH
				Exit
			EndIf

			If !lCOMST1 .And. lST1exclus .And. STG->TG_TIPOREG == "M" //Mao de obra
				lCOMST1 := .T.
				A550GLOG(STR0130, STR0131, M->TQ2_FILORI, M->TQ2_FILDES, lST1exclus)   //"ST1 - FUNCION.-TABELA N/ COMPART.,NAO SERA GRAV.INSUMO MAO OBRA NA FILIAL DEST., MANUT. FICARA INATIVA."###"STG - INSUMOS."
				A550GLOG("","","","","")
			EndIf

			If !lCOMST0 .And. lST0exclus .And. STG->TG_TIPOREG == "E" //Especialidade
				lCOMST0 := .T.
				A550GLOG(STR0132, STR0131, M->TQ2_FILORI, M->TQ2_FILDES, lST0exclus)   //"ST0 - ESPECIAL.-TABELA N/ COMPART.,NAO SERA GRAV.INSUMO ESPEC. NA FILIAL DEST., MANUT. FICARA INATIVA."###"STG - INSUMOS."
				A550GLOG("","","","","")
			EndIf

			If STG->TG_TIPOREG == "P" //Produto
				If !lCOMSB1 .And. lSB1exclus
					lCOMSB1 := .T.
					A550GLOG(STR0133, STR0131, M->TQ2_FILORI, M->TQ2_FILDES, lSB1exclus)   //"SB1 - PRODUTO-TABELA N/ COMPART.,NAO SERA GRAV.INSUMO PRODUTO NA FILIAL DEST., MANUT. FICARA INATIVA."###"STG - INSUMOS."
					A550GLOG("","","","","")
				EndIf

				If !lCOMSAH .And. lSAHexclus
					lCOMSAH := .T.
					A550GLOG(STR0134, STR0131, M->TQ2_FILORI, M->TQ2_FILDES, lSAHexclus)   //"SAH - UNIDADE MED.-TABELA N/ COMPART.,NAO SERA GRAV.INSUMO PRODUTO NA FILIAL DEST., MANUT. FICARA INATIVA."###"STG - INSUMOS."
					A550GLOG("","","","","")
				EndIf
			EndIf

			If !lCOMSH4 .And. lSH4exclus .And. STG->TG_TIPOREG == "F" //Ferramenta
				lCOMSH4 := .T.
				A550GLOG(STR0135, STR0131, M->TQ2_FILORI, M->TQ2_FILDES, lSH4exclus)   //"SH4 - FERRAMENTA-TABELA N/ COMPART.,NAO SERA GRAV.INSUMO FERRAM. NA FILIAL DEST., MANUT. FICARA INATIVA."###"STG - INSUMOS."
				A550GLOG("","","","","")
			EndIf

			If !lCOMSA2 .And. lSA2exclus .And. STG->TG_TIPOREG == "T" //Terceiros
				lCOMSA2 := .T.
				A550GLOG(STR0137, STR0131, M->TQ2_FILORI, M->TQ2_FILDES, lSA2exclus)   //"SA2 - FORNECEDORES-TABELA NAO COMPART.,NAO SERA GRAV.INSUMO TERC. NA FILIAL DEST., MANUT. FICARA INATIVA."###"STG - INSUMOS."
				A550GLOG("","","","","")
			EndIf
			dbSelectArea("STG")
			dbSkip()
		End
	Next zz

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A550STHT  ³ Autor ³ Ricardo Dal Ponte     ³ Data ³26/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao STH - ETAPAS DA MANUTENCAO                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A550STHT()

	Local lCOMPTPA := .F.
	Local zz := 0

	If !lTPAexclus .And. !lQDHexclus
		Return .T.
	EndIf

	dbSelectArea("STH")
	dbSetOrder(1)
	If dbSeek(xFilial("STH")+M->TQ2_CODBEM)

		If lTPAexclus
			lCOMPTPA := .T.
			A550GLOG(STR0138, STR0139, M->TQ2_FILORI, M->TQ2_FILDES,lTPAexclus)   //"TPA/TPC - ETAPAS GENEN. - TABELA NAO COMPART.,NAO SERA GRAV.ETAPAS NA FILIAL DEST.,MANUT. FICARA INATIVA."###"STH - ETAPAS."
			A550GLOG("","","","","")
		EndIf

	EndIf

	If !lTPAexclus .And. lQDHexclus .And. lDOCTSTH
		dbSelectArea("STH")
		dbSetOrder(1)
		If dbSeek(xFilial("STH")+M->TQ2_CODBEM)
			While !Eof() .And. STH->TH_FILIAL == xFilial("STH") .And. STH->TH_CODBEM == M->TQ2_CODBEM
				If !Empty(STH->TH_DOCTO)
					A550GLOG(STR0127+" "+ Alltrim(STH->TH_DOCTO) + " "+STR0108, STR0140,M->TQ2_FILORI, M->TQ2_FILDES, lQDHexclus)   //"QDH - COD.PROCED."###"TABELA NAO COMPART.,CODIGO SERA GRAV. EM BRANCO NA FILIAL DEST."###"STH - ETAPAS"
					A550GLOG("","","","","")
				EndIf
				dbSelectArea("STH")
				dbSkip()
			End
		EndIf
	EndIf

	//Valida os componentes da Estrutura
	For zz := 1 To Len(aBEMTRA)

		If lTPAexclus .And. lCOMPTPA
			Exit
		EndIf

		dbSelectArea("STH")
		dbSetOrder(1)
		If dbSeek(xFilial("STH")+aBEMTRA[zz])

			If lTPAexclus
				lCOMPTPA := .T.
				A550GLOG(STR0141, STR0139, M->TQ2_FILORI, M->TQ2_FILDES,lTPAexclus)   //"TPA/TPC - ETAPAS GENEN. - TABELA NAO COMPART.,NAO SERA GRAV.ETAPAS NA FILIAL DEST., MANUT. FICARA INATIVA."###"STH - ETAPAS."
				A550GLOG("","","","","")
			EndIf

		EndIf

		If !lTPAexclus .And. lQDHexclus .And. lDOCTSTH
			dbSelectArea("STH")
			dbSetOrder(1)
			If dbSeek(xFilial("STH")+aBEMTRA[zz])
				While !Eof() .And. STH->TH_FILIAL == xFilial("STH") .And. STH->TH_CODBEM == aBEMTRA[zz]
					If !Empty(STH->TH_DOCTO)
						A550GLOG(STR0127+" "+ Alltrim(STH->TH_DOCTO) + " "+STR0108, STR0140, M->TQ2_FILORI, M->TQ2_FILDES, lQDHexclus)   //"QDH - COD.PROCED."###"TABELA NAO COMPART.,CODIGO SERA GRAV. EM BRANCO NA FILIAL DEST."###"STH - ETAPAS"
						A550GLOG("","","","","")
					EndIf
					dbSelectArea("STH")
					dbSkip()
				End
			EndIf
		EndIf
	Next zz

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A550TP1T  ³ Autor ³ Ricardo Dal Ponte     ³ Data ³26/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao TP1 - OPCOES DA ETAPA DA MANUTENCAO               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A550TP1T()
	Local lCOMPTPA := .F.
	Local zz := 0

	If !lTPAexclus .And. !lST9exclus
		Return .T.
	EndIf

	dbSelectArea("TP1")
	dbSetOrder(1)
	If dbSeek(xFilial("TP1")+M->TQ2_CODBEM)

		If lTPAexclus
			lCOMPTPA := .T.
			A550GLOG(STR0142, STR0143, M->TQ2_FILORI, M->TQ2_FILDES,lTPAexclus)   //"TPA/TPC - ETAPAS GENEN. - TABELA NAO COMPART.,NAO SERA GRAV.OPCOES ETAPA NA FILIAL DEST., MANUT. FICARA INATIVA."###"TP1 - OPCOES ETAPA."
			A550GLOG("","","","","")
		EndIf

	EndIf

	If !lTPAexclus .And. lST9exclus
		dbSelectArea("TP1")
		dbSetOrder(1)
		If dbSeek(xFilial("TP1")+M->TQ2_CODBEM)
			While !Eof() .And. TP1->TP1_FILIAL == xFilial("TP1") .And. TP1->TP1_CODBEM == M->TQ2_CODBEM
				If !Empty(TP1->TP1_BEMIMN)
					dbSelectArea("ST9")
					dbSetOrder(1)
					If !dbSeek(cFilTrST9+TP1->TP1_BEMIMN)
						A550GLOG(STR0144+" "+ Alltrim(TP1->TP1_BEMIMN) + " "+STR0145, STR0143, M->TQ2_FILORI, M->TQ2_FILDES, lQDHexclus)   //"ST9 - COD.BEM MANUT."###"NAO ENCONTRADO,OPCAO DA ETAPA NAO SERA GRAVADA NA FILIAL DEST., MANUT. FICARA INATIVA."###"TP1 - OPCOES ETAPA."
						A550GLOG("","","","","")
					EndIf
				EndIf
				dbSelectArea("TP1")
				dbSkip()
			End
		EndIf
	EndIf

	//Valida os componentes da Estrutura
	For zz := 1 To Len(aBEMTRA)

		If lTPAexclus .And. lCOMPTPA
			Exit
		EndIf

		dbSelectArea("TP1")
		dbSetOrder(1)
		If dbSeek(xFilial("TP1")+aBEMTRA[zz])
			If lTPAexclus
				lCOMPTPA := .T.
				A550GLOG(STR0142, STR0143, M->TQ2_FILORI, M->TQ2_FILDES,lTPAexclus)   //"TPA/TPC - ETAPAS GENEN. - TABELA NAO COMPART.,NAO SERA GRAV.OPCOES ETAPA NA FILIAL DEST., MANUT. FICARA INATIVA."###"TP1 - OPCOES ETAPA."
				A550GLOG("","","","","")
			EndIf
		EndIf

		If !lTPAexclus .And. lST9exclus
			dbSelectArea("TP1")
			dbSetOrder(1)
			If dbSeek(xFilial("TP1")+aBEMTRA[zz])
				While !Eof() .And. TP1->TP1_FILIAL == xFilial("TP1") .And. TP1->TP1_CODBEM == aBEMTRA[zz]
					If !Empty(TP1->TP1_BEMIMN)
						dbSelectArea("ST9")
						dbSetOrder(1)
						If !dbSeek(cFilTrST9+TP1->TP1_BEMIMN)
							A550GLOG(STR0144+" "+ Alltrim(TP1->TP1_BEMIMN) + " "+STR0145, STR0143, M->TQ2_FILORI, M->TQ2_FILDES, lST9exclus)   //"ST9 - COD.BEM MANUT."###"NAO ENCONTRADO,OPCAO DA ETAPA NAO SERA GRAVADA NA FILIAL DEST., MANUT. FICARA INATIVA."###"TP1 - OPCOES ETAPA."
							A550GLOG("","","","","")
						EndIf
					EndIf
					dbSelectArea("TP1")
					dbSkip()
				End
			EndIf
		EndIf
	Next zz
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A550STBT  ³ Autor ³ Ricardo Dal Ponte     ³ Data ³26/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao STB - DETALHES DO BEM                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A550STBT()

	Local zz := 0
	Local lCOMPTPR := .F.

	If !lTPRexclus .And. !lSAHexclus
		Return .T.
	EndIf

	If !lTPRexclus .And. lSAHexclus
		dbSelectArea("STB")
		dbSetOrder(1)
		If dbSeek(xFilial("STB")+M->TQ2_CODBEM)
			While !Eof() .And. STB->TB_FILIAL = xFILIAL("STB") .And. STB->TB_CODBEM  == M->TQ2_CODBEM
				If !Empty(STB->TB_UNIDADE)
					A550GLOG(STR0148+" "+ Alltrim(STB->TB_UNIDADE) + " "+STR0149, STR0147, M->TQ2_FILORI, M->TQ2_FILDES, lSAHexclus)   //"SAH - UNIDADE MED."###"TABELA NAO COMPART.,NAO SERA GRAV. UNIDAD.MED. NA FILIAL DEST."###"STB - CARACT.BEM"
					A550GLOG("","","","","")
				EndIf
				dbSkip()
			End
		EndIf
	EndIf

	//Valida os componentes da Estrutura
	For zz := 1 To Len(aBEMTRA)

		If lCOMPTPR .And. lTPRexclus
			Exit
		EndIf

		If !lTPRexclus .And. lSAHexclus
			dbSelectArea("STB")
			dbSetOrder(1)
			If dbSeek(xFilial("STB")+aBEMTRA[zz])
				While !Eof() .And. STB->TB_FILIAL = xFILIAL("STB") .And. STB->TB_CODBEM  == aBEMTRA[zz]
					If !Empty(STB->TB_UNIDADE)
						A550GLOG(STR0148+" "+ Alltrim(STB->TB_UNIDADE) + " "+STR0150+Alltrim(aBEMTRA[zz]), STR0147, M->TQ2_FILORI, M->TQ2_FILDES, lSAHexclus)   //"SAH - UNIDADE MED."###"TABELA NAO COMPART.,NAO SERA GRAV. UNIDAD.MED. NA FILIAL DEST. PARA COMP:"###"STB - CARACT.BEM"
						A550GLOG("","","","","")
					EndIf
					dbSkip()
				End
			EndIf
		EndIf

	Next zz

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A550TPYT  ³ Autor ³ Ricardo Dal Ponte     ³ Data ³26/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao TPY - PECAS DE REPOSICAO DO BEM                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A550TPYT()
	Local zz := 0
	Local lCOMSB1 := .F.,lCOMSAH := .F.

	If !lSB1exclus .And. !lSAHexclus .And. lTPSexclus
		Return .T.
	EndIf

	dbSelectArea("TPY")
	dbSetOrder(1)
	If dbSeek(xFilial("TPY")+M->TQ2_CODBEM)

		//VALIDACAO DO PRODUTO
		If lSB1exclus
			lCOMSB1 := .T.
			A550GLOG(STR0151, STR0152, M->TQ2_FILORI, M->TQ2_FILDES, lTPRexclus)   //"SB1 - PRODUTO - TABELA NAO COMPART.,NAO SERA GRAV. PECAS REPOSICAO NA FILIAL DEST."###"TPY - PECAS REPOS."
			A550GLOG("","","","","")
		EndIf

		//VALIDACAO DA UNIDADE DA CARACTERISTICA
		If lSAHexclus
			lCOMSAH := .T.
			A550GLOG(STR0153, STR0152, M->TQ2_FILORI, M->TQ2_FILDES, lSAHexclus)   //"SAH - UNIDADE MED. - TABELA NAO COMPART.,NAO SERA GRAV.PECAS REPOSICAO NA FILIAL DEST."###"TPY - PECAS REPOS."
			A550GLOG("","","","","")
		EndIf

	EndIf

	//Validacao da localizacao
	If !lSB1exclus  .And. !lSAHexclus .And. lTPSexclus
		dbSelectArea("TPY")
		dbSetOrder(1)
		dbSeek(xFilial("TPY")+M->TQ2_CODBEM)
		While !Eof() .And. TPY->TPY_FILIAL == xFILIAL("TPY") .And. TPY->TPY_CODBEM == M->TQ2_CODBEM
			If !Empty(TPY->TPY_LOCGAR)
				A550GLOG(STR0154+" "+ Alltrim(TPY->TPY_LOCGAR) + " "+STR0108, STR0155, M->TQ2_FILORI, M->TQ2_FILDES, lTPSexclus)   //"SA2 - COD.LOCAL GARAN."###"TABELA NAO COMPART.,CODIGO SERA GRAV. EM BRANCO NA FILIAL DEST."###"TPY - PECAS REPOS"
				A550GLOG("","","","","")
			EndIf
			dbSelectArea("TPY")
			dbSkip()
		End
	EndIf

	//Valida os componentes da Estrutura
	For zz := 1 To Len(aBEMTRA)

		If (lSB1exclus .And. lCOMSB1) .And. (lSAHexclus .And. lCOMSAH)
			Exit
		ElseIf (lSB1exclus .And. lCOMSB1) .And. !lSAHexclus
			Exit
		ElseIf (lSAHexclus .And. lCOMSAH) .And. !lSB1exclus
			Exit
		EndIf

		dbSelectArea("TPY")
		dbSetOrder(1)
		If dbSeek(xFilial("TPY")+aBEMTRA[zz])
			//VALIDACAO DO PRODUTO
			If lSB1exclus .And. !lCOMSB1
				lCOMSB1 := .T.
				A550GLOG(STR0151, STR0152, M->TQ2_FILORI, M->TQ2_FILDES, lTPRexclus)   //"SB1 - PRODUTO - TABELA NAO COMPART.,NAO SERA GRAV. PECAS REPOSICAO NA FILIAL DEST."###"TPY - PECAS REPOS."
				A550GLOG("","","","","")
			EndIf

			//VALIDACAO DA UNIDADE DA CARACTERISTICA
			If lSAHexclus .And. !lCOMSAH
				lCOMSAH := .T.
				A550GLOG(STR0153, STR0152, M->TQ2_FILORI, M->TQ2_FILDES, lSAHexclus)   //"SAH - UNIDADE MED. - TABELA NAO COMPART.,NAO SERA GRAV.PECAS REPOSICAO NA FILIAL DEST."###"TPY - PECAS REPOS."
				A550GLOG("","","","","")
			EndIf
		EndIf

		//Validacao da localizacao
		If !lSB1exclus  .And. !lSAHexclus .And. lTPSexclus
			dbSelectArea("TPY")
			dbSetOrder(1)
			dbSeek(xFilial("TPY")+aBEMTRA[zz])
			While !Eof() .And. TPY->TPY_FILIAL == xFILIAL("TPY") .And. TPY->TPY_CODBEM == aBEMTRA[zz]
				If !Empty(TPY->TPY_LOCGAR)
					A550GLOG(STR0154+" "+ Alltrim(TPY->TPY_LOCGAR) + " "+STR0108, STR0155, M->TQ2_FILORI, M->TQ2_FILDES, lTPSexclus)   //"SA2 - COD.LOCAL GARAN."###"TABELA NAO COMPART.,CODIGO SERA GRAV. EM BRANCO NA FILIAL DEST."###"TPY - PECAS REPOS"
					A550GLOG("","","","","")
				EndIf
				dbSelectArea("TPY")
				dbSkip()
			End
		EndIf

	Next zz

Return .t.

//-------------------------------------------------------------
/*/{Proteus.doc} A550TQMT
Validacao TQM - Combustíveis.
@type function

@author Alexandre Santos
@since  09/07/2019

@return Lógico, Define se o tanque poderá ser transferido.
/*/
//-------------------------------------------------------------
Function A550TQMT()

	Local lRet := .T.

	If lTQMexclus

		dbSelectArea( 'TT8' )
		dbSetOrder( 1 )
		If dbSeek( xFilial( 'TT8' ) + M->TQ2_CODBEM )

			Do While TT8->( !EoF() ) .And. xFilial( 'TT8' ) == TT8->TT8_FILIAL .And. M->TQ2_CODBEM == TT8->TT8_CODBEM

				// TQM - CÓDIGO DO COMBUSTÍVEL ### TABELA NÃO COMPARTILHADA, O TANQUE DO BEM NÃO SERÁ GRAVADO NA FILIAL DESTINO ### ST9 - BEM
				A550GLOG( STR0215 + Space( 1 ) + TT8->TT8_CODCOM + Space( 1 ) + STR0216, STR0059, M->TQ2_FILORI,;
				          M->TQ2_FILDES, lTQMexclus )
				A550GLOG( '', '', '', '', '' )

				lRet := .F.

				TT8->( dbSkip() )

			EndDo

		EndIf

	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A550CHKINC³ Autor ³ Ricardo Dal Ponte     ³ Data ³26/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verificacao se houveram inconsistencias para a transferencia³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A550CHKINC(lTESIMP)
	dbSelectArea(cAliTRBIn)
	dbGotop()

	If Reccount() > 0
		If !lTESIMP
			If MSGYESNO(STR0159 +CHR(13);  //"Encontrado inconsistencias no processo de transferencia de bens,"
			+STR0160+CHR(13)+CHR(13);  //"a tranferencia sera cancelada."
			+STR0161,STR0002)  //"Deseja Imprimir o relatorio de inconsitencias?(SIM/NAO)"###"ATENCAO"

				//Impressao do relatorio de erros
				cBEMREL:= M->TQ2_CODBEM

				If FindFunction("TRepInUse") .And. TRepInUse()
					//-- Interface de impressao
					oReport := ReportDef()
					oReport:SetLandscape()  //Default Paisagem
					oReport:PrintDialog()
				Else
					A550RIMP()
				EndIf
			EndIf
			Return .F.
		Else
			If MSGYESNO(STR0162 +CHR(13)+CHR(13);  //"Encontrado inconsistencias no processo de transferencia de bens."
			+STR0163+CHR(13); //"Deseja Imprimir o relatorio de inconsitencias antes de"
			+STR0164,STR0002)  //"confirmar a transferencia? (SIM/NAO)"###"ATENCAO"

				//Impressao do relatorio de erros
				cBEMREL:= M->TQ2_CODBEM

				If FindFunction("TRepInUse") .And. TRepInUse()
					//-- Interface de impressao
					oReport := ReportDef()
					oReport:SetLandscape()  //Default Paisagem
					oReport:PrintDialog()
				Else
					A550RIMP()
				EndIf

				If MSGYESNO(STR0165,STR0002)  //"Cofirma a transferencia? (SIM/NAO)"###"ATENCAO"
					Return .T.
				Else
					Return .F.
				EndIf
			Else
				If MSGYESNO(STR0165,STR0002)  //"Cofirma a transferencia? (SIM/NAO)"###"ATENCAO"
					Return .T.
				Else
					Return .F.
				EndIf
			EndIf
		EndIf
	EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A550GRAV  ³ Autor ³ Ricardo Dal Ponte     ³ Data ³26/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Efetiva Gravacao da transferencia                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A550GRAV()

	Local 	i
	Local 	nn
	Local 	nCONTAD1
	Local	nCONTAD2
	Local	cCENTRAB
	Local	nField		:= 0
	Local 	nREGCONT1 	:= 0
	Local 	nREGCONT2 	:= 0
	Local 	aCamposSt9	:= {}
	Local 	lRet		:= .T.
	Local   lFound      := .T.

	Private lBemAtivo := GetMv("MV_NGMNTAT") $ "1#3"

	Begin Transaction

		If lBemAtivo

			If !A550ATIVFI() //Faz a transferencia do Ativo Fixo
				DisarmTransaction()
				lRet := .F.
				Break
			Endif

		EndIf

		//Inativa os conjustos hidráulicos relacionados ao bem (TKS)
		If NGCADICBASE("TKS_BEM","A","TKS",.F.)
			fIniCjnHdr(M->TQ2_CODBEM,M->TQ2_FILORI,M->TQ2_FILDES)
		Endif

		//Grava Contador 1
		If TIPOACOM .And. M->TQ2_POSCON > 0
			NGTRETCON(M->TQ2_CODBEM,M->TQ2_DATATR,M->TQ2_POSCON,M->TQ2_HORATR,1,,.F.,"C")
		EndIf

		//Grava Contador 2
		If TIPOACOM2 .And. M->TQ2_POSCO2 > 0
			NGTRETCON(M->TQ2_CODBEM,M->TQ2_DATATR,M->TQ2_POSCO2,M->TQ2_HORATR,2,,.F.,"C")
		EndIf

		//GRVA O TABELA DE HISTORICO DE TRANSFERENCIA
		dbSelectArea("TQ2")
		RecLock("TQ2",.T.)
		TQ2->TQ2_FILIAL := Xfilial("TQ2")
		TQ2->TQ2_CODBEM := M->TQ2_CODBEM
		TQ2->TQ2_FILORI := M->TQ2_FILORI
		TQ2->TQ2_FILDES := M->TQ2_FILDES
		TQ2->TQ2_DATATR := M->TQ2_DATATR
		TQ2->TQ2_HORATR := M->TQ2_HORATR
		TQ2->TQ2_POSCON := M->TQ2_POSCON
		TQ2->TQ2_POSCO2 := M->TQ2_POSCO2
		TQ2->TQ2_MOTTRA := M->TQ2_MOTTRA
		TQ2->TQ2_CCUSTO := M->TQ2_CCUSTO
		TQ2->TQ2_CENTRA := If(lSH1exclus,Space(6),M->TQ2_CENTRA)
		dbSelectArea("TQ2")
		If FieldPos("TQ2_CTRAOR") > 0
			dbSelectArea("ST9")
			dbSetOrder(1)
			If Dbseek(xFilial("ST9",M->TQ2_FILORI)+M->TQ2_CODBEM)
				TQ2->TQ2_CTRAOR := ST9->T9_CENTRAB
				TQ2->TQ2_CCORIG := ST9->T9_CCUSTO
			EndIf
		EndIf
		MsUnLock("TQ2")

		DbselectArea("ST9")
		DbsetOrder(1)
		Dbseek(xFilial("ST9",M->TQ2_FILORI)+M->TQ2_CODBEM)

		// Apos selecionar o bem de oirgem, copia todas as informaçõe para posretiormente ser recriado na filial de destino.
		// Obs.: Foi criar uma array, pois as duas outras formas de criar (por tabela temporaria usando dbUseArea ou temporarytable)
		// tem reflexos negativos, dbUseArea não cria os campos memo na estrututa e a temporarytable gera instrução de create tables
		// e isto em Oracle não permite o controle de transação (Bengin Transaction)
		For nField := 1 To ST9->( FCount() )
			AAdd(aCamposSt9,{ FieldName(nField), ST9->&(FieldName(nField))})
		Next nField

		nREGCONT1	:= ST9->(RecNo())

		//Altera a situação e status do ST9 (origem)
		RecLock("ST9",.F.)
		ST9->T9_SITMAN := "I"
		ST9->T9_SITBEM := "T"
		If !Empty(cBEMTR)
			ST9->T9_STATUS := cBEMTR
		EndIf
		MsUnLock("ST9")

		If ExistBlock("MNTA5501")
			ExecBlock("MNTA5501",.F.,.F.,{ST9->T9_FILIAL, ST9->T9_CODBEM})
		EndIf

		DbselectArea("ST9")
		DbsetOrder(1)
		Dbseek(xFilial("ST9",M->TQ2_FILDES)+M->TQ2_CODBEM)
		lFound := !Found()
		// Inicia a inclusão\alteração do bem na filial de destino.
		Reclock("ST9", lFound)
		For nField := 1 To len(aCamposSt9)
			If FieldName(nField) == aCamposSt9[nField][1]
				If ST9->T9_RECFERR == "F"
					If !lSH4exclus
						ST9->T9_RECFERR	:= aCamposSt9[nField][2]
					Else
						ST9->T9_RECFERR := ""
					EndIf
				ElseIf ST9->T9_RECFERR == "R"
					If !lSH1exclus
						ST9->T9_RECFERR	:= aCamposSt9[nField][2]
					Else
						ST9->T9_RECFERR	:= M->T9_RECFERR := ""
					EndIf
				Else
					If lFound .Or. (!lFound .And. FieldName(nField) <> 'T9_CODIMOB') // Campo deve ser ajustado conforme 
																					 // a filial destino quando existir o registro
						ST9->&( FieldName(nField) ) := aCamposSt9[nField][2]
					EndIf
				EndIf
			EndIf
		Next nField

		// Altera os campos que tem informação particular a cópia realizada.
		ST9->T9_CORVEI  	:=	If (lM7SX5exclus,"",ST9->T9_CORVEI)
		ST9->T9_UFEMPLA  	:=	If (l12SX5exclus,"",ST9->T9_UFEMPLA)
		ST9->T9_CODIMOB		:= 	If (lSN1exclus .And. !lBemAtivo,"",ST9->T9_CODIMOB)

		ST9->T9_FILIAL  	:= 	xFilial("ST9",M->TQ2_FILDES)
		ST9->T9_CCUSTO  	:=	M->TQ2_CCUSTO
		ST9->T9_CENTRAB		:=	M->TQ2_CENTRA
		ST9->T9_POSCONT 	:= 	M->TQ2_POSCON
		ST9->T9_DTULTAC 	:= 	M->TQ2_DATATR

		ST9->T9_DTBAIXA 	:= CTOD("")
		ST9->T9_SITBEM  	:= "A"
		ST9->T9_SITMAN 		:= "A"
		ST9->T9_DTVENDA 	:= CTOD("")
		ST9->T9_COMPRAD 	:= Space(Len(ST9->T9_COMPRAD))
		ST9->T9_NFVENDA		:= Space(Len(ST9->T9_NFVENDA))

		MsUnlock()

		//Integracao com TMS
		If ST9->T9_CATBEM == "2"
			//Altera DA3_FILBAS da filial Origem
			If !lDA3exclus
				dbSelectArea("DA3")
				dbSetOrder(03)
				If dbSeek(xFilial("DA3")+ST9->T9_PLACA)
					RecLock("DA3",.F.)
					DA3->DA3_FILBAS := M->TQ2_FILDES
					MsUnLock("DA3")
				EndIf
			EndIf
			//Altera T9_CODTMS se houver TMS associado no destino
			If lDA3exclus
				dbSelectArea("DA3")
				dbSetOrder(03)
				If dbSeek(M->TQ2_FILDES+ST9->T9_PLACA)
					RecLock("ST9",.F.)
					ST9->T9_CODTMS := DA3->DA3_COD
					MsUnLock("ST9")
				EndIf
			EndIf
		EndIf

		//Contador 1
		nCONTAD1 := ST9->T9_POSCONT
		If ST9->T9_TEMCONT == "S"

			dbSelectArea("STP")
			dbSetOrder(02)
			If !dbSeek(cFilTrSTP+ST9->T9_CODBEM)
				If ST9->T9_POSCONT > 0
					A550GRVHIS(ST9->T9_CODBEM,ST9->T9_POSCONT,ST9->T9_VARDIA,;
					ST9->T9_DTULTAC,ST9->T9_CONTACU,ST9->T9_VIRADAS,;
					M->TQ2_HORATR,1,"I")
				EndIf
			Else
				If ST9->T9_POSCONT > 0
					A550GRVHIS(ST9->T9_CODBEM,ST9->T9_POSCONT,ST9->T9_VARDIA,;
					ST9->T9_DTULTAC,ST9->T9_CONTACU,ST9->T9_VIRADAS,;
					M->TQ2_HORATR,1,"C")
				EndIf
			EndIf

			//----------------------------------
			// Grava segundo contador do bem
			//----------------------------------
			dbSelectArea("TPE")
			dbSetOrder(1)
			If dbSeek( xFilial("TPE") + M->TQ2_CODBEM ) .And. TPE->TPE_SITUAC == "1"
				nREGCONT2 := Recno()
				fGravaTPE( M->TQ2_CODBEM )
			EndIf

		EndIf

		//---Movimentacao de centro de custo
		cCENTRAB := M->TQ2_CENTRA
		dbSelectArea("TPN")
		dbSetOrder(1)
		If !dbSeek(cFilTrTPN+M->TQ2_CODBEM+M->TQ2_CCUSTO+cCENTRAB+DTOS(M->TQ2_DATATR)+M->TQ2_HORATR)
			RecLock("TPN",.T.)
			TPN->TPN_FILIAL := cFilTrTPN
			TPN->TPN_CODBEM := M->TQ2_CODBEM
			TPN->TPN_DTINIC := M->TQ2_DATATR
			TPN->TPN_HRINIC := M->TQ2_HORATR
			TPN->TPN_CCUSTO := M->TQ2_CCUSTO
			TPN->TPN_CTRAB  := cCENTRAB
			TPN->TPN_UTILIZ := "U"
			TPN->TPN_POSCON := nCONTAD1
			TPN->TPN_POSCO2 := nCONTAD2
			MsUnLock("TPN")

			//Funcao de integracao com o PIMS atraves do EAI
			If SuperGetMV("MV_PIMSINT",.F.,.F.) .And. FindFunction("NGIntPIMS")
				NGIntPIMS("TPN",TPN->(RecNo()),3)
			EndIf
		EndIf

		//Cria Historico de Movimentacao da Estrutura Organizacional
		aAreaTCJ := GetArea()
		If NGCADICBASE('TCJ_CODNIV','D','TCJ',.F.)
			If NGIFDBSEEK('TAF',"X1"+ST9->T9_CODBEM,6)
				If !NGIFDBSEEK('TCJ',TAF->TAF_CODNIV+TAF->TAF_NIVSUP+"T"+DTOS(dDataBase)+Time(),1)
					RecLock("TCJ",.T.)
					TCJ->TCJ_FILIAL := xFilial("TCJ")
					TCJ->TCJ_CODNIV := TAF->TAF_CODNIV
					TCJ->TCJ_DESNIV := SubStr(TAF->TAF_NOMNIV,1,40)
					TCJ->TCJ_NIVSUP := TAF->TAF_NIVSUP
					TCJ->TCJ_TIPROC := "T"
					TCJ->TCJ_DATA   := dDatabase
					TCJ->TCJ_HORA   := Time()
					MsUnLock("TCJ")
				EndIf
			EndIf
		EndIf
		RestArea(aAreaTCJ)

		A550TCARA(M->TQ2_CODBEM) //Faz a tranferencia das caracteristicas
		A550TREPO(M->TQ2_CODBEM) //Faz a tranferencia das pecas de reposicao
		A550BANCON( M->TQ2_CODBEM, 'ST9', xFilial( 'ST9' ), cEmpAnt, cFilTrST9, cEmpAnt )//Faz a tranferencia do banco do conhecimento
		A550TANQUE(M->TQ2_CODBEM) //Faz tranferencia do tanque de combustivel
		
		If lTS3Table
		
			A550PENHOR(M->TQ2_CODBEM,xFilial("TS3")) //Faz transferencia dos registros de veiculo penhorado
		
		Endif
		
		If lTSJTable
		
			A550LEASIN(M->TQ2_CODBEM,xFilial("TSJ")) //Faz transferencia dos registros de leasing de veiculos
		
		Endif
		
		If lTQSInt .And. ( NgSeek( 'ST9', M->TQ2_CODBEM, 1, 'T9_CATBEM' ) == '3' )
		
			A550PNEUS( M->TQ2_CODBEM ) //Faz a tranferencia de pneus quando integrado com frotas
		
		EndIf

		
		A550TMANU(M->TQ2_CODBEM, xFilial("STF")) //Faz a tranferencia da manutencao
		A550TRAS(nREGCONT1,nREGCONT2)            //Faz a tranferencia dos componentes da estrutura de bens

	End Transaction

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A550X2MOD ³ Autor ³ Ricardo Dal Ponte     ³ Data ³26/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega X2_modo das tabelas                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A550X2MOD()

	dbSelectArea("SX2")
	dbSetOrder(1)

	//---------------------------------------------------------
	//Tabelas do Manutenção Padrão
	//---------------------------------------------------------
	lST0exclus := FWModeAccess("ST0",3) == "E"
	lST1exclus := FWModeAccess("ST1",3) == "E"
	lST4exclus := FWModeAccess("ST4",3) == "E"
	lST5exclus := FWModeAccess("ST5",3) == "E"
	lST6exclus := FWModeAccess("ST6",3) == "E"
	lST7exclus := FWModeAccess("ST7",3) == "E"
	lST9exclus := FWModeAccess("ST9",3) == "E"
	lSTBexclus := FWModeAccess("STB",3) == "E"
	lSTCexclus := FWModeAccess("STC",3) == "E"
	lSTFexclus := FWModeAccess("STF",3) == "E"
	lSTGexclus := FWModeAccess("STG",3) == "E"
	lSTHexclus := FWModeAccess("STH",3) == "E"
	lSTMexclus := FWModeAccess("STM",3) == "E"
	lSTPexclus := FWModeAccess("STP",3) == "E"
	lSTZexclus := FWModeAccess("STZ",3) == "E"
	lTP1exclus := FWModeAccess("TP1",3) == "E"
	lTPAexclus := FWModeAccess("TPA",3) == "E"
	lTPAexclus := FWModeAccess("TPC",3) == "E"
	lTPEexclus := FWModeAccess("TPE",3) == "E"
	lTPYexclus := FWModeAccess("TPY",3) == "E"
	lTPJexclus := FWModeAccess("TPJ",3) == "E"
	lTPNexclus := FWModeAccess("TPN",3) == "E"
	lTPPexclus := FWModeAccess("TPP",3) == "E"
	lTPRexclus := FWModeAccess("TPR",3) == "E"
	lTPSexclus := FWModeAccess("TPS",3) == "E"
	lTP2exclus := FWModeAccess("TP2",3) == "E"
	lTS3exclus := FWModeAccess("TS3",3) == "E"
	lTSJexclus := FWModeAccess("TSJ",3) == "E"

	//---------------------------------------------------------
	//Tabelas do Gestão de Frotas
	//---------------------------------------------------------
	lTQQexclus := FWModeAccess("TQQ",3) == "E"
	lTQSexclus := FWModeAccess("TQS",3) == "E"
	lTQVexclus := FWModeAccess("TQV",3) == "E"
	lTQZexclus := FWModeAccess("TQZ",3) == "E"
	lTQTexclus := FWModeAccess("TQT",3) == "E"
	lTQRexclus := FWModeAccess("TQR",3) == "E"
	lTQYexclus := FWModeAccess("TQY",3) == "E"
	lTQUexclus := FWModeAccess("TQU",3) == "E"
	lDA3exclus := FWModeAccess("DA3",3) == "E"
	lTT8exclus := FWModeAccess("TT8",3) == "E"
	lTQMexclus := FWModeAccess("TQM",3) == "E"
	lDUTexclus := FWModeAccess("DUT",3) == "E"

	l12SX5exclus := FWModeAccess("SX5",3) == "E"
	lM7SX5exclus := FWModeAccess("SX5",3) == "E"

	//---------------------------------------------------------
	//Tabelas da Microsiga
	//---------------------------------------------------------
	lAC9exclus := FWModeAccess("AC9",3) == "E"
	lACBexclus := FWModeAccess("ACB",3) == "E"
	lCTTexclus := ( FWModeAccess( 'CTT', 3 ) == 'E' .Or. FWModeAccess( 'CTT', 2 ) == 'E' .Or. FWModeAccess( 'CTT', 1 ) == 'E' )
	lSI3exclus := ( FWModeAccess( 'SI3', 3 ) == 'E' .Or. FWModeAccess( 'SI3', 2 ) == 'E' .Or. FWModeAccess( 'SI3', 1 ) == 'E' )
	lQDHexclus := FWModeAccess("QDH",3) == "E"
	lSA1exclus := FWModeAccess("SA1",3) == "E"
	lSA2exclus := FWModeAccess("SA2",3) == "E"
	lSAHexclus := FWModeAccess("SAH",3) == "E"
	lSB1exclus := FWModeAccess("SB1",3) == "E"
	lSHBexclus := ( FWModeAccess( 'SHB', 3 ) == 'E' .Or. FWModeAccess( 'SHB', 2 ) == 'E' .Or. FWModeAccess( 'SHB', 1 ) == 'E' )
	lSH1exclus := FWModeAccess("SH1",3) == "E"
	lSH4exclus := FWModeAccess("SH4",3) == "E"
	lSH7exclus := FWModeAccess("SH7",3) == "E"
	lSN1exclus := FWModeAccess("SN1",3) == "E"

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A550XFILI ³ Autor ³ Ricardo Dal Ponte     ³ Data ³26/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega Filial de Destino das tabelas                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A550XFILI()
	Private cFilOriSTF  := ""

	//FILIAL DESTINO
	//---------------Tabelas do manutencao padrao
	cFilTrST0 := IIf(lST0exclus,M->TQ2_FILDES, xFILIAL("ST0"))
	cFilTrST1 := IIf(lST1exclus,M->TQ2_FILDES, xFILIAL("ST1"))
	cFilTrST4 := IIf(lST4exclus,M->TQ2_FILDES, xFILIAL("ST4"))
	cFilTrST5 := IIf(lST5exclus,M->TQ2_FILDES, xFILIAL("ST5"))
	cFilTrST6 := IIf(lST6exclus,M->TQ2_FILDES, xFILIAL("ST6"))
	cFilTrST7 := IIf(lST7exclus,M->TQ2_FILDES, xFILIAL("ST7"))
	cFilTrST9 := IIf(lST9exclus,M->TQ2_FILDES, xFILIAL("ST9"))
	cFilTrSTB := IIf(lSTBexclus,M->TQ2_FILDES, xFILIAL("STB"))
	cFilTrSTC := IIf(lSTCexclus,M->TQ2_FILDES, xFILIAL("STC"))
	cFilTrSTF := IIf(lSTFexclus,M->TQ2_FILDES, xFILIAL("STF"))
	cFilTrSTG := IIf(lSTGexclus,M->TQ2_FILDES, xFILIAL("STG"))
	cFilTrSTH := IIf(lSTHexclus,M->TQ2_FILDES, xFILIAL("STH"))
	cFilTrSTM := IIf(lSTMexclus,M->TQ2_FILDES, xFILIAL("STM"))
	cFilTrSTP := IIf(lSTPexclus,M->TQ2_FILDES, xFILIAL("STP"))
	cFilTrSTZ := IIf(lSTZexclus,M->TQ2_FILDES, xFILIAL("STZ"))

	cFilTrTP1 := IIf(lTP1exclus,M->TQ2_FILDES, xFILIAL("TP1"))
	cFilTrTPA := IIf(lTPAexclus,M->TQ2_FILDES, xFILIAL("TPA"))
	cFilTrTPC := IIf(lTPCexclus,M->TQ2_FILDES, xFILIAL("TPC"))
	cFilTrTPE := IIf(lTPEexclus,M->TQ2_FILDES, xFILIAL("TPE"))
	cFilTrTPY := IIf(lTPYexclus,M->TQ2_FILDES, xFILIAL("TPY"))
	cFilTrTPJ := IIf(lTPJexclus,M->TQ2_FILDES, xFILIAL("TPJ"))
	cFilTrTPN := IIf(lTPNexclus,M->TQ2_FILDES, xFILIAL("TPN"))
	cFilTrTPP := IIf(lTPPexclus,M->TQ2_FILDES, xFILIAL("TPP"))
	cFilTrTPR := IIf(lTPRexclus,M->TQ2_FILDES, xFILIAL("TPR"))
	cFilTrTPS := IIf(lTPSexclus,M->TQ2_FILDES, xFILIAL("TPS"))

	//------------------------Tabelas de Gestao de Frotas

	If lTS3Table
		cFilTrTS3 := IIf(lTS3exclus,M->TQ2_FILDES, xFILIAL("TS3"))
	Endif
	If lTSJTable
		cFilTrTSJ := IIf(lTSJexclus,M->TQ2_FILDES, xFILIAL("TSJ"))
	Endif
	cFilTrTQQ := IIf(lTQQexclus,M->TQ2_FILDES, xFILIAL("TQQ"))
	cFilTrTQR := IIf(lTQRexclus,M->TQ2_FILDES, xFILIAL("TQR"))
	cFilTrTQY := IIf(lTQYexclus,M->TQ2_FILDES, xFILIAL("TQY"))

	If lTT8Tanque
		cFilTrTT8 := If(lTPYexclus,M->TQ2_FILDES, xFILIAL("TT8"))
	EndIf

	If lTMSInt //TMS
		cFilTrDA3 := IIf(lDA3exclus,M->TQ2_FILDES, xFILIAL("DA3"))
		cFilTSX5M7 := IIf(lM7SX5exclus,M->TQ2_FILDES,"  ")
		cFilTSX512 := IIf(l12SX5exclus,M->TQ2_FILDES,"  ")
		cFilTrDUT := IIf(lDUTexclus,M->TQ2_FILDES, xFILIAL("DUT"))
	EndIf

	If lTQSInt //Pneus
		cFilTrTQS := IIf(lTQSexclus,M->TQ2_FILDES, xFILIAL("TQS"))
		cFilTrTQT := IIf(lTQTexclus,M->TQ2_FILDES, xFILIAL("TQT"))
		cFilTrTQU := IIf(lTQUexclus,M->TQ2_FILDES, xFILIAL("TQU"))
		cFilTrTQV := IIf(lTQVexclus,M->TQ2_FILDES, xFILIAL("TQV"))
		cFilTrTQZ := IIf(lTQZexclus,M->TQ2_FILDES, xFILIAL("TQZ"))
	EndIf

	//----------Tabelas da Microsiga
	cFilTrAC9 := IIf(lAC9exclus,M->TQ2_FILDES, xFILIAL("AC9"))
	cFilTrACB := IIf(lACBexclus,M->TQ2_FILDES, xFILIAL("ACB"))
	cFilTrCTT := xFilial( 'CTT', M->TQ2_FILDES )
	cFilTrSI3 := xFilial( 'SI3', M->TQ2_FILDES )
	cFilTrQDH := IIf(lQDHexclus,M->TQ2_FILDES, xFILIAL("QDH"))
	cFilTrSA1 := IIf(lSA1exclus,M->TQ2_FILDES, xFILIAL("SA1"))
	cFilTrSA2 := IIf(lSA2exclus,M->TQ2_FILDES, xFILIAL("SA2"))
	cFilTrSAH := IIf(lSAHexclus,M->TQ2_FILDES, xFILIAL("SAH"))
	cFilTrSB1 := IIf(lSB1exclus,M->TQ2_FILDES, xFILIAL("SB1"))
	cFilTrSHB := xFilial( 'SHB', M->TQ2_FILDES )
	cFilTrSH1 := IIf(lSH1exclus,M->TQ2_FILDES, xFILIAL("SH1"))
	cFilTrSH4 := IIf(lSH4exclus,M->TQ2_FILDES, xFILIAL("SH4"))
	cFilTrSH7 := IIf(lSH7exclus,M->TQ2_FILDES, xFILIAL("SH7"))
	cFilTrSN1 := IIf(lSN1exclus,M->TQ2_FILDES, xFILIAL("SN1"))

Return .T.


//---------------------------------------------------------------------
/*/{Protheus.doc} A550GLOG
Funcão utilizada para realizar a gravação de inconsistências

@author Ricardo Dal Ponte
@since 26/12/2006
@param cIncons, caractere, Descrição da inconsistência
@param cOrigem, caractere, Origem da inconsistência
@param cFilOri, caractere, Filial origem da transferência
@param cFilDes, caractere, Filial destino da transferência
@param cModo,   caractere, Modo de compartilhamento da tabela
@param lPulLn,  lógica,    Indica se deve pular uma linha após a gravação da linha 
@return logico, retorna sempre true depois de gravar
/*/
//---------------------------------------------------------------------
Function A550GLOG(cINCONS, cORIGEM, cFILORI, cFILDES, cMODO, lPulLn)

	Default lPulLn := .F.

	dbSelectArea(cAliTRBIn)

	(cAliTRBIn)->( dbAppend() )

	(cAliTRBIn)->INCONS := cIncons
	(cAliTRBIn)->ORIGEM := cOrigem
	(cAliTRBIn)->FILORI := cFilOri
	(cAliTRBIn)->FILDES := cFilDes

	If Empty(cModo)
		(cAliTRBIn)->MODO := ""
	Else
		If cModo
			(cAliTRBIn)->MODO   := "E"
		Else
			(cAliTRBIn)->MODO   := "C"
		EndIf
	EndIf

	If lPulLn

		A550GLOG( '', '', '', '', '' )

	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A550RIMP  ³ Autor ³ Ricardo Dal Ponte     ³ Data ³ 29/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime os problemas encontrados na transferencia           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³A550CONOK                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A550RIMP()

	Local cString  := "SA1"
	Local cdesc1   := STR0167 //"Geracao de inconsistencias encontradas durante o processo de Checagem"
	Local cdesc2   := STR0168 //"dos registros relacionados a filial origem/destino"
	Local cdesc3   := " "
	Local wnrel    := "MNTA550"

	Private aReturn  := {STR0169,1,STR0170, 1, 2, 1, "",1 }  //"Zebrado"###"Administracao"
	Private nLastKey := 0
	Private Tamanho  := "G"
	Private nomeprog := "MNTA550"
	Private Titulo   := STR0171+" " + Alltrim(cBEMREL)  //"Inconsistencias Encontradas para a Transferencia do Bem:"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel:=SetPrint(cString,wnrel,,titulo,cDesc1,cDesc2,cDesc3,.F.,"")
	If nLastKey == 27
		Set Filter To
		Return
	EndIf
	SetDefault(aReturn,cString)
	RptStatus({|lEnd| A550RIT(@lEnd,wnRel,titulo,tamanho)},titulo)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A550RIT   ³ Autor ³ Ricardo Dal Ponte     ³ Data ³29/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Chamada do Relat¢rio                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³A550RIMP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A550RIT(lEnd,wnRel,titulo,tamanho)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cRodaTxt := ""
	nCntImpr := 0
	nAtual   := 0
	contador := 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis para controle do cursor de progressao do relatorio ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTotRegs := 0
	nMult    := 1
	nPosAnt  := 4
	nPosAtu  := 4
	nPosCnt  := 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Contadores de linha e pagina                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	li := 80
	m_pag := 1
	lEnd := .f.

	CABEC1 := STR0172 //"Tabela                           Inconsistencia                                                                                                                                             FilOri?  FilDes?  Modo Arq"
	CABEC2 := " "
	ntipo  := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se deve comprimir ou nao                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTipo  := IIF(aReturn[4]==1,15,18)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta os Cabecalhos                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	/*/
	1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         20        210     220
	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	*****************************************************************************************************************************************************************************************************************************
	xxxxx.:   xx
	xxx/xxxxxxx/xxxxx                                                      Inconsitencias Encontradas na Filial Destino                                   															 			  xxxxx: xx/xx/xx
	xxxx...: xx:xx:xx                                                                                              																													       xxxxxx: xx/xx/xx
	*****************************************************************************************************************************************************************************************************************************
	Tabela                           Inconsistencia                                                                                                                                             FilOri?  FilDes?  Modo Arq
	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX     XXXX     XXXX     XXXXXXXX
	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX     XXXX     XXXX     XXXXXXXX
	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX     XXXX     XXXX     XXXXXXXX

	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX     XXXX     XXXX     XXXXXXXX
	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX     XXXX     XXXX     XXXXXXXX
	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX     XXXX     XXXX     XXXXXXXX
	******************************************************************************************************************************************************************************************************************************
	*/

	cBEMREL  := " "
	lPRIMEI  := .T.
	dbSelectArea(cAliTRBIn)
	dbGoTop()
	SetRegua(LastRec())
	While !Eof()
		IncRegua()

		NgSomali(58)

		@li,000 Psay Substr((cAliTRBIn)->ORIGEM, 1, 30)
		@li,033 Psay Substr((cAliTRBIn)->INCONS, 1, 150)

		If (cAliTRBIn)->FILORI == "X"
			@li,188 Psay "XX"
		Else
			@li,188 Psay (cAliTRBIn)->FILORI
		EndIf

		If (cAliTRBIn)->FILDES == "X"
			@li,197 Psay "XX"
		Else
			@li,197 Psay (cAliTRBIn)->FILDES
		EndIf

		If (cAliTRBIn)->MODO = "E"
			@li,124 Psay STR0173 //"EXCLUSIV."

		ElseIf (cAliTRBIn)->MODO = "C"
			@li,125 Psay STR0174 //"COMPART."
		EndIf

		dbSelectArea(cAliTRBIn)
		dbskip()
	End

	RODA(nCNTIMPR,cRODATXT,TAMANHO)

	Set Filter To
	Set Device To Screen
	If aReturn[5] == 1
		Set Printer To
		dbCommitAll()
		OurSpool(wnrel)
	EndIf

	MS_FLUSH()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ReportDef ³ Autor ³ Ricardo Dal Ponte     ³ Data ³12/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Define as secoes impressas no relatorio                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaMDT                                                    ³±±
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
Static Function ReportDef()

	Local oReport
	Local oSection1
	Local oSection2
	Local oCell

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao do componente de impressao                                      ³
	//³                                                                        ³
	//³TReport():New                                                           ³
	//³ExpC1 : Nome do relatorio                                               ³
	//³ExpC2 : Titulo                                                          ³
	//³ExpC3 : Pergunte                                                        ³
	//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
	//³ExpC5 : Descricao                                                       ³
	//³                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oReport := TReport():New("MNTA550",OemToAnsi(STR0175),"",{|oReport| ReportPrint(oReport)},STR0176)  //"Transferência de Bens entre Filiais"###"Destina-se a imprimir as inconsistencias encontradas durante o processo de checagem dos registros relacionados a filial origem/destino"

	Pergunte(oReport:uParam,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao da secao utilizada pelo relatorio                               ³
	//³                                                                        ³
	//³TRSection():New                                                         ³
	//³ExpO1 : Objeto TReport que a secao pertence                             ³
	//³ExpC2 : Descricao da seçao                                              ³
	//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
	//³        sera considerada como principal para a seção.                   ³
	//³ExpA4 : Array com as Ordens do relatório                                ³
	//³ExpL5 : Carrega campos do SX3 como celulas                              ³
	//³        Default : False                                                 ³
	//³ExpL6 : Carrega ordens do Sindex                                        ³
	//³        Default : False                                                 ³
	//³                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao da celulas da secao do relatorio                                ³
	//³                                                                        ³
	//³TRCell():New                                                            ³
	//³ExpO1 : Objeto TSection que a secao pertence                            ³
	//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
	//³ExpC3 : Nome da tabela de referencia da celula                          ³
	//³ExpC4 : Titulo da celula                                                ³
	//³        Default : X3Titulo()                                            ³
	//³ExpC5 : Picture                                                         ³
	//³        Default : X3_PICTURE                                            ³
	//³ExpC6 : Tamanho                                                         ³
	//³        Default : X3_TAMANHO                                            ³
	//³ExpL7 : Informe se o tamanho esta em pixel                              ³
	//³        Default : False                                                 ³
	//³ExpB8 : Bloco de código para impressao.                                 ³
	//³        Default : ExpC2                                                 ³
	//³                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oSection1 := TRSection():New( oReport,, {cAliTRBIn} )

	TRCell():New(oSection1, cAliTRBIn + "->ORIGEM"	,(cAliTRBIn)	,STR0177	,"@!" ,30, /*lPixel*/,/*{|| code-block de impressao }*/) //"Tabela"
	TRCell():New(oSection1, ""							,""				,""			,"@!" ,2, /*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, cAliTRBIn + "->INCONS"	,(cAliTRBIn)	,STR0178	,"@!" ,150,/*lPixel*/,/*{|| code-block de impressao }*/)  //"Inconsistencia"
	TRCell():New(oSection1, ""							,""				,""	       ,"@!" ,2, /*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "cFILORI"         		,""				,STR0179	,"@!" ,7,,{||cFILORI})  //"FilOri?"
	TRCell():New(oSection1, ""							,""				,""	       ,"@!" ,2, /*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "cFILDES"         		,""				,STR0180	,"@!" ,7,,{||cFILDES})  //"FilDes?"
	TRCell():New(oSection1, ""							,""				,""	       ,"@!" ,2, /*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "cMODO"           		,""				,STR0181	,"@!" ,8,,{||cMODO})  //"Modo Arq"

Return oReport

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ReportPrint³ Autor ³ Ricardo Dal Ponte     ³ Data ³13/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Chamada do Relat¢rio                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaMNT                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ F.O  ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport)

	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)
	Local cCUSTO, cTRABALHO, cFAMILIA, cBEM, cIRREGU

	Private cOBS

	Processa({|lEND|},STR0182+"...")  //"Processando Arquivo"

	dbSelectArea(cAliTRBIn)
	dbGoTop()

	oReport:cTitle := STR0171+" " + Alltrim(cBEMREL)  //"Inconsistencias Encontradas para a Transferencia do Bem:"
	oReport:SetMeter( LastRec() )

	lPVEZ := .T.

	While !EoF() .And. !oReport:Cancel()
		oReport:IncMeter()

		If lPVEZ = .T.
			oSection1:Init()
			lPVEZ := .f.
		EndIf

		cFilOri := ""
		cFilDes := ""
		cModo   := ""
		cFilOri := IIf( (cAliTRBIn)->FILORI == "X", "XX", (cAliTRBIn)->FILORI )
		cFILDES := IIf( (cAliTRBIn)->FILDES == "X", "XX", (cAliTRBIn)->FILDES )

		If (cAliTRBIn)->MODO == "E"

			cModo := STR0173 //"EXCLUSIV."

		ElseIf (cAliTRBIn)->MODO == "C"

			cModo := STR0174 //"COMPART."

		EndIf

		oSection1:PrintLine()

		dbSKIP()
	End

	oSection1:Finish()
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A550CRECOM³ Autor ³ Ricardo Dal Ponte     ³ Data ³29/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Faz a validacao da causa da remocao do componente           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA550                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A550CRECOM()

	If !Empty(cCAUSAREMC)
		dbSelectArea("ST8")
		dbSetOrder(01)
		If !dbSeek(xFilial("ST8")+cCAUSAREMC+"C")
			MsgStop(STR0183,STR0022)  //"Causa de Remocao invalida."###"NAO CONFORMIDADE"
			Return .F.
		EndIf
		cNOMECAU := ST8->T8_NOME
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A550ATIVFI³ Autor ³ Ricardo Dal Ponte     ³ Data ³ 25/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Faz a transferencia do Ativo Fixo 					           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA550                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A550ATIVFI()
	Local aDadosAuto := {}		// Array com os dados a serem enviados pela MsExecAuto() para gravacao automatica
	Local aOldArea := GetArea()

	Private lMsHelpAuto := .t.	// Determina se as mensagens de help devem ser direcionadas para o arq. de log
	Private lMsErroAuto := .f.	// Determina se houve alguma inconsistencia na execucao da rotina em relacao aos
	Private cHoraTrans	:= M->TQ2_HORATR

	_nRecnoSN1 := MNT550ATFI(xFilial("SN1"))

	If _nRecnoSN1 <> 0
		dbSelectArea("SN1")
		dbGoTo(_nRecnoSN1)

		dbSelectArea("SN3")
		dbSetOrder(01)
		dbSeek(xFilial("SN3")+SN1->N1_CBASE+SN1->N1_ITEM)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ O exemplo abaixo foi considerado passando somente dados de conta contabil e centro de custo, caso ³
		//³ necessario passar os campos referentes a itens contabeis e classes de valores.                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aDadosAuto:= {	{'N3_CBASE', SN1->N1_CBASE		, Nil},;	// Codigo base do ativo //"0000000002"
		{'N3_ITEM'    , SN1->N1_ITEM 	, Nil},;	// Item sequencial do codigo bas do ativo //"0001"
		{'N4_DATA' 	  , dDATABASE		, Nil},;	// Data de aquisicao do ativo
		{'N4_HORA' 	  , M->TQ2_HORATR	, Nil},;	// Hoara da transferencia do ativo
		{'N3_CCUSTO'  , M->TQ2_CCUSTO	, Nil},;	// Centro de Custo de Despesa
		{'N3_CCONTAB' , SN3->N3_CCONTAB	, Nil},;	// Conta Contabil
		{'N3_CCORREC' , SN3->N3_CCORREC	, Nil},;	// Conta de Correcao do Bem
		{'N3_CDEPREC' , SN3->N3_CDEPREC	, Nil},;	// Conta Despesa Depreciacao
		{'N3_CCDEPR'  , SN3->N3_CCDEPR	, Nil},;	// Conta Depreciacao Acumulada
		{'N3_CDESP'   , SN3->N3_CDESP	, Nil},;	// Conta Correcao Depreciacao
		{'N3_CUSTBEM' , M->TQ2_CCUSTO	, Nil},;	// Centro de Custo da Conta do Bem
		{'N3_CCCORR'  , SN3->N3_CCCORR	, Nil},;	// Centro Custo Correcao Monetaria
		{'N3_CCDESP'  , SN3->N3_CCDESP	, Nil},;	// Centro Custo Despesa Depreciacao
		{'N3_CCCDEP'  , SN3->N3_CCCDEP	, Nil},;	// Centro Custo Despesa Acumulada
		{'N3_CCCDES'  , SN3->N3_CCCDES	, Nil},;	// Centro Custo Correcao Depreciacao
		{'N1_GRUPO'   , SN1->N1_GRUPO	, Nil},;	// Codigo do Grupo do Bem
		{'N1_LOCAL'   , SN1->N1_LOCAL	, Nil},;	// Localizacao do Bem
		{'N1_NFISCAL' , SN1->N1_NFISCAL	, Nil},;	// Numero da NF
		{'N1_NSERIE'  , SN1->N1_NSERIE 	, Nil},;	// Serie da NF
		{'N1_FILIAL'  , M->TQ2_FILDES 	, Nil}}		// Filial de Destino do Ativo
		If !lAtfExecAuto
			MSExecAuto({|x, y, z| AtfA060(x, y, z)},aDadosAuto, 4)
		EndIf

		If lMsErroAuto
			_nRecnoSN1 := MNT550ATFI(xFilial("SN1",M->TQ2_FILDES))
			If _nRecnoSN1 == 0 //Se a inconsistencia for impeditiva para transferencia, mostra a mensagem. Caso contrario, o ATF ja foi transferido
				MostraErro()
				RestArea(aOldArea)
				Return .f.
			Endif
		Endif
	Endif

	RestArea(aOldArea)

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNT550ATFI³ Autor ³ Ricardo Dal Ponte     ³ Data ³ 25/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³                               					          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA550                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNT550ATFI(_cFilSN1)
	Local aOldArea := GetArea()
	Local _nRecnoSN1 := 0
	Local cAliasQry  := GetNextAlias()

	cQuery := " SELECT R_E_C_N_O_ FROM "+RetSQLName("SN1")
	cQuery += " WHERE N1_CODBEM = '" + M->TQ2_CODBEM + "'"
	cQuery += " AND D_E_L_E_T_ = '' "
	cQuery += " AND N1_FILIAL  = '" + _cFilSN1 + "'"
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)

	dbSelectArea(cAliasQry)
	dbGoTop()
	If !Eof()
		_nRecnoSN1 := (cAliasQry)->R_E_C_N_O_
	Endif

	(cAliasQry)->(dbCloseArea())

	RestArea(aOldArea)

Return _nRecnoSN1
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fIniCjnHdr³ Autor ³ Jackson Machado       ³ Data ³ 06/12/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Deixa inativos os conjuntos hidraulicos relacionados ao bem.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA550                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fIniCjnHdr(cCodBem,cFilAnt,cFilPos)
	Local aArea     := GetArea()
	Local cFamilia  := ""
	Local cTurno    := ""
	Local cFornec   := ""
	Local cLojaFor  := ""
	Local dDataComp := ""
	Local cAnoFab   := ""
	Local cFabric   := ""
	Local cModelo   := ""
	Default cCodBem := ""

	dbSelectArea("ST9")
	dbSetOrder(1)
	If dbSeek(cFilAnt+cCodBem)
		cFamilia  := ST9->T9_CODFAMI
		cTurno    := ST9->T9_CALENDA
		cFornec   := ST9->T9_FORNECE
		cLojaFor  := ST9->T9_LOJA
		dDataComp := ST9->T9_DTCOMPR
		cAnoFab   := ST9->T9_ANOFAB
		cFabric   := ST9->T9_FABRICA
		cModelo   := ST9->T9_MODELO
	Endif

	dbSelectArea("TKS")
	dbSetOrder(6)
	If dbSeek(cFilAnt+cCodBem)
		While !Eof() .and. AllTrim(TKS->TKS_BEM) == AllTrim(cCodBem)
			RecLock("TKS",.F.)
			TKS->TKS_SITUAC := "2"
			MsUnLock("TKS")

			dbSelectArea("TLD")
			dbSetOrder(2)
			If dbSeek(xFilial("TLD")+TKS->TKS_CODCJN)
				While !Eof() .and. TLD->TLD_CODEXT == TKS->TKS_CODCJN
					If TLD->TLD_CATEGO <> "2"
						dbSkip()
						Loop
					Endif
					If !Empty(TLD->TLD_DTREAL)
						dbSkip()
						Loop
					Endif
					RecLock("TLD",.F.)
					TLD->TLD_SITUAC := "3"
					TLD->(MsUnLock())
					dbSkip()
				End
			Endif

			dbSelectArea("TKS")
			dbSkip()
		End
	Elseif dbSeek(cFilPos+cCodBem)
		While !Eof() .and. AllTrim(TKS->TKS_BEM) == AllTrim(cCodBem)
			RecLock("TKS",.F.)
			TKS->TKS_FAMCJN := If(!Empty(cFamilia) .and. AllTrim(TKS->TKS_FAMCJN) <> AllTrim(cFamilia),cFamilia,TKS->TKS_FAMCJN)
			TKS->TKS_TURCJN := If(!Empty(cTurno) .and. AllTrim(TKS->TKS_TURCJN) <> AllTrim(cTurno),cTurno,TKS->TKS_TURCJN)
			TKS->TKS_FORNEC := If(!Empty(cFornec) .and. AllTrim(TKS->TKS_FORNEC) <> AllTrim(cFornec),cFornec,TKS->TKS_FORNEC)
			TKS->TKS_LOJA   := If(!Empty(cLojaFor) .and. AllTrim(TKS->TKS_LOJA) <> AllTrim(cLojaFor),cLojaFor,TKS->TKS_LOJA)
			TKS->TKS_DTCOMP := If(!Empty(dDataComp) .and. AllTrim(TKS->TKS_DTCOMP) <> AllTrim(dDataComp),dDataComp,TKS->TKS_DTCOMP)
			TKS->TKS_ANOFAB := If(!Empty(cAnoFab) .and. AllTrim(TKS->TKS_ANOFAB) <> AllTrim(cAnoFab),cAnoFab,TKS->TKS_ANOFAB)
			TKS->TKS_FABRIC := If(!Empty(cFabric) .and. AllTrim(TKS->TKS_FABRIC) <> AllTrim(cFabric),cFabric,TKS->TKS_FABRIC)
			TKS->TKS_MODELO := If(!Empty(cModelo) .and. AllTrim(TKS->TKS_MODELO) <> AllTrim(cModelo),cModelo,TKS->TKS_MODELO)
			TKS->TKS_CCCJN  := M->TQ2_CCUSTO
			TKS->TKS_SITUAC := "1"
			MsUnLock("TKS")
			dbSelectArea("TLD")
			dbSetOrder(2)
			If dbSeek(xFilial("TLD")+TKS->TKS_CODCJN)
				While !Eof() .and. TLD->TLD_CODEXT == TKS->TKS_CODCJN
					If TLD->TLD_CATEGO <> "2"
						dbSkip()
						Loop
					Endif
					If !Empty(TLD->TLD_DTREAL)
						dbSkip()
						Loop
					Endif
					RecLock("TLD",.F.)
					TLD->TLD_SITUAC := "1"
					TLD->(MsUnLock())
					dbSkip()
				End
			Endif

			dbSelectArea("TKS")
			dbSkip()
		End
	Endif

	RestArea(aArea)
Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fTrocaFil ³ Autor ³ Jackson Machado       ³ Data ³ 21/12/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Troca a variavel cFilAnt.											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTA550                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fTrocaFil(nTip)

	If nTip == 1
		cFilAnt := cOldFil
	Elseif nTip == 2
		cFilAnt := M->TQ2_FILDES
	Endif

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} A550CTTT

Validação CTT - CENTROS DE CUSTO, se a tabela CTT estiver exclusiva,
verifica se a filial destino contém os centros de custo correspondentes ao
da filial origem.

@author Felipe Helio dos Santos
@since 13/08/13
@version MP11
@return Lógico
/*/
//---------------------------------------------------------------------
Function A550CTTT(aAutoTrans)

	Local aArea := GetArea()
	Local cCcCusto := SN3->N3_CCUSTO
	Local cCUSTBem := SN3->N3_CUSTBEM
	Local cCcOrr   := SN3->N3_CCCORR
	Local cCcDep   := SN3->N3_CCCDEP
	Local cCcDes   := SN3->N3_CCCDES

	Local lBemAtivo := GetMv("MV_NGMNTAT") $ "1#3"

	If lAtfExecAuto
		If lTAuto
			cCcCusto := aAutoTrans[5][1]
			cCUSTBem := aAutoTrans[5][2][2]
			cCcOrr   := aAutoTrans[5][2][3]
			cCcDep   := aAutoTrans[5][2][4]
			cCcDes   := aAutoTrans[5][2][5]
		Else
			cCcCusto := aAutoTrans[5][1]
			cCUSTBem := aAutoTrans[5][1]
			cCcOrr   := aAutoTrans[5][3]
			cCcDep   := aAutoTrans[5][4]
			cCcDes   := aAutoTrans[5][5]
		EndIF
	EndIf

	//verifica se o bem possui um ativo
	dbSelectArea("ST9")
	dbSetOrder(1)
	If dbSeek(M->TQ2_FILORI + M->TQ2_CODBEM)

		dbSelectArea("CTT")
		dbSetOrder(01)

		//Verifica se o centro de custo do ativo existe na filial de transferencia
		If lBemAtivo .And. !Empty(ST9->T9_CODIMOB) .And. !Empty(aAutoTrans)

			If !dbSeek( cFilTrCTT + cCcCusto )
				A550GLOG(STR0197+" "+AllTrim(cCcCusto)+" "+STR0202, STR0203, M->TQ2_FILORI, M->TQ2_FILDES, lCTTexclus)
			EndIf

			If !dbSeek( cFilTrCTT + cCUSTBem )
				A550GLOG(STR0198+" "+AllTrim(cCUSTBem)+" "+STR0202, STR0203, M->TQ2_FILORI, M->TQ2_FILDES, lCTTexclus)
			EndIf

			If !Empty( cCcOrr ) .And. !dbSeek( cFilTrCTT + cCcOrr )
				A550GLOG(STR0199+" "+AllTrim(cCcOrr)+" "+STR0202, STR0203, M->TQ2_FILORI, M->TQ2_FILDES, lCTTexclus)
			EndIf

			If !Empty( cCcDep ) .And. !dbSeek( cFilTrCTT + cCcDep )
				A550GLOG(STR0200+" "+AllTrim(cCcDep)+" "+STR0202, STR0203, M->TQ2_FILORI, M->TQ2_FILDES, lCTTexclus)
			EndIf

			If !Empty( cCcDes ) .And. !dbSeek( cFilTrCTT + cCcDes )
				A550GLOG(STR0201+" "+AllTrim(cCcDes)+" "+STR0202, STR0203, M->TQ2_FILORI, M->TQ2_FILDES, lCTTexclus)
			EndIf

		Else

			If !dbSeek( cFilTrCTT + M->TQ2_CCUSTO )
				A550GLOG(STR0197+" "+AllTrim(M->TQ2_CCUSTO)+" "+STR0202, STR0203, M->TQ2_FILORI, M->TQ2_FILDES, lCTTexclus)
			EndIf

		EndIf

	EndIf

	RestArea(aArea)

Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} A550VLDCAN
Função chamada no ATFA060, faz as consistências e apaga os registros
causados pela transferência.

@param cCodBem  - Código do bem que está relacionado ao ativo fixo (SN1->N1_CODBEM)
@param cCBase   - Código do ativo (SN1->N1_CBASE)
@param dData    - Data da movimentação (SN4->N4_DATA)
@param cHora    - Hora da movimentação (SN4->N4_HORA)
@param cFilOri  - Filial Origem da transferencia do ativo (SN4->N4_FILORIG)
@param cFilDest - Filial Destino da transfererncia do ativo (SN4->N4_FILIAL)
@param lMovim   - Indica se é cancelamento de transferencia de filial (.F.) ou cancelamento de movimentação de cc (contábil)(.T.)

@author NG Informática
@since 18/11/14
@version MP11
@return aRet: array de duas posições sendo a 1ª lógica, indicando
sucesso ou erro e a segunda posição string, contendo uma mensagem.
/*/
//--------------------------------------------------------------------
Function A550VLDCAN(cCodBem, cCBase, dData, cHora, cFilOri, cFilDest, lMovim)

	Local aRet      := {.T., ""}
	Local lContador1:= .F.
	Local lContador2:= .F.
	Local aArea     := GetArea()
	Local nX 		:= 0
	Local aSTPDel 	:= {}
	Local aRetHist 	:= {}

	Default cFilOri  := ""
	Default cFilDest := ""
	Default lMovim   := .F.

	dbSelectArea("STP")
	dbSetOrder(2)
	If dbSeek( xFilial("STP") + cCodBem)
		lContador1 := .T.
	EndIf

	dbSelectArea("TPP")
	dbSetOrder(2)
	If dbSeek( xFilial("TPP") + cCodBem)
		lContador2 := .T.
	EndIf

	//Consiste contador 1, se existir...
	If lContador1

		//Arrays utilzados na função MNTA875ADEL
		aARALTC := {'STP','stp->tp_filial','stp->tp_codbem',;
		'stp->tp_dtleitu','stp->tp_hora','stp->tp_poscont',;
		'stp->tp_acumcon','stp->tp_vardia','stp->tp_viracon','stp->tp_tipolan'}

		aARABEM := {'ST9','st9->t9_poscont','st9->t9_contacu',;
		'st9->t9_dtultac','st9->t9_vardia','st9->t9_limicon'}

		//Transferencia entre Filiais
		If !lMovim
			dbSelectArea("STP")
			dbSetOrder(9)
			If dbSeek( cCodBem + DtoS(dData) + cHora )
				While !EoF() .And. STP->TP_CODBEM == cCodBem .And. STP->TP_DTLEITU == dData .And. STP->TP_HORA == cHora

					nRECNSTP := Recno()
					lULTIMOP := .T.
					NACUMDEL := nACUMFIP := STP->TP_ACUMCON
					nCONTAFP := STP->TP_POSCONT
					nVARDIFP := STP->TP_VARDIA
					dDTACUFP := STP->TP_DTLEITU
					cHRACU   := STP->TP_HORA

					//Busca contador anterior
					aRetHist := NGACUMEHIS(cCodbem,dData,cHora,1,"A",STP->TP_FILIAL)
					If Len(aRetHist) > 0
						NACUMDEL := nACUMFIP := aRetHist[2]
						nCONTAFP := aRetHist[1]
						nVARDIFP := aRetHist[6]
						dDTACUFP := aRetHist[3]
						cHRACU   := aRetHist[4]
					EndIf
					DbGoTo(nRECNSTP)

					//Guarda o Recno do registro de deve deletar
					IF STP->TP_FILIAL == cFilOri .Or. STP->TP_FILIAL == cFilDest
						aAdd(aSTPDel,nRECNSTP)
					EndIf

					//Atualiza contador da ST9 e filhos se houver estrutura STC
					MNTA875ADEL(cCodBem,dData,cHora,1,STP->TP_FILIAL,STP->TP_FILIAL)

					//Volta para o Alias anterior
					dbSelectArea("STP")
					dbSetOrder(9)
					DbGoTo(nRECNSTP)

					STP->(dbSkip())
				EndDo

				//Deleta os STP da movimentação
				For nX := 1 to Len(aSTPDel)

					dbSelectArea("STP")
					DbGoTo(aSTPDel[nX])
					RecLock("STP", .F.)
					dbDelete()
					MsUnlock("STP")

				Next nX
			EndIf
		Else //Transferencia de Centro de Custo
			dbSelectArea("STP")
			dbSetOrder(5)
			If dbSeek( IIf(!lMovim, cFilDest, xFilial("STP")) + cCodBem + DtoS(dData) + cHora )
				dbSkip()
				If STP->TP_CODBEM <> cCodBem .Or. IIf(!lMovim, cFilDest, xFilial("STP")) <> STP->TP_FILIAL
					dbSkip(-1)

					nRECNSTP := Recno()
					lULTIMOP := .T.

					NACUMDEL := nACUMFIP := STP->TP_ACUMCON
					nCONTAFP := STP->TP_POSCONT
					nVARDIFP := STP->TP_VARDIA
					dDTACUFP := STP->TP_DTLEITU
					cHRACU   := STP->TP_HORA

					//Busca contador Anterior
					aRetHist := NGACUMEHIS(cCodbem,dData,cHora,1,"A",STP->TP_FILIAL)
					If Len(aRetHist) > 0
						NACUMDEL := nACUMFIP := aRetHist[2]
						nCONTAFP := aRetHist[1]
						nVARDIFP := aRetHist[6]
						dDTACUFP := aRetHist[3]
						cHRACU   := aRetHist[4]
					EndIf
					DbGoTo(nRECNSTP)

					RecLock("STP", .F.)
					dbDelete()
					MsUnlock("STP")

					//Atualiza contador da ST9 e filhos se houver estrutura STC
					MNTA875ADEL(cCodBem,dData,cHora,1,cFilDest,cFilDest)

				Else
					aRet[1] := .F.
					aRet[2] := "Existe um lançamento de contador 1"+;
					" posterior a esta Transferência, sendo"+;
					" assim, não é possível cancelar a mesma."
				EndIf
			EndIf
		EndIf
	EndIf

	//Consiste contador 2, se existir...
	If lContador2 .And. aRet[1]

		//Arrays utilzados na função MNTA875ADEL
		aARALTC :=  {'TPP','tpp->tpp_filial','tpp->tpp_codbem',;
		'tpp->tpp_dtleit','tpp->tpp_hora','tpp->tpp_poscon',;
		'tpp->tpp_acumco','tpp->tpp_vardia','tpp->tpp_viraco','tpp->tpp_tipola'}

		aARABEM := {'TPE','tpe->tpe_poscon','tpe->tpe_contac',;
		'tpe->tpe_dtulta','tpe->tpe_vardia','tpe->tpe_limico'}

		//Transferencia entre Filiais
		If !lMovim
			// Limpa a array aSTPDel, para buscar apenas as TPP
			aSTPDel 	:= {}
			dbSelectArea("TPP")
			dbSetOrder(9)
			If dbSeek( cCodBem + DtoS(dData) + cHora )
				While !EoF() .And. TPP->TPP_CODBEM == cCodBem .And. TPP->TPP_DTLEIT == dData .And. TPP->TPP_HORA == cHora

					nRECNSTP := Recno()
					lULTIMOP := .T.
					NACUMDEL := nACUMFIP := TPP->TPP_ACUMCO
					nCONTAFP := TPP->TPP_POSCON
					nVARDIFP := TPP->TPP_VARDIA
					dDTACUFP := TPP->TPP_DTLEIT
					cHRACU   := TPP->TPP_HORA

					//Busca contador anterior
					aRetHist := NGACUMEHIS(cCodbem,dData,cHora,2,"A",TPP->TPP_FILIAL)
					If Len(aRetHist) > 0
						NACUMDEL := nACUMFIP := aRetHist[2]
						nCONTAFP := aRetHist[1]
						nVARDIFP := aRetHist[6]
						dDTACUFP := aRetHist[3]
						cHRACU   := aRetHist[4]
					EndIf
					DbGoTo(nRECNSTP)

					//Guarda o Recno do registro de deve deletar
					If TPP->TPP_FILIAL == cFilOri .Or. TPP->TPP_FILIAL == cFilDest
						aAdd(aSTPDel,nRECNSTP)
					EndIf

					//Atualiza contador da ST9 e filhos se houver estrutura STC
					MNTA875ADEL(cCodBem,dData,cHora,2,TPP->TPP_FILIAL,TPP->TPP_FILIAL)

					//Volta para o Alias anterior
					dbSelectArea("TPP")
					dbSetOrder(9)
					DbGoTo(nRECNSTP)

					TPP->(dbSkip())
				EndDo

				//Deleta os TPP da movimentação
				For nX := 1 to Len(aSTPDel)

					dbSelectArea("TPP")
					DbGoTo(aSTPDel[nX])
					RecLock("TPP", .F.)
					dbDelete()
					MsUnlock("TPP")

				Next nX
			EndIf

		Else  //Transferencia de Centro de Custo

			dbSelectArea("TPP")
			dbSetOrder(5)
			If dbSeek( IIf(!lMovim, cFilDest, xFilial("TPP")) + cCodBem + DtoS(dData) + cHora )
				dbSkip()
				If TPP->TPP_CODBEM <> cCodBem  .Or. IIf(!lMovim, cFilDest, xFilial("TPP")) <> TPP->TPP_FILIAL
					dbSkip(-1)

					nRECNSTP := Recno()
					lULTIMOP := .T.
					NACUMDEL := nACUMFIP := TPP->TPP_ACUMCO
					nCONTAFP := TPP->TPP_POSCON
					nVARDIFP := TPP->TPP_VARDIA
					dDTACUFP := TPP->TPP_DTLEIT
					cHRACU   := TPP->TPP_HORA

					//Busca contador Anterior
					aRetHist := NGACUMEHIS(cCodbem,dData,cHora,2,"A",TPP->TPP_FILIAL)
					If Len(aRetHist) > 0
						NACUMDEL := nACUMFIP := aRetHist[2]
						nCONTAFP := aRetHist[1]
						nVARDIFP := aRetHist[6]
						dDTACUFP := aRetHist[3]
						cHRACU   := aRetHist[4]
					EndIf
					DbGoTo(nRECNSTP)

					RecLock("TPP", .F.)
					dbDelete()
					MsUnlock("TPP")

					MNTA875ADEL(cCodBem,dData,cHora,2,cFilDest,cFilDest)

				Else
					aRet[1] := .F.
					aRet[2] := "Existe um lançamento de contador 2"+;
					" posterior a esta Transferência, sendo"+;
					" assim, não é possível cancelar a mesma."
				EndIf
			EndIf
		EndIf
	EndIf

	If aRet[1]
		dbSelectArea("TPN")
		dbSetOrder(01)
		If dbSeek( IIf(!lMovim, cFilDest, xFilial("TPN")) + cCodBem + DtoS(dData) + cHora )
			dbSkip()
			If TPN->TPN_CODBEM <> cCodBem
				dbSkip(-1)
				RecLock("TPN", .F.)
				dbDelete()
				MsUnlock("TPN")
				dbSkip(-1)
				If TPN->TPN_CODBEM == cCodBem
					dbSelectArea("ST9")
					dbSetOrder(1)
					If dbSeek(xFilial("ST9")+TPN->TPN_CODBEM)
						Reclock("ST9",.F.)
						ST9->T9_CCUSTO := TPN->TPN_CCUSTO
						MsUnlock("ST9")
					EndIf
				EndIf
			Else
				aRet[1] := .F.
				aRet[2] := "Existe uma movimentação de Centro de Custo\Centro de Trabalho posterior a"+;
				" que está sendo cancelada, não é"+;
				" possível completar o cancelamento."
			EndIf
		EndIf
	EndIf

	If !lMovim .And. aRet[1]
		aRet := NgAtuSt9(cFilDest,cCodBem,cCBase,dData,cHora,cFilOri)
	EndIf

	RestArea(aArea)

Return aRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA550CCB
Carrega o valor do contador do bem se o campo estiver bloqueado

@param cCobBem: Código do bem
@param dData: Data
@param cHora: Hora
@author Wexlei Silveira
@since 06/04/2017
@version MP11
@return True
/*/
//---------------------------------------------------------------------
Static Function MNTA550CCB(cCobBem, dData, cHora)

	If FindFunction("NGBlCont") .And. !NGBlCont( cCobBem )
		M->TQ2_POSCON := NGTpCont(cCobBem, dData, cHora)
	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} NgAtuSt9
Atualização do codigo do ativo ao cancelar a transferencia
quando o bem já existiu na filial
parâmentro

NgAtuSt9(cFilDest,cCodBem,cCBase,dData,cHora,cFilOri)

@param cFilDest - Filial Destino da transfererncia do ativo (SN4->N4_FILIAL)
@param cCodBem - Código do bem que está relacionado ao ativo fixo (SN1->N1_CODBEM)
@param cCBase - Código do ativo (SN1->N1_CBASE)
@param dData -  Data da movimentação (SN4->N4_DATA)
@param cHora    - Hora da movimentação (SN4->N4_HORA)
@param cFilOri  - Filial Origem da transferencia do ativo (SN4->N4_FILORIG)

@author Hamilton Soldati
@since 29/03/2018
@version MP11
@return aRet
/*/
//---------------------------------------------------------------------
Function NgAtuSt9(cFilDest,cCodBem,cCBase,dData,cHora,cFilOri)

	Local cAliasTQ2     := GetNextAlias()
	Local cAliasSN4  	:= GetNextAlias()
	Local cQuery		:= ""
	Local aRet      	:= {.T., ""}

	// Verifica se existe uma transferencia (TQ2) com data posterior ao movimento a ser excluido.
	dbSelectArea("TQ2")
	dbSetOrder(1)
	If dbSeek( xFilial("TQ2") + cCodBem + DtoS(dData) + cHora )
		dbSkip()
		If TQ2->TQ2_CODBEM == cCodBem
			aRet[1] := .F.
			aRet[2] := STR0212 // "Existe uma Transferência posterior a que está sendo cancelada, não é possível completar o cancelamento."
		EndIf
	EndIf

	// Retorna as manutenções ao seu estado inicial, ou seja, antes da transferencia.
	If aRet[1]
		A550TMANU(cCodBem,cFilOri,cFilDest,.T.)
	EndIf

	// Retorna as penhoras ao seu estado inicial, ou seja, antes da transferencia.
	If aRet[1]
		A550PENHOR(cCodBem,cFilOri,cFilDest,.T.)
	EndIf

	// Retorna os leasing ao seu estado inicial, ou seja, antes da transferencia.
	If aRet[1]
		A550LEASIN(cCodBem,cFilOri, cFilDest, .T.)
	EndIf

	If !Empty(cCodBem) .And. aRet[1]
		DbSelectArea("ST9")
		DbSetOrder(1)
		//Posiciona no bem da filial de origem para voltar a situação anterior a transferencia.
		If dbSeek(cFilOri+cCodBem)
			Reclock("ST9",.F.)
			ST9->T9_SITMAN 	:= 'A'
			ST9->T9_SITBEM 	:= 'A'
			ST9->T9_DTBAIXA := CTOD("")
			ST9->T9_DTVENDA := CTOD("")
			ST9->T9_COMPRAD := Space(Len(ST9->T9_COMPRAD))
			ST9->T9_NFVENDA	:= Space(Len(ST9->T9_NFVENDA))
			ST9->T9_STATUS 	:= Space(TAMSX3("T9_STATUS")[1])
			MsUnlock()
		EndIf

		// Verifica se o bem transferido alguma vez já esteve na filial transferia
		// Caso sim, não deverá excluir o bem, apenas deve ser atualizado os campos para
		// voltar ao estado anterior a transferencia.
		cQuery := " SELECT COUNT(TQ2_CODBEM) AS QUANT FROM " + RetSQLName("TQ2")
		cQuery += " WHERE TQ2_FILORI = '" + cFilDest + "' "
		cQuery += " AND TQ2_CODBEM = '" + cCodBem + "' "
		cQuery += " AND TQ2_DATATR || TQ2_HORATR < '" +(DtoS(dData)+cHora)+ "' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasTQ2, .F., .T.)

		If (cAliasTQ2)->QUANT > 0

			(cAliasTQ2)->(dbCloseArea())

			//Busca o código do item anterior a transferencia.
			cQuery := "SELECT SN4.N4_ITEM FROM " +RetSqlName("SN4")+ " SN4 WHERE SN4.N4_CBASE = '" +cCodBem+ "' "
			cQuery += " AND SN4.N4_OCORR = '03' AND SN4.N4_FILIAL = '" +cFilDest+ "' "
			cQuery += " AND SN4.N4_TIPOCNT = '1' AND SN4.N4_DATA || SN4.N4_HORA < '" +(DtoS(dData)+cHora)+ "' "
			cQuery += " AND SN4.D_E_L_E_T_ <> '*'
			cQuery += " ORDER BY SN4.N4_DATA , SN4.N4_HORA DESC "
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasSN4, .F., .T.)

			If !Eof()
				cCBase += (cAliasSN4)->N4_ITEM
			EndIf

			(cAliasSN4)->(dbCloseArea())

			// Atualiza o bem na filial de destino.
			// retornando ao estado anterior a transferencia cancelada.
			DbSelectArea("ST9")
			DbSetOrder(1)
			If dbSeek(cFilDest+cCodBem)
				Reclock("ST9",.F.)
				ST9->T9_SITBEM 	:= 'T'
				ST9->T9_SITMAN 	:= 'I'
				ST9->T9_CODIMOB := cCBase
				MsUnlock()
			EndIf

			// Exclui a transferencia.
			DbSelectArea("TQ2")
			dbSetOrder(1)
			If dbSeek( xFilial("TQ2") + cCodBem + DtoS(dData) + cHora )
				RecLock("TQ2", .F.)
				dbDelete()
				MsUnlock("TQ2")
			EndIf
		Else
			// Exclui o bem pois não houve nenhuma movimentação posterior.
			DbSelectArea("ST9")
			DbSetOrder(1)
			If dbSeek(cFilDest+cCodBem)
				Reclock("ST9",.F.)
				dbDelete()
				MsUnlock()
			EndIf

			// Exclui a transferencia pois não houve nenhuma movimentação posterior.
			DbSelectArea("TQ2")
			dbSetOrder(1)
			If dbSeek( xFilial("TQ2") + cCodBem + DtoS(dData) + cHora )
				RecLock("TQ2", .F.)
				dbDelete()
				MsUnlock("TQ2")
			EndIf

			// Exclui o 2 contador TPE, pois o bem nunca esteve nesta filial apos a exclusão da transferencia
			DbSelectArea("TPE")
			dbSetOrder(1)
			If dbSeek( cFilDest + cCodBem )
				RecLock("TPE", .F.)
				dbDelete()
				MsUnlock("TPE")
			EndIf

			// Exclui as caracteristicas do bem, pois o bem nunca esteve nesta filial apos a exclusão da transferencia
			DbSelectArea("STB")
			dbSetOrder(1)
			dbSeek( cFilDest + cCodBem )
			While !Eof() .And. STB->TB_FILIAL == cFilDest .And. STB->TB_CODBEM == cCodBem
				RecLock("STB", .F.)
				dbDelete()
				MsUnlock("STB")
				dbSelectArea("STB")
				dbskip()
			End

			// Exclui os tanques do bem, pois o bem nunca esteve nesta filial apos a exclusão da transferencia
			DbSelectArea("TT8")
			dbSetOrder(1)
			dbSeek( cFilDest + cCodBem )
			While !Eof() .And. TT8->TT8_FILIAL == cFilDest .And. TT8->TT8_CODBEM == cCodBem
				RecLock("TT8", .F.)
				dbDelete()
				MsUnlock("TT8")
				dbSelectArea("TT8")
				dbskip()
			End

			// Exclui as peças de reposição do bem, pois o bem nunca esteve nesta filial apos a exclusão da transferencia
			DbSelectArea("TPY")
			dbSetOrder(1)
			dbSeek( cFilDest + cCodBem )
			While !Eof() .And. TPY->TPY_FILIAL == cFilDest .And. TPY->TPY_CODBEM == cCodBem
				RecLock("TPY", .F.)
				dbDelete()
				MsUnlock("TPY")
				dbSelectArea("TPY")
				dbskip()
			End

			// Exclui as manutenções do bem, pois o bem nunca esteve nesta filial apos a exclusão da transferencia
			DbSelectArea("STF")
			dbSetOrder(1)
			dbSeek( cFilDest + cCodBem )
			While !Eof() .And. STF->TF_FILIAL == cFilDest .And. STF->TF_CODBEM == cCodBem
				RecLock("STF", .F.)
				dbDelete()
				MsUnlock("STF")
				dbSelectArea("STF")
				dbskip()
			End

			// Exclui as tarefas da manutenções do bem, pois o bem nunca esteve nesta filial apos a exclusão da transferencia
			DbSelectArea("ST5")
			dbSetOrder(1)
			dbSeek( cFilDest + cCodBem )
			While !Eof() .And. ST5->T5_FILIAL == cFilDest .And. ST5->T5_CODBEM == cCodBem
				RecLock("ST5", .F.)
				dbDelete()
				MsUnlock("ST5")
				dbSelectArea("ST5")
				dbskip()
			End

			// Exclui as dependencias entre tarefas da manutenções do bem, pois o bem nunca esteve nesta filial apos a exclusão da transferencia
			DbSelectArea("STM")
			dbSetOrder(1)
			dbSeek( cFilDest + cCodBem )
			While !Eof() .And. STM->TM_FILIAL == cFilDest .And. STM->TM_CODBEM == cCodBem
				RecLock("STM", .F.)
				dbDelete()
				MsUnlock("STM")
				dbSelectArea("STM")
				dbskip()
			End

			// Exclui os insumos da manutenções do bem, pois o bem nunca esteve nesta filial apos a exclusão da transferencia
			DbSelectArea("STG")
			dbSetOrder(1)
			dbSeek( cFilDest + cCodBem )
			While !Eof() .And. STG->TG_FILIAL == cFilDest .And. STG->TG_CODBEM == cCodBem
				RecLock("STG", .F.)
				dbDelete()
				MsUnlock("STG")
				dbSelectArea("STG")
				dbskip()
			End

			// Exclui os etapas da manutenções do bem, pois o bem nunca esteve nesta filial apos a exclusão da transferencia
			DbSelectArea("STH")
			dbSetOrder(1)
			dbSeek( cFilDest + cCodBem )
			While !Eof() .And. STH->TH_FILIAL == cFilDest .And. STH->TH_CODBEM == cCodBem
				RecLock("STH", .F.)
				dbDelete()
				MsUnlock("STH")
				dbSelectArea("STH")
				dbskip()
			End
		EndIf
	EndIf

Return aRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fNgCrtTemp
Cria tabelas temporarias

@author Hamilton Soldati
@since 25/04/2018
@version MP12
@return
/*/
//---------------------------------------------------------------------
Function fNgCrtTemp(oTmpTblSTZ,oTmpTblSTC,oTmpTblIn, oTmpTblx)

	Local aIdxSTZ := {} // Indice da Tabela de Historico de Estrutura
	Local aIdxSTC := {} // Indice da Tabela de Estrutura
	Local aIdxIn  := {} // Indice da Tabela de Inconsistencias
	Local aIdx    := {} // Indice da Tabela de STC do NGESTRUTRB
	Local aCampos := {}
	Local aDBFX   := {}
	Local nIdx    := 0

	Local cTRBSTRU 		:= GetNextAlias()
	Local cAliTRBSTZ 	:= GetNextAlias()
	Local cAliTRBSTC 	:= GetNextAlias()
	Local cAliTRBIn		:= GetNextAlias() //Inconsistências

	//Default oTmpTblSTZ, oTmpTblSTC, oTmpTblIn, oTmpTblx

	//Cria arquivo temporario do STC
	aIdxSTC		:= {{"TC_FILIAL","TC_CODBEM","TC_COMPONE","TC_TIPOEST","TC_LOCALIZ"}}
	oTmpTblSTC  := NGFwTmpTbl(cAliTRBSTC,, aIdxSTC, 'STC')

	//Cria arquivo temporario do STZ
	aIdxSTZ		:= {{"TZ_FILIAL","TZ_CODBEM","TZ_TIPOMOV"}}
	oTmpTblSTZ  := NGFwTmpTbl(cAliTRBSTZ,, aIdxSTZ, 'STZ')

	//Arquivo de inconsistências
	aAdd(aCampos, {"INCONS", "C", 150, 0} )
	aAdd(aCampos, {"ORIGEM", "C", 030, 0} )
	aAdd(aCampos, {"FILORI", "C", 002, 0} )
	aAdd(aCampos, {"FILDES", "C", 002, 0} )
	aAdd(aCampos, {"MODO"  , "C", 001, 0} )

	aIdxIn	   := {{"INCONS"}}
	oTmpTblIn  := NGFwTmpTbl(cAliTRBIn, aCampos, aIdxIn)

	dbSelectArea("STC")

	aDBFX := DbStruct()
	aAdd(aDBFX,{"TC_TEMCPAI","C",01,0})
	aAdd(aDBFX,{"TC_TEMCCOM","C",01,0})
	aAdd(aDBFX,{"TC_CONTBE1","N",09,0})
	aAdd(aDBFX,{"TC_CONTBE2","N",09,0})

	aIdx     := {{"TC_CODBEM","TC_COMPONE"},{"TC_COMPONE","TC_CODBEM"}}
	oTmpTblx := NGFwTmpTbl(cTRBSTRU, aDBFX, aIdx)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fNgDelTemp
Deleta tabelas temporarias

@author Maicon André Pinheiro
@since 26/04/2018
@version MP12
@return
/*/
//---------------------------------------------------------------------
Function fNgDelTemp()

	If Type("oTmpTblSTZ") == "O" .And. Select(oTmpTblSTZ:ostruct:calias) > 0
		oTmpTblSTZ:Delete()
	EndIf

	If Type("oTmpTblSTC") == "O" .And. Select(oTmpTblSTC:ostruct:calias) > 0
		oTmpTblSTC:Delete()
	EndIf

	If Type("oTmpTblIn") == "O" .And. Select(oTmpTblIn:ostruct:calias) > 0
		oTmpTblIn:Delete()
	EndIf

	If Type("oTmpTblx") == "O" .And. Select(oTmpTblx:ostruct:calias) > 0
		oTmpTblx:Delete()
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fGravaTPE
Copia segundor contador do bem

@author Maria Elisandra de Paula
@since 08/04/20
@param cBemTrans, string, bem para cópia
@return
/*/
//---------------------------------------------------------------------
Static Function fGravaTPE( cBemTrans )

	Local cAliasQry  := GetNextAlias()
	Local nField     := 0
	Local lFound     := .F.

	// busca contador na filial origem
	BeginSql Alias cAliasQry
		SELECT * FROM %Table:TPE% TPE
		WHERE TPE.%NotDel%
			AND TPE.TPE_FILIAL = %xFilial:TPE%
			AND TPE.TPE_CODBEM = %exp:cBemTrans%
	EndSql

	If !Eof()

		//-----------------------------------------------------------------
		// verifica se há segundo contador para o bem na filial destino
		//-----------------------------------------------------------------
		dbSelectArea("TPE")
		dbSetOrder(1)
		lFound :=  dbSeek( xFilial("TPE", M->TQ2_FILDES) + cBemTrans )

		IIf( lFound, SetAltera(), SetInclui() )
		RegToMemory("TPE", !lFound)

		M->TPE_FILIAL := M->TQ2_FILDES
		M->TPE_CODBEM := (cAliasQry)->TPE_CODBEM
		M->TPE_TPCONT := (cAliasQry)->TPE_TPCONT
		M->TPE_POSCON := (cAliasQry)->TPE_POSCON
		M->TPE_DTULTA := StoD((cAliasQry)->TPE_DTULTA)
		M->TPE_VARDIA := (cAliasQry)->TPE_VARDIA
		M->TPE_LIMICO := (cAliasQry)->TPE_LIMICO
		M->TPE_CONTAC := (cAliasQry)->TPE_CONTAC
		M->TPE_VIRADA := (cAliasQry)->TPE_VIRADA
		M->TPE_AJUSCO := (cAliasQry)->TPE_AJUSCO
		M->TPE_CONTGA := (cAliasQry)->TPE_CONTGA
		M->TPE_SITUAC := (cAliasQry)->TPE_SITUAC

		Reclock("TPE", !lFound)
		For nField := 1 To TPE->( FCount() )
			TPE->&( FieldName(nField) ) := M->&( FieldName(nField) )
		Next nField
		MsUnlock()

		If TPE->TPE_POSCON > 0
			//-------------------------------------
			// grava histórico do segundo contador
			//-------------------------------------
			dbSelectArea("TPP")
			dbSetOrder(02)
			A550GRVHIS(TPE->TPE_CODBEM,TPE->TPE_POSCON,TPE->TPE_VARDIA,;
			TPE->TPE_DTULTA,TPE->TPE_CONTAC,TPE->TPE_VIRADA,;
			M->TQ2_HORATR,2, IIF(!dbSeek(cFilTrTPP+TPE->TPE_CODBEM),"I", "C") )

		EndIf

	EndIf

	(cAliasQry)->( dbCloseArea() )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} A550GTDD
Verifica a existência dos códigos relacionados ao bem e sua estrutura 
nas tabelas da filial de destino

@author João Ricardo Santini Zandoná
@since 25/08/2022
@return logico, indica se existe inconsistencia ou nao
/*/
//---------------------------------------------------------------------
Static Function A550GTDD()

	Local lReturn    := .T.
	Local cAliasQry  := ''
	Local aBensVld   := NGCOMPEST( M->TQ2_CODBEM, 'B', .T., .F., .F. )
	Local nCont      := 0
	Local cStrAux    := ''
	Local cSqlEmb    := ''
	Local cLayout    := FWSM0Layout()

	//Modo de compartilhamento das tabelas
	Local lST6Comp := .T.
	Local lSH7Comp := .T.
	Local lTQRComp := .T.
	Local lSA2Comp := .T.
	Local lSB1Comp := .T.
	Local lSA1Comp := .T.
	Local lDA3Comp := .T.
	Local lDUTComp := .T.
	Local lST7Comp := .T.
	Local lTQYComp := .T.
	Local lTQUComp := .T.
	Local lTQTComp := .T.
	Local lTPSComp := .T.
	Local lTPRComp := .T.
	Local lST4Comp := .T.
	
	If RAt("E", cLayout) > 0

		lST6Comp := FWModeAccess( 'ST6', 1 ) == 'C'
		lSH7Comp := FWModeAccess( 'SH7', 1 ) == 'C'
		lTQRComp := FWModeAccess( 'TQR', 1 ) == 'C'
		lSA2Comp := FWModeAccess( 'SA2', 1 ) == 'C'
		lSB1Comp := FWModeAccess( 'SB1', 1 ) == 'C'
		lSA1Comp := FWModeAccess( 'SA1', 1 ) == 'C'
		lDA3Comp := FWModeAccess( 'DA3', 1 ) == 'C'
		lDUTComp := FWModeAccess( 'DUT', 1 ) == 'C'
		lST7Comp := FWModeAccess( 'ST7', 1 ) == 'C'
		lTQYComp := FWModeAccess( 'TQY', 1 ) == 'C'
		lTQUComp := FWModeAccess( 'TQU', 1 ) == 'C'
		lTQTComp := FWModeAccess( 'TQT', 1 ) == 'C'
		lTPSComp := FWModeAccess( 'TPS', 1 ) == 'C'
		lTPRComp := FWModeAccess( 'TPR', 1 ) == 'C'
		lST4Comp := FWModeAccess( 'ST4', 1 ) == 'C'

	EndIF

	If RAt("U", cLayout) > 0

		If lST6Comp
			lST6Comp := FWModeAccess( 'ST6', 2 ) == 'C'
		EndIf
		If lSH7Comp
			lSH7Comp := FWModeAccess( 'SH7', 2 ) == 'C'
		EndIf
		If lTQRComp
			lTQRComp := FWModeAccess( 'TQR', 2 ) == 'C'
		EndIf
		If lSA2Comp
			lSA2Comp := FWModeAccess( 'SA2', 2 ) == 'C'
		EndIf
		If lSB1Comp
			lSB1Comp := FWModeAccess( 'SB1', 2 ) == 'C'
		EndIf
		If lSA1Comp
			lSA1Comp := FWModeAccess( 'SA1', 2 ) == 'C'
		EndIf
		If lDA3Comp
			lDA3Comp := FWModeAccess( 'DA3', 2 ) == 'C'
		EndIf
		If lDUTComp
			lDUTComp := FWModeAccess( 'DUT', 2 ) == 'C'
		EndIf
		If lST7Comp
			lST7Comp := FWModeAccess( 'ST7', 2 ) == 'C'
		EndIf
		If lTQYComp
			lTQYComp := FWModeAccess( 'TQY', 2 ) == 'C'
		EndIf
		If lTQUComp
			lTQUComp := FWModeAccess( 'TQU', 2 ) == 'C'
		EndIf
		If lTQTComp
			lTQTComp := FWModeAccess( 'TQT', 2 ) == 'C'
		EndIf
		If lTPSComp
			lTPSComp := FWModeAccess( 'TPS', 2 ) == 'C'
		EndIf
		If lTPRComp
			lTPRComp := FWModeAccess( 'TPR', 2 ) == 'C'
		EndIf
		If lST4Comp
			lST4Comp := FWModeAccess( 'ST4', 2 ) == 'C'
		EndIf


	EndIF

	If RAt("F", cLayout) > 0
		If lST6Comp
			lST6Comp := FWModeAccess( 'ST6', 3 ) == 'C'
		EndIf
		If lSH7Comp
			lSH7Comp := FWModeAccess( 'SH7', 3 ) == 'C'
		EndIf
		If lTQRComp
			lTQRComp := FWModeAccess( 'TQR', 3 ) == 'C'
		EndIf
		If lSA2Comp
			lSA2Comp := FWModeAccess( 'SA2', 3 ) == 'C'
		EndIf
		If lSB1Comp
			lSB1Comp := FWModeAccess( 'SB1', 3 ) == 'C'
		EndIf
		If lSA1Comp
			lSA1Comp := FWModeAccess( 'SA1', 3 ) == 'C'
		EndIf
		If lDA3Comp
			lDA3Comp := FWModeAccess( 'DA3', 3 ) == 'C'
		EndIf
		If lDUTComp
			lDUTComp := FWModeAccess( 'DUT', 3 ) == 'C'
		EndIf
		If lST7Comp
			lST7Comp := FWModeAccess( 'ST7', 3 ) == 'C'
		EndIf
		If lTQYComp
			lTQYComp := FWModeAccess( 'TQY', 3 ) == 'C'
		EndIf
		If lTQUComp
			lTQUComp := FWModeAccess( 'TQU', 3 ) == 'C'
		EndIf
		If lTQTComp
			lTQTComp := FWModeAccess( 'TQT', 3 ) == 'C'
		EndIf
		If lTPSComp
			lTPSComp := FWModeAccess( 'TPS', 3 ) == 'C'
		EndIf
		If lTPRComp
			lTPRComp := FWModeAccess( 'TPR', 3 ) == 'C'
		EndIf
		If lST4Comp
			lST4Comp := FWModeAccess( 'ST4', 3 ) == 'C'
		EndIf
	EndIf

	If Empty(aBensVld)

		cStrAux := valToSql(M->TQ2_CODBEM)

	Else

		For nCont := 1 to Len( aBensVld )

			If nCont == 1

				cStrAux := valToSql(aBensVld[nCont])

			Else

				cStrAux := cStrAux + ',' + valToSql(aBensVld[nCont])

			EndIf

		Next nCont
		
	EndIf	

	// (ST6) Verifica se a familia do bem existe na filial destino
	If !lST6Comp
		
		cSqlEmb  += "SELECT ST9.T9_CODFAMI        AS CODIGO, "
		cSqlEmb  += "Count(ST6.T6_CODFAMI)        AS CODEXIST, "
		cSqlEmb  += "'ST6'                        AS TABELA, "
		cSqlEmb  += "'ST6 - "+ FwX2Nome('ST6') + "' AS DESCRI "
		cSqlEmb  += "FROM " + RetSqlName( 'ST9' ) + " ST9 "
		cSqlEmb  += "LEFT JOIN " + RetSqlName( 'ST6' ) + " ST6 ON " 
		cSqlEmb  += "ST6.T6_FILIAL = " + ValToSql( xFilial( 'ST6', M->TQ2_FILDES ) ) + " " 
		cSqlEmb  += "AND ST6.T6_CODFAMI = ST9.T9_CODFAMI " 
		cSqlEmb  += "AND ST6.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "WHERE ST9.T9_FILIAL = " + ValToSql( xFilial( 'ST9', M->TQ2_FILORI ) ) + " AND ST9.T9_CODBEM IN (" + cStrAux  + ") "
		cSqlEmb  += "AND ST9.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "GROUP BY ST9.T9_CODFAMI "

	EndIf

	// (TQY) Verifica se o status do bem existe na filial destino
	If !lTQYComp .And. !Empty(ST9->T9_STATUS)

		If !Empty( cSqlEmb )

			cSqlEmb += " UNION ALL "
		
		EndIf

		cSqlEmb  += "SELECT ST9.T9_STATUS         AS CODIGO, "
		cSqlEmb  += "Count(TQY.TQY_STATUS)        AS CODEXIST, "
		cSqlEmb  += "'TQY' 				        AS TABELA, "
		cSqlEmb  += "'TQY - "+ FwX2Nome('TQY') + "' AS DESCRI "
		cSqlEmb  += "FROM " + RetSqlName( 'ST9' ) + " ST9 "
		cSqlEmb  += "LEFT JOIN " + RetSqlName( 'TQY' ) + " TQY " 
		cSqlEmb  += "ON TQY.TQY_FILIAL = " + ValToSql( xFilial( 'TQY', M->TQ2_FILDES ) ) + " "
		cSqlEmb  += "AND TQY.TQY_STATUS = ST9.T9_STATUS "
		cSqlEmb  += "AND TQY.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "WHERE ST9.T9_FILIAL = " + ValToSql( xFilial( 'ST9', M->TQ2_FILORI ) ) + " AND ST9.T9_CODBEM IN (" + cStrAux  + ") "
		cSqlEmb  += "AND ST9.T9_STATUS != '' "
		cSqlEmb  += "AND ST9.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "GROUP BY ST9.T9_STATUS "

	EndIf

	// (SH7) Verifica se o calendario do bem existe na filial destino 
	If !lSH7Comp

		If !Empty( cSqlEmb )

			cSqlEmb += " UNION ALL "
		
		EndIf

		cSqlEmb  += "SELECT ST9.T9_CALENDA        AS CODIGO, "
		cSqlEmb  += "Count(SH7.H7_CODIGO)         AS CODEXIST, "
		cSqlEmb  += "'SH7' 				         AS TABELA, "
		cSqlEmb  += "'SH7 - "+ FwX2Nome('SH7') + "'  AS DESCRI "
		cSqlEmb  += "FROM " + RetSqlName( 'ST9' ) + " ST9 "
		cSqlEmb  += "LEFT JOIN " + RetSqlName( 'SH7' ) + " SH7 " 
		cSqlEmb  += "ON SH7.H7_FILIAL = " + ValToSql( xFilial( 'SH7', M->TQ2_FILDES ) ) + " "
		cSqlEmb  += "AND SH7.H7_CODIGO = ST9.T9_CALENDA "
		cSqlEmb  += "AND SH7.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "WHERE ST9.T9_FILIAL = " + ValToSql( xFilial( 'ST9', M->TQ2_FILORI ) ) + " AND ST9.T9_CODBEM IN (" + cStrAux + ") "
		cSqlEmb  += "AND ST9.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "GROUP BY ST9.T9_CALENDA "

	EndIf

	// (ST7) Verifica se o fabricante do bem existe na filial destino 
	If !lST7Comp .And. !Empty(ST9->T9_FABRICA)

		If !Empty( cSqlEmb )

			cSqlEmb += " UNION ALL "
		
		EndIf

		cSqlEmb  += "SELECT ST9.T9_FABRICA        AS CODIGO, "
		cSqlEmb  += "Count(ST7.T7_FABRICA)         AS CODEXIST, "
		cSqlEmb  += "'ST7' 				         AS TABELA, "
		cSqlEmb  += "'ST7 - "+ FwX2Nome('ST7') + "'  AS DESCRI "
		cSqlEmb  += "FROM " + RetSqlName( 'ST9' ) + " ST9 "
		cSqlEmb  += "LEFT JOIN " + RetSqlName( 'ST7' ) + " ST7 " 
		cSqlEmb  += "ON ST7.T7_FILIAL = " + ValToSql( FWxFilial( 'ST7', M->TQ2_FILDES ) ) + " "
		cSqlEmb  += "AND ST7.T7_FABRICA = ST9.T9_FABRICA "
		cSqlEmb  += "AND ST7.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "WHERE ST9.T9_FILIAL = " + ValToSql( FWxFilial( 'ST9', M->TQ2_FILORI ) ) + " AND ST9.T9_CODBEM IN (" + cStrAux + ") "
		cSqlEmb  += "AND ST9.T9_FABRICA <> '' "
		cSqlEmb  += "AND ST9.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "GROUP BY ST9.T9_FABRICA "

	EndIf

	// (TQR) Verifica se o tipo modelo do bem existe na filial destino 
	If !lTQRComp .And. !Empty(ST9->T9_TIPMOD)

		If !Empty( cSqlEmb )

			cSqlEmb += " UNION ALL "
		
		EndIf

		cSqlEmb  += "SELECT ST9.T9_TIPMOD        AS CODIGO, "
		cSqlEmb  += "Count(TQR.TQR_TIPMOD)         AS CODEXIST, "
		cSqlEmb  += "'TQR' 				         AS TABELA, "
		cSqlEmb  += "'TQR - "+ FwX2Nome('TQR') + "'  AS DESCRI "
		cSqlEmb  += "FROM " + RetSqlName( 'ST9' ) + " ST9 "
		cSqlEmb  += "LEFT JOIN " + RetSqlName( 'TQR' ) + " TQR " 
		cSqlEmb  += "ON TQR.TQR_FILIAL = " + ValToSql( FWxFilial( 'TQR', M->TQ2_FILDES ) ) + " "
		cSqlEmb  += "AND TQR.TQR_TIPMOD = ST9.T9_TIPMOD "
		cSqlEmb  += "AND TQR.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "WHERE ST9.T9_FILIAL = " + ValToSql( FWxFilial( 'ST9', M->TQ2_FILORI ) ) + " AND ST9.T9_CODBEM IN (" + cStrAux + ") "
		cSqlEmb  += "AND ST9.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "GROUP BY ST9.T9_TIPMOD "

	EndIf


	// (SA2) Verifica se o fornecedor do bem existe na filial destino 
	If !lSA2Comp .And. !Empty(ST9->T9_FORNECE)

		If !Empty( cSqlEmb )

			cSqlEmb += " UNION ALL "
		
		EndIf

		cSqlEmb  += "SELECT ST9.T9_FORNECE        AS CODIGO, "
		cSqlEmb  += "Count(SA2.A2_COD)         AS CODEXIST, "
		cSqlEmb  += "'SA2' 				         AS TABELA, "
		cSqlEmb  += "'SA2 - "+ FwX2Nome('SA2') + "'  AS DESCRI "
		cSqlEmb  += "FROM " + RetSqlName( 'ST9' ) + " ST9 "
		cSqlEmb  += "LEFT JOIN " + RetSqlName( 'SA2' ) + " SA2 " 
		cSqlEmb  += "ON SA2.A2_FILIAL = " + ValToSql( FWxFilial( 'SA2', M->TQ2_FILDES ) ) + " "
		cSqlEmb  += "AND SA2.A2_COD = ST9.T9_FORNECE "
		cSqlEmb  += "AND SA2.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "WHERE ST9.T9_FILIAL = " + ValToSql( FWxFilial( 'ST9', M->TQ2_FILORI ) ) + " AND ST9.T9_CODBEM IN (" + cStrAux + ") "
		cSqlEmb  += "AND ST9.T9_FORNECE <> '' "
		cSqlEmb  += "AND ST9.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "GROUP BY ST9.T9_FORNECE "

	EndIf

	// (SB1) Verifica se a descricao do bem existe na filial destino 
	If !lSB1Comp .And. !Empty(ST9->T9_CODESTO)

		If !Empty( cSqlEmb )

			cSqlEmb += " UNION ALL "
		
		EndIf

		cSqlEmb  += "SELECT ST9.T9_CODESTO        AS CODIGO, "
		cSqlEmb  += "Count(SB1.B1_COD)         AS CODEXIST, "
		cSqlEmb  += "'SB1' 				         AS TABELA, "
		cSqlEmb  += "'SB1 - "+ FwX2Nome('SB1') + "'  AS DESCRI "
		cSqlEmb  += "FROM " + RetSqlName( 'ST9' ) + " ST9 "
		cSqlEmb  += "LEFT JOIN " + RetSqlName( 'SB1' ) + " SB1 " 
		cSqlEmb  += "ON SB1.B1_FILIAL = " + ValToSql( FWxFilial( 'SB1', M->TQ2_FILDES ) ) + " "
		cSqlEmb  += "AND SB1.B1_COD = ST9.T9_CODESTO "
		cSqlEmb  += "AND SB1.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "WHERE ST9.T9_FILIAL = " + ValToSql( FWxFilial( 'ST9', M->TQ2_FILORI ) ) + " AND ST9.T9_CODBEM IN (" + cStrAux + ") "
		cSqlEmb  += "AND ST9.T9_CODESTO <> '' "
		cSqlEmb  += "AND ST9.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "GROUP BY ST9.T9_CODESTO "

	EndIf

	// (SA1) Verifica se o cliente do bem existe na filial destino 
	If !lSA1Comp .And. !Empty(ST9->T9_CLIENTE)

		If !Empty( cSqlEmb )

			cSqlEmb += " UNION ALL "
		
		EndIf

		cSqlEmb  += "SELECT ST9.T9_CLIENTE        AS CODIGO, "
		cSqlEmb  += "Count(SA1.A1_COD)         AS CODEXIST, "
		cSqlEmb  += "'SA1' 				         AS TABELA, "
		cSqlEmb  += "'SA1 - "+ FwX2Nome('SA1') + "'  AS DESCRI "
		cSqlEmb  += "FROM " + RetSqlName( 'ST9' ) + " ST9 "
		cSqlEmb  += "LEFT JOIN " + RetSqlName( 'SA1' ) + " SA1 " 
		cSqlEmb  += "ON SA1.A1_FILIAL = " + ValToSql( FWxFilial( 'SA1', M->TQ2_FILDES ) ) + " "
		cSqlEmb  += "AND SA1.A1_COD = ST9.T9_CLIENTE "
		cSqlEmb  += "AND SA1.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "WHERE ST9.T9_FILIAL = " + ValToSql( FWxFilial( 'ST9', M->TQ2_FILORI ) ) + " AND ST9.T9_CODBEM IN (" + cStrAux + ") "
		cSqlEmb  += "AND ST9.T9_CLIENTE <> '' "
		cSqlEmb  += "AND ST9.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "GROUP BY ST9.T9_CLIENTE "

	EndIf

	// (DA3) Verifica se o veiculo vinculado ao bem existe na filial destino 
	If !lDA3Comp .And. !Empty(ST9->T9_CODTMS)

		If !Empty( cSqlEmb )

			cSqlEmb += " UNION ALL "
		
		EndIf

		cSqlEmb  += "SELECT ST9.T9_CODTMS        AS CODIGO, "
		cSqlEmb  += "Count(DA3.DA3_COD)         AS CODEXIST, "
		cSqlEmb  += "'DA3' 				         AS TABELA, "
		cSqlEmb  += "'DA3 - "+ FwX2Nome('DA3') + "'  AS DESCRI "
		cSqlEmb  += "FROM " + RetSqlName( 'ST9' ) + " ST9 "
		cSqlEmb  += "LEFT JOIN " + RetSqlName( 'DA3' ) + " DA3 " 
		cSqlEmb  += "ON DA3.DA3_FILIAL = " + ValToSql( FWxFilial( 'DA3', M->TQ2_FILDES ) ) + " "
		cSqlEmb  += "AND DA3.DA3_COD = ST9.T9_CODTMS "
		cSqlEmb  += "AND DA3.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "WHERE ST9.T9_FILIAL = " + ValToSql( FWxFilial( 'ST9', M->TQ2_FILORI ) ) + " AND ST9.T9_CODBEM IN (" + cStrAux + ") "
		cSqlEmb  += "AND ST9.T9_CODTMS <> '' "
		cSqlEmb  += "AND ST9.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "GROUP BY ST9.T9_CODTMS "

	EndIf

	// (DUT) Verifica se o tipo do veiculo vinculado ao bem existe na filial destino 
	If !lDUTComp .And. !Empty(ST9->T9_TIPVEI)

		If !Empty( cSqlEmb )

			cSqlEmb += " UNION ALL "
		
		EndIf

		cSqlEmb  += "SELECT ST9.T9_TIPVEI        AS CODIGO, "
		cSqlEmb  += "Count(DUT.DUT_TIPVEI)         AS CODEXIST, "
		cSqlEmb  += "'DUT' 				         AS TABELA, "
		cSqlEmb  += "'DUT - "+ FwX2Nome('DUT') + "'  AS DESCRI "
		cSqlEmb  += "FROM " + RetSqlName( 'ST9' ) + " ST9 "
		cSqlEmb  += "LEFT JOIN " + RetSqlName( 'DUT' ) + " DUT " 
		cSqlEmb  += "ON DUT.DUT_FILIAL = " + ValToSql( FWxFilial( 'DUT', M->TQ2_FILDES ) ) + " "
		cSqlEmb  += "AND DUT.DUT_TIPVEI = ST9.T9_TIPVEI "
		cSqlEmb  += "AND DUT.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "WHERE ST9.T9_FILIAL = " + ValToSql( FWxFilial( 'ST9', M->TQ2_FILORI ) ) + " AND ST9.T9_CODBEM IN (" + cStrAux + ") "
		cSqlEmb  += "AND ST9.T9_TIPVEI <> '' "
		cSqlEmb  += "AND ST9.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "GROUP BY ST9.T9_TIPVEI "

	EndIf

	// (TPS) Verifica se a localizacao do pneu do bem existe na filial destino
	If !lTPSComp

		If !Empty( cSqlEmb )

			cSqlEmb += " UNION ALL "
		
		EndIf

		cSqlEmb  += "SELECT TQS.TQS_POSIC        AS CODIGO, "
		cSqlEmb  += "Count(TPS.TPS_CODLOC)        AS CODEXIST, "
		cSqlEmb  += "'TPS' 				         AS TABELA, "
		cSqlEmb  += "'TPS - "+ FwX2Nome('TPS') + "'  AS DESCRI "
		cSqlEmb  += "FROM " + RetSqlName( 'ST9' ) + " ST9 "
		cSqlEmb  += "INNER JOIN " + RetSqlName( 'TQS' ) + " TQS "
		cSqlEmb  += "ON TQS.TQS_FILIAL = " + ValToSql( FWxFilial( 'TQS', M->TQ2_FILORI ) ) + " "
		cSqlEmb  += "AND TQS.TQS_CODBEM = ST9.T9_CODBEM "
		cSqlEmb  += "AND TQS.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "LEFT JOIN " + RetSqlName( 'TPS' ) + " TPS " 
		cSqlEmb  += "ON TPS.TPS_FILIAL = " + ValToSql( FWxFilial( 'TPS', M->TQ2_FILDES ) ) + " "
		cSqlEmb  += "AND TPS.TPS_CODLOC = TQS.TQS_POSIC "
		cSqlEmb  += "AND TPS.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "WHERE ST9.T9_FILIAL = " + ValToSql( FWxFilial( 'ST9', M->TQ2_FILORI ) ) + " AND ST9.T9_CODBEM IN (" + cStrAux + ") "
		cSqlEmb  += "AND ST9.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "GROUP  BY TQS_POSIC "

	EndIf

	//Verifica se o desenho do pneu existe na filial destino
	If !lTQUComp

		If !Empty( cSqlEmb )

			cSqlEmb += " UNION ALL "
		
		EndIf

		cSqlEmb  += "SELECT TQS.TQS_DESENH        AS CODIGO, "
		cSqlEmb  += "Count(TQU.TQU_DESENH)        AS CODEXIST, "
		cSqlEmb  += "'TQU' 				         AS TABELA, "
		cSqlEmb  += "'TQU - "+ FwX2Nome('TQU') + "' AS DESCRI "
		cSqlEmb  += "FROM " + RetSqlName( 'ST9' ) + " ST9 "
		cSqlEmb  += "INNER JOIN " + RetSqlName( 'TQS' ) + " TQS "
		cSqlEmb  += "ON TQS.TQS_FILIAL = " + ValToSql( FWxFilial( 'TQS', M->TQ2_FILORI ) ) + " "
		cSqlEmb  += "AND TQS.TQS_CODBEM = ST9.T9_CODBEM "
		cSqlEmb  += "AND TQS.TQS_BANDAA > '1' "
		cSqlEmb  += "AND TQS.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "LEFT JOIN " + RetSqlName( 'TQU' ) + " TQU " 
		cSqlEmb  += "ON TQU.TQU_FILIAL = " + ValToSql( FWxFilial( 'TQU', M->TQ2_FILDES ) ) + " "
		cSqlEmb  += "AND TQU.TQU_DESENH = TQS.TQS_DESENH "
		cSqlEmb  += "AND TQU.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "WHERE ST9.T9_FILIAL = "+ ValToSql( FWxFilial( 'ST9', M->TQ2_FILORI ) ) + " AND ST9.T9_CODBEM IN (" + cStrAux + ") "
		cSqlEmb  += "AND ST9.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "GROUP  BY TQS_DESENH "

	EndIf

	// Verifica se a medida do pneu existe na filial destino
	If !lTQTComp

		If !Empty( cSqlEmb )

			cSqlEmb += " UNION ALL "
		
		EndIf

		cSqlEmb  += "SELECT TQS.TQS_MEDIDA        AS CODIGO, "
		cSqlEmb  += "Count(TQT.TQT_MEDIDA)        AS CODEXIST, "
		cSqlEmb  += "'TQT' 				         AS TABELA, "
		cSqlEmb  += "'TQT - "+ FwX2Nome('TQT') + "'  AS DESCRI "
		cSqlEmb  += "FROM " + RetSqlName( 'ST9' ) + " ST9 "
		cSqlEmb  += "INNER JOIN " + RetSqlName( 'TQS' ) + " TQS "
		cSqlEmb  += "ON TQS.TQS_FILIAL = " + ValToSql( FWxFilial( 'TQS', M->TQ2_FILORI ) ) + " "
		cSqlEmb  += "AND TQS.TQS_CODBEM = ST9.T9_CODBEM "
		cSqlEmb  += "AND TQS.TQS_BANDAA > '1' "
		cSqlEmb  += "AND TQS.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "LEFT JOIN " + RetSqlName( 'TQT' ) + " TQT " 
		cSqlEmb  += "ON TQT.TQT_FILIAL = " + ValToSql( FWxFilial( 'TQT', M->TQ2_FILDES ) ) + " "
		cSqlEmb  += "AND TQT.TQT_MEDIDA = TQS.TQS_MEDIDA "
		cSqlEmb  += "AND TQT.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "WHERE ST9.T9_FILIAL = " + ValToSql( FWxFilial( 'ST9', M->TQ2_FILORI ) ) + " AND ST9.T9_CODBEM IN (" + cStrAux + ") "
		cSqlEmb  += "AND ST9.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "GROUP  BY TQS_MEDIDA "

	EndIf

	// Verifica se as caracteristicas do bem existem na filial destino
	If !lTPRComp

		If !Empty( cSqlEmb )

			cSqlEmb += " UNION ALL "
		
		EndIf

		cSqlEmb  += "SELECT STB.TB_CARACTE         AS CODIGO, "
		cSqlEmb  += "Count(TPR.TPR_CODCAR)        AS CODEXIST, "
		cSqlEmb  += "'TPR' 				        AS TABELA, "
		cSqlEmb  += "'TPR - "+ FwX2Nome('TPR') + "' AS DESCRI "
		cSqlEmb  += "FROM " + RetSqlName( 'ST9' ) + " ST9 "
		cSqlEmb  += "INNER JOIN " + RetSqlName( 'STB' ) + " STB " 
		cSqlEmb  += "ON STB.TB_FILIAL = " + ValToSql( FWxFilial( 'STB', M->TQ2_FILORI ) ) + " "
		cSqlEmb  += "AND STB.TB_CODBEM = ST9.T9_CODBEM "
		cSqlEmb  += "AND STB.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "LEFT JOIN " + RetSqlName( 'TPR' ) + " TPR " 
		cSqlEmb  += "ON TPR.TPR_FILIAL = " + ValToSql( FWxFilial( 'TPR', M->TQ2_FILDES ) ) + " "
		cSqlEmb  += "AND TPR.TPR_CODCAR = STB.TB_CARACTE "
		cSqlEmb  += "AND TPR.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "WHERE ST9.T9_FILIAL = " + ValToSql( FWxFilial( 'ST9', M->TQ2_FILORI ) ) + " AND ST9.T9_CODBEM IN (" + cStrAux  + ") "
		cSqlEmb  += "AND ST9.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "GROUP BY STB.TB_CARACTE "

	EndIf

	// Verifica se os serviços usados no bem existem na filial destino
	If !lST4Comp

		If !Empty( cSqlEmb )

			cSqlEmb += " UNION ALL "
		
		EndIf

		cSqlEmb  += "SELECT STF.TF_SERVICO        AS CODIGO, "
		cSqlEmb  += "Count(ST4.T4_SERVICO)        AS CODEXIST, "
		cSqlEmb  += "'ST4' 				         AS TABELA, "
		cSqlEmb  += "'ST4 - "+ FwX2Nome('ST4') + "'  AS DESCRI "
		cSqlEmb  += "FROM " + RetSqlName( 'ST9' ) + " ST9 "
		cSqlEmb  += "INNER JOIN " + RetSqlName( 'STF' ) + " STF "
		cSqlEmb  += "ON STF.TF_FILIAL = " + ValToSql( FWxFilial( 'STF', M->TQ2_FILORI ) ) + " "
		cSqlEmb  += "AND STF.TF_CODBEM = ST9.T9_CODBEM "
		cSqlEmb  += "AND STF.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "LEFT JOIN " + RetSqlName( 'ST4' ) + " ST4 " 
		cSqlEmb  += "ON ST4.T4_FILIAL = " + ValToSql( FWxFilial( 'ST4', M->TQ2_FILDES ) ) + " "
		cSqlEmb  += "AND ST4.T4_SERVICO = STF.TF_SERVICO "
		cSqlEmb  += "AND ST4.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "WHERE ST9.T9_FILIAL = " + ValToSql( FWxFilial( 'ST9', M->TQ2_FILORI ) ) + " AND ST9.T9_CODBEM IN (" + cStrAux + ") "
		cSqlEmb  += "AND ST9.D_E_L_E_T_ = ' ' "
		cSqlEmb  += "GROUP  BY TF_SERVICO "

	EndIf

	// SH4 - SH1
	If !Empty(ST9->T9_RECFERR)
		
		// (SH4) Verifica se a ferramenta do bem existe na filial destino
		If ST9->T9_FERRAME == "F" //Ferramenta

			If lSH4exclus

				If !Empty( cSqlEmb )

					cSqlEmb += " UNION ALL "
				
				EndIf

				cSqlEmb  += "SELECT ST9.T9_RECFERR        AS CODIGO, "
				cSqlEmb  += "Count(SH4.H4_CODIGO)         AS CODEXIST, "
				cSqlEmb  += "'SH4' 				         AS TABELA, "
				cSqlEmb  += "'SH4 - "+ FwX2Nome('SH4') + "'  AS DESCRI "
				cSqlEmb  += "FROM " + RetSqlName( 'ST9' ) + " ST9 "
				cSqlEmb  += "LEFT JOIN " + RetSqlName( 'SH4' ) + " SH4 " 
				cSqlEmb  += "ON SH4.H4_FILIAL = " + ValToSql( FWxFilial( 'SH4', M->TQ2_FILDES ) ) + " "
				cSqlEmb  += "AND SH4.H4_CODIGO = ST9.T9_RECFERR "
				cSqlEmb  += "AND SH4.D_E_L_E_T_ = ' ' "
				cSqlEmb  += "WHERE ST9.T9_FILIAL = " + ValToSql( FWxFilial( 'ST9', M->TQ2_FILORI ) ) + " AND ST9.T9_CODBEM IN (" + cStrAux + ") "
				cSqlEmb  += "AND ST9.T9_RECFERR <> '' "
				cSqlEmb  += "AND ST9.D_E_L_E_T_ = ' ' "
				cSqlEmb  += "GROUP BY ST9.T9_RECFERR "

			EndIf
		
		Else                      //Recurso
		
			// (SH1) Verifica se o recurso do bem existe na filial destino
			If lSH1exclus

				If !Empty( cSqlEmb )

					cSqlEmb += " UNION ALL "
				
				EndIf

				cSqlEmb  += "SELECT ST9.T9_RECFERR        AS CODIGO, "
				cSqlEmb  += "Count(SH1.H1_CODIGO)         AS CODEXIST, "
				cSqlEmb  += "'SH1' 				         AS TABELA, "
				cSqlEmb  += "'SH1 - "+ FwX2Nome('SH1') + "'  AS DESCRI "
				cSqlEmb  += "FROM " + RetSqlName( 'ST9' ) + " ST9 "
				cSqlEmb  += "LEFT JOIN " + RetSqlName( 'SH1' ) + " SH1 " 
				cSqlEmb  += "ON SH1.H1_FILIAL = " + ValToSql( FWxFilial( 'SH1', M->TQ2_FILDES ) ) + " "
				cSqlEmb  += "AND SH1.H1_CODIGO = ST9.T9_RECFERR "
				cSqlEmb  += "AND SH1.D_E_L_E_T_ = ' ' "
				cSqlEmb  += "WHERE ST9.T9_FILIAL = " + ValToSql( FWxFilial( 'ST9', M->TQ2_FILORI ) ) + " AND ST9.T9_CODBEM IN (" + cStrAux + ") "
				cSqlEmb  += "AND ST9.T9_RECFERR <> '' "
				cSqlEmb  += "AND ST9.D_E_L_E_T_ = ' ' "
				cSqlEmb  += "GROUP BY ST9.T9_RECFERR "

			EndIf
		
		EndIf
	
	EndIf

	cSqlEmb := "%"+cSqlEmb+"%"

	If cSqlEmb != '%%'
	
		cAliasQry  := GetNextAlias()

		BeginSql Alias cAliasQry
			
			SELECT A.CODIGO,
				A.TABELA,
				A.CODEXIST,
				A.DESCRI
				FROM (
					%exp:cSqlEmb%
				) A WHERE A.CODEXIST = 0

		EndSql

		While (cAliasQry)->(!EoF())

			lReturn := .F.

			A550GLOG( STR0233 + allTrim( (cAliasQry)->CODIGO) + STR0234 + allTrim((cAliasQry)->TABELA ) + STR0235, allTrim((cAliasQry)->DESCRI ), '', , , .T. ) // "Não foi encontrando o registro chave "###" na tabela "###" na filial destino. Inclua o registro chave, ou compartilhe a tabela."

			(cAliasQry)->(DbSkip())

		Enddo
		
		(cAliasQry)->(DbCloseArea())

	EndIf

Return lReturn
