#INCLUDE "PROTHEUS.CH"
#INCLUDE 'NGPIMSXFUN.ch'


//+-----------------------------------------------------+
//|   Carga Inicial - exporta os principais cadastros   |
//+-----------------------------------------------------+
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BFTFstLd ³ Autor ³ Felipe Nathan Welter  ³ Data ³  out/10  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exporta os principais cadastros                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGPimsFstLd()

	//--------------------------------------
	dbSelectArea("ST6")
	dbSetOrder(01)
	dbGoTop()
	While ST6->(!Eof())

		PIMSGeraXML("OperativeGroup","Grupo Operativo","2","ST6")
		PIMSGeraXML("OperationalCategory","Categoria Operacional","2","ST6")

		ST6->(dbSkip())
	EndDo

	//--------------------------------------
	dbSelectArea("ST7")
	dbSetOrder(01)
	dbGoTop()
	While ST7->(!Eof())

		PIMSGeraXML("AssetManufacturer","Fabricante de Bem","2","ST7")

		ST7->(dbSkip())
	EndDo

	//--------------------------------------
	dbSelectArea("ZZ0")
	dbSetOrder(01)
	dbGoTop()
	While ZZ0->(!Eof())

		PIMSGeraXML("PowerClass","Classe de Potencia","2","ZZ0")

		ZZ0->(dbSkip())
	EndDo

	//--------------------------------------
	dbSelectArea("TQR")
	dbSetOrder(01)
	dbGoTop()
	While TQR->(!Eof())

		PIMSGeraXML("ModelType","Tipo Modelo","2","TQR")

		TQR->(dbSkip())
	EndDo

	//--------------------------------------
	dbSelectArea("SHB")
	dbSetOrder(01)
	dbGoTop()
	While SHB->(!Eof())

		PIMSGeraXML("WorkCenter","Centro de Trabalho","2","SHB")

		SHB->(dbSkip())
	EndDo

	//--------------------------------------
	dbSelectArea("ST9")
	dbSetOrder(01)
	dbGoTop()
	While ST9->(!Eof())

		PIMSGeraXML("Asset","Bens","2","ST9")

		ST9->(dbSkip())
	EndDo

	//--------------------------------------

Return Nil


//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//  Importacao de Quilometragem do Equipamento (Informe Producao)
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGPimsRCnt³ Autor ³ Felipe Nathan Welter  ³ Data ³ 02/09/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de importacao de contador de equipamentos por       ³±±
±±³          ³ "Informa Producao"                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGPimsRCnt(cXml)

	Local aArea := GetArea()
	Local lRet := .T.
	Local cError := '', cWarning := ''
	Local aTables	:= {"ST9","TPE","STP","TPE","STY","SM0","SB1","SG1","STR","ST6"}

	Local nX, xz
	Local nFator := 1
	Local lChkOSAut := .T.

	Local lProb := .F.
	Private aProb := {}

	Private cEquipto, dDataI, dDataF, cHoraI, cHoraF
	Private cBoletim, nQtd1, nQtd2, cPrdOpr, nOpcx

	Private lSched := !(Type("oMainWnd")=="O")
	Private cCONSMAQP := ""
	Private cGERAPREV := ""
	Private nREGISHI := 0
	Private aRETOMQP := {}
	Private nREGVAL1  := 0, nREGVAL2 := 0
	Private lULTIREG  := .F.
	Private aBENSFILP := {}
	Private nLIMCPAI1 := 0
	Private nLIMCPAI2 := 0
	Private nCONT1PAT := 0
	Private nCONT2PAT := 0

	//_nHdl := FCreate('logNGPimsRCnt'+".xml")
	//fWrite(_nHdl,cXml)
	//fClose(_nHdl)

	cCONSMAQP := AllTrim(GetMV("MV_NGCMAQP"))
	cGERAPREV := AllTrim(GetMV("MV_NGGERPR"))

	//Gera o Objeto XML
	oXml := XmlParser( cXml, "_", @cError, @cWarning )

	oRoot := XmlChildEx ( oXml:_FORMMODEL_PRODUCTIONRETURN , "_PRODUCTIONRETURN" )

	cEquipto := If(XmlChildEx ( oRoot , "_"+"EQUIPTO" )<>Nil,XmlChildEx ( oRoot , "_"+"EQUIPTO" ):_VALUE:TEXT,Nil)
	dDataI   := If(XmlChildEx ( oRoot , "_"+"DATAI"   )<>Nil,XmlChildEx ( oRoot , "_"+"DATAI"   ):_VALUE:TEXT,Nil)
	dDataF   := If(XmlChildEx ( oRoot , "_"+"DATAF"   )<>Nil,XmlChildEx ( oRoot , "_"+"DATAF"   ):_VALUE:TEXT,Nil)
	cHoraI   := If(XmlChildEx ( oRoot , "_"+"HORAI"   )<>Nil,XmlChildEx ( oRoot , "_"+"HORAI"   ):_VALUE:TEXT,Nil)
	cHoraF   := If(XmlChildEx ( oRoot , "_"+"HORAF"   )<>Nil,XmlChildEx ( oRoot , "_"+"HORAF"   ):_VALUE:TEXT,Nil)
	cBoletim := If(XmlChildEx ( oRoot , "_"+"BOLETIM" )<>Nil,XmlChildEx ( oRoot , "_"+"BOLETIM" ):_VALUE:TEXT,Nil)
	nQtd1    := If(XmlChildEx ( oRoot , "_"+"QTDTRB1" )<>Nil,XmlChildEx ( oRoot , "_"+"QTDTRB1" ):_VALUE:TEXT,Nil)
	nQtd2    := If(XmlChildEx ( oRoot , "_"+"QTDTRB2" )<>Nil,XmlChildEx ( oRoot , "_"+"QTDTRB2" ):_VALUE:TEXT,Nil)
	cPrdOpr  := If(XmlChildEx ( oRoot , "_"+"PRDOPR"  )<>Nil,XmlChildEx ( oRoot , "_"+"PRDOPR"  ):_VALUE:TEXT,Nil)
	nOpcx    := If(XmlChildEx ( oRoot , "_"+"TPOPER"  )<>Nil,XmlChildEx ( oRoot , "_"+"TPOPER"  ):_VALUE:TEXT,Nil) //3=Inclusao;5=Exclusao

	cEquipto := If(Type("cEquipto")=="U",'',cEquipto)
	dDataI   := If(Type("dDataI")=="U",'',If(STOD(dDataI)!=CTOD(""),STOD(dDataI),''))
	dDataF   := If(Type("dDataF")=="U",'',If(STOD(dDataF)!=CTOD(""),STOD(dDataF),''))
	cHoraI   := If(Type("cHoraI")=="U",'',cHoraI)
	cHoraF   := If(Type("cHoraF")=="U",'',cHoraF)
	cBoletim := If(Type("cBoletim")=="U",'',cBoletim)
	nQtd1    := If(Type("nQtd1")=="U",0,Val(nQtd1))
	nQtd2    := If(Type("nQtd2")=="U",0,Val(nQtd2))
	cPrdOpr  := If(Type("cPrdOpr")=="U",'',cPrdOpr)
	nOpcx    := Val(nOpcx)

	cEquipto += Space(TAMSX3("TY_CODBEM")[1]-Len(cEquipto))
	cBoletim += Space(TAMSX3("TP_BOLETIM")[1]-Len(cBoletim))
	cPrdOpr  += Space(TAMSX3("TY_PRODUTO")[1]-Len(cPrdOpr))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validacao dos parametros recebidos ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If nOpcx != 3 .And. nOpcx != 5
		aAdd(aProb,"Operação não corresponde a 3=Inclusão ou 5=Exclusão.")
	EndIf

	If Empty(cBoletim)
		aAdd(aProb,"Número do boletim não foi informado.")
	EndIf


	If nOpcx == 3

		dbSelectArea("ST9")
		dbSetOrder(01)
		If !dbSeek(xFilial("ST9")+cEquipto)
			aAdd(aProb,"Equipamento "+AllTrim(cEquipto)+" não localizado no cadastro de bens.")
		EndIf

		If Type("dDataF") <> "D"
			aAdd(aProb,"Data fim não informada.")
		ElseIf Type("dDataI") <> "D"
			If Empty(dDataI)
				dDataI := dDataF
			EndIf
		EndIf

		If Type("cHoraF") <> "C"
			aAdd(aProb,"Hora fim não informada.")
		ElseIf Type("dDataI") <> "D"
			dDataI := dDataF
		EndIf

		If Empty(cHoraF)
			aAdd(aProb,"Hora fim não informada.")
		ElseIf !NGVALHORA(cHoraF,.F.)
			aAdd(aProb,"Hora fim informada é inválida.")
		ElseIf Empty(cHoraI)
			cHoraI := MTOH(HTOM(cHoraF)-1)
		EndIf

		//---------------------------------------------

		If ST9->T9_TEMCONT <> "S"
			aAdd(aProb,"O bem informado não possui contador próprio.")
		EndIf

		If SB1->(dbSeek(xFilial("SB1")+cPrdOpr))
			If SG1->(!dbSeek(xFilial("SG1")+cPrdOpr))
				aAdd(aProb,"Produto informado não é produzido.")
			EndIf
		EndIf

		If nQtd1 > 0
			fCHKPOSLIM(cEquipto,nQtd1,1)
		EndIf

		If nQtd2 > 0
			fCHKPOSLIM(cEquipto,nQtd2,2)
		EndIf

	ElseIf nOpcx == 5

		dbSelectArea("STY")
		dbSetOrder(04)
		If !dbSeek(xFilial("STY")+cBoletim)
			aAdd(aProb,"Codigo do boletim "+AllTrim(cBoletim)+" não localizado.")
		EndIf

	EndIf

	//Impressao do log de erros
	If fRContErr(aProb)
		Return .F.
	EndIf


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Prepara variaveis dos parametros   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If nOpcx == 3

		RegToMemory("STY",.T.)

		M->TY_FILIAL  := xFilial("STY")
		M->TY_CODBEM  := cEquipto
		M->TY_PRODUTO := cPrdOpr
		M->TY_DATAINI := dDataI
		M->TY_HORAINI := cHoraI
		M->TY_DATAFIM := If(Empty(dDataF),dDataI,dDataF)
		M->TY_HORAFIM := If(Empty(cHoraF),cHoraI,cHoraF)
		M->TY_QUANTI1 := nQtd1
		M->TY_QUANTI2 := nQtd2
		M->TY_BOLETIM := cBoletim

	ElseIf nOpcx == 5

		//variaveis sao preparadas direto na exclusao (abaixo)

	EndIf



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validacao do retorno producao (STY)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If nOpcx == 3

		If Empty(M->TY_QUANTI1) .And. Empty(M->TY_QUANTI2)
			aAdd(aProb,"Obrigatório informar a quantidade de produção.")
		EndIf

		If M->TY_DATAFIM < M->TY_DATAINI
			aAdd(aProb,"Data fim deve ser maior ou igual a data início.")
		ElseIf M->TY_DATAFIM = M->TY_DATAINI .And. M->TY_HORAFIM <= M->TY_HORAINI
			aAdd(aProb,"Hora fim deve ser maior que a hora inicio.")
		EndIf

		dbSelectArea("STY")
		dbSetOrder(1)
		If dbSeek(M->TY_FILIAL+M->TY_CODBEM+M->TY_PRODUTO+DTOS(M->TY_DATAINI)+M->TY_HORAINI+DTOS(M->TY_DATAFIM)+M->TY_HORAFIM)
			If !Empty(M->TY_QUANTI1) .And. !Empty(M->TY_QUANTI2)
				If !Empty(STY->TY_QUANTI1) .And. !Empty(STY->TY_QUANTI2)
					aAdd(aProb,"Retorno de producao já existe para os Contadores 1 e 2.")
				EndIf
			ElseIf !Empty(M->TY_QUANTI1)
				If !Empty(STY->TY_QUANTI1)
					aAdd(aProb,"Retorno de producao já existe para o Contador 1.")
				EndIf
			ElseIf !Empty(M->TY_QUANTI2)
				If !Empty(STY->TY_QUANTI2)
					aAdd(aProb,"Retorno de producao já existe para o Contador 2.")
				EndIf
			EndIf
		Else
			If dbSeek(M->TY_FILIAL+M->TY_CODBEM+M->TY_PRODUTO)
				While !Eof() .And. STY->TY_FILIAL  == xFilial("STY") .And.;
				STY->TY_CODBEM  == M->TY_CODBEM .And. STY->TY_PRODUTO == M->TY_PRODUTO .And. !lProb

					If M->TY_DATAFIM < STY->TY_DATAFIM
						If M->TY_DATAFIM = STY->TY_DATAINI
							If M->TY_HORAFIM >= STY->TY_HORAINI
								//Cheka se intervalo e refente ao contador informado
								lProb := NG380CKCON()
							EndIf
						ElseIf M->TY_DATAINI > STY->TY_DATAINI
							//Cheka se intervalo e refente ao contador informado
							lProb := NG380CKCON()
						ElseIf M->TY_DATAFIM > STY->TY_DATAINI
							//Cheka se intervalo e refente ao contador informado
							lProb := NG380CKCON()
						EndIf
					Else
						If M->TY_DATAFIM > STY->TY_DATAFIM
							If M->TY_DATAINI = STY->TY_DATAFIM
								If M->TY_HORAINI <= STY->TY_HORAFIM
									//Cheka se intervalo e refente ao contador informado
									lProb := NG380CKCON()
								EndIf
							Else
								If M->TY_DATAINI < STY->TY_DATAFIM
									//Cheka se intervalo e refente ao contador informado
									lProb := NG380CKCON()
								EndIf
							EndIf
						Else
							If M->TY_DATAINI > STY->TY_DATAINI
								If M->TY_DATAFIM = STY->TY_DATAFIM
									If M->TY_DATAINI = STY->TY_DATAFIM
										If M->TY_HORAINI <= STY->TY_HORAFIM
											//Cheka se intervalo e refente ao contador informado
											lProb := NG380CKCON()
										EndIf
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
					If M->TY_DATAINI < STY->TY_DATAINI
						If M->TY_DATAFIM = STY->TY_DATAINI
							If M->TY_HORAFIM >= STY->TY_HORAINI
								//Cheka se intervalo e refente ao contador informado
								lProb := NG380CKCON()
							EndIf
						Else
							If M->TY_DATAFIM = STY->TY_DATAFIM
								//Cheka se intervalo e refente ao contador informado
								lProb := NG380CKCON()
							EndIf
						EndIf
					Else
						If M->TY_DATAINI > STY->TY_DATAINI
							If M->TY_DATAINI <> STY->TY_DATAFIM
								If M->TY_DATAFIM = STY->TY_DATAFIM
									//Cheka se intervalo e refente ao contador informado
									lProb := NG380CKCON()
								EndIf
							EndIf
						Else
							If M->TY_DATAINI = STY->TY_DATAINI
								If M->TY_DATAFIM < STY->TY_DATAFIM
									//Cheka se intervalo e refente ao contador informado
									lProb := NG380CKCON()
								EndIf
							EndIf
						EndIf
					EndIf
					If M->TY_DATAINI = STY->TY_DATAINI .And. M->TY_DATAFIM = STY->TY_DATAFIM
						If STY->TY_DATAINI = STY->TY_DATAFIM //DATAS IGUAIS MESMO DIA
							If M->TY_HORAFIM >= STY->TY_HORAINI  //INICIO DE ARQUIVO
								If M->TY_HORAINI < STY->TY_HORAINI
									//Cheka se intervalo e refente ao contador informado
									lProb := NG380CKCON()
								EndIf
							EndIf
							If M->TY_HORAINI <= STY->TY_HORAFIM   //FINAL DE ARQUIVO
								If M->TY_HORAFIM > STY->TY_HORAFIM
									//Cheka se intervalo e refente ao contador informado
									lProb := NG380CKCON()
								EndIf
							EndIf
							If M->TY_HORAINI >= STY->TY_HORAINI
								If M->TY_HORAFIM <= STY->TY_HORAFIM
									//Cheka se intervalo e refente ao contador informado
									lProb := NG380CKCON()
								EndIf
							EndIf
						Else //DATAS IGUAIS DIAS DIFERENTE
							If M->TY_HORAINI >= STY->TY_HORAINI
								//Cheka se intervalo e refente ao contador informado
								lProb := NG380CKCON()
							Else
								If M->TY_HORAFIM <= STY->TY_HORAFIM
									//Cheka se intervalo e refente ao contador informado
									lProb := NG380CKCON()
								EndIf
							EndIf
							If M->TY_HORAINI <= STY->TY_HORAINI .And. M->TY_HORAFIM >= STY->TY_HORAFIM
								//Cheka se intervalo e refente ao contador informado
								lProb := NG380CKCON()
							EndIf
						EndIf
					Else
						If M->TY_DATAINI = STY->TY_DATAINI .And. M->TY_DATAFIM = STY->TY_DATAINI
							If M->TY_HORAFIM >= STY->TY_HORAINI
								//Cheka se intervalo e refente ao contador informado
								lProb := NG380CKCON()
							EndIf
						EndIf
					EndIf
					dbSelectArea("STY")
					dbSkip()
				End
			EndIf
		EndIf

		//Impressao do log de erros
		If fRContErr(aProb)
			Return .F.
		EndIf

		//Valida se as informacoes do retorno sao validas para efetuar
		//o retorno com base no historico de contador do bem
		If !Empty(M->TY_QUANTI1)
			If !NG380CKINT(1)
				//Impressao do log de erros
				fRContErr(aProb)
				Return .F.
			Else
				nREGVAL1 := nREGISHI
			EndIf
		EndIf

		If !Empty(M->TY_QUANTI2)
			If !NG380CKINT(2)
				//Impressao do log de erros
				fRContErr(aProb)
				Return .F.
			Else
				nREGVAL2 := nREGISHI
			EndIf
		EndIf

		//Chama a funcao que cria o registro de producao = 0
		If Len(aRETOMQP) > 0
			For xz := 1 To Len(aRETOMQP)
				//Contador 1
				If aRETOMQP[xz][3] = 1
					nREGVAL1 := NGATHMQP(M->TY_CODBEM,aRETOMQP[xz][1],aRETOMQP[xz][2],1,nREGVAL1,3)
					//Contador 2
				Else
					nREGVAL2 := NGATHMQP(M->TY_CODBEM,aRETOMQP[xz][1],aRETOMQP[xz][2],2,nREGVAL2,3)
				EndIf
			Next
		EndIf

		//Verifica se tipo do retorno e' produto
		dbSelectArea("SB1")
		dbSetOrder(01)
		If dbSeek(xFilial("SB1")+M->TY_PRODUTO)
			M->TY_TIPOPRO := "S"
		Else
			M->TY_TIPOPRO := "N"
		EndIf

		//Grava novo registro na STY
		dbSelectArea("STY")
		RecLock("STY",.T.)
		For nX := 1 To FCOUNT()
			nY := "M->" + FieldName(nX)
			FieldPut(nX, &nY.)
		Next nX
		STY->(MsUnLock())

	EndIf


	//---------------------------------------------------------------

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualizacao de contadores e hist.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If nOpcx == 3

		dbSelectArea("ST9")
		dbSetOrder(01)
		dbSeek(xFilial("ST9")+STY->TY_CODBEM)

		//Busca Fator de Desgaste por Producao
		dbSelectArea("STR")
		dbSetOrder(1)
		If dbSeek( xFilial("STR") + Space(TAMSX3("TR_BEMFAMI")[1]) + STY->TY_CODBEM + STY->TY_PRODUTO)
			nFator := If(STR->TR_FATOR <= 0.00, 1, STR->TR_FATOR)
		Else
			If dbSeek( xFilial("STR") + ST9->T9_CODFAMI + Space(TAMSX3("T9_CODBEM")[1]) + STY->TY_PRODUTO)
				nFator := If(STR->TR_FATOR <= 0.00, 1, STR->TR_FATOR)
			EndIf
		EndIf

		nQUANT1 := STY->TY_QUANTI1 * nFator
		nQUANT2 := STY->TY_QUANTI2 * nFator

		dbSelectArea("STY")
		RecLock("STY",.F.)
		STY->TY_FATOR := nFator
		MsUnlock("STY")

		If !Empty(STY->TY_QUANTI1)
			//Inclui o registro novo e recalcula variacao dia do Contador 1
			NG380ATUHI(STY->TY_CODBEM,STY->TY_DATAFIM,STY->TY_HORAFIM,1,nREGVAL1,nOpcX,STY->TY_QUANTI1,nQUANT1,,)

			dbSelectArea("ST9")
			dbSetOrder(1)
			If dbSeek(xFilial("ST9")+STY->TY_CODBEM)
				nLIMCPAI1 := ST9->T9_LIMICON  //Limite de contador do bem pai
				nCONT1PAT := ST9->T9_POSCONT  //Contador atual do bem pai
			EndIf
		EndIf

		If !Empty(STY->TY_QUANTI2)

			//Inclui o registro novo e recalcula variacao dia do Contador 2
			NG380ATUHI(STY->TY_CODBEM,STY->TY_DATAFIM,STY->TY_HORAFIM,2,nREGVAL2,nOpcX,STY->TY_QUANTI2,nQUANT2, , )

			dbSelectArea("TPE")
			dbSetOrder(1)
			If dbSeek(xFilial("TPE")+STY->TY_CODBEM)
				nLIMCPAI2 := TPE->TPE_LIMICO  //Limite de contador do bem pai
				nCONT2PAT := TPE->TPE_POSCON  //Contador atual do bem pai
			EndIf
		EndIf

		//Funcao que Retorna os bens que estava ou estao na estrutura apartir da data fim
		//e hora fim da producao
		aESTRU380 := NGCOMPPCONT(STY->TY_CODBEM,STY->TY_DATAFIM,STY->TY_HORAFIM)

		//Atualiza os bens filhos da estrutura correspondentes ao bem da producao
		For xz := 1 To Len(aESTRU380)

			If !Empty(STY->TY_QUANTI1)
				dbSelectArea("ST9")
				dbSetOrder(1)
				If dbSeek(xFilial("ST9")+aESTRU380[xz][1])

					nPOS := aSCAN(aBENSFILP,{|x|(x[1])== aESTRU380[xz][1] .And. (x[2]) == 1 })

					lACHOU := .F.
					If nPOS > 0
						lACHOU := .T.
					Else
						Aadd(aBENSFILP,{aESTRU380[xz][1],1})
					EndIf

					//Processa os registros do historico para o bem filho adicionando a producao
					NGESTR380(aESTRU380[xz][1],aESTRU380[xz][2],aESTRU380[xz][3],aESTRU380[xz][4],;
					aESTRU380[xz][5],STY->TY_DATAFIM,STY->TY_HORAFIM,1,STY->TY_QUANTI1,nQUANT1, , ,;
					3,lACHOU,nLIMCPAI1,nCONT1PAT)
				EndIf
			EndIf

			If !Empty(STY->TY_QUANTI2)
				dbSelectArea("TPE")
				dbSetOrder(1)
				If dbSeek(xFilial("TPE")+aESTRU380[xz][1])

					nPOS := aSCAN(aBENSFILP,{|x|(x[1])== aESTRU380[xz][1] .And. (x[2]) == 2 })

					lACHOU := .F.
					If nPOS > 0
						lACHOU := .T.
					Else
						aAdd(aBENSFILP,{aESTRU380[xz][1],2})
					EndIf

					//Processa os registros do historico para o bem filho adicionando a producao
					NGESTR380(aESTRU380[xz][1],aESTRU380[xz][2],aESTRU380[xz][3],aESTRU380[xz][4],;
					aESTRU380[xz][5],STY->TY_DATAFIM,STY->TY_HORAFIM,2,STY->TY_QUANTI2,nQUANT2, , ,;
					3,lACHOU,nLIMCPAI2,nCONT2PAT)
				EndIf
			EndIf
		Next

		//GERA O.S AUTOMATICA POR CONTADOR
		If !Empty(STY->TY_QUANTI1)
			If cGERAPREV = "S" .Or. cGERAPREV = "C"
				If lChkOSAut //NGCONFOSAUT(cGERAPREV)  //verifica a existencia de OS automatica por contador
					NGGEROSAUT(STY->TY_CODBEM,STY->TY_QUANTI1)
				EndIf
			EndIf
		Else
			If cGERAPREV = "S" .Or. cGERAPREV = "C"
				If lChkOSAut //NGCONFOSAUT(cGERAPREV)  //verifica a existencia de OS automatica por contador
					NGGEROSAUT(STY->TY_CODBEM,STY->TY_QUANTI2)
				EndIf
			EndIf
		EndIf

	ElseIf nOpcX == 5  //EXCLUSAO

		dbSelectArea("STY")
		dbSetOrder(04)
		dbSeek(xFilial("STY")+cBoletim)
		While STY->(!Eof()) .And. STY->TY_FILIAL == xFilial("STY") .And. STY->TY_BOLETIM == cBoletim

			cBEMSTY   := STY->TY_CODBEM
			dDAFIMSTY := STY->TY_DATAFIM
			cHOFIMSTY := STY->TY_HORAFIM
			dDAINISTY := STY->TY_DATAINI
			cHOINISTY := STY->TY_HORAINI
			nQUAT1STY := STY->TY_QUANTI1
			nQUAT2STY := STY->TY_QUANTI2
			nFATORSTY :=If(STY->TY_FATOR <= 0.00, 1,STY->TY_FATOR)


			//Procura data e hora com producao 0
			vDATA380 := NGCALHDT(dDAINISTY,cHOINISTY,2)

			If !Empty(nQUAT1STY)

				//Exclui o registro com producao 0 historico do bem e recalcula acumulado, contador e variacao
				//apartir do registro deletado
				NGATHMQP(cBEMSTY,vDATA380[1],vDATA380[2],1,,nOpcX)

				//Exclui o registro relacionado no historico do bem e recalcula acumulado, contador e variacao
				//apartir do registro deletado
				NG380ATUHI(cBEMSTY,dDAFIMSTY,cHOFIMSTY,1, ,nOpcX, , ,;
				nQUAT1STY,nQUAT1STY * nFATORSTY)

				dbSelectArea("ST9")
				dbSetOrder(1)
				If dbSeek(xFilial("ST9")+cBEMSTY)
					nLIMCPAI1 := ST9->T9_LIMICON  //Limite de contador do bem pai
				EndIf

			EndIf

			If !Empty(nQUAT2STY)

				//Exclui o registro com producao 0 historico do bem e recalcula acumulado, contador e variacao
				//apartir do registro deletado
				NGATHMQP(cBEMSTY,vDATA380[1],vDATA380[2],2,,nOpcX)

				//Exclui o registro relacionado no historico do bem e recalcula acumulado, contador e variacao
				//apartir do registro deletado
				NG380ATUHI(cBEMSTY,dDAFIMSTY,cHOFIMSTY,2, ,nOpcX, , ,;
				nQUAT2STY,nQUAT2STY * nFATORSTY)

				dbSelectArea("TPE")
				dbSetOrder(1)
				If dbSeek(xFilial("TPE")+cBEMSTY)
					nLIMCPAI2 := TPE->TPE_LIMICO  //Limite de contador do bem pai
				EndIf

			EndIf

			//Funcao que Retorna os bens que estava ou estao na estrutura apartir da data fim
			//e hora fim da producao
			aESTRU380 := NGCOMPPCONT(cBEMSTY,dDAFIMSTY,cHOFIMSTY)

			//Atualiza os bens filhos da estrutura correspondentes ao bem da producao
			For xz := 1 To Len(aESTRU380)

				If !Empty(nQUAT1STY)
					dbSelectArea("ST9")
					dbSetOrder(1)
					If dbSeek(xFilial("ST9")+aESTRU380[xz][1])

						nPOS := aSCAN(aBENSFILP,{|x|(x[1])== aESTRU380[xz][1] .And. (x[2]) == 1 })

						lACHOU := .F.
						If nPOS > 0
							lACHOU := .T.
						Else
							Aadd(aBENSFILP,{aESTRU380[xz][1],1})
						EndIf

						//Processa os registros do historico para o bem filho adicionando aproducao
						NGESTR380(aESTRU380[xz][1],aESTRU380[xz][2],aESTRU380[xz][3],aESTRU380[xz][4],;
						aESTRU380[xz][5],dDAFIMSTY,cHOFIMSTY,1, , ,nQUAT1STY,nQUAT1STY * nFATORSTY,;
						5,lACHOU,nLIMCPAI1)
					EndIf
				EndIf

				If !Empty(nQUAT2STY)
					dbSelectArea("TPE")
					dbSetOrder(1)
					If dbSeek(xFilial("TPE")+aESTRU380[xz][1])

						nPOS := aSCAN(aBENSFILP,{|x|(x[1])== aESTRU380[xz][1] .And. (x[2]) == 2 })

						lACHOU := .F.
						If nPOS > 0
							lACHOU := .T.
						Else
							Aadd(aBENSFILP,{aESTRU380[xz][1],2})
						EndIf

						//Processa os registros do historico para o bem filho adicionando aproducao
						NGESTR380(aESTRU380[xz][1],aESTRU380[xz][2],aESTRU380[xz][3],aESTRU380[xz][4],;
						aESTRU380[xz][5],dDAFIMSTY,cHOFIMSTY,2, , ,nQUAT2STY,nQUAT2STY * nFATORSTY,;
						5,lACHOU,nLIMCPAI2)

					EndIf
				EndIf
			Next


			dbSelectArea("STY")
			RecLock("STY",.F.)
			STY->(dbDelete())
			MsUnLock("STY")

			STY->(dbSkip())

		EndDo

	EndIf

	RestArea(aArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fCHKPOSLIM³ Autor ³ Felipe Nathan Welter  ³ Data ³ 15/09/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consistˆncia da posicao do contador com o limite           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºObs.      ³ Baseado na rotina CHKPOSLIM do MNTUTIL                     º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ cCODBEM  - Codigo do bem                                   ³±±
±±³          ³ nPOSCON  - Valor do contador                               ³±±
±±³          ³ nIndCont - Indicacao de qual contador 1 ou 2               ³±±
±±³          ³ cFilTroc - Filial de troca de acesso          - Nao Obrig. ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fCHKPOSLIM(cCodBem,nPoscon,nIndCont,cFilTroc)
	Local aArea := GetArea()
	Local aVetCon, cFilCon
	Local lRet := .T.

	Default nIndCont := 1

	aVetCon := IIf(nIndCont = 1,;
	{"ST9","ST9->T9_LIMICON"},;
	{"TPE","TPE->TPE_LIMICO"})

	dbSelectArea(aVetCon[1])
	dbSetOrder(1)
	dbSeek(NGTROCAFILI(aVetCon[1],cFilTroc)+cCodBem)

	If (nIndCont == 1 .And. ST9->T9_TEMCONT<>'N') .Or. (nIndCont == 2)
		If nPoscon > &(aVetCon[2])
			aAdd(aProb,"Contador informado é maior do que o Limite do Contador "+cValToChar(nIndCont)+;
			" - Contador Informado -> "+cValToChar(nPOSCON)+;
			" Limite do Contador -> "+cValToChar(&(aVetCon[2]))+". ")
			lRet := .F.
		EndIf
	EndIf

	RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡…o    ³NGCALHDT  ºAutor  ³Felipe Nathan Welterº Data ³  15/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula a hora e data somando ou diminuindo um minuto da    º±±
±±º          ³hora                                                        º±±
±±ºÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³dDATACAL  = Data fim da producao                            º±±
±±º          ³cHORACAL  = Hora fim da producao                            º±±
±±º          ³nTIPOCAL  = Tipo de Calculo (1- Soma um minuto na hora,     º±±
±±º          ³            2- Diminui um minuto na hora                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObs.      ³Baseado na rotina NGCALHDT do MNTA380                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³NGPimsRCnt                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function NGCALHDT(dDATACAL,cHORACAL,nTIPOCAL)

	Local dDTA380  := CTOD("  /  /  ")
	Local cHORA380 := "  :  "

	If nTIPOCAL = 1

		//Soma 1 minuto na hora
		If Alltrim(cHORACAL) == "23:59"
			dDTA380  := dDATACAL + 1
			cHORA380 := "00:00"
		Else
			dDTA380  := dDATACAL
			cHORA380 := MTOH(HTOM(cHORACAL)+1) //Soma 1 minuto na hora
		EndIf

	Else

		//Diminui 1 minuto na hora
		If Alltrim(cHORACAL) == "00:00"
			dDTA380  := dDATACAL - 1
			cHORA380 := "23:59"
		Else
			dDTA380  := dDATACAL
			cHORA380 := MTOH(HTOM(cHORACAL)-1) //Diminui 1 minuto na hora
		EndIf

	EndIf

Return {dDTA380,ChORA380}


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡…o    ³NG380CKINTºAutor  ³Felipe Nathan Welterº Data ³  14/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se o intervalo de data da producao e valido para     º±±
±±º          ³efetuar a producao                                          º±±
±±ºÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³nTCONT = Tipo de contador (1= Contador 1 ; 2= Contador 2    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObs.      ³Baseado na rotina NG380CKINT do MNTA380                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³NGPimsRCnt                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function NG380CKINT(nTpCont)

	Local vARQUI := If(nTpCont = 1,{'STP','STP->TP_FILIAL','STP->TP_CODBEM',;
	'STP->TP_DTLEITU','STP->TP_HORA'},;
	{'TPP','TPP->TPP_FILIAL','TPP->TPP_CODBEM',;
	'TPP->TPP_DTLEIT','TPP->TPP_HORA'})

	nREGISHI := 0
	dbSelectArea(vARQUI[1])
	dbSetOrder(05)
	If dbSeek(xFilial(vARQUI[1])+M->TY_CODBEM+DTOS(M->TY_DATAFIM)+M->TY_HORAFIM)

		aAdd(aProb,"Já existe registro com mesma informação no histórico de contador do bem. Para o bem + data fim + hora fim do Contador "+cValToChar(nTpCont)+".")
		Return .F.
	Else
		dbSeek(xFilial(vARQUI[1])+M->TY_CODBEM+DTOS(M->TY_DATAINI)+M->TY_HORAINI,.T.)
		If Eof()
			dbSkip(-1)
		Else
			If &(vARQUI[2]) = xFILIAL(vARQUI[1]) .And. &(vARQUI[3]) <> M->TY_CODBEM
				dbSkip(-1)
			EndIf
		EndIf
		If &(vARQUI[2]) = xFILIAL(vARQUI[1]) .And. &(vARQUI[3]) = M->TY_CODBEM
			//Verifica se a producao e valida tendo que ter um registro anterior a producao
			nREGVAL := Recno()
			dbSkip(-1)
			If Bof()
				dbGoTo(nREGVAL)
				If !Eof().And. &(vARQUI[2]) = xFILIAL(vARQUI[1]) .And. &(vARQUI[3]) = M->TY_CODBEM
					If &(vARQUI[4]) > M->TY_DATAINI  .Or. (&(vARQUI[4]) = M->TY_DATAINI  .And. &(vARQUI[5]) > M->TY_HORAINI)
						aAdd(aProb,"Retorno de produção não pode ser efetuado. Não existe registro"+;
						" anterior a produção no histórico de contador do bem para o Contador "+cValToChar(nTpCont)+".")
						Return .F.
					EndIf
				EndIf
			ElseIf !Bof() .And. &(vARQUI[2]) = xFILIAL(vARQUI[1]) .And. &(vARQUI[3]) <> M->TY_CODBEM
				aAdd(aProb,"O retorno de produção não pode ser efetuado. Não existe registro anterior a produção no histórico de contador do bem para o Contador "+cValToChar(nTpCont)+".")
				Return .F.
			Else
				dbSkip()
			EndIf
			If M->TY_DATAINI > dDataBase
				aAdd(aProb,"A data início informada é maior que a data atual.")
				Return .F.
			EndIf
			If M->TY_DATAINI = dDATABASE .And. M->TY_HORAINI > Time()
				aAdd(aProb,"A Hora início informada é maior que a hora atual.")
				Return .F.
			EndIf
			If M->TY_DATAFIM > dDataBase
				aAdd(aProb,"A data fim informada é maior que a data atual.")
				Return .F.
			EndIf
			If M->TY_DATAFIM = dDATABASE .And. M->TY_HORAFIM > Time()
				aAdd(aProb,"A Hora fim informada é maior que a hora atual.")
				Return .F.
			EndIf
			lTREGINT := .F.
			lULTIREG := .F.
			nREGISHI := 0

			//Verifica se tem algum registro no intervalo das datas do retorno da producao
			While !Eof() .And. &(vARQUI[2]) = xFILIAL(vARQUI[1]) .And. &(vARQUI[3]) = M->TY_CODBEM .And.;
			&(vARQUI[4]) <= M->TY_DATAFIM .And. &(vARQUI[5]) <= M->TY_HORAFIM .And. !lTREGINT
				If DTOS(&(vARQUI[4]))+ &(vARQUI[5]) < DTOS(M->TY_DATAINI)+M->TY_HORAINI
					dbSkip()
					Loop
				Else
					lTREGINT := .T.
				EndIf
				dbSelectArea(vARQUI[1])
				dbSkip()
			End
			If &(vARQUI[2]) = xFILIAL(vARQUI[1]) .And. &(vARQUI[3]) <> M->TY_CODBEM
				lULTIREG := .T.
				dbSkip(-1)
			Else
				If &(vARQUI[4]) >= M->TY_DATAFIM
					If &(vARQUI[4]) = M->TY_DATAFIM  .And. &(vARQUI[5]) > M->TY_HORAFIM
						dbSkip(-1)
					ElseIf &(vARQUI[4]) > M->TY_DATAFIM
						dbSkip(-1)
					EndIf
				EndIf
				If !lULTIREG
					dbSkip()
					If Eof()
						lULTIREG := .T.
					ElseIf !Eof() .And. &(vARQUI[2]) = xFILIAL(vARQUI[1]) .And. &(vARQUI[3]) <> M->TY_CODBEM
						lULTIREG := .T.
					EndIf
					dbSkip(-1)
				EndIf
			EndIf

			nREGISHI := Recno()

			If lTREGINT
				aAdd(aProb,"O retorno de produção não pode ser efetuado. Existe registro"+;
				" no histórico de contador do bem entre o intervalo de data"+;
				" informada no retorno de produção para o Contador "+cValToChar(nTpCont)+".")
				Return .F.
			Else
				If cCONSMAQP == "S" //Consiste retorno de producao com maquina parada
					If lULTIREG
						//Calcula data e hora inicio da producao
						vDTAINI   := NGCALHDT(&(vARQUI[4]),&(vARQUI[5]),1)
						dDTINTINI := vDTAINI[1]
						cHRINTINI := vDTAINI[2]
						//Calcula data e hora fim da producao
						vDTAFIM   := NGCALHDT(M->TY_DATAINI,M->TY_HORAINI,2)
						dDTINTFIM := vDTAFIM[1]
						cHRINTFIM := vDTAFIM[2]
						If M->TY_DATAINI <> dDTINTINI .Or. M->TY_HORAINI <> cHRINTINI
							aAdd(aProb,"Nao há retorno de produção para o Contador "+cValToChar(nTpCont)+" do bem no período"+;
							" que vai de: "+DTOC(dDTINTINI)+" "+cHRINTFIM+" a "+DTOC(dDTINTFIM)+" "+cHRINTFIM+;
							" Dt.Ult.Lanc.Historico...:  "+DTOC(&(vARQUI[4]))+;
							" Hr.Ult.Lanc.Historico...:  "+&(vARQUI[5]))
							//"Confirma o retorno com bem parado ?" -> nesse caso, por ser automatico, sempre confirma)
							Aadd(aRETOMQP,{dDTINTFIM,cHRINTFIM,nTpCont})
						EndIf
					EndIf
				EndIf
			EndIf
		Else
			aAdd(aProb,"O retorno de producao nao pode ser efetuado. Nao existe nenhum registro no historico de contador do bem para o Contador "+cValToChar(nTpCont)+".")
			Return .F.
		EndIf
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡…o    ³NG380CKCONºAutor  ³Felipe Nathan Welterº Data ³  13/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se intervalo do retorno de producao e' referente aoº±±
±±º          ³ao contador informado na producao                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObs.      ³Baseado na rotina NG380CKCON do MNTA380                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³NG380CKDAT( )                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function NG380CKCON()

	Local lProb := .F.

	If !Empty(M->TY_QUANTI1) .And. !Empty(M->TY_QUANTI2)
		If !Empty(STY->TY_QUANTI1) .And. !Empty(STY->TY_QUANTI2)
			lProb := .T.
			aAdd(aProb,"Ja existe Retorno de Producao entre o intervalo de data e hora para o contador 1 e 2.")
		EndIf
	ElseIf !Empty(M->TY_QUANTI1)
		If !Empty(STY->TY_QUANTI1)
			lProb := .T.
			aAdd(aProb,"Ja existe Retorno de Producao entre o intervalo de data e hora para o contador 1.")
		EndIf
	ElseIf !Empty(M->TY_QUANTI2)
		If !Empty(STY->TY_QUANTI2)
			lProb := .T.
			aAdd(aProb,"Ja existe Retorno de Producao entre o intervalo de data e hora para o contador 2.")
		EndIf
	EndIf
Return lProb





//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//  Importacao de Quilometragem do Equipamento (Informe Producao)
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGPimsIOpr³ Autor ³ Felipe Nathan Welter  ³ Data ³  set/10  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de importacao de Desgaste de Producao (STR)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGPimsIOpr(cXml)

	Local aArea := GetArea()
	Local cError := '', cWarning := ''
	Local nX
	Local nFator := 1

	Private aProb := {}
	Private cCodFami, cEquipto, cProd, cNome, cTipPro
	Private lSched := !(Type("oMainWnd")=="O")

	//Gera o Objeto XML
	oXml := XmlParser( cXml, "_", @cError, @cWarning )

	oRoot := XmlChildEx ( oXml:_FORMMODEL_WEARANDTEARPROD, "_WEARANDTEARPROD" )

	//	cCodFami := If(XmlChildEx ( oRoot , "_"+"TR_BEMFAMI")<>Nil,XmlChildEx ( oRoot , "_"+"TR_BEMFAMI"):_VALUE:TEXT,Nil)
	//	cEquipto := If(XmlChildEx ( oRoot , "_"+"TR_CODBEM" )<>Nil,XmlChildEx ( oRoot , "_"+"TR_CODBEM" ):_VALUE:TEXT,Nil)
	cProd    := If(XmlChildEx ( oRoot , "_"+"TR_PRODUTO")<>Nil,XmlChildEx ( oRoot , "_"+"TR_PRODUTO"):_VALUE:TEXT,Nil)
	cNome    := If(XmlChildEx ( oRoot , "_"+"TR_NOME"   )<>Nil,XmlChildEx ( oRoot , "_"+"TR_NOME"   ):_VALUE:TEXT,Nil)
	//	nFator   := If(XmlChildEx ( oRoot , "_"+"TR_FATOR"  )<>Nil,XmlChildEx ( oRoot , "_"+"TR_FATOR"   ):_VALUE:TEXT,Nil)
	//	cTipPro  := If(XmlChildEx ( oRoot , "_"+"TR_TIPOPRO")<>Nil,XmlChildEx ( oRoot , "_"+"TR_TIPOPRO"):_VALUE:TEXT,Nil)


	cCodFami := ''
	cEquipto := ''
	//	cCodFami := If(Type("cCodFami")=="U",'',cCodFami)
	//	cEquipto := If(Type("cEquipto")=="U",'',cEquipto)
	cProd    := If(Type("cProd")=="U",'',cProd)
	cNome    := If(Type("cNome")=="U",'',cNome)
	//	nFator   := If(Type("nFator")=="U",0,Val(nFator))
	//	cTipPro  := If(Type("cTipPro")=="U",'',cTipPro)

	cCodFami += Space(TAMSX3("TR_BEMFAMI")[1]-Len(cCodFami))
	cEquipto += Space(TAMSX3("TR_CODBEM")[1]-Len(cEquipto))
	cProd    += Space(TAMSX3("TR_PRODUTO")[1]-Len(cProd))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Recebe o XML com produto e nome (no PIMS e' um ³
	//³ cadastro simples) e cadatra "Desgaste por Pro- ³
	//³ ducao - STR" para cada familia de todas as em- ³
	//³ presas e filiais do Protheus MNT.              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAreaSM0 := SM0->(GetArea())
	cEmpSM0 := cEmpAnt
	cFilSM0 := cFilAnt
	dbSelectArea("SM0")
	dbGoTop()
	While SM0->(!Eof())
		cEmpSTR := SM0->M0_CODIGO
		cFilSTR := SM0->M0_CODFIL
		NgPrepTbl({{"STR"},{"ST6"},{"SB1"},{"SG1"}},cEmpSTR,cFilSTR)

		//-------------------------------------
		dbSelectArea("ST6")
		dbSetOrder(01)
		dbGoTop()
		While ST6->(!Eof())
			lProb := .F.
			cCodFami := ST6->T6_CODFAMI
			nRecST6 := ST6->(RecNo())

			OldInclui := Inclui
			Inclui    := .T.  //X3_RELACAO do campo TR_FATOR
			RegToMemory("STR",.T.)  //Copy "STR" To Memory Blank
			Inclui    := OldInclui

			M->TR_FILIAL  := NGTROCAFILI("STR",cFilSTR,cEmpSTR)
			M->TR_BEMFAMI := cCodFami
			M->TR_CODBEM  := cEquipto
			M->TR_PRODUTO := cProd
			M->TR_NOME    := cNome
			M->TR_FATOR   := nFator

			dbSelectArea("SB1")
			dbSetOrder(01)
			If dbSeek(NGTROCAFILI("SB1",cFilSTR,cEmpSTR)+M->TR_PRODUTO)
				M->TR_TIPOPRO := "S"
			Else
				M->TR_TIPOPRO := "N"
			EndIf

			If SB1->(dbSeek(NGTROCAFILI("SB1",cFilSTR,cEmpSTR) + M->TR_PRODUTO))
				//verifica se o produto e produzido
				dbSelectArea("SG1")
				If !SG1->(dbSeek(NGTROCAFILI("SG1",cFilSTR,cEmpSTR) + M->TR_PRODUTO))
					aAdd(aProb,"Produto informado ("+AllTrim(M->TR_PRODUTO)+") não é produzido - Empresa: "+cEmpSTR+" Filial: "+cFilSTR)
					lProb := .T.
				EndIf
			EndIf

			//Grava/altera registro na STR
			If !lProb
				dbSelectArea("STR")
				dbSetOrder(01)
				lInsert := .T.
				If dbSeek(M->TR_FILIAL+M->TR_BEMFAMI+M->TR_CODBEM+M->TR_PRODUTO)
					lInsert := .F.
				EndIf

				RecLock("STR",lInsert)

				For nX := 1 To FCOUNT()
					//a estrutura da tabela operacao no PIMS nao possui fator de desgaste
					//a alteracao do fator, se necessaria, deve ser feita no MNT
					If lInsert .Or. (!lInsert .And. FieldName(nX) != "TR_FATOR")
						nY := "M->" + FieldName(nX)
						FieldPut(nX, &nY.)
					EndIf
				Next nX

				STR->(MsUnLock())
			EndIf
			//-------------------------------------

			dbSelectArea("ST6")
			dbSetOrder(01)
			dbGoTo(nRecST6)
			ST6->(dbSkip())

		EndDo

		dbSelectArea("SM0")
		SM0->(dbSkip())
	EndDo

	//Impressao do log de erros
	If fRContErr(aProb)
		Return .F.
	EndIf

	NgPrepTbl({{"STR"},{"ST6"},{"SB1"},{"SG1"}},cEmpSM0,cFilSM0)
	RestArea(aAreaSM0)
	RestArea(aArea)

Return Nil



//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//  Exportacao de Custos dos Equipamentos
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGPimsCstD³ Autor ³ Felipe Nathan Welter  ³ Data ³ 05/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta tela (dialog) para selecionar parametros para expor- ³±±
±±³          ³ tacao de custos (NGPimsCst)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGPimsCstD()

	Local oDlg, oCombo, oAno, oEqp, oTra
	Local aCombo 	:= {}
	Local oFont10B 	:= TFont():New("Arial",,-10,,.T.,,,,.T.,.F.)
	Local cOldEmp	:= cEmpAnt
	Local cEmp 		:= cEmpAnt
	Local cFil 		:= cFilAnt
	Local cMes 		:= StrZero(Month(Date()),2)
	Local cAno 		:= cValToChar(Year(Date()))
	Local cEqp 		:= Space(TAMSX3("T9_CODBEM")[1])
	Local cTra 		:= Space(TAMSX3("T9_CENTRAB")[1])
	Local nX
	Local cY

	For nX := 1 To 12
		cY := StrZero(nX,2)
		aAdd(aCombo,cY+"="+cMonth(STOD(cValToChar(Year(dDataBase))+cY+cY)))
	Next nX

	Define MsDialog oDlg From 0,0 to 225,370 Title "Exportação de Custos" Pixel

	oDlg:lEscClose := .F.

	oPnlA:=TPanel():New(00,00,,oDlg,,,,,RGB(255,255,255),1,1,.F.,.F.)
	oPnlA:Align := CONTROL_ALIGN_ALLCLIENT

	@ 10,08 To 85,152 Pixel Of oPnlA

	@ 20,10 SAY "Empresa" Pixel Of oPnlA FONT oFont10B Color CLR_BLUE
	@ 20,40 MsGet oEmp Var cEmp Picture "99" Size 20,08 Pixel Of oPnlA F3 "YM0" Valid (cEmpAnt := cEmp, ExistCpo("SM0",cEmp)) HASBUTTON
	@ 20,70 SAY "Filial" Pixel Of oPnlA FONT oFont10B Color CLR_BLUE
	@ 20,90 MsGet oFil Var cFil Picture "99" Size 20,08 Pixel Of oPnlA F3 "XM0" Valid ExistCpo("SM0",cEmp+cFil) HASBUTTON

	@ 35,10 SAY "Mês" Pixel Of oPnlA FONT oFont10B Color CLR_BLUE
	oCombo:= tComboBox():New(35,40,{|u|if(PCount()>0,cMes:=u,cMes)},aCombo,55,20,oPnlA,,{||.T.},,,,.T.,,,,{||.T.},,,,,'cMes')
	@ 35,105 SAY "Ano" Pixel Of oPnlA FONT oFont10B Color CLR_BLUE
	@ 35,120 MsGet oAno Var cAno Picture "9999" Size 20,08 Pixel Of oPnlA Valid !Empty(cAno)

	@ 50,10 SAY "Bem" Pixel Of oPnlA FONT oFont10B
	@ 50,40 MsGet oEqp Var cEqp Picture "@!" Size 60,08 Pixel Of oPnlA
	@ 65,10 SAY "C. Trab." Pixel Of oPnlA FONT oFont10B
	@ 65,40 MsGet oTra Var cTra Picture "@!" Size 50,08 Pixel Of oPnlA

	oButtonF1 := tButton():New(88,60,"OK",oPnlA,{||cEmpAnt := cOldEmp, NGPimsCst(cFil,cEmp,cMes,cAno,cEqp,cTra), oDlg:End()},26,11,,,,.T.)
	oButtonF2 := tButton():New(88,90,"Cancelar",oPnlA,{||cEmpAnt := cOldEmp, oDlg:End()},26,11,,,,.T.)

	Activate Dialog oDlg Centered

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGPimsCst³ Autor ³ Felipe Nathan Welter  ³ Data ³ 02/09/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera arquivo de exportacao de custos (MNT x PIMS)          ³±±
±±³          ³ PMDO-Preventiva Mão de Obra                                ³±±
±±³          ³ PTERC-Preventiva Terceiro                                  ³±±
±±³          ³ PFERR-Preventiva Ferramentas                               ³±±
±±³          ³ CMDO-Corretiva Mão de Obra                                 ³±±
±±³          ³ CTERC-Corretiva Terceiro                                   ³±±
±±³          ³ CFERR-Corretiva Ferramentas                                ³±±
±±³          ³ RMDO-Reforma Mão de Obra                                   ³±±
±±³          ³ RTERC-Reforma Terceiro                                     ³±±
±±³          ³ RFERR-Reforma Ferramentas                                  ³±±
±±³          ³ LUBR-Ordens de Servico de Lubrificacao                     ³±±
±±³          ³ PNEU-Ordens de Servico de Pneus                            ³±±
±±³          ³ ABST-Abastecimentos                                        ³±±
±±³          ³ MULTA-Multa                                                ³±±
±±³          ³ SNST-Sinistro                                              ³±±
±±³          ³ GPM - Grupo de Material                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³1.cFil - Filial a ser processada           *nao-obrigatorio ³±±
±±³          ³2.cEmp - Empresa a ser processada          *nao-obrigatorio ³±±
±±³          ³3.cMes - Mes para processamento            *nao-obrigatorio ³±±
±±³          ³4.cAno - Ano para processamento            *nao-obrigatorio ³±±
±±³          ³5.cEqp - Equipamento                       *nao-obrigatorio ³±±
±±³          ³6.cTra - Centro de Trabalho                *nao-obrigatorio ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGPimsCst(cFil,cEmp,cMes,cAno,cEqp,cTra)

	Local aArea := GetArea()
	Local nX

	Local cCodEmp	:= GetJobProfString('cCodEmp','99')
	Local cCodFil	:= GetJobProfString('cCodFil','01')
	Local aTables	:= {"STJ","STL","SB1","ST9","TRH","TRT","STS","STT","TRK",;
	"TRO","TRL","TRV","TRM","TQN","TQI","TRX","SBM"}
	Local cQuery := ""
	Local cIsNull := ""

	Private cAliasQry := GetNextAlias()
	Private cAliasQr2 := GetNextAlias()

	Private lSched := !(Type("oMainWnd")=="O")
	Private aDBF := {}

	//---------------------------------------------------------

	Default cFil := If(lSched,cCodFil,cFilAnt)
	Default cEmp := If(lSched,cCodEmp,cEmpAnt)
	Default cMes := StrZero(Month(Date()),2)
	Default cAno := cValToChar(Year(Date()))
	Default cEqp := ""
	Default cTra := ""

	cEqp += Space(TAMSX3("T9_CODBEM")[1]-Len(cEqp))
	cTra += Space(TAMSX3("T9_CENTRAB")[1]-Len(cTra))

	//Valida parametros Empresa e Filial
	If Empty(cEmp) .Or. Empty(cFil)
		If !lSched
			MsgStop( STR0002, STR0001 ) // Parâmetros EMPRESA e FILIAL não foram definidos. # Atenção
		EndIf
		RestArea(aArea)
		Return Nil
	EndIf

	//Prepara ambiente para modo schedule
	If lSched
		RPCSetType( 3 )	// Não consome licensa de uso
		RpcSetEnv( cCodEmp , cCodFil,,,"MNT",,aTables)
	EndIf

	cIsNull := If(TcGetDb() = "ORACLE","NVL",If(TcGetDb() $ "DB2","COALESCE","ISNULL"))

	//Realiza impressao de log de inconsistencias de falta de grupo
	If !fProdGroup(cFil,cEmp,cMes,cAno,cEqp,cTra)
		If !lSched
			If !MsgYesNo("Deseja prosseguir com o processo de exportar custos?","Atenção")
				RestArea(aArea)
				Return Nil
			EndIf
		EndIf
	EndIf

	aAdd(aDBF,{"CCUSTO","C",TAMSX3("T9_CCUSTO")[1] ,0})
	aAdd(aDBF,{"CTRAB" ,"C",TAMSX3("T9_CENTRAB")[1],0})
	aAdd(aDBF,{"CODBEM","C",TAMSX3("T9_CODBEM")[1] ,0})
	aAdd(aDBF,{"GRUPO" ,"C",TAMSX3("B1_GRUPO")[1]  ,0})
	aAdd(aDBF,{"QTD"   ,"N",3,0})
	aAdd(aDBF,{"TIPO"  ,"C",TAMSX3("T9_CCUSTO")[1] ,0})
	aAdd(aDBF,{"TOT"   ,"N",12,2})

	//Variavel recebe GetNextAlias()
	cAliasQry := GetNextAlias()
	//Intancia classe FWTemporaryTable
	oTmpQry := FWTemporaryTable():New( cAliasQry, aDBF )
	//Cria indices
	oTmpQry:AddIndex( "Ind01" , {"CCUSTO", "CTRAB","CODBEM","GRUPO"} )
	//Cria a tabela temporaria
	oTmpQry:Create()

	//---------------------------------------------------------

	//Tenta a criacao das tabelas a serem utilizadas
	aChkTbl := {"STJ","STL","SB1","ST9","TRH","TRK","TRO","TRL","TRV","TRM","TRT","STS","STT","TRX","TQN","TQI"}
	M985ChkTbl(aChkTbl,cEmp)

	//---------------------------------------------------------

	//PMDO-Preventiva Mão de Obra
	cQuery += " SELECT STJ.TJ_CCUSTO AS CCUSTO, STJ.TJ_CENTRAB AS CTRAB, STJ.TJ_CODBEM AS CODBEM, '' AS GRUPO, COUNT(*) AS QTD, "
	cQuery += "       'PMDO' AS TIPO, SUM(STL.TL_CUSTO) AS TOT "
	cQuery += "   FROM " + RetSqlName("STL") + " STL"
	cQuery += "   JOIN " + RetSqlName("STJ") + " STJ"
	cQuery += "     ON STL.TL_ORDEM + STL.TL_PLANO = STJ.TJ_ORDEM + STJ.TJ_PLANO "
	cQuery += "  WHERE SUBSTRING(STJ.TJ_DTMRFIM,5,2) = " + ValToSql(cMes)
	cQuery += "    AND SUBSTRING(STJ.TJ_DTMRFIM,1,4) = " + ValToSql(cAno)
	cQuery += "    AND STL.TL_FILIAL   = " + ValToSql(NGTROCAFILI("STL",cFil))
	cQuery += "    AND STJ.TJ_FILIAL   = " + ValToSql(NGTROCAFILI("STJ",cFil))
	cQuery += "    AND STL.TL_SEQRELA  > '0' "
	cQuery += "    AND STJ.TJ_SITUACA  = 'L' "
	cQuery += "    AND STJ.TJ_TERMINO  = 'S' "
	cQuery += "    AND STJ.TJ_PLANO    > '000000' "
	cQuery += "    AND STJ.TJ_ORDEPAI  = " + ValToSql(Space(TAMSX3("TJ_ORDEPAI")[1]))
	cQuery += "    AND STJ.TJ_LUBRIFI <> 'S' "
	cQuery += "    AND STL.TL_TIPOREG  = 'M' "

	If !Empty(cEqp)
		cQuery += " AND STJ.TJ_CODBEM = " + ValToSql(cEqp)
	EndIf

	If !Empty(cTra)
		cQuery += " AND STJ.TJ_CENTRAB = " + ValToSql(cTra)
	EndIf

	cQuery += "   STL.D_E_L_E_T_ <> '*' "
	cQuery += "   STJ.D_E_L_E_T_ <> '*' "
	cQuery += " GROUP BY STJ.TJ_CCUSTO, STJ.TJ_CENTRAB, STJ.TJ_CODBEM"

	cQuery += " UNION"
	//PTERC-Preventiva Terceiro
	cQuery += " SELECT STJ.TJ_CCUSTO AS CCUSTO, STJ.TJ_CENTRAB AS CTRAB, STJ.TJ_CODBEM AS CODBEM, '' AS GRUPO,"
	cQuery += " COUNT(*) AS QTD, 'PTERC' AS TIPO,"
	cQuery += " SUM(STL.TL_CUSTO) AS TOT"
	cQuery += " FROM "+RetSqlName("STL")+" STL "
	cQuery += " JOIN "+RetSqlName("STJ")+" STJ "
	cQuery += "   ON STL.TL_ORDEM+STL.TL_PLANO = STJ.TJ_ORDEM+STJ.TJ_PLANO "
	cQuery += " WHERE"
	cQuery += "   SUBSTRING(STJ.TJ_DTMRFIM,5,2) = '"+cMes+"' AND"
	cQuery += "   SUBSTRING(STJ.TJ_DTMRFIM,1,4) = '"+cAno+"' AND"
	cQuery += "   STL.TL_FILIAL = '"+NGTROCAFILI("STL",cFil)+"' AND"
	cQuery += "   STJ.TJ_FILIAL = '"+NGTROCAFILI("STJ",cFil)+"' AND"
	cQuery += "   STL.D_E_L_E_T_ <> '*' AND"
	cQuery += "   STJ.D_E_L_E_T_ <> '*' AND"
	cQuery += "      STL.TL_SEQRELA > '0' AND"
	cQuery += "      STJ.TJ_SITUACA = 'L' AND"
	cQuery += "      STJ.TJ_TERMINO = 'S' AND"
	cQuery += "      STJ.TJ_PLANO > '000000' AND"
	cQuery += "      STJ.TJ_ORDEPAI = '"+Space(TAMSX3("TJ_ORDEPAI")[1])+"' AND"
	cQuery += "      STJ.TJ_LUBRIFI <> 'S' AND"
	cQuery += "      STL.TL_TIPOREG = 'T'"
	If !Empty(cEqp)
		cQuery += " AND STJ.TJ_CODBEM = '"+cEqp+"'"
	EndIf
	If !Empty(cTra)
		cQuery += " AND STJ.TJ_CENTRAB = '"+cTra+"'"
	EndIf
	cQuery += " GROUP BY STJ.TJ_CCUSTO, STJ.TJ_CENTRAB, STJ.TJ_CODBEM"

	cQuery += " UNION"
	//PFERR-Preventiva Ferramentas
	cQuery += " SELECT STJ.TJ_CCUSTO AS CCUSTO, STJ.TJ_CENTRAB AS CTRAB, STJ.TJ_CODBEM AS CODBEM, '' AS GRUPO,"
	cQuery += " COUNT(*) AS QTD, 'PFERR' AS TIPO,"
	cQuery += " SUM(STL.TL_CUSTO) AS TOT"
	cQuery += " FROM " + RetSqlName("STL") + " STL"
	cQuery += " JOIN " + RetSqlName("STJ") + " STJ"
	cQuery += "   ON STL.TL_ORDEM+STL.TL_PLANO = STJ.TJ_ORDEM+STJ.TJ_PLANO "
	cQuery += " WHERE"
	cQuery += "   SUBSTRING(STJ.TJ_DTMRFIM,5,2) = '"+cMes+"' AND"
	cQuery += "   SUBSTRING(STJ.TJ_DTMRFIM,1,4) = '"+cAno+"' AND"
	cQuery += "   STL.TL_FILIAL = '"+NGTROCAFILI("STL",cFil)+"' AND"
	cQuery += "   STJ.TJ_FILIAL = '"+NGTROCAFILI("STJ",cFil)+"' AND"
	cQuery += "   STL.D_E_L_E_T_ <> '*' AND"
	cQuery += "   STJ.D_E_L_E_T_ <> '*' AND"
	cQuery += "      STL.TL_SEQRELA > '0' AND"
	cQuery += "      STJ.TJ_SITUACA = 'L' AND"
	cQuery += "      STJ.TJ_TERMINO = 'S' AND"
	cQuery += "      STJ.TJ_PLANO > '000000' AND"
	cQuery += "      STJ.TJ_ORDEPAI = '"+Space(TAMSX3("TJ_ORDEPAI")[1])+"' AND"
	cQuery += "      STJ.TJ_LUBRIFI <> 'S' AND"
	cQuery += "      STL.TL_TIPOREG = 'F'"
	If !Empty(cEqp)
		cQuery += " AND STJ.TJ_CODBEM = '"+cEqp+"'"
	EndIf
	If !Empty(cTra)
		cQuery += " AND STJ.TJ_CENTRAB = '"+cTra+"'"
	EndIf
	cQuery += " GROUP BY STJ.TJ_CCUSTO, STJ.TJ_CENTRAB, STJ.TJ_CODBEM"



	cQuery += " UNION"
	//CMDO-Corretiva Mão de Obra
	cQuery += " SELECT STJ.TJ_CCUSTO AS CCUSTO, STJ.TJ_CENTRAB AS CTRAB, STJ.TJ_CODBEM AS CODBEM, '' AS GRUPO,"
	cQuery += " COUNT(*) AS QTD, 'CMDO' AS TIPO,"
	cQuery += " SUM(STL.TL_CUSTO) AS TOT"
	cQuery += " FROM " + RetSqlName("STL") + " STL"
	cQuery += " JOIN " + RetSqlName("STJ") + " STJ"
	cQuery += "   ON STL.TL_ORDEM+STL.TL_PLANO = STJ.TJ_ORDEM+STJ.TJ_PLANO "
	cQuery += " WHERE"
	cQuery += "   SUBSTRING(STJ.TJ_DTMRFIM,5,2) = '"+cMes+"' AND"
	cQuery += "   SUBSTRING(STJ.TJ_DTMRFIM,1,4) = '"+cAno+"' AND"
	cQuery += "   STL.TL_FILIAL = '"+NGTROCAFILI("STL",cFil)+"' AND"
	cQuery += "   STJ.TJ_FILIAL = '"+NGTROCAFILI("STJ",cFil)+"' AND"
	cQuery += "   STL.D_E_L_E_T_ <> '*' AND"
	cQuery += "   STJ.D_E_L_E_T_ <> '*' AND"
	cQuery += "      STL.TL_SEQRELA > '0' AND"
	cQuery += "      STJ.TJ_SITUACA = 'L' AND"
	cQuery += "      STJ.TJ_TERMINO = 'S' AND"
	cQuery += "      STJ.TJ_PLANO = '000000' AND"
	cQuery += "      STJ.TJ_ORDEPAI = '"+Space(TAMSX3("TJ_ORDEPAI")[1])+"' AND"
	cQuery += "      STJ.TJ_LUBRIFI <> 'S' AND"
	cQuery += "      STL.TL_TIPOREG = 'M'"
	If !Empty(cEqp)
		cQuery += " AND STJ.TJ_CODBEM = '"+cEqp+"'"
	EndIf
	If !Empty(cTra)
		cQuery += " AND STJ.TJ_CENTRAB = '"+cTra+"'"
	EndIf
	cQuery += " GROUP BY STJ.TJ_CCUSTO, STJ.TJ_CENTRAB, STJ.TJ_CODBEM"

	cQuery += " UNION"
	//CTERC-Corretiva Terceiro
	cQuery += " SELECT STJ.TJ_CCUSTO AS CCUSTO, STJ.TJ_CENTRAB AS CTRAB, STJ.TJ_CODBEM AS CODBEM, '' AS GRUPO,"
	cQuery += " COUNT(*) AS QTD, 'CTERC' AS TIPO,"
	cQuery += " SUM(STL.TL_CUSTO) AS TOT"
	cQuery += " FROM " + RetSqlName("STL") + " STL"
	cQuery += " JOIN " + RetSqlName("STJ") + " STJ"
	cQuery += "   ON STL.TL_ORDEM+STL.TL_PLANO = STJ.TJ_ORDEM+STJ.TJ_PLANO "
	cQuery += " WHERE"
	cQuery += "   SUBSTRING(STJ.TJ_DTMRFIM,5,2) = '"+cMes+"' AND"
	cQuery += "   SUBSTRING(STJ.TJ_DTMRFIM,1,4) = '"+cAno+"' AND"
	cQuery += "   STL.TL_FILIAL = '"+NGTROCAFILI("STL",cFil)+"' AND"
	cQuery += "   STJ.TJ_FILIAL = '"+NGTROCAFILI("STJ",cFil)+"' AND"
	cQuery += "   STL.D_E_L_E_T_ <> '*' AND"
	cQuery += "   STJ.D_E_L_E_T_ <> '*' AND"
	cQuery += "      STL.TL_SEQRELA > '0' AND"
	cQuery += "      STJ.TJ_SITUACA = 'L' AND"
	cQuery += "      STJ.TJ_TERMINO = 'S' AND"
	cQuery += "      STJ.TJ_PLANO = '000000' AND"
	cQuery += "      STJ.TJ_ORDEPAI = '"+Space(TAMSX3("TJ_ORDEPAI")[1])+"' AND"
	cQuery += "      STJ.TJ_LUBRIFI <> 'S' AND"
	cQuery += "      STL.TL_TIPOREG = 'T'"
	If !Empty(cEqp)
		cQuery += " AND STJ.TJ_CODBEM = '"+cEqp+"'"
	EndIf
	If !Empty(cTra)
		cQuery += " AND STJ.TJ_CENTRAB = '"+cTra+"'"
	EndIf
	cQuery += " GROUP BY STJ.TJ_CCUSTO, STJ.TJ_CENTRAB, STJ.TJ_CODBEM"

	cQuery += " UNION"
	//CFERR-Corretiva Ferramentas
	cQuery += " SELECT STJ.TJ_CCUSTO AS CCUSTO, STJ.TJ_CENTRAB AS CTRAB, STJ.TJ_CODBEM AS CODBEM, '' AS GRUPO,"
	cQuery += " COUNT(*) AS QTD, 'CFERR' AS TIPO,"
	cQuery += " SUM(STL.TL_CUSTO) AS TOT"
	cQuery += " FROM " + RetSqlName("STL") + " STL"
	cQuery += " JOIN " + RetSqlName("STJ") + " STJ"
	cQuery += "   ON STL.TL_ORDEM+STL.TL_PLANO = STJ.TJ_ORDEM+STJ.TJ_PLANO "
	cQuery += " WHERE"
	cQuery += "   SUBSTRING(STJ.TJ_DTMRFIM,5,2) = '"+cMes+"' AND"
	cQuery += "   SUBSTRING(STJ.TJ_DTMRFIM,1,4) = '"+cAno+"' AND"
	cQuery += "   STL.TL_FILIAL = '"+NGTROCAFILI("STL",cFil)+"' AND"
	cQuery += "   STJ.TJ_FILIAL = '"+NGTROCAFILI("STJ",cFil)+"' AND"
	cQuery += "   STL.D_E_L_E_T_ <> '*' AND"
	cQuery += "   STJ.D_E_L_E_T_ <> '*' AND"
	cQuery += "      STL.TL_SEQRELA > '0' AND"
	cQuery += "      STJ.TJ_SITUACA = 'L' AND"
	cQuery += "      STJ.TJ_TERMINO = 'S' AND"
	cQuery += "      STJ.TJ_PLANO = '000000' AND"
	cQuery += "      STJ.TJ_ORDEPAI = '"+Space(TAMSX3("TJ_ORDEPAI")[1])+"' AND"
	cQuery += "      STJ.TJ_LUBRIFI <> 'S' AND"
	cQuery += "      STL.TL_TIPOREG = 'F'"
	If !Empty(cEqp)
		cQuery += " AND STJ.TJ_CODBEM = '"+cEqp+"'"
	EndIf
	If !Empty(cTra)
		cQuery += " AND STJ.TJ_CENTRAB = '"+cTra+"'"
	EndIf
	cQuery += " GROUP BY STJ.TJ_CCUSTO, STJ.TJ_CENTRAB, STJ.TJ_CODBEM"



	cQuery += " UNION"
	//RMDO-Reforma Mão de Obra
	cQuery += " SELECT STJ.TJ_CCUSTO AS CCUSTO, STJ.TJ_CENTRAB AS CTRAB, STJ.TJ_CODBEM AS CODBEM, '' AS GRUPO,"
	cQuery += " COUNT(*) AS QTD, 'RMDO' AS TIPO,"
	cQuery += " SUM(STL.TL_CUSTO) AS TOT"
	cQuery += " FROM " + RetSqlName("STL") + " STL"
	cQuery += " JOIN " + RetSqlName("STJ") + " STJ"
	cQuery += "   ON STL.TL_ORDEM+STL.TL_PLANO = STJ.TJ_ORDEM+STJ.TJ_PLANO "
	cQuery += " WHERE"
	cQuery += "   SUBSTRING(STJ.TJ_DTMRFIM,5,2) = '"+cMes+"' AND"
	cQuery += "   SUBSTRING(STJ.TJ_DTMRFIM,1,4) = '"+cAno+"' AND"
	cQuery += "   STL.TL_FILIAL = '"+NGTROCAFILI("STL",cFil)+"' AND"
	cQuery += "   STJ.TJ_FILIAL = '"+NGTROCAFILI("STJ",cFil)+"' AND"
	cQuery += "   STL.D_E_L_E_T_ <> '*' AND"
	cQuery += "   STJ.D_E_L_E_T_ <> '*' AND"
	cQuery += "      STL.TL_SEQRELA > '0' AND"
	cQuery += "      STJ.TJ_SITUACA = 'L' AND"
	cQuery += "      STJ.TJ_TERMINO = 'S' AND"
	cQuery += "      STJ.TJ_TIPOOS = 'B'  AND"
	cQuery += "      STJ.TJ_ORDEPAI <> '"+Space(TAMSX3("TJ_ORDEPAI")[1])+"' AND"
	cQuery += "      STL.TL_TIPOREG = 'M'"
	If !Empty(cEqp)
		cQuery += " AND STJ.TJ_CODBEM = '"+cEqp+"'"
	EndIf
	If !Empty(cTra)
		cQuery += " AND STJ.TJ_CENTRAB = '"+cTra+"'"
	EndIf
	cQuery += " GROUP BY STJ.TJ_CCUSTO, STJ.TJ_CENTRAB, STJ.TJ_CODBEM"

	cQuery += " UNION"
	//RTERC-Reforma Terceiro
	cQuery += " SELECT STJ.TJ_CCUSTO AS CCUSTO, STJ.TJ_CENTRAB AS CTRAB, STJ.TJ_CODBEM AS CODBEM, '' AS GRUPO,"
	cQuery += " COUNT(*) AS QTD, 'RTERC' AS TIPO,"
	cQuery += " SUM(STL.TL_CUSTO) AS TOT"
	cQuery += " FROM " + RetSqlName("STL") + " STL"
	cQuery += " JOIN " + RetSqlName("STJ") + " STJ"
	cQuery += "   ON STL.TL_ORDEM+STL.TL_PLANO = STJ.TJ_ORDEM+STJ.TJ_PLANO "
	cQuery += " WHERE"
	cQuery += "   SUBSTRING(STJ.TJ_DTMRFIM,5,2) = '"+cMes+"' AND"
	cQuery += "   SUBSTRING(STJ.TJ_DTMRFIM,1,4) = '"+cAno+"' AND"
	cQuery += "   STL.TL_FILIAL = '"+NGTROCAFILI("STL",cFil)+"' AND"
	cQuery += "   STJ.TJ_FILIAL = '"+NGTROCAFILI("STJ",cFil)+"' AND"
	cQuery += "   STL.D_E_L_E_T_ <> '*' AND"
	cQuery += "   STJ.D_E_L_E_T_ <> '*' AND"
	cQuery += "      STL.TL_SEQRELA > '0' AND"
	cQuery += "      STJ.TJ_SITUACA = 'L' AND"
	cQuery += "      STJ.TJ_TERMINO = 'S' AND"
	cQuery += "      STJ.TJ_TIPOOS = 'B'  AND"
	cQuery += "      STJ.TJ_ORDEPAI <> '"+Space(TAMSX3("TJ_ORDEPAI")[1])+"' AND"
	cQuery += "      STL.TL_TIPOREG = 'T'"
	If !Empty(cEqp)
		cQuery += " AND STJ.TJ_CODBEM = '"+cEqp+"'"
	EndIf
	If !Empty(cTra)
		cQuery += " AND STJ.TJ_CENTRAB = '"+cTra+"'"
	EndIf
	cQuery += " GROUP BY STJ.TJ_CCUSTO, STJ.TJ_CENTRAB, STJ.TJ_CODBEM"

	cQuery += " UNION"
	//RFERR-Reforma Ferramentas
	cQuery += " SELECT STJ.TJ_CCUSTO AS CCUSTO, STJ.TJ_CENTRAB AS CTRAB, STJ.TJ_CODBEM AS CODBEM, '' AS GRUPO,"
	cQuery += " COUNT(*) AS QTD, 'RFERR' AS TIPO,"
	cQuery += " SUM(STL.TL_CUSTO) AS TOT"
	cQuery += " FROM " + RetSqlName("STL")+" STL"
	cQuery += " JOIN " + RetSqlName("STJ")+" STJ"
	cQuery += "   ON STL.TL_ORDEM+STL.TL_PLANO = STJ.TJ_ORDEM+STJ.TJ_PLANO "
	cQuery += " WHERE"
	cQuery += "   SUBSTRING(STJ.TJ_DTMRFIM,5,2) = '"+cMes+"' AND"
	cQuery += "   SUBSTRING(STJ.TJ_DTMRFIM,1,4) = '"+cAno+"' AND"
	cQuery += "   STL.TL_FILIAL = '"+NGTROCAFILI("STL",cFil)+"' AND"
	cQuery += "   STJ.TJ_FILIAL = '"+NGTROCAFILI("STJ",cFil)+"' AND"
	cQuery += "   STL.D_E_L_E_T_ <> '*' AND"
	cQuery += "   STJ.D_E_L_E_T_ <> '*' AND"
	cQuery += "      STL.TL_SEQRELA > '0' AND"
	cQuery += "      STJ.TJ_SITUACA = 'L' AND"
	cQuery += "      STJ.TJ_TERMINO = 'S' AND"
	cQuery += "      STJ.TJ_TIPOOS = 'B'  AND"
	cQuery += "      STJ.TJ_ORDEPAI <> '"+Space(TAMSX3("TJ_ORDEPAI")[1])+"' AND"
	cQuery += "      STL.TL_TIPOREG = 'F'"
	If !Empty(cEqp)
		cQuery += " AND STJ.TJ_CODBEM = '"+cEqp+"'"
	EndIf
	If !Empty(cTra)
		cQuery += " AND STJ.TJ_CENTRAB = '"+cTra+"'"
	EndIf
	cQuery += " GROUP BY STJ.TJ_CCUSTO, STJ.TJ_CENTRAB, STJ.TJ_CODBEM"



	cQuery += " UNION"
	//LUBR-Ordens de Servico de Lubrificacao
	cQuery += " SELECT STJ.TJ_CCUSTO AS CCUSTO, STJ.TJ_CENTRAB AS CTRAB, STJ.TJ_CODBEM AS CODBEM,"+cIsNull+"(SB1.B1_GRUPO,'') AS GRUPO,"
	cQuery += " COUNT(*) AS QTD, 'LUBR' AS TIPO,"
	cQuery += " SUM(STL.TL_CUSTO) AS TOT"
	cQuery += " FROM " + RetSqlName("STL") + " STL"
	cQuery += " JOIN " + RetSqlName("STJ") + " STJ"
	cQuery += "   ON STL.TL_ORDEM+STL.TL_PLANO = STJ.TJ_ORDEM+STJ.TJ_PLANO "
	cQuery += " LEFT JOIN " + RetSqlName("SB1")+" SB1"
	cQuery += "   ON STL.TL_TIPOREG = 'P' AND SB1.B1_COD = STL.TL_CODIGO"
	cQuery += " WHERE"
	cQuery += "   SUBSTRING(STJ.TJ_DTMRFIM,5,2) = '"+cMes+"' AND"
	cQuery += "   SUBSTRING(STJ.TJ_DTMRFIM,1,4) = '"+cAno+"' AND"
	cQuery += "   STL.TL_SEQRELA > '0' AND"
	cQuery += "   STL.TL_FILIAL = '"+NGTROCAFILI("STL",cFil)+"' AND"
	cQuery += "   STJ.TJ_FILIAL = '"+NGTROCAFILI("STJ",cFil)+"' AND"
	cQuery += "   (SB1.B1_FILIAL IS NULL OR SB1.B1_FILIAL = '"+NGTROCAFILI("SB1",cFil)+"') AND"
	cQuery += "   STL.D_E_L_E_T_ <> '*' AND"
	cQuery += "   STJ.D_E_L_E_T_ <> '*' AND"
	cQuery += "   (SB1.D_E_L_E_T_ IS NULL OR SB1.D_E_L_E_T_ <> '*') AND"
	cQuery += "      STL.TL_SEQRELA > '0' AND"
	cQuery += "      STJ.TJ_SITUACA = 'L' AND"
	cQuery += "      STJ.TJ_TERMINO = 'S' AND"
	cQuery += "      STJ.TJ_LUBRIFI = 'S'"
	If !Empty(cEqp)
		cQuery += " AND STJ.TJ_CODBEM = '"+cEqp+"'"
	EndIf
	If !Empty(cTra)
		cQuery += " AND STJ.TJ_CENTRAB = '"+cTra+"'"
	EndIf
	cQuery += " GROUP BY STJ.TJ_CCUSTO, STJ.TJ_CENTRAB, STJ.TJ_CODBEM, SB1.B1_GRUPO"

	cQuery += " UNION"
	//PNEU-Ordens de Servico de Pneus
	cQuery += " SELECT STJ.TJ_CCUSTO AS CCUSTO, STJ.TJ_CENTRAB AS CTRAB, STJ.TJ_CODBEM AS CODBEM,"+cIsNull+"(SB1.B1_GRUPO,'') AS GRUPO,"
	cQuery += " COUNT(*) AS QTD, 'PNEU' AS TIPO,"
	cQuery += " SUM(STL.TL_CUSTO) AS TOT"
	cQuery += " FROM " + RetSqlName("STL")+" STL"
	cQuery += " JOIN " + RetSqlName("STJ")+" STJ"
	cQuery += "   ON STL.TL_ORDEM+STL.TL_PLANO = STJ.TJ_ORDEM+STJ.TJ_PLANO "
	cQuery += " JOIN "+RetSqlName("ST9")+" ST9"
	cQuery += "   ON STJ.TJ_CODBEM = ST9.T9_CODBEM "
	cQuery += " LEFT JOIN "+RetSqlName("SB1")+" SB1"
	cQuery += "   ON STL.TL_TIPOREG = 'P' AND SB1.B1_COD = STL.TL_CODIGO"
	cQuery += " WHERE"
	cQuery += "   SUBSTRING(STJ.TJ_DTMRFIM,5,2) = '"+cMes+"' AND"
	cQuery += "   SUBSTRING(STJ.TJ_DTMRFIM,1,4) = '"+cAno+"' AND"
	cQuery += "   STL.TL_SEQRELA > '0' AND"
	cQuery += "   STL.TL_FILIAL = '"+NGTROCAFILI("STL",cFil)+"' AND"
	cQuery += "   STJ.TJ_FILIAL = '"+NGTROCAFILI("STJ",cFil)+"' AND"
	cQuery += "   ST9.T9_FILIAL = '"+NGTROCAFILI("ST9",cFil)+"' AND"
	cQuery += "   (SB1.B1_FILIAL IS NULL OR SB1.B1_FILIAL = '"+NGTROCAFILI("SB1",cFil)+"') AND"
	cQuery += "   STL.D_E_L_E_T_ <> '*' AND"
	cQuery += "   STJ.D_E_L_E_T_ <> '*' AND"
	cQuery += "   ST9.D_E_L_E_T_ <> '*' AND"
	cQuery += "   (SB1.D_E_L_E_T_ IS NULL OR SB1.D_E_L_E_T_ <> '*') AND"
	cQuery += "      STL.TL_SEQRELA > '0' AND"
	cQuery += "      STJ.TJ_SITUACA = 'L' AND"
	cQuery += "      STJ.TJ_TERMINO = 'S' AND"
	cQuery += "      ST9.T9_CATBEM = '3'"
	If !Empty(cEqp)
		cQuery += " AND STJ.TJ_CODBEM = '"+cEqp+"'"
	EndIf
	If !Empty(cTra)
		cQuery += " AND STJ.TJ_CENTRAB = '"+cTra+"'"
	EndIf
	cQuery += " GROUP BY STJ.TJ_CCUSTO, STJ.TJ_CENTRAB, STJ.TJ_CODBEM, SB1.B1_GRUPO"



	cQuery += " UNION"
	//GPM - Grupo de Material
	cQuery += " SELECT STJ.TJ_CCUSTO AS CCUSTO, STJ.TJ_CENTRAB AS CTRAB, STJ.TJ_CODBEM AS CODBEM, "+cIsNull+"(SB1.B1_GRUPO,'') AS GRUPO,"
	cQuery += " COUNT(*) AS QTD, 'GPM' AS TIPO,"
	cQuery += " SUM(STL.TL_CUSTO) AS TOT"
	cQuery += " FROM "+RetSqlName("STL")+" STL"
	cQuery += " JOIN "+RetSqlName("STJ")+" STJ"
	cQuery += "   ON STL.TL_ORDEM+STL.TL_PLANO = STJ.TJ_ORDEM+STJ.TJ_PLANO "
	cQuery += " LEFT JOIN "+RetSqlName("SB1")+" SB1"
	cQuery += "   ON STL.TL_CODIGO = SB1.B1_COD"
	cQuery += " WHERE"
	cQuery += "   SUBSTRING(STJ.TJ_DTMRFIM,5,2) = '"+cMes+"' AND"
	cQuery += "   SUBSTRING(STJ.TJ_DTMRFIM,1,4) = '"+cAno+"' AND"
	cQuery += "   STL.TL_FILIAL = '"+NGTROCAFILI("STL",cFil)+"' AND"
	cQuery += "   STJ.TJ_FILIAL = '"+NGTROCAFILI("STJ",cFil)+"' AND"
	cQuery += "   (SB1.B1_FILIAL IS NULL OR SB1.B1_FILIAL = '"+NGTROCAFILI("SB1",cFil)+"') AND"
	cQuery += "   STL.D_E_L_E_T_ <> '*' AND"
	cQuery += "   STJ.D_E_L_E_T_ <> '*' AND"
	cQuery += "   (SB1.D_E_L_E_T_ IS NULL OR SB1.D_E_L_E_T_ <> '*') AND"
	cQuery += "      STL.TL_SEQRELA > '0' AND"
	cQuery += "      STJ.TJ_SITUACA = 'L' AND"
	cQuery += "      STJ.TJ_TERMINO = 'S' AND"
	cQuery += "      STL.TL_TIPOREG = 'P'"
	If !Empty(cEqp)
		cQuery += " AND STJ.TJ_CODBEM = '"+cEqp+"'"
	EndIf
	If !Empty(cTra)
		cQuery += " AND STJ.TJ_CENTRAB = '"+cTra+"'"
	EndIf
	cQuery += " GROUP BY STJ.TJ_CCUSTO, STJ.TJ_CENTRAB, STJ.TJ_CODBEM, SB1.B1_GRUPO"


	// Cria copia das query em que se referencia STJ (acima)
	cQuery2 := cQuery
	cQuery2 := StrTran(cQuery2,"STJ","STS")
	cQuery2 := StrTran(cQuery2,"STL","STT")
	cQuery2 := StrTran(cQuery2,"TJ_","TS_")
	cQuery2 := StrTran(cQuery2,"TL_","TT_")


	cQuery += " UNION"
	//SNST-Sinistro
	cQuery += " SELECT ST9.T9_CCUSTO AS CCUSTO, ST9.T9_CENTRAB AS CTRAB, ST9.T9_CODBEM AS CODBEM, '' AS GRUPO,"
	cQuery += " COUNT(*) AS QTD, 'SNST' AS TIPO,"
	cQuery += "   "+cIsNull+"(SUM(TRH.TRH_VALDAN),0) +"
	cQuery += "   "+cIsNull+"(SUM(TRH.TRH_VALGUI),0) +"
	cQuery += "   "+cIsNull+"(SUM(TRK.TRK_VALAVA),0) +"
	cQuery += "   -"+cIsNull+"(SUM(TRK.TRK_VALREC),0) +"
	cQuery += "   "+cIsNull+"(SUM(TRH.TRH_VALANI),0) +"
	cQuery += "   "+cIsNull+"(SUM(TRO.TRO_VALPRE),0) +"
	cQuery += "   "+cIsNull+"(SUM(TRO.TRO_VALTER),0) +"
	cQuery += "   "+cIsNull+"(SUM(TRL.TRL_VALPRE),0) +"
	cQuery += "   -"+cIsNull+"(SUM(TRV.TRV_VALRES),0) +"
	cQuery += "   "+cIsNull+"(SUM(TRM.TRM_VALVIT),0) +"
	cQuery += "   "+cIsNull+"(SUM(TBL.TOT),0) AS TOT FROM "
	cQuery += "	     (SELECT "+cIsNull+"(SUM(STL.TL_CUSTO),0) + "+cIsNull+"(SUM(STT.TT_CUSTO),0) AS TOT FROM "+RetSqlName("TRH")+" TRH"
	cQuery += "	     	JOIN "+RetSqlName("TRT")+" TRT ON TRH.TRH_NUMSIN = TRT.TRT_NUMSIN"
	cQuery += "	     	LEFT JOIN "+RetSqlName("STJ")+" STJ ON STJ.TJ_ORDEM+STJ.TJ_PLANO = TRT.TRT_NUMOS+TRT.TRT_PLANO"
	cQuery += "	     	LEFT JOIN "+RetSqlName("STL")+" STL ON STL.TL_ORDEM+STL.TL_PLANO = STJ.TJ_ORDEM+STJ.TJ_PLANO"
	cQuery += "	     	LEFT JOIN "+RetSqlName("STS")+" STS ON STS.TS_ORDEM+STS.TS_PLANO = TRT.TRT_NUMOS+TRT.TRT_PLANO"
	cQuery += "	     	LEFT JOIN "+RetSqlName("STT")+" STT ON STT.TT_ORDEM+STT.TT_PLANO = STS.TS_ORDEM+STS.TS_PLANO"
	cQuery += "	     	WHERE (STJ.TJ_SEQRELA IS NULL OR STJ.TJ_SEQRELA > '0') AND"
	cQuery += "	     	      (STS.TS_SEQRELA IS NULL OR STS.TS_SEQRELA > '0') AND"
	If !Empty(cEqp)
		cQuery += "      TRH.TRH_CODBEM = '"+cEqp+"' AND"
	EndIf
	If !Empty(cTra)
		cQuery += " (STJ.TJ_CENTRAB IS NULL OR STJ.TJ_CENTRAB = '"+cTra+"') AND"
		cQuery += " (STS.TS_CENTRAB IS NULL OR STS.TS_CENTRAB = '"+cTra+"') AND"
	EndIf
	cQuery += "         SUBSTRING(TRH.TRH_DTACID,5,2) = '"+cMes+"' AND"
	cQuery += "         SUBSTRING(TRH.TRH_DTACID,1,4) = '"+cAno+"' AND"
	cQuery += "         TRH.TRH_FILIAL = '"+NGTROCAFILI("TRH",cFil)+"' AND"
	cQuery += "         TRT.TRT_FILIAL = '"+NGTROCAFILI("TRT",cFil)+"' AND"
	cQuery += "         (STJ.TJ_FILIAL IS NULL OR STJ.TJ_FILIAL = '"+NGTROCAFILI("STJ",cFil)+"') AND"
	cQuery += "         (STL.TL_FILIAL IS NULL OR STL.TL_FILIAL = '"+NGTROCAFILI("STL",cFil)+"') AND"
	cQuery += "         (STS.TS_FILIAL IS NULL OR STS.TS_FILIAL = '"+NGTROCAFILI("STS",cFil)+"') AND"
	cQuery += "         (STT.TT_FILIAL IS NULL OR STT.TT_FILIAL = '"+NGTROCAFILI("STT",cFil)+"') AND"
	cQuery += "         TRH.D_E_L_E_T_ <> '*' AND TRT.D_E_L_E_T_ <> '*' AND"
	cQuery += "         (STJ.D_E_L_E_T_ IS NULL OR STJ.D_E_L_E_T_ <> '*') AND"
	cQuery += "         (STL.D_E_L_E_T_ IS NULL OR STL.D_E_L_E_T_ <> '*') AND"
	cQuery += "         (STS.D_E_L_E_T_ IS NULL OR STS.D_E_L_E_T_ <> '*') AND"
	cQuery += "         (STT.D_E_L_E_T_ IS NULL OR STT.D_E_L_E_T_ <> '*') AND
	cQuery += "         (STL.TL_SEQRELA IS NULL OR STL.TL_SEQRELA > '0') AND"
	cQuery += "         (STJ.TJ_SITUACA IS NULL OR STJ.TJ_SITUACA = 'L') AND"
	cQuery += "         (STJ.TJ_TERMINO IS NULL OR STJ.TJ_TERMINO = 'S') AND"
	cQuery += "         (STT.TT_SEQRELA IS NULL OR STT.TT_SEQRELA > '0') AND"
	cQuery += "         (STS.TS_SITUACA IS NULL OR STS.TS_SITUACA = 'L') AND"
	cQuery += "         (STS.TS_TERMINO IS NULL OR STS.TS_TERMINO = 'S')) TBL,"
	cQuery += RetSqlName("TRH")+" TRH"
	cQuery += " LEFT JOIN "+RetSqlName("TRK")+" TRK ON TRH.TRH_NUMSIN = TRK.TRK_NUMSIN"
	cQuery += " LEFT JOIN "+RetSqlName("TRO")+" TRO ON TRO.TRO_DANOS = '1' AND TRH.TRH_NUMSIN = TRO.TRO_NUMSIN"
	cQuery += " LEFT JOIN "+RetSqlName("TRL")+" TRL ON TRL.TRL_DANOS = '1' AND TRH.TRH_NUMSIN = TRL.TRL_NUMSIN"
	cQuery += " LEFT JOIN "+RetSqlName("TRV")+" TRV ON TRH.TRH_NUMSIN = TRV.TRV_NUMSIN"
	cQuery += " LEFT JOIN "+RetSqlName("TRM")+" TRM ON TRH.TRH_NUMSIN = TRM.TRM_NUMSIN"
	cQuery += " LEFT JOIN "+RetSqlName("ST9")+" ST9 ON ST9.T9_CODBEM = TRH.TRH_CODBEM"
	cQuery += " WHERE"
	If !Empty(cEqp)
		cQuery += " TRH.TRH_CODBEM = '"+cEqp+"' AND"
	EndIf
	If !Empty(cTra)
		cQuery += " ST9.T9_CENTRAB = '"+cTra+"' AND"
	EndIf
	cQuery += "   SUBSTRING(TRH.TRH_DTACID,5,2) = '"+cMes+"' AND"
	cQuery += "   SUBSTRING(TRH.TRH_DTACID,1,4) = '"+cAno+"' AND"
	cQuery += "   TRH.TRH_FILIAL = '"+NGTROCAFILI("TRH",cFil)+"' AND"
	cQuery += "   (TRK.TRK_FILIAL IS NULL OR TRK.TRK_FILIAL = '"+NGTROCAFILI("TRK",cFil)+"') AND"
	cQuery += "   (TRO.TRO_FILIAL IS NULL OR TRO.TRO_FILIAL = '"+NGTROCAFILI("TRO",cFil)+"') AND"
	cQuery += "   (TRL.TRL_FILIAL IS NULL OR TRL.TRL_FILIAL = '"+NGTROCAFILI("TRL",cFil)+"') AND"
	cQuery += "   (TRV.TRV_FILIAL IS NULL OR TRV.TRV_FILIAL = '"+NGTROCAFILI("TRV",cFil)+"') AND"
	cQuery += "   (TRM.TRM_FILIAL IS NULL OR TRM.TRM_FILIAL = '"+NGTROCAFILI("TRM",cFil)+"') AND"
	cQuery += "   (ST9.T9_FILIAL IS NULL OR ST9.T9_FILIAL = '"+NGTROCAFILI("ST9",cFil)+"') AND"
	cQuery += "   (TRH.D_E_L_E_T_ IS NULL OR TRH.D_E_L_E_T_ <> '*') AND"
	cQuery += "   (TRK.D_E_L_E_T_ IS NULL OR TRK.D_E_L_E_T_ <> '*') AND"
	cQuery += "   (TRO.D_E_L_E_T_ IS NULL OR TRO.D_E_L_E_T_ <> '*') AND"
	cQuery += "   (TRL.D_E_L_E_T_ IS NULL OR TRL.D_E_L_E_T_ <> '*') AND"
	cQuery += "   (TRV.D_E_L_E_T_ IS NULL OR TRV.D_E_L_E_T_ <> '*') AND"
	cQuery += "   (TRM.D_E_L_E_T_ IS NULL OR TRM.D_E_L_E_T_ <> '*') AND"
	cQuery += "   (ST9.D_E_L_E_T_ IS NULL OR ST9.D_E_L_E_T_ <> '*')"
	cQuery += "  GROUP BY ST9.T9_CCUSTO, ST9.T9_CENTRAB, ST9.T9_CODBEM"



	cQuery += " UNION"
	//ABST-Abastecimentos
	cQuery += " SELECT TQN.TQN_CCUSTO AS CCUSTO, TQN.TQN_CENTRA AS CTRAB, TQN.TQN_FROTA AS CODBEM, "+cIsNull+"(SB1.B1_GRUPO,'') AS GRUPO,"
	cQuery += " COUNT(*) AS QTD, 'ABST' AS TIPO,"
	cQuery += " SUM(TQN.TQN_VALTOT) AS TOT"
	cQuery += " FROM "+RetSqlName("TQN")+" TQN"
	cQuery += " LEFT JOIN "+RetSqlName("TQI")+" TQI"
	cQuery += "   ON TQI.TQI_CODPOS+TQI.TQI_LOJA+TQI.TQI_TANQUE+TQI.TQI_CODCOM = "
	cQuery += "      TQN.TQN_POSTO+TQN.TQN_LOJA+TQN.TQN_TANQUE+TQN.TQN_CODCOM"
	cQuery += " LEFT JOIN "+RetSqlName("SB1")+" SB1"
	cQuery += "   ON TQI.TQI_PRODUT = SB1.B1_COD"
	cQuery += " WHERE"
	If !Empty(cEqp)
		cQuery += " TQN.TQN_FROTA = '"+cEqp+"' AND"
	EndIf
	If !Empty(cTra)
		cQuery += " TQN.TQN_CENTRA = '"+cTra+"' AND"
	EndIf
	cQuery += "   SUBSTRING(TQN.TQN_DTABAS,5,2) = '"+cMes+"' AND"
	cQuery += "   SUBSTRING(TQN.TQN_DTABAS,1,4) = '"+cAno+"' AND"
	cQuery += "   TQN.TQN_FILIAL = '"+NGTROCAFILI("TQN",cFil)+"' AND"
	cQuery += "   (TQI.TQI_FILIAL IS NULL OR TQI.TQI_FILIAL = '"+NGTROCAFILI("TQI",cFil)+"') AND"
	cQuery += "   (SB1.B1_FILIAL IS NULL OR SB1.B1_FILIAL = '"+NGTROCAFILI("SB1",cFil)+"') AND"
	cQuery += "   TQN.D_E_L_E_T_ <> '*' AND "
	cQuery += "   (TQI.D_E_L_E_T_ IS NULL OR TQI.D_E_L_E_T_ <> '*') AND"
	cQuery += "   (SB1.D_E_L_E_T_ IS NULL OR SB1.D_E_L_E_T_ <> '*')"
	cQuery += " GROUP BY TQN.TQN_CCUSTO, TQN.TQN_CENTRA, TQN.TQN_FROTA, SB1.B1_GRUPO"


	cQuery += " UNION"
	//MULTA-Multa
	cQuery += " SELECT TRX.TRX_CCUSTO AS CCUSTO, '' AS CTRAB, TRX.TRX_CODBEM AS CODBEM, '' AS GRUPO,"
	cQuery += " COUNT(*) AS QTD, 'SNST' AS TIPO,"
	cQuery += " SUM(TRX.TRX_VALPAG) AS TOT"
	cQuery += " FROM "+RetSqlName("TRX")+" TRX"
	cQuery += "   JOIN "+RetSqlName("ST9")+" ST9"
	cQuery += "     ON TRX.TRX_CODBEM = ST9.T9_CODBEM"
	cQuery += " WHERE"
	If !Empty(cEqp)
		cQuery += " TRX.TRX_CODBEM = '"+cEqp+"' AND"
	EndIf
	cQuery += "   SUBSTRING(TRX.TRX_DTPGTO,5,2) = '"+cMes+"' AND"
	cQuery += "   SUBSTRING(TRX.TRX_DTPGTO,1,4) = '"+cAno+"' AND"
	cQuery += "   TRX.TRX_FILIAL = '"+NGTROCAFILI("TRH",cFil)+"' AND"
	cQuery += "   ST9.T9_FILIAL = '"+NGTROCAFILI("ST9",cFil)+"' AND"
	cQuery += "   TRX.D_E_L_E_T_ <> '*' AND"
	cQuery += "   ST9.D_E_L_E_T_ <> '*'"
	cQuery += " GROUP BY TRX.TRX_CCUSTO, TRX.TRX_CODBEM"
	//nao considera TSG - Movimento Pagamentos Efetuados

	cQuery += " ORDER BY CCUSTO, CTRAB, CODBEM, GRUPO, TIPO"

	cQuery  := ChangeQuery(cQuery)
	cQuery2 := ChangeQuery(cQuery2)

	//---------------------------------------------------------

	//adiciona registros ref. STJ + sinistro/abast./multa
	SqlToTrb(cQuery,aDBF,cAliasQry)

	//adiciona registros ref. STS
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery2),(cAliasQr2), .F., .T.)
	dbSelectArea(cAliasQr2)
	dbGoTop()
	While (cAliasQr2)->(!Eof())

		dbSelectArea(cAliasQry)
		dbSetOrder(01)
		If !dbSeek((cAliasQr2)->CCUSTO+(cAliasQr2)->CTRAB+(cAliasQr2)->CODBEM+(cAliasQr2)->GRUPO)
			RecLock(cAliasQry,.T.)
			(cAliasQry)->CCUSTO := (cAliasQr2)->CCUSTO
			(cAliasQry)->CTRAB  := (cAliasQr2)->CTRAB
			(cAliasQry)->CODBEM := (cAliasQr2)->CODBEM
			(cAliasQry)->GRUPO  := (cAliasQr2)->GRUPO
			(cAliasQry)->QTD    := (cAliasQr2)->QTD
			(cAliasQry)->TIPO   := (cAliasQr2)->TIPO
			(cAliasQry)->TOT    := (cAliasQr2)->TOT
		Else
			RecLock(cAliasQry,.F.)
			(cAliasQry)->TOT    += (cAliasQr2)->TOT
		EndIf
		MsUnLock(cAliasQry)

		dbSelectArea(cAliasQr2)
		dbSkip()
	EndDo

	//---------------------------------------------------------

	If SuperGetMV("MV_PIMSINT",.F.,.F.) .And. FindFunction("PIMSGeraXML")
		If !lSched
			Processa({ |lEnd| fGeraArq(cFil,cEmp,cMes,cAno)},"Aguarde... gerando arquivos")
		Else
			fGeraArq(cFil,cEmp,cMes,cAno)
		EndIf
	EndIf

	//---------------------------------------------------------

	(cAliasQry)->(dbCloseArea())
	oTmpQry:Delete()

	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} fGeraArq
Gera arquivos (mensagens) para integração dos registros de
custos para integracao com PIMS.

@author  Felipe Nathan Welter
@since   10/09/10
@version p12

@param cFil, Caractere, Filial a ser processada
@param cEmp, Caractere, Empresa a ser processada
@param cMes, Caractere, Mes para processamento
@param cMes, Caractere, Ano para processamento

@return nil
/*/
//-------------------------------------------------------------------
Static Function fGeraArq(cFil,cEmp,cMes,cAno)

	Local nX
	Local nTamTot  := 0
	Local nInd     := 0
	Local aCampos  := {}
	Local aCamposR := {}
	Local aNgHeader:= {}

	Private aLoadVar := {} //utilizada em PIMSGeraXML

	//adiciona no array os campos que nao serao usados no XML
	aNgHeader := NGHeader("ST9")
	nTamTot := Len(aNgHeader)
	For nInd := 1 To nTamTot
		If !(AllTrim(aNgHeader[nInd,2]) $ "T9_CCUSTO/T9_CENTRAB/T9_CODBEM")
			aAdd(aCamposR,AllTrim(aNgHeader[nInd,2]))
		EndIf
	Next nInd

	If !lSched
		ProcRegua((cAliasQry)->(RecCount()))
	EndIf

	(cAliasQry)->(dbGoTop())
	While (cAliasQry)->(!Eof())

		If (cAliasQry)->TOT == 0
			(cAliasQry)->(dbSkip())
			Loop
		EndIf

		If !lSched
			IncProc( "Gerando..."+cValToChar( Round(((cAliasQry)->(RecNo())*100)/(cAliasQry)->(RecCount()),2) ) + " %"  )
		EndIf

		aCampos := {}
		aLoadVar:= {}

		ST9->(dbSetOrder(01))
		//ST9->(dbSeek(xFilial("ST9")+(cAliasQry)->CODBEM))

		aFields := {{"Mes"       ,"Mes"       ,"MES"  ,"C" ,2 ,0  ,cMes},;
		{"Ano"       ,"Ano"       ,"ANO"  ,"C" ,4 ,0  ,cAno},;
		{"Quantidade","Quantidade","QUANT","N" ,3 ,0  ,1},;
		{"Tipo"      ,"Tipo"      ,"TIPO" ,"C" ,5 ,0  ,(cAliasQry)->TIPO},;
		{"Valor"     ,"Valor"     ,"VALOR","N" ,12,2  ,(cAliasQry)->TOT},;
		{"Operacao"  ,"Operacao"  ,"OPER" ,"N" ,01,0  ,3}}  //Operacao 3=Inclusao/5=Exclusao

		oStruct := FWFormStruct(1,"ST9")
		nPos := aSCan(oStruct:aFields,{|x| x[3] = "T9_MODELO"})

		If nPos > 0
			For nX := 1 To Len(aFields)
				aField := aClone(oStruct:aFields[nPos])
				aField[01] := aFields[nX,1]
				aField[02] := aFields[nX,2]
				aField[03] := aFields[nX,3]
				aField[04] := aFields[nX,4]
				aField[05] := aFields[nX,5]
				aField[06] := aFields[nX,6]
				aAdd(aCampos,aField)
				aAdd(aLoadVar,{aFields[nX,3],aFields[nX,7]})
			Next nX
		EndIf

		SB1->(dbSetOrder(01))
		SB1->(dbGoTop())

		oStruct := FWFormStruct(1,"SB1")
		nPos := aSCan(oStruct:aFields,{|x| x[3] = "B1_GRUPO"})
		If nPos > 0
			aAdd(aCampos,oStruct:aFields[nPos])
			aAdd(aLoadVar,{"B1_GRUPO",(cAliasQry)->GRUPO})
		EndIf

		//Envia duas mensagens consecutivas, a primeira como Exclusao, a segunda de Inclusao (necessidade PIMS)
		For nX := 1 To 2

			nPos := asCan(aLoadVar,{|x| x[1] == "OPER"})
			If nPos > 0
				aLoadVar[nPos,2] := If(nX==1,5,3)
			EndIf

			PIMSGeraXML("AssetCost","Custo dos Bens","2","ST9",aCampos,,aCamposR)
			//If(!lSched,U_BFTGrvXML("ST9C"),Nil)
		Next nX

		(cAliasQry)->(dbSkip())
	EndDo

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fProdGroup³ Autor ³ Felipe Nathan Welter  ³ Data ³ 09/09/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Encontra produtos e grupos de produto utilizados como:      ³±±
±±³          ³- combustivel (abastecimentos)                              ³±±
±±³          ³- insumos (ordens de servico)                               ³±±
±±³          ³para apresentar relatorio de inconsist. de falta de grupo   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³1.cFil - Filial a ser processada           *nao-obrigatorio ³±±
±±³          ³2.cEmp - Empresa a ser processada          *nao-obrigatorio ³±±
±±³          ³3.cMes - Mes para processamento            *nao-obrigatorio ³±±
±±³          ³4.cAno - Ano para processamento            *nao-obrigatorio ³±±
±±³          ³5.cEqp - Equipamento                       *nao-obrigatorio ³±±
±±³          ³6.cTra - Centro de Trabalho                *nao-obrigatorio ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³NGPimsCst                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fProdGroup(cFil,cEmp,cMes,cAno,cEqp,cTra)

	Local cQuery
	Local cAliasQry := GetNextAlias()
	Local oTmpQry
	Local cTxtLog := ""
	Local cIsNull := If(TcGetDb() = "ORACLE","NVL",If(TcGetDb() $ "DB2","COALESCE","ISNULL"))
	Local lFst1 := lFst2 := .T.
	Local cGrupo := ""
	Local nQtdSem := 0

	//Produtos utilizados como combustivel (abastecimentos)
	cQuery := " SELECT "
	cQuery += "   DISTINCT SB1.B1_COD, SB1.B1_DESC,"
	cQuery += "   SB1.B1_GRUPO, "+cIsNull+"(SBM.BM_DESC,'') AS BM_DESC"
	cQuery += " FROM "+RetSqlName("TQN")+" TQN"
	cQuery += "  JOIN "+RetSqlName("TQI")+" TQI"
	cQuery += "    ON TQI.TQI_CODPOS+TQI.TQI_LOJA+TQI.TQI_TANQUE+TQI.TQI_CODCOM"
	cQuery += "     = TQN.TQN_POSTO+TQN.TQN_LOJA+TQN.TQN_TANQUE+TQN.TQN_CODCOM"
	cQuery += "  JOIN "+RetSqlName("SB1")+" SB1"
	cQuery += "    ON TQI.TQI_PRODUT = SB1.B1_COD"
	cQuery += "  LEFT JOIN "+RetSqlName("SBM")+" SBM"
	cQuery += "    ON SBM.BM_GRUPO = SB1.B1_GRUPO"
	cQuery += " WHERE"
	If !Empty(cEqp)
		cQuery += " TQN.TQN_FROTA = '"+cEqp+"' AND"
	EndIf
	If !Empty(cTra)
		cQuery += " TQN.TQN_CENTRA = '"+cTra+"' AND"
	EndIf
	cQuery += "  SUBSTRING(TQN.TQN_DTABAS,5,2) = '"+cMes+"'"
	cQuery += "  AND SUBSTRING(TQN.TQN_DTABAS,1,4) = '"+cAno+"'"
	cQuery += "  AND TQN.TQN_FILIAL = '"+NGTROCAFILI("TQN",cFil)+"'"
	cQuery += "  AND TQI.TQI_FILIAL = '"+NGTROCAFILI("TQI",cFil)+"'"
	cQuery += "  AND SB1.B1_FILIAL = '"+NGTROCAFILI("SB1",cFil)+"'"
	cQuery += "  AND (SBM.BM_FILIAL IS NULL OR SBM.BM_FILIAL = '"+NGTROCAFILI("SBM",cFil)+"')"
	cQuery += "  AND TQN.D_E_L_E_T_ <> '*'"
	cQuery += "  AND TQI.D_E_L_E_T_ <> '*'"
	cQuery += "  AND SB1.D_E_L_E_T_ <> '*'"
	cQuery += "  AND (SBM.D_E_L_E_T_ IS NULL OR SBM.D_E_L_E_T_ <> '*')"

	cQuery += " UNION"
	//Produtos utilizados como insumos (ordens de servico)
	cQuery += " SELECT "
	cQuery += "  DISTINCT SB1.B1_COD, SB1.B1_DESC,"
	cQuery += "  "+cIsNull+"(SB1.B1_GRUPO,'') AS B1_GRUPO, "+cIsNull+"(SBM.BM_DESC,'') AS BM_DESC"
	cQuery += " FROM "+RetSqlName("STL")+" STL"
	cQuery += "  JOIN "+RetSqlName("STJ")+" STJ"
	cQuery += "    ON STL.TL_ORDEM+STL.TL_PLANO = STJ.TJ_ORDEM+STJ.TJ_PLANO"
	cQuery += "  LEFT JOIN "+RetSqlName("SB1")+" SB1"
	cQuery += "    ON STL.TL_CODIGO = SB1.B1_COD"
	cQuery += "  LEFT JOIN "+RetSqlName("SBM")+" SBM"
	cQuery += "    ON SBM.BM_GRUPO = SB1.B1_GRUPO"
	cQuery += " WHERE"
	If !Empty(cEqp)
		cQuery += " STJ.TJ_CODBEM = '"+cEqp+"' AND"
	EndIf
	If !Empty(cTra)
		cQuery += " STJ.TJ_CENTRAB = '"+cTra+"' AND"
	EndIf
	cQuery += "  SUBSTRING(STJ.TJ_DTMRFIM,5,2) = '"+cMes+"'"
	cQuery += "  AND SUBSTRING(STJ.TJ_DTMRFIM,1,4) = '"+cAno+"'"
	cQuery += "  AND STL.TL_FILIAL = '"+NGTROCAFILI("STL",cFil)+"'"
	cQuery += "  AND STJ.TJ_FILIAL = '"+NGTROCAFILI("STJ",cFil)+"'"
	cQuery += "  AND (SB1.B1_FILIAL IS NULL OR SB1.B1_FILIAL = '"+NGTROCAFILI("SB1",cFil)+"')"
	cQuery += "  AND (SBM.BM_FILIAL IS NULL OR SBM.BM_FILIAL = '"+NGTROCAFILI("SBM",cFil)+"')"
	cQuery += "  AND STL.D_E_L_E_T_ <> '*'"
	cQuery += "  AND STJ.D_E_L_E_T_ <> '*'"
	cQuery += "  AND (SB1.D_E_L_E_T_ IS NULL OR SB1.D_E_L_E_T_ <> '*')"
	cQuery += "  AND (SBM.D_E_L_E_T_ IS NULL OR SBM.D_E_L_E_T_ <> '*')"
	cQuery += "  AND STL.TL_SEQRELA > '0'"
	cQuery += "  AND STJ.TJ_SITUACA = 'L'"
	cQuery += "  AND STJ.TJ_TERMINO = 'S'"
	cQuery += "  AND STL.TL_TIPOREG = 'P'"

	cQuery += " ORDER BY B1_GRUPO"

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),(cAliasQry), .F., .T.)

	dbGoTop()

	cTxtLog += "Custos dos Equipamentos - MNT x PIMS "
	cTxtLog += If(!lSched,"[via Client]","[via Schedule]")+CRLF
	cTxtLog += "(Grupos de Estoque de Produtos)"+CRLF

	If !Eof()
		While !Eof()
			If Empty((cAliasQry)->B1_GRUPO)
				If lFst1
					cTxtLog += CRLF+" ## Produtos sem grupo"+CRLF
					lFst1 := !lFst1
				EndIf
				cTxtLog += " - " + AllTrim((cAliasQry)->B1_COD) + " - "+AllTrim((cAliasQry)->B1_DESC)
				nQtdSem++
			Else
				If lFst2
					cTxtLog += CRLF+" ## Produtos com grupo"+CRLF
					lFst2 := !lFst2
				EndIf
				If cGrupo != (cAliasQry)->B1_GRUPO
					cGrupo := (cAliasQry)->B1_GRUPO
					cTxtLog += "Grupo: "+AllTrim((cAliasQry)->B1_GRUPO) + " - " + AllTrim((cAliasQry)->BM_DESC)+CRLF
				EndIF
				cTxtLog += " - " + AllTrim((cAliasQry)->B1_COD) + " - "+AllTrim((cAliasQry)->B1_DESC)
			EndIf
			cTxtLog += CRLF
			(cAliasQry)->(dbSkip())
		EndDo
	Else
		cTxtLog += CRLF+"Não foram selecionados produtos para exportação."+CRLF
	EndIf

	cTxtLog += CRLF+CRLF
	cTxtLog += "Obs: Geração de Arquivo de Exportação de Custos - os produtos listados"+CRLF
	cTxtLog += "estão cadastrados no SIGAMNT como Insumos de Ordens de Serviço e/ou"+CRLF
	cTxtLog += "Combustível de Abastecimentos realizados no periodo de seleção para"+CRLF
	cTxtLog += "este arquivo."+CRLF
	cTxtLog += "- Empresa/Filial: "+cEmp+"/"+cFil+CRLF
	cTxtLog += "- Periodo: "+cMes+"/"+cAno+CRLF
	cTxtLog += "- Exec.: "+DTOC(GetRmtDate())+" "+SubStr(GetRmtTime(),1,5)+CRLF
	If !Empty(cEqp)
		cTxtLog += "- Equipamento: "+cEqp+CRLF
	EndIf
	If !Empty(cTra)
		cTxtLog += "- Centro de Trabalho: "+cTra+CRLF
	EndIf

	fShowLog(cTxtLog)

Return (nQtdSem == 0)





//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//  Funcoes de impressao de log/erros
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡…o    ³fRContErr ºAutor  ³Felipe Nathan Welterº Data ³  14/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao do log de erros na importacao de quilometragem    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³NGPimsRCnt                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fRContErr(aProb)

	Local nX
	Local cTxt := ''

	If Len(aProb) > 0
		For nX := 1 To Len(aProb)
			cTxt += ' - '+aProb[nX] + CHR(13)+CHR(10)
		Next nX
	EndIf

	If !Empty(cTxt)
		fShowLog(cTxt)
	EndIf

Return !Empty(cTxt)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fShowLog  ³ Autor ³ Felipe Nathan Welter  ³ Data ³ 09/09/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Apresentacao do log de processo/erro em tela                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³1.cTxtLog - texto de log para apresentacao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³NGPimsCst                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fShowLog(cTxtLog)

	Local cPrograma := Substr(ProcName(1),1,Len(ProcName(1)))
	Local cMask := "Arquivos Texto (*.TXT) |*.txt|"
	Local oFont, oDlg
	Local aLog := Array(1)

	Local cArq   := cPrograma + "_" + SM0->M0_CODIGO + SM0->M0_CODFIL + "_" + Dtos(Date()) + "_" + StrTran(Time(),":","") + ".LOG"
	Local __cFileLog := MemoWrite(cArq,cTxtLog)

	lSched := If(Type("lSched")<>"L",.F.,lSched)

	If !lSched .And. !Empty(cArq)
		cTxtLog := MemoRead(AllTrim(cArq))
		aLog[1] := {cTxtLog}
		DEFINE FONT oFont NAME "Courier New" SIZE 5,0
		DEFINE MSDIALOG oDlg TITLE "Log de Processo" From 3,0 to 340,417 COLOR CLR_BLACK,CLR_WHITE PIXEL
		@ 5,5 GET oMemo  VAR cTxtLog MEMO SIZE 200,145 OF oDlg PIXEL
		oMemo:bRClicked := {||AllwaysTrue()}
		oMemo:oFont := oFont
		oMemo:lReadOnly := .T.

		DEFINE SBUTTON FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL
		DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,OemToAnsi("Salvar Como...")),If(cFile="",.t.,MemoWrite(cFile,cTxtLog)),oDlg:End()) ENABLE OF oDlg PIXEL
		DEFINE SBUTTON  FROM 153,115 TYPE 6 ACTION fLogPrint(aLog,cPrograma) ENABLE OF oDlg PIXEL
		ACTIVATE MSDIALOG oDlg CENTERED
	EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fLogPrint ³ Autor ³ Felipe Nathan Welter  ³ Data ³ 09/09/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Apresentacao do log de processo/erro em tela                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³1.aLog - array contendo o conteudo para impressao           ³±±
±±³          ³2.cProg - programa que chama a impressao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³NGPimsCst                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fLogPrint(aLog,cProg)
	Local aTitle   := {""}

	If IsInCallStack("NGPimsRCnt")
		aTitle := {"Quilometragem dos Equip. - MNT x PIMS"}
	ElseIf IsInCallStack("NGPimsCst")
		aTitle := {"Custos dos Equipamentos - MNT x PIMS"}
	EndIf

	CursorWait()
	fMakeLog( aLog,aTitle,,.T.,cProg,aTitle[1],"P","P",,.F.)
	CursorArrow()
Return Nil