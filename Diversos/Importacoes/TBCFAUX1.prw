#Include "Protheus.ch"
#Include "ParmType.ch"
#Include "TopConn.ch"

Static cPulaLinha	:= Chr(13) + Chr(10)

/*-------------------------------------------------------------------
- Programa: funLeCsv
- Autor: Tarcisio silva
- Data: 07/04/2020
- Descrição: Efetua a leitura do arquivo Csv.
-------------------------------------------------------------------*/

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

/*-------------------------------------------------------------------
- Programa: fRetCads
- Autor: Tarcisio silva
- Data: 13/04/2020
- Descrição: Retorna cadastros que serão importados.
-------------------------------------------------------------------*/

User Function fRetCads()

    Local aRet := {}
	
	aAdd(aRet,"01 - Cadastro de Produtos - SB1"							)                     
	aAdd(aRet,"02 - Cadastro de Estrutura de Produtos - SG1"			)         
	aAdd(aRet,"03 - Cadastro de Clientes - SA1"							)                         
	aAdd(aRet,"04 - Cadastro de Fornecedores - SA2"						)                    
	aAdd(aRet,"05 - Contas a Pagar - SE2"								)        					
	aAdd(aRet,"06 - Contas a Receber - SE1"								)      					  
	aAdd(aRet,"07 - Cadastro de Bens(Ativo Fixo) - 2 arquivos SN1/SN3"	)
	aAdd(aRet,"08 - Saldos em Estoque - SB9"							) 
	aAdd(aRet,"09 - Saldos por Lote - SD5"								)    
	aAdd(aRet,"10 - Cadastro Grupos de Produtos - SBM"					)  		
	aAdd(aRet,"11 - Cadastro de Natureza Financeira - SED"				)
	aAdd(aRet,"12 - Cadastro de Condição de Pagamentos - SE4" 			)
	aAdd(aRet,"13 - Cadastro de Centro de Custo - CTT"       			)
	aAdd(aRet,"14 - Cadastro de Orçamentos (Faturamento) - 2 arquivos SCJ/SCK"   )
    
Return(aRet)

/*-------------------------------------------------------------------
- Programa: fTrocaFil
- Autor: Tarcisio silva
- Data: 07/04/2020
- Descrição: Efetua a troca de filial.
-------------------------------------------------------------------*/

User Function fTrocaFil(cFilials,cEmps)

	Default cFilials := ""
	Default cEmps 	 := cEmpAnt

	SM0->(DbGoTop())

	While SM0->(!Eof())

		if (AllTrim(SM0->M0_CODFIL) == AllTrim(cFilials)) .and. (AllTrim(SM0->M0_CODIGO) == AllTrim(cEmps))

			Exit

		endif

		SM0->(DbSkip())

	EndDo

	cFilAnt := cFilials

Return(Nil)

/*-------------------------------------------------------------------
- Programa: fDelRegs
- Autor: Tarcisio silva
- Data: 07/04/2020
- Descrição: Define se as tableas do metodo fTableExc serão apagadas.
-------------------------------------------------------------------*/

User function fDelRegs(aTabExclui,cTipo)

	Local nTipoImp 		:= 0
	Local cTab 			:= ""
	Local nI 			:= 1
	Default aTabExclui 	:= {}
	Default cTipo 		:= ""

	nTipoImp  := aScan( aTabExclui, { |x| AllTrim( x[1] ) == cTipo } )

	cTab := ''

    if nTipoImp != 0

        for nI := 1 To len(aTabExclui[nTipoImp,2])

            cTab += aTabExclui[nTipoImp,2,nI]+' '

        next nI

        if MsgYesNo("Deseja excluir os dados da(s) tabela(s):"+cTab+"antes da importação ? ", "Atenção!")

            for nI := 1 To len(aTabExclui[nTipoImp,2])

                cSQL := "DELETE FROM "+RetSqlName(aTabExclui[nTipoImp,2,nI])

                if (TCSQLExec(cSQL) < 0)

                    Return MsgStop("TCSQLError() " + TCSQLError())

                endif

                cSQL := "DELETE FROM "+RetSqlName('AO4')+" WHERE AO4_ENTIDA = '" + aTabExclui[nTipoImp,2,nI] + "'"

                if (TCSQLExec(cSQL) < 0)

                    Return MsgStop("TCSQLError() " + TCSQLError())

                endif

            next nI

        endif

    endif

Return(Nil)

/*-------------------------------------------------------------------
- Programa: fTableExc
- Autor: Tarcisio silva
- Data: 07/04/2020
- Descrição: Armazena as tabelas que serão apagadas durante a impor-
atação. 
-------------------------------------------------------------------*/

User Function fTableExc()

	Local aTabExclui := {}

	aAdd(aTabExclui,{'E4' ,{"SE4"}})
	aAdd(aTabExclui,{'ED' ,{"SED"}})
	aAdd(aTabExclui,{'BM' ,{"SBM"}})
	aAdd(aTabExclui,{'B1' ,{"SB1"}})
	aAdd(aTabExclui,{'G1' ,{"SG1"}})
	aAdd(aTabExclui,{'A1' ,{"SA1"}})
	aAdd(aTabExclui,{'A2' ,{"SA2"}})
	aAdd(aTabExclui,{'A3' ,{"SA3"}})
	aAdd(aTabExclui,{'DA3',{"DA3"}})
	aAdd(aTabExclui,{'A4' ,{"SA4"}})
	aAdd(aTabExclui,{'D5' ,{"SD5"}})
	aAdd(aTabExclui,{'C7' ,{"SC7"}})
	aAdd(aTabExclui,{'C5' ,{"SC5"}})
	aAdd(aTabExclui,{'C6' ,{"SC6"}})
	aAdd(aTabExclui,{'E2' ,{"SE2"}})
	aAdd(aTabExclui,{'E1' ,{"SE1"}})
	aAdd(aTabExclui,{'C1' ,{"SC1"}})
	aAdd(aTabExclui,{'B9' ,{"SB2","SB9"}})
	aAdd(aTabExclui,{'N1' ,{"SN1","SN3","SN4","SN5"}})
	aAdd(aTabExclui,{'CT' ,{"CTT"}})

Return(aTabExclui)

/*-------------------------------------------------------------------
- Programa: TBCFAUX1
- Autor: Raquel Pereira
- Data: 05/07/2019
- Descrição: Valida campos da Importação na SX3.
-------------------------------------------------------------------*/

User Function TBCFAUX1(aCamposImp, aCamposX3, cTipo)

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

/*-------------------------------------------------------------------
- Programa: TBCFAUX2
- Autor: Raquel Pereira
- Data: 02/04/2014
- Descrição: Função que faz a consulta na tabela SX3.
-------------------------------------------------------------------*/

User Function TBCFAUX2(cFiltroSQL)

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
