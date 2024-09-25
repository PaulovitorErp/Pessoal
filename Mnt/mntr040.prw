#INCLUDE "MNTR040.ch"
#INCLUDE "PROTHEUS.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR040
Mapa de Consumo Diario de Combustivel

@type function
@source MNTR040.prw
@author Felipe N. Welter
@since 04/12/2008
@sample MNTR040()

@return Nil
/*/
//---------------------------------------------------------------------
Function MNTR040()

	Local cString    := "TQN"
	Local cDesc1     := STR0001 //"Relatorio de apresentacao do Mapa de Consumo Diario de Combustivel."
	Local cDesc2     := STR0002 //"Atraves dos parametros o usuario podera efetuar a selecao desejada."
	Local cDesc3     := ""
	Local wnrel      := "MNTR040"

	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 95 )

		Private aReturn  := { STR0003, 1,STR0004, 2, 2, 1, "",1 } //"Zebrado"###"Administracao"
		Private nLastKey := 0
		Private titulo   := STR0005 //"Mapa de Consumo Diario de Combustivel"
		Private Tamanho  := "G"
		Private aPerg    := {}
		Private cPerg    := "MNT040"

		Private cContab  := GetMv("MV_MCONTAB")
		Private vCampoCC := {}

		If cContab == "CTB"
			vCampoCC := {"CTT","CTT_CUSTO","CTT_OPERAC","CTT_DESC01"}
		ElseIf cContab == "CON"
			vCampoCC := {"SI3","I3_CUSTO","I3_OPERAC","I3_DESC"}
		EndIf

		//Variaveis utilizadas para parametros
		//mv_par01 - De Data Abastecimento
		//mv_par02 - Ate Data Abastecimento
		//mv_par03 - De Familia
		//mv_par04 - Ate Familia
		//mv_par05 - De Modelo
		//mv_par06 - Ate Modelo
		//mv_par07 - De Centro de Custo
		//mv_par08 - Ate Centro de Custo
		//mv_par09 - De Bem
		//mv_par10 - Ate Bem
		Pergunte(cPerg,.F.)

		//Envia controle para a funcao SETPRINT
		wnrel := SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"")
		If nLastKey == 27
			Set Filter To
			Return
		EndIf
		SetDefault(aReturn,cString)
		RptStatus({|lEnd| R040Imp(@lEnd,wnRel,titulo,tamanho)},titulo)

	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} R040Imp
Chamada do Relatório

@type Static Function
@source MNTR040.prw
@author Felipe N. Welter
@since 04/12/2008
@sample R040Imp()

@return Nil
/*/
//---------------------------------------------------------------------
Static Function R040Imp(lEnd,wnRel,titulo,tamanho)

	Local cRodaTxt := ""
	Local cUndMed  := ""
	Local cTipCont := ""
	Local cUM      := ""
	Local cUnMedia := ""
	Local nCntImpr := 0
	Local nMediaR  := 0
	Local nTotMedia:= 0 //Variavel que recebe o valor total das médias

	Private cabec1   := ""
	Private cabec2   := ""
	Private nomeprog := "MNTR040"
	Private ntipo    := 0

	//Variaveis totalizadoras
	//Possuem os nomes KM e Litro como padrao, mas sao utilizadas conforme as unidades da tabela
	Private aTLitro  := {}
	Private nTKmRod  := 0
	Private nTValor  := 0

	//Variável de quilometragem anterior do bem para utilização na função M040KMANT()
	Private nKmAnt   := 0

	Private cAliasQry := GetNextAlias()

	BeginSql Alias cAliasQry

		SELECT TQN.TQN_TANQUE, TQN.TQN_CODCOM, TQN.TQN_DTABAS, TQN.TQN_HRABAS, TQN.TQN_QUANT,
			TQN.TQN_VALTOT, TQN.TQN_VALUNI, TQN.TQN_DTDIGI, TQN.TQN_FROTA, ST9.T9_FILIAL,
			ST9.T9_MEDMIN, ST9.T9_CODBEM,  ST9.T9_TIPMOD, ST9.T9_CCUSTO, ST9.T9_NOME, ST9.T9_PLACA,
			ST9.T9_TIPMOD, ST9.T9_CAPMAX, ST9.T9_MEDIA, STP.TP_CODBEM, STP.TP_POSCONT,
			STP.TP_ACUMCON, TQM.TQM_CODCOM, TQM.TQM_CONVEN, TQM.TQM_FILIAL, TQM.TQM_NOMCOM,
			TQM.TQM_UM, ST6.T6_TIPO1, ST6.T6_MEDIA1, TT8.TT8_CAPMAX, TT8.TT8_MEDIA, TT8.TT8_MEDMIN
		FROM %table:TQN% TQN
		JOIN %table:ST9% ST9
			ON TQN.TQN_FROTA = ST9.T9_CODBEM
			AND ST9.T9_FILIAL = %xFilial:ST9%
			AND ST9.%NotDel%
		JOIN %table:STP% STP
			ON STP.TP_CODBEM = TQN.TQN_FROTA
			AND STP.TP_DTLEITU = TQN.TQN_DTABAS
			AND STP.TP_HORA = TQN.TQN_HRABAS
			AND STP.TP_TIPOLAN = 'A'
			AND STP.TP_FILIAL = %xFilial:STP%
			AND STP.%NotDel%
		JOIN %table:ST6% ST6
			ON ST9.T9_CODFAMI = ST6.T6_CODFAMI
			AND ST6.T6_FILIAL = %xFilial:ST6%
			AND ST6.%NotDel%
		JOIN %table:TT8% TT8
			ON ST9.T9_CODBEM = TT8.TT8_CODBEM
			AND TQN.TQN_CODCOM = TT8.TT8_CODCOM
			AND TT8.TT8_TPCONT = '1'
			AND TT8.TT8_FILIAL = %xFilial:TT8%
			AND TT8.%NotDel%
		JOIN %table:TQM% TQM
			ON TQN.TQN_CODCOM = TQM.TQM_CODCOM
			AND TQM.TQM_FILIAL = %xFilial:TQM%
			AND TQM.%NotDel%
		JOIN %table:TQF% TQF
			ON TQN.TQN_POSTO = TQF.TQF_CODIGO
			AND TQN.TQN_LOJA = TQF.TQF_LOJA
			AND TQF.TQF_FILIAL = %xFilial:TQF%	
			AND TQF.%NotDel%
		WHERE TQN.TQN_DTABAS BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
			AND ST9.T9_CODFAMI BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
			AND ST9.T9_TIPMOD BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
			AND ST9.T9_CCUSTO BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08%
			AND ST9.T9_CODBEM BETWEEN %Exp:MV_PAR09% AND %Exp:MV_PAR10%
			AND TQF.TQF_CONVEN = TQM.TQM_CONVEN
			AND TQN.TQN_FILIAL = %xFilial:TQN%
			AND TQN.%NotDel%
		ORDER BY ST9.T9_CODBEM, TQN.TQN_CODCOM, TQN.TQN_TANQUE, TQN.TQN_DTABAS, TQN.TQN_HRABAS

	EndSql 

	//Contadores de linha e pagina
	Private li := 80 ,m_pag := 1

	//Verifica se deve comprimir ou nao
	nTipo  := IIF(aReturn[4]==1,15,18)

	//Monta os Cabecalhos
	cabec1 := " "
	cabec2 := " "

	//If ST6Tipo
	//          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8
	//0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	//
	//Periodo: de 99/99/99 ate 99/99/99
	//Frota: xxxxxxxxxxxxxxxx - xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	//Placa: xxxxxxxx - xxxxxxxxxxxxxxxxxxxx
	////Centro de Custo: xxxxxxxxx - xxxxxxxxxxxxxxxxxxxxxxxxx
	//
	//                                                                                                                ------------------------Parametros de Consumo------------------------
	//                                                                                                                Cap.Tanque: 9999999 Media: 999,99 | 999,99 Combust: xxx (Combustivel)
	//                                                                                                                ---------------------------------------------------------------------
	//_____________________________________________________________________________________________________________________________________________________________________________________
	//    Data    Hora         Contador        Realizado       Incremento           Abastecido                  Media              Valor Total        Vl. Unit.  Data Lcto.     Abast. Acum.
	//99/99/9999  99:99      999.999.999  999.999.999 XXX  999.999.999 XXX  999.999.999,999 XXX  999.999.999,99 XXX/XX  999.999.999.999.999,999  999.999.999,999    99/99/99  999.999.999,999
	//99/99/9999  99:99      999.999.999  999.999.999 XXX  999.999.999 XXX  999.999.999,999 XXX  999.999.999,99 XXX/XX  999.999.999.999.999,999  999.999.999,999    99/99/99  999.999.999,999
	//99/99/9999  99:99      999.999.999  999.999.999 XXX  999.999.999 XXX  999.999.999,999 XXX  999.999.999,99 XXX/XX  999.999.999.999.999,999  999.999.999,999    99/99/99  999.999.999,999

	//Total Veiculo: XXXXXXXXXXXXXXXX / Tanque: 99       999.999.999 XXX  999.999.999,999 XXX  999.999.999,99 XXX/XX  999.999.999.999.999,999
	//Utimo Abast. Km Real: 999.999.999 em 99/99/99
	//
	//
	//Else
	//          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8
	//0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	//
	//Periodo: de 99/99/99 ate 99/99/99
	//Frota: xxxxxxxxxxxxxxxx - xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	//Placa: xxxxxxxx - xxxxxxxxxxxxxxxxxxxx
	////Centro de Custo: xxxxxxxxx - xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	//
	//                                                                                                                ------------------------Parametros de Consumo------------------------
	//                                                                                                                Cap.Tanque: 9999999 Media: 999,99 | 999,99 Combust: xxx (Combustivel)
	//                                                                                                                ---------------------------------------------------------------------
	//_____________________________________________________________________________________________________________________________________________________________________________________
	//    Data   Hora         Contador    Realizado   Incremento       Abastecido           Media              Valor Total        Vl. Unit.   Data Lcto.     Abast. Acum.
	//_____________________________________________________________________________________________________________________________________________________________________________________
	//99/99/99  99:99      999.999.999  999.999.999  999.999.999  999.999.999,999  999.999.999,99  999.999.999.999.999,999   999.999.999,999    99/99/99  999.999.999,999
	//99/99/99  99:99      999.999.999  999.999.999  999.999.999  999.999.999,999  999.999.999,99  999.999.999.999.999,999   999.999.999,999    99/99/99  999.999.999,999
	//99/99/99  99:99      999.999.999  999.999.999  999.999.999  999.999.999,999  999.999.999,99  999.999.999.999.999,999   999.999.999,999    99/99/99  999.999.999,999
	//
	//Total Veiculo: XXXXXXXXXXXXXXXX / Tanque: 99   999.999.999  999.999.999,999  999.999.999,99  999.999.999.999.999,999
	//Utimo Abast. Km Real: 999.999.999 em 99/99/99

	DbSelectArea(cAliasQry)
	DbGotop()
	ProcRegua(LastRec(),STR0016,STR0017) //"Aguarde..."###"Processando Registros..."
	cFrota  := " "
	cTanque := " "
	cComb := IIf(Type("cComb") != "U" , cComb, "")

	While !Eof()

		IncProc()

		If lEnd
			@ PROW()+1,001 Psay STR0018 //"CANCELADO PELO OPERADOR"
			Exit
		EndIf

		//Imprime cabecalho por Frota
		If cFrota != (cAliasQry)->T9_CODBEM

			cFrota   := (cAliasQry)->T9_CODBEM
			cTanque  := " "
			cTipCont := ""
			cUM      := ""
			cUndMed  := ""
			nTKmRod  := 0
			nTLitro  := 0
			nTValor  := 0
			nMediaR  := 0
			nTotMedia:= 0


			Li := 58 //Quebra pagina
			NgSomaLi(58)

			@ Li,000 Psay STR0019+DTOC(MV_PAR01)+STR0020+DTOC(MV_PAR02) //"Período: de "###" ate "
			NgSomaLi(58)

			@ Li,000 Psay STR0021+AllTrim((cAliasQry)->T9_CODBEM)+" - "+(cAliasQry)->T9_NOME //"Frota: "
			NgSomaLi(58)

			@ Li,000 Psay STR0022+AllTrim((cAliasQry)->T9_PLACA)+" - "+(cAliasQry)->T9_TIPMOD //"Placa: "
			NgSomaLi(58)

			@ Li,000 Psay STR0023+AllTrim((cAliasQry)->T9_CCUSTO)+" - "+NGSEEK(vCampoCC[1],(cAliasQry)->T9_CCUSTO,1,vCampoCC[4]) //"Centro de Custo: "
			NgSomaLi(58)
		EndIf
		//Imprime cabecalho por Tanque
		If (cComb != (cAliasQry)->TQN_CODCOM) .Or. (!Empty((cAliasQry)->TQN_TANQUE) .And. cTanque <> (cAliasQry)->TQN_TANQUE)

			cTanque := (cAliasQry)->TQN_TANQUE

			//Parametros de Consumo
			cParCons1 := STR0024 //"Parametros de Consumo"

			cParCons2 := STR0025 + AllTrim(Transform( (cAliasQry)->TT8_CAPMAX, "@E 9,999,999" ) )+; //"Cap.Tanque: "
						STR0026 + AllTriM(Transform( (cAliasQry)->TT8_MEDIA, "@E 999.99" ) )+; //"   Media: "
						" | " + AllTrim(Transform((cAliasQry)->TT8_MEDMIN,"@E 999.99"))+;
						STR0027 + (cAliasQry)->TQM_CODCOM + "(" + Capital( AllTrim( (cAliasQry)->TQM_NOMCOM ) ) + ")" //"   Combust: "
			cTra1 := Replicate('-',1+(Len(cParCons2)-Len(cParCons1))/2)+cParCons1+Replicate('-',1+(Len(cParCons2)-Len(cParCons1))/2)
			@ Li,162-(Len(cParCons2)/2) Psay cTra1
			NgSomaLi(58)
			@ Li,162-(Len(cParCons2)/2) Psay cParCons2
			NgSomaLi(58)
			@ Li,162-(Len(cParCons2)/2) Psay Replicate("-",Len(cTra1))
			NgSomaLi(58)

			If !Empty((cAliasQry)->T6_MEDIA1)
				cTipCont := AllTrim((cAliasQry)->T6_TIPO1)
				cUM      := AllTrim((cAliasQry)->TQM_UM) //AllTrim((cAliasQry)->T6_UNIDAD1)
				cUndMed  := AllTrim((cAliasQry)->T6_MEDIA1)
				cCabec1  := STR0028+Space(8)+STR0029+Space(10)+STR0051+Space(8)+STR0031+Space(7)+STR0052+Space(13)+STR0033+Space(18)+; //"Data"###"Hora"###"Contador"###"Realizado"###"Incremento"##"Abastecido"
							STR0034+Space(13)+STR0053+Space(08)+STR0054+Space(5)+STR0037+Space(3)+STR0055 //"Media"###"Valor Total"###"Vl. Unit."###"Data Lcto."###"Abast. Acum."
				@ Li,000 Psay Replicate("_",220)
				NgSomaLi(58)

				@ Li,000 Psay cCabec1
				NgSomaLi(58)

				@ Li,000 Psay Replicate("_",220)
				NgSomaLi(58)
			Else
				cCabec1 := STR0028+Space(8)+STR0029+Space(10)+STR0051+Space(4)+STR0031+Space(3)+STR0052+Space(7)+STR0033+Space(11)+; //"Data"###"Hora"###"Contador"###"Realizado"###"Incremento"###"Abastecido"
						   STR0034+Space(13)+STR0053+Space(9)+STR0054+Space(5)+STR0037+Space(3)+Alltrim(STR0055) //"Media"###"Valor Total"###"Vl. Unit."###"Data Lcto."###"Abast. Acum."
				@ Li,000 Psay Replicate("-",220)
				NgSomaLi(58)

				@ Li,000 Psay Alltrim(cCabec1)
				NgSomaLi(58)

				@ Li,000 Psay Replicate("-",220)
				NgSomaLi(58)
			EndIf
			
		EndIf

		If !Empty((cAliasQry)->T6_MEDIA1)

			nKmRod   := M040KMANT((cAliasQry)->TQN_DTABAS,(cAliasQry)->TQN_HRABAS,(cAliasQry)->T9_FILIAL,(cAliasQry)->T9_CODBEM)
			nLtAcu   := M040LTACU((cAliasQry)->TQN_DTABAS,(cAliasQry)->TQN_HRABAS,(cAliasQry)->T9_FILIAL,(cAliasQry)->T9_CODBEM)
			cUnMedia := MNTUndCont(cTipCont,AllTrim((cAliasQry)->TQM_UM),cUndMed)

			If cUndMed = '1'
				nMediaR := nKmRod/(cAliasQry)->TQN_QUANT
			ElseIf cUndMed = '2'
				nMediaR := (cAliasQry)->TQN_QUANT/nKmRod
			EndIf

			@ Li,000 Psay STOD((cAliasQry)->TQN_DTABAS)
			@ Li,012 Psay (cAliasQry)->TQN_HRABAS Picture "99:99"
			@ Li,023 Psay (cAliasQry)->TP_POSCONT Picture "@E 999,999,999"
			@ Li,036+3-Len(cTipCont) Psay (cAliasQry)->TP_ACUMCON Picture "@E 999,999,999"
			@ Li,048+3-Len(cTipCont) Psay cTipCont
			@ Li,053+3-Len(cTipCont) Psay nKmRod Picture "@E 999,999,999"
			@ Li,065+3-Len(cTipCont) Psay cTipCont
			@ Li,070+6-Len(cTipCont) Psay (cAliasQry)->TQN_QUANT Picture "@E 999,999,999.999"
			@ Li,086+5-Len(cUM) Psay cUM
			@ Li,091+8-Len(cUnMedia) Psay nMediaR Picture "@E 999,999,999.99"
			@ Li,106+8-Len(cUnMedia) Psay cUnMedia
			@ Li,115 Psay (cAliasQry)->TQN_VALTOT Picture "@E 999,999,999,999,999."+Replicate('9',TAMSX3("TQN_VALTOT")[2])
			@ Li,140 Psay (cAliasQry)->TQN_VALUNI Picture "@E 999,999,999."+Replicate('9',TAMSX3("TQN_VALUNI")[2])
			@ Li,160 Psay STOD((cAliasQry)->TQN_DTDIGI)
			@ Li,170 Psay nLtAcu Picture "@E 999,999,999.999"
			NgSomaLi(58)

		Else

			nKmRod := M040KMANT((cAliasQry)->TQN_DTABAS,(cAliasQry)->TQN_HRABAS,(cAliasQry)->T9_FILIAL,(cAliasQry)->T9_CODBEM)
			nLtAcu := M040LTACU((cAliasQry)->TQN_DTABAS,(cAliasQry)->TQN_HRABAS,(cAliasQry)->T9_FILIAL,(cAliasQry)->T9_CODBEM)
			nMediaR := nKmRod/(cAliasQry)->TQN_QUANT
			@ Li,000 Psay STOD((cAliasQry)->TQN_DTABAS)
			@ Li,012 Psay (cAliasQry)->TQN_HRABAS Picture "99:99"
			@ Li,023 Psay (cAliasQry)->TP_POSCONT Picture "@E 999,999,999"
			@ Li,036 Psay (cAliasQry)->TP_ACUMCON Picture "@E 999,999,999"
			@ Li,049 Psay nKmRod Picture "@E 999,999,999"
			@ Li,062 Psay (cAliasQry)->TQN_QUANT Picture "@E 999,999,999.999"
			@ Li,079 Psay nMediaR Picture "@E 999,999,999.99"
			@ Li,094 Psay (cAliasQry)->TQN_VALTOT Picture "@E 999,999,999,999,999."+Replicate('9',TAMSX3("TQN_VALTOT")[2])
			@ Li,120 Psay (cAliasQry)->TQN_VALUNI Picture "@E 999,999,999."+Replicate('9',TAMSX3("TQN_VALUNI")[2])
			@ Li,140 Psay STOD((cAliasQry)->TQN_DTDIGI)
			@ Li,150 Psay nLtAcu Picture "@E 999,999,999.999"
			NgSomaLi(58)

		EndIf

		nTKmRod += nKmRod
		nTLitro += (cAliasQry)->TQN_QUANT
		nTValor += (cAliasQry)->TQN_VALTOT

		cComb := (cAliasQry)->TQN_CODCOM 

		DbSelectArea(cAliasQry)
		DbSkip()

		//--------------------------------------------
		// Trecho de totais
		//--------------------------------------------
		If cFrota != (cAliasQry)->T9_CODBEM .OR. cTanque != (cAliasQry)->TQN_TANQUE .Or. cComb != (cAliasQry)->TQN_CODCOM
			If !Empty( cUnMedia )

				nTotMedia := IIf( cUnMedia == '1', ( nTKmRod / nTLitro ), ( nTLitro / nTKmRod ) )

				NgSomaLi(58)
				@ Li,000 Psay STR0044+AllTrim(cFrota) + " / " + STR0045 + cTanque //"Total Veiculo: "###"Tanque: "
				@ Li,053+3-Len(cTipCont) Psay nTKmRod Picture "@E 999,999,999"
				@ Li,065+3-Len(cTipCont) Psay cTipCont
				@ Li,073+3-Len(cTipCont) Psay nTLitro Picture "@E 999,999,999.999"
				@ Li,088+3-Len(cUM) Psay cUM
				@ Li,93+6-Len(cUnMedia)  Psay nTotMedia Picture "@E 999,999,999.99"
				@ Li,108+6-Len(cUnMedia) Psay cUnMedia
				@ Li,116 Psay nTValor Picture "@E 99,999,999,999,999."+Replicate('9',TAMSX3("TQN_VALTOT")[2])
			Else

				nTotMedia := ( nTKmRod / nTLitro )

				NgSomaLi(58)
				@ Li,000 Psay STR0044+AllTrim(cFrota) + " / " + STR0045 + cTanque  //"Total Veiculo: "###"Tanque: "
				@ Li,049 Psay nTKmRod Picture "@E 999,999,999"
				@ Li,062 Psay nTLitro Picture "@E 999,999,999.999"
				@ Li,079 Psay nTotMedia Picture "@E 999,999,999.99"
				@ Li,095 Psay nTValor Picture "@E 99,999,999,999,999."+Replicate('9',TAMSX3("TQN_VALTOT")[2])
			EndIf

			NgSomaLi(58)
			@ Li,000 Psay STR0046+STR0056+AllTrim(Transform(RetUltAbas(cFrota,cComb)[1],"@E 999,999,999"))+; //"Utimo Abast. "##"Realizado: "
			STR0049+DToC(RetUltAbas(cFrota,cComb)[2]) //" em "
			NgSomaLi(58)
			NgSomaLi(58)
			// Zera a variável de quilometragem anterior pois irá para outro tanque do bem ou outro bem.
			nKmAnt   := 0
		EndIf

	End
	(cAliasQry)->(DbCloseArea())
	Roda(nCntImpr,cRodaTxt,Tamanho)

	//Devolve a condicao original do arquivo principal
	Set Filter To
	Set device to Screen
	If aReturn[5] = 1
		Set Printer To
		dbCommitAll()
		OurSpool(wnrel)
	EndIf
	MS_FLUSH()

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR040DT
Valida os parametros de/ate Data de Abastecimento

@type function
@source MNTR040.prw
@author Felipe N. Welter
@since 04/12/2008
@sample MNTR040DT()

@return Boolean
/*/
//---------------------------------------------------------------------
Function MNTR040DT()

	If MV_PAR02 < MV_PAR01
		MsgStop(STR0050) //"Data final não pode ser inferior à data inicial!"
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} M040KMANT
Busca abastecimento anterior e retorna KM Rodado

@type function
@source MNTR040.prw
@author Felipe N. Welter
@since 05/12/2008
@param	dData - Data do abastecimento atual
cHora - Hora do abastecimento atual
cFilBem - Filial do Veiculo/Bem do abastecimento
cCodBem - Codigo do Veiculo/Bem do abastecimento
@sample M040KMANT()

@return nKmRod - Quantidade de KM Rodado entre os 2 abastecimentos
/*/
//---------------------------------------------------------------------
Function M040KMANT(dData,cHora,cFilBem,cCodBem)

	Local nKmRod := 0

	nKmAtual := (cAliasQry)->TP_ACUMCON

	If !Eof() .And. !Bof()
		If cCodBem == (cAliasQry)->TQN_FROTA

			// Caso a quilometragem anterior (nKmAnt) seja diferente de 0 ele efetua o cálculo para verficar a quilometragem rodada
			nKmRod := fBuscaIncr(dData,cHora,nKmAtual)

			// Grava a variável de quilometragem anterior com o contador acumulado de acordo com a query
			nKmAnt := (cAliasQry)->TP_ACUMCON
		EndIf
	EndIf

Return nKmRod

//---------------------------------------------------------------------
/*/{Protheus.doc} M040LTACU
Retorna quantidade de (litros) acumulados na vida do bem

@type function
@source MNTR040.prw
@author Felipe N. Welter
@since 05/12/2008
@param	dData - Data do abastecimento atual
cHora - Hora do abastecimento atual
cFilBem - Filial do Veiculo/Bem do abastecimento
cCodBem - Codigo do Veiculo/Bem do abastecimento
@sample M040LTACU()

@return nSomaLt - Quantidade de Litros Acumulados na vida do Bem
/*/
//---------------------------------------------------------------------
Function M040LTACU(dData,cHora,cFilBem,cCodBem)

	Local aArea   := GetArea()
	Local nSomaLt := 0

	DbSelectArea("TQN")
	DbSetOrder(1)
	DbSeek(NGTROCAFILI("TQN",cFilBem)+cCodBem+dData+cHora)
	cComb := TQN->TQN_CODCOM

	DbSelectArea("TQN")
	DbSetOrder(1)
	DbSeek(NGTROCAFILI("TQN",cFilBem)+cCodBem)

	While !Eof() .And. TQN->TQN_FILIAL == xFilial("TQN") .And. TQN->TQN_FROTA == cCodBem .And. DTOS(TQN->TQN_DTABAS) <= dData

		If DTOS(TQN->TQN_DTABAS) == dData .And. TQN->TQN_HRABAS > cHora
			dbSelectArea("TQN")
			dbSkip()
			Loop
		EndIf

		If TQN->TQN_CODCOM == cComb
			nSomaLt += TQN->TQN_QUANT
		EndIf

		dbSelectArea("TQN")
		dbSkip()

	EndDo
	RestArea(aArea)

Return nSomaLt

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTUndCont
Monta Unidade de media para Contador e Unidade

@type function
@source MNTR040.prw
@author Felipe N. Welter
@since 08/12/2008
@sample MNTUndCont()

@return cRet
/*/
//---------------------------------------------------------------------
Static Function MNTUndCont(cTipo,cUnid,cTpUn)

	Local cT   := IIf(Empty(cTipo),'---',cTipo)
	Local cU   := IIf(Empty(cUnid),'--',cUnid)
	Local cTU  := cTpUn
	Local cRet := " "

	If cTU == '1'
		cRet := cT+'/'+cU
	ElseIf cTU == '2'
		cRet := cU+'/'+cT
	EndIf

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} RetUltAbas
Retorna valores referentes ao ultimo abastecimento do bem

@type function
@source MNTR040.prw
@author Felipe N. Welter
@since 08/12/2008
@sample RetUltAbas()

@return aAbast
/*/
//---------------------------------------------------------------------
Static Function RetUltAbas(cCodBem,cComb)

	Local aArea := GetArea()
	Local aAbast := {}

	dbSelectArea("TQN")
	Set Filter To TQN->TQN_FILIAL == xFilial("TQN") .And. TQN->TQN_FROTA = cCodBem .And. TQN->TQN_CODCOM == cComb

	dbSelectArea("TQN")
	dbSetOrder(01)
	dbGoBottom()

	dbSelectArea("STP")
	dbSetOrder(09)
	dbSeek(TQN->TQN_FROTA+DTOS(TQN->TQN_DTABAS)+TQN->TQN_HRABAS)

	AADD(aAbast,STP->TP_ACUMCON)
	AADD(aAbast,TQN->TQN_DTABAS)

	dbSelectArea("TQN")
	Set Filter To
	RestArea(aArea)

Return aAbast

//---------------------------------------------------------------------
/*/{Protheus.doc} fBuscaIncr
Busca o Incremento para a primeira data que está fora do range de pesquisa para
que encontre corretamente a média do abastecimento. Dessa forma não irá gerar
médias com 0.

@source MNTR040
@author Maicon André Pinheiro
@since 25/04/2017
@sample M040KMANT()
@return nIncremt

/*/
//---------------------------------------------------------------------
Static Function fBuscaIncr(dData,cHora,nKmAtual)

	Local aSTP     := {}
	Local cCond    := "STP->TP_TIPOLAN == 'I' .Or. STP->TP_TIPOLAN == 'A'"
	Local nKmAcum  := 0
	Local nIncremt := 0

	aSTP     := NGACUMEHIS((cAliasQry)->TP_CODBEM,sToD(dData),cHora,1,"A",xFilial("STP"),cCond,,(cAliasQry)->T9_PLACA)
	nKmAcum  := aSTP[2]
	nIncremt := nKmAtual - nKmAcum

Return nIncremt
