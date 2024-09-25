#INCLUDE "MNTC130.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "mProject.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MNTC130  ³ Autor ³Vitor Emanuel Batista  ³ Data ³09/07/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para integracao do SIGAMNT com o Ms-Project, listando|±±
±±³          ³todas as O.S Pendentes com seus respectivos insumos.        |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTC130()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Guarda conteudo e declara variaveis padroes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aNGBEGINPRM := NGBEGINPRM()

Local nFindPrj := 0
Local cPerg := "MNTC130"+Space(3)

//Verifica se Microsoft Project esta instalado
While nFindPrj < 10 .And. !ApOleClient( "MsProject" )
	nFindPrj++
End

If nFindPrj < 10
	Aviso(STR0001,; //"Integracao Microsoft Project"
			STR0002,{"Ok"},2) //"Atencao! Certifique-se de que o formato da data no Microsoft Project (Ferramentas - Opcoes) está configurado corretamente. 31/12/00 12:33"

	If Pergunte(cPerg,.t.)
		//Monta Projeto e abre o Ms-Project
		MsgRun( STR0003 , STR0004 , { || MNT130PROJ() }) //"Processando informações..."###"Aguarde"
	EndIf
Else
	MsgInfo(STR0005) //"Microsoft Project não instalado!"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna conteudo de variaveis padroes       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
NGRETURNPRM(aNGBEGINPRM)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³MNT130PROJ| Autor ³Denis Hyroshi de Souza ³ Data ³13/03/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³Funcao para integracao do Protheus com  o Project            ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTC130                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNT130PROJ()
Local lPrimeiro:= .t.
Local nTar     := 0
Local aConfig  := {}
Local oApp
Local cPLANOSTJ, lPLANOVAL
Private aCalBase  := {PJSUNDAY, PJMONDAY, PJTUESDAY, PJWEDNESDAY, PJTHURSDAY, PJFRIDAY, PJSATURDAY}

cCONDSTJ := ' STJ->TJ_SITUACA == "P" .And. STJ->TJ_TERMINO == "N" .And.'
cCONDSTJ += ' STJ->TJ_CODBEM  >= MV_PAR03 .And. STJ->TJ_CODBEM  <= MV_PAR04 .And.'
cCONDSTJ += ' STJ->TJ_DTORIGI >= MV_PAR05 .And. STJ->TJ_DTORIGI <= MV_PAR06 .And.'
cCONDSTJ += ' STJ->TJ_SERVICO >= MV_PAR07 .And. STJ->TJ_SERVICO <= MV_PAR08 .And.'
cCONDSTJ += ' STJ->TJ_CENTRAB >= MV_PAR09 .And. STJ->TJ_CENTRAB <= MV_PAR10 .And.'
cCONDSTJ += ' STJ->TJ_CCUSTO  >= MV_PAR13 .And. STJ->TJ_CCUSTO  <= MV_PAR14'

oApp := MsProject():New()
oApp:Quit( 0 )
oApp:Destroy()
oApp := MsProject():New()
oApp:VISIBLE:= .f.
oApp:Projects:Add()

oApp:TableEdit('Ap6View',.T.,.T.,.T.,,'ID',			,							,06,PJCENTER	,.T.,.T.,PJDATEDEFAULT,1,,PJCENTER)
oApp:TableEdit('Ap6View',.T.,		,.T.,,,'Text3'		,	STR0006				,06,PJLEFT		,.T.,.T.,PJDATEDEFAULT,1,,PJCENTER) //"Plano"
oApp:TableEdit('Ap6View',.T.,		,.T.,,,'Text1'		,	STR0007				,06,PJLEFT		,.T.,.T.,PJDATEDEFAULT,1,,PJCENTER) //"Ordem"
oApp:TableEdit('Ap6View',.T.,		,.T.,,,'Name'		,	STR0008	,24,PJLEFT		,.T.,.T.,PJDATEDEFAULT,1,,PJCENTER) //"Nome da Tarefa"
oApp:TableEdit('Ap6View',.T.,		,.T.,,,'Duration'	,	STR0009				,12,PJRIGHT	,.T.,.T.,PJDATEDEFAULT,1,,PJCENTER) //"Duração"
oApp:TableEdit('Ap6View',.T.,		,.T.,,,'Start'		,	STR0010				,20,PJRIGHT		,.T.,.T.,PJDATEDEFAULT,1,,PJCENTER) //"Início"
oApp:TableEdit('Ap6View',.T.,		,.T.,,,'Finish'	,	STR0011					,20,PJRIGHT		,.T.,.T.,PJDATEDEFAULT,1,,PJCENTER) //"Fim"
oApp:TableApply('Ap6View' )

dbSelectArea("STJ")
dbSetOrder(03)
dbSeek(xFilial("STJ")+MV_PAR01,.T.)
While !Eof() .And. xFilial("STJ") == STJ->TJ_FILIAL .And. STJ->TJ_PLANO  <= MV_PAR02

	cPLANOSTJ := STJ->TJ_PLANO
	lPLANOVAL := .T.

	If cPLANOSTJ > "000001"
		dbSelectArea("STI")
		dbSetOrder(01)
		If dbSeek(xFilial("STI")+cPLANOSTJ)
			If  STI->TI_SITUACA <> "P" .Or. STI->TI_TERMINO <> "N"
				lPLANOVAL := .F.
			EndIf
		EndIf
	EndIf

	dbSelectArea("STJ")
	While !Eof() .And. STJ->TJ_FILIAL == xFilial("STJ") .And. STJ->TJ_PLANO == cPLANOSTJ

		If !lPLANOVAL
			dbSelectArea("STJ")
			dbSkip()
			Loop
		EndIf

		If &(cCONDSTJ)
			dbSelectArea("ST9")
			dbSetOrder(1)
			If dbSeek(xFilial("ST9")+STJ->TJ_CODBEM)
				If ST9->T9_CODFAMI < MV_PAR11 .Or. ST9->T9_CODFAMI > MV_PAR12 //FILTRA FAMILIA DO BEM
					dbSelectArea("STJ")
					dbSkip()
					Loop
				EndIf
			Else
				dbSelectArea("STJ")
				dbSkip()
				Loop
			EndIf

			lPrimeiro := .t.
			dbSelectArea("STL")
			dbSetOrder(01)
			dbSeek(xFilial("STL")+STJ->TJ_ORDEM+STJ->TJ_PLANO)
			While !Eof() .And. STL->TL_FILIAL == xFilial("STL") .And.;
				STL->TL_ORDEM == STJ->TJ_ORDEM  .And. STL->TL_PLANO  == STJ->TJ_PLANO

				If Val(STL->TL_SEQRELA) > 0
					dbSelectArea("STL")
					dbSkip()
					Loop
				EndIf

				If lPrimeiro
					nTar++
					oApp:Projects(1):Tasks:Add(Alltrim(STJ->TJ_CODBEM)+" - "+If(STJ->TJ_TIPOOS == "B",Alltrim(NGSEEK("ST9",STJ->TJ_CODBEM,1,"SUBSTR(T9_NOME,1,20)")),;
					Alltrim(NGSEEK("TAF","X2"+Substr(STJ->TJ_CODBEM,1,3),7,"SUBSTR(TAF_NOMNIV,1,20)")))+" / "+Alltrim(STJ->TJ_SERVICO))
					oApp:Projects(1):Tasks(nTar):SetField('PJTASKTEXT3'	,STJ->TJ_PLANO)
					oApp:Projects(1):Tasks(nTar):SetField('PJTASKTEXT1'	,STJ->TJ_ORDEM)
					oApp:Projects(1):Tasks(nTar):SetField('PJTASKNUMBER1',STJ->TJ_SEQRELA)
					oApp:Projects(1):Tasks(nTar):SetField('PJTASKTEXT2'	,STJ->TJ_CCUSTO)
					If nTar > 1
						oApp:Projects(1):Tasks(nTar):OutLineOutIndent()
					EndIf
					oApp:Projects(1):Tasks(nTar):Start := DTOC(STJ->TJ_DTMPINI)+" "+STJ->TJ_HOMPINI
					oApp:Projects(1):Tasks(nTar):SetField('PJTASKFINISH',DTOC(STJ->TJ_DTMPFIM)+" "+STJ->TJ_HOMPFIM)
				EndIf

				cF3INS  := "SB1"
				cCodigo := SubStr(STL->TL_CODIGO,1,NGSX3TAM("B1_COD"))
				If STL->TL_TIPOREG == "T"
					cF3INS := "SA2"
					cCodigo := SubStr(STL->TL_CODIGO,1,NGSX3TAM("A2_COD"))
				ElseIf STL->TL_TIPOREG == "M"
					cF3INS := "ST1"
					cCodigo := SubStr(STL->TL_CODIGO,1,NGSX3TAM("T1_CODFUNC"))
				ElseIf STL->TL_TIPOREG == "E"
					cF3INS := "ST0"
					cCodigo := SubStr(STL->TL_CODIGO,1,NGSX3TAM("T0_ESPECIA"))
				ElseIf STL->TL_TIPOREG == "F"
					cF3INS := "SH4"
					cCodigo := SubStr(STL->TL_CODIGO,1,NGSX3TAM("H4_CODIGO"))
				EndIf

				dbSelectArea(cF3INS)
				dbSetOrder(1)
				dbSeek(xFilial(cF3INS)+cCodigo)
				cNOMCOD := Space(20)

				If cF3INS == "SB1"
					cNOMCOD := SubStr(SB1->B1_DESC,1,20)
				ElseIf cF3INS == "ST1"
					cNOMCOD := SubStr(ST1->T1_NOME,1,20)
				ElseIf cF3INS == "SA2"
					cNOMCOD := SubStr(SA2->A2_NOME,1,20)
				ElseIf cF3INS == "SH4"
					cNOMCOD := SubStr(SH4->H4_DESCRI,1,20)
				ElseIf cF3INS == "ST0"
					cNOMCOD := SubStr(ST0->T0_NOME,1,20)
				EndIf

				nTar++
				oApp:Projects(1):Tasks:Add(ALLTRIM(STL->TL_CODIGO)+" - "+ALLTRIM(cNOMCOD))
				If lPrimeiro
					oApp:Projects(1):Tasks(nTar):OutLineIndent()
				EndIf
				oApp:Projects(1):Tasks(nTar):SetField('PJTASKNUMBER1',STL->TL_SEQRELA)
				oApp:Projects(1):Tasks(nTar):Start := DTOC(STL->TL_DTINICI)+" "+STL->TL_HOINICI
				oApp:Projects(1):Tasks(nTar):SetField('PJTASKFINISH',DTOC(STL->TL_DTFIM)+" "+STL->TL_HOFIM)

				cSeek := "STJ->TJ_ORDEM+STJ->TJ_PLANO+STL->TL_TAREFA+STL->TL_TIPOREG+STL->TL_CODIGO+STL->TL_SEQRELA"

				oApp:Projects(1):Tasks(nTar):SetField('PJTASKTEXT5',"'"+&cSeek+"'")
				lPrimeiro := .f.

				dbSelectArea("STL")
				dbSkip()
			End
		EndIf
		dbSelectArea("STJ")
		dbSkip()
	End
End

If nTar > 0
	oApp:VISIBLE:= .T.
	If MsgYesNo(STR0012) //"Deseja que as alterações feitas no Project sejam sincronizadas com o SIGAMNT ?"
		Processa({|| PROJMNT(@oApp)})
	EndIf
Else
	MsgStop(STR0013) //"Não há dados a serem mostrados."
EndIf

oApp:Quit( 0 )
oApp:Destroy()
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ PROJMNT  |  Autor³Denis Hyroshi de Souza ³ Data ³13/03/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³Sincroniza as alteracoes do Project para o SIGAMNT           ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTC130                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PROJMNT(oApp)
Local nx,nw
Local cHoraini,cHorafim,cOrdem,cPlanoSTJ

Local aTempCpo := {}
Local oProject := oApp:Projects(1)
Local cCALFUNC := Space(Len(sh7->h7_codigo))
Local nLimite

oApp:VISIBLE:= .F.
nLimite := oApp:Projects(1):Tasks:Count

ProcRegua(nLimite)
For nw := 1 to nLimite
	IncProc()
	nx := nw
	If !Empty(oApp:Projects(1):Tasks(nx):GetField('PJTASKWBS'))
		If Val(oApp:Projects(1):Tasks(nx):GetField('PJTASKOUTLINELEVEL')) == 1

			cOrdem    := Substr(Alltrim(oApp:Projects(1):Tasks(nx):GetField('PJTASKTEXT1')),1,6)
			cPlanoSTJ := Substr(Alltrim(oApp:Projects(1):Tasks(nx):GetField('PJTASKTEXT3')),1,6)
			dbSelectArea("STJ")
			dbSetOrder(1)
			If dbSeek(xFilial("STJ")+cOrdem+cPlanoSTJ)
				RecLock("STJ",.F.)
				cHoraini := Alltrim(oApp:Projects(1):Tasks(nx):GetField('PJTASKSTART'))
				cHorafim := Alltrim(oApp:Projects(1):Tasks(nx):GetField('PJTASKFINISH'))
				STJ->TJ_DTMPINI := MNTREADDATA(MNTGETFIELD(aTempCpo,oProject,nx,'PJTASKSTART'))
				STJ->TJ_HOMPINI := MNTREADHORA(MNTGETFIELD(aTempCpo,oProject,nx,'PJTASKSTART'))
				STJ->TJ_DTMPFIM := MNTREADDATA(MNTGETFIELD(aTempCpo,oProject,nx,'PJTASKFINISH'))
				STJ->TJ_HOMPFIM := MNTREADHORA(MNTGETFIELD(aTempCpo,oProject,nx,'PJTASKFINISH'))
				MsUnlock("STJ")
			EndIf
		Else
			cOrdem := Substr(Alltrim(oApp:Projects(1):Tasks(nx):GetField('PJTASKTEXT5')),2,6)
			cInsumo := Alltrim(oApp:Projects(1):Tasks(nx):GetField('PJTASKTEXT5'))
			dbSelectArea("STL")
			dbSetOrder(01)
			If dbSeek(xFilial("STL")+Substr(cInsumo,2,Len(cInsumo)-2))
				dbSelectArea("STJ")
				dbSetOrder(01)
				If dbSeek(xFilial('STJ')+cOrdem+cPlanoSTJ)

					dbSelectArea("STL")
					RecLock("STL",.F.)
					cHoraini := Alltrim(oApp:Projects(1):Tasks(nx):GetField('PJTASKSTART'))
					cHorafim := Alltrim(oApp:Projects(1):Tasks(nx):GetField('PJTASKFINISH'))
					STL->TL_DTINICI := MNTREADDATA(MNTGETFIELD(aTempCpo,oProject,nx,'PJTASKSTART'))
					STL->TL_HOINICI := MNTREADHORA(MNTGETFIELD(aTempCpo,oProject,nx,'PJTASKSTART'))
					STL->TL_DTFIM   := MNTREADDATA(MNTGETFIELD(aTempCpo,oProject,nx,'PJTASKFINISH'))
					STL->TL_HOFIM   := MNTREADHORA(MNTGETFIELD(aTempCpo,oProject,nx,'PJTASKFINISH'))

					If STL->TL_TIPOREG != "P"
						nQTDHORA := 0
						If STL->TL_TIPOREG = 'M'
							cCALFUNC := NGSEEK('ST1',Substr(STL->TL_CODIGO,1,6),1,"T1_TURNO")
							If STL->TL_USACALE = "S" .And. !Empty(cCALFUNC)
								nQTDHORA        := NGCALENHORA(STL->TL_DTINICI,STL->TL_HOINICI,STL->TL_DTFIM,STL->TL_HOFIM,cCALFUNC)
								STL->TL_QUANTID := If(STL->TL_TIPOHOR = "D",NGCONVERHORA(nQTDHORA,"S","D"),nQTDHORA)
							Else
								STL->TL_QUANTID := If(STL->TL_TIPOHOR = "D",NGCALCH100(STL->TL_DTINICI,STL->TL_HOINICI,STL->TL_DTFIM,STL->TL_HOFIM);
															,NGCALCH060(STL->TL_DTINICI,STL->TL_HOINICI,STL->TL_DTFIM,STL->TL_HOFIM))
							EndIf
						Else
							STL->TL_QUANTID :=  If(STL->TL_TIPOHOR = "D",NGCALCH100(STL->TL_DTINICI,STL->TL_HOINICI,STL->TL_DTFIM,STL->TL_HOFIM);
														,NGCALCH060(STL->TL_DTINICI,STL->TL_HOINICI,STL->TL_DTFIM,STL->TL_HOFIM))
						Endif
						STL->TL_CUSTO   := NGCALCUSTI(STL->TL_CODIGO,STL->TL_TIPOREG,STL->TL_QUANTID,STL->TL_LOCAL,STL->TL_TIPOHOR)
						STL->TL_UNIDADE := "H"
					EndIf
					MsUnlock("STL")
				EndIf
			EndIf
		EndIf
	EndIf
Next
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTREADDATA³ Autor ³ Elisangela Costa   ³ Data ³ 10-03-2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de leitura da data a partir do campo no MS-Project   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTC130                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MNTREADDATA(cRead)

Local dRet
Local cDtStart
Local nBarSt1
Local nBarSt2
Local cDiaStart
Local cMesStart

If .T.
	dRet := CTOD(Substr(cRead,1,8))
Else
	nPosSep1 := AT(" ",cRead)
	cDtStart := Substr(cRead,1,(nPosSep1-1))
	nBarSt1 := AT("/",cDtStart)
	nBarSt2 := RAT("/",cDtStart)
	If nBarSt1 == 2
		cMesStart := StrZero(Val(Substr(cDtStart,1,1)),2)
	Else
		cMesStart := StrZero(Val(Substr(cDtStart,1,2)),2)
	EndIf
	If nBarSt2 == 4
		cDiaStart := StrZero(Val(Substr(cDtStart,3,1)),2)
	ElseIf nBarSt2 == 6
		cDiaStart := StrZero(Val(Substr(cDtStart,4,2)),2)
	ElseIf nBarSt2 == 5
		If nBarSt1 == 2
			cDiaStart := StrZero(Val(Substr(cDtStart,3,2)),2)
		Else
			cDiaStart := StrZero(Val(Substr(cDtStart,4,1)),2)
		EndIf
	EndIf
	dRet := CTOD(cDiaStart+"/"+cMesStart+"/"+Substr(cDtStart,(Len(cDtStart)-1),2))
EndIf

Return dRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTREADHORA³ Autor ³ Elisangela Costa   ³ Data ³ 10-03-2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de leitura da hora a partir do campo no MS-Project   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTC130                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MNTREADHORA(cRead)
Local cHora
Local nPosSep1

If .T.
	cHora := Substr(cRead,Len(cRead)-4,5)
Else
	nPosSep1 := AT(" ",cRead)
	cHora  := Substr(cRead,(nPosSep1+1),((Len(cRead)-nPosSep1)-3))
	If Len(Alltrim(cHora)) == 4
		cHora := "0" + Alltrim(cHora)
	EndIf
	If Substr(cRead,(Len(cRead)-1),2) == "PM"
		If Substr(cHora,1,2) <> "12"
			cHora := StrZero((Val(Substr(cHora,1,2))+12),2) + Substr(cHora,3,3)
		EndIf
	Else
		If Substr(cHora,1,2) == "12"
			cHora := "00" + Substr(cHora,3,3)
		EndIf
	EndIf
EndIf

Return cHora

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTGETFIELD ³ Autor ³ Elisangela Costa  ³ Data ³ 11-03-2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cache de armazenamento de Objeto para melhorar o desempenho ³±±
±±³          ³na integracao com o Projet                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTC130                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MNTGETFIELD(aTempCpos,oProject,nk,cField)
Local nPosCpo := aScan(aTempCpos,{|x| x[1]==1 .And. x[2] == nk .and. x[3]==cField})
Local xRet

If nPosCpo >0
	xRet := aTempCpos[nPosCpo][4]
Else
	aAdd(aTempCpos,{1,nk,cField,oProject:Tasks(nk):GetField(cField)})
	xRet := aTempCpos[Len(aTempCpos)][4]
EndIf

Return xRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNTC130PLA³ Autor ³Elisangela Costa       ³ Data ³27/10/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida o parametro de plano de manutencao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cVARPLA = Valor do parametro                                ³±±
±±³          ³nPAR = Numero do Parametro de Plano                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTC130                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNTC130PLA(cVARPLA,nPAR)

If nPAR == 1
	If Empty(MV_PAR01)
		Return .T.
	Else
		If !ExistCpo("STI",MV_PAR01)
			Return .F.
		EndIf
	EndIf
Else
	If !AteCodigo("STI",MV_PAR01,MV_PAR02)
		Return .F.
	EndIf
EndIf

If !Empty(cVARPLA) .And. cVARPLA <> "ZZZZZZ" .And. cVARPLA > "000001"
	dbSelectArea("STI")
	dbSetOrder(01)
	If dbSeek(xFilial("STI")+cVARPLA)
		If STI->TI_SITUACA <> "P" .Or. STI->TI_TERMINO <> "N"
			MsgStop(STR0014,STR0015) //"Informe um plano que esteja pendente."###"ATENÇÃO"
			Return .F.
		EndIf
	EndIf
EndIf

Return .T.