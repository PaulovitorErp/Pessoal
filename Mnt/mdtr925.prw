#INCLUDE "MDTR925.ch"
#Include "Protheus.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR925
Impressao de cedulas para votacao CIPA

@type function

@source MDTR925.prw

@author Denis Hyroshi de Souza
@since 09/10/2006

@param cCodMandato	, Caracter, Código do mandato
@param cCliente		, Caracter, Código do Cliente
@param cLoja		, Caracter, Código da Loja

@sample MDTR925('01','01','01')

@return Vazio
/*/
//---------------------------------------------------------------------
Function MDTR925(cCodMandato, cCliente, cLoja)

	Local aNGBEGINPRM := NGBEGINPRM() // Armazena variaveis p/ devolucao (NGRIGHTCLICK)

	Local aArea := GetArea()

	Private lCipatr    := SuperGetMv( "MV_NG2NR31", .F., "2" ) == "1"
	Private lSigaMdtPS := SuperGetMv( "MV_MDTPS", .F., "N" ) == "S"
	Private lMdtMin    := SuperGetMv( "MV_MDTMIN", .F., "N" ) == "S"

	Private nomeprog   := "MDTR925"
	Private titulo     := IIf( lMdtMin, STR0019, IIf( lCipatr, STR0016, STR0001 )) //"Cedulas para Votacao CIPA"
	Private cPerg      := IIf(!lSigaMdtPS,"MDT925    ","MDT925PS  ")

	If ExistBlock("MDTA111R") // Verifica se a rotina de eventos foi chamada

		aParam := {}
		aAdd(aParam, {"7-2"})// Tipo do Evento

		If ValType(cCodMandato) == "C"
			aAdd(aParam, {cCodMandato})
		Else
			aAdd(aParam, {""})
		EndIf

		If lSigaMdtPS

			If ValType(cCliente) == "C" .AND. ValType(cLoja) == "C"
				aAdd(aParam, {cCliente})
				aAdd(aParam, {cLoja})
			Else
				aAdd(aParam, {""})
				aAdd(aParam, {""})
			EndIf

		EndIf

		lRet := ExecBlock("MDTA111R",.F.,.F.,aParam)

		If Type("lRet") <> "L"
			lRet := .F.
		EndIf

		If lRet
			Return .T.
		EndIf

	EndIf

	/*---------------------------------------
	//PADRÃO								|
	|  Mandato CIPA ?						|
	|  Qtas cedulas deseja imprimir ?		|
	|  Tipo de Impressao ?					|
	|  Imprimir a matricula ?				|
	|  										|
	//PRESTADOR								|
	|  Cliente ?							|
	|  Loja									|
	|  Mandato CIPA ?						|
	|  Qtas cedulas deseja imprimir ?		|
	|  Tipo de Impressao ?					|
	|  Imprimir a matricula ?				|
	--------------------------------------*/

	If Pergunte(cPerg,.T.)
		Processa({|lEND| MDTA925IMP()},STR0002) // "Imprimindo..."
	Endif

	RestArea(aArea)
	NGRETURNPRM(aNGBEGINPRM) // Devolve variaveis armazenadas (NGRIGHTCLICK)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA925IMP
Função de impressao

@type function

@source MDTR925.prw

@author Denis Hyroshi de Souza
@since 09/10/2006

@sample MDTR925('01','01','01')

@return Nil, Sempre nulo
/*/
//---------------------------------------------------------------------
Static Function MDTA925IMP()

	Local nInd, nInd2
	Local nColEmp
	Local cNomeAux := ""
	Local aNomeEmp := {}
	Local nX := 0
	Local	nZ		:= 0

	Private oPrint  := FwMsPrinter():New( OemToAnsi(IIf( lMdtMin, STR0019, IIf( lCipatr, STR0016, STR0001 )))) //"Cedulas para Votacao CIPA"
	Private oFont08 := TFont():New("VERDANA",08,08,,.F.,,,,.F.,.F.)
	Private oFont09	:= TFont():New("VERDANA",09,09,,.F.,,,,.F.,.F.)
	Private oFont10	:= TFont():New("VERDANA",10,10,,.F.,,,,.F.,.F.)
	Private oFont12	:= TFont():New("VERDANA",12,12,,.F.,,,,.F.,.F.)
	Private aCandid := {}

	If lSigaMdtps

		dbSelectArea("TNN")
		dbSetOrder(3)  //TNN_FILIAL+TNN_CLIENT+TNN_LOJAC+TNN_MANDAT
		dbSeek(xFilial("TNN")+mv_par01+mv_par02+mv_par03)

		dbSelectArea("TNO")
		dbSetOrder(4)  //TNO_FILIAL+TNO_CLIENT+TNO_LOJA+TNO_MANDAT+TNO_MAT+DTOS(TNO_DTCAND)
		dbSeek(xFilial("TNO")+mv_par01+mv_par02+mv_par03)
		While !eof() .and. xFilial("TNO")+mv_par01+mv_par02+mv_par03 == TNO->TNO_FILIAL+TNO->TNO_CLIENT+TNO->TNO_LOJA+TNO->TNO_MANDAT

			cFil1Tmp := cFilAnt
			If !Empty(TNO->TNO_FILMAT)
				cFil1Tmp := TNO->TNO_FILMAT
			Endif

			dbSelectArea("SRA")
			dbSetOrder(1)
			If dbSeek(xFilial("SRA",cFil1Tmp)+TNO->TNO_MAT)
				aADD(aCandid,{Alltrim(SRA->RA_NOME),TNO->TNO_MAT})
			Endif

			dbSelectArea("TNO")
			dbSkip()
		End

		aSort(aCandid,,,{ |x, y| x < y }) //Ordena candidatos por nome
		nNumCand := Len(aCandid)
		lin := 4000

		oPrint:SetPortrait() //retrato
		nCol := 050

		For nInd := 1 To Mv_par04

			If lin+300+(70*nNumCand) > 3100

				If nInd == 1
					oPrint:StartPage()
					lin := 150
				Else
					oPrint:EndPage()
					oPrint:StartPage()
					lin := 150
				Endif

			Endif

			If mv_par06 == 1
				oPrint:Box(lin,nCol-100,lin+300+(100*nNumCand),nCol+730) // Tamanho da caixinha inferior
			Else
				oPrint:Box(lin,nCol-100,lin+300+(70*nNumCand),nCol+730)
			EndIf

			oPrint:SayBitMap(lin+15,nCol+20,NGLocLogo(),250,50) //Localização do Logo da Empresa

			oPrint:Say(lin+20,nCol+275,STR0003,oFont10) //"CÉDULA DE VOTAÇÃO"

			If Year(TNN->TNN_DTINIC) == Year(TNN->TNN_DTTERM)
				oPrint:Say(lin+85,nCol+275,IIf( lMdtMin, STR0020, IIf( lCipatr, STR0017, STR0004 ))+StrZero(Year(TNN->TNN_DTINIC),4),oFont10) // "CIPATR - GESTÃO " // "CIPA - GESTÃO "
			Else
				oPrint:Say(lin+85,nCol+275,IIf( lMdtMin, STR0020, IIf( lCipatr, STR0017, STR0004 ))+StrZero(Year(TNN->TNN_DTINIC),4)+; //"CIPATR - GESTÃO " //"CIPA - GESTÃO "
					"/"+Substr(StrZero(Year(TNN->TNN_DTTERM),4),3,2),oFont10)
			Endif

			dbSelectArea("SA1")
			dbSeek(xFilial("SA1")+mv_par01+mv_par02)

			cNomeEmp := Alltrim(Substr(SA1->A1_NOME,1,40))
			oPrint:Say(lin+150,nCol+365,cNomeEmp,oFont10,,,,2)

			If mv_par06 == 1
				For nInd2 := 1 To Len(aCandid)
					oPrint:Box(lin+170+(nInd2*100),nCol+50,lin+220+(nInd2*100),nCol+100)
					oPrint:Say(lin+150+(nInd2*100),nCol+150,STR0015 + ":",oFont08)//"Matrícula"
					oPrint:Say(lin+150+(nInd2*100),nCol+300,aCandid[nInd2][2],oFont08)
					If Len(aCandid[nInd2][1]) <= 25
						oPrint:Say(lin+190+(nInd2*100),nCol+150,aCandid[nInd2][1],oFont08)
					Else
						oPrint:Say(lin+190+(nInd2*100),nCol+150,Substr(aCandid[nInd2][1],1,25),oFont08)
					Endif
				Next nInd2

				oPrint:Line(lin+240+(100*nNumCand),nCol,lin+240+(100*nNumCand),nCol+730)
				oPrint:Say(lin+250+(100*nNumCand),nCol+030,STR0005,oFont08) //"Marque 'X' no candidato de sua preferência."

				nCol += 730

				If nCol > 1700
					nCol := 050
				Endif

				If nCol == 050
					lin := lin+300+(100*nNumCand)
				Endif

			Else

				For nInd2 := 1 To Len(aCandid)
					oPrint:Box(lin+170+(nInd2*70),nCol+50,lin+220+(nInd2*70),nCol+100)
					If Len(aCandid[nInd2][1]) < 26
						oPrint:Say(lin+180+(nInd2*70),nCol+150,aCandid[nInd2][1],oFont09)
					Else
						oPrint:Say(lin+180+(nInd2*70),nCol+150,Substr(aCandid[nInd2][1],1,25),oFont09)
					Endif
				Next nInd2

				oPrint:Line(lin+240+(70*nNumCand),nCol,lin+240+(70*nNumCand),nCol+730)
				oPrint:Say(lin+250+(70*nNumCand),nCol+030,STR0005,oFont08) //"Marque 'X' no candidato de sua preferência."

				nCol += 730

				If nCol > 1700
					nCol := 050
				Endif

				If nCol == 050
					lin := lin+300+(70*nNumCand)
				Endif

			EndIf

		Next

		If Mv_par04 > 0
			oPrint:EndPage()
		Endif

		If mv_par05 == 1
			oPrint:Preview()
		Else
			oPrint:Print()
		EndIf

	Else

		dbSelectArea("TNN")
		dbSetOrder(1)
		dbSeek(xFilial("TNN")+mv_par01)

		dbSelectArea("TNO")
		dbSetOrder(1)
		dbSeek(xFilial("TNO")+mv_par01)

		// Procura pelos candidatos que serao impressos na cedula
		While !Eof() .And. xFilial("TNO") + mv_par01 == TNO->TNO_FILIAL + TNO->TNO_MANDAT

			If TNO->TNO_INDICA != '1' // 1 - Empresa / 2 - Empregados
				cFil1Tmp := cFilAnt

				If !Empty(TNO->TNO_FILMAT)
					cFil1Tmp := TNO->TNO_FILMAT
				EndIf

				dbSelectArea("SRA")
				dbSetOrder(1)

				If dbSeek(xFilial("SRA", cFil1Tmp) + TNO->TNO_MAT)
					aAdd(aCandid, {Alltrim(SRA->RA_NOME), TNO->TNO_MAT})
				EndIf
			EndIf

			dbSelectArea("TNO")
			dbSkip()
		End

		aSort(aCandid,,, { |x, y| x[1] < y[1] }) // Ordena candidatos por Nome
		nNumCand := Len(aCandid)
		lin := 4000

		oPrint:SetPortrait()

		nCol := 50
		nColEmp := nCol+600
		nAliEmp := 0
		For nInd := 1 To Mv_par02 // Quantidade de Cedulas a serem impressas

			If lin+300+(70*nNumCand) > 3100

				If nInd == 1
					oPrint:StartPage()
					lin := 150
				Else
					oPrint:EndPage()
					oPrint:StartPage()
					lin := 150
				EndIf

			EndIf

			If mv_par04 == 1 // Imprimir a matricula ?
				oPrint:Box(lin, nCol, lin+300+(100*nNumCand), nCol+730)
			Else
				oPrint:Box(lin, nCol, lin+300+(70*nNumCand), nCol+730)
			EndIf

			// Localização do Logo da Empresa
			oPrint:SayBitMap(lin+15,nCol+20,NGLocLogo(),250,50)

			oPrint:SayAlign(lin+50,nCol+225,STR0003,oFont10, 500, 50, , 2, 0 ) //"CÉDULA DE VOTAÇÃO"

			If Year(TNN->TNN_DTINIC) == Year(TNN->TNN_DTTERM)
				oPrint:SayAlign(lin+80,nCol+225,IIf( lMdtMin, STR0020, IIf( lCipatr, STR0017, STR0004 ))+StrZero(Year(TNN->TNN_DTINIC),4),oFont10, 500, 50, , 2, 0 ) //"CIPATR - GESTÃO " //"CIPA - GESTÃO "
			Else
				oPrint:SayAlign(lin+80,nCol+250,IIf( lMdtMin, STR0020, IIf( lCipatr, STR0017, STR0004 ))+StrZero(Year(TNN->TNN_DTINIC),4)+; //"CIPATR - GESTÃO " //"CIPA - GESTÃO "
				"/"+Substr(StrZero(Year(TNN->TNN_DTTERM),4),3,2),oFont10, 500, 50, , 2, 0 )
			EndIf

			cNomeEmp := Alltrim(Substr(SM0->M0_NOMECOM, 1, 40))
			oPrint:SayAlign(lin+140, nCol-nAliEmp, cNomeEmp, oFont08, nColEmp, lin, CLR_BLACK, 2, 1)

			If mv_par04 == 1 //Imprimir a matricula ?

				For nInd2 := 1 To Len(aCandid)
					oPrint:Box(lin+150+(nInd2*100), nCol+50,lin+200+(nInd2*100),nCol+100)
					oPrint:Say(lin+150+(nInd2*100), nCol+150, STR0015 + ":", oFont08) //"Matrícula"
					oPrint:Say(lin+150+(nInd2*100), nCol+300, aCandid[nInd2][2], oFont08)

					If Len(aCandid[nInd2][1]) <= 25
						oPrint:Say(lin+190+(nInd2*100), nCol+150, aCandid[nInd2][1], oFont08)
					Else
						oPrint:Say(lin+190+(nInd2*100), nCol+150, Substr(aCandid[nInd2][1], 1, 25), oFont08)
					EndIf

				Next nInd2

				oPrint:Line(lin+240+(100*nNumCand), nCol, lin+240+(100*nNumCand), nCol+730)
				oPrint:SayAlign(lin+250+(100*nNumCand),nCol+030,STR0005,oFont08, 700, 50, , 2, 0 ) //"Marque 'X' no candidato de sua preferência."
				nCol += 730
				nAliEmp += 350
				nColEmp := nCol + 600

				If nCol > 1700
					nCol := 050
					nColEmp := nCol + 600
					nAliEmp := 0
				EndIf

				If nCol == 50
					lin := lin+300+(100*nNumCand)
				EndIf

			Else

				For nInd2 := 1 To Len(aCandid)
					oPrint:Box(lin+150+(nInd2*70),nCol+50,lin+200+(nInd2*70),nCol+100)

					If Len(aCandid[nInd2][1]) <= 25
						oPrint:Say(lin+200+(nInd2*70), nCol+150, aCandid[nInd2][1], oFont08)
					Else
						oPrint:Say(lin+200+(nInd2*70), nCol+150, Substr(aCandid[nInd2][1], 1, 25), oFont08)
					EndIf

				Next nInd2

				oPrint:Line(lin+240+(70*nNumCand), nCol, lin+240+(70*nNumCand), nCol+730)
				oPrint:SayAlign(lin+250+(70*nNumCand),nCol+030,STR0005,oFont08, 700, 50, , 2, 0 ) //"Marque 'X' no candidato de sua preferência."
				nCol += 730
				nAliEmp += 350
				nColEmp := nCol + 600
				If nCol > 1700
					nCol := 50
					nColEmp := nCol+600
					nAliEmp := 0
				EndIf

				If nCol == 50
					lin := lin+300+(70*nNumCand)
				EndIf

			EndIf

		Next

		If mv_par02 > 0 //Quant. Cedulas deseja imp. ?
			oPrint:EndPage()
		EndIf

		If mv_par03 == 1 //Tipo de Impressao ?
			oPrint:Preview()
		Else
			oPrint:Print()
		EndIf

	EndIf

Return NIL