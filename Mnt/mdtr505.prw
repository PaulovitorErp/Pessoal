#INCLUDE "mdtr505.ch"
#Include "Protheus.ch"  

#DEFINE _nVERSAO 2 //Versao do fonte
/*/   
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ MDTR690  ³ Autor ³ Jackson Machado		  ³ Data ³08/06/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Ficha de Controle de Inspecao dos Conjuntos Hidráulicos     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMDT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDTR505()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena variaveis p/ devolucao (NGRIGHTCLICK) 				  		  	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea := GetArea()
LOCAL cF3CC := "SI3001"  //SI3 apenas do cliente

PRIVATE nomeprog := "MDTR505"
PRIVATE titulo   := STR0001  //"Ficha de Controle de Inspeção dos Conjuntos Hidráulicos"
PRIVATE cPerg    := "MDT505    "
PRIVATE nSizeSI3 := If((TAMSX3("I3_CUSTO")[1]) < 1,9,(TAMSX3("I3_CUSTO")[1]))
PRIVATE cAliasCC := "SI3"
PRIVATE cCliMdtps := " "

/*------------------------------------------------
//PERGUNTAS PADRAO									|
MDT690    ¦01      ¦De  Conjunto Hidráulico  ?	|
MDT690    ¦02      ¦Ate Conjunto Hidráulico  ?	|
MDT690    ¦03      ¦De  Centro de Custo      ?	|
MDT690    ¦04      ¦Ate Centro de Custo      ?	|
MDT690    ¦05      ¦De  Data Inspecao   ?			|
MDT690    ¦06      ¦Ate Data Inspecao   ?			|
MDT690    ¦07      ¦Situação da Ordem    ?		|
--------------------------------------------------*/

If Alltrim(GETMV("MV_MCONTAB")) == "CTB"
	cAliasCC := "CTT"
	cF3CC := "CTT001"  //CTT apenas do cliente				
	nSizeSI3 := If((TAMSX3("CTT_CUSTO")[1]) < 1,9,(TAMSX3("CTT_CUSTO")[1]))
Endif

If Pergunte(cPerg,.T.,titulo)
		Processa({|lEND| MDTA505IMP()},STR0019) //"Processando..."
Endif

RestArea(aArea) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve variaveis armazenadas (NGRIGHTCLICK)                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
NGRETURNPRM(aNGBEGINPRM)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³MDTA505IMP³ Autor ³ Jackson Machado		  ³ Data ³08/06/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³Funcao de impressao                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMDT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MDTA505IMP()

	cSeekExt := xFilial('TKS')+Mv_par01
	cWhilExt := "xFilial('TKS') == TKS->TKS_FILIAL .AND. TKS->TKS_CODCJN <= Mv_par02"
	cCondExt := "TKS->TKS_CCCJN >= Mv_par03 .and. TKS->TKS_CCCJN <= Mv_par04"
	nIndiExt := 1
	
	oPrint01 := TMSPrinter():New( OemToAnsi(titulo))
	oPrint01:SetPortrait() 	//Retrato
	oPrint01:Setup() 		//Configuracao
	
	dbSelectArea("TKS")
	dbSetOrder(nIndiExt)
	dbSeek(cSeekExt,.T.)
	ProcRegua(LastRec())
	While !eof() .and. &(cWhilExt)
		IncProc()
		If &(cCondExt)
			MDT505Ficha(mv_par05,mv_par06)
		Endif
	
		dbSelectArea("TKS")
		dbSkip()
	End
oPrint01:Preview()


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³MDT505Ficha Autor ³ Jackson Machado		  ³ Data ³08/06/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³Impressao do Cabecalho da Ficha de Controle de Inspecao      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMDT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDT505Ficha(dDeData,dAteDate,cNmCli)

Local nFor  := 0   // Contador
Local nCont := 0   // Contador
Local n     := 1 //Variável de controle das inspeções

Private nLinTemp  := 0
Private cNomeCli  := cNmCli
Private aOrdens	:= {}
Private aInspecao := {}
//Variável de incremento de página
Private nPag := 1

//Variável para controle de linhas
Private nOldLin := 0

	dbSelectArea("TLD")
	dbSetOrder(2)
    If dbSeek(xFilial("TLD")+TKS->TKS_CODCJN)
      While !Eof() .and. TLD->TLD_FILIAL + AllTrim( TLD->TLD_CODEXT ) == xFilial( "TLD" ) + AllTrim( TKS->TKS_CODCJN )
      	If TLD->TLD_DTPREV < mv_par05 .or. TLD->TLD_DTPREV > mv_par06
      		dbSelectArea("TLD")
				dbSkip()
				Loop
      	Endif
      	
		If mv_par07 <> 3
			If Val(TLD->TLD_SITUAC) <> mv_par07
				dbSelectArea("TLD")
				dbSkip()
				Loop
			Endif
		Endif
		
		If mv_par07 == 3
			If TLD->TLD_SITUAC == "3"
				dbSelectArea("TLD")
				dbSkip()
				Loop
			Endif
		Endif
        
		If TLD->TLD_CATEGO == "1"
			dbSelectArea("TLD")
			dbSkip()
			Loop
		Endif
		
		aAdd(aOrdens,{TLD->TLD_ORDEM,TLD->TLD_PLANO,TKS->TKS_CODCJN,TKS->TKS_DESCJN,TKS->TKS_LOCCJN,TLD->TLD_SITUAC})
		aAdd(aInspecao,{})
		nX := 1
		dbSelectArea("TK5")
		dbSetOrder(1)
		If dbSeek(xFilial("TK5")+TLD->TLD_ORDEM)
			While !Eof() .And. TK5->TK5_ORDEM == TLD->TLD_ORDEM
				dbSelectArea("TK4")
				dbSetOrder(1)
				If dbSeek(xFilial("TK4")+TK5->TK5_EVENTO)
					aAdd(aInspecao[n],{TK5->TK5_EVENTO,TK4->TK4_DESCRI,TK5->TK5_REALIZ})//Incluindo posições de >= 6 com as inspeções
				Endif
				dbSelectArea("TK5")
				dbSkip()
			End
		Endif
		n++
		dbSelectArea("TLD")
		dbSkip()
		End

    Endif
	
	oFont12n    := TFont():New("VERDANA",12,12,,.T.,,,,.F.,.F.)
	oFont11     := TFont():New("VERDANA",11,11,,.F.,,,,.F.,.F.)
	oFont11n    := TFont():New("VERDANA",11,11,,.T.,,,,.F.,.F.)
	oFont12     := TFont():New("VERDANA",12,12,,.F.,,,,.F.,.F.)
	oFont10     := TFont():New("VERDANA",10,10,,.F.,,,,.F.,.F.)
	
	nLin := 510
	For nCont := 1 To Len(aOrdens)
		nPag := 1
		oPrint01:StartPage()	//Inicia Pagina
	
		MDTR505PAG(.F.,nCont)  
		SomaLinha(160)
		nOldLin := nLin
		nLinTemp := nLin+20
		For nFor := 1 To Len(aInspecao[nCont]) // Seleciona apenas as inspeções no array ( >=6 )
			oPrint01:Say(nLinTemp,250,aInspecao[nCont][nFor][1]+" - "+Upper(aInspecao[nCont][nFor][2]),oFont11)
			If aOrdens[nCont][6] == "2"
				If aInspecao[nCont][nFor][3] == "1"
					oPrint01:Say(nLinTemp,1750,"X",oFont12)
				Else
					oPrint01:Say(nLinTemp,2100,"X",oFont12)	
				Endif
			Endif
			nLinTemp += 100
			oPrint01:line(nLinTemp-20,200,nLinTemp-20,2300)		// Linha Horizontal que separa as respostas
			Somalinha(100,nCont)
		Next nFor
		If Len(aInspecao[nCont])%24 == 0 
			nLen := Len(aInspecao[nCont])/24
		Else
			nLen := Int(Len(aInspecao[nCont])/24)+1
		Endif
		// 670 pixels e' o valor onde inicia a impressao dos eventos
		// Quando a pagina e' finalizada pela funcao SomaLinha(), a varialvel nLin recebe +160,
		// portanto primeiro deve atribuir os 160 que seriam recebidos no rodape' para depois
		// terminar a pagina
		oPrint01:line(670,1580,nLin,1580)		// Linha Vertical que isola 'Sim'
		oPrint01:line(670,1950,nLin,1950)		// Linha Vertical que isola 'Nao'
		oPrint01:Box(160,200,nLin,2300)			// Box que contem o relatorio
		oPrint01:Say(3090,1200,STR0020+AllTrim(Str(nLen))+STR0021+AllTrim(Str(nLen)),oFont11,,,,2) //"Página "###" de "
		oPrint01:EndPage()
		nLin := 510
	Next nCont


Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³MDTR505PAGºAutor  ³Jackson Machado	  º Data ³  08/06/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pula de pagina.                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MDTR505                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MDTR505PAG(lQuebra,nCont)
Default lQuebra := .F.
Default nCont := 1

If lQuebra
	// 2400 pixels e' onde o ultimo evento e' impresso
	oPrint01:Box(160,200,nLin,2300)			// Box que contem o relatorio
	oPrint01:line(670,1580,nLin,1580)		// Linha Vertical que isola 'Sim'
	oPrint01:line(670,1950,nLin,1950)		// Linha Vertical que isola 'Nao'
	If Len(aInspecao[nCont])%24 == 0 
		oPrint01:Say(nLinTemp,1200,STR0020+AllTrim(Str(nPag))+STR0021+AllTrim(Str(Len(aInspecao[nCont])/24)),oFont11,,,,2) //"Página "###" de "
	Else
		oPrint01:Say(nLinTemp,1200,STR0020+AllTrim(Str(nPag))+STR0021+AllTrim(Str(Int(Len(aInspecao[nCont])/24)+1)),oFont11,,,,2) //"Página "###" de "
	Endif
	//Variável de incremento de página
	nPag++
	//Reestabelece parâmetros de linha
	nLin := nOldLin
	nLinTemp := nLin+20
	// Encerra a pagina atual
	oPrint01:EndPage()
	// Comeca uma nova pagina
	oPrint01:StartPage()
EndIf
cLogo := NGLocLogo()
If !Empty(cLogo)
	oPrint01:SayBitMap(180,230,cLogo,300,150)
Endif
oPrint01:Say(250,1250,Upper(STR0022),oFont12n,,,,2) //"FICHA DE CONTROLE DE INSPEÇÃO"
// Prepara a nova pagina com o cabecalho
oPrint01:line(350,200,350,2300)		// Linha Horizontal que corta o Cabecalho
oPrint01:line(430,200,430,2300)		// Linha Horizontal que corta 'Cj. Hidráulic' 
oPrint01:line(510,200,510,2300)		// Linha Horizontal que corta 'Local'
oPrint01:line(510,1230,590,1230)		// Linha Vertical que separa 'O.S.' e 'Plano'
oPrint01:line(590,200,590,2300)		// Linha Horizontal que corta 'O.S.' e 'Plano'
oPrint01:line(590,1580,670,1580)		// Linha Vertical que isola 'Sim'
oPrint01:line(590,1950,670,1950)		// Linha Vertical que isola 'Nao'
oPrint01:line(670,200,670,2300)		// Linha Horizontal que corta o 'Atividades'

oPrint01:Say(360,210,STR0024,oFont11n)  //"Cj. Hidráulico:"
oPrint01:Say(365,600,AllTrim(aOrdens[nCont][3])+" - "+aOrdens[nCont][4],oFont10)

oPrint01:Say(440,210,STR0025,oFont11n)  //"Local:"
oPrint01:Say(445,600,aOrdens[nCont][5],oFont10)

oPrint01:Say(520,210,STR0026,oFont11n)  //"Ordem:"
oPrint01:Say(525,380,aOrdens[nCont][1],oFont10)
oPrint01:Say(520,1240,STR0027,oFont11n)  //"Plano:"
oPrint01:Say(525,1380,aOrdens[nCont][2],oFont10)

oPrint01:Say(600,800,STR0028,oFont11n) //"Atividades"
oPrint01:Say(600,1730,STR0029,oFont11n) //"Sim"
oPrint01:Say(600,2080,STR0030,oFont11n)  //"Não"
	
Return .T.
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ SomaLinha³ Autor ³ Jackson Machado       ³ Data ³ 08/06/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Incrementa Linha e Controla Salto de Pagina                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ SomaLinha()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTR505                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function Somalinha(linhas,nCont)

Default linhas := 80

nLin += linhas
If nLin > 3060
	If ValType(nCont) == "N"                               
		MDTR505PAG(.T.,nCont)
	Endif
EndIf	

Return
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³R505DATAIN³ Autor ³ Jackson Machado       ³ Data ³ 08/06/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Valida data inicial.							              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTR505                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function R505DATAIN(dData,dFim)

If Empty(dData)
	Help(" ",1,"DEDATAINVA")
	Return .F.
Endif

If !Empty(dFim) .and. dData > dFim
	Help(" ",1,"DATAINVALI")
 	Return .F.
Endif

Return .T.
