#INCLUDE "MNTP010.ch"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTP010
Monta array para Painel de Gestao Tipo 1: Tempo Medio entre Falhas(MTBF)
e Tempo Medio para Reparo (MTTR/TMPR)

@author Elisangela Costa
@since  02/03/2007
@source SIGAMDI
@return Array       = {{cText1,cValor,nColorValor,bClick}}
@return cTexto1     = Texto da Coluna
@return cValor      = Valor a ser exibido (string)
@return nColorValor = Cor do valor no formato RGB (opcional)
@return bClick      = Funcao executada no click do valor (opcional)
/*/
//-------------------------------------------------------------------
Function MNTP010()

	Local vVETP010IND := {}
	Local aArea       := GetArea()
	Local aAreaSTJ    := STJ->(GetArea())
	Local aAreaSTS    := STS->(GetArea())
	Local aAreaST9    := ST9->(GetArea())
	Local cMensagem1  := " "
	Local cMensagem2  := " "
	Local aRetPanel   := {}
	Local oTempTMP    := Nil

	Private cTRBTMP  := GetNextAlias()

	Pergunte("MNTP010",.F.)

	aDBFP010 := {{"CUSTO"   ,"C",20,0},;
				{"CENTRAB" ,"C",06,0},;
				{"FAMILIA" ,"C",06,0},;
				{"CODBEM"  ,"C",16,0},;
				{"DATAINI" ,"D",08,0},;
				{"HORAINI" ,"C",08,0},;
				{"DATAFIM" ,"D",08,0},;
				{"HORAFIM" ,"C",08,0}}

	vINDP010  := {{'CODBEM','DATAINI'}}
	oTempTMP  := NGFwTmpTbl(cTRBTMP,aDBFP010,vINDP010)

	Processa({|lEND| MNTP10STJ()},STR0011) //"Processando Arquivo...Normal"
	Processa({|lEND| MNTP10STS()},STR0012) //"Processando Arquivo...Histórico"

	vVETP010IND := MNTP10IND() //Retorna o calculo do indicador MTBF e MTTR/TMPR

	// Monta mensagens apresentadas ao clicar nas medias
	cMensagem1 := STR0013 + chr(13)+chr(10) //"Calculo (MTBF-Tempo Médio entre Falhas)"
	cMensagem1 += chr(13) + chr(10)
	cMensagem1 += STR0014+Alltrim(Str(vVETP010IND[3]))+ chr(13)+chr(10) //"Total em dias entre falhas: "
	cMensagem1 += STR0015+Alltrim(Str(vVETP010IND[4]))+ chr(13)+chr(10) //"Total de reformas: "
	cMensagem1 += STR0016+ Alltrim(Transform(vVETP010IND[1],"@E 99999.99")) + chr(13)+chr(10) //"MTBF: "
	cMensagem1 += STR0017 //"Formula: Total em dias entre falhas / Total de reformas

	cMensagem2 := STR0019 + chr(13)+chr(10) //"Calculo (MTTR/TMPR-Tempo Médio para Reparo)"
	cMensagem2 += chr(13) + chr(10)
	cMensagem2 += STR0020 + NTOH(vVETP010IND[5])+ chr(13)+chr(10) //"Total de horas p/ reparo: "
	cMensagem2 += STR0015 + Alltrim(Str(vVETP010IND[4]))+ chr(13)+chr(10) //"Total de reformas: "
	cMensagem2 += STR0023 + vVETP010IND[2]+ chr(13)+chr(10) //"MTTR/TMPR: "
	cMensagem2 += STR0021 //"Formula: Total de horas p/ reparo / Total de reformas

	aAdd(aRetPanel,{STR0022, Transform(vVETP010IND[1],"@E 99999.99"),CLR_BLUE,{ || MsgInfo(cMensagem1)}} ) //"MTBF"
	aAdd(aRetPanel,{STR0018, vVETP010IND[2],CLR_BLUE,{ || MsgInfo(cMensagem2)}}) //"MTTR/TMPR"

	//Deleta o arquivo temporario fisicamente
	oTempTMP:Delete()

	RestArea(aAreaSTJ)
	RestArea(aAreaSTS)
	RestArea(aAreaST9)
	RestArea(aArea)

Return aRetPanel

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTP10STJ
Processa as o.s. normais

@author Elisangela Costa
@since  02/03/2007
@source MNTP010
/*/
//-------------------------------------------------------------------
Function MNTP10STJ()

	cCONDSTJ := 'stj->tj_situaca = "L" .And. stj->tj_termino = "S" .And. '
	cCONDSTJ := cCONDSTJ + '(stj->tj_codbem >= MV_PAR03 .And. stj->tj_codbem <= MV_PAR04)'
	cCONDSTJ := cCONDSTJ + ' .And. (stj->tj_centrab >= MV_PAR07 .And. stj->tj_centrab <= MV_PAR08)'
	cCONDSTJ := cCONDSTJ + ' .And. (stj->tj_dtorigi >= MV_PAR09 .And. stj->tj_dtorigi <= MV_PAR10)'
	cCONDSTJ := cCONDSTJ + ' .And. stj->tj_tipoos = "B"'

	cCONDST9 := 'st9->t9_codfami >= MV_PAR01 .And. st9->t9_codfami <= MV_PAR02'

	dbSelectArea("STJ")
	dbSetOrder(05)
	dbSeek(xFILIAL("STJ")+"000000"+MV_PAR05,.T.)
	ProcRegua(LastRec())
	While !Eof() .And. STJ->TJ_FILIAL == xFILIAL("STJ") .And.;
		Val(STJ->TJ_PLANO) = 0 .And. STJ->TJ_CCUSTO <= MV_PAR06

		Incproc()
		If &(cCONDSTJ)
			dbSelectArea("ST9")
			dbSetOrder(01)
			If dbSeek(xFILIAL("ST9")+STJ->TJ_CODBEM)
				If &(cCONDST9)
					MNTP010TRB(STJ->TJ_CCUSTO,STJ->TJ_CENTRAB,STJ->TJ_CODBEM,;
							   STJ->TJ_DTMRINI,STJ->TJ_HOMRINI,STJ->TJ_DTMRFIM,;
							   STJ->TJ_HOMRFIM)
				EndIf
			EndIf
		EndIf
		dbSelectArea("STJ")
		dbSkip()
	End

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTP10STS
Processa as o.s. historico

@author Elisangela Costa
@since  02/03/2007
@source MNTP010
/*/
//-------------------------------------------------------------------
Function MNTP10STS()

	cCONDSTS := 'sts->ts_situaca = "L" .And. sts->ts_termino = "S" .And. '
	cCONDSTS := cCONDSTS + '(sts->ts_codbem >= MV_PAR03 .And. sts->ts_codbem <= MV_PAR04)'
	cCONDSTS := cCONDSTS + ' .And. (sts->ts_centrab >= MV_PAR07 .And. sts->ts_centrab <= MV_PAR08)'
	cCONDSTS := cCONDSTS + ' .And. (sts->ts_dtorigi >= MV_PAR09 .And. sts->ts_dtorigi <= MV_PAR10)'
	cCONDSTS := cCONDSTS + ' .And. sts->ts_tipoos = "B"'
	cCONDST9 := 'st9->t9_codfami >= MV_PAR01 .And. st9->t9_codfami <= MV_PAR02'

	dbSelectArea("STS")
	dbSetOrder(10)
	dbSeek(xFILIAL("STS")+"000000"+MV_PAR05,.T.)
	ProcRegua(LastRec())
	While !Eof() .And. STS->TS_FILIAL == xFILIAL("STS") .And. Val(STS->TS_PLANO) = 0 .And. STS->TS_CCUSTO <= MV_PAR06

		Incproc()
		If &(cCONDSTS)
			dbSelectArea("ST9")
			dbSetOrder(1)
			If dbseek(xFILIAL("ST9")+STS->TS_CODBEM)
				If &(cCONDST9)
					MNTP010TRB(STS->TS_CCUSTO,STS->TS_CENTRAB,STS->TS_CODBEM,;
							   STS->TS_DTMRINI,STS->TS_HOMRINI,STS->TS_DTMRFIM,;
							   STS->TS_HOMRFIM)
				EndIf
			EndIf
		EndIf
		dbSelectArea("STS")
		dbSkip()
	End

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTP010TRB
Grava o arquivo temporario

@author Elisangela Costa
@since  02/03/2007
@source MNTP010
/*/
//-------------------------------------------------------------------
Function MNTP010TRB(cCCUSTO,cCENTRAB,cCODBEM,dDTMRINI,cHOMRINI,dDTMRFIM,cHOMRFIM)

	dbSelectArea(cTRBTMP)
	(cTRBTMP)->(DbAppend())
	(cTRBTMP)->CUSTO   := cCCUSTO
	(cTRBTMP)->CENTRAB := cCENTRAB
	(cTRBTMP)->FAMILIA := ST9->T9_CODFAMI
	(cTRBTMP)->CODBEM  := cCODBEM
	(cTRBTMP)->DATAINI := dDTMRINI
	(cTRBTMP)->HORAINI := cHOMRINI
	(cTRBTMP)->DATAFIM := dDTMRFIM
	(cTRBTMP)->HORAFIM := cHOMRFIM

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTP10IND
Calcula os indicadores de MTBF e MTTR

@author Elisangela Costa
@since  02/03/2007
@source MNTP010
@return aRRAY [1] - Indicador MTBF
              [2] - Indicador MTTR
/*/
//-------------------------------------------------------------------
Function MNTP10IND()

	Local lPRIMEIRO := .T.
	Local nNUMDIAS,nREFORMA,nHORAS,dDIAS,nMTBF,nMTTR

	Store 0 To nNUMDIAS,nREFORMA,nHORAS

	dbselectarea(cTRBTMP)
	dbGotop()
	While !Eof()

		cCODBEM   := (cTRBTMP)->CODBEM
		lPRIMEIRO := .T.
		While !Eof() .And. (cTRBTMP)->CODBEM = cCODBEM
			If lPRIMEIRO
				dDIAS := (cTRBTMP)->DATAINI
				lPRIMEIRO := .F.
			EndIf
			nNUMDIAS := nNUMDIAS+((cTRBTMP)->DATAINI-dDIAS)
			nREFORMA := nREFORMA+1
			nHORAS   := nHORAS+CALCHORA()
			dDIAS    := (cTRBTMP)->DATAFIM
			dbSelectArea(cTRBTMP)
			dbSkip()
		End

	End

	nMTBF := nNUMDIAS/nREFORMA
	nMTTR := NTOH(nHORAS/nREFORMA)

Return {nMTBF,nMTTR,nNUMDIAS,nREFORMA,nHORAS}

//-------------------------------------------------------------------
/*/{Protheus.doc} CALCHORA
Calcula a quantidade de horas da manutencao

@author Elisangela Costa
@since  02/03/2007
@source MNTP10IND
@return nHORAS,return_type, return_description
/*/
//-------------------------------------------------------------------
Static Function CALCHORA()

	Local nHORAS := 0

	If (cTRBTMP)->DATAFIM - (cTRBTMP)->DATAINI > 0
		nHORAS := ((cTRBTMP)->DATAFIM - (cTRBTMP)->DATAINI) * 1440
	EndIf

	nHORAS := nHORAS+(HTOM((cTRBTMP)->HORAFIM) - HTOM((cTRBTMP)->HORAINI))
	nHORAS := nHORAS/60

Return nHORAS