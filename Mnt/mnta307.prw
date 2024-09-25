#INCLUDE "PROTHEUS.CH"
#INCLUDE "MNTA307.ch"

//Posicoes do array de perguntas
#DEFINE __TUPGRU__ 01
#DEFINE __TUPPER__ 02
#DEFINE __TUPLIS__ 03
#DEFINE __TUPMEM__ 04
#DEFINE __TUP2RE__ 05
#DEFINE __TUPORD__ 06
#DEFINE __TUPQUE__ 07
#DEFINE __TUPVAL__ 08

#DEFINE __LENCOL__ 09//Define tamanho do aCols

//Posicoes do questionario
#DEFINE __QUESTAO__ 01
#DEFINE __PERGUNT__ 02
#DEFINE __CODGRUP__ 03
#DEFINE __RESPOST__ 04
#DEFINE __2PERGUN__ 05
#DEFINE __TIPLIST__ 06
#DEFINE __TENMEMO__ 07
#DEFINE __TOTRESP__ 08
#DEFINE __ORDEM__   09
#DEFINE __MEMO__    10

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA307
Configurações da Pesquisa

@return Nil

@sample
MNTA307()

@author Jackson Machado
@since 17/04/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Function MNTA307()

Local oDlgCfg
Local oPnlCfg
Local oObjClass
Local oFont12  := TFont():New("Arial",,-12,.T.,.T.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena variaveis p/ devolucao (NGRIGHTCLICK) 				  	  	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aNGBEGINPRM := NGBEGINPRM()

//Verifica se o update de facilities foi aplicado
If !FindFunction("MNTUPDFAC") .or. !MNTUPDFAC()
	Return .F.
Endif

DEFINE MSDIALOG oDlgCfg Title STR0001 From 0,0 To 170,312 Of oMainWnd Pixel //"Configuração - Pesquisa de Satisfação"
@ 000,000 MSPANEL oPnlCfg SIZE 170,150 OF oDlgCfg

@ 018,35 SAY STR0002 PIXEL OF oPnlCfg Font oFont12 //"Limiares da Pesquisa"
@ 030,25 BTNBMP oObjClass Resource 'AUTOM' Size 22,22 Pixel Of oPnlCfg Noborder Pixel Action MNTA307LIM()

@ 038,35 SAY STR0003 PIXEL OF oPnlCfg Font oFont12 //"Classificação da Pesquisa"
@ 070,25 BTNBMP oObjClass Resource 'FORM' Size 22,22 Pixel Of oPnlCfg Noborder Pixel Action fConfig()

@ 058,35 SAY STR0004 PIXEL OF oPnlCfg Font oFont12 //"Cadastro da Pesquisa"
@ 110,25 BTNBMP oObjClass Resource 'SDUIMPORT' Size 22,22 Pixel Of oPnlCfg Noborder Pixel Action MNT307BRW()

ACTIVATE MSDIALOG oDlgCfg CENTERED

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve variaveis armazenadas (NGRIGHTCLICK)                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
NGRETURNPRM(aNGBEGINPRM)

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT307BRW
Cadastro de Limiares da Pesquisa de Satisfação.

@author Wagner Sobral de Lacerda
@since 26/11/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Function MNTA307LIM()

	// Armazena estados e variáveis anteriores
	Local aNGBEGINPRM := NGBEGINPRM(,"MNTA307")
	Local cOldFil := cFilAnt

	// Variáveis do Browse
	Local oBrwLimiar

	// Variáveis Private necessárias
	Private cCadastro := STR0005 //"Limiares da Pesquisa de Satisfação"
	Private aRotina := {	{STR0006, "PesqBrw", 0, 1}, ; //"Pesquisar"
							{STR0007, "NGCAD01", 0, 2}, ; //"Visualizar"
							{STR0008, "NGCAD01", 0, 3}, ; //"Incluir"
							{STR0009, "NGCAD01", 0, 4}, ; //"Alterar"
							{STR0010, "NGCAD01", 0, 5, 3}  } //"Excluir"

	// Browse
	oBrwLimiar := FwMBrowse():New()
	oBrwLimiar:SetAlias("TUW")
	oBrwLimiar:SetDescription(cCadastro)
	oBrwLimiar:Activate()
	oBrwLimiar:DeActivate()

	// Devolve estados e variáveis
	cFilAnt := cOldFil
	NGRETURNPRM(aNGBEGINPRM)

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT307CLI
Cadastro de Limiares da Pesquisa de Satisfação relacionados a um
Questionário de Satisfação.

@author Wagner Sobral de Lacerda
@since 26/11/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Function MNT307CLI(cAlias, nRecNo, nOpcx)

	// Armazena estados e variáveis anteriores
	Local aNGBEGINPRM := NGBEGINPRM(,"MNTA307")
	Local aMemory := NGGetMemory("TUO")
	Local cOldFil := cFilAnt
	Local aAreaTUO := TUO->( GetArea() )
	Local aAreaTUP := TUP->( GetArea() )

	// Variáveis do Dialog
	Local aSize    := MsAdvSize(.T.) //.T. - Tem EnchoiceBar
	Local aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	Local aObjects := {{040,040,.T.,.T.},{100,100,.T.,.T.}}
	Local aPosObj  := MsObjSize(aInfo, aObjects,.f.)

	Local oDlgCadLim
	Local cDlgCadLim := OemToAnsi(STR0011) //"Limiares do Questionário"
	Local lDlgCadLim := .F.
	Local oPnlCadLim

	Local cCodQuest := ""
	Local cTipQuest := ""
	Local nPtsQuest := 0
	Local cWhile := ""

	Local oPnlCad
	Local oMsMGet
	Local oPnlPontos
	Local oPnlGet

	Local aBox := {}, cBox
	Local nBox
	Local nAT
	Local nX

	Local aGrava := {}, nGrava
	Local nCabec
	Local nPosLIMIAR := 0
	Local nPosDESLIM := 0

	Private oGetDados
	Private aHeader := {}, aCols := {}

	//----------
	// Executa
	//----------
	If cAlias == "TUO"
		cCodQuest := TUO->TUO_CODIGO
		cTipQuest := TUO->TUO_TIPO
		cWhile := "TUY->TUY_FILIAL == xFilial('TUY',M->TUO_FILIAL) .And. TUY->TUY_TIPO == '" + cTipQuest + "' .And. TUY->TUY_QUESTI == '" + cCodQuest + "'"

		// Recebe a Pontuação Total do Questionário
		dbSelectArea("TUP")
		dbSetOrder(1)
		dbSeek(xFilial("TUP",TUO->TUO_FILIAL) + cTipQuest + cCodQuest, .T.)
		While !Eof() .And. TUP->TUP_FILIAL == xFilial("TUP",TUO->TUO_FILIAL) .And. TUP->TUP_TIPO == cTipQuest .And. TUP->TUP_QUESTI == cCodQuest
			aBox := StrTokArr(AllTrim(TUP->TUP_VALORE), ";")
			For nBox := 1 To Len(aBox)
				cBox := aBox[nBox]
				nAT := AT("=",cBox)
				If nAT > 0
					nPtsQuest += Val( SubStr(cBox,nAT+1) )
				EndIf
			Next nBox
			dbSelectArea("TUP")
			dbSkip()
		End

		//--------------------
		// Monta o Dialog
		//--------------------
		dbSelectArea("TUO")
		RegToMemory("TUO", .F.)
		DEFINE MSDIALOG oDlgCadLim TITLE cDlgCadLim FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL

			// Painel principal do Dialog
			oPnlCadLim := TPanel():New(01, 01, , oDlgCadLim, , , , CLR_BLACK, CLR_WHITE, 100, 100)
			oPnlCadLim:Align := CONTROL_ALIGN_ALLCLIENT
			oPnlCadLim:CoorsUpdate()

				// Painel do MsMGet
				oPnlCad := TPanel():New(01, 01, , oPnlCadLim, , , , CLR_BLACK, CLR_WHITE, 100, 080)
				oPnlCad:Align := CONTROL_ALIGN_TOP
				oPnlCad:CoorsUpdate()

					// Monta Cadastro do Questionário
					oMsMGet := MsMGet():New(cAlias,nRecNo,2,/*aCRA*/,/*cLetras*/,/*cTexto*/,/*aChoice*/,aPosObj[1]/*aPos*/,/*aCpos*/,;
											3/*nModelo*/,/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oPnlCad/*oDlg*/,/*lF3*/,.T./*lMemoria*/,.F./*lColumn*/,;
											/*caTela*/,/*lNoFolder*/,/*lProperty*/, /*aField*/)
					oMsMGet:oBox:Align := CONTROL_ALIGN_ALLCLIENT

				// Painel dos Pontos
				oPnlPontos := TPanel():New(01, 01, , oPnlCadLim, , , , CLR_BLACK, CLR_WHITE, 100, 15)
				oPnlPontos:Align := CONTROL_ALIGN_TOP
				oPnlPontos:CoorsUpdate()

					@ 004,005 SAY OemToAnsi(STR0012) FONT TFont():New(,,,,.T.) OF oPnlPontos PIXEL //"Total de Pontos de Questionário:"
					@ 003,100 MSGET nPtsQuest PICTURE "@E 9,999" WHEN .F. SIZE 040,008 OF oPnlPontos PIXEL

				// Painel da GetDados
				oPnlGet := TPanel():New(01, 01, , oPnlCadLim, , , , CLR_BLACK, CLR_WHITE, 100, 100)
				oPnlGet:Align := CONTROL_ALIGN_ALLCLIENT
				oPnlGet:CoorsUpdate()

					// Get Dados
					FillGetDados(4/*nOpc*/, "TUY"/*cAlias*/, 1/*nOrder*/, cCodQuest/*cSeekKey*/, {||  }/*bSeekWhile*/, {|| .T. }/*uSeekFor*/, ;
									{"TUY_TIPO", "TUY_QUESTI", "TUY_LOJA"}/*aNoFields*/, /*aYesFields*/, /*lOnlyYes*/, /*cQuery*/, ;
									{|| NGMontaAcols("TUY",cTipQuest+cCodQuest,cWhile) }/*bMontCols*/, /*lEmpty*/, aHeader/*aHeaderAux*/, aCols/*aColsAux*/, ;
									/*bAfterCols*/, /*bBeforeCols*/, /*bAfterHeader*/, /*cAliasQry*/, /*bCriaVar*/, /*lUserFields*/, /*aYesUsado*/)
					nPosLIMIAR := aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "TUY_LIMIAR" })
					nPosDESLIM := aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "TUY_DESLIM" })
					If Len(aCols) == 0
						aCols := BlankGetD(aHeader)
					Else
						For nX := 1 To Len(aCols)
							For nCabec := 1 To Len(aHeader)
								aCols[nX][nPosDESLIM] := Posicione("TUW", 1, xFilial("TUW") + aCols[nX][nPosLIMIAR], "TUW_DESCRI")
							Next nX
						Next nX
					EndIf
					oGetDados := MsNewGetDados():New(0/*nTop*/, 0/*nLeft*/, 10/*nBottom*/, 10/*nRight */, GD_INSERT + GD_UPDATE + GD_DELETE/*nStyle*/, ;
														"MNT307VLD"/*cLinhaOk*/, "MNT307VLD"/*cTudoOk*/, /*cIniCpos*/, /*aAlter*/, /*nFreeze*/, ;
														99/*nMax*/, /*cFieldOk*/, /*cSuperDel*/, /*cDelOk*/, oPnlGet/*oWnd*/, aHeader/*aPartHeader*/, aCols/*aParCols*/, /*uChange*/, /*cTela*/)
					oGetDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

		ACTIVATE MSDIALOG oDlgCadLim ON INIT EnchoiceBar(oDlgCadLim, {|| lDlgCadLim := .T., oDlgCadLim:End() }, {|| lDlgCadLim := .F., oDlgCadLim:End() }) CENTERED

		// Se confirmou
		If lDlgCadLim
			aGrava := aClone(oGetDados:aCols)
			CursorWait()
			For nGrava := 1 To Len(aGrava)
				If !Empty(aGrava[nGrava][nPosLIMIAR])
					dbSelectArea("TUY")
					dbSetOrder(1)
					lFound := dbSeek(xFilial("TUY",M->TUO_FILIAL) + cTipQuest + cCodQuest + M->TUO_LOJA + aGrava[nGrava][nPosLIMIAR])
					Begin Transaction
					If aTail(aGrava[nGrava])
						If lFound
							RecLock("TUY", .F.)
							dbDelete()
							MsUnlock("TUY")
						EndIf
					Else
						RecLock("TUY", !lFound)
						TUY->TUY_FILIAL := xFilial("TUY",M->TUO_FILIAL)
						TUY->TUY_TIPO   := cTipQuest
						TUY->TUY_QUESTI := cCodQuest
						For nCabec := 1 To Len(aHeader)
							If aHeader[nCabec][10] <> "V"
								&("TUY->"+aHeader[nCabec][2]) := aGrava[nGrava][nCabec]
							EndIf
						Next nCabec
						MsUnlock("TUY")
					EndIf
					End Transaction
				EndIf
			Next nGrava
			CursorArrow()
		EndIf
	EndIf

	// Devolve estados e variáveis
	RestArea(aAreaTUP)
	RestArea(aAreaTUO)
	cFilAnt := cOldFil
	NGRETURNPRM(aNGBEGINPRM)
	NGRestMemory(aMemory)

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT307VLD
Validação da Linha do Cadastro de Limiar x Questionário.

@author Wagner Sobral de Lacerda
@since 26/11/2012
@version MP10/MP11
@return .T.
/*/
//---------------------------------------------------------------------
Function MNT307VLD()

	Local aLinhas := aClone(oGetDados:aCols)
	Local nLinha := oGetDados:nAT
	Local nPosLIMIAR := aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "TUY_LIMIAR" })
	Local nPosLIMDE  := aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "TUY_LIMDE" })
	Local nPosLIMATE := aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "TUY_LIMATE" })
	Local cCodLimiar := aLinhas[nLinha][nPosLIMIAR]
	Local nValLimDe  := aLinhas[nLinha][nPosLIMDE]
	Local nValLimAte := aLinhas[nLinha][nPosLIMATE]
	Local nX

	// Verifica duplicidade de LIMIAR
	For nX := 1 To Len(aLinhas)
		If nX <> nLinha .And. !aTail(aLinhas[nX])
			If aLinhas[nX][nPosLIMIAR] == cCodLimiar
				Help(Nil, Nil, STR0013, Nil, STR0014, 1, 0) //"Atenção" # "Código de Limiar já existente."
				Return .F.
			EndIf
		EndIf
	Next nX

	// Verifica De/Até Valor
	If nValLimAte < nValLimDe
		Help(Nil, Nil, STR0013, Nil, STR0015, 1, 0) //"Atenção" # "O Valor Final para considerar no Limiar deve ser igual ou superior ao Inicial."
		Return .F.
	EndIf
	// Verifica duplicidade de De/Até Valor
	For nX := 1 To Len(aLinhas)
		If nX <> nLinha .And. !aTail(aLinhas[nX])
			If ( aLinhas[nX][nPosLIMDE] >= nValLimDe .And. aLinhas[nX][nPosLIMDE] <= nValLimAte ) .Or. ;
				aLinhas[nX][nPosLIMATE] >= nValLimDe .And. aLinhas[nX][nPosLIMATE] <= nValLimAte
				Help(Nil, Nil, STR0013, Nil, STR0016, 1, 0) //"Atenção" # "O Valores dos Limiares estão em conflito de sobreposição. Por favor, definir valores distintos sem sobreposição."
				Return .F.
			EndIf
		EndIf
	Next nX

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT307BRW
Cadastro de Perguntas da Pesquisa de Satisfação

@return Nil

@sample
MNTA307()

@author Jackson Machado
@since 17/04/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Function MNT307BRW()
// Armazena variaveis p/ devolucao (NGRIGHTCLICK)
Local aNGBEGINPRM := NGBEGINPRM(,"MNTA307")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aRotina := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemtoAnsi(STR0017) //"Pesquisa de Satisfação"
PRIVATE aCHKDEL := {}, bNGGRAVA


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("TUO")
DbSetOrder(1)
mBrowse( 6, 1,22,75,"TUO")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve variaveis armazenadas (NGRIGHTCLICK)                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
NGRETURNPRM(aNGBEGINPRM)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de Menu Funcional

@return Nil

@sample
MenuDef()

@author Jackson Machado
@since 17/04/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := { { STR0006, "AxPesqui"     , 0 , 1},; //"Pesquisar"
                 { STR0007, "MNT307CAD"   , 0 , 2},; //"Visualizar"
                 { STR0008, "MNT307CAD"   , 0 , 3},; //"Incluir"
                 { STR0009, "MNT307CAD"   , 0 , 4},; //"Alterar"
                 { STR0010, "MNT307CAD"   , 0 , 5, 3},;  //"Excluir"
                 { STR0018, "MNT307CLI"   , 0 , 6} } // "Limiares"

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT307CAD
Função para visualização, inclusão, alteração e exclusão

@return Nil

@sample
MDTA55CAD('TUO',0,3)

@author Jackson Machado
@since 17/04/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Function MNT307CAD(cAlias, nRecno, nOpcx)
Local oGet
Local oDlgCad
Local nX
Local lAltProg := .T.
Local oFont12  := TFont():New("Arial",,-14,.T.,.T.)
Local nOpca    := 0
Local nPos
Local aColors  := NGCOLOR("10")
Local cTipo		:= ""
Local cPicture	:= ""
Local cTamanho	:= ""
Local cDecimal	:= ""
Local cUsado	:= ""
Local cF3		:= ""
Local cContext	:= ""
Local cValid	:= ""

//Objetos
Local oPnlPai
Local oPnlTop
Local oPnlGet
Local oPnlTGet
Local oPnlBLGet
Local oPnlGet01
Local oPnlBRGet
Local oPnlGet02
Local oEnc01
Local oSplitter

//Campos a serem considerados na GetDados
Local aCamp1 := { "TUP_CODGRU" , "TUP_NOMGRU" }
Local aCamp2 := { "TUP_PERGUN" , "TUP_TPLIST" , "TUP_ONMEMO" , "TUP_PERGUT", "TUP_2PERGU" }

//Enchoice
Private aSvATela := {}, aSvAGets := {}
Private aTela := {}
Private aGets := {}
Private aNao := {}
Private aTrocaF3 := {}

// Carregando variaveis - Grupo de Perguntas
Private aCGrup := {}
Private aTemp := {}
Private aHeadG := {}
Private oGetGru

// Carregando variaveis - Perguntas
Private aColsPr := {}
Private aGrupos := {}
Private aPergs  := {}
Private aHeadeP := {}
Private oGetPer

//Monta aHeader das perguntas
For nX := 1 To Len(aCamp1)
	cTipo		:= Posicione("SX3",2,aCamp1[nX],"X3_TIPO")
	cPicture	:= Posicione("SX3",2,aCamp1[nX],"X3_PICTURE")
	cTamanho	:= Posicione("SX3",2,aCamp1[nX],"X3_TAMANHO")
	cDecimal	:= Posicione("SX3",2,aCamp1[nX],"X3_DECIMAL")
	cUsado		:= Posicione("SX3",2,aCamp1[nX],"X3_USADO")
	cF3			:= Posicione("SX3",2,aCamp1[nX],"X3_F3")
	cContext	:= Posicione("SX3",2,aCamp1[nX],"X3_CONTEXT")
	Aadd(aHeadG,{ Trim(X3TITULO()),aCamp1[nX],cPicture,cTamanho,cDecimal,"MNT370DES()",cUsado,cTipo,cF3,cContext} )
Next nX

//Monta aHeader do grupo de perguntas
For nX := 1 To Len(aCamp2)
	cTipo		:= Posicione("SX3",2,aCamp2[nX],"X3_TIPO")
	cPicture	:= Posicione("SX3",2,aCamp2[nX],"X3_PICTURE")
	cTamanho	:= Posicione("SX3",2,aCamp2[nX],"X3_TAMANHO")
	cDecimal	:= Posicione("SX3",2,aCamp2[nX],"X3_DECIMAL")
	cValid		:= Posicione("SX3",2,aCamp2[nX],"X3_VALID")
	cUsado		:= Posicione("SX3",2,aCamp2[nX],"X3_USADO")
	cF3			:= Posicione("SX3",2,aCamp2[nX],"X3_F3")
	cContext	:= Posicione("SX3",2,aCamp2[nX],"X3_CONTEXT")
	Aadd(aHeadeP,{ Trim(X3TITULO()),aCamp2[nX],cPicture,cTamanho,cDecimal,cValid,cUsado,cTipo,cF3,cContext} )
Next nX

aColsPr := BLANKGETD(aHeadeP)
aColsPr[1,aScan(aCamp2,{|x| x == "TUP_TPLIST"})] := "1"
aColsPr[1,aScan(aCamp2,{|x| x == "TUP_ONMEMO"})] := "2"
aColsPr[1,Len(aColsPr[1])] := Space(6)
aAdd( aColsPr[1] , Space(1) )
aAdd( aColsPr[1] , Space(Len(TUP->TUP_VALORE)) )
aAdd( aColsPr[1] , .F. )


If nOpcx == 2 .or. nOpcx == 5
	aAdd(aTrocaF3,{"TUO_CODIGO",fRetTable(TUO->TUO_TIPO,4)})
	lAltProg := .f.
Endif

dbSelectArea("TUO")
RegToMemory("TUO",(nOpcx == 3))

If nOpcx == 5
	If !fValSatis()
		Return .F.
	EndIf
EndIf

If nOpcx <> 3
	dbSelectArea("TUP")
	dbSetOrder(1)
	dbSeek(xFilial("TUP")+M->TUO_TIPO+Padr(M->TUO_CODIGO,Len(TUO->TUO_CODIGO))+M->TUO_LOJA)
	While !Eof() .and. xFilial("TUP")+M->TUO_TIPO+PadR(M->TUO_CODIGO,Len(TUP->TUP_QUESTI))+M->TUO_LOJA == TUP->(TUP_FILIAL+TUP_TIPO+TUP_QUESTI+TUP_LOJA)
		If aScan( aCGrup, {|x| x[1] == TUP->TUP_CODGRU } ) == 0
			dbSelectArea("TUN")
			dbSetOrder(1)
			dbSeek(xFilial("TUN")+TUP->TUP_CODGRU)
			aAdd( aCGrup , { TUP->TUP_CODGRU , TUN->TUN_DESCRI , .F. } )
		Endif
		aAdd( aGrupos , { TUP->TUP_CODGRU , TUP->TUP_PERGUN , TUP->TUP_TPLIST , TUP->TUP_ONMEMO ,  ;
						  TUP->TUP_PERGUT + TUP->TUP_2PERGU , TUP->TUP_ORDEM  , TUP->TUP_QUESTA , TUP->TUP_VALORE, .F. } )
		dbSelectArea("TUP")
		dbSkip()
	End
EndIf
aSort( aGrupos ,,, { |x,y| x[__TUPORD__] < y[__TUPORD__] } )

If Len(aCGrup) == 0
	aCGrup := BLANKGETD(aHeadG)
Else
	cGrpTemp := aGrupos[1,__TUPGRU__]
	For nX := 1 To Len(aGrupos)
		If cGrpTemp == aGrupos[nX,__TUPGRU__]
			aAdd( aPergs , { aGrupos[nX,__TUPPER__] , aGrupos[nX,__TUPLIS__] , aGrupos[nX,__TUPMEM__] , SubStr(aGrupos[nX,__TUP2RE__],1,250) , ;
								SubStr(aGrupos[nX,__TUP2RE__],251) , aGrupos[nX,__TUPORD__] , aGrupos[nX,__TUPQUE__] , aGrupos[nX,__TUPVAL__] ,.F. } )
		Endif
		If(nPos := aScan(aCGrup,{|x| x[1] == aGrupos[nX,__TUPGRU__]})) > 0 .and. aScan(aTemp,{|x|  x[1] == aGrupos[nX,__TUPGRU__]}) == 0
			aAdd(aTemp,aCGrup[nPos])
		Endif
	Next nX
	If Len(aTemp) > 0
		aCGrup := aClone(aTemp)
	Endif
Endif
If Len(aPergs) == 0
	aPergs := aClone(aColsPr)
Endif

//aChoice recebe os campos que serao apresentados na tela
aNao    := {}
aChoice := NGCAMPNSX3("TUO",aNao)
aTela   := {}
aGets   := {}

//Tamanho da tela
Private aInfo, aPosObj
Private aSize := MsAdvSize(,.f.,430), aObjects := {}
Aadd(aObjects,{200,200,.t.,.f.})
aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
aPosObj := MsObjSize(aInfo, aObjects,.t.)

DEFINE MSDIALOG oDlgCad TITLE OemToAnsi(cCadastro) From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL

	oPnlPai := TPanel():New(00,00,,oDlgCad,,,,,,0,0,.F.,.F.)
		oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

		oSplitter := tSplitter():New(0,0,oPnlPai,100,100,1)
			oSplitter:Align := CONTROL_ALIGN_ALLCLIENT
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Enchoice tabela TUO                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPnlTop := TPanel():New(00,00,,oSplitter,,,,,,aSize[5],aSize[6],.F.,.F.)
			oPnlTop:Align := CONTROL_ALIGN_TOP
			oPnlTop:nHeight := 160
			oEnc01:= MsMGet():New("TUO",nRecno,nOpcx,,,,aChoice,{0,0,100,aPosObj[1,4]},,,,,,oPnlTop,,,.f.,"aSvATela")
				oEnc01:oBox:Align := CONTROL_ALIGN_ALLCLIENT
				aSvATela := aClone(aTela)
				aSvAGets := aClone(aGets)

				nTelaX := ( aSize[6]/2.02 ) - 108
				nTelaY := ( aSize[5]/2.01 ) - 26

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tela dos Grupos                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPnlGet := TPanel():New(00,00,,oSplitter,,,,,aColors[2],aSize[5],aSize[6],.F.,.F.)
			oPnlGet:Align := CONTROL_ALIGN_ALLCLIENT

			oPnlTGet := TPanel():New(00,00,,oPnlGet,,,,,aColors[2],aSize[5],aSize[6],.F.,.F.)
				oPnlTGet:Align := CONTROL_ALIGN_TOP
				oPnlTGet:nHeight := 30
				@ 05,012 SAY STR0019 OF oPnlTGet Pixel Color aColors[1] //"Selecione os grupos de perguntas"
				@ 05,185 SAY STR0020 OF oPnlTGet Pixel Color aColors[1] //"Selecione as perguntas do grupo:"
				@ 04,275 SAY oTextPerf Prompt aCGrup[1,2] PIXEL OF oPnlTGet Font oFont12 Color aColors[1]

			oPnlBLGet := TPanel():New(00,00,,oPnlGet,,,,,aColors[2],12,12,.F.,.F.)
				oPnlBLGet:Align := CONTROL_ALIGN_LEFT

				oBtUp01  := TBtnBmp():NewBar("PMSSETAUP","PMSSETAUP",,,,{|| fPrgNext(1,1) },,oPnlBLGet,,{|| (Inclui .or. Altera)},"",,,,,"")
					oBtUp01:cToolTip := STR0021 //"Altera a ordem do Grupo."
					oBtUp01:Align  := CONTROL_ALIGN_TOP

				oBtDw01  := TBtnBmp():NewBar("PMSSETADOWN","PMSSETADOWN",,,,{|| fPrgNext(1,2)},,oPnlBLGet,,{|| (Inclui .or. Altera)},"",,,,,"")
					oBtDw01:cToolTip := STR0021 //"Altera a ordem do Grupo."
					oBtDw01:Align  := CONTROL_ALIGN_TOP


			oPnlGet01 := TPanel():New(00,00,,oPnlGet,,,,,aColors[2],aSize[5]/8,aSize[6],.F.,.F.)
				oPnlGet01:Align := CONTROL_ALIGN_LEFT

				dbSelectArea("TUO")
				oGetGru   := MsNewGetDados():New(20,1,nTelaX,220,IIF(!lAltProg,0,GD_INSERT+GD_UPDATE+GD_DELETE),;
											{|| fLinOK_A(1) },{|| .T. },,,,9999,,,,oPnlGet01,aHeadG,aCGrup)
					oGetGru:oBrowse:Default()
					oGetGru:oBrowse:Refresh()
					oGetGru:oBrowse:bChange := {|| fChangeA() }
					oGetGru:oBrowse:bGotFocus := {|| fAltFocus(.T.,.F.) }
					oGetGru:oBrowse:bValid := {|| fAltFocus(.F.,) }
					oGetGru:oBrowse:Align  := CONTROL_ALIGN_ALLCLIENT

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tela das Questoes do Grupo                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oPnlBRGet := TPanel():New(00,00,,oPnlGet,,,,,aColors[2],12,12,.F.,.F.)
				oPnlBRGet:Align := CONTROL_ALIGN_LEFT

				oBtUp02  := TBtnBmp():NewBar("PMSSETAUP","PMSSETAUP",,,,{|| fPrgNext(2,1) },,oPnlBRGet,,{|| (Altera .and. !Empty(oGetGru:aCols[oGetGru:nAt,1])) },"",,,,,"")
					oBtUp02:cToolTip := STR0021 //"Altera a ordem do Grupo."
					oBtUp02:Align  := CONTROL_ALIGN_TOP

				oBtDw02  := TBtnBmp():NewBar("PMSSETADOWN","PMSSETADOWN",,,,{|| fPrgNext(2,2)},,oPnlBRGet,,{|| (Altera .and. !Empty(oGetGru:aCols[oGetGru:nAt,1])) },"",,,,,"")
					oBtDw02:cToolTip := STR0021 //"Altera a ordem do Grupo."
					oBtDw02:Align  := CONTROL_ALIGN_TOP

			oPnlGet02 := TPanel():New(00,00,,oPnlGet,,,,,aColors[2],aSize[5],aSize[6],.F.,.F.)
				oPnlGet02:Align := CONTROL_ALIGN_ALLCLIENT
				dbSelectArea("TUP")
				oGetPer := MsNewGetDados():New(20,250,nTelaX,nTelaY,IIF(!lAltProg,0,GD_INSERT+GD_UPDATE+GD_DELETE),;
										{|| fLinOK_B(1) },{|| fLinOK_B(2) },,,,9999,,,,oPnlGet02,aHeadeP,aPergs)
					oGetPer:oBrowse:Default()
					oGetPer:oBrowse:Refresh()
					oGetPer:oBrowse:bChange := {|| fChangeB() }
					oGetPer:oBrowse:bValid  := {|| fLinOK_B(3) }
					oGetPer:oBrowse:bGotFocus := {|| fAltFocus(.F.,.T.) }
			   		oGetPer:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	If nOpcx == 3
		oGetPer:oBrowse:Disable()
		oGetPer:oBrowse:Refresh()
	Endif

Activate MsDialog oDlgCad On Init EnchoiceBar(oDlgCad,{|| nOpca := 1,If(!MDT55OK(nOpcx),nOpca := 0,oDlgCad:End())},{|| oDlgCad:End()}) CENTERED

If nOpca == 1
	Begin Transaction
		fGrava(nOpcx)
	End Transaction
Endif

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT55OK
Validação da tela

@return Nil

@sample
MDT55OK(3)

@author Jackson Machado
@since 17/04/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function MDT55OK(nOpcx)
aCGrup := aClone(oGetGru:aCols)

If nOpcx != 2 .and. nOpcx != 5
	If !Obrigatorio(aSvAGets,aSvATela)
		Return .F.
	Endif
	If !ExistChav("TUO",M->TUO_TIPO+PADR(M->TUO_CODIGO,Len(TUO->TUO_CODIGO))+M->TUO_LOJA)
		Return .F.
	Endif
Else
	If !NGCHKDEL("TUO")
		Return .F.
	Endif
Endif

If !fLinOK_A(,.T.)
	Return .F.
Endif

If !fLinOK_B(,.T.)
	Return .F.
Endif

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fGrava
Funcao chamada para gravacao

@return Nil

@sample
fGrava(3)

@author Jackson Machado
@since 17/04/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fGrava(nOpcx)
Local x,y
Local ny,nx,nOrdTUO,cOrd
Local aTUPs := {}

If nOpcx == 3 .or. nOpcx == 4

	//Inclui ou altera o cadastro do Tipo de Ficha
	dbSelectArea("TUO")
	RecLock("TUO", (nOpcx==3) )
	If nOpcx == 3
		TUO->TUO_FILIAL := xFilial("TUO")
	Endif
	For ny := 1 To fCount()
		If "_FILIAL" $ Alltrim(FieldName(ny))
			Loop
		Endif
		x  := "M->" + FieldName(ny)
		y  := "TUO->" + FieldName(ny)
		&y := &x
	Next ny
	TUO->(MsUnLock())

	//Inclui ou altera o cadastro de itens do Tipo de Ficha
	nOrdTUO := 0
	For nx := 1 To Len(aCGrup)
		If aCGrup[nx,Len(aCGRUP[nX])]
			Loop
		Endif
		For ny := 1 To Len(aGrupos)
			If !aGrupos[ny,Len(aGrupos[ny])] .and. aCGrup[nx,1] == aGrupos[ny,__TUPGRU__] .and. !Empty(aGrupos[ny,__TUPPER__])
				nOrdTUO++ //Incrementa Ordem
				nUltTUO := Val(aGrupos[ny,__TUPORD__])
				If nUltTUO == 0
					nUltTUO := fUltQuest(TUO->TUO_TIPO+TUO->TUO_CODIGO+TUO_LOJA,1,"TUP->(TUP_FILIAL+TUP_TIPO+TUP_QUESTI+TUP_LOJA)")
				Endif
				dbSelectArea("TUP")
				dbSetOrder(1)
				If dbSeek( xFilial("TUP") + TUO->TUO_TIPO + TUO->TUO_CODIGO + TUO->TUO_LOJA + StrZero(nUltTUO,3) )
					RecLock("TUP",.F.)
				Else
					RecLock("TUP",.T.)
					TUP->TUP_FILIAL := xFilial("TUP")
					TUP->TUP_TIPO   := TUO->TUO_TIPO
					TUP->TUP_QUESTI := TUO->TUO_CODIGO
					TUP->TUP_LOJA   := TUO->TUO_LOJA
					TUP->TUP_QUESTA := StrZero(nUltTUO,3)
				Endif
				TUP->TUP_ORDEM  := StrZero(nOrdTUO,6)
				TUP->TUP_CODGRU := aGrupos[ny,__TUPGRU__]
				TUP->TUP_PERGUN := aGrupos[ny,__TUPPER__]
				TUP->TUP_TPLIST := aGrupos[ny,__TUPLIS__]
				TUP->TUP_ONMEMO := aGrupos[ny,__TUPMEM__]
				TUP->TUP_PERGUT := SubStr(aGrupos[ny,__TUP2RE__],1,250)
				TUP->TUP_2PERGU := SubStr(aGrupos[ny,__TUP2RE__],251)
				TUP->TUP_VALORE := aGrupos[ny,__TUPVAL__]
				TUP->(MsUnLock())
				aAdd(aTUPs , TUP->TUP_QUESTA )
			Endif
		Next ny
	Next nx

	dbSelectArea("TUP")
	dbSetOrder(1)
	If dbSeek( xFilial("TUP") + TUO->TUO_TIPO + TUO->TUO_CODIGO + TUO_LOJA)
			While !Eof() .and. xFilial("TUP") + M->TUO_TIPO + TUO->TUO_CODIGO + TUO->TUO_LOJA == TUP->(TUP_FILIAL+TUP_TIPO+TUP_QUESTI+TUP_LOJA)
			If aScan(aTUPs, {|x| x == TUP->TUP_QUESTA }) == 0
				dbSelectArea("TUP")
				RecLock("TUP",.F.)
				dbDelete()
				TUP->(MsUnLock())
			Endif
			dbSelectArea("TUP")
			dbSkip()
		End
	Endif

ElseIf nOpcx == 5

	dbSelectArea("TUP")
	dbSetOrder(1)
	dbSeek( xFilial("TUP") + TUO->TUO_TIPO + TUO->TUO_CODIGO + TUO_LOJA )
	While !Eof() .and. xFilial("TUP") + TUO->TUO_TIPO + TUO->TUO_CODIGO + TUO->TUO_LOJA == TUP->(TUP_FILIAL+TUP_TIPO+TUP_QUESTI+TUP_LOJA)
		dbSelectArea("TUP")
		RecLock("TUP",.F.)
		dbDelete()
		TUP->(MsUnLock())
		dbSelectArea("TUP")
		dbSkip()
	End

	dbSelectArea("TUO")
	RecLock("TUO", .F. )
	dbDelete()
	TUO->(MsUnLock())
Endif

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fUltQuest
Verifica a ultima questao do questionario

@return Nil

@sample
fUltQuest()

@author Jackson Machado
@since 17/04/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fUltQuest(cTUO_QUESTI,_nOrdTUP,_cCondTUP)
Local nRet := 1
Default _nOrdTUP := 1

dbSelectArea("TUP")
dbSetOrder(_nOrdTUP)
dbSeek( xFilial("TUP") + cTUO_QUESTI + "999999" , .T. )
If !Found()
   dbSkip(-1)
Endif
If !Eof() .and. !Bof() .and. &(_cCondTUP) == xFilial("TUP") + cTUO_QUESTI
	nRet := Val(TUP->TUP_QUESTA) + 1
Endif

Return nRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fChangeA
Funcao chamada ao mudar de linha

@return Nil

@sample
fChangeA()

@author Jackson Machado
@since 17/04/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fChangeA(cCodigo,cDescricao)
Local nX

Default cCodigo := ""
Default cDescricao := ""

If Empty(oGetGru:aCols[oGetGru:nAt,1]) .and. Empty(cCodigo)
	oGetPer:oBrowse:Disable()
	oBtUp02:Disable()
	oBtDw02:Disable()
Else
	oGetPer:oBrowse:Enable()
	oBtUp02:Enable()
	oBtDw02:Enable()
Endif
oBtUp02:Refresh()
oBtDw02:Refresh()
oGetPer:oBrowse:Refresh()

cGrpTemp := If(Empty(cCodigo),oGetGru:aCols[oGetGru:nAt,1],cCodigo)
oGetPer:aCols := {}
For nX := 1 To Len(aGrupos)
	If !aGrupos[nX,Len(aGrupos[nX])]
		If cGrpTemp == aGrupos[nX,1]
			aAdd( oGetPer:aCols , { aGrupos[nX,__TUPPER__ ] , aGrupos[nX,__TUPLIS__ ] , aGrupos[nX,__TUPMEM__] , SubStr(aGrupos[nX,__TUP2RE__],1,250) , SubStr(aGrupos[nX,__TUP2RE__],251) , aGrupos[nX,__TUPORD__] , aGrupos[nX,__TUPQUE__], aGrupos[nX,__TUPVAL__], .F. } )
		Endif
	Endif
Next nX
If Len(oGetPer:aCols) == 0
	oGetPer:aCols := aClone(aColsPr)
Endif

oTextPerf:SetText(If(Empty(cDescricao),oGetGru:aCols[oGetGru:nAt,2],cDescricao)) //Atualiza texto

aPergs := aClone(oGetPer:aCols)
oGetPer:nAt := 1
oGetPer:lNewLine := .F.
oGetPer:oBrowse:Refresh()

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fChangeB
Funcao chamada ao mudar de linha
(P.O.G. - Necessário pois ao incluir uma nova linha no aCols, esta é montada sobre o aHeader,
como são utilizados campos ocultos esses não são iniciados)

@return Nil

@sample
fChangeB()

@author Jackson Machado
@since 17/04/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fChangeB()
Local lTemp

If Len(oGetPer:aCols[oGetPer:nAt]) < __LENCOL__
	lTemp := oGetPer:aCols[oGetPer:nAt,Len(oGetPer:aCols[oGetPer:nAt])]
	oGetPer:aCols[oGetPer:nAt,Len(oGetPer:aCols[oGetPer:nAt])] := Space(6)
	aAdd( oGetPer:aCols[oGetPer:nAt] , Space(1) )
	aAdd( oGetPer:aCols[oGetPer:nAt] , Space(Len(TUP->TUP_VALORE)) )
	aAdd( oGetPer:aCols[oGetPer:nAt] , lTemp )
Endif

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fLinOK_A
Valida linha dos itens do grupo

@return Nil

@sample
fLinOK_A(1)

@author Jackson Machado
@since 17/04/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fLinOK_A(nTipo,lFim)
Local nX
Local nPosGrp := aScan(aHeadG,{|x| AllTrim(Upper(X[2])) == "TUP_CODGRU"})
Local nAt     := oGetGru:nAt
Local cGrupo  := oGetGru:aCols[nAt,nPosGrp]
Local lMsgDel := .T.


Default lFim := .F.

For nX := 1 To Len(oGetGru:aCols)
	If (lFim .or. nX == nAt) .AND. Empty(oGetGru:aCols[nX][nPosGrp]) .and. !oGetGru:aCols[nX,Len(oGetGru:aCols[nX])]
		Help(1," ","OBRIGAT2",,aHeadG[nPosGrp][1],3,0)
		Return .F.
	Endif
	If nAt <> nX
		If cGrupo == oGetGru:aCols[nX,nPosGrp] .and. !oGetGru:aCols[nX,Len(oGetGru:aCols[nX])]
			Help(" ",1,"JAEXISTINF",,aHeadG[nPosGrp][1])
			Return .F.
		Endif
	Endif
	If lMsgDel .And. !aTail(oGetGru:aCols[nX])
		lMsgDel := .F.
	EndIf

Next nX

If lFim .And. lMsgDel
	Help(1," ","OBRIGAT2",,aHeadG[nPosGrp][1],3,0)
	Return .F.
EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fLinOK_B
Valida linha dos itens do grupo

@return Nil

@sample
fLinOK_B(1)

@author Jackson Machado
@since 17/04/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fLinOK_B(nTipoC,lFim)
Local nX
Local nP1 := aScan(aHeadeP,{|x| AllTrim(Upper(X[2])) == "TUP_ONMEMO"})
Local nP2 := aScan(aHeadeP,{|x| AllTrim(Upper(X[2])) == "TUP_PERGUT"})
Local nP3 := aScan(aHeadeP,{|x| AllTrim(Upper(X[2])) == "TUP_PERGUN"})
Local nP4 := aScan(aHeadeP,{|x| AllTrim(Upper(X[2])) == "TUP_TPLIST"})
Local nP5 := aScan(aHeadeP,{|x| AllTrim(Upper(X[2])) == "TUP_2PERGU"})
Local lMsgDel := .T.

Default lFim := .F.

If !Empty(oGetPer:aCols[oGetPer:nAt,__TUPGRU__]) .or. !Empty(oGetPer:aCols[oGetPer:nAt,nP2])
	If oGetPer:aCols[oGetPer:nAt,nP1] != "1" .And. Empty(oGetPer:aCols[oGetPer:nAt,nP2])
		MsgInfo(STR0022) //"É obrigatório informar a Lista de Opções ou Campo Obs."
		Return .F.
	Endif
Endif

cGrpTemp := oGetGru:aCols[oGetGru:nAt,1]
For nX := 1 To Len(aGrupos)
	If cGrpTemp == aGrupos[nX,__TUPGRU__]
		aGrupos[nX,Len(aGrupos[nX])] := .T.
	Endif
Next nX

For nX := 1 To Len(oGetPer:aCols)
	If !oGetPer:aCols[nX,Len(oGetPer:aCols[nX])]
		aAdd( aGrupos , { cGrpTemp , oGetPer:aCols[nX,nP3] , oGetPer:aCols[nX,nP4] , oGetPer:aCols[nX,nP1] ,  ;
		  oGetPer:aCols[nX,nP2]+oGetPer:aCols[nX,nP5] , oGetPer:aCols[nX,__TUPORD__]  , oGetPer:aCols[nX,__TUPQUE__] , oGetPer:aCols[nX,__TUPVAL__] , .F. } )
	Endif
Next nX

aPergs := aClone(oGetPer:aCols)

If lFim
	For nX := 1 To Len(oGetPer:aCols)
		If Empty(oGetPer:aCols[nX,nP3])
        	Help(1," ","OBRIGAT2",,aHeadeP[nP3][1],3,0)
			Return .F.
		Elseif oGetPer:aCols[nX,nP1] != "1" .And. Empty(oGetPer:aCols[nX,nP2])
			MsgInfo(STR0022) //"É obrigatório informar a Lista de Opções ou Campo Obs."
			Return .F.
		Endif
		If lMsgDel .And. !aTail(oGetPer:aCols[nX])
			lMsgDel := .F.
		EndIf

	Next nX
Endif

If lFim .And. lMsgDel
	Help(1," ","OBRIGAT2",,aHeadeP[nP3][1],3,0)
	Return .F.
EndIf

If nTipoC == 3 .and. !lFim
	fAltFocus(,.F.) //Habilita / Desabilita botões
Endif

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fAltFocus
Habilita / Desabilita botões

@return Nil

@sample
fAltFocus(.T.,.T.)

@author Jackson Machado
@since 17/04/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fAltFocus(lBrw1,lBrw2)

If ValType(lBrw1) == "L"
	If lBrw1
		oBtUp01:Enable()
		oBtDw01:Enable()
	Else
		oBtUp01:Disable()
		oBtDw01:Disable()
	Endif
	oBtUp01:Refresh()
	oBtDw01:Refresh()
Endif
If ValType(lBrw2) == "L"
	If lBrw2 .and. !Empty(oGetPer:aCols[oGetPer:nAt,__TUPGRU__])
		oBtUp02:Enable()
		oBtDw02:Enable()
	Else
		oBtUp02:Disable()
		oBtDw02:Disable()
	Endif
	oBtUp02:Refresh()
	oBtUp02:Refresh()
Endif

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fPrgNext
Altera a posição das linhas na GetDados

@return Nil

@sample
fPrgNext(1,1)

@author Jackson Machado
@since 17/04/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fPrgNext(nTipoGet,nTipoBtn)
Local aTmp
Local nPos := 0

//GetDados - Grupo
If nTipoGet == 1 .and. Len(oGetGru:aCols) > 1
	If !Empty(oGetGru:aCols[oGetGru:nAt,1])
		If nTipoBtn == 1
			If oGetGru:nAt > 1
				aTmp := aClone(oGetGru:aCols[oGetGru:nAt-1])
				oGetGru:aCols[oGetGru:nAt-1] := aClone(oGetGru:aCols[oGetGru:nAt])
				oGetGru:aCols[oGetGru:nAt]   := aClone(aTmp)
				nPos := oGetGru:nAt - 1
			Endif
		Else
			If oGetGru:nAt < Len(oGetGru:aCols)
				aTmp := aClone(oGetGru:aCols[oGetGru:nAt+1])
				oGetGru:aCols[oGetGru:nAt+1] := aClone(oGetGru:aCols[oGetGru:nAt])
				oGetGru:aCols[oGetGru:nAt]   := aClone(aTmp)
				nPos := oGetGru:nAt + 1
			Endif
		Endif
		If nPos > 0
			oGetGru:nAt := nPos
			oGetGru:oBrowse:nAt := nPos
			oGetGru:oBrowse:nRowPos := nPos
		Endif
	Endif
	oGetGru:oBrowse:Refresh()

ElseIf nTipoGet == 2 .and. Len(oGetPer:aCols) > 1
//GetDados - Questoes
	If nTipoBtn == 1
		If oGetPer:nAt > 1
			aTmp := aClone(oGetPer:aCols[oGetPer:nAt-1])
			oGetPer:aCols[oGetPer:nAt-1] := aClone(oGetPer:aCols[oGetPer:nAt])
			oGetPer:aCols[oGetPer:nAt]   := aClone(aTmp)
			nPos := oGetPer:nAt - 1
		Endif
	Else
		If oGetPer:nAt < Len(oGetPer:aCols)
			aTmp := aClone(oGetPer:aCols[oGetPer:nAt+1])
			oGetPer:aCols[oGetPer:nAt+1] := aClone(oGetPer:aCols[oGetPer:nAt])
			oGetPer:aCols[oGetPer:nAt]   := aClone(aTmp)
			nPos := oGetPer:nAt + 1
		Endif
	Endif
	If nPos > 0
		oGetPer:nAt := nPos
		oGetPer:oBrowse:nAt := nPos
		oGetPer:oBrowse:nRowPos := nPos
	Endif
	oGetPer:oBrowse:Refresh()

Endif

Return .t.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT370DES
Dispara um gatilho para preencher a descricao do grupo de perguntas.

@return Nil

@sample
MNT370DES()

@author Jackson Machado
@since 17/04/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Function MNT370DES()

If !Empty(M->TUP_CODGRU)
	If !ExistCpo("TUN",M->TUP_CODGRU)
		Return .F.
	EndIf
Else
	HELP(" ",1,"NVAZIO")
	Return .F.
EndIf

dbSelectArea("TUN")
dbSetOrder(1)
If dbSeek(xFilial("TUN")+M->TUP_CODGRU)
	oGetGru:aCols[oGetGru:nAt,2] := TUN->TUN_DESCRI
EndIf

oGetGru:oBrowse:Refresh()

fChangeA(M->TUP_CODGRU,TUN->TUN_DESCRI)
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT307BOX
Retorna combobox de campo

@return Nil

@sample
MNT307BOX("TUO_TIPO")

@author Jackson Machado
@since 17/04/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Function MNT307BOX(cVar)

Local cCombo := ""

Default cVar := ""

If cVar == "TUO_TIPO"
	cCombo := STR0023 //"1=Família;2=Tipo Modelo;3=Bem;4=Localização;5=Tipo Serviço;6=Atendente;7=Terceiros;8=Centro Custo;9=Centro Trabalho;A=Geral"
ElseIf cVar == "TUP_TPLIST"
	cCombo := STR0024 //"1=Opção Exclusiva;2=Várias Opções"
Elseif cVar == "TUP_ONMEMO" .or. cVar == "TUO_DESABI"
	cCombo := STR0025 //"1=Sim;2=Não"
Endif

Return cCombo
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT307REL
Retorna descrição de campo

@return Nil

@sample
MNT307REL("TUO_DESCRI")

@author Jackson Machado
@since 17/04/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Function MNT307REL(cVar,lIniBrw)
Local cDesc  := ""
Local cChave := ""
Local cTable := ""
Local cOpc   := ""
Local cCampo := ""
Local nTam   := 0

Default cVar := ""
Default lIniBrw := .F.

If cVar == "TUO_DESCRI"
	If !lIniBrw
		cOpc   := M->TUO_TIPO
	Else
		cOpc   := TUO->TUO_TIPO
	Endif
	cTable := fRetTable(cOpc)
	cCampo := fRetTable(cOpc,2)
	nTam   := fRetTable(cOpc,3)
	If !Empty(cTable)
		If !lIniBrw
			If cOpc == "7"
				cChave := SubStr(M->TUO_CODIGO,1,nTam)+M->TUO_LOJA
			Else
				cChave := SubStr(M->TUO_CODIGO,1,nTam)
			Endif
		Else
			If cOpc == "7"
				cChave := SubStr(TUO->TUO_CODIGO,1,nTam)+TUO->TUO_LOJA
			Else
				cChave := SubStr(TUO->TUO_CODIGO,1,nTam)
			Endif
		Endif
		cDesc  := NGSEEK(cTable,cChave,1,cCampo)
	Else
		cDesc  := "GERAL"
	Endif
ElseIf cVar == "TUP_NOMQUE"
	If !lIniBrw
		cChave := M->TUO_TIPO+M->TUO_CODIGO
	Else
		cChave := TUO->TUO_TIPO+TUO->TUO_CODIGO
	Endif
	cDesc  := NGSEEK("TUO",cChave,1,"TUO_DESCRI")
ElseIf cVar == "TUP_NOMGRU"
	If !lIniBrw
		cChave := M->TUP_CODGRU
	Else
		cChave := TUP->TUP_CODGRU
	Endif
	cDesc  := NGSEEK("TUN",cChave,1,"TUN_DESCRI")
ElseIf cVar == "TUY_DESLIM"
	If !lIniBrw
		If Type("M->TUY_LIMIAR") == "C"
			cDesc := If(INCLUI, xRetorno, Posicione("TUW", 1, xFilial("TUW") + M->TUY_LIMIAR, "TUW_DESCRI"))
		EndIf
	Else
		cDesc := Posicione("TUW", 1, xFilial("TUW") + TUY->TUY_LIMIAR, "TUW_DESCRI")
	EndIf
Endif

Return cDesc
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT307GAT
Gatilho dos campos.

@author Wagner Sobral de Lacerda
@since 26/11/2012
@version MP10/MP11
@return uGatilho
/*/
//---------------------------------------------------------------------
Function MNT307GAT(cDominio, cContra)

	Local uGatilho

	If cDominio == "TUY_LIMIAR" .And. cContra == "TUY_DESLIM"
		uGatilho := Posicione("TUW", 1, xFilial("TUW") + M->TUY_LIMIAR, "TUW_DESCRI")
	EndIf

Return uGatilho
//---------------------------------------------------------------------
/*/{Protheus.doc} fRetTable
Retorna tabela selecionada

@return Nil

@sample
fRetTable("1")

@author Jackson Machado
@since 17/04/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fRetTable(cOpcao,nTipo)
Local cRet   := ""
Default cOpcao := ""
Default nTipo  := 1

If nTipo == 1 .Or. nTipo == 4 // 1 - Tabela / 4 - F3
	If cOpcao == "1"
		cRet := "ST6"
	Elseif cOpcao == "2"
		cRet := "TQR"
	Elseif cOpcao == "3"
		cRet := "ST9"
	Elseif cOpcao == "4"
		cRet := "TAF"
	Elseif cOpcao == "5"
		cRet := "TQ3"
	Elseif cOpcao == "6"
		cRet := If(nTipo == 1, "ST1", "ST1FAC")
	Elseif cOpcao == "7"
		cRet := "SA2"
	Elseif cOpcao == "8"
		cRet := "CTT"
	Elseif cOpcao == "9"
		cRet := "SHB"
	Endif
ElseIf nTipo == 2
	If cOpcao == "1"
		cRet := "T6_NOME"
	Elseif cOpcao == "2"
		cRet := "TQR_DESMOD"
	Elseif cOpcao == "3"
		cRet := "T9_NOME"
	Elseif cOpcao == "4"
		cRet := "TAF_NOMNIV"
	Elseif cOpcao == "5"
		cRet := "TQ3_NMSERV"
	Elseif cOpcao == "6"
		cRet := "T1_NOME"
	Elseif cOpcao == "7"
		cRet := "A2_NOME"
	Elseif cOpcao == "8"
		cRet := "CTT_DESC01"
	Elseif cOpcao == "9"
		cRet := "HB_NOME"
	Endif
Else
	If cOpcao == "1"
		cRet := TAMSX3("T6_CODFAMI")[1]
	Elseif cOpcao == "2"
		cRet := TAMSX3("TQR_TIPMOD")[1]
	Elseif cOpcao == "3"
		cRet := TAMSX3("T9_CODBEM")[1]
	Elseif cOpcao == "4"
		cRet := TAMSX3("TAF_CODNIV")[1]
	Elseif cOpcao == "5"
		cRet := TAMSX3("TQ3_CDSERV")[1]
	Elseif cOpcao == "6"
		cRet := TAMSX3("T1_CODFUNC")[1]
	Elseif cOpcao == "7"
		cRet := TAMSX3("A2_COD")[1]
	Elseif cOpcao == "8"
		cRet := TAMSX3("CTT_CUSTO")[1]
	Elseif cOpcao == "9"
		cRet := TAMSX3("HB_COD")[1]
	Else
		cRet := 1
	Endif
Endif
Return cRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT307WHEN
Retorna when de campo

@return Nil

@sample
MNT307WHEN('TUO_TIPO')

@author Jackson Machado
@since 17/04/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Function MNT307WHEN(cVar)
Local lRet := .T.
Local nXX
Local nPosRes  := aScan(aHeadeP, {|x| AllTrim(Upper(X[2])) == "TUP_PERGUT" })
Local nPos2Re  := aScan(aHeadeP, {|x| AllTrim(Upper(X[2])) == "TUP_2PERGU" })
Local oDlgWhen
Local oChecked := LoadBitmap(GetResources(),"LBTIK")
Local oUnCheck := LoadBitmap(GetResources(),"LBNO")
Local aCodBox  := {	"1","2","3","4","5","6","7","8","9",;
					"A","B","C","D","E","F","G","H","I",;
					"J","K","L","M","N","O","P","Q","R",;
					"S","T","U","V","W","X","Y","Z" }

Private oBoxPerg, aBoxPerg, bBoxPerg

If cVar == "TUO_TIPO"
 	aTrocaF3 := {}
 	aAdd(aTrocaF3,{"TUO_CODIGO",fRetTable(M->TUO_TIPO,4)})
Elseif cVar == "TUO_CODIGO"
	If M->TUO_TIPO == "A" .or.	Empty(M->TUO_TIPO)
		Return .F.
	Endif
Elseif cVar == "TUO_DESABI"
	If M->TUO_DESABI == "1"
		oGetPer:oBrowse:Disable()
		oGetGru:oBrowse:Disable()
		oGetPer:oBrowse:Refresh()
		oGetGru:oBrowse:Refresh()
	Else
		oGetGru:oBrowse:Enable()
		oGetGru:oBrowse:Refresh()
		If !Empty(oGetPer:aCols[oGetPer:nAt,1])
			oGetPer:oBrowse:Enable()
			oGetPer:oBrowse:Refresh()
		Endif
	Endif
Elseif cVar == "TUP_PERGUT"	.or. cVar == "TUP_2PERGU"
	M->TUP_PERGUT := oGetPer:aCols[oGetPer:nAt,nPosRes]+oGetPer:aCols[oGetPer:nAt,nPos2Re]
	M->TUP_VALORE := oGetPer:aCols[oGetPer:nAt,__TUPVAL__]
	aBoxPerg := {}

	For nXX := 1 To Len(aCodBox)
		nPos3 := 0
		nPos  := At( aCodBox[nXX]+"=" , M->TUP_PERGUT )
		nPos2 := At( aCodBox[nXX]+"=" , M->TUP_VALORE )
		If nPos > 0
			nPos1 := At( ";" , Substr( M->TUP_PERGUT , nPos+2 ) )
			cDesc := Alltrim(Substr( M->TUP_PERGUT , nPos+2 ))
			cVal := "0"
			If nPos2 > 0
				nPos3 := At( ";" , Substr( M->TUP_VALORE , nPos2+2 ) )
				cVal  := Alltrim(Substr( M->TUP_VALORE , nPos2+2 ))
			Endif
			If nPos1 > 0
				cDesc := Alltrim(Substr( M->TUP_PERGUT , nPos+2 , nPos1-1 ))
			Endif
			If nPos3 > 0
				cVal  := Alltrim(Substr( M->TUP_VALORE , nPos2+2 , nPos3-1 ))
			Endif
			aAdd( aBoxPerg , { .T. , aCodBox[nXX] , PadR(cDesc,30), cVal } )
		Else
			aAdd( aBoxPerg , { .F. , aCodBox[nXX] , Space(30), Space(4) } )

		Endif
	Next nXX

	DEFINE MSDIALOG oDlgWhen TITLE OemToAnsi(STR0026) from 10,15 To 30,70 COLOR CLR_BLACK,CLR_WHITE of oMainwnd //"Editar Lista de Opções"

		@ 05,9  SAY STR0027 OF oDlgWhen Pixel //"Configure a lista de opções:"
		oBoxPerg := VCBrowse():New( 17 , 010, 200, 110,,{" ",STR0028,STR0029,STR0030},{10,20,130,25},; //"Opção" # "Descrição" # "Valor"
									oDlgWhen,,,,,{||},,,,,,,.F.,,.T.,,.F.,,.t.,.t.)
		oBoxPerg:SetArray(aBoxPerg)
		bBoxPerg := { || { If(aBoxPerg[oBoxPerg:nAt,1],oChecked,oUnCheck), aBoxPerg[oBoxPerg:nAt,2], aBoxPerg[oBoxPerg:nAt,3], aBoxPerg[oBoxPerg:nAt,4] } }
		oBoxPerg:bLine:= bBoxPerg
		oBoxPerg:bLDblClick := {|| fMarkOpca(oBoxPerg:nColPos) }

		DEFINE SBUTTON FROM 135,155 TYPE 1 ENABLE OF oDlgWhen ACTION ( If( fValWhen(), oDlgWhen:End() , .F.))
		DEFINE SBUTTON FROM 135,185 TYPE 2 ENABLE OF oDlgWhen ACTION oDlgWhen:END()

	ACTIVATE MSDIALOG oDlgWhen CENTERED
Endif

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT307VAL
Retorna validação de campo
@return Nil

@sample
MNT307VAL('TUO_TIPO')

@author Jackson Machado
@since 17/04/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Function MNT307VAL(cVar)
Local lRet := .T.
Local xx := 0, nPos
Local nX, nTam := 0
Local cKey := ""

If cVar == "TUO_TIPO"
	If Pertence("123456789A")
		If M->TUO_TIPO == "A"
			M->TUO_CODIGO := Replicate("0",Len(TUO->TUO_CODIGO)-1)+"1"
			M->TUO_DESCRI := "GERAL"
		Else
			M->TUO_CODIGO := Space(fRetTable(M->TUO_TIPO,3))
			M->TUO_DESCRI := Space(TAMSX3("TUO_DESCRI")[1])
		Endif
		M->TUO_LOJA := Space(TAMSX3("TUO_DESCRI")[1])
	Else
		lRet := .F.
	Endif
Elseif cVar == "TUO_CODIGO"
	nTam := fRetTable(M->TUO_TIPO,3)
	If M->TUO_TIPO == "7"
		If Empty(SA2->A2_LOJA)
			dbSelectArea("SA2")
			dbSetOrder(1)
			dbSeek(xFilial("SA2")+SubStr(M->TUO_CODIGO,1,nTam))
		Endif
		M->TUO_LOJA := SA2->A2_LOJA
		cKey := "SubStr(M->TUO_CODIGO,1,"+cValToChar(nTam)+")+M->TUO_LOJA"
	Else
		cKey := "SubStr(M->TUO_CODIGO,1,"+cValToChar(nTam)+")"
	Endif
	If !Empty(M->TUO_CODIGO) .AND. !ExistCPO(fRetTable(M->TUO_TIPO),&(cKey))
		lRet := .F.
	Endif
	If lRet .And. M->TUO_TIPO == "6" // 6=Atendente
		dbSelectArea("ST1")
		dbSetOrder(1)
		If !( dbSeek(xFilial("ST1") + &(cKey)) .And. ST1->T1_TIPATE $ "2/3" )
			Help(Nil, Nil, STR0013, Nil, STR0031 + " " + AllTrim(M->TUO_CODIGO) +  " " + STR0032, 1, 0) //"Atenção" # "O Funcinário" # "não é um atendente de Facilities, portanto é inválido."
			lRet := .F.
		EndIf
	EndIf
	If lRet
		M->TUO_DESCRI := NGSEEK(fRetTable(M->TUO_TIPO),&(cKey),1,fRetTable(M->TUO_TIPO,2))
	Endif
Elseif cVar == "TUP_QUESTI"
	If !ExistCPO("TUO",M->TUP_TIPO+M->TUP_CODIGO+M->TUP_LOJA)
		lRet := .F.
	Endif
Elseif cVar == "TUP_QUESTA"
	nPOS := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TUP_QUESTA"})

	If nPOS > 0
		For nX := 1 to Len(aCOLS)
			If n <> nX
				If aCOLS[nX][nPOS] == M->TUP_QUESTA
					xx++
					Exit
				Endif
			Endif
		Next
	Endif

	If xx > 0
	   Help(" ",1,"JAEXISTINF")
	   lRet := .f.
	Endif
Elseif cVar == "TUP_CODGRU"
	If !ExistCPO("TUN",M->TUP_CODGRU)
		lRet := .F.
	Endif
Elseif cVar == "TUP_TPLIST"
	If !Pertence("123")
		lRet := .F.
	Endif
Elseif cVar == "TUP_ONMEMO" .or. cVar ==  "TUO_DESABI"
	If !Pertence("12")
		lRet := .F.
	Endif
Elseif cVar == "TUQ_QUESTI"
	If !ExistCPO("TUO",M->TUQ_TIPO+M->TUQ_CODIGO+M->TUQ_LOJA)
		lRet := .F.
	Endif
ElseIf cVar == "TUW_CODIGO"
	lRet := NaoVazio() .And. ExistChav("TUW", M->TUW_CODIGO, 1)
ElseIf cVar == "TUY_LIMIAR"
	lRet := NaoVazio() .And. ExistCpo("TUW", M->TUY_LIMIAR, 1) .And. ExistChav("TUY", M->TUO_CODIGO + M->TUY_LIMIAR, 1)
ElseIf cVar == "TUY_LIMDE"
	If M->TUY_LIMDE < 0 ; Help(Nil, Nil, STR0013, Nil, STR0033, 1, 0) ; lRet := .F. ; EndIf //"Atenção" #  "Valor do Limiar não pode ser Negativo."
ElseIf cVar == "TUY_LIMATE"
	If M->TUY_LIMATE < 0 ; Help(Nil, Nil, STR0013, Nil, STR0033, 1, 0) ; lRet := .F. ; EndIf //"Atenção" # "Valor do Limiar não pode ser Negativo."
Endif

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fMarkOpca
Funcao para marcar ou desmarcar as opções
@return Nil

@sample
fMarkOpca()

@author Jackson Machado
@since 17/04/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fMarkOpca()
Local nAntes3
Local nAntes1
Local lRet := .T.
If !aBoxPerg[oBoxPerg:nAt][1]
	nAntes3 := aBoxPerg[oBoxPerg:nAt][3]
	lEditCell(@aBoxPerg,oBoxPerg,"",3)
	If !Empty(aBoxPerg[oBoxPerg:nAt][3])
		If "=" $ aBoxPerg[oBoxPerg:nAt][3] .or. ";" $ aBoxPerg[oBoxPerg:nAt][3]
			lRet := .F.
			aBoxPerg[oBoxPerg:nAt][3] := nAntes3
			MsgInfo(STR0034) //"Os seguintes caracteres não poderão ser utilizados: = (sinal de igualdade) ou ; (ponto e virgula)"
			Return
		Endif
		lRet := .T.
		//Se o parametro for informado corretamente, a listbox é atualizada
		aBoxPerg[oBoxPerg:nAt][1] := .t.
		aBoxPerg[oBoxPerg:nAt][3] := PadR(aBoxPerg[oBoxPerg:nAt][3],30)
		oBoxPerg:REFRESH()
	Else
		lRet := .F.
		aBoxPerg[oBoxPerg:nAt][1] := .f.
		aBoxPerg[oBoxPerg:nAt][3] := Space(30)
		oBoxPerg:REFRESH()
	Endif
	If lRet
		nAntes1 := aBoxPerg[oBoxPerg:nAt][4]
		lEditCell(@aBoxPerg,oBoxPerg,"",4)
		If !Empty(aBoxPerg[oBoxPerg:nAt][4])
			If Val(aBoxPerg[oBoxPerg:nAt][4]) > 1000 .or. Val(aBoxPerg[oBoxPerg:nAt][4]) < 0
				aBoxPerg[oBoxPerg:nAt][1] := .f.
				aBoxPerg[oBoxPerg:nAt][3] := nAntes3
				aBoxPerg[oBoxPerg:nAt][4] := nAntes1
				MsgInfo(STR0035) //"São admitidos apenas valores de 0 a 1000."
				Return
			Endif
			aBoxPerg[oBoxPerg:nAt][4] := aBoxPerg[oBoxPerg:nAt][4]
			oBoxPerg:REFRESH()
		Else
			aBoxPerg[oBoxPerg:nAt][4] := Space(2)
			oBoxPerg:REFRESH()
		Endif
	Endif
Else
	//Caso o usuario desmarque o checkbox
	aBoxPerg[oBoxPerg:nAt][1] := .f.
	aBoxPerg[oBoxPerg:nAt][3] := Space(30)
	aBoxPerg[oBoxPerg:nAt][4] := Space(4)
	oBoxPerg:REFRESH()
Endif

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fValWhen
Valida a tela
@return Nil

@sample
fValWhen()

@author Jackson Machado
@since 17/04/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fValWhen()
Local nXX
Local nPosRes  := aScan(aHeader, {|x| AllTrim(Upper(X[2])) == "TUP_PERGUT" })
Local nPos2Re  := aScan(aHeader, {|x| AllTrim(Upper(X[2])) == "TUP_2PERGU" })

M->TUP_PERGUT := ""
M->TUP_VALORE := ""
For nXX := 1 To Len(aBoxPerg)
	If aBoxPerg[nXX,1] .and. !Empty(aBoxPerg[nXX,3])
		If !Empty(M->TUP_PERGUT)
			M->TUP_PERGUT += ";"
		Endif
		M->TUP_PERGUT += aBoxPerg[nXX,2] + "=" + Alltrim(Substr(aBoxPerg[nXX,3],1,30))
		If !Empty(M->TUP_VALORE)
			M->TUP_VALORE += ";"
		Endif
		M->TUP_VALORE += aBoxPerg[nXX,2] + "=" + AllTrim(aBoxPerg[nXX,4])
	Endif
Next nXX

If Len(M->TUP_PERGUT) > 500
	MsgInfo(STR0036) //"A quantidade de caracteres no campo Editar Opc. ultrapassou 500."
	Return .f.
ElseIf Empty(M->TUP_PERGUT)
	M->TUP_PERGUT := STR0037 //"1=Sim;2=Não;3=Sem Resposta"
	M->TUP_VALORE := "1=1;2=2;3=0"
	MsgInfo(STR0038) //"Nenhum item foi selecionado, portanto, serão consideradas as opções padrão (Sim, Não e Sem Resposta)."
Endif

aCols[n,nPosRes] := PadR(SubStr(M->TUP_PERGUT,1,250),250)
aCols[n,nPos2Re] := PadR(SubStr(M->TUP_PERGUT,251),250)
aCols[n,__TUPVAL__] := M->TUP_VALORE

Return .t.
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT307QUE()
Retorna o questionario para resposta
@return Nil

@sample
MNT307QUE(3)

@author Jackson Machado
@since 17/04/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Function MNT307QUE(lVisual,cCodSS,lWF)
Local nYY,nXX
Local aAreaTQB
Local nLinObj, nAcumLi, nLimCol, nPosOld, nOldLinObj
Local cOldGrupo, cDesGrupo, cStrYY
Local oDlgInd, oPanelTmp, oGrpNome, oResp
Local nOpca           := 0
Local cContVar        := AllTrim(GetMv("MV_NGPESST")) // Manter o GetMV já que este comando pega o valor sempre atualizado. Ver Task #14852
Local aAreaTmp        := GetArea()
Local aQuest          := {}
Local aOldRot         := If(Type("aRotina") == "A",aClone(aRotina),{})
Local oFont12         := TFont():New("Arial",,-12,.T.,.T.)
Local oFont16         := TFont():New("Arial",,-16,.T.,.T.)
Private oScroll
Private aQuestionario := {}
Private aSize         := MsAdvSize(,.f.,430)
Private aObjects      := {}

Default cCodSS  := TQB->TQB_SOLICI
Default lVisual := .F.
Default lWF     := .F.

If Empty(cContVar)
	If lWF .or. MsgYesNo(STR0039) //"Não foi definido um nível de importância para os questionários, deseja definir ou utilizar o padrao?"
		cContVar := "1/2/3/4/5/6/7/8/9/A"
	Else
		cContVar := fConfig(.T.)
	EndIf
EndIf

dbSelectArea("TQB")
dbSetOrder(1)
dbSeek(xFilial("TQB")+cCodSS)

If !lWF
	If lVisual
		If Empty(TQB->TQB_SEQQUE) .or. TQB->TQB_SATISF != "1"
			MsgInfo(STR0040) //"A solicitação não possui questionário de satisfação respondido."
			Return 0
		Endif
	Elseif !lVisual .AND. !Empty(TQB->TQB_SEQQUE) .and. TQB->TQB_SATISF == "1"
		MsgInfo(STR0041) //"Pesquisa de satisfação já respondida."
		Return 0
	Endif
Endif

aQuest := fRetQuesti(cContVar,cCodSS,lVisual,TQB->TQB_SEQQUE)

If !lWF
	If Len(aQuest) == 0
		MsgInfo(STR0042) //"Não existe uma pesquisa de satisfação definida."
		Return 0
	EndIf
Else
	If Len(aQuest) == 0
		Return 0
	EndIf
EndIf

//Verifica as questoes e respostas do questionario
MNT307RES(aQuest[1],aQuest[2],aQuest[3],@aQuestionario,lVisual,TQB->TQB_SEQQUE)

If !lWF
	aRotina := { { STR0006	, "AxPesqui"  , 0 , 1},; //"Pesquisar"
	             { STR0007	, "NGCAD01"  , 0 , 2},; //"Visualizar"
	             { STR0008	, "NGCAD01"  , 0 , 3},; //"Incluir"
	             { STR0009	, "NGCAD01"  , 0 , 4},; //"Alterar"
	             { STR0010	, "NGCAD01"  , 0 , 5, 3} } //"Excluir"

	If lVisual
		INCLUI  := .F.
		ALTERA  := .F.
	Else
		INCLUI := .T.
	Endif

	//Ajustes de tela
	Aadd(aObjects,{200,200,.t.,.f.})
	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObjects,.t.)
	If aSize[6] > 900
		aPosObj[1,3] := aPosObj[1,3] * ( aSize[6] / 560 )
	ElseIf aSize[6] > 650
		aPosObj[1,3] := aPosObj[1,3] * ( aSize[6] / 590 )
	Else
		aPosObj[1,3] := aPosObj[1,3] * ( aSize[6] / 610 )
	Endif

	aAreaTQB := TQB->(GetArea())
	dbSelectArea("TUQ")
	RegToMemory("TUQ",(!lVisual))
	RestArea(aAreaTQB)

	If Len(aQuestionario) > 0
		oResp := Array(Len(aQuestionario),3)
	Endif

	nFatMlt := 1.95
	If aPosObj[1,4] <= 410
		nFatMlt := 1.9
	ElseIf aPosObj[1,4] <= 550
		nFatMlt := 1.93
	Endif

	DEFINE MSDIALOG oDlgInd TITLE OemToAnsi(STR0043) From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL //"Questionário"
	oDlgInd:lEscClose := .f.

	nLinObj := 2
	@ 0,0 SCROLLBOX oScroll VERTICAL OF oDlgInd BORDER
	oScroll:Align := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Titulo do Grupo                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPanelTmp := TPaintPanel():new(nLinObj-1,-4,aPosObj[1,4]+5,14,oScroll)
	oPanelTmp:addShape("id=2;type=2;left=0;top=0;width="+Alltrim(Str(aPosObj[1,4]*2.2,5))+";height=28;"+;
						"gradient=1,0,0,0,36,0.0,#808090,0.1,#808090,1.0,#FFFFFF;pen-width=1;"+;
						"pen-color=#B0C4DE;can-move=0;can-mark=0;is-blinker=1;")
	@ 2, 11 SAY oGrpNome Prompt "Solicitação: "+TQB->TQB_SOLICI+" - "+fRetDesc() PIXEL OF oPanelTmp Font oFont16 COLOR CLR_WHITE
	nLinObj += 25

	cOldGrupo := "#"
	For nYY := 1 to Len(aQuestionario)
		If cOldGrupo <> aQuestionario[nYY,__CODGRUP__]
			cOldGrupo := aQuestionario[nYY,__CODGRUP__]
			cDesGrupo := " "
			dbSelectArea("TUN")
			dbSetOrder(01)
			If dbSeek( xFilial("TUN") + cOldGrupo )
				If !Empty(TUN->TUN_DESCRI)
					cDesGrupo := Capital( Alltrim(TUN->TUN_DESCRI) )
				Endif
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Titulo do Grupo                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oPanelTmp := TPaintPanel():new(nLinObj-1,0,aPosObj[1,4],10,oScroll)
			oPanelTmp:addShape("id=1;type=1;left=0;top=0;width="+Alltrim(Str(aPosObj[1,4]*2,5))+";height=20;"+;
								"gradient=1,0,0,0,15,0.0,#FFFFFF,0.1,#FFFFFF,1.0,#FFFFFF;pen-width=1;"+;
								"pen-color=#FFFFFF;can-move=0;can-mark=0;is-blinker=1;")

			oPanelTmp:addShape("id=2;type=2;left=10;top=0;width="+Alltrim(Str(aPosObj[1,4]*nFatMlt,5))+";height=20;"+;
								"gradient=1,0,0,0,15,0.0,#FFFFFF,0.1,#FDFBFD,1.0,#CDD1D4;pen-width=1;"+;
								"pen-color=#B0C4DE;can-move=0;can-mark=0;is-blinker=1;")

			@ 1, 11 SAY oResp[nYY,3] Prompt Space(40) PIXEL OF oPanelTmp Font oFont12
				oResp[nYY,3]:SetText(cDesGrupo)
			nLinObj += 13
		Endif

		cStrYY := Alltrim( Str(nYY) )

		//-------------------------------------------------
		//Titulo Questão
		//-------------------------------------------------
		nPosOld := nLinObj+7
		@ nLinObj, 009 SAY oResp[nYY,1] Prompt Space(40) PIXEL OF oScroll Font oFont12
			oResp[nYY,1]:bSetGet := &("{|u| If(pCount() == 0, aQuestionario["+cStrYY+","+cValToChar(__PERGUNT__)+"], aQuestionario["+cStrYY+","+cValToChar(__PERGUNT__)+"] := u)}")
			oResp[nYY,1]:SetText(aQuestionario[nYY,__PERGUNT__])

		//-------------------------------------------------
		//Calcula tamanho e apresenta GroupBox
		//-------------------------------------------------
		nOldLinObj := nLinObj
		nLimCol := aSize[5]/7
		nAcumLi := 0
		For nXX := 1 To Len(aQuestionario[nYY,__RESPOST__])
			cDescBox := SubStr(aQuestionario[nYY,__RESPOST__,nXX],3)
			If (nAcumLi + Len(cDescBox) + 5) > nLimCol .or. nXX == 1
				nLinObj += 9
				nAcumLi := 0
			Endif
			nAcumLi += Len(cDescBox) + 5
		Next nXX
		If aQuestionario[nYY,7]
			nLinObj += 22
		Endif
		nLinObj += 13
		@ nPosOld,09 TO nLinObj-3,aPosObj[1,4]-15 OF oScroll PIXEL

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Montando lista de opcoes (radio ou check)      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nLinObj := nOldLinObj
		nLimCol := aSize[5]/7
		nAcumLi := 0
		For nXX := 1 To Len(aQuestionario[nYY,__RESPOST__])
			cStrXX := Alltrim( Str(nXX) )
			cDescBox := SubStr(aQuestionario[nYY,__RESPOST__,nXX],3)
			If (nAcumLi + Len(cDescBox) + 5) > nLimCol .or. nXX == 1
				nLinObj += 9
				nAcumLi := 0
			Endif

			If aQuestionario[nYY,__TIPLIST__]

				aQuestionario[nYY,__TOTRESP__,nXX,2] := TBtnBmp2():New( nLinObj*2,26+(nAcumLi*7),14,14,;
					If(aQuestionario[nYY,__TOTRESP__,nXX,1] == 0,"ngradiono","ngradiook"),,,,{|| },oScroll,,,.T. )

				//@ nLinObj, 22+(nAcumLi*3.5) SAY aQuestionario[nYY,__TOTRESP__,nXX,3] Prompt Space(30) PIXEL OF oScroll
				aQuestionario[nYY,__TOTRESP__,nXX,3] = TSay():New(nLinObj,22+(nAcumLi*3.5),,oScroll,,,,,,.T.,,,120,10)

				aQuestionario[nYY,__TOTRESP__,nXX,3]:SetText(cDescBox)

				If lVisual
					aQuestionario[nYY,__TOTRESP__,nXX,2]:lReadOnly := .T.
				Else
					aQuestionario[nYY,__TOTRESP__,nXX,3]:bLClicked := &("{|| MNT307RAD("+cStrYY+","+cStrXX+") }")
					aQuestionario[nYY,__TOTRESP__,nXX,2]:bAction := &("{|| MNT307RAD("+cStrYY+","+cStrXX+") }")
				Endif

			Else
				aQuestionario[nYY,__TOTRESP__,nXX,2] := TCheckBox():New(nLinObj-1,13+(nAcumLi*3.5),cDescBox,,oScroll,13+(Len(cDescBox)*3.5),7,,,,,,,,.T.)
				aQuestionario[nYY,__TOTRESP__,nXX,2]:bSetGet := &("{|u| If(PCount() == 0,aQuestionario["+cStrYY+","+cValToChar(__TOTRESP__)+","+cStrXX+",1],aQuestionario["+cStrYY+","+cValToChar(__TOTRESP__)+","+cStrXX+",1] := u)}")
				If lVisual
					aQuestionario[nYY,__TOTRESP__,nXX,2]:lReadOnly := .T.
				Endif
			Endif

			nAcumLi += Len(cDescBox) + 5

		Next nXX
		If aQuestionario[nYY,7]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Campo Memo                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nLinObj += 10
			oResp[nYY,2] := TMultiget():New(nLinObj,12,,oScroll,aPosObj[1,4]-30,18,,,,,,.T.)
				oResp[nYY,2]:EnableHScroll(.T.)
				oResp[nYY,2]:EnableVScroll(.T.)
				oResp[nYY,2]:bSetGet := &("{|u| If(pCount() == 0, aQuestionario["+cStrYY+","+cValToChar(__MEMO__)+"], aQuestionario["+cStrYY+","+cValToChar(__MEMO__)+"] := u)}")
			nLinObj += 12
			If lVisual
				oResp[nYY,2]:lReadOnly := .T.
			Endif
		Endif
		nLinObj += 13
		//@ nPosOld,09 TO nLinObj-3,aPosObj[1,4]-15 OF oScroll PIXEL

	Next nYY

	nLinObj += 13
	@ nLinObj, 012 SAY " " PIXEL OF oScroll

	ACTIVATE MSDIALOG oDlgInd ON INIT EnchoiceBar(oDlgInd,{|| nOpca := 1 , If(!fValQuest(aQuestionario,lVisual), nOpca := 0, oDlgInd:End())},{|| oDlgInd:End()})
Endif

If nOpca == 1 .or. lWF
	Begin Transaction
		GrvQuest(lVisual,aQuest,!lWF)
	End Transaction
Endif

If Len(aOldRot) > 0
	aRotina := aClone(aOldRot)
Endif
RestArea(aAreaTmp)
Return nOpca
//---------------------------------------------------------------------
/*/{Protheus.doc} fRetDesc
Valida as questoes obrigatorias

@return Nil

@sample
fValQuest()

@author Jackson Machado
@since 17/04/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fValQuest(aQuest,lVisual)
Local nX,nY
Local lOk := .F.

If !lVisual
	For nX := 1 To Len(aQuest)
		lOk := .F.
		For nY := 1 To Len(aQuest[nX,__RESPOST__])
			If aQuest[nX,__TIPLIST__]
				If ValType(aQuest[nX,__TOTRESP__,nY,1]) == "N"
					If aQuest[nX,__TOTRESP__,nY,1] == 1
						lOk := .T.
					Endif
				Endif
			Else
				If ValType(aQuest[nX,__TOTRESP__,nY,1]) == "L"
					If aQuest[nX,__TOTRESP__,nY,1]
						lOk := .T.
					Endif
				Endif
			Endif
		Next nY
		If !lOk .and. Len(aQuest[nX,__TOTRESP__]) == 0
			If aQuest[nX,__TENMEMO__] .and. !Empty(aQuest[nX,__MEMO__])
				lOk := .T.
			Endif
		Endif
		If !lOk
			ShowHelpDlg(STR0044,{STR0045},2,{STR0046+SubStr(aQuest[nX,__PERGUNT__] ,1,1)},2) //"ATENÇÃO" # "Uma ou mais questões obrigatórias não foram preenchidas." # "Responda a questão "
			Return .F.
		Endif
	Next nX
Endif

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fRetDesc
Retorna descricao para o titulo

@return Nil

@sample
fRetDesc()

@author Jackson Machado
@since 17/04/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fRetDesc()
Local cRet := TQB->TQB_CODBEM
Local aArea := GetArea()

If TQB->TQB_TIPOSS == "B"
	dbSelectArea("ST9")
	dbSetOrder(1)
	dbSeek(xFilial("ST9")+TQB->TQB_CODBEM)
	cRet := AllTrim(TQB->TQB_CODBEM)+" ("+AllTrim(ST9->T9_NOME)+")"
Else
	dbSelectArea("TAF")
	dbSetOrder(8)
	dbSeek(xFilial("TAF")+Trim(TQB->TQB_CODBEM))
	cRet := AllTrim(TQB->TQB_CODBEM)+" ("+AllTrim(TAF->TAF_NOMNIV)+")"
Endif

RestArea(aArea)
Return cRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fRetCombo
Verifica se a formula está correta e faz a gravação

@return Nil

@sample
fRetCombo()

@author Jackson Machado
@since 17/04/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fRetCombo(cVar)
Local aArray1 := RetSx3Box(cVar,,,1)
Local nCont,aArray2 := {}

For nCont := 1 To Len(aArray1)
	If !Empty(aArray1[nCont][1])
		AADD(aArray2,Alltrim(aArray1[nCont][1]))
	Endif
Next nCont

Return aClone(aArray2)
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT307RAD
Validacao do Radio Group

@return Nil

@sample
MNT307RAD()

@author Jackson Machado
@since 17/04/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Function MNT307RAD(nTmpYY,nTmpXX)
Local nX

For nX := 1 To Len(aQuestionario[nTmpYY,__TOTRESP__])
	If nX == nTmpXX
		aQuestionario[nTmpYY,__TOTRESP__,nX,1] := 1
		aQuestionario[nTmpYY,__TOTRESP__,nX,2]:LoadBitmaps("ngradiook")
	Else
		If aQuestionario[nTmpYY,__TOTRESP__,nX,1] <> 0
			aQuestionario[nTmpYY,__TOTRESP__,nX,1] := 0
			aQuestionario[nTmpYY,__TOTRESP__,nX,2]:LoadBitmaps("ngradiono")
		Endif
	Endif
Next nX

oScroll:Refresh()

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} GrvQuest
Função chamada para gravacao

@return Nil

@sample
GrvQuest(3)

@author Jackson Machado
@since 17/04/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function GrvQuest(lVisual,aQuest,lGrvResp)
Local ny,nx,cOrd,nXX,nYY,nZZ
Local aTUQs := {}
Local cSeq  := GETSXENUM("TUQ","TUQ_SEQUEN")

Default lGrvResp := .T.

If !lVisual
	For nYY := 1 to Len(aQuestionario)
		aRespost := {}
		If lGrvResp
			For nXX := 1 To Len(aQuestionario[nYY,__RESPOST__])
				cStrXX := Alltrim( Str(nXX) )
				If aQuestionario[nYY,__TIPLIST__] //Radio
					If ValType(aQuestionario[nYY,__TOTRESP__,nXX,1]) == "N"
						If aQuestionario[nYY,__TOTRESP__,nXX,1] == 1
							aAdd( aRespost , aQuestionario[nYY,__RESPOST__,nXX] )
						Endif
					Endif
				Else //Check
					If ValType(aQuestionario[nYY,__TOTRESP__,nXX,1]) == "L"
						If aQuestionario[nYY,__TOTRESP__,nXX,1]
							aAdd( aRespost , aQuestionario[nYY,__RESPOST__,nXX] )
						Endif
					Endif
				Endif
			Next nXX
			If ValType(aQuestionario[nYY,__MEMO__]) == "C" //Adiciona campo memo para gravação
				If !Empty(aQuestionario[nYY,__MEMO__])
					aAdd( aRespost , "#" )
				Endif
			Endif
		Else
			aAdd( aRespost , " " )
		Endif
		//Se encontrou informação para a pergunta, grava
		For nZZ := 1 To Len(aRespost)
			dbSelectArea("TUQ")
			dbSetOrder(1)
			If dbSeek( xFilial("TUQ")+cSeq+aQuest[1]+aQuest[2]+aQuest[3]+aQuestionario[nYY,1]+aRespost[nZZ] )
				RecLock("TUQ",.F.)
				TUQ->TUQ_RESPOS := aRespost[nZZ]
				TUQ->TUQ_VALOR  := A307RETVAL(aQuest[1]+aQuest[2]+aQuest[3]+aQuestionario[nYY,__QUESTAO__],aRespost[nZZ])
			Else
				RecLock("TUQ",.T.)
				TUQ->TUQ_FILIAL := xFilial("TUQ")
				TUQ->TUQ_SEQUEN := cSeq
				TUQ->TUQ_TIPO   := aQuest[1]
				TUQ->TUQ_QUESTI := aQuest[2]
				TUQ->TUQ_LOJA   := aQuest[3]
				TUQ->TUQ_QUESTA := aQuestionario[nYY,1]
				If lGrvResp
					TUQ->TUQ_RESPOS := aRespost[nZZ]
					TUQ->TUQ_VALOR  := A307RETVAL(aQuest[1]+aQuest[2]+aQuest[3]+aQuestionario[nYY,__QUESTAO__],aRespost[nZZ])
				Endif
				TUQ->TUQ_PERGUN := SubStr(aQuestionario[nYY,__PERGUNT__],2)
				TUQ->TUQ_ORDEM  := aQuestionario[nYY,__ORDEM__]
				TUQ->TUQ_CODGRU := aQuestionario[nYY,__CODGRUP__]
				TUQ->TUQ_TPLIST := If(aQuestionario[nYY,__TIPLIST__],"1","2")
				TUQ->TUQ_ONMEMO := If(aQuestionario[nYY,__TENMEMO__],"1","2")
				TUQ->TUQ_PERGUT := SubStr(aQuestionario[nYY,__2PERGUN__],1,250)
				TUQ->TUQ_2PERGU := SubStr(aQuestionario[nYY,__2PERGUN__],251)
			Endif
			TUQ->(MsUnLock())
			If aRespost[nZZ] == "#"
				MSMM(,,,aQuestionario[nYY,__MEMO__],1,,,"TUQ","TUQ_CODCOM")
			Endif
			aAdd(aTUQs , TUQ->(Recno()) )
		Next nZZ
	Next nYY

	RecLock("TQB")
	TQB->TQB_SEQQUE := TUQ->TUQ_SEQUEN
	If lGrvResp
		TQB->TQB_SATISF := "1"
	Else
		TQB->TQB_SATISF := "2"
	Endif
	TQB->(MsUnLock())

	//Inclui ou altera o cadastro de itens do Tipo de Ficha
	dbSelectArea("TUQ")
	dbSetOrder(1)
	If dbSeek( xFilial("TUQ") + TQB->TQB_SEQQUE )
		While !Eof() .and. xFilial("TUQ") == TUQ->TUQ_FILIAL .and. TQB->TQB_SEQQUE == TUQ->TUQ_SEQUEN

			If TUQ->TUQ_QUESTA == Replicate("#",Len(TUQ->TUQ_QUESTA)) .Or. TUQ->TUQ_QUESTA == Replicate("@",Len(TUQ->TUQ_QUESTA))
				dbSelectArea("TUQ")
				dbSkip()
				Loop
			Endif
			If aScan(aTUQs, {|x| x == TUQ->(Recno()) }) == 0
				dbSelectArea("TUQ")
				RecLock("TUQ",.F.)
				dbDelete()
				TUQ->(MsUnLock())
			Endif
			dbSelectArea("TUQ")
			dbSkip()
		End
	Endif

	// Gera Follow-Up de Resposta de Pesquisa de Satisfação
	If lGrvResp
		MNT280GFU(TQB->TQB_SOLICI/*cCodSS*/, "10"/*cCodFlwUp*/, STR0047/*cObservacao*/, /*dDtIFlwUp*/, /*cHrIFlwUp*/, ;
					/*dDtFFlwUp*/, /*cHrFFlwUp*/, /*cUsuFlwUp*/, /*cCodFun*/, /*cCodFilAte*/)
	EndIf
Endif
ConfirmSX8()
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} A307RETVAL
Retorna valor da opção

@return Nil

@sample
A307RETVAL()

@author Jackson Machado
@since 17/04/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Function A307RETVAL(cChave,cResp)
local nPos, nPos1, nVal
Local cVal     := ""
Local aArea    := GetArea()
Local cValores := ""

If cResp <> "#"
	dbSelectArea("TUP")
	dbSetOrder(1)
	If dbSeek(xFilial("TUP")+cChave)
		cValores := AllTrim(TUP->TUP_VALORE)+";"
		nPos  := At( SubStr(cResp,1,1)+"=" , cValores )
		nPos1 := At( ";" , Substr( cValores , nPos+2 ) )
		If nPos > 0 .and. nPos1 <= 0
			cVal := Alltrim(Substr( cValores , nPos+2 ))
		Else
			cVal := Alltrim(Substr( cValores , nPos+2 , nPos1-1 ))
		Endif
	Endif
Endif
nVal := Val(cVal)

RestArea(aArea)
Return nVal
//---------------------------------------------------------------------
/*/{Protheus.doc} fConfig
Configuração de importãncia da pesquisa

@return Nil

@sample
fConfig()

@author Jackson Machado
@since 17/04/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fConfig(lRetorno)
Local nX, nPos, cOld
Local nOpca := 0
Local oDlgCon
Local oPnlPai, oPnlList, oPnl2Get, oPnlBtn
Local bBox
Local oBtnUp, oBtnDw
Local aCont    := {}
Local cContVar := ""
Local aImport  := {}
Local nSizeFil := If(FindFunction("FWSizeFilial"),FWSizeFilial(),Len(xFilial("SX6")))
Default lRetorno := .F.
Private oBox

cContVar := GetMv("MV_NGPESST") // Manter o GetMV já que este comando pega o valor sempre atualizado. Ver Task #14852
aImport  := If(Empty(cContVar),{},StrTokArr(cContVar,"/"))

aAdd(aCont,{"1",STR0048}) //"Família"
aAdd(aCont,{"2",STR0049}) //"Tipo Modelo"
aAdd(aCont,{"3",STR0050}) //"Bem"
aAdd(aCont,{"4",STR0051}) //"Localização"
aAdd(aCont,{"5",STR0052}) //"Tipo Serviço"
aAdd(aCont,{"6",STR0053}) //"Atendente"
aAdd(aCont,{"7",STR0054}) //"Terceiros"
aAdd(aCont,{"8",STR0055}) //"Centro Custo"
aAdd(aCont,{"9",STR0056}) //"Centro Trabalho"
aAdd(aCont,{"A",STR0057}) //"Geral"

If Len(aImport) == 0
	aImport := aClone(aCont)
Else
	For nX := 1 To Len(aImport)
		If(nPos := aScan(aCont,{|x| x[1] == aImport[nX]})) > 0
			aImport[nX] := aClone(aCont[nPos])
		Endif
	Next nX
Endif

// TELA DE CONFIGURACAO
DEFINE MSDIALOG oDlgCon Title STR0001 From 0,0 To 244,392 Of oMainWnd Pixel //"Configuração - Pesquisa de Satisfação"
	oPnlPai := TPanel():New(00,00,,oDlgCon,,,,,,0,0,.F.,.F.)
		oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

		//Botoes
		oPnlBtn := TPanel():New(00,00,,oPnlPai,,,,,,12,12,.F.,.F.)
			oPnlBtn:Align := CONTROL_ALIGN_LEFT
			oBtnUp  := TBtnBmp():NewBar("PMSSETAUP","PMSSETAUP",,,,{|| fAltOrd(1) },,oPnlBtn,,{|| .T. },"",,,,,"")
				oBtnUp:cToolTip := STR0058 //"Altera a ordem."
				oBtnUp:Align  := CONTROL_ALIGN_TOP

			oBtnDw  := TBtnBmp():NewBar("PMSSETADOWN","PMSSETADOWN",,,,{|| fAltOrd(2)},,oPnlBtn,,{|| .T. },"",,,,,"")
				oBtnDw:cToolTip := STR0058 //"Altera a ordem."
				oBtnDw:Align  := CONTROL_ALIGN_TOP
		//GetDados com o conteúdo original
		oPnlList := TPanel():New(00,00,,oPnlPai,,,,,,0,0,.F.,.F.)
			oPnlList:Align := CONTROL_ALIGN_ALLCLIENT

			oBox := TWBrowse():New( 0 , 0, 0, 0,,{STR0059},{100},;  //"Níveis"
										oPnlList,,,,,{||},,,,,,,.F.,,.T.,,.F.,,.T.,.T.)

			oBox:SetArray(aImport)
			bBox := { || { aImport[oBox:nAt,2] } }
			oBox:bLine := bBox
			oBox:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlgCon ON INIT EnchoiceBar(oDlgCon,{|| nOpca := 1,oDlgCon:End()},{|| nOpca := 0,oDlgCon:End()}) CENTERED

If nOpca == 1
	cOld     := cContVar
	cContVar := ""
	For nX := 1 To Len(aImport)
		cContVar += aImport[nX,1]
		If nX <> Len(aImport)
			cContVar += "/"
		Endif
	Next nX

	PutMV("MV_NGPESST",cContVar)

Endif

Return If(lRetorno,cContVar,NIL)
//---------------------------------------------------------------------
/*/{Protheus.doc} fAltOrd
Altera ordem no list box

@return Nil

@sample
fAltOrd(1)

@author Jackson Machado
@since 17/04/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fAltOrd(nTipo)
Local nPos := 0
Local aTmp

If nTipo == 1
	If oBox:nAt > 1
		aTmp := aClone(oBox:aArray[oBox:nAt-1])
		oBox:aArray[oBox:nAt-1] := aClone(oBox:aArray[oBox:nAt])
		oBox:aArray[oBox:nAt]   := aClone(aTmp)
		nPos := oBox:nAt - 1
	Endif
Else
	If oBox:nAt < Len(oBox:aArray)
		aTmp := aClone(oBox:aArray[oBox:nAt+1])
		oBox:aArray[oBox:nAt+1] := aClone(oBox:aArray[oBox:nAt])
		oBox:aArray[oBox:nAt]   := aClone(aTmp)
		nPos := oBox:nAt + 1
	Endif
Endif
If nPos > 0
	oBox:nAt := nPos
	oBox:nRowPos := nPos
Endif

oBox:Refresh()

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fRetQuesti
Retorna o questionario adequado

@return Nil

@sample
fRetQuesti('1/2/3/4/5/6/7/8/9/A')

@author Jackson Machado
@since 17/04/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Function fRetQuesti(cOrdem,cSS,lVisual,cSequen)
Local nX
Local aOrdem   := {}
Local aReturn  := {}
Local aArea    := GetArea()

// Variáveis de Pesquisa na tabela TUR
Local cTipoAtend := ""
Local cHoraMaior := ""
Local cHoraTUR := ""
Local nRecNoTUR := 0

Default cOrdem := ""
aOrdem := If(Empty(cOrdem),{},StrTokArr(cOrdem,"/"))

If !lVisual
	dbSelectArea("TQB")
	dbSetOrder(1)
	If dbSeek(xFilial("TQB")+cSS) .and. Len(aOrdem) > 0
		For nX := 1 To Len(aOrdem)
			dbSelectArea("TUO")
			dbSetOrder(1)
			If aOrdem[nX] == "1" // 1=Família
				If TQB->TQB_TIPOSS == "B"
				 	If dbSeek(xFilial("TUO")+"1"+NGSEEK("ST9",TQB->TQB_CODBEM,1,"T9_CODFAMI"))
						aAdd(aReturn,TUO->TUO_TIPO)
						aAdd(aReturn,TUO->TUO_CODIGO)
						aAdd(aReturn,TUO->TUO_LOJA)
						aAdd(aReturn,TUO->TUO_DESABI)
						Exit
					EndIf
				Else
					dbSelectArea("TAF")
					dbSetOrder(6)
					If dbSeek(xFilial("TAF")+"X"+"1"+TQB->TQB_CODBEM)
						dbSelectArea("TUO")
						dbSetOrder(1)
						If dbSeek(xFilial("TUO")+"1"+TAF->TAF_CODFAM)
							aAdd(aReturn,TUO->TUO_TIPO)
							aAdd(aReturn,TUO->TUO_CODIGO)
							aAdd(aReturn,TUO->TUO_LOJA)
							aAdd(aReturn,TUO->TUO_DESABI)
							Exit
						EndIf
					EndIf
				EndIf
			ElseIf aOrdem[nX] == "2" // 2=Tipo Modelo
				If dbSeek(xFilial("TUO")+"2"+NGSEEK("ST9",TQB->TQB_CODBEM,1,"T9_TIPMOD"))
					aAdd(aReturn,TUO->TUO_TIPO)
					aAdd(aReturn,TUO->TUO_CODIGO)
					aAdd(aReturn,TUO->TUO_LOJA)
					aAdd(aReturn,TUO->TUO_DESABI)
					Exit
				EndIf
			ElseIf aOrdem[nX] == "3" // 3=Bem
			 	If dbSeek(xFilial("TUO")+"3"+TQB->TQB_CODBEM)
					aAdd(aReturn,TUO->TUO_TIPO)
					aAdd(aReturn,TUO->TUO_CODIGO)
					aAdd(aReturn,TUO->TUO_LOJA)
					aAdd(aReturn,TUO->TUO_DESABI)
					Exit
				EndIf
			ElseIf aOrdem[nX] == "4" // 4=Localização
				If dbSeek(xFilial("TUO")+"4"+TQB->TQB_CODBEM)
					aAdd(aReturn,TUO->TUO_TIPO)
					aAdd(aReturn,TUO->TUO_CODIGO)
					aAdd(aReturn,TUO->TUO_LOJA)
					aAdd(aReturn,TUO->TUO_DESABI)
					Exit
				EndIf
			ElseIf aOrdem[nX] == "5" // 5=Tipo Serviço
				If dbSeek(xFilial("TUO")+"5"+TQB->TQB_CDSERV)
					aAdd(aReturn,TUO->TUO_TIPO)
					aAdd(aReturn,TUO->TUO_CODIGO)
					aAdd(aReturn,TUO->TUO_LOJA)
					aAdd(aReturn,TUO->TUO_DESABI)
					Exit
				EndIf
			ElseIf aOrdem[nX] $ "6/7" // 6=Atendente ou 7=Terceiros
				cTipoAtend := If(aOrdem[nX] == "6", "2", "3")
				cHoraMaior := ""
				cHoraTUR := ""
				nRecNoTUR := 0
				dbSelectArea("TUR")
				dbSetOrder(1)
				dbSeek(xFilial("TUR",TQB->TQB_FILIAL) + TQB->TQB_SOLICI + cTipoAtend, .T.)
				While !Eof() .And. TUR->TUR_FILIAL == xFilial("TUR",TQB->TQB_FILIAL) .And. TUR->TUR_SOLICI == TQB->TQB_SOLICI .And. TUR->TUR_TIPO == cTipoAtend
					cHoraTUR := TUR->TUR_HRREAL
					If Empty( StrTran(cHoraTUR, ":", "") )
						cHoraTUR := "00:00"
					EndIf

					If Empty(cHoraMaior) .Or. HTON(cHoraTUR) > HTON(cHoraMaior)
						cHoraMaior := cHoraTUR
						nRecNoTUR := TUR->( RecNo() )
					EndIf

					dbSelectArea("TUR")
					dbSkip()
				End
				If nRecNoTUR > 0
					TUR->( dbGoTo(nRecNoTUR) )
					dbSelectArea("TUO")
					If dbSeek(xFilial("TUO",TUR->TUR_FILATE) + aOrdem[nX] + TUR->TUR_CODATE + TUR->TUR_LOJATE)
						aAdd(aReturn,TUO->TUO_TIPO)
						aAdd(aReturn,TUO->TUO_CODIGO)
						aAdd(aReturn,TUO->TUO_LOJA)
						aAdd(aReturn,TUO->TUO_DESABI)
						Exit
					EndIf
				EndIf
			ElseIf aOrdem[nX] == "8" // 8=Centro Custo
				If TQB->TQB_TIPOSS == "B"
					If dbSeek(xFilial("TUO")+"8"+TQB->TQB_CCUSTO)
						aAdd(aReturn,TUO->TUO_TIPO)
						aAdd(aReturn,TUO->TUO_CODIGO)
						aAdd(aReturn,TUO->TUO_LOJA)
						aAdd(aReturn,TUO->TUO_DESABI)
						Exit
					EndIf
				Else
					dbSelectArea("TAF")
					dbSetOrder(6)
					If dbSeek(xFilial("TAF")+"X"+"1"+TQB->TQB_CODBEM)
						dbSelectArea("TUO")
						dbSetOrder(1)
						If dbSeek(xFilial("TUO")+"1"+TAF->TAF_CCUSTO)
							aAdd(aReturn,TUO->TUO_TIPO)
							aAdd(aReturn,TUO->TUO_CODIGO)
							aAdd(aReturn,TUO->TUO_LOJA)
							aAdd(aReturn,TUO->TUO_DESABI)
							Exit
						EndIf
					EndIf
				EndIf
			ElseIf aOrdem[nX] == "9" // 9=Centro Trabalho
				If TQB->TQB_TIPOSS == "B"
					If dbSeek(xFilial("TUO")+"9"+TQB->TQB_CENTRA)
						aAdd(aReturn,TUO->TUO_TIPO)
						aAdd(aReturn,TUO->TUO_CODIGO)
						aAdd(aReturn,TUO->TUO_LOJA)
						aAdd(aReturn,TUO->TUO_DESABI)
						Exit
					EndIf
				Else
					dbSelectArea("TAF")
					dbSetOrder(6)
					If dbSeek(xFilial("TAF")+"X"+"1"+TQB->TQB_CODBEM)
						dbSelectArea("TUO")
						dbSetOrder(1)
						If dbSeek(xFilial("TUO")+"1"+TAF->TAF_CENTRA)
							aAdd(aReturn,TUO->TUO_TIPO)
							aAdd(aReturn,TUO->TUO_CODIGO)
							aAdd(aReturn,TUO->TUO_LOJA)
							aAdd(aReturn,TUO->TUO_DESABI)
							Exit
						EndIf
					EndIf
				EndIf
			Else // A=Geral
				If dbSeek(xFilial("TUO")+"A")
					aAdd(aReturn,TUO->TUO_TIPO)
					aAdd(aReturn,TUO->TUO_CODIGO)
					aAdd(aReturn,TUO->TUO_LOJA)
					aAdd(aReturn,TUO->TUO_DESABI)
					Exit
				EndIf
			EndIf
		Next nX
	EndIf
Else
	dbSelectArea("TUQ")
	dbSetOrder(1)
	If dbSeek(xFilial("TUQ")+cSequen)
		aAdd(aReturn,TUQ->TUQ_TIPO)
		aAdd(aReturn,TUQ->TUQ_QUESTI)
		aAdd(aReturn,TUQ->TUQ_LOJA)
	EndIf
EndIf
RestArea(aArea)
Return aReturn
//---------------------------------------------------------------------
/*/{Protheus.doc} fRetResp
Retorna o questionario adequado

@return Nil

@sample
fRetQuesti('1/2/3/4/5/6/7/8/9/A')

@author Jackson Machado
@since 17/04/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Function MNT307RES(cTipo,cQuesti,cLoja,aQuest,lVisual,cSeque,lWf)
Local nXX
Local cMemo := ""
Local aTipoTUP, aTipoTUQ
Default lWf := .F.

If lVisual
	dbSelectArea("TUQ")
	dbSetOrder(1)
	dbSeek(xFilial("TUQ")+cSeque)
	If lWf
		cTipo   := TUQ->TUQ_TIPO
		cQuesti := TUQ->TUQ_QUESTI
		cLoja   := TUQ->TUQ_LOJA
	Endif
	While !Eof() .and. xFilial("TUQ")+cSeque == TUQ->(TUQ_FILIAL+TUQ_SEQUEN)
		aTipoTUQ := {}
		If aScan(aQuest,{|x| AllTrim(UPPER(x[__QUESTAO__])) == TUQ->TUQ_QUESTA }) > 0
			dbSkip()
			Loop
		Endif

		If !Empty(TUQ->TUQ_PERGUT+TUQ->TUQ_2PERGU)
			aTipoTUQ := fRetCombo(Alltrim(TUQ->TUQ_PERGUT+TUQ->TUQ_2PERGU))
		Endif
		aTemp    := Array(Len(aTipoTUQ),3)
		For nXX := 1 To Len(aTemp)
			If (TUQ->TUQ_TPLIST == "1")
				aTemp[nXX,1] := 0
			Else
				aTemp[nXX,1] := .F.
			Endif
			nRecTUQ := TUQ->(RECNO())
			dbSelectArea("TUQ")
			dbSetOrder(2)
			If dbSeek( xFilial("TUQ")+cTipo+cQuesti+cLoja+TUQ->TUQ_QUESTA+PadR(aTipoTUQ[nXX],Len(TUQ->TUQ_RESPOS))+cSeque )
				If (TUQ->TUQ_TPLIST == "1")
					aTemp[nXX,1] := 1
				Else
					aTemp[nXX,1] := .T.
				Endif
			Endif
			dbSelectArea("TUQ")
			dbGoTo(nRecTUQ)
		Next nXX

		//Se não for inclusão
		cMemo := ""
		nRecTUQ := TUQ->(RECNO())
		dbSelectArea("TUQ")
		dbSetOrder(2)
		If dbSeek( xFilial("TUQ")+cTipo+cQuesti+cLoja+TUQ->TUQ_QUESTA+PadR("#",Len(TUQ->TUQ_RESPOS))+cSeque )
			cMemo := MSMM(TUQ->TUQ_CODCOM,80)
		Endif
		dbSelectArea("TUQ")
		dbGoTo(nRecTUQ)
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
		//11- Obrigatoriedade
		aADD( aQuest , { TUQ->TUQ_QUESTA , Capital(cValToChar(Val(TUQ->TUQ_ORDEM))+" "+TUQ->TUQ_PERGUN) , TUQ->TUQ_CODGRU , aTipoTUQ ,;
						   TUQ->TUQ_PERGUT+TUQ->TUQ_2PERGU , (TUQ->TUQ_TPLIST == "1") ,;
						   (TUQ->TUQ_ONMEMO == "1") , aTemp , TUQ->TUQ_ORDEM , cMemo} )
		dbSelectArea("TUQ")
		dbSetOrder(1)
		dbSkip()
	End
Else
	dbSelectArea("TUP")
	dbSetOrder(1)
	dbSeek(xFilial("TUP")+cTipo+cQuesti+cLoja)
	While !Eof() .and. xFilial("TUP")+cTipo+cQuesti+cLoja == TUP->(TUP_FILIAL+TUP_TIPO+TUP_QUESTI+TUP_LOJA)
		aTipoTUP := {}
		If !Empty(TUP->TUP_PERGUT+TUP->TUP_2PERGU)
			aTipoTUP := fRetCombo(Alltrim(TUP->TUP_PERGUT+TUP->TUP_2PERGU))
		Endif
		aTemp    := Array(Len(aTipoTUP),3)
		For nXX := 1 To Len(aTemp)
			If (TUP->TUP_TPLIST == "1")
				aTemp[nXX,1] := 0
			Else
				aTemp[nXX,1] := .F.
			Endif
		Next nXX

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
		//11- Obrigatoriedade
		aADD( aQuest , { TUP->TUP_QUESTA , Capital(cValToChar(Val(TUP->TUP_ORDEM))+" "+TUP->TUP_PERGUN) , TUP->TUP_CODGRU , aTipoTUP ,;
						   TUP->TUP_PERGUT+TUP->TUP_2PERGU , (TUP->TUP_TPLIST == "1") ,;
						   (TUP->TUP_ONMEMO == "1") , aTemp , TUP->TUP_ORDEM , cMemo } )
		dbSelectArea("TUP")
		dbSetOrder(1)
		dbSkip()
	End
Endif

aSort( aQuest ,,, { |x,y| x[__ORDEM__] < y[__ORDEM__] } )

Return aQuest
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT307GRV
Função chamada para fazer a gravação da TUQ sem as respostas

@return Nil

@sample
MNT307GRV()

@author Jackson Machado
@since 17/04/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Function MNT307GRV()
Local aQuest := fRetQuesti(cContVar,cCodSS,lVisual,TQB->TQB_SEQQUE)

Private aQuestionario := {}//Necessaria variável para gravação

MNT307RES(aQuest[1],aQuest[2],aQuest[3],@aQuestionario,.F.,TQB->TQB_SEQQUE)

GrvQuest(.F.,aQuest,.F.)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fValSatis
Função para verifique se pode deletar uma pesquisa de satisfacao

@return Nil

@sample
MNT307GRV()

@author Tainã Alberto Cardoso
@since 16/11/2016
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fValSatis()

	Local cQuery := ""
	Local cAliasTUO := GetNextAlias()

	cQuery := " SELECT COUNT(*) QTD "
	cQuery += " FROM " + RetSQLName( "TQB" ) + " TQB "
	cQuery += " JOIN " + RetSQLName( "TUQ" ) + " TUQ "
	cQuery += "		ON TQB_SEQQUE = TUQ_SEQUEN "
	cQuery += " WHERE  TQB_SATISF <> ''  "
	cQuery += " 	AND TUQ_QUESTI = '" + TUO->TUO_CODIGO + " ' "
	cQuery += " 	AND TUQ_TIPO =   '" + TUO->TUO_TIPO + " ' "
	cQuery += "		AND TQB.D_E_L_E_T_ <> '*' "
	cQuery += "		AND TUQ.D_E_L_E_T_ <> '*' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasTUO, .F., .T. )
	dbSelectArea(cAliasTUO)
	dbGoTop()
	While !Eof()

		nQtdPes := (cAliasTUO)->QTD
		Exit

	End

	(cAliasTUO)->(dbCloseArea())

	//Verifica se ja possui pesquisa de satisfação apontada em uma S.S.
	If nQtdPes > 0
		MsgStop(STR0060) //"Pesquisa de satisfação já utilizada em uma S.S."
		Return .F.
	EndIf

Return .T.
