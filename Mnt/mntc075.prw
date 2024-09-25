#INCLUDE "MNTC075.ch"
#include "Protheus.ch"
#include "MsGraphi.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMNTC075   บAutor  ณRoger Rodrigues     บ Data ณ  25/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrafico da curva de custos do bem                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTA080                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC075(cCodBem)

	Local aNGBEGINPRM := NGBEGINPRM()
	Local oDlg, nOS := 0
	Local oFont1 := TFont():New("Arial",,-12,,.T.)
	Local oFont2 := TFont():New("Arial",,-20,,.T.)

	//Variaveis de Largura/Altura da Janela
	Local aSize   := MsAdvSize(.F.)
	Private nLargura  := aSize[5]
	Private nAltura   := aSize[6]
	Private nPosIni   := aSize[7]

	Private aOs := {}

	Private cDataIni := CTOD("  /  /  ")
	Private cDataFim := CTOD("  /  /  ")

	Private cPerg := "MNC075"

	aNgButton	:= {}

	If cCodBem == Nil
		MsgStop(STR0001) //"Favor escolher um bem."
		Return
	Endif

	dbSelectArea("ST9")
	dbSetOrder(1)
	dbSeek(xFilial("ST9")+cCodBem)
	cDataIni := ST9->T9_DTCOMPR
	If Empty(ST9->T9_DTBAIXA)
		cDataFim := dDataBase
	Else
		cDataFim := ST9->T9_DTBAIXA
	Endif

	Define MsDialog oDlg From nPosIni,0 To nAltura,nLargura Pixel Title STR0002 Color CLR_BLACK,CLR_WHITE //"Curva de Custos"
	oDlg:lEscClose := .F.
	oDlg:lMaximized := .T.
	@ 07,005 Say OemToansi(STR0003) of oDlg Pixel Font oFont1 //"Bem:"
	@ 07,022 Say AllTrim(cCodBem)+" - "+AllTrim(ST9->T9_NOME)	of oDlg Pixel Font oFont1

	@ 040, 000 MsGraphic oGrafCus Size nLargura/2,(nAltura/2)- 58 - nPosIni/2 Of oDlg Pixel
	oGrafCus:bLDblClick := {|| MNT75OS(cCodBem)}
	@ (nAltura/2)-14 - nPosIni/2,nLargura/2-200 Button STR0004 Size 40,14 Of oDlg Pixel Action MNT75OS(cCodBem) //"Visualizar OS's"
	@ (nAltura/2)-14 - nPosIni/2,nLargura/2-150 Button STR0005 Size 40,14 Of oDlg Pixel Action IMP075() //"Imprimir"
	@ (nAltura/2)-14 - nPosIni/2,nLargura/2-100 Button STR0006 Size 40,14 Of oDlg Pixel Action GrafSavBmp(oGrafCus) //"Salvar"
	@ (nAltura/2)-14 - nPosIni/2,nLargura/2-50  Button STR0007 Size 40,14 Of oDlg Pixel Action oDlg:End() //"Sair"

	Pergunte( cPerg, .T. )

	Processa({ |lEnd| CARGRAF75(cCodBem,cDataIni,cDataFim) },STR0008, STR0009) //"Aguarde"###"Gerando Grแfico"

	Activate MsDialog oDlg Centered

	NGRETURNPRM(aNGBEGINPRM)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CARGRAF75
Busca as Ordens de Servi็o Corretiva e de Reforma no perํodo e monta Grแfico

@author  Roger Rodrigues
@since   23/07/09
@version P11/P12
@param   cCodBem, Caracter, C๓digo do Bem
@param   cDtIni , Caracter, Data inicial
@param   cDtFim , Caracter, Data fim
/*/
//-------------------------------------------------------------------
Static Function CARGRAF75(cCodBem,cDtIni,cDtFim)
	Local i      := 1
	Local nMeses := 0
	aOS := {}
	aMeses := RETMESES(cDtIni,cDtFim)//Funcao encontrada no MNTC085, retorna os meses/ano do periodo corrente
	oGrafCus:DelSerie(1)
	oGrafCus:l3D := .F.
	oGrafCus:SetMargins( 0, 5, 0, 5 )
	oGrafCus:SetTitle(AllTrim(cCodBEm)+" - "+Alltrim(ST9->T9_NOME),,CLR_RED,A_CENTER, GRP_TITLE)
	oGrafCus:SetTitle("",STR0010,CLR_GREEN, A_LEFTJUST, GRP_TITLE  ) //"Custos"
	oGrafCus:SetTitle(STR0011,"", CLR_GREEN, A_CENTER, GRP_FOOT  ) //"Perํodo"
	nSerie := oGrafCus:CreateSerie(1,STR0010) //"Custos"

	If nSerie != GRP_CREATE_ERR
		MsgRun( STR0012, STR0008 ,{ || CARREG075(cCodBem,cDtIni,cDtFim) }) //"Processando Informa็๕es"###"Aguarde"
		If Len(aOS) > 0
			//Ordena por Data
			aSort(aOS,,,{|x,y| x[2] < y[2]})
			//Adiciona os pontos ao grแfico
			ProcRegua(Len(aOS))
			For i:=1 to Len(aOS)
				IncProc()
				If Month(aOS[i][2]) == 1
					cMes := STR0013 //"JAN/"
				ElseIf Month(aOS[i][2]) == 2
					cMes := STR0014 //"FEV/"
				ElseIf Month(aOS[i][2]) == 3
					cMes := STR0015 //"MAR/"
				ElseIf Month(aOS[i][2]) == 4
					cMes := STR0017 //"ABR/"
				ElseIf Month(aOS[i][2]) == 5
					cMes := STR0016 //"MAI/"
				ElseIf Month(aOS[i][2]) == 6
					cMes := STR0018 //"JUN/"
				ElseIf Month(aOS[i][2]) == 7
					cMes := STR0019 //"JUL/"
				ElseIf Month(aOS[i][2]) == 8
					cMes := STR0020 //"AGO/"
				ElseIf Month(aOS[i][2]) == 9
					cMes := STR0021 //"SET/"
				ElseIf Month(aOS[i][2]) == 10
					cMes := STR0022 //"OUT/"
				ElseIf Month(aOS[i][2]) == 11
					cMes := STR0023 //"NOV/"
				Else
					cMes := STR0024 //"DEZ/"
				Endif
				cAno := SUBSTR(ALLTRIM(STR(Year(aOs[i][2]))),3)
				If (nPos := aScan(aMeses, {|x| x[1] == cMes+cAno })) > 0
					aMeses[nPos][2] += aOS[i][1]
				Endif
			Next i

			nMaior := 0
			nMeses := Len(aMeses)
			For i := 1 To nMeses
				If aMeses[i][2] > nMaior
					nMaior := aMeses[i][2]
				Endif
				oGrafCus:Add( 1, aMeses[i][2], aMeses[i][1], CLR_RED )
			Next i

			// Caso possua s๓ um registro, ้ adicionado novamente para
			// o grแfico ser apresentado corretamente
			If nMeses == 1
				oGrafCus:Add( 1, aMeses[1][2], aMeses[1][1], CLR_RED )
			EndIf
			oGrafCus:SetRangeY( 0, nMaior + 1 )
			oGrafCus:l3D := .T.
			oGrafCus:l3D := .F.
			oGrafCus:Refresh()
		Else
			ApMsgAlert(STR0025) //"O Bem nใo possui custos."
			Return .F.
		Endif

	Else
		ApMsgAlert(STR0026) //"Nใo foi possํvel gerar a consulta."
	Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCARREG075 บAutor  ณRoger Rodrigues     บ Data ณ  20/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega os registros de Ordem de servi็o corretivas do bem  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC075                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CARREG075(cCodBem,cDtIni,cDtFim)
	aOS := {}

	//Pega Valor de compra do bem
	If MV_PAR01 == 1
		aADD( aOs, {ST9->T9_VALCPA, cDtIni, ""})
	EndIf
	//Carrega O.S. da STJ
	cArqSTJ := GetNextAlias()
	cQuery := "SELECT SUM(STL.TL_CUSTO) AS CUSTO,MIN(STL.TL_DTINICI) AS DTINI,STJ.TJ_ORDEM"
	cQuery += " FROM "+RetSqlName("STL")+" STL,"+RetSqlName("STJ")+" STJ"
	cQuery += " WHERE STL.D_E_L_E_T_ <> '*' AND STL.TL_FILIAL = '"+xFilial("STL")+"'"
	cQuery += " AND STL.TL_ORDEM = STJ.TJ_ORDEM AND STL.TL_SEQRELA <> '0'"
	cQuery += " AND STL.TL_DTINICI >= '"+DTOS(cDtIni)+"' AND STL.TL_DTINICI <= '"+DTOS(cDtFim)+"'"
	cQuery += " AND STJ.TJ_CODBEM = '"+cCodBem+"' AND STJ.D_E_L_E_T_ = ''"
	cQuery += " AND STJ.TJ_FILIAL = '"+xFilial("STJ")+"' AND STJ.TJ_SITUACA = 'L' "
	cQuery += " GROUP BY STJ.TJ_ORDEM"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArqSTJ,.T.,.T.)

	dbSelectArea(cArqSTJ)
	dbGoTop()
	While !eof()
		If !Empty((cArqSTJ)->DTINI)
			aADD( aOS, {(cArqSTJ)->CUSTO, STOD((cArqSTJ)->DTINI), (cArqSTJ)->TJ_ORDEM} )
		EndIf
		dbSelectArea(cArqSTJ)
		dbSkip()
	End

	//Carrega as O.S. do bens filhos na STJ
	cArqSTJFil := GetNextAlias()
	cQuery := "SELECT SUM(STL.TL_CUSTO) AS CUSTO,MIN(STL.TL_DTINICI) AS DTINI,STJ.TJ_ORDEM"
	cQuery += " FROM "+RetSqlName("STL")+" STL,"+RetSqlName("STJ")+" STJ,"+RetSqlName("STZ")+" STZ"
	cQuery += " WHERE STL.D_E_L_E_T_ <> '*' AND STL.TL_FILIAL = '"+xFilial("STL")+"'"
	cQuery += " AND STL.TL_ORDEM = STJ.TJ_ORDEM AND STL.TL_SEQRELA <> '0'"
	cQuery += " AND STL.TL_DTINICI >= STZ.TZ_DATAMOV AND STL.TL_DTINICI <= STZ.TZ_DATASAI"
	cQuery += " AND (STZ.TZ_DATAMOV||STZ.TZ_HORAENT) >= ('"+DTOS(cDtIni)+"'||STL.TL_HOFIM)"
	cQuery += " AND (STZ.TZ_DATASAI||STZ.TZ_HORASAI) <= ('"+DTOS(cDtFim)+"'||STL.TL_HOFIM)"
	cQuery += " AND STZ.TZ_BEMPAI = '"+cCodBem+"' "
	cQuery += " AND STJ.TJ_CODBEM = STZ.TZ_CODBEM AND STJ.D_E_L_E_T_ <> '*' AND STZ.D_E_L_E_T_ <> '*'"
	cQuery += " AND STZ.TZ_FILIAL = '"+xFilial("STZ")+"' AND STJ.TJ_FILIAL = '"+xFilial("STJ")+"'"
	cQuery += " AND STJ.TJ_SITUACA = 'L' "
	cQuery += " GROUP BY STJ.TJ_ORDEM"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArqSTJFil,.T.,.T.)

	dbSelectArea(cArqSTJFil)
	dbGoTop()
	While !eof()
		If !Empty((cArqSTJFil)->DTINI)
			aADD( aOS, {(cArqSTJFil)->CUSTO, STOD((cArqSTJFil)->DTINI),(cArqSTJFil)->TJ_ORDEM} )
		EndIf
		dbSelectArea(cArqSTJFil)
		dbSkip()
	End

	//Carrega O.S. da STS
	cArqSTS := GetNextAlias()
	cQuery := "SELECT (SELECT SUM(STT.TT_CUSTO) FROM "+RetSqlName("STT")+" "
	cQuery += "STT WHERE STT.D_E_L_E_T_ <> '*' AND STT.TT_FILIAL = '"+xFilial("STT")+"' "
	cQuery += "AND STT.TT_ORDEM = STS.TS_ORDEM AND STT.TT_SEQRELA <> '0') AS CUSTO, STS.TS_DTMRINI, STS.TS_ORDEM ""
	cQuery += "FROM "+RetSqlName("STS")+" STS WHERE STS.TS_CODBEM = '"+cCodBem+"'"
	cQuery += " AND STS.D_E_L_E_T_ = '' AND STS.TS_DTMRINI >= '"+DTOS(cDtIni)+"' AND STS.TS_DTMRINI <= '"+DTOS(cDtFim)+"'"
	cQuery += " AND STS.TS_FILIAL = '"+xFilial("STS")+"' AND STS.TS_SITUACA = 'L'"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArqSTS,.T.,.T.)

	dbSelectArea(cArqSTS)
	dbGoTop()
	While !eof()
		aADD( aOS, {(cArqSTS)->CUSTO, STOD((cArqSTS)->TS_DTMRINI), (cArqSTS)->TS_ORDEM} )
		dbSelectArea(cArqSTS)
		dbSkip()
	End

	//Carrega as O.S. do bens filhos na STS
	cArqSTSFil := GetNextAlias()
	cQuery := "SELECT (SELECT SUM(STT.TT_CUSTO) FROM "+RetSqlName("STT")+" "
	cQuery += "STT WHERE STT.D_E_L_E_T_ <> '*' AND STT.TT_FILIAL = '"+xFilial("STT")+"' "
	cQuery += "AND STT.TT_ORDEM = STS.TS_ORDEM AND STT.TT_SEQRELA <> '0') AS CUSTO, STS.TS_DTMRINI, STS.TS_ORDEM"
	cQuery += " FROM "+RetSqlName("STS")+" STS "
	cQuery += "JOIN "+RetSqlName("STZ")+" STZ ON STZ.TZ_BEMPAI = '"+cCodBem+"' "
	cQuery += "WHERE STS.TS_CODBEM = STZ.TZ_CODBEM "
	cQuery += "AND STS.D_E_L_E_T_ <> '*' AND STZ.D_E_L_E_T_ <> '*' "
	cQuery += "AND STS.TS_DTMRINI >= STZ.TZ_DATAMOV AND STS.TS_DTMRINI <= STZ.TZ_DATASAI "
	cQuery += "AND (STZ.TZ_DATAMOV||STZ.TZ_HORAENT) >= ('"+DTOS(cDtIni)+"'||STS.TS_HOMRFIM) "
	cQuery += "AND (STZ.TZ_DATASAI||STZ.TZ_HORASAI) <= ('"+DTOS(cDtFim)+"'||STS.TS_HOMRFIM) "
	cQuery += "AND STZ.TZ_FILIAL = '"+xFilial("STZ")+"' AND STS.TS_FILIAL = '"+xFilial("STS")+"' AND STS.TS_SITUACA = 'L'"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArqSTSFil,.T.,.T.)

	dbSelectArea(cArqSTSFil)
	dbGoTop()
	While !eof()
		aADD( aOS, {(cArqSTSFil)->CUSTO, STOD((cArqSTSFil)->TS_DTMRINI),(cArqSTSFil)->TS_ORDEM} )
		dbSelectArea(cArqSTSFil)
		dbSkip()
	End

	dbSelectArea(cArqSTJ)
	dbCloseArea()
	dbSelectArea(cArqSTS)
	dbCloseArea()
	dbSelectArea(cArqSTJFil)
	dbCloseArea()
	dbSelectArea(cArqSTSFil)
	dbCloseArea()

Return aOs

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIMP075    บAutor  ณRoger Rodrigues     บ Data ณ  20/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime o grafico                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC075                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function IMP075()
	Local oDlg1
	Local nModoImp := 1
	Local lRet := .F.
	Private cImgPath := ""
	Private cPathBmp := Alltrim(GetMv("MV_DIRACA"))// Path do arquivo logo .bmp do cliente
	cFileLogo := NGLOCLOGO()

	DEFINE MSDIALOG oDlg1 FROM  0,0 TO 150,320 TITLE STR0027 PIXEL//"Modo de Impressao"

	@ 20,14 RADIO oRadOp VAR nModoImp ITEMS STR0028,STR0029 SIZE 70,15 PIXEL OF oDlg1

	DEFINE SBUTTON FROM 59,90  TYPE 1 ENABLE OF oDlg1 ACTION EVAL({|| lRET := .T.,oDlg1:END()})
	DEFINE SBUTTON FROM 59,120 TYPE 2 ENABLE OF oDlg1 ACTION oDlg1:END()

	ACTIVATE MSDIALOG oDlg1 CENTERED

	If lRet
		oPrintCurva	:= TMSPrinter():New(OemToAnsi(STR0030))//"Curva de Custos"
		oPrintCurva:SetLandScape()
		//Cria Imagem para impressao
		oGrafCus:SaveToImage("CurvaCust.BMP", cPathBmp, "BMP" )
		cImgPath := cPathBmp+"CurvaCust.BMP"
		Lin := 75
		oPrintCurva:Line(lin,25,lin,3125)
		Lin := 150
		oPrintCurva:StartPage()

		If File(cFileLogo)
			oPrintCurva:SayBitMap(110,40,cFileLogo,250,150)
		EndIf

		oPrintCurva:Say(lin+20,1400,STR0030)//"Curva de Custos"
		oPrintCurva:Say(lin+45,2900,STR0031 + cValToChar(Date()))//"Data :"
		oPrintCurva:Say(lin+80,2900,STR0032 + Time(),)//"Hora :"
		lin := 300
		oPrintCurva:Line(lin,25,lin,3125)
		If File(cImgPath)
			oPrintCurva:SayBitmap(lin+100,100,cImgPath,3000,2000)
		Endif
		oPrintCurva:EndPage()
		If nModoImp == 1
			oPrintCurva:Preview()
		Else
			If oPrintCurva:Setup()
				oPrintCurva:Print()
			Endif
		Endif
		//Apaga Imagem apos impressao
		If File(cImgPath)
			Ferase(cImgPath)
		Endif
	Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMNT75OS   บAutor  ณRoger Rodrigues     บ Data ณ  21/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMostra as O.S. do bem e filhos                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC075                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MNT75OS(cBem)
	Local oDlgOpc
	Local lRet := .F.
	Local cMes := Space(2), cAno := Space(4)

	DEFINE MSDIALOG oDlgOpc FROM 0,0 TO 130,280 TITLE STR0004 PIXEL//"Visualizar OS's"

	@ 10,14  Say STR0034 Of oDlgOpc Pixel//"Informe um m๊s e ano para visualiza็ใo das OS's"

	@ 25,14  SAY STR0035 OF oDlgOpc Pixel//"M๊s:"
	@ 23,30  MSGET cMes PICTURE "99" WHEN .T. SIZE 15,07 OF oDlgOpc Pixel Valid MNT085VAL(1,cMes)//Funcao do MNTC085 que valida Periodo

	@ 25,55  SAY STR0036 OF oDlgOpc Pixel//"Ano:"
	@ 23,69  MSGET cAno PICTURE "9999" WHEN .T. SIZE 30,07 OF oDlgOpc Pixel Valid MNT085VAL(2,cAno)//Funcao do MNTC085 que valida Periodo

	DEFINE SBUTTON FROM 45,14 TYPE 1 ENABLE OF oDlgOpc ACTION EVAL({|| lRET := .T.,oDlgOpc:END()})
	DEFINE SBUTTON FROM 45,44 TYPE 2 ENABLE OF oDlgOpc ACTION oDlgOpc:END()

	ACTIVATE MSDIALOG oDlgOpc CENTERED

	If lRet
		MsgRun( STR0012, STR0008 ,{ || MNTBRW075(cMes,cAno,cBem) })
	Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMNTBRW075 บAutor  ณRoger Rodrigues     บ Data ณ  21/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera Browse com O.S's                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNT75OSC                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MNTBRW075(cMes,cAno,cBem)
	Local oDlgBrw, oPanel
	Local i := 1
	Local aOSCus := {}
	Local oBrowseOs
	Local aHeadOsCor := {STR0037,STR0038,STR0039,STR0040,STR0041,STR0042,STR0043}//"Ordem"##"Tipo"##"Bem"##"Descricao"##"Servico"##"Custo Total"##"Dt. Ini. Man. Real"

	//Ordena por numero de Ordem da O.S.
	aSort(aOS,,,{|x,y| x[3] < y[3]})

	//Carrega as O.S. do periodo digitado
	For i:=1 to Len(aOs)
		If !Empty(aOs[i][3])
			If Month(aOs[i][2]) == Val(cMes) .AND. YEAR(aOs[i][2]) == Val(cAno)
				dbSelectArea("STJ")
				dbSetOrder(1)
				If dbSeek(xFilial("STJ")+aOs[i][3])
					If aScan(aOSCus, { |x| Trim(Upper(x[1])) == aOs[i][3] }) == 0
						aADD( aOSCus, { aOs[i][3], STJ->TJ_TIPOOS, STJ->TJ_CODBEM, NGSEEK("ST9",STJ->TJ_CODBEM,1,"T9_NOME"), STJ->TJ_SERVICO, AllTRIm(STR(aOs[i][1])), DTOC(aOs[i][2]) })
					Endif
				Else
					dbSelectArea("STS")
					dbSetOrder(1)
					If dbSeek(xFilial("STS")+aOs[i][3])
						If aScan(aOSCus, { |x| Trim(Upper(x[1])) == aOs[i][3] }) == 0
							aADD( aOSCus, { aOs[i][3], STS->TS_TIPOOS, STS->TS_CODBEM, NGSEEK("ST9",STS->TS_CODBEM,1,"T9_NOME"), STS->TS_SERVICO, AllTRIm(STR(aOs[i][1])), DTOC(aOs[i][2]) })
						Endif
					Endif
				Endif
			Endif
		Endif
	Next i

	//Gera browse com as O.S.
	If Len(aOSCus) > 0
		Define MsDialog oDlgBrw From nPosIni,0 To nAltura,nLargura Pixel Title STR0045 Color CLR_BLACK,CLR_WHITE//"OS's do Bem e seus bens filhos"
		oDlgBrw:lEscClose := .F.
		oDlgBrw:lMaximized := .T.

		oPanel := TPanel():New(0, 0, Nil, oDlgBrw, Nil, .T., .F., Nil, Nil, 0, 25, .T., .F. )
		oPanel:Align := CONTROL_ALIGN_TOP

		dbSelectArea("ST9")
		dbSetOrder(1)
		dbSeek(xFilial("ST9")+cBem)
		@ 05,005 Say OemToansi(STR0003) of oPanel Pixel//"Bem:"
		@ 05,022 Say AllTrim(cBem)+" - "+AllTrim(ST9->T9_NOME)	of oPanel Pixel
		@ 05,nLargura/2-100 Button STR0033 Size 40,14 Of oPanel Pixel Action MNT85VIS(aOSCus[oBrowseOs:nAt,01])//Funcao do MNTC085 que chama o NGCAD01###"Visualizar"
		@ 05,nLargura/2-50  Button STR0007 Size 40,14 Of oPanel Pixel Action oDlgBrw:End()//"Sair"

		oBrowseOs := TWBrowse():New( 25 , 01, nLargura-40, nAltura-40,,aHeadOsCor,{20,20,40,40,30,30,20}, oDlgBrw, ,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
		oBrowseOs:Align := CONTROL_ALIGN_ALLCLIENT
		oBrowseOs:SetArray(aOSCus)
		oBrowseOs:bLDblClick := {|| MNT85VIS(aOSCus[oBrowseOs:nAt,01])}
		oBrowseOs:bLine := {||{aOSCus[oBrowseOs:nAt,01],aOSCus[oBrowseOs:nAt,02],aOSCus[oBrowseOs:nAt,03],aOSCus[oBrowseOs:nAt,04],;
		aOSCus[oBrowseOs:nAt,05],aOSCus[oBrowseOs:nAt,06],aOSCus[oBrowseOs:nAt,07]}}
		Activate MsDialog oDlgBrw
	Else
		MsgStop(STR0044)//"O periodo selecionado nใo possui nenhuma O.S."
	Endif

Return