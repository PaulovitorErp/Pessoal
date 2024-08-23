#include 'protheus.ch'
#include 'parmtype.ch'

Static cPulaLinha	:= Chr(13) + Chr(10)

/*
=====================================================================================
Programa.:              ORC001
Autor....:         		Paulo Vítor   
Data.....:              23/08/2024
Descricao / Objetivo:   Importa tabela de orcçamentos (Faturamento) SCJ/SCK
Uso......:               
Obs......:              
=====================================================================================
*/

User Function ORC001(oSay,cArquivo,nHdlLog,nObjProc,nSucesso)

	Local cArq	     := ""
	Local cArqd	     := ""
	Local cLogDir    := ""
	Local cLogFile   := ""
	Local cTime      := ""
	Local aLog       := {}
	Local cLogWrite  := ""
	Local cLogWritet := ""
	Local cFiltroSX3 := ""
	Local nHandle
	Local cLinha     := ''
	Local cLinhad    := ''
	Local lPrim      := .T.
	Local lPrimd     := .T.
	Local _lok       := .T.
	Local aCampos    := {}
	Local aCamposd   := {}
	Local aDados     := {}
	Local aDadosd    := {}
	Local cBKFilial  := cFilAnt
	Local nCampos    := 0
	Local nCamposd   := 0
	Local cSQL       := ''
	Local cSQLd      := ''
	Local aExecAuto  := {}
	Local aExecAutod := {}
	Local aExecAutol := {}
	Local aCamposSX3 := {}
	Local aTipoImp   := {}
	Local aTipoImpd  := {}
	Local nTipoImp   := 0
	Local nTipoImpd  := 0
	Local nPosArray  := 0
	Local cTipo      := ''
	Local cTipod     := ''
	Local cTab       := ''
	Local cTabd      := ''
	Local nI
	Local nId
	Local nX
	Local cNiv
	Local cCod
	Local cBemN1
	Local cBemN3
	Local cItemN1
	Local cItemN3
	Private lMsErroAuto    := .F.
	Private lMsHelpAuto	   := .F.
	Private lAutoErrNoFile := .T. 
	Private aTabExclui     := {{'B1',{"SB1"} },;
	{'G1',{"SG1"} },;
	{'A1',{"SA1"} },;
	{'A2',{"SA2"} },;
	{'A3',{"SA3"} },;
	{'DA3',{"DA3"} },;
	{'A4',{"SA4"} },;
	{'N1',{"SN1","SN3","SN4","SN5"} },;
	{'B9',{"SB2","SB9"} },;
	{'D5',{"SD5"} },;
	{'C7',{"SC7"} },;
	{'C5',{"SC5"} },;
	{'C6',{"SC6"} },;
	{'E2',{"SE2"} },;
	{'E1',{"SE1"} },;
    {'CJ',{"SCJ","SCK"} },;
	{'C1',{"SC1"} } }

	Default oSay 		:= Nil
	Default cArquivo 	:= ""
	Default nHdlLog 	:= 0
	Default nObjProc 	:= 0
	Default nSucesso 	:= 0

	//cArq := cGetFile("Todos os Arquivos|*.csv", OemToAnsi("Informe o diretório onde se encontra o arquivo."), 0, "SERVIDOR\", .F., GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE ,.T.)

	//Arquivo Cabeçalho
	//MsgAlert("Essa opção precisa de 2 arquivos, o primeiro é o arquivo de CABEÇALHO!","ATENÇÃO")
	/*cArq := cGetFile("Todos os Arquivos|*.csv", OemToAnsi("Informe o diretório onde se encontra o arquivo."), 0, "SERVIDOR\", .F., GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE ,.T.)

	If !File(cArq)
		MsgStop("O arquivo " +cArq + " não foi selecionado. A importação será abortada!","ATENCAO")
		Return
	EndIf
	*/

	FT_FUSE(cArquivo)
	FT_FGOTOP()
	cLinha    := FT_FREADLN()
	aTipoImp  := Separa(cLinha,";",.T.)
	cTipo     := SUBSTR(aTipoImp[1],1,2)

	IF !(cTIPO $('CJ'))
		MsgAlert('Não é possivel importar a tabela: '+cTipo+ '  !!')
		Return
	ENDIF

	// monta filtro para consulta SX3				
	cFiltroSX3 := " SX3.X3_ARQUIVO = 'SCJ' "																																														

	// função que consulta tabela SX3
	aCamposSX3 := U_TBCFAUX2(cFiltroSX3)

	If !U_TBCFAUX1(aTipoImp, aCamposSX3, cTipo)
		Return
	Endif

	nTipoImp  := aScan( aTabExclui, { |x| AllTrim( x[1] ) == cTipo } )

	cTab := ''
	For nI := 1 To Len(aTabExclui[nTipoImp,2])
		cTab += aTabExclui[nTipoImp,2,nI]+' '
	Next nI

	/*
	If MsgYesNo("Deseja excluir os dados da(s) tabela(s):"+cTab+"antes da importação ? ")
		For nI := 1 To Len(aTabExclui[nTipoImp,2])
			cSQL := "delete from "+RetSqlName(aTabExclui[nTipoImp,2,nI])
			If (TCSQLExec(cSQL) < 0)
				Return MsgStop("TCSQLError() " + TCSQLError())
			EndIf
			cSQL := "delete from "+RetSqlName("AO4") + " where AO4_ENTIDA = '" + aTabExclui[nTipoImp,2,nI] + "'"
			If (TCSQLExec(cSQL) < 0)
				Return MsgStop("TCSQLError() " + TCSQLError())
			EndIf
		Next nI
	EndIf
	*/

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

	//Arquivo Itens
	MsgAlert("Agora é o arquivo de ITENS!","ATENÇÃO")
	cArqd := cGetFile("Todos os Arquivos|*.csv", OemToAnsi("Informe o diretório onde se encontra o arquivo."), 0, "SERVIDOR\", .F., GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE ,.T.)

	If !File(cArqd)
		MsgStop("O arquivo " +cArqd + " não foi selecionado. A importação será abortada!","ATENCAO")
		Return
	EndIf

	FT_FUSE(cArqd)
	FT_FGOTOP()
	cLinhad    := FT_FREADLN()
	aTipoImpd  := Separa(cLinhad,";",.T.)
	cTipod     := SUBSTR(aTipoImpd[1],1,2)

	IF !(cTIPOd $('CK'))
		MsgAlert('Não é possivel importar a tabela: '+cTipod+ '  !!')
		Return
	ENDIF

	// monta filtro para consulta SX3				
	cFiltroSX3 := " SX3.X3_ARQUIVO = 'SCK' "																																														

	// função que consulta tabela SX3
	aCamposSX3 := U_TBCFAUX2(cFiltroSX3)

	If !U_TBCFAUX1(aTipoImpd, aCamposSX3, cTipod)
		Return
	Endif

	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()
	While !FT_FEOF()
		IncProc("Lendo arquivo texto...")
		cLinhad := FT_FREADLN()
		If lPrimd
			aCamposd := Separa(cLinhad,";",.T.)
			lPrimd := .F.
		Else
			AADD(aDadosd,Separa(cLinhad,";",.T.))
		EndIf
		FT_FSKIP()
	EndDo

	cBemN1  := ""
	cBemN3  := ""
	cItemN1 := ""
	cItemN3 := ""

	//Monta array do cabeçalho
	ProcRegua(Len(aDados))
	For nI:=1 to  Len(aDados)
		IncProc("Importando arquivos...")
		nObjProc ++
		aExecAuto  := {}
		aExecAutod := {}
		For nCampos := 1 To Len(aCampos)
			IF  SUBSTR(Upper(aCampos[nCampos]),4,6)=='FILIAL'
				IF !EMpty(aDados[nI,nCampos])
					cFilAnt := aDados[nI,nCampos]
				ENDIF
			Else
				IF  TamSx3(Upper(aCampos[nCampos]))[3] =='N'
					aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	VAL(aDados[nI,nCampos] )	,Nil})
				ELSEIF TamSx3(Upper(aCampos[nCampos]))[3] =='D'
					aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  CTOD(aDados[nI,nCampos] )	,Nil})
				ELSE
					aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	aDados[nI,nCampos] 	,Nil})
				ENDIF
			ENDIF
		Next nCampos

		cBemN1  := aDados[nI][1]
		cItemN1 := aDados[nI][2]

		//Monta array dos itens
		For nId:=1 to  Len(aDadosd)

			cBemN3  := aDadosd[nId][1]
			cItemN3 := aDadosd[nId][2]

			aExecAutol := {}
			IF cBemN3 == cBemN1 .AND. cItemN3 == cItemN1
				For nCamposd := 1 To Len(aCamposd)
					//	IF  SUBSTR(Upper(aCamposd[nCamposd]),4,6)=='FILIAL'
					//		IF !EMpty(aDadosd[nId,nCamposd])
					//			cFilAnt := aDadosd[nId,nCamposd]
					//		ENDIF
					//	Else
					IF  TamSx3(Upper(aCamposd[nCamposd]))[3] =='N'
						aAdd(aExecAutol ,{Upper(aCamposd[nCamposd]), 	VAL(aDadosd[nId,nCamposd] )	,Nil})
					ELSEIF TamSx3(Upper(aCamposd[nCamposd]))[3] =='D'
						aAdd(aExecAutol ,{Upper(aCamposd[nCamposd]),  CTOD(aDadosd[nId,nCamposd] )	,Nil})
					ELSE
						aAdd(aExecAutol ,{Upper(aCamposd[nCamposd]), 	aDadosd[nId,nCamposd] 	,Nil})
					ENDIF
					//	ENDIF
				Next nCamposd
				aAdd(aExecAutod, aExecAutol)
			ENDIF
		Next nId

		// Executa MSEXECAUTO
		lMsErroAuto := .F.
		Begin Transaction
			MSExecAuto({|x,y,z| MATA415(x,y,z)},aExecAuto,aExecAutod,3) // SCJ/SCK Orçamento pedido de ven da CABECALHO/ITENS

			//Caso ocorra erro, verifica se ocorreu antes ou depois dos primeiros 100 registros do arquivo
			If lMsErroAuto
				
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
