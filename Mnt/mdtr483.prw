#INCLUDE "MDTR483.ch"
#Include "Protheus.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR483
Imprime relatório de Exames por Função

@author Guilherme Freudenburg
@since 21/08/2014

@return Nil
/*/
//---------------------------------------------------------------------
Function MDTR483()

Local aNGBEGINPRM := NGBEGINPRM( )
//-----------------------------------
//  Define Variaveis
//-----------------------------------
Local cDesc1  := STR0001 //"Relatório que imprime os Exames por cada Função."
Local cString:= "SRJ"
Local wnrel   := "MDTR483"

Private nLastKey :=0
Private lSigaMdtPS := SuperGetMv("MV_MDTPS",.F.,"N") == "S"
Private nomeprog := "MDTR483"
Private tamanho  := "M"
Private titulo 	:= STR0002//"Exames por Função"
Private cPerg    := PADR("MDT483", 10)
Private cabec1, cabec2
Private aPerg:={}
Private aReturn  := {STR0027, 1,STR0028, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
//Variaveis do modo de Impressão Personalizado
Private oReport
Private oTempTRB
Private oSection0, oSection1
Private oCel0, oCel1
//Alias da TRB
Private cTRB:= GetNextAlias()

If FindFunction("MDTRESTRI") .AND. !MDTRESTRI(cPrograma)
	//-------------------------------------------------
	//  Devolve variaveis armazenadas
	//-------------------------------------------------
	NGRETURNPRM(aNGBEGINPRM)
	Return .F.
Endif

If FindFunction("TRepInUse") .And. TRepInUse()//Verifica se será o personalizado ou padrão
	//-- Interface de impressao
	oReport := ReportDef()
	oReport:SetPortrait()
	oReport:PrintDialog()
Else
	//---------------------------------------------------------------
	//  Verifica as perguntas selecionadas                          -
	//---------------------------------------------------------------
	pergunte(cPerg,.F.)

	wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,,,.F.,"")

	If nLastKey == 27
		Set Filter to
		//----------------------------------------------------
		//  Devolve variaveis armazenadas (NGRIGHTCLICK)     -
		//----------------------------------------------------
		NGRETURNPRM(aNGBEGINPRM)
		Return
	Endif
	SetDefault(aReturn,cString)
	If nLastKey == 27
		Set Filter to
		//----------------------------------------------------
		//  Devolve variaveis armazenadas (NGRIGHTCLICK)     -
		//----------------------------------------------------
		NGRETURNPRM(aNGBEGINPRM)
		Return
	Endif
	RptStatus({|lEnd| RImp483(@lEnd,wnRel,titulo,tamanho)},titulo)
EndIf

//---------------------------------------------------------------
//  Devolve variaveis armazenadas (NGRIGHTCLICK)                -
//---------------------------------------------------------------
NGRETURNPRM(aNGBEGINPRM)
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT483TRB
Função que realiza a montagem da TRB, que será usada na impressão,
e faz também o filtro das informações.

@author Guilhrme Freudenburg
@since 21/08/2014

@return Nil
/*/
//---------------------------------------------------------------------
Static Function MDT483TRB()

	//Variaveis de verificação de tamanho de campo
	Local nTa1 := If((TAMSX3("A1_COD")[1]) < 1,6,(TAMSX3("A1_COD")[1]))
	Local nTa1L := If((TAMSX3("A1_LOJA")[1]) < 1,2,(TAMSX3("A1_LOJA")[1]))
	Local nTalF := If((TAMSX3("RJ_FUNCAO")[1]) < 1,5,(TAMSX3("RJ_FUNCAO")[1]))
	Local nTalE := If((TAMSX3("TM4_EXAME")[1]) < 1,6,(TAMSX3("TM4_EXAME")[1]))

	Local cFuncao:=""
	Local aAreaSRJ

	aDBF := {}
	AADD(aDBF,{ "CODFUN"	, "C"	,  nTalF,  0 }) //"Função"
	AADD(aDBF,{ "DESFUN"	, "C"	,      30, 0 }) //Descrição
	AADD(aDBF,{ "CODEXA"	, "C"	,   nTalE, 0 }) //Exame
	AADD(aDBF,{ "DESEXA"	, "C"	,      30, 0 }) //Descrição
	AADD(aDBF,{ "FAIXA"	, "C"	,       2, 0 }) //Faixa
	AADD(aDBF,{ "TIPOEX"	, "C"	,      60, 0 }) //Tipo Exame

	If lSigaMdtPs
		AADD(aDBF,{ "CLIENT"	, "C"	,  nTa1, 0 }) //Cliente
		AADD(aDBF,{ "CLINOME", "C"	,    40, 0 }) //Nome Cliente
		AADD(aDBF,{ "LOJA"	, "C"	, nTa1L, 0 }) //Loja
	Endif

	//Cria TRB
	oTempTRB := FWTemporaryTable():New( cTRB, aDBF )
	If lSigaMdtPs
		oTempTRB:AddIndex( "1", {"CLIENT","LOJA","CODFUN","CODEXA"} )
	Else
		oTempTRB:AddIndex( "1", {"CODFUN","CODEXA"} )
	EndIf
	oTempTRB:Create()

	//----------------------------------
	// Preenche a TRB
	//----------------------------------
	If lSigaMdtPS
		//----------------------------------
		// Faz os filtros e preenche a TRB
		//----------------------------------
		dbSelectArea("SRJ")
		dbGoTop()
		While !Eof()
			If SRJ->RJ_FILIAL == xFilial( 'SRJ' )
				aAreaSRJ := GetArea()//Salva a area
				cFuncao:=SRJ->RJ_FUNCAO//Grava a função posicionadas
				dbSelectArea("TON")
				dbSetOrder(1)
				If dbSeek(xFilial("TON")+SRJ->RJ_FUNCAO) .And. (Mv_par09 == 1 .Or. Mv_par09 == 3)//Verifica se existe na TON
					While !Eof() .And. cFuncao == TON->TON_CODFUN
						If TON->TON_CODFUN >= mv_par05 .And.  TON->TON_CODFUN <= mv_par06 .And.;
						TON->TON_CLIENT >= mv_par01 .And. TON->TON_CLIENT <= mv_par03 .And.;
						TON->TON_LOJA >= mv_par02 .And. TON->TON_LOJA <= mv_par04 .And.;
						TON->TON_CODEXA >= mv_par07 .And. TON->TON_CODEXA <= mv_par08 .And. !Empty(TON->TON_CODFUN)// Verifica os parametros
							(cTRB)->(DbAppend())
							(cTRB)->CODFUN :=TON->TON_CODFUN
							(cTRB)->DESFUN :=NGSEEK("SRJ",TON->TON_CODFUN,1,"SRJ->RJ_DESC")
							(cTRB)->CODEXA :=TON->TON_CODEXA
							(cTRB)->DESEXA :=NGSEEK("TM4",TON->TON_CODEXA,1,"TM4->TM4_NOMEXA")
							(cTRB)->FAIXA  :=TON->TON_FAIXA
							(cTRB)->TIPOEX :=NGRETSX3BOX("TON_TIPOEX",TON->TON_TIPOEX)
							(cTRB)->CLIENT :=TON->TON_CLIENT
							(cTRB)->CLINOME:=NGSEEK("SA1",TON->TON_CLIENT ,1,"SA1->A1_NOME")
							(cTRB)->LOJA   :=TON->TON_LOJA
						Endif
						TON->(dbSkip())
					End
					RestArea(aAreaSRJ) //Volta a Area gravada
				Else
					If !dbSeek(xFilial("TON")+SRJ->RJ_FUNCAO) .And. SRJ->RJ_FUNCAO  >= mv_par05 .and.  SRJ->RJ_FUNCAO  <= mv_par06;
					.And. (Mv_par09 == 2 .Or. Mv_par09 == 3)//Verifica os parametros
						(cTRB)->(DbAppend())
						(cTRB)->CODFUN :=SRJ->RJ_FUNCAO
						(cTRB)->DESFUN :=SRJ->RJ_DESC
					Endif
					RestArea(aAreaSRJ)
				Endif
			EndIf
			SRJ->(dbSkip())
		End
	Else

		//----------------------------------
		// Faz os filtros e preenche a TRB
		//----------------------------------

		dbSelectArea( "SRJ" )
		dbGoTop()

		While !Eof()

			If SRJ->RJ_FILIAL == xFilial( 'SRJ' )

				aAreaSRJ := GetArea() // Salva a area
				cFuncao := SRJ->RJ_FUNCAO // Grava a função posicionadas

				dbSelectArea( "TON" )
				dbSetOrder( 1 )

				If dbSeek( xFilial( "TON" ) + SRJ->RJ_FUNCAO ) .And. ( Mv_par05 == 1 .Or. Mv_par05 == 3 ) // Verifica se existe na TON

					While !Eof() .And. cFuncao == TON->TON_CODFUN

						If TON->TON_CODFUN >= mv_par01 .And.  TON->TON_CODFUN <= mv_par02 .And. TON->TON_CODEXA >= mv_par03 .And. TON->TON_CODEXA <= mv_par04;
							.And. !Empty( TON->TON_CODFUN )

							( cTRB )->( DbAppend() )

							( cTRB )->CODFUN :=TON->TON_CODFUN
							( cTRB )->DESFUN :=NGSEEK( "SRJ", TON->TON_CODFUN, 1, "SRJ->RJ_DESC" )
							( cTRB )->CODEXA :=TON->TON_CODEXA
							( cTRB )->DESEXA :=NGSEEK( "TM4", TON->TON_CODEXA, 1, "TM4->TM4_NOMEXA" )
							( cTRB )->FAIXA  :=TON->TON_FAIXA
							( cTRB )->TIPOEX :=NGRETSX3BOX( "TON_TIPOEX", TON->TON_TIPOEX )

						EndIf

						TON->( dbSkip() )

					End

					RestArea( aAreaSRJ ) // Volta a Area gravada

				Else

					If !dbSeek( xFilial( "TON" ) + SRJ->RJ_FUNCAO ) .And. SRJ->RJ_FUNCAO  >= mv_par01 .and.  SRJ->RJ_FUNCAO  <= mv_par02;
						.And. ( Mv_par05 == 2 .Or. Mv_par05 == 3 )

						( cTRB )->( DbAppend() )

						( cTRB )->CODFUN := SRJ->RJ_FUNCAO
						( cTRB )->DESFUN := SRJ->RJ_DESC

					EndIf

					RestArea( aAreaSRJ )

				Endif

			EndIf

			SRJ->( dbSkip() )

		End

	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} RImp483
Faz a Impressão do relatório

@author Guilhrme Freudenburg
@since 21/08/2014

@return Nil
/*/
//---------------------------------------------------------------------
Static Function RImp483(lEnd,wnRel,titulo,tamanho)

Local cFuncao	:= ""//Controla as Funções impressas
Local cClient:= ""
Local cLoja:= ""
//----------------------------------------------------------------
//  Contadores de linha e pagina                                 -
//----------------------------------------------------------------
PRIVATE li := 80, m_pag := 1

If !lSigaMdtPs
	cabec1:= STR0033//"Função         Descrição"
Else
	cabec1:= STR0034//"Função         Descrição                        Cliente                         Loja"
Endif
cabec2:= STR0035 //"    Exame           Descrição                      Faixa    Tipo Exame"

//---------------------------------
// Chama função que monta a TRB
//---------------------------------
MDT483TRB()

dbSelectArea(cTRB)
dbGoTop()
Somalinha()
While (cTRB)->( !Eof() )
	If lSigaMDTPS
		If cFuncao <> (cTRB)->CODFUN .Or. cClient <> (cTRB)->CLIENT .Or. cLoja <> (cTRB)->LOJA
			cFuncao := (cTRB)->CODFUN
			cClient := (cTRB)->CLIENT
			cLoja:=(cTRB)->LOJA
			@ Li,001 PSay (cTRB)->CODFUN	// Código da função
			@ Li,015 Psay (cTRB)->DESFUN	//Descrição da função
			@ Li,048 Psay (cTRB)->CLIENT+" "+SubStr((cTRB)->CLINOME,1,20)//Cliente  "   "  Nome Cliente
			@ Li,080 Psay (cTRB)->LOJA 		//Loja
			Somalinha()
		EndIf
	Else
		If cFuncao <> (cTRB)->CODFUN
			cFuncao := (cTRB)->CODFUN
			@ Li,001 PSay (cTRB)->CODFUN	// Código da função
			@ Li,015 Psay (cTRB)->DESFUN	//Descrição da função
			Somalinha()
		EndIf
	EndIf

	If !Empty((cTRB)->CODEXA)
		@ Li,004 PSay (cTRB)->CODEXA //Código do Exame
		@ Li,020 PSay (cTRB)->DESEXA //Descrição do Exame
		@ Li,051 PSay (cTRB)->FAIXA //Feixa Periodica
		@ Li,060 PSay (cTRB)->TIPOEX  //Tipo do Exame
		Somalinha()
	EndIf
	(cTRB)->(dbSkip())
End

//----------------------------------------------------
//  Devolve a condicao original do arquivo principal
//----------------------------------------------------
dbSelectArea(cTRB)
dbGotop()
If RecCount()==0
	MsgInfo(STR0019)  //"Não há nada para imprimir no relatório."
	//Use
	oTempTRB:Delete()
	RetIndex("TON")
	Set Filter To
	MS_FLUSH()
	Return .F.
Endif

Dbselectarea(cTRB)
//use
oTempTRB:Delete()
RetIndex("TON")

Set Filter To

Set device to Screen

If aReturn[5] = 1
	Set Printer To
    dbCommitAll()
    OurSpool(wnrel)
Endif
//SET CENTURY ON
MS_FLUSH()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Monta as Section e as Cell para impressão no modo Personalizado

@author Guilhrme Freudenburg
@since 21/08/2014

@return Nil
/*/
//---------------------------------------------------------------------
Static Function ReportDef()

//Variaveis que verificam o tamanho dos campos
Local nTa1 := If((TAMSX3("A1_COD")[1]) < 1,6,(TAMSX3("A1_COD")[1]))
Local nTa1L := If((TAMSX3("A1_LOJA")[1]) < 1,2,(TAMSX3("A1_LOJA")[1]))
Local nTalF := If((TAMSX3("RJ_FUNCAO")[1]) < 1,5,(TAMSX3("RJ_FUNCAO")[1]))
Local nTalE := If((TAMSX3("TM4_EXAME")[1]) < 1,6,(TAMSX3("TM4_EXAME")[1]))

//---------------------------
//  Mostras as Perguntas
//---------------------------
oReport := TReport():New("MDTR483",OemToAnsi(STR0002),cPerg,{|oReport| TReport(oReport)},STR0001)//"Relatório que imprime os Exames por cada Função."
Pergunte(oReport:uParam,.F.)

oSection0 := TRSection():New (oReport,STR0020, {(cTRB)}) //Função
oCel0 := TRCell():New (oSection0, "(cTRB)->CODFUN"	, cTRB , STR0020	, "@!"	,nTalF+8, .T., /*{|| code-block de impressao }*/ ) //"Função"
oCel0 := TRCell():New (oSection0, "(cTRB)->DESFUN"	, cTRB , STR0021	, "@!"	,     40, .T., /*{|| code-block de impressao }*/ ) //"Descrição"
If lSigaMdtPS
oCel0 := TRCell():New (oSection0, "(cTRB)->CLIENT+(cTRB)->CLINOME"	, cTRB , STR0025	, "@!"	,  nTa1+28, .T., /*{|| code-block de impressao }*/ ) //"Cleinte"
oCel0 := TRCell():New (oSection0, "(cTRB)->LOJA"		, cTRB , STR0026	, "@!"	, nTa1L+8, .T., /*{|| code-block de impressao }*/ ) //"Loja"
Endif

oSection1 := TRSection():New (oReport,STR0022, {(cTRB)}) //Exame
oCel1 := TRCell():New (oSection1, "(cTRB)->CODEXA"	, cTRB , STR0022	, "@!"	,  nTalE+8, .T., /*{|| code-block de impressao }*/ ) //"Exame"
oCel1 := TRCell():New (oSection1, "(cTRB)->DESEXA"	, cTRB , STR0021	, "@!"	,       40, .T., /*{|| code-block de impressao }*/ ) //"Descrição"
oCel1 := TRCell():New (oSection1, "(cTRB)->FAIXA"	, cTRB , STR0023	, "@!"	,       10, .T., /*{|| code-block de impressao }*/ ) //"Faixa"
oCel1 := TRCell():New (oSection1, "(cTRB)->TIPOEX"	, cTRB , STR0024	, "@!"	,       60, .T., /*{|| code-block de impressao }*/ ) //"Tipo Exame"

Return oReport

//---------------------------------------------------------------------
/*/{Protheus.doc} TReport
Inicia a impressão, utilizado as Section  e as Cell

@author Guilhrme Freudenburg
@since 21/08/2014

@return nil
/*/
//---------------------------------------------------------------------
Static Function TReport(oReport)

Local cFuncao:=""//Faz Backup da função posicionada
Local lFinish:=.F.//Variavel de controle

//--------------------------------
// Chama a função que monta a TRB
//--------------------------------
MDT483TRB()

dbSelectArea(cTRB)
dbGoTop()
While !Eof()
	oSection0:Init()//Da inicio a impressão
	oSection0:PrintLine()//Imprime a linha
	cFuncao:=(cTRB)->CODFUN//Grava a função posicionada
		While !Eof() .And. cFuncao == (cTRB)->CODFUN
			If !Empty((cTRB)->CODEXA)
				oSection1:Init()
				oSection1:PrintLine()
				lFinish:=.T.
			Endif
			(cTRB)->(dbSkip())
		End
	If lFinish
		oSection1:Finish()
	Endif
	oSection0:Finish()
End
oTempTRB:Delete()
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} Somalinha
Incrementa Linha e Controla Salto de Pagina

@author Guilherme Freudenburg
@since 21/08/2014

@return nil
/*/
//---------------------------------------------------------------------
Static Function Somalinha()
    Li++
    If Li > 58
        Cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
    EndIf
Return
