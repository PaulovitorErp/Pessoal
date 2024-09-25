#INCLUDE "MNTR020.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MNTR020  ³ Autor ³ Felipe N. Welter      ³ Data ³ 14/03/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Custo da Mao-de-Obra de Terceiros                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tabelas Utilizadas:					   	                       			    ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ CTT - Centro de Custo			  ³ STJ - O.S. de Manutencao               ³
//³ SX1 - Parametros Genericos	  ³ STS - Historico de Manutencao          ³
//³ ST1 - Funcionarios             ³ STT - Historico de Detalhes da Manut.	 ³
//³ STL - Detalhes da O.S. 		  ³										 			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTR020()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Armazena variaveis p/ devolucao (NGRIGHTCLICK) 				  		  	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aNGBEGINPRM := NGBEGINPRM()

	Local oReport
	Local aArea := GetArea()

	Private nTamCTT		:= IF( (TAMSX3("CTT_CUSTO")[1]) < 1, 9, (TAMSX3("CTT_CUSTO")[1]) )
	Private cTRBTEMP	:= GetNextAlias()

	If FindFunction("TRepInUse") .And. TRepInUse()
		//-- Interface de impressao
		oReport := ReportDef()
		oReport:SetPortrait() //Default Retrato
		oReport:PrintDialog()
	Else
		MNTR020R4()
	EndIf
	RestArea(aArea)

	Set Key VK_F9 To

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Devolve variaveis armazenadas (NGRIGHTCLICK)                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	NGRETURNPRM(aNGBEGINPRM)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ReportDef³ Autor ³ Felipe N. Welter      ³ Data ³ 14/03/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Define as secoes impressas no relatorio                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTR020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()
	Local oReport
	Local oSection1
	Local oSection2
	Local oTotaliz
	Local oCell

	//LAYOUT
	//          1         2         3         4         5         6         7         8         9         0         1         2         3
	//0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
	//Centro de Custo
	//_________________________________________________________
	//xxxxxxxxx - xxxxxxxxxxxxxxxxxxxxxx
	//
	//Matricula    Nome                                   Bem                  O.S.        Qtde Horas              Valor         Dt.Apont.
	//_____________________________________________________________________________________________________________________________________
	//xxxxxx -		xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 	xxxxxxxxxxxxxxxx  	999999		     99,99			 999.999,99		     99/99/9999
	//xxxxxx -		xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 	xxxxxxxxxxxxxxxx  	999999		     99,99			 999.999,99			  99/99/9999
	//
	//Total do Funcionário
	//_____________________________________________________________________________________________________________________________________
	//																																			 999.999,99
	//
	//Matricula    Nome                                   Bem                  O.S.        Qtde Horas              Valor         Dt.Apont.
	//_____________________________________________________________________________________________________________________________________
	//xxxxxx -		xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 	xxxxxxxxxxxxxxxx  	999999		     99,99			 999.999,99		     99/99/9999
	//xxxxxx -		xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 	xxxxxxxxxxxxxxxx  	999999	        99,99			 999.999,99		     99/99/9999
	//Total do Funcionário
	//_____________________________________________________________________________________________________________________________________
	//																																			 999.999,99
	//
	//Total do Centro de Custo
	//_____________________________________________________________________________________________________________________________________
	//																																		999.999.999,99
	//
	//Total Geral
	//_____________________________________________________________________________________________________________________________________
	//																																		999.999.999,99

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao do componente de impressao                                      ³
	//³                                                                        ³
	//³TReport():New                                                           ³
	//³ExpC1 : Nome do relatorio                                               ³
	//³ExpC2 : Titulo                                                          ³
	//³ExpC3 : Pergunte                                                        ³
	//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
	//³ExpC5 : Descricao                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := TReport():New("MNTR020",OemToAnsi(STR0001),"MNT020",{|oReport| ReportPrint(oReport)},STR0001+STR0002) //"Custo da Mao-de-Obra de Terceiros"###"Custo da Mao-de-Obra de Terceiros"###"."

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
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:SetTotalInLine(.F.) //Definicao para nao imprimir descricao do campo no total geral, apenas a soma do campo
	oSection1 := TRSection():New(oReport,STR0010,{(cTRBTEMP),"SI3","ST1","STL","STJ","STS","STT"}) //"Centro de Custo"
	TRCell():New(oSection1,"(cTRBTEMP)->CCUSTO"     ,(cTRBTEMP) ,STR0010,/*Picture*/) //"Centro de Custo"
	TRCell():New(oSection1,"I3_DESC"    ,"SI3",""  ,/*Picture*/,/*Tamanho*/)
	TRPosition():New(oSection1,"SI3",1,{|| xFilial("SI3")+(cTRBTEMP)->CCUSTO})

	oSection2 := TRSection():New(oReport,STR0011,{(cTRBTEMP),"ST1","SI3","STL","STJ","STS","STT"}) //"Ordens de Servico"
	oSection2:SetHeaderBreak() // sempre que houver quebra imprime o cabeçalho da seção
	oCell := TRCell():New(oSection2,"(cTRBTEMP)->CODFUNC"  ,(cTRBTEMP) ,STR0012 ,"@!"       ,12,/*lPixel*/,/*{|| code-block de impressao }*/) //"Matricula"
	oCell := TRCell():New(oSection2,"T1_NOME"  			  ,"ST1"       ,STR0013 ,"@!"       ,35,/*lPixel*/,/*{|| code-block de impressao }*/) //"Nome"
	oCell := TRCell():New(oSection2,"(cTRBTEMP)->BEM"      ,(cTRBTEMP) ,STR0014 ,"@!"       ,20,/*lPixel*/,/*{|| code-block de impressao }*/) //"Bem"
	oCell := TRCell():New(oSection2,"(cTRBTEMP)->OS"       ,(cTRBTEMP) ,STR0015 ,"@!"       ,15,/*lPixel*/,/*{|| code-block de impressao }*/) //"O.S."
	oCell := TRCell():New(oSection2,"(cTRBTEMP)->QTDEHSEX" ,(cTRBTEMP) ,STR0016 ,"@!"       ,15,/*lPixel*/,/*{|| code-block de impressao }*/) //"Qtde Horas"
	oCell := TRCell():New(oSection2,"(cTRBTEMP)->VALOR"    ,(cTRBTEMP) ,STR0017 ,"@E 999,999.99",15,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor"
	oCell := TRCell():New(oSection2,"(cTRBTEMP)->DTAPONT"  ,(cTRBTEMP) ,STR0018 ,"@!"       ,10,/*lPixel*/,/*{|| code-block de impressao }*/) //"Dt. Apont."
	//Definicao para imprimir os cabecalhos de campos numericos da esquerda para a direita
	oSection2:Cell("(cTRBTEMP)->VALOR"):SetHeaderAlign("RIGHT")
	TRPosition():New(oSection2,"ST1",1,{|| xFilial("ST1")+(cTRBTEMP)->CODFUNC})

	oBreak1 := TRBreak():New(oSection1,".T.",STR0019,.F.) //"Total do Centro de Custo"
	TRFunction():New(oSection2:Cell("(cTRBTEMP)->VALOR"),/*cId*/,"SUM",oBreak1,/*cTitle*/,"@E 999,999.99",/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/,/*oSection1*/)

	oBreak2 := TRBreak():New(oSection2,".T.",STR0020,.F.) //"Total do Funcionario"
	TRFunction():New(oSection2:Cell("(cTRBTEMP)->VALOR"),/*cId*/,"SUM",oBreak2,/*cTitle*/,"@E 999,999.99",/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/,/*oSection1*/)

	oTotaliz := TRFunction():New(oSection2:Cell("(cTRBTEMP)->VALOR"),"TOTGCUST","SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)

Return oReport


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MNTR020R4 ³ Autor ³ Felipe N. Welter     ³ Data ³ 14/03/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio "Custo de mao-de-obra de Terceiros"              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTR020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function MNTR020R4()

	Local  WNREL     := "MNTR020R4"
	Local  LIMITE    := 132
	Local  cdesc1    := STR0021 //"Relatório de Custo da Mão-de-Obra de Terceiros."
	Local  cdesc2    := ""
	Local  cdesc3    := ""
	Local  cSTRING   := "ST1"

	Private NOMEPROG  := "MNTR020"
	Private TAMANHO   := "M"
	Private aRETURN   := {STR0022,1,STR0023,1,2,1,"",1} //"Zebrado"###"Administracao"
	Private nTIPO     := 0
	Private nLASTKEY  := 0
	Private Titulo    := STR0001 //"Custo da Mao-de-Obra de Terceiros"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                       			   ³
	//³ mv_par01     // De Centro de Custo                           				³
	//³ mv_par02     // Ate Centro de Custo                    			         ³
	//³ mv_par03     // De Funcionario                            				   ³
	//³ mv_par04     // Ate Funcionario                     				         ³
	//³ mv_par05     // De Data de Fechamento da O.S.          				      ³
	//³ mv_par06     // Ate Data de Fechamento da O.S.	         				   ³
	//| mv_par07     // Imprimir Localizacao ?  Sim/Nao                        |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private cPERG := "MNT020"

	Pergunte(cPERG,.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	WNREL:=SetPrint(cSTRING,WNREL,cPERG,TITULO,cDESC1,cDESC2,cDESC3,.F.,"")
	If nLASTKEY = 27
		Set Filter To
		dbSelectArea("ST1")
		Return
	EndIf
	SetDefault(aRETURN,cSTRING)
	RptStatus({|lEND|MNTR020Imp(@lEND,WNREL,TITULO,TAMANHO)},TITULO)
	dbSelectArea("ST1")

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNTR020Imp ³ Autor ³ Felipe N. Welter     ³ Data ³ 14/03/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Chamada do Relat¢rio                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR020                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNTR020Imp(lEND,WNREL,TITULO,TAMANHO)


	Local aVetHoras	 := Array(3)
	Local aEstrut	 := {}
	Local cRODATXT	 := "",xx
	Local cCodFunc, cCCusto
	Local cCODFUN
	Local cEstrut	 := ""
	Local nTotValFun := nTotValCTT := nTotValGer := 0
	Local nCont		 := 0
	Local nCNTIMPR	 := 0
	Local lImpCC	 := lImpFunc := lCriouTab := .F.
	Local oArqR020

	Private nomeprog := "MNTR020"

	Private aVETINR := {}
	//+--------------------------------------------+
	//| Variaveis locais exclusivas deste programa |
	//+--------------------------------------------+

	Private cUltimoReg, cCondicao, nAtual
	//+--------------------------------------------+
	//| Contadores de linha e pagina               |
	//+--------------------------------------------+
	Private li := 80 ,m_pag := 1
	//+--------------------------------------------+
	//| Verifica se deve comprimir ou nao          |
	//+--------------------------------------------+
	nTIPO  := IIF(aRETURN[4]==1,15,18)
	//+--------------------------------------------+
	//| Monta os Cabecalhos                        |
	//+--------------------------------------------+
	Private Cabec1   := " "
	Private Cabec2   := " "

	//+--------------------------------------------+
	//| Monta os Cabecalhos                        |
	//+--------------------------------------------+
	//          1         2         3         4         5         6         7         8         9         0         1         2         3
	//0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
	//Centro de Custo: xxxxxxxxx - xxxxxxxxxxxxxxxxxxxxxx
	//Funcionario  Nome                                   Bem                  O.S.        Qtde Horas              Valor         Dt.Apont.
	//-------------------------------------------------------------------------------------------------------------------------------------
	//xxxxxx -		xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 	xxxxxxxxxxxxxxxx  	999999		     99,99			 999.999,99		     99/99/9999
	//xxxxxx -		xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 	xxxxxxxxxxxxxxxx  	999999		     99,99			 999.999,99			  99/99/9999
	//Total do Funcionário																												 999.999,99
	//
	//Funcionario  Nome                                   Bem                  O.S.        Qtde Horas              Valor         Dt.Apont.
	//-------------------------------------------------------------------------------------------------------------------------------------
	//xxxxxx -		xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 	xxxxxxxxxxxxxxxx  	999999		     99,99			 999.999,99		     99/99/9999
	//xxxxxx -		xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 	xxxxxxxxxxxxxxxx  	999999	        99,99			 999.999,99		     99/99/9999
	//Total do Funcionário                                                                                    999.999,99
	//
	//Total do Centro de Custo                                                                            999.999.999,99
	//Total Geral                                                                                         999.999.999,99

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria array com os campos para tabela com Alias TRBTEMP									 			  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	aDBFR020 := {{"CCUSTO"  , "C", Len(STJ->TJ_CCUSTO),0},;
				 {"CODFUNC" , "C", 06, 0},;
				 {"BEM"     , "C", 16, 0},;
				 {"OS"      , "C", 06, 0},;
				 {"QTDEH"   , "N", 09, 2},;
				 {"QTDEHSEX", "C", 05, 0},;
				 {"VALOR"   , "N", 10, 2},;
				 {"DTAPONT" , "D", 08, 0}}

	//Cria Tabela Temporária
	oArqR020 := NGFwTmpTbl(cTRBTEMP,aDBFR020,{{"CCUSTO","CODFUNC","OS","DTAPONT"}})

	Processa({|lEND| MNTR020TRB()},STR0024) //"Processando as Ordens de Servico..."

	lTemReg := .F.
	lImpPri := .T.
	dbSelectArea(cTRBTEMP)
	dbGoTop()
	If Reccount() > 0
		lTemReg := .T.
	EndIf
	SetRegua(RecCount())
	While !Eof()

		If lImpPri
			lImpPri := .F.
			NGSomaLi(58)
		EndIf

		cCCusto := (cTRBTEMP)->CCUSTO
		@ Li, 000 Psay STR0025+Alltrim((cTRBTEMP)->CCUSTO)+STR0026+NGSeek("SI3",(cTRBTEMP)->CCUSTO,	1,"I3_DESC") //"Centro de Custo: "###" - "
		NGSomaLi(58)

		dbSelectArea(cTRBTEMP)
		While !Eof() .And. (cTRBTEMP)->CCUSTO == cCCusto

			cCodFunc := (cTRBTEMP)->CODFUNC
			@ Li, 000 Psay STR0027 //"Matricula    Nome                                   Bem                  O.S.        Qtde Horas              Valor        Dt.Apont."
			NGSomaLi(58)
			@ LI, 000 Psay Replicate("-",132)
			NGSomaLi(58)
			@ Li, 000 Psay (cTRBTEMP)->CODFUNC
			@ Li, 013 Psay NGSeek("ST1",(cTRBTEMP)->CODFUNC,1,"SubStr(T1_NOME,1,35)")

			dbSelectArea(cTRBTEMP)
			While !Eof() .And. (cTRBTEMP)->CCUSTO == cCCusto .And. (cTRBTEMP)->CODFUNC == cCodFunc

				IncRegua()
				@ Li, 052 PSay (cTRBTEMP)->BEM
				@ Li, 073 PSay (cTRBTEMP)->OS
				@ Li, 090 Psay (cTRBTEMP)->QTDEHSEX
				@ Li, 104 Psay (cTRBTEMP)->VALOR Picture "@E 999,999.99"
				@ Li, 122 PSay (cTRBTEMP)->DTAPONT Picture "99/99/9999"
				NGSomaLi(58)
				nTotValFun += (cTRBTEMP)->VALOR

				If MV_PAR07 == 1
					cEstrut := NGLocComp((cTRBTEMP)->BEM,"1")
					aEstrut := {}
					If Len(cEstrut) > 80
						aAdd(aEstrut,AllTrim(SubStr(cEstrut,1,80)))
						cEstrut := AllTrim(SubStr(cEstrut,81))
						While Len(cEstrut) > 80
							aAdd(aEstrut,AllTrim(SubStr(cEstrut,1,80)))
							cEstrut := AllTrim(SubStr(cEstrut,81))
						End
						aAdd(aEstrut,AllTrim(cEstrut))
					EndIf

					If Len(aEstrut) > 0
						For nCont := 1 To Len(aEstrut)
							If nCont == 1
								@ Li,013 PSay STR0030 + aEstrut[nCont] //"Localização: "
							Else
								@ Li,013 PSay Space(Len(STR0030)) + aEstrut[nCont] //"Localização: "
							EndIf
							NGSomaLi(58)
						Next nCont
					Else
						If AllTrim((cTRBTEMP)->BEM) <> AllTrim(cEstrut)
							@ Li,013 PSay STR0030 + cEstrut //"Localização do Bem: "
						Else
							@ Li,013 PSay STR0030 + STR0031 //"Localização do Bem: "###"Não está relacionado a uma Estrutura."
						EndIf
						NGSomaLi(58)
					EndIf
				EndIf

				dbSelectArea(cTRBTEMP)
				dbSkip()

			End

			@ Li, 000 Psay STR0028 //"Total do Funcionário"
			@ Li, 104 Psay nTotValFun Picture "@E 999,999.99"
			NGSomaLi(58)
			NGSomaLi(58)
			nTotValCTT += nTotValFun
			nTotValFun := 0

		End

		@ Li, 000 Psay STR0019 //"Total do Centro de Custo"
		@ Li, 100 PSay nTotValCTT Picture "@E 999,999,999.99"
		NGSomaLi(58)
		NGSomaLi(58)
		NGSomaLi(58)
		nTotValGer += nTotValCTT
		nTotValCTT := 0

	End

	If lTemReg
		@ Li, 000 Psay STR0029 //"Total Geral"
		@ Li, 100 Psay nTotValGer Picture  "@E 999,999,999.99"
	EndIf

	RODA(nCNTIMPR,cRODATXT,TAMANHO)
	//+----------------------------+
	//| Apaga arquivo de Trabalho  |
	//+----------------------------+
	RetIndex("ST1")
	RetIndex("STL")
	RetIndex("STJ")
	RetIndex("STT")
	RetIndex("STS")

	Set Device To Screen
	If aRETURN[5] == 1
		Set Printer To
		dbCommitAll()
		OurSpool(WNREL)
	EndIf
	MS_FLUSH()

	//Deleta o arquivo temporario fisicamente
	oArqR020:delete()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ReportPrint³ Autor ³ Felipe N. Welter      ³ Data ³ 14/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Chamada do Relat¢rio                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ReportDef                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport)

	Local oArqR020
	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)
	Local cEstrut   := ""
	Local cImpEst   := ""
	Local aEstrut   := {}
	Local nCont     := 0
	Local nImpLin   := 0
	Local nInpCol   := 0


	Private aVETINR := {}

	aDBFR020 := {{"CCUSTO"  , "C",	Len(STJ->TJ_CCUSTO) ,0}	,;
				 {"CODFUNC" , "C", 	06,0}	,;
				 {"BEM"     , "C", 	16,0}	,;
				 {"OS"      , "C", 	06,0}	,;
				 {"QTDEH"   , "N", 	09,2}	,;
				 {"QTDEHSEX", "C",	05,0}	,;
				 {"VALOR"   , "N",	10,2}	,;
				 {"DTAPONT" , "D",	08,0}}

	//Cria Tabela Temporária
	oArqR020 := NGFwTmpTbl((cTRBTEMP),aDBFR020,{{"CCUSTO","CODFUNC","OS","DTAPONT"}})

	Processa({|lEND| MNTR020TRB()},STR0024) //"Processando as Ordens de Servico..."

	dbselectarea(cTRBTEMP)
	dbGotop()
	oReport:SetMeter(RecCount())
	While !Eof() .And. !oReport:Cancel()

		cCCusto := (cTRBTEMP)->CCUSTO

		oSection1:Init()
		oSection1:PrintLine()

		While !Eof() .And. !oReport:Cancel() .And. (cTRBTEMP)->CCUSTO == cCCusto

			cCodFunc := (cTRBTEMP)->CODFUNC
			lPriFunc := .T.

			oSection2:Init()

			While !Eof() .And. !oReport:Cancel() .And. (cTRBTEMP)->CCUSTO == cCCusto .And.;
			(cTRBTEMP)->CODFUNC == cCodFunc

				oReport:IncMeter()
				If lPriFunc
					lPriFunc := .F.
					oSection2:Cell("(cTRBTEMP)->CODFUNC"):Show()
					oSection2:Cell("T1_NOME"):Show()
				Else
					oSection2:Cell("(cTRBTEMP)->CODFUNC"):Hide()
					oSection2:Cell("T1_NOME"):Hide()
				EndIf
				oSection2:PrintLine()

				If MV_PAR07 == 1
					cEstrut := NGLocComp((cTRBTEMP)->BEM,"1")
					aEstrut := {}
					If Len(cEstrut) > 80
						aAdd(aEstrut,AllTrim(SubStr(cEstrut,1,80)))
						cEstrut := AllTrim(SubStr(cEstrut,81))
						While Len(cEstrut) > 80
							aAdd(aEstrut,AllTrim(SubStr(cEstrut,1,80)))
							cEstrut := AllTrim(SubStr(cEstrut,81))
						End
						aAdd(aEstrut,AllTrim(cEstrut))
					EndIf

					nImpCol := oSection2:Cell("T1_NOME"):Col()
					If Len(aEstrut) > 0
						For nCont := 1 To Len(aEstrut)
							If nCont == 1
								cImpEst := STR0030 + aEstrut[nCont] //"Localização do Bem: "
							Else
								cImpEst := Space(Len(STR0030)) + aEstrut[nCont] //"Localização do Bem: "
							EndIf
							nImpLin := oReport:Row()
							oReport:PrintText(cImpEst,nImpLin,nImpCol)
							oReport:SkipLine()
						Next nCont
					Else
						If AllTrim((cTRBTEMP)->BEM) <> AllTrim(cEstrut)
							cImpEst := STR0030 + cEstrut //"Localização do Bem: "
						Else
							cImpEst := STR0030 + STR0031 //"Localização do Bem: "###"Não está relacionado a uma Estrutura."
						EndIf
						nImpLin := oReport:Row()
						oReport:PrintText(cImpEst,nImpLin,nImpCol)
						oReport:SkipLine()
					EndIf
				EndIf

				dbSelectArea(cTRBTEMP)
				dbSkip()

			End
			oSection2:Finish()
		End
		oSection1:Finish()
	End

	//Deleta o arquivo temporario fisicamente
	oArqR020:Delete()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNTR020TRB³ Autor ³ Felipe N. Welter      ³ Data ³14/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Processa os arquivos e carrega arquivo temporario           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR020                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNTR020TRB()

	Local nTotValFun := nTotValCTT := nTotValGer := 0

	dbSelectArea("ST1")
	dbSetOrder(1)
	dbSeek(xFilial("ST1")+MV_PAR03,.T.)
	ProcRegua(RecCount())
	While !Eof() .And. ST1->T1_FILIAL == xFilial("ST1") .And.;
	ST1->T1_CODFUNC <= MV_PAR04

		IncProc()

		If Empty(ST1->T1_CONTRAT)  //Significa que a mao-de-obra (funcionario) nao e de terceiro / sem contrato
			dbSkip()
			Loop
		EndIf

		cCODFUN := ST1->T1_CODFUNC + Replicate(' ',Len(STL->TL_CODIGO)-Len(ST1->T1_CODFUNC))  //Tamanho (15-6)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicia a verificacao das tabelas STL e STJ																  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("STL")
		dbSetOrder(8)
		dbSeek(xFilial("STL")+"M"+cCODFUN)  //Filial + Tipo de Insumo (Mao de Obra) + Codigo do Insumo
		While !Eof() .And. STL->TL_FILIAL == xFilial("STL") .And. STL->TL_TIPOREG == "M" .And. ;
		STL->TL_CODIGO == cCODFUN

			If Alltrim(STL->TL_SEQRELA) <> "0" //Insumo realizado

				dbSelectArea("STJ")
				dbSetOrder(1)
				If !dbSeek(xFilial("STJ")+STL->TL_ORDEM+STL->TL_PLANO)
					dbSelectArea("STL")
					dbSkip()
					Loop
				EndIf

				If STJ->TJ_SITUACA <> "L" .Or. STJ->TJ_TERMINO <> "S"       //TJ_SITUACA $ "C(ancelado)L(iberado)P(endente)" // TJ_TERMINO $ "S(im)N(ao)"
					dbSelectArea("STL")
					dbSkip()
					Loop
				EndIf

				If STJ->TJ_CCUSTO < MV_PAR01 .Or. STJ->TJ_CCUSTO > MV_PAR02       //Centro de Custo vem automaticamente do BEM
					dbSelectArea("STL")
					dbSkip()
					Loop
				EndIf

				If STJ->TJ_DTMRFIM < MV_PAR05 .Or. STJ->TJ_DTMRFIM > MV_PAR06
					dbSelectArea("STL")
					dbSkip()
					Loop
				EndIf

				dbSelectArea(cTRBTEMP)
				If !dbSeek(STJ->TJ_CCUSTO+ST1->T1_CODFUNC+STJ->TJ_ORDEM+Dtos(STL->TL_DTINICI))
					(cTRBTEMP)->(dbAppend())
					(cTRBTEMP)->CCUSTO  := STJ->TJ_CCUSTO
					(cTRBTEMP)->CODFUNC := ST1->T1_CODFUNC
					(cTRBTEMP)->BEM     := STJ->TJ_CODBEM
					(cTRBTEMP)->OS      := STJ->TJ_ORDEM
					(cTRBTEMP)->QTDEH   := STL->TL_QUANTID
					aVetHoras := NGTQUATINS(STL->TL_CODIGO,STL->TL_TIPOREG,STL->TL_USACALE,STL->TL_QUANTID,STL->TL_TIPOHOR,STL->TL_DTINICI,;
					STL->TL_HOINICI,STL->TL_DTFIM,STL->TL_HOFIM,STL->TL_UNIDADE)
					(cTRBTEMP)->QTDEHSEX := aVetHoras[3]
					(cTRBTEMP)->VALOR    := ST1->T1_SALARIO * aVetHoras[1]
					(cTRBTEMP)->DTAPONT  := STL->TL_DTINICI
				Else
					aVetHoras := NGTQUATINS(STL->TL_CODIGO,STL->TL_TIPOREG,STL->TL_USACALE,STL->TL_QUANTID,STL->TL_TIPOHOR,STL->TL_DTINICI,;
					STL->TL_HOINICI,STL->TL_DTFIM,STL->TL_HOFIM,STL->TL_UNIDADE)
					(cTRBTEMP)->QTDEHSEX := NGSOMAHCAR((cTRBTEMP)->QTDEHSEX,aVetHoras[3])
					(cTRBTEMP)->VALOR    := (cTRBTEMP)->VALOR + (ST1->T1_SALARIO * aVetHoras[1])
				EndIf
			EndIf
			dbSelectArea("STL")
			dbSkip()
		End

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Finaliza a verificacao das tabelas STL e STJ 															  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicia a verificacao das tabelas STT e STS																  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("STT")
		dbSetOrder(3)
		dbSeek(xFilial("STT")+"M"+cCODFUN)  //Filial + Tipo de Insumo (Mao de Obra) + Codigo do Insumo
		While !Eof() .And. STT->TT_FILIAL == xFilial("STT") .And. STT->TT_TIPOREG == "M" .And. ;
		STT->TT_CODIGO = cCODFUN

			If Alltrim(STT->TT_SEQRELA) <> "0" //Insumo realizado

				dbSelectArea("STS")
				dbSetOrder(1)
				If !dbSeek(xFilial("STS")+STT->TT_ORDEM+STT->TT_PLANO)
					dbSelectArea("STT")
					dbSkip()
					Loop
				EndIf

				If STS->TS_SITUACA <> "L" .Or. STS->TS_TERMINO <> "S"
					dbSelectArea("STT")
					dbSkip()
					Loop
				EndIf

				If STS->TS_CCUSTO < MV_PAR01 .Or. STS->TS_CCUSTO > MV_PAR02
					dbSelectArea("STT")
					dbSkip()
					Loop
				EndIf

				If STS->TS_DTMRFIM < MV_PAR05 .Or. STS->TS_DTMRFIM > MV_PAR06
					dbSelectArea("STT")
					dbSkip()
					Loop
				EndIf

				dbSelectArea(cTRBTEMP)
				If !dbSeek(STS->TS_CCUSTO+ST1->T1_CODFUNC+STS->TS_ORDEM+Dtos(STT->TT_DTINICI))
					(cTRBTEMP)->(dbAppend())
					(cTRBTEMP)->CCUSTO := STS->TS_CCUSTO
					(cTRBTEMP)->CODFUNC := ST1->T1_CODFUNC
					(cTRBTEMP)->BEM := STS->TS_CODBEM
					(cTRBTEMP)->OS := STS->TS_ORDEM
					(cTRBTEMP)->QTDEH := STT->TT_QUANTID
					aVetHoras := NGTQUATINS(STT->TT_CODIGO,STT->TT_TIPOREG,STT->TT_USACALE,STT->TT_QUANTID,STT->TT_TIPOHOR,STT->TT_DTINICI,;
					STT->TT_HOINICI,STT->TT_DTFIM,STT->TT_HOFIM,STT->TT_UNIDADE)
					(cTRBTEMP)->QTDEHSEX := aVetHoras[3]
					(cTRBTEMP)->VALOR := ST1->T1_SALARIO * aVetHoras[1]  // <> STT->TT_CUSTO
					(cTRBTEMP)->DTAPONT := STT->TT_DTINICI
				Else
					aVetHoras := NGTQUATINS(STT->TT_CODIGO,STT->TT_TIPOREG,STT->TT_USACALE,STT->TT_QUANTID,STT->TT_TIPOHOR,STT->TT_DTINICI,;
					STT->TT_HOINICI,STT->TT_DTFIM,STT->TT_HOFIM,STT->TT_UNIDADE)
					(cTRBTEMP)->QTDEHSEX := NGSOMAHCAR((cTRBTEMP)->QTDEHSEX,aVetHoras[3])
					(cTRBTEMP)->VALOR    := (cTRBTEMP)->VALOR + (ST1->T1_SALARIO * aVetHoras[1])
				EndIf


			EndIf
			dbSelectArea("STT")
			dbSkip()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza a verificacao das tabelas STT e STS										  					  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		End
		dbSelectArea("ST1")
		dbSkip()
	End


Return