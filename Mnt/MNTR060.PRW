#INCLUDE "MNTR060.ch"
#Include "Protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MNTR060 ³ Autor ³ Marcos Wagner Junior  ³ Data ³ 12/08/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio da Parte Diaria									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTR060()

	//Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	Local aNGBEGINPRM := NGBEGINPRM()

	//Define Variaveis
	Local wnrel   := "MNTR060"
	Local limite  := 132
	Local cDesc1  := STR0001 //"Programa de impressão da parte diária."
	Local cDesc2  := ""
	Local cDesc3  := ""
	Local cString := "ST9"

	Private nomeprog := "MNTR060"
	Private tamanho  := "M"
	Private aReturn  := { STR0002, 1,STR0003, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
	Private titulo   := STR0004 //"Impressão da Parte Diária"
	Private ntipo    := 0
	Private nLastKey := 0
	Private cPerg    := "MNT060    "
	Private cabec1, cabec2
	cabec1 := " "
	cabec2 := " "

	Pergunte(cPERG,.F.)

	//Devolve variaveis armazenadas (NGRIGHTCLICK)
	WNREL:=SetPrint(cSTRING,WNREL,cPERG,TITULO,cDESC1,cDESC2,cDESC3,.F.,"")
	If nLASTKEY = 27
	Set Filter To
	dbSelectArea("ST9")
	Return
	EndIf
	SetDefault(aReturn,cSTRING)
	RptStatus({|lEND| RImp060(@lEND,WNREL,TITULO,TAMANHO)},TITULO)
	dbSelectArea("ST9")

	NGRETURNPRM(aNGBEGINPRM)

Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OAS1R3RE ³ Autor ³ Marcos Wagner Junior  ³ Data ³ 12/08/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do Relat¢rio modelo grafico                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTR060                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function RImp060( lEnd,wnRel,titulo,tamanho )

Local cSMCOD := If(FindFunction("FWGrpCompany"),FWGrpCompany(),SM0->M0_CODIGO)
Local cSMFIL := If(FindFunction("FWCodFil"),FWCodFil(),SM0->M0_CODFIL)
Local nI
Local cBARRAS   := If(isSRVunix(),"/","\")
Local cRootPath := Alltrim(GetSrvProfString("RootPath",cBARRAS))
Local cStartPath := AllTrim(GetSrvProfString("StartPath",cBARRAS))
Local cDirExe  := cRootPath+cStartPath
Private oFont07, oFont11
Private oPrint := TMSPrinter():New( OemToAnsi(STR0015) ) //"Parte Diária"
Private lin := 100
oPrint:Setup()
oPrint:SetLandscape()  //Default Paisagem

oFont07 := TFont():New("COURIER",07,07,,.T.,,,,.T.,.F.)
oFont11 := TFont():New("COURIER",11,11,,.T.,,,,.T.,.F.)

cAliasQry := GetNextAlias()
cQuery := " SELECT ST9.T9_CODBEM, ST9.T9_NOME, ST9.T9_PLACA "
cQuery += " FROM " + NGRETX2("ST9")+" ST9 "
cQuery += " WHERE ST9.T9_CODFAMI >= '" + MV_PAR01 + "' AND ST9.T9_CODFAMI <= '" + MV_PAR02 + "'"
cQuery += " AND   ST9.T9_TIPMOD  >= '" + MV_PAR03 + "' AND ST9.T9_TIPMOD  <= '" + MV_PAR04 + "'"
cQuery += " AND   ST9.T9_CODBEM  >= '" + MV_PAR05 + "' AND ST9.T9_CODBEM  <= '" + MV_PAR06 + "'"
cQuery += " AND   ST9.T9_PARTEDI = '1' "
cQuery += " AND   ST9.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY ST9.T9_CODBEM "
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

dbSelectArea(cAliasQry)
dbGoTop()
While !Eof()
	dMV_PAR07 := MV_PAR07
	While MV_PAR08 >= dMV_PAR07
		oPrint:StartPage()
		If File("LGRL"+cSMCOD+cSMFIL+".BMP")
			oPrint:SayBitMap(lin,55,"LGRL"+cSMCOD+cSMFIL+".BMP",120,120)
		ElseIf File("LGRL"+cSMCOD+".BMP")
			oPrint:SayBitMap(lin,55,"LGRL"+cSMCOD+".BMP",120,120)
		ElseIf File("\SIGAADV\LGRL"+cSMCOD+cSMFIL+".BMP")
			oPrint:SayBitMap(lin,55,"\SIGAADV\LGRL"+cSMCOD+cSMFIL+".BMP",120,120)
		ElseIf File("\SIGAADV\LGRL"+cSMCOD+".BMP")
			oPrint:SayBitMap(lin,55,"\SIGAADV\LGRL"+cSMCOD+".BMP",120,120)
		Endif
		oPrint:Say(lin,200,'OBRA: ' + AllTrim(SM0->M0_CODFIL) + ' - ' + AllTrim(SM0->M0_NOME) + '               EQPTO: ' + AllTrim((cAliasQry)->T9_CODBEM) + ' - ' + AllTrim((cAliasQry)->T9_NOME) +'               Código/Placa: ' + (cAliasQry)->T9_PLACA + '               Data: '+DTOC(dMV_PAR07),oFont07)
		dMV_PAR07 += 1

//		Caixas(7,2135)
//		oPrint:Say(lin,2630,,oFont07)

		Somalinha()
		oPrint:Say(lin,200,'Horímetro Início:',oFont07)
		Caixas(5,470)
		oPrint:Say(lin,700,'Final:',oFont07)
		Caixas(5,810)
		oPrint:Say(lin,1055,'Turno:_________ Até:_________  Proprietário/Terceiro:______________________________________  Operador:______________________________________ ',oFont07)
		Somalinha()

		CabecHoras()
		Somalinha(30)

		oPrint:Line(lin,50,lin,570)//Horizontal
		_nCol := 40
		nMudaMinuto := 1
		oPrint:Line(lin,50,lin+40,50) //Linha vertical da esquerda
		oPrint:Say(lin,170,'Motivos de Parada',oFont07)
		For nI := 1 To 60
			oPrint:Line(lin,530+_nCol,lin+30,530+_nCol)
			If nMudaMinuto == 1
				oPrint:Say(lin,530+_nCol+12,'0',oFont07)
			ElseIf nMudaMinuto == 2
				oPrint:Say(lin,530+_nCol+5,'15',oFont07)
			ElseIf nMudaMinuto == 3
				oPrint:Say(lin,530+_nCol+5,'30',oFont07)
			ElseIf nMudaMinuto == 4
				oPrint:Say(lin,530+_nCol+5,'45',oFont07)
				nMudaMinuto := 0
			Endif
			_nCol += 40
			nMudaMinuto += 1
		Next
		oPrint:Say(lin,530+_nCol+45,'do dia',oFont07)
		oPrint:Line(lin,530+_nCol,lin+30,530+_nCol)//Ultima linha, depois do 45 (minutos)
		_nCol += 120
		SomaLinha(40)

		dbSelectArea("TV0") // Cadastro de Atividades
		dbGoTop()
		While !Eof()
			If TV0->TV0_TIPHOR <> '1'
				oPrint:Line(lin-10,50,lin+40,50) //Linha vertical da esquerda
				oPrint:Say(lin-8,60,TV0->TV0_CODATI + ' - ' + SubStr(TV0->TV0_NOME,1,16),oFont07)
				oPrint:Say(lin+11,60,SubStr(TV0->TV0_NOME,17,24),oFont07)
				oPrint:Line(lin-10,440,lin+40,440) //2a Linha vertical
				If !Empty(TV0->TV0_BITMAP)
					cArqTV0 := cStartPath+AllTrim(TV0->TV0_BITMAP)
					//Exporta imagem para BMP para funcionar com o TMSPrinter
					oBmp := TBitmap():New(0,0,0,0,,,.T.,,,,,.F.,,,,,.T.)
					oBmp:Hide()
					If File(cArqTV0+".PNG")
						oBmp:Load(,cArqTV0+".PNG")
						oPrint:sayBitMap(lin-10,441,"ABAST.PNG",129,50)
					ElseIf File(cArqTV0+".JPG")
						oBmp:Load(,cArqTV0+".JPG")
						oPrint:sayBitMap(lin-10,441,"ABAST.JPG",129,50)
					ElseIf File(cArqTV0+".JPEG")
						oBmp:Load(,cArqTV0+".JPEG")
						oPrint:sayBitMap(lin-10,441,"ABAST.JPEG",129,50)
					Else
						cArqTV0 := cDirExe+AllTrim(TV0->TV0_BITMAP)
						oPrint:sayBitMap(lin-10,441,Lower(cArqTV0+".BMP"),129,50) //440 a 570
					Endif
				Endif

				_nCol := 40
				For nI := 1 To 60
					oPrint:Line(lin-10,530+_nCol,lin+40,530+_nCol)
					_nCol += 40
				Next
				oPrint:Line(lin-10,530+_nCol,lin+40,530+_nCol)//Ultima linha, depois do 45 (minutos)
				_nCol += 120
				oPrint:Line(lin-10,3150,lin+40,3150)
				oPrint:Line(lin-10,50,lin-10,3150)
				SomaLinha()
			Endif
			dbSkip()
		End
		oPrint:Line(lin-10,50,lin-10,3150)

		CabecFrent()
		ListaCC()
		CabecObs()
		Assinatura()
		oPrint:EndPage()
		lin := 100
   End
	dbSelectArea(cAliasQry)
	dbSkip()
End

RetIndex("ST9")
Set Filter To
Set device to Screen

If aReturn[5] = 1
	oPrint:Preview()
Else
	oPrint:Print()
Endif

Set Device To Screen
If aRETURN[5] == 1
	Set Printer To
	dbCommitAll()
//	OurSpool(WNREL)
EndIf
MS_FLUSH()

Return NIL
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ SomaLinha³ Autor ³ Inacio Luiz Kolling   ³ Data ³   /06/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Incrementa Linha e Controla Salto de Pagina                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ SomaLinha()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTR405                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function Somalinha(linhas,lSimulacao)

Default linhas := 50

lin += linhas
If lin > 2200
	If lSimulacao
		lin -= linhas
	Endif
	lin+=180
EndIf

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³  Caixas  ³ Autor ³ Marcos Wagner Junior  ³ Data ³ 12/08/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Incrementa Linha e Controla Salto de Pagina                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ Caixas(_nCaixas,_nCol)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ _nCaixas: Quantidade de caixas a serem criadas             ³±±
±±³          ³ _nCol:    Coluna na qual comecara a ser impressa a caixa   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTR060                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function Caixas(_nCaixas,_nCol)
Local nI := 1, nTam := 0

For nI := 1 to _nCaixas
	oPrint:Box(lin-10,_nCol+nTam,lin+40,_nCol+nTam+40)
	nTam += 40
Next

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³CabecHoras³ Autor ³ Marcos Wagner Junior  ³ Data ³ 12/08/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Cria o cabecalho das horas (7 a 21)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTR060                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function CabecHoras()
Local nI := 1
Local _nCol := 570

For nI := 7 to 21
	oPrint:Box(lin,_nCol,lin+30,_nCol+160)
	oPrint:Say(lin,_nCol+IIF(nI<10,75,70),AllTrim(Str(nI)),oFont07)
	_nCol += 160
Next

oPrint:Box(lin,_nCol,lin+60,_nCol+180)
oPrint:Say(lin,_nCol+10,STR0016,oFont07)	 //"Tempo Total"

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³CabecFrent³ Autor ³ Marcos Wagner Junior  ³ Data ³ 12/08/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Cria o cabecalho das frentes (4 linhas fixas)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTR060                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function CabecFrent()
Local nI,nX

For nX := 1 to 6
	_nCol := 40
	oPrint:Line(lin-10,50,lin+40,50) //Linha vertical da esquerda
	If nX <= 4
		oPrint:Say(lin+3,60,"HTB " + AllTrim(Str(nX))+STR0017,oFont07) //"a FRENTE:"
	Endif
	For nI := 1 To 60
		oPrint:Line(lin-10,530+_nCol,lin+40,530+_nCol)
		_nCol += 40
	Next
	oPrint:Line(lin-10,530+_nCol,lin+40,530+_nCol)//Ultima linha, depois do 45 (minutos)
	_nCol += 120
	oPrint:Line(lin-10,3150,lin+40,3150)
	oPrint:Line(lin-10,50,lin-10,3150)
	SomaLinha(50)
Next
oPrint:Line(lin-10,50,lin-10,3150)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ ListaCC  ³ Autor ³ Marcos Wagner Junior  ³ Data ³ 12/08/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Lista os centro de custos							              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTR060                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function ListaCC()
Local aOldArea := GetArea()
Local _nSoma := 0
Local _nLinOld := 0
Local lTemCC := .f.

SomaLinha(5)
_nLinOld := lin //Guarda a linha inicial de quando entrou na funcao, para imprimir a segunda coluna

dbSelectArea("SI3")
dbSetOrder(01)
dbSeek(xFilial("SI3"))
/*nLenCC := Len(AllTrim(SI3->I3_CUSTO))
_nCol2 := nLenCC*28 */
While !Eof() .AND. xFilial("SI3") == SI3->I3_FILIAL .AND. 2050 > lin+30
	nLenCC := Len(AllTrim(SI3->I3_CUSTO))
	_nCol2 := 11*28
//	cFrenteTra := SubStr(AllTrim(SI3->I3_CUSTO),nLenCC-2,3)
//	If cFrenteTra >= '300' .AND. cFrenteTra <= '599'
	If SI3->I3_CUSTO >= MV_PAR09 .AND. SI3->I3_CUSTO <= MV_PAR10
		lTemCC := .t.
		oPrint:Line(lin,50+_nSoma,lin,_nCol2+400+_nSoma)
		oPrint:Line(lin,50+_nSoma,lin+30,50+_nSoma) //1a Linha vertical da esquerda
		oPrint:Line(lin,_nCol2+_nSoma,lin+30,_nCol2+_nSoma) //2a Linha vertical da esquerda
		oPrint:Line(lin,_nCol2+400+_nSoma,lin+30,_nCol2+400+_nSoma) //3a Linha vertical da esquerda
		oPrint:Say(lin,51+_nSoma,SI3->I3_CUSTO,oFont07)
		oPrint:Say(lin,_nCol2+10+_nSoma,SubStr(SI3->I3_DESC,1,25),oFont07)
		If 2050 > lin+30
			SomaLinha(30)
		Endif
	Endif
	SI3->(dbSkip())
End

If lTemCC
	If 2050 < lin+30
		oPrint:Line(lin,50,lin,_nCol2+400)
		oPrint:Line(lin,50+_nSoma,lin,_nCol2+400+_nSoma) //Fecha os quadros, ultima linha
		oPrint:Line(lin,50+_nSoma,lin,_nCol2+400+_nSoma) //Fecha os quadros, ultima linha
		lin := _nLinOld
		_nSoma := _nCol2+400
	Else
		oPrint:Line(lin,50+_nSoma,lin,_nCol2+400+_nSoma) //Fecha os quadros, ultima linha
	Endif
Endif

RestArea(aOldArea)

lin := _nLinOld

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ CabecObs ³ Autor ³ Marcos Wagner Junior  ³ Data ³ 12/08/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Cria o cabecalho das frentes (4 linhas fixas)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTR060                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function CabecObs()
Local aOldArea := GetArea()

oPrint:Say(lin,2680,STR0018,oFont07) //"Total de Horas"
oPrint:Line(lin-15,2970,lin+30,2970) //1a Linha vertical da esquerda
oPrint:Line(lin-15,3150,lin+30,3150) //1a Linha vertical da esquerda
SomaLinha(30)

oPrint:Line(lin,1600,lin,3150)
oPrint:Line(lin,1600,lin+30,1600) //1a Linha vertical da esquerda
oPrint:Line(lin,3150,lin+30,3150) //2a Linha vertical da esquerda
oPrint:Say(lin,2300,STR0019,oFont07) //"OBSERVAÇÃO"
SomaLinha(30)
oPrint:Line(lin,1600,lin,3150)

While 2050 > lin+80
	oPrint:Line(lin,1600,lin+80,1600) //1a Linha vertical da esquerda
	oPrint:Line(lin,3150,lin+80,3150) //2a Linha vertical da esquerda
	SomaLinha(80)
	oPrint:Line(lin,1600,lin,3150)
End

RestArea(aOldArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OASR3DT   ³ Autor ³ Marcos Wagner Junior  ³ Data ³17/08/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida o parametro ate data                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR060                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// User Function OASR3DT()
Function MNT060VLDT()

If !Empty(MV_PAR08) .AND. !Empty(MV_PAR07) .AND. MV_PAR08 < MV_PAR07
	MsgStop(STR0020) //"Data final não pode ser inferior à data inicial!"
	Return .F.
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OASBEMR3 ³ Autor ³ Marcos Wagner Junior  ³ Data ³17/08/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida o parametro De/Ate Bem                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR060                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// User Function OASBEMR3(_nPar)
Function MNT060VLBEM( _nPar )
Local aOldArea := GetArea()
Local lRet := .t.
If _nPar == 1
	If	Empty(mv_par05)
		Return .t.
	Else
		If ExistCpo('ST9',mv_par05)
			lRet := .t.
		Else
			lRet := .f.
		Endif
	Endif
Else
	If Atecodigo('ST9',mv_par05,mv_par06,1)
		lRet := .t.
		If mv_par06 = 'ZZZZZZZZZZZZZZZZ'
			Return .t.
		Endif
	Else
		lRet := .f.
	Endif
Endif

If lRet
	DbSelectArea("ST9")
	DbSetOrder(16)
	DbSeek(IIF(_nPar==1,mv_par05,mv_par06)+'A')
	If ST9->T9_TEMCONT != 'S'
		HELP(" ",1,STR0021,,STR0022,3,1)  //"ATENÇÃO"###"Bem não é controlado por contador."
		lRet := .f.
	Endif
	If lRet .AND. ST9->T9_PARTEDI != '1'
		HELP(" ",1,STR0021,,STR0023,3,1)  //"ATENÇÃO"###"Bem não é controlado por parte diária."
		lRet := .f.
	Endif
Endif

RestArea(aOldArea)

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³Assinatura³ Autor ³ Marcos Wagner Junior  ³ Data ³ 20/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Lista os centro de custos							              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTR060                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function Assinatura()

SomaLinha(30)

oPrint:Line(lin,80,lin,3150)
oPrint:Line(lin,80,lin+100,80)
oPrint:Say(lin+30,100,STR0024,oFont11) //"OPERADOR:"
oPrint:Line(lin,390,lin+100,390)
oPrint:Line(lin,1465,lin+100,1465)
oPrint:Say(lin+10,1485,STR0025,oFont11) //"APONTADOR/"
oPrint:Say(lin+60,1485,STR0026,oFont11) //"APROPRIADOR:"
oPrint:Line(lin,1860,lin+100,1860)
oPrint:Line(lin,3150,lin+100,3150)
oPrint:Line(lin+100,80,lin+100,3150)

SomaLinha(100)

oPrint:Line(lin,80,lin,3150)
oPrint:Line(lin,80,lin+100,80)
oPrint:Say(lin+30,100,STR0027,oFont11) //"ENCARREGADO:"
oPrint:Line(lin,390,lin+100,390)
oPrint:Line(lin,1465,lin+100,1465)
oPrint:Say(lin+30,1485,STR0028,oFont11) //"ENGº. PRODUÇÃO:"
oPrint:Line(lin,1860,lin+100,1860)
oPrint:Line(lin,3150,lin+100,3150)
oPrint:Line(lin+100,80,lin+100,3150)

Return .t.