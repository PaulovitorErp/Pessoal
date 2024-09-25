#INCLUDE "MNTA275.ch"
#Include "Protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ MNTA275  ³ Autor ³ Elisangela Costa      ³ Data ³27/11/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Liberacao de ordens de servico com status em execucao      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function MNTA275()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Armazena variaveis p/ devolucao (NGRIGHTCLICK) 				     	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aNGBEGINPRM := NGBEGINPRM()

	Local aCores
	Local nIdx

	Private cMARCA
	Private cCADASTRO	:= OemtoAnsi(STR0001)  //"Confirmação de OS para Execução"
	Private c275TRB		:= GetNextAlias()
	Private oTmp275
	Private aRotina		:= MenuDef()
	Private aCORES275	:= {}
	Private aCORESSTA	:= {}
	Private aVETINR		:= {}
	Private aIAglu		:= {}
	Private aPESQUI		:= {STR0002,;  //"Ordem+Plano"
	STR0003,;  //"Plano+Ordem"
	STR0004,;  //"Bem+Servico"
	STR0005,;  //"Servico"
	STR0006,;  //"Status OS"
	STR0007,;  //"Dt.Original"
	STR0008}   //"Dt.Prev.Inicio"

	//Verifica se Gera Solicit. ao Armazem em vez de Solic. Compras
	Private lGeraSA		:= .F.
	Private aRetSA		:= {}
	Private cUsaIntEs	:= AllTrim(GETMV("MV_NGMNTES"))

	If NGCADICBASE('TL_NUMSA','A','STL',.F.) .And. FindFunction("NGGERASA")
		If GetNewPar("MV_NGGERSA","N") == "S" .And. cUsaIntEs == "S"
			lGeraSA := .T.
		EndIf
	EndIf

	Private aPESQUIF := {"TJ_ORDEM+TJ_PLANO",;
	"TJ_PLANO+TJ_ORDEM",;
	"TJ_CODBEM+TJ_SERVICO",;
	"TJ_SERVICO",;
	"TJ_STFOLUP",;
	"DTOS(TJ_DTORIGI)",;
	"DTOS(TJ_DTMPINI)"}

	aDBF := {}
	Aadd(aDBF,{"TJ_OK"     , "C", 2, 0 })
	Aadd(aDBF,{"TJ_ORDEM"  , "C", 6, 0 })
	Aadd(aDBF,{"TJ_PLANO"  , "C", 6, 0 })
	Aadd(aDBF,{"TJ_TIPOOS" , "C", 12,0 })
	Aadd(aDBF,{"TJ_CODBEM" , "C", 16, 0 })
	Aadd(aDBF,{"TJ_NOMBEM" , "C", 20, 0 })
	Aadd(aDBF,{"TJ_SERVICO", "C", 6, 0 })
	Aadd(aDBF,{"TJ_NOMSERV", "C", 20, 0 })
	Aadd(aDBF,{"TJ_SEQRELA", "C", 3, 0 })
	Aadd(aDBF,{"TJ_DTORIGI", "D", 8, 0 })
	Aadd(aDBF,{"TJ_DTMPINI", "D", 8, 0 })
	Aadd(aDBF,{"TJ_HOMPINI", "C", 5, 0 })
	Aadd(aDBF,{"TJ_DTMPFIM", "D", 8, 0 })
	Aadd(aDBF,{"TJ_HOMPFIM", "C", 5, 0 })
	Aadd(aDBF,{"TJ_CCUSTO" , "C", Len(SI3->I3_CUSTO), 0 })
	Aadd(aDBF,{"TJ_FLAG"   , "C", 2, 0 })
	Aadd(aDBF,{"TJ_DIFDATA", "N", 9, 0 })
	Aadd(aDBF,{"TJ_DIFHORA", "N", 9, 0 })
	Aadd(aDBF,{"TJ_RECNO"  , "N",18, 0 })
	Aadd(aDBF,{"TJ_STFOLUP", "C",06, 0 })
	Aadd(aDBF,{"TJ_DESCST" , "C",40, 0 })

	vMNT275IND  := {{"TJ_ORDEM","TJ_PLANO"},;
	{"TJ_PLANO","TJ_ORDEM"},;
	{"TJ_CODBEM","TJ_SERVICO"},;
	{"TJ_SERVICO"},;
	{"TJ_STFOLUP"},;
	{"TJ_DTORIGI"},;
	{"TJ_DTMPINI"}}

	oTmp275 := FWTemporaryTable():New(c275TRB, aDBF)
	For nIdx := 1 To Len(vMNT275IND)
		oTmp275:AddIndex( "Ind"+cValToChar(nIdx) , vMNT275IND[nIdx] )
	Next nIdx
	oTmp275:Create()

	aTRB := {}
	Aadd(aTRB,{"TJ_OK",		 NIL, " "    ,})
	Aadd(aTRB,{"TJ_ORDEM" ,	 NIL, STR0009,})  //"Ordem"
	Aadd(aTRB,{"TJ_PLANO" ,	 NIL, STR0010,})  //"Plano"
	Aadd(aTRB,{"TJ_TIPOOS",	 NIL, STR0011,})  //"Tipo OS"
	Aadd(aTRB,{"TJ_CODBEM",	 NIL, STR0012,})  //"Bem"
	Aadd(aTRB,{"TJ_NOMBEM",	 NIL, STR0013,})  //"Nome do Bem"
	Aadd(aTRB,{"TJ_SERVICO", NIL, STR0005,})  //"Servico"
	Aadd(aTRB,{"TJ_NOMSERV", NIL, STR0014,})  //"Nome do Serviço"
	Aadd(aTRB,{"TJ_SEQRELA", NIL, STR0015,})  //"Sequência"
	Aadd(aTRB,{"TJ_STFOLUP", NIL, STR0006,})  //"Status OS"
	Aadd(aTRB,{"TJ_DESCST",	 NIL, STR0016,})  //"Descrição do Status"
	Aadd(aTRB,{"TJ_DTORIGI", NIL, STR0007,})  //"Dt.Original"
	Aadd(aTRB,{"TJ_DTMPINI", NIL, STR0008,})  //"Dt.Prev.Inicio"
	Aadd(aTRB,{"TJ_HOMPINI", NIL, STR0017,})  //"Hr.Prev.Inicio"
	Aadd(aTRB,{"TJ_DTMPFIM", NIL, STR0018,})  //"Dt.Prev.Fim"
	Aadd(aTRB,{"TJ_HOMPFIM", NIL, STR0019,})  //"Hr.Prev.Fim"

	MNT275GLE() //Carrega a array da legenda

	If Len(aCORES275) < 7
		MsgInfo(STR0020+CHR(13); //"Não foi cadastrado todos os tipos de status. Cadastre todos os tipos de status"
		+ STR0021,STR0038) //"na rotina de cadastramento de status da OS.# "NÃO CONFORMIDADE"

		//Deleta o arquivo temporario fisicamente
		oTmp275:Delete()
		Return .T.
	EndIf

	Processa({ |lEnd| MNT275TRB() })

	aCores := {{"TJ_STFOLUP = '"+aCORESSTA[1][1]+"'" ,aCORESSTA[1][2]},;
	{"TJ_STFOLUP = '"+aCORESSTA[2][1]+"'" ,aCORESSTA[2][2]},;
	{"TJ_STFOLUP = '"+aCORESSTA[3][1]+"'" ,aCORESSTA[3][2]},;
	{"TJ_STFOLUP = '"+aCORESSTA[4][1]+"'" ,aCORESSTA[4][2]},;
	{"TJ_STFOLUP = '"+aCORESSTA[5][1]+"'" ,aCORESSTA[5][2]},;
	{"TJ_STFOLUP = '"+aCORESSTA[6][1]+"'" ,aCORESSTA[6][2]},;
	{"TJ_STFOLUP = '"+aCORESSTA[7][1]+"'" ,aCORESSTA[7][2]}}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	cMARCA  := GetMark()
	lINVERTE:= .F.
	lMARCA  := .T.

	dbSelectArea(c275TRB)
	dbSetOrder(05)
	dbGotop()
	MARKBROW(c275TRB,"TJ_OK","",aTRB,lINVERTE,cMARCA,"A340INVERT(c275TRB)",,,,,,,,aCores)

	//Deleta o arquivo temporario fisicamente
	oTmp275:Delete()
	dbSelectArea("STJ")
	Set Filter To
	Set Key VK_F9 To
	dbsetorder(1)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Devolve variaveis armazenadas (NGRIGHTCLICK)                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	NGRETURNPRM(aNGBEGINPRM)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MNT275LEG ³ Autor ³ Elisangela Costa      ³ Data ³27/11/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Monta a legenda                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT275LEG()
	NGLEGENDA(cCadastro,STR0024, aCORES275) //"Legenda"

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNT275VL  ³ Autor ³Elisangela Costa       ³ Data ³27/11/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Posiciona no arquivo correspondente                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNT275VL()
	dbSelectArea("STJ")
	dbSetOrder(01)
	dbSeek(xFilial("STJ")+(c275TRB)->TJ_ORDEM+(c275TRB)->TJ_PLANO)
	NGCAD01("STJ", Recno(),2)
	dbSelectArea(c275TRB)
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNT275PE  ³ Autor ³Elisangela Costa       ³ Data ³27/11/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Pesquisa as OS no browse                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNT275PE()
	Private CFILTRO := Space(60)
	cPESQUI := aPESQUI[1]
	nOPCA := 0

	Define MsDialog oDLGC Title OemToAnsi(STR0026) From 10,14 To 20,58 OF oMainWnd  //"Confirmação de OS para Execução - Pesquisa"
	@ 1.6,01  Say OemToAnsi(STR0022+":") SIZE 6,7  COLOR CLR_BLUE   //"Pesquisar"
	@ 2.4,01  MSCOMBOBOX cPESQUI ITEMS aPESQUI SIZE 125,12 OF oDLGC
	@ 3.4,01  MSGET cFILTRO Picture '@!' SIZE 160,7 Of oDLGC
	@ 5.7,29.5  Button STR0027 Size 50,12 Action (oDLGC:End())  //"&Pesquisar"
	Activate MsDialog oDLGC On Init EnchoiceBar(oDLGC,{||nOPCA:=1,oDLGC:End()},{||oDLGC:End()})

	INCLUI := .F.
	lDigServ := .T.
	nPOS := aSCAN(aPESQUI, {|x| x == cPESQUI})

	dbSelectArea(c275TRB)
	dbSetOrder(nPOS)
	dbseek(Alltrim(cFILTRO),.T.)
	cFILCMP := ""
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MNT275TRB ³ Autor ³ Elisangela Costa      ³ Data ³27/11/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processa as ordens de servico                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT275TRB()

	dbSelectArea("STJ")
	dbSetorder(1)
	dbSeek(xFILIAL("STJ"))
	ProcRegua(Reccount())
	While !Eof() .And. STJ->TJ_FILIAL = xFILIAL("STJ")

		IncProc()

		If STJ->TJ_SITUACA == "P" .And. STJ->TJ_TERMINO == "N" .And. !Empty(STJ->TJ_STFOLUP)
			If !MNT275FIL()

				dbSelectArea(c275TRB)
				DbAppend()
				(c275TRB)->TJ_ORDEM   := STJ->TJ_ORDEM
				(c275TRB)->TJ_PLANO   := STJ->TJ_PLANO
				(c275TRB)->TJ_TIPOOS := If(STJ->TJ_TIPOOS =="B",STR0012,STR0028)    //"Bem"###"Localização"
				(c275TRB)->TJ_CODBEM  := STJ->TJ_CODBEM

				(c275TRB)->TJ_NOMBEM := If(STJ->TJ_TIPOOS =="B",NGSEEK('ST9',STJ->TJ_CODBEM,1,"SubStr(ST9->T9_NOME,1,30)"),;
				NGSEEK("TAF","X2"+Substr(STJ->TJ_CODBEM,1,3),7,"SUBSTR(TAF_NOMNIV,1,30)"))

				(c275TRB)->TJ_SERVICO := STJ->TJ_SERVICO
				(c275TRB)->TJ_NOMSERV := NGSEEK("ST4",STJ->TJ_SERVICO,1,"SubStr(ST4->T4_NOME,1,30)")
				(c275TRB)->TJ_SEQRELA := STJ->TJ_SEQRELA
				(c275TRB)->TJ_DTORIGI := STJ->TJ_DTORIGI
				(c275TRB)->TJ_DTMPINI := STJ->TJ_DTMPINI
				(c275TRB)->TJ_HOMPINI := STJ->TJ_HOMPINI
				(c275TRB)->TJ_DTMPFIM := STJ->TJ_DTMPFIM
				(c275TRB)->TJ_HOMPFIM := STJ->TJ_HOMPFIM
				(c275TRB)->TJ_CCUSTO  := STJ->TJ_CCUSTO
				(c275TRB)->TJ_RECNO   := STJ->(Recno())
				(c275TRB)->TJ_STFOLUP := STJ->TJ_STFOLUP
				(c275TRB)->TJ_DESCST  := NGSEEK("TQW",STJ->TJ_STFOLUP,1,"SubStr(TQW_DESTAT,1,40)")
			EndIf
		EndIf
		dbSelectArea("STJ")
		dbSkip()
	End
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³MNT275GLE ³ Autor ³ Elisangela Costa      ³ Data ³27/11/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Carrega a array com a informacoes de legenda e semafaro     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT275GLE()
	Local xt

	For xt := 1 To 7

		dbSelectArea("TQW")
		dbSetOrder(03)
		If dbSeek(xFilial("TQW")+Str(xt,1)+" ")

			If xt == 1
				cDESCSTA := STR0029 //"Programada com Alteração de Data"
			ElseIf xt == 2
				cDESCSTA := STR0030 //"Aguardando Material"
			ElseIf xt == 3
				cDESCSTA := STR0031 //"Aguardando Mão de Obra"
			ElseIf xt == 4
				cDESCSTA := STR0032 //"Aguardando Ferramenta"
			ElseIf xt == 5
				cDESCSTA := STR0033 //"Aguardando Equiptos Auxiliares"
			ElseIf xt == 6
				cDESCSTA := STR0034 //"Aguardando Programação"
			Else
				cDESCSTA := STR0035      //"Execução"
			End

			If TQW->TQW_CORSTA = "1 "
				Aadd(aCORES275,{"BR_PINK",cDESCSTA})
				Aadd(aCORESSTA,{TQW->TQW_STATUS,"BR_PINK"})
			ElseIf TQW->TQW_CORSTA = "2 "
				Aadd(aCORES275,{"BR_VERMELHO",cDESCSTA})
				Aadd(aCORESSTA,{TQW->TQW_STATUS,"BR_VERMELHO"})
			ElseIf TQW->TQW_CORSTA = "3 "
				Aadd(aCORES275,{"BR_AMARELO",cDESCSTA})
				Aadd(aCORESSTA,{TQW->TQW_STATUS,"BR_AMARELO"})
			ElseIf TQW->TQW_CORSTA = "4 "
				Aadd(aCORES275,{"BR_AZUL",cDESCSTA})
				Aadd(aCORESSTA,{TQW->TQW_STATUS,"BR_AZUL"})
			ElseIf TQW->TQW_CORSTA = "5 "
				Aadd(aCORES275,{"BR_VERDE",cDESCSTA})
				Aadd(aCORESSTA,{TQW->TQW_STATUS,"BR_VERDE"})
			ElseIf TQW->TQW_CORSTA = "6 "
				Aadd(aCORES275,{"BR_PRETO",cDESCSTA})
				Aadd(aCORESSTA,{TQW->TQW_STATUS,"BR_PRETO"})
			ElseIf TQW->TQW_CORSTA = "7 "
				Aadd(aCORES275,{"BR_LARANJA",cDESCSTA})
				Aadd(aCORESSTA,{TQW->TQW_STATUS,"BR_LARANJA"})
			ElseIf TQW->TQW_CORSTA = "8 "
				Aadd(aCORES275,{"BR_CINZA",cDESCSTA})
				Aadd(aCORESSTA,{TQW->TQW_STATUS,"BR_CINZA"})
			ElseIf TQW->TQW_CORSTA = "9 "
				Aadd(aCORES275,{"BR_MARRON",cDESCSTA})
				Aadd(aCORESSTA,{TQW->TQW_STATUS,"BR_MARRON"})
			Else
				Aadd(aCORES275,{"BR_BRANCO",cDESCSTA})
				Aadd(aCORESSTA,{TQW->TQW_STATUS,"BR_BRANCO"})
			EndIf
		EndIf

	Next xt

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³MNT275EXC ³ Autor ³ Elisangela Costa      ³ Data ³27/11/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processa as ordens de servico liberacao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT275EXC()
	Local aSIM := {}
	Local cSTAEXEC := NGSEEK("TQW","7 ",3,"TQW_STATUS")
	Local lMARCOU := .F.

	dbselectarea(c275TRB)
	dbgotop()

	While !Eof()
		If !Empty((c275TRB)->TJ_OK)
			lMARCOU := .T.
			EXIT
		Endif
		dbselectarea(c275TRB)
		dBSkip()
	End

	If lMARCOU
		dbselectarea(c275TRB)
		dbgotop()
		ProcRegua(LastRec())
		While !Eof()

			If !Empty((c275TRB)->TJ_OK)
				laSIM := .F.
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se Manutencao e Unica verifica se ja foi confirmada em outros planos ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If NGSEEK("STF",(c275TRB)->TJ_CODBEM+(c275TRB)->TJ_SERVICO+(c275TRB)->TJ_SEQRELA,1,"TF_PERIODO") = "U"
					vaSIM := NGJAMANUNICA((c275TRB)->TJ_CODBEM,(c275TRB)->TJ_SERVICO,(c275TRB)->TJ_SEQRELA)
					laSIM := vaSIM[1]
				Endif

				dbselectarea("STJ")
				dbsetorder(1)
				dbgoto((c275TRB)->TJ_RECNO)

				If !laSIM

					nDATA := (c275TRB)->TJ_DTMPINI - STJ->TJ_DTMPINI
					nHORA := HTOM((c275TRB)->TJ_HOMPINI) - HTOM(STJ->TJ_HOMPINI)
					dINI  := STJ->TJ_DTMPINI + nDATA
					hINI  := MTOH(HTOM(STJ->TJ_HOMPINI) + nHORA)
					dFIM  := STJ->TJ_DTMPFIM + nDATA
					hFIM  := MTOH(HTOM(STJ->TJ_HOMPFIM) + nHORA)
					RecLock("STJ",.F.)
					STJ->TJ_USUARIO := If(Len(STJ->TJ_USUARIO) > 15,cUsername,Substr(cUsuario,7,15))
					STJ->TJ_TERMINO := "N"
					STJ->TJ_DTMPINI := dINI
					STJ->TJ_HOMPINI := hINI
					STJ->TJ_DTMPFIM := dFIM
					STJ->TJ_HOMPFIM := hFIM
					STJ->TJ_STFOLUP := cSTAEXEC
					MsUnLock("STJ")
					dbSelectArea(c275TRB)
					//               01        02        03         04         05        06          07       08         09         10         11      12
					Aadd(aSIM,{TJ_ORDEM,TJ_CODBEM,TJ_CCUSTO,TJ_DTMPINI,TJ_DIFDATA,TJ_DIFHORA,"cORDEM",TJ_DTMPFIM,TJ_SERVICO,TJ_SEQRELA,TJ_DTORIGI," ",;
					TJ_TIPOOS,TJ_PLANO})
				Else

					RecLock("STJ",.F.)
					STJ->TJ_SITUACA := "C"
					If NGCADICBASE("TJ_MMSYP","A","STJ",.F.)
						MsMM(,80,,Alltrim(CRLF+CRLF+vaSIM[2]),1,,,"STJ","TJ_MMSYP")
					Else
						STJ->TJ_OBSERVA := Alltrim(CRLF+CRLF+vaSIM[2])
					EndIf
					MsUnLock("STJ")

					//				//-----------------------------------------------------
					//				// Integração Mensagem Unica para Cancelamento de O.S.
					//				//-----------------------------------------------------
					//				If AllTrim(GetNewPar("MV_NGINTER","N")) == "M"  //Mensagem Unica
					//					NGMUCanMnO(STJ->(RecNo()))
					//				EndIf
				Endif

				If STJ->TJ_PLANO > "000001"
					dbSelectArea("STI")
					dbSetOrder(01)
					If dbSeek(xFilial("STI")+STJ->TJ_PLANO)
						If STI->TI_SITUACA = "P" .And. STI->TI_TERMINO = "N"
							dbselectarea("STI")
							RecLock("STI",.F.)
							STI->TI_SITUACA := "L"
							MsUnLock('STI')
						EndIf
					EndIf
				EndIf

				dbSelectArea(c275TRB)
				RecLock(c275TRB,.F.)
				dbDelete()
				MsUnLock(c275TRB)

			EndIf
			dbSelectArea(c275TRB)
			dbSkip()
		EndDo
	Else
		MsgInfo(STR0036,STR0037)    //"Não há ordem de serviço marcada para passar para o status de execução."###"ATENÇÃO"
		Return .T.
	EndIf


	Processa({|lEND| MNT275LIB(aSIM)})

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNT275FIL ³ Autor ³Elisangela Costa       ³ Data ³27/11/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Filtra as OS que ja estão no status de execucao             ³±±
±±³          ³para execuccao                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNT275FIL()
	Local lRETOSFIL := .F.

	dbSelectArea("TQW")
	dbSetOrder(01)
	If dbSeek(xFilial("TQW")+STJ->TJ_STFOLUP)
		If TQW->TQW_TIPOST <> "7
			lRETOSFIL := .T.
		EndIf
	EndIf
	dbSelectArea("STJ")

Return lRETOSFIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNT275LIB ³ Autor ³ Elisangela Costa      ³ Data ³27/11/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processa as OS confirmadas                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNT275LIB(aSIM)

	Local i,xv,nFER,nFUN,nESP,nTER
	Local aWorkfOS 	:= {}
	Local cPRODMNT	:= GetMv("MV_PRODMNT")
	Local lUseIntEs := AllTrim( SuperGetMv( 'MV_NGMNTES', .F., 'N' ) ) == 'S'
	// Define se utiliza produto alternativo
	Local lUsePrAlt := AllTrim( SuperGetMv( 'MV_MNTPRAL', .F., '2' ) ) == '1' .And. FindFunction( 'NGATUSTL' ) .And. AllTrim( SuperGetMv( 'MV_NGGERSA', .F., 'N' ) ) == 'N'

	Private aNewSc := {} // Utilizado no processo de produto alternativo
	Private aBLO := { {},{},{},{},{} }
	Private nPRO, lPROBLEMA := .f.

	// Usado na funcao NGGERASA.. Nao mexer
	Private cNumSA  := Space(Len(SCP->CP_NUM))

	cUsaIntPc  := AllTrim(GETMv("MV_NGMNTPC"))
	cUsaIntCm  := AllTrim(GetMv("MV_NGMNTCM"))
	cUsaIntEs  := AllTrim(GetMv("MV_NGMNTES"))
	cGerablCo  := AllTrim(GetMv("MV_NGCORPR"))

	// Verifica as ordens ja confirmadas em outros planos
	aVETOSPL := {}
	For xv := 1 To Len(aSIM)
		If aSIM[xv,14] > "000001"
			dbselectarea("STJ")
			dbsetorder(6)
			If dbSeek(xFILIAL("STJ")+aSIM[xv,13]+aSIM[xv,2]+aSIM[xv,9]+aSIM[xv,10]+Dtos(aSIM[xv,11]))
				While !Eof() .And. stj->tj_filial = xFILIAL("STJ") .And.;
				stj->tj_tipoos = aSIM[xv,13] .And. stj->tj_codbem = aSIM[xv,2] .And.;
				stj->tj_servico = aSIM[xv,9] .And. stj->tj_seqrela = aSIM[xv,10];
				.And. stj->tj_dtorigi = aSIM[xv,11]

					If stj->tj_situaca = "L"
						aSIM[xv,12] := "P"
						Exit
					Endif
					dbskip()
				End
			EndIf
		Endif
	Next xv

	ProcRegua(Len(aSIM))
	For i := 1 To Len(aSIM)

		// Usado na funcao NGGERASA.. Nao mexer
		cNumSA := Space(Len(SCP->CP_NUM))

		If Empty(aSIM[i,12])
			aBLO := {{},{},{},{},{}}
			IncProc()

			// Efetua o processamento no STJ
			dbSelectArea("STJ")
			dbSetOrder(01)
			If dbSeek(xFILIAL("STJ")+aSIM[i][1]+aSIM[i][14])
				// Se a Manutencao e Unica desativa a Manutencao se confirmada
				If STF->(dbSeek(xFILIAL("STF")+STJ->TJ_CODBEM+STJ->TJ_SERVICO+STJ->TJ_SEQRELA))
					If STF->TF_PERIODO == "U"
						dbSelectArea("STF")
						RecLock("STF",.F.)
						STF->TF_ATIVO := "N"
						MsUnLock("STF")
						dbSelectArea("STJ")
					Endif
				Endif

				cORDEM := STJ->TJ_ORDEM
				aSIM[i][07] := STJ->TJ_ORDEM
				dbSelectArea("STJ")
				RecLock("STJ",.F.)
				STJ->TJ_SITUACA := "L"
				STJ->TJ_USUARIO := If(Len(STJ->TJ_USUARIO) > 15,cUsername,Substr(cUsuario,7,15))
				STJ->TJ_TERMINO := "N"
				MsUnLock("STJ")
				nSTJ := Recno()
				dbSelectArea("STJ")

				//-------------------------------------------------------------
				// Integracao Mensagem Unica
				//-------------------------------------------------------------
				If AllTrim(GetNewPar("MV_NGINTER","N")) == "M"  //Mensagem Unica
					NGMUMntOrd(STJ->(RecNo()),4)
				EndIf

				AADD(aWorkfOS,STJ->TJ_ORDEM)

				If lUsePrAlt .And. lUseIntEs
					// Ajusta STL caso haja produto alternativo
					NGATUSTL( STJ->TJ_ORDEM, STJ->TJ_PLANO, STJ->TJ_CODBEM )
				EndIf

			EndIf

			dbSelectArea("STL")
			dbSetOrder(01)
			dbSeek(xFILIAL("STL")+aSIM[i][1]+aSIM[i,14])
			While !Eof() .And. STL->TL_FILIAL == xFILIAL("STL") .And.;
			STL->TL_ORDEM == aSIM[i][1] .And. STL->TL_PLANO == aSIM[i,14]

				dbselectarea("STL")
				RecLock("STL",.F.)
				STL->TL_DTINICI := STL->TL_DTINICI + aSIM[i][5]
				STL->TL_HOINICI := MTOH(HTOM(STL->TL_HOINICI) + aSIM[i][6])
				If STL->TL_TIPOREG != "P"
					STL->TL_DTFIM := STL->TL_DTFIM + aSIM[i][5]
					STL->TL_HOFIM := MTOH(HTOM(STL->TL_HOFIM) + aSIM[i][6])
				Else
					STL->TL_DTFIM := STL->TL_DTINICI
					STL->TL_HOFIM := STL->TL_HOINICI
				Endif
				MsUnLock("STL")
				STL->(dbSkip())
			End

			dbSelectArea("STK")
			dbSetorder(01)
			dbSeek(xFILIAL("STK")+aSIM[i][1]+aSIM[i,14])
			While !Eof() .And. STK->TK_FILIAL == xFILIAL("STK") .And.;
			STK->TK_ORDEM == aSIM[i][1] .And. STK->TK_PLANO == aSIM[i,14]
				dbSelectArea("STK")
				RecLock("STK",.F.)
				STK->TK_DATAINI := STK->TK_DATAINI + aSIM[i][5]
				STK->TK_HORAINI := MTOH(HTOM(STK->TK_HORAINI) + aSIM[i][6])
				STK->TK_DATAFIM := STK->TK_DATAFIM + aSIM[i][5]
				STK->TK_HORAFIM := MTOH(HTOM(STK->TK_HORAFIM) + aSIM[i][6])
				MsUnLock("STK")
				STK->(dbSkip())
			End

			dbSelectArea("ST3")
			dbSetOrder(2)
			dbSeek(xFilial("ST3") + aSIM[i][1] + aSIM[i,14])
			While !Eof() .And. ST3->T3_FILIAL == xFILIAL("ST3") .And.;
			ST3->T3_ORDEM == aSIM[i][1] .And. ST3->T3_PLANO == aSIM[i,14]
				dbSelectArea("ST3")
				RecLock("ST3",.F.)
				ST3->T3_DTINI := ST3->T3_DTINI + aSIM[i][5]
				ST3->T3_HRINI := MTOH(HTOM(ST3->T3_HRINI) + aSIM[i][6])
				ST3->T3_DTFIM := ST3->T3_DTFIM + aSIM[i][5]
				ST3->T3_HRFIM := MTOH(HTOM(ST3->T3_HRFIM) + aSIM[i][6])
				MsUnLock("ST3")
				ST3->(dbSkip())
			End
			dbSetOrder(01)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Gera ordem de Producao para a OS                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cUsaIntPc == "S"         //INTEGRACAO COM O P.C.P.
				cCODPRO  := If(FindFunction("NGProdMNT"), NGProdMNT("M")[1], cPRODMNT) //Ira verificar apenas o primeiro Produto Manutencao do parametro
				cOP      := aSIM[i][7] + "OS001"
				DTPREINI := aSIM[i][4]
				DTPREFIM := aSIM[i][8]
				GERAOP(cCODPRO,1,cOP,DTPREINI,DTPREFIM)
				//-- Grava os Campos Especificos na OP
				dbSelectArea("SC2")
				RecLock('SC2',.F.)
				SC2->C2_CC      := aSIM[I][3]
				SC2->C2_EMISSAO := MNT420DTOP(STJ->TJ_DTMPINI)
				SC2->C2_STATUS  := 'U'
				SC2->C2_OBS     := 'PLANO '+aSIM[i,14]
				MsUnLock('SC2')
			EndIf

			dbSelectArea("STK")
			dbSetOrder(01)
			dbSelectArea("STJ")
			dbSetOrder(01)

			dbSelectArea("STL")
			dbSetOrder(1)
			dbSeek(xFILIAL("STL")+aSIM[i][1]+aSIM[i,14])
			While !Eof() .And. TL_FILIAL+TL_ORDEM+TL_PLANO == xFILIAL("STL")+aSIM[i][1]+aSIM[i,14]


				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta Array para Ferramentas, Funcionarios , Especia- ³
				//³listas e Produtos; contendo Codigo, quantidade e prazo³
				//³em que sera utilizado (Data e hora Inicio e Fim).     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nTIP := 0
				_OK  := .F.
				lGeraBloq := .T.
				lGeraBloq := If(STL->TL_PLANO == "000000" .And. cGerablCo <> "S",.F.,lGeraBloq)
				cReserva := "S"
				If lGeraBloq

					If STL->TL_PLANO > "000001"
						STJ->(dbSeek(xFILIAL("STJ")+aSIM[i][01]+STL->TL_PLANO))
						STI->(dbSeek(xFILIAL("STI")+STL->TL_PLANO))

						STG->(dbSeek(xFILIAL('STG')+STJ->TJ_CODBEM + STJ->TJ_SERVICO+STJ->TJ_SEQRELA+STL->TL_TAREFA+STL->TL_TIPOREG+STL->TL_CODIGO))

						If STL->TL_TIPOREG == "F"
							_OK  := !(STI->TI_BLOQFER == "S" .And. STG->TG_RESERVA == "S")
							nTIP := If(STI->TI_BLOQITE == "S" .And. STG->TG_RESERVA == "S",0,1)
						Elseif STL->TL_TIPOREG == "M"
							_OK  := !STK->(dbSeek(xFILIAL('STK')+STL->TL_ORDEM+STL->TL_PLANO+STL->TL_TAREFA+STL->TL_CODIGO))
							nTIP := If(_OK,2,0)
						Elseif STL->TL_TIPOREG == "E"
							_OK  := !STK->(dbSeek(xFILIAL('STK')+STL->TL_ORDEM+STL->TL_PLANO+STL->TL_TAREFA+STL->TL_CODIGO))
							nTIP := If(_OK,3,0)
						Elseif STL->TL_TIPOREG == "P"
							_OK  := .t.
							cReserva := STG->TG_RESERVA
							nTIP := 4
						Elseif STL->TL_TIPOREG == "T"
							_OK  := .T.
							nTIP := 5
						Endif
					Else
						If STL->TL_TIPOREG == "F"
							_OK  := .T.
							nTIP := 1
						Elseif STL->TL_TIPOREG == "M"
							_OK  := .T.
							nTIP := 2
						Elseif STL->TL_TIPOREG == "E"
							_OK  := .T.
							nTIP := 3
						Elseif STL->TL_TIPOREG == "P"
							_OK  := .t.
							nTIP := 4
						Elseif STL->TL_TIPOREG == "T"
							_OK  := .T.
							nTIP := 5
						Endif
					EndIf

					dDATAINI := STL->TL_DTINICI + aSIM[i][05]
					dDATAFIM := STL->TL_DTFIM   + aSIM[i][05]
					dDATAINI := MTOH(HTOM(STL->TL_HOINICI)+aSIM[i][06])
					dDATAFIM := MTOH(HTOM(STL->TL_HOFIM)  +aSIM[i][06])
					cALMOXA  := Space(len(sb1->b1_locpad))

					If STL->TL_TIPOREG = 'P'
						cALMOXA := STL->TL_LOCAL
					Endif

					If nTIP > 0
						Aadd(aBLO[nTIP], {STL->TL_TAREFA       ,;
						STL->TL_CODIGO       ,;
						If(STL->TL_TIPOREG$"E/F",STL->TL_QUANREC,STL->TL_QUANTID),;
						STL->TL_DTINICI          ,;
						STL->TL_HOINICI          ,;
						STL->TL_DTFIM            ,;
						STL->TL_HOFIM            ,;
						STL->TL_ORDEM            ,;
						aSIM[i,14]               ,;
						_OK                      ,;
						aSIM[i][3]               ,;
						aSIM[i][7]               ,;
						cALMOXA                  ,;   //13 Local Almoxarifado
						STL->TL_UNIDADE          ,;   //14 Unidade do insumo
						Space(Len(SC1->C1_NUM))  ,;   //15 Numero solicitacao compra
						Space(Len(SC1->C1_ITEM)) ,;   //16 Item da solicitacao de compra
						0.00                     ,;   //17 QUANTIDADE DO ESTOQUE DA OPERACAO   TL_QTDOPER
						Space(Len(SB2->B2_LOCAL)),;   //18 CODIGO DO ALMOXARIFADO OPERACAO     TL_ALMOPERA
						0.00                     ,;   //19 QUANTIDADE DO ESTOQUE DA MATRIZ     TL_QTDOMAT
						Space(Len(SB2->B2_LOCAL)),;   //20 CODIGO DO ALMOXARIFADO DA MATRIZ    TL_ALMOMAT
						0.00,;                        //21 QUANTIDADE DA SOLICITACAO DE COMPRA TL_QTDSC1
						cReserva})
					EndIf
				EndIf
				STL->(dbSkip())
			End

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetua o bloqueio de Ferramentas                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nFER := 1 To Len(aBLO[1])
				If aBLO[1][nFER][10]
					A330FER(aBLO[1][nFER])
				Else
					A340FER(aBLO[1][nFER])
				Endif
			Next

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetua o bloqueio de Mao de Obras (FUNCIONARIO)            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nFUN := 1 TO Len(aBLO[2])
				If aBLO[2][nFUN][10]
					A330FUN(aBLO[2][nFUN])
				Endif
			Next

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetua o bloqueio de Especialistas (FUNCIONARIO)           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nESP := 1 To Len(aBLO[3])
				If aBLO[3][nESP][10]
					A330ESP(aBLO[3][nESP])
				Endif
			Next

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetua o bloqueio de Produtos                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPRO := 1
			While nPRO <= Len(aBLO[4])
				IncProc()
				cTAREFA   := aBLO[4][nPRO][1]
				nQTDCOMP  := aBLO[4][nPRO][3]
				cOPrin    := AllTrim(aBLO[4][nPRO][8]) + "OS001"
				cCodPro := Left(aBLO[4][nPRO][2], Len(SB1->B1_COD))
				cOP     := AllTrim(aBLO[4][nPRO][8]) + "OS001"
				cLOCSTL := aBLO[4][nPRO][13]

				// AGLUTINACAO POR PRODUTO E ALMAXARIFADO
				nPosSC := Ascan(aIAglu,{|x| x[1]+x[2] = cCodPro+cLOCSTL})
				If nPosSC > 0
					aIAglu[nPosSC][3] += nQTDCOMP
				Else
					aAdd(aIAglu,{cCodPro,cLOCSTL,nQTDCOMP,cOp,cTAREFA,STJ->TJ_CCUSTO,;
					aBLO[4][nPRO][4],aBLO[4][nPRO][22],STJ->TJ_ORDEM,STJ->TJ_PLANO})
				EndIf

				nPRO++
			End

			// ESTA FUNCAO ESTA NO FONTE NGUTIL02 UTILIZA A MATRIZ aIAglu
			NGINTCOMPEST(STJ->TJ_DTMPINI,STJ->TJ_DTMPFIM,"MNTA275")
			// FIM DO NOVO PROCESSO DE GERACAO COMPRAS E EMPENHO

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetua o bloqueio de TERCEIROS                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nTER := 1 To Len(aBLO[5])
				If aBLO[5][nTER][10]
					a340TER(aBLO[5][nTER],aBLO[5][nTER][13],;
					aBLO[5][nTER][3],aBLO[5][nTER][14],.f.,nTER)
				EndIf
			Next
			// Limpa array
			aIAglu := {}
		EndIf

	Next

	If FindFunction("MNTW215") .AND. Len(aWorkfOS) > 0
		MNTW215(,aWorkfOS)
	Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³Elisangela Costa       ³ Data ³27/11/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
	Local aRotina := {{STR0022 ,"MNT275PE" ,  0 , 1},; //"Pesquisar"
	{STR0023 ,"MNT275VL"  , 0 , 2},; //"Visualizar"
	{STR0024 ,"MNT275LEG" , 0 , 2},; //"Legenda"
	{STR0025 ,"MNT275EXC" , 0 , 4}}  //"Conf.Liberação"
Return(aRotina)
