#INCLUDE "MNTR835.ch"
#Include "Protheus.ch"  

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTR835
Relatorio de OS Liberadas em Aberto 
@author Ricardo Dal Ponte
@since 11/05/07
@version undefined
@type function
/*/
//------------------------------------------------------------------------------
Function MNTR835() 

	//Guarda conteudo e declara variaveis padroes 
	Local aNGBEGINPRM := NGBEGINPRM()
	Local oReport
	Local aArea := GetArea()

	Private cARQ1, aVETINR := {}
	Private cF3CTTSI3 := If(CtbInUse(), "CTT", "SI3")
	Private nSizeSI3 := If((TAMSX3("I3_CUSTO")[1]) < 1,9,(TAMSX3("I3_CUSTO")[1]))   
	//TABELA TEMPORARIA	
	Private cTRB	:= GetNextAlias()
	Private oTempTable		//Tabela Temporaria

	//----------------------------------------------------------------
	//| Variaveis utilizadas para parametros                         |
	//| mv_par01     // De  Centro de Custo                          |
	//| mv_par02     // Ate Centro de Custo                          |
	//| mv_par03     // De  Centro de Trab.                          |
	//| mv_par04     // Ate Centro de Trab.                          |
	//| mv_par05     // De  Familia de Bens                          |
	//| mv_par06     // Ate Familia de Bens                          |
	//| mv_par07     // De  Bem                                      |
	//| mv_par08     // Ate Bem                                      |
	//| mv_par09     // De  Servico                                  |
	//| mv_par10     // Ate Servico                                  |
	//| mv_par11     // De  Dt.Man.Pr.I.                             |
	//| mv_par12     // Ate Dt.Man.Pr.F.                             |
	//----------------------------------------------------------------

	If FindFunction("TRepInUse") .And. TRepInUse()
		//-- Interface de impressao
		oReport := ReportDef()
		oReport:SetPortrait()
		oReport:PrintDialog()
	Else
		MNTR835R3()
	EndIf

	RestArea(aArea)  
	//----------------------------------------------
	//|   Retorna conteudo de variaveis padroes    |
	//----------------------------------------------
	NGRETURNPRM(aNGBEGINPRM)
Return .T.
//------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Define as secoes impressas no relatorio 
@author Ricardo Dal Ponte
@since 11/05/07
@version undefined
@type function
/*/
//------------------------------------------------------------------------------
Static Function ReportDef() 

	Local oReport 
	Local oSection1 
	Local oSection2 
	Local oCell 

	//--------------------------------------------------------------------------
	//|Criacao do componente de impressao                                      |
	//|                                                                        |
	//|TReport():New                                                           |
	//|ExpC1 : Nome do relatorio                                               |
	//|ExpC2 : Titulo                                                          |
	//|ExpC3 : Pergunte                                                        |
	//|ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  |
	//|ExpC5 : Descricao                                                       |
	//|                                                                        |
	//--------------------------------------------------------------------------

	oReport := TReport():New("MNTR835",OemToAnsi(STR0013),"MNT83R",{|oReport| ReportPrint(oReport)},STR0014) //"OS Liberadas em Aberto"###"Destina-se a imprimir as OS Liberadas e em Aberto no sistema."

	Pergunte(oReport:uParam,.F.) 

	//--------------------------------------------------------------------------
	//|Criacao da secao utilizada pelo relatorio                               |
	//|                                                                        |
	//|TRSection():New                                                         |
	//|ExpO1 : Objeto TReport que a secao pertence                             |
	//|ExpC2 : Descricao da seçao                                              |
	//|ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   |
	//|        sera considerada como principal para a seção.                   |
	//|ExpA4 : Array com as Ordens do relatório                                |
	//|ExpL5 : Carrega campos do SX3 como celulas                              |
	//|        Default : False                                                 |
	//|ExpL6 : Carrega ordens do Sindex                                        |
	//|        Default : False                                                 |
	//|                                                                        |
	//--------------------------------------------------------------------------
	//--------------------------------------------------------------------------
	//|Criacao da celulas da secao do relatorio                                |
	//|                                                                        |
	//|TRCell():New                                                            |
	//|ExpO1 : Objeto TSection que a secao pertence                            |
	//|ExpC2 : Nome da celula do relatório. O SX3 será consultado              |
	//|ExpC3 : Nome da tabela de referencia da celula                          |
	//|ExpC4 : Titulo da celula                                                |
	//|        Default : X3Titulo()                                            |
	//|ExpC5 : Picture                                                         |
	//|        Default : X3_PICTURE                                            |
	//|ExpC6 : Tamanho                                                         |
	//|        Default : X3_TAMANHO                                            |
	//|ExpL7 : Informe se o tamanho esta em pixel                              |
	//|        Default : False                                                 |
	//|ExpB8 : Bloco de código para impressao.                                 |
	//|        Default : ExpC2                                                 |
	//|                                                                        |
	//--------------------------------------------------------------------------

	oSection1 := TRSection():New(oReport,STR0015,{(cTRB), cF3CTTSI3,"STD"}) //"Centro de Custo/Área"
	oCell := TRCell():New(oSection1,"(cTRB)->CCUSTO"  ,(cTRB),STR0016,"@!" ,nSizeSI3, /*lPixel*/,/*{|| code-block de impressao }*/) //"Centro Custo"
	oCell := TRCell():New(oSection1,"(cTRB)->NCUSTO"  ,(cTRB),STR0017,"@!" ,30,/*lPixel*/,/*{|| code-block de impressao }*/) //"Descrição"
	oCell := TRCell():New(oSection1,""	              ,""   ,"","@!"	,2   ,/*lPixel*/,/*{|| code-block de impressao }*/)
	oCell := TRCell():New(oSection1,"(cTRB)->CODAREA" ,(cTRB),STR0018,"@!",06, /*lPixel*/,/*{|| code-block de impressao }*/) //"Codigo Área"
	oCell := TRCell():New(oSection1,"(cTRB)->NOMAREA" ,(cTRB),STR0017,"@!" ,30,/*lPixel*/,/*{|| code-block de impressao }*/) //"Descrição"
	If cF3CTTSI3 = "CTT"
		TRPosition():New(oSection1,"CTT",1,{|| xFilial("CTT")+(cTRB)->CCUSTO})
	EndIf
	If cF3CTTSI3 = "SI3"
		TRPosition():New(oSection1,"SI3",1,{|| xFilial("SI3")+(cTRB)->CCUSTO})
	EndIf
	TRPosition():New(oSection1,"STD",1,{|| xFilial("STD")+(cTRB)->CODAREA})


	oSection2 := TRSection():New(oReport, STR0019,{(cTRB),"ST4","ST9","ST6"}) //"Ordem de Servico"
	TRCell():New(oSection2,""	            ,""   ,""         ,"@!"	,5   ,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"(cTRB)->ORDEM"   ,(cTRB),STR0020,"@!" ,6, /*lPixel*/,/*{|| code-block de impressao }*/) //"Ordem"
	TRCell():New(oSection2,"(cTRB)->DTORIGI" ,(cTRB),STR0021,"99/99/9999" ,10, /*lPixel*/,/*{|| code-block de impressao }*/) //"Data da OS."
	TRCell():New(oSection2,"(cTRB)->PLANO"   ,(cTRB),STR0022,"@!" ,6, /*lPixel*/,/*{|| code-block de impressao }*/) //"Plano"
	TRCell():New(oSection2,"(cTRB)->SEQRELA" ,(cTRB),STR0023,"@!" ,6, /*lPixel*/,/*{|| code-block de impressao }*/) //"Seq."
	TRCell():New(oSection2,"(cTRB)->SERVICO" ,(cTRB),STR0024,"@!" ,6, /*lPixel*/,/*{|| code-block de impressao }*/) //"Serviço"
	TRCell():New(oSection2,"(cTRB)->NOMSERV" ,(cTRB),STR0025,"@!" ,25, /*lPixel*/,/*{|| code-block de impressao }*/) //"Descricao do Servico"
	TRCell():New(oSection2,"(cTRB)->DTMPINI" ,(cTRB),STR0026,"99/99/9999" ,10, /*lPixel*/,/*{|| code-block de impressao }*/) //"Data Inicio"
	TRCell():New(oSection2,"(cTRB)->DTMPFIM" ,(cTRB),STR0027,"99/99/9999" ,10, /*lPixel*/,/*{|| code-block de impressao }*/) //"Data Fim"
	TRCell():New(oSection2,"(cTRB)->NOMBEM"  ,(cTRB),STR0028,"@!" 	,25  ,/*lPixel*/,/*{|| code-block de impressao }*/) //"Bem"
	TRCell():New(oSection2,"(cTRB)->NOMFAMI" ,(cTRB),STR0029,"@!" 	,25  ,/*lPixel*/,/*{|| code-block de impressao }*/) //"Familia"

	TRPosition():New(oSection2,"ST4",1,{|| xFilial("ST4")+(cTRB)->SERVICO})
	TRPosition():New(oSection2,"ST9",1,{|| xFilial("ST9")+(cTRB)->CODBEM})
	TRPosition():New(oSection2,"ST6",1,{|| xFilial("ST6")+(cTRB)->CODFAMI})
Return oReport 

//------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Chamada do Relatório
@author Ricardo Dal Ponte
@since 11/05/07
@version undefined
@param oReport, object
@type function
/*/
//------------------------------------------------------------------------------
Static Function ReportPrint(oReport)

	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)
	Local cCUSTO, cAREA

	Private cOBS


	Processa({|lEND| MNTR835TRB()},STR0030) //"Processando Arquivo..."

	dbSelectArea(cTRB)
	dbsetOrder(1)
	dbGOTOP()

	oReport:CTitle := STR0013  + " - " + STR0031 + ": " + DTOC(MV_PAR11) + " " + STR0032 + ": " + DTOC(MV_PAR12) //"OS Liberadas em Aberto"###"de"###"ate"
	oReport:SetMeter(RecCount())
	While !Eof() .And. !oReport:Cancel()

		oReport:IncMeter()

		//QUEBRA POR CENTRO DE CUSTO
		If cCUSTO <> (cTRB)->CCUSTO
			cCUSTO := (cTRB)->CCUSTO
			cAREA  := (cTRB)->CODAREA

			oSection2:Finish()

			oSection1:Init()
			oSection1:PrintLine()
			oSection1:Finish()

			oSection2:Init()
		EndIf 

		//QUEBRA POR CENTRO DE CUSTO
		If cAREA <> (cTRB)->CODAREA
			cAREA := (cTRB)->CODAREA

			oSection2:Finish()

			oSection1:Init()
			oSection1:PrintLine()
			oSection1:Finish()

			oSection2:Init()
		EndIf 

		//IMPRESSAO DO DETALHE DA OS
		oSection2:PrintLine()

		dbSKIP()
	End

	oSection2:Finish()

	//	NGDELETRB((cTRB),cARQ1)            
	oTempTable:Delete()//Deleta Tabela Temporario
Return .T.
//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTR835TRB
GERACAO DE ARQUIVO TEMPORARIO  
@author Ricardo Dal Ponte
@since 11/05/07 
@version undefined
@type function
/*/
//------------------------------------------------------------------------------
Function MNTR835TRB()
	Local aDBF
	//TABELA TEMPORARIA	
	
	//criacao arquivo temporario
	//----------------------------------------
	aDBF := {{"CODBEM"  ,"C", 16,0},;
			 {"NOMBEM"  ,"C", 40,0},;
			 {"CCUSTO"  ,"C",nSizeSI3,0},;
			 {"NCUSTO"  ,"C", 40,0},;
			 {"CODAREA" ,"C", 06,0},;
			 {"NOMAREA" ,"C", 40,0},;
			 {"CODFAMI" ,"C", 06,0},;
			 {"NOMFAMI" ,"C", 40,0},;
			 {"ORDEM"   ,"C", 06,0},;
			 {"PLANO"   ,"C", 06,0},;
			 {"DTORIGI" ,"D", 08,0},;
			 {"SEQRELA" ,"C", 06,0},;
			 {"SERVICO" ,"C", 06,0},;
			 {"NOMSERV" ,"C", 30,0},;
			 {"SITUACA" ,"C", 01,0},;
			 {"CSITUAC" ,"C", 09,0},;
			 {"DTMPINI" ,"D", 08,0},;
			 {"DTMPFIM" ,"D", 08,0}}

	
	//Instancia classe FWTemporaryTable
	oTempTable	:= FWTemporaryTable():New( cTRB, aDBF )
	//Cria indices
	oTempTable:AddIndex( "Ind01" , {"CCUSTO","CODAREA","ORDEM","PLANO","SEQRELA"}  )
	//Cria a tabela temporaria
	oTempTable:Create()


	//----------------------------------------

	//GERACAO PARA ARQUIVO DE ORDEM DE SERVICO TABELA STJ
	DbSelectArea("STJ")

	SET FILTER TO STJ->TJ_FILIAL = xFILIAL("STJ") .And. ;
	STJ->TJ_TERMINO  = "N"      .And. STJ->TJ_SITUACA  = "L"      .And. ;
	STJ->TJ_CCUSTO  >= MV_PAR01 .And. STJ->TJ_CCUSTO  <= MV_PAR02 .And. ;
	STJ->TJ_CODBEM  >= MV_PAR07 .And. STJ->TJ_CODBEM  <= MV_PAR08 .And. ;
	STJ->TJ_SERVICO >= MV_PAR09 .And. STJ->TJ_SERVICO <= MV_PAR10 .And. ;
	STJ->TJ_DTMPINI >= MV_PAR11 .And. STJ->TJ_DTMPFIM <= MV_PAR12

	DbGotop()

	ProcRegua(RecCount())

	While !Eof()
		IncProc()
		DbSelectArea(cTRB)
		DbSetOrder(01)

		DbSelectArea("ST9")
		DbSetOrder(01)

		If Dbseek(xFilial("ST9")+STJ->TJ_CODBEM)
			If ST9->T9_CENTRAB  < MV_PAR03 .Or. ST9->T9_CENTRAB  > MV_PAR04
				DbSelectArea("STJ")
				dbSkip()
				Loop
			EndIf

			If ST9->T9_CODFAMI  < MV_PAR05 .Or. ST9->T9_CODFAMI  > MV_PAR06
				DbSelectArea("STJ")
				dbSkip()
				Loop
			EndIf
		Else
			DbSelectArea("STJ")
			dbSkip()
			Loop
		EndIf

		RecLock((cTRB),.T.)

		(cTRB)->CODBEM := STJ->TJ_CODBEM 
		(cTRB)->NOMBEM := ""
		(cTRB)->CCUSTO := STJ->TJ_CCUSTO
		(cTRB)->NCUSTO := ""
		(cTRB)->CODAREA := STJ->TJ_CODAREA
		(cTRB)->NOMAREA := ""
		(cTRB)->ORDEM   := STJ->TJ_ORDEM
		(cTRB)->PLANO   := STJ->TJ_PLANO
		(cTRB)->DTORIGI := STJ->TJ_DTORIGI
		(cTRB)->SEQRELA := STJ->TJ_SEQRELA
		(cTRB)->SERVICO := STJ->TJ_SERVICO
		(cTRB)->NOMSERV := ""

		(cTRB)->SITUACA  := STJ->TJ_SITUACA
		If (cTRB)->SITUACA  = "C"
			(cTRB)->CSITUAC  := STR0034 //"Cancelada"
		ElseIf (cTRB)->SITUACA  = "L"
			(cTRB)->CSITUAC  := STR0035 //"Liberada"
		ElseIf (cTRB)->SITUACA  = "P"
			(cTRB)->CSITUAC  := STR0036 //"Pendente"
		EndIf

		(cTRB)->DTMPINI  := STJ->TJ_DTMPINI
		(cTRB)->DTMPFIM  := STJ->TJ_DTMPFIM

		(cTRB)->(MsUnlock())

		DbSelectArea("STJ")
		DbSkip()
	End

	DbSelectArea("STJ")
	Set Filter To
	//GRAVA DETALHES DO ARQUIVO TEMPORARIO
	DbSelectArea(cTRB)
	DbGotop()

	ProcRegua(RecCount())

	While !Eof()
		IncProc()
		//LEITURA DO NOME DO BEM
		DbSelectArea("ST9")
		DbSetOrder(01)

		If Dbseek(xFilial("ST9")+(cTRB)->CODBEM)
			(cTRB)->NOMBEM := ST9->T9_NOME
			(cTRB)->CODFAMI := ST9->T9_CODFAMI
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

		//LEITURA DO NOME DO SERVICO
		DbSelectArea("ST4")
		DbSetOrder(01)

		If Dbseek(xFilial("ST4")+(cTRB)->SERVICO)
			(cTRB)->NOMSERV := Substr(ST4->T4_NOME,1,30)
		EndIf

		//LEITURA DO NOME DO AREA
		DbSelectArea("STD")
		DbSetOrder(01)

		If Dbseek(xFilial("STD")+(cTRB)->CODAREA)
			(cTRB)->NOMAREA := Substr(STD->TD_NOME,1,30)
		EndIf

		//LEITURA DO NOME DA FAMILIA
		DbSelectArea("ST6")
		DbSetOrder(01)

		If Dbseek(xFilial("ST6")+(cTRB)->CODFAMI)
			(cTRB)->NOMFAMI := Substr(ST6->T6_NOME,1,30)
		EndIf


		DbSelectArea(cTRB)
		DbSkip()
	End
Return .F.
//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTR835R3
Impressão do Relatório.
@author Ricardo Dal Ponte
@since 11/05/07
@version undefined
@type function
/*/
//------------------------------------------------------------------------------
Function MNTR835R3()
	Local WNREL      := "MNTR835"
	Local LIMITE     := 132
	Local cDESC1     := STR0013 //"OS Liberadas em Aberto"
	Local cDESC2     := STR0014 //"Destina-se a imprimir as OS Liberadas e em Aberto no sistema."
	Local cDESC3     := ""
	Local cSTRING    := ""

	Private NOMEPROG := "MNTR835"
	Private TAMANHO  := "M"
	Private aRETURN  := {STR0037,1,STR0038,1,2,1,"",1} //"Zebrado"###"Administracao"
	Private TITULO   := cDESC1
	Private CPERG    := "MNT83R" 

	//³ Envia controle para a funcao SETPRINT                        ³
	Pergunte(CPERG,.F.)

	WNREL := SetPrint(cSTRING,WNREL,CPERG,TITULO,cDESC1,cDESC2,cDESC3,.F.,"")

	If nLASTKEY = 27
		Set Filter To
		Return
	EndIf
	SetDefault(aRETURN,cSTRING)
	RptStatus({|lEND| R835Emp(@lEND,WNREL,TITULO,TAMANHO)},TITULO)

Return Nil
//------------------------------------------------------------------------------
/*/{Protheus.doc} R835Emp
Chamada do Relatório 
@author Ricardo Dal Ponte
@since 11/05/07
@version undefined
@param lEND, logical
@param WNREL
@param TITULO
@param TAMANHO
@type function
/*/
//------------------------------------------------------------------------------
Static Function R835Emp(lEND,WNREL,TITULO,TAMANHO)
	Local cRODATXT := ""
	Local nCNTIMPR := 0
	Local cCUSTO, cTRABALHO, cFAMILIA, cBEM, cIRREGU

	//Contadores de linha e pagina                                 ³
	Private li := 80 ,m_pag := 1
	//³ Verifica se deve comprimir ou nao                            ³

	nTIPO := IIF(aRETURN[4]==1,15,18)
	//³ Monta os Cabecalhos                                          ³
	Private CABEC1 := STR0039 //"Centro Custo      Descricao                                Area             Descricao"
	Private CABEC2 := STR0040 //"   Ordem  Data da OS.  Plano    Seq.   Serviço Descricao            Data Inicio Data Fim   Nome do Bem           Familia do Bem"

	Processa({|lEND| MNTR835TRB()},STR0030) //"Processando Arquivo..."

	dbSelectArea(cTRB)
	dbSetOrder(1)
	dbGoTop()

	ProcRegua(LastRec())

	cCUSTO   := ""
	cAREA    := ""

	While !Eof()

		IncProc()

		//QUEBRA POR CENTRO DE CUSTO
		If cCUSTO <> (cTRB)->CCUSTO
			cCUSTO   := (cTRB)->CCUSTO
			cAREA    := (cTRB)->CODAREA

			NgSomali(58)
			@ Li,000 Psay Substr((cTRB)->CCUSTO,1,16) Picture "@!"
			@ Li,018 Psay Substr((cTRB)->NCUSTO,1,30) Picture "@!"
			@ Li,059 Psay Substr((cTRB)->CODAREA,1,16) Picture "@!"
			@ Li,076 Psay Substr((cTRB)->NOMAREA,1,20) Picture "@!"
			NgSomali(58)
		EndIf 

		//QUEBRA POR AREA
		If cAREA <> (cTRB)->CODAREA
			cAREA    := (cTRB)->CODAREA

			NgSomali(58)
			@ Li,000 Psay Substr((cTRB)->CCUSTO,1,16) Picture "@!"
			@ Li,018 Psay Substr((cTRB)->NCUSTO,1,30) Picture "@!"
			@ Li,059 Psay Substr((cTRB)->CODAREA,1,16) Picture "@!"
			@ Li,076 Psay Substr((cTRB)->NOMAREA,1,20) Picture "@!"
			NgSomali(58)
		EndIf 

		@ Li,003 Psay (cTRB)->ORDEM  Picture "@!"
		@ Li,010 Psay DTOC((cTRB)->DTORIGI) Picture "99/99/9999"
		@ Li,023 Psay (cTRB)->PLANO Picture "@!"
		@ Li,031 Psay (cTRB)->SEQRELA Picture "@!"
		@ Li,039 Psay (cTRB)->SERVICO Picture "@!"
		@ Li,047 Psay SUBSTR((cTRB)->NOMSERV,1,20) Picture "@!"
		@ Li,068 Psay DTOC((cTRB)->DTMPINI) Picture "99/99/9999"
		@ Li,080 Psay DTOC((cTRB)->DTMPFIM) Picture "99/99/9999"
		@ Li,091 Psay SUBSTR((cTRB)->NOMBEM,1,21) Picture "@!"
		@ Li,113 Psay SUBSTR((cTRB)->NOMFAMI,1,20) Picture "@!"

		NgSomali(58)

		dbSelectArea(cTRB)
		dbSKIP()
	End

	RODA(nCNTIMPR,cRODATXT,TAMANHO)

	If aRETURN[5] = 1
		Set Printer To
		DbCommitAll()
		OurSpool(WNREL)
	EndIf
	MS_FLUSH()
	
	oTempTable:Delete()//Deleta Tabela Temporaria

Return Nil
//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTR835DT
Valida o parametro ate data  
@author Ricardo Dal Ponte
@since 11/05/07
@version undefined
@type function
/*/
//------------------------------------------------------------------------------
Function MNTR835DT()
	If  MV_PAR04 < MV_PAR03
		MsgStop(STR0041) //"Data final não pode ser inferior à data inicial!"
		Return .F.  
	EndIf
Return .T.