#include 'protheus.ch'
#include 'parmtype.ch'

Static cPulaLinha	:= Chr(13) + Chr(10)

/*
=====================================================================================
Programa.:              MGIMP006
Autor....:         		Danilo Teles     
Data.....:              12/02/2024
Descricao / Objetivo:   Importa Saldos em Estoque SB9
Uso......:               
Obs......:              
=====================================================================================
*/ 

User Function MGIMP006(oSay,cArquivo,nHdlLog,nObjProc,nSucesso)
	Local aLog       := {}
	Local cLogWrite  := ""
	Local cFiltroSX3 := ""
	Local cLinha     := ''
	Local lPrim      := .T.
	Local aCampos    := {}
	Local aDados     := {}
	Local cBKFilial  := cFilAnt
	Local nCampos    := 0
	Local aExecAuto  := {}
	Local aCamposSX3 := {}
	Local aTipoImp   := {}
	Local cTipo      := ''
	Local nI
	Local nX
	Local lSucesso 	:= .F.
	Local cProduto 		:= ""
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

	IF !(cTIPO $('B9'))
		MsgAlert('Não é possivel importar a tabela: '+cTipo+ '  !!')
		Return
	ENDIF

	// monta filtro para consulta SX3
	cFiltroSX3 := " SX3.X3_ARQUIVO = 'SB9' "

	// função que consulta tabela SX3
	aCamposSX3 := U_MEGAAUX2(cFiltroSX3)

	If !U_MEGAAUX1(aTipoImp, aCamposSX3, cTipo)
		Return
	Endif

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
		For nCampos := 1 To Len(aCampos)

			if Upper(aCampos[nCampos]) == "B9_COD"
				cProduto := fGetPrd(aDados[nI,nCampos])
				aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	cProduto 	,Nil})
			else
				IF  TamSx3(Upper(aCampos[nCampos]))[3] =='N'
					aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	VAL(aDados[nI,nCampos] )	,Nil})
				ELSEIF TamSx3(Upper(aCampos[nCampos]))[3] =='D'
					aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  CTOD(aDados[nI,nCampos] )	,Nil})
				ELSE
					aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	aDados[nI,nCampos] 	,Nil})
				ENDIF
			endif

		Next nCampos
		lMsErroAuto := .F.
		Begin Transaction

			if !empty(cProduto)
				if lSucesso := !SB9->(DbSetOrder(1),DbSeek(FWxFilial("SB9") + cProduto + aDados[nI][aScan(aCampos, {|x| x == "B9_LOCAL"})] ))
					MSExecAuto({|x,y| MATA220(x,y)},aExecAuto,3) // SB9 Saldo de estoque
				endif
			endif

			//Caso ocorra erro, verifica se ocorreu antes ou depois dos primeiros 100 registros do arquivo
			if empty(cProduto)
				fWrite(nHdlLog,"Registro: " + cValToChar(nI))
				fWrite(nHdlLog,cPulaLinha)
				fWrite(nHdlLog,"Erro: ExecAuto.")
				fWrite(nHdlLog,cPulaLinha)
				fWrite(nHdlLog, "Produto inexiste da base.")
				fWrite(nHdlLog,cPulaLinha)
			elseif !lSucesso
				fWrite(nHdlLog,"Registro: " + cValToChar(nI))
				fWrite(nHdlLog,cPulaLinha)
				fWrite(nHdlLog,"Erro: ExecAuto.")
				fWrite(nHdlLog,cPulaLinha)
				fWrite(nHdlLog, "Registro ja importado.")
				fWrite(nHdlLog,cPulaLinha)
			elseIf lMsErroAuto
				aLog := {}
				aLog := GetAutoGRLog()

				For nX :=1 to Len(aLog)
					cLogWrite += aLog[nX]+CRLF
				next nX

				fWrite(nHdlLog,"Registro: " + cValToChar(nI))
				fWrite(nHdlLog,cPulaLinha)
				fWrite(nHdlLog,"Erro: ExecAuto.")
				fWrite(nHdlLog,cPulaLinha)
				fWrite(nHdlLog, cLogWrite)
				fWrite(nHdlLog,cPulaLinha)

			else
				nSucesso++
			EndIF

		End Transaction
	Next nI

	FT_FUSE()
	cFilAnt := cBKFilial

Return



Static Function fGetPrd(cProduto)

	Local cReturn 		:= ""
	Local cQuery      	:= ""
	Local cAliasQry   	:= ""
	Default cProduto 	:= ""

	cQuery := " SELECT " 									+ CRLF
	cQuery += "		B1_COD AS PRODUTO "						+ CRLF
	cQuery += " FROM " + RetSqlName("SB1") + " SB1 " 		+ CRLF
	cQuery += " WHERE SB1.D_E_L_E_T_ = ' '  " 				+ CRLF
	cQuery += " AND B1_XIDSAP = '"+cProduto+"' " 			+ CRLF
	cQuery += " AND B1_FILIAL = '"+FWxFilial("SB1")+"' " 	+ CRLF

	cAliasQry := MPSysOpenQuery(cQuery)

	if !(cAliasQry)->(Eof())
		cReturn := PadR(AllTrim((cAliasQry)->PRODUTO),TamSx3("B9_COD")[1])
	endif

	if Select(cAliasQry) > 0 .AND. !Empty(cAliasQry)
		(cAliasQry)->(DbCloseArea())
	endif

Return(cReturn)
