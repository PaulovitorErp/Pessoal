#include 'protheus.ch'
#include 'parmtype.ch'

Static cPulaLinha	:= Chr(13) + Chr(10)

/*
=====================================================================================
Programa.:              TBCF001
Autor....:         		Raquel Pereira     
Data.....:              06/09/2019
Descricao / Objetivo:   Importa estrutura de produtos - SG1
Uso......:               
Obs......:              
=====================================================================================
*/

User Function TBCF003(oSay,cArquivo,nHdlLog,nObjProc,nSucesso)

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
		{'C1',{"SC1"} } }
	Default oSay 		:= Nil
	Default cArquivo 	:= ""
	Default nHdlLog 	:= 0
	Default nObjProc 	:= 0
	Default nSucesso 	:= 0

	/*
	cArq := cGetFile("Todos os Arquivos|*.csv", OemToAnsi("Informe o diretório onde se encontra o arquivo."), 0, "SERVIDOR\", .F., GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE ,.T.)

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

	IF !(cTIPO $('G1'))
		MsgAlert('Não é possivel importar a tabela: '+cTipo+ '  !!')
		Return
	ENDIF

	// monta filtro para consulta SX3
	cFiltroSX3 := " SX3.X3_ARQUIVO = 'SG1' "

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

	//Pergunta se deseja excluir os dados do cadastro de estrutura antes de importar

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
		IncProc("Lendo arquivo texto...") // Lendo linhas do arquivo
		cLinha := FT_FREADLN()
		If lPrim
			aCampos := Separa(cLinha,";",.T.)
			lPrim := .F.
		Else
			AADD(aDados,Separa(cLinha,";",.T.))
		EndIf
		FT_FSKIP()
	EndDo

	// Processando arquivo
	cNiv := "01"
	cCod := ""
	cCpoCab := "G1_COD"
	ProcRegua(Len(aDados))

	For nI:=1 to  Len(aDados)
		IncProc("Importando arquivo...")

		nObjProc ++

		If cCod # aDados[nI][1] .AND. cNiv == aDados[nI][8]
			IF Len(aExecAuto) > 0
				lMsErroAuto := .F.
				Begin Transaction
					MSExecAuto({|x,y,z| MATA200(x,y,z)},aExecAuto,aExecAutod,3) // SG1 Estrutura de Produto

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
			If !_lok
				Return
			Endif
			_lok := .T.
			aExecAuto  := {}
			aExecAutod := {}
		Endif

		//Montando array de Cabeçalho
		For nCampos := 1 To Len(aCampos)
			If Alltrim(aCampos[nCampos]) $ cCpoCab
				aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	aDados[nI,nCampos] 	,Nil})
			Endif
		Next nCampos
		aAdd(aExecAuto ,{"G1_QUANT",1,NIL})
		aAdd(aExecAuto ,{"NIVALT","S",NIL})
	Endif
	nCampos := 1
	cCod := aDados[nI][1]

	//Monta array de ITENS
	aExecAutol := {}
	For nCampos := 1 To Len(aCampos)-1
		IF  SUBSTR(Upper(aCampos[nCampos]),4,6)=='FILIAL'
			IF !EMpty(aDados[nI,nCampos])
				cFilAnt := aDados[nI,nCampos]
			ENDIF
		Else
			IF  TamSx3(Upper(aCampos[nCampos]))[3] =='N'
				aAdd(aExecAutol ,{Upper(aCampos[nCampos]), 	VAL(aDados[nI,nCampos] )	,Nil})
			ELSEIF TamSx3(Upper(aCampos[nCampos]))[3] =='D'
				aAdd(aExecAutol ,{Upper(aCampos[nCampos]),  CTOD(aDados[nI,nCampos] )	,Nil})
			ELSE
				aAdd(aExecAutol ,{Upper(aCampos[nCampos]), 	aDados[nI,nCampos] 	,Nil})
			ENDIF
		ENDIF
	Next nCampos
	aAdd(aExecAutod, aExecAutol)
Next nI

// Processa execauto da ultima linha do arquivo lido
lMsErroAuto := .F.
Begin Transaction
	MSExecAuto({|x,y,z| MATA200(x,y,z)},aExecAuto,aExecAutod,3) // SG1 Estrutura de Produto
	If lMsErroAuto
		DisarmTransaction()
		MostraErro()
		cFilAnt := cBKFilial
		//Return
		_lok := .F.
	EndIF
End Transaction
If !_lok
Return
Endif
_lok := .T.

FT_FUSE()
cFilAnt := cBKFilial

Return