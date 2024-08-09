#Include 'Protheus.ch'
#Include 'ParmType.ch'

Static cPulaLinha	:= Chr(13) + Chr(10)

/*-------------------------------------------------------------------
- Programa: TBCF014
- Autor: Tarcisio silva - AJUSTE PARA CTT Fernando Valadares
- Data: 13/04/2020      - 14/12/2021
- Descrição: Importa cadastro de Centro de Custo. - CTT.
-------------------------------------------------------------------*/

User Function TBCF014(oSay,cArquivo,nHdlLog,nObjProc,nSucesso)

	Local aArea 		:= GetArea()
//	Local aTabExclui   	:= u_fTableExc()
	Local aCamposImp 	:= u_funLeCsv(cArquivo,1)
	Local cTipo 		:= SubStr(aCamposImp[1],1,3)
	Local aCamposSX3 	:= U_TBCFAUX2(" SX3.X3_ARQUIVO = 'CTT' ")
	Default oSay 		:= Nil
	Default cArquivo 	:= ""
	Default nHdlLog 	:= 0
	Default nObjProc 	:= 0
	Default nSucesso 	:= 0

	if lRet := cTipo $ 'CTT' //Verifica se a Alias esta correta.

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
- Autor: Tarcisio silva - AJUSTE PARA CTT Fernando Valadares
- Data: 13/04/2020      - 14/12/2021
- Descrição: Efetua a inclusão dos registros.
-------------------------------------------------------------------*/

Static Function fUpdsRegs(aDados,aCampos,oSay,cArquivo,nHdlLog,nObjProc,nSucesso)

	Local aAreaSM0 		:= SM0->(GetArea())
	Local aAreaCTT 		:= CTT->(GetArea())
	Local cBKFilial		:= cFilAnt
	Local nI 			:= 0
	Local nCampos 		:= 0
	Local aExecAuto 	:= {}
	Local cCodReg 		:= ""
	Local cFilReg 		:= ""
    Private lMsHelpAuto := .F.
	Private lMsErroAuto := .F.
	Default aDados 		:= {}
	Default aCampos 	:= {}
	Default oSay 		:= Nil
	Default cArquivo 	:= ""
	Default nHdlLog 	:= 0
	Default nObjProc 	:= 0
	Default nSucesso 	:= 0

	CTT->(DbSelectArea("CTT"))
	CTT->(DbSetOrder(1))
	CTT->(DbGotop())

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
		cCodReg 	:= PadR(AllTrim(aDados[nI][aScan(aCampos,"CTT_CUSTO")]),TamSx3("CTT_CUSTO")[1])
		
		if aScan(aCampos,"CTT_FILIAL") != 0
		
			cFilReg := PadR(AllTrim(aDados[nI][aScan(aCampos,"CTT_FILIAL")]),TamSx3("CTT_FILIAL")[1])

		else
			
			cFilReg := xFilial("CTT")

		endif

		if !CTT->(DbSeek(cFilReg+cCodReg))

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

				MSExecAuto( { |x,y| CTBA030(x,y)} , aExecAuto, 3) // CTT Centro de Custo

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
			fWrite(nHdlLog,"Erro: Registro ja existente.")
			fWrite(nHdlLog,cPulaLinha)

		endif

	Next nI

	u_fTrocaFil(cBKFilial)
	RestArea(aAreaSM0)
	RestArea(aAreaCTT)

Return(Nil)
