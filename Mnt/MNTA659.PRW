#Include 'Protheus.ch'
#INCLUDE "MNTA659.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA659
Rotina para realizar validações de abastecimento de acordo com o parâmetro MV_NGABAVL

@author Maria Elisandra de Paula
@since 07/10/2015
@version P12
@return aReturn
/*/
//---------------------------------------------------------------------
Function MNTA659()

	Local oDlg,oPanelTop,oPanelLeft,oPanelBot
	Local lOk 	 := .F.
	Local aItens := {STR0001}//"Abastecimento"
	Local cProc	 := ""
	Local cMens	 := STR0002 + CRLF + STR0003 // "Selecione as opções em que o cadastro de Abastecimento " #  "deverá considerar em sua avaliação:"
	Local cTexto := ""

	Local nI
	Local lEsquema 	 := .F.
	Local lEstrutura := .F.
	Local lManutPad  := .F.
	Local lManut	 := .F.

	Local cParam := GetMv("MV_NGABAVL") // Manter o GetMV já que este comando pega o valor sempre atualizado. Ver Task #14852
	Local aParam := StrTokArr(cParam,';')
	Local aCheck := {}
	Local nX     := 0
	Local nTop   := 0

	lEsquema 	:= Len(aParam) >= 1 .And. aParam[1] == "1"
	lEstrutura	:= Len(aParam) >= 2 .And. aParam[2] == "1"
	lManutPad 	:= Len(aParam) >= 3 .And. aParam[3] == "1"
	lManut 	    := Len(aParam) >= 4 .And. aParam[4] == "1"

	cTexto1 := STR0004 + CRLF //"Esquema Padrão:será avaliado se o veículo possui um"
	cTexto1 += STR0005 + CRLF //"esquema padrão (TQ0 e TQ1) cadastrado, conforme rotinas"
	cTexto1 += STR0006 + CRLF //"padrão de Esquema (MNTA220 e MNTA221). Caso não exista"
	cTexto1 += STR0007 + CRLF //"registro de esquema vinculado com a família e modelo"
	cTexto1 += STR0008 			 //"do veículo, o processo de abastecimento será bloqueado."

	cTexto2	:= STR0009 + CRLF //"Estrutura Padrão:será avaliado se o veículo possui estrutura "
	cTexto2	+= STR0010 + CRLF //"padrão (STC) cadastrado, conforme rotina de Estrutura Padrão (MNTA095)."
	cTexto2	+= STR0011 + CRLF // "Caso não exista registro de estrutura padrão vinculado com a família e"
	cTexto2	+= STR0012 + CRLF //"modelo do veículo, o processo de abastecimento será bloqueado."
	cTexto2 += STR0013 + CRLF //"A partir do esquema padrão, será avaliado se o veículo possui os devidos"
	cTexto2 += STR0014 + CRLF //"componentes obrigatórios, conforme configurado pela rotina de estrutura"
	cTexto2 += STR0015 + CRLF //"padrão, cadastrados na estrutura de bens (STC). Caso não tenha, será"
	cTexto2 += STR0016 			 //"bloqueada a operação de abastecimento. Exemplo: Posição sem pneu."

	cTexto3 := STR0017 + CRLF	//"Manutenção Padrão:será avaliado se o veículo"
	cTexto3 += STR0018 + CRLF	//"possui ao menos um registro de manutenção"
	cTexto3 += STR0019 + CRLF	//"padrão (TPF) cadastrado pela rotina de Manutenção"
	cTexto3 += STR0020 + CRLF	//"Padrão (MNTA180). Caso não exista registro de manutenção"
	cTexto3 += STR0021 + CRLF	//"padrão vinculado com a família e modelo do veículo, o"
	cTexto3 += STR0022 				//"processo de abastecimento será bloqueado."

	cTexto4 := STR0023 + CRLF //"Manutenção:o veículo deverá possuir todas"
	cTexto4 += STR0024 + CRLF //"as manutenções cadastradas (STF)"
	cTexto4 += STR0025 + CRLF //"verificando a partir da Manutenção Padrão (TPF),"
	cTexto4 += STR0026 + CRLF //"caso falte alguma manutenção (STF) será bloqueado"
	cTexto4 += STR0027 			 //"a operação de abastecimento."

	//P.E para adicionar itens de checkbox - Estrutura do vetor aCheck: {nTipo(1- Abastecimento),cTítulo,cHelp,lValue(valor inicial),bBlock (Bloco de Código})
	If ExistBlock("MNTA6591")
		aCheck := ExecBlock("MNTA6591",.F.,.F.)
	EndIf

	DEFINE DIALOG oDlg TITLE STR0028  FROM 0,0 TO 250,300 PIXEL // "Plano de Liberação de Abastecimento"

   		oPanelTop:= tPanel():New(0,0,,oDlg,,,,,,00,40)
   			oPanelTop:align:= CONTROL_ALIGN_TOP
			@ 10,03 Say STR0029 Of oPanelTop Pixel //'Processo:'
			@ 07,30 Combobox cProc Items aItens size 60,07 Of oPanelTop Pixel
			@ 22,03 Say cMens Of oPanelTop Pixel

		oPanelLeft  := TScrollBox():New(oDlg,0,0,70,70,.T.,.T.,.T.)
   			oPanelLeft:align:= CONTROL_ALIGN_ALLCLIENT

			@ 05,03 CheckBox lEsquema   PROMPT STR0030 MESSAGE cTexto1 Size 128,10 Of oPanelLeft Pixel //"Esquema Padrão"
			@ 15,03 CheckBox lEstrutura PROMPT STR0031 MESSAGE cTexto2 Size 128,10 Of oPanelLeft Pixel //"Estrutura Padrão"
			@ 25,03 CheckBox lManutPad  PROMPT STR0032 MESSAGE cTexto3 Size 128,10 Of oPanelLeft Pixel //"Manutenção Padrão"
			@ 35,03 CheckBox lManut		PROMPT STR0033 MESSAGE cTexto4 Size 128,10 Of oPanelLeft Pixel //"Manutenção"

			//Cria mais opções de checkbox a partir do ponto de entrada MNTA6591
			nTop := 35
			For nX := 1 To Len(aCheck)

				If aCheck[nX][1] == 1 // 1  Abastecimento
					 &("lChk"+cValToChar(nX)) := aCheck[nX][4] // variável dinâmica que recebe o valor t ou f
					nTop+= 10

					o := TCheckBox():New(nTop,03,aCheck[nX][2],&("{|| lChk"+ cValToChar(nX)+"}"),oPanelLeft,128,10,,,,,,,,,aCheck[nX][3]) // cria um checkbox para cada posição do vetor
					o:bLClicked := &("{|| lChk"+ cValToChar(nX)+" := !lChk"+ cValToChar(nX)+"}")

				EndIf
			Next nX

		oPanelBot:= tPanel():New(0,0,,oDlg,,,,,,00,20)
   			oPanelBot:align:= CONTROL_ALIGN_BOTTOM
   			TButton():New(03,50,STR0034 , oPanelBot,{|| lOk := .t., oDlg:End() },45,12,,,,.T.,,,,,,) //"Confirmar"
   			TButton():New(03,100, STR0035 , oPanelBot,{|| oDlg:End()},45,12,,,,.T.,,,,,,) //"Cancelar"

	ACTIVATE DIALOG oDlg CENTERED

	If lOk
		aParam := {lEsquema,lEstrutura,lManutPad, lManut}
		cParam := ""
		For nI := 1 to 4
			If aParam[nI]
				cParam += "1;"
			Else
				cParam += "2;"
			EndIf
		Next

		PutMV("MV_NGABAVL",cParam)

		For nX := 1 To Len(aCheck)

			EVal(aCheck[nX][5], &("lChk"+ cValToChar(nX))) // executa o bloco de código para cada item de checkbox

		Next nX

	EndIf
Return
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT659VAL
Rotina para realizar validações de abastecimento de acordo com o parâmetro MV_NGABAVL

@author Maria Elisandra de Paula
@since 07/10/2015
@version P11
@return aReturn
Ex.:Retorno
{{"Mensagem"}- Mensagem que será apresentada no abastecimento manual
{{.F.," 47"} - Validação de Esquema Padrão	 - código da inconsistencia pela importação
{.F.," 48"}  - Validação de Estrutura Padrão - código da inconsistencia pela importação
{.F.," 49"}  - Validação de Manutenção Padrão- código da inconsistencia pela importação
{.F.," 50"}}}- Validação de Manutenção		 - código da inconsistencia pela importação
/*/
//---------------------------------------------------------------------
Function MNT659VAL(cCodBem,cFilBem,dDtAbast,cHhAbast)

	Local aArea := GetArea()
	Local nI
	Local lAchouStf:= .t.
	Local lAchouStc:= .t.
	Local cMensStf	:= ""
	Local cMensStc	:= ""
	Local cQuery 	:= ""
	Local cAliasQry := ""
	Local lTemStc   := .t.
	/*
	aReturn
	1 - Mensagem de Erro
	[2][1] - Se validação de Esquema Padrão está ok
	[2][2] - Se validação de Estrutura Padrão está ok
	[2][3] - Se validação de Manutenção Padrão está ok
	[2][4] - Se validação de Manutenção está ok
	*/
	Local aReturn:= {{STR0040 + cCodBem + CRLF + CRLF},{{.T.," 47"},{.T.," 48"},{.T.," 49"},{.T.," 50"}}} //"Inconsistências do Bem: "
	Local cParam:= GetMv("MV_NGABAVL") // Manter o GetMV já que este comando pega o valor sempre atualizado. Ver Task #14852
	Local aParam := StrTokArr(cParam,';')
	Local lEsquema  := Len(aParam) >= 1 .And. aParam[1] == "1" // Se vai validar Esquema Padrão
	Local lEstrutura:= Len(aParam) >= 2 .And. aParam[2] == "1" // Se vai validar Estrutura Padrão
	Local lManutPad := Len(aParam) >= 3 .And. aParam[3] == "1" // Se vai validar Manutenção
 	Local lManut    := Len(aParam) >= 4 .And. aParam[4] == "1" // Se vai validar Manutenção Padrão
 	Local nTotal := 0

	dbSelectArea("ST9")
	dbSetOrder(1)
	If dbSeek(cFilBem + cCodBem)

		//Verifica se existe Esquema Padrão para o bem
		If lEsquema
			aReturn[2][1][1] := .F.
			dbSelectArea("TQ0")
			dbSetOrder(1)
			If dbSeek(xFilial("TQ0",cFilBem) + ST9->T9_CODFAMI + ST9->T9_TIPMOD)
				dbSelectArea("TQ1")
				dbSetOrder(1)
				If dbSeek(xFilial("TQ1",cFilBem) + ST9->T9_CODFAMI + ST9->T9_TIPMOD)
					aReturn[2][1][1] := .t.
				EndIf
			EndIf
		EndIf

		//Verifica se existe Estrutura Padrão para o bem
		If lEstrutura // Se o parâmetro estiver habilitado, deve validar
			dbSelectArea("STC")
			dbSetOrder(5)
			If dbSeek(xFilial("STC",cFilBem) + PadR(ST9->T9_CODFAMI,Len(STC->TC_CODBEM)) + ST9->T9_TIPMOD)
				While !STC->(Eof()) .And. PadR(ST9->T9_CODFAMI,Len(STC->TC_CODBEM)) == STC->TC_CODBEM .And.  ST9->T9_TIPMOD == STC->TC_TIPMOD
					If STC->TC_OBRIGAT == 'S'
						cAliasQry := GetNextAlias()

						cQuery := " SELECT COUNT(*) AS TOTAL FROM " + RetSqlName("STZ") + " WHERE TZ_BEMPAI = " + ValToSql(cCodBem)
						cQuery += " AND TZ_LOCALIZ = " + ValToSql(STC->TC_LOCALIZ)
						cQuery += " AND TZ_DATAMOV||TZ_HORAENT  <= " + ValToSql(DtoS(dDtAbast) + cHhAbast)
						cQuery += " AND (TZ_DATASAI||TZ_HORASAI >= " + ValToSql(DtoS(dDtAbast) + cHhAbast)
						cQuery += " OR TZ_DATASAI||TZ_HORASAI = '') "
						cQuery += " AND D_E_L_E_T_ <> '*' AND TZ_FILIAL = " + ValToSql(xFilial("STZ",cFilBem))
						cQuery := ChangeQuery(cQuery)
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

						nTotal := (cAliasQry)->TOTAL
						(cAliasQry)->(dbCloseArea())

						//Se estiver faltando componente na localização obrigatória
						If nTotal == 0
							cMensStc += STR0037 + AllTrim(STC->TC_LOCALIZ) //"  Localização: "
							lAchouStc := .F.
							Exit
						EndIf
					EndIf

					STC->(DbSkip())
				EndDo

				//Identifica se a estrutura STC está completa ou não (.T. está ok, .F. está faltando algo)
				aReturn[2][2][1] := lAchouStc
			Else
				aReturn[2][2][1] := .F.
				lTemStc := .F.
			EndIf

		EndIf
			// Verifica se existe Manutenção Padrão para o bem
		If lManutPad
			dbSelectArea("TPF")
			dbSetOrder(4)
			If !dbSeek(xFilial("TPF",cFilBem) + ST9->T9_CODFAMI + ST9->T9_TIPMOD)
				aReturn[2][3][1] := .F.
			EndIf
		Endif

		// Verifica se existe as manutenções para o bem
		If lManut
			dbSelectArea("TPF")
			dbSetOrder(4)
			If dbSeek(xFilial("TPF",cFilBem) + ST9->T9_CODFAMI + ST9->T9_TIPMOD)
				While !TPF->(Eof()) .And. ST9->T9_CODFAMI == TPF->TPF_CODFAM .And.  ST9->T9_TIPMOD == TPF->TPF_TIPMOD
					dbSelectArea("STF")
					dbSetOrder(1)
					If !dbSeek(xFilial("STF",cFilBem) + ST9->T9_CODBEM + TPF->TPF_SERVIC + TPF->TPF_SEQREL)
						lAchouStf := .F.
						cMensStf += STR0038 + TPF->TPF_SERVIC + " /" + STR0039 + TPF->TPF_SEQREL + CRLF  // "  Serviço: "
					EndIf
					TPF->(DbSkip())
				EndDo
			EndIf
			aReturn[2][4][1]:= lAchouStf
		EndIf

	EndIf

	//Altera primeiro vetor - mensagem de erro
	For nI := 1 to Len(aReturn[2])

		If aReturn[2][nI][1] == .F.
			If nI == 1
				aReturn[1][1] += STR0041 + CRLF + CRLF   // "Esquema Padrão"
			ElseIf nI == 2
				If !lTemStc
					aReturn[1][1] += STR0045 + CRLF + CRLF // "Estrutura Padrão: O bem não possui cadastro de estrutura padrão. É necessário realizar o cadastro previamente para realizar o abastecimento."
				Else
					aReturn[1][1] += STR0042 + cMensStc + CRLF + CRLF  // "Estrutura Padrão: A estrutura do bem não está completa de acordo com o cadastro de estrutura padrão. "
				EndIf
			ElseIf nI == 3
				aReturn[1][1] += STR0043 + CRLF + CRLF // "Manutenção Padrão"
			ElseIf nI == 4
				aReturn[1][1] += STR0044 + cMensStf  + CRLF + CRLF // "Manutenção" CLRF CRLF
			EndIf
		EndIf

	Next nI

	//PE para realizar mais validações de abastecimento
	If ExistBlock("MNTA6592")
		aReturn := ExecBlock("MNTA6592",.F.,.F.,{cCodBem,cFilBem,dDtAbast,cHhAbast,aReturn})
	EndIf

	RestArea(aArea)

Return aReturn
