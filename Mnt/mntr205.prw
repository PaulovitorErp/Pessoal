#INCLUDE "PROTHEUS.CH"
#INCLUDE "MNTR205.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MNTR205  ³ Autor ³ Vitor Emanuel Batista ³ Data ³13/11/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio de Check List Padrao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Manutencao de Ativos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ F.O  ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTR205(cCODFAM,cTIPMOD,cSEQFAM)

	//Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	Local aNGBEGINPRM := NGBEGINPRM()
	Default cSEQFAM := ""

	Private cPerg := 'MNT205    '
	Private cSEQFML := cSEQFAM

	If (cCODFAM <> Nil) .And. (cTIPMOD <> Nil)
		MV_PAR01 := cCODFAM
		MV_PAR02 := cCODFAM
		MV_PAR03 := cTIPMOD
		MV_PAR04 := cTIPMOD
		MV_PAR05 := 1
	Else
		If !Pergunte(cPerg,.t.)
			Return
		EndIf
	Endif

	RptStatus({|lEnd| MNT205R(),STR0007,STR0008 }) //"Check-List"###"Imprimindo..."

	//Devolve variaveis armazenadas (NGRIGHTCLICK)
	NGRETURNPRM(aNGBEGINPRM)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNT205R   ³ Autor ³Vitor Emanuel Batista  ³ Data ³13/11/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do Relat¢rio                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNT205R()
	Private oPrint
	Private lin := 0
	Private oFont08,oFont09,oFont10,oFont11,oFont12,oFont13,oFont14

	oFont07  := TFont():New("Arial",07,07,,.F.,,,,.F.,.F.)
	oFont08  := TFont():New("Arial",08,08,,.F.,,,,.F.,.F.)
	oFont09  := TFont():New("Arial",09,09,,.F.,,,,.F.,.F.)
	oFont09B := TFont():New("Arial",09,09,,.T.,,,,.F.,.F.)
	oFont09s := TFont():New("Arial",09,09,,.T.,,,,.T.,.T.)
	oFont10  := TFont():New("Arial",10,10,,.F.,,,,.F.,.F.)
	oFont10s := TFont():New("Arial",10,10,,.F.,,,,.F.,.T.)
	oFont11  := TFont():New("Arial",11,11,,.T.,,,,.F.,.F.)

	oPrint	:= TMSPrinter():New(OemToAnsi(STR0010))  //"Check List"
	oPrint:Setup()

	R205Imp(oPrint)
	If Mv_par05 == 2
		oPrint:Print()
	Else
		oPrint:Preview()
	Endif

Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ R205Imp  ³ Autor ³Vitor Emanuel Batista  ³ Data ³12/11/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Impressao do Relatorio                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R205Imp(oPrint)

	Local lAlta, lMedia, lBaixa
	Local lEntrou := .F.
	Local cKeyTTE, cKeyETA
	Local cWhileTTE, cWhileETA
	Local nOrd      := 3
	Local lRel12133 := GetRpoRelease() >= '12.1.033'
	// A partir do release 12.1.33, o parâmetro MV_NGMNTFR será descontinuado
	// Haverá modulo específico para a gestão de Frotas no padrão do produto
	Local lFrota := IIf( FindFunction('MNTFrotas'), MNTFrotas(), GetNewPar('MV_NGMNTFR','N') == 'S' )

	cFileLogo := NGLOCLOGO()

	Store .F. to lAlta, lMedia, lBaixa

	Private nPag
	dbSelectArea("TTD")
	DbGoTop()
	SetRegua(LastRec())
	While !Eof()

		IncRegua()

		cKeyTTE   := TTD->TTD_CODFAM+TTD->TTD_TIPMOD
		cKeyETA   := TTD_CODFAM+TTD_TIPMOD+TTD_SEQFAM

		cWhileTTE := "TTE->TTE_FILIAL+TTE->TTE_CODFAM+TTE->TTE_TIPMOD"
		cWhileETA := "TTE_FILIAL+TTE_CODFAM+TTE_TIPMOD+TTE_SEQFAM"

		If !Empty(cSEQFML)
			If TTD->TTD_CODFAM < MV_PAR01 .Or. TTD->TTD_CODFAM > MV_PAR02 .Or. ;
			TTD->TTD_TIPMOD < MV_PAR03 .Or. TTD->TTD_TIPMOD > MV_PAR04 .Or. ;
			(TTD->TTD_SEQFAM != cSEQFML)
				dbSelectArea("TTD")
				dbSkip()
				Loop
			EndIf
		Else
			If TTD->TTD_CODFAM < MV_PAR01 .Or. TTD->TTD_CODFAM > MV_PAR02 .Or. ;
			TTD->TTD_TIPMOD < MV_PAR03 .Or. TTD->TTD_TIPMOD > MV_PAR04
				dbSelectArea("TTD")
				dbSkip()
				Loop
			EndIf
		EndIf

		cKeyTTE   += TTD->TTD_SEQFAM
		cWhileTTE += " + TTE->TTE_SEQFAM"

		lEntrou := .T.
		nPag := 0
		oPrint:StartPage()
		nPag ++
		lin := 100

		If File(cFileLogo)
			oPrint:SayBitMap(100,100,cFileLogo,250,120)
		EndIf

		oPrint:Say(lin+40,1050,STR0010,oFont11) //"CHECK LIST"
		oPrint:Say(lin+10,2120,STR0011 + cValToChar(nPag),oFont07) //"PÁG.:   "
		oPrint:Say(lin+45,2120,STR0012 + cValToChar(Date()),oFont07) //"DATA.: "
		oPrint:Say(lin+80,2120,STR0013 + Time(),oFont07) //"HORA.: "

		lin := 220
		oPrint:Line(lin,100,lin,2300)

		lin += 120
		oPrint:Say(lin,130,STR0014,oFont09B)  //"Família.:"
		oPrint:Say(lin,300,TTD->TTD_CODFAM  + ' - ' + NGSEEK("ST6",TTD->TTD_CODFAM,1,"T6_NOME"),oFont10)
		oPrint:Say(lin,1250,STR0033,oFont09B)  //"Sequência.:"
		oPrint:Say(lin,1420,TTD->TTD_SEQFAM,oFont10)
		oPrint:Say(lin+100,130,STR0015,oFont09B)  //"Modelo.:"
		oPrint:Say(lin+100,300,TTD->TTD_TIPMOD + ' - ' + IIf( lRel12133, MNTDesTpMd( TTD->TTD_TIPMOD ), NGSEEK( 'TQR', TTD->TTD_TIPMOD, 1, 'Alltrim( TQR->TQR_DESMOD )' ) ),oFont10)

		lin += 200

		oPrint:Say(lin,130,STR0016,oFont09B)  //"Executante.:"
		oPrint:Line(lin+30,300,lin+30,1040)
		oPrint:Say(lin,1060,STR0017,oFont09B)  //"Assinatura.:"
		oPrint:Line(lin+30,1230,lin+30,1660)
		oPrint:Say(lin,1680,Capital(STR0012),oFont09B)  //"Data.:"
		oPrint:Say(lin,1785,"_____/_____/_____",oFont08)
		oPrint:Say(lin,2060,STR0018,oFont09B)  //"Hora.:"

		lin += 100
		oPrint:Say(lin,130,STR0019,oFont09B)  //"Bem.:"
		oPrint:Line(lin+30,300,lin+30,800)
		// A partir do release 12.1.33, o parâmetro MV_NGMNTFR será descontinuado
		// Haverá modulo específico para a gestão de Frotas no padrão do produto
		If lFrota
			oPrint:Say(lin,820,STR0020,oFont09B)  //"Placa.:"
			oPrint:Line(lin+30,940,lin+30,1230)
			oPrint:Say(lin,1250,STR0021,oFont09B)  //"Contador 1.:"
			oPrint:Line(lin+30,1420,lin+30,1750)
			oPrint:Say(lin,1770,STR0022,oFont09B) 	 //"Contador 2.:"
			oPrint:Line(lin+30,1940,lin+30,2250)
		Else
			oPrint:Say(lin,820,STR0021,oFont09B)  //"Contador 1.:"
			oPrint:Line(lin+30,990,lin+30,1320)
			oPrint:Say(lin,1340,STR0022,oFont09B) 	 //"Contador 2.:"
			oPrint:Line(lin+30,1510,lin+30,1820)
		Endif

		lin += 150
		oPrint:Say(lin,130,STR0023,oFont09B)  //"Obs.:"

		lin += 50
		oPrint:Line(lin,300,lin,2250)
		oPrint:Line(lin+70,300,lin+70,2250)
		oPrint:Line(lin+140,300,lin+140,2250)
		oPrint:Line(lin+210,300,lin+210,2250)

		dbSelectArea("TTE")
		dbSetOrder(nOrd)
		dbSeek(xFilial("TTE")+cKeyTTE)
		While !Eof() .And. xFilial("TTE") + cKeyTTE == &cWhileTTE
			If !Empty(TTE->TTE_ALTA)
				lAlta := .T.
			EndIf
			If !Empty(TTE->TTE_MEDIA)
				lMedia := .T.
			Endif
			If !Empty(TTE->TTE_BAIXA)
				lBaixa := .T.
			EndIf

			dbSelectArea("TTE")
			dbSkip()
		End

		lin += 310
		oPrint:Say(lin,1770,STR0027,oFont09B) //"Criticidade"
		lin += 50
		oPrint:Say(lin,130,STR0024,oFont09B) //"Problema"
		oPrint:Say(lin,300,STR0025,oFont09B) //"Etapa"
		oPrint:Say(lin,500,STR0026,oFont09B) //"Descrição Etapa"

		oPrint:Say(lin,1600,STR0028,oFont09B) //"Alta"
		oPrint:Say(lin,1800,STR0029,oFont09B) //"Média"
		oPrint:Say(lin,2000,STR0030,oFont09B) //"Baixa"
		oPrint:Line(lin+50,100,lin+50,2300)
		oPrint:Line(lin+52,100,lin+52,2300)

		dbSelectArea("TTE")
		dbSetOrder(nOrd)
		dbSeek(xFilial("TTE")+cKeyETA)
		While !Eof() .And. xFilial("TTE") + cKeyETA == &cWhileETA

			Somalinha(100,.T.)
			oPrint:Box(lin,160,lin+35,210)
			oPrint:Say(lin,300,TTE->TTE_ETAPA,oFont09)
			oPrint:Say(lin,500,Substr(NGSEEK("TPA",TTE->TTE_ETAPA,1,"TPA_DESCRI"),1,50),oFont09)

			If !Empty(TTE->TTE_ALTA)
				oPrint:Box(lin,1600,lin+35,1650)
			EndIf
			If !Empty(TTE->TTE_MEDIA)
				oPrint:Box(lin,1810,lin+35,1860)
			Endif
			If !Empty(TTE->TTE_BAIXA)
				oPrint:Box(lin,2010,lin+35,2060)
			EndIf

			dbSelectArea("TTE")
			dbSkip()
		End

		oPrint:EndPage()

		dbSelectArea("TTD")
		dbSkip()
	EndDo

	If !lEntrou
		MsgStop(STR0009,STR0032) //"Relatório sem dados."###"Atenção"
		Return .F.
	EndIf
Return .t.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SOMALINHA ³ Autor ³Vitor Emanuel Batista  ³ Data ³13/11/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Impressao do Relatorio                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Somalinha(nLinhas,lLinFim)

	If lLinFim == Nil
		lLinFim := .t.
	EndIf

	If nLinhas == Nil
		Lin += 50
	Else
		Lin += nLinhas
	EndIf

	If lin > 3100
		If lLinFim
			oPrint:Line(lin,100,lin,2300)
		Endif
		oPrint:EndPage()
		oPrint:StartPage()
		nPag++
		lin := 100

		If File(cFileLogo)
			oPrint:SayBitMap(100,100,cFileLogo,250,120)
		EndIf

		oPrint:Say(lin+40,1000,STR0010,oFont11) //"CHECK LIST"
		oPrint:Say(lin+10,2120,STR0011 + cValToChar(nPag),oFont07) //"PÁG.:   "
		oPrint:Say(lin+45,2120,STR0012 + cValToChar(Date()),oFont07) //"DATA.: "
		oPrint:Say(lin+80,2120,STR0013 + Time(),oFont07) //"HORA.: "

		lin := 220
		oPrint:Line(lin,100,lin,2300)
		lin += 100
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MNT205MOD
Valida os campos de tipo modelo informado no pergunte MNT205

MV_PAR03 De Tipo Modelo?
MV_PAR04 Ate Tipo Modelo?

@type   Function

@author Eduardo Mussi
@since  30/07/2021

@Param  nType, Numérico, 1 - DE( MV_PAR03 ) 2 - Para( MV_PAR04 )
@Param  cTipoMod1, Caracter, Tipo modelo a ser validado( MV_PAR03 )
@Param  cTipoMod2, Caracter, Tipo modelo a ser validado( MV_PAR04 )

@return Lógico, define se o tipo modelo informado é valido
/*/
//-------------------------------------------------------------------
Function MNT205MOD( nType, cTipoMod1, cTipoMod2 )

	Local lReturn := .T.

	If nType == 1 .And. !Empty( cTipoMod1 )
		lReturn := Empty( cTipoMod1 ) .Or. RTrim( cTipoMod1 ) == '*' .Or. ExistCpo( 'TQR', cTipoMod1 )
	ElseIf nType == 2
		lReturn := RTrim( cTipoMod2 ) == '*' .Or. Atecodigo( 'TQR', cTipoMod1, cTipoMod2, 1 )
	EndIf

Return lReturn
