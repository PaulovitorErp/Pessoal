#INCLUDE "MNTR825.ch"
#Include "Protheus.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR825
Relatorio de Bens enviados para Terceiros 
@author Ricardo Dal Ponte
@since 09/05/07
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function MNTR825()

	Local aNGBEGINPRM  := NGBEGINPRM()

	Local oReport
	Local aArea := GetArea()

	Private aVETINR := {}
	Private cF3CTTSI3   := IIf( CtbInUse(), "CTT", "SI3")
	Private nSizeSI3    := IIf( TAMSX3("I3_CUSTO")[1] < 1, 9, TAMSX3("I3_CUSTO")[1])
	Private cR825BEM    := ""
	Private oTempTable //Tabela Temporaria
	Private cTRB	:= GetNextAlias()
	/*---------------------------------------------------------------
	Vetor utilizado para armazenar retorno da função MNTTRBSTB,
	criada de acordo com o item 18 (RoadMap 2013/14)
	---------------------------------------------------------------*/
	Private vFilTRB := MNT045TRB()

	SetKey(VK_F4, {|| MNT045FIL( vFilTRB[2] )})

	//---------------------------------------------------------------+
	//| Variaveis utilizadas para parametros                         |
	//| mv_par01     // De  Bem                                      |
	//| mv_par02     // Ate Bem                                      |
	//| mv_par03     // De  Data                                     |
	//| mv_par04     // Ate Data                                     |
	//| mv_par05     // Listar OS - 1=Abertas                        |
	//|                             2=Finalizadas                    |
	//|                             3=Ambas                          |
	//---------------------------------------------------------------+
	If FindFunction("TRepInUse") .And. TRepInUse()
		//Interface de impressao
		oReport := ReportDef()
		oReport:SetPortrait()
		oReport:PrintDialog()
	Else
		MNTR825R3()
	EndIf

	RestArea(aArea)

	NGRETURNPRM(aNGBEGINPRM)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Define as secoes impressas no relatorio
@author Ricardo Dal Ponte
@since 09/05/07
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Static Function ReportDef()

	Local oReport
	Local oSection1
	Local oSection2
	Local oCell

	//--------------------------------------------------------------------------
	//Criacao do componente de impressao
	//TReport():New
	//ExpC1 : Nome do relatorio
	//ExpC2 : Titulo
	//ExpC3 : Pergunte
	//ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao
	//ExpC5 : Descricao
	//--------------------------------------------------------------------------

	oReport := TReport():New("MNTR825",OemToAnsi(STR0009),"MNT85R",{|oReport| ReportPrint(oReport)},STR0010+" "+STR0011) //"Bens enviados para Terceiros"###"Destina-se a imprimir as ocorrências dos Bens enviados para Terceiros "###"nas Ordem de Serviço."

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

	oSection1 := TRSection():New(oReport,STR0012,{(cTRB), "ST9", cF3CTTSI3}) //"Bem"
	oCell := TRCell():New(oSection1,"(cTRB)->CODBEM"	,(cTRB) ,STR0012    ,"@!" 	,16   ,/*lPixel*/,/*{|| code-block de impressao }*/) //"Bem"
	oCell := TRCell():New(oSection1,"(cTRB)->NOMBEM" 	,(cTRB) ,STR0013  ,"@!" 	,40  ,/*lPixel*/,/*{|| code-block de impressao }*/) //"Descrição"
	oCell := TRCell():New(oSection1,""	            ,""   ,""      ,"@!"	,2   ,/*lPixel*/,/*{|| code-block de impressao }*/)
	oCell := TRCell():New(oSection1,"(cTRB)->CCUSTO"  ,(cTRB),STR0014	,"@!" ,nSizeSI3, /*lPixel*/,/*{|| code-block de impressao }*/) //"C.Custo"
	oCell := TRCell():New(oSection1,"(cTRB)->NCUSTO"  ,(cTRB),STR0013	,"@!" ,30,/*lPixel*/,/*{|| code-block de impressao }*/) //"Descrição"
	oCell := TRCell():New(oSection1,""	            ,""   ,""      ,"@!"	,2   ,/*lPixel*/,/*{|| code-block de impressao }*/)
	oCell := TRCell():New(oSection1,"cR825BEM"     ,"",STR0015,"@!" ,12, /*lPixel*/,{||cR825BEM}) //"Em Terceiro?"
	TRPosition():New(oSection1,"ST9",1,{|| xFilial("ST9")+(cTRB)->CODBEM})

	If cF3CTTSI3 = "CTT"
		TRPosition():New(oSection1,"CTT",1,{|| xFilial("CTT")+(cTRB)->CCUSTO})
	EndIf

	If cF3CTTSI3 = "SI3"
		TRPosition():New(oSection1,"SI3",1,{|| xFilial("SI3")+(cTRB)->CCUSTO})
	EndIf

	oSection2 := TRSection():New(oReport, STR0016,{(cTRB),"ST4"}) //"Ordem de Servico"
	TRCell():New(oSection2,""	            ,""   ,""         ,"@!"	,5   ,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"(cTRB)->ORDEM"   ,(cTRB),STR0017	   ,"@!" ,6, /*lPixel*/,/*{|| code-block de impressao }*/) //"Ordem"
	TRCell():New(oSection2,""	            ,""   ,""         ,"@!"	,1   ,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"(cTRB)->DTORIGI" ,(cTRB),STR0018,"99/99/9999" ,10, /*lPixel*/,/*{|| code-block de impressao }*/) //"Dt.Origi."
	TRCell():New(oSection2,"(cTRB)->PLANO"   ,(cTRB),STR0019	   ,"@!" ,6, /*lPixel*/,/*{|| code-block de impressao }*/) //"Plano"
	TRCell():New(oSection2,"(cTRB)->SEQRELA" ,(cTRB),STR0020     ,"@!" ,6, /*lPixel*/,/*{|| code-block de impressao }*/) //"Seq."
	TRCell():New(oSection2,"(cTRB)->SERVICO" ,(cTRB),STR0021   ,"@!" ,6, /*lPixel*/,/*{|| code-block de impressao }*/) //"Servic"
	TRCell():New(oSection2,""	            ,""   ,""         ,"@!"	,1   ,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"(cTRB)->NOMSERV" ,(cTRB),STR0022   ,"@!" ,30, /*lPixel*/,/*{|| code-block de impressao }*/) //"Descricao do Servico"
	TRCell():New(oSection2,""	            ,""   ,""         ,"@!"	,1   ,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"(cTRB)->DTMPINI" ,(cTRB),STR0023,"99/99/9999" ,10, /*lPixel*/,/*{|| code-block de impressao }*/) //"Dt.Man.Ini"
	TRCell():New(oSection2,"(cTRB)->DTMPFIM" ,(cTRB),STR0024,"99/99/9999" ,10, /*lPixel*/,/*{|| code-block de impressao }*/) //"Dt.Man.Fim"
	TRCell():New(oSection2,"(cTRB)->CSITUAC" ,(cTRB),STR0025 ,"@!" ,09, /*lPixel*/,/*{|| code-block de impressao }*/) //"Situacao"
	TRCell():New(oSection2,""	            ,""   ,""         ,"@!"	,1   ,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"(cTRB)->CTERMIN" ,(cTRB),STR0026  ,"@!" ,07, /*lPixel*/,/*{|| code-block de impressao }*/) //"Termino"
	TRPosition():New(oSection2,"ST4",1,{|| xFilial("ST4")+(cTRB)->SERVICO})

Return oReport

//---------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Chamada do Relatório 
@author Ricardo Dal Ponte
@since 09/05/07
@version undefined
@param oReport, object, descricao
@type function
/*/
//---------------------------------------------------------------------
Static Function ReportPrint(oReport)

	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)
	Local cCUSTO, cBEM
	Local lGera := .T.
	Private cOBS

	Processa({|lEND| MNTR825TRB()},STR0027) //"Processando Arquivo..."

	dbSelectArea(cTRB)
	dbSetOrder(1)
	dbGoTop()

	If EoF()
		MsgInfo(STR0042, STR0043) //"Não existem dados para montar o relatório!"###"ATENÇÃO"
		lGera := .F.
	Else
		cR825BEM := ""

		oReport:CTitle := STR0009  + " - " + STR0028 + ": " + DTOC(MV_PAR03) + " " + STR0029 + ": " + DTOC(MV_PAR04) //"Bens enviados para Terceiros"###"de"###"ate"
		oReport:SetMeter(RecCount())
		While !Eof() .And. !oReport:Cancel()

			If MNT045STB( (cTRB)->CODBEM, vFilTRB[2] )
				dbSkip()
				Loop
			EndIf

			oReport:IncMeter()

			//QUEBRA POR BEM
			If cBEM <> (cTRB)->CODBEM
				cBEM    := (cTRB)->CODBEM

				R825BEM()

				oSection2:Finish()

				oSection1:Init()
				oSection1:PrintLine()
				oSection1:Finish()

				oSection2:Init()
			EndIf

			//IMPRESSAO DO DETALHE DO OS
			oSection2:PrintLine()

			dbSelectArea(cTRB)
			dbSkip()
		EndDo

		oSection2:Finish()
	EndIf

	oTempTable:Delete()

Return lGera

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR825TRB
Geração do Arquivo Temporario
@author Ricardo Dal Ponte
@since 09/05/07
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function MNTR825TRB()

	Local aDBF

	aDBF := {{"CODBEM"  ,"C", 16, 0},;
			 {"NOMBEM"  ,"C", 40, 0},;
			 {"CCUSTO"  ,"C", nSizeSI3,0},;
			 {"NCUSTO"  ,"C", 40, 0},;
			 {"CTERCE"  ,"C", 12, 0},;
			 {"ORDEM"   ,"C", 06, 0},;
			 {"PLANO"   ,"C", 06, 0},;
			 {"DTORIGI" ,"D", 08, 0},;
			 {"SEQRELA" ,"C", 06, 0},;
			 {"SERVICO" ,"C", 06, 0},;
			 {"NOMSERV" ,"C", 30, 0},;
			 {"SITUACA" ,"C", 01, 0},;
			 {"CSITUAC" ,"C", 09, 0},;
			 {"DTMPINI" ,"D", 08, 0},;
			 {"DTMPFIM" ,"D", 08, 0},;
			 {"TERMINO" ,"C", 01, 0},;
			 {"CTERMIN" ,"C", 07, 0}}

	oTempTable	:= FWTemporaryTable():New( cTRB, aDBF )
	oTempTable:AddIndex( "Ind01" ,{"CODBEM","ORDEM","PLANO","SEQRELA"} )
	oTempTable:Create()

	If MV_PAR05 = 1
		cSITUACA  := " STJ->TJ_TERMINO = 'N'"
		cSITUACA2 := " STS->TS_TERMINO = 'N'"
	ElseIf MV_PAR05 = 2
		cSITUACA  := " STJ->TJ_TERMINO = 'S'"
		cSITUACA2 := " STS->TS_TERMINO = 'S'"
	ElseIf MV_PAR05 = 3
		cSITUACA  := " (STJ->TJ_TERMINO = 'S' .Or. STJ->TJ_TERMINO = 'N')"
		cSITUACA2 := " (STS->TS_TERMINO = 'S' .Or. STS->TS_TERMINO = 'N')"
	EndIf

	//GERACAO PARA ARQUIVO DE ORDEM DE SERVICO TABELA STJ
	dbSelectArea("STJ")

	SET FILTER TO STJ->TJ_FILIAL = xFILIAL("STJ") .And. STJ->TJ_TIPOOS = "B" .And.;
	STJ->TJ_CODBEM >= MV_PAR01 .And. STJ->TJ_CODBEM <= MV_PAR02 .And.;
	(STJ->TJ_DTORIGI >= MV_PAR03 .And. STJ->TJ_DTORIGI <= MV_PAR04) .And.;
	STJ->TJ_TERCEIR = "2" .And. &(cSITUACA)

	dbGoTop()

	ProcRegua(RecCount())

	While !Eof()
		IncProc()
		dbSelectArea(cTRB)
		dbSetOrder(01)

		If !dbSeek(STJ->TJ_CODBEM+STJ->TJ_IRREGU)
			(cTRB)->(DbAppend())
			(cTRB)->CODBEM := STJ->TJ_CODBEM
			(cTRB)->NOMBEM := ""
			(cTRB)->CCUSTO := ""
			(cTRB)->NCUSTO := ""

			(cTRB)->ORDEM    := STJ->TJ_ORDEM
			(cTRB)->PLANO    := STJ->TJ_PLANO
			(cTRB)->DTORIGI  := STJ->TJ_DTORIGI
			(cTRB)->SEQRELA  := STJ->TJ_SEQRELA
			(cTRB)->SERVICO  := STJ->TJ_SERVICO
			(cTRB)->NOMSERV  := ""

			(cTRB)->SITUACA  := STJ->TJ_SITUACA
			If (cTRB)->SITUACA  = "C"
				(cTRB)->CSITUAC  := STR0031 //"Cancelada"
			ElseIf (cTRB)->SITUACA  = "L"
				(cTRB)->CSITUAC  := STR0032 //"Liberada"
			ElseIf (cTRB)->SITUACA  = "P"
				(cTRB)->CSITUAC  := STR0033 //"Pendente"
			EndIf

			(cTRB)->TERMINO  := STJ->TJ_TERMINO
			If (cTRB)->TERMINO  = "S"
				(cTRB)->CTERMIN := STR0034 //"Sim"
			Else
				(cTRB)->CTERMIN := STR0035 //"Nao"
			EndIf
		EndIf

		(cTRB)->DTMPINI  := STJ->TJ_DTMPINI
		(cTRB)->DTMPFIM  := STJ->TJ_DTMPFIM

		dbSelectArea("STJ")
		dbSkip()
	EndDo

	dbSelectArea("STJ")
	Set Filter To

	//GERACAO PARA ARQUIVO DE HISTORICO DA ORDEM DE SERVICO TABELA STS
	dbSelectArea("STS")

	SET FILTER TO STS->TS_FILIAL = xFILIAL("STS") .And. STS->TS_TIPOOS = "B" .And.;
	STS->TS_CODBEM >= MV_PAR01 .And. STS->TS_CODBEM <= MV_PAR02 .And.;
	(STS->TS_DTORIGI >= MV_PAR03 .And. STS->TS_DTORIGI <= MV_PAR04) .And.;
	STS->TS_TERCEIR = "2" .And. &(cSITUACA2)

	dbGoTop()

	ProcRegua(RecCount())

	While !Eof()
		IncProc()
		dbSelectArea(cTRB)
		dbSetOrder(01)

		If !dbSeek(STS->TS_CODBEM+STS->TS_IRREGU)
			(cTRB)->(DbAppend())
			(cTRB)->CODBEM := STS->TS_CODBEM
			(cTRB)->NOMBEM := ""
			(cTRB)->CCUSTO := ""
			(cTRB)->NCUSTO := ""

			(cTRB)->ORDEM    := STS->TS_ORDEM
			(cTRB)->PLANO    := STS->TS_PLANO
			(cTRB)->DTORIGI  := STS->TS_DTORIGI
			(cTRB)->SEQRELA  := STS->TS_SEQRELA
			(cTRB)->SERVICO  := STS->TS_SERVICO
			(cTRB)->NOMSERV  := ""

			(cTRB)->SITUACA  := STS->TS_SITUACA
			If (cTRB)->SITUACA  = "C"
				(cTRB)->CSITUAC  := STR0031 //"Cancelada"
			ElseIf (cTRB)->SITUACA  = "L"
				(cTRB)->CSITUAC  := STR0032 //"Liberada"
			ElseIf (cTRB)->SITUACA  = "P"
				(cTRB)->CSITUAC  := STR0033 //"Pendente"
			EndIf

			(cTRB)->TERMINO  := STS->TS_TERMINO
			If (cTRB)->TERMINO  = "S"
				(cTRB)->CTERMIN := STR0034 //"Sim"
			Else
				(cTRB)->CTERMIN := STR0035 //"Nao"
			EndIf
		EndIf

		(cTRB)->DTMPINI  := STS->TS_DTMPINI
		(cTRB)->DTMPFIM  := STS->TS_DTMPFIM


		dbSelectArea("STS")
		dbSkip()
	EndDo

	dbSelectArea("STS")
	Set Filter To

	//GRAVA DETALHES DO ARQUIVO TEMPORARIO
	dbSelectArea(cTRB)
	dbGoTop()

	ProcRegua(RecCount())

	While !Eof()
		IncProc()
		//LEITURA DO NOME DO BEM
		dbSelectArea("ST9")
		dbSetOrder(01)

		If dbSeek(xFilial("ST9")+(cTRB)->CODBEM)
			(cTRB)->NOMBEM := ST9->T9_NOME
			(cTRB)->CCUSTO := ST9->T9_CCUSTO
		EndIf

		//LEITURA DO CENTRO DE CUSTO
		If cF3CTTSI3 = "CTT"
			dbSelectArea("CTT")
			dbSetOrder(1)

			If dbSeek(xFilial("CTT")+(cTRB)->CCUSTO)
				(cTRB)->NCUSTO := CTT->CTT_DESC01
			EndIf
		EndIf

		If cF3CTTSI3 = "SI3"
			dbSelectArea("SI3")
			dbSetOrder(1)

			If dbSeek(xFilial("SI3")+(cTRB)->CCUSTO)
				(cTRB)->NCUSTO := SI3->I3_DESC
			EndIf
		Endif

		//LEITURA DO NOME DO SERVICO
		dbSelectArea("ST4")
		dbSetOrder(01)

		If dbSeek(xFilial("ST4")+(cTRB)->SERVICO)
			(cTRB)->NOMSERV := Substr(ST4->T4_NOME,1,30)
		EndIf

		dbSelectArea(cTRB)
		dbSkip()
	EndDo
Return .t.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR825R3
// Descrição auto-gerada.
@author Ricardo Dal Ponte
@since 09/05/07
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function MNTR825R3()

	Local WNREL      := "MNTR825"
	Local LIMITE     := 132
	Local cDESC1     := STR0009 //"Bens enviados para Terceiros"
	Local cDESC2     := STR0036 //"Destina-se a imprimir as ocorrencias de Bens enviados para terceiros"
	Local cDESC3     := STR0011 //"nas Ordem de Serviço."
	Local cSTRING    := ""

	Private NOMEPROG := "MNTR825"
	Private TAMANHO  := "M"
	Private aRETURN  := { STR0037, 1, STR0038, 1, 2, 1, "", 1 } //"Zebrado"###"Administracao"
	Private TITULO   := cDESC1
	Private CPERG    := "MNT85R"

	//---------------------------------------------------------------+
	//| Envia controle para a funcao SETPRINT                        |
	//---------------------------------------------------------------+
	Pergunte(CPERG,.F.)

	WNREL := SetPrint(cSTRING,WNREL,CPERG,TITULO,cDESC1,cDESC2,cDESC3,.F.,"")

	SetKey(VK_F4, {|| })

	If nLASTKEY = 27
		Set Filter To

		MNT045TRB( .T., vFilTRB[1], vFilTRB[2])

		Return
	EndIf

	SetDefault(aRETURN,cSTRING)
	RptStatus({|lEND| R825Emp(@lEND,WNREL,TITULO,TAMANHO)},TITULO)

	MNT045TRB( .T., vFilTRB[1], vFilTRB[2])

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} R825Emp
Chamada do Relatório   
@author Ricardo Dal Ponte   
@since 09/05/07
@version undefined
@param lEND, logical, descricao
@param WNREL, , descricao
@param TITULO, , descricao
@param TAMANHO, , descricao
@type function
/*/
//---------------------------------------------------------------------
Static Function R825Emp(lEND,WNREL,TITULO,TAMANHO)

	Local cRODATXT := ""
	Local nCNTIMPR := 0
	Local cCUSTO, cTRABALHO, cFAMILIA, cBEM, cIRREGU
	Local lGera := .T.

	Private li := 80 ,m_pag := 1 // Contadores de linha e pagina

	nTIPO := IIF(aRETURN[4]==1,15,18) // Verifica se deve comprimir ou nao

	//+--------------------------------------------------------------+
	//| Monta os Cabecalhos                                          |
	//+--------------------------------------------------------------+

	Private CABEC1 := STR0039 //"Bem               Descricao                                C.Custo          Descricao                           Em Terceiro?"
	Private CABEC2 := STR0040 //"     Ordem  Dt.Origi.  Plano  Seq.   Servic Descricao do Servico           Dt.Man.Ini Dt.Man.Fim Situacao  Termino"

	Processa({|lEND| MNTR825TRB()},STR0027) //"Processando Arquivo..."

	dbSelectArea(cTRB)
	dbSetOrder(1)
	dbGoTop()

	If EoF()
		MsgInfo(STR0042, STR0043) //"Não existem dados para montar o relatório!"###"ATENÇÃO"
		lGera := .F.
	EndIf
	ProcRegua(LastRec())

	cBEM := ""

	While !EoF()

		IncProc()

		If MNT045STB( (cTRB)->CODBEM, vFilTRB[2] )
			dbSkip()
			Loop
		EndIf

		//QUEBRA POR BEM
		If cBEM <> (cTRB)->CODBEM
			cBEM    := (cTRB)->CODBEM

			R825BEM()

			NgSomali(58)
			@ Li,000 Psay Substr((cTRB)->CODBEM,1,16) Picture "@!"
			@ Li,018 Psay Substr((cTRB)->NOMBEM,1,30) Picture "@!"
			@ Li,059 Psay Substr((cTRB)->CCUSTO,1,16) Picture "@!"
			@ Li,076 Psay Substr((cTRB)->NCUSTO,1,20) Picture "@!"
			@ Li,112 Psay cR825BEM    Picture "@!"
			NgSomali(58)
		EndIf

		@ Li,005 Psay (cTRB)->ORDEM  Picture "@!"
		@ Li,012 Psay DTOC((cTRB)->DTORIGI) Picture "99/99/9999"
		@ Li,023 Psay (cTRB)->PLANO Picture "@!"
		@ Li,030 Psay (cTRB)->SEQRELA Picture "@!"
		@ Li,037 Psay (cTRB)->SERVICO Picture "@!"
		@ Li,044 Psay (cTRB)->NOMSERV Picture "@!"
		@ Li,075 Psay DTOC((cTRB)->DTMPINI) Picture "99/99/9999"
		@ Li,086 Psay DTOC((cTRB)->DTMPFIM) Picture "99/99/9999"
		@ Li,097 Psay (cTRB)->CSITUAC Picture "@!"
		@ Li,107 Psay (cTRB)->CTERMIN Picture "@!"

		NgSomali(58)

		dbSelectArea(cTRB)
		dbSkip()
	EndDo

	If lGera
		RODA(nCNTIMPR,cRODATXT,TAMANHO)
	EndIf

	If aRETURN[5] = 1
		Set Printer To
		DbCommitAll()
		OurSpool(WNREL)
	EndIf

	MS_FLUSH()
	oTempTable:Delete()

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR825DT
Valida o parametro ate data 
@author Ricardo Dal Ponte
@since 09/05/07
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function MNTR825DT()

	If  MV_PAR04 < MV_PAR03
		MsgStop(STR0041) //"Data final não pode ser inferior à data inicial!"
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} R825BEM
Retorna se o bem esta em terceiro 
@author Ricardo Dal Ponte
@since 09/05/07
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function R825BEM()

	dbSelectArea("ST9")
	dbSetOrder(01)

	cR825BEM := STR0035 //"Nao"

	If dbSeek(xFilial("ST9")+(cTRB)->CODBEM)
		If ST9->T9_TERCEIR = "2"
			cR825BEM := STR0034 //"Sim"
		EndIf
	EndIf

	dbSelectArea(cTRB)

Return