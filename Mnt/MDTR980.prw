#Include "Protheus.ch"
#Include "MDTR980.ch"

#Define _nVersao 2

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR980
Relatório de permissões médicas.

@Obs Chamadas: MDTA992

@author Marcos Wagner Jr. refeito por André Felipe Joriatti
@since 22/05/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------

Function MDTR980

	Local oRadOp,oDLGppra,i
	Local aNGBEGINPRM  := NGBEGINPRM( _nVersao )
	Local cString      := "TI0"
	Local cSpaceSX1		:= ""

	Private lMdtUnix      := If( GetRemoteType() == 2 .Or. isSRVunix() , .T. , .F. ) // Verifica se servidor ou estacao é Linux
	Private titulo        := STR0001 // "Permissão de Trabalho"
	Private cPerg         := "MDTR980"
	Private cDesc1        := STR0002 // "Relatório para imprimir informações relacionadas as Permissões de Trabalho"
	Private cDesc2        := ""
	Private cDesc3        := ""
	Private tamanho       := "G"
	Private wnrel         := "MDTR980"
	Private aReturn       := { STR0070 , 1 , STR0090 , 2 , 2 , 1 , "" , 1 } //"Zebrado"//"Administracao"

	Private cCodMDT992

	If !NGCADICBASE( "TI0_PERMIS", "A", "TI0", .F. )
		NGINCOMPDIC( ,"TRXQOC" )
	Else
		lRet  := .F.

		//--------------------------------------
		// Variáveis utilizadas para parametros
		// MV_PAR01 // Permissão de Trabalho
		// MV_PAR02 // Sequencia da Permissão de Trabalho
		// MV_PAR03 // Termo de Respons.
		// MV_PAR04 // Tipo de Impressão
		// MV_PAR05 // Em branco
		// MV_PAR06 // Quantidade de vias
		// MV_PAR07 // Formato de Impressão
		//--------------------------------------

		Pergunte( cPerg,.F. )

		//---------------------------------------
		// Envia controle para a funcao SETPRINT
		//---------------------------------------
		wnrel := SetPrint( cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"" )

		If nLastKey = 27
			Set Filter To
			Return Nil
		Endif

		SetDefault( aReturn,cString )
		RptStatus( { | | R980Imp() } , titulo )
	EndIf

	NGRETURNPRM( aNGBEGINPRM )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} CRSX1980
Validação das perguntas do relatório.

@param Integer nMvPar: indica qual numero do parametro para se validar
@author André Felipe Joriatti
@since 22/05/2013
@version MP11
@return Boolean lRet: conforme validação.
/*/
//---------------------------------------------------------------------

Function CRSX1980( nMvPar )

	Local lRet := .T.

	If ( nMvPar == 1 .or. nMvPar == 2 ) .And. IsInCallStack( "MDTA992" )
		If  Type("cCodMDT992") <> "U" .And. MV_PAR01 + MV_PAR02 <> cCodMDT992
			MsgStop( STR0098 , STR0097 ) //"Código e Sequência da Permissão de Trabalho não poderá ser alterada."//"Atenção"
			lRet := .F.
		EndIf
	EndIf

	If lRet
		If nMvPar == 1 // Permissão de Trabalho
			lRet := If( !Empty( MV_PAR01 ), ExistCpo( "TI0",MV_PAR01 ), .T. )
		ElseIf nMvPar == 2 // Permissão de Trabalho
			lRet := If( !Empty( MV_PAR01 ), ExistCpo( "TI0" , MV_PAR01 + MV_PAR02 ), .T. )
		ElseIf nMvPar == 3 // Termo de Responsabilidade
			lRet := If( !Empty( MV_PAR03 ) , ExistCpo( "TMZ" , MV_PAR03 ) , .T. )
		ElseIf nMvPar == 4 // Tipo de Impressão
			lRet := NaoVazio()
		ElseIf nMvPar == 5 // Em branco
			lRet := NaoVazio()
		ElseIf nMvPar == 6 // Quantidade de vias
			lRet := NaoVazio()
		ElseIf nMvPar == 7 // Formato de Impressão
			lRet := NaoVazio()
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} R980Imp
Impressão do relatório.

@author André Felipe Joriatti
@since 22/05/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------

Static Function R980Imp()

	Local nLinhas
	Local nQtdFunc
	Local cFuncioInt
	Local cFuncioExt
	Local cBarraRem := "\"
	Local cBarraSrv := "\"

	Local cCheckYes := " ( X ) "
	Local cCheckNo  := " (   ) "

	Local cFdsSim := cCheckNo
	Local cFdsNao := cCheckNo

	Local cConSim := cCheckNo
	Local cConNao := cCheckNo

	Local lDepto := NGCADICBASE( "TI0_DEPTO", "A" , "TI0" , .F. )

	Local cAreaReSim := cCheckNo
	Local cAreaReNao := cCheckNo

	Local nI        := 0

	Private cContTab:= ""
	Private nLinhaTab
	Private loPrint := MV_PAR07 == 2

	Private lImpBranco := MV_PAR05 == 1

	Private Inclui := .F.
	Private Altera := .F.

	//-------------------------------------
	// Posiciona na Permissão de Trabalho
	//-------------------------------------
	DbSelectArea( "TI0" )
	DbSetOrder( 01 ) // TI0_FILIAL+TI0_PERMIS+TI0_SEQPER
	If !DbSeek( xFilial( "TI0" ) + MV_PAR01 + MV_PAR02 )
		MsgStop( STR0023 ) // "Permissão de Trabalho não existe."
		Return .F.
	EndIf

	// Grava data de impressão e campo 'Impresso?' caso seja impressão não branco
	If !lImpBranco
		If Empty( TI0->TI0_DATIMP )
			DbSelectArea( "TI0" )
			RecLock( "TI0",.F. )
			TI0->TI0_DATIMP := dDataBase
			MsUnLock( "TI0" )
		EndIf

		// Verificar daqui para baixo como fica para dentro do laço que lê a TI0
		If TI0->TI0_AREARE == '1'
			cAreaReSim := cCheckYes
		ElseIf TI0->TI0_AREARE == '2'
			cAreaReNao := cCheckYes
		EndIf

		If TI0->TI0_FDSFER == '1'
			cFdsSim := cCheckYes
		ElseIf TI0->TI0_FDSFER == '2'
			cFdsNao := cCheckYes
		EndIf

		//Indica se o PT/PET esta concluida
		If Empty( TI0->TI0_DTCONC )
			cConSim := cCheckNo
			cConNao := cCheckYes
		Else
			cConSim := cCheckYes
			cConNao := cCheckNo
		EndIf
	Else
		// Força final de arquivo caso impresão em branco
		fTI0Bott()
		MV_PAR03 := Space( 6 )
	EndIf

	nQtdFunc   := 0
	cFuncioInt := cCheckNo
	cFuncioExt := cCheckNo

	If NGIFDBSEEK( "TI1",TI0->TI0_PERMIS + TI0->TI0_SEQPER,1 )
		While !EoF() .And. TI1->TI1_FILIAL == xFilial( "TI1" ) .And. TI1->TI1_PERMIS == TI0->TI0_PERMIS .And. TI1->TI1_SEQPER == TI0->TI0_SEQPER
			nQtdFunc += 1
			If TI1->TI1_TIPFUN == '1'
				cFuncioInt := cCheckYes
			ElseIf TI1->TI1_TIPFUN == '2'
				cFuncioExt := cCheckYes
			EndIf

			DbSelectArea( "TI1" )
			DbSkip()
		EndDo
	EndIf

	If loPrint
		Private nMaxCarac := 56	//	Quantidade maxima de caracteres em cada linha
		Private nImpLin	  := 0	//	Linha a ser impressa a Estrutura Completa
		Private oFont09   := TFont():New( "Courier New",09,09,,.F.,,,,.F.,.F. )
		Private oFont09B  := TFont():New( "Courier New",09,09,,.T.,,,,.F.,.F. )
		Private oPrint    := TMSPrinter():New( OemToAnsi( STR0001 ),,,,,,.T. ) //"Permissão de Trabalho"

		oPrint:Setup()

		For nI := 1 To MV_PAR06 // Número de vias

			oPrint:StartPage()
			lin := 90

			oPrint:Line( lin,100,lin,2300 ) // Linha Horizontal
			oPrint:Say( lin+20,1200,STR0024,oFont09B,,,,2 ) // "Permissão de Trabalho - PT"
			oPrint:Line( lin,100,Lin+70,100 )  // Linha Vertical
			oPrint:Line( lin,2300,Lin+70,2300 )
			SomaLinha( 70,,.t.,.t. )

			oPrint:Say( lin+25,120,STR0025 + MV_PAR01 + "\" + MV_PAR02,oFont09 ) // "Número: "
			oPrint:Say( lin+25,700,STR0026 + DTOC( TI0->TI0_DATIMP ),oFont09 ) // "Data: "
			oPrint:Say( lin+25,1500,STR0027 + cValToChar( nI ) + " / " + cValToChar( MV_PAR06 ),oFont09 ) // "Via: "
			SomaLinha( 70,,.t.,.t. )

			oPrint:Say( lin+25,120,STR0028,oFont09 ) // "Validade: "
			oPrint:Line( lin,500,Lin+70,500)
			oPrint:Say( lin+25,520,STR0029 + DTOC( TI0->TI0_DTRINI ),oFont09 ) // "De: "
			oPrint:Line( lin,900,Lin+70,900 )
			oPrint:Say( lin+25,920,STR0030 + TI0->TI0_HRRINI,oFont09 ) // "Hora: "
			oPrint:Line( lin,1400,Lin+70,1400 )
			oPrint:Say( lin+25,1420,STR0031 + DTOC( TI0->TI0_DTRFIM ),oFont09 ) // "Até: "
			oPrint:Line( lin,1800,Lin+70,1800 )
			oPrint:Say( lin+25,1820,STR0032 + TI0->TI0_HRRFIM,oFont09 ) // "Hora: "
			SomaLinha( 70,,.t.,.t. )

			oPrint:Say( lin+25,120,STR0033 + NGRETSX3BOX( 'TI0_TIPERM',TI0->TI0_TIPERM ),oFont09 ) // "Tipo de Permissão: "
			SomaLinha( 70,,.t.,.t. )

			oPrint:Say( lin+25,475,STR0034,oFont09B,,,,2 ) // "Área Restrita"
			oPrint:Say( lin+25,1200,STR0035,oFont09B,,,,2 ) // "Mão-de-obra"
			oPrint:Say( lin+25,1925,STR0036,oFont09B,,,,2 ) // "Fim de Semana / Feriado"
			oPrint:Line( lin,850,Lin+70,850 )
			oPrint:Line( lin,1550,Lin+70,1550 )
			SomaLinha( 70,,.t.,.t. )

			oPrint:Say( lin+25,120,cAreaReSim + STR0012,oFont09 ) // "Sim"
			oPrint:Line( lin,850,Lin+70,850 )
			oPrint:Say( lin+25,870,cFuncioInt + STR0037,oFont09 ) // "Interna"
			oPrint:Say( lin+25,1570,cFdsSim + STR0012,oFont09 ) // "Sim"
			oPrint:Line( lin,1550,Lin+70,1550 )
			SomaLinha( 70,,.t.,.f. )

			oPrint:Say( lin+25,120,cAreaReNao + STR0013,oFont09 ) // "Não"
			oPrint:Line( lin,850,Lin+70,850 )
			oPrint:Say( lin+25,870,cFuncioExt + STR0038,oFont09 ) // "Externa"
			oPrint:Say( lin+25,1570,cFdsNao + STR0013,oFont09 ) // "Não"
			oPrint:Line( lin,1550,Lin+70,1550 )
			SomaLinha( 70,,.t.,.f. )

			oPrint:Line( lin,850,Lin+70,850 )
			oPrint:Say( lin+25,870,STR0039+ AllTrim( If( lImpBranco, "" , Str( nQtdFunc ) ) ),oFont09 ) // "Nº de Funcionários: "
			oPrint:Line( lin,1550,Lin+70,1550 )
			SomaLinha( 70,,.t.,.t. )

			oPrint:Say( lin+25,120,STR0040 + TI0->TI0_NOMEMP,oFont09 ) // "Nome da Empresa: "
			oPrint:Line( lin,1180,Lin+70,1180 )
			oPrint:Say( lin+25,1200,STR0041 + MDT992RELA( "TI0" , 3 ),oFont09 ) // "Supervisor: "
			SomaLinha( 70,,.t.,.t. )

			oPrint:Say( lin+25,120,STR0042 + MDT992RELA( "TI0" , 2 ),oFont09 ) // "Responsável Técnico: "
			oPrint:Line( lin,1180,Lin+70,1180 )
			If lDepto .and. Mv_par08 == 2
				oPrint:Say( lin+25,1200,"Departamento: " + AllTrim( NGSEEK( "SQB",TI0->TI0_DEPTO,1,"QB_DESCRIC" ) ),oFont09 ) // "Departamento"
			ELse
				oPrint:Say( lin+25,1200,STR0043 + AllTrim( NGSEEK( "CTT",TI0->TI0_CCUSTO,1,"CTT_DESC01" ) ),oFont09 ) // "Centro de Custo: "
			EndIf
			SomaLinha( 70,,.t.,.t. )

			oPrint:Say( lin+25,120,STR0044 + AllTrim( NGSEEK( "SRJ",TI0->TI0_FUNCAO,1,"RJ_DESC" ) ),oFont09 ) // "Função: "
			oPrint:Line( lin,1180,Lin+70,1180 )
			oPrint:Say( lin+25,1200,STR0045+ AllTrim( NGSEEK( "TNE",TI0->TI0_LOCTRA,1,"TNE_NOME" ) ),oFont09 ) // "Local de Trabalho: "
			SomaLinha( 70,,.t.,.t. )

			oPrint:Say( lin+25,120,STR0046 + MDT992RELA( "TI0" , 1 ),oFont09 ) // "Vigia: "
			oPrint:Line( lin,1180,Lin+70,1180 )
			oPrint:Say( lin+25,1200,STR0047 + MDT992RELA( "TI0" , 4 ),oFont09 ) // "Sup. Execução: "
			SomaLinha( 70,,.t.,.t. )

			oPrint:Say( lin+25,120,STR0048 + TI0->TI0_DESTRA,oFont09 ) // "Descrição do trabalho: "
			SomaLinha( 70,,.t.,.t. )

			If lImpBranco
				DbSelectArea( "TI0" )
				DbSetOrder( 01 ) // TI0_FILIAL+TI0_PERMIS+TI0_SEQPER
				DbSeek( xFilial( "TI0" ) + MV_PAR01 + MV_PAR02 )
			EndIf

			oPrint:Say( lin+25,120,STR0049,oFont09 ) // "Observações: "
			nLinhas := PrintMemo( MSMM( TI0->TI0_OBSSYP ),370,97,.f. )
			SomaLinha( 70,,.t.,.t. )
			If NGIFDBSEEK( "TKM",TI0->TI0_EQUIPE,1 )
				oPrint:Say( lin+25,1200,STR0050,oFont09B,,,,2 ) // "Equipe de Resgate:"
				ListResgat( loPrint )
			EndIf

			If NGIFDBSEEK( "TI4",TI0->TI0_PERMIS + TI0->TI0_SEQPER,1 )
				oPrint:Say( lin+25,1200,STR0051,oFont09B,,,,2 ) // "Equipamento(s)/Aparelho(s) a utilizar"
				ListEquipa( loPrint )
			EndIf

			If NGIFDBSEEK( "TI2",TI0->TI0_PERMIS + TI0->TI0_SEQPER,1 )
				oPrint:Say( lin+25,1200,STR0052,oFont09B,,,,2 ) // "Riscos"
				ListRiscos( loPrint )
			EndIf

			If NGIFDBSEEK( "TI3",TI0->TI0_PERMIS + TI0->TI0_SEQPER,1 )
				oPrint:Say( lin+25,1200,STR0053,oFont09B,,,,2 ) // "Equipamento(s) de Proteção Individual Necessário(s)"
				ListaEPI( loPrint )
			EndIf

			If NGIFDBSEEK( "TI1",TI0->TI0_PERMIS + TI0->TI0_SEQPER,1 )
				oPrint:Say( lin+25,1200,STR0054,oFont09B,,,,2 ) // "Pessoas liberadas para trabalhar"
				ListFuncio( loPrint )
			EndIf

			If !Empty( TI0->TI0_MEDSYP )
				oPrint:Say( lin+25,1200,STR0091,oFont09B,,,,2 ) // "Medida(s) Preventiva(s)"
				ListMedPre( loPrint )
			EndIf

			If NGIFDBSEEK( "TI6",TI0->TI0_PERMIS + TI0->TI0_SEQPER,1 )
				oPrint:Say( lin+25,1200,STR0055,oFont09B,,,,2 ) // "Procedimentos de Emergência e Resgate"
				SomaLinha( 70,,.t.,.t. )
				oPrint:Say( lin+25,650,STR0056,oFont09,,,,2 ) // "Contato"
				oPrint:Say( lin+25,1750,STR0057,oFont09,,,,2 ) // "Telefone"
				oPrint:Line( lin,1200,Lin+70,1200 )
				ListContat( loPrint )
			EndIf

			cContTab := AllTrim( NGSEEK( "TMZ",MV_PAR03,1,"TMZ->TMZ_DESCRI" ) )
			If !Empty( cContTab )

				oPrint:Say( lin+25,1200,STR0058,oFont09B,,,,2 ) // "Liberação"
				SomaLinha( 70,,.t.,.t. )

				// Imprime texto de Termo de responsabilidade
				PrintMemo( cContTab , 120 , 97 , .F. )

				SomaLinha( 70,,.t.,.t. )
				oPrint:Line( lin,100,lin,2300 ) //Linha Horizontal
				oPrint:Line( lin,830,Lin+210,830 )
				oPrint:Line( lin,1530,Lin+210,1530 )
				oPrint:Line( lin,100,lin,2300 ) //Linha Horizontal
				SomaLinha( 140,,.t.,.f. )

				oPrint:Say( lin+25,245,STR0059,oFont09 ) // "Assinatura do Supervisor"
				oPrint:Say( lin+25,855,STR0060,oFont09 ) // "Assinatura do Técnico de Segurança"
				oPrint:Say( lin+25,1590,STR0061,oFont09 ) // "Assinatura do Responsável da Área"
				SomaLinha( 70,,.t.,.t. )

			EndIf

			If !Empty( TI0->TI0_DINIRV )
				If lImpBranco
					// Força final de arquivo caso impresão em branco
					fTI0Bott()
				EndIf
				oPrint:Say( lin+25,1200,STR0062,oFont09B,,,,2 ) // "Revalidação"
				SomaLinha( 70,,.t.,.t. )
				oPrint:Line( lin,830,Lin+70,830 )
				oPrint:Line( lin,1530,Lin+70,1530 )
				oPrint:Say( lin+25,120,STR0063 + DTOC( TI0->TI0_DINIRV ),oFont09 ) // "Início: "
				oPrint:Say( lin+25,850,STR0064 + DTOC( TI0->TI0_DFIMRV ),oFont09 ) // "Término: "
				SomaLinha( 70,,.t.,.f. )
				oPrint:Line( lin,830,Lin+70,830 )
				oPrint:Line( lin,1530,Lin+70,1530 )
				oPrint:Say( lin+25,120,STR0030 + TI0->TI0_HINIRV,oFont09 ) // "Hora: "
				oPrint:Say(lin+25,850,STR0030 + TI0->TI0_HFIMRV,oFont09 ) // "Hora: "
				SomaLinha( 70,,.t.,.f. )
				oPrint:Line( lin,830,Lin+70,830 )
				oPrint:Line( lin,1530,Lin+70,1530 )
				oPrint:Say( lin+25,1592,STR0065,oFont09 ) // "Assinatura do Técnico de Segurança"
				SomaLinha( 70,,.t.,.t. )
			EndIf

			oPrint:Say( lin+25,120,STR0066 + STR0012 + cConSim + Space(3) + STR0013 + cConNao,oFont09 ) // "Trabalho Concluído: " // "Sim"// "Não"
			oPrint:Say( lin+25,1100,STR0067 + DTOC(TI0->TI0_DTCONC),oFont09 ) // "Data:"
			oPrint:Say( lin+25,1600,STR0068 + TI0->TI0_HRCONC,oFont09 ) // "Hora:"
			SomaLinha( 70,,.t.,.t. )

			oPrint:EndPage()
		Next nI

		If MV_PAR04 == 1
			oPrint:Preview()
		EndIf
	Else
		Private cArqDot  := "pet.dot"	// Nome do arquivo modelo do Word (Tem que ser .dot)
		Private cPathEst := AllTrim( GetMv( "MV_DIREST" ) )  // Path do arquivo a ser armazenado na estação de trabalho
		Private cPathDot := AllTrim( GetMv( "MV_DIRACA" ) )	 // Path do arquivo modelo do Word
		Private oWord
		cPathDot += If( SubStr( cPathDot,len( cPathDot),1) != cBarraSrv,cBarraSrv,"" ) + cArqDot
		cPathEst += If( SubStr( cPathEst,len( cPathEst),1) != cBarraRem,cBarraRem,"" )

		For nI := 1 To MV_PAR06 // Número de vias
			CpyS2T( cPathDot,cPathEst,.T. ) // Copia do Server para o Remote, eh necessario

			oWord := OLE_CreateLink( 'TMsOleWord97' ) // Cria link como Word

		  	lImpress := MV_PAR04 == 2
			If lImpress //Impressao via Impressora
				OLE_SetProperty( oWord,"oleWdVisible",  .F. )
				OLE_SetProperty( oWord,"oleWdPrintBack",.T. )
			Else //Impressao na Tela(Arquivo)
				OLE_SetProperty( oWord,"oleWdVisible",.F. )
				OLE_SetProperty( oWord,"oleWdPrintBack",.F. )
			EndIf
	      // Abrindo o arquivo modelo automaticamente
			OLE_NewFile( oWord,cPathEst + cArqDot )

			OLE_SetDocumentVar( oWord,"Titulo",STR0001 )//"Permissão de Trabalho"
			OLE_SetDocumentVar( oWord,"TI0_PERMIS",STR0025 + MV_PAR01 + "\" + MV_PAR02 ) //"Número: "
			OLE_SetDocumentVar( oWord,"TI0_DATIMP",STR0067 + DTOC( TI0->TI0_DATIMP ) )//"Data: "
			OLE_SetDocumentVar( oWord,"TI0_VIAIMP",STR0027 + cValToChar( nI ) + " / " + cValToChar( MV_PAR06 ) )//"Via: "

			OLE_SetDocumentVar( oWord,"TI0_VALID",STR0028 ) //"Validade: "
			OLE_SetDocumentVar( oWord,"TI0_DTRINI",STR0029 + DTOC( TI0->TI0_DTRINI ) ) // "De: "
			OLE_SetDocumentVar( oWord,"TI0_HRRINI",STR0030 + TI0->TI0_HRRINI ) // "Hora: "
			OLE_SetDocumentVar( oWord,"TI0_DTRFIM",STR0031 + DTOC( TI0->TI0_DTRFIM ) ) // "Até: "
			OLE_SetDocumentVar( oWord,"TI0_HRRFIM",STR0032 + TI0->TI0_HRRFIM ) // "Hora: "
			OLE_SetDocumentVar( oWord,"TI0_TIPERM",STR0033 + NGRETSX3BOX( 'TI0_TIPERM',TI0->TI0_TIPERM ) ) // "Tipo de Permissão: "

			OLE_SetDocumentVar( oWord,"AreaRestrita", STR0034 ) // "Área Restrita"
			OLE_SetDocumentVar( oWord,"Maodeobra"   , STR0035 ) // "Mão-de-obra"
			OLE_SetDocumentVar( oWord,"Feriado"     , STR0036 ) // "Fim de Semana / Feriado"

			OLE_SetDocumentVar( oWord,"cAreaReSim",cAreaReSim + STR0012 ) // "Sim"
			OLE_SetDocumentVar( oWord,"cFuncioInt",cFuncioInt + STR0037 ) // "Interna"
			OLE_SetDocumentVar( oWord,"cFdsSim"   ,cFdsSim + STR0012 ) // "Sim"
			OLE_SetDocumentVar( oWord,"cAreaReNao",cAreaReNao + STR0013 ) // "Não"
			OLE_SetDocumentVar( oWord,"cFuncioExt",cFuncioExt + STR0038 ) // "Externa"
			OLE_SetDocumentVar( oWord,"cFdsNao"   ,cFdsNao + STR0013 ) // "Não"
			OLE_SetDocumentVar( oWord,"nQtdFunc"  ,STR0039+ AllTrim( If( lImpBranco, "" , Str( nQtdFunc ) ) ) ) // "Nº de Funcionários: "

			OLE_SetDocumentVar( oWord,"TI0_NOMEMP", STR0040 + TI0->TI0_NOMEMP ) // "Nome da Empresa: "
			OLE_SetDocumentVar( oWord,"TI0_NOMSUP", STR0041 + MDT992RELA( "TI0" , 3 ) ) // "Supervisor: "
			OLE_SetDocumentVar( oWord,"TI0_NOMRES", STR0042 + MDT992RELA( "TI0" , 2 ) ) // "Responsável Técnico: "
			If lDepto .and. Mv_par08 == 2
				OLE_SetDocumentVar( oWord,"TI0_CCUSTO", "Departamento: " + AllTrim( NGSEEK( "SQB",TI0->TI0_DEPTO,1,"QB_DESCRIC" ) ) ) // "Departamento"
			Else
				OLE_SetDocumentVar( oWord,"TI0_CCUSTO", STR0043 + AllTrim( NGSEEK( "CTT",TI0->TI0_CCUSTO,1,"CTT_DESC01" ) ) ) // "Centro de Custo: "
			EndIf
			OLE_SetDocumentVar( oWord,"TI0_FUNCAO", STR0044 + AllTrim( NGSEEK( "SRJ",TI0->TI0_FUNCAO,1,"RJ_DESC" ) ) ) // "Função: "
			OLE_SetDocumentVar( oWord,"TI0_LOCTRA", STR0045 + AllTrim( NGSEEK( "TNE",TI0->TI0_LOCTRA,1,"TNE_NOME" ) ) ) // "Local de Trabalho: "
			OLE_SetDocumentVar( oWord,"TI0_NOMVIG", STR0046 + MDT992RELA( "TI0" , 1 ) ) // "Vigia: "
			OLE_SetDocumentVar( oWord,"TI0_NOMSUE", STR0047 + MDT992RELA( "TI0" , 4 ) ) // "Sup. Execução: "
			OLE_SetDocumentVar( oWord,"TI0_DESTRA", STR0048 + TI0->TI0_DESTRA ) // "Descrição do trabalho: "
			OLE_SetDocumentVar( oWord,"TI0_OBSERV", STR0049+ MSMM( TI0->TI0_OBSSYP ) )// "Observações: "

			OLE_SetDocumentVar( oWord,"Conteudo",'' )
			OLE_SetDocumentVar( oWord,"Linhas",'' )
			OLE_SetDocumentVar( oWord,"Tabela",'' )
			OLE_ExecuteMacro( oWord,"Atualiza" )

			If NGIFDBSEEK( "TKM",TI0->TI0_EQUIPE,1 )
				cContTab  := ""
				nLinhaTab := 0
				ListResgat( loPrint )
				OLE_ExecuteMacro( oWord,"Final_texto" ) //Posiciona o cursor no final do documento
				OLE_SetDocumentVar( oWord,"Conteudo",cContTab )
				OLE_SetDocumentVar( oWord,"Linhas"  ,nLinhaTab )
				OLE_SetDocumentVar( oWord,"Tabela"  , "2" )//STR0084 ) // "Equipe"
				OLE_ExecuteMacro(   oWord,"Tabelas" )
			EndIf

			If NGIFDBSEEK( "TI4",TI0->TI0_PERMIS + TI0->TI0_SEQPER,1 )
				cContTab := ""
				nLinhaTab := 0
				ListEquipa( loPrint )
				If nLinhaTab > 0
					OLE_ExecuteMacro( oWord,"Final_texto" ) //Posiciona o cursor no final do documento
					OLE_SetDocumentVar( oWord,"Conteudo",cContTab )
					OLE_SetDocumentVar( oWord,"Linhas",nLinhaTab )
					OLE_SetDocumentVar( oWord,"Tabela", "1" )// STR0085 ) // "Equipamento"
					OLE_ExecuteMacro( oWord,"Tabelas" )
				EndIf
			EndIf

			If NGIFDBSEEK( "TI2",TI0->TI0_PERMIS + TI0->TI0_SEQPER,1 )
				cContTab := ""
				nLinhaTab := 0
				ListRiscos( loPrint )
				If nLinhaTab > 0
					OLE_ExecuteMacro( oWord,"Final_texto" ) //Posiciona o cursor no final do documento
					OLE_SetDocumentVar( oWord,"Conteudo",cContTab )
					OLE_SetDocumentVar( oWord,"Linhas",nLinhaTab )
					OLE_SetDocumentVar( oWord,"Tabela", "1" )//STR0086 ) // "Risco"
					OLE_ExecuteMacro( oWord,"Tabelas" )
				EndIf
			EndIf

			If NGIFDBSEEK( "TI3",TI0->TI0_PERMIS + TI0->TI0_SEQPER,1 )
				cContTab := ""
				nLinhaTab := 0
				ListaEPI( loPrint )
				If nLinhaTab > 0
					OLE_ExecuteMacro( oWord,"Final_texto" ) //Posiciona o cursor no final do documento
					OLE_SetDocumentVar( oWord,"Conteudo",cContTab )
					OLE_SetDocumentVar( oWord,"Linhas",nLinhaTab )
					OLE_SetDocumentVar( oWord,"Tabela", "1" )// STR0087 ) // "EPI"
					OLE_ExecuteMacro( oWord,"Tabelas"  )
				EndIf
			EndIf

			If NGIFDBSEEK( "TI1",TI0->TI0_PERMIS + TI0->TI0_SEQPER,1 )
				cContTab := ""
				nLinhaTab := 0
				ListFuncio( loPrint )
				If nLinhaTab > 0
					OLE_ExecuteMacro( oWord,"Final_texto" ) //Posiciona o cursor no final do documento
					OLE_SetDocumentVar( oWord,"Conteudo",cContTab )
					OLE_SetDocumentVar( oWord,"Linhas",nLinhaTab )
					OLE_SetDocumentVar( oWord,"Tabela", "2" ) // STR0088 ) // "Pessoas"
					OLE_ExecuteMacro( oWord,"Tabelas" )
				EndIf
			EndIf

			If !Empty( TI0->TI0_MEDSYP ) .Or. lImpBranco
				cContTab := ""
				nLinhaTab := 0
				ListMedPre( loPrint )
				If nLinhaTab > 0
					OLE_ExecuteMacro( oWord,"Final_texto" ) //Posiciona o cursor no final do documento
					OLE_SetDocumentVar( oWord,"Conteudo",cContTab )
					OLE_SetDocumentVar( oWord,"Linhas",nLinhaTab )
					OLE_SetDocumentVar( oWord,"Tabela", "1" )//"Medida(s) Preventiva(s)"
					OLE_ExecuteMacro( oWord,"Tabelas" )
				EndIf
			EndIf

			If NGIFDBSEEK( "TI6",TI0->TI0_PERMIS + TI0->TI0_SEQPER,1 )
				cContTab := ""
				nLinhaTab := 0
				ListContat( loPrint )
				If nLinhaTab > 0
					OLE_ExecuteMacro( oWord,"Final_texto" ) // Posiciona o cursor no final do documento
					OLE_SetDocumentVar( oWord,"Conteudo",cContTab )
					OLE_SetDocumentVar( oWord,"Linhas",nLinhaTab )
					OLE_SetDocumentVar( oWord,"Tabela", "3" )// STR0089 ) // "Procedimentos"
					OLE_ExecuteMacro( oWord,"Tabelas" )
				EndIf
			EndIf

			cContTab  := AllTrim( NGSEEK( "TMZ",MV_PAR03,1,"TMZ->TMZ_DESCRI" ) )
			If !Empty( cContTab )
				cContTab := STR0058 + "#*" + cContTab + "#*" + STR0059 + "#*" + STR0060 + "#*" + STR0061 + "#*"//"Liberação"//"Assinatura do Supervisor"//"Assinatura do Técnico de Segurança"//"Assinatura do Responsável da Área"
				OLE_SetDocumentVar( oWord,"Conteudo", cContTab )
				OLE_ExecuteMacro( oWord,"InfoLiberacao" ) //Posiciona o cursor no final do documento
			EndIf

			cContTab := DTOC( TI0->TI0_DINIRV )
			cContTab  := If( lImpBranco , "" , cContTab )
			If !Empty( TI0->TI0_DINIRV ) .Or. lImpBranco
				cContTab := STR0062 + "#*" + STR0063 + cContTab + "#*" + STR0030 + TI0->TI0_HINIRV + "#*"//"Revalidação"//"Início: "// "Hora: "
				cContTab += STR0064 + DTOC( TI0->TI0_DFIMRV ) + "#*" + STR0030 + TI0->TI0_HFIMRV + "#*" + STR0065 + "#*" // "Término: "// "Hora: "//"Assinatura do Técnico de Segurança"

				OLE_SetDocumentVar( oWord,"Conteudo", cContTab )
				OLE_ExecuteMacro( oWord,"InfoReavaliacao" ) //Posiciona o cursor no final do documento
			EndIf

			cContTab := STR0066 + STR0012 + cConSim + Space(3) + STR0013 + cConNao + "#*"//"Sim"//"Não"
			cContTab += Space(8) + STR0067 + DTOC(TI0->TI0_DTCONC) + Space(35) + STR0068 + TI0->TI0_HRCONC + "#*"//"Data:"//"Hora:"

			OLE_SetDocumentVar( oWord,"Conteudo", cContTab )
			OLE_ExecuteMacro( oWord,"InfoConclusao" ) //Posiciona o cursor no final do documento

			cRootPath := GetPvProfString( GetEnvServer(), "RootPath", "ERROR", GetADV97() )
			cRootPath := If( RIGHT( cRootPath,1 ) == cBarraSRV,SubStr( cRootPath,1,Len( cRootPath )-1 ), cRootPath )

			cArqSaida := "PET" + cValToChar( Year( Date() ) ) + cValToChar( nI ) // Cada arquivo gerado deve ter um nome diferente.

			IF lImpress //Impressao via Impressora
				OLE_SetProperty( oWord, "208", .F. )
				OLE_PrintFile( oWord, "ALL",,, 1 )
			Else //Impressao na Tela(Arquivo)
				OLE_SetProperty( oWord,"oleWdVisible",.t. )
				OLE_ExecuteMacro( oWord,"Maximiza_Tela" )
				If !lMdtUnix // Se for windows
					If fDIRR850( cRootPath+cBarraSRV+"SPOOL"+cBarraSRV )
						OLE_SaveAsFile( oWord,cRootPath + cBarraSRV + "SPOOL" + cBarraSRV+cArqSaida,,,.f.,"oleWdFormatDocument" )
					ElseIf fDIRR850( cPathEst )
						OLE_SaveAsFile( oWord,cPathEst + cArqSaida,,,.f.,"oleWdFormatDocument" )
					Else
						OLE_SaveAsFile( oWord,cPathEst + cArqSaida,,,.f.,"oleWdFormatDocument" )
					EndIf
				Endif
			EndIF

		Next nI

		MsgInfo( STR0069 ) // "Alterne para o programa do Ms-Word para visualizar o documento ou clique no botao para fechar."

		OLE_CloseFile( oWord ) // Fecha o documento
		OLE_CloseLink( oWord ) // Fecha o documento

	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} SomaLinha
Função soma linha do relatório.

@author Marcos Wagner Jr.
@since 22/05/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------

Static Function SomaLinha( nLinhas, lFirst, lBorda, lHorizonte )

	Local lRet := .T.

	// Defaults
	Default lFirst     := .F.
	Default lBorda     := .F.
	Default lHorizonte := .F.

	If lBorda
		oPrint:Line( lin,100,Lin+nLinhas,100 )
		oPrint:Line( lin,2300,Lin+nLinhas,2300 )
	EndIf

	If nLinhas == Nil
		Lin += 50
	Else
		Lin += nLinhas
	EndIf

	If lin >= 2680 .Or. lFirst
		If !lFirst
			oPrint:Line(lin,100,lin,2300)
			oPrint:EndPage()
			oPrint:StartPage()
		EndIf
		lin := 100
		oPrint:Line( lin,100,lin,2300 ) // Linha Hizontal
	EndIf

	If lHorizonte
		oPrint:Line( lin,100,lin,2300 ) // Linha Horizontal
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} PrintMemo
Imprime os campos memo.

@author Marcos Wagner Jr.
@since 11/03/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function PrintMemo( cDESCRI,nCOLU,nTAM,lBorda )

	Local lPrimeiro := .T.
	Local LinhaCorrente

	nLinhasMemo := MlCount( cDESCRI,nTAM )

	For LinhaCorrente := 1 To nLinhasMemo
		If !Empty( ( MemoLine( cDESCRI,nTAM,LinhaCorrente ) ) )
			If !lPrimeiro
				SomaLinha( 70,,.T.,.F. )
				If lBorda
					oPrint:Line( lin,880,Lin+70,880 )
					oPrint:Line( lin,1680,Lin+70,1680 )
				EndIf
			EndIf
			lPrimeiro := .F.
			oPrint:Say( lin+25,nCOLU,( If( lImpBranco , "" , MemoLine( cDESCRI,nTAM,LinhaCorrente ) ) ),oFont09 )
		EndIf
	Next LinhaCorrente

Return nLinhasMemo

//---------------------------------------------------------------------
/*/{Protheus.doc} ListResgat
Lista da Brigada vinculados a permissao

@author Marcos Wagner Jr.
@since 11/03/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function ListResgat( loPrint )

	Local nLinhas
	Local lRet := .T.

	Local cTextAux := STR0050 + "#*" + STR0075 + "#*" + STR0093 + "#*" + STR0094 + "#*"

	If loPrint
		SomaLinha( 70,,.T.,.T. )
		oPrint:Line( lin,880,Lin+70,880 )
		oPrint:Line( lin,1680,Lin+70,1680 )
		oPrint:Say( lin+25,490,STR0075,oFont09B,,,,2 )//"Nome"
		oPrint:Say( lin+25,1280,STR0093,oFont09B,,,,2 )//"Função"
		oPrint:Say( lin+25,1990,STR0094,oFont09B,,,,2 )//"Atribuições"
	EndIf


	While !EoF() .And. TKM->TKM_BRIGAD == TI0->TI0_EQUIPE .And. TKM->TKM_FILIAL == xFilial( "TKM" )
		If loPrint
			SomaLinha( 70,,.T.,.T. )
			If !lImpBranco
				oPrint:Say( lin+25,120,NGSeek( "SRA" , TKM->TKM_MATFUN , 1, "RA_NOME" ),oFont09 )
				oPrint:Say( lin+25,900,NGSeek( "TKU" , TKM->TKM_FUNCAO , 1, "TKU_DESC" ),oFont09 )
			EndIf
			oPrint:Line( lin,880,Lin+70,880 )
			oPrint:Line( lin,1680,Lin+70,1680 )
			nLinhas := PrintMemo( TKM->TKM_ATRIB,1700,29,.T. )
		Else
			If !lImpBranco
				cTextAux += AllTrim( NGSeek( "SRA" , TKM->TKM_MATFUN , 1, "RA_NOME" ) ) + "#*" + AllTrim( NGSeek( "TKU" , TKM->TKM_FUNCAO , 1, "TKU_DESC" ) ) + "#*" + AllTrim( TKM->TKM_ATRIB ) + "#*"
			Else
				cTextAux += "#*" + "#*" + "#*"
			EndIf
			nLinhaTab++
		EndIf
		DbSkip()
	EndDo

	If loPrint
		SomaLinha( 70,,.T.,.T. )
	Else
		cContTab += cTextAux
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} ListFuncio
Lista dos Contatos vinculados a permissao

@author Marcos Wagner Jr.
@since 11/03/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function ListFuncio( loPrint )

	Local cNomFun
	Local cTextAux := STR0074 + "#*" + STR0075 + "#*" + STR0076 + "#*" + STR0077 + "#*" // "Pessoas liberadas para trabalhar" // "Nome" ## "Assinatura" ## "Observações"

	If loPrint
		SomaLinha( 70,,.T.,.T. )
		oPrint:Say( lin+25,450,STR0071,oFont09B,,,,2 ) // "Nome"
		oPrint:Say( lin+25,1150,STR0072,oFont09B,,,,2 ) // "Assinatura"
		oPrint:Say( lin+25,1900,STR0073,oFont09B,,,,2 ) // "Observações"

		oPrint:Line( lin,800,Lin+70,800 )
		oPrint:Line( lin,1500,Lin+70,1500 )
	EndIf

	While !EoF() .And. TI1->TI1_FILIAL == xFilial( "TI1" ) .And. TI1->TI1_PERMIS == TI0->TI0_PERMIS .And. TI1->TI1_SEQPER == TI0->TI0_SEQPER
		cNomFun := AllTrim( TI1->TI1_NOMFUN )

		If loPrint
			SomaLinha( 70,,.T.,.T. )
			If !lImpBranco
				oPrint:Say( lin+25,120,cNomFun,oFont09 )
			EndIf
			oPrint:Line( lin,800,Lin+70,800 )
			oPrint:Line( lin,1500,Lin+70,1500 )
		Else
			If !lImpBranco
				cTextAux += cNomFun + "#*" + "#*" + "#*"
			Else
				cTextAux += "#*" + "#*" + "#*"
			EndIf
			nLinhaTab++
		EndIf

		DbSelectArea( "TI1" )
		DbSkip()
	EndDo

	If loPrint
		SomaLinha( 70,,.T.,.T. )
	Else
		cContTab := cTextAux
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} ListContat
Lista dos Contatos vinculados a permissao

@author Marcos Wagner Jr.
@since 11/03/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function ListContat( loPrint )
	Local cTextAux := STR0078 + "#*" + STR0079 + "#*" + STR0080 + "#*" // "Procedimentos de Emergência e Resgate"// "Contato" ## "Telefone"

	While !EoF() .And. TI6->TI6_FILIAL == xFilial( "TI6" ) .And. TI6->TI6_PERMIS == TI0->TI0_PERMIS .And. TI6->TI6_SEQPER == TI0->TI0_SEQPER
		If loPrint
			SomaLinha( 70,,.T.,.T. )
			If !lImpBranco
				oPrint:Say( lin+25,120,TI6->TI6_NOMCON,oFont09 )
				oPrint:Say( lin+25,1220,Transform( TI6->TI6_TELEFO,"@R (99) 9999-9999" ),oFont09 )
			EndIf
			oPrint:Line( lin,1200,Lin+70,1200 )
		Else
			If !lImpBranco
				cTextAux += AllTrim( TI6->TI6_NOMCON ) + "#*" + Transform( TI6->TI6_TELEFO,"@R (99) 9999-9999" ) + "#*"
			Else
				cTextAux += "#*" + "#*"
			EndIf
			nLinhaTab++
		EndIf
		DbSkip()
	EndDo

	If loPrint
		oPrint:Line( lin,1200,Lin+70,1200 )
		SomaLinha( 70,,.T.,.T. )
	Else
		cContTab := cTextAux
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} ListEquipa
Lista dos Equipamentos vinculados a permissao

@author Marcos Wagner Jr.
@since 11/03/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function ListEquipa( loPrint )
	Local nTamImp
	Local cTextAux := STR0081 + "#*" // "Equipamento(s)/Aparelho(s) a utilizar"


	nTamImp := Len(TI4->TI4_EQUIPA)
	While !EoF() .And. TI4->TI4_FILIAL == xFilial( "TI4" ) .And. TI4->TI4_PERMIS == TI0->TI0_PERMIS .And. TI4->TI4_SEQPER == TI0->TI0_SEQPER
		If loPrint
			SomaLinha( 70,,.T.,.T. )
			If !lImpBranco
				oPrint:Say( lin+25,120,PADR( TI4->TI4_EQUIPA , nTamImp ) + ' - ' + NGSeek( "TM7" , TI4->TI4_EQUIPA , 1 , "TM7_NOEQTO" ) ,oFont09 )
			EndIf
		Else
			If !lImpBranco
				cTextAux += AllTrim( TI4->TI4_EQUIPA ) + ' - ' + AllTrim( NGSeek( "TM7" , TI4->TI4_EQUIPA , 1 , "TM7_NOEQTO" ) ) + "#*"
			Else
				cTextAux += "#*"
			EndIf
			nLinhaTab++
		EndIf
		DbSkip()
	EndDo

	If loPrint
		SomaLinha( 70,,.T.,.T. )
	Else
		cContTab := cTextAux
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} ListaEPI
Lista dos EPIs vinculados a permissao

@author Marcos Wagner Jr.
@since 11/03/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function ListaEPI( loPrint )
	Local cTextAux := STR0082 + "#*" // "Equipamento(s) de Proteção Individual Necessário(s)"


	While !EoF() .And. TI3->TI3_FILIAL == xFilial( "TI3" ) .And. TI3->TI3_PERMIS == TI0->TI0_PERMIS .And. TI3->TI3_SEQPER == TI0->TI0_SEQPER
		If loPrint
			SomaLinha( 70,,.T.,.T. )
			If !lImpBranco
				oPrint:Say( lin+25,120,TI3->TI3_CODEPI + ' - ' + NGSeek( "SB1" , TI3->TI3_CODEPI , 1 , "B1_DESC" ) , oFont09 )
			EndIf
		Else
			If !lImpBranco
				cTextAux += AllTrim( TI3->TI3_CODEPI ) + ' - ' + AllTrim( NGSeek( "SB1" , TI3->TI3_CODEPI , 1 , "B1_DESC" ) ) + "#*"
			Else
				cTextAux += "#*"
			EndIf
			nLinhaTab++
		EndIf
		DbSkip()
	EndDo

	If loPrint
		SomaLinha( 70,,.T.,.T. )
	Else
		cContTab := cTextAux
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} ListRiscos
Lista dos Riscos vinculados a permissao

@author Marcos Wagner Jr.
@since 11/03/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------

Static Function ListRiscos( loPrint )

	Local cTextAux := STR0083 + "#*" // "Riscos"


	While !EoF() .And. TI2->TI2_FILIAL == xFilial( "TI2" ) .And. TI2->TI2_PERMIS == TI0->TI0_PERMIS .And. TI2->TI2_SEQPER == TI0->TI0_SEQPER
		If loPrint
			SomaLinha( 70,,.T.,.T. )
			If !lImpBranco
				oPrint:Say( lin+25,120,TI2->TI2_NUMRIS + " - " + MDT992RELA( "TI2" , 1 ),oFont09 )
			EndIf
		Else
			If !lImpBranco
				cTextAux += AllTrim( TI2->TI2_NUMRIS ) + " - " + AllTrim( MDT992RELA( "TI2" , 1 ) ) + "#*"
			Else
				cTextAux += "#*"
			EndIf
			nLinhaTab++
		EndIf
		DbSkip()
	EndDo

	If loPrint
		SomaLinha( 70,,.T.,.T. )
	Else
		cContTab := cTextAux
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} ListMedPre
Impressão de medidas preventivas.

@author Guilherme Benkendorf
@since 17/12/2014
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function ListMedPre( loPrint )
	Local cMedPrev := MSMM( TI0->TI0_MEDSYP )

	If loPrint
		SomaLinha( 70 , , .T. , .T. )
		PrintMemo( cMedPrev , 120 , 97 , .F. )
		SomaLinha( 70 , , .T. , .T. )
	Else
		cContTab := STR0091 + "#*" //"Medida(s) Preventiva(s)"
		cContTab += If( lImpBranco , " " , cMedPrev )
		cContTab += "#*"
		nLinhaTab:= 1
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fTI0Bott
Força final de arquivo da tabela TI0

@author André Felipe Joriatti
@since 24/05/2013
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------

Static Function fTI0Bott()
	TI0->( DbGoBottom() )
	TI0->( DbSkip() )
Return Nil