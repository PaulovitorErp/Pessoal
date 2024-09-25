#Include "Protheus.ch"
#Include "mdtr481.ch"
#Include "msole.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR481

Relatório de Resultado Exame Oftalmológico (SNELEN)

@author Bruno Lobo de Souza
@since 04/06/2018

@sample MDTR481()
@version MP11

@return Sempre Verdadeiro
/*/
//---------------------------------------------------------------------
Function MDTR481()

	Local aNgBeginPrm	:= ngBeginPrm() //Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	Local aArea			:= GetArea()
	Local oReport

	If GetRpoRelease() < "12.1.023" .Or. TM4->(ColumnPos("TM4_OFTIPO")) <= 0
		MsgInfo(STR0017, STR0018)
		Return .F.
	EndIf

	Private cPerg		:= "MDT481    "
	Private cAliasTemp	:= GetNextAlias()

	Pergunte(cPerg, .F.)

	//-- Interface de impressão
	oReport := ReportDef()
	oReport:PrintDialog()

	RestArea(aArea)

	ngReturnPrm(aNgBeginPrm) // Devolve variaveis armazenadas (NGRIGHTCLICK)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef

Define as seções impressas no relatório

@type    static function
@author  Bruno Lobo de Souza
@since   05/06/2018

@return oReport, object, instância da classe TReport
/*/
//-------------------------------------------------------------------
Static Function ReportDef()

	Local oReport
	Local oSecHeader
	Local oSecBody

	oReport := TReport():New("MDTR481", STR0001, "MDT481",;
		{|oReport| ReportPrint(oReport)}, STR0002)

	oSecHeader := TRSection():New(oReport, STR0003, {"TM5","TM0"})
		TRCell():New(oSecHeader, "TM0_MAT", "TM0", STR0004, "@!", 12,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oSecHeader, "TM5_NUMFIC", "TM5", STR0005, "@!", 15,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oSecHeader, "TM0_NOMFIC", "TM0", STR0006, "@!", 45,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRPosition():New(oSecHeader, "TM0", 1, {|| xFilial("TM0") + TM5->TM5_NUMFIC})

	oSecBody := TRSection():New(oReport, STR0007, {"TM5","TM4","TMU","TMK"})
		TRCell():New(oSecBody, "TM5_EXAME", "TM5", STR0008, "@!", 08,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oSecBody, "TM4_NOMEXA", "TM4", STR0015, "@!", 25,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oSecBody, "TM5_DTPROG", "TM5", STR0009, "99/99/9999", 15,/*lPixel*/, )
		TRCell():New(oSecBody, "TM5_DTRESU", "TM5", STR0010, "99/99/9999", 15,/*lPixel*/, )
		TRCell():New(oSecBody, "TM5_INDRES", "TM5", STR0011, "@!", 15,/*lPixel*/,{|| NGRETSX3BOX( "TM5_INDRES", TM5->TM5_INDRES) })
		TRCell():New(oSecBody, "TMU_RESULT", "TMU", STR0012, "@!", 55,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oSecBody, "TMK_NOMUSU", "TMK", STR0016, "@!", 85,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRPosition():New(oSecBody, "TM4", 1, {|| xFilial("TM4") + TM5->TM5_EXAME})
		TRPosition():New(oSecBody, "TYC", 1, {|| xFilial("TYC") + TM5->TM5_NUMFIC + DTOS(TM5->TM5_DTPROG) + TM5->TM5_HRPROG + TM5->TM5_EXAME})
		TRPosition():New(oSecBody, "TMK", 1, {|| xFilial("TMK") + TYC->TYC_ATENDE})

Return oReport

//-------------------------------------------------------------------
/*/ {Protheus.doc} ReportPrint

Impressão do relatório

@type  Static Function
@author Bruno Lobo de Souza
@since 05/06/2018
@param oReport, object, instância da classe tReport
@return boolean, sempre verdadeiro
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport)

	Local oSecHeader
	Local oSecBody

	Local cMatricula := ""
	Local cFichaMed  := ""
	Local cExameMed  := ""

	oSecHeader	:= oReport:Section(1)
	oSecBody	:= oReport:Section(2)

	dbSelectArea("TM5")
	dbSetOrder(1)
	dbGoTop()
	oReport:SetMeter(RecCount())
	While !Eof() .And. !oReport:Cancel() .And.;
		TM5->TM5_FILIAL == xFilial("TM5")
		oReport:IncMeter()

		If TM5->TM5_NUMFIC < Mv_Par01 .Or. TM5->TM5_NUMFIC > Mv_Par02
			TM5->(dbSkip())
			Loop
		EndIf
		If Posicione("TM4", 1, xFilial('TM4')+TM5->TM5_EXAME, "TM4_INDRES") <> '5' .Or.;
				Posicione("TM4", 1, xFilial('TM4')+TM5->TM5_EXAME, "TM4_OFTIPO") <> '2'
			TM5->(dbSkip())
			Loop
		EndIf
		If TM5->TM5_EXAME < Mv_Par03 .Or.;
				TM5->TM5_EXAME > Mv_Par04
			TM5->(dbSkip())
			Loop
		EndIf
		If TM5->TM5_DTRESU < Mv_Par05 .Or.;
				TM5->TM5_DTRESU > Mv_Par06
			TM5->(dbSkip())
			Loop
		EndIf

		cMatricula	:= TM5->TM5_MAT
		cFichaMed	:= TM5->TM5_NUMFIC
		cExameMed	:= TM5->TM5_EXAME

		oSecHeader:Init()
		oSecHeader:PrintLine()

		While !Eof() .And. cMatricula == TM5->TM5_MAT ;
					.And. cFichaMed == TM5->TM5_NUMFIC ;
					.And. cExameMed == TM5->TM5_EXAME ;
		 			.And. !oReport:Cancel()

			If Posicione("TM4", 1, xFilial('TM4')+TM5->TM5_EXAME, "TM4_INDRES") <> '5' .Or.;
					Posicione("TM4", 1, xFilial('TM4')+TM5->TM5_EXAME, "TM4_OFTIPO") <> '2'
				TM5->(dbSkip())
				Loop
			EndIf

			oSecBody:Init()
			oSecBody:PrintLine()
			TM5->(dbSkip())
		EndDo
		oSecBody:Finish()
		oSecHeader:Finish()
	EndDo

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT481VX1
Validações das perguntas do relatório
@type function
@author Bruno Lobo de Souza
@since 18/08/2018
@param cPerg, caracter, pergunta a ser validada
@return boolean, retorna o valor da validação
/*/
//-------------------------------------------------------------------
Function MDT481VX1(cPerg)

	Local lRet := .T.

	If cPerg == '03'
		If Empty(Mv_par03)

			lRet := .T.
		Else
			dbSelectArea("TM4")
			dbSetOrder(1)
			If dbSeek(xFilial("TM4")+Mv_par03) .And. TM4->TM4_OFTIPO == "2"
				lRet := .T.
			Else
				lRet := .F.
			EndIf
		EndIf
	ElseIf cPerg == '04'
		lRet := AteCodigo('TM4',mv_par03,mv_par04)
		If lRet .And. mv_par04 <> Replicate('Z', Len(mv_par04))
			dbSelectArea("TM4")
			dbSetOrder(1)
			lRet := dbSeek(xFilial("TM4")+Mv_par04) .And. TM4->TM4_OFTIPO == "2"
		EndIf
	EndIf

Return lRet