#include 'protheus.ch'
#include 'parmtype.ch'

Static cPulaLinha	:= Chr(13) + Chr(10)

/*
=====================================================================================
Programa.:              MGIMP005
Autor....:         		Danilo Teles     
Data.....:              25/01/2024
Descricao / Objetivo:   Importa contas a receber - SE1
Uso......:               
Obs......:              
=====================================================================================
*/

User Function MGIMP005(oSay,cArquivo,nHdlLog,nObjProc,nSucesso)
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
	Local cIdSAPCli := ""
	Local dBkpData  := cTod("")
	Local dEmissao  := cTod("")
	Local lBlq 		:= .F.
	Local lMudaTit  := .F.


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

	IF !(cTIPO $('E1/A1'))
		MsgAlert('Não é possivel importar a tabela: '+cTipo+ '  !!')
		Return
	ENDIF

	// monta filtro para consulta SX3
	cFiltroSX3 := " SX3.X3_ARQUIVO = 'SE1' "

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
		cPrefixo    := PadR(AllTrim(aDados[nI][aScan(aCampos,"E1_PREFIXO")]),TamSx3("E1_PREFIXO")[1])
		cParcela    := PadR(AllTrim(aDados[nI][aScan(aCampos,"E1_PARCELA")]),TamSx3("E1_PARCELA")[1])
		cTipoTit    := PadR(AllTrim(aDados[nI][aScan(aCampos,"E1_TIPO")]),TamSx3("E1_TIPO")[1])
		cNumero     := PadR(AllTrim(aDados[nI][aScan(aCampos,"E1_NUM")]),TamSx3("E1_NUM")[1])
		cIdSap   	:= PadR(AllTrim(aDados[nI][aScan(aCampos,"E1_XIDSAP")]),TamSx3("E1_XIDSAP")[1])
		aCGC     	:= AllTrim(aDados[nI][aScan(aCampos,"E1_CLIENTE")])
		cIdSAPCli  	:= PadR(AllTrim(aDados[nI][aScan(aCampos,"A1_CGC")]),TamSx3("A1_CGC")[1])
		dEmissao   	:= cTod(aDados[nI][aScan(aCampos,"E1_EMISSAO")])
		aCGC 	 	:= StrTran(ALLTRIM(aCGC),".","")
		aCGC 	 	:= StrTran(aCGC,"-","")
		aCGC 	 	:= StrTran(aCGC,"/","")
		lBlq 		:= .F.
		lMudaTit 	:= .F.
		DBSELECTAREA("SA1")
		SA1->(DBSETORDER(3))
		IF SA1->(DbSeek(XFILIAL("SA1")+aCGC)) .OR. fGetCli(cIdSAPCli)
			if !SE1->(DbSetOrder(1),DbSeek(FWxFilial("SE1")+cPrefixo+cNumero+cParcela+cTipoTit)) .OR. fGetTit(cIdSAP,@lMudaTit)
				//Se o fornecedor estiver bloqueado, eu desbloqueio ele.
				IF SA1->A1_MSBLQL == "1"
					lBlq := .T.
					SA1->(RecLock("SA1",.F.))
					SA1->A1_MSBLQL := "2"
					SA1->(MsUnLock())
				endif
				if lMudaTit
					cNumero := AllTrim(cNumero)
					cNumero	+= AllTrim(aCGC)
					cNumero	:= PadR(AllTrim(SubStr(cNumero,1,9)),TamSx3("E1_NUM")[1])
					if SE1->(DbSetOrder(1),DbSeek(FWxFilial("SE1")+cPrefixo+cNumero+cParcela+cTipoTit))
						cNumero := AllTrim(PadR(AllTrim(aDados[nI][aScan(aCampos,"E1_NUM")]),TamSx3("E1_NUM")[1]))
						cNumero	+= dTos(dEmissao)
						cNumero	:= PadR(AllTrim(SubStr(cNumero,1,9)),TamSx3("E1_NUM")[1])
						if SE1->(DbSetOrder(1),DbSeek(FWxFilial("SE1")+cPrefixo+cNumero+cParcela+cTipoTit))
							fWrite(nHdlLog,cPrefixo+cNumero+cParcela+cTipoTit +";"+"Titulo já incluso."+";")
							fWrite(nHdlLog,cPulaLinha)
							loop
						endif
					endif
				endif
				aAdd(aExecAuto ,{"E1_FILIAL", 	XFILIAL("SE1")	,Nil})
				For nCampos := 1 To Len(aCampos)
					IF  Upper(aCampos[nCampos])=='E1_CLIENTE'
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	SA1->A1_COD		,Nil})
						aAdd(aExecAuto ,{"E1_LOJA", 				SA1->A1_LOJA	,Nil})
					ELSEIF Upper(aCampos[nCampos])=='A1_CGC'
						loop
					ELSEIF Upper(aCampos[nCampos])=='E1_NUM'
						aAdd(aExecAuto ,{"E1_NUM",	cNumero	,Nil})
					Else
						IF  TamSx3(Upper(aCampos[nCampos]))[3] =='N'
							aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  VAL(strtran(aDados[nI,nCampos],",","."))	,Nil})
						ELSEIF TamSx3(Upper(aCampos[nCampos]))[3] =='D'
							aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  Ctod(aDados[nI,nCampos] )	,Nil})
						ELSE
							aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  SUBSTR(ALLTRIM(aDados[nI,nCampos]),1,TamSx3(aCampos[nCampos])[1]) 	,Nil})
						ENDIF
					ENDIF
				Next nCampos

				if AllTrim(cTipoTit) == "RA"
					aAdd(aExecAuto ,{"CBCOAUTO",  "001" 		, Nil})
					aAdd(aExecAuto ,{"CAGEAUTO",  "3348 " 		, Nil})
					aAdd(aExecAuto ,{"CCTAAUTO",  "5799      " 	, Nil})
				endif

				lMsErroAuto := .F.
				Begin Transaction
					dBkpData  := dDataBase
					dDataBase := dEmissao
					MSExecAuto({|x,y| FINA040(x,y)},aExecAuto,3)   // SE1 Contas a Receber em aberto MESTRE
					dDataBase := dBkpData
					//Se de fato ele tiver bloqueado, eu bloqueio de novo.
					if lBlq
						SA1->(RecLock("SA1",.F.))
						SA1->A1_MSBLQL := "1"
						SA1->(MsUnLock())
					endif
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
			else
				fWrite(nHdlLog,cPrefixo+cNumero+cParcela+cTipoTit +";"+"Titulo já incluso."+";")
				fWrite(nHdlLog,cPulaLinha)
			ENDIF
		else
			fWrite(nHdlLog,aCGC +";"+"Cliente não encontrado."+ "Titulo : " + cPrefixo+cNumero+cParcela+cTipoTit +";")
			fWrite(nHdlLog,cPulaLinha)
		endif
	Next nI

	FT_FUSE()

Return()


Static Function fGetCli(cIdSAP)

	Local lReturn 		:= .F.
	Local cQuery      	:= ""
	Local cAliasQry   	:= ""
	Default cIdSAP 		:= ""

	cQuery := " SELECT SA1.R_E_C_N_O_ AS CHAVESA1 "			+ CRLF
	cQuery += " FROM " + RetSqlName("SA1") + " SA1 " 		+ CRLF
	cQuery += " WHERE SA1.D_E_L_E_T_ = ' '  " 				+ CRLF
	cQuery += " AND A1_XIDSAP = '"+cIdSAP+"' " 				+ CRLF
	cQuery += " AND A1_FILIAL = '"+FWxFilial("SA1")+"' " 	+ CRLF
	cQuery += " AND A1_XORIGEM = '9' " 	+ CRLF

	cAliasQry := MPSysOpenQuery(cQuery)

	if !(cAliasQry)->(Eof())
		SA1->(DbGoto( (cAliasQry)->CHAVESA1 ))
		lReturn := .T.
	endif

	if Select(cAliasQry) > 0 .AND. !Empty(cAliasQry)
		(cAliasQry)->(DbCloseArea())
	endif

Return(lReturn)

Static Function fGetTit(cIdSAP,lMudaTit)

	Local lReturn 		:= .T.
	Local cQuery      	:= ""
	Local cAliasQry   	:= ""
	Default cIdSAP 		:= ""
	Default lMudaTit 	:= .T.

	cQuery := " SELECT SE1.R_E_C_N_O_ AS CHAVESE1 "			+ CRLF
	cQuery += " FROM " + RetSqlName("SE1") + " SE1 " 		+ CRLF
	cQuery += " WHERE SE1.D_E_L_E_T_ = ' '  " 				+ CRLF
	cQuery += " AND E1_XIDSAP = '"+cIdSAP+"' " 				+ CRLF
	cQuery += " AND E1_FILIAL = '"+FWxFilial("SE1")+"' " 	+ CRLF

	cAliasQry := MPSysOpenQuery(cQuery)
	//Se existir o numero, eu vou embora e não faço nada.
	if !(cAliasQry)->(Eof())
		lReturn  := .F.
		lMudaTit := .F.
	else
		lMudaTit := .T.
	endif

	if Select(cAliasQry) > 0 .AND. !Empty(cAliasQry)
		(cAliasQry)->(DbCloseArea())
	endif

Return(lReturn)
