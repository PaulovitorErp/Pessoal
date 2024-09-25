#INCLUDE "MNTR415.ch"
#include "Protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MNTR415  ³ Autor ³ Rafael Diogo Richter  ³ Data ³12/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio de Banco de Pontos dos Motoristas                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tabelas   ³SM0 - Filiais                                               ³±±
±±³          ³TSH - Infracoes de Transito                                 ³±±
±±³          ³DA4 - Motoristas                                            ³±±
±±³          ³TRX - Multas                                                ³±±
±±³          ³TRW - Grupo de Filiais                                      ³±±
±±³          ³TSL - Cadastro de Filiais Martins                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaMNT                                                    ³±±
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
Function MNTR415()

	Local   WNREL     := "MNTR415"
	Local   cDESC1    := STR0001 //"O relatório apresentará o banco de pontos dos Motoristas"
	Local   cDESC2    := ""
	Local   cDESC3    := ""
	Local   cSTRING   := "TRX"
	Private cCadastro := OemtoAnsi(STR0002) //"Banco de Pontos dos Motoristas"
	Private cPerg     := "MNR415"
	Private aPerg     := {}
	Private NOMEPROG  := "MNTR415"
	Private TAMANHO   := "M"
	Private aRETURN   := {STR0003,1,STR0004,1,2,1,"",1} //"Zebrado"###"Administracao"
	Private TITULO    := STR0002 //"Banco de Pontos dos Motoristas"
	Private nTIPO     := 0
	Private nLASTKEY  := 0
	Private aVETINR   := {}
	Private lGera     := .t.
	Private CABEC1,CABEC2
	Private lFilial,lHub

	Pergunte(cPERG,.F.)

	//Envia controle para a funcao SETPRINT 

	WNREL:=SetPrint(cSTRING,WNREL,cPERG,TITULO,cDESC1,cDESC2,cDESC3,.F.,"")
	If nLASTKEY = 27
		Set Filter To
		DbSelectArea("TRX")
		Return
	EndIf
	SetDefault(aReturn,cSTRING)
	Processa({|lEND| MNTR415IMP(@lEND,WNREL,TITULO,TAMANHO)},STR0011) //"Processando Registros..."
	Dbselectarea("TRX")

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |MNT415IMP | Autor ³ Rafael Diogo Richter  ³ Data ³12/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Chamada do Relat¢rio                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR415                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTR415IMP(lEND,WNREL,TITULO,TAMANHO)

	Local cCodFil := ""
	Local nP0Fil := 0, nP3Fil := 0, nP4Fil := 0, nP5Fil := 0, nP7Fil := 0, nPTFil := 0
	Local nISimFil := 0, nINaoFil := 0, nISerFil := 0, nITotFil := 0
	Local nP0GFil := 0, nP3GFil := 0, nP4GFil := 0, nP5GFil := 0, nP7GFil := 0, nPTGFil := 0, nISimGFil := 0
	Local nINaoGFil := 0, nISerGFil := 0, nITotGFil := 0
	Local nP0Hub := 0, nP3Hub := 0, nP4Hub := 0, nP5Hub := 0, nP7Hub := 0, nPTHub := 0, nISimHub := 0, nINaoHub := 0
	Local nISerHub := 0, nITotHub := 0
	Local lFirst, lFirstH
	Local oTempTable		//Tabela Temporaria
	Private li := 80 ,m_pag := 1
	Private cRODATXT := ""
	Private nCNTIMPR := 0
	Private cTRB	 := GetNextAlias()

	aDBF :=	{	{ 'MULTA' , "C", FWTamSX3( 'TRX_MULTA' )[1], 0 },;
				{ 'CODHUB', "C", 02                        , 0 },;
				{ 'DESHUB', 'C', 25                        , 0 },;
				{ 'CODFIL', 'C', FwSizeFilial()            , 0 },;
				{ 'DESFIL', 'C', 25                        , 0 },;
				{ 'CODMO' , 'C', 06                        , 0 },;
				{ 'CODINF', 'C', 06                        , 0 },;
				{ 'CODP0' , 'N', 03                        , 0 },;
				{ 'CODP3' , 'N', 03                        , 0 },;
				{ 'CODP4' , 'N', 03                        , 0 },;
				{ 'CODP5' , 'N', 03                        , 0 },;
				{ 'CODP7' , 'N', 03                        , 0 },;
				{ 'CODPTO', 'N', 03                        , 0 },;
				{ 'INFSIM', 'N', 03                        , 0 },;
				{ 'INFNAO', 'N', 03                        , 0 },;
				{ 'INFSER', 'N', 03                        , 0 },;
				{ 'INFTOT', 'N', 03                        , 0 } }

	//Intancia classe FWTemporaryTable
	oTempTable  := FWTemporaryTable():New( cTRB, aDBF )	
	//Cria indices
	oTempTable:AddIndex( "Ind01" , {"CODHUB","CODFIL","CODMO","CODINF"}  )
	oTempTable:AddIndex( "Ind02" , {"CODFIL","CODMO","CODINF"} )
	//Cria a tabela temporaria
	oTempTable:Create()

	MsgRun(OemToAnsi(STR0013),OemToAnsi(STR0014),{|| MNTR415TMP()}) //"Processando Arquivo..."###"Aguarde"

	If !lGera
		oTempTable:Delete()//Deleta Tabela Temporaria
		Return .F.
	Endif

	/* 
	0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7
	0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
	****************************************************************************************************************************************************************************
	Banco de Pontos                                                 Pontuação              Tot.Pontos   Infrator Identificado?
	****************************************************************************************************************************************************************************
	Filial                  Mot.    Nome                         0    3    4    5    7     Qtde         Sim  Não  Será       Tot.Inf.
	****************************************************************************************************************************************************************************
	xxxxxxxxxxxxxxxxxxxxxxxxx  xxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxx  999  999  999  999  999      999         999  999   999            999
	xxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxx  999  999  999  999  999      999         999  999   999            999
	xxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxx  999  999  999  999  999      999         999  999   999            999

	Total por Filial          9999 9999 9999 9999 9999     9999        9999 9999  9999           9999

	xxxxxxxxxxxxxxxxxxxxxxxxx  xxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxx  999  999  999  999  999      999         999  999   999            999
	xxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxx  999  999  999  999  999      999         999  999   999            999
	xxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxx  999  999  999  999  999      999         999  999   999            999

	Total por Filial          9999 9999 9999 9999 9999     9999        9999 9999  9999           9999      
	Total Geral               9999 9999 9999 9999 9999     9999        9999 9999  9999           9999
	/*/                                                

	CABEC1 := STR0015 //"Banco de Pontos                                                 Pontuação              Tot.Pontos   Infrator Identificado?"

	If (lFilial == .T. .And. lHub == .F.) .Or. (lFilial == .F. .And. lHub == .F.)
		CABEC2 := STR0016 //"   Filial                  Mot.    Nome                         0    3    4    5    7     Qtde         Sim  Não  Será       Tot.Inf."
	ElseIf lFilial == .F. .And. lHub == .T.
		CABEC2 := STR0017 //"   Grupo de Filial         Mot.    Nome                         0    3    4    5    7     Qtde         Sim  Não  Será       Tot.Inf."
	EndIf

	cHub := ""
	lFirst := .T.
	lFirstH := .T.
	dbSelectArea(cTRB)
	If lFilial == .F. .And. lHub == .T.
		dbSetOrder(1)
	ElseIf (lFilial == .T. .And. lHub == .F.) .Or. (lFilial == .F. .And. lHub == .F.)
		dbSetOrder(2)
	EndIf
	dbGoTop()
	ProcRegua(Reccount())
	While !Eof()
		IncProc()
		If cCodFil <> (cTRB)->CODFIL
			If lFirst
				NgSomaLi(58)
				lFirst := .F.
			Else
				NgSomaLi(58)
				NgSomaLi(58)
				@ Li,035		Psay STR0018 //"Total por Filial"

				@ Li,061		Psay nP0Fil 	Picture "@R 9999"
				@ Li,066		Psay nP3Fil 	Picture "@R 9999"
				@ Li,071		Psay nP4Fil 	Picture "@R 9999"
				@ Li,076		Psay nP5Fil 	Picture "@R 9999"
				@ Li,081		Psay nP7Fil 	Picture "@R 9999"
				@ Li,090		Psay nPTFil 	Picture "@R 9999"

				@ Li,102		Psay nISimFil 	Picture "@R 9999"
				@ Li,107		Psay nINaoFil 	Picture "@R 9999"
				//@ Li,113		Psay nISerFil 	Picture "@R 9999"
				@ Li,128		Psay nITotFil 	Picture "@R 9999"
				If lHub == .F.
					NgSomaLi(58)			
				Endif
				If lFilial == .F. .And. lHub == .T.
					If cHub <> (cTRB)->CODHUB .AND. !lFirstH
						NgSomaLi(58)
						@ Li,035		Psay STR0019 //"Total por Grupo de Filial"

						@ Li,061		Psay nP0Hub 	Picture "@E 9999"
						@ Li,066		Psay nP3Hub 	Picture "@R 9999"
						@ Li,071		Psay nP4Hub 	Picture "@R 9999"
						@ Li,076		Psay nP5Hub 	Picture "@R 9999"
						@ Li,081		Psay nP7Hub 	Picture "@R 9999"
						@ Li,090		Psay nPTHub 	Picture "@R 9999"

						@ Li,102		Psay nISimHub 	Picture "@R 9999"
						@ Li,107		Psay nINaoHub 	Picture "@R 9999"
						//@ Li,113		Psay nISerHub 	Picture "@R 9999"
						@ Li,128		Psay nITotHub 	Picture "@R 9999"
						NgSomaLi(58)
						NgSomaLi(58)
					Else
						NgSomaLi(58)
						NgSomaLi(58)
					Endif
				EndIf
			EndIf

			If lFilial == .F. .And. lHub == .T.
				If cHub <> (cTRB)->CODHUB
					If lFirstH
						lFirstH := .F.
					EndIf
					@ Li,000		Psay SubStr((cTRB)->DESHUB,1,25)
					NgSomaLi(58)
					cHub := (cTRB)->CODHUB
					nP0Hub := 0
					nP3Hub := 0
					nP4Hub := 0
					nP5Hub := 0
					nP7Hub := 0
					nPTHub := 0
					nISimHub := 0
					nINaoHub := 0
					nISerHub := 0
					nITotHub := 0
				EndIf
			EndIf

			If lFilial == .F. .And. lHub == .T.
				@ Li,000		Psay STR0020+SubStr((cTRB)->DESFIL,1,17) //"Filial: "
			Else
				NgSomaLi(58)
				@ Li,000		Psay SubStr((cTRB)->DESFIL,1,25)
			EndIf
			cCodFil := (cTRB)->CODFIL
			nP0Fil := 0
			nP3Fil := 0
			nP4Fil := 0
			nP5Fil := 0
			nP7Fil := 0
			nPTFil := 0
			nISimFil := 0
			nINaoFil := 0
			nISerFil := 0
			nITotFil := 0
		Else
			NgSomaLi(58)
		EndIf

		@ Li,027		Psay (cTRB)->CODMO

		dbSelectArea("DA4")
		dbSetOrder(1)
		dbSeek(xFilial("DA4")+(cTRB)->CODMO)
		@ Li,035		Psay SubStr(DA4->DA4_NOME,1,25)

		@ Li,062		Psay (cTRB)->CODP0 	Picture "@R 999"
		@ Li,067		Psay (cTRB)->CODP3 	Picture "@R 999"
		@ Li,072		Psay (cTRB)->CODP4 	Picture "@R 999"
		@ Li,077		Psay (cTRB)->CODP5 	Picture "@R 999"
		@ Li,082		Psay (cTRB)->CODP7	    Picture "@R 999"
		@ Li,091		Psay (cTRB)->CODPTO	Picture "@R 999"

		@ Li,103		Psay (cTRB)->INFSIM	Picture "@R 999"
		@ Li,108		Psay (cTRB)->INFNAO	Picture "@R 999"
		//@ Li,114		Psay (cTRB)->INFSER	Picture "@R 999"
		@ Li,129		Psay (cTRB)->INFTOT	Picture "@R 999"

		If lFilial == .F. .And. lHub == .T.
			//Totais por Grupo de Filial
			nP0Hub += (cTRB)->CODP0
			nP3Hub += (cTRB)->CODP3
			nP4Hub += (cTRB)->CODP4
			nP5Hub += (cTRB)->CODP5
			nP7Hub += (cTRB)->CODP7
			nPTHub += (cTRB)->CODPTO
			nISimHub += (cTRB)->INFSIM
			nINaoHub += (cTRB)->INFNAO
			//		nISerHub += (cTRB)->INFSER
			nITotHub += (cTRB)->INFTOT
		EndIf

		//Totais por filial
		nP0Fil += (cTRB)->CODP0
		nP3Fil += (cTRB)->CODP3
		nP4Fil += (cTRB)->CODP4
		nP5Fil += (cTRB)->CODP5
		nP7Fil += (cTRB)->CODP7
		nPTFil += (cTRB)->CODPTO
		nISimFil += (cTRB)->INFSIM
		nINaoFil += (cTRB)->INFNAO
		//	nISerFil += (cTRB)->INFSER
		nITotFil += (cTRB)->INFTOT

		//Total Geral
		nP0GFil += (cTRB)->CODP0
		nP3GFil += (cTRB)->CODP3
		nP4GFil += (cTRB)->CODP4
		nP5GFil += (cTRB)->CODP5
		nP7GFil += (cTRB)->CODP7
		nPTGFil += (cTRB)->CODPTO
		nISimGFil += (cTRB)->INFSIM
		nINaoGFil += (cTRB)->INFNAO
		//	nISerGFil += (cTRB)->INFSER
		nITotGFil += (cTRB)->INFTOT

		cHub := (cTRB)->CODHUB
		dbSelectArea(cTRB)
		dbSetOrder(1)
		dbSkip()
	End

	NgSomaLi(58)
	NgSomaLi(58)

	@ Li,035		Psay STR0018 //"Total por Filial"

	@ Li,061		Psay nP0Fil 	Picture "@E 9999"
	@ Li,066		Psay nP3Fil 	Picture "@R 9999"
	@ Li,071		Psay nP4Fil 	Picture "@R 9999"
	@ Li,076		Psay nP5Fil 	Picture "@R 9999"
	@ Li,081		Psay nP7Fil 	Picture "@R 9999"
	@ Li,090		Psay nPTFil 	Picture "@R 9999"

	@ Li,102		Psay nISimFil 	Picture "@R 9999"
	@ Li,107		Psay nINaoFil 	Picture "@R 9999"
	//@ Li,113		Psay nISerFil 	Picture "@R 9999"
	@ Li,128		Psay nITotFil 	Picture "@R 9999"

	If lFilial == .F. .And. lHub == .T.
		NgSomaLi(58)
		@ Li,035		Psay STR0019 //"Total por Grupo de Filial"

		@ Li,061		Psay nP0Hub 	Picture "@E 9999"
		@ Li,066		Psay nP3Hub 	Picture "@R 9999"
		@ Li,071		Psay nP4Hub 	Picture "@R 9999"
		@ Li,076		Psay nP5Hub 	Picture "@R 9999"
		@ Li,081		Psay nP7Hub 	Picture "@R 9999"
		@ Li,090		Psay nPTHub 	Picture "@R 9999"

		@ Li,102		Psay nISimHub 	Picture "@R 9999"
		@ Li,107		Psay nINaoHub 	Picture "@R 9999"
		//@ Li,113		Psay nISerHub 	Picture "@R 9999"
		@ Li,128		Psay nITotHub 	Picture "@R 9999"
	EndIf

	NgSomaLi(58)
	@ Li,035		Psay STR0021 //"Total Geral"

	@ Li,061		Psay nP0GFil 	Picture "@R 9999"
	@ Li,066		Psay nP3GFil 	Picture "@R 9999"
	@ Li,071		Psay nP4GFil 	Picture "@R 9999"
	@ Li,076		Psay nP5GFil 	Picture "@R 9999"
	@ Li,081		Psay nP7GFil 	Picture "@R 9999"
	@ Li,090		Psay nPTGFil 	Picture "@R 9999"

	@ Li,102		Psay nISimGFil 	Picture "@R 9999"
	@ Li,107		Psay nINaoGFil 	Picture "@R 9999"
	//@ Li,113		Psay nISerGFil 	Picture "@R 9999"
	@ Li,128		Psay nITotGFil 	Picture "@R 9999"

	oTempTable:Delete()//Deleta Tabela Temporaria

	RODA(nCNTIMPR,cRODATXT,TAMANHO)

	//Devolve a condicao original do arquivo principal
	RetIndex("TRX")
	Set Filter To
	Set Device To Screen
	If aReturn[5] == 1
		Set Printer To
		dbCommitAll()
		OurSpool(WNREL)
	EndIf
	MS_FLUSH()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNT415FL  ³ Autor ³Rafael Diogo Richter   ³ Data ³12/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida o parametro filial                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR415                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNT415FL(nOpc)
	Local cVERFL

	cVERFL := Mv_Par03

	If (Empty(mv_par03) .And. mv_par04 = 'ZZZZZZZZ') .OR. (Mv_PAR04 = 'ZZZZZZZZ')
		MV_PAR05 := "  "
		MV_PAR06 := "  "
		Return .T.
	Else
		If nOpc == 1
			lRet := IIf(Empty(Mv_Par03),.t.,ExistCpo('SM0',SM0->M0_CODIGO+Mv_par03))
			If !lRet
				Return .F.
			EndIf
			If !Empty(MV_PAR03)
				MV_PAR05 := "  "
				MV_PAR06 := "  "
			EndIf
		EndIf

		If nOpc == 2
			If !Empty(Mv_PAR04)
				lRet := IIF(ATECODIGO('SM0',SM0->M0_CODIGO+Mv_par03,SM0->M0_CODIGO+Mv_Par04,02),.T.,.F.)
				If !lRet
					Return .F.
				EndIf
				If !Empty(MV_PAR04)
					MV_PAR05 := "  "
					MV_PAR06 := "  "
				EndIf
			ElseIf Empty(MV_PAR05) .AND. Empty(MV_PAR06)
				NaoVazio()
				Return .F.		
			Endif
		EndIf
	EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |MNTR415TMP| Autor ³ Rafael Diogo Richter  ³ Data ³12/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Geracao do arquivo temporario                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR415                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTR415TMP()
	Local cAliasQry := ""
	Local	cPar07
	Local	cPar08

	If mv_par07 = 1
		cPar07 := '0'
	ElseIf mv_par07 = 2
		cPar07 := '3'
	ElseIf mv_par07 = 3
		cPar07 := '4'
	ElseIf mv_par07 = 4
		cPar07 := '5'
	ElseIf mv_par07 = 5
		cPar07 := '7'
	Endif

	If mv_par08 = 1
		cPar08 := '0'
	ElseIf mv_par08 = 2
		cPar08 := '3'
	ElseIf mv_par08 = 3
		cPar08 := '4'
	ElseIf mv_par08 = 4
		cPar08 := '5'
	ElseIf mv_par08 = 5
		cPar08 := '7'
	Endif

	cAliasQry := GetNextAlias()

	If Empty(MV_PAR04) .And. !Empty(MV_PAR06)
		lFilial := .F.
		lHub := .T.
	ElseIf Empty(MV_PAR06) .And. !Empty(MV_PAR04)
		lFilial := .T.
		lHub := .F.
	ElseIf Empty(MV_PAR04) .And. Empty(MV_PAR06)
		lFilial := .F.
		lHub := .F.
	EndIf

	//MakeSqlExpr(cPerg)

	If (lFilial == .T. .And. lHub == .F.) .Or. (lFilial == .F. .And. lHub == .F.)
		If lFilial == .T. .And. lHub == .F.
			BeginSql Alias cAliasQry
			SELECT TRX_FILIAL, TRX_CODMO, TRX_CODINF, TRX_MULTA, TRX_INFRAC
			FROM %Table:TRX% TRX
			JOIN %Table:TSH% TSH ON TSH.TSH_CODINF = TRX.TRX_CODINF
			AND TSH.TSH_RESPON = "1"
			AND TSH.TSH_PONTOS  BETWEEN %Exp:cPar07% AND %Exp:cPar08%
			AND TSH.%NotDel%
			WHERE TRX.TRX_FILIAL BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
			AND TRX.TRX_DTINFR BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
			AND TRX.%NotDel%
			ORDER BY TRX.TRX_FILIAL, TRX.TRX_CODMO
			EndSql
		Else
			BeginSql Alias cAliasQry
			SELECT TRX_FILIAL, TRX_CODMO, TRX_CODINF, TRX_MULTA, TRX_INFRAC
			FROM %Table:TRX% TRX
			JOIN %Table:TSH% TSH ON TSH.TSH_CODINF = TRX.TRX_CODINF
			AND TSH.TSH_RESPON = "1"
			AND TSH.TSH_PONTOS  BETWEEN %Exp:cPar07% AND %Exp:cPar08%
			AND TSH.%NotDel%			
			WHERE TRX.TRX_FILIAL BETWEEN %Exp:mv_par03% AND 'ZZZZZZZZ'
			AND TRX.TRX_DTINFR BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
			AND TRX.%NotDel%
			ORDER BY TRX.TRX_FILIAL, TRX.TRX_CODMO
			EndSql
		EndIf
		dbSelectArea(cAliasQry)
		dbGoTop()

		If Eof()
			MsgInfo(STR0022,STR0023) //"Não existem dados para montar o relatório!"###"ATENÇÃO"
			(cAliasQry)->(dbCloseArea())
			lGera := .f.
			Return
		Endif

		While (cAliasQry)->( !Eof() )
			dbSelectArea(cTRB)
			dbSetOrder(2)
			If !dbSeek((cAliasQry)->TRX_FILIAL+(cAliasQry)->TRX_CODMO)
				RecLock((cTRB), .T.)
				(cTRB)->MULTA	:= (cAliasQry)->TRX_MULTA
				(cTRB)->CODFIL	:= (cAliasQry)->TRX_FILIAL
				dbSelectArea("SM0")
				SM0->(dbSetOrder(1))
				If MsSeek(SM0->M0_CODIGO+(cAliasQry)->TRX_FILIAL)
					(cTRB)->DESFIL	:= SM0->M0_FILIAL
				EndIf
				(cTRB)->CODMO	:= (cAliasQry)->TRX_CODMO
				(cTRB)->CODINF	:= (cAliasQry)->TRX_CODINF
			Else
				RecLock((cTRB), .F.)
			EndIf
			dbSelectArea("TSH")
			dbSetOrder(1)
			//If dbSeek((cAliasQry)->TRX_FILIAL+(cAliasQry)->TRX_CODINF)
			If dbSeek(Xfilial("TSH")+(cAliasQry)->TRX_CODINF)
				If TSH->TSH_PONTOS == "0"
					(cTRB)->CODP0 := (cTRB)->CODP0+1
					(cTRB)->CODPTO	:= (cTRB)->CODPTO + Val(TSH->TSH_PONTOS)
				ElseIf TSH->TSH_PONTOS == "3"
					(cTRB)->CODP3 := (cTRB)->CODP3+1
					(cTRB)->CODPTO	:= (cTRB)->CODPTO + Val(TSH->TSH_PONTOS)
				ElseIf TSH->TSH_PONTOS == "4"
					(cTRB)->CODP4 := (cTRB)->CODP4+1
					(cTRB)->CODPTO	:= (cTRB)->CODPTO + Val(TSH->TSH_PONTOS)
				ElseIf TSH->TSH_PONTOS == "5"
					(cTRB)->CODP5 := (cTRB)->CODP5+1
					(cTRB)->CODPTO	:= (cTRB)->CODPTO + Val(TSH->TSH_PONTOS)
				ElseIf TSH->TSH_PONTOS == "7"
					(cTRB)->CODP7 := (cTRB)->CODP7+1
					(cTRB)->CODPTO	:= (cTRB)->CODPTO + Val(TSH->TSH_PONTOS)
				EndIf
			EndIf
			If (cAliasQry)->TRX_INFRAC == "1"
				(cTRB)->INFSIM := (cTRB)->INFSIM+1
				(cTRB)->INFTOT := (cTRB)->INFTOT+1
			ElseIf (cAliasQry)->TRX_INFRAC == "2"
				(cTRB)->INFNAO := (cTRB)->INFNAO+1
				(cTRB)->INFTOT := (cTRB)->INFTOT+1
			ElseIf (cAliasQry)->TRX_INFRAC == "3"
				//(cTRB)->INFSER := (cTRB)->INFSER+1
				(cTRB)->INFTOT := (cTRB)->INFTOT+1
			EndIf
			MsUnLock(cTRB)
			(cAliasQry)->(dbSkip())
		End
	ElseIf lFilial == .F. .And. lHub == .T.
		BeginSql Alias cAliasQry
		SELECT TRX_FILIAL, TRX_CODMO, TRX_CODINF, TRX_MULTA, TRX_INFRAC
		FROM %Table:TRX% TRX
		JOIN %Table:TSH% TSH ON TSH.TSH_CODINF = TRX.TRX_CODINF
		AND TSH.TSH_RESPON = "1"
		AND TSH.TSH_PONTOS  BETWEEN %Exp:cPar07% AND %Exp:cPar08%
		AND TSH.%NotDel%
		WHERE TRX.TRX_FILIAL BETWEEN %Exp:mv_par03% AND 'ZZ'
		AND TRX.TRX_DTINFR BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
		AND TRX.%NotDel%
		ORDER BY TRX.TRX_FILIAL, TRX.TRX_CODMO
		EndSql

		dbSelectArea(cAliasQry)
		dbGoTop()

		If Eof()
			MsgInfo(STR0022,STR0023) //"Não existem dados para montar o relatório!"###"ATENÇÃO"
			(cAliasQry)->(dbCloseArea())
			lGera := .F.
			Return
		Endif

		While (cAliasQry)->( !Eof() )
			dbSelectArea(cTRB)
			dbSetOrder(1)
			If !dbSeek((cAliasQry)->TRX_FILIAL+(cAliasQry)->TRX_CODMO)
				RecLock((cTRB), .T.)
				(cTRB)->MULTA	:= (cAliasQry)->TRX_MULTA
				(cTRB)->CODFIL	:= (cAliasQry)->TRX_FILIAL
				dbSelectArea("SM0")
				SM0->(dbSetOrder(1))
				If MsSeek(SM0->M0_CODIGO+(cAliasQry)->TRX_FILIAL)
					(cTRB)->DESFIL	:= SM0->M0_FILIAL
				EndIf
				(cTRB)->CODMO	:= (cAliasQry)->TRX_CODMO
				(cTRB)->CODINF	:= (cAliasQry)->TRX_CODINF
			Else
				RecLock((cTRB), .F.)
			EndIf
			dbSelectArea("TSH")
			dbSetOrder(1)
			//If dbSeek((cAliasQry)->TRX_FILIAL+(cAliasQry)->TRX_CODINF)
			If dbSeek(Xfilial("TSH")+(cAliasQry)->TRX_CODINF)
				If TSH->TSH_PONTOS == "0"
					(cTRB)->CODP0 := (cTRB)->CODP0+1
					(cTRB)->CODPTO	:= (cTRB)->CODPTO + Val(TSH->TSH_PONTOS)
				ElseIf TSH->TSH_PONTOS == "3"
					(cTRB)->CODP3 := (cTRB)->CODP3+1
					(cTRB)->CODPTO	:= (cTRB)->CODPTO + Val(TSH->TSH_PONTOS)
				ElseIf TSH->TSH_PONTOS == "4"
					(cTRB)->CODP4 := (cTRB)->CODP4+1
					(cTRB)->CODPTO	:= (cTRB)->CODPTO + Val(TSH->TSH_PONTOS)
				ElseIf TSH->TSH_PONTOS == "5"
					(cTRB)->CODP5 := (cTRB)->CODP5+1
					(cTRB)->CODPTO	:= (cTRB)->CODPTO + Val(TSH->TSH_PONTOS)
				ElseIf TSH->TSH_PONTOS == "7"
					(cTRB)->CODP7 := (cTRB)->CODP7+1
					(cTRB)->CODPTO	:= (cTRB)->CODPTO + Val(TSH->TSH_PONTOS)
				EndIf
			EndIf
			If (cAliasQry)->TRX_INFRAC == "1"
				(cTRB)->INFSIM := (cTRB)->INFSIM+1
				(cTRB)->INFTOT := (cTRB)->INFTOT+1
			ElseIf (cAliasQry)->TRX_INFRAC == "2"
				(cTRB)->INFNAO := (cTRB)->INFNAO+1
				(cTRB)->INFTOT := (cTRB)->INFTOT+1
			ElseIf (cAliasQry)->TRX_INFRAC == "3"
				//(cTRB)->INFSER := (cTRB)->INFSER+1
				(cTRB)->INFTOT := (cTRB)->INFTOT+1
			EndIf
			MsUnLock(cTRB)
			(cAliasQry)->(dbSkip())
		End
	EndIf

	dbSelectArea(cAliasQry)
	dbCloseArea()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNT415Gr  ³ Autor ³Rafael Diogo Richter   ³ Data ³12/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida o parametro Grupo                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR415                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNT415Gr(nGr)

	If (Empty(mv_par05) .And. mv_par06 = 'ZZ') .OR. (MV_PAR06 = 'ZZ')
		MV_PAR03 := "        "
		MV_PAR04 := "        "
		Return .T.
	Else
		If nGr == 2
			If !Empty(MV_PAR06)
				lRet := If(atecodigo("TRW",mv_par05,mv_par06),.t.,.f.)
				If !lRet
					Return .F.
				EndIf
				If !Empty(MV_PAR06)
					MV_PAR03 := "        "
					MV_PAR04 := "        "
				EndIf
			ElseIf Empty(MV_PAR03) .AND. Empty(MV_PAR04)
				NaoVazio()
				Return .F.		
			Endif
		Else
			lRet := If(Empty(MV_PAR05),.T., ExistCpo('TRW',MV_PAR05))
			If !lRet
				Return .F.
			EndIf
			If !Empty(MV_PAR05)
				MV_PAR03 := "        "
				MV_PAR04 := "        "
			EndIf
		EndIf
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNTDT415  ³ Autor ³Inacio Luiz Kolling    ³ Data ³25/10/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao De Data                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Dicionario                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNTDT415()
	If !NaoVazio(mv_par01)
		Return .f.
	Endif
	If mv_par01 > date()
		MsgInfo(STR0024+" "+STR0026+" "+STR0028,STR0027)
		Return .f.
	Endif
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNTAT415  ³ Autor ³Inacio Luiz Kolling    ³ Data ³25/10/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao Ate Data                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Dicionario                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNTAT415()
	If !NaoVazio(mv_par02)
		Return .f.
	Endif
	If mv_par02 > date()
		MsgInfo(STR0025+" "+STR0026+" "+STR0028,STR0027)
		Return .f.
	Endif
	If mv_par02 < mv_par01
		MsgInfo(STR0025+" "+STR0026+" "+STR0024,STR0027)
	Endif
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNT415PTOS³ Autor ³Marcos Wagner Junior   ³ Data ³21/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao De/Ate Pontos                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR415                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNT415PTOS()

	If MV_PAR07 > MV_PAR08
		MsgStop(STR0029,STR0023) //"De Pontos não poderá ser maior que Ate Pontos!"###"ATENÇÃO"
		Return .f.
	Endif

Return .t.
