#Include 'Protheus.ch'
#INCLUDE "MNTA659.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA659
Rotina para realizar valida��es de abastecimento de acordo com o par�metro MV_NGABAVL

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
	Local cMens	 := STR0002 + CRLF + STR0003 // "Selecione as op��es em que o cadastro de Abastecimento " #  "dever� considerar em sua avalia��o:"
	Local cTexto := ""

	Local nI
	Local lEsquema 	 := .F.
	Local lEstrutura := .F.
	Local lManutPad  := .F.
	Local lManut	 := .F.

	Local cParam := GetMv("MV_NGABAVL") // Manter o GetMV j� que este comando pega o valor sempre atualizado. Ver Task #14852
	Local aParam := StrTokArr(cParam,';')
	Local aCheck := {}
	Local nX     := 0
	Local nTop   := 0

	lEsquema 	:= Len(aParam) >= 1 .And. aParam[1] == "1"
	lEstrutura	:= Len(aParam) >= 2 .And. aParam[2] == "1"
	lManutPad 	:= Len(aParam) >= 3 .And. aParam[3] == "1"
	lManut 	    := Len(aParam) >= 4 .And. aParam[4] == "1"

	cTexto1 := STR0004 + CRLF //"Esquema Padr�o:ser� avaliado se o ve�culo possui um"
	cTexto1 += STR0005 + CRLF //"esquema padr�o (TQ0 e TQ1) cadastrado, conforme rotinas"
	cTexto1 += STR0006 + CRLF //"padr�o de Esquema (MNTA220 e MNTA221). Caso n�o exista"
	cTexto1 += STR0007 + CRLF //"registro de esquema vinculado com a fam�lia e modelo"
	cTexto1 += STR0008 			 //"do ve�culo, o processo de abastecimento ser� bloqueado."

	cTexto2	:= STR0009 + CRLF //"Estrutura Padr�o:ser� avaliado se o ve�culo possui estrutura "
	cTexto2	+= STR0010 + CRLF //"padr�o (STC) cadastrado, conforme rotina de Estrutura Padr�o (MNTA095)."
	cTexto2	+= STR0011 + CRLF // "Caso n�o exista registro de estrutura padr�o vinculado com a fam�lia e"
	cTexto2	+= STR0012 + CRLF //"modelo do ve�culo, o processo de abastecimento ser� bloqueado."
	cTexto2 += STR0013 + CRLF //"A partir do esquema padr�o, ser� avaliado se o ve�culo possui os devidos"
	cTexto2 += STR0014 + CRLF //"componentes obrigat�rios, conforme configurado pela rotina de estrutura"
	cTexto2 += STR0015 + CRLF //"padr�o, cadastrados na estrutura de bens (STC). Caso n�o tenha, ser�"
	cTexto2 += STR0016 			 //"bloqueada a opera��o de abastecimento. Exemplo: Posi��o sem pneu."

	cTexto3 := STR0017 + CRLF	//"Manuten��o Padr�o:ser� avaliado se o ve�culo"
	cTexto3 += STR0018 + CRLF	//"possui ao menos um registro de manuten��o"
	cTexto3 += STR0019 + CRLF	//"padr�o (TPF) cadastrado pela rotina de Manuten��o"
	cTexto3 += STR0020 + CRLF	//"Padr�o (MNTA180). Caso n�o exista registro de manuten��o"
	cTexto3 += STR0021 + CRLF	//"padr�o vinculado com a fam�lia e modelo do ve�culo, o"
	cTexto3 += STR0022 				//"processo de abastecimento ser� bloqueado."

	cTexto4 := STR0023 + CRLF //"Manuten��o:o ve�culo dever� possuir todas"
	cTexto4 += STR0024 + CRLF //"as manuten��es cadastradas (STF)"
	cTexto4 += STR0025 + CRLF //"verificando a partir da Manuten��o Padr�o (TPF),"
	cTexto4 += STR0026 + CRLF //"caso falte alguma manuten��o (STF) ser� bloqueado"
	cTexto4 += STR0027 			 //"a opera��o de abastecimento."

	//P.E para adicionar itens de checkbox - Estrutura do vetor aCheck: {nTipo(1- Abastecimento),cT�tulo,cHelp,lValue(valor inicial),bBlock (Bloco de C�digo})
	If ExistBlock("MNTA6591")
		aCheck := ExecBlock("MNTA6591",.F.,.F.)
	EndIf

	DEFINE DIALOG oDlg TITLE STR0028  FROM 0,0 TO 250,300 PIXEL // "Plano de Libera��o de Abastecimento"

   		oPanelTop:= tPanel():New(0,0,,oDlg,,,,,,00,40)
   			oPanelTop:align:= CONTROL_ALIGN_TOP
			@ 10,03 Say STR0029 Of oPanelTop Pixel //'Processo:'
			@ 07,30 Combobox cProc Items aItens size 60,07 Of oPanelTop Pixel
			@ 22,03 Say cMens Of oPanelTop Pixel

		oPanelLeft  := TScrollBox():New(oDlg,0,0,70,70,.T.,.T.,.T.)
   			oPanelLeft:align:= CONTROL_ALIGN_ALLCLIENT

			@ 05,03 CheckBox lEsquema   PROMPT STR0030 MESSAGE cTexto1 Size 128,10 Of oPanelLeft Pixel //"Esquema Padr�o"
			@ 15,03 CheckBox lEstrutura PROMPT STR0031 MESSAGE cTexto2 Size 128,10 Of oPanelLeft Pixel //"Estrutura Padr�o"
			@ 25,03 CheckBox lManutPad  PROMPT STR0032 MESSAGE cTexto3 Size 128,10 Of oPanelLeft Pixel //"Manuten��o Padr�o"
			@ 35,03 CheckBox lManut		PROMPT STR0033 MESSAGE cTexto4 Size 128,10 Of oPanelLeft Pixel //"Manuten��o"

			//Cria mais op��es de checkbox a partir do ponto de entrada MNTA6591
			nTop := 35
			For nX := 1 To Len(aCheck)

				If aCheck[nX][1] == 1 // 1  Abastecimento
					 &("lChk"+cValToChar(nX)) := aCheck[nX][4] // vari�vel din�mica que recebe o valor t ou f
					nTop+= 10

					o := TCheckBox():New(nTop,03,aCheck[nX][2],&("{|| lChk"+ cValToChar(nX)+"}"),oPanelLeft,128,10,,,,,,,,,aCheck[nX][3]) // cria um checkbox para cada posi��o do vetor
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

			EVal(aCheck[nX][5], &("lChk"+ cValToChar(nX))) // executa o bloco de c�digo para cada item de checkbox

		Next nX

	EndIf
Return
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT659VAL
Rotina para realizar valida��es de abastecimento de acordo com o par�metro MV_NGABAVL

@author Maria Elisandra de Paula
@since 07/10/2015
@version P11
@return aReturn
Ex.:Retorno
{{"Mensagem"}- Mensagem que ser� apresentada no abastecimento manual
{{.F.," 47"} - Valida��o de Esquema Padr�o	 - c�digo da inconsistencia pela importa��o
{.F.," 48"}  - Valida��o de Estrutura Padr�o - c�digo da inconsistencia pela importa��o
{.F.," 49"}  - Valida��o de Manuten��o Padr�o- c�digo da inconsistencia pela importa��o
{.F.," 50"}}}- Valida��o de Manuten��o		 - c�digo da inconsistencia pela importa��o
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
	[2][1] - Se valida��o de Esquema Padr�o est� ok
	[2][2] - Se valida��o de Estrutura Padr�o est� ok
	[2][3] - Se valida��o de Manuten��o Padr�o est� ok
	[2][4] - Se valida��o de Manuten��o est� ok
	*/
	Local aReturn:= {{STR0040 + cCodBem + CRLF + CRLF},{{.T.," 47"},{.T.," 48"},{.T.," 49"},{.T.," 50"}}} //"Inconsist�ncias do Bem: "
	Local cParam:= GetMv("MV_NGABAVL") // Manter o GetMV j� que este comando pega o valor sempre atualizado. Ver Task #14852
	Local aParam := StrTokArr(cParam,';')
	Local lEsquema  := Len(aParam) >= 1 .And. aParam[1] == "1" // Se vai validar Esquema Padr�o
	Local lEstrutura:= Len(aParam) >= 2 .And. aParam[2] == "1" // Se vai validar Estrutura Padr�o
	Local lManutPad := Len(aParam) >= 3 .And. aParam[3] == "1" // Se vai validar Manuten��o
 	Local lManut    := Len(aParam) >= 4 .And. aParam[4] == "1" // Se vai validar Manuten��o Padr�o
 	Local nTotal := 0

	dbSelectArea("ST9")
	dbSetOrder(1)
	If dbSeek(cFilBem + cCodBem)

		//Verifica se existe Esquema Padr�o para o bem
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

		//Verifica se existe Estrutura Padr�o para o bem
		If lEstrutura // Se o par�metro estiver habilitado, deve validar
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

						//Se estiver faltando componente na localiza��o obrigat�ria
						If nTotal == 0
							cMensStc += STR0037 + AllTrim(STC->TC_LOCALIZ) //"  Localiza��o: "
							lAchouStc := .F.
							Exit
						EndIf
					EndIf

					STC->(DbSkip())
				EndDo

				//Identifica se a estrutura STC est� completa ou n�o (.T. est� ok, .F. est� faltando algo)
				aReturn[2][2][1] := lAchouStc
			Else
				aReturn[2][2][1] := .F.
				lTemStc := .F.
			EndIf

		EndIf
			// Verifica se existe Manuten��o Padr�o para o bem
		If lManutPad
			dbSelectArea("TPF")
			dbSetOrder(4)
			If !dbSeek(xFilial("TPF",cFilBem) + ST9->T9_CODFAMI + ST9->T9_TIPMOD)
				aReturn[2][3][1] := .F.
			EndIf
		Endif

		// Verifica se existe as manuten��es para o bem
		If lManut
			dbSelectArea("TPF")
			dbSetOrder(4)
			If dbSeek(xFilial("TPF",cFilBem) + ST9->T9_CODFAMI + ST9->T9_TIPMOD)
				While !TPF->(Eof()) .And. ST9->T9_CODFAMI == TPF->TPF_CODFAM .And.  ST9->T9_TIPMOD == TPF->TPF_TIPMOD
					dbSelectArea("STF")
					dbSetOrder(1)
					If !dbSeek(xFilial("STF",cFilBem) + ST9->T9_CODBEM + TPF->TPF_SERVIC + TPF->TPF_SEQREL)
						lAchouStf := .F.
						cMensStf += STR0038 + TPF->TPF_SERVIC + " /" + STR0039 + TPF->TPF_SEQREL + CRLF  // "  Servi�o: "
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
				aReturn[1][1] += STR0041 + CRLF + CRLF   // "Esquema Padr�o"
			ElseIf nI == 2
				If !lTemStc
					aReturn[1][1] += STR0045 + CRLF + CRLF // "Estrutura Padr�o: O bem n�o possui cadastro de estrutura padr�o. � necess�rio realizar o cadastro previamente para realizar o abastecimento."
				Else
					aReturn[1][1] += STR0042 + cMensStc + CRLF + CRLF  // "Estrutura Padr�o: A estrutura do bem n�o est� completa de acordo com o cadastro de estrutura padr�o. "
				EndIf
			ElseIf nI == 3
				aReturn[1][1] += STR0043 + CRLF + CRLF // "Manuten��o Padr�o"
			ElseIf nI == 4
				aReturn[1][1] += STR0044 + cMensStf  + CRLF + CRLF // "Manuten��o" CLRF CRLF
			EndIf
		EndIf

	Next nI

	//PE para realizar mais valida��es de abastecimento
	If ExistBlock("MNTA6592")
		aReturn := ExecBlock("MNTA6592",.F.,.F.,{cCodBem,cFilBem,dDtAbast,cHhAbast,aReturn})
	EndIf

	RestArea(aArea)

Return aReturn
