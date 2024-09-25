#INCLUDE "MNTA385.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MNTA385  ³ Autor ³ Felipe Nathan Welter  ³ Data ³ 20/08/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Apropriacao de custos (integracao RM)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAMNT X Backoffice RM                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTA385()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Armazena variaveis p/ devolucao (NGRIGHTCLICK)                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aNGBEGINPRM := NGBEGINPRM()

	Local oFont12B := TFont():New("Arial",,-12,,.T.,,,,.T.,.F.)
	Local oComboBox, oBtnVer
	Local nX

	Private cCODBEM := Space(TAMSX3("T9_CODBEM")[1])
	Private cLIST   := '1'
	Private dDTINI  := dDataBase-30
	Private M->TJ_INTPRJ := Space(TAMSX3("AF8_PROJET")[1])
	Private M->TJ_INTTSK := Space(TAMSX3("AF9_TAREFA")[1])

	Private oDlg, oGet
	Private oPanel, oPanelTop, oPanel1, oPanelBtm
	Private aChoice := {}, aHead385 := {}, aCols := {}, nMAR
	Private aSize := MsAdvSize()
	Private nLeft := 0

	If AllTrim(GetNewPar("MV_NGINTER","N")) != "M"
		ShowHelpDlg(STR0001, {STR0002+; //"ATENCAO"###"A rotina de apropriação de custos só pode ser executada se o ambiente estiver configurado "
										STR0003,""},2,; //"para trabalhar com integração via mensagem única."
									  {STR0004,""},2) //"Habilite o parâmetero MV_NGINTER para trabalhar com a integração."
		Return .F.
	EndIf

	Define MsDialog oDlg From aSize[7],nLeft to aSize[6],aSize[5] Title STR0005 Pixel //"Apropriação de Custos"

		oDlg:lMaximized := .T.
		oDlg:lEscClose := .F.

		oPanel := TPanel():New(01,01,,oDlg,,,,,CLR_WHITE,10,10,.F.,.F.)
		   oPanel:Align := CONTROL_ALIGN_ALLCLIENT

		oPanelTop := TPanel():New(01,01,,oPanel,,,,,CLR_WHITE,10,30,.F.,.F.)
		   oPanelTop:Align := CONTROL_ALIGN_TOP

		   @ 10,3 Say STR0006 Pixel Of oPanelTop COLOR CLR_HBLUE  //"Bem"
		   @ 8,20 MsGet cCODBEM Picture '@!' Size 70,10 F3 "ST9" HASBUTTON Valid ExistCpo("ST9",cCODBEM)  Pixel Of oPanelTop
		   @ 10,105 Say STR0007 Pixel Of oPanelTop COLOR CLR_HBLUE  //"Listar"
			@ 8,125 MSCOMBOBOX oComboBox VAR cLIST ITEMS {"1="+STR0008,"2="+STR0009,"3="+STR0010} Size 65,10 Pixel Of oDlg //"Ordens de Serviço"###"Contador 1"###"Contador 2"
		   @ 10,200 Say STR0011 Pixel Of oPanelTop COLOR CLR_HBLUE  //"a partir de"
		   @ 8,228 MsGet dDTINI Picture '99/99/9999' Size 46,10 HASBUTTON Valid NaoVazio() Pixel Of oPanelTop
		   @ 8,300 Button STR0012 Size 40,10 Pixel Of oPanelTop Action fLoadGet() //"&Carregar"

		oPanel1 := TPanel():New(01,01,,oPanel,,,,,RGB(229,227,227),10,10,.F.,.F.)
		   oPanel1:Align := CONTROL_ALIGN_ALLCLIENT

		oPanelBtm := TPanel():New(01,01,,oPanel,,,,,CLR_WHITE,10,30,.F.,.F.)
		   oPanelBtm:Align := CONTROL_ALIGN_BOTTOM

	   	@ 1,2 To 26,55 Label STR0013 Pixel Of oPanelBtm //"Legenda"
			@ 8,4 BitMap oBtnVer Resource 'checked_15' Size 17,17 of oPanelBtm Pixel Noborder Design
		   @ 8,14 Say STR0014 Pixel Of oPanelBtm //"a apropriar"
			@ 16,4 BitMap oBtnVer Resource 'nochecked_15' Size 17,17 of oPanelBtm Pixel Noborder Design
		   @ 16,14 Say STR0015 Pixel Of oPanelBtm //"apropriado"

		   @ 10,65 Say STR0016 Pixel Of oPanelBtm COLOR CLR_HBLUE  //"Projeto"
		   @ 8,88 MsGet M->TJ_INTPRJ Picture '@!' Size 46,10 Valid ExistCpo("AF8",M->TJ_INTPRJ,1) Pixel Of oPanelBtm F3 "AF8" HASBUTTON
		   @ 10,135 Say STR0017 Pixel Of oPanelBtm COLOR CLR_HBLUE  //"Tarefa"
		   @ 8,158 MsGet M->TJ_INTTSK Picture '@!' Size 46,10 Valid Vazio() .Or. ExistCpo("AF9",M->TJ_INTPRJ+M->TJ_INTTSK,5) Pixel Of oPanelBtm F3 "MNTAF9" HASBUTTON
		   @ 8,215 Button STR0018 Size 40,10  Pixel Of oPanelBtm Action fApropriar() //"&Apropriar"

	Activate Dialog oDlg

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Devolve variaveis armazenadas (NGRIGHTCLICK)                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	NGRETURNPRM(aNGBEGINPRM)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fLoadGet ³ Autor ³ Felipe Nathan Welter  ³ Data ³ 20/08/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Apropriacao de custos (integracao RM)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAMNT X Backoffice RM                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fLoadGet()

	Local nX
	Local lRet := .T.

	dbSelectArea("ST9")
	dbSetOrder(01)
	dbSeek(xFilial("ST9")+cCODBEM)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida os parametros iniciais               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cLIST == '2' //CONTADOR 1
		If ST9->T9_TEMCONT == "N"
			ShowHelpDlg(STR0001, {STR0019,""},2,; //"ATENCAO"###"Bem nao possui contador 1"
										  {STR0020,""},2) //"Selecione outra forma de listagem"
			lRet := .F.
		EndIf
	ElseIf cLIST == '3' //CONTADOR 2
		dbSelectArea("TPE")
		dbSetOrder(01)
		If !dbSeek(xFilial("TPE")+cCODBEM)
			ShowHelpDlg(STR0001, {STR0021,""},2,; //"ATENCAO"###"Bem nao possui contador 2"
										  {STR0020,""},2) //"Selecione outra forma de listagem"
			lRet := .F.
		EndIf
	EndIf


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega os getdados                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		oPanel1:Hide()

		aChoice := {}
		aHead385 := {}
		aCols := {}

		//------------------------
		If cLIST == '1' // ORDEM DE SERVICO

		   aChoice := {"TJ_ORDEM","TJ_PLANO","TJ_SERVICO","TJ_DTORIGI","TJ_DTMRFIM","TJ_HOMRFIM"}
			aAdd(aHead385,{"","COLBMP","@BMP",11,0,"",Chr(251),"C","","V"})
		   //Monta aHeader
			For nX := 1 To Len(aChoice)

				If cNivel >= Posicione("SX3", 2, aChoice[nX], "X3_NIVEL")  //sem X3USO

					aAdd(aHead385,{NGRETTITULO(aChoice[nX]),;
								   aChoice[nX],;
								   Posicione("SX3", 2, aChoice[nX], "X3_PICTURE"),;
								   Posicione("SX3", 2, aChoice[nX], "X3_TAMANHO"),;
								   Posicione("SX3", 2, aChoice[nX], "X3_DECIMAL"),;
								   Posicione("SX3", 2, aChoice[nX], "X3_VALID"),;
								   Posicione("SX3", 2, aChoice[nX], "X3_USADO"),;
								   Posicione("SX3", 2, aChoice[nX], "X3_TIPO"),;
								   Posicione("SX3", 2, aChoice[nX], "X3_ARQUIVO"),;
								   Posicione("SX3", 2, aChoice[nX], "X3_CONTEXT")})

				EndIf

			Next

		   //Monta aCols
		   dbSelectArea("STJ")
		   dbSetOrder(15)
		   dbSeek(xFilial("STJ")+"B"+cCODBEM+DTOS(dDTINI),.T.)
		   While !Eof() .And. STJ->TJ_FILIAL == xFilial("STJ") .And. STJ->TJ_TIPOOS == "B" .And.;
		   						 STJ->TJ_CODBEM == cCODBEM .And. STJ->TJ_DTORIGI >= dDTINI


		   	If STJ->TJ_SITUACA == "L" .And. STJ->TJ_TERMINO == "S" .And. STJ->TJ_FATURA == '1'
			      aAdd(aCols, Array(Len(aHead385)+1))
			      nC := Len(aCols)
			      For nX := 1 to Len(aHead385)
			         If "TJ_" $ aHead385[nX][2]
			            If aHead385[nX][10] == "V"
			               aCols[nC,nX] := CriaVar(AllTrim(aHead385[nX,2]))
			            Else
			               aCols[nC,nX] := FieldGet(FieldPos(aHead385[nX,2]))
			            EndIf
						ElseIf "COLBMP" $ aHead385[nX][2]
							aCols[nC,nX] := If(STJ->TJ_APROPRI=="1","nochecked_15","LBNO")
						EndIf
					Next
					aCols[nC,Len(aHead385)+1] := .F.
				EndIf

				STJ->(dbSkip())
			EndDo

		//------------------------
		ElseIf cLIST == '2'  //CONTADOR 1

		   aChoice := {"TP_DTLEITU","TP_HORA","TP_POSCONT","TP_ACUMCON","TP_VIRACON","TP_TIPOLAN"}
			aAdd(aHead385,{"","COLBMP","@BMP",11,0,"",Chr(251),"C","","V"})
		   //Monta aHeader
			For nX := 1 To Len(aChoice)

				If cNivel >= Posicione("SX3", 2, aChoice[nX], "X3_NIVEL")  //sem X3USO

					aAdd(aHead385,{NGRETTITULO(aChoice[nX]),;
								   aChoice[nX],;
								   Posicione("SX3", 2, aChoice[nX], "X3_PICTURE"),;
								   Posicione("SX3", 2, aChoice[nX], "X3_TAMANHO"),;
								   Posicione("SX3", 2, aChoice[nX], "X3_DECIMAL"),;
								   Posicione("SX3", 2, aChoice[nX], "X3_VALID"),;
								   Posicione("SX3", 2, aChoice[nX], "X3_USADO"),;
								   Posicione("SX3", 2, aChoice[nX], "X3_TIPO"),;
								   Posicione("SX3", 2, aChoice[nX], "X3_ARQUIVO"),;
								   Posicione("SX3", 2, aChoice[nX], "X3_CONTEXT")})

				EndIf

			Next

		   //Monta aCols
		   dbSelectArea("STP")
		   dbSetOrder(05)
		   dbSeek(xFilial("STP")+cCODBEM+DTOS(dDTINI),.T.)
		   While !Eof() .And. STP->TP_FILIAL == xFilial("STP") .And.;
		   						 STP->TP_CODBEM == cCODBEM .And. STP->TP_DTLEITU >= dDTINI

		      aAdd(aCols, Array(Len(aHead385)+1))
		      nC := Len(aCols)
		      For nX := 1 to Len(aHead385)
		         If "TP_" $ aHead385[nX][2]
		            If aHead385[nX][10] == "V"
		               aCols[nC,nX] := CriaVar(AllTrim(aHead385[nX,2]))
		            Else
		               aCols[nC,nX] := FieldGet(FieldPos(aHead385[nX,2]))
		            EndIf
		            If "TP_TIPOLAN" $ aHead385[nX][2]
		               Do Case
		                  case aCols[nC,nX] == "C"
		                     aCols[nC,nX] := STR0022 //"Contador"
		                  case aCols[nC,nX] == "P"
		                     aCols[nC,nX] := STR0023 //"Produção"
		                  case aCols[nC,nX] == "A"
		                     aCols[nC,nX] := STR0024 //"Abastecimento"
		                  case aCols[nC,nX] == "Q"
		                     aCols[nC,nX] := STR0025 //"Quebra"
		                  case aCols[nC,nX] == "I"
		                     aCols[nC,nX] := STR0026 //"Inclusão"
		                  case aCols[nC,nX] == "V"
		                     aCols[nC,nX] := STR0027 //"Virada"
		                  Endcase
		               EndIf
					ElseIf "COLBMP" $ aHead385[nX][2]

						//Busca quantidade a apropriar
						cCodBem := STP->TP_CODBEM
						nKmRodado := STP->TP_ACUMCON
						dbSelectArea("STP")
						dbSetOrder(05)
						dbSkip(-1)
						If xFilial("STP") == STP->TP_FILIAL .And. cCodBem == STP->TP_CODBEM
							nKmRodado -= STP->TP_ACUMCON
						Else
							nKmRodado := 0
						EndIf
						dbSkip()

						If nKmRodado == 0
							aCols[nC,nX] := '-'
						Else
							aCols[nC,nX] := If(STP->TP_APROPRI=="1","nochecked_15","LBNO")
						EndIf
					EndIf
				Next
				aCols[nC,Len(aHead385)+1] := .F.

				STP->(dbSkip())
			EndDo

		//------------------------
		ElseIf cLIST == '3' //CONTADOR 2

		   aChoice := {"TPP_DTLEIT","TPP_HORA","TPP_POSCON","TPP_ACUMCO","TPP_VIRACO","TP_TIPOLA"}
			aAdd(aHead385,{"","COLBMP","@BMP",11,0,"",Chr(251),"C","","V"})
		   //Monta aHeader
			For nX := 1 To Len(aChoice)

				If cNivel >= Posicione("SX3", 2, aChoice[nX], "X3_NIVEL")  //sem X3USO

					aAdd(aHead385,{NGRETTITULO(aChoice[nX]),;
								   aChoice[nX],;
								   Posicione("SX3", 2, aChoice[nX], "X3_PICTURE"),;
								   Posicione("SX3", 2, aChoice[nX], "X3_TAMANHO"),;
								   Posicione("SX3", 2, aChoice[nX], "X3_DECIMAL"),;
								   Posicione("SX3", 2, aChoice[nX], "X3_VALID"),;
								   Posicione("SX3", 2, aChoice[nX], "X3_USADO"),;
								   Posicione("SX3", 2, aChoice[nX], "X3_TIPO"),;
								   Posicione("SX3", 2, aChoice[nX], "X3_ARQUIVO"),;
								   Posicione("SX3", 2, aChoice[nX], "X3_CONTEXT")})

				EndIf

			Next

		   //Monta aCols
		   dbSelectArea("TPP")
		   dbSetOrder(05)
		   dbSeek(xFilial("TPP")+cCODBEM+DTOS(dDTINI),.T.)
		   While !Eof() .And. TPP->TPP_FILIAL == xFilial("TPP") .And.;
		   						 TPP->TPP_CODBEM == cCODBEM .And. TPP->TPP_DTLEIT >= dDTINI

		      aAdd(aCols, Array(Len(aHead385)+1))
		      nC := Len(aCols)
		      For nX := 1 to Len(aHead385)
		         If "TPP_" $ aHead385[nX][2]
		            If aHead385[nX][10] == "V"
		               aCols[nC,nX] := CriaVar(AllTrim(aHead385[nX,2]))
		            Else
		               aCols[nC,nX] := FieldGet(FieldPos(aHead385[nX,2]))
		            EndIf
		            If "TPP_TIPOLA" $ aHead385[nX][2]
		               Do Case
		                  case aCols[nC,nX] == "C"
		                     aCols[nC,nX] := STR0022 //"Contador"
		                  case aCols[nC,nX] == "P"
		                     aCols[nC,nX] := STR0023 //"Produção"
		                  case aCols[nC,nX] == "A"
		                     aCols[nC,nX] := STR0024 //"Abastecimento"
		                  case aCols[nC,nX] == "Q"
		                     aCols[nC,nX] := STR0025 //"Quebra"
		                  case aCols[nC,nX] == "I"
		                     aCols[nC,nX] := STR0026 //"Inclusão"
		                  case aCols[nC,nX] == "V"
		                     aCols[nC,nX] := STR0027 //"Virada"
		                  Endcase
		               EndIf
					ElseIf "COLBMP" $ aHead385[nX][2]

						//Busca quantidade a apropriar
						cCodBem := TPP->TPP_CODBEM
						nKmRodado := TPP->TPP_ACUMCO
						dbSelectArea("TPP")
						dbSetOrder(05)
						dbSkip(-1)
						If xFilial("TPP") == TPP->TPP_FILIAL .And. cCodBem == TPP->TPP_CODBEM
							nKmRodado -= TPP->TPP_ACUMCO
						Else
							nKmRodado := 0
						EndIf
						dbSkip()

						If nKmRodado == 0
							aCols[nC,nX] := '-'
						Else
							aCols[nC,nX] := If(TPP->TPP_APROPR=="1","nochecked_15","LBNO")
						EndIf
					EndIf
				Next
				aCols[nC,Len(aHead385)+1] := .F.

				TPP->(dbSkip())
			EndDo

		EndIf

		//--------------------------------------------------
		If Len(aCols) == 0
			aCols := BlankGetD(aHead385)
		EndIf
		If oGet <> Nil
			oPanel1:FreeChildren()
		EndIf

		oGet := MsNewGetDados():New(0,0,10,10,2,"AllwaysTrue()","AllwaysTrue()",,{"COLBMP"},,,/*[cFieldOk]*/,,,oPanel1,aHead385,aCols,,)
		nMAR := aScan(aHead385,{|x| TRIM(UPPER(x[2])) == "COLBMP" })
		oGet:aInfo[nMAR][4] := "MNA385INV()"

		oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oGet:oBrowse:Refresh()

		oPanel1:Show()
	EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fApropriar³ Autor ³ Felipe Nathan Welter  ³ Data ³ 20/08/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Apropriacao de custos (integracao RM)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAMNT X Backoffice RM                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fApropriar()

	Local nX
	Local nTot := 0, nOk := 0
	Local lRet := .T.
	Local lIndic := .T.

	Local cProject := M->TJ_INTPRJ
	Local cTask    := M->TJ_INTTSK

	If Empty(cProject) .Or. Empty(cTASK)
		ShowHelpDlg(STR0001, {STR0028,""},2,; //"ATENCAO"###"Não foram informados projeto e tarefa para apropriação."
									  {STR0029,""},2) //"Preencha os campos necessãrios e clique em 'apropriar'."
		lRet := .F.
	ElseIf oGet == Nil //carregou get's
		ShowHelpDlg(STR0001, {STR0030,""},2,; //"ATENCAO"###"Não foram marcados itens para apropriação."
									  {STR0031,""},2) //"Informe os parâmetros e selecione a opção 'carregar'."
		lRet := .F.
	ElseIf asCan(oGet:aCols,{|x| x[nMAR] == "checked_15"}) > 0
		lRet := MsgYesNo(STR0032+CRLF+STR0033) //"Foram marcados itens para apropriação de custos."###"Deseja prosseguir com o processo?"
	EndIf

	If lRet

		For nX := 1 To Len(oGet:aCols)

			If oGet:aCols[nX][nMAR] == "checked_15"
				nTot++

				If cLIST == '1' //ORDEM DE SERVICO
					nOrdem := aScan(aHead385,{|x| TRIM(UPPER(x[2])) == "TJ_ORDEM" })
					nPlano := aScan(aHead385,{|x| TRIM(UPPER(x[2])) == "TJ_PLANO" })
					dbSelectArea("STJ")
					dbSetOrder(01)
					If dbSeek(xFilial("STJ")+oGet:aCols[nX][nOrdem]+oGet:aCols[nX][nPlano])

						dbSelectArea("AF8")
						dbSetOrder(01)
						If dbSeek(xFilial("AF8")+cProject)
							cProject := AF8->AF8_PROJET
							dbSelectArea("AF9")
							dbSetOrder(05)
							If dbSeek(xFilial("AF9")+AF8->AF8_PROJET+cTask)
								cTask := AF9->AF9_TAREFA
							EndIf
						EndIf

						aFields := {{"ProjectInternalId",cProject},{"TaskInternalId",cTask}}
						lAprop := NGMUAprCst(STJ->(RecNo()),3,"STJ",aFields)

						RecLock("STJ",.F.)
						STJ->TJ_APROPRI := If(lAprop,'1','2')
						MsUnLock("STJ")

						If STJ->TJ_APROPRI == '1'
							nOk++
							oGet:aCols[nX][nMAR] := "nochecked_15"
						Else
							lRet := .F.
						EndIf
					EndIf

				ElseIf cLIST == '2' //CONTADOR 1
					nDtLeit  := aScan(aHead385,{|x| TRIM(UPPER(x[2])) == "TP_DTLEITU" })
					nHora    := aScan(aHead385,{|x| TRIM(UPPER(x[2])) == "TP_HORA" })
					dbSelectArea("STP")
					dbSetOrder(05)
					If dbSeek(xFilial("STP")+cCODBEM+DTOS(oGet:aCols[nX][nDtLeit])+oGet:aCols[nX][nHora])

						dbSelectArea("TUT")
						dbSetOrder(01)
						If !dbSeek(xFilial("TUT")+STP->TP_CODBEM+'1')
							ShowHelpDlg(STR0001, {STR0034,""},2,; //"ATENCAO"###"Não foi encontrado indicador de custo para o contador 1 do bem."
														  {"",""},2)
							lRet := .F.
							lIndic := .F.
						Else
							dbSelectArea("AF8")
							dbSetOrder(01)
							If dbSeek(xFilial("AF8")+cProject)
								cProject := AF8->AF8_FILIAL+"|"+AF8->AF8_PROJET
								dbSelectArea("AF9")
								dbSetOrder(05)
								If dbSeek(xFilial("AF9")+AF8->AF8_PROJET+cTask)
									cTask := AF9->AF9_FILIAL+'|'+AF9->AF9_PROJET+'|'+AF9->AF9_REVISA+'|'+AF9->AF9_TAREFA
								EndIf
							EndIf

							aFields := {{"ProjectInternalId",cProject},{"TaskInternalId",cTask}}

							// Executa mensagem unica para Apropriação de Custo
							lAprop := NGMUAprCst(STP->(RecNo()),3,"STP",aFields)

							dbSelectArea("STP")
							RecLock("STP",.F.)
							STP->TP_APROPRI := If(lAprop,'1','2')
							MsUnLock()

							If STP->TP_APROPRI == '1'
								nOk++
								oGet:aCols[nX][nMAR] := "nochecked_15"
							Else
								lRet := .F.
							EndIf
						EndIf

					EndIf

				ElseIf cLIST == '3' //CONTADOR 2
					nDtLeit  := aScan(aHead385,{|x| TRIM(UPPER(x[2])) == "TPP_DTLEIT" })
					nHora    := aScan(aHead385,{|x| TRIM(UPPER(x[2])) == "TPP_HORA" })
					dbSelectArea("TPP")
					dbSetOrder(05)
					If dbSeek(xFilial("TPP")+cCODBEM+DTOS(oGet:aCols[nX][nDtLeit])+oGet:aCols[nX][nHora])

						dbSelectArea("TUT")
						dbSetOrder(01)
						If !dbSeek(xFilial("TUT")+TPP->TPP_CODBEM+'2')
							ShowHelpDlg(STR0001, {STR0035,""},2,; //"ATENCAO"###"Não foi encontrado indicador de custo para o contador 2 do bem."
														  {"",""},2)
							lRet := .F.
							lIndic := .F.
						Else

							dbSelectArea("AF8")
							dbSetOrder(01)
							If dbSeek(xFilial("AF8")+cProject)
								cProject := AF8->AF8_FILIAL+"|"+AF8->AF8_PROJET
								dbSelectArea("AF9")
								dbSetOrder(05)
								If dbSeek(xFilial("AF9")+AF8->AF8_PROJET+cTask)
									cTask := AF9->AF9_FILIAL+'|'+AF9->AF9_PROJET+'|'+AF9->AF9_REVISA+'|'+AF9->AF9_TAREFA
								EndIf
							EndIf

							aFields := {{"ProjectInternalId",cProject},{"TaskInternalId",cTask}}
							lAprop := NGMUAprCst(TPP->(RecNo()),3,"TPP",aFields)

							RecLock("TPP",.F.)
							TPP->TPP_APROPR := If(lAprop,'1','2')
							MsUnLock("TPP")

							If TPP->TPP_APROPR == '1'
								nOk++
								oGet:aCols[nX][nMAR] := "nochecked_15"
							Else
								lRet := .F.
							EndIf
						EndIf
					EndIf

				EndIf

			EndIf

			If !lIndic
				Exit
			EndIf

		Next nX

		If nTot == 0
			ShowHelpDlg(STR0001, {STR0030,""},2,; //"ATENCAO"###"Não foram marcados itens para apropriação."
										  {STR0036,""},2) //"Marque os itens que deseja apropriar."
			lRet := .F.
		Else
			MsgInfo(STR0037+cValToChar(nOk)+STR0038+cValToChar(nTot)+STR0039) //"Foram apropriados "###" de um total de "###" registros."
		EndIf

	EndIf


Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MNA385INV³ Autor ³ Felipe Nathan Welter  ³ Data ³ 20/08/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Apropriacao de custos (integracao RM)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAMNT X Backoffice RM                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNA385INV()
	If Alltrim(oGet:aCols[n][nMAR]) == "LBNO"
		aCols[n][nMAR] := "checked_15"
	ElseIf Alltrim(oGet:aCols[n][nMAR]) == "checked_15"
		aCols[n][nMAR] := "LBNO"
	EndIf
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MNA385APR³ Autor ³ Felipe Nathan Welter  ³ Data ³ 22/08/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se ha registros apropriados posteriores a dt/hr   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³1.cCodBem - codigo do bem                                   ³±±
±±³          ³2.dDt - data de leitura                                     ³±±
±±³          ³3.cHr - hora de leitura                                     ³±±
±±³          ³4.nTp - indica se e' contaor 1 ou 2                         ³±±
±±³          ³5.lFirst - verif. apenas o registro posterior      (def=.F.)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAMNT X Backoffice RM                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNA385APR(cCodBem,dDt,cHr,nTp,lFirst)

	Local cQuery := '', cQueryI := '', cQueryF := ''
	Local cQuery1S := '', cQuery1W := '', cQuery1O := ''
	Local cSGBD := Upper(AllTrim(TcGetDB()))
	Local lRet

	Default nTp := 1
	Default lFirst := .F.

	If nTp == 1
		//SELECT
		cQueryI += " SELECT "+If(lFirst,"TMP.TP_APROPRI AS APROPRI","COUNT(*) AS TOTAL")+" FROM ("
		   //select
			cQuery1S += If(lFirst,/*" SELECT TOP 1"*/" * FROM "," * FROM ")
			cQuery1S += RetSQLName("STP")+" STP "
			//where
			cQuery1W += " WHERE STP.TP_CODBEM = "+ValToSql(cCodBem)
			cQuery1W += "   AND STP.TP_DTLEITU||STP.TP_HORA >= "+ValToSql(DTOS(dDt)+cHr)
			cQuery1W += If(lFirst,"","   AND STP.TP_APROPRI = '1' ")
			cQuery1W += "   AND STP.TP_FILIAL = "+ValToSql(xFilial("STP"))
			cQuery1W += "   AND STP.D_E_L_E_T_ <> '*' "
			//order by
			cQuery1O += If(lFirst," ORDER BY STP.TP_DTLEITU||STP.TP_HORA ASC","")
		cQueryF += ") TMP"
	ElseIf nTp == 2
		//SELECT
		cQueryI += " SELECT "+If(lFirst,"TMP.TPP_APROPR AS APROPRI","COUNT(*) AS TOTAL")+" FROM ("
			//select
			cQuery1S += If(lFirst,/*" SELECT TOP 1"*/" * FROM "," * FROM ")
			cQuery1S += RetSQLName("TPP")+" TPP "
			//where
			cQuery1W += " WHERE TPP.TPP_CODBEM = "+ValToSql(cCodBem)
			cQuery1W += "   AND TPP.TPP_DTLEIT||TPP.TPP_HORA >= "+ValToSql(DTOS(dDt)+cHr)
			cQuery1W += If(lFirst,"","   AND TPP.TPP_APROPR = '1' ")
			cQuery1W += "   AND TPP.TPP_FILIAL = "+ValToSql(xFilial("TPP"))
			cQuery1W += "   AND TPP.D_E_L_E_T_ <> '*' "
			//order by
			cQuery1O += If(lFirst," ORDER BY TPP.TPP_DTLEIT||TPP.TPP_HORA ASC","")
		cQueryF += ") TMP"
	EndIf

	If lFirst
		Do Case
			Case cSGBD $ "ORACLE"
				cQuery1W += " AND ROWNUM <= 1 "
			Case cSGBD $ "MYSQL"
				cQuery1O += " LIMIT 1 "
			Case cSGBD $ "DB2"
				cQuery1O += " FETCH FIRST 1 ROW ONLY "
			Otherwise
				cQuery1S := " TOP 1 " + cQuery1S
		EndCase
	EndIf
	cQuery1S := " SELECT " + cQuery1S

	cQuery := cQueryI + cQuery1S + cQuery1W + cQuery1O + cQueryF
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	lRet := If(lFirst,(cAliasQry)->APROPRI == '1',(cAliasQry)->TOTAL > 0)
	(cAliasQry)->(dbCloseArea())

Return lRet