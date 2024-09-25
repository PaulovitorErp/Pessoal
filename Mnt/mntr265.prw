#INCLUDE "MNTR265.ch"
#Include "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMNTR265   บAutor  ณRoger Rodrigues     บ Data ณ  04/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRelat๓rio de Anแlise de Pneus Sucateados                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Manuten็ใo de Ativos                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MNTR265

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGuarda conteudo e declara variaveis padroes ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aNGBEGINPRM := NGBEGINPRM(3)
	Local cString     := "TQS"
	Local cDesc1      := STR0001 //"Relat๓rio de Anแlise de Pneus Sucateados"
	Local cDesc2      := ""
	Local cDesc3      := ""
	Local wnrel       := "MNTR265"

	Private aReturn   := { STR0002, 1,STR0003, 2, 2, 1, "",1 } //"Zebrado"###"Administracao"
	Private nLastKey  := 0
	Private cPerg     := "MNR265"
	Private Titulo    := STR0001 //"Relat๓rio de Anแlise de Pneus Sucateados"
	Private Tamanho   := "G"
	Private aPerg     := {}
	Private nomeProg  := "MNTR265"
	Private aVETINR   := {}
	Private oArqTrab
	Private cAliasTRB := GetNextAlias()

	SetKey( VK_F9, { | | NGVersao( "MNTR265" , 1 ) } )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Variaveis utilizadas                                         ณ
	//ณ MV_PAR01     // De Data                                      ณ
	//ณ MV_PAR02     // At้ Data                                     ณ
	//ณ MV_PAR03     // De Medida                                    ณ
	//ณ MV_PAR04     // Ate Medida                                   ณ
	//| MV_PAR05     // De Tipo Modelo                               ณ
	//| MV_PAR06     // Ate Tipo Modelo                              ณ
	//| MV_PAR07     // De Motivo Destino                            ณ
	//| MV_PAR08     // Ate Motivo Destino                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	pergunte(cPerg,.F.)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Envia controle para a funcao SETPRINT                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"")

	If nLastKey = 27
		Set Filter To
		DbselectArea("TQS")
		NGRETURNPRM(aNGBEGINPRM)
		Return
	Endif

	SetDefault(aReturn,cString)

	RptStatus({|lEnd| R265Imp(@lEnd,wnRel,titulo,tamanho)},titulo)

	DbselectArea("TQS")
	NGRETURNPRM(aNGBEGINPRM)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR265IMP   บAutor  ณRoger Rodrigues     บ Data ณ  04/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime o relat๓rio                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTR265                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R265IMP(lEnd,wnRel,titulo,tamanho)
	Private li := 80 ,m_pag := 1
	Private cSucata  := GetMV("MV_NGSTARS")
	nTipo := IIF(aReturn[4]==1,15,18)

	cabec1 := STR0004 //"                                                                    Data                KM      -------Original-------  ----------R1----------  ----------R2----------  ----------R3----------  ----------R4----------"
	cabec2 := STR0005 //"Motivo Sucateamento           Modelo       Desenho     Nบ Fogo     Compra            Acumulado  KM          Desenho     KM          Desenho     KM          Desenho     KM          Desenho     KM          Desenho     DOT"

	/*
	********************************************************************************************************************************************************************************************************************************
	*<empresa>                                                                                                                                                                                                    Folha..: xxxxx   *
	*SIGA /SCR001/v.P10                                                        Relat๓rio de Anแlise de Pneus Sucateados                                                                                           DT.Ref.: dd/mm/aa*
	*Hora...: xx:xx:xx                                                                                                                                                                                            Emissao: dd/mm/aa*
	********************************************************************************************************************************************************************************************************************************
	1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2
	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123
	Data                KM      -------Original-------  ----------R1----------  ----------R2----------  ----------R3----------  ----------R4----------
	Motivo Sucateamento           Modelo       Desenho     Nบ Fogo     Compra            Acumulado  KM          Desenho     KM          Desenho     KM          Desenho     KM          Desenho     KM          Desenho     DOT
	********************************************************************************************************************************************************************************************************************************
	xxxxxxxxxxxxxxxxxxxxxxxxxxxx  xxxxxxxxxx   xxxxxxxxxx  xxxxxxxxxx  xx/xx/xxxx  999,999,999,999  999999999   xxxxxxxxxx  999999999   xxxxxxxxxx  999999999   xxxxxxxxxx  999999999   xxxxxxxxxx  999999999   xxxxxxxxxx  xxxx
	*/

	Processa({|lEND| MNTR265TRB(@lEnd)},STR0006) //"Processando Arquivo..."

	If (cAliasTRB)->(RecCount()) > 0
		dbSelectArea(cAliasTRB)
		dbGoTop()
		While !Eof()
			NgSomali(58)
			@Li,000 pSay Substr((cAliasTRB)->CAUSA,1,27)
			@Li,030 pSay (cAliasTRB)->T9_TIPMOD
			@Li,043 pSay (cAliasTRB)->TQS_DESENH
			@Li,055 pSay (cAliasTRB)->TQS_NUMFOG
			@Li,067 pSay (cAliasTRB)->T9_DTCOMPR	Picture "99/99/9999"
			@Li,079 pSay (cAliasTRB)->T9_CONTACU	Picture "@E 999,999,999,999"
			@Li,096 pSay Padr((cAliasTRB)->TQS_KMOR,9,"")
			@Li,108 pSay (cAliasTRB)->BANDAORI
			@Li,120 pSay Padr((cAliasTRB)->TQS_KMR1,9,"")
			@Li,133 pSay (cAliasTRB)->BANDA1
			@Li,144 pSay Padr((cAliasTRB)->TQS_KMR2,9,"")
			@Li,157 pSay (cAliasTRB)->BANDA2
			@Li,168 pSay Padr((cAliasTRB)->TQS_KMR3,9,"")
			@Li,181 pSay (cAliasTRB)->BANDA3
			@Li,192 pSay Padr((cAliasTRB)->TQS_KMR4,9,"")
			@Li,204 pSay (cAliasTRB)->BANDA4
			@Li,216 pSay (cAliasTRB)->TQS_DOT
			dbSelectArea(cAliasTRB)
			dbSkip()
		End
	Else
		MsgInfo(STR0007) //"Nใo existem dados para imprimir no relat๓rio."
	Endif

	dbSelectArea(cAliasTRB)
	
	oArqTrab:Delete() //Deleta Tabela Temporแria
	
	dbCloseArea()
	Set Filter To
	Set Device To Screen
	If aReturn[5] == 1
		Set Printer To
		dbCommitAll()
		OurSpool(wnrel)
	EndIf
	MS_FLUSH()

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMNTR265TRBบAutor  ณRoger Rodrigues     บ Data ณ  04/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega arquivo temporแrio com os pneus sucateados          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MNTR265                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MNTR265TRB(lEnd)
	Private aDBF := {}
	Private cDBMS := Upper(TCGETDB())
	Private cSrvType := TCSrvType()

	aAdd(aDBF,{ "DTANALISE"	, "D" ,8						, 0 })
	aAdd(aDBF,{ "HORA"			, "C" ,5						, 0 })
	aAdd(aDBF,{ "CAUSA"		, "C" ,Len(ST8->T8_NOME)		, 0 })
	aAdd(aDBF,{ "T9_CODBEM"	, "C" ,Len(ST9->T9_CODBEM)		, 0 })
	aAdd(aDBF,{ "T9_TIPMOD"	, "C" ,Len(ST9->T9_TIPMOD)		, 0 })
	aAdd(aDBF,{ "TQS_DESENH"	, "C" ,Len(TQS->TQS_DESENH)	, 0 })
	aAdd(aDBF,{ "TQS_NUMFOG"	, "C" ,Len(TQS->TQS_NUMFOG)	, 0 })
	aAdd(aDBF,{ "T9_DTCOMPR"	, "D" ,8						, 0 })
	aAdd(aDBF,{ "T9_CONTACU"	, "N" ,12						, 0 })
	aAdd(aDBF,{ "TQS_KMOR"		, "N" ,9						, 0 })
	aAdd(aDBF,{ "BANDAORI"		, "C" ,Len(TR8->TR8_DESENH)	, 0 })
	aAdd(aDBF,{ "TQS_KMR1"		, "N" ,9						, 0 })
	aAdd(aDBF,{ "BANDA1"		, "C" ,Len(TR8->TR8_DESENH)	, 0 })
	aAdd(aDBF,{ "TQS_KMR2"		, "N" ,9						, 0 })
	aAdd(aDBF,{ "BANDA2"		, "C" ,Len(TR8->TR8_DESENH)	, 0 })
	aAdd(aDBF,{ "TQS_KMR3"		, "N" ,9						, 0 })
	aAdd(aDBF,{ "BANDA3"		, "C" ,Len(TR8->TR8_DESENH)	, 0 })
	aAdd(aDBF,{ "TQS_KMR4"		, "N" ,9						, 0 })
	aAdd(aDBF,{ "BANDA4"		, "C" ,Len(TR8->TR8_DESENH)	, 0 })
	aAdd(aDBF,{ "TQS_DOT"		, "C" ,Len(TQS->TQS_DOT)		, 0 })

	//Cria Tabela Temporแria
	oArqTrab := NGFwTmpTbl(cAliasTRB,aDBF,{{"T9_CODBEM"}})


	//Carrega os registros de anแlise t้cnica
	cAnaArqTRB := GetNextAlias()
	cQuery := "SELECT TR4.TR4_DTANAL AS DTANALISE, TR4.TR4_HRANAL AS HORA, ST9.T9_CODBEM, ST8.T8_NOME AS CAUSA, ST9.T9_TIPMOD, "
	cQuery += "TQS.TQS_DESENH, TQS.TQS_NUMFOG, ST9.T9_DTCOMPR, ST9.T9_CONTACU, TQS.TQS_KMOR, "
	cQuery += " (SELECT MAX(TQV.TQV_DESENH) FROM "+RetSqlName("TQV")+" TQV WHERE TQV.D_E_L_E_T_ <> '*' AND TQV.TQV_CODBEM = TQS.TQS_CODBEM AND TQV.TQV_BANDA = '1') AS BANDAORI, "
	cQuery += " TQS.TQS_KMR1, "
	cQuery += " (SELECT MAX(TQV.TQV_DESENH) FROM "+RetSqlName("TQV")+" TQV WHERE TQV.D_E_L_E_T_ <> '*' AND TQV.TQV_CODBEM = TQS.TQS_CODBEM AND TQV.TQV_BANDA = '2') AS BANDA1, "
	cQuery += " TQS.TQS_KMR2, "
	cQuery += " (SELECT MAX(TQV.TQV_DESENH) FROM "+RetSqlName("TQV")+" TQV WHERE TQV.D_E_L_E_T_ <> '*' AND TQV.TQV_CODBEM = TQS.TQS_CODBEM AND TQV.TQV_BANDA = '3') AS BANDA2, "
	cQuery += " TQS.TQS_KMR3, "
	cQuery += " (SELECT MAX(TQV.TQV_DESENH) FROM "+RetSqlName("TQV")+" TQV WHERE TQV.D_E_L_E_T_ <> '*' AND TQV.TQV_CODBEM = TQS.TQS_CODBEM AND TQV.TQV_BANDA = '4') AS BANDA3, "
	cQuery += " TQS.TQS_KMR4, "
	cQuery += " (SELECT MAX(TQV.TQV_DESENH) FROM "+RetSqlName("TQV")+" TQV WHERE TQV.D_E_L_E_T_ <> '*' AND TQV.TQV_CODBEM = TQS.TQS_CODBEM AND TQV.TQV_BANDA = '5') AS BANDA4, "
	cQuery += " TQS.TQS_DOT "
	cQuery += "FROM "+RetSqlName("TR4")+" TR4 "
	cQuery += "JOIN "+RetSqlName("TQS")+" TQS ON TQS.TQS_CODBEM = TR4.TR4_CODBEM "
	cQuery += "JOIN "+RetSqlName("ST9")+" ST9 ON ST9.T9_CODBEM = TQS.TQS_CODBEM "
	cQuery += "JOIN "+RetSqlName("ST8")+" ST8 ON ST8.T8_CODOCOR = TR4.TR4_MOTIVO "
	cQuery += "WHERE ST9.T9_STATUS = '"+ cSucata +"' AND TQS.TQS_MEDIDA BETWEEN '"+ mv_par05 +"' AND '"+ mv_par06 +"'"
	cQuery += " AND ST9.T9_TIPMOD  BETWEEN '"+ mv_par03 +"' AND '"+ mv_par04 +"'"
	cQuery += " AND TR4.TR4_DTANAL BETWEEN '"+ DTOS(mv_par01) +"' AND '"+ DTOS(mv_par02) +"'"
	cQuery += " AND TR4.TR4_MOTIVO BETWEEN '"+ mv_par07 +"' AND '"+ mv_par08 +"'"
	cQuery += " AND TQS.TQS_FILIAL = '"+ xFilial("TQS") +"' AND ST9.T9_FILIAL = '"+ xFilial("ST9") +"'"
	cQuery += " AND TR4.TR4_FILIAL = '"+ xFilial("TR4") +"' AND ST8.T8_FILIAL = '"+ xFilial("ST8") +"'"
	cQuery += " AND TQS.D_E_L_E_T_ <> '*' AND ST9.D_E_L_E_T_ <> '*' AND TR4.D_E_L_E_T_ <> '*' AND ST8.D_E_L_E_T_ <> '*'"
	cQuery += "ORDER BY ST9.T9_CODBEM"
	cQuery := ChangeQuery(cQuery)
	//Verifica se o banco ้ diferente de DB2 para retirar o FOR READ ONLY caso o Change Query coloque na Query
	If !(cDBMS == "DB2" .or. cSrvType == "AS/400")
		cQuery := StrTran(cQuery, " FOR READ ONLY", " ")
	Endif
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAnaArqTRB, .F., .T.)

	dbSelectArea(cAnaArqTRB)
	dbGoTop()
	While !Eof()
		dbSelectArea(cAliasTRB)
		dbSetOrder(1)
		If dbSeek((cAnaArqTRB)->T9_CODBEM)
			RecLock(cAliasTRB,.F.)
			(cAliasTRB)->DTANALISE 	:= STOD((cAnaArqTRB)->DTANALISE)
			(cAliasTRB)->HORA 		:= (cAnaArqTRB)->HORA
			(cAliasTRB)->CAUSA 		:= (cAnaArqTRB)->CAUSA
			MsUnlock(cAliasTRB)
		Else
			RecLock(cAliasTRB,.T.)
			(cAliasTRB)->DTANALISE 	:= STOD((cAnaArqTRB)->DTANALISE)
			(cAliasTRB)->HORA 		:= (cAnaArqTRB)->HORA
			(cAliasTRB)->CAUSA 		:= (cAnaArqTRB)->CAUSA
			(cAliasTRB)->T9_CODBEM 	:= (cAnaArqTRB)->T9_CODBEM
			(cAliasTRB)->T9_TIPMOD 	:= (cAnaArqTRB)->T9_TIPMOD
			(cAliasTRB)->TQS_DESENH	:= (cAnaArqTRB)->TQS_DESENH
			(cAliasTRB)->TQS_NUMFOG	:= (cAnaArqTRB)->TQS_NUMFOG
			(cAliasTRB)->T9_DTCOMPR	:= STOD((cAnaArqTRB)->T9_DTCOMPR)
			(cAliasTRB)->T9_CONTACU	:= (cAnaArqTRB)->T9_CONTACU
			(cAliasTRB)->TQS_KMOR	:= (cAnaArqTRB)->TQS_KMOR
			(cAliasTRB)->BANDAORI	:= (cAnaArqTRB)->BANDAORI
			(cAliasTRB)->TQS_KMR1	:= (cAnaArqTRB)->TQS_KMR1
			(cAliasTRB)->BANDA1		:= (cAnaArqTRB)->BANDA1
			(cAliasTRB)->TQS_KMR2	:= (cAnaArqTRB)->TQS_KMR2
			(cAliasTRB)->BANDA2		:= (cAnaArqTRB)->BANDA2
			(cAliasTRB)->TQS_KMR3	:= (cAnaArqTRB)->TQS_KMR3
			(cAliasTRB)->BANDA3		:= (cAnaArqTRB)->BANDA3
			(cAliasTRB)->TQS_KMR4	:= (cAnaArqTRB)->TQS_KMR4
			(cAliasTRB)->BANDA4		:= (cAnaArqTRB)->BANDA4
			(cAliasTRB)->TQS_DOT	:= (cAnaArqTRB)->TQS_DOT
			MsUnlock(cAliasTRB)
		Endif
		dbSelectArea(cAnaArqTRB)
		dbSkip()
	End
	dbSelectArea(cAnaArqTRB)
	dbCloseArea()

	//Carrega Registros do esquema de Rodados
	cAliasSTZ := GetNextAlias()
	cQuery := "SELECT STZ.TZ_DATAMOV AS DTANALISE, STZ.TZ_HORAENT AS HORA, ST9.T9_CODBEM, ST8.T8_NOME AS CAUSA, ST9.T9_TIPMOD, "
	cQuery += "TQS.TQS_DESENH, TQS.TQS_NUMFOG, ST9.T9_DTCOMPR, ST9.T9_CONTACU, TQS.TQS_KMOR, "
	cQuery += " (SELECT MAX(TQV.TQV_DESENH) FROM "+RetSqlName("TQV")+" TQV WHERE TQV.D_E_L_E_T_ <> '*' AND TQV.TQV_CODBEM = TQS.TQS_CODBEM AND TQV.TQV_BANDA = '1') AS BANDAORI, "
	cQuery += " TQS.TQS_KMR1, "
	cQuery += " (SELECT MAX(TQV.TQV_DESENH) FROM "+RetSqlName("TQV")+" TQV WHERE TQV.D_E_L_E_T_ <> '*' AND TQV.TQV_CODBEM = TQS.TQS_CODBEM AND TQV.TQV_BANDA = '2') AS BANDA1, "
	cQuery += " TQS.TQS_KMR2, "
	cQuery += " (SELECT MAX(TQV.TQV_DESENH) FROM "+RetSqlName("TQV")+" TQV WHERE TQV.D_E_L_E_T_ <> '*' AND TQV.TQV_CODBEM = TQS.TQS_CODBEM AND TQV.TQV_BANDA = '3') AS BANDA2, "
	cQuery += " TQS.TQS_KMR3, "
	cQuery += " (SELECT MAX(TQV.TQV_DESENH) FROM "+RetSqlName("TQV")+" TQV WHERE TQV.D_E_L_E_T_ <> '*' AND TQV.TQV_CODBEM = TQS.TQS_CODBEM AND TQV.TQV_BANDA = '4') AS BANDA3, "
	cQuery += " TQS.TQS_KMR4, "
	cQuery += " (SELECT MAX(TQV.TQV_DESENH) FROM "+RetSqlName("TQV")+" TQV WHERE TQV.D_E_L_E_T_ <> '*' AND TQV.TQV_CODBEM = TQS.TQS_CODBEM AND TQV.TQV_BANDA = '5') AS BANDA4, "
	cQuery += " TQS.TQS_DOT "
	cQuery += "FROM "+RetSqlName("STZ")+" STZ "
	cQuery += "JOIN "+RetSqlName("TQS")+" TQS ON TQS.TQS_CODBEM = STZ.TZ_CODBEM "
	cQuery += "JOIN "+RetSqlName("ST9")+" ST9 ON ST9.T9_CODBEM = TQS.TQS_CODBEM "
	cQuery += "JOIN "+RetSqlName("ST8")+" ST8 ON ST8.T8_CODOCOR = STZ.TZ_CAUSA "
	cQuery += "WHERE ST9.T9_STATUS = '"+ cSucata +"' AND TQS.TQS_MEDIDA BETWEEN '"+ mv_par05 +"' AND '"+ mv_par06 +"'"
	cQuery += " AND ST9.T9_TIPMOD  BETWEEN '"+ mv_par03 +"' AND '"+ mv_par04 +"'"
	cQuery += " AND STZ.TZ_DATAMOV BETWEEN '"+ DTOS(mv_par01) +"' AND '"+ DTOS(mv_par02) +"'"
	cQuery += " AND STZ.TZ_CAUSA BETWEEN '"+ mv_par07 +"' AND '"+ mv_par08 +"'"
	cQuery += " AND TQS.TQS_FILIAL = '"+ xFilial("TQS") +"' AND ST9.T9_FILIAL = '"+ xFilial("ST9") +"'"
	cQuery += " AND STZ.TZ_FILIAL =  '"+ xFilial("STZ") +"' AND ST8.T8_FILIAL = '"+ xFilial("ST8") +"'"
	cQuery += " AND TQS.D_E_L_E_T_ <> '*' AND ST9.D_E_L_E_T_ <> '*' AND STZ.D_E_L_E_T_ <> '*' AND ST8.D_E_L_E_T_ <> '*'"
	cQuery += "ORDER BY ST9.T9_CODBEM"
	cQuery := ChangeQuery(cQuery)
	//Verifica se o banco ้ diferente de DB2 para retirar o FOR READ ONLY caso o Change Query coloque na Query
	If !(cDBMS == "DB2" .or. cSrvType == "AS/400")
		cQuery := StrTran(cQuery, " FOR READ ONLY", " ")
	Endif
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasSTZ, .F., .T.)

	//Verifica qual registro ้ o mais recente entre as duas tabelas
	dbSelectArea(cAliasSTZ)
	dbGoTop()
	While !eof()
		dbSelectArea(cAliasTRB)
		dbSetOrder(1)
		If dbSeek((cAliasSTZ)->T9_CODBEM)
			If STOD((cAliasSTZ)->DTANALISE) > (cAliasTRB)->DTANALISE
				dbSelectArea(cAliasTRB)
				RecLock(cAliasTRB, .F.)
				(cAliasTRB)->DTANALISE := STOD((cAliasSTZ)->DTANALISE)
				(cAliasTRB)->HORA	   := (cAliasSTZ)->HORA
				(cAliasTRB)->CAUSA     := (cAliasSTZ)->CAUSA
				MsUnlock(cAliasTRB)
			ElseIf STOD((cAliasSTZ)->DTANALISE) == (cAliasTRB)->DTANALISE .AND. (cAliasSTZ)->HORA > (cAliasTRB)->HORA
				dbSelectArea(cAliasTRB)
				RecLock(cAliasTRB, .F.)
				(cAliasTRB)->DTANALISE 	:= STOD((cAliasSTZ)->DTANALISE)
				(cAliasTRB)->HORA	    := (cAliasSTZ)->HORA
				(cAliasTRB)->CAUSA     	:= (cAliasSTZ)->CAUSA
				MsUnlock(cAliasTRB)
			Endif
		Else
			dbSelectArea(cAliasTRB)
			RecLock(cAliasTRB,.T.)
			(cAliasTRB)->DTANALISE 	:= STOD((cAliasSTZ)->DTANALISE)
			(cAliasTRB)->HORA 		:= (cAliasSTZ)->HORA
			(cAliasTRB)->CAUSA 		:= (cAliasSTZ)->CAUSA
			(cAliasTRB)->T9_CODBEM 	:= (cAliasSTZ)->T9_CODBEM
			(cAliasTRB)->T9_TIPMOD 	:= (cAliasSTZ)->T9_TIPMOD
			(cAliasTRB)->TQS_DESENH	:= (cAliasSTZ)->TQS_DESENH
			(cAliasTRB)->TQS_NUMFOG	:= (cAliasSTZ)->TQS_NUMFOG
			(cAliasTRB)->T9_DTCOMPR	:= STOD((cAliasSTZ)->T9_DTCOMPR)
			(cAliasTRB)->T9_CONTACU	:= (cAliasSTZ)->T9_CONTACU
			(cAliasTRB)->TQS_KMOR	:= (cAliasSTZ)->TQS_KMOR
			(cAliasTRB)->BANDAORI	:= (cAliasSTZ)->BANDAORI
			(cAliasTRB)->TQS_KMR1	:= (cAliasSTZ)->TQS_KMR1
			(cAliasTRB)->BANDA1		:= (cAliasSTZ)->BANDA1
			(cAliasTRB)->TQS_KMR2	:= (cAliasSTZ)->TQS_KMR2
			(cAliasTRB)->BANDA2		:= (cAliasSTZ)->BANDA2
			(cAliasTRB)->TQS_KMR3	:= (cAliasSTZ)->TQS_KMR3
			(cAliasTRB)->BANDA3		:= (cAliasSTZ)->BANDA3
			(cAliasTRB)->TQS_KMR4	:= (cAliasSTZ)->TQS_KMR4
			(cAliasTRB)->BANDA4		:= (cAliasSTZ)->BANDA4
			(cAliasTRB)->TQS_DOT		:= (cAliasSTZ)->TQS_DOT
			MsUnlock(cAliasTRB)
		Endif
		dbSelectArea(cAliasSTZ)
		dbSkip()
	End

	dbSelectArea(cAliasSTZ)
	dbCloseArea()

Return .T.