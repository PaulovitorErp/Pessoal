#INCLUDE "MNTR755.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTR755   ³ Autor ³ Ricardo Dal Ponte     ³ Data ³ 09/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio de Quantidade de Eventos por Filial               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/      
Function MNTR755() 

	Private 	nTGFILJAN := 0
	Private 	nTGFILFEV := 0
	Private 	nTGFILMAR := 0
	Private 	nTGFILABR := 0
	Private 	nTGFILMAI := 0
	Private 	nTGFILJUN := 0
	Private 	nTGFILJUL := 0
	Private 	nTGFILAGO := 0
	Private 	nTGFILSET := 0
	Private 	nTGFILOUT := 0
	Private 	nTGFILNOV := 0
	Private 	nTGFILDEZ := 0
	Private 	nTGFILTOT := 0
	Private 	nSizeFil := If(FindFunction("FWSizeFilial"),FwSizeFilial(),Len(TRH->TRH_FILIAL))

	WNREL      := "MNTR755"
	LIMITE     := 220
	cDESC1     := STR0001 //"O relatório apresentará a quantidade de eventos ocorridos "
	cDESC2     := STR0002 //"no ano, demonstrando o valor do prejuízo, o custo com "
	cDESC3     := STR0003 //"Manutenção e demais custos(guincho, indenizações)."
	cSTRING    := "TRH"       

	SetKey( VK_F9, { | | NGVersao( "MNTR755" , 1 ) } )

	Private NOMEPROG := "MNTR755"
	Private TAMANHO  := "G"
	Private aRETURN  := {STR0004,1,STR0005,1,2,1,"",1} //"Zebrado"###"Administracao"
	Private TITULO   := STR0006 //"Relatorio de Quantidade de Eventos por Filial"
	Private nTIPO    := 0
	Private nLASTKEY := 0
	Private CABEC1,CABEC2 
	Private aVETINR := {}    
	Private cPERG := "MNT755"   
	Private aPerg :={}

	Pergunte(cPERG,.F.)
	//+---------------------------------------+
	//| Envia controle para a funcao SETPRINT |   
	//+---------------------------------------+               
	WNREL:=SetPrint(cSTRING,WNREL,cPERG,TITULO,cDESC1,cDESC2,cDESC3,.F.,"")
	If nLASTKEY = 27
		Set Filter To
		DbSelectArea("TRH")  
		Return
	EndIf     
	SetDefault(aReturn,cSTRING)
	RptStatus({|lEND| MNTR755IMP(@lEND,WNREL,TITULO,TAMANHO)},STR0010,STR0011) //"Aguarde..."###"Processando Registros..."
	Dbselectarea("TRH")  

Return .T.    

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |MNT755IMP | Autor ³ Ricardo Dal Ponte     ³ Data ³ 08/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Chamada do Relat¢rio                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR755                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTR755IMP(lEND,WNREL,TITULO,TAMANHO) 
	Local	nPETOTCARa := 0
	Local	nPETOTMNTa := 0
	Local	nPETOTFILa := 0

	Local	nGETOTCAR 	:= 0
	Local	nGETOTMNT 	:= 0
	Local	nGETOTFIL 	:= 0

	Local	nGR_TOTCAR 	:= 0
	Local	nGR_TOTMNT	:= 0
	Local	nGR_TOTOUT	:= 0
	Local	nGR_TOTFIL 	:= 0
	Local   nI
	
	//TABELA TEMPORARIA	
	Local   oTempTable		
	
	Private cRODATXT 	:= ""
	Private nCNTIMPR 	:= 0     
	Private li := 80 ,m_pag := 1    
	Private cNomeOri
	Private aVetor		:= {}
	Private aTotGeral	:= {}
	Private nAno, nMes 
	Private nTotCarga 	:= 0, nTotManut := 0 
	Private nTotal 		:= 0

	//Alias da tabela temporaria
	Private cTRB	:= GetNextAlias()
	
	aDBF :={{"CODFIL", "C", nSizeFil,0},; //codigo filial
			{"DESFIL", "C", 25, 0},; //descricao filial
			{"FILJAN", "N",  6, 0},; //qtde janeiro
			{"FILFEV", "N",  6, 0},; //qtde fevereiro
			{"FILMAR", "N",  6, 0},; //qtde marco
			{"FILABR", "N",  6, 0},; //qtde abril
			{"FILMAI", "N",  6, 0},; //qtde maio
			{"FILJUN", "N",  6, 0},; //qtde junho
			{"FILJUL", "N",  6, 0},; //qtde julho
			{"FILAGO", "N",  6, 0},; //qtde agosto
			{"FILSET", "N",  6, 0},; //qtde setembro
			{"FILOUT", "N",  6, 0},; //qtde outubro
			{"FILNOV", "N",  6, 0},; //qtde novembro
			{"FILDEZ", "N",  6, 0},; //qtde dezembro
			{"FILTOT", "N",  6, 0},; //qtde total por hub
			{"TOTCAR", "N", 12, 2},; //prejuizo carga
			{"TOTMNT", "N", 12, 2},; //PREJUIZO MANUTENCAO
			{"TOTOUT", "N", 12, 2},; //PREJUIZO Outros
			{"TOTFIL", "N", 12, 2}}  //PREJUIZO FILIAL

	//Intancia classe FWTemporaryTable
	oTempTable  := FWTemporaryTable():New( cTRB, aDBF )
	//Cria indices
	oTempTable:AddIndex( "Ind01" , {"CODFIL"} )
	//Cria a tabela temporaria
	oTempTable:Create()

	Processa({|lEND| MNTR755TMP()},STR0013) //"Processando Arquivo..."

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

		nTGFILJAN += (cTRB)->FILJAN
		nTGFILFEV += (cTRB)->FILFEV
		nTGFILMAR += (cTRB)->FILMAR
		nTGFILABR += (cTRB)->FILABR
		nTGFILMAI += (cTRB)->FILMAI
		nTGFILJUN += (cTRB)->FILJUN
		nTGFILJUL += (cTRB)->FILJUL
		nTGFILAGO += (cTRB)->FILAGO
		nTGFILSET += (cTRB)->FILSET
		nTGFILOUT += (cTRB)->FILOUT
		nTGFILNOV += (cTRB)->FILNOV
		nTGFILDEZ += (cTRB)->FILDEZ
		nTGFILTOT += (cTRB)->FILTOT

		nGR_TOTCAR += (cTRB)->TOTCAR
		nGR_TOTMNT += (cTRB)->TOTMNT
		nGR_TOTOUT += (cTRB)->TOTOUT
		nGR_TOTFIL += (cTRB)->TOTFIL

		dbSelectArea(cTRB)		   
		dbSkip()
	End

	DbSelectArea(cTRB)
	DbGoTop()  
	SetRegua(RecCount())

	/*
	1         2         3         4         5         6         7         8         9         10        11        12        13        14
	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890 
	*********************************************************************************************************************************************
	Filial                               | JAN  FEV  MAR  ABR  MAI  JUN  JUL  AGO  SET  OUT  NOV  DEZ  TOTAL
	*********************************************************************************************************************************************
	xxxxxxxxxxxx - xxxxxxxxxxxxxxxxxxxx    999  999  999  999  999  999  999  999  999  999  999  999  99999
	*/

	While !Eof()
		IncRegua()

		If lPri = .T.  
			NgSomaLi(58)
			@ Li,000 	 Psay STR0014 //"Filial"
			@ Li,037 	 Psay "|"
			@ Li,039 	 Psay STR0015 //"JAN"
			@ Li,044 	 Psay STR0016 //"FEV"
			@ Li,049 	 Psay STR0017 //"MAR"
			@ Li,054 	 Psay STR0018 //"ABR"
			@ Li,059 	 Psay STR0019 //"MAI"
			@ Li,064 	 Psay STR0020 //"JUN"
			@ Li,069 	 Psay STR0021 //"JUL"
			@ Li,074 	 Psay STR0022 //"AGO"
			@ Li,079 	 Psay STR0023 //"SET"
			@ Li,084 	 Psay STR0024 //"OUT"
			@ Li,089 	 Psay STR0025 //"NOV"
			@ Li,094 	 Psay STR0026 //"DEZ"
			@ Li,099 	 Psay STR0027 //"TOTAL"

			@ Li,111 	 Psay STR0028 //"PREJ.CARGA"
			@ Li,126 	 Psay "%"
			@ Li,130 	 Psay STR0029 //"%AC"

			@ Li,141 	 Psay STR0030 //"PREJ. MNT"
			@ Li,155 	 Psay "%"
			@ Li,159 	 Psay STR0029 //"%AC"

			@ Li,168		 Psay STR0043 //"PREJ.OUTROS"

			@ Li,189 	 Psay STR0031 //"PREJ.TOTAL"
			@ Li,204 	 Psay "%"
			@ Li,207 	 Psay " "+STR0029 //"%AC"

			NgSomaLi(58)
			@ Li,000 	 Psay Replicate("-",220)
			NgSomaLi(58) 

			lPri := .F.  
		EndIf

		@ Li,000 	 Psay (cTRB)->CODFIL +" - " + Substr((cTRB)->DESFIL, 1, 20)
		@ Li,037 	 Psay "|"
		@ Li,039 	 Psay (cTRB)->FILJAN Picture "999"
		@ Li,044 	 Psay (cTRB)->FILFEV Picture "999"
		@ Li,049 	 Psay (cTRB)->FILMAR Picture "999"
		@ Li,054 	 Psay (cTRB)->FILABR Picture "999"
		@ Li,059 	 Psay (cTRB)->FILMAI Picture "999"
		@ Li,064 	 Psay (cTRB)->FILJUN Picture "999"
		@ Li,069 	 Psay (cTRB)->FILJUL Picture "999"
		@ Li,074 	 Psay (cTRB)->FILAGO Picture "999"
		@ Li,079 	 Psay (cTRB)->FILSET Picture "999"
		@ Li,084 	 Psay (cTRB)->FILOUT Picture "999"
		@ Li,089 	 Psay (cTRB)->FILNOV Picture "999"
		@ Li,094 	 Psay (cTRB)->FILDEZ Picture "999"
		@ Li,099 	 Psay (cTRB)->FILTOT Picture "9,999"

		cPETOTCAR := Round((((cTRB)->TOTCAR /nGR_TOTCAR) *100), 0)
		cPETOTMNT := Round((((cTRB)->TOTMNT /nGR_TOTMNT) *100), 0)
		cPETOTFIL := Round((((cTRB)->TOTFIL /nGR_TOTFIL) *100), 0)

		nPETOTCARa += cPETOTCAR
		nPETOTMNTa += cPETOTMNT
		nPETOTFILa += cPETOTFIL

		@ Li,107 	 Psay (cTRB)->TOTCAR Picture "@E 999,999,999.99"
		@ Li,123 	 Psay Transform(cPETOTCAR,"@E 999")+"%"

		If lPriAcum = .T.
			@ Li,129 	 Psay Transform(cPETOTCAR,"@E 999")+"%"
		Else
			@ Li,129 	 Psay Transform(nPETOTCARa,"@E 999")+"%"
		EndIf

		@ Li,136 	 Psay (cTRB)->TOTMNT Picture "@E 999,999,999.99"
		@ Li,152 	 Psay Transform(cPETOTMNT,"@E 999")+"%"

		If lPriAcum = .T.
			@ Li,158 	 Psay Transform(cPETOTMNT,"@E 999")+"%"
		Else
			@ Li,158 	 Psay Transform(nPETOTMNTa,"@E 999")+"%"
		EndIf

		@ Li,165 	 Psay (cTRB)->TOTOUT Picture "@E 999,999,999.99"

		@ Li,182 	 Psay (cTRB)->TOTFIL Picture "@E 99,999,999,999.99"
		@ Li,201 	 Psay Transform(cPETOTFIL,"@E 999")+"%"

		If lPriAcum = .T.
			@ Li,207 	 Psay Transform(cPETOTFIL,"@E 999")+"%"
		Else
			@ Li,207 	 Psay Transform(nPETOTFILa,"@E 999")+"%"
		EndIf

		lPriAcum := .F.

		NgSomaLi(58) 

		dbSelectArea(cTRB)		   
		dbSkip()
	End

	If lPri = .F.  
		NgSomaLi(58)
		@ Li,000 	 Psay Replicate("-",220)
		NgSomaLi(58) 
		@ Li,000 	 Psay STR0027 //"TOTAL"
		@ Li,037 	 Psay "|"
		@ Li,039 	 Psay nTGFILJAN Picture "999"
		@ Li,044 	 Psay nTGFILFEV Picture "999"
		@ Li,049 	 Psay nTGFILMAR Picture "999"
		@ Li,054 	 Psay nTGFILABR Picture "999"
		@ Li,059 	 Psay nTGFILMAI Picture "999"
		@ Li,064 	 Psay nTGFILJUN Picture "999"
		@ Li,069 	 Psay nTGFILJUL Picture "999"
		@ Li,074 	 Psay nTGFILAGO Picture "999"
		@ Li,079 	 Psay nTGFILSET Picture "999"
		@ Li,084 	 Psay nTGFILOUT Picture "999"
		@ Li,089 	 Psay nTGFILNOV Picture "999"
		@ Li,094 	 Psay nTGFILDEZ Picture "999"
		@ Li,099 	 Psay nTGFILTOT Picture "9,999"

		@ Li,107 	 Psay nGR_TOTCAR Picture "@E 999,999,999.99"
		@ Li,123 	 Psay Transform(Round(((nGR_TOTCAR /nGR_TOTCAR) *100), 0),"@E 999")+"%"
		@ Li,129 	 Psay Transform(Round(((nGR_TOTCAR /nGR_TOTCAR) *100), 0),"@E 999")+"%"
		@ Li,136 	 Psay nGR_TOTMNT Picture "@E 999,999,999.99"
		@ Li,152 	 Psay Transform(Round(((nGR_TOTMNT /nGR_TOTMNT) *100), 0),"@E 999")+"%"
		@ Li,158 	 Psay Transform(Round(((nGR_TOTMNT /nGR_TOTMNT) *100), 0),"@E 999")+"%"
		@ Li,165 	 Psay nGR_TOTOUT Picture "@E 999,999,999.99"
		@ Li,182 	 Psay nGR_TOTFIL Picture "@E 99,999,999,999.99"
		@ Li,201 	 Psay Transform(Round(((nGR_TOTFIL /nGR_TOTFIL) *100), 0),"@E 999")+"%"
		@ Li,207 	 Psay Transform(Round(((nGR_TOTFIL /nGR_TOTFIL) *100), 0),"@E 999")+"%"
	EndIF

	oTempTable:Delete()//Deleta arquivo temporario

	RODA(nCNTIMPR,cRODATXT,TAMANHO)       

	//³ Devolve a condicao original do arquivo principal   
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

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |MNTR755VAL| Autor ³ Ricardo Dal Ponte     ³ Data ³ 08/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao dos Parametros	                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR755                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTR755VAL() 

	If !Empty(MV_PAR02) .AND. !Empty(MV_PAR03)
		If MV_PAR02 > MV_PAR03
			MsgStop(STR0032,STR0033)  //"De Filial não pode ser maior que Até Filial!"###"Atenção"
			Return .f.	
		Endif
	Endif
Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |MNTR755TMP| Autor ³ Ricardo Dal Ponte     ³ Data ³ 08/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Geracao do arquivo temporario                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR755                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function MNTR755TMP()
	cAliasQry := GetNextAlias()
	cQuery := " SELECT TRH.TRH_FILIAL, TRH.TRH_DTACID, TRH.TRH_NUMSIN, TRH.TRH_VALGUI, TRH.TRH_VALANI "
	cQuery += " FROM " + RetSqlName("TRH")+" TRH "
	cQuery += " WHERE "
	cQuery += "       (TRH.TRH_DTACID  >= '"+AllTrim(Str(MV_PAR01))+"0101'"
	cQuery += " AND    TRH.TRH_DTACID  <= '"+AllTrim(Str(MV_PAR01))+"1231')"
	cQuery += " AND   TRH.TRH_FILIAL   >= '"+MV_PAR02+"'"
	cQuery += " AND   TRH.TRH_FILIAL   <= '"+MV_PAR03+"'"
	cQuery += " AND   TRH.TRH_EVENTO   = '"+AllTrim(Str(MV_PAR04))+"'"
	cQuery += " AND   TRH.TRH_TIPACI  >= '"+MV_PAR05+"'"
	cQuery += " AND   TRH.TRH_TIPACI  <= '"+MV_PAR06+"'"
	cQuery += " AND   TRH.D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)  

	dbSelectArea(cAliasQry)			   
	dbGoTop()

	If Eof()
		MsgInfo(STR0034,STR0033) //"Não existem dados para montar o relatório!"###"Atenção"
		(cALIASQRY)->(dbCloseArea())
		Return
	Endif

	SetRegua(LastRec())

	While !Eof()
		IncRegua()

		dbSelectArea(cTRB)
		dbSetOrder(1)

		If !dbSeek((cAliasQry)->TRH_FILIAL)
			RecLock((cTRB), .T.)
			(cTRB)->CODFIL := (cAliasQry)->TRH_FILIAL
			(cTRB)->DESFIL := ""

			dbSelectArea("SM0")
			dbSetorder(1)

			If dbSeek(cEmpAnt+(cAliasQry)->TRH_FILIAL)
				(cTRB)->DESFIL := SM0->M0_FILIAL
			EndIf

			(cTRB)->FILJAN := 0 //qtde janeiro
			(cTRB)->FILFEV := 0 //qtde fevereiro
			(cTRB)->FILMAR := 0 //qtde marco
			(cTRB)->FILABR := 0 //qtde abril
			(cTRB)->FILMAI := 0 //qtde maio
			(cTRB)->FILJUN := 0 //qtde junho
			(cTRB)->FILJUL := 0 //qtde julho
			(cTRB)->FILAGO := 0 //qtde agosto
			(cTRB)->FILSET := 0 //qtde setembro
			(cTRB)->FILOUT := 0 //qtde outubro
			(cTRB)->FILNOV := 0 //qtde novembro
			(cTRB)->FILDEZ := 0 //qtde dezembro
			(cTRB)->FILTOT := 0 //TOTAL
			(cTRB)->TOTCAR := 0 //PREJUIZO CARGA
			(cTRB)->TOTMNT := 0 //PREJUIZO MANUTENCAO
			(cTRB)->TOTOUT := 0 //PREJUIZO Outros
			(cTRB)->TOTFIL := 0 //PREJUIZO FILIAL
		Else
			RecLock((cTRB), .F.)
		EndiF

		nMes := Val(SubStr((cAliasQry)->TRH_DTACID,5,2))

		Do Case 	
			Case nMes = 1; (cTRB)->FILJAN += 1 //qtde janeiro
			Case nMes = 2; (cTRB)->FILFEV += 1 //qtde fevereiro
			Case nMes = 3; (cTRB)->FILMAR += 1 //qtde marco
			Case nMes = 4; (cTRB)->FILABR += 1 //qtde abril
			Case nMes = 5; (cTRB)->FILMAI += 1 //qtde maio
			Case nMes = 6; (cTRB)->FILJUN += 1 //qtde junho
			Case nMes = 7; (cTRB)->FILJUL += 1 //qtde julho
			Case nMes = 8; (cTRB)->FILAGO += 1 //qtde agosto
			Case nMes = 9; (cTRB)->FILSET += 1 //qtde setembro
			Case nMes = 10; (cTRB)->FILOUT += 1 //qtde outubro
			Case nMes = 11; (cTRB)->FILNOV += 1 //qtde novembro
			Case nMes = 12; (cTRB)->FILDEZ += 1 //qtde dezembro
		End Case

		(cTRB)->FILTOT += 1 //TOTAL

		(cTRB)->TOTCAR += R755CAR((cAliasQry)->TRH_NUMSIN) //PREJUIZO CARGA

		(cTRB)->TOTMNT += R755MNT((cAliasQry)->TRH_NUMSIN) //PREJUIZO MANUTENCAO

		(cTRB)->TOTOUT += R755Outros((cAliasQry)->TRH_NUMSIN) + (cAliasQry)->TRH_VALGUI + (cAliasQry)->TRH_VALANI //PREJUIZO OUTROS

		(cTRB)->TOTFIL := (cTRB)->TOTCAR + (cTRB)->TOTMNT + (cTRB)->TOTOUT //PREJUIZO TOTAL

		MsUnLock(cTRB)

		dbSelectArea(cAliasQry)			   
		dbSkip()
	End
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |R755CAR   | Autor ³ Ricardo Dal Ponte     ³ Data ³ 09/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega os valores de prejuizos em cargas                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR755                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function R755CAR(cCodSin)
	Local cAliasQry
	Local cQuery
	Local nTotCarga := 0

	cAliasQry := GetNextAlias()
	cQuery := " SELECT SUM(TRK_VALAVA) AS TTAVARIA, SUM(TRK_VALREC) AS TTAVAREC "
	cQuery += " FROM " + RetSqlName("TRH")+" TRH, " + RetSqlName("TRK")+" TRK "
	cQuery += " WHERE "
	cQuery += "       TRK.TRK_NUMSIN = '"+cCodSin+"'"
	cQuery += " AND   TRK.TRK_FILIAL = '"+(cTRB)->CODFIL+"'"
	cQuery += " AND   TRH.TRH_FILIAL = TRK.TRK_FILIAL "
	cQuery += " AND   TRH.TRH_NUMSIN = TRK.TRK_NUMSIN "
	cQuery += " AND   TRH.D_E_L_E_T_ <> '*' "
	cQuery += " AND   TRK.D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)  

	dbSelectArea(cAliasQry)			   
	dbGoTop()

	nTotCarga := (cAliasQry)->TTAVARIA - (cAliasQry)->TTAVAREC

	(cAliasQry)->(dbCloseArea())

Return nTotCarga

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |R755MNT   | Autor ³ Ricardo Dal Ponte     ³ Data ³ 09/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega os valores de prejuizos da manutencao               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR755                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function R755MNT(cCodSin)
	Local aOldArea := GetArea()
	Local cAliasQry := GetNextAlias()
	Local cQuery
	Local nPrejuMNT := 0

	cQuery := " SELECT STJ.TJ_ORDEM, STJ.TJ_TERMINO, STJ.TJ_SEQRELA, STL.TL_CUSTO"
	cQuery += " FROM " + RetSqlName("TRH")+" TRH, " + RetSqlName("TRT")+" TRT, " + RetSqlName("STJ")+" STJ, "+ RetSqlName("STL")+" STL "
	cQuery += " WHERE "
	cQuery += "       TRT.TRT_NUMSIN = '"+cCodSin+"'"
	cQuery += " AND   TRT.TRT_FILIAL = TRH.TRH_FILIAL "
	cQuery += " AND   TRT.TRT_NUMSIN = TRH.TRH_NUMSIN "

	cQuery += " AND   STJ.TJ_FILIAL  = TRT.TRT_FILIAL "
	cQuery += " AND   STJ.TJ_ORDEM   = TRT.TRT_NUMOS "
	cQuery += " AND   STJ.TJ_PLANO   = TRT.TRT_PLANO "

	cQuery += " AND   STL.TL_FILIAL = STJ.TJ_FILIAL "
	cQuery += " AND   STL.TL_ORDEM  = STJ.TJ_ORDEM "
	cQuery += " AND   STL.TL_PLANO  = STJ.TJ_PLANO "

	cQuery += " AND   ((STJ.TJ_TERMINO = 'N') OR ((STJ.TJ_TERMINO = 'S') AND (STJ.TJ_SEQRELA <> '000'))) "

	cQuery += " AND   TRH.D_E_L_E_T_ <> '*' "
	cQuery += " AND   TRT.D_E_L_E_T_ <> '*' "
	cQuery += " AND   STJ.D_E_L_E_T_ <> '*' "
	cQuery += " AND   STL.D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)  

	dbSelectArea(cAliasQry)			   
	dbGoTop()

	While !Eof()	
		nPrejuMNT += (cAliasQry)->TL_CUSTO
		dbSelectArea(cAliasQry)			   
		dbSkip()
	End

	(cAliasQry)->(dbCloseArea())

	RestArea(aOldArea)

Return nPrejuMNT 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |R755Outros| Autor ³ Ricardo Dal Ponte     ³ Data ³ 09/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega os valores de prejuizos filial                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR755                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function R755Outros(cCodSin)
	Local cAliasQry, cQuery
	Local nSoma := 0

	//PREJUIZOS VITIMAS
	cAliasQry := GetNextAlias()
	cQuery := " SELECT SUM(TRM.TRM_VALVIT) AS TOTVALVIT "
	cQuery += " FROM " + RetSqlName("TRH")+" TRH, "+ RetSqlName("TRM")+" TRM "
	cQuery += " WHERE "
	cQuery += "       TRM.TRM_NUMSIN = '"+cCodSin+"'"
	cQuery += " AND   TRM.TRM_FILIAL = TRH.TRH_FILIAL "
	cQuery += " AND   TRM.TRM_NUMSIN = TRH.TRH_NUMSIN "
	cQuery += " AND   TRH.D_E_L_E_T_ <> '*' "
	cQuery += " AND   TRM.D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)  

	dbSelectArea(cAliasQry)			   
	dbGoTop()

	nSoma += (cAliasQry)->TOTVALVIT
	(cAliasQry)->(dbCloseArea())


	//PREJUIZOS VEICULOS DE TERCEIROS
	cAliasQry := GetNextAlias()
	cQuery := " SELECT SUM(TRO.TRO_VALPRE) AS TOTVALPRE "
	cQuery += " FROM " + RetSqlName("TRH")+" TRH, "+ RetSqlName("TRO")+" TRO "
	cQuery += " WHERE "
	cQuery += "       TRO.TRO_NUMSIN = '"+cCodSin+"'"
	cQuery += " AND   TRO.TRO_FILIAL = TRH.TRH_FILIAL "
	cQuery += " AND   TRO.TRO_NUMSIN = TRH.TRH_NUMSIN "
	cQuery += " AND   TRH.D_E_L_E_T_ <> '*' "
	cQuery += " AND   TRO.D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)  

	dbSelectArea(cAliasQry)			   
	dbGoTop()

	nSoma += (cAliasQry)->TOTVALPRE
	(cAliasQry)->(dbCloseArea())


	//IMOVEIS DE TERCEIROS
	cAliasQry := GetNextAlias()
	cQuery := " SELECT SUM(TRL.TRL_VALPRE) AS TOTVALPRE "
	cQuery += " FROM " + RetSqlName("TRH")+" TRH, "+ RetSqlName("TRL")+" TRL "
	cQuery += " WHERE "
	cQuery += "       TRL.TRL_NUMSIN = '"+cCodSin+"'"
	cQuery += " AND   TRL.TRL_FILIAL = TRH.TRH_FILIAL "
	cQuery += " AND   TRL.TRL_NUMSIN = TRH.TRH_NUMSIN "
	cQuery += " AND   TRH.D_E_L_E_T_ <> '*' "
	cQuery += " AND   TRL.D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)  

	dbSelectArea(cAliasQry)			   
	dbGoTop()

	nSoma += (cAliasQry)->TOTVALPRE
	(cAliasQry)->(dbCloseArea())


	//CREDITO COMPLEMENTO
	cAliasQry := GetNextAlias()
	cQuery := " SELECT SUM(TRV.TRV_VALRES) AS TOTVALRES "
	cQuery += " FROM " + RetSqlName("TRH")+" TRH, "+ RetSqlName("TRV")+" TRV "
	cQuery += " WHERE "
	cQuery += "       TRV.TRV_NUMSIN = '"+cCodSin+"'"
	cQuery += " AND   TRV.TRV_FILIAL = TRH.TRH_FILIAL "
	cQuery += " AND   TRV.TRV_NUMSIN = TRH.TRH_NUMSIN "
	cQuery += " AND   TRH.D_E_L_E_T_ <> '*' "
	cQuery += " AND   TRV.D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)  

	dbSelectArea(cAliasQry)			   
	dbGoTop()

	nSoma -= (cAliasQry)->TOTVALRES
	(cAliasQry)->(dbCloseArea())


Return nSoma
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNR755FL  ³ Autor ³Ricardo Dal Ponte      ³ Data ³ 16/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³validação do parametro Filial                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR755                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function MNR755FL(nOpc)
	Local cVERFL

	cVERFL := Mv_Par02

	If Empty(mv_par02) .And. (mv_par03 == Replicate('Z',nSizeFil))
		Return .t.
	Else
		If nOpc == 1
			lRet := IIf(Empty(mv_par02),.t.,ExistCpo('SM0',SM0->M0_CODIGO+mv_par02))
			If !lRet
				Return .f.
			EndIf
		EndIf

		If nOpc == 2
			lRet := IIF(ATECODIGO('SM0',SM0->M0_CODIGO+mv_par02,SM0->M0_CODIGO+mv_par03,07),.T.,.F.)
			If !lRet
				Return .f.
			EndIf
		EndIf
	EndIf

Return .t. 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |MNTR755ANO| Autor ³ Marcos Wagner Junior  ³ Data ³ 10/06/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao do Parametro de Ano                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR755                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTR755ANO()

	cAno := AllTrim(Str(MV_PAR01))
	If Len(cAno) != 4
		MsgStop(STR0041,STR0033) //"O Ano informado deverá conter 4 dígitos!"###"Atenção"
		Return .f.
	Endif
	If Val(cAno) > (Year(dDATABASE))
		MsgStop(STR0042+AllTrim(Str(Year(dDATABASE)))+'!',STR0033) //"Ano informado não poderá ser maior que "###"Atenção"
		Return .f.
	Endif

Return .t.
