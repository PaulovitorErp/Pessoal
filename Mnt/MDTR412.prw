#Include "Protheus.ch"
#INCLUDE "MDTR412.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR412
Realiza a impressão da Ficha de Avaliação de EPI com as Respostas dos Funcionário

@return Nil

@sample MDTR412()

@author Jackson Machado
@since 08/02/2016
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDTR412( aDados )

	//-----------------------------------------------
	// Guarda conteudo e declara variaveis padroes
	//-----------------------------------------------
	Local aNGBEGINPRM := NGBEGINPRM( )

	//-----------------------------------------------
	// Define Variaveis
	//-----------------------------------------------
	Local nFor
	Local limite  := 132
	Local wnrel   := "MDTR412"
	Local cDesc1  := STR0001 //"Relatório de apresentação do questionário e suas respostas das "
	Local cDesc2  := STR0002 //"Avaliações respondidas pelos funcionários sobre os EPIs fornecidos."
	Local cDesc3  := ""
	Local cString := "TY8"

	Private cabec1, cabec2
	Private aDad145
	Private nomeprog 	:= "MDTR412"
	Private tamanho  	:= "G"
	Private aReturn  	:= { "Zebrado" , 1 , "Administracao" , 1 , 2 , 1 , "" , 1 }
	Private titulo   	:= STR0003 //"Avaliação de EPI"
	Private ntipo    	:= 0
	Private nLastKey 	:= 0
	Private cPerg    	:= PadR( "MDT412" , 10 )
	Private aPerg	 	:= {}
	Private aQuesSelc	:= {}
	Private nLinhaTot	:= 3550
	Private lSigaMDTPs	:= SuperGetMv( "MV_MDTPS" , .F. , "N" ) == "S"
	Private cFilPg 		:= "mv_par13"
	Private oTempTRB

	If lSigaMDTPs
		ShowHelpDlg( STR0004 , ; //"Atenção"
					{ STR0005 } , 2 , ; //"Rotina não autorizada para Prestador de Serviço."
					{ STR0006 } , 2 ) //"Contate o administrador de sistema."
	Else
		//Verifica se recebeu os dados de outra rotina
		If ValType( aDados ) == "A"
			aDad145 := aClone( aDados )
		EndIf

		/* Perguntas
		+--------------------------------------+
		| 01  De Questionario ?                |
		| 02  Até Questionario ?               |
		| 03  De Matrícula ?                   |
		| 04  Até Matrícula ?                  |
		| 05  De  Data Realizacao ?            |
		| 06  Ate Data Realizacao ?            |
		| 07  De  Fornecedor ?                 |
		| 08  De  Loja ?                       |
		| 09  Ate Fornecedor ?                 |
		| 10  Ate Loja ?                       |
		| 11  De  EPI ?                        |
		| 12  Ate EPI ?                        |
		| 13  Filtrar Questoes ?               |
		| 14  Perguntas por Linha ?            |
		| 15  Imprimir Observações em branco ? |
		+--------------------------------------+
		*/

		Pergunte( cPerg , .F. )

		//-------------------------------------------
		// Envia controle para a funcao SETPRINT
		//-------------------------------------------
		wnrel := "MDTR412"

		If Valtype( aDad145 ) == "A"
			For nFor := 1 To Len( aDad145 )
				&( aDad145[ nFor , 1 ] ) := aDad145[ nFor , 2 ]
			Next nFor
		Else
			If !Pergunte( cPerg , .T. )
				Return
			Endif
		Endif

		Processa( { | lEnd | fImpRel() } )

	EndIf

	//-----------------------------------------------
	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	//-----------------------------------------------
	NGRETURNPRM( aNGBEGINPRM )

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fInicPagina
Imprime Cabeçalho

@return Nil

@sample fInicPagina()

@author Jackson Machado
@since 08/02/2016
/*/
//---------------------------------------------------------------------
Static Function fInicPagina()

	Local cLogo
	Local lLogo := .F.

	oPrint:StartPage() //Iniciar Pagina
	oPrint:Box( 150 , 100 , 330 , 2300 )

	cLogo := cStartPath + "LGRL" + SM0->M0_CODIGO + SM0->M0_CODFIL + ".BMP" //Empresa+Filial
	If File( cLogo )
		lLogo := .T.
	Else
		cLogo := cStartPath + "LGRL" + SM0->M0_CODIGO + ".BMP" //Empresa
		If File(cLogo)
			lLogo := .T.
		Endif
	Endif

	If lLogo
		oPrint:SayBitMap( 160 , 110 , cLogo , 310 , 170 )
	EndIf

	nColInic := 530

	nPag410++
	oPrint:Say( 170 , 2070 , STR0037 + ": " + cValToChar( nPag410 ) , oFont07 ) //"Pág."
	oPrint:Say( 210 , 2070 , STR0038 + ": " + cValToChar( dDataBase ) , oFont07 ) //"Data"
	oPrint:Say( 250 , 2070 , STR0039 + ": " + Time() , oFont07 ) //"Hora"
	lin := 330

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} Somalinha
Incrementa Linha e Controla Salto de Pagina

@return Nil

@param nSalto Numerico Valor a ser utilizado como salto de página

@sample Somalinha()

@author Jackson Machado
@since 08/02/2016
/*/
//---------------------------------------------------------------------
Static Function Somalinha( nSaltoGrf , lQuebra )

	Default lQuebra := .F.

	lin += nSaltoGrf

	If lin > nLinhaTot
		If !lFirst
			If !lQuebra
				oPrint:Line( lin , 200 , lin , 2300 )
			EndIf

			oPrint:EndPage() //Fechar Pagina
		EndIf
		lin := 150
		fInicPagina() //Iniciar Pagina
	EndIf

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fImpRel
Impressão do Relatório

@return Nil

@sample fImpRel()

@author Jackson Machado
@since 08/02/2016
/*/
//---------------------------------------------------------------------
Static Function fImpRel()

	Local nXYZ, nXX, LinhaCorrente, nYY
	Local nX, lQs
	Local cQuestio	:= ""
	Local cFornec	:= ""
	Local cCodEPI	:= ""
	Local cAliasCC	:= "SI3"
	Local cCodCC2	:= "I3_CUSTO"
	Local cDescCC2	:= "SI3->I3_DESC"
	Local cTemp		:= AllTrim( GetTempPath() )
	Local aImagens	:= { "ngradiono.png" , "ngradiook.png" , "ngcheckno.png" , "ngcheckok.png" }
	Local cBarras	:= If( isSrvUnix() , "/" , "\" )
	Local aArea 	:= GetArea()
	Local nDescBox	:= 0
	Local nXZ		:= 0
	Local nAdicLinha:= 0 //Utilizado para adicionar valor a linha
	Local lLinha50	:= .F. //Verifica se ja foi adicionado o valor.

	Private lFirst 		:= .T.
	Private cArqTrab2
	Private cAliasTRB	:= GetNextAlias()
	Private cStartPath	:= AllTrim( GetSrvProfString( "Startpath" , "" ) )
	Private cBarraSrv	:= "\"
	Private cBarSrv2	:= "\\"
	Private nTipLine	:= mv_par14
	Private lin 		:= 9999
	Private nPag410 	:= 0
	Private oPrint
	Private oFont07  	:= TFont():New("Verdana",07,07,,.F.,,,,.F.,.F.)
	Private oFont10b 	:= TFont():New("Verdana",09,09,,.T.,,,,.F.,.F.)
	Private oFont10  	:= TFont():New("Verdana",09,09,,.F.,,,,.F.,.F.)
	Private oFont10n 	:= TFont():New("Tahoma",10,10,,.T.,,,,.F.,.F.)
	Private aValImp		:= {}

	If Alltrim( GetMV( "MV_MCONTAB" ) ) == "CTB"
		cAliasCC := "CTT"
		cCodCC2  := "CTT_CUSTO"
		cDescCC2 := "CTT->CTT_DESC01"
	Endif
	If isSRVunix()  //Servidor eh da familia Unix (linux, solaris, free-bsd, hp-ux, etc.)
		cBarraSrv := "/"
		cBarSrv2 := "//"
	Endif

	If SubStr( cStartPath , Len( cStartPath ) , 1 ) <> cBarraSrv
		cStartPath := cStartPath + cBarraSrv
	Endif


	If mv_par13 == 1 .And. Len( aQuesSelc ) == 0
		MsgInfo( STR0040 ) //"Não há nada para imprimir no relatório."
		RestArea( aArea )
		Return .F.
	EndIf

	cTemp := cTemp + If( Right( cTemp , 1 ) == cBarras , "" , cBarras )
	//Cria Pasta Temp
	If !ExistDir( cTemp )
		MakeDir( cTemp )
	EndIf

	For nYY := 1 To Len( aImagens )
		//Exclui imagem se ela ja existir no diretorio
		FErase( cTemp + aImagens[ nYY ] )

		//Exporta imagens do RPO para a pasta especificada
		Resource2File( aImagens[ nYY ] , cTemp + aImagens[ nYY ] )

		//---------------------------------------------------------
		// Exporta imagem para BMP para funcionar com o TMSPrinter
		//---------------------------------------------------------
		oBmp := TBitmap():New( 0 , 0 , 0 , 0 , , , .T. , , , , , .F. , , , , , .T. )
		oBmp:Hide()
		oBmp:Load( , StrTran( aImagens[ nYY ] , ".png" , "" ) )

		oBmp:lStretch		:= .T.
		oBmp:lTransparent	:= .T.
		nAltura				:= oBmp:nClientHeight
		nLArgura			:= oBmp:nClientWidth
		oBmp:nHeight		:= nAltura
		oBmp:nWidth  		:= nLargura
		oBmp:SaveAsBmp( cTemp + StrTran( Lower( aImagens[ nYY ] ) , ".png" , ".bmp" ) )
		oBmp:Free()
	Next nX

	oPrint := TMSPrinter():New( OemToAnsi( STR0003 ) ) //"Avaliação de EPI"
	oPrint:SetPortRait()
	If !oPrint:Setup()
		RestArea ( aArea )
		Return .F.
	EndIf

	LoadArTmp()

	dbSelectArea( cAliasTRB )
	dbGoTop()
	lTemDados := .T.
	If ( cAliasTRB )->( Eof() )
		lTemDados := .F.
	Endif
	While ( cAliasTRB )->( !Eof() )

		cMatricula := ( cAliasTRB )->MATRICULA
		nPag410 := 0

		If cQuestio <> ( cAliasTRB )->QUESTI .Or. ;
			cFornec <> ( cAliasTRB )->FORNEC + ( cAliasTRB )->LOJA .Or. ;
			cCodEPI <> ( cAliasTRB )->CODEPI

			lin := 9999

			SomaLinha( 20 )
			lFirst := .F.

			cQuestio := ( cAliasTRB )-> QUESTI
			cFornec := ( cAliasTRB )->FORNEC + ( cAliasTRB )->LOJA
			cCodEPI := ( cAliasTRB )->CODEPI

			dbSelectArea("SRA")
			dbSetOrder(01)
			If dbSeek( xFilial("SRA") + cMatricula )
				cCodFuncao := SRA->RA_CODFUNC
				cCodCcusto := SRA->RA_CC
			Endif
			dbSelectArea("SRJ")
			dbSetOrder(01)
			dbSeek( xFilial("SRJ") + cCodFuncao )
			dbSelectArea(cAliasCC)
			dbSetOrder(01)
			dbSeek( xFilial(cAliasCC) + cCodCcusto )

			oPrint:Line(330,100,550,100)
			oPrint:Line(330,2300,550,2300)
			oPrint:Line(550,100,550,2300)
			oPrint:Line(390,100,390,2300)

			oPrint:Say(340,110,"1. "+STR0041,oFont10b) //"IDENTIFICAÇÃO"
			oPrint:Say(400,110,STR0042+":",oFont10b) //"Nome"
			oPrint:Say(400,510,SRA->RA_NOME,oFont10)
			oPrint:Say(450,110,STR0043+":",oFont10b) //"Função"
			oPrint:Say(450,510,SRJ->RJ_DESC,oFont10)
			oPrint:Say(500,110,STR0044+":",oFont10b) //"Centro de Custo"
			oPrint:Say(500,510,&(cDescCC2),oFont10)

			cIdade := Alltrim( Str( Int((dDataBase - SRA->RA_NASC) / 365) , 10 ) )
			oPrint:Say(400,1500,STR0045+":",oFont10b) //"Idade"
			oPrint:Say(400,1640,cIdade,oFont10)
			oPrint:Say(400,1810,STR0046+":",oFont10b) //"Sexo"
			oPrint:Say(400,1950,If(SRA->RA_SEXO=="M",STR0047,STR0048),oFont10) //"Masculino"###"Feminino"
			oPrint:Say(450,1500,STR0049+":",oFont10b) //"Data do Questionário"
			oPrint:Say(450,1950,DtoC((cAliasTRB)->DTREAL),oFont10)
			oPrint:Say(500,1500,STR0050+":",oFont10b) //"Data Admissão"
			oPrint:Say(500,1950,DtoC(SRA->RA_ADMISSA),oFont10)

			oPrint:Line(550,100,870,100)
			oPrint:Line(550,2300,870,2300)
			oPrint:Line(870,100,870,2300)
			oPrint:Line(610,100,610,2300)

			dbSelectArea( "SA2" )
			dbSetOrder( 1 )
			dbSeek( xFilial( "SA2" ) + ( cAliasTRB )->FORNEC + ( cAliasTRB )->LOJA )

			dbSelectArea( "TN3" )
			dbSetOrder( 1 )
			dbSeek( xFilial( "TN3" ) + ( cAliasTRB )->FORNEC + ( cAliasTRB )->LOJA + ( cAliasTRB )->CODEPI )

			dbSelectArea( "SB1" )
			dbSetOrder( 1 )
			dbSeek( xFilial( "SB1" ) + ( cAliasTRB )->CODEPI )

			oPrint:Say(560,110,"2. "+STR0051,oFont10b) //"DADOS DO EQUIPAMENTO"
			oPrint:Say(610,110,STR0052+":",oFont10b) //"EPI"
			oPrint:Say(610,350, ( cAliasTRB )->CODEPI + ": " + AllTrim( SB1->B1_DESC ) ,oFont10)
			oPrint:Say(670,110,STR0053+":",oFont10b) //"Fornecedor"
			oPrint:Say(670,350, ( cAliasTRB )->FORNEC + " - " + ( cAliasTRB )->LOJA + ": " + AllTrim( SA2->A2_NOME ) ,oFont10)
			oPrint:Say(720,110,"C.A." + ":",oFont10b)
			oPrint:Say(720,350,TN3->TN3_NUMCAP,oFont10)
			oPrint:Say(770,110,"C.R.F." + ":",oFont10b)
			oPrint:Say(770,350,TN3->TN3_NUMCRF,oFont10)
			oPrint:Say(820,110,"C.R.I." + ":",oFont10b)
			oPrint:Say(820,350,TN3->TN3_NUMCRI,oFont10)

			nContGrp := 2
			lin := 800
			lPrimQuest := .t.

		EndIf

		If IsInCallStack( "MDTA621" )
			aValImp := aClone( aCadTipo )
		Else
			dbSelectArea( "TMH" )
			dbSetOrder( 1 )
			dbSeek( xFilial( "TMH" ) + ( cAliasTRB )->QUESTI )
			While TMH->( !Eof() ) .And. TMH->TMH_FILIAL == xFilial( "TMH" ) .And. ;
				TMH->TMH_QUESTI == ( cAliasTRB )->QUESTI

				//Verifica se há algum questionário com perguntas selecionadas nessa matrícula.
				If mv_par13 == 1 //Filtrar perguntas? Sim
					If aScan( aQuesSelc , { | x | x[ 5 ] .And. x[ 1 ] == TMH->TMH_QUESTI .And. x[ 2 ] == TMH->TMH_QUESTA  } ) == 0
						dbSelectArea( "TMH" )
						dbSkip()
						Loop
					EndIf
				EndIf

				aTipoTMH := {}
				If !Empty( TMH->TMH_RESPOS )
					aTipoTMH := fRetCombo( Alltrim( TMH->TMH_RESPOS ) )
				Endif

				aTemp := Array( Len( aTipoTMH ) , 3 )
				For nXX := 1 To Len( aTemp )
					dbSelectArea( "TY8" )
					dbSetOrder( 1 )
					If dbSeek( xFilial( "TY8" ) + ( cAliasTRB )->FORNEC + ( cAliasTRB )->LOJA + ( cAliasTRB )->CODEPI + ( cAliasTRB )->MATRICULA + DToS( ( cAliasTRB )->DTREAL ) + ( cAliasTRB )->QUESTI + TMH->TMH_QUESTA + SubStr(aTipoTMH[nXX],1,1) )
						If ( TMH->TMH_TPLIST == "1" )
							aTemp[nXX,1] := 1
						Else
							aTemp[nXX,1] := .T.
						Endif
					Else
						If ( TMH->TMH_TPLIST == "1" )
							aTemp[nXX,1] := 0
						Else
							aTemp[nXX,1] := .F.
						Endif
					EndIf
				Next nXX


				cMemoM6 := ""

				dbSelectArea( "TY8" )
				dbSetOrder( 1 )
				If dbSeek( xFilial( "TY8" ) + ( cAliasTRB )->FORNEC + ( cAliasTRB )->LOJA + ( cAliasTRB )->CODEPI + ( cAliasTRB )->MATRICULA + DToS( ( cAliasTRB )->DTREAL ) + ( cAliasTRB )->QUESTI + TMH->TMH_QUESTA + "#" )
					cMemoM6 := Alltrim( TY8->TY8_DESCRI )
				Endif

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
				//11- Questionario
				//12- Qtd. Objetos x Pergunta
				//13- Página onde ficará a pergunta
				//--------------------------------------------------------------------------------------------------------------------
				// ATENCAO: A CONFIGURACAO DA VARIAVEL aValImp DEVE SER A MESMA DA VARIÁVEL aCadTipo DEFINIDA NO PROGRAMA MDTA621.PRW
				//--------------------------------------------------------------------------------------------------------------------
				aAdd( aValImp , { TMH->TMH_QUESTA , Capital( TMH->TMH_PERGUN ) , TMH->TMH_CODGRU , aTipoTMH ,;
									TMH->TMH_RESPOS , ( TMH->TMH_TPLIST == "1" ) ,;
									( TMH->TMH_ONMEMO == "1" ) , aTemp , TMH->TMH_ORDEM , cMemoM6 , ( cAliasTRB )->QUESTI , 0  , 0  } )
				dbSelectArea( "TMH" )
				dbSkip()
			End
		EndIf
		If Len( aValImp ) > 0
			If Len( aValImp[ 1 ] ) > 10
				aSort( aValImp , , , { |x,y| x[11]+x[3]+x[9] < y[11]+y[3]+y[9] } )
			Else
				aSort( aValImp , , , { |x,y| x[3]+x[9] < y[3]+y[9] } )
			Endif
		EndIf
		cOldGrupo := "#"
		cOldQuest := "#"
		If nTipLine <> 1
			lMemoAnt := .T.
			nTotAcu := 0
			nQtPer  := 0
			nLinAcu := 0
		Endif
		For nYY := 1 to Len(aValImp)

			If Len(aValImp[nYY]) > 10 //Caso impressao seja de apenas um questionario, não valida posição 11 da mudança de questionário
				If cOldQuest <> aValImp[nYY,11]
					cOldQuest := aValImp[nYY,11]
					dbSelectArea("TMG")
					dbSetOrder(01)
					dbSeek(xFilial("TMG")+cOldQuest)
					//------------------------------
					// Titulo do Questionario
					//------------------------------
					Somalinha(70)
					oPrint:Box(lin,100,lin+100,2300)
					oPrint:Say(lin+20,1000-Len(TMG->TMG_NOMQUE),Capital(Alltrim(TMG->TMG_NOMQUE)),oFont10b)
					Somalinha(30)
					cOldGrupo := "#"
				Endif
			Endif

			If cOldGrupo <> aValImp[nYY,3]
				cOldGrupo := aValImp[nYY,3]
				cDesGrupo := " "
				dbSelectArea("TK0")
				dbSetOrder(01)
				If dbSeek( xFilial("TK0") + cOldGrupo )
					If !Empty(TK0->TK0_DESCRI)
						cDesGrupo := Capital( Alltrim(TK0->TK0_DESCRI) )
					Endif
				Endif
				//------------------------------
				// Titulo do Grupo
				//------------------------------
				nContGrp++
				Somalinha(70)
				oPrint:Box(lin,100,lin+100,2300)
				oPrint:Say(lin+20,120,Alltrim(Str(nContGrp,10))+". "+cDesGrupo,oFont10b)
				Somalinha(70)
				If nTipLine <> 1
					nTotAcu := 0
					nLinAcu := If(lin > nLinhaTot .and. nTipLine == 2,280,lin)
					nQtPer  := 0
				Endif
			Endif
			nLimCol := 120
			nAcumLi := 0

			If nTipLine <> 1
				If lMemoAnt
					nLinAcu := If(lin > nLinhaTot .and. nTipLine == 2,280,lin)
					nAcumLi := 0
					nTotAcu := 0
					nQtPer  := 1
				Else
					If aValImp[nYY,7]
						nLinAcu := If(lin > nLinhaTot .and. nTipLine == 2,280,lin)
						nAcumLi := 0
						nTotAcu := 0
						nQtPer  := 0
					Endif
					nAcumLi := nTotAcu
					nTot := Len(aValImp[nYY,2])
					nBox := 0
					For nXX := 1 To Len(aValImp[nYY,4])
						nBox += Len(SubStr(aValImp[nYY,4,nXX],3))
					Next nXX
					If nBox > nTot
						nTot := nBox
					Endif

					If nAcumLi+nTot > nLimCol
						nLinAcu := If(lin > nLinhaTot .and. nTipLine == 2,280,lin)
						nTotAcu := 0
						nQtPer  := 1
					Endif

					If nTipLine == 2
						If nQtPer == 0
							nAcumLi := 0
						Elseif nQtPer == 1 .and. nTotAcu <> 0
							nAcumLi := 60
						Endif
						If nQtPer < 2
							lin := nLinAcu
							nQtPer++
						Else
							nLinAcu := If(lin > nLinhaTot .and. nTipLine == 2,280,lin)
							nAcumLi := 0
							nTotAcu := 0
							nQtPer  := 1
						Endif
					Else
						lin := nLinAcu
					Endif
				Endif
				If aValImp[nYY,7]
					lMemoAnt := .T.
					nAcumLi := 0
				Else
					lMemoAnt := .F.
				Endif
			ENdif
			//------------------------------
			// Titulo Questão
			//------------------------------
			Somalinha(50)

			If mv_par14 == 1 //Caso seja uma pergunta por linha
				oPrint:Say(lin,If(nTipLine == 1,125,125+(nAcumLi*18)),aValImp[nYY,2],oFont10n)
			ELse //Caso seja 2 pergunta por linha
				nLinhasMemo := MLCOUNT(aValImp[nYY,2],60)//Quebra a linha
				For LinhaCorrente := 1 to nLinhasMemo
					If !Empty( (MemoLine(aValImp[nYY,2],60,LinhaCorrente)))
						If nLinhasMemo > 1 .And. LinhaCorrente == 2
							Somalinha(50)
						EndIf
						oPrint:Say(lin,If(nTipLine == 1,125,125+(nAcumLi*18)),MemoLine(aValImp[nYY,2],60,LinhaCorrente),oFont10n)
					Endif
				Next LinhaCorrente
			EndIf

			oPrint:Line(lin-30,100,lin+50,100)
			oPrint:Line(lin-30,2300,lin+50,2300)
			//------------------------------------------------
			// Montando lista de opcoes (radio ou check)
			//------------------------------------------------
			For nXX := 1 To Len(aValImp[nYY,4])
				cStrXX := Alltrim( Str(nXX) )
				If nXX = 1
					For nXZ:=1 to Len(aValImp[nYY,4]) //Percorre  o Array
						cDescBox := SubStr(aValImp[nYY,4,nXZ],3)//Verificar o todos os registros
						nDescBox:=If(Len(cDescBox) > nDescBox, Len(cDescBox),nDescBox)//Adiciona o registro de maior
					Next nXZ
				Endif
				cDescBox := SubStr(aValImp[nYY,4,nXX],3)
				If (nAcumLi + nDescBox + 5) > nLimCol .or. nXX == 1
					If nXX == 1
						Somalinha(50)
					Else
						lMemoAnt := .T.
						Somalinha(40)
					Endif
					nAcumLi := If(nTipLine == 1,0,nTotAcu)
					oPrint:Line(lin-30,100,lin+40,100)
					oPrint:Line(lin-30,2300,lin+40,2300)
				Endif

				If aValImp[nYY,6]
					If aValImp[nYY,8,nXX,1] == 0
						If File(cTemp+"ngradiono.bmp")
							oPrint:SayBitmap(Lin+5,120+(nAcumLi*18),cTemp+"ngradiono.bmp",30,32)
						Endif
					Else
						If File(cTemp+"ngradiook.bmp")
							oPrint:SayBitmap(Lin+5,120+(nAcumLi*18),cTemp+"ngradiook.bmp",30,32)
						Endif
					Endif
				Else
					If !aValImp[nYY,8,nXX,1]
						If File(cTemp+"ngcheckno.bmp")
							oPrint:SayBitmap(Lin+5,120+(nAcumLi*18),cTemp+"ngcheckno.bmp",30,32)
						Endif
					Else
						If File(cTemp+"ngcheckok.bmp")
							oPrint:SayBitmap(Lin+5,120+(nAcumLi*18),cTemp+"ngcheckok.bmp",30,32)
						Endif
					Endif
				Endif
				oPrint:Say(lin,120+(nAcumLi*18)+30,cDescBox,oFont10)
				nAcumLi += nDescBox + 9	//Variavel de controle da distancia entre os elementos
			Next nXX
			If nTipLine <> 1
				nTotAcu := If(Len(aValImp[nYY,2])+nTotAcu > nAcumLi,nTotAcu+Len(aValImp[nYY,2])+4,nAcumLi+4)
				nTotAcu := If(nTipLine == 2,If(nQtPer == 0,0,60),nTotAcu)
			Endif

			If mv_par14 == 2//Verifica se será impresso 2 perguntas por linha

				If nLinhasMemo > 1 .and. nQtPer == 1 //Verifica se é primeira pergunta da linha, e se houve quebra de linha.
					nAdicLinha:= 50 //Adiciona o valor a mais na linha
				EndIf

				lLinha50 := nLinhasMemo > 1 .and. nQtPer <> 1 //Verifica se é a segunda pergunta da mesma linha

				If nQtPer > 1 .And. nAdicLinha > 0 .And. !lLinha50 //Verifica esta na 2ª pergunta e se necessita adicionar o valor na linha.
					lin+= nAdicLinha //Adiciona o valor a linha.
					nAdicLinha:= 0 //Zera variavel.
				ELseIf nQtPer > 1 .And. nAdicLinha > 0 //Caso não seja preciso adicionar valor, zera variavel
					nAdicLinha:= 0 //Zera variavel
				Endif

			Endif

			If aValImp[nYY,7]
				If (mv_par15 == 2 .And. !Empty(aValImp[nYY,10])) .Or. mv_par15 == 1
				//------------------
				// Campo Memo
				//------------------
					nLinhasMemo := MLCOUNT(aValImp[nYY,10],110)
					nLinhasMemo := If(nLinhasMemo<2,2,nLinhasMemo)
					For LinhaCorrente := 1 To nLinhasMemo
						If LinhaCorrente == 1
							If Lin+85 > nLinhaTot
								Lin := 7777
							Endif
							Somalinha(50)
							oPrint:Line(lin-30,100,lin+40,100)
							oPrint:Line(lin-30,2300,lin+40,2300)
							oPrint:Line(lin,200,lin+50,200)
							oPrint:Line(lin,2200,lin+50,2200)
							oPrint:Line(lin,200,lin,2200)
						Else
							Somalinha(45,.T.,.T.)
							oPrint:Line(lin,2200,lin+45,2200)
							oPrint:Line(lin,200,lin+45,200)
						Endif
						oPrint:Line(lin-30,100,lin+40,100)
						oPrint:Line(lin-30,2300,lin+40,2300)
						oPrint:Say(lin+3,215,MemoLine(aValImp[nYY,10],110,LinhaCorrente),oFont10)
						If LinhaCorrente == nLinhasMemo
							oPrint:Line(lin+45,200,lin+45,2200)
							oPrint:Line(lin-30,100,lin+40,100)
							oPrint:Line(lin-30,2300,lin+40,2300)
						Endif
					Next LinhaCorrente
				EndIf
			Endif

			/*If nYY != Len(aValImp)
				Somalinha(10)
			Endif*/
			oPrint:Line(lin-30,100,lin+100,100)
			oPrint:Line(lin-30,2300,lin+100,2300)

			If lin+540 > nLinhaTot
				oPrint:Line(lin+100,100,lin+100,2300)
				lin := 9999
			ElseIF nYY == Len(aValImp) .And. lin+540 > 3200
				oPrint:Line(lin+100,100,lin+100,2300)
			Endif

		Next nYY
		aValImp := {}
		lQbrPg := .F.
		If lin+540 > 3200
			lin := 9999
			lQbrPg := .T.
		Endif
		Somalinha(90,lQbrPg)
		If !lQbrPg
			oPrint:Line(lin,100,lin,2300)
		EndIf

		oPrint:Line(lin,100,lin+220,100)
		oPrint:Line(lin+60,1150,lin+220,1150)
		oPrint:Line(lin,2300,lin+220,2300)

		oPrint:Line(lin+60,100,lin+60,2300)
		oPrint:Line(lin+120,100,lin+120,2300)
		oPrint:Line(lin+220,100,lin+220,2300)

		nContGrp++
		oPrint:Say(lin+10,110,Alltrim(Str(nContGrp,10))+". "+ STR0054,oFont10b) //"REGISTRO DE LEGITIMIDADE E VERACIDADE DAS INFORMAÇÕES"

		oPrint:Say(lin+70,400,STR0055,oFont10) //"DATA DO PREENCHIMENTO"
		oPrint:Line(lin+215,410,lin+215,850)
		oPrint:Line(lin+215,557,lin+155,567)
		oPrint:Line(lin+215,702,lin+155,712)
		oPrint:Say(lin+70,1420,STR0056,oFont10) //"ASSINATURA DO COLABORADOR"
		oPrint:Line(lin+215,1200,lin+215,2250)

		Somalinha(220)

		oPrint:Line(lin,100,lin+120,100)
		oPrint:Line(lin+60,1150,lin+120,1150)
		oPrint:Line(lin,2300,lin+120,2300)

		oPrint:Line(lin+60,100,lin+60,2300)
		oPrint:Line(lin+120,100,lin+120,2300)

		nContGrp++
		oPrint:Say(lin+10,110,Alltrim(Str(nContGrp,10))+". "+ STR0057,oFont10b) //"APROVAÇÃO DO EQUIPAMENTO DE PROTEÇÃO"
		oPrint:Say(lin+70,400,STR0058,oFont10) //"EQUIPAMENTO APROVADO?"
		oPrint:Say(lin+70,1420,If( ( cAliasTRB )->APROVA == "1" , STR0059 , STR0060 ) ,oFont10) //"SIM"###"NÃO"

		dbSelectArea( cAliasTRB )
		dbSkip()
	End

	If !lTemDados
		MsgInfo(STR0040)//"Não há nada para imprimir no relatório."
	Else
		oPrint:EndPage() //Fechar última Pagina

		oPrint:Preview()
	Endif

	dbSelectArea( cAliasTRB )
	oTempTRB:Delete()

	RestArea( aArea )
Return
//---------------------------------------------------------------------
/*/{Protheus.doc} LoadArTmp
Carrega arquivo temporário

@return Nil

@sample LoadArTmp()

@author Jackson Machado
@since 08/02/2016
/*/
//---------------------------------------------------------------------
Static Function LoadArTmp()

	Local nX
	Local aArea := GetArea()
	Local aDBF


	aDBF := {}
	aAdd( aDBF , { "FORNEC" 	, "C" , TAMSX3("A2_COD")[1] , 0 } )
	aAdd( aDBF , { "LOJA" 		, "C" , TAMSX3("A2_LOJA")[1] , 0 } )
	aAdd( aDBF , { "CODEPI" 	, "C" , TAMSX3("B1_COD")[1] , 0 } )
	aAdd( aDBF , { "QUESTI" 	, "C" , 06 , 0 } )
	aAdd( aDBF , { "MATRICULA" 	, "C" , 06 , 0 } )
	aAdd( aDBF , { "PERGUNTA"  	, "C" , 03 , 0 } )
	aAdd( aDBF , { "NOMPERGU"  	, "C" , TAMSX3("TMH_PERGUN")[1] , 0 } )
	aAdd( aDBF , { "RESPOS"    	, "C" , 01 , 0 } )
	aAdd( aDBF , { "DTREAL"    	, "D" , 10 , 0 } )
	aAdd( aDBF , { "CODGRUPO"  	, "C" , 03 , 0 } )
	aAdd( aDBF , { "XCOMBO"    	, "M" , 10 , 0 } )
	aAdd( aDBF , { "APROVA"    	, "C" , 01 , 0 } )

	//Cria TRB
	oTempTRB := FWTemporaryTable():New( cAliasTRB, aDBF )
	oTempTRB:AddIndex( "1", {"FORNEC","LOJA","CODEPI","MATRICULA","DTREAL","QUESTI","CODGRUPO","PERGUNTA"} )
	oTempTRB:AddIndex( "2", {"FORNEC","LOJA","CODEPI","MATRICULA","DTREAL","PERGUNTA"} )
	oTempTRB:Create()

	dbSelectArea("TY8")
	dbSetOrder(1)
	dbSeek(xFilial("TY8"),.T.)

	ProcRegua( LastRec() )

	//---------------------------------------
	// Correr TY8 para ler as  Questoes
	//---------------------------------------

	While TY8->( !Eof() ) .And. TY8->TY8_FILIAL == xFilial( "TY8" )

		IncProc()

		If TY8->TY8_MAT < mv_par03 .Or. TY8->TY8_MAT > mv_par04
			dbSelectArea("TY8")
			dbSkip()
			Loop
		Endif

		If TY8->TY8_QUESTI <  mv_par01 .OR. TY8->TY8_QUESTI >  mv_par02
			dbSelectArea("TY8")
			dbSkip()
			Loop
		Endif

		If TY8->TY8_DTREAL <  mv_par05 .OR. TY8->TY8_DTREAL >  mv_par06
			dbSelectArea("TY8")
			dbSkip()
			Loop
		EndIf

		If TY8->TY8_FORNEC+TY8->TY8_LOJA < mv_par07+mv_par08 .OR. TY8->TY8_FORNEC+TY8->TY8_LOJA > mv_par09+mv_par10
			dbSelectArea("TY8")
			dbSkip()
			Loop
		Endif

		If TY8->TY8_CODEPI <  mv_par11 .OR. TY8->TY8_CODEPI >  mv_par12
			dbSelectArea("TY8")
			dbSkip()
			Loop
		Endif

		dbSelectArea( "TMH" )
		dbSetOrder( 1 )
		dbSeek( xFilial( "TMH" ) + TY8->TY8_QUESTI + TY8->TY8_QUESTA )

		dbSelectArea( cAliasTRB )
		dbSetOrder( 1 )
		If !dbSeek( TY8->TY8_FORNEC+TY8->TY8_LOJA+TY8->TY8_CODEPI+TY8->TY8_MAT+DTOS(TY8->TY8_DTREAL)+TY8->TY8_QUESTI )
			RecLock( cAliasTRB , .T. )
			( cAliasTRB )->FORNEC   	:= TY8->TY8_FORNEC
			( cAliasTRB )->LOJA		   	:= TY8->TY8_LOJA
			( cAliasTRB )->CODEPI   	:= TY8->TY8_CODEPI
			( cAliasTRB )->QUESTI   	:= TY8->TY8_QUESTI
			( cAliasTRB )->MATRICULA  	:= TY8->TY8_MAT
			( cAliasTRB )->PERGUNTA   	:= TY8->TY8_QUESTA
			( cAliasTRB )->NOMPERGU   	:= TMH->TMH_PERGUN
			( cAliasTRB )->RESPOS     	:= TY8->TY8_RESPOS
			( cAliasTRB )->DTREAL     	:= TY8->TY8_DTREAL
			( cAliasTRB )->XCOMBO   	:= TMH->TMH_RESPOS
			( cAliasTRB )->CODGRUPO 	:= TMH->TMH_CODGRU
			( cAliasTRB )->APROVA	 	:= TY8->TY8_APROVA
			( cAliasTRB )->( MsUnLock() )
		EndIf

		dbSelectArea( "TY8" )
		dbSKIP()
	End
	RestArea( aArea )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fRetCombo
Realiza a gravação

@return aArray2 Array Valores do ComboBox

@param cVar Caracter Valor do ComboBox

@sample fRetCombo( "" )

@author Jackson Machado
@since 05/02/2016
/*/
//---------------------------------------------------------------------
Static Function fRetCombo( cVar )

	Local aArray1 := RetSx3Box( cVar , , , 1 )
	Local nCont,aArray2 := {}

	For nCont := 1 To Len( aArray1 )
		If !Empty( aArray1[ nCont , 1 ] )
			aAdd( aArray2 , AllTrim( aArray1[ nCont , 1 ] ) )
		Endif
	Next nCont

Return aClone( aArray2 )
//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR412FOR
Validação de Fornecedor e Loja do SX1

@return aArray2 Array Valores do ComboBox

@param nDeAte Numerico Indica qual o Fornecedor e Loja está sendo validado (1-De;2-Até)
@param nForLoj Numerico Indica se está validando o Fornecedor ou a Loja (1-Fornecedor;2-Loja)

@sample MDTR412FOR( 1 , 1 )

@author Jackson Machado
@since 05/02/2016
/*/
//---------------------------------------------------------------------
Function MDTR412FOR(nDeAte,nForLoj)

	Local lRet := .T.

	Default nDeAte := 0
	Default nForLoj := 0


	If nDeAte == 1
		If nForLoj == 1
			If !Empty( mv_par07 )
				lRet := ExistCPO( "SA2" , mv_par07 )
			EndIf
		ElseIf nForLoj == 2
			If !Empty( mv_par08 )
				If Empty( mv_par07 )
					ShowHelpDlg( STR0004 , ; //"Atenção"
									{ STR0061 } , 2 , ; //"Fornecedor não preenchido."
									{ STR0062 } , 2 ) //"Para informar uma loja, favor informar um fornecedor."
					lRet := .F.
				Else
					lRet := ExistCPO( "SA2" , mv_par07+mv_par08 )
				EndIf
			EndIf
		EndIf
	ElseIf nDeAte == 2
		If nForLoj == 1
			If Empty( mv_par09 )
				ShowHelpDlg( STR0004 , ; //"Atenção"
								{ STR0063 } , 2 , ; //"Fornecedor vazio."
								{ STR0064 } , 2 ) //"'Até Fornecedor' não pode ser vazio."
				lRet := .F.
			EndIf
			If lRet .And. mv_par09 <> Replicate( "Z" , TAMSX3( "A2_COD" )[ 1 ] )
				lRet := ExistCPO( "SA2" , mv_par09 )
			EndIf
		ElseIf nForLoj == 2
			If Empty( mv_par10 )
				ShowHelpDlg( STR0004 , ; //"Atenção"
								{ STR0065 } , 2 , ; //"Loja vazia."
								{ STR0066 } , 2 ) //"'Até Loja' não pode ser vazio."
				lRet := .F.
			EndIf
			If lRet .And. mv_par10 <> Replicate( "Z" , TAMSX3( "A2_LOJA" )[ 1 ] )
				lRet := ExistCPO( "SA2" , mv_par09+mv_par10 )
			EndIf
		EndIf
	EndIf
	If lRet .And. !Empty( mv_par09 ) .And. !Empty( mv_par10 )
		If mv_par07+mv_par08 > mv_par09+mv_par10
			ShowHelpDlg( STR0004 , ; //"Atenção"
							{ STR0067 } , 2 , ; //"Valores De/Até Inválidos."
							{ STR0068 } , 2 ) //"Informe os valores de De Fornecedor/De Loja menores que Até Fornecedor/Até Loja."
			lRet := .F.
		EndIf
	EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR412FOR
Validação de Data do SX1

@return lRet Logico Retorna verdadeiro quando valor correto

@param nData Numerico Indica qual Data está sendo validado (1-De;2-Até)

@sample MDTR412DT( 1 )

@author Jackson Machado
@since 05/02/2016
/*/
//---------------------------------------------------------------------
Function MDTR412DT( nData )

	Local lRet 		:= .T.
	Local cProblem  := STR0069 //"Valor do campo 'De Data' não pode ser maior que 'Até Data'."
	Local cSoluc	:= ""
	Default nData := 0

	If !Empty( mv_par05 ) .And. !Empty( mv_par06 )
		If mv_par05 > mv_par06
			lRet := .F.
			If nData == 1
				cSoluc := STR0070 //"Informe o valor de 'De Data' menor."
			ElseIf nData == 2
				cSoluc := STR0071 //"Informe o valor de 'Até Data' maior."
			EndIf
			ShowHelpDlg( STR0004 , ; //"Atenção"
						{ cProblem } , 2 , ;
						{ cSoluc } , 2 )
		EndIf
	EndIf

Return lRet