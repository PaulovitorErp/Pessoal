#INCLUDE "MNTR235.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MNTR235  ³ Autor ³ Marcos Wagner Junior  ³ Data ³ 06/02/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de M-D-O Aplicada Por Fornecedor                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³OBSERVACAO³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTR235                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNTR235()

	Local WNREL      := "MNTR235"
	Local LIMITE     := 132
	Local cDESC1     := STR0001 //"Relatório de M-D-O Aplicada Por Fornecedor"
	Local cDESC2     := " "
	Local cDESC3     := " "
	Local cSTRING    := "STJ"

	Private cTRB 	 := GetNextAlias()
	Private NOMEPROG := "MNTR235"
	Private TAMANHO  := "M"
	Private aRETURN  := {STR0002,1,STR0003,1,2,1,"",1}   //"Zebrado"###"Administracao"
	Private TITULO   := STR0001 //"Relatório de M-D-O Aplicada Por Fornecedor"
	Private nTIPO    := 0
	Private nLASTKEY := 0
	Private cPERG    := "MNR235"
	Private CABEC1
	Private CABEC2

	PERGUNTE(cPERG,.F.)

	//Envia controle para a funcao SETPRINT
	WNREL:=SETPRINT(cSTRING,WNREL,cPERG,TITULO,cDESC1,cDESC2,cDESC3,.F.,"")
	If nLASTKEY = 27
		SET FILTER TO
		Dbselectarea("STL")
		Return
	Endif
	SETDEFAULT(aRETURN,cSTRING)

	RPTSTATUS({|lEND| MNTR235IMP(@lEND,WNREL,TITULO,TAMANHO)},TITULO)
Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNTR235IMP³ Autor ³ Marcos Wagner Junior  ³ Data ³ 20/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do Relat¢rio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTR235                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTR235IMP(lEND,WNREL,TITULO,TAMANHO)

	Local cRODATXT := ""
	Local nCNTIMPR := 0
	Local nI := 0
	Local lSeqSTL    := NGVerify("STL")
	Local cOldFornec := ''
	Local nTotHoFor  := 0
	Local nTotCusFor := 0
	Local nTotHoGer  := 0
	Local nTotCusGer := 0
	Local cPictuCus  := X3Picture( 'TL_CUSTO' )
	Local oARQTRVCR

	Private li     := 80 ,m_pag := 1
	Private aVETINR := {}
	nTIPO          := IIf(aRETURN[4]==1,15,18)

	aPos1 := {15,1,95,315 }
	aDBFRVCR := {{"FORNEC", "C", TAMSX3('A2_COD')[1],0},;
				 {"CODBEM", "C", 16, 0},;
				 {"ORDEM" , "C", 06, 0},;
				 {"DTINIC", "D", 08, 0},;
				 {"QUANTI", "N", 09, 2},;
				 {"CUSTO" ,"N", TAMSX3('TL_CUSTO')[1],TAMSX3('TL_CUSTO')[2]}}

	//Cria Tabela Temporária
	oARQTRVCR := NGFwTmpTbl(cTRB,aDBFRVCR,{{"FORNEC","ORDEM"}})

	//+-----------------------+
	//| Monta os Cabecalhos   |
	//+-----------------------+
	CABEC1 := STR0010 //"Bem               Nome                                      O.S.     Data Aplic.           Qtd.              Valor"
	CABEC2 := " "

	/*
	1         2         3         4         5         6         7         8         9         0         1
	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	Bem               Nome                                      O.S.     Data Aplic.              Qtd.                 Valor
	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

	Fornecedor: xxxxxx - xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

	xxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xxxxxx  99/99/99        999:99    99.999,99
	xxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xxxxxx  99/99/99        999:99    99.999,99

	Total Fornecedor:      99999:99   999.999,99


	Fornecedor: xxxxxx - xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

	xxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xxxxxx  99/99/99        999:99    99.999,99
	xxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xxxxxx  99/99/99        999:99    99.999,99

	Total Fornecedor:      99999:99   999.999,99
	Total Geral:           99999:99   999.999,99*/


	cAliasQry := GetNextAlias()
	cQuery := " SELECT STL.TL_CODIGO, STJ.TJ_CODBEM, STJ.TJ_ORDEM, STL.TL_DTINICI, STL.TL_QUANTID, STL.TL_CUSTO, STL.TL_TIPOHOR "
	cQuery += " FROM " + RetSqlName("STJ")+" STJ, "+ RetSqlName("STL")+" STL "
	cQuery += " WHERE STL.TL_FILIAL = STJ.TJ_FILIAL "
	cQuery += " AND   STL.TL_ORDEM  = STJ.TJ_ORDEM "
	cQuery += " AND   STL.TL_PLANO  = STJ.TJ_PLANO "
	cQuery += " AND   STL.TL_DTINICI >= '"+DTOS(MV_PAR01)+"'"
	cQuery += " AND   STL.TL_DTINICI <= '"+DTOS(MV_PAR02)+"'"
	If Upper(TcGetDb()) $ "ORACLE,DB2"		// Sinal de concatencao nesses ambientes
		cQuery += " AND   SUBSTR(STL.TL_CODIGO,1,"+AllTrim(Str(TAMSX3('A2_COD')[1]))+")  >= '"+MV_PAR03+"'"
		cQuery += " AND   SUBSTR(STL.TL_CODIGO,1,"+AllTrim(Str(TAMSX3('A2_COD')[1]))+")  <= '"+MV_PAR04+"'"
	Else
		cQuery += " AND   SUBSTRING(STL.TL_CODIGO,1,"+AllTrim(Str(TAMSX3('A2_COD')[1]))+")  >= '"+MV_PAR03+"'"
		cQuery += " AND   SUBSTRING(STL.TL_CODIGO,1,"+AllTrim(Str(TAMSX3('A2_COD')[1]))+")  <= '"+MV_PAR04+"'"
	Endif
	cQuery += " AND   STJ.TJ_CODBEM  >= '"+MV_PAR05+"'"
	cQuery += " AND   STJ.TJ_CODBEM  <= '"+MV_PAR06+"'"
	cQuery += " AND   STL.TL_TIPOREG  = 'T' "
	If lSeqSTL
		cQuery += " AND   STL.TL_SEQRELA > '0' "
	Else
		cQuery += " AND   STL.TL_SEQUENC > 0 "
	Endif
	cQuery += " AND   STJ.D_E_L_E_T_ <> '*' "
	cQuery += " AND   STL.D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY STL.TL_CODIGO, STJ.TJ_CODBEM "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	dbGotop()
	While !Eof()
		dbSelectArea((cTRB))
		RecLock((cTRB),.t.)
		(cTRB)->FORNEC := SubStr((cAliasQry)->TL_CODIGO,1,TAMSX3('A2_COD')[1])
		(cTRB)->CODBEM := (cAliasQry)->TJ_CODBEM
		(cTRB)->ORDEM  := (cAliasQry)->TJ_ORDEM
		(cTRB)->DTINIC := STOD((cAliasQry)->TL_DTINICI)
		(cTRB)->QUANTI := (cAliasQry)->TL_QUANTID
		(cTRB)->CUSTO  := (cAliasQry)->TL_CUSTO
		(cTRB)->(MsUnlock())
		dbSelectArea(cAliasQry)
		dbSkip()
	End
	(cAliasQry)->(dbCloseArea())

	cAliasQry := GetNextAlias()
	cQuery := " SELECT STT.TT_CODIGO, STS.TS_CODBEM, STS.TS_ORDEM, STT.TT_DTINICI, STT.TT_QUANTID, STT.TT_CUSTO, STT.TT_TIPOHOR "
	cQuery += " FROM " + RetSqlName("STS")+" STS, "+ RetSqlName("STT")+" STT "
	cQuery += " WHERE STT.TT_FILIAL = STS.TS_FILIAL "
	cQuery += " AND   STT.TT_ORDEM  = STS.TS_ORDEM "
	cQuery += " AND   STT.TT_PLANO  = STS.TS_PLANO "
	cQuery += " AND   STT.TT_DTINICI >= '"+DTOS(MV_PAR01)+"'"
	cQuery += " AND   STT.TT_DTINICI <= '"+DTOS(MV_PAR02)+"'"
	If Upper(TcGetDb()) $ "ORACLE,DB2"		// Sinal de concatencao nesses ambientes
		cQuery += " AND   SUBSTR(STT.TT_CODIGO,1,"+AllTrim(Str(TAMSX3('A2_COD')[1]))+") >= '"+MV_PAR03+"'"
		cQuery += " AND   SUBSTR(STT.TT_CODIGO,1,"+AllTrim(Str(TAMSX3('A2_COD')[1]))+") <= '"+MV_PAR04+"'"
	Else
		cQuery += " AND   SUBSTRING(STT.TT_CODIGO,1,"+AllTrim(Str(TAMSX3('A2_COD')[1]))+") >= '"+MV_PAR03+"'"
		cQuery += " AND   SUBSTRING(STT.TT_CODIGO,1,"+AllTrim(Str(TAMSX3('A2_COD')[1]))+") <= '"+MV_PAR04+"'"
	Endif
	cQuery += " AND   STS.TS_CODBEM  >= '"+MV_PAR05+"'"
	cQuery += " AND   STS.TS_CODBEM  <= '"+MV_PAR06+"'"
	cQuery += " AND   STT.TT_TIPOREG  = 'T' "
	If lSeqSTL
		cQuery += " AND   STT.TT_SEQRELA > '0' "
	Else
		cQuery += " AND   STT.TT_SEQUENC > 0 "
	Endif
	cQuery += " AND   STS.D_E_L_E_T_ <> '*' "
	cQuery += " AND   STT.D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY STT.TT_CODIGO, STS.TS_CODBEM "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	dbGotop()
	While !Eof()
		dbSelectArea(cTRB)
		RecLock((cTRB),.t.)
		(cTRB)->FORNEC := SubStr((cAliasQry)->TT_CODIGO,1,TAMSX3('A2_COD')[1])
		(cTRB)->CODBEM := (cAliasQry)->TS_CODBEM
		(cTRB)->ORDEM  := (cAliasQry)->TS_ORDEM
		(cTRB)->DTINIC := STOD((cAliasQry)->TT_DTINICI)
		If (cAliasQry)->TT_TIPOHOR == 'D'
			(cTRB)->QUANTI := (cAliasQry)->TT_QUANTID
		Else
			(cTRB)->QUANTI := NGCONVERHORA((cAliasQry)->TT_QUANTID,'S','D')
		Endif
		(cTRB)->CUSTO  := (cAliasQry)->TT_CUSTO
		(cTRB)->(MsUnlock())
		dbSelectArea(cAliasQry)
		dbSkip()
	End
	(cAliasQry)->(dbCloseArea())

	dbselectarea(cTRB)
	dbSetOrder(01)
	dbgotop()
	SetRegua(LastRec())
	If !Eof()
		While !Eof()
			If nI == 0
				NgSomaLi(58)
				nI++
			Endif
			If cOldFornec != (cTRB)->FORNEC
				If !Empty(cOldFornec)
					NgSomaLi(58)
					NgSomaLi(58)
					@ Li,059 PSay STR0011 //"Total Fornecedor: "
					aQtdHoras := NGRETHORDDH(nTotHoFor)
					@ Li,083 PSay PADL(aQtdHoras[1],12)
					@ Li,100 PSay Transform(Round(nTotCusFor,2),cPictuCus)
					nTotHoFor  := 0
					nTotCusFor := 0
					NgSomaLi(58)
					NgSomaLi(58)
					NgSomaLi(58)
				Endif
				@ Li,000 PSay STR0012+(cTRB)->FORNEC + ' - ' + NGSEEK("SA2",(cTRB)->FORNEC,1,'A2_NOME') //"Fornecedor: "
				NgSomaLi(58)
			Endif
			NgSomaLi(58)
			@ Li,000 PSay (cTRB)->CODBEM
			@ Li,018 PSay NGSEEK("ST9",(cTRB)->CODBEM,1,'T9_NOME')
			@ Li,060 PSay (cTRB)->ORDEM
			@ Li,069 PSay (cTRB)->DTINIC
			aQtdHoras := NGRETHORDDH((cTRB)->QUANTI)
			@ Li,086 PSay PADL(aQtdHoras[1],9)
			@ Li,102 PSay Transform(Round((cTRB)->CUSTO,2),cPictuCus)
			nTotHoFor  += (cTRB)->QUANTI
			nTotCusFor += (cTRB)->CUSTO
			nTotHoGer  += (cTRB)->QUANTI
			nTotCusGer += (cTRB)->CUSTO

			cOldFornec := (cTRB)->FORNEC
			dbSkip()
		End
		//Imprime os Totais
		NgSomaLi(58)
		NgSomaLi(58)
		@ Li,059 PSay STR0011 //"Total Fornecedor: "
		aQtdHoras := NGRETHORDDH(nTotHoFor)
		@ Li,083 PSay PADL(aQtdHoras[1],12)
		@ Li,100 PSay Transform(Round(nTotCusFor,2),cPictuCus)
		NgSomaLi(58)
		NgSomaLi(58)
		@ Li,059 PSay STR0013 //"Total Geral: "
		aQtdHoras := NGRETHORDDH(nTotHoGer)
		@ Li,083 PSay PADL(aQtdHoras[1],12)
		@ Li,100 PSay Transform(Round(nTotCusGer,2),cPictuCus)
		//Fim da impressao dos Totais
	Else
		MsgInfo(STR0014,STR0015) //"Não existem dados para montar o relatório."###"ATENÇÃO"
		Dbselectarea(cTRB)
		//Deleta o arquivo temporario fisicamente
		oARQTRVCR:Delete()
		Return .f.
	Endif

	RODA(nCNTIMPR,cRODATXT,TAMANHO)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Devolve a condicao original do arquivo principam             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RETINDEX("STJ")
	SET FILTER TO
	SET DEVICE TO SCREEN
	If aRETURN[5] == 1
		SET PRINTER TO
		dbCommitAll()
		OURSPOOL(WNREL)
	Endif
	MS_FLUSH()
	Dbselectarea(cTRB)
	//Deleta o arquivo temporario fisicamente
	//NGDELETRB("TRB",cARQTRVCR)
	oARQTRVCR:Delete()
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MNR235CC  | Autor ³Marcos Wagner Junior   ³ Data ³ 05/02/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o |Valida todos codigos De... , Ate..., com excessao da Filial ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR235                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNR235CC(nOpc,cParDe,cParAte,cTabela)

	If (Empty(cParDe) .AND. cParAte = 'ZZZZZZZZZZZZZZZZ' ) .OR. (Empty(cParDe) .AND. cParAte = Replicate('Z',TAMSX3('A2_COD')[1]) )
		Return .t.
	Else
		If nOpc == 1
			If Empty(cParDe)
				Return .t.
			Else
				lRet := IIf(Empty(cParDe),.t.,ExistCpo(cTabela,cParDe))
				If !lRet
					Return .f.
				EndIf
			Endif
		ElseIf nOpc == 2
			If (cParAte == 'ZZZZZZZZZZZZZZZZ') .OR. (cParAte = Replicate('Z',TAMSX3('A2_COD')[1]) )
				Return .t.
			Else
				lRet := IIF(ATECODIGO(cTabela,cParDe,cParAte,08),.T.,.F.)
				If !lRet
					Return .f.
				EndIf
			EndIf
		EndIf
	Endif

Return .T.