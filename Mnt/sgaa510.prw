#INCLUDE "SGAA510.ch"
#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSGAA510   บAutor  ณRoger Rodrigues     บ Data ณ  17/03/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de Logistica de Retirada de  FMR - Fichas de		 	  บฑฑ
ฑฑบ          ณMovimenta็ใo de Residuos	       							  		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGASGA                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SGAA510(aFiltroFmr)

	Local aNGBEGINPRM	 := NGBEGINPRM()
	Local cFilter510  := "TDC_STATUS <> '7'"

	If Amiin(56) //Verifica se o usuแrio possui licen็a para acessar a rotina.

	Private lAleat	 := .F.//Variavel de Filtro
	Private aRotina	 := MenuDef()
	Private cCadastro := OemToAnsi(STR0001) //"Logํstica de Retirada"

	//Verifica se o Update de FMR esta aplicado
	If !SGAUPDFMR()
		Return .F.
	Endif

	dbSelectArea("TDC")
	If !Empty(aFiltroFmr) //Array passado por parametro, utilizado pelo TNGPG
		cFilter510 += " And " + BuildFilter(aFiltroFmr)
	EndIf

	mBrowse( 6, 1,22,75,"TDC",,,,,,SG510SEMAF(),,,,,,,,cFilter510)

	dbSelectArea("TDC")

	EndIf

	NGRETURNPRM(aNGBEGINPRM)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG510ALT  บAutor  ณRoger Rodrigues     บ Data ณ  17/03/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta tela para cadastro de FMRs                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SGAA510/SGAA500                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG510ALT(cAlias,nRecno,nOpcx,aDadosFmr,lRotFab)

	Local cTitulo := cCadastro// Titulo da janela
	Local lVisual := .t., lOk := .F.
	Local nOK := 0, i, k
	Local aPages:= {},aTitles:= {}
	Local cParStat  := SuperGetMv("MV_NGSGASF",.F.,"2")
	Local lNAltInfo := IsInCallStack("SgaOprFMR")

	//Variaveis de tamanho de tela e objetos
	Local aSize := {}, aObjects := {}, aInfo := {}, aPosObj := {}

	Default lRotFab := .T.

	//Variaveis Chave da Rotina
	Private lCancel := .f.
	Private lFabrica := !IsInCallStack("SGAA510") .And. lRotFab //Variavel que verifica se o Usuแrio e dแ fแbrica ou do Departamento de Residuos
	Private cStatus := If(nOpcx == 4, TDC->TDC_STATUS," ")//Variavel com antigo Status da FMR, utilizado para validacoes

	//Variaveis de Tela
	Private oDlg510, oFolder510, oEnc510, oPnlAll
	Private aTela := {}, aGets := {}
	Private aButtons := {}

	//Variaveis da GetDados
	Private oGetAc, oGetRe
	Private aColsAcon := {}, aColsResp := {}
	Private aHeadAcon := {}, aHeadResp := {}
	Private cGetWhlAc := "", cGetWhlRe := ""
	Private cDepto490
	Private cDepto510

	Private lSg510WDep := .T.
	Private lSg510WRes := .T.
	Private lSg510WPto := .T.

	//Definicao de tamanho de tela e objetos
	aSize := MsAdvSize(,.f.,430)
	Aadd(aObjects,{045,045,.t.,.t.})
	Aadd(aObjects,{055,055,.t.,.t.})
	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObjects,.t.)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Realiza Verificacoes                                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//Verifica se a FMR posssui nใo conformidades - Botใo Conformidades SGAA500
	If TDC->TDC_STATUS <> "4" .and. nOpcx <> 2 .and. nOpcx <> 3 .and. lFabrica
		MsgInfo(STR0002,STR0003) //"A FMR nใo possui nใo conformidades."###"Aten็ใo"
		Return .F.
	Endif
	//Verifica se a FMR com NC estแ sendo alterada pela Fabrica
	If TDC->TDC_STATUS == "4" .AND. !lFabrica .and. nOpcx == 4
		MsgInfo(STR0004,STR0003) //"Esta FMR somente poderแ ser alterada via rotina de Cadastro de FMR's no botใo Conformidades."###"Aten็ใo"
		Return .F.
	Endif

	//Cria os Folders de acordo com a Rotina que chama
	Aadd(aTitles,OemToAnsi(STR0005)) //"Acondicionamento"
	Aadd(aPages,"Header 1")
	If !lFabrica
		Aadd(aTitles,OemToAnsi(STR0006)) //"Responsแveis"
		Aadd(aPages,"Header 2")
	Endif

	//Carrega variaveis de Modo de exibicao
	Inclui := (nOpcx == 3)
	Altera := (nOpcx == 4)
	If TDC->TDC_STATUS $ "3/5/7" .and. Altera
		If TDC->TDC_STATUS == "5"
			MsgInfo(STR0007,STR0003) //"Esta FMR estแ cancelada, somente serแ possํvel a visualiza็ใo da mesma."###"Aten็ใo"
		ElseIf TDC->TDC_STATUS == "3"
			//Verifica se a ocorrencia gerada pela FMR nใo estแ associada a uma composi็ใo de carga
			If cParStat <> "1"
				MsgInfo(STR0008,STR0003) //"O resํduo desta FMR jแ estแ em Armaz้m, somente serแ possํvel a visualiza็ใo da mesma."###"Aten็ใo"
			Else
				MsgInfo( STR0057 , STR0003 )//"O resํduo desta FMR jแ estแ em Armaz้m, somente serแ possํvel o cancelamento da mesma."###"Aten็ใo"
				If fVerifOco()
					lCancel := .T.
				Else
					Return .F.
				EndIf
			EndIf
		ElseIf TDC->TDC_STATUS == "7"
			MsgInfo(STR0009,STR0003)	 //"O resํduo jแ foi destinado para tratamento, somente serแ possํvel a visualiza็ใo da mesma."###"Aten็ใo"
		Endif
		nOpcx := 2
		Inclui := .F.
		Altera := .F.
	Endif

	If nOpcx == 3 .or. nOpcx == 4
		aButtons := {{"RELOAD" ,{||SG510CPY()},STR0010,STR0011}} //"Copiar Coletores"###"Cop. Cole."
	Endif

	Define MsDialog oDlg510 Title OemToAnsi(cTitulo) From aSize[7],0 To aSize[6],aSize[5] Of oMainWnd Pixel

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Parte Superior da tela                               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aTela := {}
	aGets := {}
	Dbselectarea("TDC")
	RegToMemory("TDC",(nOpcx == 3))

	If lCancel
		M->TDC_STATUS := "5"
	EndIf

	If !Empty(aDadosFmr)
		VerifyFilt(aDadosFmr)
		lSg510WDep := Empty(M->TDC_DEPTO)  .Or. !lNAltInfo
		lSg510WRes := Empty(M->TDC_CODRES) .Or. !lNAltInfo
		lSg510WPto := Empty(M->TDC_CODPNT) .Or. !lNAltInfo
	EndIf

	oPnlAll := TPanel():New(01,01,,oDlg510,,,,,,10,10,.F.,.F.)
	oPnlAll:Align := CONTROL_ALIGN_ALLCLIENT

	oEnc510:= MsMGet():New("TDC",nRecno,nOpcx,,,,,aPosObj[1],,,,,,oPnlAll,,If( lCancel , .T. ,  ),.F.)
	oEnc510:oBox:Align := CONTROL_ALIGN_TOP
	If Inclui
		IIF(cParStat == "1",M->TDC_STATUS := "3",M->TDC_STATUS := "1")
	ElseIf lFabrica .and. nOpcx == 4
		M->TDC_STATUS := "6"
	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Parte Inferior da tela                               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oFolder510 := TFolder():New(300,0,aTitles,aPages,oPnlAll,,,,.T.,.f.)
	oFolder510:aDialogs[1]:oFont := oPnlAll:oFont
	If !lFabrica
		oFolder510:aDialogs[2]:oFont := oPnlAll:oFont
	Endif
	oFolder510:Align := CONTROL_ALIGN_ALLCLIENT

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Folder 01 - Acondicionamentos                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aCols := {}
	aHeader := {}

	cGetWhlAc := "TDD->TDD_FILIAL == '"+xFilial("TDD")+"' .AND. TDD->TDD_CODFMR = '"+TDC->TDC_CODFMR+"'"
	FillGetDados( nOpcx, "TDD", 1, "TDC->TDC_CODFMR", {|| }, {|| .T.},{"TDD_CODFMR"},,,,{|| NGMontaAcols("TDD", TDC->TDC_CODFMR,cGetWhlAc)})

	aColsAcon := aClone(aCols)
	aHeadAcon := aClone(aHeader)

	If Empty(aColsAcon) .Or. nOpcx == 3
	   aColsAcon := BlankGetd(aHeadAcon)
	Endif
	//Verifica Sequencia de Acondicionamentos
	If Len(aColsAcon) > 0 .and. Inclui
		If ( nPosSeq := aScan(aHeadAcon,{|x| Trim(Upper(x[2])) == "TDD_SEQUEN" }) ) > 0
			aColsAcon[1][nPosSeq] := StrZero(Len(aColsAcon),3)
		Endif
	Endif
	oGetAc := MsNewGetDados():New(005, 005, 100, 200,IIF(!Inclui.And.!Altera,0,GD_INSERT+GD_UPDATE+GD_DELETE),"SG510ACLIN()","SG510ACLIN()",,,,9999,,,,oFolder510:aDialogs[1],aHeadAcon, aColsAcon)
	oGetAc:oBrowse:Default()
	oGetAc:oBrowse:Refresh()
	oGetAc:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	aSvAcon := aClone(aColsAcon)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Folder 02 - Responsแveis                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//Get Dados somente disponํvel para o DERAM
	If !lFabrica
		aCols := {}
		aHeader := {}

		cGetWhlRe := "TDE->TDE_FILIAL == '"+xFilial("TDE")+"' .AND. TDE->TDE_CODFMR = '"+TDC->TDC_CODFMR+"'"
		FillGetDados( nOpcx, "TDE", 1, "TDC->TDC_CODFMR", {|| }, {|| .T.},{"TDE_CODFMR"},,,,{|| NGMontaAcols("TDE", TDC->TDC_CODFMR,cGetWhlRe)})

		aColsResp := aClone(aCols)
		aHeadResp := aClone(aHeader)

		If Empty(aColsResp) .Or. nOpcx == 3
		   aColsResp := BlankGetd(aHeadResp)
		Endif
		nPosMat  := aScan(aHeadResp, {|x| Trim(Upper(x[2])) == "TDE_MAT"})
		nPosNom  := aScan(aHeadResp, {|x| Trim(Upper(x[2])) == "TDE_NOME"})
		If Len(aColsResp) > 0 .and. !Inclui .and. nOpcx <> 2
			//Adiciona na GetDados Usuแrio da Altera็ใo
			dbSelectArea("QAA")
			dbSetOrder(6)
			If dbSeek(Trim(Upper(cUserName)))
				//Verifica se o Acols estแ vazio
				If Empty(aColsResp[1][1])
					aColsResp[1][nPosMat] := QAA->QAA_MAT
					aColsResp[1][nPosNom] := QAA->QAA_NOME
				Else
					//Verifica se jแ estแ no aCols
					If aScan(aColsResp, {|x| x[nPosMat] == QAA->QAA_MAT}) == 0
						aAdd(aColsResp, BlankGetd(aHeadResp)[1])
						aColsResp[Len(aColsResp)][nPosMat] := QAA->QAA_MAT
						aColsResp[Len(aColsResp)][nPosNom] := QAA->QAA_NOME
					Endif
				Endif
			Endif
		Endif
		oGetRe := MsNewGetDados():New(005, 005, 100, 200,IIF(!Inclui.And.!Altera,0,GD_INSERT+GD_UPDATE+GD_DELETE),"SG510RELIN()","SG510RELIN()",,,,9999,,,,oFolder510:aDialogs[2],aHeadResp, aColsResp)
		oGetRe:oBrowse:Default()
		oGetRe:oBrowse:Refresh()
		oGetRe:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		aSvRe := aClone(aColsResp)
	Endif

	//Click da Direita
	If Len(aSMenu) > 0
		NGPOPUP(asMenu,@oMenu)
		oDlg510:bRClicked := { |o,x,y| oMenu:Activate(x,y,oDlg510)}
		oEnc510:oBox:bRClicked := { |o,x,y| oMenu:Activate(x,y,oDlg510)}
	Endif

	cDepto490 := M->TDC_DEPTO
	cDepto510 := M->TDC_DEPTO

	Activate Dialog oDlg510 On Init (EnchoiceBar(oDlg510,{|| lOk:=.T.,If(SG510TUDOK(),(lOk := .T., oDlg510:End()),lOk := .f.)},;
																					{|| lOk:= .F.,oDlg510:End()},,aButtons)) Centered

	If lOk
		If Inclui .or. Altera .Or. lCancel
			If nOpcx == 3
				ConfirmSX8()
			Endif
			If lCancel
				fDeletaOco() //Deleta ocorr๊ncia ligada a FMR
			EndIf
			SG510GRAVA()
		Endif
	Else
		If nOpcx == 3
			RollBackSX8()
		Endif
	Endif

Return lOk
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG510GRAVAบAutor  ณRoger Rodrigues     บ Data ณ  17/03/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava as informa็๕es e o hist๓rico                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA510                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG510GRAVA(lQNC,aGetAc,aGetRe)
Local i, k
Local lWorkFlow := .F.
Default lQNC := .F.//Varํavel que verifica se a chamada ้ do QNC
Default aGetAc := {}//Variavel com aHeader e aCols de Acondicionamento
Default aGetRe := {}//Variavel com aHeader e aCols de Responsแvel

//Campos de Hist๓rico
dDtHist := dDataBase
cHora	:= Time()
cUsHist	:= cUserName

If Len(aGetAc) == 0
	aHeadAc := oGetAc:aHeader
	aColsAc := oGetAc:aCols
Else
	aHeadAc := aGetAc[1]
	aColsAc := aGetAc[2]
Endif

//Verifica se houveram mudan็as
lHist := If(Inclui .Or. lQNC,.T.,.F.)

If !lHist
	dbSelectArea("TDC")
	For i := 1 To FCOUNT()
		nx := "M->" + FieldName(i)
		If "_FILIAL"$Upper(nx)
			Loop
		Else
			If &(nx) <> &("TDC->"+FieldName(i))
				lHist := .T.
				Exit
			Endif
		Endif
	Next i
Endif
If !lHist
	For i:=1 to Len(aSvAcon)
		For k:=1 to Len(aSvAcon[i])
			If aColsAc[i][k] <> aSvAcon[i][k]
				lHist := .T.
				Exit
			Endif
		Next k
		If lHist
			Exit
		Endif
	Next i
	If !lHist
		If Len(aSvAcon) <> Len(aColsAc)
			lHist := .T.
		Endif
	Endif
Endif
If !lFabrica
	If Len(aGetRe) == 0
		aHeadRe := oGetRe:aHeader
		aColsRe := oGetRe:aCols
	Else
		aHeadRe := aGetRe[1]
		aColsRe := aGetRe[2]
	Endif

	For i:=1 to Len(aSvRe)
		For k:=1 to Len(aSvRe[i])
			If aColsRe[i][k] <> aSvRe[i][k]
				lHist := .T.
				Exit
			Endif
		Next k
		If lHist
			Exit
		Endif
	Next i
	If !lHist
		If Len(aSvRe) <> Len(aColsRe)
			lHist := .T.
		Endif
	Endif
Endif

//Grava FMR
If !lQNC//Se nใo chamado no m๓dulo de nใo conformidade
	//Gera Nใo conformidade e WorkFlow caso exista
	If SuperGetMV("MV_NGSGAQN",.F.,"2") == "1" .and. M->TDC_STATUS == "4" .or. (cStatus == "4" .and. lFabrica)
		//Se for DERAM gera FNCS
		If !lFabrica
			If M->TDC_LIBRES == "2"
				//Gera Nใo Conformidade no QNC
				SG510QNC()
			Endif
			lWorkFlow := .T.
		Else
			//Se fแbrica Finaliza FNC
			dbSelectArea("QI2")
			dbSetOrder(2)
			If dbSeek(xFilial("QI2")+M->TDC_FNC) .and. !Empty(M->TDC_FNC)
				RecLock("QI2",.F.)
				QI2->QI2_CONREA := dDataBase
				MsUnlock("QI2")
			Endif
		Endif
	Endif
	dbSelectArea("TDC")
	RecLock("TDC",Inclui)
	For i := 1 To FCOUNT()
		nx := "M->" + FieldName(i)
		If "_FILIAL"$Upper(nx)
			FieldPut(i, xFilial("TDC"))
		ElseIf "_MMOBS"$Upper(nx) .or. "_MMNC"$Upper(nx)
			Loop
		Else
			FieldPut(i, &nx.)
		Endif
	Next i
	MsUnlock("TDC")
	If !Inclui
		MSMM(&("TDC_MMOBS"),TAMSX3("TDC_OBSERV")[1],,M->TDC_OBSERV,1,,,"TDC","TDC_MMOBS")
		MSMM(&("TDC_MMNC"),TAMSX3("TDC_DESCNC")[1],,M->TDC_DESCNC,1,,,"TDC","TDC_MMNC")
	Else
		MSMM(,TAMSX3("TDC_OBSERV")[1],,M->TDC_OBSERV,1,,,"TDC","TDC_MMOBS")
		MSMM(,TAMSX3("TDC_DESCNC")[1],,M->TDC_DESCNC,1,,,"TDC","TDC_MMNC")
	Endif
Else
	RecLock("TDC",.F.)
	TDC->TDC_STATUS := "6"
	MsUnlock("TDC")
Endif

//Grava Hist๓rico de FMR
dbSelectArea("TDF")
dbSetOrder(1)
If dbSeek(xFilial("TDF")+TDC->TDC_CODFMR+DTOS(dDtHist)+cHora) .and. lHist
	cHrs := Substr(cHora,1,2)
	cMins:= Substr(cHora,4,2)
	cSecs:= Substr(cHora,7)
	cSecs:= StrZero(Val(cSecs)+1,2)
	If cSecs == "60"
		cSecs:= StrZero(Val(cSecs)-1,2)
		cMins:= StrZero(Val(cMins)+1,2)
		If cMins == "60"
			cMins:= StrZero(Val(cMins)-1,2)
			cHrs := StrZero(Val(cHrs)+1,2)
		Endif
	Endif
	cHora := cHrs+":"+cMins+":"+cSecs
Endif
If lHist
	//Grava Hist๓rico
	dbSelectArea("TDF")
	RecLock("TDF",.T.)
	For i:=1 to FCount()
		If "_FILIAL"$Upper(FieldName(i))
			FieldPut(i, xFilial("TDF"))
		Elseif "_DTALT"$Upper(FieldName(i))
			FieldPut(i, dDtHist)
		Elseif "_HRALT"$Upper(FieldName(i))
			FieldPut(i, cHora)
		Elseif "_USUALT"$Upper(FieldName(i))
			FieldPut(i, cUsHist)
		ElseIf "_MMOBS"$Upper(FieldName(i)) .or. "_MMNC"$Upper(FieldName(i))
			Loop
		Else
			FieldPut(i, &("TDC->TDC"+Substr(FieldName(i),4)))
		Endif
	Next i
	MsUnlock("TDF")
	MSMM(,TAMSX3("TDF_OBSERV")[1],,M->TDC_OBSERV,1,,,"TDF","TDF_MMOBS")
	MSMM(,TAMSX3("TDF_DESCNC")[1],,M->TDC_DESCNC,1,,,"TDF","TDF_MMNC")
Endif
nPosSeq := aScan(aHeadAc, {|x| Trim(Upper(x[2])) == "TDD_SEQUEN"})
//Grava Acondicionamentos
For i:=1 to Len(aColsAc)
	If aColsAc[i][Len(aColsAc[i])]
		dbSelectArea("TDD")
		dbSetOrder(1)
		If dbSeek(xFilial("TDD")+TDC->TDC_CODFMR+aColsAc[i][nPosSeq])
			RecLock("TDD",.F.)
			dbDelete()
			MsUnlock("TDD")
		Endif
	Else
		dbSelectArea("TDD")
		dbSetOrder(1)
		If dbSeek(xFilial("TDD")+TDC->TDC_CODFMR+aColsAc[i][nPosSeq])
			RecLock("TDD",.F.)
		Else
			RecLock("TDD",.T.)
		Endif
		For k:=1 to FCount()
			If "_FILIAL"$Upper(FieldName(k))
				FieldPut(k, xFilial("TDD"))
			Elseif "_CODFMR"$Upper(FieldName(k))
				FieldPut(k, TDC->TDC_CODFMR)
			ElseIf (nPosCpo := aScan(aHeadAc, {|x| Trim(Upper(x[2])) == Trim(Upper(FieldName(k)))	})) > 0
				FieldPut(k, aColsAc[i][nPosCpo])
			Endif
		Next k
		MsUnlock("TDD")
		//Grava Hist๓rico
		dbSelectArea("TDG")
		dbSetOrder(1)
		If !dbSeek(xFilial("TDG")+TDC->TDC_CODFMR+DTOS(dDtHist)+cHora+aColsAc[i][nPosSeq]) .and. lHist
			dbSelectArea("TDG")
			RecLock("TDG",.T.)
			For k:=1 to FCount()
				If "_FILIAL"$Upper(FieldName(k))
					FieldPut(k, xFilial("TDG"))
				Elseif "_DTALT"$Upper(FieldName(k))
					FieldPut(k, dDtHist)
				Elseif "_HRALT"$Upper(FieldName(k))
					FieldPut(k, cHora)
				Elseif "_USUALT"$Upper(FieldName(k))
					FieldPut(k, cUsHist)
				Else
					FieldPut(k, &("TDD->TDD"+Substr(FieldName(k),4)))
				Endif
			Next k
			MsUnlock("TDG")
		Endif
	Endif
Next i
If !lFabrica
	nPosMat  := aScan(aHeadRe, {|x| Trim(Upper(x[2])) == "TDE_MAT"})
	//Grava Responsแveis
	For i:=1 to Len(aColsRe)
		If aColsRe[i][Len(aColsRe[i])]
			dbSelectArea("TDE")
			dbSetOrder(1)
			If dbSeek(xFilial("TDE")+TDC->TDC_CODFMR+aColsRe[i][nPosMat])
				RecLock("TDE",.F.)
				dbDelete()
				MsUnlock("TDE")
			Endif
		ElseIf !Empty(aColsRe[i][nPosMat])
			dbSelectArea("TDE")
			dbSetOrder(1)
			If dbSeek(xFilial("TDE")+TDC->TDC_CODFMR+aColsRe[i][nPosMat])
				RecLock("TDE",.F.)
			Else
				RecLock("TDE",.T.)
			Endif
			For k:=1 to FCount()
				If "_FILIAL"$Upper(FieldName(k))
					FieldPut(k, xFilial("TDE"))
				Elseif "_CODFMR"$Upper(FieldName(k))
					FieldPut(k, TDC->TDC_CODFMR)
				ElseIf (nPosCpo := aScan(aHeadRe, {|x| Trim(Upper(x[2])) == Trim(Upper(FieldName(k)))	})) > 0
					FieldPut(k, aColsRe[i][nPosCpo])
				Endif
			Next k
			MsUnlock("TDE")
			//Grava Hist๓rico
			dbSelectArea("TDH")
			dbSetOrder(1)
			If !dbSeek(xFilial("TDH")+TDC->TDC_CODFMR+DTOS(dDtHist)+cHora+aColsRe[i][nPosMat]) .and. lHist
				RecLock("TDH",.T.)
				For k:=1 to FCount()
					If "_FILIAL"$Upper(FieldName(k))
						FieldPut(k, xFilial("TDH"))
					Elseif "_DTALT"$Upper(FieldName(k))
						FieldPut(k, dDtHist)
					Elseif "_HRALT"$Upper(FieldName(k))
						FieldPut(k, cHora)
					Elseif "_USUALT"$Upper(FieldName(k))
						FieldPut(k, cUsHist)
					Else
						FieldPut(k, &("TDE->TDE"+Substr(FieldName(k),4)))
					Endif
				Next k
				MsUnlock("TDH")
			Endif
		Endif
	Next i
Else
	//Caso seja chamado do botใo confirmadade grava hist๓rico de usuแrios normalmente
	If TDC->TDC_STATUS == "6"
		dbSelectArea("TDE")
		dbSetOrder(1)
		dbSeek(xFilial("TDE")+TDC->TDC_CODFMR)
		While !eof() .and. TDE->TDE_FILIAL+TDE->TDE_CODFMR == xFilial("TDE")+TDC->TDC_CODFMR
			//Grava Hist๓rico
			dbSelectArea("TDH")
			dbSetOrder(1)
			If !dbSeek(xFilial("TDH")+TDC->TDC_CODFMR+DTOS(dDtHist)+cHora+TDE->TDE_MAT)
				RecLock("TDH",.T.)
				For k:=1 to FCount()
					If "_FILIAL"$Upper(FieldName(k))
						FieldPut(k, xFilial("TDH"))
					Elseif "_DTALT"$Upper(FieldName(k))
						FieldPut(k, dDtHist)
					Elseif "_HRALT"$Upper(FieldName(k))
						FieldPut(k, cHora)
					Elseif "_USUALT"$Upper(FieldName(k))
						FieldPut(k, cUsHist)
					Else
						FieldPut(k, &("TDE->TDE"+Substr(FieldName(k),4)))
					Endif
				Next k
				MsUnlock("TDH")
			Endif
			dbSelectArea("TDE")
			dbSkip()
		End
	Endif
Endif
//Se for Inclusใo grava os responsแveis do departamento
If Inclui
	//Grava Responsแvel pelo Departamento
	If !Empty(M->TDC_DEPTO)
		dbSelectArea("TAF")
		dbSetOrder(8)
		If dbSeek(xFilial("TAF")+M->TDC_DEPTO)
			If !Empty(TAF->TAF_MAT)
				dbSelectArea("TDE")
				dbSetOrder(1)
				If dbSeek(xFilial("TDE")+TDC->TDC_CODFMR+TAF->TAF_MAT)
					RecLock("TDE",.F.)
				Else
					RecLock("TDE",.T.)
				Endif
				TDE->TDE_FILIAL	:= xFilial("TDE")
				TDE->TDE_CODFMR	:= TDC->TDC_CODFMR
				TDE->TDE_MAT	:= TAF->TAF_MAT
				MsUnlock("TDE")
				//Grava Hist๓rico
				dbSelectArea("TDH")
				dbSetOrder(1)
				If !dbSeek(xFilial("TDH")+M->TDC_CODFMR+DTOS(dDtHist)+cHora+TAF->TAF_MAT)
					RecLock("TDH",.T.)
					TDH->TDH_FILIAL	:= xFilial("TDH")
					TDH->TDH_CODFMR	:= M->TDC_CODFMR
					TDH->TDH_DTALT	:= dDtHist
					TDH->TDH_HRALT	:= cHora
					TDH->TDH_MAT	:= TAF->TAF_MAT
					MsUnlock("TDH")
				Endif
			Endif
		Endif
	Endif
Endif

//Se for o caso, envia WorkFlow para responsaveis
If lWorkflow
	SGAW090(TDC->TDC_CODFMR)
Endif

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ MenuDef  ณ Autor ณ Roger Rodrigues       ณ Data ณ17/03/2011ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณUtilizacao de Menu Funcional.                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SigaSGA                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ	  1 - Pesquisa e Posiciona em um Banco de Dados           ณฑฑ
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ    3 - Inclui registros no Bancos de Dados                 ณฑฑ
ฑฑณ          ณ    4 - Altera o registro corrente                          ณฑฑ
ฑฑณ          ณ    5 - Remove o registro corrente do Banco de Dados        ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MenuDef()
Local aRotina :=	{ { STR0012	, "AxPesqui"	, 0 , 1},; //"Pesquisar"
                      { STR0013	, "SG510ALT"	, 0 , 2},; //"Visualizar"
                      { STR0014	, "SG510ALT"	, 0 , 3},; //"Incluir"
                      { STR0015	, "SG510ALT"	, 0 , 4},; //"Alterar"
                      { STR0016	, "SGAA520"	, 0 , 4},; //"Hist๓rico"
                      { STR0017	, "SG510DES"	, 0 , 3},; //"Mostra Dest."
                      { STR0018	, "SG510LEG"	, 0 , 3}} //"Legenda"

Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG510SEMAFบAutor  ณRoger Rodrigues     บ Data ณ  17/03/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefine as cores de semaforo para as FMRS                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SGAA510/SGAA500                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG510SEMAF()
Local aCores :={{"NGSEMAFARO('TDC->TDC_STATUS == "+'"1"'+"')" , "BR_VERMELHO" },;
				 {"NGSEMAFARO('TDC->TDC_STATUS == "+'"3"'+" .AND. !EMPTY(TDC->TDC_LIBRES)')" , "BR_AZUL"},;
				 {"NGSEMAFARO('TDC->TDC_STATUS == "+'"2"'+"')" , "BR_AMARELO"},;
				 {"NGSEMAFARO('TDC->TDC_STATUS == "+'"3"'+"')" , "BR_VERDE"},;
				 {"NGSEMAFARO('TDC->TDC_STATUS == "+'"4"'+"')" , "BR_PRETO"},;
				 {"NGSEMAFARO('TDC->TDC_STATUS == "+'"5"'+"')" , "BR_LARANJA"},;
				 {"NGSEMAFARO('TDC->TDC_STATUS == "+'"6"'+"')" , "BR_PINK"},;
				 {"NGSEMAFARO('TDC->TDC_STATUS == "+'"7"'+"')" , "BR_CINZA"}}

Return aCores
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG510NMR  บAutor  ณRoger Rodrigues     บ Data ณ  17/03/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o nome do responsแvel                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA510              		    			  				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG510NMR(cCodUsu)

Local cConteud := ""

If !Empty(cCodUsu)

	PswOrder(2)
	PswSeek(cCodUsu)
	cConteud := PswRet(1)[1][4]
	
EndIf

Return cConteud

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG510LEG  บAutor  ณRoger Rodrigues     บ Data ณ  17/03/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta Browse com legenda                           	      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA510                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG510LEG()
BrwLegenda(cCadastro,STR0018,{	{"BR_VERMELHO"	, STR0019 },; //"Legenda"###"Ponto de Coleta"
									{"BR_AMARELO"	, STR0020},; //"มrea de Pesagem"
									{"BR_VERDE"		, STR0021},; //"Armaz้m"
									{"BR_PRETO"		, STR0022},; //"Nใo Conforme"
									{"BR_AZUL"		, STR0023},; //"Nใo Conformidade Tratada e em Armaz้m"
									{"BR_LARANJA"	, STR0024},; //"FMR Cancelada"
									{"BR_PINK"		, STR0025},; //"FMR Reaberta"
									{"BR_CINZA"		, STR0026}}) //"FMR Destinada"
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} SG510VAL

Validacao dos campos da tela

@author  Roger Rodrigues
@since   18/03/2011
/*/
//-------------------------------------------------------------------
Function SG510VAL( cCampo )

	Local lRet		:= .T.
	Local aHeadAcon	:= oGetAc:aHeader
	Local nPosSeq	:= aScan( aHeadAcon, { | x | Trim( Upper( x[ 2 ] ) ) == "TDD_SEQUEN" } )
	Local cParStat	:= SuperGetMv( "MV_NGSGASF", .F., "2" )

	Default cCampo	:= ReadVar()

	If cCampo == "M->TDC_DEPTO"

		cDepto490 := M->TDC_DEPTO
		cDepto510 := M->TDC_DEPTO

		//Valida Departamento e se usuแrio estแ realacionado ao mesmo na Estrutura Organizacional
		If ExistCpo( "TAF", M->TDC_DEPTO, 8 )

			//Valida se o nํvel estแ ativo
			If Posicione( "TAF", 8, xFilial( "TAF" ) + M->TDC_DEPTO, "TAF_SITNIV" ) == "2"
				//"ATENวรO"##"A localiza็ใo informada estแ inativa"##"Favor selecionar uma localiza็ใo ativa"
				Help( ' ', 1, STR0003, , STR0060, 2, 0, , , , , , { STR0061 } )
				lRet := .F.
			Else
				dbSelectArea( "QAA" )
				dbSetOrder( 6 )
				If dbSeek( Trim( Upper( M->TDC_RESPON ) ) )
					dbSelectArea( "TAK" )
					dbSetOrder( 1 )
					If dbSeek( xFilial( "TAK" ) + "001" + M->TDC_DEPTO + QAA->QAA_MAT )
						dbSelectArea( "TDB" )
						dbSetOrder( 1 )
						If !dbSeek( xFilial( "TDB" ) + M->TDC_DEPTO + M->TDC_CODPNT ) .And. !Empty( M->TDC_CODPNT )
							M->TDC_CODPNT := Space( TAMSX3( "TDC_CODPNT" )[ 1 ] )
							M->TDC_DESPNT := Space( TAMSX3( "TDC_DESCRI" )[ 1 ] )
						EndIf
					EndIf
				Else
					Help( ' ', 1, STR0003, , STR0027, 2, 0 ) //"Aten็ใo"###"O Usuแrio de inclusใo deverแ ser participante da localiza็ใo informada."
					lRet := .F.
				EndIf
			EndIf
		EndIf

	ElseIf cCampo == "M->TDC_CODRES"

		//Valida Residuo Digitado
		If ExistCpo( "TAX", M->TDC_CODRES )
			//Limpa aCols
			oGetAc:aCols:= BlankGetd( aHeadaCon )
			oGetAc:nAt	:= 1
			//Reinicializa sequ๊ncia
			If nPosSeq > 0
				oGetAc:aCols[ 1 ][ nPosSeq ] := "001"
			EndIf
			oGetAc:Refresh()
		EndIf

	ElseIf cCampo == "M->TDC_STATUS" //Valida campo de Status

		If !Inclui .and. M->TDC_STATUS == "1"
			ShowHelpDlg( STR0003, { STR0028 }, 2 ) //"Aten็ใo"###"Somente na inclusใo o Status poderแ ser 1=Ponto de Coleta."
			lRet := .F.
		ElseIf Altera .And. ( cStatus != "1" .And. cStatus != "6" ) .And. M->TDC_STATUS == "4"
			ShowHelpDlg( STR0003, { STR0029 } ) //"Aten็ใo"###"O status 4=Nใo Conforme somente se aplica quando o status anterior da FMR for 1=Ponto de Coleta ou 6=Reaberta."
			lRet := .F.
		ElseIf Altera .And. cStatus != "4" .And. M->TDC_STATUS == "6"
			ShowHelpDlg( STR0003, { STR0030 }, 3 ) //"Aten็ใo"###"O status 6=Reaberta somente se aplica quando o status anterior da FMR for 4=Nใo Conforme."
			lRet := .F.
		ElseIf M->TDC_STATUS == "7"
			ShowHelpDlg( STR0003, { STR0031 }, 2 ) //"Aten็ใo"###"O status 7=Destinado s๓ se aplica quando todo o resํduo da FMR tiver sido Transferido para outro Destino."
			lRet := .F.
		ElseIf cParStat == "1" .And. Altera .And. cStatus == "3" .And. !( M->TDC_STATUS $ "3/5" )
			ShowHelpDlg( STR0003, { STR0058 }, 2 ) //"Aten็ใo"###"Para FMR's jแ enviadas ao armazem apenas o status 5=Cancelada ้ aplicแvel."
			lRet := .F.
		EndIf

	Endif

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG510SEQ  บAutor  ณRoger Rodrigues     บ Data ณ  17/03/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica qual pr๓xima ordem para sequencia de acondiciona-  บฑฑ
ฑฑบ          ณmento                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSG510ALT                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG510SEQ()

If Type("oGetAc") != "O"
	cSeq := "001"
Else
	cSeq := StrZero(Len(oGetAc:aCols),3)
Endif

Return cSeq
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG510ACLINบAutor  ณRoger Rodrigues     บ Data ณ  17/03/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCritica se a linha de Acondicionamentos estแ OK             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSG510ALT                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG510ACLIN()
Local nPosAc, nPosPe
Local aColsAc := oGetAc:aCols
Local aHeadAc := oGetAc:aHeader
Local n := oGetAc:nAt

If aColsAc[n][Len(aColsAc[n])]
	Return .T.
Endif
If (nPosAc := aScan(aHeadAc, {|x| Trim(Upper(x[2])) == "TDD_ACONDI"})) > 0 .AND. !lFabrica .AND. (M->TDC_STATUS <> "4" .AND. M->TDC_LIBRES <> "1")
	If Empty(aColsAc[n][nPosAc])
		ShowHelpDlg(STR0003,{STR0032},1,{STR0033}) //"Aten็ใo"###"O preenchimento do campo Acondicionamento ้ obrigat๓rio."###"Informe os campos obrigat๓rios."
		Return .F.
	Endif
Endif
If (nPosCol := aScan(aHeadAc, {|x| Trim(Upper(x[2])) == "TDD_COLET"})) > 0
	If Empty(aColsAc[n][nPosCol])
		ShowHelpDlg(STR0003,{STR0034},1,{STR0033}) //"Aten็ใo"###"O preenchimento do campo Coletor ้ obrigat๓rio."###"Informe os campos obrigat๓rios."
		Return .F.
	Endif
Endif

PutFileInEof("TDD")

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG510RELINบAutor  ณRoger Rodrigues     บ Data ณ  17/03/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCritica se a linha de Responsแveis estแ OK                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSG510ALT                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG510RELIN(lFim)
Local aColsRe := oGetRe:aCols
Local aHeadRe := oGetRe:aHeader
Local n := oGetRe:nAt
Local nPosMat := aScan(aHeadRe, {|x| Trim(Upper(x[2])) == "TDE_MAT"})
Local i
Default lFim := .F.

//Percorre aCols
For i = 1 to Len(aColsRe)
	If !aColsRe[i][Len(aColsRe[i])]
		If lFim .or. i == n
			//VerIfica se os campos obrigat๓rios estใo preenchidos
			If Empty(aColsRe[i][nPosMat])
				//Mostra mensagem de Help
				Help(1," ","OBRIGAT2",,aHeadRe[nPosMat][1],3,0)
				Return .F.
			Endif
		Endif
		//Verifica se ้ somente LinhaOk
		If i <> n .and. !aColsRe[n][Len(aColsRe[n])]
			If aColsRe[i][nPosMat] == aColsRe[n][nPosMat]
				Help(" ",1,"JAEXISTINF")
				Return .F.
			Endif
		Endif
	Endif
Next f

PutFileInEof("TDE")

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Sg510TudOk
Verifica o preenchimento da rotina.

@author Roger Rodrigues
@since 17/03/2011

@return lRet, L๓gico, Retorna verdadeiro caso esteja tudo certo.
/*/
//-------------------------------------------------------------------
Function Sg510TudOk()

	Local aColsAc := oGetAc:aCols
	Local aHeadAc := oGetAc:aHeader

	Local cParStat := SuperGetMv("MV_NGSGASF",.F.,"2")

	Local lMsg := .F.
	Local lEstAuto := SuperGetMv( 'MV_NGSGAES', .F., 'N' ) == 'S'

	Local nPeso := 0.00
	Local nX, xx := 0
	Local nPosAc := aScan(aHeadAc, {|x| Trim(Upper(x[2])) == "TDD_ACONDI"})
	Local nPosPe := aScan(aHeadAc, {|x| Trim(Upper(x[2])) == "TDD_PESO"})
	Local nPosCol := aScan(aHeadAc, {|x| Trim(Upper(x[2])) == "TDD_COLET"})

	If Inclui .or. Altera .or. lCancel

		If lEstAuto .And. !SgaCodMov() // Verifica o preenchimento dos parโmtros MV_SGADEV e MV_SGAREQ
			Return .F.
		EndIf

		//Verifica se os campos da parte de cima da tela foram digitados corretamente
		If !Obrigatorio(aGets,aTela)
			Return .F.
		Endif
		If !Inclui .and. M->TDC_STATUS == "1"
			ShowHelpDlg(STR0003,{STR0028},2) //"Aten็ใo"###"Somente na inclusใo o Status poderแ ser 1=Ponto de Coleta."
			Return .F.
		Endif
		If M->TDC_STATUS == "4" .and. Empty(M->TDC_LIBRES)
			ShowHelpDlg(STR0003,{STR0035},2) //"Aten็ใo"###"O campo Libera Com Restri็๕es deve ser preenchido quando o status for 4=Nใo Conforme."
			Return .F.
		Endif
		If M->TDC_STATUS == "4" .and. Empty(M->TDC_DESCNC)
			ShowHelpDlg(STR0003,{STR0036},3) //"Aten็ใo"###"O campo Descri็ใo da Nใo Conformidade deve ser preenchido quando o status for 4=Nใo Conforme."
			Return .F.
		Endif
		//Se Cancelamento
		If M->TDC_STATUS == "5" .and. (Altera .or. Inclui .or. lCancel)
			lMsg := MsgYesNo(STR0037,STR0003) //"Deseja mesmo cancelar a FMR? Nใo serแ mais possํvel alterar a mesma."###"Aten็ใo"
			If lMsg .And. Altera .And. cStatus == "3" .And. cParStat == "1"//Caso parametro MV_NGSGASF ativado e jogando de 'Armazem' para 'Cancelamento', realiza o extorno
				lMsg := fExtornoFMR()
			EndIf
			Return lMsg
		Endif
		//Se Liberar com restri็๕es
		If M->TDC_STATUS != "4" .and. M->TDC_LIBRES != "1"
			//Valida se os Acondicionamentos foram digitados corretamente
			If !SG510ACLIN()
				Return .F.
			Endif
			//Verifica os Responsแveis
			If !lFabrica
				If !SG510RELIN(.T.)
					Return .F.
				Endif
			Endif
		Endif
		If nPosAc > 0 .and. nPosPe > 0
			For nX := 1 to Len(aColsAc)
				If aColsAc[NX][Len(aColsAc[nX])]
					Loop
				Endif
				If lFabrica .OR. (M->TDC_STATUS == "4" .AND. M->TDC_LIBRES <> "1")
					If !Empty(aColsAc[nX][nPosCol])
						xx++
						Exit
					Endif
				Else
					If !Empty(aColsAc[nX][nPosAc]) .and. !Empty(aColsAc[nX][nPosCol])
						xx++
						Exit
					Endif
				Endif
			Next
		Endif
		If xx == 0
			If lFabrica
				ShowHelpDlg(STR0003,{STR0038},1) //"Aten็ใo"###"Favor preencher pelo menos um Coletor."
			Else
				ShowHelpDlg(STR0003,{STR0039},1) //"Aten็ใo"###"Favor preencher pelo menos um Acondicionamento com Coletor."
			Endif
			Return .F.
		Endif
		lTdPeso := .T.//Varํavel para verificar se todos os pesos estใo preenchidos
		//Verifica se deve abrir mensagem para แrea de pesagem
		If !lFabrica .and. (M->TDC_STATUS == "3" .or. (M->TDC_STATUS == "4" .and. M->TDC_LIBRES == "1")) .and. Empty(M->TDC_CODOCO)
			//Verifica se todos os pesos estใo preenchidos
			For nX:=1 to Len(aColsAc)
				If aColsAc[nX][nPosPe] > 0
					nPeso += aColsAc[nX][nPosPe]
				Else
					lTdPeso := .F.
					Exit
				Endif
			Next nX
			//Exibe mensagem para mandar para แrea de pesagem
			If !lTdPeso
				ShowHelpDlg(STR0003,{STR0040},2,{STR0033}) //"Aten็ใo"###"O preenchimento do campo Peso ้ obrigat๓rio."###"Informe os campos obrigat๓rios."
				If cStatus <> "2"
					If MsgYesNo(STR0041,STR0003) //"Deseja enviar a FMR para a Area de Pesagem?"###"Aten็ใo"
						If M->TDC_STATUS == "4" .and. M->TDC_LIBRES == "1"
							SG510GRAVA()
						Endif
						M->TDC_STATUS := "2"
						Return .T.
					Else
						Return .F.
					Endif
				Else
					Return .F.
				Endif
			Endif
			//Caso Armazem verifica se todos os pesos estใo preenchidos
			If nPeso > 0 .and. lTdPeso
				cCadastro := OemToAnsi(STR0042) //"Ocorr๊ncia de Resํduos"
				If !Sg150Pro("TB0",0,3,M->TDC_CODRES,nPeso,M->TDC_DEPTO)
					cCadastro := OemToAnsi(STR0043) //"Cadastro de FMRs"
					ShowHelpDlg(STR0003,{STR0044},3) //"Aten็ใo"###"A FMR nใo poderแ ter status Armaz้m enquanto nใo for cadastrada uma ocorr๊ncia de resํduo."
					Return .F.
				Else
					cCadastro := OemToAnsi(STR0043) //"Cadastro de FMRs"
					If M->TDC_STATUS == "4" .and. M->TDC_LIBRES == "1"
						SG510GRAVA()
						M->TDC_STATUS := "3"
					Endif
					dbSelectArea("TB0")
					//Grava C๓digo da Ocorr๊ncia
					M->TDC_CODOCO := TB0->TB0_CODOCO
				Endif
			Endif
		Endif

	Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG510QNC  บAutor  ณRoger Rodrigues     บ Data ณ  17/03/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera registro de nใo conformidade para o m๓dulo QNC         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSG510ALT                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SG510QNC()

	Local lQncFDig := !Empty( SuperGetMv( "MV_QNCFDIG", .F., "" ) )//Filial do Usuario Digitador/Originador da FNC
	Local lQncMDig := !Empty( SuperGetMv( "MV_QNCMDIG", .F., "" ) )//Matricula do Usuario Digitador/Originador da FNC
	Local lQncDDig := !Empty( SuperGetMv( "MV_QNCDDIG", .F., "" ) )//Codigo Depto/C.Custo do Usuario Digitador da FNC
	Local lQncFRes := !Empty( SuperGetMv( "MV_QNCFRES", .F., "" ) )//Filial do usuario Responsavel pela FNC 
	Local lQncMRes := !Empty( SuperGetMv( "MV_QNCMRES", .F., "" ) )//Codigo/Matricula do Usuario Responsavel pela FNC
	
	/*
	- MV_QNCFORI - Filial de Origem da FNC
	- MV_QNCDORI - Codigo do Depto/C.Custo de origem da FNC
	- MV_QNCFDES - Filial destino da FNC
	- MV_QNCDDES - Codigo do Depto/C.Custo destino da FNC
	- MV_QNCFRES - Filial do usuario Responsavel pela FNC
	- MV_QNCMRES - Codigo/Matricula do Usuario Responsavel pela FNC
	- MV_QNCFDIG - Filial do Usuario Digitador/Originador da FNC
	- MV_QNCMDIG - Matricula do Usuario Digitador/Originador da FNC
	- MV_QNCDDIG - Codigo Depto/C.Custo do Usuario Digitador da FNC
	*/

	Local aCamposQNC := {}

	DbSelectArea("QI2")
	aAdd( aCamposQNC, { "QI2_TPFIC", "2"}) //Classifica็ใo de NC
	aAdd( aCamposQNC, { "QI2_PRIORI", "1"}) //Prioridade
	aAdd( aCamposQNC, { "QI2_STATUS", "3"}) //Situal็ao 3=Procede
	aAdd( aCamposQNC, { "QI2_DESCR",  STR0045+M->TDC_CODFMR}) //Cod FMR //"Ficha de Movimenta็ใo de Resํduos: "
	aAdd( aCamposQNC, { "QI2_MEMO1",  M->TDC_DESCNC}) //Descricao da Nใo Conformidade
	aAdd( aCamposQNC, { "QI2_MEMO2",  M->TDC_OBSERV}) //Observa็๕es da FMR
	aAdd( aCamposQNC, { "QI2_OCORRE", dDataBase}) //Data da Ocorr๊ncias
	aAdd( aCamposQNC, { "QI2_CODPRO", M->TDC_CODRES}) //C๓digo do Resํduo
	aAdd( aCamposQNC, { "QI2_ORIGEM", "SGA"}) //M๓dulo de Origem da FNC
	
	dbSelectArea("QAA")
	dbSetOrder(6)
	If dbSeek(Trim(Upper(cUserName)))
		If !lQncFDig
			aAdd( aCamposQNC, { "QI2_FILMAT", QAA->QAA_FILIAL } ) //Filial do Usuแrio Digitador
		EndIf
		If !lQncMDig
			aAdd( aCamposQNC, { "QI2_MAT",    QAA->QAA_MAT } ) //Matricula Usuแrio digitador
		EndIf
		If !lQncDDig
			aAdd( aCamposQNC, { "QI2_MATDEP", QAA->QAA_CC } ) //Centro de Custo Digitador
		EndIf
	EndIf

	If dbSeek(Trim(Upper(TDC->TDC_RESPON)))
		If !lQncFRes	
			aAdd( aCamposQNC, { "QI2_FILRES", QAA->QAA_FILIAL } ) //Filial do usuario Responsavel pela FNC
		EndIf
		If !lQncMRes
			aAdd( aCamposQNC, { "QI2_MATRES", QAA->QAA_MAT } ) //Matrํcula do responsแvel pela FNC
		EndIf
	EndIf

	M->TDC_FNC := QNCGERA(1,aCamposQNC)[2]

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณSG510COLTRBบAutor  ณRoger Rodrigues     บ Data ณ 17/03/2011 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega TRB com os coletores                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA510                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG510COLTRB(lValid)
Local aCampos := {}
Local aOpcao:= {STR0046, STR0047}//Variavel para montagem da consulta padrใo //"C๓digo"###"Descri็ใo"
Local aCamposF3 := {}
//Varแveis para verifica็ใo se o Tipo Acondicionamento estแ digitado
Local aColsAc	:= oGetAc:aCols
Local aHeadAc	:= oGetAc:aHeader
Local n := oGetAc:nAt
Local nPosTp := aScan(aHeadAc , {|x| Trim(Upper(x[2])) == "TDD_ACONDI"})
Local lAcondi := .F.
Local oTempTRB

//Varํaveis para valida็ใo
Local lRet := .F.
Default lValid := .F.

Private cAliasCol := GetNextAlias()
//Verifica se ้ F3 ou Valida็ใo
If !lValid
	//Campos para F3
	aADD(aCamposF3, {STR0046		,"CODCOL"	, 50	}) //"C๓digo"
	aADD(aCamposF3, {STR0047	,"DESCOL"	, 200	}) //"Descri็ใo"

	//Campos do TRB
	aADD(aCampos, {"CODCOL"	, "C" , Len(SB1->B1_COD)	, 0})
	aADD(aCampos, {"DESCOL"	, "C" , 40					, 0})

	oTempTRB := FWTemporaryTable():New( cAliasCol, aCampos )
	oTempTRB:AddIndex( "1", {"CODCOL"} )
	oTempTRB:AddIndex( "2", {"DESCOL"} )
	oTempTRB:Create()
Endif

//Verifica se o Tipo Acond. Estแ preenchido
If nPosTp > 0
	If !Empty(aColsAc[n][nPosTp])
		lAcondi := .T.
	Endif
Endif
dbSelectArea("TB7")
dbSelectArea("TB6")
dbSelectArea("TBW")
dbSelectArea("SB1")
cAliasQry := GetNextAlias()
cQuery := "SELECT DISTINCT(TBW.TBW_CODPRO), SB1.B1_DESC "
cQuery += "FROM "+RetSqlName("TBW")+" TBW "
cQuery += "JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_COD = TBW.TBW_CODPRO "
cQuery += "JOIN "+RetSqlName("TB7")+" TB7 ON TB7.TB7_CODRES = '"+M->TDC_CODRES+"' "
//Caso haja tipo acond.
If lAcondi
	cQuery += "AND TB7.TB7_CODTIP = '"+aColsAc[n][nPosTP]+"' "
Endif
cQuery += "JOIN "+RetSqlName("TB6")+" TB6 ON TB6.TB6_CODTIP = TB7.TB7_CODTIP "
cQuery += "WHERE TBW.D_E_L_E_T_ <> '*' AND SB1.D_E_L_E_T_ <> '*' AND "
//Caso haja tipo acond.
cQuery += "TB6.D_E_L_E_T_ <> '*' AND TB6.TB6_STATUS <> '2' AND "
cQuery += "TB7.D_E_L_E_T_ <> '*' AND TBW.TBW_CODTIP = TB7.TB7_CODTIP AND TB7.TB7_TIPO = '6'"

cQuery := ChangeQuery(cQuery)
MPSysOpenQuery( cQuery , cAliasQry )

//Preenche TRB com os registros
dbSelectArea(cAliasQry)
dbGoTop()
While !eof()
	//Verifica se ้ F3 ou Valida็ใo
	If !lValid
		dbSelectArea(cAliasCol)
		dbSetOrder(1)
		If !dbSeek((cAliasQry)->TBW_CODPRO)
			RecLock((cAliasCol),.T.)
			(cAliasCol)->CODCOL	:= (cAliasQry)->TBW_CODPRO
			(cAliasCol)->DESCOL	:= (cAliasQry)->B1_DESC
			MsUnlock((cAliasCol))
		Endif
	Else
		If M->TDD_COLET == (cAliasQry)->TBW_CODPRO
			lRet := .T.
			Exit
		Endif
	Endif
	dbSelectArea(cAliasQry)
	dbSkip()
End
dbSelectArea(cAliasQry)
dbCloseArea()

//Verifica se ้ F3 ou Valida็ใo
If !lValid
	//Fun็ใo que monta Consulta Padrใo
	If NGCONPDTRB(cAliasCol,aOpcao,aCamposF3,40,STR0048) //"Coletores"
		lRet := .T.
		//Posiciona no registro para retorno
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+(cAliasCol)->CODCOL)
	Else
		lRet := .F.
	Endif
	//Deleta arquivo temporแrio e restaura area
	oTempTRB:Delete()
Else
	If lRet
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+M->TDD_COLET)
	Else
		Help("",1,"REGNOIS")
	Endif
Endif

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณSG510ACTRB บAutor  ณRoger Rodrigues     บ Data ณ 17/03/2011 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega TRB com os acondicionamentos                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA510                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG510ACTRB(lValid)
Local aCampos := {}
Local aOpcao:= {STR0046, STR0047}//Variavel para montagem da consulta padrใo //"C๓digo"###"Descri็ใo"
Local aCamposF3 := {}
//Varแveis para verifica็ใo se o coletor estแ digitado
Local aColsAc	:= oGetAc:aCols
Local aHeadAc	:= oGetAc:aHeader
Local n := oGetAc:nAt
Local nPosCol := aScan(aHeadAc , {|x| Trim(Upper(x[2])) == "TDD_COLET"})
Local lColetor := .F.
Local oTempTRB

//Variaveis para valida็ใo
Local lRet := .F.
Default lValid := .F.//Varํavel para verificar se ้ valida็ใo

Private cAliasAcon := GetNextAlias()
//Verifica se ้ F3 ou Valida็ใo
If !lValid
	//Campos para F3
	aADD(aCamposF3, {STR0046		,"CODACON"	, 50	}) //"C๓digo"
	aADD(aCamposF3, {STR0047	,"DESACON"	, 200	}) //"Descri็ใo"

	//Campos do TRB
	aADD(aCampos, {"CODACON"	, "C" , Len(TB6->TB6_CODTIP)	, 0})
	aADD(aCampos, {"DESACON"	, "C" , 40				 		, 0})

	oTempTRB := FWTemporaryTable():New( cAliasAcon, aCampos )
	oTempTRB:AddIndex( "1", {"CODACON"} )
	oTempTRB:AddIndex( "2", {"DESACON"} )
	oTempTRB:Create()
Endif

//Verifica se o Tipo Acond. Estแ preenchido
If nPosCol > 0
	If !Empty(aColsAc[n][nPosCol])
		lColetor := .T.
	Endif
Endif

dbSelectArea("TB7")
dbSelectArea("TB6")
dbSelectArea("TBW")
cAliasQry := GetNextAlias()
cQuery := "SELECT TB7.TB7_CODTIP, TB6.TB6_DESCRI "
cQuery += "FROM "+RetSqlName("TB7")+" TB7 "
cQuery += "JOIN "+RetSqlName("TB6")+" TB6 ON TB6.TB6_CODTIP = TB7.TB7_CODTIP "
If lColetor
	cQuery += "JOIN "+RetSqlName("TBW")+" TBW ON TBW.TBW_CODTIP = TB6.TB6_CODTIP AND TBW.TBW_CODPRO = '"+aColsAc[n][nPosCol]+"' "
Endif
cQuery += "WHERE TB7.D_E_L_E_T_ <> '*' AND TB6.D_E_L_E_T_ <> '*' AND TB6.TB6_STATUS <> '2' AND "
If lColetor
	cQuery += "TBW.D_E_L_E_T_ <> '*' AND "
Endif
cQuery += "TB7.TB7_CODRES = '"+M->TDC_CODRES+"' AND TB7.TB7_TIPO = '6'"

cQuery := ChangeQuery(cQuery)
MPSysOpenQuery( cQuery , cAliasQry )

//Preenche TRB com os registros
dbSelectArea(cAliasQry)
dbGoTop()
While !eof()
	//Verifica se ้ F3 ou Valida็ใo
	If !lValid
		dbSelectArea(cAliasAcon)
		dbSetOrder(1)
		If !dbSeek((cAliasQry)->TB7_CODTIP)
			RecLock((cAliasAcon),.T.)
			(cAliasAcon)->CODACON	:= (cAliasQry)->TB7_CODTIP
			(cAliasAcon)->DESACON	:= (cAliasQry)->TB6_DESCRI
			MsUnlock((cAliasAcon))
		Endif
	Else
		If M->TDD_ACONDI == (cAliasQry)->TB7_CODTIP
			lRet := .T.
			Exit
		Endif
	Endif
	dbSelectArea(cAliasQry)
	dbSkip()
End
dbSelectArea(cAliasQry)
dbCloseArea()

//Verifica se ้ F3 ou Valida็ใo
If !lValid
	//Fun็ใo que monta Consulta Padrใo
	If NGCONPDTRB(cAliasAcon,aOpcao,aCamposF3,40,STR0005) //"Acondicionamento"
		lRet := .T.
		//Posiciona no registro para retorno
		dbSelectArea("TB6")
		dbSetOrder(1)
		dbSeek(xFilial("TB6")+(cAliasAcon)->CODACON)
	Else
		lRet := .F.
	Endif
	//Deleta arquivo temporแrio e restaura area
	oTempTRB:Delete()
Else
	If lRet
		dbSelectArea("TB6")
		dbSetOrder(1)
		dbSeek(xFilial("TB6")+M->TDD_ACONDI)
	Else
		Help("",1,"REGNOIS")
	Endif
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณSG510DES  ณ Autor ณRoger Rodrigues        ณ Data ณ17/03/2011ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFuncao para trazer FMRs destinadas	                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณSIGASGA                                                     ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function SG510DES()

lAleat := !lAleat

If !lAleat
	dbSelectArea("TDC")
	Set Filter to TDC->TDC_STATUS <> "7"
	DbSeek(xFilial("TDC"))
Else
	MsgRun(STR0049,STR0050,{ || SG510FIL() } ) //"Selecionando FMRs"###"Aguarde..."
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณSG510FIL  ณ Autor ณRoger Rodrigues        ณ Data ณ17/03/2011ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFuncao para filtrar todas FMRs		                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณSIGASGA                                                     ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function SG510FIL()

DbSelectArea("TDC")
Set Filter to
DbSeek(xFilial("TDC"))

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG510CPY  บAutor  ณRoger Rodrigues     บ Data ณ  17/03/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz copia dos coletores                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA510                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG510CPY()
Local oDlgCpy, oQtd, i, j, aArray := {}, aArray2 := {}
Local aColsAc	:= oGetAc:aCols
Local aHeadAc	:= oGetAc:aHeader
Local n := oGetAc:nAt
Local nPosCol	:= aScan(aHeadAc, {|x| Trim(Upper(x[2])) == "TDD_COLET"})
Local nPosPes	:= aScan(aHeadAc, {|x| Trim(Upper(x[2])) == "TDD_PESO"})
Local nPosSeq	:= aScan(aHeadAc, {|x| Trim(Upper(x[2])) == "TDD_SEQUEN"})
Private lRet  := .f., nQtd := 0

//Verifica se estแ no folder de coletores
If oFolder510:nOption <> 1
	ShowHelpDlg(STR0003,{STR0051},; //"Aten็ใo"###"Op็ใo disponํvel somente quando o folder Acondicionamento estแ selecionado."
							2,{STR0052}) //"Selecione o folder Acondicionamento."
	Return .F.
Endif
//Verifica se o coletor esta preenchido
If Empty(aColsAc[n][nPosCol])
	ShowHelpDlg(STR0003,{STR0053,STR0054},2) //"Aten็ใo"###"Favor selecionar um registro com coletor"###"jแ preenchida."
	Return .F.
Endif

//Monta tela perguntando quantidade de coletores
DEFINE MSDIALOG oDlgCpy FROM  0,0 TO 100,230 TITLE OemToAnsi(STR0055) PIXEL //"C๓pia de Coletores"

@ 12,05 Say STR0056 of oDlgCpy Pixel //"Quantidade a copiar:"
@ 10,70 MsGet oQtd Var nQtd Size 15,8 of oDlgCpy Pixel Picture "999" Valid Positivo()

DEFINE SBUTTON FROM 35,50  TYPE 1 ENABLE OF oDlgCpy ACTION EVAL({|| If(Positivo(nQtd),(lRET := .T.,oDlgCpy:END()),lRet := .F.)})
DEFINE SBUTTON FROM 35,80 TYPE 2 ENABLE OF oDlgCpy ACTION oDlgCpy:END()

ACTIVATE MSDIALOG oDlgCpy CENTERED

If lRet
	cSeq := aColsAc[Len(aColsAc)][nPosSeq]
	//Copia linha do coletor
	aArray := aClone(aColsAc[n])
	aArray2:= aColsAc
	aColsAc := {}
	oGetAc:aCols := {}
	//Zera peso
	aArray[nPosPes] := 0
	//Adiciona novos itens
	For i:=1 To nQtd
		cSeq := StrZero(Val(cSeq)+1,3)
		aArray[nPosSeq] := cSeq
		aADD(aArray2,aArray)
		aArray2 := aClone(aArray2)
	Next i
	oGetAc:aCols := aArray2
	oGetAc:ForceRefresh()
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG510RQNC บAutor  ณRoger Rodrigues     บ Data ณ  22/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se FMR deve ser Reaberta ao Finalizar FNC          บฑฑ
ฑฑบ          ณIntegracao com SIGAQNC                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGASGA/SIGAQNC                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG510RQNC(cCodFNC)
Local aAreaQI2 := GetArea("QI2")
Local lOldInclui := Inclui
Local lOldAltera := Altera

dbSelectArea("TDC")
dbSetOrder(7)
If dbSeek(xFilial("TDC")+cCodFNC)//Procura FMR da FNC
	//Verifica se o status ainda ้ nใo conforme
	If TDC->TDC_STATUS == "4" .and. TDC->TDC_LIBRES == "2"
		//Inicializa Varํaveis para a fun็ใo SG510GRAVA
		nOpcx 	:= 4
		Inclui	:= .F.
		Altera	:= .T.
		lFabrica:= .F.
		RegToMemory("TDC",.F.)
		//Acondicionamentos
		aHeadAcon := CabecGetd("TDD",{'TDD_CODFMR'})
		aColsAcon := MakeGetd("TDD",TDC->TDC_CODFMR,aHeadAcon,;
						"TDD->TDD_FILIAL == xFilial('TDD') .And. TDD->TDD_CODFMR == TDC->TDC_CODFMR",,.F.)
		If Empty(aColsAcon)
		   aColsAcon := BlankGetd(aHeadAcon)
		Endif
		aSvAcon := aClone(aColsAcon)

		//Responsแveis
		aHeadResp := CabecGetd("TDE",{'TDE_CODFMR'})
		aColsResp := MakeGetd("TDE",TDC->TDC_CODFMR,aHeadResp,;
						"TDE->TDE_FILIAL == xFilial('TDE') .And. TDE->TDE_CODFMR == TDC->TDC_CODFMR",,.F.)

		If Empty(aColsResp)
		   aColsResp := BlankGetd(aHeadResp)
		Endif
		aSvRe := aClone(aColsResp)

		//Grava FMR e hist๓rico
		SG510GRAVA(.T.,{aHeadAcon,aColsAcon},{aHeadResp,aColsResp})
	Endif
Endif

Inclui := lOldInclui
Altera := lOldAltera

//Restaura QI2
RestArea(aAreaQI2)
dbSelectArea("QI2")
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSG510RELACบAutor  ณRoger Rodrigues     บ Data ณ  27/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRelacao dos campos da tela                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSGAA510                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SG510RELAC(cCampo)
Local cRetorno := ""

If cCampo == "M->TDC_RESPON"
	If Inclui
		cRetorno := cUserName
	Else
		cRetorno := TDC->TDC_RESPON
	Endif
Endif

Return cRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} fExtornoFMR
Realiza o Extorno quando Cancelamento vindo de Armazem

@samples fExtornoFMR()

@return L๓gico - Caso extorno esteja correto, retorna verdadeiro

@author Jackson Machado
@since 30/04/2013
/*/
//---------------------------------------------------------------------
Static Function fExtornoFMR()

	Local nDes		:= 0			//Contador de For
	Local cMsg		:= ""			//String indicativa da mensagem de erro
	Local cProdMsg	:= ""			//Produtos que estao com o saldo errado para mensagem de erro
	Local cDocumSD3	:= ""			//Recebe o valor do documento para geracao da SD3
	Local lRet 		:= .T.			//Variavel de controle de retorno
	Local lSaldoOk	:= .T.			//Indica se os Saldos estใo todos certos
    Local aDestinos	:= {}			//Array contendo os destinos dos resํduos
    Local aNumSeqD	:= {}			//Recebera o retorno do ExecAuto
    Local aArea		:= GetArea()	//Salva a area

	If AllTrim( GetMv( "MV_NGSGAES" ) ) <> "N"//Verifica se possui integracao com Estoque

		//Localiza a ocorr๊ncia
		dbSelectArea( "TB0" )
		dbSetOrder( 1 )
		dbSeek( xFilial( "TB0" ) + M->TDC_CODOCO )

		//Posiciona na Localiza็ใo
		dbSelectArea( "TBJ" )
		dbSetOrder( 1 )
		dbSeek( xFilial( "TBJ" ) + M->TDC_CODOCO )

		//Localiza os Destinos vinculados a Ocorr๊ncia
		dbSelectArea( "TB4" )
		dbSetOrder( 1 )
		dbSeek( xFilial( "TB4" ) + TB0->TB0_CODOCO )
		While TB4->( !Eof() ) .And. TB4->TB4_FILIAL == xFilial( "TB4" ) .And. ;
				TB4->TB4_CODOCO == TB0->TB0_CODOCO

			aAdd( aDestinos , { TB4->TB4_CODDES , TB4->TB4_QUANTI , TB4->TB4_UNIMED , TB4->TB4_LOTECT , TB4->TB4_NUMLOT , TB4->TB4_DTVALI } )

			TB4->( dbSkip() )
		End
		If AllTrim( GetMv( "MV_ESTNEG" ) ) == "S"
			For nDes := 1 To Len( aDestinos ) //Percorre todos os Destinos
				//Posiciona no Destino
				dbSelectArea( "TB2" )
				dbSetOrder( 1 )
				dbSeek( xFilial( "TB2" ) + aDestinos[ nDes , 1 ] )

				//Localiza o Centro de Custo
				cCCusto := NGSEEK( "TAF" , TBJ->TBJ_CODNIV , 8 , "TAF->TAF_CCUSTO" )
				If Empty(cCCusto)
					cCCusto   := NGSeek( "SB1" , TB0->TB0_CODRES , 1 , "SB1->B1_CC" )
				EndIf

				//Verifica o saldo na SB2, caso nao exista, altera valor de controle do saldo para falso e monta a mensagem
				If !NGSALSB2( M->TDC_CODRES , TB2->TB2_CODALM , aDestinos[ nDes , 2 ] , .F. )
					lSaldoOK := .F.
					cProdMsg += Alltrim( M->TDC_CODRES )
					cProdMsg += " - "
					cProdMsg += AllTrim( NGSeek( "SB1" , M->TDC_CODRES , 1 , "SB1->B1_DESC" ) )
					cProdMsg += ": "
					cProdMsg += cValToChar( aDestinos[ nDes , 2 ] ) + " "
					cProdMsg += NGSeek( "SAH" , aDestinos[ nDes , 3 ] , 1 , "SAH->AH_UMRES" )
					cProdMsg += CRLF
				EndIf

			Next nDes
		EndIf

		If lSaldoOk//Caso saldo esteja correto
			For nDes := 1 To Len( aDestinos ) //Percorre todos os Destinos
				//Posiciona no Destino
				dbSelectArea( "TB2" )
				dbSetOrder( 1 )
				dbSeek( xFilial( "TB2" ) + aDestinos[ nDes , 1 ] )

				//Localiza o Centro de Custo
				cCCusto := NGSEEK( "TAF" , TBJ->TBJ_CODNIV , 8 , "TAF->TAF_CCUSTO" )
				If Empty(cCCusto)
					cCCusto   := NGSeek( "SB1" , TB0->TB0_CODRES , 1 , "SB1->B1_CC" )
				EndIf

				cDocumSD3 := NextNumero( "SD3" , 2 , "D3_DOC" , .T. ) //Gera um novo Doc.

				//Chama a fun็ใo para gerar movimentacao. Retorno : { SD3->D3_NUMSEQ , lMsErroAuto }
				aNumSeqD  := SgMovEstoque( "RE0" , TB2->TB2_CODALM , M->TDC_CODRES , "" , aDestinos[ nDes , 3 ] , ;
						aDestinos[ nDes , 2 ] , TB0->TB0_DATA , cDocumSD3 , aDestinos[ nDes , 4 ] , aDestinos[ nDes , 5 ] , ;
						aDestinos[ nDes , 6 ] , .F. , , cCCusto )

				If aNumSeqD[ 2 ]//Caso nao gere corretamente, retorna a funcao
					lRet := .F.
					Exit
				EndIf
			Next nDes
		Else
			//Caso saldo incorreto, exibe mensagem de log do problema
			cMsg += STR0059 + CRLF//"O(s) seguinte(s) produto(s) nใo possue(m) o saldo necessแrio: "
			cMsg += cProdMsg
			If FindFunction( "NGMSGMEMO" )
			 	NGMsgMemo( STR0003 , cMsg )	//"Aten็ใo"
			Else
				ApMsgInfo( cMsg , STR0003 )	//"Aten็ใo"
			EndIf
			lRet := .F.
	    EndIf
	EndIf

	RestArea( aArea )//Retorna a area atual
Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} VerifyFilt
Fun็ใo utilizada pelo TNGPG, para planta grแfica no m๓dulo de SGA.
Verifica os filtros, preenche a tela de inclusใo de FMR, conforme o conte๚do do array.

@author Gabriel Augusto Werlich
@since 07/07/2014
@version MP11
@return Retorna os valores a ser prenchidos nos campos de mem๓ria da tela.
/*/
//---------------------------------------------------------------------
Static Function VerifyFilt(aDadosFmr)

	Local i

	For i := 1 to Len(aDadosFmr)

		&("M->"+aDadosFmr[i][1]) := aDadosFmr[i][2]
		If ExistTrigger(aDadosFmr[i][1]) //Verifica se existe trigger para este campo
			RunTrigger(1,,,,aDadosFmr[i][1])
		Endif

	Next

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} BuildFilter
Fun็ใo utilizada pelo TNGPG, para planta grแfica no m๓dulo de SGA.
Verifica o campo passado por param๊tro

@author Gabriel Augusto Werlich
@since 03/07/2014
@version MP11
@return cFiltro, retorna a String a ser passada para o Set Filter.
/*/
//---------------------------------------------------------------------
Static Function BuildFilter(aFiltroFmr)

	Local cFiltro := ""
	Local i

	For i := 1 to Len(aFiltroFmr)
		cFiltro += If(i > 1," And ", "")
		cFiltro += aFiltroFmr[i][1] + " = '" + aFiltroFmr[i][2] + "'"
	Next

Return cFiltro

//-----------------------------------------------------------------------
/*{Protheus.doc} SGA510WHRE


@author Juliani Schlickmann Damasceno
@since 25/02/2014
@version 1.0
*/
//-----------------------------------------------------------------------
Function SGA510WHRE()
Return Type("lSg510WRes") <> "L" .Or. lSg510WRes

//-----------------------------------------------------------------------
/*{Protheus.doc} SGA510WHPT


@author Juliani Schlickmann Damasceno
@since 25/02/2014
@version 1.0
*/
//-----------------------------------------------------------------------
Function SGA510WHPT()
Return Type("lSg510WPto") <> "L" .Or. lSg510WPto

//-----------------------------------------------------------------------
/*{Protheus.doc} SGA510WHRE


@author Juliani Schlickmann Damasceno
@since 25/02/2014
@version 1.0
*/
//-----------------------------------------------------------------------
Function SGA510WHDP()
Return Type("lSg510WDep") <> "L" .Or. lSg510WDep

//---------------------------------------------------------------------
/*{Protheus.doc} Sga510FTAV

@author Juliani Schlickmann Damasceno
@since 05/09/2014

@Return lRet
/*/
//---------------------------------------------------------------------
Function Sga510FTAV()

Local lRet	:= .F.

If Type("cDepto510") == "C"
	dbSelectArea("TAV")
	dbSetOrder(1)
	lRet := dbSeek(xFilial("TAV") + TAX->TAX_CODRES + "001" + cDepto510)

	dbSelectArea("TAX")
EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fDeletaOco
Deleta a ocorr๊ncia ligada a FMR quando a mesma ้ cancelada.

@type function

@source SGAA510.prw

@author Gabriel Gustavo de Mora
@since 08/02/2017

@sample fDeletaOco()

@return Nil
/*/
//---------------------------------------------------------------------
Static Function fDeletaOco()

	Local aArea	  := GetArea()
	Local aRelacio := {}

	//Deleta relacionamentos da Ocorr๊ncia
	dbSelectArea("TB4") //Destino dos Residuos
	dbSetOrder(1) //TB4_FILIAL + TB4_CODOCO
	If MsSeek(xFilial("TB4") + M->TDC_CODOCO)
		RecLock("TB4",.F.)
			TB4->(dbDelete())
		TB4->(MsUnlock())
	EndIf

	dbSelectArea("TBJ") //Ocorr๊ncia do Processo
	dbSetOrder(1) //TBJ_FILIAL + TBJ_CODOCO
	If MsSeek(xFilial("TBJ") + M->TDC_CODOCO)
		RecLock("TBJ",.F.)
			TBJ->(dbDelete())
		TBJ->(MsUnlock())
	EndIf

	//Deleta Ocorr๊ncia
	dbSelectArea("TB0")
	dbSetOrder(1)
	If MsSeek(xFilial("TB0") + M->TDC_CODOCO)
		RecLock("TB0",.F.)
			TB0->(dbDelete())
		TB0->(MsUnlock())
	EndIf
	M->TDC_CODOCO := ""

	RestArea(aArea)

Return Nil
//---------------------------------------------------------------------
/*/{Protheus.doc} fVerifOco
Verifica se a ocorr๊ncia ligada a FMR estแ sendo utilizada em uma composi็ใo de carga.

@type function

@source SGAA510.prw

@author Gabriel Gustavo de Mora
@since 08/02/2017

@sample fVerifOco()

@return L๓gico, Retorna verdadeiro se a FMR pode ser cancelada.
/*/
//---------------------------------------------------------------------
Static Function fVerifOco()

	Local lRet		:= .T.
	Local aArea 	:= GetArea()

	dbSelectArea("TDJ") //Itens da composi็ใo
	dbSetOrder(2) //TDJ_FILIAL + TDJ_CODOCO
	If MsSeek(xFilial("TDJ") + TDC->TDC_CODOCO)
		ShowHelpDlg("Aten็ใo",{"A Ocorr๊ncia ligada a esta FMR estแ sendo utilizada em uma Composi็ใo de Carga"},2,{"Exclua a Composi็ใo de Carga onde a Ocorr๊ncia estแ sendo usada"},1)
		lRet := .F.
	EndIf

	RestArea(aArea)

Return lRet
