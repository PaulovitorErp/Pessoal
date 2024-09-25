#INCLUDE "MNTR985.ch"
#INCLUDE "PROTHEUS.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR985
Relatório para listar as multas a pagar

@author Marcos Wagner Junior
@since 16/07/2010
/*/
//---------------------------------------------------------------------
Function MNTR985()

	//---------------------------------------------------------------------
	// Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	//---------------------------------------------------------------------
	Local aNGBEGINPRM := NGBEGINPRM()
	Local cString     := "TRX"
	Local cDesc1      := STR0001 //"Relatório de multas a pagar"
	Local cDesc2      := ""
	Local cDesc3      := ""
	Local wnrel       := "MNTR985"

	Private aReturn   := {STR0002, 1,STR0003, 1, 2, 1, "",1 } //"Zebrado"###"Administração"
	Private nLastKey  := 0
	Private cPerg     := "MNTR985"
	Private Titulo    := STR0001 //"Relatório de Multas a Pagar"
	Private TamanhO   := "G"
	Private nomeprog  := "MNTR985"
	Private lEditResp := If(NGCADICBASE("TRX_REPON","A","TRX",.F.),.T.,.F.)
	Private lIntFin   := ( SuperGetMV("MV_NGMNTFI", .F., "N") == "S" )

	Pergunte(cPerg,.F.)

	wnrel := SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"")

	If nLastKey = 27
		Set Filter To
		dbSelectArea("TRX")
		Return
	EndIf

	SetDefault(aReturn,cString)
	RptStatus({|lEnd| RFR985Imp(@lEnd,wnRel,titulo,tamanho)},titulo)

	Set Key VK_F9 To
	dbSelectArea("TRX")

	//---------------------------------------------------------------------
	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	//---------------------------------------------------------------------
	NGRETURNPRM(aNGBEGINPRM)

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} RFR985Imp
Chamada do Relatório

@author Marcos Wagner Junior
@since 16/07/2010
/*/
//---------------------------------------------------------------------
Function RFR985Imp(lEND,WNREL,TITULO,TAMANHO)

	Local nI
	Local nX
	Local cRODATXT    := ""
	Local nCNTIMPR    := 0
	Local nTotPagar   := 0
	Local lTRX_MMSYP  := NGCADICBASE('TRX_MMSYP','A','TRX',.F.)
	Local lTRX_OBS    := NGCADICBASE('TRX_OBS   ','A','TRX',.F.)
	Local lTRX_MMCOND := NGCADICBASE('TRX_MMCOND','A','TRX',.F.)
	Local lTRX_OBCOND := NGCADICBASE('TRX_OBCOND','A','TRX',.F.)
	Local cTRX_DESOBS := ''
	Local cTRX_OBCOND := ''
	Local cNomRes     := ""
	// [LGPD] Caso o usuário não possua acesso ao(s) campo(s), deve-se ofuscá-lo(s)
	Local lOfuscar := FindFunction( 'FWPDCanUse' ) .And. FwPdCanUse( .T. );
					.And. Len( FwProtectedDataUtil():UsrAccessPDField( __CUSERID, { 'TRX_NOME' } ) ) == 0

	Private li    := 80
	Private m_pag := 1

	nTIPO  := IIf(aReturn[4]==1,15,18)
	CABEC1 := STR0010 //"Multa     Nro Infração   C. Custo  Bem              Dt. Infr.  Docto Correios Aviso  N. Fiscal  Aut.Inf. Rest. Vencimento        Desconto   Valor a Pagar"
	CABEC2 := STR0020 //"	Motorista                                 Descrição do Artigo                  Responsabilidade"

	/*/
	1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2
	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	*****************************************************************************************************************************************************************************************************************************
	Multa     Nro Infração   C. Custo             Bem              Dt. Infr.  Docto Correios Aviso  N. Fiscal  Aut.Inf. Rest. Vencimento        Desconto   Valor a Pagar"
	Multa     Nro Infração   C. Custo             Bem              Dt. Infr.  Docto Correios Aviso  N. Fiscal  Aut.Inf. Rest. Vencimento        Desconto   Valor a Pagar  No. Título (somente se estiver integrado com o Financeiro)
	Motorista                                 Descrição do Artigo                  Responsabilidade
	*****************************************************************************************************************************************************************************************************************************

	999/99/99 99999999999999 xxxxxxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxx 99/99/9999 xxxxxxxxxxxxxxxxxxxx  xxxxxxxxx  Sim      Sim   99/99/9999  999,999,999.99  999,999,999.99  XXXXXXXXX
	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxx               TOTAL A PAGAR: 999.999.999.999,99
	*/

	// Se estiver integrado com o Financeiro, acrescenta a coluna Número do Título, gerado pela Multa no Contas a Pagar
	If lIntFin
		dbSelectArea("SX3")
		dbSetOrder(2)
		If dbSeek("TRX_NUMSE2")
			CABEC1 += Space(1) + SubStr(X3Titulo(),1,10)
		EndIf
	EndIf

	cAliasQry := GetNextAlias()
	cQuery    := " SELECT TRX.TRX_FILIAL, TRX.TRX_MULTA, TRX.TRX_NUMAIT, TRX.TRX_CCUSTO, TRX.TRX_CODBEM, TRX.TRX_DTINFR, TRX.TRX_NUMAR, TRX.TRX_NOME,"
	cQuery    += "        TRX.TRX_NF, TRX.TRX_RECAUT, TRX.TRX_RESTIT, TRX.TRX_DTVECI, TRX.TRX_VALOR, TRX.TRX_DESCON, TSH.TSH_DESART, TSH.TSH_RESPON "

	If lTRX_MMSYP
		cQuery += ", TRX.TRX_MMSYP "
	EndIf

	If lTRX_MMCOND
		cQuery += ", TRX.TRX_MMCOND "
	EndIf

	If lEditResp
		cQuery += ", TRX.TRX_REPON "
	EndIf

	If lIntFin
		cQuery += ", TRX.TRX_NUMSE2 "
	EndIf

	cQuery += " FROM " + RetSqlName("TRX") + " TRX, " + RetSqlName("TSH") + " TSH "
	cQuery += " WHERE TRX.TRX_PAGTO  = '2' "

	If NGSX2MODO("TRX") == NGSX2MODO("TSH")
		cQuery += " AND TRX.TRX_FILIAL = TSH.TSH_FILIAL "
	Else
		cQuery += " AND TRX.TRX_FILIAL = '"+xFilial("TRX")+"' AND TSH.TSH_FILIAL = '"+xFilial("TSH")+"' "
	EndIf

	If !Empty(MV_PAR02)
		cQuery += " AND TRX.TRX_CODBEM BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
	EndIf

	If !Empty(MV_PAR04)
		cQuery += " AND TRX.TRX_PLACA BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
	EndIf

	cQuery += " AND TRX.TRX_CODINF = TSH.TSH_CODINF "
	cQuery += " AND TRX.TRX_DTVECI BETWEEN '" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) + "' "
	cQuery += " AND   TRX.D_E_L_E_T_ = ' ' "
	cQuery += " AND   TSH.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY TRX.TRX_DTINFR "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	dbSelectArea(cAliasQry)
	dbGoTop()
	If Eof()
		MsgInfo(STR0011,STR0012)  //"Não existem dados para montar o relatório."###"Atenção"
		(cAliasQry)->(dbCloseArea())
		Return
	Else

		nTotPagar := 0
		While !Eof()

			If lEditResp
				cNomRes := SubStr(NGRETSX3BOX("TRX_REPON",(cAliasQry)->TRX_REPON),1,24)
			Else
				cNomRes := SubStr(NGRETSX3BOX("TSH_RESPON",(cAliasQry)->TSH_RESPON),1,24)
			EndIf

			NgSomaLi(58)
			@Li,000 Psay (cAliasQry)->TRX_MULTA Picture '@!'
			@Li,020 Psay (cAliasQry)->TRX_NUMAIT
			@Li,035 Psay (cAliasQry)->TRX_CCUSTO
			@Li,056 Psay (cAliasQry)->TRX_CODBEM
			@Li,073 Psay STOD((cAliasQry)->TRX_DTINFR) Picture "99/99/9999"
			@Li,084 Psay (cAliasQry)->TRX_NUMAR
			@Li,106 Psay (cAliasQry)->TRX_NF
			@Li,117 Psay NGRETSX3BOX("TRX_RECAUT",(cAliasQry)->TRX_RECAUT)
			If !Empty((cAliasQry)->TRX_RESTIT)
				@Li,126 Psay NGRETSX3BOX("TRX_RESTIT",(cAliasQry)->TRX_RESTIT)
			EndIf
			@Li,132 Psay STOD((cAliasQry)->TRX_DTVECI) Picture "99/99/9999"
			@Li,144 Psay PADL(Transform((cAliasQry)->TRX_DESCON,"@E 999,999,999.99"),14)
			@Li,160 Psay PADL(Transform((cAliasQry)->TRX_VALOR - (cAliasQry)->TRX_DESCON,"@E 999,999,999.99"),14)
			If lIntFin
				@Li,176 Psay (cAliasQry)->TRX_NUMSE2
			EndIf
			NgSomaLi(58)
			If lOfuscar
				@li,004 PSay FwProtectedDataUtil():ValueAsteriskToAnonymize(  ) Picture "@!"
			Else
				@li,004 PSay SubStr((cAliasQry)->TRX_NOME,1,40) Picture "@!"
			EndIf
			@Li,046 Psay SubStr((cAliasQry)->TSH_DESART,1,35)
			@Li,083 Psay cNomRes

			//Verifica campo memo 1
			cTRX_DESOBS := ''
			If lTRX_MMSYP .And. !Empty((cAliasQry)->TRX_MMSYP)
				cTRX_DESOBS := NGMEMOSYP((cAliasQry)->TRX_MMSYP)
			ElseIf lTRX_OBS
				dbSelectArea("TRX")
				dbSetOrder(01)
				If dbSeek((cAliasQry)->TRX_FILIAL+(cAliasQry)->TRX_MULTA) .And. !Empty(TRX->TRX_OBS)
					cTRX_DESOBS := TRX->TRX_OBS
				EndIf
			EndIf
			If !Empty(cTRX_DESOBS)
				NgSomaLi(58)
				@Li,000 Psay STR0013 //"Observação: "
				nX := MlCount(cTRX_DESOBS,209)
				For nI := 1 To nX
					If !Empty(MemoLine(cTRX_DESOBS,209,nI))
						If nI != 1
							NgSomaLi(58)
						EndIf
						@Li,012 Psay MemoLine(cTRX_DESOBS,209,nI)
					EndIf
				Next
			EndIf

			//Verifica campo memo 2
			cTRX_OBCOND := ''
			If lTRX_MMCOND .And. !Empty((cAliasQry)->TRX_MMCOND)
				cTRX_OBCOND := NGMEMOSYP((cAliasQry)->TRX_MMCOND)
			ElseIf lTRX_OBCOND
				dbSelectArea("TRX")
				dbSetOrder(01)
				If dbSeek((cAliasQry)->TRX_FILIAL+(cAliasQry)->TRX_MULTA) .And. !Empty(TRX->TRX_OBCOND)
					cTRX_OBCOND := TRX->TRX_OBCOND
				EndIf
			EndIf
			If !Empty(cTRX_OBCOND)
				NgSomaLi(58)
				@Li,000 Psay STR0014 //"Justificativa: "
				nX := MlCount(cTRX_OBCOND,206)
				For nI := 1 To nX
					If !Empty(MemoLine(cTRX_OBCOND,206,nI))
						If nI != 1
							NgSomaLi(58)
						EndIf
						@Li,015 Psay MemoLine(cTRX_OBCOND,206,nI)
					EndIf
				Next
			EndIf

			nTotPagar += (cAliasQry)->TRX_VALOR - (cAliasQry)->TRX_DESCON
			dbSelectArea(cAliasQry)
			dbSkip()
		End
		NgSomaLi(58)
		NgSomaLi(58)
		@Li,120 Psay STR0015 //"TOTAL A PAGAR: "
		@Li,135 Psay PADL(Transform(nTotPagar,"@E 999,999,999,999.99"),18)
	EndIf

	Roda(nCntImpr,cRodaTxt,Tamanho)

	(cAliasQry)->(dbCloseArea())
	//---------------------------------------------------------------------
	// Devolve a condicao original do arquivo principal
	//---------------------------------------------------------------------
	RetIndex("TRX")
	Set Filter To
	Set device to Screen
	If aReturn[5] = 1
		Set Printer To
		dbCommitAll()
		OurSpool(wnrel)
	EndIf
	MS_FLUSH()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNR985DT
Validação de datas

@author Marcos Wagner Junior
@since 16/07/2010
/*/
//---------------------------------------------------------------------
Function MNR985DT()

	If !Empty(MV_PAR06) .And. !Empty(MV_PAR05) .And. MV_PAR06 < MV_PAR05
		MsgStop(STR0016,STR0012) //"'De Data Vencimento' deverá ser menor/igual à 'Até Data Vencimento'!"###"Atenção"
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNR985BEM
Validação do bem

@author Marcos Wagner Junior
@since 19/07/2010
/*/
//---------------------------------------------------------------------
Function MNR985BEM(_nPar)

	If _nPar == 1
		If Empty(Mv_Par01)
			Return .T.
		Else
			If !ExistCpo('ST9',Mv_Par01)
				Return .F.
			EndIf
		EndIf
	Else
		If !Atecodigo('ST9',Mv_Par01,Mv_Par02,16)
			Return .F.
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT985PLA
Valida De/Ate Placa

@author Marcos Wagner Junior
@since 16/07/2010
/*/
//---------------------------------------------------------------------
Function MNT985PLA(nOpc,cParDe,cParAte,cTabela)

	Local lRet := .T.

	If Empty(cParDe) .And. cParAte = 'ZZZZZZZZ'
		lRet := .T.
	Else
		If nOpc == 1
			If Empty(cParDe)
				lRet := .T.
			Else
				If !Empty(cParDe)
					dbSelectArea("ST9")
					dbSetOrder(14)
					If !dbSeek(cParDe+'A')
						MsgStop(STR0019,STR0012) //"Placa digitada é inválida!"###"Atenção"
						lRet := .F.
					EndIf
				EndIf
			EndIf
		ElseIf nOpc == 2
			If cParAte == 'ZZZZZZZZ'
				lRet := .T.
			Else
				If !Empty(cParAte)
					dbSelectArea("ST9")
					dbSetOrder(14)
					If !dbSeek(cParAte+'A')
						MsgStop(STR0019,STR0012) //"Placa digitada é inválida!"###"Atenção"
						lRet := .F.
					EndIf
				ElseIf !Empty(cParDe)
					MsgStop(STR0017,STR0012) //"'Ate Placa' deverá ser digitado!"###"Atenção"
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	If lRet
		If (Empty(MV_PAR03) .And. !Empty(MV_PAR04)) .Or. (!Empty(MV_PAR03) .And. !Empty(MV_PAR04))
			If MV_PAR03 > MV_PAR04
				MsgStop(STR0017,STR0012) //"'De Placa' deverá ser menor/igual a 'Ate Placa'!"###"Atenção"
				Return .F.
			EndIf
		EndIf
	EndIf

Return lRet
