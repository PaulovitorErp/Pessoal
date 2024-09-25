#INCLUDE "MNTR745.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTR745   ³ Autor ³ Ricardo Dal Ponte     ³ Data ³ 07/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio de Quantidade de Eventos por Grupo de Filiais     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/      
Function MNTR745()  
	
	Private 	nTGHUBJAN := 0                              
	Private 	nTGHUBFEV := 0
	Private 	nTGHUBMAR := 0
	Private 	nTGHUBABR := 0
	Private 	nTGHUBMAI := 0
	Private 	nTGHUBJUN := 0
	Private 	nTGHUBJUL := 0
	Private 	nTGHUBAGO := 0
	Private 	nTGHUBSET := 0
	Private 	nTGHUBOUT := 0
	Private 	nTGHUBNOV := 0
	Private 	nTGHUBDEZ := 0
	Private 	nTGHUBTOT := 0
	Private lGera := .T.

	WNREL      := "MNTR745"
	LIMITE     := 220
	cDESC1     := STR0001 //"O relatório apresentará a quantidade de eventos por grupo "
	cDESC2     := STR0002  //"de filiais, e o prejuízo das cargas afetadas pelo sinistro "
	cDESC3     := STR0003 //"para cada grupo de filial."
	cSTRING    := "TRH"       

	SetKey( VK_F9, { | | NGVersao( "MNTR745" , 1 ) } )

	Private NOMEPROG := "MNTR745"
	Private TAMANHO  := "G"
	Private aRETURN  := {STR0004,1,STR0005,1,2,1,"",1} //"Zebrado"###"Administracao"
	Private TITULO   := STR0006 //"Relatorio de Quantidade de Eventos por Grupo de Filiais"
	Private nTIPO    := 0
	Private nLASTKEY := 0
	Private CABEC1,CABEC2 
	Private aVETINR := {}    
	Private cPERG := "MNT745"   
	Private aPerg :={}

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
	RptStatus({|lEND| MNTR745IMP(@lEND,WNREL,TITULO,TAMANHO)},STR0010,STR0011) //"Aguarde..."###"Processando Registros..."
	Dbselectarea("TRH")  

Return .T.    

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |MNT745IMP | Autor ³ Ricardo Dal Ponte     ³ Data ³ 08/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Chamada do Relat¢rio                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR745                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTR745IMP(lEND,WNREL,TITULO,TAMANHO) 

	Local	nPETOTPREa := 0
	Local	nPETOTMNTa := 0
	Local	nPETOTHUBa := 0

	Local	nGETOTPRE := 0
	Local	nGETOTMNT := 0
	Local	nGETOTHUB := 0

	Local	nGR_TOTPRE := 0
	Local	nGR_TOTMNT := 0
	Local	nGR_TOTHUB := 0
	Local nI

	Local  oTempTable //Obj. Tabela Temporaria

	Private cRODATXT 	:= ""
	Private nCNTIMPR 	:= 0     
	Private li := 80 ,m_pag := 1    
	Private cNomeOri
	Private aVetor 		:= {}
	Private aTotGeral 	:= {}
	Private nAno, nMes 
	Private nTotCarga 	:= 0, nTotManut := 0 
	Private nTotal 		:= 0
	Private cTRB		:= GetNextAlias()

	aDBF :={{"CODHUB", "C", 02, 0},; //codigo hub
	{"DESHUB", "C", 25, 0},; //descricao hub
	{"HUBJAN", "N",  6, 0},; //qtde janeiro
	{"HUBFEV", "N",  6, 0},; //qtde fevereiro
	{"HUBMAR", "N",  6, 0},; //qtde marco
	{"HUBABR", "N",  6, 0},; //qtde abril
	{"HUBMAI", "N",  6, 0},; //qtde maio
	{"HUBJUN", "N",  6, 0},; //qtde junho
	{"HUBJUL", "N",  6, 0},; //qtde julho
	{"HUBAGO", "N",  6, 0},; //qtde agosto
	{"HUBSET", "N",  6, 0},; //qtde setembro
	{"HUBOUT", "N",  6, 0},; //qtde outubro
	{"HUBNOV", "N",  6, 0},; //qtde novembro
	{"HUBDEZ", "N",  6, 0},; //qtde dezembro
	{"HUBTOT", "N",  6, 0},; //qtde total por hub
	{"TOTPRE", "N", 12, 2},; //prejuizo carga
	{"TOTMNT", "N", 12, 2},; //PREJUIZO MANUTENCAO
	{"TOTHUB", "N", 12, 2}}  //PREJUIZO HUB

	//Instancia classe FWTemporaryTable
	oTempTable  := FWTemporaryTable():New( cTRB, aDBF )
	//Cria indices
	oTempTable:AddIndex( "Ind01" , {"CODHUB"}  )
	//Cria a tabela temporaria
	oTempTable:Create()

	Processa({|lEND| MNTR745TMP()},STR0013) //"Processando Arquivo..."

	If !lGera
		oTempTable:Delete()//Deleta Arquivo temporario
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
	ProcRegua(Reccount())

	While !Eof()
		IncProc()

		nTGHUBJAN += (cTRB)->HUBJAN
		nTGHUBFEV += (cTRB)->HUBFEV
		nTGHUBMAR += (cTRB)->HUBMAR
		nTGHUBABR += (cTRB)->HUBABR
		nTGHUBMAI += (cTRB)->HUBMAI
		nTGHUBJUN += (cTRB)->HUBJUN
		nTGHUBJUL += (cTRB)->HUBJUL
		nTGHUBAGO += (cTRB)->HUBAGO
		nTGHUBSET += (cTRB)->HUBSET
		nTGHUBOUT += (cTRB)->HUBOUT
		nTGHUBNOV += (cTRB)->HUBNOV
		nTGHUBDEZ += (cTRB)->HUBDEZ
		nTGHUBTOT += (cTRB)->HUBTOT

		nGR_TOTPRE += (cTRB)->TOTPRE
		nGR_TOTMNT += (cTRB)->TOTMNT
		nGR_TOTHUB += (cTRB)->TOTHUB

		dbSelectArea(cTRB)		   
		dbSkip()
	End

	DbSelectArea(cTRB)
	DbGoTop()  
	SetRegua(Reccount())

	While !Eof()
		IncRegua()

		If lPri = .T.  
			NgSomaLi(58)
			@ Li,000 	 Psay STR0041 //"Grupo de Filial"
			@ Li,027 	 Psay "|"
			@ Li,029 	 Psay STR0014 //"JAN"
			@ Li,036 	 Psay STR0015 //"FEV"
			@ Li,043 	 Psay STR0016 //"MAR"
			@ Li,050 	 Psay STR0017 //"ABR"
			@ Li,057 	 Psay STR0018 //"MAI"
			@ Li,064 	 Psay STR0019 //"JUN"
			@ Li,071 	 Psay STR0020 //"JUL"
			@ Li,078 	 Psay STR0021 //"AGO"
			@ Li,085 	 Psay STR0022 //"SET"
			@ Li,092 	 Psay STR0023 //"OUT"
			@ Li,099 	 Psay STR0024 //"NOV"
			@ Li,106 	 Psay STR0025 //"DEZ"
			@ Li,113 	 Psay STR0026 //"TOTAL"

			@ Li,122 	 Psay "  "+STR0027 //"PREJ.CARGA"
			@ Li,135 	 Psay "   "+"%"
			@ Li,142 	 Psay " "+STR0028 //"%AC"

			@ Li,156 	 Psay "   "+STR0029 //"PREJ. MNT"
			@ Li,169 	 Psay "   "+"%"
			@ Li,176 	 Psay " "+STR0028 //"%AC"

			@ Li,190 	 Psay "  "+STR0030 //"PREJ.TOTAL"
			@ Li,203 	 Psay "   "+"%"
			@ Li,210 	 Psay " "+STR0028 //"%AC"

			NgSomaLi(58)
			@ Li,000 	 Psay Replicate("-",220)
			NgSomaLi(58) 

			lPri := .F.  
		EndIf

		@ Li,000 	 Psay (cTRB)->DESHUB
		@ Li,027 	 Psay "|"
		@ Li,029 	 Psay (cTRB)->HUBJAN Picture "999"
		@ Li,036 	 Psay (cTRB)->HUBFEV Picture "999"
		@ Li,043 	 Psay (cTRB)->HUBMAR Picture "999"
		@ Li,050 	 Psay (cTRB)->HUBABR Picture "999"
		@ Li,057 	 Psay (cTRB)->HUBMAI Picture "999"
		@ Li,064 	 Psay (cTRB)->HUBJUN Picture "999"
		@ Li,071 	 Psay (cTRB)->HUBJUL Picture "999"
		@ Li,078 	 Psay (cTRB)->HUBAGO Picture "999"
		@ Li,085 	 Psay (cTRB)->HUBSET Picture "999"
		@ Li,092 	 Psay (cTRB)->HUBOUT Picture "999"
		@ Li,099 	 Psay (cTRB)->HUBNOV Picture "999"
		@ Li,106 	 Psay (cTRB)->HUBDEZ Picture "999"
		@ Li,113 	 Psay (cTRB)->HUBTOT Picture "9,999"

		cPETOTPRE := Round((((cTRB)->TOTPRE/nGR_TOTPRE) *100), 0)
		cPETOTMNT := Round((((cTRB)->TOTMNT/nGR_TOTMNT) *100), 0)
		cPETOTHUB := Round((((cTRB)->TOTHUB/nGR_TOTHUB) *100), 0)

		nPETOTPREa += cPETOTPRE
		nPETOTMNTa += cPETOTMNT
		nPETOTHUBa += cPETOTHUB

		@ Li,120 	 Psay (cTRB)->TOTPRE Picture "@E 999,999,999.99"
		@ Li,135 	 Psay Transform(cPETOTPRE,"@E 999")+"%"

		If lPriAcum = .T.
			@ Li,142 	 Psay Transform(cPETOTPRE,"@E 999")+"%"
		Else
			@ Li,142 	 Psay Transform(nPETOTPREa,"@E 999")+"%"
		EndIf

		@ Li,154 	 Psay (cTRB)->TOTMNT Picture "@E 999,999,999.99"
		@ Li,169 	 Psay Transform(cPETOTMNT,"@E 999")+"%"

		If lPriAcum = .T.
			@ Li,176 	 Psay Transform(cPETOTMNT,"@E 999")+"%"
		Else
			@ Li,176 	 Psay Transform(nPETOTMNTa,"@E 999")+"%"
		EndIf

		@ Li,188 	 Psay (cTRB)->TOTHUB Picture "@E 999,999,999.99"
		@ Li,203 	 Psay Transform(cPETOTHUB,"@E 999")+"%"

		If lPriAcum = .T.
			@ Li,210 	 Psay Transform(cPETOTHUB,"@E 999")+"%"
		Else
			@ Li,210 	 Psay Transform(nPETOTHUBa,"@E 999")+"%"
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
		@ Li,000 	 Psay STR0026 //"TOTAL"
		@ Li,027 	 Psay "|"
		@ Li,029 	 Psay nTGHUBJAN Picture "999"
		@ Li,036 	 Psay nTGHUBFEV Picture "999"
		@ Li,043 	 Psay nTGHUBMAR Picture "999"
		@ Li,050 	 Psay nTGHUBABR Picture "999"
		@ Li,057 	 Psay nTGHUBMAI Picture "999"
		@ Li,064 	 Psay nTGHUBJUN Picture "999"
		@ Li,071 	 Psay nTGHUBJUL Picture "999"
		@ Li,078 	 Psay nTGHUBAGO Picture "999"
		@ Li,085 	 Psay nTGHUBSET Picture "999"
		@ Li,092 	 Psay nTGHUBOUT Picture "999"
		@ Li,099 	 Psay nTGHUBNOV Picture "999"
		@ Li,106 	 Psay nTGHUBDEZ Picture "999"
		@ Li,113 	 Psay nTGHUBTOT Picture "9,999"

		@ Li,120 	 Psay nGR_TOTPRE Picture "@E 999,999,999.99"
		@ Li,135 	 Psay Transform(Round(((nGR_TOTPRE /nGR_TOTPRE) *100), 0),"@E 999")+"%"
		@ Li,142 	 Psay Transform(Round(((nGR_TOTPRE /nGR_TOTPRE) *100), 0),"@E 999")+"%"
		@ Li,154 	 Psay nGR_TOTMNT Picture "@E 999,999,999.99"
		@ Li,169 	 Psay Transform(Round(((nGR_TOTMNT /nGR_TOTMNT) *100), 0),"@E 999")+"%"
		@ Li,176 	 Psay Transform(Round(((nGR_TOTMNT /nGR_TOTMNT) *100), 0),"@E 999")+"%"
		@ Li,188 	 Psay nGR_TOTHUB Picture "@E 999,999,999.99"
		@ Li,203 	 Psay Transform(Round(((nGR_TOTHUB /nGR_TOTHUB) *100), 0),"@E 999")+"%"
		@ Li,210 	 Psay Transform(Round(((nGR_TOTHUB /nGR_TOTHUB) *100), 0),"@E 999")+"%"
	EndIF
  
	oTempTable:Delete()//Deleta arquivo temporario

	RODA(nCNTIMPR,cRODATXT,TAMANHO)

	//³ Devolve a condicao original do arquivo principal             ³
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
±±³Fun‡…o    |MNTR745VAL| Autor ³ Ricardo Dal Ponte     ³ Data ³ 08/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao dos Parametros	                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR745                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTR745VAL() 

	If !Empty(MV_PAR02) .AND. !Empty(MV_PAR03)
		If MV_PAR02 > MV_PAR03
			MsgStop(STR0031,STR0032) //"De Grupo de Filial não pode ser maior que Até Grupo de Filial!"###"Atenção"
			Return .f.	
		Endif
	Endif
Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |MNTR745TMP| Autor ³ Ricardo Dal Ponte     ³ Data ³ 08/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Geracao do arquivo temporario                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR745                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function MNTR745TMP()
	cAliasQry := GetNextAlias()
	cQuery := " SELECT TRW.TRW_HUB, TRW.TRW_DESHUB, TRH.TRH_DTACID, TRH.TRH_NUMSIN"
	cQuery += " FROM " + RetSqlName("TRH")+" TRH, " + RetSqlName("TSL")+" TSL, " + RetSqlName("TRW")+" TRW "
	cQuery += " WHERE "
	cQuery += "       (TRH.TRH_DTACID  >= '"+AllTrim(Str(MV_PAR01))+"0101'"
	cQuery += " AND    TRH.TRH_DTACID  <= '"+AllTrim(Str(MV_PAR01))+"1231')"
	cQuery += " AND   TSL.TSL_HUB     >= '"+MV_PAR02+"'"
	cQuery += " AND   TSL.TSL_HUB     <= '"+MV_PAR03+"'"
	cQuery += " AND   TRH.TRH_EVENTO   = '"+AllTrim(Str(MV_PAR04))+"'"
	cQuery += " AND   TRH.TRH_TIPACI  >= '"+MV_PAR05+"'"
	cQuery += " AND   TRH.TRH_TIPACI  <= '"+MV_PAR06+"'"
	If NGSX2MODO("TRH") == NGSX2MODO("TSL")
		cQuery += " AND   TRH.TRH_FILIAL = TSL.TSL_FILIAL "
	Else
		cQuery += " AND TRH.TRH_FILIAL = '"+xFilial("TRH")+"' AND TSL.TSL_FILIAL = '"+xFilial("TSL")+"' "
	EndIf
	If NGSX2MODO("TRH") == "E"
		cQuery += " AND   TRH.TRH_FILIAL = TSL.TSL_FILMS "
	EndIf
	If NGSX2MODO("TSL") == NGSX2MODO("TRW")
		cQuery += " AND   TSL.TSL_FILIAL = TRW.TRW_FILIAL "
	Else
		cQuery += " AND TSL.TSL_FILIAL = '"+xFilial("TSL")+"' AND TRW.TRW_FILIAL = '"+xFilial("TRW")+"' "
	EndIf
	cQuery += " AND   TSL.TSL_HUB     = TRW.TRW_HUB  "
	cQuery += " AND   TRH.D_E_L_E_T_ <> '*' "
	cQuery += " AND   TSL.D_E_L_E_T_ <> '*' "
	cQuery += " AND   TRW.D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)  

	dbSelectArea(cAliasQry)			   
	dbGoTop()

	If Eof()
		MsgInfo(STR0033,STR0032) //"Não existem dados para montar o relatório!"###"ATENÇÃO"
		(cAliasQry)->(dbCloseArea())
		lGera := .f.   
		Return
	Endif

	SetRegua(Reccount())

	While !Eof()	
		IncRegua()

		dbSelectArea(cTRB)
		dbSetOrder(1)

		If !dbSeek((cAliasQry)->TRW_HUB)
			RecLock((cTRB), .T.)
			(cTRB)->CODHUB := (cAliasQry)->TRW_HUB
			(cTRB)->DESHUB := (cAliasQry)->TRW_DESHUB

			(cTRB)->HUBJAN := 0 //qtde janeiro
			(cTRB)->HUBFEV := 0 //qtde fevereiro
			(cTRB)->HUBMAR := 0 //qtde marco
			(cTRB)->HUBABR := 0 //qtde abril
			(cTRB)->HUBMAI := 0 //qtde maio
			(cTRB)->HUBJUN := 0 //qtde junho
			(cTRB)->HUBJUL := 0 //qtde julho
			(cTRB)->HUBAGO := 0 //qtde agosto
			(cTRB)->HUBSET := 0 //qtde setembro
			(cTRB)->HUBOUT := 0 //qtde outubro
			(cTRB)->HUBNOV := 0 //qtde novembro
			(cTRB)->HUBDEZ := 0 //qtde dezembro
			(cTRB)->HUBTOT := 0 //TOTAL
			(cTRB)->TOTPRE := 0 //PREJUIZO CARGA
			(cTRB)->TOTMNT := 0 //PREJUIZO MANUTENCAO
			(cTRB)->TOTHUB := 0 //PREJUIZO HUB
		Else
			RecLock((cTRB), .F.)
		EndiF

		nMes := Val(SubStr((cAliasQry)->TRH_DTACID,5,2))

		Do Case 	
			Case nMes = 1; (cTRB)->HUBJAN += 1 //qtde janeiro
			Case nMes = 2; (cTRB)->HUBFEV += 1 //qtde fevereiro
			Case nMes = 3; (cTRB)->HUBMAR += 1 //qtde marco
			Case nMes = 4; (cTRB)->HUBABR += 1 //qtde abril
			Case nMes = 5; (cTRB)->HUBMAI += 1 //qtde maio
			Case nMes = 6; (cTRB)->HUBJUN += 1 //qtde junho
			Case nMes = 7; (cTRB)->HUBJUL += 1 //qtde julho
			Case nMes = 8; (cTRB)->HUBAGO += 1 //qtde agosto
			Case nMes = 9; (cTRB)->HUBSET += 1 //qtde setembro
			Case nMes = 10; (cTRB)->HUBOUT += 1 //qtde outubro
			Case nMes = 11; (cTRB)->HUBNOV += 1 //qtde novembro
			Case nMes = 12; (cTRB)->HUBDEZ += 1 //qtde dezembro
		End Case

		(cTRB)->HUBTOT += 1 //TOTAL

		(cTRB)->TOTPRE += R745CAR((cAliasQry)->TRH_NUMSIN) //PREJUIZO CARGA

		nTTmanu := R745MNT((cAliasQry)->TRH_NUMSIN) //PREJUIZO MANUTENCAO
		(cTRB)->TOTMNT += nTTmanu

		(cTRB)->TOTHUB += nTTmanu + R745HUB((cAliasQry)->TRH_NUMSIN) //PREJUIZO HUB

		MsUnLock(cTRB)

		dbSelectArea(cAliasQry)			   
		dbSkip()
	End

	(cAliasQry)->(dbCloseArea())

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |R745CAR   | Autor ³ Ricardo Dal Ponte     ³ Data ³ 08/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega os valores dos sinistros                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR745                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function R745CAR(cCodSin)
	Local cAliasTRK := GetNextAlias()
	Local cQueryTRK
	Local nPrejuTRK

	cQueryTRK := " SELECT SUM(TRK_VALAVA) AS TTAVARIA, SUM(TRK_VALREC) AS TVALOREC "
	cQueryTRK += " FROM " + RetSqlName("TRH")+" TRH, " + RetSqlName("TRK")+" TRK "
	cQueryTRK += " WHERE "
	//cQueryTRK += "       (TRH.TRH_DTACID  >= '"+AllTrim(Str(MV_PAR01))+"0101'"
	//cQueryTRK += " AND    TRH.TRH_DTACID  <= '"+AllTrim(Str(MV_PAR01))+"1231')"
	cQueryTRK += "       TRK.TRK_NUMSIN = '"+cCodSin+"'"
	cQueryTRK += " AND   TRH.TRH_FILIAL = TRK.TRK_FILIAL "
	cQueryTRK += " AND   TRH.TRH_NUMSIN = TRK.TRK_NUMSIN "
	cQueryTRK += " AND   TRH.D_E_L_E_T_ <> '*' "
	cQueryTRK += " AND   TRK.D_E_L_E_T_ <> '*' "
	cQueryTRK := ChangeQuery(cQueryTRK)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryTRK),cAliasTRK, .F., .T.)  

	dbSelectArea(cAliasTRK)			   
	dbGoTop()

	nPrejuTRK := (cAliasTRK)->TTAVARIA - (cAliasTRK)->TVALOREC

	(cAliasTRK)->(dbCloseArea())

Return nPrejuTRK

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |R745MNT   | Autor ³ Ricardo Dal Ponte     ³ Data ³ 08/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega os valores de prejuizos da manutencao por HUB       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR745                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function R745MNT(cCodSin)
	Local cAliasMNT := GetNextAlias()
	Local cQueryMNT
	Local nSoma
	Local lIndSTJ := If(NgVerify("STL"),.t.,.f.)

	cQueryMNT := " SELECT STJ.TJ_ORDEM, STL.TL_CUSTO,"
	If lIndSTJ
		cQueryMNT += " STL.TL_SEQRELA "
	Else
		cQueryMNT += " STL.TL_SEQUENC "
	Endif
	cQueryMNT += " FROM " + RetSqlName("TRH")+" TRH, " + RetSqlName("TRT")+" TRT, " + RetSqlName("STJ")+" STJ, "+ RetSqlName("STL")+" STL "
	cQueryMNT += " WHERE "
	cQueryMNT += "       TRT.TRT_NUMSIN = '"+cCodSin+"'"
	If NGSX2MODO("TRH") == NGSX2MODO("TRT")
		cQueryMNT += " AND   TRH.TRH_FILIAL  = TRT.TRT_FILIAL "
	Else
		cQueryMNT += " AND TRH.TRH_FILIAL = '"+xFilial("TRH")+"' AND TRT.TRT_FILIAL = '"+xFilial("TRT")+"' "
	EndIf
	cQueryMNT += " AND   TRT.TRT_NUMSIN = TRH.TRH_NUMSIN "
	If NGSX2MODO("STJ") == NGSX2MODO("TRT")
		cQueryMNT += " AND   STJ.TJ_FILIAL  = TRT.TRT_FILIAL "
	Else
		cQueryMNT += " AND STJ.TJ_FILIAL = '"+xFilial("STJ")+"' AND TRT.TRT_FILIAL = '"+xFilial("TRT")+"' "
	EndIf
	cQueryMNT += " AND   STJ.TJ_ORDEM   = TRT.TRT_NUMOS "
	cQueryMNT += " AND   STJ.TJ_PLANO   = TRT.TRT_PLANO "
	cQueryMNT += " AND   STJ.TJ_SITUACA = 'L' "
	If NGSX2MODO("STJ") == NGSX2MODO("STL")
		cQueryMNT += " AND   STJ.TJ_FILIAL  = STL.TL_FILIAL "
	Else
		cQueryMNT += " AND STJ.TJ_FILIAL = '"+xFilial("STJ")+"' AND STL.TL_FILIAL = '"+xFilial("STL")+"' "
	EndIf
	cQueryMNT += " AND   STL.TL_ORDEM  = STJ.TJ_ORDEM "
	cQueryMNT += " AND   STL.TL_PLANO  = STJ.TJ_PLANO "
	cQueryMNT += " AND   TRH.D_E_L_E_T_ <> '*' "
	cQueryMNT += " AND   TRT.D_E_L_E_T_ <> '*' "
	cQueryMNT += " AND   STJ.D_E_L_E_T_ <> '*' "
	cQueryMNT += " AND   STL.D_E_L_E_T_ <> '*' "
	cQueryMNT := ChangeQuery(cQueryMNT)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryMNT),cAliasMNT, .F., .T.)  

	dbSelectArea(cAliasMNT)			   
	dbGoTop()

	If Eof()
		Return 0
	Endif

	nSoma := 0

	While !Eof()
		If lIndSTJ
			If AllTrim((cAliasMNT)->TL_SEQRELA) <> "0"
				nSoma += (cAliasMNT)->TL_CUSTO
			Endif
		Else
			If (cAliasMNT)->TL_SEQUENC <> 0
				nSoma += (cAliasMNT)->TL_CUSTO
			Endif
		Endif

		dbSelectArea(cAliasMNT)			   
		dbSkip()
	End

	(cAliasMNT)->(dbCloseArea())

Return nSoma 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |R745HUB   | Autor ³ Ricardo Dal Ponte     ³ Data ³ 08/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega os valores de prejuizos por HUB                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR745                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function R745HUB(cCodSin)
	Local cAliasHUB1 := GetNextAlias()
	Local cAliasHUB2 := GetNextAlias()
	Local cAliasHUB3 := GetNextAlias()
	Local cAliasHUB4 := GetNextAlias()
	Local cAliasHUB5 := GetNextAlias()
	Local cAliasHUB6 := GetNextAlias()
	Local cQueryHUB
	Local nSoma := 0

	//PREJUIZOS ANIMAIS POR GUINCHO
	cQueryHUB := " SELECT SUM(TRH.TRH_VALANI) AS TOTVALANI, SUM(TRH.TRH_VALGUI) AS TOTVALGUI"
	cQueryHUB += " FROM " + RetSqlName("TRH")+" TRH "
	cQueryHUB += " WHERE "
	cQueryHUB += "       TRH.TRH_NUMSIN = '"+cCodSin+"'"
	cQueryHUB += " AND   TRH.D_E_L_E_T_ <> '*' "
	cQueryHUB := ChangeQuery(cQueryHUB)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryHUB),cAliasHUB1, .F., .T.)  

	dbSelectArea(cAliasHUB1)			   
	dbGoTop()

	nSoma += (cAliasHUB1)->TOTVALANI
	nSoma += (cAliasHUB1)->TOTVALGUI
	(cAliasHUB1)->(dbCloseArea())

	//PREJUIZOS VITIMAS
	cQueryHUB := " SELECT SUM(TRM.TRM_VALVIT) AS TOTVALVIT "
	cQueryHUB += " FROM " + RetSqlName("TRH")+" TRH, "+ RetSqlName("TRM")+" TRM "
	cQueryHUB += " WHERE "
	cQueryHUB += "       TRM.TRM_NUMSIN = '"+cCodSin+"'"
	cQueryHUB += " AND   TRM.TRM_FILIAL = TRH.TRH_FILIAL "
	cQueryHUB += " AND   TRM.TRM_NUMSIN = TRH.TRH_NUMSIN "
	cQueryHUB += " AND   TRH.D_E_L_E_T_ <> '*' "
	cQueryHUB += " AND   TRM.D_E_L_E_T_ <> '*' "
	cQueryHUB := ChangeQuery(cQueryHUB)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryHUB),cAliasHUB2, .F., .T.)  

	dbSelectArea(cAliasHUB2)			   
	dbGoTop()

	nSoma += (cAliasHUB2)->TOTVALVIT
	(cAliasHUB2)->(dbCloseArea())

	//PREJUIZOS CARGAS
	cQueryHUB := " SELECT SUM(TRK.TRK_VALAVA) AS TOTVALAVA, SUM(TRK.TRK_VALREC) AS TOTVALREC "
	cQueryHUB += " FROM " + RetSqlName("TRH")+" TRH, "+ RetSqlName("TRK")+" TRK "
	cQueryHUB += " WHERE "
	cQueryHUB += "       TRK.TRK_NUMSIN = '"+cCodSin+"'"
	cQueryHUB += " AND   TRK.TRK_FILIAL = TRH.TRH_FILIAL "
	cQueryHUB += " AND   TRK.TRK_NUMSIN = TRH.TRH_NUMSIN "
	cQueryHUB += " AND   TRH.D_E_L_E_T_ <> '*' "
	cQueryHUB += " AND   TRK.D_E_L_E_T_ <> '*' "
	cQueryHUB := ChangeQuery(cQueryHUB)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryHUB),cAliasHUB3, .F., .T.)  

	dbSelectArea(cAliasHUB3)			   
	dbGoTop()

	nSoma += (cAliasHUB3)->TOTVALAVA - (cAliasHUB3)->TOTVALREC
	(cAliasHUB3)->(dbCloseArea())

	//PREJUIZOS VEICULOS DE TERCEIROS
	cQueryHUB := " SELECT SUM(TRO.TRO_VALPRE) AS TOTVALPRE "
	cQueryHUB += " FROM " + RetSqlName("TRH")+" TRH, "+ RetSqlName("TRO")+" TRO "
	cQueryHUB += " WHERE "
	cQueryHUB += "       TRO.TRO_NUMSIN = '"+cCodSin+"'"
	cQueryHUB += " AND   TRO.TRO_FILIAL = TRH.TRH_FILIAL "
	cQueryHUB += " AND   TRO.TRO_NUMSIN = TRH.TRH_NUMSIN "
	cQueryHUB += " AND   TRH.D_E_L_E_T_ <> '*' "
	cQueryHUB += " AND   TRO.D_E_L_E_T_ <> '*' "
	cQueryHUB := ChangeQuery(cQueryHUB)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryHUB),cAliasHUB4, .F., .T.)  

	dbSelectArea(cAliasHUB4)			   
	dbGoTop()

	nSoma += (cAliasHUB4)->TOTVALPRE
	(cAliasHUB4)->(dbCloseArea())

	//IMOVEIS DE TERCEIROS
	cQueryHUB := " SELECT SUM(TRL.TRL_VALPRE) AS TOTVALPRE "
	cQueryHUB += " FROM " + RetSqlName("TRH")+" TRH, "+ RetSqlName("TRL")+" TRL "
	cQueryHUB += " WHERE "
	cQueryHUB += "       TRL.TRL_NUMSIN = '"+cCodSin+"'"
	cQueryHUB += " AND   TRL.TRL_FILIAL = TRH.TRH_FILIAL "
	cQueryHUB += " AND   TRL.TRL_NUMSIN = TRH.TRH_NUMSIN "
	cQueryHUB += " AND   TRH.D_E_L_E_T_ <> '*' "
	cQueryHUB += " AND   TRL.D_E_L_E_T_ <> '*' "
	cQueryHUB := ChangeQuery(cQueryHUB)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryHUB),cAliasHUB5, .F., .T.)  

	dbSelectArea(cAliasHUB5)			   
	dbGoTop()

	nSoma += (cAliasHUB5)->TOTVALPRE
	(cAliasHUB5)->(dbCloseArea())

	//RESTITUICAO
	cQueryHUB := " SELECT SUM(TRV.TRV_VALRES) AS TOTVALRES "
	cQueryHUB += " FROM " + RetSqlName("TRH")+" TRH, "+ RetSqlName("TRV")+" TRV "
	cQueryHUB += " WHERE "
	cQueryHUB += "       TRV.TRV_NUMSIN = '"+cCodSin+"'"
	cQueryHUB += " AND   TRV.TRV_DTRESS <= '"+DTOS(dDataBase)+"'"
	cQueryHUB += " AND   TRV.TRV_FILIAL = TRH.TRH_FILIAL "
	cQueryHUB += " AND   TRV.TRV_NUMSIN = TRH.TRH_NUMSIN "
	cQueryHUB += " AND   TRH.D_E_L_E_T_ <> '*' "
	cQueryHUB += " AND   TRV.D_E_L_E_T_ <> '*' "
	cQueryHUB := ChangeQuery(cQueryHUB)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryHUB),cAliasHUB6, .F., .T.)  

	dbSelectArea(cAliasHUB6)			   
	dbGoTop()

	nSoma -= (cAliasHUB6)->TOTVALRES
	(cAliasHUB6)->(dbCloseArea())

Return nSoma 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |MNTR745ANO| Autor ³ Marcos Wagner Junior  ³ Data ³ 12/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao dos Parametros	                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR745                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTR745ANO()

	cAno := AllTrim(Str(MV_PAR01))
	If Len(cAno) != 4
		MsgStop(STR0042,STR0032) //"O Ano informado deverá conter 4 dígitos!"###"Atenção"
		Return .f.
	Endif
	If MV_PAR01 > Year(dDATABASE)
		MsgStop(STR0040+AllTrim(Str(Year(dDATABASE)))+'!',STR0032) //"Ano informado não poderá ser maior que "###"Atenção"
		Return .f.
	Endif

Return .t.