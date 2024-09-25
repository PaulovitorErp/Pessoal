#INCLUDE "MDTR923.ch"
#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTR923

Impressao das fichas de inscricao CIPA

@author  Denis Hyroshi de Souza
@since   16/10/2006

@sample  MDTR923(cCodMandato,cCliente,cLoja)

@param   cCodMandato, Caractere, Parâmetro usado no modo de prestador
@param   cCliente, Caractere, Parâmetro usado no modo de prestador
@param   cLoja, Caractere, Parâmetro usado no modo de prestador
/*/
//-------------------------------------------------------------------
Function MDTR923(cCodMandato,cCliente,cLoja)
	// Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	Local aNGBEGINPRM := NGBEGINPRM()


	// Define Variaveis
	Local aArea := GetArea()

	Private lCipatr    := SuperGetMv( "MV_NG2NR31", .F., "2" ) == "1"
	Private lSigaMdtPS := SuperGetMv( "MV_MDTPS", .F., "N" ) == "S"
	Private lMdtMin    := SuperGetMv( "MV_MDTMIN", .F., "N" ) == "S"

	Private nomeprog := "MDTR923"
	Private titulo   := STR0001 //"Ficha Inscrição"
	Private cPerg    := If(!lSigaMdtPS,"MDT923    ","MDT923PS  ")

	If ExistBlock("MDTA111R")
		//Verifica se a rotina de eventos foi chamada
		aParam := {}
		aAdd(aParam, {"5"})//Tipo do Evento

		If ValType(cCodMandato) == "C"
			aAdd(aParam, {cCodMandato})
		Else
			aAdd(aParam, {""})
		Endif

		If lSigaMdtPS

			If ValType(cCliente) == "C" .AND. ValType(cLoja) == "C"
				aAdd(aParam, {cCliente})
				aAdd(aParam, {cLoja})
			Else
				aAdd(aParam, {""})
				aAdd(aParam, {""})
			Endif

		Endif

		lRet := ExecBlock("MDTA111R",.F.,.F.,aParam)

		If Type("lRet") <> "L"
			lRet := .F.
		Endif

		If lRet
			Return .T.
		Endif

	Endif

	/*----------------------------------
	//PADRÃO							|
	|  Mandato CIPA ?					|
	|  Qtdade de Fichas Inscricao ?		|
	|  Fichas por Pagina ?				|
	|  Tipo de Impressao ?				|
	|  									|
	//PRESTADOR							|
	|  Cliente ?						|
	|  Loja								|
	|  Mandato CIPA ?					|
	|  Qtdade de Fichas Inscricao ?		|
	|  Fichas por Pagina ?				|
	|  Tipo de Impressao ?				|
	-----------------------------------*/

	If Pergunte(cPerg,.t.)
		Processa({|lEND| MDTA923IMP()},STR0002) //"Imprimindo..."
	Endif

	RestArea(aArea)

	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	NGRETURNPRM(aNGBEGINPRM)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA923IMP

Funcao de impressao

@author  Denis Hyroshi de Souza
@since   16/10/2006

@return  Nulo, Sempre nulo
/*/
//-------------------------------------------------------------------
Static Function MDTA923IMP()

Local nInd

Private oPrint    := FwMsPrinter():New( OemToAnsi(titulo))

Private oFont09	  := TFont():New("VERDANA",09,09,,.F.,,,,.F.,.F.)
Private oFont11	  := TFont():New("VERDANA",11,11,,.F.,,,,.F.,.F.)
Private oFont12n  := TFont():New("VERDANA",12,12,,.T.,,,,.F.,.F.)
Private oFont12	  := TFont():New("VERDANA",12,12,,.F.,,,,.F.,.F.)
Private l1st_page := .T. // Controla impressao da primeira pagina ou nao

Lin := 4000
oPrint:SetPortrait() // Retrato

If lSigaMdtps

	dbSelectArea("TNN")
	dbSetOrder(3)  //TNN_FILIAL+TNN_CLIENT+TNN_LOJAC+TNN_MANDAT
	dbSeek(xFilial("TNN")+mv_par01+mv_par02+mv_par03)

	For nInd := 1 To Mv_par04
		If (nInd % 2) <> 0 .or. Mv_par05 == 1
			If nInd > 1
				oPrint:EndPage()
			Endif
			oPrint:StartPage()
			lin := 200
		Else
			lin := 1500
		Endif

		oPrint:Box(lin,500,lin+900,2000)
		// Localização do Logo da Empresa
		oPrint:SayBitMap(lin+020,520,NGLocLogo(),250,50)
		oPrint:Say(lin+080,850,IIf( lMdtMin, STR0021, IIf( lCipatr, STR0018, STR0003 )), oFont12n) //"FICHA DE INSCRIÇÃO PARA ELEIÇÃO DA CIPATR"

		cTitTxt := STR0004+StrZero(Year(TNN->TNN_DTINIC),4) //"GESTÃO - "
		If Year(TNN->TNN_DTINIC) <> Year(TNN->TNN_DTTERM)
			cTitTxt += "/"+Substr(StrZero(Year(TNN->TNN_DTTERM),4),3,2)
		Else
			cTitTxt += Space(5)
		Endif
		cTitTxt := PadR(cTitTxt,18)
		oPrint:Say(lin+140,1125,cTitTxt,oFont12)

		oPrint:Box(lin+210,520,lin+350,1980)
		oPrint:Say(lin+220,530,STR0005,oFont12) //"Nome:"
		oPrint:Line(lin+280,520,lin+280,1980)
		oPrint:Say(lin+290,530,STR0006,oFont12) //"Cargo:"

		cTxtCIPA := STR0007 //"Venho, através desta, candidatar-me para eleição dos representantes dos empregados na "
		cTxtCIPA += IIf( lMdtMin, STR0022, IIf( lCipatr, STR0019, STR0008 )) //"Comissão Interna de Prevenção de Acidentes no Trabalho Rural - CIPATR da " //"Comissão Interna de Prevenção de Acidentes - CIPA da "
		cTxtCIPA += Alltrim(NGSeek('SA1',TNN->(TNN_CLIENT+TNN_LOJAC),1,'SA1->A1_NOME'))

		oPrint:Say(lin+400,520,MEMOLINE(cTxtCIPA,80,1),oFont09)
		oPrint:Say(lin+440,520,MEMOLINE(cTxtCIPA,80,2),oFont09)
		oPrint:Say(lin+480,520,MEMOLINE(cTxtCIPA,80,3),oFont09)

		cCidade  := Alltrim(SM0->M0_CIDCOB)
		cCidade  += ", "+Strzero(Day(dDataBase),2)+STR0009 //" de "
		cCidade  += UPPER(MesExtenso(dDataBase))+STR0009 //" de "
		cCidade  += Strzero(Year(dDataBase),4)

		oPrint:Say(lin+560,520,cCidade,oFont09)

		oPrint:Line(lin+800,520,lin+800,1230)
		oPrint:Say(lin+810,650,STR0010,oFont09) //"Assinatura do Candidato"
		oPrint:Line(lin+800,1270,lin+800,1980)
		oPrint:Say(lin+810,1400,STR0011,oFont09) //"Responsável Pela Inscrição"

	Next nInd

	If Mv_par04 > 0
		oPrint:EndPage()
	Endif

	If mv_par06 == 1
		oPrint:Preview()
	Else
		oPrint:Print()
	EndIf

Else

	dbSelectArea("TNN")
	dbSetOrder(1)
	dbSeek(xFilial("TNN")+mv_par01)

	For nInd := 1 To Mv_par02
		If (nInd % 2) <> 0 .or. Mv_par03 == 1
			If nInd > 1
				oPrint:EndPage()
			Endif
			oPrint:StartPage()
			lin := 200
		Else
			lin := 1500
		Endif

		oPrint:Box(lin,500,lin+900,2000)
		// Localização do Logo da Empresa
		oPrint:SayBitMap(lin+020,520,NGLocLogo(),250,50)
		oPrint:Say(lin+080,850,IIf( lMdtMin, STR0021, IIf( lCipatr, STR0018, STR0003 )),oFont12n) //"FICHA DE INSCRIÇÃO PARA ELEIÇÃO DA CIPATR" //"FICHA DE INSCRIÇÃO PARA ELEIÇÃO DA CIPA"

		cTitTxt := STR0004+StrZero(Year(TNN->TNN_DTINIC),4) //"GESTÃO - "
		If Year(TNN->TNN_DTINIC) <> Year(TNN->TNN_DTTERM)
			cTitTxt += "/"+Substr(StrZero(Year(TNN->TNN_DTTERM),4),3,2)
		Else
			cTitTxt += Space(5)
		Endif
		cTitTxt := PadR(cTitTxt,18)
		oPrint:Say(lin+140,1125,cTitTxt,oFont12)

		oPrint:Box(lin+210,520,lin+350,1980)
		oPrint:Say(lin+250,530,STR0005,oFont12) //"Nome:"
		oPrint:Line(lin+280,520,lin+280,1980)
		oPrint:Say(lin+320,530,STR0006,oFont12) //"Cargo:"

		cTxtCIPA := STR0007 //"Venho, através desta, candidatar-me para eleição dos representantes dos empregados na "
		cTxtCIPA += IIf( lMdtMin, STR0022, IIf( lCipatr, STR0019, STR0008 )) //"Comissão Interna de Prevenção de Acidentes no Trabalho Rural - CIPATR da " //"Comissão Interna de Prevenção de Acidentes - CIPA da "
		cTxtCIPA += Alltrim(SM0->M0_NOMECOM)+"."

		oPrint:SayAlign(lin+400,580,cTxtCIPA,oFont11, 1300, 145, , 3, 0 )

		cCidade  := Alltrim(SM0->M0_CIDCOB)
		cCidade  += ", "+Strzero(Day(dDataBase),2)+STR0009 //" de "
		cCidade  += UPPER(MesExtenso(dDataBase))+STR0009 //" de "
		cCidade  += Strzero(Year(dDataBase),4)

		oPrint:Say(lin+600,580,cCidade,oFont09)

		oPrint:Line(lin+800,520,lin+800,1230)
		oPrint:Say(lin+850,650,STR0010,oFont09) //"Assinatura do Candidato"
		oPrint:Line(lin+800,1270,lin+800,1980)
		oPrint:Say(lin+850,1400,STR0011,oFont09) //"Responsável Pela Inscrição"

	Next nInd

	If Mv_par02 > 0
		oPrint:EndPage()
	Endif

	If mv_par04 == 1
		oPrint:Preview()
	Else
		oPrint:Print()
	EndIf

Endif

Return NIL