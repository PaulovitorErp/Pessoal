#INCLUDE "MDTR961.ch"
#INCLUDE "protheus.ch"
#DEFINE _nVERSAO 2 //Versao do fonte

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR961
Impressao da Tabela de Dimensionamento dos Sesmt     
   
@return .T.        
@author Andrey Martim Pegorini
@since 20/09/10     
/*/ 
//---------------------------------------------------------------------
Function MDTR961()       
Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)  

//Variaveis para impressao
Local wnrel   := "MDTR961"    
Local cDesc1  := STR0001 //"Tabela de Dimensionamento do Sesmt"
Local cDesc2  := "" 
Local cDesc3  := ""
Local cString := "TMK"    
Local aCalend  := {}
Private aReturn  := {STR0002, 1,STR0003, 1, 2, 1, "",1 } //"Zebrado"###"Administração"
Private titulo   := STR0001 //"Tabela de Dimensionamento do Sesmt"
Private ntipo    := 0  
Private nLastKey := 0
Private lSigaMdtPS := If(SuperGetMv("MV_MDTPS",.F.,"N") == "S",.T.,.F.)
Private cPerg    := "MDT961"
Private aPerg	   := {}
If lSigaMdtPS
	Private cPergPS  := "MDT961PS"
	Private aPergPS  := {}
EndIf

Private nCod	   := If((TAMSX3("A1_COD")[1]) < 1,6,(TAMSX3("A1_COD")[1]))
Private nLoj	   := If((TAMSX3("A1_LOJA")[1]) < 1,2,(TAMSX3("A1_LOJA")[1]))
Private nSizeFil   := FwSizeFilial()
Private cEmp       := FWGrpCompany()
Private cFil       := FWCodFil()

//Cria Perguntas
dbSelectarea("SX1")
dbSetorder(01)
If !MDTRESTRI(cPrograma)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Devolve variaveis armazenadas (NGRIGHTCLICK) 			 			  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	NGRETURNPRM(aNGBEGINPRM)
	Return .F.
Endif

/*------------------------------
//PADRÃO							|
|  Data de Referência ?			|
|  De Filial ?					|
|  Até Filial						|
|  Imprimir Quadro ?				|
|  Consid. Hrs.					|
|  									|
//PRESTADOR						|
|  De Cliente ?					|
|  De Loja ?						|
|  Até Cliente ?					|
|  Até Loja ?						|
|  Data de Referência ?			|
|  De Filial ?					|
|  Até Filial						|
|  Imprimir Quadro ?				|
|  Consid. Hrs.					|
--------------------------------*/
    
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

Processa({|lEnd| fIMPRIME(If(lSigaMdtPS,mv_par08,mv_par04))}) // MONTE TELA PARA ACOMPANHAMENTO DO PROCESSO.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna conteudo de variaveis padroes       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
NGRETURNPRM(aNGBEGINPRM)
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fIMPRIME
Realiza impressao do relatorio   
   
@return aNecesFunc
@param nMvPar - Determina como será impresso
@author Andrey Martim Pegorini
@since 23/09/2010
/*/
//---------------------------------------------------------------------
Static Function fIMPRIME(nMvPar)
Local lImp := .F.
Local i
Local nPOS:=0
Local nVal:=0
Local nTot:=0 
Local nDia:=0
Local lRet:=.F.
Local lAst
Local xx
Local n
Local cClase
Private aTotalFunc := {}
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
  
If nMvPar == 1
        
   lImp := .T.
   lin  := 100
   col  := 275
   
	oPrint:StartPage()

	Somalinha()
	oPrint:Say(lin,1550,STR0021,oFont13bs,,,,2) //"DIMENSIONAMENTO DO SESMT"
	Somalinha(150,"F") // Linha Horizontal
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Cabeçalho																		
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Somalinha()
	
	// -------------------- Coluna 1 --------------------
	oPrint:Say(lin    ,col+25,STR0022,oFont10) //"GRAU"
	oPrint:Say(lin+60 ,col+45,STR0023,oFont10) //"DE"
	oPrint:Say(lin+120,col+25,STR0024,oFont10) //"RISCO"
	
	// -------------------- Coluna 2 --------------------
	col += 175
	
	oPrint:Say (lin+185,col+20 ,STR0025,oFont09) //"Técnicas"
	
	oPrint:Line(300    ,450    ,lin+250,1175   ) // Linha Diagonal
	
	oPrint:Say (lin-50 ,col+325,STR0026,oFont09) //"Nº de Empregados"
	oPrint:Say (lin    ,col+325,STR0027,oFont09) //"no Estabelecimento"
	
	// -------------------- Coluna 3 --------------------
	col += 725
	
	oPrint:Say(lin    ,col+25,"50"   ,oFont10)
	oPrint:Say(lin+60 ,col+45,STR0032,oFont10) //"a"
	oPrint:Say(lin+120,col+25,"100"  ,oFont10)
	
	// -------------------- Coluna 4 --------------------
	col += 175
	
	oPrint:Say(lin    ,col+25,"101"  ,oFont10)
	oPrint:Say(lin+60 ,col+45,STR0032,oFont10) //"a"
	oPrint:Say(lin+120,col+25,"250"  ,oFont10)
	
	// -------------------- Coluna 5 --------------------
	col += 175
	
	oPrint:Say(lin    ,col+25,"251"  ,oFont10)
	oPrint:Say(lin+60 ,col+45,STR0032,oFont10) //"a"
	oPrint:Say(lin+120,col+25,"500"  ,oFont10)
	
	// -------------------- Coluna 6 --------------------
	col += 175
	
	oPrint:Say(lin    ,col+25,"501"  ,oFont10)
	oPrint:Say(lin+60 ,col+45,STR0032,oFont10) //"a"
	oPrint:Say(lin+120,col+25,"1.000",oFont10)
	
	// -------------------- Coluna 7 --------------------
	col += 175
	
	oPrint:Say(lin    ,col+25,"1.001",oFont10)
	oPrint:Say(lin+60 ,col+45,STR0032,oFont10) //"a"
	oPrint:Say(lin+120,col+25,"2.000",oFont10)
	
	// -------------------- Coluna 8 --------------------
	col += 175
	
	oPrint:Say(lin    ,col+25,"2.001",oFont10)
	oPrint:Say(lin+60 ,col+45,STR0032,oFont10) //"a"
	oPrint:Say(lin+120,col+25,"3.500",oFont10)
	
	// -------------------- Coluna 9 --------------------
	col += 175
	
	oPrint:Say(lin    ,col+25,"3.501",oFont10)
	oPrint:Say(lin+60 ,col+45,STR0032,oFont10) //"a"
	oPrint:Say(lin+120,col+25,"5.000",oFont10)
	
	// -------------------- Coluna 10 -------------------
	col += 175
	
	oPrint:Say(lin    ,col+25,STR0028,oFont10) //"Acima de 5.000"
	oPrint:Say(lin+60 ,col+25,STR0029,oFont10) //"Para cada Grupo"
	oPrint:Say(lin+120,col+25,STR0030,oFont10) //"De 4.000 ou fração"
	oPrint:Say(lin+180,col+25,STR0031,oFont10) //"acima de 2.000(**)"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Linha 1																					³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Somalinha(250,"F") // Linha Horizontal
	Somalinha(25)
	col := 275
	
	// -------------------- Coluna 1 --------------------
	oPrint:Say(lin+60 ,col+45,"1",oFont10)
	
	// -------------------- Coluna 2 --------------------
	col += 175
	
	oPrint:Say (lin    ,col+20 ,STR0033+STR0053,oFont09) //"Técnico Seg."##"Trabalho"
	oPrint:Say (lin+60 ,col+20 ,STR0034+STR0053,oFont09) //"Engenheiro Seg."##"Trabalho"
	oPrint:Say (lin+120,col+20 ,STR0035+STR0053,oFont09) //"Aux. Enferm. do"##"Trabalho"
	oPrint:Say (lin+180,col+20 ,STR0036+STR0053,oFont09) //"Enfermeiro do"##"Trabalho"
	oPrint:Say (lin+240,col+20 ,STR0037+STR0053,oFont09) //"Médico do"##"Trabalho"
	
	// -------------------- Coluna 3 --------------------
	col += 725
	
	// -------------------- Coluna 4 --------------------
	col += 175
	
	// -------------------- Coluna 5 --------------------
	col += 175
	
	// -------------------- Coluna 6 --------------------
	col += 175
	
	oPrint:Say (lin    ,col+20 ,"1" ,oFont09) //"Técnico Seg. Trabalho"
	
	// -------------------- Coluna 7 --------------------
	col += 175
	
	oPrint:Say (lin    ,col+20 ,"1" ,oFont09) //"Técnico Seg. Trabalho"
	oPrint:Say (lin+240,col+20 ,"1*",oFont09) //"Médico do Trabalho"
	
	// -------------------- Coluna 8 --------------------
	col += 175
	
	oPrint:Say (lin    ,col+20 ,"1" ,oFont09) //"Técnico Seg. Trabalho"
	oPrint:Say (lin+60 ,col+20 ,"1*",oFont09) //"Engenheiro Seg. Trabalho"
	oPrint:Say (lin+120,col+20 ,"1" ,oFont09) //"Aux. Enferm. do Trabalho"
	oPrint:Say (lin+240,col+20 ,"1*",oFont09) //"Médico do Trabalho"
	
	// -------------------- Coluna 9 --------------------
	col += 175
	          
	oPrint:Say (lin    ,col+20 ,"2" ,oFont09) //"Técnico Seg. Trabalho"
	oPrint:Say (lin+60 ,col+20 ,"1" ,oFont09) //"Engenheiro Seg. Trabalho"
	oPrint:Say (lin+120,col+20 ,"1" ,oFont09) //"Aux. Enferm. do Trabalho"
	oPrint:Say (lin+180,col+20 ,"1*",oFont09) //"Enfermeiro do Trabalho"
	oPrint:Say (lin+240,col+20 ,"1" ,oFont09) //"Médico do Trabalho"
	
	// -------------------- Coluna 10 -------------------
	col += 175 
	
	oPrint:Say (lin    ,col+20 ,"1" ,oFont09) //"Técnico Seg. Trabalho"
	oPrint:Say (lin+60 ,col+20 ,"1*",oFont09) //"Engenheiro Seg. Trabalho"
	oPrint:Say (lin+120,col+20 ,"1" ,oFont09) //"Aux. Enferm. do Trabalho"
	oPrint:Say (lin+240,col+20 ,"1*",oFont09) //"Médico do Trabalho"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Linha 2																					³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Somalinha(300,"F") // Linha Horizontal
	Somalinha(25)
	col := 275
	
	// -------------------- Coluna 1 --------------------
	oPrint:Say(lin+60 ,col+45,"2",oFont10)
	
	// -------------------- Coluna 2 --------------------
	col += 175
	
	oPrint:Say (lin    ,col+20 ,STR0033+STR0053,oFont09) //"Técnico Seg."##"Trabalho"
	oPrint:Say (lin+60 ,col+20 ,STR0034+STR0053,oFont09) //"Engenheiro Seg."##"Trabalho"
	oPrint:Say (lin+120,col+20 ,STR0035+STR0053,oFont09) //"Aux. Enferm. do"##"Trabalho"
	oPrint:Say (lin+180,col+20 ,STR0036+STR0053,oFont09) //"Enfermeiro do"##"Trabalho"
	oPrint:Say (lin+240,col+20 ,STR0037+STR0053,oFont09) //"Médico do"##"Trabalho"
	
	// -------------------- Coluna 3 --------------------
	col += 725
	
	// -------------------- Coluna 4 --------------------
	col += 175
	
	// -------------------- Coluna 5 --------------------
	col += 175
	
	// -------------------- Coluna 6 --------------------
	col += 175
	
	oPrint:Say (lin    ,col+20 ,"1" ,oFont09) //"Técnico Seg. Trabalho"
	
	// -------------------- Coluna 7 --------------------
	col += 175
	
	oPrint:Say (lin    ,col+20 ,"1" ,oFont09) //"Técnico Seg. Trabalho"
	oPrint:Say (lin+60 ,col+20 ,"1*",oFont09) //"Engenheiro Seg. Trabalho"
	oPrint:Say (lin+120,col+20 ,"1" ,oFont09) //"Aux. Enferm. do Trabalho"
	oPrint:Say (lin+240,col+20 ,"1*",oFont09) //"Médico do Trabalho"
	
	// -------------------- Coluna 8 --------------------
	col += 175
	
	oPrint:Say (lin    ,col+20 ,"2" ,oFont09) //"Técnico Seg. Trabalho"
	oPrint:Say (lin+60 ,col+20 ,"1" ,oFont09) //"Engenheiro Seg. Trabalho"
	oPrint:Say (lin+120,col+20 ,"1" ,oFont09) //"Aux. Enferm. do Trabalho"
	oPrint:Say (lin+180,col+20 ,"1" ,oFont09) //"Enfermeiro do Trabalho"
	oPrint:Say (lin+240,col+20 ,"1" ,oFont09) //"Médico do Trabalho"
	
	// -------------------- Coluna 9 --------------------
	col += 175
	
	oPrint:Say (lin    ,col+20 ,"5" ,oFont09) //"Técnico Seg. Trabalho"
	oPrint:Say (lin+60 ,col+20 ,"1" ,oFont09) //"Engenheiro Seg. Trabalho"
	oPrint:Say (lin+120,col+20 ,"1" ,oFont09) //"Aux. Enferm. do Trabalho"
	oPrint:Say (lin+240,col+20 ,"1" ,oFont09) //"Médico do Trabalho"
	
	// -------------------- Coluna 10 -------------------
	col += 175
	
	oPrint:Say (lin    ,col+20 ,"1" ,oFont09) //"Técnico Seg. Trabalho"
	oPrint:Say (lin+60 ,col+20 ,"1*",oFont09) //"Engenheiro Seg. Trabalho"
	oPrint:Say (lin+120,col+20 ,"1" ,oFont09) //"Aux. Enferm. do Trabalho"
	oPrint:Say (lin+240,col+20 ,"1" ,oFont09) //"Médico do Trabalho"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Linha 3																					³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Somalinha(300,"F") // Linha Horizontal
	Somalinha(25)
	col := 275
	
	// -------------------- Coluna 1 --------------------
	oPrint:Say(lin+60 ,col+45,"3",oFont10)
	
	// -------------------- Coluna 2 --------------------
	col += 175
	
	oPrint:Say (lin    ,col+20 ,STR0033+STR0053,oFont09) //"Técnico Seg."##"Trabalho"
	oPrint:Say (lin+60 ,col+20 ,STR0034+STR0053,oFont09) //"Engenheiro Seg."##"Trabalho"
	oPrint:Say (lin+120,col+20 ,STR0035+STR0053,oFont09) //"Aux. Enferm. do"##"Trabalho"
	oPrint:Say (lin+180,col+20 ,STR0036+STR0053,oFont09) //"Enfermeiro do"##"Trabalho"
	oPrint:Say (lin+240,col+20 ,STR0037+STR0053,oFont09) //"Médico do"##"Trabalho"
	
	// -------------------- Coluna 3 --------------------
	col += 725
	
	// -------------------- Coluna 4 --------------------
	col += 175
	
	oPrint:Say (lin    ,col+20 ,"1" ,oFont09) //"Técnico Seg. Trabalho"
	
	// -------------------- Coluna 5 --------------------
	col += 175
	
	oPrint:Say (lin    ,col+20 ,"2" ,oFont09) //"Técnico Seg. Trabalho"
	
	// -------------------- Coluna 6 --------------------
	col += 175
	
	oPrint:Say (lin    ,col+20 ,"3" ,oFont09) //"Técnico Seg. Trabalho"
	oPrint:Say (lin+60 ,col+20 ,"1*",oFont09) //"Engenheiro Seg. Trabalho"
	oPrint:Say (lin+240,col+20 ,"1*" ,oFont09) //"Médico do Trabalho"
	
	// -------------------- Coluna 7 --------------------
	col += 175
	
	oPrint:Say (lin    ,col+20 ,"4" ,oFont09) //"Técnico Seg. Trabalho"
	oPrint:Say (lin+60 ,col+20 ,"1" ,oFont09) //"Engenheiro Seg. Trabalho"
	oPrint:Say (lin+120,col+20 ,"1" ,oFont09) //"Aux. Enferm. do Trabalho"
	oPrint:Say (lin+240,col+20 ,"1" ,oFont09) //"Médico do Trabalho"
	
	// -------------------- Coluna 8 --------------------
	col += 175
	
	oPrint:Say (lin    ,col+20 ,"6" ,oFont09) //"Técnico Seg. Trabalho"
	oPrint:Say (lin+60 ,col+20 ,"1" ,oFont09) //"Engenheiro Seg. Trabalho"
	oPrint:Say (lin+120,col+20 ,"2" ,oFont09) //"Aux. Enferm. do Trabalho"
	oPrint:Say (lin+240,col+20 ,"1" ,oFont09) //"Médico do Trabalho"
	
	// -------------------- Coluna 9 --------------------
	col += 175
	
	oPrint:Say (lin    ,col+20 ,"8" ,oFont09) //"Técnico Seg. Trabalho"
	oPrint:Say (lin+60 ,col+20 ,"2" ,oFont09) //"Engenheiro Seg. Trabalho"
	oPrint:Say (lin+120,col+20 ,"1" ,oFont09) //"Aux. Enferm. do Trabalho"
	oPrint:Say (lin+180,col+20 ,"1" ,oFont09) //"Enfermeiro do Trabalho"
	oPrint:Say (lin+240,col+20 ,"2" ,oFont09) //"Médico do Trabalho"
	
	// -------------------- Coluna 10 -------------------
	col += 175
	
	oPrint:Say (lin    ,col+20 ,"3" ,oFont09) //"Técnico Seg. Trabalho"
	oPrint:Say (lin+60 ,col+20 ,"1" ,oFont09) //"Engenheiro Seg. Trabalho"
	oPrint:Say (lin+120,col+20 ,"1" ,oFont09) //"Aux. Enferm. do Trabalho"
	oPrint:Say (lin+240,col+20 ,"1" ,oFont09) //"Médico do Trabalho"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Linha 4																					³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Somalinha(300,"F") // Linha Horizontal
	Somalinha(25)
	col := 275
	
	// -------------------- Coluna 1 --------------------
	oPrint:Say(lin+60 ,col+45,"4",oFont10)
	
	// -------------------- Coluna 2 --------------------
	col += 175
	
	oPrint:Say (lin    ,col+20 ,STR0033+STR0053,oFont09) //"Técnico Seg."##"Trabalho"
	oPrint:Say (lin+60 ,col+20 ,STR0034+STR0053,oFont09) //"Engenheiro Seg."##"Trabalho"
	oPrint:Say (lin+120,col+20 ,STR0035+STR0053,oFont09) //"Aux. Enferm. do"##"Trabalho"
	oPrint:Say (lin+180,col+20 ,STR0036+STR0053,oFont09) //"Enfermeiro do"##"Trabalho"
	oPrint:Say (lin+240,col+20 ,STR0037+STR0053,oFont09) //"Médico do"##"Trabalho"

	// -------------------- Coluna 3 --------------------
	col += 725
	
	oPrint:Say (lin    ,col+20 ,"1" ,oFont09) //"Técnico Seg. Trabalho"
	
	// -------------------- Coluna 4 --------------------
	col += 175
	
	oPrint:Say (lin    ,col+20 ,"2" ,oFont09) //"Técnico Seg. Trabalho"
	oPrint:Say (lin+60 ,col+20 ,"1*",oFont09) //"Engenheiro Seg. Trabalho"
	oPrint:Say (lin+240,col+20 ,"1*",oFont09) //"Médico do Trabalho"
	
	// -------------------- Coluna 5 --------------------
	col += 175
	
	oPrint:Say (lin    ,col+20 ,"3" ,oFont09) //"Técnico Seg. Trabalho"
	oPrint:Say (lin+60 ,col+20 ,"1*",oFont09) //"Engenheiro Seg. Trabalho"
	oPrint:Say (lin+240,col+20 ,"1*",oFont09) //"Médico do Trabalho"
	
	// -------------------- Coluna 6 --------------------
	col += 175
	
	oPrint:Say (lin    ,col+20 ,"4" ,oFont09) //"Técnico Seg. Trabalho"
	oPrint:Say (lin+60 ,col+20 ,"1" ,oFont09) //"Engenheiro Seg. Trabalho"
	oPrint:Say (lin+120,col+20 ,"1" ,oFont09) //"Aux. Enferm. do Trabalho"
	oPrint:Say (lin+240,col+20 ,"1" ,oFont09) //"Médico do Trabalho"
	
	// -------------------- Coluna 7 --------------------
	col += 175
	
	oPrint:Say (lin    ,col+20 ,"5" ,oFont09) //"Técnico Seg. Trabalho"
	oPrint:Say (lin+60 ,col+20 ,"1" ,oFont09) //"Engenheiro Seg. Trabalho"
	oPrint:Say (lin+120,col+20 ,"1" ,oFont09) //"Aux. Enferm. do Trabalho"
	oPrint:Say (lin+240,col+20 ,"1" ,oFont09) //"Médico do Trabalho"
	
	// -------------------- Coluna 8 --------------------
	col += 175
	
	oPrint:Say (lin    ,col+20 ,"8" ,oFont09) //"Técnico Seg. Trabalho"
	oPrint:Say (lin+60 ,col+20 ,"2" ,oFont09) //"Engenheiro Seg. Trabalho"
	oPrint:Say (lin+120,col+20 ,"2" ,oFont09) //"Aux. Enferm. do Trabalho"
	oPrint:Say (lin+240,col+20 ,"2" ,oFont09) //"Médico do Trabalho"
	
	// -------------------- Coluna 9 --------------------
	col += 175
	
	oPrint:Say (lin    ,col+20 ,"10",oFont09) //"Técnico Seg. Trabalho"
	oPrint:Say (lin+60 ,col+20 ,"3" ,oFont09) //"Engenheiro Seg. Trabalho"
	oPrint:Say (lin+120,col+20 ,"1" ,oFont09) //"Aux. Enferm. do Trabalho"
	oPrint:Say (lin+180,col+20 ,"1" ,oFont09) //"Enfermeiro do Trabalho"
	oPrint:Say (lin+240,col+20 ,"3" ,oFont09) //"Médico do Trabalho"
	
	// -------------------- Coluna 10 -------------------
	col += 175
	
	oPrint:Say (lin    ,col+20 ,"3" ,oFont09) //"Técnico Seg. Trabalho"
	oPrint:Say (lin+60 ,col+20 ,"1" ,oFont09) //"Engenheiro Seg. Trabalho"
	oPrint:Say (lin+120,col+20 ,"1" ,oFont09) //"Aux. Enferm. do Trabalho"
	oPrint:Say (lin+240,col+20 ,"1" ,oFont09) //"Médico do Trabalho"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Fim da Tabela																			³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Somalinha(300,"F") // Linha Horizontal
	
	// Linhas Verticais
	oPrint:Line(300,275 ,lin,275 )
	oPrint:Line(300,450 ,lin,450 )
	oPrint:Line(300,1175,lin,1175)
	oPrint:Line(300,1350,lin,1350)
	oPrint:Line(300,1525,lin,1525)
	oPrint:Line(300,1700,lin,1700)
	oPrint:Line(300,1875,lin,1875)
	oPrint:Line(300,2050,lin,2050)
	oPrint:Line(300,2225,lin,2225)
	oPrint:Line(300,2400,lin,2400)
	oPrint:Line(300,2875,lin,2875)	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Observacoes																				³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Somalinha(10,"F") // Linha Horizontal
	col := 275
	
	// Linhas Verticais
	oPrint:Line(lin,275 ,lin+325,275 )
	oPrint:Line(lin,2875,lin+325,2875)
	
	// -------------------- Coluna 1 --------------------
	oPrint:Say (lin+15 ,col+25,STR0038,oFont10) //"(*) Tempo parcial (mínimo de três horas)"
	oPrint:Say (lin+75 ,col+25,STR0039,oFont10) //"(**) O dimensionamento total deverá ser feito"
	oPrint:Say (lin+135,col+25,STR0040,oFont10) //"levando-se em consideração o dimensionamento"
	oPrint:Say (lin+195,col+25,STR0041,oFont10) //"de faixas 3.501 a 5.000 mais o dimensionamento"
	oPrint:Say (lin+255,col+25,STR0042,oFont10) //"do(s) grupo(s) de 4.000 ou fração acima de 2.000."
	
	// -------------------- Coluna 2 --------------------
	col += 1425 //Equivalente a Coluna 6
	
	oPrint:Say (lin+15 ,col+15,STR0054+STR0043,oFont10) //"OBS: Hospitais, Ambulatórios, Maternidade, Casas de"
	oPrint:Say (lin+75 ,col+15,STR0044			 ,oFont10) //"Saúde e Repouso, Clínicas e estabelecimentos similares"
	oPrint:Say (lin+135,col+15,STR0045			 ,oFont10) //"com mais de 500 (quinhentos) empregados deverão"
	oPrint:Say (lin+195,col+15,STR0046			 ,oFont10) //"contratar um enfermeiro em tempo integral"
	
	oPrint:Line(lin+325,275,lin+325,2875)
	
	oPrint:EndPage()

ElseIf nMvPar == 2

	Processa({|lEnd| aTotalFunc := fTOTALFUNC()})//Carrega Array com o total de funcionários de cada filial

	oPrint:StartPage()
	lin := 100
	Somalinha()
	oPrint:Say(lin,1550,STR0021,oFont13bs,,,,2) //"DIMENSIONAMENTO DO SESMT"
	
	ProcRegua(Len(aTotalFunc))
   
	For i:=1 To Len(aTotalFunc)
	
		IncProc()
	
		dbSelectArea("SM0")
		dbSetOrder(1)
		If dbSeek(cEmp + aTotalFunc[i][1])
			
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
					oPrint:Say(lin,col+600,cValToChar(aTotalFunc[i][2]),oFont11)
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³	Cabeçalho																				³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Somalinha(80,"C")
					col  := 100
					
					// -------------------- Coluna 1 --------------------
					oPrint:Say (lin+125,col+20 ,STR0050,oFont09) //"Situação da Empresa"
					
					oPrint:Line(lin    ,col    ,lin+200,col+600) // Linha Diagonal
					
					oPrint:Say (lin    ,col+400,STR0025,oFont09) //"Técnicas"
					
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
					
						
					aNeces := fNESCFUNC(TOE->TOE_GRISCO,aTotalFunc[i][2])
					// -------------------- Coluna 1 --------------------
					oPrint:Say (lin+20,col+20 ,STR0051,oFont09) // Necessidade
					
					// -------------------- Colzuna 2 --------------------
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
					
					aReal := lREALFUNC(aTotalFunc[i][1])
					
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
					oPrint:Say(lin+60 ,100,STR0055+STR0056,oFont10,,ColorBlack) //"Legenda: "##"Preto - Dentro dos Conformes"
					oPrint:Say(lin+120,300,STR0057        ,oFont10,,ColorRed)   //"Vermelho - Fora dos Conformes"
					If i < Len(aTotalFunc)
						Somalinha(150)
					EndIf
				EndIf
			EndIf
		EndIf		
	Next i
	 
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
Realiza Salto de Linha.
   
@return aNecesFunc
@param nLin - Distância que será pulada
@param cPrtLin - Distancia pré fixada
@author Andrey M. Pegorini
@since 01/10/2010
@obs Utilizado nos fontes: MDTR961
/*/
//---------------------------------------------------------------------
Static Function Somalinha(nLin, cPrtLin)
Default nLin    := 50

lin += nLin

If cPrtLin == "F"
	oPrint:Line(lin,275,lin,2875)
ElseIf cPrtLin == "C"
	oPrint:Line(lin,100,lin,2450)
EndIf
If lin > 1950
	oPrint:EndPage()
	oPrint:StartPage()
	lin := 100
EndIf   

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fTOTALFUNC
Retorna quantidade de funcionarios da empresa 
   
@return aFunc 
@author Andrey Martim Pegorini
@since 23/09/2010
/*/
//---------------------------------------------------------------------
Static Function fTOTALFUNC()
Local aArea   := GetArea()
Local nFunc   := 0
Local cFilSRA := mv_par02   
Local aFunc   := {}
Local lFilial := .T.

If !lSigaMdtps
	dbSelectArea("SRA")
	dbSetOrder(1)
	dbSeek(mv_par02,.T.)
	While !Eof() .and. SRA->RA_FILIAL >= mv_par02 .and. SRA->RA_FILIAL <= mv_par03
		If lFilial .and. Empty(mv_par02)
			cFilSRA := SRA->RA_FILIAL
			lFilial := .F.
		EndIf
		If SRA->RA_SITFOLH != "D" .and. cFilSRA == SRA->RA_FILIAL .and.;
			DtoS(SRA->RA_ADMISSA) <= DtoS(mv_par01) .and.;
		  (Empty(DtoS(SRA->RA_DEMISSA)) .or. SRA->RA_DEMISSA > dDataBase)
			nFunc++
		EndIf
		If cFilSRA != SRA->RA_FILIAL
			aAdd (aFunc , {cFilSRA , nFunc} )
			cFilSRA := SRA->RA_FILIAL
			nFunc   := 1
		EndIf
		dbSelectArea("SRA")
		dbSkip()
		Loop
	End
	aAdd (aFunc , {cFilSRA , nFunc} )
Else
	dbSelectArea("SRA")
	dbSetOrder(1)
	dbSeek(mv_par06,.T.)
	While !Eof() .and. SRA->RA_FILIAL >= mv_par06 .and. SRA->RA_FILIAL <= mv_par07
		If lFilial .and. Empty(mv_par02)
			cFilSRA := SRA->RA_FILIAL
			lFilial := .F.
		EndIf
		If SRA->RA_SITFOLH != "D" .and.;
			DtoS(SRA->RA_ADMISSA) <= DtoS(mv_par05) .and.;
		  (Empty(DtoS(SRA->RA_DEMISSA)) .or. SRA->RA_DEMISSA > dDataBase) .and.;
		   Substr(SRA->RA_CC,1,nCod+nLoj) == mv_par01+mv_par02 .and. xFilial("SRA") == SRA->RA_FILIAL
			nFunc++
		EndIf
		If cFilSRA != SRA->RA_FILIAL
			aAdd (aFunc , {cFilSRA , nFunc} )                      
			cFilSRA := SRA->RA_FILIAL
			nFunc   := 1                           
		EndIf
		dbSelectArea("SRA")
		dbSkip()
		Loop
	End
	aAdd (aFunc , {cFilSRA , nFunc} )
EndIf

RestArea(aArea)
Return aFunc

//---------------------------------------------------------------------
/*/{Protheus.doc} fNESCFUNC
 Retorna quantidade necessária no sesmt 
   
@return aNecesFunc
@param cRisco - Obrigatório,valor do campo TOE->TOE_GRISCO
@param nTotalFunc - Obrigatório,total de funcionários da filial
@author Andrey Martim Pegorini
@since 06/10/2010
@obs Utilizado nos fontes: MDTR961
/*/
//---------------------------------------------------------------------
Static Function fNESCFUNC(cRisco,nTotalFunc)
Local cTecnico    := "0"
Local cEngenheiro := "0"
Local cAuxEnferm  := "0"
Local cEnfermeiro := "0"
Local cMedico     := "0"
Local nResto      := 0
Local nAuxFunc    := 0
Local lAuxFunc    := .T.
Local aNecesFunc  := {}

If cRisco == "1" 

	If  nTotalFunc >= 501  .and. nTotalFunc <= 1000
		cTecnico    := "1"
	ElseIf nTotalFunc >= 1001 .and. nTotalFunc <= 2000
		cTecnico    := "1"
		cMedico     := "1*"
	ElseIf nTotalFunc >= 2001 .and. nTotalFunc <= 3500
		cTecnico    := "1"
		cEngenheiro := "1*"
		cAuxEnferm  := "1"
		cMedico     := "1*"
	ElseIf nTotalFunc >= 3501
		cTecnico    := "2"
		cEngenheiro := "1"
		cAuxEnferm  := "1"
		cEnfermeiro := "1*"
		cMedico     := "1"
		If nTotalFunc > 5000
			While lAuxFunc
				If nResto == 0
					nResto := nTotalFunc - 5000
				EndIf
				If nResto < 2000
					lAuxFunc := .F.
				ElseIf nResto >= 2000 .and. nResto <= 4000
					lAuxFunc := .F.
					nAuxFunc++
				ElseIf nResto > 4000
					nResto := nResto - 4000
					nAuxFunc++
				EndIf
			End
			While nAuxFunc > 0
				cTecnico    := cValToChar(Val(cTecnico)    + 1)
				cEngenheiro := cValToChar(Val(cEngenheiro) + 1) + "*"
				cAuxEnferm  := cValToChar(Val(cAuxEnferm)  + 1)
				cMedico     := cValToChar(Val(cMedico)     + 1) + "*"
				nAuxFunc--
			End
		EndIf
	EndIf
	
ElseIf cRisco == "2" 

	If     nTotalFunc >= 501  .and. nTotalFunc <= 1000
		cTecnico    := "1"
	ElseIf nTotalFunc >= 1001 .and. nTotalFunc <= 2000
		cTecnico    := "1"
		cEngenheiro := "1*"
		cAuxEnferm  := "1"
		cMedico     := "1*"
	ElseIf nTotalFunc >= 2001 .and. nTotalFunc <= 3500
		cTecnico    := "2"
		cEngenheiro := "1"
		cAuxEnferm  := "1"
		cEnfermeiro := "1"
		cMedico     := "1"
	ElseIf nTotalFunc >= 3501
		cTecnico    := "5"
		cEngenheiro := "1"
		cAuxEnferm  := "1"
		cMedico     := "1"
		If nTotalFunc > 5000
			While lAuxFunc
				If nResto == 0
					nResto := nTotalFunc - 5000
				EndIf
				If nResto < 2000
					lAuxFunc := .F.
				ElseIf nResto >= 2000 .and. nResto <= 4000
					lAuxFunc    := .F.
					nAuxFunc++
				ElseIf nResto > 4000
					nResto := nResto - 4000
					nAuxFunc++
				EndIf
			End
			While nAuxFunc > 0
				cTecnico    := cValToChar(Val(cTecnico)    + 1)
				cEngenheiro := cValToChar(Val(cEngenheiro) + 1) + "*"
				cAuxEnferm  := cValToChar(Val(cAuxEnferm)  + 1)
				cMedico     := cValToChar(Val(cMedico)     + 1)
				nAuxFunc--
			End
		EndIf
	EndIf             
	
ElseIf cRisco == "3" 

	If     nTotalFunc >= 101  .and. nTotalFunc <= 250
		cTecnico    := "1"
	ElseIf nTotalFunc >= 251  .and. nTotalFunc <= 500
		cTecnico    := "2"
	ElseIf nTotalFunc >= 501  .and. nTotalFunc <= 1000
		cTecnico    := "3"
		cEngenheiro := "1*"
		cMedico     := "1*"
	ElseIf nTotalFunc >= 1001 .and. nTotalFunc <= 2000
		cTecnico    := "4"
		cEngenheiro := "1"
		cAuxEnferm  := "1"
		cMedico     := "1"
	ElseIf nTotalFunc >= 2001 .and. nTotalFunc <= 3500
		cTecnico    := "6"
		cEngenheiro := "1"
		cAuxEnferm  := "2"
		cMedico     := "1"
	ElseIf nTotalFunc >= 3501
		cTecnico    := "8"
		cEngenheiro := "2"
		cAuxEnferm  := "1"
		cEnfermeiro := "1"
		cMedico     := "2"
		If nTotalFunc > 5000
			While lAuxFunc
				If nResto == 0
					nResto := nTotalFunc - 5000
				EndIf
				If nResto < 2000
					lAuxFunc := .F.
				ElseIf nResto >= 2000 .and. nResto <= 4000
					lAuxFunc    := .F.
					nAuxFunc++
				ElseIf nResto > 4000
					nResto := nResto - 4000
					nAuxFunc++
				EndIf
			End
			While nAuxFunc > 0
				cTecnico    := cValToChar(Val(cTecnico)    + 3)
				cEngenheiro := cValToChar(Val(cEngenheiro) + 1)
				cAuxEnferm  := cValToChar(Val(cAuxEnferm)  + 1)
				cMedico     := cValToChar(Val(cMedico)     + 1)
				nAuxFunc--
			End
		EndIf
	EndIf           
	
ElseIf cRisco == "4" 

	If     nTotalFunc >= 50   .and. nTotalFunc <= 100
		cTecnico    := "1"
	ElseIf nTotalFunc >= 101  .and. nTotalFunc <= 250
		cTecnico    := "2"
		cEngenheiro := "1*"
		cMedico     := "1*"
	ElseIf nTotalFunc >= 251  .and. nTotalFunc <= 500
		cTecnico    := "3"
		cEngenheiro := "1*"
		cMedico     := "1*"
	ElseIf nTotalFunc >= 501  .and. nTotalFunc <= 1000
		cTecnico    := "4"
		cEngenheiro := "1"
		cAuxEnferm  := "1"
		cMedico     := "1"
	ElseIf nTotalFunc >= 1001 .and. nTotalFunc <= 2000
		cTecnico    := "5"
		cEngenheiro := "1"
		cAuxEnferm  := "1"
		cMedico     := "1"
	ElseIf nTotalFunc >= 2001 .and. nTotalFunc <= 3500
		cTecnico    := "8"
		cEngenheiro := "2"
		cAuxEnferm  := "2"
		cMedico     := "2"
	ElseIf nTotalFunc >= 3501
		cTecnico    := "10"
		cEngenheiro := "3"
		cAuxEnferm  := "1"
		cEnfermeiro := "1"
		cMedico     := "3"
		If nTotalFunc > 5000
			While lAuxFunc
				If nResto == 0
					nResto := nTotalFunc - 5000
				EndIf
				If nResto < 2000
					lAuxFunc := .F.
				ElseIf nResto >= 2000 .and. nResto <= 4000
					lAuxFunc    := .F.
					nAuxFunc++
				ElseIf nResto > 4000
					nResto := nResto - 4000
					nAuxFunc++
				EndIf
			End
			While nAuxFunc > 0
				cTecnico    := cValToChar(Val(cTecnico)    + 3)
				cEngenheiro := cValToChar(Val(cEngenheiro) + 1)
				cAuxEnferm  := cValToChar(Val(cAuxEnferm)  + 1)
				cMedico     := cValToChar(Val(cMedico)     + 1)
				nAuxFunc--
			End
		EndIf
	EndIf  
	
EndIf

aAdd (aNecesFunc , { cTecnico , cEngenheiro, cAuxEnferm, cEnfermeiro, cMedico })

Return aNecesFunc

//---------------------------------------------------------------------
/*/{Protheus.doc} lREALFUNC
Retorna quantidade real de componentes do Sesmt
   
@return aRealFunc
@param cFilFun - Total de Funcionários.
@author Andrey Martim Pegorini
@since 08/10/2010
@obs Utilizado nos fontes: MDTR961
/*/
//---------------------------------------------------------------------
Static Function lREALFUNC(cFilFun)
Local aArea		:= GetArea()
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

If !lSigaMdtps
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
			
			If Mv_PAR05 == 9
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
		EndIf 
		dbSelectArea("TMK")
		dbSkip()
		Loop
	End
Else
	dbSelectArea("TMK")
	dbSetOrder(1)
	dbSeek(cFilFun)
	While !Eof() .and. TMK->TMK_FILIAL == cFilFun
		If Substr(TMK->TMK_CC,1,nCod+nLoj) >= mv_par01+mv_par02 .and. Substr(TMK->TMK_CC,1,nCod+nLoj) <= mv_par03+mv_par04
			If TMK->TMK_SESMT == "1" .and.;
				DtoS(TMK->TMK_DTINIC) <= DtoS(mv_par05) .and.;
			  (Empty(DtoS(TMK->TMK_DTTERM)) .or. TMK->TMK_DTTERM > dDataBase)
				If TMK->TMK_INDFUN == "1" 
					cMedico := cValToChar(Val(cMedico)     + 1)
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
			If Mv_PAR09 == 1 
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
		Endif
		dbSelectArea("TMK")
		dbSkip()
		Loop 
	End  
EndIf

If If(!lSigaMdtPS,mv_par05 == 1,mv_par09 == 1)
	aAdd (aRealFunc , { { cTecnico , lTecSeg } , { cEngenheiro , lEngSeg  } , { cAuxEnferm , lAuxEnf } , { cEnfermeiro , lEnfTra } , { cMedico , lMedTra } })
Else
	aAdd (aRealFunc , { { cTecnico , .T. } , { cEngenheiro , .T.  } , { cAuxEnferm , .T. } , { cEnfermeiro , .T. } , { cMedico , .T. } })
EndIf

RestArea(aArea)  
Return aRealFunc  

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
	
	If If(!lSigaMdtPS,mv_par05 == 1,mv_par09 == 1)
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