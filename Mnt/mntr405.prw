#INCLUDE "MNTR405.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTR405   ³ Autor ³ Ricardo Dal Ponte     ³ Data ³ 15/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio infracoes de transito por filial e hub - Recurso  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/      
Function MNTR405()  

	Private nSizeFil := If(FindFunction("FWSizeFilial"),FwSizeFilial(),Len(TRX->TRX_FILIAL))

	Private nPEPJQANT := 0
	Private nPEPJPEND := 0
	Private nPEPJDEFE := 0
	Private nPEPJINDE := 0
	Private nPEPJSEMR := 0

	Private nGR_PJQANT := 0
	Private nGR_PJPEND := 0
	Private nGR_PJDEFE := 0
	Private nGR_PJINDE := 0
	Private nGR_PJSEMR := 0

	Private cAliasQry  := GetNextAlias()
	Private NOMEPROG := "MNTR405"
	Private TAMANHO  := "M"
	Private aRETURN  := {STR0001,1,STR0002,1,2,1,"",1} //"Zebrado"###"Administracao"
	Private TITULO   := STR0003 //"Relatório de Infrações de Trânsito por Filial e Grupo de Filial - Recurso"
	Private nTIPO    := 0
	Private nLASTKEY := 0
	Private CABEC1,CABEC2 
	Private aVETINR := {}    
	Private cPerg := "MNT405"
	Private aPerg :={}
	Private lGera := .t.
	Private n1 := 0; n2 := 0; n3 := 0
	Private aMotorista := {}

	SetKey( VK_F9, { | | NGVersao( "MNTR405" , 1 ) } )

	WNREL      := "MNTR405"
	LIMITE     := 132
	cDESC1     := STR0004 //"Apresentará as infrações de trânsito ocorridas em um determinado "
	cDESC2     := STR0005 //"período, classificando por Grupo de Filial e por Filial. Emitindo "
	cDESC3     := STR0006 //" resumo no final de quantidade de multas recebidas por Status."
	cSTRING    := "TRH"       
	
	Pergunte(cPerg,.F.)
	
	//Envia controle para a funcao SETPRINT
	WNREL:=SetPrint(cSTRING,WNREL,cPerg,TITULO,cDESC1,cDESC2,cDESC3,.F.,"")
	If nLASTKEY = 27
		Set Filter To
		DbSelectArea("TRH")  
		Return
	EndIf     
	SetDefault(aReturn,cSTRING)
	RptStatus({|lEND| MNTR405IMP(@lEND,WNREL,TITULO,TAMANHO)},STR0015,STR0016) //"Aguarde..."###"Processando Registros..."
	Dbselectarea("TRH")  

Return .T.    

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |MNT405IMP | Autor ³ Ricardo Dal Ponte     ³ Data ³ 15/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Chamada do Relat¢rio                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR405                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTR405IMP(lEND,WNREL,TITULO,TAMANHO) 

	Local nI      
	Local oTempTable		//Tabela Temporaria
	
	Private cRODATXT   := ""
	Private nCNTIMPR   := 0     
	Private li         := 80 
	Private m_pag 	   := 1    
	Private cNomeOri
	Private aVetor     := {}
	Private aTotGeral  := {}
	Private nAno, nMes 
	Private nTotCarga  := 0
	Private nTotManut  := 0 
	Private nTotal     := 0
	Private lHub       := .F.
	Private lFilial    := .F.
	Private cHubAntigo
	Private aTotaisHub := {}
	Private nPosicao
	
	//Alias da Tabela Temporaria 
	Private cTRB	 := GetNextAlias()

	If !Empty(MV_PAR05) .OR. !Empty(MV_PAR06)
		lHub := .t.
	Endif
	If !Empty(MV_PAR07) .OR. !Empty(MV_PAR08)
		lFilial := .t.
	Endif

	aDBF :={{"CODHUB", "C", 02,0},; 	  //Hub
			{"DESHUB", "C", 40,0},; 	  //Descricao
			{"CODFIL", "C", nSizeFil,0},; //Filial
			{"DESFIL", "C", 25,0},; 	  //Descricao
			{"PJQANT", "N", 15,2},; 	  //Quantidade
			{"PJPEND", "N", 15,2},; 	  //Pendentes
			{"PJDEFE", "N", 15,2},; 	  //Recurso Deferido 
			{"PJINDE", "N", 15,2},; 	  //Recurso Indeferido
			{"PJSEMR", "N", 15,2}}  	  //Sem Recurso

	//Intancia classe FWTemporaryTable
	oTempTable  := FWTemporaryTable():New( cTRB, aDBF )
    //Cria indices
	oTempTable:AddIndex( "Ind01" , {"CODFIL"}  )
	oTempTable:AddIndex( "Ind02" , {"CODHUB","CODFIL"} )
	//Cria a tabela temporaria
	oTempTable:Create()


	Processa({|lEND| MNTR405TMP()},STR0018) //"Processando Arquivo..."

	If !lGera
  		oTempTable:Delete()//Deleta Tabela Temporaria
		Return .F.
	Endif

	nTIPO  := IIf(aReturn[4]==1,15,18)                                                                                                                                                                                               

	CABEC1 := ""
	CABEC2 := ""   

	lPri := .T.  
	lPriAcum := .T.

	//Carrega Totais
	DbSelectArea(cTRB)
	DbGoTop()  

	SetRegua(RecCount())

	While !Eof()
		IncRegua()

		nGR_PJQANT += (cTRB)->PJQANT
		nGR_PJPEND += (cTRB)->PJPEND
		nGR_PJDEFE += (cTRB)->PJDEFE
		nGR_PJINDE += (cTRB)->PJINDE
		nGR_PJSEMR += (cTRB)->PJSEMR
		If lHub
			nPosicao := aSCAN(aTotaisHub,{|x| x[1] = (cTRB)->CODHUB})
			If nPosicao == 0
				AADD(aTotaisHub,{(cTRB)->CODHUB,(cTRB)->PJQANT,(cTRB)->PJPEND,(cTRB)->PJDEFE,(cTRB)->PJINDE,(cTRB)->PJSEMR})
			Else
				aTotaisHub[nPosicao][2] += (cTRB)->PJQANT
				aTotaisHub[nPosicao][3] += (cTRB)->PJPEND
				aTotaisHub[nPosicao][4] += (cTRB)->PJDEFE
				aTotaisHub[nPosicao][5] += (cTRB)->PJINDE
				aTotaisHub[nPosicao][6] += (cTRB)->PJSEMR
			Endif
		Endif

		dbSelectArea(cTRB)			   
		dbSkip()
	End


	DbSelectArea(cTRB)
	If lFilial
		dbSetOrder(01)
	ElseIf lHub
		dbSetOrder(02)
	Endif
	DbGoTop()  

	SetRegua(RecCount())

	While !Eof()
		IncRegua()

		If lPri = .T.  
			NgSomaLi(58)
			@ Li,000 	 Psay STR0019 //"Filial"

			@ Li,042 	 Psay STR0020 //"QUANTIDADE"
			@ Li,053 	 Psay "   "+"%"

			@ Li,060 	 Psay STR0021 //"PENDENTE"
			@ Li,070 	 Psay "   "+"%"

			@ Li,077 	 Psay STR0022 //"REC.DEFER."
			@ Li,088 	 Psay "   "+"%"                

			@ Li,096 	 Psay STR0023 //"REC.INDEF."
			@ Li,107 	 Psay "   "+"%"                

			@ Li,115 	 Psay STR0036 //"SEM RECURSO"
			@ Li,127 	 Psay "   "+"%"      


			NgSomaLi(58)
			@ Li,000 	 Psay Replicate("-",132)
			NgSomaLi(58) 

			lPri := .F.  
		EndIf
		If lHub
			If cHubAntigo != (cTRB)->CODHUB
				NgSomaLi(58)
				@ Li,000 Psay (cTRB)->CODHUB + " - " + (cTRB)->DESHUB Picture "@!"
				NgSomaLi(58)
				NgSomaLi(58)
			Endif
		Endif
		cHubAntigo := (cTRB)->CODHUB

		@ Li,000 Psay (cTRB)->CODFIL + " - " + Substr((cTRB)->DESFIL, 1, 22) Picture "@!"

		If lHub
			nPosicao := aSCAN(aTotaisHub,{|x| x[1] = (cTRB)->CODHUB})
			nPEPJQANT := Round((((cTRB)->PJQANT/aTotaisHub[nPosicao][2]) *100), 0)
			nPEPJPEND := Round((((cTRB)->PJPEND/aTotaisHub[nPosicao][3]) *100), 0)
			nPEPJDEFE := Round((((cTRB)->PJDEFE/aTotaisHub[nPosicao][4]) *100), 0)
			nPEPJINDE := Round((((cTRB)->PJINDE/aTotaisHub[nPosicao][5]) *100), 0)
			nPEPJSEMR := Round((((cTRB)->PJSEMR/aTotaisHub[nPosicao][6]) *100), 0)	
		Else
			nPEPJQANT := Round((((cTRB)->PJQANT/nGR_PJQANT) *100), 0)
			nPEPJPEND := Round((((cTRB)->PJPEND/nGR_PJPEND) *100), 0)
			nPEPJDEFE := Round((((cTRB)->PJDEFE/nGR_PJDEFE) *100), 0)
			nPEPJINDE := Round((((cTRB)->PJINDE/nGR_PJINDE) *100), 0)
			nPEPJSEMR := Round((((cTRB)->PJSEMR/nGR_PJSEMR) *100), 0)
		Endif

		@ Li,042 	 Psay (cTRB)->PJQANT Picture "@E 9999999999"
		@ Li,053 	 Psay Transform(Round(nPEPJQANT, 0),"@E 999")+"%"

		@ Li,060 	 Psay (cTRB)->PJPEND Picture "@E 99999999"
		@ Li,070 	 Psay Transform(Round(nPEPJPEND, 0),"@E 999")+"%"

		@ Li,077 	 Psay (cTRB)->PJDEFE Picture "@E 9999999999"
		@ Li,088 	 Psay Transform(Round(nPEPJDEFE, 0),"@E 999")+"%"

		@ Li,096 	 Psay (cTRB)->PJINDE Picture "@E 9999999999"
		@ Li,107 	 Psay Transform(Round(nPEPJINDE, 0),"@E 999")+"%"

		@ Li,116 	 Psay (cTRB)->PJSEMR Picture "@E 9999999999"
		@ Li,127 	 Psay Transform(Round(nPEPJSEMR, 0),"@E 999")+"%"

		NgSomaLi(58) 

		dbSelectArea(cTRB)			   
		dbSkip()
		MNR405THUB()
	End

	If lHub
		NgSomaLi(58)
		@ Li,000 	 Psay Replicate("-",132)
		NgSomaLi(58)

		@ Li,000 	 Psay STR0024 //"TOTAL"

		@ Li,042 	 Psay nGR_PJQANT Picture "@E 9999999999"
		@ Li,053 	 Psay Transform(Round(((nGR_PJQANT/nGR_PJQANT) *100), 0),"@E 999")+"%"

		@ Li,060 	 Psay nGR_PJPEND Picture "@E 99999999"
		@ Li,070 	 Psay Transform(Round(((nGR_PJPEND/nGR_PJQANT) *100), 0),"@E 999")+"%"

		@ Li,077 	 Psay nGR_PJDEFE Picture "@E 9999999999"
		@ Li,088 	 Psay Transform(Round(((nGR_PJDEFE/nGR_PJQANT) *100), 0),"@E 999")+"%"

		@ Li,096 	 Psay nGR_PJINDE Picture "@E 9999999999"
		@ Li,107 	 Psay Transform(Round(((nGR_PJINDE/nGR_PJQANT) *100), 0),"@E 999")+"%"

		@ Li,116 	 Psay nGR_PJSEMR Picture "@E 9999999999"
		@ Li,127 	 Psay Transform(Round(((nGR_PJSEMR/nGR_PJQANT) *100), 0),"@E 999")+"%"
	Else
		If lPri = .F.
			NgSomaLi(58)
			@ Li,000 	 Psay Replicate("-",132)
			NgSomaLi(58)

			@ Li,000 	 Psay STR0024 //"TOTAL"

			@ Li,042 	 Psay nGR_PJQANT Picture "@E 9999999999"
			@ Li,053 	 Psay Transform(Round(((nGR_PJQANT/nGR_PJQANT) *100), 0),"@E 999")+"%"

			@ Li,060 	 Psay nGR_PJPEND Picture "@E 99999999"
			@ Li,070 	 Psay Transform(Round(((nGR_PJPEND/nGR_PJQANT) *100), 0),"@E 999")+"%"

			@ Li,077 	 Psay nGR_PJDEFE Picture "@E 9999999999"
			@ Li,088 	 Psay Transform(Round(((nGR_PJDEFE/nGR_PJQANT) *100), 0),"@E 999")+"%"

			@ Li,096 	 Psay nGR_PJINDE Picture "@E 9999999999"
			@ Li,107 	 Psay Transform(Round(((nGR_PJINDE/nGR_PJQANT) *100), 0),"@E 999")+"%"

			@ Li,116 	 Psay nGR_PJSEMR Picture "@E 9999999999"
			@ Li,127 	 Psay Transform(Round(((nGR_PJSEMR/nGR_PJQANT) *100), 0),"@E 999")+"%"		
		EndIF
	Endif

	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)

	If !Empty(n1) .OR. !Empty(n2) .OR. !Empty(n3)
		@ Li,000 	 Psay STR0029 //"TOTAL DE MULTAS POR STATUS:"
		NgSomaLi(58)
		If n1 > 0
			NgSomaLi(58)
			@ Li,000 	 Psay STR0030+AllTrim(Str(n1))//"Registrada(s): "
		ElseIf n2 > 0
			NgSomaLi(58)
			@ Li,000 	 Psay STR0031+AllTrim(Str(n2))//"Em Andamento : "
		ElseIf n3 > 0
			NgSomaLi(58)
			@ Li,000 	 Psay STR0032+AllTrim(Str(n3))//"Concluída(s) : "
		Endif	
		NgSomaLi(58)
		NgSomaLi(58)
	Endif

	If Len(aMotorista) > 0
		@ Li,000 	 Psay STR0033 //"TOTAL DE MULTAS POR MOTORISTA:"
		NgSomaLi(58)
		For nI := 1 to Len(aMotorista)
			NgSomaLi(58)
			@ Li,000  Psay aMotorista[nI][1] + ' - '
			@ Li,009  Psay NGSEEK('DA4',aMotorista[nI][1],1,'DA4_NOME')
			@ Li,049  Psay ' : ' + AllTrim(Str(aMotorista[nI][2]))		
		Next
	Endif

	oTempTable:Delete()//Deleta Tabela Temporaria

	RODA(nCNTIMPR,cRODATXT,TAMANHO)       
	
	//Devolve a condicao original do arquivo principal
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
±±³Fun‡„o    ³MNR405FL  ³ Autor ³Ricardo Dal Ponte      ³ Data ³ 15/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³validação do parametro Filial                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR405                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNR405FL(nOpc)

	If Empty(mv_par07) .AND. Empty(mv_par08)
		Return .t.
	Endif

	If Empty(mv_par07) .And. (mv_par08 == Replicate('Z', nSizeFil))
		MV_PAR05 := Space(02)
		MV_PAR06 := Space(02)
		Return .t.
	Else
		If nOpc == 1
			lRet := IIf(Empty(Mv_Par07),.t.,ExistCpo('SM0',SM0->M0_CODIGO+Mv_Par07))
			If !lRet
				Return .f.
			EndIf
		ElseIf nOpc == 2 .AND. MV_PAR08 != Replicate('Z', nSizeFil)
			lRet := IIF(ATECODIGO('SM0',SM0->M0_CODIGO+Mv_Par07,SM0->M0_CODIGO+Mv_Par08,07),.T.,.F.)
			If !lRet
				Return .f.
			EndIf
		EndIf
	EndIf

	If !Empty(MV_PAR07) .Or. !Empty(MV_PAR08)
		MV_PAR05 := Space(02)
		MV_PAR06 := Space(02)
	Endif

Return .t. 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |MNTR405TMP| Autor ³ Ricardo Dal Ponte     ³ Data ³ 15/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Geracao do arquivo temporario                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR405                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTR405TMP()

	Local cFiliIni := IF(NgSX2Modo("TRX")=='C',Space(nSizeFil),MV_PAR07)

	cAliasQry  := GetNextAlias()

	cQuery := " SELECT TRX.TRX_FILIAL, TRX.TRX_CODINF, TRX.TRX_DTINFR, TRX.TRX_INDREC, TRX.TRX_STATUS, TRX.TRX_CODMO"
	If lHub
		cQuery += ", TRW.TRW_HUB, TRW.TRW_DESHUB"	
	Endif
	cQuery += " FROM " + RetSqlName("TRX")+" TRX"
	If lHub
		cQuery += ", " + RetSqlName("TSL")+" TSL, " + RetSqlName("TRW")+" TRW "
	Endif
	cQuery += " WHERE "
	cQuery += "      (TRX.TRX_DTINFR  >= '"+AllTrim(Str(MV_PAR01))+"0101'"
	cQuery += " AND   TRX.TRX_DTINFR  <= '"+AllTrim(Str(MV_PAR02))+"1231')"
	cQuery += " AND   TRX.TRX_CODINF  >= '"+MV_PAR03+"'"
	cQuery += " AND   TRX.TRX_CODINF  <= '"+MV_PAR04+"'"
	If lFilial
		cQuery += " AND   TRX.TRX_FILIAL  >= '"+cFiliIni+"'"
		cQuery += " AND   TRX.TRX_FILIAL  <= '"+MV_PAR08+"'"
	Endif
	If lHub
		cQuery += " AND   TSL.TSL_HUB     >= '"+MV_PAR05+"'"
		cQuery += " AND   TSL.TSL_HUB     <= '"+MV_PAR06+"'"
		cQuery += " AND   TRX.TRX_FILIAL  = TSL.TSL_FILMS "
		cQuery += " AND   TSL.TSL_HUB     = TRW.TRW_HUB  "
		cQuery += " AND   TRW.D_E_L_E_T_ <> '*' "
		cQuery += " AND   TSL.D_E_L_E_T_ <> '*' "	
	Endif
	cQuery += "	AND   TRX.TRX_CODMO   >= '"+MV_PAR09+"'"
	cQuery += "	AND   TRX.TRX_CODMO   <= '"+MV_PAR10+"'"
	cQuery += " AND   TRX.D_E_L_E_T_ <> '*' "
	If lHub
		cQuery += " ORDER BY TRW.TRW_HUB, TRX.TRX_FILIAL "
	Endif

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)  

	dbSelectArea(cAliasQry)			   
	dbGoTop()

	If Eof()
		MsgInfo(STR0025,STR0026) //"Não existem dados para montar o relatório!"###"ATENÇÃO"
		(cALIASQRY)->(dbCloseArea())
		lGera := .f.
		Return
	Endif

	SetRegua(LastRec())

	While !Eof()
		IncProc()

		dbSelectArea(cTRB)
		dbSetOrder(1)

		If !dbSeek((cAliasQry)->TRX_FILIAL)
			RecLock((cTRB), .T.)

			(cTRB)->CODFIL := (cAliasQry)->TRX_FILIAL
			If lHub
				(cTRB)->CODHUB := (cAliasQry)->TRW_HUB
				(cTRB)->DESHUB := (cAliasQry)->TRW_DESHUB
			Endif

			dbSelectArea("SM0")
			dbSetorder(1)

			(cTRB)->DESFIL := ""
			If dbSeek(cEmpAnt+(cALIASQRY)->TRX_FILIAL)
				(cTRB)->DESFIL := SM0->M0_FILIAL
			EndIf

			(cTRB)->PJQANT := 0 //QUANTIDADE
			(cTRB)->PJPEND := 0 //PENDENTES
			(cTRB)->PJDEFE := 0 //RECURSO DEFERIDO 
			(cTRB)->PJINDE := 0 //RECURSO INDEFERIDO
			(cTRB)->PJSEMR := 0 //SEM RECURSO
		Else
			RecLock((cTRB), .F.)
		EndiF

		(cTRB)->PJQANT += 1 //QUANTIDADE

		If (cAliasQry)->TRX_INDREC = "1"
			(cTRB)->PJPEND += 1 //PENDENTES
		ElseIf (cAliasQry)->TRX_INDREC = "2"
			(cTRB)->PJDEFE += 1 //RECURSO DEFERIDO 
		ElseIf  (cAliasQry)->TRX_INDREC = "3"
			(cTRB)->PJINDE += 1 //RECURSO INDEFERIDO
		Else
			(cTRB)->PJSEMR += 1 //RECURSO INDEFERIDO 	
		EndIf

		MsUnLock(cTRB)

		If (cAliasQry)->TRX_STATUS = '1'
			n1 += 1
		ElseIf (cAliasQry)->TRX_STATUS = '2'
			n2 += 1
		ElseIf (cAliasQry)->TRX_STATUS = '3'
			n3 += 1
		Endif

		nRetorno := aSCAN(aMotorista,{|x| x[1] = (cAliasQry)->TRX_CODMO}) 
		If nRetorno > 0
			aMotorista[nRetorno][2] += 1
		Else
			AADD(aMotorista,{(cAliasQry)->TRX_CODMO,1})
		Endif

		dbSelectArea(cAliasQry)			   
		dbSkip()
	End


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MNR405CC  | Autor ³Marcos Wagner Junior   ³ Data ³ 12/09/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o |Valida os codigos De/Ate Motorista		                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR405                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNR405CC(nOpc,cParDe,cParAte,cTabela)  

	If (Empty(cParDe) .AND. cParAte = 'ZZZZZZ')
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
			If (cParAte == 'ZZZZZZ') 
				Return .t.
			Else
				lRet := IIF(ATECODIGO(cTabela,cParDe,cParAte,10),.T.,.F.)
				If !lRet 
					Return .f.
				EndIf  
			EndIf
		EndIf    
	Endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MNR405ANO | Autor ³Marcos Wagner Junior   ³ Data ³ 23/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o |Valida o ano digitado no grupo de perguntas                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR405                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNR405ANO(nPar)

	cAno := AllTrim(Str(IF(nPar==1,MV_PAR01,MV_PAR02)))
	If Len(cAno) != 4
		MsgStop(STR0037,STR0026) //"O Ano informado deverá conter 4 dígitos!"###"ATENÇÃO"
		Return .f.
	Endif
	If (nPar = 1 .AND. MV_PAR01 > Year(dDATABASE)) .OR. (nPar = 2 .AND. MV_PAR02 > Year(dDATABASE))
		MsgStop(STR0034+AllTrim(Str(Year(dDATABASE)))+'!',STR0026) //"Ano informado não poderá ser maior que "###"ATENÇÃO"
		Return .f.
	Endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MNR405HUB | Autor ³Marcos Wagner Junior   ³ Data ³ 23/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o |Validacao De/Ate HUB								                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR405                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNR405HUB(nPar)

	If (nPar = 1 .AND. !Empty(MV_PAR05)) .OR. (nPar = 2 .AND. !Empty(MV_PAR06))
		If nPar = 1
			If !ExistCpo('TRW',MV_PAR05)
				Return .f.
			Endif
		Else
			If !AteCodigo("TRW",mv_par05,mv_par06)
				Return .f.	   
			Endif
		Endif
	Endif

	If !Empty(MV_PAR05) .OR. !Empty(MV_PAR06)
		MV_PAR07 := Space(nSizeFil)
		MV_PAR08 := Space(nSizeFil)
	Endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MNR405THUB| Autor ³Marcos Wagner Junior   ³ Data ³ 23/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o |Totalizacao por Hub								                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR405                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNR405THUB()

	If lHub .And. (Eof() .OR. cHubAntigo != (cTRB)->CODHUB)
		NgSomaLi(58)

		@ Li,000 	 Psay STR0035 //"TOTAL DO GRUPO DE FILIAL"

		@ Li,035 	 Psay aTotaisHub[nPosicao][2] Picture "@E 9999999999"
		@ Li,046 	 Psay Transform(Round(((aTotaisHub[nPosicao][2]/aTotaisHub[nPosicao][2]) *100), 0),"@E 999")+"%"

		@ Li,053 	 Psay aTotaisHub[nPosicao][3] Picture "@E 99999999"
		@ Li,063 	 Psay Transform(Round(((aTotaisHub[nPosicao][3]/aTotaisHub[nPosicao][2]) *100), 0),"@E 999")+"%"

		@ Li,070 	 Psay aTotaisHub[nPosicao][4] Picture "@E 9999999999"
		@ Li,081 	 Psay Transform(Round(((aTotaisHub[nPosicao][4]/aTotaisHub[nPosicao][2]) *100), 0),"@E 999")+"%"

		@ Li,089 	 Psay aTotaisHub[nPosicao][5] Picture "@E 9999999999"
		@ Li,100 	 Psay Transform(Round(((aTotaisHub[nPosicao][5]/aTotaisHub[nPosicao][2]) *100), 0),"@E 999")+"%"

		@ Li,109 	 Psay aTotaisHub[nPosicao][6] Picture "@E 9999999999"
		@ Li,120 	 Psay Transform(Round(((aTotaisHub[nPosicao][6]/aTotaisHub[nPosicao][2]) *100), 0),"@E 999")+"%"

		NgSomaLi(58)
		If !Eof()
			NgSomaLi(58)	
		Endif
	Endif

Return .T.