#Include "Protheus.ch"
#Include "Totvs.ch"
#Include "TbiConn.ch"

/*/-------------------------------------------------------------------
- Programa: UMNTA001
- Autor: Tarcisio Silva Miranda
- Data: 14/06/2024
- Descrição: Rotina de importação de combustiveis.
-------------------------------------------------------------------/*/

User Function UMNTA001()

	Local aArea 		:= FwGetArea()
	Local cLocFile 		:= ""
	Local aDados	 	:= {}
	Private cCadastro	:= "Importação de combustíveis"

	if MsgYesNo("Deseja apagar os movimentos retroativos da tabela?","Atenção!")
		FWMsgRun(,{|| fDelTR6() },'Aguarde...','Realizando deleção dos registros...')
		MsgInfo("Registros deletados com sucesso!","Atenção!")
	endif
	If fPergunte(@cLocFile)
		FwMsgRun(Nil, {|oSayBar| aDados := fGetRegs(cLocFile) }, "Aguarde... Realizando a leitura do arquivo...", "Iniciando o processo...")
		FwMsgRun(Nil, {|oSayBar| fGerTR6(aDados) }, "Aguarde... Atualizando as informações...", "Finalizando o processo...")
		MsgInfo("Registros importados com sucesso!","Atenção!")
	EndIf

	FwRestArea(aArea)

Return(Nil)

/*/-------------------------------------------------------------------
	- Programa: fGerTR6
	- Autor: Tarcisio Silva Miranda
	- Data: 14/06/2024
	- Descrição: Realiza a gravação da tabela.
-------------------------------------------------------------------/*/

Static Function fGerTR6(aDados)

	Local aAreaTR6 := TR6->(FwGetArea())
	Local aArea 	:= FwGetArea()
	Local aLinha	 := {}
	Local aCampos	 := {}
	Local nPosCmp	 := 1
	Local nPosTp	 := 2
	Local nPosIni	 := 3
	Local nPosTam	 := 4
	Local nPosHora	 := 0
	Local nPosData	 := 0
	Local nPosPlaca  := 0
	Local nPosAbast  := 0
	Local nX		 := 0
	Local nY 		 := 0
	Local cHora 	 := ""
	Local cPlaca 	 := ""
	Local cNumAbast  := ""
	Local cData 	 := ""
	Local lPrimeiro  := .F.
	Default aDados 	 := {}

	//Verifica se tem registros no arquivo.
	If len(aDados) > 0
		//Pega todos os campos do layout.
		aCampos 	:= fGetTQ8()
		//Pega as posições dos campos abaixo para validar se já existem na base.
		nPosHora 	:= aScan(aCampos,{|x|Alltrim(Upper(x[1])) == "TR6_HRABAS" })
		nPosPlaca	:= aScan(aCampos,{|x|Alltrim(Upper(x[1])) == "TR6_PLACA" })
		nPosData 	:= aScan(aCampos,{|x|Alltrim(Upper(x[1])) == "TR6_DTABAS" })
		nPosAbast 	:= aScan(aCampos,{|x|Alltrim(Upper(x[1])) == "TR6_NUMABA" })
		//Percorre os registros do arquivo.
		for nY := 1 to len(aDados)
			//Utiliza a variavel linha como auxiliar para logica e manipulação dos dados.
			aLinha := aDados[nY]
			//Se for a primeira linha eu pulo, por que ela não deve ser importada.
			if !lPrimeiro
				lPrimeiro := .T.
				loop
			endif
			//formato as variaveis para validar se os registros já existem na base.
			cHora 		:= PadR(AllTrim(SubStr(aLinha, aCampos[nPosHora][nPosIni], aCampos[nPosHora][nPosTam])),TamSx3("TR6_HRABAS")[1])
			cPlaca 		:= PadR(AllTrim(SubStr(aLinha, aCampos[nPosPlaca][nPosIni], aCampos[nPosPlaca][nPosTam])),TamSx3("TR6_PLACA")[1])
			cData 		:= PadR(dTos(cTod(SubStr(aLinha, aCampos[nPosData][nPosIni], aCampos[nPosData][nPosTam]))),TamSx3("TR6_DTABAS")[1])
			cNumAbast 	:= PadR(AllTrim(SubStr(aLinha, aCampos[nPosAbast][nPosIni], aCampos[nPosAbast][nPosTam])),TamSx3("TR6_NUMABA")[1])
			//Valido se os registros já existem na base.
			while TR6->(DbSetOrder(2),DbSeek( FWxFilial("TR6") + cPlaca + cData + cHora ))
				cHora := SubStr(IncTime(cHora, 0, 1, 0),1,5)
			enddo
			//Valido se os registros já existem na base.
			while TR6->(DbSetOrder(1),DbSeek( cNumAbast ))
				cNumAbast := Soma1(cNumAbast)
			enddo
			//Inicio o processo de gravação dos dados.
			TR6->(RecLock("TR6",.T.))
			//Percorro os campos do layuout para a gravação.s
			For nX := 1 to Len(aCampos)
				//Se for o campo hora, eu faço a logica para não dar registro duplicado.
				if aCampos[nX][nPosCmp] == "TR6_HRABAS"
					TR6->&(aCampos[nX][nPosCmp]) := cHora
					//Se for o campo o numero do abastecimento, eu faço a logica para não dar registro duplicado.
				elseif aCampos[nX][nPosCmp] == "TR6_NUMABA"
					TR6->&(aCampos[nX][nPosCmp]) := cNumAbast
					//Se for numerico eu trato a variavel.
				elseif aCampos[nX][nPosTp] == "N"
					TR6->&(aCampos[nX][nPosCmp]) := Val(SubStr(aLinha, aCampos[nX][nPosIni], aCampos[nX][nPosTam]))
					//Se for data eu faço o tratamento de data.
				ElseIf aCampos[nX][nPosTp] == "D"
					TR6->&(aCampos[nX][nPosCmp]) := cTod(SubStr(aLinha, aCampos[nX][nPosIni], aCampos[nX][nPosTam]))
					//Se for normal eu não faço tratamento.
				Else
					TR6->&(aCampos[nX][nPosCmp]) := SubStr(aLinha, aCampos[nX][nPosIni], aCampos[nX][nPosTam])
				EndIf
			Next nX
			//Finalizo a gravação.
			TR6->(MsUnLock())
		next nY
	EndIf

	FwRestArea(aAreaTR6)
	FwRestArea(aArea)

Return(Nil)

/*/-------------------------------------------------------------------
	- Programa: fGetRegs
	- Autor: Tarcisio Silva Miranda
	- Data: 14/06/2024
	- Descrição: Realiza a leitura do arquivo.
-------------------------------------------------------------------/*/

Static Function fGetRegs(cLocFile)

	Local oFile         := FWFileReader():New(cLocFile)
	Local aReturn       := {}
	Default cLocFile    := ""

	//Se o arquivo pode ser aberto
	If (oFile:Open())
		//Se não for fim do arquivo
		If ! (oFile:EoF())
			//Enquanto houver linhas a serem lidas
			While (oFile:HasLine())
				//Buscando o texto da linha atual
				aAdd(aReturn,oFile:GetLine())
			EndDo
		EndIf
		//Fecha o arquivo e finaliza o processamento
		oFile:Close()
	EndIf

Return(aReturn)

/*/-------------------------------------------------------------------
	- Programa: fGetTQ8
	- Autor: Tarcisio Silva Miranda
	- Data: 14/06/2024
	- Descrição: Pega somente os campos do layout.
-------------------------------------------------------------------/*/

Static Function fGetTQ8()

	Local aArea 	:= FwGetArea()
	Local cQuery	:= ""
	Local cAliasQry	:= ""
	Local aData		:= {}

	cQuery := " SELECT 								" + CRLF
	cQuery += "		TQ8_CPOTAB,						" + CRLF
	cQuery += "		TQ8_TIPO,						" + CRLF
	cQuery += "		TQ8_POSINI,						" + CRLF
	cQuery += "		TQ8_TAMARQ						" + CRLF
	cQuery += "	FROM "+ retsqlname("TQ8") +" TQ8	" + CRLF
	cQuery += "	WHERE TQ8.D_E_L_E_T_ = ' '			" + CRLF
	cQuery += "	    AND TQ8_CPOTAB LIKE 'TR6_%'		" + CRLF
	cQuery += "	    AND TQ8_CODLAY = '000006'		" + CRLF
	cQuery += "	ORDER BY TQ8_CODLAY					" + CRLF

	cAliasQry := MPSysOpenQuery(cQuery)

	While !(cAliasQry)->(Eof())
		aAdd(aData,{(cAliasQry)->TQ8_CPOTAB,(cAliasQry)->TQ8_TIPO,(cAliasQry)->TQ8_POSINI,(cAliasQry)->TQ8_TAMARQ})
		(cAliasQry)->(DbSkip())
	EndDO

	If Select(cAliasQry) > 0 .AND. !Empty(cAliasQry)
		(cAliasQry)->(DbCloseArea())
	EndIf

	FwRestArea(aArea)

Return(aData)

/*/-------------------------------------------------------------------
	- Programa: fPergunte
	- Autor: Tarcisio Silva Miranda
	- Data: 14/06/2024
	- Descrição: Simula a rotina de pergunta.
-------------------------------------------------------------------/*/

Static Function fPergunte(cLocFile)

	Local cProfile		:= "UMNTA001"
	Local aPar 			:= {}
	Local lRet 			:= .F.
	Local cArquivo 		:= PadR("",150)
	Local aPergunte 	:= {}
	Default cLocFile 	:= ""

	aAdd(aPar,{6,"Buscar arquivo",cArquivo,"","","",50,.F.,"Arquivos .TXT |*.TXT"})

	if lRet := ParamBox(aPar,"Parâmetros",@aPergunte,,,,,,,cProfile,.T.,.T.)
		cLocFile := AllTrim(aPergunte[1])
	endif

Return(lRet)

/*/-------------------------------------------------------------------
	- Programa: fDelTR6
	- Autor: Tarcisio Silva Miranda
	- Data: 14/06/2024
	- Descrição: Realiza a deleção da TR6.
-------------------------------------------------------------------/*/

Static Function fDelTR6()

	Local aAreaTR6 := TR6->(FwGetArea())

	TR6->(DbSelectArea("TR6"))
	While !TR6->(Eof())
		TR6->(RecLock("TR6",.F.))
		TR6->(DbDelete())
		TR6->(MsUnLock())
		TR6->(DbSkip())
	enddo

	FwRestArea(aAreaTR6)

Return(Nil)
