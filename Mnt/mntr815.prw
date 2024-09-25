#INCLUDE "mntr815.ch"
#Include "Protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MNTR815  ³ Autor ³ Ricardo Dal Ponte     ³ Data ³ 13/09/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio de Bens por Irregularidades                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MNTR815()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTR815()

	//+---------------------------------------------+
	//| Guarda conteudo e declara variaveis padroes |
	//+---------------------------------------------+
	Local aNGBEGINPRM := NGBEGINPRM()
	Local oReport
	Local aArea := GetArea()

	Private aVETINR := {}
	Private cF3CTTSI3 := If(CtbInUse(), "CTT", "SI3")
	Private nSizeSI3 := If((TAMSX3("I3_CUSTO")[1]) < 1,9,(TAMSX3("I3_CUSTO")[1]))
	//TABELA TEMPORARIA
	Private cTRB	:= GetNextAlias()
	Private oTempTable

	/*---------------------------------------------------------------
	Vetor utilizado para armazenar retorno da função MNTTRBSTB,
	criada de acordo com o item 18 (RoadMap 2013/14)
	---------------------------------------------------------------*/
	Private vFilTRB := MNT045TRB()

	SetKey(VK_F4, {|| MNT045FIL( vFilTRB[2] )})

	//checa se parametro de irregularidade "MV_NGTNDFL" esta habilidado
	If !NGCHKIRREG()
		Return .T.
	EndIf

	If FindFunction("TRepInUse") .And. TRepInUse()
		//-- Interface de impressao
		oReport := ReportDef()
		oReport:SetPortrait()
		oReport:PrintDialog()
	Else
		MNTR815R3()
	EndIf

	MNT045TRB( .T., vFilTRB[1], vFilTRB[2])

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retorna conteudo de variaveis padroes       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	NGRETURNPRM(aNGBEGINPRM)

	RestArea(aArea)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ReportDef ³ Autor ³ Ricardo Dal Ponte     ³ Data ³13/09/2006³±±
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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros das perguntas           ³
	//³ mv_par01     // De  Centro de Custos                         ³
	//³ mv_par02     // Ate Centro de Custos                         ³
	//³ mv_par03     // De Centro de Trabalho                        ³
	//³ mv_par04     // Ate Centro de Trabalho                       ³
	//³ mv_par05     // De Familia de Bem                            ³
	//³ mv_par06     // Ate Familia de Bem                           ³
	//³ mv_par07     // De  Bem                                      ³
	//³ mv_par08     // Ate Bem                                      ³
	//³ mv_par09     // De Periodo                                   ³
	//³ mv_par10     // Ate Periodo                                  ³
	//³ mv_par11     // De Irregularidade                            ³
	//³ mv_par12     // Ate Irregularidade                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

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

	oReport := TReport():New("MNTR815",OemToAnsi(STR0001),"MNT815",{|oReport| ReportPrint(oReport)},STR0003+" "+STR0004) //"Bens por Irregularidades"###"Destina-se a imprimir as ocorrencias de Irregularidades dos Bens"###"nas Ordem de Serviço Corretivas."

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

	oSection1 := TRSection():New(oReport, STR0018,{(cTRB), cF3CTTSI3, "SHB", "ST6"})//"Ordem de Servico"

	TRCell():New(oSection1,"(cTRB)->CCUSTO"  ,(cTRB),STR0005	,"@!" ,nSizeSI3, /*lPixel*/,/*{|| code-block de impressao }*/) //"C.Custo"
	TRCell():New(oSection1,"(cTRB)->NCUSTO"  ,(cTRB),STR0006	,"@!" ,30,/*lPixel*/,/*{|| code-block de impressao }*/) //"Descrição"
	TRCell():New(oSection1,""	            ,""   ,""      ,"@!"	,2   ,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"(cTRB)->CENTRAB" ,(cTRB),STR0007	,"@!" ,6,/*lPixel*/,/*{|| code-block de impressao }*/) //"C. Trab."
	TRCell():New(oSection1,"(cTRB)->NOMTRAB" ,(cTRB),STR0006	,"@!" ,30,/*lPixel*/,/*{|| code-block de impressao }*/) //"Descrição"
	TRCell():New(oSection1,""	            ,""   ,""      ,"@!"	,2   ,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"(cTRB)->CODFAMI" ,(cTRB),STR0008 ,"@!" ,6,/*lPixel*/,/*{|| code-block de impressao }*/) //"Familia"
	TRCell():New(oSection1,"(cTRB)->NOMFAMI"	,"SI3",STR0006	,"@!" ,30,/*lPixel*/,/*{|| code-block de impressao }*/) //"Descrição"

	If cF3CTTSI3 = "CTT"
		TRPosition():New(oSection1,"CTT",1,{|| xFilial("CTT")+(cTRB)->CCUSTO})
	EndIf

	If cF3CTTSI3 = "SI3"
		TRPosition():New(oSection1,"SI3",1,{|| xFilial("SI3")+(cTRB)->CCUSTO})
	EndIf

	TRPosition():New(oSection1,"SHB",1,{|| xFilial("SHB")+(cTRB)->CENTRAB})
	TRPosition():New(oSection1,"ST6",1,{|| xFilial("ST6")+(cTRB)->CODFAMI})

	oSection2 := TRSection():New(oReport,STR0011,{(cTRB), "ST9", "TP7"})

	oCell := TRCell():New(oSection2,""	            ,""    ,""       ,"@!" 	,5   ,/*lPixel*/,/*{|| code-block de impressao }*/)
	oCell := TRCell():New(oSection2,"(cTRB)->CODBEM"	,(cTRB) ,STR0009  ,"@!" 	,16   ,/*lPixel*/,/*{|| code-block de impressao }*/) //"Bem"
	oCell := TRCell():New(oSection2,"(cTRB)->NOMBEM" 	,(cTRB) ,STR0006  ,"@!" 	,40  ,/*lPixel*/,/*{|| code-block de impressao }*/) //"Descrição"
	oCell := TRCell():New(oSection2,"(cTRB)->CODIRE"	,(cTRB) ,STR0011  ,"@!"  ,15  ,/*lPixel*/,/*{|| code-block de impressao }*/) //"Irregularidade"
	oCell := TRCell():New(oSection2,"(cTRB)->NOMIRE"	,(cTRB) ,STR0006  ,"@!"  ,40  ,/*lPixel*/,/*{|| code-block de impressao }*/) //"Descrição"
	oCell := TRCell():New(oSection2,"(cTRB)->QUANTI"	,(cTRB) ,STR0012  ,"@!"  ,15  ,/*lPixel*/,/*{|| code-block de impressao }*/) //"Quant. Ocorr."
	oSection2:Cell("(cTRB)->QUANTI"):SetHeaderAlign("RIGHT")

	TRPosition():New(oSection2,"ST9",1,{|| xFilial("ST9")+(cTRB)->CODBEM})
	TRPosition():New(oSection2,"TP7",1,{|| xFilial("TP7")+(cTRB)->CODIRE})

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

	// Verifica se foi executado update de características (Item 18)
	Private cOBS

	//Retira filtro de características da opção F4
	SetKey(VK_F4, {|| })
	Processa({|lEND| MNTR815TRB()},STR0013) //"Processando Arquivo..."

	dbSelectArea(cTRB)
	dbsetOrder(02)
	dbGoTop()

	oReport:cTitle := STR0001  + " - " + STR0015 + ": " + DTOC(MV_PAR09) + " " + STR0016 + ": " + DTOC(MV_PAR10) //de### //ate
	oReport:SetMeter(RecCount())
	While !Eof() .And. !oReport:Cancel()

		//FILTRA CENTRO DE CUSTO
		If (cTRB)->CCUSTO < MV_PAR01 .Or. (cTRB)->CCUSTO > MV_PAR02
			DbSkip()
			Loop
		EndIf

		//FILTRA CENTRO DE TRABALHO
		If (cTRB)->CENTRAB < MV_PAR03 .Or. (cTRB)->CENTRAB > MV_PAR04
			DbSkip()
			Loop
		EndIf

		//FILTRA FAMILIA DO BEM
		If (cTRB)->CODFAMI < MV_PAR05 .Or. (cTRB)->CODFAMI > MV_PAR06
			DbSkip()
			Loop
		EndIf

		//FILTRA BEM
		If (cTRB)->CODBEM < MV_PAR07 .Or. (cTRB)->CODBEM > MV_PAR08
			DbSkip()
			Loop
		EndIf

		//FILTRA IRREGULARIDADE
		If (cTRB)->CODIRE < MV_PAR11 .Or. (cTRB)->CODIRE > MV_PAR12
			DbSkip()
			Loop
		EndIf

		If MNT045STB( (cTRB)->CODBEM, vFilTRB[2] )
			dbSkip()
			Loop
		EndIf

		oReport:IncMeter()

		//QUEBRA POR CENTRO DE CUSTO
		If cCUSTO <> (cTRB)->CCUSTO
			cCUSTO    := (cTRB)->CCUSTO
			cTRABALHO := (cTRB)->CENTRAB
			cFAMILIA  := (cTRB)->CODFAMI

			oSection2:Finish()

			oSection1:Init()
			oSection1:PrintLine()
			oSection1:Finish()

			oSection2:Init()
		EndIf

		//QUEBRA POR CENTRO DE TRABALHO
		If cTRABALHO  <> (cTRB)->CENTRAB
			cTRABALHO := (cTRB)->CENTRAB
			cFAMILIA  := (cTRB)->CODFAMI

			oSection2:Finish()

			oSection1:Init()
			oSection1:PrintLine()
			oSection1:Finish()

			oSection2:Init()
		EndIf

		//QUEBRA POR FAMILIA DE BEM
		If cFAMILIA  <> (cTRB)->CODFAMI
			cFAMILIA   := (cTRB)->CODFAMI

			oSection2:Finish()

			oSection1:Init()
			oSection1:PrintLine()
			oSection1:Finish()

			oSection2:Init()
		EndIf

		//IMPRESSAO DO DETALHE DO BEM/IRREGULARIDADE
		oSection2:PrintLine()

		dbSkip()
	EndDo

	oSection2:Finish()

	If Type("oTempTable") == "O"
		oTempTable:Delete()//Deleta Tabela temporario
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MNTR815TRBºAutor  ³ Ricardo Dal Ponte  º Data ³  04/09/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ GERACAO DE ARQUIVO TEMPORARIO                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAMNT                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function MNTR815TRB()

	Local aDBF, cIndR001, cIndR002
	Local nAlerta
	Local dDtLimit1, dDtLimit2
	Local cFilter1 := ""
	Local cFilter2 := ""

	//criacao arquivo temporario
	//----------------------------------------
	aDBF := {{"CODBEM" , "C", 16, 0},;
	{"NOMBEM" , "C", 40, 0},;
	{"CODIRE" , "C", 03, 0},;
	{"NOMIRE" , "C", 40, 0},;
	{"CCUSTO" , "C", nSizeSI3,0},;
	{"NCUSTO" , "C", 40, 0},;
	{"CENTRAB", "C", 06, 0},;
	{"NOMTRAB", "C", 40, 0},;
	{"CODFAMI", "C", 06, 0},;
	{"NOMFAMI", "C", 40, 0},;
	{"DTLIMT" , "D", 08, 0},;
	{"QTDALE" , "N", 08, 0},;
	{"QUANTI" , "N", 08, 0}}

	//Intancia classe FWTemporaryTable
	oTempTable	:= FWTemporaryTable():New( cTRB, aDBF )
	//Cria indices
	oTempTable:AddIndex( "Ind01" , {"CODBEM","CODIRE"}  )
	oTempTable:AddIndex( "Ind02" , {"CCUSTO","CENTRAB","CODFAMI","CODBEM","CODIRE"} )
	//Cria a tabela temporaria
	oTempTable:Create()

	nAlerta:=GetMv("MV_NGALERT")
	dDtLimit1 := dDataBase - nAlerta

	IF dDtLimit1 = dDataBase
		Return .F.
	EndIf

	//GERACAO PARA ARQUIVO DE ORDEM DE SERVICO
	DbSelectArea("STJ")

	cFilter1 := "STJ->TJ_FILIAL = '"+xFILIAL("STJ")+"' .And. STJ->TJ_PLANO = '000000' .And. "
	cFilter1 += "STJ->TJ_TERMINO = 'S' .And. STJ->TJ_IRREGU <> '"+Space(Len(STJ->TJ_IRREGU))+"' .And. "
	cFilter1 += "(DTOS(STJ->TJ_DTMRFIM) >= "+ValToSql(dDtLimit1)+" .And. DTOS(STJ->TJ_DTMRFIM) <= "+ValToSql(dDataBase)+") .And. "
	cFilter1 += "(DTOS(STJ->TJ_DTMRFIM) >= "+ValToSql(MV_PAR09)+"  .And. DTOS(STJ->TJ_DTMRFIM) <= "+ValToSql(MV_PAR10)+")"

	SET FILTER TO &cFilter1
	DbGotop()

	ProcRegua(RecCount())

	While !Eof()
		IncProc()
		DbSelectArea(cTRB)
		DbSetOrder(01)

		If !Dbseek(STJ->TJ_CODBEM+STJ->TJ_IRREGU)
			(cTRB)->(DbAppend())
			(cTRB)->CODBEM := STJ->TJ_CODBEM
			(cTRB)->NOMBEM := ""
			(cTRB)->CODIRE := STJ->TJ_IRREGU
			(cTRB)->NOMIRE := ""
			(cTRB)->CCUSTO := ""
			(cTRB)->NCUSTO := ""
			(cTRB)->CENTRAB := ""
			(cTRB)->NOMTRAB := ""
			(cTRB)->CODFAMI := ""
			(cTRB)->NOMFAMI := ""
			(cTRB)->QUANTI := 0

			DbSelectArea("TP7")
			DbSetOrder(01)

			If Dbseek(xFilial("STJ")+STJ->TJ_IRREGU)
				If TP7->TP7_UNDTMP == "1"
					//Unidade de Dias
					dDtLimit2 := dDataBase - (TP7->TP7_QTDTMP)
				ElseIf TP7->TP7_UNDTMP == "2"
					//Unidade de Mes
					dDtLimit2 := dDataBase - (TP7->TP7_QTDTMP * 30)
				ElseIf TP7->TP7_UNDTMP == "3"
					//Unidade de Ano
					dDtLimit2 := dDataBase - (TP7->TP7_QTDTMP * 365)
				EndIf

				(cTRB)->QTDALE := TP7->TP7_QTDALE
				(cTRB)->NOMIRE := TP7->TP7_NOME
				(cTRB)->DTLIMT := IIF( DTOS( dDtLimit2 ) < '19000101', STOD( '19000101' ), dDtLimit2) //Validação adicionada para evitar
			EndIf																					 //casos em que a data limite calculada
		EndIf																						//é menor que 01/01/1900, resultando num erro

		If STJ->TJ_DTMRFIM >= (cTRB)->DTLIMT
			(cTRB)->QUANTI := (cTRB)->QUANTI + 1
		EndIf

		DbSelectArea("STJ")
		DbSkip()
	End

	DbSelectArea("STJ")
	Set Filter To

	//GERACAO PARA ARQUIVO DE DIGITACAO DO PCP
	DbSelectArea("TP8")

	cFilter2 := "TP8->TP8_FILIAL = '"+xFILIAL("TP8")+"' .And. "
	cFilter2 += "(DTOS(TP8->TP8_DTOCOR) >= "+ValToSql(dDtLimit1)+" .And. DTOS(TP8->TP8_DTOCOR) <= "+ValToSql(dDataBase)+") .And. "
	cFilter2 += "(DTOS(TP8->TP8_DTOCOR) >= "+ValToSql(MV_PAR09)+" .And. DTOS(TP8->TP8_DTOCOR) <= "+ValToSql(MV_PAR10)+")"

	SET FILTER TO &cFilter2

	DbGotop()
	ProcRegua(RecCount())

	While !Eof()
		IncProc()
		DbSelectArea(cTRB)
		DbSetOrder(01)

		If !Dbseek(TP8->TP8_CODBEM+TP8->TP8_CODIRE)
			(cTRB)->(DbAppend())
			(cTRB)->CODBEM := TP8->TP8_CODBEM
			(cTRB)->NOMBEM := ""
			(cTRB)->CODIRE := TP8->TP8_CODIRE
			(cTRB)->NOMIRE := ""
			(cTRB)->CCUSTO := ""
			(cTRB)->NCUSTO := ""
			(cTRB)->CENTRAB := ""
			(cTRB)->NOMTRAB := ""
			(cTRB)->CODFAMI := ""
			(cTRB)->NOMFAMI := ""
			(cTRB)->QUANTI := 0

			DbSelectArea("TP7")
			DbSetOrder(01)

			If Dbseek(xFilial("TP8")+TP8->TP8_CODIRE)
				If TP7->TP7_UNDTMP == "1"
					//Unidade de Dias
					dDtLimit2 := dDataBase - (TP7->TP7_QTDTMP)
				ElseIf TP7->TP7_UNDTMP == "2"
					//Unidade de Mes
					dDtLimit2 := dDataBase - (TP7->TP7_QTDTMP * 30)
				ElseIf TP7->TP7_UNDTMP == "3"
					//Unidade de Ano
					dDtLimit2 := dDataBase - (TP7->TP7_QTDTMP * 365)
				EndIf

				(cTRB)->QTDALE := TP7->TP7_QTDALE
				(cTRB)->NOMIRE := TP7->TP7_NOME
				(cTRB)->DTLIMT := IIF( DTOS( dDtLimit2 ) < '19000101', STOD( '19000101' ), dDtLimit2) //Validação adicionada para evitar
			EndIf																					 //casos em que a data limite calculada
		EndIf																						//é menor que 01/01/1900, resultando num erro

		If TP8->TP8_DTOCOR >= (cTRB)->DTLIMT
			(cTRB)->QUANTI := (cTRB)->QUANTI + 1
		EndIf

		DbSelectArea("TP8")
		DbSkip()
	EndDo

	DbSelectArea("TP8")
	Set Filter To

	//GRAVA DETALHES DO ARQUIVO TEMPORARIO
	DbSelectArea(cTRB)
	DbGotop()

	ProcRegua(RecCount())

	While !EoF()
		IncProc()
		//LEITURA DO NOME DO BEM
		DbSelectArea("ST9")
		DbSetOrder(01)

		If Dbseek(xFilial("ST9")+(cTRB)->CODBEM)
			(cTRB)->NOMBEM := ST9->T9_NOME
			(cTRB)->CCUSTO := ST9->T9_CCUSTO
			(cTRB)->CENTRAB:= ST9->T9_CENTRAB
			(cTRB)->CODFAMI:= ST9->T9_CODFAMI
		EndIf

		//LEITURA DO CENTRO DE CUSTO
		If cF3CTTSI3 = "CTT"
			DbSelectArea("CTT")
			DbSetOrder(1)

			If Dbseek(xFilial("CTT")+(cTRB)->CCUSTO)
				(cTRB)->NCUSTO := CTT->CTT_DESC01
			EndIf
		EndIf

		If cF3CTTSI3 = "SI3"
			DbSelectArea("SI3")
			DbSetOrder(1)

			If Dbseek(xFilial("SI3")+(cTRB)->CCUSTO)
				(cTRB)->NCUSTO := SI3->I3_DESC
			EndIf
		Endif

		//LEITURA DO CENTRO DE TRABALHO
		DbSelectArea("SHB")
		DbSetOrder(01)

		If Dbseek(xFilial("SHB")+(cTRB)->CENTRAB)
			(cTRB)->NOMTRAB := SHB->HB_NOME
		EndIf

		//LEITURA DA FAMILIA
		DbSelectArea("ST6")
		DbSetOrder(01)

		If Dbseek(xFilial("ST6")+(cTRB)->CODFAMI)
			(cTRB)->NOMFAMI := ST6->T6_NOME
		EndIf

		DbSelectArea(cTRB)
		DbSkip()
	EndDo
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTR815R3 ³ Autor ³ Ricardo Dal Ponte     ³ Data ³13/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function MNTR815R3()

	Local WNREL      := "MNTR815"
	Local LIMITE     := 132
	Local cDESC1     := STR0001 //"Bens por Irregularidades"
	Local cDESC2     := STR0003 //"Destina-se a imprimir as ocorrencias de Irregularidades dos Bens"
	Local cDESC3     := STR0004 //"nas Ordem de Serviço Corretivas."
	Local cSTRING    := ""

	Private NOMEPROG := "MNTR815"
	Private TAMANHO  := "M"
	Private aRETURN  := {"Zebrado",1,"Administracao",1,2,1,"",1}
	Private TITULO   := cDESC1
	Private CPERG    := "MNT815"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(CPERG,.F.)

	WNREL := SetPrint(cSTRING,WNREL,CPERG,TITULO,cDESC1,cDESC2,cDESC3,.F.,"")

	SetKey(VK_F4, {|| })

	If nLASTKEY = 27
		Set Filter To
		Return
	EndIf

	SetDefault(aRETURN,cSTRING)
	RptStatus({|lEND| R815Emp(@lEND,WNREL,TITULO,TAMANHO)},TITULO)

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ R815Emp  ³ Autor ³ Ricardo Dal Ponte     ³ Data ³13/02/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do Relat¢rio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTR815                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R815Emp(lEND,WNREL,TITULO,TAMANHO)

	Local cRODATXT := ""
	Local nCNTIMPR := 0
	Local cCUSTO, cTRABALHO, cFAMILIA, cBEM, cIRREGU
	Local lImpCar  := .F.
	Local lRet     := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Contadores de linha e pagina                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private li := 80 ,m_pag := 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se deve comprimir ou nao                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTIPO := IIF(aRETURN[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta os Cabecalhos                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private CABEC1 := STR0019//"               Bem              Descrição                                Irregularidade Descrição                      Quant. Ocorr."
	Private CABEC2 := " "

	/*
	1         2         3         4         5         6         7         8         9         100       110       120      130
	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012346789012
	************************************************************************************************************************************
	Bem              Descrição                                Irregularidade Descrição                      Quant. Ocorr.
	************************************************************************************************************************************
	xxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	xxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	xxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

	xxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xxx            xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  999,999,999
	xxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xxx            xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  999,999,999
	xxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xxx            xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  999,999,999
	*/

	Processa({|lEND| MNTR815TRB()},STR0013) //"Processando Arquivo..."

	dbSelectArea(cTRB)
	dbSetOrder(2)
	dbGoTop()

	//STR0001  + " - " + STR0015 + ": " + DTOC(MV_PAR09) + " " + STR0016 + ": " + DTOC(MV_PAR10) //de### //ate
	//oReport:CTitle := STR0001  + " - " + STR0015 + ": " + DTOC(MV_PAR09) + " " + STR0016 + ": " + DTOC(MV_PAR10) //de### //ate
	//oReport:SetMeter(RecCount())

	ProcRegua(LastRec())

	cCUSTO    := ""
	cTRABALHO := ""
	cFAMILIA  := ""

	If EoF()
		oTempTable:Delete()//Deleta tabela temporaria
		MsgInfo( STR0021, STR0020 ) //"Não existem dados para montar o relatório."###"ATENÇÃO"
		Return .F.
	EndIf

	While !Eof()

		IncProc()

		//FILTRA CENTRO DE CUSTO
		If (cTRB)->CCUSTO < MV_PAR01 .Or. (cTRB)->CCUSTO > MV_PAR02
			DbSkip()
			Loop
		EndIf

		//FILTRA CENTRO DE TRABALHO
		If (cTRB)->CENTRAB < MV_PAR03 .Or. (cTRB)->CENTRAB > MV_PAR04
			DbSkip()
			Loop
		EndIf

		//FILTRA FAMILIA DO BEM
		If (cTRB)->CODFAMI < MV_PAR05 .Or. (cTRB)->CODFAMI > MV_PAR06
			DbSkip()
			Loop
		EndIf

		//FILTRA BEM
		If (cTRB)->CODBEM < MV_PAR07 .Or. (cTRB)->CODBEM > MV_PAR08
			DbSkip()
			Loop
		EndIf

		//FILTRA IRREGULARIDADE
		If (cTRB)->CODIRE < MV_PAR11 .Or. (cTRB)->CODIRE > MV_PAR12
			DbSkip()
			Loop
		EndIf

		If MNT045STB( (cTRB)->CODBEM, vFilTRB[2] )
			dbSkip()
			Loop
		EndIf

		lImpCar := .T.

		//QUEBRA POR CENTRO DE CUSTO
		If cCUSTO <> (cTRB)->CCUSTO
			cCUSTO    := (cTRB)->CCUSTO
			cTRABALHO := (cTRB)->CENTRAB
			cFAMILIA  := (cTRB)->CODFAMI

			NgSomali(58)
			@ Li,000 Psay STR0005+" - " //"C.Custo"
			@ Li,011 Psay (cTRB)->CCUSTO
			@ Li,026 Psay (cTRB)->NCUSTO
			NgSomali(58)
			@ Li,003 Psay STR0007+" - " //"C. Trab."
			@ Li,015 Psay (cTRB)->CENTRAB
			@ Li,021 Psay (cTRB)->NOMTRAB
			NgSomali(58)
			@ Li,006 Psay STR0008+" - " //"Familia"
			@ Li,017 Psay (cTRB)->CODFAMI
			@ Li,024 Psay (cTRB)->NOMFAMI
			NgSomali(58)
		EndIf

		//QUEBRA POR CENTRO DE TRABALHO
		If cTRABALHO  <> (cTRB)->CENTRAB
			cTRABALHO := (cTRB)->CENTRAB
			cFAMILIA  := (cTRB)->CODFAMI

			NgSomali(58)
			@ Li,003 Psay STR0007+" - " //"C. Trab."
			@ Li,015 Psay (cTRB)->CENTRAB
			@ Li,021 Psay (cTRB)->NOMTRAB
			NgSomali(58)
			@ Li,006 Psay STR0008+" - " //"Familia"
			@ Li,017 Psay (cTRB)->CODFAMI
			@ Li,024 Psay (cTRB)->NOMFAMI
			NgSomali(58)
		EndIf

		//QUEBRA POR FAMILIA DE BEM
		If cFAMILIA  <> (cTRB)->CODFAMI
			cFAMILIA   := (cTRB)->CODFAMI

			NgSomali(58)
			@ Li,006 Psay STR0008+" - " //"Familia"
			@ Li,017 Psay (cTRB)->CODFAMI
			@ Li,024 Psay (cTRB)->NOMFAMI
			NgSomali(58)
		EndIf

		@ Li,015 Psay (cTRB)->CODBEM  Picture "@!"
		@ Li,032 Psay (cTRB)->NOMBEM  Picture "@!"
		@ Li,073 Psay (cTRB)->CODIRE  Picture "@!"
		@ Li,088 Psay SubStr((cTRB)->NOMIRE,1,30) Picture "@!"
		@ Li,121 Psay (cTRB)->QUANTI  Picture "@E 999,999,999"

		NgSomali(58)

		dbSelectArea(cTRB)
		dbSkip()
	EndDo

	If Type("oTempTable") == "O"
		oTempTable:Delete()//Deleta Tabela Temporaria
	Endif
	If lImpCar
		Roda(nCNTIMPR,cRODATXT,TAMANHO)
	Else
		MsgInfo( STR0021, STR0020 ) //"Não existem dados para montar o relatório."###"ATENÇÃO"
		Return .F.
	EndIf

	If aRETURN[5] = 1

		Set Printer To
		dbCommitAll()
		OurSpool(WNREL)
	EndIf

	MS_FLUSH()

Return Nil