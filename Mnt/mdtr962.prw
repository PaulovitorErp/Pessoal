#INCLUDE "MDTR962.ch"
#INCLUDE "protheus.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR962
Dimensionamento SESSTP
Impressao da Tabela de Dimensionamento dos Sesmt para SESSTP(Segurança e Saúde  no Trabalho Portuário)

@author Rodrigo Soledade
@since 18/07/13
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function MDTR962()
Local aNGBEGINPRM := NGBEGINPRM()

//Variaveis para impressao
Local wnrel   := "MDTR962"
Local cDesc1  := STR0001 //"Tabela de Dimensionamento do Sesmt"
Local cDesc2  := ""
Local cDesc3  := ""
Local cString := "TMK"

Private aReturn  := {STR0002, 1,STR0003, 1, 2, 1, "",1 } //"Zebrado"###"Administração"
Private titulo   := STR0001 //"Tabela de Dimensionamento do Sesmt"
Private ntipo    := 0
Private nLastKey := 0
Private cPerg    := "MDT962"

Private lSigaMdtPS := If(SuperGetMv("MV_MDTPS",.F.,"N") == "S",.T.,.F.)
Private nCod  		 := If((TAMSX3("A1_COD")[1]) < 1,6,(TAMSX3("A1_COD")[1]))
Private nLoj  		 := If((TAMSX3("A1_LOJA")[1]) < 1,2,(TAMSX3("A1_LOJA")[1]))
Private nSizeFil	 := FwSizeFilial()
Private cEmp       := FWGrpCompany()
Private cFil       := FWCodFil()

If !MDTRESTRI(cPrograma)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Devolve variaveis armazenadas (NGRIGHTCLICK) 			 			  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	NGRETURNPRM(aNGBEGINPRM)
	Return .F.
Endif

/*-------------------------------------
//PADRÃO									|
|  Data de Referencia					|
|  Imprimir Quadro ?						|
|  Inicio de operacao?					|
|  Estimativa trab. tomados ano.		|
|  OGMO?									|
|  Num. trab. avulsos ano ant.			|
|  Num. dias efet. trab. ano ant.		|
|  Med. mens. trab. ano civ. ant.		|
|  Consid. Hrs.							|
---------------------------------------*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"")

If nLastKey == 27
    Set Filter to
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Devolve variaveis armazenadas (NGRIGHTCLICK)                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	NGRETURNPRM(aNGBEGINPRM)
    Return
EndIf

SetDefault(aReturn,cString)

If nLastKey == 27
   Set Filter to
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Devolve variaveis armazenadas (NGRIGHTCLICK)                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	NGRETURNPRM(aNGBEGINPRM)
   Return
EndIf

Processa({|lEnd| MDT962IMP(mv_par02)}) // MONTE TELA PARA ACOMPANHAMENTO DO PROCESSO.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna conteudo de variaveis padroes       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
NGRETURNPRM(aNGBEGINPRM)
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT962IMP

Realiza impressao do relatorio

@author Rodrigo Soledade
@since 18/07/13
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MDT962IMP(nMvPar)
Local lImp := .F.
Local nNumTrab := 0
Local nNumDias := 0

Private nNumFunc := 0
Private aNeces     := {}
Private aReal      := {}
Private ColorRed   := CLR_HRED
Private ColorBlack := CLR_BLACK

//Variaveis do relatorio
Private oPrint

//Definicao de Fontes
Private cFonte 	:= "Verdana"
Private oFont13   := TFont():New(cFonte,13,13,,.T.,,,,.F.,.F.)
Private oFont13bs := TFont():New(cFonte,13,13,,.T.,,,,.F.,.T.)
Private oFont12	:= TFont():New(cFonte,12,12,,.T.,,,,.F.,.F.)
Private oFont11	:= TFont():New(cFonte,11,11,,.T.,,,,.F.,.F.)
Private oFont10	:= TFont():New(cFonte,10,10,,.T.,,,,.F.,.F.)
Private oFont09	:= TFont():New(cFonte,09,09,,.T.,,,,.F.,.F.)
Private oFont08	:= TFont():New(cFonte,08,08,,.T.,,,,.F.,.F.)
Private oFont07	:= TFont():New(cFonte,07,07,,.T.,,,,.F.,.F.)

//Inicializa Objeto
oPrint := TMSPrinter():New(OemToAnsi(titulo))
oPrint:Setup()
oPrint:SetLandScape()//Paisagem

If nMvPar == 1 //"Imprimir Quadro ?" ##"1=Fixo";"2=Comparativo"

   lImp := .T.
   lin  := 100
   col  := 275

	oPrint:StartPage()

	Somalinha()
	oPrint:Say(lin,1200,STR0021,oFont13bs,,,,2) //"DIMENSIONAMENTO DO SESMT SESSTP"
	Somalinha(150,"F") // Linha Horizontal

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Cabeçalho																				³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Somalinha()

	// -------------------- Coluna 1 --------------------
	col += 175

	oPrint:Say (lin+185,col+20 ,STR0064,oFont09) //"Profissionais Especializados"
	oPrint:Line(300    ,450    ,lin+250,1175   ) // Linha Diagonal
	oPrint:Say (lin-50 ,col+325,STR0026,oFont09) //"Nº de Empregados"
	oPrint:Say (lin    ,col+325,STR0027,oFont09) //"no Estabelecimento"

	// -------------------- Coluna 2 --------------------
	col += 725

	oPrint:Say(lin    ,col+25,"20"   ,oFont10)
	oPrint:Say(lin+60 ,col+45,STR0032,oFont10) //"a"
	oPrint:Say(lin+120,col+25,"250"  ,oFont10)

	// -------------------- Coluna 3 --------------------
	col += 175

	oPrint:Say(lin    ,col+25,"251"  ,oFont10)
	oPrint:Say(lin+60 ,col+45,STR0032,oFont10) //"a"
	oPrint:Say(lin+120,col+25,"750"  ,oFont10)

	// -------------------- Coluna 4 --------------------
	col += 175

	oPrint:Say(lin    ,col+25,"751"  ,oFont10)
	oPrint:Say(lin+60 ,col+45,STR0032,oFont10) //"a"
	oPrint:Say(lin+120,col+25,"2.000",oFont10)

	// -------------------- Coluna 5 --------------------
	col += 175

	oPrint:Say(lin    ,col+25,"2.001",oFont10)
	oPrint:Say(lin+60 ,col+45,STR0032,oFont10) //"a"
	oPrint:Say(lin+120,col+25,"3.500",oFont10)

	// -------------------- Coluna 6 -------------------
	col += 175

	oPrint:Say(lin    ,col+25,STR0028,oFont10) //"Acima de 3.500"
	oPrint:Say(lin+60 ,col+25,STR0029,oFont10) //"Para cada Grupo"
	oPrint:Say(lin+120,col+25,STR0030,oFont10) //"De 2.000 ou fração"
	oPrint:Say(lin+180,col+25,STR0031,oFont10) //"acima de 500(**)"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Linha 1																					³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Somalinha(250,"F") // Linha Horizontal
	Somalinha(25)
	col := 275

	// -------------------- Coluna 1 --------------------
	col += 175

	oPrint:Say (lin    ,col+20 ,STR0034+STR0053,oFont09) //"Engenheiro Seg."##"Trabalho"
	oPrint:Say (lin+60 ,col+20 ,STR0033+STR0053,oFont09) //"Técnico Seg."##"Trabalho"
	oPrint:Say (lin+120,col+20 ,STR0037+STR0053,oFont09) //"Médico do"##"Trabalho"
	oPrint:Say (lin+180,col+20 ,STR0036+STR0053,oFont09) //"Enfermeiro do"##"Trabalho"
	oPrint:Say (lin+240,col+20 ,STR0035+STR0053,oFont09) //"Aux. Enferm. do"##"Trabalho"

	// -------------------- Coluna 2 --------------------
	col += 725

	oPrint:Say (lin    ,col+20 ,"-" ,oFont09) //"Engenheiro Seg. Trabalho"
	oPrint:Say (lin+60 ,col+20 ,"1" ,oFont09) //"Técnico Seg. Trabalho"
	oPrint:Say (lin+120,col+20 ,"-" ,oFont09) //"Médico do Trabalho"
	oPrint:Say (lin+180,col+20 ,"-" ,oFont09) //"Enfermeiro do Trabalho"
	oPrint:Say (lin+240,col+20 ,"1" ,oFont09) //"Aux. Enferm. do Trabalho"
	// -------------------- Coluna 3 --------------------
	col += 175

	oPrint:Say (lin    ,col+20 ,"1" ,oFont09) //"Engenheiro Seg. Trabalho"
	oPrint:Say (lin+60 ,col+20 ,"2" ,oFont09) //"Técnico Seg. Trabalho"
	oPrint:Say (lin+120,col+20 ,"1*",oFont09) //"Médico do Trabalho"
	oPrint:Say (lin+180,col+20 ,"-" ,oFont09) //"Enfermeiro do Trabalho"
	oPrint:Say (lin+240,col+20 ,"1" ,oFont09) //"Aux. Enferm. do Trabalho"

	// -------------------- Coluna 4 --------------------
	col += 175

	oPrint:Say (lin    ,col+20 ,"2" ,oFont09) //"Engenheiro Seg. Trabalho"
	oPrint:Say (lin+60 ,col+20 ,"4" ,oFont09) //"Técnico Seg. Trabalho"
	oPrint:Say (lin+120,col+20 ,"2" ,oFont09) //"Médico do Trabalho"
	oPrint:Say (lin+180,col+20 ,"1" ,oFont09) //"Enfermeiro do Trabalho"
	oPrint:Say (lin+240,col+20 ,"2" ,oFont09) //"Aux. Enferm. do Trabalho"

	// -------------------- Coluna 5 --------------------
	col += 175

	oPrint:Say (lin    ,col+20 ,"3" ,oFont09) //"Engenheiro Seg. Trabalho"
	oPrint:Say (lin+60 ,col+20 ,"11",oFont09) //"Técnico Seg. Trabalho"
	oPrint:Say (lin+120,col+20 ,"3" ,oFont09) //"Médico do Trabalho"
	oPrint:Say (lin+180,col+20 ,"3" ,oFont09) //"Enfermeiro do Trabalho"
	oPrint:Say (lin+240,col+20 ,"4" ,oFont09) //"Aux. Enferm. do Trabalho"

	// -------------------- Coluna 6 --------------------
	col += 175

	oPrint:Say (lin    ,col+20 ,"1" ,oFont09) //"Engenheiro Seg. Trabalho"
	oPrint:Say (lin+60 ,col+20 ,"3",oFont09) //"Técnico Seg. Trabalho"
	oPrint:Say (lin+120,col+20 ,"1" ,oFont09) //"Médico do Trabalho"
	oPrint:Say (lin+180,col+20 ,"1" ,oFont09) //"Enfermeiro do Trabalho"
	oPrint:Say (lin+240,col+20 ,"1" ,oFont09) //"Aux. Enferm. do Trabalho"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Fim da Tabela																			³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Somalinha(300,"F") // Linha Horizontal

	// Linhas Verticais
	//oPrint:Line(300,275 ,lin,275 )
	oPrint:Line(300,450 ,lin,450 )
	oPrint:Line(300,1175,lin,1175)
	oPrint:Line(300,1350,lin,1350)
	oPrint:Line(300,1525,lin,1525)
	oPrint:Line(300,1700,lin,1700)
	oPrint:Line(300,1875,lin,1875)
	oPrint:Line(300,2290,lin,2290)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Observacoes																				³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Somalinha(10,"F") // Linha Horizontal
	col := 275

	// Linhas Verticais
 	oPrint:Line(lin,450 ,lin+125,450 )
 	oPrint:Line(lin,2290,lin+125,2290)

	// -------------------- Coluna 1 --------------------
	oPrint:Say (lin+15 ,col+225,STR0038,oFont10) //"(*) Tempo parcial (mínimo de três horas)"

	Somalinha(125,"F") // Linha Horizontal

	oPrint:EndPage()

ElseIf nMvPar == 2

	oPrint:StartPage()
	lin := 100
	Somalinha()
	oPrint:Say(lin,1400,STR0021,oFont13bs,,,,2) //"DIMENSIONAMENTO DO SESMT SESSTP"

	//ProcRegua(Len(aTotalFunc))
	IncProc()

	dbSelectArea("SM0")
	dbSetOrder(1)
	If dbSeek(cEmp + cFil)

		dbSelectArea("TOE")
		dbSetOrder(1)
		If dbSeek(xFilial("TOE") + SM0->M0_CNAE)
			If TOE->TOE_GRISCO >= "1" .and. TOE->TOE_GRISCO <= "4"

				Somalinha(200)
				lImp     := .T.
				col      := 100
				aNeces   := {}
				aReal    := {}

				oPrint:Say(lin,col    ,STR0047,oFont11) //"Filial: "
				oPrint:Say(lin,col+600,SM0->M0_CODFIL+" - "+SM0->M0_NOME,oFont11)

				Somalinha(60)
				oPrint:Say(lin,col    ,STR0048,oFont11) //"Grau de Risco: "
				oPrint:Say(lin,col+600,TOE->TOE_GRISCO,oFont11)

				Somalinha(60)
				oPrint:Say(lin,col    ,STR0049,oFont11) //"Total de Funcionários: "
				If mv_par03 == 1
					oPrint:Say(lin,col+600,cValToChar(mv_par04),oFont11)
				Else
					If mv_par05 == 1
						nNumTrab := mv_par06
						nNumDias := mv_par07
						oPrint:Say(lin,col+600,cValToChar(Int(nNumTrab/nNumDias)),oFont11)
					Else
						If !SuperGetMv("MV_MDTGPE",.F.,"N") == "S"//Verifica se esta integrado com o GPE
							oPrint:Say(lin,col+600,cValToChar(mv_par08),oFont11)
						Else
						//Teste
							nNumFunc := MDT962FUN()//Carrega Array com o total de funcionários de cada filial
							oPrint:Say(lin,col+600,cValToChar(nNumFunc),oFont11)
						EndIf
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³	Cabeçalho																				³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Somalinha(80,"C")
				col  := 100

				// -------------------- Coluna 1 --------------------
				oPrint:Say (lin+125,col+20 ,STR0050,oFont09) //"Situação da Empresa"

				oPrint:Line(lin    ,col    ,lin+200,col+600) // Linha Diagonal

				oPrint:Say (lin    ,col+150,STR0065,oFont09) //"Profis. Especializados

				// -------------------- Coluna 2 --------------------
				col += 600

				oPrint:Say (lin+40 ,col+20 ,STR0033,oFont09) //"Técnico Seg."
				oPrint:Say (lin+100,col+20 ,STR0053,oFont09) //"Trabalho"

				// -------------------- Coluna 3 --------------------
				col += 350

				oPrint:Say (lin+40 ,col+20 ,STR0034,oFont09) //"Engenheiro Seg."
				oPrint:Say (lin+100,col+20 ,STR0053,oFont09) //"Trabalho"

				// -------------------- Coluna 4 --------------------
				col += 350

				oPrint:Say (lin+40 ,col+20 ,STR0035,oFont09) //"Aux. Enferm. do"
				oPrint:Say (lin+100,col+20 ,STR0053,oFont09) //"Trabalho"

				// -------------------- Coluna 5 --------------------
				col += 350

				oPrint:Say (lin+40 ,col+20 ,STR0036,oFont09) //"Enfermeiro do"
				oPrint:Say (lin+100,col+20 ,STR0053,oFont09) //"Trabalho"

				// -------------------- Coluna 6 --------------------
				col += 350

				oPrint:Say (lin+40 ,col+20 ,STR0037,oFont09) //"Médico do"
				oPrint:Say (lin+100,col+20 ,STR0053,oFont09) //"Trabalho"

				// Linhas Verticais
				oPrint:Line(lin,100 ,lin+400,100 )
				oPrint:Line(lin,700 ,lin+400,700 )
				oPrint:Line(lin,1050,lin+400,1050)
				oPrint:Line(lin,1400,lin+400,1400)
				oPrint:Line(lin,1750,lin+400,1750)
				oPrint:Line(lin,2100,lin+400,2100)
				oPrint:Line(lin,2450,lin+400,2450)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³	Necessidade																				³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Somalinha(200,"C")
				col  := 100
				If mv_par03 == 1
					aNeces := MDT962NESC(TOE->TOE_GRISCO,mv_par04)
				Else
					If mv_par05 == 1 //OGMO? = SIM
						aNeces := MDT962NESC(TOE->TOE_GRISCO,Int(nNumTrab/nNumDias))
					Else
						If !SuperGetMv("MV_MDTGPE",.F.,"N") == "S"//Verifica se esta integrado com o GPE
							nNumFunc := MV_PAR08//Carrega Array com o total de funcionários de cada filial
						EndIf
						aNeces := MDT962NESC(TOE->TOE_GRISCO,nNumFunc)
					EndIf
				EndIf

				// -------------------- Coluna 1 --------------------
				oPrint:Say (lin+20,col+20 ,STR0051,oFont09) // Necessidade

				// -------------------- Coluna 2 --------------------
				col += 600
				oPrint:Say (lin+20,col+20 ,aNeces[1,1],oFont09) // Técnico Seg. Trabalho

				// -------------------- Coluna 3 --------------------
				col += 350
				oPrint:Say (lin+20,col+20 ,aNeces[1,2],oFont09) // Engenheiro Seg. Trabalho

				// -------------------- Coluna 4 --------------------
				col += 350
				oPrint:Say (lin+20,col+20 ,aNeces[1,3],oFont09) // Aux. Enferm. do Trabalho

				// -------------------- Coluna 5 --------------------
				col += 350
				oPrint:Say (lin+20,col+20 ,aNeces[1,4],oFont09) // Enfermeiro do Trabalho

				// -------------------- Coluna 6 --------------------
				col += 350
				oPrint:Say (lin+20,col+20 ,aNeces[1,5],oFont09) // médico do Trabalho

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³	Realidade																				³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Somalinha(100,"C")
				col  := 100

				aReal := MDT962REAL(cFil)//aTotalFunc[i][1])

				// -------------------- Coluna 1 --------------------
				oPrint:Say (lin+20,col+20 ,STR0052,oFont09) // Realidade

				// -------------------- Coluna 2 --------------------
				col += 600
				oPrint:Say (lin+20,col+20 ,aReal[1,1,1],oFont09 ,, If(lVERSESMT(1),ColorRed,ColorBlack) ) // Técnico Seg. Trabalho

				// -------------------- Coluna 3 --------------------
				col += 350
				oPrint:Say (lin+20,col+20 ,aReal[1,2,1],oFont09 ,, If(lVERSESMT(2),ColorRed,ColorBlack) ) // Engenheiro Seg. Trabalho

				// -------------------- Coluna 4 --------------------
				col += 350
				oPrint:Say (lin+20,col+20 ,aReal[1,3,1],oFont09 ,, If(lVERSESMT(3),ColorRed,ColorBlack) ) // Aux. Enferm. do Trabalho

				// -------------------- Coluna 5 --------------------
				col += 350
				oPrint:Say (lin+20,col+20 ,aReal[1,4,1],oFont09 ,, If(lVERSESMT(4),ColorRed,ColorBlack) ) // Enfermeiro do Trabalho

				// -------------------- Coluna 6 --------------------
				col += 350
				oPrint:Say (lin+20,col+20 ,aReal[1,5,1],oFont09 ,, If(lVERSESMT(5),ColorRed,ColorBlack) ) // médico do Trabalho

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³	Fim da Tabela																			³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Somalinha(100,"C") // Linha Horizontal

				oPrint:Say(lin    ,100,STR0054+STR0038,oFont10,,ColorBlack) //"OBS:"##"(*) Tempo parcial (mínimo de três horas)"
				oPrint:Say(lin+60 ,100,STR0055,oFont10,,ColorBlack) //"Legenda: "
				oPrint:Say(lin+120,300,STR0056,oFont10,,ColorBlack) //"Preto - Dentro dos Conformes"
				Somalinha(100)
				oPrint:Say(lin+120,300,STR0057,oFont10,,ColorRed)   //"Vermelho - Fora dos Conformes"
				Somalinha(150)
			EndIf
		EndIf
	EndIf
EndIf

If lImp
	oPrint:EndPage()
	//Imprime na Tela ou Impressora
	If aReturn[5] == 1
		oPrint:Preview()
	Else
		oPrint:Print()
	EndIf
Else
	MsgStop(STR0020,STR0019)//"Não existem dados para montar o Quadro Comparativo."##"ATENÇÃO"
Endif
MS_FLUSH()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} Somalinha

Realiza salto de linha

@author Rodrigo Soledade
@since 18/07/13
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function Somalinha(nLin, cPrtLin)
Default nLin    := 50

lin += nLin

If cPrtLin == "F"
	oPrint:Line(lin,452,lin,2290)//2875)
ElseIf cPrtLin == "C"
	oPrint:Line(lin,100,lin,2450)
EndIf
If lin > 2850
	oPrint:EndPage()
	oPrint:StartPage()
EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT962NESC

Retorna quantidade de funcionarios da tabela fixa.

Parametros:	cRisco -----> Obrigatorio;
          	              Valor do campo TOE->TOE_GRISCO.
          	nTotalFunc -> Obrigatorio;
          	              Total de funcionarios da filial

@author Rodrigo Soledade
@since 18/07/13
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MDT962NESC(cRisco,nTotalFunc)
Local cTecnico    := "0"
Local cEngenheiro := "0"
Local cAuxEnferm  := "0"
Local cEnfermeiro := "0"
Local cMedico     := "0"
Local nResto      := 0
Local nAuxFunc    := 0
Local lAuxFunc    := .T.
Local aNecesFunc  := {}

If nTotalFunc >= 20  .and. nTotalFunc <= 250
	cEngenheiro := "-"
	cTecnico    := "1"
	cMedico     := "-"
	cEnfermeiro := "-"
	cAuxEnferm  := "1"
ElseIf nTotalFunc >= 251 .and. nTotalFunc <= 750
	cEngenheiro := "1"
	cTecnico    := "2"
	cMedico     := "1*"
	cEnfermeiro := "-"
	cAuxEnferm  := "1"
ElseIf nTotalFunc >= 751 .and. nTotalFunc <= 2000
	cEngenheiro := "2"
	cTecnico    := "4"
	cMedico     := "2"
	cEnfermeiro := "1"
	cAuxEnferm  := "2"
ElseIf nTotalFunc >= 2001 .and. nTotalFunc <= 3500
	cEngenheiro := "3"
	cTecnico    := "11"
	cMedico     := "3"
	cEnfermeiro := "3"
	cAuxEnferm  := "4"
ElseIf nTotalFunc > 3500
		While lAuxFunc
			If nResto == 0
				nResto := nTotalFunc - 3500
			EndIf
			If nResto < 500
				lAuxFunc := .F.
			ElseIf nResto >= 500 .and. nResto <= 2000
				lAuxFunc    := .F.
				nAuxFunc++
			ElseIf nResto > 2000
				nResto := nResto - 2000
				nAuxFunc++
			EndIf
		End
		While nAuxFunc > 0
			cEngenheiro := cValToChar(Val(cEngenheiro) + 1)
			cTecnico    := cValToChar(Val(cTecnico)    + 3)
			cMedico     := cValToChar(Val(cMedico)     + 1)
			cEnfermeiro := cValToChar(Val(cEnfermeiro) + 1)
			cAuxEnferm  := cValToChar(Val(cAuxEnferm)  + 1)
			nAuxFunc--
		End
EndIf

aAdd (aNecesFunc , { cTecnico , cEngenheiro, cAuxEnferm, cEnfermeiro, cMedico })

Return aNecesFunc

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT962REAL

Retorna quantidade de funcionarios da empresa.

@author Rodrigo Soledade
@since 18/07/13
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MDT962REAL(cFilFun)
Local aArea       := GetArea()
Local nCalc
Local nTotMin		:=0
Local nDia			:=0
Local nMin			:=0
Local cTecnico		:= "0"
Local cEngenheiro	:= "0"
Local cAuxEnferm	:= "0"
Local cEnfermeiro	:= "0"
Local cMedico		:= "0"
Local aRealFunc	:= {}
Local lTecSeg		:= .T.
Local lEngSeg		:= .T.
Local lAuxEnf		:= .T.
Local lEnfTra		:= .T.
Local lMedTra		:= .T.

cFilFun := xFilial("TMK",cFilFun)

dbSelectArea("TMK")
dbSetOrder(1)
dbSeek(cFilFun)
While !Eof() .and. TMK->TMK_FILIAL == cFilFun
	If TMK->TMK_SESMT == "1" .and.;
		DtoS(TMK->TMK_DTINIC) <= DtoS(mv_par01) .and.;
	  (Empty(DtoS(TMK->TMK_DTTERM)) .or. TMK->TMK_DTTERM > dDataBase)
		If     TMK->TMK_INDFUN == "1"
			cMedico     := cValToChar(Val(cMedico)     + 1)
		ElseIf TMK->TMK_INDFUN == "2"
			cEnfermeiro := cValToChar(Val(cEnfermeiro) + 1)
		ElseIf TMK->TMK_INDFUN == "3"
			cAuxEnferm  := cValToChar(Val(cAuxEnferm)  + 1)
		ElseIf TMK->TMK_INDFUN == "4"
			cEngenheiro := cValToChar(Val(cEngenheiro) + 1)
		ElseIf TMK->TMK_INDFUN == "5"
			cTecnico    := cValToChar(Val(cTecnico)    + 1)
		EndIf
	EndIf

	If Mv_PAR05 == 1
		aCalend := NGCALENDAH( TMK->TMK_CALEND )
		For nCalc :=1 To Len(aCalend)
			If(Val(aCalend[nCalc,1])) > 0
				nMin:=HTOM(aCalend[nCalc,1])
				nTotMin+=nMin
				nDia++
			Endif
		Next nCalc
		nDia:=(nDia*3)*60
		If( nTotMin < nDia )
			If     TMK->TMK_INDFUN == "1"
				lMedTra := .F.
			ElseIf TMK->TMK_INDFUN == "2"
				lEnfTra := .F.
			ElseIf TMK->TMK_INDFUN == "3"
				lAuxEnf := .F.
			ElseIf TMK->TMK_INDFUN == "4"
				lEngSeg := .F.
			ElseIf TMK->TMK_INDFUN == "5"
				lTecSeg := .F.
			EndIf
		Endif
	EndIf


	dbSelectArea("TMK")
	dbSkip()
	Loop
End

If MV_PAR05 == 1
	aAdd (aRealFunc , { { cTecnico , lTecSeg } , { cEngenheiro , lEngSeg  } , { cAuxEnferm , lAuxEnf } , { cEnfermeiro , lEnfTra } , { cMedico , lMedTra } })
Else
	aAdd (aRealFunc , { { cTecnico , .T. } , { cEngenheiro , .T.  } , { cAuxEnferm , .T. } , { cEnfermeiro , .T. } , { cMedico , .T. } })
EndIf

RestArea(aArea)
Return aRealFunc

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT962FUN

Retorna quantidade de funcionarios da empresa

@author Rodrigo Soledade
@since 23/07/13
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MDT962FUN()
Local aArea   := GetArea()
Local nFunc   := 0
//Local cFilSRA
//Local aFunc   := {}
Local lFilial := .T.
Local nAnoAtual := 0

nAnoAtual := Year(mv_par01)

dbSelectArea("SRA")
dbSetOrder(1)
dbSeek(cFil,.T.)
While !Eof() .and. SRA->RA_FILIAL == cFil
	If lFilial .and. Empty(cFil)
		cFil := SRA->RA_FILIAL
		lFilial := .F.
	EndIf
	If cFil == SRA->RA_FILIAL .and.	DtoS(SRA->RA_ADMISSA) <= DtoS(mv_par01) .and.;
	  (Empty(DtoS(SRA->RA_DEMISSA)) .or. Year(SRA->RA_DEMISSA) >= nAnoAtual) .and. Year(SRA->RA_ADMISSA) < nAnoAtual
		nFunc++
	EndIf
	dbSelectArea("SRA")
	dbSkip()
	Loop
End
//aAdd (aFunc , {cFilSRA , nFunc} )
RestArea(aArea)
Return nFunc

//---------------------------------------------------------------------
/*/{Protheus.doc} fR962Val

Função que valida os parametros do SX1.

@author Rodrigo Soledade
@since 23/07/13
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function fR962Val(cPar)
Local nRet := .T.

If cPar == '4' //"Estimativa trab. tomados ano."
	If mv_par03 == 2
		Msginfo(STR0066) //"Esse parâmetro somente é valido quando o 'Inicio operação?' for 'Sim'."
		mv_par04 := 0
	EndIf
ElseIf cPar == '5' //"OGMO?"
	If (mv_par03==1)
		Msginfo(STR0066) //"Esse parâmetro somente é valido quando o 'Inicio operação?' for 'Sim'."
	EndIf
ElseIf cPar == '6' //"Num. Trab. avulsos ano ant."
	If !(mv_par03==2 .And. mv_par05==1 .Or. Empty(mv_par06))
		Msginfo(STR0067) //"Esse parâmetro somente é valido quando o parâmetros 'Inicio operação?' for 'Não' e o 'OGMO?' forem 'Sim'."
		mv_par06 := 0
	EndIf
ElseIf cPar == '7' //"Num. dias efet. trab. ano ant."
	If !(mv_par03==2 .And. mv_par05==1 .Or. Empty(mv_par07))
		Msginfo(STR0067) //"Esse parâmetro somente é valido quando o parâmetros 'Inicio operação?' for 'Não' e o 'OGMO?' forem 'Sim'."
		mv_par07 := 0
	EndIf
ElseIf cPar == '8' //"Média mensal trab. ano civ. ant."
	If SuperGetMv("MV_MDTGPE",.F.,"N") == "S"//Verifica se esta integrado com o GPE
		Msginfo(STR0068) //"Esse parâmetro somente é valido quando o MDT não esta integrado com o GPE."
		mv_par08 := 0
	ElseIf (mv_par03==1 .And. mv_par05==1 .And. !Empty(mv_par08))
		Msginfo(STR0069) //"Esse parâmetro somente é valido quando o parâmetro 'Inicio operação?' for 'Não' e 'OGMO?' for 'Não'."
		mv_par08 := 0
	EndIf
EndIf

Return nRet

//---------------------------------------------------------------------
/*/{Protheus.doc} lVERSESMT
Verfica se os componestes suprem a necessidade, caso esteja com (*) e seje
apenas 1 componente.

@return lRet - Valor lógico
@param nposic - Posição da linha que esta imprimindo
@author Guilherme Freudenburg
@since 10/04/2014
@obs Utilizado nos fontes: MDTR961
/*/
//---------------------------------------------------------------------
Static Function lVERSESMT(nposic)

	Local lRet:=.F.
	Local lVldHrs := .F.

	If mv_par05 == 1
		If "*" $ aNeces[1,nposic]
			lVldHrs := .T.
		Endif
		//Verifica se a impressão será em RED ou BLACK
		If( Val(aReal[1 , nposic , 1 ]) < Val(aNeces[ 1 , nposic ] ) )
			lRet := .T.
		ElseIf lVldHrs .And. ( Val(aReal[1 , nposic , 1 ]) == Val(aNeces[ 1 , nposic ] ) )
			lRet := !aReal[ 1 , nposic , 2 ]
		Endif
	Else
		If( Val(aReal[1 , nposic , 1 ]) < Val(aNeces[ 1 , nposic  ] ) )
			lRet:=.T.
		Endif
	Endif
Return lRet

