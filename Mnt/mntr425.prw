#INCLUDE "MNTR425.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTR425   ³ Autor ³ Ricardo Dal Ponte     ³ Data ³ 15/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio de resultado dos recurso                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNTR425()


	//Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	Local aNGBEGINPRM := NGBEGINPRM()
	Local nSizeFil := If(FindFunction("FWSizeFilial"),FwSizeFilial(),Len(TRX->TRX_FILIAL))

	If ExistBlock("MNTR425R")
		ExecBlock("MNTR425R",.F.,.F.)
		//Devolve variaveis armazenadas (NGRIGHTCLICK)
		NGRETURNPRM(aNGBEGINPRM)
		Return .T.
	EndIf

	Private cAliasQry  := GetNextAlias()
	Private lnRegistro := .F.

	Private NOMEPROG := "MNTR425"
	Private TAMANHO  := "G"
	Private aRETURN  := {STR0001,1,STR0002,1,2,1,"",1} //"Zebrado"###"Administracao"
	Private TITULO   := STR0003 //"Relatório de Resultados dos Recursos"
	Private nTIPO    := 0
	Private nLASTKEY := 0
	Private CABEC1,CABEC2
	Private aVETINR := {}
	Private cPERG := "MNT425"
	Private aPerg :={}

	Private lEditResp := If(NGCADICBASE("TRX_REPON","A","TRX",.F.),.T.,.F.)

	WNREL      := "MNTR425"
	LIMITE     := 220
	cDESC1     := STR0004 //"O relatório apresentará informações das multas que foram"
	cDESC2     := STR0005 //"recorridas pela empresa. Apresenta os valores restituídos"
	cDESC3     := STR0006 //"como também estes por motivo de recurso."
	cSTRING    := "TRH"

	Pergunte(cPERG,.F.)

	//Envia controle para a funcao SETPRINT
	WNREL:=SetPrint(cSTRING,WNREL,cPERG,TITULO,cDESC1,cDESC2,cDESC3,.F.,"")
	If nLASTKEY = 27
		Set Filter To
		DbSelectArea("TRH")
		Return
	EndIf
	SetDefault(aReturn,cSTRING)
	RptStatus({|lEND| MNTR425IMP(@lEND,WNREL,TITULO,TAMANHO)},STR0021,STR0022) //"Aguarde..."###"Processando Registros..."
	Dbselectarea("TRH")

	//Devolve variaveis armazenadas (NGRIGHTCLICK)
	NGRETURNPRM(aNGBEGINPRM)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |MNT425IMP | Autor ³ Ricardo Dal Ponte     ³ Data ³ 15/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Chamada do Relat¢rio                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR425                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTR425IMP(lEND,WNREL,TITULO,TAMANHO)

	Local nI
	Local lIntTMS 		:= GetMV("MV_INTTMS")
	Local cCompara 		:= ""
	Local oTempTable		//Tabela Temporaria

	Private cRODATXT 	:= ""
	Private nCNTIMPR 	:= 0
	Private li 			:= 80
	Private m_pag 		:= 1
	Private cNomeOri
	Private aVetor 		:= {}
	Private aTotGeral 	:= {}
	Private nAno, nMes
	Private nTotCarga 	:= 0
	Private nTotManut   := 0
	Private nTotal 		:= 0
	Private cTRB		:= GetNextAlias()   //Tabela temporaria

	Processa({|lEND| MNTR425TMP()},STR0023) //"Processando Arquivo..."

	If lnRegistro = .T.
		Return
	EndIf

	nTIPO  := IIf(aReturn[4]==1,15,18)

	CABEC1 := ""
	CABEC2 := ""

	lPri := .T.

	aDBF :={{"MOTREC", "C", 06,0},; //codigo
	{"VALPGO", "N", 15,2}}  //restituicao

	//Intancia classe FWTemporaryTable
	oTempTable  := FWTemporaryTable():New( cTRB, aDBF )
	//Cria indices
	oTempTable:AddIndex( "Ind01" , {"MOTREC"} )
	//Cria a tabela temporaria
	oTempTable:Create()

	dbSelectArea(cAliasQry)
	SetRegua(LastRec())

	lpvez := .T.
	nGR_TOTALR := 0

	/*
	1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21        22
	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	*****************************************************************************************************************************************************************************************************************************
	Filial/Grupo de Filiais
	Multa         Dt.Recebimento Dt.Infra.  Hr.Inf. AIT            CI Recurso Motivo             Sit.Rec. Dt.Pagto. Vl.Boleto %Desc. Vl.Pago. Art.Infracao     Placa     Motorista        Resp. Valor R$  Status     Tot.Restit.
	*****************************************************************************************************************************************************************************************************************************
	XXXXXXXXXXXX/XXXXXXXXXXXX
	XXXXXXXXX     99/99/9999     99/99/9999 99:99   XXXXXXXXXXXXXX XXXXXXXXXX XXXXXXXXXXXXXXXXXX XXXXXXX  99/99/9999 99999,99 9999,9 99999,99 XXXXXXXXXXXXXXXX XXXXXXXX  XXXXXXXXXXXXXXX  XXXXX 99999,99  XXXXXXXXXX 99999999,99
	XXXXXXXXX     99/99/9999     99/99/9999 99:99   XXXXXXXXXXXXXX XXXXXXXXXX XXXXXXXXXXXXXXXXXX XXXXXXX  99/99/9999 99999,99 9999,9 99999,99 XXXXXXXXXXXXXXXX XXXXXXXX  XXXXXXXXXXXXXXX  XXXXX 99999,99  XXXXXXXXXX 99999999,99
	XXXXXXXXX     99/99/9999     99/99/9999 99:99   XXXXXXXXXXXXXX XXXXXXXXXX XXXXXXXXXXXXXXXXXX XXXXXXX  99/99/9999 99999,99 9999,9 99999,99 XXXXXXXXXXXXXXXX XXXXXXXX  XXXXXXXXXXXXXXX  XXXXX 99999,99  XXXXXXXXXX 99999999,99

	Total da Restituicao 			  99999999.99
	*/
	While !Eof()
		IncProc()

		If lPri = .T.
			NgSomaLi(58)
			If FWModeAccess("TRX",3) != "C"
				@ Li,000 	 Psay STR0025  //15 //"Filial/Grupo de Filiais"
			EndIf
			NgSomaLi(58)

			@ Li,000 	 Psay STR0026	//10 //"Multa"
			@ Li,014 	 Psay STR0027	//10 //"Dt.Recebimento"
			@ Li,029 	 Psay STR0028	//10 //"Dt.Infra."
			@ Li,040 	 Psay STR0029	//6  //"Hr.Inf."
			@ Li,048 	 Psay STR0030	//14 //"AIT"
			@ Li,063 	 Psay STR0031	//10 //"CI Recurso"
			@ Li,074 	 Psay STR0032	//17 //"Motivo"
			@ Li,093 	 Psay STR0033	//7  //"Sit.Rec."
			@ Li,102 	 Psay STR0034	//10 //"Dt.Pagto."
			@ Li,112 	 Psay STR0035	//8  //"Vl.Boleto"
			@ Li,122 	 Psay STR0036	//6  //"%Desc."
			@ Li,129 	 Psay STR0037	//8  //"Vl.Pago."
			@ Li,138 	 Psay STR0038	//15 //"Art.Infracao"
			@ Li,155 	 Psay STR0039	//8  //"Placa"
			@ Li,165 	 Psay STR0040	//15 //"Motorista"
			@ Li,182 	 Psay STR0041	//5  //"Resp."
			@ Li,188 	 Psay STR0042	//8  //"Valor R$"
			@ Li,198 	 Psay STR0043	//10 //"Status"
			@ Li,209 	 Psay STR0044	//11 //"Tot.Restit."

			NgSomaLi(58)
			@ Li,000 	 Psay Replicate("-",220)
			NgSomaLi(58)

			lPri := .F.
		EndIf

		If FWModeAccess("TRX",3) != "C"
			@ Li,000 	 Psay (cALIASQRY)->TRX_FILIAL + "/" + (cALIASQRY)->TRW_DESHUB
		EndIf
		NgSomaLi(58)

		@ Li,000 	 Psay (cALIASQRY)->TRX_MULTA        Picture "@!"       //Multa       //9
		@ Li,014 	 Psay STOD((cALIASQRY)->TRX_DTREC)  Picture "99/99/9999" //Dt.Recebimento  //10
		@ Li,029 	 Psay STOD((cALIASQRY)->TRX_DTINFR) Picture "99/99/9999" //Dt.Infra    //10
		@ Li,040 	 Psay (cALIASQRY)->TRX_RHINFR       Picture "99:99"          //Hr.Inf      //6
		@ Li,048 	 Psay (cALIASQRY)->TRX_NUMAIT       Picture "@!" //AIT         //14
		@ Li,063 	 Psay (cALIASQRY)->TRX_NUMCI        Picture "@!" //CI Recur    //10


		dbSelectArea("TSD")
		dbSetOrder(1)

		If dbSeek(xFilial("TSD")+(cALIASQRY)->TRX_MOTREC)
			@ Li,074 	 Psay Substr(TSD->TSD_DESMOT, 1, 17)           Picture "@!"                      //Motivo      //17
		EndIf

		If (cALIASQRY)->TRX_SITREC = "1"
			@ Li,093 	 Psay STR0063 Picture "@!" //Sit.Rec     //7 //"Penden."
		ElseIf (cALIASQRY)->TRX_INDREC = "2"
			@ Li,093 	 Psay STR0064 Picture "@!" //Sit.Rec     //7 //"Defer."
		ElseIf (cALIASQRY)->TRX_INDREC = "3"
			@ Li,093 	 Psay STR0065 Picture "@!" //Sit.Rec     //7 //"Indef."
		Else
			@ Li,093 	 Psay STR0047 Picture "@!" //Sit.Rec     //7 //"NPossui"
		EndIf

		dbSelectArea("TSG")
		dbSetOrder(1)

		If dbSeek(xFilial("TSG")+(cALIASQRY)->TRX_MULTA+"1")
			@ Li,102 	 Psay DTOC(TSG->TSG_DTPAG)  Picture "99/99/99"  //Dt.Pagto    //8
			@ Li,113 	 Psay TSG->TSG_VALORI Picture "@E 99999.99"     //Vl.Bolet    //8
			@ Li,122 	 Psay TSG->TSG_DESCON Picture "@E 9999.9"       //%Desc.      //6
			@ Li,129 	 Psay TSG->TSG_VALPGO Picture "@E 99999.99"     //Vl.Pago.    //8
		EndIf

		@ Li,138 	 Psay SubStr((cALIASQRY)->TSH_ARTIGO,1,16) Picture "@!" //Art.Infracao //15
		@ Li,155 	 Psay (cALIASQRY)->TRX_PLACA  Picture "@!" //Placa        //8

		dbSelectArea("DA4")
		dbSetOrder(1)

		If dbSeek(xFilial("DA4")+(cALIASQRY)->TRX_CODMO)
			@ Li,165 	 Psay Substr(DA4->DA4_NOME, 1, 15) Picture "@!" //Motorista   //15
		Endif

		If lEditResp
			cCompara := (cAliasQry)->TRX_REPON
		Else
			cCompara := NGSEEK('TSH',(cAliasQry)->TRX_CODINF,1,'TSH_RESPON')
		EndIf
		If cCompara == "1"
			@ Li,182 	 Psay STR0049 Picture "@!" //Resp."        //5 //"Mot"
		ElseIf cCompara == "2"
			@ Li,182 	 Psay STR0048 Picture "@!" //Resp."        //5 //"Empr"
		EndIf

		@ Li,188 	 Psay (cALIASQRY)->TRX_VALOR Picture "@E 99999.99" //Valor       //8

		If (cALIASQRY)->TRX_STATUS = "1"
			@ Li,198 	 Psay STR0050 Picture "@!" //Status      //10 //"Registrado"
		ElseIf (cALIASQRY)->TRX_STATUS = "2"
			@ Li,198 	 Psay STR0051 Picture "@!" //Status      //10 //"Andamento"
		ElseIf (cALIASQRY)->TRX_STATUS = "3"
			@ Li,198 	 Psay STR0052 Picture "@!" //Status      //10 //"Concluido"
		EndIf

		dbSelectArea("TSG")
		dbSetOrder(1)

		nValPG :=0
		If dbSeek(xFilial("TSG")+(cALIASQRY)->TRX_MULTA+"2")
			nValPG := TSG->TSG_VALPGO
		EndIf
		@ Li,209 	 Psay nValPG Picture "@E 99999999.99" //"Tot.Rest."   //9

		nGR_TOTALR += nValPG

		NgSomaLi(58)
		NgSomaLi(58)

		dbSelectArea(cTRB)
		dbSetOrder(1)

		If !dbSeek((cALIASQRY)->TRX_MOTREC)
			RecLock((cTRB), .T.)
			(cTRB)->MOTREC := (cALIASQRY)->TRX_MOTREC
			(cTRB)->VALPGO := 0
		Else
			RecLock((cTRB), .F.)
		EndIf

		(cTRB)->VALPGO += R425RESM((cALIASQRY)->TRX_MULTA)

		MsUnLock(cTRB)

		lpvez := .F.
		dbSelectArea(cAliasQry)
		dbSkip()
	End

	If lpvez = .F.
		@ Li,000 	 Psay Replicate("-",220)
		NgSomaLi(58)

		@ Li,177 	 Psay STR0053 Picture "@!" //"Total da Restituicao"
		@ Li,209 	 Psay nGR_TOTALR Picture "@E 99999999.99"
		NgSomaLi(58)
	EndIf


	NgSomaLi(58)
	NgSomaLi(58)
	@ Li,000 	 Psay STR0054 //"Motivos de Restituicao por Valor Restituido"
	NgSomaLi(58)
	@ Li,000 	 Psay Replicate("-",80)
	NgSomaLi(58)

	@ Li,000 	 Psay STR0055 //"Motivos Restituicao"
	@ Li,050 	 Psay STR0056 //"Valor Restituido"
	NgSomaLi(58)
	@ Li,000 	 Psay Replicate("-",80)
	NgSomaLi(58)

	dbSelectArea(cTRB)
	SetRegua(LastRec())

	nGR_TOTAL := 0
	lPvezRes  := .T.
	While !Eof()
		IncProc()

		dbSelectArea("TSD")
		dbSetOrder(1)
		If dbSeek(xFilial("TSD")+(cTRB)->MOTREC)
			cDESREC := TSD->TSD_DESMOT
		Else
			cDESREC := ''
		EndIf

		If !Empty((cTRB)->MOTREC)
			@ Li,000 	 Psay Substr((cTRB)->MOTREC+" - "+cDESREC, 1, 48) Picture "@!"
			@ Li,050 	 Psay (cTRB)->VALPGO Picture "9,999,999,999.99"
			NgSomaLi(58)
		Endif

		nGR_TOTAL += (cTRB)->VALPGO

		lPvezRes  := .F.

		dbSelectArea(cTRB)
		dbSkip()
	End

	If lPvezRes  = .F.
		@ Li,000 	 Psay Replicate("-",80)
		NgSomaLi(58)
		@ Li,000 	 Psay STR0057 //"Total"
		@ Li,050 	 Psay nGR_TOTAL Picture "9,999,999,999.99"
	Endif

	oTempTable:Delete()//Deleta Arquivo temporario

	RODA(nCNTIMPR,cRODATXT,TAMANHO)

	//Devolve a condicao original do arquivo principal
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

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |MNTR425TMP| Autor ³ Ricardo Dal Ponte     ³ Data ³ 15/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Geracao do arquivo temporario                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR425                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function MNTR425TMP()
	lnRegistro := .F.

	cQuery := " SELECT TRX.TRX_FILIAL, TRW.TRW_DESHUB, TRX.TRX_MULTA , TRX.TRX_DTINFR, TRX.TRX_RHINFR, TRX.TRX_NUMAIT, "
	cQuery += "        TRX.TRX_DTREC , TRX.TRX_NUMCI , TRX.TRX_INDREC, TRX.TRX_MOTREC, TRX.TRX_CODINF, "
	cQuery += "        TRX.TRX_LOCAL , TRX.TRX_CIDINF, TRX.TRX_UFINF , TRX.TRX_PLACA , "
	cQuery += "        TRX.TRX_VALOR , TRX.TRX_DTPGTO, TRX.TRX_VALPAG, TRX.TRX_STATUS, TRX.TRX_NOTDT, "
	cQuery += "        TSH.TSH_ARTIGO, TRX.TRX_CODMO, TRX.TRX_SITREC "
	If lEditResp
		cQuery += " , TRX.TRX_REPON "
	EndIf
	cQuery += " FROM " + RetSqlName("TRX")+" TRX, "
	cQuery += "      " + RetSqlName("TSH")+" TSH, "
	cQuery += "      " + RetSqlName("TRW")+" TRW, " + RetSqlName("TSL")+" TSL "

	cQuery += " WHERE "
	cQuery += "      (TRX.TRX_DTINFR >= '"+AllTrim(DTOS(MV_PAR01))+"'"
	cQuery += " AND   TRX.TRX_DTINFR <= '"+AllTrim(DTOS(MV_PAR02))+"')"

	If MV_PAR03 = 2
		cQuery += " AND   TSH.TSH_FLGTPM  = '1'" //Transito
	ElseIf MV_PAR03 = 3
		cQuery += " AND   TSH.TSH_FLGTPM  = '2'" //Prod. Perigoso
	Endif

	If MV_PAR04 = 2
		cQuery += " AND   TRX.TRX_SITREC  = '1'" //Pendente
	ElseIf MV_PAR04 = 3
		cQuery += " AND   TRX.TRX_SITREC  = '2'" //Recurso Deferido
	ElseIf MV_PAR04 = 4
		cQuery += " AND   TRX.TRX_SITREC  = '3'" //Recurso Indeferido
	Endif

	If MV_PAR05 = 1
		cQuery += " AND   (TRX.TRX_INDREC  = '1'"  //Pela Empresa
		cQuery += " OR     TRX.TRX_INDREC  = '2')" //Pelo Motorista
	ElseIf MV_PAR05 = 2
		cQuery += " AND   TRX.TRX_INDREC  = '1'"  //Pela Empresa
	ElseIf MV_PAR05 = 3
		cQuery += " AND   TRX.TRX_INDREC  = '2'"  //Pelo Motorista
	Endif

	If !Empty(MV_PAR06)
		If FWModeAccess("TRX",3) != "C"
			cQuery += " AND   TRX.TRX_FILIAL = '"+MV_PAR06+"'"
		EndIf
	Endif

	If !Empty(MV_PAR07)
		If FWModeAccess("TRX",3) != "C"
			cQuery += " AND   TSL.TSL_HUB    = '"+MV_PAR07+"'"
		EndIf
	Endif

	If FWModeAccess("TRX",3) != "C"
		cQuery += " AND   TRX.TRX_FILIAL = TSL.TSL_FILMS "
		cQuery += " AND   TSL.TSL_HUB     = TRW.TRW_HUB "
	Endif

	//cQuery += " AND   TSH.TSH_FILIAL = TRX.TRX_FILIAL "
	cQuery += " AND   TSH.TSH_CODINF = TRX.TRX_CODINF "
	cQuery += " AND   TRX.D_E_L_E_T_ <> '*' "
	cQuery += " AND   TSH.D_E_L_E_T_ <> '*' "
	cQuery += " AND   TRW.D_E_L_E_T_ <> '*' "
	cQuery += " AND   TSL.D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	dbSelectArea(cAliasQry)
	dbGoTop()

	If Eof()
		MsgInfo(STR0059,STR0060) //"Não existem dados para montar o relatório!"###"ATENÇÃO"
		(cALIASQRY)->(dbCloseArea())
		lnRegistro := .T.
		Return
	Endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |R425RESM  | Autor ³ Ricardo Dal Ponte     ³ Data ³ 16/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega os valores de restituicoes                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR425                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function R425RESM(cCodMulta)
	Local cAliasFIL1 := GetNextAlias()
	Local cQueryFIL

	cQueryFIL := " SELECT SUM(TSG.TSG_VALPGO)  AS TOTVALPGO"
	cQueryFIL += " FROM " + RetSqlName("TSG")+" TSG "
	cQueryFIL += " WHERE "
	cQueryFIL += "       TSG.TSG_MULTA  = '"+cCodMulta+"'"
	cQueryFIL += " AND   TSG.TSG_TIPOMO = '2' "
	cQueryFIL += " AND   TSG.D_E_L_E_T_ <> '*' "
	cQueryFIL := ChangeQuery(cQueryFIL)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryFIL),cAliasFIL1, .F., .T.)

	dbSelectArea(cAliasFIL1)
	dbGoTop()

Return (cAliasFIL1)->TOTVALPGO

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNT425FL  ³ Autor ³Marcos Wagner Junior   ³ Data ³17/09/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida o parametro filial                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR425                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNT425FL()
	Local lRet

	If FWModeAccess("TRX",3) != "C"
		Mv_Par06 := "  "
	Else
		lRet := IIf(Empty(Mv_Par06),.T.,ExistCpo('SM0',SM0->M0_CODIGO+Mv_Par06))
		If !lRet
			Return .F.
		EndIf
		If !Empty(Mv_Par06)
			Mv_Par07 := "  "
		EndIf
	EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNT425Gr  ³ Autor ³Marcos Wagner Junior   ³ Data ³17/09/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida o parametro Grupo                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR425                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNT425Gr()
	Local lRet

	If FWModeAccess("TRX",3) != "C"
		Mv_Par06 := "  "
	Else
		If Empty(Mv_Par07) .And. Empty(Mv_Par06)
			lRet := .F.
		ElseIf Empty(Mv_Par07) .And. !Empty(Mv_Par06)
			lRet := .T.
		Else
			lRet := ExistCpo('TRW',Mv_Par07)
		EndIf
		If !lRet
			Return .F.
		EndIf
		If !Empty(Mv_Par07)
			Mv_Par06 := Space(If(FindFunction("FWSizeFilial"),FwSizeFilial(),Len(TRX->TRX_FILIAL)))
		EndIf
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNTR425DT ³ Autor ³Marcos Wagner Junior   ³ Data ³ 09/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida o parametro ate data                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR425                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MNTR425DT()

	Local dVarDeDt  := MV_PAR01
	Local dVarAteDt := MV_PAR02
	Local cCampo := ReadVar()

	If cCampo == "MV_PAR01"
		If !Empty(dVarAteDt) .And. dVarDeDt > dVarAteDt
			ShowHelpDlg(STR0060,;//"ATENÇÃO"
			{STR0067},2,;//"A data é inválida."
			{STR0066},2)//"Data inicio não pode ser maior que data final."
			Return .F.
		EndIf
	Else
		If !Empty(dVarDeDt) .And. dVarAteDt < dVarDeDt
			ShowHelpDlg(STR0060,;//"ATENÇÃO"
			{STR0067},2,;//"A data é inválida."
			{STR0058},2)//"Data final não pode ser inferior à data inicial!"
			Return .F.
		EndIf
	EndIf

Return .T.