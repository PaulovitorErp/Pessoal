#Include 'MNTR422.ch'
#Include 'Protheus.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR422
Relatório de ordem de serviço por Etapas
@author William Rozin Gaspar
@author Maria Elisandra de Paula
@since 09/05/2014
/*/
//---------------------------------------------------------------------
Function MNTR422(cParam)

	Local aNGBEGINPRM := NGBEGINPRM()
	Local lMNTR676	  := FunName() == 'MNTR676'
	Local cPerg       := IIf( lMNTR676 , "MNTR422B", "MNTR422" )
	Local lTemPerg    := !Empty( Posicione( 'SX1', 1, cPerg, 'X1_GRUPO' ) )
	Local lReturn	  := .T.
	Local lUmaFolha   := .T. //Imprime uma Tarefa por folha

	Private aReturn   := {STR0020 , 1,STR0021, 1, 2, 1, "",1 } // "Zebrado" #"Administracao"
	Private cTitulo   := STR0001 // "Relatório de Ordem de Serviço por Etapas"
	Private ntipo     := 0
	Private nLastKey  := 0
	Private cNumOSX   := ""

	Default cParam := ""

	cNumOSX := cParam

	If !lTemPerg //Caso não exista a pergunta

		MV_PAR01 := 1 // Etapa
		MV_PAR02 := 2 // Sem Insumos
		MV_PAR03 := 2 // Imprimir uma folha em Etapas (MNTR422)
		MV_PAR11 := 1 // Imprimir uma folha em Etapas (MNTR422B)

	Else
		// PL Rimatur - MIT044 - Relatório O.S. Interna (MNTR422) para atender a impressão de tarefas
		If !Pergunte( cPerg )
			lReturn := .F.
		EndIf
		
	EndIf

	If lReturn

		If MV_PAR01 == 2 // Tarefa
			cTitulo   := STR0028
		Else
			If lMNTR676
				lUmaFolha := MV_PAR11 == 1
			Else
				lUmaFolha := MV_PAR03 == 1
			EndIf
		EndIf

		If !AliasInDic("TVT")
			MsgInfo(STR0002) //"Tabela TVT não consta no dicionário, favor contatar o administrador do sistema."
		Else
			Processa({|lEnd| MNT421IMP(lMNTR676, lTemPerg, lUmaFolha)})
		EndIf
	EndIf

	NGRETURNPRM(aNGBEGINPRM)

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT421IMP

@author William Rozin Gaspar

@since 09/05/2014
@param lMNTR676, Lógico,  Origem do fonte é MNTR676
@param lTemPerg, Lógico,  Pergunte está no banco de dados
@param lUmaFolha, Lógico, Imprimir uma Etapa por folha

/*/
//---------------------------------------------------------------------
Static Function MNT421IMP(lMNTR676, lTemPerg, lUmaFolha)

	Local lImp 	:= .F.
	Local cCode := ""
	Local i := 0
	Local nAuxCode 	:= 0
	Local cEmpresa 	:= Alltrim(SM0->M0_NOME)
	Local cFilAtu	:= ""
	Local cFilDesc 	:= ""
	Local nOb := 0
	Local lGrupo	:= .F.
	Local nContLinha:= 0
	Local nLinBarra	:= 0
	Local lMemo 	:= .f.
	Local cEtapaMemo:= ""
	Local nT 		:= 1
	Local cContDif 	:= ""
	Local cEtapa	:= ""
	Local lImpChassi := .f. // indica se chassi já foi impresso
	Local nLinha
	Local nLinTar
	Local cAliasSTQ
	Local cAliasSTL
	Local nLinhaVer
	Local cOldOrdem := ''
	Local cOldTarefa:= ''
	Local cRelacSB1 := "%" + NGMODCOMP("STL","SB1") + "%"
	Local cRelacST1 := "%" + NGMODCOMP("STL","ST1") + "%"
	Local cRelacSH4 := "%" + NGMODCOMP("STL","SH4") + "%"
	Local cRelacST0 := "%" + NGMODCOMP("STL","ST0") + "%"
	Local cRelacSA2 := "%" + NGMODCOMP("STL","SA2") + "%"
	Local cAliasQry := GetNextAlias()
	Local nQtdeLin  := 1
	Local nEta		:= 1
	Local cObsMemo  := ''	
	Local nLinObs	:= 1

    //Variaveis do relatorio
	Private oPrint
	Private Lin := 9999

    //Definicao de Fontes
	Private cFonte   := "Courier new"
	Private oFont10  := TFont():New(cFonte,12,10,,.F.,,,,.F.,.F.)
	Private oFont12  := TFont():New(cFonte,12,12,,.F.,,,,.F.,.F.)
	Private oFont14  := TFont():New(cFonte,12,14,,.F.,,,,.F.,.F.)
	Private oFont14b := TFont():New(cFonte,12,14,,.T.,,,,.F.,.F.)
	Private oFont18  := TFont():New(cFonte,12,18,,.T.,,,,.F.,.F.)

	If !ProcTable( cAliasQry, lMNTR676, lTemPerg )

		If MV_PAR01 == 1 // Etapa
			MsgStop(STR0004,STR0003) // "Não existem etapas para esta OS." # "Atenção"
		Else
			MsgStop(STR0037,STR0003) // "Não existem tarefas para esta OS." # "Atenção"
		EndIf

		Return .F.
	EndIf

    //Inicializa Objeto
	oPrint := FWMSPrinter():New(OemToAnsi(cTitulo))

	// Caso a geracao do relatorio tenha sido cancelado, encerra a funcao
	If oPrint:Canceled() .Or. oPrint:lCanceled .Or. oPrint:oFileWriter == Nil
		Return .F.
	EndIf

	/*
	Valores para imprimir o relatório corretamente mesmo que usuário selecione outra configuração
	Orientação Retrato, folha A4 , tamanhos referente a orientação retrato pois SetPortrait apresentou problemas
	*/
	oPrint:SetPortrait() //Retrato
	oPrint:SetMargin(50,50,50,50)// nEsquerda, nSuperior, nDireita, nInferior
	oPrint:setPaperSize(9)//A4
	oPrint:nFactorHor	:= 3.87096774
	oPrint:nFactorVert	:= 3.61643836
	oPrint:nPageHeight	:= 3168
	oPrint:nPageWidth	:= 2400

	Somalinha(3)
	dbSelectArea(cAliasQry)
	dbGoTop()
	While ( cAliasQry )->( !EoF() )

		i++
		
		If !lUmaFolha //imprimir mais de 1 etapa por folha
			nContLinha++
		EndIf

		lImp := .T.
		lMemo := .F.
		lImpChassi := .F.

		If MV_PAR01 == 2 // Tarefa
			cCode := (cAliasQry)->TJ_ORDEM + (cAliasQry)->TJ_PLANO + (cAliasQry)->TAREFA + Space(Len(STQ->TQ_ETAPA))
		Else
			cCode := (cAliasQry)->TJ_ORDEM + (cAliasQry)->TJ_PLANO + (cAliasQry)->TAREFA + (cAliasQry)->ETAPA
		EndIf

		//para calcular a coluna para impressão da descrição da barra (24 é o tamanho máximo com coluna 1840)
		nTamCode :=  24 - Len(RTRIM(cCode))
		nColCcode := 1705 + (nTamCode * 15)

		if nContLinha == 4
			nContLinha := 1
		EndIf

		If MV_PAR01 == 1 .And. !lUmaFolha // Etapa
			If nContLinha == 1
				nLinBarra := 6.5
			ElseIf nContLinha == 2
				nLinBarra := 27.3
			Else
				nLinBarra := 48.0
			Endif
		Else
			nLinBarra := 6.5
		Endif

		nColBarra := 20

		If (cAliasQry)->T9_CATBEM == '2'
			dbSelectArea("DA3")
			dbSetOrder(1)
			If dbSeek(xFilial("DA3")+ (cAliasQry)->T9_CODTMS)
				cFilAtu := DA3->DA3_FILBAS
			EndIf
		Else
			If NGSX2MODO("ST9") == "E"
				cFilAtu := (cAliasQry)->T9_FILIAL
			EndIf
		EndIf

		If !Empty(cFilAtu)

			cFilDesc := AllTrim(FWFilialName(,cFilAtu,1))

		EndIf

		If i == 1
			cContDif := ContDif((cAliasQry)->TJ_ORDEM)
		EndIf

		cEtapa := STR0025 + Alltrim(NGSEEK("TPA", (cAliasQry)->ETAPA, 1, "TPA_DESCRI"))

		Somalinha(3)
		oPrint:Say(Lin , 10  , cEmpresa , oFont14b)
		If MV_PAR01 == 1 // Etapa
			oPrint:Say(Lin , 1050 , STR0005 , oFont14b) //"ETAPA DA ORDEM DE SERVIÇO"
		Else
			oPrint:Say(Lin , 1050 , STR0027 , oFont14b) //"TAREFA DA ORDEM DE SERVIÇO"
		EndIf

		SomaLinha(3)
		SomaLinha(3)

		oPrint:Say(Lin , 10  , STR0006 , oFont10) //"BEM..............:"
		oPrint:Say(Lin , 300  , (cAliasQry)->TJ_CODBEM , oFont18)

		If MV_PAR01 == 1 // Etapa
			oPrint:FWMSBAR("CODE128" /*cTypeBar*/,nLinBarra /*nRow*/ ,nColBarra/*nCol*/, cCode/*cCode*/,oPrint/*oPrint*/,.T./*lCheck*/,/*Color*/,.T./*lHorz*/,0.02/*nWidth*/,0.8/*nHeigth*/,.f./*lBanner*/,cFonte/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,0.001/*nPFWidth*/,0.001/*nPFHeigth*/,.t./*lCmtr2Pix*/)
		EndIf

		SomaLinha(3)

		SomaLinha(3)
		oPrint:Say(Lin , 10  , STR0007 , oFont10) //"O.S.............:"
		oPrint:Say(Lin , 300  , (cAliasQry)->TJ_ORDEM  , oFont18)

		SomaLinha(3)
		oPrint:Say(Lin , 10 ,  STR0008     , oFont10) //"Centro de Custo..:"
		oPrint:Say(Lin , 300 , Alltrim((cAliasQry)->TJ_CCUSTO)  + " - " + Substring(Alltrim(NGSEEK("CTT",(cAliasQry)->TJ_CCUSTO , 1, "CTT_DESC01")),1,20) , oFont10)
       	oPrint:Say(Lin , nColCcode  , cCode , oFont10)

		If !Empty(cFilDesc)
			oPrint:Say(Lin,905,STR0009 + Substr(cFilDesc,1,35),oFont10) //"Filial:"
		ElseIf !Empty((cAliasQry)->T9_CHASSI)
			oPrint:Say(Lin,905,STR0010 + (cAliasQry)->T9_CHASSI , oFont10) //"Chassi:"
			lImpChassi:= .t.
		EndIf

		SomaLinha(3)

		oPrint:Say(Lin,10, STR0022,oFont10)//"Família"
		oPrint:Say(Lin,300,Alltrim((cAliasQry)->T9_CODFAMI) + " - " + Alltrim(NGSEEK("ST6", (cAliasQry)->T9_CODFAMI, 1, "T6_NOME")) , oFont10)

		If !Empty((cAliasQry)->T9_CHASSI) .and. !lImpChassi
			oPrint:Say(Lin,905,STR0010 + (cAliasQry)->T9_CHASSI, oFont10) //"Chassi: "
		EndIf

		SomaLinha(3)
		oPrint:Say(Lin , 10  , 		STR0011 , oFont10) //"Modelo...........:"
		oPrint:Say(Lin , 300  , Alltrim((cAliasQry)->T9_TIPMOD) + " - " + 	Alltrim(NGSEEK("TQR", (cAliasQry)->T9_TIPMOD, 1, "TQR_DESMOD")) , oFont10)

		SomaLinha(3)

		If !Empty((cAliasQry)->T9_FABRICA)
			oPrint:Say(Lin , 10  , 		STR0012       , oFont10) //"Fabricante.......:"
			oPrint:Say(Lin , 300  , Alltrim((cAliasQry)->T9_FABRICA) + " - " +	Alltrim(NGSEEK("ST7", (cAliasQry)->T9_FABRICA, 1, "T7_NOME")) , oFont10)
       	EndIf
		SomaLinha(3)

		cObserva := Alltrim( NGSEEK( "STJ", (cAliasQry)->TJ_ORDEM + (cAliasQry)->TJ_PLANO, 1, "TJ_OBSERVA"))

		nLinObs := MlCount(cObserva,100,,.T.)

		If MV_PAR01 == 2 // Tarefa

			oPrint:Say(Lin , 10   , STR0026 , oFont10) //"Observações da O.S."

			oPrint:FWMSBAR("CODE128" /*cTypeBar*/, Round( Lin / 87, 1) /*nLinBarra nRow*/ ,nColBarra/*nCol*/, cCode/*cCode*/,oPrint/*oPrint*/,.T./*lCheck*/,/*Color*/,.T./*lHorz*/,0.02/*nWidth*/,0.8/*nHeigth*/,.f./*lBanner*/,cFonte/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,0.001/*nPFWidth*/,0.001/*nPFHeigth*/,.t./*lCmtr2Pix*/)

			SomaLinha(3)

			For nLinha := 1 to nLinObs

				cObsMemo := Padr(MemoLine(cObserva,110,nLinha,,.t.),110)
				oPrint:Say( Lin-5 , 400  , cObsMemo , oFont10)

				oPrint:Line( Lin, 400, Lin, 2000)
				SomaLinha(3)
			
			Next

			For nLinha := 1 to 5

				oPrint:Line( Lin, 400, Lin, 2000)
				SomaLinha(3)

			Next

		EndIf

		oPrint:Line( Lin, 10, Lin, 2210)

		SomaLinha(3)
		oPrint:Say(Lin , 10   , STR0013 , oFont10) //"Contador Acumuldado"
		oPrint:Say(Lin , 300  , STR0014 , oFont10) //"Contador"
		oPrint:Say(Lin , 540  , STR0015 , oFont10) //"Tipo Serviço"
		oPrint:Say(Lin , 1060 , STR0016 , oFont10) //"Entrada"
		oPrint:Say(Lin , 1415 , STR0017 , oFont10) //"Previsão de Saída"

		SomaLinha(3)

		oPrint:Say(Lin , 10   , cValtoChar((cAliasQry)->T9_CONTACU) , oFont10) // "Contador Acumulado"

		oPrint:Say(Lin , 300  , cContDif , oFont10)//Contador
		oPrint:Say(Lin , 540  , SubStr(Alltrim(NGSEEK("ST4", (cAliasQry)->TJ_SERVICO, 1, "T4_NOME")),1,20) , oFont10)// Tipo Serviço

		dbSelectArea("TTI")
		dbSetOrder(1)
		If dbSeek(xFilial("TTI") + cEmpAnt + cFilAnt + cEmpAnt + (cAliasQry)->T9_FILIAL +  (cAliasQry)->TJ_CODBEM + "1")
			oPrint:Say(Lin , 1060  , DtoC(TTI->TTI_DTENT) + " " + TTI->TTI_HRENT , oFont10)//Entrada

		EndIf
		oPrint:Say(Lin , 1415 , DtoC(StoD((cAliasQry)->TJ_DTMPFIM)) + " " + (cAliasQry)->TJ_HOMPFIM, oFont10) //Previsão Saída

		SomaLinha(3)
		oPrint:Line( Lin, 10, Lin, 2210)
		nLinhaVer := Lin

		SomaLinha(3)

		// verifica a quantidade de linhas campo observação  - máximo 5
		nRecSTQ := (cAliasQry)->RECNO
		aArea := GetArea()
		dbSelectArea("STQ")
		dbGoTo(nRecSTQ)
		cMemoObs := MemoLine(STQ->TQ_OBSERVA)
		nOb := MlCount(STQ->TQ_OBSERVA,72,,.T.)

		If !EmptY(cMemoObs)
			If nOb > 5
				nOb := 5
			EndIf
		Else
			nOb := 0
		EndIf

		// verifica a quantidade de linhas campo etapa  - máximo 3
		nEta := MlCount(cEtapa,65,,.T.)
		If nEta > 3
			nEta := 3
		EndIf

		oPrint:Say(Lin , 1410 , STR0018, oFont14)  //"O B S E R V A Ç Õ E S"

		If MV_PAR01 == 1 // Etapa

			/*
			Primeira linha de retângulo -> Código do grupo.Código subgrupo.tarefa (ou somente tarefa.ETAPA)
			*/
			lGrupo := .F.
			dbSelectArea("TVS")
			dbSetOrder(4)
			If dbSeek(xFilial("TVS") + (cAliasQry)->TAREFA + (cAliasQry)->ETAPA)
				lGrupo := .T.
				oPrint:Say(Lin , 10   , Alltrim(TVS->TVS_TAREFA) + "." + Alltrim(TVS->TVS_GRUPO) + "." + Alltrim(TVS->TVS_ETAPA), oFont10)
			Else
				oPrint:Say(Lin , 10   , Alltrim((cAliasQry)->TAREFA) + "." + Alltrim((cAliasQry)->ETAPA), oFont10)
			EndIf

			For nT := 1 to 5
				SomaLinha(3)

				If nT == 1   //linha 2 imprime descrição da tarefa
					If lGrupo
						oPrint:Say(Lin , 10  ,STR0023 + Alltrim(NGSEEK("TT9", TVS->TVS_TAREFA, 1, "TT9_DESCRI")) , oFont12)
					Else
						oPrint:Say(Lin , 10  ,STR0023 + Alltrim(NGSEEK("TT9", (cAliasQry)->TAREFA , 1, "TT9_DESCRI")), oFont12)
					EndIf
				Else
					If nT == 2 // linha 3 imprime descrição do grupo
						If lGrupo
							oPrint:Say(Lin , 10  ,STR0024 + Alltrim(NGSEEK("TVR", TVS->TVS_GRUPO, 2, "TVR_NOME"))  , oFont12)
						EndIf
					Else

						If nT <= (nEta + 2)

							cEtapaMemo := Padr(MemoLine(cEtapa,65,nT-2,,.t.),65)
							oPrint:Say(Lin,10,cEtapaMemo , oFont10)
						EndIf
					EndIf
				EndIf

				If nOb != 0
					cLast := Padr(MemoLine(STQ->TQ_OBSERVA,72,nT,,.t.),72)
					If nOb == nT
						cLast := RTrim(cLast)
					Endif

					oPrint:Say(Lin , 1070, cLast, oFont10)
				EndIf
			Next

		ElseIf MV_PAR01 == 2 // Tarefa

			If nT == 1   //linha 2 imprime descrição da tarefa
				oPrint:Say(Lin , 10  ,STR0023 + Alltrim(NGSEEK("TT9", (cAliasQry)->TAREFA , 1, "TT9_DESCRI")), oFont12)
			EndIf

			cAliasSTQ := GetNextAlias()

			BeginSql Alias cAliasSTQ
				SELECT TQ_ETAPA, TPA_DESCRI, TQ_OBSERVA
					FROM %table:STQ% STQ
				LEFT JOIN %table:TPA% TPA
					ON STQ.TQ_FILIAL = TPA.TPA_FILIAL
					AND STQ.TQ_ETAPA = TPA.TPA_ETAPA
					AND TPA.%NotDel%
				WHERE	TQ_FILIAL 	= %xFilial:STQ%
					AND	TQ_ORDEM 	= %exp:(cAliasQry)->TJ_ORDEM%
					AND TQ_TAREFA	= %exp:(cAliasQry)->TAREFA%
					AND STQ.%NotDel%
			EndSql

			SomaLinha(3)

			While ( cAliasSTQ )->( !Eof() )

				oPrint:Say(Lin , 10  ,STR0025, oFont12) //"Etapa : "

				cEtapa := Alltrim( ( cAliasSTQ )->TPA_DESCRI )
				nEtapa := MlCount(cEtapa,55,,.T.)

				If nEtapa > 3 // máximo três linhas
					nEtapa := 3
				EndIf

				nLinTar := Lin

				For nLinha := 1 to nEtapa

					cEtapaMemo := Padr(MemoLine(cEtapa,55,nLinha,,.t.),55)
					oPrint:Say( nLinTar , 140  , cEtapaMemo , oFont12)

					nLinTar += 36 // Valor de uma Lin

				Next

				nLinTar := Lin

				For nLinha := 1 to nOb

					cLast := Padr(MemoLine( ( cAliasSTQ )->TQ_OBSERVA, 62, nLinha,, .T. ), 62 )
					oPrint:Say( nLinTar , 1075  , cLast , oFont12)

					nLinTar += 36 // Valor de uma Lin

				Next

				IIf(nEtapa > nOb, nSomaLin := nEtapa, nSomaLin := nOb)

				SomaLinha( 3 * ( nSomaLin + 1 ) )

				( cAliasSTQ )->( dbSkip() )
			End

			(cAliasSTQ)->(dbCloseArea())

		EndIf

		oPrint:Line( nLinhaVer, 1060, Lin, 1060) // linha vertical para divisão do retângulo

		If MV_PAR02 == 1 // Sim para Insumos

			cAliasSTL := GetNextAlias()

			//Query para pegar os dados do Insumo
			BeginSql Alias cAliasSTL
				SELECT TL_TAREFA,
						TL_TIPOREG,
						TL_CODIGO,
						B1_DESC cDescProd,
						T1_NOME cDescFunc,
						H4_DESCRI cDescFer,
						T0_NOME cDescEspec,
						A2_NOME cDescTerc,
						TL_DTFIM,
						TL_HOFIM,
						TL_QUANTID,
						TL_UNIDADE
					FROM %table:STL% STL
				LEFT JOIN %table:SB1% SB1
					ON %exp:cRelacSB1%
					AND STL.TL_CODIGO = SB1.B1_COD
					AND SB1.%NotDel%
				LEFT JOIN %table:ST1% ST1
					ON %exp:cRelacST1%
					AND STL.TL_CODIGO = ST1.T1_CODFUNC
					AND ST1.%NotDel%
				LEFT JOIN %table:SH4% SH4
					ON %exp:cRelacSH4%
					AND STL.TL_CODIGO = SH4.H4_CODIGO
					AND SH4.%NotDel%
				LEFT JOIN %table:ST0% ST0
					ON %exp:cRelacST0%
					AND STL.TL_CODIGO = ST0.T0_ESPECIA
					AND ST0.%NotDel%
				LEFT JOIN %table:SA2% SA2
					ON %exp:cRelacSA2%
					AND STL.TL_CODIGO = SA2.A2_COD
					AND SA2.%NotDel%
				WHERE	TL_FILIAL 	= %xFilial:STL%
					AND	TL_ORDEM 	= %exp:(cAliasQry)->TJ_ORDEM%
					AND	TL_TAREFA	= %exp:(cAliasQry)->TAREFA%
					AND TL_SEQRELA	= '0'
					AND STL.%NotDel%
				ORDER BY TL_TAREFA, TL_CODIGO
			EndSql

			nLinhaPrt := Lin + 50
			oPrint:Say(nLinhaPrt , 0010 , Replicate("-",65) , oFont10)
			oPrint:Say(nLinhaPrt , 0980 , STR0029 , oFont12) //"Insumos"
			oPrint:Say(nLinhaPrt , 1100 , Replicate("-",75) , oFont10)
			nLinhaPrt += 24
			oPrint:Say(nLinhaPrt , 0010 , STR0030 , oFont10) //"Tipo"
			oPrint:Say(nLinhaPrt , 0120 , STR0031 , oFont10) //"Código"
			oPrint:Say(nLinhaPrt , 0670 , STR0032 , oFont10) //"Descrição"
			oPrint:Say(nLinhaPrt , 1320 , STR0033 , oFont10) //"Data Prev."
			oPrint:Say(nLinhaPrt , 1550 , STR0034 , oFont10) //"Hora"
			oPrint:Say(nLinhaPrt , 1700 , STR0035 , oFont10) //"Quant."
			oPrint:Say(nLinhaPrt , 1800 , STR0036 , oFont10) //"Unid."

			While ( cAliasSTL )->( !EoF() )
				nLinhaPrt += 24 * nQtdeLin
				oPrint:Say(nLinhaPrt, 0010  ,(cAliasSTL)->TL_TIPOREG, oFont12)
				oPrint:Say(nLinhaPrt, 0120  ,(cAliasSTL)->TL_CODIGO, oFont12)
				nQtdeLin := fDescInsumo( cAliasSTL, nLinhaPrt )
				oPrint:Say(nLinhaPrt, 1320  ,DtoC(StoD((cAliasSTL)->TL_DTFIM)), oFont12)
				oPrint:Say(nLinhaPrt, 1550  ,(cAliasSTL)->TL_HOFIM, oFont12)
				oPrint:Say(nLinhaPrt, 1700  ,cValToChar( (cAliasSTL)->TL_QUANTID ), oFont12)
				oPrint:Say(nLinhaPrt, 1800  ,(cAliasSTL)->TL_UNIDADE, oFont12)
				
				( cAliasSTL )->( dbSkip() )
			End
			
			( cAliasSTL )->(dbCloseArea())
		Else
			oPrint:Say(Lin+50 , 10 , Replicate("-",142) , oFont10)
		EndIf

		RestArea(aArea)

		Lin += 200
		nAuxCode++

		If MV_PAR01 == 1 // Etapa
			dbSelectArea(cAliasQry)
			( cAliasQry )->( dbSkip() )
		Else
			cOldOrdem  := ( cAliasQry )->TJ_ORDEM
			cOldTarefa := ( cAliasQry )->TAREFA
			( cAliasQry )->( dbSkip() )
			If ( cAliasQry )->TJ_ORDEM == cOldOrdem
				While ( cAliasQry )->TJ_ORDEM == cOldOrdem .And. cOldTarefa == ( cAliasQry )->TAREFA
					cOldOrdem  := ( cAliasQry )->TJ_ORDEM
					cOldTarefa := ( cAliasQry )->TAREFA
					( cAliasQry )->( dbSkip() )
				End
			EndIf
		EndIf

		If MV_PAR01 == 2 .And. ( cAliasQry )->( !EoF() )
			Somalinha(0 ,.T.)
		Else
			If Mod(nContLinha,3) == 0 .And. !Eof()
				Somalinha(0 ,.T.)
				nAuxCode := 0
			EndIf
		EndIf

	EndDo
	
	( cAliasQry )->(dbCloseArea())

	If lImp
		oPrint:EndPage()
		oPrint:Preview()
	Else
		oPrint:EndPage()
		MsgStop(STR0019 ,STR0003) // "Não existem dados para montar o relatório."# "Atenção"
	Endif
	MS_FLUSH()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} Somalinha

@author William Rozin Gaspar
@since 09/05/2014
/*/
//---------------------------------------------------------------------
Static Function Somalinha( nQtdLin , lEndPage , nLimite )

	Local nLin := 12

	Default nQtdLin := 1
	Default lEndPage := .F.
	Default nLimite := 2950

	nLin := nLin * nQtdLin
	Lin += nLin
	If lin > nLimite .Or. lEndPage
		oPrint:EndPage()
		oPrint:StartPage()
		lin := 200
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} ProcTable

@author William Rozin Gaspar

@param cAliasQry, Caracter, Alias da query
@param lMNTR676, Lógico, Origem do fonte é MNTR676
@param lTemPerg, Lógico, Pergunte está no banco de dados

@return lRet, Lógico, .T. se encontrou dados para impressão

@since 09/05/2014
/*/
//---------------------------------------------------------------------
Static Function ProcTable( cAliasQry, lMNTR676, lTemPerg )

	Local cWhere 	:= ''
	Local cJoin  	:= '%'
	Local cWhereSTL	:= ''
	Local lRet 		:= .F.
	Local caliasSTL

	If lMNTR676 .And. lTemPerg

		cWhereSTL := "%AND STL.TL_ORDEM   BETWEEN " + ValToSql(MV_PAR05) + " AND " + ValToSql(MV_PAR06)

		cWhere := "%AND STJ.TJ_PLANO   BETWEEN " + ValToSql(MV_PAR03) + " AND " + ValToSql(MV_PAR04)
		cWhere += "AND STJ.TJ_ORDEM   BETWEEN " + ValToSql(MV_PAR05) + " AND " + ValToSql(MV_PAR06)
		cWhere += "AND STJ.TJ_DTORIGI BETWEEN " + ValToSql(MV_PAR07) + " AND " + ValToSql(MV_PAR08)

		cJoin	+= "AND STQ.TQ_TAREFA BETWEEN " + ValToSql(MV_PAR09) + " AND " + ValToSql(MV_PAR10)
	Else
		cWhereSTL := '%AND STL.TL_ORDEM = ' + ValToSql(cNumOSX)

		cWhere := '%AND STJ.TJ_ORDEM = ' + ValToSql(cNumOSX)

	Endif

	cWhereSTL += "%"
	cWhere 	  += " AND STJ.D_E_L_E_T_ = ' '%"

	cJoin	+= " AND STQ.D_E_L_E_T_ = ' '%"

	//Verifica se ao menos existe STL(Insumos) quando é pedido Insumos no relatório 
	If MV_PAR02 == 1

		caliasSTL := GetNextAlias()

		BeginSql Alias cAliasSTL
			SELECT Count(TL_ORDEM) Tarefas
			FROM %table:STL% STL
			WHERE	TL_FILIAL 	= %xFilial:STL%
				AND STL.%NotDel%
				%exp:cWhereSTL%
		EndSql

		If ( cAliasSTL )->Tarefas == 0
			MV_PAR02 := 2 // Não (sem insumos)
		EndIf

		( cAliasSTL )->(dbCloseArea())

	EndIf

	BeginSql Alias cAliasQry
		SELECT DISTINCT TJ_ORDEM,
						TJ_CODBEM,
						TJ_PLANO,
						TJ_CCUSTO,
						TJ_SERVICO,
						TJ_DTMPFIM,
						TJ_HOMPFIM,
						T9_CODFAMI,
						T9_CODTMS,
						T9_CATBEM,
						T9_CHASSI,
						T9_FILIAL,
						T9_FABRICA,
						T9_TIPMOD,
						T9_CONTACU,
						TQ_TAREFA as TAREFA,
						TQ_ETAPA as ETAPA,
						STQ.R_E_C_N_O_ AS RECNO
		FROM %table:STJ% STJ
		JOIN %table:ST9% ST9 ON
						ST9.T9_FILIAL = %xFilial:ST9%
					AND ST9.T9_CODBEM = STJ.TJ_CODBEM
					AND ST9.D_E_L_E_T_ = ' '
		JOIN %table:STQ% STQ ON
						STQ.TQ_FILIAL = %xFilial:STQ%
					AND STQ.TQ_ORDEM  = STJ.TJ_ORDEM
					%exp:cJoin%
		WHERE 	STJ.TJ_FILIAL = %xFilial:STJ% AND
				STJ.TJ_TERMINO <> 'S' AND
				STJ.TJ_SITUACA =  'L'
				%exp:cWhere%
		ORDER BY TJ_ORDEM, TJ_PLANO, TQ_TAREFA, TQ_ETAPA
	EndSql

	If ( cAliasQry )->( !EoF() )
		lRet := .T.
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fDescInsumo
Função que trata impressão de insumos, usado quando a descrição do
insumo for muito grande. Ex: X3_TAMANHO do campo B1_DESC igual a 60

@author Cristiano Serafim Kair
@since 03/03/2022
@param cAlias, Caracter, Alias da tabela de insumos
@param nLinha, Numérico, Linha atual que irá imprimir

@return nDesc, Numérico, Número de linhas que imprimiu
/*/
//---------------------------------------------------------------------
Static Function fDescInsumo( cAlias, nLinha )

	Local cDesc		:= ''
	Local nDesc		:= 0
	Local nTamanho	:= 35
	Local nLinhaDes := 0
	Local cDescMemo := ''
	Local cTipoReg	:= (cAlias)->TL_TIPOREG

	If cTipoReg == 'M'
		cDesc := Alltrim( (cAlias)->cDescFunc )
	ElseIf cTipoReg == 'P'
		cDesc := Alltrim( (cAlias)->cDescProd )
	ElseIf cTipoReg == 'F'
		cDesc := Alltrim( (cAlias)->cDescFer )
	ElseIf cTipoReg == 'E'
		cDesc := Alltrim( (cAlias)->cDescEspec )
	ElseIf cTipoReg == 'T'
		cDesc := Alltrim( (cAlias)->cDescTerc )
	EndIf

	nDesc := MlCount(cDesc,nTamanho,,.T.)

	For nLinhaDes := 1 to nDesc

		cDescMemo := Padr(MemoLine(cDesc,nTamanho,nLinhaDes,,.t.),nTamanho)
		oPrint:Say( nLinha, 0670, cDescMemo, oFont12)

		nLinha += 24 // Valor de uma Lin

	Next

Return nDesc

//---------------------------------------------------------------------
/*/{Protheus.doc} ContDif
Função que retorna a diferença do contador atual com o da última manutenção
ou última OS, dependendo do tipo da manutenção

@author William Rozin Gaspar
@since 09/12/2014
/*/
//---------------------------------------------------------------------
Static Function ContDif(cOrdem)
	Local aArea := GetArea()
	Local cRet := ""
	Local cTpServ := ""
	Local nPoscont := 0
	Local nDif := 0

	Local cAliasQry := GetNextAlias()
	Local cQuery := ''


	/*
	Diferença do km atual com a da última manutenção (caso preventivo)
	ou diferença de km atual com a última O.S com o serviço (caso corretiva)
	*/

	dbSelectArea("ST9")
	dbSetOrder(1)
	If dbSeek( xFilial("ST9") + STJ->TJ_CODBEM)
		nPoscont := ST9->T9_CONTACU
	EndIf

	dbSelectArea("STE")
	dbSetOrder(1)
	If dbSeek(xFilial("STE") + STJ->TJ_TIPO)
		cTpServ  := STE->TE_CARACTE
	EndIf

	If cTpServ == "C" // CORRETIVA

		cQuery := "SELECT TJ_POSCONT FROM " + RetSqlName("STJ")
		cQuery += " WHERE TJ_FILIAL = " + ValToSql(xFilial("ST9"))
		cQuery += " AND TJ_CODBEM = " + ValToSql(STJ->TJ_CODBEM)
		cQuery += " AND TJ_SERVICO = " + ValToSql(STJ->TJ_SERVICO)
		cQuery += " AND TJ_DTORIGI || TJ_HORACO1 <"  + ValToSql(DtoS(STJ->TJ_DTORIGI) + STJ->TJ_HORACO1)
		cQuery += " AND TJ_SITUACA <> 'C' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		cQuery += " ORDER BY TJ_DTORIGI || TJ_HORACO1 DESC "

		cQuery :=  ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

		If !Eof()
			nDif :=  nPoscont - (cAliasQry)->TJ_POSCONT
		Else
			nDif := 0
		EndIf

		cRet := cValtoChar(nDif)

		(cAliasQry)->(dbCloseArea())

	ElseIf cTpServ == "P"//PREVENTIVA

		//Buscar o ultimo contado realizado na manutenção
		dbSelectArea("STF")
		dbSetOrder(1) //TF_FILIAL+TF_CODBEM+TF_SERVICO+TF_SEQRELA
		If dbSeek( xFilial("STF") + STJ->TJ_CODBEM + STJ->TJ_SERVICO + STJ->TJ_SEQRELA)
			If STF->TF_TIPACOM <> "T"
				nDif := ( nPoscont - STF->TF_CONMANU )
			EndIf
		Else
			nDif := nPoscont
		EndIf

		cRet := cValtoChar(nDif)
	EndIf
	RestArea(aArea)

Return cRet
