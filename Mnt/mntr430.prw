#INCLUDE "MNTR430.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTR430   ³ Autor ³ Ricardo Dal Ponte     ³ Data ³ 14/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio de multas de transporte de produtos perigosos     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/      
Function MNTR430() 
 
	Private cAliasQry  := GetNextAlias()
	Private NOMEPROG := "MNTR430"
	Private TAMANHO  := "G"
	Private aRETURN  := {STR0001,1,STR0002,1,2,1,"",1} //"Zebrado"###"Administracao"
	Private TITULO   := STR0003 //"Relatório de Multas de Transporte de Produtos Perigosos."
	Private nTIPO    := 0
	Private nLASTKEY := 0
	Private CABEC1,CABEC2 
	Private aVETINR := {}    
	Private cPERG := "MNT430"   
	Private aPerg :={}

	SetKey( VK_F9, { | | NGVersao( "MNTR430" , 1 ) } )

	WNREL      := "MNTR430"
	LIMITE     := 220
	cDESC1     := STR0004 //"O relatório apresentará as multas para transporte de "
	cDESC2     := STR0005 //"produtos perigosos em determinado período."
	cDESC3     := ""
	cSTRING    := "TRH"      

	Pergunte(cPERG,.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	WNREL:=SetPrint(cSTRING,WNREL,cPERG,TITULO,cDESC1,cDESC2,cDESC3,.F.,"")
	If nLASTKEY = 27
		Set Filter To
		DbSelectArea("TRH")  
		Return
	EndIf     
	SetDefault(aReturn,cSTRING)
	RptStatus({|lEND| MNTR430IMP(@lEND,WNREL,TITULO,TAMANHO)},STR0012,STR0013) //"Aguarde..."###"Processando Registros..."
	Dbselectarea("TRH")  

Return .T.    

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |MNT430IMP | Autor ³ Ricardo Dal Ponte     ³ Data ³ 08/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Chamada do Relat¢rio                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR430                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTR430IMP(lEND,WNREL,TITULO,TAMANHO) 
	Local nI
	Local lIntTMS := GetMV("MV_INTTMS")
	Private cRODATXT := ""
	Private nCNTIMPR := 0     
	Private li := 80 ,m_pag := 1    
	Private cNomeOri
	Private aVetor := {}
	Private aTotGeral := {}
	Private nAno, nMes 
	Private nTotCarga := 0, nTotManut := 0 
	Private nTotal := 0

	Processa({|lEND| MNTR430TMP()},STR0014) //"Processando Arquivo..."

	nTIPO  := IIf(aReturn[4]==1,15,18)                                                                                                                                                                                               

	CABEC1 := ""
	CABEC2 := ""   

	lPri := .T.  

	SetRegua(LastRec())

	If !Eof()
		While !Eof()
			IncProc()

			If lPri = .T.  
				NgSomaLi(58)
				@ Li,000 	 Psay STR0015 //"Filial"
				@ Li,030 	 Psay STR0016 //"Dt.Infr."
				@ Li,042 	 Psay STR0017 //"Hh.Infr."
				@ Li,052 	 Psay STR0018 //"AIT Nr.Infracao"
				@ Li,068 	 Psay STR0019 //"Orgao Autuador"
				@ Li,095 	 Psay STR0020 //"Motorista"
				@ Li,122 	 Psay STR0021 //"Frota"
				@ Li,149 	 Psay STR0022 //"Placa"
				@ Li,161 	 Psay STR0023 //"Tipo"
				@ Li,173 	 Psay STR0024 //"Local"
				@ Li,200 	 Psay STR0025 //"UF"
				@ Li,204 	 Psay STR0026 //"Cod. Infracao"

				NgSomaLi(58)
				@ Li,000 	 Psay Replicate("-",220)
				NgSomaLi(58) 

				lPri := .F.  
			EndIf

			dbSelectArea("SM0")
			dbSetorder(1)

			cDesFil := ""
			If dbSeek(cEmpAnt+(cALIASQRY)->TRX_FILIAL)
				cDesFil := SM0->M0_FILIAL
			EndIf

			cDTINFR := Substr((cALIASQRY)->TRX_DTINFR, 7, 2)+;
			"/"+;
			Substr((cALIASQRY)->TRX_DTINFR, 5, 2)+;
			"/"+;
			Substr((cALIASQRY)->TRX_DTINFR, 1, 4)

			@ Li,000 	 Psay (cALIASQRY)->TRX_FILIAL + " - " + Substr(cDesFil, 1, 24)
			@ Li,030 	 Psay cDTINFR Picture "99/99/9999"
			@ Li,042 	 Psay (cALIASQRY)->TRX_RHINFR Picture "99:99"
			@ Li,052 	 Psay (cALIASQRY)->TRX_NUMAIT Picture "@E"
			@ Li,068 	 Psay Substr((cALIASQRY)->TRZ_NOMOR,1 ,25)  Picture "@E"
			@ Li,095 	 Psay Substr((cALIASQRY)->DA4_NOME,1 ,25)   Picture "@E"

			cDesFrota := ""
			cDesTipo  := ""

			If lIntTMS := .T.	
				dbSelectArea("DA3")
				dbSetOrder(3)

				If dbSeek(xFilial("DA3")+(cALIASQRY)->TRX_PLACA)
					cDesFrota := DA3->DA3_COD

					If DA3->DA3_FROVEI = "1"
						cDesTipo := STR0027 //"Proprio"
					ElseIf DA3->DA3_FROVEI = "2"
						cDesTipo := STR0028 //"Terceiro"
					ElseIf DA3->DA3_FROVEI = "3"
						cDesTipo := STR0029 //"Agregado"
					EndIf
				EndIf
			Else
				dbSelectArea("ST9")
				dbSetOrder(1)

				If dbSeek(xFilial("DA3")+(cALIASQRY)->TRX_PLACA)
					If ST9->T9_CATBEM = "2"
						cDesFrota := ST9->T9_CODBEM
					EndIf
				EndIf
			EndIf

			@ Li,122 	 Psay Substr(cDesFrota, 1, 25) Picture "@E"
			@ Li,149 	 Psay Substr((cALIASQRY)->TRX_PLACA, 1, 8)  Picture "@E"
			@ Li,161 	 Psay Substr(cDesTipo, 1, 25) Picture "@E"
			@ Li,173 	 Psay Substr((cALIASQRY)->TRX_LOCAL, 1, 25)  Picture "@E"
			@ Li,200 	 Psay Substr((cALIASQRY)->TRX_UFINF, 1, 2)  Picture "@E"
			@ Li,204 	 Psay Substr((cALIASQRY)->TRX_CODINF, 1, 15) Picture "@E"

			NgSomaLi(58)

			cAliasQry2  := GetNextAlias()
			cQuery2 := " SELECT DT6.DT6_DOC "
			cQuery2 += " FROM " + RetSqlName("DT6") + " DT6 "
			cQuery2 += " WHERE DT6.DT6_NUMVGA IN (SELECT DTR.DTR_VIAGEM FROM " + RetSqlName("DTR") + " DTR "
			cQuery2 += " WHERE (DTR.DTR_DATINI <= '" + (cALIASQRY)->TRX_DTINFR + "'"
			cQuery2 += " AND   DTR.DTR_DATFIM  >= '" + (cALIASQRY)->TRX_DTINFR + "') AND DTR.D_E_L_E_T_ <> '*'"
			cQuery2 += " AND   DTR.DTR_CODVEI IN (SELECT T9_CODTMS FROM "+ RetSqlName("ST9") + " ST9 "
			cQuery2 += " WHERE T9_PLACA = '" + (cALIASQRY)->TRX_PLACA + "' AND ST9.D_E_L_E_T_ <> '*' ))"
			cQuery2 += " AND   DT6.D_E_L_E_T_ <> '*' "
			cQuery2 := ChangeQuery(cQuery2)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery2),cAliasQry2, .F., .T.) 
			dbSelectArea(cAliasQry2)
			dbGotop()
			If !Eof()
				@ Li,000 	 Psay STR0033 //"Notas Fiscais:"
				While !Eof()
					@ Li,015 	 Psay (cALIASQRY2)->DT6_DOC
					NgSomaLi(58)
					dbSkip()
				End
			Endif
			(cALIASQRY2)->(dbCloseArea())

			dbSelectArea(cAliasQry)			   
			dbSkip()
		End 
	Else
		MsgInfo(STR0031,STR0032) //"Não existem dados para montar o relatório!"###"ATENÇÃO"
		Return .f.
	End
	(cALIASQRY)->(dbCloseArea())

	RODA(nCNTIMPR,cRODATXT,TAMANHO)       

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Devolve a condicao original do arquivo principal             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RetIndex('TRH')
	Set Filter To
	Set Device To Screen
	If aReturn[5] == 1
		Set Printer To
		dbCommitAll()
		OurSpool(WNREL)
	EndIf
	MS_FLUSH()

Return Nil  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNR430FL  ³ Autor ³Ricardo Dal Ponte      ³ Data ³ 09/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³validação do parametro Filial                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR430                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function MNR430FL(nOpc)
	Local cVERFL

	cVERFL := Mv_Par03

	If Empty(mv_par03) .And. (mv_par04 == 'ZZ')
		Return .t.
	Else
		If nOpc == 1
			lRet := IIf(Empty(Mv_Par03),.t.,ExistCpo('SM0',SM0->M0_CODIGO+Mv_Par03))
			If !lRet
				Return .f.
			EndIf
		EndIf

		If nOpc == 2
			lRet := IIF(ATECODIGO('SM0',SM0->M0_CODIGO+Mv_Par03,SM0->M0_CODIGO+Mv_Par04,07),.T.,.F.)
			If !lRet
				Return .f.
			EndIf
		EndIf
	EndIf

Return .t. 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNT430DT  ³ Autor ³Ricardo Dal Ponte      ³ Data ³ 14/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida o parametro ate data                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR430                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNT430DT()
	If  MV_PAR02 < MV_PAR01
		MsgStop(STR0030)  //"Data final não pode ser inferior à data inicial!"
		Return .F.  
	EndIf
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |MNTR430TMP| Autor ³ Ricardo Dal Ponte     ³ Data ³ 08/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Geracao do arquivo temporario                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR430                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTR430TMP()

	cQuery := " SELECT TRX.TRX_FILIAL, TRX.TRX_DTINFR, TRX.TRX_RHINFR, TRX.TRX_NUMAIT, "
	cQuery += "        TRX.TRX_PLACA , TRX.TRX_LOCAL , TRX.TRX_UFINF , TRX.TRX_CODINF, "
	cQuery += "        TSH.TSH_FLGTPM, TRX.TRX_CODOR ,  TRZ.TRZ_NOMOR, "
	cQuery += "        TRX.TRX_CODMO , DA4.DA4_NOME  "
	cQuery += " FROM " + RetSqlName("TSH")+" TSH, " + RetSqlName("TRX")+" TRX "
	cQuery += "	LEFT JOIN " + RetSQLName("TRZ") + " TRZ ON TRX.TRX_FILIAL  = TRZ.TRZ_FILIAL "
	cQuery += "	AND TRX.TRX_CODOR   = TRZ.TRZ_CODOR "
	cQuery += "	AND TRZ.D_E_L_E_T_ <> '*' "
	cQuery += "	LEFT JOIN " + RetSQLName("DA4") + " DA4 ON DA4.DA4_COD = TRX.TRX_CODMO "
	cQuery += "	AND DA4.D_E_L_E_T_ <> '*' "
	cQuery += " WHERE "
	cQuery += "      (TRX.TRX_DTINFR >= '"+AllTrim(DTOS(MV_PAR01))+"'"
	cQuery += " AND   TRX.TRX_DTINFR <= '"+AllTrim(DTOS(MV_PAR02))+"')"
	cQuery += " AND   TRX.TRX_FILIAL >= '"+MV_PAR03+"'"
	cQuery += " AND   TRX.TRX_FILIAL <= '"+MV_PAR04+"'"
	cQuery += " AND   TRX.TRX_CODOR  >= '"+MV_PAR05+"'"
	cQuery += " AND   TRX.TRX_CODOR  <= '"+MV_PAR06+"'"
	//cQuery += " AND   TSH.TSH_FILIAL  = TRX.TRX_FILIAL"
	cQuery += " AND   TSH.TSH_CODINF  = TRX.TRX_CODINF" 
	/*If Upper(_cGetDB) == "ORACLE"
	cQuery += " AND   TRX.TRX_FILIAL  = TRZ.TRZ_FILIAL (+)"
	cQuery += " AND   TRX.TRX_CODOR   = TRZ.TRZ_CODOR  (+)"
	cQuery += " AND   DA4.DA4_COD     = TRX.TRX_CODMO  (+)"
	Else
	cQuery += " AND   TRX.TRX_FILIAL  *= TRZ.TRZ_FILIAL "
	cQuery += " AND   TRX.TRX_CODOR   *= TRZ.TRZ_CODOR  "
	cQuery += " AND   DA4.DA4_COD     *= TRX.TRX_CODMO  "
	Endif*/
	cQuery += " AND   TSH.TSH_FLGTPM  = '2'"
	cQuery += " AND   TRX.D_E_L_E_T_ <> '*' "
	cQuery += " AND   TSH.D_E_L_E_T_ <> '*' "
	cQuery += "       ORDER BY TRX.TRX_FILIAL, TRX.TRX_DTINFR, TRX.TRX_RHINFR "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)  

	dbSelectArea(cAliasQry)			   
	dbGoTop()

Return