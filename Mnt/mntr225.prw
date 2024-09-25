#INCLUDE "MNTR225.ch"
#INCLUDE "PROTHEUS.CH"

#DEFINE _nVERSAO 1 //Versao do fonte
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MNTR225  ³ Autor ³ Vitor Emanuel Batista ³ Data ³26/11/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio de Satisfacao referente atendimento de check-list ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Manutencao de Ativos                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNTR225

	//Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)

	Local cString    := "TQB"
	Local cDesc1     := STR0001 //"Relatório de Satisfação referente ao Atendimendo de Check-List"
	Local cDesc2     := ""
	Local cDesc3     := ""
	Local wnrel      := "MNT225"

	Private aReturn  := { STR0002, 1,STR0003, 2, 2, 1, "",1 }   //"Zebrado"###"Administracao"			
	Private nLastKey := 0
	Private cPerg    := "MNT225"
	Private Titulo   := STR0004 //"Relatírio de Satisfação referente ao Atendimendo de Check-List"
	Private Tamanho  := "G"
	//+----------------------------------+
	//| Variaveis utilizadas             |
	//| mv_par01     // De Data          |
	//| mv_par02     // Ate Data         |
	//| mv_par03     // De Familia       |
	//| mv_par04     // Ate Familia      |
	//| mv_par05     // De Bem           |
	//| mv_par06     // Ate Bem          |
	//+----------------------------------+
	
	Pergunte(cPerg,.F.)
	//Envia controle para a funcao SETPRINT
	wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"")

	If nLastKey = 27
		Set Filter To
		DbselectArea("TQB")
		Return
	Endif

	SetDefault(aReturn,cString)

	RptStatus({|lEnd| R225Imp(@lEnd,wnRel,titulo,tamanho)},titulo)

	DbselectArea("TQB")

	//Devolve variaveis armazenadas (NGRIGHTCLICK)
	NGRETURNPRM(aNGBEGINPRM)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ R225Imp  ³ Autor ³ Vitor Emanuel Batista ³ Data ³ 26/11/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o relatório                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTR225                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R225Imp(lEnd,wnRel,titulo,tamanho)
	Local nOtimoP,nOtimoN, nBomP, nBomN, nSatisP, nSatisN, nRuimP, nRuimN
	Local lPrint := .F.
	Store 0 To nOtimoP,nOtimoN, nBomP, nBomN, nSatisP, nSatisN, nRuimP, nRuimN

	Private li := 80 ,m_pag := 1
	Private Cabec1     := STR0011+DtoC(dDataBase)+STR0019 //"Emissao "###"                                                                                           Avaliação"
	Private Cabec2     := STR0012 //"Check List  Data      O.S     Bem              Nome                      Serviço                Atend. Prazo     Atend. Necessidade "
	Private nomeprog   := "MNTR225"

	nTipo := IIF(aReturn[4]==1,15,18)

	/*
	************************************************************************************************************************************
	*<empresa>                                                                                                        Folha..: xxxxx   *
	*SIGA /SCR001/v.P10            Relatírio de Satisfação referente ao Atendimendo de Check-List                     DT.Ref.: dd/mm/aa*
	*Hora...: xx:xx:xx                                                                                                Emissao: dd/mm/aa*
	*************************************************************************************************************************************
	1         2         3         4         5         6         7         8         9         0         1         2     3
	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
	Avaliação
	Check List  Data      O.S     Bem              Nome                      Serviço                Atend. Prazo     Atend. Necessidade "
	*************************************************************************************************************************************
	000000      00/00/00  000000  0000000000000000 0000000000000000000000000 XXXXXXXXXXXXXXXXXXXXX  Regular          Regular
	000000       00/00/00    000000   0000000000000000 0000000000000000000000000  000000           Otima            Otima
	000000       00/00/00    000000   0000000000000000 0000000000000000000000000  000000           Ruim             Ruim
	000000       00/00/00    000000   0000000000000000 0000000000000000000000000  000000           Satisfatorio     Satisfatorio
	000000       00/00/00    000000   0000000000000000 0000000000000000000000000  000000     

	*/

	dbSelectArea("TQB")
	dbSetOrder(5)
	If dbSeek(xFilial("TQB")+AllTrim(MV_PAR05),.T.)
		SetRegua(LastRec())
		While !Eof() .And. xFilial("TQB") == TQB->TQB_FILIAL .And. TQB->TQB_CODBEM >= MV_PAR05;
		.And. TQB->TQB_CODBEM <= MV_PAR06

			IncRegua()				 
			cCODFAM := NGSEEK("ST9",TQB->TQB_CODBEM,1,"T9_CODFAMI")
			If cCODFAM < MV_PAR03 .Or. cCODFAM > MV_PAR04 .Or.;
			Empty(TQB->TQB_PSAP) .Or. Empty(TQB->TQB_PSAN)	 
				dbSkip()
				Loop
			EndIf

			dbSelectArea("TTG")
			dbSetOrder(2)
			If dbSeek(xFilial("TTG")+TQB->TQB_SOLICI+"S")
				dbSelectArea("TTF")
				dbSetOrder(1)
				dbSeek(xFilial("TTF")+TTG->TTG_CHECK)
				If TTF->TTF_DATA >= MV_PAR01 .Or. TTF->TTF_DATA <= MV_PAR02 
					NgSomali(58)
					cCODBEM := NGSEEK("ST9",TQB->TQB_CODBEM,1,"T9_NOME")
					cSERVIC := NGSEEK("STJ",TQB->TQB_ORDEM ,1,"TJ_SERVICO")
					@ li,00 Psay TTG->TTG_CHECK
					@ li,12 Psay TTF->TTF_DATA
					@ li,24 Psay TQB->TQB_ORDEM
					@ li,32 Psay TQB->TQB_CODBEM
					@ li,51 Psay cCODBEM
					@ li,93 Psay Substr(NGSEEK("ST4",cSERVIC,1,"T4_NOME"),1,20)
					@ li,118 Psay NGRETSX3BOX("TQB_PSAP",TQB->TQB_PSAP)
					@ li,135 Psay NGRETSX3BOX("TQB_PSAN",TQB->TQB_PSAN) 

					If TQB->TQB_PSAP == '1'
						nOtimoP++
					ElseIf TQB->TQB_PSAP == '2'
						nBomP++
					ElseIf TQB->TQB_PSAP == '3'
						nSatisP++                               
					ElseIf TQB->TQB_PSAP == '4'
						nRuimP++
					EndIf 

					If TQB->TQB_PSAN == '1'
						nOtimoN++
					ElseIf TQB->TQB_PSAN == '2'
						nBomN++
					ElseIf TQB->TQB_PSAN == '3'
						nSatisN++
					ElseIf TQB->TQB_PSAN == '4'
						nRuimN++
					EndIf 
					lPrint := .T.
				EndIf			
			EndIf

			dbSelectArea("TQB")
			dbSkip()
		End

		If lPrint
			NgSomali(58)
			NgSomali(58)
			@ li,00 Psay STR0013+STR0017+cValToChar(nOtimoP)+STR0014+cValToChar(nBomP)+; //"Atendimento no Prazo.......: Ótimo = "###" ; Bom = "
			STR0015+cValToChar(nSatisP)+STR0016+cValToChar(nRuimP) //" ; Satisfatório = "###" ; Ruim = "
			NgSomali(58)			 
			@ li,00 Psay STR0018+STR0017+cValToChar(nOtimoN)+STR0014+cValToChar(nBomN)+; //"Atendimento as Necessidades: "###" ; Bom = "
			STR0015+cValToChar(nSatisN)+STR0016+cValToChar(nRuimN) //" ; Satisfatório = "###" ; Ruim = "
		EndIf
	EndIf

	RetIndex("TQB")
	Set Filter To
	Set Device To Screen
	If aReturn[5] == 1
		Set Printer To
		dbCommitAll()
		OurSpool(WNREL)
	EndIf
	MS_FLUSH()
Return .T.