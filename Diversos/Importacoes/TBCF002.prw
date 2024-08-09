#Include 'Protheus.ch'
#Include 'ParmType.ch'

Static cPulaLinha	:= Chr(13) + Chr(10)

/*-------------------------------------------------------------------
- Programa: TBCF002
- Autor: Tarcisio silva
- Data: 07/04/2020
- Descrição: Importa cadastro de produtos - SB1.
-------------------------------------------------------------------*/

User Function TBCF002(oSay,cArquivo,nHdlLog,nObjProc,nSucesso)

	Local aArea 		:= GetArea()
	Local aTabExclui   	:= u_fTableExc()
	Local aCamposImp 	:= u_funLeCsv(cArquivo,1)
	Local cTipo 		:= SubStr(aCamposImp[1],1,2)
	Local aCamposSX3 	:= U_TBCFAUX2(" SX3.X3_ARQUIVO = 'SB1' ")
	Default oSay 		:= Nil
	Default cArquivo 	:= ""
	Default nHdlLog 	:= 0
	Default nObjProc 	:= 0
	Default nSucesso 	:= 0

	if lRet := cTipo $ 'B1' //Verifica se a Alias esta correta.

		if lRet := U_TBCFAUX1(aCamposImp, aCamposSX3, cTipo)

			//U_fDelRegs(aTabExclui,cTipo)
			aDados := U_funLeCsv(cArquivo,2,oSay)
			fUpdsRegs(aDados,aCamposImp,oSay,cArquivo,@nHdlLog,@nObjProc,@nSucesso)

		endif

	else

		MsgAlert('Não é possivel importar a tabela: '+cTipo+ '  !!', "Atenção!")

	endif

	RestArea(aArea)

Return(lRet)

/*-------------------------------------------------------------------
- Programa: fUpdsRegs
- Autor: Tarcisio silva
- Data: 07/04/2020
- Descrição: Efetua a inclusão dos registros.
-------------------------------------------------------------------*/

Static Function fUpdsRegs(aDados,aCampos,oSay,cArquivo,nHdlLog,nObjProc,nSucesso)

	Local aAreaSM0 		:= SM0->(GetArea())
	Local aAreaSB1 		:= SB1->(GetArea())
	Local cBKFilial		:= cFilAnt
	Local nI 			:= 0
	Local nCampos 		:= 0
	Local nPosProd		:= 0
	Local aExecAuto 	:= {}
	Local cCodProd 		:= ""
	Local cFilProd 		:= ""
	Private lMsHelpAuto := .F.
	Private lMsErroAuto := .F.
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

		if nPosProd > 0
			cCodProd := PadR(AllTrim(aDados[nI][aScan(aCampos,"B1_COD")]),TamSx3("B1_COD")[1])
		else 
			cCodProd := ""
		endif
		
		if aScan(aCampos,"B1_FILIAL") != 0
		
			cFilProd := PadR(AllTrim(aDados[nI][aScan(aCampos,"B1_FILIAL")]),TamSx3("B1_FILIAL")[1])

		else
			
			cFilProd := xFilial("SB1")

		endif

		// se não vier o código do produto preenchido, nao valida se já está cadastrado
		if nPosProd <= 0 .OR. !SB1->(DbSeek(cFilProd+cCodProd))

			for nCampos := 1 To Len(aCampos)

				if SubStr(Upper(aCampos[nCampos]),4,6)=='FILIAL'

					if !Empty(aDados[nI,nCampos])

						u_fTrocaFil(aDados[nI,nCampos])

					endif

				else

					if TamSx3(Upper(aCampos[nCampos]))[3] =='N'

						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	Val(aDados[nI,nCampos] )	,Nil})

					elseif TamSx3(Upper(aCampos[nCampos]))[3] =='D'

						aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  cTod(aDados[nI,nCampos] )	,Nil})

					else

						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	aDados[nI,nCampos] 	,Nil})

					endif

				endif

			Next nCampos

			Begin Transaction

				MSExecAuto({|x,y| MATA010(x,y)},aExecAuto,3) // SB1 Produto

				if lMsErroAuto

					fWrite(nHdlLog,"Registro: " + cValToChar(nI))
					fWrite(nHdlLog,cPulaLinha)
					fWrite(nHdlLog,"Erro: ExecAuto.")
					fWrite(nHdlLog,cPulaLinha)
					fWrite(nHdlLog, MostraErro("\"))
					fWrite(nHdlLog,cPulaLinha)
					u_fTrocaFil(cBKFilial)

				else

					nSucesso++

				endif

			End Transaction

		else

			fWrite(nHdlLog,"Registro: " + cValToChar(nI))
			fWrite(nHdlLog,cPulaLinha)
			fWrite(nHdlLog,"Erro: Produto ja existente.")
			fWrite(nHdlLog,cPulaLinha)

		endif

	Next nI

	u_fTrocaFil(cBKFilial)
	RestArea(aAreaSM0)
	RestArea(aAreaSB1)

Return(Nil)


