#INCLUDE "rwmake.ch"
#INCLUDE "tbiconn.ch"
       
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RCTBM002 บ Autor ณ TOTVS-GO           บ Data ณ  14/03/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Cria os lancamentos de estorno/exclusao para os lancamentosบฑฑ
ฑฑบ          ณ definidos, invertendo os itens de debito e credito         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TOTVS-GO                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/                      
User Function RCTBM002()
Local cMsg, aOpc, nOpc

cMsg := "Este programa tem por objetivo a inativa็ใo dos lan็amentos de estorno jแ" + chr(13)+chr(10)
cMsg += "existentes e a cria็ใo de novos, automaticamente, invertendo d้bito e    " + chr(13)+chr(10)
cMsg += "cr้dito dos lan็amentos de inclusใo.                                     " + chr(13)+chr(10)+chr(13)+chr(10)
cMsg += "Deseja prosseguir?                                                       "

aOpc := {"Gera","Desfaz","Cancela"}

IF (nOpc:=Aviso("Aten็ao",cMsg,aOpc)) < 3
	Processa({|| atual(nOpc) })
ENDIF
Return

Static Function Atual(nOpc)
Local aLc := {}, aRec := {}, aLin := {}, xNd, cQry

// Define os lan็amentos correspondentes de inclusใo e estorno/exclusใo.
aAdd(aLc,{"500","505","Contas a Receber - Inclusao de Titulos"})
aAdd(aLc,{"501","502","Contas a Receber - Inclusao de Titulos Recebimento Antecipado (RA)"})
aAdd(aLc,{"504","529","Contas a Receber - Geracao de Titulos por Desdobramento"})
aAdd(aLc,{"506","507","Contas a Receber - Inclusao Rateio Centro de Custo Multipla Natureza"})
aAdd(aLc,{"596","588","Contas a Receber - Compensacao Contas a Receber"})
aAdd(aLc,{"508","509","Contas a Pagar - Rateio Centro de Custo Multipla Natureza"})
aAdd(aLc,{"510","515","Contas a Pagar - Inclusao de Titulos"})
aAdd(aLc,{"511","512","Contas a Pagar - Inclusao de Titulos com Rateio Simples"})
aAdd(aLc,{"513","514","Contas a Pagar - Inclusao de Titulos Pagamento Antecipado (PA)"})
aAdd(aLc,{"590","591","Contas a Pagar - Geracao de Cheques sobre Titulos baixados"})
aAdd(aLc,{"597","589","Contas a Pagar - Compensacao Contas a Pagar"})
aAdd(aLc,{"598","59A","Variacao Monetaria - Contas a Receber"})
aAdd(aLc,{"599","59B","Variacao Monetaria - Contas a Pagar"})
aAdd(aLc,{"516","557","Movimento Bancario - Inclusao Movimento a Pagar com Rateio"})
aAdd(aLc,{"517","558","Movimento Bancario - Inclusao Movimento a Receber com Rateio"})
aAdd(aLc,{"518","519","Contas a Pagar - Baixa de Titulos por Vendor"})
aAdd(aLc,{"520","527","Baixa Contas a Receber em Carteira"})
aAdd(aLc,{"530","531","Baixa Contas a Pagar"})
aAdd(aLc,{"562","564","Movimento Bancario - Inclusao de Movimento a Pagar"})
aAdd(aLc,{"563","565","Movimento Bancario - Inclusao de Movimento a Receber"})
aAdd(aLc,{"610","630","Documento de Saida - Inclusao de Documento Itens"})
aAdd(aLc,{"620","635","Documento de Saida - Inclusao de Documento Total"})
aAdd(aLc,{"650","655","Documento de Entrada - Inclusao de Documento Entrada Itens"})
aAdd(aLc,{"651","656","Documento de Entrada - Inclusao de Documento Entrada Itens"})
aAdd(aLc,{"660","665","Documento de Entrada - Inclusao de Documento Entrada Total"})
aAdd(aLc,{"755","756","CIAP - Apropriacao Mensal"})
aAdd(aLc,{"801","805","Ativo Fixo - Implantacao de Bem - Aquisicao"})
aAdd(aLc,{"803","807","Ativo Fixo - Implantacao de Bem - Adiantamento"})
aAdd(aLc,{"810","814","Ativo Fixo - Baixa do registro - Adiantamento"})
aAdd(aLc,{"812","816","Ativo Fixo - Baixa do registro - Adiantamento"})
aAdd(aLc,{"820","825","Ativo Fixo - Calculo da Depreciacao"})

IF nOpc == 1
	procRegua(len(aLc))

	BEGINSQL ALIAS 'TRB'
		column QTD as Numeric (3,0)

		SELECT COUNT(*) QTD
		  FROM %table:CT5% CT5
		 WHERE CT5.%notdel%
		   AND CT5_ORIGEM LIKE '%AUTO-LCPD - %'
	ENDSQL

	xNd := TRB->QTD
	TRB->( dbCloseArea() )
	IF xNd > 0
		Alert("Esta rotina jแ foi utilizada. Execute-a com a op็ใo 'Desfaz' primeiro.","Aten็ใo")
		Return
	ENDIF

	FOR nX := 1 TO len(aLc)
		incProc(aLc[nX][3])
		// Desativa os lan็amentos existentes de estorno para a linha atual
		cQry := "UPDATE " + retSqlName("CT5")
		cQry += "   SET CT5_SEQUEN = 'X' || subStr(CT5_SEQUEN,2,2), CT5_STATUS = '2'"
		cQry += " WHERE D_E_L_E_T_ <> '*' "
		cQry += "   AND CT5_SEQUEN LIKE '0%' "
		cQry += "   AND CT5_STATUS <> '2' "
		cQry += "   AND CT5_LANPAD = '" + aLc[nX][2] + "' "
		Begin Transaction
			TcSqlExec(cQry)
		End Transaction
		aRec := {}

		// Gera os lan็amentos de estorno, invertendo as contas
		aRec := {}
		CT5->( dbSeek(xFilial("CT5")+aLc[nX][1]) )
		CT5->( dbEval({|| aAdd(aRec,recNo()) },,{|| CT5_LANPAD == aLc[nX][1] }) ) // Pega todos os Recnos
		FOR nY := 1 TO len(aRec) // Trata um por um
			CT5->(dbGoto(aRec[nY]))
			aLin := {CT5->CT5_FILIAL,	CT5->CT5_LANPAD,	CT5->CT5_SEQUEN,	CT5->CT5_DESC,		CT5->CT5_DC,		;
						CT5->CT5_DEBITO,	CT5->CT5_CREDIT,	CT5->CT5_MOEDAS,	CT5->CT5_VLR01,	CT5->CT5_VLR02,	;
						CT5->CT5_VLR03,	CT5->CT5_VLR04,	CT5->CT5_VLR05,	CT5->CT5_HIST,		CT5->CT5_HAGLUT,	;
						CT5->CT5_CCD,		CT5->CT5_CCC,		CT5->CT5_ORIGEM,	CT5->CT5_INTERC,	CT5->CT5_ITEMD,	;
						CT5->CT5_ITEMC,	CT5->CT5_CLVLDB,	CT5->CT5_CLVLCR,	CT5->CT5_ATIVDE,	CT5->CT5_ATIVCR,	;
						CT5->CT5_TPSALD,	CT5->CT5_MOEDLC,	CT5->CT5_SBLOTE,	CT5->CT5_DTVENC,	CT5->CT5_STATUS,	;
						CT5->CT5_ROTRAS,	CT5->CT5_TABORI,	CT5->CT5_RECORI}
			IF recLock("CT5",.T.)
				CT5->CT5_FILIAL := aLin[01]
				CT5->CT5_LANPAD := aLc[nX][2]
				CT5->CT5_SEQUEN := aLin[03]
				CT5->CT5_DESC	 := "CANC. " + aLin[04]
				CT5->CT5_DC		 := IIF(aLin[05]=="1","2",IIF(aLin[05]=="2","1",aLin[05])) // Inverte
				CT5->CT5_DEBITO := aLin[07] // Inverte
				CT5->CT5_CREDIT := aLin[06] // Inverte
				CT5->CT5_MOEDAS := aLin[08]
				CT5->CT5_VLR01	 := aLin[09]
				CT5->CT5_VLR02	 := aLin[10]
				CT5->CT5_VLR03	 := aLin[11]
				CT5->CT5_VLR04	 := aLin[12]
				CT5->CT5_VLR05	 := aLin[13] 
				IF (Len(RTrim("'CANC. '+" + aLin[14]))>TamSx3("CT5_HIST")[1]) .or. (Len(RTrim("'CANC. '+" + aLin[15]))>TamSx3("CT5_HAGLUT")[1]) 
				  Alert("LP: ["+aLc[nX][2] + "/" + aLin[03]+"] O campo Historico foi truncado. Aumente o tamanho dos campos[CT5_HIST/CT5_HAGLUT] .")
				Endif 
				if Upper(Substr(aLin[14],1,5))=='LEFT('
				  cHist:="LEFT('CANC. '+"+Substr(aLin[14],6)
				else 
				  cHist:="'CANC. '+" + aLin[14]
				endif
				CT5->CT5_HIST	 := cHist
				if !empty(aLin[15])
				  if Upper(Substr(aLin[15],1,5))=='LEFT('
				    cHist:="LEFT('CANC. '+"+Substr(aLin[15],6)
				  else 
				    cHist:="'CANC. '+" + aLin[15]
				  endif
				else 
				  cHist:=" "   
				endif
				CT5->CT5_HAGLUT := cHist
				CT5->CT5_CCD	 := aLin[17] // Inverte
				CT5->CT5_CCC	 := aLin[16] // Inverte
				CT5->CT5_ORIGEM := "'AUTO-LCPD - " + aLc[nX][2] + "/" + aLin[03] + " - Estorno do lcto: " + aLc[nX][1] + "/" + aLin[03] + "'"
				CT5->CT5_INTERC := aLin[19]
				CT5->CT5_ITEMD	 := aLin[21] // Inverte
				CT5->CT5_ITEMC	 := aLin[20] // Inverte
				CT5->CT5_CLVLDB := aLin[23] // Inverte
				CT5->CT5_CLVLCR := aLin[22] // Inverte
				CT5->CT5_ATIVDE := aLin[25] // Inverte
				CT5->CT5_ATIVCR := aLin[24] // Inverte
				CT5->CT5_TPSALD := aLin[26]
				CT5->CT5_MOEDLC := aLin[27]
				CT5->CT5_SBLOTE := aLin[28]
				CT5->CT5_DTVENC := aLin[29]
				CT5->CT5_STATUS := aLin[30]
				CT5->CT5_ROTRAS := aLin[31]
				CT5->CT5_TABORI := aLin[32]
				CT5->CT5_RECORI := aLin[33]
				CT5->(msUnlock())
			ENDIF
		NEXT
	NEXT
ELSE
	procRegua(2)
	incProc('Apagando registros gerados')
	cQry := "UPDATE " + retSqlName("CT5")
	cQry += "   SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
	cQry += " WHERE D_E_L_E_T_ <> '*' "
	cQry += "   AND CT5_ORIGEM LIKE '%AUTO-LCPD - %' "
	Begin Transaction
		TcSqlExec(cQry)
	End Transaction
	incProc('Retornando registros anteriores')
	cQry := "UPDATE " + retSqlName("CT5")
	cQry += "   SET CT5_SEQUEN = '0' || subStr(CT5_SEQUEN,2,2), CT5_STATUS = '1'"
	cQry += " WHERE D_E_L_E_T_ <> '*' "
	cQry += "   AND CT5_SEQUEN LIKE 'X%' "
	cQry += "   AND CT5_STATUS = '2' "
	Begin Transaction
		TcSqlExec(cQry)
	End Transaction
ENDIF

Return
/*
CT5_FILIAL	C	2		
CT5_LANPAD	C	3		
CT5_SEQUEN	C	3		
CT5_DESC  	C	40		
CT5_DC    	C	1		
CT5_DEBITO	C	200	
CT5_CREDIT	C	200	
CT5_MOEDAS	C	5		"12222"
CT5_VLR01 	C	200	
CT5_VLR02 	C	200	
CT5_VLR03 	C	200	
CT5_VLR04 	C	200	
CT5_VLR05 	C	200	
CT5_HIST  	C	200	
CT5_HAGLUT	C	200	
CT5_CCD   	C	200	
CT5_CCC   	C	200	
CT5_ORIGEM	C	100	
CT5_INTERC	C	1		"2"
CT5_ITEMD 	C	200	
CT5_ITEMC 	C	200	
CT5_CLVLDB	C	200	
CT5_CLVLCR	C	200	
CT5_ATIVDE	C	200	
CT5_ATIVCR	C	200	
CT5_TPSALD	C	1		"1"
CT5_MOEDLC	C	2		
CT5_SBLOTE	C	3		
CT5_DTVENC	C	200	
CT5_STATUS	C	1		
CT5_ROTRAS	C	60		
CT5_TABORI	C	100	
CT5_RECORI	C	100	
*/
