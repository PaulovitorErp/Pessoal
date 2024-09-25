#INCLUDE "MNTR770.ch"
#INCLUDE "PROTHEUS.CH"

//------------------------------------------------------------------------------     
/*/{Protheus.doc} MNTR770
Relatorio de pagtos para terceiros apurados pelo juridico.
@author Ricardo Dal Ponte
@since 13/03/07
@version undefined
@type function
/*/
//------------------------------------------------------------------------------
Function MNTR770()
  
	Private nGR_TTANIM := 0
	Private nGR_TTIMOV := 0
	Private nGR_TTVEIC := 0
	Private nGR_TTGUIN := 0
	Private nGR_TTVITM := 0
	Private nGR_TTTERC := 0
	Private nGR_TTGERA := 0

	Private nPETTANIM := 0
	Private nPETTIMOV := 0
	Private nPETTVEIC := 0
	Private nPETTGUIN := 0
	Private nPETTVITM := 0
	Private nPETTTERC := 0

	Private nPETTANIMa := 0
	Private nPETTIMOVa := 0
	Private nPETTVEICa := 0
	Private nPETTGUINa := 0
	Private nPETTVITMa := 0
	Private nPETTTERCa := 0

	Private NOMEPROG := "MNTR770"
	Private TAMANHO  := "G"
	Private aRETURN  := {STR0001,1,STR0002,1,2,1,"",1} //"Zebrado"###"Administracao"
	Private TITULO   := STR0003 //"Relatório de pagtos para terceiros apurados pelo jurídico."
	Private nTIPO    := 0
	Private nLASTKEY := 0
	Private CABEC1,CABEC2 
	Private aVETINR := {}    
	Private cPERG := "MNT77R"   
	Private aPerg :={}
	Private lGera := .t.

	Private cR770VALID1 := ""
	Private cR770VALID2 := ""
	Private cR770F3     := ""

	Private lOper := If(Alltrim(GetMv("MV_NGOPER")) == "S",.T.,.F.)
	Private cContab := GetMv("MV_MCONTAB")
	Private vCampoCC := {}

	If cContab == "CTB"
		vCampoCC := {"CTT","CTT_CUSTO","CTT_OPERAC","CTT_FILIAL"}
	ElseIf cContab == "CON"
		vCampoCC := {"SI3","I3_CUSTO","I3_OPERAC","I3_FILIAL"}
	EndIf

	SetKey( VK_F9, { | | NGVersao( "MNTR770" , 1 ) } )

	WNREL      := "MNTR770"
	LIMITE     := 220
	cDESC1     := STR0004 //"O relatório apresentará os valores pagos a terceiros por "
	cDESC2     := STR0005 //"acordo, totalizando por Filial ou Operação."
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
	RptStatus({|lEND| MNTR770IMP(@lEND,WNREL,TITULO,TAMANHO)},STR0011,STR0012) //"Aguarde..."###"Processando Registros..."
	Dbselectarea("TRH")  

Return .T.    
//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTR770IMP
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
Function MNTR770IMP(lEND,WNREL,TITULO,TAMANHO) 
	
	Local nI
	Local oTempTable		//Objeto Tabela Temporaria
	
	Private cRODATXT  := ""
	Private nCNTIMPR  := 0     
	Private li        := 80 
	Private m_pag     := 1    
	Private cNomeOri
	Private aVetor    := {}
	Private aTotGeral := {}
	Private nAno, nMes 
	Private nTotCarga := 0, nTotManut := 0 
	Private nTotal    := 0
	Private cTRB	  := GetNextAlias()
	
	aDBF :={{"CODSER", "C", 03,0},; //codigo 
			{"DESSER", "C", 25,0},; //descricao
			{"PJANIM", "N", 15,2},; //PREJUIZO ANIMAIS
			{"PJIMOV", "N", 15,2},; //PREJUIZO IMOVEIS
			{"PJVEIC", "N", 15,2},; //PREJUIZO VEICULOS
			{"PJGUIN", "N", 15,2},; //PREJUIZO GUINCHO
			{"PJVITM", "N", 15,2},; //PREJUIZO VITIMAS
			{"PJTERC", "N", 15,2}}  //PREJUIZO TERCEIROS

	//Instancia classe FWTemporaryTable
	oTempTable  := FWTemporaryTable():New( cTRB, aDBF )
	//Cria indices
	oTempTable:AddIndex( "Ind01" , {"CODSER"}  )
	//Cria a tabela temporaria
	oTempTable:Create()

	Processa({|lEND| MNTR770TMP()},STR0014) //"Processando Arquivo..."

	If !lGera

		oTempTable:Delete()//Deleta Arquivo temporario
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

		nGR_TTANIM += (cTRB)->PJANIM //TOTAL ANIMAIS
		nGR_TTIMOV += (cTRB)->PJIMOV //TOTAL IMOVEIS
		nGR_TTVEIC += (cTRB)->PJVEIC //TOTAL VEICULOS
		nGR_TTGUIN += (cTRB)->PJGUIN //TOTAL GUINCHO
		nGR_TTVITM += (cTRB)->PJVITM //TOTAL VITIMAS
		nGR_TTTERC += (cTRB)->PJTERC //TOTAL TERCEIROS

		nGR_TTGERA += (cTRB)->PJANIM +;
		(cTRB)->PJIMOV +;
		(cTRB)->PJVEIC +;
		(cTRB)->PJGUIN +;
		(cTRB)->PJVITM +;
		(cTRB)->PJTERC  //TOTAL GERAL

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
			@ Li,000 	 Psay IIF(lOper,STR0015,STR0030) //"FILIAL"###"OPERACAO"

			@ Li,030 	 Psay "   "+STR0016     //"PREJ.ANIMAIS"
			@ Li,046 	 Psay "  "+"%"                
			@ Li,050 	 Psay STR0017                    //"%AC"

			@ Li,055 	 Psay "   "+STR0018 //"PREJ.IMOVEIS"
			@ Li,071 	 Psay "  "+"%"
			@ Li,075 	 Psay STR0017 //"%AC"

			@ Li,080 	 Psay "  "+STR0019 //"PREJ.VEICULOS"
			@ Li,096 	 Psay "  "+"%"
			@ Li,100 	 Psay STR0017 //"%AC"

			@ Li,105 	 Psay "   "+STR0020 //"PREJ.GUINCHO"
			@ Li,121 	 Psay "  "+"%"
			@ Li,125 	 Psay STR0017 //"%AC"

			@ Li,130 	 Psay "   "+STR0021 //"PREJ.VITIMAS"
			@ Li,146 	 Psay "  "+"%"
			@ Li,150 	 Psay STR0017 //"%AC"

			@ Li,155 	 Psay " "+STR0022 //"REST.TERCEIROS"
			@ Li,171 	 Psay "  "+"%"
			@ Li,175 	 Psay STR0017 //"%AC"

			@ Li,180 	 Psay "     "+STR0023 //"PREJ.TOTAL"

			NgSomaLi(58)
			@ Li,000 	 Psay Replicate("-",220)
			NgSomaLi(58) 

			lPri := .F.  
		EndIf

		cPictuV := "@E 999999999999.99"
		cPictuP := "@E 999"

		@ Li,000 	 Psay (cTRB)->CODSER + " - " +Substr((cTRB)->DESSER, 1, 23)

		nPETTANIM := Round((((cTRB)->PJANIM/nGR_TTANIM) *100), 0)
		nPETTIMOV := Round((((cTRB)->PJIMOV/nGR_TTIMOV) *100), 0)
		nPETTVEIC := Round((((cTRB)->PJVEIC/nGR_TTVEIC) *100), 0)
		nPETTGUIN := Round((((cTRB)->PJGUIN/nGR_TTGUIN) *100), 0)
		nPETTVITM := Round((((cTRB)->PJVITM/nGR_TTVITM) *100), 0)
		nPETTTERC := Round((((cTRB)->PJTERC/nGR_TTTERC) *100), 0)

		nPETTANIMa += nPETTANIM
		nPETTIMOVa += nPETTIMOV
		nPETTVEICa += nPETTVEIC
		nPETTGUINa += nPETTGUIN
		nPETTVITMa += nPETTVITM
		nPETTTERCa += nPETTTERC

		@ Li,030 	 Psay (cTRB)->PJANIM Picture cPictuV
		@ Li,046 	 Psay Transform(Round((((cTRB)->PJANIM/nGR_TTANIM) *100), 0),cPictuP)

		If lPriAcum = .T.
			@ Li,050 	 Psay Transform(nPETTANIM ,cPictuP)
		Else
			@ Li,050 	 Psay Transform(nPETTANIMa,cPictuP)
		Endif

		@ Li,055 	 Psay (cTRB)->PJIMOV Picture cPictuV
		@ Li,071 	 Psay Transform(Round((((cTRB)->PJIMOV/nGR_TTIMOV) *100), 0),cPictuP)

		If lPriAcum = .T.
			@ Li,075 	 Psay Transform(nPETTIMOV ,cPictuP)
		Else
			@ Li,075 	 Psay Transform(nPETTIMOVa,cPictuP)
		Endif

		@ Li,080 	 Psay (cTRB)->PJVEIC Picture cPictuV
		@ Li,096 	 Psay Transform(Round((((cTRB)->PJVEIC/nGR_TTVEIC) *100), 0),cPictuP)

		If lPriAcum = .T.
			@ Li,100 	 Psay Transform(nPETTVEIC ,cPictuP)
		Else
			@ Li,100 	 Psay Transform(nPETTVEICa,cPictuP)
		Endif

		@ Li,105 	 Psay (cTRB)->PJGUIN Picture cPictuV
		@ Li,121 	 Psay Transform(Round((((cTRB)->PJGUIN/nGR_TTGUIN) *100), 0),cPictuP)

		If lPriAcum = .T.
			@ Li,125 	 Psay Transform(nPETTGUIN ,cPictuP)
		Else
			@ Li,125 	 Psay Transform(nPETTGUINa,cPictuP)
		Endif

		@ Li,130 	 Psay (cTRB)->PJVITM Picture cPictuV
		@ Li,146 	 Psay Transform(Round((((cTRB)->PJVITM/nGR_TTVITM) *100), 0),cPictuP)

		If lPriAcum = .T.
			@ Li,150 	 Psay Transform(nPETTVITM ,cPictuP)
		Else
			@ Li,150 	 Psay Transform(nPETTVITMa,cPictuP)
		Endif

		@ Li,155 	 Psay (cTRB)->PJTERC Picture cPictuV
		@ Li,171 	 Psay Transform(Round((((cTRB)->PJTERC/nGR_TTTERC) *100), 0),cPictuP)

		If lPriAcum = .T.
			@ Li,175 	 Psay Transform(nPETTTERC ,cPictuP)
		Else
			@ Li,175 	 Psay Transform(nPETTTERCa,cPictuP)
		Endif

		@ Li,180 	 Psay (cTRB)->PJANIM+;
		(cTRB)->PJIMOV+;
		(cTRB)->PJVEIC+;
		(cTRB)->PJGUIN+;
		(cTRB)->PJVITM+;
		(cTRB)->PJTERC  Picture cPictuV

		NgSomaLi(58) 

		lPriAcum := .F.

		dbSelectArea(cTRB)
		dbSkip()
	End

	If lPri = .F.  
		NgSomaLi(58)
		@ Li,000 	 Psay Replicate("-",220)
		NgSomaLi(58)

		@ Li,000 	 Psay STR0024 //"TOTAL"

		@ Li,030 	 Psay nGR_TTANIM Picture cPictuV
		@ Li,046 	 Psay Transform(Round(((nGR_TTANIM/nGR_TTANIM) *100), 0),cPictuP)
		@ Li,050 	 Psay Transform(Round(((nGR_TTANIM/nGR_TTANIM) *100), 0),cPictuP)

		@ Li,055 	 Psay nGR_TTIMOV Picture cPictuV
		@ Li,071 	 Psay Transform(Round(((nGR_TTIMOV/nGR_TTIMOV) *100), 0),cPictuP)
		@ Li,075 	 Psay Transform(Round(((nGR_TTIMOV/nGR_TTIMOV) *100), 0),cPictuP)

		@ Li,080 	 Psay nGR_TTVEIC Picture cPictuV
		@ Li,096 	 Psay Transform(Round(((nGR_TTVEIC/nGR_TTVEIC) *100), 0),cPictuP)
		@ Li,100 	 Psay Transform(Round(((nGR_TTVEIC/nGR_TTVEIC) *100), 0),cPictuP)

		@ Li,105 	 Psay nGR_TTGUIN Picture cPictuV
		@ Li,121 	 Psay Transform(Round(((nGR_TTGUIN/nGR_TTGUIN) *100), 0),cPictuP)
		@ Li,125 	 Psay Transform(Round(((nGR_TTGUIN/nGR_TTGUIN) *100), 0),cPictuP)

		@ Li,130 	 Psay nGR_TTVITM Picture cPictuV
		@ Li,146 	 Psay Transform(Round(((nGR_TTVITM/nGR_TTVITM) *100), 0),cPictuP)
		@ Li,150 	 Psay Transform(Round(((nGR_TTVITM/nGR_TTVITM) *100), 0),cPictuP)

		@ Li,155 	 Psay nGR_TTTERC Picture cPictuV
		@ Li,171 	 Psay Transform(Round(((nGR_TTTERC/nGR_TTTERC) *100), 0),cPictuP)
		@ Li,175 	 Psay Transform(Round(((nGR_TTTERC/nGR_TTTERC) *100), 0),cPictuP)

		@ Li,180 	 Psay nGR_TTANIM+;
		nGR_TTIMOV+;
		nGR_TTVEIC+;
		nGR_TTGUIN+;
		nGR_TTVITM+;
		nGR_TTTERC Picture cPictuV
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
/*/{Protheus.doc} MNR770FL
Validação do parametro Filial
@author Ricardo Dal Ponte
@since 09/03/07
@version undefined
@param nOpc, numeric
@type function
/*/
//------------------------------------------------------------------------------
Function MNR770FL(nOpc)

	If Empty(mv_par04) .And. (mv_par05 == 'ZZ')
		Return .t.
	Else
		If nOpc == 1
			lRet := IIf(Empty(Mv_Par04),.t.,ExistCpo('SM0',SM0->M0_CODIGO+Mv_Par04))
			If !lRet
				Return .f.
			EndIf
		EndIf

		If nOpc == 2
			If mv_par05 == 'ZZ'
				Return .t.
			Endif
			lRet := IIF(ATECODIGO('SM0',SM0->M0_CODIGO+Mv_Par04,SM0->M0_CODIGO+Mv_Par05,07),.T.,.F.)
			If !lRet
				Return .f.
			EndIf
		EndIf
	EndIf

Return .T. 
//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTR770VAL
Validacao dos Parametros
@author Ricardo Dal Ponte
@since 08/03/07
@version undefined
@type function
/*/
//------------------------------------------------------------------------------
Function MNTR770VAL() 

	If !Empty(MV_PAR03) .AND. !Empty(MV_PAR04)
		If MV_PAR03 > MV_PAR04
			MsgStop(STR0025,STR0026) //"De Grupo de Filial não pode ser maior que Até Grupo de Filial!"###"Atenção"
			Return .f.	
		Endif
	Endif
Return .T.
//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTR770FIL
Validacao dos Parametros	
@author Ricardo Dal Ponte
@since 09/03/07
@version undefined
@type function
/*/
//------------------------------------------------------------------------------
Function MNTR770FIL() 

	If !Empty(MV_PAR03) .AND. !Empty(MV_PAR04)
		If MV_PAR03 > MV_PAR04
			MsgStop(STR0027,STR0026) //"De Filial não pode ser maior que Até Filial!"###"Atenção"
			Return .F.	
		Endif
	Endif
Return .T.
//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTR770TMP
Geracao do arquivo temporario 
@author Ricardo Dal Ponte
@since 08/03/07
@version undefined
@type function
/*/
//------------------------------------------------------------------------------
Function MNTR770TMP()
	
	cAliasQry  := GetNextAlias()

	cQuery := " SELECT TRW.TRW_HUB, TRW.TRW_DESHUB, TRH.TRH_FILIAL, TRH.TRH_DTACID, TRH.TRH_NUMSIN, 
	cQuery += " 		 TRH.TRH_RECVEL, TRH.TRH_GUINCH, TRH.TRH_VALGUI"
	If lOper
		cQuery += ", CDC."+vCampoCC[3]
	Endif
	cQuery += " FROM " + RetSqlName("TRH")+" TRH, " + RetSqlName("TSL")+" TSL, " + RetSqlName("TRW")+" TRW, "+ RetSqlName("ST9")+" ST9, "+ RetSqlName(vCampoCC[1])+" CDC "
	cQuery += " WHERE "
	cQuery += "       (TRH.TRH_DTACID  >= '"+AllTrim(Str(MV_PAR01))+"0101'"
	cQuery += " AND    TRH.TRH_DTACID  <= '"+AllTrim(Str(MV_PAR01))+"1231')"
	cQuery += " AND   TSL.TSL_HUB     >= '"+MV_PAR02+"'"
	cQuery += " AND   TSL.TSL_HUB     <= '"+MV_PAR03+"'"
	cQuery += " AND   TRH.TRH_FILIAL = TSL.TSL_FILMS "
	cQuery += " AND   TSL.TSL_HUB     = TRW.TRW_HUB  "
	cQuery += " AND   TRH.TRH_FILIAL >= '"+MV_PAR04+"'"
	cQuery += " AND   TRH.TRH_FILIAL <= '"+MV_PAR05+"'"
	cQuery += " AND   TRH.TRH_EVENTO  = '1'"
	cQuery += " AND   ST9.T9_FILIAL = TRH.TRH_FILIAL "
	cQuery += " AND   ST9.T9_CODBEM = TRH.TRH_CODBEM "
	cQuery += " AND   ST9.T9_FILIAL = CDC."+vCampoCC[4]
	cQuery += " AND   ST9.T9_CCUSTO = CDC."+vCampoCC[2]
	cQuery += " AND   TRH.D_E_L_E_T_ <> '*' "
	cQuery += " AND   TSL.D_E_L_E_T_ <> '*' "
	cQuery += " AND   TRW.D_E_L_E_T_ <> '*' "
	cQuery += " AND   ST9.D_E_L_E_T_ <> '*' "
	cQuery += " AND   CDC.D_E_L_E_T_ <> '*' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)  

	dbSelectArea(cAliasQry)			   
	dbGoTop()

	SetRegua(LastRec())

	While !Eof()
		IncProc()

		If lOper
			dbSelectArea("TSZ")
			dbSetorder(1)

			cCODSER := &('(cAliasQry)->'+vCampoCC[3])

			If dbSeek(xFilial("TSZ")+cCODSER)
				cDESSER := TSZ->TSZ_DESSER
			Else
				dbSelectArea(cAliasQry)			   
				dbSkip()
				Loop
			EndIf
		Else
			cCODSER := (cAliasQry)->TRH_FILIAL
			dbSelectArea("SM0")
			dbSetOrder(01)
			If dbSeek(SM0->M0_CODIGO+(cAliasQry)->TRH_FILIAL)
				cDESSER := SM0->M0_FILIAL
			Else
				dbSelectArea(cAliasQry)			   
				dbSkip()
				Loop
			EndIf
		Endif

		dbSelectArea(cTRB)
		dbSetOrder(1)

		If !dbSeek(cCODSER)
			RecLock((cTRB), .T.)

			(cTRB)->CODSER := cCODSER
			(cTRB)->DESSER := cDESSER
			(cTRB)->PJANIM := 0 //PREJUIZO ANIMAIS
			(cTRB)->PJIMOV := 0 //PREJUIZO IMOVEIS
			(cTRB)->PJVEIC := 0 //PREJUIZO VEICULOS
			(cTRB)->PJGUIN := 0 //PREJUIZO GUINCHO
			(cTRB)->PJVITM := 0 //PREJUIZO VITIMAS
			(cTRB)->PJTERC := 0 //PREJUIZO TERCEIROS
		Else
			RecLock((cTRB), .F.)
		EndiF

		(cTRB)->PJANIM += R770ANIM((cAliasQry)->TRH_NUMSIN,(cAliasQry)->TRH_FILIAL) //TOTAL ANIMAIS
		(cTRB)->PJIMOV += R770IMOV((cAliasQry)->TRH_NUMSIN,(cAliasQry)->TRH_FILIAL) //TOTAL IMOVEIS
		(cTRB)->PJVEIC += R770VEIC((cAliasQry)->TRH_NUMSIN,(cAliasQry)->TRH_FILIAL) //TOTAL VEICULOS

		If (cAliasQry)->TRH_GUINCH = "1"
			(cTRB)->PJGUIN += (cAliasQry)->TRH_VALGUI
		EndIf

		(cTRB)->PJVITM += R770VITM((cAliasQry)->TRH_NUMSIN,(cAliasQry)->TRH_FILIAL) //TOTAL VITIMAS
		(cTRB)->PJTERC += R770TERC((cAliasQry)->TRH_NUMSIN,(cAliasQry)->TRH_FILIAL) //TOTAL TERCEIROS

		MsUnLock(cTRB)

		dbSelectArea(cAliasQry)			   
		dbSkip()
	End

	dbSelectArea(cTRB)
	dbGotop()
	If Eof()
		MsgInfo(STR0028,STR0026) //"Não existem dados para montar o relatório!"###"ATENÇÃO"
		(cALIASQRY)->(dbCloseArea())
		lGera := .f.
		Return
	Endif

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} R770ANIM
Carrega os valores de prejuizos animais 
@author Ricardo Dal Ponte
@since 14/03/07
@version undefined
@param cCodSin, characters
@param cTRHFilial, characters
@type function
/*/
//------------------------------------------------------------------------------
Function R770ANIM(cCodSin, cTRHFilial)
	Local cAliasFIL1 := GetNextAlias()
	Local cQueryFIL

	//PREJUIZO ANIMAIS
	cQueryFIL := " SELECT SUM(TRH.TRH_VALANI) AS TOTVALANI"
	cQueryFIL += " FROM " + RetSqlName("TRH")+" TRH "
	cQueryFIL += " WHERE "
	cQueryFIL += "       TRH.TRH_NUMSIN = '"+cCodSin+"'"
	cQueryFIL += " AND   TRH.TRH_FILIAL = '"+cTRHFilial+"'"
	cQueryFIL += " AND   TRH.D_E_L_E_T_ <> '*' "
	cQueryFIL := ChangeQuery(cQueryFIL)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryFIL),cAliasFIL1, .F., .T.)  

	dbSelectArea(cAliasFIL1)			   
	dbGoTop()

Return (cAliasFIL1)->TOTVALANI
//------------------------------------------------------------------------------
/*/{Protheus.doc} R770IMOV
Carrega os valores de prejuizos imoveis 
@author Ricardo Dal Ponte 
@since 14/03/07
@version undefined
@param cCodSin, characters
@param cTRHFilial, characters
@type function
/*/
//------------------------------------------------------------------------------
Function R770IMOV(cCodSin, cTRHFilial)
	Local cAliasFIL1 := GetNextAlias()
	Local cQueryFIL

	//PREJUIZO imoveis
	cQueryFIL := " SELECT SUM(TRL.TRL_VALPRE) AS TOTVALPRE"
	cQueryFIL += " FROM " + RetSqlName("TRL")+" TRL "
	cQueryFIL += " WHERE "
	cQueryFIL += "       TRL.TRL_NUMSIN = '"+cCodSin+"'"
	cQueryFIL += " AND   TRL.TRL_FILIAL = '"+cTRHFilial+"'"
	cQueryFIL += " AND   TRL.D_E_L_E_T_ <> '*' "
	cQueryFIL := ChangeQuery(cQueryFIL)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryFIL),cAliasFIL1, .F., .T.)  

	dbSelectArea(cAliasFIL1)			   
	dbGoTop()

Return (cAliasFIL1)->TOTVALPRE
//------------------------------------------------------------------------------
/*/{Protheus.doc} R770VEIC
Carrega os valores de prejuizos VEICULOS
@author Ricardo Dal Ponte
@since 14/03/07
@version undefined
@param cCodSin, characters
@param cTRHFilial, characters
@type function
/*/
//------------------------------------------------------------------------------
Function R770VEIC(cCodSin, cTRHFilial)
	Local cAliasFIL1 := GetNextAlias()
	Local cAliasFIL2 := GetNextAlias()
	Local cQueryFIL

	//PREJUIZO VEICULOS
	cQueryFIL := " SELECT SUM(TRO.TRO_VALPRE) AS TOTVALPRE"
	cQueryFIL += " FROM " + RetSqlName("TRO")+" TRO "
	cQueryFIL += " WHERE "
	cQueryFIL += "       TRO.TRO_NUMSIN = '"+cCodSin+"'"
	cQueryFIL += " AND   TRO.TRO_FILIAL = '"+cTRHFilial+"'"
	cQueryFIL += " AND   TRO.D_E_L_E_T_ <> '*' "
	cQueryFIL := ChangeQuery(cQueryFIL)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryFIL),cAliasFIL1, .F., .T.)  

	dbSelectArea(cAliasFIL1)			   
	dbGoTop()

	nVALPRE := (cAliasFIL1)->TOTVALPRE
	nVALRES := 0

	If nVALPRE <> 0
		//RESSARCIMENTO
		cQueryFIL := " SELECT SUM(TRV.TRV_VALRES) AS TOTVALRES"
		cQueryFIL += " FROM " + RetSqlName("TRV")+" TRV "
		cQueryFIL += " WHERE "
		cQueryFIL += "       TRV.TRV_NUMSIN = '"+cCodSin+"'"
		cQueryFIL += " AND   TRV.TRV_FILIAL = '"+cTRHFilial+"'"
		cQueryFIL += " AND   TRV.D_E_L_E_T_ <> '*' "
		cQueryFIL := ChangeQuery(cQueryFIL)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryFIL),cAliasFIL2, .F., .T.)  

		dbSelectArea(cAliasFIL2)			   
		dbGoTop()

		nVALRES := (cAliasFIL2)->TOTVALRES
	EndIf
Return nVALPRE - nVALRES
//------------------------------------------------------------------------------
/*/{Protheus.doc} R770VITM
Carrega os valores de indenizacoes vitimas
@author Ricardo Dal Ponte
@since 14/03/07
@version undefined
@param cCodSin, characters
@param cTRHFilial, characters
@type function
/*/
//------------------------------------------------------------------------------
Function R770VITM(cCodSin, cTRHFilial)
	Local cAliasFIL1 := GetNextAlias()
	Local cQueryFIL

	//indenizacoes vitimas
	cQueryFIL := " SELECT SUM(TRM.TRM_VALVIT) AS TOTVALVIT"
	cQueryFIL += " FROM " + RetSqlName("TRM")+" TRM "
	cQueryFIL += " WHERE "
	cQueryFIL += "       TRM.TRM_NUMSIN = '"+cCodSin+"'"
	cQueryFIL += " AND   TRM.TRM_FILIAL = '"+cTRHFilial+"'"
	cQueryFIL += " AND   TRM.D_E_L_E_T_ <> '*' "
	cQueryFIL := ChangeQuery(cQueryFIL)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryFIL),cAliasFIL1, .F., .T.)  

	dbSelectArea(cAliasFIL1)			   
	dbGoTop()

Return (cAliasFIL1)->TOTVALVIT
//------------------------------------------------------------------------------
/*/{Protheus.doc} R770TERC
Carrega os valores de terceiros
@author Ricardo Dal Ponte
@since 14/03/07
@version undefined
@param cCodSin, characters
@param cTRHFilial, characters
@type function
/*/
//------------------------------------------------------------------------------
Function R770TERC(cCodSin, cTRHFilial)
	Local cAliasFIL1 := GetNextAlias()
	Local cQueryFIL

	//indenizacoes vitimas
	cQueryFIL := " SELECT SUM(TRV.TRV_VALRES) AS TOTVALRES"
	cQueryFIL += " FROM " + RetSqlName("TRV")+" TRV "
	cQueryFIL += " WHERE "
	cQueryFIL += "       TRV.TRV_NUMSIN = '"+cCodSin+"'"
	cQueryFIL += " AND   TRV.TRV_FILIAL = '"+cTRHFilial+"'"
	cQueryFIL += " AND   TRV.D_E_L_E_T_ <> '*' "
	cQueryFIL := ChangeQuery(cQueryFIL)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryFIL),cAliasFIL1, .F., .T.)  

	dbSelectArea(cAliasFIL1)			   
	dbGoTop()

Return (cAliasFIL1)->TOTVALRES
//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTR770ANO
Validacao dos Parametros	
@author Marcos Wagner Junior
@since 12/11/07
@version undefined
@type function
/*/
//------------------------------------------------------------------------------
Function MNTR770ANO()

	cAno := AllTrim(Str(MV_PAR01))
	If Len(cAno) != 4
		MsgStop(STR0031,STR0026) //"O Ano informado deverá conter 4 dígitos!"###"Atenção"
		Return .F.
	Endif
	If MV_PAR01 > Year(dDATABASE)
		MsgStop(STR0029+AllTrim(Str(Year(dDATABASE)))+'!',STR0026) //"Ano informado não poderá ser maior que "###"Atenção"
		Return .F.
	Endif

Return .T.