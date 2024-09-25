#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"
#Include "RWMAKE.CH"
#Include "Fileio.ch"
#Include "tbiconn.ch"
#Include "DBINFO.CH"
#Include "MSGRAPHI.CH"
#Include "MNTUTIL01.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³PROCALEND ³ Autor ³ In cio Luiz Kolling   ³ Data ³ 18/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Procura o calendario                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ProCalend(cCodBem, cServico, cSeq)

	Local cCalenda := Space( TamSX3('T9_CALENDA')[1] )
	Local cSequenc := IIf( ValType(cSeq) == "C", cSeq, Str(cSeq, 3) )

	dbSelectArea("ST9")
	dbSetOrder(1)
	If dbSeek(xFilial("ST9") + cCodBem)

		cCalenda := ST9->T9_CALENDA

		dbSelectArea("STF")
		dbSetOrder(1)
		If dbSeek(xFilial("STF") + cCodBem + cServico + cSequenc)
			cCalenda := STF->TF_CALENDA
		EndIf
	EndIf

Return cCalenda

//---------------------------------------------------------------------------
/*/{Protheus.doc} NG_H7
Monta uma matriz com os dados do calendario

@param	cCod, Caracter	, Código do Calendario
@return aDIA, Array		, Array com dados do calendario

@sample NG_H7()
@author
@since
/*/
//---------------------------------------------------------------------------
Function NG_H7(cCod)
	Local aDIA := {}
	Local aOCI := {}
	Local nHor	:= 0
	Local nQtd	:= 0
	Local nPos 	:= 1
	Local nIni	:= 0
	Local nFim	:= 0
	Local nDia	:= 0
	Local nTot	:= 0
	Local nX	:= 0
	Local nI	:= 0

	SH7->(dbSetOrder(1))
	SH7->(dbSeek(xFilial('SH7')))

	If !SH7->(dbSeek(xFilial('SH7') + cCod))
		Return aDIA
	EndIf

	aDia 	:= {}
	nHor  	:= SH7->H7_ALOC
	nQtd  	:= Len(nHor)/7

	Rep := SubStr(nHor,nPos,nQtd)
	For nI := 1 to 7
		nDia 	:= SubStr(nHor,nPos,nQtd)
		nTot 	:= 0
		nIni 	:= 999
		nFim 	:= 0
		nPos	+= nQtd
		aOCI	:= {}
		nOI 	:= 999
		nOF 	:= 0

		For nX := 1 to Len(nDia)
			If !Empty(SubStr(nDia,nX,1))
				nTot += (1440/Len(nDia))
				nFim := ( (1440/Len(nDia)) * nX )
				nIni := If(nIni == 999,(nFim - (1440/Len(nDia))),nIni)
				If nOI != 999
					aAdd(aOCI,{nOI, nOF})
					nOI := 999
					nOF := 0
				EndIf
			Else
				nOF := ( (1440/Len(nDia)) * nX)
				nOI := If(nOI == 999,(nOF - (1440/Len(nDia))),nOI)
			EndIf
		Next nX
		If nOI != 999
			aAdd(aOCI,{nOI, nOF})
			nOI := 999
			nOF := 0
		EndIf
		nIni := If(nIni == 999,0,nIni)
		aAdd(aDia,{MtoH(nIni),MtoH(nFim),MtoH(nTot),aOCI})
	Next nI
Return aDIA

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³  NGCHKFLUT   ³ Autor ³ Rafael Diogo Richter  ³ Data ³31/08/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para validar se esta sendo utilizado o turno flutuante ou³±±
±±³          ³nao, caso sim, o campo STL->TL_USACALE fica desabilitado.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaMNT                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ F.O  ³  Motivo da Alteracao                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGCHKFLUT()

//Trata o calendario flutuante
If Alltrim(superGetMv("MV_NGFLUT",.F.,"N")) == "S"
	Return .F.
EndIf

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGCALEINTD  ³ Autor ³Inacio Luiz Kolling    ³ Data ³30/09/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula a quantidade de horas no intervalo de datas e horas   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICA                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGCALEINTD(dDTIV,hHIVV,dDTFV,hHFVV,cCALEV)
If lCALE
   nQTDF := NGCALENHORA(dDTIV,hHIVV,dDTFV,hHFVV,cCALEV)
ElseIf GETMV("MV_NGUNIDT") = "D"
   nQTDF := NGCALCH100(dDTIV,hHIVV,dDTFV,hHFVV)
Else
   nQTDF := NGCALCH060(dDTIV,hHIVV,dDTFV,hHFVV)
EndIf

NGCALECARV(dDTIV,hHIVV,dDTFV,hHFVV,nQTDF)

Return .T.

//---------------------------------------------------------------------
/*{Protheus.doc} NGCALDTHO
Calcula a data e hora inicio a partir de uma data e hora fim e quantidade ou vise-versa.
Dependendo utiliza calendario

@return .T.
@param

@author Inacio Luiz Kolling
@since 30/09/2005
//---------------------------------------------------------------------
*/
Function NGCALDTHO()

	Local lCHKQTD 	:= .T.
	Local lIntEsto 	:= GetNewPar("MV_NGMNTES","N") == "S"
	Local nTIPO	 	:= aScan(aHeader,{|x| Trim(Upper(x[2])) == "TL_TIPOREG"})
	Local lMNTA401 	:= IsInCallStack( "MNTA401" )
	Local lMNTA990  := IsInCallStack( "MNTA990" )
	Local nCust		:= 0
	Local nCustOld  := 0
	Local nQtdeRec  := 0
	Local nHrFim    := 0
	Local nDtFim    := 0
	
	lGETACH := .T.
	If type( "aHeader" ) == "A"
		If nTIPO > 0
			lGETACH := .F.
		ElseIf lMNTA401
			lGETACH := .F.
		EndIf
	EndIf

	cREADVAR := Readvar()

	If type("lPREVIS") = "L"
		If lPREVIS
			lCHKQTD := .F.
		EndIf
	EndIf

	If lCHKQTD
		If !lGETACH
			nTIPR := aScan(aHeader,{|x| Trim(Upper(x[2])) == "TL_TIPOREG"})
			nUSAC := aScan(aHeader,{|x| Trim(Upper(x[2])) == "TL_USACALE"})
			nDTIN := aScan(aHeader,{|x| Trim(Upper(x[2])) == "TL_DTINICI"})
			nHOIN := aScan(aHeader,{|x| Trim(Upper(x[2])) == "TL_HOINICI"})
			nDTFI := aScan(aHeader,{|x| Trim(Upper(x[2])) == "TL_DTFIM"})
			nHOFI := aScan(aHeader,{|x| Trim(Upper(x[2])) == "TL_HOFIM"})
			nQUTD := aScan(aHeader,{|x| Trim(Upper(x[2])) == "TL_QUANTID"})
			nCODI := aScan(aHeader,{|x| Trim(Upper(x[2])) == "TL_CODIGO"})
			nUNDA := aScan(aHeader,{|x| Trim(Upper(x[2])) == "TL_UNIDADE"})
			nQtRe := aScan(aHeader,{|x| Trim(Upper(x[2])) == "TL_QUANREC"})

			cTIPR := IIf( lMNTA401, SubStr( cTipoIns, 1, 1 ), aCols[n,nTIPR] )

			If nUSAC > 0 .And. nDTIN > 0 .And. nHOIN > 0 .And. nDTFI > 0 .And. nHOFI > 0 .And. nQUTD > 0 .And. nUNDA > 0;
			.And. ( nCODI > 0 .Or. lMNTA401 ) .And. ( nQtRe > 0 .Or. lMNTA401 .Or. cTIPR == 'M' )

				cTIPO   := aCols[n,nUSAC]
				dDTI    := aCols[n,nDTIN]
				hHI     := aCols[n,nHOIN]
				dDTF    := aCols[n,nDTFI]
				hHF     := aCols[n,nHOFI]
				nQTD    := aCols[n,nQUTD]

				// QUANDO REALIZADO A CHAMADA PELO MNTA401, SOMENTE PARA FERRAMENTA É UTILIZADO A VARIAVÉL PRIVATE.
				If lMNTA401 .And. cTIPR == 'F'

					nQtdeRec := nQuanRec

				// PARA INSUMOS DO TIPPO MÃO DE OBRA NÃO SE VÊ NECESSARIO O PREENCHIMENTO DO CAMPO QTD. RECURSO
				ElseIf !lMNTA401 .And. cTIPR != 'M'

					nQtdeRec := aCols[n,nQtRe]

				Else

					nQtdeRec := 1

				EndIf

				If cREADVAR = "M->TL_HOINICI" .And. cTIPR <> "P" .And.;
					!Empty(dDTI) .And. !Empty(dDTF) .And. !Empty(hHF)
					If dDTI = dDTF .And. M->TL_HOINICI > hHF
						If lMNTA401 .And. (!Empty(aCols[n][nHORAF]) .And. Alltrim(aCols[n][nHORAF]) <> ":")
							MsgInfo(STR0001,STR0002)
							Return .F.
						Else
							MsgInfo(STR0001,STR0002)
							Return .F.
						EndIf
					EndIf
				ElseIf cREADVAR = "M->TL_HOFIM" .And. cTIPR <> "P" .And.;
					!Empty(dDTI) .And. !Empty(dDTF) .And. !Empty(hHI)
					If dDTI = dDTF .And. M->TL_HOFIM < hHI
						MsgInfo(STR0003,STR0002)
						Return .F.
					EndIf
				ElseIf cREADVAR = "M->TL_DTINICI" .And. cTIPR <> "P" .And.;
					!Empty(dDTF)
					If M->TL_DTINICI > dDTF
						MsgInfo(STR0004,STR0002)
						Return .F.
					EndIf
				ElseIf cREADVAR = "M->TL_DTFIM" .And. cTIPR <> "P" .And.;
					!Empty(dDTI)
					If M->TL_DTFIM < dDTI
						MsgInfo(STR0005,STR0002)
						Return .F.
					EndIf
				EndIf
			Else

				// Não será possivel realizar o cálculo de data/hora/quantidade, pois um ou mais campos dentre
				// ( Calendário, Data, Hora e Quantidade ) não foram informados. # Atenção
				MsgStop( STR0006, STR0176 )
				Return .F.

			EndIf

			If lMNTA401
				cCODF := M->TL_CODIGO
			Else
				cCODF := If(cREADVAR = "M->TL_CODIGO",M->TL_CODIGO,aCols[n,nCODI])
			EndIf

			If cREADVAR = "M->TL_USACALE"
				cTIPO   := M->TL_USACALE
			ElseIf cREADVAR = "M->TL_DTINICI"
				dDTI    := M->TL_DTINICI
			ElseIf cREADVAR = "M->TL_HOINICI"
				hHI     := M->TL_HOINICI
			ElseIf cREADVAR = "M->TL_DTFIM"
				dDTF    := M->TL_DTFIM
			ElseIf cREADVAR = "M->TL_HOFIM"
				hHF     := M->TL_HOFIM
			ElseIf cREADVAR = "M->TL_QUANTID"
				nQTD    := M->TL_QUANTID
			ElseIf cREADVAR = "M->TL_QUANREC"
				nQtdeRec := M->TL_QUANREC
			EndIf
		Else
			cTIPO   := M->TL_USACALE
			dDTI    := M->TL_DTINICI
			hHI     := M->TL_HOINICI
			dDTF    := M->TL_DTFIM
			hHF     := M->TL_HOFIM
			nQTD    := M->TL_QUANTID
			cCODF   := M->TL_CODIGO
			cTIPR   := M->TL_TIPOREG
			nQtdeRec := M->TL_QUANREC

			If cREADVAR = "M->TL_HOINICI" .And. cTIPR <> "P" .And.;
				!Empty(dDTI) .And. !Empty(dDTF) .And. !Empty(hHF)
				If dDTI = dDTF .And. M->TL_HOINICI > hHF
					MsgInfo(STR0001,STR0002)
					Return .F.
				EndIf
			ElseIf cREADVAR = "M->TL_HOFIM" .And. cTIPR <> "P" .And.;
				!Empty(dDTI) .And. !Empty(dDTF) .And. !Empty(hHI)
				If dDTI = dDTF .And. M->TL_HOFIM < hHI
					MsgInfo(STR0003,STR0002)
					Return .F.
				EndIf
			ElseIf cREADVAR = "M->TL_DTINICI" .And. cTIPR <> "P" .And.;
				!Empty(dDTF)
				If M->TL_DTINICI > dDTF
					MsgInfo(STR0004,STR0002)
					Return .F.
				EndIf
			ElseIf cREADVAR = "M->TL_DTFIM" .And. cTIPR <> "P" .And.;
				!Empty(dDTI)
				If M->TL_DTFIM < dDTI
					MsgInfo(STR0005,STR0002)
					Return .F.
				EndIf
			EndIf
		EndIf

		hHIV  := If(Alltrim(hHI) = ":",Space(5),hHI)
		hHFV  := If(Alltrim(hHF) = ":",Space(5),hHF)
		nQTDF := 0.00
		lCALE := .F.
		cCALE := ST1->T1_TURNO

		If cTIPO == "S" //Se o funcionário utiliza calendário.
			lCALE := .T.
			If FunName() $ "MNTA990" //Em execução rotina: 'Programação de O.S.'.
				If GetNewPar( "MV_NGFLUT","N" ) == "S" //Se o parâmetro de Turno Flutuante estiver habilitado.
					cCALE := MNTCALFLU( aCols[n,nCODI],aCols[n,nDTIN],aCols[n,nDTIN] ) //Realiza o cálculo conforme turno flutuante.
					If Empty( cCALE ) // Se o funcionário da manutenção não estiver relacionado à uma equipe.
						cCALE := ST1->T1_TURNO //Turno do funcionário da manutenção.
					EndIf
				Else
					cCALE := ST1->T1_TURNO //Turno do funcionário da manutenção.
				EndIf
			Else
				If GetNewPar( "MV_NGFLUT","N" ) == "S" .And. !Empty( M->TL_DTFIM ) //Se utiliza Turno Flut. e a Hora Fim estiver preenchida.
					cCALE := MNTCALFLU( M->TL_CODIGO,M->TL_DTFIM,M->TL_DTFIM ) //Realiza o cálculo conforme turno flutuante.
					If Empty( cCALE ) //Se o fucnionário da manutenção não estiver relaciodado è uma equipe.
						cCALE := ST1->T1_TURNO //Turno do funcionário da manutenção.
					EndIf
				Else
					cCALE := ST1->T1_TURNO //Turno do funcionário da manutenção.
				EndIf
			EndIf
		Else
			cCALE := ST1->T1_TURNO //Turno do funcionário da manutenção.
		EndIf

		// TROCOU O TIPO
		If cREADVAR = "M->TL_USACALE" .AND. cTIPR <> 'P'
			If !Empty(dDTI) .And. !Empty(hHIV) .And. (Empty(dDTF) .Or. Empty(hHFV)) .And. !Empty(nQTD)
				If !NGCALEDTFIM(dDTI,hHIV,nQTD,cCALE)
					Return .F.
				EndIf
			ElseIf !Empty(dDTI) .And. !Empty(hHIV) .And. !Empty(dDTF) .And. !Empty(hHFV)
				NGCALEINTD(dDTI,hHIV,dDTF,hHFV,cCALE)
			ElseIf (!Empty(dDTI) .Or. !Empty(hHIV)) .And. !Empty(dDTF) .And. !Empty(hHFV) .And. !Empty(nQTD)
				NGCALEDTINI(dDTF,hHFV,nQTD,cCALE)
			EndIf

		// DATA E HORA INICIO
		ElseIf (cREADVAR == "M->TL_DTINICI" .Or. cREADVAR == "M->TL_HOINICI" ).And. cTIPR <> 'P'
			If !Empty( dDTI ) .And. !Empty( hHIV ) .And. !Empty( dDTF ) .And. !Empty( hHFV )
				If !COMPDATA( dDTI , hHIV, dDTF, hHFV )
					Return .F.
				EndIf
			EndIf
			If cREADVAR = "M->TL_DTINICI"
				// LENDO A DATA INICIO
				If !Empty(dDTI)
					If !Empty(hHIV)
						If !Empty(dDTF) .And. !Empty(hHFV)
							NGCALEINTD(dDTI,hHIV,dDTF,hHFV,cCALE)
						ElseIf !Empty(nQTD)
							If !NGCALEDTFIM(dDTI,hHIV,nQTD,cCALE)
								Return .F.
						EndIf
					EndIf
				Else
					If !Empty(dDTF) .And. !Empty(hHFV) .And. !Empty(nQTD)
						NGCALEDTINI(dDTF,hHFV,nQTD,cCALE)
					EndIf
				EndIf
			Else
				If !Empty(dDTF) .And. !Empty(hHFV) .And. !Empty(nQTD)
					NGCALEDTINI(dDTF,hHFV,nQTD,cCALE)
				EndIf
			EndIf

		ElseIf cTIPR <> 'P'
			// LENDO A HORA INICIO
			If !Empty(hHIV)
				If !Empty(dDTI)
					If !Empty(dDTF) .And. !Empty(hHFV)
						NGCALEINTD(dDTI,hHIV,dDTF,hHFV,cCALE)
					ElseIf !Empty(nQTD)
						If !NGCALEDTFIM(dDTI,hHIV,nQTD,cCALE)
							Return .F.
						EndIf
					EndIf
				ElseIf !Empty(dDTF) .And. !Empty(hHFV) .And. !Empty(nQTD)
					NGCALEDTINI(dDTF,hHFV,nQTD,cCALE)
				EndIf
			Else
				If !Empty(dDTF) .And. !Empty(hHFV) .And. !Empty(nQTD)
					NGCALEDTINI(dDTF,hHFV,nQTD,cCALE)
				EndIf
			EndIf

		EndIf

		// DATA E HORA FIM
		ElseIf (cREADVAR = "M->TL_DTFIM" .Or. cREADVAR = "M->TL_HOFIM") .AND. cTIPR <> 'P'
			If !Empty( dDTI ) .And. !Empty( hHIV ) .And. !Empty( dDTF ) .And. !Empty( hHFV )
				If !COMPDATA( dDTI , hHIV, dDTF, hHFV )
					Return .F.
				EndIf
			EndIf
			// LENDO A DATA FIM
			If cREADVAR = "M->TL_HOFIM"
				If !Empty(dDTF)
					If !Empty(hHFV)
						If !lMNTA990 .And. dDTF == dDataBase .And. hHFV > substr(Time(),1,5)
							MsgStop(STR0008)
							Return .F.
						EndIf
					If !Empty(dDTI) .And. !Empty(hHIV)
						NGCALEINTD(dDTI,hHIV,dDTF,hHFV,cCALE)
					ElseIf !Empty(nQTD)
						NGCALEDTINI(dDTF,hHFV,nQTD,cCALE)
					EndIf
				Else
					If !Empty(dDTI) .And. !Empty(hHIV) .And. !Empty(nQTD)
						If !NGCALEDTFIM(dDTI,hHIV,nQTD,cCALE)
							Return .F.
						EndIf
					EndIf
				EndIf
			Else
				If !Empty(dDTI) .And. !Empty(hHIV) .And. !Empty(nQTD)
					If !NGCALEDTFIM(dDTI,hHIV,nQTD,cCALE)
						Return .F.
					EndIf
				EndIf
			EndIf

		ElseIf cTIPR <> 'P'
			// LENDO A HORA FIM
			If !Empty(hHFV)
				If !Empty(dDTF)
					If !lMNTA990 .And. dDTF == dDataBase .And. hHFV > substr(Time(),1,5)
						MsgStop(STR0008)
						Return .F.
					EndIf
					If !Empty(dDTI) .And. !Empty(hHIV)
						NGCALEINTD(dDTI,hHIV,dDTF,hHFV,cCALE)
					ElseIf !Empty(nQTD)
						NGCALEDTINI(dDTF,hHFV,nQTD,cCALE)
					EndIf
				ElseIf !Empty(dDTI) .And. !Empty(hHIV) .And. !Empty(nQTD)
					NGCALEDTINI(dDTF,hHFV,nQTD,cCALE)
				EndIf
			Else
				If !Empty(dDTI) .And. !Empty(hHIV) .And. !Empty(nQTD)
					If !NGCALEDTFIM(dDTI,hHIV,nQTD,cCALE)
						Return .F.
					EndIf
				EndIf
			EndIf
		EndIf

		ElseIf (cREADVAR = "M->TL_QUANTID" .Or. IsInCallStack("MNTA435")) .AND. cTIPR <> 'P'
			// OK
			If !Empty(nQTD)
				If !Empty(dDTI) .And. !Empty(hHIV)
					If !NGCALEDTFIM(dDTI,hHIV,nQTD,cCALE)
						Return .F.
					EndIf
				Else
					If (Empty(dDTI) .Or. Empty(hHIV)) .And. (!Empty(dDTF) .And. !Empty(hHFV))
						NGCALEDTINI(dDTF,hHFV,nQTD,cCALE)
					EndIf
				EndIf
			Else
				If !Empty(dDTI) .And. !Empty(hHIV) .And. !Empty(dDTF) .And. !Empty(hHFV)
					NGCALEINTD(dDTI,hHIV,dDTF,hHFV,cCALE)
				EndIf
			EndIf
		EndIf
		//Atualiza a variavel de quantidade
		If lGETACH .AND. cTIPR <> 'P'
			nQTD  := M->TL_QUANTID
		EndIf

		If lMNTA401 .AND. cTIPR <> 'P'
			If dDataBase <= aCols[n][nDATAF] .And. !Empty(aCols[n][nHORAF]) .And. !Empty(aCols[n][nHORAI]) .And. HTOM(aCols[n][nHORAF]) > HTOM(Substr(Time(),1,5))
				MsgStop(STR0186) //"A quantidade informada excede o cálculo da hora fim, não podendo ser maior que a hora atual."
				aCols[n][nHORAF] := M->TL_HOFIM
				aCols[n][nDATAF] := M->TL_DTFIM
				Return .F.
			ElseIf aCols[n][nDATGD] < aCols[n][nDATAF] .And. !Empty(M->TL_HOFIM) .And. !Empty(aCols[n][nHORAI]) .And. aCols[n][nDATAF] > dDataBase
				MsgStop(STR0187) //"A quantidade informada excede o cálculo da data fim, não podendo ser maior que a data atual."
				aCols[n][nHORAF] := M->TL_HOFIM
				aCols[n][nDATAF] := M->TL_DTFIM
				Return .F.
			EndIf
		EndIf

		nCust := aScan(aHeader,{|x| Trim(Upper(x[2])) == "TL_CUSTO"})
		If nCust > 0
			nCustOld := aCols[n][nCust]
		EndIf

		If cTIPR <> "T" .OR. lIntEsto

			// Atribui o custo ja tratado, passando sempre ele como 'realizado'
			M->TL_CUSTO := Round( NGCALCUSTI( cCODF , cTIPR , nQTD , , , , , nQtdeRec , "1" , , nCustOld ) , 2 )

			nCust := aScan(aHeader,{|x| Trim(Upper(x[2])) == "TL_CUSTO"})
			If nCust > 0
				aCols[n][nCust] := M->TL_CUSTO
			EndIf

		Endif

	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} NGCALEDTFIM
Calcula a quantidade de horas no intervalo de datas e horas

@author	 Inacio Luiz Kolling
@since	 30/09/2005
@version MP11
@return .T.
/*/
//---------------------------------------------------------------------
Function NGCALEDTFIM( dDTIV,hHIVV,nQTDV,cCALEV )

	vVETDTRET := If( !lCALE,NGDTHORFIM(dDTIV,hHIVV,nQTDV),NGDTHORFCALE(dDTIV,hHIVV,nQTDV,cCALEV) )

	If IsInCallStack( "MNTA231" ) .Or. IsInCallStack( "MNTA232" )
		If vVETDTRET[1] = dDatabase
			If vVETDTRET[2] > SubStr(Time(),1,5)
				MsgStop(STR0009)
				Return .F.
			EndIf
		ElseIf vVETDTRET[1] > dDatabase
			MsgStop(STR0010)
			Return .F.
		EndIf
	EndIf

	NGCALECARV( dDTIV,hHIVV,vVETDTRET[1],vVETDTRET[2],nQTDV )

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGCALEDTINI ³ Autor ³Inacio Luiz Kolling    ³ Data ³30/09/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula a quantidade de horas no intervalo de datas e horas   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICA                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGCALEDTINI(dDTFV,hHFVV,nQTDV,cCALEV)
	vVETDTRET := IIf(!lCALE,NGDTHORINI(dDTF,hHFV,nQTD), NGDTHRICLD(dDTF,hHFV,nQTD,cCALEV))
	NGCALECARV(vVETDTRET[1],vVETDTRET[2],dDTFV,hHFVV,nQTDV)
Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGCALECARV  ³ Autor ³Inacio Luiz Kolling    ³ Data ³30/09/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula a quantidae de horas no intervalo de datas e horas    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICA                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGCALECARV(vDTIF,vHIF,dDTFF,hHFF,nQTDF)
Local nDTI1,nHOI1,nDTF2,nHOF2,nQUT1,nUND1,lTemA := .F.

Store 0 To nDTI1,nHOI1,nDTF2,nHOF2,nQUT1,nUND1
If type("aHeader") = "A"
   nDTI1 := GDFIELDPOS("TL_DTINICI",aHEADER)
   nHOI1 := GDFIELDPOS("TL_HOINICI",aHEADER)
   nDTF2 := GDFIELDPOS("TL_DTFIM"  ,aHEADER)
   nHOF2 := GDFIELDPOS("TL_HOFIM"  ,aHEADER)
   nQUT1 := GDFIELDPOS("TL_QUANTID",aHEADER)
   nUND1 := GDFIELDPOS("TL_UNIDADE",aHEADER)
   lTemA := .T.
EndIf

If !lGETACH
   aCols[n,nDTIN] := vDTIF
   aCols[n,nHOIN] := vHIF
   aCols[n,nDTFI] := dDTFF
   aCols[n,nHOFI] := hHFF
   aCols[n,nQUTD] := nQTDF
   aCols[n,nUNDA] := "H"
Else
	If FunName() == "MNTA992"
	   M->TTL_DTINI  := vDTIF
	   M->TTL_HRINI  := vHIF
	   M->TTL_DTFIM  := dDTFF
	   M->TTL_HRFIM  := hHFF
	   M->TTL_QUANTI := nQTDF
	Else
	   M->TL_DTINICI := vDTIF
	   M->TL_HOINICI := vHIF
	   M->TL_DTFIM   := dDTFF
	   M->TL_HOFIM   := hHFF
	   M->TL_QUANTID := nQTDF
	   M->TL_UNIDADE := "H"
	   If lTemA
	      If nDTI1 > 0
	         aCols[n,nHOI1] := vHIF
	      EndIf
	      If nDTF2 > 0
	         aCols[n,nDTF2] := dDTFF
	      EndIf

	      If nHOF2 > 0
	         aCols[n,nHOF2] := hHFF
	      EndIf

	      If nQUT1 > 0
	         aCols[n,nQUT1] := nQTDF
	      EndIf

	      If nUND1 > 0
	         aCols[n,nUND1] := "H"
	      EndIf
	   EndIf
EndIf
EndIf
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} COMPDATA
Consistência de data e hora
@author   NG INFORMATICA
@since
@version P11
@use Genérico
@parameters - dDataIni - Data inicial a ser comparada  - Obrigatorio
              cHoraIni - Hora inicial a ser comparada  - Obrigatorio
              dDataFim - Data Fim a ser comparada      - Obrigatorio
              cHoraFim - Hora Fim a ser comparada      - Obrigatorio
@obs Conteudo da variavel das variaveis que armazenam horas devem
vir formato "00:00"
/*/
//-------------------------------------------------------------------
Function COMPDATA(dDataIni, cHoraIni, dDataFim, cHoraFim)

    Local lRet := .T.

    cHoraIni := HtoM(cHoraIni)
    cHoraFim := HtoM(cHoraFim)

    If (dDataIni > dDataFim)
        lRet := .F.
    EndIf

    If (dDataIni == dDataFim)
        lRet := (cHoraIni <= cHoraFim)
    EndIf

    If !lRet
        If 	IsInCallStack("MNTA150") .Or. IsInCallStack("MNTA160")
            //" A hora final do bloqueio não pode ser inferior ou igual à hora inicial." - "Alterar o campo Hora Final."
            Help(Nil, Nil, "NGATENCAO", Nil, STR0192 + CRLF + CRLF + STR0193, 1, 0)
        Else
            Help(" ", 1, "HORAINVALI")
        EndIf
    EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} TimeWork
Cálcula o tempo entre duas data e hora considerando o calendario.
@type function

@author Alexandre Santos
@since 22/04/2019

@sample TimeWork( 28/05/1996, '08:00', 29/05/1996, '07:45', 'Calend' )

@param  dIni     , Data    , Data Inicio.
@param  hIni     , Caracter, Hora Inicio.
@param  dFim     , Data    , Data Fim.
@param  hFim     , Caracter, Hora Fim.
@param  cCode    , Caracter, Código do calendário que deve ser considerado.
@param  [cFilSH7], Caracter, Filial de referencia para o cadastro de calendário.
@return Númerico, Tempo em minutos entre o período definido por parãmetro.
/*/
//---------------------------------------------------------------------
Function TimeWork( dINI, hINI, dFIM, hFIM, cCode, cFilSH7 )

	Local aDia      := {}
	Local aArea     := GetArea()
	Local nPos      := 1
	Local nX        := 0
	Local nY        := 0
	Local nFim      := 0
	Local nIni      := 0
	Local nHora     := 0.00
	Local dAtu

	Default cFilSH7 := xFilial( 'SH7' )

	dbSelectArea( 'SH7' )
	dbSetOrder( 1 ) // H7_FILIAL + H7_CODIGO
	If dbSeek( cFilSH7 + cCode )

		aDIA := NG_H7( SH7->H7_CODIGO )

	EndIf

	If Len( aDIA ) == 0
		Help( '', 1, 'CALENDINEX' )
		Return -1.00
	EndIf

	dAtu := dIni
	nIni := HtoM( hIni )

	For nY := 1 To ( ( dFim - dIni ) + 1 )

		nPos := IIf( Dow( dAtu ) == 1, 7, Dow( dAtu )-1 )

		If nY > 1

			nIni := HtoM( aDia[nPos,1] )

			// Caso neste dia não haja horários disponiveis.
			If HtoM( aDia[nPos,3] ) == 0
				dAtu++
				Loop
			EndIf

		// Caso neste dia não haja horarios disponiveis, passa para o próximo dia.
		ElseIf HtoM( aDia[nPos,3] ) == 0
			dAtu++
			Loop
		EndIf

		// Caso o dia atual seja o mesmo que o fim do perído.
		If dFim == dAtu

			// Assume-se que a hr. fim do periodo, de fato é o horario fim no dia atual.
			nFim  := HtoM( hFIM )

			// Caso o fim do perído não seja no mesmo dia que o inicio.
			If dFim != dIni

				// Se hr. fim for maior que o primeiro horario disponivel no calendário.
				If nFim > HtoM( aDia[nPos,1] )

					// Considera o intervalo a diferença entre o primeiro e o final do periodo.
					nHora += ( nFim - HtoM( aDia[nPos,1] ) )

				EndIf

			// Caso o período inicie e encerre no mesmo dia.
			Else

				// Caso inicio e fim estejam no memso dia, considera a diferença entre estes como o intervalo.
				nHora += ( nFim - nIni )

			EndIf

		// Caso o dia atual NÃO seja o mesmo que o fim do perído.
		Else

			// Assume-se que a ultima hora dispnivel no calendario será considerada horario fim no dia atual.
			nFim  := HtoM( aDia[nPos,2] )

			// CASO A DATA INICIO SEJA A DATA ATUAL
			If dAtu == dIni

				// CONSIDERA O INTERVALO A DIFERENÇA ENTRE O ÚLTIMO HORÁRIO DO CALENDÁRIO E O INÍCIO DO PERÍODO.
				nHora += nFim - nIni

			// CASO O FIM DO PERÍODO NÃO SEJA NO MESMO DIA QUE O INICIO.
			ElseIf dFim != dIni

				// CONSIDERA O INTERVALO A DIFERENÇA ENTRE O ÚLTIMO E OPRIMEIRO HORÁRIO DO CALENDÁRIO.
				nHora += nFim - HtoM( aDia[nPos,1] )

			EndIf

		EndIf

		If nHora > 0

			// Loop para dedução dos intevalos de parada do calendário.
			For nX := 1 to Len( aDia[nPos,4] )

				Do Case

					// Caso inicio e fim não estejam no mesmo dia, e o dia atual seja o fim.
					Case ( dIni != dFim .And. dAtu == dFim )

						// Caso exista um intervalo entre o inicio e fim do perido no dia atual.
						If nFim > aDia[nPos,4,nX,2] .And. nIni < aDia[nPos,4,nX,2]

							nHora -= ( aDia[nPos,4,nX,2] - aDia[nPos,4,nX,1] )

						// Caso a Hora Fim esteja no intervalo de parada.
						ElseIf ( nFim >= aDia[nPos,4,nX,1] .And. nFim <= aDia[nPos,4,nX,2] ) .And. nFim != HToM( aDia[nPos,1] )

							nHora -= ( nFim - aDia[nPos,4,nX,1] )

						EndIf

					// Caso inicio e fim não estejam no mesmo dia, e o dia atual seja o inicio.
					Case ( dIni != dFim .And. dAtu == dIni )

						// Caso exista um intervalo entre o inicio e fim do perido no dia atual.
						If nIni < aDia[nPos,4,nX,1] .And. nFim > aDia[nPos,4,nX,2]

							nHora -= ( aDia[nPos,4,nX,2] - aDia[nPos,4,nX,1] )

						// Caso a Hora Inicio esteja no intervalo de parada.
						ElseIf nIni >= aDia[nPos,4,nX,1] .And. nIni <= aDia[nPos,4,nX,2]

							nHora -= ( aDia[nPos,4,nX,2] - nIni )

						EndIf

					// Caso a Hr. Inicio comece antes de uma hora de parada e a Hr. Fim encerre após.
					Case ( nIni < aDia[nPos,4,nX,1] .And. nFim > aDia[nPos,4,nX,2] )
						nHora -= ( aDia[nPos,4,nX,2] - aDia[nPos,4,nX,1] )

					// Caso a Hora Inicio e Fim estejam no intervalo de parada.
					Case ( nIni >= aDia[nPos,4,nX,1] .And. nFim <= aDia[nPos,4,nX,2] )
						nHora -= ( nFim - nIni )

					// Caso a Hora Fim esteja no intervalo de parada.
					Case ( nFim >= aDia[nPos,4,nX,1] .And. nFim <= aDia[nPos,4,nX,2] )
						nHora -= ( nFim - aDia[nPos,4,nX,1] )

					// Caso a Hora Inicio esteja no intervalo de parada.
					Case ( nIni >= aDia[nPos,4,nX,1] .And. nIni <= aDia[nPos,4,nX,2] )
						nHora -= ( aDia[nPos,4,nX,2] - nIni )

				EndCase

			Next nX

		EndIf

		dAtu++

	Next nY

	RestArea( aArea )

Return nHora/60

//--------------------------------------------------------------------------------------------------
/*/{Proteus.doc} NGCalcHour
Calcula intervalo de horas entre data + hora inicio e fim referente a um insumo, quando utiliza-se
de calendário ou não.
@type function

@author Alexandre Santos
@since  04/06/2019

@sample NGCalcHour( 'Adalberto', { 21/01/2019, '00:15', 22/01/2019, '09:00' }, 'S' )

@param  cCode   , Caracter, Código do Insumo.
@param  aTime   , Array   , [1] - Data inicio.
						 	[2] - Hora inicio.
						 	[3] - Data fim.
						 	[4] - Hora fim.
@param, cUseCld , Caracter, Define se ultiliza calendário.
@param  [cFilH7], Caracter, Filial para posicionamento na SH7.
@return Númerico, Intervalo em horas referente ao periodo passado por parâmetro.
/*/
//------------------------------------------------------------------------------------------------
Function NGCalcHour( cCode, aTime, cUseCld, cFilH7 )

	Local nHours    := 0.0
	Local lUseCld   := ( cUseCld == 'S' )
	Local cCalendar := IIf( lUseCld, Trim( Posicione( 'ST1', 1, xFilial( 'ST1' ) + cCode, 'T1_TURNO' ) ), '' )

	If lUseCld
		nHours := TimeWork( aTime[1], aTime[2], aTime[3], aTime[4], cCalendar, cFilH7 )
	Else
		nHours := NGCALCH100( aTime[1], aTime[2], aTime[3], aTime[4] )
	EndIf

Return nHours

//---------------------------------------------------------------------
/*{Protheus.doc} NgTraNtoH
Função que ajusta o parâmetro recebido "nHora" para o formato correto de hora.
Exemplo: 0.10 -> 00:10

@return cHoral

@param nHora - Valor que será convertido para o formato de hora.

@author Elynton Fellipe Bazzo
@since 02/08/2013
@version 1.0
//---------------------------------------------------------------------
*/
Function NgTraNtoH(nHora)

    //Varáveis utilizadas na função
	Local cHoral := cValToChar(nHora)
	Local cHR 	 := ""
	Local cMin	 := ""
	Local nPos

	If nHora == 0 // Se o valor que vier como parâmetro estiver vazio ou igual a zero.
		cHoral :=  '00:00'
		Return cHoral //Retorna o formato em ZERO de horas: '00:00'
	EndIf

	nPos := At('.',cHoral) //Retorna a posição da string passada como parâmetro até o ponto ('.').

	If nPos == 0 // Se o valor de horas não vier em formato de horas, Ex: '01:00'
		xHora := Val( cHoral )
		cHoral := MToH( xHora * 60 ) // Chama a função que converte minutos em horas.
	EndIf

	If nPos > 0  // Busca a parte da frente referente a Horas.
		If Len(SubStr(cHoral,1,nPos-1)) < 2 // Tratamento parte da frente de horas quando menor que 1 para add numero de zero.
			cHR := '0'+ SubStr(cHoral,1,nPos-1)
		Else
			cHR := SubStr(cHoral,1,nPos-1)
		EndIf
	EndIf

	If nPos > 0 // Busca a parte de tras referente a Minutos, (após o ponto).
		If Len(SubStr(cHoral,nPos+1,Len(cHoral))) < 2  // Tratamento parte de tras de horas quando menor que 1 para add numero de zero.
			cMin := SubStr(SubStr(cHoral,1,nPos-1) +'.'+ SubStr(cHoral,nPos+1,Len(cHoral)) + '0',nPos+1,Len(cHoral))
		Else
			cMin := SubStr(cHoral,nPos+1,Len(cHoral))
		EndIf
	EndIf

	If nPos <> 0
	cHoral := cHR + ':' + cMin // Retorna o formato em hora
	EndIf

Return cHoral
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³NGCALCH060³ Autor ³In cio Luiz Kolling    ³ Data ³10/02/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula a quantidade de horas entre datas e horas em 60     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ dDTAINI  - Data inicial                    - Obrigat¢rio   ³±±
±±³          ³ hHORINI  - Hora inicial                    - Obrigat¢rio   ³±±
±±³          ³ dDTAFIM  - Data final                      - Obrigat¢rio   ³±±
±±³          ³ hHORFIM  - Hora final                      - Obrigat¢rio   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³nHORETO   - Quantidade de horas em valor numerico           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGCALCH060(dDTAINI,hHORINI,dDTAFIM,hHORFIM)
Local nQTDH060 := 0

If dDTAINI = dDTAFIM
   nQTDH060 := Htom(hHORFIM)-Htom(hHORINI)
Else
   nQDIAS := (dDTAFIM - dDTAINI)+1
   nLDIAS := 1
   dLDATA := dDTAINI
   While nLDIAS <= nQDIAS
      If dLDATA = dDTAINI
         nQTDH060 := Htom('24:00')-Htom(hHORINI)
      ElseIf dLDATA = dDTAFIM
         nQTDH060 := nQTDH060+Htom(hHORFIM)
      Else
         nQTDH060 := nQTDH060+Htom('24:00')
      EndIf
      dLDATA += 1
      nLDIAS += 1
   End
EndIf

cHORA060 := Alltrim(Mtoh(nQTDH060))
nPOS060  := AT(":",cHORA060)

If nPOS060 > 0
   nHORA060 := Substr(cHORA060,1,(nPOS060-1))
   nMIN060  := Substr(cHORA060,(nPOS060+1))
   nQTDH060 := Val(nHORA060+"."+nMIN060)
EndIf
Return nQTDH060

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGDTHORFIM³ Autor ³Inacio Luiz Kolling    ³ Data ³04/08/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula a data e hora fim a partir de uma data e hora       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICA                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGDTHORFIM(dVDATI,cVHORI,nQTDHO,cUniDt)
Local cIni  := HTOM(cVHORI)
Local cDat  := dVDATI
Local nHint := Int(nQTDHO)
Local nRest := (nQTDHO - nHint) * 100
Local nSoma := 0
Local cFim

// Caso a parametro cUniDt (funcao) esteja definido, prioriza o mesmo perante o parametro MV_NGUNIDT (SX6)
Default cUniDt := SuperGetMV("MV_NGUNIDT", .F., "")

cFim := cIni + If( cUniDt == "D", (nQTDHO * 60), ( (nHint * 60) + nRest) )

// Verifica a quantidade de dias a serem somados, conforme a quantidade de horas repassada
While cFim >= 1440
   nSoma++
   cFim -= 1440
End

// Define retorno (Data Final e Hora final)
dDATF  := cDat + nSoma
cHORAF := MTOH(cFim)

Return {dDATF,cHORAF}

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGDTHORINI³ Autor ³Inacio Luiz Kolling    ³ Data ³30/09/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula a data e hora inicio a partir de uma data e hora fim³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICA                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGDTHORINI(dVDATF,cVHORF,nQTDHO)
Local cINI  := HTOM(cVHORF),cDAT := dVDATF
Local nSOMA := 0
Local cFIM  := nQTDHO * 60
While cFIM > 1440
   nSOMA++
   cFIM -= 1440
End
If nSOMA = 0
   nTTH := nQTDHO * 60
   nDIf := cINI - nTTH
   If nDIf < 0
      dDATF  := cDAT-1
      cHORAF := MTOH(1440 - (nTTH - cINI))
   Else
      dDATF  := cDAT
      cHORAF := MTOH(cINI-nTTH)
   EndIf
Else
   dDATF := cDAT-nSOMA
   nDIf  := cFIM - 1440
   If nDIf < 0 .Or. nDIf = 0
      dDATF  := dDATF - 1
      cHORAF := If(nDIf = 0,MTOH(cINI),MTOH(1440 - cFIM))
   Else
      nDIF   := 1440 - cFIM
      cHORAF := MTOH(nDIF)
   EndIf
EndIf
Return {dDATF,cHORAF}

//---------------------------------------------------------------------
/*/{Protheus.doc} NGDTHRICLD
Calcula a data e hora inicio a partir da data e hora fim
utilizando calendario.

Obs: Repasse da v118

@param	dDateF	, Caracter	, Data fim
		cHoraF	, Caracter	, Hora fim
		nQuant	, Numerico	, Quantidade de horas utilizadas
		cCalend	, Caracter	, Calendário utilizado
@return aRet	, Array		, Array contendo data inicio e hora inicio.

@author	Alexandre Santos
@since	24/04/18
/*/
//---------------------------------------------------------------------
Function NGDTHRICLD(dDateF,cHoraF,nQuant,cCalend)
	Local cHini  := "  :  "
	Local lPrimx := .F.
	Local lSair	 := .F.
	Local lCale := .F.
	Local nSoDia := 0
	Local nX	 := 0
	Local nY	 := 0
	Local nDias  := Dow(dDateF)
	Local nSomH  := 0.00
	Local nSomaH := nQuant * 60
	Local nSOMIN := 0
	Local nHOARF := 0
	Local nHOARI := 0
	Local aRet	 := {}

	If Type('aMATCA') == "U"
		aMATCA := NGCALENDAH(cCalend)
		lCale := .T.
	EndIf

	Do While !lSair
		For nX := nDias To 1 step - 1
			For nY := Len(aMATCA[nX,2]) To 1 step - 1
				If !lPrimx
					If (cHoraF >= aMATCA[nX,2,nY,1] .And. cHoraF <= aMATCA[nX,2,nY,2])
						lPrimx := .T.
						nHOARF := Htom(cHoraF)
						nHOARI := Htom(aMATCA[nX,2,nY,1])
						nSomH  := nHOARF - nHOARI
						If nSomH >= nSomaH
							If nSomH > nSomaH
								cHini := Mtoh(nHOARF - nSomaH)
							Else
								cHini := Mtoh(nHOARI)
							EndIf
							lSair := .T.
							Exit
						EndIf
					EndIf
				Else
					nHOARI := Htom(aMATCA[nX,2,nY,1])
					nHOARF := Htom(aMATCA[nX,2,nY,2])
					nSOMIN := nHOARF - nHOARI
					nSomH  += nSOMIN
					If nSomH >= nSomaH
						If nSomH > nSomaH
							cHini := Mtoh(nHOARI+(nSomH - nSomaH))
						Else
							cHini := Mtoh(nHOARI)
						EndIf
						lSair := .T.
						Exit
					EndIf
				EndIf
			Next nY
			If lSair
				Exit
			Else
				nSoDia := nSoDia + 1
			EndIf
		Next nX

		If lSair
			Exit
		Else
			nDias := 7
		EndIf
	EndDo
	aRet := {dDateF-nSoDia,cHini}
Return aRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGDTHORFCALE³ Autor ³Inacio Luiz Kolling    ³ Data ³30/09/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula a data e hora fim usando calenedario                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICA                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGDTHORFCALE(dVDTI,hVHI,nVQTD,cVCALE)
Local nDIAS  := Dow(dVDTI)
Local nSOMH  := 0.00
Local nSOMAH := Round((NGCONVERHORA(nVQTD,"S","D") * 60),0)
Local hHFC   := "  :  "
Local lPRIMX ,lSAIR
Local nSODIA,iX,iY,nFcal := 0
Local lCALE := .F.

Store 0 To nSODIA,iX,iY
Store .F. To lPRIMX,lSAIR

If type('aMATCA') == "A"
Else
   aMATCA := NGCALENDAH(cVCALE)
   lCALE  := .T.
EndIf

While !lSAIR
   For iX := nDIAS To 7
      For iY := 1 To Len(aMATCA[iX,2])
         If !lPRIMX
            If (hVHI >= aMATCA[iX,2,iY,1] .And. hVHI < aMATCA[iX,2,iY,2])
               lPRIMX := .T.
               nHOARF := Htom(aMATCA[iX,2,iY,2])
               nHOARI := Htom(hVHI)
               nSOMH  := nHOARF - nHOARI
               If nSOMH >= nSOMAH
                  If nSOMH > nSOMAH
                     hHFC := Mtoh(nHOARF - (nSOMH - nSOMAH))
                  Else
                     hHFC := Mtoh(nHOARF)
                  EndIf
                  lSAIR := .T.
                  Exit
               EndIf
            ElseIf ( hVHI >= aMATCA[iX,2,iY,1] .And. hVHI == aMATCA[iX,2,iY,2] )
            	lPRIMX := .T.
            EndIf
         Else
            nHOARI := Htom(aMATCA[iX,2,iY,1])
            nHOARF := Htom(aMATCA[iX,2,iY,2])
            nSOMIN := nHOARF - nHOARI
            nSOMH  += nSOMIN
            If nSOMH >= nSOMAH
               If nSOMH > nSOMAH
                  hHFC := Mtoh(nHOARF-(nSOMH - nSOMAH))
               Else
                  hHFC := Mtoh(nHOARF)
               EndIf
               lSAIR := .T.
               Exit
            EndIf
         EndIf
      Next iY
      If lSAIR
         Exit
      Else
         nSODIA := nSODIA + 1
      EndIf
   Next iX

   If lSAIR
      Exit
   Else
      nDIAS := 1
   EndIf

   nFcal ++
   If nFcal > 2 .And. !lPRIMX
      Exit
   EndIf
End
If hHFC == "24:00"
	hHFC := "00:00"
	nSODIA := nSODIA + 1
EndIf
Return {dVDTI+nSODIA,hHFC}

//---------------------------------------------------------------------
/*/{Protheus.doc} NGDtHrCale
Verifica se a Data e Hora iniciais são válidas de acordo com um
determinado calendário.
Caso sejam inválidas a data e a horas iniciais passadas como parâmetro
da função, será retornada a próxima data/hora possível de acordo com
o calendário.

@author Wagner Sobral de Lacerda
@since 17/10/2012

@param dDtIni
	Data Inicial * Obrigatório
@param cHrIni
	Hora Inicial * Obrigatório
@param cCalend
	Código do Calendário * Obrigatório

@return aDtHrCale
/*/
//---------------------------------------------------------------------
Function NGDtHrCale(dDtIni, cHrIni, cCalend)

	// Variável do Retorno
	Local aDtHrCale := {dDtIni, cHrIni}

	// Variáveis do Calendário
	Local aCalend := {}
	Local lCalendOK := .F.

	Local dDtCalend := dDtIni
	Local cHrCalend := ""

	Local nDiaSemana := 0

	Local aTurno := {}
	Local nTurno := 0

	Local lFirst := .T.

	//----------
	// Executa
	//----------
	//-- Busca o Calendário
	aCalend := NGCALENDAH(cCalend)
	If Len(aCalend) > 0
		While !lCalendOK
			// Recebe o Dia da Semana (Day Of Week)
			nDiaSemana := DOW(dDtCalend)

			// Verifica se o Calendário é válido
			If HTON(aCalend[nDiaSemana][1]) > 0 .And. Len(aCalend[nDiaSemana][2]) > 0
				// Procura Data e Hora válidas no Turno
				aTurno := aClone( aCalend[nDiaSemana][2] )
				For nTurno := 1 To Len(aTurno)
					// Se for o primeiro registro, verifica se a hora passada como parâmetro é válida no turno
					If lFirst
						// Se a Hora Inicial for menor que a Hora Final do Turno, então o registro é válido
						If cHrIni < aTurno[nTurno][2]
							cHrCalend := cHrIni
							lCalendOK := .T.
						EndIf
					Else // Recebe o próximo turno válido
						// Se for um dia posterior, o turno é válido
						If dDtCalend > dDtIni
							cHrCalend := aTurno[nTurno][1]
							lCalendOK := .T.
						Else // Senão, o turno só será válido se a Hora Inicial for menor que a Final do turno
							If cHrIni < aTurno[nTurno][2]
								cHrCalend := aTurno[nTurno][1]
								lCalendOK := .T.
							EndIf
						EndIf
					EndIf

					// Se já encontrou a Hora válida, encerra a busca
					If lCalendOK
						Exit
					EndIf

					// Se for o primeiro, indica que não é mais o primeiro turno sendo verificado, o que permite que o próximo turno válido seja recebido
					If lFirst
						lFirst := .F.
					EndIf
				Next nTurno
			EndIf

			// Se já encontrou a Hora válida, encerra a busca
			If lCalendOK
				Exit
			EndIf

			// Se não for, recebe o próximo
			dDtCalend++
		End
	EndIf

	//-- Define o Retorno
	aDtHrCale := {dDtCalend, cHrCalend}

Return aDtHrCale

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGSOMAHNUM³ Autor ³ Elisangela Costa      ³ Data ³ 07/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Soma horas em numerico em uma variavel                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nHORACONS = Quantidade de horas              -obrigatorio   ³±±
±±³          ³nSOMAPARA = Quantidade ja somada             -obrigatorio   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³nSOMAHOTO = Soma total das horas                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGSOMAHNUM(nHORACONS,nSOMAPARA)

nPARTINTS := Int(nSOMAPARA)
nMINISRES := nSOMAPARA-nPARTINTS
cMINISRES := Alltrim(Str(nMINISRES,10,2))
nPOSPONTS := At(".",cMINISRES)
cPARSRESS := Alltrim(Substr(cMINISRES,nPOSPONTS+1,Len(cMINISRES)))
nPARSRESS := Val(cPARSRESS)

nPARTINTH := Int(nHORACONS)
nMINISREH := nHORACONS-nPARTINTH
cMINISREH := Alltrim(Str(nMINISREH,10,2))
nPOSPONTH := At(".",cMINISREH)
cPARSRESH := Alltrim(Substr(cMINISREH,nPOSPONTH+1,Len(cMINISREH)))
nPARSRESH := Val(cPARSRESH)

nSOMAMINU := nPARSRESS + nPARSRESH

If nSOMAMINU > 59
   cPARTINTS := Alltrim(Str(nPARTINTS + 1,10))
   cMINISRES := "00"
   nPARSRESF := nSOMAMINU - 60

   cHORAINTS := cPARTINTS+"."+cMINISRES
   If nPARSRESF < 10
      cHORAINTH := Alltrim(Str(nPARTINTH))+".0"+Alltrim(Str(nPARSRESF))
   Else
      cHORAINTH := Alltrim(Str(nPARTINTH))+"."+Alltrim(Str(nPARSRESF))
   EndIf

   nSOMAHOTO := Val(cHORAINTS)+Val(cHORAINTH)

Else
   nSOMAHOTO := nSOMAPARA + nHORACONS
EndIf

Return nSOMAHOTO

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³NGCALCDHM ³ Autor ³Inacio Luiz Kolling    ³ Data ³24/11/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Calcula a quantidade de dias,horas e minuitos entre duas    ³±±
±±³          ³datas e horas                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³dDTI  - Data inicio                           - Obrigatorio ³±±
±±³          ³hHI   - Hora inicio                           - Obrigatorio ³±±
±±³          ³dDTF  - Data fim                              - Obrigatorio ³±±
±±³          ³hHF   - Hora fim                              - Obrigatorio ³±±
±±³          ³cCALE - Codigo do calendario                  - Nao Obrigat.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³OBSERVACAO³Funcao funcional. Considera 24 horas ao dia, quando nao for ³±±
±±³          ³informado o codigo do calendario. Quando for informado a    ³±±
±±³          ³quantidade de dias,horas e minutos sÆo considerado as horas ³±±
±±³          ³validas informadas no periodo do calendario.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³Vetor - [1] - Qdte dias, [2] Qdte horas, [3] Qdte minutos.  ³±±
±±³          ³        {2,5,15}                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGCALCDHM(dDTI,hHI,dDTF,hHF,cCALE)
Local nHORT,nDIAF,nRESD,nHORF,nMINF,XH,nQTDHCAL,nDIASE,aCALENH
Local nHORF1,nMINF1,nHORF2,nMINF2,nHORFX,nMINUX,nTOTHO,lPRIMH,lTERMI
Private cSOMAH := Space(12)

Store 0 To nHORT,nDIAF,nRESD,nHORF,nMINF,XH,nQTDHCAL,nDIASE
Store 0 To nHORF1,nMINF1,nHORF2,nMINF2,nHORFX,nMINUX,nTOTHO

If cCALE = Nil .Or. Empty(cCALE)
   nHORT := Htom(NGCALCHCAR(dDTI,hHI,dDTF,hHF))
   nDIAF := Int(nHORT/1440)
   nRESD := nHORT - (nDIAF * 1440)
   nHORF := Int(nRESD/60)
   nMINF := nRESD - (nHORF * 60)
Else
   dbSelectArea("SH7")
   dbSetOrder(1)
   If dbSeek(xFilial("SH7")+cCALE)
      aCALENH := NGCALENDAH(cCALE)
      If dDTI = dDTF
         Store .F. To lPRIMH,lTERMI
         nDIASE := Dow(dDTI)
         If Len(aCALENH[nDIASE,2]) > 0
            If hHI <= aCALENH[nDIASE,2,1,1] .And. hHF >= aCALENH[nDIASE,2,Len(aCALENH[nDIASE,2]),2]
               nDIAF := 1
            Else
               For XH := 1 To Len(aCALENH[nDIASE,2])
                  If hHI >= aCALENH[nDIASE,2,XH,1] .And. hHI < aCALENH[nDIASE,2,XH,2]
                     If !lPRIMH
                        cHORAIN := hHI
                        lPRIMH  := .T.
                     Else
                        cHORAIN := aCALENH[nDIASE,2,XH,1]
                     EndIf

                     If aCALENH[nDIASE,2,XH,2] >= hHF
                        cHORAFI := hHF
                        lTERMI  := .T.
                     Else
                        cHORAFI := aCALENH[nDIASE,2,XH,2]
                     EndIf
                     nQTDHCAL := nQTDHCAL+Htom(cHORAFI)-Htom(cHORAIN)

                     If lTERMI
                        Exit
                     EndIf
                  Else
                     If aCALENH[nDIASE,2,XH,1] >= hHI .And. aCALENH[nDIASE,2,XH,2] >= hHI
                        cHORAIN := aCALENH[nDIASE,2,XH,1]
                        cHORAFI := If (aCALENH[nDIASE,2,XH,2] >= hHF,hHF,;
                                   aCALENH[nDIASE,2,XH,2])

                        nQTDHCAL := nQTDHCAL+Htom(cHORAFI)-Htom(cHORAIN)

                        If cHORAFI >= hHF
                           Exit
                        EndIf
                     EndIf
                  EndIf

                  If lPRIMH
                     If XH < len(aCALENH[nDIASE,2])
                        hHI := aCALENH[nDIASE,2,XH+1,1]
                     EndIf
                  EndIf
                  If hHI > hHF
                     Exit
                  EndIf

               Next XH
               cHORACAR := Alltrim(Mtoh(nQTDHCAL))
               nPOS2PON := AT(":",cHORACAR)

               If nPOS2PON > 0
                  nHORF := Val(Substr(cHORACAR,1,(nPOS2PON-1)))
                  nMINF := Val(Substr(cHORACAR,(nPOS2PON+1)))
               EndIf

            EndIf
         EndIf
      Else
         nQDIAS := (dDTF - dDTI)+1
         nLDIAS := 1
         dLDATA := dDTI
         While nLDIAS <= nQDIAS
            nDIASE := Dow(dLDATA)
            nTOTHO += Htom(aCALENH[Dow(dLDATA),1])
            If dLDATA = dDTI
               Store .F. To lPRIMH,lTERMI
               If Len(aCALENH[nDIASE,2]) > 0
                  If hHI <= aCALENH[nDIASE,2,1,1] .And. hHF >= aCALENH[nDIASE,2,Len(aCALENH[nDIASE,2]),2]
                     nDIAF := 1
                  Else
                     For XH := 1 To Len(aCALENH[nDIASE,2])
                        If hHI >= aCALENH[nDIASE,2,XH,1] .And. hHI < aCALENH[nDIASE,2,XH,2]
                           If !lPRIMH
                              lPRIMH  := .T.
                           EndIf
                           cHORAIN  := hHI
                           cHORAFI  := aCALENH[nDIASE,2,XH,2]
                           nHORASF1 := Htom(cHORAFI)
                           nHORASI1 := Htom(cHORAIN)
                           nQTDHCAL := nQTDHCAL+Htom(cHORAFI)-Htom(cHORAIN)
                        Else
                           If aCALENH[nDIASE,2,XH,1] >= hHI .And. aCALENH[nDIASE,2,XH,2] >= hHI
                              If !lPRIMH
                                 lPRIMH  := .T.
                              EndIf
                              cHORAIN  := aCALENH[nDIASE,2,XH,1]
                              cHORAFI  := aCALENH[nDIASE,2,XH,2]
                              nHORASF1 := Htom(cHORAFI)
                              nHORASI1 := Htom(cHORAIN)
                              nQTDHCAL := nQTDHCAL+Htom(cHORAFI)-Htom(cHORAIN)
                           EndIf
                        EndIf

                        If lPRIMH
                           If XH < len(aCALENH[nDIASE,2])
                              hHI := aCALENH[nDIASE,2,XH+1,1]
                           EndIf
                        EndIf
                        If hHI > hHF .And. dLDATA = dDTF
                           Exit
                        EndIf
                     Next XH

                     cHORACAR := Alltrim(Mtoh(nQTDHCAL))

                     If cHORACAR = aCALENH[Dow(dLDATA),1]
                        nDIAF += 1
                     Else
                        If Empty(cSOMAH)
                           cSOMAH := cHORACAR
                        Else
                           cSOMAH := NGSOMAHCAR(cSOMAH,cHORACAR)
                        EndIf
                     EndIf

                  EndIf
               EndIf
            ElseIf dLDATA = dDTF
               Store .F. To lPRIMH,lTERMI
               nQTDHCAL := 0

               If Len(aCALENH[nDIASE,2]) > 0
                  If hHF >= aCALENH[nDIASE,2,Len(aCALENH[nDIASE,2]),2]
                     nDIAF += 1
                  Else
                     For XH := 1 To Len(aCALENH[nDIASE,2])
                        If hHF >= aCALENH[nDIASE,2,XH,1] .And. hHF <= aCALENH[nDIASE,2,XH,2]
                           cHORAIN  := aCALENH[nDIASE,2,XH,1]
                           cHORAFI  := hHF
                           nQTDHCAL := nQTDHCAL+Htom(cHORAFI)-Htom(cHORAIN)
                           Exit
                        Else
                           cHORAIN  := aCALENH[nDIASE,2,XH,1]
                           cHORAFI  := aCALENH[nDIASE,2,XH,2]
                           nQTDHCAL := nQTDHCAL+Htom(cHORAFI)-Htom(cHORAIN)
                        EndIf
                     Next XH

                     cHORACAR := Alltrim(Mtoh(nQTDHCAL))
                     If cHORACAR = aCALENH[Dow(dLDATA),1]
                        nDIAF += 1
                     Else
                        If Empty(cSOMAH)
                           cSOMAH := cHORACAR
                        Else
                           cSOMAH := NGSOMAHCAR(cSOMAH,cHORACAR)
                        EndIf
                     EndIf
                  EndIf
               EndIf
            Else
               If Htom(aCALENH[nDIASE,1]) > 0
                  nDIAF += 1
               EndIf
            EndIf
            dLDATA += 1
            nLDIAS += 1
         End

         If !Empty(cSOMAH)
            nHORAH := Htom(cSOMAH)
            nMEDIA := Int(nTOTHO / nDIAF)
            If nHORAH >= nMEDIA
               nDIAF  += Int(nHORAH / nMEDIA)
            EndIf
            nRESDO := nHORAH - (InT(nHORAH / NMEDIA) * 60)
            nHORF  := Int(nRESDO/60)
            nMINF  := nRESDO - (nHORF * 60)
            If nMINF >= 60
               nHORF += nHOMI
               nHOMI := Int(nMINF / 60)
               nMINF := nMINF - (nHOMI * 60)
            EndIf
         EndIf

      EndIf
   EndIf
EndIf
Return {nDIAF,nHORF,nMINF}

//-------------------------------------------------------------------------
/*/{Protheus.doc} NGCPDIAATU
Compara uma data com a data atual ou com a do sistema
@author  Inacio Luiz Kolling
@since   28/03/2006
@version P11
@parameters - dDataP - Data a ser comparada                 - Obrigatorio
              cCondP - Condicao a comparar                  - Obrigatorio
              lDtbas - Compara com data base (dDataBase)    - Nao Obrigat
              lInvMe - Inverte a afirmacao da mens. de ret. - Nao Obrigat
              lMostM - Mostrar mensagem na tela             - Nao Obrigat
@use Genérico
@examples - NGCPDIAATU(dDta,">",.T.,.T.,.T.)
            NGCPDIAATU(dDta,"=",.F.,.F.,.T.)
            NGCPDIAATU(dDta,">=",,.T.)

/*/
//-------------------------------------------------------------------------
Function NGCPDIAATU(dDataP, cCondP, lDtbas, lInvMe, lMostM)

    Local lMenM   := IIf(lMostM = Nil, .F., lMostM)
    Local nPosS   := 0
    Local lDtcom  := IIf(lDtbas = Nil,.T., lDtbas)
    Local lInRMe  := IIf(lInvMe = Nil,.T., lInvMe)
    Local cCondIf := Dtos(dDataP) + " " + cCondP + " " + Dtos(Date())
    Local aCondIf := {{">", STR0015},;
                     {"<" , STR0016},;
                     {">=", STR0017},;
                     {"<=", STR0018},;
                     {"=" , STR0019},;
                     {"<>", STR0020}}

    Local cDesDt  := IIf(lDtcom, STR0021, STR0022)
    Local dDtmos  := IIf(lDtcom,Dtoc(dDataBase),Dtoc(Date()))
    Local cMensa  := Space(1)

    nPosS := Ascan(aCondIf,{|x| (Alltrim(x[1])) == Alltrim(cCondP)})
    If nPosS > 0
        If !(&cCondIf)
            If IsInCallStack("MNTA150")
                // "Atenção" ## "Este registro não pode ser manipulado porque é de autoria de outro usuário."
                Help(Nil, Nil, "NGATENCAO", Nil, STR0191 + CRLF + CRLF + STR0194, 1, 0)
                Return .F.
            ElseIf IsInCallStack("MNTA160")
                ShowHelpDlg( "NGATENCAO", { STR0191 }, 5,;	// "A data inicial do bloqueio não pode ser inferior à data atual."
                                        { STR0195 }, 5)	    // "Alterar o campo Dt. Bloqueio."
                Return .F.
            ElseIf lInRMe
                cMensa := STR0023 + " " + STR0024 + " " + aCondIf[nPosS, 2] + " " + STR0025 + " " + cDesDt
            Else
                cMensa := STR0023 + " " + Dtoc(dDataP) + " " + STR0026 + " " +;
                        aCondIf[nPosS, 2] + " " + STR0025 + " " + cDesDt + "  " + dDtmos
            EndIf
        EndIf
    Else
        cMensa := STR0027
    EndIf

    If !Empty(cMensa) .And. lMenM
        MsgInfo(cMensa, STR0002)
    EndIf

Return IIf(Empty(cMensa), .T., .F.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGCPHORAATU³ Autor ³Inacio Luiz Kolling   ³ Data ³28/03/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Compara uma hora com a hora atual                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cHoraP - Hora a ser comparada                 - Obrigatorio ³±±
±±³          ³cCondP - Condicao a comparar                  - Obrigatorio ³±±
±±³          ³lInvMe - Inverte a afirmacao da mens. de ret. - Nao Obrigat.³±±
±±³          ³lMostM - Mostrar mensagem na tela             - Nao Obrigat.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Exemplos  ³NGCPHORAATU(cHora,">",.T.,.T.)                              ³±±
±±³Exemplos  ³NGCPHORAATU(cHora,">",.F.,.F.)                              ³±±
±±³de chamada³NGCPHORAATU(cHora,"=")                                      ³±±
±±³          ³.......                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGCPHORAATU(cHoraP,cCondP,lInvMe,lMostM)
Local lMenM   := If(lMostM = Nil,.F.,lMostM),nPosS := 0
Local lInRMe  := If(lInvMe = Nil,.T.,lInvMe)
Local cHoraC  := Substr(Time(),1,5)
Local cCondIf := "'"+cHoraP+"' "+cCondP+" '"+cHoraC+"'"
Local aCondIf := {{">" ,STR0015},;
                  {"<" ,STR0016},;
                  {">=",STR0017},;
                  {"<=",STR0018},;
                  {"=" ,STR0019},;
                  {"<>",STR0020} }
Local cMensa  := Space(1)

nPosS := Ascan(aCondIf,{|x| (Alltrim(x[1])) == Alltrim(cCondP)})

If nPosS > 0
   If &cCondIf
   Else
      If lInRMe
         cMensa := STR0028+" "+STR0024+" "+aCondIf[nPosS,2]+" "+STR0029
      Else
         cMensa := STR0028+"  "+cHoraP+"  "+STR0026+"  "+aCondIf[nPosS,2]+" "+STR0029+"  "+cHoraC
      EndIf
   EndIf
Else
   cMensa := STR0128
EndIf
If !Empty(cMensa) .And. lMenM
   MsgInfo(cMensa,STR0002)
EndIf

Return If(Empty(cMensa),.T.,.F.)

//---------------------------------------------------------------------
/*/{Protheus.doc} NGFRHAFAST
Consiste se o funcionario possui afastamento em determinado
periodo de data

@author	 Elisangela Costa
@since	 17/11/2006

@param  cCodFunc - Codigo do funcinario (Obrigatório)
@param	dDataIn - Data inicio de utilizacao do func. (Obrigatório)
@param	dDataFim - Data fim de utilizacao do func. (Obrigatório)
@param	lMenTela - Indica se a saida por via tela
@param	lDemit - Considera apenas func. demitidos

@version MP11
@return .T.,.F.
/*/
//---------------------------------------------------------------------
Function NGFRHAFAST(cCodFun,dDataIn,dDataFim,lMenTela,lDemit)

	Local aAreaAtua	:= GetArea()

	Local lSait		:= IIf(lMenTela = Nil, .F., lMenTela)
	Local lRetor	:= .T.
	Local lAfastPer	:= .F.
	Local cTipoSR8	:= ""
	Local cDescSX5	:= ""
	Local cNGInter	:= AllTrim( GetNewPar("MV_NGINTER","N") )
	Local cCodFunRH	:= SubStr(cCodFun, 1, TamSX3('T1_CODFUNC')[1] )

	Local dDtIniSR8	:= CToD("  /  / ")
	Local dDtFimSR8	:= CToD("  /  / ")

	Local cOrdemBkp //Variavel utilizada para integração RM

	Default lDemit := .T.

	If AllTrim( SuperGetMv("MV_NGMNTRH") ) $ "SX"

		If cNGInter == "N"
			dbSelectArea("SRA")
			dbSetOrder(01)
			If dbSeek(xFilial("SRA") + cCodFunRH)

				If  SRA->RA_SITFOLH != 'D' .Or. (SRA->RA_SITFOLH == "D" .And. SRA->RA_DEMISSA >= dDataIn .And. SRA->RA_DEMISSA >= dDataFim)

					dbSelectArea("SR8")
					dbSetOrder(01)
					If dbSeek(xFilial("SR8") + cCodFunRH)

						While !EoF() .And. SR8->R8_FILIAL == xFilial("SR8") .And.;
								SR8->R8_MAT == cCodFunRH .And. !lAfastPer

							If dDataFim < SR8->R8_DATAFIM

								lAfastPer := dDataFim = SR8->R8_DATAINI .Or. dDataIn > SR8->R8_DATAINI .Or. dDataFim > SR8->R8_DATAINI

							ElseIf dDataFim > SR8->R8_DATAFIM

								lAfastPer := dDataIn = SR8->R8_DATAFIM .Or. dDataIn < SR8->R8_DATAFIM

							ElseIf dDataIn > SR8->R8_DATAINI

								lAfastPer := dDataFim = SR8->R8_DATAFIM .And. dDataIn = SR8->R8_DATAFIM

							EndIf

							If !lAfastPer
								If dDataIn < SR8->R8_DATAINI

									lAfastPer := dDataFim = SR8->R8_DATAINI .Or. dDataFim = SR8->R8_DATAFIM

								ElseIf dDataIn > SR8->R8_DATAINI

									lAfastPer := dDataIn <> SR8->R8_DATAFIM .And. dDataFim = SR8->R8_DATAFIM

								ElseIf dDataIn = SR8->R8_DATAINI

									lAfastPer := dDataFim < SR8->R8_DATAFIM

								EndIf

								If !lAfastPer
									lAfastPer := dDataIn = SR8->R8_DATAINI .And. dDataFim = SR8->R8_DATAFIM
								EndIf
							EndIf

							If lAfastPer
								dDtIniSR8 := SR8->R8_DATAINI
								dDtFimSR8 := SR8->R8_DATAFIM
								cTipoSR8  := SR8->R8_TIPO
							EndIf

							dbSelectArea("SR8")
							dbSkip()
						EndDo

						If lAfastPer
							If lSait
								dbSelectArea("SX5")
								dbSetOrder(01)
								If dbSeek(xFilial("SX5")+"30"+cTIPOSR8)
									cDescSX5 := X5Descri()
								EndIf

								Help( Nil, 1,STR0002, Nil, STR0030 +; //"O funcionario possui registro de afastamento dentro do periodo no RH."
											STR0031 +; //"Informacoes do afastamento: "
											STR0032 + SubStr(cDescSX5, 1, 35) + Chr(13) +; //"Tipo do afastamento: "
											STR0035 + cCodFunRH + Chr(13)+; //"Funcionario: "
											STR0033 + DToC( dDtIniSR8 ) + Chr(13) +;  //"Data Inicio: "
											STR0034 + DToC( dDtFimSR8 ), 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0218}) //"Data Fim...: " #"NAO CONFORMIDADE"###"1) Verifique novamente o código do funcionário"

							EndIf

							lRetor := .F.
						EndIf
					EndIf
				EndIf
			EndIf
		ElseIf cNGInter == "M"
			dbSelectArea("SRA")
			dbSetOrder(01)
			If dbSeek(xFilial("SRA") + cCodFun)
				//Itegração com RH do RM - GetEmployeeSituation
				cOrdemBkp := If( Type( "cOrdem" ) <> "C", "", cOrdem )
				lRetor	:= NGMUGetSit( cCodFun, dDataIn, dDataFim, xFilial("SRA"))
				cOrdem	:= cOrdemBkp
			EndIf
		EndIf
	EndIf

	RestArea(aAreaAtua)

Return lRetor

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGCALDATF ³ Autor ³ Elisangela Costa      ³ Data ³17/11/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a data/hora fim corrida com base na unidade de medi-³±±
±±³          ³da(D=Dia,S=Semana,M=Mes,H=Hora) e quantidade.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cDTINIC = Data Inicio  -Obrigatorio                         ³±±
±±³          ³cHOINIC = Hora Inicio  -Obrigatorio                         ³±±
±±³          ³cQUANTI = Quantidade   -Obrigatorio                         ³±±
±±³          ³cUNIDAD = Quantidade   -Obrigatorio                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ vDATHOR: [1]-Data Incio                                    ³±±
±±³          ³          [2]-Hora Incio                                    ³±±
±±³          ³          [3]-Data Fim                                      ³±±
±±³          ³          [4]-Hora Fim                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGCALDATF(cDTINIC,cHOINIC,cQUANTI,cUNIDAD)

Local dDATAFIM := CTOD("  /  /  /")
Local cHORAFIM := "  :  "
Local nDIA,nMES,nAno,nSOMA
Local nTEMPO := HTOM(cHOINIC)

If Alltrim(cUNIDAD) == "D"
   dDATAFIM := cDTINIC + cQUANTI
   cHORAFIM := cHOINIC
ElseIf Alltrim(cUNIDAD) == "S"
   dDATAFIM := cDTINIC + (cQUANTI * 7)
   cHORAFIM := cHOINIC
ElseIf Alltrim(cUNIDAD) == "M"
   nAno := Year(cDTINIC)
   nMES := Month(cDTINIC)
   nDIA := Day(cDTINIC)
   nMES := nMES + cQUANTI

   While nMES > 12
      nMES := nMES - 12
      nANO := nANO + 01
   End

   nDIA := Strzero(nDIA,2)
   nMES := Strzero(nMES,2)
   nANO := Alltrim( Strzero(nANO,4) )

   dDATAFIM := CtoD(nDIA + '/' + nMES + '/' + nANO)

   While Empty(dDATAFIM)
      nDIA := Val(nDIA)-1
      nDIA := Strzero(nDIA,2)
      dDATAFIM := CtoD(nDIA + '/' + nMES + '/' + nANO)
   End
   cHORAFIM := cHOINIC
Else
   nTEMPO := nTEMPO + (cQUANTI * 60)
   nSOMA  := 0

   While nTEMPO > 1440
      nSOMA  := nSOMA + 1
      nTEMPO := nTEMPO - 1440
   End

   dDATAFIM := cDTINIC + nSOMA
   cHORAFIM := MtoH(nTEMPO)
EndIf

Return {cDTINIC,cHOINIC,dDATAFIM,cHORAFIM}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄ¿±±
±±³Funcao    ³NGRETDSANO  ³ Autor³Inacio Luiz Kolling ³ Data ³09/11/2007³09:00³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna os dias inicio de cada semana do ano  [1.. 52]          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nVAno - Ano de referencia                         - Obrigatorio ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Chamadas  ³vRetX := NGRETDSANO(2007)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³vRetDs - Vetor com os dias inicio de cada semana                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGRETDSANO(nVAno)
Local cAnoC  := Alltrim(Str(nVAno,4)),n,nSemA,vRetDs := {}
Local  dDia  := Ctod('01/01/'+If(Len(cAnoC) = 4,SubStr(cAnoC,3,2),cAnoC))
Local nTDiaA := If(Mod(nVAno,4) = 0,366,365)
Store 0 To n,nSemA

For n := 1 To nTDiaA
   nSem := NGSEMANANO(dDia)
   If nSem <> nSemA
      aAdd(vRetDs,dDia)
      nSemA := nSem
   EndIf
   dDia ++
Next n
Return vRetDs
//---------------------------------------------------------------------
/*/{Protheus.doc} NG_H9
Verifica exceção de calendário

@author NG Informática
@since   /  /
@param 	dData -> Data da exceção do calendário

@return array -> [1] Horário Inicial
                   [2] Horário Final
                   [3] Total carga Horário
@use SIGAMNT
/*/
//---------------------------------------------------------------------
Function NG_H9(dDat)
Local aDIA := {}, Hor,INI, FIM, Dia, Tot
Local aOCI := {},X

SH9->(dbSetOrder(2))
SH9->(dbSeek(xFilial('SH9')))
If !SH9->(dbSeek(xFilial('SH9') + "E" + DTOS(dDAT) ))
   SH9->(dbSetOrder(1))
   Return aDIA
EndIf

aDia := {}
Hor  := sh9->h9_aloc
Dia  := Hor

Tot  := 0
Ini  := 999
Fim  := 0

aOCI := {}
nOI  := 999
nOF  := 0

Tot  := 0
x := 0
For x := 1 to Len(Dia)
   If !Empty(SubStr(DIa,x,1))
      Tot += (1440/Len(Dia))
      Fim := ( (1440/Len(Dia)) * x )
      Ini := If(Ini == 999,(Fim - (1440/Len(Dia))),Ini)

      If nOI != 999
         aAdd(aOCI,{nOI, nOF})
         nOI := 999
         nOF := 0
      EndIf
   Else
      nOF := ( (1440/Len(Dia)) * x )
      nOI := If(nOI == 999,(nOF - (1440/Len(Dia))),nOI)
   EndIf
Next

If nOI != 999
   aAdd(aOCI,{nOI, nOF})
   nOI := 999
   nOF := 0
EndIf

Ini := If(Ini == 999,0,Ini)

aDia := { MtoH(INI), MtoH(FIM), MtoH(TOT), aOCI }

Return aDIA

//---------------------------------------------------------------------
/*/{Protheus.doc} INTERVALO
Numero de Minutos

@author NG Informática
@since   /  /
@param 	HINI -> Hora Início
	    HFIM -> Hora Fim
	    nDia -> Qtde Dias

@return _hora -> Numérico

@use SIGAMNT
/*/
//---------------------------------------------------------------------
Function INTERVALO(HINI,HFIM,nDIA)
Local _hora := 0, x1,x2,y1,y2,i
For i := 1 to Len(aDIAMAN[nDIA][4])
   x1 := aDIAMAN[nDIA][4][i][1]
   x2 := aDIAMAN[nDIA][4][i][2]

   y1 := HtoM(hINI)
   y2 := HtoM(hFIM)

   If x1 > y1 .And. x2 <= y2
      _hora += (x2 - x1)
   ElseIf y2 > x1 .And. y2 <= x2
     _hora += (x2-x1)
   ElseIf y1 >= x1 .And. y1 < x2
     _hora += (x2 - y1)
   EndIf
Next
Return _hora

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QTDHOR    ³ Autor ³ Paulo Pego           ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula a quantidade de horas de corrida segundo o calenda-³±±
±±³          ³ rio da manutencao                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GENERICO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QTDHOR(nQTD,dINI,hINI,dFIM,hFIM,cUND,cCod)
Local nTempo, nSem, nFol,i

cUND    := Trim(cUND)
nSem    := If(DOW(dINI)==1,7,DOW(dINI)-1)
aDIAMAN := NG_H7(cCOD)

If cUND == "H"
   Return nQTD
EndIf

If cUND == "S"
   nFol   := (nQTD *  7)
   nTempo := 0

ElseIf cUND == "M"
   nFol   := (nQTD *  30)
   nTempo := 0

Else
   nFol   := nQTD
   nTempo := 0
EndIf

dFaz   := dINI
FimS   := 0

For i := 1 To nFOL
   nSem   := If(DOW(dFaz)==1,7,DOW(dFaz)-1)

   If i == nFOL
      nTempo += ( (HtoM(hFIM) - HtoM(aDIAMAN[nSem][1])) - Intervalo(aDIAMAN[nSem][1], hFIM, nSem))
   Else
      nTempo += HtoM( aDIAMAN[nSem][3] )
   EndIf
   dFaz++
Next

Return (nTEMPO/60)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGSubtAno ³ Autor ³ Andre E. Perez Alvarez³ Data ³30/11/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula a nova data somando a quantidade de anos informada  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ dData = Data  -Obrigatorio                                 ³±±
±±³          ³ nQtAno = Quantidade de anos a serem somados -Obrigatorio   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ dData                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGSubtAno(dData, nQtAno)
Local nDia := Day(dData)
Local nMes := Month(dData)
Local nAno := Year(dData)
Local nAnoNew := nAno - nQtAno

nDIA := Strzero(nDIA,2)
nMes := Strzero(nMes,2)
nAnoNew := Alltrim( Strzero(nAnoNew,4) )

dData := CtoD(nDia + '/' + nMes + '/' + nAnoNew)

While Empty(dData)
	nDia := Val(nDia) - 1
	nDia := Strzero(nDia,2)
	dData := CtoD(nDia + '/' + nMes + '/' + nAnoNew)
End
Return dData

//-------------------------------------------------------------------
/*/{Protheus.doc} NGSOMAHORAS
Soma quantidades de horas (100->60  / 60->100)

@author  Inacio Luiz Kolling
@since   30/04/2004
@version P11/P12

@param   nVQDHORAS  , Numérico, Quantidade de horas
@param   cVTIPOHOR  , Caracter, Tipo da hora (D = 100,<> 60)
@param   cVARSOMAH  , Caracter, Nome da variavel que sera somada
@param   [cPARATPHO], Caracter, Tipo de unidade da quantidade quando for
								informado um insumo que utiliza tipo de
								unidade e hora.( MV_NGUNIDT )
/*/
//-------------------------------------------------------------------
Function NGSOMAHORAS(nVQDHORAS,cVTIPOHOR,cVARSOMAH, cPARATPHO )

	Local nSOMAHOTO := 0.00
	Local nHORACONS := nVQDHORAS
	Local nSOMAPARA := &(cVARSOMAH)

	Default cPARATPHO := AllTrim( SuperGetMv( 'MV_NGUNIDT', .F., 'S' ) )

	If cVTIPOHOR <> cPARATPHO
		nHORACONS := NGCONVERHORA(nVQDHORAS,cVTIPOHOR)
	EndIf

	If cPARATPHO <> "D"

		nPARTINTS := Int(nSOMAPARA)
		nMINISRES := nSOMAPARA-nPARTINTS
		cMINISRES := Alltrim(Str(nMINISRES,10,2))
		nPOSPONTS := At(".",cMINISRES)
		cPARSRESS := Alltrim(Substr(cMINISRES,nPOSPONTS+1,Len(cMINISRES)))
		nPARSRESS := Val(cPARSRESS)

		nPARTINTH := Int(nHORACONS)
		nMINISREH := nHORACONS-nPARTINTH
		cMINISREH := Alltrim(Str(nMINISREH,10,2))
		nPOSPONTH := At(".",cMINISREH)
		cPARSRESH := Alltrim(Substr(cMINISREH,nPOSPONTH+1,Len(cMINISREH)))
		nPARSRESH := Val(cPARSRESH)

		nSOMAMINU := nPARSRESS + nPARSRESH

		If nSOMAMINU > 59
			cPARTINTS := Alltrim(Str(nPARTINTS + 1,10))
			cMINISRES := "00"
			nPARSRESF := nSOMAMINU - 60

			cHORAINTS := cPARTINTS+"."+cMINISRES
			cHORAINTH := Alltrim(Str(nPARTINTH))+"."+Alltrim(Str(nPARSRESF))
			nSOMAHOTO := Val(cHORAINTS)+Val(cHORAINTH)
		Else
			nSOMAHOTO := &(cVARSOMAH) + nHORACONS
		EndIf
	Else
		nSOMAHOTO := &(cVARSOMAH) + nHORACONS
	EndIf

	&(cVARSOMAH) := nSOMAHOTO

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGRETHORDDH³ Autor ³Elisangela Costa       ³ Data ³30/08/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Converte o valor de hora que esta em numerico em formato de  ³±±
±±³          |horas sexagesimal e em centesimal                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³nHORADEC = Hora em decimal                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ vVETHODH [1] = Valor de hora em Sexagesimal(1,30 em 01:30)  ³±±
±±³          ³          [2] = Valor de hora em centesimal (1,30 em 1,50)   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGRETHORDDH(nHORADEC)
Local cHORADEC, cPARTEIN, cHORACON, cRESTINT
Local nPOSDEC, nQTDHORAS

cHORADEC := Alltrim(Str(nHORADEC,10,2))
nPOSDEC  := At(".",cHORADEC)
cPARTEIN := SubStr(cHORADEC,1,nPOSDEC-1)
cRESTINT := SubStr(cHORADEC,nPOSDEC+1,2)
cPARTEIN := If(Len(cPARTEIN) = 1,"0"+cPARTEIN,cPARTEIN)
cHORACON := cPARTEIN + ":" + cRESTINT

nQTDHORAS := HTON(cHORACON)

Return {cHORACON,nQTDHORAS}

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³NGHORPARAPR³ Autor ³In cio Luiz Kolling    ³ Data ³14/06/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³Calcula a quantidade de horas de parada prevista e real com  ³±±
±±³          ³nas datas e horas e o calendario                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³vRetHor    [1] - Qtde prevista.. [2] - Qtde real             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function NGHORPARAPR(cBEM,dDTPPINI,cHOPPINI, dDTMPINI,cHOMPINI,dDTPPFIM,;
                     cHOPPFIM,dDTMPFIM,cHOMPFIM,dDTPRINI,cHOPRINI,dDTMRINI,;
                     cHOMRINI,dDTPRFIM,cHOPRFIM,dDTMRFIM,cHOMRFIM)
Local vRetHor := {},aAreaP := GetArea()

dINIP := If(!EMPTY(dDTPPINI),dDTPPINI,dDTMPINI)
hINIP := If(!EMPTY(dDTPPINI),cHOPPINI,cHOMPINI)
dFIMP := If(!EMPTY(dDTPPFIM),dDTPPFIM,dDTMPFIM)
hFIMP := If(!EMPTY(dDTPPFIM),cHOPPFIM,cHOMPFIM)

nPREP := NGCALEBEM(dINIP,hINIP,dFIMP,hFIMP,cBEM)
nPREP := HtoM(nPREP)/60
nPREP := If(nPREP < 0.00,0.00,nPREP)

dINIR := If(!EMPTY(dDTPRINI),dDTPRINI,dDTMRINI)
hINIR := If(!EMPTY(dDTPRINI),cHOPRINI,cHOMRINI)
dFIMR := If(!EMPTY(dDTPRFIM),dDTPRFIM,dDTMRFIM)
hFIMR := If(!EMPTY(dDTPRFIM),cHOPRFIM,cHOMRFIM)

nREAR := NGCALEBEM(dINIR,hINIR,dFIMR,hFIMR,cBEM)
nREAR := HTOM(nREAR)/60
nREAR := If(nREAR < 0.00,0.00,nREAR)

aAdd(vRetHor,nPREP)
aAdd(vRetHor,nREAR)

RestArea(aAreaP)
Return vRetHor

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGMOTIVO  ³ Autor ³ In cio Luiz Kolling   ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consistˆncia do motivo do rodizio                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGMOTIVO(cVMOTIVO)
lMOSTRE := .T.
cNOMCAU := Space(Len(st8->t8_nome))
lRefresh := .T.
If !ExistCpo('ST8',cVMOTIVO)
	Return .F.
EndIf
dbSelectArea("ST8")
dbSetOrder(1)
dbSeek(xFilial("ST8")+cVMOTIVO)
If ST8->T8_TIPO <> 'C'
	MsgInfo(STR0036,STR0037) //"Motivo devera ser do tipo CAUSA"###"ATENCAO"
	Return .F.
EndIf
cNOMCAU  := st8->t8_nome
lRefresh := .T.
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGSD1STLCOMP³ Autor ³In cio Luiz Kolling  ³ Data ³14/07/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava os campos complementares do SD1 para STL              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGSD1STLCOMP()
Local nVP      := 0
Local vVETCAMN := {"_FILIAL","_NUMSEQ","_ORDEM"}
Local aESTRUT  := {}

dbSelectArea("STL")
aESTRUT := dbStruct()

RecLock("STL",.F.)
dbSelectArea("SD1")
For nVP := 1 To Fcount()
   ny := Fieldname(nVP)
   nc := "STL->TL"+Alltrim(Substr(ny,3,Len(ny)))
   cCAMPP := Alltrim(Substr(ny,3,Len(ny)))
   If Ascan(vVETCAMN, {|x| x == Alltrim(Substr(ny,3,Len(ny)))}) = 0
      If Ascan(aESTRUT, {|x| Alltrim(Substr(x[1],3,Len(x[1]))) == cCAMPP}) > 0
         nx   := "SD1->"+Fieldname(nVP)
         &nc. := &nx.
      EndIf
   EndIf
Next
STL->(MsUnLock())
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} NGMNTATFIN
Consiste se o bem integrado com o Manutencao da Ativo pode ser baixado -
chamado em AFVLBXIntMnt do fonte ATFXATU

cCodBemMNT - Codigo do bem (SN1->N1_CODBEM)
dDataBaixa - Data da baixa (SN1->N1_BAIXA)
cRotina    - Rotina de baixa (ATFA030 / ATFA035 / ATFA036 )

@author ARNALDO R. JUNIOR
@since 14/07/2008
@funcao trazida por Guiherme Benkendorf
@Data 11/02/2013
@version MP11
@return
/*/
//---------------------------------------------------------------------
Function NGMNTATFIN(cCodBemMNT,dDataBaixa,cRotina)

	Local aArea 	 := GetArea()
	Local cMensagem  := SPACE(01)
	Local lRotVia080 := fVerAutExe(cRotina)

	Default dDataBaixa := dDataBase

	If !Empty(cCodBemMNT) .And. !lRotVia080

		//Verifica a existencia do bem na estrutura
		dbSelectArea("STC")
		dbSetOrder(01)
		If dbSeek(xFilial("STC")+cCodBemMNT)
			cMensagem := STR0038+CRLF+STC->TC_COMPONE+" / "+STC->TC_CODBEM //"Bem faz parte da estrutura."
		Else
			dbSelectArea("STC")
			dbSetOrder(03)
			If dbSeek(xFilial("STC")+cCodBemMNT)
				cMensagem := STR0038+CRLF+STC->TC_COMPONE+" / "+STC->TC_CODBEM //"Bem faz parte da estrutura."
			EndIf
		EndIf

		If Empty(cMensagem)

			//Verifica a existencia do bem nas ordens de servico
			dbSelectArea("STJ")
			dbSetOrder(12)
			If dbSeek(xFilial("STJ")+"B"+cCodBemMNT+"N")
				While !EoF() .And. STJ->TJ_FILIAL = xFilial("STJ") .And. STJ->TJ_TIPOOS = "B";
				             .And. STJ->TJ_CODBEM = cCodBemMNT     .And. STJ->TJ_TERMINO = "N"

					If STJ->TJ_SITUACA = 'L'
						cMensagem := STR0039+CRLF+STJ->TJ_ORDEM+" / "+STJ->TJ_PLANO+" / "+STJ->TJ_TIPOOS  //"Existe ordem de serviço em aberto para o bem."
						Exit
					EndIf
					dbSkip()
				End
			EndIf

		EndIf

		If !Empty(cMensagem)
			Help(cRotina,1,"HELP","MV_NGMNTAT",cMensagem,1,0)
		EndIf

	EndIf

	RestArea(aArea)

Return Empty(cMensagem)

//---------------------------------------------------------------------
/*/{Protheus.doc} fVerAutExe
Verifica se a chamada da função é via AutoExec do ATFA036 e se foi foi
chamado diretamente do MNTA080, nesse caso não é necessário fazer a
consistência da estrutura nem de ordem de serviço pois o mesmo irá
ocorrer no do cadastro de bens.

cRotina - Rotina de baixa (ATFA030 / ATFA035 / ATFA036)

@author Maicon André Mendes Pinheiro
@since 20/04/2017
@version MP12
@return
/*/
//---------------------------------------------------------------------
Static Function fVerAutExe(cRotina)

	Local lRet     := .F.
	Local lProg080 := IIf(Type("cPrograma") != "U" .And. cPrograma == "MNTA080",.T.,.F.)

	lRet := lProg080 .And. cRotina == "ATFA036" .And. Type("lMSFINALAUTO") != "U"

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NG103LINOK³Autor  ³ Marcos Wagner Junior  ³ Data ³24/11/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de validacao da LinhaOk (p/ o modulo de Manutencao)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. se a Validacao esta OK e .F. caso nao estiveja          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA103                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NG103LINOK()
Local aOldArea := GetArea(), aOldTJArea := STJ->(GetArea()), lRet := .T., lTemInsumo := .F.
Local nPosNFOri  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_NFORI"})
Local nPosSerOri := aScan(aHeader,{|x| AllTrim(x[2])=="D1_SERIORI"})
Local nPosOrdem  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ORDEM"})
Local nPosCod    := aScan(aHeader,{|x| AllTrim(x[2])=="D1_COD"})
Local nPosQuant  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_QUANT"})

If nPosOrdem > 0

	If cTipo == 'D'
		If !Empty(aCols[n][nPosOrdem]) .AND. (Empty(aCols[n][nPosNFOri]) .OR. Empty(aCols[n][nPosSerOri]))
			MsgAlert(STR0040+"'"+AllTrim(NGRETTITULO("D1_NFORI"))+"', '"+AllTrim(NGRETTITULO("D1_SERIORI"))+"'!") //"Deverão ser informados os campos: "
			lRet := .F.
		ElseIf !Empty(aCols[n][nPosOrdem]) .AND. !Empty(aCols[n][nPosNFOri]) .AND. !Empty(aCols[n][nPosSerOri])
			dbSelectArea("STL")
			dbSetOrder(01)
			dbSeek(xFilial("STL")+aCols[n][nPosOrdem])
			While !EoF() .AND. STL->TL_FILIAL == xFilial("STL") .AND. STL->TL_ORDEM == aCols[n][nPosOrdem]
				If STL->TL_TIPOREG == 'P' .AND.;
					STL->TL_CODIGO  == aCols[n][nPosCod] .AND.;
					STL->TL_ORIGNFE == 'SD1' .AND.;
					STL->TL_NOTFIS  == aCols[n][nPosNFOri] .AND.;
					STL->TL_SERIE   == aCols[n][nPosSerOri] .AND.;
					STL->TL_FORNEC  == cA100For .AND.;
					STL->TL_LOJA    == cLoja
					lTemInsumo := .T.
					Exit
				EndIf
				dbSkip()
			End
			If !lTemInsumo
				MsgAlert(STR0041+; //"Nenhum insumo da O.S. informada tem como origem a NF/Serie Origem informada: "
							AllTrim(aCols[n][nPosNFOri])+"/"+AllTrim(aCols[n][nPosSerOri]))
				lRet := .F.
			EndIf
		EndIf
	ElseIf !Empty(aCols[n][nPosOrdem])
		
		If SuperGetMV( 'MV_NGCOQPR', .F., 'N' ) == 'S' .And. NgIfdbSeek( 'STJ', aCols[n,nPosOrdem], 1 ) .And.;
			!NGCHKLIMP( STJ->TJ_CODBEM, aCols[n,nPosCod], aCols[n,nPosQuant] )
				
			lRet := .F.

		EndIf

	EndIf

EndIf

RestArea(aOldArea)
RestArea(aOldTJArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGPRIMDHCALE³ Autor ³ Inacio Luiz Kolling   ³ Data ³13/08/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Procura a primeira data e hora disponivel para o calendario   ³±±
±±³          ³apartir de uma data inicial                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³dtini   - Data inicio                           - OBRIGATORIO ³±±
±±³          ³cCalend - Calendario                            - OBRIGATORIO ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³vVetR -> {dDinV,cHorCI} <- {dia,hora}                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obsevacao ³Na duvida consistir o retorno na chamada da funcao            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³GENERICO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGPRIMDHCALE(dtini,cCalend)
Local dDinV := dtini,aCalenC := NGCALENDAH(cCalend)
Local vVetR := {Ctod("  /   /   "),Space(5)}
If !Empty(aCalenC)
   While .T.
      If aCalenC[Dow(dDinV),1] <> "00:00"
          vVetR := {dDinV,aCalenC[Dow(dDinV),2,1,1]}
          Exit
      EndIf
      dDinV ++
   End
EndIf
Return vVetR

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³NGCONGARAN³ Autor ³ Vitor Emanuel Batista ³ Data ³10/02/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consiste garantia do produto por Tempo e Contador          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodBem  -> C¢digo do Bem                     -Obrigatorio ³±±
±±³          ³ cProduto -> C¢digo do Produto                 -Obrigatorio ³±±
±±³          ³ cLocaliz -> C¢digo da localizacao do produto               ³±±
±±³          ³ nContGar -> Tipo de contador da garantia                   ³±±
±±³          ³ nPosCont -> Posicao do contador na O.S                     ³±±
±±³          ³ lMostra  -> Mensagem de produto em garantia   -Default .T. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³  lRet - .T. se esta em garantia / .F. se nao esta          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGCONGARAN(cCodBem,cProduto,cLocaliz,nContGar,nPosCont,lMostra)
Local cUni1,dIniGar,cOrd, cQuery, nQtde, cPlan
Local cAliasQry := GetNextAlias()
Local lRet := .F.
Local aArea := GetArea()
lMostra := If(lMostra == Nil,.T.,lMostra)
lCont   := If(nContGar == Nil .Or. nContGar == 0 .Or. nPosCont == Nil .Or. nPosCont == 0,.F.,.T.)

cQuery := " SELECT TPZ_ORDEM, TPZ_PLANO, TPZ_DTGARA, TPZ_QTDGAR, TPZ_UNIGAR, TPZ_CONGAR"
If NGCADICBASE("TPZ_QTDCON","A","TPZ",.F.)
	cQuery += ", TPZ_QTDCON FROM "+RetSqlName("TPZ")
Else
	cQuery += " FROM "+RetSqlName("TPZ")
EndIf
cQuery += " WHERE TPZ_CODBEM = '"+cCodBem+"' AND TPZ_CODIGO = '"+cProduto+"' "
cQuery += " AND TPZ_LOCGAR = '"+cLocaliz+"'"
cQuery += " AND TPZ_FILIAL = '"+FWxFilial("TPZ")+"' AND D_E_L_E_T_ = ' '"
cQuery += " ORDER BY TPZ_DTGARA DESC"

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

If !EoF()
	dIniGar := StoD( (cAliasQry)->TPZ_DTGARA )
	cOrd    := (cAliasQry)->TPZ_ORDEM
	cPlan   := (cAliasQry)->TPZ_PLANO
    cUni1   := (cAliasQry)->TPZ_UNIGAR
    nQtde   := (cAliasQry)->TPZ_QTDGAR

	If !Empty(nQtde) .And. !Empty(cUni1)
		If cUni1 == "D"
			dDtVal := dIniGar + nQtde
		ElseIf cUni1 == "S"
			dDtVal := dIniGar + (nQtde * 7)
		ElseIf cUni1 == "M"
			dDtVal := dIniGar + (nQtde * 30)
		EndIf

		If dDtVal > dDataBase
			If lMostra
				dFimGar := dDtVal
				MsgAlert(STR0042+CHR(13); //"Insumo substituido no prazo de Garantia"
						+STR0043+AllTrim(Str(Day(dIniGar)))+"/"+AllTrim(Str(Month(dIniGar)))+"/"+AllTrim(Str(Year(dIniGar)))+If(Empty(cOrd),"","    O.S.:"+cOrd)+CHR(13); //"Data de Inicio de uso :"
						+STR0126+AllTrim(Str(Day(dFimGar))+"/"+AllTrim(Str(Month(dFimGar)))+"/"+AllTrim(Str(Year(dFimGar))))+CHR(13); //"Garantia Ate..............:"
						+If(Empty(cLocaliz)," ",STR0127+cLocaliz),STR0037) //"Na Localização: "
			EndIf
			lRet := .T.
		EndIf

	EndIf

	If lCont
		dbSelectArea(cAliasQry)
        cTipContL := If(ValType(nContGar) = "N",Str(nContGar,1),nContGar)
		While !EoF()
            If (cAliasQry)->TPZ_CONGAR == cTipContL
    			dbSelectArea("STJ")
    			dbSetOrder(1)
    			If dbSeek(xFilial("STJ")+(cAliasQry)->TPZ_ORDEM+(cAliasQry)->TPZ_PLANO)
                    If cTipContL == "1"
    					nPosCon := STJ->TJ_POSCONT
    				Else
    					nPosCon := STJ->TJ_POSCON2
    				EndIf

    				If !Empty(nPosCon) .And. NGCADICBASE("TPZ_QTDCON","A","TPZ",.F.)
    					If (nPosCon + (cAliasQry)->TPZ_QTDCON) > nPosCont
    						If lMostra
								MsgAlert(STR0046+CHR(13)+CHR(13); //"Insumo substituido no prazo de Garantia"
										+STR0047+AllTrim(Str(nPoscont))+CHR(13);
										+"O.S.                                     : "+(cAliasQry)->TPZ_ORDEM+CHR(13);
										+STR0048+AllTrim(Str(nPosCon))+CHR(13); //"Contador atual                     : "
										+STR0049+AllTrim(Str(nPosCon + (cAliasQry)->TPZ_QTDCON) )) //"Garantia Ate                         : "
    						EndIf
    						lRet := .T.
    					EndIf
    				EndIf
    			EndIf
    			dbSelectArea(cAliasQry)
    			dbSkip()
    		EndIf
		EndDo
	EndIf
EndIf

(cAliasQry)->(dbCloseArea())
RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGTPZGARAN³ Autor ³Vitor Emanuel Batista  ³ Data ³10/02/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inclusao da Garantia para tipo de insumo igual a Produto    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cORDEM  -> Ordem de Servico                 -Obrigatorio   ³±±
±±³          ³ cPRODUTO-> C¢digo do Produto                -Obrigatorio   ³±±
±±³          ³ cLocalIZ-> C¢digo da localizacao do produto                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³aGarant [1] - Codigo do Bem                                 ³±±
±±³          ³        [2] - Codigo do Insumo                              ³±±
±±³          ³        [3] - Tipo de Insumo                                ³±±
±±³          ³        [4] - Localizacao do Produto                        ³±±
±±³          ³        [5] - Codigo da O.S                                 ³±±
±±³          ³        [6] - Plano da O.S                                  ³±±
±±³          ³        [7] - Quantidade de Garantia por Tempo              ³±±
±±³          ³        [8] - Unidade da Garantia por Tempo                 ³±±
±±³          ³        [9] - Quantidade de Garantia por Contador           ³±±
±±³          ³        [10]- Tipo de Contador                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGTPZGARAN(cOrdem,cProd,cLocal)
Local oDlg
Local nOpc    := 0
Local aUni    := {" ",STR0050,STR0051,STR0052} //"Dia" ## "Semana" ## "Mes"
Local aCont   := {" ",STR0053,STR0054} //"Contador 1" ## "Contador 2"
Local aGarant := {}

Private cCont    := " "
Private cUni     := " "
Private nQtde    := 0
Private nQtdeC   := 0
Private cProduto := cProd
Private cLocaliz := cLocal
Private cCodBem, cPlano, cNomLoc
Private nPosCon, nPosCon2

dbSelectArea("STJ")
dbSetOrder(1)
If dbSeek(xFilial("STJ")+cOrdem)
	cCodBem  := STJ->TJ_CODBEM
	cOrdem   := STJ->TJ_ORDEM
	cPlano   := STJ->TJ_PLANO
	nPosCon  := STJ->TJ_POSCONT
	nPosCon2 := STJ->TJ_POSCON2
	cLocaliz := If(cLocaliz == Nil,"",cLocaliz)
	lTemCG1 := If(NGSEEK("ST9",cCODBEM,1,"T9_TEMCONT") <> "N",.T.,.F.)
   lTemCG2 := If(NGIfDBSEEK("TPE",cCODBEM,1,.F.),.T.,.F.)

	dbSelectArea("TPY")
	dbSetOrder(1)
	If dbSeek(xFilial("TPY")+cCodBem+cProduto+cLocaliz)
		cLocaliz := TPY->TPY_LOCGAR
		nQtde    := TPY->TPY_QTDGAR
		cUni1    := TPY->TPY_UNIGAR
		nQtdeC   := TPY->TPY_QTDCON

		If cUni1 == "D"
			cUni := aUni[2] //"Dia"
		ElseIf cUni1 == "S"
			cUni := aUni[3] //"Semana"
		Else
			cUni := aUni[4] //"Mes"
		EndIf

		If !Empty(TPY->TPY_CONGAR)
			If TPY->TPY_CONGAR == '1'
				cCont := aCont[2] //"Contador 1"
			Else
				cCont := aCont[1] //"Contador 2"
			EndIf
		EndIf
	EndIf

   If !Empty(aMntGarant) .And. Len(aMntGarant[1]) >= 11 //n .And. Len(aMntGarant[n]) >= 11 .And. !Empty(aMntGarant[n,11])
       nLS := Ascan(aMntGarant,{|x| x[11] = n })
       If nLS  > 0
          cLocaliz := aMntGarant[nLS,4]
          cNomLoc  := NGSEEK("TPS",cLocaliz,1,"TPS_NOME")
          nQtde    := aMntGarant[nLS,7]
          nIU := If(!Empty(aMntGarant[nLs,8]),If(aMntGarant[nLS,8] = "D",2,If(aMntGarant[nLS,8] = "S",3,4)),1)
          cUni     := aUni[nIU]
          nQtdeC   := aMntGarant[nLS,9]
          cCont    := If(!Empty(aMntGarant[nLS,10]),If(aMntGarant[nLS,10] = '1',aCont[2],aCont[3]),"           ")
       EndIf
   EndIf

	cLocaliz := If(Empty(cLocaliz),Space(Len(TPY->TPY_LOCGAR)),cLocaliz)

	Define Msdialog oDlg From  000,000 To 280,550 Title STR0055 Pixel //"Garantia"

	@ 1.5,.5 To 3.5,34 LABEL STR0056 OF oDlg //"Localização"

	@ 30,008 Say Oemtoansi(STR0057) Size 47,07 Of oDlg Pixel //"Local"
	@ 30,040 MsGet cLocaliz Picture "@!" Valid NGLOCGAR(cLocaliz) F3 "TPS" Size 38,08 Of oDlg Pixel HASBUTTON
	@ 30,100 MsGet oNomLoc Var cNomLoc Of oDlg Pixel Picture '@!' When .F. Size 90,08

	@ 4.0,.5 To 6.0,34 LABEL STR0058 OF oDlg //"Garantia por Tempo"

	@ 65,008 Say Oemtoansi(STR0059) Size 47,07 Of oDlg Pixel //"Quantidade"
	@ 65,040 MsGet nQtde Size 38,08 Of oDlg Pixel Valid positivo(nQtde) Picture '@E 999,999,999'

	@ 65,100 Say Oemtoansi(STR0060) Size 47,07 Of oDlg Pixel //"Unidade"
	@ 65,132 Combobox cUni Items aUni Size 40,50 OF oDlg Pixel Valid If(!Empty(nQtde),NG400CON(cUni,cCont,1,nQtde),.T.)

	@ 6.5,.5 To 8.5,34 LABEL STR0061 OF oDlg //"Garantia por Contador"

	@ 100,008 Say Oemtoansi(STR0059) Size 47,07 Of oDlg Pixel //"Quantidade"
	@ 100,040 MsGet nQtdeC Size 38,08 Of oDlg Pixel Valid positivo(nQtdeC) Picture '@E 999,999,999' When lTemCG1 .Or. lTemCG2

	@ 100,100 say OemtoAnSi(STR0062) Size 47,07 Of oDlg Pixel //"Tp Contador"
	@ 100,132 Combobox cCont Items aCont Size 40,50 Of oDlg Pixel Valid If(!Empty(nQtdeC),NG400CON(cUni,cCont,2,nQtdeC),.T.) When lTemCG1 .Or. lTemCG2

	Activate Msdialog oDlg On Init EnchoiceBar(oDlg,{||nOpc:=2,If(ValGarant(),oDlg:End(),nOpc:=0)},{||nOpc:=1,oDlg:End()}) Centered
EndIf

If nOpc == 2

	If cUni = STR0050 //"Dia"
	   cUni := "D"
	ElseIf cUni = STR0051 //"Semana"
	   cUni := "S"
	ElseIf cUni = STR0052 //"Mes"
	   cUni := "M"
	Else
	   cUni := " "
	EndIf

	If cCont == STR0053 //"Contador 1"
		cCont := "1"
	ElseIf cCont == STR0054 //"Contador 2"
		cCont := "2"
	Else
		cCont := " "
	EndIf

	cTIPOREG := If(NGPRODESP(cProduto,.F.,"T"), "P", "T")
	nPox     := If (Type("n") = "U",1,n)
    aGarant :=  {   cCodBem  ,; //TPZ_CODBEM
					cProduto ,; //TPZ_CODIGO
					cTipoReg ,; //TPZ_TIPORE
					cLocaliz ,; //TPZ_LOCGAR
					cOrdem   ,; //TPZ_ORDEM
					cPlano   ,; //TPZ_PLANO
					nQtde    ,; //TPZ_QTDGAR
					cUni     ,; //TPZ_UNIGAR
					nQtdeC   ,; //TPZ_QTDCON
                    cCont    ,; //TPZ_CONGAR
                    nPox  }  //Linha do aCOLS
Else
EndIf

Return aGarant

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³NGD3GARANT³ Autor ³Vitor Emanuel Batista  ³ Data ³10/02/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Integracao de garantia de insumo em Movimentos Internos     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAEST                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs.      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGD3GARANT()
Local aArea := GetArea()
Local lRet  := NGCADICBASE("D3_GARANTI","A","SD3",.F.)
RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ValGarant ³ Autor ³Vitor Emanuel Batista  ³ Data ³10/02/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida dados da janela de Garantia                          |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ NGTPZGARAN                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValGarant()
Local nCont,nPosCont

If (Empty(nQtde) .And. !Empty(cUni)) .Or. (Empty(nQtdeC) .And. !Empty(cCont))
	MsgStop(STR0063,STR0037) //"Informe a quantidade da garantia"
	Return .F.
ElseIf (!Empty(nQtde) .And. Empty(cUni)) .Or. (!Empty(nQtdeC) .And. Empty(cCont))
	MsgStop(STR0064,STR0037)//"Informe a unidade da garantia"
	Return .F.
ElseIf (Empty(nQtde) .And. Empty(cUni)) .And. (Empty(nQtdeC) .And. Empty(cCont))
	MsgStop(STR0065,STR0037) //"Informe o tipo de garantia"
	Return .F.
EndIf

If !Empty(nQtdeC) .And. !lTemCG2 .And. cCont = STR0054
   MsgStop(STR0066+" "+Alltrim(STJ->TJ_CODBEM)+" "+STR0067+" "+STR0054,STR0037)
   Return .F.
EndIf

If cCont == STR0053 //"Contador 1"
	nCont := 1
	nPosCont := nPosCon
ElseIf cCont == STR0054 //"Contador 2"
	nCont := 2
	nPosCont := nPosCon2
EndIf

NGCONGARAN(cCodBem,cProduto,cLocaliz,nCont,nPosCont)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³NGRETESTMOV ³ Autor ³Inacio Luiz Kolling  ³ Data ³29/06/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Navegacao na estrutura do bem                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³NGRETCOMPEST                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGRETESTMOV(cCOD)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³NGGRVGARAN³ Autor ³ Vitor Emanuel Batista ³ Data ³11/02/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava a garantia de acordo com a Array em parametro        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aGarant  -> NGTPZGARAN()                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³  Nil                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAMNT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGGRVGARAN(aGarant,x,cSeqR)
Local cCodBem, cProduto, cTipoReg ,cLocaliz, cOrdem, cPlano, nQtde, cUni, nQtdeC, cCont
cCodBem  := aGarant[x][1]  //TPZ_CODBEM
cProduto := aGarant[x][2]  //TPZ_CODIGO
cTipoReg := aGarant[x][3]  //TPZ_TIPORE
cLocaliz := aGarant[x][4]  //TPZ_LOCGAR
cOrdem   := aGarant[x][5]  //TPZ_ORDEM
cPlano   := aGarant[x][6]  //TPZ_PLANO
nQtde    := aGarant[x][7]  //TPZ_QTDGAR
cUni     := aGarant[x][8]  //TPZ_UNIGAR
nQtdeC   := aGarant[x][9]  //TPZ_QTDCON
cCont    := aGarant[x][10] //TPZ_CONGAR

If !NGIfDBSEEK("TPZ",cCodBem+cTipoReg+cProduto+cLocaliz+cOrdem+cPlano+cSeqR,1,.F.)
	RecLock("TPZ",.T.)
	TPZ->TPZ_FILIAL := xFilial("TPZ")
	TPZ->TPZ_CODBEM := cCodBem
	TPZ->TPZ_TIPORE := cTipoReg
	TPZ->TPZ_CODIGO := cProduto
	TPZ->TPZ_LOCGAR := cLocaliz
	TPZ->TPZ_ORDEM  := cOrdem
	TPZ->TPZ_PLANO  := cPlano
	TPZ->TPZ_SEQREL := cSeqR
	TPZ->TPZ_QTDGAR := nQtde
	TPZ->TPZ_UNIGAR := cUni
	TPZ->TPZ_DTGARA := SD3->D3_EMISSAO
	TPZ->TPZ_CONGAR := cCont
	If NGCADICBASE("TPZ_QTDCON","A","TPZ",.F.)
		TPZ->TPZ_QTDCON := nQtdeC
	EndIf
	MsUnLock("TPZ")
EndIf
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³NGRetSulcoºAutor  ³Wagner S. de Lacerdaº Data ³  03/01/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o sulco do pneu.                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cPneu -> Obrigatorio;                                      º±±
±±º          ³          Indica o pneu a verificar.                        º±±
±±º          ³ dData -> Obrigatorio;                                      º±±
±±º          ³          Indica a data para buscar o sulco.                º±±
±±º          ³          (formato data sistema - DD/MM/AA ou DD/MM/AAAA)   º±±
±±º          ³ cHora -> Obrigatorio;                                      º±±
±±º          ³          Indica a hora para buscar o sulco.                º±±
±±º          ³ lHist -> Opcional;                                         º±±
±±º          ³          Indica se retornara o historico ou o sulco.       º±±
±±º          ³          .T. -> Retorna historico.                         º±±
±±º          ³          .F. -> Retorno o sulco. (Default)                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ aSulco -> Vetor com historico de sulcos.                   º±±
±±º          ³ nSulco -> Sulco atual de acordo com a Data e a Hora.       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAMNT                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObservacao³ Para utilizar a barra de carregamento, deve-se chamar esta º±±
±±º          ³ funcao atraves de uma outra funcao: Processa().            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador ³   Data     ³ Descricao                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º            ³ xx/xx/xxxx ³                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGRetSulco(cPneu, dData, cHora, lHist)

Local aSulco := {}
Local nSulco := 0, nCont := 0
Local lElse  := .T.
Local uRet

Default lHist := .F.

dbSelectArea("TQS")
dbSetOrder(1)
If dbSeek(xFilial("TQS")+cPneu)
	If DTOS(dData) == DTOS(TQS->TQS_DTMEAT) .And. cHora >= TQS->TQS_HRMEAT
		ProcRegua(1)
		nSulco := TQS->TQS_SULCAT
		lElse  := .F.
		IncProc("Carregando...")
	EndIf
EndIf

If lElse
	dbSelectArea("TQV")
	dbSetOrder(1)
	If dbSeek(xFilial("TQV")+cPneu)
		ProcRegua(LastRec())
		While !EoF() .And. TQV->TQV_FILIAL == xFilial("TQV") .And. TQV->TQV_CODBEM == cPneu
			IncProc("Carregando...")

			aAdd(aSulco, {cPneu, TQV->TQV_DTMEDI, TQV->TQV_HRMEDI, TQV->TQV_SULCO})

			dbSelectArea("TQV")
			dbSkip()
		End
		If Len(aSulco) > 0
			aSort(aSulco, , , {|x,y| DTOS(x[2])+x[3]+cValToChar(x[4]) < DTOS(y[2])+y[3]+cValToChar(y[4]) })

			If !lHist
				ProcRegua(Len(aSulco))
				For nCont := 1 To Len(aSulco)
					IncProc("Calculando...")
					If dData < aSulco[nCont][2]
						Exit
					Else
						If cHora >= aSulco[nCont][3]
							nSulco := aSulco[nCont][4]
						EndIf
					EndIf
				Next nCont
				IncProc("Calculando...")
			EndIf
		EndIf
	EndIf
EndIf

If lHist
	uRet := aClone(aSulco)
Else
	uRet := nSulco
EndIf

Return uRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGTIPSER  ³ Autor ³ Inacio Luiz Kolling   ³ Data ³10/09/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o Tipo do Servico                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGTIPSER(cSERVICO,cTIPO,lMsg)
Local OldAli  := Alias()
Local nOLDKEY := INDEXORD()
Local cMENSAN := Space(10)
Local lRet    := .T.

Default lMsg := .T.

If cTIPO == Nil
	cTIPO := 'P'
EndIf

dbSelectArea('ST4')
dbSetOrder(1)
If !dbSeek(xFilial('ST4')+cSERVICO)
	cMENSAN := "SERVNAOEXI"
	lRet    := .F.
Else
    If NGFUNCRPO("NGSERVBLOQ",.F.)
       vRetSer := NGSERVBLOQ(cSERVICO,.F.)
       If !vRetSer[1]
          cMENSAN := "REGBLOQ"
          lRet    := .F.
       EndIf
    EndIf
    If lRet
       dbSelectArea('STE')
       dbSetOrder(1)
       If !dbSeek(xFilial('STE') + ST4->T4_TIPOMAN)
           cMENSAN := "TPSERVNEXI"
           lRet    := .F.
       Else
           If STE->TE_CARACTE <> cTIPO
               If cTIPO = "C" .AND. STE->TE_CARACTE = 'P'
                   cMENSAN := "SERVNAOCOR"
               Else
                   If cTIPO = "P" .AND. STE->TE_CARACTE = 'C'
                       cMENSAN := "NSERVPREVE"
                   EndIf
               EndIf
               lRet    := .F.
               If cTIPO = "C" .AND. STE->TE_CARACTE = 'O'
                   lRet    := .T.
               EndIf
           EndIf
       EndIf
    EndIf
EndIf

If !lRet .And. lMsg
	Help(" ",1,cMENSAN)
EndIf
dbSelectArea(OldAli)
dbSetOrder(nOLDKEY)

Return IIf(lMsg, lRet, {lRet,cMENSAN})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGDATHORIf  ³ Autor ³ In cio Luiz Kolling ³ Data ³19/04/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao de campos data inicio/fim e hora inicio/fim       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³NGESTVITOB                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGDATHORIf(dVDATAI,cVHORAI,dVDATAF,cVHORAF,nVITEM)
If Empty(dVDATAI) .Or. Empty(dVDATAF) .Or. Empty(cVHORAI) .Or.;
	Alltrim(cVHORAI) = ":" .Or. Empty(cVHORAF) .Or. Alltrim(cVHORAf) = ":"
	MsgInfo(STR0068+chr(13)+STR0069+" "+str(nVITEM,3)+" "+STR0070,STR0002)
	Return .F.
EndIf
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} NGATUATF
Atualiza o Centro de Custo do bem no ativo fixo se estiver integrado com
o ativo fixo. Só vai atualizar se o parametro MV_NGMNTAT estiver = 2 ou 3

@param String cCODIMOB: Código do Imobilizado
@param String cCCUSTO: Centro de Custo

@author Elisangela Costa
@since 25/11/2005
@version P11
@return Boolean lRet: ever true
/*/
//---------------------------------------------------------------------
Function NGATUATF(cCODIMOB,cCCUSTO,lMostraErro)

	Local lRet       := .T.
	Local lMNTXATF1  := ExistBlock( 'MNTXATF1' )
	Local dTransf    := CTOD( "  /  /    " )
	Local cHoraTransf:= ""
	Local cBaseATF   := ""
	Local aDadosAuto := {}		// Array com os dados a serem enviados pela MsExecAuto() para gravacao automatica
	Local xRetPE

	Default lMostraErro := .T.

	Private lAutoErrNoFile := .F.
	Private lMsHelpAuto    := .F.	// Determina se as mensagens de help devem ser direcionadas para o arq. de log
	Private lMsErroAuto    := .F.	// Determina se houve alguma inconsistência na execucao da rotina

	If !lMostraErro
		lAutoErrNoFile := .T.
		lMsHelpAuto    := .T.
	EndIf

	If GetMv("MV_NGMNTAT") $ "2#3" .And. !Empty(cCODIMOB)

		dbSelectArea("SN1")
		dbSetOrder( 01 ) // N1_FILIAL+N1_CBASE+N1_ITEM
		If dbSeek( xFilial( "SN1" ) + cCODIMOB )

			If SN1->N1_QUANTD == 1

				dbSelectArea("SN3")
				dbSetOrder( 01 ) // N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
				If dbSeek( xFilial( "SN3" ) + cCODIMOB)

					//----------------------------------------
					// Processa transferência no Ativo Fixo
					//----------------------------------------
					If !( Trim( SN3->N3_CCUSTO ) == Trim( cCCUSTO ) ) .Or. !( Trim( SN3->N3_CUSTBEM ) == Trim( cCCUSTO ) )

						dTransf      := If ( IsInCallStack( "MNTA470" ),M->TPN_DTINIC,dDataBase ) // Data da Transferência
						cHoraTransf  := If ( IsInCallStack( "MNTA470" ),M->TPN_HRINIC,Time() )    // Hora da Transferência
						cBaseATF := SubStr( AllTrim( cCODIMOB ),1,Len(  cCODIMOB  ) - TamSX3("N3_ITEM")[1] )

						aDadosAuto:= {	{ "N3_FILIAL"  , xFilial( "SN3" ), Nil },;	// Codigo base do ativo
										{ "N3_CBASE"   , cBaseATF        , Nil },;	// Codigo base do ativo
										{ "N3_ITEM"    , SN3->N3_ITEM    , Nil },;	// Item sequencials do codigo bas do ativo
										{ "N4_DATA"    , dTransf         , Nil },;	// Data de aquisicao do ativo
										{ 'N4_HORA'    , cHoraTransf	 , Nil },;	// Hora da transferencia do ativo
										{ "N3_CUSTBEM" , cCCUSTO		 , Nil },;	// Centro de Custo da Conta do Bem
										{ "N1_Local"   , SN1->N1_Local   , Nil },; // Numero da NF
										{ "N1_TAXAPAD" , SN1->N1_TAXAPAD , Nil },; // Codigo da Taxa Padrao
										{ "N3_CCORREC" , SN3->N3_CCORREC , Nil },;
										{ "N3_CDESP"   , SN3->N3_CDESP   , Nil },;
										{ "N3_CDEPREC" , SN3->N3_CDEPREC , Nil },;
										{ "N3_SUBCTA"  , SN3->N3_SUBCTA  , Nil },;
										{ "N3_SUBCCON" , SN3->N3_SUBCCON , Nil },;
										{ "N3_SUBCDEP" , SN3->N3_SUBCDEP , Nil },;
										{ "N3_SUBCCDE" , SN3->N3_SUBCCDE , Nil },;
										{ "N3_SUBCDES" , SN3->N3_SUBCDES , Nil },;
										{ "N3_SUBCCOR" , SN3->N3_SUBCCOR , Nil },;
										{ "N3_CLVL"    , SN3->N3_CLVL    , Nil },;
										{ "N3_CLVLCON" , SN3->N3_CLVLCON , Nil },;
										{ "N3_CLVLDEP" , SN3->N3_CLVLDEP , Nil },;
										{ "N3_CLVLCDE" , SN3->N3_CLVLCDE , Nil },;
										{ "N3_CLVLDES" , SN3->N3_CLVLDES , Nil },;
										{ "N3_CLVLCOR" , SN3->N3_CLVLCOR , Nil },;
										{ 'N1_GRUPO'   , SN1->N1_GRUPO   , Nil } }

						If !Empty(SN1->N1_TAXAPAD)
							aAdd(aDadosAuto,{ "N1_TAXAPAD" ,SN1->N1_TAXAPAD  ,Nil })
						EndIf

						If lMNTXATF1

							xRetPE := ExecBlock( 'MNTXATF1', .F., .F., { aDadosAuto } )

							If ValType( xRetPE ) == 'A'
								aDadosAuto := aClone( xRetPE )
							EndIf

						EndIf

						MSExecAuto( { |w,x,y,z| AtfA060( w,x,y,z ) },aDadosAuto,4 ,, .F. ) //quarto parametro é falso para nao replicar os dados do grupo do ativo

						If lMsErroAuto //Se ocorrer inconsistência junto a transferência do C.C e C.T.
							If lMostraErro
								MostraErro() //Executa o log do erro.
							EndIf
							lRet := .F. //Retorna Falso.
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MNTANCOP  ³ Autor ³Inacio Luiz Kolling    ³ Data ³05/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta e/ou refaz o getdados                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MNTACOP                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MNTANCOP(oGet)
Local xn := 0, aColOd := Aclone(aCOLS)
aCols  := {}

If nCopias <=0
   MsgInfo(STR0071,STR0002)  //"Informe o numero de copias." # "NAO CONFORMIDADE"
   Return .F.
EndIf

For xn := 1 To nCopias
   If xn <= Len(aColOd)
      aAdd(aCols,{xn,aColOd[xn,nDaHe],aColOd[xn,Len(aColOd[xn])]})
   Else
      aAdd(aCols,{xn,stj->tj_dtmpini,.F.})
   EndIf
Next xn
oGet:FORCEREFRE()
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} ShowF4MNT
Chamada da funcao F4MNTLocal

@return Nil

@sample
ShowF4MNT()

@author Elisangela Costa
@since 11/03/08
@version 1.0
/*/
//---------------------------------------------------------------------
Function ShowF4MNT()
	Local cCampo := AllTrim(Upper(ReadVar()))

	If cCampo == "M->TL_LOCALIZ" .Or. cCampo == "M->TL_NUMSERI"
		F4MNTLocal()
	EndIf
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGSERBLOQ   ³ Autor ³ Inacio Luiz Kolling   ³ Data ³24/09/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se o registro do servico esta bloqueado para uso     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCampo - Campo                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³DICIONARIO DE DADOS                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGSERVBLOQ(cServi,lSaida)
Local vMenBlq := {.T.,Space(1)}, lTela := If(lSaida = Nil,.T.,lSaida)
If NGCADICBASE("T4_MSBLQL","D","ST4",.F.)
   If NGIfDBSEEK("ST4",cServi,1) .And. ST4->T4_MSBLQL = "1"
      If lTela
         Help(" ",1,"REGBLOQ",,STR0078,3,1)
      EndIf
      vMenBlq := {.F.,"REGBLOQ"}
   EndIf
EndIf
Return If(lTela,vMenBlq[1],vMenBlq)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGX3PV      ³ Autor ³ Inacio Luiz Kolling   ³ Data ³24/09/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Formatacao da picture do campo. A principio CNPJ/CPF          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCampo - Campo                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³DICIONARIO DE DADOS                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGX3PV(cCampo)
Local aOldArea := GetArea()
Local cRetPict := NGSEEKDIC("SX3",cCampo,2,'X3_PICTURE')
If cCampo = "TQF_CNPJ" .Or. cCampo = "TQN_CNPJ"
   If cCampo = "TQF_CNPJ"
      cChaveAP := M->TQF_CODIGO+M->TQF_LOJA
   ElseIf cCampo = "TQN_CNPJ"
      cChaveAP := M->TQN_POSTO+M->TQN_LOJA
   EndIf
   NGIfDBSEEK("SA2",cChaveAP,1)
   cRetPict := Picpes(SA2->A2_TIPO)
EndIf
RestArea(aOldArea)
Return cRetPict

//-------------------------------------------------------------------
/*/{Protheus.doc} NGRESPETAEX
Verifica obriga a resposta das etapas e executante

@type Function
@author Inacio Luiz Kolling
@since 05/02/2010
@param cNumOrde				, character, Número da Ordem de Serviço ( TQ_ORDEM )
@param lTipoSai				, boolean  , Tipo de Saída
@param [cNomeTmp]			, character, nome da tabela temporaria caso seja analisada
@param [lUsaFil]			, character, Indica se o Alias em questão utiliza Filial
@return .T. ou .F.		   	, boolean  , Para lTipoSai = .T.
@return {.T. ou .F., Mensa}	, array    , Para lTipoSai = .F.
/*/
//-------------------------------------------------------------------
Function NGRESPETAEX( cNumOrde, lTipoSai, cNomeTmp, lUsaFil )

	Local aArA 		:= GetArea()
	LocaL vRet 		:= { .T., "   " }
	Local lSait 	:= IIf( lTipoSai = Nil, .T., lTipoSai )
	Local cAliasSTQ	:= GetNextAlias()
	Local cTabela	:= ""
	Local cUsaFil	:= ""

	Default cNomeTmp := ""
	Default lUsaFil  := .T.

	If SuperGetMv( "MV_NGETAEX", .F., "0" ) == "1"

		cTabela	:= "%" + IIf( Empty( cNomeTmp ), RetSqlName( 'STQ' ), cNomeTmp ) + "%"
		cUsaFil := "%" + IIf( lUsaFil, " AND TQ_FILIAL = " + ValToSQL( xFilial( 'STQ' ) ), "" ) + " %"

		BeginSQL Alias cAliasSTQ
			SELECT COUNT( TQ_ORDEM ) QTDNEXEC
			FROM %exp:cTabela%
			WHERE TQ_ORDEM = %exp:cNumOrde%
				AND (
					TQ_OK = ' '
					OR TQ_CODFUNC = ' '
					)
				AND %NotDel%
				%exp:cUsaFil%
		EndSQL

		If ( cAliasSTQ )->QTDNEXEC > 0
			vRet := { .F., STR0079 }
		EndIf

		If lSait .And. !vRet[1]
			MsgInfo( vRet[2] + " " + cNumOrde, STR0002 )
		EndIf

		( cAliasSTQ )->( dbCloseArea() )

	EndIf

	RestArea( aArA )

Return If( lSait, vRet[1], vRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} NOMINSBRW
Mostra o nome do insumo no Browse

@author  Inacio Luiz Kolling
@since   29/07/99
@version P11/P12
@param   cTIPREG, Caracter, Tipo de insumo
@param   cCODIGO, Caracter, Código do Insumo
@param   [cLoja], Caracter, Loja do Fornecedor (A2_LOJA)

@return  Caracter, Descrição do insumo.
/*/
//-------------------------------------------------------------------
Function NOMINSBRW( cTIPREG, cCODIGO, cLoja )

	Local aArea   := GetArea()
	Local cRet    := Space( 20 )

	Default cLoja := ''

	If cTIPREG == 'E'      // especialista
		ST0->(dbSeek(xFilial("ST0")+Trim(cCODIGO)))
		cRET := st0->t0_nome
	ElseIf cTIPREG == 'M'  // funcionario
		ST1->(dbSeek(xFilial("ST1")+Trim(cCODIGO)))
		cRET := st1->t1_nome
	ElseIf cTIPREG == 'P' // produto
		SB1->(dbSeek(xFilial("SB1")+Trim(cCODIGO)))
		cRET := sb1->b1_desc
	ElseIf cTIPREG == 'F' // ferramenta
		SH4->(dbSeek(xFilial("SH4")+Trim(cCODIGO)))
		cRET := sh4->h4_descri
	ElseIf cTIPREG == 'T' // Terceiro
		SA2->( dbSeek( xFilial( 'SA2' ) + Left( cCODIGO, Len( A2_COD ) ) + cLoja ) )
		cRET := SA2->A2_NOME
	EndIf

	RestArea( aArea )

Return cRET

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGINTESTORG³ Autor ³In cio Luiz Kolling    ³ Data ³30/04/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se tem estrutura organizacional (Bem/Localizacao)   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³.T. ou .F.                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGINTESTORG()
Local lTEMINTO := .F. ,nQTDREG := 0
dbSelectArea("TAF")
dbSetOrder(6)
If dbSeek(xFILIAL("TAF")+"X")
   While !EoF() .And. taf->taf_filial = xFILIAL("TAF");
      .And. taf->taf_modmnt = "X"
      If taf->taf_indcon $"12"
         nQTDREG += 1
         If nQTDREG >= 2
            lTEMINTO := .T.
            Exit
         EndIf
      EndIf
      dbSkip()
   End
EndIf
Return lTEMINTO

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGCHKCODORG³ Autor ³In cio Luiz Kolling    ³ Data ³30/04/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se o codigo do retorna e valido (Bem/Localizacao)   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cVCHAVEOG - Chave primaria do est.org. (TAF) - Obrigat¢rio   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³.T. ou .F.                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGCHKCODORG(cVCHAVEOG)
Local lRETOROG := .T.
dbSelectArea("TAF")
dbSetOrder(2)
If dbSeek(xFILIAL("TAF")+cVCHAVEOG)
   If taf->taf_indcon $"12"

      If cARQUISAI = "STJ"
         M->TJ_TIPOOS := If(taf->taf_indcon = "2","L","B")
      ElseIf cARQUISAI = "TQB"
         M->TQB_TIPOSS := If(taf->taf_indcon = "2","L","B")
      ElseIf cARQUISAI = "XXX"
         cTIPOSS  := If(taf->taf_indcon = "2","L","B")
      EndIf

   Else
      MsgInfo(STR0080+chr(13)+chr(10)+STR0081+STR0082,STR0002)
      lRETOROG := .F.
   EndIf
EndIf
Return lRETOROG

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGTAFMNT    ³ Autor ³ Inacio Luiz Kolling   ³ Data ³17/02/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consistencia de consulta especial (F3) estrutura organizacio- ³±±
±±³          ³nal                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGTAFMNT(cCAMLEI, lSkipF11)
Local cAlias := Alias()
Local nITEM := 0
Local aAreaTa := GetArea()
Private lTEMFACI  := NGINTESTORG()
vCAMPOS := Space(16)

If Type("cARQUISAI") = "U"
   cARQUISAI := "STJ"
EndIf

If Type("oEnchoice") = "U" .And. Type("oEncSS") != "U"
   oEnchoice := oEncSS
EndIf

If Readvar() = cCAMLEI
   If !lTEMFACI
      MsgInfo(STR0083+" SIGAMNT",STR0002)
   Else
      lAHEADER := .F.
      If type("aHeader") = "A"
         aHAEDOLD := Aclone(aHeader)
         lAHEADER := .T.
      EndIf

      aINTESOG := SGESTMOD(4)

      If Len(aINTESOG) = 0
         If lAHEADER
            aHeader := Aclone(aHAEDOLD)
         EndIf
         RestArea(aAreaTa)
         Return .F.
      EndIf

      If aINTESOG[1,1]
         If INCLUI .Or. ALTERA
            If !NGCHKCODORG(aINTESOG[1,2])
               If lAHEADER
                  aHeader := Aclone(aHAEDOLD)
               EndIf
               RestArea(aAreaTa)
               Return .F.
            EndIf
            If cARQUISAI = "STJ"
               M->TJ_CODBEM := If(taf->taf_indcon = "2",taf->taf_codniv+Space(16-3),taf->taf_codcon)
               M->TJ_TIPOOS := If(taf->taf_indcon = "2","L","B")
               vCAMPOS := M->TJ_CODBEM
               nITEM := Ascan(oENCHOICE:aGETS,{|X| "TJ_SERVICO" $X})
            ElseIf cARQUISAI = "TQB"
               M->TQB_CODBEM := If(taf->taf_indcon = "2",taf->taf_codniv+Space(16-3),taf->taf_codcon)
               M->TQB_TIPOSS := If(taf->taf_indcon = "2","L","B")
               vCAMPOS :=  M->TQB_CODBEM
               nITEM := Ascan(oENCHOICE:aGETS,{|X| "TQB_CCUSTO" $X})

               If !NG280BEMLOC(M->TQB_TIPOSS)
                  If lAHEADER
                     aHeader := Aclone(aHAEDOLD)
                  EndIf
                  RestArea(aAreaTa)
                  Return .F.
               EndIf
            ElseIf cARQUISAI = "XXX"
               cBEMSOLI := If(taf->taf_indcon = "2",taf->taf_codniv+Space(16-3),taf->taf_codcon)
               cTIPOSS  := If(taf->taf_indcon = "2","L","B")
               vCAMPOS  := cBEMSOLI
               oDLGA:SETFOCUS(oSERVICO)
               If !NG290BEMLOC(cTIPOSS)
                  If lAHEADER
                     aHeader := Aclone(aHAEDOLD)
                  EndIf
                  RestArea(aAreaTa)
                  Return .F.
               EndIf
            EndIf
            If nITEM > 0
               oOBSTJ := oENCHOICE:aENTRYCTRLS[nITEM]
               oOBSTJ:SETFOCUS(oOBSTJ)
            EndIf
         EndIf
      EndIf
      If lAHEADER
         aHeader := Aclone(aHAEDOLD)
      EndIf
   EndIf
Else
	If lSkipF11 = .T.
		Return
	EndIf

   lCONDP := CONPAD1(NIL,NIL,NIL,"ST9",NIL,NIL,.F.)
   If lCONDP
      If cARQUISAI = "STJ"
         M->TJ_CODBEM := st9->t9_codbem
         vCAMPOS :=  M->TJ_CODBEM
         M->TJ_TIPOOS := "B"
      Else
         M->TQB_CODBEM := st9->t9_codbem
         M->TQB_TIPOSS := "B"
         vCAMPOS :=  M->TQB_CODBEM

         dbSelectArea("ST9")
         dbSetOrder(1)
         dbSeek(xFILIAL("ST9")+M->TQB_CODBEM)
         M->TQB_NOMBEM  := ST9->T9_NOME
         M->TQB_CCUSTO  := ST9->T9_CCUSTO
         M->TQB_NOMCUS  := NGSEEK("CTT",M->TQB_CCUSTO,1,"CTT_DESC01")
         M->TQB_LocalI  := ST9->T9_Local
         M->TQB_NOMLOC  := NGSEEK("TPS",M->TQB_LocalI,1,"TPS_NOME")
         M->TQB_CENTRA  := ST9->T9_CENTRAB
         M->TQB_NOMCTR  := NGSEEK("SHB",M->TQB_CENTRA,1,"HB_NOME")

         If Type("cPROGRAMA") <> "U"
            If cPROGRAMA <> "MNTA290" .And. cPROGRAMA <> "MNTA295"
               nITEM := Ascan(oENCHOICE:aGETS,{|X| "TQB_CCUSTO" $X})
               If nITEM > 0
                  oOBSTJ := oENCHOICE:aENTRYCTRLS[nITEM]
                  oOBSTJ:SETFOCUS(oOBSTJ)
               EndIf
            EndIf
         Else
            nITEM := Ascan(oENCHOICE:aGETS,{|X| "TQB_CCUSTO" $X})
            If nITEM > 0
               oOBSTJ := oENCHOICE:aENTRYCTRLS[nITEM]
               oOBSTJ:SETFOCUS(oOBSTJ)
            EndIf
         EndIf

      EndIf
      lREFRESH := .T.
   EndIf
EndIf
RestArea(aAreaTa)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ NGCOROSLENGBAutor ³Inácio Luiz Kolling  ³ Data ³ 17/03/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Define a cor da legenda da ordem de servico                 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cChaveA  -> Chave de acesso Nao obrigatório                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³vRetCor  - Vetor com a cor da legenda                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGCOROSLENG(cChaveA)
Local aAreaCT := GetArea() ,vRetCor := {0,"BR_PRETO"}
If cChaveA <> Nil
   NGIfDBSEEK("STJ",cChaveA,1,.F.)
EndIf
If !Empty(STJ->TJ_TIPORET) .And. STJ->TJ_DTMPFIM >= dDataBase
   vRetCor := {1,"BR_VERDE"}
ElseIf Empty(STJ->TJ_TIPORET) .And. STJ->TJ_DTMPFIM >= dDataBase
   vRetCor := {2,"BR_VERMELHO"}
ElseIf Empty(STJ->TJ_TIPORET) .And. STJ->TJ_DTMPFIM < dDataBase
	vRetCor := {3,"BR_AMARELO"}
ElseIf !Empty(STJ->TJ_TIPORET) .And. STJ->TJ_DTMPFIM < dDataBase
	vRetCor := {4,"BR_AZUL"}
EndIf
RestArea(aAreaCT)
Return vRetCor

//---------------------------------------------------------------------
/*{Protheus.doc} NgEmailWF
Função generica para verificar os e-mails cadastrado na tabela TKS
para enviar o workflow

@return cEmails

@param cTipWf - Tipo do Wokflow	1 = Oficina
									2 = Pneus
									3 = Multas
									4 = Sinistros
									5 = Documentos
									6 = Todos

@author Tainã Alberto Cardoso
@since 18/03/2014
@version 1.0
//---------------------------------------------------------------------
*/
Function NgEmailWF(cTipWf,cProgWf)

	Local aArea    := GetArea()
	Local cEmails  := ''

	Default cTipWf := '6'

	dbSelectArea( 'TSK' )
	dbSetOrder( 2 ) //TSK_FILMS + TSK_PROCES
	If dbSeek( cFilAnt + cTipWf )

		Do While TSK->( !EoF() ) .And. cFilAnt == TSK->TSK_FILMS .And. cTipWf == TSK->TSK_PROCES

			//Verifica se o Workflow esta contido para enviar para o usuario
			If !Empty( AllTrim( TSK->TSK_EMAIL ) ) .And. !( AllTrim( TSK->TSK_EMAIL ) $ cEmails )

				If cProgWf $ MSMM( TSK->TSK_LISTWF, , , , 3 )
					cEmails += Lower( AllTrim( TSK->TSK_EMAIL ) ) + ';'
				EndIf

			Else

				dbSelectArea( 'ST1' )
				dbSetOrder( 1 )
				If dbSeek( xFilial( 'ST1' ) + TSK->TSK_CODFUN )
					//Seleciona o E-mail do funcionário
					If !Empty( AllTrim( ST1->T1_EMAIL ) ) .And. !( Alltrim( ST1->T1_EMAIL ) $ cEmails )

						If cProgWf $ MSMM( TSK->TSK_LISTWF, , , , 3 )
							cEmails += Lower( AllTrim( ST1->T1_EMAIL ) ) + ';'
						EndIf

					EndIf

				EndIf

			EndIf

			TSK->( dbSkip() )

		EndDo

	EndIf

	//Verifica todos os e-mail que estão no grupo Todos
	dbSelectArea( 'TSK' )
	dbSetOrder( 2 ) // TSK_FILMS + TSK_PROCES
	If dbSeek( cFilAnt + '6' )

		Do While TSK->( !EoF() ) .And. cFilAnt == TSK->TSK_FILMS .And. '6' == TSK->TSK_PROCES

			//Verifica se o Workflow esta contido para enviar para o usuario
			If !Empty( AllTrim( TSK->TSK_EMAIL ) ) .And. !( AllTrim( TSK->TSK_EMAIL ) $ cEmails )

				If cProgWf $ MSMM(TSK->TSK_LISTWF,,,,3)
					cEmails += Lower(Alltrim(TSK->TSK_EMAIL)) + ";" //Este campo é virtual, não sendo possível utilizar o mesmo
				EndIf

			Else

				dbSelectArea("ST1")
				dbSetOrder(01)
				If dbSeek(xFilial("ST1")+TSK->TSK_CODFUN)

					//Seleciona o E-mail do funcionário
					If !Empty(Alltrim(ST1->T1_EMAIL)) .And. !(Alltrim(ST1->T1_EMAIL) $ cEmails)

						If cProgWf $ MSMM(TSK->TSK_LISTWF,,,,3)
							cEmails += Lower(AllTrim(ST1->T1_EMAIL)) + ";"
						EndIf

					EndIf

				EndIf

			EndIf

			TSK->( dbSkip() )

		EndDo

	EndIf

	RestArea( aArea )

Return cEmails

//------------------------------------------------------------------------------
/*/{Protheus.doc} NGVALPLACA
Consistencia da placa do veiculo

@author Inacio Luiz Kolling
@since 11/08/2006
@param cPlaca  - Codigo da placa          - Obrigatorio
	   lMosR   - Mostar mensagem na tela  - Nao Obrigatorio
	   cFilRet - Retorno da filial do Bem - Nao Obrigatorio
	   cBemRet - Retorno do codigo do Bem - Nao Obrigatorio
@return lRetPl - Lógico | .T. = OK
/*/
//------------------------------------------------------------------------------
Function NGVALPLACA(cPlaca,lMosR,cFilRet,cBemRet)

	Local lRetPl  := .T.
	Local lAtivo  := .F.
	Local lMosT   := IIf(lMosR = Nil,.T.,lMosR)
	Local cMensaP := Space(1)
	Local aAreaPl := GetArea()
	Local cEmpTTM := ""
	Local cOldEmp := cEmpAnt

	DbSelectArea("ST9")
	DbSetOrder(14)
	If !DbSeek(cPlaca)
		cMensaP := STR0084
	Else
		While !Eof() .And. ST9->T9_PLACA == cPlaca
			If ST9->T9_SITBEM = 'A'
				lATIVO := .T.
				If cFilRet <> Nil
					&cFilRet := ST9->T9_FILIAL
				Endif
				If cBemRet <> Nil
					&cBemRet := ST9->T9_CODBEM
				Endif
				Exit
			EndIf
			DbSkip()
		EndDo
	Endif

	If Empty(cMensaP) .And. !lATIVO
		cMensaP := STR0085
	EndIf

	If !Empty(cMensaP) .And. lMosT
		MsgInfo(cMensaP,STR0002)
		lRetPl := .F.
	Endif

	RestArea(aAreaPl)

Return lRetPl

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGPROXABAST³ Autor ³Inacio Luiz Kolling    ³ Data ³25/08/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Proxima numeracao do abastecimento da filial                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cFilPar - Codigo da filial                 - Nao Obrigatorio ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³cProxAb - Numero do proximo abastecimento da filial          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGPROXABAST(cFilPar)
Local aAreaPA := GetArea()
Local cFilAbs := NGTROCAFILI("TQN",cFilPar)
Local cProxAb := Replicate('0',Len(TQN->TQN_NABAST))
Local cMaxMAb := Replicate('Z',Len(TQN->TQN_NABAST))

dbSelectArea('TQN')
dbSetOrder(4)
dbSeek(cFilAbs+cMaxMAb,.T.)
If EoF()
   dbSkip(-1)
   If !BoF() .And. TQN->TQN_FILIAL = cFilAbs
      cProxAb := TQN->TQN_NABAST
   EndIf
Else
   If TQN->TQN_FILIAL = cFilAbs
      cProxAb := TQN->TQN_NABAST
   Else
      dbSkip(-1)
      If !BoF() .And. TQN->TQN_FILIAL = cFilAbs
         cProxAb := TQN->TQN_NABAST
      EndIf
   EndIf
EndIf

RestArea(aAreaPA)
Return cProxAb

//----------------------------------------------------------------
/*/{Protheus.doc} GetLSNum()
Função não definida.

@author Anonymous
@since	XX/XX/XXXX
/*/
//----------------------------------------------------------------
Static Function GetLSNum(cAlias, cCpoSx8, cAliasSX8, nOrdem, cFilSXE)

	Local cRet, nRet
	Local nSizeFil := 2

	Local __SpecialKey	:= IIf (Type("SpecialKey") == Nil, Upper(GetSrvProfString("SpecialKey")), "")
	Local __aKeys		:= {}

	nOrdem := IIf(nOrdem == Nil, 1, nOrdem)

	//Atualiza o conteúdo da filial
	If FindFunction("FWSizeFilial")
		nSizeFil := FWSizeFilial()
	EndIf

	If cAliasSX8 == Nil
		cAliasSx8  :=   PadR(cFilSXE + Upper( X2Path(cAlias) ),48 + nSizeFil)
	Else
		cAliasSx8  :=   Upper( Padr(cAliasSx8, 48 + nSizeFil) )
	EndIf

	cRet := LS_GetNum(__SpecialKey + cAliasSX8 + cAlias)

	If ( Empty(cRet) )
		cRet := CriaSXE(cAlias, cCpoSX8, cAliasSX8, nOrdem, .T.)
		nRet := LS_CreateNum(__SpecialKey + cAliasSx8 + cAlias, cRet)

		If nRet < 0 .And. nRet != -12    // Chave Duplicada é -12
			UserException(" Error On LS_CreateNum : " + Str(nRet, 4, 0))
		EndIf

		cRet := LS_GetNum(__SpecialKey + cAliasSX8 + cAlias)

		If Empty(cRet)
			UserException(" Error On GetLSNUM : Empty")
		EndIf
	EndIf

	aAdd(__aKeys, { __SpecialKey + cAliasSX8 + cAlias, cRet, cAlias, cCpoSX8})

	__lSX8 := .T.

Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGPRIABAS ³ Autor ³ Evaldo Cevinscki Jr. ³ Data ³25/04/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se abastecimento passado no parametro eh o 1a      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Para os relatorios que fazem o calculo de Km rodado e media³±±
±±³			 ³ se for o 1a abastecimento nao faz esse calculo.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ F.O  ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGPRIABAS(cBem,cDtAbas,cHrAbas)
Local lPrimAbas := .F.

cQry := GetNextAlias()
cQuery := " SELECT MIN(TQN_DTABAS||TQN_HRABAS) AS PRIMABAS"
cQuery += " FROM " + RetSQLName("TQN")
cQuery += " WHERE TQN_FROTA = '"+cBem+"' "
cQuery += " AND D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cQry, .F., .T.)

While !EoF()
   If (cQry)->PRIMABAS == cDtAbas+cHrAbas
   	lPrimAbas := .T.
   EndIf
	dbSelectArea(cQry)
	dbSkip()
End
(cQry)->( dbCloseArea() )

Return lPrimAbas

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NG2IMPMEMO³ Autor ³ Roger Rodrigues       ³ Data ³ 14/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime campo MEMO(Utilizado principalmente para o campo   ³±±
±±³          ³ TJ_OBSERVA quando O.S. MultiEmpresa                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cDESCRIC   - Campo MEMO para ser impresso                  ³±±
±±³          ³ nTAM       - Tamanho da linha a ser impresso               ³±±
±±³          ³ nCOL       - Posi‡Æo em que come‡a a ser impresso          ³±±
±±³          ³ cTITULO    - T¡tulo que precede a primeira linha de impres.³±±
±±³          ³ lPRIMEIRO  - Indica se ser  impresso o t¡tulo              ³±±
±±³          ³ lSOMALINHA - Indica se ser  somado a linha antes de impri- ³±±
±±³          ³              mir o t¡tulo com a primeira linha da cDESCRIC ³±±
±±³          ³ cSOMALI    - Nome da fun‡Æo que imprime o cabe‡alho especi-³±±
±±³          ³              para o programa em questÆo                    ³±±
±±³          ³ Ex: NG2IMPMEMO(ST9->T9_DESCRIC,56,0,"Descricao..:",.F.,.F.,³±±
±±³          ³               "NGCABEC1()"                                 ³±±
±±³          ³ Ex: NG2IMPMEMO(TPA->TPA_DESCRI,56,0,,.F.,.F.)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NG2IMPMEMO(cDESCRIC,nTAM,nCOL,cTITULO,lPRIMEIRO,lSOMALINHA,cSOMALI)
Local nIni,nAt,nCOLuna,cLine
Default lSOMALINHA := .F., lPRIMEIRO  := .T.
Default cTITULO := "", cDESCRIC := ""
Default nTAM := 50, nCOL := 0
//Verifica se não existem quebras de linha
If (nAt:= AT(CHR(13),cDESCRIC)) > 0
	//Verifica se deve pular linha antes de imprimir
	If lSOMALINHA
		If cSOMALI <> Nil
			EVAL({|A| &(cSOMALI)})
		Else
			NGSOMALI(58)
		EndIf
	EndIf
	If !lPRIMEIRO
		@ Li,nCOL PSay cTITULO
		lPRIMEIRO := .T.
		If !Empty(cTITULO)
			nCOL := nCOL + Len(cTITULO)
		EndIf
	EndIf
	nIni:= 1
	//Verifica se ainda existem quebras
	While AT(CHR(13),SubStr(cDESCRIC,nIni)) > 0
		While nIni < nAT
			//Verifica se existem 2 quebras seguidas
			If(AT(CHR(10),Substr(cDESCRIC,nIni,1)) > 0,nIni += 1,)
			//Verifica o pedaco a ser impresso
			If (nAT-nIni) < nTAM
				cLine := Substr(cDESCRIC,nIni,nAT-nIni)
			Else
				cLine := Substr(cDESCRIC,nIni,nTAM)
			EndIf
			//Imprime da ultima quebra até a próxima e pula de linha
			If nAT > 0 .And. AllTrim(Substr(cDESCRIC,nIni,(nAT-1)-nIni)) <> CHR(10)
				@ li,nCOL Psay cLine
			EndIf
			nIni += nTAM
			//Pula Linha
			If cSOMALI <> Nil
				EVAL({|A| &(cSOMALI)})
			Else
				NGSOMALI(58)
			EndIf
		End
		nIni:= nAt+1
		nAt:= nAt + AT(CHR(13),SubStr(cDESCRIC,nIni))
	End
	If(AT(CHR(10),Substr(cDESCRIC,nIni,1)) > 0,nIni += 1,)
	If nIni <= Len(cDESCRIC)
		If Substr(cDESCRIC,nIni) <> CHR(10)
			@ li,nCOL Psay Substr(cDESCRIC,nIni)
		EndIf
	EndIf
	//Pula Linha
	If cSOMALI <> Nil
		EVAL({|A| &(cSOMALI)})
	Else
		NGSOMALI(58)
	EndIf
Else
	//Se não existir quebras de linha
	NGIMPMEMO(cDESCRIC,nTAM,nCOL,cTITULO,lPRIMEIRO,lSOMALINHA,cSOMALI)
EndIf
Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MAKEGETR ³ Autor ³ NG INFORMATICA        ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta o aCOLS com itens da base de dados                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Arg1- Alias do arquivo                                     ³±±
±±³          ³ Arg2- Chave de Pesquisa                                    ³±±
±±³          ³ Arg3- Array com o Cabecalho da GETDADOS (aHEADER)          ³±±
±±³          ³ Arg4- Expressao contendo o parametro "WHILE" fim de arquivo³±±
±±³          ³ Arg5- Prefixo do arquivo de busca dos dados                ³±±
±±³          ³ Arg6- Indica se utiliza WakeTrue, .T. = Sim, .F. = Nao     ³±±
±±³          ³       nao obrigatorio                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MAKEGETR(cALI,cKEY,aVETOR,cWHILE,cPREF,lWalkThru)
Local i,aRET := {},cOLD := ALIAS(), xx, nv:=1
Local lWalkT := NGWALKTHRU(lWalkThru)
Local nConWalt := If(lWalkT,2,0)
DBSELECTAREA(cALI)
DBGOTOP()
DBSEEK(cKEY)

Do While !EoF() .AND. &cWHILE.
         aAdd(aRET, {})
         FOR i := 1 TO LEN(aVETOR)-nConWalt
             If aVETOR[i][10] == "V"
                aAdd(aRET[nv],CriaVar(AllTrim(aVETOR[i][2])) )
             ELSE
                xx   :=  aVETOR[i][2]
                nPOS := at("_",aVETOR[i][2])
                yy   := cPREF+"_"+SUBSTR(aVETOR[i][2],NPOS+1,7)
                aAdd(aRET[nv], &yy.)
             EndIf
		 Next
		 If lWalkT
		    aAdd(aRET[nv],cAli)
		    aAdd(aRET[nv],(cALI)->(Recno()))
            aAdd(aRET[nv],.F.)
         EndIf
         DBSKIP()
         nv++
EndDo
DBSELECTAREA(cOLD)
Return aRET

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MOSTVIRTU³ Autor ³ Inacio Luiz Kolling   ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Campos virtuais para descricao do codigos dos cadastros    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aVARR vetor que contem os nomes para serem mostrados       ³±±
±±³          ³ aTAM  vetor com o tamanho dos nomes para serem mostrados   ³±±
±±³          ³ * Se aTAM[X] == 0 tamanho dos nomes = tamanho do arquivo   ³±±
±±³          ³     Senao         tamanho dos nomes = aTAM[X]              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MOSTVIRTU(aVARR,vTAM)
Local k,y

For k := 1 to Len(aGETS)
   For y := 1 to Len(aVARR)
      If ALLTRIM(SUBSTR(aGETS[k],9,10)) == aVARR[y]
         t := Val( SubStr(aGETS[k],1,2) )
         p := Val( SubStr(aGETS[k],3,1) ) * 2
         z := aVARR[y]
         aTELA[t][p] := &z.
         If vTAM[y] > 0
            aTELA[t][p] := substr(aTELA[t][p],1,vTAM[y])
         EndIf
      EndIf
   Next
Next
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ngparce   ³ Autor ³ Paulo Pego            ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que retorna parte de uma string delimitada por      ³±±
±±³          ³ virgula ajustando o restante da string                     ³±±
±±³          ³ Parcelas                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cVal  - > String com delimitador                           ³±±
±±³          ³ cDel  - > Delimitador                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ cRet - Valor excluso da string                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ngparce(cVal,cDel)
Local cRet := " ", nPos

If Empty(cVal)
   Return cVAL
EndIf
nPos := AT(cDel, cVal)
If nPos > 0
   cRet := SubStr(cVal,1,nPos-1)
   cVal := SubStr(cVal,nPos+1)
Else
   cRet := Trim(cVal)
   cVal := NIL
EndIf
cRet := If(cRet == NIL, " ", cRet)
Return cRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NGX3USO   ºAutor  ³Bruno Lobo          º Data ³  03/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica X3_USADO                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³  Generico                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGX3USO(aHeader)
Local aHeaderAux := {}
Local aNao := {}
Local nInd, nCpo

Default aHeader := {}

aHeaderAux := aClone(aHeader)

// Verifica existencia do campo, assim como seu Uso (X3_USADO)
dbSelectArea("SX3")
dbSetOrder(2)
For nInd := 1 to Len(aHeaderAux)
	If !dbSeek(aHeaderAux[nInd]) .Or. !X3USO(Posicione("SX3",2,aHeaderAux[nInd],"X3_USADO"))
		aAdd(aNao,aHeaderAux[nInd])
	EndIf
Next nInd

// Deleta do array os campos a serem desconsiderados tanto pela sua inexistencia,
// assim como pelo seu desuso (X3_USADO)
For nInd := 1 to Len(aNao)
    If (nCpo := aSCAN(aHeaderAux,{|x| x == aNao[nInd] })) > 0
		aDel(aHeaderAux,nCpo)
		aSize(aHeaderAux,Len(aHeaderAux)-1)
	EndIf
Next nInd

Return aHeaderAux

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGGVALPATGR³ Autor ³In cio Luiz Kolling    ³ Data ³25/06/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³V lida a montagem do gr fico ( arquivos,parƒmetro...)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³.T. ou .F.                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGGVALPATGR(cARQU1,cARQU2,cARQU3)
Local cPARGRAF  := "C:\GRAFING\",xa
Local dTGRAEXE  := Ctod("05/04/04"),dTEXEST := Ctod("  /  /  "),dTEXETA := dTEXEST
Local cARQUIV1  := cARQU1+".DBF",cARQUIV2 := cARQU2+".DBF", cARQUIV3 := cARQU3+".DBF"
Local vARQEXE   := {"GRAFING.EXE","CHART2FX.VBX","BIVBX10.DLL","CTL3D.DLL"}
Local cROOTPATH := Alltrim(GetSrvProfString("RootPath","\") )
Local cSTARPATH := AllTrim(GetSrvProfString("StartPath","\" ) )
Local cDIREXETH := cROOTPATH+cSTARPATH
Local cROOTPAT2 := If(Substr(cROOTPATH,Len(cROOTPATH),1) <> "\",;
                      cROOTPATH+"\",cROOTPATH)
Local vRETGRVAL := {.T.,cPARGRAF}
Local cDIREXE   := Space(40)

cDIREXETH := Strtran(cDIREXETH,"\\","\")
cDIRCRIAR := If(Substr(cPARGRAF,Len(cPARGRAF),1) = "\",;
                Substr(cPARGRAF,1,Len(cPARGRAF)-1),cPARGRAF)

cROOTPAT2 := If(Substr(cROOTPAT2,Len(cROOTPAT2),1) <> "\",;
                       cROOTPAT2+"\",cROOTPAT2)
cSTARPATH := If(Substr(cSTARPATH,Len(cSTARPATH),1) <> "\",;
                       cSTARPATH+"\",cSTARPATH)
cDIREXETH := If(Substr(cDIREXETH,Len(cDIREXETH),1) <> "\",;
                       cDIREXETH+"\",cDIREXETH)

If file(cROOTPAT2+vARQEXE[1])
   cDIREXE := cROOTPAT2
ElseIf file(cSTARPATH+vARQEXE[1])
   cDIREXE := cSTARPATH
ElseIf file(cDIREXETH+vARQEXE[1])
   cDIREXE := cDIREXETH
EndIf

If Empty(cDIREXE)
   MsgInfo(STR0103+vARQEXE[1]+" "+STR0104+chr(13)+chr(13);
          +STR0105+chr(13)+STR0106,STR0002)
   Return {.F.,Space(10)}
EndIf

aEXEATRIS := Directory(cDIREXE+vARQEXE[1])
If Len(aEXEATRIS) > 0
   dTEXEST := aEXEATRIS[1,3]
EndIf

If dTEXEST < dTGRAEXE
   MsgInfo(vARQEXE[1]+" "+STR0107+chr(13)+chr(13);
          +STR0105+chr(13)+STR0108+" "+vARQEXE[1]+".",STR0002)
   Return {.F.,Space(10)}
EndIf

MAKEDIR(cDIRCRIAR)

For xa := 1 To Len(vARQEXE)
   If file(cROOTPAT2+vARQEXE[xa])
      __copyfile(cROOTPAT2+vARQEXE[xa],cPARGRAF+vARQEXE[xa])
   ElseIf file(cSTARPATH+vARQEXE[xa])
      __copyfile(cSTARPATH+vARQEXE[xa],cPARGRAF+vARQEXE[xa])
   ElseIf file(cDIREXETH+vARQEXE[xa])
      __copyfile(cDIREXETH+vARQEXE[xa],cPARGRAF+vARQEXE[xa])
   Else
      MsgInfo(STR0103+vARQEXE[xa]+" "+STR0104+chr(13)+chr(13);
          +STR0105+chr(13)+STR0106,STR0002)
      Return {.F.,Space(10)}
   EndIf
Next xa

aEXEATRIA := Directory(cPARGRAF+vARQEXE[1])
If Len(aEXEATRIA) > 0
   dTEXETA := aEXEATRIA[1,3]
   If dTEXEST < dTEXETA
      fErase(cPARGRAF+vARQEXE[1])
      __copyfile(cDIREXE+vARQEXE[1],cPARGRAF+vARQEXE[1])
   EndIf
EndIf

__copyfile(cARQUIV1,cPARGRAF+cARQUIV1)
__copyfile(cARQUIV2,cPARGRAF+cARQUIV2)
__copyfile(cARQUIV3,cPARGRAF+cARQUIV3)

Return vRETGRVAL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NgRestMemoryºAutor  ³Taina A. Cardoso    º Data ³  15/03/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o conteudo dos campos da memoria da tabela.        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ aArray-> Array com o conteudo da memoria da tabela         ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NgRestMemory(aArray)

Local nField

For nField := 1 to Len(aArray)
	&(aArray[nField,1]) := aArray[nField,2]
Next nField

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NGGetMemoryºAutor  ³Taina A. Cardoso    º Data ³  15/03/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Guarda em um array os campos da memoria da tabela.         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ cAlias-> Alias da tabela                                   ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGGetMemory(cAlias)

	Local aArea    := GetArea()
	Local aMemory  := {}
	Local aHeadAli := {}
	Local cFunType := "Type"
	Local nTamTot  := 0
	Local nInd     := 0

	aHeadAli := NGHeader(cAlias)
	nTamTot := Len(aHeadAli)

	For nInd := 1 To nTamTot
		If &cFunType.("M->"+Trim(aHeadAli[nInd,2])) <> "U"
			aAdd(aMemory,{"M->"+Trim(aHeadAli[nInd,2]),&("M->"+Trim(aHeadAli[nInd,2]))})
		EndIf
	Next nInd

	RestArea(aArea)

Return aMemory

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGRODAIMP   ³ Autor ³ Inacio Luiz Kolling   ³ Data ³21/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Roda impressão do relatório                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nCntlV  - nCntImpr                               - Obrigatorio³±±
±±³          ³ cRodaTV - cRodaTXT                               - Obrigatório³±±
±±³          ³ TamV    - Tamanho                                - Obrigatório³±±
±±³          ³ wnrelV  - Nome do relatório                      - Obrigatório³±±
±±³          ³ vRetI   - Alias para refazer os índices          - Obrigatório³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Relatórios                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Functio NGRODAIMP(nCntIV,cRodaTV,TamV,wnrelV,vRetI)
Local nFl := 0
Roda(nCntIV,cRodaTV,TamV)
For nFl := 1 To Len(vRetI)
   RetIndex(vRetI[nFl])
Next nFl
Set Filter To
Set device to Screen
If aReturn[5] = 1
   Set Printer To
   dbCommitAll()
   OurSpool(wnrelV)
EndIf
MS_FLUSH()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGCANCELAIMP³ Autor ³ Inacio Luiz Kolling   ³ Data ³16/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cancelamento da impressão do relatório                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nLast  - Tecla precionada                        - Obrigatorio³±±
±±³          ³ cAliasV - Alias de retorno                       - Obrigatório³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³ .T.,.F.                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGCANCELAIMP(nLasT,cAliasV)
If nLast = 27
   Set Filter To
   dbSelectArea(cAliasV)
EndIf
Return If(nLast = 27,.T.,.F.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGEXISTCHAV³ Autor ³In cio Luiz Kolling    ³ Data ³27/02/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consistencia de chave                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cvAli - Alias do arquivo/tabela                 - Obrigatorio³±±
±±³          ³cvCha - Chave de acesso                         - Obrigatorio³±±
±±³          ³nvInd - Indice de acesso                        - Obrigatorio³±±
±±³          ³cvFil - Filial de acesso                        - Nao Obrig. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³.T. - Achou , .F. - Nao achou                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³OBSERVACAO³Usar esta funcao com a indicacao do(S) campo(s) (INDICE )    ³±±
±±³          ³configurados como chave primaria de gravacao (INCLUSAO).     ³±±
±±³          ³                                                             ³±±
±±³          ³Para outros fins manter os criterios de sua funcionalidade.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGEXISTCHAV(cvAli,cvCha,nvInd,cvFil)
Local lRetCv := .T., cFilcH := NGTROCAFILI(cvAli,cvFil),aAreaCH := GetArea()
If Type("INCLUI") = 'U'
   INCLUI := .T.  // Considera que e uma inclusao e chave de gravacao
EndIf
If INCLUI
   vRetCv := NGEXISTEREG(cvAli,cvCha,nvInd,.F.,cFilcH)
   If vRetCv[1] = .T.
      HELP(" ",1,"JAGRAVADO",,STR0127+" ->"+" "+cvAli+Space(5)+STR0128+" ->"+" "+Str(nvInd,2)+;
                              CRLF+STR0129+CRLF+cvCha,3)
      lRetCv := .F.
   EndIf
EndIf
RestArea(aAreaCH)
Return lRetCv



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGSEEKCPO ³ Autor ³Inacio Luiz Kolling   ³ Data ³28/11/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consistencia da existencia do registro pela chave primaria  ³±±
±±³          ³Ou uma outra chave                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cVALIAS - Alias do arquivo                    - Obrigatorio ³±±
±±³          ³cVCHAV  - Chave de acesso                     - Obrigatorio ³±±
±±³          ³nIndAc  - Indice de acesso                    - Nao Obrigat.³±±
±±³          ³cFilTr  - Filial                              - Nao Obrigat.³±±
±±³          ³lSaidT  - Saida via tela                      - Nao Obrigat.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³OBSERVACAO³Funcao funcional.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGSEEKCPO(cVALIAS,cVCHAV,nVIndAc,cFilTr,lSaidT)
Local aAreaSe := GetArea()
Local cFilArq := xFilial(cVALIAS)
Local vINDSIX := {}, XN := 0,nIndAc := 0
Local lSViaTe := If(lSaidT = Nil,.T.,lSaidT),lProInd := .F.
Local lVeioIn := If(nVIndAc <> Nil,.T.,.F.) ,lRETCPO := .T.
Local cIndAc  := If(nVIndAc <> Nil,Alltrim(STR(nVIndAc,10)),' ')

If lVeioIn
   For XN := 49 To 57
      aAdd(vINDSIX,chr(XN))
   Next XN
   For XN := 65 To 90
      aAdd(vINDSIX,chr(XN))
   Next XN

   lProInd := If(nVIndAc > Len(vINDSIX),.T.,.F.)
   If !lProInd
      cIndAc := vINDSIX[nVIndAc]
      dbSelectArea("SIX")
      dbSetOrder(1)
      If !dbSeek(cVALIAS+cIndAc)
         If lSViaTe
            lProInd := .T.
         EndIf
      EndIf
   EndIf

   If lProInd
      MsgInfo(STR0128+" "+STR0104+". ( SIX -> "+cVALIAS+"  "+STR0128+" "+cIndAc+" )";
              +chr(13)+chr(13)+STR0130+" NGSEEKCPO .",STR0002)
      lRETCPO := .F.
   EndIf

   nIndAc := nVIndAc
Else
   nIndAc := 1
EndIf

If lRETCPO
   cFilArq := NGTROCAFILI(cVALIAS,cFilTr)
   dbSelectArea(cVALIAS)
   dbSetOrder(nIndAc)
   If !dbSeek(cFilArq+cVCHAV)
      If lSViaTe
         HELP(" ",1,"REGNOIS")
      EndIf
      lRETCPO := .F.
   EndIf
EndIf
RestArea(aAreaSe)
Return lRETCPO

//-------------------------------------------------------------------
/*/{Protheus.doc} NGFUNCRH
Consistencia do funcionario demitido qdo ha integracao RH

@type Function
@author Inacio Luiz Kolling
@since 05/05/2006
@param cCodFunc , Character, Codigo do funcionário
@param lMenTela , Logical  , Indica se a saida por via tela
@param dDtFim   , Date     , Data Fim Insumo, para checar disp.
@param lValidaRH, Logical  , Indica se valida o Funcionário com a tabela de RH
@param lRetArray, Logical  , Indica se o retorno será array ou lógico

@return lRetor , Logical  , Indica se o funcionário está disponível ou não.
/*/
//-------------------------------------------------------------------
Function NGFUNCRH( cCodFunV, lMenTela, dDtFIM, lValidaRH, lRetArray )

	Local aAreaAtua := GetArea(),lRetor := .T.,lDtDem
	Local aRet      := {}
	Local cDESCSX5  := Space(TAMSX3("X5_DESCRI")[1])
	Local cCodFunRH := SubStr(cCodFunV,1,Len(ST1->T1_CODFUNC))
	Local cNgMntRh  := AllTrim(GetMv("MV_NGMNTRH"))

	Default lValidaRH := .T.
	Default lMenTela  := .F.
	Default lRetArray := .F.

	//Ponto de entrada para fazer validação específica do funcionário
	If ExistBlock("NGUTILVF")
		lRetor := ExecBlock("NGUTILVF",.F.,.F.,{cCodFunV,lMenTela,dDtFIM,lValidaRH})
		If ValType(lRetor) == "L"
			Return lRetor
		EndIf
	EndIf

	dbSelectArea("ST1")
	dbSetOrder(01)
	If dbSeek(xFilial("ST1")+cCodFunRH)

		If cNgMntRh $ "SX"
			dbSelectArea("SRA")
			dbSetOrder(01)
			If dbSeek(xFilial("SRA")+cCodFunRH)
				lDtDem := If(dDtFIM == Nil,.T.,.F.)
				If !lDtDem //Se for informada a data fim do insumo, será verificado se a demissão foi antes desta data
					If SRA->RA_DEMISSA < dDtFIM
						lDtDem := .T.
					EndIf
				EndIf
				If SRA->RA_SITFOLH == "D" .And. lDtDem .And. lValidaRH
					dbSelectArea("SX5")
					dbSetOrder(01)
					If dbSeek(xFilial("SX5")+"31"+SRA->RA_SITFOLH)
						cDESCSX5 := AllTrim(X5Descri())
					EndIf
					If lMenTela
						Help(" ",1,STR0002,,STR0131+Chr(13)+STR0132+Chr(13)+cDESCSX5,4,5)
					Else
						aRet := {.F.,STR0131+Chr(13)+STR0132+Chr(13)+cDESCSX5}
					EndIf
					lRetor := .F.
				EndIf
			Else
				If cNgMntRh == "S"
					If lMenTela
						Help(" ",1,STR0002,,STR0133,4,5)
					Else
						aRet := {.F.,STR0133}
					EndIf
					lRetor := .F.
				EndIf
			EndIf
		EndIf

		//Checa campo T1_DTFIMDI de fim da disponibilidade
		If lRetor .And. NGCADICBASE("T1_DTFIMDI","A","ST1",.F.) .And. dDtFIM <> Nil
			If !Empty(ST1->T1_DTFIMDI) .And. ST1->T1_DTFIMDI < dDtFIM
				If lMenTela
					Help(" ",1,STR0002,,STR0133,4,5)
				Else
					aRet := {.F.,STR0133}
				EndIf
				lRetor := .F.
			EndIf
		EndIf

		If lRetor .And. st1->t1_disponi = "N" .And. dDtFIM == Nil
			If lMenTela
				Help(" ",1,STR0002,,STR0133,4,5)
			Else
				aRet := {.F.,STR0133}
			EndIf
			lRetor := .F.
		EndIf
	Else
		If lMenTela
			HELP(" ",1,"REGNOIS")
		Else
			aRet := {.F.,"Não existe registro relacionado a este código."}
		EndIf
		lRetor := .F.
	EndIf

	RestArea(aAreaAtua)

Return IIf( lRetArray, aRet, lRetor )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGCPFCGC   ³ Autor ³Inacio Luiz Kolling    ³ Data ³28/08/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consistencia do C.P.F. ou C.G.C.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cCPFCGC - Codigo do C.P.F. ou C.G.C.           - Obrigatorio ³±±
±±³          ³cRefere - Consistir C.P.F. ou C.G.C. (F,J)     - Nao Obrigat.³±±
±±³          ³          Onde "F" - C.P.F. (Pessoa Fisica)                  ³±±
±±³          ³               "J" - C.G.C. (Pessoa Juridica)                ³±±
±±³          ³          OBS Nao informado assume "F" (Pessoa Fisica)       ³±±
±±³          ³                                                             ³±±
±±³          ³lMostM - Indica saida via tela                 - Nao Obrigat.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³lRCPFCGC ou vVRCPFCGC  Se lMostM = .T. Retorna .T. / .F.     ³±±
±±³          ³                       Se lMostM = .F. Retorna vVRCPFCGC     ³±±
±±³          ³                           Onde vVRCPFCGC[1] = .T. / .F.     ³±±
±±³          ³                                vVRCPFCGC[2] = Mensagem      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGCPFCGC(cCPFCGC,cRefere,lMostM)
Local lReturn  := .T.
Local lMTela   := If(lMostM = Nil,.F.,lMostM),lRCPFCGC := .F.
Local cMenCPCG := Space(1), vVRCPFCGC := {.T.,Space(40)}
Local cRefAux  := If(cRefere = Nil,"F",cRefere)
Local nConI,Ic,Jc,nSoma,nDigt,cCPF := "",cDvc := "",cDig := ""
Local cLocal   := SuperGetMV("MV_PAISLOC",.F.,"NLL")

If AllTrim(cLocal) == 'BRA' // Valida o local de uso do sistema para validar corretamente o documento

	If cRefAux = "F"
	If Len(cCPFCGC) < 11 .Or. Len(cCPFCGC) > 11
		cMenCPCG := STR0134
	EndIf
	Else
	If Len(cCPFCGC) < 14 .Or. Len(cCPFCGC) > 14
		cMenCPCG := STR0135
	EndIf
	EndIf

	If Empty(cMenCPCG)
	cDvc    := SubStr(cCPFCGC,13,02)
	cCPFCGC := SubStr(cCPFCGC,01,12)

	If cRefAux = "F"
		cDvc := SubStr(cCPFCGC,10,2)
		cCPF := SubStr(cCPFCGC,01,9)
		cDig := ""

		For Jc := 10 to 11
			nConI := Jc
			nSoma := 0
			For Ic:= 1 to len(trim(cCPF))
				nSoma += (Val(SubStr(cCPF,Ic,1)) * nConI)
				nConI--
			Next Ic
			nDigt := If((nSoma % 11) < 2,0,11 - (nSoma % 11))
			cCPF  := cCPF + Str(nDigt,1)
			cDig  := cDig + Str(nDigt,1)
		Next Jc

		lRCPFCGC := cDig == cDvc
		If !lRCPFCGC
			cMenCPCG := STR0134
		EndIf
	Else
		For Jc := 12 to 13
			nConI := 1
			nSoma := 0
			For Ic := Jc to 1 Step -1
				nConI++
				If nConI > 9
				nConI := 2
				EndIf
				nSoma += (val(substr(cCPFCGC,Ic,1)) * nConI)
			Next Ic
			nDigt   := If((nSoma % 11) < 2,0,11 - (nSoma % 11))
			cCPFCGC := cCPFCGC + Str(nDigt,1)
			cDig    := cDig + Str(nDigt,1)
		Next Jc

		lRCPFCGC := cDig == cDvc
		If !lRCPFCGC
			cMenCPCG := STR0135
		EndIf
	EndIf
	EndIf

	If lMTela
	If !Empty(cMenCPCG)
		MsgInfo(cMenCPCG,STR0037)
		lRCPFCGC := .F.
	EndIf
	Else
	If !Empty(cMenCPCG)
		vVRCPFCGC[1] := .F.
		vVRCPFCGC[2] := cMenCPCG
	EndIf
	EndIf
	
	lReturn := If(lMTela,lRCPFCGC,vVRCPFCGC)
	
EndIf

Return lReturn





/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGALINVARP³ Autor ³ Inacio Luiz Kolling  ³ Data ³10/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Posiciona em um determidado registro e alimenta variaveis  ³±±
±±³          ³                                                 (Privatas) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cALIAS   - Alias do arquivo/tabela a ser acessada          ³±±
±±³          ³ cKEY     - Chave de acesso                                 ³±±
±±³          ³ nORD     - Ordem de acesso                                 ³±±
±±³          ³ aARVAR   - Array com as variaveis de retorna e dados       ³±±
±±³          ³ cFilTroc - Filial                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Exemplo de³ NGALINVARP("ST1",cCodF,1,{{"cNomFu","T1_NOME"},;           ³±±
±±³chamada   ³                           {"cCodCc","T1_CCUSTO"},;         ³±±
±±³          ³                           {"cCodTu","T1_TURNO"}})          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGALINVARP(cALIAS,cKEY,nORD,aARVAR,cFilTroc)
Local aAreaAV := GetArea(),nx := 0
Local cFilArq := NGTROCAFILI(cALIAS,cFilTroc)
dbSelectArea(cALIAS)
dbSetOrder(nORD)
If dbSeek(cFilArq+cKey)
   For nx := 1 To Len(aARVAR)
      If ValType(aArvar[nx,1]) <> 'U'
         If FieldPos(aARVAR[nx,2]) > 0
            &(aArvar[nx,1]) := &(&("'"+cALIAS+"->"+aARVAR[nx,2]+"'"))
         EndIf
      EndIf
   Next nx
   lREFRESH := .T.
EndIf
RestArea(aAreaAV)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGDELETAREG³ Autor ³Inacio Luiz Kolling   ³ Data ³04/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Deleta um determinado registro                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cVAlias - Alias do arquivo                    - Obrigatorio ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³OBSERVACAO³Funcional e devera estar sobre o registro a ser deletado    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGDELETAREG(cVAlias)
RecLock(cVAlias,.F.)
DBDelete()
(cVAlias)->(MsUnLock())
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGDELETAWRE³ Autor ³Inacio Luiz Kolling   ³ Data ³04/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Deleta o(s) registro(s) de um arquivo/tabela conforme condi-³±±
±±³          ³cao                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cVAlias - Alias do arquivo                    - Obrigatorio ³±±
±±³          ³cWondS  - Condicao While                      - Obrigatorio ³±±
±±³          ³cWondV  - Condicao a comparar = Chave S/filial- Obrigatorio ³±±
±±³          ³cIndic  - Indice de acesso                    - Obrigatorio ³±±
±±³          ³cIndIf  - Condicao no While                   - Nao Obrigat.³±±
±±³          ³cFilV   - Filial                              - Nao Obrigat.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³OBSERVACAO³Funcional                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Exemplo   ³CWondS := "'STJ->TJ_ORDEM'"       // "'STJ->TJ_PLANO'"      ³±±
±±³          ³CWondV := '000391'                // '000001'               ³±±
±±³          ³nIndic := 1                       // 3                      ³±±
±±³          ³CondIf := 'STJ->TJ_SITUACA = "C"' // 'STJ->TJ_SITUACA = "C"'³±±
±±³          ³                                                            ³±±
±±³          ³NGDELARQ('STJ',CWondS,CWondV,nIndic,CondIf)                 ³±±
±±³          ³                                                            ³±±
±±³          ³NGDELARQ('STJ',CWondS,CWondV,nIndic)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGDELETAWRE(cVAlias,cWondS,cWondV,nIndic,condIf,cFilV)
Local cFilDe := NGTROCAFILI(cVAlias,cFilV), aAreaWre := GetArea()
Local nPos_  := At('_',cWondS), nPosM  := At('>',cWondS)
Local cPref  := SubStr(cWondS,nPosM+1,(nPos_-1)-nPosM)
Local cFilW  := '"'+cVALIAS+'->'+cPref+'_FILIAL"'

dbSelectArea(cVAlias)
dbSetOrder(nIndic)
If dbSeek(cFilDe+cWondV)
   While !EoF() .And. (&(&(cFilW)) = cFilDe) .And. (&(cWondS) = cWondV)
     If CondIf <> Nil
        If &CondIf
           NGDELETAREG(cVAlias)
        EndIf
     Else
        NGDELETAREG(cVAlias)
     EndIf
     dbSkip(1)
   End
EndIf
RestArea(aAreaWre)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGEXISTEREG³ Autor ³Inacio Luiz Kolling   ³ Data ³04/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se existe um determinado registro                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cVAlias - Alias do arquivo                    - Obrigatorio ³±±
±±³          ³cVChave - Chave de acesso (Sem a filial)      - Obrigatorio ³±±
±±³          ³nIndice - Indice                              - Obrigatorio ³±±
±±³          ³lSaiTel - Indica se mostra mensagem           - Obrigatorio ³±±
±±³          ³cFilAce - Filial                              - Nao Obrigat.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³OBSERVACAO³Funcao funcional.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGEXISTEREG(cVAlias, cVChave, nIndice, lSaiTel, cFilAce)

	Local aAreaTemF	:= GetArea()
	Local aVetRef		:= {.T., ' '}

	Local cMenSi, cFilArq := NGTrocaFili(cVAlias, cFilAce)

	Local lRetFu	:= .T.
	Local lMosTel := IIf( lSaiTel == Nil, .T., lSaiTel )

	dbSelectArea(cVALIAS)
	dbSetOrder(nIndice)
	If !MsSeek(cFilArq + cVChave)

		cMenSi := STR0136 + Chr(13) + Chr(13) +;
					STR0127 + "...: " + cVAlias + Chr(13) +;
					STR0137 + "..: " + cVChave + Chr(13) +;
					STR0128 + "..: " + Str(nIndice, 2) + Chr(13) +;
					STR0138 + "....: " + cFilArq

		If lMosTel
			MsgInfo(cMenSi, STR0002)
			lRetFu := .F.
		Else
			aVetRef := {.F., cMenSi}
		EndIf
	EndIf

	RestArea(aAreaTemF)

Return IIf(lMosTel, lRetFu, aVetRef)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄ¿±±
±±³Funcao    ³NGCONTEMCAR³ Autor ³In cio Luiz Kolling ³ Data ³08/05/2008³09:30³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄ´±±
±±³Descricao ³Verifica se um conteudo esta contido em uma string e/ou tamb‚m  ³±±
±±³          ³em que posicao inicial                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cConteu - Conteudo a ser pesquisado               - Obrigatorio ³±±
±±³          ³cString - String                                  - Obrigatorio ³±±
±±³          ³lPosica - Indica se retorna a posicao inicial na String         ³±±
±±³          ³                                                  - Nao Obrigat.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Exemplos  ³If NGCONTEMCAR("AB","TESTE AB").. If NGCONTEMCAR(cV,cS,.F.) ... ³±±
±±³          ³If NGCONTEMCAR("AB","TESTE AB",.T.) > 0                         ³±±
±±³          ³   ....                                                         ³±±
±±³          ³nRet := NGCONTEMCAR("AB","TESTE AB DA",t.)                      ³±±
±±³          ³If nRet > 0                                                     ³±±
±±³          ³   ....                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³Se lPosica = Nil ou .F. -> .T.,.F. Senao -> 0 ou > 0            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGCONTEMCAR(cConte,cString,lPosica)

	Local lPosic := If(lPosica = Nil,.F.,lPosica),nPosic := 0

	If lPosic
		nPosic := AT(cConte,cString)
		Return nPosic
	Else
		Return If(cConte $ cString,.T.,.F.)
	EndIf

//----------------------------------------------------------------------------------
/*/{Protheus.doc} NGTRAVAROT
Travamento da rotina para acesso unico de um usuário.
@type function

@author Inacio Luiz Kolling
@since 24/10/2010

@sample NGTRAVAROT( 'NG420GRAVA' )

@param 	cFuncao, Caracter, Função que será bloqueada pelo semáforo.
@return lReturn, Lógico	 , Valor que garante que o processo foi realizado com exito.
/*/
//----------------------------------------------------------------------------------
Function NGTRAVAROT( cFuncao )

	Local nTentativas := 0
	Local lReturn     := .T.

	If NGFUNCRPO( cFuncao )

		//Trava função para que apenas um usuário possa utilizar.
		Do While !LockByName( cFuncao + cEmpAnt, .T., .T., .T. ) .And. nTentativas <= 50
			nTentativas++
			Sleep( 5000 )
		EndDo

		//Após 50 tentativas o processo será abortado.
		If nTentativas >= 50
			MsgInfo( STR0139 + Space( 1 ) + cFuncao + Space( 1 ) + STR0140, STR0037 ) //O acesso a rotina xxx está bloqueado, pois outro usuário está utilizando. Aguarde!
			lReturn := .F.
		EndIf

	EndIf

Return lReturn

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGDETRAVAROT³ Autor ³ Inacio Luiz Kolling   ³ Data ³24/10/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Destravamento da rotina para acesso unico de um usuario       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cFuncao - Nome da funcao                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGDETRAVAROT(cFuncao)
If NGFUNCRPO(cFuncao)
   UnLockByName(cFuncao+cEmpAnt,.T.,.T.,.T.)
EndIf
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGTGRUPSX1  ³ Autor ³ Inacio Luiz Kolling   ³ Data ³23/06/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a variavel + o tamanho do grupo de pergunta           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPergX1 - Conteudo da pergunta (X1_GRUPO)        - Obrigatorio³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³ cPergEx - Conteudo exato do grupo (X1_GRUPO)                  ³±±
±±³          ³            OBS: Na duvida testar o retorno, Se for vazio ha   ³±±
±±³          ³                 problema na passagem do parametro (TAMANHO)   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGTGRUPSX1(cPergX1)

	Local cPergEx  := Space(Len(Posicione("SX1", 1, cPergX1, "X1_GRUPO")))
	Local cPergRet := cPergX1

	If Len(cPergX1) < Len(cPergEx)
		cPergRet := PadR( cPergX1, Len(cPergEx) )
	EndIf

Return cPergRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGINICIAVAR³ Autor ³ Inacio Luiz Kolling   ³ Data ³21/05/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inicializa uma variavel   pelo SX3 ou pela base de dados     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cVar   - Nome da variavel (Campo)              - Obrigatorio ³±±
±±³          ³lSX3   - Campo do SX3                          - Nao Obrig.  ³±±
±±³          ³cAliaI - Campo da base                         - Nao Obrig.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³OBSERVACAO³lSX3 - Vazio inicializa em relacao a base de dados           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³cContV - Conteudo inicializado                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGINICIAVAR(cVar,lSX3,cAliaI)
Local cContV,cTipV := Space(1),nTamV := 0,nDecV := 0,lPSX3 := If(lSX3 = Nil,.T.,lSX3)
If lPSX3
   If NGIfDICIONA("SX3",cVar,2)
      cTipV := Posicione("SX3",2,cVar,"X3_TIPO")
      nTamV := Posicione("SX3",2,cVar,"X3_TAMANHO")
      nDecV := Posicione("SX3",2,cVar,"X3_DECIMAL")
   EndIf
Else
   dbSelectArea(cAliaI)
   aEstru := dbStruct()
   nPosEs := Ascan(aEstru,{|x| x[1] == cVar})
   If nPosEs > 0
      cTipV := aEstru[nPosEs,2]
      nTamV := aEstru[nPosEs,3]
      nDecV := aEstru[nPosEs,4]
   EndIf
EndIf
If !Empty(cTipV)
   If  cTipV $ "CM"
      cContV := Space(nTamV)
   ElseIf cTipV = "N"
      cContV := If(nDecv = 0,0,0.00)
   ElseIf cTipV = "D"
      cContV := Ctod("  /  /  ")
   ElseIf cTipV = "L"
      cContV := .F.
   EndIf
EndIf
Return cContV
//---------------------------------------------------------------------
/*/{Protheus.doc} NGIntMULog

@param cMensagem
@param cOperacao
@param cXml
@author Felipe Nathan Welter
@author Vitor Emanuel Batista
@since 14/11/2012
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Function NGIntMULog(cMensagem,cOperacao,cXml)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGRETAUMVPA³ Autor ³In cio Luiz Kolling   ³ Data ³16/10/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Restaura as variaveis (MV_PAR..)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³vVetR - Vetor com o conteudo dos MV_PAR        - Obrigatorio³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³OBSERVACAO³Usar esta funcao em conjunto com a funcao NGSALVAMVPA       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGRETAUMVPA(vVetR)
Local nF := 0
For nF := 1 To 59
   If ValType(vVetR[nF]) = "C"
      &("MV_PAR"+StrZero(nF,2)) := Space(Len(vVetR[nF]))
   ElseIf ValType(vVetR[nF]) = "N"
      &("MV_PAR"+StrZero(nF,2)) := 0
   ElseIf ValType(vVetR[nF]) = "D"
      &("MV_PAR"+StrZero(nF,2)) := Ctod('  /  /  ')
   EndIf
   &("MV_PAR"+StrZero(nF,2)) := vVetR[nF]
Next nF
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGSALVAMVPA³ Autor ³In cio Luiz Kolling   ³ Data ³16/10/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Salva o conteudo das variaveis (MV_PAR..)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGSALVAMVPA()
Local vVetMvPar := {},nF := 0
For nF := 1 To 59
   aAdd(vVetMvPar,&("MV_PAR"+StrZero(nF,2)))
Next nF
Return vVetMvPar

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGCABECEMP ³ Autor ³In cio Luiz Kolling   ³ Data ³28/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Impressao grafica do cabecalho do relatorio                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³No bloco de codigo da funcao chamada pela passagem como pa- ³±±
±±³          ³rametro na funcao NGIMPRGRAFI  (bProcesso)                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGCABECEMP()
Local cDetCab := "",nEspaco := 0,nFc := 0,cStartPath := GetSrvProfString("Startpath","")

Li += 40
If Li >= nLinMax
   oPrint:EndPage()    // Finaliza a pagina
   oPrint:StartPage()  // Inicia uma nova pagina
   Li := 0
   //-- Carrega Logotipo para impressao
   cLogo := cStartPath + "LGRL"+SM0->M0_CODIGO+SM0->M0_CODFIL+".BMP"   // Empresa+Filial //NGLOCLOGO() - substituir por isso//
   If !File( cLogo )
      cLogo := cStartPath + "LGRL"+SM0->M0_CODIGO+".BMP"              // Empresa
   EndIf
   Li += 20
   // Nome da Empresa / Pagina  / Logotipo
   oPrint:Line(li,30,li,nColMax)
   If File(cLogo)
      li += 50
      oPrint:SayBitmap(li,30, cLogo,400,090)
   EndIf
   cDetCab := RptFolha +" " + TRANSFORM(m_pag,'999999')
   li      += 75
   oPrint:say(li,nColMax-300,cDetCab,oCouNew10)

   // Versão
   cDetCab := "SIGA /"+cNomPro+"/v."+cVersao+"  "
   li      += 50
   oPrint:say(li ,30 ,cDetCab,oCouNew10)

   //-- Titulo
   cDetCab := If(lLandScape,Trim(cTitulo),Left(Trim(cTitulo),48))
   nEspaco := (nColMax - Len(AllTrim(cTitulo)) *100 / 6 ) / 2
   oPrint:say(li,nEspaco,cDetCab,oArial12N)

   cDetCab := RptDtRef +" "+ DTOC(dDataBase)
   oPrint:say(li,nColMax-300,cDetCab,oCouNew10)

   // Hora da emissão / Data Emissao
   cDetCab := RptHora+" "+time()
   li      += 50
   oPrint:say(li,30,cDetCab,oCouNew10)

   cDetCab := RptEmiss+" "+DToC(MsDate())
   oPrint:say(li,nColMax-300,cDetCab,oCouNew10)
   li += 50
   oPrint:Line(li,50,li,nColMax)
   oPrint:Box(li,30,nLinMax+50,nColMax)

   If Valtype(cCabec1) = 'A'
      If Len(cCabec1) > 0
         If Valtype(cCabec1) = 'A'
            For nFC := 1 To Len(cCabec1)
               nColP := cCabec1[nFC,2]
               cDesC := cCabec1[nFC,1]
               oPrint:say(Li,nColP,cDesC,oCouNew10N)
            Next nFC
            If Valtype(cCabec2) = 'A'
               If Len(cCabec2) > 0
                  Li += 50
                  oPrint:say(Li,50,cCabec2[nFC,2],cCabec2[nFC,2],oCouNew10N)
               EndIf
            EndIf
         EndIf
      EndIf
      Li += 50
      oPrint:Line(Li,50-20,Li,nColMax)
   Else
      If Len(Trim(cCabec1)) > 0
         oPrint:say(Li,50,cCabec1,oCouNew10N)
         If Len(Trim(cCabec2)) != 0
            Li += 50
            oPrint:say(Li,50,cCabec2,oCouNew10N)
         EndIf
         Li += 50
         oPrint:Line(Li,50-20,Li,nColMax)
      EndIf
   EndIf
   m_pag++
EndIf
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGIMPRGRAFI³ Autor ³In cio Luiz Kolling   ³ Data ³28/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Impressao grafica                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³bProcesso - Bloco de codigo (funcao)          - Obrigatorio ³±±
±±³          ³lPaisgem  - Tipo do relatorio                 - Nao Obrigat.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGIMPRGRAFI(bProcesso,lPaisagem)
Private lLandScape := If(lPaisagem = Nil,.F.,lPaisagem)
Private nLinMax    := 0, nColMax := 0,Li := 4000,m_pag := 1
Private oCouNew07  := TFont():New("Courier New",07,07,,.F.,,,,.T.,.F.) //-- Modo Normal
Private oCouNew07N := TFont():New("Courier New",07,07,,.T.,,,,.T.,.F.) //-- Modo Negrito(5o parametro New() )
Private oCouNew08  := TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)
Private oCouNew08N := TFont():New("Courier New",08,08,,.T.,,,,.T.,.F.)
Private oCouNew10  := TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
Private oCouNew10N := TFont():New("Courier New",10,10,,.T.,,,,.T.,.F.)
Private oCouNew12  := TFont():New("Courier New",12,12,,.F.,,,,.T.,.F.)
Private oCouNew12N := TFont():New("Courier New",12,12,,.T.,,,,.T.,.F.)
Private oCouNew15  := TFont():New("Courier New",15,15,,.F.,,,,.T.,.F.)
Private oCouNew15N := TFont():New("Courier New",15,15,,.T.,,,,.T.,.F.)
Private oCouNew21  := TFont():New("Courier New",21,21,,.F.,,,,.T.,.T.)
Private oCouNew21N := TFont():New("Courier New",21,21,,.T.,,,,.T.,.T.)
Private oArial08   := TFont():New("Arial"      ,08,08,,.F.,,,,.T.,.F.)
Private oArial08N  := TFont():New("Arial"      ,08,08,,.T.,,,,.T.,.F.)
Private oArial12   := TFont():New("Arial"      ,12,12,,.F.,,,,.T.,.F.)
Private oArial12N  := TFont():New("Arial"      ,12,12,,.T.,,,,.T.,.F.)
Private oArial16   := TFont():New("Arial"      ,16,16,,.F.,,,,.T.,.F.)
Private oArial16N  := TFont():New("Arial"      ,16,16,,.T.,,,,.T.,.F.)

_SetOwnerPrvt("oPrint",)

//-- Objeto para Impressao grafica
oPrint := TMSPrinter():New(cTitulo)

If lLandScape
   oPrint:SetLandScape() //Modo paisagem
Else
   oPrint:SetPortrait()  //Modo retrato
EndIf

nLinMax := If(lLandScape,2300,3100)
nColMax := If(lLandScape,3285,2350)

If bProcesso != NIL
   eval(bProcesso)
   oPrint:EndPage()  // Finaliza a pagina
   oPrint:Preview()  // Visualiza antes de imprimir
EndIf
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGPICTESP   ³ Autor ³In cio Luiz Kolling   ³ Data ³20/04/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna a Picture conforme campo da estrutura (Base de Dados)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nCamp - Indicador do campo                     - Obrigatorio ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³NGVISUESP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGPICTESP(nCamp)
Local cPicR := "@!",cDeci,cInte,cPicI,cPicF,nCont,YX
If aEstr[nCamp,2] = "N"
   cPicR := Replicate("9",aEstr[nCamp,3])
   If aEstr[nCamp,4] <> 0
      cDeci := "."+Replicate("9",aEstr[nCamp,4])
      cInte := Replicate("9",aEstr[nCamp,3]-(aEstr[nCamp,4]+1))
      cPicI := ""
      cPicF := ""
      nCont := 0
      For YX := Len(cInte) to 1 Step -1
        cPicI += SubStr(cInte,YX,1)
        nCont ++
        If nCont = 3
           If YX <> 1
              cPicF += ","+cPicI
           Else
              cPicF := cPicI+cPicF
           EndIf
           nCont := 0
           cPicI := ""
        EndIf
      Next YX
      If !Empty(cPicI)
         cPicF := cPicI+cPicF
      EndIf
      cPicR  := '@E '+cPicF+cDeci
   EndIf
ElseIf aEstr[nCamp,2] = "D"
   cPicR := "99/99/99"
EndIf
Return cPicR

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGVISUESP   ³ Autor ³In cio Luiz Kolling   ³ Data ³17/04/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Visualizacao com base na estrutura do arquivo (Base de Dados)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cValias - Alias do arquivo                 - Nao Obrigatorio ³±±
±±³          ³cChav   - Chave de acesso                  - Nao Obrigatorio ³±±
±±³          ³nInd    - Indice de acesso                 - Nao Obrigatorio ³±±
±±³          ³cTit    - Titulo da janela                 - Nao Obrigatorio ³±±
±±³          ³vVCamp  - Vetor com os nome dos campos     - Nao Obrigatorio ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³cValias <> Nil, cChav,nInd                 - Obrigatorios    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Exemplo em³NGSX6PAR.PRX                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGVISUESP(cValias,cChav,nInd,cTit,vVCamp)
Local nOpca := 0,cCampo, nX, nY, cCaption, cPict, cValid, cF3,nIn := 1
Local cWhen, nLargSay, nLargGet, oSay, oGet,oBar,lOk,oScroll
Local cBlkGet,cBlkWhen,cBlkVld,nOpcx := 3,oGets := {},aC := {},aSay := {}
Local XX,YX,XP,nCL,aAreaAt := GetArea(),nCOL := 50,l11 := 10,nIntP := 1
Local cTitA := If(cTit = Nil,STR0144,cTit)+" "+If(cValias = Nil,Alias(),cValias)
Local cPicA,lPula,cTitT,cAliAt := If(cValias = Nil,Alias(),cValias)
Private bSet15,bSet24

cTitT := NGSX2NOME(cAliAt)
cTitT := If(!Empty(cTitT),cTitT,cTitA)
cTitT += " - "+STR0145

If cValias <> Nil
   dbSelectArea(cValias)
   dbSetOrder(nInd)
   dbSeek(cChav)
EndIf

aEstr := dbStruct()
If vVCamp <> Nil .And. Empty(vVCamp[1])
   nIn := 2
EndIf

For xx := nIn to Fcount()
   cPicA := NGPICTESP(xx)
   lPula := .F.
   If nIntP = 1
      nCOL  := 50
      nIntP := 2
   Else
      nCOL := 250+(aEstr[xx,3] * 4)
      If nCOL < 500
         nCOL := 250
         nIntP := 1
         lPula := .T.
      ElseIf nCOL > 500
         nCOL  := 50
         l11 += 13
         nIntP := 2
         nIntP := 1

         If nCOL < 500
            lPula := .T.
            nIntP := 1
         EndIf
      Else
         lPula := .T.
      EndIf
   EndIf

   aAdd(aC,{FieldName(xx),{l11,nCOL},&(FieldName(xx)),cPicA,,,,aEstr[xx,3]*4,CLR_BLUE})
   aAdd(aSay,{l11+2,nCOL-45})

   If nIntP = 2
      If (aEstr[xx,3] * 4)+50 > 200
         lPula := .T.
         nIntP := 1
      EndIf
   EndIf
    If lPula
      l11 += 13
   EndIf
Next xx

DEFINE MSDIALOG odlge TITLE OemToAnsi(cTitT) FROM 0,0 To 450,794 Pixel
   oDlgE:lEscClose := .F.
   oScrollBox := TScrollBox():new(odlge,05,00,221,397,.T.,.T.,.T.)
   For XP := 1 to Len(aC)
      cCampo   := aC[XP,1]
      cCaption := IIf(Empty(aC[XP,3])," ",aC[XP,3])
      cValid   := IIf(Empty(aC[XP,5]),".T.",aC[XP,5])
      cWhen    := IIf(aC[XP,7]==NIL,".T.",IIf(aC[XP,7],".T.",".F."))
      cWhen    := IIf(!(Str(nOpcx,1,0)$"346"),".F.",cWhen)
      cBlkGet  := "{ | u | If( PCount() == 0, "+cCampo+","+cCampo+":= u ) }"
      cBlKVld  := "{|| "+cValid+"}"
      cBlKWhen := "{|| NGWHENESPVI()}"
      oGet     := TGet():New(aC[XP,2,1],aC[XP,2,2],&cBlKGet,oScrollBox,aC[XP,8],,aC[XP,4],&(cBlkVld),,,,.F.,,.T.,,.F.,&(cBlkWhen),.F.,.F.,,.F.,.F.,aC[XP,6],(aC[XP,1]))
      aAdd(oGets,oGet)
   Next XP

   For nCL := nIn To Fcount()
      cCaption := If (vVCamp <> Nil .And. Len(vVCamp) > 0 .And. nCL <= Len(vVCamp),vVCamp[nCL],FieldName(nCL))
      cBlKSay1 := "{|| OemToAnsi('"+cCaption+"')}"
      oSay     := TSay():New(aSay[If(nIn = 2,nCL-1,nCL),1],aSay[If(nIn = 2,nCL-1,nCL),2],&cBlkSay1,oScrollBox,,, .F., .F., .F., .T.,CLR_BLACK,,,, .F., .F., .F., .F., .F. )
      nLargSay := GetTextWidth(0,cCaption) // 2
      cCaption := oSay:cCaption
   Next nCL
Activate Msdialog oDlge Centered On Init EnchoiceBar(oDlge,{||nOpce := 1,oDlge:End()},{||oDlge:End()})
RestArea(aAreaAt)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGRETFUNESP³ Autor ³In cio Luiz Kolling ³ Data ³24/04/2009³09:30³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica os funcionarios que tem a especialidade                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCodEsp - Codigo da especialidade                  - Obrigatorio³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³vArEspR - Vetor com as especialidades                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGRETFUNESP(cCodEsp)
Local aAreaAt := GetArea(),vArEspR := {}
NGIfDBSEEK("ST2",cCodEsp,2)
While !EoF() .And. st2->t2_filial = xFilial("ST2") .And. st2->t2_especia = cCodEsp
   aAdd(vArEspR,st2->t2_codfunc)
   NGDBSELSKIP("ST2")
End
RestArea(aAreaAt)
Return vArEspR

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGFECHATRB ³ Autor ³In cio Luiz Kolling ³ Data ³24/04/2009³09:30³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se tem arquivo para click da direita                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAliTRB  - Alias do arquivo temporario             - Obrigatorio³±±
±±³          ³cArqTRB  - Nome do arquivo temporario              - Nao Obrig. ³±±
±±³          ³lTemFPT  - Tem arquivo memo para cArqTRB           - Nao Obrig. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³Nil                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGFECHATRB(cAliTRB,cArqTRB,lTemFPT)
dbSelectArea(cAliTRB)
USE
If cArqTRB <> Nil
   FErase(cArqTRB+GetDbExtension())
EndIf
If lTemFPt
   ArqTemFPT := cArqTRB + ".FPT"
   If File(ArqTemFPT)
      FErase(ArqTemFPT)
   EndIf
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGIfFILSEEK³ Autor ³In cio Luiz Kolling ³ Data ³22/04/2009³09:30³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se o registro existe (somente pela filial)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias  - Alias do arquivo                        - Obrigatorio ³±±
±±³          ³cChave  - Chave de acesso  (Somente a filial)     - Obrigatorio ³±±
±±³          ³nIndic  - Indice de acesso                        - Obrigatorio ³±±
±±³          ³lMostr  - Indica se mostra mensagem               - Nao Obrigat.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³.T.,.F. - .T. Achou,  .F. Nao achou o registro                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGIfFILSEEK(cAlias,cChave,nIndic,lMostr)
Local lMostT := If(lMostr = Nil,.F.,lMostr),lRetF := .F.

If NGFILNACHAVE(cAlias,nIndic)
   NGDBAREAORDE(cAlias,nIndic)
   lRetF := If(dbSeek(cChave),.T.,.F.)
EndIf

If !lRetF .And. lMostT
   MsgInfo(STR0146+NGFINALLINHA(2)+STR0127+"....: "+cAlias+NGFINALLINHA();
          +STR0129+"...: "+cChave+NGFINALLINHA()+STR0128+"...: "+Str(nIndic,2),;
           STR0002)
EndIf
Return lRetF

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGIfTRBSEEK³ Autor ³In cio Luiz Kolling ³ Data ³22/04/2009³09:30³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se o registro existe (arquivo temporario)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias  - Alias do arquivo                        - Obrigatorio ³±±
±±³          ³cChave  - Chave de acesso                         - Obrigatorio ³±±
±±³          ³nIndic  - Indice de acesso                        - Obrigatorio ³±±
±±³          ³lMostr  - Indica se mostra mensagem               - Nao Obrigat.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³.T.,.F. - .T. Achou,  .F. Nao achou o registro                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico (posiciona e permanece no alias)                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGIfTRBSEEK(cAlias,cChave,nIndic,lMostr)
Local lMostT := If(lMostr = Nil,.F.,lMostr)
NGDBAREAORDE(cAlias,nIndic)
lRetk := If(dbSeek(cChave),.T.,.F.)
If !lRetk .And. lMostT
   MsgInfo(STR0101+NGFINALLINHA(2)+STR0127+"....: "+cAlias+NGFINALLINHA();
          +STR0137+"...: "+cChave+NGFINALLINHA()+STR0128+"...: "+Str(nIndic,2),;
           STR0022)
EndIf
Return lRetk

//--------------------------------------------------------------------------------------------
/*/{Protheus.doc} NGDELSC1PR
Programa de exclusão de itens SC1 e atualização SB2 e SD4.
@type function

@author Inácio Luiz Kolling
@since 02/02/2009

@param cvORDEM , string , Ordem de Serviço.
@param cvITEM  , string , Sufixo da O.P. normalmente 'OS001'.
@param cvPROD  , string , Código do produto.
@param cLocal  , string , Código do almoxarifado.
@param nQtdPr  , numeric, Quantidade
@param lDelSD4 , boolean, Indica se deve deletar registros relacionados da SD4.
@param lUpdSB2 , boolean, Indica se deve atualizar SB2 relacionada.
@param aSeek   , array  , Itens para pesquisa e posicionamento.
							[1] - Chave.
							[2] - Indice.
@param cLoop   , string , Condição para se manter no loop.

@return boolean, Indica se o processo foi executado com sucesso.
/*/
//--------------------------------------------------------------------------------------------
Function NGDELSC1PR( cvORDEM, cvITEM, cvPROD, cLocal, nQtdPr, lDelSD4, lUpdSB2, aSeek, cLoop )

	Local cCODOP1  := cvORDEM+cvITEM,nFs := 0,lEstp := .F.,aEstP := {}
	Local cCODOP2  := cCODOP1+Space(Len(sc1->c1_op)-Len(cCODOP1))
	Local cLocSC1  := If(cLocal = NIL,Space(2),cLocal),nQtDSC1 := 0
	Local cProdD4  := Padr( cvPROD, TamSx3('D4_COD')[1])
	Local cLocD4   := ''
	LocaL lOk      := .T.
	Local lTemSc1  := .F.
	Local lExecSC1 := ( FindFunction( 'MntExecSC1' ) .And. FwIsInCallStack( 'NG420INC' ) )
	Local lDelIt   := !Empty( aSeek )

	Default lDelSD4 := .T.
	Default lUpdSB2 := .F.
	Default aSeek   := { cvORDEM + cvITEM, 4 }
	Default cLoop   := 'SC1->C1_FILIAL == xFilial( "SC1" ) .And. SC1->C1_OP == cCODOP2'

	If NGIfDBSEEK("SG1",cvPROD,1)
		aEstP := NGESTRUPROD(cvPROD)
		lEstp := .T.
		aAdd(aEstP,{" "," ",cvPROD})
	Else
		aAdd(aEstP,{" "," ",cvPROD})
	EndIf

	For nFs := 1 To Len(aEstP)

		cvProdSC := aEstP[nFs,3]

		If lEstp
			cLocSC1 := NGSEEK("SB1",cvProdSC,1,"B1_LOCPAD")
		EndIf

		If !lExecSC1

			If NGIFDBSEEK( 'SC1', aSeek[1], aSeek[2] )

				lTemSc1 := .T.

				Do While SC1->( !EoF() ) .And. &( cLoop )

					If sc1->c1_produto == cvProdSC .And. sc1->c1_tpop == 'F' .And. sc1->c1_local = cLocSC1 .And.;
						Empty(sc1->c1_pedido) .And. Empty(sc1->c1_cotacao)

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Remove o Numero e Item da SC do Pedido de Compra.              ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If NGIfDBSEEK("SC7",SC1->C1_PRODUTO,2)
							While !EoF() .And. xFilial('SC7')+SC1->C1_PRODUTO==SC7->C7_FILIAL+SC7->C7_PRODUTO
								If SC1->C1_Num+SC1->C1_ITEM == SC7->C7_NUMSC+SC7->C7_ITEMSC
									RecLock("SC7",.F.)
									SC7->C7_NUMSC  := Space(Len(SC7->C7_NUMSC))
									SC7->C7_ITEMSC := Space(Len(SC7->C7_ITEMSC))
									SC7->(MsUnlock())
								EndIf
								NGDBSELSKIP("SC7")
							End
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Subtrai a qtde do Item da SC no arquivo de entrada de estoque  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If NGIfDBSEEK("SB2",cvProdSC+SC1->C1_Local,1)
							RecLock("SB2",.F.)
							SB2->B2_SALPEDI -= (SC1->C1_QUANT-SC1->C1_QUJE)
							SB2->(MsUnlock())
							nQtDSC1 += (SC1->C1_QUANT-SC1->C1_QUJE)
						EndIf

						If ( lOk := NGAtuErp( 'SC1', 'DELETE', IIf( lDelIt, SC1->C1_ITEM, Nil ) ) )

							// Realiza exclusão da S.C. e seus relacionamentos ( SCR ).
							IIf( FindFunction( 'MntDelReq' ), MntDelReq( SC1->C1_NUM, SC1->C1_ITEM, 'SC' ), NGDELETAREG( 'SC1' ) )

						EndIf

						Exit

					EndIf

					NGDBSELSKIP("SC1")

				End

			EndIf

		EndIf

		If !lOk
			Exit
		EndIf

		cProdD4 := IIf( lTemSc1, cvProdSC, cProdD4 )
		cLocD4  := IIf( lEstp, cLocSC1, cLocal )

		If lDelSD4 .And. NGIfDBSEEK( 'SD4', cCODOP2 +cProdD4 + cLocD4,2 )

			nQTPD4 := SD4->D4_QTDEORI

			If SB1->(dbSeek(xFilial('SB1')+SD4->D4_COD))
				If SB1->B1_LocalIZ == "S"
					//Verifica lote/endereço
					dbSelectArea("SDC")
					dbSetOrder(2) //DC_FILIAL+DC_PRODUTO+DC_Local+DC_OP+DC_TRT+DC_LOTECTL+DC_NUMLOTE+DC_LocalIZ+DC_NUMSERI
					If dbSeek( xFilial("SDC") + SD4->D4_COD + SD4->D4_Local + SD4->D4_OP )
						RecLock("SDC",.F.)
						dbDelete()
						MsUnlock("SDC")
					EndIf

					//Retira o saldo empenhado da tabela SBF
					dbSelectArea("SBF")
					dbSetOrder(02)
					If dbSeek( xFilial("SBF") + SD4->D4_COD + SD4->D4_Local)
						RecLock("SBF",.F.)
						SBF->BF_EMPENHO -= SD4->D4_QUANT
						MsUnlock("SBF")
					EndIf
				EndIf
			EndIf

			// Atualiza quantidade empenhada na tabelas SB2.
			If lUpdSB2

				dbSelectArea( 'SB2' )
				dbSetOrder( 1 ) // B2_FILIAL + B2_COD + B2_LOCAL
				If msSeek( xFilial( 'SB2' ) + cvPROD + cLocal )

					RecLock( 'SB2', .F. )
					SB2->B2_QEMP -= SD4->D4_QUANT
					SB2->( MsUnlock() )

				EndIf

			EndIf

			NGAtuErp("SD4","DELETE")
			NGDELETAREG("SD4")

		EndIf

	Next nFs

	If lOk .And. lEstp

		cLocSC1 := NGSEEK("SB1",cvPROD,1,"B1_LOCPAD")

		If NGIfDBSEEK("SB2",cvProd+cLocSC1,1)
			RecLock("SB2",.F.)
			SB2->B2_SALPEDI -= nQtdPr
			If SB2->B2_SALPEDI < 0
				SB2->B2_SALPEDI := 0
			EndIf
			SB2->(MsUnlock())
		EndIf

	EndIf

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGALTCAMBAS ³ Autor ³ Inacio Luiz Kolling   ³ Data ³12/12/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Altera o conteudo de um campo da base de dados                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias  - Alias do arquivo/tabela               - Obrigatorio³±±
±±³          ³ cChav   - Chave de acesso                       - Obrigatorio³±±
±±³          ³ nInd    - Numero do indice                      - Obrigatorio³±±
±±³          ³ cCamp   - Nome do campo                         - Obrigatorio³±±
±±³          ³ cCont   - Conteudo                              - Obrigatorio³±±
±±³          ³ cFili   - Codigo da filial                      - Nao Obrit. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³ .T.     - Alterou , .F. Nao alterou                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³OBSERVACAO³ Ser muito criterioso na utilizacao da funcao.   FUNCIONAL    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGALTCAMBAS(cAlias,cChav,nInd,cCamp,cCont,cFili)
Local aAreaAt := GetArea(),lRet := .F.,lTipI := .F.
If NGIfDBSEEK(cAlias,cChav,nInd,.F.,cFili)
   aEstrD := dbStruct()
   If Ascan(aEstrD,{|x| x[1] == cCamp}) > 0
      cCa1 := cAlias+"->"+cCamp
      If type(cCa1) = Valtype(cCont)
         lTipI := .T.
      ElseIf type(cCa1) = 'M' .And. Valtype(cCont) = 'C'
         lTipI := .T.
      EndIf
      If lTipI
         If &(cCa1) <> cCont
            RecLock(cAlias,.F.)
            &(cCa1) := cCont
            (cAlias)->(MSUNLOCK())
            lRet := .T.
         EndIf
      EndIf
   EndIf
EndIf
RestArea(aAreaAt)
Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGPONTOENTR ³ Autor ³In cio Luiz Kolling   ³ Data ³12/11/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se existe o ponto de entrada e executa              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cNomPto - Nome do ponto de entrada                Obrigatorio³±±
±±³          ³lTemRet - Tem retorno                             Nao Obrig. ³±±
±±³          ³vVetPar - Parametros                              Nao Obrig. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGPONTOENTR(cNomPto,lTemRet,vVetPar)
Local cNomePr := Alltrim(cNomPto)
If NGFUNCRPO("U_"+cNomePr,.F.)
   If lTemRet <> Nil
      If vVetPar <> Nil
         lRetP := ExecBlock(cNomePr,.F.,.F.,vVetPar)
      Else
         lRetP := ExecBlock(cNomePr,.F.,.F.)
      EndIf
      Return lRetP
   Else
      If vVetPar <> Nil
         ExecBlock(cNomePr,.F.,.F.,vVetPar)
      Else
         ExecBlock(cNomePr,.F.,.F.)
      EndIf
   EndIf
EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGEXISTVARIA³ Autor ³In cio Luiz Kolling   ³ Data ³10/11/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se existe uma variavel e o tipo(opcionol)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cNomV - Nome da variavel                          Obrigatorio³±±
±±³          ³cTipV - Tipo da variavel                          Nao Obrig. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³lRetV - .T.,.F.                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGEXISTVARIA(cNomV,cTipV)
Return If(cTipV <> Nil,If(Type(cNomV) = cTipV,.T.,.F.),;
                       If(Type(cNomV) <> "U",.T.,.F.))

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ NGSAIENC ³ Autor ³ Deivys Joenck         ³ Data ³ 14/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Guarda aTela e aGets na saida do foco na enchoice          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGSAIENC(cALIAS,x)
Local lReturn := .T.

If nOPCAO == 3 .OR. nOPCAO == 4
   If !OBRIGATORIO(aGETS,aTELA)
      lReturn := .F.
   EndIf
EndIf
aSVATELA := aCLONE(aTELA)
aSVAGETS := aCLONE(aGETS)
DBSELECTAREA(cALIAS)
Return(lReturn)

//-----------------------------------------------------------------------
/*/{Protheus.doc} NGSAIGET
Guarda aCols e aHeader quando se sai da GETDADOS.
@type function

@author Deivys Joenck
@since	14/08/2001

@param  nG  , numeric, Indica qual posição deve salvar o aCols e aHeader.
@param oGet, object , Objeto de controle do GetDados.
@retun
/*/
//-----------------------------------------------------------------------
Function NGSAIGET( nG, oGet )
	
	If Len( aSVHeader ) >= nG .And. Len( aSVCols ) >= nG
		
		If !Empty( oGet )
			aSVHeader[nG] := aClone( oGet:aHeader )
			aSVCols[nG]   := aClone( oGet:aCols )
		Else
			aSVHeader[nG] := aClone( aHeader )
			aSVCOLS[nG]   := aClone( aCols )
		EndIf
	
	EndIf

	n := Len( aSVCols[nG] )

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGVISUESPE³ Autor ³In cio Luiz Kolling    ³ Data ³29/07/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Posiciona e visualisa o cadastro                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGVISUESPE(cARQ,cCHAVE)
Local cALIASOV  := Alias()
Local nORDIOLV  := IndexOrd()
Local nRECGARV  := Recno()
Local cCADAOLV  := If(Type("cCADASTRO") = 'A',cCADASTRO,' ')
Local aROTIOLV  := If(Type("aRotina") = 'A',Aclone(aROTINA),{})
Local aAPOS     := If(Type("aPOS") = 'A',Aclone(aPOS),{})
Private aPOS1   := {15,1,95,315}
Private aROTINA := {{STR0154,"AxPesqui" , 0, 1},; //"Pesquisar"
                    {STR0155,"AxVisual", 0, 2}}   //"Visualizar"
If Select(cARQ) > 0
   If NGIfDICIONA("SX2",cARQ,1)
      cCADASTRO := FWX2Nome(cARQ)+" - "+STR0144
      NGDBAREAORDE(cARQ,1)
      dbSeek(xFILIAL(cARQ)+cCHAVE)
      AxVisual(cARQ,RECNO(),2)
   EndIf
EndIf

dbSelectArea(cALIASOV)
cCADASTRO := cCADAOLV
aRotina   := Aclone(aROTIOLV)
aPOS      := Aclone(aAPOS)
NGDBAREAORDE(cALIASOV,nORDIOLV)
dbGoTo(nRECGARV)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NGSOCARACTER³ Autor ³In cio Luiz Kolling   ³ Data ³22/09/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consistencia do conteudo de uma variavel somente tipo        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cVARIAVEL - Conteudo da variavel                - Obrigatorio³±±
±±³          ³cTIPOCARA - Tipo de caracter (D-Digito,L-Letra) - Nao Obrig. ³±±
±±³          ³cSAIDATEL - Saida via tela                      - Nao Obrig. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GENERICA                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGSOCARACTER(cVARIAVEL,cTIPOCARA,cSAIDATEL)
Local nf := 0,cMENSAF := Space(1), vVetRet := {.T.,Space(1)}
Local lTELA := If(cSAIDATEL = Nil,.T.,cSAIDATEL),lProbV := .F.
Local cTIPO := If(cTIPOCARA = Nil,"L",cTIPOCARA)
If VALTYPE(cVARIAVEL) $ "CM"
   For nf := 1 To Len(Alltrim(cVARIAVEL))
      cCARACV := SubS(cVARIAVEL,nf,1)
      If cTIPO = "D"
         If !Isdigit(cCARACV)
            cMENSAF := STR0156
            Exit
         EndIf
      Else
         If Isdigit(cCARACV)
            cMENSAF := STR0157
            Exit
         EndIf
      EndIf
   Next nf
Else
   lProbV  := .T.
   cMENSAF := STR0158
EndIf

If !Empty(cMENSAF)
   If lTELA
      MsgInfo(If(lProbV,cMENSAF,STR0159+" "+cMENSAF+" - "+Alltrim(cVARIAVEL)),STR0002)
      vVetRet[1] := .F.
   Else
      vVetRet := {.F.,If(lProbV,cMENSAF,STR0159+" "+cMENSAF+" - "+Alltrim(cVARIAVEL))}
   EndIf
EndIf
Return If(lTELA,vVetRet[1],vVetRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³NGIMPCAD  ºAutor  ³Wagner S. de Lacerdaº Data ³  25/07/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprime o Cadastro (registro) com os campos do dicionario  º±±
±±º          ³ e os dados da tabela.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ .T. -> Impressao realizada com sucesso.                    º±±
±±º          ³ .F. -> Nao foi possivel realizar a impressao.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cAliasImp -> Obrigatorio;                                  º±±
±±º          ³              Alias (tabela) utilizada para impressao.      º±±
±±º          ³              Utilizado na funcao de Impressao.             º±±
±±º          ³ aChaveImp -> Obrigatorio;                                  º±±
±±º          ³              Array contendo as chaves de pesquisa para os  º±±
±±º          ³              Utilizado na funcao de Impressao.             º±±
±±º          ³ nIndImp ---> Opcional;                                     º±±
±±º          ³              Define o Indice (ordem) da pesquisa dos dados.º±±
±±º          ³              Utilizado na funcao de Impressao.             º±±
±±º          ³ lBreakImp -> Opcional;                                     º±±
±±º          ³              Define se o relatorio deve quebrar as paginas º±±
±±º          ³              a cada registro impresso.                     º±±
±±º          ³              Utilizado na funcao de Impressao.             º±±
±±º          ³              Default: .T. - Quebra por registro.           º±±
±±º          ³ aTitsImp --> Opcional;                                     º±±
±±º          ³              Array contendo os titulos para cada Cadastro. º±±
±±º          ³              Utilizado na funcao de Impressao.             º±±
±±º          ³              Default: {} - vazio.                          º±±
±±º          ³ aNaoImp ---> Opcional;                                     º±±
±±º          ³              Array contendo os campos do dicionario (SX3)  º±±
±±º          ³              que nao devem constar na impressao.           º±±
±±º          ³              Utilizado na funcao de Busca.                 º±±
±±º          ³              Default: {} - vazio.                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador ³   Data     ³ Descricao                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º            ³ xx/xx/xxxx ³                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGIMPCAD(cAliasImp, aChaveImp, nIndImp, lBreakImp, aTitsImp, aNaoImp)

Local aAreaOLD := GetArea()

Local nX := {}

Local cField := cDescField := ""
Local uValor := Nil

Default cAliasImp := ""
Default aChaveImp := {}
Default nIndImp   := 1
Default lBreakImp := .T.
Default aTitsImp  := {}
Default aNaoImp   := {}

/* Variaveis para definicao da Impressao */
Private cNomeProg := "NGIMPCAD"
Private nLimite   := 220
Private cTamanho  := "G"
Private aReturn   := {STR0160,1,STR0161,1,2,1,"",1} //"Zebrado"###"Administração"
Private nTipo     := 0
Private nLastKey  := 0
Private cTitulo   := OemToAnsi(STR0162) //"Relatório de Impressão do Cadastro"
Private cDesc1    := OemToAnsi(STR0163+" ") //"Imprime as informações do cadastro de acordo com os campos do dicionário"
Private cDesc2    := OemToAnsi(STR0164) //"e os dados registrados na tabela."
Private cDesc3    := ""
Private cString   := cAliasImp
/**/

/* Variaveis que devem ser PRIVATE para controle do Relatorio */
Private cAliasCAD := cAliasImp
Private aChaveCAD := aChaveImp
Private nIndCAD   := nIndImp
Private lBreakCAD := lBreakImp
Private aTitsCAD  := aTitsImp
Private aNaoCAD   := aNaoImp

Private cNomTblCAD := ""
/**/

If Empty(cAliasCAD) .Or. Len(aChaveCAD) == 0
	MsgInfo(STR0165,STR0037) //"Não foi possível montar o relatório."###"Atenção"
	Return .F.
EndIf

//Nome da Tabela
dbSelectArea("SX2")
dbSetOrder(1)
If dbSeek(cAliasCAD)
	cNomTblCAD := Upper(AllTrim( X2Nome() ))
EndIf

//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º Imprime o Cadastro              º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
If FindFunction("TRepInUse") .And. TRepInUse()
	NGIMPCAD02()
Else
	Private cWnRel  := cNomeProg
	Private cCabec1 := ""
	Private cCabec2 := ""

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cWnRel := SetPrint(cString, cWnRel, , cTitulo, cDesc1, cDesc2, cDesc3, .F., "")
	If nLastKey == 27
		Return .F.
	EndIf

	nTipo := If(aReturn[4] == 1, 15, 18)

	SetDefault(aReturn, cString)
	RptStatus({|lEnd| NGIMPCAD01(@lEnd)}, OemToAnsi(STR0166+"...")) //"Imprimindo Relatório" //Modelo 01 - Padrao
EndIf

RestArea(aAreaOLD)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³NGBUSCACADºAutor  ³Wagner S. de Lacerdaº Data ³  25/07/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca os dados do Cadastro.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ aBuscaCAD -> Array com os dados do cadastro.               º±±
±±º          ³ .F. -> Nao foi possivel buscar os dados.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObservacao³ Chamar esta funcao atraves de um Processa(...) para poder  º±±
±±º          ³ mostrar a barra de progresso.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador ³   Data     ³ Descricao                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º            ³ xx/xx/xxxx ³                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGBUSCACAD()

	Local aAreaOLD   := GetArea()
	Local aBuscaCAD  := {}
	Local aBuscaTemp := {}
	Local aHeaderAli := {}
	Local nX         := 0
	Local nLimpa     := 0
	Local nPosNao    := 0
	Local nTamTot    := 0
	Local nInd       := 0
	Local cField     := ""
	Local cDescField := ""
	Local uValor     := Nil
	Local lOReport   := Type("oReport") == "O"
	Local lCont      := .T.

	Local aMemo
	Local nMemo
	Local nLinhasMemo

	If Empty(cAliasCAD) .Or. Len(aChaveCAD) == 0
		Return .F.
	EndIf

	//Busca os Dados do Cadastro
	aBuscaCAD  := {}
	aBuscaTemp := {}

	ProcRegua(Len(aChaveCAD))
	For nX := 1 To Len(aChaveCAD)
		IncProc(STR0167+"...") //"Buscando Dados"

		dbSelectArea(cAliasCAD)
		dbSetOrder(nIndCAD)
		If dbSeek(aChaveCAD[nX])
			aBuscaTemp := {}

			RegToMemory(cAliasCAD,.F.)

			aHeaderAli := NGHeader(cAliasCAD)
			nTamTot := Len(aHeaderAli)
			For nInd := 1 To nTamTot

				cField := aHeaderAli[nInd,2]
				cDescField := AllTrim(X3Descric())

				If Len(aNaoCAD) > 0 //Campos do dicionario SX3 que nao devem constar no relatorio
					nPosNao := aScan(aNaoCAD, {|x| AllTrim(x) == AllTrim(cField) })
					If nPosNao > 0
						lCont := .F.
					EndIf
				EndIf

				If aHeaderAli[nInd,8] == "M" .And. lOReport .And. lCont  //No relatorio personalizavel, os campos Memo nao serao impressos
					lCont := .F.
				EndIf

				If lCont
					//Retira os enters
					cDescField := StrTran(cDescField, Chr(13), "")
					cDescField := StrTran(cDescField, Chr(10), "")


					If aHeaderAli[nInd,10] != "V" .Or. aHeaderAli[nInd,8] == "M"

						If aHeaderAli[nInd,8] == "M"
							uValor := cAliasCAD+"->"+cField
						Else
							uValor := &(cAliasCAD+"->"+cField)
						EndIf
						aMemo := {}

						If aHeaderAli[nInd,8] == "D"
							uValor := DTOC(uValor)
						ElseIf aHeaderAli[nInd,8] == "N"
							uValor := Transform(uValor, AllTrim(Posicione("SX3", 2, aHeaderAli[nInd,2], "X3_PICTURE")))
						ElseIf aHeaderAli[nInd,8] == "M"
							nLinhasMemo := MLCOUNT(&(uValor),60)
							If nLinhasMemo > 0
								For nMemo := 1 To nLinhasMemo
									aAdd(aMemo, MemoLine(&(uValor),60,nMemo))
								Next nMemo
							Else
								uValor := " "
							EndIf
						Else
							uValor := AllTrim(uValor)
						EndIf

						If Len(aMemo) == 0
							aAdd(aBuscaTemp, {cDescField, uValor})
						Else
							aAdd(aBuscaTemp, {cDescField, aMemo })
						EndIf
					ElseIf Posicione("SX3",2,aHeaderAli[nInd,2],"X3_CONTEXT") == "V"
						uValor := CriaVar(cField,.T.)
						aAdd(aBuscaTemp, {cDescField, uValor})
					EndIf
				EndIf

			Next nInd

			//--- Limpa o conteudo do array, porque campos vazios devem possuir Espaco em Branco
			For nLimpa := 1 To Len(aBuscaTemp)
				If Empty(aBuscaTemp[nLimpa][2]) .And. ValType(aBuscaTemp[nLimpa][2]) <> "N"
					aBuscaTemp[nLimpa][2] := Space(1)
				EndIf
			Next nLimpa

			aAdd(aBuscaCAD, aBuscaTemp)
		EndIf
	Next nX

	RestArea(aAreaOLD)

Return aBuscaCAD

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³NGIMPCAD01ºAutor  ³Wagner S. de Lacerdaº Data ³  25/07/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza a impressao do Cadastro no Modelo 01 - Padrao.     º±±
±±º          ³ (Imprime o Relatorio Padrao)                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ .T. -> Impressao realizada com sucesso.                    º±±
±±º          ³ .F. -> Nao foi possivel realizar a impressao.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ lEnd ------> Obrigatorio;                                  º±±
±±º          ³              Controla o Cancelamento do Relatorio pelo     º±±
±±º          ³              usuario.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObservacao³ Chamar esta funcao atraves de um RptStatus(...) para poder º±±
±±º          ³ mostrar a barra de progresso.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador ³   Data     ³ Descricao                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º            ³ xx/xx/xxxx ³                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGIMPCAD01(lEnd)

Local aAreaOLD := GetArea()

Local aImprime := {}
Local nRegs := 0
Local nColuna := 001
Local nCAD := 0, nDados := 0, nMemo := 0

Local nTamDesc := SX3->(Len(X3Descric()))

Local cRodaTxt := "" //Variavel para controle do Relatorio
Local nCntImpr := 0 //Variavel para controle do Relatorio

Private Li := 80, m_pag := 1 //Variaveis para controle do Relatorio

Private aImpCAD01  := {}
Private cTitPagina := "" //Variavel para o Titulo da Pagina

//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º Busca os Dados para a Impressao º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
Processa({|| aImpCAD01 := aClone( NGBUSCACAD() ) }, OemToAnsi(STR0168+"...")) //"Processando Relatório"

If Len(aImpCAD01) == 0
	MsgInfo(STR0169,STR0037) //"Não há dados para imprimir o relatório."###"Atenção"
	Return .F.
EndIf

//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º Realiza a Impressao do Cadastro º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
SetRegua(Len(aImpCAD01))

For nCAD := 1 To Len(aImpCAD01)

	IncRegua()

	If lEnd
		MsgStop(STR0170+"!",STR0037) //"Relatório cancelado pelo usuário"###"Atenção"
		Return .F.
	EndIf

	//Recebe o Titulo da Pagina
	If Len(aTitsCAD) == Len(aImpCAD01)
		cTitPagina := aTitsCAD[nCAD]
	Else
		cTitPagina := ""
	EndIf

	//Quebra a Pagina
	If nCAD == 1 //Primeiro Cadastro
		NGIMPCADLI(80)
	ElseIf nCAD > 1
		If lBreakCAD //Quebra por Cadastro
			NGIMPCADLI(80)
		Else
			NGIMPCADLI(2,.T.)
		EndIf
	EndIf

	//Imprime os Dados Cadastrais
	aImprime := aClone( aImpCAD01[nCAD] )
	nRegs    := 1
	nColuna  := 001

	For nDados := 1 To Len(aImprime)
		If lEnd
			MsgStop(STR0170+"!",STR0037) //"Relatório cancelado pelo usuário"###"Atenção"
			Return .F.
		EndIf

		If nRegs > 2
			nRegs := 1

			NGIMPCADLI()
			nColuna := 001
		ElseIf nRegs == 2
			nColuna := 100
		EndIf

		@ Li,nColuna PSAY OemToAnsi(AllTrim(aImprime[nDados][1])) + Replicate(".",(nTamDesc - Len(AllTrim(aImprime[nDados][1])))) + ":"

		nColuna += 31

		If ValType(aImprime[nDados][2]) <> "A"
			@ Li,nColuna PSAY OemToAnsi(aImprime[nDados][2])
		Else
			For nMemo := 1 To Len(aImprime[nDados][2])
				If nMemo > 1
					NGIMPCADLI()
				EndIf
				@ Li,nColuna PSAY OemToAnsi(aImprime[nDados][2][nMemo])
			Next nMemo
		EndIf

		nRegs++
	Next nDados
Next nCAD

//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º Finaliza a Impressao            º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
Roda(nCntImpr, cRodaTxt, cTamanho)

Set Device To Screen
If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(cWnRel)
EndIf
MS_FLUSH()

RestArea(aAreaOLD)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³NGIMPCAD02ºAutor  ³Wagner S. de Lacerdaº Data ³  25/07/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza a impressao do Cadastro no Modelo 02 - Personali-  º±±
±±º          ³ zavel. (Imprime o Relatorio Personalizavel)                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ .T. -> Impressao realizada com sucesso.                    º±±
±±º          ³ .F. -> Nao foi possivel realizar a impressao.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador ³   Data     ³ Descricao                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º            ³ xx/xx/xxxx ³                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGIMPCAD02()

Local aAreaOLD := GetArea()

Private aImpCAD02 := {}
Private oReport, oSection0
Private nATU, nPROC

//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º Realiza a Impressao do Cadastro º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
oReport := fCAD02Def()
oReport:SetLandscape() //Default Paisagem
oReport:PrintDialog()

RestArea(aAreaOLD)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³fCAD02Def ºAutor  ³Wagner S. de Lacerdaº Data ³  25/07/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Define relatorio personalizavel.                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ .T. -> Sucesso.                                            º±±
±±º          ³ .F. -> Ocorreram erros.                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NGIMPCAD02                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador ³   Data     ³ Descricao                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º            ³ xx/xx/xxxx ³                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fCAD02Def()

Local oCell

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := TReport():New(cNomeProg, cTitulo, , {|oReport| fCAD02Prnt()}, cDesc1+cDesc2+cDesc3)

Pergunte(oReport:uParam,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³                                                                        ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de código para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º Section 0 - Cadastro            º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
oSection0 := TRSection():New(oReport, cNomTblCAD, {cAliasCAD} )
	oCell := TRCell():New(oSection0, "CAMPO1"  , "" , STR0171, ""  , 30, .T./*lPixel*/, {|| fCAD02Trat(nATU, nPROC-1,1) }/*code-block de impressao*/ ) //"Campo"
	oCell := TRCell():New(oSection0, "CONTEUD1", "" , STR0172, "@!", 50, .T./*lPixel*/, {|| fCAD02Trat(nATU, nPROC-1,2) }/*code-block de impressao*/ ) //"Conteúdo"
	oCell := TRCell():New(oSection0, "CAMPO2"  , "" , STR0171, ""  , 30, .T./*lPixel*/, {|| fCAD02Trat(nATU, nPROC,1)   }/*code-block de impressao*/ ) //"Campo"
	oCell := TRCell():New(oSection0, "CONTEUD2", "" , STR0172, "@!", 50, .T./*lPixel*/, {|| fCAD02Trat(nATU, nPROC,2)   }/*code-block de impressao*/ ) //"Conteúdo"

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³fCAD02PrntºAutor  ³Wagner S. de Lacerdaº Data ³  25/07/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprime o relatorio personalizavel.                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ .T. -> Sucesso.                                            º±±
±±º          ³ .F. -> Ocorreram erros.                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NGIMPCAD02                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador ³   Data     ³ Descricao                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º            ³ xx/xx/xxxx ³                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fCAD02Prnt()

Local aImprime := {}
Local nCAD, nDados

Private oTitFont := Nil
Private nTitCol  := 030

//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º Busca os Dados para a Impressao º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
Processa({|| aImpCAD02 := aClone( NGBUSCACAD() ) }, OemToAnsi(STR0158+"...")) //"Processando Relatório"

If Len(aImpCAD02) == 0
	MsgInfo(STR0174,STR0037) //"Não há dados para imprimir o relatório."###"Atenção"
	Return .F.
EndIf

//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º Realiza a Impressao do Cadastro º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
oReport:SetMeter(Len(aImpCAD02))

For nCAD := 1 To Len(aImpCAD02)
	oReport:IncMeter()

	aImprime := aClone( aImpCAD02[nCAD] )
	nATU   := nCAD
	nDados := 0

	If oReport:Cancel()
		MsgStop(STR0170+"!",STR0037) //"Relatório cancelado pelo usuário"###"Atenção"
		Return .F.
	EndIf

	//Recebe o Titulo da Pagina
	If Len(aTitsCAD) == Len(aImpCAD02)
		cTitPagina := aTitsCAD[nCAD]
	Else
		cTitPagina := ""
	EndIf

	//Quebra a Pagina
	If nCAD == 1 //Primeiro Cadastro
		oReport:StartPage()
		oTitFont := oReport:oPrint:oFont
	ElseIf nCAD > 1 .And. lBreakCAD //Quebra por Cadastro
		oReport:EndPage()
		oReport:StartPage()
	EndIf
	NGIMPCADLI(80)

	oSection0:Init()
	While nDados <= Len(aImprime)
		nDados += 2

		nPROC := nDados
		oSection0:PrintLine()
	End
	oSection0:Finish()
Next nCAD

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³fCAD02TratºAutor  ³Wagner S. de Lacerdaº Data ³  25/07/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Trata a impressao dos Dados do dicionario.                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ uRet -> Retorno do campo.                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nAtual -> Obrigatorio;                                     º±±
±±º          ³           Indica o Cadastro que esta sendo impresso.       º±±
±±º          ³ nCont --> Obrigatorio;                                     º±±
±±º          ³           Indica posicao do array na impressao.            º±±
±±º          ³ nPos ---> Obrigatorio;                                     º±±
±±º          ³           Indica qual a informacao a ser impressa.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MNTC755                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador ³   Data     ³ Descricao                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º            ³ xx/xx/xxxx ³                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fCAD02Trat(nAtual, nCont, nPos)

Local aTemp := {}
Local uRet := " "

Local nTamDesc := SX3->(Len(X3Descric()))

aTemp := aClone(aImpCAD02[nAtual])

If Len(aTemp) >= nCont
	uRet := aTemp[nCont][nPos]
	If nPos == 1
		uRet += Replicate(".",(nTamDesc - Len(uRet))) + ":"
	EndIf
EndIf

Return uRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³NGIMPCADLIºAutor  ³Wagner S. de Lacerdaº Data ³  25/07/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Soma a linha do relatorio de Impressao do Cadastro.        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ .T.                                                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nLinhas ---> Opcional;                                     º±±
±±º          ³              Indica a quantidade de linhas a acrescentar.  º±±
±±º          ³              Default: 1.                                   º±±
±±º          ³ lImpCabec -> Opcional;                                     º±±
±±º          ³              Indica se deve forcar a impressao do titulo   º±±
±±º          ³              (cabecalho).                                  º±±
±±º          ³               .T. - Forca a impressao                      º±±
±±º          ³               .F. - Nao forca a impressao                  º±±
±±º          ³              Default: .F.                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador ³   Data     ³ Descricao                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º            ³ xx/xx/xxxx ³                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGIMPCADLI(nLinhas, lImpCabec)

Default nLinhas := 1
Default lImpCabec := .F.

If Type("oReport") <> "O"
	Li += nLinhas

	If Li > 58
		Cabec(cTitulo, cCabec1, cCabec2, cNomeProg, cTamanho, nTipo, , .F.) //Nao imprime parametros

		lImpCabec := .T.
	EndIf

	If lImpCabec
		If !Empty(cTitPagina)
			@ Li,001 PSAY OemToAnsi(Upper(cTitPagina))
			NGIMPCADLI()
			@ Li,000 PSAY Replicate("-",nLimite)
		EndIf
		NGIMPCADLI(2)
	EndIf
Else
	If !Empty(cTitPagina)
		oReport:Say(oReport:Row(), nTitCol, OemToAnsi(Upper(cTitPagina)), oTitFont, oSection0:nCLRBACK, oSection0:nCLRFORE)
		oReport:SkipLine()
		oReport:FatLine()
		oReport:SkipLine()
	EndIf
EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} NGNextNum
Traz o proximo numero sequencia de uma tabela contando com numeros deletados junto
cTabela - Tabela que deseja retornar o conteudo
cCampo  - Campo da tabela que deseja retornar o conteudo
@author Tainã Alberto Cardoso
@since 24/01/2014
@version MP11
@return
/*/
//---------------------------------------------------------------------
Function NGNextNum(cTabela,cCampo)
	Local cAliasQry, cQuery
	Local cNumero := ""
	Local cFilQuery := If(SubStr(cTabela,1,1) == "S",SubStr(cTabela,2),cTabela)
	If FindFunction("NGCONVINDICE")
	   cDesInd := Alltrim(NGSEEKDIC("SIX",cTabela+NGCONVINDICE(1,"N"),1,'CHAVE'))
	   nPosTra := At("_",cDesInd)
	   If nPosTra > 0
	      nPosMai := At("+",cDesInd)
	      cFilInc := If(nPosMai > 0,SubStr(cDesInd,nPosTra+1,(nPosMai-1)-nPosTra),;
	                                SubStr(cDesInd,nPosTra+1,Len(cDesInd)-nPosTra))
	      lTemFilI := 'FILIAL' $ cFilInc
	   EndIf
	EndIf
	cAliasQry := GetNextAlias()
	cQuery := " SELECT MAX("+cCampo+") AS NUMERO "
	cQuery += " FROM "+RetSqlName(cTabela)+" "
	cQuery += " WHERE "+cFilQuery+"_FILIAL='"+xFilial(cTabela)+"'"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	If !EoF()
		cNumero := (cAliasQry)->NUMERO
	Else
		cNumero := STRZero(1,Len(cCampo))
	End
Return Soma1(cNumero,Len(cCampo))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³NGLegenda ºAutor  ³Inacio Luiz Kolling º Data ³  23/06/2002 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta uma tela de Legenda.                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ .T.                                                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cTitulo --> Obrigatorio;                                   º±±
±±º          ³             Define o Titulo da Janela.                     º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³ cLegenda -> Obrigatorio;                                   º±±
±±º          ³             Define o Subtitulo da Janela.                  º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³ aLegenda -> Obrigatorio;                                   º±±
±±º          ³             Define o array (matriz) com a legenda,         º±±
±±º          ³             seguindo o formato:                            º±±
±±º          ³                [x][1] - Imagem no Repositorio              º±±
±±º          ³                [x][2] - Descricao/Legenda da imagem        º±±
±±º          ³ nModelo --> Opcional;                                      º±±
±±º          ³             Indica o Modelo da janela da legenda.          º±±
±±º          ³                1 - Modelo padrao do Protheus               º±±
±±º          ³                2 - Janela Personalizada da NG              º±±
±±º          ³             Default: 1                                     º±±
±±º          ³ aModelo --> Opcional;                                      º±±
±±º          ³             Indica as informacoes necessarias para montar  º±±
±±º          ³             a janela personalizada:                        º±±
±±º          ³                [1] - Altura da Imagem                      º±±
±±º          ³                [2] - Largura da Imagem                     º±±
±±º          ³                [3] - Largura do Texto                      º±±
±±º          ³                [4] - Quantidade de Secoes (colunas)        º±±
±±º          ³             (este parametro e' obrigatorio caso o modelo   º±±
±±º          ³              'nModelo' seja 2; caso nao venha definido, o  º±±
±±º          ³              modelo 1 sera setado automaticamente)         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador ³   Data     ³ Descricao                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºWagner S. L.³ 27/12/2012 ³ - Implementada uma tela personalizada para  º±±
±±º            ³            ³ a Legenda.                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NGLegenda(cTitulo, cLegenda, aLegenda, nModelo, aModelo)

Local oDlgPai    := If(Type("oMainWnd") == "O", oMainWnd, GetWndDefault())
Local oDlgLgnd   := Nil
Local oPnlLgnd   := Nil, oPnlTop := Nil, oPnlAll := Nil
Local oObjScroll := Nil
Local oLgndFont  := TFont():New(, , 16, .T., .T.)

Local nDlgHeight := 0, nMaxHeight := 400
Local nDlgWidth  := 0, nMaxWidth  := 600
Local nTamPnlTop := 030

Local nTopIni    := 05 //Posicao Real ao Topo em que a legenda esta
Local nTopPos    := 0 //Posicao Real ao Topo em que a legenda esta
Local nLeftIni   := 10 //Posicao Real a Esquerda em que a legenda esta
Local nLeftPos   := 0 //Posicao Real a Esquerda em que a legenda esta

Local nImgHeight := 15 //Altura da Imagem
Local nImgWidth  := 15 //Largura da Imagem
Local nTxtWidth  := 100 //Largura do Texto da Imagem
Local nQtdeSecao := 1 //Quantidade Secoes (Colunas)
Local nImgsSecao := 0 //Quantidade de Imagems por Secao

Local nQtde := 0  , nX    := 0
Local uAux1 := Nil, uAux2 := Nil

Default cTitulo  := ""
Default cLegenda := ""
Default aLegenda := ""
Default nModelo  := 1
Default aModelo  := {}

Private aShowLgnd := aClone( aLegenda )

//Valida os parametros do Titulo e Subtitulo
If Empty(cTitulo)
	cTitulo := If(ValType(cCadastro) == "C", cCadastro, STR0175) //"Legenda"
EndIf
If Empty(cLegenda)
	cLegenda := STR0175 //"Legenda"
EndIf

If nModelo == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Legenda Padrao do Protheus      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BrwLegenda(cTitulo, cLegenda, aShowLgnd)
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Janela Personalizada da Legenda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Valida as Definicoes do Modelo
	nImgHeight := If(Len(aModelo) >= 1 .And. ValType(aModelo[1]) == "N", aModelo[1], nImgHeight)
	nImgWidth  := If(Len(aModelo) >= 2 .And. ValType(aModelo[2]) == "N", aModelo[2], nImgWidth)
	nTxtWidth  := If(Len(aModelo) >= 3 .And. ValType(aModelo[3]) == "N", aModelo[3], nTxtWidth)
	nQtdeSecao := If(Len(aModelo) >= 4 .And. ValType(aModelo[4]) == "N", aModelo[4], nQtdeSecao)

	//Calcula a distribuicao em Secoes (colunas)
	If nQtdeSecao > 1
		nImgsSecao := Len(aShowLgnd) / nQtdeSecao
		If (nImgsSecao % Int(nImgsSecao)) > 0 //Se for ponto flutuante
			nImgsSecao := Int(nImgsSecao) + 1 //arredonda para 1 a mais
		EndIf
	EndIf

	//Calcula o Tamanho da Janela
	nDlgHeight := nTamPnlTop + (Len(aShowLgnd) * (nImgHeight*2))
	nDlgWidth  := (250 + nTxtWidth) * nQtdeSecao
	//Tamanho Maximo
	nDlgHeight := If(nDlgHeight > nMaxHeight, nMaxHeight, nDlgHeight)
	nDlgWidth  := If(nDlgWidth > nMaxWidth, nMaxWidth, nDlgWidth)

	//--- Monta a Legenda
	DEFINE MSDIALOG oDlgLgnd TITLE cTitulo FROM 0,0 TO nDlgHeight,nDlgWidth OF oDlgPai PIXEL

		//Painel Pai do Dialog
		oPnlLgnd := TPanel():New(01, 01, , oDlgLgnd, , , , CLR_BLACK, CLR_WHITE, 100, 100)
		oPnlLgnd:Align := CONTROL_ALIGN_ALLCLIENT

			//Painel TOP
			oPnlTop := TPanel():New(01, 01, , oDlgLgnd, , , , CLR_BLACK, CLR_WHITE, 100, nTamPnlTop)
			oPnlTop:Align := CONTROL_ALIGN_TOP

				//Subtitulo da Janela
				TSay():New(010, nLeftIni, {|| cLegenda }, oPnlTop, , oLgndFont, , , , .T., CLR_BLACK, CLR_WHITE, 100, 020)

				//GroupBox de Enfeite
				TGroup():New(019, 003, 021, (nDlgWidth*0.50), , oPnlTop, , , .T.)

			//Painel ALL
			oPnlAll := TPanel():New(01, 01, , oDlgLgnd, , , , CLR_BLACK, CLR_WHITE, 100, 100)
			oPnlAll:Align := CONTROL_ALIGN_ALLCLIENT

				//ScrollBox
				oObjScroll := TScrollBox():New(oPnlAll, 0, 0, 100, 100, .T., .T., .T.)
				oObjScroll:nClrPane := CLR_WHITE
				oObjScroll:Align := CONTROL_ALIGN_ALLCLIENT

				//Monta as Imagens e os Textos da Legenda
				nTopPos  := nTopIni
				nLeftPos := nLeftIni
				nQtde    := 0
				For nX := 1 To Len(aShowLgnd)

					//Define a Posicao
					If nQtdeSecao > 1 .And. nQtde > nImgsSecao
						nTopPos  := nTopIni //Redefine a posicao ao Topo

						//Calcula qual a melhor posicao a Esquerda
						uAux1 := (nImgWidth + nTxtWidth + nLeftIni) //Posicao acrescentada da minima
						uAux2 := (nDlgWidth * 0.50) - nTxtWidth - nImgWidth - nLeftIni //Posicao maxima da Janela menos o conteudo (para melhor ajustar as colunas)


						nLeftPos := If(uAux2 >= uAux1, uAux2, uAux1) //Redefine a posicao a Esquerda (dando preferencia para o melhor ajuste das colunas 'uAux2')

						nQtde := 0
					EndIf

					nQtde++
					//Imagem
					TBitmap():New(nTopPos, nLeftPos, nImgHeight, nImgWidth, , &("aShowLgnd["+cValToChar(nX)+"][1]"), .T., oObjScroll,;
						 			, , .F., .F., , , .T., , .T., , .F.)
					//Descricao
					TSay():New(nTopPos+(nImgHeight/4), (nImgWidth+nLeftPos), &("{|| aShowLgnd["+cValToChar(nX)+"][2] }"), oObjScroll,;
									, , , , , .T., CLR_BLACK, CLR_WHITE, nTxtWidth, nImgHeight)

					//Acrescenta a Posicao ao Topo
					nTopPos += nImgHeight

				Next nX

	ACTIVATE MSDIALOG oDlgLgnd CENTERED
EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} NGCALCUSMD
Converte valor conforme conforme moeda repassada.

@param cCodIn Codigo do Insumo
@param cTipr  Tipo do Insumo
@param nQuant Quantidade
@param cLocal Local estoque (Almoxarifado)
@param cTipoH Tipo de Unidade de Hora
@param cEmp   Codigo da Empresa
@param cFil   Codigo da Filial
@param nRecur Quantidade de Recurso
@param cMoeda Moeda utilizada para conversao

@author Hugo R. Pereira
@since 28/05/2012
@version MP10
@return nValor Valor conforme a moeda repassada
/*/
//---------------------------------------------------------------------
Function NGCALCUSMD(cCodIn, cTipr, nQuant, cLocal, cTipoH, cEmp, cFil, nRecur, cMoeda)

	Local nCusto     := 0
	Private cMdCusto := "1"

	nCusto := NGCALCUSTI(cCodIn, cTipr, nQuant, cLocal, cTipoH, cEmp, cFil, nRecur,, cMoeda)

Return {nCusto, cMdCusto}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³NGMEMOSYP ³ Autor ³ Evaldo Cevinscki Jr.  ³ Data ³ 18.03.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Busca memo da tabela SYP                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cChSYP  -> Campo com chave de relacionamento com SYP        ³±±
±±³          ³cFIL -> Codigo da Filial (opcional)                         ³±±
±±³          ³cEMP -> Codigo da Empresa (opcional)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³NGPROXMAN                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGMEMOSYP(cChSYP,cFIL,cEMP)
Local cMM := " "
Local aAREA := GetArea()

If cEMP <> NIL
	//Abre Arquivo SYP___ da empresa cEMP
	NGPrepTBL({{"SYP"}},cEMP)
EndIf

cFilSYP := NGTROCAFILI("SYP",cFIL,cEMP)

If !Empty(cChSYP)
 dbSelectArea("SYP")
 dbSetOrder(1)
 If dbSeek(cFilSYP+cChSYP)
  cMM := MSMM(SYP->YP_CHAVE,,,,3)
 EndIf
EndIf
RestArea(aAREA)

Return cMM

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGDOCPRINT ³ Autor ³ Thiago Olis Machado  ³ Data ³07/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime os documentos relacionados ao Banco de Conhecimento ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAMNT,SIGAMDT,SIGASGA                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cCodEnt = Codigo da entidade a ser impressa                 ³±±
±±³          ³          Exemplo: "ST9"                                    ³±±
±±³          ³cFilEnt = Filial da entidade a ser impressa                 ³±±
±±³          ³cCodRel = Codigo do Relacionamento da entidade              ³±±
±±³          ³          Exemplo: "CA001"                                  ³±±
±±³          ³nIMPVIS = Indica se deve imprimir ou abrir o arquivo do     ³±±
±±³          ³          banco do conhecimento (1 = Abrir, 2=Imprimir)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ F.O  ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NgDocPrint(cCodEnt,cFilEnt,cCodRel,nIMPVIS)
Local cFileName := ""
Local cParam    := ""
Local cDir      := ""
Local cDrive    := ""
Local cDirDocs  := MsDocPath()
Local nIMPV     := If(nIMPVIS == Nil,2,nIMPVIS)

dbSelectArea("AC9")
dbSetOrder(2)
dbSeek(xFilial("AC9")+cCodEnt+cFilEnt+cCodRel)

While !EoF() .And. AC9->AC9_FILIAL == xFilial("AC9") .And.;
                    AC9->AC9_FILENT == cFilEnt        .And.;
                    AC9->AC9_ENTIDA == cCodEnt			.And.;
                    AllTrim(AC9->AC9_CODENT) == AllTrim(cCodRel)

	dbSelectArea("ACB")
	dbSetOrder(1)
	dbSeek(xFilial("ACB")+AC9->AC9_CODOBJ)

	cFileName := GetTempPath() + AllTrim( ACB->ACB_OBJETO )

	SplitPath(cFileName, @cDrive, @cDir )
	cDir := Alltrim(cDrive) + Alltrim(cDir)
	cTempPath := GetTempPath()
	cPathFile := cDirDocs + "\" + AllTrim( ACB->ACB_OBJETO )

	Processa( { || lCopied := CpyS2T( cPathFile, cTempPath, .T. ) }, "Transferindo objeto", "Aguarde...",.F.)

	If nIMPV == 1 //Abri o arquivo para visualizacao
   	nRet := ShellExecute("Open",cFileName,cParam,cDir, 1 )
	Else          //Imprimi
	   nRet := ShellExecute("print",cFileName,cParam,cDir, 1 )
	EndIf

	dbSelectArea("AC9")
	dbSetOrder(2)
	dbSkip()
End

Return .T.


cFilSYP := NGTROCAFILI("SYP",cFIL,cEMP)

If !Empty(cChSYP)
	dbSelectArea("SYP")
	dbSetOrder(1)
	If dbSeek(cFilSYP+cChSYP)
		cMM := MSMM(SYP->YP_CHAVE,,,,3)
	EndIf
EndIf
RestArea(aAREA)

Return cMM

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGIntPIMS ³ Autor ³ Felipe Nathan Welter  ³ Data ³ 28/09/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Centraliza o envio de mensagem para integracao com o sistema³±±
±±³          ³PIMS atraves do EAI.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGIntPIMS(cAlias,nRecNo,nOp)

	Local aCampos := {}, aFields := {}
	Local nX := 0
	Private aLoadVar := {} //utilizada em PIMSGeraXML

	dbSelectArea(cAlias)
	dbGoTo(nRecNo)

	If !EoF() .And. SuperGetMV("MV_PIMSINT",.F.,.F.) .And. FindFunction("PIMSGeraXML")

		If cAlias == "TPN"

			If nOp == 3 .Or. nOp == 4 .Or. nOp == 5
				ST9->(dbSetOrder(01))
				ST9->(dbSeek(xFilial("ST9")+TPN->TPN_CODBEM))

				oStruct := FWFormStruct(1,"ST9")

				aFields := {"T9_CLIENTE","T9_LOJACLI","T9_SITBEM","T9_DTVENDA","T9_COMPRAD","T9_NFVENDA"}


				For nX := 1 To Len(aFields)
					nPos := aSCan(oStruct:aFields,{|x| x[3] = aFields[nX]})
					If nPos > 0
						aField := aClone(oStruct:aFields[nPos])
						aAdd(aCampos,aField)
						aAdd(aLoadVar,{aFields[nX],ST9->&(aFields[nX])})
					EndIf
				Next nX

				oStruct := FWFormStruct(1,"ST9")
				nPos := aSCan(oStruct:aFields,{|x| x[3] = "T9_MODELO"})
				If nPos > 0
					aAdd(aCampos,oStruct:aFields[nPos])
					oStruct:aFields[nPos][3] := "OPER"
					aAdd(aLoadVar,{"OPER",nOp})
				EndIf

				//Envia duas mensagens consecutivas, a primeira como Exclusao, a segunda de Inclusao (necessidade PIMS)
				If nOp == 3 .Or. nOp == 4
					For nX := 1 To 2
						nPos := asCan(aLoadVar,{|x| x[1] == "OPER"})
						If nPos > 0
							aLoadVar[nPos,2] := If(nX==1,5,3)
						EndIf
						PIMSGeraXML("UsageOfAssets","Utilizacao de Bens","2","TPN",aCampos)
					Next nX
				Else
					PIMSGeraXML("UsageOfAssets","Utilizacao de Bens","2","TPN",aCampos)
				EndIf

			EndIf

		ElseIf cAlias == "ST6"

			If nOp == 3 .Or. nOp == 4
				PIMSGeraXML("OperativeGroup","Grupo Operativo","2","ST6")
				PIMSGeraXML("OperationalCategory","Categoria Operacional","2","ST6")
			EndIf

		ElseIf cAlias == "ST7"

			If nOp == 3 .Or. nOp == 4
				PIMSGeraXML("AssetManufacturer","Fabricante de Bem","2","ST7")
			EndIf

		ElseIf cAlias == "TQR"

			If nOp == 3 .Or. nOp == 4
				PIMSGeraXML("ModelType","Tipo Modelo","2","TQR")
			EndIf

		ElseIf cAlias == "ST9"

			If nOp == 3 .Or. nOp == 4
				PIMSGeraXML("Asset","Bens","2","ST9")
			EndIf

		ElseIf cAlias == "SHB"

			If nOp == 3 .Or. nOp == 4
				PIMSGeraXML("WorkCenter","Centro de Trabalho","2","SHB")
			EndIf

		EndIf

	EndIf

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NGSX2EXIST³ Autor ³Evaldo Cevinscki Jr.   ³ Data ³19/12/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Checa no SX2 se a tabela informada no parametro existe      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExistAlias- Alias da Tabela                   - Obrigatorio³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna   ³ lExistAlias = .T./.F.                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGSX2EXIST(cExistAlias)
Local aAreaA := GetArea()
Local lExistAlias := .F.

dbSelectArea("SX2")
dbSetOrder(1)
If dbSeek(cExistAlias)
	lExistAlias := .T.
Else
	lExistAlias := .F.
EndIf
RestArea(aAreaA)

Return lExistAlias

//------------------------------------------------------------------------------------
/*/{Protheus.doc} NGVDHBomba
Verifica se existe outro abastecimento com data e hora superior ou igual para
o Tipo de Lancamento informado.
@type function

@author Vitor Emanuel Batista
@since 09/09/2009

@sample NGVDHBomba( 'MARLENE', '01', '01   ', '01', 25/12/2019, '22:00', 3 )

@param cPosto    , Caracter, Código do posto.
@param cLoja     , Caracter, Loja.
@param cTanque   , Caracter, Código do local de estoque (tanque).
@param cBomba    , Caracter, Código da bomba.
@param cData     , Data    , Data dp abastecimento.
@param cHora     , Caracter, Hora do abastecimento.
@param [cTipoLan], Caracter, Tipo do lançamento.
@param [cMotivo] , Caracter, Motivo do lançamento.
@param [cEmp]    , Caracter, Empresa na qual foi realizado o lançamento.
@param [cFil]    , Caracter, Filial na qual foi realizado o lançamento.
@return Lógico   , Define se o processo poderá seguir ou não.
/*/
//------------------------------------------------------------------------------------
Function NGVDHBomba( cPosto, cLoja, cTanque, cBomba, dData, cHora, cTipoLan, cMotivo, cEmp, cFil )

	Local lRet	  := .T.
	Local cAlsTQN := ''
	Local cAlsTTV := ''
	Local cWhere  := '%'
	Local aArea   := GetArea()

	If Inclui

		cAlsTQN := GetNextAlias()

		BeginSQL Alias cAlsTQN

			SELECT 1
			FROM
				%table:TQN%
			WHERE
				TQN_POSTO  = %exp:cPosto% 		 AND
       			TQN_LOJA   = %exp:cLoja%  		 AND
				TQN_TANQUE = %exp:cTanque%  	 AND
				TQN_BOMBA  = %exp:cBomba%  		 AND
				TQN_DTABAS = %exp:dToS( dData )% AND
				TQN_HRABAS = %exp:cHora%  		 AND
				%NotDel%

		EndSQL

		If (cAlsTQN)->( !EoF() )

			// Já existe um abastecimento com essas características: ## Atenção
			MsgStop( STR0196, STR0037 )
			lRet := .F.

		EndIf

		(cAlsTQN)->( dbCloseArea() )

	EndIf

	If lRet

		cAlsTTV := GetNextAlias()

		cWhere += 'AND TTV.TTV_FILIAL = ' + ValToSql( NGTROCAFILI( 'TTV', cFil, cEmp ) )

		If !Empty( cTipoLan )

			cWhere += ' AND TTV.TTV_TIPOLA IN ( ' + ValToSQL( cTipoLan ) + ' )'

		EndIf

		If !Empty( cMotivo )

			cWhere += ' AND TTV.TTV_MOTIVO IN ( ' + ValToSQL( cMotivo ) + ' )'

		EndIf

		cWhere += '%'

		BeginSQL Alias cAlsTTV

			SELECT
				COUNT(*) AS TTV_COUNT
			FROM
				%table:TTV% TTV
			WHERE
				TTV.TTV_POSTO  = %exp:cPosto%  AND
				TTV.TTV_LOJA   = %exp:cLoja%   AND
				TTV.TTV_TANQUE = %exp:cTanque% AND
				TTV.TTV_BOMBA  = %exp:cBomba%  AND
				TTV.TTV_DATA || TTV.TTV_HORA >= %exp:dToS( dData ) + cHora% AND
				TTV.%NotDel%
				%exp:cWhere%

		EndSQL


		lRet := (cAlsTTV)->( !EoF() ) .And. (cAlsTTV)->TTV_COUNT > 0

		(cAlsTTV)->( dbCloseArea() )

   	EndIf

	RestArea( aArea )

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³NGDelTTVAba³ Autor ³Vitor Emanuel Batista ³ Data ³08/09/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exclui registro da TTV de acordo com o N. do Abastecimento ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ cNABAST - Numero do abastecimento a ser localizado na TTV  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAMNT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NGDelTTVAba(cNAbast)

	If !AliasInDic("TTV")
		Return
	EndIf

	dbSelectArea("TTV")
	dbSetOrder(2)
	If dbSeek(xFilial("TTV")+cNAbast)
		NGDelTTV()
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} NGFILIAL
	Funcao para validar filial.
	@param	nOpc	, Númerico, 1 para De? 2 para Até?
			cPar1	, Caracter,	Parametro De?
			cPar2	, Caracter, Parametro Ate?
	@return
	@sample NGFILIAL(nOpc,cPar1,cPar2)
	@author Evaldo Cevinscki Jr.
	@since 16/11/2006
/*/
//---------------------------------------------------------------------
Function NGFILIAL(nOpc,cPar1,cPar2)

	Default cPar1 := ""
	Default cPar2 := ""

	If !Empty(cPar1)
		cPar1 := Upper(cPar1)
	EndIf
	If !Empty(cPar2)
		cPar2 := Upper(cPar2)
	EndIf

	If nOpc == 1
		If Empty(cPar1)
			Return .T.
		Else
			lRet := IIf(Empty(cPar1),.T.,ExistCpo('SM0',SM0->M0_CODIGO+cPar1))
		If !lRet
			Return .F.
		EndIf
		EndIf
	EndIf
	If nOpc == 2
		If cPar2 != Replicate('Z',Len(cPar2))
		lRet := IIf(ATECODIGO('SM0',SM0->M0_CODIGO+cPar1,SM0->M0_CODIGO+cPar2,02),.T.,.F.)
			If !lRet
			Return .F.
			EndIf
		Else
			Return .T.
		EndIf
	EndIf

Return .T.

//----------------------------------------------------------------------
/*/{Protheus.doc} NgFilTPN()
Retorna a filial do Bem no periodo solicitado.

@param cBem     - Código do bem    - Obrigatório
@param dDData   - Data da consulta - Obrigatório
@param cHora    - Hora da consulta - Obrigatório
@param cPlacST9 - Placa do veículo - Não obrigatório
@param cFilBem  - Filial do bem.   - Não obrigatório

@author Thiago Olis Machado
@since 04/12/2006
@version MP12
@return .t.
/*/
//---------------------------------------------------------------------
Function NgFilTPN(cBem,dData,cHora,cPlacST9,cFilBem)

	Local aArea	   := GetArea()
	Local aRet	   := {}
	Local cFilTPN  := ' '
	Local cCCusto  := ' '
	Local cCentrab := ' '
	Local cTabST9
	Local cTabTPN

	//Alteracao do nome da tabela na query para multiempresa
	dbSelectArea("ST9")
	cTabST9 := Trim(DBINFO(DBI_FULLPATH))
	dbSelectArea("TPN")
	cTabTPN := Trim(DBINFO(DBI_FULLPATH))

	Default cPlacST9 := ''
	Default cFilBem  := ''

	If Len(cTabST9) == 6 .And. Len(cTabTPN) == 6 .And. Substr(cTabST9,4) != Substr(cTabTPN,4)
		cTabTPN := "TPN"+Substr(cTabST9,4)
	Else
		cTabTPN := RetSQLName("TPN")
	EndIf

	cQry := GetNextAlias()

	cQuery := " SELECT TPN_FILIAL,TPN_CCUSTO,TPN_CTRAB,TPN_DTINIC,TPN_HRINIC"
	cQuery += " FROM " + cTabTPN + " TPN "

	If !Empty(cPlacST9)
		cQuery += " JOIN " +RetSQLName("ST9")+ " ST9 ON ST9.T9_CODBEM = '"+cBem+"' "
	EndIf

	cQuery += " WHERE TPN.D_E_L_E_T_ = ' ' AND "
	cQuery += " TPN.TPN_CODBEM = '"+cBem+"'  "
	If !Empty(cFilBem)
		cQuery += " AND TPN_FILIAL = '"+ cFilBem + "'"
	EndIf

	If !Empty(cPlacST9)
		cQuery += " AND TPN.TPN_FILIAL = ST9.T9_FILIAL  "
		cQuery += " AND ST9.T9_PLACA = '"+cPlacST9+"' AND ST9.D_E_L_E_T_ = '' "
	EndIf
	cQuery += " ORDER BY TPN.TPN_DTINIC,TPN.TPN_HRINIC,TPN.R_E_C_N_O_ "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cQry, .F., .T.)

	If (cQry)->( Eof() )
		//----------------------------------------------------
		//Quando não há TPN para o bem busca na ST9
		//----------------------------------------------------
		dbSelectArea("ST9")
		dbSetOrder(1)
		If dbSeek( xFilial( "ST9", IIF( !Empty( cFilBem ), cFilBem, NIL ) ) + cBem )
			cFilTPN  := ST9->T9_FILIAL
			cCCusto  := ST9->T9_CCUSTO
			cCentrab := ST9->T9_CENTRAB
		EndIf
	Else

		While !EoF()
			If DtoS(dData) > (cQry)->TPN_DTINIC
				cFilTPN  := (cQry)->TPN_FILIAL
				cCCusto  := (cQry)->TPN_CCUSTO
				cCentrab := (cQry)->TPN_CTRAB
			ElseIf DtoS(dData) == (cQry)->TPN_DTINIC .And. cHora >= (cQry)->TPN_HRINIC
				cFilTPN  := (cQry)->TPN_FILIAL
				cCCusto  := (cQry)->TPN_CCUSTO
				cCentrab := (cQry)->TPN_CTRAB
			EndIf
			DbSelectArea(cQry)
			DbSkip()
		End
	EndIf

	(cQry)->( dbCloseArea() )
	aRet := {cFilTPN,cCCusto,cCentrab}

	RestArea(aArea)

Return aRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ CriaSXE	 ³Autor	³ Ary Medeiros 		  ³ Data ³			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria registro no SX8 para alias nao Localizado				 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³CriaSXE() 															 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 														 ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CriaSXE(cAlias,cCpoSx8,cAliasSx8,nOrdSX8,lInServer)
Local cSavAlias := Alias(), nRecno, nOrdem, cNum, cFilCpo
Local lCampo := .T., cProva, aArquivos, nTamanho, lNetErr := .T., nTimes := 0
Local nHdl := -1, nTrys := 0, lFound, cCampo,cFilter, cSerie, nOrd, nNum, uRet
Local cMvUniao, cMvMunic
Local nFilNG := SubStr(cAliasSx8,1,2)

DEFAULT lInServer := .F.

cNum := Nil

If ( ExistBlock("CRIASXE") )
	uRet := ExecBlock("CRIASXE",.F.,.F.,{cAlias,cCpoSx8,cAliasSx8,nOrdSX8})
	If ( ValType(uRet) == 'C' )
		cNum 	:= uRet
		nTamanho:=Len(cNum)
	EndIf
EndIf

If cNum == Nil
	nOrdSX8 := IIf(nOrdSX8 == Nil,1,nOrdSX8)
	Do Case
		Case cAlias == "SA1"
			cCampo := "A1_COD"
		Case cAlias == "SA2"
			cCampo := "A2_COD"
		Case cAlias == "SB1"
			cCampo := "B1_COD"
		Case cAlias == "SC1"
			cCampo := "C1_NUM"
		Case cAlias == "SC2"
			cCampo := "C2_NUM"
		Case cAlias == "SC5"
			cCampo := "C5_NUM"
		Case cAlias == "SC7"
			cCampo := "C7_NUM"
		Case cAlias == "SC8"
			cCampo := "C8_NUM"
		Case cAlias == "SI2"
			cCampo := "I2_NUM"
		Case cAlias == "SL1"
			cCampo := "L1_NUM"
		Case cAlias == "NFF"
		   If cAliasSX8 == Nil
			   UserException("Invalid Use OF GetSXENum With NFF Alias")
			EndIf
		   lCampo := .F.
		   cSerie := Subs(cAliasSX8,1,3)
			nTamanho := Len(SF2->F2_DOC)
			nOrd := SF2->(IndexOrd())
			SF2->(dbSetOrder(4))
			SF2->(dbGoTop())	// Nao tirar -> Ramalho
			SF2->(dbSeek(xFilial("SF2")+"zzzzz",.T.))
			SF2->(dbSkip(-1))
			If SF2->(BoF()) .Or. SF2->F2_FILIAL+SF2->F2_SERIE != xFilial("SF2")+cSerie
			   nNum := 1
			Else
			   nNum := Val(SF2->F2_DOC) + 1
			EndIf
			cNum := StrZero(nNum,nTamanho,0)
		SF2->(dbSetOrder(nOrd))
		Case cAlias == "CPR"
			lCampo := .F.
			cProva	 := GetMv("MV_PROVA")
			aArquivos := DIRECTORY(cProva+"SP*.*")
			If Len(aArquivos) == 0
				cNum := "0001"
			Else
				aArquivos:=ASORT(aArquivos,,, { | x ,y| x[1] < y[1] } )
				cNum := StrZero(Val(Substr(aArquivos[Len(aArquivos)][1],5,4))+1,4)
			EndIf
			nTamanho := 4
		Case cAlias == "_CT"    //Numeador do CTK
			lCampo := .F.
			nRec := SM0->(Recno())
			nOrd := CTK->(IndexOrd())
			nRecno := CTK->(Recno())
			SM0->(dbSeek(cEmpAnt))
			cNum := " "
			While !SM0->(EoF()) .And. SM0->M0_CODIGO == cEmpAnt
			   cFilTrb := xFilial("CTK")
			   dbSelectArea("CTK")
			   dbSetOrder(1)
			   dbSeek(cFilTrb+"zzzzzzzzzz",.T.)
			   dbSkip(-1)
			   If CTK_FILIAL != cFilTrb .And. Empty(cNum)
			      cNum := "0000000001"
			   ElseIf cNum <= CTK->CTK_SEQUEN
			      cNum := SOMA1(CTK_SEQUEN)
			   EndIf
			   nTamanho := 10
			   If Empty(cFilTrb)
			      Exit
			   EndIf
			   SM0->(dbSkip())
			End
			SM0->(dbGoto(nRec))
			CTK->(dbSetOrder(nOrd))
			CTK->(dbGoto(nRecno))
		Case cAlias == "TRB"
			lCampo := .F.
			cNum := "00001"
			nTamanho := 5
		Case cAlias == "SSC"
			cCampo := "SC_VIAGEM"
		Case cAlias == "SS2"
			cCampo := "S2_CODIGO"
		Case cAlias == "ACF"
			cCampo := "ACF_CODIGO"
		Case cAlias == "SUA"
			cCampo := "UA_NUM"
		Case cAlias == "SUC"
			cCampo := "UC_CODIGO"
		Case cAlias == "SY6"
			cCampo := "Y6_CODLEIT"
		Case cAlias == "SY4"
			cCampo := "Y4_CODEMP"
		Case cAlias == "SY8"
			cCampo := "Y8_CODREV"
		Case cAlias == "SYA"
			cCampo := "YA_CODPECA"
		Case cAlias == "SYE"
			cCampo := "YE_CODPEnd"
		Case cAlias == "SYR"
			cCampo := "YR_CODHIST"
		Case cAlias == "SYI"
			cCampo := "YI_CODAL"
		Case cAlias == "SYC"
			cCampo := "YC_CODPLAN"
		Case cAlias == "SGJ"         //GUTEMBERG
			cCampo := "GJ_FICHA"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Arquivos do modulo de Administracao de Oficina e Veiculos	  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case cAlias == "SO8"
			cCampo := "O8_NUM"
		Case cAlias == "SO1"
			cCampo := "O1_CODIGO"
		Case cAlias == "SO2"
			cCampo := "O2_CODIGO"
		Case cAlias == "SO3"
			cCampo := "O3_CODIGO"
		Case cAlias == "SO5"
			cCampo := "O5_CODIGO"
		Case cAlias == "SV1"
			cCampo := "V1_CODIGO"
	EndCase
	If cCpoSX8 != Nil
		cCampo := cCpoSX8
	EndIf

	If lCampo
		cFilCpo := PrefixoCpo(cAlias)+"_FILIAL"
		dbSelectArea("SX3")
		dbSetOrder(2)
		dbSeek(cCampo)
		dbSetOrder(1)
		dbSelectArea(cAlias)
		nRecno := Recno()
		nOrdem := IndexOrd()
		dbSetOrder(nOrdSX8)
		cFilter := dbFilter()
		If cAlias == "SA1"
		   cMvUniao := Padr(GetMV("MV_UNIAO"),6)
		   cMvMunic := Padr(GetMV("MV_MUNIC"),6)
	       dbSelectArea(cAlias)
		   Set Filter to ( A1_COD != cMvUniao .And. A1_COD != cMvMunic)
		ElseIf ( cAlias == 'SA2' )
		   cMvUniao := Padr(GetMV("MV_UNIAO"),6)
		   cMvMunic := Padr(GetMV("MV_MUNIC"),6)
	       dbSelectArea(cAlias)
		   SET FILTER TO ( A2_COD != cMvUniao .And. A2_COD != cMvMunic)
		ElseIf cAlias == "SB1"
		   Set Filter to Subs(B1_COD,1,3) != "MOD"
		Else
		   Set Filter to
		EndIf
		dbGoTop()		// Nao tirar !!!!!!!! - Eh usado para resolver problema quando o SXE eh chamado apos o SetDummy
		dbSeek(nFilNG+'z',.T.)
		dbSkip(-1)
		dbSetOrder(nOrdem)
		If (Substr(&(cFilCpo),1,2) != nFilNG) .Or. (LastRec()==0)
			cNum := Replicate("0",TAMSX3(cCampo)[1])
		Else
			cNum := &(cCampo)
		EndIf
		dbGoTo(nRecno)
		If !Empty(cFilter)
			Set Filter to &cFilter
		Else
			SET FILTER TO
		EndIf
		cNum := Soma1(cNum)
		nTamanho := TAMSX3(cCampo)[1]

	EndIf

EndIf

If lInServer
   Return cNum
EndIf

nTrys := 0
While !LockByName("SOSXE"+cAlias)
	Inkey(3)
	nTrys++
	If nTrys > 20
		FINAL("PROBS.CRIASXE")
	EndIf
End

dbSelectArea("SXE")   //Garantir que nao existe o Registro
dbGoTop()
lFound := .F.

While !EoF()
	If XE_FILIAL+XE_ALIAS == cAliasSX8+cAlias
		lFound := .T.
		Exit
	EndIf
	dbSkip()
End

If !lFound
	While lNetErr
		dbAppEnd(.F.)
		lNetErr := NetErr()
		nTimes ++
		If nTimes > 20
			If NetCancel()
				Final( oemtoansi("Problema de GRAVACAO NO SX8") )
			Else
				nTimes := 0
			EndIf
		EndIf
		If ( lNetErr )
			Inkey( nTimes/24 )
		EndIf
	End
	MSRLock(Recno())
	Replace XE_ALIAS with cAlias, XE_TAMANHO with nTamanho,XE_FILIAL with cAliasSx8
	Replace XE_NUMERO with cNum
	dbCommit()
	MsRUnLock(Recno())
EndIf
UnLockByName("SOSXE"+cAlias)
Return cNum

//-------------------------------------------------------------------
/*/{Protheus.doc} NGCALENHORA
Calcula a quantidade de horas pelo Calendário.

@param dDINI , Date    , Data Inicial
@param hHINI , Caracter, Hora Inicial
@param dDFIM , Date    , Data Final
@param hHFIM , Caracter, Hora Final
@param cCALEN, Caracter, Código do Calendário
@param [cFIL], Caracter, Código da Filial

@obs Caso não possua a Hora Início(hHINI) e Hora Fim(hHFIM) ou seja necessário
		considerar um dia total (24:00 horas), utilizar o parâmetro
		hHINI como 00:00 e o parâmetro hHFIM como 24:00 assim o calculo será
		feito sobre um dia inteiro, considerando 24:00 horas como o total por dia.

@author Inácio Luiz Kolling
@since  10/02/2004
@version P12

@return nQTDHCAL, Numérico, Quantidade de horas do período.
/*/
//-------------------------------------------------------------------
Function NGCALENHORA(dDINI,cHINI,dDFIM,cHFIM,cCALEN,cFIL)

Local nQTDHCAL:= 0
Local nDIASE  := 0
Local XH      := 0
Local aCALENH := {}
Local cFilSH7 := NGTROCAFILI("SH7",cFIL)

dbSelectArea("SH7")
dbSetOrder(1)
If dbSeek(cFILSH7+cCALEN)
   aCALENH := NGCALENDAH(cCALEN,cFIL)
   If dDINI = dDFIM
      lPRIMH := .F.
      nDIASE := Dow(dDINI)
      lTERMI := .F.
      For XH := 1 To Len(aCALENH[nDIASE,2])
         If cHINI >= aCALENH[nDIASE,2,XH,1] .And. cHINI < aCALENH[nDIASE,2,XH,2]
            If !lPRIMH
               cHORAIN := cHINI
               lPRIMH  := .T.
            Else
               cHORAIN := aCALENH[nDIASE,2,XH,1]
            EndIf

            If aCALENH[nDIASE,2,XH,2] >= cHFIM
               cHORAFI := cHFIM
               lTERMI  := .T.
            Else
               cHORAFI := aCALENH[nDIASE,2,XH,2]
            EndIf
            nQTDHCAL := nQTDHCAL+Htom(cHORAFI)-Htom(cHORAIN)

            If lTERMI
               Exit
            EndIf
         Else
            If aCALENH[nDIASE,2,XH,1] >= cHINI .And. aCALENH[nDIASE,2,XH,2] >= cHINI

               cHORAIN := aCALENH[nDIASE,2,XH,1]
               cHORAFI := If (aCALENH[nDIASE,2,XH,2] >= cHFIM,cHFIM,;
                          aCALENH[nDIASE,2,XH,2])

               nQTDHCAL := nQTDHCAL+Htom(cHORAFI)-Htom(cHORAIN)

               If cHORAFI >= cHFIM
                  Exit
               EndIf
            EndIf
         EndIf

         If lPRIMH
            If XH < len(aCALENH[nDIASE,2])
               cHINI := aCALENH[nDIASE,2,XH+1,1]
            EndIf
         EndIf
         If cHINI > cHFIM
            Exit
         EndIf

      Next XH
   Else
      nQDIAS := (dDFIM - dDINI)+1
      nLDIAS := 1
      dLDATA := dDINI
      While nLDIAS <= nQDIAS
         nDIASE := Dow(dLDATA)
         If dLDATA = dDINI
            lPRIMH := .F.
            lTERMI := .F.
            For XH := 1 To Len(aCALENH[nDIASE,2])
               If cHINI >= aCALENH[nDIASE,2,XH,1] .And. cHINI < aCALENH[nDIASE,2,XH,2]
                  If !lPRIMH
                     lPRIMH  := .T.
                  EndIf
                  cHORAIN  := cHINI
                  cHORAFI  := aCALENH[nDIASE,2,XH,2]
                  nHORASF1 := Htom(cHORAFI)
                  nHORASI1 := Htom(cHORAIN)
                  nQTDHCAL := nQTDHCAL+Htom(cHORAFI)-Htom(cHORAIN)
               Else
                  If aCALENH[nDIASE,2,XH,1] >= cHINI .And. aCALENH[nDIASE,2,XH,2] >= cHINI
                     If !lPRIMH
                        lPRIMH  := .T.
                     EndIf
                     cHORAIN  := aCALENH[nDIASE,2,XH,1]
                     cHORAFI  := aCALENH[nDIASE,2,XH,2]
                     nHORASF1 := Htom(cHORAFI)
                     nHORASI1 := Htom(cHORAIN)
                     nQTDHCAL := nQTDHCAL+Htom(cHORAFI)-Htom(cHORAIN)
                  EndIf
               EndIf

               If lPRIMH
                  If XH < len(aCALENH[nDIASE,2])
                     cHINI := aCALENH[nDIASE,2,XH+1,1]
                  EndIf
               EndIf
               If cHINI > cHFIM .And. dLDATA = dDFIM
                  Exit
               EndIf
            Next XH
         ElseIf dLDATA = dDFIM
            lPRIMH := .F.
            lTERMI := .F.
            For XH := 1 To Len(aCALENH[nDIASE,2])
               If cHFIM >= aCALENH[nDIASE,2,XH,1] .And. cHFIM <= aCALENH[nDIASE,2,XH,2]
                  cHORAIN  := aCALENH[nDIASE,2,XH,1]
                  cHORAFI  := cHFIM
                  nQTDHCAL := nQTDHCAL+Htom(cHORAFI)-Htom(cHORAIN)
                  Exit
               Else
                  cHORAIN  := aCALENH[nDIASE,2,XH,1]
                  cHORAFI  := aCALENH[nDIASE,2,XH,2]
                  nQTDHCAL := nQTDHCAL+Htom(cHORAFI)-Htom(cHORAIN)
               EndIf
            Next XH
         Else
            nQTDHCAL := nQTDHCAL+Htom(aCALENH[nDIASE,1])
         EndIf
         dLDATA += 1
         nLDIAS += 1
      End
   EndIf

   cHORACAR := Alltrim(Mtoh(nQTDHCAL))
   nPOS2PON := AT(":",cHORACAR)

   If nPOS2PON > 0
      nHORAS1F := Substr(cHORACAR,1,(nPOS2PON-1))
      nMINUTOS := Substr(cHORACAR,(nPOS2PON+1))
      nQTDHCAL := Val(nHORAS1F+"."+nMINUTOS)
      nQTDHCAL := If(nQTDHCAL < 0,0,nQTDHCAL)
   EndIf
EndIf

Return nQTDHCAL

//----------------------------------------------------------------------
/*/{Protheus.doc} NGPNEULOTE()
Função para utilização na integração com gestão de compras MATA103.PRW
Permite inserir pneus em lote ao lançar documento de entrada

@param cSerie, String, Código da Serie inserido na tela do MATA103
@author Maria Elisandra de Paula
@since 04/11/2014
@version MP12
@return .T.
/*/
//---------------------------------------------------------------------
Function NGPNEULOTE(cSerie)

	Local nST9			:= 0
	Local nAc 			:= 0
	Local nPosCod		:= 0
	Local nPosCC		:= 0
	Local nPosQtd		:= 0
	Local nPosVUnit		:= 0
	Local nPosDoc		:= 0
	Local nPosLocal		:= 0
	Local nPosOp 		:= 0
	Local dEmisSD1 		:= dDEmissao
	Local lRet 			:= .T.
	Local lPNEULOT2		:= ExistBlock("PNEULOT2")
	Local aFuncX 		:= {}
	Local aST9 			:= {}
	Local nTamCols      := 0
	Local lIncBkp    	:= INCLUI
	Local lAltBkp     	:= ALTERA

	//------------------------------------------------------------------------------------------------------------------------
	// Esse processo de pneus em lote está sendo descontinuado pois será substituido pela nova rotina 'Pneus a partir de NF'
	//------------------------------------------------------------------------------------------------------------------------
	If FindFunction( 'MNTA085' ) .And. TQZ->( FieldPos("TQZ_NUMSEQ") ) > 0 
		Return .T.
	EndIf

	If IsInCallStack('MATA310') .Or. IsInCallStack('A103Devol')
		Return .T.
	EndIf

	If !Empty(GetNewPar("MV_NGPNGR","")) .And. Empty(GetNewPar("MV_NGSTAFG", ""))

		ShowHelpDLG(STR0176,{STR0177+STR0178},2,{STR0179},2) //"Atenção" #  "O parâmetro 'MV_NGPNGR' está configurado mas o parâmetro 'MV_NGSTAFG' ainda não foi configurado. "
																	//"Esses parâmetros são utilizados no módulo de manutenção de ativos." # "Favor configurar o parâmetro 'MV_NGSTAFG'"
		Return .F.
	EndIf

	nPosCod   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_COD"})
	nPosCC    := aScan(aHeader,{|x| AllTrim(x[2])=="D1_CC"})
	nPosQtd   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_QUANT"})
	nPosVUnit := aScan(aHeader,{|x| AllTrim(x[2])=="D1_VUNIT"})
	nPosDoc   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_DOC"})
	nPosLocal := aScan(aHeader,{|x| AllTrim(x[2])=="D1_LOCAL"})
	nPosOp    := aScan(aHeader,{|x| AllTrim(x[2])=="D1_OP"})

	Begin Transaction

		//Faz atribuição manual das variaveis para o relação dos campos da ST9 funcionarem corretamente
		INCLUI := .T.
		ALTERA := .F.

		//Coloca o parâmetro em um vetor
		If ";" $ SuperGetMV("MV_NGPNGR")
			aFuncX:= Strtokarr(Alltrim(SuperGetMV("MV_NGPNGR")) ,";")
		Else
			aFuncX := {Alltrim(SuperGetMV("MV_NGPNGR"))}
		EndIf

		For nAc:= 1  to len(aCols)
			dbSelectArea("SB1")
			dbSetOrder(1)
			If dbSeek(xFilial("SB1")+ aCols[nAc][nPosCod]) .And. aScan(aFuncX,{|x| Alltrim(x) == Alltrim(SB1->B1_GRUPO)}) > 0
				If int(aCols[nAc][nPosQtd]) >= 1 .And. Empty(aCols[nAc][nPosOp]) //Se a OP tiver preenchida nao é chamada a função de cadastrar o Pneu

					nTamCols := Len(aCols[nAc])
					If !aCols[nAc][nTamCols] //Verifica se a linha não está deletada.
						lRet := fPNEULOTE(	aCols[nAc][nPosCod]	,;
												cSerie,;
												aCols[nAc][nPosCC],;
												aCols[nAc][nPosQtd]  ,;
												aCols[nAc][nPosVUnit],;
												cNfiscal,;
												cA100For,;
												cLoja,dEmisSD1,;
												aCols[nAc][nPosLocal],;
												@aST9)
						If .Not. lRet
							Exit
						EndIf
					EndIf

				EndIf
			EndIf
		Next

		If lRet
			//Realiza a inclusão do Pneu pela classe MNTPNEU
			For nST9 := 1 to Len(aST9)
				oST9 := aST9[nST9]

				If oST9:IsValid()
					oST9:Upsert()
					If lPNEULOT2
						ExecBlock("PNEULOT2",.F.,.F.)
					EndIf
				EndIf
				oST9:Free()
			Next nST9
		Else
			If Len( aST9 ) > 0
				oST9 := aTail( aST9 )
				oST9:ShowHelp()
				oST9:Free()
			EndIf
		EndIf

		INCLUI := lIncBkp
		ALTERA := lAltBkp

	End Transaction
Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} fPNEULOTE()
Tela para inserir os produtos do grupo de pneus

@param cCodSD1 	- Código do produto
@param	nQuantSD1 	- Quantidade
@param cSerieSD1 	- Serie
@param cCustoSD1 	- Centro de Custo
@param nVUnitSD1	- Valor unitário
@param 	nDocSD1	- Doc
@param 	cFornecSD1	- Fornecedor
@param cLojaSD1	- Loja
@param 	dEmisSD1	- Data Emissao
@param 	cLocalSD1 - Local de estoque
@param 	aST9 - array de bens gerados
@author Maria Elisandra de Paula
@since 11/11/2014
@version MP12
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fPNEULOTE(cCodSD1,cSerieSD1,cCustoSD1,nQuantSD1,nVUnitSD1,cDocSD1,cFornecSD1,cLojaSD1,dEmisSD1,cLocalSD1,aST9)

	Local aItens 	:= {"1=OR","2=R1","3=R2","4=R3","5=R4"}
	Local cAliasQry := GetNextAlias()
	Local lSerie  	:= .T.
	Local lCcusto 	:= .T.
	Local lOk 		:= .F.
	Local lRet	 	:= .T.
	Local lPNEULOT2	:= ExistBlock("PNEULOT2")
	Local lMntPneu  := FindFunction("_MNTPNEU")
	Local oDlg
	Local oPanel
	Local oCodFami
	Local nQPneu 	:= 0

	Local _Inclui := Inclui //BKP pois SETOPERATION MODIFICA
	Local _Altera := Altera //BKP pois SETOPERATION MODIFICA

	//Verifica a existência dos campos TQS_TWI e TQU_TWI.
	Local lExistTwi := NGCADICBASE("TQS_TWI", "A", "TQS", .F.)

	Private oDesenho,oOr,oR1,oR2,oR3,oR4
	Private lKMOR := .T.

	Store .F. to lDESEN,lKMR1,lKMR2,lKMR3,lKMR4

 	If FindFunction("_MNTPNEU")
	 	RegToMemory("ST9",.T.)
	 	RegToMemory("TQS",.T.)
	EndIf

 	M->T9_FILIAL	:= xFilial('ST9')
 	M->T9_CODFAMI	:= Space(TamSx3("T9_CODFAMI")[1])
 	M->T9_TIPMOD 	:= Space(TamSx3("T9_TIPMOD")[1])
	M->T9_FABRICA	:= Space(TamSx3("T9_FABRICA")[1])
	If Empty(cCustoSD1)
		M->T9_CCUSTO	:= Space(TamSx3("T9_CCUSTO")[1])
	Else
		M->T9_CCUSTO	:= AllTrim(cCustoSD1)
		lCcusto := .F.
	EndIf
	M->T9_CALENDA := Space(TamSx3("T9_CALENDA")[1])
 	M->TQS_MEDIDA := Space(TamSx3("TQT_MEDIDA")[1])
	M->T9_DTGARAN := CTOD("  /  /    ")
	M->T9_PADRAO  := 'N'
	M->T9_CATBEM  := "3"
	M->T9_STATUS  := Alltrim(SuperGetMV("MV_NGSTAFG"))
	M->T9_DTCOMPR := dEmisSD1
	M->T9_ESTRUTU := "N"
	M->T9_TEMCONT := "P"
	M->T9_TPCONTA := "HODOMETRO"
	M->T9_DTULTAC := dEmisSD1
	M->T9_SERIE	  := M->D1_SERIE
	M->T9_CODESTO := AllTrim(cCodSD1)
	M->T9_LOCPAD  := cLocalSD1
	M->T9_FORNECE := cFornecSD1
	M->T9_LOJA 	  := cLojaSD1
	M->T9_VALCPA  := nVUnitSD1
	M->T9_NFCOMPR := AllTrim(cDocSD1)
	M->T9_SITMAN  := "A"
	M->T9_SITBEM  := "A"
	M->T9_MOVIBEM := "S"
	M->T9_PARTEDI := "2"

	M->TQS_FILIAL := xFilial('TQS')
 	M->TQS_DOT	  := Space(TamSx3("TQS_DOT")[1])
 	If Empty(cSerieSD1)
		M->D1_SERIE	:= Space(TamSx3("D1_SERIE")[1])
	Else
		M->D1_SERIE	:= AllTrim(cSerieSD1)
		lSerie := .F.
	EndIf
	M->TQS_DESENH := Space(TamSx3("TQS_DESENH")[1])
 	M->TQS_SULCAT := 0.0
 	M->TQS_BANDAA := Space(1)
 	M->TQS_KMOR   := 0
 	M->TQS_KMR1   := 0
 	M->TQS_KMR2   := 0
 	M->TQS_KMR3   := 0
 	M->TQS_KMR4   := 0
	M->TQS_SULCAT := M->TQS_SULCAT
	M->TQS_DTMEAT := dEmisSD1
	M->TQS_HRMEAT := SubStr(Time(),1,5)

	oDlg := FWDialogModal():New()
	oDlg:SetBackground(.T.)	 	// .T. -> escurece o fundo da janela
	oDlg:SetTitle(STR0180) // "Inclusão de Lote de Pneus"
	oDlg:SetEscClose(.F.)		//permite fechar a tela com o ESC
	oDlg:bValid := {||lOk}
	oDlg:SetSize(230,270)
	oDlg:EnableFormBar(.T.)
	oDlg:CreateDialog() //cria a janela (cria os paineis)
	oPanel := oDlg:getPanelMain()

	oDlg:createFormBar()//cria barra de botoes

		oScrollBox := TScrollBox():New(oPanel,0,0,270,230,.T.,.T.,.T.)
			oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT

		@ 10,03 Say NGRETTITULO('T9_CODESTO') Color CLR_HBLUE, CLR_WHITE Of oScrollBox Pixel
		@ 07,43 MsGet M->T9_CODESTO Picture "@!" size 40,07 When .F. Of oScrollBox Pixel

		@ 10,123 Say NGRETTITULO('T9_NOMESTQ') Color CLR_HBLUE, CLR_WHITE Of oScrollBox Pixel
		@ 07,163 MsGet NGSEEK("SB1",M->T9_CODESTO,1,"B1_DESC") Picture "@!" size 80,07 When .F. Of oScrollBox Pixel

		@ 22,03 Say NGRETTITULO('T9_CODFAMI') Color CLR_HBLUE, CLR_WHITE Of oScrollBox Pixel
		@ 19,43 MsGet oCodFami Var M->T9_CODFAMI Valid If(!Empty(M->T9_CODFAMI),ExistCpo("ST6",M->T9_CODFAMI),.T.) Picture "@!" size 40,07 F3 "ST6" Of oScrollBox Pixel HasButton

		@ 22,123 Say NGRETTITULO('T9_NOMFAMI') Color CLR_HBLUE, CLR_WHITE Of oScrollBox Pixel
		@ 19,163 MsGet NGSEEK("ST6",M->T9_CODFAMI,1,"T6_NOME") Picture "@!" size 80,07 When .F. Of oScrollBox Pixel

		@ 34,03 Say NGRETTITULO('T9_TIPMOD') Color CLR_HBLUE, CLR_WHITE Of oScrollBox Pixel
		@ 31,43 MsGet M->T9_TIPMOD Valid If(!Empty(M->T9_TIPMOD),ExistCpo("TQR",M->T9_TIPMOD),.T.) Picture "@!" size 40,07 F3 "TQR" Of oScrollBox Pixel HasButton

		@ 34,123 Say NGRETTITULO('T9_DESMOD') Color CLR_HBLUE, CLR_WHITE Of oScrollBox Pixel
		@ 31,163 MsGet NGSEEK("TQR",M->T9_TIPMOD,1,"TQR_DESMOD") Picture "@!" size 80,07 When .F. Of oScrollBox Pixel

		@ 46,03 Say NGRETTITULO('T9_FABRICA') Of oScrollBox Pixel
		@ 43,43 MsGet M->T9_FABRICA Valid If(!Empty(M->T9_FABRICA),ExistCpo("ST7",M->T9_FABRICA),.T.)  Picture "@!" size 40,07 F3 "ST7" Of oScrollBox Pixel HasButton

		@ 46,123 Say NGRETTITULO('T9_NOMFABR') Color CLR_HBLUE, CLR_WHITE Of oScrollBox Pixel
		@ 43,163 MsGet NGSEEK("ST7",M->T9_FABRICA,1,"T7_NOME") Picture "@!" size 80,07 When .F. Of oScrollBox Pixel

		@ 58,03 Say NGRETTITULO('T9_CCUSTO') Color CLR_HBLUE, CLR_WHITE Of oScrollBox Pixel
		@ 55,43 MsGet M->T9_CCUSTO Valid If(!Empty(M->T9_CCUSTO),ExistCpo("CTT",M->T9_CCUSTO),.T.) Picture "@!" size 40,07 F3 "CTT" When lCcusto Of oScrollBox Pixel HasButton

		@ 58,123 Say NGRETTITULO('T9_NOMCUST') Color CLR_HBLUE, CLR_WHITE Of oScrollBox Pixel
		@ 55,163 MsGet NGSEEK("CTT",M->T9_CCUSTO,1,"CTT_DESC01") Picture "@!" size 80,07 When .F. Of oScrollBox Pixel

		//M->T9_CALENDA
		@ 70,03 Say NGRETTITULO('T9_CALENDA') Color CLR_HBLUE, CLR_WHITE Of oScrollBox Pixel
		@ 67,43 MsGet M->T9_CALENDA Valid If(!Empty(M->T9_CALENDA),ExistCpo("SH7",M->T9_CALENDA),.T.) Picture "@!" size 40,07 F3 "SH7" Of oScrollBox Pixel HasButton

		@ 70,123 Say NGRETTITULO('T9_NOMCALE') Color CLR_HBLUE, CLR_WHITE Of oScrollBox Pixel
		@ 67,163 MsGet NGSEEK("SH7",M->T9_CALENDA,1,"H7_DESCRI") Picture "@!" size 80,07 When .F. Of oScrollBox Pixel


		@ 82,03 Say NGRETTITULO('TQS_MEDIDA') Color CLR_HBLUE, CLR_WHITE Of oScrollBox Pixel
		@ 79,43 MsGet M->TQS_MEDIDA Valid If(!Empty(M->TQS_MEDIDA),ExistCpo("TQT",M->TQS_MEDIDA),.T.) Picture "@!" size 40,07 F3 "TQT" Of oScrollBox Pixel HasButton

		@ 82,123 Say NGRETTITULO('TQS_DESBEM') Color CLR_HBLUE, CLR_WHITE Of oScrollBox Pixel
		@ 79,163 MsGet NGSEEK("TQT",M->TQS_MEDIDA,1,"TQT_DESMED") Picture "@!" size 80,07 When .F. Of oScrollBox Pixel

		@ 94,03 Say NGRETTITULO('T9_DTGARAN') Of oScrollBox Pixel
		@ 91,43 MsGet M->T9_DTGARAN Picture "99/99/9999" Valid If(!Empty(M->T9_DTGARAN),VALDATA(M->T9_DTCOMPR,M->T9_DTGARAN,"DTGARAN"),.T.) size 50,07 Of oScrollBox Pixel HasButton

		@ 94,123 Say NGRETTITULO('TQS_DOT')  Of oScrollBox Pixel
		@ 91,163 MsGet M->TQS_DOT Picture "9999" Valid Valid If(!Empty(M->TQS_DOT), MNTA080DOT() .And. M->TQS_DOT > 0 , .T. ) size 40,07 Of oScrollBox Pixel

	 	@ 106,03 Say NGRETTITULO("D1_SERIE") Of oScrollBox Pixel
		@ 103,43 MsGet oSerie Var M->D1_SERIE Picture "@!" size 20,07  When lSerie Of oScrollBox Pixel

		@ 106,123 Say NGRETTITULO("TQS_SULCAT") Color CLR_HBLUE, CLR_WHITE Of oScrollBox Pixel
		@ 103,163 MsGet M->TQS_SULCAT Picture "@E 999.99" Valid If(!Empty(M->TQS_SULCAT), M->TQS_SULCAT >= 0 , .T. ) size 40,07 Of oScrollBox Pixel HasButton

		@ 118,03 Say NGRETTITULO("TQS_BANDAA") Of oScrollBox Pixel
		@ 115,43 Combobox oComb Var M->TQS_BANDAA Items aItens size 40,07 Of oScrollBox ;
			Valid ChangeBand(oDesenho,oOr,oR1,oR2,oR3,oR4) .And. PERTENCE('12345') .And. MNT80BANDA() Pixel

		@ 118,123 Say NGRETTITULO("TQS_DESENH") Of oScrollBox Pixel
		@ 115,163 MsGet oDesenho Var M->TQS_DESENH Valid If(!Empty(M->TQS_DESENH),(ExistCpo("TQU",M->TQS_DESENH), fGatTwi(M->TQS_DESENH, lExistTwi)),.T.) Picture "@!" size 40,07 F3 "TQU" When lDESEN Of oScrollBox Pixel HasButton

		@ 130,03 Say NGRETTITULO("TQS_KMOR") Of oScrollBox Pixel
		@ 127,43 MsGet oOr Var M->TQS_KMOR Picture "@E 999999999" Valid If(!Empty(M->TQS_KMOR), M->TQS_KMOR >= 0 , .T. ) size 40,07 When lKMOR  Of oScrollBox Pixel

		@ 130,123 Say NGRETTITULO("TQS_KMR1") Of oScrollBox Pixel
		@ 127,163 MsGet oR1 Var M->TQS_KMR1 Picture "@E 999999999" Valid If(!Empty(M->TQS_KMR1), M->TQS_KMR1 >= 0 , .T. ) size 40,07 When lKMR1 Of oScrollBox Pixel

		@ 142,03 Say NGRETTITULO("TQS_KMR2") Of oScrollBox Pixel
		@ 139,43 MsGet oR2 Var M->TQS_KMR2 Picture "@E 999999999" Valid If(!Empty(M->TQS_KMR2), M->TQS_KMR2 >= 0 , .T. ) size 40,07 When lKMR2 Of oScrollBox Pixel

		@ 142,123 Say NGRETTITULO("TQS_KMR3") Of oScrollBox Pixel
		@ 139,163 MsGet oR3 Var M->TQS_KMR3 Picture "@E 999999999" Valid If(!Empty(M->TQS_KMR3), M->TQS_KMR3 >= 0 , .T. ) size 40,07 When lKMR3 Of oScrollBox Pixel

		@ 154,03 Say NGRETTITULO("TQS_KMR4") Of oScrollBox Pixel
		@ 151,43 MsGet oR4 Var M->TQS_KMR4 Picture "@E 999999999" Valid If(!Empty(M->TQS_KMR4), M->TQS_KMR4 >= 0 , .T. ) size 40,07 When lKMR4 Of oScrollBox Pixel
		If lExistTwi
			@ 154,123 Say NGRETTITULO("TQS_TWI") Of oScrollBox Pixel
			@ 151,163 MsGet M->TQS_TWI Picture "@E 999.99" Valid MNT096TWI(M->TQS_TWI) size 40,07 Of oScrollBox Pixel HasButton
		EndIf

		oDlg:AddButton( 'Confirmar'	,{|| If(fObrigOk(),(lOk := .T. ,oDlg:Deactivate()),.F.)}, 'Confirmar' , , .T., .F., .T., )

		oDlg:bInit := {||oCodFami:SetFocus()}

		nLinUlt := 151
		nColUlt := 43

		If ExistBlock("PNEULOT1")
			ExecBlock("PNEULOT1",.F.,.F.,{oScrollBox,nLinUlt,nColUlt})
		EndIf

	oDlg:activate()

	// Atribui
	M->T9_CODBEM := If( !lMntPneu .Or. Empty(aST9), RetNumBem(), Soma1Old( aTail( aST9 ):getValue("T9_CODBEM") ))
	If Empty(M->T9_CODBEM)
		M->T9_CODBEM := fInformaCod()
	EndIf

	For nQPneu := 1 to int(nQuantSD1)
		//verifica se existe registro de pneu senão mostra tela para informar código do primeiro registro

		If nQPneu > 1
			M->T9_CODBEM := Soma1Old(M->T9_CODBEM)
		EndIf
		M->T9_LIMICON := 999999999
		M->TQS_CODBEM := M->T9_CODBEM
		M->TQS_NUMFOG := M->T9_CODBEM
		M->T9_NOME := NGSEEK("SB1",M->T9_CODESTO,1,"B1_DESC")
		M->T9_POSCONT   := M->TQS_KMOR+M->TQS_KMR1+M->TQS_KMR2+M->TQS_KMR3+M->TQS_KMR4
		M->T9_CONTACU   := M->TQS_KMOR+M->TQS_KMR1+M->TQS_KMR2+M->TQS_KMR3+M->TQS_KMR4
		M->T9_SERIE		:= cSerie
		//Verifica se a classe MNTPNEU está liberada no RPO,
		//realizando o processo pela classe e não manualmente
		If lMntPneu
			oST9 := MntPneu():New
			oST9:SetOperation(3)
			oST9:MemoryToClass()
			oST9:Valid()
			aAdd(aST9,oST9)

			If .Not. oST9:IsValid()
				lRet := .F.
				Exit
			EndIf

		Else

			dbSelectArea("ST9")
			dbSetOrder()
			RecLock("ST9", .T.)
			ST9->T9_FILIAL	:= xFilial("ST9")
			ST9->T9_CODBEM	:= M->T9_CODBEM
			ST9->T9_TIPMOD	:= M->T9_TIPMOD
			ST9->T9_FABRICA	:= M->T9_FABRICA
			ST9->T9_CODFAMI	:= M->T9_CODFAMI
			ST9->T9_PADRAO	:= M->T9_PADRAO
			ST9->T9_CATBEM	:= M->T9_CATBEM
			ST9->T9_NOME 	:= M->T9_NOME
			ST9->T9_STATUS 	:= M->T9_STATUS
			ST9->T9_CCUSTO	:= M->T9_CCUSTO
			ST9->T9_CALENDA := M->T9_CALENDA
			ST9->T9_DTCOMPR := M->T9_DTCOMPR
			ST9->T9_ESTRUTU	:= M->T9_ESTRUTU
			ST9->T9_TEMCONT	:= M->T9_TEMCONT
			ST9->T9_TPCONTA	:= M->T9_TPCONTA
			ST9->T9_LIMICON := M->T9_LIMICON
			ST9->T9_POSCONT := M->T9_POSCONT
			ST9->T9_CONTACU := M->T9_CONTACU
			ST9->T9_DTULTAC	:= M->T9_DTULTAC
			ST9->T9_SERIE	:= M->T9_SERIE
			ST9->T9_CODESTO	:= M->T9_CODESTO
			ST9->T9_FORNECE := M->T9_FORNECE
			ST9->T9_LOJA 	:= M->T9_LOJA
			ST9->T9_VALCPA 	:= M->T9_VALCPA
			ST9->T9_NFCOMPR := M->T9_NFCOMPR
			ST9->T9_SITMAN 	:= M->T9_SITMAN
			ST9->T9_SITBEM 	:= M->T9_SITBEM
			ST9->T9_MOVIBEM := M->T9_MOVIBEM
			ST9->T9_PARTEDI := M->T9_PARTEDI
			MsUnlock()
			//------------

			dbSelectArea("TQS")
			dbSetOrder(1)
			RecLock("TQS", .T.)

			TQS->TQS_FILIAL := xFilial("TQS")
			TQS->TQS_CODBEM := M->T9_CODBEM
			TQS->TQS_MEDIDA	:= M->TQS_MEDIDA
			TQS->TQS_NUMFOG := M->TQS_NUMFOG
			TQS->TQS_SULCAT	:= M->TQS_SULCAT
			TQS->TQS_DTMEAT	:= M->TQS_DTMEAT
			TQS->TQS_HRMEAT	:= M->TQS_HRMEAT
			TQS->TQS_BANDAA	:= M->TQS_BANDAA
		 	TQS->TQS_DESENH	:= M->TQS_DESENH
			TQS->TQS_KMOR 	:= M->TQS_KMOR
		 	TQS->TQS_KMR1	:= M->TQS_KMR1
		 	TQS->TQS_KMR2	:= M->TQS_KMR2
		 	TQS->TQS_KMR3	:= M->TQS_KMR3
		 	TQS->TQS_KMR4	:= M->TQS_KMR4
		 	TQS->TQS_DOT	:= M->TQS_DOT  //semana e ano de fabricacao
			If lExistTwi .And. M->TQS_BANDAA != "1"
				TQS->TQS_TWI :=  MNTMinTwi(M->TQS_DESENH)
			EndIf
			MsUnlock()

			/*
			//Parametros
			cVBEM   - C¢digo do bem                        - Obrigat¢rio
			nVCONT  - Valor do contador                    - Obrigat¢rio
			nVVARD  - Valor da varia‡Æo dia                - Obrigat¢rio
			dVDLEIT - Data da leitura                      - Obrigat¢rio
			nVACUM  - Valor do contador acumulado          - Obrigat¢rio
			nVIRACO - N£mero de viradas ia                 - Obrigat¢rio
			cVHORA  - Hora do lancamento                   - Obrigat¢rio
			nTIPOC  - Tipo do contador ( 1/2 )             - Obrigat¢rio
			cTIPOL  - Tipo de lancamento                   - Obrigat¢rio
			cFIHIS  - Codigo da filial do historico        - Obrigat¢rio
			cFICON  - Codigo da filial do contador
			*/


			//Gera registro de historico ( STP )
			NGGRAVAHIS(M->T9_CODBEM,ST9->T9_POSCONT,0,dEmisSD1,ST9->T9_CONTACU,0,SubStr(TIME(),1,5),1,"I",xFilial("ST9"))


		   If !NGIfDBSEEK('TPN',M->T9_CODBEM,1)
		      RecLock("TPN",.T.)
		      TPN->TPN_FILIAL := xFILIAL("TPN")
		      TPN->TPN_CODBEM := M->T9_CODBEM
		      TPN->TPN_DTINIC := dDATABASE
		      TPN->TPN_HRINIC := SubStr(Time(),1,5)
		      TPN->TPN_CCUSTO := M->T9_CCUSTO
		      TPN->TPN_CTRAB  := ""
		      TPN->TPN_UTILIZ := "U"
		      TPN->TPN_POSCON := ST9->T9_POSCONT
		      TPN->TPN_POSCO2 := ST9->T9_POSCONT
		      MsUnLock("TPN")
			EndIf

			//------------------------------------------------------------------
			// Grava histórico de sulco do pneu
			//------------------------------------------------------------------
			DBSelectArea( 'TQV' )
			DBSetOrder( 1 )
			DBSeek( xFilial("TQV") + M->T9_CODBEM + DToS( M->TQS_DTMEAT ) + M->TQS_HRMEAT + M->TQS_BANDAA  )
			If .Not. TQV->( Found() )
				RecLock( 'TQV' , .T. )
				TQV->TQV_FILIAL := xFilial("TQV")
				TQV->TQV_CODBEM := M->T9_CODBEM
				TQV->TQV_DTMEDI := M->TQS_DTMEAT
				TQV->TQV_HRMEDI := M->TQS_HRMEAT
				TQV->TQV_BANDA  := M->TQS_BANDAA
				TQV->TQV_DESENH := M->TQS_DESENH
			Else
				RecLock( 'TQV' , .F. )
			EndIf
			TQV->TQV_SULCO  := M->TQS_SULCAT
			MsUnLock( 'TQV' )

			//------------------------------------------------------------------
			// Grava histórico de status do pneu
			//------------------------------------------------------------------
			DBSelectArea( 'TQZ' )
			DBSetOrder( 1 )
			DBSeek( xFilial("TQZ") + M->T9_CODBEM + DToS( M->TQS_DTMEAT ) + M->TQS_HRMEAT + M->T9_STATUS )
			If .Not. TQZ->( Found() )
				RecLock( 'TQZ' , .T. )
				TQZ->TQZ_FILIAL := xFilial("TQZ")
				TQZ->TQZ_CODBEM := M->T9_CODBEM
				TQZ->TQZ_DTSTAT := M->TQS_DTMEAT
				TQZ->TQZ_HRSTAT := M->TQS_HRMEAT
				TQZ->TQZ_STATUS := M->T9_STATUS
				TQZ->TQZ_PRODUT := M->T9_CODESTO
				TQZ->TQZ_ALMOX  := M->T9_LOCPAD
			Else
				RecLock( 'TQZ' , .F. )
			EndIf
			TQZ->TQZ_PRODUT := M->T9_CODESTO
			TQZ->TQZ_ALMOX  := M->T9_LOCPAD
			MsUnLock( 'TQZ' )
			If lPNEULOT2
				ExecBlock("PNEULOT2",.F.,.F.)
			EndIf
		EndIf

	Next nQPneu

	Inclui := _Inclui  //restaura variavel pois SETOPERATION MODIFICA
	Altera := _Altera  //restaura variavel pois SETOPERATION MODIFICA

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} RetNumBem()
Retorna o código do pneu para seguir sequencia de cadastro de bens

@author Maria Elisandra de Paula
@since 04/11/2014
@version MP12
@return .T.
/*/
//---------------------------------------------------------------------
Static Function RetNumBem()

    Local cProxCodBem := ""
	Local cAliasQry   := GetNextAlias()
    Local cDuplST9    := AllTrim(GetNewPar("MV_NGDPST9",""))

	cQuery := " SELECT MAX(T9_CODBEM) AS T9_CODBEM FROM " + RetSqlName( "ST9" ) + " ST9 WHERE D_E_L_E_T_ = ' ' "
	cQuery += "  AND T9_CATBEM = '3' "
    If cDuplST9 == "0"
        cQuery += " AND T9_FILIAL =  '" + xFilial("ST9")+ "'"
    EndIf

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	dbSelectArea(cAliasQry)
	dbGotop()
	If !Empty((cAliasQry)->T9_CODBEM)
		cProxCodBem :=  Alltrim((cAliasQry)->T9_CODBEM)
		cProxCodBem := Soma1OLD(cProxCodBem)
	EndIf

	(cAliasQry)->(dbCloseArea())
Return cProxCodBem

//----------------------------------------------------------------------
/*/{Protheus.doc} ChangeBand()
Define cor do texto da banda

@param oDesenho,oOr,oR1,oR2,oR3,oR4 (Objetos referente a pneus)
@author Maria Elisandra de Paula
@since 04/11/2014
@version MP12
@return .T.
/*/
//---------------------------------------------------------------------
Static Function ChangeBand(oDesenho,oOr,oR1,oR2,oR3,oR4)

	oDesenho:nClrText := CLR_BLACK
	oOr:nClrText := CLR_BLACK
	oR1:nClrText := CLR_BLACK
	oR2:nClrText := CLR_BLACK
	oR4:nClrText := CLR_BLACK

	//{"1=OR","2=R1","3=R2","4=R3","5=R4"}
	If M->TQS_BANDAA <> "1"
		oDesenho:nClrText := CLR_HBLUE
	EndIf

	If M->TQS_BANDAA == "2"
		oR1:nClrText := CLR_HBLUE
	ElseIf M->TQS_BANDAA == "3"
		oR2:nClrText := CLR_HBLUE
	ElseIf M->TQS_BANDAA == "4"
		oR3:nClrText := CLR_HBLUE
	ElseIf M->TQS_BANDAA == "5"
		oR4:nClrText := CLR_HBLUE
	EndIf


Return .T.
//----------------------------------------------------------------------
/*/{Protheus.doc} fObrigOk()
Valida campos obrigatórios

@author Maria Elisandra de Paula
@since 04/11/2014
@version MP12
@return .T.
/*/
//---------------------------------------------------------------------

Static Function fObrigOk()

	Local lRetObr := .T.
	Local cCampoVazio

	If Empty(M->T9_TIPMOD)
		cCampoVazio := "T9_TIPMOD"
	ElseIf	Empty(M->T9_CODFAMI)
		cCampoVazio := "T9_CODFAMI"
	ElseIf	Empty(M->T9_CCUSTO)
		cCampoVazio := "T9_CCUSTO"
	ElseIf Empty(M->T9_CALENDA)
		cCampoVazio := "T9_CALENDA"
	ElseIf	Empty(M->TQS_MEDIDA)
		cCampoVazio := "TQS_MEDIDA"
	//ElseIf Empty(M->TQS_DOT)
	//	cCampoVazio := "TQS_DOT"
	ElseIf	Empty(M->TQS_SULCAT)
 	 	cCampoVazio := "TQS_SULCAT"
	ElseIf M->TQS_BANDAA != "1"
 		If M->TQS_BANDAA == "2" .And. Empty(M->TQS_KMR1)
			cCampoVazio := "TQS_KMR1"
		ElseIf	M->TQS_BANDAA == "3" .And. Empty(M->TQS_KMR2)
			cCampoVazio := "TQS_KMR2"
 		ElseIf	M->TQS_BANDAA == "4" .And. Empty(M->TQS_KMR3)
			cCampoVazio := "TQS_KMR3"
 		ElseIf	M->TQS_BANDAA == "5" .And. Empty(M->TQS_KMR4)
			cCampoVazio := "TQS_KMR4"
		ElseIf	Empty(M->TQS_DESENH)
			cCampoVazio := "TQS_DESENH"
 		EndIf
	//ElseIf  Empty(M->TQS_KMOR)
		//cCampoVazio := "TQS_KMOR"
	EndIf

	If !Empty(cCampoVazio)
		lRetObr := .F.
		HELP(" ",1,"OBRIGAT",,CHR(13)+cCampoVazio+Space(35),3)
	EndIf

Return lRetObr
//----------------------------------------------------------------------
/*/{Protheus.doc} fInformaCod()
Apresenta tela para informar nome do primeiro pneu

@author Maria Elisandra de Paula
@since 04/12/2014
@version MP12
@return
/*/
//---------------------------------------------------------------------
Static function fInformaCod()

	Local oDlg ,oPanel, oMensag
	Local cProxNum 	:= ""

	Local cMens1	:= STR0183+STR0184+STR0185

	M->T9_CODBEM := Space(TamSx3("T9_CODBEM")[1])

	Define Font oFontB Name "Arial" Size 07,15 bold //altura,largura letra 9,13
	oDlg := FWDialogModal():New()
		oDlg:SetBackground(.T.)	 	// .T. -> escurece o fundo da janela
		oDlg:SetTitle("")
		oDlg:SetEscClose(.F.)		//permite fechar a tela com o ESC
		oDlg:SetSize(90,190) 		//altura,largura
		oDlg:EnableFormBar(.T.)

		oDlg:CreateDialog() //cria a janela (cria os paineis)
		oDlg:createFormBar()//cria barra de botoes
		oPanel := oDlg:getPanelMain()


		@ 10,03 Say oMensag Var cMens1 Font oFontB size 185,60 Of oPanel  Pixel

		@ 50,03 MsGet M->T9_CODBEM  Picture "@!" size 70,07 Of oPanel Pixel

		oDlg:AddButton( 'Confirmar'	,{|| If(!Empty(M->T9_CODBEM),If(Empty(cProxNum := RetNumBem()),(ExistChav("ST9",M->T9_CODBEM) .And. oDlg:Deactivate()),;
											(MsgAlert(STR0181),oDlg:Deactivate())),MsgAlert(STR0182))},	'Confirmar' , , .T., .F., .T., )//"Foi inserido um pneu no banco de dados neste período, desta forma, será considerado o código já cadastrado."
																																				//"Favor informar o código do Pneu para continuar com o processo."
	oDlg:Activate()

	If !Empty(cProxNum)
		M->T9_CODBEM := cProxNum
	EndIf

Return M->T9_CODBEM

//------------------------------------------------------------------------------
/*/{Protheus.doc} fGatTwi
Busca valor TWi cadastrado no desenho informado para o pneu.

@author  Eduardo Mussi
@since	 25/10/2017
@version P12
@param 	 cDesenho - Desenho do Pneu
		 lExist	  - Se existe o Campo TWI - Obrigatório
/*/
//------------------------------------------------------------------------------
Static Function fGatTwi(cDesenho, lExist)

	Default lExist	 :=  .F.

	If lExist
		M->TQS_TWI := MNTMinTwi(cDesenho)
	EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MNTALTATF
Caso centro de custo do bem cadastrado pelo Ativo fixo estiver vazio,
faz repasse do centro de custo informado no bem MNT

@author  Eduardo Mussi
@since   21/05/2019
@version P12
@param   cCodiMob    , Caracter, Código do ativo
@param   cCost       , Caracter, Centrod de custo MNT
@return  aRet, aRet[1] Caso encontre algum problema retorna Falso
			   aRet[2] Retorna erro encontrado
/*/
//-------------------------------------------------------------------
Function MNTALTATF( cCodiMob, cCost )

	Local aArea  := GetArea()
	Local aItens := {}
	Local aCab   := {}
	Local aRet   := { .T., '' }
	Local cError := ''

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	// Pesquisa pelo Ativo
	SN1->( DbSetOrder( 1 ) ) // N1_FILIAL+N1_CBASE+N1_ITEM
	If SN1->( DbSeek( xFilial( 'SN1' ) + cCodiMob ) )

		// Preenche dados necessários conforme exemplo disponibilizado no TDN.
		aAdd( aCab, { 'N1_CBASE'  , SN1->N1_CBASE  , NIL } )
		aAdd( aCab, { 'N1_ITEM'   , SN1->N1_ITEM   , NIL } )
		aAdd( aCab, { 'N1_AQUISIC', SN1->N1_AQUISIC, NIL } )
		aAdd( aCab, { 'N1_DESCRIC', SN1->N1_DESCRIC, NIL } )
		aAdd( aCab, { 'N1_QUANTD' , SN1->N1_QUANTD , NIL } )
		aAdd( aCab, { 'N1_CHAPA'  , SN1->N1_CHAPA  , NIL } )
		aAdd( aCab, { 'N1_PATRIM' , SN1->N1_PATRIM , NIL } )
		aAdd( aCab, { 'N1_GRUPO'  , SN1->N1_GRUPO  , NIL } )

		// Pesquisa saldos e valores do Ativo
		SN3->( DbSetOrder( 1 ) ) // N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
		If SN3->( DbSeek( xFilial( 'SN3' ) + cCodiMob ) ) .And. SN3->N3_CUSTBEM != cCost

			// Preenche itens necessários conforme exemplo disponibilizado no TDN.
			aAdd( aItens, { { 'N3_CBASE'  , SN3->N3_CBASE, NIL } ,;
							{ 'N3_ITEM'   , SN3->N3_ITEM , NIL } ,;
							{ 'N3_TIPO'   , SN3->N3_TIPO , NIL } ,;
							{ 'N3_BAIXA'  , SN3->N3_BAIXA, NIL } ,;
							{ 'N3_SEQ'    , SN3->N3_SEQ  , NIL } ,;
							{ 'N3_CUSTBEM', cCost        , NIL } } )

			Begin Transaction

				// Executa ATFA012 para atualizar o CC
				MSExecAuto( { |x,y,z| ATFA012( x, y, z ) }, aCab, aItens, 4 )

				If lMsErroAuto
					If !IsBlind()
						MostraErro()
						aRet[1] := .F.
					Else
						cError := MostraErro( GetSrvProfString('Startpath','' ) ) // Armazena mensagem de erro na raíz.
						//Array contendo o resultado do MostraErro
						aRet := { .F., cError }
					EndIf
				EndIf

			End Transaction
		EndIf

	EndIf

	RestArea( aArea )

Return aRet

//----------------------------------------------------------------------
/*/{Protheus.doc} NgFilTQ2()
Retorna a filial do Bem no periodo solicitado.

@param cBem     - Código do bem    - Obrigatório
@param dDData   - Data da consulta - Obrigatório
@param cHora    - Hora da consulta - Obrigatório

@author Tainã Alberto Cardoso
@since 10/07/2019
@version MP12
@return .t.
/*/
//---------------------------------------------------------------------
Function NgFilTQ2(cBem,dData,cHora)

	Local cFilTQ2  := cFilAnt

	Local cAliasTQ2 := GetNextAlias()
	Local cDtHr := DtoS(dData) + cHora

	BeginSQL Alias cAliasTQ2

		SELECT TQ2_FILDES, TQ2_DATATR, TQ2_HORATR
		FROM %table:TQ2%
			WHERE	TQ2_CODBEM = %exp:cBem%
				AND TQ2_DATATR || TQ2_HORATR <= %exp:cDtHr%
				AND %NotDel%
				ORDER BY TQ2_DATATR, TQ2_HORATR
	EndSQL

	While !EoF()
		If DtoS(dData) > (cAliasTQ2)->TQ2_DATATR
			cFilTQ2 := (cAliasTQ2)->TQ2_FILDES
		ElseIf DtoS(dData) == (cAliasTQ2)->TQ2_DATATR .And. cHora >= (cAliasTQ2)->TQ2_HORATR
			cFilTQ2 := (cAliasTQ2)->TQ2_FILDES
		EndIf
		DbSelectArea(cAliasTQ2)
		DbSkip()
	End

	dbCloseArea(cAliasTQ2)

Return cFilTQ2

//----------------------------------------------------------------------
/*/{Protheus.doc} MNTINTSD1
Integração com NF SD1

@param nOpc, numérico, operação (5=Exclusão de NF; 6=Devolução de Compra)
@param cOrigem, string, fonte que aciona a função

@author Maria Elisandra de Paula
@since 15/09/20
@return boolean, se passou pela validação
/*/
//---------------------------------------------------------------------
Function MNTINTSD1( nOpc, cOrigem )

	Local aAreaSd1 := SD1->( GetArea() )
	Local lRet     := .T.

	If TQZ->( FieldPos("TQZ_NUMSEQ") ) > 0

		If nOpc == 5 .And. cOrigem == 'MATA103' // acionado na exclusão de NF
			lRet := fVldExcSd1()
		ElseIf nOpc == 6 .And. cOrigem == 'MATV410A' // acionado no pedido de vendas
			lRet := fVldDevSd1()
		EndIf

	EndIf

	RestArea( aAreaSd1 )

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} fVldExcSd1
Exclui pneus ao excluir uma NF SD1

@author Maria Elisandra de Paula
@since 15/09/20
@return boolean, se passou pela validação
/*/
//---------------------------------------------------------------------
Static Function fVldExcSd1()

	Local nIndex     := 0
	Local cAliasQry  := ''
	Local lRet       := .T.
	Local nDoc       := aScan(aHeader,{|x| AllTrim(x[2])=='D1_DOC'})
	Local nCod       := aScan(aHeader,{|x| AllTrim(x[2])=='D1_COD'})
	Local nItem      := aScan(aHeader,{|x| AllTrim(x[2])=='D1_ITEM'})
	Local cHelp      := ''
	Local oModelPneu

	For nIndex := 1 to Len( aCols )

		dbSelectArea('SD1')
		dbSetOrder(1) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
		If dbSeek( xFilial('SD1') + aCols[nIndex,nDoc] + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA + aCols[nIndex,nCod] + aCols[nIndex,nItem] )

			cAliasQry := GetNextAlias()

			BeginSQL Alias cAliasQry
				SELECT DISTINCT( TQZ.TQZ_CODBEM ) 
				FROM %table:TQZ% TQZ
				WHERE TQZ.TQZ_FILIAL = %xFilial:TQZ%
					AND TQZ.TQZ_NUMSEQ = %exp:SD1->D1_NUMSEQ%
					AND TQZ.TQZ_ORIGEM = 'SD1'
					AND TQZ.%NotDel%
				ORDER BY TQZ_CODBEM
			EndSQL

			While !(cAliasQry)->(EoF())

				dbSelectArea('ST9')
				dbSetOrder(1)
				If dbSeek( xFilial('ST9') + (cAliasQry)->TQZ_CODBEM )

					//----------------------
					// Exclusão de pneus
					//----------------------

					oModelPneu := FWLoadModel( 'MNTA083' )
					oModelPneu:SetOperation(5)
					lRet := oModelPneu:Activate() .And. oModelPneu:VldData() .And. oModelPneu:CommitData()

					If !lRet
						cHelp := STR0197   +  ' ' +  Alltrim( (cAliasQry)->TQZ_CODBEM )  //"Esta nota fiscal não pode ser excluída pois possui vínculo com o pneu"
						cHelp += CRLF + CRLF
						cHelp += oModelPneu:GetErrorMessage()[6]

						HELP( ' ', 1, STR0002,, cHelp,2, 0 ) // "NAO CONFORMIDADE"

						Exit

					EndIf
				EndIf

				If ValType( oModelPneu ) == 'O' .And. oModelPneu:IsActive()
					oModelPneu:Deactivate()
					oModelPneu:Destroy()
					oModelPneu := Nil
				EndIf

				(cAliasQry)->( dbSkip() )

			EndDo

			(cAliasQry)->( dbCloseArea() )

		EndIf

	Next nIndex

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} fVldDevSd1
Validação na devolução de uma NF de compra SD1

@author Maria Elisandra de Paula
@since 15/09/20
@return boolean, se passou pela validação
/*/
//---------------------------------------------------------------------
Static Function fVldDevSd1()

	Local lRet      := .T.
	Local nIndex    := 0
	Local nNFOri    := aScan(aHeader,{|x| AllTrim(x[2])=='C6_NFORI'})
	Local nSeriOri  := aScan(aHeader,{|x| AllTrim(x[2])=='C6_SERIORI'})
	Local nItemOri  := aScan(aHeader,{|x| AllTrim(x[2])=='C6_ITEMORI'})
	Local nProduto  := aScan(aHeader,{|x| AllTrim(x[2])=='C6_PRODUTO'})
	Local cAliasQry := ''
	Local cHelp     := ''

	For nIndex := 1 To Len( aCols )

		dbSelectArea('SD1')
		dbSetOrder(1) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
		If dbSeek( xFilial('SD1') + aCols[nIndex,nNFOri] +  aCols[nIndex,nSeriOri] + M->C5_CLIENTE + M->C5_LOJACLI + ;
			aCols[nIndex,nProduto] + aCols[nIndex,nItemOri] )
			
			cAliasQry := GetNextAlias()

			BeginSQL Alias cAliasQry
				SELECT DISTINCT( TQZ.TQZ_CODBEM )
				FROM %table:TQZ% TQZ
				JOIN %table:ST9% ST9
					ON ST9.T9_FILIAL = %xFilial:ST9%
					AND ST9.T9_CODBEM = TQZ.TQZ_CODBEM
					AND ST9.T9_SITBEM = 'A'
					AND ST9.%NotDel%
				WHERE TQZ.TQZ_FILIAL = %xFilial:TQZ%
					AND TQZ.TQZ_NUMSEQ = %exp:SD1->D1_NUMSEQ%
					AND TQZ.TQZ_ORIGEM = 'SD1'
					AND TQZ.%NotDel%
				ORDER BY TQZ_CODBEM
			EndSQL

			While !(cAliasQry)->(EoF())

				cHelp+= (cAliasQry)->TQZ_CODBEM + CRLF

				(cAliasQry)->( dbSkip() )

			EndDo

			(cAliasQry)->( dbCloseArea() )

		EndIf

	Next nIndex

	If !Empty( cHelp )
		cHelp := STR0199  + CRLF + CRLF ; // "A nota fiscal de origem possui vínculo com pneus ativos."
			+ cHelp
		
		HELP( ' ', 1, STR0176,, cHelp,2, 0,,,,,, { STR0198 } ) //'É necessário inativá-los para prosseguir com o processo de devolução da nota' #"NAO CONFORMIDADE"
		lRet := .F.

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTLoteDE
Cria e Deleta lote de pneus de um Documento de Entrada.
@type function
@param cSerie, String, Traz o código da série colocada em tela
@param l103Inclui, Lógico, Se está incluindo
@param l103Exclui, Lógico, Se está Deletando

@author Cauê Girardi Petri
@since 09/02/23
/*/
//---------------------------------------------------------------------

Function MNTLoteDE(cSerie, l103Inclui, l103Exclui)

Local cAliST9
Local cQuery 	:= ''
Local cMarFog	:= SuperGetMV( 'MV_NGSTAFG', .T., '05' )
Local lRet		:= .T.
Local oSt9
Local oStatement

// Integracao com SIGAMNT - NG Informatica
If  l103Inclui .And. ;
	SuperGetMV("MV_NGMNTES", .T., 'N') == 'S' .And. ; // Verifica se o Manutencao de Ativos esta integrado com Estoque
	!Empty(SuperGetMV("MV_NGPNGR",.T.,'01')) // Verifica se o parametro MV_NGPNGR esta configurado (desta forma sera obrigatorio o preenchimento de dados dos pneus)
	
	NGPNEULOTE(cSerie)

EndIf

If l103Exclui

	cAliSt9 := GetNextAlias()

	oStatement := FWPreparedStatement():New()

	cQuery := "SELECT T9_FILIAL, T9_CODBEM, T9_STATUS FROM " + RetSQLName( 'ST9' )
	cQuery += " WHERE 	T9_SERIE	= ?"
	cQuery += " AND		T9_NFCOMPR 	= ?"
	cQuery += " AND		T9_FORNECE	= ?"
	cQuery += " AND		T9_LOJA		= ?"
	cQuery += " AND 	D_E_L_E_T_	= ''"

	oStatement:SetQuery(cQuery)
	oStatement:SetString( 1, cSerie			 )
	oStatement:SetString( 2, SD1->D1_DOC 	 )
	oStatement:SetString( 3, SD1->D1_FORNECE )
	oStatement:SetString( 4, SD1->D1_LOJA 	 )

	cQuery := oStatement:GetFixQuery()

	MPSysOpenQuery( cQuery, cAliSt9 )

	Begin Transaction

		While !Eof()

			DbSelectArea('ST9')
			DbSetOrder(1)
			If DbSeek( ( cAliSt9 )->T9_FILIAL + ( cAliSt9 )->T9_CODBEM )
			
				If ( cAliSt9 )->T9_STATUS == cMarFog

					oST9 := MntPneu():New
					oST9:SetOperation(5)
					oST9:Valid()
					oST9:Delete()

				Else

					//'Atenção' , 'Só pode ser deletado pneus aguardando marcação de fogo'
					Help(" ",1,"NGATENCAO",,STR0221 ,3,1)

					lRet := .F.

					DisarmTransaction()

					Break

				EndIf

			EndIf

			( cAliSt9 )->( DbSkip() )

		End

	End Transaction

	( cAliSt9 )->( dbCloseArea() )
	
EndIf

Return lRet

//------------------------------------------------------------------------------------
/*/{Protheus.doc} MNT261PNEU
Realiza operações vinculadas a rotina mata261

@author Maria Elisandra de Paula
@since 23/05/2023

@param cAction, string, local qua a função foi acionada
@param aTiresMnt, array, [1]Pneus selecionados para transferencia
						[2] recno da SD3
@param aHeader, array, cabeçalho da getdados
@param aCols, array, informações da getdados
@param nPosic, numerico, posição do item selecionado

@obs o retorno da função será de acordo com o action id:
	ACTION_BUTTON, array, pneus marcados pelo usuário
	DESC_BUTTON, string, descrição para o botão
	COMMIT, nulo
	REVERSAL_VALID, boolean, se a transferência pode ser estornada
	REVERSAL, nulo
	TUDOOK_VALID, boolean, se a transferência pode ser incluída

/*/
//------------------------------------------------------------------------------------
Function MNT261PNEU( cAction, aTiresMnt, aHeader, aCols, nPosic )

	Local xRet

	Do Case

		Case cAction == 'ACTION_BUTTON'

			xRet := f261Selec( @aTiresMnt[1], aHeader, aCols, nPosic )

		Case cAction == 'DESC_BUTTON'

			xRet := 'Selecionar Pneus [F7]'

		Case cAction == 'COMMIT'

			f261Grava( aTiresMnt, aHeader, aCols )

		Case cAction == 'REVERSAL'

			f261Estorn( aHeader, aCols )

		Case cAction == 'REVERSAL_VALID'

			xRet := f261ValEst( aHeader, aCols )

		Case cAction == 'TUDOOK_VALID'

			xRet := f261TudoOk( aTiresMnt[1], aHeader, aCols )

	EndCase

Return xRet

//------------------------------------------------------------------------------------
/*/{Protheus.doc} f261Selec
Função acionada no F7 e Outras ações da rotina de transferências multiplas mata261
Apresenta markbrowse para selecionar pneus referente aos produtos

@author Maria Elisandra de Paula
@since 19/11/2020
@param aMarked, array, Pneus selecionados para transferencia
		[1]Código
		[2]Local
		[3]Quantidade
		[4]Linha do acols
		[5]Pneus selecionados
@param aHeader, array, cabeçalho da getdados
@param aCols, array, informações da getdados
@param nPosic, numerico, posição do item selecionado
@return array, pneus marcados pelo usuário
/*/
//------------------------------------------------------------------------------------
Static Function f261Selec( aMarked, aHeader, aCols, nPosic )

	Local nPosCod    := aSCan( aHeader, { |x| Trim( Upper(x[2]) ) == 'D3_COD' } )
	Local nPosLoc    := aSCan( aHeader, { |x| Trim( Upper(x[2]) ) == 'D3_LOCAL' } )
	Local nPosQt     := aSCan( aHeader, { |x| Trim( Upper(x[2]) ) == 'D3_QUANT' } )
	Local nPosDescri := aSCan( aHeader, { |x| Trim( Upper(x[2]) ) == 'D3_DESCRI' } )
	Local cProd      := aCols[nPosic, nPosCod]
	Local cLocal     := aCols[nPosic, nPosLoc]
	Local nAmount    := aCols[nPosic, nPosQt]
	Local lOk        := .F.
	Local nPosKey    := 0
	Local cAliasMark := ''
	Local cMark      := GetMark()
	Local aDataBrw   := {}
	Local aTires     := {}
	Local aButtons   := {{ '', {|| NGIfDBSEEK('ST9', (cAliasMark)->T9_CODBEM ,1),;
						MNTA080CAD( 'ST9', ST9->( Recno() ), 2, '3' )  }, STR0214 } }// 'Visualizar Pneu'
	Local oDlg
	Local oPnOwner
	Local oPnCenter
	Local oPnFooter
	Local oMark

	//-------------------------------------
	// Variável utilizada no browse
	//-------------------------------------
	Private cCadastro := STR0203 // 'Pneus para Transferência'
	Private aRotina   := {}


	// SuperGetMv( 'MV_NGPNEUS',.F. , 'N' ) == 'S' .And. SuperGetMv( 'MV_NGPNEST',.F. , 'N' ) == 'S' .And. TQZ->( FieldPos("TQZ_NUMSEQ") )

	//-----------------------------------------
	// Definição do array de pneus marcados
	//-----------------------------------------
	If fDataTires( @aMarked, @aTires, @nPosKey, cProd, cLocal, nAmount, nPosic )

		cAliasMark := GetNextAlias()

		//-----------------------------------
		// Definição de dados do markbrowse
		//-----------------------------------
		aDataBrw := fDataBrw( cProd, cLocal, nPosKey, aMarked, aTires, cAliasMark, cMark )

		DEFINE MSDIALOG oDlg Title STR0203 From 0, 0 To 600, 800 Of oMainWnd PIXEL // 'Pneus para Transferência'

			oPnOwner:= TPanel():New(0,0,'',oDlg,, .T., .T.,, ,115,115,.F.,.F. )
			oPnOwner:Align := CONTROL_ALIGN_ALLCLIENT

			oPnFooter:= tPanel():New(01,01,'',oPnOwner,,,,,,100,30)
			oPnFooter:Align := CONTROL_ALIGN_BOTTOM

			oPnCenter:= tPanel():New(01,01,'',oPnOwner,,,,,,100,30)
			oPnCenter:Align := CONTROL_ALIGN_ALLCLIENT

			@ 05,05 Say aHeader[ nPosCod, 1 ] Of oPnFooter Pixel // Produto
			@ 13,05 MSget cProd Picture '@!' SIZE 120,12 WHEN .F. Of oPnFooter Pixel

			@ 05,130 Say aHeader[ nPosDescri, 1 ] Of oPnFooter Pixel // Desc Produto
			@ 13,130 MSget aCols[nPosic, nPosDescri] Picture '@!' SIZE 120,12 WHEN .F. Of oPnFooter Pixel

			@ 05,260 Say aHeader[ nPosLoc, 1 ] Of oPnFooter Pixel // Armazém
			@ 13,260 MSget cLocal Picture '@!' SIZE 50,12 WHEN .F. Of oPnFooter Pixel

			@ 05,320 Say aHeader[ nPosQt, 1 ] Of oPnFooter Pixel // Quantidade
			@ 13,320 MSget nAmount Picture '999999' size 30,12 WHEN .F. Of oPnFooter Pixel

			//--------------------------
			//Cria markbrowse
			//--------------------------
			oMark := FWMarkBrowse():New()
			oMark:SetOwner( oPnCenter )
			oMark:SetTemporary( .T. )
			oMark:SetFieldMark('OK')
			oMark:SetFields( aDataBrw[1] )
			oMark:SetAlias( cAliasMark )
			oMark:SetAllMark( {|| MarkAll( cAliasMark, oMark, @aTires, cMark ) })
			oMark:SetAfterMark( {||MarkOne( cAliasMark, @aTires ) } )
			oMark:SetSeek( .T. , aDataBrw[2] )
			oMark:SetMark( cMark, cAliasMark, 'OK' )
			oMark:SetDescription( '' )
			oMark:SetMenuDef( '' )
			oMark:DisableConfig()
			oMark:DisableFilter()
			oMark:DisableReport()
			oMark:Activate()

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg, {|| ( lOk := Mnt261Ok( nAmount, aTires ) ) .And. oDlg:End() },; // Botão ok
					{|| lOk := .F., oDlg:End() },, aButtons ) CENTER  

		If lOk
			//---------------------------------------------------------------------
			// aMarked armazena todos os pneus de todos os itens
			// aTires armazena apenas os pneus marcados para o item selecionado
			// Caso o usuário não marque nenhum pneu, as informações são excluídas
			//---------------------------------------------------------------------
			If Len( aTires ) == 0
				aDel( aMarked, nPosKey )
				aSize( aMarked, Len( aMarked ) - 1 )
			Else
				aMarked[ nPosKey, 5 ] := aClone( aTires )
			EndIf

		EndIf

	EndIf

Return aMarked

//------------------------------------------------------------------------------------
/*/{Protheus.doc} fDataTires
Validação e definição do array de controle de pneus

@author Maria Elisandra de Paula
@since 02/12/2020
@param aMarked, array, Pneus selecionados para transferencia
		[1]Código
		[2]Local
		[3]Quantidade
		[4]Linha do acols
		[5]Pneus selecionados
@param aTires, array, pneus da linha selecionada
@param nPosKey, numerico, posição do item no array aMarked
@param cProd, string, código do produto
@param cLocal, string, código do almoxarifado
@param nAmount, numerico, pneus já selecionados pelo usuário
@param nPosic, numerico, posição do item no acols
@return array, pneus selecionados pelo usuário
/*/
//------------------------------------------------------------------------------------
Static Function fDataTires( aMarked, aTires, nPosKey, cProd, cLocal, nAmount, nPosic )

	Local lRet := .T.

	//--------------------------------------------------
	// Verifica se campos principais estão preenchidos
	//--------------------------------------------------
	If Empty( cProd ) .Or. Empty( cLocal ) .Or. nAmount == 0
		HELP( ' ', 1, 'NGATENCAO',, STR0200, 2, 0,,,,,, ; //'O campo produto, armazém ou quantidade não foi informado na linha selecionada.'
			{ STR0201 } )// 'Antes de acionar essa funcionalidade informe os campos Produto Origem, Armazém Origem e Quantidade.'
		lRet := .F.
	EndIf

	If lRet

		//--------------------------------------------
		// A chave é a linha posicionada
		//--------------------------------------------
		nPosKey := aScan( aMarked, { |x| x[4] == nPosic } )
		If nPosKey == 0

			aAdd( aMarked, { cProd, cLocal, nAmount, nPosic, {} } )
			nPosKey := Len( aMarked )

		ElseIf aMarked[nPosKey,1] <> cProd ; // Caso usuário tenha alterado produto ou armazém, as informações serão limpadas
			.Or. aMarked[nPosKey,2] <> cLocal

			aMarked[nPosKey,1] := cProd
			aMarked[nPosKey,2] := cLocal
			aMarked[nPosKey,3] := nAmount
			aMarked[nPosKey,5] := {}

		EndIf

		aTires := aClone( aMarked[ nPosKey, 5 ] ) // Pneus da linha selecionada

	EndIf

Return lRet

//------------------------------------------------------------------------------------
/*/{Protheus.doc} fDataBrw
Definição de dados utilizados no markbrowse

@author Maria Elisandra de Paula
@since 02/12/2020
@param cProd, string, código do produto
@param cLocal, string, código do almoxarifado
@param nPosKey, numerico, posição do item no aMarked
@param aMarked, array, informações de todos os pneus marcados
		[1]Código
		[2]Local
		[3]Quantidade
		[4]Linha do acols
		[5]Pneus selecionados
@param aTires, array, pneus do item posicionado
@param cAliasMark, string, alias de trabalho
@return array, pneus selecionados pelo usuário
/*/
//------------------------------------------------------------------------------------
Static Function fDataBrw( cProd, cLocal, nPosKey, aMarked, aTires, cAliasMark, cMark )

	Local aFields := {}
	Local aSeek   := {}
	Local cQuery  := ''
	Local nIndY   := 0
	Local nIndex  := 0
	Local aNotIn  := {}
	Local aTrb    := {}
	Local oTmpTbl1

	//-------------------------------------------------------------------------------------------------------------
	// Trecho abaixo define pneus que estão selecionados para outra linha - utilizados no filtro da query
	//-------------------------------------------------------------------------------------------------------------
	For nIndex := 1 To Len( aMarked )

		If aMarked[nIndex,4] <> nPosKey .And.;
			aMarked[nIndex,1] == cProd .And.;
			aMarked[nIndex,2] == cLocal .And.;
			Len( aMarked[nIndex,5] ) > 0

			For nIndY := 1 To Len( aMarked[nIndex,5] )
				aAdd( aNotIn, aMarked[nIndex,5, nIndY] )
			Next nIndY

		EndIf

	Next nIndex

	cQuery := " SELECT ST9.T9_CODBEM, T9_NOME,"

	//--------------------------------------------
	// Definição de pneus já marcados
	//--------------------------------------------
	If Len( aTires ) > 0
		
		cQuery += "CASE WHEN ST9.T9_CODBEM IN("

		For nIndex := 1 To Len( aTires )

			If nIndex > 1
				cQuery += ","
			EndIf

			cQuery += ValToSql( aTires[nIndex] )

		Next nIndex

		cQuery += ") THEN " + ValtoSql( cMark ) + " ELSE '  ' END AS OK "

	Else

		cQuery += " '  ' AS OK "

	EndIf

	cQuery += " FROM " + RetSqlName( "ST9" ) + " ST9 "
	cQuery += " WHERE ST9.T9_CODESTO = " + ValToSql( cProd ) 
	cQuery += "     AND ST9.T9_LOCPAD  = " + ValToSql( cLocal )
	cQuery += "     AND T9_CATBEM =  '3' "
	cQuery += "     AND ST9.D_E_L_E_T_ = ' ' "
	cQuery += "     AND ST9.T9_FILIAL  = " + ValToSql( xFilial( "ST9" ) )
	cQuery += "     AND ST9.T9_STATUS IN("
	cQuery +=       ValToSql( AllTrim( SuperGetMv( 'MV_NGSTAEU' ) ) ) + "," //Status de Estoque Usado
	cQuery +=       ValToSql( AllTrim( SuperGetMv( 'MV_NGSTAER' ) ) ) + "," //Status de Estoque Reformado
	cQuery +=       ValToSql( AllTrim( SuperGetMv( 'MV_NGSTAEN' ) ) ) + "," //Status de Estoque Novo
	cQuery +=       ValToSql( AllTrim( SuperGetMv( 'MV_NGSTEST' ) ) ) + ")" //Status de Estoque Filial

	//------------------------------------------------
	// Definição de pneus já marcados em outra linha
	//------------------------------------------------
	If Len( aNotIn ) > 0

		cQuery += " AND ST9.T9_CODBEM NOT IN("

		For nIndex := 1 To Len( aNotIn )

			If nIndex > 1
				cQuery += ","
			EndIf

			cQuery += ValToSql( aNotIn[nIndex] )

		Next nIndex

		cQuery += ") "

	EndIf

	//----------------------------------------------------------------------------------------
	// Ponto de Entrada destinado a filtrar os pneus que serão apresentados no markbrowse
	//----------------------------------------------------------------------------------------
	If ExistBlock( 'MNTPN261A' )

		cQuery += ExecBlock( 'MNTPN261A' )

	EndIf

	cQuery += " ORDER BY ST9.T9_CODBEM "

	//-------------------------------------------
	// Campos TRB
	//-------------------------------------------
	aAdd( aTrb, { 'T9_CODBEM', 'C', TamSx3( 'T9_CODBEM' )[1], 0, ''})
	aAdd( aTrb, { 'T9_NOME', 'C', TamSx3( 'T9_NOME' )[1], 0, '' })
	aAdd( aTrb, { 'OK', 'C', 2,0, '' })

	oTmpTbl1 := FWTemporaryTable():New( cAliasMark, aTrb )
	oTmpTbl1:AddIndex( '01', { 'T9_CODBEM' })
	oTmpTbl1:AddIndex( '02', { 'T9_NOME' })
	oTmpTbl1:Create()

	SqlToTrb( cQuery, aTrb, cAliasMark )

	//-------------------------------------------------
	// Campos para MarkBrowse
	//-------------------------------------------------
	aAdd( aFields,{ NGRETTITULO('TQS_CODBEM'), 'T9_CODBEM', 'C', TAMSX3( 'T9_CODBEM' )[1], 0 } )
	aAdd( aFields,{ NGRETTITULO('T9_NOME'),  'T9_NOME', 'C', TAMSX3( 'T9_NOME' )[1], 0 } )

	//------------------------------
	// Campos para Pesquisa
	//------------------------------
	aAdd( aSeek , { Alltrim( NGRETTITULO('TQS_CODBEM') ), { { '', 'C', TAMSX3( 'T9_CODBEM')[1], 0, 'T9_CODBEM', '@!' } } } )
	aAdd( aSeek , { Alltrim( NGRETTITULO('T9_NOME') ), { { '', 'C', TAMSX3( 'T9_NOME')[1], 0, 'T9_NOME', '@!' } } } )

Return { aFields, aSeek }

//-------------------------------------------------------------------
/*/{Protheus.doc} Mnt261Ok
Valida marcação de markbrowse

@author Maria Elisandra de Paula
@since 24/11/2020
@param nAmount, numérico, quantidade de produtos
@param aTires, string, pneus marcados
@return boolean
/*/
//-------------------------------------------------------------------
Static Function Mnt261Ok( nAmount, aTires )

	Local lRet   := .T.

	If Len( aTires ) > nAmount

		HELP( ' ', 1, 'NGATENCAO',, STR0204 + ' (' +  cValtoChar( Len( aTires ) ) + ') ' + ; // 'Há mais pneus selecionados'
		STR0205 + ' (' +  cValtoChar( nAmount ) + ').',2, 0 ) // 'do que a quantidade de produtos informada'

		lRet   := .F.

	EndIf

	If lRet .And. Len( aTires ) < nAmount .And.;
		!MsgYesNo( STR0208 + '(' +  cValtoChar( Len( aTires ) ) + ')' + ; // 'Há menos pneus selecionados'
		STR0205 + '(' +  cValtoChar( nAmount ) + '). '  + CRLF + CRLF + STR0209 ) // 'do que a quantidade de produtos informada' #Deseja continuar?

		lRet := .F.

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MarkOne
Ação ao marcar/desmarcar

@author Maria Elisandra de Paula
@since 24/11/2020
@param cAliasMark, string, alias da temporária
@param oMark, objeto, markbrowse
@param aTires, array, pneus selecionados
@return boolean
/*/
//-------------------------------------------------------------------
Static Function MarkOne( cAliasMark, aTires )

	Local nPosic := 0

	//---------------------------------------------------------------------------------
	// Trecho abaixo realiza ajuste do array de controle de pneus marcados/desmarcados
	//---------------------------------------------------------------------------------
	If !Empty( (cAliasMark)->OK )

		aAdd( aTires, (cAliasMark)->T9_CODBEM )
	
	ElseIf ( nPosic := aScan( aTires, (cAliasMark)->T9_CODBEM ) ) > 0

		aDel( aTires, nPosic )
		aSize( aTires, Len( aTires ) -1 )

	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MarkAll
Ação ao marcar/desmarcar todos

@author Maria Elisandra de Paula
@since 24/11/2020
@param cAliasMark, string, alias da temporária
@param oMark, objeto, markbrowse
@param aTires, array, pneus selecionados
@return boolean
/*/
//-------------------------------------------------------------------
Static Function MarkAll( cAliasMark, oMark, aTires, cMark )

	Local aArea  := (cAliasMark)->( GetArea() )

	//----------------------------------------
	// Ajuste do array de controle de pneus
	//----------------------------------------
	dbSelectArea(cAliasMark)
	dbGotop()
	While !(cAliasMark)->( Eof() )

		//----------------------------------------------
		// Marca/desmarca (inverte) itens
		//----------------------------------------------
		RecLock( cAliasMark, .F. )
		(cAliasMark)->OK := IIf( Empty( (cAliasMark)->OK ), cMark, '  ' )
		MsUnLock()

		MarkOne( cAliasMark, @aTires )

		(cAliasMark)->( dbSkip() )
	EndDo

	RestArea( aArea )

	oMark:Refresh(.T.)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} f261Grava
Função acionada após gravar tranferências multiplas mata261
Realiza transferência dos pneus selecionados previamente

@author Maria Elisandra de Paula
@since 25/11/2020
@param aTiresMnt, array, Informações para realizar transferecia
		[1]pneus selecionados
		[2]Recno da SD3 já gravados
@param aHeader, array, cabeçalho da getdados
@param aCols, array, informações da getdados
@return Nil
/*/
//-------------------------------------------------------------------
Static Function f261Grava( aTiresMnt, aHeader, aCols )


	If Len( aTiresMnt[1] ) > 0

		//-----------------------------------------------
		// Aciona função que realiza movimentação
		//-----------------------------------------------
		FWMsgRun(, {|| fGravaPneu( aTiresMnt[1], aHeader, aCols, aTiresMnt[2] ) }, STR0206, STR0207 )//"Aguarde" #"Gravando dados..."

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fGravaPneu
Atualiza Codesto e Local de Pneus selecionados por markbrowse

@author Maria Elisandra de Paula
@since 25/11/2020
@param aMarked, array, Pneus selecionados para transferencia
		[1]Código
		[2]Local
		[3]Quantidade
		[4]Linha do acols
		[5]Pneus selecionados
@param aHeader, array, cabeçalho da getdados
@param aCols, array, informações da getdados
@param aRegSD3, array, movimentações gravadas
		[1]Linha do acols
		[2]Recno SD3
@return Nil
/*/
//-------------------------------------------------------------------
Static Function fGravaPneu( aMarked, aHeader, aCols, aRegSD3 )

	Local aSd3Area   := SD3->( GetArea() )
	Local aTires     := {}
	Local nPosCodOri := aSCan( aHeader, { |x| Trim( Upper(x[2]) ) == 'D3_COD' } )
	Local nPosLocOri := aSCan( aHeader, { |x| Trim( Upper(x[2]) ) == 'D3_LOCAL' } )
	Local nPosCodDes := aSCan( aHeader, { |x| Trim( Upper(x[2]) ) == 'D3_COD' }, nPosCodOri + 1 )
	Local nPosLocDes := aSCan( aHeader, { |x| Trim( Upper(x[2]) ) == 'D3_LOCAL' }, nPosLocOri + 1 )
	Local nIndY      := 0
	Local nIndex     := 0
	Local nLine      := 0
	Local nCount     := 0
	Local cCurTime   := Subst( Time(), 1,5 )
	Local nRecnoSd3  := 0

	//-------------------------------------------------------
	// Pneus a serem transferidos
	//-------------------------------------------------------
	For nIndex := 1 To Len( aMarked )

		nLine  := aMarked[nIndex,4]
		aTires := aMarked[nIndex,5]
		nCount := 0

		If Len( aCols ) >= nLine .And. ; // Posição do acols
			!Atail( aCols[nLine] )// Não deletado

			cProdDes := aCols[ nLine, nPosCodDes ] // Produto destino
			cLocDes  := aCols[ nLine, nPosLocDes ] // Armazém destino
			nCount   := Len( aTires )

			nRecnoSd3 := 0
			nPos := aScan( aRegSD3, { |x| x[1] == nLine } )
			If nPos > 0

				nRecnoSd3 := aRegSD3[nPos,2]

				For nIndY := 1 To nCount

					//-------------------------------------
					// Realiza movimentação de pneus
					//-------------------------------------
					fMovPneu( aTires[nIndY], cProdDes, cLocDes, nRecnoSd3, cCurTime )

				Next nIndY

			EndIf

		EndIf

	Next nIndex

	RestArea( aSd3Area )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMovPneu
Realiza movimentação de estoque dos pneus
Altera campos relacionados a estoque de um pneu

@author Maria Elisandra de Paula
@since 01/12/2020
@param cTire, string, código do pneu
@param cProdDes, string, código do produto destino
@param cLocDes, string, código do almoxarifado destino
@param nRecnoSd3, numérico, numero do recno da sd3 que houve a transferência
@param cCurTime, string, hora corrente
@return Nil
/*/
//-------------------------------------------------------------------
Static Function fMovPneu( cTire, cProdDes, cLocDes, nRecnoSd3, cCurTime )

	dbSelectArea('ST9')
	dbSetOrder(1)
	If dbSeek( xFilial( 'ST9' ) + cTire )

		Reclock( 'ST9', .F. )
		ST9->T9_CODESTO := cProdDes
		ST9->T9_LOCPAD  := cLocDes
		ST9->( MsUnLock() )

		dbSelectArea('SD3')
		dbGoto( nRecnoSd3 )

		dbSelectArea('TQZ')
		dbSetOrder(1) // TQZ_FILIAL+TQZ_CODBEM+DTOS(TQZ_DTSTAT)+TQZ_HRSTAT+TQZ_STATUS
		If !dbSeek( xFilial('TQZ') + ST9->T9_CODBEM + Dtos( SD3->D3_EMISSAO ) +  cCurTime + ST9->T9_STATUS )

			Reclock( 'TQZ', .T. )
			TQZ->TQZ_FILIAL := xFilial('TQZ')
			TQZ->TQZ_CODBEM := ST9->T9_CODBEM
			TQZ->TQZ_DTSTAT := SD3->D3_EMISSAO
			TQZ->TQZ_HRSTAT := cCurTime
			TQZ->TQZ_STATUS := ST9->T9_STATUS
			TQZ->TQZ_PRODUT := ST9->T9_CODESTO
			TQZ->TQZ_ALMOX  := ST9->T9_LOCPAD
			TQZ->TQZ_NUMSEQ := SD3->D3_NUMSEQ
			TQZ->TQZ_ORIGEM := 'SD3'
			TQZ->( MsUnLock() )

		EndIf

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} f261TudoOk
Validação de inclusão rotina transferencia multipla mata261
quando usuário vinculou pneus a produtos

@author Maria Elisandra de Paula
@since 04/12/2020
@param aMarked, array, Pneus selecionados para transferencia
		[1]Código
		[2]Local
		[3]Quantidade
		[4]Linha do acols
		[5]Pneus selecionados
@param aHeader, array, cabeçalho da getdados
@param aCols, array, informações da getdados
@return Nil
/*/
//-------------------------------------------------------------------
Static Function f261TudoOk( aMarked, aHeader, aCols )

	Local nPosCodOri := aSCan( aHeader, { |x| Trim( Upper(x[2]) ) == 'D3_COD' } )
	Local nPosLocOri := aSCan( aHeader, { |x| Trim( Upper(x[2]) ) == 'D3_LOCAL' } )
	Local nPosQt     := aSCan( aHeader, { |x| Trim( Upper(x[2]) ) == 'D3_QUANT' } )
	Local nIndex     := 0
	Local nIndY      := 0
	Local nLine      := 0     
	Local cProd      := ''
	Local cLocal     := ''
	Local nAmount    := 0
	Local aTires     := {}
	Local cError     := ''
	Local lRet       := .T.

	For nIndex := 1 To Len( aMarked )

		cProd   := aMarked[nIndex,1]
		cLocal  := aMarked[nIndex,2]
		nAmount := aMarked[nIndex,3]
		nLine   := aMarked[nIndex,4]
		aTires  := aMarked[nIndex,5]

		If Len( aCols ) >= nLine .And. ; // Posição do acols
			!Atail( aCols[nLine] )// Não deletado

			//-------------------------------------------------------------------------------
			// Valida quando usuário alterou o produto e almoxarifado após vincular pneus
			//-------------------------------------------------------------------------------
			If aCols[nLine, nPosCodOri] != cProd .Or. aCols[nLine, nPosLocOri] != cLocal
				cError :=  STR0210 + ' ' + cValtochar( nLine ) + ':' + CRLF + ; // 'Item/linha'
					STR0211 + '.' // "O produto e armazém origem não condizem com os pneus selecionados para transferência"
				Exit
			EndIf

			//-------------------------------------------------------------------------------
			// Valida quando usuário alterou a quantidade para menos após vincular pneus
			//-------------------------------------------------------------------------------
			If aCols[nLine, nPosQt] < nAmount
				cError :=  STR0210 + ' ' + cValtochar( nLine ) + ':' + CRLF + ; // 'Item/linha'
						STR0204 + '(' +  cValtoChar( Len( aTires ) ) + ')' + ; // 'Há mais pneus selecionados'
						STR0205 + '(' +  cValtoChar( nAmount ) + ').'  //"do que a quantidade de produtos informada"
				Exit
			EndIf

			//-----------------------------------------------------------------------------------------------
			// Identifica se um pneu tem codesto e local diferente ao item - quando já houve transferência
			//-----------------------------------------------------------------------------------------------
			For nIndY := 1 To Len( aTires )

				dbSelectArea('ST9')
				dbSetOrder(1)
				If dbSeek( xFilial('ST9') + aTires[nIndY] ) .And. ST9->T9_CODESTO != cProd .Or. ST9->T9_LOCPAD != cLocal
					cError := STR0210 + ' ' + cValtochar( nLine ) + ':' + CRLF + ; // 'Item/linha'
						STR0212 + '.' + CRLF + CRLF+; // "O produto e armazém origem não condizem com o pneu selecionado para transferência"
						aTires[nIndY]  + ':' + CRLF +;
						STR0147 + ': ' + ST9->T9_CODESTO + CRLF +; // 'Produto'
						STR0213 + ': ' + ST9->T9_LOCPAD // 'Armazém'
					Exit
				EndIf

			Next nIndY

			If !Empty( cError )
				Exit
			EndIf

			//-------------------------------------------------------
			// Valida quando usuário alterou a quantidade para menos 
			//-------------------------------------------------------
			If aCols[nLine, nPosQt] > nAmount .And. ;
				!MsgYesNo( STR0210 + ' ' + cValtochar( nLine ) + ':' + CRLF + ; // 'Item/linha'
						STR0208 + '(' +  cValtoChar( Len( aTires ) ) + ')' +; // 'Há menos pneus selecionados'
						STR0205 + '(' +  cValtoChar( nAmount ) + ').' + CRLF + CRLF +; //"do que a quantidade de produtos informada"
						STR0209 ) // 'Deseja Continuar?'
				lRet := .F.
				Exit

			EndIf

		EndIf

	Next

	If !Empty( cError )
		HELP( ' ', 1, 'NGATENCAO',, cError ,2, 0 )
		lRet := .F.
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} f261ValEst
Função acionada na validação de estorno de transferencia multipla mata261
Valida se usuário vinculou pneus a produtos e houve alteração de status posterior

@author Maria Elisandra de Paula
@since 09/12/2020
@param aHeader, array, cabeçalho da getdados
@param aCols, array, informações da getdados
@return boolean
/*/
//------------------------------------------------------------------------------
Static Function f261ValEst( aHeader, aCols )

	Local aArea      := SD3->( GetArea() )
	Local nPosNumSeq := aSCan( aHeader, { |x| Trim( Upper(x[2]) ) == 'D3_NUMSEQ' } )
	Local nIndex     := 0
	Local cAliasQry  := GetNextAlias()
	Local cError     := ''
	Local cCondSql   := '%AND TQZ.TQZ_NUMSEQ IN( '
	Local lRet       := .T.

	//-----------------------------------------------
	// Busca numseq de todas as transferências
	//-----------------------------------------------
	For nIndex := 1 To Len( aCols )

		If nIndex > 1
			cCondSql += ","
		EndIf

		cCondSql += ValToSql( aCols[nIndex, nPosNumSeq] )

	Next nIndex
	
	cCondSql += ')%'

	//------------------------------------------------------------------------------------------------------------------------------
	// Verifica se há pneus vinculados a produtos e já sofreram alteração de status após a transferência que está sendo estornada
	//------------------------------------------------------------------------------------------------------------------------------
	BeginSQL Alias cAliasQry

		SELECT ST9.T9_CODBEM,
			ST9.T9_STATUS
		FROM %table:TQZ% TQZ
		INNER JOIN %table:ST9% ST9
			ON ST9.T9_FILIAL = %xFilial:ST9%
			AND ST9.%NotDel%
			AND ST9.T9_CODBEM = TQZ.TQZ_CODBEM
		WHERE TQZ.%NotDel% 
			AND TQZ.TQZ_FILIAL = %xFilial:TQZ%
			AND TQZ.TQZ_ORIGEM = 'SD3'
			%exp:cCondSql%
			AND ( 
				SELECT COUNT(TQZ2.TQZ_CODBEM)
				FROM %table:TQZ% TQZ2
				WHERE TQZ2.%NotDel% 
					AND TQZ2.TQZ_FILIAL = %xFilial:TQZ%
					AND TQZ2.TQZ_CODBEM = TQZ.TQZ_CODBEM
					AND TQZ2.TQZ_DTSTAT ||  TQZ2.TQZ_HRSTAT > TQZ.TQZ_DTSTAT ||  TQZ.TQZ_HRSTAT
				) > 0

	EndSQL

	While !(cAliasQry)->( Eof() )

		cError += CRLF + STR0215 + ': ' + Alltrim( (cAliasQry)->T9_CODBEM ) + CRLF // 'Pneu'

		(cAliasQry)->( dbSkip() )

	End

	(cAliasQry)->( dbCloseArea() )

	If !Empty( cError )

		lRet := .F.
		cError := STR0217  + ':' + CRLF + cError // 'Há pelo menos um produto vinculado a pneus do SIGAMNT que sofreram alteração de status com data posterior a esta transferência'
		HELP( ' ', 1, 'NGATENCAO',, cError ,2, 0 )

	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} f261Estorn
Função acionada no estorno de movimentação transferência mata261
Desfaz vínculo realizado entre pneus e produtos

@author Maria Elisandra de Paula
@since 09/12/2020
@param aHeader, array, cabeçalho da getdados
@param aCols, array, informações da getdados
@return Nil
/*/
//-------------------------------------------------------------------
Static Function f261Estorn( aHeader, aCols )

	Local aArea      := SD3->( GetArea() )
	Local nPosNumSeq := aSCan( aHeader, { |x| Trim( Upper(x[2]) ) == 'D3_NUMSEQ' } )
	Local nPosCodOri := aSCan( aHeader, { |x| Trim( Upper(x[2]) ) == 'D3_COD' } )
	Local nPosLocOri := aSCan( aHeader, { |x| Trim( Upper(x[2]) ) == 'D3_LOCAL' } )
	Local nIndex     := 0
	Local cAliasQry  := ''

	//-----------------------------------------------
	// Busca numseq de todas as transferências
	//-----------------------------------------------
	For nIndex := 1 To Len( aCols )

		cAliasQry  := GetNextAlias()

		BeginSQL Alias cAliasQry

			SELECT ST9.R_E_C_N_O_ AS RECST9,
					TQZ.R_E_C_N_O_ AS RECTQZ
			FROM %table:TQZ% TQZ
			INNER JOIN %table:ST9% ST9
				ON ST9.T9_FILIAL = %xFilial:ST9%
				AND ST9.%NotDel%
				AND ST9.T9_CODBEM = TQZ.TQZ_CODBEM
			WHERE TQZ.%NotDel% 
				AND TQZ.TQZ_FILIAL = %xFilial:TQZ%
				AND TQZ.TQZ_ORIGEM = 'SD3'
				AND TQZ.TQZ_NUMSEQ = %exp:aCols[ nIndex, nPosNumSeq ]%
		EndSQL

		While !(cAliasQry)->( Eof() )

			//------------------------------------
			// Altera codesto e local do pneu
			//------------------------------------
			dbSelectArea('ST9')
			dbGoTo( (cAliasQry)->RECST9 )
			RecLock( 'ST9', .F. )
			ST9->T9_CODESTO := aCols[ nIndex, nPosCodOri ]
			ST9->T9_LOCPAD  := aCols[ nIndex, nPosLocOri ]
			ST9->( MsUnLock() )

			//---------------------------------------
			// Deleta TQZ referente a movimentação
			//---------------------------------------
			dbSelectArea('TQZ')
			dbGoTo( (cAliasQry)->RECTQZ )
			RecLock( 'TQZ', .F. )
			dbDelete()
			TQZ->( MsUnlock() )

			(cAliasQry)->( dbSkip() )

		End

		(cAliasQry)->( dbCloseArea() )

	Next nIndex

	RestArea( aArea )

Return
