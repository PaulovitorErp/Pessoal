#INCLUDE "Protheus.ch"
#INCLUDE "VKey.ch"
#INCLUDE "MsGraphi.ch"
#INCLUDE "MProject.ch"
#INCLUDE "MNTC755.CH"

#DEFINE _ENTER			Chr(13)+Chr(10) //Enter (pular a linha)
#DEFINE _COR_PREVIS		CLR_GREEN //Cor dos Previstos
#DEFINE _COR_REALIZ		CLR_BLUE //Cor dos Realizados
#DEFINE _ATRASO			"ZZZ0" //Identificador de Atrasos
#DEFINE _COR_ATRASO		CLR_RED //Cor dos Atrasos
#DEFINE _PROJEC			"ZZZ1" //Identificador de Projecoes
#DEFINE _COR_PROJEC		RGB(176,196,222) //Cor das Projecoes

/* Implementacoes Futuras para a Consulta de O.S.

( ) - Integracao com QNC -> procure por 'FNC' ou futura' no codigo fonte (sem as aspas)
( ) - Implementar legenda Numerica, de acordo com a configuracao do Usuario -> um exmeplo de funcao que faz isto e' a FWChkColors( aCores )
( ) - Fazer o Protheus MNT tratar a relacao entre Especialidade x Mao de Obra, e nao somente deixar um chuncho nesta Consulta (procure pela palavra 'chuncho')
( ) - Descomentar o 'SETKEY' do F5 (Atualizacao da Consulta). Mas para isso, deve ser implementado no NGBEGINPRM um meio de armazenar e devolver os teclas utilizadas.

*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMNTC755   บAutor  ณWagner S. de Lacerdaบ Data ณ  28/02/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consulta de Ordem de Servico.                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบTabelas   ณ SB1 - Descricao Generica do Produto                        บฑฑ
ฑฑบ          ณ SB2 - Saldos Fisico e Financeiro                           บฑฑ
ฑฑบ          ณ SC1 - Solicitacao de Compra                                บฑฑ
ฑฑบ          ณ SC2 - Ordens de Producao                                   บฑฑ
ฑฑบ          ณ SC7 - Pedidos de Compra                                    บฑฑ
ฑฑบ          ณ SCP - Solicitacoes ao Armazem                              บฑฑ
ฑฑบ          ณ SD1 - Itens da NF de Entrada                               บฑฑ
ฑฑบ          ณ SF1 - Cabecalho das NF's de Entrada                        บฑฑ
ฑฑบ          ณ SH9 - Bloqueios e Excecoes                                 บฑฑ
ฑฑบ          ณ ST5 - Tarefas da Manutencao                                บฑฑ
ฑฑบ          ณ STA - Problemas com Ordens de Servico                      บฑฑ
ฑฑบ          ณ STV - Problemas com Ordens de Servico (Historico)          บฑฑ
ฑฑบ          ณ STJ - Ordens de Servico de Manutencao                      บฑฑ
ฑฑบ          ณ STS - Ordens de Servico de Manutencao (Historico)          บฑฑ
ฑฑบ          ณ STK - Bloqueio de Funcionario                              บฑฑ
ฑฑบ          ณ STL - Detalhes da Ordem de Servico                         บฑฑ
ฑฑบ          ณ STT - Detalhes da Ordem de Servico (Historico)             บฑฑ
ฑฑบ          ณ STN - Ocorrencias Retorno Manutencao                       บฑฑ
ฑฑบ          ณ STU - Ocorrencias Retorno Manutencao (Historico)           บฑฑ
ฑฑบ          ณ STQ - Etapas Executadas                                    บฑฑ
ฑฑบ          ณ STX - Etapas Executadas (Historico)                        บฑฑ
ฑฑบ          ณ TPA - Etapas Genericas                                     บฑฑ
ฑฑบ          ณ TPC - Opcoes das Etapas Genericas                          บฑฑ
ฑฑบ          ณ TPL - Motivos Atraso O.S.                                  บฑฑ
ฑฑบ          ณ TQ6 - Motivos Atraso O.S. (Historico)                      บฑฑ
ฑฑบ          ณ TPQ - Opcoes das Etapas da O.S.                            บฑฑ
ฑฑบ          ณ TQB - Solicitacao de Servico                               บฑฑ
ฑฑบ          ณ TT9 - Tarefa Generica                                      บฑฑ
ฑฑบ          ณ TTC - Sintomas da Ordem de Servico                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cOrdem -> Opcional;                                        บฑฑ
ฑฑบ          ณ           Indica a Ordem de Servico (via clique da direita)บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบObservacaoณ O Gantt das Tarefas esta sendo apresentado na forma de     บฑฑ
ฑฑบ          ณ linha de tempo - Grid. Portanto, seu nome como objeto e'   บฑฑ
ฑฑบ          ณ definido como Grid de Tarefas, porem, para apresentacao em บฑฑ
ฑฑบ          ณ tela, chamaremos de Gantt de Tarefas, devido a semelhanca  บฑฑ
ฑฑบ          ณ e, especialmente, pelo fato de poder exportar para o       บฑฑ
ฑฑบ          ณ MsProject. Ou seja, para esta rotina, Grid == Gantt.       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Durante a criacao desta rotina de consulta, o Protheus nao บฑฑ
ฑฑบ          ณ tratava a relacao de Insumo Realizado com a Especialidade, บฑฑ
ฑฑบ          ณ ou seja, para insumos realizados de mao de obra, nao era   บฑฑ
ฑฑบ          ณ possivel saber de qual especialidade era o funcionario.    บฑฑ
ฑฑบ          ณ Nisto, a qualidade pediu um chuncho, para esta consulta    บฑฑ
ฑฑบ          ณ considerar uma das especialidades relacionadas ao funcio-  บฑฑ
ฑฑบ          ณ nario. Entao, evite modificar muito a estrutura da arvore eบฑฑ
ฑฑบ          ณ de como os dados sao recebidos, pois tudo isto e' chuncho, บฑฑ
ฑฑบ          ณ e se nao tiver certeza do que esta' fazendo, muitas outras บฑฑ
ฑฑบ          ณ funcionalidades podem deixar de funcionar corretamente.    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ * Por que estou citando os Ajustes Tecnicos? (chunchos)    บฑฑ
ฑฑบ          ณ R: Simples. E' para o desenvolvedor que for implementar /  บฑฑ
ฑฑบ          ณ prestar manutencao nesta rotina se ATENTAR aos detalhes    บฑฑ
ฑฑบ          ณ muito particulares desta consulta, e que fique em mente queบฑฑ
ฑฑบ          ณ para resolver o que parece ser um problema pontual, pode   บฑฑ
ฑฑบ          ณ ter impacto em mais de 500 linhas de codigo, devido a uma  บฑฑ
ฑฑบ          ณ coisa estar atrelada a outra. Portanto, ATENCAO.           บฑฑ
ฑฑบ          ณ Um problema que pode estar ocorrendo com um calculo, ou a  บฑฑ
ฑฑบ          ณ projecao, por exmeplo, pode paracer bobo, facil de corrigirบฑฑ
ฑฑบ          ณ e testar, mas tenha ciencia de que esta "simples" alteracaoบฑฑ
ฑฑบ          ณ pode influenciar TODOS os outros calculos / projecoes, sem บฑฑ
ฑฑบ          ณ nem mesmo que voce saiba! Tudo que se pede e': ATENCAO.    บฑฑ
ฑฑบ          ณ Obrigado, tenha um bom dia.                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAMNT                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC755(cOrdem)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Armazena variaveis p/ devolucao (NGRIGHTCLICK)                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aNGBEGINPRM := {}

	Local nCorIntro
	Local oFont1Norm, oFont1Bold, oFont2

	//Variaveis de outra tela (normalmente ira' existir quando esta Consulta for chamada por outra rotina, como por exemplo, via clique da direita)
	Local aOldChoice := Nil, aOldGets := Nil, aOldTela := Nil

	Default cOrdem := ""

	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 19, 95 )

		aNGBEGINPRM := NGBEGINPRM()

		Private oDlgIntro, oBmpIntro, oMeter
		Private oSayIntro1, oSayIntro2, oSayMeter, oSayVersao
		Private nMeter, nMeterTot

		Private aAreaIni   := GetArea()
		Private aRotina    := aClone(MenuDef())
		Private cCadastro  := OemToAnsi(STR0006) //"Consulta de O.S."
		Private cPerg      := "MNC755"
		Private cTabela    := "STJ"
		Private cDirTemp   := AllTrim(GetTempPath())
		Private cDirDic    := "\"+CurDir()
		Private cDirBarra  := If(IsSrvUnix(), "/", "\")
		Private cImgPXR    := "MNTC755PXR.bmp"
		Private cImgOSXS   := "MNTC755OSXS.bmp"
		Private lSintomas  := NGCADICBASE("TTC_FILIAL","A","TTC",.F.)
		Private lPerMDO    := NGCADICBASE("TL_PERMDOE","A","STL",.F.)

		Private lUsaTarPad := NGUSATARPAD() //Usa Tarefa Generica?
		Private lUsaIntEst := (AllTrim(SuperGetMv("MV_NGMNTES", .F., .F., "N")) == "S")
		Private lUsaIntCom := (AllTrim(SuperGetMv("MV_NGMNTCM", .F., .F., "N")) == "S")
		//Private lUsaIntFNC := (AllTrim(SuperGetMv("MV_NGMNTQN", .F., .F., "N")) == "S") - Possivel implementacao futura, Integracao com QNC (Nao Conformidade)
		Private lUsaIntERP := (lUsaIntEst .Or. lUsaIntCom)//Variavel para indicar se a Integracao com o ERP esta habilitada ou nao

		Private cTRBIns    := GetNextAlias(), oTmpTRBIns
		Private cTRBEta    := GetNextAlias(), oTmpTRBEta
		Private cTRBOco    := GetNextAlias(), oTmpTRBOco
		Private cTRBMot    := GetNextAlias(), oTmpTRBMot
		Private cTRBPro    := GetNextAlias(), oTmpTRBPro
		Private cTRBSin    := GetNextAlias(), oTmpTRBSin

		Private aSize      := MsAdvSize(.T.) //.T. - Tem EnchoiceBar
		Private nLargura   := 0
		Private nAltura    := 0

		nAltura  := aSize[6]
		nLargura := aSize[5]

		//Considera as Barras '\' ou '/' no diretorio temporario
		If SubStr(cDirTemp,Len(cDirTemp),1) <> cDirBarra
			cDirBarra += cDirBarra
		EndIf

		INCLUI := .F.
		ALTERA := .F.

		//Variaveis de outra tela
		If Type("aChoice") == "A"
			aOldChoice := aClone( aChoice )
			aChoice := Nil
		EndIf
		If Type("aGets") == "A"
			aOldGets := aClone( aGets )
			aGets := Nil
		EndIf
		If Type("aTela") == "A"
			aOldTela := aClone( aTela )
			aTela := Nil
		EndIf

		//+------------------+
		//| Inicio           |
		//+------------------+
		nMeter    := 0
		nMeterTot := 6

		nCorIntro := RGB(0, 74, 119)

		oFont1Norm := TFont():New("Arial", , 16, , .F., , , , , , .T.)
		oFont1Bold := TFont():New("Arial", , 24, , .T., , , , , , .T.)
		oFont2 := TFont():New( , , 12)

		DEFINE MSDIALOG oDlgIntro FROM 005,005 TO 415,690 COLOR CLR_BLACK,CLR_WHITE OF oMainWnd PIXEL ;
		STYLE nOr(DS_SYSMODAL,WS_MAXIMIZEBOX,WS_POPUP)

		oBmpIntro := TBitmap():New(0, 0, 20, 20, , "ng_intro_consultaos", .T., , , , .F., .F., , , .T., , .F., , .F.)
		oBmpIntro:lTransparent := .F.
		oBmpIntro:Align := CONTROL_ALIGN_ALLCLIENT

		oSayIntro1 := TSay():New(144, 162, {|| OemToAnsi(STR0088)}, oBmpIntro, , oFont1Norm, , ; //"Consulta de"
		, , .T., nCorIntro, , 150, 030)

		oSayIntro2 := TSay():New(150, 135, {|| OemToAnsi(STR0261)}, oBmpIntro, , oFont1Bold, , ; //"Ordem de Servi็o"
		, , .T., nCorIntro, , 150, 030)

		oSayMeter := TSay():New(180, 130, {|| OemToAnsi(STR0103)+"..."}, oBmpIntro, , , , ; //"Iniciando Programa"
		, , .T., CLR_RED, , 150, 030)

		oMeter := TMeter():New(194, 128, {|u| If(PCount() > 0, nMeter := u, nMeter)},;
		100, oBmpIntro, 100, 008, , .T.)
		oMeter:SetTotal(nMeterTot)
		oMeter:Set(nMeter)
		oMeter:SetCSS("QProgressBar {margin:0px; background-color:#CDD1D4; border: 1px solid #CDD1D4;")

		ACTIVATE MSDIALOG oDlgIntro ON INIT ( Eval({|| MNTC755OS(cOrdem)}),oDlgIntro:End() ) CENTERED

		//Devolve as variaveis da tela anterior (caso existam)
		If ValType(aOldChoice) == "A"
			aChoice := aClone( aOldChoice )
		EndIf
		If ValType(aOldGets) == "A"
			aGets := aClone( aOldGets )
		EndIf
		If ValType(aOldTela) == "A"
			aTela := aClone( aOldTela )
		EndIf

		//+-----------------------------------------------------------------------+
		//| Devolve variaveis armazenadas (NGRIGHTCLICK)                          |
		//+-----------------------------------------------------------------------+
		NGRETURNPRM(aNGBEGINPRM)

		RestArea(aAreaIni)
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMenuDef   บAutor  ณWagner S. de Lacerdaบ Data ณ  28/02/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Utilizacao de Menu Funcional.                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Array com opcoes da rotina.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ  Parametros do array a Rotina:                             บฑฑ
ฑฑบ          ณ  1. Nome a aparecer no cabecalho                           บฑฑ
ฑฑบ          ณ  2. Nome da Rotina associada                               บฑฑ
ฑฑบ          ณ  3. Reservado                                              บฑฑ
ฑฑบ          ณ  4. Tipo de Transacao a ser efetuada:                      บฑฑ
ฑฑบ          ณ      1 - Pesquisa e Posiciona em um Banco de Dados         บฑฑ
ฑฑบ          ณ      2 - Simplesmente Mostra os Campos                     บฑฑ
ฑฑบ          ณ      3 - Inclui registros no Bancos de Dados               บฑฑ
ฑฑบ          ณ      4 - Altera o registro corrente                        บฑฑ
ฑฑบ          ณ      5 - Remove o registro corrente do Banco de Dados      บฑฑ
ฑฑบ          ณ 5. Nivel de acesso                                         บฑฑ
ฑฑบ          ณ 6. Habilita Menu Funcional                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()

	Local aRot

	aRot := {{ STR0001, "AxPesqui"  , 0 , 1},;    //"Pesquisar"
	{ STR0002, "NGCAD01"   , 0 , 2},;    //"Visualizar"
	{ STR0003, "NGCAD01"   , 0 , 3},;    //"Incluir"
	{ STR0004, "NGCAD01"   , 0 , 4},;    //"Alterar"
	{ STR0005, "NGCAD01"   , 0 , 5, 3}	} //"Excluir"

Return aRot

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ SECAO: PRINCIPAL - INICIO                                             บฑฑ
ฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMNTC755OS บAutor  ณWagner S. de Lacerdaบ Data ณ  28/02/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta a tela da Consulta de O.S.                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cOrdem -> Opcional;                                        บฑฑ
ฑฑบ          ณ           Indica a Ordem de Servico (via clique da direita)บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC755OS(cOrdem)

	Local aCOSColors := {}

	Local oPanelTot
	//Verifica se existe o PE MNTC7551
	Local lMNTC7551 := ExistBlock("MNTC7551")

	Default cOrdem := ""

	/* Variaveis da Janela */
	Private aAreaOS   := {}
	Private aAreaSoli := {}

	Private nCorText, nCorBack

	Private nCtrlsIni, nCtrlsFim
	/**/

	/* Variaveis Padroes da Rotina */
	Private oDlgCOS, oBlackPnl
	Private oCOSMenu
	Private oFontNorm, oFontBold
	Private oConteudo, oSplitter

	Private aCOSBtns   := {}
	Private bCOSOk     := {|| }
	Private bCOSCancel := {|| }

	Private lCOSIsProc := .T. //Define que a Consulta de O.S. esta' processando
	Private dCOSDtIni  := dDataBase //Data em que a Consulta de O.S. foi iniciada ou a Ordem de Servico selecionada
	Private cCOSHrIni  := SubStr(Time(),1,5) //Hora em que a Consulta de O.S. foi iniciada ou a Ordem de Servico selecionada
	/**/

	/* Variaveis do Cabecalho */
	Private oCabec, oXumbaFoco
	Private cOS, oOS, cOldOS
	Private cBemLoc, cNomBemLoc, oBemLoc, oNomBemLoc
	Private cPlano, oPlano
	Private cPriorid, oPriorid
	Private cServico, oServico
	Private cTipoOS, cSolici, cSequencia
	Private lOSTermino, lOSCorret, lOSCancela
	Private oBtnStat
	/**/

	/* Variaveis do Grid de Tarefas */
	Private oDlgGrdTar
	Private oGrdTit
	Private oGrdPnlAll, oGrdPnlLef, oGrdPnlCen
	Private oGrdBorda, oGrdBtnInf, oGrdBtnLgd, oGrdSplit

	Private oTree, oMnuTree
	Private aTreeOS, aTreeTar, aTreeTip, aTreeIns, aTreeSubIns
	Private oGrdTar   , oGrdTarGrp
	Private cGrdTAtuCo, oGrdTAtuCo, cGrdTAtuNo, oGrdTAtuNo
	Private dGrdTAtuD1, oGrdTAtuD1, cGrdTAtuH1, oGrdTAtuH1
	Private dGrdTAtuD2, oGrdTAtuD2, cGrdTAtuH2, oGrdTAtuH2
	Private cGrdTAtuDe, oGrdTAtuDe
	Private oLegendGrd, oBtnGrdRe1, oBtnGrdRe2, oBtnGrdRe3, oBtnGrdRe4, oBtnGrdRe5, oBtnGrdRe6, oBtnGrdRe7, oBtnGrdRe8

	Private oGrdPnlGrd
	Private aGrdIns, aGrdTips, aGrdTars
	Private oGrdGrafic, aGrdGrafic
	Private nGrdResolu, nGrdZoom, dGrdDtIni, dGrdSetDt, dGrdDtMin, dGrdDtMax
	Private aGrdLinClk
	Private aCritico //Armazena todo o caminho critico da O.S., por isso o nome de sua varial e' mais global (nao possui o Grd como prefixo)
	Private aPercOS, aPercTars, aPercTips, aPercIns, aPercSubIns //Armazena os Percentuais de Conclusao (nao possui o Grd como prefixo)
	/**/

	/* Variaveis das Informacoes da O.S. */
	Private oDlgInfo
	Private oBtnInfo01, oBtnInfo02, oBtnInfo03, oBtnInfo04, oBtnInfo05
	Private oBtnImp
	Private oInfPnlTop, cInfPnlTop
	Private oInfPnlLef, oInfPnlCen
	Private oPnlHideInfo, oBtnHideInfo
	/**/

	/* Variaveis da Info 01 - Dados Cadastrais */
	Private oI1PnlPai
	Private oI1PnlFol
	Private oI1Folder , aI1Folder, aI1Pages

	Private oI1Gerais , aI1Gerais
	Private oI1Manuten, aI1Manuten
	Private oI1Complem, aI1Complem
	/**/

	/* Variaveis da Info 02 - Custos */
	Private oI2PnlPai
	Private oI2PnlFol
	Private oI2Folder , aI2Folder, aI2Pages

	Private oI2BrwCust
	Private aI2Custos , aI2HeaCus, aI2SizCus

	Private aI2DadosP , aI2DadosR
	Private oI2GrfPXR , lI2ViuPXR
	Private nI2SerieP := 0, nI2SerieR  := 0
	Private oI2BtnTar
	Private lI2CarTar, lI2TarClik
	Private aI2DadosOS, aI2DadosSe
	Private oI2GrfOSXS, lI2ViuOSXS, oI2DadOSXS
	Private nI2SerieOS := 0, nI2SerieSe := 0
	Private oI2BtnHist
	Private cI2ParItem, dI2ParDtDe, dI2ParDtAt
	/**/

	/* Variaveis da Info 03 - Detalhes */
	Private oI3PnlPai
	Private oI3PnlFol , oI3TitFol
	Private oI3Folder , aI3Folder , aI3Pages

	Private oI3PnlIns , oI3TitIns
	Private oI3PnlInsP, oI3GetInsP
	Private oI3PnlInsR, oI3GetInsR
	Private aI3HeadIns
	Private aI3DetInsP, aI3DetInsR

	Private oI3EtaLeft, oI3BtnVis
	Private oI3GetEta , aI3HeadEta
	Private aI3DetEta
	Private oI3GetOco , aI3HeadOco
	Private aI3DetOco
	Private oI3GetMot , aI3HeadMot
	Private aI3DetMot
	Private oI3GetPro , aI3HeadPro
	Private aI3DetPro
	If lSintomas
		Private oI3GetSin , aI3HeadSin
		Private aI3DetSin
	EndIf
	/**/

	/* Variaveis da Info 04 - Solicitacao de Servico */
	Private oI4PnlPai
	Private oI4Solicit, aI4Solicit
	/**/

	/* Variaveis da Info 05 - Informacoes ERP */
	If lUsaIntERP //Usa Integracao com ERP?
		Private oI5PnlPai
		Private oI5PnlFol
		Private oI5Folder , aI5Folder, aI5Pages

		Private oI5PnlDoc, oI5LeftDoc, oI5BtnVDoc, oI5BtnLDoc
		Private oI5BrwDoc, aI5HeadDoc, aI5SizeDoc, oI5SayDoc
		Private aI5ERPDoc, bI5LineDoc
		Private oI5PnlCom, oI5LeftCom, oI5BtnVCom, oI5BtnLCom
		Private oI5BrwCom, aI5HeadCom, aI5SizeCom, oI5SayCom
		Private aI5ERPCom, bI5LineCom
		Private oI5PnlArm, oI5LeftArm, oI5BtnVArm, oI5BtnLArm
		Private oI5BrwArm, aI5HeadArm, aI5SizeArm, oI5SayArm
		Private aI5ERPArm, bI5LineArm
	EndIf
	/**/

	//SETKEY(VK_F5, {|| MNTC755BTN(1) }) //F5: Atualiza a Tela - funcao MNTC755ATU()

	MNTC755TRB() //Cria as tabelas temporarias

	//Introducao
	nMeter++
	oMeter:Set(nMeter)
	oSayMeter:SetText(OemToAnsi(STR0104)+"...") //"Carregando Variแveis"
	oSayMeter:CtrlRefresh()

	MNTC755INI() //Inicializa as variaveis

	aI1Gerais  := aClone(MNTC755MON(10))
	aI1Manuten := aClone(MNTC755MON(11))
	aI1Complem := aClone(MNTC755MON(12))
	aI2Custos  := aClone(MNTC755MON(2))
	aI3DetInsP := aClone(MNTC755MON(30))
	aI3DetInsR := aClone(MNTC755MON(30))
	aI3DetEta  := aClone(MNTC755MON(31))
	aI3DetOco  := aClone(MNTC755MON(32))
	aI3DetMot  := aClone(MNTC755MON(33))
	aI3DetPro  := aClone(MNTC755MON(34))
	If lSintomas
		aI3DetSin  := aClone(MNTC755MON(35))
	EndIf
	aI4Solicit := aClone(MNTC755MON(4))
	If lUsaIntERP //Usa Integracao com ERP?
		aI5ERPDoc  := aClone(MNTC755MON(50))
		aI5ERPCom  := aClone(MNTC755MON(51))
		aI5ERPArm  := aClone(MNTC755MON(52))
	EndIf

	aI1Folder  := {STR0012, STR0013, STR0014} //"Gerais"###"Manuten็ใo"###"Complementares"
	aI1Pages   := aClone(aI1Folder)
	aI2Folder  := {STR0200 + " " + STR0015, STR0217 + " " + STR0015, STR0217 + " " + STR0016} //"Insumos Previstos x Realizados"###"Grแfico Previstos x Realizados"###"Grแfico O.S. x Hist๓rico"
	aI2Pages   := aClone(aI2Folder)
	aI3Folder  := {STR0200, STR0017, STR0018, STR0019, STR0020} //"Insumos"###"Etapas"###"Ocorr๊ncias"###"Motivos de Atraso"###"Problemas"
	If lSintomas
		aAdd(aI3Folder, STR0021) //"Sintomas"
	EndIf
	aI3Pages   := aClone(aI3Folder)
	aI5Folder  := {STR0052, STR0054, STR0056} //"Documentos de Entrada"###"Solicita็๕es de Compra"###"Solicita็๕es ao Armaz้m"
	aI5Pages   := aClone(aI5Folder)

	oFontNorm  := TFont():New("Verdana", , 14, .T., .F.)
	oFontBold  := TFont():New("Verdana", , 14, .T., .T.)

	aCOSColors := aClone( NGCOLOR("10") )
	nCorText := aCOSColors[1] //RGB(0,0,128)
	nCorBack := aCOSColors[2] //RGB(67,70,87)

	aCOSBtns   := {}
	aAdd(aCOSBtns, { "reload"        , {|| MNTC755BTN(1)}, OemToAnsi(STR0041), OemToAnsi(STR0218) }) //"Atualizar O.S."###"Atualizar"
	aAdd(aCOSBtns, { "ng_ico_legenda", {|| MNTC755BTN(2,1)}, OemToAnsi(STR0042), OemToAnsi(STR0132) }) //"Legenda do Status da O.S."###"Legenda"
	//Ponto de entrada que adiciona botใo เ enchoice bar (Outras A็๕es)
	If lMNTC7551
		aCOSBtns := ExecBlock("MNTC7551",.F.,.F.,{aCOSBtns})
	EndIf

	bCOSOk     := {|| MNTC755SAI()}
	bCOSCancel := {|| MNTC755SAI()}

	//Introducao
	nMeter++
	oMeter:Set(nMeter)
	oSayMeter:SetText(OemToAnsi(STR0194)+"...") //"Carregando Objetos"
	oSayMeter:CtrlRefresh()

	DEFINE MSDIALOG oDlgCOS TITLE cCadastro FROM aSize[7],0 TO aSize[6],aSize[5] COLOR CLR_BLACK, CLR_WHITE OF oMainWnd PIXEL

	oDlgCOS:lEscClose := .F.

	oDlgCOS:lMaximized := .T.

	//Cria Painel para adequa็ใo da tela.
	oPanelTot := TPanel():New(0,0,,oDlgCOS,,,,,,0,0,.F.,.F.)
	oPanelTot:Align := CONTROL_ALIGN_ALLCLIENT

	//+------------------+
	//| Cabecalho        |
	//+------------------+
	oCabec := TPanel():New(01, 01, , oPanelTot, , , , CLR_BLACK, CLR_WHITE, 50, 35)
	oCabec:Align := CONTROL_ALIGN_TOP

	//O.S.
	@ 005,012 SAY OemToAnsi(STR0022) FONT oFontBold COLOR CLR_BLACK OF oCabec PIXEL //"Ordem de Servi็o:"
	oOS := TGet():New(004, 080, {|u| If(PCount() > 0, cOS := u, cOS)}, oCabec, 040, 008, "@!", {|| If(!IsInCallStack("MNTC755VOS") .And. MNTC755VOS(),RegToMemory(cTabela,.F.),.F.) }, CLR_BLACK, CLR_WHITE, oFontNorm,;
	.F., , .T./*lPixel*/, , .F., {|| If(Empty(cOrdem),.T.,.F.) }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "MNTOS", "cOS", , , , .T./*lHasButton*/)
	oOS:bHelp := {|| ShowHelpCpo(STR0023,; //"O.S."
	{STR0024},2,; //"Ordem de Servi็o."
	{},2)}
	//Campo utilizado apenas para chumbar o foco para fora do campo de O.S., executando assim o seu 'Valid'.
	oXumbaFoco := TGet():New(004, 1000+nLargura, {|| }, oCabec, 040, 008, "@!", {|| }, CLR_BLACK, CLR_WHITE, oFontNorm,;
	.F., , .T./*lPixel*/, , .F., {|| .T. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "", , , , /*lHasButton*/)

	//Plano
	@ 005,140 SAY OemToAnsi(STR0025) FONT oFontNorm COLOR CLR_BLACK OF oCabec PIXEL //"Plano:"
	oPlano := TGet():New(004, 170, {|| cPlano}, oCabec, 040, 008, "@!", , CLR_BLACK, , oFontNorm,;
	.F., , .T., , .F., {|| .F. }, .F., .F., , .F., .F., , "cPlano")
	oPlano:bHelp := {|| ShowHelpCpo(STR0026,; //"Plano"
	{STR0027},2,; //"Plano da Ordem de Servi็o."
	{},2)}

	//Prioridade
	@ 005,220 SAY OemToAnsi(STR0028) FONT oFontNorm COLOR CLR_BLACK OF oCabec PIXEL //"Prioridade:"
	oPriorid := TGet():New(004, 260, {|| cPriorid}, oCabec, 020, 008, "@!", , CLR_BLACK, , oFontNorm,;
	.F., , .T., , .F., {|| .F. }, .F., .F., , .F., .F., , "cPriorid")
	oPriorid:bHelp := {|| ShowHelpCpo(STR0029,; //"Prioridade"
	{STR0030},2,; //"Prioridade da Ordem de Servi็o."
	{},2)}

	//Servico
	@ 005,290 SAY OemToAnsi(STR0031) FONT oFontNorm COLOR CLR_BLACK OF oCabec PIXEL //"Servi็o:"
	oServico := TGet():New(004, 320, {|| cServico}, oCabec, 040, 008, "@!", , CLR_BLACK, , oFontNorm,;
	.F., , .T., , .F., {|| .F. }, .F., .F., , .F., .F., , "cServico")
	oServico:bHelp := {|| ShowHelpCpo(STR0032,; //"Servi็o"
	{STR0033},2,; //"C๓digo do Servi็o da Ordem de Servi็o."
	{},2)}

	//Status
	@ 005,370 SAY OemToAnsi(STR0034) FONT oFontNorm COLOR CLR_BLACK OF oCabec PIXEL //"Status:"
	oBtnStat := TBtnBmp2():New(008, 790, 20, 20, "BR_BRANCO", , , , {|| MNTC755BTN(2,1)}, oCabec, OemToAnsi(STR0035)) //"Status da O.S."

	//Bem/Localizacao
	@ 020,012 SAY OemToAnsi(STR0036) FONT oFontNorm COLOR CLR_BLACK OF oCabec PIXEL //"Bem/Localiza็ใo:"
	oBemLoc := TGet():New(019, 080, {|| cBemLoc}, oCabec, 080, 008, "@!", , CLR_BLACK, , oFontNorm,;
	.F., , .T., , .F., {|| .F. }, .F., .F., , .F., .F., , "cBemLoc")
	oBemLoc:bHelp := {|| ShowHelpCpo(STR0037,; //"Bem/Localizacao"
	{STR0038},2,; //"C๓digo do Bem/Localiza็ใo da Ordem de Servi็o."
	{},2)}
	//Nome do Bem/Localizacao
	oNomBemLoc := TGet():New(019, 170, {|| cNomBemLoc}, oCabec, 230, 008, "@!", , CLR_BLACK, , oFontNorm,;
	.F., , .T., , .F., {|| .F. }, .F., .F., , .F., .F., , "cNomBemLoc")
	oNomBemLoc:bHelp := {|| ShowHelpCpo(STR0039,; //"Nome do Bem/Localiza็ใo"
	{STR0040},2,; //"Nome do Bem/Localiza็ใo da Ordem de Servi็o."
	{},2)}

	//+------------------+
	//| Conteudo         |
	//+------------------+
	//--- Conteudo da Tela
	oConteudo := TPanel():New(01, 01, , oPanelTot, , , , CLR_WHITE, CLR_WHITE, 12, 50)
	oConteudo:Align := CONTROL_ALIGN_ALLCLIENT

	//+------------------+
	//| Splitter         |
	//+------------------+
	//--- Splitter da Tela
	oSplitter := TSplitter():New(01, 01, oConteudo, 10, 10)
	oSplitter:SetOrient(1)
	oSplitter:Align := CONTROL_ALIGN_ALLCLIENT

	//------------------------------------------------------------------------------------------------------------------------//
	//------------------------------------------------------------------------------------------------------------------------//

	//Introducao
	nMeter++
	oMeter:Set(nMeter)

	//ษออออออออออออออออออป
	//บ Grafico - Tarefasบ
	//ศออออออออออออออออออผ
	//--- Painel Principal do Grid de Tarefas (deve ocupar 50% da tela)
	oDlgGrdTar := TPanel():New(01, 01, , oSplitter, , , , CLR_BLACK, CLR_WHITE, 12, (oSplitter:nClientHeight * 0.50))
	oDlgGrdTar:Align := CONTROL_ALIGN_ALLCLIENT

	//--- Titulo da Tarefa do Grid de Tarefas
	oGrdTit := TPanel():New(01, 01, , oDlgGrdTar, oFontBold, .F., , CLR_BLACK, nCorBack, 100, 10)
	oGrdTit:Align := CONTROL_ALIGN_TOP
	TSay():New(02, 12, {|| OemToAnsi(STR0059)}, oGrdTit, , oFontBold, , ; //"Gantt de Tarefas"
	, ,.T., CLR_WHITE, nCorBack, 150, 010)

	//--- Painel TOTAL do Grid de Tarefas
	oGrdPnlAll := TPanel():New(0, 0, , oDlgGrdTar, , , , CLR_BLACK, CLR_WHITE, 50, 50)
	oGrdPnlAll:Align := CONTROL_ALIGN_ALLCLIENT

	//--- Painel Esquerdo do Grid de Tarefas (Alocado para as Tarefas e Insumos da O.S.)
	oGrdPnlLef := TPanel():New(0, 0, , oGrdPnlAll, , , , CLR_BLACK, CLR_WHITE, If(nLargura > 1000,120,100), 20)
	oGrdPnlLef:Align := CONTROL_ALIGN_LEFT

	//--- Painal do Split da Arvore
	oGrdSplit := TPanel():New(01, 01, , oGrdPnlAll, , , , CLR_BLACK, CLR_WHITE, 5, 12)
	oGrdSplit:Align := CONTROL_ALIGN_LEFT

	//Botao de Split da Arvore
	oGrdSplitB := TBtnBmp2():New(01, 01, 05, 05, "fw_arrow_left", , , , {|| fShowHide(1)}, oGrdSplit, OemToAnsi(STR0290), , .T.) //"Esconder มrvore"
	oGrdSplitB:Align := CONTROL_ALIGN_ALLCLIENT

	//--- Painel Direito do Grid de Tarefas (tendo como titulo - ao topo - a sua tarefa selecionada)
	oGrdPnlCen := TPanel():New(0, 0, , oGrdPnlAll, , , , CLR_BLACK, CLR_WHITE, 100, 20)
	oGrdPnlCen:Align := CONTROL_ALIGN_ALLCLIENT

	//------------------------------------------------------------------------------------------------------------------------//

	//ษออออออออออออออออออป
	//บ Borda - Grafico  บ
	//ศออออออออออออออออออผ
	//--- Painel da Borda Esquerda
	oGrdBorda := TPanel():New(01, 01, , oDlgGrdTar, , , , CLR_WHITE, nCorBack, 12, 50)
	oGrdBorda:Align := CONTROL_ALIGN_LEFT

	//Botao de Informacoes da O.S.
	oGrdBtnInf := TBtnBmp2():New(01, 01, 27, 30, "ng_ico_info", , , , {|| MNTC755BTN(9)}, oGrdBorda, OemToAnsi(STR0243)) //"Informa็๕es da O.S."
	oGrdBtnInf:Align := CONTROL_ALIGN_TOP

	//Botao de Legenda da Arvore
	oGrdBtnLgd := TBtnBmp2():New(01, 01, 27, 30, "ng_ico_lgndos", , , , {|| MNTC755BTN(2,2)}, oGrdBorda, OemToAnsi(STR0299)) //"Legenda da มrvore"
	oGrdBtnLgd:Align := CONTROL_ALIGN_TOP

	//------------------------------------------------------------------------------------------------------------------------//

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Arvore de Tarefas do Grid   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//--- Arvore das Tarefas e Insumos da Ordem de Servico
	oTree := DbTree():New(01, 01, 200, 100, oGrdPnlLef, , , .T.)
	oTree:bChange   := {|| fGrdTar(.T.)}
	oTree:bRClicked := {|oObject,nPosX,nPosY| fGrdDefMnu(),oMnuTree:Activate( fGrdDefMnu("x", nPosX), fGrdDefMnu("y", nPosY), oTree ) }
	oTree:Align := CONTROL_ALIGN_ALLCLIENT

	//------------------------------------------------------------------------------------------------------------------------//

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Tarefa Selecionada          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//--- Painel da Tarefa do Grid de Tarefas
	oGrdTar := TPanel():New(0, 0, , oGrdPnlCen, , , , CLR_BLACK, CLR_WHITE, 50, 35)
	oGrdTar:Align := CONTROL_ALIGN_TOP

	//--- Grupo Container das Propriedades do Item (campos do Item selecionado)
	oGrdTarGrp := TGroup():New(01, 01, 10, 10, , oGrdTar, , , .T.)
	oGrdTarGrp:Align := CONTROL_ALIGN_ALLCLIENT

	//Codigo do Item Atual do Grid de Tarefas
	@ 005,25 SAY OemToAnsi(STR0061) FONT oFontNorm COLOR CLR_BLACK OF oGrdTar PIXEL //"C๓digo:"
	oGrdTAtuCo := TGet():New(004, 055, {|| cGrdTAtuCo}, oGrdTar, 120, 008, "@!", , CLR_BLACK, , oFontNorm,;
	.F., , .T., , .F., {|| .T. }, .F., .F., , .T., .F., , "cGrdTAtuCo")
	oGrdTAtuCo:bHelp := {|| ShowHelpCpo(STR0062,; //"Codigo do Item"
	{STR0063},2,; //"C๓digo do Item selecionado do Gantt."
	{},2)}

	//Nome do Item Atual do Grid de Tarefas
	@ 005,185 SAY OemToAnsi(STR0064) FONT oFontNorm COLOR CLR_BLACK OF oGrdTar PIXEL //"Nome:"
	oGrdTAtuNo := TGet():New(004, 210, {|| cGrdTAtuNo}, oGrdTar, 140, 008, "@!", , CLR_BLACK, , oFontNorm,;
	.F., , .T., , .F., {|| .T. }, .F., .F., , .T., .F., , "cGrdTAtuNo")
	oGrdTAtuNo:bHelp := {|| ShowHelpCpo(STR0065,; //"Nome do Item"
	{STR0066},2,; //"Nome do Item selecionado do Gantt."
	{},2)}

	//Inicio do Item Atual do Grid de Tarefas
	@ 020,005 SAY OemToAnsi(STR0077 + " " + STR0067) FONT oFontNorm COLOR CLR_BLACK OF oGrdTar PIXEL //"Previsto"###"Inํcio:"
	oGrdTAtuD1 := TGet():New(019, 055, {|| dGrdTAtuD1}, oGrdTar, 40, 008, "99/99/9999", , CLR_BLACK, , oFontNorm,;
	.F., , .T., , .F., {|| .T. }, .F., .F., , .T., .F., , "dGrdTAtuD1")
	oGrdTAtuD1:bHelp := {|| ShowHelpCpo(STR0068,; //"Data Inicio Prev."
	{STR0069},2,; //"Data Inํcio Prevista do Item selecionado do Gantt."
	{},2)}
	oGrdTAtuH1 := TGet():New(019, 105, {|| cGrdTAtuH1}, oGrdTar, 10, 008, "99:99", , CLR_BLACK, , oFontNorm,;
	.F., , .T., , .F., {|| .T. }, .F., .F., , .T., .F., , "cGrdTAtuH1")
	oGrdTAtuH1:bHelp := {|| ShowHelpCpo(STR0070,; //"Hora Inicio Prev."
	{STR0071},2,; //"Hora Inํcio Prevista do Item selecionado do Gantt."
	{},2)}

	//Fim do Item Atual do Grid de Tarefas
	@ 020,141 SAY OemToAnsi(STR0077 + " " + STR0072) FONT oFontNorm COLOR CLR_BLACK OF oGrdTar PIXEL //"Previsto"###"Fim:"###
	oGrdTAtuD2 := TGet():New(019, 185, {|| dGrdTAtuD2}, oGrdTar, 40, 008, "99/99/9999", , CLR_BLACK, , oFontNorm,;
	.F., , .T., , .F., {|| .T. }, .F., .F., , .T., .F., , "dGrdTAtuD2")
	oGrdTAtuD2:bHelp := {|| ShowHelpCpo(STR0073,; //"Data Fim Prev."
	{STR0074},2,; //"Data Fim Prevista do Item selecionado do Gantt."
	{},2)}
	oGrdTAtuH2 := TGet():New(019, 235, {|| cGrdTAtuH2}, oGrdTar, 10, 008, "99:99", , CLR_BLACK, , oFontNorm,;
	.F., , .T., , .F., {|| .T. }, .F., .F., , .T., .F., , "cGrdTAtuH2")
	oGrdTAtuH2:bHelp := {|| ShowHelpCpo(STR0075,; //"Hora Fim Prev."
	{STR0076},2,; //"Hora Fim Prevista do Item selecionado do Gantt."
	{},2)}

	//Destino do Item Atual do Grid de Tarefas (apenas para Produtos)
	@ 020,275 SAY OemToAnsi(STR0308+":") FONT oFontNorm COLOR CLR_BLACK OF oGrdTar PIXEL //"Destino"
	oGrdTAtuDe := TGet():New(019, 305, {|| cGrdTAtuDe}, oGrdTar, 080, 008, "@!", , CLR_BLACK, , oFontNorm,;
	.F., , .T., , .F., {|| !Empty(cGrdTAtuDe) }, .F., .F., , .T., .F., , "cGrdTAtuDe")
	oGrdTAtuDe:bHelp := {|| ShowHelpCpo(STR0309,; //"Destino do Item"
	{STR0310},2,; //"Destino do Item selecionado no Gantt. (Destino do Produto)"
	{},2)}

	//------------------------------------------------------------------------------------------------------------------------//

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Bordas                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//--- Borda do Grid de Tarefas
	oLegendGrd := TPanel():New(01, 01, , oGrdPnlCen, , , , CLR_BLACK, CLR_WHITE, 12, 15)
	oLegendGrd:Align := CONTROL_ALIGN_BOTTOM

	//Legenda o Grid de Tarefas
	TPanel():New(004, 002, , oLegendGrd, , , , CLR_WHITE, _COR_PREVIS, 10, 5)
	@ 003,015 SAY OemToAnsi("[P] "+STR0077) OF oLegendGrd PIXEL //"Previsto"

	TPanel():New(004, 052, , oLegendGrd, , , , CLR_WHITE, _COR_REALIZ, 10, 5)
	@ 003,065 Say OemToAnsi("[R] "+STR0078) OF oLegendGrd PIXEL //"Realizado"

	TPanel():New(004, 105, , oLegendGrd, , , , CLR_WHITE, _COR_ATRASO, 10, 5)
	@ 003,118 Say OemToAnsi(STR0280) OF oLegendGrd PIXEL //"Atrasado"

	TPanel():New(004, 148, , oLegendGrd, , , , CLR_WHITE, _COR_PROJEC, 10, 5)
	@ 003,161 Say OemToAnsi(STR0079) OF oLegendGrd PIXEL //"Proje็ใo de Conclusใo"

	//Botao de Intervalo Maior
	oBtnGrdRe1 := TBtnBmp2():New(01, 01, 40, 26, "ng_pg_zoom_mais", , , , {|| fGrdBtn(1)}, oLegendGrd, OemToAnsi(STR0080)) //"Intervalo Maior"
	oBtnGrdRe1:Align := CONTROL_ALIGN_RIGHT

	//Botao de Intervalo Menor
	oBtnGrdRe2 := TBtnBmp2():New(01, 01, 40, 26, "ng_pg_zoom_menos", , , , {|| fGrdBtn(2)}, oLegendGrd, OemToAnsi(STR0081)) //"Intervalo Menor"
	oBtnGrdRe2:Align := CONTROL_ALIGN_RIGHT

	//Botao de Avancar para o Ultimo
	oBtnGrdRe3 := TBtnBmp2():New(01, 01, 40, 26, "bottom", , , , {|| fGrdBtn(3)}, oLegendGrd, OemToAnsi(STR0082)) //"ฺltimo"
	oBtnGrdRe3:Align := CONTROL_ALIGN_RIGHT

	//Botao de Avancar
	oBtnGrdRe4 := TBtnBmp2():New(01, 01, 40, 26, "right", , , , {|| fGrdBtn(4)}, oLegendGrd, OemToAnsi(STR0083)) //"Avan็ar"
	oBtnGrdRe4:Align := CONTROL_ALIGN_RIGHT

	//Botao de Setar Data
	dGrdSetDt := dGrdDtIni
	/*oBtnGrdRe5 := TGet():New(01, 01, {|u| If(PCount() > 0, dGrdSetDt := u, dGrdSetDt)}, oLegendGrd, 040, 008, "99/99/9999", , CLR_BLACK, , oFontNorm,;
	.F., , .T., , .F., {|| .T. }, .F., .F., , .F., .F., , "dGrdSetDt")
	oBtnGrdRe5:Align := CONTROL_ALIGN_RIGHT*/

	//Botao de Retroceder
	oBtnGrdRe6 := TBtnBmp2():New(01, 01, 40, 26, "left", , , , {|| fGrdBtn(6)}, oLegendGrd, OemToAnsi(STR0084)) //"Retroceder"
	oBtnGrdRe6:Align := CONTROL_ALIGN_RIGHT

	//Botao de Retroceder para o Primeiro
	oBtnGrdRe7 := TBtnBmp2():New(01, 01, 40, 26, "top", , , , {|| fGrdBtn(7)}, oLegendGrd, OemToAnsi(STR0085)) //"Primeiro"
	oBtnGrdRe7:Align := CONTROL_ALIGN_RIGHT

	//Botao de Exportacao para o MsProject (Microsoft Project)
	oBtnGrdRe8 := TBtnBmp2():New(01, 01, 40, 26, "ng_ico_exportar_project", , , , {|| MNTC755EXP()}, oLegendGrd, OemToAnsi(STR0086)) //"Exportar o Gantt de Tarefas"
	oBtnGrdRe8:Align := CONTROL_ALIGN_RIGHT

	//------------------------------------------------------------------------------------------------------------------------//

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Grid de Tarefas             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//--- Cria o Grid de Tarefas
	oGrdPnlGrd := TPanel():New(0, 0, , oGrdPnlCen, , , , CLR_BLACK, CLR_WHITE, 50, 20)
	oGrdPnlGrd:Align := CONTROL_ALIGN_ALLCLIENT

	MNTC755GRD()

	//------------------------------------------------------------------------------------------------------------------------//

	//--- Painel para Inibir/Exibir as Informacoes da O.S.
	oPnlHideInfo := TPanel():New(0, 0, , oDlgGrdTar, , , , CLR_BLACK, CLR_WHITE, 12, 06)
	oPnlHideInfo:Align := CONTROL_ALIGN_BOTTOM

	//Botao para Inibir/Exibir as Informacoes da O.S.
	oBtnHideInfo := TButton():New(001, 001, OemToAnsi(STR0294+" "+STR0243), oPnlHideInfo, {|| MNTC755BTN(9)},; //"Exibir"###"Informa็๕es da O.S."
	40,10,,,.F.,.T.,.F.,,.F.,,,.F.)
	oBtnHideInfo:SetCSS("QPushButton{ background-color: #F4F4F4; color: #BEBEBE; font-size: 10px; border: 1px solid #D3D3D3; } " +;
	"QPushButton:Focus{ background-color: #FFFAFA; } " +;
	"QPushButton:Hover{ background-color: #F4F4F4; color: #000000; border: 1px solid #D3D3D3; } ")
	oBtnHideInfo:lCanGotFocus := .F.
	oBtnHideInfo:Align := CONTROL_ALIGN_ALLCLIENT

	//------------------------------------------------------------------------------------------------------------------------//
	//------------------------------------------------------------------------------------------------------------------------//

	//Introducao
	nMeter++
	oMeter:Set(nMeter)

	//ษออออออออออออออออออป
	//บ Info da O.S.     บ
	//ศออออออออออออออออออผ
	//--- Painel Principal das Informacoes da O.S. (deve ocupar 50% da tela)
	oDlgInfo := TPanel():New(01, 01, , oSplitter, , , , CLR_BLACK, CLR_WHITE, 12, (oSplitter:nClientHeight * 0.50))
	oDlgInfo:Align := CONTROL_ALIGN_ALLCLIENT

	//--- Painel Topo das Informacoes da O.S. (para Titulo)
	oInfPnlTop := TPanel():New(01, 01, , oDlgInfo, , , , CLR_WHITE, nCorBack, 12, 10)
	oInfPnlTop:Align := CONTROL_ALIGN_TOP
	TSay():New(02, 12, {|| OemToAnsi(STR0243) + ": " + OemToAnsi(cInfPnlTop)}, oInfPnlTop, , oFontBold, , ; //"Informa็๕es da O.S."
	, ,.T., CLR_WHITE, nCorBack, 150, 010)

	//--- Painel Esquerdo das Informacoes da O.S.
	oInfPnlLef := TPanel():New(01, 01, , oDlgInfo, , , , CLR_WHITE, nCorBack, 12, 10)
	oInfPnlLef:Align := CONTROL_ALIGN_LEFT

	//--- Painel Central das Informacoes da O.S.
	oInfPnlCen := TPanel():New(01, 01, , oDlgInfo, , , , CLR_WHITE, CLR_WHITE, 12, 10)
	oInfPnlCen:Align := CONTROL_ALIGN_ALLCLIENT

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Dados Cadastrais             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oBtnInfo01 := TBtnBmp2():New(01, 01, 27, 30, "ng_ico_visualizar", , , , {|| MNTC755BTN(9,1), RegToMemory(cTabela,.F.)}, oInfPnlLef, OemToAnsi(STR0007)) //"Dados Cadastrais"
	oBtnInfo01:Align := CONTROL_ALIGN_TOP

	//Botao: Custos
	oBtnInfo02 := TBtnBmp2():New(01, 01, 27, 30, "ng_ico_custos", , , , {|| MNTC755BTN(9,2)}, oInfPnlLef, OemToAnsi(STR0008)) //"Custos"
	oBtnInfo02:Align := CONTROL_ALIGN_TOP
	oBtnInfo02:Disable() //Botao inicialmente desabilitado

	//Botao: Solicitacao de Servico
	oBtnInfo04 := TBtnBmp2():New(01, 01, 27, 30, "ng_ico_ss", , , , {|| MNTC755BTN(9,4), RegToMemory("TQB",.F.)}, oInfPnlLef, OemToAnsi(STR0010)) //"Solicita็ใo de Servi็o"
	oBtnInfo04:Align := CONTROL_ALIGN_TOP
	oBtnInfo04:Disable() //Botao inicialmente desabilitado

	//Botao: Detalhes da O.S.
	oBtnInfo03 := TBtnBmp2():New(01, 01, 27, 30, "ng_ico_relac", , , , {|| MNTC755BTN(9,3)}, oInfPnlLef, OemToAnsi(STR0009)) //"Detalhes"
	oBtnInfo03:Align := CONTROL_ALIGN_TOP
	oBtnInfo03:Disable() //Botao inicialmente desabilitado

	If lUsaIntERP //Usa Integracao com ERP?
		//Botao: Informacoes ERP
		oBtnInfo05 := TBtnBmp2():New(01, 01, 27, 30, "ng_ico_erp", , , , {|| MNTC755BTN(9,5)}, oInfPnlLef, OemToAnsi(STR0011)) //"Informa็๕es ERP"
		oBtnInfo05:Align := CONTROL_ALIGN_TOP
		oBtnInfo05:Disable() //Botao inicialmente desabilitado
	EndIf

	//Botao de Impressao da O.S.
	oBtnImp := TBtnBmp2():New(01, 01, 27, 30, "ng_ico_imp", , , , {|| MNTC755BTN(3)}, oInfPnlLef, OemToAnsi(STR0043)) //"Imprimir O.S."
	oBtnImp:Align := CONTROL_ALIGN_TOP

	//------------------------------------------------------------------------------------------------------------------------//
	//------------------------------------------------------------------------------------------------------------------------//

	dbSelectArea("STJ")
	PutFileInEof("STJ")
	RegToMemory("STJ",.F.)

	//------------------------------------------------------------------------------------------------------------------------//
	//------------------------------------------------------------------------------------------------------------------------//

	dbSelectArea("TQB")
	PutFileInEOF("TQB")
	RegToMemory("TQB",.F.)

	//------------------------------------------------------------------------------------------------------------------------//

	MNTC755I01() //Dados Cadastrais
	MNTC755I02() //Custos
	MNTC755I03() //Detalhes
	MNTC755I04() //Solicitacao de Servico
	If lUsaIntERP //Usa Integracao com ERP?
		MNTC755I05() //Informacoes ERP
	EndIf

	//------------------------------------------------------------------------------------------------------------------------//

	//Introducao
	nMeter++
	oMeter:Set(nMeter)
	oSayMeter:SetText(OemToAnsi(STR0195)+"...") //"Finalizando Configura็ใo"
	oSayMeter:CtrlRefresh()

	oDlgInfo:Hide()

	//ษออออออออออออออออออป
	//บ Finalizacao      บ
	//ศออออออออออออออออออผ
	//Clique da Direita da Consulta de O.S.
	If Len(aSMenu) > 0
		NGPOPUP(aSMenu, @oCOSMenu, oCabec) //Clique da Direita no Cabecalho
		oCabec:bRClicked:= { |o,x,y| oCOSMenu:Activate(x,y,oCabec)}
	EndIf

	//--- Painel Preto com Transparencia de 70% para ficar por cima da tela
	fBlackPnl(.F.)

	//--- Nao permite que o Dialog do Grid de Tarefas seja fechado
	oSplitter:SetCollapse(oDlgGrdTar, .F.)
	oSplitter:SetOpaqueResize(.F.)

	//--- Carrega a Ordem de Servico caso ja esteja predefinida (exemplo: consulta chamada atraves do clique da direita)
	If !Empty(cOrdem)
		cOS := cOrdem
		MNTC755VOS()
		RegToMemory(cTabela,.F.)
	EndIf

	//--- Seta o Foco Inicial
	oOS:SetFocus()

	//--- Esconde a Introducao
	oBmpIntro:Hide()

	//--- Verifica os Controles da Tela para depois alterar os botoes da EnchoiceBar
	nCtrlsIni := Len(oDlgCOS:aControls)

	ACTIVATE MSDIALOG oDlgCOS ON INIT ( EnchoiceBar(oDlgCOS, bCOSOk, bCOSCancel, , aCOSBtns), fAlterEnch(), lCOSIsProc := .F. )

	// Insumos
	oTmpTRBIns:Delete()
	// Etapas
	oTmpTRBEta:Delete()
	// Ocorrencias
	oTmpTRBOco:Delete()
	// Motivos de Atraso
	oTmpTRBMot:Delete()
	// Problemas
	oTmpTRBPro:Delete()
	// Sintomas
	If lSintomas
		oTmpTRBSin:Delete()
	EndIf

	//Deleta as imagens do grafico dos diretorios
	If File(cDirDic + cImgPXR)
		FErase(cDirDic + cImgPXR)
	EndIf
	If File(cDirTemp + cImgPXR)
		FErase(cDirTemp + cImgPXR)
	EndIf

	If File(cDirDic + cImgOSXS)
		FErase(cDirDic + cImgOSXS)
	EndIf
	If File(cDirTemp + cImgOSXS)
		FErase(cDirTemp + cImgOSXS)
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMNTC755BTNบAutor  ณWagner S. de Lacerdaบ Data ณ  29/04/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Acao dos botoes principais da Consulta de O.S.             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nBtn ---> Obrigatorio;                                     บฑฑ
ฑฑบ          ณ           Define qual o botao acionado.                    บฑฑ
ฑฑบ          ณ nOpcao -> Opcional;                                        บฑฑ
ฑฑบ          ณ           Define a opcao da Informacao da O.S. ou a da     บฑฑ
ฑฑบ          ณ           Legenda.                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC755BTN(nBtn, nOpcao)

	//Se estiver em processo do validacao ainda, entao nao permite o clique em nenhum botao desta funcao
	If IsInCallStack("MNTC755VOS") .Or. lCOSIsProc
		Return .F.
	EndIf

	//Legenda: Nao e' necessario validar a Ordem de Servico para o botao Legenda
	If nBtn <> 2
		If !fSeekOS()[1]
			Return .F.
		EndIf
	EndIf

	fBlackPnl() //Mostra o Painel de Transparencia
	//SETKEY(VK_F5, {|| }) //Desabilita F5

	If nBtn == 1 //Botao de Atualizacao da O.S.
		MNTC755ATU()
	ElseIf nBtn == 2 //Botao de Legenda do Status da O.S.
		Do Case
			Case nOpcao == 1
			fLegendaOS() //Botao de Legenda do Status da O.S.
			Case nOpcao == 2
			fLegendaAr() //Botao de Legenda da Arvore
		EndCase
	ElseIf nBtn == 3 //Impressao da O.S.
		MNTC755IMP()
	ElseIf nBtn == 4 //Botao de Aglutinar/Considerar Tarefas dos Custos
		Processa({|| fI2CarCust(lI2TarClik)}, STR0087) //"Processando Custos da Ordem de Servi็o..."
	ElseIf nBtn == 5 //Botao de Perido do Historico
		fI2ParOSXS()
	ElseIf nBtn == 9 //Botao de Informacoes da O.S.
		MNTC755INF(nOpcao)
	EndIf

	fSetUpdate() //Define a atualizacao da tela

	fBlackPnl(.F.) //Esconde o Painel de Transparencia
	//SETKEY(VK_F5, {|| MNTC755BTN(1) }) //F5: Atualiza a Tela - funcao MNTC755ATU()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMNTC755INFบAutor  ณWagner S. de Lacerdaบ Data ณ  09/06/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta as Informacoes da O.S.                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nOpen -> Opcional;                                         บฑฑ
ฑฑบ          ณ          Indica qual Informacao deve estar visivel.        บฑฑ
ฑฑบ          ณ           0 - Exibir/Inibir as Informacoes da O.S.         บฑฑ
ฑฑบ          ณ           1 - Dados Cadastrais                             บฑฑ
ฑฑบ          ณ           2 - Custos                                       บฑฑ
ฑฑบ          ณ           3 - Detalhes                                     บฑฑ
ฑฑบ          ณ           4 - Solicitacao de Servico                       บฑฑ
ฑฑบ          ณ           5 - Informacoes ERP                              บฑฑ
ฑฑบ          ณ          Default: 0 - Apenas habilita/desabilita as        บฑฑ
ฑฑบ          ณ                       Informacoes da O.S.                  บฑฑ
ฑฑบ          ณ lMuda -> Opcional;                                         บฑฑ
ฑฑบ          ณ          Define se deve mudar a visualizacao da Informacoesบฑฑ
ฑฑบ          ณ          da O.S.                                           บฑฑ
ฑฑบ          ณ          Default: .F. -> Nao muda                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC755INF(nOpen, lMuda)

	Local nX

	Default nOpen := 0
	Default lMuda := .T.

	//Esconde todos os Paineis
	If Type("oI1PnlPai") == "O"
		oI1PnlPai:Hide()
	EndIf
	If Type("oI2PnlPai") == "O"
		oI2PnlPai:Hide()
	EndIf
	If Type("oI3PnlPai") == "O"
		oI3PnlPai:Hide()
	EndIf
	If Type("oI4PnlPai") == "O"
		oI4PnlPai:Hide()
	EndIf
	If Type("oI5PnlPai") == "O"
		oI5PnlPai:Hide()
	EndIf

	Do Case
		Case nOpen == 0
		If lMuda
			If oDlgInfo:lVisible
				oDlgInfo:Hide()
				oBtnHideInfo:SetText( OemToAnsi(STR0294+" "+STR0243) ) //"Exibir"###"Informa็๕es da O.S."
			Else
				oDlgInfo:Show()
				oBtnHideInfo:SetText( OemToAnsi(STR0295+" "+STR0243) ) //"Inibir"###"Informa็๕es da O.S."
			EndIf
		EndIf
		MNTC755INF(1) //Inicializa com os Dados Cadastrais
		Case nOpen == 1 //Dados Cadastrais
		If Type("oI1PnlPai") == "O"
			//Devolve a area da Ordem de Servico
			If Len(aAreaOS) > 0
				RestArea(aAreaOS)
			EndIf

			cInfPnlTop := STR0007 //"Dados Cadastrais"
			oI1PnlPai:Show()
		EndIf
		Case nOpen == 2 //Custos
		If Type("oI2PnlPai") == "O"
			cInfPnlTop := STR0008 //"Custos"
			oI2PnlPai:Show()

			If !oI2Folder:aDialogs[oI2Folder:nOption]:lActive
				For nX := 1 To Len(aI2Pages)
					If oI2Folder:aDialogs[nX]:lActive
						oI2Folder:SetOption(nX)
					EndIf
				Next nX
			EndIf

			fEntraI2Fo()
		EndIf
		Case nOpen == 3 //Detalhes
		If Type("oI3PnlPai") == "O"
			cInfPnlTop := STR0009 // "Detalhes"
			oI3PnlPai:Show()

			If !oI3Folder:aDialogs[oI3Folder:nOption]:lActive
				For nX := 1 To Len(aI3Pages)
					If oI3Folder:aDialogs[nX]:lActive
						oI3Folder:SetOption(nX)
					EndIf
				Next nX
			EndIf

			fEntraI3Fo()
		EndIf
		Case nOpen == 4 //Solicitacao de Servico
		If Type("oI4PnlPai") == "O"
			//Devolve a area da Solicitacao de Servico
			If Len(aAreaSoli) > 0
				RestArea(aAreaSoli)
			EndIf

			cInfPnlTop := STR0010 //"Solicita็ใo de Servi็o"
			oI4PnlPai:Show()
		EndIf
		Case nOpen == 5 //Informacoes ERP
		If Type("oI5PnlPai") == "O"
			cInfPnlTop := STR0011 //"Informa็๕es ERP"
			oI5PnlPai:Show()

			If !oI5Folder:aDialogs[oI5Folder:nOption]:lActive
				For nX := 1 To Len(aI5Pages)
					If oI5Folder:aDialogs[nX]:lActive
						oI5Folder:SetOption(nX)
					EndIf
				Next nX
			EndIf

			fEntraI5Fo()
		EndIf
		Otherwise
		MNTC755INF(,lMuda)
	EndCase

	oTree:SetFocus()
	oDlgInfo:Refresh()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMNTC755I01บAutor  ณWagner S. de Lacerdaบ Data ณ  09/06/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Dados Cadastrais da O.S.                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC755I01()

	Local aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	Local aObjects := {{040,040,.T.,.T.},{100,100,.T.,.T.},{020,020,.T.,.T.}}
	Local aPosObj  := MsObjSize(aInfo, aObjects,.f.)
	Local nX

	//--- Painel Pai
	If Type("oI1PnlPai") <> "O"
		oI1PnlPai := TPanel():New(01, 01, , oInfPnlCen, , , , CLR_WHITE, , 50, 50)
		oI1PnlPai:Align := CONTROL_ALIGN_ALLCLIENT
	Else
		oI1PnlPai:FreeChildren()
	EndIf

	//--- Painel do Folder dos Dados Cadastrais da Ordem de Servico
	oI1PnlFol := TPanel():New(01, 01, , oI1PnlPai, , , , CLR_WHITE, , 50, 50)
	oI1PnlFol:Align := CONTROL_ALIGN_ALLCLIENT

	//--- Folder contendo as Informacoes da Ordem de Servico
	oI1Folder := TFolder():New(01, 01, aI1Folder, aI1Pages, oI1PnlFol, 1, CLR_BLACK, CLR_WHITE, .T., , 1000, 1000)
	oI1Folder:Align := CONTROL_ALIGN_ALLCLIENT

	For nX := 1 To Len(aI1Pages)
		oI1Folder:aDialogs[nX]:oFont := oDlgCOS:oFont
	Next nX

	//------------------------------------------------------------------------------------------------------------------------//

	//--- Dados Genericos da Ordem de Servico
	oI1Gerais := MsMGet():New(cTabela,RecNo(),2,/*aCRA*/,/*cLetras*/,/*cTexto*/,aI1Gerais/*aChoice*/,aPosObj[1]/*aPos*/,/*aCpos*/,;
	3/*nModelo*/,/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oI1Folder:aDialogs[1]/*oDlg*/,/*lF3*/,.T./*lMemoria*/,.F./*lColumn*/,;
	/*caTela*/,/*lNoFolder*/,/*lProperty*/, /*aField*/)
	oI1Gerais:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	//------------------------------------------------------------------------------------------------------------------------//

	//--- Dados da Manutencao da Ordem de Servico
	oI1Manuten := MsMGet():New(cTabela,RecNo(),2,/*aCRA*/,/*cLetras*/,/*cTexto*/,aI1Manuten/*aChoice*/,aPosObj[1]/*aPos*/,/*aCpos*/,;
	3/*nModelo*/,/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oI1Folder:aDialogs[2]/*oDlg*/,/*lF3*/,.T./*lMemoria*/,.F./*lColumn*/,;
	/*caTela*/,/*lNoFolder*/,/*lProperty*/, /*aField*/)
	oI1Manuten:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	//------------------------------------------------------------------------------------------------------------------------//

	//--- Dados Complementares da Ordem de Servico
	oI1Complem := MsMGet():New(cTabela,RecNo(),2,/*aCRA*/,/*cLetras*/,/*cTexto*/,aI1Complem/*aChoice*/,aPosObj[1]/*aPos*/,/*aCpos*/,;
	3/*nModelo*/,/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oI1Folder:aDialogs[3]/*oDlg*/,/*lF3*/,.T./*lMemoria*/,.F./*lColumn*/,;
	/*caTela*/,/*lNoFolder*/,/*lProperty*/, /*aField*/)
	oI1Complem:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	//------------------------------------------------------------------------------------------------------------------------//

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMNTC755I02บAutor  ณWagner S. de Lacerdaบ Data ณ  09/06/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Custos da O.S.                                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC755I02()

	Local oBorda
	Local nX

	//--- Painel Pai
	If Type("oI2PnlPai") <> "O"
		oI2PnlPai := TPanel():New(01, 01, , oInfPnlCen, , , , CLR_WHITE, , 50, 50)
		oI2PnlPai:Align := CONTROL_ALIGN_ALLCLIENT
	Else
		oI2PnlPai:FreeChildren()
	EndIf

	//--- Painel do Folder dos Custos da Ordem de Servico
	oI2PnlFol := TPanel():New(01, 01, , oI2PnlPai, , , , CLR_WHITE, , 50, 50)
	oI2PnlFol:Align := CONTROL_ALIGN_ALLCLIENT

	//--- Folder contendo os Custos da Ordem de Servico
	oI2Folder := TFolder():New(01, 01, aI2Folder, aI2Pages, oI2PnlFol, 1, CLR_BLACK, CLR_WHITE, .T., , 1000, 1000)
	oI2Folder:Align := CONTROL_ALIGN_ALLCLIENT

	For nX := 1 To Len(aI2Pages)
		oI2Folder:aDialogs[nX]:oFont := oDlgCOS:oFont
	Next nX

	oI2Folder:bChange := {|| fEntraI2Fo() }

	//------------------------------------------------------------------------------------------------------------------------//

	//--- Borda Esquerda
	oBorda := TPanel():New(01, 01, , oI2Folder:aDialogs[1], , , , CLR_WHITE, nCorBack, 12, 50)
	oBorda:Align := CONTROL_ALIGN_LEFT

	//Botao de Aglutinar/Considerar Tarefas dos Custos
	oI2BtnTar := TBtnBmp2():New(01, 01, 27, 30, "ng_ico_tarefas02", , , ,;
	{|| MNTC755BTN(4)},;
	oBorda, OemToAnsi(STR0044)) //"Aglutinar Tarefas"
	oI2BtnTar:Align := CONTROL_ALIGN_TOP

	//--- Browse dos Custos da Ordem de Servico consultada (Insumos Previstos x Relizados)
	oI2BrwCust := TWBrowse():New(001, 001, 1000, 1000, , , aI2SizCus,;
	oI2Folder:aDialogs[1], , , , , {|| }, , , , , , , .F., , .T., , .F., , ,)
	For nX := 1 To Len(aI2HeaCus)
		If nX == 6 .Or. nX == 7 .Or. nX == 8 //Custo Previsto/Realizado/Diferenca
			oI2BrwCust:AddColumn(TCColumn():New(aI2HeaCus[nX], &("{|| aI2Custos[oI2BrwCust:nAT]["+cValToChar(nX)+"] }"), "@E 9,999,999.99", , , "RIGHT"))
		ElseIf nX == 9 //Percentual de Variacao
			oI2BrwCust:AddColumn(TCColumn():New(aI2HeaCus[nX], &("{|| aI2Custos[oI2BrwCust:nAT]["+cValToChar(nX)+"] }"), "@E 9999.99", , , "RIGHT"))
		Else
			oI2BrwCust:AddColumn(TCColumn():New(aI2HeaCus[nX], &("{|| aI2Custos[oI2BrwCust:nAT]["+cValToChar(nX)+"] }"), "", , , "LEFT"))
		EndIf
	Next nX
	oI2BrwCust:SetArray(aI2Custos)
	oI2BrwCust:bGotFocus := {|| fAtuI2Fo(@oI2BrwCust) }
	oI2BrwCust:Align := CONTROL_ALIGN_ALLCLIENT

	//------------------------------------------------------------------------------------------------------------------------//

	//--- Grafico de Custos de Insumos Previstos x Realizados
	oI2GrfPXR := TMSGraphic():New(10, 10, oI2Folder:aDialogs[2], , , , 1000, 1000)
	oI2GrfPXR:SetTitle(STR0015, "", CLR_BLUE, A_CENTER, .F.) //"Previstos x Realizados"
	oI2GrfPXR:Align := CONTROL_ALIGN_ALLCLIENT

	//------------------------------------------------------------------------------------------------------------------------//

	//--- Borda Esquerda
	oBorda := TPanel():New(01, 01, , oI2Folder:aDialogs[3], , , , CLR_WHITE, nCorBack, 12, 50)
	oBorda:Align := CONTROL_ALIGN_LEFT

	//Botao de Perido do Historico
	oI2BtnHist := TBtnBmp2():New(01, 01, 27, 30, "ng_ico_historico", , , ,;
	{|| MNTC755BTN(5)},;
	oBorda, OemToAnsi(STR0300)) //"Perํodo"
	oI2BtnHist:Align := CONTROL_ALIGN_TOP

	//Texto que sera' exibido caso nao seja possivel montar este grafico de O.S. x Historico
	oI2DadOSXS := TSay():New(005, 015, {|| OemToAnsi(STR0114)}, oI2Folder:aDialogs[3], , , , ; //"Nใo hแ dados para exibir."
	, , .T., CLR_BLACK, , 150, 030)

	//--- Grafico de Custos do comparativo da O.S. x Historico
	oI2GrfOSXS := TMSGraphic():New(10, 10, oI2Folder:aDialogs[3], , , , 1000, 1000)
	oI2GrfOSXS:SetTitle(STR0016, "", CLR_BLUE, A_CENTER, .F.) //"O.S. x Hist๓rico"
	oI2GrfOSXS:Align := CONTROL_ALIGN_ALLCLIENT

	//------------------------------------------------------------------------------------------------------------------------//

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMNTC755I03บAutor  ณWagner S. de Lacerdaบ Data ณ  09/06/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Detalhes da O.S.                                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC755I03()

	Local nHeader := If(cTabela == "STJ",1,2)

	Local oBorda
	Local nX

	//--- Painel Pai
	If Type("oI3PnlPai") <> "O"
		oI3PnlPai := TPanel():New(01, 01, , oInfPnlCen, , , , CLR_WHITE, , 50, 50)
		oI3PnlPai:Align := CONTROL_ALIGN_ALLCLIENT
	Else
		oI3PnlPai:FreeChildren()
	EndIf

	//--- Painel do Folder dos Custos da Ordem de Servico
	oI3PnlFol := TPanel():New(01, 01, , oI3PnlPai, , , , CLR_WHITE, , 50, 50)
	oI3PnlFol:Align := CONTROL_ALIGN_ALLCLIENT

	//--- Folder contendo os Custos da Ordem de Servico
	oI3Folder := TFolder():New(01, 01, aI3Folder, aI3Pages, oI3PnlFol, 1, CLR_BLACK, CLR_WHITE, .T., , 1000, 1000)
	oI3Folder:Align := CONTROL_ALIGN_ALLCLIENT

	For nX := 1 To Len(aI3Pages)
		oI3Folder:aDialogs[nX]:oFont := oDlgCOS:oFont
	Next nX

	oI3Folder:bChange := {|| fEntraI3Fo() }

	//------------------------------------------------------------------------------------------------------------------------//

	//--- Painel Pai dos Insumos
	oI3PnlIns := TPanel():New(01, 01, , oI3Folder:aDialogs[1], , , , CLR_WHITE, , 50, 50)
	oI3PnlIns:Align := CONTROL_ALIGN_ALLCLIENT

	//--- Splitter da Tela
	oI3SpltIns := TSplitter():New(01, 01, oI3PnlIns, 10, 10)
	oI3SpltIns:SetOrient(0)
	oI3SpltIns:Align := CONTROL_ALIGN_ALLCLIENT

	//--- Painel do Browse de Insumos Previstos
	oI3PnlInsP := TPanel():New(01, 01, , oI3SpltIns, , , , CLR_WHITE, , 50, 10)
	oI3PnlInsP:Align := CONTROL_ALIGN_ALLCLIENT

	//Titulo dos Insumos Previstos da Ordem de Servico
	oI3TitInsP := TPanel():New(01, 01, , oI3PnlInsP, oFontBold, .T., , CLR_WHITE, nCorBack, 100, 10)
	oI3TitInsP:Align := CONTROL_ALIGN_TOP
	TSay():New(02, 05, {|| OemToAnsi(STR0050)}, oI3TitInsP, , oFontBold, , ; //"Insumos Previstos"
	, , .T., CLR_WHITE, nCorBack, 150, 010)

	//Browse dos Insumos Previstos
	oI3GetInsP := MsNewGetDados():New(01, 01, 1000, 1000,;
	0, "AllwaysTrue()", "AllwaysTrue()", , , , 999, "AllwaysTrue()",;
	"AllwaysFalse()", "AllwaysFalse()", oI3PnlInsP, aI3HeadIns[nHeader], aI3DetInsP)
	oI3GetInsP:oBrowse:bGotFocus := {|| fAtuI3Fo(@oI3GetInsP) }
	oI3GetInsP:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	//--- Painel do Browse de Insumos Realizados
	oI3PnlInsR := TPanel():New(01, 01, , oI3SpltIns, , , , CLR_WHITE, , 50, 10)
	oI3PnlInsR:Align := CONTROL_ALIGN_ALLCLIENT

	//Titulo dos Insumos Realizados da Ordem de Servico
	oI3TitInsR := TPanel():New(01, 01, , oI3PnlInsR, oFontBold, .T., , CLR_WHITE, nCorBack, 100, 10)
	oI3TitInsR:Align := CONTROL_ALIGN_TOP
	TSay():New(02, 05, {|| OemToAnsi(STR0051)}, oI3TitInsR, , oFontBold, , ; //"Insumos Realizados"
	, , .T., CLR_WHITE, nCorBack, 150, 010)

	//Browse dos Insumos Realizados
	oI3GetInsR := MsNewGetDados():New(01, 01, 1000, 1000,;
	0, "AllwaysTrue()", "AllwaysTrue()", , , , 999, "AllwaysTrue()",;
	"AllwaysFalse()", "AllwaysFalse()", oI3PnlInsR, aI3HeadIns[nHeader], aI3DetInsR)
	oI3GetInsR:oBrowse:bGotFocus := {|| fAtuI3Fo(@oI3GetInsR) }
	oI3GetInsR:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	//------------------------------------------------------------------------------------------------------------------------//

	//Borda Esquerda das Etapas
	oI3EtaLeft := TPanel():New(01, 01, , oI3Folder:aDialogs[2], , , , CLR_WHITE, nCorBack, 12, 50)
	oI3EtaLeft:Align := CONTROL_ALIGN_LEFT

	//Botao para Visualizar a Etapa
	oI3BtnVis := TBtnBmp2():New(01, 01, 27, 30, "ng_ico_visual", , , , {|| fI3VisEta()}, oI3EtaLeft, OemToAnsi(STR0002), , .T.) //"Visualizar"
	oI3BtnVis:Align := CONTROL_ALIGN_TOP

	//--- Browse das Etapas da Ordem de Servico
	oI3GetEta := MsNewGetDados():New(01, 01, 1000, 1000,;
	0, "AllwaysTrue()", "AllwaysTrue()", , , , 999, "AllwaysTrue()",;
	"AllwaysFalse()", "AllwaysFalse()", oI3Folder:aDialogs[2], aI3HeadEta[nHeader], aI3DetEta)
	oI3GetEta:oBrowse:bGotFocus := {|| fAtuI3Fo(@oI3GetEta) }
	oI3GetEta:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	//------------------------------------------------------------------------------------------------------------------------//

	//--- Browse das Ocorrencias da Ordem de Servico
	oI3GetOco := MsNewGetDados():New(01, 01, 1000, 1000,;
	0, "AllwaysTrue()", "AllwaysTrue()", , , , 999, "AllwaysTrue()",;
	"AllwaysFalse()", "AllwaysFalse()", oI3Folder:aDialogs[3], aI3HeadOco[nHeader], aI3DetOco)
	oI3GetOco:oBrowse:bGotFocus := {|| fAtuI3Fo(@oI3GetOco) }
	oI3GetOco:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	//------------------------------------------------------------------------------------------------------------------------//

	//--- Browse dos Motivos de Atraso da Ordem de Servico
	oI3GetMot := MsNewGetDados():New(01, 01, 1000, 1000,;
	0, "AllwaysTrue()", "AllwaysTrue()", , , , 999, "AllwaysTrue()",;
	"AllwaysFalse()", "AllwaysFalse()", oI3Folder:aDialogs[4], aI3HeadMot[nHeader], aI3DetMot)
	oI3GetMot:oBrowse:bGotFocus := {|| fAtuI3Fo(@oI3GetMot) }
	oI3GetMot:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	//------------------------------------------------------------------------------------------------------------------------//

	//--- Browse dos Problemas da Ordem de Servico
	oI3GetPro := MsNewGetDados():New(01, 01, 1000, 1000,;
	0, "AllwaysTrue()", "AllwaysTrue()", , , , 999, "AllwaysTrue()",;
	"AllwaysFalse()", "AllwaysFalse()", oI3Folder:aDialogs[5], aI3HeadPro[nHeader], aI3DetPro)
	oI3GetPro:oBrowse:bGotFocus := {|| fAtuI3Fo(@oI3GetPro) }
	oI3GetPro:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	//------------------------------------------------------------------------------------------------------------------------//

	If lSintomas
		//--- Browse dos Sintomas da Ordem de Servico
		oI3GetSin := MsNewGetDados():New(01, 01, 1000, 1000,;
		0, "AllwaysTrue()", "AllwaysTrue()", , , , 999, "AllwaysTrue()",;
		"AllwaysFalse()", "AllwaysFalse()", oI3Folder:aDialogs[6], aI3HeadSin, aI3DetSin)
		oI3GetSin:oBrowse:bGotFocus := {|| fAtuI3Fo(@oI3GetSin) }
		oI3GetSin:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	EndIf

	//------------------------------------------------------------------------------------------------------------------------//

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMNTC755I04บAutor  ณWagner S. de Lacerdaบ Data ณ  09/06/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Solicitacao de Servico vinculada na O.S.                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC755I04()

	Local aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	Local aObjects := {{040,040,.T.,.T.},{100,100,.T.,.T.},{020,020,.T.,.T.}}
	Local aPosObj  := MsObjSize(aInfo, aObjects,.f.)

	//--- Painel Pai
	If Type("oI4PnlPai") <> "O"
		oI4PnlPai := TPanel():New(01, 01, , oInfPnlCen, , , , CLR_WHITE, , 50, 50)
		oI4PnlPai:Align := CONTROL_ALIGN_ALLCLIENT
	Else
		oI4PnlPai:FreeChildren()
	EndIf

	//--- Dados da Solicitacao de Servico
	oI4Solicit := MsMGet():New("TQB",RecNo(),2,/*aCRA*/,/*cLetras*/,/*cTexto*/,aI4Solicit/*aChoice*/,aPosObj[1]/*aPos*/,/*aCpos*/,;
	3/*nModelo*/,/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oI4PnlPai/*oDlg*/,/*lF3*/,.T./*lMemoria*/,.F./*lColumn*/,;
	/*caTela*/,/*lNoFolder*/,/*lProperty*/, /*aField*/)
	oI4Solicit:oBox:Align := CONTROL_ALIGN_ALLCLIENT

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMNTC755I04บAutor  ณWagner S. de Lacerdaบ Data ณ  09/06/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Solicitacao de Servico vinculada na O.S.                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC755I05()

	Local nX

	//--- Painel Pai
	If Type("oI5PnlPai") <> "O"
		oI5PnlPai := TPanel():New(01, 01, , oInfPnlCen, , , , CLR_WHITE, , 50, 50)
		oI5PnlPai:Align := CONTROL_ALIGN_ALLCLIENT
	Else
		oI5PnlPai:FreeChildren()
	EndIf

	//--- Painel do Folder dos Custos da Ordem de Servico
	oI5PnlFol := TPanel():New(01, 01, , oI5PnlPai, , , , CLR_WHITE, , 50, 50)
	oI5PnlFol:Align := CONTROL_ALIGN_ALLCLIENT

	//--- Folder contendo os Custos da Ordem de Servico
	oI5Folder := TFolder():New(01, 01, aI5Folder, aI5Pages, oI5PnlFol, 1, CLR_BLACK, CLR_WHITE, .T., , 1000, 1000)
	oI5Folder:Align := CONTROL_ALIGN_ALLCLIENT

	For nX := 1 To Len(aI5Pages)
		oI5Folder:aDialogs[nX]:oFont := oDlgCOS:oFont
	Next nX

	oI5Folder:bChange := {|| fEntraI5Fo() }

	//------------------------------------------------------------------------------------------------------------------------//

	If lUsaIntERP //Usa Integracao com ERP?
		//--- Painel Pai dos Documentos de Entrada
		oI5PnlDoc := TPanel():New(01, 01, , oI5Folder:aDialogs[1], , , , CLR_WHITE, , 100, 50)
		oI5PnlDoc:Align := CONTROL_ALIGN_ALLCLIENT

		//Borda Esquerda dos Documentos de Entrada
		oI5LeftDoc := TPanel():New(01, 01, , oI5PnlDoc, , , , CLR_WHITE, nCorBack, 12, 50)
		oI5LeftDoc:Align := CONTROL_ALIGN_LEFT

		//Botao para visualizar o Documento de Entrada
		oI5BtnVDoc := TBtnBmp2():New(01, 01, 27, 30, "ng_ico_visual", , , , {|| fI5ERPVis(1)}, oI5LeftDoc, OemToAnsi(STR0053), , .T.) //"Visualizar Documento de Entradas"
		oI5BtnVDoc:Align := CONTROL_ALIGN_TOP

		//Botao para visualizar a Legenda do Documento de Entrada
		oI5BtnLDoc := TBtnBmp2():New(01, 01, 27, 30, "ng_ico_lgndos", , , , {|| A103Legenda()}, oI5LeftDoc, OemToAnsi(STR0132), , .T.) //"Legenda"
		oI5BtnLDoc:Align := CONTROL_ALIGN_TOP

		//--- Browse dos Documentos de Entrada
		oI5BrwDoc := TWBrowse():New(001, 001, 1000, 1000, , aI5HeadDoc, aI5SizeDoc,;
		oI5PnlDoc, , , , , {|| }, , , , , , , .F., , .T., , .F., , ,)
		oI5BrwDoc:SetArray(aI5ERPDoc)
		oI5BrwDoc:bLine := bI5LineDoc
		oI5BrwDoc:bLDblClick := {|| fI5ERPVis(1)}
		oI5BrwDoc:bGotFocus := {|| fAtuI5Fo(@oI5BrwDoc) }
		oI5BrwDoc:Align := CONTROL_ALIGN_ALLCLIENT

		//------------------------------------------------------------------------------------------------------------------------//

		//--- Painel Pai dos Solicitacoes de Compra
		oI5PnlCom := TPanel():New(01, 01, , oI5Folder:aDialogs[2], , , , CLR_WHITE, , 100, 50)
		oI5PnlCom:Align := CONTROL_ALIGN_ALLCLIENT

		//Borda Esquerda dos Solicitacoes de Compra
		oI5LeftCom := TPanel():New(01, 01, , oI5PnlCom, , , , CLR_WHITE, nCorBack, 12, 50)
		oI5LeftCom:Align := CONTROL_ALIGN_LEFT

		//Botao para visualizar o Solicitacao de Compra
		oI5BtnVCom := TBtnBmp2():New(01, 01, 27, 30, "ng_ico_visual", , , , {|| fI5ERPVis(2)}, oI5LeftCom, OemToAnsi(STR0055), , .T.) //"Visualizar Solicita็ใo de Compra"
		oI5BtnVCom:Align := CONTROL_ALIGN_TOP

		//Botao para visualizar a Legenda da Solicitacao de Compra
		oI5BtnLCom := TBtnBmp2():New(01, 01, 27, 30, "ng_ico_lgndos", , , , {|| A110Legenda()}, oI5LeftCom, OemToAnsi(STR0132), , .T.) //"Legenda"
		oI5BtnLCom:Align := CONTROL_ALIGN_TOP

		//--- Browse dos Solicitacoes de Compra
		oI5BrwCom := TWBrowse():New(001, 001, 1000, 1000, , aI5HeadCom, aI5SizeCom,;
		oI5PnlCom, , , , , {|| }, , , , , , , .F., , .T., , .F., , ,)
		oI5BrwCom:SetArray(aI5ERPCom)
		oI5BrwCom:bLine := bI5LineCom
		oI5BrwCom:bLDblClick := {|| fI5ERPVis(2)}
		oI5BrwCom:bGotFocus := {|| fAtuI5Fo(@oI5BrwCom) }
		oI5BrwCom:Align := CONTROL_ALIGN_ALLCLIENT

		//------------------------------------------------------------------------------------------------------------------------//

		//--- Painel Pai dos Solicitacoes ao Armazem
		oI5PnlArm := TPanel():New(01, 01, , oI5Folder:aDialogs[3], , , , CLR_WHITE, , 100, 50)
		oI5PnlArm:Align := CONTROL_ALIGN_ALLCLIENT


		//Borda Esquerda dos Solicitacoes ao Armazem
		oI5LeftArm := TPanel():New(01, 01, , oI5PnlArm, , , , CLR_WHITE, nCorBack, 12, 50)
		oI5LeftArm:Align := CONTROL_ALIGN_LEFT

		//Botao para visualizar o Solicitacao ao Armazem
		oI5BtnVArm := TBtnBmp2():New(01, 01, 27, 30, "ng_ico_visual", , , , {|| fI5ERPVis(3)}, oI5LeftArm, OemToAnsi(STR0057), , .T.) //"Visualizar Solicita็ใo ao Armaz้m"
		oI5BtnVArm:Align := CONTROL_ALIGN_TOP

		oI5BtnLArm := TBtnBmp2():New(01, 01, 27, 30, "ng_ico_lgndos", , , , {|| A105Legenda()}, oI5LeftArm, OemToAnsi(STR0132), , .T.) //"Legenda"
		oI5BtnLArm:Align := CONTROL_ALIGN_TOP

		//--- Browse dos Solicitacoes ao Armazem
		oI5BrwArm := TWBrowse():New(001, 001, 1000, 1000, , aI5HeadArm, aI5SizeArm,;
		oI5PnlArm, , , , , {|| }, , , , , , , .F., , .T., , .F., , ,)
		oI5BrwArm:SetArray(aI5ERPArm)
		oI5BrwArm:bLine := bI5LineArm
		oI5BrwArm:bLDblClick := {|| fI5ERPVis(3)}
		oI5BrwArm:bGotFocus := {|| fAtuI5Fo(@oI5BrwArm) }
		oI5BrwArm:Align := CONTROL_ALIGN_ALLCLIENT
	EndIf

	//------------------------------------------------------------------------------------------------------------------------//

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMNTC755SAIบAutor  ณWagner S. de Lacerdaบ Data ณ  28/04/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Acao de Confirmar/Cancelar a Consulta de O.S.              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC755SAI()

	oDlgCOS:End()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ SECAO: PRINCIPAL - FIM                                                บฑฑ
ฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ SECAO: GRAFICO DE GANTT - INICIO                                      บฑฑ
ฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMNTC755GRDบAutor  ณWagner S. de Lacerdaบ Data ณ  09/03/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Constroi o Grid de Tarefas da Consulta de O.S.             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ lProcessa -> Opcional;                                     บฑฑ
ฑฑบ          ณ              Define se deve processar as informacoes da    บฑฑ
ฑฑบ          ณ              base, ou carregar o que ja esta armazenado.   บฑฑ
ฑฑบ          ณ              Default: .T. -> Carrega da Base.              บฑฑ
ฑฑบ          ณ lSetData --> Opcional;                                     บฑฑ
ฑฑบ          ณ              Define se deve carregar a data do Grid.       บฑฑ
ฑฑบ          ณ              Default: .T. -> Carrega a Data.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC755GRD(lProcessa, lSetData)

	Local aArea := GetArea()
	Local aAreaTRB := {}
	Local aEspFunc := {}
	Local cChgTblIns := If(cTabela == "STJ","STL","STT")
	Local cNivArv := "", cArrayArv := "", cNivAtu := ""
	Local cCarChav := "", cCarOS := "", cCarTar := "", cCarTip := "", cCarIns := "", cCarDest := ""
	Local nX, nY, nPos, nPos2, nPos3, nAT

	Local aRetDtHr
	Local dDtIni, dDtFim
	Local cHrIni, cHrFim
	Local cSeqRela, cNomeTar, cNomeIns, cTipoReg, cTipoHor, cDestino
	Local lIsSubIns
	Local nPosExec, nPerExec, nQuantid, nQuanRec

	Local nMinsIni, nMinsFim, nDiasIni, nDiasFim
	Local nPosTotal, nMinsTotal, nPosIni, nPosFim
	Local nLinGrd, nLinPrev, nFimPrev

	Local cSequenc := ""
	Local cT5Sequen	:= Space(TAMSX3("T5_SEQUENC")[1])

	Default lProcessa := .T.
	Default lSetData  := .T.

	oGrdPnlCen:Hide()
	If Empty(cOS)
		Return .F.
	EndIf

	If lSetData
		dGrdDtIni := CTOD("  /  /    ")
		dGrdDtMin := CTOD("  /  /    ")
		dGrdDtMax := CTOD("  /  /    ")
	EndIf

	If lProcessa
		oTree:Reset()

		aGrdIns  := {}
		aGrdTips := {}
		aGrdTars := {}

		//Busca Insumos
		dbSelectArea((cTRBIns))
		dbSetOrder(1)
		dbSeek(xFilial(cChgTblIns)+cOS+cPlano,.T.)
		ProcRegua(LastRec() - RecNo())

		cSequenc := "000000"
		While !Eof() .And. (cTRBIns)->TL_FILIAL + (cTRBIns)->TL_ORDEM + (cTRBIns)->TL_PLANO <= xFilial(cChgTblIns) + cOS + cPlano
			IncProc(STR0115) //"Buscando Insumos..."

			dDtIni := (cTRBIns)->TL_DTINICI
			cHrIni := (cTRBIns)->TL_HOINICI
			dDtFim := (cTRBIns)->TL_DTFIM
			cHrFim := (cTRBIns)->TL_HOFIM

			cSeqRela := AllTrim((cTRBIns)->TL_SEQRELA)
			cNomeTar := fNomeTar((cTRBIns)->TL_TAREFA)
			cNomeIns := AllTrim( NOMINSBRW((cTRBIns)->TL_TIPOREG,(cTRBIns)->TL_CODIGO) )
			cTipoReg := (cTRBIns)->TL_TIPOREG
			cDestino := If(Empty((cTRBIns)->TL_DESTINO), "", AllTrim((cTRBIns)->TL_DESTINO))

			aEspFunc  := {}
			lIsSubIns := .F.
			nPerExec  := If(lPerMDO, (cTRBIns)->TL_PERMDOE, 0)

			If cTipoReg == "M" .And. cSeqRela <> "0" //Se o insumo for Mao de Obra e for Realizado
				dbSelectArea((cTRBIns))
				aAreaTRB := GetArea()
				//Verifica se esta relacionado a uma Especialidade
				aEspFunc := aClone( fVerFunEsp((cTRBIns)->TL_CODIGO) )
				If aEspFunc[1]
					lIsSubIns := .T. //Sub Insumo se refere 'a Mao de Obra que possui UMA Especiliadade Prevista relacionada na mesma O.S. (Chuncho solicitado pela qualidade; o MNT nao faz isto, mas esta Consulta de O.S. deve fazer esta aglutinacao)
				EndIf
				RestArea(aAreaTRB)
			EndIf

			nQuanRec := (cTRBIns)->TL_QUANREC
			nQuantid := (cTRBIns)->TL_QUANTID
			cTipoHor := AllTrim( (cTRBIns)->TL_TIPOHOR )
			cT5Sequen	:= (cTRBIns)->T5SEQUE
			//Converte os Insumos que trabalham com Horas para serem Horas Decimais, que sao mais faceis de trabalhar
			If cTipoReg <> "P" .And. cTipoHor <> "D"
				nQuantid := NGCONVERHORA(nQuantid, cTipoHor, "D")
			EndIf

			cSequenc := If(FindFunction("Soma1Old"),Soma1Old(cSequenc),Soma1(cSequenc))
			//1      ; 2              ; 3         ; 4                ; 5              ; 6                         ; 7     ; 8           ; 9           ; 10       ; 11       ; 12                      ; 13                       ; 14                                                                     ; 15                     ; 16                  ; 17                      ; 18                     ; 19
			//Tarefa ; Nome da Tarefa ; Sequencia ; Codigo do Insumo ; Nome do Insumo ; Tipo de Registro (Insumo) ; Local ; Data Inicio ; Hora Inicio ; Data Fim ; Hora Fim ; Codigo da Especialidade ; Porcentagem de Conclusao ; Quantidade ('Prevista' se for previsto e 'Realizada' se for realizado) ; Tipo de Hora do Insumo ; Sequencia do Insumo ; Destino (para Produtos) ; Quantidade de Recursos ; Sequ๊ncia ST5
			aAdd(aGrdIns, { (cTRBIns)->TL_TAREFA, cNomeTar, cSeqRela, (cTRBIns)->TL_CODIGO, cNomeIns, cTipoReg, (cTRBIns)->TL_LOCAL,;
			dDtIni, cHrIni, dDtFim, cHrFim, If(lIsSubIns, aEspFunc[2], ""), nPerExec, nQuantid,;
			cTipoHor, cSequenc, cDestino, nQuanRec, cT5Sequen } )

			dbSelectArea((cTRBIns))
			dbSkip()
		End

		//Se houver insumos
		If Len(aGrdIns) > 0
			ProcRegua(Len(aGrdIns))

			//Consiste os dados dos Insumos
			fGrdConst()

			//Adiciona para cada insumo, a sua perspectiva de conclusao (barra Projecao)
			fGrdProjec()

			//Define os Tipos de Registros e Tarefas para a projecao, a partir dos Insumos
			For nX := 1 To Len(aGrdIns)

				IncProc(STR0115) //"Buscando Insumos..."

				dDtIni := aGrdIns[nX][8]
				cHrIni := aGrdIns[nX][9]
				dDtFim := aGrdIns[nX][10]
				cHrFim := aGrdIns[nX][11]

				If AllTrim(aGrdIns[nX][3]) == "0" //Previstos
					cSeqRela := "0"
				ElseIf AllTrim(aGrdIns[nX][3]) == _ATRASO //Atrasos
					cSeqRela := _ATRASO
				ElseIf AllTrim(aGrdIns[nX][3]) == _PROJEC //Projecoes
					cSeqRela := _PROJEC
				ElseIf AllTrim(aGrdIns[nX][3]) <> "0"
					cSeqRela := "1"
				EndIf

				//Tipos de Registros
				If Empty(aGrdIns[nX][12])
					nPos := aScan(aGrdTips, {|x| x[1]+x[3] == aGrdIns[nX][1]+aGrdIns[nX][6] .And. AllTrim(x[2]) == cSeqRela})

					nPosExec := aScan(aPercTips, {|x| x[1]+x[2]+x[3] == cOS+aGrdIns[nX][1]+aGrdIns[nX][6] })
				Else //Considera o Sub Insumo da Especialidade
					nPos := aScan(aGrdTips, {|x| x[1]+x[3] == aGrdIns[nX][1]+"E" .And. AllTrim(x[2]) == cSeqRela})

					nPosExec := aScan(aPercTips, {|x| x[1]+x[2]+x[3] == cOS+aGrdIns[nX][1]+"E" })
				EndIf
				If nPos == 0
					//1      ; 2         ; 3                         ; 4            ; 5           ; 6           ; 7        ; 8        ; 9                        ; 10
					//Tarefa ; Sequencia ; Tipo de Registro (Insumo) ; Nome do Tipo ; Data Inicio ; Hora Inicio ; Data Fim ; Hora Fim ; Porcentagem de Conclusao ; Sequencia do Insumo
					aAdd(aGrdTips, { aGrdIns[nX][1], cSeqRela, If(Empty(aGrdIns[nX][12]),aGrdIns[nX][6],"E"), TIPREGBRW(If(Empty(aGrdIns[nX][12]),aGrdIns[nX][6],"E")),;
					dDtIni, cHrIni, dDtFim, cHrFim,;
					0, aGrdIns[nX][16] } )

					nPos := Len(aGrdTips)
				Else
					aRetDtHr := fCompDtHr( {aGrdTips[nPos][5], aGrdTips[nPos][6], aGrdTips[nPos][7], aGrdTips[nPos][8]},;
					{dDtIni, cHrIni, dDtFim, cHrFim} )
					aGrdTips[nPos][5] := aRetDtHr[1]
					aGrdTips[nPos][6] := aRetDtHr[2]
					aGrdTips[nPos][7] := aRetDtHr[3]
					aGrdTips[nPos][8] := aRetDtHr[4]
				EndIf
				If nPosExec > 0
					nPerExec := aPercTips[nPosExec][5]

					If nPerExec > aGrdTips[nPos][9]
						aGrdTips[nPos][9] := nPerExec
					EndIf
				EndIf

				//Tarefas
				nPos := aScan(aGrdTars, {|x| x[1] == aGrdIns[nX][1] .And. AllTrim(x[2]) == cSeqRela})
				nPosExec := aScan(aPercTars, {|x| x[1]+x[2] == cOS+aGrdIns[nX][1] })
				If nPos == 0
					//1      ; 2         ; 3              ; 4           ; 5           ; 6        ; 7        ; 8                        ; 9
					//Tarefa ; Sequencia ; Nome da Tarefa ; Data Inicio ; Hora Inicio ; Data Fim ; Hora Fim ; Porcentagem de Conclusao ; Sequencia do Insumo
					aAdd(aGrdTars, { aGrdIns[nX][1], cSeqRela, aGrdIns[nX][2],;
					dDtIni, cHrIni, dDtFim, cHrFim,;
					0, aGrdIns[nX][16],aGrdIns[nX][19] } )

					nPos := Len(aGrdTars)
				Else
					aRetDtHr := fCompDtHr( {aGrdTars[nPos][4], aGrdTars[nPos][5], aGrdTars[nPos][6], aGrdTars[nPos][7]},;
					{dDtIni, cHrIni, dDtFim, cHrFim} )
					aGrdTars[nPos][4] := aRetDtHr[1]
					aGrdTars[nPos][5] := aRetDtHr[2]
					aGrdTars[nPos][6] := aRetDtHr[3]
					aGrdTars[nPos][7] := aRetDtHr[4]
					aGrdTars[nPos][10] := aGrdIns[nX][19] //Sequ๊ncia ST5
				EndIf
				If nPosExec > 0
					nPerExec := aPercTars[nPosExec][4]

					If nPerExec > aGrdTars[nPos][8]
						aGrdTars[nPos][8] := nPerExec
					EndIf
				EndIf
			Next nX

			//Ordena os Arrays
			aSort(aGrdIns  , , , {|x,y| x[1]+x[6]+x[19]+x[3]+x[4]+DTOS(x[8])+x[9]+x[17] < y[1]+y[6]+y[19]+y[3]+y[4]+DTOS(y[8])+y[9]+y[17] })
			aSort(aGrdTips , , , {|x,y| x[1]+x[3]+x[2]+DTOS(x[5])+x[6] < y[1]+y[3]+y[2]+DTOS(y[5])+y[6] })
			aSort(aGrdTars , , , {|x,y| x[10]+x[1]+x[3]+x[2]+DTOS(x[4])+x[5] < y[10]+y[1]+y[3]+y[2]+DTOS(y[4])+y[5] })

			aSort(aTreeOS , , , {|x,y| x[1]+DTOS(x[2])+x[3] < y[1]+DTOS(y[2])+y[3] })
			aSort(aTreeTar, , , {|x,y| x[1]+x[13]+x[2]+DTOS(x[4])+x[5] < y[1]+y[13]+y[2]+DTOS(y[4])+y[5] })
			aSort(aTreeTip, , , {|x,y| x[1]+x[2]+x[4]+DTOS(x[6])+x[7] < y[1]+y[2]+y[4]+DTOS(y[6])+y[7] })
			aSort(aTreeIns, , , {|x,y| x[1]+x[2]+x[4]+x[6]+DTOS(x[8])+x[9]+x[17] < y[1]+y[2]+y[4]+y[6]+DTOS(y[8])+y[9]+y[17] })
			aSort(aTreeSubIns, , , {|x,y| x[1]+x[2]+x[4]+x[6]+DTOS(x[8])+x[9] < y[1]+y[2]+y[4]+y[6]+DTOS(y[8])+y[9] })

			//Define os itens da Arvore de Tarefas
			fGrdArvore()
		EndIf
	EndIf

	If oTree:IsEmpty()
		Return .F.
	EndIf

	ProcRegua(3)

	//Recebe o Nivel Atual na Arvore
	cNivArv   := oTree:GetCargo()
	nAT       := AT(".", cNivArv)
	cArrayArv := SubStr(cNivArv, 1, (nAT-1))
	cNivArv   := SubStr(cNivArv, (nAT+1))

	nPos := 0
	If cArrayArv == "OS"
		nPos := aScan(aTreeOS, {|x| x[6] == cNivArv })
	ElseIf cArrayArv == "TA"
		nPos := aScan(aTreeTar, {|x| x[8] == cNivArv })
	ElseIf cArrayArv == "TI"
		nPos := aScan(aTreeTip, {|x| x[10] == cNivArv })
	ElseIf cArrayArv == "IN"
		nPos := aScan(aTreeIns, {|x| x[12] == cNivArv })
	ElseIf cArrayArv == "SI"
		nPos := aScan(aTreeSubIns, {|x| x[12] == cNivArv })
	EndIf

	If nPos == 0
		Return .F.
	EndIf

	If cArrayArv == "OS"
		cCarOS   := aTreeOS[nPos][1]
		cCarTar  := ""
		cCarTip  := ""
		cCarIns  := ""
		cCarDest := ""

		//Atualiza Visualmente o Item Selecionado
		cGrdTAtuCo := aTreeOS[nPos][1]
		cGrdTAtuNo := OemToAnsi(STR0006) //"Consulta de O.S."
		dGrdTAtuD1 := aTreeOS[nPos][2]
		cGrdTAtuH1 := aTreeOS[nPos][3]
		dGrdTAtuD2 := aTreeOS[nPos][4]
		cGrdTAtuH2 := aTreeOS[nPos][5]
	ElseIf cArrayArv == "TA"
		cCarOS   := aTreeTar[nPos][1]
		cCarTar  := aTreeTar[nPos][2]
		cCarTip  := ""
		cCarIns  := ""
		cCarDest := ""

		//Atualiza Visualmente o Item Selecionado
		cGrdTAtuCo := aTreeTar[nPos][2]
		cGrdTAtuNo := aTreeTar[nPos][3]
		dGrdTAtuD1 := aTreeTar[nPos][4]
		cGrdTAtuH1 := aTreeTar[nPos][5]
		dGrdTAtuD2 := aTreeTar[nPos][6]
		cGrdTAtuH2 := aTreeTar[nPos][7]
	ElseIf cArrayArv == "TI"
		cCarOS   := aTreeTip[nPos][1]
		cCarTar  := aTreeTip[nPos][2]
		cCarTip  := aTreeTip[nPos][4]
		cCarIns  := ""
		cCarDest := ""

		//Atualiza Visualmente o Item Selecionado
		cGrdTAtuCo := aTreeTip[nPos][4]
		cGrdTAtuNo := aTreeTip[nPos][5]
		dGrdTAtuD1 := aTreeTip[nPos][6]
		cGrdTAtuH1 := aTreeTip[nPos][7]
		dGrdTAtuD2 := aTreeTip[nPos][8]
		cGrdTAtuH2 := aTreeTip[nPos][9]
	ElseIf cArrayArv == "IN"
		cCarOS   := aTreeIns[nPos][1]
		cCarTar  := aTreeIns[nPos][2]
		cCarTip  := aTreeIns[nPos][4]
		cCarIns  := aTreeIns[nPos][6]
		cCarDest := aTreeIns[nPos][17]

		//Atualiza Visualmente o Item Selecionado
		cGrdTAtuCo := aTreeIns[nPos][6]
		cGrdTAtuNo := aTreeIns[nPos][7]
		dGrdTAtuD1 := aTreeIns[nPos][8]
		cGrdTAtuH1 := aTreeIns[nPos][9]
		dGrdTAtuD2 := aTreeIns[nPos][10]
		cGrdTAtuH2 := aTreeIns[nPos][11]
	ElseIf cArrayArv == "SI"
		cCarOS   := aTreeSubIns[nPos][1]
		cCarTar  := aTreeSubIns[nPos][2]
		cCarTip  := aTreeSubIns[nPos][4]
		cCarIns  := aTreeSubIns[nPos][6]
		cCarDest := ""

		//Atualiza Visualmente o Item Selecionado
		cGrdTAtuCo := aTreeSubIns[nPos][6]
		cGrdTAtuNo := aTreeSubIns[nPos][7]
		dGrdTAtuD1 := aTreeSubIns[nPos][8]
		cGrdTAtuH1 := aTreeSubIns[nPos][9]
		dGrdTAtuD2 := aTreeSubIns[nPos][10]
		cGrdTAtuH2 := aTreeSubIns[nPos][11]
	EndIf
	cGrdTAtuDe := If(!Empty(cCarDest), NGRETSX3BOX("TL_DESTINO", cCarDest), Space(1))
	If Empty(cGrdTAtuDe)
		oGrdTAtuDe:Disable()
	Else
		oGrdTAtuDe:Enable()
	EndIf

	cCarChav := cCarOS + cCarTar + cCarTip + cCarIns + cCarDest

	oGrdTAtuCo:Refresh()
	oGrdTAtuNo:Refresh()
	oGrdTAtuD1:Refresh()
	oGrdTAtuH1:Refresh()
	oGrdTAtuD2:Refresh()
	oGrdTAtuH2:Refresh()
	oGrdTAtuDe:Refresh()

	IncProc()

	//Define os itens do Grafico
	//1      ; 2       ; 3                ; 4              ; 5                ; 6                                                     ; 7                        ; 8                   ; 9 -> apenas existe em Insumos do Tipo Produtos
	//Tarefa ; SeqRela ; Codigo do Insumo ; Nome do Insumo ; Tipo de Registro ; { Data Inicial ; Hora Inicial ; Data Fim ; Hora Fim } ; Porcentagem de Conclusao ; Sequencia do Insumo ; Destino (para Produtos)
	aGrdGrafic := {}

	If cArrayArv == "OS" //Se o item 'O.S.' estiver selecionado, carrega as Tarefas no Gantt
		For nX := 1 To Len(aGrdTars)
			aAdd(aGrdGrafic, {aGrdTars[nX][1], aGrdTars[nX][2], aGrdTars[nX][1], aGrdTars[nX][3], " ",;
			{aGrdTars[nX][4], aGrdTars[nX][5], aGrdTars[nX][6], aGrdTars[nX][7]},;
			aGrdTars[nX][8], aGrdTars[nX][9],aGrdTars[nX][10] })

			fGrdSetDts(lSetData,aGrdTars[nX][4],aGrdTars[nX][6]) //Seta as Datas do Gantt
		Next nX
	ElseIf cArrayArv == "TA" //Se o item 'Tarefa' estiver selecionado, carrega os Tipos de Registro no Gantt
		nPos := aScan(aGrdTips, {|x| cOS+x[1] == cCarChav })
		If nPos > 0
			For nX := nPos To Len(aGrdTips)
				If cOS+aGrdTips[nX][1] == cCarChav
					aAdd(aGrdGrafic, {aGrdTips[nX][1], aGrdTips[nX][2], aGrdTips[nX][3], aGrdTips[nX][4], aGrdTips[nX][3],;
					{aGrdTips[nX][5], aGrdTips[nX][6], aGrdTips[nX][7], aGrdTips[nX][8]},;
					aGrdTips[nX][9], aGrdTips[nX][10] })

					fGrdSetDts(lSetData,aGrdTips[nX][5],aGrdTips[nX][7]) //Seta as Datas do Gantt
				EndIf
			Next nX
		EndIf
	ElseIf cArrayArv == "TI" //Se o item 'Tipo de Registro' estiver selecionado, carrega os Insumos no Gantt
		//Para nao ter que varrer todos o insumos, inicia pela tarefa
		nPos := aScan(aGrdIns, {|x| x[1] == cCarTar })
		If nPos > 0
			For nX := nPos To Len(aGrdIns)
				If cOS+aGrdIns[nX][1]+aGrdIns[nX][6] == cCarChav .And. Empty(aGrdIns[nX][12])
					aAdd(aGrdGrafic, {aGrdIns[nX][1], aGrdIns[nX][3], aGrdIns[nX][4], aGrdIns[nX][5], aGrdIns[nX][6],;
					{aGrdIns[nX][8], aGrdIns[nX][9], aGrdIns[nX][10], aGrdIns[nX][11]},;
					aGrdIns[nX][13], aGrdIns[nX][16], aGrdIns[nX][17] })

					fGrdSetDts(lSetData,aGrdIns[nX][8],aGrdIns[nX][10]) //Seta as Datas do Gantt
				EndIf

				//Adiciona tambem, caso existam, os Sub Insumos do Tipo Especialidade (Realizados)
				If aGrdIns[nX][1] == cCarTar .And. cCarTip == "E" .And. !Empty(aGrdIns[nX][12])
					nPos2 := aScan(aGrdGrafic, {|x| x[1]+x[5]+AllTrim(x[3]) == aGrdIns[nX][1]+"E"+AllTrim(aGrdIns[nX][12]) .And. AllTrim(x[2]) <> "0" .And. AllTrim(x[2]) <> _ATRASO .And. AllTrim(x[2]) <> _PROJEC })
					If nPos2 == 0
						aAdd(aGrdGrafic, {aGrdIns[nX][1], aGrdIns[nX][3], aGrdIns[nX][12], AllTrim( NOMINSBRW("E",aGrdIns[nX][12]) ), "E",;
						{aGrdIns[nX][8], aGrdIns[nX][9], aGrdIns[nX][10], aGrdIns[nX][11]},;
						aGrdIns[nX][13], aGrdIns[nX][16], aGrdIns[nX][17] })

						fGrdSetDts(lSetData,aGrdGrafic[Len(aGrdGrafic)][6][1],aGrdGrafic[Len(aGrdGrafic)][6][3]) //Seta as Datas do Gantt
					Else
						aRetDtHr := fCompDtHr( {aGrdGrafic[nPos2][6][1], aGrdGrafic[nPos2][6][2], aGrdGrafic[nPos2][6][3], aGrdGrafic[nPos2][6][4]},;
						{aGrdIns[nX][8], aGrdIns[nX][9], aGrdIns[nX][10], aGrdIns[nX][11]} )
						aGrdGrafic[nPos2][6][1] := aRetDtHr[1]
						aGrdGrafic[nPos2][6][2] := aRetDtHr[2]
						aGrdGrafic[nPos2][6][3] := aRetDtHr[3]
						aGrdGrafic[nPos2][6][4] := aRetDtHr[4]

						fGrdSetDts(lSetData,aGrdGrafic[nPos2][6][1],aGrdGrafic[nPos2][6][3]) //Seta as Datas do Gantt

						If aGrdIns[nX][13] > aGrdGrafic[nPos2][7]
							aGrdGrafic[nPos2][7] := aGrdIns[nX][13]
						EndIf
					EndIf
				EndIf
			Next nX
		EndIf
	ElseIf cArrayArv == "IN" //Se o item 'Insumo' estiver selecionado, carrega apenas o Insumo selecionado no Gantt
		//Para nao ter que varrer todos o insumos, inicia pela tarefa
		nPos := aScan(aGrdIns, {|x| x[1] == cCarTar })
		If nPos > 0
			For nX := nPos To Len(aGrdIns)
				If cOS+aGrdIns[nX][1]+aGrdIns[nX][6]+aGrdIns[nX][4]+aGrdIns[nX][17] == cCarChav .And. Empty(aGrdIns[nX][12])
					aAdd(aGrdGrafic, {aGrdIns[nX][1], aGrdIns[nX][3], aGrdIns[nX][4], aGrdIns[nX][5], aGrdIns[nX][6],;
					{aGrdIns[nX][8], aGrdIns[nX][9], aGrdIns[nX][10], aGrdIns[nX][11]},;
					aGrdIns[nX][13], aGrdIns[nX][16], aGrdIns[nX][17] })

					fGrdSetDts(lSetData,aGrdIns[nX][8],aGrdIns[nX][10]) //Seta as Datas do Gantt
				EndIf

				//Adiciona tambem, caso existam, os Sub Insumos do Insumo de Especialidade (Realizados)
				If aGrdIns[nX][1] == cCarTar .And. cCarTip == "E" .And. !Empty(aGrdIns[nX][12]) .And. AllTrim(aGrdIns[nX][12]) == AllTrim(cCarIns)
					nPos2 := aScan(aGrdGrafic, {|x| x[1]+x[5]+AllTrim(x[3]) == aGrdIns[nX][1]+"E"+AllTrim(aGrdIns[nX][12]) .And. AllTrim(x[2]) <> "0" .And. AllTrim(x[2]) <> _ATRASO .And. AllTrim(x[2]) <> _PROJEC })
					If nPos2 == 0
						aAdd(aGrdGrafic, {aGrdIns[nX][1], aGrdIns[nX][3], aGrdIns[nX][12], AllTrim( NOMINSBRW("E",aGrdIns[nX][12]) ), "E",;
						{aGrdIns[nX][8], aGrdIns[nX][9], aGrdIns[nX][10], aGrdIns[nX][11]},;
						aGrdIns[nX][13], aGrdIns[nX][16], aGrdIns[nX][17] })

						fGrdSetDts(lSetData,aGrdGrafic[Len(aGrdGrafic)][6][1],aGrdGrafic[Len(aGrdGrafic)][6][3]) //Seta as Datas do Gantt
					Else
						aRetDtHr := fCompDtHr( {aGrdGrafic[nPos2][6][1], aGrdGrafic[nPos2][6][2], aGrdGrafic[nPos2][6][3], aGrdGrafic[nPos2][6][4]},;
						{aGrdIns[nX][8], aGrdIns[nX][9], aGrdIns[nX][10], aGrdIns[nX][11]} )
						aGrdGrafic[nPos2][6][1] := aRetDtHr[1]
						aGrdGrafic[nPos2][6][2] := aRetDtHr[2]
						aGrdGrafic[nPos2][6][3] := aRetDtHr[3]
						aGrdGrafic[nPos2][6][4] := aRetDtHr[4]

						fGrdSetDts(lSetData,aGrdGrafic[nPos2][6][1],aGrdGrafic[nPos2][6][3]) //Seta as Datas do Gantt

						If aGrdIns[nX][13] > aGrdGrafic[nPos2][7]
							aGrdGrafic[nPos2][7] := aGrdIns[nX][13]
						EndIf
					EndIf
				EndIf
			Next nX
		EndIf
	ElseIf cArrayArv == "SI" //Se o item 'Sub Insumo' estiver selecionado, carrega apenas o Sub Insumo selecionado no Gantt
		//Para nao ter que varrer todos o insumos, inicia pela tarefa
		nPos := aScan(aGrdIns, {|x| x[1] == cCarTar })
		If nPos > 0
			For nX := nPos To Len(aGrdIns)
				If cOS+aGrdIns[nX][1]+aGrdIns[nX][6]+aGrdIns[nX][4] == cCarChav
					aAdd(aGrdGrafic, {aGrdIns[nX][1], aGrdIns[nX][3], aGrdIns[nX][4], aGrdIns[nX][5], aGrdIns[nX][6],;
					{aGrdIns[nX][8], aGrdIns[nX][9], aGrdIns[nX][10], aGrdIns[nX][11]},;
					aGrdIns[nX][13], aGrdIns[nX][16] })

					fGrdSetDts(lSetData,aGrdIns[nX][8],aGrdIns[nX][10]) //Seta as Datas do Gantt
				EndIf

				//Adiciona tambem, caso exista, o Insumo que gerou este Sub Insumo (ex.: Especialidade que possui a Mao de Obra)
				If aGrdIns[nX][1] == cCarTar .And. cCarTip == "M" .And. !Empty(aGrdIns[nX][12]) .And. AllTrim(aGrdIns[nX][4]) == AllTrim(cCarIns)
					For nY := 1 To 3 //Busca por Previsto, Atraso e Projecao da Especialidade
						If nY == 1 //Previsto
							nPos2 := aScan(aGrdIns, {|x| x[1]+x[6]+AllTrim(x[4]) == aGrdIns[nX][1]+"E"+AllTrim(aGrdIns[nX][12]) .And. AllTrim(x[3]) == "0" })
						ElseIf nY == 2 //Atraso
							nPos2 := aScan(aGrdIns, {|x| x[1]+x[6]+AllTrim(x[4]) == aGrdIns[nX][1]+"E"+AllTrim(aGrdIns[nX][12]) .And. AllTrim(x[3]) == _ATRASO })
						Else //Projecao
							nPos2 := aScan(aGrdIns, {|x| x[1]+x[6]+AllTrim(x[4]) == aGrdIns[nX][1]+"E"+AllTrim(aGrdIns[nX][12]) .And. AllTrim(x[3]) == _PROJEC })
						EndIf

						If nPos2 > 0
							nPos3 := aScan(aGrdGrafic, {|x| x[1]+x[2]+x[5]+AllTrim(x[3]) == aGrdIns[nPos2][1]+aGrdIns[nPos2][3]+aGrdIns[nPos2][6]+AllTrim(aGrdIns[nPos2][4])})
							If nPos3 == 0
								aAdd(aGrdGrafic, {aGrdIns[nPos2][1], aGrdIns[nPos2][3], aGrdIns[nPos2][4], aGrdIns[nPos2][5], aGrdIns[nPos2][6],;
								{aGrdIns[nPos2][8], aGrdIns[nPos2][9], aGrdIns[nPos2][10], aGrdIns[nPos2][11]},;
								aGrdIns[nPos2][13], aGrdIns[nPos2][16] })

								fGrdSetDts(lSetData,aGrdIns[nPos2][8],aGrdIns[nPos2][10]) //Seta as Datas do Gantt
							Else
								//So se compara as datas de um Insumo Previsto com outro Previsto, pois algo realizado/atrasado/projetado nao pode alterar a previsao inicial; sao apenas um complemento ao previsto
								If AllTrim(aGrdGrafic[nPos3][2]) <> "0" .Or. ( AllTrim(aGrdGrafic[nPos3][2]) == "0" .And. AllTrim(aGrdIns[nX][3]) == "0" )
									aRetDtHr := fCompDtHr( {aGrdGrafic[nPos3][6][1], aGrdGrafic[nPos3][6][2], aGrdGrafic[nPos3][6][3], aGrdGrafic[nPos3][6][4]},;
									{aGrdIns[nX][8], aGrdIns[nX][9], aGrdIns[nX][10], aGrdIns[nX][11]} )
									aGrdGrafic[nPos3][6][1] := aRetDtHr[1]
									aGrdGrafic[nPos3][6][2] := aRetDtHr[2]
									aGrdGrafic[nPos3][6][3] := aRetDtHr[3]
									aGrdGrafic[nPos3][6][4] := aRetDtHr[4]
								EndIf

								fGrdSetDts(lSetData,aGrdGrafic[nPos3][6][1],aGrdGrafic[nPos3][6][3]) //Seta as Datas do Gantt

								If aGrdIns[nX][13] > aGrdGrafic[nPos3][7]
									aGrdGrafic[nPos3][7] := aGrdIns[nX][13]
								EndIf
							EndIf
						EndIf
					Next nY
				EndIf
			Next nX
		EndIf
	EndIf
	If Len(aGrdGrafic) > 0 .And. Len(aGrdGrafic[1]) >= 9 //Ordena tambem pelo Destino do Insumo (especialmente no caso de existirem produtos)
		aSort(aGrdGrafic, , , {|x,y| x[5]+x[9]+x[3]+x[2] < y[5]+y[9]+y[3]+y[2] })
	Else
		aSort(aGrdGrafic, , , {|x,y| x[8]+x[5]+x[3]+x[2] < y[8]+y[5]+y[3]+y[2] })
	EndIf

	IncProc()

	/*	Resolucoes:
	1 - Intervalo de 60 minutos (24 casas/posicoes na escala por dia)
	2 - Intervalo de 30 minutos (48 casas/posicoes na escala por dia)
	3 - Intervalo de 20 minut\os (72 casas/posicoes na escala por dia)
	4 - Intervalo de 15 minutos (96 casas/posicoes na escala por dia)
	5 - Intervalo de 12 minutos (120 casas/posicoes na escala por dia)
	6 - Intervalo de 10 minutos (144 casas/posicoes na escala por dia)
	*/

	//--- Cria/Atualiza o Grid de Tarefas
	oGrdPnlCen:Show()

	If Type("oGrdGrafic") == "O"
		oGrdGrafic:Disable()
		oGrdGrafic:Hide()
		MsFreeObj(oGrdGrafic)
	EndIf

	oGrdGrafic := MsCalendGrid():New(oGrdPnlGrd, 01, 01, 200, 200,;
	dGrdDtIni, nGrdResolu, , ,;
	RGB(211,211,211), {|| fGrdClick()}, .T. )
	oGrdGrafic:nZoom := nGrdZoom
	oGrdGrafic:Align := CONTROL_ALIGN_ALLCLIENT

	oGrdGrafic:Hide()

	dGrdSetDt := dGrdDtIni
	aGrdLinClk := {}
	nLinGrd := 0
	For nX := 1 To Len(aGrdGrafic)
		//Recebe os valores
		nMinsIni := HTOM(aGrdGrafic[nX][6][2])
		nMinsFim := HTOM(aGrdGrafic[nX][6][4])
		nDiasIni := aGrdGrafic[nX][6][1] - dGrdDtIni
		nDiasFim := aGrdGrafic[nX][6][3] - dGrdDtIni

		//Converte os minutos para casas/posicoes na escala
		nPosTotal  := nGrdResolu * 24
		nMinsTotal := 60 / nGrdResolu

		//Define as casas/posicoes iniciais e finais no grafico
		nPosIni := 1 + (nMinsIni / nMinsTotal) + (nDiasIni * nPosTotal)
		nPosFim := 2 + (nMinsFim / nMinsTotal) + (nDiasFim * nPosTotal)

		//Se for no minuto '..:00' arredonda uma posicao abaixo
		If ! ("." $ cValToChar(nPosFim))
			nPosFim--
		EndIf

		//A posicao inicial nao pode ser 0 caso a final seja maior que 0 (senao nao aparecera')
		If nPosFim > 0 .And. nPosIni <= 0
			nPosIni := 1
		EndIf

		//A posicao final deve ser maior que a inicial, senao nao mostrara no Gantt
		//Obs.: Isso so' e' valido para os itens Previstos (que sao os principais) e Realizados. Projecoes e Atrasos nao sao obrigatorios para aparecer no Gantt.
		If AllTrim(aGrdGrafic[nX][2]) == "0" .Or. ( AllTrim(aGrdGrafic[nX][2]) <> "0" .And.  AllTrim(aGrdGrafic[nX][2]) <> _ATRASO .And. AllTrim(aGrdGrafic[nX][2]) <> _PROJEC )
			If Round(nPosFim,0) == Round(nPosIni,0)
				nPosFim++
			EndIf
		EndIf

		If AllTrim(aGrdGrafic[nX][2]) == "0"
			nLinGrd++

			nLinPrev := nLinGrd
			nFimPrev := nPosFim //Mostra a Projecao logo APOS o Previto, e NAO EXATAMENTE sobre o Previto
			oGrdGrafic:Add("[P] " + AllTrim(aGrdGrafic[nX][4]), nLinGrd, nPosIni, nPosFim, _COR_PREVIS, STR0077) //"Previsto"

			aAdd(aGrdLinClk, {nLinGrd, nX}) //Ou seja, a linha selecionada (clicada), corresponde a posicao x (segundo elemento) do array do Grid (aGrdGrafic)
		ElseIf AllTrim(aGrdGrafic[nX][2]) == _ATRASO
			If Round(nPosIni,0) <= Round(nFimPrev,0) //Mostra a Projecao logo apos o Previto
				nPosIni := nFimPrev
			EndIf
			If Round(nFimPrev,0) <= Round(nPosFim,0)
				nFimPrev := nPosFim
			EndIf

			If nPosFim > nPosIni
				oGrdGrafic:Add("", nLinPrev, nPosIni, nPosFim, _COR_ATRASO, STR0280) //"Atrasado"
			EndIf
		ElseIf AllTrim(aGrdGrafic[nX][2]) == _PROJEC
			If Round(nPosIni,0) <= Round(nFimPrev,0) //Mostra a Projecao logo apos o Previto
				nPosIni := nFimPrev
			EndIf

			If nPosFim > nPosIni
				oGrdGrafic:Add("", nLinPrev, nPosIni, nPosFim, _COR_PROJEC, STR0079) //"Proje็ใo de Conclusใo"
			EndIf
		Else
			nLinGrd++

			oGrdGrafic:Add("[R] " + AllTrim(aGrdGrafic[nX][4]), nLinGrd, nPosIni, nPosFim, _COR_REALIZ, STR0078) //"Realizado"

			aAdd(aGrdLinClk, {nLinGrd, nX}) //Ou seja, a linha selecionada (clicada), corresponde a posicao x (segundo elemento) do array do Grid (aGrdGrafic)
		EndIf
	Next nX

	oGrdGrafic:Refresh()
	oGrdGrafic:Show()

	RestArea(aArea)

	IncProc()

	//Quando a classe DbTree esta' dentro de um splitter, caso haja mais de uma objeto nesse mesmo TSplitter e o split esteja ativo
	//ou seja, quando o redimensionamento esta' ativo, o scroll interno da DbTree se reseta sozinho. Este bloco de codigo e' para quando
	//o outro objeto do splitter estiver visivel (isto ocorreu para um TSplitter com Orientecao 1 - Vertical)
	If oDlgInfo:lVisible
		//Atualiza a Arvore
		cAuxNiv := oTree:GetCargo()
		oTree:TreeSeek("OS.001")
		oTree:TreeSeek(cAuxNiv)
		oTree:PTRefresh()
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfGrdTar   บAutor  ณWagner S. de Lacerdaบ Data ณ  23/03/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega a Tarefa do Grid de Tarefas a partir da tarefa     บฑฑ
ฑฑบ          ณ selecionado no Tree.                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ lTrocaTar -> Opcional;                                     บฑฑ
ฑฑบ          ณ              Indica a troca de Tarefa para o grafico.      บฑฑ
ฑฑบ          ณ              Default: .F. -> Nao houve troca de tarefa     บฑฑ
ฑฑบ          ณ lSetData --> Opcional;                                     บฑฑ
ฑฑบ          ณ              Indica se deve carregar a Data do Grid.       บฑฑ
ฑฑบ          ณ              Default: .T. -> Carrega a Data.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fGrdTar(lTrocaTar, lSetData)

	Default lTrocaTar := .F.
	Default lSetData  := .T.

	If Empty(cOS) .Or. IsInCallStack("MNTC755VOS") //Se nao ha' Ordem de Service definida OU o processo de Validacao da O.S. esta' sendo executado, retorna...
		Return .T.
	EndIf

	//Se trocar a tarefa, reinicializa a data inicial do grafico
	If lTrocaTar
		lSetData := .T.
	EndIf

	fSetUpdate(.F.) //Define a atualizacao da tela

	MNTC755GRD(.F., lSetData)

	fSetUpdate() //Define a atualizacao da tela

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfGrdSetDtsบAutor  ณWagner S. de Lacerdaบ Data ณ  19/07/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Define a Data Inicio, Minima e Maxima do Gantt.            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ lSetDt -> Obrigatorio;                                     บฑฑ
ฑฑบ          ณ           Define se e' para setar as datas.                บฑฑ
ฑฑบ          ณ           .T. - Seta.                                      บฑฑ
ฑฑบ          ณ           .F. - Nao seta.                                  บฑฑ
ฑฑบ          ณ dDtMin -> Obrigatorio;                                     บฑฑ
ฑฑบ          ณ           Indica qual o Data Minima para comparacao.       บฑฑ
ฑฑบ          ณ dDtMax -> Obrigatorio;                                     บฑฑ
ฑฑบ          ณ           Indica qual o Data Maxima para comparacao.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fGrdSetDts(lSetDt, dDtMin, dDtMax)

	Default lSetDt := .F.

	If lSetDt
		If Empty(dGrdDtIni) //Data Inicial
			dGrdDtIni := dDtMin
		ElseIf dGrdDtIni > dDtMin
			dGrdDtIni := dDtMin
		EndIf

		If Empty(dGrdDtMin) //Data Minima (Menor)
			dGrdDtMin := dDtMin
		ElseIf dGrdDtMin > dDtMin
			dGrdDtMin := dDtMin
		EndIf

		If Empty(dGrdDtMax) //Data Maxima (Maior)
			dGrdDtMax := dDtMax
		ElseIf dGrdDtMax < dDtMax
			dGrdDtMax := dDtMax
		EndIf
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfGrdBtn   บAutor  ณWagner S. de Lacerdaบ Data ณ  15/04/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Executa a acao do botao do grafico.                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nBtn -> Obrigatorio;                                       บฑฑ
ฑฑบ          ณ         Indica qual o botao do grafico foi clicado.        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fGrdBtn(nBtn)

	Local lRecriar := .T.

	If nBtn == 1 //Intervalo Maior
		If oGrdGrafic:nZoom >= 2 .And. oGrdGrafic:nZoom < 8 //2 - Menor Zoom ; 8 - Maior Zoom
			oGrdGrafic:nZoom++
			nGrdZoom := oGrdGrafic:nZoom
		EndIf
		lRecriar := .F.
	ElseIf nBtn == 2 //Intervalo Menor
		If oGrdGrafic:nZoom > 2 .And. oGrdGrafic:nZoom <= 8 //2 - Menor Zoom ; 8 - Maior Zoom
			oGrdGrafic:nZoom--
			nGrdZoom := oGrdGrafic:nZoom
		EndIf
		lRecriar := .F.
	ElseIf nBtn == 3 //Ultimo
		If !Empty(dGrdDtMax)
			dGrdDtIni := dGrdDtMax
		EndIf
	ElseIf nBtn == 4 //Avancar
		dGrdDtIni++
	ElseIf nBtn == 6 //Retroceder
		dGrdDtIni--
	ElseIf nBtn == 7 //Primeiro
		If !Empty(dGrdDtMin)
			dGrdDtIni := dGrdDtMin
		EndIf
	EndIf

	//Atualilza o Grid de Tarefas
	If lRecriar
		fGrdTar(, .F.)
	EndIf

	oGrdTAtuCo:SetFocus()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfGrdConst บAutor  ณWagner S. de Lacerdaบ Data ณ  13/07/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consiste os dados dos insumos, verificando percentual de   บฑฑ
ฑฑบ          ณ conclusao e atualizando os dados conforme necessario.      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fGrdConst()

	Local aRetDtHr := {}

	/* Variaveis para Controle da Arvore */
	Local dDtIni, dDtFim
	Local cHrIni, cHrFim
	Local cCodTar, cNomeTar, cSeqRela
	Local cCodIns, cNomeIns, cTipoReg, cDestino
	Local lIsSubIns
	Local nIns := 0
	/**/

	/* Variaveis da Atualizacao dos Insumos */
	Local nPerExec := 0, nQtdeReal := 0, nQuanRec := 0
	Local nVAtual := 0, nVPrev := 0, nVReal := 0
	Local nPos := 0
	/**/

	Local cT5Seque := Space(TAMSX3("T5_SEQUENC")[1])

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Atualiza a Porcentagem de Conclusao dos Insumos                       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nVAtual := 1 To Len(aGrdIns)
		nQtdeReal := 0

		If AllTrim(aGrdIns[nVAtual][3]) == "0"
			//ษอออออออออออออออออออป
			//บ Ajusta: Previsto  บ
			//ศอออออออออออออออออออผ
			/* Importante:
			Neste bloco sao apenas considerados os insumos realizados que possuem previssao,
			logo, os insumos que foram realizados sem possuir um previsto nao sao processados.
			*/

			nPerExec := aGrdIns[nVAtual][13]
			nQuanRec := If(aGrdIns[nVAtual][18] > 0, aGrdIns[nVAtual][18], 1)
			For nVReal := 1 To Len(aGrdIns)
				//Se for o mesmo insumo, porem realizado
				If aGrdIns[nVReal][1] == aGrdIns[nVAtual][1] .And. aGrdIns[nVReal][6] == aGrdIns[nVAtual][6] ;
				.And. aGrdIns[nVReal][4] == aGrdIns[nVAtual][4] .And. AllTrim(aGrdIns[nVReal][3]) <> "0" .And. ;
				If(aGrdIns[nVAtual][6] == "P" , aGrdIns[nVReal][17] == aGrdIns[nVAtual][17], .T.)

					nQtdeReal += aGrdIns[nVReal][14]

					If aGrdIns[nVReal][6] == "M" //Mao de Obra
						If aGrdIns[nVReal][13] > nPerExec //Se o Percentual Executado for Maior
							nPerExec := aGrdIns[nVReal][13]
						EndIf
					Else //Os Outros
						If aGrdIns[nVReal][14] >= aGrdIns[nVAtual][14] //Se a Quantidade Realizada for Maior ou Igual
							nPerExec := 100
						Else //Calcula com base no que esta realizado atualmente
							nPerExec := ( (aGrdIns[nVReal][14] * 100) / (aGrdIns[nVAtual][14] * nQuanRec) )
						EndIf
					EndIf

					//Atualiza a Porcentagem do Realizado de acordo com o Calculado
					//Com excecao de Mao de Obra, que ja tem seu proprio campo para isso (TL_PERMDOE)
					If aGrdIns[nVReal][6] <> "M"
						aGrdIns[nVReal][13] := Round(nPerExec,2)
					EndIf
				EndIf
			Next nVReal

			//Se estiver utilizando o Percentual de Mao de Obra (TL_PERMDOE) e o insumo previsto for uma Especialidade ou uma Mao de Obra, entao utiliza o percentual ja' calculado, que e' o Maior
			//Caso contrario, atualiza a Porcentagem do Previsto com a Quantidade Realizada TOTAL
			If !lPerMDO .Or. ( aGrdIns[nVAtual][6] <> "E" .And. aGrdIns[nVAtual][6] <> "M" )
				If nQtdeReal >= aGrdIns[nVAtual][14]
					nPerExec := 100
				Else
					nPerExec := ( (nQtdeReal * 100) / (aGrdIns[nVAtual][14] * nQuanRec) )
				EndIf
			EndIf
			If nPerExec > aGrdIns[nVAtual][13]
				aGrdIns[nVAtual][13] := Round(nPerExec,2)
			EndIf
		Else
			//ษอออออออออออออออออออป
			//บ Ajusta: Realizado บ
			//ศอออออออออออออออออออผ
			/* Importante:
			Neste bloco sao apenas processados os insumos realizados que nao estavam previstos.
			(com excecao do chuncho entre Especialidade x Mao de Obra)
			*/

			nPerExec := aGrdIns[nVAtual][13]

			//Busca por um Previsto
			nPos := aScan(aGrdIns, {|x| x[1]+x[6]+x[4] == aGrdIns[nVAtual][1]+aGrdIns[nVAtual][6]+aGrdIns[nVAtual][4] .And. AllTrim(x[3]) == "0" .And. If(aGrdIns[nVAtual][6] == "P" , x[17] == aGrdIns[nVAtual][17], .T.) })
			//Se nao possuir Previsto
			If nPos == 0
				If aGrdIns[nVAtual][6] == "M" .And. !Empty(aGrdIns[nVAtual][12]) //Mao de Obra
					//Busca a Especialidade desta Mao de Obra
					nVPrev := aScan(aGrdIns, {|x| x[1]+x[6]+AllTrim(x[4]) == aGrdIns[nVAtual][1]+"E"+AllTrim(aGrdIns[nVAtual][12]) .And. AllTrim(x[3]) == "0"})
					If nVPrev > 0
						//Atualiza a Porcentagem Especialidade com o que foi realizado
						If nPerExec > aGrdIns[nVPrev][13] //Se o Percentual Executado for Maior
							aGrdIns[nVPrev][13] := nPerExec
						EndIf
					Else
						aGrdIns[nVAtual][13] := 100 //Se nao encontrou uma Especialida Prevista relacionada, entao o insumo nao teve previsao, logo, joga 100%
					EndIf
				Else
					aGrdIns[nVAtual][13] := 100 //Se nao encontrou um Insumo Previsto relacionado, entao o insumo nao teve previsao, logo, joga 100%
				EndIf
			EndIf
		EndIf
	Next nVAtual

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Atribui os Dados para a Arvore                                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aTreeOS  := {}
	aTreeTar := {}
	aTreeTip := {}
	aTreeIns := {}
	aTreeSubIns := {}

	For nIns := 1 To Len(aGrdIns)

		dDtIni := aGrdIns[nIns][8]
		cHrIni := aGrdIns[nIns][9]
		dDtFim := aGrdIns[nIns][10]
		cHrFim := aGrdIns[nIns][11]

		cCodTar  := aGrdIns[nIns][1]
		cNomeTar := aGrdIns[nIns][2]
		cSeqRela := aGrdIns[nIns][3]

		cCodIns  := aGrdIns[nIns][4]
		cNomeIns := aGrdIns[nIns][5]
		cTipoReg := aGrdIns[nIns][6]
		cDestino := aGrdIns[nIns][17]
		cT5Seque := aGrdIns[nIns][19]

		lIsSubIns := !Empty( aGrdIns[nIns][12] )

		//Grava dados da O.S.
		nPos := aScan(aTreeOS, {|x| x[1] == cOS})
		If nPos == 0
			//1    ; 2              ; 3              ; 4             ; 5             ; 6               ; 7               ; 8               ; 9            ; 10
			//O.S. ; Dt. Prev. Ini. ; Ht. Prev. Ini. ; Dt. Prev. Fim ; Hr. Prev. Fim ; NIVEL NA ARVORE ; Dt. Real Inicio ; Hr. Real Inicio ; Dt. Real Fim ; Hr. Real Fim
			If cSeqRela == "0"
				aAdd(aTreeOS, {cOS, dDtIni, cHrIni, dDtFim, cHrFim, " ", CTOD("  /  /    "), " ", CTOD("  /  /    "), " "})
			Else
				aAdd(aTreeOS, {cOS, CTOD("  /  /    "), " ", CTOD("  /  /    "), " ", " ", dDtIni, cHrIni, dDtFim, cHrFim})
			EndIf
		ElseIf cSeqRela == "0"
			aRetDtHr := fCompDtHr( {aTreeOS[nPos][2], aTreeOS[nPos][3], aTreeOS[nPos][4], aTreeOS[nPos][5]},;
			{dDtIni, cHrIni, dDtFim, cHrFim} )
			aTreeOS[nPos][2] := aRetDtHr[1]
			aTreeOS[nPos][3] := aRetDtHr[2]
			aTreeOS[nPos][4] := aRetDtHr[3]
			aTreeOS[nPos][5] := aRetDtHr[4]
		Else
			aRetDtHr := fCompDtHr( {aTreeOS[nPos][7], aTreeOS[nPos][8], aTreeOS[nPos][9], aTreeOS[nPos][10]},;
			{dDtIni, cHrIni, dDtFim, cHrFim} )
			aTreeOS[nPos][7] := aRetDtHr[1]
			aTreeOS[nPos][8] := aRetDtHr[2]
			aTreeOS[nPos][9] := aRetDtHr[3]
			aTreeOS[nPos][10] := aRetDtHr[4]
		EndIf

		//Grava dados da Tarefa
		nPos := aScan(aTreeTar, {|x| x[1]+x[2] == cOS+cCodTar})
		If nPos == 0
			//1    ; 2      ; 3              ; 4              ; 5              ; 6             ; 7             ; 8               ; 9               ; 10              ; 11           ; 12           ; 13
			//O.S. ; Tarefa ; Nome da Tarefa ; Dt. Prev. Ini. ; Ht. Prev. Ini. ; Dt. Prev. Fim ; Hr. Prev. Fim ; NIVEL NA ARVORE ; Dt. Real Inicio ; Hr. Real Inicio ; Dt. Real Fim ; Hr. Real Fim ; Sequ๊ncia ST5
			If cSeqRela == "0"
				aAdd(aTreeTar, {cOS, cCodTar, cNomeTar, dDtIni, cHrIni, dDtFim, cHrFim, " ", CTOD("  /  /    "), " ", CTOD("  /  /    "), " ", cT5Seque})
			Else
				aAdd(aTreeTar, {cOS, cCodTar, cNomeTar, CTOD("  /  /    "), " ", CTOD("  /  /    "), " ", " ", dDtIni, cHrIni, dDtFim, cHrFim, cT5Seque})
			EndIf
		ElseIf cSeqRela == "0"
			aRetDtHr := fCompDtHr( {aTreeTar[nPos][4], aTreeTar[nPos][5], aTreeTar[nPos][6], aTreeTar[nPos][7]},;
			{dDtIni, cHrIni, dDtFim, cHrFim} )
			aTreeTar[nPos][4] := aRetDtHr[1]
			aTreeTar[nPos][5] := aRetDtHr[2]
			aTreeTar[nPos][6] := aRetDtHr[3]
			aTreeTar[nPos][7] := aRetDtHr[4]
		Else
			aRetDtHr := fCompDtHr( {aTreeTar[nPos][9], aTreeTar[nPos][10], aTreeTar[nPos][11], aTreeTar[nPos][12]},;
			{dDtIni, cHrIni, dDtFim, cHrFim} )
			aTreeTar[nPos][9]  := aRetDtHr[1]
			aTreeTar[nPos][10] := aRetDtHr[2]
			aTreeTar[nPos][11] := aRetDtHr[3]
			aTreeTar[nPos][12] := aRetDtHr[4]
		EndIf

		//Grava dados do Tipo de Registro
		If !lIsSubIns
			nPos := aScan(aTreeTip, {|x| x[1]+x[2]+x[4] == cOS+cCodTar+cTipoReg})
		Else
			nPos := aScan(aTreeTip, {|x| x[1]+x[2]+x[4] == cOS+cCodTar+"E"}) //Trata o Sub Insumo de Mao de Obra como uma Especialidade
		EndIf
		If nPos == 0
			//1    ; 2      ; 3              ; 4                ; 5            ; 6              ; 7              ; 8             ; 9             ; 10              ; 11              ; 12              ; 13           ; 14
			//O.S. ; Tarefa ; Nome da Tarefa ; Tipo de Registro ; Nome do Tipo ; Dt. Prev. Ini. ; Ht. Prev. Ini. ; Dt. Prev. Fim ; Hr. Prev. Fim ; NIVEL NA ARVORE ; Dt. Real Inicio ; Hr. Real Inicio ; Dt. Real Fim ; Hr. Real Fim
			If cSeqRela == "0"
				aAdd(aTreeTip, {cOS, cCodTar, cNomeTar, If(lIsSubIns,"E",cTipoReg), TIPREGBRW(If(lIsSubIns,"E",cTipoReg)), dDtIni, cHrIni, dDtFim, cHrFim, " ", CTOD("  /  /    "), " ", CTOD("  /  /    "), " "})
			Else
				aAdd(aTreeTip, {cOS, cCodTar, cNomeTar, If(lIsSubIns,"E",cTipoReg), TIPREGBRW(If(lIsSubIns,"E",cTipoReg)), CTOD("  /  /    "), " ", CTOD("  /  /    "), " ", " ", dDtIni, cHrIni, dDtFim, cHrFim})
			EndIf
		ElseIf cSeqRela == "0"
			aRetDtHr := fCompDtHr( {aTreeTip[nPos][6], aTreeTip[nPos][7], aTreeTip[nPos][8], aTreeTip[nPos][9]},;
			{dDtIni, cHrIni, dDtFim, cHrFim} )
			aTreeTip[nPos][6] := aRetDtHr[1]
			aTreeTip[nPos][7] := aRetDtHr[2]
			aTreeTip[nPos][8] := aRetDtHr[3]
			aTreeTip[nPos][9] := aRetDtHr[4]
		Else
			aRetDtHr := fCompDtHr( {aTreeTip[nPos][11], aTreeTip[nPos][12], aTreeTip[nPos][13], aTreeTip[nPos][14]},;
			{dDtIni, cHrIni, dDtFim, cHrFim} )
			aTreeTip[nPos][11] := aRetDtHr[1]
			aTreeTip[nPos][12] := aRetDtHr[2]
			aTreeTip[nPos][13] := aRetDtHr[3]
			aTreeTip[nPos][14] := aRetDtHr[4]
		EndIf

		//Grava dados do Insumo
		If !lIsSubIns
			nPos := aScan(aTreeIns, {|x| x[1]+x[2]+x[4]+x[6]+x[17] == cOS+cCodTar+cTipoReg+cCodIns+cDestino})
			If nPos == 0
				//1    ; 2      ; 3              ; 4                ; 5            ; 6             ; 7           ; 8              ; 9              ; 10            ; 11            ; 12              ; 13              ; 14              ; 15           ; 16           ; 17
				//O.S. ; Tarefa ; Nome da Tarefa ; Tipo de Registro ; Nome do Tipo ; Codigo Insumo ; Nome Insumo ; Dt. Prev. Ini. ; Ht. Prev. Ini. ; Dt. Prev. Fim ; Hr. Prev. Fim ; NIVEL NA ARVORE ; Dt. Real Inicio ; Hr. Real Inicio ; Dt. Real Fim ; Hr. Real Fim ; Destino (para Produtos)
				If cSeqRela == "0"
					aAdd(aTreeIns, {cOS, cCodTar, cNomeTar, cTipoReg, TIPREGBRW(cTipoReg), cCodIns, cNomeIns, dDtIni, cHrIni, dDtFim, cHrFim, " ", CTOD("  /  /    "), " ", CTOD("  /  /    "), " ", cDestino})
				Else
					aAdd(aTreeIns, {cOS, cCodTar, cNomeTar, cTipoReg, TIPREGBRW(cTipoReg), cCodIns, cNomeIns, CTOD("  /  /    "), " ", CTOD("  /  /    "), " ", " ", dDtIni, cHrIni, dDtFim, cHrFim, cDestino})
				EndIf
			ElseIf cSeqRela == "0"
				aRetDtHr := fCompDtHr( {aTreeIns[nPos][8], aTreeIns[nPos][9], aTreeIns[nPos][10], aTreeIns[nPos][11]},;
				{dDtIni, cHrIni, dDtFim, cHrFim} )
				aTreeIns[nPos][8]  := aRetDtHr[1]
				aTreeIns[nPos][9]  := aRetDtHr[2]
				aTreeIns[nPos][10] := aRetDtHr[3]
				aTreeIns[nPos][11] := aRetDtHr[4]
			Else
				aRetDtHr := fCompDtHr( {aTreeIns[nPos][13], aTreeIns[nPos][14], aTreeIns[nPos][15], aTreeIns[nPos][16]},;
				{dDtIni, cHrIni, dDtFim, cHrFim} )
				aTreeIns[nPos][13] := aRetDtHr[1]
				aTreeIns[nPos][14] := aRetDtHr[2]
				aTreeIns[nPos][15] := aRetDtHr[3]
				aTreeIns[nPos][16] := aRetDtHr[4]
			EndIf
		Else
			//Grava dados do Sub Insumo
			nPos := aScan(aTreeSubIns, {|x| x[1]+x[2]+x[4]+x[6]+x[18] == cOS+cCodTar+cTipoReg+cCodIns+cDestino})
			//Sub Insumo so' pode ser REALIZADO
			If nPos == 0
				//1    ; 2      ; 3              ; 4                ; 5            ; 6             ; 7           ; 8              ; 9              ; 10            ; 11            ; 12              ; 13              ; 14              ; 15           ; 16           ; 17                        ; 18
				//O.S. ; Tarefa ; Nome da Tarefa ; Tipo de Registro ; Nome do Tipo ; Codigo Insumo ; Nome Insumo ; Dt. Prev. Ini. ; Ht. Prev. Ini. ; Dt. Prev. Fim ; Hr. Prev. Fim ; NIVEL NA ARVORE ; Dt. Real Inicio ; Hr. Real Inicio ; Dt. Real Fim ; Hr. Real Fim ; Especialidade Relacionada ; Destino (para Produtos)
				aAdd(aTreeSubIns, {cOS, cCodTar, cNomeTar, cTipoReg, TIPREGBRW(cTipoReg), cCodIns, cNomeIns, CTOD("  /  /    "), " ", CTOD("  /  /    "), " ", " ", dDtIni, cHrIni, dDtFim, cHrFim, aGrdIns[nIns][12], cDestino})
			Else
				aRetDtHr := fCompDtHr( {aTreeSubIns[nPos][13], aTreeSubIns[nPos][14], aTreeSubIns[nPos][15], aTreeSubIns[nPos][16]},;
				{dDtIni, cHrIni, dDtFim, cHrFim} )
				aTreeSubIns[nPos][13] := aRetDtHr[1]
				aTreeSubIns[nPos][14] := aRetDtHr[2]
				aTreeSubIns[nPos][15] := aRetDtHr[3]
				aTreeSubIns[nPos][16] := aRetDtHr[4]
			EndIf
		EndIf
	Next nIns

	//Atualiza o Insumo de acordo com o Sub Insumo
	For nIns := 1 To Len(aTreeSubIns)
		cCodTar  := aTreeSubIns[nIns][2]

		cCodIns  := aTreeSubIns[nIns][17]
		cTipoReg := "E"

		nPos := aScan(aTreeIns, {|x| x[1]+x[2]+x[4]+AllTrim(x[6]) == cOS+cCodTar+cTipoReg+AllTrim(cCodIns)})
		If nPos > 0
			//Recebe a Data e Hora Realizada do Sub Insumo
			dDtIni := aTreeSubIns[nIns][13]
			cHrIni := aTreeSubIns[nIns][14]
			dDtFim := aTreeSubIns[nIns][15]
			cHrFim := aTreeSubIns[nIns][16]

			//Atualiza o Realizado da Especialidade
			aRetDtHr := fCompDtHr( {aTreeIns[nPos][13], aTreeIns[nPos][14], aTreeIns[nPos][15], aTreeIns[nPos][16]},;
			{dDtIni, cHrIni, dDtFim, cHrFim} )
			aTreeIns[nPos][13] := aRetDtHr[1]
			aTreeIns[nPos][14] := aRetDtHr[2]
			aTreeIns[nPos][15] := aRetDtHr[3]
			aTreeIns[nPos][16] := aRetDtHr[4]

			//Recebe a Data e Hora Prevista da Especialidade
			dDtIni := aTreeIns[nPos][8]
			cHrIni := aTreeIns[nPos][9]
			dDtFim := aTreeIns[nPos][10]
			cHrFim := aTreeIns[nPos][11]

			//Atualiza o Previsto do Sub Insumo
			aRetDtHr := fCompDtHr( {aTreeSubIns[nIns][8], aTreeSubIns[nIns][9], aTreeSubIns[nIns][10], aTreeSubIns[nIns][11]},;
			{dDtIni, cHrIni, dDtFim, cHrFim} )
			aTreeSubIns[nIns][8]  := aRetDtHr[1]
			aTreeSubIns[nIns][9]  := aRetDtHr[2]
			aTreeSubIns[nIns][10] := aRetDtHr[3]
			aTreeSubIns[nIns][11] := aRetDtHr[4]
		EndIf
	Next nIns

	//Calcula os Percentuais
	fGrdPercs()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfGrdPercs บAutor  ณWagner S. de Lacerdaบ Data ณ  28/07/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calcula a Porcentagem de Conclusao dos Insumos, Tipos de   บฑฑ
ฑฑบ          ณ Registro, Tarefas e da propria O.S.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T. -> Percentuais calculados.                             บฑฑ
ฑฑบ          ณ .F. -> Nao foram calculados os percentuais.                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fGrdPercs()

	Local nPerExec
	Local nPos, nPrev
	Local nX, nY

	aPercOS     := {}
	aPercTars   := {}
	aPercTips   := {}
	aPercIns    := {}
	aPercSubIns := {}

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Porcentagem: Insumos                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nX := 1 To Len(aGrdIns)
		nPerExec := aGrdIns[nX][13]
		nPrev := 0

		//Verifica o Insumo Previsto. Se o Previsto estiver 100%, entao joga o Percentual Executado como 100% (o 'Calculo' para o Insumo Previsto estar 100% e' de responsabilidade da funcao 'fGrdConst()')
		If AllTrim(aGrdIns[nX][3]) == "0"
			nPrev := nX
		Else
			nPrev := aScan(aGrdIns, {|x| x[1]+x[6]+x[4]+x[17] == aGrdIns[nX][1]+aGrdIns[nX][6]+aGrdIns[nX][4]+aGrdIns[nX][17] .And. AllTrim(x[3]) == "0" })
		EndIf
		If nPrev > 0 .And. aGrdIns[nPrev][13] >= 100
			nPerExec := 100
		EndIf

		//Atribui o calculo do Percentual Executado para o Insumo
		If Empty(aGrdIns[nX][12])
			nPos := aScan(aPercIns, {|x| x[1]+x[2]+x[3]+x[4]+x[5] == cOS+aGrdIns[nX][1]+aGrdIns[nX][6]+aGrdIns[nX][4]+aGrdIns[nX][17] })
		Else
			nPos := aScan(aPercIns, {|x| x[1]+x[2]+x[3]+AllTrim(x[4]) == cOS+aGrdIns[nX][1]+"E"+AllTrim(aGrdIns[nX][12]) })
		EndIf
		If nPos == 0
			//1    ; 2      ; 3                ; 4                ; 5                                  ; 6                          ; 7
			//O.S. ; Tarefa ; Tipo de Registro ; Codigo do Insumo ; Destino do Insumo (para Produtos)  ; Quantidade do mesmo Insumo ; Porcentagem Calculada
			aAdd(aPercIns, {cOS, aGrdIns[nX][1], aGrdIns[nX][6], aGrdIns[nX][4], aGrdIns[nX][17], 1, nPerExec})
		Else
			If aGrdIns[nX][6] == "M"
				//Mao de Obra nao e' acumulativa, e sim sempre a maior
				If nPerExec > aPercIns[nPos][7]
					//Atualiza como se tudo fosse a mesma porcentagem MAIOR
					aPercIns[nPos][7] := nPerExec * aPercIns[nPos][6]
				EndIf
			Else
				aPercIns[nPos][6] += 1
				//Caso contrario, apenas acumula a porcentagem
				aPercIns[nPos][7] += nPerExec
			EndIf
		EndIf

		//Atribui o calculo do Percentual Executado para o Sub Insumo
		If !Empty(aGrdIns[nX][12])
			nPos := aScan(aPercSubIns, {|x| x[1]+x[2]+x[3]+x[4] == cOS+aGrdIns[nX][1]+aGrdIns[nX][6]+aGrdIns[nX][4] })

			If nPos == 0
				//1    ; 2      ; 3                ; 4                ; 5                          ; 6
				//O.S. ; Tarefa ; Tipo de Registro ; Codigo do Insumo ; Quantidade do mesmo Insumo ; Porcentagem Calculada
				aAdd(aPercSubIns, {cOS, aGrdIns[nX][1], aGrdIns[nX][6], aGrdIns[nX][4], 1, nPerExec})
			Else
				aPercSubIns[nPos][5] += 1

				If aGrdIns[nX][6] == "M"
					//Mao de Obra nao e' acumulativa, e sim sempre a maior
					If nPerExec > aPercSubIns[nPos][6]
						//Atualiza como se tudo fosse a mesma porcentagem MAIOR
						aPercSubIns[nPos][6] := nPerExec
					EndIf
				Else
					//Caso contrario, apenas acumula a porcentagem
					aPercSubIns[nPos][6] += nPerExec
				EndIf
			EndIf
		EndIf
	Next nX

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Porcentagem: Tipos de Registro              ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nX := 1 To Len(aPercIns)
		If lOSTermino
			nPerExec := 100
		Else
			If aPercIns[nX][3] == "M"
				//Para Mao de Obra, sempre vale a Maior Porcentagem
				nPerExec := aPercIns[nX][7]
			Else
				nPerExec := (aPercIns[nX][7] / aPercIns[nX][6])
			EndIf
		EndIf
		aPercIns[nX][7] := Round(nPerExec, 2) //Porcentagem do Insumo

		nPos := aScan(aPercTips, {|x| x[1]+x[2]+x[3] == aPercIns[nX][1]+aPercIns[nX][2]+aPercIns[nX][3] })
		If nPos == 0
			//1    ; 2      ; 3                ; 4                     ; 5
			//O.S. ; Tarefa ; Tipo de Registro ; Quantidade de Insumos ; Porcentagem Calculada
			aAdd(aPercTips, {aPercIns[nX][1], aPercIns[nX][2], aPercIns[nX][3], 1, aPercIns[nX][7]})
		Else
			aPercTips[nPos][4] += 1
			aPercTips[nPos][5] += aPercIns[nX][7]
		EndIf
	Next nX

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Porcentagem: Tarefas                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nX := 1 To Len(aPercTips)
		aPercTips[nX][5] := Round( (aPercTips[nX][5] / aPercTips[nX][4]) , 2) //Porcentagem do Tipo de Registro

		nPos := aScan(aPercTars, {|x| x[1]+x[2] == aPercTips[nX][1]+aPercTips[nX][2] })
		If nPos == 0
			//1    ; 2      ; 3                               ; 4
			//O.S. ; Tarefa ; Quantidade de Tipos de Registro ; Porcentagem Calculada
			aAdd(aPercTars, {aPercTips[nX][1], aPercTips[nX][2], 1, aPercTips[nX][5]})
		Else
			aPercTars[nPos][3] += 1
			aPercTars[nPos][4] += aPercTips[nX][5]
		EndIf
	Next nX

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Porcentagem: Ordem de Servico               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nX := 1 To Len(aPercTars)
		aPercTars[nX][4] := Round( (aPercTars[nX][4] / aPercTars[nX][3]) , 2) //Porcentagem do Tipo de Registro

		nPos := aScan(aPercOS, {|x| x[1] == aPercTars[nX][1] })
		If nPos == 0
			//1    ; 2                     ; 3
			//O.S. ; Quantidade de Tarefas ; Porcentagem Calculada
			aAdd(aPercOS, {aPercTars[nX][1], 1, aPercTars[nX][4]})
		Else
			aPercOS[nPos][2] += 1
			aPercOS[nPos][3] += aPercTars[nX][4]
		EndIf
	Next nX
	aPercOS[1][3] := Round( (aPercOS[1][3] / aPercOS[1][2]) , 2) //Porcentagem da O.S.

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Ordenacao                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aSort(aPercIns   , , , {|x,y| x[1]+x[2]+x[3]+x[4]+x[5] < y[1]+y[2]+y[3]+y[4]+y[5] })
	aSort(aPercSubIns, , , {|x,y| x[1]+x[2]+x[3]+x[4] < y[1]+y[2]+y[3]+y[4] })
	aSort(aPercTips  , , , {|x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3] })
	aSort(aPercTars  , , , {|x,y| x[1]+x[2] < y[1]+y[2] })
	aSort(aPercOS    , , , {|x,y| x[1] < y[1] })

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfGrdProjecบAutor  ณWagner S. de Lacerdaบ Data ณ  18/04/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega a projecao de conclusao da tarefa.                 บฑฑ
ฑฑบ          ณ (barra Projecao).                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fGrdProjec()

	Local aAreaTRB := {}
	Local aProjecao := {}
	Local aConcluida := {} //Controla as Tarefas Concluidas
	Local aRetFalta := {}
	Local aDisp := {}

	Local aRealizado := {} //Armazena as posicoes dos Insumo relacionados que sao Realizados
	Local nRealizado := 0
	Local nBuscaReal := {}
	Local lTemRealiz := .F.
	Local lProjeta   := .F.
	Local lAtrasado  := .F., lFuturo := .F.

	Local nX, nY

	Local cCodIns
	Local cLocal
	Local dDtIni, dDtFim, dDtFalta
	Local cHrIni, cHrFim, cHrFalta
	Local nSaldoDisp
	Local nQuantid, nQuanRec, nPos, nPerMDO, nQtdeReal

	Local cFalta
	Local nTotal, nHrFalta, nMiFalta
	Local nHora, nMins
	Local nAT

	For nX := 1 To Len(aGrdIns)
		cCodIns := aGrdIns[nX][4]

		dDtIni := aGrdIns[nX][8]
		cHrIni := aGrdIns[nX][9]
		dDtFim := aGrdIns[nX][10]
		cHrFim := aGrdIns[nX][11]

		nPerMDO   := 0
		nQtdeReal := 0

		lProjeta := .F.

		nQuanRec := If(aGrdIns[nX][18] > 0, aGrdIns[nX][18], 1)
		nQuantid := ( aGrdIns[nX][14] * nQuanRec )
		cFalta := cValToChar(nQuantid)

		If AllTrim(aGrdIns[nX][3]) == "0" //Calcula com base no Insumo Previsto

			If !lOSTermino //Projeta/Atrasa somente se a O.S. NAO estiver terminada

				lProjeta := .T.

				//Busca os Insumos Realizados relacionados ao Previsto
				aRealizado := {}
				For nBuscaReal := 1 To Len(aGrdIns)
					If aGrdIns[nX][6] == "E" //Para Especialidade, busca os Funcionarios relacionados
						If aGrdIns[nBuscaReal][1] == aGrdIns[nX][1] .And. aGrdIns[nBuscaReal][6] == "M" .And. AllTrim(aGrdIns[nBuscaReal][12]) == AllTrim(aGrdIns[nX][4]) ;
						.And. AllTrim(aGrdIns[nBuscaReal][3]) <> "0" .And. AllTrim(aGrdIns[nBuscaReal][3]) <> _ATRASO .And. AllTrim(aGrdIns[nBuscaReal][3]) <> _PROJEC

							aAdd(aRealizado, nBuscaReal)
						EndIf
					Else
						If aGrdIns[nBuscaReal][1] == aGrdIns[nX][1] .And. aGrdIns[nBuscaReal][6] == aGrdIns[nX][6] .And. aGrdIns[nBuscaReal][4] == aGrdIns[nX][4] .And. If(aGrdIns[nX][6] == "P" , aGrdIns[nBuscaReal][17] == aGrdIns[nX][17], .T.) ;
						.And. AllTrim(aGrdIns[nBuscaReal][3]) <> "0" .And. AllTrim(aGrdIns[nBuscaReal][3]) <> _ATRASO .And. AllTrim(aGrdIns[nBuscaReal][3]) <> _PROJEC

							aAdd(aRealizado, nBuscaReal)
						EndIf
					EndIf
				Next nBuscaReal
				lTemRealiz := ( Len(aRealizado) > 0 )

				//O Insumo esta' atrasado se a Data/Hora atual for maior que a Prevista e ainda nao estiver 100% concluido
				lAtrasado := ( aGrdIns[nX][13] < 100 .And. (dCOSDtIni > dDtFim .Or. (dCOSDtIni == dDtFim .And. cCOSHrIni > cHrFim))  )
				//Verifica agora se algum Insumo REALIZADO esta 100%. Se estiver, entao ja' esta' concluido o Previsto, e nao ha' mais atraso
				If lTemRealiz .And. lAtrasado
					For nBuscaReal := 1 To Len(aRealizado)
						nRealizado := aRealizado[nBuscaReal]

						If aGrdIns[nRealizado][13] >= 100 //100% Concluido
							lAtrasado := .F.
							Exit
						EndIf
					Next nBuscaReal
				EndIf
				If lAtrasado
					aAdd(aProjecao, { aGrdIns[nX][1], aGrdIns[nX][2], _ATRASO, aGrdIns[nX][4], aGrdIns[nX][5], aGrdIns[nX][6], aGrdIns[nX][7],;
					dDtFim, cHrFim, dCOSDtIni, cCOSHrIni, aGrdIns[nX][12], aGrdIns[nX][13], nQuantid,;
					aGrdIns[nX][15], aGrdIns[nX][16], aGrdIns[nX][17], aGrdIns[nX][18],aGrdIns[nX][19] } )
				EndIf

				//Verifica se o insumo e' futuro
				lFuturo := ( dDtIni > dCOSDtIni .Or. (dDtIni == dCOSDtIni .And. cHrIni > cCOSHrIni) )

				If aGrdIns[nX][6] == "P"
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ Projecao: Produto            ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					cLocal := aGrdIns[nX][7]

					If lUsaIntEst //Usa Integracao com Estoque?
						dbSelectArea("SB2")
						dbSetOrder(1)
						If !dbSeek(xFilial("SB2")+cCodIns+cLocal)
							CriaSB2(cCodIns,cLocal)
						EndIf
						//					nSaldoDisp := SaldoSB2(.F., .T./*Considera Empenho*/, dCOSDtIni, .F.)
						nSaldoDisp := If(GetNewPar("MV_NGINTER","") == "M",; 			// Integracao por Mensagem Unica
						NGMUStoLvl(cCodIns, cLocal,.T.),;		  		// Atualiza tabela
						SaldoSB2(.F.,.T.,dCOSDtIni,.F.))		// Atualiza tabela SB2
					Else
						nSaldoDisp := 0
					EndIf

					If lTemRealiz //Se ja possuir Insumo realizado, somente ira projetar caso nao esteja 100% realizado
						For nBuscaReal := 1 To Len(aRealizado)
							nRealizado := aRealizado[nBuscaReal]

							nQtdeReal += aGrdIns[nRealizado][14]

							If nBuscaReal == 1 .Or. aGrdIns[nRealizado][10] > dDtFim ;
							.Or. ( aGrdIns[nRealizado][10] == dDtFim .And. aGrdIns[nRealizado][11] > cHrFim )

								dDtFim := aGrdIns[nRealizado][10]
								cHrFim := aGrdIns[nRealizado][11]
							EndIf

							If nQtdeReal >= nQuantid
								lProjeta := .F.
								Exit
							ElseIf nSaldoDisp < nQuantid
								//Busca a Disponibilidade do Produto
								aDisp := fGrdDispon("P", aGrdIns[nRealizado][4], dDtIni, cHrIni, dDtFim, cHrFim, cOS)
								dDtFim := aDisp[1]
								cHrFim := aDisp[2]
							EndIf
						Next nBuscaReal
					Else
						//Busca a Disponibilidade do Produto
						aDisp := fGrdDispon("P", aGrdIns[nX][4], dDtIni, cHrIni, dDtFim, cHrFim, cOS)
						dDtFim := aDisp[1]
						cHrFim := aDisp[2]
					EndIf
				ElseIf aGrdIns[nX][6] == "M"
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ Projecao: Mao de Obra        ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If lTemRealiz //Verifica insumo realizado
						For nBuscaReal := 1 To Len(aRealizado)
							nRealizado := aRealizado[nBuscaReal]

							If lPerMDO
								If aGrdIns[nRealizado][13] == 100
									aAdd(aConcluida, aGrdIns[nRealizado][1])
									lProjeta := .F.
									nPerMDO := 100
									Exit
								ElseIf aGrdIns[nRealizado][13] < 100 .And. aGrdIns[nRealizado][13] > nPerMDO
									lProjeta := .T.
									nPerMDO := aGrdIns[nRealizado][13]

									dDtFim := aGrdIns[nRealizado][10]
									cHrFim := aGrdIns[nRealizado][11]

									//Total de Horas
									If Empty(aGrdIns[nRealizado][13])
										nTotal := aGrdIns[nRealizado][14]
									Else
										nTotal := ( (aGrdIns[nRealizado][14] * 100) / aGrdIns[nRealizado][13] )
									EndIf

									//Calcula o que ainda tem que realizar
									cFalta := cValToChar( (nTotal - aGrdIns[nRealizado][14]) )

									aDisp := fGrdDispon("M", aGrdIns[nRealizado][4], dDtIni, cHrIni, dDtFim, cHrFim, cOS)
									dDtFim := aDisp[1]
									cHrFim := aDisp[2]
								EndIf
							Else
								nQtdeReal += aGrdIns[nRealizado][14]

								If nQtdeReal >= nQuantid //Se a quantidade for Maior ou Igual a prevista, entao esta' concluida
									aAdd(aConcluida, aGrdIns[nRealizado][1])
									lProjeta := .F.
									nPerMDO := 100
									Exit
								Else //Senao deve projetar com o que falta
									cFalta := cValToChar( (nQuantid - nQtdeReal) )

									//Busca a Dispoonibilidade da Mao de Obra
									aDisp := fGrdDispon("M", aGrdIns[nRealizado][4], dDtIni, cHrIni, dDtFim, cHrFim, cOS)
									dDtFim := aDisp[1]
									cHrFim := aDisp[2]
								EndIf
							EndIf
						Next nBuscaReal
					Else
						//Busca a Disponibilidade da Mao de Obra
						aDisp := fGrdDispon("M", aGrdIns[nX][4], dDtIni, cHrIni, dDtFim, cHrFim, cOS)
						dDtFim := aDisp[1]
						cHrFim := aDisp[2]
					EndIf
				ElseIf aGrdIns[nX][6] == "F"
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ Projecao: Ferramenta         ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If lTemRealiz
						For nBuscaReal := 1 To Len(aRealizado)
							nRealizado := aRealizado[nBuscaReal]

							nQtdeReal += aGrdIns[nRealizado][14]

							If nBuscaReal == 1 .Or. aGrdIns[nRealizado][10] > dDtFim ;
							.Or. ( aGrdIns[nRealizado][10] == dDtFim .And. aGrdIns[nRealizado][11] > cHrFim )

								dDtFim := aGrdIns[nRealizado][10]
								cHrFim := aGrdIns[nRealizado][11]
							EndIf

							If nQtdeReal >= nQuantid
								lProjeta := .F.
								Exit
							Else
								cFalta := cValToChar( (nQuantid - nQtdeReal) )

								//Busca a Disponibilidade da Ferramenta
								aDisp := fGrdDispon("F", aGrdIns[nRealizado][4], dDtIni, cHrIni, dDtFim, cHrFim, cOS)
								dDtFim := aDisp[1]
								cHrFim := aDisp[2]
							EndIf
						Next nBuscaReal
					Else
						//Busca a Disponibilidade da Ferramenta
						aDisp := fGrdDispon("F", aGrdIns[nX][4], dDtIni, cHrIni, dDtFim, cHrFim, cOS)
						dDtFim := aDisp[1]
						cHrFim := aDisp[2]
					EndIf
				ElseIf aGrdIns[nX][6] == "E"
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ Projecao: Especialidade      ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					//Deve ser semelhante a Mao de Obra, afinal, a Especialidade possui relacao com o Funcionario
					If lTemRealiz
						For nBuscaReal := 1 To Len(aRealizado)
							nRealizado := aRealizado[nBuscaReal]

							If lPerMDO
								If aGrdIns[nRealizado][13] == 100
									aAdd(aConcluida, aGrdIns[nRealizado][1])
									lProjeta := .F.
									nPerMDO := 100
									Exit
								ElseIf aGrdIns[nRealizado][13] < 100 .And. aGrdIns[nRealizado][13] > nPerMDO
									lProjeta := .T.
									nPerMDO := aGrdIns[nRealizado][13]

									dDtFim := aGrdIns[nRealizado][10]
									cHrFim := aGrdIns[nRealizado][11]

									//Total de Horas
									If Empty(aGrdIns[nRealizado][13])
										nTotal := aGrdIns[nRealizado][14]
									Else
										nTotal := ( (aGrdIns[nRealizado][14] * 100) / aGrdIns[nRealizado][13] )
									EndIf

									//Calcula o que ainda tem que realizar
									cFalta := cValToChar( (nTotal - aGrdIns[nRealizado][14]) )

									//Busca a Dispoonibilidade da Mao de Obra
									aDisp := fGrdDispon("M", aGrdIns[nRealizado][4], dDtIni, cHrIni, dDtFim, cHrFim, cOS)
									dDtFim := aDisp[1]
									cHrFim := aDisp[2]
								EndIf
							Else
								nQtdeReal += aGrdIns[nRealizado][14]

								If nQtdeReal >= nQuantid //Se a quantidade for Maior ou Igual a prevista, entao esta' concluida
									aAdd(aConcluida, aGrdIns[nRealizado][1])
									lProjeta := .F.
									nPerMDO := 100
									Exit
								Else //Senao deve projetar com o que falta
									cFalta := cValToChar( (nQuantid - nQtdeReal) )

									//Busca a Dispoonibilidade da Mao de Obra
									aDisp := fGrdDispon("M", aGrdIns[nRealizado][4], dDtIni, cHrIni, dDtFim, cHrFim, cOS)
									dDtFim := aDisp[1]
									cHrFim := aDisp[2]
								EndIf
							EndIf
						Next nBuscaReal
					EndIf
				Else
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ Projecao: Terceiro           ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If lTemRealiz
						For nBuscaReal := 1 To Len(aRealizado)
							nRealizado := aRealizado[nBuscaReal]

							nQtdeReal += aGrdIns[nRealizado][14]

							If nBuscaReal == 1 .Or. aGrdIns[nRealizado][10] > dDtFim ;
							.Or. ( aGrdIns[nRealizado][10] == dDtFim .And. aGrdIns[nRealizado][11] > cHrFim )

								dDtFim := aGrdIns[nRealizado][10]
								cHrFim := aGrdIns[nRealizado][11]
							EndIf

							If nQtdeReal >= nQuantid
								lProjeta := .F.
								Exit
							Else
								cFalta := cValToChar( (nQuantid - nQtdeReal) )
							EndIf
						Next nBuscaReal
					EndIf
				EndIf

				//Recebe a Data e Hora para Projetar
				If lProjeta
					If aGrdIns[nX][6] == "P" //Produto
						//Recebe a Data e Hora maior
						If dCOSDtIni > dDtFim .Or. ( dCOSDtIni == dDtFim .And. cCOSHrIni > cHrFim )
							dDtFim := dCOSDtIni
							cHrFim := cCOSHrIni
						ElseIf lFuturo
							//Se for futuro, joga a Data/Hora final de aplicacao do produto
							dDtFim := aGrdIns[nX][10]
							cHrFim := aGrdIns[nX][11]
						EndIf
					Else //Especialidade / Feramenta / Mao de Obra / Terceiro
						//Se ainda nao estiver atrasado o insumo (ainda nao passou da data/hora fim prevista), utiliza a Data/Hora Inicio para projetar o quanto ainda falta ser realizado
						If !lAtrasado
							dDtFim := dDtIni
							cHrFim := cHrIni
						EndIf
						//Se for um insumo futuro (data/hora inicial maior que a atual), entao joga essa data/hora para as Data/Hora final para o calcula de quanto falta a realizar
						If lFuturo
							dDtFalta := dDtIni
							cHrFalta := cHrIni
						Else
							//Se nao for, joga a Data/Hora atual
							dDtFalta := dCOSDtIni
							cHrFalta := cCOSHrIni
						EndIf

						//Calcula a Data e Hora do quanto falta para realizar do insumo
						aRetFalta := fGrdFalta(cFalta,dDtFim,cHrFim,dDtFalta,cHrFalta,lTemRealiz)
						dDtFim := aRetFalta[1]
						cHrFim := aRetFalta[2]
					EndIf
				EndIf
			EndIf

			//Adiciona a Projecao
			If lProjeta
				dDtIni := aGrdIns[nX][10]
				cHrIni := aGrdIns[nX][11]

				aAdd(aProjecao, { aGrdIns[nX][1], aGrdIns[nX][2], _PROJEC, aGrdIns[nX][4], aGrdIns[nX][5], aGrdIns[nX][6], aGrdIns[nX][7],;
				dDtIni, cHrIni, dDtFim, cHrFim, aGrdIns[nX][12], aGrdIns[nX][13], nQuantid,;
				aGrdIns[nX][15], aGrdIns[nX][16], aGrdIns[nX][17], aGrdIns[nX][18],aGrdIns[nX][19] } )
			EndIf
		EndIf
	Next nX

	//Deleta as Projecoes das Tarefas que ja foram CONCLUIDAS
	For nX := 1 To Len(aConcluida)
		While .T.
			nPos := aScan(aProjecao, {|x| x[1] == aConcluida[nX] })
			If nPos == 0
				Exit
			Else
				aDel(aProjecao, nPos)
				aSize(aProjecao, (Len(aProjecao)-1))
			EndIf
		End
	Next nX

	//Repassa para o array de Insumos as Projecoes
	For nX := 1 To Len(aProjecao)
		aAdd(aGrdIns, aProjecao[nX])
	Next nX

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfGrdFalta บAutor  ณWagner S. de Lacerdaบ Data ณ  14/07/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica quantas dias e horas faltam para o fim do item.   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ aRet -> Array com:                                         บฑฑ
ฑฑบ          ณ          [1] -                                             บฑฑ
ฑฑบ          ณ          [2] -                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cTipo ------> Obrigatorio;                                 บฑฑ
ฑฑบ          ณ               Define o Tipo do Insumo;                     บฑฑ
ฑฑบ          ณ cCodigo ----> Obrigatorio;                                 บฑฑ
ฑฑบ          ณ               Define o Codigo do Insumo.                   บฑฑ
ฑฑบ          ณ dDtIni -----> Obrigatorio;                                 บฑฑ
ฑฑบ          ณ               Indica a Data Inicial da utilizacao.         บฑฑ
ฑฑบ          ณ cHrIni -----> Obrigatorio;                                 บฑฑ
ฑฑบ          ณ               Indica a Hora Inicial da utilizacao.         บฑฑ
ฑฑบ          ณ dDtFim -----> Obrigatorio;                                 บฑฑ
ฑฑบ          ณ               Indica a Data Final da utilizacao.           บฑฑ
ฑฑบ          ณ cHrFim -----> Obrigatorio;                                 บฑฑ
ฑฑบ          ณ               Indica a Data Final da utilizacao.           บฑฑ
ฑฑบ          ณ cOrdemServ -> Obrigatorio;                                 บฑฑ
ฑฑบ          ณ               Indica a Ordem de Servico.                   บฑฑ
ฑฑบ          ณ cCodTarefa -> Obrigatorio;                                 บฑฑ
ฑฑบ          ณ               Indica a Tarefa do Insumo.                   บฑฑ
ฑฑบ          ณ lInsReal ---> Obrigatorio;                                 บฑฑ
ฑฑบ          ณ               Indica se ha' Insumo Realizado na previsao.  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fGrdFalta(cFalta, dDataIni, cHoraIni, dDataFim, cHoraFim, lInsReal)

	Local aCalc, nDiAtu, nHrAtu, nMiAtu
	Local nAT
	Local nHora, nHrFalta
	Local nMins, nMiFalta

	nDiAtu := 0
	nHrAtu := 0
	nMiAtu := 0
	//Compensa o tempo menor para calcular o quanto falta (somente caso nao haja insumo realizado)
	If !lInsReal
		If ( dDataFim < dDataIni ) .Or. ( dDataFim == dDataIni .And. cHoraFim < cHoraIni )
			aCalc  := aClone( NGCALCDHM(dDataFim, cHoraFim, dDataIni, cHoraIni) )
			nDiAtu := aCalc[1]
			nHrAtu := aCalc[2] + (nDiAtu * 24)
			nMiAtu := aCalc[3]
		EndIf
	EndIf

	//Verifica as Horas e Minutos que ainda faltam
	nAT := AT(".",cFalta)
	If nAT == 0
		nHrFalta := Val(cFalta)
		nMiFalta := 0
	Else
		nHrFalta := Val(SubStr(cFalta,1,nAT-1))
		nMiFalta := ( Val("0."+SubStr(cFalta,nAT+1,2)) * 60 )
	EndIf
	nHrFalta := Round(nHrFalta,0)
	nMiFalta := Round(nMiFalta,0)

	//Retira dos Minutos Faltantes o que ja' passou com a Diferenca de Data/Hora Inicio e Fim
	While nMiAtu > 0
		nMiFalta := nMiFalta - 1
		nMiAtu := nMiAtu - 1

		If nMiFalta < 0
			nHrFalta--
			nMiFalta := 59
		EndIf
	End
	If nMiFalta < 0
		nMiFalta := 0
	EndIf

	//Retira das Horas Faltantes o que ja' passou com a Diferenca de Data/Hora Inicio e Fim
	While nHrAtu > 0
		nHrFalta := nHrFalta - 1
		nHrAtu := nHrAtu - 1
	End
	If nHrFalta < 0
		nHrFalta := 0
		nMiFalta := 0
	EndIf

	//Recebe a Data e Hora maior
	If dDataIni < dDataFim
		dDataIni := dDataFim
		cHoraIni := cHoraFim
	ElseIf dDataIni == dDataFim .And. cHoraIni < cHoraFim
		cHoraIni := cHoraFim
	EndIf

	//Calcula a Data e Hora
	nHora := Val(SubStr(cHoraIni,1,2)) + nHrFalta
	nMins := Val(SubStr(cHoraIni,4,2)) + nMiFalta

	While nMins >= 60
		nHora++
		nMins := nMins - 60
	End

	While nHora >= 24
		dDataIni++
		nHora := nHora - 24
	End

	cHoraIni := PADL(nHora,2,"0") + ":" + PADL(nMins,2,"0")

Return {dDataIni, cHoraIni}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfGrdDisponบAutor  ณWagner S. de Lacerdaบ Data ณ  20/04/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica a Disponibilidade de Produtos/Mao de Obra/Ferra-  บฑฑ
ฑฑบ          ณ mentas para uma determinada Data e Hora.                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ aRet ->                                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cTipo ------> Obrigatorio;                                 บฑฑ
ฑฑบ          ณ               Define o Tipo do Insumo;                     บฑฑ
ฑฑบ          ณ cCodigo ----> Obrigatorio;                                 บฑฑ
ฑฑบ          ณ               Define o Codigo do Insumo.                   บฑฑ
ฑฑบ          ณ dDtIni -----> Obrigatorio;                                 บฑฑ
ฑฑบ          ณ               Indica a Data Inicial da utilizacao.         บฑฑ
ฑฑบ          ณ cHrIni -----> Obrigatorio;                                 บฑฑ
ฑฑบ          ณ               Indica a Hora Inicial da utilizacao.         บฑฑ
ฑฑบ          ณ dDtFim -----> Obrigatorio;                                 บฑฑ
ฑฑบ          ณ               Indica a Data Final da utilizacao.           บฑฑ
ฑฑบ          ณ cHrFim -----> Obrigatorio;                                 บฑฑ
ฑฑบ          ณ               Indica a Data Final da utilizacao.           บฑฑ
ฑฑบ          ณ cOrdemServ -> Obrigatorio;                                 บฑฑ
ฑฑบ          ณ               Indica a Ordem de Servico.                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fGrdDispon(cTipo, cCodigo, dDtIni, cHrIni, dDtFim, cHrFim, cOrdemServ)

	Local aRet    := {}
	Local cOP     := ""
	Local aNumSC  := {}, cNumSC  := ""
	Local dDtDisp := dDtIni
	Local cHrDisp := cHrIni
	Local nPrazo  := 0, nHora := 0, nMins := 0
	Local nX

	Local lPedido := .F.

	Default cOrdemServ := ""

	If cTipo == "P"
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Produto                      ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If lUsaIntEst //Usa Integracao com Estoque?
			//Busca Documento de Entrada
			For nX := 1 To Len(aI5ERPDoc)
				If AllTrim(aI5ERPDoc[nX][3]) == AllTrim(cCodigo) .And. aI5ERPDoc[nX][14] > dDtFim
					dDtDisp := aI5ERPDoc[nX][14]
					cHrDisp := cCOSHrIni
				EndIf
			Next nX

			//Verifica se existe SC2 (Ordem de Producao)
			dbSelectArea("SC2")
			dbSetOrder(9)
			If dbSeek(xFilial("SC2")+cOrdemServ)
				cOP := SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN
			EndIf

			//Busca Solicitacao ao Armazem
			For nX := 1 To Len(aI5ERPArm)
				If AllTrim(aI5ERPArm[nX][3]) == AllTrim(cCodigo) .And. aI5ERPArm[nX][10] > dDtFim
					dDtDisp := aI5ERPArm[nX][10]
					cHrDisp := cCOSHrIni
				EndIf
			Next nX
		ElseIf lUsaIntCom //Usa Integracao com Compras?
			//Verifica se existe SC1 (Solicitacao de Compra) com a Ordem de Producao correspondente a O.S.
			dbSelectArea("SC1")
			dbSetOrder(4)
			If dbSeek(xFilial("SC1")+cOS+"OS001")
				cOP := cOS+"OS001"
			EndIf
		EndIf

		lPedido := .F.
		If !Empty(cOP) .And. lUsaIntCom //Usa Integracao com Compras?
			//Busca Solicitacao de Compras
			aNumSC := {}
			For nX := 1 To Len(aI5ERPCom)
				If AllTrim(aI5ERPCom[nX][3]) == AllTrim(cCodigo)
					dDtDisp := aI5ERPCom[nX][9]
					cHrDisp := cCOSHrIni

					aAdd(aNumSC,aI5ERPCom[nX][1])
				EndIf
			Next nX

			//Busca Pedido de Compra
			For nX := 1 To Len(aNumSC)
				cNumSC := aNumSC[nX]
				dbSelectArea("SC7")
				dbSetOrder(2)
				If dbSeek(xFilial("SC7")+cCodigo)
					While !Eof() .And. SC7->C7_FILIAL == xFilial("SC7") .And. AllTrim(SC7->C7_PRODUTO) == AllTrim(cCodigo)

						If SC7->C7_NUMSC == cNumSC
							If SC7->C7_DATPRF > dDtDisp
								dDtDisp := SC7->C7_DATPRF
								cHrDisp := cCOSHrIni

								lPedido := .T.
							EndIf
						EndIf

						dbSelectArea("SC7")
						dbSkip()
					End
				EndIf
			Next nX
		EndIf

		If !lPedido
			//Define Prazo de Entrega apenas se nao houver um Pedido de Compra
			dbSelectArea("SB1")
			dbSetOrder(1)
			If dbSeek(xFilial("SB1")+cCodigo) .And. !Empty(SB1->B1_PE)
				nPrazo := SB1->B1_PE

				Do Case
					Case SB1->B1_TIPE == "H" //Horas
					While nPrazo >= 24
						dDtDisp := dDtDisp + 1
						nPrazo := nPrazo - 24
					End

					nHora := Val(SubStr(cHrFim,1,2)) + nPrazo
					nMins := Val(SubStr(cHrFim,4,2))
					While nHora >= 24
						dDtDisp := dDtDisp + 1
						nHora  := nHora - 24
					End

					cHrDisp := PADL(nHora,2,"0") + ":" + PADL(nMins,2,"0")
					Case SB1->B1_TIPE == "D" //Dias
					dDtDisp := dDtDisp + nPrazo
					Case SB1->B1_TIPE == "S" //Semanas
					dDtDisp := dDtDisp + (nPrazo * 7)
					Case SB1->B1_TIPE == "M" //Meses
					dDtDisp := dDtDisp + (nPrazo * 30)
					Case SB1->B1_TIPE == "A" //Anos
					dDtDisp := dDtDisp + (nPrazo * 365)
					OtherWise
					nPrazo := 0
				EndCase
			EndIf
		EndIf
	ElseIf cTipo == "M"
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Funcionario (Mao de Obra)    ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		//Busca Bloqueios
		dbSelectArea("STK")
		dbSetOrder(2)
		dbSeek(xFilial("STK")+SubStr(cCodigo,1,6)+DTOS(dDtDisp)+cHrDisp,.T.)

		If STK->TK_FILIAL <> xFilial("STK")
			dbSkip(-1)
		ElseIf STK->TK_FILIAL == xFilial("STK") .And. STK->TK_CODFUNC <> SubStr(cCodigo,1,6)
			dbSkip(-1)
		ElseIf STK->TK_DATAINI > dDtDisp
			dbSkip(-1)
			If Bof()
				dbSkip()
			ElseIf STK->TK_FILIAL <> xFilial("STK")
				dbSkip()
			ElseIf STK->TK_FILIAL == xFilial("STK") .And. STK->TK_CODFUNC <> SubStr(cCodigo,1,6)
				dbSkip()
			EndIf
		EndIf

		While !Eof() .And. STK->TK_FILIAL == xFilial("STK") .And. STK->TK_DATAFIM <= dDtFim .And. AllTrim(STK->TK_CODFUNC) == AllTrim(cCodigo)

			If !Empty(cOrdemServ) .And. STK->TK_ORDEM == cOrdemServ
				dbSelectArea("STK")
				dbSkip()
				Loop
			EndIf

			//Se a Data Inicio da utilizacao esta entre as datas do bloqueio, entao esta Data Inicio e' invalida
			//Logo, a disponibilidade sera ao fim do bloqueio
			If dDtDisp >= STK->TK_DATAINI .And. dDtDisp <= STK->TK_DATAFIM
				dDtDisp := STK->TK_DATAFIM
				cHrDisp := STK->TK_HORAFIM
			EndIf

			dbSelectArea("STK")
			dbSkip()
		End
	ElseIf cTipo == "F"
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Ferramenta                   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		dbSelectArea("SH9")
		dbSetOrder(3)
		dbSeek(xFilial("SH9")+"F"+SubStr(cCodigo,1,6)+DTOS(dDtDisp),.T.)

		If SH9->H9_FILIAL <> xFilial("SH9")
			dbSkip(-1)
		ElseIf SH9->H9_FILIAL == xFilial("SH9") .And. SH9->H9_FERRAM <> SubStr(cCodigo,1,6)
			dbSkip(-1)
		ElseIf SH9->H9_DTINI > dDtDisp
			dbSkip(-1)
			If Bof()
				dbSkip()
			ElseIf SH9->H9_FILIAL <> xFilial("SH9")
				dbSkip()
			ElseIf SH9->H9_FILIAL == xFilial("SH9") .And. SH9->H9_FERRAM <> SubStr(cCodigo,1,6)
				dbSkip()
			EndIf
		EndIf

		While !Eof() .And. SH9->H9_FILIAL == xFilial("SH9") .And. SH9->H9_DTFIM <= dDtFim  .And. SH9->H9_TIPO == "F" .And. AllTrim(SH9->H9_FERRAM) == AllTrim(cCodigo)

			If !Empty(cOrdemServ) .And. cOrdemServ $ SH9->H9_MOTIVO
				dbSelectArea("SH9")
				dbSkip()
				Loop
			EndIf

			//Se a Data Inicio da utilizacao esta entre as datas do bloqueio, entao esta Data Inicio e' invalida
			//Logo, a disponibilidade sera ao fim do bloqueio
			If dDtDisp >= SH9->H9_DTINI .And. dDtDisp <= SH9->H9_DTFIM
				dDtDisp := SH9->H9_DTFIM
				cHrDisp := SH9->H9_HRFIM
			EndIf

			dbSelectArea("SH9")
			dbSkip()
		End
	EndIf

	//A Data/Hora de Disponibilidade (Data/Hora Fim do Insumo) deve ser Maior ou Igual ao Fim do Insumo
	If dDtDisp < dDtFim
		dDtDisp := dDtFim
		cHrDisp := cHrFim
	ElseIf dDtDisp == dDtFim .And. cHrDisp < cHrFim
		cHrDisp := cHrFim
	EndIf

	//Retorno da Funcao
	aRet := {}
	aAdd(aRet, dDtDisp)
	aAdd(aRet, cHrDisp)
	aAdd(aRet, cOrdemServ)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfGrdArvoreบAutor  ณWagner S. de Lacerdaบ Data ณ  05/05/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega a Arvore de Tarefas.                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fGrdArvore()

	Local nNivArv, cNivArv
	Local cNivSupTar, cNivSupTip, cNivSupIns
	Local nX, nY, nZ, nW, nPosTip, nPosIns, nPosSubIns

	Local cAberto := "", cFechado := ""

	oTree:BeginUpdate() //Inicia a atualizacao da Arvore

	oTree:Reset() //Limpa a Arvore

	//O.S.
	cAberto  := "OS"
	cFechado := "OS"
	oTree:AddTree(OemToAnsi(STR0023+": " + aTreeOS[1][1]) + Space(40), .F., cFechado, cAberto, , , "OS.001") //"O.S."
	//Adiciona na ultima posicao - Len(array[x]) - o seu ID na Arvore
	aTreeOS[1][6] := "001"

	nNivArv := 1
	For nX := 1 To Len(aTreeTar)
		If !oTree:IsEmpty()
			oTree:TreeSeek("OS.001")
		EndIf

		nNivArv++
		cNivArv := PADL(nNivArv, 3, "0")
		//Tarefa
		cAberto  := "note"
		cFechado := "note"
		oTree:AddItem(aTreeTar[nX][3], "TA."+cNivArv, cFechado, cAberto, , , 2)
		//Adiciona o seu ID na Arvore
		aTreeTar[nX][8] := cNivArv

		cNivSupTar := "TA."+cNivArv

		nPosTip := aScan(aTreeTip, {|x| x[1]+x[2] == aTreeTar[nX][1]+aTreeTar[nX][2] })
		If nPosTip > 0
			For nY := nPosTip To Len(aTreeTip)
				If aTreeTip[nY][1]+aTreeTip[nY][2] == aTreeTar[nX][1]+aTreeTar[nX][2]
					oTree:TreeSeek(cNivSupTar)

					nNivArv++
					cNivArv := PADL(nNivArv, 3, "0")
					//Tipo de Registro
					If aTreeTip[nY][4] == "E" //Especialidade
						cAberto  := "ng_tree_especialidade02"
						cFechado := "ng_tree_especialidade01"
					ElseIf aTreeTip[nY][4] == "F" //Ferramenta
						cAberto  := "ng_tree_ferramenta02"
						cFechado := "ng_tree_ferramenta01"
					ElseIf aTreeTip[nY][4] == "M" //Mao de Obra (Funcionario)
						cAberto  := "ng_tree_funcionario02"
						cFechado := "ng_tree_funcionario01"
					ElseIf aTreeTip[nY][4] == "P" //Produto
						cAberto  := "ng_tree_produto02"
						cFechado := "ng_tree_produto01"
					ElseIf aTreeTip[nY][4] == "T" //Terceiro
						cAberto  := "ng_tree_terceiros02"
						cFechado := "ng_tree_terceiros01"
					EndIf
					oTree:AddItem(aTreeTip[nY][5], "TI."+cNivArv, cFechado, cAberto, , , 2)
					//Adiciona o seu ID na Arvore
					aTreeTip[nY][10] := cNivArv

					cNivSupTip := "TI."+cNivArv

					nPosIns := aScan(aTreeIns, {|x| x[1]+x[2]+x[4] == aTreeTip[nY][1]+aTreeTip[nY][2]+aTreeTip[nY][4] })
					If nPosIns > 0
						For nZ := nPosIns To Len(aTreeIns)
							If aTreeIns[nZ][1]+aTreeIns[nZ][2]+aTreeIns[nZ][4] == aTreeTip[nY][1]+aTreeTip[nY][2]+aTreeTip[nY][4]
								oTree:TreeSeek(cNivSupTip)

								nNivArv++
								cNivArv := PADL(nNivArv, 3, "0")
								//Insumo
								If aTreeIns[nZ][4] == "E" //Especialidade
									cAberto  := "ng_especialidade"
									cFechado := "ng_especialidade"
								ElseIf aTreeIns[nZ][4] == "F" //Ferramenta
									cAberto  := "ng_ferramenta"
									cFechado := "ng_ferramenta"
								ElseIf aTreeIns[nZ][4] == "M" //Mao de Obra (Funcionario)
									cAberto  := "ng_funcionario"
									cFechado := "ng_funcionario"
								ElseIf aTreeIns[nZ][4] == "P" //Produto
									cAberto  := "ng_produto"
									cFechado := "ng_produto"
								ElseIf aTreeIns[nZ][4] == "T" //Terceiro
									cAberto  := "ng_terceiros"
									cFechado := "ng_terceiros"
								EndIf
								oTree:AddItem(aTreeIns[nZ][7], "IN."+cNivArv, cFechado, cAberto, , , 2)
								//Adiciona o seu ID na Arvore
								aTreeIns[nZ][12] := cNivArv

								cNivSupIns := "IN."+cNivArv

								//ESPECIALIDADE -> MAO DE OBRA
								nPosSubIns := aScan(aTreeSubIns, {|x| x[1]+x[2]+"E"+AllTrim(x[17]) == aTreeIns[nZ][1]+aTreeIns[nZ][2]+aTreeIns[nZ][4]+AllTrim(aTreeIns[nZ][6]) })
								If nPosSubIns > 0
									For nW := nPosSubIns To Len(aTreeSubIns)
										If aTreeSubIns[nW][1]+aTreeSubIns[nW][2]+"E"+AllTrim(aTreeSubIns[nW][17]) == aTreeIns[nZ][1]+aTreeIns[nZ][2]+aTreeIns[nZ][4]+AllTrim(aTreeIns[nZ][6])
											oTree:TreeSeek(cNivSupIns)

											nNivArv++
											cNivArv := PADL(nNivArv, 3, "0")
											//Sub Insumo
											cAberto  := "ng_funcionario"
											cFechado := "ng_funcionario"
											oTree:AddItem(aTreeSubIns[nW][7], "SI."+cNivArv, cFechado, cAberto, , , 2)
											//Adiciona o seu ID na Arvore
											aTreeSubIns[nW][12] := cNivArv
										EndIf
									Next nW
								EndIf
								oTree:TreeSeek(cNivSupIns)
								oTree:PTCollapse()
							EndIf
						Next nZ
					EndIf
					oTree:TreeSeek(cNivSupTip)
					oTree:PTCollapse()
				EndIf
			Next nY
		EndIf
		oTree:TreeSeek(cNivSupTar)
		oTree:PTCollapse()
	Next nX

	//Retorna o Foco para a O.S. na Arvore
	If !oTree:IsEmpty()
		oTree:TreeSeek("OS.001")
		oTree:PTCollapse()
	EndIf

	oTree:EndUpdate() //Finaliza a atualizacao da Arvore

	oTree:PTRefresh() //Atualiza os Niveis

	oTree:EndTree() //Encerra a Arvore (e' diferente de destruir)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfGrdDefMnuบAutor  ณWagner S. de Lacerdaบ Data ณ  11/05/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Define o Menu do Clique da Direta da Arvore de Tarefas.    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cDef -----> Opcional;                                      บฑฑ
ฑฑบ          ณ             Indica qual a funcionalidade a carregar.       บฑฑ
ฑฑบ          ณ             Default: "O" -> Define o objeto POPUP.         บฑฑ
ฑฑบ          ณ nPosicao -> Opcional;                                      บฑฑ
ฑฑบ          ณ             Indica a posicao do clique.                    บฑฑ
ฑฑบ          ณ             (E' obrigatorio quando se calcua a posicao).   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fGrdDefMnu(cDef, nPosicao)

	Local oItem
	Local nDiff
	Local uRet

	Local cMenuTitle, cMenuFunc, cMenuImg
	Local nMenu

	Default cDef := "O"

	cDef  := Upper(cDef)
	nDiff := 0
	uRet  := .T.

	If cDef  == "O"
		If Type("oMnuTree") == "O"
			MsFreeObj(oMnuTree)
		EndIf

		//Menu POPUP da Arvore de Tarefas
		oMnuTree := TMenu():New(, , , , .T., , , , )

		//Visualizar Item
		oItem := TMenuItem():New(oMnuTree:Owner(), STR0288, , , .T., {|| fGrdClick(.T.)}, , "bmpvisual", , , , , , , .T.) //"Visualizar Item"
		oMnuTree:Add(oItem)

		//Clique da Direita da Consulta de O.S.
		If Len(aSMenu) > 0
			//Cria um separador para identificar:
			//Acima do separador -> Menu da Arvore; Abaixo do separador -> Menu da Consulta de O.S.
			oItem := TMenuItem():New(oMnuTree:Owner(), Replicate("_",25), , , .F., {|| }, , Nil, , , , , , , .T.)
			oMnuTree:Add(oItem)

			//Adiciona as opcoes do menu
			For nMenu := 1 To Len(aSMenu)
				cMenuTitle := If(ValType(aSMenu[nMenu][1]) == "U", "", "aSMenu["+cValToChar(nMenu)+"][1]")
				cMenuFunc  := If(ValType(aSMenu[nMenu][2]) == "U", "", "{|| "+aSMenu[nMenu][2]+" }")
				cMenuImg   := If(ValType(aSMenu[nMenu][3]) == "U", "", "aSMenu["+cValToChar(nMenu)+"][3]")

				If !Empty(cMenuTitle) .And. !Empty(cMenuFunc) //Parametros obrigatorios
					oItem := TMenuItem():New(oMnuTree:Owner(), &(cMenuTitle), , , .T., &(cMenuFunc), , &(cMenuImg), , , , , , , .T.)
					oMnuTree:Add(oItem)
				EndIf
			Next nMenu
		EndIf
	ElseIf cDef == "X"
		If PtGetTheme() == "MDI"
			nDiff := 50

			uRet := nPosicao - nDiff
		Else
			nDiff := 20

			uRet := nPosicao - nDiff
		EndIf
	ElseIf cDef == "Y"
		If PtGetTheme() == "MDI"
			nDiff := oDlgGrdTar:nTop + oTree:nTop + 225

			uRet := nPosicao - nDiff
		Else
			nDiff := oDlgGrdTar:nTop + oTree:nTop + 190

			uRet := nPosicao - nDiff
		EndIf

		//Se for a 11.5, a enchoicebar esta' em baixo, entao devemos alterar novamente a posicao do clique da direita
		//MV_ECMFTPP -> Parametro presente somente a partir da 11.5
		If SuperGetMV("MV_ECMFTPP",.F.,-1) <> -1
			uRet := uRet + 25
		EndIf
	EndIf

Return uRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfGrdClick บAutor  ณWagner S. de Lacerdaบ Data ณ  19/04/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega o clicque no Grid de Tarefas. Monta a tela de      บฑฑ
ฑฑบ          ณ 'Detalhes' do insumo atual do Grid.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ lArvore-> Opcional;                                        บฑฑ
ฑฑบ          ณ           Indica se o clique foi chamado atraves da Arvore บฑฑ
ฑฑบ          ณ           de Tarefas.                                      บฑฑ
ฑฑบ          ณ           Default: .F. -> Nao foi chamado pela Arvore.     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fGrdClick(lArvore)

	Local oDlgGrdClk
	Local oLeft, oBtnSituac, oBtnSair
	Local oAll
	Local oMid, oMidCabec, oMidAll
	Local cSitItem, nSitItem
	Local oBot
	Local oProjDt, dProjDt
	Local oProjHr, cProjHr
	Local oPerExec, nPerExec, nPosExec
	Local lTemProjec := .F., lTemDest := .F.

	Local cCodItem, oCodItem
	Local cNomItem, oNomItem
	Local cTare, cTipoReg
	Local cDestino, cNomDest, oNomDest
	Local dPreDtIni , oPreGet61 , dReaDtIni , oReaGet61
	Local cPreHrIni , oPreGet62 , cReaHrIni , oReaGet62
	Local dPreDtFim , oPreGet63 , dReaDtFim , oReaGet63
	Local cPreHrFim , oPreGet64 , cReaHrFim , oReaGet64

	Local aRetDtHr := {}
	Local lPrev := lGrafic := .F.
	Local nPos := 0, nPos2 := 0, nPos3 := 0, nLinha := 0
	Local nX := 0

	Local cNivArv := cArrayArv := ""
	Local nAT := 0

	Default lArvore := .F.

	cCodItem := ""
	cNomItem := ""
	cTare    := ""
	cTipoReg := ""
	cDestino := ""
	cNomDest := ""

	dPreDtIni := CTOD("  /  /    ")
	dPreDtFim := CTOD("  /  /    ")
	cPreHrIni := "  :  "
	cPreHrFim := "  :  "
	dReaDtIni := CTOD("  /  /    ")
	dReaDtFim := CTOD("  /  /    ")
	cReaHrIni := "  :  "
	cReaHrFim := "  :  "

	dProjDt := CTOD("  /  /    ")
	cProjHr := "  :  "

	cSitItem := STR0279 + " " + "OK" //"Item"

	//Recebe o Nivel Atual na Arvore
	cNivArv   := oTree:GetCargo()
	nAT       := AT(".", cNivArv)
	cArrayArv := SubStr(cNivArv, 1, (nAT-1))
	cNivArv   := SubStr(cNivArv, (nAT+1))

	nPosExec := 0
	nPerExec := 0

	If lArvore
		nPos := 0
		If cArrayArv == "OS"
			nPos := aScan(aTreeOS, {|x| x[6] == cNivArv })
		ElseIf cArrayArv == "TA"
			nPos := aScan(aTreeTar, {|x| x[8] == cNivArv })
		ElseIf cArrayArv == "TI"
			nPos := aScan(aTreeTip, {|x| x[10] == cNivArv })
		ElseIf cArrayArv == "IN"
			nPos := aScan(aTreeIns, {|x| x[12] == cNivArv })
		ElseIf cArrayArv == "SI"
			nPos := aScan(aTreeSubIns, {|x| x[12] == cNivArv })
		EndIf

		If nPos == 0
			Return .F.
		EndIf

		If cArrayArv == "OS" //ORDEM DE SERVICO
			cCodItem := aTreeOS[nPos][1]
			cNomItem := OemToAnsi(Upper(STR0006)) //"Consulta de O.S."
			cTare    := ""
			cTipoReg := ""

			//Previsto
			dPreDtIni := aTreeOS[nPos][2]
			cPreHrIni := aTreeOS[nPos][3]
			dPreDtFim := aTreeOS[nPos][4]
			cPreHrFim := aTreeOS[nPos][5]

			//Realizado
			dReaDtIni := aTreeOS[nPos][7]
			cReaHrIni := aTreeOS[nPos][8]
			dReaDtFim := aTreeOS[nPos][9]
			cReaHrFim := aTreeOS[nPos][10]

			//Projecao
			For nX := 1 To Len(aGrdIns)
				If AllTrim(aGrdIns[nX][3]) == _PROJEC
					If Empty(dProjDt)
						dProjDt := aGrdIns[nX][10]
						cProjHr := aGrdIns[nX][11]
					Else
						If aGrdIns[nX][10] > dProjDt
							dProjDt := aGrdIns[nX][10]
							cProjHr := aGrdIns[nX][11]
						ElseIf aGrdIns[nX][10] == dProjDt .And. aGrdIns[nX][11] > cProjHr
							cProjHr := aGrdIns[nX][11]
						EndIf
					EndIf
				EndIf
			Next nX

			//Percentual Executado
			nPosExec := aScan(aPercOS, {|x| AllTrim(x[1]) == AllTrim(cOS)})
			If nPosExec > 0
				nPerExec := aPercOS[nPosExec][3]
			EndIf
		ElseIf cArrayArv == "TA" //TAREFA
			cCodItem := aTreeTar[nPos][2]
			cNomItem := aTreeTar[nPos][3]
			cTare    := aTreeTar[nPos][2]
			cTipoReg := aTreeTar[nPos][2]

			//Previsto
			dPreDtIni := aTreeTar[nPos][4]
			cPreHrIni := aTreeTar[nPos][5]
			dPreDtFim := aTreeTar[nPos][6]
			cPreHrFim := aTreeTar[nPos][7]

			//Realizado
			dReaDtIni := aTreeTar[nPos][9]
			cReaHrIni := aTreeTar[nPos][10]
			dReaDtFim := aTreeTar[nPos][11]
			cReaHrFim := aTreeTar[nPos][12]

			//Projecao
			For nX := 1 To Len(aGrdIns)
				If aGrdIns[nX][1] == cTare
					If AllTrim(aGrdIns[nX][3]) == _PROJEC
						If Empty(dProjDt)
							dProjDt := aGrdIns[nX][10]
							cProjHr := aGrdIns[nX][11]
						Else
							If aGrdIns[nX][10] > dProjDt
								dProjDt := aGrdIns[nX][10]
								cProjHr := aGrdIns[nX][11]
							ElseIf aGrdIns[nX][10] == dProjDt .And. aGrdIns[nX][11] > cProjHr
								cProjHr := aGrdIns[nX][11]
							EndIf
						EndIf
					EndIf
				EndIf
			Next nX

			//Percentual Executado
			nPosExec := aScan(aPercTars, {|x| AllTrim(x[1])+AllTrim(x[2]) == AllTrim(cOS)+AllTrim(cTare)})
			If nPosExec > 0
				nPerExec := aPercTars[nPosExec][4]
			EndIf
		ElseIf cArrayArv == "TI" //TIPO DE INSUMO
			cCodItem := aTreeTip[nPos][4]
			cNomItem := aTreeTip[nPos][5]
			cTare    := aTreeTip[nPos][2]
			cTipoReg := aTreeTip[nPos][4]

			//Previsto
			dPreDtIni := aTreeTip[nPos][6]
			cPreHrIni := aTreeTip[nPos][7]
			dPreDtFim := aTreeTip[nPos][8]
			cPreHrFim := aTreeTip[nPos][9]

			//Realizado
			dReaDtIni := aTreeTip[nPos][11]
			cReaHrIni := aTreeTip[nPos][12]
			dReaDtFim := aTreeTip[nPos][13]
			cReaHrFim := aTreeTip[nPos][14]

			//Projecao
			For nX := 1 To Len(aGrdIns)
				If aGrdIns[nX][1] == cTare .And. aGrdIns[nX][6] == cTipoReg
					If AllTrim(aGrdIns[nX][3]) == _PROJEC
						If Empty(dProjDt)
							dProjDt := aGrdIns[nX][10]
							cProjHr := aGrdIns[nX][11]
						Else
							If aGrdIns[nX][10] > dProjDt
								dProjDt := aGrdIns[nX][10]
								cProjHr := aGrdIns[nX][11]
							ElseIf aGrdIns[nX][10] == dProjDt .And. aGrdIns[nX][11] > cProjHr
								cProjHr := aGrdIns[nX][11]
							EndIf
						EndIf
					EndIf
				EndIf
			Next nX

			//Percentual Executado
			nPosExec := aScan(aPercTips, {|x| AllTrim(x[1])+AllTrim(x[2])+AllTrim(x[3]) == AllTrim(cOS)+AllTrim(cTare)+AllTrim(cTipoReg)})
			If nPosExec > 0
				nPerExec := aPercTips[nPosExec][5]
			EndIf
		ElseIf cArrayArv == "IN" //INSUMO
			cCodItem := aTreeIns[nPos][6]
			cNomItem := aTreeIns[nPos][7]
			cTare    := aTreeIns[nPos][2]
			cTipoReg := aTreeIns[nPos][4]
			cDestino := aTreeIns[nPos][17]

			//Previsto
			dPreDtIni := aTreeIns[nPos][8]
			cPreHrIni := aTreeIns[nPos][9]
			dPreDtFim := aTreeIns[nPos][10]
			cPreHrFim := aTreeIns[nPos][11]

			//Realizado
			dReaDtIni := aTreeIns[nPos][13]
			cReaHrIni := aTreeIns[nPos][14]
			dReaDtFim := aTreeIns[nPos][15]
			cReaHrFim := aTreeIns[nPos][16]

			//Projecao
			For nX := 1 To Len(aGrdIns)
				If aGrdIns[nX][1] == cTare .And. aGrdIns[nX][6] == cTipoReg .And. aGrdIns[nX][4] == cCodItem
					If AllTrim(aGrdIns[nX][3]) == _PROJEC
						If Empty(dProjDt)
							dProjDt := aGrdIns[nX][10]
							cProjHr := aGrdIns[nX][11]
						Else
							If aGrdIns[nX][10] > dProjDt
								dProjDt := aGrdIns[nX][10]
								cProjHr := aGrdIns[nX][11]
							ElseIf aGrdIns[nX][10] == dProjDt .And. aGrdIns[nX][11] > cProjHr
								cProjHr := aGrdIns[nX][11]
							EndIf
						EndIf
					EndIf
				EndIf
			Next nX

			//Percentual Executado
			nPosExec := aScan(aPercIns, {|x| AllTrim(x[1])+AllTrim(x[2])+AllTrim(x[3])+AllTrim(x[4])+x[5] == AllTrim(cOS)+AllTrim(cTare)+AllTrim(cTipoReg)+AllTrim(cCodItem)+cDestino})
			If nPosExec > 0
				nPerExec := aPercIns[nPosExec][7]
			EndIf
		ElseIf cArrayArv == "SI" //SUB INSUMO
			cCodItem := aTreeSubIns[nPos][6]
			cNomItem := aTreeSubIns[nPos][7]
			cTare    := aTreeSubIns[nPos][2]
			cTipoReg := aTreeSubIns[nPos][4]

			//Previsto
			dPreDtIni := aTreeSubIns[nPos][8]
			cPreHrIni := aTreeSubIns[nPos][9]
			dPreDtFim := aTreeSubIns[nPos][10]
			cPreHrFim := aTreeSubIns[nPos][11]

			//Realizado
			dReaDtIni := aTreeSubIns[nPos][13]
			cReaHrIni := aTreeSubIns[nPos][14]
			dReaDtFim := aTreeSubIns[nPos][15]
			cReaHrFim := aTreeSubIns[nPos][16]

			//Sub Insumo e' sempre Realizado
			For nX := 1 To Len(aGrdIns)
				If ( aGrdIns[nX][1] == cTare .And. aGrdIns[nX][6] == cTipoReg .And. aGrdIns[nX][4] == cCodItem ) ;
				.Or. ( aGrdIns[nX][1] == cTare .And. aGrdIns[nX][6] == "E" .And. AllTrim(aGrdIns[nX][4]) == AllTrim(aTreeSubIns[nPos][17]) )

					If AllTrim(aGrdIns[nX][3]) == _PROJEC
						//Projecao
						If Empty(dProjDt)
							dProjDt := aGrdIns[nX][10]
							cProjHr := aGrdIns[nX][11]
						Else
							If aGrdIns[nX][10] > dProjDt
								dProjDt := aGrdIns[nX][10]
								cProjHr := aGrdIns[nX][11]
							ElseIf aGrdIns[nX][10] == dProjDt .And. aGrdIns[nX][11] > cProjHr
								cProjHr := aGrdIns[nX][11]
							EndIf
						EndIf
					EndIf
				EndIf
			Next nX

			//Percentual Executado
			nPosExec := aScan(aPercSubIns, {|x| AllTrim(x[1])+AllTrim(x[2])+AllTrim(x[3])+AllTrim(x[4]) == AllTrim(cOS)+AllTrim(cTare)+AllTrim(cTipoReg)+AllTrim(cCodItem)})
			If nPosExec > 0
				nPerExec := aPercSubIns[nPosExec][6]
			EndIf
		EndIf
	Else
		nPos := aScan(aGrdLinClk, {|x| x[1] == oGrdGrafic:nLineAtu } )
		If nPos > 0
			nLinha := aGrdLinClk[nPos][2]
		EndIf

		If nLinha == 0 .Or. Len(aGrdGrafic) < nLinha
			Return .F.
		EndIf

		lPrev := ( AllTrim(aGrdGrafic[nLinha][2]) == "0" )

		cCodItem := aGrdGrafic[nLinha][3]
		cNomItem := aGrdGrafic[nLinha][4]
		cTare    := aGrdGrafic[nLinha][1]
		cTipoReg := aGrdGrafic[nLinha][5]
		cDestino := ""
		If Len(aGrdGrafic[nLinha]) >= 9 //Destino para Produtos quando o nivel na Arvore for "TI" ou "IN" //Tipo de Insumo ou Insumo
			cDestino := aGrdGrafic[nLinha][9]
		EndIf

		If lPrev //Item visualizado e' Previsto
			dPreDtIni := aGrdGrafic[nLinha][6][1]
			cPreHrIni := aGrdGrafic[nLinha][6][2]
			dPreDtFim := aGrdGrafic[nLinha][6][3]
			cPreHrFim := aGrdGrafic[nLinha][6][4]

			For nX := 1 To Len(aGrdIns)

				If AllTrim(aGrdIns[nX][3]) == "0" .Or. AllTrim(aGrdIns[nX][3]) == _ATRASO .Or. AllTrim(aGrdIns[nX][3]) == _PROJEC
					Loop
				EndIf

				lGrafic := .F.
				If cArrayArv == "OS" //Visualizando a O.S. -> Carrega as Tarefas
					lGrafic := .T.
				ElseIf cArrayArv == "TA" //Visualizando a Tarefa -> Carrega os Tipos de Insumo
					lGrafic := ( AllTrim(aGrdIns[nX][1]) == AllTrim(cTare) ;
					.And. If(cTipoReg == "E", ;
					AllTrim(aGrdIns[nX][6]) == "E" .Or. (AllTrim(aGrdIns[nX][6]) == "M" .And. !Empty(aGrdIns[nX][12])), ;
					AllTrim(aGrdIns[nX][6]) == AllTrim(cTipoReg) .And. Empty(aGrdIns[nX][12])) ;
					)
				ElseIf cArrayArv == "TI" .Or. cArrayArv == "IN" .Or. cArrayArv == "SI" //Visualizando o Tipo de Insumo/Insumo/Sub Insumo -> Carrega o proprio Tipo de Insumo/Insumo/Sub Insumo
					lGrafic := ( AllTrim(aGrdIns[nX][1]) == AllTrim(cTare) ;
					.And. If(cTipoReg == "E", ;
					AllTrim(aGrdIns[nX][6]) == "E" .Or. (AllTrim(aGrdIns[nX][6]) == "M" .And. !Empty(aGrdIns[nX][12])), ;
					AllTrim(aGrdIns[nX][6]) == AllTrim(cTipoReg)) ;
					.And. If(cTipoReg == "E", ;
					AllTrim(aGrdIns[nX][12]) == AllTrim(cCodItem), ;
					AllTrim(aGrdIns[nX][4]) == AllTrim(cCodItem)) ;
					.And. aGrdIns[nX][17] == cDestino ;
					)
				EndIf

				If lGrafic
					If Empty(dReaDtIni)
						dReaDtIni := aGrdIns[nX][8]
						cReaHrIni := aGrdIns[nX][9]
						dReaDtFim := aGrdIns[nX][10]
						cReaHrFim := aGrdIns[nX][11]
					Else
						aRetDtHr := fCompDtHr( {dReaDtIni, cReaHrIni, dReaDtFim, cReaHrFim},;
						{aGrdIns[nX][8], aGrdIns[nX][9], aGrdIns[nX][10], aGrdIns[nX][11]} )
						dReaDtIni := aRetDtHr[1]
						cReaHrIni := aRetDtHr[2]
						dReaDtFim := aRetDtHr[3]
						cReaHrFim := aRetDtHr[4]
					EndIf
				EndIf
			Next nX
		Else //Item visualizado e' Realizado
			dReaDtIni := aGrdGrafic[nLinha][6][1]
			cReaHrIni := aGrdGrafic[nLinha][6][2]
			dReaDtFim := aGrdGrafic[nLinha][6][3]
			cReaHrFim := aGrdGrafic[nLinha][6][4]

			nPos2 := aScan(aGrdGrafic, {|x| AllTrim(x[1])+AllTrim(x[3])+AllTrim(x[5]) == AllTrim(cTare)+AllTrim(cCodItem)+AllTrim(cTipoReg) .And. AllTrim(x[2]) == "0" .And. If(Len(aGrdGrafic[nLinha]) >= 9, x[9] == cDestino, .T.) } )
			If nPos2 > 0
				dPreDtIni := aGrdGrafic[nPos2][6][1]
				cPreHrIni := aGrdGrafic[nPos2][6][2]
				dPreDtFim := aGrdGrafic[nPos2][6][3]
				cPreHrFim := aGrdGrafic[nPos2][6][4]
			ElseIf (cArrayArv == "IN" .Or. cArrayArv == "SI") .And. cTipoReg == "M" //Caso nao encontre um Previsto, verifica se e' um Sub Insumo de Mao de Obra
				//Se for, entao faz uma busca especifica pela Especialidade Relacionada
				nPos3 := aScan(aGrdIns, {|x| AllTrim(x[1])+AllTrim(x[6])+AllTrim(x[4]) == AllTrim(cTare)+AllTrim(cTipoReg)+AllTrim(cCodItem) .And. !Empty(x[12])})
				If nPos3 > 0
					//Agora busca no Grafico se possui um Previsto
					nPos2 := aScan(aGrdGrafic, {|x| AllTrim(x[1])+AllTrim(x[3])+AllTrim(x[5]) == AllTrim(aGrdIns[nPos3][1])+AllTrim(aGrdIns[nPos3][12])+"E" .And. AllTrim(x[2]) == "0"} )
					If nPos2 > 0
						dPreDtIni := aGrdGrafic[nPos2][6][1]
						cPreHrIni := aGrdGrafic[nPos2][6][2]
						dPreDtFim := aGrdGrafic[nPos2][6][3]
						cPreHrFim := aGrdGrafic[nPos2][6][4]
					EndIf
				EndIf
			EndIf
		EndIf

		//Projecao
		For nX := 1 To Len(aGrdGrafic)
			If AllTrim(aGrdGrafic[nX][2]) == _PROJEC

				lGrafic := .F.
				If cArrayArv == "OS" //Visualizando a O.S. -> Carrega as Tarefas
					lGrafic := ( AllTrim(aGrdGrafic[nX][1]) == AllTrim(cTare) )
				Else
					lGrafic := ( AllTrim(aGrdGrafic[nX][1]) == AllTrim(cTare) ;
					.And. AllTrim(aGrdGrafic[nX][5]) == AllTrim(cTipoReg) ;
					.And. If(Len(aGrdGrafic[nLinha]) >= 9, aGrdGrafic[nX][9] == cDestino, .T.) ;
					)
					//Se nao achou, verifica se estamos processando um insumo de Mao de Obra Realizado relacionado a uma Especialidade
					If !lGrafic .And. AllTrim(cTipoReg) == "M" .And. AllTrim(aGrdGrafic[nLinha][2]) <> "0" .And. AllTrim(aGrdGrafic[nLinha][2]) <> _ATRASO .Or. AllTrim(aGrdGrafic[nLinha][2]) <> _PROJEC
						//Se sim, verifica se o insumo tem Previsao
						If aScan(aGrdIns, {|x| AllTrim(x[1])+AllTrim(x[6])+AllTrim(x[4]) == AllTrim(cTare)+AllTrim(cTipoReg)+AllTrim(cCodItem) .And. AllTrim(x[3]) == "0" }) == 0
							//Caso nao tenha Previsto, entao tenta alocar na Especialidade Prevista
							lGrafic := ( AllTrim(aGrdGrafic[nX][1]) == AllTrim(cTare) .And. AllTrim(aGrdGrafic[nX][5]) == "E" )
						EndIf
					EndIf
				EndIf

				If lGrafic
					If Empty(dProjDt)
						dProjDt := aGrdGrafic[nX][6][3]
						cProjHr := aGrdGrafic[nX][6][4]
					Else
						If aGrdGrafic[nX][6][3] > dProjDt
							dProjDt := aGrdGrafic[nX][6][3]
							cProjHr := aGrdGrafic[nX][6][4]
						ElseIf aGrdGrafic[nX][6][3] == dProjDt .And. aGrdGrafic[nX][6][4] > cProjHr
							cProjHr := aGrdGrafic[nX][6][4]
						EndIf
					EndIf
				EndIf
			EndIf
		Next nX

		//Busca o Percentual Executado
		//E' diferente de quando se clica na arvore, pois nela os insumos iguais nao sao separados,
		//ja' no Gantt sao mostrados separadamente, exemplo:
		//Ha' dois Insumos de Mao de Obra reportados. Na Arvore, aparecera' um so', porem no Gantt, os dois sao mostrados
		nPerExec := aGrdGrafic[nLinha][7]
	EndIf

	lTemProjec := ( !Empty(dProjDt) .And. !lOSTermino ) //Mostra Projecao somente se Possuir E se a O.S. Nao estiver Terminada
	lTemDest   := !Empty(cDestino)

	//Situacao do Item
	If !Empty(dReaDtIni)
		cSitItem := STR0279 + " " + STR0078 //"Item"###"Realizado"
		nSitItem := 3

		If nPerExec < 100 //Se ainda nao estiver 100%, diz que o item esta' realizado 'parcialmente'
			cSitItem += Space(1)+"("+STR0311+")" //"parcialmente"
		EndIf
	ElseIf !Empty(dPreDtIni)
		If dCOSDtIni > dPreDtFim //Data Atual maior que o Fim Previsto
			cSitItem := STR0279 + " " + STR0077 + " " + STR0280 //"Item"###"Previsto"###"Atrasado"
			nSitItem := 2
		ElseIf dCOSDtIni == dPreDtFim .And. cCOSHrIni > cPreHrFim //Data Atual igual ao Fim Previsto, porem a Hora Atual e' maior que a do Fim Previsto
			cSitItem := STR0279 + " " + STR0077 + " " + STR0280 //"Item"###"Previsto"###"Atrasado"
			nSitItem := 2
		Else
			cSitItem := STR0279 + " " + STR0077 //"Item"###"Previsto"
			nSitItem := 1
		EndIf
	EndIf

	fBlackPnl() //Mostra o Painel de Transparencia
	//SETKEY(VK_F5, {|| }) //Desabilita F5

	DEFINE MSDIALOG oDlgGrdClk TITLE OemToAnsi(STR0216) COLOR CLR_BLACK, CLR_WHITE FROM 0,0 TO 230,700 OF oMainWnd PIXEL //"Informa็๕es do Item"

	oDlgGrdClk:lEscClose := .T.

	//--- Painel Left
	oLeft := TPanel():New(01, 01, , oDlgGrdClk, , , , CLR_WHITE, nCorBack, 12, 50)
	oLeft:Align := CONTROL_ALIGN_LEFT

	//Sair
	oBtnSair := TBtnBmp2():New(01, 01, 27, 30, "ng_ico_final", , , , {|| oDlgGrdClk:End()}, oLeft, OemToAnsi(STR0151)) //"Sair"
	oBtnSair:Align := CONTROL_ALIGN_TOP

	//--- Painel ALL
	oAll := TPanel():New(01, 01, , oDlgGrdClk, , , , CLR_BLACK, CLR_WHITE, 12, 50)
	oAll:Align := CONTROL_ALIGN_ALLCLIENT

	//--- Painel Mid
	oMid := TPanel():New(01, 01, , oAll, , , , CLR_BLACK, CLR_WHITE, 12, 50)
	oMid:Align := CONTROL_ALIGN_ALLCLIENT

	//--- Painel Mid Cabecalho
	oMidCabec := TPanel():New(01, 01, , oMid, , , , CLR_BLACK, CLR_WHITE, 12, 40)
	oMidCabec:Align := CONTROL_ALIGN_TOP

	//Codigo
	@ 010,010 SAY OemToAnsi(STR0061) FONT oFontBold COLOR CLR_BLACK OF oMidCabec PIXEL //"C๓digo:"
	@ 009,040 MSGET oCodItem VAR cCodItem SIZE 131,08 READONLY OF oMidCabec PIXEL
	oCodItem:bHelp := {|| ShowHelpCpo(STR0219,; //"Codigo"
	{STR0220},2,; //"C๓digo do Item Selecionado."
	{},2)}
	//Nome
	@ 025,010 SAY OemToAnsi(STR0064) FONT oFontBold COLOR CLR_BLACK OF oMidCabec PIXEL //"Nome:"
	@ 024,040 MSGET oNomItem VAR cNomItem SIZE 131,08 READONLY OF oMidCabec PIXEL
	oNomItem:bHelp := {|| ShowHelpCpo(STR0094,; //"Nome"
	{STR0221},2,; //"Nome do C๓digo do Item Selecionado."
	{},2)}

	//Situacao
	@ 010,180 SAY OemToAnsi(STR0281) FONT oFontBold COLOR CLR_BLACK OF oMidCabec PIXEL //"Situa็ใo:"
	@ 010,220 SAY OemToAnsi(cSitItem) FONT oFontNorm COLOR If(nSitItem == 1, CLR_GREEN, If(nSitItem == 2, CLR_RED,CLR_BLUE)) OF oMidCabec PIXEL

	//Destino
	cNomDest := If(!Empty(cDestino), NGRETSX3BOX("TL_DESTINO", cDestino), Space(1))
	@ 025,180 SAY OemToAnsi(STR0308+":") FONT oFontBold COLOR CLR_BLACK OF oMidCabec PIXEL //"Destino"
	@ 024,220 MSGET oNomDest VAR cNomDest SIZE 080,08 PICTURE "@!" READONLY OF oMidCabec PIXEL
	oNomDest:bHelp := {|| ShowHelpCpo(STR0308,;
	{STR0310},2,; //"Destino do Item selecionado no Gantt. (Destino do Produto)"
	{},2)}
	If !lTemDest
		oNomDest:Disable()
	EndIf

	//--- Painel Mid ALL
	oMidAll := TPanel():New(01, 01, , oMid, , , , CLR_BLACK, CLR_WHITE, 12, 100)
	oMidAll:Align := CONTROL_ALIGN_ALLCLIENT

	//--- Grupo do Previsto
	oGrpPrev := TGroup():New(001, 000, 100, 170, STR0077, oMidAll, CLR_GREEN, , .T.) //"Previsto"
	oGrpPrev:Align := CONTROL_ALIGN_LEFT

	//Data Inicial
	@ 015,005 SAY OemToAnsi(STR0222) FONT oFontNorm COLOR CLR_BLACK OF oMidAll PIXEL //"Data Inicial:"
	@ 014,045 MSGET oPreGet61 VAR dPreDtIni PICTURE "99/99/9999" SIZE 040,08 READONLY OF oMidAll PIXEL
	oPreGet61:bHelp := {|| ShowHelpCpo(STR0223,; //"Data Inicial Prev."
	{STR0224},2,; //"Data Inicial Previsto."
	{},2)}
	//Hora Inicial
	@ 015,090 SAY OemToAnsi(STR0225) FONT oFontNorm COLOR CLR_BLACK OF oMidAll PIXEL //"Hora Inicial:"
	@ 014,130 MSGET oPreGet62 VAR cPreHrIni PICTURE "99:99" SIZE 020,08 READONLY OF oMidAll PIXEL
	oPreGet62:bHelp := {|| ShowHelpCpo(STR0226,; //"Hora Inicial Prev."
	{STR0227},2,; //"Hora Inicial Previsto."
	{},2)}

	//Data Fim
	@ 035,005 SAY OemToAnsi(STR0228) FONT oFontNorm COLOR CLR_BLACK OF oMidAll PIXEL //"Data Fim:"
	@ 034,045 MSGET oPreGet63 VAR dPreDtFim PICTURE "99/99/9999" SIZE 040,08 READONLY OF oMidAll PIXEL
	oPreGet63:bHelp := {|| ShowHelpCpo(STR0229,; //"Data Fim Prev."
	{STR0230},2,; //"Data Fim Previsto."
	{},2)}
	//Hora Fim
	@ 035,090 SAY OemToAnsi(STR0231) FONT oFontNorm COLOR CLR_BLACK OF oMidAll PIXEL //"Hora Fim:"
	@ 034,130 MSGET oPreGet64 VAR cPreHrFim PICTURE "99:99" SIZE 020,08 READONLY OF oMidAll PIXEL
	oPreGet64:bHelp := {|| ShowHelpCpo(STR0232,; //"Hora Fim Prev."
	{STR0233},2,; //"Hora Fim Previsto."
	{},2)}

	//--- Grupo do Realizado
	oGrpReal := TGroup():New(001, 000, 100, 170, STR0078, oMidAll, CLR_BLUE, , .T.) //"Realizado"
	oGrpReal:Align := CONTROL_ALIGN_RIGHT

	//Data Inicial
	@ 015,180 SAY OemToAnsi(STR0222) FONT oFontNorm COLOR CLR_BLACK OF oMidAll PIXEL //"Data Inicial:"
	@ 014,220 MSGET oReaGet61 VAR dReaDtIni PICTURE "99/99/9999" SIZE 040,08 READONLY OF oMidAll PIXEL
	oReaGet61:bHelp := {|| ShowHelpCpo(STR0234,; //"Data Inicial Real."
	{STR0235},2,; //"Data Inicial Realizado."
	{},2)}
	//Hora Inicial
	@ 015,265 SAY OemToAnsi(STR0225) FONT oFontNorm COLOR CLR_BLACK OF oMidAll PIXEL //"Hora Inicial:"
	@ 014,305 MSGET oReaGet62 VAR cReaHrIni PICTURE "99:99" SIZE 020,08 READONLY OF oMidAll PIXEL
	oReaGet62:bHelp := {|| ShowHelpCpo(STR0236,; //"Hora Inicial Real."
	{STR0237},2,; //"Hora Inicial Realizado."
	{},2)}

	//Data Fim
	@ 035,180 SAY OemToAnsi(STR0228) FONT oFontNorm COLOR CLR_BLACK OF oMidAll PIXEL //"Data Fim:"
	@ 034,220 MSGET oReaGet63 VAR dReaDtFim PICTURE "99/99/9999" SIZE 040,08 READONLY OF oMidAll PIXEL
	oReaGet63:bHelp := {|| ShowHelpCpo(STR0238,; //"Data Fim Real."
	{STR0239},2,; //"Data Fim Realizado."
	{},2)}
	//Hora Fim
	@ 035,265 SAY OemToAnsi(STR0231) FONT oFontNorm COLOR CLR_BLACK OF oMidAll PIXEL //"Hora Fim:"
	@ 034,305 MSGET oReaGet64 VAR cReaHrFim PICTURE "99:99" SIZE 020,08 READONLY OF oMidAll PIXEL
	oReaGet64:bHelp := {|| ShowHelpCpo(STR0240,; //"Hora Fim Real."
	{STR0241},2,; //"Hora Fim Realizado."
	{},2)}

	//--- Painel Bot
	oBot := TPanel():New(01, 01, , oAll, , , , CLR_BLACK, CLR_WHITE, 12, 20)
	oBot:Align := CONTROL_ALIGN_BOTTOM

	If lTemProjec
		@ 005,010 SAY OemToAnsi(STR0079+":") FONT oFontBold COLOR CLR_BLACK OF oBot PIXEL //"Proje็ใo de Conclusใo"
		@ 004,090 MSGET oProjDt VAR dProjDt PICTURE "99/99/9999" SIZE 040,08 READONLY OF oBot PIXEL
		oProjDt:bHelp := {|| ShowHelpCpo(STR0079,; //"Proje็ใo"
		{STR0079},2,; //"Proje็ใo de Conclusใo"
		{},2)}
		@ 004,140 MSGET oProjHr VAR cProjHr PICTURE "99:99" SIZE 020,08 READONLY OF oBot PIXEL
		oProjHr:bHelp := {|| ShowHelpCpo(STR0079,; //"Proje็ใo"
		{STR0079},2,; //"Proje็ใo de Conclusใo"
		{},2)}
	EndIf

	@ 005,180 SAY OemToAnsi("Percentual Concluํdo"+":") FONT oFontBold COLOR CLR_BLACK OF oBot PIXEL
	@ 004,260 MSGET oPerExec VAR nPerExec PICTURE "@E 999.99" SIZE 020,08 READONLY OF oBot PIXEL
	oPerExec:bHelp := {|| ShowHelpCpo("Percentual",; //"Percentual"
	{"Pencentual Concluํdo do Item."},2,; //"Proje็ใo de Conclusใo"
	{},2)}
	@ 005,286 SAY OemToAnsi("%") FONT oFontBold COLOR CLR_BLACK OF oBot PIXEL

	ACTIVATE MSDIALOG oDlgGrdClk CENTERED

	fBlackPnl(.F.) //Esconde o Painel de Transparencia
	//SETKEY(VK_F5, {|| MNTC755BTN(1) }) //F5: Atualiza a Tela - funcao MNTC755ATU()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMNTC755EXPบAutor  ณWagner S. de Lacerdaบ Data ณ  26/04/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Prepara a Exportacao para o MsProject.                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC755EXP()

	Local lMsP := .T.
	Local nBtnSel := 0

	fBlackPnl() //Mostra o Painel de Transparencia

	Processa({|| lMsp :=  fGrdChkMsP()}, "MsProject")

	If !lMsp
		fBlackPnl(.F.) //Esconde o Painel de Transparencia
		Return .F.
	EndIf

	nBtnSel := Aviso(STR0116,; //"Assistente de Integra็ใo"
	STR0117+_ENTER+; //"Certifique-se de que o MsProject esteja configuradao corretamente:"
	"- "+STR0277+_ENTER+; //"A data no formato 28/01/02 12:33 (Ferramentas - Op็๕es)"
	"- "+STR0278+_ENTER+; //"A dura็ใo definida para Horas (Ferramentas - Op็๕es)"
	"- "+STR0100+_ENTER+; //"O Calendแrio do Projeto definido para 24h (Projeto - Informa็๕es sobre o Projeto)"
	STR0118+_ENTER+; //"ษ possํvel que este processo de exporta็ใo demore alguns minutos."
	STR0119,; //"Confirmar?"
	{STR0120, STR0121},3) //"OK"###"Cancelar"

	If nBtnSel == 1 //OK
		MsgRun(STR0122, STR0123, {|| fGrdExport() } ) //"Exportando o Gantt de Tarefas para o MsProject..."###"Por favor aguarde..."
	EndIf

	fBlackPnl(.F.) //Esconde o Painel de Transparencia

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfGrdChkMsPบAutor  ณWagner S. de Lacerdaบ Data ณ  26/04/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se o MsProject esta' instalado no cliente.        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fGrdChkMsP()

	Local nFindPrj   := 1
	Local nTentativs := 10

	ProcRegua(nTentativs)
	While nFindPrj <= nTentativs .And. !ApOleClient("MsProject")
		IncProc(STR0244+PADL(nFindPrj,2,"0")+"/"+PADL(nTentativs,2,"0")) //"Verificando instala็ใo do MsProject... "
		nFindPrj++
	End

	If nFindPrj > nTentativs
		MsgInfo(STR0245,STR0089) //"MsProject nใo estแ instalado."###"Aten็ใo"
		Return .F.
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfGrdExportบAutor  ณWagner S. de Lacerdaบ Data ณ  26/04/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exporta o Grid de Tarefas para o MsProject.                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fGrdExport()

	Local aTarefas, aDuracao
	Local cDuracao
	Local oAppMsP
	Local lIndent
	Local nX, nY, nTar, nIndent, nDuracao
	Local nPosTar, nPosIns

	//--- Inicializa o MsProject novamente
	oAppMsP := MsProject():New()
	oAppMsP:Visible := .F.
	oAppMsP:Projects:Add()

	//--- Cria a Tabela
	oAppMsP:TableEdit("MNTC755", .T., .T., .T., , "ID", , , 06, PJCENTER, .T., .T., PJDATEDEFAULT, 1, , PJCENTER)
	oAppMsP:TableEdit("MNTC755", .T., , .T., , ,"Text1"   , STR0026, 06, PJLEFT , .T., .T., PJDATEDEFAULT, 1, , PJCENTER) //"Plano"
	oAppMsP:TableEdit("MNTC755", .T., , .T., , ,"Text2"   , STR0246, 06, PJLEFT , .T., .T., PJDATEDEFAULT, 1, , PJCENTER) //"Ordem"
	oAppMsP:TableEdit("MNTC755", .T., , .T., , ,"Name"    , STR0065, 20, PJLEFT , .T., .T., PJDATEDEFAULT, 1, , PJCENTER) //"Nome da Tarefa"
	oAppMsP:TableEdit("MNTC755", .T., , .T., , ,"Duration", STR0247, 12, PJRIGHT	, .T., .T., PJDATEDEFAULT, 1, , PJCENTER) //"Dura็ใo"
	oAppMsP:TableEdit("MNTC755", .T., , .T., , ,"Start"   , STR0248, 20, PJRIGHT, .T., .T., PJDATEDEFAULT, 1, , PJCENTER) //"Inํcio"
	oAppMsP:TableEdit("MNTC755", .T., , .T., , ,"Finish"  , STR0249, 20, PJRIGHT, .T., .T., PJDATEDEFAULT, 1, , PJCENTER) //"Fim"
	oAppMsP:TableApply("MNTC755")

	//--- Cria as Tarefas
	//Tarefa, Nome da Tarefa, {Tipo de Registro, Codigo do Insumo, Nome do Insumo, {Previsto}, {Realizado} }
	aTarefas := {}
	For nX := 1 To Len(aGrdIns)
		If aGrdIns[nX][3] <> _ATRASO .And. aGrdIns[nX][3] <> _PROJEC //Diferente de Atraso e de Projecao
			nPosTar := 0
			If Len(aTarefas) > 0
				nPosTar := aScan(aTarefas, {|x| x[1] == aGrdIns[nX][1] })
			EndIf
			If nPosTar == 0
				aAdd(aTarefas, {aGrdIns[nX][1], aGrdIns[nX][2]})
				nPosTar := Len(aTarefas)
			EndIf

			nPosIns := 0
			If Len(aTarefas[nPosTar]) > 2
				For nY := 1 To Len(aTarefas[nPosTar])
					If ValType(aTarefas[nPosTar][nY]) == "A"
						If aTarefas[nPosTar][nY][1] == aGrdIns[nX][6] .And. aTarefas[nPosTar][nY][2] == aGrdIns[nX][4]
							nPosIns := nY
							Exit
						EndIf
					EndIf
				Next nY
			EndIf
			If nPosIns == 0
				aAdd(aTarefas[nPosTar], {aGrdIns[nX][6], aGrdIns[nX][4], aGrdIns[nX][5], {" ", " ", " "}, {" ", " ", " "}})
				nPosIns := Len(aTarefas[nPosTar])
			EndIf

			//Duracao do periodo {dias, horas, minutos}
			aDuracao := aClone( NGCALCDHM(aGrdIns[nX][8], aGrdIns[nX][9], aGrdIns[nX][10], aGrdIns[nX][11]) )
			//Transforma a duracao em horas
			nDuracao := (aDuracao[1]*24) + aDuracao[2] + (aDuracao[3]/60)
			cDuracao := cValToChar( Round(nDuracao,2) )
			cDuracao := StrTran(cDuracao, ".", ",")

			If AllTrim(aGrdIns[nX][3]) == "0"
				aTarefas[nPosTar][nPosIns][4][1] := DTOC(aGrdIns[nX][8])+" "+aGrdIns[nX][9]
				aTarefas[nPosTar][nPosIns][4][2] := DTOC(aGrdIns[nX][10])+" "+aGrdIns[nX][11]
				aTarefas[nPosTar][nPosIns][4][3] := cDuracao
			Else
				aTarefas[nPosTar][nPosIns][5][1] := DTOC(aGrdIns[nX][8])+" "+aGrdIns[nX][9]
				aTarefas[nPosTar][nPosIns][5][2] := DTOC(aGrdIns[nX][10])+" "+aGrdIns[nX][11]
				aTarefas[nPosTar][nPosIns][5][3] := cDuracao
			EndIf
		EndIf
	Next nX

	lIndent := .T.
	nTar    := 0
	nIndent := 0

	nTar++
	oAppMsP:Projects(1):Tasks:Add(OemToAnsi(Upper(STR0006))) //"Consulta de O.S."
	oAppMsP:Projects(1):Tasks(nTar):Text1 := cPlano //Plano
	oAppMsP:Projects(1):Tasks(nTar):Text2 := cOS //O.S.

	For nX := 1 To Len(aTarefas)
		nTar++
		oAppMsP:Projects(1):Tasks:Add(aTarefas[nX][2]) //Nome da Tarefa

		//A cada nova tarefa, limpa todas as indentacoes ate' o inicio
		For nIndent := 1 To 3 //3 -> numero de indentacoes totais da TAREFA
			//Limpa a Indentacao
			oAppMsP:Projects(1):Tasks(nTar):OutLineOutIndent()
		Next nIndent
		//Atribui a Indentacao
		oAppMsP:Projects(1):Tasks(nTar):OutLineIndent()

		lIndent := .T.
		//Os insumos comecam na posicao 3
		For nY := 3 To Len(aTarefas[nX])
			nTar++
			oAppMsP:Projects(1):Tasks:Add(aTarefas[nX][nY][1]+" - "+aTarefas[nX][nY][3]) //Tipo de Registro - Nome do Insumo
			If nY > 3
				//A cada novo insumo, limpa todas as indentacoes ate' o inicio para reiniciar estas indentacoes
				For nIndent := 1 To 2 //2 -> numero de indentacoes totais do TIPO DE REGISTRO
					//Limpa a Indentacao
					oAppMsP:Projects(1):Tasks(nTar):OutLineOutIndent()
				Next nIndent
			EndIf
			//Atribui a Indentacao
			oAppMsP:Projects(1):Tasks(nTar):OutLineIndent()

			If !Empty(aTarefas[nX][nY][4][1])
				nTar++
				oAppMsP:Projects(1):Tasks:Add(STR0077) //"Previsto"
				oAppMsP:Projects(1):Tasks(nTar):Start  := aTarefas[nX][nY][4][1] //Data e Hora Inicio
				oAppMsP:Projects(1):Tasks(nTar):Finish := aTarefas[nX][nY][4][2] //Data e Hora Fim

				oAppMsP:Projects(1):Tasks(nTar):Duration := aTarefas[nX][nY][4][3] //Duracao

				If lIndent
					//Atribui a Indentacao
					oAppMsP:Projects(1):Tasks(nTar):OutLineIndent()

					lIndent := .F.
				EndIf
			EndIf
			If !Empty(aTarefas[nX][nY][5][1])
				nTar++
				oAppMsP:Projects(1):Tasks:Add(STR0078) //"Realizado"
				oAppMsP:Projects(1):Tasks(nTar):Start  := aTarefas[nX][nY][5][1] //Data e Hora Inicio
				oAppMsP:Projects(1):Tasks(nTar):Finish := aTarefas[nX][nY][5][2] //Data e Hora Fim

				oAppMsP:Projects(1):Tasks(nTar):Duration := aTarefas[nX][nY][5][3] //Duracao

				If lIndent
					//Atribui a Indentacao
					oAppMsP:Projects(1):Tasks(nTar):OutLineIndent()

					lIndent := .F.
				EndIf
			EndIf

			lIndent := .T.
		Next nY
	Next nX

	//Permite a Visualizacao no Msproject
	If nTar > 0
		oAppMsP:Visible := .T.

		//Emite um aviso sobre a finalizacao da exportacao, logo, o documento pode ser visualizado
		Aviso(STR0116,; //"Assistente de Integra็ใo"
		STR0250+_ENTER+; //"O projeto selecionado estแ disponํvel no Microsoft Project para visualiza็ใo."
		STR0251+" '"+STR0151+"' "+STR0252,; //"Selecione a op็ใo"###"Sair"###"para finalizar a integra็ใo com o Microsoft Project."
		{STR0151},2) //"Sair"
	Else
		MsgInfo(STR0253,STR0089) //"Nใo hแ dados para exportar."###"Aten็ใo"
	EndIf

	//Destroi o objeto do MsProject
	oAppMsP:Quit(0)
	oAppMsP:Destroy()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ SECAO: GRAFICO DE GANTT - FIM                                         บฑฑ
ฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ SECAO: FUNCOES DIVERSAS - INICIO                                      บฑฑ
ฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMNTC755INIบAutor  ณWagner S. de Lacerdaบ Data ณ  28/02/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega as variaveis no seu estado inicial.                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ lInitOS -> Opcional;                                       บฑฑ
ฑฑบ          ณ            Define se a variavel de Ordem de Servico deve   บฑฑ
ฑฑบ          ณ            ser inicializada (ou re-inicializada).          บฑฑ
ฑฑบ          ณ            Default: .T. -> Inicializar.                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC755INI(lInitOS)

	Local aCpos := {}, aNao := {}, nX
	Local nTAREFA

	Default lInitOS := .T.

	//Data e Hora da Consulta
	dCOSDtIni := dDataBase
	cCOSHrIni := SubStr(Time(),1,5)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Cabecalho                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lInitOS
		cOS     := Space(TAMSX3("TJ_ORDEM")[1])
	EndIf
	cPlano     := Space(TAMSX3("TJ_PLANO")[1])
	cBemLoc    := Space(TAMSX3("TJ_CODBEM")[1])
	cNomBemLoc := Space(TAMSX3("T9_NOME")[1])
	cPriorid   := Space(TAMSX3("TJ_PRIORID")[1])
	cServico   := Space(TAMSX3("TJ_SERVICO")[1])
	cTipoOS    := Space(TAMSX3("TJ_TIPOOS")[1])
	cSolici    := Space(TAMSX3("TJ_SOLICI")[1])
	cSequencia := Space(TAMSX3("TJ_SEQRELA")[1])
	lOSTermino := .F.
	lOSCorret  := .F.
	lOSCancela := .F.

	If Type("oBtnStat") == "O"
		oBtnStat:LoadBitmaps("BR_BRANCO")
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Folder 1 - Dados Cadastrais ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	/* Carregado via Enchoice (MsMGet) */

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Folder 2 - Custos            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aI2Custos  := {}
	aI2HeaCus  := {STR0090, STR0091, STR0092, STR0093, STR0094, STR0077, STR0078, STR0095, STR0296} //"Tarefa"###"Descri็ใo"###"Tipo de Insumo"###"C๓digo"###"Nome"###"Previsto"###"Realizado"###"Diferen็a"###"Varia็ใo (%)"
	aI2SizCus  := {10, 40, 15, 15, 30, 15, 15, 15, 15} //Ao alterar esta variavel, deve considerar estes tamanhos nos Relatorios!!! (Pardrao e Personalizavel)
	lI2CarTar  := .T. //Separa por tarefa
	lI2TarClik := .T. //Separa por tarefa

	lI2ViuPXR  := .F. //Viu o folder do grafico de Custos de Insumos Previstos x Realizados?
	lI2ViuOSXS := .F. //Viu o folder do grafico de Custos da O.S. x Servico?

	aI2DadosOS := {}
	aAdd(aI2DadosOS, {"F",0})
	aAdd(aI2DadosOS, {"M",0})
	aAdd(aI2DadosOS, {"P",0})
	aAdd(aI2DadosOS, {"T",0})
	aAdd(aI2DadosOS, {"E",0})

	aI2DadosSe := {}
	aAdd(aI2DadosSe, {"F",0})
	aAdd(aI2DadosSe, {"M",0})
	aAdd(aI2DadosSe, {"P",0})
	aAdd(aI2DadosSe, {"T",0})
	aAdd(aI2DadosSe, {"E",0})

	cI2ParItem := STR0148 //"Semestral"
	dI2ParDtDe := dCOSDtIni - (6 * 30)
	dI2ParDtAt := dCOSDtIni

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Folder 3 - Detalhes          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//--- Insumos
	dbSelectArea(cTRBIns)
	ZAP

	aI3DetInsP := {}
	aI3DetInsR := {}
	aI3HeadIns := { {}, {} }

	//Tarefa, Nome da Tarefa, SeqRela, Tipo de Insumo, C๓digo, Nome, Qtde. Recurso, Qtde. Utilizada,
	//Unidade, Destino, Data Inํcio, Hora Inํcio, Data Fim, Hora Fim}
	aCpos := {"TL_TAREFA" , "TL_NOMTAR" , "TL_TIPOREG","TL_SEQRELA",;
	"TL_CODIGO" , "TL_NOMCODI", "TL_USACALE", "TL_QUANREC", "TL_QUANTID", ;
	"TL_UNIDADE", "TL_DESTINO", "TL_OBSERVA", "TL_DTINICI", ;
	"TL_HOINICI", "TL_DTFIM"  , "TL_HOFIM"  , If(NGCADICBASE("TL_PCTHREX","A","STL",.F.), "TL_PCTHREX", "TL_HREXTRA"), ;
	"TL_LOCAL"  , "TL_LOTECTL", "TL_NUMLOTE", "TL_LOCALIZ","TL_CUSTO","TL_NUMSERI",;
	"TL_ETAPA","TL_GARANTI","TL_DTVALID"}
	If lPerMDO
		aAdd(aCpos, "TL_PERMDOE")
	EndIf
	aNao  := aClone(fCposSim("STL", aCpos))
	aI3HeadIns[1] := CABECGETD("STL", aNao, 2)

	aCpos := {"TT_TAREFA" , "TT_NOMTAR" , "TT_TIPOREG","TT_SEQRELA",;
	"TT_CODIGO" , "TT_NOMCODI", "TT_USACALE", "TT_QUANREC", "TT_QUANTID", ;
	"TT_UNIDADE", "TT_DESTINO", "TT_OBSERVA", "TT_DTINICI", ;
	"TT_HOINICI", "TT_DTFIM"  , "TT_HOFIM"  , If(NGCADICBASE("TT_PCTHREX","A","STT",.F.), "TT_PCTHREX", "TT_HREXTRA"), ;
	"TT_LOCAL"  , "TT_LOTECTL", "TT_NUMLOTE", "TT_LOCALIZ","TT_CUSTO","TT_NUMSERI",;
	"TT_ETAPA","TT_GARANTI","TT_DTVALID"}
	If lPerMDO
		aAdd(aCpos, "TT_PERMDOE")
	EndIf
	aNao  := aClone(fCposSim("STT", aCpos))
	aI3HeadIns[2] := CABECGETD("STT", aNao, 2)

	//--- Etapas
	dbSelectArea(cTRBEta)
	ZAP

	aI3DetEta  := {}
	aI3HeadEta := { {}, {} }

	aNao  := {'TQ_FILIAL', 'TQ_ORDEM', 'TQ_PLANO', 'TQ_NOMSITU', 'TQ_OK', 'TQ_OPCOES', 'TQ_SEQTARE'}
	aI3HeadEta[1] := NgHeader( 'STQ', aNao, .F. )

	aNao  := {'TX_FILIAL', 'TX_ORDEM', 'TX_PLANO', 'TX_NOMSITU', 'TX_OK', 'TX_OPCOES', 'TX_SEQTARE'}
	aI3HeadEta[2] := NgHeader( 'STX', aNao, .F. )

	//O Campo TQ_OK e' adicionado neste momento por se Nao Usado, e o cabec nao construi-lo automaticamente
	If aScan(aI3HeadEta[1], {|x| AllTrim(x[2]) == "TQ_OK" }) == 0

		aAdd(aI3HeadEta[1], { "OK", "TQ_OK", Posicione("SX3",2,"TQ_OK","X3_PICTURE"), Posicione("SX3",2,"TQ_OK","X3_TAMANHO"), Posicione("SX3",2,"TQ_OK","X3_DECIMAL"), "", Posicione("SX3",2,"TQ_OK","X3_USADO"),;
							 Posicione("SX3",2,"TQ_OK","X3_TIPO"), Posicione("SX3",2,"TQ_OK","X3_ARQUIVO"), Posicione("SX3",2,"TQ_OK","X3_CONTEXT") } )

		aAdd(aI3HeadEta[2], { "OK", "TX_OK", Posicione("SX3",2,"TX_OK","X3_PICTURE"), Posicione("SX3",2,"TX_OK","X3_TAMANHO"), Posicione("SX3",2,"TX_OK","X3_DECIMAL"), "",;
		 					Posicione("SX3",2,"TX_OK","X3_USADO"), Posicione("SX3",2,"TX_OK","X3_TIPO"), Posicione("SX3",2,"TX_OK","X3_ARQUIVO"), Posicione("SX3",2,"TX_OK","X3_CONTEXT") } )
	EndIf

	//--- Ocorrencias
	dbSelectArea(cTRBOco)
	ZAP

	aI3DetOco  := {}
	aI3HeadOco := { {}, {} }

	//Tarefa, Nome da Tarefa, Ocorr๊ncias, Nome da Ocorr๊ncias, Causa, Nome da Causa,;
	//Solu็ใo, Nome da Solu็ใo, Descri็ใo
	aCpos := {"TN_TAREFA", "TN_NOMETAR", "TN_CODOCOR" , "TN_NOMOCOR", "TN_CAUSA", "TN_NOMCAUS",;
	"TN_SOLUCAO", "TN_NOMSOLU", "TN_DESCRIC"}
	aNao  := aClone(fCposSim("STN", aCpos))
	aI3HeadOco[1] := CABECGETD("STN", aNao, 2)

	aCpos := {"TU_TAREFA", "TU_NOMETAR", "TU_CODOCOR" , "TU_NOMOCOR", "TU_CAUSA", "TU_NOMCAUS",;
	"TU_SOLUCAO", "TU_NOMSOLU", "TU_DESCRIC"}
	aNao  := aClone(fCposSim("STU", aCpos))
	aI3HeadOco[2] := CABECGETD("STU", aNao, 2)

	//--- Motivos de Atraso
	aI3DetMot  := {}
	aI3HeadMot := { {}, {} }

	//Motivo, Descri็ใo, Data Inํcio, Hora Inํcio, Data Fim, Hora Fim
	aCpos := {"TPL_CODMOT", "TPL_DESMOT", "TPL_DTINIC", "TPL_HOINIC", "TPL_DTFIM", "TPL_HOFIM"}
	aNao  := aClone(fCposSim("TPL", aCpos))
	aI3HeadMot[1] := CABECGETD("TPL", aNao, 2)

	aCpos := {"TQ6_CODMOT", "TQ6_DESMOT", "TQ6_DTINIC", "TQ6_HOINIC", "TQ6_DTFIM", "TQ6_HOFIM"}
	aNao  := aClone(fCposSim("TQ6", aCpos))
	aI3HeadMot[2] := CABECGETD("TQ6", aNao, 2)

	//--- Problemas
	dbSelectArea(cTRBPro)
	ZAP

	aI3DetPro  := {}
	aI3HeadPro := { {}, {} }

	//Tarefa, Nome da Tarefa, Tipo de Insumo, C๓digo, Nome, Descri็ใo do Problema
	aCpos := {"TA_TAREFA", "TA_NOMTAR", "TA_NOMTREG", "TA_CODIGO", "TA_NOMCODI", "TA_DESCRIC"}
	aNao  := aClone(fCposSim("STA", aCpos))
	aI3HeadPro[1] := CABECGETD("STA", aNao, 2)
	//Chuncho para aumentar o tamanho do campo na GetDados para nao truncar o titulo da Tarefa (Chuncho solicitado pela qualidade; para ficar mais 'bonito')
	nTAREFA := aScan(aI3HeadPro[1], {|x| "TA_TAREFA" $ AllTrim(Upper(x[2])) })
	aI3HeadPro[1][nTAREFA][4] += 2

	aCpos := {"TV_TAREFA", "TV_NOMTAR", "TV_NOMTREG", "TV_CODIGO", "TV_NOMCODI", "TV_DESCRIC"}
	aNao  := aClone(fCposSim("STV", aCpos))
	aI3HeadPro[2] := CABECGETD("STV", aNao, 2)
	//Chuncho para aumentar o tamanho do campo na GetDados para nao truncar o titulo da Tarefa (Chuncho solicitado pela qualidade; para ficar mais 'bonito')
	nTAREFA := aScan(aI3HeadPro[2], {|x| "TV_TAREFA" $ AllTrim(Upper(x[2])) })
	aI3HeadPro[1][nTAREFA][4] += 2

	If lSintomas
		//--- Sintomas
		dbSelectArea(cTRBSin)
		ZAP

		aI3DetSin  := {}

		//Data, C๓digo, Descri็ใo
		aCpos := {"TTC_DATA", "TTC_CDSINT", "TTC_DESSIN"}
		aNao  := aClone(fCposSim("TTC", aCpos))

		aI3HeadSin := CABECGETD("TTC", aNao, 2)
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Folder 5 - Informacoes ERP   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lUsaIntERP //Usa Integracao com ERP?
		//Documentos de Entrada
		aI5ERPDoc  := {}
		aI5HeadDoc := {" ", RetTitle("D1_DOC"), RetTitle("D1_ITEM"), RetTitle("D1_COD"), RetTitle("B1_DESC"), RetTitle("D1_UM"),;
		RetTitle("D1_QUANT"), RetTitle("D1_TOTAL"), STR0023} //"O.S."
		aI5SizeDoc := {2, 20, 20, 30, 40, 25, 25, 25, 25}
		bI5LineDoc := {||;
		{fGetCores(1,oI5BrwDoc:nAt),;
		PADR(aI5ERPDoc[oI5BrwDoc:nAt,01],20," "),;
		PADR(aI5ERPDoc[oI5BrwDoc:nAt,02],20," "),;
		PADR(aI5ERPDoc[oI5BrwDoc:nAt,03],30," "),;
		PADR(aI5ERPDoc[oI5BrwDoc:nAt,04],40," "),;
		PADR(aI5ERPDoc[oI5BrwDoc:nAt,05],25," "),;
		Transform(aI5ERPDoc[oI5BrwDoc:nAt,06],"@E 9,999,999,999,999.99"),;
		Transform(aI5ERPDoc[oI5BrwDoc:nAt,07],"@E 9,999,999,999,999.99"),;
		PADR(aI5ERPDoc[oI5BrwDoc:nAt,08],15," ")};
		}

		//Solicitacoes de Compra
		aI5ERPCom  := {}
		aI5HeadCom := {" ", RetTitle("C1_NUM"), RetTitle("C1_ITEM"),RetTitle("C1_PRODUTO"), RetTitle("B1_DESC"), RetTitle("C1_QUANT"), RetTitle("C1_UM"),;
		RetTitle("C1_EMISSAO"), RetTitle("C1_PEDIDO"), RetTitle("C1_DATPRF"), STR0102, STR0023} //"Solicitante"###"O.S."

		aI5SizeCom := {2, 20, 20, 30, 40, 25, 25, 20, 25, 25, 25, 15}
		bI5LineCom := {||;
		{fGetCores(2,oI5BrwCom:nAt),;
		PADR(aI5ERPCom[oI5BrwCom:nAt,01],20," "),;
		PADR(aI5ERPCom[oI5BrwCom:nAt,02],20," "),;
		PADR(aI5ERPCom[oI5BrwCom:nAt,03],30," "),;
		PADR(aI5ERPCom[oI5BrwCom:nAt,04],40," "),;
		Transform(aI5ERPCom[oI5BrwCom:nAt,05],"@E 9,999,999,999,999.99"),;
		PADR(aI5ERPCom[oI5BrwCom:nAt,06],25," "),;
		PADR(aI5ERPCom[oI5BrwCom:nAt,07],20," "),;
		PADR(aI5ERPCom[oI5BrwCom:nAt,08],25," "),;
		PADR(aI5ERPCom[oI5BrwCom:nAt,09],25," "),;
		PADR(aI5ERPCom[oI5BrwCom:nAt,10],25," "),;
		PADR(aI5ERPCom[oI5BrwCom:nAt,11],15," ")};
		}

		//Solicitacoes ao Armazem
		aI5ERPArm  := {}
		aI5HeadArm := {" ", RetTitle("CP_NUM"), RetTitle("CP_ITEM"), RetTitle("CP_PRODUTO"), RetTitle("B1_DESC"), RetTitle("CP_QUANT"), RetTitle("CP_OBS"), STR0102, STR0023} //"Solicitante"###"O.S."
		aI5SizeArm := {2, 20, 20, 30, 40, 25, 40, 30, 15}
		bI5LineArm := {||;
		{fGetCores(3,oI5BrwArm:nAt),;
		PADR(aI5ERPArm[oI5BrwArm:nAt,01],20," "),;
		PADR(aI5ERPArm[oI5BrwArm:nAt,02],20," "),;
		PADR(aI5ERPArm[oI5BrwArm:nAt,03],30," "),;
		PADR(aI5ERPArm[oI5BrwArm:nAt,04],40," "),;
		Transform(aI5ERPArm[oI5BrwArm:nAt,05],"@E 9,999,999,999,999.99"),;
		PADR(aI5ERPArm[oI5BrwArm:nAt,06],40," "),;
		PADR(aI5ERPArm[oI5BrwArm:nAt,07],30," "),;
		PADR(aI5ERPArm[oI5BrwArm:nAt,08],15," ")};
		}
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Grid de Tarefas             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cGrdTAtuCo := Space(TAMSX3("T5_TAREFA")[1])
	cGrdTAtuNo := Space(TAMSX3("T5_DESCRIC")[1])
	dGrdTAtuD1 := CTOD("  /  /    ")
	cGrdTAtuH1 := "  :  "
	dGrdTAtuD2 := CTOD("  /  /    ")
	cGrdTAtuH2 := "  :  "
	cGrdTAtuDe := Space(TAMSX3("TL_DESTINO")[1])

	aGrdIns  := {}
	aGrdTips := {}
	aGrdTars := {}

	aTreeOS  := {}
	aTreeTar := {}
	aTreeTip := {}
	aTreeIns := {}

	aGrdGrafic := {}

	nGrdResolu := 1 //Intervalo de 60 Minutos
	nGrdZoom   := 3 //Zoom Normal
	dGrdDtIni  := CTOD("  /  /    ")
	dGrdDtMin  := CTOD("  /  /    ")
	dGrdDtMax  := CTOD("  /  /    ")

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfSeekOS   บAutor  ณWagner S. de Lacerdaบ Data ณ  26/08/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca a Ordem de Servico.                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ aSeekOS -> Array contendo o retorno da funcao:             บฑฑ
ฑฑบ          ณ            [1] - .T. - O.S. encontrada                     บฑฑ
ฑฑบ          ณ                  .F. - O.S. nao encontrada                 บฑฑ
ฑฑบ          ณ            [2] - Tabela na qual a O.S. foi encontrada      บฑฑ
ฑฑบ          ณ            [3] - .T. - A Tabela encontrada e' diferente    บฑฑ
ฑฑบ          ณ                        da anterior                         บฑฑ
ฑฑบ          ณ                  .F. - A Tabela encontrada e' a mesma que aบฑฑ
ฑฑบ          ณ                        anterior                            บฑฑ
ฑฑบ          ณ            [4] - Indica o prefixo dos campos a partir da   บฑฑ
ฑฑบ          ณ                  tabela encontrada.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fSeekOS()

	Local aSeek      := {}
	Local lSeekAchou := .F.
	Local cSeekTbl   := cTabela
	Local lSeekTroca := .F.
	Local cSeekPref  := ""

	dbSelectArea("STJ")
	dbSetOrder(1)
	If dbSeek(xFilial("STJ")+cOS)
		lSeekAchou := .T.

		If cSeekTbl <> "STJ"
			lSeekTroca := .T.
		EndIf

		cSeekTbl  := "STJ"
		cSeekPref := "STJ->TJ_"
	Else
		dbSelectArea("STS")
		dbSetOrder(1)
		If dbSeek(xFilial("STS")+cOS)
			lSeekAchou := .T.

			If cSeekTbl <> "STS"
				lSeekTroca := .T.
			EndIf

			cSeekTbl  := "STS"
			cSeekPref := "STS->TS_"
		EndIf
	EndIf

	If !lSeekAchou
		If Empty(cOS)
			ShowHelpDlg(STR0110,; //"Registro Inexistente."
			{STR0111+" "+STR0291},2,; //"A Ordem de Servi็o"###"nใo foi informada."
			{STR0292},2) //"Informe a Ordem de Servi็o."
		Else
			ShowHelpDlg(STR0110,; //"Registro Inexistente."
			{STR0111+" '"+cOS+"' "+STR0112},2,; //"A Ordem de Servi็o"###"nใo foi encontrada."
			{STR0113},2) //"Insira uma O.S. que esteja cadastrada no sistema."
		EndIf
	EndIf

	aSeek := {lSeekAchou, cSeekTbl, cSeekPref, lSeekTroca}

Return aSeek

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMNTC755VOSบAutor  ณWagner S. de Lacerdaบ Data ณ  28/02/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida a O.S. e preenche os campos relacionados.           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T. -> Ordem de Servico valida.                            บฑฑ
ฑฑบ          ณ .F. -> Ordem de Servico invalida.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC755VOS()

	Local aStruct := {}, aSeekOS := {}
	Local cPrefix := "", cField := ""
	Local lSeek   := .F., lChgTbl := .F.

	If IsInCallStack("MNTC755SAI") .Or. IsInCallStack("SAFEEVAL") //SAFEEVAL e' utilizado no Confirmar da EnchoiceBar
		oTree:SetFocus()
		Return .T.
	EndIf

	If !Empty(cOS) .And. cOS == cOldOS .And. !IsInCallStack("MNTC755ATU")
		oTree:SetFocus()
		Return .T.
	EndIf

	//Data e Hora em que a O.S. foi selecionada
	dCOSDtIni := dDataBase
	cCOSHrIni := SubStr(Time(),1,5)

	//Busca a Ordem de Servico
	aSeekOS := aClone( fSeekOS() )
	lSeek   := aSeekOS[1]
	cTabela := aSeekOS[2]
	cPrefix := aSeekOS[3]
	lChgTbl := aSeekOS[4]

	If lSeek
		aAreaOS := GetArea()
		cTipoOS := &(cPrefix + "TIPOOS")

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Cabecalho                   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cOS      := &(cPrefix + "ORDEM")
		cPlano   := &(cPrefix + "PLANO")
		cBemLoc  := &(cPrefix + "CODBEM")
		cServico := &(cPrefix + "SERVICO")
		If cTipoOS == "B"
			cNomBemLoc := SubStr(NGSEEK("ST9",&(cPrefix + "CODBEM"),1,"T9_NOME"),1,40)
		Else
			cNomBemLoc := SubStr(NGSEEK("TAF","X"+"2"+AllTrim(&(cPrefix + "CODBEM")),7,"TAF_NOMNIV"),1,56)
		EndIf
		cPriorid := &(cPrefix + "PRIORID")
		cSolici  := &(cPrefix + "SOLICI")
		cSequencia := If(NGVERIFY(cTabela),&(cPrefix + "SEQRELA"),Str(&(cPrefix + "SEQUENC"),3))

		lOSTermino := &(cPrefix + "TERMINO") == "S" .and. &(cPrefix + "SITUACA") <> "C"
		lOSCorret  := (Val(&(cPrefix + "PLANO")) == 0)
		lOSCancela := &(cPrefix + "SITUACA") == "C"

		If lOSTermino
			oBtnStat:LoadBitmaps("BR_AZUL") //Terminada
		ElseIf &(cPrefix + "SITUACA") == "L" //Liberada
			If (dCOSDtIni < &(cPrefix + "DTMPFIM")) .Or. (dCOSDtIni == &(cPrefix + "DTMPFIM") .And. cCOSHrIni < &(cPrefix + "HOMPFIM"))
				oBtnStat:LoadBitmaps("BR_VERDE") //Em dia
			ElseIf (dCOSDtIni == &(cPrefix + "DTMPFIM") .And. cCOSHrIni > &(cPrefix + "HOMPFIM")) .Or. (dCOSDtIni > &(cPrefix + "DTMPFIM"))
				If cTabela == "STJ"
					dbSelectArea("TPL")
					dbSetOrder(1)
					If dbSeek(xFilial("TPL")+cOS)
						oBtnStat:LoadBitmaps("BR_LARANJA") //Em atraso com motivo
					Else
						oBtnStat:LoadBitmaps("BR_AMARELO") //Em atraso
					EndIf
				Else
					dbSelectArea("TQ6")
					dbSetOrder(1)
					If dbSeek(xFilial("TQ6")+cOS)
						oBtnStat:LoadBitmaps("BR_LARANJA") //Em atraso com motivo
					Else
						oBtnStat:LoadBitmaps("BR_AMARELO") //Em atraso
					EndIf
				EndIf
			EndIf
		ElseIf &(cPrefix + "SITUACA") == "P" //Pendente
			If (dCOSDtIni < &(cPrefix + "DTMPFIM")) .Or. (dCOSDtIni == &(cPrefix + "DTMPFIM") .And. cCOSHrIni < &(cPrefix + "HOMPFIM"))
				oBtnStat:LoadBitmaps("BR_CINZA") //Em dia
			ElseIf (dCOSDtIni == &(cPrefix + "DTMPFIM") .And. cCOSHrIni > &(cPrefix + "HOMPFIM")) .Or. (dCOSDtIni > &(cPrefix + "DTMPFIM"))
				oBtnStat:LoadBitmaps("BR_MARROM") //Em atraso
			EndIf
		ElseIf &(cPrefix + "SITUACA") == "C" //Cancelada
			oBtnStat:LoadBitmaps("BR_VERMELHO")
		Else
			oBtnStat:LoadBitmaps("BR_BRANCO") //Nao definida
		EndIf
		RegToMemory(cTabela,.F.)

		//Prepara os Folders para a atualizacao
		oI2Folder:SetOption(1)
		oI3Folder:SetOption(1)

		//Troca as tabelas dos objetos
		If lChgTbl
			aI1Gerais  := aClone(MNTC755MON(10))
			aI1Manuten := aClone(MNTC755MON(11))
			aI1Complem := aClone(MNTC755MON(12))

			aI3DetInsP := aClone(MNTC755MON(30))
			aI3DetInsR := aClone(MNTC755MON(30))
			aI3DetEta  := aClone(MNTC755MON(31))
			aI3DetOco  := aClone(MNTC755MON(32))
			aI3DetMot  := aClone(MNTC755MON(33))
			aI3DetPro  := aClone(MNTC755MON(34))
			If lSintomas
				aI3DetSin  := aClone(MNTC755MON(35))
			EndIf

			MNTC755I01() //Dados Cadastrais
			MNTC755I03() //Detalhes
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Folder 1 - Dados Cadastrais ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oI1Gerais:Refresh()
		oI1Manuten:Refresh()
		oI1Complem:Refresh()

		Processa({|| fCarTRBs()}, STR0105) //"Processando Arquivos Temporแrios...."

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Folder 2 - Custos           ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		lI2TarClik := .T.
		lI2CarTar  := .T.
		Processa({|| fI2CarCust()}, STR0087) //"Processando Custos da Ordem de Servi็o..."
		Processa({|| fI2CarPXR()} , STR0106) //"Processando Grแfico de Previstos x Realizados..."
		Processa({|| fI2CarOSXS()}, STR0107) //"Processando Grแfico da O.S. x Hist๓rico..."

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Folder 3 - Detalhes         ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Processa({|| fI3CarDet()}, STR0108) //"Processando Detalhes da O.S...."

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Folder 4 - Solicit. de Serv. ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If Type("oI4Solicit") == "O"
			RegToMemory("TQB",.F.)
			oI4Solicit:Refresh()
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Folder 5 - Informacoes ERP   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If lUsaIntERP //Usa Integracao com ERP?
			Processa({|| fI5CarERP()}, STR0109) //"Processando Integra็๕es da O.S...."
		EndIf

		//Verifica os botoes e folders que devem ser habilitadas
		MNTC755HAB()

		//Define qual o conteudo a ser mostrado por primeiro em tela
		If !IsInCallStack("MNTC755ATU")
			MNTC755INF(,.F.)
		EndIF

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Grid de Tarefas              ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		//Monta o Grid de Tarefas
		Processa({|| MNTC755GRD()}, STR0198) //"Atualizando Gantt..."
		//	MsgRun(STR0197, STR0198, {|| MNTC755GRD() } ) //"Atualizando o Gantt de Tarefas... Por favor aguarde..."###"Atualizando Gantt..."

		If oTree:IsEmpty() //Se a arvore estiver vazia, entao o Gantt nao foi montado
			oDlgGrdTar:Hide()
			oDlgInfo:Hide()
			MNTC755INF(,.T.)
		Else //Se for montado, mostra o Gantt
			oDlgGrdTar:Show()
		EndIf

		//Devolve a area da Ordem de Servico
		RestArea(aAreaOS)
	Else
		//Habilita somente o botao da Legenda
		oBtnStat:Enable()

		//--- Seta o Foco Inicial
		oOS:SetFocus()

		fSetUpdate() //Define a atualizacao da tela

		oTree:SetFocus()
		Return .F.
	EndIf

	fSetUpdate() //Define a atualizacao da tela

	oBemLoc:CtrlRefresh()
	oNomBemLoc:CtrlRefresh()
	oPlano:CtrlRefresh()
	oPriorid:CtrlRefresh()
	oServico:CtrlRefresh()

	cOldOS := cOS

	oTree:SetFocus()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMNTC755ATUบAutor  ณWagner S. de Lacerdaบ Data ณ  01/03/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza a Consulta de O.S.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC755ATU()

	If !MNTC755VOS() //Verifica a O.S.
		oOS:SetFocus()
		Return .F.
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMNTC755HABบAutor  ณWagner S. de Lacerdaบ Data ณ  01/03/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica os dados da O.S. e habilita/desabilita os botoes eบฑฑ
ฑฑบ          ณ folders.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ lDisable -> Opcional;                                      บฑฑ
ฑฑบ          ณ             Define se deve desabilitar todas as abas.      บฑฑ
ฑฑบ          ณ             Default: .F. -> Verificar primeiro.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC755HAB( lDisable )

	Local lI2Custos  := .T.
	Local lI2GrfPXR  := .T.
	Local lI2GrfOSXS := .T.
	Local lI3DetInsP := .T.
	Local lI3DetInsR := .T.
	Local lI3DetEta  := .T.
	Local lI3DetOco  := .T.
	Local lI3DetMot  := .T.
	Local lI3DetPro  := .T.
	Local lI3DetSin  := .T.
	Local lI5ERPDoc  := .T.
	Local lI5ERPCom  := .T.
	Local lI5ERPArm  := .T.

	Default lDisable := .F.

	If lDisable
		oBtnInfo02:Disable()
		oBtnInfo03:Disable()
		oBtnInfo04:Disable()
		oBtnInfo05:Disable()

		oOS:SetFocus()

		Return .T.
	EndIf

	fHowInitFo(1)

	//Folder 2 - Custos
	lI2Custos  := Len(aI2Custos) > 0 .And. !Empty(aI2Custos[1][1])
	lI2GrfPXR  := (nI2SerieP <> 0 .Or. nI2SerieR <> 0)
	lI2GrfOSXS := (nI2SerieOS <> 0 .Or. nI2SerieSe <> 0)

	If !lOSCancela .And. (lI2Custos .Or. lI2GrfPXR .Or. lI2GrfOSXS)
		oBtnInfo02:Enable()

		fHowInitFo(2)

		//--- Verifica do Ultimo para o Primeiro para a atualizacao correta do folder

		//Grafico de Custos Realizados da O.S. x Servico
		If lI2GrfOSXS
			oI2Folder:aEnable(3,.T.)
			oI2GrfOSXS:Show()
			oI2DadOSXS:Hide()
		Else
			oI2GrfOSXS:Hide()
			oI2DadOSXS:Show()
		EndIf

		//Grafico de Custos Previstos x Realizados
		If lI2GrfPXR
			oI2Folder:aEnable(2,.T.)
		Else
			oI2Folder:aEnable(2,.F.)
		EndIf

		//Custos
		If lI2Custos
			oI2Folder:aEnable(1,.T.)
		Else
			oI2Folder:aEnable(1,.F.)
		EndIf
	Else
		oBtnInfo02:Disable()
	EndIf

	//Folder 3 - Detalhes
	lI3DetInsP := Len( aI3DetInsP ) > 0 .And. !Empty( aI3DetInsP[1][1] ) //Verifica se nใo foi realizada
	lI3DetInsR := Len( aI3DetInsR ) > 0 .And. !Empty( aI3DetInsR[1][1] ) //Verifica se foi realizado
	lI3DetEta  := Len( aI3DetEta )  > 0 .And. !Empty( aI3DetEta[1][3]  ) //Verifica C๓digo da Etapa
	lI3DetOco  := Len( aI3DetOco )  > 0 .And. !Empty( aI3DetOco[1][3]  ) //Verifica se o problema foi preenchido
	lI3DetMot  := Len( aI3DetMot )  > 0 .And. !Empty( aI3DetMot[1][1]  ) //Verifica se o motivo de atraso foi preenchido
	lI3DetPro  := Len( aI3DetPro )  > 0 .And. !Empty( aI3DetPro[1][3]  ) //Verifica C๓digo do Problema
	If lSintomas
		lI3DetSin  := Len( aI3DetSin ) > 0 .And. !Empty( aI3DetSin[1][1] ) //Verifica C๓digo do Sintoma
	Else
		lI3DetSin  := .F.
	EndIf

	If lI3DetInsP .Or. lI3DetInsR .Or. lI3DetEta .Or. lI3DetOco .Or. lI3DetMot .Or. lI3DetPro .Or. lI3DetSin //Se houver algum registro em Detalhes
		oBtnInfo03:Enable()

		fHowInitFo(3)

		//--- Verifica do Ultimo para o Primeiro para a atualizacao correta do folder

		If lSintomas
			//Sintomas
			If lI3DetSin
				oI3Folder:aEnable(6,.T.)
			Else
				oI3Folder:aEnable(6,.F.)
			EndIf
		EndIf

		//Problemas
		If lI3DetPro
			oI3Folder:aEnable(5,.T.)
		Else
			oI3Folder:aEnable(5,.F.)
		EndIf

		//Motivos de Atraso
		If lI3DetMot
			oI3Folder:aEnable(4,.T.)
		Else
			oI3Folder:aEnable(4,.F.)
		EndIf

		//Ocorrencias
		If lI3DetOco
			oI3Folder:aEnable(3,.T.)
		Else
			oI3Folder:aEnable(3,.F.)
		EndIf

		//Etapas
		If lI3DetEta
			oI3Folder:aEnable(2,.T.)
		Else
			oI3Folder:aEnable(2,.F.)
		EndIf

		//Insumos
		If lI3DetInsP .Or. lI3DetInsR
			oI3Folder:aEnable(1,.T.)
			If lI3DetInsP
				oI3PnlInsP:Show()
			Else
				oI3PnlInsP:Hide()
			EndIf

			If lI3DetInsR
				oI3PnlInsR:Show()
			Else
				oI3PnlInsR:Hide()
			EndIf
		Else
			oI3Folder:aEnable(1,.F.)
		EndIf
	Else //Caso contrario (nao ha nenhum)
		oBtnInfo03:Disable()
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Folder 4 - Solicit. de Serv. ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("TQB")
	dbSetOrder(1)
	If dbSeek(xFilial("TQB")+cSolici)
		oBtnInfo04:Enable()

		fHowInitFo(4)

		aAreaSoli := GetArea()
	Else
		oBtnInfo04:Disable()

		aAreaSoli := {}
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Folder 5 - Informacoes ERP  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lUsaIntERP //Usa Integracao com ERP?
		lI5ERPDoc := Len(aI5ERPDoc) > 0 .And. !Empty(aI5ERPDoc[1][1])
		lI5ERPCom := Len(aI5ERPCom) > 0 .And. !Empty(aI5ERPCom[1][1])
		lI5ERPArm := Len(aI5ERPArm) > 0 .And. !Empty(aI5ERPArm[1][1])

		//Se nenhum informacoes foi carregada nos arrays, desabilita a aba de Informacoes ERP
		If lI5ERPDoc .Or. lI5ERPCom .Or. lI5ERPArm
			oBtnInfo05:Enable()

			fHowInitFo(5)

			//--- Verifica do Ultimo para o Primeiro para a atualizacao correta do folder

			//Solicitacoes ao Armazem
			If lI5ERPArm
				oI5Folder:aEnable(3,.T.)
			Else
				oI5Folder:aEnable(3,.F.)
			EndIf

			//Solicitacoes de Compra
			If lI5ERPCom
				oI5Folder:aEnable(2,.T.)
			Else
				oI5Folder:aEnable(2,.F.)
			EndIf

			//Documentos de Entrada
			If lI5ERPDoc
				oI5Folder:aEnable(1,.T.)
			Else
				oI5Folder:aEnable(1,.F.)
			EndIf
		Else
			oBtnInfo05:Disable()
		EndIf
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMNTC755MONบAutor  ณWagner S. de Lacerdaบ Data ณ  01/03/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta os campos dos Browses.                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nMonta -> Obrigatorio;                                     บฑฑ
ฑฑบ          ณ           Indica de qual os campos a serem montados.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC755MON(nMonta)

	Local aMonta := {}, aNao := {}, aCpos := {}, aVazio := {}
	Local cPrefixo := If(cTabela == "STJ","TJ_","TS_")
	Local nHeader  := If(cTabela == "STJ",1,2)
	Local nXX    := 0

	If nMonta == 10 //aChoice do MsMGet - Ordem de Servico - Gerais
		aNao := {cPrefixo+"PLANO"  , cPrefixo+"CODBEM" , cPrefixo+"NOMBEM" , cPrefixo+"PRIORID",; //Campos do 'Cabecalho' menos o Numero da Ordem
		cPrefixo+"DTPPINI", cPrefixo+"HOPPINI", cPrefixo+"DTPPFIM", cPrefixo+"HOPPFIM",; //Campos de 'Parada do Bem'
		cPrefixo+"DTPRINI", cPrefixo+"HOPRINI", cPrefixo+"DTPRFIM", cPrefixo+"HOPRFIM",; //Campos de 'Parada do Bem'
		cPrefixo+"DTULTMA",; //Campos de 'Manutencao'
		cPrefixo+"DTMPINI", cPrefixo+"HOMPINI", cPrefixo+"DTMPFIM", cPrefixo+"HOMPFIM",; //Campos de 'Manutencao'
		cPrefixo+"DTMRINI", cPrefixo+"HOMRINI", cPrefixo+"DTMRFIM", cPrefixo+"HOMRFIM",; //Campos de 'Manutencao'
		cPrefixo+"POSCONT", cPrefixo+"HORACO1", cPrefixo+"COULTMA",; //Campos de 'Contador'
		cPrefixo+"POSCON2", cPrefixo+"HORACO2", cPrefixo+"COULTM2",; //Campos de 'Contador'
		cPrefixo+"SOLICI" , cPrefixo+"QTDREP" , cPrefixo+"MOTREPR"} //Campos de 'Complementares'

		aMonta := NGCAMPNSX3(cTabela,aNao,,.F.)
		aAdd(aMonta, "NOUSER")
	ElseIf nMonta == 11 //aChoice do MsMGet - Ordem de Servico - Manutencao
		aCpos := {cPrefixo+"DTPPINI", cPrefixo+"HOPPINI", cPrefixo+"DTPPFIM", cPrefixo+"HOPPFIM",; //Campos de 'Parada do Bem'
		cPrefixo+"DTPRINI", cPrefixo+"HOPRINI", cPrefixo+"DTPRFIM", cPrefixo+"HOPRFIM",; //Campos de 'Parada do Bem'
		cPrefixo+"DTULTMA",; //Campos de 'Manutencao'
		cPrefixo+"DTMPINI", cPrefixo+"HOMPINI", cPrefixo+"DTMPFIM", cPrefixo+"HOMPFIM",; //Campos de 'Manutencao'
		cPrefixo+"DTMRINI", cPrefixo+"HOMRINI", cPrefixo+"DTMRFIM", cPrefixo+"HOMRFIM",; //Campos de 'Manutencao'
		cPrefixo+"POSCONT", cPrefixo+"HORACO1", cPrefixo+"COULTMA",; //Campos de 'Contador'
		cPrefixo+"POSCON2", cPrefixo+"HORACO2", cPrefixo+"COULTM2"} //Campos de 'Contador'
		aNao  := aClone(fCposSim(cTabela, aCpos))

		aMonta := NGCAMPNSX3(cTabela,aNao,,.F.)
		aAdd(aMonta, "NOUSER")
	ElseIf nMonta == 12 //aChoice do MsMGet - Ordem de Servico - Manutencao
		aNao := {cPrefixo+"ORDEM"  , cPrefixo+"PLANO"  , cPrefixo+"CODBEM" , cPrefixo+"NOMBEM" , cPrefixo+"PRIORID"} //Campos do 'Cabecalho'

		//Campos das Outras Abas
		For nXX := 1 To Len(aI1Gerais)
			If aI1Gerais[nXX] <> "NOUSER"
				aAdd(aNao, aI1Gerais[nXX])
			EndIf
		Next nXX
		For nXX := 1 To Len(aI1Manuten)
			If aI1Manuten[nXX] <> "NOUSER"
				aAdd(aNao, aI1Manuten[nXX])
			EndIf
		Next nXX

		aMonta := NGCAMPNSX3(cTabela,aNao)
	ElseIf nMonta == 2 //Campos do Browse de Custos
		aVazio := {}
		For nXX := 1 To Len(aI2SizCus)
			aAdd(aVazio, Space(aI2SizCus[nXX]))
		Next nXX

		aMonta := { aVazio }
	ElseIf nMonta == 30 //Campos do Browse de Insumos
		aMonta := BLANKGETD(aI3HeadIns[nHeader])
	ElseIf nMonta == 31 //Campos do Browse de Etapas
		aMonta := BLANKGETD(aI3HeadEta[nHeader])
	ElseIf nMonta == 32 //Campos do Browse de Ocorrencias
		aMonta := BLANKGETD(aI3HeadOco[nHeader])
	ElseIf nMonta == 33 //Campos do Browse de Motivos de Atraso
		aMonta := BLANKGETD(aI3HeadMot[nHeader])
	ElseIf nMonta == 34 //Campos do Browse de Problemas
		aMonta := BLANKGETD(aI3HeadPro[nHeader])
	ElseIf nMonta == 35 //Campos do Browse de Sintomas
		aMonta := BLANKGETD(aI3HeadSin)
	ElseIf nMonta == 4 //aChoice do MsMGet - Solicitacao de Servico
		aNao := {}

		aMonta := NGCAMPNSX3("TQB",aNao)
	ElseIf nMonta == 50 //Campos do Browse de Documentos de Entrada
		aVazio := {}
		For nXX := 1 To 14
			aAdd(aVazio, Space(1))
		Next nXX

		aMonta := { aVazio }
	ElseIf nMonta == 51 //Campos do Browse de Solicitacoes de Compra
		aVazio := {}
		For nXX := 1 To 12
			aAdd(aVazio, Space(1))
		Next nXX

		aMonta := { aVazio }
	ElseIf nMonta == 52 //Campos do Browse de Solicitacoes ao Armazem
		aVazio := {}
		For nXX := 1 To 10
			aAdd(aVazio, Space(1))
		Next nXX

		aMonta := { aVazio }
	EndIf

Return aMonta

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMNTC755TRBบAutor  ณWagner S. de Lacerdaบ Data ณ  11/04/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria as tabelas temporarias da Consulta de O.S.            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC755TRB()

	Local aDBF := {}, aInd := {}


	// Insumos
	dbSelectArea("STL")
	aDBF := dbStruct()
	aAdd(aDBF, {"TBLORIG", "C", 3, 0})
	aAdd(aDBF, {"T5SEQUE", "C", 3, 0})

	aInd := {"TL_FILIAL","TL_ORDEM","TL_PLANO","TL_TAREFA","TL_TIPOREG","TL_CODIGO","TL_SEQRELA","T5SEQUE","TL_SEQTARE"}

	oTmpTRBIns := FWTemporaryTable():New(cTRBIns, aDBF)
	oTmpTRBIns:AddIndex("Ind01", aInd)
	oTmpTRBIns:Create()

	// Etapas
	dbSelectArea("STQ")
	aDBF := dbStruct()
	aAdd(aDBF, {"TBLORIG", "C", 3, 0})

	//aInd := {OrdKey(1)}
	aInd := StrTokArr(AllTrim(OrdKey(1)), "+")

	oTmpTRBEta  := FWTemporaryTable():New(cTRBEta, aDBF)
	oTmpTRBEta:AddIndex("Ind01", aInd)
	oTmpTRBEta:Create()

	// Ocorrencias
	dbSelectArea("STN")
	aDBF := dbStruct()
	aAdd(aDBF, {"TBLORIG", "C", 3, 0})

	//aInd := {OrdKey(1)}
	aInd := StrTokArr(AllTrim(OrdKey(1)), "+")

	oTmpTRBOco := FWTemporaryTable():New(cTRBOco, aDBF)
	oTmpTRBOco:AddIndex("Ind01", aInd)
	oTmpTRBOco:Create()

	// Motivos de Atraso
	dbSelectArea("TPL")
	aDBF := dbStruct()
	aAdd(aDBF, {"TBLORIG", "C", 3, 0})

	//aInd := {OrdKey(1)}
	aInd := StrTokArr(AllTrim(OrdKey(1)), "+")
	aInd[4] := "TPL_DTINIC"
	aInd[6] := "TPL_DTFIM"

	oTmpTRBMot := FWTemporaryTable():New(cTRBMot, aDBF)
	oTmpTRBMot:AddIndex("Ind01", aInd)
	oTmpTRBMot:Create()


	// Problemas
	dbSelectArea("STA")
	aDBF := dbStruct()
	aAdd(aDBF, {"TBLORIG", "C", 3, 0})

	//aInd := {OrdKey(1)}
	aInd := StrTokArr(AllTrim(OrdKey(1)), "+")

	oTmpTRBPro := FWTemporaryTable():New(cTRBPro, aDBF)
	oTmpTRBPro:AddIndex("Ind01", aInd)
	oTmpTRBPro:Create()

	If lSintomas
		// Sintomas
		dbSelectArea("TTC")
		aDBF := dbStruct()
		aAdd(aDBF, {"TBLORIG", "C", 3, 0})

		//aInd := {OrdKey(1)}
		aInd := StrTokArr(AllTrim(OrdKey(1)), "+")
		oTmpTRBSin := FWTemporaryTable():New(cTRBSin, aDBF)
		oTmpTRBSin:AddIndex("Ind01", aInd)
		oTmpTRBSin:Create()
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfBlackPnl บAutor  ณWagner S. de Lacerdaบ Data ณ  04/04/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Habilita/Desabilita a tela com um Painel Preto.            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ lVisible -> Opcional;                                      บฑฑ
ฑฑบ          ณ             Define a visibilidade do Painel Preto.         บฑฑ
ฑฑบ          ณ             Default: .T. -> Visivel                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fBlackPnl(lVisible)

	Default lVisible := .T.

	If Type("oBlackPnl") <> "O"
		oBlackPnl := TPanel():New(0, 0, , oDlgCOS, , , , , SetTransparentColor(CLR_BLACK,70), nLargura, nAltura, .F., .F.)
		oBlackPnl:Hide()
	EndIf

	If lVisible
		oBlackPnl:Show()
	Else
		oBlackPnl:Hide()
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfSetUpdateบAutor  ณWagner S. de Lacerdaบ Data ณ  04/04/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Define se a tela e' atualizavel.                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ lUpdate -> Opcional;                                       บฑฑ
ฑฑบ          ณ            Define se os objetos podem ser atualizados.     บฑฑ
ฑฑบ          ณ            Default: .T. -> Permite a atualizacao           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fSetUpdate(lUpdate)

	Default lUpdate := .T.

	If !lUpdate //Desabilita a atualizacao (visual) dos controles da tela, fazendo assim com que ela nao "pisque"
		//Tela Principal
		oDlgCOS:SetUpdatesEnabled(.F.)
	Else //Habilita a atualizacao (visual) dos controles da tela, fazendo assim com que ela nao "pisque"
		//Tela Principal
		oDlgCOS:CommitControls()
		oDlgCOS:SetUpdatesEnabled(.T.)
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfLegendaOSบAutor  ณWagner S. de Lacerdaบ Data ณ  04/04/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Legenda do Status da Ordem de Servico.                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fLegendaOS()

	Local aLegenda := {}

	aAdd(aLegenda, {"BR_AZUL"    , STR0124}) //"Terminada"
	aAdd(aLegenda, {"BR_VERDE"   , STR0125}) //"Liberada / Em dia"
	aAdd(aLegenda, {"BR_AMARELO" , STR0126}) //"Liberada / Em atraso"
	aAdd(aLegenda, {"BR_LARANJA" , STR0127}) //"Liberada / Em atraso com motivo"
	aAdd(aLegenda, {"BR_CINZA"   , STR0128}) //"Pendente / Em dia"
	aAdd(aLegenda, {"BR_MARROM"  , STR0129}) //"Pendente / Em atraso"
	aAdd(aLegenda, {"BR_VERMELHO", STR0130}) //"Cancelada"
	aAdd(aLegenda, {"BR_BRANCO"  , STR0131}) //"O.S. nใo definida."

	BrwLegenda(cCadastro, STR0132, aLegenda) //"Legenda"

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfLegendaArบAutor  ณWagner S. de Lacerdaบ Data ณ  27/12/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Legenda da Arvore da Ordem de Servico.                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fLegendaAr()

	Local aLegenda  := {}
	Local nModelo   := 2
	Local aModelo   := {, , 100, 2}

	aAdd(aLegenda, {"OS"                     , STR0261}) //"Ordem de Servi็o"

	aAdd(aLegenda, {"note"                   , STR0090}) //"Tarefa"

	aAdd(aLegenda, {"ng_tree_especialidade02", STR0301+" "+STR0306}) //"Especialidade"####"(item aberto)"
	aAdd(aLegenda, {"ng_tree_especialidade01", STR0301+" "+STR0307}) //"Especialidade"####"(item fechado)"
	aAdd(aLegenda, {"ng_tree_ferramenta02"   , STR0302+" "+STR0306}) //"Ferramenta"####"(item aberto)"
	aAdd(aLegenda, {"ng_tree_ferramenta01"   , STR0302+" "+STR0307}) //"Ferramenta"####"(item fechado)"
	aAdd(aLegenda, {"ng_tree_funcionario02"  , STR0303+" "+STR0306}) //"Funcionแrio / Mใo de Obra"####"(item aberto)"
	aAdd(aLegenda, {"ng_tree_funcionario01"  , STR0303+" "+STR0307}) //"Funcionแrio / Mใo de Obra"####"(item fechado)"
	aAdd(aLegenda, {"ng_tree_produto02"      , STR0304+" "+STR0306}) //"Produto"####"(item aberto)"
	aAdd(aLegenda, {"ng_tree_produto01"      , STR0304+" "+STR0307}) //"Produto"####"(item fechado)"
	aAdd(aLegenda, {"ng_tree_terceiros02"    , STR0305+" "+STR0306}) //"Terceiro"####"(item aberto)"
	aAdd(aLegenda, {"ng_tree_terceiros01"    , STR0305+" "+STR0307}) //"Terceiro"####"(item fechado)"

	aAdd(aLegenda, {"ng_especialidade"       , STR0301}) //"Especialidade"
	aAdd(aLegenda, {"ng_ferramenta"          , STR0302}) //"Ferramenta"
	aAdd(aLegenda, {"ng_funcionario"         , STR0303}) //"Funcionแrio / Mใo de Obra"
	aAdd(aLegenda, {"ng_produto"             , STR0304}) //"Produto"
	aAdd(aLegenda, {"ng_terceiros"           , STR0305}) //"Terceiro"

	fBlackPnl() //Mostra o Painel de Transparencia

	NGLegenda(cCadastro+" - "+STR0299, STR0132, aLegenda, nModelo, aModelo) //"Legenda da มrvore"###"Legenda"

	fBlackPnl(.F.) //Esconde o Painel de Transparencia

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfEntraI2FoบAutor  ณWagner S. de Lacerdaบ Data ณ  10/06/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza as atualizacoes em tela necessarias ao entrar num  บฑฑ
ฑฑบ          ณ folder de Custos.                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fEntraI2Fo()

	If oI2Folder:nOption == 1 //Custos Previstos x Realizados
		oI2BrwCust:SetFocus()
	ElseIf oI2Folder:nOption == 2 //Grafico Previstos x Realizados
		If nI2SerieP <> 0 .And. nI2SerieR <> 0
			lI2ViuPXR  := .T.
		Else
			lI2ViuPXR  := .F.
		EndIf
	ElseIf oI2Folder:nOption == 3 //Grafico O.S. x Servico
		If nI2SerieOS <> 0 .And. nI2SerieSe <> 0
			lI2ViuOSXS := .T.
		Else
			lI2ViuOSXS := .F.
		EndIf
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfAtuI2Fo  บAutor  ณWagner S. de Lacerdaบ Data ณ  29/08/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza o Objeto do Browse.                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oObj -> Obrigatorio;                                       บฑฑ
ฑฑบ          ณ         Define o objeto para atualizar.                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fAtuI2Fo(oObj)

	CursorWait()

	oObj:CoorsUpdate()
	oObj:Refresh()

	CursorArrow()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfEntraI3FoบAutor  ณWagner S. de Lacerdaบ Data ณ  29/08/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza as atualizacoes em tela necessarias ao entrar num  บฑฑ
ฑฑบ          ณ folder de Detalhes.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fEntraI3Fo()

	If oI3Folder:nOption == 1 //Insumos Previstos e Realizados
		oI3GetInsR:oBrowse:SetFocus()
		oI3GetInsP:oBrowse:SetFocus()
	ElseIf oI3Folder:nOption == 2 //Etapas
		oI3GetEta:oBrowse:SetFocus()
	ElseIf oI3Folder:nOption == 3 //Ocorrencias
		oI3GetOco:oBrowse:SetFocus()
	ElseIf oI3Folder:nOption == 4 //Motivos de Atraso
		oI3GetMot:oBrowse:SetFocus()
	ElseIf oI3Folder:nOption == 5 //Problemas
		oI3GetPro:oBrowse:SetFocus()
	ElseIf lSintomas .And. oI3Folder:nOption == 6 //Sintomas
		oI3GetSin:oBrowse:SetFocus()
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfAtuI3Fo  บAutor  ณWagner S. de Lacerdaบ Data ณ  29/08/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza o Objeto do Browse.                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oObj -> Obrigatorio;                                       บฑฑ
ฑฑบ          ณ         Define o objeto para atualizar.                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fAtuI3Fo(oObj)

	CursorWait()

	oObj:ForceRefresh()

	CursorArrow()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfEntraI5FoบAutor  ณWagner S. de Lacerdaบ Data ณ  01/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza as atualizacoes em tela necessarias ao entrar num  บฑฑ
ฑฑบ          ณ folder de ERP.                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fEntraI5Fo()

	If oI5Folder:nOption == 1 //Documentos de Entrada
		oI5BrwDoc:SetFocus()
	ElseIf oI5Folder:nOption == 2 //Solicitacoes de Compra
		oI5BrwCom:SetFocus()
	ElseIf oI5Folder:nOption == 3 //Solicitacoes ao Armazem
		oI5BrwArm:SetFocus()
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfAtuI5Fo  บAutor  ณWagner S. de Lacerdaบ Data ณ  01/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza o Objeto do Browse.                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oObj -> Obrigatorio;                                       บฑฑ
ฑฑบ          ณ         Define o objeto para atualizar.                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fAtuI5Fo(oObj)

	CursorWait()

	oObj:CoorsUpdate()
	oObj:Refresh()

	CursorArrow()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfHowInitFoบAutor  ณWagner S. de Lacerdaบ Data ณ  10/06/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Define os folder que devem ser focados inicialmente.       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fHowInitFo(nInfo)

	Local nX

	If nInfo == 1 //Dados Cadastrais
		//deixa como esta'
	ElseIf nInfo == 2 //Custos
		For nX := 1 To Len(oI2Folder:aPrompts)
			oI2Folder:aEnable(nX, .T.)
		Next nX
	ElseIf nInfo == 3 //Detalhes da O.S.
		For nX := 1 To Len(oI3Folder:aPrompts)
			oI3Folder:aEnable(nX, .T.)
		Next nX
	ElseIf nInfo == 4 //Solicitacao de Servico
		//nao ha' folder
	ElseIf nInfo == 5 //Informacoes ERP
		For nX := 1 To Len(oI5Folder:aPrompts)
			oI5Folder:aEnable(nX, .T.)
		Next nX
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfShowHide บAutor  ณWagner S. de Lacerdaบ Data ณ  16/03/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Mostra/Esconde o Panel.                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nPanel -> Obrigatorio;                                     บฑฑ
ฑฑบ          ณ           Indica qual o panel deve ser mostrado/escondido. บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fShowHide(nPanel)

	If nPanel == 1 //Arviore
		If oGrdPnlLef:lVisible
			oGrdPnlLef:Hide()
			oGrdSplitB:LoadBitmaps("fw_arrow_right")
			oGrdSplitB:cTooltip := OemToAnsi(STR0293) //"Mostrar มrvore"
		Else
			oGrdPnlLef:Show()
			oGrdSplitB:LoadBitmaps("fw_arrow_left")
			oGrdSplitB:cTooltip := OemToAnsi(STR0290) //"Esconder มrvore"
		EndIf
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfCarTRBs  บAutor  ณWagner S. de Lacerdaบ Data ณ  11/04/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega as tabelas temporarias dos Detalhes.               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fCarTRBs()

	Local aStruct
	Local cField
	Local x, y, nPos
	Local nX
	Private cTarStl := ""
	Private cSequenc := "0"

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Insumos                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea(cTRBIns)
	ZAP

	//--- Insumos
	dbSelectArea("STL")
	dbGoTop()
	dbSetOrder(1)
	If dbSeek(xFilial("STL")+cOS+cPlano)
		ProcRegua(LastRec() - RecNo())

		While !Eof() .And. STL->TL_FILIAL + STL->TL_ORDEM + STL->TL_PLANO == xFilial("STL") + cOS + cPlano
			IncProc(STR0133) //"Carregando Arquivo de Insumos..."

			dbSelectArea(cTRBIns)
			RecLock((cTRBIns), .T.)
			For nX := 1 To FCount()
				cField := FieldName(nX)

				If cField == "TBLORIG"
					x := "'STL'"
				ElseIf cField == "T5SEQUE"
					cTarStl := STL->TL_TAREFA
					NGDBAREAORDE("STJ",1)
					If DbSeek(xFilial("STJ") + STL->TL_ORDEM + STL->TL_PLANO)
						dbSelectArea("ST5")
						dbSetorder(1)
						If dbSeek(xFilial("ST5") + STJ->TJ_CODBEM + STJ->TJ_SERVICO + STJ->TJ_SEQRELA + cTarStl)
							x := 'cValToChar(STRZERO(NGSEEK("ST5",TJ_CODBEM+TJ_SERVICO+TJ_SEQRELA+cTarStl,1,"T5_SEQUENC"),3))'
						Else
							x := 'cSequenc'
						EndIf
					EndIf
				Else
					dbSelectArea("STL")
					aStruct := dbStruct()
					nPos := aScan(aStruct, {|x| SubStr(AllTrim(x[1]),3) == SubStr(AllTrim(cField),3) })
					x := "STL->" + FieldName(nPos)
				EndIf

				dbSelectArea(cTRBIns)
				y := (cTRBIns) + "->" + cField

				&(y) := &(x)
			Next nX
			MsUnlock((cTRBIns))

			dbSelectArea("STL")
			dbSkip()
		End
	EndIf

	//--- Historico de Insumos
	dbSelectArea("STT")
	dbGoTop()
	dbSetOrder(1)
	If dbSeek(xFilial("STT")+cOS+cPlano)
		ProcRegua(LastRec() - RecNo())

		While !Eof() .And. STT->TT_FILIAL + STT->TT_ORDEM + STT->TT_PLANO == xFilial("STT") + cOS + cPlano
			IncProc(STR0133) //"Carregando Arquivo de Insumos..."

			dbSelectArea(cTRBIns)
			RecLock((cTRBIns), .T.)
			For nX := 1 To FCount()
				cField := FieldName(nX)

				If cField == "TBLORIG"
					x := "'STT'"
				ElseIf cField == "T5SEQUE"
					cTarStl := STT->TT_TAREFA
					NGDBAREAORDE("STS",1)
					If DbSeek(xFilial("STS") + STT->TT_ORDEM + STT->TT_PLANO)
						dbSelectArea("ST5")
						dbSetorder(1)
						If dbSeek(xFilial("ST5") + STT->TT_CODBEM + STT->TT_SERVICO + STT->TT_SEQRELA + cTarStl)
							x := 'cValToChar(STRZERO(NGSEEK("ST5",TT_CODBEM+TT_SERVICO+TT_SEQRELA+cTarStl,1,"T5_SEQUENC"),3))'
						Else
							x := 'cSequenc'
						EndIf
					EndIf
				Else
					dbSelectArea("STT")
					aStruct := dbStruct()
					nPos := aScan(aStruct, {|x| SubStr(AllTrim(x[1]),3) == SubStr(AllTrim(cField),3) })
					x := "STT->" + FieldName(nPos)
				EndIf

				dbSelectArea(cTRBIns)
				y := (cTRBIns) + "->" + cField

				&(y) := &(x)
			Next nX
			MsUnlock((cTRBIns))

			dbSelectArea("STT")
			dbSkip()
		End
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Etapas                       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea(cTRBEta)
	ZAP

	//--- Etapas
	dbSelectArea("STQ")
	dbGoTop()
	dbSetOrder(1)
	If dbSeek(xFilial("STQ")+cOS+cPlano)
		ProcRegua(LastRec() - RecNo())

		While !Eof() .And. STQ->TQ_FILIAL + STQ->TQ_ORDEM + STQ->TQ_PLANO == xFilial("STQ") + cOS + cPlano
			IncProc(STR0134) //"Carregando Arquivo de Etapas..."

			dbSelectArea(cTRBEta)
			RecLock((cTRBEta), .T.)
			For nX := 1 To FCount()
				cField := FieldName(nX)

				If cField == "TBLORIG"
					x := "'STQ'"
				Else
					dbSelectArea("STQ")
					aStruct := dbStruct()
					nPos := aScan(aStruct, {|x| SubStr(AllTrim(x[1]),3) == SubStr(AllTrim(cField),3) })
					x := "STQ->" + FieldName(nPos)
				EndIf

				dbSelectArea(cTRBEta)
				y := (cTRBEta) + "->" + cField

				&(y) := &(x)
			Next nX
			MsUnlock((cTRBEta))

			dbSelectArea("STQ")
			dbSkip()
		End
	EndIf

	//--- Historico de Etapas
	dbSelectArea("STX")
	dbGoTop()
	dbSetOrder(1)
	If dbSeek(xFilial("STX")+cOS+cPlano)
		ProcRegua(LastRec() - RecNo())

		While !Eof() .And. STX->TX_FILIAL + STX->TX_ORDEM + STX->TX_PLANO == xFilial("STX") + cOS + cPlano
			IncProc(STR0134) //"Carregando Arquivo de Etapas..."

			dbSelectArea(cTRBEta)
			RecLock((cTRBEta), .T.)
			For nX := 1 To FCount()
				cField := FieldName(nX)

				If cField == "TBLORIG"
					x := "'STX'"
				Else
					dbSelectArea("STX")
					aStruct := dbStruct()
					nPos := aScan(aStruct, {|x| SubStr(AllTrim(x[1]),3) == SubStr(AllTrim(cField),3) })
					x := "STX->" + FieldName(nPos)
				EndIf

				dbSelectArea(cTRBEta)
				y := (cTRBEta) + "->" + cField

				&(y) := &(x)
			Next nX
			MsUnlock((cTRBEta))

			dbSelectArea("STX")
			dbSkip()
		End
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Ocorrencias                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea(cTRBOco)
	ZAP

	//--- Ocorrencias
	dbSelectArea("STN")
	dbGoTop()
	dbSetOrder(1)
	If dbSeek(xFilial("STN")+cOS+cPlano)
		ProcRegua(LastRec() - RecNo())

		While !Eof() .And. STN->TN_FILIAL + STN->TN_ORDEM + STN->TN_PLANO == xFilial("STN") + cOS + cPlano
			IncProc(STR0135) //"Carregando Arquivo de Ocorr๊ncias..."

			dbSelectArea(cTRBOco)
			RecLock((cTRBOco), .T.)
			For nX := 1 To FCount()
				cField := FieldName(nX)

				If cField == "TBLORIG"
					x := "'STN'"
				Else
					dbSelectArea("STN")
					aStruct := dbStruct()
					nPos := aScan(aStruct, {|x| SubStr(AllTrim(x[1]),3) == SubStr(AllTrim(cField),3) })
					x := "STN->" + FieldName(nPos)
				EndIf

				dbSelectArea(cTRBOco)
				y := (cTRBOco) + "->" + cField

				&(y) := &(x)
			Next nX
			MsUnlock((cTRBOco))

			dbSelectArea("STN")
			dbSkip()
		End
	EndIf

	//--- Historico de Ocorrencias
	dbSelectArea("STU")
	dbGoTop()
	dbSetOrder(1)
	If dbSeek(xFilial("STU")+cOS+cPlano)
		ProcRegua(LastRec() - RecNo())

		While !Eof() .And. STU->TU_FILIAL + STU->TU_ORDEM + STU->TU_PLANO == xFilial("STU") + cOS + cPlano
			IncProc(STR0135) //"Carregando Arquivo de Ocorr๊ncias..."

			dbSelectArea(cTRBOco)
			RecLock((cTRBOco), .T.)
			For nX := 1 To FCount()
				cField := FieldName(nX)

				If cField == "TBLORIG"
					x := "'STU'"
				Else
					dbSelectArea("STU")
					aStruct := dbStruct()
					nPos := aScan(aStruct, {|x| SubStr(AllTrim(x[1]),3) == SubStr(AllTrim(cField),3) })
					x := "STU->" + FieldName(nPos)
				EndIf

				dbSelectArea(cTRBOco)
				y := (cTRBOco) + "->" + cField

				&(y) := &(x)
			Next nX
			MsUnlock((cTRBOco))

			dbSelectArea("STU")
			dbSkip()
		End
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Motivos de Atraso            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea(cTRBMot)
	ZAP

	//--- Motivos de Atraso
	dbSelectArea("TPL")
	dbGoTop()
	dbSetOrder(1)
	If dbSeek(xFilial("TPL")+cOS)
		ProcRegua(LastRec() - RecNo())

		While !Eof() .And. TPL->TPL_FILIAL + TPL->TPL_ORDEM == xFilial("TPL") + cOS
			IncProc(STR0136) //"Carregando Arquivo de Motivos de Atraso..."

			dbSelectArea(cTRBMot)
			RecLock((cTRBMot), .T.)
			For nX := 1 To FCount()
				cField := FieldName(nX)

				If cField == "TBLORIG"
					x := "'TPL'"
				Else
					dbSelectArea("TPL")
					aStruct := dbStruct()
					nPos := aScan(aStruct, {|x| SubStr(AllTrim(x[1]),4) == SubStr(AllTrim(cField),4) })
					x := "TPL->" + FieldName(nPos)
				EndIf

				dbSelectArea(cTRBMot)
				y := (cTRBMot) + "->" + cField

				&(y) := &(x)
			Next nX
			MsUnlock((cTRBMot))

			dbSelectArea("TPL")
			dbSkip()
		End
	EndIf

	//--- Historico de Motivos de Atraso
	dbSelectArea("TQ6")
	dbGoTop()
	dbSetOrder(1)
	If dbSeek(xFilial("TQ6")+cOS+cPlano)
		ProcRegua(LastRec() - RecNo())

		While !Eof() .And. TQ6->TQ6_FILIAL + TQ6->TQ6_ORDEM == xFilial("TQ6") + cOS
			IncProc(STR0136) //"Carregando Arquivo de Motivos de Atraso..."

			dbSelectArea(cTRBMot)
			RecLock((cTRBMot), .T.)
			For nX := 1 To FCount()
				cField := FieldName(nX)

				If cField == "TBLORIG"
					x := "'TQ6'"
				Else
					dbSelectArea("TQ6")
					aStruct := dbStruct()
					nPos := aScan(aStruct, {|x| SubStr(AllTrim(x[1]),4) == SubStr(AllTrim(cField),4) })
					x := "TQ6->" + FieldName(nPos)
				EndIf

				dbSelectArea(cTRBMot)
				y := (cTRBMot) + "->" + cField

				&(y) := &(x)
			Next nX
			MsUnlock((cTRBMot))

			dbSelectArea("TQ6")
			dbSkip()
		End
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Problemas                    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea(cTRBPro)
	ZAP

	//--- Problemas
	dbSelectArea("STA")
	dbGoTop()
	dbSetOrder(1)
	If dbSeek(xFilial("STA")+cOS+cPlano)
		ProcRegua(LastRec() - RecNo())

		While !Eof() .And. STA->TA_FILIAL + STA->TA_ORDEM + STA->TA_PLANO == xFilial("STA") + cOS + cPlano
			IncProc(STR0137) //"Carregando Arquivo de Problemas..."

			dbSelectArea(cTRBPro)
			RecLock((cTRBPro), .T.)
			For nX := 1 To FCount()
				cField := FieldName(nX)

				If cField == "TBLORIG"
					x := "'STA'"
				Else
					dbSelectArea("STA")
					aStruct := dbStruct()
					nPos := aScan(aStruct, {|x| SubStr(AllTrim(x[1]),3) == SubStr(AllTrim(cField),3) })
					x := "STA->" + FieldName(nPos)
				EndIf

				dbSelectArea(cTRBPro)
				y := (cTRBPro) + "->" + cField

				&(y) := &(x)
			Next nX
			MsUnlock((cTRBPro))

			dbSelectArea("STA")
			dbSkip()
		End
	EndIf

	//--- Historico de Problemas
	dbSelectArea("STV")
	dbGoTop()
	dbSetOrder(1)
	If dbSeek(xFilial("STV")+cOS+cPlano)
		ProcRegua(LastRec() - RecNo())

		While !Eof() .And. STV->TV_FILIAL + STV->TV_ORDEM + STV->TV_PLANO == xFilial("STV") + cOS + cPlano
			IncProc(STR0137) //"Carregando Arquivo de Problemas..."

			dbSelectArea(cTRBPro)
			RecLock((cTRBPro), .T.)
			For nX := 1 To FCount()
				cField := FieldName(nX)

				If cField == "TBLORIG"
					x := "'STV'"
				Else
					dbSelectArea("STV")
					aStruct := dbStruct()
					nPos := aScan(aStruct, {|x| SubStr(AllTrim(x[1]),3) == SubStr(AllTrim(cField),3) })
					x := "STV->" + FieldName(nPos)
				EndIf

				dbSelectArea(cTRBPro)
				y := (cTRBPro) + "->" + cField

				&(y) := &(x)
			Next nX
			MsUnlock((cTRBPro))

			dbSelectArea("STV")
			dbSkip()
		End
	EndIf

	If lSintomas
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Sintomas                     ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		dbSelectArea(cTRBSin)
		ZAP

		//--- Sintomas
		dbSelectArea("TTC")
		dbGoTop()
		dbSetOrder(1)
		If dbSeek(xFilial("TTC")+cOS+cPlano)
			ProcRegua(LastRec() - RecNo())

			While !Eof() .And. TTC->TTC_FILIAL + TTC->TTC_ORDEM + TTC->TTC_PLANO == xFilial("TTC") + cOS + cPlano
				IncProc(STR0138) //"Carregando Arquivo de Sintomas..."

				dbSelectArea(cTRBSin)
				RecLock((cTRBSin), .T.)
				For nX := 1 To FCount()
					cField := FieldName(nX)

					If cField == "TBLORIG"
						x := "'TTC'"
					Else
						dbSelectArea("TTC")
						aStruct := dbStruct()
						nPos := aScan(aStruct, {|x| SubStr(AllTrim(x[1]),4) == SubStr(AllTrim(cField),4) })
						x := "TTC->" + FieldName(nPos)
					EndIf

					dbSelectArea(cTRBSin)
					y := (cTRBSin) + "->" + cField

					&(y) := &(x)
				Next nX
				MsUnlock((cTRBSin))

				dbSelectArea("TTC")
				dbSkip()
			End
		EndIf

		//--- Nao Ha Historico de Sintomas
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfI2CarCustบAutor  ณWagner S. de Lacerdaบ Data ณ  07/03/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega o array de Custos da Ordem de Servico consultada.  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ lVerTarefa -> Opcional;                                    บฑฑ
ฑฑบ          ณ               Define a aglutinacao/ou nao das tarefas.     บฑฑ
ฑฑบ          ณ                .T. -> Separa por tarefa.                   บฑฑ
ฑฑบ          ณ                .F. -> Aglutina as tarefas.                 บฑฑ
ฑฑบ          ณ               Default: variavel 'lI2CarTar'                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fI2CarCust(lVerTarefa)

	Local aAreaTRB := {}
	Local cAuxFiltro, cNomeTar
	Local lPrev
	Local nXX, nPos, nPrev, nReal, nPerc

	Default lVerTarefa := lI2CarTar

	If lVerTarefa
		oI2BtnTar:LoadBitmaps("ng_ico_tarefas02")
		oI2BtnTar:cTooltip := OemToAnsi(STR0044) //"Aglutinar Tarefas"
		lI2CarTar := .F.
	Else
		oI2BtnTar:LoadBitmaps("ng_ico_tarefas")
		oI2BtnTar:cTooltip := OemToAnsi(STR0139) //"Considerar Tarefas"
		lI2CarTar := .T.
	EndIf

	aI2Custos := {}

	//A O.S. a calcular e' a que esta' sendo consultada
	cAuxFiltro := cOS + cPlano //Ordem de Servico + Plano

	//Carrega os Insumos Previstos e Realizados
	dbSelectArea((cTRBIns))
	dbSetOrder(1)
	dbSeek(xFilial("STL")+cAuxFiltro,.T.)
	ProcRegua(LastRec() - RecNo())
	While !Eof() .And. (cTRBIns)->TL_FILIAL == xFilial("STL") .And. (cTRBIns)->TL_ORDEM + (cTRBIns)->TL_PLANO == cAuxFiltro
		IncProc(STR0140) //"Carregando Custos..."

		lPrev := (Alltrim((cTRBIns)->TL_SEQRELA) == "0")

		If lVerTarefa
			nPos := aScan(aI2Custos, {|x| x[1]+x[10]+x[4] == (cTRBIns)->TL_TAREFA+(cTRBIns)->TL_TIPOREG+(cTRBIns)->TL_CODIGO })
		Else
			nPos := aScan(aI2Custos, {|x| x[10]+x[4] == (cTRBIns)->TL_TIPOREG+(cTRBIns)->TL_CODIGO })
		EndIf

		cNomeTar := fNomeTar((cTRBIns)->TL_TAREFA)

		aEspFunc := {.F., ""}
		If (cTRBIns)->TL_TIPOREG == "M" .And. !lPrev //Se o insumo for Mao de Obra e for Realizado
			dbSelectArea((cTRBIns))
			aAreaTRB := GetArea()
			//Verifica se esta relacionado a uma Especialidade
			aEspFunc := aClone( fVerFunEsp((cTRBIns)->TL_CODIGO) )
			RestArea(aAreaTRB)
		EndIf

		If nPos == 0
			aAdd(aI2Custos, {If(lVerTarefa, (cTRBIns)->TL_TAREFA, "*"),; //Codigo da Tarefa
			If(lVerTarefa, cNomeTar, STR0141),; //Nome da Tarefa //"TODAS"
			TIPREGBRW((cTRBIns)->TL_TIPOREG),; //Tipo de Insumo
			(cTRBIns)->TL_CODIGO,; //Codigo do Insumo
			NOMINSBRW((cTRBIns)->TL_TIPOREG, (cTRBIns)->TL_CODIGO),; //Nome do Insumo
			If(lPrev, (cTRBIns)->TL_CUSTO, 0),; //Custo Previsto
			If(!lPrev, (cTRBIns)->TL_CUSTO, 0),; //Custo Real
			0,; //Diferenca entre o Custo Previsto e o Realizado
			0,; //Percentual de Variacaeo entre o Custo Previsto e o Realizado
			(cTRBIns)->TL_TIPOREG,; //Codigo do Tipo de Insumo
			If(aEspFunc[1], aEspFunc[2], "") }) //Especialidade relacionada
		Else
			If lPrev
				aI2Custos[nPos][6] += (cTRBIns)->TL_CUSTO
			Else
				aI2Custos[nPos][7] += (cTRBIns)->TL_CUSTO
			EndIf
		EndIf

		dbSelectArea((cTRBIns))
		dbSkip()
	End

	If Len(aI2Custos) > 0
		//Relaciona a Mao de Obra com a Especialidade
		For nXX := 1 To Len(aI2Custos)
			nPos := 0

			If aI2Custos[nXX][10] == "E" //Especialidade
				If lVerTarefa
					nPos := aScan(aI2Custos, {|x| x[1]+x[10]+AllTrim(x[11]) == aI2Custos[nXX][1]+"M"+AllTrim(aI2Custos[nXX][4]) })
				Else
					nPos := aScan(aI2Custos, {|x| x[10]+AllTrim(x[11]) == "M"+AllTrim(aI2Custos[nXX][4]) })
				EndIf

				If nPos > 0
					aI2Custos[nPos][6] += aI2Custos[nXX][6]
				EndIf
			ElseIf aI2Custos[nXX][10] == "M" //Mao de Obra
				If lVerTarefa
					nPos := aScan(aI2Custos, {|x| x[1]+x[10]+AllTrim(x[4]) == aI2Custos[nXX][1]+"E"+AllTrim(aI2Custos[nXX][11]) })
				Else
					nPos := aScan(aI2Custos, {|x| x[10]+AllTrim(x[4]) == "E"+AllTrim(aI2Custos[nXX][11]) })
				EndIf

				If nPos > 0
					aI2Custos[nPos][7] += aI2Custos[nXX][7]
				EndIf
			EndIf
		Next nXX

		//Calcula o Percentual de Diferenca
		For nXX := 1 To Len(aI2Custos)
			nPrev := aI2Custos[nXX][6]
			nReal := aI2Custos[nXX][7]

			If nPrev > 0
				If nReal > 0
					nPerc := ((nReal * 100) / nPrev)
				Else
					nPerc := -100
				EndIf
			Else
				nPerc := 0
			EndIf

			aI2Custos[nXX][8] := nPrev - nReal
			aI2Custos[nXX][9] := Round(nPerc,2)
		Next nXX
	EndIf

	If Len(aI2Custos) == 0
		aI2Custos := aClone(MNTC755MON(2))
	EndIf

	oI2BrwCust:SetArray(aI2Custos)
	oI2BrwCust:GoTop()
	oI2BrwCust:Refresh()

	lI2TarClik := !lVerTarefa //Recebe a situacao atual do clique no botao de Separar/Aglutinar tarefas

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfI2CarPXR บAutor  ณWagner S. de Lacerdaบ Data ณ  13/04/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega o grafico de Insumos Previstos x Realizados da O.S.บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fI2CarPXR()

	Local aAreaTRB := {}
	Local nPos  := 0, nXX := 0
	Local lCria := .F.

	aI2DadosP := {}
	aI2DadosR := {}

	//Define os Tipos de Insumo
	aAdd(aI2DadosP, {"F",0})
	aAdd(aI2DadosP, {"M",0})
	aAdd(aI2DadosP, {"P",0})
	aAdd(aI2DadosP, {"T",0})
	aAdd(aI2DadosP, {"E",0})

	aAdd(aI2DadosR, {"F",0})
	aAdd(aI2DadosR, {"M",0})
	aAdd(aI2DadosR, {"P",0})
	aAdd(aI2DadosR, {"T",0})
	aAdd(aI2DadosR, {"E",0})

	//--- Busca os Insumos da O.S.
	dbSelectArea(cTRBIns)
	dbSetOrder(1)
	dbGoTop()
	ProcRegua(LastRec() - RecNo())

	While !Eof()
		IncProc(STR0142) //"Definidos dados de Previstos x Realizados..."

		If AllTrim((cTRBIns)->TL_SEQRELA) == "0"
			nPos := aScan(aI2DadosP, {|x| x[1] == (cTRBIns)->TL_TIPOREG })
			If nPos > 0
				aI2DadosP[nPos][2] += (cTRBIns)->TL_CUSTO
			EndIf
		Else
			nPos := aScan(aI2DadosR, {|x| x[1] == (cTRBIns)->TL_TIPOREG })
			If nPos > 0
				aI2DadosR[nPos][2] += (cTRBIns)->TL_CUSTO
			EndIf
		EndIf

		dbSelectArea(cTRBIns)
		dbSkip()
	End

	If nI2SerieP <> 0
		oI2GrfPXR:DelSerie(nI2SerieP)
	EndIf
	If nI2SerieR <> 0
		oI2GrfPXR:DelSerie(nI2SerieR)
	EndIf

	//Verifica se ha custos para criar o grafico
	For nXX := 1 To Len(aI2DadosP)
		If aI2DadosP[nXX][2] > 0
			lCria := .T.
		EndIf
	Next nXX

	If !lCria
		For nXX := 1 To Len(aI2DadosR)
			If aI2DadosR[nXX][2] > 0
				lCria := .T.
			EndIf
		Next nXX
	EndIf

	If lCria
		//Serie dos Custos da O.S. Consultada
		nI2SerieP := oI2GrfPXR:CreateSerie(GRP_BAR, STR0143, 2) //"Previstos"
		oI2GrfPXR:Add(nI2SerieP, aI2DadosP[1][2], Capital(TIPREGBRW(aI2DadosP[1][1])), CLR_HGREEN)
		oI2GrfPXR:Add(nI2SerieP, aI2DadosP[2][2], Capital(TIPREGBRW(aI2DadosP[2][1])), CLR_HGREEN)
		oI2GrfPXR:Add(nI2SerieP, aI2DadosP[3][2], Capital(TIPREGBRW(aI2DadosP[3][1])), CLR_HGREEN)
		oI2GrfPXR:Add(nI2SerieP, aI2DadosP[4][2], Capital(TIPREGBRW(aI2DadosP[4][1])), CLR_HGREEN)
		oI2GrfPXR:Add(nI2SerieP, aI2DadosP[5][2], Capital(TIPREGBRW(aI2DadosP[5][1])), CLR_HGREEN)

		//Serie dos Custos do Servico
		nI2SerieR := oI2GrfPXR:CreateSerie(GRP_BAR, STR0144, 2) //"Realizados"
		oI2GrfPXR:Add(nI2SerieR, aI2DadosR[1][2], Capital(TIPREGBRW(aI2DadosR[1][1])), CLR_HBLUE)
		oI2GrfPXR:Add(nI2SerieR, aI2DadosR[2][2], Capital(TIPREGBRW(aI2DadosR[2][1])), CLR_HBLUE)
		oI2GrfPXR:Add(nI2SerieR, aI2DadosR[3][2], Capital(TIPREGBRW(aI2DadosR[3][1])), CLR_HBLUE)
		oI2GrfPXR:Add(nI2SerieR, aI2DadosR[4][2], Capital(TIPREGBRW(aI2DadosR[4][1])), CLR_HBLUE)
		oI2GrfPXR:Add(nI2SerieR, aI2DadosR[5][2], Capital(TIPREGBRW(aI2DadosR[5][1])), CLR_HBLUE)
	Else
		nI2SerieP := 0
		nI2SerieR := 0
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfI2CarOSXSบAutor  ณWagner S. de Lacerdaบ Data ณ  10/03/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega o grafico de Ordem de Servico x Hist๓rico.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fI2CarOSXS()

	Local nPos       := 0
	local nXX        := 0
	Local nQtdeOSs   := 0 // Quantidade de Ordens de Servico
	Local lCria      := .F.
	Local cTabSTJ    := GetNextAlias()
	Local cTabSTS    := GetNextAlias()
	Local cLocalOs   := "", cLocalPlan := ""
	Local cWhereSTS  := '%'
	Local cWhereSTJ  := '%'
	Local aAreaSTJ   := STJ->(GetArea())

	aI2DadosOS := {}
	aI2DadosSe := {}

	//Define os Tipos de Insumo
	aAdd(aI2DadosOS, {"F",0})
	aAdd(aI2DadosOS, {"M",0})
	aAdd(aI2DadosOS, {"P",0})
	aAdd(aI2DadosOS, {"T",0})
	aAdd(aI2DadosOS, {"E",0})

	aAdd(aI2DadosSe, {"F",0})
	aAdd(aI2DadosSe, {"M",0})
	aAdd(aI2DadosSe, {"P",0})
	aAdd(aI2DadosSe, {"T",0})
	aAdd(aI2DadosSe, {"E",0})

	nQtdeOSs := 0

	//--- Busca as Ordens de Servico (Nao pode ser com o arquivo temporario pois deve considerar todos os registros)
	dbSelectArea("STJ")
	dbSetOrder(4)
	dbSeek(xFilial("STJ")+cServico)
	ProcRegua(LastRec() - RecNo())

	// Verifica se a data inicio da O.S. esta preenchida
	If !Empty( dI2ParDtDe )
		cWhereSTJ += ' AND STL.TL_DTINICI >= ' + ValToSql( dToS( dI2ParDtDe ) )
	EndIf

	// Verfica se a data fim esta preenchida
	If !Empty( dI2ParDtAt )
		cWhereSTJ += ' AND STL.TL_DTINICI <= ' + ValToSql( dToS( dI2ParDtAt ) )
	EndIf

	cWhereSTJ += '%'

	BeginSQL Alias cTabSTJ

		SELECT
			TL_ORDEM  ,
			TL_PLANO  ,
			TL_TIPOREG,
			TL_CUSTO
		FROM
			%table:STL% STL
		JOIN
			%table:STJ% STJ ON
				STL.TL_FILIAL = STJ.TJ_FILIAL AND
				STL.TL_ORDEM  = STJ.TJ_ORDEM  AND
				STL.TL_PLANO  = STJ.TJ_PLANO
		WHERE
			STJ.TJ_SERVICO = %exp:cServico% AND
			STJ.TJ_SITUACA <> 'C' AND STJ.%NotDel% AND
			( STJ.TJ_ORDEM <> %exp:cOS% OR
			  STJ.TJ_PLANO <> %exp:cPlano% ) AND
			STL.TL_SEQRELA <> '0  ' AND STL.%NotDel%
			%exp:cWhereSTJ%
	EndSQL

	Do While (cTabSTJ)->( !EoF() )

		IncProc(STR0145) //"Definidos dados da O.S. x Hist๓rico..."

		nPos := aScan(aI2DadosSe, {|x| x[1] == (cTabSTJ)->TL_TIPOREG })
		If nPos > 0
			aI2DadosSe[nPos][2] += (cTabSTJ)->TL_CUSTO
		EndIf

		If !Empty(cLocalOs) .And. !Empty(cLocalPlan)
			cLocalOs := (cTabSTJ)->TL_ORDEM
			cLocalPlan :=  (cTabSTJ)->TL_PLANO
			nQtdeOSs++
		ElseIf cLocalOs <> (cTabSTJ)->TL_ORDEM .And. cLocalPlan <> (cTabSTJ)->TL_PLANO
			cLocalOs := (cTabSTJ)->TL_ORDEM
			cLocalPlan :=  (cTabSTJ)->TL_PLANO
			nQtdeOSs++
		EndIf

		dbSelectArea(cTabSTJ)
		dbSkip()

	EndDo

	(cTabSTJ)->(DbCloseArea())

	//Bsuca apenas da S.S. selecionada
	cTabSTJ := GetNextAlias()

	BeginSQL Alias cTabSTJ

		SELECT
			TL_TIPOREG,
			TL_CUSTO
		FROM
			%table:STL% STL
		JOIN
			%table:STJ% STJ ON
				STL.TL_FILIAL = STJ.TJ_FILIAL AND
				STL.TL_ORDEM  = STJ.TJ_ORDEM  AND
				STL.TL_PLANO  = STJ.TJ_PLANO
		WHERE
			STJ.TJ_SERVICO = %exp:cServico% AND
			STJ.TJ_ORDEM   = %exp:cOS%      AND
			STJ.TJ_PLANO   = %exp:cPlano%   AND
			STL.TL_SEQRELA <> '0  '         AND
			STJ.TJ_SITUACA <> 'C'           AND
			STL.%NotDel% AND STJ.%NotDel%

	EndSQL

	Do While (cTabSTJ)->( !EoF() )

		nPos := aScan(aI2DadosOS, {|x| x[1] == (cTabSTJ)->TL_TIPOREG })
		If nPos > 0
			aI2DadosOS[nPos][2] += (cTabSTJ)->TL_CUSTO
		EndIf

		dbSelectArea(cTabSTJ)
		dbSkip()

	EndDo

	(cTabSTJ)->(DbCloseArea())

	// Verifica se a Data Inicio da O.S. esta preenchida
	If !Empty( dI2ParDtDe )
		cWhereSTS += 'AND STT.TT_DTINICI >= ' + ValToSql( dToS( dI2ParDtDe ) )
	EndIf

	// Verfica se a Data Fim esta preenchida
	If !Empty( dI2ParDtAt )
		cWhereSTS += 'AND STT.TT_DTINICI <= ' + ValToSql( dToS( dI2ParDtAt ) )
	EndIf

	cWhereSTS += '%'

	// Busca as Ordens de Servico do Historico (Nao pode ser com o arquivo temporario pois deve considerar todos os registros)
	BeginSQL Alias cTabSTS

		SELECT
			STT.TT_ORDEM  ,
		 	STT.TT_PLANO  ,
			STT.TT_TIPOREG,
			STT.TT_CUSTO
		FROM
			%table:STT% STT
		JOIN
			%table:STS% STS ON
				STT.TT_FILIAL = STS.TS_FILIAL AND
				STT.TT_ORDEM  = STS.TS_ORDEM  AND
				STT.TT_PLANO  = STS.TS_PLANO
		WHERE
			STS.TS_SERVICO = %exp:cServico% AND
			( STS.TS_ORDEM <> %exp:cOS% OR
			  STS.TS_PLANO <> %exp:cPlano% ) AND
			STT.TT_SEQRELA <> '0  ' AND STT.%NotDel% AND
			STS.TS_SITUACA <> 'C'   AND STS.%NotDel%

	EndSQL

	Do While (cTabSTS)->( !EoF() )

		IncProc(STR0145) //"Definidos dados da O.S. x Hist๓rico..."

		nPos := aScan(aI2DadosSe, {|x| x[1] == (cTabSTS)->TT_TIPOREG })
		If nPos > 0
			aI2DadosSe[nPos][2] += (cTabSTS)->TT_CUSTO
		EndIf

		If !Empty(cLocalOs) .And. !Empty(cLocalPlan)

			cLocalOs   := (cTabSTS)->TT_ORDEM
			cLocalPlan := (cTabSTS)->TT_PLANO
			nQtdeOSs++

		ElseIf cLocalOs != (cTabSTS)->TT_ORDEM .And. cLocalPlan != (cTabSTS)->TT_PLANO

			cLocalOs   := (cTabSTS)->TT_ORDEM
			cLocalPlan := (cTabSTS)->TT_PLANO
			nQtdeOSs++

		EndIf

		dbSelectArea(cTabSTS)
		dbSkip()
	End

	(cTabSTS)->(DbCloseArea())

	// Busca apenas da S.S. selecionada
	cTabSTS := GetNextAlias()

	BeginSQL Alias cTabSTS

		SELECT
			STT.TT_CUSTO  ,
			STT.TT_TIPOREG
		FROM
			%table:STT% STT
		JOIN
			%table:STS% STS ON
				STT.TT_FILIAL = STS.TS_FILIAL AND
				STT.TT_ORDEM  = STS.TS_ORDEM  AND
				STT.TT_PLANO  = STS.TS_PLANO
		WHERE
			STS.TS_SERVICO = %exp:cServico% AND
			( STS.TS_ORDEM = %exp:cOS% AND
			  STS.TS_PLANO = %exp:cPlano% ) AND
			STS.TS_SITUACA <> 'C' AND STS.%NotDel% AND
			STT.TT_SEQRELA <> '0  ' AND STT.%NotDel%

	EndSQL

	While (cTabSTS)->( !EoF() )

		nPos := aScan(aI2DadosOS, {|x| x[1] == STT->TT_TIPOREG })
		If nPos > 0
			aI2DadosOS[nPos][2] += STT->TT_CUSTO
		EndIf

		dbSelectArea(cTabSTS)
		dbSkip()

	End

	(cTabSTS)->(DbCloseArea())

	If nI2SerieOS <> 0
		oI2GrfOSXS:DelSerie(nI2SerieOS)
	EndIf
	If nI2SerieSe <> 0
		oI2GrfOSXS:DelSerie(nI2SerieSe)
	EndIf

	//Verifica se ha custos para criar o grafico
	For nXX := 1 To Len(aI2DadosOS)
		If aI2DadosOS[nXX][2] > 0
			lCria := .T.
		EndIf
	Next nXX

	For nXX := 1 To Len(aI2DadosSe)
		If aI2DadosSe[nXX][2] > 0
			aI2DadosSe[nXX][2] := (aI2DadosSe[nXX][2] / nQtdeOSs) //Media do Custo pela Quantidade de O.S.'s para o Servico
			lCria := .T.
		EndIf
	Next nXX

	If lCria
		//Serie dos Custos do Servico
		nI2SerieSe := oI2GrfOSXS:CreateSerie(GRP_BAR, STR0032, 2) //"Servi็o"
		oI2GrfOSXS:Add(nI2SerieSe, aI2DadosSe[1][2], Capital(TIPREGBRW(aI2DadosSe[1][1])), CLR_YELLOW)
		oI2GrfOSXS:Add(nI2SerieSe, aI2DadosSe[2][2], Capital(TIPREGBRW(aI2DadosSe[2][1])), CLR_YELLOW)
		oI2GrfOSXS:Add(nI2SerieSe, aI2DadosSe[3][2], Capital(TIPREGBRW(aI2DadosSe[3][1])), CLR_YELLOW)
		oI2GrfOSXS:Add(nI2SerieSe, aI2DadosSe[4][2], Capital(TIPREGBRW(aI2DadosSe[4][1])), CLR_YELLOW)
		oI2GrfOSXS:Add(nI2SerieSe, aI2DadosSe[5][2], Capital(TIPREGBRW(aI2DadosSe[5][1])), CLR_YELLOW)

		//Serie dos Custos da O.S. Consultada
		nI2SerieOS := oI2GrfOSXS:CreateSerie(GRP_BAR, STR0023, 2) //"O.S."
		oI2GrfOSXS:Add(nI2SerieOS, aI2DadosOS[1][2], Capital(TIPREGBRW(aI2DadosOS[1][1])), CLR_HBLUE)
		oI2GrfOSXS:Add(nI2SerieOS, aI2DadosOS[2][2], Capital(TIPREGBRW(aI2DadosOS[2][1])), CLR_HBLUE)
		oI2GrfOSXS:Add(nI2SerieOS, aI2DadosOS[3][2], Capital(TIPREGBRW(aI2DadosOS[3][1])), CLR_HBLUE)
		oI2GrfOSXS:Add(nI2SerieOS, aI2DadosOS[4][2], Capital(TIPREGBRW(aI2DadosOS[4][1])), CLR_HBLUE)
		oI2GrfOSXS:Add(nI2SerieOS, aI2DadosOS[5][2], Capital(TIPREGBRW(aI2DadosOS[5][1])), CLR_HBLUE)

		oI2GrfOSXS:Show()
		oI2DadOSXS:Hide()
	Else
		nI2SerieOS := 0
		nI2SerieSe := 0

		oI2GrfOSXS:Hide()
		oI2DadOSXS:Show()
	EndIf

	RestArea(aAreaSTJ)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfI2ParOSXSบAutor  ณWagner S. de Lacerdaบ Data ณ  18/04/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Mostra a tela de definicao dos Parametros do Grafico de    บฑฑ
ฑฑบ          ณ O.S. x Hist๓rico.                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fI2ParOSXS()

	Local oDlgParOSXS
	Local oLeft
	Local oBtnSair
	Local oMid
	Local lOK

	Local nMonths, nYears

	Private oCbx, aItens, cItem
	Private oGetDtIni, dDtDe, oGetDtFim, dDtAte

	aItens := {STR0146, STR0147, STR0148, STR0149, STR0150} //"Bimestral"###"Trimestral"###"Semestral"###"Anual"###"Outro"
	If Empty(cI2ParItem)
		cItem  := STR0148 //"Semestral"
	Else
		cItem := cI2ParItem
	EndIf

	If Empty(dI2ParDtDe)
		dDtDe := CTOD("  /  /    ")
	Else
		dDtDe := dI2ParDtDe
	EndIf

	If Empty(dI2ParDtDe)
		dDtAte := CTOD("  /  /    ")
	Else
		dDtAte := dI2ParDtAt
	EndIf

	lOK := .F.
	DEFINE MSDIALOG oDlgParOSXS TITLE OemToAnsi(STR0045) COLOR CLR_BLACK, CLR_WHITE FROM 0,0 TO 150,300 OF oMainWnd PIXEL //"Grแfico de O.S. x Hist๓rico"

	oDlgParOSXS:lEscClose := .F.

	//--- Panel Left
	oLeft := TPanel():New(01, 01, , oDlgParOSXS, , , , CLR_WHITE, nCorBack, 12, 50)
	oLeft:Align := CONTROL_ALIGN_LEFT

	oBtnSair := TBtnBmp2():New(01, 01, 27, 30, "ng_ico_final", , , , {|| oDlgParOSXS:End()}, oLeft, OemToAnsi(STR0151)) //"Sair"
	oBtnSair:Align := CONTROL_ALIGN_TOP

	//--- Panel Mid
	oMid := TPanel():New(01, 01, , oDlgParOSXS, , , , CLR_BLACK, CLR_WHITE, 50, 40)
	oMid:Align := CONTROL_ALIGN_ALLCLIENT

	@ 005,010 SAY OemToAnsi(STR0152) COLOR CLR_BLACK OF oMid PIXEL //"Perํodo:"
	@ 004,040 COMBOBOX oCbx VAR cItem ITEMS aItens ON CHANGE fI2VldOSXS(1) SIZE 60,08 WHEN .T. OF oMid PIXEL
	oCbx:bHelp := {|| ShowHelpCpo(STR0153,; //"Periodo"
	{STR0154},2,; //"Perํodo para a busca do Hist๓rico de Servi็o."
	{},2)}

	@ 020,010 SAY OemToAnsi(STR0155) COLOR CLR_BLACK OF oMid PIXEL //"De Data:"
	@ 019,040 MSGET oGetDtIni VAR dDtDe PICTURE "99/99/9999" SIZE 60,08 VALID fI2VldOSXS(2) OF oMid PIXEL HASBUTTON
	oGetDtIni:bHelp := {|| ShowHelpCpo(STR0156,; //"Data Inicial"
	{STR0157},2,; //"Define a Data inicial a ser considerada no Hist๓rico."
	{},2)}

	@ 035,010 SAY OemToAnsi(STR0158) COLOR CLR_BLACK OF oMid PIXEL //"At้ Data:"
	@ 034,040 MSGET oGetDtFim VAR dDtAte PICTURE "99/99/9999" SIZE 60,08 VALID fI2VldOSXS(3) OF oMid PIXEL HASBUTTON
	oGetDtFim:bHelp := {|| ShowHelpCpo(STR0159,; //"Data Final"
	{STR0160},2,; //"Define a Data Final a ser considerada no Hist๓rico."
	{},2)}

	SButton():New(060, 010, 1, {|| lOK := .T., If(fI2VldOSXS(4), oDlgParOSXS:End(), lOK := .F.)}, oMid, .T.)

	If oCbx:nAT == 5
		oGetDtIni:Enable()
		oGetDtFim:Enable()
	Else
		oGetDtIni:Disable()
		oGetDtFim:Disable()
	EndIf

	ACTIVATE MSDIALOG oDlgParOSXS CENTERED

	If lOK
		cI2ParItem := cItem
		dI2ParDtDe := dDtDe
		dI2ParDtAt := dDtAte
	Else
		If Empty(dI2ParDtDe)
			If MsgYesNo(STR0161,STR0089) //"Deseja considerar todo o hist๓rico?"###"Aten็ใo"
				dI2ParDtDe := CTOD("  /  /    ")
				dI2ParDtAt := CTOD("  /  /    ")
			EndIf
		EndIf
	EndIf

	Processa({|| fI2CarOSXS()}, STR0107) //"Processando Grแfico da O.S. x Hist๓rico..."

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfI2VldOSXSบAutor  ณWagner S. de Lacerdaบ Data ณ  18/04/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida a tela de definicao dos Parametros do Grafico de    บฑฑ
ฑฑบ          ณ O.S. x Hist๓rico.                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nGet ------> Obrigatorio;                                  บฑฑ
ฑฑบ          ณ              Define o tipo de validacao.                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fI2VldOSXS(nGet)

	If nGet == 1
		If oCbx:nAT == 5
			oGetDtIni:Enable()
			oGetDtFim:Enable()

			dDtDe  := CTOD("  /  /    ")
			dDtAte := CTOD("  /  /    ")
		Else
			dDtDe  := dCOSDtIni
			dDtAte := dCOSDtIni

			If oCbx:nAT == 1
				dDtDe := dDtDe - (2 * 30)
			ElseIf oCbx:nAT == 2
				dDtDe := dDtDe - (3 * 30)
			ElseIf oCbx:nAT == 3
				dDtDe := dDtDe - (6 * 30)
			ElseIf oCbx:nAT == 4
				dDtDe := dDtDe - (12 * 30)
			EndIf

			oGetDtIni:Disable()
			oGetDtFim:Disable()
		EndIf

		oGetDtIni:CtrlRefresh()
		oGetDtFim:CtrlRefresh()
	ElseIf nGet == 2
		If !Empty(dDtAte) .And. dDtDe > dDtAte
			ShowHelpDlg(STR0162,; //"Data Invแlida."
			{STR0163},2,; //"A data informada ้ invแlida."
			{STR0164},2) //"Insira uma data 'De' menor que a data 'At้'."
			Return .F.
		EndIf
	ElseIf nGet == 3
		If dDtAte < dDtDe
			ShowHelpDlg(STR0162,; //"Data Invแlida."
			{STR0163},2,; //"A data informada ้ invแlida."
			{STR0165},2) //"Insira uma data 'At้' maior que a data 'De'."
			Return .F.
		EndIf
	ElseIf nGet == 4
		If !fI2VldOSXS(2,.T.)
			Return .F.
		EndIf
		If !fI2VldOSXS(3,.T.)
			Return .F.
		EndIf

		If Empty(dDtDe) .And. Empty(dDtAte)
			If !MsgYesNo(STR0161,STR0089) //"Deseja considerar todo o hist๓rico?"###"Aten็ใo"
				Return .F.
			EndIf
		EndIf
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfI3CarDet บAutor  ณWagner S. de Lacerdaบ Data ณ  30/03/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega os detalhes da O.S.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fI3CarDet()

	Local aAuxCols := {}
	Local cTblAux  := ""
	Local cPrefix  := ""
	Local cSeqRela := ""
	Local cNomTar  := ""
	Local cNomEta  := ""
	Local nX       := 0
	Local nHead    := 0

	Local nTLSEQRELA := aScan(aI3HeadIns[1], {|x| AllTrim(x[2]) == "TL_SEQRELA" })
	Local nTLTIPOREG := aScan(aI3HeadIns[1], {|x| AllTrim(x[2]) == "TL_TIPOREG" })
	Local nTLTAREFA  := aScan(aI3HeadIns[1], {|x| AllTrim(x[2]) == "TL_TAREFA" })
	Local nTLNOMTAR  := aScan(aI3HeadIns[1], {|x| AllTrim(x[2]) == "TL_NOMTAR" })
	Local nTQOK      := aScan(aI3HeadEta[1], {|x| AllTrim(x[2]) == "TQ_OK" })
	Local nTQTAREFA  := aScan(aI3HeadEta[1], {|x| AllTrim(x[2]) == "TQ_TAREFA" })
	Local nTQNOMTARE := aScan(aI3HeadEta[1], {|x| AllTrim(x[2]) == "TQ_NOMTARE" })
	Local nTQETAPA   := aScan(aI3HeadEta[1], {|x| AllTrim(x[2]) == "TQ_ETAPA" })
	Local nTQSEQETA  := aScan(aI3HeadEta[1], {|x| AllTrim(x[2]) == "TQ_SEQETA" })
	Local nTNTAREFA  := aScan(aI3HeadOco[1], {|x| AllTrim(x[2]) == "TN_TAREFA" })
	Local nTNNOMETAR := aScan(aI3HeadOco[1], {|x| AllTrim(x[2]) == "TN_NOMETAR" })
	Local nTNCODOCOR := aScan(aI3HeadOco[1], {|x| AllTrim(x[2]) == "TN_CODOCOR" })
	Local nTPLCODMOT := aScan(aI3HeadMot[1], {|x| AllTrim(x[2]) == "TPL_CODMOT" })
	Local nTPLDTINIC := aScan(aI3HeadMot[1], {|x| AllTrim(x[2]) == "TPL_DTINIC" })
	Local nTPLHOINIC := aScan(aI3HeadMot[1], {|x| AllTrim(x[2]) == "TPL_HOINIC" })
	Local nTATAREFA  := aScan(aI3HeadPro[1], {|x| AllTrim(x[2]) == "TA_TAREFA" })
	Local nTANOMTAR  := aScan(aI3HeadPro[1], {|x| AllTrim(x[2]) == "TA_NOMTAR" })
	Local nTATIPOREG := aScan(aI3HeadPro[1], {|x| AllTrim(x[2]) == "TA_TIPOREG" })
	Local nTACODIGO  := aScan(aI3HeadPro[1], {|x| AllTrim(x[2]) == "TA_CODIGO" })
	Local nTTCDATA   := 0
	Local nTTCCDSINT := 0

	aI3DetInsP := {}
	aI3DetInsR := {}
	aI3DetEta  := {}
	aI3DetOco  := {}
	aI3DetMot  := {}
	aI3DetPro  := {}
	If lSintomas
		aI3DetSin  := {}
		nTTCDATA   := aScan(aI3HeadSin, {|x| AllTrim(x[2]) == "TTC_DATA" })
		nTTCCDSINT := aScan(aI3HeadSin, {|x| AllTrim(x[2]) == "TTC_CDSINT" })
	EndIf

	nHead := If(cTabela == "STJ", 1, 2)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Insumos                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cTblAux := If(cTabela == "STJ", "STL", "STT")
	cPrefix := cTblAux + "->" + SubStr(cTblAux,2) + "_"

	If cTabela <> "STJ"
		nTLSEQRELA := aScan(aI3HeadIns[2], {|x| AllTrim(x[2]) == "TT_SEQRELA" })
		nTLTIPOREG := aScan(aI3HeadIns[2], {|x| AllTrim(x[2]) == "TT_TIPOREG" })
		nTLTAREFA  := aScan(aI3HeadIns[2], {|x| AllTrim(x[2]) == "TT_TAREFA" })
		nTLNOMTAR  := aScan(aI3HeadIns[2], {|x| AllTrim(x[2]) == "TT_NOMTAR" })
		nTQOK      := aScan(aI3HeadEta[2], {|x| AllTrim(x[2]) == "TX_OK" })
		nTQTAREFA  := aScan(aI3HeadEta[2], {|x| AllTrim(x[2]) == "TX_TAREFA" })
		nTQNOMTARE := aScan(aI3HeadEta[2], {|x| AllTrim(x[2]) == "TX_NOMTARE" })
		nTQETAPA   := aScan(aI3HeadEta[2], {|x| AllTrim(x[2]) == "TX_ETAPA" })
		nTNTAREFA  := aScan(aI3HeadOco[2], {|x| AllTrim(x[2]) == "TU_TAREFA" })
		nTNNOMETAR := aScan(aI3HeadOco[2], {|x| AllTrim(x[2]) == "TU_NOMETAR" })
		nTNCODOCOR := aScan(aI3HeadOco[2], {|x| AllTrim(x[2]) == "TU_CODOCOR" })
		nTPLCODMOT := aScan(aI3HeadMot[2], {|x| AllTrim(x[2]) == "TQ6_CODMOT" })
		nTPLDTINIC := aScan(aI3HeadMot[2], {|x| AllTrim(x[2]) == "TQ6_DTINIC" })
		nTPLHOINIC := aScan(aI3HeadMot[2], {|x| AllTrim(x[2]) == "TQ6_HOINIC" })
		nTATAREFA  := aScan(aI3HeadPro[2], {|x| AllTrim(x[2]) == "TV_TAREFA" })
		nTANOMTAR  := aScan(aI3HeadPro[2], {|x| AllTrim(x[2]) == "TV_NOMTAR" })
		nTATIPOREG := aScan(aI3HeadPro[2], {|x| AllTrim(x[2]) == "TV_TIPOREG" })
		nTACODIGO  := aScan(aI3HeadPro[2], {|x| AllTrim(x[2]) == "TV_CODIGO" })
		//TTC nao tem historico
	EndIf

	dbSelectArea(cTblAux)
	dbSetOrder(1)
	PutFileInEof(cTblAux)
	RegToMemory(cTblAux,.F.)
	aAuxCols := MAKEGETD(cTblAux, cOS + cPlano, aI3HeadIns[nHead],;
	cPrefix+"FILIAL + "+cPrefix+"ORDEM + "+cPrefix+"PLANO == xFilial('"+cTblAux+"') + cOS + cPlano", , .F.)

	For nX := 1 To Len(aAuxCols)
		If nTLNOMTAR > 0
			If Empty(aAuxCols[nX][nTLNOMTAR])
				aAuxCols[nX][nTLNOMTAR] := fNomeTar(aAuxCols[nX][nTLTAREFA])
			EndIf
		EndIf

		If nTLSEQRELA > 0
			If AllTrim(aAuxCols[nX][nTLSEQRELA]) == "0"
				aAdd(aI3DetInsP, aAuxCols[nX])
			Else
				aAdd(aI3DetInsR, aAuxCols[nX])
			EndIf
		EndIf
	Next nX

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Etapas                       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cTblAux := If(cTabela == "STJ", "STQ", "STX")
	cPrefix := cTblAux + "->" + SubStr(cTblAux,2) + "_"

	dbSelectArea(cTblAux)
	dbSetOrder(1)
	PutFileInEof(cTblAux)
	RegToMemory(cTblAux,.F.)
	aI3DetEta := MAKEGETD(cTblAux, cOS + cPlano, aI3HeadEta[nHead],;
	cPrefix+"FILIAL + "+cPrefix+"ORDEM + "+cPrefix+"PLANO == xFilial('"+cTblAux+"') + cOS + cPlano", , .F.)

	For nX := 1 To Len(aI3DetEta)
		If nTQNOMTARE > 0
			If Empty(aI3DetEta[nX][nTQNOMTARE])
				aI3DetEta[nX][nTQNOMTARE] := fNomeTar(aI3DetEta[nX][nTQTAREFA])
			EndIf
		EndIf

		If nTQOK > 0
			If !Empty(aI3DetEta[nX][nTQOK])
				aI3DetEta[nX][nTQOK] := "X"
			EndIf
		EndIf
	Next nX

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Ocorrencias                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cTblAux := If(cTabela == "STJ", "STN", "STU")
	cPrefix := cTblAux + "->" + SubStr(cTblAux,2) + "_"

	dbSelectArea(cTblAux)
	dbSetOrder(1)
	PutFileInEof(cTblAux)
	RegToMemory(cTblAux,.F.)
	aI3DetOco := MAKEGETD(cTblAux, cOS + cPlano, aI3HeadOco[nHead],;
	cPrefix+"FILIAL + "+cPrefix+"ORDEM + "+cPrefix+"PLANO == xFilial('"+cTblAux+"') + cOS + cPlano", , .F.)

	For nX := 1 To Len(aI3DetOco)
		If nTNNOMETAR > 0
			If Empty(aI3DetOco[nX][nTNNOMETAR])
				aI3DetOco[nX][nTNNOMETAR] := fNomeTar(aI3DetOco[nX][nTNTAREFA])
			EndIf
		EndIf
	Next nX

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Motivos de Atraso            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cTblAux := If(cTabela == "STJ", "TPL", "TQ6")
	cPrefix := cTblAux + "->" + cTblAux + "_"

	dbSelectArea(cTblAux)
	dbSetOrder(1)
	PutFileInEof(cTblAux)
	RegToMemory(cTblAux,.F.)
	aI3DetMot := MAKEGETD(cTblAux, cOS, aI3HeadMot[nHead],;
	cPrefix+"FILIAL + "+cPrefix+"ORDEM == xFilial('"+cTblAux+"') + cOS", , .F.)


	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Problemas                    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cTblAux := If(cTabela == "STJ", "STA", "STV")
	cPrefix := cTblAux + "->" + SubStr(cTblAux,2) + "_"

	dbSelectArea(cTblAux)
	dbSetOrder(1)
	PutFileInEof(cTblAux)
	RegToMemory(cTblAux,.F.)
	aI3DetPro := MAKEGETD(cTblAux, cOS + cPlano, aI3HeadPro[nHead],;
	cPrefix+"FILIAL + "+cPrefix+"ORDEM + "+cPrefix+"PLANO == xFilial('"+cTblAux+"') + cOS + cPlano", , .F.)

	For nX := 1 To Len(aI3DetPro)
		If nTANOMTAR > 0
			If Empty(aI3DetPro[nX][nTANOMTAR])
				aI3DetPro[nX][nTANOMTAR] := fNomeTar(aI3DetPro[nX][nTATAREFA])
			EndIf
		EndIf
	Next nX

	If lSintomas
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Sintomas                     ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cTblAux := "TTC"
		cPrefix := cTblAux + "->" + cTblAux + "_"

		dbSelectArea(cTblAux)
		dbSetOrder(1)
		PutFileInEof(cTblAux)
		RegToMemory(cTblAux,.F.)
		aI3DetSin := MAKEGETD(cTblAux, cOS + cPlano, aI3HeadSin,;
		cPrefix+"FILIAL + "+cPrefix+"ORDEM + "+cPrefix+"PLANO == xFilial('"+cTblAux+"') + cOS + cPlano", , .F.)
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Finalizando Detalhes         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//--- Finaliza os Arrays
	If Len(aI3DetInsP) > 0
		If nTLTAREFA > 0 .And. nTLSEQRELA > 0
			aSort(aI3DetInsP, , , {|x,y| x[nTLTAREFA]+PADL(AllTrim(x[nTLSEQRELA]),3,"0") < y[nTLTAREFA]+PADL(AllTrim(y[nTLSEQRELA]),3,"0") })
		EndIf
	Else
		aI3DetInsP := aClone(MNTC755MON(30))
	EndIf
	If Len(aI3DetInsR) > 0
		If nTLTAREFA > 0 .And. nTLSEQRELA > 0
			aSort(aI3DetInsR, , , {|x,y| x[nTLTAREFA]+PADL(AllTrim(x[nTLSEQRELA]),3,"0") < y[nTLTAREFA]+PADL(AllTrim(y[nTLSEQRELA]),3,"0") })
		EndIf
	Else
		aI3DetInsR := aClone(MNTC755MON(30))
	EndIf

	If Len(aI3DetEta) > 0
		If nTQTAREFA > 0 .And. nTQETAPA > 0
			If nTQSEQETA > 0 //Ordena pela sequ๊ncia da etapa
				aSort(aI3DetEta, , , {|x,y| x[nTQTAREFA]+x[nTQSEQETA] < y[nTQTAREFA]+y[nTQSEQETA] })
			Else
				aSort(aI3DetEta, , , {|x,y| x[nTQTAREFA]+x[nTQETAPA] < y[nTQTAREFA]+y[nTQETAPA] })
			EndIf
		EndIf
	Else
		aI3DetEta := aClone(MNTC755MON(31))
	EndIf

	If Len(aI3DetOco) > 0
		If nTNTAREFA > 0 .And. nTNCODOCOR > 0
			aSort(aI3DetOco, , , {|x,y| x[nTNTAREFA]+x[nTNCODOCOR] < y[nTNTAREFA]+y[nTNCODOCOR] })
		EndIf
	Else
		aI3DetOco := aClone(MNTC755MON(32))
	EndIf

	If Len(aI3DetMot) > 0
		If nTPLCODMOT > 0 .And. nTPLDTINIC > 0 .And. nTPLHOINIC > 0
			aSort(aI3DetMot, , , {|x,y| x[nTPLCODMOT]+DTOC(x[nTPLDTINIC])+x[nTPLHOINIC] < y[nTPLCODMOT]+DTOC(y[nTPLDTINIC])+y[nTPLHOINIC] })
		EndIf
	Else
		aI3DetMot := aClone(MNTC755MON(33))
	EndIf

	If Len(aI3DetPro) > 0
		If nTATAREFA > 0 .And. nTATIPOREG > 0 .And. nTACODIGO > 0
			aSort(aI3DetPro, , , {|x,y| x[nTATAREFA]+x[nTATIPOREG]+x[nTACODIGO] < y[nTATAREFA]+y[nTATIPOREG]+y[nTACODIGO] })
		EndIf
	Else
		aI3DetPro := aClone(MNTC755MON(34))
	EndIf

	If lSintomas
		If Len(aI3DetSin) > 0
			If nTTCDATA > 0 .And. nTTCCDSINT > 0
				aSort(aI3DetSin, , , {|x,y| DTOC(x[nTTCDATA])+x[nTTCCDSINT] < DTOC(y[nTTCDATA])+y[nTTCCDSINT] })
			EndIf
		Else
			aI3DetSin := aClone(MNTC755MON(35))
		EndIf
	EndIf

	oI3GetInsP:SetArray(aI3DetInsP)
	If Len(aI3DetInsP) > 0 .And. !Empty(aI3DetInsP[1][1])
		oI3GetInsP:GoTop()
	EndIf
	oI3GetInsP:Refresh()

	oI3GetInsR:SetArray(aI3DetInsR)
	If Len(aI3DetInsR) > 0 .And. !Empty(aI3DetInsR[1][1])
		oI3GetInsR:GoTop()
	EndIf
	oI3GetInsR:Refresh()

	oI3GetEta:SetArray(aI3DetEta)
	If Len(aI3DetEta) > 0 .And. !Empty(aI3DetEta[1][1])
		oI3GetEta:GoTop()
	EndIf
	oI3GetEta:Refresh()

	oI3GetOco:SetArray(aI3DetOco)
	If Len(aI3DetOco) > 0 .And. !Empty(aI3DetOco[1][1])
		oI3GetOco:GoTop()
	EndIf
	oI3GetOco:Refresh()

	oI3GetMot:SetArray(aI3DetMot)
	If Len(aI3DetMot) > 0 .And. !Empty(aI3DetMot[1][1])
		oI3GetMot:GoTop()
	EndIf
	oI3GetMot:Refresh()

	oI3GetPro:SetArray(aI3DetPro)
	If Len(aI3DetPro) > 0 .And. !Empty(aI3DetPro[1][1])
		oI3GetPro:GoTop()
	EndIf
	oI3GetPro:Refresh()

	If lSintomas
		oI3GetSin:SetArray(aI3DetSin)
		If Len(aI3DetSin) > 0 .And. !Empty(aI3DetSin[1][1])
			oI3GetSin:GoTop()
		EndIf
		oI3GetSin:Refresh()
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fI3VisEta()
Visualiza a etapa selecionada.
@type static

@author	Wagner S. de Lacerda
@since	04/04/2011

@sample fI3VisEta()

@return	.T.
/*/
//---------------------------------------------------------------------
Static Function fI3VisEta()

	Local aEtapa     := {}
	Local aHeadEta   := {}
	Local aSizeEta   := {}
	Local bLineEta   := {|| }
	Local cTipo      := ''
	Local cCondOp    := ''
	Local cCampo     := ''
	Local cCondIn    := ''
	Local cFormul    := ''
	Local oDlgVisEta := Nil
	Local oLeft      := Nil
	Local oBtnSair   := Nil
	Local oMid       := Nil
	Local oTop       := Nil
	Local oAll       := Nil
	Local oBrwOpcoes := Nil
	Local nPos       := 0
	Local nWidth     := 0
	Local nHeight    := 0
	Local nLinha     := oI3GetEta:nAT
	Local nTQTAREFA  := aScan( aI3HeadEta[1], {|x| AllTrim( x[2] ) == 'TQ_TAREFA'  } )
	Local nTQNOMTARE := aScan( aI3HeadEta[1], {|x| AllTrim( x[2] ) == 'TQ_NOMTARE' } )
	Local nTQETAPA   := aScan( aI3HeadEta[1], {|x| AllTrim( x[2] ) == 'TQ_ETAPA'   } )
	Local nSeqEtapa  := aScan( aI3HeadEta[1], {|x| AllTrim( x[2] ) == 'TQ_SEQETA'  } )
	Local nCodFunc   := aScan( aI3HeadEta[1], {|x| AllTrim( x[2] ) == 'TQ_CODFUNC' } )
	Local nPosOk     := aScan( aI3HeadEta[1], {|x| AllTrim( x[2] ) == 'TQ_OK'      } )

	If cTabela <> 'STJ'
		nTQTAREFA  := aScan( aI3HeadEta[2], {|x| AllTrim( x[2] ) == 'TX_TAREFA'  } )
		nTQNOMTARE := aScan( aI3HeadEta[2], {|x| AllTrim( x[2] ) == 'TX_NOMTARE' } )
		nTQETAPA   := aScan( aI3HeadEta[2], {|x| AllTrim( x[2] ) == 'TX_ETAPA'   } )
		nSeqEtapa  := aScan( aI3HeadEta[2], {|x| AllTrim( x[2] ) == 'TX_SEQETA'  } )
		nCodFunc   := aScan( aI3HeadEta[2], {|x| AllTrim( x[2] ) == 'TX_CODFUNC' } )
		nPosOk     := aScan( aI3HeadEta[1], {|x| AllTrim( x[2] ) == 'TX_OK'      } )
	EndIf

	aImpEta := {}

	//Busca a Etapa
	dbSelectArea("TPA")
	dbSetOrder(1)
	If dbSeek(xFilial("TPA")+aI3DetEta[nLinha][nTQETAPA])

		//Busca as Opcoes da Etapa
		dbSelectArea("TPC")
		dbSetOrder(1)
		If dbSeek(xFilial("TPC")+aI3DetEta[nLinha][nTQETAPA])
			While !Eof() .And. TPC->TPC_FILIAL == xFilial("TPC") .And. TPC->TPC_ETAPA == aI3DetEta[nLinha][nTQETAPA]
				cTipo   := IIf( TPC->TPC_TIPRES == '2', STR0166, STR0167 ) //"Informar"###"Marcar"
				cCampo  := AllTrim(NGRetSX3Box("TPC_TIPCAM",AllTrim(TPC->TPC_TIPCAM)))
				cFormul := AllTrim( TPC->TPC_FORMUL )

				aAdd( aEtapa, {  TPC->TPC_OPCAO, cTipo, cCampo, cFormul, " " })

				dbSelectArea("TPC")
				dbSkip()
			EndDo
		EndIf
	EndIf

	If Len(aEtapa) > 0

		//Busca as resposta da Etapa
		dbSelectArea("TPQ")
		dbSetOrder(1)
		If dbSeek(xFilial("TPQ")+cOS+cPlano+aI3DetEta[nLinha][nTQTAREFA]+aI3DetEta[nLinha][nTQETAPA])
			While !Eof() .And. TPQ->TPQ_FILIAL == xFilial("TPQ") .And. TPQ->TPQ_TAREFA + TPQ->TPQ_ETAPA == aI3DetEta[nLinha][nTQTAREFA] + aI3DetEta[nLinha][nTQETAPA]
				nPos   := aScan(aEtapa, {|x| x[1] == TPQ->TPQ_OPCAO })

				If nPos > 0
					aEtapa[nPos][5] := IIf( Empty( TPQ->TPQ_RESPOS ), "X", AllTrim( TPQ->TPQ_RESPOS ) )
				EndIf

				dbSelectArea("TPQ")
				dbSkip()
			EndDo
		EndIf

		aHeadEta := { STR0168, STR0169, STR0170, STR0312, STR0173 } //"Op็ใo" ## "Tipo" ## "Campo" ## "F๓rmula" ## "Resposta"
		aSizeEta := { 40, 30, 30, 60, 50 }
		bLineEta := {|| { PadR( aEtapa[oBrwOpcoes:nAt,01], 40," "),;
		PadR( aEtapa[oBrwOpcoes:nAt,02], 30, " "),;
		PadR( aEtapa[oBrwOpcoes:nAt,03], 30, " "),;
		PadR( aEtapa[oBrwOpcoes:nAt,04], 80, " "),;
		PadR( aEtapa[oBrwOpcoes:nAt,05], 40, " ") }}

		aSort(aEtapa, , , {|x,y| x[1]+x[2] < y[1]+y[2]})
	EndIf

	//Define altura e largura do objeto dialog
	If Len(aEtapa) > 0
		nWidth  := 855
		nHeight := 380
	Else
		nWidth  := 570
		nHeight := 210
	EndIf

	DEFINE MSDIALOG oDlgVisEta TITLE OemToAnsi(STR0174) COLOR CLR_BLACK, CLR_WHITE FROM 0,0 TO nHeight,nWidth OF oMainWnd PIXEL //"Detalhes da Etapa"

	oDlgVisEta:lEscClose := .T.

	//--- Panel Left
	oLeft := TPanel():New(01, 01, , oDlgVisEta, , , , CLR_WHITE, nCorBack, 12, 50)
	oLeft:Align := CONTROL_ALIGN_LEFT

	oBtnSair := TBtnBmp2():New(01, 01, 27, 30, "ng_ico_final", , , , {|| oDlgVisEta:End()}, oLeft, OemToAnsi(STR0151)) //"Sair"
	oBtnSair:Align := CONTROL_ALIGN_TOP

	//--- Panel Mid
	oMid := TPanel():New(01, 01, , oDlgVisEta, , , , CLR_BLACK, CLR_WHITE, 50, 40)
	oMid:Align := CONTROL_ALIGN_ALLCLIENT

	//--- Panel Top
	oTop := TPanel():New(01, 01, , oMid, , , , CLR_BLACK, CLR_WHITE, 100, 100)
	oTop:Align := CONTROL_ALIGN_TOP

	@ 005,010 SAY OemToAnsi(STR0175) COLOR CLR_BLACK OF oTop PIXEL //"Tarefa:"
	TGet():New(004, 045, {|| aI3DetEta[nLinha][nTQTAREFA]}, oTop, 040, 008, "@!", , CLR_BLACK, , ,;
	.F., , .T., , .F., {|| .F. }, .F., .F. , , .F., , "")
	TGet():New(004, 090, {|| aI3DetEta[nLinha][nTQNOMTARE]}, oTop, 175, 008, "@!", , CLR_BLACK, , ,;
	.F., , .T., , .F., {|| .F. }, .F., .F., , .F., .F., , "")

	@ 020,010 SAY OemToAnsi(STR0176) COLOR CLR_BLACK OF oTop PIXEL //"Etapa:"
	TGet():New(019, 045, {|| aI3DetEta[nLinha][nTQETAPA]}, oTop, 040, 008, "@!", , CLR_BLACK, , ,;
	.F., , .T., , .F., {|| .F. }, .F., .F., , .F., .F., , "")
	TGet():New(019, 090, {|| aI3DetEta[nLinha][4]}, oTop, 175, 008, "@!", , CLR_BLACK, , ,;
	.F., , .T., , .F., {|| .F. }, .F., .F., , .F., .F., , "")

	@ 035,010 SAY OemToAnsi(STR0313) COLOR CLR_BLACK OF oTop PIXEL //"Executante:
	TGet():New( 035, 045, {|| aI3DetEta[nLinha][nCodFunc]}, oTop, 040, 008, '@!',, CLR_BLACK,,,.F.,, .T.,, .F., {||.F.}, .F., .F.,, .F., .F.,, '' )
	TGet():New( 035, 090, {|| NgSeek( 'ST1', aI3DetEta[nLinha][nCodFunc], 1, 'T1_NOME' )}, oTop, 175, 008, '@!', , CLR_BLACK,,, .F.,, .T.,, .F., {||.F.}, .F., .F.,, .F., .F.,, '' )

	@ 050,010 SAY OemToAnsi(STR0314) COLOR CLR_BLACK OF oTop PIXEL //Sequencia:
	TGet():New( 050, 045, {|| aI3DetEta[nLinha][nSeqEtapa]}, oTop, 040, 008, '@!',, CLR_BLACK,,, .F.,, .T.,, .F., {||.F.}, .F., .F.,, .F., .F.,, '' )

	//--- Apenas informa se a etapa foi realizada ou nao
	@ 050,090 SAY OemToAnsi(STR0177) COLOR CLR_BLACK OF oTop PIXEL //"Realizada:"
	If Empty(aI3DetEta[nLinha][nPosOk])
		@ 050,120 SAY OemToAnsi(STR0178) COLOR CLR_HRED OF oTop PIXEL //"Nใo"
	Else
		@ 050,120 SAY OemToAnsi(STR0179) COLOR CLR_GREEN OF oTop PIXEL //"Sim"
	EndIf

	@ 065,010 SAY OemToAnsi(STR0315) COLOR CLR_BLACK OF oTop PIXEL //Observa็ใo:
	@ 065,045 GET oObs VAR aI3DetEta[nLinha][nTQETAPA] OF oTop MEMO SIZE 219,30 PIXEL WHEN .F.

	//--- Panel All
	oAll := TPanel():New(01, 01, , oMid, , , , CLR_BLACK, CLR_WHITE, 100, 40)
	oAll:Align := CONTROL_ALIGN_ALLCLIENT

	//Browse da Opcoes da Etapa
	If Len(aEtapa) > 0
		oBrwOpcoes := TWBrowse():New( 005, 010, 400, 080,, aHeadEta, aSizeEta, oAll,,,,, {|| },,,,,,, .F.,, .T.,, .F.,, .T., .F. )
		oBrwOpcoes:SetArray(aEtapa)
		oBrwOpcoes:bLine := bLineEta
		oBrwOpcoes:Align := CONTROL_ALIGN_ALLCLIENT
	EndIf

	ACTIVATE MSDIALOG oDlgVisEta CENTERED

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfI5CarERP บAutor  ณWagner S. de Lacerdaบ Data ณ  04/04/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega as Informacoes do ERP (integracoes com outros      บฑฑ
ฑฑบ          ณ modulos).                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T. -> Dados carregados.                                   บฑฑ
ฑฑบ          ณ .F. -> Ambiente nao est' integrado ao estoque.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fI5CarERP()

	Local aProds := {}
	Local cOP    := ""
	Local nPos   := 0, nX := 0
	Local cAlsSCP := ''

	aI5ERPDoc := {}
	aI5ERPCom := {}
	aI5ERPArm := {}

	If cTabela <> "STJ" .Or. !lUsaIntERP //Usa Integracao com ERP?
		aI5ERPDoc := aClone(MNTC755MON(50))
		aI5ERPCom := aClone(MNTC755MON(51))
		aI5ERPArm := aClone(MNTC755MON(52))
		Return .F.
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Documento de Entrada        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//Recebe todos os Produtos dos insumos da O.S.
	dbSelectArea((cTRBIns))
	dbSetOrder(1)
	If dbSeek(xFilial("STL")+cOS+cPlano)
		ProcRegua(LastRec() - RecNo())

		While !Eof() .And. (cTRBIns)->TL_FILIAL + (cTRBIns)->TL_ORDEM + (cTRBIns)->TL_PLANO == xFilial("STL") + cOS + cPlano
			IncProc(STR0180) //"Carregando ERP - Produtos..."

			If AllTrim((cTRBIns)->TL_TIPOREG) == "P"
				nPos := aScan(aProds, {|x| AllTrim(x[1]) == AllTrim((cTRBIns)->TL_CODIGO) })

				If nPos == 0
					aAdd(aProds, {(cTRBIns)->TL_CODIGO, (cTRBIns)->TL_NUMSC, (cTRBIns)->TL_NUMOP,;
					If(NGCADICBASE("TL_NOTFIS","A","STL",.F.),(cTRBIns)->TL_NOTFIS, " "),;
					If(NGCADICBASE("TL_SERIE" ,"A","STL",.F.),(cTRBIns)->TL_SERIE , " "),;
					If(NGCADICBASE("TL_DOC"   ,"A","STL",.F.),(cTRBIns)->TL_DOC   , " "),;
					If(NGCADICBASE("TL_NUMSA" ,"A","STL",.F.),(cTRBIns)->TL_NUMSA , " ")} )

				EndIf
			EndIf

			dbSelectArea((cTRBIns))
			dbSkip()
		End
	EndIf

	If lUsaIntEst //Usa Integracao com Estoque?
		//Verifica se existe SC2 (Ordem de Producao)
		dbSelectArea("SC2")
		dbSetOrder(9)
		If dbSeek(xFilial("SC2")+cOS)
			cOP := SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN
		EndIf
	ElseIf lUsaIntCom //Usa Integracao com Compras?
		//Verifica se existe SC1 (Solicitacao de Compra) com a Ordem de Producao correspondente a O.S.
		dbSelectArea("SC1")
		dbSetOrder(4)
		If dbSeek(xFilial("SC1")+cOS+"OS001")
			cOP := cOS+"OS001"
		EndIf
	EndIf

	//Se houver Ordem de Producao para a O.S. Consultada busca o Documento de Entrada pela Ordem de Producao
	If !Empty(cOP)
		dbSelectArea("SD1")
		dbSetOrder(9)
		If dbSeek(xFilial("SD1")+cOS)
			ProcRegua(LastRec() - RecNo())

			While !Eof() .And. SD1->D1_FILIAL == xFilial("SD1") .And. SD1->D1_ORDEM == cOS
				IncProc(STR0181) //"Carregando ERP - Documentos de Entrada..."

				aAdd(aI5ERPDoc, {SD1->D1_DOC, SD1->D1_ITEM,;
				SD1->D1_COD, AllTrim(NOMINSBRW("P",SD1->D1_COD)),;
				SD1->D1_UM , SD1->D1_QUANT, SD1->D1_TOTAL,;
				cOS        , RecNo(),;
				SD1->D1_SERIE, SD1->D1_FORNECE, SD1->D1_LOJA, SD1->D1_TIPO,; //Chave -> junto com o D1_DOC
				SD1->D1_EMISSAO })

				dbSelectArea("SD1")
				dbSkip()
			End
		EndIf

		//Se existir algum Produto nos isumos da O.S. busca o Documento relacionado
		If Len(aProds) > 0
			ProcRegua(Len(aProds))

			For nX := 1 To Len(aProds)
				IncProc(STR0181) //"Carregando ERP - Documentos de Entrada..."

				cAliasQry := GetNextAlias()

				cQuery := "SELECT * "
				cQuery += " FROM " + RetSqlName("SD1")
				cQuery += " WHERE D1_ORDEM = '"+cOS+"' AND D1_FILIAL = " + ValToSql(xFilial('SD1')) + "  AND "
				cQuery += " D1_COD = " + ValToSql( aProds[nX][1] ) + " AND D_E_L_E_T_ = ''"


				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

				dbSelectArea(cAliasQry)
				dbGoTop()
				While !Eof()

					If (cAliasQry)->D1_COD == aProds[nX][1]

						nPos := aScan(aI5ERPDoc, {|x| AllTrim(x[1])+x[10] == AllTrim((cAliasQry)->D1_DOC)+(cAliasQry)->D1_SERIE })

						If nPos == 0
							aAdd( aI5ERPDoc,{	(cAliasQry)->D1_DOC, (cAliasQry)->D1_ITEM,(cAliasQry)->D1_COD, AllTrim(NOMINSBRW("P",(cAliasQry)->D1_COD)),;
							(cAliasQry)->D1_UM , (cAliasQry)->D1_QUANT, (cAliasQry)->D1_TOTAL,cOS,;
							(cAliasQry)->R_E_C_N_O_,(cAliasQry)->D1_SERIE,;
							(cAliasQry)->D1_FORNECE, (cAliasQry)->D1_LOJA, (cAliasQry)->D1_TIPO,StoD((cAliasQry)->D1_EMISSAO) })
						EndIf

					EndIf
					dbSelectArea( cAliasQry )
					DbSkip()
				End While
				(cAliasQry)->(DbCloseArea())
			Next nX
		EndIf

	EndIf


	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Solicitacao de Compras      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//Se houver Ordem de Producao e estiver integrado ao 'Compras', busca as Solicitacoes de Compra pela Ordem de Producao
	If !Empty(cOP) .And. lUsaIntCom //Usa Integracao com Compras?
		dbSelectArea("SC1")
		dbSetOrder(4)
		If dbSeek(xFilial("SC1")+cOP)
			ProcRegua(LastRec() - RecNo())

			While !Eof() .And. SC1->C1_FILIAL == xFilial("SC1") .And. AllTrim(SC1->C1_OP) == AllTrim(cOP)
				IncProc(STR0182) //"Carregando ERP - Solicita็๕es de Compra..."

				aAdd(aI5ERPCom, {SC1->C1_NUM, SC1->C1_ITEM,;
				SC1->C1_PRODUTO, AllTrim(NOMINSBRW("P",SC1->C1_PRODUTO)),;
				SC1->C1_QUANT  , SC1->C1_UM     , SC1->C1_EMISSAO,;
				SC1->C1_PEDIDO , SC1->C1_DATPRF ,;
				SC1->C1_SOLICIT, cOS            , RecNo() })

				dbSelectArea("SC1")
				dbSkip()
			End
		EndIf
	EndIf

	//Se existir algum Produto nos isumos da O.S. e estiver integrado ao 'Compras', busca a S.C. relacionada
	If Len(aProds) > 0 .And. lUsaIntCom //Usa Integracao com Compras?
		ProcRegua(Len(aProds))

		For nX := 1 To Len(aProds)
			IncProc(STR0182) //"Carregando ERP - Solicita็๕es de Compra..."

			dbSelectArea("SC1")
			dbSetOrder(1)
			If dbSeek(xFilial("SC1")+aProds[nX][2])
				nPos := aScan(aI5ERPCom, {|x| AllTrim(x[3]) == AllTrim(SC1->C1_PRODUTO) .And. x[9] == SC1->C1_DATPRF })

				If nPos == 0
					aAdd(aI5ERPCom, {SC1->C1_NUM, SC1->C1_ITEM,;
					SC1->C1_PRODUTO, AllTrim(NOMINSBRW("P",SC1->C1_PRODUTO)),;
					SC1->C1_QUANT  , SC1->C1_UM     , SC1->C1_EMISSAO,;
					SC1->C1_PEDIDO , SC1->C1_DATPRF ,;
					SC1->C1_SOLICIT, cOS            , RecNo() })
				EndIf
			EndIf
		Next
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Solicitacao ao Armazem      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//Se houver Ordem de Producao, busca as Solicitacoes ao Armazem
	If !Empty(cOP)

		cAlsSCP := GetNextAlias()
		
		BeginSQL Alias cAlsSCP

			SELECT
				SCP.CP_NUM,
				SCP.CP_ITEM,
				SCP.CP_PRODUTO,
				SCP.CP_QUANT,
				SCP.CP_OBS,
				SCP.CP_SOLICIT,
				SCP.CP_DATPRF
			FROM
				%table:SCP% SCP
			WHERE
				SCP.CP_FILIAL  	= %xFilial:SCP%	AND
				SCP.CP_OP   	= %exp:cOP% 	AND
				SCP.%NotDel%
		EndSQL

		While (cAlsSCP)->( !EoF() )

			aAdd(aI5ERPArm, {(cAlsSCP)->CP_NUM, (cAlsSCP)->CP_ITEM,;
			(cAlsSCP)->CP_PRODUTO, AllTrim(NOMINSBRW("P",(cAlsSCP)->CP_PRODUTO)), (cAlsSCP)->CP_QUANT, ;
			(cAlsSCP)->CP_OBS, (cAlsSCP)->CP_SOLICIT, cOS,;
			RecNo(), StoD((cAlsSCP)->CP_DATPRF) })
	

			dbSelectArea(cAlsSCP)
			dbSkip()
		
		End

		(cAlsSCP)->( dbCloseArea() )
	EndIf

	//Se existir algum Produto nos isumos da O.S., busca a S.A. relacionada
	If Len(aProds) > 0
		ProcRegua(Len(aProds))

		For nX := 1 To Len(aProds)
			IncProc(STR0183) //"Carregando ERP - Solicita็๕es ao Armaz้m..."

			dbSelectArea("SCP")
			dbSetOrder(1)
			If dbSeek(xFilial("SCP")+aProds[nX][7])
				nPos := aScan(aI5ERPArm, {|x| x[3] == SCP->CP_PRODUTO .And. x[10] == SCP->CP_DATPRF })

				If nPos == 0
					aAdd(aI5ERPArm, {SCP->CP_NUM, SCP->CP_ITEM,;
					SCP->CP_PRODUTO, AllTrim(NOMINSBRW("P",SCP->CP_PRODUTO)), SCP->CP_QUANT, ;
					SCP->CP_OBS, SCP->CP_SOLICIT, cOS,;
					RecNo(), SCP->CP_DATPRF })
				EndIf
			EndIf
		Next
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Finalizando Informaces ERP   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//--- Finaliza os Arrays
	If Len(aI5ERPDoc) > 0
		aSort(aI5ERPDoc, , , {|x,y| x[1]+x[2]+x[10]+cValToChar(x[6]) < y[1]+y[2]+y[10]+cValToChar(y[6]) })
	Else
		aI5ERPDoc := aClone(MNTC755MON(50))
	EndIf

	If Len(aI5ERPCom) > 0
		aSort(aI5ERPCom, , , {|x,y| x[1]+x[2]+x[3]+cValToChar(x[5]) < y[1]+y[2]+y[3]+cValToChar(y[5]) })
	Else
		aI5ERPCom := aClone(MNTC755MON(51))
	EndIf

	If Len(aI5ERPArm) > 0
		aSort(aI5ERPArm, , , {|x,y| x[1]+x[2]+x[3]+x[7] < y[1]+y[2]+y[3]+y[7] })
	Else
		aI5ERPArm := aClone(MNTC755MON(52))
	EndIf

	oI5BrwDoc:SetArray(aI5ERPDoc)
	oI5BrwDoc:bLine := bI5LineDoc
	oI5BrwDoc:GoTop()
	oI5BrwDoc:Refresh()

	oI5BrwCom:SetArray(aI5ERPCom)
	oI5BrwCom:bLine := bI5LineCom
	oI5BrwCom:GoTop()
	oI5BrwCom:Refresh()

	oI5BrwArm:SetArray(aI5ERPArm)
	oI5BrwArm:bLine := bI5LineArm
	oI5BrwArm:GoTop()
	oI5BrwArm:Refresh()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfI5ERPVis บAutor  ณWagner S. de Lacerdaบ Data ณ  04/04/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Visualiza a integraco relacionada (Documento / Solicitacoesบฑฑ
ฑฑบ          ณ de Compra / Solicitacoes ao Armazem).                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T. -> Registro visualizado.                               บฑฑ
ฑฑบ          ณ .F. -> Nao foi possivel visualizar o registro.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nnERP -> Obrigatorio;                                      บฑฑ
ฑฑบ          ณ          Indica qual integracao sera visualizada.          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fI5ERPVis(nERP)

	Local cOldCad := cCadastro

	Local nLinha := 1
	Local lRet   := .T.

	If nERP == 1 //Visualiza Documento de Entrada
		nLinha := oI5BrwDoc:nAt

		dbSelectArea("SF1")
		dbSetOrder(1)
		If dbSeek(xFilial("SF1")+aI5ERPDoc[nLinha][1]+aI5ERPDoc[nLinha][10]+aI5ERPDoc[nLinha][11]+aI5ERPDoc[nLinha][12]+aI5ERPDoc[nLinha][13])
			MsgRun(STR0184, STR0185, {||; //"Visualizando Documento de Entrada... Por favor aguarde..."###"Visualizando Registro..."
			A103NFiscal("SD1", aI5ERPDoc[nLinha][9], 2, .F., .F.); //Funcao de Visualizacao do MATA103.PRX
			} )
		Else
			ShowHelpDlg(STR0110,; //"Registro Inexistente."
			{STR0186},2,; //"Nใo foi possํvel visualizar o Documento de Entrada."
			{STR0187},2) //"Verifique se o Documento realmente existe e tente novamente."
			lRet := .F.
		EndIf
	ElseIf nERP == 2 //Visualiza Solicitacao de Compra
		nLinha := oI5BrwCom:nAt

		dbSelectArea("SC1")
		dbSetOrder(1)
		If dbSeek(xFilial("SC1")+aI5ERPCom[nLinha][1])
			MsgRun(STR0188, STR0185, {||; //"Visualizando Solicita็ใo de Compra... Por favor aguarde..."###"Visualizando Registro..."
			A110Visual("SC1", aI5ERPCom[nLinha][12], 2); //Funcao de Visualizacao do MATA110.PRX
			} )
		Else
			ShowHelpDlg(STR0110,; //"Registro Inexistente."
			{STR0189},2,; //"Nใo foi possํvel visualizar a Solicita็ใo de Compra."
			{STR0190},2) //"Verifique se a S.C. realmente existe e tente novamente."
			lRet := .F.
		EndIf
	ElseIf nERP == 3 //Visualiza Solicitacao ao Armazem
		nLinha := oI5BrwArm:nAt

		dbSelectArea("SCP")
		dbSetOrder(1)
		If dbSeek(xFilial("SCP")+aI5ERPArm[nLinha][1])
			MsgRun(STR0191, STR0185, {||; //"Visualizando Solicita็ใo ao Armaz้m... Por favor aguarde..."###"Visualizando Registro..."
			A105Visual("SCP", aI5ERPArm[nLinha][9], 2); //Funcao de Visualizacao do MATA105.PRX
			} )
		Else
			ShowHelpDlg(STR0110,; //"Registro Inexistente."
			{STR0192},2,; //"Nใo foi possํvel visualizar a Solicita็ใo ao Armaz้m."
			{STR0193},2) //"Verifique se a S.A. realmente existe e tente novamente."
			lRet := .F.
		EndIf
	EndIf

	cCadastro := cOldCad

	INCLUI := .F.
	ALTERA := .F.

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fCposSim
Carrega os campos que nao devem estar no cabecalho (aNao)
atraves dos campos que devem estar (especia de aSim).

@author  Wagner S. de Lacerda
@since   04/04/2011
@version P12
@param   cArquivo, caracter, indica a tabela SX3.
@param   aCpos, array, Indica os campos que devem aparecer.
@return  .T.
/*/
//-------------------------------------------------------------------
Static Function fCposSim(cArquivo, aCpos)

	Local aNao     := {}
	Local nPos     := 0
	Local aHeadFil := {}
	Local nInd     := 0

	If Len(aCpos) > 0
		//Carrega os campos do TRB e do Browse
		aHeadFil := NGHeader(cArquivo)
		For nInd := 1 To Len(aHeadFil)
			nPos := aScan(aCpos, {|x| AllTrim(x) == AllTrim(aHeadFil[nInd,2])})

			If nPos == 0
				aAdd(aNao, AllTrim(aHeadFil[nInd,2]))
			EndIf
		Next nInd
	EndIf

Return aNao

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfGetCores บAutor  ณWagner S. de Lacerdaบ Data ณ  11/07/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega as cores da legenda das Informacoes ERP.           บฑฑ
ฑฑบ          ณ (deve estar de acordo com os respectivos fontes originais: บฑฑ
ฑฑบ          ณ MATA103, MATA105 e MATA 110)                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ oRetCor -> Objeto com a Cor da situacao (vide legenda).    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nVer ---> Origatorio;                                      บฑฑ
ฑฑบ          ณ           Define qual o objeto a verificar a cor.          บฑฑ
ฑฑบ          ณ            1 - Documento de Entrada                        บฑฑ
ฑฑบ          ณ            2 - Solicitacao de Compra                       บฑฑ
ฑฑบ          ณ            3 - Solicitacao ao Armazem                      บฑฑ
ฑฑบ          ณ nLinha -> Obrigatorio;                                     บฑฑ
ฑฑบ          ณ           Indica a linha atual do objeto verificado.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fGetCores(nVer,nLinha)

	Local aCores    := {}
	Local aCoresUsr := {}
	Local cLoadCor  := "BR_PRETO"
	Local lLoadCor  := .T.
	Local lAProvSI  := GetNewPar("MV_APROVSI",.F.)
	Local nResult   := 0
	Local oRetCor

	If nVer == 1 //Documento de Entrada - MATA103
		aCores := { {'Empty(F1_STATUS)','ENABLE'	 },; // NF Nao Classificada
		{'F1_STATUS=="B"'  ,'BR_LARANJA' },; // NF Bloqueada
		{'F1_STATUS=="C"'  ,'BR_VIOLETA' },; // NF Bloqueada s/classf.
		{'F1_TIPO=="N"'    ,'DISABLE'    },; // NF Normal
		{'F1_TIPO=="P"'    ,'BR_AZUL'    },; // NF de Compl. IPI
		{'F1_TIPO=="I"'    ,'BR_MARROM'  },; // NF de Compl. ICMS
		{'F1_TIPO=="C"'    ,'BR_PINK'    },; // NF de Compl. Preco/Frete
		{'F1_TIPO=="B"'    ,'BR_CINZA'   },; // NF de Beneficiamento
		{'F1_TIPO=="D"'    ,'BR_AMARELO' } } // NF de Devolucao

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Ajusta as cores se utilizar coletor de dados                 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If SuperGetMV("MV_CONFFIS",.F.,"N") == "S"
			aCores := {}
			aAdd(aCores,{ '(F1_STATCON=="1" .OR. EMPTY(F1_STATCON)) .AND. Empty(F1_STATUS)'	, 'ENABLE' 		})  // NF Nao Classificada
			If SuperGetMV("MV_TPCONFF",.F.,"1") == "1"
				aAdd(aCores,{ '(F1_STATCON=="1" .OR. EMPTY(F1_STATCON)) .AND. F1_TIPO=="N" .AND. (F1_STATUS<>"B" .AND. F1_STATUS<>"C")'	, 'DISABLE'	})	// NF Normal
				aAdd(aCores,{ 'F1_STATUS=="B"'													, 'BR_LARANJA'	})  // NF Bloqueada
				aAdd(aCores,{ 'F1_STATUS=="C"'													, 'BR_VIOLETA'	})  // NF Bloqueada s/classf.
				aAdd(aCores,{ '(F1_STATCON=="1" .OR. EMPTY(F1_STATCON)) .AND. F1_TIPO=="P"'	 	, 'BR_AZUL'		})  // NF de Compl. IPI
				aAdd(aCores,{ '(F1_STATCON=="1" .OR. EMPTY(F1_STATCON)) .AND. F1_TIPO=="I"'	 	, 'BR_MARROM'	})  // NF de Compl. ICMS
				aAdd(aCores,{ '(F1_STATCON=="1" .OR. EMPTY(F1_STATCON)) .AND. F1_TIPO=="C"'	 	, 'BR_PINK'		})  // NF de Compl. Preco/Frete
				aAdd(aCores,{ '(F1_STATCON=="1" .OR. EMPTY(F1_STATCON)) .AND. F1_TIPO=="B"'	 	, 'BR_CINZA'	})  // NF de Beneficiamento
				aAdd(aCores,{ '(F1_STATCON=="1" .OR. EMPTY(F1_STATCON)) .AND. F1_TIPO=="D"'    	, 'BR_AMARELO'	})  // NF de Devolucao
				aAdd(aCores,{ 'F1_STATCON<>"1" .AND. !EMPTY(F1_STATCON) .AND. Empty(F1_STATUS)'	, 'BR_PRETO'	})  // NF Bloq. para Conferencia
			Else
				aAdd(aCores,{ 'F1_STATCON=="1" .AND. F1_TIPO=="N" .AND. (F1_STATUS<>"B" .AND. F1_STATUS<>"C")', 'DISABLE'		})  // NF Normal
				aAdd(aCores,{ 'F1_STATUS=="B"'													, 'BR_LARANJA'	})  // NF Bloqueada
				aAdd(aCores,{ 'F1_STATUS=="C"'													, 'BR_VIOLETA'	})  // NF Bloqueada s/classf.
				aAdd(aCores,{ '(F1_STATCON=="1" .OR. EMPTY(F1_STATCON)) .AND. F1_TIPO=="P"'	 	, 'BR_AZUL'		})  // NF de Compl. IPI
				aAdd(aCores,{ '(F1_STATCON=="1" .OR. EMPTY(F1_STATCON)) .AND. F1_TIPO=="I"'	 	, 'BR_MARROM'	})  // NF de Compl. ICMS
				aAdd(aCores,{ '(F1_STATCON=="1" .OR. EMPTY(F1_STATCON)) .AND. F1_TIPO=="C"'	 	, 'BR_PINK'		})  // NF de Compl. Preco/Frete
				aAdd(aCores,{ '(F1_STATCON=="1" .OR. EMPTY(F1_STATCON)) .AND. F1_TIPO=="B"'	 	, 'BR_CINZA'	})  // NF de Beneficiamento
				aAdd(aCores,{ '(F1_STATCON=="1" .OR. EMPTY(F1_STATCON)) .AND. F1_TIPO=="D"'    	, 'BR_AMARELO'	})  // NF de Devolucao
				aAdd(aCores,{ 'F1_STATCON<>"1" .AND. !EMPTY(F1_STATCON) .AND. F1_TIPO=="N"'		, 'BR_PRETO'	})  // NF Bloq. para Conferencia
			EndIf
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณPonto de entrada para inclusใo de nova COR da legenda       ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If ExistBlock("MT103COR")
			aCoresUsr := ExecBlock("MT103COR",.F.,.F.,{aCores})
			If ValType(aCoresUsr) == "A"
				aCores := aClone(aCoresUsr)
			EndIf
		EndIf

		dbSelectArea("SF1")
		dbSetOrder(1)
		If dbSeek(xFilial("SF1")+aI5ERPDoc[nLinha][1]+aI5ERPDoc[nLinha][10]+aI5ERPDoc[nLinha][11]+aI5ERPDoc[nLinha][12]+aI5ERPDoc[nLinha][13])
			lLoadCor := .T.
			aEval(aCores, {|x| If(&(x[1]), If(lLoadCor,(cLoadCor := x[2],lLoadCor := .F.),cLoadCor := cLoadCor), cLoadCor := cLoadCor)})
		EndIf
	ElseIf nVer == 2 //Solicitacao de Compra - MATA110
		If lAprovSI
			//-- Integracao com o modulo de Gestao de Contratos
			If SC1->(FieldPos("C1_FLAGGCT")) > 0
				aAdd(aCores,{'C1_FLAGGCT=="1"','BR_MARROM'})		//SC Totalmente Atendida pelo SIGAGCT
			EndIf
			If SC1->(FieldPos("C1_TIPO"))>0
				aAdd(aCores,{'C1_TIPO==2' 	                                                                            ,'BR_BRANCO'	})	//Solicitacao de Importacao
			Endif
			aAdd(aCores,{'!Empty(C1_RESIDUO)'																			,'BR_PRETO'		})	//SC Eliminada por Residuo
			aAdd(aCores,{'C1_QUJE==0.And.C1_COTACAO==Space(Len(C1_COTACAO)).And.C1_APROV$" ,L"' 						,'ENABLE'		})	//SC em Aberto
			aAdd(aCores,{'C1_QUJE==0.And.(C1_COTACAO==Space(Len(C1_COTACAO)).Or.C1_COTACAO=="IMPORT").And.C1_APROV="R"'	,'BR_LARANJA'	})	//SC Rejeitada
			aAdd(aCores,{'C1_QUJE==0.And.(C1_COTACAO==Space(Len(C1_COTACAO)).Or.C1_COTACAO=="IMPORT").And.C1_APROV="B"'	,'BR_CINZA' 	})	//SC Bloqueada
			aAdd(aCores,{'C1_QUJE==C1_QUANT' 																			,'DISABLE'		})	//SC com Pedido Colocado
			aAdd(aCores,{'C1_QUJE>0' 																					,'BR_AMARELO'	})	//SC com Pedido Colocado Parcial
			aAdd(aCores,{'C1_QUJE==0.And.C1_COTACAO<>Space(Len(C1_COTACAO)).And. C1_IMPORT <>"S" ' 						,'BR_AZUL'		})	//SC em Processo de Cotacao
			aAdd(aCores,{'C1_QUJE==0.And.C1_COTACAO<>Space(Len(C1_COTACAO)).And. C1_IMPORT =="S".And.C1_APROV$" ,L"' 	,'BR_PINK'		})	//SC com Produto Importado
		Else
			//-- Integracao com o modulo de Gestao de Contratos
			If SC1->(FieldPos("C1_FLAGGCT")) > 0
				aAdd(aCores,{'C1_FLAGGCT=="1"' , 'BR_MARROM'})	//SC Totalmente Atendida pelo SIGAGCT
			EndIf
			If SC1->(FieldPos("C1_TIPO"))>0
				aAdd(aCores,{'C1_TIPO==2' 	                                                                            ,'BR_BRANCO'	})	//Solicitacao de Importacao
			EndIf
			aAdd(aCores,{'!Empty(C1_RESIDUO)'																			,'BR_PRETO'		})	//SC Eliminada por Residuo
			aAdd(aCores,{'C1_QUJE==0.And.C1_COTACAO==Space(Len(C1_COTACAO)).And.C1_APROV$" ,L"'							,'ENABLE'		})	//SC em Aberto
			aAdd(aCores,{'C1_QUJE==0.And.C1_COTACAO==Space(Len(C1_COTACAO)).And.C1_APROV="R"' 							,'BR_LARANJA'	})	//SC Rejeitada
			aAdd(aCores,{'C1_QUJE==0.And.C1_COTACAO==Space(Len(C1_COTACAO)).And.C1_APROV="B"' 							,'BR_CINZA'		})	//SC Bloqueada
			aAdd(aCores,{'C1_QUJE==C1_QUANT'																			,'DISABLE'		})	//SC com Pedido Colocado
			aAdd(aCores,{'C1_QUJE>0'																					,'BR_AMARELO'	})	//SC com Pedido Colocado Parcial
			aAdd(aCores,{'C1_QUJE==0.And.C1_COTACAO<>Space(Len(C1_COTACAO)).And. C1_IMPORT <>"S" '						,'BR_AZUL'		})	//SC em Processo de Cotacao
			aAdd(aCores,{'C1_QUJE==0.And.C1_COTACAO<>Space(Len(C1_COTACAO)).And. C1_IMPORT =="S"'						,'BR_PINK'		})	//SC com Produto Importado
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Ponto de Entrada para alterar cores do Browse do Cadastro    ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If ExistBlock("MT110COR")
			aCoresUsr := ExecBlock("MT110COR",.F.,.F.,{aCores})
			If ValType(aCoresUsr) == "A"
				aCores := aClone(aCoresUsr)
			EndIf
		EndIf

		dbSelectArea("SC1")
		dbSetOrder(1)
		If dbSeek(xFilial("SC1")+aI5ERPCom[nLinha][1])
			lLoadCor := .T.
			aEval(aCores, {|x| If(&(x[1]), If(lLoadCor,(cLoadCor := x[2],lLoadCor := .F.),cLoadCor := cLoadCor), cLoadCor := cLoadCor)})
		EndIf
	ElseIf nVer == 3 //Solicitacao Ao Armazem - MATA105
		If AliasInDic("SCW")
			aAdd(aCores, { "!EMPTY(CP_PREREQU) .AND. CP_STATSA <> 'B'" , "Disable" })
			aAdd(aCores, { "EMPTY(CP_PREREQU)  .AND. CP_STATSA <> 'B'" , "Enable"  })
			aAdd(aCores, { "CP_STATSA == 'B'", "BR_PRETO" })
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ P.E. Utilizado para alterar as cores da legenda              ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If ExistBlock("MT105COR")
			aCoresUsr := ExecBlock("MT105COR",.F.,.F., {aCores} )
			If Valtype(aCoresUsr) == "A"
				aCores := aClone(aCoresUsr)
			EndIf
		EndIf

		dbSelectArea("SCP")
		dbSetOrder(1)
		If dbSeek(xFilial("SCP")+aI5ERPArm[nLinha][1])
			lLoadCor := .T.
			aEval(aCores, {|x| If(&(x[1]), If(lLoadCor,(cLoadCor := x[2],lLoadCor := .F.),cLoadCor := cLoadCor), cLoadCor := cLoadCor)})
		EndIf
	EndIf

	oRetCor := LoadBitmap(GetResources(),cLoadCor)

Return oRetCor

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfNomeTar  บAutor  ณWagner S. de Lacerdaบ Data ณ  02/06/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega a descricao da tarefa.                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ cNomeTar -> Nome da Tarefa.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fNomeTar(cTarefa)

	Local cNomeTar := ""

	If lUsaTarPad .And. lOSCorret //Usa Tarefa Generica e e' Corretiva?
		cNomeTar := SubStr(NGSEEK("TT9",cTarefa,1,"TT9_DESCRI"),1,40)
	Else
		cNomeTar := SubStr(NGSEEK("ST5",cBemLoc+cServico+cSequencia+cTarefa,1,"T5_DESCRIC"),1,40)
	EndIf

	If Empty(cNomeTar) .And. AllTrim(cTarefa) == "0"
		cNomeTar := STR0196 //"SEM ESPECIFICACAO DE TAREFA"
	EndIf

Return cNomeTar

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfVerFunEspบAutor  ณWagner S. de Lacerdaบ Data ณ  13/07/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se o Insumo de Mao de Obra (Funcinario) reportado บฑฑ
ฑฑบ          ณ e' proveniente de uma Especialidade.                       บฑฑ
ฑฑบ          ณ (vide observacao no cabcecalho no inicio deste programa)   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ aRet -> Array com o retorno:                               บฑฑ
ฑฑบ          ณ          [1] - .T. se possuir Especialidade vinculada.     บฑฑ
ฑฑบ          ณ          [2] - Se o [1] for .T., retorna o codigo dessa    บฑฑ
ฑฑบ          ณ                Especialidade.                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fVerFunEsp(cCodFunc)

	Local aArea := GetArea()
	Local aRet  := {.F.,""}

	If !Empty(cCodFunc)
		//Apenas verifica a Especialidade se nao houver insumo previsto do Funcinario
		dbSelectArea((cTRBIns))
		dbSetOrder(1)
		If !dbSeek((cTRBIns)->TL_FILIAL+(cTRBIns)->TL_ORDEM+(cTRBIns)->TL_PLANO+(cTRBIns)->TL_TAREFA+"M"+cCodFunc+"0")
			cCodFunc := AllTrim(cCodFunc)

			dbSelectArea("ST2")
			dbSetOrder(1)
			If dbSeek(xFilial("ST2")+cCodFunc)
				While !Eof() .And. ST2->T2_FILIAL == xFilial("ST2") .And. AllTrim(ST2->T2_CODFUNC) == cCodFunc

					RestArea(aArea)
					dbSelectArea((cTRBIns))
					dbSetOrder(1)
					If dbSeek((cTRBIns)->TL_FILIAL+(cTRBIns)->TL_ORDEM+(cTRBIns)->TL_PLANO+(cTRBIns)->TL_TAREFA+"E"+ST2->T2_ESPECIA)
						If Empty(aRet[2]) //Primeira Especialidade
							aRet[1] := .T.
							aRet[2] := ST2->T2_ESPECIA
						Else //Mais de uma Especialidade reportada para o funcionario nao pode ser controlada
							aRet[1] := .F.
							aRet[2] := ""
						EndIf
					EndIf

					dbSelectArea("ST2")
					dbSkip()
				End
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfCompDtHr บAutor  ณWagner S. de Lacerdaบ Data ณ  13/07/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Compara as Data e Horas a atribui as maiores ou menores    บฑฑ
ฑฑบ          ณ conforme necessidade.                                      บฑฑ
ฑฑบ          ณ Caso as data e horas do parametro e' que sejam validas,    บฑฑ
ฑฑบ          ณ retorna elas mesmas.                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ aRet -> Array com o Retorno:                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aParam1 -> Obrigatorio;                                    บฑฑ
ฑฑบ          ณ            Define as datas/horas ja contidas no insumo.    บฑฑ
ฑฑบ          ณ             [1] - Data Inicio                              บฑฑ
ฑฑบ          ณ             [2] - Hora Inicio                              บฑฑ
ฑฑบ          ณ             [3] - Data Fim                                 บฑฑ
ฑฑบ          ณ             [4] - Hora Fim                                 บฑฑ
ฑฑบ          ณ aParam2 -> Obrigatorio;                                    บฑฑ
ฑฑบ          ณ            Define as datas/horas do insumo atual.          บฑฑ
ฑฑบ          ณ             [1] - Data Inicio                              บฑฑ
ฑฑบ          ณ             [2] - Hora Inicio                              บฑฑ
ฑฑบ          ณ             [3] - Data Fim                                 บฑฑ
ฑฑบ          ณ             [4] - Hora Fim                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fCompDtHr(aParam1, aParam2)

	Local aRet := {}

	If Empty(aParam1[1])
		aParam1[1] := aParam2[1]
		aParam1[2] := aParam2[2]
		aParam1[3] := aParam2[3]
		aParam1[4] := aParam2[4]
	Else
		//Data e Hora Maior/Menor
		If aParam1[1] > aParam2[1]
			aParam1[1] := aParam2[1]
			aParam1[2] := aParam2[2]
		ElseIf aParam1[1] == aParam2[1] .And. aParam1[2] > aParam2[2]
			aParam1[2] := aParam2[2]
		EndIf
		If aParam1[3] < aParam2[3]
			aParam1[3] := aParam2[3]
			aParam1[4] := aParam2[4]
		ElseIf aParam1[3] == aParam2[3] .And. aParam1[4] < aParam2[4]
			aParam1[4] := aParam2[4]
		EndIf
	EndIf

	aRet := aClone(aParam1)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfAlterEnchบAutor  ณWagner S. de Lacerdaบ Data ณ  19/07/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Altera os botoes da EnchoiceBar.                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fAlterEnch()

	Local cBloco
	Local nX
	Local lAction := .T.
	Local lAitens := .T.

	nCtrlsFim := Len(oDlgCOS:aControls)

	For nX := (nCtrlsIni+2) To nCtrlsFim

		lAction := AsCan(ClassDataArr(oDlgCOS:ACONTROLS[nX],.T.), {|x| x[1] == "BACTION"}) <> 0
		lAitens := AsCan(ClassDataArr(oDlgCOS:ACONTROLS[nX],.T.), {|x| x[1] == "AITEMS"}) <> 0

		If Empty(oDlgCOS:ACONTROLS[nX]:CDEFAULTACT) .And. lAction ;
		.And. lAitens .And. Len(oDlgCOS:ACONTROLS[nX]:AITEMS) == 0

			cBloco := GetCbSource(oDlgCOS:ACONTROLS[nX]:BACTION)
			If Upper("aBtnTemp[03][2]") $ Upper(cBloco) //Altera o Botao "Imprime Cadastro"
				oDlgCOS:ACONTROLS[nX]:BACTION := {|| If(FindFunction("NGIMPCAD"),;
				NGIMPCAD("STJ",{xFilial("STJ")+cOS+cPlano},1,.T.,{STR0022+" "+cOS}),; //"Ordem de Servi็o:"
				MNTC755BTN(3)) }
			EndIf
		EndIf
	Next nX

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ SECAO: FUNCOES DIVERSAS - FIM                                         บฑฑ
ฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ SECAO: RELATORIO - INICIO                                             บฑฑ
ฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMNTC755IMPบAutor  ณWagner S. de Lacerdaบ Data ณ  11/03/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprime a Ordem de Servico.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC755IMP()

	Local aArea := GetArea()

	Private cNomeProg := "MNTC755"
	Private nLimite   := 220
	Private cTamanho  := "G"
	Private aReturn   := {STR0254,1,STR0255,1,2,1,"",1} //"Zebrado"###"Administra็ใo"
	Private nTipo     := 0
	Private nLastKey  := 0
	Private cTitulo   := STR0256 //"Relat๓rio da Consulta de Ordem de Servi็o."
	Private cDesc1    := STR0257 //"Relat๓rio da Consulta de Ordem de Servi็o, o qual imprime as informa็๕es"
	Private cDesc2    := STR0258 //"da O.S., seus insumos, tarefas, etapas, custos, etc."
	Private cDesc3    := ""
	Private cString   := "STJ"

	Private aImpOS := {}, aImpSolici := {}, aImpEtapa := {}
	Private cPagTexto :=  ""

	Private nLenImp := 0

	If Empty(cOS)
		ShowHelpDlg(STR0131,; //"O.S. Nใo Definida."
		{STR0259},2,; //"Impossํvel imprimir a Ordem de Servi็o."
		{STR0260},2) //"Indique a Ordem de Servi็o consultada."
		Return .F.
	EndIf

	nLenImp := Len(aImpOS) + Len(aI2Custos) + Len(oI3GetInsP:aCols) + Len(oI3GetInsR:aCols) + Len(oI3GetEta:aCols) + Len(oI3GetOco:aCols) + Len(oI3GetMot:aCols) + Len(oI3GetPro:aCols) + Len(aImpSolici)
	If lSintomas
		nLenImp += Len(oI3GetSin:aCols)
	EndIf

	If FindFunction("TRepInUse") .And. TRepInUse()
		Private oReport, oSection0, oSection1, oSection2, oSection3, oSection4
		Private nPROC := 1, nPROCX := 1

		If File(cDirDic + cImgPXR)
			FErase(cDirDic + cImgPXR)
		EndIf
		If File(cDirDic + cImgOSXS)
			FErase(cDirDic + cImgOSXS)
		EndIf
		If lI2ViuPXR
			oI2GrfPXR:SaveToImage(cImgPXR, cDirDic, "BMP")
		EndIf
		If lI2ViuOSXS
			oI2GrfOSXS:SaveToImage(cImgOSXS, cDirDic, "BMP")
		EndIf

		cDesc1 += Space(1) //Separa a Descricao 1 da 2 (na caixa de mensagem estava muito junto, porque e' diferente do relatorio Padrao)

		//--- Interface de impressao
		oReport := ReportDef()
		oReport:SetLandscape() //Default Paisagem
		oReport:PrintDialog()
	Else
		fImpDefPad()
	EndIf

	RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณReportDef บAutor  ณWagner S. de Lacerdaบ Data ณ  17/12/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Define relatorio personalizavel.                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T. -> Sucesso.                                            บฑฑ
ฑฑบ          ณ .F. -> Ocorreram erros.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ReportDef()

	Local oSubSec, oSubSec2
	Local oCell

	Local uPerVal
	Local lAlign
	Local nX 		:= 0
	Local nZ		:= 0
	Local nTam  	:= 0
	Local nMemo 	:= 0
	Local nTamanho	:= "Len({ })" //Vazio para utilizar no &()
	Local cDescri	:= ""
	Local cPic 		:= ""
	Local cNomeCell := ""

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCriacao do componente de impressao                                      ณ
	//ณ                                                                        ณ
	//ณTReport():New                                                           ณ
	//ณExpC1 : Nome do relatorio                                               ณ
	//ณExpC2 : Titulo                                                          ณ
	//ณExpC3 : Pergunte                                                        ณ
	//ณExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ณ
	//ณExpC5 : Descricao                                                       ณ
	//ณ                                                                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oReport := TReport():New("MNTC755", cTitulo, , {|oReport| ReportPrint()}, cDesc1+cDesc2+cDesc3)

	Pergunte(oReport:uParam,.F.)

	/* Modelo de Impressao
	10        20        30        40        50        60        70        80        90        100       110       120       130       140       150       160       170       180       190       200       210       220
	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	****************************************************************************************************************************************************************************************************************************
	O.S.........: XXXXXX                    Plano.: XXXXXX          Prioridade.: XXX
	Bem/Localiz.: XXXXXXXXXXXXXXXX          Nome..: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	____________________________________________________________________________________________________________________________________________________________________________________________________________________________

	DADOS CADASTRAIS
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	XXXXXXXXXXXXXXXXXXXXXXXXX:     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX    XXXXXXXXXXXXXXXXXXXXXXXXX:     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	XXXXXXXXXXXXXXXXXXXXXXXXX:     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX    XXXXXXXXXXXXXXXXXXXXXXXXX:     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	XXXXXXXXXXXXXXXXXXXXXXXXX:     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX    XXXXXXXXXXXXXXXXXXXXXXXXX:     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	XXXXXXXXXXXXXXXXXXXXXXXXX:     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX    XXXXXXXXXXXXXXXXXXXXXXXXX:     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	XXXXXXXXXXXXXXXXXXXXXXXXX:     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX    XXXXXXXXXXXXXXXXXXXXXXXXX:     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


	~~Proxima Pagina

	CUSTOS
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	Tarefa    Descricao    Tipo de Insumos    Codigo ...
	XXXXXX    XXXXXX       XXXXXXXXXXX        XXXXXXXX
	XXXXXX    XXXXXX       XXXXXXXXXXX        XXXXXXXX
	(Esta parte - acima - e' montada automaticamente com os dados do Browse de Custos - Folder 2 - portanto nao devemos considerar estas posicoes na impressao)
	(Apenas esta descrito aqui como um informativo)

	--- Comparativo de O.S. x Historico

	O.S. XXXXXX | Servico XXXXXX
	XXXXXXXXXXXXX              999,999,999.99 | 999,999,999.99
	------------------------------------------------------------
	XXXXXXXXXXXXX              999,999,999.99 | 999,999,999.99
	------------------------------------------------------------


	~~Proxima Pagina

	DETALHES
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	(Esta parte e' completamente montada a partir dos brwoses em tela, portanto, tambem nao devemos considerar estas posicoes)
	(Apenas informativo... vide os Browses...)

	--- Browse 1

	Tarefa XXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	...   ...   ...
	...   ...   ...

	--- Browse 2

	Tarefa XXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	...   ...   ...
	...   ...   ...

	*/

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCriacao da secao utilizada pelo relatorio                               ณ
	//ณ                                                                        ณ
	//ณTRSection():New                                                         ณ
	//ณExpO1 : Objeto TReport que a secao pertence                             ณ
	//ณExpC2 : Descricao da se็ao                                              ณ
	//ณExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ณ
	//ณ        sera considerada como principal para a se็ใo.                   ณ
	//ณExpA4 : Array com as Ordens do relat๓rio                                ณ
	//ณExpL5 : Carrega campos do SX3 como celulas                              ณ
	//ณ        Default : False                                                 ณ
	//ณExpL6 : Carrega ordens do Sindex                                        ณ
	//ณ        Default : False                                                 ณ
	//ณ                                                                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCriacao da celulas da secao do relatorio                                ณ
	//ณ                                                                        ณ
	//ณTRCell():New                                                            ณ
	//ณExpO1 : Objeto TSection que a secao pertence                            ณ
	//ณExpC2 : Nome da celula do relat๓rio. O SX3 serแ consultado              ณ
	//ณExpC3 : Nome da tabela de referencia da celula                          ณ
	//ณExpC4 : Titulo da celula                                                ณ
	//ณ        Default : X3Titulo()                                            ณ
	//ณExpC5 : Picture                                                         ณ
	//ณ        Default : X3_PICTURE                                            ณ
	//ณExpC6 : Tamanho                                                         ณ
	//ณ        Default : X3_TAMANHO                                            ณ
	//ณExpL7 : Informe se o tamanho esta em pixel                              ณ
	//ณ        Default : False                                                 ณ
	//ณExpB8 : Bloco de c๓digo para impressao.                                 ณ
	//ณ        Default : ExpC2                                                 ณ
	//ณ                                                                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	//ษอออออออออออออออออออออออออออออออออป
	//บ Section 0 - Cabecalho da O.S.   บ
	//ศอออออออออออออออออออออออออออออออออผ
	oSection0 := TRSection():New(oReport, "Cabe็alho", {""} )
	oCell := TRCell():New(oSection0, "OS"     , "" , STR0261, "@!", 14, .T./*lPixel*/, {|| cOS        }/*code-block de impressao*/ ) //"Ordem de Servi็o"
	oCell := TRCell():New(oSection0, "PLANO"  , "" , STR0026, "@!", 10, .T./*lPixel*/, {|| cPlano     }/*code-block de impressao*/ ) //"Plano"
	oCell := TRCell():New(oSection0, "PRIORID", "" , STR0029, "@!", 13, .T./*lPixel*/, {|| cPriorid   }/*code-block de impressao*/ ) //"Prioridade"
	oCell := TRCell():New(oSection0, "SERVICO", "" , STR0032, "@!", 10, .T./*lPixel*/, {|| cServico   }/*code-block de impressao*/ ) //"Servi็o"
	oCell := TRCell():New(oSection0, "BEMLOC" , "" , STR0037, "@!", 20, .T./*lPixel*/, {|| cBemLoc    }/*code-block de impressao*/ ) //"Bem/Localiza็ใo"
	oCell := TRCell():New(oSection0, "NOME"   , "" , STR0094, "@!", 60, .T./*lPixel*/, {|| cNomBemloc }/*code-block de impressao*/ ) //"Nome"

	//ษอออออออออออออออออออออออออออออออออป
	//บ Section 1 - Dados Cadastrais    บ
	//ศอออออออออออออออออออออออออออออออออผ
	oSection1 := TRSection():New(oReport, STR0007, {""} ) //"Dados Cadastrais"
	oCell := TRCell():New(oSection1, "CAMPO1"  , "" , STR0170, ""  , 30, .T./*lPixel*/, {|| fPerTraImp(1,nPROC-1,1) }/*code-block de impressao*/ ) //"Campo"
	oCell := TRCell():New(oSection1, "CONTEUD1", "" , STR0262, "@!", 50, .T./*lPixel*/, {|| fPerTraImp(1,nPROC-1,2) }/*code-block de impressao*/ ) //"Conte๚do"
	oCell := TRCell():New(oSection1, "CAMPO2"  , "" , STR0170, ""  , 30, .T./*lPixel*/, {|| fPerTraImp(1,nPROC,1)   }/*code-block de impressao*/ ) //"Campo"
	oCell := TRCell():New(oSection1, "CONTEUD2", "" , STR0262, "@!", 50, .T./*lPixel*/, {|| fPerTraImp(1,nPROC,2)   }/*code-block de impressao*/ ) //"Conte๚do"

	//ษอออออออออออออออออออออออออออออออออป
	//บ Section 2 - Custos              บ
	//ศอออออออออออออออออออออออออออออออออผ
	oSection2 := TRSection():New(oReport, STR0008, {""} ) //"Custos"
	oCell := TRCell():New(oSection2, "TAREFA", "" , aI2HeaCus[1], ""               , 12, .T./*lPixel*/, {|| aI2Custos[nPROC][1] }/*code-block de impressao*/ )
	oCell := TRCell():New(oSection2, "DESCRI", "" , aI2HeaCus[2], ""               , 55, .T./*lPixel*/, {|| aI2Custos[nPROC][2] }/*code-block de impressao*/ )
	oCell := TRCell():New(oSection2, "TIPINS", "" , aI2HeaCus[3], ""               , 25, .T./*lPixel*/, {|| aI2Custos[nPROC][3] }/*code-block de impressao*/ )
	oCell := TRCell():New(oSection2, "CODIGO", "" , aI2HeaCus[4], ""               , 25, .T./*lPixel*/, {|| aI2Custos[nPROC][4] }/*code-block de impressao*/ )
	oCell := TRCell():New(oSection2, "NOME"  , "" , aI2HeaCus[5], ""               , 30, .T./*lPixel*/, {|| aI2Custos[nPROC][5] }/*code-block de impressao*/ )
	oCell := TRCell():New(oSection2, "PREV"  , "" , aI2HeaCus[6], "@E 9,999,999.99", 25, .T./*lPixel*/, {|| aI2Custos[nPROC][6] }/*code-block de impressao*/ )
	oCell := TRCell():New(oSection2, "REAL"  , "" , aI2HeaCus[7], "@E 9,999,999.99", 25, .T./*lPixel*/, {|| aI2Custos[nPROC][7] }/*code-block de impressao*/ )
	oCell := TRCell():New(oSection2, "DIFF"  , "" , aI2HeaCus[8], "@E 9,999,999.99", 25, .T./*lPixel*/, {|| aI2Custos[nPROC][8] }/*code-block de impressao*/ )
	oCell := TRCell():New(oSection2, "PERC"  , "" , aI2HeaCus[9], "@E 9999.99"     , 25, .T./*lPixel*/, {|| aI2Custos[nPROC][9] }/*code-block de impressao*/ )

	oSection2:Cell("PREV"):SetHeaderAlign("RIGHT")
	oSection2:Cell("REAL"):SetHeaderAlign("RIGHT")
	oSection2:Cell("DIFF"):SetHeaderAlign("RIGHT")
	oSection2:Cell("PERC"):SetHeaderAlign("RIGHT")

	//ษอออออออออออออออออออออออออออออออออป
	//บ Section 3 - Detalhes            บ
	//ศอออออออออออออออออออออออออออออออออผ
	oSection3 := TRSection():New(oReport, STR0009, {""} ) //"Detalhes"
	oCell := TRCell():New(oSection3, "INSPREV" , "" , STR0050, "", 20, .T./*lPixel*/, {|| Space(20)} /*code-block de impressao*/ ) //"Insumos Previstos"
	oSubSec := TRSection():New(oSection3, STR0050, {""} ) //"Insumos Previstos"
	For nX := 1 To Len(oI3GetInsP:aHeader)
		If nX > 15
			Exit
		EndIf
		If "_SEQRELA" $ oI3GetInsP:aHeader[nX][2]
			Loop
		EndIf

		lAlign    := .F.
		cNomeCell := "PREV"+PADL(nX,3,"0")

		cPerHead := "oI3GetInsP:aHeader["+cValToChar(nX)+"][1]"
		nTam     := "TAMSX3(oI3GetInsP:aHeader["+cValToChar(nX)+"][2])[1]"
		If oI3GetInsP:aHeader[nX][8] == "D"
			nTam += " + 3"
		EndIf
		If "_DESTINO" $ oI3GetInsP:aHeader[nX][2]
			uPerVal  := "{|| AllTrim(NGRetSX3Box('TL_DESTINO',AllTrim(oI3GetInsP:aCols[nPROC]["+cValToChar(nX)+"]))) }"
			nTam += " + 40"
		ElseIf "_TIPOREG" $ oI3GetInsP:aHeader[nX][2]
			uPerVal  := "{|| AllTrim(NGRetSX3Box('TL_TIPOREG',AllTrim(oI3GetInsP:aCols[nPROC]["+cValToChar(nX)+"]))) }"
			nTam += " + 50"
		ElseIf "_NOMTAR" $ oI3GetInsP:aHeader[nX][2]
			uPerVal  := "{|| oI3GetInsP:aCols[nPROC]["+cValToChar(nX)+"] }"
			nTam += " + 115"
		ElseIf "_NOMCODI" $ oI3GetInsP:aHeader[nX][2]
			uPerVal  := "{|| oI3GetInsP:aCols[nPROC]["+cValToChar(nX)+"] }"
			nTam += " + 55"
		ElseIf "_USACALE" $ oI3GetInsP:aHeader[nX][2]
			uPerVal  := "{|| oI3GetInsP:aCols[nPROC]["+cValToChar(nX)+"] }"
			nTam += " + 20"
		ElseIf "_UNIDADE" $ oI3GetInsP:aHeader[nX][2]
			uPerVal  := "{|| oI3GetInsP:aCols[nPROC]["+cValToChar(nX)+"] }"
			nTam += " + 25"
		ElseIf "_QUANREC" $ oI3GetInsP:aHeader[nX][2]
			uPerVal  := "{|| oI3GetInsP:aCols[nPROC]["+cValToChar(nX)+"] }"
			nTam += " + 20"
		ElseIf "_QUANTID" $ oI3GetInsP:aHeader[nX][2]
			uPerVal  := "{|| oI3GetInsP:aCols[nPROC]["+cValToChar(nX)+"] }"
			nTam += " + 20"
		ElseIf "_CUSTO" $ oI3GetInsP:aHeader[nX][2]
			uPerVal  := "{|| oI3GetInsP:aCols[nPROC]["+cValToChar(nX)+"] }"
			nTam += " + 20"
		Else
			uPerVal  := "{|| oI3GetInsP:aCols[nPROC]["+cValToChar(nX)+"] }"
			nTam += " + 15"
		EndIf

		If "_QUANTID" $ oI3GetInsP:aHeader[nX][2] .Or. "_CUSTO" $ oI3GetInsP:aHeader[nX][2]
			lAlign := .T.
			cPic := "@E 999,999.99"
		Else
			cPic := ""
		EndIf
		oCell := TRCell():New(oSubSec, cNomeCell , "" , &(cPerHead), cPic, &(nTam), .T./*lPixel*/, &(uPerVal) /*code-block de impressao*/ )

		If lAlign
			oSubSec:Cell(cNomeCell):SetHeaderAlign("RIGHT")
		EndIf
	Next nX

	oCell := TRCell():New(oSection3, "INSREAL" , "" , STR0051, "", 20, .T./*lPixel*/, {|| Space(20)} /*code-block de impressao*/ ) //"Insumos Realizados"
	oSubSec := TRSection():New(oSection3, STR0051, {""} ) //"Insumos Realizados"
	For nX := 1 To Len(oI3GetInsR:aHeader)
		If nX > 15
			Exit
		EndIf
		If "_SEQRELA" $ oI3GetInsP:aHeader[nX][2]
			Loop
		EndIf

		lAlign    := .F.
		cNomeCell := "REAL"+PADL(nX,3,"0")

		cPerHead := "oI3GetInsR:aHeader["+cValToChar(nX)+"][1]"
		nTam     := "TAMSX3(oI3GetInsR:aHeader["+cValToChar(nX)+"][2])[1]"
		If oI3GetInsR:aHeader[nX][8] == "D"
			nTam += " + 3"
		EndIf
		If "_DESTINO" $ oI3GetInsR:aHeader[nX][2]
			uPerVal  := "{|| AllTrim(NGRetSX3Box('TL_DESTINO',AllTrim(oI3GetInsR:aCols[nPROC]["+cValToChar(nX)+"]))) }"
			nTam += " + 40"
		ElseIf "_TIPOREG" $ oI3GetInsR:aHeader[nX][2]
			uPerVal  := "{|| AllTrim(NGRetSX3Box('TL_TIPOREG',AllTrim(oI3GetInsR:aCols[nPROC]["+cValToChar(nX)+"]))) }"
			nTam += " + 50"
		ElseIf "_NOMTAR" $ oI3GetInsR:aHeader[nX][2]
			uPerVal  := "{|| oI3GetInsR:aCols[nPROC]["+cValToChar(nX)+"] }"
			nTam += " + 115"
		ElseIf "_NOMCODI" $ oI3GetInsR:aHeader[nX][2]
			uPerVal  := "{|| oI3GetInsR:aCols[nPROC]["+cValToChar(nX)+"] }"
			nTam += " + 55"
		ElseIf "_USACALE" $ oI3GetInsR:aHeader[nX][2]
			uPerVal  := "{|| oI3GetInsR:aCols[nPROC]["+cValToChar(nX)+"] }"
			nTam += " + 20"
		ElseIf "_UNIDADE" $ oI3GetInsR:aHeader[nX][2]
			uPerVal  := "{|| oI3GetInsR:aCols[nPROC]["+cValToChar(nX)+"] }"
			nTam += " + 25"
		ElseIf "_QUANREC" $ oI3GetInsR:aHeader[nX][2]
			uPerVal  := "{|| oI3GetInsR:aCols[nPROC]["+cValToChar(nX)+"] }"
			nTam += " + 20"
		ElseIf "_QUANTID" $ oI3GetInsR:aHeader[nX][2]
			uPerVal  := "{|| oI3GetInsR:aCols[nPROC]["+cValToChar(nX)+"] }"
			nTam += " + 20"
		ElseIf "_CUSTO" $ oI3GetInsR:aHeader[nX][2]
			uPerVal  := "{|| oI3GetInsR:aCols[nPROC]["+cValToChar(nX)+"] }"
			nTam += " + 20"
		Else
			uPerVal  := "{|| oI3GetInsR:aCols[nPROC]["+cValToChar(nX)+"] }"
			nTam += " + 15"
		EndIf

		If "_QUANTID" $ oI3GetInsR:aHeader[nX][2] .Or. "_CUSTO" $ oI3GetInsR:aHeader[nX][2]
			lAlign := .T.
			cPic := "@E 999,999.99"
		Else
			cPic := ""
		EndIf
		oCell := TRCell():New(oSubSec, cNomeCell , "" , &(cPerHead), cPic, &(nTam), .T./*lPixel*/, &(uPerVal) /*code-block de impressao*/ )

		If lAlign
			oSubSec:Cell(cNomeCell):SetHeaderAlign("RIGHT")
		EndIf
	Next nX

	//Adiciona as descri็๕es da Etapa
	For nZ := 1 To Len(oI3GetEta:aCols)
		nLinhasMemo := MLCOUNT(oI3GetEta:aCols[nZ][7],60)
		cDescri := ""
		For nMemo := 1 to nLinhasMemo
			If nMemo == 1 //Condi็ใo para buscar memo em "diferentes linhas"
				uPerVal := "{|| oI3GetEta:aCols["+cValToChar(nZ)+"][7] }"
				nTam 	:= "TAMSX3(oI3GetEta:aHeader["+cValToChar(4)+"][2])[1]" //Utiliza o maior tamanho que ้ das Etapas 150
				cDescri := AllTrim(MemoLine(oI3GetEta:aCols[nZ][7],60,nMemo))
			Else
				cDescri += Space(1)+Alltrim(MemoLine(oI3GetEta:aCols[nZ][7],60,nMemo))
			EndIf
		Next nMemo
		oI3GetEta:aCols[nZ][7] := SubStr(cDescri,1,97) //Atribui conte๚do de todas as linhas
		//Buscar o maior valor
		If &(nTamanho) < &(nTam)
			nTamanho := nTam
		EndIf
	Next nZ

	oCell := TRCell():New(oSection3, "ETAPAS" , "" , STR0017, "", 20, .T./*lPixel*/, {|| Space(20)} /*code-block de impressao*/ ) //"Etapas"
	oSubSec := TRSection():New(oSection3, STR0017, {""} ) //"Etapas"
	For nX := 1 To Len(oI3GetEta:aHeader)
		cPerHead := "oI3GetEta:aHeader["+cValToChar(nX)+"][1]"
		nTam     := "TAMSX3(oI3GetEta:aHeader["+cValToChar(nX)+"][2])[1]"
		uPerVal  := "{|| oI3GetEta:aCols[nPROC]["+cValToChar(nX)+"] }"
		If oI3GetEta:aHeader[nX][8] == "D"
			nTam += " + 3"
		ElseIf "_TAREFA" $ oI3GetEta:aHeader[nX][2]
			nTam += " + 3"
		ElseIf "_NOMTAR" $ oI3GetEta:aHeader[nX][2]
			nTam += " + 11"
			uPerVal  := "{|| SubStr(oI3GetEta:aCols[nPROC]["+cValToChar(nX)+"],1,20) }"
		ElseIf "_NOMETAP" $ oI3GetEta:aHeader[nX][2]
			uPerVal  := "{|| SubStr(oI3GetEta:aCols[nPROC]["+cValToChar(nX)+"],1,48) }"
		EndIf

		//Condi็ใo para os campos do tipo "memo"
		If oI3GetEta:aHeader[nX][8] == "M"
			nLinhasMemo := MLCOUNT(oI3GetEta:aCols[nPROC][7],60)
			cDescri := ""
			For nMemo := 1 to nLinhasMemo
				If nMemo == 1 //Condi็ใo para buscar memo em "diferentes linhas"
					uPerVal := "{|| oI3GetEta:aCols[nPROC][7] }"
					nTam 	:= "Len(oI3GetEta:aCols[nPROC][7])"
					cDescri := AllTrim(MemoLine(oI3GetEta:aCols[nPROC][7],60,nMemo))
				Else
					cDescri += Space(1)+Alltrim(MemoLine(oI3GetEta:aCols[nPROC][7],60,nMemo))
				EndIf
			Next nMemo
			oI3GetEta:aCols[nPROC][7] := SubStr(cDescri,1,97) //Atribui conte๚do de todas as linhas
			//Buscar o maior valor
			If &(nTamanho) > &(nTam)
				nTam := nTamanho
			EndIf
		EndIf
		//Retirada a condi็ใo para campos "memo", pois podem ser maiores que 100
		If &(nTam) > 100 .And. "NOMETAP" $ oI3GetEta:aHeader[4][2] .And. oI3GetEta:aHeader[nX][8] <> "M"
			nTam  := "oI3GetEta:aHeader["+cValToChar(nX)+"][4] / 2"
		EndIf
		oCell := TRCell():New(oSubSec, "ETAP"+PADL(nX,3,"0") , "" , &(cPerHead), "", &(nTam), .T./*lPixel*/, &(uPerVal) /*code-block de impressao*/ )
	Next nX
	oSubSec2 := TRSection():New(oSubSec, STR0263, {""} ) //"Op็๕es da Etapa"
	oCell := TRCell():New(oSubSec2, "OPCAO", "" , STR0168, "", 20, .T./*lPixel*/, {|| aImpEtapa[nPROCX][3] }/*code-block de impressao*/ ) //"Op็ใo"
	oCell := TRCell():New(oSubSec2, "TIPO" , "" , STR0169, "", 20, .T./*lPixel*/, {|| aImpEtapa[nPROCX][4] }/*code-block de impressao*/ ) //"Tipo"
	oCell := TRCell():New(oSubSec2, "CAMPO", "" , STR0170, "", 20, .T./*lPixel*/, {|| aImpEtapa[nPROCX][5] }/*code-block de impressao*/ ) //"Campo"
	oCell := TRCell():New(oSubSec2, "FORM" , "" , STR0312, "", 40, .T./*lPixel*/, {|| aImpEtapa[nPROCX][6] }/*code-block de impressao*/ ) //"F๓rmula"
	oCell := TRCell():New(oSubSec2, "RESP" , "" , STR0173, "", 20, .T./*lPixel*/, {|| aImpEtapa[nPROCX][7] }/*code-block de impressao*/ ) //"Resposta"
	oSubSec2:nLeftMargin := 10

	oCell := TRCell():New(oSection3, "OCORREN" , "" , STR0018, "", 20, .T./*lPixel*/, {|| Space(20)} /*code-block de impressao*/ ) //"Ocorr๊ncias"
	oSubSec := TRSection():New(oSection3, STR0018, {""} ) //"Ocorr๊ncias"
	For nX := 1 To Len(oI3GetOco:aHeader)
		cPerHead := "oI3GetOco:aHeader["+cValToChar(nX)+"][1]"
		nTam     := "TAMSX3(oI3GetOco:aHeader["+cValToChar(nX)+"][2])[1]"
		If oI3GetOco:aHeader[nX][8] == "D"
			nTam += " + 2"
		EndIf
		uPerVal  := "{|| oI3GetOco:aCols[nPROC]["+cValToChar(nX)+"] }"
		oCell := TRCell():New(oSubSec, "OCOR"+PADL(nX,3,"0") , "" , &(cPerHead), "", &(nTam), .T./*lPixel*/, &(uPerVal) /*code-block de impressao*/ )
	Next nX

	oCell := TRCell():New(oSection3, "MOTIVOS" , "" , STR0019, "", 20, .T./*lPixel*/, {|| Space(20)} /*code-block de impressao*/ ) //"Motivos de Atraso"
	oSubSec := TRSection():New(oSection3, STR0019, {""} ) //"Motivos de Atraso"
	For nX := 1 To Len(oI3GetMot:aHeader)
		cPerHead := "oI3GetMot:aHeader["+cValToChar(nX)+"][1]"
		nTam     := "TAMSX3(oI3GetMot:aHeader["+cValToChar(nX)+"][2])[1]"
		If oI3GetMot:aHeader[nX][8] == "D"
			nTam += " + 2"
		EndIf
		uPerVal  := "{|| oI3GetMot:aCols[nPROC]["+cValToChar(nX)+"] }"
		oCell := TRCell():New(oSubSec, "MOTI"+PADL(nX,3,"0") , "" , &(cPerHead), "", &(nTam), .T./*lPixel*/, &(uPerVal) /*code-block de impressao*/ )
	Next nX

	oCell := TRCell():New(oSection3, "PROBLEM" , "" , STR0020, "", 20, .T./*lPixel*/, {|| Space(20)} /*code-block de impressao*/ ) //"Problemas"
	oSubSec := TRSection():New(oSection3, STR0020, {""} ) //"Problemas"
	For nX := 1 To Len(oI3GetPro:aHeader)
		cPerHead := "oI3GetPro:aHeader["+cValToChar(nX)+"][1]"
		nTam     := "TAMSX3(oI3GetPro:aHeader["+cValToChar(nX)+"][2])[1]"
		If oI3GetPro:aHeader[nX][8] == "D"
			nTam += " + 2"
		EndIf
		uPerVal  := "{|| oI3GetPro:aCols[nPROC]["+cValToChar(nX)+"] }"
		oCell := TRCell():New(oSubSec, "PROB"+PADL(nX,3,"0") , "" , &(cPerHead), "", &(nTam), .T./*lPixel*/, &(uPerVal) /*code-block de impressao*/ )
	Next nX

	If lSintomas
		oCell := TRCell():New(oSection3, "SINTOMA" , "" , STR0021, "", 20, .T./*lPixel*/, {|| Space(20)} /*code-block de impressao*/ ) //"Sintomas"
		oSubSec := TRSection():New(oSection3, STR0021, {""} ) //"Sintomas"
		For nX := 1 To Len(oI3GetSin:aHeader)
			cPerHead := "oI3GetSin:aHeader["+cValToChar(nX)+"][1]"
			nTam     := "TAMSX3(oI3GetSin:aHeader["+cValToChar(nX)+"][2])[1]"
			If oI3GetSin:aHeader[nX][8] == "D"
				nTam += " + 2"
			EndIf
			uPerVal  := "{|| oI3GetSin:aCols[nPROC]["+cValToChar(nX)+"] }"
			oCell := TRCell():New(oSubSec, "SINT"+PADL(nX,3,"0") , "" , &(cPerHead), "", &(nTam), .T./*lPixel*/, &(uPerVal) /*code-block de impressao*/ )
		Next nX
	EndIf

	//ษอออออออออออออออออออออออออออออออออป
	//บ Section 4 - Solicit. de Serv.   บ
	//ศอออออออออออออออออออออออออออออออออผ
	oSection4 := TRSection():New(oReport, STR0010, {""} ) //"Solicita็ใo de Servi็o"
	oCell := TRCell():New(oSection4, "CAMPO1"  , "" , STR0170, ""  , 30, .T./*lPixel*/, {|| fPerTraImp(4,nPROC-1,1) }/*code-block de impressao*/ ) //"Campo"
	oCell := TRCell():New(oSection4, "CONTEUD1", "" , STR0262, "@!", 50, .T./*lPixel*/, {|| fPerTraImp(4,nPROC-1,2) }/*code-block de impressao*/ ) //"Conte๚do"
	oCell := TRCell():New(oSection4, "CAMPO2"  , "" , STR0170, ""  , 30, .T./*lPixel*/, {|| fPerTraImp(4,nPROC,1) }/*code-block de impressao*/ ) //"Campo"
	oCell := TRCell():New(oSection4, "CONTEUD2", "" , STR0262, "@!", 50, .T./*lPixel*/, {|| fPerTraImp(4,nPROC,2) }/*code-block de impressao*/ ) //"Conte๚do"

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณReportPrintบAutor ณWagner S. de Lacerdaบ Data ณ  17/12/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprime o relatorio personalizavel.                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T. -> Sucesso.                                            บฑฑ
ฑฑบ          ณ .F. -> Ocorreram erros.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ReportPrint()

	Local nX, nY, nPos
	Local nSecoesImp
	Local lImgPxR, lImgOSxS

	Local nTQTAREFA  := aScan(aI3HeadEta[1], {|x| AllTrim(x[2]) == "TQ_TAREFA" })
	Local nTQETAPA   := aScan(aI3HeadEta[1], {|x| AllTrim(x[2]) == "TQ_ETAPA" })

	If cTabela <> "STJ"
		nTQTAREFA  := aScan(aI3HeadEta[2], {|x| AllTrim(x[2]) == "TX_TAREFA" })
		nTQETAPA   := aScan(aI3HeadEta[2], {|x| AllTrim(x[2]) == "TX_ETAPA" })
	EndIf

	Private lFirst    := .T.

	Processa({|| fImpProces()}, STR0264) //"Processando Dados da Impressใo..."

	//Imprime o relatorio
	oReport:SetMeter(nLenImp)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Folder 1 - Dados Cadastrais ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cPagTexto := STR0007 //"Dados Cadastrais"
	fPerImpPag()
	lFirst := .F.

	nSecoesImp := 0

	oSection1:Init()
	nX := 0
	If Len(aImpOS) > 0
		While nX <= Len(aImpOS)
			oReport:IncMeter()

			nX += 2

			nPROC := nX
			oSection1:PrintLine()
			fPerImpPag()
		End

		nSecoesImp++
	Else
		oReport:PrintText(STR0114, oReport:Row(), 15) //"Nใo hแ dados para exibir."
		oReport:SkipLine()
	EndIf
	&("oSection1:Finish()")

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Folder 2 - Custos           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cPagTexto := STR0008 //"Custos"
	fPerImpPag(.T.)

	If Len(aI2Custos) > 0 .And. !Empty(aI2Custos[1][1])
		oSection2:Init()
		For nX := 1 To Len(aI2Custos)
			oReport:IncMeter()

			nPROC := nX
			oSection2:PrintLine()
			fPerImpPag()
		Next nX
		&("oSection2:Finish()")

		nSecoesImp++
	Else
		oReport:PrintText(STR0114, oReport:Row(), 15) //"Nใo hแ dados para exibir."
		oReport:SkipLine()
	EndIf

	fPerImpPag(.T.)
	lImgPxR  := File(cDirDic + cImgPXR)
	lImgOSxS := File(cDirDic + cImgOSXS)

	If !lImgPxR
		oReport:PrintText(STR0297+".", oReport:Row(), 15) //"Nใo foi possํvel imprimir o grแfico de custos Previstos x Realizados"
		oReport:IncRow(50)
	EndIf
	If !lImgOSxS
		oReport:PrintText(STR0298+".", oReport:Row(), 15) //"Nใo foi possํvel imprimir o grแfico de custos da O.S. x Hist๓rico"
		oReport:IncRow(50)
	EndIf

	If lImgPxR
		oReport:SayBitmap(oReport:Row(), oReport:Col(), cDirDic + cImgPXR, (oReport:PageWidth() - 10), If(!lImgOSxS,2000,1000))

		nSecoesImp++
		oReport:IncRow(If(!lImgOSxS,2000,1000))
	EndIf
	If lImgOSxS
		oReport:SayBitmap(oReport:Row(), oReport:Col(), cDirDic + cImgOSXS, (oReport:PageWidth() - 10), If(!lImgPxR,2000,1000))

		nSecoesImp++
		oReport:IncRow(If(!lImgPxR,2000,1000))
	EndIf

	oReport:EndPage()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Folder 3 - Detalhes         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cPagTexto := STR0009 //"Detalhes"
	fPerImpPag(.T.)

	//--- Insumos Previstos
	oSection3:Init()
	oSection3:Cell("INSPREV"):Enable()
	oSection3:Cell("INSREAL"):Disable()
	oSection3:Cell("ETAPAS"):Disable()
	oSection3:Cell("OCORREN"):Disable()
	oSection3:Cell("MOTIVOS"):Disable()
	oSection3:Cell("PROBLEM"):Disable()
	If lSintomas
		oSection3:Cell("SINTOMA"):Disable()
	EndIf
	oSection3:PrintLine()
	fPerImpPag()

	If Len(oI3GetInsP:aCols) > 0 .And. !Empty(oI3GetInsP:aCols[1][1])
		oSection3:aSection[1]:Init()
		For nX := 1 To Len(oI3GetInsP:aCols)
			oReport:IncMeter()

			nPROC := nX
			oSection3:aSection[1]:PrintLine()
			fPerImpPag()
		Next nX
		&("oSection3:aSection[1]:Finish()")

		nSecoesImp++
	Else
		oReport:PrintText(STR0114, oReport:Row(), 15) //"Nใo hแ dados para exibir."
		oReport:SkipLine()
	EndIf
	&("oSection3:Finish()")

	//--- Insumos Realizados
	oSection3:Init()
	oSection3:Cell("INSPREV"):Disable()
	oSection3:Cell("INSREAL"):Enable()
	oSection3:Cell("ETAPAS"):Disable()
	oSection3:Cell("OCORREN"):Disable()
	oSection3:Cell("MOTIVOS"):Disable()
	oSection3:Cell("PROBLEM"):Disable()
	If lSintomas
		oSection3:Cell("SINTOMA"):Disable()
	EndIf
	oSection3:PrintLine()
	fPerImpPag()

	If Len(oI3GetInsR:aCols) > 0 .And. !Empty(oI3GetInsR:aCols[1][1])
		oSection3:aSection[2]:Init()
		For nX := 1 To Len(oI3GetInsR:aCols)
			oReport:IncMeter()

			nPROC := nX
			oSection3:aSection[2]:PrintLine()
			fPerImpPag()
		Next nX
		&("oSection3:aSection[2]:Finish()")

		nSecoesImp++
	Else
		oReport:PrintText(STR0114, oReport:Row(), 15) //"Nใo hแ dados para exibir."
		oReport:SkipLine()
	EndIf
	&("oSection3:Finish()")

	//--- Etapas
	oSection3:Init()
	oSection3:Cell("INSPREV"):Disable()
	oSection3:Cell("INSREAL"):Disable()
	oSection3:Cell("ETAPAS"):Enable()
	oSection3:Cell("OCORREN"):Disable()
	oSection3:Cell("MOTIVOS"):Disable()
	oSection3:Cell("PROBLEM"):Disable()
	If lSintomas
		oSection3:Cell("SINTOMA"):Disable()
	EndIf
	oSection3:PrintLine()
	fPerImpPag()

	If Len(oI3GetEta:aCols) > 0 .And. !Empty(oI3GetEta:aCols[1][1])
		oSection3:aSection[3]:Init()
		For nX := 1 To Len(oI3GetEta:aCols)
			oReport:IncMeter()

			nPROC := nX
			oSection3:aSection[3]:PrintLine()
			fPerImpPag()

			//Imprime as opcoes da etapa, caso existam
			nPos := aScan(aImpEtapa, {|x| AllTrim(x[1])+AllTrim(x[2]) == AllTrim(oI3GetEta:aCols[nX][nTQTAREFA]) + AllTrim(oI3GetEta:aCols[nX][nTQETAPA]) })
			If nPos > 0
				oSection3:aSection[3]:aSection[1]:Init()
				For nY := nPos To Len(aImpEtapa)
					If AllTrim(aImpEtapa[nY][1]) + AllTrim(aImpEtapa[nY][2]) == AllTrim(oI3GetEta:aCols[nX][nTQTAREFA]) + AllTrim(oI3GetEta:aCols[nX][nTQETAPA])
						nPROCX := nY
						oSection3:aSection[3]:aSection[1]:PrintLine()
						fPerImpPag()
					Else
						Exit
					EndIf
				Next nY
				&("oSection3:aSection[3]:aSection[1]:Finish()")
				oReport:SkipLine()
				&("oSection3:aSection[3]:Finish()")
				oSection3:aSection[3]:Init()
			EndIf
		Next nX
		&("oSection3:aSection[3]:Finish()")

		nSecoesImp++
	Else
		oReport:PrintText(STR0114, oReport:Row(), 15) //"Nใo hแ dados para exibir."
		oReport:SkipLine()
	EndIf
	&("oSection3:Finish()")

	//--- Ocorrencias
	oSection3:Init()
	oSection3:Cell("INSPREV"):Disable()
	oSection3:Cell("INSREAL"):Disable()
	oSection3:Cell("ETAPAS"):Disable()
	oSection3:Cell("OCORREN"):Enable()
	oSection3:Cell("MOTIVOS"):Disable()
	oSection3:Cell("PROBLEM"):Disable()
	If lSintomas
		oSection3:Cell("SINTOMA"):Disable()
	EndIf
	oSection3:PrintLine()
	fPerImpPag()

	If Len(oI3GetOco:aCols) > 0 .And. !Empty(oI3GetOco:aCols[1][1])
		oSection3:aSection[4]:Init()
		For nX := 1 To Len(oI3GetOco:aCols)
			oReport:IncMeter()

			nPROC := nX
			oSection3:aSection[4]:PrintLine()
			fPerImpPag()
		Next nX
		&("oSection3:aSection[4]:Finish()")

		nSecoesImp++
	Else
		oReport:PrintText(STR0114, oReport:Row(), 15) //"Nใo hแ dados para exibir."
		oReport:SkipLine()
	EndIf
	&("oSection3:Finish()")

	//--- Motivos de Atraso
	oSection3:Init()
	oSection3:Cell("INSPREV"):Disable()
	oSection3:Cell("INSREAL"):Disable()
	oSection3:Cell("ETAPAS"):Disable()
	oSection3:Cell("OCORREN"):Disable()
	oSection3:Cell("MOTIVOS"):Enable()
	oSection3:Cell("PROBLEM"):Disable()
	If lSintomas
		oSection3:Cell("SINTOMA"):Disable()
	EndIf
	oSection3:PrintLine()
	fPerImpPag()

	If Len(oI3GetMot:aCols) > 0 .And. !Empty(oI3GetMot:aCols[1][1])
		oSection3:aSection[5]:Init()
		For nX := 1 To Len(oI3GetMot:aCols)
			oReport:IncMeter()

			nPROC := nX
			oSection3:aSection[5]:PrintLine()
			fPerImpPag()
		Next nX
		&("oSection3:aSection[5]:Finish()")

		nSecoesImp++
	Else
		oReport:PrintText(STR0114, oReport:Row(), 15) //"Nใo hแ dados para exibir."
		oReport:SkipLine()
	EndIf
	&("oSection3:Finish()")

	//--- Problemas
	oSection3:Init()
	oSection3:Cell("INSPREV"):Disable()
	oSection3:Cell("INSREAL"):Disable()
	oSection3:Cell("ETAPAS"):Disable()
	oSection3:Cell("OCORREN"):Disable()
	oSection3:Cell("MOTIVOS"):Disable()
	oSection3:Cell("PROBLEM"):Enable()
	If lSintomas
		oSection3:Cell("SINTOMA"):Disable()
	EndIf
	oSection3:PrintLine()
	fPerImpPag()

	If Len(oI3GetPro:aCols) > 0 .And. !Empty(oI3GetPro:aCols[1][1])
		oSection3:aSection[6]:Init()
		For nX := 1 To Len(oI3GetPro:aCols)
			oReport:IncMeter()

			nPROC := nX
			oSection3:aSection[6]:PrintLine()
			fPerImpPag()
		Next nX
		&("oSection3:aSection[6]:Finish()")

		nSecoesImp++
	Else
		oReport:PrintText(STR0114, oReport:Row(), 15) //"Nใo hแ dados para exibir."
		oReport:SkipLine()
	EndIf
	&("oSection3:Finish()")

	If lSintomas
		//--- Sintomas
		oSection3:Init()
		oSection3:Cell("INSPREV"):Disable()
		oSection3:Cell("INSREAL"):Disable()
		oSection3:Cell("ETAPAS"):Disable()
		oSection3:Cell("OCORREN"):Disable()
		oSection3:Cell("MOTIVOS"):Disable()
		oSection3:Cell("PROBLEM"):Disable()
		oSection3:Cell("SINTOMA"):Enable()

		oSection3:PrintLine()
		fPerImpPag()

		If Len(oI3GetSin:aCols) > 0 .And. !Empty(oI3GetSin:aCols[1][1])
			oSection3:aSection[7]:Init()
			For nX := 1 To Len(oI3GetSin:aCols)
				oReport:IncMeter()

				nPROC := nX
				oSection3:aSection[7]:PrintLine()
				fPerImpPag()
			Next nX
			&("oSection3:aSection[7]:Finish()")

			nSecoesImp++
		Else
			oReport:PrintText(STR0114, oReport:Row(), 15) //"Nใo hแ dados para exibir."
			oReport:SkipLine()
		EndIf
		&("oSection3:Finish()")
	EndIf

	oReport:EndPage()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Folder 4 - Solicit. de Serv.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cPagTexto := STR0010 //"Solicita็ใo de Servi็o"
	fPerImpPag(.T.)

	oSection4:Init()
	nX := 0
	If Len(aImpSolici) > 0
		While nX <= Len(aImpSolici)
			oReport:IncMeter()

			nX += 2

			nPROC := nX
			oSection4:PrintLine()
			fPerImpPag()
		End

		nSecoesImp++
	Else
		oReport:PrintText(STR0114, oReport:Row(), 15) //"Nใo hแ dados para exibir."
		oReport:SkipLine()
	EndIf
	&("oSection4:Finish()")

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Fim do Relatorio            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	&("oSection0:Finish()")

	If nSecoesImp == 0
		MsgStop(STR0265+_ENTER+; //"Nใo foi possํvel imprimir o relat๓rio da "
		STR0266+_ENTER+_ENTER+; //"Consulta da O.S."
		STR0267,STR0089) //"Recarregue a Ordem de Servi็o e tente novamente..."###"Aten็ใo"
		Return .F.
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfPerTraImpบAutor  ณWagner S. de Lacerdaบ Data ณ  07/04/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Trata a impressao dos Dados do dicionario.                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ uRet -> Retorno do campo.                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nFold -> Obrigatorio;                                      บฑฑ
ฑฑบ          ณ          Indica o folder da impressao a ser tratado.       บฑฑ
ฑฑบ          ณ nCont -> Obrigatorio;                                      บฑฑ
ฑฑบ          ณ          Indica posicao do array na impressao.             บฑฑ
ฑฑบ          ณ nPos --> Obrigatorio;                                      บฑฑ
ฑฑบ          ณ          Indica qual a informacao a ser impressa.          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fPerTraImp(nFold, nCont, nPos)

	Local aTemp := {}
	Local uRet := " "

	If nFold == 1
		aTemp := aClone(aImpOS)
	Else
		aTemp := aClone(aImpSolici)
	EndIf

	If Len(aTemp) >= nCont
		uRet := aTemp[nCont][nPos]
		If nPos == 1
			uRet += Replicate(".",(26 - Len(uRet))) + ":"
		EndIf
	EndIf

Return uRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfPerImpPagบAutor  ณWagner S. de Lacerdaบ Data ณ  12/04/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se deve iniciar uma nova pagina.                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ lQuebra -> Opcional;                                       บฑฑ
ฑฑบ          ณ            Define se e' para forcar a quebra de pagina.    บฑฑ
ฑฑบ          ณ            Default: .F.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fPerImpPag(lQuebra)

	Default lQuebra := .F.

	//Se a linha atual ja estiver em 90% da linha maxima, quebra a pagina e iniciliza o cabecalho; Ou se for estipulado para forcar a quabra de Pagina (lQuebra -> variavel private)
	If oReport:Row() >= (oReport:PageHeight() * 0.90) .Or. lQuebra .Or. lFirst //lFirst -> variavel Private que indica se e' o primeiro cabecalho
		If lFirst
			oReport:StartPage()
		Else
			oReport:EndPage()
			oReport:StartPage()
		EndIf

		//Cabecalho
		oSection0:Init()
		oSection0:PrintLine()

		oReport:SkipLine()
		oReport:Say(oReport:Row(), oReport:Col(), OemToAnsi(Upper(cPagTexto)), , oSection1:nCLRBACK, oSection1:nCLRFORE)
		oReport:SkipLine()
		oReport:FatLine()
		oReport:SkipLine()
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfImpDefPadบAutor  ณWagner S. de Lacerdaบ Data ณ  17/03/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza as definicoes do Relatorio Padrao.                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T. -> Sucesso.                                            บฑฑ
ฑฑบ          ณ .F. -> Ocorreram erros.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fImpDefPad()

	Private cWnRel  := "MNTC755"
	Private cCabec1 := STR0268 + PADR(cOS,16," ")     + Space(10) + STR0269 + cPlano + Space(10) + STR0270 + cPriorid + Space(10) + STR0271 + cServico //"O.S.........: "###"Plano.: "###"Prioridade.: "###"Servi็o.: "
	Private cCabec2 := STR0272 + PADR(cBemLoc,16," ") + Space(10) + STR0273 + cNomBemLoc //"Bem/Localiz.: "###"Nome..: "

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Envia controle para a funcao SETPRINT                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cWnRel := SetPrint(cString, cWnRel, , cTitulo, cDesc1, cDesc2, cDesc3, .F., , .F., cTamanho, , .F.)
	If nLastKey == 27
		Return .F.
	EndIf

	nTipo := If(aReturn[4] == 1, 15, 18)

	SetDefault(aReturn, cString)
	RptStatus({|lEnd| fRelPadrao(@lEnd,cWnRel,cTitulo,cTamanho)}, cTitulo)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfRelPadraoบAutor  ณWagner S. de Lacerdaบ Data ณ  17/03/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprime o Relatorio Padrao.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T. -> Sucesso.                                            บฑฑ
ฑฑบ          ณ .F. -> Ocorreram erros.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fRelPadrao()

	Local cOldTar := ""
	Local nColuna := 001
	Local nX, nY, nLinhasMemo, nMemo, nRegs, nPos, nMemoEta, nLinhasEta
	Local nSecoesImp := 0 //Controla a quantidade de secoes impressas, para mostrar ou nao o relatorio

	Local cTipo   := " "
	Local cCondOp := " "
	Local cCampo  := " "
	Local cCondIn := " "
	Local cFormul := " "

	Local nTLSEQRELA := aScan(aI3HeadIns[1], {|x| AllTrim(x[2]) == "TL_SEQRELA" })
	Local nTLTAREFA  := aScan(aI3HeadIns[1], {|x| AllTrim(x[2]) == "TL_TAREFA" })
	Local nTLNOMTAR  := aScan(aI3HeadIns[1], {|x| AllTrim(x[2]) == "TL_NOMTAR" })
	Local nTLTIPOREG := aScan(aI3HeadIns[1], {|x| AllTrim(x[2]) == "TL_TIPOREG" })
	Local nTLQUANTID := aScan(aI3HeadIns[1], {|x| AllTrim(x[2]) == "TL_QUANTID" })
	Local nTLCUSTO   := aScan(aI3HeadIns[1], {|x| AllTrim(x[2]) == "TL_CUSTO" })
	Local nTLDESTINO := aScan(aI3HeadIns[1], {|x| AllTrim(x[2]) == "TL_DESTINO" })

	Local nTQTAREFA  := aScan(aI3HeadEta[1], {|x| AllTrim(x[2]) == "TQ_TAREFA" })
	Local nTQNOMTARE := aScan(aI3HeadEta[1], {|x| AllTrim(x[2]) == "TQ_NOMTARE" })
	Local nTQETAPA   := aScan(aI3HeadEta[1], {|x| AllTrim(x[2]) == "TQ_ETAPA" })
	Local nTQNOMETAP := aScan(aI3HeadEta[1], {|x| AllTrim(x[2]) == "TQ_NOMETAP" })
	Local nTQOBSERVA := aScan(aI3HeadEta[1], {|x| AllTrim(x[2]) == "TQ_OBSERVA" })

	Local nTNTAREFA  := aScan(aI3HeadOco[1], {|x| AllTrim(x[2]) == "TN_TAREFA" })
	Local nTNNOMETAR := aScan(aI3HeadOco[1], {|x| AllTrim(x[2]) == "TN_NOMETAR" })
	Local nTNDESCRIC := aScan(aI3HeadOco[1], {|x| AllTrim(x[2]) == "TN_DESCRIC" })

	Local nTPLCODMOT := aScan(aI3HeadMot[1], {|x| AllTrim(x[2]) == "TPL_CODMOT" })
	Local nTPLDESMOT := aScan(aI3HeadMot[1], {|x| AllTrim(x[2]) == "TPL_DESMOT" })

	Local cRodaTxt := ""
	Local nCntImpr := 0

	Private Li := 80, m_pag := 1

	If cTabela <> "STJ"
		nTLSEQRELA := aScan(aI3HeadIns[2], {|x| AllTrim(x[2]) == "TT_SEQRELA" })
		nTLTAREFA  := aScan(aI3HeadIns[2], {|x| AllTrim(x[2]) == "TT_TAREFA" })
		nTLNOMTAR  := aScan(aI3HeadIns[2], {|x| AllTrim(x[2]) == "TT_NOMTAR" })
		nTLTIPOREG := aScan(aI3HeadIns[2], {|x| AllTrim(x[2]) == "TT_TIPOREG" })
		nTLQUANTID := aScan(aI3HeadIns[2], {|x| AllTrim(x[2]) == "TT_QUANTID" })
		nTLCUSTO   := aScan(aI3HeadIns[2], {|x| AllTrim(x[2]) == "TT_CUSTO" })
		nTLDESTINO := aScan(aI3HeadIns[2], {|x| AllTrim(x[2]) == "TT_DESTINO" })

		nTQTAREFA  := aScan(aI3HeadEta[2], {|x| AllTrim(x[2]) == "TX_TAREFA" })
		nTQNOMTARE := aScan(aI3HeadEta[2], {|x| AllTrim(x[2]) == "TX_NOMTARE" })
		nTQETAPA   := aScan(aI3HeadEta[2], {|x| AllTrim(x[2]) == "TX_ETAPA" })
		nTQNOMETAP := aScan(aI3HeadEta[2], {|x| AllTrim(x[2]) == "TX_NOMETAP" })

		nTNTAREFA  := aScan(aI3HeadOco[2], {|x| AllTrim(x[2]) == "TU_TAREFA" })
		nTNNOMETAR := aScan(aI3HeadOco[2], {|x| AllTrim(x[2]) == "TU_NOMETAR" })
		nTNDESCRIC := aScan(aI3HeadOco[2], {|x| AllTrim(x[2]) == "TU_DESCRIC" })

		nTPLCODMOT := aScan(aI3HeadMot[2], {|x| AllTrim(x[2]) == "TQ6_CODMOT" })
		nTPLDESMOT := aScan(aI3HeadMot[2], {|x| AllTrim(x[2]) == "TQ6_DESMOT" })
	EndIf

	/* Modelo de Impressao
	10        20        30        40        50        60        70        80        90        100       110       120       130       140       150       160       170       180       190       200       210       220
	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	****************************************************************************************************************************************************************************************************************************
	O.S.........: XXXXXX                    Plano.: XXXXXX          Prioridade.: XXX
	Bem/Localiz.: XXXXXXXXXXXXXXXX          Nome..: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	____________________________________________________________________________________________________________________________________________________________________________________________________________________________

	DADOS CADASTRAIS
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	XXXXXXXXXXXXXXXXXXXXXXXXX:     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX    XXXXXXXXXXXXXXXXXXXXXXXXX:     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	XXXXXXXXXXXXXXXXXXXXXXXXX:     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX    XXXXXXXXXXXXXXXXXXXXXXXXX:     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	XXXXXXXXXXXXXXXXXXXXXXXXX:     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX    XXXXXXXXXXXXXXXXXXXXXXXXX:     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	XXXXXXXXXXXXXXXXXXXXXXXXX:     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX    XXXXXXXXXXXXXXXXXXXXXXXXX:     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	XXXXXXXXXXXXXXXXXXXXXXXXX:     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX    XXXXXXXXXXXXXXXXXXXXXXXXX:     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


	~~Proxima Pagina

	CUSTOS
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	Tarefa    Descricao    Tipo de Insumos    Codigo ...
	XXXXXX    XXXXXX       XXXXXXXXXXX        XXXXXXXX
	XXXXXX    XXXXXX       XXXXXXXXXXX        XXXXXXXX
	(Esta parte - acima - e' montada automaticamente com os dados do Browse de Custos - Folder 2 - portanto nao devemos considerar estas posicoes na impressao)
	(Apenas esta descrito aqui como um informativo)

	--- Comparativo de O.S. x Historico

	O.S. XXXXXX | Servico XXXXXX
	XXXXXXXXXXXXX              999,999,999.99 | 999,999,999.99
	------------------------------------------------------------
	XXXXXXXXXXXXX              999,999,999.99 | 999,999,999.99
	------------------------------------------------------------


	~~Proxima Pagina

	DETALHES
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	(Esta parte e' completamente montada a partir dos brwoses em tela, portanto, tambem nao devemos considerar estas posicoes)
	(Apenas informativo... vide os Browses...)

	--- Browse 1

	Tarefa XXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	...   ...   ...
	...   ...   ...

	--- Browse 2

	Tarefa XXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	...   ...   ...
	...   ...   ...

	*/

	Processa({|| fImpProces()}, STR0264) //"Processando Dados da Impressใo..."
	nSecoesImp := 0

	SetRegua(nLenImp)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Folder 1 - Dados Cadastrais ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cPagTexto := STR0007 //"Dados Cadastrais"
	SomaLinha()
	nColuna := 001
	If Len(aImpOS) > 0
		//Imprime os Dados Cadastrais da O.S.
		nRegs := 1
		For nX := 1 To Len(aImpOS)
			IncRegua()

			If nRegs > 2
				nRegs := 1

				SomaLinha()
				nColuna := 001
			ElseIf nRegs == 2
				nColuna := 100
			EndIf

			@ Li,nColuna PSAY OemToAnsi(AllTrim(aImpOS[nX][1])) + Replicate(".",(26 - Len(AllTrim(aImpOS[nX][1])))) + ":" //25 e' o tamanho do titulo no dicionario e o +1 e' para o '.' antes do ':'

			nColuna += 31

			If ValType(aImpOS[nX][2]) <> "A"
				@ Li,nColuna PSAY OemToAnsi(aImpOS[nX][2])
			Else
				For nMemo := 1 To Len(aImpOS[nX][2])
					If nMemo > 1
						SomaLinha()
					EndIf
					@ Li,nColuna PSAY OemToAnsi(aImpOS[nX][2][nMemo])
				Next nMemo
			EndIf

			nRegs++
		Next nX

		nSecoesImp++
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Folder 2 - Custos           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cPagTexto := STR0008 //"Custos"
	SomaLinha(80)
	If Len(aI2Custos) > 0 .And. !Empty(aI2Custos[1][1])
		//Imprime os Custos da O.S
		For nX := 1 To Len(aI2Custos)
			IncRegua()

			nColuna := 001

			If nX == 1
				For nY := 1 To Len(aI2HeaCus)
					If nY > 1
						nColuna += 05 //Espacamento entre as colunas
					EndIf

					//Define as Posicoes
					If nY == 2 //Nome da Tarefa
						nColuna += 10
					ElseIf nY == 3 //Tipo de Insumo
						nColuna += 40
					ElseIf nY == 4 //Codigo do Insumo
						nColuna += 15
					ElseIf nY == 5 //Nome do Insumo
						nColuna += 15
					ElseIf nY == 6 //Previsto
						nColuna += 30 + 4 //Identacao a direita
					ElseIf nY == 7 //Realizado
						nColuna += 15 + 3 //Identacao a direita
					ElseIf nY == 8 //Diferenca
						nColuna += 15 + 3 //Identacao a direita
					ElseIf nY == 9 //Percentual de Variacao
						nColuna += 10 //Identacao a direita
					EndIf

					@ Li,nColuna PSAY aI2HeaCus[nY]

					//Devolve as Identacoes
					If nY == 6 //Previsto
						nColuna -= 4
					ElseIf nY == 7 //Realizado
						nColuna -= 3
					ElseIf nY == 8 //Diferenca
						nColuna -= 3
					ElseIf nY == 9 //Percentual de Variacao
						nColuna -= + 3
					EndIf
				Next nY

				SomaLinha()
				nColuna := 001
			EndIf

			For nY := 1 To Len(aI2HeaCus)
				If nY > 1
					nColuna += 05 //Espacamento entre as colunas
				EndIf

				//Define as Posicoes
				If nY == 2 //Nome da Tarefa
					nColuna += 10
				ElseIf nY == 3 //Tipo de Insumo
					nColuna += 40
				ElseIf nY == 4 //Codigo do Insumo
					nColuna += 15
				ElseIf nY == 5 //Nome do Insumo
					nColuna += 15
				ElseIf nY == 6 //Previsto
					nColuna += 30
				ElseIf nY == 7 //Realizado
					nColuna += 15
				ElseIf nY == 8 //Diferenca
					nColuna += 15
				ElseIf nY == 9 //Percentual de Variacao
					nColuna += 15
				EndIf

				If nY  == 6 .Or. nY == 7 .Or. nY == 8 //Custo Previsto/Realizado/Diferenca
					@ Li,nColuna PSAY Transform(aI2Custos[nX][nY],"@E 9,999,999.99")
				ElseIf nY == 9 //Percentual de Variacao
					@ Li,nColuna PSAY Transform(aI2Custos[nX][nY],"@E 9999.99")
				Else
					If nY == 1
						@ Li,nColuna PSAY SubStr(aI2Custos[nX][nY],1,10)
					ElseIf nY == 2
						@ Li,nColuna PSAY SubStr(aI2Custos[nX][nY],1,25)
					ElseIf nY == 3
						@ Li,nColuna PSAY SubStr(aI2Custos[nX][nY],1,15)
					ElseIf nY == 4
						@ Li,nColuna PSAY SubStr(aI2Custos[nX][nY],1,10)
					ElseIf nY == 5
						@ Li,nColuna PSAY SubStr(aI2Custos[nX][nY],1,25)
					EndIf
				EndIf
			Next nY

			SomaLinha()
		Next nX
		SomaLinha(2)

		nSecoesImp++
	Else
		nColuna := 001
		@ Li,nColuna PSAY OemToAnsi(STR0114) //"Nใo hแ dados para exibir."
		SomaLinha()
	EndIf

	If aScan(aI2DadosOS, {|x| x[2] > 0 }) > 0
		//Imprime o comparativo de Custos da O.S. x Custos do Servico
		nColuna := 001

		@ Li,nColuna PSAY "--- " + OemToAnsi(STR0274) //"Comparativo de O.S. x Hist๓rico"
		SomaLinha(2)

		nColuna := 006
		@ Li,nColuna+28 PSAY OemToAnsi(STR0023) + cOS //"O.S."
		@ Li,nColuna+40 PSAY "|"
		@ Li,nColuna+42 PSAY OemToAnsi(STR0032) + " " + cServico //"Servi็o"
		SomaLinha()
		@ Li,nColuna PSAY Replicate("-",60)
		SomaLinha()
		For nX := 1 To Len(aI2DadosOS) //Lembrando que o tamanho de 'aI2DadosOS' e 'aI2DadosSe' sao os mesmos, pois se referem ao mesmo tipo de registro
			IncRegua()

			@ Li,nColuna PSAY Capital(TIPREGBRW(aI2DadosOS[nX][1]))

			@ Li,nColuna+24 PSAY Transform(aI2DadosOS[nX][2], "@E 999,999,999.99")
			@ Li,nColuna+40 PSAY "|"
			@ Li,nColuna+42 PSAY Transform(aI2DadosSe[nX][2], "@E 999,999,999.99")

			SomaLinha()
			@ Li,nColuna PSAY Replicate("-",60)

			SomaLinha()
		Next nX

		nSecoesImp++
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Folder 3 - Detalhes         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cPagTexto := STR0009 //"Detalhes"
	SomaLinha(80)

	//--- Insumos Previstos
	nColuna := 001

	@ Li,nColuna PSAY "--- " + OemToAnsi(STR0050) //"Insumos Previstos"
	SomaLinha()

	If Len(oI3GetInsP:aCols) > 0 .And. !Empty(oI3GetInsP:aCols[1][1])
		cOldTar := ""
		For nX := 1 To Len(oI3GetInsP:aCols)
			IncRegua()

			nColuna := 001

			If cOldTar <> oI3GetInsP:aCols[nX][nTLTAREFA]
				SomaLinha()
				@ Li,nColuna PSAY oI3GetInsP:aHeader[nTLTAREFA][1] + ": " + AllTrim(oI3GetInsP:aCols[nX][nTLTAREFA]) + " - " + AllTrim(oI3GetInsP:aCols[nX][nTLNOMTAR])
				SomaLinha(2)

				nColuna := 006
				For nY := 1 To Len(oI3GetInsP:aHeader)
					If nY > 15
						Exit
					EndIf

					If nY <> nTLSEQRELA .And. nY <> nTLTAREFA .And. nY <> nTLNOMTAR
						If nY == nTLCUSTO
							nColuna += 5
						EndIf
						@ Li,nColuna PSAY oI3GetInsP:aHeader[nY][1]
						If nY == nTLCUSTO
							nColuna -= 5
						EndIf

						nColuna += (oI3GetInsP:oBrowse:aColSizes[nY] / 3)
					EndIf
				Next nY
				SomaLinha()
			EndIf

			nColuna := 006
			For nY := 1 To Len(oI3GetInsP:aHeader)
				If nY > 15
					Exit
				EndIf

				If nY <> nTLSEQRELA .And. nY <> nTLTAREFA .And. nY <> nTLNOMTAR
					If nY == nTLDESTINO
						@ Li,nColuna PSAY SubStr( AllTrim(NGRetSX3Box("TL_DESTINO",AllTrim(oI3GetInsP:aCols[nX][nY]))) , 1, 12) PICTURE oI3GetInsP:aHeader[nY][3]
					ElseIf nY == nTLTIPOREG
						@ Li,nColuna PSAY SubStr( AllTrim(NGRetSX3Box("TL_TIPOREG",AllTrim(oI3GetInsP:aCols[nX][nY]))) , 1, 15)
					ElseIf nY == nTLQUANTID .Or. nY == nTLCUSTO
						@ Li,nColuna PSAY oI3GetInsP:aCols[nX][nY] PICTURE "@E 999,999.99"
					Else
						@ Li,nColuna PSAY oI3GetInsP:aCols[nX][nY]
					EndIf

					nColuna += (oI3GetInsP:oBrowse:aColSizes[nY] / 3)
				EndIf
			Next nY

			cOldTar := oI3GetInsP:aCols[nX][nTLTAREFA]
			SomaLinha()
		Next nX

		nSecoesImp++
	Else
		nColuna := 001
		@ Li,nColuna PSAY OemToAnsi(STR0114) //"Nใo hแ dados para exibir."
		SomaLinha()
	EndIf

	//--- Insumos Realizados
	If Li <> 12 //12 e' a linha inicial para impressao neste relatorio
		SomaLinha(2)
	EndIf
	nColuna := 001

	@ Li,nColuna PSAY "--- " + OemToAnsi(STR0051) //"Insumos Realizados"
	SomaLinha()

	If Len(oI3GetInsR:aCols) > 0 .And. !Empty(oI3GetInsR:aCols[1][1])
		cOldTar := ""
		For nX := 1 To Len(oI3GetInsR:aCols)
			IncRegua()

			nColuna := 001

			If cOldTar <> oI3GetInsR:aCols[nX][nTLTAREFA]
				SomaLinha()
				@ Li,nColuna PSAY oI3GetInsR:aHeader[nTLTAREFA][1] + ": " + AllTrim(oI3GetInsR:aCols[nX][nTLTAREFA]) + " - " + AllTrim(oI3GetInsR:aCols[nX][nTLNOMTAR])
				SomaLinha(2)

				nColuna := 006
				For nY := 1 To Len(oI3GetInsR:aHeader)
					If nY > 15
						Exit
					EndIf

					If nY <> nTLSEQRELA .And. nY <> nTLTAREFA .And. nY <> nTLNOMTAR
						If nY == nTLCUSTO
							nColuna += 5
						EndIf
						@ Li,nColuna PSAY oI3GetInsR:aHeader[nY][1]
						If nY == nTLCUSTO
							nColuna -= 5
						EndIf

						nColuna += (oI3GetInsR:oBrowse:aColSizes[nY] / 3)
					EndIf
				Next nY
				SomaLinha()
			EndIf

			nColuna := 006
			For nY := 1 To Len(oI3GetInsR:aHeader)
				If nY > 15
					Exit
				EndIf

				If nY <> nTLSEQRELA .And. nY <> nTLTAREFA .And. nY <> nTLNOMTAR
					If nY == nTLDESTINO
						@ Li,nColuna PSAY SubStr( AllTrim(NGRetSX3Box("TL_DESTINO",AllTrim(oI3GetInsR:aCols[nX][nY]))) , 1, 12) PICTURE oI3GetInsR:aHeader[nY][3]
					ElseIf nY == nTLTIPOREG
						@ Li,nColuna PSAY SubStr( AllTrim(NGRetSX3Box("TL_TIPOREG",AllTrim(oI3GetInsR:aCols[nX][nY]))) , 1, 15)
					ElseIf nY == nTLQUANTID .Or. nY == nTLCUSTO
						@ Li,nColuna PSAY oI3GetInsR:aCols[nX][nY] PICTURE "@E 999,999.99"
					Else
						@ Li,nColuna PSAY oI3GetInsR:aCols[nX][nY]
					EndIf

					nColuna += (oI3GetInsR:oBrowse:aColSizes[nY] / 3)
				EndIf
			Next nY

			cOldTar := oI3GetInsR:aCols[nX][nTLTAREFA]
			SomaLinha()
		Next nX

		nSecoesImp++
	Else
		nColuna := 001
		@ Li,nColuna PSAY OemToAnsi(STR0114) //"Nใo hแ dados para exibir."
		SomaLinha()
	EndIf

	//--- Etapas
	If Li <> 12 //12 e' a linha inicial para impressao neste relatorio
		SomaLinha(2)
	EndIf
	nColuna := 001

	@ Li,nColuna PSAY "--- " + OemToAnsi(STR0017) //"Etapas"
	SomaLinha()

	If Len(oI3GetEta:aCols) > 0 .And. !Empty(oI3GetEta:aCols[1][1])
		cOldTar := ""
		For nX := 1 To Len(oI3GetEta:aCols)
			IncRegua()

			nColuna := 001

			If cOldTar <> oI3GetEta:aCols[nX][nTQTAREFA]
				SomaLinha()
				@ Li,nColuna PSAY oI3GetEta:aHeader[nTQTAREFA][1] + ": " + AllTrim(oI3GetEta:aCols[nX][nTQTAREFA]) + " - " + AllTrim(oI3GetEta:aCols[nX][nTQNOMTARE])
				SomaLinha(2)

				nColuna := 006
				For nY := 1 To Len(oI3GetEta:aHeader)
					If nY <> nTQTAREFA .And. nY <> nTQNOMTARE
						@ Li,nColuna PSAY oI3GetEta:aHeader[nY][1]
						If nY == nTQOBSERVA
							nColuna += 70
						EndIf
						nColuna += (oI3GetEta:oBrowse:aColSizes[nY] / If(nY == nTQNOMETAP,8.7,3))
					EndIf
				Next nY
				SomaLinha()
			EndIf

			nColuna := 006
			For nY := 1 To Len(oI3GetEta:aHeader)
				If nY <> nTQTAREFA .And. nY <> nTQNOMTARE
					If nY == nTQNOMETAP
						@ Li,nColuna PSAY SubStr(oI3GetEta:aCols[nX][nY],1,57)
					ElseIf nY == nTQOBSERVA
						nLinhasMemo := MLCOUNT(oI3GetEta:aCols[nX][nY],60)
						For nMemo := 1 To nLinhasMemo
							If nMemo > 1
								SomaLinha()
							EndIf
							@ Li,nColuna PSAY (OemToAnsi(MemoLine(oI3GetEta:aCols[nX][nY],60,nMemo)))
						Next nMemo

						nColuna += 70
					Else
						@ Li,nColuna PSAY oI3GetEta:aCols[nX][nY]
					EndIf

					nColuna += (oI3GetEta:oBrowse:aColSizes[nY] / If(nY == nTQNOMETAP,8.7,3))
				EndIf
			Next nY

			//Imprime as opcoes da etapa, caso existam
			nPos := aScan(aImpEtapa, {|x| AllTrim(x[1])+AllTrim(x[2]) == AllTrim(oI3GetEta:aCols[nX][nTQTAREFA]) + AllTrim(oI3GetEta:aCols[nX][nTQETAPA]) })
			If nPos > 0
				SomaLinha()
				nColuna := 010

				@ Li,nColuna PSAY OemToAnsi(STR0168) //"Op็ใo"
				nColuna += 20
				@ Li,nColuna PSAY OemToAnsi(STR0169) //"Tipo"
				nColuna += 20
				@ Li,nColuna PSAY OemToAnsi(STR0170) //"Campo"
				nColuna += 20
				@ Li,nColuna PSAY OemToAnsi(STR0312) //"F๓rmula"
				nColuna += 40
				@ Li,nColuna PSAY OemToAnsi(STR0173) //"Resposta"

				For nY := nPos To Len(aImpEtapa)
					If AllTrim(aImpEtapa[nY][1]) + AllTrim(aImpEtapa[nY][2]) == AllTrim(oI3GetEta:aCols[nX][nTQTAREFA]) + AllTrim(oI3GetEta:aCols[nX][nTQETAPA])
						SomaLinha()
						nColuna := 010

						@ Li,nColuna PSAY OemToAnsi(aImpEtapa[nY][3])
						nColuna += 20
						@ Li,nColuna PSAY OemToAnsi(aImpEtapa[nY][4])
						nColuna += 20
						@ Li,nColuna PSAY OemToAnsi(aImpEtapa[nY][5])
						nColuna += 20
						@ Li,nColuna PSAY OemToAnsi(aImpEtapa[nY][6])
						nColuna += 40
						@ Li,nColuna PSAY OemToAnsi(aImpEtapa[nY][7])
						nColuna += 20
						If Len(aImpEtapa[1]) > 7
							@ Li,nColuna PSAY OemToAnsi(aImpEtapa[nY][8])
							nColuna += 20
						EndIf
					Else
						Exit
					EndIf
				Next nY
				SomaLinha()
			EndIf

			cOldTar := oI3GetEta:aCols[nX][nTQTAREFA]
			SomaLinha()
		Next nX

		nSecoesImp++
	Else
		nColuna := 001
		@ Li,nColuna PSAY OemToAnsi(STR0114) //"Nใo hแ dados para exibir."
		SomaLinha()
	EndIf

	//--- Ocorrencias
	If Li <> 12 //12 e' a linha inicial para impressao neste relatorio
		SomaLinha(2)
	EndIf
	nColuna := 001

	@ Li,nColuna PSAY "--- " + OemToAnsi(STR0018) //"Ocorr๊ncias"
	SomaLinha()

	If Len(oI3GetOco:aCols) > 0 .And. !Empty(oI3GetOco:aCols[1][1])
		cOldTar := ""
		For nX := 1 To Len(oI3GetOco:aCols)
			IncRegua()

			nColuna := 001

			If cOldTar <> oI3GetOco:aCols[nX][nTNTAREFA]
				SomaLinha()
				@ Li,nColuna PSAY oI3GetOco:aHeader[nTNTAREFA][1] + ": " + AllTrim(oI3GetOco:aCols[nX][nTNTAREFA]) + " - " + AllTrim(oI3GetOco:aCols[nX][nTNNOMETAR])
				SomaLinha(2)

				nColuna := 006
				For nY := 1 To Len(oI3GetOco:aHeader)
					If nY <> nTNTAREFA .And. nY <> nTNNOMETAR
						@ Li,nColuna PSAY oI3GetOco:aHeader[nY][1]

						nColuna += (oI3GetOco:oBrowse:aColSizes[nY] / 3)
					EndIf
				Next nY
				SomaLinha()
			EndIf

			nColuna := 006
			For nY := 1 To Len(oI3GetOco:aHeader)
				If nY <> nTNTAREFA .And. nY <> nTNNOMETAR
					If nY == nTNDESCRIC
						nLinhasMemo := MLCOUNT(oI3GetOco:aCols[nX][nY],60)
						For nMemo := 1 To nLinhasMemo
							If nMemo > 1
								SomaLinha()
							EndIf
							@ Li,nColuna PSAY OemToAnsi(MemoLine(oI3GetOco:aCols[nX][nY],60,nMemo))
						Next nMemo

						nColuna += 70
					Else
						@ Li,nColuna PSAY oI3GetOco:aCols[nX][nY]
						nColuna += (oI3GetOco:oBrowse:aColSizes[nY] / 3)
					EndIf
				EndIf
			Next nY

			cOldTar := oI3GetOco:aCols[nX][nTNTAREFA]
			SomaLinha()
		Next nX

		nSecoesImp++
	Else
		nColuna := 001
		@ Li,nColuna PSAY OemToAnsi(STR0114) //"Nใo hแ dados para exibir."
		SomaLinha()
	EndIf

	//--- Motivos de Atraso
	If Li <> 12 //12 e' a linha inicial para impressao neste relatorio
		SomaLinha(2)
	EndIf
	nColuna := 001

	@ Li,nColuna PSAY "--- " + OemToAnsi(STR0019) //"Motivos de Atraso"
	SomaLinha()

	If Len(oI3GetMot:aCols) > 0 .And. !Empty(oI3GetMot:aCols[1][1])
		SomaLinha()

		For nX := 1 To Len(oI3GetMot:aCols)
			IncRegua()

			If nX == 1
				For nY := 1 To Len(oI3GetMot:aHeader)
					@ Li,nColuna PSAY oI3GetMot:aHeader[nY][1]

					nColuna += (oI3GetMot:oBrowse:aColSizes[nY] / 3)
				Next nY

				SomaLinha()
				nColuna := 001
			EndIf

			nColuna := 001
			For nY := 1 To Len(oI3GetMot:aHeader)
				@ Li,nColuna PSAY oI3GetMot:aCols[nX][nY]
				nColuna += (oI3GetMot:oBrowse:aColSizes[nY] / 3)
			Next nY

			SomaLinha()
		Next nX

		nSecoesImp++
	Else
		nColuna := 001
		@ Li,nColuna PSAY OemToAnsi(STR0114) //"Nใo hแ dados para exibir."
		SomaLinha()
	EndIf

	//--- Problemas
	If Li <> 12 //12 e' a linha inicial para impressao neste relatorio
		SomaLinha(2)
	EndIf
	nColuna := 001

	@ Li,nColuna PSAY "--- " + OemToAnsi(STR0020) //"Problemas"
	SomaLinha()

	If Len(oI3GetPro:aCols) > 0 .And. !Empty(oI3GetPro:aCols[1][1])
		SomaLinha()

		For nX := 1 To Len(oI3GetPro:aCols)
			IncRegua()

			If nX == 1
				For nY := 1 To Len(oI3GetPro:aHeader)
					@ Li,nColuna PSAY oI3GetPro:aHeader[nY][1]

					nColuna += (oI3GetPro:oBrowse:aColSizes[nY] / 3)
				Next nY

				SomaLinha()
				nColuna := 001
			EndIf

			nColuna := 001
			For nY := 1 To Len(oI3GetPro:aHeader)
				@ Li,nColuna PSAY oI3GetPro:aCols[nX][nY]
				nColuna += (oI3GetPro:oBrowse:aColSizes[nY] / 3)
			Next nY

			SomaLinha()
		Next nX

		nSecoesImp++
	Else
		nColuna := 001
		@ Li,nColuna PSAY OemToAnsi(STR0114) //"Nใo hแ dados para exibir."
		SomaLinha()
	EndIf

	If lSintomas
		//--- Sintomas
		If Li <> 12 //12 e' a linha inicial para impressao neste relatorio
			SomaLinha(2)
		EndIf
		nColuna := 001

		@ Li,nColuna PSAY "--- " + OemToAnsi(STR0021) //"Sintomas"
		SomaLinha()

		If Len(oI3GetSin:aCols) > 0 .And. !Empty(oI3GetSin:aCols[1][1])
			SomaLinha()

			For nX := 1 To Len(oI3GetSin:aCols)
				IncRegua()

				If nX == 1
					For nY := 1 To Len(oI3GetSin:aHeader)
						@ Li,nColuna PSAY oI3GetSin:aHeader[nY][1]

						nColuna += (oI3GetSin:oBrowse:aColSizes[nY] / 3)
					Next nY

					SomaLinha()
					nColuna := 001
				EndIf

				nColuna := 001
				For nY := 1 To Len(oI3GetSin:aHeader)
					@ Li,nColuna PSAY oI3GetSin:aCols[nX][nY]
					nColuna += (oI3GetSin:oBrowse:aColSizes[nY] / 3)
				Next nY

				SomaLinha()
			Next nX

			nSecoesImp++
		Else
			nColuna := 001
			@ Li,nColuna PSAY OemToAnsi(STR0114) //"Nใo hแ dados para exibir."
			SomaLinha()
		EndIf
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Folder 4 - Solicit. de Serv.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cPagTexto := STR0010 //"Solicita็ใo de Servi็o"
	SomaLinha(80)
	nColuna := 001
	If Len(aImpSolici) > 0
		//Imprime os Dados Cadastrais da Solicitacao de Servico
		nRegs := 1
		For nX := 1 To Len(aImpSolici)
			IncRegua()

			If nRegs > 2
				nRegs := 1

				SomaLinha()
				nColuna := 001
			ElseIf nRegs == 2
				nColuna := 100
			EndIf

			@ Li,nColuna PSAY OemToAnsi(aImpSolici[nX][1]) + Replicate(".",(26 - Len(aImpSolici[nX][1]))) + ":" //25 e' o tamanho do titulo no dicionario e o +1 e' para o '.' antes do ':'

			nColuna += 31

			If ValType(aImpSolici[nX][2]) <> "A"
				@ Li,nColuna PSAY OemToAnsi(aImpSolici[nX][2])
			Else
				For nMemo := 1 To Len(aImpSolici[nX][2])
					If nMemo > 1
						SomaLinha()
					EndIf
					@ Li,nColuna PSAY OemToAnsi(aImpSolici[nX][2][nMemo])
				Next nMemo
			EndIf

			nRegs++
		Next nX

		nSecoesImp++
	Else
		nColuna := 001
		@ Li,nColuna PSAY OemToAnsi(STR0114) //"Nใo hแ dados para exibir."
		SomaLinha()
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Fim do Relatorio            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If nSecoesImp == 0
		MsgStop(STR0265+_ENTER+; //"Nใo foi possํvel imprimir o relat๓rio da "
		STR0266+_ENTER+_ENTER+; //"Consulta da O.S."
		STR0267,STR0089) //"Recarregue a Ordem de Servi็o e tente novamente..."###"Aten็ใo"
		Return .F.
	EndIf

	Roda(nCntImpr, cRodaTxt, cTamanho)

	Set Device To Screen
	If aReturn[5] == 1
		Set Printer To
		dbCommitAll()
		OurSpool(cWnRel)
	EndIf
	MS_FLUSH()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} fImpProces
Processa os dados do relatorio.

@author  Wagner S. de Lacerda
@since   17/03/2011
@version P12
@return L๓gico, sucesso(.T.) e ocorrram erros(.F.)
/*/
//-------------------------------------------------------------------
Static Function fImpProces()

	Local aMemo
	Local cField
	Local cDescField
	Local lPrev
	Local nX
	Local nMemo
	Local nLinhasMemo
	Local nPos
	Local nRespos
	Local uValor
	Local lReport := Type("oReport") == "O"

	Local aNgHeader	:= {}
	Local nTamTot 	:= 0
	Local nInd 		:= 0
	Local cCampo 	:= ""
	Local cTipo 	:= ""
	Local cUsado 	:= ""
	Local cContext 	:= ""
	Local cPicture 	:= ""

	Local nTQTAREFA  := aScan(aI3HeadEta[1], {|x| AllTrim(x[2]) == "TQ_TAREFA" })
	Local nTQNOMTARE := aScan(aI3HeadEta[1], {|x| AllTrim(x[2]) == "TQ_NOMTARE" })
	Local nTQETAPA   := aScan(aI3HeadEta[1], {|x| AllTrim(x[2]) == "TQ_ETAPA" })

	If cTabela <> "STJ"
		nTQTAREFA  := aScan(aI3HeadEta[2], {|x| AllTrim(x[2]) == "TX_TAREFA" })
		nTQNOMTARE := aScan(aI3HeadEta[2], {|x| AllTrim(x[2]) == "TX_NOMTARE" })
		nTQETAPA   := aScan(aI3HeadEta[2], {|x| AllTrim(x[2]) == "TX_ETAPA" })
	EndIf

	aImpOS     := {}
	aImpEtapa  := {}
	aImpSolici := {}

	// Busca a Ordem de Servico
	dbSelectArea(cTabela)
	dbSetOrder(1)
	If dbSeek(xFilial(cTabela)+cOS+cPlano)
		RegToMemory(cTabela,.F.)

		//Carrega os campos do TRB e do Browse
		aNgHeader := NGHeader(cTabela,,.F.)
		nTamTot := Len(aNgHeader)
		For nInd := 1 To nTamTot
			cCampo 		:= aNgHeader[nInd,2]
			cTipo 		:= Posicione("SX3",2,cCampo,"X3_TIPO")
			cUsado 		:= Posicione("SX3",2,cCampo,"X3_USADO")
			cContext 	:= Posicione("SX3",2,cCampo,"X3_CONTEXT")
			cPicture 	:= Posicione("SX3",2,cCampo,"X3_PICTURE")

			IncProc(STR0275) //"Processando Ordem de Servi็o..."

			cField := cCampo
			cDescField := AllTrim(X3Descric())
			//Retira os enters
			cDescField := StrTran(cDescField, Chr(13), "")
			cDescField := StrTran(cDescField, Chr(10), "")

			If cTipo == "M" .And. lReport//No relatorio personalizavel, os campos Memo nao serao impressos
				Loop
			EndIf

			If X3Uso(cUsado) .And. (cContext <> "V" .Or. cTipo == "M")
				If cTipo == "M"
					uValor := cTabela+"->"+cField
				Else
					uValor := &(cTabela+"->"+cField)
				EndIf
				aMemo := {}

				If cTipo == "D"
					uValor := DTOC(uValor)
				ElseIf cTipo == "N"
					uValor := Transform(uValor, AllTrim(cPicture))
				ElseIf cTipo == "M"
					nLinhasMemo := MLCOUNT(&(uValor),60)
					If nLinhasMemo > 0
						For nMemo := 1 To nLinhasMemo
							aAdd(aMemo, MemoLine(&(uValor),60,nMemo))
						Next nMemo
					Else
						uValor := " "
					EndIf
				Else
					uValor := AllTrim(uValor)
				EndIf

				If Len(aMemo) == 0
					aAdd(aImpOS, {cDescField, uValor})
				Else
					aAdd(aImpOS, {cDescField, aMemo })
				EndIf
			ElseIf cContext == "V"
				uValor := CriaVar(cField,.T.)
				aAdd(aImpOS, {cDescField, uValor})
			EndIf

		Next nInd
	EndIf

	// Busca a Solicitacao de Servico
	dbSelectArea("TQB")
	dbSetOrder(1)
	If dbSeek(xFilial("TQB")+cSolici)
		RegToMemory("TQB",.F.)

		//Carrega os campos do TRB e do Browse
		aNgHeader := NGHeader("TQB",,.F.)
		nTamTot := Len(aNgHeader) - 2
		For nInd := 1 To nTamTot
			cCampo 		:= aNgHeader[nInd,2]
			cTipo 		:= Posicione("SX3",2,cCampo,"X3_TIPO")
			cUsado 		:= Posicione("SX3",2,cCampo,"X3_USADO")
			cContext 	:= Posicione("SX3",2,cCampo,"X3_CONTEXT")
			cPicture 	:= Posicione("SX3",2,cCampo,"X3_PICTURE")

			IncProc(STR0276) //"Processando Solicita็ใo de Servi็o..."

			cField := cCampo
			cDescField := AllTrim(X3Descric())

			If cTipo == "M" .And. lReport//No relatorio personalizavel, os campos Memo nao serao impressos
				Loop
			EndIf

			If X3Uso(cUsado) .And. cContext <> "V"
				If cTipo == "M"
					uValor := "TQB->"+cField
				Else
					uValor := &("TQB->"+cField)
				EndIf
				aMemo := {}

				If cTipo == "D"
					uValor := DTOC(uValor)
				ElseIf cTipo == "N"
					uValor := Transform(uValor, AllTrim(cPicture))
				ElseIf cTipo == "M"
					nLinhasMemo := MLCOUNT(&(uValor),60)
					If nLinhasMemo > 0
						For nMemo := 1 To nLinhasMemo
							aAdd(aMemo, MemoLine(&(uValor),60,nMemo))
						Next nMemo
					Else
						uValor := " "
					EndIf
				Else
					uValor := AllTrim(uValor)
				EndIf

				If Len(aMemo) == 0
					aAdd(aImpSolici, {cDescField, uValor})
				Else
					aAdd(aImpSolici, {cDescField, aMemo })
				EndIf
			ElseIf cContext == "V"
				uValor := CriaVar(cField,.T.)
				aAdd(aImpSolici, {cDescField, uValor})
			EndIf

		Next nInd
	EndIf

	// Busca as Opcoes da Etapa
	For nX := 1 To Len(oI3GetEta:aCols)
		dbSelectArea("TPC")
		dbSetOrder(1)
		If dbSeek(xFilial("TPC")+oI3GetEta:aCols[nX][nTQETAPA])
			While !Eof() .And. TPC->TPC_FILIAL == xFilial("TPC") .And. TPC->TPC_ETAPA == oI3GetEta:aCols[nX][nTQETAPA]

				cTipo   := IIf( TPC->TPC_TIPRES == '2', STR0166, STR0167 ) //"Informar"###"Marcar"
				cCampo  := AllTrim(NGRetSX3Box("TPC_TIPCAM",AllTrim(TPC->TPC_TIPCAM)))
				cFormul := AllTrim( TPC->TPC_FORMUL )

				//Tratamento para nao espacar demais no relatorio
				If Empty(cTipo)
					cTipo := " "
				EndIf

				If Empty(cCampo)
					cCampo := " "
				EndIf
				If Empty( cFormul )
					cCondOp := " "
				EndIf

				aAdd(aImpEtapa, {	oI3GetEta:aCols[nX][nTQTAREFA], TPC->TPC_ETAPA,;
				TPC->TPC_OPCAO, cTipo, cCampo, cFormul, " " })

				dbSelectArea("TPC")
				dbSkip()
			EndDo
		EndIf
		If Len(aImpEtapa) > 0
			//Busca as resposta da Etapa
			dbSelectArea("TPQ")
			dbSetOrder(1)
			If dbSeek(xFilial("TPQ")+cOS+cPlano+oI3GetEta:aCols[nX][nTQTAREFA]+oI3GetEta:aCols[nX][nTQETAPA])
				While !Eof() .And. TPQ->TPQ_FILIAL == xFilial("TPQ") .And. TPQ->TPQ_TAREFA + TPQ->TPQ_ETAPA == oI3GetEta:aCols[nX][nTQTAREFA] + oI3GetEta:aCols[nX][nTQETAPA]
					nPos := aScan(aImpEtapa, {|x| AllTrim(x[1])+AllTrim(x[2])+AllTrim(x[3]) == AllTrim(oI3GetEta:aCols[nX][nTQTAREFA])+AllTrim(oI3GetEta:aCols[nX][nTQETAPA])+AllTrim(TPQ->TPQ_OPCAO) })

					nRespos := 7
					If nPos > 0
						aImpEtapa[nPos][nRespos] := IIf( Empty(TPQ->TPQ_RESPOS), "X", AllTrim(TPQ->TPQ_RESPOS) )
					EndIf

					dbSelectArea("TPQ")
					dbSkip()
				EndDo
			EndIf
		EndIf
	Next nX

	// Limpa o conteudo do array
	For nX := 1 To Len(aImpOS)
		If Empty(aImpOS[nX][2]) .And. ValType(aImpOS[nX][2]) <> "N"
			aImpOS[nX][2] := " "
		EndIf
	Next nX

	For nX := 1 To Len(aImpSolici)
		If Empty(aImpSolici[nX][2]) .And. ValType(aImpSolici[nX][2]) <> "N"
			aImpSolici[nX][2] := " "
		EndIf
	Next nX

	For nX := 1 To Len(aImpEtapa)
		If Empty(aImpEtapa[nX][4]) .And. ValType(aImpEtapa[nX][4]) <> "N"
			aImpEtapa[nX][4] := " "
		EndIf
		If Empty(aImpEtapa[nX][5]) .And. ValType(aImpEtapa[nX][5]) <> "N"
			aImpEtapa[nX][5] := " "
		EndIf
		If Empty(aImpEtapa[nX][6]) .And. ValType(aImpEtapa[nX][6]) <> "N"
			aImpEtapa[nX][6] := " "
		EndIf
		If Empty(aImpEtapa[nX][7]) .And. ValType(aImpEtapa[nX][7]) <> "N"
			aImpEtapa[nX][7] := " "
		EndIf
	Next nX
	aSort(aImpEtapa, , , {|x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3] })

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณSomaLinha บAutor  ณWagner S. de Lacerdaบ Data ณ  17/03/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Soma a linha do relatorio.                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC755                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            บฑฑ
ฑฑฬออออออออออออัออออออออออออัอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ   Data     ณ Descricao                                   บฑฑ
ฑฑฬออออออออออออุออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            ณ xx/xx/xxxx ณ                                             บฑฑ
ฑฑศออออออออออออฯออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SomaLinha(nLinhas)

	Default nLinhas := 1

	Li += nLinhas

	If Li > 58
		Cabec(cTitulo, cCabec1, cCabec2, cNomeProg, cTamanho, nTipo, , .F.) //Nao imprime parametros
		@ Li,001 PSAY OemToAnsi(Upper(cPagTexto))
		SomaLinha()
		@ Li,000 PSAY Replicate("-",nLimite)
		SomaLinha(2)
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ SECAO: RELATORIO - FIM                                                บฑฑ
ฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
