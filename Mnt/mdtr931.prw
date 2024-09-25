#INCLUDE "MDTR931.ch"
#INCLUDE "protheus.ch"

#DEFINE _nAcimPos_ 15
#DEFINE _nTipoPos_ 16
#DEFINE _nLastPos_ 17

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR931()
Impressão da tabela de Dimensionamento CIPA

@author Guilherme Freudenburg
@since 31/01/2014
@return
/*/
//---------------------------------------------------------------------
Function MDTR931()

	Local aNGBEGINPRM := NGBEGINPRM()

	//Variaveis para impressao
	Local wnrel   := "MDTR931"
	Local cDesc1  := STR0001 //"Dimensionamento da CIPA"
	Local cDesc2  := ""
	Local cDesc3  := ""
	Local cString := "TOK"
	Local cPerg    := Padr( "MDT931" , 10 )
	Local lCipatr := SuperGetMv("MV_NG2NR31" , .F. , "2") == "1"

	Private aReturn  := {STR0002, 1,STR0003, 1, 2, 1, "",1 } //""De Mandato ?""###""Até Mandato ?""
	Private titulo   := STR0001 //"Dimensionamento da CIPA"
	Private ntipo    := 0
	Private nLastKey := 0
	Private aPerg := {}

	/*--------------------------
	//PADRÃO				   |
	|  De Mandato ?			   |
	|  Ate Mandato ? 		   |
	|  Imprimir Quadro ?       |
	--------------------------*/

	//Conforme parâmentro MV_NG2NR31
	If lCipatr
		MDTR932()
	Else

		If !AliasInDic('TYH')
			// "As perguntas do relatório estão desatualizadas, favor aplicar a atualização contida no pacote da issue DNG-1847"
			MsgStop( STR0077 )
		Else

			//  Verifica as perguntas selecionadas
			pergunte(cPerg,.F.)

			// Envia controle para a funcao SETPRINT
			wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"")

			If nLastKey == 27
				Set Filter to
					// Devolve variaveis armazenadas (NGRIGHTCLICK)
					NGRETURNPRM(aNGBEGINPRM)
				Return
			EndIf

			SetDefault(aReturn,cString)

			If nLastKey == 27
				Set Filter to
				// Devolve variaveis armazenadas (NGRIGHTCLICK)
				NGRETURNPRM(aNGBEGINPRM)
				Return
			EndIf

			Processa({|lEnd| MDT931IMP()}) // MONTE TELA PARA ACOMPANHAMENTO DO PROCESSO.

		EndIf

		// Retorna conteudo de variaveis padroes
		NGRETURNPRM(aNGBEGINPRM)
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT931IMP()
Faz a impressão

@author Guilherme Freudenburg
@since 30/01/2014
@return
/*/
//---------------------------------------------------------------------
Static Function MDT931IMP()
Local lImp := .F.
Local i
Local aQuadroI:= {}

//Definicao de Fontes
Local cFonte 	:= "Verdana"
Local oFont13bs := TFont():New(cFonte,13,13,,.T.,,,,.F.,.T.)
Local oFont10	:= TFont():New(cFonte,10,10,,.T.,,,,.F.,.F.)
Local oFont08	:= TFont():New(cFonte,08,08,,.T.,,,,.F.,.F.)
Local oFont07	:= TFont():New(cFonte,07,07,,.T.,,,,.F.,.F.)

//Variaveis de controle de quantidades
Local nEfet
Local nSupl
Local nNeceEfet
Local nNeceSupl
Local nQuantFunc
//Variaveis do relatorio
Local oPrint

//Inicializa Objeto
oPrint := TMSPrinter():New(OemToAnsi(titulo))
oPrint:SetPortrait()
oPrint:Setup()

fMontaQuadro( @aQuadroI )

If(mv_par03) == 1
	   //-------------------------------------------------------------------------
	   // INICIA A IMPRESSÃO
	   //-------------------------------------------------------------------------
	  	lImp := .T.
	   	lin  := 100
	    oPrint:StartPage()
		Somalinha(oPrint)
		oPrint:Say(lin,1225,STR0005,oFont13bs,,,,2) //"DIMENSIONAMENTO DA CIPA"
		Somalinha(oPrint,150) // Linha Horizontal



		For i:=1 To Len(aQuadroI)
			If(aQuadroI[i,_nLastPos_])
				fCabec931(oPrint,oFont07)
			Endif
			If (Lin == 100) .And. !(aQuadroI[i,_nLastPos_])
				oPrint:Line(lin		,275 	,lin,2300 		)//linha superior
			Endif

			If(aQuadroI[i,_nTipoPos_]) == 1
				//---------------------------------------------------------------------
				// IMPRIME LINHAS
				//---------------------------------------------------------------------
				oPrint:Line(lin		,275	,lin+120	,275 	)	//0ª linha
				oPrint:Line(lin		,460	,lin+120	,460 	)	//1ª linha
				oPrint:Line(lin		,750	,lin+120	,750 	)	//2ª linha
				oPrint:Line(lin		,840	,lin+120	,840 	)	//3ª linha
				oPrint:Line(lin		,930 	,lin+120	,930 	)	//4ª linha
				oPrint:Line(lin		,1020 	,lin+120	,1020	)	//5ª linha
				oPrint:Line(lin		,1110 	,lin+120	,1110 	)	//6ª linha
				oPrint:Line(lin		,1200	,lin+120	,1200 	)	//7ª linha
				oPrint:Line(lin		,1290 	,lin+120	,1290 	)	//8ª linha
				oPrint:Line(lin		,1380	,lin+120	,1380 	)	//9ª linha
				oPrint:Line(lin		,1470	,lin+120	,1470 	)	//10ª linha
				oPrint:Line(lin		,1560	,lin+120	,1560 	)	//11ª linha
				oPrint:Line(lin		,1680	,lin+120	,1680 	)	//12ª linha
				oPrint:Line(lin		,1800	,lin+120	,1800 	)	//13ª linha
				oPrint:Line(lin		,1920	,lin+120	,1920 	)	//14ª linha
				oPrint:Line(lin		,2050	,lin+120	,2050 	)	//15ª linha
				oPrint:Line(lin		,2300	,lin+120	,2300 	)	//16ª linha
				oPrint:Line(lin+60	,460 	,lin+60	,2300 	)	//linha meio
				oPrint:Line(lin+120	,275 	,lin+120	,2300 	)	//linha inferior
				//---------------------------------------------------------
				// EFETIVOS
				//---------------------------------------------------------
				oPrint:Say(lin+40 	,290	,aQuadroI[i,1]			,oFont10) //"Grupo"
				oPrint:Say(lin+20		,475	,STR0019					,oFont07) //"Efetivos"
				oPrint:Say(lin+20		,790	,aQuadroI[i,2]			,oFont07) //"a"
				oPrint:Say(lin+20 	,870	,aQuadroI[i,3]			,oFont07) //"a"
				oPrint:Say(lin+20 	,960	,aQuadroI[i,4]			,oFont07) //"a"
				oPrint:Say(lin+20 	,1050	,aQuadroI[i,5]			,oFont07) //"a"
				oPrint:Say(lin+20 	,1130	,aQuadroI[i,6]			,oFont07) //"a"
				oPrint:Say(lin+20 	,1230	,aQuadroI[i,7]			,oFont07) //"a"
				oPrint:Say(lin+20 	,1320	,aQuadroI[i,8]			,oFont07) //"a"
				oPrint:Say(lin+20 	,1410	,aQuadroI[i,9]			,oFont07) //"a"
				oPrint:Say(lin+20 	,1510	,aQuadroI[i,10]			,oFont07) //"a"
				oPrint:Say(lin+20 	,1610	,aQuadroI[i,11]			,oFont07) //"a"
				oPrint:Say(lin+20 	,1730	,aQuadroI[i,12]			,oFont07) //"a"
				oPrint:Say(lin+20 	,1850	,aQuadroI[i,13]			,oFont07) //"a"
				oPrint:Say(lin+20 	,1960	,aQuadroI[i,14]			,oFont07) //"a"
				oPrint:Say(lin+20 	,2160	,aQuadroI[i,_nAcimPos_]	,oFont07) //"a"
			Else
				//----------------------------------------------------------
				// SUPLENTES
				//----------------------------------------------------------
				oPrint:Say(lin+70	,475	,STR0020				,oFont07) //"Suplentes"
				oPrint:Say(lin+70	,790	,aQuadroI[i,2]			,oFont07) //"a"
				oPrint:Say(lin+70 	,870	,aQuadroI[i,3]			,oFont07) //"a"
				oPrint:Say(lin+70 	,960	,aQuadroI[i,4]			,oFont07) //"a"
				oPrint:Say(lin+70 	,1050	,aQuadroI[i,5]			,oFont07) //"a"
				oPrint:Say(lin+70 	,1130	,aQuadroI[i,6]			,oFont07) //"a"
				oPrint:Say(lin+70 	,1230	,aQuadroI[i,7]			,oFont07) //"a"
				oPrint:Say(lin+70 	,1320	,aQuadroI[i,8]			,oFont07) //"a"
				oPrint:Say(lin+70 	,1410	,aQuadroI[i,9]			,oFont07) //"a"
				oPrint:Say(lin+70 	,1510	,aQuadroI[i,10]			,oFont07) //"a"
				oPrint:Say(lin+70 	,1610	,aQuadroI[i,11]			,oFont07) //"a"
				oPrint:Say(lin+70 	,1730	,aQuadroI[i,12]			,oFont07) //"a"
				oPrint:Say(lin+70 	,1850	,aQuadroI[i,13]			,oFont07) //"a"
				oPrint:Say(lin+70 	,1960	,aQuadroI[i,14]			,oFont07) //"a"
				oPrint:Say(lin+70 	,2160	,aQuadroI[i,_nAcimPos_]	,oFont07) //"a"
			Endif
			If(aQuadroI[i,_nTipoPos_]) == 2
				Somalinha(oPrint)
			Endif
		Next i
		oPrint:Say(lin+50 	,275	,STR0032	,oFont07) //"Observação:"
		oPrint:Say(lin+110 	,300	,STR0033	,oFont07) //"Nos grupos C-18 e C-18a constituir CIPA por estabelecimento a partir de 70 trabalhadores e quando o estabelecimento possuir menos de 70"
		oPrint:Say(lin+170 	,300	,STR0034	,oFont07) // "trabalhadores observar o dimensionamento descrito na NR 18 - subitem 18.33.1."

		oPrint:EndPage()

ElseIf(mv_par03) == 2
		dbSelectArea("TOE")
		dbSetOrder(1)
		If dbSeek(xFilial("TOE") + SM0->M0_CNAE) .And. !Empty( TOE->TOE_GRUPO ) .And. ;
			aSCAN( aQuadroI, {|x| Alltrim(x[1]) == Alltrim(TOE->TOE_GRUPO) } ) > 0
				dbSelectArea( "TNN" )
				dbSetOrder( 1 )
				dbSeek( xFilial( "TNN" ) + MV_PAR01 , .T. )
				While TNN->( !Eof() ) .And. TNN->TNN_FILIAL == xFilial( "TNN" ) .And. TNN->TNN_MANDAT <= MV_PAR02

					//-------------------------------------------------------------------------
					// INICIA A IMPRESSÃO
					//-------------------------------------------------------------------------

				  	lImp := .T.
				   	lin  := 100
				    oPrint:StartPage()

				    fCalc931( aQuadroI , @nEfet , @nSupl , @nNeceEfet , @nNeceSupl , @nQuantFunc )//Função que calcula a quantidade de Efetivos e Suplentes

					Somalinha(oPrint,150)
					oPrint:Say(lin,1225,STR0005,oFont13bs,,,,2) //"DIMENSIONAMENTO DA CIPA"
					Somalinha(oPrint,150)

					dbSelectArea("TOK")
					dbSetOrder(1)
					dbSeek( xFilial( "TOK" ) + TOE->TOE_GRUPO )
					//----------------------------------------------------------------------------------
					// TEXTO SUPERIOR
					//----------------------------------------------------------------------------------
					oPrint:Say( lin 	, 0275, STR0021													, oFont08 ) //"Filial"
					oPrint:Say( lin+40 	, 0275, STR0022													, oFont08 ) //"Gráu de Risco:"
					oPrint:Say( lin+80	, 0275, STR0035													, oFont08 ) //"Mandato:"
					oPrint:Say( lin+80	, 0900, STR0036													, oFont08 ) //"Data Início:"
					oPrint:Say( lin+80	, 1400, STR0037													, oFont08 ) //"Data Fim:"
					oPrint:Say( lin+120	, 0275, STR0023													, oFont08 ) //"Total de Funcionários:"
					oPrint:Say( lin		, 0700, Alltrim(TOE->TOE_FILIAL)								, oFont08 ) //"Filial"
					oPrint:Say( lin+40 	, 0700, Alltrim(TOE->TOE_GRISCO)								, oFont08 ) //"Gráu de Risco:"
					oPrint:Say( lin+80	, 0700, Alltrim(TNN->TNN_MANDAT)								, oFont08 ) //"Mandato:"
					oPrint:Say( lin+80	, 1105, cValToChar(TNN->TNN_DTINIC)								, oFont08 ) //"Data Início:"
					oPrint:Say( lin+80	, 1575, cValToChar(TNN->TNN_DTTERM)								, oFont08 ) //"Data Fim:"
					oPrint:Say( lin+120 , 0700, cValToChar(nQuantFunc)									, oFont08 ) //"Total de Funcionários:"
					oPrint:Say( lin		, 1300, STR0024													, oFont08 ) //"Grupo"
					oPrint:Say( lin	 	, 1450, Alltrim(TOK->TOK_GRUPO)+"  -  "+Alltrim(TOK->TOK_DESCRI), oFont08 ) //"Grupo"
					Somalinha(oPrint)
					lin+=60

					//----------------------------------------------------------------------------------
					// TEXTO DA TABELA
					//----------------------------------------------------------------------------------
					oPrint:Say( lin+020, 0650, STR0025, oFont08 ) //"Técnicas"
					oPrint:Say( lin+130, 0290, STR0026, oFont08 ) //"Situação da Empresa"
					oPrint:Say( lin+200, 0290, STR0027, oFont08 ) //"Necessidade"
					oPrint:Say( lin+290, 0290, STR0028, oFont08 ) //"Realidade"
					oPrint:Say( lin+085, 0900, STR0019, oFont08 ) //"Efetivos"
					oPrint:Say( lin+085, 1250, STR0020, oFont08 ) //"Suplentes"

					//---------------------------------------------------------------
					// VERIFICA A NECESSIDADE CONFORME NR5
					//---------------------------------------------------------------
					If Empty(nNeceEfet)
						oPrint:Say(lin+200 	,820	,"0"					,oFont08)
					Else
						oPrint:Say(lin+200 	,820	,cValToChar(nNeceEfet)	,oFont08)
					Endif
					If Empty(nNeceSupl)
						oPrint:Say(lin+200	,1170	,"0"					,oFont08)
					Else
						oPrint:Say(lin+200	,1170	,cValToChar(nNeceSupl)	,oFont08)
					Endif

					//---------------------------------------------------------------
					// VERIFICA A REALIDADE DA EMPRESA
					//---------------------------------------------------------------
					If nEfet >= nNeceEfet
						oPrint:Say(lin+290 	,820	,cValToChar(nEfet)	,oFont08)
					Else
						oPrint:Say(lin+290 	,820	,cValToChar(nEfet)	,oFont08,,CLR_HRED)
					Endif
					If nSupl >= nNeceSupl
						oPrint:Say(lin+290	,1170	,cValToChar(nSupl)	,oFont08)
					Else
						oPrint:Say(lin+290	,1170	,cValToChar(nSupl)	,oFont08,,CLR_HRED)
					Endif

					//IMPRIMI LINHAS
					oPrint:Line(lin		,275	,lin		,1500 	)	//Linha Superior
					oPrint:Line(lin		,275 	,lin+180	,800 	)	//Linha Transversal
					oPrint:Line(lin		,275	,lin+340	,275 	)	//1ª linha
					oPrint:Line(lin		,800	,lin+340	,800 	)	//2ª linha
					oPrint:Line(lin		,1150	,lin+340	,1150 	)	//3ª linha
					oPrint:Line(lin		,1500 	,lin+340	,1500 	)	//4ª linha
					oPrint:Line(lin+180	,275 	,lin+180	,1500 	)	//Linha Central
					oPrint:Line(lin+260	,275 	,lin+260	,1500 	)	//Linha Central
					oPrint:Line(lin+340	,275 	,lin+340	,1500 	)	//Linha Infereior

					oPrint:Say(lin+350 	,275	,STR0029	,oFont08) //"OBS:(*) Tempo Parcial (mínimo de três horas)"
					oPrint:Say(lin+395 	,275	,STR0030	,oFont08) //"Legenda: Preto - Dentro dos Conformes"
					oPrint:Say(lin+440 	,485	,STR0031	,oFont08,,CLR_HRED) //"Vermelhor - Fora dos Conformes"

					oPrint:EndPage()

					TNN->( dbSkip() )

				End
		Endif
Endif


If lImp
//Imprime na Tela ou Impressora
	If aReturn[5] == 1
		oPrint:Preview()
	Else
		oPrint:Print()
	EndIf
Else
	MsgStop(STR0038,STR0039)//"Não existem dados para montar o Quadro Comparativo."##"ATENÇÃO"
Endif
MS_FLUSH()
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fCabec931(oPrint)
Imprrime Cabeçalho

@author Guilherme Freudenburg
@since 31/01/2014
@return
/*/
//---------------------------------------------------------------------

Static Function fCabec931(oPrint,oFont07)

Local cFonte 	:= "Verdana"
Local oFont09	:= TFont():New(cFonte,09,09,,.T.,,,,.F.,.F.)

	// Coluna 1
	oPrint:Say(lin+60	,290	,STR0006	,oFont09	)//"GRUPOS"
	oPrint:Line(lin		,460	,lin+180	,460		)//linha vertical
	oPrint:Line(lin		,275 	,lin		,2300 		)//linha superior
	oPrint:Line(lin+180	,275 	,lin+180	,2300 		)//linha inferior
	oPrint:Line(lin		,275	,lin+180	,275 		)//linha vertical
	oPrint:Line(lin		,750	,lin+180	,750 		)//linha vertica
	// Coluna 2
	oPrint:Say (lin+15	,590 	,STR0007	,oFont07	) //"Nº de"
	oPrint:Say (lin+45	,500	,STR0008	,oFont07	) //"Empregados no"
	oPrint:Say (lin+75	,500	,STR0009	,oFont07	) //"Estabelecimento"
	oPrint:Say (lin+105	,500	,STR0010	,oFont07	) //"Nº de Membros"
	oPrint:Say (lin+135	,500	,STR0011	,oFont07	) //"da CIPA"
	//Coluna 3
	oPrint:Say(lin+20   ,790	,"0"   		,oFont07	)
	oPrint:Say(lin+60	,790	,STR0012	,oFont07	) //"a"
	oPrint:Say(lin+110	,780	,"19"  		,oFont07	)
	oPrint:Line(lin		,840	,lin+180	,840	 	) //linha vertical
	//Coluna 4
	oPrint:Say(lin+20  	,860	,"20"  		,oFont07	)
	oPrint:Say(lin+60 	,870	,STR0012	,oFont07	)	//"a"
	oPrint:Say(lin+110	,860	,"29"  		,oFont07	)
	oPrint:Line(lin		,930 	,lin+180	,930	 	) 	//linha vertical
	//Coluna 5
	oPrint:Say(lin+20   ,950	,"30"  		,oFont07	)
	oPrint:Say(lin+60 	,960	,STR0012	,oFont07	) //"a"
	oPrint:Say(lin+110	,950	,"50"  		,oFont07	)
	oPrint:Line(lin		,1020 	,lin+180	,1020 	 	) //linha vertical
	//Coluna 6
	oPrint:Say(lin+20   ,1040	,"51"  		,oFont07	)
	oPrint:Say(lin+60 	,1050	,STR0012	,oFont07	) //"a"
	oPrint:Say(lin+110	,1040	,"80"		,oFont07	)
	oPrint:Line(lin		,1110	,lin+180	,1110 	 	) //linha vertical
	//Coluna 7
	oPrint:Say(lin+20   ,1120	,"81"		,oFont07	)
	oPrint:Say(lin+60 	,1130	,STR0012	,oFont07	) //"a"
	oPrint:Say(lin+110	,1120	,"100"		,oFont07	)
	oPrint:Line(lin		,1200	,lin+180	,1200 	 	) //linha vertical
	//Coluna 8
	oPrint:Say(lin+20   ,1220	,"101"		,oFont07	)
	oPrint:Say(lin+60 	,1230	,STR0012	,oFont07	) //"a"
	oPrint:Say(lin+110	,1220	,"120"		,oFont07	)
	oPrint:Line(lin	 	,1290 	,lin+180	,1290 	 	) //linha vertical
	//Coluna 9
	oPrint:Say(lin+20   ,1310	,"121"		,oFont07	)
	oPrint:Say(lin+60 	,1320	,STR0012	,oFont07	)	//"a"
	oPrint:Say(lin+110	,1310	,"140"		,oFont07	)
	oPrint:Line(lin		,1380	,lin+180	,1380 	 	)	//linha vertical
	//Coluna 10
	oPrint:Say(lin+20   ,1400	,"141"		,oFont07	)
	oPrint:Say(lin+60 	,1410	,STR0012	,oFont07	)	//"a"
	oPrint:Say(lin+110	,1400	,"300"		,oFont07	)
	oPrint:Line(lin		,1470	,lin+180	,1470 	 	)	//linha vertical
	//Coluna 11
	oPrint:Say(lin+20   ,1490	,"301"		,oFont07	)
	oPrint:Say(lin+60 	,1510	,STR0012	,oFont07	)	//"a"
	oPrint:Say(lin+110	,1490	,"500"		,oFont07	)
	oPrint:Line(lin		,1560	,lin+180	,1560 	 	)	//linha vertical
	//Coluna 12
	oPrint:Say(lin+20   ,1590	,"501"		,oFont07	)
	oPrint:Say(lin+60 	,1610	,STR0012	,oFont07	) //"a"
	oPrint:Say(lin+110	,1590	,"1000"		,oFont07	)
	oPrint:Line(lin		,1680	,lin+180	,1680 	 	) //linha vertical
	//Coluna 13
	oPrint:Say(lin+20   ,1710	,"1001"		,oFont07	)
	oPrint:Say(lin+60 	,1730	,STR0012	,oFont07	) //"a"
	oPrint:Say(lin+110	,1710	,"2500"		,oFont07	)
	oPrint:Line(lin		,1800	,lin+180	,1800 	 	) //linha vertical
	//Coluna 14
	oPrint:Say(lin+20   ,1830	,"2501"		,oFont07	)
	oPrint:Say(lin+60 	,1850	,STR0012	,oFont07	) //"a"
	oPrint:Say(lin+110	,1830	,"5000"		,oFont07	)
	oPrint:Line(lin		,1920	,lin+180	,1920 	 	)  //linha vertical
	//Coluna 15
	oPrint:Say(lin+20   ,1940	,"5001"	,oFont07		)
	oPrint:Say(lin+60 	,1960	,STR0012	,oFont07	) //"a"
	oPrint:Say(lin+110	,1940	,"10.000"	,oFont07	)
	oPrint:Line(lin		,2050	,lin+180	,2050 	 	) //linha vertical
	//Coluna 16
	oPrint:Say(lin+15   ,2080	,STR0013	,oFont07	) //"Acima de"
	oPrint:Say(lin+45 	,2080	,STR0014	,oFont07	) //"10.000 para"
	oPrint:Say(lin+75	,2080	,STR0015	,oFont07	) //"cada grupo de"
	oPrint:Say(lin+105	,2080	,STR0016	,oFont07	) //"2.500"
	oPrint:Say(lin+135	,2080	,STR0017	,oFont07	) //"acrescentar"
	oPrint:Line(lin		,2300 	,lin+180	,2300 	 	) //linha vertical
	lin+=60
	Somalinha(oPrint)
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} Somalinha(oPrint,nLin)
Realiza salto de linha

@author Guilherme Freudenburg
@since 31/01/2014
@return
/*/
//---------------------------------------------------------------------
Static Function Somalinha(oPrint,nLin)
Default nLin    := 120

lin += nLin

If lin > 3000
	oPrint:EndPage()
	oPrint:StartPage()
	lin := 100
EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fCalc931()
Calcula a quantidade de Efetivos e Suplentes

@author Guilherme Freudenburg
@since 31/01/2014
@return
/*/
//---------------------------------------------------------------------
Static Function fCalc931( aQuadroI , nEfet , nSupl , nNeceEfet , nNeceSupl , nQuantFunc )

Local nQuadroE
Local nQuadroS
Local nNum:=0
Local nTotFunc
Local nFunc10E
Local nFunc10S

//Define os novos Alias
Local cAliasSRA := GetNextAlias()
Local cAliasTNQ := GetNextAlias()
Local cAliasTNQ2 := GetNextAlias()

	cTabSRA := RetSqlName("SRA")
	//Consulta para trazer total de funcionários ativos.
	cQuery := "SELECT COUNT(*) AS QTFUNC "
	cQuery += "FROM " + cTabSRA + " SRA "
	cQuery += "WHERE SRA.D_E_L_E_T_ <> '*' AND "
	cQuery +="(SRA.RA_ADMISSA <= "+ValToSql(TNN->TNN_DTTERM)+") AND "
	If !Empty(TNN->TNN_CC)
		cQuery +="(SRA.RA_CC = "+ValToSql(TNN->TNN_CC)+") AND "
	EndIf
	cQuery +="(SRA.RA_SITFOLH <> 'D' OR SRA.RA_DEMISSA = '' OR SRA.RA_DEMISSA >= "+ValToSql(TNN->TNN_DTINIC)+") AND "
	cQuery += "(SRA.RA_FILIAL = " + ValToSql( xFilial("SRA") ) + ")"
	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery( cQuery , cAliasSRA )

	nQuantFunc := ( cAliasSRA )->QTFUNC

	If nQuantFunc > 0 .And. nQuantFunc <= 19
		nNum:=2
	ElseIf nQuantFunc > 19 .And. nQuantFunc <= 29
		nNum:=3
	ElseIf nQuantFunc > 29 .And. nQuantFunc <= 50
		nNum:=4
	ElseIf nQuantFunc > 50 .And. nQuantFunc <= 80
		nNum:=5
	ElseIf nQuantFunc > 80 .And. nQuantFunc <= 100
		nNum:=6
	ElseIf nQuantFunc > 100 .And. nQuantFunc <= 120
		nNum:=7
	ElseIf nQuantFunc > 120 .And. nQuantFunc <= 140
		nNum:=8
	ElseIf nQuantFunc > 140 .And. nQuantFunc <= 300
		nNum:=9
	ElseIf nQuantFunc > 300 .And. nQuantFunc <= 500
		nNum:=10
	ElseIf nQuantFunc > 500 .And. nQuantFunc <= 1000
		nNum:=11
	ElseIf nQuantFunc > 1000 .And. nQuantFunc <= 2500
		nNum:=12
	ElseIf nQuantFunc > 2500 .And. nQuantFunc <= 5000
		nNum:=13
	ElseIf nQuantFunc > 5000 .And. nQuantFunc <= 10000
		nNum:=14
	Else
		nNum:=_nAcimPos_
	Endif

	cTabTNQ := RetSqlName("TNQ")
	//Consulta para verificar a quantidade de componentes efetivos da CIPA
	cQuery := "SELECT COUNT(*) AS QTCOMP1 "
	cQuery += "FROM " + cTabTNQ + " TNQ "
	cQuery += "WHERE TNQ.D_E_L_E_T_ != '*' AND "
	cQuery += "(TNQ.TNQ_DTSAID = '' AND TNQ.TNQ_TIPCOM = '1') AND"
	cQuery +="(TNQ.TNQ_MANDAT ="+ValToSql(TNN->TNN_MANDAT)+")"
	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery( cQuery , cAliasTNQ )
	nEfet := ( cAliasTNQ )->QTCOMP1//Quantidade de efetivos real

	cTabTNQ := RetSqlName("TNQ")
	//Consulta para verificar a quantidade de componentes suplentes da CIPA
	cQuery := "SELECT COUNT(*) AS QTCOMP2 "
	cQuery += "FROM " + cTabTNQ + " TNQ "
	cQuery += "WHERE TNQ.D_E_L_E_T_ != '*' AND "
	cQuery += "(TNQ.TNQ_DTSAID = '' AND TNQ.TNQ_TIPCOM = '2') AND"
	cQuery +="(TNQ.TNQ_MANDAT ="+ValToSql(TNN->TNN_MANDAT)+")"
	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery( cQuery , cAliasTNQ2 )
	nSupl := ( cAliasTNQ2 )->QTCOMP2//Quantidade real de suplentes

	nQuadroE:= aSCAN( aQuadroI, {|x| Alltrim(x[1]) == Alltrim(TOE->TOE_GRUPO) .and. (x[_nTipoPos_]) == 1 } )
	nQuadroS:= aSCAN( aQuadroI, {|x| Alltrim(x[1]) == Alltrim(TOE->TOE_GRUPO) .and. (x[_nTipoPos_]) == 2 } )

	If (nNum == _nAcimPos_) //Se a quantidade de funcionários ultrapassa a quantidade de 10.000 conforme a NR5
		nTotFunc:=nQuantFunc - 10000//Verifica a quantidade a mais
		nTotFunc:=nTotFunc / 2500 // a cada 2500 recebe um valor de componentes da CIPA
		nTotFunc:=Ceiling(nTotFunc)

		nFunc10E :=Val(aQuadroI[nQuadroE,_nAcimPos_])
		nFunc10S :=Val(aQuadroI[nQuadroS,_nAcimPos_])

		nFunc10E:=(nFunc10E * nTotFunc)//Multiplica para obter a quantidade necessaria a mais
		nFunc10S:=(nFunc10S * nTotFunc)//Multiplica para obter a quantidade necessaria a mais

		nNeceEfet:=Val(aQuadroI[nQuadroE,14])//pega o valor do array conforme a posição
		nNeceSupl:=Val(aQuadroI[nQuadroS,14])//pega valor do array conforme a posição

		nNeceEfet:=(nNeceEfet+nFunc10E)
		nNeceSupl:=(nNeceSupl+nFunc10S)

	Else
		nNeceEfet:=Val(aQuadroI[nQuadroE,nNum])//pega o valor do array conforme a posição
		nNeceSupl:=Val(aQuadroI[nQuadroS,nNum])//pega valor do array conforme a posição
	Endif

	(cAliasSRA)->(dbCloseArea())
	(cAliasTNQ)->(dbCloseArea())
	(cAliasTNQ2)->(dbCloseArea())

Return()
//---------------------------------------------------------------------
/*/{Protheus.doc} fMontaQuadro()
Monta o quadro contido na NR5

@param aQuadroI - Array que irá receber as informações

@author Guilherme Freudenburg
@since 31/01/2014
@return
/*/
//---------------------------------------------------------------------
Static Function fMontaQuadro( aQuadroI )

	aAdd( aQuadroI, { "C-1",   "",  "1", "1", "3", "3", "4", "4", "4", "4", "6", "9",  "12", "15", "2", 1, .T. } ) //"C-1"
	aAdd( aQuadroI, { "C-1",   "",  "1", "1", "3", "3", "3", "3", "3", "3", "4", "7",  "9",  "12", "2", 2, .F. } ) //"C-1"
	aAdd( aQuadroI, { "C-1a",  "",  "1", "1", "3", "3", "4", "4", "4", "4", "6", "9",  "12", "15", "2", 1, .F. } ) //"C-1a"
	aAdd( aQuadroI, { "C-1a",  "",  "1", "1", "3", "3", "3", "3", "3", "4", "5", "8",  "9",  "12", "2", 2, .F. } ) //"C-1a"
	aAdd( aQuadroI, { "C-2",   "",  "1", "1", "2", "2", "3", "4", "4", "5", "6", "7",  "10", "11", "2", 1, .F. } ) //"C-2"
	aAdd( aQuadroI, { "C-2",   "",  "1", "1", "2", "2", "3", "3", "4", "4", "5", "6",  "7",  "9",  "1", 2, .F. } ) //"C-2"
	aAdd( aQuadroI, { "C-3",   "",  "1", "1", "2", "2", "3", "3", "4", "5", "6", "7",  "10", "10", "2", 1, .F. } ) //"C-3"
	aAdd( aQuadroI, { "C-3",   "",  "1", "1", "2", "2", "3", "3", "4", "4", "5", "6",  "8",  "8",  "2", 2, .F. } ) //"C-3"
	aAdd( aQuadroI, { "C-3a",  "",  "",  "",  "1", "1", "2", "2", "2", "3", "3", "4",  "5",  "6",  "1", 1, .F. } ) //"C-3a"
	aAdd( aQuadroI, { "C-3a",  "",  "",  "",  "1", "1", "2", "2", "2", "3", "3", "3",  "4",  "5",  "1", 2, .F. } ) //"C-3a"
	aAdd( aQuadroI, { "C-4",   "",  "",  "1", "1", "1", "1", "1", "2", "2", "2", "3",  "5",  "6",  "1", 1, .F. } ) //"C-4"
	aAdd( aQuadroI, { "C-4",   "",  "",  "1", "1", "1", "1", "1", "2", "2", "2", "3",  "4",  "4",  "1", 2, .F. } ) //"C-4"
	aAdd( aQuadroI, { "C-5",   "",  "1", "1", "2", "3", "3", "4", "4", "4", "6", "9",  "9",  "11", "2", 1, .F. } ) //"C-5"
	aAdd( aQuadroI, { "C-5",   "",  "1", "1", "2", "3", "3", "3", "4", "4", "5", "7",  "7",  "9",  "2", 2, .F. } ) //"C-5"
	aAdd( aQuadroI, { "C-5a",  "",  "",  "",  "1", "1", "2", "2", "2", "3", "3", "4",  "6",  "7",  "1", 1, .F. } ) //"C-5a"
	aAdd( aQuadroI, { "C-5a",  "",  "",  "",  "1", "1", "2", "2", "2", "3", "3", "3",  "4",  "5",  "1", 2, .F. } ) //"C-5a"
	aAdd( aQuadroI, { "C-6",   "",  "1", "1", "2", "3", "3", "4", "5", "5", "6", "8",  "10", "12", "2", 1, .F. } ) //"C-6"
	aAdd( aQuadroI, { "C-6",   "",  "1", "1", "2", "3", "3", "3", "4", "4", "4", "6",  "8",  "10", "2", 2, .F. } ) //"C-6"
	aAdd( aQuadroI, { "C-7",   "",  "",  "",  "1", "1", "2", "2", "2", "2", "3", "4",  "5",  "6",  "1", 1, .T. } ) //"C-7"
	aAdd( aQuadroI, { "C-7",   "",  "",  "",  "1", "1", "2", "2", "2", "2", "3", "3",  "4",  "4",  "1", 2, .F. } ) //"C-7"
	aAdd( aQuadroI, { "C-7a",  "",  "1", "1", "2", "2", "3", "3", "4", "5", "6", "8",  "9",  "10", "2", 1, .F. } ) //"C-7a"
	aAdd( aQuadroI, { "C-7a",  "",  "1", "1", "2", "2", "3", "3", "3", "4", "5", "7",  "8",  "8",  "2", 2, .F. } ) //"C-7a"
	aAdd( aQuadroI, { "C-8",   "",  "1", "1", "2", "2", "3", "3", "4", "5", "6", "7",  "8",  "10", "1", 1, .F. } ) //"C-8"
	aAdd( aQuadroI, { "C-8",   "",  "1", "1", "2", "2", "3", "3", "3", "4", "4", "5",  "6",  "8",  "1", 2, .F. } ) //"C-8"
	aAdd( aQuadroI, { "C-9",   "",  "",  "",  "1", "1", "1", "2", "2", "2", "3", "5",  "6",  "7",  "1", 1, .F. } ) //"C-9"
	aAdd( aQuadroI, { "C-9",   "",  "",  "",  "1", "1", "1", "2", "2", "2", "3", "4",  "4",  "5",  "1", 2, .F. } ) //"C-9"
	aAdd( aQuadroI, { "C-10",  "",  "1", "1", "2", "2", "3", "3", "4", "4", "5", "8",  "9",  "10", "2", 1, .F. } ) //"C-10"
	aAdd( aQuadroI, { "C-10",  "",  "1", "1", "2", "2", "3", "3", "3", "4", "4", "6",  "7",  "8",  "2", 2, .F. } ) //"C-10"
	aAdd( aQuadroI, { "C-11",  "",  "1", "1", "2", "3", "3", "4", "4", "5", "6", "9",  "10", "12", "2", 1, .F. } ) //"C-11"
	aAdd( aQuadroI, { "C-11",  "",  "1", "1", "2", "3", "3", "3", "3", "4", "4", "7",  "8",  "10", "2", 2, .F. } ) //"C-11"
	aAdd( aQuadroI, { "C-12",  "",  "1", "1", "2", "3", "3", "4", "4", "5", "7", "8",  "9",  "10", "2", 1, .F. } ) //"C-12"
	aAdd( aQuadroI, { "C-12",  "",  "1", "1", "2", "3", "3", "3", "3", "4", "6", "6",  "7",  "8",  "2", 2, .F. } ) //"C-12"
	aAdd( aQuadroI, { "C-13",  "",  "1", "1", "3", "3", "3", "3", "4", "5", "6", "9", "11",  "13", "2", 1, .F. } ) //"C-13"
	aAdd( aQuadroI, { "C-13",  "",  "1", "1", "3", "3", "3", "3", "3", "4", "5", "7",  "8",  "10", "2", 2, .F. } ) //"C-13"
	aAdd( aQuadroI, { "C-14",  "",  "1", "1", "2", "2", "3", "4", "4", "5", "6", "9",  "11", "11", "2", 1, .F. } ) //"C-14"
	aAdd( aQuadroI, { "C-14",  "",  "1", "1", "2", "2", "3", "3", "4", "4", "5", "7",  "9",  "9",  "2", 2, .F. } ) //"C-14"
	aAdd( aQuadroI, { "C-14a", "",  "",  "",  "1", "1", "2", "2", "2", "3", "3", "4",  "5",  "6",  "1", 1, .F. } ) //"C-14a"
	aAdd( aQuadroI, { "C-14a", "",  "",  "",  "1", "1", "2", "2", "2", "3", "3", "3",  "4",  "4",  "1", 2, .F. } ) //"C-14a"
	aAdd( aQuadroI, { "C-15",  "",  "1", "1", "3", "3", "4", "4", "4", "5", "6", "8",  "10", "12", "2", 1, .F. } ) //"C-15"
	aAdd( aQuadroI, { "C-15",  "",  "1", "1", "3", "3", "3", "3", "3", "4", "4", "6",  "8",  "10", "2", 2, .F. } ) //"C-15"
	aAdd( aQuadroI, { "C-16",  "",  "1", "1", "2", "3", "3", "3", "4", "5", "6", "8",  "10", "12", "2", 1, .F. } ) //"C-16"
	aAdd( aQuadroI, { "C-16",  "",  "1", "1", "2", "3", "3", "3", "3", "4", "4", "6",  "7",  "9",  "2", 2, .F. } ) //"C-16"
	aAdd( aQuadroI, { "C-17",  "",  "1", "1", "2", "2", "4", "4", "4", "4", "6", "8",  "10", "12", "2", 1, .F. } ) //"C-17"
	aAdd( aQuadroI, { "C-17",  "",  "1", "1", "2", "2", "3", "3", "3", "4", "5", "7",  "8",  "10", "2", 2, .F. } ) //"C-17"
	aAdd( aQuadroI, { "C-18",  "",  "",  "",  "2", "2", "4", "4", "4", "4", "6", "8",  "10", "12", "2", 1, .F. } ) //"C-18"
	aAdd( aQuadroI, { "C-18",  "",  "",  "",  "2", "2", "3", "3", "3", "4", "5", "7",  "8",  "10", "2", 2, .F. } ) //"C-18"
	aAdd( aQuadroI, { "C-18a", "",  "",  "",  "3", "3", "4", "4", "4", "4", "6", "9",  "12", "15", "2", 1, .F. } ) //"C-18a"
	aAdd( aQuadroI, { "C-18a", "",  "",  "",  "3", "3", "3", "3", "3", "4", "5", "7",  "9",  "12", "2", 2, .F. } ) //"C-18a"
	aAdd( aQuadroI, { "C-19",  "",  "",  "",  "1", "1", "2", "2", "2", "3", "3", "4",  "5",  "6",  "1", 1, .F. } ) //"C-19"
	aAdd( aQuadroI, { "C-19",  "",  "",  "",  "1", "1", "2", "2", "2", "3", "3", "3",  "4",  "4",  "1", 2, .F. } ) //"C-19"
	aAdd( aQuadroI, { "C-20",  "",  "",  "1", "1", "3", "3", "3", "3", "4", "5", "5",  "6",  "8",  "2", 1, .F. } ) //"C-20"
	aAdd( aQuadroI, { "C-20",  "",  "",  "1", "1", "3", "3", "3", "3", "3", "4", "4",  "5",  "6",  "1", 2, .F. } ) //"C-20"
	aAdd( aQuadroI, { "C-21",  "",  "",  "",  "1", "1", "2", "2", "2", "3", "3", "4",  "5",  "6",  "1", 1, .F. } ) //"C-21"
	aAdd( aQuadroI, { "C-21",  "",  "",  "",  "1", "1", "2", "2", "2", "3", "3", "3",  "4",  "5",  "1", 2, .F. } ) //"C-21"
	aAdd( aQuadroI, { "C-22",  "",  "1", "1", "2", "2", "3", "3", "4", "4", "6", "8",  "10", "12", "2", 1, .F. } ) //"C-22"
	aAdd( aQuadroI, { "C-22",  "",  "1", "1", "2", "2", "3", "3", "3", "3", "5", "6",  "8",  "9",  "2", 2, .F. } ) //"C-22"
	aAdd( aQuadroI, { "C-23",  "",  "",  "",  "1", "1", "2", "2", "2", "2", "3", "4",  "5",  "6",  "1", 1, .T. } ) //"C-23"
	aAdd( aQuadroI, { "C-23",  "",  "",  "",  "1", "1", "2", "2", "2", "2", "3", "3",  "4",  "5",  "1", 2, .F. } ) //"C-23"
	aAdd( aQuadroI, { "C-24",  "",  "1", "1", "2", "2", "4", "4", "4", "4", "6", "8",  "10", "12", "2", 1, .F. } ) //"C-24"
	aAdd( aQuadroI, { "C-24",  "",  "1", "1", "2", "2", "3", "3", "4", "4", "5", "7",  "8",  "10", "2", 2, .F. } ) //"C-24"
	aAdd( aQuadroI, { "C-24a", "",  "",  "",  "1", "1", "2", "2", "2", "2", "3", "4",  "5",  "6",  "1", 1, .F. } ) //"C-24a"
	aAdd( aQuadroI, { "C-24a", "",  "",  "",  "1", "1", "2", "2", "2", "2", "3", "3",  "4",  "4",  "1", 2, .F. } ) //"C-24a"
	aAdd( aQuadroI, { "C-24b", "",  "1", "1", "3", "3", "4", "4", "4", "4", "6", "9",  "12", "15", "2", 1, .F. } ) //"C-24b"
	aAdd( aQuadroI, { "C-24b", "",  "1", "1", "3", "3", "3", "3", "3", "3", "4", "7",  "9",  "12", "2", 2, .F. } ) //"C-24b"
	aAdd( aQuadroI, { "C-24c", "",  "",  "",  "1", "1", "2", "2", "2", "2", "4", "5",  "7",  "7",  "1", 1, .F. } ) //"C-24c"
	aAdd( aQuadroI, { "C-24c", "",  "",  "",  "1", "1", "1", "1", "2", "2", "4", "5",  "7",  "7",  "1", 2, .F. } ) //"C-24c"
	aAdd( aQuadroI, { "C-24d", "",  "",  "",  "1", "1", "2", "2", "2", "3", "4", "5",  "7",  "9",  "1", 1, .F. } ) //"C-24d"
	aAdd( aQuadroI, { "C-24d", "",  "",  "",  "1", "1", "1", "1", "2", "2", "4", "5",  "7",  "9",  "1", 2, .F. } ) //"C-24d"
	aAdd( aQuadroI, { "C-25",  "",  "",  "",  "1", "1", "2", "2", "2", "2", "3", "4",  "5",  "6",  "1", 1, .F. } ) //"C-25"
	aAdd( aQuadroI, { "C-25",  "",  "",  "",  "1", "1", "2", "2", "2", "2", "3", "3",  "4",  "5",  "1", 2, .F. } ) //"C-25"
	aAdd( aQuadroI, { "C-26",  "",  "",  "",  "",  "",  "",  "",  "",  "1", "2", "3",  "4",  "5",  "1", 1, .F. } ) //"C-26"
	aAdd( aQuadroI, { "C-26",  "",  "",  "",  "",  "",  "",  "",  "",  "1", "2", "3",  "3",  "4",  "1", 2, .F. } ) //"C-26"
	aAdd( aQuadroI, { "C-27",  "",  "",  "",  "",  "",  "1", "1", "2", "3", "4", "5",  "6",  "6",  "1", 1, .F. } ) //"C-27"
	aAdd( aQuadroI, { "C-27",  "",  "",  "",  "",  "",  "1", "1", "2", "3", "3", "4",  "5",  "5",  "1", 2, .F. } ) //"C-27"
	aAdd( aQuadroI, { "C-28",  "",  "",  "",  "",  "",  "1", "1", "2", "3", "4", "5",  "6",  "6",  "1", 1, .F. } ) //"C-28"
	aAdd( aQuadroI, { "C-28",  "",  "",  "",  "",  "",  "1", "1", "2", "3", "4", "5",  "5",  "5",  "1", 2, .F. } ) //"C-28"
	aAdd( aQuadroI, { "C-29",  "",  "",  "",  "",  "",  "",  "",  "",  "1", "2", "3",  "4",  "5",  "1", 1, .F. } ) //"C-29"
	aAdd( aQuadroI, { "C-29",  "",  "",  "",  "",  "",  "",  "",  "",  "1", "2", "3",  "3",  "4",  "1", 2, .F. } ) //"C-29"
	aAdd( aQuadroI, { "C-30",  "",  "1", "1", "1", "2", "4", "4", "4", "5", "7", "8",  "9",  "10", "2", 1, .F. } ) //"C-30"
	aAdd( aQuadroI, { "C-30",  "",  "1", "1", "1", "2", "3", "3", "4", "4", "6", "7",  "8",  "9",  "1", 2, .F. } ) //"C-30"
	aAdd( aQuadroI, { "C-31",  "",  "",  "",  "1", "1", "2", "2", "2", "3", "3", "4",  "5",  "6",  "1", 1, .F. } ) //"C-31"
	aAdd( aQuadroI, { "C-31",  "",  "",  "",  "1", "1", "2", "2", "2", "3", "3", "3",  "4",  "5",  "1", 2, .F. } ) //"C-31"
	aAdd( aQuadroI, { "C-32",  "",  "",  "",  "1", "1", "2", "2", "2", "3", "3", "4",  "5",  "6",  "1", 1, .F. } ) //"C-32"
	aAdd( aQuadroI, { "C-32",  "",  "",  "",  "1", "1", "2", "2", "2", "3", "3", "3",  "4",  "5",  "1", 2, .F. } ) //"C-32"
	aAdd( aQuadroI, { "C-33",  "",  "",  "",  "",  "",  "1", "1", "1", "1", "2", "3",  "4",  "5",  "1", 1, .F. } ) //"C-33"
	aAdd( aQuadroI, { "C-33",  "",  "",  "",  "",  "",  "1", "1", "1", "1", "2", "3",  "3",  "4",  "1", 2, .F. } ) //"C-33"
	aAdd( aQuadroI, { "C-34",  "",  "1", "1", "2", "2", "4", "4", "4", "4", "6", "8",  "10", "12", "2", 1, .F. } ) //"C-34"
	aAdd( aQuadroI, { "C-34",  "",  "1", "1", "2", "2", "3", "3", "3", "4", "5", "7",  "8",  "9",  "2", 2, .F. } ) //"C-34"
	aAdd( aQuadroI, { "C-35",  "",  "",  "",  "1", "1", "2", "2", "2", "2", "3", "4",  "5",  "6",  "1", 1, .F. } ) //"C-35"
	aAdd( aQuadroI, { "C-35",  "",  "",  "",  "1", "1", "2", "2", "2", "2", "3", "3",  "4",  "5",  "1", 2, .F. } ) //"C-35"

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTAliTOK
Função para alimentar automaticamente
a tabela TOK (Grupo de Atividades Econômicas)

@author Guilherme Freudenburg
@since 12/02/2014
@return .T.
/*/
//---------------------------------------------------------------------
Function MDTAliTOK()

Local aAuto:={}//array que receberá os valores
Local nX:=0 //variavel de controle

aAdd( aAuto , {"C-1"		,STR0042})	//"MINERAIS"
aAdd( aAuto , {"C-1a"		,STR0042})	//"MINERAIS"
aAdd( aAuto , {"C-2" 		,STR0043})	//"ALIMENTOS"
aAdd( aAuto , {"C-3"  	,STR0044})	//"TÊXTEIS"
aAdd( aAuto , {"C-3a" 	,STR0044})	//"TÊXTEIS"
aAdd( aAuto , {"C-4"  	,STR0045}) //"CONFECÇÃO"
aAdd( aAuto , {"C-5"  	,STR0046})	//"CALÇADOS E SIMILARES"
aAdd( aAuto , {"C-5a" 	,STR0046}) //"CALÇADOS E SIMILARES"
aAdd( aAuto , {"C-6"  	,STR0047}) //"MADEIRA"
aAdd( aAuto , {"C-7"  	,STR0048}) //"PAPEL"
aAdd( aAuto , {"C-7a" 	,STR0048}) //"PAPEL"
aAdd( aAuto , {"C-8"  	,STR0049})	//"GRÁFICOS"
aAdd( aAuto , {"C-9" 		,STR0050})	//"SOM E IMAGEM"
aAdd( aAuto , {"C-10" 	,STR0051}) //"QUÍMICOS"
aAdd( aAuto , {"C-11" 	,STR0052}) //"BORRACHA"
aAdd( aAuto , {"C-14" 	,STR0053})	//"EQUIPAMENTOS/MÁQUINAS E FERRAMENTAS"
aAdd( aAuto , {"C-15" 	,STR0054}) //"EXPLOSIVOS E ARMAS"
aAdd( aAuto , {"C-16" 	,STR0055}) //"VEÍCULOS"
aAdd( aAuto , {"C-17" 	,STR0056})	//"ÁGUA E ENERGIA"
aAdd( aAuto , {"C-18" 	,STR0057})	//"CONSTRUÇÃO"
aAdd( aAuto , {"C-18a" 	,STR0057}) //"CONSTRUÇÃO"
aAdd( aAuto , {"C-19" 	,STR0058})	//"INTERMEDIÁRIOS DO COMÉRCIO"
aAdd( aAuto , {"C-20" 	,STR0059}) //"COMÉRCIO ATACADISTA"
aAdd( aAuto , {"C-21" 	,STR0060}) //"COMÉRCIO VAREJISTA"
aAdd( aAuto , {"C-22" 	,STR0061})	//"COMÉRCIO DE PRODUTOS PERIGOSOS"
aAdd( aAuto , {"C-23" 	,STR0062}) //"ALOJAMENTO E ALIMENTAÇÃO"
aAdd( aAuto , {"C-24" 	,STR0063}) //"TRANSPORTE"
aAdd( aAuto , {"C-24a"	,STR0063}) //"TRANSPORTE"
aAdd( aAuto , {"C-24B" 	,STR0063}) //"TRANSPORTE"
aAdd( aAuto , {"C-24C" 	,STR0063})	//"TRANSPORTE"
aAdd( aAuto , {"C-24D" 	,STR0063})	//"TRANSPORTE"
aAdd( aAuto , {"C-25" 	,STR0064})	//"CORREIO E TELECOMUNICAÇÕES"
aAdd( aAuto , {"C-26" 	,STR0065})	//"SEGURO"
aAdd( aAuto , {"C-27" 	,STR0066})	//"ADMINISTRAÇÃO DE MERCADOS FINANCEIROS"
aAdd( aAuto , {"C-28" 	,STR0067})	//"BANCOS"
aAdd( aAuto , {"C-29" 	,STR0068})	//"SERVIÇOS"
aAdd( aAuto , {"C-30" 	,STR0069})	//"LOCAÇÃO DE MÃO-DE-OBRA E LIMPEZA"
aAdd( aAuto , {"C-31" 	,STR0070})	//"ENSINO"
aAdd( aAuto , {"C-32" 	,STR0071})	//"PESQUISAS"
aAdd( aAuto , {"C-33" 	,STR0072})	//"ADMINISTRAÇÃO PÚBLICA"
aAdd( aAuto , {"C-34" 	,STR0073})	//"SAÚDE"
aAdd( aAuto , {"C-35" 	,STR0074})	//"OUTROS SERVIÇOS"

DbselectArea("TOK")
	If TOK->(RecCount()) == 0
		For nX:= 1 To Len(aAuto)
			RecLock("TOK",.T.)
			TOK->TOK_FILIAL:=xFilial("TOK")
			TOK->TOK_GRUPO:=aAuto[nX,1]
			TOK->TOK_DESCRI:=aAuto[nX,2]
			TOK->(MsUnlock())
		Next nX
	Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidMV2
Função criada para validar o Mv_par02 ,
Até Mandato.

@author Guilherme Freudenburg
@since 12/02/2014
@return .T.
/*/
//---------------------------------------------------------------------
Function MDT931VLD(nPar)

	Local lRet:=.T.

	If nPar == 1
		If !Empty( MV_PAR01 ) .And. !ExistCpo( "TNN" ,MV_PAR01)
			lRet:= .F.
		EndIf
		If !Empty( MV_PAR02 )
			If MV_PAR02 < MV_PAR01
				ShowHelpDlg(STR0039,{STR0075},2,{STR0076},2)//ATENÇÂO ## "Para a opção de Paramêtro de Até no arquivo de Perguntas, esta opção é inválida." ## "Informe uma opção válida para este parâmetro."
				lRet:=.F.
			Endif
		EndIf
	Else
		If MV_PAR02 <> Replicate('Z',Len(MV_PAR02)) .And. !ExistCpo( "TNN" ,MV_PAR02)
			lRet:= .F.
		EndIf
		If MV_PAR02 < MV_PAR01
			ShowHelpDlg(STR0039,{STR0075},2,{STR0076},2)//ATENÇÂO ## "Para a opção de Paramêtro de Até no arquivo de Perguntas, esta opção é inválida." ## "Informe uma opção válida para este parâmetro."
			lRet:=.F.
		Endif
	EndIf

Return lRet