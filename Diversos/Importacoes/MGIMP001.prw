#include 'protheus.ch'
#include 'parmtype.ch'

Static cPulaLinha	:= Chr(13) + Chr(10)
/*
=====================================================================================
Programa.:              MGIMP004
Autor....:         		Danilo TEles     
Data.....:              24/01/2024
Descricao / Objetivo:   Importa cadastro de clientes - SA1
Uso......:               
Obs......:              
=====================================================================================
*/
 
User Function MGIMP001(oSay,cArquivo,nHdlLog,nObjProc,nSucesso)
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
Local nI		 := 0
Local nX		 := 0
Local aCGC       := ""
lOCAL cTipoCli := ""
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

	IF !(cTIPO $('A1'))
		MsgAlert('Não é possivel importar a tabela: '+cTipo+ '  !!')
		Return
	ENDIF

	// monta filtro para consulta SX3
	cFiltroSX3 := " SX3.X3_ARQUIVO = 'SA1' "

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
		aNomeF   := PadR(AllTrim(aDados[nI][aScan(aCampos,"A1_NOME")]),TamSx3("A1_NOME")[1])
		aCGC     := AllTrim(aDados[nI][aScan(aCampos,"A1_CGC")])
		cTipoCli := PadR(AllTrim(aDados[nI][aScan(aCampos,"A1_TIPO")]),TamSx3("A1_TIPO")[1])
		aCGC 	 := StrTran(aCGC,".","")
		aCGC 	 := StrTran(aCGC,"-","")
		aCGC 	 := StrTran(aCGC,"/","")
		aCGC     := PadR(aCGC,TamSx3("A1_CGC")[1])
		DBSELECTAREA("SA1")
		SA1->(DBSETORDER(3))
		IF !SA1->(DbSeek(XFILIAL("SA1")+aCGC)).OR. cTipoCli == "X"
			aAdd(aExecAuto ,{"A1_FILIAL", 	XFILIAL("SA1")	,Nil})
			For nCampos := 1 To Len(aCampos)				
				IF  Upper(aCampos[nCampos])=='A1_COD'					
					aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	MATI30PNum()	,Nil})	
				ELSEIF Upper(aCampos[nCampos]) $ "A1_CGC-A1_INSCR-A1_CONTA-A1_CEP"
					cDadoImp := StrTran(ALLTRIM(aDados[nI,nCampos]),".","")
					cDadoImp := StrTran(cDadoImp,"-","")
					cDadoImp := StrTran(cDadoImp,"/","")
					aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  PadR(cDadoImp,TamSx3(aCampos[nCampos])[1]) 	,Nil})
				ELSEIF Upper(aCampos[nCampos]) == "A1_COD_MUN"
					aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  PadR(SUBSTR(ALLTRIM(aDados[nI,nCampos]),3,TamSx3(aCampos[nCampos])[1]),TamSx3(aCampos[nCampos])[1]) 	,Nil})
				ELSEIF Upper(aCampos[nCampos]) == "A1_PAIS"
					aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  IIF(ALLTRIM(aDados[nI,nCampos]) == "BR","105",aDados[nI,nCampos]) 	,Nil})
				ELSEIF Upper(aCampos[nCampos]) == "A1_PESSOA"
					IF ALLTRIM(aDados[nI,nCampos]) $ "J-F-X"
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  aDados[nI,nCampos] 	,Nil})
					ELSE
						IF LEN(aCGC) == 14
							aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  "J" 	,Nil})
						ELSE
							aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  "F" 	,Nil})
						ENDIF
					ENDIF
				ELSE
				
					IF  TamSx3(Upper(aCampos[nCampos]))[3] =='N'
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	VAL(strtran(aDados[nI,nCampos],",","."))	,Nil})
					ELSEIF TamSx3(Upper(aCampos[nCampos]))[3] =='D'
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  CTOD(aDados[nI,nCampos] )	,Nil})
					ELSE
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  FWNoAccent(PadR(SUBSTR(ALLTRIM(aDados[nI,nCampos]),1,TamSx3(aCampos[nCampos])[1]),TamSx3(aCampos[nCampos])[1])) 	,Nil})
					ENDIF
				ENDIF
			Next nCampos
			lMsErroAuto := .F.

			//aExecAuto := FWVetByDic(aExecAuto, "SA1")

			Begin Transaction
				MSExecAuto({|x,y| MATA030(x,y)},aExecAuto,3) // SA1 Cliente

				//Caso ocorra erro, verifica se ocorreu antes ou depois dos primeiros 100 registros do arquivo
				If lMsErroAuto

					aLog := {}
					aLog := GetAutoGRLog()
					cLogWrite := ""
					For nX :=1 to Len(aLog)
						cLogWrite += strtran(StrTran(StrTran(aLog[nX], "<", ""), "-", ""),CRLF,"") + " "//aLog[nX]+ "--"
					next nX
					/*
					fWrite(nHdlLog,"Registro: " + cValToChar(nI) + " CPF/CNPJ: " + aCGC)
					fWrite(nHdlLog,cPulaLinha)
					fWrite(nHdlLog,"Erro: ExecAuto.")
					fWrite(nHdlLog,cPulaLinha)
					fWrite(nHdlLog, cLogWrite)
					fWrite(nHdlLog,cPulaLinha)
					fWrite(nHdlLog,cPulaLinha)*/
					fWrite(nHdlLog,aCGC +";"+aNomeF+";"+cLogWrite+";")
        			fWrite(nHdlLog,cPulaLinha)
				else
					nSucesso++
					ConfirmSX8()
				EndIF

			End Transaction
			
		ELSE
			/*fWrite(nHdlLog,"Registro: " + cValToChar(nI) + " CPF/CNPJ: " + aCGC)
			fWrite(nHdlLog,cPulaLinha)
			fWrite(nHdlLog,"Erro: Cliente já existe na base.")
			fWrite(nHdlLog,cPulaLinha)
			fWrite(nHdlLog, SA1->A1_COD + " - " + SA1->A1_LOJA + "-" + ALLTRIM(SA1->A1_NOME))
			fWrite(nHdlLog,cPulaLinha)
			fWrite(nHdlLog,cPulaLinha)*/
			fWrite(nHdlLog,aCGC +";"+aNomeF+";"+"Cliente já existe na base."+";")
        	fWrite(nHdlLog,cPulaLinha)
		ENDIF
	Next nI

	FT_FUSE()
	cFilAnt := cBKFilial

Return


Static Function MATI30PNum()
Local cProxNum := ""
Local ccArea := Getarea()

	cProxNum := GetSxeNum("SA1","A1_COD")
	DBSELECTAREA("SA1")
	DBSETORDER(1)
	While .T.
		If SA1->( DbSeek( xFilial("SA1")+cProxNum ) )
			ConfirmSX8()
			cProxNum := GetSxeNum("SA1","A1_COD")
		Else
			//ConfirmSX8()
			Exit
		Endif
	Enddo

	RestArea(ccArea)
Return(cProxNum)
