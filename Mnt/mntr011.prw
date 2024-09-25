#Include "MNTR011.ch"
#Include "Protheus.ch"

#Define _nVersao 2 //Versão do fonte

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MNTR011  ³ Autor ³ Vitor Emanuel Batista ³ Data ³15/04/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio para listar manutencoes a vencer utilizando      ³±±
±±³          ³ tolerancia                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTR011()

	Local aNGBEGINPRM := NGBEGINPRM( _nVersao )

	Local cString    := "STF"
	Local cDesc1     := STR0001 //"Relatório de manutenções a vencer dentro do período selecionado"
	Local cDesc2     := STR0002 //"nos parâmetros."
	Local cDesc3     := ""
	Local wnrel      := "MNTR011"

	Private aReturn  := {STR0003, 1,STR0004, 1, 2, 1, "",1 } //"Zebrado" ## "Administração"
	Private nLastKey := 0
	Private Tamanho  := "G"
	Private cPerg    := "MNT011"
	Private nomeprog := "MNTR011"
	Private cReturnXB:= " "
	Private nPERFIXO := GetMV("MV_NGCOFIX")/ 100
	Private lTolera  := NGCADICBASE("TF_TOLECON","D","STF",.F.)
	Private lCORRET  := .F.
	Private Titulo   := STR0005 //"Preventivas a Vencer"
	Private lTolConE := If(NGCADICBASE("TF_MARGEM","A","STF",.F.),.t.,.F.)

    //+---------------------------------------------------------------+
    // Vetor utilizado para armazenar retorno da função MNT045TRB,	  |
    // criada de acordo com o item 18 (RoadMap 2013/14)				  |
    //+---------------------------------------------------------------+
	Private vFilTRB := MNT045TRB()

	SetKey(VK_F4, {|| MNT045FIL( vFilTRB[2] )})

	nServico := TAMSX3("T4_SERVICO")[1]
	nCodBem  := TAMSX3("T9_CODBEM ")[1]
	nCCUSTO  := TAMSX3("CTT_CUSTO ")[1]
	nCTRAB   := TAMSX3("HB_COD    ")[1]

	Pergunte(cPerg,.F.)

	wnrel := SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"")

	SetKey(VK_F4, {|| })

	If nLastKey = 27
		Set Filter To
		dbSelectArea("STF")
		MNT045TRB( .T., vFilTRB[1], vFilTRB[2])
		NGRETURNPRM(aNGBEGINPRM)
		Return
	Endif

	Titulo := STR0012 + AllTrim(Str(MV_PAR01)) + STR0013 + AllTrim(Str(MV_PAR02)) //+ STR0014 //"Preventivas a Vencer de "###" a "###" horas"

	SetDefault(aReturn,cString)
	RptStatus({|lEnd| MNT011Imp(@lEnd,wnRel,titulo,tamanho)},titulo)

	dbSelectArea("STF")

	MNT045TRB( .T., vFilTRB[1], vFilTRB[2])

	NGRETURNPRM(aNGBEGINPRM)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNT011Imp ³ Autor ³ Vitor Emanuel Batista ³ Data ³15/04/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Chamada do Relat¢rio                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR011                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNT011Imp(lEND,WNREL,TITULO,TAMANHO)

	Local nX
	Local nCntImpr   := 0
	Local nRecno     := 0
	Local nSort      := 2
	Local lToleCont  := .F.
	Local lToleTempo := .F.
	Local nRec       := 0   // Posiciona o registro na impressao do relatorio
	Local cCont      := ""  // Contador do bem
	Local lSkip      := .F. // Indica se j' ocorreu o dbSkip
	Local lImpCar    := .F.
	Local aIND		 := {}
	Local oTmpTbl1

	Private li 			:= 80 ,m_pag := 1
	Private cRODATXT    := ""
	Private aVETINR     := {}
	Private nTIPO       := IIF(aReturn[4] == 1, 15, 18)
	Private lImpTotal   := .F.
	Private lContManu   := .T.
	Private cTRB	    := GetNextAlias() //Alias Tab. 1

	If lTolConE
		// Especifico para Locar
		nSort := 3
		CABEC1 := STR0029//" Contador Bem              Descrição                      Serviço  Sequencia        Contador Atual     Tolerância/Dias    Prox. Manutenção   Dt. Prox. Man."
	Else
		If MV_PAR03 $ 'A/Z'
			lToleTempo := .T.
			lToleCont  := .T.
			CABEC1 := STR0015 //" Contador Bem              Descrição                      Serviço  Sequencia        Contador Atual   Tolerância Tempo  Tolerância Cont.     Prox. Manutenção   Dt. Prox. Man."
		ElseIf MV_PAR03 $ 'T'
			lToleTempo := .T.
			CABEC1 := STR0016 //" Contador Bem              Descrição                      Serviço  Sequencia        Contador Atual   Tolerância Tempo  Prox. Manutenção   Dt. Prox. Man."
		Else
			lToleCont  := .T.
			nSort := 3
			CABEC1 := STR0017 //" Contador Bem              Descrição                      Serviço  Sequencia        Contador Atual   Tolerância Cont.     Prox. Manutenção   Dt. Prox. Man."
		EndIf
	EndIf

	CABEC2 := " "

	cAliasQry := GetNextAlias()
	cQuery := " SELECT STF.TF_CODBEM, STF.TF_SERVICO, STF.TF_SEQRELA, STF.TF_TOLERA, STF.TF_TOLECON,"
	cQuery += "        ST9.T9_CCUSTO, ST9.T9_CENTRAB, ST9.T9_CODFAMI"
	cQuery += " FROM "+RetSqlName("STF")+" STF "
	cQuery += " INNER JOIN "+RetSqlName("ST9")+" ST9 ON STF.TF_CODBEM = ST9.T9_CODBEM AND "
	cQuery +=                "'"+xFilial("ST9")+"' = ST9.T9_FILIAL AND ST9.D_E_L_E_T_ != '*'"
	cQuery += " WHERE STF.TF_FILIAL = '"+xFilial("STF")+"' AND STF.TF_CODBEM  >='"+MV_PAR10+"'  AND"

	If lTolConE
		If MV_PAR03 != 'Z'
			cQuery += " STF.TF_TIPACOM = '" + MV_PAR03 + "' AND"
		EndIf
		cQuery += " STF.TF_TOLERA BETWEEN '" + Alltrim(Str(MV_PAR01))+"' AND '"+  Alltrim(Str(MV_PAR02)) + "' AND"
	Else
		If MV_PAR03 != 'Z'
			cQuery += " STF.TF_TIPACOM = '" + MV_PAR03+"' AND"
			If lToleTempo
				cQuery += " STF.TF_TOLERA BETWEEN '"+Alltrim(Str(MV_PAR01))+"' AND '"+Alltrim(Str(MV_PAR02))+"' AND"
			EndIf
			If lToleCont
				cQuery += " STF.TF_TOLECON BETWEEN '"+Alltrim(Str(MV_PAR01))+"' AND '"+Alltrim(Str(MV_PAR02))+"' AND"
			EndIf
		EndIf
	EndIf

	cQuery += "       STF.TF_CODBEM  <= '" + MV_PAR11 + "' AND STF.TF_SERVICO >= '" + MV_PAR12 + "'  AND"
	cQuery += "       STF.TF_SERVICO <= '" + MV_PAR13 + "' AND ST9.T9_CCUSTO  >= '" + MV_PAR04 + "' AND"
	cQuery += "       ST9.T9_CCUSTO  <= '" + MV_PAR05 + "' AND ST9.T9_CENTRAB >= '" + MV_PAR06 + "' AND"
	cQuery += "       ST9.T9_CENTRAB <= '" + MV_PAR07 + "' AND ST9.T9_CODFAMI >= '" + MV_PAR08 + "' AND"
	cQuery += "       ST9.T9_CODFAMI <= '" + MV_PAR09 + "' AND STF.TF_ATIVO = 'S' AND"
	cQuery += "       ST9.T9_SITBEM = 'A' AND ST9.T9_SITMAN = 'A' AND STF.D_E_L_E_T_ != '*'"
	cQuery += " ORDER BY ST9.T9_CCUSTO, ST9.T9_CENTRAB, ST9.T9_CODFAMI"

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .F.)

	/*
	P                                                   M                                                                                       G
	*****************************************************************************************************************************************************************************************************************************
	1         2         3         4         5         6         7         8         9       100       110       120       130       140       150       160       170       180       190       200       210       220
	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	*****************************************************************************************************************************************************************************************************************************
	Contador Bem              Descrição                      Serviço  Sequencia        Contador Atual   Tolerância Tempo  Tolerância Cont.     Prox. Manutenção   Dt. Prox. Man.
	Contador Bem              Descrição                      Serviço  Sequencia        Contador Atual   Tolerância Tempo  Prox. Manutenção   Dt. Prox. Man.
	Contador Bem              Descrição                      Serviço  Sequencia        Contador Atual   Tolerância Cont.     Prox. Manutenção   Dt. Prox. Man.
	*****************************************************************************************************************************************************************************************************************************
	99/99/99
	Centro de Custo: XXXXXXXXX  XXXXXXXXXXXXXXXXXXXX  Centro de Trabalho: XXXXXXXXX  XXXXXXXXXXXXXXXXXXXX
	XXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXX   XXXXXXXXXXXXXXXXcXXXXXXXXXXXXX XXX  99/99/9999    99/99/9999     XXXXXX

	*/

	dbSelectArea(cAliasQry)
	aStruct := DbStruct()

	oTmpTbl1 := FWTemporaryTable():New(cTRB, aStruct) 
	oTmpTbl1:AddIndex( "Ind01" , {"T9_CCUSTO", "T9_CENTRAB", "T9_CODFAMI"} )
	oTmpTbl1:Create()

	dbSelectArea(cAliasQry)
	dbGoTop()

	While !Eof()

		NGIFDICIONA("STF",xFilial("STF")+(cAliasQry)->(TF_CODBEM+TF_SERVICO+TF_SEQRELA),1)
		If NG120CHK("V")
			nRecno++
			RecLock(cTRB,.T.)
			(cTRB)->TF_CODBEM   := (cAliasQry)->TF_CODBEM
			(cTRB)->TF_SERVICO  := (cAliasQry)->TF_SERVICO
			(cTRB)->TF_SEQRELA  := (cAliasQry)->TF_SEQRELA
			(cTRB)->TF_TOLERA   := (cAliasQry)->TF_TOLERA
			(cTRB)->TF_TOLECON  := (cAliasQry)->TF_TOLECON
			(cTRB)->T9_CCUSTO   := (cAliasQry)->T9_CCUSTO
			(cTRB)->T9_CENTRAB  := (cAliasQry)->T9_CENTRAB
			(cTRB)->T9_CODFAMI  := (cAliasQry)->T9_CODFAMI
			MsUnLock(cTRB)
		EndIf
		dbSelectArea(cAliasQry)
		dbSkip()
	EndDo

	(cAliasQry)->(DbCloseArea())

	dbSelectArea(cTRB)
	dbGoTop()
	If EoF()
		oTmpTbl1:Delete()//Deleta tablera temporária
		MsgInfo(STR0026, STR0007) //"Não existem dados para montar o relatório."###"ATENÇÃO"
		Return .F.
	EndIf

	SetRegua(nRecno)
	nRec := 0

	While !EoF()

		NGSOMALI(58)
		cCCT := (cTRB)->(T9_CCUSTO+T9_CENTRAB)
		@LI,000 Psay Replicate("-",175)

		NGSOMALI(58)
		@LI,000 Psay STR0018 + (cTRB)->T9_CCUSTO //"Centro de Custo: "
		@LI,038 Psay NGSEEK('CTT',(cTRB)->T9_CCUSTO,1,'Substr(CTT_DESC01,1,20)')

		If !Empty((cTRB)->T9_CENTRAB)
			@LI,074 Psay STR0019 + (cTRB)->T9_CENTRAB //"Centro de Trabalho: "
			@LI,105 Psay NGSEEK('SHB',(cTRB)->T9_CENTRAB,1,'Substr(HB_NOME,1,20)')
			lImpTotal := .T.
		EndIf

		nTotCC := 0
		nTotCT := 0
		cCC := Space(2) + NGSEEK('CTT',(cTRB)->T9_CCUSTO,1,'Substr(CTT_DESC01,1,20)')
		cCT := Space(2) + NGSEEK('SHB',(cTRB)->T9_CENTRAB,1,'Substr(HB_NOME,1,20)')

		While !Eof() .And. cCCT == (cTRB)->(T9_CCUSTO+T9_CENTRAB)

			lSkip := .F.

			nTotCC++
			nTotCT++

			NGSOMALI(58)

			cFamilia := Space(2) + NGSEEK('ST6',(cTRB)->T9_CODFAMI,1,'Substr(T6_NOME,1,20)')

			@LI,000 Psay STR0020 + (cTRB)->T9_CODFAMI + cFamilia	Picture "@!" //"Família: "

			NGSOMALI(58)

			cFAM := (cTRB)->T9_CODFAMI
			aFAM := {}
			While !Eof() .And. cFAM == (cTRB)->T9_CODFAMI
				IncRegua()
				nRec++
				aAdd(aFAM,{(cTRB)->(TF_CODBEM+TF_SERVICO+TF_SEQRELA),(cTRB)->TF_TOLERA,(cTRB)->TF_TOLECON})
				lSkip := .T.
				dbSkip()
			EndDo

			aFAM := aSort(aFAM,,,{|x,y| x[nSort] < y[nSort]})

			NGSOMALI(58)

			For nX := 1 to Len(aFAM)

				NGIFDICIONA("STF", xFilial("STF") + aFAM[nX][1], 1)
				NGIFDICIONA("ST9", xFilial("ST9") + STF->TF_CODBEM, 1)

				If MNT045STB( STF->TF_CODBEM, vFilTRB[2] )
					dbSkip()
					Loop
				EndIf

				lImpCar := .T.

				dProxManu :=  NGXPROXMAN(STF->TF_CODBEM)

				// Caso seja por contador, imprime se e' o 1 ou o 2
				If STF->TF_TIPACOM = "C"
					cCont := "1"
				ElseIf STF->TF_TIPACOM = "S"
					cCont := "2"
				Else
					cCont := "--"
				EndIf

				@LI,008 - Len( Alltrim(cCont) ) Psay cCont Picture "@!"

				@LI,009 Psay STF->TF_CODBEM  Picture "@!"
				@LI,026 Psay NGSEEK('ST9',STF->TF_CODBEM,1,'Substr(T9_NOME,1,28)')  Picture "@!"
				@LI,057 Psay STF->TF_SERVICO  Picture "@!"
				//@LI,056 Psay NGSEEK('ST4',STF->TF_SERVICO,1,'Substr(T4_NOME,1,30)')  Picture "@!"
				@LI,075-Len(Alltrim(STF->TF_SEQRELA)) Psay STF->TF_SEQRELA Picture "@!"

				If cCont == "2"
					dbSelectArea("TPE")
					dbSetOrder(1)
					If dbSeek(xFilial("TPE")+STF->TF_CODBEM)
						@LI,082 Psay Transform( TPE->TPE_CONTAC , "@E 999,999,999,999")
					EndIf
				Else
					@LI,082 Psay Transform( ST9->T9_CONTACU , "@E 999,999,999,999")
				EndIf

				//n := 0
				If lTolConE
					@LI,105 Psay Transform( STF->TF_TOLERA , "@E 999,999,999")
				ElseIf lToleTempo
					@LI,110 Psay Transform( STF->TF_TOLERA , "999999")
				EndIf

				IIF(lToleTempo .And. lToleCont,n:=20,n:=0)

				If lToleCont
					@LI,105+n Psay Transform( STF->TF_TOLECON , "@E 999,999,999")
				EndIf
				@LI,119+n Psay Transform( STF->TF_CONMANU + STF->TF_INENMAN, "@E 999,999,999,999")
				@LI,141+n Psay DTOC(dProxManu) Picture "99/99/9999"
				NGSOMALI(58)
			Next nX

			NGSOMALI(58)
			@LI,000 Psay STR0021 +":"+cFamilia +": "+ AllTrim(Str(Len(aFAM))) //"Total da Família"

			dbSelectArea(cTRB)
			If !lSkip
				dbSkip()
			EndIf
		EndDo

		If nTotCC > 0
			NGSOMALI(58)
			@LI,000 Psay STR0027+"......:"+cCC+": "+AllTrim(Str(nTotCC))  //"Total C.C."
			If lImpTotal
				NGSOMALI(58)
				@LI,000 Psay STR0028+"......:"+cCT+": "+AllTrim(Str(nTotCT))  //"Total C.T."
			EndIf
		EndIf
		lImpTotal := .F.
		NGSOMALI(58)
		dbSelectArea(cTRB)
		dbGoTo(nRec)
		dbSkip()
	EndDo

	dbSelectArea(cTRB)
	oTmpTbl1:Delete()

	If lImpCar
		Roda(nCntImpr,cRodaTxt,Tamanho)
	Else
		MsgInfo(STR0026, STR0007)
		Return .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Devolve a condicao original do arquivo principal             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RetIndex("STF")
	Set Filter To
	Set device to Screen
	If aReturn[5] = 1
		Set Printer To
		dbCommitAll()
		OurSpool(wnrel)
	EndIf

	MS_FLUSH()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MNTR11XB  ³ Autor ³Vitor Emanuel Batista  ³ Data ³16/04/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consulta especifica dos tipos de acompanhamento             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR011                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTR11XB()

	Local i,j
	Local nInd := 0
	Local oOrdem, oChave, oPanel
	Local cChave     := Space(1)
	Local aCabec
	Local oTmpTbl2

	Private nOrdem   := 1
	Private nOpcaXB  := 0
	Private aIndices := {}
	Private /*cAliasXB,*/ cOrdIx
	Private oLbx,oDlg2
	//TABELA TEMPORARIA
	Private cAliasXB := GetNextAlias()

	aDbf := { {"CODIGO"  , "C", 01,0},;
	{"DESCRI"  , "C", 20,0} }

	//Intancia classe FWTemporaryTable
	oTmpTbl2 := FWTemporaryTable():New( cAliasXB, aDbf )
	//Cria indices
	oTmpTbl2:AddIndex( "Ind01" , {"CODIGO"} )

	//Cria a tabela temporaria
	oTmpTbl2:Create()

	aTipo := {  {'A',NGRETSX3BOX("TF_TIPACOM","A")},; //'Tempo/Contador'
	{'C',NGRETSX3BOX("TF_TIPACOM","C")},; //'Contador'
	{'F',NGRETSX3BOX("TF_TIPACOM","F")},; //'Contador Fixo'
	{'P',NGRETSX3BOX("TF_TIPACOM","P")},; //'Producao'
	{'S',NGRETSX3BOX("TF_TIPACOM","S")},; //'Segundo Contador'
	{'T',NGRETSX3BOX("TF_TIPACOM","T")},; //'Tempo'
	{'Z','Todos'}}

	dbSelectArea(cAliasXB)
	For j := 1 to Len(aTipo)
		RecLock((cAliasXB),.T.)
		(cAliasXB)->CODIGO := aTipo[j][1]
		(cAliasXB)->DESCRI := aTipo[j][2]
		MsUnlock(cAliasXB)
	Next j

	cLine := "{ || { "
	i     := 0
	aAux  := {}
	aLbx  := {}

	// Monta os dados do listbox
	dbSelectArea(cAliasXB)
	aFields := DBSTRUCT()
	aCabec  := {STR0023,STR0024} //"Código"###"Descrição"

	dbGotop()
	While !Eof()
		aAux := ARRAY(Len(aFields))
		For j := 1 to Len(aFields)
			aAux[j] := &(aFields[j][1])
		Next j
		aAdd(aLbx,aAux)
		dbSkip()
	EndDo

	nTAMB := Len(aLbx)

	// Define o numero de colunas do listbox
	For i := 1 To Len(aDbf)
		If aDbf[i][2] == "D"
			cLine+= "DtoC(aLbx[oLbx:nAt,"+Alltrim(str(i,2))+"])"
		ElseIf aDbf[i][2] == "N"
			cLine+= "Str(aLbx[oLbx:nAt,"+Alltrim(str(i,2))+"])"
		Else
			cLine+= "aLbx[oLbx:nAt,"+Alltrim(str(i,2))+"]"
		EndIf
		If i#Len(aDbf)
			cLine+=","
		Else
			cLine+="}"
		EndIf
	Next i

	cLine+= "}"
	nGuarda := 1
	nOrdem  := 1

	aAdd(aIndices,STR0023) //"Código"

	Define MsDialog oDlg2 Title STR0011 From 000,000 To 421,522 Pixel //"Tipos de Acompanhamento"

	@ 020,020 MSPANEL oPanel OF oDlg2

	@ 005, 005 combobox oOrdem var cOrdIx items aIndices size 210,08 PIXEL OF oDlg2 ON CHANGE nOrdem := oOrdem:nAt
	@ 020, 005 msget oChave var cChave size 210,08 of oDlg2 pixel
	@ 005, 220 Button STR0025 of oDlg2 Size 40,10 Pixel Action MNTR11PES(cChave) //"&Pesquisar"

	oLbx:= TWBrowse():New(3,0,263,149,,aCabec,, oDlg2,,,,,,,,,,,, .F.,, .F.,, .F.,,, )

	oLbx:SetArray(aLbx)
	oLbx:bLine := &(cline)
	oLbx:nAt   := nGuarda
	oLbx:bLDblClick := {|| (nOpcaXB := 1,nGuarda:=oLbx:nAt,oDlg2:End()) }

	Define sButton oBtOk  from 195, 05 type 1 action (nOpcaXB := 1,nGuarda := oLbx:nAt, oDlg2:End()) enable of oDlg2 pixel
	Define sButton oBtCan from 195, 36 type 2 action (nOpcaXB := 0, oDlg2:End()) enable of oDlg2 pixel

	ACTIVATE MSDIALOG oDlg2 ON INIT AlignObject(oDlg2,{oPanel},1,,{100}) CENTERED

	If nOpcaXB == 1
		dbGoTo(nGuarda)
		cReturnXB := (cAliasXB)->CODIGO
	Else
		cReturnXB := " "
	Endif

	dbSelectArea(cAliasXB)
	
	//Deleta Arquivo temporario 1
	oTmpTbl2:Delete()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MNTR11PES ³ Autor ³Vitor Emanuel Batista ³ Data ³16/04/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta a tela de pesquisa especifica.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR011                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNTR11PES(cCHPesq)

	Local cSeek := Upper(SubStr(cCHPesq,1,1))
	Local nOrdem := 0

	dbGoTop()
	While !EoF()
		nOrdem++
		If cSeek == (cAliasXB)->CODIGO
			Exit
		EndIf
		dbSkip()
	EndDo

	oLbx:SetFocus(aLbx[nOrdem])

	oLbx:nAt   := nOrdem
	oLbx:bLine := &(cline)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR011VTA

Função para validação do parâmetro 'Tipo de Acompanhamento.
@author William Rozin Gaspar
@since 06/12/13
@return lReturn
/*/
//---------------------------------------------------------------------
Function MNTR011VTA()
	Local lReturn := .T.

	If !(MV_PAR03 $ "TCAPFSZ")
		ShowHelpDLG( STR0007, {STR0060}, 2, {STR0061}, 2)
		lReturn := .F.
	EndIf
Return lReturn