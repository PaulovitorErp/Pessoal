#include 'protheus.ch'
#include 'parmtype.ch'

Static cPulaLinha	:= Chr(13) + Chr(10)

/*
=====================================================================================
Programa.:              TBCF001
Autor....:         		Danilo Teles     
Data.....:              25/01/2024
Descricao / Objetivo:   Importa contas a pagar - SE2
Uso......:               
Obs......:              
=====================================================================================
*/

User Function MGIMP004(oSay,cArquivo,nHdlLog,nObjProc,nSucesso)
	Local aLog       := {}
	Local cLogWrite  := ""
	Local cFiltroSX3 := ""
	Local cLinha     := ''
	Local lPrim      := .T.
	Local aCampos    := {}
	Local aDados     := {}
	Local nCampos    := 0
	Local aExecAuto  := {}
	Local aCamposSX3 := {}
	Local aTipoImp   := {}
	Local cTipo      := ''
	Local nI
	Local nX

	Local cPrefixo  := ""
	Local cParcela  := ""
	Local cTipoTit  := ""
	Local cNumero 	:= ""
	Local cIdSap 	:= ""
	Local dEmissao  := cTod("")
	Local dBkpData  := cTod("")
	Local dDtBaixa 	:= cTod("")
	Local nValBaixa := 0
	Local lBlq 		:= .F.

	Private lMsErroAuto    := .F.
	Private lMsHelpAuto	   := .F.
	Private lAutoErrNoFile := .T.

	Default oSay 		:= Nil
	Default cArquivo 	:= ""
	Default nHdlLog 	:= 0
	Default nObjProc 	:= 0
	Default nSucesso 	:= 0


	FT_FUSE(cArquivo)
	FT_FGOTOP()
	cLinha    := FT_FREADLN()
	aTipoImp  := Separa(cLinha,";",.T.)
	cTipo     := SUBSTR(aTipoImp[1],1,2)

	IF !(cTIPO $('E2/A2'))
		MsgAlert('Não é possivel importar a tabela: '+cTipo+ '  !!')
		Return
	ENDIF

	// monta filtro para consulta SX3
	cFiltroSX3 := " SX3.X3_ARQUIVO = 'SE2' "

	// função que consulta tabela SX3
	aCamposSX3 := U_MEGAAUX2(cFiltroSX3)

	//If !U_MEGAAUX1(aTipoImp, aCamposSX3, cTipo)
	//	Return
	//Endif


	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()
	While !FT_FEOF()
		IncProc("Lendo arquivo texto...")
		cLinha := FT_FREADLN()
		If lPrim
			aCampos := Separa(cLinha,";",.T.)
			lPrim := .F.
		Else
			AADD(aDados,Separa(cLinha,";",.T.))
		EndIf
		FT_FSKIP()
	EndDo

	ProcRegua(Len(aDados))
	For nI:=1 to  Len(aDados)

		nObjProc ++

		IncProc("Importando arquivo...")
		aExecAuto := {}
		cPrefixo    := PadR(AllTrim(aDados[nI][aScan(aCampos,"E2_PREFIXO")]),TamSx3("E2_PREFIXO")[1])
		cParcela    := PadR(AllTrim(aDados[nI][aScan(aCampos,"E2_PARCELA")]),TamSx3("E2_PARCELA")[1])
		cTipoTit    := PadR(AllTrim(aDados[nI][aScan(aCampos,"E2_TIPO")]),TamSx3("E2_TIPO")[1])
		cNumero     := PadR(AllTrim(aDados[nI][aScan(aCampos,"E2_NUM")]),TamSx3("E2_NUM")[1])
		cIdSap   	:= PadR(AllTrim(aDados[nI][aScan(aCampos,"E2_XIDSAP")]),TamSx3("E2_XIDSAP")[1])
		dEmissao   	:= cTod(aDados[nI][aScan(aCampos,"E2_EMISSAO")])
		aCGC     	:= AllTrim(aDados[nI][aScan(aCampos,"E2_FORNECE")])
		aCGC 	 	:= StrTran(ALLTRIM(aCGC),".","")
		aCGC 	 	:= StrTran(aCGC,"-","")
		aCGC 	 	:= StrTran(aCGC,"/","")
		nValBaixa	:= val(strtran(aDados[nI][aScan(aCampos,"E2_XSLDSAP")],",","."))
		dDtBaixa 	:= cTod(aDados[nI][aScan(aCampos,"E2_XDTBAIX")])
		cIdSAPFor  	:= PadR(AllTrim(aDados[nI][aScan(aCampos,"A2_CGC")]),TamSx3("A2_CGC")[1])
		lBlq 		:= .F.
		DBSELECTAREA("SA2")
		SA2->(DBSETORDER(3))
		IF SA2->(DbSeek(XFILIAL("SA2")+aCGC)) .OR. fGetForn(cIdSAPFor)
			//Se o fornecedor estiver bloqueado, eu desbloqueio ele.
			IF SA2->A2_MSBLQL == "1"
				lBlq := .T.
				SA2->(RecLock("SA2",.F.))
				SA2->A2_MSBLQL := "2"
				SA2->(MsUnLock())
			endif
			if !SE2->(DbSetOrder(1),DbSeek(FWxFilial("SE2")+cPrefixo+cNumero+cParcela+cTipoTit+SA2->A2_COD+SA2->A2_LOJA))
				aAdd(aExecAuto ,{"E2_FILIAL", 	XFILIAL("SE2")	,Nil})
				For nCampos := 1 To Len(aCampos)
					IF  Upper(aCampos[nCampos])=='E2_FORNECE'
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	SA2->A2_COD		,Nil})
						aAdd(aExecAuto ,{"E2_LOJA", 				SA2->A2_LOJA	,Nil})
					ELSEIF Upper(aCampos[nCampos])=='E2_BAIXA'
						loop
					ELSEIF Upper(aCampos[nCampos])=='A2_CGC'
						loop
					Else
						IF  TamSx3(Upper(aCampos[nCampos]))[3] =='N'
							aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  VAL(strtran(aDados[nI,nCampos],",","."))	,Nil})
						ELSEIF TamSx3(Upper(aCampos[nCampos]))[3] =='D'
							aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  CTOD(aDados[nI,nCampos] )	,Nil})
						ELSE
							aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  SUBSTR(ALLTRIM(aDados[nI,nCampos]),1,TamSx3(aCampos[nCampos])[1]) 	,Nil})
						ENDIF
					ENDIF
				Next nCampos

				if AllTrim(cTipoTit) == "PA"
					aAdd(aExecAuto ,{"CBCOAUTO",  "001" 		, Nil})
					aAdd(aExecAuto ,{"CAGEAUTO",  "3348 " 		, Nil})
					aAdd(aExecAuto ,{"CCTAAUTO",  "5799      " 	, Nil})
				endif

				lMsErroAuto := .F.
				Begin Transaction
					dBkpData  := dDataBase
					dDataBase := dEmissao
					MSExecAuto({|y,z| FINA050(y,z)},aExecAuto,3)   // SE2 Contas a Pagar em aberto MESTRE
					dDataBase := dBkpData
					//Caso ocorra erro, verifica se ocorreu antes ou depois dos primeiros 100 registros do arquivo
					If lMsErroAuto

						aLog := {}
						aLog := GetAutoGRLog()
						cLogWrite := ""

						For nX :=1 to Len(aLog)
							cLogWrite += aLog[nX]+CRLF
						next nX

						fWrite(nHdlLog,cPrefixo+cNumero+cParcela+cTipoTit +";"+cLogWrite+";")
						fWrite(nHdlLog,cPulaLinha)
					else
						nSucesso++
					EndIF

				End Transaction
				//Se de fato ele tiver bloqueado, eu bloqueio de novo.
				if lBlq
					SA2->(RecLock("SA2",.F.))
					SA2->A2_MSBLQL := "1"
					SA2->(MsUnLock())
				endif
			else
				////Se encontrar o titulo, verficar se tem baixa nele, se tiver baixa nele, alimenta o campo de baixa.
				//if nValBaixa > 0 .AND. SE2->E2_XSLDSAP == 0
				//	SE2->(RecLock("SE2",.F.))
				//	SE2->E2_XSLDSAP := nValBaixa
				//	SE2->E2_XDTBAIX := dDtBaixa
				//	SE2->(MsUnLock())
				//	nSucesso++
				//else
				fWrite(nHdlLog,cPrefixo+cNumero+cParcela+cTipoTit +";"+"Titulo já incluso."+";")
				fWrite(nHdlLog,cPulaLinha)
				//endif
			ENDIF
		else
			fWrite(nHdlLog,aCGC +";"+"Fornecedor não encontrado." + "Titulo : " + cPrefixo+cNumero+cParcela+cTipoTit +";")
			fWrite(nHdlLog,cPulaLinha)
		ENDIF
	Next nI

	FT_FUSE()

Return

Static Function fGetForn(cIdSAP)

	Local lReturn 		:= .F.
	Local cQuery      	:= ""
	Local cAliasQry   	:= ""
	Default cIdSAP 		:= ""

	cQuery := " SELECT SA2.R_E_C_N_O_ AS CHAVESA2 "			+ CRLF
	cQuery += " FROM " + RetSqlName("SA2") + " SA2 " 		+ CRLF
	cQuery += " WHERE SA2.D_E_L_E_T_ = ' '  " 				+ CRLF
	cQuery += " AND A2_XIDSAP  = '"+cIdSAP+"' " 			+ CRLF
	cQuery += " AND A2_FILIAL  = '"+FWxFilial("SA2")+"' " 	+ CRLF
	cQuery += " AND A2_XORIGEM = '2' " 						+ CRLF

	cAliasQry := MPSysOpenQuery(cQuery)

	if !(cAliasQry)->(Eof())
		SA2->(DbGoto( (cAliasQry)->CHAVESA2 ))
		lReturn := .T.
	endif

	if Select(cAliasQry) > 0 .AND. !Empty(cAliasQry)
		(cAliasQry)->(DbCloseArea())
	endif

Return(lReturn)
