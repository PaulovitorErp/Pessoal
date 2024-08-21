#Include "Protheus.ch"
#Include "ParmType.ch"
#Include "TopConn.ch"

Static cPulaLinha	:= Chr(13) + Chr(10)

/*/-------------------------------------------------------------------
- Programa: funLeCsv
- Autor: Danilo Teles
- Data: 25/01/2024
- Descrição: Efetua a leitura do arquivo Csv.
-------------------------------------------------------------------/*/

User Function funLeCsv(cLocFile,nOpcao,oSay)

	Local cLinha 		:= ""
	Local aRet 			:= {}
	Local lPrim         := .T.
	Default cLocFile 	:= ""
	Default nOpcao      := 0
	Default oSay 		:= Nil

	if nOpcao == 2
		oSay:cCaption := ("Agrupando os registros em um array...")
		ProcessMessages()
	endif

	FT_FUSE(cLocFile)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()

	While !FT_FEOF()

		IncProc("lendo arquivo Csv...")
		cLinha := FT_FREADLN()
		if nOpcao == 1
			aRet := Separa(cLinha,";",.T.)
			exit
		else
			if lPrim
				lPrim := .F.
			else
				aAdd(aRet,Separa(cLinha,";",.T.))
			endif
		endif
		FT_FSKIP()
	enddo

Return(aRet)

/*/-------------------------------------------------------------------
	- Programa: fRetCads
	- Autor: Danilo Teles
	- Data: 25/01/2024
	- Descrição: Retorna cadastros que serão importados.
-------------------------------------------------------------------/*/

User Function fRetCads()

	Local aRet := {}

	aAdd(aRet,"01 - Cadastro de Clientes - SA1"		)
	aAdd(aRet,"02 - Cadastro de Fornecedores - SA2"	)
	aAdd(aRet,"03 - Cadastro de Produtos - SB1"		)
	aAdd(aRet,"04 - Contas a Pagar - SE2"			)
	aAdd(aRet,"05 - Contas a Receber - SE1"			)
	aAdd(aRet,"06 - Saldos em Estoque - SB9"		)
	aAdd(aRet,"07 - Contratos - CN9/CNA/CNB/CNC"	)
	aAdd(aRet,"08 - Baixas a Receber - SE1"			)
	aAdd(aRet,"09 - Baixas a Pagar - SE2"			)

	/*/
	aAdd(aRet,"09 - Saldos por Lote - SD5"								)
	aAdd(aRet,"10 - Cadastro Grupos de Produtos - SBM"					)
	aAdd(aRet,"11 - Cadastro de Natureza Financeira - SED"				)
	aAdd(aRet,"12 - Cadastro de Condição de Pagamentos - SE4" 			)
	aAdd(aRet,"13 - Cadastro de indicador de produto - SBZ" 			)
	aAdd(aRet,"14 - Cadastro de bens - ST9" 						    )
	aAdd(aRet,"15 - Cadastro de tabela de preços - DA0/DA1" 			)
	/*/

Return(aRet)

/*/-------------------------------------------------------------------
	- Programa: MEGAAUX1
	- Autor: Danilo Teles
	- Data: 25/01/2024
	- Descrição: Valida campos da Importação na SX3.
-------------------------------------------------------------------/*/

User Function MEGAAUX1(aCamposImp, aCamposX3, cTipo)

	Local nI
	Local nY
	Local nPosArray

	for nI := 1 To len(aCamposImp)
		//Verifca se todos os campos devem pertencer a mesma tabela
		if cTipo <> SUBSTR(aCamposImp[nI],1,2)
			MsgAlert('Todos os campos devem pertencer a mesma tabela !!')
			Return .F.
		endif
		//Varre os campos para validar.
		if len(aCamposX3) > 0
			for nY := 1 to len(aCamposX3)
				nPosArray := aScan(aCamposX3, {|x| AllTrim(Upper(x[2])) == AllTrim(aCamposImp[nI]) })
				if nPosArray == 0
					MsgAlert('Campo não encontrado na tabela :'+aCamposImp[nI]+' !!')
					Return .F.
				elseif (aCamposX3[nPosArray,13] $ ('V') ) .OR. (aCamposX3[nPosArray,6] == "V"  )
					MsgAlert('Campo marcado na tabela como visual ou virtual :'+aCamposImp[nI]+' !!')
					Return .F.
				endif
			next nY
		endif
	next nI

Return(.T.)

/*/-------------------------------------------------------------------
	- Programa: MEGAAUX2
	- Autor: Danilo Teles
	- Data: 25/01/2024
	- Descrição: Função que faz a consulta na tabela SX3.
-------------------------------------------------------------------/*/

User Function MEGAAUX2(cFiltroSQL)
	Local aArea			:= GetArea()
	Local cQry			:= ""
	Local aCampos		:= {}
	Local aRet			:= {}
	Default cFiltroSQL	:= ""

	// verifico se nao existe este alias criado
	If Select("QRYX3") > 0
		QRYSX3->(DbCloseArea())
	EndIf

	cQry := " SELECT "														+ cPulaLinha
	cQry += " SX3.X3_CAMPO CAMPO, "											+ cPulaLinha
	cQry += " SX3.X3_TIPO TIPO, "											+ cPulaLinha
	cQry += " SX3.X3_TAMANHO TAMANHO, "										+ cPulaLinha
	cQry += " SX3.X3_DECIMAL CPODEC, "										+ cPulaLinha //Alterado nome do campo pois dá restrição de palavra reservado ORACLE // Claudio 20.09.21
	cQry += " SX3.X3_PICTURE PICTURE, "										+ cPulaLinha
	cQry += " SX3.X3_CONTEXT CONTEXT, "										+ cPulaLinha
	cQry += " SX3.X3_TITULO TITULO, "										+ cPulaLinha
	cQry += " SX3.X3_VALID VALID, "											+ cPulaLinha
	cQry += " SX3.X3_USADO USADO, "											+ cPulaLinha
	cQry += " SX3.X3_F3 F3, "												+ cPulaLinha
	cQry += " SX3.X3_CBOX CBOX,"											+ cPulaLinha
	cQry += " SX3.X3_RELACAO RELACAO,"										+ cPulaLinha
	cQry += " SX3.X3_VISUAL VISUAL"											+ cPulaLinha
	cQry += " FROM "														+ cPulaLinha
	cQry += " " + RetSqlName("SX3") + " SX3 "								+ cPulaLinha
	cQry += " WHERE "														+ cPulaLinha
	cQry += " SX3.D_E_L_E_T_ <> '*' "										+ cPulaLinha

	if !Empty(cFiltroSQL)
		cQry += " AND " + cFiltroSQL										+ cPulaLinha
	endif

	cQry += " ORDER BY SX3.X3_ORDEM "										+ cPulaLinha

	// funcao que converte a query generica para o protheus
	cQry := ChangeQuery(cQry)

	// crio o alias temporario
	TcQuery cQry New Alias "QRYX3" // Cria uma nova area com o resultado do query
	if QRYX3->(!Eof())
		// percorro os campos da SX3
		While QRYX3->(!Eof())
			aCampos := {}
			aadd(aCampos , AllTrim(QRYX3->TITULO))
			aadd(aCampos , AllTrim(QRYX3->CAMPO))
			aadd(aCampos , QRYX3->PICTURE)
			aadd(aCampos , QRYX3->TAMANHO)
			aadd(aCampos , QRYX3->CPODEC)
			aadd(aCampos , QRYX3->CONTEXT)
			aadd(aCampos , QRYX3->VALID)
			aadd(aCampos , QRYX3->USADO)
			aadd(aCampos , QRYX3->TIPO)
			aadd(aCampos , QRYX3->F3)
			aadd(aCampos , QRYX3->CBOX)
			aadd(aCampos , QRYX3->RELACAO)
			aadd(aCampos , QRYX3->VISUAL)
			aadd(aRet , aCampos)
			QRYX3->(DbSkip())
		EndDo
	endif

	// verifico se nao existe este alias criado
	If Select("QRYX3") > 0
		QRYX3->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return(aRet)
