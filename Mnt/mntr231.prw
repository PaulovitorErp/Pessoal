#INCLUDE "PROTHEUS.CH"
#INCLUDE "MNTR231.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR231
	Relatório de rodados

	@param
			cBem	, Caracter	, Código do bem corrente
			nLegen	, Numeric	, Informa se imprime ou não a legenda
			cCodMod	, Caracter	, Código do modelo
			aAREIXO	, Array		, Contem as informações para o eixo

	@return

	@author Alexandre Santos
	@since 25/09/2017

	/*/
//---------------------------------------------------------------------
Function MNTR231(cBem,nLegen,cCodMod,aAREIXO)

	Local nLin		:= 0
	Local nI		:= 1
	Local lPrevW 	:= .T.
	Local cTiPag 	:= "P"

	Local oPrint //Objeto de impressão

	oPrint  := TMSPrinter():New( OemToAnsi(STR0013)) //"Impressao do Esquema de Rodado"
	oPrint:SetlandScape() // Paisagem

	MNTR231IMP(oPrint,@nI,@nLin,cBem,nLegen,cCodMod,cTiPag,lPrevW,aAREIXO)

Return

/*/{Protheus.doc} MNTR231
	Definição da Impressão do rodado

	@param
			oPrint	, Objeto	, Objeto de impressão
			nI		, Numeric	, Indicação da página corrente
			nLin	, Numeric	, Indicação da linha corrente
			cBem	, Caracter	, Código do bem corrente
			nLegen	, Numeric	, Informa se imprime ou não a legenda
			cVModT	, Caracter	, Código do modelo
			cTiPag	, Caracter	, Tipo de página para impressão.
			lPrevW	, Lógico	, Habilita visualização do relatório antes da impressão
			aAREIXO	, Array		, Contem as informações para o eixo
	@return

	@author Alexandre Santos
	@since 25/09/2017

	/*/
Function MNTR231IMP(oPrint,nI,nLin,cVBEMP,nLegen,cVModT,cTiPag,lPrevW,aAREIXO)

	Local lPRINC 	:= .T.

	Local oFont11 	:= TFont():New("Arial",11,11,,.F.,,,,.T.,.F.)
	Local oFont14 	:= TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)
	Local oFont17 	:= TFont():New("Arial",17,17,,.T.,,,,.T.,.F.)
	Local oFont18 	:= TFont():New("Arial",18,18,,.T.,,,,.T.,.F.)

	Local cCor     	:= CLR_HRED
	Local cTIPODIM 	:= STR0003 //"RODADOS"
	Local cTIPODFA 	:= If (nDESIGM = 2,STR0007,STR0008) //"LOCALIZACAO"###"FAMILIA"
	Local cNomeBem	:= Alltrim(NGSEEK("ST9",cVBEMP,1,"ST9->T9_NOME"))
	Local cDescMod	:= Alltrim(NGSEEK("TQR",cVModT,1,"TQR->TQR_DESMOD"))
	Local cPlaca	:= Alltrim(NGSEEK("ST9",cVBEMP,1,"ST9->T9_PLACA"))
	Local cHora		:= Space(10)+STR0002+" "+Dtoc(date())+Space(3)+Time()
	Local cTitRel  	:= STR0012+"..: "+Alltrim(st9->t9_codbem)+" - "+cNomeBem+Space(10)+STR0011+"..: ";
						+Alltrim(cVModT)+" - "+ cDescMod+Space(10)+STR0009+"..: " + cPlaca

	Local nInd		:= 0
	Local nPag		:= 1
	Local nCOLP2	:= 30
	Local nLinha	:= 710
	Local nUTLin	:= 0
	Local nMaior	:= 0
	Local nTamLin	:= If(cTiPag = "P",2550,1800)
	Local nLISOMA  	:= 0
	Local nL01     	:= 320
	Local nL02     	:= 470
	Local nL03     	:= 620
	Local nL04     	:= 770
	Local nL05     	:= 920
	Local nL06     	:= 1070
	Local nL07     	:= 1220
	Local nL08     	:= 1370
	Local nL09     	:= 1520
	Local nL10     	:= 1670
	Local nL11     	:= 1820

	Private nTotEixo := 0

	nMaior   := MNT231QE(aAREIXO)

	If nMaior == 1
		nLen := 576
	Elseif nMaior == 2
		nLen := 512
	Elseif nMaior == 3
		nLen := 448
	Elseif nMaior == 4
		nLen := 384
	Elseif nMaior == 5
		nLen := 320
	Elseif nMaior == 6
		nLen := 256
	Elseif nMaior == 7
		nLen := 192
	Elseif nMaior == 8
		nLen := 128
	Elseif nMaior == 9
		nLen := 64
	Elseif nMaior >= 10
		nLen := 0
	Else
		nLen := 0
	Endif

	For nInd := 1 to Len(aAREIXO)
		If lPRINC
			lPRINC := .F.
			oPrint:StartPage()
			oPrint:Say(020,0040,cTitRel,oFont14)

			oPrint:Box(100,390,200,760)
			oPrint:Say(115,040,STR0010,oFont14) //"Apresentacao   "
			oPrint:Say(125,402,cTIPODIM,oFont11)

			cPAGI := STR0001+" "+Str(nPag,2)+"    "+cHora
			oPrint:Say(125,2000,cPAGI,oFont14)
			If nDESIGM <> 1
				oPrint:Box(209,392,280,690)
				oPrint:Say(220,402,cTIPODFA,oFont11,,cCor)
			Endif
		Endif

		//   If nCOLP2 > 2550
		If nCOLP2 > nTamLin
			nLinha := 710
			nCOLP2 := 30
			nPag   += 1
			nUTLin := 0
			oPrint:EndPage()
			oPrint:StartPage()
			cPAGI := STR0001+" "+Str(nPag,2)+"    "+cHora
			oPrint:Say(125,2000,cPAGI,oFont14)
		Endif

		cNOEIXO := If(Alltrim(aAREIXO[nInd][12]) = STR0006,STR0006,;
		Alltrim(aAREIXO[nInd][12])+" "+CHR(176)+" "+STR0004)

		Do Case
			Case aAREIXO[nInd][1] = 1
				nPN1 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][2]})
				If nDESIGM = 1
					MNTA220BX(oPrint,@nI,@nLin,nL06-20-nLen,85,370,1,nCOLP2)
					oPrint:Say(nL06-85-nLen      ,nCOLP2+5,cNOEIXO,oFont14)
					oPrint:Say(nL06-nLen,nCOLP2  ,aARESTB[nPN1,3],oFont11)
					nUTLin := Max(nUTLin,1050-nLen)
				Else
					oPrint:Say(nL06+140 -nLen,nCOLP2+7,cNOEIXO,oFont14)
					MNTA220BX(oPrint,@nI,@nLin,nL01+952-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+972-nLen,nCOLP2  ,aARESTB[nPN1,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+1034-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+1049-nLen,nCOLP2  ,aARESTB[nPN1,If(nDESIGM = 2,1,4)],oFont11,,cCor)
					nUTLin := Max(nUTLin,1450-nLen)
				Endif
			Case aAREIXO[nInd][1] = 2
				nPN1 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][2]})
				nPN2 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][3]})
				If nDESIGM = 1
					MNTA220BX(oPrint,@nI,@nLin,nL05-20-nLen,85,370,1,nCOLP2)
					MNTA220BX(oPrint,@nI,@nLin,nL07-20-nLen,85,370,1,nCOLP2)
					MNTA220EI1(oPrint,@nI,@nLin,nL05+65-nLen,nL05+280-nLen,1,1,170,nLISOMA,nCOLP2)
					oPrint:Say(nL05-85-nLen      ,nCOLP2+100,cNOEIXO,oFont14)
					oPrint:Say(nL05-nLen,nCOLP2  ,aARESTB[nPN1,3],oFont11)
					oPrint:Say(nL07-nLen,nCOLP2  ,aARESTB[nPN2,3],oFont11)
					nUTLin := Max(nUTLin,1250-nLen)
				Else
					oPrint:Say(nL05+140-nLen ,nCOLP2+100,cNOEIXO,oFont14)
					MNTA220BX(oPrint,@nI,@nLin,nL01+802-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+822-nLen,nCOLP2  ,aARESTB[nPN1,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+884-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+899-nLen,nCOLP2  ,aARESTB[nPN1,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					// DIVISOR
					MNTA220EI1(oPrint,@nI,@nLin,nL01+969-nLen,nL01+1119-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+1119-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+1139-nLen,nCOLP2  ,aARESTB[nPN2,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+1201-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+1216-nLen,nCOLP2  ,aARESTB[nPN2,If(nDESIGM = 2,1,4)],oFont11,,cCor)
					nUTLin := Max(nUTLin,1650-nLen)
				Endif
			Case aAREIXO[nInd][1] = 3
				nPN1 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][2]})
				nPN2 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][3]})
				nPN3 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][4]})
				If nDESIGM = 1
					MNTA220BX(oPrint,@nI,@nLin,nL05-20-nLen,85,370,2,nCOLP2)
					MNTA220BX(oPrint,@nI,@nLin,nL07-20-nLen,85,370,1,nCOLP2)
					MNTA220EI1(oPrint,@nI,@nLin,nL05+65-nLen,nL05+130-nLen,2,1,170,nLISOMA,nCOLP2)
					MNTA220EI1(oPrint,@nI,@nLin,nL06+62-nLen,nL06+130-nLen,2,1,170,nLISOMA,nCOLP2)
					oPrint:Say(nL05-85-nLen      ,nCOLP2+100,cNOEIXO,oFont14)
					oPrint:Say(nL05-nLen,nCOLP2  ,aARESTB[nPN1,3],oFont11)
					oPrint:Say(nL06-nLen,nCOLP2  ,aARESTB[nPN2,3],oFont11)
					oPrint:Say(nL07-nLen,nCOLP2  ,aARESTB[nPN3,3],oFont11)
					nUTLin := Max(nUTLin,1250-nLen)
				Else
					oPrint:Say(nL05+100-nLen,nCOLP2+100,cNOEIXO,oFont14)
					MNTA220BX(oPrint,@nI,@nLin,nL01+761-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+781-nLen,nCOLP2  ,aARESTB[nPN1,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+843-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+858-nLen,nCOLP2  ,aARESTB[nPN1,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+927-nLen,nL01+952-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+952-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+972-nLen,nCOLP2  ,aARESTB[nPN2,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+1034-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+1049-nLen,nCOLP2  ,aARESTB[nPN2,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+1118-nLen,nL01+1143-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+1143-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+1163-nLen,nCOLP2  ,aARESTB[nPN3,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+1225-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+1240-nLen,nCOLP2  ,aARESTB[nPN3,If(nDESIGM = 2,1,4)],oFont11,,cCor)
					nUTLin := Max(nUTLin,1650-nLen)
				Endif
			Case aAREIXO[nInd][1] = 4
				nPN1 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][2]})
				nPN2 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][3]})
				nPN3 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][4]})
				nPN4 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][5]})
				If nDESIGM = 1
					MNTA220BX(oPrint,@nI,@nLin,nL04-20-nLen,85,370,2,nCOLP2)
					MNTA220BX(oPrint,@nI,@nLin,nL07-20-nLen,85,370,2,nCOLP2)
					MNTA220EI1(oPrint,@nI,@nLin,nL04+65-nLen,nL04+125-nLen,2,1,170,nLISOMA,nCOLP2)
					MNTA220EI1(oPrint,@nI,@nLin,nL05+57-nLen,nL05+280-nLen,2,1,170,nLISOMA,nCOLP2)
					MNTA220EI1(oPrint,@nI,@nLin,nL07+65-nLen,nL07+125-nLen,2,1,170,nLISOMA,nCOLP2)
					oPrint:Say(nL04-85-nLen      ,nCOLP2+100,cNOEIXO,oFont14)
					oPrint:Say(nL04-nLen,nCOLP2  ,aARESTB[nPN1,3],oFont11)
					oPrint:Say(nL05-nLen,nCOLP2  ,aARESTB[nPN2,3],oFont11)
					oPrint:Say(nL07-nLen,nCOLP2  ,aARESTB[nPN3,3],oFont11)
					oPrint:Say(nL08-nLen,nCOLP2  ,aARESTB[nPN4,3],oFont11)
					nUTLin := Max(nUTLin,1455-nLen)
				Else
					oPrint:Say(nL04+100-nLen ,nCOLP2+100,cNOEIXO,oFont14)
					MNTA220BX(oPrint,@nI,@nLin,nL01+611-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+631-nLen,nCOLP2  ,aARESTB[nPN1,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+693-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+708-nLen,nCOLP2  ,aARESTB[nPN1,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+777-nLen,nL01+802-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+802-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+822-nLen,nCOLP2  ,aARESTB[nPN2,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+884-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+899-nLen,nCOLP2  ,aARESTB[nPN2,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					// DIVISOR
					MNTA220EI1(oPrint,@nI,@nLin,nL01+969-nLen,nL01+1119-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+1119-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+1139-nLen,nCOLP2  ,aARESTB[nPN3,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+1201-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+1216-nLen,nCOLP2  ,aARESTB[nPN3,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+1285-nLen,nL01+1310-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+1310-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+1330-nLen,nCOLP2  ,aARESTB[nPN4,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+1392-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+1407-nLen,nCOLP2  ,aARESTB[nPN4,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					nUTLin := Max(nUTLin,1855-nLen)
				Endif
			Case aAREIXO[nInd][1] = 5
				nPN1 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][2]})
				nPN2 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][3]})
				nPN3 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][4]})
				nPN4 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][5]})
				nPN5 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][6]})
				If nDESIGM = 1
					MNTA220BX(oPrint,@nI,@nLin,nL04-20-nLen,85,370,2,nCOLP2)
					MNTA220BX(oPrint,@nI,@nLin,nL06-20-nLen,85,370,1,nCOLP2)
					MNTA220BX(oPrint,@nI,@nLin,nL07-20-nLen,85,370,2,nCOLP2)
					MNTA220EI1(oPrint,@nI,@nLin,nL04+65-nLen,nL04+130-nLen,2,1,170,nLISOMA,nCOLP2)
					MNTA220EI1(oPrint,@nI,@nLin,nL05+58-nLen,nL05+130-nLen,2,1,170,nLISOMA,nCOLP2)
					MNTA220EI1(oPrint,@nI,@nLin,nL06+65-nLen,nL06+130-nLen,2,2,170,nLISOMA,nCOLP2)
					oPrint:Say(nL04-85-nLen      ,nCOLP2+100,cNOEIXO,oFont14)
					oPrint:Say(nL04-nLen,nCOLP2  ,aARESTB[nPN1,3],oFont11)
					oPrint:Say(nL05-nLen,nCOLP2  ,aARESTB[nPN2,3],oFont11)
					oPrint:Say(nL06-nLen,nCOLP2  ,aARESTB[nPN3,3],oFont11)
					oPrint:Say(nL07-nLen,nCOLP2  ,aARESTB[nPN4,3],oFont11)
					oPrint:Say(nL08-nLen,nCOLP2  ,aARESTB[nPN5,3],oFont11)
					//anUTLin := Max(nUTLin,1450-nLen)
				Else
					oPrint:Say(nL04+60-nLen,nCOLP2+100,cNOEIXO,oFont14)
					MNTA220BX(oPrint,@nI,@nLin,nL01+570-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+590-nLen,nCOLP2  ,aARESTB[nPN1,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+652-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+667-nLen,nCOLP2  ,aARESTB[nPN1,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+736-nLen,nL01+761-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+761-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+781-nLen,nCOLP2  ,aARESTB[nPN2,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+843-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+858-nLen,nCOLP2  ,aARESTB[nPN2,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+927-nLen,nL01+952-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+952-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+972-nLen,nCOLP2  ,aARESTB[nPN3,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+1034-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+1049-nLen,nCOLP2  ,aARESTB[nPN3,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+1118-nLen,nL01+1143-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+1143-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+1163-nLen,nCOLP2  ,aARESTB[nPN4,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+1225-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+1240-nLen,nCOLP2  ,aARESTB[nPN4,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+1309-nLen,nL01+1334-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+1334-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+1354-nLen,nCOLP2  ,aARESTB[nPN5,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+1416-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+1431-nLen,nCOLP2  ,aARESTB[nPN5,If(nDESIGM = 2,1,4)],oFont11,,cCor)
					nUTLin := Max(nUTLin,1850)
				Endif
			Case aAREIXO[nInd][1] = 6
				nPN1 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][2]})
				nPN2 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][3]})
				nPN3 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][4]})
				nPN4 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][5]})
				nPN5 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][6]})
				nPN6 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][7]})
				If nDESIGM = 1
					MNTA220BX(oPrint,@nI,@nLin,nL03-20-nLen,85,370,3,nCOLP2)
					MNTA220BX(oPrint,@nI,@nLin,nL07-20-nLen,85,370,3,nCOLP2)
					MNTA220EI1(oPrint,@nI,@nLin,nL03+65-nLen,nL03+130-nLen,2,2,170,nLISOMA,nCOLP2)
					MNTA220EI1(oPrint,@nI,@nLin,nL05+50-nLen,nL05+280-nLen,2,1,170,nLISOMA,nCOLP2)
					MNTA220EI1(oPrint,@nI,@nLin,nL07+65-nLen,nL07+130-nLen,2,2,170,nLISOMA,nCOLP2)
					oPrint:Say(nL03-85-nLen      ,nCOLP2+100,cNOEIXO,oFont14)
					oPrint:Say(nL03-nLen,nCOLP2  ,aARESTB[nPN1,3],oFont11)
					oPrint:Say(nL04-nLen,nCOLP2  ,aARESTB[nPN2,3],oFont11)
					oPrint:Say(nL05-nLen,nCOLP2  ,aARESTB[nPN3,3],oFont11)
					oPrint:Say(nL07-nLen,nCOLP2  ,aARESTB[nPN4,3],oFont11)
					oPrint:Say(nL08-nLen,nCOLP2  ,aARESTB[nPN5,3],oFont11)
					oPrint:Say(nL09-nLen,nCOLP2  ,aARESTB[nPN6,3],oFont11)
					nUTLin := Max(nUTLin,1550-nLen)
				Else
					oPrint:Say(nL03+60-nLen ,nCOLP2+100,cNOEIXO,oFont14)
					MNTA220BX(oPrint,@nI,@nLin,nL01+420-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+440-nLen,nCOLP2  ,aARESTB[nPN1,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+502-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+517-nLen,nCOLP2  ,aARESTB[nPN1,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+586-nLen,nL01+611-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+611-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+631-nLen,nCOLP2  ,aARESTB[nPN2,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+693-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+708-nLen,nCOLP2  ,aARESTB[nPN2,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+777-nLen,nL01+802-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+802-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+822-nLen,nCOLP2  ,aARESTB[nPN3,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+884-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+899-nLen,nCOLP2  ,aARESTB[nPN3,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					// DIVISOR
					MNTA220EI1(oPrint,@nI,@nLin,nL01+969-nLen,nL01+1119-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+1119-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+1139-nLen,nCOLP2  ,aARESTB[nPN4,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+1201-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+1216-nLen,nCOLP2  ,aARESTB[nPN4,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+1285-nLen,nL01+1310-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+1310-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+1330-nLen,nCOLP2  ,aARESTB[nPN5,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+1392-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+1407-nLen,nCOLP2  ,aARESTB[nPN5,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+1476-nLen,nL01+1501-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+1501-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+1521-nLen,nCOLP2  ,aARESTB[nPN6,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+1583-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+1598-nLen,nCOLP2  ,aARESTB[nPN6,If(nDESIGM = 2,1,4)],oFont11,,cCor)
					nUTLin := Max(nUTLin,1950-nLen)
				Endif
			Case aAREIXO[nInd][1] = 7
				nPN1 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][2]})
				nPN2 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][3]})
				nPN3 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][4]})
				nPN4 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][5]})
				nPN5 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][6]})
				nPN6 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][7]})
				nPN7 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][8]})
				If nDESIGM = 1
					MNTA220BX(oPrint,@nI,@nLin,nL03-20-nLen,85,370,3,nCOLP2)
					MNTA220BX(oPrint,@nI,@nLin,nL06-20-nLen,85,370,1,nCOLP2)
					MNTA220BX(oPrint,@nI,@nLin,nL07-20-nLen,85,370,3,nCOLP2)
					MNTA220EI1(oPrint,@nI,@nLin,nL03+65-nLen,nL03+130-nLen,2,2,170,nLISOMA,nCOLP2)
					MNTA220EI1(oPrint,@nI,@nLin,nL05+58-nLen,nL05+130-nLen,2,1,170,nLISOMA,nCOLP2)
					MNTA220EI1(oPrint,@nI,@nLin,nL06+65-nLen,nL06+130-nLen,2,3,170,nLISOMA,nCOLP2)
					oPrint:Say(nL03-85-nLen      ,nCOLP2+100,cNOEIXO,oFont14)
					oPrint:Say(nL03-nLen,nCOLP2  ,aARESTB[nPN1,3],oFont11)
					oPrint:Say(nL04-nLen,nCOLP2  ,aARESTB[nPN2,3],oFont11)
					oPrint:Say(nL05-nLen,nCOLP2  ,aARESTB[nPN3,3],oFont11)
					oPrint:Say(nL06-nLen,nCOLP2  ,aARESTB[nPN4,3],oFont11)
					oPrint:Say(nL07-nLen,nCOLP2  ,aARESTB[nPN5,3],oFont11)
					oPrint:Say(nL08-nLen,nCOLP2  ,aARESTB[nPN6,3],oFont11)
					oPrint:Say(nL09-nLen,nCOLP2  ,aARESTB[nPN7,3],oFont11)
					nUTLin := Max(nUTLin,1750-nLen)
				Else
					oPrint:Say(nL03+20-nLen ,nCOLP2+100,cNOEIXO,oFont14)
					MNTA220BX(oPrint,@nI,@nLin,nL01+380-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+390-nLen,nCOLP2  ,aARESTB[nPN1,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+462-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+477-nLen,nCOLP2  ,aARESTB[nPN1,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+545-nLen,nL01+570-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+570-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+590-nLen,nCOLP2  ,aARESTB[nPN2,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+652-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+667-nLen,nCOLP2  ,aARESTB[nPN2,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+736-nLen,nL01+761-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+761-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+781-nLen,nCOLP2  ,aARESTB[nPN3,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+843-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+858-nLen,nCOLP2  ,aARESTB[nPN3,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+927-nLen,nL01+952-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+952-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+972-nLen,nCOLP2  ,aARESTB[nPN4,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+1034-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+1049-nLen,nCOLP2  ,aARESTB[nPN4,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+1118-nLen,nL01+1143-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+1143-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+1163-nLen,nCOLP2  ,aARESTB[nPN5,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+1225-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+1240-nLen,nCOLP2  ,aARESTB[nPN5,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+1309-nLen,nL01+1334-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+1334-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+1354-nLen,nCOLP2  ,aARESTB[nPN6,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+1416-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+1431-nLen,nCOLP2  ,aARESTB[nPN6,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+1500-nLen,nL01+1525-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+1525-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+1545-nLen,nCOLP2  ,aARESTB[nPN7,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+1607-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+1622-nLen,nCOLP2  ,aARESTB[nPN7,If(nDESIGM = 2,1,4)],oFont11,,cCor)
					nUTLin := Max(nUTLin,2150-nLen)
				Endif

			Case aAREIXO[nInd][1] = 8
				nPN1 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][2]})
				nPN2 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][3]})
				nPN3 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][4]})
				nPN4 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][5]})
				nPN5 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][6]})
				nPN6 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][7]})
				nPN7 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][8]})
				nPN8 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][9]})
				If nDESIGM = 1
					MNTA220BX(oPrint,@nI,@nLin,nL02-20-nLen,85,370,4,nCOLP2)
					MNTA220BX(oPrint,@nI,@nLin,nL07-20-nLen,85,370,4,nCOLP2)
					MNTA220EI1(oPrint,@nI,@nLin,nL02+65-nLen,nL02+130-nLen,2,3,170,nLISOMA,nCOLP2)
					MNTA220EI1(oPrint,@nI,@nLin,nL05+45-nLen,nL05+280-nLen,2,1,170,nLISOMA,nCOLP2)
					MNTA220EI1(oPrint,@nI,@nLin,nL07+65-nLen,nL07+130-nLen,2,3,170,nLISOMA,nCOLP2)
					oPrint:Say(nL02-85-nLen      ,nCOLP2+100,cNOEIXO,oFont14)
					oPrint:Say(nL02-nLen,nCOLP2  ,aARESTB[nPN1,3],oFont11)
					oPrint:Say(nL03-nLen,nCOLP2  ,aARESTB[nPN2,3],oFont11)
					oPrint:Say(nL04-nLen,nCOLP2  ,aARESTB[nPN3,3],oFont11)
					oPrint:Say(nL05-nLen,nCOLP2  ,aARESTB[nPN4,3],oFont11)
					oPrint:Say(nL07-nLen,nCOLP2  ,aARESTB[nPN5,3],oFont11)
					oPrint:Say(nL08-nLen,nCOLP2  ,aARESTB[nPN6,3],oFont11)
					oPrint:Say(nL09-nLen,nCOLP2  ,aARESTB[nPN7,3],oFont11)
					oPrint:Say(nL10-nLen,nCOLP2  ,aARESTB[nPN8,3],oFont11)
					nUTLin := Max(nUTLin,1950-nLen)
				Else
					oPrint:Say(nL02+20-nLen ,nCOLP2+100,cNOEIXO,oFont14)
					MNTA220BX(oPrint,@nI,@nLin,nL01+230-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+250-nLen,nCOLP2  ,aARESTB[nPN1,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+312-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+327-nLen,nCOLP2  ,aARESTB[nPN1,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+395-nLen,nL01+420-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+420-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+440-nLen,nCOLP2  ,aARESTB[nPN2,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+502-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+517-nLen,nCOLP2  ,aARESTB[nPN2,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+586-nLen,nL01+611-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+611-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+631-nLen,nCOLP2  ,aARESTB[nPN3,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+693-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+708-nLen,nCOLP2  ,aARESTB[nPN3,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+777-nLen,nL01+802-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+802-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+822-nLen,nCOLP2  ,aARESTB[nPN4,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+884-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+899-nLen,nCOLP2  ,aARESTB[nPN4,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					// DIVISOR
					MNTA220EI1(oPrint,@nI,@nLin,nL01+969-nLen,nL01+1119-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+1119-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+1139-nLen,nCOLP2  ,aARESTB[nPN5,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+1201-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+1216-nLen,nCOLP2  ,aARESTB[nPN5,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+1285-nLen,nL01+1310-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+1310-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+1330-nLen,nCOLP2  ,aARESTB[nPN6,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+1392-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+1407-nLen,nCOLP2  ,aARESTB[nPN6,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+1476-nLen,nL01+1501-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+1501-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+1521-nLen,nCOLP2  ,aARESTB[nPN7,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+1583-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+1598-nLen,nCOLP2  ,aARESTB[nPN7,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+1667-nLen,nL01+1692-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+1692-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+1717-nLen,nCOLP2  ,aARESTB[nPN8,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+1779-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+1794-nLen,nCOLP2  ,aARESTB[nPN8,If(nDESIGM = 2,1,4)],oFont11,,cCor)
					nUTLin := Max(nUTLin,2350-nLen)
				Endif
			Case aAREIXO[nInd][1] = 9
				nPN1 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][2]})
				nPN2 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][3]})
				nPN3 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][4]})
				nPN4 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][5]})
				nPN5 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][6]})
				nPN6 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][7]})
				nPN7 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][8]})
				nPN8 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][9]})
				nPN9 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][10]})
				If nDESIGM = 1
					MNTA220BX(oPrint,@nI,@nLin,nL02-20-nLen,85,370,4,nCOLP2)
					MNTA220BX(oPrint,@nI,@nLin,nL06-20-nLen,85,370,5,nCOLP2)
					MNTA220EI1(oPrint,@nI,@nLin,nL02+65-nLen,nL02+130-nLen,2,4,170,nLISOMA,nCOLP2)
					MNTA220EI1(oPrint,@nI,@nLin,nL05+65-nLen,nL05+130-nLen,2,5,170,nLISOMA,nCOLP2)
					oPrint:Say(nL02-85-nLen      ,nCOLP2+100,cNOEIXO,oFont14)
					oPrint:Say(nL02-nLen,nCOLP2  ,aARESTB[nPN1,3],oFont11)
					oPrint:Say(nL03-nLen,nCOLP2  ,aARESTB[nPN2,3],oFont11)
					oPrint:Say(nL04-nLen,nCOLP2  ,aARESTB[nPN3,3],oFont11)
					oPrint:Say(nL05-nLen,nCOLP2  ,aARESTB[nPN4,3],oFont11)
					oPrint:Say(nL06-nLen,nCOLP2  ,aARESTB[nPN5,3],oFont11)
					oPrint:Say(nL07-nLen,nCOLP2  ,aARESTB[nPN6,3],oFont11)
					oPrint:Say(nL08-nLen,nCOLP2  ,aARESTB[nPN7,3],oFont11)
					oPrint:Say(nL09-nLen,nCOLP2  ,aARESTB[nPN8,3],oFont11)
					oPrint:Say(nL10-nLen,nCOLP2  ,aARESTB[nPN9,3],oFont11)
					nUTLin := Max(nUTLin,2150)
				Else
					oPrint:Say(nL02-20-nLen  ,nCOLP2+100,cNOEIXO,oFont14)
					MNTA220BX(oPrint,@nI,@nLin,nL01+190-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+200-nLen,nCOLP2  ,aARESTB[nPN1,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+270-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+290-nLen,nCOLP2  ,aARESTB[nPN1,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+355-nLen,nL01+380-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+380-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+390-nLen,nCOLP2  ,aARESTB[nPN2,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+462-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+477-nLen,nCOLP2  ,aARESTB[nPN2,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+545-nLen,nL01+570-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+570-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+590-nLen,nCOLP2  ,aARESTB[nPN3,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+652-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+667-nLen,nCOLP2  ,aARESTB[nPN3,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+736-nLen,nL01+761-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+761-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+781-nLen,nCOLP2  ,aARESTB[nPN4,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+843-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+858-nLen,nCOLP2  ,aARESTB[nPN4,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+927-nLen,nL01+952-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+952-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+972-nLen,nCOLP2  ,aARESTB[nPN5,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+1034-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+1049-nLen,nCOLP2  ,aARESTB[nPN5,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+1118-nLen,nL01+1143-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+1143-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+1163-nLen,nCOLP2  ,aARESTB[nPN6,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+1225-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+1240-nLen,nCOLP2  ,aARESTB[nPN6,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+1309-nLen,nL01+1334-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+1334-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+1354-nLen,nCOLP2  ,aARESTB[nPN7,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+1416-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+1431-nLen,nCOLP2  ,aARESTB[nPN7,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+1500-nLen,nL01+1525-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+1525-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+1545-nLen,nCOLP2  ,aARESTB[nPN8,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+1607-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+1622-nLen,nCOLP2  ,aARESTB[nPN8,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+1691-nLen,nL01+1716-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+1716-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+1736-nLen,nCOLP2  ,aARESTB[nPN8,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+1798-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+1813-nLen,nCOLP2  ,aARESTB[nPN8,If(nDESIGM = 2,1,4)],oFont11,,cCor)
					nUTLin := Max(nUTLin,2550-nLen)
				Endif

			Case aAREIXO[nInd][1] = 10
				nPN1 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][2]})
				nPN2 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][3]})
				nPN3 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][4]})
				nPN4 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][5]})
				nPN5 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][6]})
				nPN6 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][7]})
				nPN7 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][8]})
				nPN8 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][9]})
				nPN9 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][10]})
				nPN0 := ASCAN(aARESTB,{|x| x[1] == aAREIXO[nInd][11]})

				If nDESIGM = 1
					MNTA220BX(oPrint,@nI,@nLin,nL01-20-nLen,85,370,5,nCOLP2)
					MNTA220EI1(oPrint,@nI,@nLin,nL01+65-nLen,nL01+130-nLen,2,4,170,nLISOMA,nCOLP2)
					MNTA220EI1(oPrint,@nI,@nLin,nL05+45-nLen,nL05+280-nLen,2,1,170,nLISOMA,nCOLP2)
					MNTA220BX(oPrint,@nI,@nLin,nL07-20-nLen,85,370,5,nCOLP2)
					MNTA220EI1(oPrint,@nI,@nLin,nL07+65-nLen,nL07+130-nLen,2,4,170,nLISOMA,nCOLP2)
					oPrint:Say(nL01-85-nLen      ,nCOLP2+100,cNOEIXO,oFont14)
					oPrint:Say(nL01-nLen,nCOLP2  ,aARESTB[nPN1,3],oFont11)
					oPrint:Say(nL02-nLen,nCOLP2  ,aARESTB[nPN2,3],oFont11)
					oPrint:Say(nL03-nLen,nCOLP2  ,aARESTB[nPN3,3],oFont11)
					oPrint:Say(nL04-nLen,nCOLP2  ,aARESTB[nPN4,3],oFont11)
					oPrint:Say(nL05-nLen,nCOLP2  ,aARESTB[nPN5,3],oFont11)
					oPrint:Say(nL07-nLen,nCOLP2  ,aARESTB[nPN6,3],oFont11)
					oPrint:Say(nL08-nLen,nCOLP2  ,aARESTB[nPN7,3],oFont11)
					oPrint:Say(nL09-nLen,nCOLP2  ,aARESTB[nPN8,3],oFont11)
					oPrint:Say(nL10-nLen,nCOLP2  ,aARESTB[nPN9,3],oFont11)
					oPrint:Say(nL11-nLen,nCOLP2  ,aARESTB[nPN0,3],oFont11)
					nUTLin := Max(nUTLin,2350-nLen)
				Else
					oPrint:Say(nL01-15-nLen      ,nCOLP2+100,cNOEIXO,oFont14)

					MNTA220BX(oPrint,@nI,@nLin,nL01+40-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+50-nLen,nCOLP2  ,aARESTB[nPN1,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+120-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+140-nLen,nCOLP2  ,aARESTB[nPN1,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+205-nLen,nL01+230-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+230-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+250-nLen,nCOLP2  ,aARESTB[nPN2,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+312-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+327-nLen,nCOLP2  ,aARESTB[nPN2,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+395-nLen,nL01+420-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+420-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+440-nLen,nCOLP2  ,aARESTB[nPN3,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+502-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+517-nLen,nCOLP2  ,aARESTB[nPN3,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+586-nLen,nL01+611-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+611-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+631-nLen,nCOLP2  ,aARESTB[nPN4,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+693-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+708-nLen,nCOLP2  ,aARESTB[nPN4,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+777-nLen,nL01+802-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+802-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+822-nLen,nCOLP2  ,aARESTB[nPN5,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+884-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+899-nLen,nCOLP2  ,aARESTB[nPN5,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					// DIVISOR
					MNTA220EI1(oPrint,@nI,@nLin,nL01+969-nLen,nL01+1119-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+1119-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+1139-nLen,nCOLP2  ,aARESTB[nPN6,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+1201-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+1216-nLen,nCOLP2  ,aARESTB[nPN6,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+1285-nLen,nL01+1310-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+1310-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+1330-nLen,nCOLP2  ,aARESTB[nPN7,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+1392-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+1407-nLen,nCOLP2  ,aARESTB[nPN7,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+1476-nLen,nL01+1501-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+1501-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+1521-nLen,nCOLP2  ,aARESTB[nPN8,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+1583-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+1598-nLen,nCOLP2  ,aARESTB[nPN8,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+1667-nLen,nL01+1692-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+1692-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+1717-nLen,nCOLP2  ,aARESTB[nPN9,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+1779-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+1794-nLen,nCOLP2  ,aARESTB[nPN9,If(nDESIGM = 2,1,4)],oFont11,,cCor)

					MNTA220EI1(oPrint,@nI,@nLin,nL01+1866-nLen,nL01+1893-nLen,2,1,170,nLISOMA,nCOLP2)

					MNTA220BX(oPrint,@nI,@nLin,nL01+1893-nLen,85,380,1,nCOLP2)
					oPrint:Say(nL01+1913-nLen,nCOLP2  ,aARESTB[nPN0,3],oFont11)
					MNTA220BX(oPrint,@nI,@nLin,nL01+1975-nLen,85,210,1,nCOLP2)
					oPrint:Say(nL01+1990-nLen,nCOLP2  ,aARESTB[nPN0,If(nDESIGM = 2,1,4)],oFont11,,cCor)
					nUTLin := Max(nUTLin,2750)
				Endif
		EndCase
		nCOLP2 := nCOLP2 + 420
	Next nInd

	If nLegen == 2
		nLIN := nUTLin+70
		If nLIN > 2350 .OR. nMaior >= 7 .OR. nLIN+(nTotEixo*40) > 2350
			nPag   += 1
			nUTLin := 0
			oPrint:EndPage()
			oPrint:StartPage()
			cPAGI := STR0001+" "+Str(nPag,2)+"    "+cHora
			oPrint:Say(10,2000,cPAGI,oFont14)
			nLIN := 60
		Endif

		// GERAR UMA MATRIZ COM OS DESENHO
		If nDESIGM <> 1
			cDESIGF := If(nDESIGM = 2,STR0007,STR0008) //"LOCALIZACAO","FAMILIA"
			aDESIGF := {}
			For nInd := 1 To Len(aARESTB)
				cCODESIG := If(nDESIGM = 2,aARESTB[nInd][1],aARESTB[nInd][4])
				If ASCAN(aDESIGF,{|x| x[1] == cCODESIG}) = 0
					Aadd(aDESIGF,{cCODESIG})
				Endif
			Next nInd
		Endif

		oPrint:Say(nLIN,040,STR0005,oFont18) //"LEGENDA"

		nLIN := nLIN + 90
		oPrint:Say(nLIN,040,Upper(STR0003),oFont14) //"RODADOS"

		If nDESIGM <> 1
			oPrint:Say(nLIN,1540,Upper(cDESIGF),oFont14,,cCor)
		Endif

		nLIN := nLIN + 50
		For nInd := 1 To Len(aARESTB)
			If nLIN > 2350
				nPag   += 1
				oPrint:EndPage()
				oPrint:StartPage()
				cPAGI := STR0001+" "+Str(nPag,2)+"    "+cHora
				oPrint:Say(10,2000,cPAGI,oFont14)
				oPrint:Say(40,040,Upper(STR0003),oFont14) //"RODADOS"
				nLIN  := 90
			Endif

			If !Empty(aARESTB[nInd][3])
				oPrint:Say(nLIN,040,aARESTB[nInd][3],oFont11)
				oPrint:Say(nLIN,402,"- "+NGSEEK("ST9",aARESTB[nInd,3],1,"T9_NOME"),oFont11)
			Endif

			If nDESIGM <> 1
				If nInd <= Len(aDESIGF)
					oPrint:Say(nLIN,1540,aDESIGF[nInd,1],oFont11,,cCor)
					If nDESIGM = 2
						oPrint:Say(nLIN,1700,"- "+NGSEEK("TPS",aDESIGF[nInd,1],1,"TPS_NOME"),oFont11,,cCor)
					Else
						oPrint:Say(nLIN,1700,"- "+NGSEEK("ST6",aDESIGF[nInd,1],1,"T6_NOME"),oFont11,,cCor)
					Endif
				Endif
			Endif
			nLIN := nLIN + 40
		Next nInd
	Endif

	oPrint:EndPage()
	If lPrevW
		oPrint:Preview()
	Endif

Return