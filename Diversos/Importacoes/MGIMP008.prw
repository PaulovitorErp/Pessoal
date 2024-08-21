#include 'protheus.ch'
#include 'parmtype.ch'

Static cPulaLinha	:= Chr(13) + Chr(10)

/*/-------------------------------------------------------------------
- Programa: MGIMP008
- Autor: Tarcisio Silva Miranda
- Data: 02/07/2024
- Descrição: Importação de baixas a receber.
-------------------------------------------------------------------/*/

User Function MGIMP008(oSay,cArquivo,nHdlLog,nObjProc,nSucesso)
	
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
	Local cBanco 			:= ""
	Local cAgencia 			:= ""
	Local cConta 			:= ""
	Local cTpBaixa 			:= ""
	Local dDtaBakp 			:= cTod("")
	Local nValBaixa 		:= 0
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

	IF !(cTIPO $('E1/A6'))
		MsgAlert('Não é possivel importar a tabela: '+cTipo+ '  !!')
		Return
	ENDIF

	// monta filtro para consulta SX3
	cFiltroSX3 := " SX3.X3_ARQUIVO IN ('SE1','SA6','SE5') "

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
		cPrefixo    := PadR(AllTrim(aDados[nI][aScan(aCampos,"E1_PREFIXO")]),TamSx3("E1_PREFIXO")[1])
		cParcela    := PadR(AllTrim(aDados[nI][aScan(aCampos,"E1_PARCELA")]),TamSx3("E1_PARCELA")[1])
		cTipoTit    := PadR(AllTrim(aDados[nI][aScan(aCampos,"E1_TIPO")]),TamSx3("E1_TIPO")[1])
		cNumero     := PadR(AllTrim(aDados[nI][aScan(aCampos,"E1_NUM")]),TamSx3("E1_NUM")[1])
		//Implementação.
		cIdSapTit   := PadR(AllTrim(aDados[nI][aScan(aCampos,"E1_XIDSAP")]),TamSx3("E1_XIDSAP")[1])
		cBanco 		:= PadR(AllTrim(aDados[nI][aScan(aCampos,"A6_COD")]),TamSx3("A6_COD")[1])
		cAgencia 	:= PadR(AllTrim(aDados[nI][aScan(aCampos,"A6_AGENCIA")]),TamSx3("A6_AGENCIA")[1])
		cConta 		:= PadR(AllTrim(aDados[nI][aScan(aCampos,"A6_NUMCON")]),TamSx3("A6_NUMCON")[1])
		cTpBaixa 	:= PadR(AllTrim(aDados[nI][aScan(aCampos,"E5_MOTBX")]),TamSx3("E5_MOTBX")[1])
		dDtBaixa 	:= cTod(aDados[nI][aScan(aCampos,"E1_BAIXA")])
		nValBaixa   := val(StrTran(aDados[nI][aScan(aCampos,"E1_VALOR")],",","."))-val(StrTran(aDados[nI][aScan(aCampos,"E1_SALDO")],",","."))
		//fim
		aCGC     	:= AllTrim(aDados[nI][aScan(aCampos,"E1_CLIENTE")])
		aCGC 	 	:= StrTran(ALLTRIM(aCGC),".","")
		aCGC 	 	:= StrTran(aCGC,"-","")
		aCGC 	 	:= StrTran(aCGC,"/","")
		DBSELECTAREA("SA1")
		SA1->(DBSETORDER(3))
		//Localiza o cliente.
		IF SA1->(DbSeek(XFILIAL("SA1")+aCGC)) .OR. fGetCli(aCGC)
			//Posiciona no titulo.
			if fGetTit(cIdSapTit)
				//Se o titulo estiver em aberto.
				if SE1->E1_SALDO > 0
					//Posiona no banco.
					if SA6->(DbSetOrder(1),DbSeek(FWxFilial("SA6")+cBanco+cAgencia+cConta))

						dDtaBakp 	:= dDataBase
						dDataBase 	:= dDtBaixa
						aAdd(aExecAuto,{"E1_PREFIXO"  ,SE1->E1_PREFIXO		,Nil    })
						aAdd(aExecAuto,{"E1_NUM"      ,SE1->E1_NUM			,Nil    })
						aAdd(aExecAuto,{"E1_PARCELA"  ,SE1->E1_PARCELA		,Nil    })
						aAdd(aExecAuto,{"E1_TIPO"     ,SE1->E1_TIPO			,Nil    })
						aAdd(aExecAuto,{"AUTMOTBX"    ,cTpBaixa				,Nil    })
						aAdd(aExecAuto,{"AUTBANCO"    ,SA6->A6_COD			,Nil    })
						aAdd(aExecAuto,{"AUTAGENCIA"  ,SA6->A6_AGENCIA		,Nil    })
						aAdd(aExecAuto,{"AUTCONTA"    ,SA6->A6_NUMCON    	,Nil    })
						aAdd(aExecAuto,{"AUTDTBAIXA"  ,dDtBaixa         	,Nil    })
						aAdd(aExecAuto,{"AUTDTCREDITO",dDtBaixa         	,Nil    })
						aAdd(aExecAuto,{"AUTHIST"     ,"CARGA INICIAL"    	,Nil    })
						aAdd(aExecAuto,{"AUTJUROS"    ,0					,Nil,.T.})
						aAdd(aExecAuto,{"AUTVALREC"   ,nValBaixa			,Nil    })

						lMsErroAuto := .F.
						Begin Transaction

							MSExecAuto({|x,y| Fina070(x,y)},aExecAuto,3)
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
						fWrite(nHdlLog,cIdSapTit +";"+"Banco não existente."+";")
						fWrite(nHdlLog,cPulaLinha)
					endif
				else
					fWrite(nHdlLog,cIdSapTit +";"+"Titulo já baixado."+";")
					fWrite(nHdlLog,cPulaLinha)
				endif
			else
				fWrite(nHdlLog,cIdSapTit +";"+"Titulo inexistente."+";")
				fWrite(nHdlLog,cPulaLinha)
			ENDIF

		else
			fWrite(nHdlLog,aCGC +";"+"Cliente não encontrado."+ "Titulo : " + cIdSapTit +";")
			fWrite(nHdlLog,cPulaLinha)
		endif
	Next nI

	FT_FUSE()

Return()

/*/-------------------------------------------------------------------
	- Programa: fGetCli
	- Autor: Tarcisio Silva Miranda
	- Data: 22/03/2022
	- Descrição: Posiciona no cliente com base no ID do SAP.
-------------------------------------------------------------------/*/

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

	cAliasQry := MPSysOpenQuery(cQuery)

	if !(cAliasQry)->(Eof())
		SA1->(DbGoto( (cAliasQry)->CHAVESA1 ))
		lReturn := .T.
	endif

	if Select(cAliasQry) > 0 .AND. !Empty(cAliasQry)
		(cAliasQry)->(DbCloseArea())
	endif

Return(lReturn)

/*/-------------------------------------------------------------------
	- Programa: fGetTit
	- Autor: Tarcisio Silva Miranda
	- Data: 22/03/2022
	- Descrição: Posiciona no titulo com base no ID do SAP.
-------------------------------------------------------------------/*/

Static Function fGetTit(cIdSapTit)

	Local lReturn 		:= .F.
	Local cQuery      	:= ""
	Local cAliasQry   	:= ""
	Default cIdSapTit 		:= ""

	cQuery := " SELECT SE1.R_E_C_N_O_ AS CHAVESE1 "			+ CRLF
	cQuery += " FROM " + RetSqlName("SE1") + " SE1 " 		+ CRLF
	cQuery += " WHERE SE1.D_E_L_E_T_ = ' '  " 				+ CRLF
	cQuery += " AND E1_XIDSAP = '"+cIdSapTit+"' " 			+ CRLF
	cQuery += " AND E1_FILIAL = '"+FWxFilial("SE1")+"' " 	+ CRLF

	cAliasQry := MPSysOpenQuery(cQuery)

	if !(cAliasQry)->(Eof())
		SE1->(DbGoto( (cAliasQry)->CHAVESE1 ))
		lReturn := .T.
	endif

	if Select(cAliasQry) > 0 .AND. !Empty(cAliasQry)
		(cAliasQry)->(DbCloseArea())
	endif

Return(lReturn)
