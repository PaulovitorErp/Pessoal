#INCLUDE "MNTC280.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MNTC280  ³ Autor ³ Ricardo Dal Ponte     ³ Data ³05/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consulta Gerencial do Modulo de Solicitacao de Servicos     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTC280()

	// Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	Local aNGBEGINPRM := NGBEGINPRM()
	Local oSplitter, oPanel1, oPanel2
	Local nI
	Local oDlg
	Local oGetDados
	Local cHeaderLST := ""

	Private lALLMARK := .T.
	Private lGEROURR := .F.

	Private cCHAVEGRAF := ""
	Private oLabel1, oLabel2
	Private oTitCENCUS, oDeCENCUS, oAteCENCUS, oAteBem
	Private oTiSERV, oDeSERV, oAteSERV
	Private oBtnClear, oBtnFilt, oBtnVSS, oBtnVOS,oBtnIMPR
	Private oTitABE, oABDE, oABATE
	Private oTitENC, oENCDE, oENCATE
	Private oTPGRAF, cTPGRAF, aTPGRAF := {}
	Private oINFOGRAF, cINFOGRAF, aINFOGRAF := {}

	Private cDETLINE := ""
	Private oFont14  := TFont():New("Arial",8,14,,.t.,,.f.,,.f.,.f.)
	Private oFont14n := TFont():New("Arial",7,14,,.F.,,.f.,,.f.,.f.)
	Private cTPTABLE := ""
	Private nCUSTO := 0
	Private cATRASO, cDESATRASO
	Private cCDRESP, cNMRESP
	Private cFilPRI, cFilDET, cFilSEQ
	Private nUsado := 0
	Private nx  := 0
	Private oMARKRES, oMARKDET, lMARKRES := .F., lMARKDET := .F.
	Private oDLG1, OLIST1
	Private aORDEM := {}, aORDEMF := {}, oORDEM, cPesq := "", oTitFil
	Private aTPANALISE := {}, oTPANALISE, cTPANALISE := ""
	Private aAGRUPA := {}, oAGRUPA, cAGRUPA := ""
	Private aTRB,aDBF, aTRBD, aDBFDET

	Private lGerar := .F., lDetalhar := .F., lFILTROS := .F.
	Private cDATADE  := CTOD("  /  /  ")
	Private cDATAATE := CTOD("  /  /  ")
	Private cABDE    := CTOD("  /  /  ")
	Private cABATE   := CTOD("  /  /  ")
	Private cENCDE   := CTOD("  /  /  ")
	Private cENCATE  := CTOD("  /  /  ")
	Private lRefresh := .T.
	Private aHeaderRE := {}
	Private aHeaderDE := {}
	Private aCols := {}

	Private cDeBem   := Space(Len(TQB->TQB_CODBEM))
	Private cAteBem  := Replicate("Z",Len(cDeBem))
	Private cF3CTTSI3 := If(CtbInUse(), "CTT", "SI3")
	Private cDeCENCUS  := Space(Len(TQB->TQB_CCUSTO))
	Private cAteCENCUS := Replicate("Z",Len(cDeCENCUS))
	Private cDeSERV  := Space(Len(TQB->TQB_CDSERV))
	Private cAteSERV := Replicate("Z",Len(cDeSERV))
	PRIVATE cARQ1
	Private aVETINR   := {}
	Private aCriaTrab := {}
	Private cARQPZ01,cIndPz01
	Private cARQPZ02,cIndPz02
	Private cARQPZ03,cIndPz03
	Private cARQPZ04,cIndPz04
	Private cARQPZ05,cIndPz05
	Private cARQSZ01,cIndSz01
	Private cARQSZ02,cIndSz02
	Private cARQSZ03,cIndSz03
	Private cARQSZ04,cIndSz04
	Private cARQSZ05,cIndSz05
	Private cARQSZ06,cIndSz06
	Private cARQCZ01,cIndCz01
	Private cARQCZ02,cIndCz02
	Private cARQCZ03,cIndCz03
	Private cARQCZ04,cIndCz04
	Private cARQOZ01,cIndOz01
	Private cARQOZ02,cIndOz02
	Private cARQOZ03,cIndOz03
	Private cARQOZ04,cIndOz04
	Private cARQAZ01,cIndAz01
	Private cARQAZ02,cIndAz02
	Private cARQAZ03,cIndAz03
	Private cARQAZ04,cIndAz04
	Private cIndD
	Private cARQGRAF,cIndGraf

	Private lDTAB := .T.
	Private lDTAE := .T.

	Private nCentroCusto := 0
	Private nFilial 	 := 0
	Private lPrin        := .T.
	Private lFacilities  := SuperGetMv("MV_NG1FAC",.F.,"2") == '1'
	Private cTRBD        := GetNextAlias()
	Private cTRBPZ01     := GetNextAlias()
	Private cTRBPZ02     := GetNextAlias()
	Private cTRBPZ03     := GetNextAlias()
	Private cTRBPZ04     := GetNextAlias()
	Private cTRBPZ05     := GetNextAlias()
	Private cTRBSZ01     := GetNextAlias()
	Private cTRBSZ02     := GetNextAlias()
	Private cTRBSZ03     := GetNextAlias()
	Private cTRBSZ04     := GetNextAlias()
	Private cTRBSZ05     := GetNextAlias()
	Private cTRBSZ06     := GetNextAlias()
	Private cTRBCZ01     := GetNextAlias()
	Private cTRBCZ02     := GetNextAlias()
	Private cTRBCZ03     := GetNextAlias()
	Private cTRBCZ04     := GetNextAlias()
	Private cTRBOZ01     := GetNextAlias()
	Private cTRBOZ02     := GetNextAlias()
	Private cTRBOZ03     := GetNextAlias()
	Private cTRBOZ04     := GetNextAlias()
	Private cTRBAZ01     := GetNextAlias()
	Private cTRBAZ02     := GetNextAlias()
	Private cTRBAZ03     := GetNextAlias()
	Private cTRBAZ04     := GetNextAlias()
	Private cTRBGRAF     := GetNextAlias()
	Private oTmpTRBD     := Nil
	Private oTmpZ01      := Nil
	Private oTmpZ02      := Nil
	Private oTmpZ03      := Nil
	Private oTmpZ04      := Nil
	Private oTmpZ05      := Nil
	Private oTmpSZ01     := Nil
	Private oTmpSZ02     := Nil
	Private oTmpSZ03     := Nil
	Private oTmpSZ04     := Nil
	Private oTmpSZ05     := Nil
	Private oTmpSZ06     := Nil
	Private oTmpCZ01     := Nil
	Private oTmpCZ02     := Nil
	Private oTmpCZ03     := Nil
	Private oTmpCZ04     := Nil
	Private oTmpOZ01     := Nil
	Private oTmpOZ02     := Nil
	Private oTmpOZ03     := Nil
	Private oTmpOZ04     := Nil
	Private oTmpAZ01     := Nil
	Private oTmpAZ02     := Nil
	Private oTmpAZ03     := Nil
	Private oTmpAZ04     := Nil
	Private oTmpGRAF     := Nil

	If lFacilities
		MsgStop(STR0238+CHR(10)+; //"Esta consulta é exclusiva de ambientes sem Facilities."
		STR0239,STR0216) //"Para ambientes integrados ao Facilities (MV_NG1FAC = 1) deve-se utilizar a consulta Gerencial de SS (MNTC286)."
		Return .F.
	EndIf

	CursorWait()

	aORDEM  := {STR0001,; //"Solicitação"
				STR0002,; //"Bem+Serviço"
				STR0003,; //"Bem+Centro de Custo+Serviço"
				STR0004,; //"Bem+Executante+Serviço"
				STR0005,; //"Bem+Data Abertura+Prioridade"
				STR0006,; //"Bem+Prioridade+Data Abertura"
				STR0007,; //"Solicitante+Solicitacao"
				STR0008,; //"Solicitante+Centro de Custo"
				STR0009,; //"Solicitante+Serviço+Data Abertura"
				STR0010,; //"Solicitante+Serviço+Prioridade"
				STR0011,; //"Data Abertura+Solicitacao"
				STR0012,; //"Data Abertura+Centro de Custo"
				STR0013,; //"Data Abertura+Prioridade"
				STR0014,; //"Data Abertura+Executante"
				STR0015,; //"Data Encerramento+Solicitacao"
				STR0016,; //"Data Encerramento+Centro de Custo"
				STR0017,; //"Data Encerramento+Prioridade"
				STR0018,; //"Data Encerramento+Executante"
				STR0019,; //"Serviço+Centro de Custo"
				STR0020,; //"Serviço+Executante"
				STR0021,; //"Serviço+Data Abertura+Prioridade"
				STR0022} //"Serviço+Prioridade+Data Abertura"

	aORDEMF  := {"DT_SOLICI",;
				 "DT_CODBEM+DT_CDSERV",;
				 "DT_CODBEM+DT_CCUSTO+DT_CDSERV",;
				 "DT_CODBEM+DT_CDEXEC+DT_CDSERV",;
				 "DT_CODBEM+DTOS(DT_DTABER)+DT_PRIORI",;
				 "DT_CODBEM+DT_PRIORI+DTOS(DT_DTABER)",;
				 "DT_CDSOLI+DT_SOLICI",;
				 "DT_CDSOLI+DT_CCUSTO",;
				 "DT_CDSOLI+DT_CDSERV+DTOS(DT_DTABER)",;
				 "DT_CDSOLI+DT_CDSERV+DT_PRIORI",;
				 "DTOS(DT_DTABER)+DT_SOLICI",;
				 "DTOS(DT_DTABER)+DT_CCUSTO",;
				 "DTOS(DT_DTABER)+DT_PRIORI",;
				 "DTOS(DT_DTABER)+DT_CDEXEC",;
				 "DTOS(DT_DTFECH)+DT_SOLICI",;
				 "DTOS(DT_DTFECH)+DT_CCUSTO",;
				 "DTOS(DT_DTFECH)+DT_PRIORI",;
				 "DTOS(DT_DTFECH)+DT_CDEXEC",;
				 "DT_CDSERV+DT_CCUSTO",;
				 "DT_CDSERV+DT_CDEXEC",;
				 "DT_CDSERV+DTOS(DT_DTABER)+DT_PRIORI",;
				 "DT_CDSERV+DT_PRIORI+DTOS(DT_DTABER)"}

	aTPANALISE := {STR0023, STR0024, STR0025, STR0026, STR0027} //"Pendências"###"Satisfação"###"Custo/Tempo"###"Os geradas"###"Atendimento"

	//Identifica o Tipo de Consulta
	cTPANALISE := aTPANALISE[1]
	C280TPCON()
	cAGRUPA    := aAGRUPA[1]
	cPesq      := aORDEM[1]

	//Cria Arquivos Temporarios para o detalhamento das SS
	C280WDET()

	//Cria Arquivos Temporarios para os totais
	C280WTOT()

	DEFINE MSDIALOG oDlg1 Title STR0028 FROM 90,0 TO 660,1015 Of oMainWnd PIXEL COLOR CLR_BLACK,RGB(225,225,225) //"Consulta Gerencial do Módulo de Solicitação de Serviços"

		@ 06,005 say STR0029 SIZE 300,08 OF oDlg1  PIXEL COLOR RGB(0,100,30) //"Tipo de Análise"

		@ 14,005 MSCOMBOBOX oTPANALISE VAR cTPANALISE ITEMS aTPANALISE SIZE 70,12 OF oDlg1 PIXEL ON CHANGE (C280TPCON())
		oGrpFold6   := TGroup():New( 06,083,43,155,STR0030,oDlg1,RGB(0,100,30),CLR_WHITE,.T.,.F. )//"Pesquisar entre ?"
		@ 14,85 say oTitBemDe Var STR0214 SIZE 120,08 OF oGrpFold6  Pixel Font oFont14 COLOR RGB(0,85,150) //"De:"
		@ 14,100 MsGet cDATADE  Picture '99/99/9999' Size 45,08 Pixel Valid C280DTINI() HasButton
		@ 28,85 say oTitAte Var STR0215 SIZE 120,08 OF oGrpFold6  Pixel Font oFont14 COLOR RGB(0,85,150) //"Até:"
		@ 28,100 MsGet cDATAATE Picture '99/99/9999' Size 45,08 Pixel Valid C280DTFIM(cDATADE, cDATAATE) HasButton

		@ 30,005 say STR0032 SIZE 300,08 OF oDlg1  PIXEL COLOR RGB(0,100,30) //"Visualizar por:"

		//Monta Browse com resumo na tela
		C280BRWRE(cAGRUPA)

		@ 50,105 Button STR0033 Of oDlg1 Size 50,12 Pixel Action (C280GERAR(cTPANALISE)) //"&Gerar Consulta"

		//Monta tela com os componentes para filtrar o browse de detalhes
		@ 00,159 To 312,160 LABEL oLabel1 Prompt "" OF oDlg1 PIXEL
		@ 00,160 To 312,161 LABEL oLabel2 Prompt "" OF oDlg1 PIXEL

		oGrpFold1   := TGroup():New( 02,173,41,270,"Bem:",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
		@ 14,175 say oTitBemDe1 Var STR0214 SIZE 120,08 OF oGrpFold1  Pixel Font oFont14 COLOR RGB(0,85,150) //"De:"
		@ 14,190 MsGet oDeBem Var cDeBem  Size 65,08 Of oGrpFold1 Pixel Picture "!@" F3 "ST9" Valid If(Empty(cDeBem),.t.,ExistCpo('ST9',cDeBem)) HasButton
		@ 28,175 say oTitAte1 Var STR0215 SIZE 120,08 OF oGrpFold1  Pixel Font oFont14 COLOR RGB(0,85,150) //"Até:"
		@ 28,190 MsGet oAteBem Var cAteBem Size 65,08 Of oGrpFold1 Pixel Picture "!@" F3 "ST9" Valid If(AteCodigo('ST9',cDeBem,cAteBem,Len(cDeBem)),.t.,.f.) HasButton

		oGrpFold2   := TGroup():New( 44,173,80,270,"Centro de Custo:",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
		@ 52,175 say oTitBemDe2 Var STR0214 SIZE 120,08 OF oGrpFold2  Pixel Font oFont14 COLOR RGB(0,85,150) //"De:"
		@ 52,190 MsGet oDeCENCUS Var cDeCENCUS  Size 75,08 Of oGrpFold2 Pixel Picture "!@" F3 cF3CTTSI3 Valid If(Empty(cDeCENCUS),.t.,ExistCpo(cF3CTTSI3,cDeCENCUS)) HasButton
		@ 66,175 say oTitAte2 Var STR0215 SIZE 120,08 OF oGrpFold2  Pixel Font oFont14 COLOR RGB(0,85,150) //"Até:"
		@ 66,190 MsGet oAteCENCUS Var cAteCENCUS Size 75,08 Of oGrpFold2 Pixel Picture "!@" F3 cF3CTTSI3 Valid If(AteCodigo(cF3CTTSI3,cDeCENCUS,cAteCENCUS, Len(cDeCENCUS)),.t.,.f.) HasButton

		oGrpFold3   := TGroup():New( 02,281,41,350,"Serviço:",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
		@ 14,283 say oTitBemDe3 Var STR0214 SIZE 120,08 OF oGrpFold3  Pixel Font oFont14 COLOR RGB(0,85,150) //"De:"
		@ 14,298 MsGet oDeSERV Var cDeSERV  Size 45,08 Of oGrpFold3 Pixel Picture "!@" F3 "TQ3" Valid If(Empty(cDeSERV),.t.,ExistCpo('TQ3',cDeSERV)) HasButton
		@ 28,283 say oTitAte3 Var STR0215 SIZE 120,08 OF oGrpFold3  Pixel Font oFont14 COLOR RGB(0,85,150) //"Até:"
		@ 28,298 MsGet oAteSERV Var cAteSERV Size 45,08 Of oGrpFold3 Pixel Picture "!@" F3 "TQ3" Valid If(AteCodigo('TQ3',cDeSERV,cAteSERV,Len(cDeSERV)),.t.,.f.) HasButton

		oGrpFold4   := TGroup():New( 44,281,80,350,"Abertura:",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
		@ 52,283 say oTitBemDe4 Var STR0214 SIZE 120,08 OF oGrpFold4  Pixel Font oFont14 COLOR RGB(0,85,150) //"De:"
		@ 52,298 MsGet oABDE Var cABDE  Picture '99/99/9999' Size 45,08 Pixel Valid C280ADINI() When lDTAB HasButton
		@ 66,283 say oTitAte4 Var STR0215 SIZE 120,08 OF oGrpFold4  Pixel Font oFont14 COLOR RGB(0,85,150) //"Até:"
		@ 66,298 MsGet oABATE Var cABATE Picture '99/99/9999' Size 45,08 Pixel Valid C280DTFIM(cABDE, cABATE) When lDTAB HasButton

		oGrpFold5   := TGroup():New( 44,360,80,428,"Encerramento:",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
		@ 52,363 say oTitBemDe5 Var STR0214 SIZE 120,08 OF oGrpFold5  Pixel Font oFont14 COLOR RGB(0,85,150) //"De:"
		@ 52,378 MsGet oENCDE Var cENCDE  Picture '99/99/9999' Size 45,08 Pixel Valid C280EDINI() When lDTAE HasButton
		@ 66,363 say oTitAte5 Var STR0215 SIZE 120,08 OF oGrpFold5  Pixel Font oFont14 COLOR RGB(0,85,150) //"Até:"
		@ 66,378 MsGet oENCATE Var cENCATE Picture '99/99/9999' Size 45,08 Pixel Valid C280DTFIM(cENCDE, cENCATE) When lDTAE HasButton

		@ 06,360 say oTitFil Var STR0038 SIZE 100,08 OF oDlg1  Pixel Font oFont14 COLOR RGB(0,85,150) //"Organizar Detalhes por:"
		@ 14,360 MSCOMBOBOX oORDEM VAR cPesq ITEMS aORDEM SIZE 120,12 OF oDlg1 PIXEL ON CHANGE ()

		C280VCLARF()
		lFILTROS := .T.

		@ 28,430 Button oBtnClear Prompt STR0039   Of oDlg1 Size 50,12 Pixel Action(C280VCLARF()) //"&Limpar Filtro"
		@ 42,430 Button oBtnFilt  Prompt STR0040  Of oDlg1 Size 50,12 Pixel Action(C280FILDET()) //"&Filtrar Detalhes"

		@ 265,344 Button oBtnVSS   Prompt STR0041   Of oDlg1 Size 50,10 Pixel Action(C280CHASS()) //"Visualizar SS"
		If AllTrim(GetNewPar("MV_NGMULOS","N")) <> "S"
			@ 265,395 Button oBtnVOS   Prompt STR0042   Of oDlg1 Size 50,10 Pixel Action(C280CHAOS()) //"Visualizar OS"
		EndIf
		@ 265,450 Button oBtnIMPR  Prompt STR0043       Of oDlg1 Size 50,10 Pixel Action(C280IMPRD()) //"&Imprimir"

		//Monta Browse com o detalhamento das SS na tela
		@ 265,003 Button STR0045  Of oDlg1 Size 50,10 Pixel When lGEROURR Action (C280DETFIL())//"&Detalhar"
		@ 265,054 Button STR0044  Of oDlg1 Size 50,10 Pixel When lGEROURR Action (C280TGRAF())  //"&Gráfico"
		@ 265,105 Button STR0235  Of oDlg1 Size 50,10 Pixel Action(oDlg1:End())  //"Sair"

		C280VFILTR()
		CursorArrow()

	Activate MsDialog oDLG1

	C280WCLEAR()

	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	NGRETURNPRM(aNGBEGINPRM)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³C280DTINI ³ Autor ³ Ricardo Dal Ponte     ³ Data ³11/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a data inicio da consulta                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .t.,.f.                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C280DTINI()
If Vazio(cDATADE)
   cDATAATE := CTOD("  /  /  ")
Endif
Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³C280ADINI ³ Autor ³ Ricardo Dal Ponte     ³ Data ³15/02/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a data inicio da abertura                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .t.,.f.                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C280ADINI()
If Vazio(cABDE)
   cABATE := CTOD("  /  /  ")
Endif
Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³C280EDINI ³ Autor ³ Ricardo Dal Ponte     ³ Data ³18/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a data inicio do encerramento                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .t.,.f.                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C280EDINI()
If Vazio(cENCDE)
   cENCATE := CTOD("  /  /  ")
Endif
Return .t.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³C280DTFIM ³ Autor ³ Ricardo Dal Ponte     ³ Data ³11/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a data fim da consulta                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .t.,.f.                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C280DTFIM(cDATAD, cDATAA)
If Vazio(cDATAA)
   If !Vazio(cDATAD)
      MsgInfo(STR0046,STR0047) //"Data Final da Consulta deve ser informada."###"NAO CONFORMIDADE"
      Return .F.
   EndIf
Else
   If Vazio(cDATAD)
      MsgInfo(STR0048,STR0047) //"Data Final da Consulta não deve ser informada."###"NAO CONFORMIDADE"
      Return .F.
   Else
      If cDATAD > cDATAA
         MsgInfo(STR0049,STR0047) //"Data Final da Consulta não pode ser anterior a Data Inicial."###"NAO CONFORMIDADE"
         Return .F.
      Endif
   EndIf
Endif
Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C280WTOT  ³ Autor ³ Ricardo Dal Ponte     ³ Data ³17/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria Arquivos Temporarios para os totais                    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C280WTOT()
   C280WPENDE() //Cria Arquivos Temporarios para a consulta de Analise de Pendencias
   C280WSATIS() //Cria Arquivos Temporarios para a consulta de Analise de Satisfacao
   C280WCUSTE() //Cria Arquivos Temporarios para a consulta de Analise de Custo/Tempo da SS
   C280WOSGER() //Cria Arquivos Temporarios para a consulta de Analise das OS Geradas
   C280WATEND() //Cria Arquivos Temporarios para a consulta de Analise de Atendimento
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C280WDET  ³ Autor ³ Ricardo Dal Ponte     ³ Data ³11/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria Arquivos Temporarios para o detalhamento das SS        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C280WDET()

	//Arquivo temporario da consulta DETALHES DAS SS
	aDBFDET:= {}

	//Verifica o Tamanho da Filial e do Centro de Custo
	nFilial      := If(TamSX3("TQB_FILIAL")[1] >= 2,TamSX3("TQB_FILIAL")[1],2)
	nCentroCusto := If(TamSX3("CTT_CUSTO")[1]  >= 9, TamSX3("CTT_CUSTO")[1],9)

	//CAMPOS PARA CRIAR ARQUIVO TEMPORARIO
	aAdd(aDBFDET,{"DT_FILIAL", "C", nFilial, 0 })
	aAdd(aDBFDET,{"DT_SOLICI", "C", 06, 0 })
	aAdd(aDBFDET,{"DT_TIPOS" , "C", 01, 0 })
	aAdd(aDBFDET,{"DT_TIPOSS", "C", 11, 0 })
	aAdd(aDBFDET,{"DT_CODBEM", "C", 16, 0 })
	aAdd(aDBFDET,{"DT_NOMBEM", "C", 20, 0 })
	aAdd(aDBFDET,{"DT_CCUSTO", "C", nCentroCusto, 0 })
	aAdd(aDBFDET,{"DT_NOMCUS", "C", 20, 0 })
	aAdd(aDBFDET,{"DT_CENTRA", "C", 06, 0 })
	aAdd(aDBFDET,{"DT_NOMCTR", "C", 20, 0 })
	aAdd(aDBFDET,{"DT_LOCALI", "C", 06, 0 })
	aAdd(aDBFDET,{"DT_NOMLOC", "C", 20, 0 })
	aAdd(aDBFDET,{"DT_DTABER", "D", 08, 0 })
	aAdd(aDBFDET,{"DT_HOABER", "C", 05, 0 })
	aAdd(aDBFDET,{"DT_USUARI", "C", 30, 0 })
	aAdd(aDBFDET,{"DT_RAMAL" , "C", 10, 0 })
	aAdd(aDBFDET,{"DT_SOLUCA", "C", 01, 0 })
	aAdd(aDBFDET,{"DT_DOLUCA", "C", 20, 0 })
	aAdd(aDBFDET,{"DT_FUNEXE", "C", 06, 0 })
	aAdd(aDBFDET,{"DT_NOMFUN", "C", 20, 0 })
	aAdd(aDBFDET,{"DT_DTFECH", "D", 08, 0 })
	aAdd(aDBFDET,{"DT_HOFECH", "C", 05, 0 })
	aAdd(aDBFDET,{"DT_TEMPO" , "C", Len(TQB->TQB_TEMPO), 0 })
	aAdd(aDBFDET,{"DT_ORDEM" , "C", 06, 0 })
	aAdd(aDBFDET,{"DT_OSCUST", "N", 15, 6 })
	aAdd(aDBFDET,{"DT_CDSERV", "C", 06, 0 })
	aAdd(aDBFDET,{"DT_NMSERV", "C", 20, 0 })
	aAdd(aDBFDET,{"DT_CDSOLI", "C", 15, 0 })
	aAdd(aDBFDET,{"DT_NMSOLI", "C", 25, 0 })
	aAdd(aDBFDET,{"DT_CDEXEC", "C", TamSX3("TQB_CDEXEC")[1], 0 })
	aAdd(aDBFDET,{"DT_NMEXEC", "C", 20, 0 })
	aAdd(aDBFDET,{"DT_PRIORI", "C", 01, 0 })
	aAdd(aDBFDET,{"DT_DRIORI", "C", 10, 0 })
	aAdd(aDBFDET,{"DT_PSAP"  , "C", 01, 0 })
	aAdd(aDBFDET,{"DT_DSAP"  , "C", 15, 0 })
	aAdd(aDBFDET,{"DT_PSAN"  , "C", 01, 0 })
	aAdd(aDBFDET,{"DT_DSAN"  , "C", 15, 0 })

	aAdd(aDBFDET,{"DT_CODMSS", "C", 06, 0 })
	aAdd(aDBFDET,{"DT_CODMSO", "C", 06, 0 })
	aAdd(aDBFDET,{"DT_CATRAS", "C", 02, 0 })
	aAdd(aDBFDET,{"DT_DATRAS", "C", 20, 0 })
	dbSelectArea("TQ3")
	aAdd(aDBFDET,{"DT_CDRESP", "C", Len(TQ3->TQ3_CDRESP), 0 })
	aAdd(aDBFDET,{"DT_NMRESP", "C", 20, 0 })

	cIndD    := {{"DT_FILIAL","DT_SOLICI"}}
	oTmpTRBD := NGFwTmpTbl(cTRBD,aDBFDET,cIndD)

	//CAMPOS PARA CRIAR BROWSE NA TELA
	aTRBD:= {}

	aAdd(aTRBD,{"DT_SOLICI", NIL, NGSEEKDIC("SX3","TQB_SOLICI",2,"X3_TITULO"),})
	aAdd(aTRBD,{"DT_TIPOSS", NIL, NGSEEKDIC("SX3","TQB_TIPOSS",2,"X3_TITULO"),})
	aAdd(aTRBD,{"DT_CODBEM", NIL, NGSEEKDIC("SX3","TQB_CODBEM",2,"X3_TITULO"),})
	aAdd(aTRBD,{"DT_NOMBEM", NIL, NGSEEKDIC("SX3","TQB_NOMBEM",2,"X3_TITULO"),})
	aAdd(aTRBD,{"DT_CCUSTO", NIL, NGSEEKDIC("SX3","TQB_CCUSTO",2,"X3_TITULO"),})
	aAdd(aTRBD,{"DT_NOMCUS", NIL, NGSEEKDIC("SX3","TQB_NOMCUS",2,"X3_TITULO"),})
	aAdd(aTRBD,{"DT_NOMCTR", NIL, NGSEEKDIC("SX3","TQB_NOMCTR",2,"X3_TITULO"),})
	aAdd(aTRBD,{"DT_NOMLOC", NIL, NGSEEKDIC("SX3","TQB_NOMLOC",2,"X3_TITULO"),})
	aAdd(aTRBD,{"DT_DTABER", NIL, NGSEEKDIC("SX3","TQB_DTABER",2,"X3_TITULO"),})
	aAdd(aTRBD,{"DT_HOABER", NIL, NGSEEKDIC("SX3","TQB_HOABER",2,"X3_TITULO"),})
	aAdd(aTRBD,{"DT_DOLUCA", NIL, NGSEEKDIC("SX3","TQB_SOLUCA",2,"X3_TITULO"),})
	aAdd(aTRBD,{"DT_DTFECH", NIL, NGSEEKDIC("SX3","TQB_DTFECH",2,"X3_TITULO"),})
	aAdd(aTRBD,{"DT_HOFECH", NIL, NGSEEKDIC("SX3","TQB_HOFECH",2,"X3_TITULO"),})
	aAdd(aTRBD,{"DT_TEMPO",  NIL, NGSEEKDIC("SX3","TQB_TEMPO" ,2,"X3_TITULO"),})

	If AllTrim(GetNewPar("MV_NGMULOS","N")) <> "S"
		aAdd(aTRBD,{"DT_ORDEM",  NIL, NGSEEKDIC("SX3","TQB_ORDEM",2,"X3_TITULO"),})
	EndIf

	aAdd(aTRBD,{"DT_OSCUST",  NIL, STR0050,}) //"Custo da OS"
	aAdd(aTRBD,{"DT_NMSERV", NIL, NGSEEKDIC("SX3","TQB_NMSERV",2,"X3_TITULO"),})
	aAdd(aTRBD,{"DT_NMSOLI", NIL, NGSEEKDIC("SX3","TQB_NMSOLI",2,"X3_TITULO"),})
	aAdd(aTRBD,{"DT_NMEXEC", NIL, NGSEEKDIC("SX3","TQB_NMEXEC",2,"X3_TITULO"),})
	aAdd(aTRBD,{"DT_DRIORI", NIL, NGSEEKDIC("SX3","TQB_PRIORI",2,"X3_TITULO"),})

	If lFacilities
		aAdd(aTRBD,{"DT_DSAP"  , NIL, NGSEEKDIC("SX3","TQB_SATISF",2,"X3_TITULO"),})
	Else
		aAdd(aTRBD,{"DT_DSAP"  , NIL, NGSEEKDIC("SX3","TQB_PSAP",2,"X3_TITULO"),})
	EndIf

	If lFacilities
		aAdd(aTRBD,{"DT_DSAN"  , NIL, NGSEEKDIC("SX3","TQB_SEQQUE",2,"X3_TITULO"),})
	Else
		aAdd(aTRBD,{"DT_DSAN"  , NIL, NGSEEKDIC("SX3","TQB_PSAN",2,"X3_TITULO"),})
	EndIf

	aAdd(aTRBD,{"DT_DATRAS", NIL, STR0069,})//"Atraso"
	aAdd(aTRBD,{"DT_NMRESP", NIL, STR0051,}) //"Responsavel"

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C280DETFIL³ Autor ³ Ricardo Dal Ponte     ³ Data ³11/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Filtra a tabela de detalhe de acordo com os parametros      ³±±
±±³          ³selecionados em tela                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C280DETFIL()

Local lPVEZ    := .T.
Local lContem  := .F.

	CursorWait()

	lDTAE := .T.
	If cTPANALISE = aTPANALISE[1] .Or. cTPANALISE = aTPANALISE[4]
		lDTAE := .F.
	EndIf

	cFilSEQ := ""
	lDetalhar := .T.
	lFILTROS := .T.

	//-----------------------------------------------------
	//-----------------------------------------------------
	//ANALISE POR PENDENCIAS
	If cTPANALISE = aTPANALISE[1]
		//Selecao dos detalhes por Prioridade
		If cAGRUPA = aAGRUPA[1]

			dbSelectArea(cTRBPZ01)
			nRecno := (cTRBPZ01)->(Recno())
			dbGoTop()

			cFilSEQ := cFilDET

			While !Eof()
				If (cTRBPZ01)->MKBROW = "S"
					If lPVEZ = .T.
						lPVEZ = .F.
						cFilSEQ +=' .And. (DT_PRIORI=="'+(cTRBPZ01)->PRIORI+'"'
					Else
						cFilSEQ +=' .Or.  DT_PRIORI=="'+(cTRBPZ01)->PRIORI+'"'
					EndIf

					lContem := .T.

				EndIf

				dbSkip()
			End

			(cTRBPZ01)->(dbGoto(nRecno))
		EndIf

		//Selecao dos detalhes por Servico
		If cAGRUPA = aAGRUPA[2]

			dbSelectArea(cTRBPZ02)
			nRecno := (cTRBPZ02)->(Recno())
			dbGoTop()

			cFilSEQ := cFilDET

			While !Eof()
				If (cTRBPZ02)->MKBROW = "S"
					If lPVEZ = .T.
						lPVEZ = .F.
						cFilSEQ +=' .And. (DT_CDSERV=="'+(cTRBPZ02)->CDSERV+'"'
					Else
						cFilSEQ +=' .Or.  DT_CDSERV=="'+(cTRBPZ02)->CDSERV+'"'
					EndIf

					lContem := .T.

				EndIf

				dbSkip()
			End

			(cTRBPZ02)->(dbGoto(nRecno))
		EndIf

		//Selecao dos detalhes por Atraso
		If cAGRUPA = aAGRUPA[3]
	    	dbSelectArea(cTRBPZ03)
			nRecno := (cTRBPZ03)->(Recno())
			dbGoTop()

			cFilSEQ := cFilDET

			While !Eof()
				If (cTRBPZ03)->MKBROW = "S"
					If lPVEZ = .T.
						lPVEZ = .F.
						cFilSEQ +=' .And. (DT_CATRAS=="'+(cTRBPZ03)->ATRASO+'"'
					Else
						cFilSEQ +=' .Or.  DT_CATRAS=="'+(cTRBPZ03)->ATRASO+'"'
					EndIf

					lContem := .T.

				EndIf

				dbSkip()
			End

			(cTRBPZ03)->(dbGoto(nRecno))
		EndIf


		//Selecao dos detalhes por Executante
		If cAGRUPA = aAGRUPA[4] //
	    	dbSelectArea(cTRBPZ04)
			nRecno := (cTRBPZ04)->(Recno())
			dbGoTop()

			cFilSEQ := cFilDET

			While !Eof()
				If (cTRBPZ04)->MKBROW = "S"
					If lPVEZ = .T.
						lPVEZ = .F.
						cFilSEQ +=' .And. (DT_CDEXEC=="'+(cTRBPZ04)->CDEXEC+'"'
					Else
						cFilSEQ +=' .Or.  DT_CDEXEC=="'+(cTRBPZ04)->CDEXEC+'"'
					EndIf

					lContem := .T.

				EndIf

				dbSkip()
			End

			(cTRBPZ04)->(dbGoto(nRecno))
		EndIf

		//Selecao dos detalhes por LOCALIZACAO
		If cAGRUPA = aAGRUPA[5] //
	    	dbSelectArea(cTRBPZ05)
			nRecno := (cTRBPZ05)->(Recno())
			dbGoTop()

			cFilSEQ := cFilDET

			While !Eof()
				If (cTRBPZ05)->MKBROW = "S"
					If lPVEZ = .T.
						lPVEZ = .F.
						cFilSEQ +=' .And. (DT_CODBEM=="'+(cTRBPZ05)->CDLOCA+'"'
					Else
						cFilSEQ +=' .Or.  DT_CODBEM=="'+(cTRBPZ05)->CDLOCA+'"'
					EndIf

					lContem := .T.

				EndIf

				dbSkip()
			End

			(cTRBPZ05)->(dbGoto(nRecno))
		EndIf
	EndIf

	//-----------------------------------------------------
	//-----------------------------------------------------
	//-----------------------------------------------------
	//ANALISE POR SATISFACAO
	If cTPANALISE = aTPANALISE[2]

		If cAGRUPA = aAGRUPA[1]

			dbSelectArea(cTRBSZ01)
			nRecno := (cTRBSZ01)->(Recno())
			dbGoTop()

			cFilSEQ := cFilDET

			While !Eof()
				If (cTRBSZ01)->MKBROW = "S"
					If lPVEZ = .T.
						lPVEZ = .F.
						cFilSEQ +=' .And. (DT_PRIORI=="'+(cTRBSZ01)->PRIORI+'"'
					Else
						cFilSEQ +=' .Or.  DT_PRIORI=="'+(cTRBSZ01)->PRIORI+'"'
					EndIf

					lContem := .T.

				EndIf

				dbSkip()
			End

			(cTRBSZ01)->(dbGoto(nRecno))
		EndIf


		//Selecao dos detalhes por Servico
		If cAGRUPA = aAGRUPA[2]

			dbSelectArea(cTRBSZ02)
			nRecno := (cTRBSZ02)->(Recno())
			dbGoTop()

			cFilSEQ := cFilDET

			While !Eof()
				If (cTRBSZ02)->MKBROW = "S"
					If lPVEZ = .T.
						lPVEZ = .F.
						cFilSEQ +=' .And. (DT_CDSERV=="'+(cTRBSZ02)->CDSERV+'"'
					Else
						cFilSEQ +=' .Or.  DT_CDSERV=="'+(cTRBSZ02)->CDSERV+'"'
					EndIf

					lContem := .T.

				EndIf

				dbSkip()
			End

			(cTRBSZ02)->(dbGoto(nRecno))
		EndIf

		//Selecao dos detalhes por Executante
		If cAGRUPA = aAGRUPA[3] //
			dbSelectArea(cTRBSZ03)
			nRecno := (cTRBSZ03)->(Recno())
			dbGoTop()

			cFilSEQ := cFilDET

			While !Eof()
				If (cTRBSZ03)->MKBROW = "S"
					If lPVEZ = .T.
						lPVEZ = .F.
						cFilSEQ +=' .And. (DT_CDEXEC=="'+(cTRBSZ03)->CDEXEC+'"'
					Else
						cFilSEQ +=' .Or.  DT_CDEXEC=="'+(cTRBSZ03)->CDEXEC+'"'
					EndIf

					lContem := .T.

				EndIf

				dbSkip()
			End

			(cTRBSZ03)->(dbGoto(nRecno))
		EndIf

		//Selecao dos detalhes por Atendimento Prazo
		If cAGRUPA = aAGRUPA[4] //
			dbSelectArea(cTRBSZ04)
			nRecno := (cTRBSZ04)->(Recno())
			dbGoTop()

			cFilSEQ := cFilDET

			While !Eof()
				If (cTRBSZ04)->MKBROW = "S"
					If lPVEZ = .T.
						lPVEZ = .F.
						cFilSEQ +=' .And. (DT_PSAP=="'+(cTRBSZ04)->PSAP+'"'
					Else
						cFilSEQ +=' .Or.  DT_PSAP=="'+(cTRBSZ04)->PSAP+'"'
					EndIf

					lContem := .T.

         		EndIf

				dbSkip()
			End

			(cTRBSZ04)->(dbGoto(nRecno))
		EndIf


		//Selecao dos detalhes por Atendimento Necessidade
		If cAGRUPA = aAGRUPA[5] //
			dbSelectArea(cTRBSZ05)
			nRecno := (cTRBSZ05)->(Recno())
			dbGoTop()

			cFilSEQ := cFilDET

			While !Eof()
				If (cTRBSZ05)->MKBROW = "S"
					If lPVEZ = .T.
						lPVEZ = .F.
						cFilSEQ +=' .And. (DT_PSAN=="'+(cTRBSZ05)->PSAN+'"'
					Else
						cFilSEQ +=' .Or.  DT_PSAN=="'+(cTRBSZ05)->PSAN+'"'
					EndIf

					lContem := .T.

				EndIf

				dbSkip()
			End

			(cTRBSZ05)->(dbGoto(nRecno))
		EndIf

		//Selecao dos detalhes por Localizacao
		If cAGRUPA = aAGRUPA[6] //
			dbSelectArea(cTRBSZ06)
			nRecno := (cTRBSZ06)->(Recno())
			dbGoTop()

			cFilSEQ := cFilDET

			While !Eof()
				If (cTRBSZ06)->MKBROW = "S"
					If lPVEZ = .T.
						lPVEZ = .F.
						cFilSEQ +=' .And. (DT_CODBEM=="'+(cTRBSZ06)->CDLOCA+'"'
					Else
						cFilSEQ +=' .Or.  DT_CODBEM=="'+(cTRBSZ06)->CDLOCA+'"'
					EndIf

					lContem := .T.

				EndIf

				dbSkip()
			End

			(cTRBSZ06)->(dbGoto(nRecno))
		EndIf
	EndIf


	//-----------------------------------------------------
	//-----------------------------------------------------
	//-----------------------------------------------------
	//ANALISE POR ANALISE DE CUSTO/TEMPO
	If cTPANALISE = aTPANALISE[3]

		If cAGRUPA = aAGRUPA[1]

			dbSelectArea(cTRBCZ01)
			nRecno := (cTRBCZ01)->(Recno())
			dbGoTop()

			cFilSEQ := cFilDET

			While !Eof()
				If (cTRBCZ01)->MKBROW = "S"
					If lPVEZ = .T.
						lPVEZ = .F.
						cFilSEQ +=' .And. (DT_PRIORI=="'+(cTRBCZ01)->PRIORI+'"'
					Else
						cFilSEQ +=' .Or.  DT_PRIORI=="'+(cTRBCZ01)->PRIORI+'"'
					EndIf

					lContem := .T.

				EndIf

				dbSkip()
			End

			(cTRBCZ01)->(dbGoto(nRecno))
		EndIf


		//Selecao dos detalhes por Servico
		If cAGRUPA = aAGRUPA[2]

			dbSelectArea(cTRBCZ02)
			nRecno := (cTRBCZ02)->(Recno())
			dbGoTop()

			cFilSEQ := cFilDET

			While !Eof()
				If (cTRBCZ02)->MKBROW = "S"
					If lPVEZ = .T.
						lPVEZ = .F.
						cFilSEQ +=' .And. (DT_CDSERV=="'+(cTRBCZ02)->CDSERV+'"'
					Else
						cFilSEQ +=' .Or.  DT_CDSERV=="'+(cTRBCZ02)->CDSERV+'"'
					EndIf

					lContem := .T.

				EndIf

				dbSkip()
			End

			(cTRBCZ02)->(dbGoto(nRecno))
		EndIf

		//Selecao dos detalhes por Executante
		If cAGRUPA = aAGRUPA[3] //
			dbSelectArea(cTRBCZ03)
			nRecno := (cTRBCZ03)->(Recno())
			dbGoTop()

			cFilSEQ := cFilDET

			While !Eof()
				If (cTRBCZ03)->MKBROW = "S"
					If lPVEZ = .T.
						lPVEZ = .F.
						cFilSEQ +=' .And. (DT_CDEXEC=="'+(cTRBCZ03)->CDEXEC+'"'
					Else
						cFilSEQ +=' .Or.  DT_CDEXEC=="'+(cTRBCZ03)->CDEXEC+'"'
					EndIf

					lContem := .T.

				EndIf

				dbSkip()
			End

			(cTRBCZ03)->(dbGoto(nRecno))
		EndIf

		//Selecao dos detalhes por LOCALIZACAO
		If cAGRUPA = aAGRUPA[4] //
			dbSelectArea(cTRBCZ04)
			nRecno := (cTRBCZ04)->(Recno())
			dbGoTop()

			cFilSEQ := cFilDET

      While !Eof()
         If (cTRBCZ04)->MKBROW = "S"
            If lPVEZ = .T.
               lPVEZ = .F.
               cFilSEQ +=' .And. (DT_CODBEM=="'+(cTRBCZ04)->CDLOCA+'"'
             Else
               cFilSEQ +=' .Or.  DT_CODBEM=="'+(cTRBCZ04)->CDLOCA+'"'
            Endif
         EndIf
         dbSkip()
      End

	   (cTRBCZ04)->(dbGoto(nRecno))
	EndIf
EndIf

//-----------------------------------------------------
//-----------------------------------------------------
//-----------------------------------------------------
//ANALISE DE OS GERADAS
If cTPANALISE = aTPANALISE[4]

   If cAGRUPA = aAGRUPA[1]

      dbSelectArea(cTRBOZ01)
      nRecno := (cTRBOZ01)->(Recno())
      dbGoTop()

			cFilSEQ := cFilDET

			While !Eof()
				If (cTRBOZ01)->MKBROW = "S"
					If lPVEZ = .T.
						lPVEZ = .F.
						cFilSEQ +=' .And. (DT_PRIORI=="'+(cTRBOZ01)->PRIORI+'"'
					Else
						cFilSEQ +=' .Or.  DT_PRIORI=="'+(cTRBOZ01)->PRIORI+'"'
					EndIf

					lContem := .T.

				EndIf

				dbSkip()
			End

			(cTRBOZ01)->(dbGoto(nRecno))
		EndIf


		//Selecao dos detalhes por Servico
		If cAGRUPA = aAGRUPA[2]

			dbSelectArea(cTRBOZ02)
			nRecno := (cTRBOZ02)->(Recno())
			dbGoTop()

			cFilSEQ := cFilDET

			While !Eof()
				If (cTRBOZ02)->MKBROW = "S"
					If lPVEZ = .T.
						lPVEZ = .F.
						cFilSEQ +=' .And. (DT_CDSERV=="'+(cTRBOZ02)->CDSERV+'"'
					Else
						cFilSEQ +=' .Or.  DT_CDSERV=="'+(cTRBOZ02)->CDSERV+'"'
					EndIf

					lContem := .T.

				EndIf

				dbSkip()
			End

			(cTRBOZ02)->(dbGoto(nRecno))
		EndIf

		//Selecao dos detalhes por Executante
		If cAGRUPA = aAGRUPA[3] //
			dbSelectArea(cTRBOZ03)
			nRecno := (cTRBOZ03)->(Recno())
			dbGoTop()

			cFilSEQ := cFilDET

			While !Eof()
				If (cTRBOZ03)->MKBROW = "S"
					If lPVEZ = .T.
						lPVEZ = .F.
						cFilSEQ +=' .And. (DT_CDEXEC=="'+(cTRBOZ03)->CDEXEC+'"'
					Else
						cFilSEQ +=' .Or.  DT_CDEXEC=="'+(cTRBOZ03)->CDEXEC+'"'
					EndIf

					lContem := .T.

				EndIf

				dbSkip()
			End

			(cTRBOZ03)->(dbGoto(nRecno))
		EndIf

		//Selecao dos detalhes por LOCALIZACAO
		If cAGRUPA = aAGRUPA[4] //
			dbSelectArea(cTRBOZ04)
			nRecno := (cTRBOZ04)->(Recno())
			dbGoTop()

			cFilSEQ := cFilDET

			While !Eof()
				If (cTRBOZ04)->MKBROW = "S"
					If lPVEZ = .T.
						lPVEZ = .F.
						cFilSEQ +=' .And. (DT_CODBEM=="'+(cTRBOZ04)->CDLOCA+'"'
					Else
						cFilSEQ +=' .Or.  DT_CODBEM=="'+(cTRBOZ04)->CDLOCA+'"'
					EndIf

					lContem := .T.

				EndIf

				dbSkip()
			End

			(cTRBOZ04)->(dbGoto(nRecno))
		EndIf
	EndIf


	//-----------------------------------------------------
	//-----------------------------------------------------
	//-----------------------------------------------------
	//ANALISE POR ATENDIMENTO
	If cTPANALISE = aTPANALISE[5]

		If cAGRUPA = aAGRUPA[1]

			dbSelectArea(cTRBAZ01)
			nRecno := (cTRBAZ01)->(Recno())
			dbGoTop()

			cFilSEQ := cFilDET

			While !Eof()
				If (cTRBAZ01)->MKBROW = "S"
					If lPVEZ = .T.
						lPVEZ = .F.
						cFilSEQ +=' .And. (DT_PRIORI=="'+(cTRBAZ01)->PRIORI+'"'
					Else
               			cFilSEQ +=' .Or.  DT_PRIORI=="'+(cTRBAZ01)->PRIORI+'"'
					EndIf

					lContem := .T.

				EndIf

				dbSkip()
			End

			(cTRBAZ01)->(dbGoto(nRecno))
		EndIf


		//Selecao dos detalhes por Servico
		If cAGRUPA = aAGRUPA[2]

			dbSelectArea(cTRBAZ02)
			nRecno := (cTRBAZ02)->(Recno())
			dbGoTop()

			cFilSEQ := cFilDET

      While !Eof()
         If (cTRBAZ02)->MKBROW = "S"
            If lPVEZ = .T.
               lPVEZ = .F.
               cFilSEQ +=' .And. (DT_CDSERV=="'+(cTRBAZ02)->CDSERV+'"'
             Else
               cFilSEQ +=' .Or.  DT_CDSERV=="'+(cTRBAZ02)->CDSERV+'"'
            Endif
         EndIf
         dbSkip()
      End

	   (cTRBAZ02)->(dbGoto(nRecno))
   EndIf

   //Selecao dos detalhes por Executante
   If cAGRUPA = aAGRUPA[3] //
      dbSelectArea(cTRBAZ03)
      nRecno := (cTRBAZ03)->(Recno())
      dbGoTop()

			cFilSEQ := cFilDET

			While !Eof()
				If (cTRBAZ03)->MKBROW = "S"
					If lPVEZ = .T.
						lPVEZ = .F.
						cFilSEQ +=' .And. (DT_CDEXEC=="'+(cTRBAZ03)->CDEXEC+'"'
					Else
						cFilSEQ +=' .Or.  DT_CDEXEC=="'+(cTRBAZ03)->CDEXEC+'"'
					EndIf

					lContem := .T.

				EndIf

				dbSkip()
			End

			(cTRBAZ03)->(dbGoto(nRecno))
		EndIf

		//Selecao dos detalhes por LOCALIZACAO
		If cAGRUPA = aAGRUPA[4] //
			dbSelectArea(cTRBAZ04)
			nRecno := (cTRBAZ04)->(Recno())
			dbGoTop()

			cFilSEQ := cFilDET

			While !Eof()
				If (cTRBAZ04)->MKBROW = "S"
					If lPVEZ = .T.
						lPVEZ = .F.
						cFilSEQ +=' .And. (DT_CODBEM=="'+(cTRBAZ04)->CDLOCA+'"'
					Else
						cFilSEQ +=' .Or.  DT_CODBEM=="'+(cTRBAZ04)->CDLOCA+'"'
					EndIf

					lContem := .T.

				EndIf

				dbSkip()
			End

			(cTRBAZ04)->(dbGoto(nRecno))
		EndIf
	EndIf

	If lPVEZ = .F.
		cFilSEQ +=')'
	EndIf

	If !lContem
		MsgStop(STR0222) //"Não existem dados para serem exibidos."
		Return .F.
	EndIf

	dbSelectArea(cTRBD)
	dbGoTop()

	C280BRWDE()
	C280VFILTR()
	C280FILDET()

	CursorArrow()

	oDeBem:SetFocus()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C280WPENDE³ Autor ³ Ricardo Dal Ponte     ³ Data ³09/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria Arquivos Temporarios para a consulta de                ³±±
±±³          ³Analise de Pendencias                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C280WPENDE()

	aDBFDET := {}
	aDBF    := {}

	//Arquivo temporario da consulta por PRIORIDADE
	aDBF := {{"MKBROW", "C", 01, 0 },; //MARKBROWSE
			 {"PRIORI", "C", 01, 0 },; //PRIORIDADE
			 {"DESCRI", "C", 20, 0 },; //DESCRICAO
			 {"SSQTD" , "N", 06, 0 },; //NUMERO DE SS
			 {"SSRMET", "N", 10, 0 },; //MENOR ATRASO
			 {"SSRMAT", "N", 10, 0 },; //MAIOR ATRASO
			 {"SSRTOT", "N", 10, 0 },; //ATRASO TOTAL
			 {"SSRMED", "N", 10, 2 }}  //ATRASO MEDIO

	cIndPz01 := {{"PRIORI"}}
	oTmpZ01  := NGFwTmpTbl(cTRBPZ01,aDBF,cIndPz01)

	//Arquivo temporario da consulta por SERVICO
	aDBF := {{"MKBROW", "C", 01, 0 },; //MARKBROWSE
			 {"CDSERV", "C", 06, 0 },; //SERVICO
			 {"DESCRI", "C", 20, 0 },; //DESCRICAO
			 {"SSQTD" , "N", 06, 0 },; //NUMERO DE SS
			 {"SSRMET", "N", 10, 0 },; //MENOR ATRASO
			 {"SSRMAT", "N", 10, 0 },; //MAIOR ATRASO
			 {"SSRTOT", "N", 10, 0 },; //ATRASO TOTAL
			 {"SSRMED", "N", 10, 2 }}  //ATRASO MEDIO

	cIndPz02 := {{"CDSERV"}}
	oTmpZ02  := NGFwTmpTbl(cTRBPZ02,aDBF,cIndPz02)

	//Arquivo temporario da consulta por ATRASO
	aDBF := {{"MKBROW", "C", 01, 0 },; //MARKBROWSE
			 {"ATRASO", "C", 02, 0 },; //ATRASO
			 {"DESCRI", "C", 25, 0 },; //DESCRICAO
			 {"SSQTD" , "N", 06, 0 },; //NUMERO DE SS
			 {"SSRMET", "N", 10, 0 },; //MENOR ATRASO
			 {"SSRMAT", "N", 10, 0 },; //MAIOR ATRASO
			 {"SSRTOT", "N", 10, 0 },; //ATRASO TOTAL
			 {"SSRMED", "N", 10, 2 }}  //ATRASO MEDIO

	cIndPz03 := {{"ATRASO"}}
	oTmpZ03  := NGFwTmpTbl(cTRBPZ03,aDBF,cIndPz03)

	//Arquivo temporario da consulta por EXECUTANTE
	aDBF := {{"MKBROW", "C", 01, 0 },; //MARKBROWSE
			 {"CDEXEC", "C", TamSX3("TQB_CDEXEC")[1], 0 },; //EXECUTANTE
			 {"DESCRI", "C", 20, 0 },; //DESCRICAO
			 {"SSQTD" , "N", 06, 0 },; //NUMERO DE SS
			 {"SSRMET", "N", 10, 0 },; //MENOR ATRASO
			 {"SSRMAT", "N", 10, 0 },; //MAIOR ATRASO
			 {"SSRTOT", "N", 10, 0 },; //ATRASO TOTAL
			 {"SSRMED", "N", 10, 2 }}  //ATRASO MEDIO

	cIndPz04 := {{"CDEXEC"}}
	oTmpZ04  := NGFwTmpTbl(cTRBPZ04,aDBF,cIndPz04)

	//Arquivo temporario da consulta por LOCALIZACAO
	aDBF := {{"MKBROW", "C", 01, 0 },; //MARKBROWSE
			 {"CDLOCA", "C", 16, 0 },; //LOCALIZACAO
			 {"DESCRI", "C", 40, 0 },; //DESCRICAO
			 {"SSQTD" , "N", 06, 0 },; //NUMERO DE SS
			 {"SSRMET", "N", 10, 0 },; //MENOR ATRASO
			 {"SSRMAT", "N", 10, 0 },; //MAIOR ATRASO
			 {"SSRTOT", "N", 10, 0 },; //ATRASO TOTAL
			 {"SSRMED", "N", 10, 2 }}  //ATRASO MEDIO

	cIndPz05 := {{"CDLOCA"}}
	oTmpZ05  := NGFwTmpTbl(cTRBPZ05,aDBF,cIndPz05)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C280WSATIS³ Autor ³ Ricardo Dal Ponte     ³ Data ³16/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria Arquivos Temporarios para a consulta de                ³±±
±±³          ³Analise de Satisfacao                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C280WSATIS()

	aDBFDET := {}
	aDBF    := {}

	//Arquivo temporario da consulta por PRIORIDADE
	aDBF := {{"MKBROW", "C", 01, 0 },;    //MARKBROWSE
			 {"PRIORI", "C", 01, 0 },;    //PRIORIDADE
			 {"DESCRI", "C", 20, 0 },;   //DESCRICAO
			 {"SSQTD" , "N", 06, 0 },;  //NUMERO DE SS
			 {"PSOTIM", "N", 10, 0 },; //ATENDIMENTO Prazo Otimo
			 {"PSBOM" , "N", 10, 0 },; //ATENDIMENTO Prazo Bom
			 {"PSSATI", "N", 10, 0 },; //ATENDIMENTO Prazo Satisfatorio
			 {"PSRUIM", "N", 10, 0 },; //ATENDIMENTO Prazo Ruim
			 {"NSOTIM", "N", 10, 0 },; //ATENDIMENTO Necessidade Otimo
			 {"NSBOM" , "N", 10, 0 },; //ATENDIMENTO Necessidade Bom
			 {"NSSATI", "N", 10, 0 },; //ATENDIMENTO Necessidade Satisfatorio
			 {"NSRUIM", "N", 10, 0 },;  //ATENDIMENTO Necessidade Ruim
			 {"SSRMED", "N", 10, 2 }}  //ATRASO MEDIO

	cIndSz01 := {{"PRIORI"}}
	oTmpSZ01 := NGFwTmpTbl(cTRBSZ01,aDBF,cIndSz01)

	//Arquivo temporario da consulta por SERVICO
	aDBF := {{"MKBROW", "C", 01, 0 },;    //MARKBROWSE
			 {"CDSERV", "C", 06, 0 },;    //SERVICO
			 {"DESCRI", "C", 20, 0 },;   //DESCRICAO
			 {"SSQTD" , "N", 06, 0 },;  //NUMERO DE SS
			 {"PSOTIM", "N", 10, 0 },; //ATENDIMENTO Prazo Otimo
			 {"PSBOM" , "N", 10, 0 },; //ATENDIMENTO Prazo Bom
			 {"PSSATI", "N", 10, 0 },; //ATENDIMENTO Prazo Satisfatorio
			 {"PSRUIM", "N", 10, 0 },; //ATENDIMENTO Prazo Ruim
			 {"NSOTIM", "N", 10, 0 },; //ATENDIMENTO Necessidade Otimo
			 {"NSBOM" , "N", 10, 0 },; //ATENDIMENTO Necessidade Bom
			 {"NSSATI", "N", 10, 0 },; //ATENDIMENTO Necessidade Satisfatorio
			 {"NSRUIM", "N", 10, 0 }}  //ATENDIMENTO Necessidade Ruim

	cIndSz02 := {{"CDSERV"}}
	oTmpSZ02 := NGFwTmpTbl(cTRBSZ02,aDBF,cIndSz02)

	//Arquivo temporario da consulta por EXECUTANTE
	aDBF := {{"MKBROW", "C", 01, 0 },;    //MARKBROWSE
			 {"CDEXEC", "C", TamSX3("TQB_CDEXEC")[1], 0 },;    //EXECUTANTE
			 {"DESCRI", "C", 20, 0 },;   //DESCRICAO
			 {"SSQTD" , "N", 06, 0 },;  //NUMERO DE SS
			 {"PSOTIM", "N", 10, 0 },; //ATENDIMENTO Prazo Otimo
			 {"PSBOM" , "N", 10, 0 },; //ATENDIMENTO Prazo Bom
			 {"PSSATI", "N", 10, 0 },; //ATENDIMENTO Prazo Satisfatorio
			 {"PSRUIM", "N", 10, 0 },; //ATENDIMENTO Prazo Ruim
			 {"NSOTIM", "N", 10, 0 },; //ATENDIMENTO Necessidade Otimo
			 {"NSBOM" , "N", 10, 0 },; //ATENDIMENTO Necessidade Bom
			 {"NSSATI", "N", 10, 0 },; //ATENDIMENTO Necessidade Satisfatorio
			 {"NSRUIM", "N", 10, 0 }}  //ATENDIMENTO Necessidade Ruim

	cIndSz03 := {{"CDEXEC"}}
	oTmpSZ03 := NGFwTmpTbl(cTRBSZ03,aDBF,cIndSz03)

	//Arquivo temporario da consulta por Atend Prazo
	aDBF := {{"MKBROW", "C", 01, 0 },;  //MARKBROWSE
			 {"PSAP"  , "C", 01, 0 },;  //Atendimento Prazo
			 {"DESCRI", "C", 25, 0 },; //DESCRICAO
			 {"SSQTD" , "N", 06, 0 }} //NUMERO DE SS

	cIndSz04 := {{"PSAP"}}
	oTmpSZ04 := NGFwTmpTbl(cTRBSZ04,aDBF,cIndSz04)

	//Arquivo temporario da consulta por Atend Necessidade
	aDBF := {{"MKBROW", "C", 01, 0 },;  //MARKBROWSE
			 {"PSAN"  , "C", 01, 0 },;  //Atend Necessidade
			 {"DESCRI", "C", 25, 0 },; //DESCRICAO
			 {"SSQTD" , "N", 06, 0 }} //NUMERO DE SS

	cIndSz05 := {{"PSAN"}}
	oTmpSZ05 := NGFwTmpTbl(cTRBSZ05,aDBF,cIndSz05)

	//Arquivo temporario da consulta por LOCALIZACAO
	aDBF := {{"MKBROW", "C", 01, 0 },;    //MARKBROWSE
			 {"CDLOCA", "C", 16, 0 },;   //LOCALIZACAO
			 {"DESCRI", "C", 20, 0 },;   //DESCRICAO
			 {"SSQTD" , "N", 06, 0 },;  //NUMERO DE SS
			 {"PSOTIM", "N", 10, 0 },; //ATENDIMENTO Prazo Otimo
			 {"PSBOM" , "N", 10, 0 },; //ATENDIMENTO Prazo Bom
			 {"PSSATI", "N", 10, 0 },; //ATENDIMENTO Prazo Satisfatorio
			 {"PSRUIM", "N", 10, 0 },; //ATENDIMENTO Prazo Ruim
			 {"NSOTIM", "N", 10, 0 },; //ATENDIMENTO Necessidade Otimo
			 {"NSBOM" , "N", 10, 0 },; //ATENDIMENTO Necessidade Bom
			 {"NSSATI", "N", 10, 0 },; //ATENDIMENTO Necessidade Satisfatorio
			 {"NSRUIM", "N", 10, 0 }}  //ATENDIMENTO Necessidade Ruim

	cIndSz06 := {{"CDLOCA"}}
	oTmpSZ06 := NGFwTmpTbl(cTRBSZ06,aDBF,cIndSz06)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C280WCUSTE³ Autor ³ Ricardo Dal Ponte     ³ Data ³17/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria Arquivos Temporarios para a consulta de                ³±±
±±³          ³Analise de Custo/Tempo das SS                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C280WCUSTE()

	aDBFDET := {}
	aDBF    := {}

	//Arquivo temporario da consulta por PRIORIDADE
	aDBF := {{"MKBROW", "C", 01, 0 },;    //MARKBROWSE
			 {"PRIORI", "C", 01, 0 },;    //PRIORIDADE
			 {"DESCRI", "C", 20, 0 },;   //DESCRICAO
			 {"OSQTD" , "N", 06, 0 },;  //NUMERO DE SS
			 {"OSMENC", "N", 15, 6 },; //MENOR CUSTO
			 {"OSMAIC", "N", 15, 6 },; //MAIOR CUSTO
			 {"OSCUSM", "N", 15, 6 },; //CUSTO MEDIO
			 {"OSCUST", "N", 15, 6 },; //CUSTO TOTAL
			 {"SSHMET", "C", 05, 0 },;  //MENOR TEMPO ATENDIMENTO EM HORAS
			 {"SSHMAT", "C", 05, 0 },;  //MAIOR TEMPO ATENDIMENTO EM HORAS
			 {"SSHTOT", "C", 05, 0 },;  //TEMPO ATENDIMENTO TOTAL EM HORAS
			 {"SSHMED", "C", 05, 0 }}   //TEMPO ATENDIMENTO MEDIO EM HORAS

	cIndCz01 := {{"PRIORI"}}
	oTmpCZ01 := NGFwTmpTbl(cTRBCZ01,aDBF,cIndCz01)

	//Arquivo temporario da consulta por SERVICO
	aDBF := {{"MKBROW", "C", 01, 0 },;    //MARKBROWSE
			 {"CDSERV", "C", 06, 0 },;    //SERVICO
			 {"DESCRI", "C", 20, 0 },;   //DESCRICAO
			 {"OSQTD" , "N", 06, 0 },;  //NUMERO DE SS
			 {"OSMENC", "N", 15, 6 },; //MENOR CUSTO
			 {"OSMAIC", "N", 15, 6 },; //MAIOR CUSTO
			 {"OSCUSM", "N", 15, 6 },; //CUSTO MEDIO
			 {"OSCUST", "N", 15, 6 },; //CUSTO TOTAL
			 {"SSHMET", "C", 05, 0 },;  //MENOR TEMPO ATENDIMENTO EM HORAS
			 {"SSHMAT", "C", 05, 0 },;  //MAIOR TEMPO ATENDIMENTO EM HORAS
			 {"SSHTOT", "C", 05, 0 },;  //TEMPO ATENDIMENTO TOTAL EM HORAS
			 {"SSHMED", "C", 05, 0 }}   //TEMPO ATENDIMENTO MEDIO EM HORAS

	cIndCz02 := {{"CDSERV"}}
	oTmpCZ02 := NGFwTmpTbl(cTRBCZ02,aDBF,cIndCz02)

	//Arquivo temporario da consulta por EXECUTANTE
	aDBF := {{"MKBROW", "C", 01, 0 },;    //MARKBROWSE
			 {"CDEXEC", "C", TamSX3("TQB_CDEXEC")[1], 0 },;    //EXECUTANTE
			 {"DESCRI", "C", 20, 0 },;   //DESCRICAO
			 {"OSQTD" , "N", 06, 0 },;  //NUMERO DE SS
			 {"OSMENC", "N", 15, 6 },; //MENOR CUSTO
			 {"OSMAIC", "N", 15, 6 },; //MAIOR CUSTO
			 {"OSCUSM", "N", 15, 6 },; //CUSTO MEDIO
			 {"OSCUST", "N", 15, 6 },; //CUSTO TOTAL
			 {"SSHMET", "C", 05, 0 },;  //MENOR TEMPO ATENDIMENTO EM HORAS
			 {"SSHMAT", "C", 05, 0 },;  //MAIOR TEMPO ATENDIMENTO EM HORAS
			 {"SSHTOT", "C", 05, 0 },;  //TEMPO ATENDIMENTO TOTAL EM HORAS
			 {"SSHMED", "C", 05, 0 }}   //TEMPO ATENDIMENTO MEDIO EM HORAS

	cIndCz03 := {{"CDEXEC"}}
	oTmpCZ03 := NGFwTmpTbl(cTRBCZ03,aDBF,cIndCz03)

	//Arquivo temporario da consulta por LOCALIZACAO
	aDBF := {{"MKBROW", "C", 01, 0 },;    //MARKBROWSE
			 {"CDLOCA", "C", 16, 0 },;   //LOCALIZACAO
			 {"DESCRI", "C", 20, 0 },;   //DESCRICAO
			 {"OSQTD" , "N", 06, 0 },;  //NUMERO DE SS
			 {"OSMENC", "N", 15, 6 },; //MENOR CUSTO
			 {"OSMAIC", "N", 15, 6 },; //MAIOR CUSTO
			 {"OSCUSM", "N", 15, 6 },; //CUSTO MEDIO
			 {"OSCUST", "N", 15, 6 },; //CUSTO TOTAL
			 {"SSHMET", "C", 05, 0 },;  //MENOR TEMPO ATENDIMENTO EM HORAS
			 {"SSHMAT", "C", 05, 0 },;  //MAIOR TEMPO ATENDIMENTO EM HORAS
			 {"SSHTOT", "C", 05, 0 },;  //TEMPO ATENDIMENTO TOTAL EM HORAS
			 {"SSHMED", "C", 05, 0 }}   //TEMPO ATENDIMENTO MEDIO EM HORAS

	cIndCz04 := {{"CDLOCA"}}
	oTmpCZ04 := NGFwTmpTbl(cTRBCZ04,aDBF,cIndCz04)

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C280WOSGER³ Autor ³ Ricardo Dal Ponte     ³ Data ³24/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria Arquivos Temporarios para a consulta de                ³±±
±±³          ³Os Geradas                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C280WOSGER()

	aDBFDET := {}
	aDBF    := {}

	//Arquivo temporario da consulta por PRIORIDADE
	aDBF := {{"MKBROW", "C", 01, 0 },;    //MARKBROWSE
			 {"PRIORI", "C", 01, 0 },;    //PRIORIDADE
			 {"DESCRI", "C", 20, 0 },;   //DESCRICAO
			 {"OSQTD" , "N", 06, 0 },;  //NUMERO DE SS
			 {"OSMENC", "N", 15, 6 },; //MENOR CUSTO
			 {"OSMAIC", "N", 15, 6 },; //MAIOR CUSTO
			 {"OSCUSM", "N", 15, 6 },; //CUSTO MEDIO
			 {"OSCUST", "N", 15, 6 },; //CUSTO TOTAL
			 {"SSRMED", "N", 10, 2 }} //ATRASO MEDIO

	cIndOz01 := {{"PRIORI"}}
	oTmpOZ01 := NGFwTmpTbl(cTRBOZ01,aDBF,cIndOz01)

	//Arquivo temporario da consulta por SERVICO
	aDBF := {{"MKBROW", "C", 01, 0 },;    //MARKBROWSE
			 {"CDSERV", "C", 06, 0 },;    //SERVICO
			 {"DESCRI", "C", 20, 0 },;   //DESCRICAO
			 {"OSQTD" , "N", 06, 0 },;  //NUMERO DE SS
			 {"OSMENC", "N", 15, 6 },; //MENOR CUSTO
			 {"OSMAIC", "N", 15, 6 },; //MAIOR CUSTO
			 {"OSCUSM", "N", 15, 6 },; //CUSTO MEDIO
			 {"OSCUST", "N", 15, 6 },; //CUSTO TOTAL
			 {"SSRMED", "N", 10, 2 }} //ATRASO MEDIO

	cIndOz02 := {{"CDSERV"}}
	oTmpOZ02 := NGFwTmpTbl(cTRBOZ02,aDBF,cIndOz02)

	//Arquivo temporario da consulta por EXECUTANTE
	aDBF := {{"MKBROW", "C", 01, 0 },;    //MARKBROWSE
			 {"CDEXEC", "C", TamSX3("TQB_CDEXEC")[1], 0 },;    //EXECUTANTE
			 {"DESCRI", "C", 20, 0 },;   //DESCRICAO
			 {"OSQTD" , "N", 06, 0 },;  //NUMERO DE SS
			 {"OSMENC", "N", 15, 6 },; //MENOR CUSTO
			 {"OSMAIC", "N", 15, 6 },; //MAIOR CUSTO
			 {"OSCUSM", "N", 15, 6 },; //CUSTO MEDIO
			 {"OSCUST", "N", 15, 6 },; //CUSTO TOTAL
			 {"SSRMED", "N", 10, 2 }}  //ATRASO MEDIO

	cIndOz03 := {{"CDEXEC"}}
	oTmpOZ03 := NGFwTmpTbl(cTRBOZ03,aDBF,cIndOz03)

	//Arquivo temporario da consulta por LOCALIZACAO
	aDBF := {{"MKBROW", "C", 01, 0 },;    //MARKBROWSE
			 {"CDLOCA", "C", 16, 0 },;   //LOCALIZACAO
			 {"DESCRI", "C", 20, 0 },;   //DESCRICAO
			 {"OSQTD" , "N", 06, 0 },;  //NUMERO DE SS
			 {"OSMENC", "N", 15, 6 },; //MENOR CUSTO
			 {"OSMAIC", "N", 15, 6 },; //MAIOR CUSTO
			 {"OSCUSM", "N", 15, 6 },; //CUSTO MEDIO
			 {"OSCUST", "N", 15, 6 },; //CUSTO TOTAL
			 {"SSRMED", "N", 10, 2 }}  //ATRASO MEDIO

	cIndOz04 := {{"CDLOCA"}}
	oTmpOZ04 := NGFwTmpTbl(cTRBOZ04,aDBF,cIndOz04)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C280WATEND³ Autor ³ Ricardo Dal Ponte     ³ Data ³17/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria Arquivos Temporarios para a consulta de                ³±±
±±³          ³Analise de Atendimento                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C280WATEND()

	aDBFDET := {}
	aDBF    := {}

	//Arquivo temporario da consulta por PRIORIDADE
	aDBF := {{"MKBROW", "C", 01, 0 },;    //MARKBROWSE
			 {"PRIORI", "C", 01, 0 },;    //PRIORIDADE
			 {"DESCRI", "C", 20, 0 },;   //DESCRICAO
			 {"SSQTD" , "N", 06, 0 },;  //NUMERO DE SS
			 {"SSRMET", "N", 10, 0 },; //MENOR TEMPO ATENDIMENTO EM DIAS
			 {"SSRMAT", "N", 10, 0 },; //MAIOR TEMPO ATENDIMENTO EM DIAS
			 {"SSRTOT", "N", 10, 0 },; //TEMPO ATENDIMENTO TOTAL EM DIAS
			 {"SSRMED", "N", 10, 2 },; //TEMPO ATENDIMENTO MEDIO EM DIAS
			 {"SSHMET", "C", 05, 0 },;  //MENOR TEMPO ATENDIMENTO EM HORAS
			 {"SSHMAT", "C", 05, 0 },;  //MAIOR TEMPO ATENDIMENTO EM HORAS
			 {"SSHTOT", "C", 05, 0 },;  //TEMPO ATENDIMENTO TOTAL EM HORAS
			 {"SSHMED", "C", 05, 0 }}   //TEMPO ATENDIMENTO MEDIO EM HORAS

	cIndAz01 := {{"PRIORI"}}
	oTmpAZ01 := NGFwTmpTbl(cTRBAZ01,aDBF,cIndAz01)

	//Arquivo temporario da consulta por SERVICO
	aDBF := {{"MKBROW", "C", 01, 0 },;    //MARKBROWSE
			 {"CDSERV", "C", 06, 0 },;    //SERVICO
			 {"DESCRI", "C", 20, 0 },;   //DESCRICAO
			 {"SSQTD" , "N", 06, 0 },;  //NUMERO DE SS
			 {"SSRMET", "N", 10, 0 },; //MENOR TEMPO ATENDIMENTO EM DIAS
			 {"SSRMAT", "N", 10, 0 },; //MAIOR TEMPO ATENDIMENTO EM DIAS
			 {"SSRTOT", "N", 10, 0 },; //TEMPO ATENDIMENTO TOTAL EM DIAS
			 {"SSRMED", "N", 10, 2 },; //TEMPO ATENDIMENTO MEDIO EM DIAS
			 {"SSHMET", "C", 05, 0 },;  //MENOR TEMPO ATENDIMENTO EM HORAS
			 {"SSHMAT", "C", 05, 0 },;  //MAIOR TEMPO ATENDIMENTO EM HORAS
			 {"SSHTOT", "C", 05, 0 },;  //TEMPO ATENDIMENTO TOTAL EM HORAS
			 {"SSHMED", "C", 05, 0 }}   //TEMPO ATENDIMENTO MEDIO EM HORAS

	cIndAz02 := {{"CDSERV"}}
	oTmpAZ02 := NGFwTmpTbl(cTRBAZ02,aDBF,cIndAz02)

	//Arquivo temporario da consulta por EXECUTANTE
	aDBF := {{"MKBROW", "C", 01, 0 },;    //MARKBROWSE
			 {"CDEXEC", "C", TamSX3("TQB_CDEXEC")[1], 0 },;    //EXECUTANTE
			 {"DESCRI", "C", 20, 0 },;   //DESCRICAO
			 {"SSQTD" , "N", 06, 0 },;  //NUMERO DE SS
			 {"SSRMET", "N", 10, 0 },; //MENOR TEMPO ATENDIMENTO EM DIAS
			 {"SSRMAT", "N", 10, 0 },; //MAIOR TEMPO ATENDIMENTO EM DIAS
			 {"SSRTOT", "N", 10, 0 },; //TEMPO ATENDIMENTO TOTAL EM DIAS
			 {"SSRMED", "N", 10, 2 },; //TEMPO ATENDIMENTO MEDIO EM DIAS
			 {"SSHMET", "C", 05, 0 },;  //MENOR TEMPO ATENDIMENTO EM HORAS
			 {"SSHMAT", "C", 05, 0 },;  //MAIOR TEMPO ATENDIMENTO EM HORAS
			 {"SSHTOT", "C", 05, 0 },;  //TEMPO ATENDIMENTO TOTAL EM HORAS
			 {"SSHMED", "C", 05, 0 }}   //TEMPO ATENDIMENTO MEDIO EM HORAS

	cIndAz03 := {{"CDEXEC"}}
	oTmpAZ03 := NGFwTmpTbl(cTRBAZ03,aDBF,cIndAz03)

	//Arquivo temporario da consulta por LOCALIZACAO
	aDBF := {{"MKBROW", "C", 01, 0 },;    //MARKBROWSE
			 {"CDLOCA", "C", 16, 0 },;   //LOCALIZACAO
			 {"DESCRI", "C", 20, 0 },;   //DESCRICAO
			 {"SSQTD" , "N", 06, 0 },;  //NUMERO DE SS
			 {"SSRMET", "N", 10, 0 },; //MENOR TEMPO ATENDIMENTO EM DIAS
			 {"SSRMAT", "N", 10, 0 },; //MAIOR TEMPO ATENDIMENTO EM DIAS
			 {"SSRTOT", "N", 10, 0 },; //TEMPO ATENDIMENTO TOTAL EM DIAS
			 {"SSRMED", "N", 10, 2 },; //TEMPO ATENDIMENTO MEDIO EM DIAS
			 {"SSHMET", "C", 05, 0 },;  //MENOR TEMPO ATENDIMENTO EM HORAS
			 {"SSHMAT", "C", 05, 0 },;  //MAIOR TEMPO ATENDIMENTO EM HORAS
			 {"SSHTOT", "C", 05, 0 },;  //TEMPO ATENDIMENTO TOTAL EM HORAS
			 {"SSHMED", "C", 05, 0 }}   //TEMPO ATENDIMENTO MEDIO EM HORAS

	cIndAz04 := {{"CDLOCA"}}
	oTmpAZ04 := NGFwTmpTbl(cTRBAZ04,aDBF,cIndAz04)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C280WCLEAR³ Autor ³ Ricardo Dal Ponte     ³ Data ³09/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Elimina Arquivos Temporarios                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function C280WCLEAR()

	oTmpTRBD:Delete()
	oTmpZ01:Delete()
	oTmpZ02:Delete()
	oTmpZ03:Delete()
	oTmpZ04:Delete()
	oTmpZ05:Delete()
	oTmpSZ01:Delete()
	oTmpSZ02:Delete()
	oTmpSZ03:Delete()
	oTmpSZ04:Delete()
	oTmpSZ05:Delete()
	oTmpSZ06:Delete()
	oTmpCZ01:Delete()
	oTmpCZ02:Delete()
	oTmpCZ03:Delete()
	oTmpCZ04:Delete()
	oTmpOZ01:Delete()
	oTmpOZ02:Delete()
	oTmpOZ03:Delete()
	oTmpOZ04:Delete()
	oTmpAZ01:Delete()
	oTmpAZ02:Delete()
	oTmpAZ03:Delete()
	oTmpAZ04:Delete()

Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C280APENDE³ Autor ³ Ricardo Dal Ponte     ³ Data ³10/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Alimenta arquivos temporarios com os resumos de pendencias  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function C280APENDE()
lGEROURR := .F.

//#IFDEF TOP
   /*
   cQuery := "SELECT TQB_CODBEM,TJ_ORDEM,TJ_PLANO,TJ_POSCONT FROM " + RetSQLName("STJ")
   cQuery += " WHERE TJ_FILIAL = '" + xFilial("STJ") + "'"
   cQuery += " AND TJ_TIPOOS = 'B' AND TJ_SITUACA <> 'C' "
   cQuery += " AND TJ_CODBEM = '" + cBEMHIST +"'"
   cQuery += " AND TJ_DTORIGI = '" + Dtos(aLbx[oLbx:nAt,1]) +"'"
   cQuery += " AND D_E_L_E_T_ = ' '"

   cQuery := ChangeQuery(cQuery)
   dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), 'STJTMP', .F., .T.)

   dbSelectArea("STJTMP")
   dbgotop()
   */
//#ELSE
   Dbselectarea("TQB")
   Dbsetorder(1)

   cChave  := IndexKey()
   cFilPRI := ""
   cFilDET := ""

   cFilPRI :='TQB_FILIAL=="'+xFilial('TQB')+'" .And. '
   cFilDET :='DT_FILIAL=="'+xFilial('TQB')+'" .And. '

   If !Vazio(cDATADE) .And. !Vazio(cDATAATE)
      cFilPRI +='(DTOS(TQB_DTABER) >="'+DTOS(cDATADE) +'" .And. '
      cFilPRI +=' DTOS(TQB_DTABER) <="'+DTOS(cDATAATE)+'") .And. '

      cFilDET +='(DTOS(DT_DTABER) >="'+DTOS(cDATADE)  +'" .And. '
      cFilDET +=' DTOS(DT_DTABER) <="'+DTOS(cDATAATE) +'") .And. '
   Endif

	cFilPRI += "TQB_SOLUCA == 'D'"
   cFilDET += "DT_SOLUCA == 'D'"

   cIndTQB := CriaTrab(Nil, .F.)

   IndRegua("TQB",cIndTQB,TQB->(IndexKey(1)),,cFilPRI,STR0052) //"Selecionando Registros"

//#ENDIF

Dbselectarea("TQB")

While !Eof()
   lGEROURR := .T.
   ///--------------------------------------------
   //CALCULA ATRASO DA SS
   dDTABER := TQB->TQB_DTABER
   nATRASO := dDataBase - dDTABER

   If nATRASO < 0 .Or. dDTABER > dDataBase
      nATRASO := 0
   Endif
   ///--------------------------------------------


   ///--------------------------------------------
   ///GRAVA TEMPORARIO POR PRIORIDADE
   dbSelectArea(cTRBPZ01)
   dbsetorder(1)

   If !Dbseek(TQB->TQB_PRIORI)
      RecLock(cTRBPZ01,.T.)

      (cTRBPZ01)->MKBROW := "S"
      (cTRBPZ01)->PRIORI := TQB->TQB_PRIORI
      (cTRBPZ01)->SSQTD  := 1
      (cTRBPZ01)->SSRMET := nATRASO
      (cTRBPZ01)->SSRMAT := nATRASO
      (cTRBPZ01)->SSRMED := 0
      (cTRBPZ01)->SSRTOT := 0

      If TQB->TQB_PRIORI == "1"
         (cTRBPZ01)->DESCRI := STR0053 //"ALTA"
      Elseif TQB->TQB_PRIORI == "2"
         (cTRBPZ01)->DESCRI := STR0054 //"MÉDIA"
      Elseif TQB->TQB_PRIORI == "3"
         (cTRBPZ01)->DESCRI := STR0055 //"BAIXA"
      Endif
   Else
      RecLock(cTRBPZ01,.F.)

      (cTRBPZ01)->SSQTD  += 1
   Endif

   If nATRASO < (cTRBPZ01)->SSRMET
      (cTRBPZ01)->SSRMET := nATRASO
   Endif

   If nATRASO > (cTRBPZ01)->SSRMAT
      (cTRBPZ01)->SSRMAT := nATRASO
   Endif

   (cTRBPZ01)->SSRTOT += nATRASO
   (cTRBPZ01)->SSRMED := Round((cTRBPZ01)->SSRTOT / (cTRBPZ01)->SSQTD, 2)

   (cTRBPZ01)->(MsUnLock())
   ///--------------------------------------------


   ///--------------------------------------------
   ///GRAVA TEMPORARIO POR SERVICO
   dbSelectArea(cTRBPZ02)
   dbsetorder(1)

   If !Dbseek(TQB->TQB_CDSERV)
      RecLock(cTRBPZ02,.T.)

      (cTRBPZ02)->MKBROW := "S"
      (cTRBPZ02)->CDSERV := TQB->TQB_CDSERV
      (cTRBPZ02)->SSQTD  := 1
      (cTRBPZ02)->SSRMET := nATRASO
      (cTRBPZ02)->SSRMAT := nATRASO
      (cTRBPZ02)->SSRMED := 0
      (cTRBPZ02)->SSRTOT := 0

      dbSelectArea("TQ3")
      dbsetorder(1)

      (cTRBPZ02)->DESCRI := ""
      If Dbseek(xFilial("TQ3")+TQB->TQB_CDSERV)
         (cTRBPZ02)->DESCRI := SUBSTR(TQ3->TQ3_NMSERV,1,20)
      EndIf
   Else
      RecLock(cTRBPZ02,.F.)

      (cTRBPZ02)->SSQTD  += 1
   Endif

   If nATRASO < (cTRBPZ02)->SSRMET
      (cTRBPZ02)->SSRMET := nATRASO
   Endif

   If nATRASO > (cTRBPZ02)->SSRMAT
      (cTRBPZ02)->SSRMAT := nATRASO
   Endif

   (cTRBPZ02)->SSRTOT += nATRASO
   (cTRBPZ02)->SSRMED := Round((cTRBPZ02)->SSRTOT / (cTRBPZ02)->SSQTD, 2)

   (cTRBPZ02)->(MsUnLock())
   ///--------------------------------------------


   ///--------------------------------------------
   ///GRAVA TEMPORARIO POR TRASOS
   dbSelectArea(cTRBPZ03)
   dbsetorder(1)

   cATRASO := ""
   cDESATRASO := ""

   If nATRASO = 0
      cATRASO := "00"
      cDESATRASO := STR0056 //"Em dia"
   ElseIf nATRASO > 0 .And. nATRASO <= 1
      cATRASO := "01"
      cDESATRASO := STR0057 //"Atrasos em 1 dia"
   ElseIf nATRASO > 1 .And. nATRASO <= 3
      cATRASO := "02"
      cDESATRASO := STR0058 //"Atrasos entre 2 e 3 dias"
   ElseIf nATRASO > 3 .And. nATRASO <= 5
      cATRASO := "03"
      cDESATRASO := STR0059 //"Atrasos entre 4 e 5 dias"
   ElseIf nATRASO > 5 .And. nATRASO <= 7
      cATRASO := "04"
      cDESATRASO := STR0060 //"Atrasos entre 6 e 7 dias"
   ElseIf nATRASO > 7 .And. nATRASO <= 14
      cATRASO := "05"
      cDESATRASO := STR0061 //"Atrasos entre 8 e 14 dias"
   ElseIf nATRASO > 14
      cATRASO := "06"
      cDESATRASO := STR0062 //"Atrasos mais de 15 dias"
   EndIf

   If !Dbseek(cATRASO)
      RecLock(cTRBPZ03,.T.)

      (cTRBPZ03)->MKBROW := "S"
      (cTRBPZ03)->ATRASO := cATRASO
      (cTRBPZ03)->SSQTD  := 1
      (cTRBPZ03)->SSRMET := nATRASO
      (cTRBPZ03)->SSRMAT := nATRASO
      (cTRBPZ03)->SSRMED := 0
      (cTRBPZ03)->SSRTOT := 0
      (cTRBPZ03)->DESCRI := cDESATRASO
   Else
      RecLock(cTRBPZ03,.F.)

      (cTRBPZ03)->SSQTD  += 1
   Endif

   If nATRASO < (cTRBPZ03)->SSRMET
      (cTRBPZ03)->SSRMET := nATRASO
   Endif

   If nATRASO > (cTRBPZ03)->SSRMAT
      (cTRBPZ03)->SSRMAT := nATRASO
   Endif

   (cTRBPZ03)->SSRTOT += nATRASO
   (cTRBPZ03)->SSRMED := Round((cTRBPZ03)->SSRTOT / (cTRBPZ03)->SSQTD, 2)

   (cTRBPZ03)->(MsUnLock())
   ///--------------------------------------------


   ///--------------------------------------------
   ///GRAVA TEMPORARIO POR EXECUTANTE
   dbSelectArea(cTRBPZ04)
   dbsetorder(1)

   If !Dbseek(TQB->TQB_CDEXEC)
      RecLock(cTRBPZ04,.T.)

      (cTRBPZ04)->MKBROW := "S"
      (cTRBPZ04)->CDEXEC := TQB->TQB_CDEXEC
      (cTRBPZ04)->SSQTD  := 1
      (cTRBPZ04)->SSRMET := nATRASO
      (cTRBPZ04)->SSRMAT := nATRASO
      (cTRBPZ04)->SSRMED := 0
      (cTRBPZ04)->SSRTOT := 0

      If lFacilities
      	dbSelectArea("ST1")
	   	dbSetOrder(1)

	   	If dbSeek(xFilial("ST1")+TQB->TQB_CDEXEC)
	   		(cTRBPZ04)->DESCRI := SubStr(ST1->T1_NOME,1,20)
	   	EndIf
      Else
	      dbSelectArea("TQ4")
	      dbsetorder(1)

	      If Dbseek(xFilial("TQ4")+TQB->TQB_CDEXEC)
	         (cTRBPZ04)->DESCRI := TQ4->TQ4_NMEXEC
	      EndIf
	  End
   Else
      RecLock(cTRBPZ04,.F.)

      (cTRBPZ04)->SSQTD  += 1
   Endif

   If nATRASO < (cTRBPZ04)->SSRMET
      (cTRBPZ04)->SSRMET := nATRASO
   Endif

   If nATRASO > (cTRBPZ04)->SSRMAT
      (cTRBPZ04)->SSRMAT := nATRASO
   Endif

   (cTRBPZ04)->SSRTOT += nATRASO
   (cTRBPZ04)->SSRMED := Round((cTRBPZ04)->SSRTOT / (cTRBPZ04)->SSQTD, 2)

   (cTRBPZ04)->(MsUnLock())
   ///--------------------------------------------

   ///--------------------------------------------
   ///GRAVA TEMPORARIO POR LOCALIZACAO
   If TQB->TQB_TIPOSS = "L"
	   dbSelectArea(cTRBPZ05)
	   dbsetorder(1)

	   If !Dbseek(TQB->TQB_CODBEM)
	      RecLock(cTRBPZ05,.T.)

	      (cTRBPZ05)->MKBROW := "S"
	      (cTRBPZ05)->CDLOCA := TQB->TQB_CODBEM
	      (cTRBPZ05)->SSQTD  := 1
	      (cTRBPZ05)->SSRMET := nATRASO
	      (cTRBPZ05)->SSRMAT := nATRASO
	      (cTRBPZ05)->SSRMED := 0
	      (cTRBPZ05)->SSRTOT := 0

	      (cTRBPZ05)->DESCRI := ""
	      Dbselectarea("TAF")
	      Dbsetorder(7)
	      If Dbseek(xFILIAL("TAF")+"X"+"2"+Substr(TQB->TQB_CODBEM, 1, 3))
	         (cTRBPZ05)->DESCRI := SUBSTR(TAF->TAF_NOMNIV,1,40)
	      EndIf
	   Else
	      RecLock(cTRBPZ05,.F.)

	      (cTRBPZ05)->SSQTD  += 1
	   Endif

	   If nATRASO < (cTRBPZ05)->SSRMET
	      (cTRBPZ05)->SSRMET := nATRASO
	   Endif

	   If nATRASO > (cTRBPZ05)->SSRMAT
	      (cTRBPZ05)->SSRMAT := nATRASO
	   Endif

	   (cTRBPZ05)->SSRTOT += nATRASO
	   (cTRBPZ05)->SSRMED := Round((cTRBPZ05)->SSRTOT / (cTRBPZ05)->SSQTD, 2)

	   (cTRBPZ05)->(MsUnLock())
   EndIf
   ///--------------------------------------------


   //--------------------------------------------
   //GRAVA ARQUIVO TEMPORARIO DE DETALHE
   C280TRBD()
   //--------------------------------------------

   dbSelectarea("TQB")
   dbSkip()
End

DbSelectArea("TQB")
DbClearFilter()
RetIndex("TQB")

/*Substrituido pelo NGDELETRB
FErase(cIndTQB+OrdBagExt())
*/

DbSelectArea("TQB")
Set Filter To
Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C280ASATIS³ Autor ³ Ricardo Dal Ponte     ³ Data ³16/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Alimenta arquivos temporarios com os resumos de SATISFACAO  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function C280ASATIS()
Local nPSOTIM := 0 //ATENDIMENTO Prazo Otimo
Local nPSBOM  := 0 //ATENDIMENTO Prazo Bom
Local nPSSATI := 0 //ATENDIMENTO Prazo Satisfatorio
Local nPSRUIM := 0 //ATENDIMENTO Prazo Ruim
Local nNSOTIM := 0 //ATENDIMENTO Necessidade Otimo
Local nNSBOM  := 0  //ATENDIMENTO Necessidade Bom
Local nNSSATI := 0  //ATENDIMENTO Necessidade Satisfatorio
Local nNSRUIM := 0  //ATENDIMENTO Necessidade Ruim

lGEROURR := .F.

//#IFDEF TOP
//#ELSE
	dbselectarea("TQB")
	dbSetOrder(1)

	cChave  := IndexKey()
	cFilPRI := ""
	cFilDET := ""

	cFilPRI :='TQB_FILIAL=="'+xFilial('TQB')+'" .And. '
	cFilDET :='DT_FILIAL=="'+xFilial('TQB')+'" .And. '

	If !Vazio(cDATADE) .And. !Vazio(cDATAATE)
		cFilPRI +='(DTOS(TQB_DTABER) >="'+DTOS(cDATADE) +'" .And. '
		cFilPRI +=' DTOS(TQB_DTABER) <="'+DTOS(cDATAATE)+'") .And. '

		cFilDET +='(DTOS(DT_DTABER) >="'+DTOS(cDATADE) +'" .And. '
		cFilDET +=' DTOS(DT_DTABER) <="'+DTOS(cDATAATE) +'") .And. '
	EndIf

	cFilPRI += "TQB_SOLUCA=='E' .And. "
	cFilDET += " DT_SOLUCA=='E' .And. "

	If lFacilities
		cFilPRI += "(!Empty(TQB_SATISF) .And. !Empty(TQB_SEQQUE)) "
	Else
		cFilPRI += "(!Empty(TQB_PSAP) .And. !Empty(TQB_PSAN)) "
	EndIf

	cFilDET += "(!Empty(DT_PSAP)  .And. !Empty(DT_PSAN)) "

	cIndTQB := CriaTrab(Nil, .F.)

	IndRegua("TQB",cIndTQB,TQB->(IndexKey(1)),,cFilPRI,STR0052) //"Selecionando Registros"
	aAdd(aCriaTrab,cIndTQB)

dbSelectArea("TQB")

While !Eof()
	lGEROURR := .T.
	///--------------------------------------------
	nPSOTIM := 0 //ATENDIMENTO Prazo Otimo
	nPSBOM  := 0 //ATENDIMENTO Prazo Bom
	nPSSATI := 0 //ATENDIMENTO Prazo Satisfatorio
	nPSRUIM := 0 //ATENDIMENTO Prazo Ruim
	nNSOTIM := 0 //ATENDIMENTO Necessidade Otimo
	nNSBOM  := 0  //ATENDIMENTO Necessidade Bom
	nNSSATI := 0  //ATENDIMENTO Necessidade Satisfatorio
	nNSRUIM := 0  //ATENDIMENTO Necessidade Ruim

	If lFacilities
		If TQB->TQB_SATISF = "1"
	    	nPSOTIM := 1 //ATENDIMENTO Prazo Otimo
		ElseIf TQB->TQB_SATISF = "2"
	    	nPSBOM  := 1 //ATENDIMENTO Prazo Bom
		ElseIf TQB->TQB_SATISF = "3"
	    	nPSSATI := 1 //ATENDIMENTO Prazo Satisfatorio
		ElseIf TQB->TQB_SATISF = "4"
	    	nPSRUIM := 1 //ATENDIMENTO Prazo Ruim
		EndIf
	Else
		If TQB->TQB_PSAP = "1"
	    	nPSOTIM := 1 //ATENDIMENTO Prazo Otimo
		ElseIf TQB->TQB_PSAP = "2"
	    	nPSBOM  := 1 //ATENDIMENTO Prazo Bom
		ElseIf TQB->TQB_PSAP = "3"
	    	nPSSATI := 1 //ATENDIMENTO Prazo Satisfatorio
		ElseIf TQB->TQB_PSAP = "4"
	    	nPSRUIM := 1 //ATENDIMENTO Prazo Ruim
		EndIf
	EndIf

	If lFacilities
		If TQB->TQB_SEQQUE = "1"
	    	nNSOTIM := 1 //ATENDIMENTO Necessidade Otimo
		ElseIf TQB->TQB_SEQQUE = "2"
	    	nNSBOM  := 1  //ATENDIMENTO Necessidade Bom
		ElseIf TQB->TQB_SEQQUE = "3"
	    	nNSSATI := 1  //ATENDIMENTO Necessidade Satisfatorio
		ElseIf TQB->TQB_SEQQUE = "4"
	    	nNSRUIM := 1  //ATENDIMENTO Necessidade Ruim
		EndIf
	Else
		If TQB->TQB_PSAN = "1"
	    	nNSOTIM := 1 //ATENDIMENTO Necessidade Otimo
		ElseIf TQB->TQB_PSAN = "2"
	    	nNSBOM  := 1  //ATENDIMENTO Necessidade Bom
		ElseIf TQB->TQB_PSAN = "3"
	    	nNSSATI := 1  //ATENDIMENTO Necessidade Satisfatorio
		ElseIf TQB->TQB_PSAN = "4"
	    	nNSRUIM := 1  //ATENDIMENTO Necessidade Ruim
		EndIf
	EndIf
  	///--------------------------------------------


	///--------------------------------------------
	///GRAVA TEMPORARIO POR PRIORIDADE
	dbSelectArea(cTRBSZ01)
	dbSetOrder(1)

	If !Dbseek(TQB->TQB_PRIORI)
    	RecLock(cTRBSZ01,.T.)

		(cTRBSZ01)->MKBROW := "S"
		(cTRBSZ01)->PRIORI := TQB->TQB_PRIORI
		(cTRBSZ01)->SSQTD  := 1

		(cTRBSZ01)->PSOTIM := 0 //ATENDIMENTO Prazo Otimo
		(cTRBSZ01)->PSBOM  := 0 //ATENDIMENTO Prazo Bom
		(cTRBSZ01)->PSSATI := 0 //ATENDIMENTO Prazo Satisfatorio
		(cTRBSZ01)->PSRUIM := 0 //ATENDIMENTO Prazo Ruim
		(cTRBSZ01)->NSOTIM := 0 //ATENDIMENTO Necessidade Otimo
		(cTRBSZ01)->NSBOM  := 0  //ATENDIMENTO Necessidade Bom
    	(cTRBSZ01)->NSSATI := 0  //ATENDIMENTO Necessidade Satisfatorio
		(cTRBSZ01)->NSRUIM := 0  //ATENDIMENTO Necessidade Ruim

		If TQB->TQB_PRIORI == "1"
        	(cTRBSZ01)->DESCRI := STR0053 //"ALTA"
		ElseIf TQB->TQB_PRIORI == "2"
			(cTRBSZ01)->DESCRI := STR0054 //"MÉDIA"
		ElseIf TQB->TQB_PRIORI == "3"
			(cTRBSZ01)->DESCRI := STR0055 //"BAIXA"
		EndIf
	Else
    	RecLock(cTRBSZ01,.F.)

		(cTRBSZ01)->SSQTD  += 1
	EndIf

	(cTRBSZ01)->PSOTIM += nPSOTIM  //ATENDIMENTO Prazo Otimo
	(cTRBSZ01)->PSBOM  += nPSBOM   //ATENDIMENTO Prazo Bom
	(cTRBSZ01)->PSSATI += nPSSATI  //ATENDIMENTO Prazo Satisfatorio
	(cTRBSZ01)->PSRUIM += nPSRUIM  //ATENDIMENTO Prazo Ruim
	(cTRBSZ01)->NSOTIM += nNSOTIM  //ATENDIMENTO Necessidade Otimo
	(cTRBSZ01)->NSBOM  += nNSBOM   //ATENDIMENTO Necessidade Bom
	(cTRBSZ01)->NSSATI += nNSSATI  //ATENDIMENTO Necessidade Satisfatorio
	(cTRBSZ01)->NSRUIM += nNSRUIM  //ATENDIMENTO Necessidade Ruim

	(cTRBSZ01)->(MsUnLock())

	///--------------------------------------------
	///GRAVA TEMPORARIO POR SERVICO
	dbSelectArea(cTRBSZ02)
	dbsetorder(1)

	If !Dbseek(TQB->TQB_CDSERV)
    	RecLock(cTRBSZ02,.T.)

		(cTRBSZ02)->MKBROW := "S"
		(cTRBSZ02)->CDSERV := TQB->TQB_CDSERV
		(cTRBSZ02)->SSQTD  := 1
		(cTRBSZ02)->PSOTIM := 0 //ATENDIMENTO Prazo Otimo
		(cTRBSZ02)->PSBOM  := 0 //ATENDIMENTO Prazo Bom
		(cTRBSZ02)->PSSATI := 0 //ATENDIMENTO Prazo Satisfatorio
		(cTRBSZ02)->PSRUIM := 0 //ATENDIMENTO Prazo Ruim
		(cTRBSZ02)->NSOTIM := 0 //ATENDIMENTO Necessidade Otimo
		(cTRBSZ02)->NSBOM  := 0  //ATENDIMENTO Necessidade Bom
		(cTRBSZ02)->NSSATI := 0  //ATENDIMENTO Necessidade Satisfatorio
		(cTRBSZ02)->NSRUIM := 0  //ATENDIMENTO Necessidade Ruim

		dbSelectArea("TQ3")
		dbSetOrder(1)

		(cTRBSZ02)->DESCRI := ""
		If Dbseek(xFilial("TQ3")+TQB->TQB_CDSERV)
        	(cTRBSZ02)->DESCRI := SUBSTR(TQ3->TQ3_NMSERV,1,20)
		EndIf
	Else
    	RecLock(cTRBSZ02,.F.)

		(cTRBSZ02)->SSQTD  += 1
	EndIf

	(cTRBSZ02)->PSOTIM += nPSOTIM  //ATENDIMENTO Prazo Otimo
	(cTRBSZ02)->PSBOM  += nPSBOM   //ATENDIMENTO Prazo Bom
	(cTRBSZ02)->PSSATI += nPSSATI  //ATENDIMENTO Prazo Satisfatorio
	(cTRBSZ02)->PSRUIM += nPSRUIM  //ATENDIMENTO Prazo Ruim
	(cTRBSZ02)->NSOTIM += nNSOTIM  //ATENDIMENTO Necessidade Otimo
	(cTRBSZ02)->NSBOM  += nNSBOM   //ATENDIMENTO Necessidade Bom
	(cTRBSZ02)->NSSATI += nNSSATI  //ATENDIMENTO Necessidade Satisfatorio
	(cTRBSZ02)->NSRUIM += nNSRUIM  //ATENDIMENTO Necessidade Ruim

	(cTRBSZ02)->(MsUnLock())
	///--------------------------------------------


	///--------------------------------------------
	///GRAVA TEMPORARIO POR EXECUTANTE
	dbSelectArea(cTRBSZ03)
	dbSetOrder(1)

	If !Dbseek(TQB->TQB_CDEXEC)
    	RecLock(cTRBSZ03,.T.)

		(cTRBSZ03)->MKBROW := "S"
		(cTRBSZ03)->CDEXEC := TQB->TQB_CDEXEC
		(cTRBSZ03)->SSQTD  := 1
		(cTRBSZ03)->PSOTIM := 0 //ATENDIMENTO Prazo Otimo
		(cTRBSZ03)->PSBOM  := 0 //ATENDIMENTO Prazo Bom
		(cTRBSZ03)->PSSATI := 0 //ATENDIMENTO Prazo Satisfatorio
		(cTRBSZ03)->PSRUIM := 0 //ATENDIMENTO Prazo Ruim
		(cTRBSZ03)->NSOTIM := 0 //ATENDIMENTO Necessidade Otimo
		(cTRBSZ03)->NSBOM  := 0  //ATENDIMENTO Necessidade Bom
		(cTRBSZ03)->NSSATI := 0  //ATENDIMENTO Necessidade Satisfatorio
		(cTRBSZ03)->NSRUIM := 0  //ATENDIMENTO Necessidade Ruim

		If lFacilities
			dbSelectArea("ST1")
			dbSetOrder(1)

			If dbSeek(xFilial("ST1")+TQB->TQB_CDEXEC)
				(cTRBSZ03)->DESCRI := SubStr(ST1->T1_NOME,1,20)
			EndIf
		Else
	    	dbSelectArea("TQ4")
			dbSetOrder(1)

			If Dbseek(xFilial("TQ4")+TQB->TQB_CDEXEC)
				(cTRBSZ03)->DESCRI := TQ4->TQ4_NMEXEC
			EndIf
		EndIf

	Else
    	RecLock(cTRBSZ03,.F.)

		(cTRBSZ03)->SSQTD  += 1
	EndIf

	(cTRBSZ03)->PSOTIM += nPSOTIM  //ATENDIMENTO Prazo Otimo
	(cTRBSZ03)->PSBOM  += nPSBOM   //ATENDIMENTO Prazo Bom
	(cTRBSZ03)->PSSATI += nPSSATI  //ATENDIMENTO Prazo Satisfatorio
	(cTRBSZ03)->PSRUIM += nPSRUIM  //ATENDIMENTO Prazo Ruim
	(cTRBSZ03)->NSOTIM += nNSOTIM  //ATENDIMENTO Necessidade Otimo
	(cTRBSZ03)->NSBOM  += nNSBOM   //ATENDIMENTO Necessidade Bom
	(cTRBSZ03)->NSSATI += nNSSATI  //ATENDIMENTO Necessidade Satisfatorio
	(cTRBSZ03)->NSRUIM += nNSRUIM  //ATENDIMENTO Necessidade Ruim

	(cTRBSZ03)->(MsUnLock())
	///--------------------------------------------


	///--------------------------------------------
	///GRAVA TEMPORARIO POR ATENDIMENTO PRAZO
	dbSelectArea(cTRBSZ04)
	dbSetOrder(1)

	If !lFacilities .And. !dbSeek(TQB->TQB_PSAP)
    	RecLock(cTRBSZ04,.T.)

		(cTRBSZ04)->MKBROW := "S"
		(cTRBSZ04)->PSAP   := TQB->TQB_PSAP
		(cTRBSZ04)->SSQTD  := 1

		If TQB->TQB_PSAP == "1"
        	(cTRBSZ04)->DESCRI := STR0063 //"OTIMO"
		ElseIf TQB->TQB_PSAP == "2"
        	(cTRBSZ04)->DESCRI := STR0064 //"BOM"
		ElseIf TQB->TQB_PSAP == "3"
			(cTRBSZ04)->DESCRI := STR0065 //"SATISFATORIO"
		ElseIf TQB->TQB_PSAP == "4"
        	(cTRBSZ04)->DESCRI := STR0066 //"RUIM"
      	EndIf
	ElseIf lFacilities .And. !dbSeek(TQB->TQB_SATISF)
		RecLock(cTRBSZ04,.T.)

		(cTRBSZ04)->MKBROW := "S"
		(cTRBSZ04)->PSAP   := TQB->TQB_SATISF
		(cTRBSZ04)->SSQTD  := 1

		If TQB->TQB_SATISF == "1"
	       	(cTRBSZ04)->DESCRI := STR0063 //"OTIMO"
		ElseIf TQB->TQB_SATISF == "2"
	       	(cTRBSZ04)->DESCRI := STR0064 //"BOM"
		ElseIf TQB->TQB_SATISF == "3"
			(cTRBSZ04)->DESCRI := STR0065 //"SATISFATORIO"
		ElseIf TQB->TQB_SATISF == "4"
	       	(cTRBSZ04)->DESCRI := STR0066 //"RUIM"
	    EndIf
	Else
    	RecLock(cTRBSZ04,.F.)

		(cTRBSZ04)->SSQTD  += 1
	EndIf

	(cTRBSZ04)->(MsUnLock())
	///--------------------------------------------


	///--------------------------------------------
	///GRAVA TEMPORARIO POR ATENDIMENTO NECESSIDADE
	dbSelectArea(cTRBSZ05)
	dbSetOrder(1)

	If !lFacilities .And. !Dbseek(TQB->TQB_PSAN)
    	RecLock(cTRBSZ05,.T.)

		(cTRBSZ05)->MKBROW := "S"
		(cTRBSZ05)->PSAN   := TQB->TQB_PSAN
		(cTRBSZ05)->SSQTD  := 1

		If TQB->TQB_PSAN == "1"
        	(cTRBSZ05)->DESCRI := STR0063 //"OTIMO"
		ElseIf TQB->TQB_PSAN == "2"
			(cTRBSZ05)->DESCRI := STR0064 //"BOM"
		ElseIf TQB->TQB_PSAN == "3"
         	(cTRBSZ05)->DESCRI := STR0065 //"SATISFATORIO"
		ElseIf TQB->TQB_PSAN == "4"
         	(cTRBSZ05)->DESCRI := STR0066 //"RUIM"
		EndIf
	ElseIf lFacilities .And. !Dbseek(TQB->TQB_SEQQUE)
		RecLock(cTRBSZ05,.T.)

		(cTRBSZ05)->MKBROW := "S"
		(cTRBSZ05)->PSAN   := TQB->TQB_SEQQUE
		(cTRBSZ05)->SSQTD  := 1

		If TQB->TQB_SEQQUE == "1"
        	(cTRBSZ05)->DESCRI := STR0063 //"OTIMO"
		ElseIf TQB->TQB_SEQQUE == "2"
			(cTRBSZ05)->DESCRI := STR0064 //"BOM"
		ElseIf TQB->TQB_SEQQUE == "3"
         	(cTRBSZ05)->DESCRI := STR0065 //"SATISFATORIO"
		ElseIf TQB->TQB_SEQQUE == "4"
         	(cTRBSZ05)->DESCRI := STR0066 //"RUIM"
		EndIf
	Else
    	RecLock(cTRBSZ05,.F.)

		(cTRBSZ05)->SSQTD  += 1
	EndIf

	(cTRBSZ05)->(MsUnLock())
	///--------------------------------------------


	///--------------------------------------------
	///GRAVA TEMPORARIO POR LOCALIZACAO
	If TQB->TQB_TIPOSS = "L"
		dbSelectArea(cTRBSZ06)
		dbSetOrder(1)

		If !Dbseek(TQB->TQB_CODBEM)
	    	RecLock(cTRBSZ06,.T.)

			(cTRBSZ06)->MKBROW := "S"
			(cTRBSZ06)->CDLOCA := TQB->TQB_CODBEM
			(cTRBSZ06)->SSQTD  := 1
			(cTRBSZ06)->PSOTIM := 0 //ATENDIMENTO Prazo Otimo
			(cTRBSZ06)->PSBOM  := 0 //ATENDIMENTO Prazo Bom
			(cTRBSZ06)->PSSATI := 0 //ATENDIMENTO Prazo Satisfatorio
			(cTRBSZ06)->PSRUIM := 0 //ATENDIMENTO Prazo Ruim
			(cTRBSZ06)->NSOTIM := 0 //ATENDIMENTO Necessidade Otimo
	     	(cTRBSZ06)->NSBOM  := 0  //ATENDIMENTO Necessidade Bom
			(cTRBSZ06)->NSSATI := 0  //ATENDIMENTO Necessidade Satisfatorio
			(cTRBSZ06)->NSRUIM := 0  //ATENDIMENTO Necessidade Ruim

			(cTRBSZ06)->DESCRI := ""
			dbSelectArea("TAF")
			dbSetOrder(7)
			If Dbseek(xFILIAL("TAF")+"X"+"2"+Substr(TQB->TQB_CODBEM, 1, 3))
	        	(cTRBSZ06)->DESCRI := SUBSTR(TAF->TAF_NOMNIV,1,40)
			EndIf
		Else
	    	RecLock(cTRBSZ06,.F.)

			(cTRBSZ06)->SSQTD  += 1
		EndIf

		(cTRBSZ06)->PSOTIM += nPSOTIM  //ATENDIMENTO Prazo Otimo
		(cTRBSZ06)->PSBOM  += nPSBOM   //ATENDIMENTO Prazo Bom
		(cTRBSZ06)->PSSATI += nPSSATI  //ATENDIMENTO Prazo Satisfatorio
		(cTRBSZ06)->PSRUIM += nPSRUIM  //ATENDIMENTO Prazo Ruim
		(cTRBSZ06)->NSOTIM += nNSOTIM  //ATENDIMENTO Necessidade Otimo
		(cTRBSZ06)->NSBOM  += nNSBOM   //ATENDIMENTO Necessidade Bom
		(cTRBSZ06)->NSSATI += nNSSATI  //ATENDIMENTO Necessidade Satisfatorio
		(cTRBSZ06)->NSRUIM += nNSRUIM  //ATENDIMENTO Necessidade Ruim

		(cTRBSZ06)->(MsUnLock())
	EndIf
	///--------------------------------------------

	//--------------------------------------------
	//GRAVA ARQUIVO TEMPORARIO DE DETALHE
	C280TRBD()
	//--------------------------------------------

	dbSelectArea("TQB")
	dbSkip()
End

dbSelectArea("TQB")
dbClearFilter()
RetIndex("TQB")

/*Substrituido pelo NGDELETRB
FErase(cIndTQB+OrdBagExt())
*/
If !lGEROURR
	MsgStop(STR0222) //"Não existe dados para serem exibidos."
	Return .F.
EndIf

dbSelectArea("TQB")
Set Filter To
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C280ACUSTE³ Autor ³ Ricardo Dal Ponte     ³ Data ³24/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Alimenta arquivos temporarios com os resumos de Custo/Tempo |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function C280ACUSTE()
	Local cNGMNTRH := AllTrim(GetMv("MV_NGMNTRH"))
	lGEROURR := .F.

	//#IFDEF TOP
	//#ELSE
	Dbselectarea("TQB")
	Dbsetorder(1)

	cChave  := IndexKey()
	cFilPRI := ""
	cFilDET := ""

	cFilPRI :='TQB_FILIAL=="'+xFilial('TQB')+'" .And. '
	cFilDET :='DT_FILIAL=="'+xFilial('TQB')+'" .And. '

	If !Vazio(cDATADE) .And. !Vazio(cDATAATE)
		cFilPRI +='(DTOS(TQB_DTABER) >="'+DTOS(cDATADE) +'" .And. '
		cFilPRI +=' DTOS(TQB_DTABER) <="'+DTOS(cDATAATE)+'") .And. '

		cFilDET +='(DTOS(DT_DTABER) >="'+DTOS(cDATADE) +'" .And. '
		cFilDET +=' DTOS(DT_DTABER) <="'+DTOS(cDATAATE) +'") .And. '
	Endif

		cFilPRI += "TQB_SOLUCA == 'E'"
	cFilDET += "DT_SOLUCA == 'E'"

	cIndTQB := CriaTrab(Nil, .F.)

	IndRegua("TQB",cIndTQB,TQB->(IndexKey(1)),,cFilPRI,STR0052) //"Selecionando Registros"
		aAdd(aCriaTrab,cIndTQB)

	Dbselectarea("TQB")

	While !Eof()
	lGEROURR := .T.
	///--------------------------------------------
	//BUSCA O CUSTO DA OS NO ARQUIVO DE CUSTOS STL
	nHORAS  := HtoM(TQB->TQB_TEMPO)
	nCUSTO  := 0
	nCUSTOH := 0

	PswOrder(2)

	If PswSeek(TQB->TQB_CDEXEC)
		cMATRIC := Substr(PswRet(1)[1][22], 5, 6)

		If cNGMNTRH $ "SX"
			dbSelectArea("SRA")
			dbsetorder(1)
			If Dbseek(xFilial("SRA")+cMATRIC)
				If SRA->RA_SALARIO > 0 .Or. SRA->RA_HRSMES > 0
				nCUSTOH := Round(SRA->RA_SALARIO / SRA->RA_HRSMES, 4)
				EndIf

				If SRA->RA_SALARIO > 0 .And. SRA->RA_HRSMES = 0
				nCUSTOH := Round(SRA->RA_SALARIO, 4)
				EndIf
			Else
				dbSelectArea("ST1")
				dbsetorder(1)
				If Dbseek(xFilial("ST1")+cMATRIC)
					nCUSTOH := ST1->T1_SALARIO
					Endif
			EndIf
		Else
			dbSelectArea("ST1")
			dbsetorder(1)

			If Dbseek(xFilial("ST1")+cMATRIC)
				nCUSTOH := ST1->T1_SALARIO
				Endif
			Endif
	EndIf

	nCUSTO := Round(nCUSTOH * Round(nHORAS/60, 2), 4)
	nCUSTO := Round(nCUSTO,2)
	///--------------------------------------------


	///--------------------------------------------
	///GRAVA TEMPORARIO POR PRIORIDADE
	dbSelectArea(cTRBCZ01)
	dbsetorder(1)

	If !Dbseek(TQB->TQB_PRIORI)
		RecLock(cTRBCZ01,.T.)

		(cTRBCZ01)->MKBROW := "S"
		(cTRBCZ01)->PRIORI := TQB->TQB_PRIORI
		(cTRBCZ01)->OSQTD  := 1      //NUMERO DE SS
		(cTRBCZ01)->OSMENC := nCUSTO //MENOR CUSTO
		(cTRBCZ01)->OSMAIC := nCUSTO //MAIOR CUSTO
		(cTRBCZ01)->OSCUSM := 0 //CUSTO MEDIO
		(cTRBCZ01)->OSCUST := 0 //CUSTO TOTAL
		(cTRBCZ01)->SSHMET := MtoH(nHORAS) //MENOR TEMPO ATENDIMENTO EM HORAS
		(cTRBCZ01)->SSHMAT := MtoH(nHORAS) //MAIOR TEMPO ATENDIMENTO EM HORAS
		(cTRBCZ01)->SSHTOT := MtoH(0) //TEMPO ATENDIMENTO TOTAL EM HORAS
		(cTRBCZ01)->SSHMED := MtoH(0) //TEMPO ATENDIMENTO MEDIO EM HORAS

		If TQB->TQB_PRIORI == "1"
			(cTRBCZ01)->DESCRI := STR0053 //"ALTA"
		Elseif TQB->TQB_PRIORI == "2"
			(cTRBCZ01)->DESCRI := STR0054 //"MÉDIA"
		Elseif TQB->TQB_PRIORI == "3"
			(cTRBCZ01)->DESCRI := STR0055 //"BAIXA"
		Endif
	Else
		RecLock(cTRBCZ01,.F.)

		(cTRBCZ01)->OSQTD  += 1
	Endif

	//GRAVA TEMPOS
	If nHORAS < HtoM((cTRBCZ01)->SSHMET)
		(cTRBCZ01)->SSHMET := MtoH(nHORAS)
	Endif

	If nHORAS > HtoM((cTRBCZ01)->SSHMAT)
		(cTRBCZ01)->SSHMAT := MtoH(nHORAS)
	Endif

	(cTRBCZ01)->SSHTOT := MtoH(HtoM((cTRBCZ01)->SSHTOT)+HtoM(TQB->TQB_TEMPO))
	(cTRBCZ01)->SSHMED := MtoH(Round(HtoM((cTRBCZ01)->SSHTOT) / (cTRBCZ01)->OSQTD, 2))

	//GRAVA CUSTOS
	If nCUSTO < (cTRBCZ01)->OSMENC
		(cTRBCZ01)->OSMENC := nCUSTO
	Endif

	If nCUSTO > (cTRBCZ01)->OSMAIC
		(cTRBCZ01)->OSMAIC := nCUSTO
	Endif

	(cTRBCZ01)->OSCUST += nCUSTO
	(cTRBCZ01)->OSCUSM := Round((cTRBCZ01)->OSCUST / (cTRBCZ01)->OSQTD, 4)

	(cTRBCZ01)->(MsUnLock())
	///--------------------------------------------


	///--------------------------------------------
	///GRAVA TEMPORARIO POR SERVICO
	dbSelectArea(cTRBCZ02)
	dbsetorder(1)

	If !Dbseek(TQB->TQB_CDSERV)
		RecLock(cTRBCZ02,.T.)

		(cTRBCZ02)->MKBROW := "S"
		(cTRBCZ02)->CDSERV := TQB->TQB_CDSERV
		(cTRBCZ02)->OSQTD  := 1      //NUMERO DE SS
		(cTRBCZ02)->OSMENC := nCUSTO //MENOR CUSTO
		(cTRBCZ02)->OSMAIC := nCUSTO //MAIOR CUSTO
		(cTRBCZ02)->OSCUSM := 0 //CUSTO MEDIO
		(cTRBCZ02)->OSCUST := 0 //CUSTO TOTAL
		(cTRBCZ02)->SSHMET := MtoH(nHORAS) //MENOR TEMPO ATENDIMENTO EM HORAS
		(cTRBCZ02)->SSHMAT := MtoH(nHORAS) //MAIOR TEMPO ATENDIMENTO EM HORAS
		(cTRBCZ02)->SSHTOT := MtoH(0) //TEMPO ATENDIMENTO TOTAL EM HORAS
		(cTRBCZ02)->SSHMED := MtoH(0) //TEMPO ATENDIMENTO MEDIO EM HORAS

		dbSelectArea("TQ3")
		dbsetorder(1)

		(cTRBCZ02)->DESCRI := ""
		If Dbseek(xFilial("TQ3")+TQB->TQB_CDSERV)
			(cTRBCZ02)->DESCRI := SUBSTR(TQ3->TQ3_NMSERV,1,20)
		EndIf
	Else
		RecLock(cTRBCZ02,.F.)

		(cTRBCZ02)->OSQTD  += 1
	Endif

	//GRAVA TEMPOS
	If nHORAS < HtoM((cTRBCZ02)->SSHMET)
		(cTRBCZ02)->SSHMET := MtoH(nHORAS)
	Endif

	If nHORAS > HtoM((cTRBCZ02)->SSHMAT)
		(cTRBCZ02)->SSHMAT := MtoH(nHORAS)
	Endif

	(cTRBCZ02)->SSHTOT := MtoH(HtoM((cTRBCZ02)->SSHTOT)+HtoM(TQB->TQB_TEMPO))
	(cTRBCZ02)->SSHMED := MtoH(Round(HtoM((cTRBCZ02)->SSHTOT) / (cTRBCZ02)->OSQTD, 2))

	//GRAVA CUSTOS
	If nCUSTO < (cTRBCZ02)->OSMENC
		(cTRBCZ02)->OSMENC := nCUSTO
	Endif

	If nCUSTO > (cTRBCZ02)->OSMAIC
		(cTRBCZ02)->OSMAIC := nCUSTO
	Endif

	(cTRBCZ02)->OSCUST += nCUSTO
	(cTRBCZ02)->OSCUSM := Round((cTRBCZ02)->OSCUST / (cTRBCZ02)->OSQTD, 4)

	(cTRBCZ02)->(MsUnLock())
	///--------------------------------------------

	///--------------------------------------------
	///GRAVA TEMPORARIO POR EXECUTANTE
	dbSelectArea(cTRBCZ03)
	dbsetorder(1)

	If !Dbseek(TQB->TQB_CDEXEC)
		RecLock(cTRBCZ03,.T.)

		(cTRBCZ03)->MKBROW := "S"
		(cTRBCZ03)->CDEXEC := TQB->TQB_CDEXEC
		(cTRBCZ03)->OSQTD  := 1      //NUMERO DE SS
		(cTRBCZ03)->OSMENC := nCUSTO //MENOR CUSTO
		(cTRBCZ03)->OSMAIC := nCUSTO //MAIOR CUSTO
		(cTRBCZ03)->OSCUSM := 0 //CUSTO MEDIO
		(cTRBCZ03)->OSCUST := 0 //CUSTO TOTAL
		(cTRBCZ03)->SSHMET := MtoH(nHORAS) //MENOR TEMPO ATENDIMENTO EM HORAS
		(cTRBCZ03)->SSHMAT := MtoH(nHORAS) //MAIOR TEMPO ATENDIMENTO EM HORAS
		(cTRBCZ03)->SSHTOT := MtoH(0) //TEMPO ATENDIMENTO TOTAL EM HORAS
		(cTRBCZ03)->SSHMED := MtoH(0) //TEMPO ATENDIMENTO MEDIO EM HORAS


		If lFacilities
			dbSelectArea("ST1")
			dbSetOrder(1)

			If dbSeek(xFilial("ST1")+TQB->TQB_CDEXEC)
				(cTRBCZ03)->DESCRI := SubStr(ST1->T1_NOME,1,20)
			EndIf
		Else
			dbSelectArea("TQ4")
			dbsetorder(1)

			If Dbseek(xFilial("TQ4")+TQB->TQB_CDEXEC)
				(cTRBCZ03)->DESCRI := TQ4->TQ4_NMEXEC
			EndIf
		EndIf
	Else
		RecLock(cTRBCZ03,.F.)

		(cTRBCZ03)->OSQTD  += 1
	Endif

	//GRAVA TEMPOS
	If nHORAS < HtoM((cTRBCZ03)->SSHMET)
		(cTRBCZ03)->SSHMET := MtoH(nHORAS)
	Endif

	If nHORAS > HtoM((cTRBCZ03)->SSHMAT)
		(cTRBCZ03)->SSHMAT := MtoH(nHORAS)
	Endif

	(cTRBCZ03)->SSHTOT := MtoH(HtoM((cTRBCZ03)->SSHTOT)+HtoM(TQB->TQB_TEMPO))
	(cTRBCZ03)->SSHMED := MtoH(Round(HtoM((cTRBCZ03)->SSHTOT) / (cTRBCZ03)->OSQTD, 2))

	//GRAVA CUSTOS
	If nCUSTO < (cTRBCZ03)->OSMENC
		(cTRBCZ03)->OSMENC := nCUSTO
	Endif

	If nCUSTO > (cTRBCZ03)->OSMAIC
		(cTRBCZ03)->OSMAIC := nCUSTO
	Endif

	(cTRBCZ03)->OSCUST += nCUSTO
	(cTRBCZ03)->OSCUSM := Round((cTRBCZ03)->OSCUST / (cTRBCZ03)->OSQTD, 4)

	(cTRBCZ03)->(MsUnLock())
	///--------------------------------------------

	///--------------------------------------------


	///--------------------------------------------
	///GRAVA TEMPORARIO POR LOCALIZACAO
	If TQB->TQB_TIPOSS = "L"
		dbSelectArea(cTRBCZ04)
		dbsetorder(1)

		If !Dbseek(TQB->TQB_CODBEM)
			RecLock(cTRBCZ04,.T.)

			(cTRBCZ04)->MKBROW := "S"
			(cTRBCZ04)->CDLOCA := TQB->TQB_CODBEM
			(cTRBCZ04)->OSQTD  := 1      //NUMERO DE SS
			(cTRBCZ04)->OSMENC := nCUSTO //MENOR CUSTO
			(cTRBCZ04)->OSMAIC := nCUSTO //MAIOR CUSTO
			(cTRBCZ04)->OSCUSM := 0 //CUSTO MEDIO
			(cTRBCZ04)->OSCUST := 0 //CUSTO TOTAL
			(cTRBCZ04)->SSHMET := MtoH(nHORAS) //MENOR TEMPO ATENDIMENTO EM HORAS
			(cTRBCZ04)->SSHMAT := MtoH(nHORAS) //MAIOR TEMPO ATENDIMENTO EM HORAS
			(cTRBCZ04)->SSHTOT := MtoH(0) //TEMPO ATENDIMENTO TOTAL EM HORAS
			(cTRBCZ04)->SSHMED := MtoH(0) //TEMPO ATENDIMENTO MEDIO EM HORAS

			(cTRBCZ04)->DESCRI := ""
			Dbselectarea("TAF")
			Dbsetorder(7)
			If Dbseek(xFILIAL("TAF")+"X"+"2"+Substr(TQB->TQB_CODBEM, 1, 3))
				(cTRBCZ04)->DESCRI := SUBSTR(TAF->TAF_NOMNIV,1,40)
			EndIf
		Else
			RecLock(cTRBCZ04,.F.)

			(cTRBCZ04)->OSQTD  += 1
		Endif

		//GRAVA TEMPOS
		If nHORAS < HtoM((cTRBCZ04)->SSHMET)
			(cTRBCZ04)->SSHMET := MtoH(nHORAS)
		Endif

		If nHORAS > HtoM((cTRBCZ04)->SSHMAT)
			(cTRBCZ04)->SSHMAT := MtoH(nHORAS)
		Endif

		(cTRBCZ04)->SSHTOT := MtoH(HtoM((cTRBCZ04)->SSHTOT)+HtoM(TQB->TQB_TEMPO))
		(cTRBCZ04)->SSHMED := MtoH(Round(HtoM((cTRBCZ04)->SSHTOT) / (cTRBCZ04)->OSQTD, 2))

		//GRAVA CUSTOS
		If nCUSTO < (cTRBCZ04)->OSMENC
			(cTRBCZ04)->OSMENC := nCUSTO
		Endif

		If nCUSTO > (cTRBCZ04)->OSMAIC
			(cTRBCZ04)->OSMAIC := nCUSTO
		Endif

		(cTRBCZ04)->OSCUST += nCUSTO
		(cTRBCZ04)->OSCUSM := Round((cTRBCZ04)->OSCUST / (cTRBCZ04)->OSQTD, 4)

		(cTRBCZ04)->(MsUnLock())
	EndIf
		///--------------------------------------------

	//--------------------------------------------
	//GRAVA ARQUIVO TEMPORARIO DE DETALHE
	C280TRBD()
	//--------------------------------------------

	dbSelectarea("TQB")
	dbSkip()
	End

	DbSelectArea("TQB")
	DbClearFilter()
	RetIndex("TQB")

	/*Substrituido pelo NGDELETRB
	FErase(cIndTQB+OrdBagExt())
	*/

	If !lGEROURR
		MsgStop(STR0222) //"Não existe dados para serem exibidos."
		Return .F.
	EndIf

	DbSelectArea("TQB")
	Set Filter To
Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C280AOSGER³ Autor ³ Ricardo Dal Ponte     ³ Data ³24/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Alimenta arquivos temporarios com os resumos de OS Geradas  |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function C280AOSGER()
lGEROURR := .F.

//#IFDEF TOP
//#ELSE
   Dbselectarea("TQB")
   Dbsetorder(1)

   cChave  := IndexKey()
   cFilPRI := ""
   cFilDET := ""

   cFilPRI :='TQB_FILIAL=="'+xFilial('TQB')+'" .And. '
   cFilDET :='DT_FILIAL=="'+xFilial('TQB')+'" .And. '

   If !Vazio(cDATADE) .And. !Vazio(cDATAATE)
      cFilPRI +='(DTOS(TQB_DTABER) >="'+DTOS(cDATADE) +'" .And. '
      cFilPRI +=' DTOS(TQB_DTABER) <="'+DTOS(cDATAATE)+'") .And. '

      cFilDET +='(DTOS(DT_DTABER) >="'+DTOS(cDATADE) +'" .And. '
      cFilDET +=' DTOS(DT_DTABER) <="'+DTOS(cDATAATE) +'") .And. '
   Endif

	cFilPRI += "!Empty(TQB_ORDEM)"
   cFilDET += "!Empty(DT_ORDEM)"

   cIndTQB := CriaTrab(Nil, .F.)

   IndRegua("TQB",cIndTQB,TQB->(IndexKey(1)),,cFilPRI,STR0052) //"Selecionando Registros"
	aAdd(aCriaTrab,cIndTQB)

Dbselectarea("TQB")

While !Eof()
   lGEROURR := .T.
   ///--------------------------------------------
   //BUSCA O CUSTO DA OS NO ARQUIVO DE CUSTOS STL
   nCUSTO  := 0

   Dbselectarea("STJ")
   Dbsetorder(1)
   If Dbseek(xFilial("STJ")+TQB->TQB_ORDEM)
      Dbselectarea("STL")
      Dbsetorder(01)
      Dbseek(xFilial("STL")+STJ->TJ_ORDEM+STJ->TJ_PLANO)
      While !Eof() .And. STL->TL_FILIAL == xFILIAL("STL") .And.;
         STL->TL_ORDEM == STJ->TJ_ORDEM .And. STL->TL_PLANO == STJ->TJ_PLANO

         nCUSTO += STL->TL_CUSTO
         DbSelectArea( "STL" )
         dbSkip()
      End
   Endif
   ///--------------------------------------------


   ///--------------------------------------------
   ///GRAVA TEMPORARIO POR PRIORIDADE
   dbSelectArea(cTRBOZ01)
   dbsetorder(1)

   If !Dbseek(TQB->TQB_PRIORI)
      RecLock(cTRBOZ01,.T.)

      (cTRBOZ01)->MKBROW := "S"
      (cTRBOZ01)->PRIORI := TQB->TQB_PRIORI
      (cTRBOZ01)->OSQTD  := 1      //NUMERO DE SS
      (cTRBOZ01)->OSMENC := nCUSTO //MENOR CUSTO
      (cTRBOZ01)->OSMAIC := nCUSTO //MAIOR CUSTO
      (cTRBOZ01)->OSCUSM := 0      //CUSTO MEDIO
      (cTRBOZ01)->OSCUST := 0      //CUSTO TOTAL

      If TQB->TQB_PRIORI == "1"
         (cTRBOZ01)->DESCRI := STR0053 //"ALTA"
      Elseif TQB->TQB_PRIORI == "2"
         (cTRBOZ01)->DESCRI := STR0054 //"MÉDIA"
      Elseif TQB->TQB_PRIORI == "3"
         (cTRBOZ01)->DESCRI := STR0055 //"BAIXA"
      Endif
   Else
      RecLock(cTRBOZ01,.F.)

      (cTRBOZ01)->OSQTD  += 1
   Endif

   If nCUSTO < (cTRBOZ01)->OSMENC
      (cTRBOZ01)->OSMENC := nCUSTO
   Endif

   If nCUSTO > (cTRBOZ01)->OSMAIC
      (cTRBOZ01)->OSMAIC := nCUSTO
   Endif

   (cTRBOZ01)->OSCUST += nCUSTO
   (cTRBOZ01)->OSCUSM := Round((cTRBOZ01)->OSCUST / (cTRBOZ01)->OSQTD, 4)

   (cTRBOZ01)->(MsUnLock())
   ///--------------------------------------------


   ///--------------------------------------------
   ///GRAVA TEMPORARIO POR SERVICO
   dbSelectArea(cTRBOZ02)
   dbsetorder(1)

   If !Dbseek(TQB->TQB_CDSERV)
      RecLock(cTRBOZ02,.T.)

      (cTRBOZ02)->MKBROW := "S"
      (cTRBOZ02)->CDSERV := TQB->TQB_CDSERV
      (cTRBOZ02)->OSQTD  := 1      //NUMERO DE SS
      (cTRBOZ02)->OSMENC := nCUSTO //MENOR CUSTO
      (cTRBOZ02)->OSMAIC := nCUSTO //MAIOR CUSTO
      (cTRBOZ02)->OSCUSM := 0      //CUSTO MEDIO
      (cTRBOZ02)->OSCUST := 0      //CUSTO TOTAL

      dbSelectArea("TQ3")
      dbsetorder(1)

      (cTRBOZ02)->DESCRI := ""
      If Dbseek(xFilial("TQ3")+TQB->TQB_CDSERV)
         (cTRBOZ02)->DESCRI := SUBSTR(TQ3->TQ3_NMSERV,1,20)
      EndIf
   Else
      RecLock(cTRBOZ02,.F.)

      (cTRBOZ02)->OSQTD  += 1
   Endif

   If nCUSTO < (cTRBOZ02)->OSMENC
      (cTRBOZ02)->OSMENC := nCUSTO
   Endif

   If nCUSTO > (cTRBOZ02)->OSMAIC
      (cTRBOZ02)->OSMAIC := nCUSTO
   Endif

   (cTRBOZ02)->OSCUST += nCUSTO
   (cTRBOZ02)->OSCUSM := Round((cTRBOZ02)->OSCUST / (cTRBOZ02)->OSQTD, 4)

   (cTRBOZ02)->(MsUnLock())
   ///--------------------------------------------

   ///--------------------------------------------
   ///GRAVA TEMPORARIO POR EXECUTANTE
   dbSelectArea(cTRBOZ03)
   dbsetorder(1)

   If !Dbseek(TQB->TQB_CDEXEC)
      RecLock(cTRBOZ03,.T.)

      (cTRBOZ03)->MKBROW := "S"
      (cTRBOZ03)->CDEXEC := TQB->TQB_CDEXEC
      (cTRBOZ03)->OSQTD  := 1      //NUMERO DE SS
      (cTRBOZ03)->OSMENC := nCUSTO //MENOR CUSTO
      (cTRBOZ03)->OSMAIC := nCUSTO //MAIOR CUSTO
      (cTRBOZ03)->OSCUSM := 0      //CUSTO MEDIO
      (cTRBOZ03)->OSCUST := 0      //CUSTO TOTAL

      If lFacilities
      	dbSelectArea("ST1")
	   	dbSetOrder(1)

	   	If dbSeek(xFilial("ST1")+TQB->TQB_CDEXEC)
	   		(cTRBSZ03)->DESCRI := SubStr(ST1->T1_NOME,1,20)
	   	EndIf
      Else
	      dbSelectArea("TQ4")
	      dbsetorder(1)

	      If Dbseek(xFilial("TQ4")+TQB->TQB_CDEXEC)
	         (cTRBOZ03)->DESCRI := TQ4->TQ4_NMEXEC
	      EndIf
	  EndIf
   Else
      RecLock(cTRBOZ03,.F.)

      (cTRBOZ03)->OSQTD  += 1
   Endif

   If nCUSTO < (cTRBOZ03)->OSMENC
      (cTRBOZ03)->OSMENC := nCUSTO
   Endif

   If nCUSTO > (cTRBOZ03)->OSMAIC
      (cTRBOZ03)->OSMAIC := nCUSTO
   Endif

   (cTRBOZ03)->OSCUST += nCUSTO
   (cTRBOZ03)->OSCUSM := Round((cTRBOZ03)->OSCUST / (cTRBOZ03)->OSQTD, 4)

   (cTRBOZ03)->(MsUnLock())
   ///--------------------------------------------


   ///--------------------------------------------
   ///GRAVA TEMPORARIO POR LOCALIZACAO
   If TQB->TQB_TIPOSS = "L"
	   dbSelectArea(cTRBOZ04)
	   dbsetorder(1)

	   If !Dbseek(TQB->TQB_CODBEM)
	      RecLock(cTRBOZ04,.T.)

	      (cTRBOZ04)->MKBROW := "S"
	      (cTRBOZ04)->CDLOCA := TQB->TQB_CODBEM
	      (cTRBOZ04)->OSQTD  := 1      //NUMERO DE SS
	      (cTRBOZ04)->OSMENC := nCUSTO //MENOR CUSTO
	      (cTRBOZ04)->OSMAIC := nCUSTO //MAIOR CUSTO
	      (cTRBOZ04)->OSCUSM := 0      //CUSTO MEDIO
	      (cTRBOZ04)->OSCUST := 0      //CUSTO TOTAL

	      (cTRBOZ04)->DESCRI := ""
	      Dbselectarea("TAF")
	      Dbsetorder(7)
	      If Dbseek(xFILIAL("TAF")+"X"+"2"+Substr(TQB->TQB_CODBEM, 1, 3))
	         (cTRBOZ04)->DESCRI := SUBSTR(TAF->TAF_NOMNIV,1,40)
	      EndIf
	   Else
	      RecLock(cTRBOZ04,.F.)

	      (cTRBOZ04)->OSQTD  += 1
	   Endif

	   If nCUSTO < (cTRBOZ04)->OSMENC
	      (cTRBOZ04)->OSMENC := nCUSTO
	   Endif

	   If nCUSTO > (cTRBOZ04)->OSMAIC
	      (cTRBOZ04)->OSMAIC := nCUSTO
	   Endif

	   (cTRBOZ04)->OSCUST += nCUSTO
	   (cTRBOZ04)->OSCUSM := Round((cTRBOZ04)->OSCUST / (cTRBOZ04)->OSQTD, 4)

	   (cTRBOZ04)->(MsUnLock())
	EndIf
	///--------------------------------------------

   //--------------------------------------------
   //GRAVA ARQUIVO TEMPORARIO DE DETALHE
   C280TRBD()
   //--------------------------------------------

   dbSelectarea("TQB")
   dbSkip()
End

DbSelectArea("TQB")
DbClearFilter()
RetIndex("TQB")

/*Substrituido pelo NGDELETRB
FErase(cIndTQB+OrdBagExt())
*/

If !lGEROURR
	MsgStop(STR0222) //"Não existe dados para serem exibidos."
	Return .F.
EndIf

DbSelectArea("TQB")
Set Filter To
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C280AATEND³ Autor ³ Ricardo Dal Ponte     ³ Data ³17/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Alimenta arquivos temporarios com os resumos de Atendimentos|±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function C280AATEND()
lGEROURR := .F.

//#IFDEF TOP
//#ELSE
   Dbselectarea("TQB")
   Dbsetorder(1)

   cChave  := IndexKey()
   cFilPRI := ""
   cFilDET := ""

   cFilPRI :='TQB_FILIAL=="'+xFilial('TQB')+'" .And. '
   cFilDET :='DT_FILIAL=="'+xFilial('TQB')+'" .And. '

   If !Vazio(cDATADE) .And. !Vazio(cDATAATE)
      cFilPRI +='(DTOS(TQB_DTABER) >="'+DTOS(cDATADE) +'" .And. '
      cFilPRI +=' DTOS(TQB_DTABER) <="'+DTOS(cDATAATE)+'") .And. '

      cFilDET +='(DTOS(DT_DTABER) >="'+DTOS(cDATADE) +'" .And. '
      cFilDET +=' DTOS(DT_DTABER) <="'+DTOS(cDATAATE) +'") .And. '
   Endif

	cFilPRI += "TQB_SOLUCA == 'E'"
   cFilDET += "DT_SOLUCA == 'E'"

   cIndTQB := CriaTrab(Nil, .F.)

   IndRegua("TQB",cIndTQB,TQB->(IndexKey(1)),,cFilPRI,STR0052) //"Selecionando Registros"
	aAdd(aCriaTrab,cIndTQB)

//#ENDIF

Dbselectarea("TQB")

While !Eof()
   lGEROURR := .T.
   ///--------------------------------------------
   //CALCULA ATRASO DA SS
   dDTABER := TQB->TQB_DTABER
   nDIAS   := TQB->TQB_DTFECH - dDTABER

   If nDIAS < 0 .Or. dDTABER > TQB->TQB_DTFECH
      nDIAS := 0
   Endif

   nHORAS := HtoM(TQB->TQB_TEMPO)
   ///--------------------------------------------


   ///--------------------------------------------
   ///GRAVA TEMPORARIO POR PRIORIDADE
   dbSelectArea(cTRBAZ01)
   dbsetorder(1)

   If !Dbseek(TQB->TQB_PRIORI)
      RecLock(cTRBAZ01,.T.)

      (cTRBAZ01)->MKBROW := "S"
      (cTRBAZ01)->PRIORI := TQB->TQB_PRIORI
      (cTRBAZ01)->SSQTD  := 1
      (cTRBAZ01)->SSRMET := nDIAS //MENOR TEMPO ATENDIMENTO EM DIAS
      (cTRBAZ01)->SSRMAT := nDIAS //MAIOR TEMPO ATENDIMENTO EM DIAS
      (cTRBAZ01)->SSRMED := 0     //TEMPO ATENDIMENTO MEDIO EM DIAS
      (cTRBAZ01)->SSRTOT := 0     //TEMPO ATENDIMENTO TOTAL EM DIAS
      (cTRBAZ01)->SSHMET := MtoH(nHORAS) //MENOR TEMPO ATENDIMENTO EM HORAS
      (cTRBAZ01)->SSHMAT := MtoH(nHORAS) //MAIOR TEMPO ATENDIMENTO EM HORAS
      (cTRBAZ01)->SSHMED := MtoH(0)      //TEMPO ATENDIMENTO MEDIO EM HORAS
      (cTRBAZ01)->SSHTOT := MtoH(0)      //TEMPO ATENDIMENTO TOTAL EM HORAS

      If TQB->TQB_PRIORI == "1"
         (cTRBAZ01)->DESCRI := STR0053 //"ALTA"
      Elseif TQB->TQB_PRIORI == "2"
         (cTRBAZ01)->DESCRI := STR0054 //"MÉDIA"
      Elseif TQB->TQB_PRIORI == "3"
         (cTRBAZ01)->DESCRI := STR0055 //"BAIXA"
      Endif
   Else
      RecLock(cTRBAZ01,.F.)

      (cTRBAZ01)->SSQTD  += 1
   Endif

   If nDIAS < (cTRBAZ01)->SSRMET
      (cTRBAZ01)->SSRMET := nDIAS
   Endif

   If nDIAS > (cTRBAZ01)->SSRMAT
      (cTRBAZ01)->SSRMAT := nDIAS
   Endif

   (cTRBAZ01)->SSRTOT += nDIAS
   (cTRBAZ01)->SSRMED := Round((cTRBAZ01)->SSRTOT / (cTRBAZ01)->SSQTD, 2)

   //GRAVA CAMPOS DE HORAS
   If nHORAS < HtoM((cTRBAZ01)->SSHMET)
      (cTRBAZ01)->SSHMET := MtoH(nHORAS)
   Endif

   If nHORAS > HtoM((cTRBAZ01)->SSHMAT)
      (cTRBAZ01)->SSHMAT := MtoH(nHORAS)
   Endif

   (cTRBAZ01)->SSHTOT := MtoH(HtoM((cTRBAZ01)->SSHTOT)+HtoM(TQB->TQB_TEMPO))
   (cTRBAZ01)->SSHMED := MtoH(Round(HtoM((cTRBAZ01)->SSHTOT) / (cTRBAZ01)->SSQTD, 2))

   (cTRBAZ01)->(MsUnLock())
   ///--------------------------------------------


   ///--------------------------------------------
   ///GRAVA TEMPORARIO POR SERVICO
   dbSelectArea(cTRBAZ02)
   dbsetorder(1)

   If !Dbseek(TQB->TQB_CDSERV)
      RecLock(cTRBAZ02,.T.)

      (cTRBAZ02)->MKBROW := "S"
      (cTRBAZ02)->CDSERV := TQB->TQB_CDSERV
      (cTRBAZ02)->SSQTD  := 1
      (cTRBAZ02)->SSRMET := nDIAS //MENOR TEMPO ATENDIMENTO EM DIAS
      (cTRBAZ02)->SSRMAT := nDIAS //MAIOR TEMPO ATENDIMENTO EM DIAS
      (cTRBAZ02)->SSRMED := 0     //TEMPO ATENDIMENTO MEDIO EM DIAS
      (cTRBAZ02)->SSRTOT := 0     //TEMPO ATENDIMENTO TOTAL EM DIAS
      (cTRBAZ02)->SSHMET := MtoH(nHORAS) //MENOR TEMPO ATENDIMENTO EM HORAS
      (cTRBAZ02)->SSHMAT := MtoH(nHORAS) //MAIOR TEMPO ATENDIMENTO EM HORAS
      (cTRBAZ02)->SSHMED := MtoH(0)      //TEMPO ATENDIMENTO MEDIO EM HORAS
      (cTRBAZ02)->SSHTOT := MtoH(0)      //TEMPO ATENDIMENTO TOTAL EM HORAS

      dbSelectArea("TQ3")
      dbsetorder(1)

      (cTRBAZ02)->DESCRI := ""
      If Dbseek(xFilial("TQ3")+TQB->TQB_CDSERV)
         (cTRBAZ02)->DESCRI := SUBSTR(TQ3->TQ3_NMSERV,1,20)
      EndIf
   Else
      RecLock(cTRBPZ02,.F.)

      (cTRBAZ02)->SSQTD  += 1
   Endif

   If nDIAS < (cTRBAZ02)->SSRMET
      (cTRBAZ02)->SSRMET := nDIAS
   Endif

   If nDIAS > (cTRBAZ02)->SSRMAT
      (cTRBAZ02)->SSRMAT := nDIAS
   Endif

   (cTRBAZ02)->SSRTOT += nDIAS
   (cTRBAZ02)->SSRMED := Round((cTRBAZ02)->SSRTOT / (cTRBAZ02)->SSQTD, 2)

   //GRAVA CAMPOS DE HORAS
   If nHORAS < HtoM((cTRBAZ02)->SSHMET)
      (cTRBAZ02)->SSHMET := MtoH(nHORAS)
   Endif

   If nHORAS > HtoM((cTRBAZ02)->SSHMAT)
      (cTRBAZ02)->SSHMAT := MtoH(nHORAS)
   Endif

   (cTRBAZ02)->SSHTOT := MtoH(HtoM((cTRBAZ02)->SSHTOT)+HtoM(TQB->TQB_TEMPO))
   (cTRBAZ02)->SSHMED := MtoH(Round(HtoM((cTRBAZ02)->SSHTOT) / (cTRBAZ02)->SSQTD, 2))

   (cTRBAZ02)->(MsUnLock())
   ///--------------------------------------------

   ///--------------------------------------------
   ///GRAVA TEMPORARIO POR EXECUTANTE
   dbSelectArea(cTRBAZ03)
   dbsetorder(1)

   If !Dbseek(TQB->TQB_CDEXEC)
      RecLock(cTRBAZ03,.T.)

      (cTRBAZ03)->MKBROW := "S"
      (cTRBAZ03)->CDEXEC := TQB->TQB_CDEXEC
      (cTRBAZ03)->SSQTD  := 1
      (cTRBAZ03)->SSRMET := nDIAS //MENOR TEMPO ATENDIMENTO EM DIAS
      (cTRBAZ03)->SSRMAT := nDIAS //MAIOR TEMPO ATENDIMENTO EM DIAS
      (cTRBAZ03)->SSRMED := 0     //TEMPO ATENDIMENTO MEDIO EM DIAS
      (cTRBAZ03)->SSRTOT := 0     //TEMPO ATENDIMENTO TOTAL EM DIAS
      (cTRBAZ03)->SSHMET := MtoH(nHORAS) //MENOR TEMPO ATENDIMENTO EM HORAS
      (cTRBAZ03)->SSHMAT := MtoH(nHORAS) //MAIOR TEMPO ATENDIMENTO EM HORAS
      (cTRBAZ03)->SSHMED := MtoH(0)      //TEMPO ATENDIMENTO MEDIO EM HORAS
      (cTRBAZ03)->SSHTOT := MtoH(0)      //TEMPO ATENDIMENTO TOTAL EM HORAS

      dbSelectArea("TQ4")
      dbsetorder(1)
	  If lFacilities
      	dbSelectArea("ST1")
	   	dbSetOrder(1)

	   	If dbSeek(xFilial("ST1")+TQB->TQB_CDEXEC)
	   		(cTRBAZ03)->DESCRI := SubStr(ST1->T1_NOME,1,20)
	   	EndIf
	  Else
	      If Dbseek(xFilial("TQ4")+TQB->TQB_CDEXEC)
	         (cTRBAZ03)->DESCRI := TQ4->TQ4_NMEXEC
	      EndIf
	  EndIf
   Else
      RecLock(cTRBAZ03,.F.)

      (cTRBAZ03)->SSQTD  += 1
   Endif

   If nDIAS < (cTRBAZ03)->SSRMET
      (cTRBAZ03)->SSRMET := nDIAS
   Endif

   If nDIAS > (cTRBAZ03)->SSRMAT
      (cTRBAZ03)->SSRMAT := nDIAS
   Endif

   (cTRBAZ03)->SSRTOT += nDIAS
   (cTRBAZ03)->SSRMED := Round((cTRBAZ03)->SSRTOT / (cTRBAZ03)->SSQTD, 2)

   //GRAVA CAMPOS DE HORAS
   If nHORAS < HtoM((cTRBAZ03)->SSHMET)
      (cTRBAZ03)->SSHMET := MtoH(nHORAS)
   Endif

   If nHORAS > HtoM((cTRBAZ03)->SSHMAT)
      (cTRBAZ03)->SSHMAT := MtoH(nHORAS)
   Endif

   (cTRBAZ03)->SSHTOT := MtoH(HtoM((cTRBAZ03)->SSHTOT)+HtoM(TQB->TQB_TEMPO))
   (cTRBAZ03)->SSHMED := MtoH(Round(HtoM((cTRBAZ03)->SSHTOT) / (cTRBAZ03)->SSQTD, 2))

   (cTRBAZ03)->(MsUnLock())
   ///--------------------------------------------


   ///--------------------------------------------
   ///GRAVA TEMPORARIO POR LOCALIZACAO
   If TQB->TQB_TIPOSS = "L"
	   dbSelectArea(cTRBAZ04)
	   dbsetorder(1)

	   If !Dbseek(TQB->TQB_CODBEM)
	      RecLock(cTRBAZ04,.T.)

	      (cTRBAZ04)->MKBROW := "S"
	      (cTRBAZ04)->CDLOCA := TQB->TQB_CODBEM
	      (cTRBAZ04)->SSQTD  := 1
	      (cTRBAZ04)->SSRMET := nDIAS //MENOR TEMPO ATENDIMENTO EM DIAS
	      (cTRBAZ04)->SSRMAT := nDIAS //MAIOR TEMPO ATENDIMENTO EM DIAS
	      (cTRBAZ04)->SSRMED := 0     //TEMPO ATENDIMENTO MEDIO EM DIAS
	      (cTRBAZ04)->SSRTOT := 0     //TEMPO ATENDIMENTO TOTAL EM DIAS
	      (cTRBAZ04)->SSHMET := MtoH(nHORAS) //MENOR TEMPO ATENDIMENTO EM HORAS
	      (cTRBAZ04)->SSHMAT := MtoH(nHORAS) //MAIOR TEMPO ATENDIMENTO EM HORAS
	      (cTRBAZ04)->SSHMED := MtoH(0)      //TEMPO ATENDIMENTO MEDIO EM HORAS
	      (cTRBAZ04)->SSHTOT := MtoH(0)      //TEMPO ATENDIMENTO TOTAL EM HORAS

	      (cTRBAZ04)->DESCRI := ""
	      Dbselectarea("TAF")
	      Dbsetorder(7)
	      If Dbseek(xFILIAL("TAF")+"X"+"2"+Substr(TQB->TQB_CODBEM, 1, 3))
	         (cTRBAZ04)->DESCRI := SUBSTR(TAF->TAF_NOMNIV,1,40)
	      EndIf
	   Else
	      RecLock(cTRBAZ04,.F.)

	      (cTRBAZ04)->SSQTD  += 1
	   Endif

	   If nDIAS < (cTRBAZ04)->SSRMET
	      (cTRBAZ04)->SSRMET := nDIAS
	   Endif

	   If nDIAS > (cTRBAZ04)->SSRMAT
	      (cTRBAZ04)->SSRMAT := nDIAS
	   Endif

	   (cTRBAZ04)->SSRTOT += nDIAS
	   (cTRBAZ04)->SSRMED := Round((cTRBAZ04)->SSRTOT / (cTRBAZ04)->SSQTD, 2)

	   //GRAVA CAMPOS DE HORAS
	   If nHORAS < HtoM((cTRBAZ04)->SSHMET)
	      (cTRBAZ04)->SSHMET := MtoH(nHORAS)
	   Endif

	   If nHORAS > HtoM((cTRBAZ04)->SSHMAT)
	      (cTRBAZ04)->SSHMAT := MtoH(nHORAS)
	   Endif

	   (cTRBAZ04)->SSHTOT := MtoH(HtoM((cTRBAZ04)->SSHTOT)+HtoM(TQB->TQB_TEMPO))
	   (cTRBAZ04)->SSHMED := MtoH(Round(HtoM((cTRBAZ04)->SSHTOT) / (cTRBAZ04)->SSQTD, 2))

	   (cTRBAZ04)->(MsUnLock())
   EndIf
   ///--------------------------------------------


   //--------------------------------------------
   //GRAVA ARQUIVO TEMPORARIO DE DETALHE
   C280TRBD()
   //--------------------------------------------

   dbSelectarea("TQB")
   dbSkip()
End

DbSelectArea("TQB")
DbClearFilter()
RetIndex("TQB")

/*Substrituido pelo NGDELETRB
FErase(cIndTQB+OrdBagExt())
*/

If !lGEROURR
	MsgStop(STR0222) //"Não existe dados para serem exibidos."
	Return .F.
EndIf

DbSelectArea("TQB")
Set Filter To
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C280TPCON ³ Autor ³ Ricardo Dal Ponte     ³ Data ³17/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Identificacao do Tipo de Consulta                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function C280TPCON()
   lDetalhar := .F.
   lGerar    := .F.
   lGEROURR  := .F.

   CursorWait()
	If lMARKDET
    	oMARKDET:oBROWSE:hide()
	   	MsFreeObj(@oMARKDET:oBROWSE,.t.)
	   	oMARKDET:oBROWSE:End()
	   	oMARKDET:oBROWSE:=NIL
	   	lMARKDET := .F.

      	C280VFILTR()
   Endif

   If !Empty(cTPTABLE)
      dbSelectArea(cTPTABLE)
      ZAP

      oMARKRES:oBROWSE:Refresh()
   EndIf

   If cTPANALISE = aTPANALISE[1]
      aAGRUPA := {STR0067, STR0068, STR0069, STR0070, STR0071} //"Prioridade"###"Serviço"###"Atraso"###"Executante"###"Localização"
      cAGRUPA := aAGRUPA[1]
   EndIf

   If cTPANALISE = aTPANALISE[2]
      aAGRUPA := {STR0067, STR0068, STR0070, STR0072, STR0073, STR0071} //"Prioridade"###"Serviço"###"Executante"###"Atendimento Prazo"###"Atendimento Necesidade"###"Localização"
      cAGRUPA := aAGRUPA[1]
	EndIf

   If cTPANALISE = aTPANALISE[3]
      aAGRUPA := {STR0067, STR0068, STR0070, STR0071} //"Prioridade"###"Serviço"###"Executante"###"Localização"
      cAGRUPA := aAGRUPA[1]
	EndIf

   If cTPANALISE = aTPANALISE[4]
      aAGRUPA := {STR0067, STR0068, STR0070, STR0071} //"Prioridade"###"Serviço"###"Executante"###"Localização"
      cAGRUPA := aAGRUPA[1]
	EndIf

   If cTPANALISE = aTPANALISE[5]
      aAGRUPA := {STR0067, STR0068, STR0070, STR0071} //"Prioridade"###"Serviço"###"Executante"###"Localização"
      cAGRUPA := aAGRUPA[1]
	EndIf
	CursorArrow()
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C280BRWRE ³ Autor ³ Ricardo Dal Ponte     ³ Data ³10/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta Browse com resumo na tela                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function C280BRWRE(cOpcao)

Local lMsg  := .T.

   lDetalhar := .F.
   CursorWait()

   If cTPANALISE = aTPANALISE[1]
		If cOpcao = aAGRUPA[1] //Prioridade
	      cTPTABLE := cTRBPZ01
	   ElseIf cOpcao = aAGRUPA[2] //Serviço
	      cTPTABLE := cTRBPZ02
	   ElseIf cOpcao = aAGRUPA[3] //Atraso
	      cTPTABLE := cTRBPZ03
	   ElseIf cOpcao = aAGRUPA[4] //Executante
	      cTPTABLE := cTRBPZ04
	   ElseIf cOpcao = aAGRUPA[5] //Localizacao
	      cTPTABLE := cTRBPZ05
	   Endif

		aTRB := {}
		AADD(aTRB,{"MKBROW" ,NIL," "    ,})
		AADD(aTRB,{"DESCRI" ,NIL,STR0074,}) //"Descrição"
		AADD(aTRB,{"SSQTD"  ,NIL,STR0075,}) //"Qtd. SS"
		AADD(aTRB,{"SSRMED" ,NIL,STR0076,"@E 9,999,999.99"}) //"Atraso Médio"
		AADD(aTRB,{"SSRMAT" ,NIL,STR0077,"@E 9999.99"}) //"Maior Atraso"
		AADD(aTRB,{"SSRMET" ,NIL,STR0078,"@E 9999.99"}) //"Menor Atraso"
	EndIf

   If cTPANALISE = aTPANALISE[2]
	   If cOpcao = aAGRUPA[1] //Prioridade

		  	cTPTABLE := cTRBSZ01
			aTRB     := {}

			AADD(aTRB,{"MKBROW" ,NIL," "    ,})
			AADD(aTRB,{"DESCRI" ,NIL,STR0074,}) //"Descrição"
			AADD(aTRB,{"SSQTD"  ,NIL,STR0075,}) //"Qtd. SS"
			AADD(aTRB,{"PSOTIM" ,NIL,STR0079,}) //"At.Prazo Otimo"
			AADD(aTRB,{"PSBOM"  ,NIL,STR0080,}) //"At.Prazo Bom"
			AADD(aTRB,{"PSSATI" ,NIL,STR0081,}) //"At.Prazo Satisf."
			AADD(aTRB,{"PSRUIM" ,NIL,STR0082,}) //"At.Prazo Ruim"
			AADD(aTRB,{"NSOTIM" ,NIL,STR0083,}) //"At.Neces Otimo"
			AADD(aTRB,{"NSBOM"  ,NIL,STR0084,}) //"At.Neces Bom"
			AADD(aTRB,{"NSSATI" ,NIL,STR0085,}) //"At.Neces Satisf."
			AADD(aTRB,{"NSRUIM" ,NIL,STR0086,}) //"At.Neces Ruim"
	   ElseIf cOpcao = aAGRUPA[2] //Serviço

			cTPTABLE := cTRBSZ02
			aTRB     := {}

			AADD(aTRB,{"MKBROW" ,NIL," "    ,})
			AADD(aTRB,{"DESCRI" ,NIL,STR0074,}) //"Descrição"
			AADD(aTRB,{"SSQTD"  ,NIL,STR0075,}) //"Qtd. SS"
			AADD(aTRB,{"PSOTIM" ,NIL,STR0079,}) //"At.Prazo Otimo"
			AADD(aTRB,{"PSBOM"  ,NIL,STR0080,}) //"At.Prazo Bom"
			AADD(aTRB,{"PSSATI" ,NIL,STR0081,}) //"At.Prazo Satisf."
			AADD(aTRB,{"PSRUIM" ,NIL,STR0082,}) //"At.Prazo Ruim"
			AADD(aTRB,{"NSOTIM" ,NIL,STR0083,}) //"At.Neces Otimo"
			AADD(aTRB,{"NSBOM"  ,NIL,STR0084,}) //"At.Neces Bom"
			AADD(aTRB,{"NSSATI" ,NIL,STR0085,}) //"At.Neces Satisf."
			AADD(aTRB,{"NSRUIM" ,NIL,STR0086,}) //"At.Neces Ruim"

	   ElseIf cOpcao = aAGRUPA[3] //Executante

			cTPTABLE := cTRBSZ03
			aTRB     := {}

			AADD(aTRB,{"MKBROW" ,NIL," "    ,})
			AADD(aTRB,{"DESCRI" ,NIL,STR0074,}) //"Descrição"
			AADD(aTRB,{"SSQTD"  ,NIL,STR0075,}) //"Qtd. SS"
			AADD(aTRB,{"PSOTIM" ,NIL,STR0079,}) //"At.Prazo Otimo"
			AADD(aTRB,{"PSBOM"  ,NIL,STR0080,}) //"At.Prazo Bom"
			AADD(aTRB,{"PSSATI" ,NIL,STR0081,}) //"At.Prazo Satisf."
			AADD(aTRB,{"PSRUIM" ,NIL,STR0082,}) //"At.Prazo Ruim"
			AADD(aTRB,{"NSOTIM" ,NIL,STR0083,}) //"At.Neces Otimo"
			AADD(aTRB,{"NSBOM"  ,NIL,STR0084,}) //"At.Neces Bom"
			AADD(aTRB,{"NSSATI" ,NIL,STR0085,}) //"At.Neces Satisf."
			AADD(aTRB,{"NSRUIM" ,NIL,STR0086,}) //"At.Neces Ruim"

	   ElseIf cOpcao = aAGRUPA[4] //Atend Prazo

			cTPTABLE := cTRBSZ04
			aTRB     := {}

			AADD(aTRB,{"MKBROW" ,NIL," "    ,})
			AADD(aTRB,{"DESCRI" ,NIL,STR0074,}) //"Descrição"
			AADD(aTRB,{"SSQTD"  ,NIL,STR0075,}) //"Qtd. SS"

	   ElseIf cOpcao = aAGRUPA[5] //Atend Necessidade

		  	cTPTABLE := cTRBSZ05
			aTRB     := {}

			AADD(aTRB,{"MKBROW" ,NIL," "    ,})
			AADD(aTRB,{"DESCRI" ,NIL,STR0074,}) //"Descrição"
			AADD(aTRB,{"SSQTD"  ,NIL,STR0075,}) //"Qtd. SS"

	   ElseIf cOpcao = aAGRUPA[6] //Localizacao

		  	cTPTABLE := cTRBSZ06
			aTRB     := {}

			AADD(aTRB,{"MKBROW" ,NIL," "    ,})
			AADD(aTRB,{"DESCRI" ,NIL,STR0074,}) //"Descrição"
			AADD(aTRB,{"SSQTD"  ,NIL,STR0075,}) //"Qtd. SS"
			AADD(aTRB,{"PSOTIM" ,NIL,STR0079,}) //"At.Prazo Otimo"
			AADD(aTRB,{"PSBOM"  ,NIL,STR0080,}) //"At.Prazo Bom"
			AADD(aTRB,{"PSSATI" ,NIL,STR0081,}) //"At.Prazo Satisf."
			AADD(aTRB,{"PSRUIM" ,NIL,STR0082,}) //"At.Prazo Ruim"
			AADD(aTRB,{"NSOTIM" ,NIL,STR0083,}) //"At.Neces Otimo"
			AADD(aTRB,{"NSBOM"  ,NIL,STR0084,}) //"At.Neces Bom"
			AADD(aTRB,{"NSSATI" ,NIL,STR0085,}) //"At.Neces Satisf."
			AADD(aTRB,{"NSRUIM" ,NIL,STR0086,}) //"At.Neces Ruim"
	   Endif
	EndIf

   If cTPANALISE = aTPANALISE[3]
		aTRB := {}
		AADD(aTRB,{"MKBROW" ,NIL," "    ,})
		AADD(aTRB,{"DESCRI" ,NIL,STR0074,}) //"Descrição"
		AADD(aTRB,{"OSQTD"  ,NIL,STR0087,}) //"Qtd. OS"
		AADD(aTRB,{"OSMENC" ,NIL,STR0088,"@E 999999999999999.99"}) //"Menor Custo"
		AADD(aTRB,{"OSMAIC" ,NIL,STR0089,"@E 999999999999999.99"}) //"Maior Custo"
		AADD(aTRB,{"OSCUSM" ,NIL,STR0090,"@E 999999999999999.99"}) //"Custo Médio"
		AADD(aTRB,{"OSCUST" ,NIL,STR0091,"@E 999999999999999.99"}) //"Custo Total"
		AADD(aTRB,{"SSHMET" ,NIL,STR0092,}) //"Menor Tempo Atend. Hs"
		AADD(aTRB,{"SSHMAT" ,NIL,STR0093,}) //"Maior Tempo Atend. Hs"
		AADD(aTRB,{"SSHTOT" ,NIL,STR0094,}) //"Tempo Atend. Total Hs"
		AADD(aTRB,{"SSHMED" ,NIL,STR0095,}) //"Tempo Atend. Médio Hs"

		If cOpcao = aAGRUPA[1] //Prioridade
	      cTPTABLE := cTRBCZ01
	   ElseIf cOpcao = aAGRUPA[2] //Serviço
	      cTPTABLE := cTRBCZ02
	   ElseIf cOpcao = aAGRUPA[3]  //Executante
	      cTPTABLE := cTRBCZ03
	   ElseIf cOpcao = aAGRUPA[4]  //Localizacao
	      cTPTABLE := cTRBCZ04
	   Endif
	EndIf

   If cTPANALISE = aTPANALISE[4]
		aTRB := {}
		AADD(aTRB,{"MKBROW" ,NIL," "    ,})
		AADD(aTRB,{"DESCRI" ,NIL,STR0074,}) //"Descrição"
		AADD(aTRB,{"OSQTD"  ,NIL,STR0087,}) //"Qtd. OS"
		AADD(aTRB,{"OSMENC" ,NIL,STR0088,"@E 999999999999999.99"}) //"Menor Custo"
		AADD(aTRB,{"OSMAIC" ,NIL,STR0089,"@E 999999999999999.99"}) //"Maior Custo"
		AADD(aTRB,{"OSCUSM" ,NIL,STR0090,"@E 999999999999999.99"}) //"Custo Médio"
		AADD(aTRB,{"OSCUST" ,NIL,STR0091,"@E 999999999999999.99"}) //"Custo Total"

		If cOpcao = aAGRUPA[1] //Prioridade
	      cTPTABLE := cTRBOZ01
	   ElseIf cOpcao = aAGRUPA[2] //Serviço
	      cTPTABLE := cTRBOZ02
	   ElseIf cOpcao = aAGRUPA[3]  //Executante
	      cTPTABLE := cTRBOZ03
	   ElseIf cOpcao = aAGRUPA[4]  //Localizacao
	      cTPTABLE := cTRBOZ04
	   Endif
	EndIf

   If cTPANALISE = aTPANALISE[5]
		aTRB := {}
		AADD(aTRB,{"MKBROW" ,NIL," "    ,})
		AADD(aTRB,{"DESCRI" ,NIL,STR0074,}) //"Descrição"
		AADD(aTRB,{"SSQTD"  ,NIL,STR0075,}) //"Qtd. SS"
		AADD(aTRB,{"SSRMED" ,NIL,STR0096,"@E 9,999,999.99"}) //"Tmp Médio Atend Dias"
		AADD(aTRB,{"SSRMAT" ,NIL,STR0097,"@E 9999.99"}) //"Maior Tmp Atend Dias"
		AADD(aTRB,{"SSRMET" ,NIL,STR0098,"@E 9999.99"}) //"Menor Tmp Atend Dias"
		AADD(aTRB,{"SSHMED" ,NIL,STR0099,}) //"Duração Média Hs"
		AADD(aTRB,{"SSHMAT" ,NIL,STR0100,}) //"Maior Duração Hs"
		AADD(aTRB,{"SSHMET" ,NIL,STR0101,}) //"Menor Duração Hs"
		AADD(aTRB,{"SSHTOT" ,NIL,STR0102,}) //"Duração Total Hs"

		If cOpcao = aAGRUPA[1] //Prioridade
	      cTPTABLE := cTRBAZ01
	   ElseIf cOpcao = aAGRUPA[2] //Serviço
	      cTPTABLE := cTRBAZ02
	   ElseIf cOpcao = aAGRUPA[3]  //Executante
	      cTPTABLE := cTRBAZ03
	   ElseIf cOpcao = aAGRUPA[4]  //Localizacao
	      cTPTABLE := cTRBAZ04
	   Endif
	EndIf

   dbSelectArea(cTPTABLE)
   dbGoTop()
   If lPrin
		lMsg := .F.
	EndIf
	lGEROURR := .F.
	While !Eof()
   	lMsg := .F.
   	lPrin := .F.
   	lGEROURR := .T.
	   Exit
   End


   If lMsg
		MsgStop(STR0222) //"Não existe dados para serem exibidos."
	EndIf

	If lMARKRES = .T.
    	oMARKRES:oBROWSE:hide()
   	MsFreeObj(@oMARKRES:oBROWSE,.t.)
   	oMARKRES:oBROWSE:End()
   	oMARKRES:oBROWSE:=NIL

    	oAGRUPA:hide()
   	MsFreeObj(@oAGRUPA,.t.)
   	oAGRUPA:End()
   	oAGRUPA:=NIL
   Endif

   @ 38,005 MSCOMBOBOX oAGRUPA VAR cAGRUPA ITEMS aAGRUPA SIZE 70,12 OF oDlg1 PIXEL ON CHANGE (C280BRWRE(cAGRUPA)) When lGerar

   cMARCA := "S"
   oMARKRES       := MsSelect():NEW(cTPTABLE,"MKBROW",,aTRB,,@cMARCA,{85,005,260,155})
   //oMARKRES:bMARK := {| | MNTA320MA(cMARCA,lINVERTE)}
   oMARKRES:oBROWSE:lHASMARK := .T.
   oMARKRES:oBROWSE:lCANALLMARK := .T.
   oMARKRES:oBROWSE:bALLMARK := {|| PROCESSA({||C280ALLMAR(cTPTABLE)})}
   oMARKRES:oBROWSE:Refresh()
   oMARKRES:oWnd:Refresh()
   CursorArrow()
	If lMARKRES = .T.
    	oMARKRES:oBROWSE:SetFocus()
   Endif
   lMARKRES = .T.

   C280BRWDE()
   CursorArrow()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C280BRWDE ³ Autor ³ Ricardo Dal Ponte     ³ Data ³11/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta Browse com o detalhe das SS                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function C280BRWDE()

	If lMARKDET
		oMARKDET:oBROWSE:hide()
		MsFreeObj(@oMARKDET:oBROWSE,.t.)
		oMARKDET:oBROWSE:End()
		oMARKDET:oBROWSE:=NIL
		lMARKDET := .F.

		C280VFILTR()
	EndIf

	If lDetalhar = .F.
    	Return
	EndIf

	dbSelectArea(cTRBD)
	dbGoTop()

	cMARCA := "S"

	oMARKDET := MsSelect():NEW(cTRBD,,,aTRBD,,@cMARCA,{85,165,260,500})

	oMARKDET:oBROWSE:lHASMARK := .F.
	oMARKDET:oBROWSE:lCANALLMARK := .F.

	oMARKDET:oBROWSE:Refresh()
	CursorArrow()
	oMARKDET:oBROWSE:SetFocus()

	lMARKDET := .T.

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C280GERAR ³ Autor ³ Ricardo Dal Ponte     ³ Data ³11/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao principal de geracao da consulta                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function C280GERAR(cOpcao)
   lDetalhar := .F.
   lGerar := .T.

   CursorWait()
   IF lGerar = .T.
      dbSelectArea(cTRBPZ01)
      ZAP

      dbSelectArea(cTRBPZ02)
      ZAP

      dbSelectArea(cTRBPZ03)
      ZAP

      dbSelectArea(cTRBPZ04)
      ZAP

      dbSelectArea(cTRBPZ05)
      ZAP

      dbSelectArea(cTRBSZ01)
      ZAP

      dbSelectArea(cTRBSZ02)
      ZAP

      dbSelectArea(cTRBSZ03)
      ZAP

      dbSelectArea(cTRBSZ04)
      ZAP

      dbSelectArea(cTRBSZ05)
      ZAP

      dbSelectArea(cTRBSZ06)
      ZAP

      dbSelectArea(cTRBCZ01)
      ZAP

      dbSelectArea(cTRBCZ02)
      ZAP

      dbSelectArea(cTRBCZ03)
      ZAP

      dbSelectArea(cTRBCZ04)
      ZAP

      dbSelectArea(cTRBOZ01)
      ZAP

      dbSelectArea(cTRBOZ02)
      ZAP

      dbSelectArea(cTRBOZ03)
      ZAP

      dbSelectArea(cTRBOZ04)
      ZAP

      dbSelectArea(cTRBAZ01)
      ZAP

      dbSelectArea(cTRBAZ02)
      ZAP

      dbSelectArea(cTRBAZ03)
      ZAP

      dbSelectArea(cTRBAZ04)
      ZAP

      If Select(cTRBD) > 0
			dbSelectArea(cTRBD)
			ZAP
		EndIf
   EndIf

   If cOpcao = aTPANALISE[1] //Pendencias
      C280APENDE()
      C280BRWRE(cAGRUPA)
   ElseIf cOpcao = aTPANALISE[2] //Satisfacao
      C280ASATIS()
      C280BRWRE(cAGRUPA)
   ElseIf cOpcao = aTPANALISE[3] //Custo/Tempo da SS
      C280ACUSTE()
      C280BRWRE(cAGRUPA)
   ElseIf cOpcao = aTPANALISE[4] //Os geradas
      C280AOSGER()
      C280BRWRE(cAGRUPA)
   ElseIf cOpcao = aTPANALISE[5] //Analise de Atendimento
      C280AATEND()
      C280BRWRE(cAGRUPA)
   Endif

   lALLMARK := .T.
	lGerar := .T.
	CursorArrow()
Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C280TRBD  ³ Autor ³ Ricardo Dal Ponte     ³ Data ³11/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava Arquivo temporario de detalhe                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function C280TRBD()

dbSelectArea(cTRBD)
(cTRBD)->(DbAppend())

(cTRBD)->DT_FILIAL := TQB->TQB_FILIAL
(cTRBD)->DT_SOLICI := TQB->TQB_SOLICI
(cTRBD)->DT_TIPOS  := TQB->TQB_TIPOSS

If (cTRBD)->DT_TIPOS = "B"
   (cTRBD)->DT_TIPOSS  := STR0103 //"Bem"
EndIf

If (cTRBD)->DT_TIPOS = "L"
   (cTRBD)->DT_TIPOSS  := STR0071 //"Localização"
EndIf

(cTRBD)->DT_CODBEM := TQB->TQB_CODBEM
(cTRBD)->DT_CCUSTO := TQB->TQB_CCUSTO
(cTRBD)->DT_CENTRA := TQB->TQB_CENTRA
(cTRBD)->DT_LOCALI := TQB->TQB_LOCALI

//CARREGA DESCRICOES
C280BEMLOC(TQB->TQB_TIPOSS)

(cTRBD)->DT_DTABER := TQB->TQB_DTABER
(cTRBD)->DT_HOABER := TQB->TQB_HOABER
(cTRBD)->DT_USUARI := TQB->TQB_USUARI
(cTRBD)->DT_RAMAL  := TQB->TQB_RAMAL
(cTRBD)->DT_SOLUCA := TQB->TQB_SOLUCA

(cTRBD)->DT_SOLUCA := TQB->TQB_SOLUCA
If (cTRBD)->DT_SOLUCA = "A"
   (cTRBD)->DT_DOLUCA := STR0104 //"Aguardando Analise"
ElseIf (cTRBD)->DT_SOLUCA = "D"
   (cTRBD)->DT_DOLUCA := STR0105 //"Classificada"
ElseIf (cTRBD)->DT_SOLUCA = "E"
   (cTRBD)->DT_DOLUCA := STR0106 //"Encerrada"
ElseIf (cTRBD)->DT_SOLUCA = "C"
   (cTRBD)->DT_DOLUCA := STR0107 //"Cancelada"
EndIf

(cTRBD)->DT_FUNEXE := TQB->TQB_FUNEXE
(cTRBD)->DT_NOMFUN := ""

(cTRBD)->DT_DTFECH := TQB->TQB_DTFECH
(cTRBD)->DT_HOFECH := TQB->TQB_HOFECH
(cTRBD)->DT_TEMPO  := TQB->TQB_TEMPO
(cTRBD)->DT_ORDEM  := TQB->TQB_ORDEM
(cTRBD)->DT_OSCUST := nCUSTO

(cTRBD)->DT_CDSERV := TQB->TQB_CDSERV
(cTRBD)->DT_NMSERV := ""

dbSelectArea("TQ3")
dbSetOrder(1)

If dbSeek(xFilial("TQ3")+(cTRBD)->DT_CDSERV)
   (cTRBD)->DT_NMSERV := SubStr(TQ3->TQ3_NMSERV,1,20)
EndIf

(cTRBD)->DT_CDSOLI := TQB->TQB_CDSOLI
(cTRBD)->DT_NMSOLI := UsrRetName((cTRBD)->DT_CDSOLI)

(cTRBD)->DT_CDEXEC := TQB->TQB_CDEXEC

If Empty((cTRBD)->DT_NMEXEC)
   (cTRBD)->DT_NMEXEC := ""

	If lFacilities
	   dbSelectArea("ST1")
	   dbSetOrder(1)

	   If dbSeek(xFilial("ST1")+(cTRBD)->DT_CDEXEC)
	      (cTRBD)->DT_NMEXEC := SubStr(ST1->T1_NOME,1,20)
	   EndIf
	Else
		dbSelectArea("TQ4")
		dbSetOrder(1)

		If dbSeek(xFilial("TQ4")+(cTRBD)->DT_CDEXEC)
			(cTRBD)->DT_NMEXEC := SubStr(TQ4->TQ4_NMEXEC,1,20)
		EndIf
	EndIf
EndIf

(cTRBD)->DT_PRIORI := TQB->TQB_PRIORI

If (cTRBD)->DT_PRIORI = "1"
   (cTRBD)->DT_DRIORI := STR0053 //"Alta"
ElseIf (cTRBD)->DT_PRIORI = "2"
   (cTRBD)->DT_DRIORI := STR0054 //"Média"
ElseIf (cTRBD)->DT_PRIORI = "3"
   (cTRBD)->DT_DRIORI := STR0055 //"Baixa"
EndIf

If lFacilities
	(cTRBD)->DT_PSAP   := TQB->TQB_SATISF
Else
	(cTRBD)->DT_PSAP   := TQB->TQB_PSAP
EndIf

If (cTRBD)->DT_PSAP = "1"
   (cTRBD)->DT_DSAP   := STR0108 //"Ótimo"
ElseIf (cTRBD)->DT_PSAP = "2"
   (cTRBD)->DT_DSAP   := STR0064 //"Bom"
ElseIf (cTRBD)->DT_PSAP = "3"
   (cTRBD)->DT_DSAP   := STR0109 //"Satisfatório"
ElseIf (cTRBD)->DT_PSAP = "4"
   (cTRBD)->DT_DSAP   := STR0066 //"Ruim"
EndIf

If lFacilities
	(cTRBD)->DT_PSAN   := TQB->TQB_SEQQUE
Else
	(cTRBD)->DT_PSAN   := TQB->TQB_PSAN
EndIf

If (cTRBD)->DT_PSAN = "1"
   (cTRBD)->DT_DSAN   := STR0108 //"Ótimo"
ElseIf (cTRBD)->DT_PSAN = "2"
   (cTRBD)->DT_DSAN   := STR0064 //"Bom"
ElseIf (cTRBD)->DT_PSAN = "3"
   (cTRBD)->DT_DSAN   :=  STR0109 //"Satisfatório"
ElseIf (cTRBD)->DT_PSAN = "4"
   (cTRBD)->DT_DSAN   := STR0066 //"Ruim"
EndIf

(cTRBD)->DT_CATRAS := cATRASO
(cTRBD)->DT_DATRAS := cDESATRASO

(cTRBD)->DT_CODMSS := TQB->TQB_CODMSS
(cTRBD)->DT_CODMSO := TQB->TQB_CODMSO

dbSelectArea("TQ3")
dbsetorder(1)

(cTRBD)->DT_CDRESP := ""
(cTRBD)->DT_NMRESP := ""
If Dbseek(xFilial("TQ3")+TQB->TQB_CDSERV)
   (cTRBD)->DT_CDRESP := TQ3->TQ3_CDRESP
   PswOrder(2)
   If PswSeek(TQ3->TQ3_CDRESP)
      (cTRBD)->DT_NMRESP := Substr(PswRet(1)[1][4],1,20)
   EndIf
EndIf
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C280BEMLOC ³ Autor ³ Ricardo Dal Ponte     ³ Data ³12/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorno da descricao do bem/localizacao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C280BEMLOC(cTIPOS)
If cTIPOS = "B"
   If !ExistCpo("ST9",(cTRBD)->DT_CODBEM)
      Return .T.
   Endif

   (cTRBD)->DT_NOMBEM  := NGSEEK("ST9",(cTRBD)->DT_CODBEM,1,"T9_NOME")
   (cTRBD)->DT_NOMCUS  := NGSEEK("CTT",(cTRBD)->DT_CCUSTO,1,"CTT_DESC01")
   (cTRBD)->DT_NOMLOC  := NGSEEK("TPS",(cTRBD)->DT_LOCALI,1,"TPS_NOME")
   (cTRBD)->DT_NOMCTR  := NGSEEK("SHB",(cTRBD)->DT_CENTRA,1,"HB_NOME")
Else
   Dbselectarea("TAF")
   Dbsetorder(7)
   If !Dbseek(xFILIAL("TAF")+"X2"+Substr((cTRBD)->DT_CODBEM,1,3))
      Return .T.
   Endif
   If cTIPOS = "L"
      (cTRBD)->DT_NOMBEM := TAF->TAF_NOMNIV
      (cTRBD)->DT_NOMCUS := NGSEEK("CTT",(cTRBD)->DT_CCUSTO,1,"CTT_DESC01")
      (cTRBD)->DT_NOMCTR := NGSEEK("SHB",(cTRBD)->DT_CENTRA,1,"HB_NOME")
      (cTRBD)->DT_NOMLOC := Space(Len((cTRBD)->DT_LOCALI))
   Endif
Endif
Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C280VFILTR³ Autor ³ Ricardo Dal Ponte     ³ Data ³17/01/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta Tela com componentes para filtras os detalhes         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C280VFILTR()
oTitBemDe1:lVisible := lDetalhar
oTitAte1:lVisible := lDetalhar
oTitBemDe2:lVisible := lDetalhar
oTitAte2:lVisible := lDetalhar
oTitBemDe3:lVisible := lDetalhar
oTitAte3:lVisible := lDetalhar
oTitBemDe4:lVisible := lDetalhar
oTitAte4:lVisible := lDetalhar
oTitBemDe5:lVisible := lDetalhar
oTitAte5:lVisible := lDetalhar
oDeBem:lVisible := lDetalhar
oAteBem:lVisible := lDetalhar

oGrpFold1:lVisible := lDetalhar
oGrpFold2:lVisible := lDetalhar
oGrpFold3:lVisible := lDetalhar
oGrpFold4:lVisible := lDetalhar
oGrpFold5:lVisible := lDetalhar

//oTitCENCUS:lVisible := lDetalhar
oDeCENCUS:lVisible := lDetalhar
oAteCENCUS:lVisible := lDetalhar

//oTiSERV:lVisible := lDetalhar
oDeSERV:lVisible := lDetalhar
oAteSERV:lVisible := lDetalhar

//oTitABE:lVisible := lDetalhar
oABDE:lVisible := lDetalhar
oABATE:lVisible := lDetalhar

//oTitENC:lVisible := lDetalhar
oENCDE:lVisible := lDetalhar
oENCATE:lVisible := lDetalhar

oBtnClear:lVisible := lDetalhar
oBtnFilt:lVisible := lDetalhar

oBtnVSS:lVisible := lDetalhar
If AllTrim(GetNewPar("MV_NGMULOS","N")) <> "S"
	oBtnVOS:lVisible := lDetalhar
EndIf
oBtnIMPR:lVisible := lDetalhar

oTitFil:lVisible := lDetalhar
oOrdem:lVisible := lDetalhar

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} C280VCLARF
Limpa conteudo dos componentes usados para filtrar os dets

@return Nil

@sample
C280VCLARF()

@author Ricardo Dal Ponte
@since 17/01/07
/*/
//---------------------------------------------------------------------
Function C280VCLARF()
	CursorWait()
	cDeBem     := Space(Len(TQB->TQB_CODBEM))
	cAteBem    := Replicate("Z",Len(cDeBem))
	cF3CTTSI3  := IIf(CtbInUse(), "CTT", "SI3")
	cDeCENCUS  := Space(Len(TQB->TQB_CCUSTO))
	cAteCENCUS := Replicate("Z",Len(cDeCENCUS))
	cDeSERV    := Space(Len(TQB->TQB_CDSERV))
	cAteSERV   := Replicate("Z",Len(cDeSERV))
	cABDE  	   := CTOD("  /  /  ")
	cABATE     := CTOD("  /  /  ")
	cENCDE     := CTOD("  /  /  ")
	cENCATE    := CTOD("  /  /  ")

	dbSelectArea(cTRBD)
	dbGoTop()

	If lFILTROS
		C280BRWDE()
	EndIf
	CursorArrow()
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C280FILDET³ Autor ³ Ricardo Dal Ponte     ³ Data ³17/01/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Filtra detalhes com base nos componentes da tela            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C280FILDET()
Local cFILCMP := cFilSEQ

CursorWait()
lFILTROS := .T.

If !Empty(cDeBem)
   cFILCMP += ' .And. (DT_CODBEM >="'+cDeBem +'"   .And. '
   cFILCMP += '        DT_CODBEM <="'+cAteBem +'")'
EndIf

If !Empty(cDeCENCUS)
   cFILCMP += ' .And. (DT_CCUSTO >="'+cDeCENCUS +'"   .And. '
   cFILCMP += '        DT_CCUSTO <="'+cAteCENCUS+'")'
EndIf

If !Empty(cDeSERV)
   cFILCMP += ' .And. (DT_CDSERV >="'+cDeSERV +'"   .And. '
   cFILCMP += '        DT_CDSERV <="'+cAteSERV+'")'
EndIf

If !Empty(cABDE)
   cFILCMP += ' .And. (DTOS(DT_DTABER) >="'+DTOS(cABDE) +'"   .And. '
   cFILCMP += '        DTOS(DT_DTABER) <="'+DTOS(cABATE)+'")'
EndIf

If !Empty(cENCDE)
   cFILCMP += ' .And. (DTOS(DT_DTFECH) >="'+DTOS(cENCDE) +'"   .And. '
   cFILCMP += '        DTOS(DT_DTFECH) <="'+DTOS(cENCATE)+'")'
EndIf

cIndTQB := CriaTrab(Nil, .F.)
nPOS := aSCAN(aORDEM, {|x| x == cPesq})

cIndiceFil := aORDEMF[nPOS]
IndRegua(cTRBD,cIndTQB,cIndiceFil,,cFILCMP,STR0052) //"Selecionando Registros"
aAdd(aCriaTrab,cIndTQB)

dbSelectArea(cTRBD)
dbGoTop()

C280BRWDE()
oMARKDET:oBROWSE:SetFocus()

CursorArrow()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C280CHASS ³ Autor ³ Ricardo Dal Ponte     ³ Data ³18/01/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Abre a Visualizacao da Solicitacao de Servico               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C280CHASS()
Local nRecnoTRBD
Local nSOLICI

dbSelectArea(cTRBD)
nRecnoTRBD := (cTRBD)->(Recno())
nSOLICI := (cTRBD)->DT_SOLICI

If Empty(nSOLICI)
   MsgInfo(STR0110,STR0111) //"Nenhuma Solicitação de Serviço foi selecionada para visualização."###"INFORMAÇÃO"
   Return .T.
EndIf

aRotina := {{STR0112 ,"AxPesqui",0,1},; //"Pesquisar"
            {STR0113,"NGCAD01",0,2}} //"Visualizar"
cCadastro := OemtoAnsi(STR0114) //"Visualização da Solicitação de Serviço"

CursorWait()
Dbselectarea("TQB")
Dbsetorder(1)
Dbseek(xFilial("TQB")+nSOLICI)
NGCAD01('TQB',Recno(),2)
CursorArrow()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C280CHAOS ³ Autor ³ Ricardo Dal Ponte     ³ Data ³18/01/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Abre a Visualizacao da Ordem de Servico                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C280CHAOS()
Local nRecnoTRBD
Local nSOLICI,nORDEM

dbSelectArea(cTRBD)
nRecnoTRBD := (cTRBD)->(Recno())

nSOLICI := (cTRBD)->DT_SOLICI
nORDEM  := (cTRBD)->DT_ORDEM

If Empty(nORDEM)
   MsgInfo(STR0115+nSOLICI+".",STR0111) //"Não existe nenhuma Ordem de Serviço relacionada com a Solicitação de Serviço "###"INFORMAÇÃO"
   Return .T.
EndIf

aRotina := {{STR0112 ,"AxPesqui",0,1},; //"Pesquisar"
            {STR0113,"NGCAD01",0,2}} //"Visualizar"

cCadastro := OemtoAnsi(STR0116) //"Visualização da Ordem de Serviço"
CursorWait()
Dbselectarea("STJ")
Dbsetorder(1)
Dbseek(xFilial("STJ")+nORDEM)
NGCAD01('STJ',Recno(),1)
CursorArrow()
Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C280ALLMAR³ Autor ³ Ricardo Dal Ponte     ³ Data ³18/01/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Marca/Desmarca todos os registros do browse de totais       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C280ALLMAR(cAlias)
CursorWait()

dbSelectArea(cAlias)
nRecno := &(cAlias)->(Recno())
dbGoTop()

While !Eof()
   RecLock(cAlias,.F.)
   If lALLMARK = .T.
      &(cAlias)->(MKBROW) := "N"
   Else
      &(cAlias)->(MKBROW) := "S"
   EndIf
   &(cAlias)->(MsUnLock())
   dbSkip()
End

lALLMARK := !lALLMARK
&(cAlias)->(dbGoto(nRecno))

CursorArrow()
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C280TGRAF ³ Autor ³ Ricardo Dal Ponte     ³ Data ³18/01/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Marca/Desmarca todos os registros do browse de totais       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C280TGRAF()
aTPGRAF := {STR0117, STR0118} //"Barras"###"Pizza"

//  0 - Line Chart
//  1 - Columns and Bar Charts
//  2 - Fit to Curve Chart
//  3 - Mark Point Chart
//  4 - Pizza Chart
//  5 - Area Chart
//  6 - Blocos
//  7 - Mark Point2 Chart
//  8 - Columns and Bar Invert Charts
cTPGRAF := aTPGRAF[1]
cINFOGRAF := ""

DEFINE MSDIALOG oDLGRAF Title STR0119 FROM 0,0 TO 145,270 Of oMainWnd PIXEL COLOR CLR_BLACK,RGB(225,225,225) //"Parâmetros para geração do Gráfico"
	CursorWait()

	@ 06,005 say STR0120 SIZE 300,08 OF oDLGRAF  PIXEL Font oFont14 COLOR CLR_BLUE //"Tipo do gráfico ?"
	@ 14,005 MSCOMBOBOX oTPGRAF VAR cTPGRAF ITEMS aTPGRAF SIZE 70,12 OF oDLGRAF PIXEL ON CHANGE (C280SINFO(.T.))

	@ 30,005 say STR0121 SIZE 300,08 OF oDLGRAF  PIXEL Font oFont14 COLOR CLR_BLUE //"Emitir gráfico de ?"
	C280SINFO(.F.)

	@ 55,80 Button STR0122 Of oDLGRAF Size 50,12 Pixel Action (C280GRAFI(cTPTABLE))  //"&Gerar Gráfico"

	CursorArrow()
Activate MsDialog oDLGRAF CENTERED
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C280SINFO ³ Autor ³ Ricardo Dal Ponte     ³ Data ³19/01/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Seleciona Informacoes que serao impressas no grafico        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C280SINFO(lSINFO)
If cTPANALISE = aTPANALISE[1]
   If cAGRUPA = aAGRUPA[1] .Or. cAGRUPA = aAGRUPA[2] .Or.;
      cAGRUPA = aAGRUPA[3] .Or. cAGRUPA = aAGRUPA[4] .Or.;
      cAGRUPA = aAGRUPA[5]

      If cTPGRAF = aTPGRAF[1] //BARRAS
         aINFOGRAF := {STR0123, STR0124} //"Quantidade de SS"###"Atrasos"
         cINFOGRAF := aINFOGRAF[1]
      EndIf

      If cTPGRAF = aTPGRAF[2] //PIZZA
         aINFOGRAF := {STR0123, STR0125, STR0077, STR0078} //"Quantidade de SS"###"Atraso Médio"###"Maior Atraso"###"Menor Atraso"
         cINFOGRAF := aINFOGRAF[1]
      EndIf
   EndIf
EndIf

If cTPANALISE = aTPANALISE[2]
   If cAGRUPA = aAGRUPA[1] .Or. cAGRUPA = aAGRUPA[2] .Or.;
      cAGRUPA = aAGRUPA[3] .Or. cAGRUPA = aAGRUPA[6]

      If cTPGRAF = aTPGRAF[1] //BARRAS
         aINFOGRAF := {STR0123, STR0072, STR0126} //"Quantidade de SS"###"Atendimento Prazo"###"Atendimento Necessidade"
         cINFOGRAF := aINFOGRAF[1]
      EndIf

      If cTPGRAF = aTPGRAF[2] //PIZZA
         aINFOGRAF := {STR0123,;  //"Quantidade de SS"
                        STR0127,; //"Atendimento Prazo (Ótimo)"
                        STR0128,;  //"Atendimento Prazo (Bom)"
                        STR0129,; //"Atendimento Prazo (Satisfatório)"
                        STR0130,; //"Atendimento Prazo (Ruim)"
                        STR0131,; //"Atendimento Necessidade (Ótimo)"
                        STR0132,; //"Atendimento Necessidade (Bom)"
                        STR0133,; //"Atendimento Necessidade (Satisfatório)"
                        STR0134} //"Atendimento Necessidade (Ruim)"
         cINFOGRAF := aINFOGRAF[1]
      EndIf
   EndIf

   If cAGRUPA = aAGRUPA[4] .Or. cAGRUPA = aAGRUPA[5]
      If cTPGRAF = aTPGRAF[1] //BARRAS
         aINFOGRAF := {STR0123} //"Quantidade de SS"
         cINFOGRAF := aINFOGRAF[1]
      EndIf

      If cTPGRAF = aTPGRAF[2] //PIZZA
         aINFOGRAF := {STR0123} //"Quantidade de SS"
         cINFOGRAF := aINFOGRAF[1]
      EndIf
   EndIf
EndIf

If cTPANALISE = aTPANALISE[3]
   If cAGRUPA = aAGRUPA[1] .Or. cAGRUPA = aAGRUPA[2] .Or.;
      cAGRUPA = aAGRUPA[3] .Or. cAGRUPA = aAGRUPA[4]

      If cTPGRAF = aTPGRAF[1] //BARRAS
         aINFOGRAF := {STR0135, STR0136, STR0137} //"Quantidade de OS"###"Custos"###"Tempos"
         cINFOGRAF := aINFOGRAF[1]
      EndIf

      If cTPGRAF = aTPGRAF[2] //PIZZA
         aINFOGRAF := {STR0135, STR0088,STR0089,STR0090, STR0091, STR0092, STR0093, STR0094, STR0095} //"Quantidade de OS"###"Menor Custo"###"Maior Custo"###"Custo Médio"###"Custo Total"###"Menor Tempo Atend. Hs"###"Maior Tempo Atend. Hs"###"Tempo Atend. Total Hs"###"Tempo Atend. Médio Hs"
         cINFOGRAF := aINFOGRAF[1]
      EndIf
   EndIf
EndIf

If cTPANALISE = aTPANALISE[4]
   If cAGRUPA = aAGRUPA[1] .Or. cAGRUPA = aAGRUPA[2] .Or.;
      cAGRUPA = aAGRUPA[3] .Or. cAGRUPA = aAGRUPA[4]

      If cTPGRAF = aTPGRAF[1] //BARRAS
         aINFOGRAF := {STR0135, STR0136} //"Quantidade de OS"###"Custos"
         cINFOGRAF := aINFOGRAF[1]
      EndIf

      If cTPGRAF = aTPGRAF[2] //PIZZA
         aINFOGRAF := {STR0135, STR0088, STR0089, STR0090, STR0091} //"Quantidade de OS"###"Menor Custo"###"Maior Custo"###"Custo Médio"###"Custo Total"
         cINFOGRAF := aINFOGRAF[1]
      EndIf
   EndIf
EndIf

If cTPANALISE = aTPANALISE[5]
   If cAGRUPA = aAGRUPA[1] .Or. cAGRUPA = aAGRUPA[2] .Or.;
      cAGRUPA = aAGRUPA[3] .Or. cAGRUPA = aAGRUPA[4]

      If cTPGRAF = aTPGRAF[1] //BARRAS
         aINFOGRAF := {STR0123, STR0138, STR0139} //"Quantidade de SS"###"Tempo de Atendimento (Dias)"###"Duração Atendimento (Horas)"
         cINFOGRAF := aINFOGRAF[1]
      EndIf

      If cTPGRAF = aTPGRAF[2] //PIZZA
         aINFOGRAF := {STR0123, STR0140, STR0141, STR0142, STR0143, STR0144, STR0145} //"Quantidade de SS"###"Tempo de Atendimento Médio"###"Maior Tempo Atendimento"###"Menor Tempo Atendimento"###"Duração de Atendimento Médio"###"Maior Duração Atendimento"###"Menor Duração Atendimento"
         cINFOGRAF := aINFOGRAF[1]
      EndIf
   EndIf
EndIf


IF lSINFO = .T.
   oINFOGRAF:hide()
   MsFreeObj(@oINFOGRAF,.t.)
   oINFOGRAF:End()
   oINFOGRAF:=NIL
Endif

@ 38,005 MSCOMBOBOX oINFOGRAF VAR cINFOGRAF ITEMS aINFOGRAF SIZE 125,12 OF oDLGRAF PIXEL ON CHANGE ()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C280GRAFI ³ Autor ³ Ricardo Dal Ponte     ³ Data ³12/01/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Emissao do Grafico                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C280GRAFI(cAlias)
Local i
Local aSerias  := {}
Local cAnalise := cTPANALISE+" "+STR0146+": "+cAGRUPA //"por"
Local cResumo  := STR0147+": "+cINFOGRAF //"Gráfico de"

Local cCHAVE

Local nQuat := 0
Local lConsulta := .T.

If cTPGRAF = aTPGRAF[1] //BARRAS
   cESTYLEGRAF := "1"
ElseIf cTPGRAF = aTPGRAF[2] //PIZZA
   cESTYLEGRAF := "4"
EndIf

If cTPANALISE = aTPANALISE[1]
   If cAGRUPA = aAGRUPA[1]
      cCHAVEGRAF   := "PRIORI"
   ElseIf cAGRUPA = aAGRUPA[2]
      cCHAVEGRAF   := "CDSERV"
   ElseIf cAGRUPA = aAGRUPA[3]
      cCHAVEGRAF   := "ATRASO"
   ElseIf cAGRUPA = aAGRUPA[4]
      cCHAVEGRAF   := "CDEXEC"
   ElseIf cAGRUPA = aAGRUPA[5]
      cCHAVEGRAF   := "CDLOCA"
   Endif

   If cAGRUPA = aAGRUPA[1] .Or. cAGRUPA = aAGRUPA[2] .Or.;
      cAGRUPA = aAGRUPA[3] .Or. cAGRUPA = aAGRUPA[4] .Or.;
      cAGRUPA = aAGRUPA[5]

      If cTPGRAF = aTPGRAF[1] //BARRAS
         If cINFOGRAF = aINFOGRAF[1] //Quantidade de SS
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;  //DESCRICAO
                         {"SSQTD" , "N", 06, 0 }}  //Quantidade de SS
            aSerias  := {STR0123} //"Quantidade de SS"
         EndIf

         If cINFOGRAF = aINFOGRAF[2] //Atrasos
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;   //DESCRICAO
                         {"SSRMET", "N", 10, 0 },; //MENOR ATRASO
                         {"SSRMAT", "N", 10, 0 },; //MAIOR ATRASO
                         {"SSRMED", "N", 10, 2 }}  //ATRASO MEDIO
            aSerias  := {STR0078, STR0077, STR0076} //"Menor Atraso"###"Maior Atraso"###"Atraso Médio"
         EndIf
      EndIf

      If cTPGRAF = aTPGRAF[2] //PIZZA

         If cINFOGRAF = aINFOGRAF[1] //Quantidade de SS
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;   //DESCRICAO
                         {"SSQTD" , "N", 06, 0 }}  //Quantidade de SS

            aSerias  := {STR0123} //"Quantidade de SS"
         EndIf

         If cINFOGRAF = aINFOGRAF[2] //Atraso Medio
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;   //DESCRICAO
                         {"SSRMED", "N", 10, 2 }}  //ATRASO MEDIO
            aSerias  := {STR0076} //"Atraso Médio"
         EndIf

         If cINFOGRAF = aINFOGRAF[3] //Maior Atraso
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;   //DESCRICAO
                         {"SSRMAT", "N", 06, 2 }}  //Maior Atraso
            aSerias  := {STR0077} //"Maior Atraso"
         EndIf

         If cINFOGRAF = aINFOGRAF[4] //Menor Atraso
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;   //DESCRICAO
                         {"SSRMET", "N", 06, 2 }}  //Menor Atraso
            aSerias  := {STR0078} //"Menor Atraso"
         EndIf
      EndIf
   EndIf
EndIf


If cTPANALISE = aTPANALISE[2]
   If cAGRUPA = aAGRUPA[1]
      cCHAVEGRAF   := "PRIORI"
   ElseIf cAGRUPA = aAGRUPA[2]
      cCHAVEGRAF   := "CDSERV"
   ElseIf cAGRUPA = aAGRUPA[3]
      cCHAVEGRAF   := "CDEXEC"
   ElseIf cAGRUPA = aAGRUPA[4]
      cCHAVEGRAF   := "PSAP"
   ElseIf cAGRUPA = aAGRUPA[5]
      cCHAVEGRAF   := "PSAN"
   ElseIf cAGRUPA = aAGRUPA[6]
      cCHAVEGRAF   := "CDLOCA"
   Endif

   If cAGRUPA = aAGRUPA[1] .Or. cAGRUPA = aAGRUPA[2] .Or.;
      cAGRUPA = aAGRUPA[3] .Or. cAGRUPA = aAGRUPA[6]

      If cTPGRAF = aTPGRAF[1] //BARRAS
         If cINFOGRAF = aINFOGRAF[1] //Quantidade de SS
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;  //DESCRICAO
                         {"SSQTD" , "N", 06, 0 }}  //Quantidade de SS
            aSerias  := {STR0123} //"Quantidade de SS"
         EndIf

         If cINFOGRAF = aINFOGRAF[2] //ATENDIMENTO Prazo
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;   //DESCRICAO
                         {"PSOTIM", "N", 10, 0 },; //ATENDIMENTO Prazo Otimo
                         {"PSBOM" , "N", 10, 0 },; //ATENDIMENTO Prazo Bom
                         {"PSSATI", "N", 10, 0 },; //ATENDIMENTO Prazo Satisfatorio
                         {"PSRUIM", "N", 10, 0 }}  //ATENDIMENTO Prazo Ruim

            aSerias  := {STR0108, STR0064, STR0109, STR0066} //"Ótimo"###"Bom"###"Satisfatório"###"Ruim"
         EndIf

         If cINFOGRAF = aINFOGRAF[3] //ATENDIMENTO Necessidade
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;   //DESCRICAO
                         {"NSOTIM", "N", 10, 0 },; //ATENDIMENTO Prazo Otimo
                         {"NSBOM" , "N", 10, 0 },; //ATENDIMENTO Prazo Bom
                         {"NSSATI", "N", 10, 0 },; //ATENDIMENTO Prazo Satisfatorio
                         {"NSRUIM", "N", 10, 0 }}  //ATENDIMENTO Prazo Ruim

            aSerias  := {STR0108, STR0064, STR0109, STR0066} //"Ótimo"###"Bom"###"Satisfatório"###"Ruim"
         EndIf
      EndIf

      If cTPGRAF = aTPGRAF[2] //PIZZA
         If cINFOGRAF = aINFOGRAF[1] //Quantidade de SS
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;  //DESCRICAO
                         {"SSQTD" , "N", 06, 0 }}  //Quantidade de SS
            aSerias  := {STR0123} //"Quantidade de SS"
         EndIf

         If cINFOGRAF = aINFOGRAF[2] //Atendimento Prazo (Ótimo)
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;  //DESCRICAO
                         {"PSOTIM", "N", 06, 0 }}  //Otimo
            aSerias  := {STR0148} //"Atendimento no Prazo (Ótimo)"
         EndIf

         If cINFOGRAF = aINFOGRAF[3] //Atendimento Prazo (Bom)
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;  //DESCRICAO
                         {"PSBOM" , "N", 06, 0 }}  //Bom
            aSerias  := {STR0149} //"Atendimento no Prazo (Bom)"
         EndIf

         If cINFOGRAF = aINFOGRAF[4] //Atendimento Prazo (Satisfatório)
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;  //DESCRICAO
                         {"PSSATI", "N", 06, 0 }}  //Satisfatorio
            aSerias  := {STR0150} //"Atendimento no Prazo (Satisfatório)"
         EndIf

         If cINFOGRAF = aINFOGRAF[5] //Atendimento Prazo (Ruim)
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;  //DESCRICAO
                         {"PSRUIM", "N", 06, 0 }}  //Ruim
            aSerias  := {STR0151} //"Atendimento no Prazo (Ruim)"
         EndIf

         If cINFOGRAF = aINFOGRAF[6] //Atendimento Necessidade (Ótimo)
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;  //DESCRICAO
                         {"NSOTIM", "N", 06, 0 }}  //Otimo
            aSerias  := {STR0152} //"Atendimento da Necessidade (Ótimo)"
         EndIf

         If cINFOGRAF = aINFOGRAF[7] //Atendimento Necessidade (Bom)
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;  //DESCRICAO
                         {"NSBOM" , "N", 06, 0 }}  //Bom
            aSerias  := {STR0153} //"Atendimento da Necessidade (Bom)"
         EndIf

         If cINFOGRAF = aINFOGRAF[8] //Atendimento Necessidade (Satisfatório)
            aDBFGRAF := {{"CODIGO" , "C", 20, 0 },;  //CODIGO
                         {"DESCRI" , "C", 40, 0 },;  //DESCRICAO
                         {"NSSATI" , "N", 06, 0 }}  //Satisfatorio
            aSerias  := {STR0154} //"Atendimento da Necessidade (Satisfatório)"
         EndIf

         If cINFOGRAF = aINFOGRAF[9] //Atendimento Necessidade (Ruim)
            aDBFGRAF := {{"CODIGO" , "C", 20, 0 },;  //CODIGO
                         {"DESCRI" , "C", 40, 0 },;  //DESCRICAO
                         {"NSRUIM" , "N", 06, 0 }}  //Ruim
            aSerias  := {STR0155} //"Atendimento da Necessidade (Ruim)"
         EndIf
      EndIf
   EndIf

   If cAGRUPA = aAGRUPA[4] .Or. cAGRUPA = aAGRUPA[5]
      If cTPGRAF = aTPGRAF[1] //BARRAS
         If cINFOGRAF = aINFOGRAF[1] //Quantidade de SS
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;  //DESCRICAO
                         {"SSQTD" , "N", 06, 0 }}  //Quantidade de SS
            aSerias  := {STR0123} //"Quantidade de SS"
         EndIf
      EndIf

      If cTPGRAF = aTPGRAF[2] //PIZZA
         If cINFOGRAF = aINFOGRAF[1] //Quantidade de SS
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;  //DESCRICAO
                         {"SSQTD" , "N", 06, 0 }}  //Quantidade de SS
            aSerias  := {STR0123} //"Quantidade de SS"
         EndIf
      EndIf
	EndIf
EndIf

If cTPANALISE = aTPANALISE[3]
   If cAGRUPA = aAGRUPA[1]
      cCHAVEGRAF   := "PRIORI"
   ElseIf cAGRUPA = aAGRUPA[2]
      cCHAVEGRAF   := "CDSERV"
   ElseIf cAGRUPA = aAGRUPA[3]
      cCHAVEGRAF   := "CDEXEC"
   ElseIf cAGRUPA = aAGRUPA[4]
      cCHAVEGRAF   := "CDLOCA"
   Endif

   If cAGRUPA = aAGRUPA[1] .Or. cAGRUPA = aAGRUPA[2] .Or.;
      cAGRUPA = aAGRUPA[3] .Or. cAGRUPA = aAGRUPA[4]

      If cTPGRAF = aTPGRAF[1] //BARRAS
         If cINFOGRAF = aINFOGRAF[1] //Quantidade de OS
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;  //DESCRICAO
                         {"OSQTD" , "N", 06, 0 }}  //Quantidade de OS
            aSerias  := {STR0135} //"Quantidade de OS"
         EndIf

         If cINFOGRAF = aINFOGRAF[2] //Custos
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;   //DESCRICAO
                         {"OSMENC", "N", 10, 2 },; //MENOR CUSTO
                         {"OSMAIC", "N", 10, 2 },; //MAIOR CUSTO
                         {"OSCUSM", "N", 10, 2 },; //CUSTO MEDIO
                         {"OSCUST", "N", 10, 2 }} //CUSTO TOTAL

            aSerias  := {STR0088, STR0089, STR0090, STR0091} //"Menor Custo"###"Maior Custo"###"Custo Médio"###"Custo Total"
         EndIf

         If cINFOGRAF = aINFOGRAF[3] //Tempos
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;   //DESCRICAO
                         {"SSHMET", "N", 06, 2 },; //Menor Tempo Atend. Hs
                         {"SSHMAT", "N", 06, 2 },; //Maior Tempo Atend. Hs
                         {"SSHTOT", "N", 06, 2 },; //Tempo Atend. Total Hs
                         {"SSHMED", "N", 06, 2 }}  //Tempo Atend. Médio Hs

            aSerias  := {STR0092, STR0093, STR0094, STR0095} //"Menor Tempo Atend. Hs"###"Maior Tempo Atend. Hs"###"Tempo Atend. Total Hs"###"Tempo Atend. Médio Hs"
         EndIf
      EndIf

      If cTPGRAF = aTPGRAF[2] //PIZZA
         If cINFOGRAF = aINFOGRAF[1] //Quantidade de OS
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;  //DESCRICAO
                         {"OSQTD" , "N", 06, 0 }}  //Quantidade de OS
            aSerias  := {STR0135} //"Quantidade de OS"
         EndIf

         If cINFOGRAF = aINFOGRAF[2] //Menor Custo
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;  //DESCRICAO
                         {"OSMENC", "N", 06, 2 }} //Menor Custo
            aSerias  := {STR0088} //"Menor Custo"
         EndIf

         If cINFOGRAF = aINFOGRAF[3] //Maior Custo
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;  //DESCRICAO
                         {"OSMAIC", "N", 06, 2 }}  //Maior Custo
            aSerias  := {STR0089} //"Maior Custo"
         EndIf

         If cINFOGRAF = aINFOGRAF[4] //Custo Médio
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;  //DESCRICAO
                         {"OSCUSM", "N", 06, 2 }}  //Custo Médio
            aSerias  := {STR0090} //"Custo Médio"
         EndIf

         If cINFOGRAF = aINFOGRAF[5] //Custo Total
            aDBFGRAF := {{"CODIGO" , "C", 20, 0 },;  //CODIGO
                         {"DESCRI" , "C", 40, 0 },;  //DESCRICAO
                         {"OSCUST" , "N", 06, 2 }}  //Custo Total
            aSerias  := {STR0091} //"Custo Total"
         EndIf

         If cINFOGRAF = aINFOGRAF[6] //Menor Tempo Atend. Hs
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;  //DESCRICAO
                         {"SSHMET", "N", 06, 2 }}  //Menor Tempo Atend. Hs
            aSerias  := {STR0092} //"Menor Tempo Atend. Hs"
         EndIf

         If cINFOGRAF = aINFOGRAF[7] //Maior Tempo Atend. Hs
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;  //DESCRICAO
                         {"SSHMAT", "N", 06, 2 }}  //Maior Tempo Atend. Hs
            aSerias  := {STR0093} //"Maior Tempo Atend. Hs"
         EndIf

         If cINFOGRAF = aINFOGRAF[8] //Tempo Atend. Total Hs
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;  //DESCRICAO
                         {"SSHTOT", "N", 06, 2 }}  //Tempo Atend. Total Hs
            aSerias  := {STR0094} //"Tempo Atend. Total Hs"
         EndIf

         If cINFOGRAF = aINFOGRAF[9] //Tempo Atend. Total Hs
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;  //DESCRICAO
                         {"SSHMED", "N", 06, 2 }}  //Tempo Atend. Total Hs
            aSerias  := {STR0094} //"Tempo Atend. Total Hs"
         EndIf
      EndIf
	EndIf
EndIf


If cTPANALISE = aTPANALISE[4]
   If cAGRUPA = aAGRUPA[1]
      cCHAVEGRAF   := "PRIORI"
   ElseIf cAGRUPA = aAGRUPA[2]
      cCHAVEGRAF   := "CDSERV"
   ElseIf cAGRUPA = aAGRUPA[3]
      cCHAVEGRAF   := "CDEXEC"
   ElseIf cAGRUPA = aAGRUPA[4]
      cCHAVEGRAF   := "CDLOCA"
   Endif

   If cAGRUPA = aAGRUPA[1] .Or. cAGRUPA = aAGRUPA[2] .Or.;
      cAGRUPA = aAGRUPA[3] .Or. cAGRUPA = aAGRUPA[4]

      If cTPGRAF = aTPGRAF[1] //BARRAS
         If cINFOGRAF = aINFOGRAF[1] //Quantidade de OS
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;  //DESCRICAO
                         {"OSQTD" , "N", 06, 0 }}  //Quantidade de OS
            aSerias  := {STR0135} //"Quantidade de OS"
         EndIf

         If cINFOGRAF = aINFOGRAF[2] //Custos
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;   //DESCRICAO
                         {"OSMENC", "N", 10, 2 },; //MENOR CUSTO
                         {"OSMAIC", "N", 10, 2 },; //MAIOR CUSTO
                         {"OSCUSM", "N", 10, 2 },; //CUSTO MEDIO
                         {"OSCUST", "N", 10, 2 }} //CUSTO TOTAL

            aSerias  := {STR0088, STR0089, STR0090, STR0091} //"Menor Custo"###"Maior Custo"###"Custo Médio"###"Custo Total"
         EndIf
      EndIf

      If cTPGRAF = aTPGRAF[2] //PIZZA
         If cINFOGRAF = aINFOGRAF[1] //Quantidade de OS
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;  //DESCRICAO
                         {"OSQTD" , "N", 06, 0 }}  //Quantidade de OS
            aSerias  := {STR0135} //"Quantidade de OS"
         EndIf

         If cINFOGRAF = aINFOGRAF[2] //Menor Custo
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;  //DESCRICAO
                         {"OSMENC", "N", 06, 2 }} //Menor Custo
            aSerias  := {STR0088} //"Menor Custo"
         EndIf

         If cINFOGRAF = aINFOGRAF[3] //Maior Custo
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;  //DESCRICAO
                         {"OSMAIC", "N", 06, 2 }}  //Maior Custo
            aSerias  := {STR0089} //"Maior Custo"
         EndIf

         If cINFOGRAF = aINFOGRAF[4] //Custo Médio
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;  //DESCRICAO
                         {"OSCUSM", "N", 06, 2 }}  //Custo Médio
            aSerias  := {STR0090} //"Custo Médio"
         EndIf

         If cINFOGRAF = aINFOGRAF[5] //Custo Total
            aDBFGRAF := {{"CODIGO" , "C", 20, 0 },;  //CODIGO
                         {"DESCRI" , "C", 40, 0 },;  //DESCRICAO
                         {"OSCUST" , "N", 06, 2 }}  //Custo Total
            aSerias  := {STR0091} //"Custo Total"
         EndIf
      EndIf
	EndIf
EndIf

If cTPANALISE = aTPANALISE[5]
   If cAGRUPA = aAGRUPA[1]
      cCHAVEGRAF   := "PRIORI"
   ElseIf cAGRUPA = aAGRUPA[2]
      cCHAVEGRAF   := "CDSERV"
   ElseIf cAGRUPA = aAGRUPA[3]
      cCHAVEGRAF   := "CDEXEC"
   ElseIf cAGRUPA = aAGRUPA[4]
      cCHAVEGRAF   := "CDLOCA"
   Endif

   If cAGRUPA = aAGRUPA[1] .Or. cAGRUPA = aAGRUPA[2] .Or.;
      cAGRUPA = aAGRUPA[3] .Or. cAGRUPA = aAGRUPA[4]

      If cTPGRAF = aTPGRAF[1] //BARRAS
         If cINFOGRAF = aINFOGRAF[1] //Quantidade de SS
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;  //DESCRICAO
                         {"SSQTD" , "N", 06, 0 }}  //Quantidade de SS
            aSerias  := {STR0123} //"Quantidade de SS"
         EndIf

         If cINFOGRAF = aINFOGRAF[2] //"Tempo de Atendimento (Dias)"
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;   //DESCRICAO
                         {"SSRMED", "N", 10, 2 },; //TEMPO ATENDIMENTO MEDIO EM DIAS
                         {"SSRMAT", "N", 06, 2 },; //MAIOR TEMPO ATENDIMENTO EM DIAS
                         {"SSRMET", "N", 06, 2 }} //MENOR TEMPO ATENDIMENTO EM DIAS

            aSerias  := {STR0156, STR0141, STR0142} //"Tempo Médio de Atendimento"###"Maior Tempo Atendimento"###"Menor Tempo Atendimento"
         EndIf

         If cINFOGRAF = aINFOGRAF[3] //"Duração Atendimento (Horas)"
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;   //DESCRICAO
                         {"SSHMED", "N", 06, 2 },;  //TEMPO ATENDIMENTO MEDIO EM HORAS
                         {"SSHMAT", "N", 06, 2 },;  //MAIOR TEMPO ATENDIMENTO EM HORAS
                         {"SSHMET", "N", 06, 2 }}  //MENOR TEMPO ATENDIMENTO EM HORAS

            aSerias  := {STR0157, STR0144, STR0145} //"Duração Média de Atendimento"###"Maior Duração Atendimento"###"Menor Duração Atendimento"
         EndIf
      EndIf

      If cTPGRAF = aTPGRAF[2] //PIZZA
         If cINFOGRAF = aINFOGRAF[1] //Quantidade de SS
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;  //DESCRICAO
                         {"SSQTD" , "N", 06, 0 }}  //Quantidade de SS
            aSerias  := {STR0123} //"Quantidade de SS"
         EndIf

         If cINFOGRAF = aINFOGRAF[2] //Tempo de Atendimento Médio
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;  //DESCRICAO
                         {"SSRMED", "N", 10, 2 }} //TEMPO ATENDIMENTO MEDIO EM DIAS
            aSerias  := {STR0156} //"Tempo Médio de Atendimento"
         EndIf

         If cINFOGRAF = aINFOGRAF[3] //Maior Tempo Atendimento
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;  //DESCRICAO
                         {"SSRMAT", "N", 06, 2 }}  //MAIOR TEMPO ATENDIMENTO EM DIAS
            aSerias  := {STR0158} //"Maior Tempo de Atendimento"
         EndIf

         If cINFOGRAF = aINFOGRAF[4] //Menor Tempo Atendimento
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;  //DESCRICAO
                         {"SSRMET", "N", 06, 2 }}  //MENOR TEMPO ATENDIMENTO EM DIAS
            aSerias  := {STR0159} //"Menor Tempo de Atendimento"
         EndIf

         If cINFOGRAF = aINFOGRAF[5] //Duração de Atendimento Médio
            aDBFGRAF := {{"CODIGO" , "C", 20, 0 },;  //CODIGO
                         {"DESCRI" , "C", 40, 0 },;  //DESCRICAO
                         {"SSHMED" , "N", 06, 2 }}  //TEMPO ATENDIMENTO MEDIO EM HORAS
            aSerias  := {STR0157} //"Duração Média de Atendimento"
         EndIf

         If cINFOGRAF = aINFOGRAF[6] //Maior Duração Atendimento
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;  //DESCRICAO
                         {"SSHMAT", "N", 06, 2 }} //MAIOR TEMPO ATENDIMENTO EM HORAS
            aSerias  := {STR0144} //"Maior Duração Atendimento"
         EndIf

         If cINFOGRAF = aINFOGRAF[7] //Menor Duração Atendimento
            aDBFGRAF := {{"CODIGO", "C", 20, 0 },;  //CODIGO
                         {"DESCRI", "C", 40, 0 },;  //DESCRICAO
                         {"SSHMET", "N", 06, 2 }} //MENOR TEMPO ATENDIMENTO EM HORAS
            aSerias  := {STR0145} //"Menor Duração Atendimento"
         EndIf
      EndIf
	EndIf
EndIf

CursorWait()
//----------------------------------------------
DbselectArea(cAlias)

cIndGraf := {{"CODIGO"}}
oTmpGRAF := NGFwTmpTbl(cTRBGRAF,aDBFGRAF,cIndGraf)

dbSelectArea(cAlias)
nRecno := &(cAlias)->(Recno())
dbGoTop()
While !Eof()
   If &(cAlias)->(MKBROW) = "S"
      (cTRBGRAF)->(DbAppend())
      (cTRBGRAF)->CODIGO := &(cAlias)->(&(cCHAVEGRAF))
      For i := 2 TO Len(aDBFGRAF)
         If aDBFGRAF[i][1] = "SSHMET" .Or. aDBFGRAF[i][1] = "SSHMAT" .Or.;
            aDBFGRAF[i][1] = "SSHTOT" .Or. aDBFGRAF[i][1] = "SSHMED"
            //QUANDO O CAMPO FOR DE HORAS TRSFORMA PARA CENTESIMAL
            (cTRBGRAF)->(FieldPut(i,Round(HtoM(&(cAlias)->(&(aDBFGRAF[i][1])))/60, 2)))
            If ValType((cTRBGRAF)->(FieldPut(i,Round(HtoM(&(cAlias)->(&(aDBFGRAF[i][1])))/60, 2)))) == "N"
            	nQuat := nQuat + (cTRBGRAF)->(FieldPut(i,Round(HtoM(&(cAlias)->(&(aDBFGRAF[i][1])))/60, 2)))
            EndIf
         Else
            (cTRBGRAF)->(FieldPut(i,&(cAlias)->(&(aDBFGRAF[i][1]))))
            If ValType((cTRBGRAF)->(FieldPut(i,&(cAlias)->(&(aDBFGRAF[i][1]))))) == "N"
            	nQuat := nQuat + (cTRBGRAF)->(FieldPut(i,&(cAlias)->(&(aDBFGRAF[i][1]))))
            EndIf
         EndIf
      Next i
   EndIf
   dbSkip()
End
If nQuat == 0
	lConsulta := .F.
EndIf
If !lConsulta
	MsgStop(STR0217,STR0216)//"Não a dados para a impressão do gráfico."##"Atenção"
	NGDELETRB("TRBGRAF",cARQGRAF)
	oTmpGRAF:Delete()
	DbselectArea(cAlias)
	dbGoTop()
	CursorArrow()
	Return .F.
Endif
&(cAlias)->(dbGoto(nRecno))
//----------------------------------------------

// 1§ linha titulo do grafico (janela)
// 2§ linha titulo da direita do grafico
// 3§ linha titulo superior do grafico
// 4§ linha titulo da direita do grafico
// 5§ linha titulo da inferior do grafico
// 6§ linha series do grafico
// 7§ leitura ("A" - Arquivo temporario,"M" - Matriz)
// 8§ alias doa arquivo temporario com os dados /ou
// 9§ matriz com os dados

vCRIGTXT := NGGRAFICO(" "+STR0160,; //"Grafico da Consulta Gerencial da Solicitação de Serviço"
                      " ",;
                      cAnalise,;
                      " ",;
                      cResumo,;
                      aSerias,;
                      "A",;
                      cTRBGRAF,,cESTYLEGRAF)
oTmpGRAF:Delete()

DbselectArea(cAlias)
CursorArrow()
Return .t.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C280IMPRD ³ Autor ³ Ricardo Dal Ponte     ³ Data ³25/01/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao de Relatorio dos Detalhes                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C280IMPRD()
Local aArea := GetArea()
Local ic

Private nRecTRBD := 1

dbSelectArea(cTRBD)
nRecTRBD := (cTRBD)->(Recno())

C280FILDET()

//usuario escolhera o tipo de impressao
If MNTC280IMP()
	RestArea(aArea)
	Return .t.
EndIf

If FindFunction("TRepInUse") .And. TRepInUse()
   //-- Interface de impressao
   oReport:= ReportDef()
   oReport:PrintDialog()
Else
   MNTC280R3()
EndIf

RestArea(aArea)
Return .T.
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
oReport := TReport():New("MNTC280",OemToAnsi(STR0028),"MNT28C",{|oReport| ReportPrint(oReport)},STR0028) //"Consulta Gerencial do Módulo de Solicitação de Serviços"
oReport:ParamReadOnly()
oReport:SetLandscape()  //Default Paisagem
oReport:DisableOrientation()//Trava opcao do ambiente: Retrato/Paisagem

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


oSection1 := TRSection():New(oReport,STR0163 ,{cTRBD, "TQB", "ST9", "TQ3", "TQ4", "STJ"})
TRCell():New(oSection1,"(cTRBD)->DT_SOLICI" ,cTRBD,STR0163  ,"@!" ,08 , /*lPixel*/,/*{|| code-block de impressao }*/) //"SS"
TRCell():New(oSection1,"(cTRBD)->DT_TIPOS"  ,cTRBD,STR0164  ,"@!" ,04 , /*lPixel*/,/*{|| code-block de impressao }*/) //"Tipo"
TRCell():New(oSection1,"(cTRBD)->DT_CODBEM" ,cTRBD,STR0165  ,"@!" ,18 , /*lPixel*/,/*{|| code-block de impressao }*/) //"Bem/Local"
TRCell():New(oSection1,"(cTRBD)->DT_NOMBEM" ,cTRBD,STR0166  ,"@!" ,24 , /*lPixel*/,/*{|| code-block de impressao }*/) //"Nome"
TRCell():New(oSection1,"(cTRBD)->DT_DRIORI" ,cTRBD,STR0067  ,"@!" ,12 , /*lPixel*/,/*{|| code-block de impressao }*/) //"Prioridade"
TRCell():New(oSection1,"(cTRBD)->DT_DTABER" ,cTRBD,STR0167  ,"@!" ,14 , /*lPixel*/,/*{|| code-block de impressao }*/) //"Dt Aber."
TRCell():New(oSection1,"(cTRBD)->DT_HOABER" ,cTRBD,STR0168  ,"@!" ,10 , /*lPixel*/,/*{|| code-block de impressao }*/) //"Hr Aber."
TRCell():New(oSection1,"(cTRBD)->DT_NMSERV" ,cTRBD,STR0169  ,"@!" ,25 , /*lPixel*/,/*{|| code-block de impressao }*/) //"Servico"
TRCell():New(oSection1,"(cTRBD)->DT_NMRESP" ,cTRBD,STR0051  ,"@!" ,25 , /*lPixel*/,/*{|| code-block de impressao }*/) //"Responsavel"
TRCell():New(oSection1,"(cTRBD)->DT_NMEXEC" ,cTRBD,STR0070  ,"@!" ,25 , /*lPixel*/,/*{|| code-block de impressao }*/) //"Executante"
TRCell():New(oSection1,"(cTRBD)->DT_NMSOLI" ,cTRBD,STR0170  ,"@!" ,30 , /*lPixel*/,/*{|| code-block de impressao }*/) //"Solicitante"
TRCell():New(oSection1,"(cTRBD)->DT_ORDEM"  ,cTRBD,STR0171  ,"@!" ,08 , /*lPixel*/,/*{|| code-block de impressao }*/) //"OS"

oCell1 := TRPosition():New(oSection1,"TQB",1,{|| xFilial("TQB") + (cTRBD)->DT_SOLICI})
oCell1 := TRPosition():New(oSection1,"ST9",1,{|| xFilial("ST9") + (cTRBD)->DT_CODBEM})
oCell1 := TRPosition():New(oSection1,"TQ3",1,{|| xFilial("TQ3") + (cTRBD)->DT_CDSERV})
oCell1 := TRPosition():New(oSection1,"TQ4",1,{|| xFilial("TQ4") + (cTRBD)->DT_CDEXEC})
oCell1 := TRPosition():New(oSection1,"STJ",1,{|| xFilial("STJ") + (cTRBD)->DT_ORDEM})
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
Local nRecno := (cTRBD)->(Recno())

Processa({|lEND|},STR0172+"...") //"Processando Arquivo"

dbSelectArea(cTRBD)
nRecno := (cTRBD)->(Recno())
dbGoTop()

oReport:CTitle := STR0173+" - "+STR0174+" "+cTPANALISE //"Consulta Gerencial do Módulo de SS"###"Análise de"

oReport:SetMeter(RecCount())

lPVEZ := .T.
While !Eof() .And. !oReport:Cancel()
	oReport:IncMeter()

   If lPVEZ = .T.
      oSection1:Init()
      lPVEZ := .F.
   Endif

   oSection1:PrintLine()

   dbSKIP()
End

If lPVEZ = .F.
   oSection1:Finish()
EndIf

(cTRBD)->(dbGoto(nRecno))
Return .T.






/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTC280R3 ³ Autor ³ Ricardo Dal Ponte     ³ Data ³12/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function MNTC280R3()
Local WNREL      := "MNTC280"
Local LIMITE     := 132
Local cDESC1     := OemToAnsi(STR0028)//"Consulta Gerencial do Módulo de Solicitação de Serviços"
Local cDESC2     := " "
Local cDESC3     := " "
Local cSTRING    := cTRBD

Private NOMEPROG := "MNTC280"
Private TAMANHO  := "M"
Private aRETURN  := {STR0187,1,STR0188,1,2,1,"",1} //"Zebrado"###"Administracao"
Private TITULO   := cDESC1
Private CPERG    := "MNT28C"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(CPERG,.F.)

WNREL := SetPrint(cSTRING,WNREL,,TITULO,cDESC1,cDESC2,cDESC3,.F.,"")

If nLASTKEY = 27
   Set Filter To
   Return
EndIf
SetDefault(aRETURN,cSTRING)
RptStatus({|lEND| RC280Emp(@lEND,WNREL,TITULO,TAMANHO)},TITULO)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ RC280Emp ³ Autor ³ Ricardo Dal Ponte     ³ Data ³12/02/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do Relat¢rio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTC280                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RC280Emp(lEND,WNREL,TITULO,TAMANHO)
Local nRecno := (cTRBD)->(Recno())
Local cRODATXT := ""
Local nCNTIMPR := 0

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
Private CABEC1 := STR0189 //"SS     Tipo Bem/Local        Nome               Prioridade Dt Aber.   Hr Aber. Servico         Responsavel     Executante      OS"
Private CABEC2 := " "
/*
         1         2         3         4         5         6         7         8         9         100       110       120      130
012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012346789012
************************************************************************************************************************************
SS     Tipo Bem/Local        Nome               Prioridade Dt Aber. Hr Aber. Servico         Responsavel     Executante      OS
************************************************************************************************************************************
xxxxxx xxxx xxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxx xxxxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxxxxxxxxx xxxxxxxxxxxxxxx xxxxxxxxxxxxxxx xxxxxx
xxxxxx xxxx xxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxx xxxxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxxxxxxxxx xxxxxxxxxxxxxxx xxxxxxxxxxxxxxx xxxxxx
*/
Processa({|lEND|},STR0172+"...") //"Processando Arquivo"
dbSelectArea(cTRBD)
nRecno := (cTRBD)->(Recno())
dbGoTop()
SetRegua(LastRec())
While !Eof()
   NgSomali(58)
   @ Li,000 Psay (cTRBD)->DT_SOLICI Picture "@!"
   @ Li,007 Psay (cTRBD)->DT_TIPOS  Picture "@!"
   @ Li,012 Psay (cTRBD)->DT_CODBEM Picture "@!"
   @ Li,029 Psay Substr((cTRBD)->DT_NOMBEM, 1, 17) Picture "@!"
   @ Li,048 Psay (cTRBD)->DT_DRIORI Picture "@!"
   @ Li,059 Psay (cTRBD)->DT_DTABER Picture "99/99/9999"
   @ Li,070 Psay (cTRBD)->DT_HOABER Picture "99:99"
   @ Li,079 Psay Substr((cTRBD)->DT_NMSERV, 1, 15) Picture "@!"
   @ Li,095 Psay Substr((cTRBD)->DT_NMRESP, 1, 15) Picture "@!"
   @ Li,111 Psay Substr((cTRBD)->DT_NMEXEC, 1, 15) Picture "@!"
   @ Li,127 Psay (cTRBD)->DT_ORDEM  Picture "@!"
   dbSKIP()
End

RODA(nCNTIMPR,cRODATXT,TAMANHO)

If aRETURN[5] = 1
   Set Printer To
   DbCommitAll()
   OurSpool(WNREL)
EndIf
MS_FLUSH()

(cTRBD)->(dbGoto(nRecno))
Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNTC280IMP³ Autor ³ Evaldo Cevinscki Jr.  ³ Data ³22/07/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Se for tipo de analise com SS encerrada,abre tela pra esco-³±±
±±³          ³ lher o tipo de impressão, detalhada ou sintetica           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTC280                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNTC280IMP()
Local nTpImp := 1 //"Detalhada"
Local oDlgc280,lGrava,oMainWnd2
Local lRetIMP := .f.

If cTPANALISE = aTPANALISE[2] .Or. cTPANALISE = aTPANALISE[3] .Or. cTPANALISE = aTPANALISE[5]

	Define MsDialog oDlgc280 Title OemToAnsi(STR0191) From 300,120 To 400,370 Of oMainWnd2 PIXEL //"Impressão"

	@ 0.5,1 say OemtoAnsi(STR0192)  //"Informe o tipo de Impressão"
	@ 15,10 RADIO oMainWnd2 VAR nTpImp ITEMS STR0193,STR0194 3D SIZE 80,50 PIXEL  //"Detalhada"###"Sintética"
	Define sButton From 40,050 Type 1 Enable Of oDlgc280 Action (lGrava := .T.,oDlgc280:End())
	Define sButton From 40,080 Type 2 Enable Of oDlgc280 Action (lGrava := .F.,oDlgc280:End())

	Activate MsDialog oDlgc280 Centered

	If lGrava
		If nTpImp == 1
			MNT280CHRE()
			lRetIMP := .t.
		Else
			lRetIMP := .f.
		EndIf
	EndIf
EndIf

Return lRetIMP

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNT120CHRE³ Autor ³ Elisangela Costa      ³ Data ³28/05/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Chamada do relatorio                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MNTR120                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNT280CHRE()

Private oPrint
Private lin := 0
Private oFont08,oFont09,oFont10,oFont11,oFont12,oFont13,oFont14

oFont09	 := TFont():New("Courier New",09,09,,.F.,,,,.F.,.F.)
oFont09B := TFont():New("Courier New",09,09,,.T.,,,,.F.,.F.)
oFont10  := TFont():New("Courier New",10,10,,.T.,,,,.F.,.F.)
oFont11	 := TFont():New("Courier New",11,11,,.F.,,,,.F.,.F.)
oFont11B := TFont():New("Courier New",11,11,,.T.,,,,.F.,.F.)
oFont13	 := TFont():New("Courier New",13,13,,.T.,,,,.F.,.F.)

oPrint	:= TMSPrinter():New(OemToAnsi(STR0195))   //"Solicitacao de Servico"
oPrint:Setup()

C280IMPD(oPrint)

oPrint:Preview()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTR120IMP³ Autor ³ Elisangela Costa      ³ Data ³28/05/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do relatorio                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MNT120CHRE                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function C280IMPD(oPrint)

Local i := 0
Private cEmpresa := SM0->M0_CODIGO
Private cFilial  := SM0->M0_CODFIL

cLogo := NGLOCLOGO()

DbSelectArea(cTRBD)
//nRecno := (cTRBD)->(Recno())
//dbGoTop()
dbGoTo(nRecTRBD)
//While !Eof()
	oPrint:StartPage()

	lin := 100
	oPrint:Box(lin,100,480,2300)

	If File(cLogo)
		oPrint:SayBitMap(120,120,cLogo,370,150)
	EndIf

	oPrint:Line(lin,500,300,500)  //Linha vertical
   oPrint:Say(lin+45,520,"SIGA/MNTC280",oFont11)
   oPrint:Say(lin+45,1440,STR0195+": "+(cTRBD)->DT_SOLICI,oFont13) //"Solicitacao de Servico"

   Somalinha(200)
   oPrint:Line(lin,100,lin,2300) //Linha Hizontal

   oPrint:Say(lin+30,120,STR0196,oFont11)   //"Emissão............:"
   oPrint:Say(lin+40,1880,Transform(ddatabase,"99/99/9999"),oFont11)
   oPrint:Say(lin+40,2155,Transform(Time(),"99:99"),oFont11)

   Somalinha(40)
   oPrint:Say(lin+60,120,STR0197+Transform(Dtoc((cTRBD)->DT_DTABER),"99/99/9999"),oFont11) 	    //"Data Abertura S.S..: "
   oPrint:Say(lin+60,1650,STR0198+Transform((cTRBD)->DT_HOABER,"99:99"),oFont11)   // //"Hora Abertura S.S..: "

   Somalinha(140)
   oPrint:Say(lin+20,1100,STR0170,oFont09B)        //"Solicitante"

   oPrint:Line(lin,100,Lin+70,100) //Linha Vertical
	oPrint:Line(lin,2300,Lin+70,2300)
   Somalinha(70)
   oPrint:Line(lin,100,lin,2300)   //Linha Horizontal

   oPrint:Say(lin+30,120,STR0199+SubStr((cTRBD)->DT_USUARI,1,40),oFont09) //Solicitante // //"Nome..: "
	oPrint:Say(lin+30,1000,STR0200+ AllTrim((cTRBD)->DT_RAMAL),oFont09)   //"Ramal..: "

   oPrint:Line(lin,100,Lin+90,100)  //Linha Vertical
	oPrint:Line(lin,2300,Lin+90,2300)
   Somalinha(90)
   oPrint:Line(lin,100,lin,2300)    //Linha Horizontal

   oPrint:Say(lin+20,1040,STR0201,oFont09B)  // //"Bem / Localização"
   oPrint:Line(lin,100,Lin+70,100)  //Linha Vertical
	oPrint:Line(lin,2300,Lin+70,2300)
   Somalinha(70)
   oPrint:Line(lin,100,lin,2300)    //Linha Horizontal

   //Indentificacao da localizacao ou bem
   oPrint:Say(lin+30,120,STR0202+(cTRBD)->DT_CODBEM,oFont09)  //"Ident...: "

   If (cTRBD)->DT_TIPOSS = "B"
   	oPrint:Say(lin+30,650,NGSEEK('ST9',(cTRBD)->DT_CODBEM,1,'T9_NOME'),oFont09)
   Else
   	DbSelectArea("TAF")
      DbSetOrder(07)
      If DbSeek(xFilial("TAF")+"X"+"2"+(cTRBD)->DT_CODBEM)
      	oPrint:Say(lin+30,650,TAF->TAF_NOMNIV,oFont09)
      EndIf
   EndIf

   //Impressao do tipo
   If (cTRBD)->DT_TIPOSS = "B"
   	oPrint:Say(lin+30,1830,STR0203,oFont09)  //"Tipo.: Bem"
   Else
   	oPrint:Say(lin+30,1830,STR0204,oFont09)  //"Tipo.: Localização"
   EndIf

   //Impressao do Centro de Custo
   oPrint:Say(lin+80,120,STR0205+(cTRBD)->DT_CCUSTO,oFont09)  //"C.Custo.: "
   oPrint:Say(lin+80,760,NGSEEK('CTT',(cTRBD)->DT_CCUSTO,1,'CTT_DESC01'),oFont09)

   //Impressao do Centro de Trabalho
   oPrint:Say(lin+130,120,STR0206+(cTRBD)->DT_CENTRA,oFont09)  //"C.Trab..: "
   oPrint:Say(lin+130,600,NGSEEK('SHB',(cTRBD)->DT_CENTRA,1,'HB_NOME'),oFont09)

   //Impressao da Familia
   oPrint:Say(lin+180,120,STR0207,oFont09)  //"Familia.: "
   If (cTRBD)->DT_TIPOSS = "B"
   	DbSelectArea("ST9")
      DbSetOrder(01)
      If DbSeek(xFilial("ST9")+(cTRBD)->DT_CODBEM)
      	oPrint:Say(lin+180,290,ST9->T9_CODFAMI,oFont09)
         oPrint:Say(lin+180,450,NGSEEK('ST6',ST9->T9_CODFAMI,1,'T6_NOME'),oFont09)
      EndIf
   EndIf

   oPrint:Line(lin,100,Lin+240,100) //Linha vertical
	oPrint:Line(lin,2300,Lin+240,2300)
   Somalinha(240)
   oPrint:Line(lin,100,lin,2300)    //Linha Horizontal


   oPrint:Say(lin+20,900,STR0208,oFont09B)  //"Descrição do Serviço Solicitado"

   oPrint:Line(lin,100,Lin+70,100)  //Linha Vertical
	oPrint:Line(lin,2300,Lin+70,2300)
   Somalinha(70)
   oPrint:Line(lin,100,lin,2300)    //Linha Horizontal

   //Impressao do campo memo
   cMemo   := MSMM((cTRBD)->DT_CODMSS,,,,3)
   nLinhas := MlCount(cMemo,106)
	For i:= 1 To nLinhas
  		oPrint:Say(lin+20,130,MemoLine(cMemo,106,i),oFont09)
  		oPrint:Line(lin,100,Lin+50,100)
 		oPrint:Line(lin,2300,Lin+50,2300)
		SomaLinha()
  	Next i

   oPrint:Line(lin,100,Lin+50,100)  //Linha Vertical
	oPrint:Line(lin,2300,Lin+50,2300)
   SomaLinha()
   oPrint:Line(lin,100,lin,2300)    //Linha Horizontal

   oPrint:Say(lin+20,940,STR0209,oFont09B)   //"Descrição da Solução da S.S"

   oPrint:Line(lin,100,Lin+70,100)  //Linha Vertical
	oPrint:Line(lin,2300,Lin+70,2300)
   Somalinha(70)
   oPrint:Line(lin,100,lin,2300)    //Linha Horizontal

   //Impressao da solucao
   cMemo   := MSMM((cTRBD)->DT_CODMSO,,,,3)
   nLinhas := MlCount(cMemo,106)
   For i := 1 To nLinhas
		oPrint:Say(lin+20,130,MemoLine(cMemo,106,i),oFont09)
	  	oPrint:Line(lin,100,lin+50,100)
		oPrint:Line(lin,2300,lin+50,2300)
		Somalinha()
  	Next i

	oPrint:Line(lin,100,lin+50,100)  //Linha Horizontal
	oPrint:Line(lin,2300,lin+50,2300)
	Somalinha()
   oPrint:Line(lin,100,lin,2300)    //Linha Horizontal

   oPrint:Say(lin+20,120,STR0210+NGSEEK('ST1',(cTRBD)->DT_FUNEXE,1,'T1_NOME'),oFont09)  //"Supervisor..........: "
  	oPrint:Line(lin,100,lin+50,100)
  	oPrint:Line(lin,2300,lin+50,2300)
  	Somalinha()

  	oPrint:Say(lin+20,120,STR0211+Transform(Dtoc((cTRBD)->DT_DTFECH),"99/99/9999")+STR0212+(cTRBD)->DT_HOFECH,oFont09)   //"Data de Encerramento: "###"          Hora de Encerramento: "
  	oPrint:Line(lin,100,lin+50,100)
  	oPrint:Line(lin,2300,lin+50,2300)
  	Somalinha()

  	oPrint:Say(lin+20,120,STR0213+(cTRBD)->DT_TEMPO,oFont09)   //"Tempo da S.S........: "
  	oPrint:Line(lin,100,lin+70,100)
  	oPrint:Line(lin,2300,lin+70,2300)
	Somalinha(70)

	oPrint:Line(lin,100,lin,2300)
   oPrint:EndPage()


  // DbSelectArea(cTRBD)
  // DbSkip()
//End

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SOMALINHA ³ Autor ³Elisangela Costa       ³ Data ³29/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Impressao do Relatorio                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Somalinha(nLinhas)

cLogo := NGLOCLOGO()

If nLinhas == Nil
	Lin += 50
Else
	Lin += nLinhas
EndIf

If lin > 2810
	oPrint:Line(lin,100,lin,2300)
	oPrint:EndPage()
	oPrint:StartPage()

	lin := 100
	oPrint:Box(lin,100,480,2300)

	If File(cLogo)
		oPrint:SayBitMap(120,120,cLogo,370,150)
	EndIf

	oPrint:Line(lin,500,300,500)  //Linha vertical
    oPrint:Say(lin+45,520,"SIGA/MNTC280",oFont11)
    oPrint:Say(lin+45,1440,STR0195+": "+TQB->TQB_SOLICI,oFont13) //"Solicitacao de Servico"

    Somalinha(200)
    oPrint:Line(lin,100,lin,2300) //Linha Hizontal

    oPrint:Say(lin+30,120,STR0196,oFont11)   //"Emissão............:"
    oPrint:Say(lin+40,1880,Transform(ddatabase,"99/99/9999"),oFont11)
    oPrint:Say(lin+40,2155,Transform(Time(),"99:99"),oFont11)

    Somalinha(40)
    oPrint:Say(lin+60,120,STR0197+Transform(Dtoc(TQB->TQB_DTABER),"99/99/9999"),oFont11)  //"Data Abertura S.S..: "
    oPrint:Say(lin+60,1650,STR0198+Transform(TQB->TQB_HOABER,"99:99"),oFont11)             //"Hora Abertura S.S..: "
    Somalinha(140)

EndIf

Return .T.
