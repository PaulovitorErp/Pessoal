#INCLUDE "MDTA333.ch"
#include "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MDTA333  ³ Autor ³ Denis Hyroshi de Souza³ Data ³11/01/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Confirmação do recibo de entrega do Epi ao funcionario.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Objetivo  ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDTA333( lIndDev )

// Armazena variaveis p/ devolucao (NGRIGHTCLICK)
Local aNGBEGINPRM := NGBEGINPRM()

Private lSigaMdtPS	:= If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )
Private aRotina		:= MenuDef()
Private cCadastro
Private lCallDev	:= .F.
Default lIndDev		:= fChooseRec()

lCallDev	:= lIndDev
cCadastro	:= If( lIndDev, OemtoAnsi( STR0019 ), OemtoAnsi( STR0001 ) ) //"Confirmação de Devolução de EPI (Por Biometria)"##"Confirmação de Entrega de EPI (Por Biometria)"

If SuperGetMv("MV_NG2BIOM",.F.,"2") != "1"
	MsgStop(STR0002) //"O parâmetro de utilização de Biometria está desativado."
	Return .F.
Endif

If lSigaMdtps
	dbSelectArea("SA1")
	dbSetOrder(1)
	mBrowse( 6, 1,22,75,"SA1")
Else
	dbSelectArea("SRA")
	dbSetOrder(1)
	mBrowse( 6, 1,22,75,"SRA",,,,,,fCriaCor() )
Endif

// Devolve variaveis armazenadas (NGRIGHTCLICK)
NGRETURNPRM(aNGBEGINPRM)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MDT333SRA  ³ Autor ³ Denis                   ³ Data ³29/06/10  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Filtra os funcionarios do cliente                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MDTA333()                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                ³±±
±±³          ³                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³  SIGAMDT                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function MDT333SRA()

Local aArea	:= GetArea()
Local oldROTINA := aCLONE(aROTINA)
cCliMdtPs := SA1->A1_COD+SA1->A1_LOJA

nSizeSA1 := If((TAMSX3("A1_COD")[1]) < 1,6,(TAMSX3("A1_COD")[1]))
nSizeLo1 := If((TAMSX3("A1_LOJA")[1]) < 1,2,(TAMSX3("A1_LOJA")[1]))

aRotina :=	{{STR0003, "AxPesqui", 0, 1},; //"Pesquisar"
			 {STR0004, "NGCAD01" , 0, 2},; //"Visualizar"
             { STR0005, "MDT333EPI", 0 , 4},; //"Epis"
             { STR0006, "gpLegend", 0 , 6, 0, .F.}} //"Legenda"

dbSelectArea("SRA")
Set Filter To SubStr(SRA->RA_CC,1,nSizeSA1+nSizeLo1) == cCliMdtps
dbSetOrder(1)
mBrowse( 6, 1,22,75,"SRA",,,,,,fCriaCor() )

dbSelectArea("SRA")
Set Filter To

aROTINA := aCLONE(oldROTINA)
RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MenuDef  ³ Autor ³ Rafael Diogo Richter  ³ Data ³29/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Utilizacao de Menu Funcional.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaMDT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados         ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
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
Static Function MenuDef()

Local lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )
Local aRotina

If lSigaMdtps
	aRotina := { { STR0003,   "AxPesqui"  , 0 , 1},; //"Pesquisar"
	             { STR0004,   "NGCAD01"   , 0 , 2},; //"Visualizar"
	             { STR0007,   "MDT333SRA" , 0 , 4} } //"Funcionários"
Else
	aRotina :=	{ { STR0003, "AxPesqui", 0 , 1},; //"Pesquisar"
                  { STR0004, "NGCAD01", 0 , 2},; //"Visualizar"
                  { STR0005, "MDT333EPI", 0 , 4},; //"Epis"
                  { STR0006, "gpLegend", 0 , 6, 0, .F.}} //"Legenda"
Endif

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT333EPI
Tela de Programacao de Epi

@author Denis Hyroshi de Souza
@since 03/08/2009
@return nRet
/*/
//---------------------------------------------------------------------
Function MDT333EPI( cAlias , nReg , nOpcx ,lIndDev, lDevParc )

	Local nRet     := 0
	Local oFont10  := TFont():New( "Arial",, -12, .T., .T. )
	
	Local aScrRes  := GetScreenRes()
	Local aNgCadBt := {}
	
	Local lGeneric := NGCADICBASE("TN3_GENERI","D","TN3",.F.)
	Local lAddFil	 := .F.
	Local lBioLeg := SuperGetMV('MV_BIOMDT', .F., '1') == '1'
	
	Local cVldWhl  := "TNF->TNF_INDDEV == '2' .And. Empty(TNF->TNF_DTRECI)"
	Local cRegBio  := ''
	Local cFil
	Local cMat
	Local cRAMat
	Local cRANome

	Private aVetFor   := {}
	Private oChecked  := LoadBitmap( GetResources(), "LBTIK" )
	Private oUnCheck  := LoadBitmap( GetResources(), "LBNO"  )
	Private aClassBox := {;
						   "1="+Alltrim( NGRETTITULO( "TNF_CODEPI" ) ),;
						   "2="+Alltrim( NGRETTITULO( "TNF_DESC"   ) ),;
						   "3="+Alltrim( NGRETTITULO( "TNF_QTDENT" ) ),;
						   "4="+Alltrim( NGRETTITULO( "TNF_DTENTR" ) ),;
						   "5="+Alltrim( NGRETTITULO( "TNF_FORNEC" ) ),;
						   "6="+Alltrim( NGRETTITULO( "TNF_NUMCAP" ) );
						}

	Private cOrdemEPI := Space(1)
	Private lImpR805  := .T.
	Private oEpiProg
	Private aEpiProg
	Private bEpiProg
	Private aDigTM0
	Private aRetBio

	//Variáveis para devolução biométrica.
	Private lDevol	 := .F.
	Default lIndDev	 := .F.
	Default lDevParc := .F.

	lDevol := lIndDev

	If Type( "lCallDev" ) == "L"
		lDevol := lCallDev
	EndIf

	cCadastro := If( lDevol, OemtoAnsi( STR0019 ), OemtoAnsi( STR0001 ) ) //"Confirmação de Devolução de EPI (Por Biometria)"##"Confirmação de Entrega de EPI (Por Biometria)"

	//Verifica se Epi deverá ser devolvido pela biometria
	If lDevol
		cVldWhl := "TNF->TNF_INDDEV == '1' .And. TNF->TNF_DEVBIO <> '1'"
	EndIf

	dbSelectArea("TM0")
	dbSetOrder(3)
	If IsInCallStack( "MDTA333" )
		cFil := SRA->RA_FILIAL
		cMat := SRA->RA_MAT
	Else
		cFil := M->RA_FILIAL
		cMat := M->RA_MAT
	EndIf
	If !dbSeek(cFil+cMat)
		MsgInfo(STR0008) //"O Funcionário não possui ficha médica."
		Return .f.
	EndIf
	If TM0->TM0_INDBIO <> "1"
		MsgInfo(STR0009 ) //"O Funcionário não está configurado para utilizar Biometria."
		Return .f.
	Endif

	dbSelectArea("TM0")
	dbSetOrder(1)
	If lBioLeg
		aDigTM0 := MdtRetBio(TM0->TM0_NUMFIC,"TM0")

		If Len(aDigTM0) == 0
			If !MsgYesNo(STR0010 + " " + STR0011 ) //"O Funcionário não possui Biometria cadastrada."###"Deseja cadastrar agora?"
				Return .f.
			Endif
			aRetBio := MdtGetBio(TM0->TM0_NUMFIC,"TM0",.F.)
			If Type("aRetBio[2]") != "L" .Or. !aRetBio[2]
				Return .f.
			Endif
			aDigTM0 := MdtRetBio(TM0->TM0_NUMFIC,"TM0")
		EndIf

	Else

		If Empty(TM0->TM0_REGBIO)
			Help( ' ', 1, 'Aviso',, STR0010, 2, 0,,,,,, { STR0025 } )//"Efetue o cadastro biométrico para esta ficha médica."
		Else
			cRegBio := TM0->TM0_REGBIO
		EndIf
	EndIf

	aEpiProg := {}
	
	dbSelectArea("TNF")
	dbSetOrder(3)
	dbSeek( xFilial("TNF") + cMat )
	
	While !Eof() .and. xFilial("TNF") == TNF->TNF_FILIAL .And. cMat == TNF->TNF_MAT
	
		lAddFil := .F.
		If &( cVldWhl )
			
			If lGeneric//Verifica se já rodou validação de EPI genérico
				dbSelectArea("TL0")
				dbSetOrder(2)//TL0_FILIAL+TL0_EPIFIL
				
				If dbSeek(xFilial("TL0")+TNF->TNF_CODEPI)  //Verificar se o Epi é um filho
					While TL0->( !Eof() ) .And. xFilial("TL0") == TL0->TL0_FILIAL .And. TL0->TL0_EPIFIL == TNF->TNF_CODEPI
						If TL0->TL0_FORNEC == TNF->TNF_FORNEC .And. TL0->TL0_LOJA == TNF->TNF_LOJA .And. TNF->TNF_NUMCAP == TL0->TL0_NUMCAP//Verifica se o Fornecedor e Loja são iguais
							dbSelectArea("SB1")
							dbSetOrder(1)
							dbSeek( xFilial("SB1") + TL0->TL0_EPIFIL )
							aAdd( aEpiProg , { .F. , TNF->TNF_CODEPI , SB1->B1_DESC , TNF->TNF_QTDENT , TNF->TNF_DTENTR, TNF->TNF_HRENTR, TNF->TNF_FORNEC,TNF->TNF_LOJA, TNF->TNF_NUMCAP } )
							lAddFil := .T.
							Exit
						EndIf
						TL0->( dbSkip() )
					End
				EndIf

			EndIf

			If !lAddFil
				dbSelectArea("TN3")
				dbSetOrder(1)//TN3_FILIAL+TN3_FORNEC+TN3_LOJA+TN3_CODEPI+TN3_NUMCAP
			
				If dbSeek( xFilial("TN3") + TNF->TNF_FORNEC + TNF->TNF_LOJA + TNF->TNF_CODEPI + TNF->TNF_NUMCAP )
					dbSelectArea("SB1")
					dbSetOrder(1)
					dbSeek( xFilial("SB1") + TNF->TNF_CODEPI )
					aAdd( aEpiProg , { .F. , TNF->TNF_CODEPI , SB1->B1_DESC , TNF->TNF_QTDENT , TNF->TNF_DTENTR, TNF->TNF_HRENTR, TN3->TN3_FORNEC, TN3->TN3_LOJA, TN3->TN3_NUMCAP } )
				EndIf
			
			EndIf

		EndIf
	
		TNF->( dbSkip() )
	End

	If Len(aEpiProg) == 0
		MsgInfo(STR0012) //"O Funcionário não possui Recibo pendente."
		Return .F.
	Endif
	fClaBrwEpi( "1", .F. )

	opcaoZZ := 0

	DEFINE MSDIALOG oDlg1 TITLE OemToAnsi(cCadastro) from 5,0 To (aScrRes[2]-95),(aScrRes[1]-15);
		of oMainwnd COLOR CLR_BLACK,CLR_WHITE STYLE nOr(WS_POPUP,WS_VISIBLE) Pixel
	
		oDlg1:lMaximized := .T.
		oDlg1:lEscClose := .F.

		//Painel sobre a tela
		oPanelFull :=  TPanel():New(01, 01,, oDlg1,,,, CLR_BLACK, CLR_WHITE, 100, 100)
			oPanelFull:Align := CONTROL_ALIGN_ALLCLIENT

		//Dados do Funcionario
		oPanelCab := TPanel():New( 0, 0,, oPanelFull,,,,, RGB(255, 255, 255), 12, 12, .F., .F. )
			oPanelCab:Align := CONTROL_ALIGN_TOP
			oPanelCab:nHeight := 80

		oPanelBrw := TPanel():New(01, 01,, oPanelFull,,,, CLR_BLACK, CLR_WHITE, 100, 100)
			oPanelBrw:Align := CONTROL_ALIGN_ALLCLIENT

		cRAMat := MDTHideCpo( SRA->RA_MAT, "RA_MAT" )
		cRANome := MDTHideCpo( SRA->RA_NOME, "RA_NOME" )

		@ 05, 003 Say Alltrim( NGRETTITULO( "RA_MAT" ) ) Of oPanelCab Pixel Font oFont10
		@ 05, 055 MsGet cRAMat Picture "@!" Size 40, 08 Of oPanelCab Pixel When .F.

		@ 05, 135 Say Alltrim( NGRETTITULO( "RA_NOME" ) ) Of oPanelCab Pixel Font oFont10
		@ 05, 170 MsGet cRANome Picture "@!" Size 150, 08 Of oPanelCab Pixel When .F.

		@ 19, 003 Say STR0013 OF oPanelCab Pixel Font oFont10 //"Classificar por:"
		@ 19, 055 ComboBox oCbx1 VAR cOrdemEPI Items aClassBox Size 60,60 Of oPanelCab When .T. Pixel Valid fClaBrwEpi(cOrdemEPI,.t.)

		@ 19, 135 CheckBox oCheck01 Var lImpR805 Prompt If( lDevol, STR0020, STR0014 ) Size 80, 7 Of oPanelCab //"Imprimir Recibo de Entrega"
		
		//Epis pendentes
		aCol800 := { 10, 40, 100, 40, 40, 40, 40, 20, 40 }
		aTit800 := {}
		
		aAdd( aTit800, "")
		aAdd( aTit800, Alltrim( NGRETTITULO( "TNF_CODEPI" ) ) )
		aAdd( aTit800, Alltrim( NGRETTITULO( "TNF_DESC"   ) ) )
		aAdd( aTit800, Alltrim( NGRETTITULO( "TNF_QTDENT" ) ) )
		aAdd( aTit800, Alltrim( NGRETTITULO( "TNF_DTENTR" ) ) )
		aAdd( aTit800, Alltrim( NGRETTITULO( "TNF_HRENTR" ) ) )
		aAdd( aTit800, Alltrim( NGRETTITULO( "TNF_FORNEC" ) ) )
		aAdd( aTit800, Alltrim( NGRETTITULO( "TNF_LOJA"   ) ) )
		aAdd( aTit800, Alltrim( NGRETTITULO( "TNF_NUMCAP" ) ) )
		
		bEpiProg := { || {;
							If( aEpiProg[oEpiProg:nAt, 1], oChecked, oUnCheck ),;
							aEpiProg[oEpiProg:nAt, 2],;
							aEpiProg[oEpiProg:nAt, 3],;
							TransForm(aEpiProg[oEpiProg:nAt,4],"@E 999,999.99"),;
							aEpiProg[oEpiProg:nAt,5],;
							aEpiProg[oEpiProg:nAt,6],;
							aEpiProg[oEpiProg:nAt,7],;
							aEpiProg[oEpiProg:nAt,8],;
							aEpiProg[oEpiProg:nAt,9];
					} }

		oEpiProg := TWBrowse():New( 017, 4, 175, 140,, aTit800, aCol800, oPanelBrw,,,,, {||},,,,,,, .F.,, .T.,, .F.,,, )
		oEpiProg:Align := CONTROL_ALIGN_ALLCLIENT
		oEpiProg:SetArray( aEpiProg )
		oEpiProg:bLine := bEpiProg
		oEpiProg:bLDblClick := { || fMarkEpi(), oEpiProg:DrawSelect() }
		oEpiProg:bHeaderClick := { |x, a| fMarkAll( x, a ) }
		oEpiProg:nAt := 1

	ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1, {|| opcaoZZ := 1,;
		If( !fGravaPrg( aDigTM0, lBioLeg, cRegBio ),;
			opcaoZZ := 0, oDlg1:End() ) },;
			{||oDlg1:End()},, aNgCadBt )

Return nRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fClaBrwEpi³ Autor ³Denis Hyroshi de Souza ³ Data ³03/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ordena a tela de Epi                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fClaBrwEpi(cTipInd,lRefr)
If cTipInd == "2"
	aSORT(aEpiProg,,,{|x,y| x[3]+x[2]+DtoS(x[5]) < y[3]+y[2]+DtoS(y[5]) })
ElseIf cTipInd == "3"
	aSORT(aEpiProg,,,{|x,y| x[4] < y[4] })
ElseIf cTipInd == "4"
	aSORT(aEpiProg,,,{|x,y| DtoS(x[5])+x[6] < DtoS(y[5])+y[6] })
ElseIf cTipInd == "5"
	aSORT(aEpiProg,,,{|x,y| x[7]+x[8]+x[9]+x[2] < y[7]+y[8]+y[9]+y[2] })
ElseIf cTipInd == "6"
	aSORT(aEpiProg,,,{|x,y| x[9]+x[7]+x[8]+x[2] < y[9]+y[7]+y[8]+y[2] })
Else
	aSORT(aEpiProg,,,{|x,y| x[2]+x[3]+DtoS(x[5]) < y[2]+y[3]+DtoS(y[5]) })
Endif
If lRefr
	oEpiProg:SetArray(aEpiProg)
	oEpiProg:bLine:= bEpiProg
	oEpiProg:GoTop()
	oEpiProg:Refresh()
Endif
Return .t.

//---------------------------------------------------------------------
/*/{Protheus.doc} fGravaPrg
Grava programação

@author Denis Hyroshi de Souza
@since 03/08/2009
@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fGravaPrg(aDigTM0, lBioLeg, cDigital)

	Local cD1,nX,lTem := .F.
	Local aReg := {}
	Local lExistBl3332 := ExistBlock("MDTA3332")
	Local lChkBio := .F.

	For nX := 1 To Len(aEpiProg)
		If aEpiProg[nX,1]
			lTem := .T.
		Endif
	Next nX

	If !lTem
		MsgStop(STR0015) //"Nenhum EPI foi selecionado."
		Return .F.
	Endif

	If lBioLeg
		cD1 := BioFGetFinger()
		If AllDigit(SubStr(cD1,1,12))
			cD1:=SubStr(cD1,13)
		EndIf

		If "ERRO" $ cD1 .Or. Len(Alltrim(cD1)) < 60
			If !("ERRO" $ cD1)
				MsgStop(STR0016) //"Falhou captura da impressão digital."
			Endif
			Return .F.
		EndIf

		nRet := BioChkFingers(cD1,aDigTM0)

		If nRet == 0
			MsgStop(STR0017) //"Digital não confere com o cadastro deste funcionário."
			Return .F.
		Else
			If !MsgYesNo( If( lDevol, STR0021, STR0018 ) ) //"Digital confere com o cadastro deste funcionário. Confirmar a devolução do EPI?"##"Digital confere com o cadastro deste funcionário. Confirmar a entrega do EPI?"
				Return .F.
			Else
				lChkBio := .T.
			Endif
		Endif
	
	Else
		If !MatchBio(cDigital)
			MsgStop(STR0017) //"Digital não confere com o cadastro deste funcionário."
			Return .F.
		Else
			lChkBio := .T.
		EndIf
	EndIf

	If ExistBlock("MDTA3331") //Ponto de Entrada MDTA3331
		ExecBlock("MDTA3331",.F.,.F.)
	EndIf

	If lImpR805
		For nX := 1 To Len(aEpiProg)
			If aEpiProg[nX,1]
				dbSelectArea("TNF")
				dbSetOrder(1)
				If dbSeek(xFilial("TNF")+aEpiProg[nX,7]+aEpiProg[nX,8]+aEpiProg[nX,2]+aEpiProg[nX,9]+SRA->RA_MAT+DtoS(aEpiProg[nX,5])+aEpiProg[nX,6])
					aAdd( aReg , TNF->(Recno()) )
				Endif
			Endif
		Next nX

		If Len(aReg) > 0
			MDTR805( ,, aReg, lDevol,, lChkBio )
		Endif
	Endif

	For nX := 1 To Len(aEpiProg)
		If aEpiProg[nX,1]
			dbSelectArea("TNF")
			dbSetOrder(1)
			If dbSeek(xFilial("TNF")+aEpiProg[nX,7]+aEpiProg[nX,8]+aEpiProg[nX,2]+aEpiProg[nX,9]+SRA->RA_MAT+DtoS(aEpiProg[nX,5])+aEpiProg[nX,6])
				RecLock("TNF",.F.)
				If lDevol
					TNF->TNF_DEVBIO := "1"
				Else
					TNF->TNF_DTRECI := dDataBase
					If lBioLeg
						TNF->TNF_DIGIT1 := SubStr(cD1,  1,200)
						TNF->TNF_DIGIT2 := SubStr(cD1,201,200)
					Else
						TNF->TNF_ENTBIO := '1'
						//TNF->TNF_BIORET
					EndIf

				EndIf
				TNF->(MsUnLock())
				//----------------------------------------------
				// Ponto de Entrada para Preencher Data Recibo
				//----------------------------------------------
				If lExistBl3332
					ExecBlock("MDTA3332",.F.,.F.,{lDevol})
				EndIf
			Endif
		Endif
	Next nX

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fMarkAll ³ Autor ³Denis Hyroshi de Souza ³ Data ³03/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Marcar / Desmarcar todos                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fMarkAll(_Objeto,_nColHead)
Local nX, nOld := oEpiProg:nAt
If _nColHead == 1
	For nX := 1 To Len(aEpiProg)
		oEpiProg:nAt := nX
		fMarkEpi()
	Next nX
Endif
oEpiProg:nAt := nOld
oEpiProg:Refresh()
Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fMarkEpi ³ Autor ³Denis Hyroshi de Souza ³ Data ³03/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Marcar / Desmarcar Epi                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fMarkEpi()
aEpiProg[oEpiProg:nAt,1] := !aEpiProg[oEpiProg:nAt,1]
Return .t.

/*/------------------------------------------------------------------
{Protheus.doc} AllDigit
Função para teste de Biometria.
@author Rodrigo Soledade
@since 24/06/2013
---------------------------------------------------------------------
/*/
Static Function AllDigit(cVar)

Local lRet	:= .T.
Local nX	:= 0

For nX := 1 To Len(cVar)
	If ! IsDigit(SubStr(cVar,nX,1))
		lRet := .F.
		Exit
	EndIf
Next

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fChooseRec
Apresenta escolha entre validar recibo de entrega ou devolução

@author Bruno Souza
@since 27/03/2022
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fChooseRec()
	
	Local oDlgChoose
	Local oSay
	Local oTBtnRec, oTBtnDev
	Local lDev := .F.

	Local oFont12  := TFont():New("Arial",,-12,.T.,.T.)

	DEFINE DIALOG oDlgChoose TITLE "Tipo de Recibo" FROM 180,180 TO 300,550 PIXEL
		
		oSay := TSay():New( 05, 10, {||STR0022}, oDlgChoose,, oFont12,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 )
		
		oTBtnRec := TButton():New( 032, 045, STR0023, oDlgChoose, {||lDev := .F., oDlgChoose:End()},;
			40,15,,,.F.,.T.,.F.,,.F.,,,.F. )    
  		oTBtnDev := TButton():New( 032, 095, STR0024, oDlgChoose, {||lDev := .T., oDlgChoose:End()},;
			40,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	ACTIVATE DIALOG oDlgChoose CENTERED
	
Return lDev
