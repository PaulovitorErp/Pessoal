#INCLUDE "PROTHEUS.CH"
#INCLUDE "MNTA402.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA402
Cria tela que possibilita rateio de horas reportadas de insumos do
tipo ferramenta, mao-de-obra e terceiro entre diversas Ordens de
Servico

@author Vitor Emanuel Batista
@since 17/06/2009
@version P12
@souce SIGAMNT
/*/
//-------------------------------------------------------------------
Function MNTA402()

	Local aNGBEGINPRM := NGBEGINPRM(,,,,.T.)

	Local nOpc, nX, nTIPOI2, nQUANT2

	Local cTUDOK, cLINOK, cCombBox

	Local aSTJ     := {}
	Local aNAO     := {}
	Local aButton  := {}

	//Variavel com os campos especificos do cliente
	Local aCposAlter := {}

	//Variavel que indica se o filtro ja foi ativo (para carregar a TRB temporaria)
	Local lFiltro  := .F.

	Local lInverte := .F.
	Local cMarca   := GetMark()

	//Tabela Utilizada pelo oMark
	Local cTRB402
	Local cTRBTEMP
	Local oTmpMrk
	Local oTmpFil

	//Variaveis de Largura/Altura da Janela
	Local aSize   := MsAdvSize(,.F.,430)

	Private oDlg
	Private oGet
	Private oMark
	Private oMenu

	Private nLargura  := aSize[5]
	Private nAltura   := aSize[6]
	Private cSerefor  := AllTrim( GETMV( "MV_NGSEREF" ) )
	Private aServRef  := StrTokArr( cSerefor, ';' ) 
	Private cSercons  := AllTrim( GETMV( "MV_NGSECON" ) )
	Private aServCon  := StrTokArr( cSercons, ';' ) 

	Private cUSAINT3 := AllTrim(GetMv("MV_NGMNTES"))
	Private lCUSTO   := cUSAINT3 == 'N'

	//Variaveis utilizadas pela função NGCALDTHO
	Private nDATAF		:= 0
	Private nDATGD		:= 0
	Private nHORAF		:= 0
	Private nHORAI		:= 0

	Private lMMoeda    := NGCADICBASE("TL_MOEDA","A","STL",.F.) // Multi-Moeda
	Private cCadastro := OemToAnsi(STR0001) //"Retorno de Múltiplas O.S's"

	Private cNGINSPREA := "R" //Indica se o insumo e realizado ou previsto, nao deve ser retirado
	//esta variavel ela e usada para fazer checagem em funcoes dos ng..

	Private cPar01 := Space(6), cPar02 := Space(6), cPar05 := Space(3)

	//Retorna campos que nao irao aparecer no GetDados
	aNAO := NGRETaNAO(@aCposAlter)

	cTUDOK := "MNT402LIOK"
	cLINOK := "MNT402LIOK(oGet:nAt)"

	//Retorna aHeader e Inicializa aCOLS em Branco
	dbSelectArea("STL")
	dbGoBottom()
	dbSkip()
	aHeader := CABECGETD("STL", aNAO, 2)
	aCols   := BLANKGETD(aHEADER)

	nTIPOI2 := GdFieldPos("TL_TIPOREG")
	nQUANT2 := GdFieldPos("TL_QUANTID")
	nDtIni  := GdFieldPos("TL_DTINICI")

	//retira a funcao NGDTINIC do valid do campo tl_dtinici
	nPosI := At("NGDTINIC()",aHeader[nDtIni,6]) - 7
	nPosF := nPosI + Len("NGDTINIC()") + 8
	aHeader[nDtIni,6] := SubStr(aHeader[nDtIni,6],1,nPosI) + SubStr(aHeader[nDtIni,6],nPosF,Len(aHeader[nDtIni,6]))
	aHeader[nTIPOI2,6] += ".And. VERDESTINO(.T.)"

	//Variaveis utilizadas em outros fontes
	Private aGETINSAL	:= {}
	Private lCORRET		:= .T.
	Private nSEQUENC	:= "0  "
	Private TIPOACOM	:= .F.
	Private TIPOACOM2	:= .F.
	Private lSITUACA	:= .F.
	Private cLocaliz	:= Space(Len(TPS->TPS_CODLOC))
	aTROCAF3			:= {}

	MV_PAR01 := Space(20)
	MV_PAR02 := Space(20)
	MV_PAR05 := Space(20)

	//Variavel utilizada no NGCRIACOR
	Private lCervPetro := .F.
	If ExistBlock("CER1A050")
		lCervPetro := .T.
	EndIf
	//--Fim

	SetInclui()

	RegtoMemory("STL",.T.)
	RegtoMemory("STJ",.T.)

	//Cria Tabela Temporaria e carrega dados das O.S
	MsgRun( STR0002, STR0003, { || cTRB402 := CRIATRBOS(@aSTJ, @cTRBTEMP, @oTmpMrk, @oTmpFil) }) //"Processando informações..."###"Aguarde"

	//Botao na barra superior
	aAdd(aButton,{"FILTRO", {|| MNTA402FIL(@lFiltro, cTRB402, cTRBTEMP)}, STR0004, STR0004}) //"Filtro"###"Filtro"
	aAdd(aButton,{"NG_ICO_LEGENDA", {|| NG400LEG()}, STR0005, STR0005}) //"Legenda"###"Legenda"

	//PE - Oculta botão finalizar
	If ExistBlock("MNTA4021")
		If ExecBlock("MNTA4021",.F.,.F.) //Será verificado através do PE se será apresentado o botão finalizar
			aAdd(aButton, {"SDUSETDEL", {|| If(NG402FIM(cTRB402, aCposAlter), oDlg:End(), .F.)}, STR0006, STR0006}) //"Finalizar"###"Finalizar"
		EndIf
	Else //Caso o ponto de entrada não exista, mostra o botão finalizar
		aAdd(aButton,{"SDUSETDEL", {|| If(NG402FIM(cTRB402, aCposAlter), oDlg:End(), .F.)}, STR0006, STR0006}) //"Finalizar"###"Finalizar"
	EndIf

	//Array com cores possiveis para as O.S
	aCores := MNTA402COR(cTRB402)

	dbSelectArea(cTRB402)
	dbGoTop()

	Define MsDialog oDlg From 0, 0 To nAltura, nLargura Title cCadastro Of oMainWnd Color CLR_BLACK, CLR_WHITE Pixel Style nOR(WS_VISIBLE,WS_POPUP)

		oPanel := TPanel():New( 01, 01,, oDlg,,,,,,,, .F., .F. )
		oPanel:Align := CONTROL_ALIGN_ALLCLIENT

		oDlg:lMaximized := .T.
		oDlg:lEscClose  := .F.

		//apenas itens que necessitam de rateio
		cCombBox := 'F=' + NGRetSX3Box('TL_TIPOREG', 'F') + ';'
		cCombBox += 'M=' + NGRetSX3Box('TL_TIPOREG', 'M') + ';'
		cCombBox += 'T=' + NGRetSX3Box('TL_TIPOREG', 'T')

		oGet := MsNewGetDados():New(1, 1, (nAltura / 4) - 30, (nLargura / 2), GD_INSERT + GD_UPDATE + GD_DELETE, cLinOk, cTudOk,,,,9999,,,"NG420DELI(oGet:aCOLS, oGet:nAt)",oPanel,aHeader,aCols)
		oGet:aInfo[nTipoI2][2] := cCombBox

		oGet:aHeader[nQUANT2,6]  += " .And. NG420QUANT(aCOLS[oGet:nAt," + cValToChar(nTIPOI2) + "],M->TL_QUANTID)"

		oMark := MsSelect():New(cTRB402,"TRB_OK",,aSTJ,@lInverte,@cMarca,{(nAltura/4)-25,1,(nAltura/2)-20,(nLargura/2)},,, oPanel,,aCores)
		oMark:oBrowse:bAllMark    := { || MNTA402INV(cMarca,cTRB402) }
		oMark:oBrowse:lHasMark    := .T.
		oMark:oBrowse:lCanAllMark := .T.

		If Len(aSMenu) > 0
			NGPOPUP(asMenu,@oMenu)
			oPanel:bRClicked := { |o,x,y| oMenu:Activate(x, y, oPanel)}
		EndIf

		nDATAF := GdFieldPos("TL_DTFIM")
		nDATGD := GdFieldPos("TL_DTINICI")
		nHORAI := GdFieldPos("TL_HOINICI")
		nHORAF := GdFieldPos("TL_HOFIM")

	Activate MsDialog oDlg ON INIT EnchoiceBar(@oDlg,{||nOpc := 2,IIf(MNT402VLD(cTRB402,aCposAlter),oDlg:End(),nOpc :=1)},{||nOpc := 1,oDlg:End()},,aButton)

	//Efetua a deleção das tabelas temporárias
	oTmpMrk:Delete()
	oTmpFil:Delete()

	NGRETURNPRM(aNGBEGINPRM)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MNTA402COR³ Autor ³Vitor Emanuel Batista ³ Data ³18/06/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Incrementa funcao para setar no STJ de acordo com o TRB    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aCores                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNTA402COR(cTRB402)
	Local aCores := NGCRIACOR()
	Local nX

	For nX := 1 to Len(aCores)
		aCores[nX][1] := 'NGIFDICIONA("STJ",xFilial("STJ")+'+cTRB402+'->TRB_ORDEM+'+cTRB402+'->TRB_PLANO,1) .And. ' + aCores[nX][1]
	Next nX

Return aCores

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTA490INV³ Autor ³Vitor Emanuel Batista  ³ Data ³18/06/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Inverte  marcacoes                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function MNTA402INV(cMARCA,cTRB402)
	Local nRecno

	dbSelectArea(cTRB402)
	nRecno := Recno()
	dbGoTop()
	While !Eof()
		(cTRB402)->TRB_OK := If(!Empty((cTRB402)->TRB_OK) ," ",cMARCA)
		dbSkip()
	EndDo

	DbGoTo(nRecno)
	lREFRESH := .T.
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ NGRETaNAO ³ Autor ³Vitor Emanuel Batista ³ Data ³18/06/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Retorna campos que nao irao aparecer no GetDados de Insumos ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aNAO                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function NGRETaNAO(aCposAlter)

	Local aSIM
	Local aNAO := {"TL_NOMSEQ", "TL_NOMTAR", "TL_NOMTREG", "TL_NOMLOCA"}
	Local nInd := 1
	Local cCampo := ""
	Local cPropri := ""
	Local aHeadSTL := {}

	//Campos visiveis no GetDados
	aSIM := {	"TL_TIPOREG", "TL_ETAPA"  , "TL_NOMETAP", ;
				"TL_CODIGO" , "TL_NOMCODI", "TL_USACALE", "TL_QUANREC" , "TL_QUANTID", ;
				"TL_UNIDADE", "TL_OBSERVA", "TL_DTINICI", If(NGCADICBASE('TL_PCTHREX','A','STL',.F.), "TL_PCTHREX", "TL_HREXTRA"), ;
				"TL_HOINICI", "TL_DTFIM"  , "TL_HOFIM"	, "TL_CUSTO"   , "TL_NUMSA"  , "TL_ITEMSA", "TL_NUMSC", "TL_ITEMSC" }

	If lMMoeda
		aAdd(aSim,"TL_MOEDA")
	EndIf

	aHeadSTL := NGHeader("STL")

	For nInd := 1 To Len(aHeadSTL)

		cCampo   := aHeadSTL[nInd,2]
		cPropri := Posicione("SX3",2,cCampo,"X3_PROPRI")

		If cPropri = 'U'
			aAdd(aCposAlter,cCampo)
		ElseIf aSCAN(aSIM, {|x| Trim(x) == Trim(cCampo) }) == 0
			aAdd(aNAO,Trim(cCampo))
		Endif

	Next nInd

Return aNAO

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CRIATRBOS ³ Autor ³Vitor Emanuel Batista ³ Data ³18/06/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Cria TRB e adiciona conteudo das O.S                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cTRB402 - Alias utilizada pelo oMark                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CRIATRBOS(aSTJ, cTRBTEMP, oTmpMrk, oTmpFil)

	Local nX
	Local cQuery
	Local cIniBrw
	Local cTJCpo  		:= ""
	Local aInd    		:= {}
	Local aCpoV   		:= {}
	Local aDBF    		:= {}
	Local cTRB402 		:= GetNextAlias()
	Local aIndSTJ		:= {}
	Local aCamposReal	:= {}

	//Retorna somente campos Visiveis no mBrowse
	Local aSTJVis := NGCAMPNSX3("STJ", {}, .T.)

	Default cTRBTEMP := GetNextAlias()

	aAdd(aSTJ, { "TRB_OK", Nil, " ",})

	aAdd(aDBF, { "TRB_OK", "C" ,02, 0,"" })
	aAdd(aDBF, { "TRB_ORDEM",  "C", Len(STJ->TJ_ORDEM),   0, "STJ->TJ_ORDEM"})
	aAdd(aDBF, { "TRB_PLANO",  "C", Len(STJ->TJ_PLANO),   0, "STJ->TJ_PLANO"})
	aAdd(aDBF, { "TRB_CODBEM", "C", Len(STJ->TJ_CODBEM),  0, "STJ->TJ_CODBEM"})
	aAdd(aDBF, { "TRB_SERVIC", "C", Len(STJ->TJ_SERVICO), 0, "STJ->TJ_SERVICO"})
	aAdd(aDBF, { "TRB_DTMPIN", "D", 8, 0, "STJ->TJ_DTMPINI"})

	dbSelectArea("SX3")
	dbSetOrder(2)
	For nX := 1 to Len(aSTJVis)
		dbSeek(aSTJVis[nX])
		aAdd(aDBF, {aSTJVis[nX], TamSX3(aSTJVis[nX])[3], TamSX3(aSTJVis[nX])[1], TamSX3(aSTJVis[nX])[2]})
		aAdd(aSTJ, {aSTJVis[nX], Nil, Trim(X3TITULO()) })

		If Posicione("SX3",2,aSTJVis[nX],"X3_CONTEXT") != 'V'
			//Adiciona campos na variavel campos utilizados pela Query
			cTJCpo += If(!Empty(cTJCpo), ", ", "")+aSTJVis[nX]
			aAdd(aCamposReal, aSTJVis[nX])
		Else
			//Adiciona na array campos Virtuais para serem carregados no TRB
			aAdd(aCpoV, aSTJVis[nX])
		EndIf
	Next nX

	aInd := {"TRB_ORDEM", "TRB_PLANO"}

	//TRB visivel no oMark
	oTmpMrk := FWTemporaryTable():New(cTRB402, aDBF)
	oTmpMrk:AddIndex("Ind01", aInd)
	oTmpMrk:Create()

	//TRB temporario para filtro
	oTmpFil := FWTemporaryTable():New(cTRBTEMP, aDBF)
	oTmpFil:AddIndex("Ind01", aInd)
	oTmpFil:Create()

	//Preenche a variavel cSerefor com todos os serviços do parametro MV_NGSEREF
	If !Empty(cSerefor)

		For nX := 1 To Len(aServRef)
			If nX == 1
				cSerefor := "'"+aServRef[nX]+"'"
			Else
				cSerefor += ",'"+aServRef[nX]+"'"
			EndIf
		Next nX

	Else

		//Garante que a aspas vão certas para a Query
		cSerefor := "' '"

	EndIf

	//Preenche a variavel cSercons com todos os serviços do parametro MV_NGSECON
	If !Empty(cSercons)

		For nX := 1 To Len(aServCon)
			If nX == 1
				cSercons := "'"+aServCon[nX]+"'"
			Else
				cSercons += ",'"+aServCon[nX]+"'"
			EndIf
		Next nX

	Else

		//Garante que a aspas vão certas para a Query
		cSercons := "' '"

	EndIf

	cQuery := " SELECT TJ_ORDEM AS TRB_ORDEM, TJ_PLANO AS TRB_PLANO, TJ_CODBEM AS TRB_CODBEM,"
	cQuery += "        TJ_SERVICO AS TRB_SERVIC,TJ_DTMPINI AS TRB_DTMPIN,"+cTJCpo
	cQuery += " FROM "+RetSqlName("STJ")
	cQuery += " WHERE TJ_FILIAL = '"+ xFilial("STJ")+"'"+" And "
	cQuery += "       TJ_LUBRIFI <> 'S' And TJ_TERMINO = 'N' And "
	cQuery += "       TJ_SITUACA = 'L'  And TJ_ORDEPAI = '" +  Space(Len(STJ->TJ_ORDEPAI)) + "' And"
	cQuery += "       TJ_SERVICO NOT IN ("+ cSerefor +","+ cSercons +") And"
	cQuery += "       D_E_L_E_T_ != '*'"
	cQuery += " ORDER BY TJ_ORDEM,TJ_PLANO"

	//Funcao que ira executar query e adicionar em uma TRB
	SqlToTrb(cQuery,aDBF,cTRB402)

	//Se existir campos virtuais, ira executar seu inicializador padrao
	If Len(aCpoV) > 0

		//Alterado INCLUI/ALTERA para funcionar VDISP
		SetAltera()

		dbSelectArea(cTRB402)
		dbGoTop()
		While !Eof()
			dbSelectArea("STJ")
			dbSetOrder(1)
			dbSeek(xFilial("STJ")+(cTRB402)->TRB_ORDEM+(cTRB402)->TRB_PLANO)
			For nX := 1 to Len(aCpoV)
				dbSelectArea("SX3")
				dbSetOrder(2)
				If dbSeek(aCpoV[nX])
					cIniBrw := &(Posicione("SX3",2,aCpoV[nX],"X3_INIBRW"))
					If ValType((cTRB402)->&(aCpoV[nX])) == ValType(cIniBrw)
						(cTRB402)->&(aCpoV[nX]) := cIniBrw
					EndIf
				EndIf
			Next nX

			dbSelectArea(cTRB402)
			dbSkip()
		EndDo

		//Retorna INCLUI/ALTERA
		SetInclui()
	EndIf

Return cTRB402

//----------------------------------------------------------------------------
/*/{Protheus.doc} MNT402LIOK
Verifica campos obrigatorios e faz diversas validacoes no GetDados de Insumos 

@return lRet  , Lógico  , Valor que verifica a integridade
@param  nPosAt, Numerico, Valor da linha atual do getdados. (oGet:nAt)

@sample
MNT402LIOK()

@author Vitor Emanuel Batista
@since 18/06/2009
@version 1.0
/*/
//----------------------------------------------------------------------------
Function MNT402LIOK(nPosAt)
	Local nX
	Local cMENSA  := ""
	Local lRet    := .T.
	Local nVEZIN

	Local nHORAF2 := GdFieldPos("TL_HOFIM")
	Local nDATAF2 := GdFieldPos("TL_DTFIM")
	Local nHORAI2 := GdFieldPos("TL_HOINICI")
	Local nDATAI2 := GdFieldPos("TL_DTINICI")
	Local nCODIG2 := GdFieldPos("TL_CODIGO")
	Local nTIPOI2 := GdFieldPos("TL_TIPOREG")

	aCols := oGet:aCols
	nVEZIN  := If(nPosAt == NIL,Len(aCols),nPosAt)

	Default nPosAt := 1

	For nX := nPosAt to nVEZIN
		If !aTail(aCOLS[nX])
			If Empty(GdFieldGet("TL_TIPOREG",nX))
				cMENSA := Trim(NGRetTitulo("TL_TIPOREG"))+STR0007 + Str(nX,3) //": Item  "
				Exit
			EndIf
			If Empty(GdFieldGet("TL_CODIGO",nX))
				cMENSA := Trim(NGRetTitulo("TL_CODIGO"))+STR0007 + Str(nX,3) //": Item  "
				Exit
			EndIf
			If Empty(GdFieldGet("TL_DTINICI",nX))
				cMENSA := Trim(NGRetTitulo("TL_DTINICI"))+STR0007 + Str(nX,3) //": Item  "
				Exit
			EndIf
			If Empty(GdFieldGet("TL_HOINICI",nX))
				cMENSA := Trim(NGRetTitulo("TL_HOINICI"))+STR0007 + Str(nX,3) //": Item  "
				Exit
			EndIf

			If Empty(GdFieldGet("TL_DTFIM",nX)) .Or. Empty(GdFieldGet("TL_HOFIM",nX))
				cMENSA := Trim(NGRetTitulo("TL_DTFIM"))+"/"+Trim(NGRetTitulo("TL_HOFIM"))+STR0032 + Str(nX,3) //": Item "
				Exit
			EndIf

			If lRet .And. !NGVDTINS(	GdFieldGet("TL_CODIGO",nX),GdFieldGet("TL_DTINICI",nX),GdFieldGet("TL_HOINICI",nX),;
			GdFieldGet("TL_DTFIM",nX),GdFieldGet("TL_HOFIM",nX),GdFieldGet("TL_TIPOREG",nX))
				lRet := .F.
			EndIf

			M->TL_TIPOREG := GdFieldGet("TL_TIPOREG",nX)
			M->TL_UNIDADE := GdFieldGet("TL_UNIDADE",nX)
			M->TL_QUANTID := GdFieldGet("TL_QUANTID",nX)
			M->TL_CODIGO  := GdFieldGet("TL_CODIGO",nX)
			M->TL_USACALE := GdFieldGet("TL_USACALE",nX)

			If lRet .And. !CHECKCOD(.T.,.F.,nX)
				lRet := .F.
			EndIf

			If lRet .And. !NGQUANTCHK(nX)
				lRet := .F.
			EndIf

			If lRet .And. !NGCHKMESFE(aCols[nX,nDATAI2],aCols[nX,nTIPOI2])
				lRet := .F.
			EndIf
		
			//Valida afastamentos da mao de obra no RH
			If lRet .And. aCOLS[nX][nTIPOI2] == 'M' .And. Empty(cMENSA) .And. !NGFRHAFAST(aCOLS[nX][nCODIG2],aCOLS[nX][nDATAI2],aCOLS[nX][nDATAF2],.T.)
				lRet := .F.
			EndIf

			If lRet .And. GdFieldGet("TL_DTFIM",nX) > dDataBase .Or. GdFieldGet("TL_DTINICI",nX) > dDataBase
				MsgStop(STR0035,STR0008) //"Data Início e Data Fim não poderão ser maiores que a data atual."
				lRet := .F.
			EndIf
			
			If lRet .And. !NGCHKSOBHR(nTIPOI2, nCODIG2, nDATAI2, nHORAI2, nDATAF2, nHORAF2, nPosAt)
				lRet := .F. //Mensagem de alerta internamente na função NGCHKSOBHR
			EndIf
			
			If !lRet
				Exit
			EndIf
		EndIf
	Next nX

	If !Empty(cMENSA)
		Help(1," ","OBRIGAT2",,cMENSA ,3,0)
		lRet := .F.
	EndIf

	dbSelectArea("STL")
	dbGoBottom()
	dbSkip()
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MNT402TUOK³ Autor ³Vitor Emanuel Batista  ³ Data ³18/06/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida se todos os dados na tela estao OK                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNT402TUOK(cTRB402,lFinal)
	Local lRet, nX
	Local lExistOS 	:= .T.
	Local aTRBArea 	:= (cTRB402)->(GetArea())
	Local aOS      	:= {}
	Local nQUANT2  	:= GdFieldPos("TL_QUANTID")
	Local cNGUNIDT	:= AllTrim(GetMv("MV_NGUNIDT"))

	//Valida Insumos
	lRet := MNT402LIOK()

	If lRet
		lRet := .F.
		dbSelectArea(cTRB402)
		dbGoTop()
		While !Eof()
			If !Empty((cTRB402)->TRB_OK)
				lRet := .T.
				aAdd(aOS,{(cTRB402)->TRB_ORDEM,(cTRB402)->TRB_PLANO})
				If NGFUNCRPO("NGRESPETAEX",.F.) .And. lFinal
					If !NGRESPETAEX((cTRB402)->TRB_ORDEM,.T.)
						RestArea(aTRBArea)
						Return .F.
					EndIf
				EndIf
			EndIf
			dbSkip()
		EndDo
		If !lRet
			ShowHelpDlg(STR0008,{STR0009},1,; //"ATENÇÃO"###"Não existem Ordens de Serviços selecionadas para o reporte."
			{STR0010},1) //"Selecione pelo menos uma Ordem de Serviço"
		EndIf
	EndIf

	If lRet
		lExistOS := .F.
		For nX := 1 to Len(aCols)
			If !aTail(aCols[nX])
				lExistOS := .T.

				nQuant := aCols[nX][nQUANT2]
				If cNGUNIDT != "D"
					nQuant := NGRETHORDDH(nQuant)[2]
				EndIf

				//Quantidade Tempo / Quantidade O.S
				nQuant := nQuant / Len(aOS)

				If nQuant < 0.01
					ShowHelpDlg(STR0008,{STR0011+Str(nX,3)+; //"ATENÇÃO"###"Nao é possível reportar Insumo da linha "
					STR0012},5,; //" pois dividindo-a entre as O.S's, resultaria em menos de 1 minuto para cada"
					{STR0013},5) //"Aumente a quantidade de Horas do insumo da linha informada ou diminua a quantidade de O.S's reportadas"
					lRet := .F.
				EndIf
			EndIf
		Next nX
	EndIf

	If !lExistOS
		ShowHelpDlg(STR0008,{STR0036},1,; //"Não há insumos para serem rateados."
		{STR0037},1) //"Informe pelo menos um insumo."
		lRet := .F.
	EndIf
	RestArea(aTRBArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MNTA402FIL³ Autor ³Vitor Emanuel Batista  ³ Data ³18/06/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cria filtro para as Ordens de Servico                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNTA402FIL(lFiltro,cTRB402,cTRBTEMP)

	Local nI        := 0
	Local nF        := 0
	Local nRecCount := 0
	Local aStruct   := {}
	Local cPerg     := "MNTA402"
	Local lMNTA4020 := ExistBlock( 'MNTA4020' )

	If Pergunte(cPerg,.T.)

		aStruct  := (cTRB402)->(dbStruct())
		nF			:= Len(aStruct)

		//Carrega TRB temporario com todas as O.S.
		//Processo feito somente na primeira vez da filtragem
		If !lFiltro
			nRecCount:= (cTRB402)->(RecCount())

			(cTRB402)->(dbGoTop())

			ProcRegua( nRecCount )

			While !(cTRB402)->(Eof())
				IncProc()
				(cTRBTEMP)->(DbAppend())
				For nI := 1 To nF
					If (cTRBTEMP)->(FieldPos(aStruct[nI,1])) > 0	 .And. aStruct[nI,2] <> 'M'
						(cTRBTEMP)->(FieldPut(FieldPos(aStruct[nI,1]),(cTRB402)->(FieldGet((cTRB402)->(FieldPos(aStruct[nI,1]))))))
					EndIf
				Next nI

				(cTRBTEMP)->TRB_OK := ""
				(cTRB402)->(dbSkip())
			EndDo

			dbSelectArea(cTRB402)
			ZAP

			lFiltro := .T.
		Else
			dbSelectArea(cTRB402)
			ZAP
		EndIf

		dbSelectArea(cTRBTEMP)
		dbGoTop()
		
		While !Eof()
			
			If (cTRBTEMP)->TRB_ORDEM  >= MV_PAR01 .And. (cTRBTEMP)->TRB_ORDEM  <= MV_PAR02 .And.;
				(cTRBTEMP)->TRB_PLANO  >= MV_PAR03 .And. (cTRBTEMP)->TRB_PLANO  <= MV_PAR04 .And.;
				(cTRBTEMP)->TRB_CODBEM >= MV_PAR05 .And. (cTRBTEMP)->TRB_CODBEM <= MV_PAR06 .And.;
				(cTRBTEMP)->TRB_SERVIC >= MV_PAR07 .And. (cTRBTEMP)->TRB_SERVIC <= MV_PAR08 .And.;
				(cTRBTEMP)->TRB_DTMPIN >= MV_PAR09 .And. (cTRBTEMP)->TRB_DTMPIN <= MV_PAR10

				If lMNTA4020 .And. !ExecBlock( 'MNTA4020', .F., .F., { cTRBTEMP } )

					dbSelectArea( cTRBTEMP )
					dbSkip()

					Loop

				EndIf

				(cTRB402)->(DbAppend())
				
				For nI := 1 To nF
					
					If (cTRB402)->(FieldPos(aStruct[nI,1])) > 0	 .And. aStruct[nI,2] <> 'M'
					
						(cTRB402)->(FieldPut(FieldPos(aStruct[nI,1]),(cTRBTEMP)->(FieldGet((cTRBTEMP)->(FieldPos(aStruct[nI,1]))))))
					
					EndIf

				Next nI

			EndIf
		
			dbSelectArea(cTRBTEMP)
			dbSkip()
		
		EndDo
	
	EndIf

	(cTRB402)->(dbGoTop())
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MNT402VLD ³ Autor ³Vitor Emanuel Batista  ³ Data ³18/06/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida para fazer retorno dos insumos                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNT402VLD(cTRB402,aCposAlter)
	Local lRet := .T.

	lRet := MNT402TUOK(cTRB402,.F.)
	If lRet
		Processa({ |lEnd| RETINSUMO(cTRB402,aCposAlter) },STR0024+STR0025) //"Aguarde... "###"Processando Insumos Ordem "
	EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} RETINSUMO
Retorna insumos nas O.S selecionadas

@type Function
@author Vitor Emanuel Batista
@since 18/06/2009
@version P12
@param cTRB402    - C - Tabela Temporária
       aCposAlter - A - Array de campo a alterar
@return
/*/
//--------------------------------------------------------
Static Function RETINSUMO(cTRB402,aCposAlter)
	Local nX, nY, nI, nTam
	Local nQuant, nPosCpo, nONDERL
	Local dDtIni
	Local cHrIni, cCAMIGUA, cCAMPSTL
	Local cCAMPSD3, cFILPOS3
	Local aDTHRFIM 	:= {}
	Local aOS      	:= {}
	Local aColsOS  	:= {}
	Local aColsGrv 	:= {} // Recebera somente registros nao excluidos
	Local lRet     	:= .F.
	Local lH100    	:= .F.
	Local lPctHrExt := NGCADICBASE('TL_PCTHREX','A','STL',.F.)
	Local lMMoeda 	:= NGCADICBASE("TL_MOEDA","A","STL",.F.)
	Local aCstMoeda := {}

	Local nTIPOI2  	:= GdFieldPos("TL_TIPOREG")
	Local nCODIG2  	:= GdFieldPos("TL_CODIGO")
	Local nUSACA2  	:= GdFieldPos("TL_USACALE")
	Local nQUANT2  	:= GdFieldPos("TL_QUANTID")
	Local nUNIDA2  	:= GdFieldPos("TL_UNIDADE")
	Local nDATAI2  	:= GdFieldPos("TL_DTINICI")
	Local nHORAI2  	:= GdFieldPos("TL_HOINICI")
	Local nDATAF2  	:= GdFieldPos("TL_DTFIM")
	Local nHORAF2  	:= GdFieldPos("TL_HOFIM")
	Local nCUSTO2  	:= GdFieldPos("TL_CUSTO")
	Local nOBSER2  	:= GdFieldPos("TL_OBSERVA")
	Local nDTVAL2  	:= GdFieldPos("TL_DTVALID")
	Local nMOEDA2  	:= GdFieldPos("TL_MOEDA")
	Local nQUANR2  	:= GdFieldPos("TL_QUANREC")
	Local nHREXTRA 	:= If(lPctHrExt,GdFieldPos("TL_PCTHREX"),GdFieldPos("TL_HREXTRA"))
	Local nEtapa   	:= GdFieldPos("TL_ETAPA")
	Local cNGUNIDT	:= AllTrim(GetMv("MV_NGUNIDT"))
	Local cPRODMNT	:= AllTrim(GetMv("MV_PRODMNT"))

	dbSelectArea(cTRB402)
	dbGoTop()
	While !Eof()
		If !Empty((cTRB402)->TRB_OK)
			aAdd(aOS,{(cTRB402)->TRB_ORDEM,(cTRB402)->TRB_PLANO})
		EndIf
		dbSkip()
	EndDo

	For nX := 1 to Len(aCols) // Percorre todas as posicoes do aCols
		If !aTail(aCols[nX]) // Se o registro do aCols nao estiver excluido
			aAdd(aColsGrv,aClone(aCols[nX])) // Adiciona os registros no aColsGrv
		EndIf
	Next nX // Proximo registro do aCols

	For nX := 1 to Len(aColsGrv)
		dDtIni := aColsGrv[nX][nDATAI2]
		cHrIni := MTOH(HTOM(aColsGrv[nX][nHORAI2]))
		nQuant := aColsGrv[nX][nQUANT2]

		If cNGUNIDT != "D"
			nQuant := NGRETHORDDH(nQuant)[2]
			lH100  := .T.
		EndIf

		//Quantidade Tempo / Quantidade O.S
		nQuant := nQuant / Len(aOS)

		If nQuant < 0.01
			ShowHelpDlg(STR0008,{STR0011+Str(nX,3)+; //"ATENÇÃO"###"Nao é possível reportar Insumo da linha "
			            STR0012},5,;                 //" pois dividindo-a entre as O.S's, resultaria em menos de 1 minuto para cada"
			            {STR0013},5)                 //"Aumente a quantidade de Horas do insumo da linha informada ou diminua a quantidade de O.S's reportadas"
			Return .F.
		EndIf

		If lH100
			nQuant := NGRHODSEXN(nQuant,"D")
		EndIf

		For nY := 1 to Len(aOS)
			aAdd(aColsOS,aClone(aColsGrv[nX]))
			nTam := Len(aColsOS)

			aDTHRFIM := CalcDtHrFim(@dDtIni,@cHrIni,nQuant,aColsOS[nX][nCODIG2],aColsOS[nTam][nUSACA2])

			//O TJ_ORDEM e TJ_PLANO estão na ultima posicao
			aAdd(aColsOS[nTam],aOS[nY])

			//Altera quantidade ja dividida entre as O.S
			aColsOS[nTam][nQUANT2] := nQuant

			//Data e Hora Inicio
			aColsOS[nTam][nDATAI2] := dDtIni
			aColsOS[nTam][nHORAI2] := cHrIni

			//Data e Hora Fim
			aColsOS[nTam][nDATAF2] := aDTHRFIM[1]
			aColsOS[nTam][nHORAF2] := aDTHRFIM[2]

			dDtIni := aDTHRFIM[1]
			cHrIni := aDTHRFIM[2]
		Next nY
	Next nX

	Begin Transaction
		ProcRegua( Len(aColsOS) )
		For nX := 1 to Len(aColsOS)
			IncProc()
			dbSelectArea("STJ")
			dbSetOrder(1)
			If dbSeek(xFilial("STJ")+aColsOS[nX][Len(aColsOS[nX])][1]+aColsOS[nX][Len(aColsOS[nX])][2])
				cTIPOMAN := If(Val(STJ->TJ_PLANO) == 0,"C","P")
				If !NGRETINS(STJ->TJ_ORDEM       ,; //PORDEM
					         STJ->TJ_PLANO       ,; //PPLANO
					         cTIPOMAN            ,; //PTIPO
					                             ,; //PCODBEM
					                             ,; //PSERVICO
					                             ,; //PSEQ
					         '0'                 ,; //PTAREFA
					         aColsOS[nX][nTIPOI2],; //PTIPOINS
					         aColsOS[nX][nCODIG2],; //PCODIGO
					         aColsOS[nX][nQUANT2],; //PQUANTID
					         aColsOS[nX][nUNIDA2],; //PUNIDADE
					                             ,; //PDESTINO
					         STR0026             ,; //PDESCRIC //"Consumo"
					         aColsOS[nX][nDATAI2],; //PDATAINI
					         aColsOS[nX][nHORAI2],; //PHORAINI
					         "F"                 ,; //PGERAFES
					                             ,; //PLOCAL
					                             ,; //PLOTEC
					                             ,; //PNUMLOTE
					                             ,; //PDTVALID
					                             )  //PLOCALIZ
					DisarmTransaction()
					Break
				EndIf

				RecLock("STL",.F.)
				STL->TL_DTFIM   := aColsOS[nX][nDATAF2]
				STL->TL_HOFIM   := aColsOS[nX][nHORAF2]
				STL->TL_GARANTI := "N"
				STL->TL_USACALE := If(aColsOS[nX][nUSACA2] == "S","S","N")
				STL->TL_TIPOHOR := If(STL->TL_USACALE = "S","S",cNGUNIDT)
				If lPctHrExt
					STL->TL_PCTHREX := aColsOS[nX][nHREXTRA]
				Else
					STL->TL_HREXTRA := aColsOS[nX][nHREXTRA]
				EndIf

				If cUSAINT3 == 'N'
					STL->TL_CUSTO := If(nCUSTO2 > 0,aColsOS[nX][nCUSTO2] / Len(aOS),0)
					If lMMoeda
						STL->TL_Moeda := If(nMOEDA2 > 0,aColsOS[nX][nMOEDA2],"1")
					EndIf
				Else
					If lMMoeda .And. FindFunction("NGCALCUSMD")
						aCstMoeda := NGCALCUSMD(STL->TL_CODIGO,STL->TL_TIPOREG,STL->TL_QUANTID,STL->TL_LOCAL,STL->TL_TIPOHOR,,,STL->TL_QUANREC)
						STL->TL_CUSTO := aCstMoeda[1]
						STL->TL_MOEDA := aCstMoeda[2]
					Else
						STL->TL_CUSTO := NGCALCUSTI(STL->TL_CODIGO,STL->TL_TIPOREG,STL->TL_QUANTID,STL->TL_LOCAL,STL->TL_TIPOHOR,,,STL->TL_QUANREC)
						If lMMoeda
							STL->TL_MOEDA := "1"
						EndIf
					EndIf
				EndIf

				STL->TL_OBSERVA := aColsOS[nX][nOBSER2]
				If STL->TL_TIPOREG <> "P"
					STL->TL_DTFIM := aColsOS[nX][nDATAF2]
					STL->TL_HOFIM := aColsOS[nX][nHORAF2]
				EndIf

				STL->TL_QUANREC := If(nQUANR2 > 0,aColsOS[nX][nQUANR2],"0")
				STL->TL_ETAPA   := aColsOS[nX][nEtapa]

				MsUnlock("STL")

				If Len(aCposAlter) > 0
					RecLock("STL",.F.)
					For nI := 1 To Len(aCposAlter)
						nPosCpo := GdFieldPos(aCposAlter[nI])
						If nPosCpo > 0
							STL->(FieldPut(FieldPos(aCposAlter[nI]),aColsOS[nX][nPosCpo]))
						EndIf
					Next nI
					MsUnLock("STL")
				EndIf

				If cUsaInt3 == 'S'
					dbSelectArea("SD3")
					dbSetOrder(4)
					If Dbseek(xFilial("SD3")+STL->TL_NUMSEQ)
						For nI := 1 To Len(aCposAlter)
							nONDERL := At("_",aCposAlter[nI])
							If nONDERL > 0
								cCAMIGUA := Alltrim(Substr(aCposAlter[nI],nONDERL+1,Len(aCposAlter[nI])))
								cCAMPSTL := "STL->TL_"+cCAMIGUA
								cCAMPSD3 := "SD3->D3_"+cCAMIGUA
								cFILPOS3 := "D3_"+cCAMIGUA
								If FieldPos(cFILPOS3) > 0
									RecLock("SD3",.F.)
									&cCAMPSD3 := &cCAMPSTL
									MsUnLock("SD3")
								EndIf
								If AllTrim(SD3->D3_COD) <> cPRODMNT
									NGAtuErp("SD3","UPDATE")
								EndIf
							EndIf
						Next nI
						//-------------------------------------
						//INTEGRACAO POR MENSAGEM UNICA
						//-------------------------------------
						If AllTrim(GetNewPar("MV_NGINTER","N")) == "M"  //Mensagem Unica
							If SubStr(SD3->D3_CF,1,2) == "RE"//
								NGMUStoTuO(SD3->(RecNo()),"SD3")
							Else
								NGMUCanReq(SD3->(RecNo()),"SD3")
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		Next nX
	End Transaction

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³NG402FIM  ³ Autor ³Vitor Emanuel Batista  ³ Data ³20/06/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Finaliza as Ordens de Servicos                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function NG402FIM(cTRB402,aCposAlter)
	Local aBEMCX := {}
	Local lFINAL := .F.
	Local pi,yx, x
	Local lCONT1
	Local lCONT2
	Local aTRBArea := (cTRB402)->(GetArea())
	Local aARRAYOS := {}

	If MNT402TUOK(cTRB402,.T.)
		If !MsgYesNo(STR0027,STR0008) //"Deseja finalizar as O.S selecionadas?"###"ATENÇÃO"
			Return .F.
		EndIf

		lFINAL := .T.
		dbSelectArea(cTRB402)
		dbGoTop()
		While !Eof()
			If !Empty((cTRB402)->TRB_OK)
				If cUsaInt3 == 'S'
					dbSelectArea("SC2")
					dbSetOrder(1)
					If !dbSeek(xFilial("SC2")+(cTRB402)->TRB_ORDEM+'OS001')
						MsgInfo(STR0028+(cTRB402)->TRB_ORDEM+STR0029,STR0008) //"A Ordem de Servico "###" nao podera ser finalizada, pois não existe Ordem do Producao para a mesma"
						Return .F.
					EndIf
				EndIf

				dbSelectArea("STJ")
				dbSetOrder(1)
				dbSeek(xFilial("STJ")+(cTRB402)->TRB_ORDEM+(cTRB402)->TRB_PLANO)

				cBEMRET := Space(Len(STJ->TJ_CODBEM))
				cBEMRET := NGTBEMPAI(STJ->TJ_CODBEM,cBEMRET)
				cBEMRET := If(Empty(cBEMRET),STJ->TJ_CODBEM,cBEMRET)

				nPOS := Ascan(aBEMCX,{|x| x[1] = cBEMRET})
				lCONT1 := .F.
				lCONT2 := .F.
				If nPOS = 0
					cTIPOCON := " "
					cTIPOCON := NGSEEK("ST9",cBEMRET,1,"T9_TEMCONT")
					lCONT1 := cTIPOCON == "S"

					dbSelectArea("TPE")
					dbSetOrder(01)
					If dbSeek(xFilial("TPE")+cBEMRET)
						lCONT2 := .T.
					EndIf
					cBEMFIM := cBEMRET
					Aadd(aBEMCX,{cBEMFIM,lCONT1,lCONT2})
					nINCRE := Len(aBEMCX)
				Else
					nINCRE    := nPOS
					cBEMFIM   := aBEMCX[nINCRE][1]
					lCONT1    := aBEMCX[nINCRE][2]
					dbSelectArea("TPE")
					dbSetOrder(1)
					If dbSeek(xFilial("TPE")+cBEMRET)
						lCONT2 := .T.
					EndIf
				EndIf

				aAdd(aARRAYOS,{(cTRB402)->TRB_ORDEM,; //[1] ORDEM
				Ctod("  /  /  "),;		//[2] DT PARADA INICIO
				Ctod("  /  /  "),;		//[3] DT PARADA FIM
				Space(5),;					//[4] HORA PARADA INICIO
				Space(5),;					//[5] HORA PARADA FIM
				0,;							//[6] CONTADOR 1
				Space(5),;					//[7] HORA CONTADOR 1
				0,;							//[8] CONTADOR 2
				Space(5),;					//[9] HORA CONTADOR 2
				Ctod("  /  /  "),;		//[10] DT REAL FINAL
				lCONT1,;						//[11] TEM CONTADOR 1
				lCONT2,;						//[12] TEM CONTADOR 2
				cBEMFIM,;					//[13] BEM CONTADOR
				(cTRB402)->TRB_PLANO,;	//[14] PLANO
				Space(3)})					//[15] IRREGULARIDADE
			EndIf
			dbSelectArea(cTRB402)
			dbSkip()
		EndDo

		For yx := 1 To Len(aARRAYOS)
			If FindFunction("NGVLDSTL") .And. !NGVLDSTL(aARRAYOS[yx][1]) // verifica se não existe insumo com data e hora inicial igual a data e hora final
				lFinal := .F.
				Exit
			EndIf
			
			//-----------------------------------------------------------
			// Verifica se não há pneus aguardando aplicação
			//-----------------------------------------------------------
			If lFinal .And. FindFunction( 'MNTVLDFIN' ) .And. !MNTVLDFIN( aARRAYOS[yx][1] )[1]
				lFinal := .F.
				Exit
			EndIf

		Next yx

		If lFinal
			For yx := 1 To Len(aARRAYOS)
				If !NG402FICAD(yx,aARRAYOS)
					lFINAL := .F.
					Exit
				EndIf
				If !lFINAL
					Exit
				EndIf
			Next yx
		EndIf

		If lFINAL // grava inumos STL etc..
			Processa({ |lEnd| RETINSUMO(cTRB402,aCposAlter) },STR0024+STR0025) //"Aguarde... "###"Processando Insumos Ordem "
			Processa({ |lEnd| MNT402FIM(aARRAYOS) },STR0024+STR0030) //"Aguarde... "###"Finalizando Ordem "
		EndIf
	EndIf

	RestArea(aTRBArea)
Return lFINAL


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³NG402FICAD³ Autor ³Vitor Emanuel Batista  ³ Data ³20/06/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta tela de finalizacao de O.S                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ True/False                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function NG402FICAD(nINCRE,aARRAYOS)
	Local xm := 0
	Local oDlg
	Local lRet := .F.
	Local hHOREAL := "  :  "

	Local M->TJ_HOPRINI := Space(5)
	Local M->TJ_HOPRFIM := Space(5)
	Local M->TJ_DTPRFIM := Ctod("  /  /  ")
	Local M->TJ_DTPRINI := Ctod("  /  /  ")

	Local nDATAF2 := GdFieldPos("TL_DTFIM")
	Local nHORAF2 := GdFieldPos("TL_HOFIM")
	Local cEquipment := aARRAYOS[nINCRE,13]
	Local lOpenCnt:= NGBlCont( cEquipment ) // se campo contador ficará aberto

	//Utilizadas no MNTA415
	Private cNIRREGU   := SPACE(40)
	Private cTENDFLAHA := AllTrim(GETMv("MV_NGTNDFL"))
	Private lLECON1    := aARRAYOS[nINCRE][11]
	Private lLECON2    := aARRAYOS[nINCRE][12]

	M->TJ_IRREGU  := SPACE(3)
	M->TJ_DTMRFIM := Ctod("  /  /  ")
	M->TJ_POSCONT := 0
	M->TJ_POSCON2 := 0
	M->TJ_HORACO1 := '  :  '
	M->TJ_HORACO2 := '  :  '

	If lLECON1 .Or. lLECON2
		hHOREAL := "00:01"
		For xm := 1 To Len(aCols)
			If aCols[xm][nDATAF2] > M->TJ_DTMRFIM
				M->TJ_DTMRFIM := aCols[xm][nDATAF2]
				hHOREAL := aCols[xm][nHORAF2]
			ElseIf aCols[xm][nDATAF2] = M->TJ_DTMRFIM
				hREAL1  := HtoM(hHOREAL)
				hREAL2  := HtoM(aCols[xm][nHORAF2])
				hMAXIMA := MAX(hREAL1,hREAL2)
				hHOREAL := MtoH(hMAXIMA)
			EndIf
		Next xm

		If lLECON1
			M->TJ_HORACO1 := hHOREAL
			M->TJ_POSCONT := NGACUMEHIS( cEquipment, M->TJ_DTMRFIM, M->TJ_HORACO1, 1, "A" )[1]
		EndIf

		If lLECON2
			M->TJ_HORACO2 := hHOREAL
			M->TJ_POSCON2 := NGACUMEHIS( cEquipment, M->TJ_DTMRFIM, M->TJ_HORACO2, 2, "A" )[1]
		EndIf

	EndIf

	dbSelectArea("STJ")
	dbSetOrder(1)
	dbSeek(xFilial("STJ")+aARRAYOS[nINCRE][1]+aARRAYOS[nINCRE][14])

	nOpca := 0
	Define MsDialog oDlg Title STR0031 From 12,10 To 28,70 Of oMainWnd COLOR CLR_BLACK,CLR_WHITE //"Retorno de Manutencao - Final"
	oDlg:lEscClose  := .F.

	@ 34,018 SAY OemToAnsi(NGRETTITULO("TJ_ORDEM")) SIZE 47,07 OF oDLG PIXEL Color CLR_HBLUE
	@ 34,050 MSGET aARRAYOS[nINCRE][1] SIZE 38,08 OF oDLG PIXEL When .F.

	@ 46,018 SAY OemToAnsi(NGRETTITULO("TJ_POSCONT")) SIZE 47,07 OF oDLG PIXEL
	@ 46,050 MSGET M->TJ_POSCONT SIZE 38,08 OF oDLG PIXEL PICTURE '999999999';
	Valid MNTA415CO(aARRAYOS[nINCRE][1],M->TJ_POSCONT,1) When lLECON1 .And. lOpenCnt

	@ 46,132 SAY OemToAnsi(NGRETTITULO("TJ_HORACO1")) SIZE 47,07 OF oDLG PIXEL
	@ 46,164 MSGET M->TJ_HORACO1 SIZE 38,08 OF oDLG PIXEL PICTURE "99:99";
	VALID If(!Empty(M->TJ_POSCONT),NGVALHORA(M->TJ_HORACO1,.T.) .And. ;
	fCounter( nINCRE, aARRAYOS, 1, lOpenCnt, cEquipment ),.T.) When lLECON1

	@ 58,018 SAY OemToAnsi(NGRETTITULO("TJ_DTPRINI")) SIZE 47,07 OF oDLG PIXEL
	@ 58,050 MSGET M->TJ_DTPRINI SIZE 38,08 OF oDLG PIXEL PICTURE '99/99/99' HASBUTTON

	@ 58,132 SAY OemToAnsi(NGRETTITULO("TJ_HOPRINI")) SIZE 47,07 OF oDLG PIXEL
	@ 58,164 MSGET M->TJ_HOPRINI SIZE  38,08 OF oDLG PIXEL PICTURE "99:99" VALID NGVALHORA(M->TJ_HOPRINI,.T.)

	@ 70,018 SAY OemToAnsi(NGRETTITULO("TJ_DTPRFIM")) SIZE 47,07 OF oDLG PIXEL
	@ 70,050 MSGET M->TJ_DTPRFIM SIZE 38,08 OF oDLG PIXEL PICTURE '99/99/99' VALID (M->TJ_DTPRFIM >= M->TJ_DTPRINI) HASBUTTON

	@ 70,132 SAY OemToAnsi(NGRETTITULO("TJ_HOPRFIM")) SIZE 47,07 OF oDLG PIXEL
	@ 70,164 MSGET M->TJ_HOPRFIM SIZE 38,08 OF oDLG PIXEL PICTURE "99:99" VALID NGVALHORA(M->TJ_HOPRFIM,.T.) .AND.;
	COMPDATA(M->TJ_DTPRINI,M->TJ_HOPRINI,M->TJ_DTPRFIM,M->TJ_HOPRFIM)

	@ 82,018 SAY OemToAnsi(NGRETTITULO("TJ_POSCON2")) SIZE 47,07 OF oDLG PIXEL
	@ 82,050 MSGET M->TJ_POSCON2 SIZE 38,08 OF oDLG PIXEL PICTURE '999999999';
	Valid MNTA415CO(aARRAYOS[nINCRE][1],M->TJ_POSCON2,2) When lLECON2 .And. lOpenCnt

	@ 82,132 SAY OemToAnsi(NGRETTITULO("TJ_HORACO2")) SIZE 47,07 OF oDLG PIXEL
	@ 82,164 MSGET M->TJ_HORACO2 SIZE 38,08 OF oDLG PIXEL PICTURE "99:99";
	VALID If(!Empty(M->TJ_POSCON2),NGVALHORA(M->TJ_HORACO2,.T.) .And. ;
	fCounter( nINCRE, aARRAYOS, 2, lOpenCnt, cEquipment ),.T.) When lLECON2	

	@ 94,018 SAY OemToAnsi(NGRETTITULO("TJ_DTMRFIM")) SIZE 47,07 OF oDLG PIXEL
	@ 94,050 MSGET M->TJ_DTMRFIM  SIZE 38,08 OF oDLG PIXEL PICTURE '99/99/99' When .F. HASBUTTON

	//FORCA A DIGITACAO DA IRREGULARIDADE
	If cTENDFLAHA != "N" .And. aARRAYOS[nINCRE][14] == "000000" //O.S Corretiva
		If cTENDFLAHA == "S"
			@ 106,018 SAY OemToAnsi(NGRETTITULO("TJ_IRREGU")) SIZE 47,07 OF oDLG PIXEL Color CLR_HBLUE
		Else
			@ 106,018 SAY OemToAnsi(NGRETTITULO("TJ_IRREGU")) SIZE 47,07 OF oDLG PIXEL
		EndIf
		@ 106,050 MSGET M->TJ_IRREGU SIZE 38,7 OF oDLG PIXEL Picture '@!' Valid MNT402TP7() F3 "TP7" HASBUTTON
		@ 106,089 MSGET cNIRREGU SIZE 114,7 OF oDLG PIXEL Picture '@!' When .F.
	EndIf

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,IF(!ConsFinal( nINCRE, aARRAYOS, cEquipment ),nOpca:=2,oDlg:End())},{||oDlg:End()}) CENTERED

	If nOpca = 1
		aARRAYOS[nINCRE][2]  := M->TJ_DTPRINI	// dt.parada inicio
		aARRAYOS[nINCRE][3]  := M->TJ_DTPRFIM	// dt.parada fim
		aARRAYOS[nINCRE][4]  := M->TJ_HOPRINI	// hora parada inicio
		aARRAYOS[nINCRE][5]  := M->TJ_HOPRFIM	// hora parada fim
		aARRAYOS[nINCRE][6]  := M->TJ_POSCONT	// contador 1
		aARRAYOS[nINCRE][7]  := M->TJ_HORACO1	// hora cont. 1
		aARRAYOS[nINCRE][8]  := M->TJ_POSCON2	// contador 2
		aARRAYOS[nINCRE][9]  := M->TJ_HORACO2	// hora cont. 2
		aARRAYOS[nINCRE][10] := M->TJ_DTMRFIM	// dt real final
		aARRAYOS[nINCRE][15] := M->TJ_IRREGU	// irregularidade
		lRet := .T.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ConsFinal
Consistência na finalizacão da O.S.

@author Vitor Emanuel Batista
@since 22/06/2009
@param nX, numérico, posição no array de ordens
@param aARRAYOS, array, ordens de serviço selecionadas
@return lógico, se as informações são válidas
/*/
//-------------------------------------------------------------------
Static Function ConsFinal( nX, aARRAYOS, cEquipment )

	If aARRAYOS[nX][11] .And. !Empty(M->TJ_POSCONT)
		If !NGCHKHISTO(aARRAYOS[nX][13],M->TJ_DTMRFIM,M->TJ_POSCONT,M->TJ_HORACO1,1,,.T.)
			Return .F.
		EndIf
		If !NGVALIVARD(aARRAYOS[nX][13],M->TJ_POSCONT,M->TJ_DTMRFIM,M->TJ_HORACO1,1,.T.)
			Return .F.
		EndIf

		If !fValidCnt( nX, aARRAYOS, 1, cEquipment )//Validação para não permitir 2 apontamentos de contador com mesma hora
			Return .F.
		EndIf
	EndIf

	If aARRAYOS[nX][12] .And. !Empty(M->TJ_POSCON2)
		If !NGCHKHISTO(aARRAYOS[nX][13],M->TJ_DTMRFIM,M->TJ_POSCON2,M->TJ_HORACO2,2,,.T.)
			Return .F.
		EndIf
		If !NGVALIVARD(aARRAYOS[nX][13],M->TJ_POSCON2,M->TJ_DTMRFIM,M->TJ_HORACO2,2,.T.)
			Return .F.
		EndIf

		If !fValidCnt( nX, aARRAYOS, 2, cEquipment )//Validação para não permitir 2 apontamentos de contador com mesma hora
			Return .F.
		EndIf
	EndIf

	//FORCA A DIGITACAO DA IRREGULARIDADE
	If cTENDFLAHA == "S" .And. STJ->TJ_PLANO == "000000" //os corretiva
		If Empty(M->TJ_IRREGU)
			MsgInfo( STR0038,STR0008) //'Obrigatorio informar o Codigo da Irregularidade.'
			Return .F.
		EndIf
	EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MNT402FIM ³ Autor ³Vitor Emanuel Batista  ³ Data ³22/06/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processa finalizacao de O.S                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNT402FIM(aARRAYOS)
	Local xy := 0
	Local lSTJAchou, lINCLUI

	ProcRegua(Len(aARRAYOS))
	Begin Transaction
		For xy := 1 to len(aARRAYOS)
			IncProc(OemToAnsi(STR0030+aARRAYOS[xy][1])) //"Finalizando Ordem "
			dbSelectArea("STJ")
			dbSetOrder(1)
			dbSeek(xFilial("STJ")+aARRAYOS[xy][1]+aARRAYOS[xy][14])

			If aARRAYOS[xy][11] .Or. aARRAYOS[xy][12] //Tem Contador 1 ou 2

				dbSelectArea("STJ")
				RecLock("STJ",.F.)
				STJ->TJ_POSCONT := aARRAYOS[xy][6]	//Contador 1
				STJ->TJ_HORACO1 := aARRAYOS[xy][7]	//Hora Cont 1
				STJ->TJ_POSCON2 := aARRAYOS[xy][8]	//Contador 2
				STJ->TJ_HORACO2 := aARRAYOS[xy][9]	//Hora Cont 2
				STJ->TJ_IRREGU  := aARRAYOS[xy][15]//Irregularidade
				cACODBEM := STJ->TJ_CODBEM
				MsUnlock("STJ")

				NGFINAL(	aARRAYOS[xy][1],aARRAYOS[xy][14],aARRAYOS[xy][2],aARRAYOS[xy][4],;
				aARRAYOS[xy][3],aARRAYOS[xy][5],aARRAYOS[xy][6],aARRAYOS[xy][8],;
				aARRAYOS[xy][13],aARRAYOS[xy][7],aARRAYOS[xy][9])
			Else
				dbSelectArea("STJ")
				RecLock("STJ",.F.)
				STJ->TJ_IRREGU  := aARRAYOS[xy][15] //Irregularidade
				cACODBEM := STJ->TJ_CODBEM
				MsUnlock("STJ")

				NGFINAL(	aARRAYOS[xy][1],aARRAYOS[xy][14],aARRAYOS[xy][2],aARRAYOS[xy][4],;
				aARRAYOS[xy][3],aARRAYOS[xy][5],aARRAYOS[xy][6],aARRAYOS[xy][8])
			EndIf

			//---------------------------------------------------
			lSTJAchou  := A415STJBUS(cACODBEM)

			dbSelectArea("ST9")
			dbSetOrder(1)

			If dbSeek(xFilial("ST9")+cACODBEM)
				RecLock("ST9",.F.)

				If lSTJAchou = .F.
					ST9->T9_TERCEIR := "1"
				EndIf

				MsUnlock("ST9")
			EndIf
			//---------------------------------------------------

			dbSelectArea("STJ")
			dbSetOrder(1)
			dbSeek(xFilial("STJ")+aARRAYOS[xy][1])

			//Fechamento de solicitacao de servico
			//Redifinicao da variavel de controle para manipulacao do fechamento do solicitacao de servico
			lINCLUI  := INCLUI
			INCLUI   := .F.

			NGFECHASS(aARRAYOS[xy][1])
			INCLUI := lINCLUI
		Next xy
	End Transaction
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CalcDtHrFim³Autor ³Vitor Emanuel Batista  ³ Data ³10/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula data hora fim para o insumo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ {Data Fim,Hora Fim}                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CalcDtHrFim(dDtIni,cHrIni,nQuant,cCodigo,cUsaCalen)
	Local aCalend
	Local nDiaSem, nPos, nX

	//Se o insumo utilizar calendario
	If cUsaCalen == "S"
		NGIFDICIONA("ST1",xFilial("ST1")+cCodigo,1)
		aDTHRFIM  := NGDTHORFCALE(dDtIni,cHrIni,nQuant,ST1->T1_TURNO)

		//Se hora fim nao foi encontrada, verifica calendario
		If AllTrim(aDTHRFIM[2]) == ":"
			aCalend   := NGCALENDAH(ST1->T1_TURNO)
			nDiaSem   := Dow(dDtIni)
			nPos      := aScan(aCalend[nDiaSem][2], {|aArray| aArray[2] == cHrIni })
			If nPos > 0
				//Se existe outro horario possivel no mesmo dia
				If Len(aCalend[nDiaSem][2]) > nPos
					cHrIni := aCalend[nDiaSem][2][nPos+1][1]
					Return CalcDtHrFim(@dDtIni,@cHrIni,nQuant,cCodigo,cUsaCalen)
				Else //Senao ira para o proximo dia
					If Len(aCalend) > nDiaSem
						For nX := nDiaSem+1 to Len(aCalend)
							If Len(aCalend[nX][2]) > 0
								dDtIni := dDtIni + (nX - nDiaSem)
								cHrIni := aCalend[nX][2][1][1]
								Return CalcDtHrFim(@dDtIni,@cHrIni,nQuant,cCodigo,cUsaCalen)
							EndIf
						Next nX
					EndIf
					//Se os proximos dias nao foram encontrados, volta pro primeiro dia da semana ate achar
					//If !lNovaDtHr
					For nX := 1 to Len(aCalend)
						If Len(aCalend[nX][2]) > 0
							dDtIni := dDtIni + (7 - nDiaSem) + nX
							cHrIni := aCalend[nX][2][1][1]
							Return CalcDtHrFim(@dDtIni,@cHrIni,nQuant,cCodigo,cUsaCalen)
						EndIf
					Next mX
					//EndIf
				EndIf
			EndIf
		EndIf
	Else
		aDTHRFIM := NGDTHORFIM(dDtIni,cHrIni,nQuant)
	EndIf

Return aDTHRFIM

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT402TP7
Consistência do campo Irregularidade

@author Maicon André Pinheiro.
@since	11/03/2016
@return True
/*/
//---------------------------------------------------------------------
Function MNT402TP7()

	If Empty(M->TJ_IRREGU)
		cNIRREGU := Space( TAMSX3("TP7_NOME")[1] )
	ElseIf !EXISTCPO("TP7",M->TJ_IRREGU)
		cNIRREGU := Space( TAMSX3("TP7_NOME")[1] )
		Return .F.
	EndIf

	cNIRREGU := Posicione("TP7",1,xFilial("TP7")+M->TJ_IRREGU,"TP7_NOME")
Return .T.

//--------------------------------------------------------------------------
/*/{Protheus.doc} fValidCnt
Não permite ter dois apontamentos de contador para o mesmo bem + data + hora

@author Maria Elisandra de Paula
@since 16/08/2019
@param nX, numérico, posição no array
@param aARRAYOS, array, ordens de serviço selecionadas
@param nType, numérico, tipo de contador: 1 ou 2
@param cEquipment, string, código do bem
@return lógico, se ok
/*/
//--------------------------------------------------------------------------
Static Function fValidCnt( nX, aARRAYOS, nType, cEquipment )

	Local lRet := .T.
	Local cHourVld := IIF( nType == 1, M->TJ_HORACO1, M->TJ_HORACO2 ) //Conteúdo do campo hora contador
	Local nPosCnt  := IIF( nType == 1, 7, 9 ) //posição da hora contador

	If nX > 1 .And. aScanX( aARRAYOS ,{|x,y| x[13] == cEquipment ; // mesmo bem
		.And. x[10] == M->TJ_DTMRFIM ; // mesma data
		.And. x[nPosCnt] == cHourVld ; // mesma hora
		.And. y <> nX },; //não validar com ele mesmo
		1,nX -1 ) > 0 //irá buscar apenas nas posições anteriores

		MsgInfo( STR0039 + ' ' + cValtoChar( nType ), 'NAO CONFORMIDADE' ) //'Já existe uma ordem sendo finalizada para este bem com a mesma data e hora para o contador'
		lRet := .F.
	EndIf

Return lRet

//--------------------------------------------------------------------------
/*/{Protheus.doc} fCounter
Atualiza campo contador quando está fechado
Valida campo contador

@author Maria Elisandra de Paula
@since 16/08/2019
@param nINCRE, numérico, posição no array
@param aRRAYOS, array, ordens de serviço selecionadas
@param nType, numérico, tipo de contador: 1 ou 2
@param lOpenCnt, se campo contador está aberto para edição
@param cEquipment, string, código do bem
@return lógico, se ok
/*/
//--------------------------------------------------------------------------
Static Function fCounter( nINCRE, aARRAYOS, nType, lOpenCnt, cEquipment )

	Local lRet := .T.

	//-----------------------------------------------
	//Atualiza campo contador quando está fechado
	//-----------------------------------------------
	If !lOpenCnt .And. nType == 1
		M->TJ_POSCONT := NGACUMEHIS( cEquipment, M->TJ_DTMRFIM, M->TJ_HORACO1, 1, "A" )[1]
	EndIf

	If !lOpenCnt .And. nType == 2	
		M->TJ_POSCON2 := NGACUMEHIS( cEquipment, M->TJ_DTMRFIM, M->TJ_HORACO2, 2, "A" )[1]
	EndIf

	lRet := fValidCnt( nINCRE, aARRAYOS, nType, cEquipment )

Return lRet
