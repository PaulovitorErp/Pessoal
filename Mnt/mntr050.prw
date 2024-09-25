#INCLUDE "MNTR050.ch"
#INCLUDE "MSOLE.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MNTR050  ³ Autor ³ Felipe N. Welter      ³ Data ³ 07/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ordem de Servico Grafica para o Manutencao                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tabelas   ³SB1 - Desc.Gen. do Produto    STD - Area de Manutencao      ³±±
±±³          ³SH4 - Ferramentas             STE - Tipo de Manutencao      ³±±
±±³          ³SI3 - Centros de Custos       STF - Manutencao              ³±±
±±³          ³ST0 - Especialidades          STJ - Ordens de Servico de M. ³±±
±±³          ³ST1 - Funcionarios            STL - Detalhes da OS de Man.  ³±±
±±³          ³ST4 - Servicos de Manutencao  STQ - Etapas Executadas       ³±±
±±³          ³ST5 - Tarefas da Manutencao   TPA - Etapas Genericas        ³±±
±±³          ³ST9 - Bem                     TPC - Opcoes da Etapa Generica³±±
±±³          ³STC - Estrutura               TT9 - Tarefa Generica         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOS - Numero da Ordem de Servico (Opcional)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTR050(cOS)

	Local aNGBEGINPRM := {}

	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 19, 95 )
		
		aNGBeginPrm := NGBEGINPRM()

		Private cPerg := 'MNR050'
		Private lTT9 := NGUSATARPAD()
		Private _cOS

		//+-----------------------------------------------------------+
		//| Variaveis utilizadas para qarametros                      |
		//| MV_PAR01     Ordem de Servico                             |
		//| MV_PAR02     Tipo de Impressao (Em Disco, Via Spool)      |
		//+-----------------------------------------------------------+
		If cOS <> Nil
			MV_PAR01 := cOS
			MV_PAR02 := 1
			MV_PAR03 := ""
			MNT050CHRE()
		ElseIf Pergunte(cPerg,.T.)
			MNT050CHRE()
		EndIf

		NGReturnPrm( aNGBeginPrm )

	EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNT050CHRE³ Autor ³ Felipe N. Welter      ³ Data ³ 07/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Chamada do Relatorio                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MNTR050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT050CHRE()

	Private cAliT   := GetNextAlias()
	Private cAliE   := GetNextAlias()
	Private cAliD   := GetNextAlias()
	Private oARQT
	Private oARQE
	Private oARQD


	//TAREFAS
	aDBFT := {}
		Aadd(aDBFT,{"TAREFA", "C", 06,0})
		Aadd(aDBFT,{"DESCRI", "C", 40,0})
		Aadd(aDBFT,{"DTPINI", "D", 08,0})
		Aadd(aDBFT,{"HRPINI", "C", 05,0})
		Aadd(aDBFT,{"DTPFIM", "D", 08,0})
		Aadd(aDBFT,{"HRPFIM", "C", 05,0})
		Aadd(aDBFT,{"SEQUEN", "C", 03,0})

	//Cria Tabela Temporária
	oARQT := NGFwTmpTbl( cAliT, aDBFT, { { 'SEQUEN', 'TAREFA', 'DESCRI' } } )

	//ETAPAS
	aDBFE := {}
		Aadd(aDBFE,{"TAREFA", "C", 006,0})
		Aadd(aDBFE,{"ETAPA" , "C", 006,0})
		Aadd(aDBFE,{"DESCRI", "C", 150,0})
		Aadd(aDBFE,{"OPCAO" , "C", 015,0})
		Aadd(aDBFE,{"REFERE", "C", 010,0})
		Aadd(aDBFE,{"SEQUEN", "C", 003,0})

	//Cria Tabela Temporária
	oARQE := NGFwTmpTbl(cAliE,aDBFE,{{"TAREFA","SEQUEN","ETAPA"}})

	//DETALHES
	aDBFD := {}
		Aadd(aDBFD,{"TAREFA" , "C", 06,0})
		Aadd(aDBFD,{"TIPOREG", "C", 01,0})
		Aadd(aDBFD,{"CODIGO" , "C", 15,0})
		Aadd(aDBFD,{"NOMECOD", "C", 20,0})
		Aadd(aDBFD,{"QUANREC", "N", 03,0})
		Aadd(aDBFD,{"QUANTID", "N", 09,2})
		Aadd(aDBFD,{"UNIDADE", "C", 03,0})
		Aadd(aDBFD,{"DTINICI", "D", 08,0})
		Aadd(aDBFD,{"HOINICI", "C", 05,0})
		Aadd(aDBFD,{"DTFIM"  , "D", 08,0})
		Aadd(aDBFD,{"HOFIM"  , "C", 05,0})

	//Cria Tabela Temporária
	oARQD := NGFwTmpTbl(cAliD,aDBFD,{{"TAREFA","TIPOREG","CODIGO"}})

	MNTR050IMP()

	oARQT:Delete()
	oARQE:Delete()
	oARQD:Delete()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTR050IMP³ Autor ³ Felipe N. Welter      ³ Data ³ 07/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do Relatorio                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MNT050CHRE                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTR050IMP()

	Local cArqDot  := "MNTR050.DOT"  // Nome do arquivo modelo do Word (Tem que ser .DOT)
	Local cPathDot := Alltrim(GetMv("MV_DIRACA")) // Path do arquivo modelo do Word
	Local cPathEst := Alltrim(GetMv("MV_DIREST")) // PATH DO ARQUIVO A SER ARMAZENADO NA ESTACAO DE TRABALHO
	Local cRootPath
	Local cPathLogo

	Local cBarraRem  := If(GetRemoteType() == 2,"/","\") //estacao com sistema operacional unix = 2
	Local cBarraSrv  := If(isSRVunix(),"/","\") //servidor eh da familia Unix (linux, solaris, free-bsd, hp-ux, etc.)
	Local cStartPath := AllTrim(GetSrvProfString("StartPath",cBarraSrv))

	cPathLogo := cPathDot + If(Substr(cPathDot,len(cPathDot),1) != cBarraSrv,cBarraSrv,"")
	cPathDot  += If(Substr(cPathDot,len(cPathDot),1) != cBarraSrv,cBarraSrv,"") + cArqDot
	cPathEst  += If(Substr(cPathEst,len(cPathEst),1) != cBarraRem,cBarraRem,"")

	//Cria diretorio se nao existir
	MontaDir(cPathEst)

	//Se existir .dot na estacao, apaga!
	If File( cPathEst + cArqDot )
		Ferase( cPathEst + cArqDot )
	EndIf
	If !File(cPathDot)
		MsgStop(STR0001+chr(13)+STR0002,STR0003) //"O arquivo MNTR050.DOT não foi encontrado no servidor."###"Verificar parâmetro 'MV_DIRACA'."###"ATENÇÃO"
		Return
	EndIf
	CpyS2T(cPathDot,cPathEst,.T.) 	// Copia do Server para o Remote, eh necessario
	// para que o wordview e o proprio word possam preparar o arquivo para impressao e
	// ou visualizacao .... copia o DOT que esta no ROOTPATH Protheus para o PATH da
	// estacao , por exemplo C:\WORDTMP


	//Variaveis utilizadas na integracao com macros do Word
	Private nLin, nCol
	Private nTarefas, nEtapas, nDetME, nDetPF


	lImpress	:= If(MV_PAR02 == 1,.F.,.T.)	//Verifica se a saida sera em Tela ou Impressora
	cArqSaida	:= If(Empty(MV_PAR03),STR0004+MV_PAR01,AllTrim(MV_PAR03)) // Nome do arquivo de saida //"OS"

	oWord := OLE_CreateLink('TMsOleWord97')//Cria link com o Word

	If lImpress //Impressao via Impressora
		OLE_SetProperty(oWord,oleWdVisible,  .F.)
		OLE_SetProperty(oWord,oleWdPrintBack,.T.)
	Else //Impressao na Tela(Arquivo)
		OLE_SetProperty(oWord,oleWdVisible,  .F.)
		OLE_SetProperty(oWord,oleWdPrintBack,.F.)
	EndIf
	cType := "MNTR050| *.DOT"
	OLE_NewFile(oWord,cPathEst + cArqDot) //Abrindo o arquivo modelo automaticamente


	//Processa os registros da Ordem de Servico e derivados
	//e seta as variaveis fixas no documento Word
	MNT050PROC()


	//Cria tabelas para Tarefas
	nTarefas := 0
	dbSelectArea(cAliT)
	dbGoTop()
	While !Eof()
		If nTarefas > 0
			OLE_ExecuteMacro(oWord,"NovaTarefa")
		EndIf
		nTarefas++
		dbSelectArea(cAliT)
		dbSkip()
	EndDo

	//Preenche tabelas de Tarefa criadas
	nTarefas := 0
	dbSelectArea(cAliT)
	dbGoTop()
	While !Eof()
		nLin := 1
		nCol := 1
		MNT050WORD(" "+AllTrim((cAliT)->TAREFA)+" - "+Capital(AllTrim((cAliT)->DESCRI)),nLin,nCol,nTarefas)

		nLin := 3
		nCol := 3
		MNT050WORD(DTOC((cAliT)->DTPINI),nLin,nCol,nTarefas)
		MNT050WORD((cAliT)->HRPINI,nLin,nCol+1,nTarefas)
		MNT050WORD(DTOC((cAliT)->DTPFIM),nLin,nCol+3,nTarefas)
		MNT050WORD((cAliT)->HRPFIM,nLin,nCol+4,nTarefas)

		Processa({ |lEnd| M050ETAPA()},STR0005+AllTrim((cAliT)->TAREFA)+" ... "+STR0006) //"Tarefa "###"Etapas"
		Processa({ |lEnd| M050MDOESP()},STR0005+AllTrim((cAliT)->TAREFA)+" ... "+STR0007) //"Tarefa "###"Mao-de-Obra e Especialidade"
		Processa({ |lEnd| M050PROFER()},STR0005+AllTrim((cAliT)->TAREFA)+" ... "+STR0008) //"Tarefa "###"Produtos e Ferramentas"

		nTarefas++
		dbSelectArea(cAliT)
		dbSkip()
	EndDo

	//Insere o Logo da Empresa no cabecalho e final da pagina
	cLogo := NGLOCLOGO()
	If Empty(cLogo)
		cStartPath := StrTran(cStartPath, cBarraSrv, ' ')
		MsgStop(STR0018 + cPathEst + Alltrim(cStartPath) + "") //"Não foi encontrada imagem da logo, inclua o arquivo na pasta "
		Return .F.
	EndIf

	//Copia do Server para o Remote, eh necessario
	CpyS2T(cLogo,cPathEst,.T.)

	//Copia do Server para o Remote, eh necessario
	CpyS2T(cPathDot,cPathEst,.T.)

	//Altera caminho da logo para o caminho na estação
	//cLogo := cPathEst + SubStr(cLogo,RAt(cBarraSrv,cLogo)+1)

	OLE_SetDocumentVar(oWord,"cVar",cPathEst + SubStr(cLogo, At("LGRL",cLogo ) ) )
	OLE_ExecuteMacro(oWord,"Insere_Logo")
	OLE_ExecuteMacro(oWord,"InsereLogoEnd")


	OLE_ExecuteMacro(oWord,"Atualiza") //Executa a macro que atualiza os campos do documento
	OLE_ExecuteMacro(oWord,"Begin_Text") //Posiciona o cursor no inicio do documento

	cRootPath := GetPvProfString( GetEnvServer(), "RootPath", "ERROR", GetADV97() )
	cRootPath := IF( RIGHT(cRootPath,1) == cBarraSrv,SubStr(cRootPath,1,Len(cRootPath)-1), cRootPath)

	IF lImpress //Impressao via Impressora
		OLE_SetProperty( oWord, '208', .F. ) ; OLE_PrintFile( oWord, "ALL",,, 1 )
	Else //Impressao na Tela(Arquivo)
		OLE_ExecuteMacro(oWord,"Maximiza_Tela")
		OLE_SetProperty(oWord,oleWdVisible,.t.)

		If DIRR570(cRootPath+cBarraSrv+"SPOOL"+cBarraSrv)
			OLE_SaveAsFile(oWord,cRootPath+cBarraSrv+"SPOOL"+cBarraSrv+cArqSaida,,,.f.,oleWdFormatDocument)
		Else
			OLE_SaveAsFile(oWord,cPathEst+cArqSaida,,,.f.,oleWdFormatDocument)
		Endif
		MsgInfo(STR0009) //"Alterne para o programa do Ms-Word para visualizar o documento ou clique no botao para fechar."
	EndIF
	OLE_CloseLink(oWord) //Fecha o documento

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNT050PROC³ Autor ³ Felipe N. Welter      ³ Data ³ 07/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processa os registros da Ordem de Servico e derivados      ³±±
±±³          ³ e seta as variaveis fixas no documento Word                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MNTR050IMP                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT050PROC()

	Local cTarefa	:= ""
	Local cSequen	:= Space(TAMSX3("T5_SEQUENC")[1])

	/**** ORDEM DE SERVICO ****/
	dbSelectArea("STJ")
	dbSetOrder(01)
	dbSeek(xFilial("STJ")+MV_PAR01)

	OLE_SetDocumentVar(oWord,"cOrdem",STJ->TJ_ORDEM)
	OLE_SetDocumentVar(oWord,"dDtEmissao",dDataBase)

	If NGCADICBASE("TJ_MMSYP","A","STJ",.F.)
		cl := NGMEMOSYP(STJ->TJ_MMSYP)
	Else
		cl := STJ->TJ_OBSERVA
	EndIf

	//Verifica se não existem quebras de linha
	If (nAt:= AT(CHR(13),cl)) == 0
		MNT050WORD(cl,1,1,-1)//-1 para voltar uma tabela
	Else
		nIni:= 1
		//Verifica se ainda existem quebras
		While AT(CHR(13),SubStr(cl,nIni)) > 0
			While nIni < nAT
				//Verifica se existem 2 quebras seguidas
				If(AT(CHR(10),SubStr(cl,nIni,1)) > 0,nIni += 1, Nil)
				//Verifica o pedaco a ser impresso
				If (nAT-nIni) < 120
					cLine := SubStr(cl,nIni,nAT-nIni)
				Else
					cLine := SubStr(cl,nIni,110)
				EndIf
				//Imprime da ultima quebra até a próxima e pula de linha
				If  nAT > 0 .and. AllTrim(SubStr(cl,nIni,(nAT-1)-nIni)) <> CHR(10)
					MNT050WORD(If(nIni==1,cLine,Space(21)+cLine),1,1,-1)//-1 para voltar uma tabela
				EndIf
				nIni += 110
				OLE_ExecuteMacro(oWord,"ProxLinha")//Pula Linha
			End
			nIni:= nAt+1
			nAt:= nAt + AT(CHR(13),SubStr(cl,nIni))
		End
		If(AT(CHR(10),SubStr(cl,nIni,1)) > 0,nIni += 1,Nil)
		If nIni <= Len(cL)
			If SubStr(cl,nIni) <> CHR(10)
				MNT050WORD(Space(21)+SubStr(cl,nIni),1,1,-1)//-1 para voltar uma tabela
			EndIf
		EndIf
	EndIf

	OLE_SetDocumentVar(oWord,"dDtPPIni",If(Empty(STJ->TJ_DTPPINI),"--/--/--",STJ->TJ_DTPPINI))
	OLE_SetDocumentVar(oWord,"cHoPPIni",If(Empty(STJ->TJ_HOPPINI),"--:--",STJ->TJ_HOPPINI))
	OLE_SetDocumentVar(oWord,"dDtPPFim",If(Empty(STJ->TJ_DTPPFIM),"--/--/--",STJ->TJ_DTPPFIM))
	OLE_SetDocumentVar(oWord,"cHoPPFim",If(Empty(STJ->TJ_HOPPFIM),"--:--",STJ->TJ_HOPPFIM))

	OLE_SetDocumentVar(oWord,"dDtMPIni",If(Empty(STJ->TJ_DTMPINI),"--/--/--",STJ->TJ_DTMPINI))
	OLE_SetDocumentVar(oWord,"cHoMPIni",If(Empty(STJ->TJ_HOMPINI),"--:--",STJ->TJ_HOMPINI))
	OLE_SetDocumentVar(oWord,"dDtMPFim",If(Empty(STJ->TJ_DTMPFIM),"--/--/--",STJ->TJ_DTMPFIM))
	OLE_SetDocumentVar(oWord,"cHoMPFim",If(Empty(STJ->TJ_HOMPFIM),"--:--",STJ->TJ_HOMPFIM))

	/**** BEM ****/
	dbSelectArea("ST9")
	dbSetOrder(01)
	If dbSeek(xFilial("ST9")+STJ->TJ_CODBEM)

		OLE_SetDocumentVar(oWord,"cCodBem",ST9->T9_CODBEM)
		OLE_SetDocumentVar(oWord,"cDescBem",ST9->T9_NOME)

		If (ST9->T9_ESTRUTU == "S") //Filho da Estrutura
			dbSelectArea("STC")
			dbSetOrder(03)
			If dbSeek(xFilial("STC")+ST9->T9_CODBEM)
				OLE_SetDocumentVar(oWord,"cPaiBem",STC->TC_CODBEM)
			EndIf
		Else
			dbSelectArea("STC")
			dbSetOrder(01)
			If dbSeek(xFilial("STC")+ST9->T9_CODBEM) //Pai da Estrutura
				OLE_SetDocumentVar(oWord,"cPaiBem",AllTrim(STC->TC_CODBEM)+STR0010) //" (é o pai)"
			Else //Nao possui estrutura
				OLE_SetDocumentVar(oWord,"cPaiBem",STR0011) //"Não possui estrutura"
			EndIf
		EndIf

		OLE_SetDocumentVar(oWord,"cCCustoBem",AllTrim(ST9->T9_CCUSTO)+" - "+NGSEEK("SI3",ST9->T9_CCUSTO,1,"I3_DESC"))

	EndIf


	If STJ->TJ_PLANO == "000000"
		lPreventiva := .F. //OS CORRETIVA
	Else
		lPreventiva := .T. //OS PREVENTIVA
	EndIf


	/**** MANUTENCAO ****/
	If lPreventiva
		dbSelectArea("STF")
		dbSetOrder(01)
		If dbSeek(xFilial("STF")+STJ->TJ_CODBEM+STJ->TJ_SERVICO+STJ->TJ_SEQRELA)
			OLE_SetDocumentVar(oWord,"cNomeMan",STF->TF_NOMEMAN)
			OLE_SetDocumentVar(oWord,"cServico",AllTrim(STF->TF_SERVICO)+" - "+NGSEEK("ST4",STF->TF_SERVICO,1,"T4_NOME"))
			OLE_SetDocumentVar(oWord,"cArea",NGSEEK("STD",STF->TF_CODAREA,1,"TD_NOME"))
			OLE_SetDocumentVar(oWord,"cTipo",NGSEEK("STE",STF->TF_TIPO,1,"TE_NOME"))
			OLE_SetDocumentVar(oWord,"dManAnt",STF->TF_DTULTMA)
			OLE_SetDocumentVar(oWord,"cSequencia",STF->TF_SEQRELA)
		EndIf
	Else
		OLE_SetDocumentVar(oWord,"cNomeMan",STR0012) //"MANUTENÇÃO CORRETIVA"
		OLE_SetDocumentVar(oWord,"cServico",AllTrim(STJ->TJ_SERVICO)+" - "+NGSEEK("ST4",STJ->TJ_SERVICO,1,"T4_NOME"))
		OLE_SetDocumentVar(oWord,"cArea",NGSEEK("STD",STJ->TJ_CODAREA,1,"TD_NOME"))
		OLE_SetDocumentVar(oWord,"cTipo",NGSEEK("STE",STJ->TJ_TIPO,1,"TE_NOME"))
		OLE_SetDocumentVar(oWord,"dManAnt"," --/--/--")
		OLE_SetDocumentVar(oWord,"cSequencia",STJ->TJ_SEQRELA)
	EndIf

	/**** TAREFAS ****/
	If lPreventiva

		dbSelectArea("STL")
		dbSetOrder(01)
		dbSeek(xFilial("STL")+STJ->TJ_ORDEM+STJ->TJ_PLANO,.T.)
		While !Eof() .And. STL->TL_FILIAL == xFilial("STL") .And. STL->TL_ORDEM == STJ->TJ_ORDEM .And. STL->TL_PLANO == STJ->TJ_PLANO

			If AllTrim(STL->TL_SEQRELA) == "0"

				dbSelectArea( 'ST5' )
				dbSetOrder( 1 ) // T5_FILIAL + T5_CODBEM + T5_SERVICO + T5_SEQRELA + T5_TAREFA
				If dbSeek( xFilial( 'ST5' ) + STJ->TJ_CODBEM + STJ->TJ_SERVICO + STJ->TJ_SEQRELA + STL->TL_TAREFA )
					cSequen := cValToChar( StrZero( ST5->T5_SEQUENC, TamSX3( 'T5_SEQUENC' )[1] ) )
				Else
					cSequen := Space( Len( (cAliT)->SEQUEN ) )
				EndIf

				dbSelectArea( cAliT )
				dbSetOrder( 1 ) // T5_SEQUENC + T5_TAREFA
				If !dbSeek( cSequen + STL->TL_TAREFA )

					RecLock( (cAliT), .T. )

						(cAliT)->TAREFA := STL->TL_TAREFA
						(cAliT)->SEQUEN := cSequen

						If Trim( STL->TL_TAREFA ) == '0'
							(cAliT)->DESCRI := STR0017 // Sem Especificação De Tarefa
						Else
							If !Empty( cSequen )
								(cAliT)->DESCRI := ST5->T5_DESCRIC
							Else
								dbSelectArea( 'TT9' )
								dbSetOrder( 1 ) // TT9_FILIAL + TT9_TAREFA
								If dbSeek( xFilial( 'TT9' ) + STL->TL_TAREFA )
									(cAliT)->DESCRI := TT9->TT9_DESCRI
								EndIf
							EndIf
						EndIf

					(cAliT)->( MsUnLock() )

				EndIf
			EndIf
			dbSelectArea("STL")
			dbSkip()
		EndDo

		dbSelectArea("STQ")
		dbSetOrder(1)//TQ_FILIAL+TQ_ORDEM+TQ_PLANO
		dbSeek(xFilial("STQ") + STJ->TJ_ORDEM + STJ->TJ_PLANO )
		While !Eof() .And. STQ->TQ_FILIAL == xFilial("STQ") .And. STQ->TQ_ORDEM == STJ->TJ_ORDEM ;
		.And. STQ->TQ_PLANO == STJ->TJ_PLANO //.And.  STQ->TQ_TAREFA == (cAliT)->TAREFA

			cTarefa := STQ->TQ_TAREFA
			cSequen := cValToChar(STRZERO(NGSEEK("ST5",STJ->TJ_CODBEM + STJ->TJ_SERVICO + STJ->TJ_SEQRELA + cTarefa,1,"T5_SEQUENC"),TAMSX3("T5_SEQUENC")[1]))
			dbSelectArea(cAliT)
			dbSetOrder(01)
			If !dbSeek(cSequen+cTarefa)
				RecLock((cAliT),.T.)
				(cAliT)->TAREFA := cTarefa
				(cAliT)->DESCRI := If (Alltrim(cTarefa) == "0",STR0017,NGSEEK("ST5",STJ->TJ_CODBEM+STJ->TJ_SERVICO+; //"Sem Especificação De Tarefa"
				STJ->TJ_SEQRELA+cTarefa,1,"T5_DESCRIC"))
				(cAliT)->SEQUEN := cSequen
				MsUnLock(cAliT)
			EndIf

			dbSelectArea("STQ")
			dbSkip()
		End

	Else
		If lTT9
			dbSelectArea("STL")
			dbSetOrder(01)
			dbSeek(xFilial("STL")+STJ->TJ_ORDEM+STJ->TJ_PLANO,.T.)
			While !Eof() .And. STL->TL_FILIAL == xFilial("STL") .And. STL->TL_ORDEM == STJ->TJ_ORDEM .And. STL->TL_PLANO == STJ->TJ_PLANO
				If AllTrim(STL->TL_SEQRELA) == "0"
					dbSelectArea(cAliT)
					dbSetOrder(01)
					// Campo (cAliT)->SEQUEN é sempre vazio nesse caso, por isso a chave depende apenas da TL_TAREFA.
					If !dbSeek(Space(Len((cAliT)->SEQUEN)) + STL->TL_TAREFA)
						RecLock((cAliT),.T.)
						(cAliT)->TAREFA := STL->TL_TAREFA
						(cAliT)->DESCRI := NGSEEK("TT9",STL->TL_TAREFA,1,"TT9_DESCRI")
						MsUnLock(cAliT)
					EndIf
				EndIf
				dbSelectArea("STL")
				dbSkip()
			EndDo
			dbSelectArea("STQ")
			dbSetOrder(01)
			dbSeek(xFilial("STQ")+STJ->TJ_ORDEM+STJ->TJ_PLANO,.T.)
			While !Eof() .And. STQ->TQ_FILIAL == xFilial("STQ") .And. STQ->TQ_ORDEM == STJ->TJ_ORDEM .And. STQ->TQ_PLANO == STJ->TJ_PLANO
				dbSelectArea(cAliT)
				dbSetOrder(01)
				// Campo (cAliT)->SEQUEN é sempre vazio nesse caso, por isso a chave depende apenas da TL_TAREFA.
				If !dbSeek(Space(Len((cAliT)->SEQUEN)) + STQ->TQ_TAREFA)
					RecLock((cAliT),.T.)
					(cAliT)->TAREFA := STQ->TQ_TAREFA
					(cAliT)->DESCRI := NGSEEK("TT9",STQ->TQ_TAREFA,1,"TT9_DESCRI")
					MsUnLock(cAliT)
				EndIf
				dbSelectArea("STQ")
				dbSkip()
			EndDo
		Else
			RecLock((cAliT),.T.)
			(cAliT)->TAREFA := "0"
			(cAliT)->DESCRI := STR0013 //"Não existe tarefa especificada"
			MsUnLock(cAliT)
		EndIf
	EndIf

	dbSelectArea(cAliT)
	dbGoTop()
	While !Eof()

		/**** ETAPAS ****/
		dbSelectArea("STQ")
		dbSetOrder(1)//TQ_FILIAL+TQ_ORDEM+TQ_PLANO
		dbSeek(xFilial("STQ") + STJ->TJ_ORDEM + STJ->TJ_PLANO + (cAliT)->TAREFA)
		While !Eof() .And. STQ->TQ_FILIAL == xFilial("STQ") .And. STQ->TQ_ORDEM == STJ->TJ_ORDEM ;
		.And. STQ->TQ_PLANO == STJ->TJ_PLANO .And. STQ->TQ_TAREFA == (cAliT)->TAREFA

			/**** OPCOES DA ETAPA ****/
			dbSelectArea("TPA")
			dbSetOrder(01)
			If dbSeek(xFilial("TPA")+STQ->TQ_ETAPA)

				dbSelectArea("TPC")
				dbSetOrder(01)
				If dbSeek(xFilial("TPC")+TPA->TPA_ETAPA)

					While TPC->TPC_FILIAL == xFilial("TPC") .And. TPC->TPC_ETAPA == TPA->TPA_ETAPA
						dbSelectArea(cAliE)
						dbSetOrder(01)
						RecLock((cAliE),.T.)
						(cAliE)->TAREFA := STQ->TQ_TAREFA
						(cAliE)->ETAPA  := STQ->TQ_ETAPA
						(cAliE)->DESCRI := TPA->TPA_DESCRI
						(cAliE)->OPCAO  := TPC->TPC_OPCAO
						(cAliE)->SEQUEN := STQ->TQ_SEQETA

						MsUnLock(cAliE)
						dbSelectArea("TPC")
						dbSkip()
					EndDo

				Else
					dbSelectArea(cAliE)
					dbSetOrder(01)
					RecLock((cAliE),.T.)
					(cAliE)->TAREFA	:= STQ->TQ_TAREFA
					(cAliE)->ETAPA	:= STQ->TQ_ETAPA
					(cAliE)->DESCRI	:= TPA->TPA_DESCRI
					(cAliE)->SEQUEN	:= STQ->TQ_SEQETA
					MsUnLock(cAliE)
				EndIf
			EndIf
			dbSelectArea("STQ")
			dbSkip()
		End While

		/**** MAO DE OBRA E ESPECIALIDADE ****/
		dbSelectArea("STL")
		Set Filter To STL->TL_FILIAL = xFilial("STL") .And. STL->TL_ORDEM = STJ->TJ_ORDEM .And. STL->TL_PLANO = STJ->TJ_PLANO .And.;
		STL->TL_TAREFA = (cAliT)->TAREFA .And. STL->TL_TIPOREG $ "ME"
		dbGoTop()
		dbSetOrder(01)
		dbSeek(xFilial("STL")+STJ->TJ_ORDEM+STJ->TJ_PLANO+(cAliT)->TAREFA)

		While !Eof() .And. STL->TL_FILIAL == xFilial("STL") .And. STL->TL_ORDEM == STJ->TJ_ORDEM .And. STL->TL_PLANO == STJ->TJ_PLANO .And.;
		STL->TL_TAREFA == (cAliT)->TAREFA .And. STL->TL_TIPOREG $ "ME"

			If AllTrim(STL->TL_SEQRELA) == "0"
				dbSelectArea(cAliD)
				dbSetOrder(01)
				RecLock((cAliD),.T.)
				(cAliD)->TAREFA  := (cAliT)->TAREFA
				(cAliD)->TIPOREG := STL->TL_TIPOREG
				(cAliD)->CODIGO  := STL->TL_CODIGO
				If STL->TL_TIPOREG == "M"
					(cAliD)->NOMECOD := NGSEEK("ST1",STL->TL_CODIGO,1,"T1_NOME")
				ElseIf STL->TL_TIPOREG == "E"
					(cAliD)->NOMECOD := NGSEEK("ST0",STL->TL_CODIGO,1,"T0_NOME")
				EndIf
				(cAliD)->QUANREC := STL->TL_QUANREC
				(cAliD)->QUANTID := STL->TL_QUANTID
				(cAliD)->UNIDADE := STL->TL_UNIDADE
				(cAliD)->DTINICI := STL->TL_DTINICI
				(cAliD)->HOINICI := STL->TL_HOINICI
				(cAliD)->DTFIM   := STL->TL_DTFIM
				(cAliD)->HOFIM   := STL->TL_HOFIM
				MsUnLock(cAliD)
			EndIf

			dbSelectArea("STL")
			dbSkip()

		EndDo

		dbSelectArea("STL")
		Set Filter To

		/**** PRODUTOS - FERRAMENTAS - TERCEIROS****/
		dbSelectArea("STL")
		Set Filter To STL->TL_FILIAL = xFilial("STL") .And. STL->TL_ORDEM = STJ->TJ_ORDEM .And. STL->TL_PLANO = STJ->TJ_PLANO .And.;
		STL->TL_TAREFA = (cAliT)->TAREFA .And. STL->TL_TIPOREG $ "TFP"
		dbGoTop()
		dbSetOrder(01)
		dbSeek(xFilial("STL")+STJ->TJ_ORDEM+STJ->TJ_PLANO+(cAliT)->TAREFA)

		While !Eof() .And. STL->TL_FILIAL == xFilial("STL") .And. STL->TL_ORDEM == STJ->TJ_ORDEM .And. STL->TL_PLANO == STJ->TJ_PLANO .And.;
		STL->TL_TAREFA == (cAliT)->TAREFA .And. STL->TL_TIPOREG $ "TFP"

			If AllTrim(STL->TL_SEQRELA) == "0"
				dbSelectArea(cAliD)
				dbSetOrder(01)
				RecLock((cAliD),.T.)
				(cAliD)->TAREFA  := (cAliT)->TAREFA
				(cAliD)->TIPOREG := STL->TL_TIPOREG
				(cAliD)->CODIGO  := STL->TL_CODIGO
				If STL->TL_TIPOREG == "F"
					(cAliD)->NOMECOD := NGSEEK("SH4",STL->TL_CODIGO,1,"H4_DESCRI")
				ElseIf STL->TL_TIPOREG == "P"
					(cAliD)->NOMECOD := NGSEEK("SB1",STL->TL_CODIGO,1,"B1_DESC")
				ElseIf STL->TL_TIPOREG == "T" //Terceiros
					(cAliD)->NOMECOD := NGSEEK("SA2",AllTrim(STL->TL_CODIGO),1,"A2_NOME")
				EndIf
				(cAliD)->QUANTID := STL->TL_QUANTID
				(cAliD)->UNIDADE := STL->TL_UNIDADE
				MsUnLock(cAliD)
			EndIf

			dbSelectArea("STL")
			dbSkip()

		EndDo

		dbSelectArea("STL")
		Set Filter To

		/**** PREVISAO INICIO/FIM  ****/
		//Trecho baseado no fonte MNTR675 (utilizacao da variavel aARTAREFAS)
		aPrevDtHr := {}
		dbSelectArea("STL")
		dbSetOrder(01)
		dbSeek(xFilial("STL")+STJ->TJ_ORDEM+STJ->TJ_PLANO+(cAliT)->TAREFA,.T.)
		While !Eof() .And. STL->TL_FILIAL == xFilial("STL") .And. STL->TL_ORDEM == STJ->TJ_ORDEM .And.;
		STL->TL_PLANO == STJ->TJ_PLANO .And. STL->TL_TAREFA == (cAliT)->TAREFA

			If Empty(aPrevDtHr)
				aPrevDtHr := {STL->TL_DTINICI,STL->TL_HOINICI,STL->TL_DTFIM,STL->TL_HOFIM}
			Else
				If STL->TL_DTINICI < aPrevDtHr[1]
					aPrevDtHr[1] := STL->TL_DTINICI
					aPrevDtHr[2] := STL->TL_HOINICI
				ElseIf STL->TL_DTINICI == aPrevDtHr[1] .And. STL->TL_HOINICI < aPrevDtHr[2]
					aPrevDtHr[2] := STL->TL_HOINICI
				EndIf
				If STL->TL_DTFIM > aPrevDtHr[3]
					aPrevDtHr[3] := STL->TL_DTFIM
					aPrevDtHr[4] := STL->TL_HOFIM
				ElseIf STL->TL_DTFIM == aPrevDtHr[3] .And. STL->TL_HOFIM > aPrevDtHr[4]
					aPrevDtHr[4] := STL->TL_HOFIM
				EndIf
			EndIf

			If AllTrim(STL->TL_SEQRELA) == "0"
				dbSelectArea(cAliT)
				RecLock((cAliT),.F.)
				(cAliT)->DTPINI  := aPrevDtHr[1]
				(cAliT)->HRPINI  := aPrevDtHr[2]
				(cAliT)->DTPFIM  := aPrevDtHr[3]
				(cAliT)->HRPFIM  := aPrevDtHr[4]
				MsUnLock(cAliT)
			EndIf

			dbSelectArea("STL")
			dbSkip()

		EndDo

		dbSelectArea(cAliT)
		dbSkip()

	EndDo

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M050ETAPA ³ Autor ³ Felipe N. Welter      ³ Data ³ 07/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processa as Etapas da Tarefa da Ordem de Servico            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MNTR050IMP                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M050ETAPA()

	//Cria linhas para Etapas
	dbSelectArea(cAliE)
	dbSetOrder(01)
	dbSeek((cAliT)->TAREFA,.T.)
	nEtapas := 0
	nLinOri := 7
	nLinDes := 9
	While !Eof() .And. (cAliE)->TAREFA == (cAliT)->TAREFA

		nEtapas++
		OLE_SetDocumentVar(oWord,"cVar",AllTrim(STR(nLinOri))+"#"+AllTrim(STR(nLinDes))+"#"+AllTrim(STR(nTarefas)))
		OLE_ExecuteMacro(oWord,"CopiaLinha")
		nLinOri++
		nLinDes++
		dbSelectArea(cAliE)
		dbSkip()

	EndDo

	ProcRegua(nEtapas)
	//Preenche as linhas de Etapas criadas
	nLin := 7
	nCol := 1
	dbSelectArea(cAliE)
	dbSetOrder(01)
	dbSeek((cAliT)->TAREFA,.T.)
	While !Eof() .And. (cAliE)->TAREFA == (cAliT)->TAREFA
		IncProc()
		MNT050WORD(" "+(cAliE)->ETAPA,nLin,nCol,nTarefas)
		If !Empty((cAliE)->OPCAO)
			MNT050WORD(" "+AllTrim((cAliE)->DESCRI)+" - "+AllTrim((cAliE)->OPCAO),nLin,nCol+1,nTarefas)
		Else
			MNT050WORD(" "+AllTrim((cAliE)->DESCRI),nLin,nCol+1,nTarefas)
		EndIf
		nLin++
		dbSelectArea(cAliE)
		dbSkip()
	EndDo

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M050MDOESP³ Autor ³ Felipe N. Welter      ³ Data ³ 07/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processa as MDO e Especialid. da Tarefa da Ordem de Servico ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MNTR050IMP                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M050MDOESP()

	//Cria linhas para 'MDO e Especialidade'
	dbSelectArea(cAliD)
	Set Filter To (cAliD)->TAREFA = (cAliT)->TAREFA .And. (cAliD)->TIPOREG $ "ME"
	dbSetOrder(01)
	dbGoTop()
	nDetME := 0
	nLinOri := 12 + nEtapas
	nLinDes := 14 + nEtapas
	While !Eof()

		nDetME++
		OLE_SetDocumentVar(oWord,"cVar",AllTrim(STR(nLinOri))+"#"+AllTrim(STR(nLinDes))+"#"+AllTrim(STR(nTarefas)))
		OLE_ExecuteMacro(oWord,"CopiaLinha")
		nLinOri++
		nLinDes++
		dbSelectArea(cAliD)
		dbSkip()

	EndDo
	dbSelectArea(cAliD)
	Set Filter To

	ProcRegua(nDetME)
	//Preenche as linhas de 'MDO e Especialidade' criadas
	nLin := 12 + nEtapas
	nCol := 1
	dbSelectArea(cAliD)
	Set Filter To (cAliD)->TAREFA = (cAliT)->TAREFA .And. (cAliD)->TIPOREG $ "ME"
	dbSetOrder(01)
	dbSeek((cAliT)->TAREFA,.T.)
	While !Eof() .And. (cAliD)->TAREFA == (cAliT)->TAREFA
		IncProc()
		MNT050WORD((cAliD)->CODIGO,nLin,nCol,nTarefas)
		MNT050WORD(AllTrim((cAliD)->NOMECOD),nLin,nCol+1,nTarefas)
		MNT050WORD(AllTrim(STR((cAliD)->QUANREC)),nLin,nCol+2,nTarefas)
		MNT050WORD(AllTrim(STR((cAliD)->QUANTID)),nLin,nCol+3,nTarefas)
		MNT050WORD(AllTrim((cAliD)->UNIDADE),nLin,nCol+4,nTarefas)
		MNT050WORD(AllTrim(DTOC((cAliD)->DTINICI)),nLin,nCol+5,nTarefas)
		MNT050WORD(AllTrim((cAliD)->HOINICI),nLin,nCol+6,nTarefas)
		MNT050WORD(AllTrim(DTOC((cAliD)->DTFIM)),nLin,nCol+7,nTarefas)
		MNT050WORD(AllTrim((cAliD)->HOFIM),nLin,nCol+8,nTarefas)
		nLin++
		dbSelectArea(cAliD)
		dbSkip()
	EndDo
	dbSelectArea(cAliD)
	Set Filter To

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M050PROFER³ Autor ³ Felipe N. Welter      ³ Data ³ 07/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processa Produtos e Ferramentas da Tarefa da O.S.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MNTR050IMP                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M050PROFER()

	//Cria linhas para 'Produtos, Ferramentas e Terceiros'
	dbSelectArea(cAliD)
	Set Filter To (cAliD)->TAREFA = (cAliT)->TAREFA .And. (cAliD)->TIPOREG $ "TPF"
	dbSetOrder(01)
	dbGoTop()
	nDetPF := 0
	nLinOri := 17 + nEtapas + nDetME
	nLinDes := 19 + nEtapas + nDetME
	While !Eof()

		nDetPF++
		OLE_SetDocumentVar(oWord,"cVar",AllTrim(STR(nLinOri))+"#"+AllTrim(STR(nLinDes))+"#"+AllTrim(STR(nTarefas)))
		OLE_ExecuteMacro(oWord,"CopiaLinha")
		nLinOri++
		nLinDes++
		dbSelectArea(cAliD)
		dbSkip()

	EndDo
	dbSelectArea(cAliD)
	Set Filter To

	ProcRegua(nDetPF)
	//Preenche as linhas de 'Produtos e Ferramentas' criadas
	nLin := 17 + nEtapas + nDetME
	nCol := 1
	dbSelectArea(cAliD)
	Set Filter To (cAliD)->TAREFA = (cAliT)->TAREFA .And. (cAliD)->TIPOREG $ "TPF"
	dbSetOrder(01)
	dbSeek((cAliT)->TAREFA,.T.)
	While !Eof() .And. (cAliD)->TAREFA == (cAliT)->TAREFA
		IncProc()
		If (cAliD)->TIPOREG == "P" //PRODUTO
			MNT050WORD((STR0014),nLin,nCol,nTarefas) //"PROD"
		ElseIf (cAliD)->TIPOREG == "F" // FERRAMENTA
			MNT050WORD((STR0015),nLin,nCol,nTarefas) //"FERR"
		ElseIf (cAliD)->TIPOREG == "T" // TERCEIRO
			MNT050WORD((STR0016),nLin,nCol,nTarefas) //"TERC"
		EndIf
		MNT050WORD(AllTrim((cAliD)->CODIGO)+" ",nLin,nCol+1,nTarefas)
		MNT050WORD(" "+AllTrim((cAliD)->NOMECOD),nLin,nCol+2,nTarefas)
		MNT050WORD(AllTrim(STR((cAliD)->QUANTID)),nLin,nCol+3,nTarefas)
		MNT050WORD(AllTrim((cAliD)->UNIDADE),nLin,nCol+4,nTarefas)
		nLin++
		dbSelectArea(cAliD)
		dbSkip()
	EndDo
	dbSelectArea(cAliD)
	Set Filter To

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNT050WORD³ Autor ³ Felipe N. Welter      ³ Data ³ 07/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz a inclusao das informacoes variaveis (que nao estao as-³±±
±±³          ³sociadas com variaveis de documento.                        ³±±
±±³          ³ Obs: Para esta rotina e' utilizada uma variavel oculta no  ³±±
±±³          ³documento, que recebe os parametros em forma de string, e   ³±±
±±³          ³decompoem utilizando as macros do Word.                     ³±±
±±³          ³Obs: Começa na terceira tabela, para retroceder, informar   ³±±
±±³          ³numeros negativos                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³1.cTxt - Texto a ser jogado no documento                    ³±±
±±³          ³2.nLinha - Linha dentro da tabela                           ³±±
±±³          ³3.nColuna - Coluna dentro da tabela                         ³±±
±±³          ³4.nTabela - Tabela em que sera colocado o texto             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MNTR050                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT050WORD(cTxt,nLinha,nColuna,nTabela)

	cLinha		:= AllTrim(STR(nLinha))
	cColuna	:= AllTrim(STR(nColuna))
	cTabela	:= AllTrim(STR(nTabela))

	OLE_SetDocumentVar(oWord,"cVar",cTxt+"#"+cLinha+"#"+cColuna+"#"+cTabela)
	OLE_ExecuteMacro(oWord,"Cria_Texto")

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNT050LOGO³ Autor ³ Felipe N. Welter      ³ Data ³ 07/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o caminho utilizado pelo sistema para localizar a  ³±±
±±³          ³imagem de logotipo da empresa.                              ³±±
±±³          ³ Obs: O nome do arquivo de logotipo e': LGLR99.BMP, sendo 99³±±
±±³          ³o numero da empresa corrente.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MNTR050, MNTR120                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*Function MNR050LOGO(lRootPath)

Local cBARRAS		:= If(isSRVunix(),"/","\")
Local cRootPath	:= Alltrim(GetSrvProfString("RootPath",cBARRAS))
Local cStartPath	:= AllTrim(GetSrvProfString("StartPath",cBARRAS))
Private cDirExe	:= cRootPath+cStartPath
Private cLogo		:= NGLOCLOGO()

Default lRootPath := .T.

cLogo := cStartPath+"LGRL"+SM0->M0_CODIGO+SM0->M0_CODFIL+".BMP" // Empresa+Filial
If !File(cLogo)
If File(cStartPath+"LGRL"+SM0->M0_CODIGO+".BMP")
cLogo := cStartPath+"LGRL"+SM0->M0_CODIGO+".BMP" // Empresa
ElseIf File(cDIREXE+"LGRL"+SM0->M0_CODIGO+SM0->M0_CODFIL+".BMP") .And. lRootPath
cLogo := cDIREXE+"LGRL"+SM0->M0_CODIGO+SM0->M0_CODFIL+".BMP"
ElseIf File(cDIREXE+"LGRL"+SM0->M0_CODIGO+".BMP")	 .And. lRootPath
cLogo := cDIREXE+"LGRL"+SM0->M0_CODIGO+".BMP"
ElseIf File("LGRL"+SM0->M0_CODIGO+SM0->M0_CODFIL+".BMP")
cLogo := "LGRL"+SM0->M0_CODIGO+SM0->M0_CODFIL+".BMP"
ElseIf File("LGRL"+SM0->M0_CODIGO+".BMP")
cLogo := "LGRL"+SM0->M0_CODIGO+".BMP"
ElseIf File("\SIGAADV\LGRL"+SM0->M0_CODIGO+SM0->M0_CODFIL+".BMP")
cLogo := "\SIGAADV\LGRL"+SM0->M0_CODIGO+SM0->M0_CODFIL+".BMP"
ElseIf File("\SIGAADV\LGRL"+SM0->M0_CODIGO+".BMP")
cLogo := "\SIGAADV\LGRL"+SM0->M0_CODIGO+".BMP"
Endif
Endif

Return If(lRootPath,cRootPath+cLogo,cLogo)*/

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT050CO
Consistência do Nome do Arquivo

@param   cCont: indica o conteúdo digitado para o nome do arquivo
@author  Diego de Oliveira
@since   27/02/2017
@return  Boolean lRet: conforme validação
@version MP12
/*/
//---------------------------------------------------------------------
Function MNT050CO(cCont)

	Local lRet := .F.
	Local cRootPath := ""
	Local cBarraSrv := If(isSRVunix(),"/","\") //servidor eh da familia Unix (linux, solaris, free-bsd, hp-ux, etc.)

	cRootPath := GetPvProfString( GetEnvServer(), "RootPath", "ERROR", GetADV97() )
	cRootPath := IF( RIGHT(cRootPath,1) == cBarraSrv,SubStr(cRootPath,1,Len(cRootPath)-1), cRootPath)

	If ":/" $ cCont .Or. ":\" $ cCont
		MsgStop(STR0019 + cRootPath+cBarraSrv+"SPOOL" + "") //"Caminho inválido, digite o nome do arquivo que será salvo na pasta "
	Else
		lRet := .T.
	EndIf

Return lRet
