#INCLUDE	"Protheus.ch"
#INCLUDE	"MNTA131.ch"

//---------------------------------------------------------------------
/*/MNTA131
Importacao de Abastecimentos da Integracao com o GTFrota
da ExcelBr. (via arquivo .TXT)

TABELAS:
TQF - Postos
TR0 - Integração ExcelBr
TR6 - Abastecimentos Importados

@author Wagner Sobral de Lacerda
@since 05/09/2011

@return .T./.F.
/*/
//---------------------------------------------------------------------
Function MNTA131()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Armazena variaveis p/ devolucao (NGRIGHTCLICK)                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aNGBEGINPRM := NGBEGINPRM()
	Local nTTXMOTIVO := TAMSX3("TTX_MOTIVO")[1]

	Private cArquivo := ""
	Private nTipoArq := 0 //0 - Nenhum; 1 - Painel Online; 2 - Painel Offline

	Private lPrSB2			:= ( SuperGetMv("MV_NGPRSB2") == "S" ) //Parametro que indica se busca custo da SB2
	Private lConsComb 	:= ( SuperGetMv("MV_NGIMPOR",.F.,"1") == "2" ) //Parâmetro que indica se a Importação é pelo código do Convênio ("1") ou do Combustível ("2")
	Private cCodMotiv 	:= PADR(SuperGetMv("MV_NGMOTTR",.F.,""),nTTXMOTIVO," ") //Parâmetro que indica o código do Motivo da Transferência de Combustível (tabela TTX - Motivo de Saída)

	Private lHelp := .F. // Variável Private da função 'FWAliasInDic()', sendo .F. para não mostrar o help

	If !MNTA616OP()
		Return .F.
	EndIf

	If fAviso() //Pergunta: deseja realmente processar?
		If fArquivo() //Recebe o arquivo para efetuar a importacao
			Processa({|| fImportar() }, STR0001) // "Processando a Importação..."
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Devolve variaveis armazenadas (NGRIGHTCLICK)                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	NGRETURNPRM(aNGBEGINPRM)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fAviso
Apresenta uma Mensagem para o usuario, perguntando se ele
realmente deseja executar a importacao.

@author Wagner Sobral de Lacerda
@since 05/09/2011

@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fAviso()

	Local cMsg := ""

	cMsg += Space(5) + STR0002 // "Esta rotina tem por objetivo importar, de um arquivo TXT, os abastecimentos disponibilizados pelo convênio ExcelBR para o SIGAMNT."
	cMsg += CRLF + CRLF
	cMsg += Space(5) + STR0003 // "Antes de prosseguir, deve ser feita uma cópia de segurança dos arquivos e/ou tabelas TR6 em uso no sistema."
	cMsg += Space(1) + STR0004 // "Caso algum problema ocorra durante a execução do processo, as cópias de segurança devem ser restauradas."
	cMsg += CRLF
	cMsg += Space(5) + STR0005 // "Ainda, garantir a integridade da tabela complementar desta importação (tabela TR0 - Integração ExcelBr), sendo que os dados da importação dependem diretamente desta tabela."
	cMsg += CRLF + CRLF
	cMsg += STR0006 // "Este processo pode demorar alguns minutos."
	cMsg += CRLF
	cMsg += STR0007 // "Deseja efetuar o processamento?"

	If !ApMsgYesNo(cMsg,STR0010) // "Atenção"
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fArquivo
Recebe o arquivo para importar.

@author Wagner Sobral de Lacerda
@since 05/09/2011

@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fArquivo()

	Local cType   := STR0008 + " | *.txt" // "Arquivos de Texto"
	Local cTitulo := OemToAnsi(STR0009) // "Selecione o Arquivo (Abastecimentos GTFrota)"

	cArquivo := cGetFile(cType, cTitulo, , , , GETF_LOCALHARD + GETF_NETWORKDRIVE)

	If Empty(cArquivo)
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fImportar
Processa a importação.

@author Wagner Sobral de Lacerda
@since 05/09/2011

@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fImportar()

	Local aImport := {}
	Local cLinha  := "", cAuxLin := ""
	Local nHandle := 0

	Local nTam := 0
	Local nQtdGrv := 0, nQtdPro := 0
	Local cTipoArq := ""

	nHandle := FT_FUse(cArquivo)

	If nHandle == -1
		ApMsgStop(STR0011,STR0010) // "Não foi possível abrir o arquivo para leitura." ### "Atenção"
		Return .F.
	EndIf

	FT_FGoTop()

	//Verifica tipo de Arquivo (1 - Painel Online; 2 - Painel Offline)
	cLinha  := FT_FReadLn()
	If "(" $ cLinha .And. ")" $ cLinha .And. "/" $ cLinha //Cabecalho
		nTipoArq := If(Len(cLinha) < 200, 2, 1)
	Else //Conteudo
		nTipoArq := If(Len(cLinha) < 120, 2, 1)
	EndIf
	cTipoArq := If(nTipoArq == 1, STR0013 + " Online", STR0013 + " Offline") // "Painél" ### "Painél"

	ProcRegua(FT_FLastRec())

	While !FT_FEof()
		IncProc(STR0012 + " - " + cTipoArq) // "Processando arquivo"

		cLinha  := FT_FReadLn()
		aImport := {}

		//Verifica se e' Cabecalho
		If "(" $ cLinha .And. ")" $ cLinha .And. "/" $ cLinha
			FT_FSkip()
			Loop
		EndIf
		cAuxLin := cLinha

		nTam := 10
		aAdd(aImport, SubStr(cAuxLin,1,nTam)) //[1] - Data
		cAuxLin := SubStr(cAuxLin,nTam+2)

		nTam := 08
		aAdd(aImport, SubStr(cAuxLin,1,nTam)) //[2] - Hora
		cAuxLin := SubStr(cAuxLin,nTam+2)

		nTam := 15
		aAdd(aImport, SubStr(cAuxLin,1,nTam)) //[3] - Usuario
		cAuxLin := SubStr(cAuxLin,nTam+2)

		nTam := 15
		aAdd(aImport, SubStr(cAuxLin,1,nTam)) //[4] - Veiculo
		cAuxLin := SubStr(cAuxLin,nTam+2)

		nTam := 07
		aAdd(aImport, SubStr(cAuxLin,1,nTam)) //[5] - Hodometro
		cAuxLin := SubStr(cAuxLin,nTam+2)

		nTam := 10
		aAdd(aImport, SubStr(cAuxLin,1,nTam)) //[6] - Litros
		cAuxLin := SubStr(cAuxLin,nTam+2)

		nTam := 10
		aAdd(aImport, SubStr(cAuxLin,1,nTam)) //[7] - Km. Percorrido
		cAuxLin := SubStr(cAuxLin,nTam+2)

		nTam := 10
		aAdd(aImport, SubStr(cAuxLin,1,nTam)) //[8] - Observacao
		cAuxLin := SubStr(cAuxLin,nTam+2)

		nTam := If(nTipoArq == 1,04,02) //No Painel Online, o terminal tem 4 caracteres
		aAdd(aImport, SubStr(cAuxLin,1,nTam)) //[9] - Terminal
		cAuxLin := SubStr(cAuxLin,nTam+2)

		nTam := 01
		aAdd(aImport, SubStr(cAuxLin,1,nTam)) //[10] - Bomba
		cAuxLin := SubStr(cAuxLin,nTam+2)

		If nTipoArq == 1 //Somente para Painel Online
			nTam := 07
			aAdd(aImport, SubStr(cAuxLin,1,nTam)) //[11] - Horimetro
			cAuxLin := SubStr(cAuxLin,nTam+2)

			nTam := 07
			aAdd(aImport, SubStr(cAuxLin,1,nTam)) //[12] - Informacao Extra 1
			cAuxLin := SubStr(cAuxLin,nTam+2)

			nTam := 07
			aAdd(aImport, SubStr(cAuxLin,1,nTam)) //[13] - Informacao Extra 2
			cAuxLin := SubStr(cAuxLin,nTam+2)

			nTam := 07
			aAdd(aImport, SubStr(cAuxLin,1,nTam)) //[14] - Informacao Extra 3
			cAuxLin := SubStr(cAuxLin,nTam+2)

			nTam := 07
			aAdd(aImport, SubStr(cAuxLin,1,nTam)) //[15] - Informacao Extra 4
			cAuxLin := SubStr(cAuxLin,nTam+2)

			nTam := 07
			aAdd(aImport, SubStr(cAuxLin,1,nTam)) //[16] - Informacao Extra 5
			cAuxLin := SubStr(cAuxLin,nTam+2)

			nTam := 01
			aAdd(aImport, SubStr(cAuxLin,1,nTam)) //[17] - Situacao ("T" para abastecimentos de transferencia - COMBOIOS)
			cAuxLin := SubStr(cAuxLin,nTam+2)
		EndIf

		If fGravaTR6(aImport) //Grava a Importacao na TR6
			nQtdGrv++
		EndIf

		nQtdPro++

		FT_FSkip()
	End

	FT_FUse()
	FClose(nHandle)

	ApMsgInfo(STR0014 + CRLF + CRLF + ; // "Importação finalizada"
				STR0015 + " " + Transform(nQtdGrv,"@E 9,999,999") + " / " + Transform(nQtdPro,"@E 9,999,999") +".",STR0010) // "Registros Importados / Processados:" ### "Atenção"

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fGravaTR6
Processa a importação.

@param aGrava
	Array com a importação, no formato: * Obrigatório
	[1] - Data
	[2] - Hora
	[3] - Usuario
	[4] - Veiculo
	[5] - Hodometro
	[6] - Litros
	[7] - Km. Percorrido
	[8] - Observacao
	[9] - Terminal
	[10] - Bomba

@author Wagner Sobral de Lacerda
@since 05/09/2011

@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fGravaTR6(aGrava)

	// Variáveis do Abastecimento
	Local cNumAbast  	:= ""
	Local dDatAbast  	:= CTOD(aGrava[1])
	Local cHorAbast  	:= SubStr(aGrava[2],1,5)
	Local cCPFMotGen 	:= SuperGetMV("MV_NGMOTGE",.F.,"")
	Local nQtdComb   	:= Val(aGrava[6])
	Local cQtdComb   	:= aGrava[6]
	Local nKmAbast   	:= Val(aGrava[5])
	Local nQuant     	:= 0

	// Variáveis do Bem
	Local cCodFilBem 	:= ""
	Local cPlacaBem  	:= ""

	// Variáveis das Informações do Posto
	Local cTerminal  	:= PADR(aGrava[9] , TAMSX3("TR0_TERMIN")[1], " ")
	Local cBomba     	:= PADR(aGrava[10], TAMSX3("TQJ_BOMBA")[1] , " ")
	Local cCodPosto  	:= ""
	Local cCodLoja   	:= ""
	Local cCNPJ      	:= ""
	Local cTanque    	:= ""
	Local cCombustiv 	:= "", cCodConven := ""
	Local nValUni    	:= 0
	Local nValTot    	:= 0
	Local cProduto 		:= ""
	Local lRet 			:= .F.
	Local lMNTA1311  	:= ExistBlock("MNTA1311")
	Local nX

	// Variáveis da transferências
	Local cCodEmpOri := ""
	Local cCodFilOri := ""
	Local cCodEmpDes := ""
	Local cCodFilDes := ""
	Local cPostoDest := ""
	Local cLojaDest  := ""
	Local cTanqDest  := ""
	Local cObserv    := aGrava[8]
	Local cTermDest  := ""
	Local cBombDest  := ""
	Local nTermExtra := 0
	Local nBombExtra := 0
	Local aGrupos := aClone( FWAllGrpCompany() )
	Local nGrupo
	Local cQryAlias  := ""
	Local cQryTerBom := ""
	Local cQryTbl    := ""

	// Limpa o conteudo do array
	For nX := 1 To Len(aGrava)
		aGrava[nX] := AllTrim(aGrava[nX])
	Next nX

	// Veirifica o Bem
	dbSelectArea("ST9")
	dbSetOrder(16)
	If dbSeek(aGrava[4])
		cCodFilBem := ST9->T9_FILIAL
		cPlacaBem  := ST9->T9_PLACA
	Else
		cCodFilBem := cFilAnt
	EndIf

	// Verifica o Abastecimento
	cNumAbast := fNextAbast(cCodFilBem)
	If Empty(cNumAbast)
		Return .F.
	EndIf

	//Realiza conversão da quantidade de combustível informada com duas casas decimais
	cParc2 := SubStr(cQtdComb,1,8) + "." + SubStr(cQtdComb,9,2)
	nQuant := Val(cParc2)

	// Busca o Posto com a relação Terminal X Bomba (cadastro do MNTA616)
	dbSelectArea("TR0")
	dbSetOrder(1)
	If dbSeek(NgTrocaFil("TR0",cCodFilBem) + cTerminal + cBomba)
		cCodEmpOri := cEmpAnt
		cCodFilOri := TR0->TR0_FILIAL
		cCodPosto  := TR0->TR0_CODPOS
		cCodLoja   := TR0->TR0_LOJPOS
		cTanque    := TR0->TR0_TANPOS
	Else
		// Busca em todas as empresas
		cQryAlias := GetNextAlias()
		For nGrupo := 1 To Len(aGrupos)
			If NGABRESX("SX3", aGrupos[nGrupo])
				cQryTbl := NGRetX2("TR0",aGrupos[nGrupo], .F.) //RetFullName("TR0",aGrupos[nGrupo])
				If !Empty(cQryTbl)
					// Query
					cQryTerBom := "SELECT * FROM " + cQryTbl + " TR0 "
					cQryTerBom += "WHERE TR0.D_E_L_E_T_ <> '*' AND TR0.TR0_TERMIN = " + ValToSQL(cTerminal) + " AND TR0.TR0_BOMPOS = " + ValToSQL(cBomba) + " "
					// Garante integridade da query de acordo com o banco de dados
					cQryTerBom := ChangeQuery(cQryTerBom)
					// Cria a tabela temporária
					dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryTerBom), cQryAlias, .T., .T.)
					// Resultado
					dbSelectArea(cQryAlias)
					dbGoTop()
					If !Eof()
						cCodEmpOri := aGrupos[nGrupo]
						cCodFilOri := (cQryAlias)->TR0_FILIAL
						cCodPosto  := (cQryAlias)->TR0_CODPOS
						cCodLoja   := (cQryAlias)->TR0_LOJPOS
						cTanque    := (cQryAlias)->TR0_TANPOS
						Exit
					EndIf
					// Fecha a tabela
					dbSelectArea(cQryAlias)
					dbCloseArea()
				EndIf
			EndIf
		Next nGrupo
	EndIf

	If !Empty(cCodPosto) .And. !Empty(cCodLoja) .And. !Empty(cTanque)
		// Cadastro do Posto
		dbSelectArea("TQF")
		dbSetOrder(1)
		If dbSeek(NgTrocaFil("TQF",cCodFilBem) + cCodPosto + cCodLoja)
			cCNPJ := TQF->TQF_CNPJ

			// Cadastro do Tanque
			dbSelectArea("TQI")
			dbSetOrder(1)
			If dbSeek(NgTrocaFil("TQI",TQF->TQF_FILIAL) + cCodPosto + cCodLoja + cTanque)
				cCombustiv := TQI->TQI_CODCOM

				// Cadastro dos Preços Negociados
				dbSelectArea("TQH")
				dbSetOrder(1)
				dbSeek(NgTrocaFil("TQH",TQF->TQF_FILIAL) + cCodPosto + cCodLoja + cCombustiv + DTOS(dDatAbast) + cHorAbast, .T.)

				// Do último para o primeiro
				If Eof() .Or. TQH->TQH_FILIAL <> NgTrocaFil("TQH",TQF->TQF_FILIAL) .Or. ;
					TQH->TQH_CODPOS <> cCodPosto .Or. TQH->TQH_LOJA <> cCodLoja .Or. TQH->TQH_CODCOM <> cCombustiv
					dbSkip(-1)
				EndIf
				While !Bof() .And. TQH->TQH_FILIAL == NgTrocaFil("TQH",TQF->TQF_FILIAL) .And. ;
					TQH->TQH_CODPOS == cCodPosto .And. TQH->TQH_LOJA == cCodLoja .And. TQH->TQH_CODCOM == cCombustiv

					If TQH->TQH_DTNEG == dDatAbast
						If TQH->TQH_HRNEG <= cHorAbast
							nValUni := TQH->TQH_PRENEG
							Exit
						EndIf
					ElseIf TQH->TQH_DTNEG < dDatAbast
						nValUni := TQH->TQH_PRENEG
						Exit
					EndIf

					dbSelectArea("TQH")
					dbSkip(-1)
				End

				nValTot := ( nValUni * nQuant )

				// Cadastro dos Tipos de Combustíveis
				dbSelectArea("TQM")
				dbSetOrder(1)
				If dbSeek(NgTrocaFil("TQM",TQF->TQF_FILIAL) + cCombustiv + "7")
					cCodConven := TQM->TQM_CODCON
				EndIf
			EndIf
		EndIf
	EndIf

	// Painél On-Line E é uma Transferência?
	If Len(aGrava) > 10 .And. AllTrim(aGrava[17]) == "T"
		cPostoDest := ""
		cLojaDest  := ""
		cTanqDest  := ""

		// Verifica qual Informação Extra representa o Terminal
		dbSelectArea("TR0")
		dbSetOrder(1)
		If dbSeek(NgTrocaFil("TR0") + "#")
			nTermExtra := Val(TR0->TR0_EXTRA)
		EndIf
		// Verifica qual Informação Extra representa a Bomba
		dbSelectArea("TR0")
		dbSetOrder(2)
		If dbSeek(NgTrocaFil("TR0") + "#")
			nBombExtra := Val(TR0->TR0_EXTRA)
		EndIf

		// Busca o Posto/Loja destino da transferência de acordo com a tabela DE/PARA de Terminal x Bomba
		If nTermExtra > 0 .And. nBombExtra > 0
			cTermDest := PADR(aGrava[nTermExtra+11], TAMSX3("TR0_TERMIN")[1], " ") // Terminal destino
			cBombDest := PADR(aGrava[nBombExtra+11], TAMSX3("TQJ_BOMBA")[1] , " ") // Bomba destino

			dbSelectArea("TR0")
			dbSetOrder(1)
			If dbSeek(NgTrocaFil("TR0",cCodFilBem) + cTermDest + cBombDest)
				cCodEmpDes := cEmpAnt
				cCodFilDes := TR0->TR0_FILIAL
				cPostoDest := TR0->TR0_CODPOS
				cLojaDest  := TR0->TR0_LOJPOS
				cTanqDest  := TR0->TR0_TANPOS
			Else
				// Busca em todas as empresas
				cQryAlias := GetNextAlias()
				For nGrupo := 1 To Len(aGrupos)
					cQryTbl := NGRetX2("TR0",aGrupos[nGrupo], .F.) //RetFullName("TR0",aGrupos[nGrupo])
					If !Empty(cQryTbl)
						// Query
						cQryTerBom := "SELECT * FROM " + cQryTbl + " TR0 "
						cQryTerBom += "WHERE TR0.D_E_L_E_T_ <> '*' AND TR0.TR0_TERMIN = " + ValToSQL(cTermDest) + " AND TR0.TR0_BOMPOS = " + ValToSQL(cBombDest) + " "
						// Garante integridade da query de acordo com o banco de dados
						cQryTerBom := ChangeQuery(cQryTerBom)
						// Cria a tabela temporária
						dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryTerBom), cQryAlias, .T., .T.)
						// Resultado
						dbSelectArea(cQryAlias)
						dbGoTop()
						If !Eof()
							cCodEmpDes := aGrupos[nGrupo]
							cCodFilDes := (cQryAlias)->TR0_FILIAL
							cPostoDest := (cQryAlias)->TR0_CODPOS
							cLojaDest  := (cQryAlias)->TR0_LOJPOS
							cTanqDest  := (cQryAlias)->TR0_TANPOS
							Exit
						EndIf
						// Fecha a tabela
						dbSelectArea(cQryAlias)
						dbCloseArea()
					EndIf
				Next nGrupo
			EndIf

		EndIf
	EndIf

	// Grava a Importação
	Begin Transaction
	dbSelectArea("TR6")
	dbSetOrder(1)
	If !dbSeek(cNumAbast)
		RecLock("TR6",.T.)
		TR6->TR6_FILIAL := xFilial("TR6")
		TR6->TR6_NUMABA := cNumAbast
		TR6->TR6_PLACA  := cPlacaBem
		TR6->TR6_POSTO  := cCodPosto
		TR6->TR6_LOJA   := cCodLoja
		TR6->TR6_CNPJ   := cCNPJ
		TR6->TR6_TIPCOM := If(lConsComb, cCombustiv, cCodConven)
		TR6->TR6_CPFMOT := cCPFMotGen
		TR6->TR6_KMABAS := nKmAbast
		TR6->TR6_QTDCOM := Val(cParc2)
		TR6->TR6_VLCOMB := nValUni
		TR6->TR6_VLTOT  := nValTot
		TR6->TR6_DTABAS := dDatAbast
		TR6->TR6_HRABAS := cHorAbast
		TR6->TR6_TANQUE := cTanque
		TR6->TR6_BOMBA  := cBomba
		// Transferência
		TR6->TR6_EMPORI := cCodEmpOri
		TR6->TR6_FILORI := cCodFilOri
		TR6->TR6_EMPDES := cCodEmpDes
		TR6->TR6_FILDES := cCodFilDes
		TR6->TR6_POSDES := cPostoDest
		TR6->TR6_LOJDES := cLojaDest
		TR6->TR6_TANDES := cTanqDest
		TR6->TR6_MOTTRA := cCodMotiv
		TR6->TR6_CONVEN := "7"

		//grava observacoes
		MsMM(TR6->TR6_CODOBS,80,,cObserv,1,,,"TR6","TR6_CODOBS")

		If lPrSB2
			cProduto := NgSeek("TQI",cCodPosto+cCodLoja+cTanque+cCombustiv,1,"TQI->TQI_PRODUT")
			DbSelectArea("SB2")
			DbSetOrder(01)
			DbSeek(xFilial("SB2")+cProduto+TR6->TR6_TANQUE)
			TR6->TR6_VLCOMB := SB2->B2_CM1
			TR6->TR6_VLTOT := nQuant * SB2->B2_CM1
		EndIf

		MsUnlock("TR6")

		// PE - Gravação de campos de usuários
		If lMNTA1311
			ExecBlock( "MNTA1311", .F., .F. )
		EndIf

		lRet := .T.
	EndIf
	End Transaction

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fNextAbast
Recebe o próximo número de abastecimento.

@param cCodFilBem
	Filial do Bem para buscar o abastecimento * Obrigatório

@author Wagner Sobral de Lacerda
@since 05/09/2011

@return cNextAbast Número do próximo abastecimento
/*/
//---------------------------------------------------------------------
Static Function fNextAbast(cCodFilBem)

	// Salva a área
	Local aAreaTR6 := TR6->( GetArea() )

	// Número do próximo abastecimento
	Local cNextAbast

	// Recebe o próximo abastecimento na TR6
	cNextAbast := AllTrim( NGPROXABAST(cCodFilBem) )
	dbSelectArea("TR6")
	dbSetOrder(1)
	If dbSeek(cNextAbast)
		dbGoBottom()
		cNextAbast := Soma1Old(TR6->TR6_NUMABA)
	EndIf

	// Devolve a área
	RestArea(aAreaTR6)

Return cNextAbast