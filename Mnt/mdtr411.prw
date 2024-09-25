#INCLUDE "MDTR411.ch"
#Include "Protheus.ch"

#DEFINE _nVERSAO 02 //Versao do fonte
//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR411
Respostas ao Questionario de Acidentes
Permite tabular as respostas dos questionamentos do acidente

@Param aDados
@Param lFont - Verifica se é chamado de outro fonte - MDTA690

@author Jackson Machado
@since 28/02/11
/*/
//---------------------------------------------------------------------
Function MDTR411( aDados, lCallMDTR411 )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena variaveis p/ devolucao (NGRIGHTCLICK) 				 	  	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL wnrel   := "MDTR411"
LOCAL limite  := 132
LOCAL cDesc1  := STR0001 //"Relatorio de apresentacao do questionario e suas respostas e resumo "
LOCAL cDesc2  := STR0002 //"contento estatistica das respostas do universo selecionado          "
LOCAL cDesc3  := STR0003 //"Opcao disponivel atraves do botao de  parametros.   "
LOCAL cString := "TO6",nFor

Private cCliMdtPs
PRIVATE aDad145
If Valtype(aDados) == "A"  
	aDad145 := aClone(aDados)
Endif

Private nSizeTMH := (TAMSX3("TMH_PERGUN")[1])
nSizeTMH := If( nSizeTMH > 0 , nSizeTMH , 60 )

lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )

PRIVATE nomeprog := "MDTR411"
PRIVATE tamanho  := "M"
PRIVATE aReturn  := { STR0004, 1,STR0005, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
PRIVATE titulo   := STR0006   // + ( NOME DO QUESTIONARIO ) //"Questionario de Acidente"
PRIVATE ntipo    := 0
PRIVATE nLastKey := 0
PRIVATE cPerg    :=If(!lSigaMdtPS,"MDT411    ","MDT411PS  ")
PRIVATE cabec1, cabec2
Private lPrinGraf := .t.
Private lPrintTel := .t.

PRIVATE nSizeTNC := If((TAMSX3("TNC_ACIDEN")[1]) < 1,9,(TAMSX3("TNC_ACIDEN")[1]))

//Variável de controle de funcionário
Private lFunc := .F.

Default lCallMDTR411 := .T.

If nSizeTMH > 60
	tamanho := "G"
Endif

/*
//----------------------------------------
//PERGUNTAS DO PADRÃO						|
|  01  Questionario ?        				|
|  02  De Acidente ?         				|
|  03  Até Acidente ?        				|
|  04  De  Data Realizacao ? 				|
|  05  Ate Data Realizacao ? 				|
|  06  Tipo Impressão?						|
| 												|
//PERGUNTAS DO PRESTADO 						|
|  01  Cliente ?             				|
|  02  Loja                  				|
|  03  Questionario ?        				|
|  04  De Acidente ?	     					|
|  05  Até Acidente ? 	    				|
|  06  De  Data Realizacao ? 				|
|  07  Ate Data Realizacao ? 				|
|  08  Tipo Impressão? 						|
//-----------------------------------------
*/

pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:="MDTR411"
If lCallMDTR411
	wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"")
EndIf

If Valtype(aDad145) == "A"
	For nFor := 1 To Len(aDad145)
		&(aDad145[nFor,1]) := aDad145[nFor,2]
	Next nFor
Else
	If nLastKey == 27
	   Set Filter to
	   Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
	   Set Filter to
	   Return
	Endif 	
	If lSigaMdtps
		If mv_par08 == 2
			lPrintTel := .f.
		Endif
	Else
		If mv_par06 == 2
			lPrintTel := .f.
		Endif
	Endif
Endif

If lSigaMdtps

	dbSelectArea("TMG")
	dbSetOrder(02)  //TMG_FILIAL+TMG_CLIENT+TMG_LOJA+TMG_QUESTI
	dbSeek(xFilial("TMG")+MV_PAR01+MV_PAR02+MV_PAR03)

Else

	dbSelectArea("TMG")
	dbSetOrder(01)
	dbSeek(xFilial("TMG")+MV_PAR01)

Endif

cDESQUEST := ALLTRIM(TMG->TMG_NOMQUE)

If lSigaMdtps
	titulo := titulo + "  " + cDESQUEST + " ("+DTOC(MV_PAR06)+" a "+DTOC(MV_PAR07)+")"
Else
	titulo := titulo + "  " + cDESQUEST + " ("+DTOC(MV_PAR04)+" a "+DTOC(MV_PAR05)+")"
Endif

If !lPrinGraf
	RptStatus( { | lEnd | R411Imp2( @lEnd , wnRel , titulo , tamanho ) } , titulo )
Else
	Processa( { | lEnd | fImpMod4() } )
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve variaveis armazenadas (NGRIGHTCLICK)                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
NGRETURNPRM(aNGBEGINPRM)

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
Static Function Somalinha(lImpGrf,nSaltoGrf)

If Valtype(lImpGrf) == "L"
	If lImpGrf
		If Valtype(nSaltoGrf) == "N"
			lin += nSaltoGrf
		Else
			lin += 60
		Endif
		If lin > 3000
			oPrint:Line(lin,200,lin,2300)
			lin := 150
			oPrint:EndPage() //Fechar Pagina
			fInicPagina() //Iniciar Pagina
			//oPrint:Line(lin,200,lin,2300)
		Endif
		Return
	Endif
Endif

Li++
If Li > 58
	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
EndIf

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ MDT411ACI³ Autor ³ Jackson Machado		  ³ Data ³01/03/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Valida a pergunta De Acidente (prestador)        	        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function MDT411ACI()   

Return IF(empty(mv_par04),.t.,existcpo('TNC',mv_par01+mv_par02+mv_par04,8))
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ MDTACI411³ Autor ³  Jackson Machado		  ³ Data ³01/03/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Valida a pergunta Ate Acidente (prestador)           	     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function MDTACI411()   

Return ValAte3(mv_par04,mv_par05,'TNC','TNC_ACIDEN',mv_par01+mv_par02,8)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³LoadArTmp ³ Autor ³ Denis                 ³ Data ³ 20/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Carrega arquivo temporario                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function LoadArTmp(lCombTK0,lRelGraf)

Local nLenCompl := (TAMSX3("TO6_COMRES")[1])
If nLenCompl < 30
	nLenCompl := 30
Endif

aDBF := {}
AADD(aDBF,{ "ACIDEN"  , "C" ,06, 0 })
AADD(aDBF,{ "PERGUNTA"  , "C" ,03, 0 })
AADD(aDBF,{ "NOMPERGU"  , "C" ,nSizeTMH, 0 })
AADD(aDBF,{ "RESPOS"    , "C" ,01, 0 })
AADD(aDBF,{ "DTREAL"    , "D" ,08, 0 })
AADD(aDBF,{ "QUANTID"   , "N" ,09, 2 })
AADD(aDBF,{ "COMPLEM"   , "C" ,nLenCompl, 0 })
AADD(aDBF,{ "CODGRUPO"  , "C" ,03, 0 })
AADD(aDBF,{ "XCOMBO"   , "C" ,250, 0 })

oTempTable := FWTemporaryTable():New( "TRB", aDBF )
oTempTable:AddIndex( "1", {"ACIDEN","DTREAL","CODGRUPO","PERGUNTA"} )
oTempTable:Create()

aDBF2 := {}
AADD(aDBF2,{ "PERGUNTA" , "C" ,03, 0 })
AADD(aDBF2,{ "NOMPERGU" , "C" ,nSizeTMH, 0 })
AADD(aDBF2,{ "RESPSIM"  , "N" ,06, 0 })                                  
AADD(aDBF2,{ "RESPNAO"  , "N" ,06, 0 })

oTempTable := FWTemporaryTable():New( "TRB2", aDBF2 )
oTempTable:AddIndex( "1", {"PERGUNTA"} )
oTempTable:Create()

If lSigaMdtps

	dbSelectArea("TO6")
	dbSetOrder(04)  //TO6_FILIAL+TO6_CLIENT+TO6_LOJA+TO6_QUESTI
	dbSeek(xFilial("TO6")+MV_PAR01+MV_PAR02+MV_PAR03)

	If lRelGraf
		ProcRegua(LastRec())
	Else
		SetRegua(LastRec())
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Correr TO6 para ler as  Questoes                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	While !Eof()                                   .AND.;
	      TO6->TO6_FILIAL == xFilial('TO6')        .AND.;
	      TO6->(TO6_CLIENT+TO6_LOJA) == MV_PAR01+MV_PAR02 .AND.;
	      TO6->TO6_QUESTI == MV_PAR03
	      	      
		If lRelGraf
			IncProc()
		Else
			IncRegua()
		Endif

		If TO6->TO6_ACIDEN < mv_par04 .or. TO6->TO6_ACIDEN > mv_par05
			dbSelectArea("TO6")
			dbSkip()
			Loop		
		Endif
		
		dbSelectArea("TNC")
		dbSetOrder(1)
		If !dbSeek(xFilial("TNC")+TO6->TO6_ACIDEN)
			dbSelectArea("TO6")
			dbSkip()
			loop
		Endif
			
	
		If TO6->TO6_DTREAL < MV_PAR06 .OR. TO6->TO6_DTREAL > MV_PAR07
			dbSelectArea("TO6")
			dbSkip()
			loop
		Endif
	
		dbSelectArea("TMH")
		dbSetOrder(02)  //TMH_FILIAL+TMH_CLIENT+TMH_LOJA+TMH_QUESTI+TMH_QUESTA
		If !dbSeek(xFilial("TMH")+mv_par01+mv_par02+TO6->TO6_QUESTI+TO6->TO6_QUESTA)
			dbSelectArea("TO6")
			dbSkip()
			loop
		Endif
	
		TRB->(DbAppend())
	
		TRB->ACIDEN   := TO6->TO6_ACIDEN
		TRB->PERGUNTA   := TO6->TO6_QUESTA
		TRB->NOMPERGU   := TMH->TMH_PERGUN
		TRB->RESPOS     := TO6->TO6_RESPOS
		TRB->DTREAL     := TO6->TO6_DTREAL
		TRB->QUANTID    := TO6->TO6_QTRESP
		TRB->COMPLEM    := TO6->TO6_COMRES
		TRB->XCOMBO   := TMH->TMH_COMBO
		TRB->CODGRUPO := TMH->TMH_CODGRU

		dbSelectArea("TRB2")
		If !dbSeek(TO6->TO6_QUESTA)
			TRB2->(DbAppend())
			TRB2->PERGUNTA := TO6->TO6_QUESTA
			TRB2->NOMPERGU := TMH->TMH_PERGUN
		Endif
	
		If TO6->TO6_RESPOS = '1'
			TRB2->RESPSIM := TRB2->RESPSIM + 1
		Else
			TRB2->RESPNAO := TRB2->RESPNAO + 1
		Endif
	
		dbSelectArea("TO6")
		dbSKIP()
	
	End

Else

	dbSelectArea("TO6")
	dbSetOrder(02)
	dbSeek(xFilial("TO6")+MV_PAR01,.T.)

	If lRelGraf
		ProcRegua(LastRec())
	Else
		SetRegua(LastRec())
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Correr TO6 para ler as  Questoes                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	While !Eof()                                   .AND.;
	      TO6->TO6_FILIAL == xFIlial('TO6')        .AND.;
	      TO6->TO6_QUESTI == MV_PAR01

		If lRelGraf
			IncProc()
		Else
			IncRegua()
		Endif

	
		If TO6->TO6_DTREAL < MV_PAR04 .OR. TO6->TO6_DTREAL > MV_PAR05
			dbSelectArea("TO6")
			dbSkip()
			loop
		Endif
	
		dbSelectArea("TNC")
		dbSetOrder(01)
		If dbSeek(xFilial("TNC")+TO6->TO6_ACIDEN)
			If TNC->TNC_ACIDEN < MV_PAR02 .OR. TNC->TNC_ACIDEN > MV_PAR03
				dbSelectArea("TO6")
				dbSkip()
				loop
			Endif
		Else
			dbSelectArea("TO6")
			dbSkip()
			loop
		Endif
	
		dbSelectArea("TMH")
		dbSetOrder(01)
		If !dbSeek(xFilial("TMH")+TO6->TO6_QUESTI+TO6->TO6_QUESTA)
			dbSelectArea("TO6")
			dbSkip()
			loop
		Endif
	
		TRB->(DbAppend())

		TRB->ACIDEN   := TO6->TO6_ACIDEN
		TRB->PERGUNTA   := TO6->TO6_QUESTA
		TRB->NOMPERGU   := TMH->TMH_PERGUN
		TRB->RESPOS     := TO6->TO6_RESPOS
		TRB->DTREAL     := TMI->TO6_DTREAL
		TRB->QUANTID    := TO6->TO6_QTRESP
		TRB->COMPLEM    := TO6->TO6_COMRES
		TRB->XCOMBO   := TMH->TMH_COMBO
		TRB->CODGRUPO := TMH->TMH_CODGRU

		dbSelectArea("TRB2")
		If !dbSeek(TO6->TO6_QUESTA)
			TRB2->(DbAppend())
			TRB2->PERGUNTA := TO6->TO6_QUESTA
			TRB2->NOMPERGU := TMH->TMH_PERGUN
		Endif
	
		If TO6->TO6_RESPOS = '1'
			TRB2->RESPSIM := TRB2->RESPSIM + 1
		Else
			TRB2->RESPNAO := TRB2->RESPNAO + 1
		Endif
	
		dbSelectArea("TO6")
		dbSKIP()
	
	End

Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fRetCbox ³ Autor ³Denis Hyroshi de Souza ³ Data ³ 01/04/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para mostar lista de opções ao entrar no campo      ³±±
±±³          ³ TMH_COMBO                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fRetCbox( cCboxTMH )
Local nPos,nPos1,cDesc,nXX,aCodBox
Local aBoxPerg := {}
Local cSemRes := "1="+STR0012+";"+"2="+STR0013+";"+"3="+STR0056 //"Sim"###"Nao"###"Sem Resposta"

nPos1 := aScan(aCboxSV,{|x| x[1] == Alltrim(cCboxTMH) })
If nPos1 > 0
	aBoxPerg := aClone( aCboxSV[nPos1,2] )
Else
	aCodBox := {"1","2","3","4","5","6","7","8","9",;
				"A","B","C","D","E","F","G","H","I",;
				"J","K","L","M","N","O","P","Q","R",;
				"S","T","U","V","W","X","Y","Z" }
	If cSemRes != Alltrim(cCboxTMH)
		For nXX := 1 To Len(aCodBox)
			nPos := At( aCodBox[nXX]+"=" , cCboxTMH )
			If nPos > 0
				nPos1 := At( ";" , Substr( cCboxTMH , nPos+2 ) )
				cDesc := Alltrim(Substr( cCboxTMH , nPos+2 ))
				If nPos1 > 0
					cDesc := Alltrim(Substr( cCboxTMH , nPos+2 , nPos1-1 ))
				Endif
				aAdd( aBoxPerg , { Alltrim(Substr(cDesc,1,30)) , aCodBox[nXX] } )
			Endif
		Next nXX
	Endif
	If Len(aBoxPerg) == 0
		aAdd( aBoxPerg , { STR0012 , "1" } ) //"Sim"
		aAdd( aBoxPerg , { STR0013 , "2" } ) //"Nao"
	Endif
	aAdd(aCboxSV , { Alltrim(cCboxTMH) , aBoxPerg } )
Endif

Return aBoxPerg

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fInicPagina³Autor ³Denis Hyroshi de Souza ³ Data ³ 01/04/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para imprimir cabeçalho do relatorio                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fInicPagina()

oPrint:StartPage() //Iniciar Pagina
oPrint:Box(150,100,330,2300)
cLogo := cStartPath+"LGRL"+SM0->M0_CODIGO+SM0->M0_CODFIL+".BMP" //Empresa+Filial
If File(cLogo)
	oPrint:SayBitMap(160,110,cLogo,290,150)
Else
	cLogo := cStartPath+"LGRL"+SM0->M0_CODIGO+".BMP" //Empresa
	If File(cLogo)
		oPrint:SayBitMap(160,110,cLogo,290,150)
	Endif
Endif

nColInic := 530
nTamTit  := Int(Len(cDESQUEST)/2)
nTamTit  := If(nTamTit>20,20,nTamTit)
nTamTit  := If(nTamTit==0,1,nTamTit)
nColInic := 530 + ( ( 20 - nTamTit ) * 38 )
If Len(cDESQUEST) > 36
	oPrint:Say(210,540,Substr(cDESQUEST,1,40),oFont15b) //Nome Questionario
Else
	oPrint:Say(210,nColInic,Substr(cDESQUEST,1,40),oFont16b) //Nome Questionario
Endif

nPag411++
oPrint:Say(170,2040,STR0053 + cValToChar(nPag411),oFont07) //"Pág.: "
oPrint:Say(210,2040,STR0054 + cValToChar(dDataBase),oFont07) //"Data: "
oPrint:Say(250,2040,STR0055 + Time(),oFont07) //"Hora: "
lin := 330

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ R411Imp2 ³ Autor ³ Inacio Luiz Kolling   ³ Data ³   /06/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do Relat¢rio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTR411                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R411Imp2(lEnd,wnRel,titulo,tamanho)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cRodaTxt := ""
LOCAL nCntImpr := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis locais exclusivas deste programa                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cFICHA

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis tipo Private padrao de todos os relatorios         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Contadores de linha e pagina                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE li := 80 ,m_pag := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis locais exclusivas deste programa                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// PRIVATE

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se deve comprimir ou nao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTipo  := IIF(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os Cabecalhos                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*
************************************************************************************************************************************
*<empresa>                                                                                                        Folha..: xxxxx   *
*SIGA /<nome .04                                 <Relatorio de Questionario Medico>                               DT.Ref.: dd/mm/aa*
*Hora...: xx:xx:xx                                                                                                Emissao: dd/mm/aa*
************************************************************************************************************************************

             1         2         3         4         5         6         7         8         9         0         1         2         3
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Matricula  Nome Funcionario                           Sexo       Admissao   Idade
Perg. Descricao Pergunta                                         Resp. Dt.Resp.  Quantidade Complemento
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxx     xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xxxxxxxxx  99/99/99      99

xxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx xxx   99/99/99 999.999.999 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx xxx   99/99/99 999.999.999 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

Resumo do Questionario  ( NOME DO QUESTIONARO )
Total de Funcionarios pesquisados.: 999.999
Per.  Descricao Pergunta                                                  Sim        Nao  Sem Respos.
xxx   xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx    999.999    999.999     999.999
xxx   xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx    999.999    999.999     999.999


TAMANHO G
_____________________________________________________________________________________________________________________________________________________________________________________________________________________________
          1         2         3         4         5         6         7         8         9       100       110       120       130       140       150       160       170       180       190       200       210       220
01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
_____________________________________________________________________________________________________________________________________________________________________________________________________________________________
Matricula  Nome Funcionario                           Sexo       Admissao   Idade
Perg. Descricao Pergunta                                                                                                                                      Resp. Dt.Resp.  Quantidade Complemento
_____________________________________________________________________________________________________________________________________________________________________________________________________________________________
xxx   123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890  Sim   99/99/99 999.999.999 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


Per.  Descricao Pergunta                                                                                                                                                                Sim        Nao  Sem Respos.
xxx   12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890    999.999    999.999     999.999
*/

MontaRelat(.F.,.F.)

cabec1 := STR0007 //"Matricula  Nome Funcionario                           Sexo       Admissao   Idade"
cabec2 := STR0008 //"Perg. Descricao Pergunta                                         Resp. Dt.Resp.  Quantidade Complemento"
If nSizeTMH > 60
	cabec2 := STR0025 //"Perg. Descricao Pergunta                                                                                                                                      Resp. Dt.Resp.  Quantidade Complemento"
Endif

dbSelectArea("TRB")
dbGOTOP()

If Eof()
	MsgInfo(STR0023)  //"Não há nada para imprimir no relatório."
	Use        
	dbSelectArea("TRB2")
	use	
	Return .F.
Else
	If lSigaMdtps
		Somalinha2()
		@Li,000 PSAY STR0024 + MV_PAR01 +"-"+ MV_PAR02 +" - "+ NGSEEK("SA1",mv_par01+mv_par02,1,"SA1->A1_NOME")  //"Cliente/Loja: "
		Somalinha2()
	Endif
Endif

nTOTFUNC := 0
While ! eof()

	cFICHA := TRB->ACIDEN

	nTOTFUNC := nTOTFUNC + 1

	Somalinha2()


	dbSelectArea("TNC")
	dbSetOrder(01)
	dbSeek(xFilial("TNC")+cFICHA)

	@Li,011 PSAY substr(TNC->TNC_DESACI,1,40)

	@Li,065 PSAY TNC->TNC_DTACID  PICTURE '99/99/99'
	@Li,079 PSAY TNC->TNC_HRACID  PICTURE '99:99'
	Somalinha2()

	dbSelectArea("TRB")

	While ! eof() .and. TRB->ACIDEN == cFICHA

		SomaLinha2()
		@ Li,000 PSAY TRB->PERGUNTA  PICTURE "@!"
		If nSizeTMH <= 60
			@ Li,004 PSAY Substr(TRB->NOMPERGU,1,60)
			If TRB->RESPOS = '1'
				@ Li,065 PSAY STR0012 //'Sim'
			Else
				@ Li,065 PSAY STR0013 //'Nao'
			Endif
			@ Li,071 PSAY TRB->DTREAL    PICTURE '99/99/99'
			@ Li,082 PSAY TRB->QUANTID   PICTURE '@E 999,999.99'
			@ LI,094 PSAY Substr(TRB->COMPLEM,1,30)
		Else
			@ Li,006 PSAY Substr(TRB->NOMPERGU,1,150)
			If TRB->RESPOS = '1'
				@ Li,158 PSAY STR0012 //'Sim'
			Else
				@ Li,158 PSAY STR0013 //'Nao'
			Endif
			@ Li,164 PSAY TRB->DTREAL    PICTURE '99/99/99'
			@ Li,173 PSAY TRB->QUANTID   PICTURE '@E 999,999.99'
			@ LI,185 PSAY Substr(TRB->COMPLEM,1,30)
		Endif

		dbSelectArea("TRB")
		dbskip()
	Enddo

	SomaLinha2()

Enddo
 
If nTOTFUNC > 0
	SomaLinha2()
	@ LI,000 PSAY Replicate("-",132)
	SomaLinha2()
	If lSigaMdtps
		@ LI,000 PSAY STR0014 + cDESQUEST + " ("+DTOC(MV_PAR06)+" a "+DTOC(MV_PAR07)+")" //"Resumo do Questionario - "	
	Else
		@ LI,000 PSAY STR0014 + cDESQUEST + " ("+DTOC(MV_PAR04)+" a "+DTOC(MV_PAR05)+")" //"Resumo do Questionario - "
	Endif
	SomaLinha2()              
	@ LI,000 PSAY STR0015 //"Total de Funcionarios ou Candidatos Pesquisados.:"
	@ LI,050 PSAY nTOTFUNC PICTURE '@E 999,999'
	SomaLinha2()
	If nSizeTMH <= 60
		@ LI,000 PSAY STR0016 //"Per.  Descricao Pergunta                                                  Sim        Nao  Sem Respos."
	Else
		@ LI,000 PSAY STR0026 //"Per.  Descricao Pergunta                                                                                                                                                                Sim        Nao  Sem Respos."
	Endif

	SomaLinha2()
	dbSelectArea("TRB2")
	dbGOTOP()

	While ! eof()
		SomaLinha2()
		@ Li,000 PSAY TRB2->PERGUNTA                           PICTURE "@!"
		If nSizeTMH <= 60
			@ Li,006 PSAY Substr(TRB2->NOMPERGU,1,57)
			@ Li,070 PSAY TRB2->RESPSIM                            PICTURE '@E 999,999'
			@ Li,081 PSAY TRB2->RESPNAO                            PICTURE '@E 999,999'
			nTot := nTOTFUNC-(TRB2->RESPSIM + TRB2->RESPNAO) 
			If nTot < 0 
				nTot := 0
			EndIf   
			@ Li,093 PSAY nTOT PICTURE '@E 999,999'
		Else
			@ Li,006 PSAY Substr(TRB2->NOMPERGU,1,170)
			@ Li,180 PSAY TRB2->RESPSIM                            PICTURE '@E 999,999'
			@ Li,191 PSAY TRB2->RESPNAO                            PICTURE '@E 999,999'
			nTot := nTOTFUNC-(TRB2->RESPSIM + TRB2->RESPNAO) 
			If nTot < 0 
				nTot := 0
			EndIf   
			@ Li,203 PSAY nTOT PICTURE '@E 999,999'
		Endif

		dbSelectArea("TRB2")
		dbskip()
	Enddo

Endif

// EJECT

Roda(nCntImpr,cRodaTxt,Tamanho)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve a condicao original do arquivo principal             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RetIndex("TM1")
Set Filter To

Set device to Screen

If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif
//SET CENTURY ON
MS_FLUSH()

dbSelectArea("TRB")
use
dbSelectArea("TRB2")
use
dbSelectArea("TO6")
dbSetOrder(01)

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
Static Function Somalinha2(nSaltoGrf)

If Valtype(nSaltoGrf) == "N"
	lin += nSaltoGrf

	If lin > 3000
		oPrint:Line(lin,200,lin,2300)
		lin := 150
		oPrint:EndPage() //Fechar Pagina
		fInicPagina() //Iniciar Pagina
		//oPrint:Line(lin,200,lin,2300)
	Endif
Else
	Li++
	If Li > 58
		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	EndIf   
EndIf
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ fImpMod4 ³ Autor ³ Jackson machado		  ³ Data ³02/03/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Montagem do Relatório 							                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function fImpMod4(a411Tipo)
Local nXYZ, nXX, LinhaCorrente, nYY
Local cAliasCC := "SI3"
Local cCodCC2  := "I3_CUSTO"
Local cDescCC2 := "SI3->I3_DESC"

Local cComboRes:= "TMH->TMH_RESPOS"
Local cTemp    := Alltrim(GetTempPath())
Local aImagens := {"ngradiono.png","ngradiook.png","ngcheckno.png","ngcheckok.png"}
Local cBarras  := If(isSrvUnix(),"/","\")
Local nIndTMH, cSeekTMH, cCondTMH
Local cQuesti := If(lSigaMdtps, mv_par03, mv_par01)
Local cSexo := ""

//Variável de controle de funcionário
Private lFunc := .F.

Private cStartPath := AllTrim(GetSrvProfString("Startpath",""))
Private cBarraSrv := "\"
Private cBarSrv2 := "\\"
Private cLogo
Private aCadTipo := {}

If Valtype(a411Tipo) == "A"
	aCadTipo := aClone(a411Tipo)
Endif

If Alltrim(GETMV("MV_MCONTAB")) == "CTB"
	cAliasCC := "CTT"
	cCodCC2  := "CTT_CUSTO"
	cDescCC2 := "CTT->CTT_DESC01"
Endif

If isSRVunix()  //servidor eh da familia Unix (linux, solaris, free-bsd, hp-ux, etc.)
	cBarraSrv := "/"
	cBarSrv2 := "//"
Endif

If Substr(cStartPath,Len(cStartPath),1) <> cBarraSrv
	cStartPath := cStartPath+cBarraSrv
Endif
                    
Private nOrdTO6 := NGRETORDEM("TO6","TO6_FILIAL+TO6_ACIDEN+TO6_QUESTI+DTOS(TO6_DTREAL)+TO6_QUESTA+TO6_RESPOS",.F.)
Private lin := 9999
Private nPag411 := 0
Private oPrint
Private oFont07  := TFont():New("Courier New",07,07,,.F.,,,,.F.,.F.)
Private oFont08  := TFont():New("Courier New",08,08,,.F.,,,,.F.,.F.)
Private oFont10b := TFont():New("Courier New",09,09,,.T.,,,,.F.,.F.)
Private oFont10  := TFont():New("Courier New",09,09,,.F.,,,,.F.,.F.)
Private oFont10n := TFont():New("Tahoma",10,10,,.T.,,,,.F.,.F.)
Private oFont13  := TFont():New("Tahoma",13,13,,.T.,,,,.F.,.F.)
Private oFont15b := TFont():New("Courier New",15,15,,.T.,,,,.F.,.F.)
Private oFont16b := TFont():New("Courrier New",16,16,,.T.,,,,.F.,.F.)
Private aCboxSV  := {}
Private aTNCCombo := PPPMDTCbox("TNC_INDACI"," ",1)
Private cIndic := " "
Private nIND

cTemp := cTemp + If(Right(cTemp,1)==cBarras,"",cBarras)
//Cria Pasta Temp
If !ExistDir(cTemp)
	MakeDir(cTemp)
EndIf
For nYY := 1 to Len(aImagens)
	//Exclui imagem se ela ja existir no diretorio
	FErase(cTemp+aImagens[nYY])

	//Exporta imagens do RPO para a pasta especificada
	Resource2File(aImagens[nYY],cTemp+aImagens[nYY])
Next nX

oPrint := TMSPrinter():New(OemToAnsi(STR0006)) //"Questionario Medico"
oPrint:SetPortRait()
oPrint:Setup()

MontaRelat(.T.,.T.,Len(aCadTipo))

dbSelectArea("TRB")
dbGoTop()
lTemDados := .t.
If Eof()
	lTemDados := .f.
Endif
While !Eof()

	cFICHA := TRB->ACIDEN
	dDTSAV := TRB->DTREAL
	nPag411 := 0
	fInicPagina()

	oPrint:Line(330,100,870,100)
	oPrint:Line(330,2300,870,2300)
	oPrint:Line(390,100,390,2300)
   dbSelectArea("TNC")
   dbSetOrder(1)
   dbSeek(xFilial("TNC")+TRB->ACIDEN)
   
   
   dbSelectArea("TM0")
   dbSetOrder(1)
   dbSeek(xFilial("TM0")+TNC->TNC_NUMFIC)
   
   dbSelectArea("SRA")
   dbSetOrder(1)
	If dbSeek(xFilial("SRA")+TM0->TM0_MAT)
   	lFunc := .T.
   Endif 
   
	oPrint:Say(340,120,"1. "+STR0027,oFont10b) //"IDENTIFICAÇÃO"
	oPrint:Say(400,120,STR0046+":",oFont10b) //"Descrição do acidente"
	oPrint:Say(400,610,TNC->TNC_DESACI,oFont10)
	oPrint:Say(450,120,STR0033+":",oFont10b) //"Data do Questionário"
	oPrint:Say(450,610,DtoC(TRB->DTREAL),oFont10)
	oPrint:Say(500,120,STR0045+":",oFont10b) //"Código do acidente"
	oPrint:Say(500,610,TNC->TNC_ACIDEN,oFont10)
	oPrint:Say(550,120,STR0040+":",oFont10b) //"Indicador do acidente"
	
	cIndic := " "
	
	If Len(aTNCCombo) == 0
		Do Case
			Case TNC_INDACI == "1" ; cIndic := STR0041
			Case TNC_INDACI == "2" ; cIndic := STR0042
			Case TNC_INDACI == "3" ; cIndic := STR0043
			Case TNC_INDACI == "4" ; cIndic := STR0044
		End Case
	Else
		If (nIND := aScan(aTNCCombo,{|x| Upper(Substr(x,1,1)) == Substr(TNC->TNC_INDACI,1,1)})) > 0
			cIndic := Upper(Substr(aTNCCombo[nIND],3))
		Endif
	Endif
	
	oPrint:Say(550,610,cIndic,oFont10)
	oPrint:Say(600,120,STR0034+":",oFont10b) //"Data do Acidente"
	oPrint:Say(600,610,DtoC(TNC->TNC_DTACID),oFont10)
	oPrint:Say(650,120,STR0039+":",oFont10b) //"Hora do Questionário"
	oPrint:Say(650,610,TNC->TNC_HRACID,oFont10)
	oPrint:Say(700,120,STR0035+":",oFont10b) //"Tipo"
	dbSelectArea("TNG")
	dbSetOrder(1)
	dbSeek(xFilial("TNG")+TNC->TNC_TIPACI)
	oPrint:Say(700,610,SubStr(TNG->TNG_DESTIP,1,35),oFont10)
	oPrint:Say(750,120,STR0036+":",oFont10b) //"Local"
	oPrint:Say(750,610,SubStr(TNC->TNC_LOCAL,1,15),oFont10)
	oPrint:Say(800,120,STR0037+":",oFont10b) //"Parte do Corpo Atigida"
	dbSelectArea("TOI")
	dbSetOrder(1)
	dbSeek(xFilial("TOI")+TNC->TNC_CODPAR)
	oPrint:Say(800,610,TOI->TOI_DESPAR,oFont10)
   
	oPrint:Say(450,1380,STR0030+":",oFont10b) //"Ficha Médica"
	oPrint:Say(450,1830,TM0->TM0_NUMFIC,oFont10) 
	oPrint:Say(500,1380,STR0070+":",oFont10b)//"Matrícula"
	oPrint:Say(500,1830,SRA->RA_MAT,oFont10)
	oPrint:Say(550,1380,STR0028+":",oFont10b) //"Nome do Acidentado"
	If lFunc
		oPrint:Say(550,1830,SubStr(SRA->RA_NOME,1,20),oFont10)
	Else
		oPrint:Say(550,1830,SubStr(TM0->TM0_NOMFIC,1,20),oFont10)	
	Endif
	oPrint:Say(600,1380,STR0038+":",oFont10b) //"Data de Nascimento"
	If lFunc
  		oPrint:Say(600,1830,DtoC(SRA->RA_NASC),oFont10)
 	Else
 		oPrint:Say(600,1830,DtoC(TM0->TM0_DTNASC),oFont10)
 	Endif
	oPrint:Say(650,1380,STR0032+":",oFont10b) //"Sexo"
	If lFunc
		If(SRA->RA_SEXO=="F")
			oPrint:Say(650,1830,STR0011,oFont10)
		ElseIf(SRA->RA_SEXO=="M")
			oPrint:Say(650,1830,STR0010,oFont10)
		Endif
	Else
		If(TM0->TM0_SEXO=="2")
			oPrint:Say(650,1830,STR0011,oFont10)
		ElseIf(TM0->TM0_SEXO=="1")
			oPrint:Say(650,1830,STR0010,oFont10)
		Endif
	Endif
	oPrint:Say(700,1380,STR0031+":",oFont10b) //"Identidade"
	If lFunc
		oPrint:Say(700,1830,SRA->RA_RG,oFont10)
	Else
		oPrint:Say(700,1830,TM0->TM0_RG,oFont10)
	Endif
	oPrint:Say(750,1380,STR0029+":",oFont10b) //"Função"
	dbSelectArea("SRJ")
	dbSetOrder(1)
	If lFunc
		dbSeek(xFilial("SRJ")+SRA->RA_CODFUNC)
	Else
		dbSeek(xFilial("SRJ")+TM0->TM0_CODFUN)
	Endif
	oPrint:Say(750,1830,SubStr(SRJ->RJ_DESC,1,20),oFont10)
	
	nContGrp := 1
	lin := 800
	lPrimQuest := .t.

	If lSigaMdtps
		If ( nIndTMH := NGRETORDEM("TMH","TMH_FILIAL+TMH_CLIENT+TMH_LOJA+TMH_QUESTI+TMH_QUESTA",.T.) ) == 0
			nIndTMH := 1
		EndIf
		cSeekTMH:= mv_par01+mv_par02+cQuesti
		cCondTMH:= "TMH->(TMH_FILIAL+TMH_CLIENT+TMH_LOJA+TMH_QUESTI)"
	Else
		nIndTMH := 1
		cSeekTMH:= cQuesti
		cCondTMH:= "TMH->(TMH_FILIAL+TMH_QUESTI)"
	Endif

	If Len(aCadTipo) == 0
		dbSelectArea("TMH")
		dbSetOrder(nIndTMH)
		dbSeek(xFilial("TMH")+cSeekTMH)
		While !Eof() .and. xFilial("TMH")+cSeekTMH == &(cCondTMH)
			
			If lSigaMdtps
				cCliMdtPs := TMH->(TMH_CLIENT+TMH_LOJA)
			EndIf
			
			//Verifica se usuario precisa responder a pergunta
			aTipoTMH := {}
			If !Empty( &cComboRes )
				aTipoTMH := fRetCombo(Alltrim( &cComboRes ))
			Endif
			aTemp    := Array(Len(aTipoTMH),3)
			For nXX := 1 To Len(aTemp)
				If (TMH->TMH_TPLIST=="1")
					aTemp[nXX,1] := 0
				Else
					aTemp[nXX,1] := .F.
				Endif
				
				dbSelectArea("TO6")
				If lSigaMdtPs
					nOrdTO6 := NGRETORDEM("TO6","TO6_FILIAL+TO6_CLIENT+TO6_LOJA+TO6_ACIDEN+TO6_QUESTI+DTOS(TO6_DTREAL)+TO6_QUESTA+TO6_RESPOS",.F.)
					dbSetOrder(nOrdTO6)
					If dbSeek( xFilial("TO6") + cCliMdtPs + TRB->ACIDEN +cQuesti+DTOS(TRB->DTREAL)+TMH->TMH_QUESTA+SubStr(aTipoTMH[nXX],1,1) )
						If (TMH->TMH_TPLIST=="1")
							aTemp[nXX,1] := 1
						Else
							aTemp[nXX,1] := .T.
						Endif
					Endif
				Else
					dbSetOrder(nOrdTO6)
					If dbSeek( xFilial("TO6") + TRB->ACIDEN +cQuesti+DTOS(TRB->DTREAL)+TMH->TMH_QUESTA+SubStr(aTipoTMH[nXX],1,1) )
						If (TMH->TMH_TPLIST=="1")
							aTemp[nXX,1] := 1
						Else
							aTemp[nXX,1] := .T.
						Endif
					Endif
				Endif
			Next nXX
		
			//Se não for inclusão
			cMemoM6 := ""
			dbSelectArea("TO6")
			dbSetOrder(nOrdTO6)
			If dbSeek( xFilial("TO6") + TRB->ACIDEN+cQuesti+DTOS(TRB->DTREAL)+TMH->TMH_QUESTA+"#" )
				cMemoM6 := Alltrim(TO6->TO6_DESCRI)
			Endif

		  	dbSelectArea("TNC")
			dbSetOrder(1)
			If dbSeek(xFilial("TNC")+TRB->ACIDEN)
				cFichaMed := TNC->TNC_NUMFIC
			   dbSelectArea("TM0")
			   dbSetOrder(1)
			   If dbSeek(xFilial("TM0")+cFichaMed)
			   	cSexo := TM0->TM0_SEXO
				EndIf
			EndIf
			
			If !Empty(cSexo)
				If cSexo <>  TMH->TMH_INDSEXO .And. TMH->TMH_INDSEXO <> "3"
					dbSelectArea("TMH") 
	  				dbSkip()
					Loop
				EndIf
			EndIf	
		  
			//1 - Codigo Questão
			//2 - Descrição Questão
			//3 - Grupo
			//4 - Array de Opções
			//5 - Cbox
			//6 - Indica se é RADIO (.T.) ou CHECK (.F.)
			//7 - Indica se tem campo Memo
			//8 - Array (respostas,objeto)
			//9 - Ordem
			//10- Campo Memo

			//ATENCAO: A CONFIGURACAO DA VARIAVEL aCadTipo DEVE SER A MESMA DEFINIDA NO PROGRAMA MDTA690.PRX
			aADD( aCadTipo , { TMH->TMH_QUESTA , Left( Upper( TMH->TMH_PERGUN ) , 1 ) + SubStr( Lower( TMH->TMH_PERGUN ) , 2 )  , TMH->TMH_CODGRU , aTipoTMH ,;
							   &cComboRes , (TMH->TMH_TPLIST=="1") ,;
							   (TMH->TMH_ONMEMO=="1") , aTemp , TMH->TMH_ORDEM , cMemoM6 } )
			dbSelectArea("TMH")
			dbSkip()
		End
	Endif
	
	aSort( aCadTipo ,,, { |x,y| x[9] < y[9] } )
	If Empty(aCadTipo)
		MsgStop(STR0069) //"Não existe nenhuma pergunta para o sexo da ficha médica."
		dbSelectArea("TRB")
		Use
		dbSelectArea("TRB2")
		Use
		Return .F.
	EndIf
	cOldGrupo := "#"
	For nYY := 1 to Len(aCadTipo)
		If cOldGrupo <> aCadTipo[nYY,3]
			cOldGrupo := aCadTipo[nYY,3]
			cDesGrupo := " "
			dbSelectArea("TK0")
			dbSetOrder(01)
			If dbSeek( xFilial("TK0") + cOldGrupo )
				If !Empty(TK0->TK0_DESCRI)
					cDesGrupo := Capital( Alltrim(TK0->TK0_DESCRI) )
				Endif
			Endif

			//Titulo do Grupo                                				
			nContGrp++
			Somalinha2(70)
			oPrint:Box(lin,100,lin+100,2300)
			oPrint:Say(lin+20,120,Alltrim(Str(nContGrp,10))+". "+Upper(cDesGrupo),oFont10b)
			Somalinha2(70)
		Endif
	
		//Titulo Questão                                
		Somalinha2(50)
		oPrint:Say( lin,125, aCadTipo[ nYY, 2 ], oFont10n )
		oPrint:Line(lin-30,100,lin+50,100)
		oPrint:Line(lin-30,2300,lin+50,2300)

		//Montando lista de opcoes (radio ou check)
		nLimCol := 120
		nAcumLi := 0
		For nXX := 1 To Len(aCadTipo[nYY,4])
			cStrXX := Alltrim( Str(nXX) )
			cDescBox := SubStr(aCadTipo[nYY,4,nXX],3)
			If (nAcumLi + Len(cDescBox) + 5) > nLimCol .or. nXX == 1
				If nXX == 1
			 		Somalinha2(50)
			 	Else
				 	Somalinha2(40)
			 	Endif
		   	nAcumLi := 0
				oPrint:Line(lin-30,100,lin+40,100)
				oPrint:Line(lin-30,2300,lin+40,2300)
			Endif
						
			If aCadTipo[nYY,6]
				If aCadTipo[nYY,8,nXX,1] == 0
					If File(cTemp+"ngradiono.png")
						oPrint:SayBitmap(Lin+5,120+(nAcumLi*18),cTemp+"ngradiono.png",30,32)
					Endif
				Else
					If File(cTemp+"ngradiook.png")
						oPrint:SayBitmap(Lin+5,120+(nAcumLi*18),cTemp+"ngradiook.png",30,32)
					Endif
				Endif
			Else
				If !aCadTipo[nYY,8,nXX,1]
					If File(cTemp+"ngcheckno.png")
						oPrint:SayBitmap(Lin+5,120+(nAcumLi*18),cTemp+"ngcheckno.png",30,32)
					Endif
				Else
					If File(cTemp+"ngcheckok.png")
						oPrint:SayBitmap(Lin+5,120+(nAcumLi*18),cTemp+"ngcheckok.png",30,32)
					Endif
				Endif
			Endif
			oPrint:Say(lin,120+(nAcumLi*18)+40,cDescBox,oFont10)
	    	nAcumLi += Len(cDescBox) + 6	    		
		Next nXX
	
		If aCadTipo[nYY,7]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Campo Memo                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nLinhasMemo := MLCOUNT(aCadTipo[nYY,10],97)
			nLinhasMemo := If(nLinhasMemo<2,2,nLinhasMemo)
			nCont := 30
			For LinhaCorrente := 1 To nLinhasMemo
				If LinhaCorrente == 1
					If Lin+85 > 3000
						Lin := 7777
					Endif
					Somalinha2(50)
					oPrint:Line(lin-30,100,lin+40,100)
					oPrint:Line(lin-30,2300,lin+40,2300)
					oPrint:Line(lin,200,lin+50,200)
					oPrint:Line(lin,2200,lin+50,2200)
					oPrint:Line(lin,200,lin,2200)
				Else
					Somalinha2(45,.T.,.T.)
					oPrint:Line(lin,2200,lin+45,2200)
					oPrint:Line(lin,200,lin+45,200)					
				Endif
				oPrint:Say(lin+3,215,MemoLine(aCadTipo[nYY,10],97,LinhaCorrente),oFont10)
				nCont += 50
				If LinhaCorrente == nLinhasMemo
					oPrint:Line(lin+45,200,lin+45,2200)
					oPrint:Line(lin-nCont,100,lin+40,100)
					oPrint:Line(lin-nCont,2300,lin+40,2300)
				Endif
			Next LinhaCorrente
		Endif
	
		If nYY != Len(aCadTipo)
			Somalinha2(10)
		Endif
		oPrint:Line(lin-30,100,lin+100,100)
		oPrint:Line(lin-30,2300,lin+100,2300)
		If lin+540 > 3000
			oPrint:Line(lin+100,100,lin+100,2300)
			lin := 9999
		Endif
	Next nYY 
	aCadTipo := {}
	
	If lin+540 > 3000
		lin := 9999
	Endif
	Somalinha2(90)
	oPrint:Line(lin,100,lin+380,100)
	oPrint:Line(lin+60,1150,lin+380,1150)
	oPrint:Line(lin,2300,lin+380,2300)

	oPrint:Line(lin+60,100,lin+60,2300)
	oPrint:Line(lin+120,100,lin+120,2300)
	oPrint:Line(lin+220,100,lin+220,2300)
	oPrint:Line(lin+280,100,lin+280,2300)
	oPrint:Line(lin+380,100,lin+380,2300)
	/*	oPrint:Line(lin+440,100,lin+440,2300)
	oPrint:Line(lin+540,100,lin+540,2300)*/

	nContGrp++ 
	oPrint:Line(lin,100,lin,2300)
	oPrint:Say(lin+10,120,Alltrim(Str(nContGrp,10))+". "+ STR0048,oFont10b) //"REGISTRO DE LEGITIMIDADE E VERACIDADE DAS INFORMAÇÕES"

	oPrint:Say(lin+70,550,STR0051,oFont10,,,,0) //"DATA"
	oPrint:Line(lin+210,350,lin+210,780)
	oPrint:Line(lin+210,477,lin+155,487)
	oPrint:Line(lin+210,622,lin+155,632)
	oPrint:Say(lin+70,1375,STR0050,oFont10,,,,0) //"ASSINATURA DO COLABORADOR ACIDENTADO"
	oPrint:Line(lin+210,1300,lin+210,2250)
	
	oPrint:Say(lin+230,400,STR0049,oFont10,,,,0) //"DATA DO PREENCHIMENTO"
	oPrint:Line(lin+370,350,lin+370,780)
	oPrint:Line(lin+370,477,lin+315,487)
	oPrint:Line(lin+370,622,lin+315,632)
	oPrint:Say(lin+230,1475,STR0052,oFont10,,,,0) //"ASSINATURA DO RESPONSÁVEL"
	oPrint:Line(lin+370,1300,lin+370,2250)

	oPrint:EndPage() //Fechar Pagina
	dbSelectArea("TRB")
	dbSkip()
End

If !lTemDados
	MsgInfo(STR0023)  //"Não há nada para imprimir no relatório."
Else
	If lPrintTel
		oPrint:Preview()
	Else
		oPrint:Print()
	EndIf
Endif

dbSelectArea("TRB")
Use
dbSelectArea("TRB2")
Use

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³LoadArTmp ³ Autor ³ Denis                 ³ Data ³ 20/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Carrega arquivo temporario                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function MontaRelat(lCombTK0,lRelGraf,nImp145)

Local nLenCompl := (TAMSX3("TO6_COMRES")[1])
Local cComboRes:= "TMH->TMH_RESPOS"
Local oTempTable

Default nImp145 := 0
If nLenCompl < 30
	nLenCompl := 30
Endif

aDBF := {}
AADD(aDBF,{ "ACIDEN"  , "C" ,06, 0 })
AADD(aDBF,{ "PERGUNTA"  , "C" ,03, 0 })
AADD(aDBF,{ "NOMPERGU"  , "C" ,nSizeTMH, 0 })
AADD(aDBF,{ "RESPOS"    , "C" ,01, 0 })
AADD(aDBF,{ "DTREAL"    , "D" ,10, 0 })
AADD(aDBF,{ "QUANTID"   , "N" ,09, 2 })
AADD(aDBF,{ "COMPLEM"   , "C" ,nLenCompl, 0 })
AADD(aDBF,{ "CODGRUPO"  , "C" ,03, 0 })
AADD(aDBF,{ "XCOMBO"   , "C" ,250, 0 })

oTempTable := FWTemporaryTable():New( "TRB", aDBF )
oTempTable:AddIndex( "1", {"ACIDEN","DTREAL","CODGRUPO","PERGUNTA"} )
oTempTable:Create()

aDBF2 := {}
AADD(aDBF2,{ "PERGUNTA" , "C" ,03, 0 })
AADD(aDBF2,{ "NOMPERGU" , "C" ,nSizeTMH, 0 })
AADD(aDBF2,{ "RESPSIM"  , "N" ,06, 0 })                                  
AADD(aDBF2,{ "RESPNAO"  , "N" ,06, 0 })

oTempTable := FWTemporaryTable():New( "TRB2", aDBF2 )
oTempTable:AddIndex( "1", {"PERGUNTA"} )
oTempTable:Create()

If nImp145 > 0
	dbSelectArea("TRB")
	If lSigaMdtps
		If !dbSeek(MV_PAR04+DTOS(MV_PAR06))
			TRB->(DbAppend())
			TRB->ACIDEN   := MV_PAR04
			TRB->DTREAL     := MV_PAR06
		EndIf
	Else
		If !dbSeek(MV_PAR02+DTOS(MV_PAR04))
			TRB->(DbAppend())
			TRB->ACIDEN     := MV_PAR02
			TRB->DTREAL     := MV_PAR04
		EndIf
	Endif
ElseIf lSigaMdtps

	dbSelectArea("TO6")
	dbSetOrder(04)  //TO6_FILIAL+TO6_CLIENT+TO6_LOJA+TO6_QUESTI
	dbSeek(xFilial("TO6")+MV_PAR01+MV_PAR02+MV_PAR03)

	If lRelGraf
		ProcRegua(LastRec())
	Else
		SetRegua(LastRec())
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Correr TO6 para ler as  Questoes                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	While !Eof()                                   .AND.;
	      TO6->TO6_FILIAL == xFilial('TO6')        .AND.;
	      TO6->(TO6_CLIENT+TO6_LOJA) == MV_PAR01+MV_PAR02 .AND.;
	      TO6->TO6_QUESTI == MV_PAR03
	      	      
		If lRelGraf
			IncProc()
		Else
			IncRegua()
		Endif

		If TO6->TO6_ACIDEN < mv_par04 .or. TO6->TO6_ACIDEN > mv_par05
			dbSelectArea("TO6")
			dbSkip()
			Loop		
		Endif
		
		dbSelectArea("TNC")
		dbSetOrder(1)
		If !dbSeek(xFilial("TNC")+TO6->TO6_ACIDEN)
			dbSelectArea("TO6")
			dbSkip()
			loop
		Endif
			
	
		If TO6->TO6_DTREAL < MV_PAR06 .OR. TO6->TO6_DTREAL > MV_PAR07
			dbSelectArea("TO6")
			dbSkip()
			loop
		Endif
	
		dbSelectArea("TMH")
		dbSetOrder(02)  //TMH_FILIAL+TMH_CLIENT+TMH_LOJA+TMH_QUESTI+TMH_QUESTA
		If !dbSeek(xFilial("TMH")+mv_par01+mv_par02+TO6->TO6_QUESTI+TO6->TO6_QUESTA)
			dbSelectArea("TO6")
			dbSkip()
			loop
		Endif
	
		dbSelectArea("TRB")
		If !dbSeek(TO6->TO6_ACIDEN+DTOS(TO6->TO6_DTREAL))
			TRB->(DbAppend())
		
			TRB->ACIDEN   := TO6->TO6_ACIDEN
			TRB->PERGUNTA   := TO6->TO6_QUESTA
			TRB->NOMPERGU   := TMH->TMH_PERGUN
			TRB->RESPOS     := TO6->TO6_RESPOS
			TRB->DTREAL     := TO6->TO6_DTREAL
			TRB->QUANTID    := TO6->TO6_QTRESP
			TRB->COMPLEM    := TO6->TO6_COMRES
			TRB->XCOMBO   := &cComboRes
			TRB->CODGRUPO := TMH->TMH_CODGRU
		EndIf	
		dbSelectArea("TRB2")
		If !dbSeek(TO6->TO6_QUESTA)
			TRB2->(DbAppend())
			TRB2->PERGUNTA := TO6->TO6_QUESTA
			TRB2->NOMPERGU := TMH->TMH_PERGUN
		Endif
	
		If TO6->TO6_RESPOS = '1'
			TRB2->RESPSIM := TRB2->RESPSIM + 1
		Else
			TRB2->RESPNAO := TRB2->RESPNAO + 1
		Endif
	
		dbSelectArea("TO6")
		dbSKIP()	
	End
Else
	dbSelectArea("TO6")
	dbSetOrder(02)
	dbSeek(xFilial("TO6")+MV_PAR01,.T.)

	If lRelGraf
		ProcRegua(LastRec())
	Else
		SetRegua(LastRec())
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Correr TO6 para ler as  Questoes                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	While !Eof()                                   .AND.;
	      TO6->TO6_FILIAL == xFIlial('TO6')        .AND.;
	      TO6->TO6_QUESTI == MV_PAR01 

		If lRelGraf
			IncProc()
		Else
			IncRegua()
		Endif
		
			
		If TO6->TO6_DTREAL < MV_PAR04 .OR. TO6->TO6_DTREAL > MV_PAR05
			dbSelectArea("TO6")
			dbSkip()
			loop
		Endif
	
		dbSelectArea("TNC")
		dbSetOrder(01)
		If dbSeek(xFilial("TNC")+TO6->TO6_ACIDEN)
			If TNC->TNC_ACIDEN < MV_PAR02 .OR. TNC->TNC_ACIDEN > MV_PAR03
				dbSelectArea("TO6")
				dbSkip()
				loop
			Endif
		Else
			dbSelectArea("TO6")
			dbSkip()
			loop
		Endif
	
		dbSelectArea("TMH")
		dbSetOrder(01)
		If !dbSeek(xFilial("TMH")+TO6->TO6_QUESTI+TO6->TO6_QUESTA)
			dbSelectArea("TO6")
			dbSkip()                                                                            
			loop
		Endif
		
		dbSelectArea("TRB")
		If !dbSeek(TO6->TO6_ACIDEN+DTOS(TO6->TO6_DTREAL))
			TRB->(DbAppend())
		
			TRB->ACIDEN	    := TO6->TO6_ACIDEN
			TRB->PERGUNTA   := TO6->TO6_QUESTA
			TRB->NOMPERGU   := TMH->TMH_PERGUN
			TRB->RESPOS     := TO6->TO6_RESPOS
			TRB->DTREAL     := TO6->TO6_DTREAL
			TRB->QUANTID    := TO6->TO6_QTRESP
			TRB->COMPLEM    := TO6->TO6_COMRES
			TRB->XCOMBO   := &cComboRes
			TRB->CODGRUPO := TMH->TMH_CODGRU
		EndIf	
		dbSelectArea("TRB2")
		If !dbSeek(TO6->TO6_QUESTA)
			TRB2->(DbAppend())
			TRB2->PERGUNTA := TO6->TO6_QUESTA
			TRB2->NOMPERGU := TMH->TMH_PERGUN
		Endif
	
		If TO6->TO6_RESPOS = '1'
			TRB2->RESPSIM := TRB2->RESPSIM + 1
		Else
			TRB2->RESPNAO := TRB2->RESPNAO + 1
		Endif
	
		dbSelectArea("TO6")
		dbSKIP()	
	End
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³  fRetCombo³ Autor ³ Denis Hyroshi de Souza³ Data ³07/07/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a formula esta correta e faz a gravacao         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fRetCombo(cVar)
Local aArray1 := RetSx3Box(cVar,,,1)
Local nCont,aArray2 := {}

For nCont := 1 To Len(aArray1)
	If !Empty(aArray1[nCont][1])
		AADD(aArray2,Alltrim(aArray1[nCont][1]))
	Endif
Next nCont

Return aClone(aArray2)
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT411VLD
Valida parametros SX1

@return .T./.F. Retorno logico de acordo com a condicao de validacao

@sample
MDT411VLD( 1 )

@author Jackson Machado
@since 11/01/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDT411VLD(nValid)
Local lRet := .T.

If nValid == 1
	If !ExistCpo("SA1",mv_par01)
		lRet := .F.
	EndIf
ElseIf nValid == 2
	If !ExistCpo("SA1",mv_par01+mv_par02)
		lRet := .F.
	EndIf
EndIf

cCliMdtPs := mv_par01+mv_par02

Return lRet
