#include "SGAR300.ch"
#include "protheus.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} SGAR300()
Relatório IBAMA de Resíduos Sólidos

@author  Elynton Fellipe Bazzo
@since   03/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Function SGAR300()

	Local aNGBEGINPRM := NGBEGINPRM()
	Local oTempTRB

	Private cCadastro := OemtoAnsi(STR0001)//"Relatório IBAMA de Resíduos Sólidos"
	Private cPerg	   := STR0002//"SGAR300"
	Private aPerg	   := {}
	Private aResiduos := {}
	//Varíaveis para verificar tamanho dos campos
	Private nTamTB6 := If((TAMSX3("TB6_CODTIP")[1]) < 1,06,(TAMSX3("TB6_CODTIP")[1]))
	Private nTamSB1 := If((TAMSX3("B1_COD")[1]) < 1,15,(TAMSX3("B1_COD")[1]))
	Private nTamSA2 := If((TAMSX3("A2_COD")[1]) < 1,6,(TAMSX3("A2_COD")[1]))
	Private nTamA2L := If((TAMSX3("A2_LOJA")[1]) < 1,2,(TAMSX3("A2_LOJA")[1]))
	Private nTamCGC := If((TAMSX3("A2_CGC")[1]) < 1,14,(TAMSX3("A2_CGC")[1]))

	If !NGCADICBASE("TF0_TIPO","D","TF0",.F.)
		If !NGINCOMPDIC("UPDSGA42","THYWO2",.F.)
			Return .F.
		EndIf
	EndIf

	Pergunte(cPerg,.F.)

	//Cria TRB
	cTRB := GetNextAlias()

	aDBF := {}
	aAdd(aDBF,{ "ANO"			, "C" ,04		, 0 })
	aAdd(aDBF,{ "TAX_CODRES", "C" ,nTamSB1	, 0 })
	aAdd(aDBF,{ "B1_DESC"	, "C" ,40		, 0 })
	aAdd(aDBF,{ "B1_UM"		, "C" ,02		, 0 })
	aAdd(aDBF,{ "TAX_CLASSE", "C" ,25		, 0 })
	aAdd(aDBF,{ "TAX_IDENTI", "C" ,20		, 0 })
	aAdd(aDBF,{ "TAX_CODCLA", "C" ,01		, 0 })
	aAdd(aDBF,{ "TAX_CODIDE", "C" ,01		, 0 })
	aAdd(aDBF,{ "TFC_IBAMA"	, "C" ,10		, 0 })
	aAdd(aDBF,{ "TFC_DESCRI", "C" ,30		, 0 })
	aAdd(aDBF,{ "TF2_EFICIE", "N" ,03		, 0 })
	aAdd(aDBF,{ "TF2_TIPMON", "C" ,100		, 0 })
	aAdd(aDBF,{ "TF0_TIPO"	, "C" ,20		, 0 })
	aAdd(aDBF,{ "TF0_CTIPO"	, "C" ,01		, 0 })
	aAdd(aDBF,{ "TF0_CODTIP", "C" ,nTamTB6	, 0 })
	aAdd(aDBF,{ "TB6_DESCRI", "C" ,30		, 0 })
	aAdd(aDBF,{ "TF0_TPRECE", "C" ,01		, 0 })
	aAdd(aDBF,{ "TF0_FORREC", "C" ,nTamSA2	, 0 })
	aAdd(aDBF,{ "TF0_LOJREC", "C" ,nTamA2L	, 0 })
	aAdd(aDBF,{ "TIPOREC"	, "C" ,01		, 0 })
	aAdd(aDBF,{ "DESCREC"	, "C" ,40		, 0 })
	aAdd(aDBF,{ "CGCREC"		, "C" ,nTamCGC	, 0 })
	aAdd(aDBF,{ "TB2_GRAUS1", "N" ,09		, 0 })
	aAdd(aDBF,{ "TB2_MINUT1", "N" ,09		, 0 })
	aAdd(aDBF,{ "TB2_SEGUN1", "N" ,06		, 2 })
	aAdd(aDBF,{ "TB2_GRAUS2", "N" ,09		, 0 })
	aAdd(aDBF,{ "TB2_MINUT2", "N" ,09		, 0 })
	aAdd(aDBF,{ "TB2_SEGUN2", "N" ,06		, 2 })
	aAdd(aDBF,{ "TB2_TPLATI", "C" ,05		, 0 })
	aAdd(aDBF,{ "TB2_TPLONG", "C" ,05		, 0 })
	aAdd(aDBF,{ "QUANTIDADE", "N" ,16		, 3 })
	aAdd(aDBF,{ "TAX_CLASSI", "C" ,20		, 0 })

	oTempTRB := FWTemporaryTable():New( cTRB, aDBF )
	oTempTRB:AddIndex( "1", {"TFC_IBAMA","TFC_DESCRI","TAX_CODRES","TF0_CTIPO","TF0_CODTIP","TF0_TPRECE","TF0_FORREC","TF0_LOJREC"} )
	oTempTRB:Create()

	SGAR300PAD()

	Dbselectarea( "TAX" )
	oTempTRB:Delete()

	NGRETURNPRM(aNGBEGINPRM)

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} SGAR300TRB()
Carrega TRB

@author  Elynton Fellipe Bazzo
@since   03/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Static Function SGAR300TRB()

	Local cDataIni := MV_PAR01+"0101"//Monta data Inicio
	Local cDataFim := MV_PAR01+"1231"//Monta data Fim
	Local cNome, cCGC, cTipo
	Local nPos

	cAliasQry := GetNextAlias()
	cQuery := "SELECT TAX.TAX_CODRES, SB1.B1_DESC, SB1.B1_UM, TAX.TAX_CLASSE, TAX.TAX_IDENTI, TF0.TF0_TIPO,   "
	cQuery += "TFC.TFC_IBAMA, TFC.TFC_DESCRI, TF0.TF0_PESOTO, TF0.TF0_DTCOMP, TF2.TF2_EFICIE, TF2.TF2_TIPMON, "
	cQuery += "TF0.TF0_CODTIP, TB6.TB6_DESCRI, TF0.TF0_TPRECE, TF0.TF0_FORREC, TF0.TF0_LOJREC, TB2.TB2_GRAUS1, "
	cQuery += "TB2.TB2_MINUT1, TB2.TB2_SEGUN1, TB2.TB2_GRAUS2, TB2.TB2_MINUT2, TB2.TB2_SEGUN2, TB2.TB2_TPLATI, TB2.TB2_TPLONG "
	cQuery += "FROM "+RetSqlName("TF0")+" TF0 "
	cQuery += "JOIN "+RetSqlName("TAX")+" TAX ON(TAX.D_E_L_E_T_ <> '*' AND TAX.TAX_CODRES = TF0.TF0_CODRES "
	cQuery += "AND TAX.TAX_FILIAL = '"+xFilial("TAX")+"') "
	cQuery += "JOIN "+RetSqlName("SB1")+" SB1 ON(SB1.D_E_L_E_T_ <> '*' AND SB1.B1_COD = TF0.TF0_CODRES "
	cQuery += "AND SB1.B1_FILIAL = '"+xFilial("SB1")+"') "
	cQuery += "LEFT JOIN "+RetSqlName("TFC")+" TFC ON (TFC.D_E_L_E_T_ <> '*' AND TFC.TFC_FILIAL = '"+xFilial("TFC")+"' AND "
	cQuery += "TFC.TFC_CODIBA = TAX.TAX_IBAMA) "
	cQuery += "LEFT JOIN "+RetSqlName("TB6")+" TB6 ON (TB6.D_E_L_E_T_ <> '*' AND TB6.TB6_FILIAL = '"+xFilial("TB6")+"' AND "
	cQuery += "TB6.TB6_TIPO = TF0.TF0_TIPO AND TB6.TB6_CODTIP = TF0.TF0_CODTIP) "
	cQuery += "LEFT JOIN "+RetSqlName("TF2")+" TF2 ON(TF2.D_E_L_E_T_ <> '*' AND "
	cQuery += "TF2.TF2_CODRES = TF0.TF0_CODRES AND TF2.TF2_ANO = '"+MV_PAR01+"' AND TF2.TF2_FILIAL = '"+xFilial("TF2")+"' ) "
	cQuery += "LEFT JOIN "+RetSqlName("TB2")+" TB2 ON(TB2.D_E_L_E_T_ <> '*' AND "
	cQuery += "TB2.TB2_TPRECE = TF0.TF0_TPRECE AND TB2.TB2_FORNEC = TF0.TF0_FORREC AND TB2.TB2_FILIAL = '"+xFilial("TF2")+"' ) "
	cQuery += "WHERE TF0.D_E_L_E_T_ <> '*' AND TF0.TF0_FILIAL = '"+xFilial("TF0")+"' AND "
	cQuery += "TF0.TF0_DTCOMP >= '"+cDataIni+"' AND TF0.TF0_DTCOMP <= '"+cDataFim+"' AND "
	cQuery += "TF0.TF0_STATUS <> '4' AND TF0_NUMMTR <> ''"
	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery( cQuery , cAliasQry )

	dbSelectArea(cAliasQry)
	dbGoTop()
	ProcRegua((cAliasQry)->(RecCount()))
	While !Eof()
		IncProc()
		dbSelectArea(cTRB)
		dbSetOrder(1)
		If !dbSeek((cAliasQry)->(TFC_IBAMA+TFC_DESCRI+TAX_CODRES+TF0_TIPO+TF0_CODTIP+TF0_TPRECE+TF0_FORREC+TF0_LOJREC))
			cNome := "-"
			cCGC  := "-"
			cTipo := "X"
			If (cAliasQry)->TF0_TPRECE == "1"
				dbSelectArea("SA2")
				dbSetOrder(1)
				If dbSeek(xFilial("SA2")+(cAliasQry)->TF0_FORREC+(cAliasQry)->TF0_LOJREC)
					cNome := AllTrim(SA2->A2_NOME)
					cCGC  := AllTrim(SA2->A2_CGC)
					cTipo := AllTrim(SA2->A2_TIPO)
				Endif
			Else
				dbSelectArea("SA1")
				dbSetOrder(1)
				If dbSeek(xFilial("SA1")+(cAliasQry)->TF0_FORREC+(cAliasQry)->TF0_LOJREC)
					cNome := AllTrim(SA1->A1_NOME)
					cCGC  := AllTrim(SA1->A1_CGC)
					cTipo := AllTrim(SA1->A1_TIPO)
				Endif
			Endif
			RecLock(cTRB,.T.)
			(cTRB)->ANO	   		:= mv_par01
			(cTRB)->TAX_CODRES	:= (cAliasQry)->TAX_CODRES
			(cTRB)->B1_DESC		:= (cAliasQry)->B1_DESC
			(cTRB)->B1_UM		   := (cAliasQry)->B1_UM
			(cTRB)->TAX_CLASSE	:= If(Empty((cAliasQry)->TAX_CLASSE),"-",NGRETSX3BOX("TAX_CLASSE",(cAliasQry)->TAX_CLASSE))
			(cTRB)->TAX_IDENTI	:= If(Empty((cAliasQry)->TAX_IDENTI),"-",NGRETSX3BOX("TAX_IDENTI",(cAliasQry)->TAX_IDENTI))
			(cTRB)->TAX_CODCLA	:= (cAliasQry)->TAX_CLASSE
			(cTRB)->TAX_CODIDE	:= (cAliasQry)->TAX_IDENTI
			(cTRB)->TFC_IBAMA    := (cAliasQry)->TFC_IBAMA
			(cTRB)->TFC_DESCRI	:= (cAliasQry)->TFC_DESCRI
			(cTRB)->TF2_EFICIE	:= (cAliasQry)->TF2_EFICIE
			(cTRB)->TF2_TIPMON	:= If(Empty((cAliasQry)->TF2_TIPMON),"-",(cAliasQry)->TF2_TIPMON)
			(cTRB)->TF0_TIPO     := If(Empty((cAliasQry)->TF0_TIPO),"-",NGRETSX3BOX("TF0_TIPO",(cAliasQry)->TF0_TIPO))
			(cTRB)->TF0_CTIPO  	:= (cAliasQry)->TF0_TIPO
			(cTRB)->TF0_CODTIP	:= (cAliasQry)->TF0_CODTIP
			(cTRB)->TB6_DESCRI	:= If(Empty((cAliasQry)->TB6_DESCRI),"-",(cAliasQry)->TB6_DESCRI)
			(cTRB)->TF0_TPRECE	:= (cAliasQry)->TF0_TPRECE
			(cTRB)->TF0_FORREC	:= (cAliasQry)->TF0_FORREC
			(cTRB)->TF0_LOJREC	:= (cAliasQry)->TF0_LOJREC
			(cTRB)->TB2_GRAUS1	:= If(Empty((cAliasQry)->TB2_GRAUS1),0,(cAliasQry)->TB2_GRAUS1)
			(cTRB)->TB2_MINUT1	:= If(Empty((cAliasQry)->TB2_MINUT1),0,(cAliasQry)->TB2_MINUT1)
			(cTRB)->TB2_SEGUN1	:= If(Empty((cAliasQry)->TB2_SEGUN1),0,(cAliasQry)->TB2_SEGUN1)
			(cTRB)->TB2_GRAUS2	:= If(Empty((cAliasQry)->TB2_GRAUS2),0,(cAliasQry)->TB2_GRAUS2)
			(cTRB)->TB2_MINUT2	:= If(Empty((cAliasQry)->TB2_MINUT2),0,(cAliasQry)->TB2_MINUT2)
			(cTRB)->TB2_SEGUN2	:= If(Empty((cAliasQry)->TB2_SEGUN2),0,(cAliasQry)->TB2_SEGUN2)
			(cTRB)->TB2_TPLATI	:= If(Empty((cAliasQry)->TB2_TPLATI),"-",NGRETSX3BOX("TB2_TPLATI",(cAliasQry)->TB2_TPLATI))
			(cTRB)->TB2_TPLONG	:= If(Empty((cAliasQry)->TB2_TPLONG),"-",NGRETSX3BOX("TB2_TPLONG",(cAliasQry)->TB2_TPLONG))
			(cTRB)->DESCREC		:= cNome
			(cTRB)->CGCREC	    	:= cCGC
			(cTRB)->TIPOREC		:= cTipo
			(cTRB)->QUANTIDADE	:= (cAliasQry)->TF0_PESOTO
			(cTRB)->TAX_CLASSI   := (cAliasQry)->TAX_CLASSE
			MsUnlock(cTRB)
		Else
			RecLock(cTRB,.F.)
			(cTRB)->QUANTIDADE	+= (cAliasQry)->TF0_PESOTO
			MsUnlock(cTRB)
		Endif
		If (nPos := aScan(aResiduos, {|x| x[1] == (cAliasQry)->TAX_CODRES}) ) == 0
			aAdd(aResiduos, {(cAliasQry)->TAX_CODRES, {{(cAliasQry)->TF0_DTCOMP, (cAliasQry)->TF0_PESOTO, ;
									fRetPol((cAliasQry)->TAX_CODRES,STOD((cAliasQry)->TF0_DTCOMP), (cAliasQry)->TF0_PESOTO) } }})
		Else
			aAdd(aResiduos[nPos][2], {(cAliasQry)->TF0_DTCOMP, (cAliasQry)->TF0_PESOTO,;
							 fRetPol((cAliasQry)->TAX_CODRES,STOD((cAliasQry)->TF0_DTCOMP), (cAliasQry)->TF0_PESOTO) })
		Endif
		dbSelectArea(cAliasQry)
		dbSkip()
	End
	(cAliasQry)->(dbCloseArea())

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} SGAR300PAD()
Imprime relatório IBAMA de Resíduos Sólidos

@author  Elynton Fellipe Bazzo
@since   03/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Static Function SGAR300PAD()

	Local WnRel		:= STR0002 //"SGAR300"
	Local Limite	:= 220
	Local cDesc1	:= STR0001 //"Relatório IBAMA de Resíduos Sólidos"
	Local cDesc2	:= ""
	Local cDesc3	:= ""
	Local cString	:= "TAX"

	Private NomeProg  := STR0002 //"SGAR300"
	Private Tamanho	:= "G"
	Private aReturn	:= {STR0007,1,STR0008,1,2,1,"",1} //"Zebrado" - "Administracao"
	Private Titulo	   := STR0009 //"Relatório IBAMA - Resíduos Sólidos"
	Private nTipo	   := 0
	Private nLastKey  := 0
	Private CABEC1,CABEC2

	//------------------------------------------
	// Envia controle para a funcao SETPRINT
	//-------------------------------------------
	WnRel:=SetPrint(cString,WnRel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,"")

	If nLastKey = 27
		Set Filter To
		DbSelectArea("TAX")
		Return
	EndIf
	SetDefault(aReturn,cString)
	Processa({|lEND| SGAR300Imp(@lEND,WnRel,Titulo,Tamanho)},STR0010) //"Processando Registros..."

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} SGAR300Imp()
Imprime relatório de FMR x MTR

@author  Elynton Fellipe Bazzo
@since   03/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Static Function SGAR300Imp(lEND,WnRel,Titulo,Tamanho)

	Local cRodaTxt	:= ""
	Local nCntImpr	:= 0 ,nTotal := 0, nPosScan := 0
	Local lImp 		:= .F., lPri := .T. ,lPri2 := .T.
	Local cCodRes 	:= "", i, j, nPos, nPos2, x, cB1COd
	Local aTots 	:= {}

	Private li 		:= 80 ,m_pag := 1
	Private cabec1	:= STR0011 //"Ano   Tipo Resíduo                                           "
	Private cabec2	:= STR0012 //"   Resíduo                                   Classificação              Identificação         Efic. Trat.       Tipo de Monitoramento"

	//    Tp. Finalidade        Finalidade                               Quantidade Un.  Receptor                                  CNPJ                Lat. Graus   Min.    Seg.   Tipo  Lon. Graus   Min.    Seg.   Tipo"
	/*
	0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3
	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	***************************************************************************************************************************************************************************************************************************************
	Ano   Resíduo                                   Classificação              Identificação         Tipo Resíduo                                           Efic. Trat.  Tipo de Monitoramento
	    Tp. Finalidade        Finalidade                               Quantidade Un.  Receptor                                  CNPJ                Lat. Graus   Min.    Seg.   Tipo  Lon. Graus   Min.    Seg.   Tipo
	***************************************************************************************************************************************************************************************************************************************
	9999  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxx  xxxxxxxxxx - xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx         999%  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	                                                                                                                                                                     xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	    xxxxxxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  999,999,999,999.999 xx   xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xx.xxx.xxx/xxxx-xx         999    999  999.99   XXXXX        999    999  999.99   XXXXX

	          Poluentes:
	                Código Poluente  Descrição                                           Quantidade Un.  Método        Identificação  Sigilo  Justificativa
	                XXXXXX           XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999,999,999,999,999,999,999.99 XX   XXXXXXXXXXXX  XXXXXXXXXXXX   XXX     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	*/
	//Carrega TRB
	Processa({|| SGAR300TRB()}, STR0013, STR0014, .T.) //"Aguarde" - "Processando Registros"


	dbSelectArea(cTRB)
	dbSetOrder(1)
	dbGoTop()
	ProcRegua((cTRB)->(RecCount()))
	While !eof()
		IncProc()
		If lImp
			NGSomali(58)
			NGSomali(58)
		Endif
		lImp := .T.
		NGSomali(58)
		//Cabecalho 1
		@ Li,000 pSay (cTRB)->ANO
		@ Li,006 pSay Padr((cTRB)->TFC_IBAMA,10)+" - "+(cTRB)->TFC_DESCRI Picture "@!"
		NGSOMALI(58)


		//Cabecalho 2
		cCodIB := Padr((cTRB)->TFC_IBAMA,10) +(cTRB)->TFC_DESCRI
		dbSelectArea(cTRB)
		While !eof() .and. cCodIB == Padr((cTRB)->TFC_IBAMA,10) +(cTRB)->TFC_DESCRI
			If lPri .And. cB1COd == (cTRB)->B1_DESC
				DbSelectArea(cTRB)
				dbSkip()
				Loop
			EndIf
			If lPri
				NGSOMALI(58)
				NGSomali(58)
			EndIf
			@ Li,003 pSay (cTRB)->B1_DESC Picture "@!"
			@ Li,045 pSay (cTRB)->TAX_CLASSI Picture "@!"
			@ Li,072	 pSay (cTRB)->TAX_IDENTI Picture "@!"

			@ Li,101 pSay (cTRB)->TF2_EFICIE Picture "999"
			@ Li,104 pSay "%" Picture "@!"
			@ Li,112 pSay Substr((cTRB)->TF2_TIPMON,1,50) Picture "@!"
			If Len((cTRB)->TF2_TIPMON) > 50
				NGSOMALI(58)
				@ Li,112 pSay Substr((cTRB)->TF2_TIPMON,51) Picture "@!"
			Endif
			cB1COd := (cTRB)->B1_DESC
			lPri := .T.
			cCodIba := (cTRB)->TFC_IBAMA
			cCodRes := (cTRB)->TAX_CODRES
			dbSelectArea(cTRB)
			dbSetorder(1)
			While !eof() .and. (cTRB)->TFC_IBAMA + (cTRB)->TAX_CODRES == cCodIba + cCodRes
				//Cabecalho 3
				If lPri2
					NGSOMALI(58)
					@ Li,006 pSay STR0015 //"Tp. Finalidade:       Finalidade:                              Quantidade Un.  Receptor:                                 CNPJ:               Lat. Graus:  Min.    Seg.   Tipo: Lon. Graus:  Min.    Seg.   Tipo:"
					NGSOMALI(58)
				  //	dbSkip(-1)
				EndIf
				lPri2 := .F.
				@ Li,006 pSay (cTRB)->TF0_TIPO Picture "@!"
				@ Li,028 pSay (cTRB)->TB6_DESCRI Picture "@!"
				@ Li,060 pSay (cTRB)->QUANTIDADE Picture "@E 999,999,999,999.999"
				@ Li,080 pSay (cTRB)->B1_UM Picture "@!"
				@ Li,085 pSay SubStr((cTRB)->DESCREC,1,30) Picture "@!"
				If (cTRB)->TIPOREC <> "F"
					@ Li,117 pSay (cTRB)->CGCREC Picture If(!Empty((cTRB)->CGCREC),"@R 99.999.999/9999-99","@!")
				Else
					@ Li,117 pSay (cTRB)->CGCREC Picture If(!Empty((cTRB)->CGCREC),"@R 999.999.999-99","@!")
				Endif
				@ Li,137 pSay (cTRB)->TB2_GRAUS1 Picture PesqPict("TB2","TB2_GRAUS1")
				@ Li,150 pSay (cTRB)->TB2_MINUT1 Picture PesqPict("TB2","TB2_MINUT1")
				@ Li,161 pSay (cTRB)->TB2_SEGUN1 Picture PesqPict("TB2","TB2_SEGUN1")
				@ Li,170 pSay AllTrim((cTRB)->TB2_TPLATI) Picture "@!"
				@ Li,178 pSay (cTRB)->TB2_GRAUS2 Picture PesqPict("TB2","TB2_GRAUS2")
				@ Li,192 pSay (cTRB)->TB2_MINUT2 Picture PesqPict("TB2","TB2_MINUT2")
				@ Li,204 pSay (cTRB)->TB2_SEGUN2 Picture PesqPict("TB2","TB2_SEGUN2")
				@ Li,211 pSay AllTrim((cTRB)->TB2_TPLONG) Picture "@!"
				cB1COd := (cTRB)->B1_DESC
				NGSOMALI(58)
				If MV_PAR02 == 3
					nPosScan := aSCAN(aTots,{|x| x[1] == Upper((cTRB)->TF0_TIPO)+" "+(cTRB)->TB6_DESCRI+" "+(cTRB)->DESCREC})
					If nPosScan > 0
						aTots[nPosScan,2] += (cTRB)->QUANTIDADE
					Else
						aADD(aTots,{Upper((cTRB)->TF0_TIPO)+" "+(cTRB)->TB6_DESCRI+" "+(cTRB)->DESCREC,(cTRB)->QUANTIDADE,(cTRB)->B1_UM})
					Endif
					nTotal += (cTRB)->QUANTIDADE
				ElseIf MV_PAR02 == 2
					nPosScan := aSCAN(aTots,{|x| x[1] == (cTRB)->DESCREC})
					If nPosScan > 0
						aTots[nPosScan,2] += (cTRB)->QUANTIDADE
					Else
						aADD(aTots,{(cTRB)->DESCREC,(cTRB)->QUANTIDADE,(cTRB)->B1_UM})
					Endif
					nTotal += (cTRB)->QUANTIDADE
				ElseIf MV_PAR02 == 1
					nPosScan := aSCAN(aTots,{|x| x[1] == Upper((cTRB)->TF0_TIPO)+" "+(cTRB)->TB6_DESCRI})
					If nPosScan > 0
						aTots[nPosScan,2] += (cTRB)->QUANTIDADE
					Else
						aADD(aTots,{Upper((cTRB)->TF0_TIPO)+" "+(cTRB)->TB6_DESCRI,(cTRB)->QUANTIDADE,(cTRB)->B1_UM})
					Endif
					nTotal += (cTRB)->QUANTIDADE
				EndIf
				dbSelectArea(cTRB)
				dbSkip()
			End
			aPoluentes:= {}
			If (nPos2 := aScan(aResiduos, {|x| x[1] == cCodRes}) ) > 0
				For i:=1 to Len(aResiduos[nPos2][2])
					For j:=1 to Len(aResiduos[nPos2][2][i][3])
						dbSelectArea("TF1")
						dbSetOrder(1)
						If dbSeek(xFilial("TF1")+cCodRes+aResiduos[nPos2][2][i][3][j][1]+DTOS(aResiduos[nPos2][2][i][3][j][3]))
							If (nPos := aScan(aPoluentes, {|x| x[1]+x[2]+x[3]+x[4]+x[5] == TF1->(TF1_CODPOL+TF1_UNIDAD+TF1_METODO+TF1_IDMETO+TF1_CONSIG) } ) ) == 0
								aAdd(aPoluentes, {TF1->TF1_CODPOL, TF1->TF1_UNIDAD, TF1->TF1_METODO, TF1->TF1_IDMETO, TF1->TF1_CONSIG,;
													 TF1->TF1_JUSSIG, aResiduos[nPos2][2][i][3][j][2], ;
													 Substr(NGSEEK("TEG",TF1->TF1_CODPOL,1,"TEG->TEG_DESCRI"),1,30),;
													 If(!Empty(TF1->TF1_METODO),AllTrim(NGRETSX3BOX("TF1_METODO",TF1->TF1_METODO)),""),;
													 If(!Empty(TF1->TF1_CONSIG),AllTrim(NGRETSX3BOX("TF1_CONSIG",TF1->TF1_CONSIG)),"")} )
							Else
								aPoluentes[nPos,7] += aResiduos[nPos2][2][i][3][j][2]
								If Empty(aPoluentes[nPos,6]) .and. !Empty(TF1->TF1_JUSSIG)
									aPoluentes[nPos,6] += TF1->TF1_JUSSIG
								Endif
							Endif
						Endif
					Next j
				Next i
			Endif
			If Len(aPoluentes) > 0
				aSort( aPoluentes,,, { |x,y| x[1]+x[2]+x[3]+x[4]+x[5] < y[1]+y[2]+y[3]+y[4]+y[5] } )
				For i:=1 to Len(aPoluentes)
					NGSOMALI(58)
					If i == 1
						@ Li,011 pSay STR0016 //"Poluentes:"
						NGSOMALI(58)
						@ Li,005 pSay STR0017 //"                Código Poluente  Descrição                                           Quantidade Un.  Método        Identificação  Sigilo  Justificativa"
						NGSOMALI(58)
					Endif
					@ Li,021 pSay AllTrim(aPoluentes[i,1]) Picture "@!"
					@ Li,038 pSay AllTrim(aPoluentes[i,8]) Picture "@!"
					@ Li,070 pSay aPoluentes[i,7] Picture "@E 999,999,999,999,999,999,999.99"
					@ Li,101 pSay AllTrim(aPoluentes[i,2]) Picture "@!"
					If !Empty(aPoluentes[i,9])
						@ Li,135 pSay AllTrim(aPoluentes[i,9]) Picture "@!"
					Endif
					If !Empty(aPoluentes[i,4])
						@ Li,118 pSay AllTrim(aPoluentes[i,4]) Picture "@!"
					Endif
					If !Empty(aPoluentes[i,10])
						@ Li,148 pSay AllTrim(aPoluentes[i,10]) Picture "@!"
					Endif
					If !Empty(aPoluentes[i,6])
						cMemo := AllTrim(aPoluentes[i,6])
						nLinha:= MLCount(cMemo,60)
						For j:= 1 To nLinha
							If j != 1
								NGSomali(58)
							Endif
							@ Li,156 PSAY Memoline(cMemo,60,j)
						Next
					Endif
					NGSOMALI(58)
					@ Li,000 pSay Replicate("_",220)
				Next i
			Else
				NGSomali(58)
				@ Li,011 pSay STR0018 //"Não existem poluentes gerados por este resíduo no período."
				NGSomali(58)
			Endif
			If cCodIB == Padr((cTRB)->TFC_IBAMA,10)
				DbSelectArea(cTRB)
				dbSkip()
			EndIf
			lPri2 := .T.
		End
		NGSomali(58)
		For x := 1 to len(aTots)
			NGSOMALI(58)
			@ Li,050 pSay STR0019 Picture "@!" //"Total :"
			@ Li,060 pSay aTots[x][2] Picture "@E 999,999,999,999.999"
			@ Li,080 pSay aTots[x][3] Picture "@!"
			If MV_PAR02 == 3
				@ Li,085 pSay AllTrim(aTots[x][1])
			ElseIf MV_PAR02 == 2
				@ Li,085 pSay AllTrim(aTots[x][1])
			Else
				If !Empty(Substr(aTots[x][1],1,30))
					@ Li,085 pSay AllTrim(aTots[x][1])
				Else
					@ Li,085 pSay "      -      "
				EndIf
			EndIf
		Next x
		NGSomali(58)
		aTots := {}
	//	If cCodIba <> (cTRB)->TFC_IBAMA
	//		dbSelectArea(cTRB)
	//		dbSkip()
	//	EndIf
	End

	If lImp
		RODA(nCntImpr,cRodaTxt,Tamanho)
		Set Device To Screen
		If aReturn[5] == 1
		   Set Printer To
		   dbCommitAll()
		   OurSpool(WnRel)
		EndIf
		MS_FLUSH()
	Else
		MsgInfo(STR0020) //"Não existem dados para montar o relatório."
	Endif

	//------------------------------------------------------
	// Devolve a condicao original do arquivo principal
	//------------------------------------------------------
	Set Filter To

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fRetPol(cResiduo, dData, nQuant)
Retorna poluente do resíduo na data

@author  Elynton Fellipe Bazzo
@since   03/05/2013
@version P11
@return  aPol
/*/
//---------------------------------------------------------------------
Static Function fRetPol(cResiduo, dData, nQuant)

	Local aPol := {}
	Local nPos

	dbSelectArea("TF1")
	dbSetOrder(1)
	dbSeek(xFilial("TF1")+cResiduo)
	While !Eof() .and. xFilial("TF1")+cResiduo == TF1->(TF1_FILIAL+TF1_CODRES)
		nPos := aScan(aPol, {|x| x[1] == TF1->TF1_CODPOL })
		If dData >= TF1->TF1_DATA .or. (dData < TF1->TF1_DATA .and. nPos == 0) .or. ;
			(nPos > 0 .and. aPol[nPos][3] < TF1->TF1_DATA .and. TF1->TF1_DATA < dData)
			If nPos == 0
				aAdd(aPol, {TF1->TF1_CODPOL, TF1->TF1_COEFIC*nQuant, TF1->TF1_DATA})
			Else
				aPol[nPos][2] := TF1->TF1_COEFIC*nQuant
				aPol[nPos][3] := TF1->TF1_DATA
			Endif
		Endif
		dbSelectArea("TF1")
		dbSkip()
	End

Return aPol