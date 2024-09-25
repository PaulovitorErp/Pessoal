#INCLUDE "Protheus.ch"
#INCLUDE "MNTA494.ch"
#INCLUDE "FWADAPTEREAI.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA494
Monta tela (dialog) para selecionar parametros para exportacao de custos

@param cFil - Filial a ser processada
@param cEmp - Empresa a ser processada
@param cMes - Mes para processamento
@param cAno - Ano para processamento
@param aEquips - Equipamentos

@author Vitor Emanuel Batista
@since 11/07/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Function MNTA494(aArgs)

	//---------------------------------------------
	// Guarda conteúdo e declara variáveis padrões
	//---------------------------------------------
	Local aNGBEGINPRM := {}

	Local oDlg, oCombo, oAno, oEqp, oTra
	Local aCombo := {}
	Local oFont10B := TFont():New("Arial",,-10,,.T.,,,,.T.,.F.)
	Local cOldEmp := ""
	Local cOldFil := ""
	Local nX, cY
	Local oMark := nil
	Local aDBF
	Local aINDTRB
	Local cAliasTRB1 := GetNextAlias()
	Local nOpcao
	Local lAbriu
	Local oFont
	Local aEquips := {}
	Local lInverte
	Local cMarca
	Local cEmp		:= ""
	Local cFil		:= ""
	Local cMes		:= ""
	Local cAno		:= ""
	Local cPesq     := Space(40)
	Local cFiltro	:= ""
	Local oTempTMP  := Nil

	Private aTables := { "STJ","STL","SB1","ST9","TRH","TRT","STS","STT","TRK","TRO","TRL","TRV","TRM","TQN","TQI","TRX","SBM" }
	Private lSched  := !(Type("oMainWnd") == "O")

	If !lSched

		Private cMarca := GetMark()

		//Verifica o compartilhamento das tabelas
		Private lModCompE := FWModeAccess("ST9",1) == "C"
		Private lModCompU := FWModeAccess("ST9",2) == "C"
		Private lModCompF := FWModeAccess("ST9",3) == "C"

		//Verifica o tamanho do Layout do Sigamat
		Private cLayoutE := FWSM0Layout(cEmpant,1)
		Private cLayoutU := FWSM0Layout(cEmpant,2)
		Private cLayoutF := FWSM0Layout(cEmpant,3)

	EndIf

	Default aArgs := {}

	If lSched
		cCodEmp := aArgs[1]
		cCodFil := aArgs[2]
		cMes    := aArgs[3]
		cAno    := aArgs[4]
		aEquips := aArgs[5]
		cEmpAnt := aArgs[1]
      	cFilAnt := aArgs[2]
	Else
		cFil := cFilAnt
		cEmp := cEmpAnt
		cMes := StrZero( Month( Date() ),2 )
		cAno := cValToChar( Year( Date() ) )
	EndIf

	// Abre ambiente
	If lSched
		RPCSetType(3) // Não consome licença de uso
		RpcSetEnv(cCodEmp,cCodFil,,,"MNT",,aTables)
	EndIf

    cOldEmp := cEmpAnt
	cOldFil := cFilAnt

	aNGBEGINPRM := NGBEGINPRM()

	If !FindFunction( "NGINTMOB" ) .Or. !NGINTMOB( "MNTI494A" ) .Or. !NGINTMOB( "MNTI494B" )

		If !lSched
			ShowHelpDlg(STR0001,; //"Atenção"
						{STR0002},1,; //"Esta rotina será habilita somente quando houver integração no processo Mobilidade"
						{STR0003},1) //"Verique o parâmetro MV_NGINTMB e a compilação das funções MNTI494A e MNTI494B."
		EndIf

		Return Nil
	EndIf

	For nX := 1 To 12
		cY := StrZero(nX,2)
		aAdd(aCombo,cY+"="+cMonth(STOD(cValToChar(Year(dDataBase))+cY+cY)))
	Next nX

	If !lSched

		//Campos para o arquivo temporário
		aDBF := {{"OK"    , "C", 02, 0},;
				 {"CODBEM", "C", 16, 0},;
				 {"TIPO"  , "C", 40, 0},;
				 {"NOME"  , "C", 40, 0}}

		// Campos para o MarkBrowse.
		aCampos := {{"OK"    , Nil, " "},;
					{"CODBEM", Nil, "Bem"},;
					{"TIPO"  , Nil, "Tipo Modelo"},;
					{"NOME"  , Nil, "Nome do Bem"}}

		aINDTRB  := {{"CODBEM"},{"TIPO"}, {"NOME"}}
		oTempTMP  := NGFwTmpTbl(cAliasTRB1,aDBF,aINDTRB)

		Define FONT oFont NAME "Arial" Size 07,17

		Define MsDialog oDlg From 0,0 to 500,800 Title STR0004 Pixel //"Exportação de Custos"

			oDlg:lEscClose := .F. //Determina que janela não fechará ao pressionar ESC.

			oGRHNPNL := TPanel():New(0,0,,oDlg,,.T.,,,,0,0,.T.,.F.)
			oGRHNPNL:Align := CONTROL_ALIGN_ALLCLIENT

			oMark := MsSelect():New( cAliasTRB1, "OK",, aCampos, @lInverte, @cMarca, {040,000,220,402},,, oGRHNPNL )

			@ 05,10 SAY STR0005 Pixel Of oGRHNPNL FONT oFont10B Color CLR_BLUE //"Empresa"
			@ 05,35 MsGet oEmp Var cEmp Picture "@!" Size 20,08 Pixel Of oGRHNPNL F3 "YM0" Valid;
			        (cEmpAnt := cEmp, ExistCpo("SM0",cEmp)) HASBUTTON
			@ 05,70 SAY STR0006 Pixel Of oGRHNPNL FONT oFont10B Color CLR_BLUE //"Filial"
			@ 05,85 MsGet oFil Var cFil Picture "@!" Size 20,08 Pixel Of oGRHNPNL F3 "XM0" Valid;
			        (ExistCpo("SM0",cEmp+cFil) .AND. MNTA494X(cFil, oMark, cAliasTRB1)) HASBUTTON

			MNTA494X(cFil, oMark, cAliasTRB1)

			@ 05,140 SAY STR0007 Pixel Of oGRHNPNL FONT oFont10B Color CLR_BLUE //"Mês"
			oCombo := tComboBox():New(05,155,{|u|if(PCount()>0,cMes:=u,cMes)},aCombo,55,20,oGRHNPNL,,{||.T.},,,,.T.,,,,{||.T.},,,,,'cMes')

			@ 05,225 SAY STR0008 Pixel Of oGRHNPNL FONT oFont10B Color CLR_BLUE //"Ano"
			@ 05,240 MsGet oAno Var cAno Picture "9999" Size 20,08 Pixel Of oGRHNPNL Valid !Empty(cAno)

			@ 25,100 SAY STR0009 Pixel Of oGRHNPNL FONT oFont10B Color CLR_BLUE //"Pesquisa"
			@ 25,130 MsGet oPesq Var cPesq Picture "@!" Size 90,08 Pixel Of oGRHNPNL

			@ 25,10 SAY STR0010 Pixel Of oGRHNPNL FONT oFont10B Color CLR_BLUE //"Filtro"

			aItems  := {STR0011,STR0012,STR0013} //'Codigo' ## 'Tipo' ## 'Nome'
			cCombo  := aItems[1]
			oFiltro := TComboBox():New(25,30,{|u|if(PCount()>0,cCombo:=u,cCombo)},aItems,55,20,oGRHNPNL,,{||MNTA494C(cCombo, oMark,;
			                           cAliasTRB1)},,,,.T.,,,,,,,,,'cFiltro')

			@ 230,002 Say STR0014 Of oGRHNPNL Pixel // "Clique duas vezes sobre um bem para marcar/desmarcar o mesmo."

			oMark:oBrowse:lHasMark    := .T.
			oMark:oBrowse:lCanAllMark := .T.

			dbSelectArea( cAliasTRB1 )
			dbGoTop()

			oButtonF3 := tButton():New(25,230,STR0015,oGRHNPNL,{||MNTA494L(cPesq, cAliasTRB1, cCombo)},40,11,,,,.T.) //"Localizar"
			oButtonF1 := tButton():New(230,300,STR0016,oGRHNPNL,{|| ( nOpcao := 1, lAbriu := .T. ),oDlg:End() },40,11,,,,.T.) //"Confirmar"
			oButtonF2 := tButton():New(230,345,STR0017,oGRHNPNL,{||cEmpAnt := cOldEmp, oDlg:End()},40,11,,,,.T.) //"Cancelar"

		Activate Dialog oDlg Centered

		If(nOpcao == 1)

			dbSelectArea( cAliasTRB1 )
			dbGoTop()
			While !EoF()
				// Se o bem não estiver marcado passa para o próximo registro.
				If !IsMark("OK")
			   		dbSelectArea( cAliasTRB1 )
					dbSkip()
					Loop
				EndIf
				// Adiciona o bem a lista de bens
				AADD(aEquips,(cAliasTRB1)->CODBEM)
				dbSelectArea( cAliasTRB1 )
				dbSkip()

			End While
			// Executa a função com os bens marcados.
			FilterCost( cEmp,cFil,cMes,cAno, aEquips)

		EndIf

	Else
		FilterCost( cCodEmp,cCodFil,cMes,cAno,aEquips )
	EndIf

	oTempTMP:Delete()

	cEmpAnt := cOldEmp
	cFilAnt := cOldFil

	// Retorna conteúdo de variáveis padrões
	NGRETURNPRM(aNGBEGINPRM)

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA494X(cFil, oMark, cAliasTRB1)
Atualiza TRB com os dados da nova filial.

@param cFil - Filial utilizada.
@param oMark - Objeto que guarda o browser.
@param cAliasTRB1 - Tabela temporaria.

@author Vinicius Schadeck
@since 28/08/14
@version P11
@return
/*/
//---------------------------------------------------------------------
Static Function MNTA494X(cFil, oMark, cAliasTRB1)

	Local cFilBem := ""

	cFilBem := SubStr(cFil,1,NGLEASTLAY("ST9"))

	dbSelectArea(cAliasTRB1)
	ZAP
	dbSelectArea("ST9")
	dbSetOrder(1)
	dbSeek( cFilBem )

	While(!EoF() .And. cFilBem == ST9->T9_FILIAL)

		recLock(cAliasTRB1, .T.)
		(cAliasTRB1)->OK := space(2)
		(cAliasTRB1)->CODBEM := ST9->T9_CODBEM
		(cAliasTRB1)->TIPO := ST9->T9_TIPMOD
		(cAliasTRB1)->NOME := ST9->T9_NOME
		msUnlock(cAliasTRB1)
		dbSelectArea("ST9")
		dbSkip()

	EndDo

	dbSelectArea(cAliasTRB1)
	dbGoTop()
	oMark:oBrowse:refresh()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA494L(cPesq, cAliasTRB1, cCombo)
Localiza item apartir do indice selecionado.

@param cPesq - Indica valor a ser pesquisado.
@param cAliasTRB1 - Tabela temporaria.
@param cCombo - Indica o indice selecionado.

@author Vinicius Schadeck
@since 28/08/14
@version P11
@return
/*/
//---------------------------------------------------------------------
Static Function MNTA494L(cPesq, cAliasTRB1, cCombo)

	dbSelectArea(cAliasTRB1)

	If(cCombo == STR0011) //"Codigo"
		dbSetOrder(1)
	ElseIf(cCombo == STR0012) //"Tipo"
		dbSetOrder(2)
	ElseIf(cCombo == STR0013) //"Nome"
		dbSetOrder(3)
	EndIf

	dbSeek(cPesq, .T.)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA494C(cCombo, oMark, cAliasTRB1)
Altera o indece da cAliasTRB1.

@param cCombo - Indica o indice selecionado.
@param oMark - Objeto que guarda o browser.
@param cAliasTRB1 - Tabela temporaria.

@author Vinicius Schadeck
@since 28/08/14
@version P11
@return
/*/
//---------------------------------------------------------------------
Static Function MNTA494C(cCombo, oMark, cAliasTRB1)

	dbSelectArea(cAliasTRB1)
	If(cCombo == STR0011) //"Codigo"
		dbSetOrder(1)
	EndIf
	If(cCombo == STR0012) //"Tipo"
		dbSetOrder(2)
	EndIf
	If(cCombo == STR0013) //"Nome"
		dbSetOrder(3)
	EndIf
	oMark:oBrowse:refresh()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} FilterCost
Gera arquivo de exportacao de custos

Custos Indiretos:
LaborCost        - Custo de mão de obra aplicado nas OS
InputCost        - Custo de peças, produtos, lubrificantes, aplicados na OS
ThirdPartCost    - Custo com serviços de terceiros que trabalharam na OS
ToolCost         - Custo com ferramentas aplicadas na OS
FuelCost         - Custo com os abastecimentos realizados no Mês
PenaltyCost      - Custo com multas pagas no mês, podemos considerar somente multas por culpa da empresa
IncidentCost     - Custo com acidentes ocorridos no mês
PaperCost        - Custo com documentos realizados no mês
RentCost         - Custo de Locação do Equipamento (Fixo), calculado pelo sistema de manutenção de ativos
TotalRentCost    - Custo total de locação do Equipamento, calculado pelo sistema de manutenção de ativos mensalmente
HourRentCost     - Custo Hora de Locação do Equipamento, calculado pelo sistema de manutenção de ativos
RealHourRentCost - Custo Hora Real de locação do Equipamento, calculado pelo sistema de manutenção de ativos mensalmente
BilledRentCost   - Valor Faturado pela locação do Equipamento

Custos Diretos:
UnproductiveHoursAmount          - Quantidade de horas improdutivas apontadas no mês na frente de trabalho
UnproductiveHoursCost            - Valor das horas improdutivas no mês. Calculado da seguinte forma. Valor Improdutivo = (custo hora da maquina parada * quantidade de horas paradas). O somatório das horas paradas será apurado com base nas horas lançadas nas atividades improdutivas
ProductiveHoursAmount            - Quantidade de horas produtivas apontadas no mês na frente de trabalho
ProductiveHoursCost              - Valor de horas produtivas
ApportionmentProductiveHoursCost - Valor das horas produtivas recalculada após rateio das horas improdutivas. Processo de rateio distribui as horas improdutivas com base na quantidade de horas produtivas por frente de trabalho. Então a quantidade de horas produtivas vai aumentar, e consequentemente o valor também vai aumentar, após o rateio. Este campo representa este novo valor.

@param cFil   - Filial a ser processada
@param cEmp   - Empresa a ser processada
@param cMes   - Mes para processamento
@param cAno   - Ano para processamento
@param cEquip - Equipamento

@author Vitor Emanuel Batista
@since 11/07/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function FilterCost(cEmp,cFil,cMes,cAno,aEquips)

	Local aArea := GetArea()
	Local bBlock, nSend, nEquips, nErros, nCertos, nMsg
	Local aErros := {}
	Local aCertos := {}
	Local aMsg := {}
	Local cMsg := ""

	// Local cCodEmp	:= GetJobProfString('cCodEmp','99')
	// Local cCodFil	:= GetJobProfString('cCodFil','01')
	// Local aTables	:= {"STJ","STL","SB1","ST9","TRH","TRT","STS","STT","TRK",;
							 // "TRO","TRL","TRV","TRM","TQN","TQI","TRX","SBM"}

	Private aSendIntDef := {}

	Private aCostsEquip := {}

	//---------------------------------------------------------

	Default cFil := If(lSched,cCodFil,cFilAnt)
	Default cEmp := If(lSched,cCodEmp,cEmpAnt)
	Default cMes := StrZero(Month(Date()),2)
	Default cAno := cValToChar(Year(Date()))

	//Valida parametros Empresa e Filial
	If (Empty(cEmp) .Or. Empty(cFil)) .And. !lModComp
		If !lSched
			MsgInfo(STR0018,STR0001) //"Parametros EMPRESA e FILIAL não foram definidos." ## "Atenção"
		EndIf
		RestArea(aArea)
		Return Nil
	EndIf

	If !lSched
		If lModCompE .Or. lModCompU .Or. lModCompF
			If !MsgYesNo(STR0019+STR0020 +; //"Os custos serão importado apenas da filial selecionada." ## "Deseja prosseguir com o processo de exportar custos?"
			STR0001) //"Atenção"
				RestArea(aArea)
				Return Nil
			EndIf
		Else
			If !MsgYesNo(STR0020,STR0001) //"Deseja prosseguir com o processo de exportar custos?" ## "Atenção"
				RestArea(aArea)
				Return Nil
			EndIf
		EndIf
	EndIf

	If(Len(aEquips) > 0)

		For nEquips := 1 To Len(aEquips)

			bBlock := &( "{ || aSendIntDef := MNT494GCST('" + cEmp + "', '" + cFil + "', '" + cMes + "', '" + cAno + "', '" + aEquips[nEquips] + "') }" )

			If !lSched //Type( "oMainWnd" ) == "O"
				MsgRun( STR0021,STR0022, bBlock ) //"Verificando Custos do Equipamento..." ## "Custo Mensal do Equipamento"
			Else
				Eval( bBlock )
			EndIf

			If Len(aSendIntDef) > 0
				For nSend := 1 To Len(aSendIntDef)

					aCostsEquip := aClone(aSendIntDef[nSend])

					If Len(aCostsEquip) >= 4 .And. Len(aCostsEquip[4]) > 0
						MNTI494A(aCostsEquip) // Envia mensagem de custos indiretos
					EndIf

					If Len(aCostsEquip) >= 5 .And. Len(aCostsEquip[5]) > 0
						MNTI494B(aCostsEquip) // Envia mensagem de custos diretos
					EndIf

					AADD(aCertos, aEquips[nEquips])

				Next nSend
			Else
				If lSched
					AADD(aErros, aEquips[nEquips])
				Else
					AADD(aErros, aEquips[nEquips])
				EndIf
			EndIf

		Next nEquips

		If Len(aCertos)>0

			cMessage := STR0023 //"Custos exportados corretamente. Para os bens:"
			For nCertos := 1 To Len(aCertos)

				cMessage += (chr(10)+AllTrim(aCertos[nCertos]))

			Next nCertos
			AADD(aMsg, cMessage)

		EndIf

		If Len(aErros)>0

			cMessage := STR0024 //"Nenhum custo foi gerado no período informado. Para os bens:"
			For nErros := 1 To Len(aErros)

				cMessage += (chr(10)+AllTrim(aErros[nErros]))

			Next nErros
			AADD(aMsg, cMessage)

		EndIf

		cMsg := ""

		For nMsg := 1 To Len(aMsg)

			cMsg += aMsg[nMsg]+chr(10)

		Next nMsg

		If !lSched
			NGMSGMEMO( "ATENCAO" , cMsg )
		EndIf

	EndIf

	RestArea(aArea)

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT494GCST

@author Felipe Nathan Welter
@since 09/07/13
@version P11
@return aArray sendo [1]-.T./.F. e [2]-cError
/*/
//---------------------------------------------------------------------
Function MNT494GCST(cEmp,cFil,cMes,cAno,cEquip)

	Local aCostsEquip := {}
	Local nApptsEquip, nSendAll, nApptsCC
	Local cIntIDApp
	Local cCustCpr 	:= ""
	Local cCpEquip  := ""
	Local nCostType
	Local lMNTA4941 := ExistBlock("MNTA4941")
	Local cQuery   	:= ""
	Local cQuery2  	:= ""
	Local aDBF     	:= {}
	Local aApptsDirectCost := {}
	Local aAppointments := {}
	Local nEquipCosts
	Local cIsNull := If(TcGetDb() = "ORACLE","NVL",If(TcGetDb() $ "DB2","COALESCE","ISNULL"))
	Local nHrCostEquip := 0
	Local nSend
	Local aIndirectCosts := {}
	Local nIndCostCC  := 0
	Local aDirectCosts := {}
	Local nDrtCostCC  := 0
	Local nCostEquip
	Local cARQ1, cInd1
	Local nLimitCosts := 30
	Local cAliasQry   := GetNextAlias()
	Local lPE4941     := .F.
	Local oTempQRY

	aAdd( aDBF, { "CCUSTO", "C", TAMSX3("T9_CCUSTO")[1]	,0 } )
	aAdd( aDBF, { "CODBEM", "C", TAMSX3("T9_CODBEM")[1]	,0 } )
	aAdd( aDBF, { "QTD"   , "N", 03                     ,0 } )
	aAdd( aDBF, { "TIPO"  , "C", 40                    	,0 } )
	aAdd( aDBF, { "TOT"   , "N", 12                     ,2 } )

	oTempQRY := FWTemporaryTable():New( cAliasQry, aDBF )
	oTempQRY:AddIndex( "1", {"CODBEM","CCUSTO","TIPO"} )
	oTempQRY:Create()

	//---------------------------------------------------------
	//Tenta a criacao das tabelas a serem utilizadas
	aChkTbl := {"STJ","STL","SB1","ST9","TRH","TRK","TRO","TRL","TRV","TRM","TRT","STS","STT","TRX","TQN","TQI"}
	M985ChkTbl(aChkTbl,cEmp)
	//---------------------------------------------------------

	If NGCADICBASE("TJ_CCUSTO","A","STJ",.F.) .And. NGCADICBASE("TL_CUSTO","A","STL",.F.)

		//LaborCost - Custo de mão de obra aplicado nas OS
		cQuery += " SELECT STJ.TJ_CCUSTO CCUSTO, STJ.TJ_CODBEM CODBEM, COUNT(*) QTD, 'LaborCost' TIPO, SUM(STL.TL_CUSTO) TOT "
		cQuery += "   FROM " + RetSqlName("STL") + " STL "
		cQuery += "   JOIN " + RetSqlName("STJ") + " STJ "
		cQuery += "     ON STL.TL_ORDEM = STJ.TJ_ORDEM "
		cQuery += "    AND STL.TL_PLANO = STJ.TJ_PLANO "
		cQuery += "  WHERE SUBSTRING(STJ.TJ_DTMRFIM,5,2) = " + ValToSql(cMes)
		cQuery += "    AND SUBSTRING(STJ.TJ_DTMRFIM,1,4) = " + ValToSql(cAno)
		cQuery += "    AND STL.TL_FILIAL  = " + ValToSql(NGTROCAFILI("STL",cFil))
		cQuery += "    AND STJ.TJ_FILIAL  = " + ValToSql(NGTROCAFILI("STJ",cFil))
		cQuery += "    AND STL.TL_SEQRELA  > '0' "
		cQuery += "    AND STJ.TJ_SITUACA  = 'L' "
		cQuery += "    AND STJ.TJ_TERMINO  = 'S' "
		cQuery += "    AND STL.TL_TIPOREG  = 'M' "

		If !Empty( cEquip )
			cQuery += " AND STJ.TJ_CODBEM = " + ValToSql(cEquip)
		EndIf

		cQuery += "    AND STL.D_E_L_E_T_ <> '*' "
		cQuery += "    AND STJ.D_E_L_E_T_ <> '*' "
		cQuery += "  GROUP BY STJ.TJ_CODBEM, STJ.TJ_CCUSTO, STJ.TJ_CENTRAB "

		cQuery += " UNION"

		//InputCost - Custo de peças, produtos, lubrificantes, aplicados na OS
		cQuery += " SELECT STJ.TJ_CCUSTO CCUSTO, STJ.TJ_CODBEM CODBEM, COUNT(*) QTD, 'InputCost' TIPO, SUM(STL.TL_CUSTO) TOT "
		cQuery += "   FROM " + RetSqlName("STL") + " STL"
		cQuery += "   JOIN " + RetSqlName("STJ") + " STJ"
		cQuery += "     ON STL.TL_ORDEM = STJ.TJ_ORDEM "
		cQuery += "    AND STL.TL_PLANO = STJ.TJ_PLANO "
		cQuery += "  WHERE SUBSTRING(STJ.TJ_DTMRFIM,5,2) = " + ValToSql(cMes)
		cQuery += "    AND SUBSTRING(STJ.TJ_DTMRFIM,1,4) = " + ValToSql(cAno)
		cQuery += "    AND STL.TL_FILIAL   = " + ValToSql(NGTROCAFILI("STL",cFil))
		cQuery += "    AND STJ.TJ_FILIAL   = " + ValToSql(NGTROCAFILI("STJ",cFil))
		cQuery += "    AND STL.TL_SEQRELA  > '0' "
		cQuery += "    AND STJ.TJ_SITUACA  = 'L' "
		cQuery += "    AND STJ.TJ_TERMINO  = 'S' "
		cQuery += "    AND STL.TL_TIPOREG  = 'P' "

		If !Empty( cEquip )
			cQuery += " AND STJ.TJ_CODBEM = " + ValToSql(cEquip)
		EndIf

		cQuery += "    AND STL.D_E_L_E_T_ <> '*' "
		cQuery += "    AND STJ.D_E_L_E_T_ <> '*' "

		cQuery += " GROUP BY STJ.TJ_CODBEM, STJ.TJ_CCUSTO, STJ.TJ_CENTRAB "

		cQuery += " UNION"

		//ThirdPartCost - Custo com serviços de terceiros que trabalharam na OS
		cQuery += " SELECT STJ.TJ_CCUSTO CCUSTO, STJ.TJ_CODBEM CODBEM, COUNT(*) QTD, 'ThirdPartCost' TIPO, SUM(STL.TL_CUSTO) TOT "
		cQuery += "   FROM " + RetSqlName("STL") + " STL"
		cQuery += "   JOIN " + RetSqlName("STJ") + " STJ"
		cQuery += "     ON STL.TL_ORDEM = STJ.TJ_ORDEM "
		cQuery += "    AND STL.TL_PLANO = STJ.TJ_PLANO "
		cQuery += "  WHERE SUBSTRING(STJ.TJ_DTMRFIM,5,2) = " + ValToSql(cMes)
		cQuery += "    AND SUBSTRING(STJ.TJ_DTMRFIM,1,4) = " + ValToSql(cAno)
		cQuery += "    AND STL.TL_FILIAL = " + ValToSql(NGTROCAFILI("STL",cFil))
		cQuery += "    AND STJ.TJ_FILIAL = " + ValToSql(NGTROCAFILI("STJ",cFil))
		cQuery += "    AND STL.TL_SEQRELA > '0' "
		cQuery += "    AND STJ.TJ_SITUACA = 'L' "
		cQuery += "    AND STJ.TJ_TERMINO = 'S' "
		cQuery += "    AND STL.TL_TIPOREG = 'T' "

		If !Empty( cEquip )
			cQuery += " AND STJ.TJ_CODBEM = " + ValToSql(cEquip)
		EndIf

		cQuery += "    AND STL.D_E_L_E_T_ <> '*' "
		cQuery += "    AND STJ.D_E_L_E_T_ <> '*' "
		cQuery += "  GROUP BY STJ.TJ_CODBEM, STJ.TJ_CCUSTO, STJ.TJ_CENTRAB "

		cQuery += " UNION"

		//ToolCost - Custo com ferramentas aplicadas na OS
		cQuery += " SELECT STJ.TJ_CCUSTO CCUSTO, STJ.TJ_CODBEM CODBEM, COUNT(*) QTD, 'ToolCost' TIPO, SUM(STL.TL_CUSTO) TOT "
		cQuery += "   FROM " + RetSqlName("STL") + " STL"
		cQuery += "   JOIN " + RetSqlName("STJ") + " STJ"
		cQuery += "     ON STL.TL_ORDEM = STJ.TJ_ORDEM "
		cQuery += "    AND STL.TL_PLANO = STJ.TJ_PLANO "
		cQuery += "  WHERE SUBSTRING(STJ.TJ_DTMRFIM,5,2) = " + ValToSql(cMes)
		cQuery += "    AND SUBSTRING(STJ.TJ_DTMRFIM,1,4) = " + ValToSql(cAno)
		cQuery += "    AND STL.TL_FILIAL  = " + ValToSql(NGTROCAFILI("STL",cFil))
		cQuery += "    AND STJ.TJ_FILIAL  = " + ValToSql(NGTROCAFILI("STJ",cFil))
		cQuery += "    AND STL.TL_SEQRELA > '0' "
		cQuery += "    AND STJ.TJ_SITUACA = 'L' "
		cQuery += "    AND STJ.TJ_TERMINO = 'S' "
		cQuery += "    AND STL.TL_TIPOREG = 'F' "

		If !Empty( cEquip )
			cQuery += " AND STJ.TJ_CODBEM = " + ValToSql(cEquip)
		EndIf

		cQuery += "   AND STL.D_E_L_E_T_ <> '*' "
		cQuery += "   AND STJ.D_E_L_E_T_ <> '*' "
		cQuery += " GROUP BY STJ.TJ_CODBEM, STJ.TJ_CCUSTO, STJ.TJ_CENTRAB "

	EndIf

	If NGCADICBASE("TS_CUSTO","A","STS",.F.) .And. NGCADICBASE("TT_CUSTO","A","STT",.F.)

		// Cria copia das query em que se referencia STJ (acima)
		cQuery2 := cQuery
		cQuery2 := StrTran(cQuery2,"STJ","STS")
		cQuery2 := StrTran(cQuery2,"STL","STT")
		cQuery2 := StrTran(cQuery2,"TJ_","TS_")
		cQuery2 := StrTran(cQuery2,"TL_","TT_")

	EndIf

	If NGCADICBASE("TQN_CCUSTO","A","TQN",.F.)

		cQuery += " UNION"

		//FuelCost - Custo com os abastecimentos realizados no Mês
		cQuery += " SELECT TQN.TQN_CCUSTO CCUSTO, TQN.TQN_FROTA CODBEM, COUNT(*) QTD, 'FuelCost' TIPO, SUM(TQN.TQN_VALTOT) TOT "
		cQuery += "   FROM "      + RetSqlName("TQN") + " TQN"
		cQuery += "   LEFT JOIN " + RetSqlName("TQI") + " TQI"
		cQuery += "     ON TQI.TQI_CODPOS = TQN.TQN_POSTO "
		cQuery += "       AND TQI.TQI_LOJA = TQN.TQN_LOJA "
		cQuery += "       AND TQI.TQI_TANQUE = TQN.TQN_TANQUE "
		cQuery += "	      AND TQI.TQI_CODCOM = TQN.TQN_CODCOM "

		cQuery += "  WHERE "

		If !Empty( cEquip )
			cQuery += " TQN.TQN_FROTA = " + ValToSql(cEquip)
		EndIf

		cQuery += "   AND SUBSTRING(TQN.TQN_DTABAS,5,2) = " + ValToSql(cMes)
		cQuery += "   AND SUBSTRING(TQN.TQN_DTABAS,1,4) = " + ValToSql(cAno)
		cQuery += "   AND TQN.TQN_FILIAL = " + ValToSql(NGTROCAFILI("TQN",cFil))
		cQuery += "   AND (TQI.TQI_FILIAL IS NULL OR TQI.TQI_FILIAL = " + ValToSql(NGTROCAFILI("TQI",cFil)) + ")"
		cQuery += "   AND TQN.D_E_L_E_T_ <> '*' "
		cQuery += "   AND (TQI.D_E_L_E_T_ IS NULL OR TQI.D_E_L_E_T_ <> '*')"
		cQuery += " GROUP BY TQN.TQN_FROTA, TQN.TQN_CCUSTO, TQN.TQN_CENTRA"

	EndIf

	If NGCADICBASE("TRX_CCUSTO","A","TRX",.F.)

		cQuery += " UNION"

		//PenaltyCost - Custo com multas pagas no mês, podemos considerar somente multas por culpa da empresa
		cQuery += " SELECT TRX.TRX_CCUSTO CCUSTO, TRX.TRX_CODBEM CODBEM, COUNT(*) QTD, 'PenaltyCost' TIPO, SUM(TRX.TRX_VALPAG) TOT "
		cQuery += "   FROM " + RetSqlName("TRX") + " TRX"
		cQuery += "   JOIN " + RetSqlName("ST9") + " ST9"
		cQuery += "     ON TRX.TRX_CODBEM = ST9.T9_CODBEM"
		cQuery += "  WHERE "

		If !Empty( cEquip )
			cQuery += " TRX.TRX_CODBEM = " + ValToSql(cEquip)
		EndIf

		cQuery += "   AND SUBSTRING(TRX.TRX_DTPGTO,5,2) = " + ValToSql(cMes)
		cQuery += "   AND SUBSTRING(TRX.TRX_DTPGTO,1,4) = " + ValToSql(cAno)
		cQuery += "   AND TRX.TRX_FILIAL  = " + ValToSql(NGTROCAFILI("TRH",cFil))
		cQuery += "   AND ST9.T9_FILIAL   = " + ValToSql(NGTROCAFILI("ST9",cFil))
		cQuery += "   AND TRX.D_E_L_E_T_ <> '*' "
		cQuery += "   AND ST9.D_E_L_E_T_ <> '*' "
		cQuery += " GROUP BY TRX.TRX_CODBEM, TRX.TRX_CCUSTO"
		//nao considera TSG - Movimento Pagamentos Efetuados

	EndIf

	If 	NGCADICBASE("TRH_VALDAN","A","TRH",.F.) .And. NGCADICBASE("TRK_VALAVA","A","TRK",.F.) .And. ;
		NGCADICBASE("TRO_VALPRE","A","TRO",.F.) .And. NGCADICBASE("TRL_VALPRE","A","TRL",.F.) .And. ;
		NGCADICBASE("TRV_VALRES","A","TRV",.F.) .And. NGCADICBASE("TRM_VALVIT","A","TRM",.F.) .And. ;
		NGCADICBASE("TRT_NUMSIN","A","TRT",.F.) .And. NGCADICBASE("TT_CCUSTO","A","STT",.F.)  .And. ;
		NGCADICBASE("TL_CCUSTO","A","STL",.F.)  .And. NGCADICBASE("TS_CCUSTO","A","STS",.F.)  .And. ;
		NGCADICBASE("TJ_CCUSTO","A","STJ",.F.)

		cQuery += " UNION"
		//IncidentCost-Sinistro
		cQuery += " SELECT ST9.T9_CCUSTO CCUSTO, ST9.T9_CODBEM CODBEM, COUNT(*) QTD, 'IncidentCost' TIPO,"
		cQuery += "   " + cIsNull + "(SUM(TRH.TRH_VALDAN),0) +"
		cQuery += "   " + cIsNull + "(SUM(TRH.TRH_VALGUI),0) +"
		cQuery += "   " + cIsNull + "(SUM(TRK.TRK_VALAVA),0) +"
		cQuery += "   -" + cIsNull + "(SUM(TRK.TRK_VALREC),0) +"
		cQuery += "   " + cIsNull + "(SUM(TRH.TRH_VALANI),0) +"
		cQuery += "   " + cIsNull + "(SUM(TRO.TRO_VALPRE),0) +"
		cQuery += "   " + cIsNull + "(SUM(TRO.TRO_VALTER),0) +"
		cQuery += "   " + cIsNull + "(SUM(TRL.TRL_VALPRE),0) +"
		cQuery += "   -" + cIsNull + "(SUM(TRV.TRV_VALRES),0) +"
		cQuery += "   " + cIsNull + "(SUM(TRM.TRM_VALVIT),0) +"
		cQuery += "   " + cIsNull + "(SUM(TBL.TOT),0) TOT FROM "
		cQuery += "	     (SELECT " + cIsNull + "(SUM(STL.TL_CUSTO),0) + " + cIsNull + "(SUM(STT.TT_CUSTO),0) TOT FROM " + RetSqlName("TRH") + " TRH"
		cQuery += "	     	JOIN " + RetSqlName("TRT") + " TRT ON TRH.TRH_NUMSIN = TRT.TRT_NUMSIN"
		cQuery += "	     	LEFT JOIN " + RetSqlName("STJ") + " STJ ON STJ.TJ_ORDEM = TRT.TRT_NUMOS AND STJ.TJ_PLANO = TRT.TRT_PLANO"
		cQuery += "	     	LEFT JOIN " + RetSqlName("STL") + " STL ON STL.TL_ORDEM = STJ.TJ_ORDEM  AND STL.TL_PLANO = STJ.TJ_PLANO"
		cQuery += "	     	LEFT JOIN " + RetSqlName("STS") + " STS ON STS.TS_ORDEM = TRT.TRT_NUMOS AND STS.TS_PLANO = TRT.TRT_PLANO"
		cQuery += "	     	LEFT JOIN " + RetSqlName("STT") + " STT ON STT.TT_ORDEM = STS.TS_ORDEM AND STT.TT_PLANO = STS.TS_PLANO"
		cQuery += "	     	WHERE (STJ.TJ_SEQRELA IS NULL OR STJ.TJ_SEQRELA > '0') AND "
		cQuery += "	     	      (STS.TS_SEQRELA IS NULL OR STS.TS_SEQRELA > '0') AND "

		If !Empty( cEquip )
			cQuery += "      TRH.TRH_CODBEM = '" + cEquip + "' AND"
		EndIf

		cQuery += "         SUBSTRING(TRH.TRH_DTACID,5,2) = '" + cMes + "' AND"
		cQuery += "         SUBSTRING(TRH.TRH_DTACID,1,4) = '" + cAno + "' AND"
		cQuery += "         TRH.TRH_FILIAL = '" + NGTROCAFILI("TRH",cFil) + "' AND"
		cQuery += "         TRT.TRT_FILIAL = '" + NGTROCAFILI("TRT",cFil) + "' AND"
		cQuery += "         (STJ.TJ_FILIAL IS NULL OR STJ.TJ_FILIAL = '" + NGTROCAFILI("STJ",cFil) + "') AND"
		cQuery += "         (STL.TL_FILIAL IS NULL OR STL.TL_FILIAL = '" + NGTROCAFILI("STL",cFil) + "') AND"
		cQuery += "         (STS.TS_FILIAL IS NULL OR STS.TS_FILIAL = '" + NGTROCAFILI("STS",cFil) + "') AND"
		cQuery += "         (STT.TT_FILIAL IS NULL OR STT.TT_FILIAL = '" + NGTROCAFILI("STT",cFil) + "') AND"
		cQuery += "         TRH.D_E_L_E_T_ <> '*' AND TRT.D_E_L_E_T_ <> '*' AND"
		cQuery += "         (STJ.D_E_L_E_T_ IS NULL OR STJ.D_E_L_E_T_ <> '*') AND"
		cQuery += "         (STL.D_E_L_E_T_ IS NULL OR STL.D_E_L_E_T_ <> '*') AND"
		cQuery += "         (STS.D_E_L_E_T_ IS NULL OR STS.D_E_L_E_T_ <> '*') AND"
		cQuery += "         (STT.D_E_L_E_T_ IS NULL OR STT.D_E_L_E_T_ <> '*') AND
		cQuery += "         (STL.TL_SEQRELA IS NULL OR STL.TL_SEQRELA > '0') AND"
		cQuery += "         (STJ.TJ_SITUACA IS NULL OR STJ.TJ_SITUACA = 'L') AND"
		cQuery += "         (STJ.TJ_TERMINO IS NULL OR STJ.TJ_TERMINO = 'S') AND"
		cQuery += "         (STT.TT_SEQRELA IS NULL OR STT.TT_SEQRELA > '0') AND"
		cQuery += "         (STS.TS_SITUACA IS NULL OR STS.TS_SITUACA = 'L') AND"
		cQuery += "         (STS.TS_TERMINO IS NULL OR STS.TS_TERMINO = 'S')) TBL,"
		cQuery += RetSqlName("SX2",01,"X2_ARQUIVO","TRH",cEmp) + " TRH"
		cQuery += " LEFT JOIN " + RetSqlName("TRK") + " TRK ON TRH.TRH_NUMSIN = TRK.TRK_NUMSIN"
		cQuery += " LEFT JOIN " + RetSqlName("TRO") + " TRO ON TRO.TRO_DANOS  = '1' AND TRH.TRH_NUMSIN = TRO.TRO_NUMSIN"
		cQuery += " LEFT JOIN " + RetSqlName("TRL") + " TRL ON TRL.TRL_DANOS  = '1' AND TRH.TRH_NUMSIN = TRL.TRL_NUMSIN"
		cQuery += " LEFT JOIN " + RetSqlName("TRV") + " TRV ON TRH.TRH_NUMSIN = TRV.TRV_NUMSIN"
		cQuery += " LEFT JOIN " + RetSqlName("TRM") + " TRM ON TRH.TRH_NUMSIN = TRM.TRM_NUMSIN"
		cQuery += " LEFT JOIN " + RetSqlName("ST9") + " ST9 ON ST9.T9_CODBEM  = TRH.TRH_CODBEM"
		cQuery += " WHERE"

		If !Empty( cEquip )
			cQuery += " TRH.TRH_CODBEM = '" + cEquip + "' AND"
		EndIf

		cQuery += "   SUBSTRING(TRH.TRH_DTACID,5,2) = '" + cMes + "' AND"
		cQuery += "   SUBSTRING(TRH.TRH_DTACID,1,4) = '" + cAno + "' AND"
		cQuery += "   TRH.TRH_FILIAL = '" + NGTROCAFILI("TRH",cFil) + "' AND"
		cQuery += "   (TRK.TRK_FILIAL IS NULL OR TRK.TRK_FILIAL = '" + NGTROCAFILI("TRK",cFil) + "') AND"
		cQuery += "   (TRO.TRO_FILIAL IS NULL OR TRO.TRO_FILIAL = '" + NGTROCAFILI("TRO",cFil) + "') AND"
		cQuery += "   (TRL.TRL_FILIAL IS NULL OR TRL.TRL_FILIAL = '" + NGTROCAFILI("TRL",cFil) + "') AND"
		cQuery += "   (TRV.TRV_FILIAL IS NULL OR TRV.TRV_FILIAL = '" + NGTROCAFILI("TRV",cFil) + "') AND"
		cQuery += "   (TRM.TRM_FILIAL IS NULL OR TRM.TRM_FILIAL = '" + NGTROCAFILI("TRM",cFil) + "') AND"
		cQuery += "   (ST9.T9_FILIAL  IS NULL OR ST9.T9_FILIAL  = '" + NGTROCAFILI("ST9",cFil) + "') AND"
		cQuery += "   (TRH.D_E_L_E_T_ IS NULL OR TRH.D_E_L_E_T_ <> '*') AND"
		cQuery += "   (TRK.D_E_L_E_T_ IS NULL OR TRK.D_E_L_E_T_ <> '*') AND"
		cQuery += "   (TRO.D_E_L_E_T_ IS NULL OR TRO.D_E_L_E_T_ <> '*') AND"
		cQuery += "   (TRL.D_E_L_E_T_ IS NULL OR TRL.D_E_L_E_T_ <> '*') AND"
		cQuery += "   (TRV.D_E_L_E_T_ IS NULL OR TRV.D_E_L_E_T_ <> '*') AND"
		cQuery += "   (TRM.D_E_L_E_T_ IS NULL OR TRM.D_E_L_E_T_ <> '*') AND"
		cQuery += "   (ST9.D_E_L_E_T_ IS NULL OR ST9.D_E_L_E_T_ <> '*')"
		cQuery += "  GROUP BY ST9.T9_CODBEM, ST9.T9_CCUSTO, ST9.T9_CENTRAB"

	EndIf

	If NGCADICBASE("TS2_CCUSTO","A","TS2",.F.)

		cQuery += " UNION"

		// PaperCost - Custo Documentos
		cQuery += "	SELECT TS2.TS2_CCUSTO CCUSTO, TS2.TS2_CODBEM CODBEM, COUNT(*) QTD, 'PaperCost' TIPO,  SUM(TS2.TS2_VALOR) TOT "
		cQuery += "	  FROM " + RetSqlName("TS2") + " TS2 "
		cQuery += "	  JOIN " + RetSqlName("ST9") + " ST9 "
		cQuery += "	    ON ST9.T9_CODBEM = TS2.TS2_CODBEM "
		cQuery += "	WHERE "

		If !Empty( cEquip )
			cQuery += "   TS2.TS2_CODBEM = " + ValToSql(cEquip)
		EndIf

		cQuery += "   AND SUBSTRING(TS2.TS2_DTPGTO,5,2) = " + ValToSql(cMes)
		cQuery += "   AND SUBSTRING(TS2.TS2_DTPGTO,1,4) = " + ValToSql(cAno)
		cQuery += "   AND TS2.TS2_FILIAL = " + ValToSql(NGTROCAFILI("TS2",cFil))
		cQuery += "   AND ST9.T9_FILIAL  = " + ValToSql(NGTROCAFILI("ST9",cFil))
		cQuery += "   AND TS2.D_E_L_E_T_ <> '*' "
		cQuery += "   AND ST9.D_E_L_E_T_ <> '*' "
		cQuery += " GROUP BY TS2.TS2_CODBEM, TS2.TS2_CCUSTO "

	EndIf

	If !Empty(cQuery2)
		cQuery += " UNION "
		cQuery += cQuery2
	EndIf

	cQuery += " ORDER BY CODBEM, CCUSTO, TIPO "

	cQuery  := ChangeQuery(cQuery)
	cQuery2 := ChangeQuery(cQuery2)

	// Transfere resultado da query para tabela temporaria especifica
	SqlToTrb(cQuery,aDBF,cAliasQry)

	// ---------------------------------------------------
	// Custos Indiretos
	//----------------------------------------------------

	// Percorre resultados da query
	dbSelectArea(cAliasQry)
	dbGoTop()
	If (cAliasQry)->(!Eof())
		While (cAliasQry)->(!Eof())

			// Define equipamento para agrupamento de custos
			cCpEquip  := (cAliasQry)->CODBEM

			// Inicializa variaveis chaves para o armazenamento dos custos
			nHrCostEquip     := 0
			aIndirectCosts   := {}
			aApptsDirectCost := {}

			// Define array de Custos por Centro de Custo
			// [1] Centro de Custo | [2] Tags Envolvidas
			While !Eof() .And. (cAliasQry)->CODBEM == cCpEquip

				If ( nEquipCosts := aScan( aIndirectCosts, {|x| x[1] == cCpEquip } ) ) == 0
					aAdd( aIndirectCosts, { cCpEquip, {} } ) // Custo | Tags
					nEquipCosts := Len(aIndirectCosts)
				EndIf

				// Verifica se ja existe algum custo gerado para o centro de custo em questao
				// Caso nao, cria posicao para o mesmo
				If ( nIndCostCC := aScan( aIndirectCosts[nEquipCosts][2], {|x| x[1] == (cAliasQry)->CCUSTO } ) ) == 0
					aAdd( aIndirectCosts[nEquipCosts][2], { (cAliasQry)->CCUSTO, {} } ) // Custo | Tags
					nIndCostCC := Len(aIndirectCosts[nEquipCosts][2])
				EndIf

				// Verifica se ja existe algum custo para o tipo de custo em questao
				// Caso nao, cria posicao para o tipo
				If ( nCostType := aScan( aIndirectCosts[nEquipCosts][2][nIndCostCC][2], {|x| x[1] == (cAliasQry)->TIPO } ) ) == 0
					aAdd( aIndirectCosts[nEquipCosts][2][nIndCostCC][2], { (cAliasQry)->TIPO, 0 } )
					nCostType := Len(aIndirectCosts[nEquipCosts][2][nIndCostCC][2])
				EndIf

				// Adiciona custo ao tipo correspondente, conforme centro de custo
				aIndirectCosts[nEquipCosts][2][nIndCostCC][2][nCostType][2] += (cAliasQry)->TOT

				dbSelectArea(cAliasQry)
				dbSkip()

			EndDo

		EndDo
	EndIf

	For nCostEquip := 1 To Len(aIndirectCosts)

		// Custos do Equipamento | Diretos e Indiretos
		If ( nEquipCosts := aScan( aCostsEquip, {|x| x[1] == aIndirectCosts[nCostEquip][1] } ) ) == 0
			aAdd(aCostsEquip, {	aIndirectCosts[nCostEquip][1] , ;
										cMes           , ;
										cAno           , ;
										{}					, ;
										{}   				} )

			nEquipCosts := Len(aCostsEquip)
		EndIf

		aCostsEquip[nEquipCosts][4] := aIndirectCosts[nCostEquip][2]

	Next nCostEquip

	// ---------------------------------------------------
	// Custos Diretos
	//----------------------------------------------------

	// Recupera apontamentos [ Custos Diretos ]
	aAppointments := GetCostApp(cEmp, cFil, cEquip, cMes, cAno)

	// Verifica se existem custos diretos para o equipamento em questao
	// nApptsEquip := aScan( aAppointments,{|x| x[1] == cCpEquip } )

	// Percorre todos os apontamentos encontrados
	For nApptsEquip := 1 To Len(aAppointments)

		// Percorre centro de custos em que geraram custo no periodo para o bem em questao
		For nApptsCC := 1 To Len(aAppointments[nApptsEquip][2])

			// Verifica se o centro de custo analisado ja foi visto anteriormente
			If ( nEquipCosts := aScan( aDirectCosts, {|x| x[1] == aAppointments[nApptsEquip][1] } ) ) == 0
				aAdd( aDirectCosts, { aAppointments[nApptsEquip][1], {} } )
				nEquipCosts := Len(aDirectCosts)
			EndIf

			// Verifica se o centro de custo analisado ja foi visto anteriormente
			If ( nDrtCostCC := aScan( aDirectCosts[nEquipCosts][2], {|x| x[1] == aAppointments[nApptsEquip][2][nApptsCC][1] } ) ) == 0
				aAdd( aDirectCosts[nEquipCosts][2], { aAppointments[nApptsEquip][2][nApptsCC][1], {}, {} } )
				nDrtCostCC := Len(aDirectCosts[nEquipCosts][2])
			EndIf

			// Montante de horas produtivas e improdutivas, baseado nos apontamentos
			aAdd( aDirectCosts[nEquipCosts][2][nDrtCostCC][2], { 'ProductiveHoursAmount'  , aAppointments[nApptsEquip][2][nApptsCC][2] } ) // Total de Horas Produtivas
			aAdd( aDirectCosts[nEquipCosts][2][nDrtCostCC][2], { 'UnproductiveHoursAmount', aAppointments[nApptsEquip][2][nApptsCC][3] } ) // Total de Horas Improdutivas
			aApptsDirectCost := aClone(aAppointments[nApptsEquip][2][nApptsCC][4])

			//Ponto de Entrada para a manipulação do custo hora do Bem
			If lMNTA4941
				nHrCostEquip := ExecBlock("MNTA4941", .F., .F.,{cFil,aAppointments[nApptsEquip][1], cMes, cAno})
				lPE4941      := .T.
			Else
				nHrCostEquip := NGSEEK("ST9",aAppointments[nApptsEquip][1],1,"ST9->T9_CUSTOHO", cFil, cEmp, cEmpAnt) // Verifica custo de hora do equipamento
				lPE4941      := .F.
			EndIf

			// Caso as horas tenham sido corretamente alcancadas
			If ValType(nHrCostEquip) == "N"

				// Custo Horas Produtivas
				If ( nTag := aScan( aDirectCosts[nEquipCosts][2][nDrtCostCC][2], {|x| x[1] == "ProductiveHoursAmount" } ) ) > 0
					aAdd( aDirectCosts[nEquipCosts][2][nDrtCostCC][2], { "ProductiveHoursCost"  ,  IIf(!lPE4941,aDirectCosts[nEquipCosts][2][nDrtCostCC][2][nTag][2] * nHrCostEquip,nHrCostEquip) } )
				EndIf

				// Custo Horas Improdutivas
				If ( nTag := aScan( aDirectCosts[nEquipCosts][2][nDrtCostCC][2], {|x| x[1] == "UnproductiveHoursAmount" } ) ) > 0
					aAdd( aDirectCosts[nEquipCosts][2][nDrtCostCC][2], { "UnproductiveHoursCost",  IIf(!lPE4941,aDirectCosts[nEquipCosts][2][nDrtCostCC][2][nTag][2] * nHrCostEquip,nHrCostEquip) } )
				EndIf

			EndIf

			// Adiciona apontamentos vinculados 'a quantidade de horas mencionadas nas tags
			aDirectCosts[nEquipCosts][2][nDrtCostCC][3] := aClone(aApptsDirectCost)

		Next nApptsCC

	Next nApptsEquip

	For nCostEquip := 1 To Len(aDirectCosts)

		// Custos do Equipamento | Diretos e Indiretos
		If ( nEquipCosts := aScan( aCostsEquip, {|x| x[1] == aDirectCosts[nCostEquip][1] } ) ) == 0
			aAdd(aCostsEquip, {	aDirectCosts[nCostEquip][1] , ;
										cMes           , ;
										cAno           , ;
										{}					, ;
										{}   				} )

			nEquipCosts := Len(aCostsEquip)
		EndIf

		aCostsEquip[nEquipCosts][5] := aDirectCosts[nCostEquip][2]

	Next nCostEquip

	oTempQRY:Delete()

Return aCostsEquip

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT494VLBM
Funcao de tratamento para o recebimento/envio de mensagem unica de
cadastro de atividades da parte diária.

@author Felipe Nathan Welter
@since 09/07/13
@version P11
@return aArray sendo [1]-.T./.F. e [2]-cError
/*/
//---------------------------------------------------------------------
Static Function GetXmlDate(cData, cHora)

	Local cXmlDate := ""

	cXmlDate := SubStr(cData,1,4) + "-" + SubStr(cData,5,2) + "-" + SubStr(cData,7,2)
	cXmlDate += "T" + StrTran( Transform(cHora, "99:99:99"), " ", "0" )

Return cXmlDate

//---------------------------------------------------------------------
/*/{Protheus.doc} GetCostApp
Custos de Apontamentos.

@author Felipe Nathan Welter
@since 09/07/13
@version P11
@return aArray sendo [1]-.T./.F. e [2]-cError
/*/
//---------------------------------------------------------------------
Static Function GetCostApp(cEmp, cFil, cEquip, cMes, cAno)

	Local aAppointments := {}
	Local aAppointAux   := {}

	Local cQueryApp     := ""
	Local cAliasQrApp   := GetNextAlias()

	Local nTipo
	Local nApp
	Local nApptsEquip
	Local nApptsCC

	Local nQtdApp := 999

	cQueryApp := " SELECT TV2.TV2_FILIAL, TV2.TV2_EMPRES, TV2.TV2_DTSERV, TV2.TV2_TURNO, "
	cQueryApp += "        TV2.TV2_PDIHRI, TV2.TV2_PDIHRF, TV2.TV2_HRINI, TV2_HRFIM, TV2.TV2_CODATI,
	cQueryApp += "        TV2.TV2_CODFRE, TV2.TV2_CODBEM, TV2.TV2_TOTHOR, TV2.TV2_INTTSK, TV0.TV0_TIPHOR, TV2.TV2_SEQREL "
	cQueryApp += "   FROM " + RetFullName("TV2",cEmp) + " TV2 "
	cQueryApp += "  INNER JOIN " + RetFullName("TV0",cEmp) + " TV0 "
	cQueryApp += "     ON ( TV0.TV0_CODATI = TV2.TV2_CODATI )"
	cQueryApp += "  INNER JOIN " + RetFullName("TV1",cEmp) + " TV1 "
	cQueryApp += "     ON ( TV1.TV1_FILIAL = TV2.TV2_FILIAL "
	cQueryApp += "        AND TV1.TV1_EMPRES = TV2.TV2_EMPRES "
	cQueryApp += "        AND TV1.TV1_CODBEM = TV2.TV2_CODBEM "
	cQueryApp += "        AND TV1.TV1_DTSERV = TV2.TV2_DTSERV "
	cQueryApp += "        AND TV1.TV1_TURNO = TV2.TV2_TURNO "
	cQueryApp += "        AND TV1.TV1_HRINI = TV2.TV2_PDIHRI "
	cQueryApp += "        AND TV1.TV1_HRFIM = TV2.TV2_PDIHRF )  AND TV1.TV1_INDERR = '2' "
	cQueryApp += "  WHERE SUBSTRING(TV2.TV2_DTSERV,5,2) = '" + cMes + "' "
	cQueryApp += "    AND SUBSTRING(TV2.TV2_DTSERV,1,4) = '" + cAno + "' "
	If !Empty( cEquip )
		cQueryApp += "    AND TV2.TV2_CODBEM = '" + cEquip + "' "
	EndIf
	cQueryApp += "    AND TV2.TV2_INDERR = '2' "
	cQueryApp += "    AND TV2.TV2_FILIAL = '" + NGTROCAFILI("TV2", cFil) + "' "
	cQueryApp += "    AND TV0.TV0_FILIAL = '" + NGTROCAFILI("TV0", cFil) + "' "
	cQueryApp += "    AND TV1.TV1_FILIAL = '" + NGTROCAFILI("TV1", cFil) + "' "
	cQueryApp += "    AND TV2.D_E_L_E_T_ <> '*' "
	cQueryApp += "    AND TV0.D_E_L_E_T_ <> '*' "
	cQueryApp += "    AND TV1.D_E_L_E_T_ <> '*' "
	cQueryApp += "  ORDER BY TV2.TV2_CODBEM, TV2.TV2_CODFRE"

	cQueryApp  := ChangeQuery(cQueryApp)
	MPSysOpenQuery( cQueryApp , cAliasQrApp )

	dbSelectArea(cAliasQrApp)
	dbGoTop()
	While (cAliasQrApp)->(!Eof())

		nApptsEquip := aScan(aAppointments,{|x|x[1] == (cAliasQrApp)->TV2_CODBEM})
		cIntIDApp   := (cAliasQrApp)->TV2_EMPRES + "|" + (cAliasQrApp)->TV2_FILIAL + "|" + (cAliasQrApp)->TV2_EMPRES + "|" + ;
					   (cAliasQrApp)->TV2_CODBEM + "|" + (cAliasQrApp)->TV2_DTSERV + "|" + (cAliasQrApp)->TV2_SEQREL

		aAppointAux := {cIntIDApp,;
					    (cAliasQrApp)->TV2_INTTSK,;
						(cAliasQrApp)->TV2_EMPRES + "|" + (cAliasQrApp)->TV2_FILIAL + "|" + (cAliasQrApp)->TV2_INTTSK,;
						GetXmlDate((cAliasQrApp)->TV2_DTSERV,(cAliasQrApp)->TV2_HRINI),;   // StartDateTime
						GetXmlDate((cAliasQrApp)->TV2_DTSERV,(cAliasQrApp)->TV2_HRFIM),;   // EndDateTime
						If((cAliasQrApp)->TV0_TIPHOR <> "1",(cAliasQrApp)->TV2_CODATI,"")} // Motivo de Improdutividade

		While nApptsEquip > 0

			nQtdItens := 0

			If nApptsEquip > Len(aAppointments)
				nApptsEquip := 0
				Exit
			EndIf

			For nApp := 1 To Len(aAppointments[nApptsEquip][2])
				nQtdItens += Len(aAppointments[nApptsEquip][2][nApp][4])
			Next nApp

			If nQtdItens < nQtdApp
				Exit
			EndIf

			nApptsEquip++

		End

		If nApptsEquip == 0
			aAdd(aAppointments,{(cAliasQrApp)->TV2_CODBEM,{}})
			nApptsEquip := Len(aAppointments)
		EndIf

		If (nApptsCC := aScan( aAppointments[nApptsEquip][2], {|x| x[1] == (cAliasQrApp)->TV2_CODFRE } ) ) == 0
			aCostsCC := {(cAliasQrApp)->TV2_CODFRE, 0, 0, {}}
			aAdd(aAppointments[nApptsEquip][2],aClone(aCostsCC))
			nApptsCC := Len(aAppointments[nApptsEquip][2])
		EndIf

		nTipo := If((cAliasQrApp)->TV0_TIPHOR == "1", 2, 3)
		aAppointments[nApptsEquip][2][nApptsCC][nTipo] += HTON( (cAliasQrApp)->TV2_TOTHOR )
		aAdd( aAppointments[nApptsEquip][2][nApptsCC][4], aClone(aAppointAux) )

		dbSelectArea(cAliasQrApp)
		dbSkip()

	End
	(cAliasQrApp)->(dbCloseArea())

Return aAppointments
