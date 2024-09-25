#INCLUDE "MNTR765.ch"
#INCLUDE "PROTHEUS.CH"

//------------------------------------------------------------------------------     
/*/{Protheus.doc} MNTR765
Relatorio de Sinistralidade  
@author Ricardo Dal Ponte
@since 09/03/07
@version undefined
@type function
/*/
//------------------------------------------------------------------------------
Function MNTR765()  

	Private nGR_TOTROB := 0
	Private nGR_TOTACI := 0
	Private nGR_TOTPRJ := 0, nPETOTPRJa := 0

	Private NOMEPROG := "MNTR765"
	Private TAMANHO  := "M"
	Private aRETURN  := {STR0001,1,STR0002,1,2,1,"",1} //"Zebrado"###"Administracao"
	Private TITULO   := STR0003 //"Relatorio de Sinistralidade"
	Private nTIPO    := 0
	Private nLASTKEY := 0
	Private CABEC1,CABEC2 
	Private aVETINR := {}    
	Private cPERG := "MNT765"   
	Private aPerg :={}
	Private lGera := .t.

	Private cR765VALID1 := ""
	Private cR765VALID2 := ""
	Private cR765F3     := ""

	SetKey( VK_F9, { | | NGVersao( "MNTR765" , 1 ) } )

	WNREL      := "MNTR765"
	LIMITE     := 132
	cDESC1     := STR0004 //"O relatório apresentará a despesa total com sinistralidade. "
	cDESC2     := STR0005 //"(Acidentes e Roubos) "
	cDESC3     := ""
	cSTRING    := "TRH"       

	Pergunte(cPERG,.F.)
	//----------------------------------------------------------------
	//| Envia controle para a funcao SETPRINT                        |
	//---------------------------------------------------------------- 
	WNREL:=SetPrint(cSTRING,WNREL,cPERG,TITULO,cDESC1,cDESC2,cDESC3,.F.,"")
	If nLASTKEY = 27
		Set Filter To
		DbSelectArea("TRH")  
		Return
	EndIf     
	SetDefault(aReturn,cSTRING)
	RptStatus({|lEND| MNTR765IMP(@lEND,WNREL,TITULO,TAMANHO)},STR0012,STR0013) //"Aguarde..."###"Processando Registros..."
	Dbselectarea("TRH")  

Return .T.
//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTR765IMP
Chamada do Relatório 
@author Ricardo Dal Ponte
@since 08/03/07
@version undefined
@param lEND, logical
@param WNREL
@param TITULO
@param TAMANHO
@type function
/*/
//------------------------------------------------------------------------------
Function MNTR765IMP(lEND,WNREL,TITULO,TAMANHO) 
	Local	nPETOTPREa := 0
	Local	nPETOTMNTa := 0
	Local	nPETOTFILa := 0
	Local	nGETOTPRE  := 0
	Local	nGETOTMNT  := 0
	Local	nGETOTFIL  := 0
	Local	nGR_TOTPRE := 0
	Local	nGR_TOTMNT := 0
	Local	nGR_TOTFIL := 0
	Local oTempTable		      //Objeto Tabela Temporaria
	Local nI
	
	Private cRODATXT 	:= ""
	Private nCNTIMPR 	:= 0     
	Private li 			:= 80 ,m_pag := 1    
	Private cNomeOri
	Private aVetor	 	:= {}
	Private aTotGeral 	:= {}
	Private nAno, nMes 
	Private nTotCarga 	:= 0, nTotManut := 0 
	Private nTotal 		:= 0
	Private cTRB		:= GetNextAlias()
	
	aDBF :={{"CODFIL", "C", 02,0},; //codigo filial
			{"DESFIL", "C", 25,0},; //descricao filial
			{"TOTROB", "N", 15,2},; //PREJUIZO ROUBO
			{"TOTACI", "N", 15,2},; //PREJUIZO ACIDENTEAO
			{"TOTPRJ", "N", 15,2}}  //PREJUIZO

	//Intancia classe FWTemporaryTable
	oTempTable  := FWTemporaryTable():New( cTRB, aDBF )
	//Cria indices
	oTempTable:AddIndex( "Ind01" , {"CODFIL"} )
	//Cria a tabela temporaria
	oTempTable:Create()

	Processa({|lEND| MNTR765TMP()},STR0015) //"Processando Arquivo..."

	If !lGera
		oTempTable:Delete()//Deleta arquivo temporario
		Return .F.
	Endif        

	nTIPO  := IIf(aReturn[4]==1,15,18)                                                                                                                                                                                               

	CABEC1 := ""
	CABEC2 := ""   

	lPri := .T.  
	lPriAcum := .T.
	//Carrega Totais
	DbSelectArea(cTRB)
	DbGoTop()  

	SetRegua(RecCount())

	While !Eof()
		IncRegua()

		nGR_TOTROB += (cTRB)->TOTROB
		nGR_TOTACI += (cTRB)->TOTACI
		nGR_TOTPRJ += (cTRB)->TOTPRJ

		dbSelectArea(cTRB)
		dbSkip()
	End

	DbSelectArea(cTRB)
	DbGoTop()  
	SetRegua(RecCount())

	While !Eof()
		IncRegua()

		If lPri = .T.  
			NgSomaLi(58)
			@ Li,000 	 Psay STR0016 //"Filial"

			@ Li,033 	 Psay "    "+STR0017 //"PREJ.ROUBOS"
			@ Li,053 	 Psay " "+STR0018 //"PREJ.ACIDENTES"
			@ Li,071 	 Psay "      "+STR0019 //"PREJUIZOS"
			@ Li,089 	 Psay "%"+STR0019 //"PREJUIZOS"
			@ Li,102 	 Psay " "+STR0020 //"%AC"

			NgSomaLi(58)
			@ Li,000 	 Psay Replicate("-",132)
			NgSomaLi(58) 

			lPri := .F.  
		EndIf

		@ Li,000 	 Psay (cTRB)->CODFIL +" - " + Substr((cTRB)->DESFIL, 1, 20)

		cPETOTROB := Round((((cTRB)->TOTROB /nGR_TOTROB) *100), 0)
		cPETOTACI := Round((((cTRB)->TOTACI /nGR_TOTACI) *100), 0)
		cPETOTPRJ := Round((((cTRB)->TOTPRJ /nGR_TOTPRJ) *100), 0)

		nPETOTPRJa += cPETOTPRJ

		@ Li,030 	 Psay (cTRB)->TOTROB Picture "@E 999,999,999,999.99"
		@ Li,050 	 Psay (cTRB)->TOTACI Picture "@E 999,999,999,999.99"
		@ Li,068 	 Psay (cTRB)->TOTPRJ Picture "@E 999,999,999,999.99"
		@ Li,089 	 Psay Transform(Round((((cTRB)->TOTPRJ/nGR_TOTPRJ) *100), 0),"@E 999999999")+"%"

		If lPriAcum = .T.
			@ Li,102 	 Psay Transform(cPETOTPRJ,"@E 999")+"%"
		Else
			@ Li,102 	 Psay Transform(nPETOTPRJa,"@E 999")+"%"
		EndIf

		lPriAcum := .F.    

		NgSomaLi(58) 

		dbSelectArea(cTRB)			   
		dbSkip()
	End

	If lPri = .F.  
		NgSomaLi(58)
		@ Li,000 	 Psay Replicate("-",132)
		NgSomaLi(58)
		@ Li,000 	 Psay STR0021 //"TOTAL"
		@ Li,030 	 Psay nGR_TOTROB Picture "@E 999,999,999,999.99"
		@ Li,050 	 Psay nGR_TOTACI Picture "@E 999,999,999,999.99"
		@ Li,068 	 Psay nGR_TOTPRJ Picture "@E 999,999,999,999.99"
		@ Li,089 	 Psay Transform(Round(((nGR_TOTPRJ /nGR_TOTPRJ) *100), 0),"@E 999999999")+"%"
		@ Li,102 	 Psay Transform(Round(((nGR_TOTPRJ /nGR_TOTPRJ) *100), 0),"@E 999")+"%"
	EndIF

	oTempTable:Delete()//Deleta arquivo temporario
	
	RODA(nCNTIMPR,cRODATXT,TAMANHO)       

	//----------------------------------------------------------------
	//| Devolve a condicao original do arquivo principal             |
	//----------------------------------------------------------------
	RetIndex('TRH')
	Set Filter To
	Set Device To Screen
	If aReturn[5] == 1
		Set Printer To
		dbCommitAll()
		OurSpool(WNREL)
	EndIf
	MS_FLUSH()

Return Nil  
//------------------------------------------------------------------------------
/*/{Protheus.doc} MNR765FL
Validação do parametro Filial 
@author Ricardo Dal Ponte
@since 09/03/07
@version undefined
@param nOpc, numeric
@type function
/*/
//------------------------------------------------------------------------------
Function MNR765FL(nOpc)

	If Empty(mv_par04) .And. (mv_par05 == 'ZZ')
		Return .T.
	Else
		If nOpc == 1
			lRet := IIf(Empty(Mv_Par04),.t.,ExistCpo('SM0',SM0->M0_CODIGO+Mv_Par04))
			If !lRet
				Return .F.
			EndIf
		EndIf

		If nOpc == 2
			If MV_PAR05 = 'ZZ'
				Return .T.
			Endif
			lRet := IIF(ATECODIGO('SM0',SM0->M0_CODIGO+Mv_Par04,SM0->M0_CODIGO+Mv_Par05,07),.T.,.F.)
			If !lRet
				Return .F.
			EndIf
		EndIf
	EndIf

Return .T.
//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTR765VAL
Validacao dos Parametros
@author Ricardo Dal Ponte 
@since 08/03/07
@version undefined
@type function
/*/
//------------------------------------------------------------------------------
Function MNTR765VAL() 

	If !Empty(MV_PAR03) .AND. !Empty(MV_PAR04)
		If MV_PAR03 > MV_PAR04
			MsgStop(STR0022,STR0023) //"De Grupo de Filial não pode ser maior que Até Grupo de Filial!"###"Atenção"
			Return .F.	
		Endif
	Endif
Return .T.
//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTR765FIL
Validacao dos Parametros	
@author Ricardo Dal Ponte
@since 09/03/07
@version undefined
@type function
/*/
//------------------------------------------------------------------------------
Function MNTR765FIL() 

	If !Empty(MV_PAR03) .AND. !Empty(MV_PAR04)
		If MV_PAR03 > MV_PAR04
			MsgStop(STR0024,STR0023) //"De Filial não pode ser maior que Até Filial!"###"Atenção"
			Return .F.	
		Endif
	Endif
Return .T.
//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTR765TMP
Geracao do arquivo temporario 
@author Ricardo Dal Ponte
@since 08/03/07
@version undefined
@type function
/*/
//------------------------------------------------------------------------------
Function MNTR765TMP()
	cAliasQry := GetNextAlias()

	cQuery := " SELECT TRH.TRH_EVENTO, TRW.TRW_HUB, TRW.TRW_DESHUB, TRH.TRH_FILIAL, TRH.TRH_DTACID, TRH.TRH_NUMSIN, TRH.TRH_RECVEL, TRH_CODBEM"
	cQuery += " FROM " + RetSqlName("TRH")+" TRH, " + RetSqlName("TSL")+" TSL, " + RetSqlName("TRW")+" TRW "
	cQuery += " WHERE "
	cQuery += "       (TRH.TRH_DTACID  >= '"+AllTrim(Str(MV_PAR01))+"0101'"
	cQuery += " AND    TRH.TRH_DTACID  <= '"+AllTrim(Str(MV_PAR01))+"1231')"
	cQuery += " AND   TSL.TSL_HUB     >= '"+MV_PAR02+"'"
	cQuery += " AND   TSL.TSL_HUB     <= '"+MV_PAR03+"'"
	cQuery += " AND   TSL.TSL_HUB     = TRW.TRW_HUB  "
	cQuery += " AND   TRH.TRH_FILIAL >= '"+MV_PAR04+"'"
	cQuery += " AND   TRH.TRH_FILIAL <= '"+MV_PAR05+"'"
	cQuery += " AND   (TRH.TRH_EVENTO = '1'"
	cQuery += " OR     TRH.TRH_EVENTO = '2')"
	If NGSX2MODO("TRH") == NGSX2MODO("TSL")
		cQuery += " AND   TRH.TRH_FILIAL = TSL.TSL_FILIAL "
	Else
		cQuery += " AND TRH.TRH_FILIAL = '"+xFilial("TRH")+"' AND TSL.TSL_FILIAL = '"+xFilial("TSL")+"' "
	EndIf
	If NGSX2MODO("TRH") == "E"
		cQuery += " AND   TRH.TRH_FILIAL = TSL.TSL_FILMS "
	EndIf
	If NGSX2MODO("TSL") == NGSX2MODO("TRW")
		cQuery += " AND   TSL.TSL_FILIAL = TRW.TRW_FILIAL "
	Else
		cQuery += " AND TSL.TSL_FILIAL = '"+xFilial("TSL")+"' AND TRW.TRW_FILIAL = '"+xFilial("TRW")+"' "
	EndIf
	cQuery += " AND   TRH.D_E_L_E_T_ <> '*' "
	cQuery += " AND   TSL.D_E_L_E_T_ <> '*' "
	cQuery += " AND   TRW.D_E_L_E_T_ <> '*' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)  

	dbSelectArea(cAliasQry)			   
	dbGoTop()

	If Eof()
		MsgInfo(STR0025,STR0023) //"Não existem dados para montar o relatório!"###"ATENÇÃO"
		(cAliasQry)->(dbCloseArea())
		lGera := .f.
		Return   
	Endif

	SetRegua(LastRec())

	While !Eof()
		IncRegua()

		dbSelectArea(cTRB)
		dbSetOrder(1)

		If !dbSeek((cAliasQry)->TRH_FILIAL)
			RecLock((cTRB), .T.)
			(cTRB)->CODFIL := (cAliasQry)->TRH_FILIAL
			(cTRB)->DESFIL := ""

			dbSelectArea("SM0")
			dbSetorder(1)

			If dbSeek(cEmpAnt+(cAliasQry)->TRH_FILIAL)
				(cTRB)->DESFIL := SM0->M0_FILIAL
			EndIf
		Else
			RecLock((cTRB), .F.)
		EndiF

		nTOTACI := 0
		nTOTROB := 0

		If (cAliasQry)->TRH_EVENTO = "2"
			nTOTROB :=  R765ROB((cAliasQry)->TRH_NUMSIN,(cAliasQry)->TRH_FILIAL,(cAliasQry)->TRH_CODBEM,(cAliasQry)->TRH_RECVEL) //PREJUIZO ROUBO
		ElseIf (cAliasQry)->TRH_EVENTO = "1"
			nTOTACI := R765ACI((cAliasQry)->TRH_NUMSIN,(cAliasQry)->TRH_FILIAL) //PREJUIZO ACIDENTEAO
		EndIf

		(cTRB)->TOTACI +=  nTOTACI
		(cTRB)->TOTROB +=  nTOTROB
		(cTRB)->TOTPRJ +=  nTOTACI + nTOTROB   //TOTAL PREJUIZOS

		MsUnLock(cTRB)

		dbSelectArea(cAliasQry)			   
		dbSkip()
	End
	(cAliasQry)->(dbCloseArea())
Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} R765ROB
Carrega os valores de prejuizos em roubos 
@author Ricardo Dal Ponte
@since 09/03/07
@version undefined
@param cCodSin, characters
@param cCodFilial, characters
@param cCodBem, characters
@param cRecVel, characters
@type function
/*/
//------------------------------------------------------------------------------
Function R765ROB(cCodSin,cCodFilial,cCodBem,cRecVel)
	Local cAliasFIL1 := GetNextAlias()
	Local cAliasFIL3 := GetNextAlias()
	Local cQueryFIL
	Local nSoma := 0

	//VEICULOS
	cQueryFIL := " SELECT ST9.T9_VALCPA"
	cQueryFIL += " FROM " + RetSqlName("ST9")+" ST9 "
	cQueryFIL += " WHERE "
	If NGSX2MODO("TRH") == NGSX2MODO("ST9")
		cQueryFIL += " ST9.T9_FILIAL = '"+ cCodFilial +"'"
	Else
		cQueryFIL += " AND ST9.T9_FILIAL = '"+xFilial("ST9")+"' "
	EndIf
	cQueryFIL += " AND   ST9.T9_CODBEM = '"+cCodBem+"'"
	cQueryFIL += " AND   ST9.D_E_L_E_T_ <> '*' "
	cQueryFIL := ChangeQuery(cQueryFIL)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryFIL),cAliasFIL1, .F., .T.)  

	dbSelectArea(cAliasFIL1)			   
	dbGoTop()

	nSOMAVALCP := (cAliasFIL1)->T9_VALCPA
	(cAliasFIL1)->(dbCloseArea())

	//CARGAS
	cQueryFIL := " SELECT SUM(TRK.TRK_VALAVA) AS TOTVALCAR, SUM(TRK.TRK_VALREC) AS TOTVALREC "
	cQueryFIL += " FROM " + RetSqlName("TRK")+" TRK "
	cQueryFIL += " WHERE "
	cQueryFIL += "       TRK.TRK_NUMSIN = '"+cCodSin+"'"
	cQueryFIL += " AND   TRK.TRK_FILIAL = '"+cCodFilial+"'"
	cQueryFIL += " AND   TRK.D_E_L_E_T_ <> '*' "
	cQueryFIL := ChangeQuery(cQueryFIL)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryFIL),cAliasFIL3, .F., .T.)  

	dbSelectArea(cAliasFIL3)			   
	dbGoTop()

	nSoma := (cAliasFIL3)->TOTVALCAR - (cAliasFIL3)->TOTVALREC
	If cRecVel = "2"
		nSoma += nSOMAVALCP
	Endif

	(cAliasFIL3)->(dbCloseArea())

Return nSoma 
//------------------------------------------------------------------------------
/*/{Protheus.doc} R765ACI
Carrega os valores de prejuizos em acidentes  
@author Ricardo Dal Ponte
@since 12/03/07
@version undefined
@param cCodSin, characters
@param cCodFilial, characters
@type function
/*/
//------------------------------------------------------------------------------
Function R765ACI(cCodSin,cCodFilial)
	Local cAliasFIL1 := GetNextAlias()
	Local cAliasFIL2 := GetNextAlias()
	Local cAliasFIL3 := GetNextAlias()
	Local cAliasFIL4 := GetNextAlias()
	Local cAliasFIL5 := GetNextAlias()
	Local cAliasFIL7 := GetNextAlias()
	Local cAliasFIL8 := GetNextAlias()
	Local cQueryFIL
	Local nSoma := 0
	Local lIndSTJ := If(NgVerify("STL"),.t.,.f.)
	Local nS_VIT     := 0
	Local nS_VCAR    := 0
	Local nS_VREC    := 0
	Local nS_VTERCE  := 0
	Local nS_VIMOV   := 0
	Local nS_VANI    := 0
	Local nS_VGUI    := 0
	Local nS_VMANUTE := 0
	Local nS_VRES    := 0

	//PREJUIZOS VITIMAS
	cQueryFIL := " SELECT SUM(TRM.TRM_VALVIT) AS TOTVALVIT "
	cQueryFIL += " FROM " + RetSqlName("TRH")+" TRH, "+ RetSqlName("TRM")+" TRM "
	cQueryFIL += " WHERE "
	cQueryFIL += "       TRM.TRM_NUMSIN = '"+cCodSin+"'"
	cQueryFIL += " AND   TRM.TRM_FILIAL = '"+cCodFilial+"'"
	cQueryFIL += " AND   TRM.TRM_FILIAL = TRH.TRH_FILIAL "
	cQueryFIL += " AND   TRM.TRM_NUMSIN = TRH.TRH_NUMSIN "
	cQueryFIL += " AND   TRH.D_E_L_E_T_ <> '*' "
	cQueryFIL += " AND   TRM.D_E_L_E_T_ <> '*' "
	cQueryFIL := ChangeQuery(cQueryFIL)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryFIL),cAliasFIL1, .F., .T.)  

	dbSelectArea(cAliasFIL1)			   
	dbGoTop()

	nS_VIT := (cAliasFIL1)->TOTVALVIT
	(cAliasFIL1)->(dbCloseArea())

	//PREJUIZOS CARGAS
	cQueryFIL := " SELECT SUM(TRK.TRK_VALAVA) AS TOTVALCAR, SUM(TRK.TRK_VALREC) AS TOTVALREC "
	cQueryFIL += " FROM " + RetSqlName("TRH")+" TRH, "+ RetSqlName("TRK")+" TRK "
	cQueryFIL += " WHERE "
	cQueryFIL += "       TRK.TRK_NUMSIN = '"+cCodSin+"'"
	cQueryFIL += " AND   TRK.TRK_FILIAL = '"+cCodFilial+"'"
	cQueryFIL += " AND   TRK.TRK_FILIAL = TRH.TRH_FILIAL "
	cQueryFIL += " AND   TRK.TRK_NUMSIN = TRH.TRH_NUMSIN "
	cQueryFIL += " AND   TRH.D_E_L_E_T_ <> '*' "
	cQueryFIL += " AND   TRK.D_E_L_E_T_ <> '*' "
	cQueryFIL := ChangeQuery(cQueryFIL)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryFIL),cAliasFIL2, .F., .T.)  

	dbSelectArea(cAliasFIL2)
	dbGoTop()

	nS_VCAR := (cAliasFIL2)->TOTVALCAR
	nS_VREC := (cAliasFIL2)->TOTVALREC
	(cAliasFIL2)->(dbCloseArea())

	//PREJUIZOS VEICULOS DE TERCEIROS
	cQueryFIL := " SELECT SUM(TRO.TRO_VALPRE) AS TOTVALPRE "
	cQueryFIL += " FROM " + RetSqlName("TRH")+" TRH, "+ RetSqlName("TRO")+" TRO "
	cQueryFIL += " WHERE "
	cQueryFIL += "       TRO.TRO_NUMSIN = '"+cCodSin+"'"
	cQueryFIL += " AND   TRO.TRO_FILIAL = '"+cCodFilial+"'"
	cQueryFIL += " AND   TRO.TRO_FILIAL = TRH.TRH_FILIAL "
	cQueryFIL += " AND   TRO.TRO_NUMSIN = TRH.TRH_NUMSIN "
	cQueryFIL += " AND   TRH.D_E_L_E_T_ <> '*' "
	cQueryFIL += " AND   TRO.D_E_L_E_T_ <> '*' "
	cQueryFIL := ChangeQuery(cQueryFIL)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryFIL),cAliasFIL3, .F., .T.)  

	dbSelectArea(cAliasFIL3)			   
	dbGoTop()

	nS_VTERCE := (cAliasFIL3)->TOTVALPRE
	(cAliasFIL3)->(dbCloseArea())

	//IMOVEIS DE TERCEIROS
	cQueryFIL := " SELECT SUM(TRL.TRL_VALPRE) AS TOTVALPRE "
	cQueryFIL += " FROM " + RetSqlName("TRH")+" TRH, "+ RetSqlName("TRL")+" TRL "
	cQueryFIL += " WHERE "
	cQueryFIL += "       TRL.TRL_NUMSIN = '"+cCodSin+"'"
	cQueryFIL += " AND   TRL.TRL_FILIAL = '"+cCodFilial+"'"
	cQueryFIL += " AND   TRL.TRL_FILIAL = TRH.TRH_FILIAL "
	cQueryFIL += " AND   TRL.TRL_NUMSIN = TRH.TRH_NUMSIN "
	cQueryFIL += " AND   TRH.D_E_L_E_T_ <> '*' "
	cQueryFIL += " AND   TRL.D_E_L_E_T_ <> '*' "
	cQueryFIL := ChangeQuery(cQueryFIL)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryFIL),cAliasFIL4, .F., .T.)  

	dbSelectArea(cAliasFIL4)			   
	dbGoTop()

	nS_VIMOV := (cAliasFIL4)->TOTVALPRE
	(cAliasFIL4)->(dbCloseArea())

	//PREJUIZOS ANIMAIS POR GUINCHO
	cQueryFIL := " SELECT SUM(TRH.TRH_VALANI) AS TOTVALANI, SUM(TRH.TRH_VALGUI) AS TOTVALGUI"
	cQueryFIL += " FROM " + RetSqlName("TRH")+" TRH "
	cQueryFIL += " WHERE "
	cQueryFIL += "       TRH.TRH_NUMSIN = '"+cCodSin+"'"
	cQueryFIL += " AND   TRH.TRH_FILIAL = '"+cCodFilial+"'"
	cQueryFIL += " AND   TRH.D_E_L_E_T_ <> '*' "
	cQueryFIL := ChangeQuery(cQueryFIL)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryFIL),cAliasFIL5, .F., .T.)  

	dbSelectArea(cAliasFIL5)			   
	dbGoTop()

	nS_VANI := (cAliasFIL5)->TOTVALANI
	nS_VGUI := (cAliasFIL5)->TOTVALGUI
	(cAliasFIL5)->(dbCloseArea())

	//RESSARCIMENTO
	cQueryFIL := " SELECT SUM(TRV.TRV_VALRES) AS TOTVALRES "
	cQueryFIL += " FROM " + RetSqlName("TRH")+" TRH, "+ RetSqlName("TRV")+" TRV "
	cQueryFIL += " WHERE "
	cQueryFIL += "       TRV.TRV_NUMSIN = '"+cCodSin+"'"
	cQueryFIL += " AND   TRV.TRV_FILIAL = '"+cCodFilial+"'"
	cQueryFIL += " AND   TRV.TRV_FILIAL = TRH.TRH_FILIAL "
	cQueryFIL += " AND   TRV.TRV_NUMSIN = TRH.TRH_NUMSIN "
	cQueryFIL += " AND   TRH.D_E_L_E_T_ <> '*' "
	cQueryFIL += " AND   TRV.D_E_L_E_T_ <> '*' "
	cQueryFIL := ChangeQuery(cQueryFIL)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryFIL),cAliasFIL8, .F., .T.)  

	dbSelectArea(cAliasFIL8)
	dbGoTop()

	nS_VRES := (cAliasFIL8)->TOTVALRES
	(cAliasFIL8)->(dbCloseArea())

	//MANUTENCAO
	cQueryMNT := " SELECT STJ.TJ_ORDEM, STL.TL_CUSTO,"
	If lIndSTJ
		cQueryMNT += " STL.TL_SEQRELA "
	Else
		cQueryMNT += " STL.TL_SEQUENC "
	Endif
	cQueryMNT += " FROM " + RetSqlName("TRH")+" TRH, " + RetSqlName("TRT")+" TRT, " + RetSqlName("STJ")+" STJ, "+ RetSqlName("STL")+" STL "
	cQueryMNT += " WHERE "
	cQueryMNT += "       TRT.TRT_NUMSIN = '"+cCodSin+"'"
	cQueryMNT += " AND   TRT.TRT_FILIAL = '"+cCodFilial+"'"
	If NGSX2MODO("TRH") == NGSX2MODO("TRT")
		cQueryMNT += " AND   TRH.TRH_FILIAL  = TRT.TRT_FILIAL "
	Else
		cQueryMNT += " AND TRH.TRH_FILIAL = '"+xFilial("TRH")+"' AND TRT.TRT_FILIAL = '"+xFilial("TRT")+"' "
	EndIf
	cQueryMNT += " AND   TRT.TRT_NUMSIN = TRH.TRH_NUMSIN "
	If NGSX2MODO("STJ") == NGSX2MODO("TRT")
		cQueryMNT += " AND   STJ.TJ_FILIAL  = TRT.TRT_FILIAL "
	Else
		cQueryMNT += " AND STJ.TJ_FILIAL = '"+xFilial("STJ")+"' AND TRT.TRT_FILIAL = '"+xFilial("TRT")+"' "
	EndIf
	cQueryMNT += " AND   STJ.TJ_ORDEM   = TRT.TRT_NUMOS "
	cQueryMNT += " AND   STJ.TJ_PLANO   = TRT.TRT_PLANO "
	cQueryMNT += " AND   STJ.TJ_SITUACA = 'L' "
	If NGSX2MODO("STJ") == NGSX2MODO("STL")
		cQueryMNT += " AND   STJ.TJ_FILIAL  = STL.TL_FILIAL "
	Else
		cQueryMNT += " AND STJ.TJ_FILIAL = '"+xFilial("STJ")+"' AND STL.TL_FILIAL = '"+xFilial("STL")+"' "
	EndIf
	cQueryMNT += " AND   STL.TL_ORDEM  = STJ.TJ_ORDEM "
	cQueryMNT += " AND   STL.TL_PLANO  = STJ.TJ_PLANO "
	cQueryMNT += " AND   TRH.D_E_L_E_T_ <> '*' "
	cQueryMNT += " AND   TRT.D_E_L_E_T_ <> '*' "
	cQueryMNT += " AND   STJ.D_E_L_E_T_ <> '*' "
	cQueryMNT += " AND   STL.D_E_L_E_T_ <> '*' "
	cQueryMNT := ChangeQuery(cQueryMNT)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryMNT),cAliasFIL7, .F., .T.)  

	dbSelectArea(cAliasFIL7)			   
	dbGoTop()

	nS_VMANUTE := 0

	If !Eof()
		While !Eof()	
			If lIndSTJ
				If AllTrim((cAliasFIL7)->TL_SEQRELA) <> "0"
					nS_VMANUTE += (cAliasFIL7)->TL_CUSTO
				Endif
			Else
				If (cAliasFIL7)->TL_SEQUENC <> 0
					nS_VMANUTE += (cAliasFIL7)->TL_CUSTO
				Endif
			Endif

			dbSelectArea(cAliasFIL7)			   
			dbSkip()
		End
	Endif
	(cAliasFIL7)->(dbCloseArea())

	nSoma := nS_VIT +;
	nS_VTERCE +;
	nS_VIMOV +;
	nS_VANI +;
	nS_VGUI +;
	nS_VMANUTE +;
	nS_VCAR - ;
	nS_VREC - ;
	nS_VRES

Return nSoma 

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTR765ANO
Validacao dos Parametros
@author Marcos Wagner Junior
@since 13/11/07
@version undefined
@type function
/*/
//------------------------------------------------------------------------------
Function MNTR765ANO()

	cAno := AllTrim(Str(MV_PAR01))
	If Len(cAno) != 4
		MsgStop(STR0026,STR0023) //"O Ano informado deverá conter 4 dígitos!"###"Atenção"
		Return .F.
	Endif
	If MV_PAR01 > Year(dDATABASE)
		MsgStop(STR0007+AllTrim(Str(Year(dDATABASE)))+'!',STR0023) //"Ano informado não poderá ser maior que "###"Atenção"
		Return .F.
	Endif

Return .T.