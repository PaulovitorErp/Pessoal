#INCLUDE "MNTR925.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MNTR925   ³ Autor ³ Ricardo Dal Ponte     ³ Data ³ 22/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio de Servicos por Fornecedor                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/      
Function MNTR925()  
	Private cAliasQry  := GetNextAlias()
	Private lnRegistro := .F.

	Private NOMEPROG := "MNTR925"
	Private TAMANHO  := "M"
	Private aRETURN  := {STR0001,1,STR0002,1,2,1,"",1} //"Zebrado"###"Administracao"
	Private TITULO   := STR0003 //"Relatório de Serviços por Fornecedor"
	Private nTIPO    := 0
	Private nLASTKEY := 0
	Private CABEC1,CABEC2 
	Private aVETINR := {}    
	Private cPERG := "MNT925"   
	Private aPerg :={}

	SetKey( VK_F9, { | | NGVersao( "MNTR925" , 1 ) } )

	WNREL      := "MNTR925"
	LIMITE     := 132
	cDESC1     := STR0004 //"O relatório permitirá parametrização para classificar por serviço/fornecedor "
	cDESC2     := STR0005 //"ou fornecedor/serviço. Terá também filtros por fornecedor e serviço."
	cDESC3     := ""
	cSTRING    := ""       
	
	Pergunte(cPERG,.F.)
	
	MV_PAR01 := "1"
	MV_PAR03 := "ZZZZZZZZ"
	MV_PAR05 := "ZZZZZZ"
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	WNREL:=SetPrint(cSTRING,WNREL,cPERG,TITULO,cDESC1,cDESC2,cDESC3,.F.,"")
	If nLASTKEY = 27
		Set Filter To
		DbSelectArea("TS6")  
		Return
	EndIf     
	SetDefault(aReturn,cSTRING)
	RptStatus({|lEND| MNTR925IMP(@lEND,WNREL,TITULO,TAMANHO)},STR0013,STR0014) //"Aguarde..."###"Processando Registros..."
	Dbselectarea("TS6")  

Return .T.    

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |MNT925IMP | Autor ³ Ricardo Dal Ponte     ³ Data ³ 22/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Chamada do Relat¢rio                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR925                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTR925IMP(lEND,WNREL,TITULO,TAMANHO) 
	Local nI
	Private cRODATXT := ""
	Private nCNTIMPR := 0     
	Private li := 80 ,m_pag := 1    
	Private cNomeOri
	Private aVetor := {}
	Private aTotGeral := {}
	Private nAno, nMes 
	Private nTotCarga := 0, nTotManut := 0 
	Private nTotal := 0

	Processa({|lEND| MNTR925TMP()},STR0015) //"Processando Arquivo..."

	If lnRegistro = .T.
		Return
	EndIf

	nTIPO  := IIf(aReturn[4]==1,15,18)                                                                                                                                                                                               

	CABEC1 := ""
	CABEC2 := ""   

	If MV_PAR01 = 1
		R925PFORNE()
	EndIf


	If MV_PAR01 = 2
		R925PSERVI()
	EndIf

	RODA(nCNTIMPR,cRODATXT,TAMANHO)       

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Devolve a condicao original do arquivo principal             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RetIndex('TS6')
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
±±³Fun‡…o    |MNTR925TMP| Autor ³ Ricardo Dal Ponte     ³ Data ³ 22/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Geracao do arquivo temporario                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR925                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function MNTR925TMP()
	lnRegistro := .F.

	cQuery := " SELECT TS6.TS6_FORNEC, TS6.TS6_LOJA, TS6.TS6_FILIAL, TS6.TS6_SERVIC, "
	cQuery += " SA2.A2_NOME,   TS4.TS4_DESCRI, TS6.TS6_VALOR"
	cQuery += " FROM " + RetSqlName("TS6")+" TS6 "
	cQuery += " LEFT JOIN " + RetSqlName("TS4")+" TS4 ON TS4.TS4_CODSDP = TS6.TS6_SERVIC "
	cQuery += " AND   TS4.D_E_L_E_T_ <> '*' "
	cQuery += " LEFT JOIN " + RetSqlName("SA2")+" SA2 ON SA2.A2_LOJA = TS6.TS6_LOJA "
	cQuery += " AND   SA2.A2_COD = TS6.TS6_FORNEC "
	cQuery += " AND   SA2.D_E_L_E_T_ <> '*' "
	cQuery += " WHERE TS6.TS6_FORNEC >= '"+MV_PAR02+"'"
	cQuery += " AND   TS6.TS6_FORNEC <= '"+MV_PAR03+"'"
	cQuery += " AND   TS6.TS6_SERVIC >= '"+MV_PAR04+"'"
	cQuery += " AND   TS6.TS6_SERVIC <= '"+MV_PAR05+"'"
	cQuery += " AND   TS6.D_E_L_E_T_ <> '*' "
	cQuery += " group by TS6_FORNEC, TS6_LOJA, TS6_FILIAL, TS6_SERVIC, SA2.A2_NOME, TS4.TS4_DESCRI, TS6.TS6_VALOR"

	If MV_PAR01 = 1
		cQuery += " ORDER BY TS6_FORNEC, TS6_LOJA, TS6_FILIAL, TS6_SERVIC"
	EndIf

	If MV_PAR01 = 2
		cQuery += " ORDER BY TS6_SERVIC, TS6_FILIAL, TS6_FORNEC, TS6_LOJA"
	EndIf

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)  

	dbSelectArea(cAliasQry)			   
	dbGoTop()

	If Eof()
		MsgInfo(STR0016,STR0017) //"Não existem dados para montar o relatório!"###"ATENÇÃO"
		(cALIASQRY)->(dbCloseArea())
		lnRegistro := .T.
		Return
	Endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |R925PFORNE| Autor ³ Ricardo Dal Ponte     ³ Data ³ 22/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Impressao por Fornecedor                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR925                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function R925PFORNE()
	Local cQ_FORNEC := ""
	Local cQ_LOJA   := "" 
	Local nq_TTFORNEC  := 0
	Local nq_TTLOJA    := 0
	Local nG_TOTAL  := 0
	Local lPvez     := .T.

	dbSelectArea(cAliasQry)			   
	SetRegua(LastRec())

	While !Eof()
		IncProc()

		If lPvez = .T.  
			NgSomaLi(58)
			@ Li,015 	 Psay STR0018 //"Filial"
			@ Li,047 	 Psay STR0019 //"Servico"
			@ Li,055 	 Psay STR0020 //"Descricao do Servico"
			@ Li,106 	 Psay STR0021 //"Valor"

			NgSomaLi(58)
			@ Li,000 	 Psay Replicate("-",132)
			NgSomaLi(58) 

			cQ_FORNEC := (cALIASQRY)->TS6_FORNEC
			cQ_LOJA   := (cALIASQRY)->TS6_LOJA

			@ Li,000 	 Psay STR0007+".: "+(cALIASQRY)->TS6_FORNEC + " - " + (cALIASQRY)->A2_NOME //"Fornecedor"
			NgSomaLi(58) 
			@ Li,006 	 Psay STR0022+".: "+(cALIASQRY)->TS6_LOJA //"Loja"
			NgSomaLi(58) 
			NgSomaLi(58) 
			lPvez := .F.  
		EndIf

		If cQ_FORNEC <> (cALIASQRY)->TS6_FORNEC
			cQ_FORNEC := (cALIASQRY)->TS6_FORNEC
			cQ_LOJA   := (cALIASQRY)->TS6_LOJA

			NgSomaLi(58) 
			@ Li,070 	 Psay STR0023+"........:" Picture "@!" //"Total Loja"
			@ Li,097 	 Psay nq_TTLOJA  Picture "@E 999,999,999.99"
			NgSomaLi(58) 

			@ Li,070 	 Psay STR0024+"..:" Picture "@!" //"Total Fornecedor"
			@ Li,097 	 Psay nq_TTFORNEC  Picture "@E 999,999,999.99"

			nq_TTFORNEC  := 0
			nq_TTLOJA    := 0
			NgSomaLi(58) 
			NgSomaLi(58) 
			@ Li,000 	 Psay STR0007+".: "+(cALIASQRY)->TS6_FORNEC + " - " + (cALIASQRY)->A2_NOME //"Fornecedor"
			NgSomaLi(58) 
			@ Li,006 	 Psay STR0022+".: "+(cALIASQRY)->TS6_LOJA //"Loja"
			NgSomaLi(58) 
			NgSomaLi(58) 
		EndIf

		If cQ_LOJA <> (cALIASQRY)->TS6_LOJA
			cQ_LOJA   := (cALIASQRY)->TS6_LOJA

			NgSomaLi(58) 
			@ Li,070 	 Psay STR0023+"........:" Picture "@!" //"Total Loja"
			@ Li,097 	 Psay nq_TTLOJA  Picture "@E 999,999,999.99"

			nq_TTLOJA    := 0
			NgSomaLi(58) 
			NgSomaLi(58) 
		EndIF

		dbSelectArea("SM0")
		dbSetorder(1)

		cDESFIL := ""
		If dbSeek(cEmpAnt+(cALIASQRY)->TS6_FILIAL)
			cDESFIL := SM0->M0_FILIAL
		EndIf

		If !Empty((cALIASQRY)->TS6_FILIAL)
			@ Li,015 	 Psay (cALIASQRY)->TS6_FILIAL+" - "+Substr(cDESFIL,1,25) Picture "@!"
		Endif
		@ Li,047 	 Psay (cALIASQRY)->TS6_SERVIC Picture "@!"
		@ Li,055 	 Psay (cALIASQRY)->TS4_DESCRI Picture "@!"
		@ Li,097 	 Psay (cALIASQRY)->TS6_VALOR  Picture "@E 999,999,999.99"

		nq_TTFORNEC  += (cALIASQRY)->TS6_VALOR
		nq_TTLOJA    += (cALIASQRY)->TS6_VALOR
		nG_TOTAL     += (cALIASQRY)->TS6_VALOR

		NgSomaLi(58) 

		dbSelectArea(cAliasQry)			   
		dbSkip()
	End

	If lPvez = .F.
		NgSomaLi(58) 
		@ Li,070 	 Psay STR0023+"........:" Picture "@!" //"Total Loja"
		@ Li,097 	 Psay nq_TTLOJA  Picture "@E 999,999,999.99"
		NgSomaLi(58) 

		@ Li,070 	 Psay STR0024+"..:" Picture "@!" //"Total Fornecedor"
		@ Li,097 	 Psay nq_TTFORNEC  Picture "@E 999,999,999.99"
		NgSomaLi(58) 

		@ Li,000 	 Psay Replicate("-",132)
		NgSomaLi(58)
		@ Li,070 	 Psay STR0025+".......:" Picture "@!" //"Total GERAL"
		@ Li,097 	 Psay nG_TOTAL  Picture "@E 999,999,999.99"
		NgSomaLi(58)
	EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |R925PSERVI| Autor ³ Ricardo Dal Ponte     ³ Data ³ 22/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Impressao por servico                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTR925                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function R925PSERVI()
	Local cQ_SERVIC := ""
	Local nq_SERVIC := 0
	Local nG_TOTAL  := 0
	Local lPvez     := .T.

	dbSelectArea(cAliasQry)			   
	SetRegua(LastRec())

	While !Eof()
		IncProc()

		If lPvez = .T.  
			NgSomaLi(58)
			@ Li,005 	 Psay STR0018 //"Filial"
			@ Li,037 	 Psay STR0007 //"Fornecedor"
			@ Li,052 	 Psay STR0022 //"Loja"
			@ Li,058 	 Psay STR0026 //"Descricao do Fornecedor"
			@ Li,115 	 Psay STR0021 //"Valor"

			NgSomaLi(58)
			@ Li,000 	 Psay Replicate("-",132)
			NgSomaLi(58) 

			cQ_SERVIC := (cALIASQRY)->TS6_SERVIC

			@ Li,000 	 Psay STR0019+".: "+(cALIASQRY)->TS6_SERVIC + " - " + (cALIASQRY)->TS4_DESCRI //"Servico"
			NgSomaLi(58) 
			NgSomaLi(58) 
			lPvez := .F.  
		EndIf

		If cQ_SERVIC <> (cALIASQRY)->TS6_SERVIC
			cQ_SERVIC := (cALIASQRY)->TS6_SERVIC

			NgSomaLi(58) 
			@ Li,080 	 Psay STR0027+"........:" Picture "@!" //"Total Servico"
			@ Li,106 	 Psay nq_SERVIC  Picture "@E 999,999,999.99"
			NgSomaLi(58) 

			nq_SERVIC  := 0

			@ Li,000 	 Psay STR0019+".: "+(cALIASQRY)->TS6_SERVIC + " - " + (cALIASQRY)->TS4_DESCRI //"Servico"
			NgSomaLi(58) 
			NgSomaLi(58) 
		EndIf

		dbSelectArea("SM0")
		dbSetorder(1)

		cDESFIL := ""
		If dbSeek(cEmpAnt+(cALIASQRY)->TS6_FILIAL)
			cDESFIL := SM0->M0_FILIAL
		EndIf

		If !Empty((cALIASQRY)->TS6_FILIAL)
			@ Li,005 	 Psay (cALIASQRY)->TS6_FILIAL+" - "+Substr(cDESFIL,1,25) Picture "@!"
		Endif
		@ Li,037 	 Psay (cALIASQRY)->TS6_FORNEC Picture "@!"
		@ Li,052 	 Psay (cALIASQRY)->TS6_LOJA   Picture "@!"
		@ Li,058 	 Psay (cALIASQRY)->A2_NOME    Picture "@!"
		@ Li,106 	 Psay (cALIASQRY)->TS6_valor  Picture "@E 999,999,999.99"

		nq_SERVIC  += (cALIASQRY)->TS6_VALOR
		nG_TOTAL   += (cALIASQRY)->TS6_VALOR

		NgSomaLi(58) 

		dbSelectArea(cAliasQry)			   
		dbSkip()
	End

	If lPvez = .F.
		NgSomaLi(58) 
		@ Li,080 	 Psay STR0027+"........:" Picture "@!" //"Total Servico"
		@ Li,106 	 Psay nq_SERVIC  Picture "@E 999,999,999.99"
		NgSomaLi(58) 

		@ Li,000 	 Psay Replicate("-",132)
		NgSomaLi(58)
		@ Li,080 	 Psay STR0025+"..........:" Picture "@!" //"Total GERAL"
		@ Li,106 	 Psay nG_TOTAL  Picture "@E 999,999,999.99"
		NgSomaLi(58)
	EndIf
Return