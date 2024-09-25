#INCLUDE "MDTR932.ch"
#INCLUDE "protheus.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR932()
Impressão da tabela de Dimensionamento CIPATR

@author Gabriel Gustavo de Mora
@since 16/05/2016
@return
/*/
//---------------------------------------------------------------------
Function MDTR932()
Local aNGBEGINPRM := NGBEGINPRM()

//Variaveis para impressao
Local wnrel   := "MDTR932"
Local cDesc1  := STR0001 //"Dimensionamento da CIPATR"
Local cDesc2  := ""
Local cDesc3  := ""
Local cString := "TOK"
Local cPerg    := Padr( "MDT932" , Len( Posicione("SX1", 1, "MDT932", "X1_GRUPO" ) ) )

Private aReturn  := {STR0002, 1,STR0003, 1, 2, 1, "",1 } //""De Mandato ?""###""Até Mandato ?""
Private titulo   := STR0001 //"Dimensionamento da CIPATR"
Private ntipo    := 0
Private nLastKey := 0
Private aPerg := {}

If !NGCADICBASE("TOK_GRUPO","A","TOK",.F.)
	If !NGINCOMPDIC("UPDMDT99","TIKBPP")
		Return .F.
	Endif
Endif

//-----------------------------------------------------------------------
//  Variaveis utilizadas para parametros
//  mv_par01		// De Mandato ?
//  mv_par02		// Até Mandato
//  mv_par03		// Imprimir Quadro ?
//-----------------------------------------------------------------------
If !dbseek(cPerg+"01")

	aAdd(aPerg, {STR0002,"C",TamSx3("TNN_MANDAT")[1]	,0 ,"MDT931VLD(1)" , "TNN"	,"G"}) //"De Mandato ?"
	aAdd(aPerg, {STR0003,"C",TamSx3("TNN_MANDAT")[1]	,0 ,"MDT931VLD(2)" , "TNN"	,"G"}) //"Ate Mandato ?"
	aAdd(aPerg, {STR0004,"C",01							,0 ,"NaoVazio()"   ,    	,"C" ,STR0019,STR0020}) //"Imprimir Quadro ?"###"Fixo"###"Comparativo"
	NGChkSx1(cPerg,aPerg)
EndIf

NgHelp( "." + cPerg + Space( Len( Posicione("SX1", 1, "MDT932", "X1_GRUPO" ) ) - Len(cPerg)) + "01.", STR0017, .T. ) //"Informe a partir de qual Mandato deve filtrar a consulta. Pressione as teclas [F3]+[Enter] para selecionar um Mandato."
NgHelp( "." + cPerg + Space( Len( Posicione("SX1", 1, "MDT932", "X1_GRUPO" ) ) - Len(cPerg)) + "02.", STR0018, .T. ) //"Informe até qual Mandato deve se filtrar a consulta. Pressione as teclas [F3]+[Enter] para selecionar o Mandato desejado ou digite ZZZZZZ neste campo e o acima em branco para considerar todos os Mandatos."
NgHelp( "." + cPerg + Space( Len( Posicione("SX1", 1, "MDT932", "X1_GRUPO" ) ) - Len(cPerg)) + "03.", STR0006, .T. ) //"Determina se será impresso o Quadro Comparativo"



//---------------------------------------------------------------
//  Verifica as perguntas selecionadas
//---------------------------------------------------------------
pergunte(cPerg,.F.)

//---------------------------------------------------------------
// Envia controle para a funcao SETPRINT
//---------------------------------------------------------------
wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"")

If nLastKey == 27
    Set Filter to
	//---------------------------------------------------------------
	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	//---------------------------------------------------------------
	NGRETURNPRM(aNGBEGINPRM)
    Return
EndIf

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter to
 	//---------------------------------------------------------------
	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	//---------------------------------------------------------------
	NGRETURNPRM(aNGBEGINPRM)
 	Return
EndIf

Processa({|lEnd| MDT932IMP()}) // MONTE TELA PARA ACOMPANHAMENTO DO PROCESSO.

//----------------------------------------------
// Retorna conteudo de variaveis padroes
//----------------------------------------------
NGRETURNPRM(aNGBEGINPRM)
Return
//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR932IMP()
Realiza a impressão

@author Gabriel Gustavo de Mora
@since 16/05/2016
@return
/*/
//---------------------------------------------------------------------
Static Function MDT932IMP()
Local lImp := .F.
Local nY, nX
Local aQuadro:= {}

//Definicao de Fontes
Local cFonte 	:= "Arial"
Local oFont13bs := TFont():New(cFonte,13,13,,.T.,,,,.F.,.T.)
Local oFont10	:= TFont():New(cFonte,10,10,,.T.,,,,.F.,.F.)

//Variaveis de controle de quantidades
Local nEfet
Local nSupl
Local nQuantFunc
Local nNecEfet
Local nNecSupl

//Variaveis do relatorio
Local oPrint

//Inicializa Objeto
oPrint := FwMsPrinter():New(OemToAnsi(titulo))
oPrint:SetPortrait()

//Preenche o quadro
aAdd (aQuadro , { "1" , "2" , "3" , "4" , "5" , "6" } ) //Representates dos trabalhadores
aAdd (aQuadro , { "1" , "2" , "3" , "4" , "5" , "6" } ) //Representates dos empregados

If(mv_par03) == 1
   //-------------------------------------------------------------------------
   // INICIA A IMPRESSÃO
   //-------------------------------------------------------------------------
  	lImp := .T.
   	lin  := 100
    oPrint:StartPage()
	Somalinha(oPrint)
	oPrint:SayAlign(lin,300,STR0005,oFont13bs,1700,200,,2,0) //"DIMENSIONAMENTO DA CIPATR"
	Somalinha(oPrint,200) // Linha Horizontal


	//Monta o quadro
	For nX := 1 To Len(aQuadro)

		//Constroi cabeçalho
		If nX == 1
			fCabec932(oPrint,oFont10)
		Endif

		nCol := 300
		oPrint:Box(lin,nCol,lin+100,2040)
		If nX % 2 == 0
			oPrint:SayAlign(lin+10,nCol,STR0021, oFont10,360,70,,2,0) //"Representantes do empregador"
		Else
			oPrint:SayAlign(lin+10,nCol,STR0022, oFont10,360,70,,2,0) //"Representantes dos trabalhadores"
		EndIf
		nCol += 360
		For nY := 1 to len(aQuadro[nX])
			oPrint:Line(lin,nCol,lin+100,nCol)
			oPrint:SayAlign(lin+20,nCol+80,aQuadro[nX][nY],oFont10,100,50,,0,0)
			nCol += 230
		Next nY
		Somalinha(oPrint,100)
	Next nX
	oPrint:EndPage()
ElseIf(mv_par03) == 2

	dbSelectArea("TOE")
	dbSetOrder(1)
	dbSeek(xFilial("TOE") + SM0->M0_CNAE)

	dbSelectArea("TNN")
	dbSetOrder(1)
	dbSeek(xFilial("TNN") + MV_PAR01 , .T.)
	While TNN->( !Eof() ) .And. TNN->TNN_FILIAL == xFilial( "TNN" ) .And. TNN->TNN_MANDAT <= MV_PAR02

		lImp := .T.
		lin  := 100
		oPrint:StartPage()
		Somalinha(oPrint)
		oPrint:SayAlign(lin,300,STR0005,oFont13bs,1700,200,,2,0) //"DIMENSIONAMENTO DA CIPATR"
		Somalinha(oPrint,200) // Linha Horizontal

		//Chama função que calcula quantidades de funcionários, suplentes e efetivos
		fCalc932(@nEfet, @nSupl , @nQuantFunc)

		//Verifica quantidade necessária de suplentes e efetivos para a CIPATR
		Do Case
			Case nQuantFunc >= 0 .AND. nQuantFunc < 20
				nNecEfet := 0
				nNecSupl := 0
			Case nQuantFunc >= 20 .AND. nQuantFunc <= 35
				nNecEfet := 1
				nNecSupl := 1
			Case nQuantFunc >= 36 .AND. nQuantFunc <= 70
				nNecEfet := 2
				nNecSupl := 2
			Case nQuantFunc >= 71 .AND. nQuantFunc <= 100
				nNecEfet := 3
				nNecSupl := 3
			Case nQuantFunc >= 101 .AND. nQuantFunc <= 500
				nNecEfet := 4
				nNecSupl := 4
			Case nQuantFunc >= 501 .AND. nQuantFunc <= 1000
				nNecEfet := 5
				nNecSupl := 5
			Case nQuantFunc > 1000
				nNecEfet := 6
				nNecSupl := 6
		EndCase

		dbSelectArea("TOK")
		dbSetOrder(1)
		dbSeek(xFilial("TOK") + TOE->TOE_GRUPO )

		//----------------------------------------------------------------------------------
		// TEXTO SUPERIOR
		//----------------------------------------------------------------------------------
		oPrint:Say(lin 		,300	,STR0007													,oFont10) //"Filial"
		oPrint:Say(lin		,1000	,STR0012													,oFont10) //"Mandato:"
		oPrint:Say(lin+40	,300	,STR0013													,oFont10) //"Data Início:"
		oPrint:Say(lin+40	,1000	,STR0014													,oFont10) //"Data Fim:"
		oPrint:Say(lin+80	,300	,STR0008													,oFont10) //"Total de Funcionários:"
		oPrint:Say(lin 		,700	,Alltrim(TOE->TOE_FILIAL)									,oFont10) //"Filial"
		oPrint:Say(lin		,1205	,Alltrim(TNN->TNN_MANDAT)									,oFont10) //"Mandato:"
		oPrint:Say(lin+40	,700	,cValToChar(TNN->TNN_DTINIC)								,oFont10) //"Data Início:"
		oPrint:Say(lin+40	,1205	,cValToChar(TNN->TNN_DTTERM)								,oFont10) //"Data Fim:"
		oPrint:Say(lin+80 	,700	,cValToChar(nQuantFunc)										,oFont10) //"Total de Funcionários:"

		Somalinha(oPrint,120)

		//Monta cabeçalho
		fCabec932(oPrint , oFont10)

		nCol := 300
		//Monta quadro
		oPrint:Box(lin, nCol, lin+70, 900)
		oPrint:SayAlign(lin+10,nCol,STR0023, oFont10,600,50,,2,0) //"Necessidade"
		nCol += 600
		//Preenche linhas com as informações da empresa - NECESSIDADE
		oPrint:Box(lin, nCol, lin+70, nCol+250)
		oPrint:SayAlign(lin,nCol,CValToChar(nNecEfet), oFont10,250,70,,2,0) //Necessidade efetivos

		oPrint:Box(lin, nCol+250, lin+70, nCol+502)
		oPrint:SayAlign(lin,nCol+250,CValToChar(nNecSupl), oFont10,250,70,,2,0) //Necessidade suplentes

		nCol -= 600
		Somalinha(oPrint,70)
		oPrint:Box(lin, nCol, lin+70, 900)
		oPrint:SayAlign(lin+10,nCol,STR0024, oFont10,600,50,,2,0) //"Realidade"
		nCol += 600

		//Preenche linhas com as informações da empresa - REALIDADE//

		//Realidade efetivos
		oPrint:Box(lin, nCol, lin+70, nCol+250)
		If nEfet >= nNecEfet //Dentro dos conformes
			oPrint:SayAlign(lin,nCol,CValToChar(nEfet), oFont10,250,70,,2,0)
		Else // Fora dos conformes
			oPrint:SayAlign(lin,nCol,CValToChar(nEfet), oFont10,250,70,CLR_HRED,2,0)
		EndIf

		//Realidade suplentes
		oPrint:Box(lin, nCol+250, lin+70, nCol+502)
		If nSupl >= nNecSupl //Dentro dos conformes
			oPrint:SayAlign(lin,nCol+250,CValToChar(nSupl), oFont10,250,70,,2,0)
		Else //Fora dos conformes
			oPrint:SayAlign(lin,nCol+250,CValToChar(nSupl), oFont10,250,70,CLR_HRED,2,0)
		EndIf

		Somalinha(oPrint,70)

		// TEXTO FINAL //
		oPrint:SayAlign(lin,300,STR0009, oFont10,800,70,,0,0) //"OBS:(*) Tempo Parcial (mínimo de três horas)"
		oPrint:SayAlign(lin+75,300,STR0010, oFont10,800,70,,0,0) //"Legenda: Preto - Dentro dos Conformes"
		oPrint:SayAlign(lin+150,430,STR0011, oFont10,800,70,CLR_HRED,0,0) //"Vermelho - Fora dos Conformes"

		TNN->( dbSkip() )
	End
Endif

If lImp
//Imprime na Tela ou Impressora
	If aReturn[5] == 1
		oPrint:Preview()
	Else
		oPrint:Print()
	EndIf
Else
	MsgStop(STR0015,STR0016)//"Não existem dados para montar o Quadro Comparativo."##"ATENÇÃO"
Endif
MS_FLUSH()
Return
//---------------------------------------------------------------------
/*/{Protheus.doc} Somalinha(oPrint,nLin)
Realiza saltos de linhas

@author Gabriel Gustavo de Mora
@since 16/05/2016
@return
/*/
//---------------------------------------------------------------------
Static Function Somalinha(oPrint,nLin)

Default nLin    := 120

lin += nLin

If lin > 2900
	oPrint:EndPage()
	oPrint:StartPage()
	lin := 100
EndIf

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fCabec932(oPrint, oFont08)
Realiza saltos de linhas

@author Gabriel Gustavo de Mora
@since 16/05/2016
@return
/*/
//---------------------------------------------------------------------
static Function fCabec932(oPrint,oFont10)

	Local nCol

	If (mv_par03) == 1

		nCol := 300
		oPrint:Box(lin,nCol,lin+150,2040)
		oPrint:SayAlign( lin,nCol,STR0025 + CHR(10) + STR0026, oFont10 ,360,100,,2,0 )//"Nº de Trabalhadores "###"Nº de Membros"
		nCol += 360
		oPrint:Line( lin, nCol, lin+100, nCol )
		oPrint:SayAlign( lin,nCol,"20 a 35",oFont10,230,100,,2,0 )
		nCol += 230
		oPrint:Line( lin, nCol, lin+100, nCol )
		oPrint:SayAlign( lin,nCol,"36 a 70",oFont10,230,100,,2,0 )
		nCol += 230
		oPrint:Line( lin, nCol, lin+100, nCol )
		oPrint:SayAlign( lin,nCol,"71 a 100",oFont10,230,100,,2,0 )
		nCol += 230
		oPrint:Line( lin, nCol, lin+100, nCol )
		oPrint:SayAlign( lin,nCol,"101 a 500",oFont10,230,100,,2,0 )
		nCol += 230
		oPrint:Line( lin, nCol, lin+100, nCol )
		oPrint:SayAlign( lin,nCol,"501 a 1000",oFont10,230,100,,2,0 )
		nCol += 230
		oPrint:Line( lin, nCol, lin+100, nCol )
		oPrint:SayAlign( lin,nCol,"Acima de 1000",oFont10,230,100,,2,0 )

		Somalinha(oPrint,100)

	ElseIf (mv_par03) == 2

		nCol := 300
		oPrint:Box(lin,nCol,lin+200,1400)
		oPrint:Line( lin, nCol, lin+200, nCol+600)
		oPrint:SayAlign( lin+100,nCol+50,STR0027, oFont10 ,600,100,,0,0 ) //"Situação da empresa"
		oPrint:SayAlign( lin,nCol,STR0028, oFont10 ,550,100,,1,0 ) //"Técnica"
		nCol += 600
		oPrint:Line( lin, nCol, lin+200, nCol )
		oPrint:SayAlign( lin,nCol,STR0029,oFont10,250,200,,2,0 ) //"Efetivos"
		nCol += 250
		oPrint:Line( lin, nCol, lin+200, nCol )
		oPrint:SayAlign( lin,nCol,STR0030,oFont10,250,200,,2,0 ) //"Suplentes"

		Somalinha(oPrint,200)
	EndIf

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fCalc932(nEfet , nSupl, nQuantFunc)
Calcula total de funcionários, suplentes e efetivos

@author Gabriel Gustavo de Mora
@since 16/05/2016
@return
/*/
//---------------------------------------------------------------------
Static Function fCalc932(nEfet , nSupl, nQuantFunc)

	//Define os novos Alias
	Local cAliasSRA := GetNextAlias()
	Local cAliasTNQ := GetNextAlias()
	Local cAliasTNQ2 := GetNextAlias()

	cTabSRA := RetSqlName("SRA")
	//Consulta para trazer total de funcionários ativos.
	cQuery := "SELECT COUNT(*) AS QTFUNC "
	cQuery += "FROM " + cTabSRA + " SRA "
	cQuery += "WHERE SRA.D_E_L_E_T_ <> '*' AND"
	cQuery +="(SRA.RA_ADMISSA <= "+ValToSql(TNN->TNN_DTTERM)+") AND"
	cQuery +="(SRA.RA_SITFOLH <> 'D' OR SRA.RA_DEMISSA = '' OR SRA.RA_DEMISSA >= "+ValToSql(TNN->TNN_DTINIC)+") AND"
	cQuery += "(SRA.RA_FILIAL = " + ValToSql( xFilial("SRA") ) + ")"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSRA,.T.,.T.)

	nQuantFunc := ( cAliasSRA )->QTFUNC //Quantidade de funcionários ativos.

	cTabTNQ := RetSqlName("TNQ")
	//Consulta para verificar a quantidade de componentes efetivos da CIPATR
	cQuery := "SELECT COUNT(*) AS QTCOMP1 "
	cQuery += "FROM " + cTabTNQ + " TNQ "
	cQuery += "WHERE TNQ.D_E_L_E_T_ != '*' AND "
	cQuery += "(TNQ.TNQ_DTSAID = '' AND TNQ.TNQ_TIPCOM = '1') AND"
	cQuery +="(TNQ.TNQ_MANDAT ="+ValToSql(TNN->TNN_MANDAT)+")"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTNQ,.T.,.T.)

	nEfet := ( cAliasTNQ )->QTCOMP1//Quantidade de efetivos real

	cTabTNQ := RetSqlName("TNQ")
	//Consulta para verificar a quantidade de componentes suplentes da CIPATR
	cQuery := "SELECT COUNT(*) AS QTCOMP2"
	cQuery += "FROM " + cTabTNQ + " TNQ "
	cQuery += "WHERE TNQ.D_E_L_E_T_ != '*' AND "
	cQuery += "(TNQ.TNQ_DTSAID = '' AND TNQ.TNQ_TIPCOM = '2') AND"
	cQuery +="(TNQ.TNQ_MANDAT ="+ValToSql(TNN->TNN_MANDAT)+")"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTNQ2,.T.,.T.)

	nSupl := ( cAliasTNQ2 )->QTCOMP2//Quantidade real de suplentes

Return