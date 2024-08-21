#include 'protheus.ch'
#include 'parmtype.ch'

Static cPulaLinha	:= Chr(13) + Chr(10)

/*/-------------------------------------------------------------------
- Programa: MGIMP009
- Autor: Tarcisio Silva Miranda
- Data: 02/07/2024
- Descrição: Importação de baixas a pagar.
-------------------------------------------------------------------/*/

User Function MGIMP009(oSay,cArquivo,nHdlLog,nObjProc,nSucesso)

	Local aLog       		:= {}
	Local cLogWrite  		:= ""
	Local cFiltroSX3 		:= ""
	Local cLinha     		:= ''
	Local lPrim      		:= .T.
	Local aCampos    		:= {}
	Local aDados     		:= {}
	Local aExecAuto  		:= {}
	Local aCamposSX3 		:= {}
	Local aTipoImp   		:= {}
	Local cTipo      		:= ''
	Local nI 				:= 0
	Local nX 				:= 0
	Local cPrefixo  		:= ""
	Local cParcela  		:= ""
	Local cTipoTit  		:= ""
	Local cNumero 			:= ""
	Local cIdSapTit 		:= ""
	Local dDtaBakp 			:= cTod("")
	Private lMsErroAuto    	:= .F.
	Private lMsHelpAuto	   	:= .F.
	Private lAutoErrNoFile 	:= .T.
	Default oSay 			:= Nil
	Default cArquivo 		:= ""
	Default nHdlLog 		:= 0
	Default nObjProc 		:= 0
	Default nSucesso 		:= 0

	FT_FUSE(cArquivo)
	FT_FGOTOP()
	cLinha    := FT_FREADLN()
	aTipoImp  := Separa(cLinha,";",.T.)
	cTipo     := SUBSTR(aTipoImp[1],1,2)

	IF !(cTIPO $('E2'))
		MsgAlert('Não é possivel importar a tabela: '+cTipo+ '  !!')
		Return
	ENDIF

	// monta filtro para consulta SX3
	cFiltroSX3 := " SX3.X3_ARQUIVO IN ('SE2','SA6','SE5') "

	// função que consulta tabela SX3
	aCamposSX3 := U_MEGAAUX2(cFiltroSX3)

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
		//Implementação.
		cIdSapTit   := PadR(AllTrim(aDados[nI][aScan(aCampos,"E2_XIDSAP")]),TamSx3("E2_XIDSAP")[1])
		dDtBaixa 	:= cTod(aDados[nI][aScan(aCampos,"E2_BAIXA")])
		//fim
		aCGC     	:= AllTrim(aDados[nI][aScan(aCampos,"E2_FORNECE")])
		aCGC 	 	:= StrTran(ALLTRIM(aCGC),".","")
		aCGC 	 	:= StrTran(aCGC,"-","")
		aCGC 	 	:= StrTran(aCGC,"/","")
		DBSELECTAREA("SA2")
		SA2->(DBSETORDER(3))
		//Posiciona no titulo.
		if SE2->(DbSetOrder(1),DbSeek( FWxFilial("SE2") + PadR(AllTrim(cPrefixo),TamSx3("E2_PREFIXO")[1]);
				+ PadR(AllTrim(cNumero),TamSx3("E2_NUM")[1]) + PadR(AllTrim(cParcela),TamSx3("E2_PARCELA")[1]);
				+ PadR(AllTrim(cTipoTit),TamSx3("E2_TIPO")[1]))) .AND.SE2->E2_SALDO > 0

			//Posiona no banco.
			SA6->(DbSetOrder(1),DbSeek(FWxFilial("SA6")+"CX1"+"00001"+"0000000001"))

			dDtaBakp 	:= dDataBase
			dDataBase 	:= dDtBaixa
			Aadd(aExecAuto,{"E2_PREFIXO" ,SE2->E2_PREFIXO	,Nil})
			Aadd(aExecAuto,{"E2_NUM"	 ,SE2->E2_NUM		,Nil})
			Aadd(aExecAuto,{"E2_PARCELA" ,SE2->E2_PARCELA	,Nil})
			Aadd(aExecAuto,{"E2_TIPO"	 ,SE2->E2_TIPO		,Nil})
			Aadd(aExecAuto,{"E2_FORNECE" ,SE2->E2_FORNECE	,Nil})
			Aadd(aExecAuto,{"E2_LOJA"	 ,SE2->E2_LOJA		,Nil})
			aAdd(aExecAuto,{"AUTBANCO"   ,SA6->A6_COD		,Nil})
			aAdd(aExecAuto,{"AUTAGENCIA" ,SA6->A6_AGENCIA	,Nil})
			aAdd(aExecAuto,{"AUTCONTA"   ,SA6->A6_NUMCON    ,Nil})
			Aadd(aExecAuto,{"AUTMOTBX"	 ,"NOR"				,Nil})
			Aadd(aExecAuto,{"AUTDTBAIXA" ,dDtBaixa			,Nil})
			Aadd(aExecAuto,{"AUTHIST"	 ,"CARGA INICIAL"	,Nil})
			aAdd(aExecAuto,{"AUTVALREC"  ,SE2->E2_VALOR		,Nil})

			lMsErroAuto := .F.
			Begin Transaction

				//if MsgYesNo("teste?","teste")
				if SE2->E2_MOEDA != 1
					if !SM2->(DbSetOrder(1),DbSeek( dDataBase ))
						SM2->(RecLock("SM2",.T.))
						SM2->M2_DATA := dDataBase
						SM2->(MsUnLock())
					endif
				endif
				//endif

				MsExecAuto({|x, y| FINA080(x, y)}, aExecAuto, 3)
				dDataBase := dDtaBakp
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
			fWrite(nHdlLog,cIdSapTit +";"+"Titulo inexistente."+";")
			fWrite(nHdlLog,cPulaLinha)
		ENDIF
	Next nI

	FT_FUSE()

Return()
