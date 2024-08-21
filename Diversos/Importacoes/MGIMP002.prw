#include 'protheus.ch'
#include 'parmtype.ch'

Static cPulaLinha	:= Chr(13) + Chr(10)

/*
=====================================================================================
Programa.:              MGIMP002
Autor....:         		Danilo TEles     
Data.....:              24/01/2024
Descricao / Objetivo:   Importa cadastro de fornecedores - SA2
Uso......:               
Obs......:              
=====================================================================================
*/

User Function MGIMP002(oSay,cArquivo,nHdlLog,nObjProc,nSucesso)
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
Local cTipoCli 	:= ""
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

	IF !(cTIPO $('A2'))
		MsgAlert('Não é possivel importar a tabela: '+cTipo+ '  !!')
		Return
	ENDIF

	// monta filtro para consulta SX3				
	cFiltroSX3 := " SX3.X3_ARQUIVO = 'SA2' "																																														

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
		aCGC     := AllTrim(aDados[nI][aScan(aCampos,"A2_CGC")])
		aNomeF   := PadR(AllTrim(aDados[nI][aScan(aCampos,"A2_NOME")]),TamSx3("A2_NOME")[1])
		cTipoCli := PadR(AllTrim(aDados[nI][aScan(aCampos,"A2_TIPO")]),TamSx3("A2_TIPO")[1])
		aCGC 	 := StrTran(ALLTRIM(aCGC),".","")
		aCGC 	 := StrTran(aCGC,"-","")
		aCGC 	 := StrTran(aCGC,"/","")
		aCGC     := PadR(aCGC,TamSx3("A2_CGC")[1])
		DBSELECTAREA("SA2")
		SA2->(DBSETORDER(3))
		IF ( alltrim(aCGC) != "" .AND. !SA2->(DbSeek(XFILIAL("SA2")+aCGC)) ) .OR. cTipoCli == "X"
			aAdd(aExecAuto ,{"A2_FILIAL", 	XFILIAL("SA2")	,Nil})
			For nCampos := 1 To Len(aCampos)
				
				IF Upper(aCampos[nCampos]) $ "A2_CGC-A2_INSCR-A2_CONTA-A2_CEP"
					cDadoImp := StrTran(ALLTRIM(aDados[nI,nCampos]),".","")
					cDadoImp := StrTran(cDadoImp,"-","")
					cDadoImp := StrTran(cDadoImp,"/","")
					aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  PadR(cDadoImp,TamSx3(aCampos[nCampos])[1]) 	,Nil})
				ELSEIF Upper(aCampos[nCampos]) == "A2_COD_MUN"
					aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  PadR(SUBSTR(ALLTRIM(aDados[nI,nCampos]),3,TamSx3(aCampos[nCampos])[1]),TamSx3(aCampos[nCampos])[1]) 	,Nil})
				ELSEIF Upper(aCampos[nCampos]) == "A2_PAIS"
					aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  IIF(ALLTRIM(aDados[nI,nCampos]) == "BR","105",aDados[nI,nCampos]) 	,Nil})
				ELSEIF Upper(aCampos[nCampos]) == "A2_TIPO"
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
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  VAL(strtran(aDados[nI,nCampos],",","."))		,Nil})
					ELSEIF TamSx3(Upper(aCampos[nCampos]))[3] =='D'
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  CTOD(aDados[nI,nCampos] )	,Nil})
					ELSE
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  FWNoAccent(PadR(SUBSTR(ALLTRIM(aDados[nI,nCampos]),1,TamSx3(aCampos[nCampos])[1]),TamSx3(aCampos[nCampos])[1])) 	,Nil})
					ENDIF
				ENDIF
			Next nCampos
			lMsErroAuto := .F.
			Begin Transaction
				MSExecAuto({|x,y| MATA020(x,y)},aExecAuto,3) // SA2 Fornecedores

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
				EndIF

			End Transaction
			
		ELSE
			IF ALLTRIM(aCGC) != ""
				/*fWrite(nHdlLog,"Registro:" + cValToChar(nI) + " CPF/CNPJ: " + aCGC)
				fWrite(nHdlLog,cPulaLinha)
				fWrite(nHdlLog,"Erro: Fornecedor já existe na base.")
				fWrite(nHdlLog,cPulaLinha)
				fWrite(nHdlLog, SA2->A2_COD + " - " + SA2->A2_LOJA + "-" + ALLTRIM(SA2->A2_NOME))
				fWrite(nHdlLog,cPulaLinha)	
				fWrite(nHdlLog,cPulaLinha)*/

				fWrite(nHdlLog,aCGC +";"+aNomeF+";"+"Fornecedor já existe na base."+";")
        		fWrite(nHdlLog,cPulaLinha)
			//ELSE
			//	/*fWrite(nHdlLog,"Registro:" + cValToChar(nI) + " NOME: " + aNomeF)
			//	fWrite(nHdlLog,cPulaLinha)
			//	fWrite(nHdlLog,"Erro: Fornecedor sem CPF/CNPJ.")
			//	fWrite(nHdlLog,cPulaLinha)	
			//	fWrite(nHdlLog,cPulaLinha)*/
			//	fWrite(nHdlLog,aCGC +";"+aNomeF+";"+"Fornecedor sem CPF/CNPJ."+";")
        	//	fWrite(nHdlLog,cPulaLinha)
			ENDIF
		ENDIF
	Next nI

	FT_FUSE()
	cFilAnt := cBKFilial

Return
