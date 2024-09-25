#INCLUDE "MNTC085.ch"
#include "Protheus.ch"
#include "MsGraphi.ch"

#DEFINE _nVERSAO 2 //Versao do fonte

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMNTC085   บAutor  ณRoger Rodrigues     บ Data ณ  23/07/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConsulta responsแvel pela gera็ใo da curva da banheira      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTA080                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTC085(cCodBem)
Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)
Local aOldNgBtn := If(Type("aNgButton") <> "U",ACLONE(aNgButton),{})
Local oDlg, nOS := 0
Local oFont1 := TFont():New("Arial",,-12,,.T.)
Local oFont2 := TFont():New("Arial",,-20,,.T.)

//Variaveis de Largura/Altura da Janela
Local aSize   := MsAdvSize(.F.)
Private nLargura  := aSize[5]
Private nAltura   := aSize[6]
Private nPosIni   := aSize[7]

Private cVisualiza := STR0001 //"Reparo"
Private cDataIni := CTOD("  /  /  ")
Private cDataFim := CTOD("  /  /  ")
Private aOs := {}

If cCodBem == Nil
	MsgStop(STR0002) //"Favor escolher um bem."
	Return
Endif
Private cBem := cCodBem

aNgButton	:= {}

dbSelectArea("ST9")
dbSetOrder(1)
dbSeek(xFilial("ST9")+cCodBem)
cDataIni := ST9->T9_DTCOMPR
If Empty(ST9->T9_DTBAIXA)
	cDataFim := dDataBase
Else
	cDataFim := ST9->T9_DTBAIXA
Endif

Define MsDialog oDlg From nPosIni,0 To nAltura,nLargura Pixel Title STR0003 Color CLR_BLACK,CLR_WHITE //"Curva da Banheira"
	oDlg:lEscClose := .F.
	oDlg:lMaximized := .t.

	@ 05,005 Say OemToansi(STR0004) of oDlg Pixel Font oFont1 //"Bem:"
	@ 05,022 Say AllTrim(cCodBem)+" - "+AllTrim(ST9->T9_NOME)	of oDlg Pixel Font oFont1
	@ 20,005 say OemtoAnsi(STR0005) of oDLG Pixel Font oFont1 //"Visualizar por:"

	@ 18,048 COMBOBOX cVisualiza ITEMS {STR0001,STR0006} SIZE 40,08 OF oDLG PIXEL; //"Reparo"###"Custo"
				ON CHANGE Processa({ |lEnd| CARREGRAF(cCodBem,cVisualiza,cDataIni,cDataFim) },STR0007) //"Aguarde Gerando Grแfico"

	@ 040, 000 MsGraphic oGrafico Size nLargura/2,(nAltura/2)- 58 - nPosIni/2 Of oDlg Pixel
	oGrafico:bLDblClick := {|| MNT85OSC()}
	@ (nAltura/2)-14 - nPosIni/2,nLargura/2-205 Button STR0008 Size 40,14 Of oDlg Pixel Action MNT85OSC(aOS) //"Visualizar OS's"
	@ (nAltura/2)-14 - nPosIni/2,nLargura/2-155 Button STR0009 Size 40,14 Of oDlg Pixel Action IMP085() //"Imprimir"
	@ (nAltura/2)-14 - nPosIni/2,nLargura/2-105 Button STR0010 Size 40,14 Of oDlg Pixel Action GrafSavBmp(oGrafico) //"Salvar"
	@ (nAltura/2)-14 - nPosIni/2,nLargura/2-55  Button STR0011 Size 40,14 Of oDlg Pixel Action oDlg:End() //"Sair"

	Processa({ |lEnd| CARREGRAF(cCodBem,cVisualiza,cDataIni,cDataFim) },STR0012, STR0013) //"Aguarde"###"Gerando Grแfico"

Activate MsDialog oDlg Centered

NGRETURNPRM(aNGBEGINPRM)
aNgButton := ACLONE(aOldNgBtn)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCARREGRAF บAutor  ณRoger Rodrigues     บ Data ณ  23/07/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca as Ordens de Servi็o Corretiva e de Reforma no perํodoบฑฑ
ฑฑบ          ณe monta o Grแfico                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC085                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} CARREGRAF
Busca as Ordens de Servi็o Corretiva e de Reforma no perํodo e monta o Grแfico

@author  Roger Rodrigues
@since   23/07/09
@version P11/P12
@param   cCodBem   , Caracter, C๓digo do bem
@param   cVisualiza, Caracter, Legenda a ser apresentada 'Reparo'/'Custo'
@param   ccDtIni   , Caracter, Data incial
@param   cDtFim    , Caracter, Data final
/*/
//-------------------------------------------------------------------
Function CARREGRAF(cCodBem,cVisualiza,cDtIni,cDtFim)

	Local i := 1
	Local nMeses := 0
	aOS := {}
	aMeses := RETMESES(cDtIni,cDtFim)
	oGrafico:DelSerie(1)
	oGrafico:l3D := .F.
	oGrafico:SetMargins( 0, 5, 0, 5 )
	oGrafico:SetTitle(AllTrim(cCodBEm)+" - "+Alltrim(ST9->T9_NOME),,CLR_RED,A_CENTER, GRP_TITLE)
	oGrafico:SetTitle("",cVisualiza,CLR_GREEN, A_LEFTJUST, GRP_TITLE  )
	oGrafico:SetTitle(STR0014,"", CLR_GREEN, A_CENTER, GRP_FOOT  ) //"Perํodo"
	nSerie := oGrafico:CreateSerie(1,cVisualiza)

	If nSerie != GRP_CREATE_ERR
		MsgRun( STR0015, STR0012 ,{ || CARREREG(cCodBem,cDtIni,cDtFim) }) //"Processando Informa็๕es"###"Aguarde"
		If Len(aOS) > 0
			//Ordena por Data
			aSort(aOS,,,{|x,y| x[2] < y[2]})
			//Adiciona os pontos ao grแfico
			ProcRegua(Len(aOS))
			For i:=1 to Len(aOS)
				IncProc()
				If Month(aOS[i][2]) == 1
					cMes := STR0016 //"JAN/"
				ElseIf Month(aOS[i][2]) == 2
					cMes := STR0017 //"FEV/"
				ElseIf Month(aOS[i][2]) == 3
					cMes := STR0018 //"MAR/"
				ElseIf Month(aOS[i][2]) == 4
					cMes := STR0020 //"ABR/"
				ElseIf Month(aOS[i][2]) == 5
					cMes := STR0019 //"MAI/"
				ElseIf Month(aOS[i][2]) == 6
					cMes := STR0021 //"JUN/"
				ElseIf Month(aOS[i][2]) == 7
					cMes := STR0022 //"JUL/"
				ElseIf Month(aOS[i][2]) == 8
					cMes := STR0023 //"AGO/"
				ElseIf Month(aOS[i][2]) == 9
					cMes := STR0024 //"SET/"
				ElseIf Month(aOS[i][2]) == 10
					cMes := STR0025 //"OUT/"
				ElseIf Month(aOS[i][2]) == 11
					cMes := STR0026 //"NOV/"
				Else
					cMes := STR0027 //"DEZ/"
				Endif
				cAno := SUBSTR(ALLTRIM(STR(Year(aOs[i][2]))),3)
				If (nPos := aScan(aMeses, {|x| x[1] == cMes+cAno })) > 0
					If cVisualiza == STR0006 //"Custo"
						aMeses[nPos][2] += aOS[i][1]
					Else
						aMeses[nPos][2] ++
					Endif
				Endif
			Next i

			nMaior := 0
			nMeses := Len(aMeses)
			For i := 1 To nMeses
				If aMeses[i][2] > nMaior
					nMaior := aMeses[i][2]
				Endif
				oGrafico:Add(1,aMeses[i][2],aMeses[i][1],CLR_RED)
			Next i

			// Caso possua s๓ um registro no nMeses, ้ adicionado o valor
			// novamente para o grแfico ser apresentado corretamente
			If nMeses == 1
				oGrafico:Add( 1, aMeses[1][2], aMeses[1][1], CLR_RED )
			EndIf
			oGrafico:SetRangeY( 0, nMaior + 1 )
			oGrafico:l3D := .T.
			oGrafico:l3D := .F.
			oGrafico:Refresh()
		Else
			ApMsgAlert(STR0028) //"O Bem nใo possui Ordens de Servi็o Corretivas e de Reforma no perํodo desejado."
		Endif

	Else
		ApMsgAlert(STR0029) //"Nใo foi possํvel gerar a consulta."
	Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRETMESES  บAutor  ณRoger Rodrigues     บ Data ณ  23/07/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna array com os meses do perํodo desejado              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CARREGRAF                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function RETMESES(dDtIni,dDtFim)
Local aArray := {}, cMes := "", cAno := ""

While ((dDtIni <= dDtFim) .OR. (Month(dDtIni) == Month(dDtFim) .AND. YEAR(dDtIni) == YEAR(dDtFim)))
	If Month(dDtIni) == 1
		cMes := STR0016 //"JAN/"
	ElseIf Month(dDtIni) == 2
		cMes := STR0017 //"FEV/"
	ElseIf Month(dDtIni) == 3
		cMes := STR0018 //"MAR/"
	ElseIf Month(dDtIni) == 4
		cMes := STR0020 //"ABR/"
	ElseIf Month(dDtIni) == 5
		cMes := STR0019 //"MAI/"
	ElseIf Month(dDtIni) == 6
		cMes := STR0021 //"JUN/"
	ElseIf Month(dDtIni) == 7
		cMes := STR0022 //"JUL/"
	ElseIf Month(dDtIni) == 8
		cMes := STR0023 //"AGO/"
	ElseIf Month(dDtIni) == 9
		cMes := STR0024 //"SET/"
	ElseIf Month(dDtIni) == 10
		cMes := STR0025 //"OUT/"
	ElseIf Month(dDtIni) == 11
		cMes := STR0026 //"NOV/"
	Else
		cMes := STR0027 //"DEZ/"
	Endif
	cAno := SUBSTR(ALLTRIM(STR(Year(dDtIni))),3)
	If aScan(aArray, {|x| x[1] == cMes+cAno }) == 0
		AADD(aArray, {cMes+cAno , 0 , CTOD("01/"+ALLTRIM(STRZERO(MONTH(dDtIni),2))+"/"+cAno)})
	Endif
	dDtIni := NGSomaMes(dDtIni,1)
End
aSort(aArray,,,{|x,y| x[3] < y[3] })
Return aArray

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCARREREG  บAutor  ณRoger Rodrigues     บ Data ณ  20/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega os registros de Ordem de servi็o corretivas do bem  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC085                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CARREREG(cCodBem,cDtIni,cDtFim)

// Sintaxe 'AS' necessแria para definir Alias de campo em POSTGRES
Local cSQL_AS := If( TCGetDB() == "POSTGRES","AS","" )

aOS := {}
//Carrega O.S. da STJ
cArqSTJ := GetNextAlias()
cQuery := "SELECT SUM(STL.TL_CUSTO) " + cSQL_AS + " CUSTO,MIN(STL.TL_DTINICI) " + cSQL_AS + " DTINI,STJ.TJ_ORDEM"
cQuery += " FROM "+RetSqlName("STL")+" STL,"+RetSqlName("STJ")+" STJ"
cQuery += " WHERE STL.D_E_L_E_T_ <> '*' AND STL.TL_PLANO = '000000' AND STL.TL_FILIAL = '"+xFilial("STL")+"'"
cQuery += " AND STL.TL_ORDEM = STJ.TJ_ORDEM AND STL.TL_SEQRELA <> '0'"
cQuery += " AND STL.TL_DTINICI >= '"+DTOS(cDtIni)+"' AND STL.TL_DTINICI <= '"+DTOS(cDtFim)+"'"
cQuery += " AND STJ.TJ_CODBEM = '"+cCodBem+"'"
cQuery += " AND STJ.D_E_L_E_T_ = '' AND STJ.TJ_PLANO = '000000'"
cQuery += " AND STJ.TJ_FILIAL = '"+xFilial("STJ")+"' AND STJ.TJ_SITUACA = 'L'"
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
cQuery := "SELECT SUM(STL.TL_CUSTO) " + cSQL_AS + " CUSTO,MIN(STL.TL_DTINICI) " + cSQL_AS + " DTINI,STJ.TJ_ORDEM"
cQuery += " FROM "+RetSqlName("STL")+" STL,"+RetSqlName("STJ")+" STJ,"+RetSqlName("STZ")+" STZ"
cQuery += " WHERE STL.D_E_L_E_T_ <> '*' AND STL.TL_PLANO = '000000' AND STL.TL_FILIAL = '"+xFilial("STL")+"'"
cQuery += " AND STL.TL_ORDEM = STJ.TJ_ORDEM AND STL.TL_SEQRELA <> '0'"
cQuery += " AND STL.TL_DTINICI >= STZ.TZ_DATAMOV AND STL.TL_DTINICI <= STZ.TZ_DATASAI"
cQuery += " AND (STZ.TZ_DATAMOV||STZ.TZ_HORAENT) >= ('"+DTOS(cDtIni)+"'||STL.TL_HOFIM)"
cQuery += " AND (STZ.TZ_DATASAI||STZ.TZ_HORASAI) <= ('"+DTOS(cDtFim)+"'||STL.TL_HOFIM)"
cQuery += " AND STZ.TZ_BEMPAI = '"+cCodBem+"'"
cQuery += " AND STJ.TJ_CODBEM = STZ.TZ_CODBEM  AND STJ.TJ_PLANO = '000000'"
cQuery += " AND STJ.D_E_L_E_T_ <> '*' AND STZ.D_E_L_E_T_ <> '*'"
cQuery += " AND STZ.TZ_FILIAL = '"+xFilial("STZ")+"' AND STJ.TJ_FILIAL = '"+xFilial("STJ")+"' AND STJ.TJ_SITUACA = 'L'"
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
cQuery := "SELECT (SELECT SUM(STT.TT_CUSTO) FROM "+RetSqlName("STT")+" STT"
cQuery += " WHERE STT.D_E_L_E_T_ <> '*' AND STT.TT_PLANO = '000000' AND STT.TT_FILIAL = '"+xFilial("STT")+"'"
cQuery += " AND STT.TT_ORDEM = STS.TS_ORDEM AND STT.TT_SEQRELA <> '0') " + cSQL_AS + " CUSTO, STS.TS_DTMRINI, STS.TS_ORDEM "
cQuery += " FROM "+RetSqlName("STS")+" STS WHERE STS.TS_CODBEM = '"+cCodBem+"'"
cQuery += " AND STS.D_E_L_E_T_ = '' AND STS.TS_DTMRINI >= '"+DTOS(cDtIni)+"' AND STS.TS_DTMRINI <= '"+DTOS(cDtFim)+"' AND STS.	TS_PLANO = '000000'"
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
cQuery := "SELECT (SELECT SUM(STT.TT_CUSTO) FROM "+RetSqlName("STT")+" STT"
cQuery += " WHERE STT.D_E_L_E_T_ <> '*' AND STT.TT_PLANO = '000000' AND STT.TT_FILIAL = '"+xFilial("STT")+"'"
cQuery += " AND STT.TT_ORDEM = STS.TS_ORDEM AND STT.TT_SEQRELA <> '0') " + cSQL_AS + " CUSTO, STS.TS_DTMRINI, STS.TS_ORDEM"
cQuery += " FROM "+RetSqlName("STS")+" STS"
cQuery += " JOIN "+RetSqlName("STZ")+" STZ ON STZ.TZ_BEMPAI = '"+cCodBem+"'"
cQuery += " WHERE STS.TS_CODBEM = STZ.TZ_CODBEM  AND STS.TS_PLANO = '000000'"
cQuery += " AND STS.D_E_L_E_T_ <> '*' AND STZ.D_E_L_E_T_ <> '*'"
cQuery += " AND STS.TS_DTMRINI >= STZ.TZ_DATAMOV AND STS.TS_DTMRINI <= STZ.TZ_DATASAI"
cQuery += " AND (STZ.TZ_DATAMOV||STZ.TZ_HORAENT) >= ('"+DTOS(cDtIni)+"'||STS.TS_HOMRFIM) "
cQuery += " AND (STZ.TZ_DATASAI||STZ.TZ_HORASAI) <= ('"+DTOS(cDtFim)+"'||STS.TS_HOMRFIM) "
cQuery += " AND STZ.TZ_FILIAL = '"+xFilial("STZ")+"' AND STS.TS_FILIAL = '"+xFilial("STS")+"' AND STS.TS_SITUACA = 'L'"
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
ฑฑบPrograma  ณIMP085    บAutor  ณRoger Rodrigues     บ Data ณ  20/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime o grafico                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC085                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function IMP085()
Local oDlg1
Local nModoImp := 1
Local lRet := .F.
Private cImgPath := ""
Private cPathBmp := Alltrim(GetMv("MV_DIRACA"))// Path do arquivo logo .bmp do cliente
cFileLogo := NGLOCLOGO()

DEFINE MSDIALOG oDlg1 FROM  0,0 TO 150,320 TITLE STR0030 PIXEL //"Modo de Impressao"

@ 20,14 RADIO oRadOp VAR nModoImp ITEMS STR0031,STR0032 SIZE 70,15 PIXEL OF oDlg1 //"Tela"###"Impressora"

DEFINE SBUTTON FROM 59,90  TYPE 1 ENABLE OF oDlg1 ACTION EVAL({|| lRET := .T.,oDlg1:END()})
DEFINE SBUTTON FROM 59,120 TYPE 2 ENABLE OF oDlg1 ACTION oDlg1:END()

ACTIVATE MSDIALOG oDlg1 CENTERED

If lRet
	oPrintCurva	:= TMSPrinter():New(OemToAnsi(STR0003)) //"Curva da Banheira"
	oPrintCurva:SetLandScape()
	//Cria Imagem para impressao
	oGrafico:SaveToImage("Curva.BMP", cPathBmp, "BMP" )
	cImgPath := cPathBmp+"Curva.BMP"
	Lin := 75
	oPrintCurva:Line(lin,25,lin,3125)
	Lin := 150
	oPrintCurva:StartPage()

	If File(cFileLogo)
		oPrintCurva:SayBitMap(110,40,cFileLogo,250,150)
	EndIf

	oPrintCurva:Say(lin+20,1400,STR0033+Upper(cVisualiza)) //"CURVA DA BANHEIRA - "
	oPrintCurva:Say(lin+45,2900,STR0034 + cValToChar(Date())) //"Data : "
 	oPrintCurva:Say(lin+80,2900,STR0035 + Time(),) //"Hora : "
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
ฑฑบPrograma  ณMNT85OSC  บAutor  ณRoger Rodrigues     บ Data ณ  21/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMostra as O.S. corretivas do bem e filhos                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTC085                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNT85OSC()
Local oDlgOpc
Local lRet := .F.
Local cMes := Space(2), cAno := Space(4)

DEFINE MSDIALOG oDlgOpc FROM 0,0 TO 130,280 TITLE STR0008 PIXEL //"Visualizar OS's"

@ 10,14  Say STR0036 Of oDlgOpc Pixel //"Informe um m๊s e ano para visualiza็ใo das OS's"

@ 25,14  SAY STR0037 OF oDlgOpc Pixel //"M๊s:"
@ 23,30  MSGET cMes PICTURE "99" WHEN .T. SIZE 15,07 OF oDlgOpc Pixel Valid MNT085VAL(1,cMes)

@ 25,55  SAY STR0038 OF oDlgOpc Pixel //"Ano:"
@ 23,69  MSGET cAno PICTURE "9999" WHEN .T. SIZE 30,07 OF oDlgOpc Pixel Valid MNT085VAL(2,cAno)

DEFINE SBUTTON FROM 45,14 TYPE 1 ENABLE OF oDlgOpc ACTION EVAL({|| lRET := .T.,oDlgOpc:END()})
DEFINE SBUTTON FROM 45,44 TYPE 2 ENABLE OF oDlgOpc ACTION oDlgOpc:END()

ACTIVATE MSDIALOG oDlgOpc CENTERED

If lRet
	MsgRun( STR0015, STR0012 ,{ || CARREBRW(cMes,cAno) }) //"Processando Informa็๕es"###"Aguarde"
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCARREBRW  บAutor  ณRoger Rodrigues     บ Data ณ  21/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera Browse com O.S's                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNT85OSC                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CARREBRW(cMes,cAno)
Local oDlgBrw, oPanel
Local i := 1
Local aOSCor := {}
Local oBrowseOs
Local aHeadOsCor := {STR0041, STR0042, STR0043, STR0044, STR0045, STR0046, STR0047} //"Ordem"###"Tipo"###"Bem"###"Descricao"###"Servico"###"Custo Total"###"Dt. Ini. Man. Real"

//Ordena por numero de Ordem da O.S.
If Len(aOs) > 0
	aSort(aOS,,,{|x,y| x[3] < y[3]})
Endif

For i:=1 to Len(aOs)
	If Month(aOs[i][2]) == Val(cMes) .AND. YEAR(aOs[i][2]) == Val(cAno)
		dbSelectArea("STJ")
		dbSetOrder(1)
		If dbSeek(xFilial("STJ")+aOs[i][3]+"000000")
			If aScan(aOsCor, { |x| Trim(Upper(x[1])) == aOs[i][3] }) == 0
				aADD( aOsCor, { aOs[i][3], STJ->TJ_TIPOOS, STJ->TJ_CODBEM, NGSEEK("ST9",STJ->TJ_CODBEM,1,"T9_NOME"), STJ->TJ_SERVICO, AllTRIm(STR(aOs[i][1])), DTOC(aOs[i][2]) })
			Endif
		Else
			dbSelectArea("STS")
			dbSetOrder(1)
			If dbSeek(xFilial("STS")+aOs[i][3]+"000000")
				If aScan(aOsCor, { |x| Trim(Upper(x[1])) == aOs[i][3] }) == 0
					aADD( aOsCor, { aOs[i][3], STS->TS_TIPOOS, STS->TS_CODBEM, NGSEEK("ST9",STS->TS_CODBEM,1,"T9_NOME"), STS->TS_SERVICO, AllTRIm(STR(aOs[i][1])), DTOC(aOs[i][2]) })
				Endif
			Endif
		Endif
	Endif
Next i

If Len(aOSCor) > 0
	Define MsDialog oDlgBrw From nPosIni,0 To nAltura,nLargura Pixel Title STR0039 Color CLR_BLACK,CLR_WHITE //"OS's Corretivas do Bem e seus bens filhos"
		oDlgBrw:lEscClose := .F.
		oDlgBrw:lMaximized := .T.

		oPanel := TPanel():New(0, 0, Nil, oDlgBrw, Nil, .T., .F., Nil, Nil, 0, 25, .T., .F. )
			oPanel:Align := CONTROL_ALIGN_TOP

			dbSelectArea("ST9")
			dbSetOrder(1)
			dbSeek(xFilial("ST9")+cBem)
			@ 05,005 Say OemToansi(STR0004) of oPanel Pixel //"Bem:"
			@ 05,022 Say AllTrim(cBem)+" - "+AllTrim(ST9->T9_NOME)	of oPanel Pixel
			@ 05,nLargura/2-100 Button STR0040 Size 40,14 Of oPanel Pixel Action MNT85VIS(aOSCor[oBrowseOs:nAt,01]) //"Visualizar"
			@ 05,nLargura/2-50  Button STR0011 Size 40,14 Of oPanel Pixel Action oDlgBrw:End()	 //"Sair"

		oBrowseOs := TWBrowse():New( 25 , 01, nLargura-40, nAltura-40,,aHeadOsCor,{20,20,40,40,30,30,20}, oDlgBrw, ,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
			oBrowseOs:Align := CONTROL_ALIGN_ALLCLIENT
			oBrowseOs:SetArray(aOSCor)
			oBrowseOs:bLDblClick := {|| MNT85VIS(aOSCor[oBrowseOs:nAt,01])}
			oBrowseOs:bLine := {||{aOSCor[oBrowseOs:nAt,01],aOSCor[oBrowseOs:nAt,02],aOSCor[oBrowseOs:nAt,03],aOSCor[oBrowseOs:nAt,04],;
									aOSCor[oBrowseOs:nAt,05],aOSCor[oBrowseOs:nAt,06],aOSCor[oBrowseOs:nAt,07]}}

	Activate MsDialog oDlgBrw Centered
Else
	MsgStop(STR0048) //"O periodo selecionado nใo possui nenhuma O.S. Corretiva."
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMNT85VIS  บAutor  ณRoger Rodrigues     บ Data ณ  21/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVisualiza a Os Selecionada no Browse                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CARREBRW                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNT85VIS(cOrdem)
Local aArea := GetArea()
cCadastro := STR0049 //"Ordem de Servi็o"
dbSelectArea("STJ")
dbSetOrder(1)
If dbSeek(xFilial("STJ")+cOrdem) //+"000000")
	NGCAD01("STJ",Recno(),2)
Else
	dbSelectArea("STS")
	dbSetOrder(1)
	If dbSeek(xFilial("STS")+cOrdem) //+"000000")
		NGCAD01("STS",Recno(),2)
	Endif
Endif
RestArea(aArea)
cCadastro := STR0050 //"Bens"

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMNT085VAL บAutor  ณRoger Rodrigues     บ Data ณ  25/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida mes e ano preenchidos                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNT85OSC                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNT085VAL(nOpc, cValor)
Local lRet := .T.

If nOpc == 1
	If Val(AllTrim(cValor)) < 1 .Or. Val(AllTrim(cValor)) > 12
		MsgStop(STR0051,STR0054)
		lRet := .F.
	Endif
ElseIf nOpc == 2
	If Val(AllTrim(cValor)) > Year(cDataFim) .Or. Val(AllTrim(cValor)) < Year(cDataIni)
		MsgStop(STR0052+CHR(13)	+STR0053,STR0054)
		lRet := .F.
	Endif
Endif

Return lRet