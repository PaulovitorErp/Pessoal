#Include 'Protheus.ch'
#Include 'ParmType.ch'

Static cPulaLinha	:= Chr(13) + Chr(10)

/*-------------------------------------------------------------------
- Programa: MGIMP003 
- Autor: Danilo Teles
- Data: 30/01/2024
- Descrição: Importa cadastro de produtos - SB1.
-------------------------------------------------------------------*/

User Function MGIMP003(oSay,cArquivo,nHdlLog,nObjProc,nSucesso)
Local aArea 		:= GetArea()
Local aCamposImp 	:= u_funLeCsv(cArquivo,1)
Local cTipo 		:= SubStr(aCamposImp[1],1,2)
Local aCamposSX3 	:= U_MEGAAUX2(" SX3.X3_ARQUIVO = 'SB1' ")
Default oSay 		:= Nil
Default cArquivo 	:= ""
Default nHdlLog 	:= 0
Default nObjProc 	:= 0
Default nSucesso 	:= 0

	if lRet := cTipo $ 'B1' //Verifica se a Alias esta correta.

		if lRet := U_MEGAAUX1(aCamposImp, aCamposSX3, cTipo)

			aDados := U_funLeCsv(cArquivo,2,oSay)
			FCadProd(aDados,aCamposImp,oSay,cArquivo,@nHdlLog,@nObjProc,@nSucesso)

		endif

	else

		MsgAlert('Não é possivel importar a tabela: '+cTipo+ '  !!', "Atenção!")

	endif

	RestArea(aArea)

Return(lRet)


/*-------------------------------------------------------------------
- Programa: FCadProd
- Autor: Danilo Teles
- Data: 30/01/2024
- Descrição: Efetua o cadastro dos produtos
-------------------------------------------------------------------*/

Static Function FCadProd(aDados,aCampos,oSay,cArquivo,nHdlLog,nObjProc,nSucesso)
Local aAreaSM0 		:= SM0->(GetArea())
Local aAreaSB1 		:= SB1->(GetArea())
Local nI 			:= 0
Local nCampos 		:= 0
Local nPosProd		:= 0
Local aExecAuto 	:= {}
Local cCodProd 		:= ""
Local nX
lOCAL cIdSap 			:= ""
Private lMsErroAuto    := .F.
Private lMsHelpAuto	   := .F.
Private lAutoErrNoFile := .T.
Default aDados 		:= {}
Default aCampos 	:= {}
Default oSay 		:= Nil
Default cArquivo 	:= ""
Default nHdlLog 	:= 0
Default nObjProc 	:= 0
Default nSucesso 	:= 0

	SB1->(DbSelectArea("SB1"))
	SB1->(DbSetOrder(1))
	SB1->(DbGotop())

	oSay:cCaption := ("Processando gravação dos registros!...")
	ProcessMessages()

	for nI := 1 to Len(aDados)

		if len(aCampos) != len(aDados[nI])
			
			nObjProc	++
			fWrite(nHdlLog,"Registro: " + cValToChar(nI))
			fWrite(nHdlLog,cPulaLinha)
			fWrite(nHdlLog,"Cabeçalho difere dos dados!")
			fWrite(nHdlLog,cPulaLinha)
			loop

		endif
		
		nObjProc	++
		aExecAuto 	:= {}
		lMsErroAuto := .F.
		nPosProd	:= aScan(aCampos,"B1_COD")

		cIdSap   	:= PadR(AllTrim(aDados[nI][aScan(aCampos,"B1_XIDSAP")]),TamSx3("B1_XIDSAP")[1])

		if nPosProd > 0
			cCodProd := PadR(AllTrim(aDados[nI][aScan(aCampos,"B1_COD")]),TamSx3("B1_COD")[1])
		else 
			cCodProd := ""
		endif
			

		// se não vier o código do produto preenchido, nao valida se já está cadastrado
		if nPosProd <= 0 .OR. !SB1->(DbSeek(xFilial("SB1")+cCodProd)) .OR. !fGetProd(cIdSAP)

			for nCampos := 1 To Len(aCampos)			

				if TamSx3(Upper(aCampos[nCampos]))[3] =='N'
					aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	Val(aDados[nI,nCampos] )	,Nil})
				elseif TamSx3(Upper(aCampos[nCampos]))[3] =='D'
					aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  cTod(aDados[nI,nCampos] )	,Nil})
				else
					aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	SUBSTR(ALLTRIM(aDados[nI,nCampos]),1,TamSx3(aCampos[nCampos])[1]) 	,Nil})
				endif			

			Next nCampos
			_lok := .T.
			Begin Transaction

				MSExecAuto({|x,y| MATA010(x,y)},aExecAuto,3) // SB1 Produto

				if lMsErroAuto

					aLog := {}
					aLog := GetAutoGRLog()
					cLogWrite := ""
					For nX :=1 to Len(aLog)
						cLogWrite += aLog[nX]+CRLF
					next nX

					fWrite(nHdlLog,"Registro: " + cValToChar(nI) + " PROD: " + cCodProd)
					fWrite(nHdlLog,cPulaLinha)
					fWrite(nHdlLog,"Erro: ExecAuto.")
					fWrite(nHdlLog,cPulaLinha)
					fWrite(nHdlLog,cLogWrite)
					fWrite(nHdlLog,cPulaLinha)
					fWrite(nHdlLog,cPulaLinha)
					_lok := .F.
				else
					nSucesso++
				endif

			End Transaction
						
		else

			fWrite(nHdlLog,"Registro: " + cValToChar(nI) + " PROD: " + cCodProd) 
			fWrite(nHdlLog,cPulaLinha)
			fWrite(nHdlLog,"Erro: Produto ja existente.")
			fWrite(nHdlLog,cPulaLinha)

		endif

	Next nI

	RestArea(aAreaSM0)
	RestArea(aAreaSB1)

Return(Nil)

Static Function fGetProd(cIdSAP)

	Local lReturn 		:= .F.
	Local cQuery      	:= ""
	Local cAliasQry   	:= ""
	Default cIdSAP 		:= ""

	cQuery := " SELECT SB1.R_E_C_N_O_ AS CHAVESB1 "			+ CRLF
	cQuery += " FROM " + RetSqlName("SB1") + " SB1 " 		+ CRLF
	cQuery += " WHERE SB1.D_E_L_E_T_ = ' '  " 				+ CRLF
	cQuery += " AND B1_XIDSAP = '"+cIdSAP+"' " 				+ CRLF
	cQuery += " AND B1_FILIAL = '"+FWxFilial("SB1")+"' " 	+ CRLF

	cAliasQry := MPSysOpenQuery(cQuery)

	if !(cAliasQry)->(Eof())
		SB1->(DbGoto( (cAliasQry)->CHAVESB1 ))
		lReturn := .T.
	endif

	if Select(cAliasQry) > 0 .AND. !Empty(cAliasQry)
		(cAliasQry)->(DbCloseArea())
	endif

Return(lReturn)
