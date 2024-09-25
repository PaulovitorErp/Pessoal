#INCLUDE "Protheus.ch"
#INCLUDE "mnta877.ch"
#INCLUDE "Colors.ch"
#INCLUDE "RWMake.ch"
#INCLUDE "Fileio.ch"

#DEFINE DS_MODALFRAME 128 //Estilo de frame que retira o X da janela

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA877
Função responsável por refazer o histórico de contador do bem.
É disponibilizada três opções, uma apontando os códigos dos bens
como parâmetros (para realizar a correção em lote e de forma mais
abstrata), outra por um markbrowse, para eventual modificação de 1
ou mais bens e outra para importação de dados de um arquivo Excel
para correção de registros inconsistentes (sem inclusão).

@author Éwerton Cercal
@since 27/04/2015
@version P11
@return
/*/
//---------------------------------------------------------------------
Function MNTA877()

	Local aNGBEGINPRM := NGBEGINPRM()		//Versão do fonte e inicialização de variáveis padrão
	Local cMsg := ""				//Mensagem informativa sobre as opções disponíveis na rotina

	Private nOpcSel := 1			//Variável que armazena o número da opção selecionada, sendo:
									//1 - Correção informando bens por parâmetros	(Opção Padrão)
									//2 - Correção escolhendo bens via MsSelect
									//3 - Correção dos registros inconsistentes
	Private nOpcao := 0			//Variável que armazena o numeral que representa se foi confirmada a execução (nOpcao == 1) ou fechada a rotina (nOpcao == 0)
	Private lMark := .T.			//Variável lógica que aponta se está utilizando a opção por MsSelect. Ela será utilizada na montagem específica de Query
	Private lParam := .F.		//Variável lógica que aponta se está utilizando a opção por Parâmetros. Ela será utilizada na montagem específica de Query
	Private oGetExp				//Objeto do MsGetNewDados sobre o arquivo .dbf que contém os bens inconsistentes (sem registro de inclusão)
	Private oDlgExp				//Objeto do MsDialog para montagem da tela com a GetNewDados dos bens inconsistentes para realizar correção
	Private lInconsist := .F.	//Variável lógica que sinaliza se existem inconsistentes que foram gravadas no arquivo .dbf
	Private aBens := {}			//Array para os bens que serão corrigidos - somente MsSelect
	Private cBemIni := Replicate(" ", TamSX3("T9_CODBEM")[1])//Variável com o tamanho do campo T9_CODBEM, para passar como parâmetro
	Private cBemFim := Replicate("Z", TamSX3("T9_CODBEM")[1])
	Private aProc := {}			//Array com os bens que foram processados
	Private aNaoProc := {}		//Array com bens que não podem ter seu contador reprocessado
	Private lCorrigiu := .F.
	Private lSitBem := .T.		//Indica se consideração situação dos bens
	Private lProccess := .F. //Indica se houve algum processamento, para atualizar a STZ
	Private cPerg := PadR( "MNTA877" , Len(Posicione("SX1", 1, "MNTA877", "X1_GRUPO")) )

	//Tabelas temporárias do processo
	Private oTmpTRB
	Private oTmpSTZ
	Private oTmpSTP
	Private oTmpBem
	Private oTmpInc
	Private oTmpASTP

	Private cTimeInic := ""
	Private cTimeFim  := ""

	SetFunName( 'MNTA877' ) // Assume a função posicionada como principal

	dbSelectArea("SX1")
	dbSetOrder(01)
	If !dbSeek(cPerg+"01")
		ShowHelpDlg( STR0070 ,     ; // "ATENÇÃO!"
					{ STR0071 }, 2,; // "O dicionário de dados está desatualizado, o que pode comprometer a utilização de algumas rotinas."
					{ STR0072 }, 2 )  // "Favor aplicar as atualizações contidas no pacote da issue DNG-2319"
	Else

		ShowHelpDlg("ATENCAO", {STR0043}, 1, {STR0044}, 1)

		pergunte(cPerg,.F.)

		nOpcao := 1
		nOpcSel := 2
		lMark := .T.
		lParam := .F.
		MNT877MKB()

		cMsg := ""

	EndIf

	SetFunName( 'MNTA875' ) // Retorna a função chamadora como principal

	/*--------------------------------------------------------
			Retorna conteúdo de variáveis padrões
	--------------------------------------------------------*/
	NGReturnPRM(aNGBEGINPRM)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT877MKB
Função MarkBrowse para selecionar em quais bens serão realizadas
as alterações.

@author Éwerton Cercal
@since 27/04/2015
@version P11
@return lRet - Lógico (.T./.F.)
/*/
//---------------------------------------------------------------------
Function MNT877MKB()

	Local aEstrut := {}	//Estrutura da TRB
	Local aCampos := {}	//Campos do MsSelect
	Local lRet := .T.	//Variável lógica que sinaliza se o retorno das operações foi um sucesso (.T.) ou fracasso (.F.)

	Local cQryMark := ""				//Query da MsSelect para listagem de bens

	Local oDlg	//Objeto do MsDialog para montagem de tela 'Por Lista'
	Local oPnl	//Objeto do TPanel para montagem de painel em tela

	Local nTamFil := IIf(FindFunction("FWSizeFilial"), FWSizeFilial(), TamSX3("TP_FILIAL")[1])
	Local aIdx := {}
	Local nComboIdx, cPesquisa := Space(30)

	Local aButtons := {}

	Private cMark := GetMark()	//Variável que armazena o marcador

	Private oMark				//Objeto do MsSelect para montagem em tela

	Private aSize := MsAdvSize()

	//Estrutura da tabela temporária
	aAdd(aEstrut, {"OK"    , "C",  2, 0})	//Campo de marcação
	aAdd(aEstrut, {"FILIAL", "C", nTamFil, 0})	//Filial
	aAdd(aEstrut, {"CODBEM", "C", TamSX3( 'T9_CODBEM' )[1] , 0})	//Código do Bem
	aAdd(aEstrut, {"NOMBEM", "C", TamSX3( 'T9_NOME' )[1]   , 0})	//Nome do Bem
	aAdd(aEstrut, {"TIPMOD", "C", TamSX3( 'T9_TIPMOD' )[1] , 0})	//Tipo do Modelo
	aAdd(aEstrut, {"NOMMOD", "C", TamSX3( 'TQR_DESMOD' )[1], 0})	//Nome do Modelo
	aAdd(aEstrut, {"CODFAM", "C", TamSX3( 'T9_CODFAMI' )[1], 0})	//Código da Família
	aAdd(aEstrut, {"NOMFAM", "C", TamSX3( 'T6_NOME' )[1]   , 0})	//Nome da Família
	aAdd(aEstrut, {"SULCAT", "C", 20, 0})	//Sulco Atual
	aAdd(aEstrut, {"BANDAA", "C", 20, 0})	//Banda Atual

	//Instancia classe FWTemporaryTable
	oTmpTRB := FWTemporaryTable():New("TRB", aEstrut)

	//Cria indices
	oTmpTRB:AddIndex("1", {"CODBEM"})
	oTmpTRB:AddIndex("2", {"TIPMOD"})
	oTmpTRB:AddIndex("3", {"CODFAM"})
	oTmpTRB:AddIndex("4", {"CODBEM", "TIPMOD"})
	oTmpTRB:AddIndex("5", {"CODBEM", "CODFAM"})
	oTmpTRB:AddIndex("6", {"CODBEM", "TIPMOD", "CODFAM"})

	//Cria a tabela temporaria
	oTmpTRB:Create()

	/*------------------------------------------------+
	| Inclusão dos equipamentos na tabela temporária. |
	+------------------------------------------------*/
	cQryMark := 'INSERT INTO ' + oTmpTRB:GetRealName()
	cQryMark += 	" ( FILIAL, CODBEM, NOMBEM, TIPMOD, NOMMOD, CODFAM, NOMFAM, SULCAT, BANDAA ) " 
	cQryMark += "SELECT DISTINCT "
	cQryMark += 		"ST9.T9_FILIAL , "
	cQryMark +=  		"ST9.T9_CODBEM , "
	cQryMark += 		"ST9.T9_NOME   , "
	cQryMark += 		"ST9.T9_TIPMOD , "
	cQryMark += 		"TQR.TQR_DESMOD, "
	cQryMark += 		"ST9.T9_CODFAMI, " 
	cQryMark += 		"ST6.T6_NOME   , " 
	cQryMark += 		"CASE T9_CATBEM WHEN '3' "
	cQryMark +=				"THEN CAST( TQS_SULCAT AS VARCHAR( 20 ) ) " 
	cQryMark +=				"ELSE '-' "
	cQryMark += 		"END, "
	cQryMark += 		"CASE T9_CATBEM WHEN '3' "
	cQryMark += 			"THEN CAST( TQS_BANDAA AS VARCHAR( 20 ) ) "
	cQryMark += 			"ELSE '-' " 
	cQryMark += 		"END "
	cQryMark += " FROM " + RetSQLName( 'ST9' ) + " ST9 "
	cQryMark += " LEFT JOIN " + RetSQLName( 'TQS' )  + " TQS ON "
	cQryMark += 		"ST9.T9_FILIAL = TQS.TQS_FILIAL AND " 
	cQryMark +=			"ST9.T9_CODBEM = TQS.TQS_CODBEM AND "
	cQryMark += 		"TQS.D_E_L_E_T_ <> '*' "
	cQryMark += " INNER JOIN " + RetSQLName( 'TQR' ) + " TQR ON "
	cQryMark += 		"ST9.T9_TIPMOD = TQR.TQR_TIPMOD AND "
	cQryMark += 		"TQR.D_E_L_E_T_ <> '*' AND "
	cQryMark +=			NGMODCOMP( 'ST9', 'TQR' )
	cQryMark += " INNER JOIN " + RetSQLName( 'ST6' ) + " ST6 ON "
	cQryMark += 		"ST9.T9_CODFAMI = ST6.T6_CODFAMI AND "
	cQryMark += 		"ST6.D_E_L_E_T_ <> '*' AND "
	cQryMark +=			NGMODCOMP( 'ST9', 'ST6' )
	cQryMark += " WHERE "
	cQryMark += 		"ST9.T9_TEMCONT IN ( 'P', 'I' ) AND "
	cQryMark += 		"ST9.T9_SITBEM <> 'T' AND "
	cQryMark += 		"ST9.D_E_L_E_T_ <> '*' "
	cQryMark += "ORDER BY 
	cQryMark += 		"T9_CODBEM"

	TcSQLExec( cQryMark )

	//Adiciona ao array os campos que serão mostrados em tela
	aAdd(aCampos, {"OK"    , "", ""})
	aAdd(aCampos, {"CODBEM", "", STR0007})	//"Cód. Bem"
	aAdd(aCampos, {"NOMBEM", "", STR0008})	//"Nome Bem"
	aAdd(aCampos, {"TIPMOD", "", STR0009})	//"Tipo Modelo"
	aAdd(aCampos, {"NOMMOD", "", STR0010})	//"Nome Tip. Mod."
	aAdd(aCampos, {"CODFAM", "", STR0011})	//"Família"
	aAdd(aCampos, {"NOMFAM", "", STR0012})	//"Nome Fam."
	aAdd(aCampos, {"BANDAA", "", STR0014})	//"Banda Atual"

	dbSelectArea("TRB")
	dbGoTop()
	Aadd(aButtons, {"PARAMETROS" ,{|| fParam()},STR0069}) //"Parâmetros"

	Define MsDialog oDlg Title STR0001 From aSize[7],0 To aSize[6],aSize[5] Of oMainWnd Pixel Style DS_MODALFRAME

		oDlg:lEscClose := .F.	//Não permite sair através do Esc

		oPnl:= TPanel():New(0, 0,, oDlg,,,,,, 0, 115, .F., .F.)
    	oPnl:Align := CONTROL_ALIGN_ALLCLIENT

		oMark := MsSelect():New( 'TRB', 'OK', , aCampos, , @cMark, , , , oPnl )
		oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oMark:oBrowse:bLDblClick := { || fMark( .F. ) }
		oMark:oBrowse:bAllMark   := { || fMark( .T. ) }

		aAdd(aIdx, STR0073) //"Bem"
		aAdd(aIdx, STR0074) //"Modelo"
		aAdd(aIdx, STR0075) //"Família"
		aAdd(aIdx, STR0076) //"Bem + Modelo"
		aAdd(aIdx, STR0077) //"Bem + Família"
		aAdd(aIdx, STR0078) //"Bem + Modelo + Família"

		cIdx := aIdx[1]

		//Painel do campo de busca
		oPnlTop := TPanel():New(1, 1,, oDlg,,,,,CLR_HGRAY, 400, 12, .F., .F.)
		oPnlTop:Align := CONTROL_ALIGN_TOP
		oPnlBusca := TPanel():New(1, 1,, oPnlTop,,,,,CLR_HGRAY, 300, 12, .F., .F.)
		oPnlBusca:Align := CONTROL_ALIGN_LEFT
		nComboIdx := TComboBox():New(1, 2,{| u | If(PCount() > 0, cIdx := u, cIdx)}, aIdx, 90, 10, oPnlBusca,,,,,,.T.,,,,,,,,,"cIdx")
		@01,95 Get cPesquisa Size 120,8 Picture "@X XXXXXXXXXXXXXXXXXXXXXXXXXXXXX" Pixel Of oPnlBusca
		@01,220 BUTTON STR0079 SIZE 036,010 Pixel OF oPnlBusca ACTION(fBusca(cIdx, cPesquisa)) //"Pesquisar"

		dbSelectArea("TRB")
		dbGoTop()

	Activate MsDialog oDlg On Init EnchoiceBar(oDlg, {|| IIF(MNT877CGP() .And. MNT877AVL(), oDlg:End(), lRet := .F.)}, {|| oDlg:End()},,aButtons) Centered

	//Apaga a tabela temporária e remove os índices
	fDelTTab("TRB")

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fBusca
Efetua a busca do registro

@sample
fBusca(cIndex, cPesquisa)

@param cIndex: Indice de pesquisa do arquivo
@param cPesquisa: valor a ser pesquisado no arquivo
@author Wexlei Silveira
@since 15/10/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fBusca(cIndex, cPesquisa)

If(Empty(Trim(cPesquisa)))

	MsgStop(STR0080) //"O campo de pesquisa está vazio."

Else

	dbSelectArea("TRB")

	If(cIndex == STR0073) //"Bem"
		dbSetOrder(01)
	ElseIf(cIndex == STR0074) //"Modelo"
		dbSetOrder(02)
	ElseIf(cIndex == STR0075) //"Família"
		dbSetOrder(03)
	ElseIf(cIndex == STR0076) //"Bem + Modelo"
		dbSetOrder(04)
	ElseIf(cIndex == STR0077) //"Bem + Família"
		dbSetOrder(05)
	ElseIf(cIndex == STR0078) //"Bem + Modelo + Família"
		dbSetOrder(06)
	EndIf

	dbSeek(Upper(cPesquisa), .T.)

EndIf

Return .T.

//---------------------------------------------------------------------------
/*/{Protheus.doc} MNT877CGP
Rotina que recupera da TRB os itens marcados para seleção e alimenta
um array com eles.

@author Éwerton Cercal
@since 24/06/2015
@version P11
@return Nil
/*/
//---------------------------------------------------------------------------
Function MNT877CGP()

	dbSelectArea("TRB")
	dbGoTop()

	While TRB->(!EoF())

		If !Empty(TRB->OK)
			aAdd(aBens, TRB->CODBEM)
		EndIf

		dbSelectArea("TRB")
		dbSkip()

	End

	If Len(aBens) == 0
		MsgStop(STR0081,STR0070) //"Selecione um ou mais bens para o processamento." ## "Atenção"
		dbSelectArea("TRB")
		dbGoTop()
		Return .F.
	EndIf

Return .T.
//---------------------------------------------------------------------------
/*/{Protheus.doc} MNT877AVL

Rotina que avalia se os bens selecionados podem receber alterações ou não.

@author Éwerton Cercal
@since 29/05/2015
@version P11
@return Nil
/*/
//---------------------------------------------------------------------------
Function MNT877AVL()

	Local aArea      := GetArea()
	Local cJoin      := ''
	Local cWhere     := '%'
	Local cTable     := '%' + oTmpTRB:GetRealName() + '%'
	Local cAliasSTP2 := GetNextAlias()
	Local cAliasISTZ := GetNextAlias()
	Local aDBFBEM    := {}	//Estrutura da TRB STP
	Local nTamFil   := IIf( FindFunction( 'FWSizeFilial' ), FWSizeFilial(), TamSX3( 'TP_FILIAL' )[1] )

	//Estrutura da tabela temporária
	aAdd(aDBFBEM, {"CODBEM", "C", 16, 0})//Código do Bem
	aAdd(aDBFBEM, {"GRAVA" , "C", 1, 0})//Define se o bem receberá a correção
	aAdd(aDBFBEM, {"FILIAL" , "C", nTamFil, 0})//Filial do bem na STZ


	oTmpBem := FWTemporaryTable():New("TRB5", aDBFBEM)
	oTmpBem:AddIndex("1", {"CODBEM"})
	oTmpBem:Create()

	If MV_PAR01 == 1
		lSitBem := .F.//"Considera bens inativos na correção? O processo poderá levar mais tempo de execução."
	EndIf

	cTimeInic := Time()

	// Verifica a existência de bens inconsistentes
	lInconsist := .F.
	MNT877INC()

	// Verifica a existência de bens sem STP e/ou sem STZ
	MNT877VER()

	// Corrige bens sem data de leitura preenchida e/ou data último acompanhamento vazia
	MNT877CGEN()

	// INSERT INTO na tabela temporária com base na query que verifica se há registro de inclusão do bem.
	cQueryBem := 'INSERT INTO ' + oTmpBem:GetRealName() + '( CODBEM, FILIAL, GRAVA )'
	cQueryBem += 	'SELECT '
	cQueryBem +=		'STZ.TZ_CODBEM, '
	cQueryBem +=		'STZ.TZ_FILIAL, '
	cQueryBem +=		ValToSQL( 'N' )
	cQueryBem +=	'FROM '
	cQueryBem += 		RetSQLName( 'STZ' ) + ' STZ '
	cQueryBem += 	'INNER JOIN '
	cQueryBem += 		RetSQLName( 'ST9' ) + ' ST9 ON '
	cQueryBem +=			'STZ.TZ_CODBEM = ST9.T9_CODBEM AND '
	cQueryBem +=			'ST9.T9_FILIAL = '   + ValToSQL( xFilial( 'ST9' ) ) + ' AND '
	cQueryBem += 			'ST9.D_E_L_E_T_ <> ' + ValToSQL( '*' )

	// Se não estiver vazio e tiver vindo da função de Parâmetros
	If !Empty( cBemFim ) .And. !lMark .And. lParam

   		cJoin += ' AND ST9.T9_CODBEM BETWEEN ' + ValToSQL( cBemIni ) + ' AND ' + ValToSQL( cBemFim )

	// Se não estiver vazio e tiver vindo da função de MarkBrowse
	ElseIf !Empty( aBens ) .And. lMark .And. !lParam

		cJoin += ' AND ST9.T9_CODBEM IN ( '
		cJoin +=							'SELECT '
		cJoin += 								'TRB.CODBEM '
		cJoin +=		 					'FROM '
		cJoin += 								oTmpTRB:GetRealName() + ' TRB '
		cJoin += 							'WHERE '
		cJoin += 								'TRB.D_E_L_E_T_ <> ' + ValToSQL( '*' ) + ' AND '
		cJoin += 								'TRB.OK <> '         + ValToSQL( ' ' ) + ' )'

	EndIf

	cQueryBem += cJoin

	cQueryBem += 	'WHERE '
	cQueryBem +=		'STZ.D_E_L_E_T_ <> ' + ValToSQL( '*' ) + ' AND '
	cQueryBem +=		'STZ.TZ_FILIAL  =  ' + ValToSQL( xFilial( 'STZ' ) )
	cQueryBem += 	' GROUP BY '
	cQueryBem += 		'STZ.TZ_FILIAL, '
	cQueryBem += 		'STZ.TZ_CODBEM '
  	cQueryBem += 	'ORDER BY '
	cQueryBem += 		'STZ.TZ_FILIAL, '
	cQueryBem += 		'STZ.TZ_CODBEM '

   	// Executa o comando INSERT INTO na tabela temporária.
	TcSQLExec( cQueryBem )

	cWhere += cJoin + IIf( lSitBem, ' AND T9_SITBEM <> ' + ValToSQL( 'I' ), '' ) + '%'

	//Query para obter os bens com registro de inclusão
	BeginSQL Alias cAliasSTP2

		SELECT DISTINCT
			ST9.T9_CODBEM ,
			STP.TP_DTLEITU,
			STP.TP_HORA
		FROM
			%table:ST9% ST9
		INNER JOIN
			%table:STP% STP ON
				STP.TP_CODBEM  = ST9.T9_CODBEM AND
				STP.TP_FILIAL  = %xFilial:STP% AND
				STP.TP_TIPOLAN = 'I'           AND
				STP.%NotDel%
		WHERE
			ST9.T9_FILIAL  = %xFilial:ST9% AND
			ST9.T9_TEMCONT IN ('P','I')    AND
			ST9.%NotDel%
			%exp:cWhere%

	EndSQL

	// Percorre a TRB verificando quais bens estão nela e no alias com os registros de inclusão.
	// Caso encontrado, o campo GRAVA é alterado para "S" - "Sim"
	Do While (cAliasSTP2)->(!EoF())

		dbSelectArea("TRB5")
		dbGoTop()

		While TRB5->(!EoF())

			If TRB5->CODBEM == (cAliasSTP2)->T9_CODBEM

				RecLock("TRB5", .F.)
				TRB5->GRAVA := "S"
				TRB5->(MsUnlock())

			EndIf

			dbSelectArea("TRB5")
			dbSkip()

		End

		dbSelectArea(cAliasSTP2)
		dbSkip()

	EndDo

	(cAliasSTP2)->(dbCloseArea())

	//Query para obter os bens com registro de inclusão
	BeginSQL Alias cAliasISTZ

		SELECT DISTINCT
			STP.TP_FILIAL,
			STP.TP_CODBEM
		FROM
			%table:STP% STP
		INNER JOIN
			%table:STZ% STZ ON
				STZ.TZ_CODBEM = STP.TP_CODBEM AND
				STZ.TZ_DATAMOV || STZ.TZ_HORAENT < STP.TP_DTLEITU || STP.TP_HORA AND
				STZ.%NotDel%
		WHERE
			STP.TP_CODBEM IN (
								SELECT
									TRB.CODBEM
								FROM
									%exp:cTable% TRB
								WHERE
									TRB.%NotDel% AND
									TRB.OK <> ' ' ) AND
			STP.TP_TIPOLAN = 'I' AND
			STP.%NotDel%

	EndSQL

	//Grava na TRB os registros que possuem a inclusão após uma movimentação de estrutura STZ
	While (cAliasISTZ)->(!EoF())

		dbSelectArea("TRB5")
		dbGoTop()

		While TRB5->(!EoF())

			If TRB5->CODBEM == (cAliasISTZ)->TP_CODBEM .And. TRB5->FILIAL == (cAliasISTZ)->TP_FILIAL

				RecLock("TRB5", .F.)
				TRB5->GRAVA := "N"
				TRB5->(MsUnlock())

				//Array contendo bens que não podem ser processados
				aAdd(aNaoProc, {Alltrim((cAliasISTZ)->TP_CODBEM), STR0082}) //"Bem possui movimentação anterior ao registro de inclusão de contador."

			EndIf

			dbSelectArea("TRB5")
			dbSkip()

		End

		dbSelectArea(cAliasISTZ)
		dbSkip()

	End

	(cAliasISTZ)->(dbCloseArea())

	Processa({|| MNT877PRC()}, STR0018)	//"Aguarde... Reprocessando contador(s) do(s) Bem(s)..."

	RestArea(aArea)

	If !lInconsist

		MNT877LOG(aProc,aNaoProc)

		If lCorrigiu
			MsgInfo(STR0036)	//"Processo de correção realizado com sucesso! Finalizando rotina..."
			lProccess := .T.
		Else
			MsgInfo(STR0054)	//"Não houveram correções a serem realizadas. Encerrando a execução da rotina..."
			lProccess := .F.
		EndIf

		lCorrigiu := .F.

	Else

		MNT877LOG(aProc,aNaoProc)

		If lCorrigiu
			ShowHelpDlg("ATENCAO", {STR0037}, 1,;
								   {STR0038}, 1)
		Else
			ShowHelpDlg("ATENCAO", {STR0055}, 1,;
								   {STR0038}, 1)
		EndIf

		lCorrigiu := .F.

	EndIf

	//Apaga a tabela temporária
	fDelTTab("TRB5")

	aProc := {}
	aNaoProc := {}

Return .T.
//------------------------------------------------------------------------------------
/*/{Protheus.doc} MNT877PRC
Processa os bens que estão na TRB e com campo TRB5->GRAVA = "S".

@author Éwerton Cercal
@since 03/06/2015
@version P11
@return Nil
/*/
//------------------------------------------------------------------------------------
Function MNT877PRC()

	//Seleciona novamente a TRB, agora contando o número de bens que serão atualizados,
	//para utilização na função Processa()
	dbSelectArea("TRB5")
	dbGoTop()

	//Seleciona a TRB, preparando para a correção
	("TRB5")->(dbGoTop())
	ProcRegua(0)

	While TRB5->(!EoF())

		If TRB5->GRAVA == "S"

			lCorrigiu := .T.

			IncProc(STR0020 + AllTrim(TRB5->CODBEM))

			MNT877STZ(TRB5->CODBEM)

			MNT877STP(TRB5->CODBEM , TRB5->FILIAL) // Gera todos os STP para o bem informado

			aAdd(aProc, TRB5->CODBEM)	//Adiciona ao array que irá conter log final de bens processados

		EndIf

		dbSelectArea("TRB5")
		dbSkip()

	End

	cTimeFim := Time()

Return .T.
//------------------------------------------------------------------------------------
/*/{Protheus.doc} MNT877EXC
Reprocessa todos os bens da ST9, excluindo todos os registros dela, menos o primeiro

@author Vitor Emanuel Batista
@since 23/10/2013
@version P11
@param  cCodBem, Caracter, Código do bem a ser processado.
@param  cBranch, Caracter, Código da filial do bem a ser processado
@return Array {dDataIni,cHoraIni,nAcumul}, Data e Hora de Leitura, contador acumulado referente a inclusão (TP_TIPOLAN = I)

/*/
//------------------------------------------------------------------------------------
Function MNT877EXC(cCodBem , cBranch )

	Local dDataIni := cTod('  /  /    ') //Variável que armazena a data inicial conforme registro de inclusão
	Local cHoraIni := ''				//Variável que armazena a hora inicial conforme registro de inclusão
	Local aArea    := GetArea()	//Armazena a área de trabalho atual
	Local cQuery   := ''
	Local nAcumul  := 0

	// Busca o primeiro contador do bem
	dbSelectArea("STP")
	dbSetOrder(8) // "TP_FILIAL+TP_CODBEM+TP_TIPOLAN"
	If dbSeek(xFilial("STP") + cCodBem + "I")

		dbSelectArea("ST9")
		dbSetOrder(1)

		If dbSeek(cBranch + cCodBem)

			RecLock("ST9",.F.)
			ST9->T9_DTULTAC := STP->TP_DTLEITU
			ST9->T9_CONTACU := STP->TP_ACUMCON
			ST9->(MsUnLock())

		EndIf

		("ST9")->(dbCloseArea())

		//-------------------------------------
		// Indica data de cadastramento do bem
		//-------------------------------------
		dDataIni	:= STP->TP_DTLEITU
		cHoraIni 	:= STP->TP_HORA
		nAcumul		:= STP->TP_ACUMCON

		//----------------------------------------------
		// Deleta todos os contadores menos as inclusões
		//----------------------------------------------

		cQuery := "UPDATE " + RetSQLName("STP")
		cQuery += "   SET D_E_L_E_T_ = '*' , R_E_C_D_E_L_ = R_E_C_N_O_ "
		cQuery += " WHERE TP_CODBEM = " + ValToSQL(cCodBem)
		cQuery += "   AND TP_TIPOLAN <> 'I' AND TP_FILIAL = " + ValToSQL(cBranch)
		cQuery += "   AND D_E_L_E_T_ <> '*'"

		If TcSqlExec(cQuery) <> 0
			UserException(TCSQLError())
		EndIf

	EndIf

	("STP")->(dbCloseArea())

	RestArea(aArea)

Return {dDataIni,cHoraIni,nAcumul}
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT877STP
Gera todos os STP para o bem informado.
@type function
@author Hamilton Soldati
@since 26/03/2019
@version P12
@param  cCodBem, Caracter, Código do bem a ser processado.
@param  cBranch, Caracter, Filial do bem a ser processado.
@return True
/*/
//---------------------------------------------------------------------
Function MNT877STP( cCodBem , cBranch )

	Local cAliasSTZ := GetNextAlias()
	Local aParent	:= {}
	Local i
	Local aDadosInc	:= {}
	Local nAcumul	:= 0

	//--------------------------------------
	// Ajuste de Data e Hora da STP
	//---------------------------------------
	MNT877DTH(cCodBem)

	//-------------------------------------------
	//Exclui todas as STPs, menos a de Inclusão
	//-------------------------------------------
	aDadosInc	:= MNT877EXC(cCodBem , cBranch )

	nAcumul	:= aDadosInc[3]

	//------------------------------------------
	//Busca todas as movimentações do componente
	//------------------------------------------
	BeginSql Alias cAliasSTZ
		SELECT R_E_C_N_O_ AS RECNOSTZ, TZ_FILIAL,TZ_CODBEM,TZ_BEMPAI,TZ_LOCALIZ,TZ_DATAMOV,
				TZ_TIPOMOV,TZ_DATASAI,TZ_HORASAI,TZ_HORAENT,TZ_TEMCONT
		FROM %Table:STZ%
			WHERE TZ_CODBEM = %exp:cCodBem% AND %NotDel% AND TZ_FILIAL = %exp:cBranch%  AND TZ_TEMCONT IN ('P','I')
			ORDER BY TZ_FILIAL,TZ_CODBEM,TZ_DATAMOV,TZ_HORAENT
	EndSql

	While (cAliasSTZ)->(!Eof())

		If (cAliasSTZ)->TZ_TEMCONT == "P"

			cBemPai	:= RetParent((cAliasSTZ)->TZ_CODBEM,(cAliasSTZ)->TZ_DATAMOV,(cAliasSTZ)->TZ_HORAENT)

			//-------------------------------------------------------------------------
			// gera stp para pai da estrutura com data e hora de entrada do componente
			//-------------------------------------------------------------------------
			GeraStpPai( cBemPai, cAliasSTZ, (cAliasSTZ)->RECNOSTZ, "E" )

			If !Empty( (cAliasSTZ)->TZ_DATASAI ) .And. !Empty( (cAliasSTZ)->TZ_HORASAI )

				//-------------------------------------------------------------------------
				// gera stp para pai da estrutura com data e hora de saída do componente
				//-------------------------------------------------------------------------
				GeraStpPai( cBemPai, cAliasSTZ, (cAliasSTZ)->RECNOSTZ, "S" )

			EndIf

		Else

			cBemPai	:= (cAliasSTZ)->TZ_BEMPAI

		EndIf

		Aadd(aParent,{(cAliasSTZ)->TZ_CODBEM,cBemPai,(cAliasSTZ)->TZ_DATAMOV+(cAliasSTZ)->TZ_HORAENT,;
		(cAliasSTZ)->TZ_DATASAI+(cAliasSTZ)->TZ_HORASAI})
		dbSelectArea(cAliasSTZ)
		dbSkip()
	EndDo

	(cAliasSTZ)->(dbCloseArea())

	For i:=1 To Len(aParent)
		if Empty(aParent[i][4])
			aParent[i][4] := Dtos(dDatabase) + time()
		EndIf
		If MNTA877ATV(aParent[i][1],Substr(aParent[i][3],1,8),Substr(aParent[i][3],9,14))
			fGeraSTP(aParent[i],i,@nAcumul)
		EndIf
	Next i

	//------------------
	// Tratamento na TQV
	//------------------
	fUpdateTQV( cCodBem, cBranch, aDadosInc[1], aDadosInc[2] )

	//--------------------------------------------
	//Corrige campos da TQS de acordo com a  TQV
	//--------------------------------------------
	MNT877TQS(cCodBem, cBranch)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT877TQS
Recria a TQS conforme informações da TQV e os dados corrigidos da STP.

@author Éwerton Cercal
@param  cBem, Caracter, Código do pneu a ser processado.
@param  cBranch, Caracter, Filial do bem a ser processado.
@since 29/05/2015
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Function MNT877TQS(cBem, cBranch)

	Local cAliasQry := GetNextAlias()
	Local cQuery    := ""
	Local cAliasTQV := GetNextAlias()
	Local aCpBanda  := {}
	Local cBanda	:= "1"
	Local nBanda    := 0

	// Campos do padrão até TQS_KMR4 e demais via ponto de entrada. Caso seja criado novos precisa ser adicionado na array
	Local aBanda := {	{"1","TQS_KMOR"},;
						{"2","TQS_KMR1"},;
						{"3","TQS_KMR2"},;
						{"4","TQS_KMR3"},;
						{"5","TQS_KMR4"},;
						{"6","TQS_KMR5"},;
						{"7","TQS_KMR6"},;
						{"8","TQS_KMR7"},;
						{"9","TQS_KMR8"},;
						{"A","TQS_KMR9"}}

	Local nATRefer 	:= 6	// A partir de qual caracter, se cortar a string, fica somente o campo.
	                    	// Ex: "TQS->TQS_KMOR" => SubStr("TQS->TQS_KMOR",nATRefer) => "TQS_KMOR"
	Local aTQV 		:= {}	// Variável que armazena a data e hora das bandas da TQV
	Local nInd		:= 0	// Variável para laço FOR
	Local cCampo 	:= ""
	Local aNgHeader := {}
	Local cDataIni  := ""
	Local cDataFim  := ""
	Local nAcumIni  := 0
	Local nAcumFim  := 0
	Local nAcumBanda:= 0
	Local nKm       := 0
	Local cKms      := ""
	Local nDifAcum  := 0

	Default cBranch	:= xFilial("TQV")

	//----------------------------------------------------------------------------------------------------------------
	// Trecho abaixo busca o primeiro registro de cada banda ( que houve troca de banda ou o primeiro da original)
	//----------------------------------------------------------------------------------------------------------------
	cQuery := " SELECT TQV.TQV_CODBEM, TQV.TQV_DTMEDI, TQV.TQV_HRMEDI, TQV.TQV_BANDA FROM " + RetSQLName("TQV") + " TQV "
	cQuery += " WHERE (SELECT COUNT(TQV1.TQV_CODBEM) FROM " + RetSQLName("TQV") + " TQV1 "
	cQuery += "        WHERE TQV.TQV_FILIAL = TQV.TQV_FILIAL AND TQV1.TQV_CODBEM = TQV.TQV_CODBEM "
	cQuery += "		  AND TQV1.TQV_DTMEDI||TQV1.TQV_HRMEDI < TQV.TQV_DTMEDI||TQV.TQV_HRMEDI "
	cQuery += "        AND TQV1.TQV_BANDA = TQV.TQV_BANDA AND TQV1.D_E_L_E_T_ <> '*') = 0 "
	cQuery += " AND TQV.D_E_L_E_T_ <> '*' "
	cQuery += " AND TQV.TQV_CODBEM = " + ValToSQL(cBem)
	cQuery += " AND TQV.TQV_FILIAL = " + ValToSQL(cBranch)
	cQuery += " ORDER BY TQV_DTMEDI || TQV_HRMEDI DESC"
	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery(cQuery, cAliasTQV)

	dbSelectArea(cAliasTQV)
	dbGoTop()
	While (cAliasTQV)->(!Eof())
		aAdd(aTQV, {(cAliasTQV)->TQV_CODBEM, ((cAliasTQV)->TQV_DTMEDI + TQV_HRMEDI), (cAliasTQV)->TQV_BANDA})
		dbSelectArea(cAliasTQV)
		dbSkip()
	EndDo
	(cAliasTQV)->(dbCloseArea())

	//--------------------------------------------------------------------------------------
	// Trecho abaixo carrega array aCpBanda com todos os campos relacionados a km percorrido
	//--------------------------------------------------------------------------------------
	aNgHeader := NGHeader("TQS") //campos da TQS
	For nInd := 1 To Len(aNgHeader)
		cCampo 	:= aNgHeader[nInd,2]
		If SubStr(cCampo, 1, nATRefer) == "TQS_KM"
			aAdd(aCpBanda, cCampo)
		EndIf
	Next nInd

	//---------------------------------------------------------
	// Zera todos os campos da TQS relacionados a KM percorrido
	//---------------------------------------------------------
	cQuery := " UPDATE " + RetSQLName("TQS")
	cQuery += " SET "

	For nInd := 1 To (Len(aCpBanda) - 1)
		cQuery += " " + aCpBanda[nInd] + " = 0, "
	Next nInd

	cQuery += " " + aCpBanda[Len(aCpBanda)] + " = 0 "
	cQuery += " WHERE TQS_CODBEM = " + ValToSQL(cBem)
	cQuery += " AND TQS_FILIAL = "  + ValToSQL(cBranch)
	cQuery += " AND D_E_L_E_T_ <> '*' "

	If TcSqlExec(cQuery) <> 0
		UserException(TCSQLError())
	EndIf

	If Len( aTQV ) > 0

		Asort(aTQV,,,{|x,y| x[2] > y[2]})// Ordena descrescente todas as movimentações da TQV

		//--------------------------------------------------
		// Tratamento para quando há apenas uma banda
		// O km percorrido é carregado para apenas um campo
		//--------------------------------------------------
		If Len( aTQV ) == 1
			
			cBanda	:= aTQV[1][3]
			nBanda  := aScan(aBanda, {|x| AllTrim(x[1]) == AllTrim(cBanda)})
			cCampo 	:= aBanda[nBanda][2]

			cQuery := " UPDATE " + RetSQLName("TQS")
			cQuery += " SET " + cCampo + " = "
			cQuery += " ( SELECT "
			cQuery += 		" MAX( STP.TP_ACUMCON ) "
			cQuery += 	" FROM " + RetSQLName( 'STP' ) + " STP "
			cQuery += 	" WHERE "
			cQuery += 		" STP.TP_FILIAL = " + ValToSQL( xFilial( 'STP', cBranch ) ) + " AND " 
			cQuery += 		" STP.TP_CODBEM = TQS_CODBEM AND "
			cQuery += 		" STP.D_E_L_E_T_ <> '*' AND "
			cQuery += 		" STP.TP_CODBEM = " + ValToSQL( cBem ) + " ) "
			cQuery += " WHERE TQS_FILIAL = " + ValToSQL(cBranch)
			cQuery += " AND TQS_CODBEM = " + ValToSQL(cBem)
			cQuery += " AND D_E_L_E_T_ <> '*' "

			If TcSqlExec(cQuery) <> 0
				UserException(TCSQLError())
			EndIf

		EndIf

		//----------------------------------------------------------
		// Tratamento para distribuir o km acumulado para as bandas
		//----------------------------------------------------------
		If Len( aTQV ) > 1
			For nInd := 1 To Len( aTQV )

				cBanda := aTQV[nInd][3]
				nBanda := aScan(aBanda, {|x| AllTrim(x[1]) == AllTrim(cBanda)})
				cCampo := aBanda[nBanda][2]

				If nInd == 1
					cDataIni	:= aTQV[nInd][2]
					cDataFim	:= DtoS(dDataBase) + substring(time(),1,5)
				Else
					cDataIni	:= aTQV[nInd][2]
					cDataFim	:= aTQV[nInd-1][2]
				EndIf
				DbSelectArea("STP")
				DbSetOrder(9)

				//-------------------------------------------------------------------------
				// Atualiza o acumulado da banda de acordo com as datas de inicio e fim
				//-------------------------------------------------------------------------
				nAcumIni	:= NGGetCont(cBem , StoD(Substring(cDataIni,1,8)), Substring(cDataIni,9,5),,.F.)
				nAcumFim	:= NGGetCont(cBem , StoD(Substring(cDataFim,1,8)), Substring(cDataFim,9,5),,.F.)
				nAcumBanda	:= nAcumFim - nAcumIni

				cQuery := " UPDATE " + RetSQLName("TQS")
				cQuery += " SET " + cCampo + " = " + cValToChar(nAcumBanda)
				cQuery += " WHERE TQS_FILIAL = " + ValToSQL(cBranch)
				cQuery += " AND TQS_CODBEM = " + ValToSQL(cBem)
				cQuery += " AND D_E_L_E_T_ <> '*' "

				If TcSqlExec(cQuery) <> 0
					UserException(TCSQLError())
				EndIf
			Next nInd
		EndIf
	EndIf

	// Atualiza o contador acumulado da ST9 (T9_CONTACU)
	fAtuSt9(cBem , cBranch)

	//-----------------------------------------------------------------------------------
	// Tratamento abaixo para pneus que já iniciaram a vida no sistema com km percorrido
	// neste caso há uma diferença do acumulado da ST9 com o acumulado da TQS
	// essa diferença será somada ao primeiro km da vida do pneu no sistema
	//-----------------------------------------------------------------------------------
	If Len( aTQV ) > 0

		//concatena os campos para soma na query
		For nKm := 1 To Len( aCpBanda )
			cKms += Alltrim(aCpBanda[nKm])
			If nKm < Len( aCpBanda )
				cKms += "+"
			EndIf
		Next

		//Query para buscar a soma dos contadores de kms percorridos
		cQuery := "SELECT T9_CONTACU, (" +  cKms + " ) TQSTOTAL, TQS_KMOR "
		cQuery += "FROM " + RetSqlName( "ST9" ) + " ST9 "
		cQuery += "INNER JOIN " + RetSqlName( "TQS" ) + " TQS "
		cQuery += "    ON ST9.T9_CODBEM = TQS.TQS_CODBEM "
		cQuery += "    AND ST9.T9_FILIAL = TQS.TQS_FILIAL "
		cQuery += "    AND TQS.D_E_L_E_T_ <> '*' "
		cQuery += "WHERE ST9.T9_CODBEM = " + ValToSQL( cBem )
		cQuery += "    AND ST9.D_E_L_E_T_ <> '*' "
		cQuery += "    AND ST9.T9_FILIAL = " + ValToSQL( cBranch )

		cQuery := ChangeQuery( cQuery )
		MPSysOpenQuery( cQuery, cAliasQry )

		//Correção quando os valores de acumulados estão divergentes
		If (cAliasQry)->T9_CONTACU > (cAliasQry)->TQSTOTAL

			cBanda := aTQV[len(aTQV)][3]
			nBanda := aScan(aBanda, {|x| AllTrim(x[1]) == AllTrim(cBanda)})

			If nBanda > 1
				--nBanda
			EndIf
			cCampo 	:= aBanda[nBanda][2]

			If cCampo == "TQS_KMOR" .And. !Empty((cAliasQry)->TQS_KMOR)
				nDifAcum	:= (cAliasQry)->T9_CONTACU - ((cAliasQry)->TQSTOTAL - (cAliasQry)->TQS_KMOR)
			Else
				nDifAcum	:= (cAliasQry)->T9_CONTACU - (cAliasQry)->TQSTOTAL
			EndIf

			cQuery := " UPDATE " + RetSQLName("TQS")
			cQuery += " SET " + cCampo + " = " + cValToChar(nDifAcum)
			cQuery += " WHERE TQS_FILIAL = " + ValToSQL(cBranch)
			cQuery += " AND TQS_CODBEM = " + ValToSQL(cBem)
			cQuery += " AND D_E_L_E_T_ <> '*' "

			If TcSqlExec(cQuery) <> 0
				UserException(TCSQLError())
			EndIf
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf
Return .T.

//------------------------------------------------------------------------
/*/{Protheus.doc} fMark
Função para marcar/desmarcar os itens do browse.
@type function

@author Alexandre Santos
@since 23/09/2021

@param lAll, boolean, Indica se o processo acionado é para todos os itens.
@return
/*/
//------------------------------------------------------------------------
Static Function fMark( lAll )

	Local cQryMark := ''

	Default lAll   := .F.
	
	/*--------------------------------------------------------+
	| Inverte todas as marcações já existentes nos registros. |
	+--------------------------------------------------------*/
	If lAll

		cQryMark := "UPDATE " + oTmpTRB:GetRealName()
		cQryMark += 	" SET OK = CASE "
		cQryMark +=          		" WHEN OK <> '  ' THEN '  ' " 
		cQryMark +=					" ELSE " + ValToSQL( cMark )
		cQryMark +=				 " END"
					
		TcSQLExec( cQryMark )

	/*-----------------------------+
	| Marcações um único registro. |
	+-----------------------------*/
	Else
		
		If IsMark( 'OK', cMark )

			RecLock( 'TRB', .F. )
			TRB->OK := '  '
			MsUnLock()

		Else

			RecLock( 'TRB', .F. )
			TRB->OK := cMark
			MsUnLock()

		EndIf

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT877INC
Salva em uma TRB os bens inconsistentes para serem corrigidos.
@type function

@author Éwerton Cercal
@since 28/05/2015

/*/
//---------------------------------------------------------------------
Function MNT877INC()

	Local cWhere    := ''
	Local cSitBem   := ''
	Local cInsert   := ''
	Local cTop      := '%%'
	Local cAliasOut := GetNextAlias()
	Local _cGetDB   := TcGetDb()		//Obtém qual o Banco de Dados corrente
	Local aDBFB     := { { 'CODBEM', 'C', 16, 0 } }

	oTmpInc := FWTemporaryTable():New( 'TRB2', aDBFB )
	oTmpInc:AddIndex( '1', { 'CODBEM' } )
	oTmpInc:Create()

	cInsert := 'INSERT INTO ' + oTmpInc:GetRealName() + '( CODBEM )'
	cInsert +=		'SELECT DISTINCT '
	cInsert +=			'ST9.T9_CODBEM '
	cInsert +=		'FROM '
	cInsert += 			RetSQLName( 'ST9' ) + ' ST9 '
	cInsert +=		'INNER JOIN '
	cInsert += 			RetSQLName( 'STP' ) + ' STP ON '
	cInsert += 				'STP.TP_CODBEM  = ST9.T9_CODBEM AND '
	cInsert += 				'STP.TP_FILIAL  = '  + ValToSQL( xFilial( 'STP' ) ) + ' AND '
	cInsert += 				'STP.TP_TIPOLAN = '  + ValToSQL( 'I' )              + ' AND '
	cInsert += 				'STP.D_E_L_E_T_ <> ' + ValToSQL( '*' )
	cInsert +=		' WHERE '
	cInsert += 				'ST9.T9_FILIAL  = '  + ValToSQL( xFilial( 'ST9' ) ) + ' AND '
	cInsert +=				'ST9.T9_TEMCONT IN ("P","I") '					 	+ ' AND '
	cInsert += 				'ST9.D_E_L_E_T_ <> ' + ValToSQL( '*' )

	// Inclue filtro para situação do bem
	cSitBem := IIf( lSitBem, ' AND ST9.T9_SITBEM <> ' + ValToSQL( 'I' ), '' )

	// Se não estiver vazio e tiver vindo da função de Parâmetros
	If !Empty( cBemFim ) .And. !lMark .And. lParam

		cWhere  := 'AND ST9.T9_CODBEM BETWEEN ' + ValToSQL( cBemIni ) + ' AND ' + ValToSQL( cBemFim )

	// Se não estiver vazio e tiver vindo da função de MarkBrowse
	ElseIf !Empty( aBens ) .And. lMark .And. !lParam

		cWhere := 'AND '
		cWhere += 'ST9.T9_CODBEM IN ( '
		cWhere += 						'SELECT '
		cWhere += 							'TRB.CODBEM '
		cWhere += 						'FROM '
		cWhere += 							oTmpTRB:GetRealName() + ' TRB '
		cWhere += 						'WHERE '
		cWhere += 							'TRB.D_E_L_E_T_ <> ' + ValToSQL( '*' ) + ' AND '
		cWhere += 							'TRB.OK <> ' + ValToSQL( ' ' ) + ' )'

	EndIf

	cInsert += cWhere + cSitBem

	// Executa o comando INSERT INTO na tabela temporária.
	TcSQLExec( cInsert )

	// Adiciona condições extras no formato Embedded SQL
	cWhere := '%' + cWhere + cSitBem + '%'

	// Cria TRB com registros que tenham Tipo Lançamento diferente de 'I' - 'Inclusão'
	BeginSQL Alias cAliasOut

		SELECT DISTINCT
			ST9.T9_FILIAL ,
			ST9.T9_CODBEM ,
			ST9.T9_DTCOMPR
		FROM
			%table:ST9% ST9
		INNER JOIN
			%table:STP% STP ON
				STP.TP_CODBEM  = ST9.T9_CODBEM AND
				STP.TP_FILIAL  = %xFilial:STP% AND
				STP.TP_TIPOLAN <> 'I'          AND
				STP.%NotDel%
		WHERE
			ST9.T9_FILIAL  = %xFilial:ST9% AND
			ST9.T9_TEMCONT IN ('P','I')    AND
			ST9.%NotDel%
			%exp:cWhere%

	EndSQL

	// Verifica quais bens estão na query mas não estão na TRB
	Do While (cAliasOut)->( !EoF() )

		dbSelectArea("TRB2")
		dbGoTop()

		If !DbSeek((cAliasOut)->T9_CODBEM)

			//Se a data de compra estiver preenchida, envia a mesma. Senão, campo data em branco
			dDtCompra := IIf(!Empty((cAliasOut)->T9_DTCOMPR), (cAliasOut)->T9_DTCOMPR, CtoD("  /  /  "))

			cAlias1STP := GetNextAlias()
			_cGetDB    := AllTrim( _cGetDB )

			//Cria query que pega o primeiro registro do bem sem STP de inclusão
			If  _cGetDB == 'MSSQL'

				cQryGetTP := " SELECT TOP 1 STP1.R_E_C_N_O_ RECNOSTP "
				cQryGetTP += " FROM " + RetSQLName("STP") + " STP1 "
				cQryGetTP += " WHERE (SELECT COUNT(*) FROM " + RetSQLName("STP") + " STP2 "
				cQryGetTP += " WHERE  STP1.TP_CODBEM = STP2.TP_CODBEM AND STP1.TP_TIPOLAN IN ('P', 'A') AND STP2.D_E_L_E_T_ <> '*')  = 0 "
				cQryGetTP += " AND TP_CODBEM = " + ValToSQL((cAliasOut)->T9_CODBEM)
				cQryGetTP += " AND STP1.D_E_L_E_T_ <> '*' "

				cQryGetTP := ChangeQuery(cQryGetTP)
				MPSysOpenQuery(cQryGetTP, cAlias1STP)

			Else

				Do Case

					Case _cGetDB $ 'POSTGRES/MYSQL'
						cTop := '%LIMIT 1%'
					Case _cGetDB == 'ORACLE'
						cTop := '%AND ROWNUM <= 1%'
					Case _cGetDB == 'DB2'
						cTop := '%FETCH FIRST 1 ROW ONLY%'

				EndCase

				BeginSQL Alias cAlias1STP

					SELECT
						STP.R_E_C_N_O_ AS RECNOSTP
					FROM
						%table:STP% STP
					WHERE
						STP.TP_CODBEM = %exp:(cAliasOut)->T9_CODBEM% AND
						STP.%NotDel%
					%exp:cTop%

				EndSQL

			EndIf

			dbSelectArea("STP")
			dbGoTo((cAlias1STP)->RECNOSTP)

			If Empty(dDtCompra)
				lInconsist := .T.
			Else
				//Corrige registros inconsistentes
				MNT877COR(STP->TP_FILIAL, STP->TP_CODBEM, STP->TP_POSCONT, dDtCompra, 0, STP->TP_HORA)
				(cAlias1STP)->(dbCloseArea())
			EndIf

			("STP")->(dbCloseArea())

		EndIf

		dbSelectArea(cAliasOut)
		dbSkip()

	End

	(cAliasOut)->(dbCloseArea())

	//Apaga a tabela temporária
	fDelTTab("TRB2")

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT877COR
Corrige os registros inconsistentes.

@author Éwerton Cercal
@since 03/06/2015
@version P11
@return
/*/
//---------------------------------------------------------------------
Function MNT877COR(cFiliBem, cCodBem, cPosCont, dDtLeitu, nAcumul, cHora)

	If ValType(dDtLeitu) != "D"
		dDtLeitu := STOD(dDtLeitu)
	EndIf

	//Grava histórico de inclusão
	NGGRAVAHIS(cCodBem, cPosCont, 1, dDtLeitu, nAcumul, 0, cHora, 1, "I")

	//Grava a data de compra informada no Bem
	dbSelectArea("ST9")
	dbSetOrder(1)
	If dbSeek(cFiliBem + cCodBem)
		RecLock("ST9", .F.)
		ST9->T9_DTCOMPR := dDtLeitu
		ST9->(MsUnlock())
	EndIf
	("ST9")->(dbCloseArea())

Return .T.
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} MNT877LOG
Lista os bens que foram processados.

@author Éwerton Cercal
@since 22/06/2015
@version P11
@return Nil Nulo
/*/
//---------------------------------------------------------------------------------------
Function MNT877LOG(aProc, aNaoProc)

	Local cTexto := ""
	Local oFont
	Local cMask  := STR0056 //"Arquivos Texto (*.TXT) |*.txt|"
	Local oDlgMot
	Local nI := 0

	Default aProc    := {}
	Default aNaoProc := {}

	Private aLog := Array(1)

	If Empty(aProc) .And. Empty(aNaoProc)

		cTexto := STR0059	//"Nenhum bem foi processado."

	ElseIf Empty(aProc) .And. !Empty(aNaoProc)

		///////////////////////////////////////////////////
		//	Log de Bens que não podem ser processados	//
		///////////////////////////////////////////////////

		cTexto := STR0063 //"Os seguintes bens não podem ser processados: "
		cTexto += CRLF + CRLF

		For nI := 1 To Len(aNaoProc)

			cTexto += aNaoProc[nI][1] + " - " + aNaoProc[nI][2] + CRLF + CRLF

		Next nI

		If !Empty(cTexto)
			aLog[1] := {cTexto}
			Define Font oFont Name "Courier New" Size 5,0
			Define MsDialog oDlgMot Title STR0064 From 3,0 To 340,417 Color CLR_BLACK, CLR_WHITE Pixel Style DS_MODALFRAME //"Bens Não Processados"
				@ 5,5 Get oMemo  Var cTexto Memo Size 200,145 Of oDlgMot Pixel
					oMemo:bRClicked := {|| AllwaysTrue()}
					oMemo:oFont := oFont
					oMemo:lReadOnly := .T.

				Define SButton From 153,175 Type 1 Action oDlgMot:End() Enable Of oDlgMot Pixel
				Define SButton From 153,145 Type 13 Action (cFile := cGetFile(cMask, OemToAnsi(STR0060)), If(cFile == "", .T.,;
				                                  MemoWrite(cFile, cTexto)),) Enable Of oDlgMot Pixel	//"Salvar Como..."
			Activate MsDialog oDlgMot Centered
		EndIf

	ElseIf !Empty(aProc)

		/////////////////////////////////////////
		//	Log de Bens que foram processados	//
		////////////////////////////////////////
		cTexto := STR0083 + cTimeInic + CRLF + CRLF //"Inicio de processamento: "

		If Len(aNaoProc) > 0
			cTexto += STR0063 //"Os seguintes bens não podem ser processados: "
			cTexto += CRLF + CRLF

			For nI := 1 To Len(aNaoProc)

				cTexto += aNaoProc[nI][1] + " - " + aNaoProc[nI][2] + CRLF + CRLF

			Next nI

		EndIf

		cTexto += STR0057 //"Os seguintes bens foram processados: "
		cTexto += CRLF + CRLF

		For nI := 1 To Len(aProc)

			cTexto += aProc[nI] + CRLF

		Next nI
		cTexto += + CRLF + CRLF + STR0084 + cTimeFim + CRLF + CRLF //"Fim de processamento: "

		cTexto += STR0085 + ElapTime( cTimeInic, cTimeFim ) //"Tempo de processamento: "

		If !Empty(cTexto)
			aLog[1] := {cTexto}
			Define Font oFont Name "Courier New" Size 5,0
			Define MsDialog oDlgMot Title STR0058 From 3,0 To 340,417 Color CLR_BLACK, CLR_WHITE Pixel Style DS_MODALFRAME //"Bens Processados"
				@ 5,5 Get oMemo  Var cTexto Memo Size 200,145 Of oDlgMot Pixel
					oMemo:bRClicked := {|| AllwaysTrue()}
					oMemo:oFont := oFont
					oMemo:lReadOnly := .T.

				Define SButton From 153,175 Type 1 Action oDlgMot:End() Enable Of oDlgMot Pixel
				Define SButton From 153,145 Type 13 Action (cFile := cGetFile(cMask, OemToAnsi(STR0060)), If(cFile == "", .T.,;
				                                  MemoWrite(cFile, cTexto)),) Enable Of oDlgMot Pixel	//"Salvar Como..."
			Activate MsDialog oDlgMot Centered
		EndIf

	EndIf

	cTexto := ""

	If !Empty(aProc)
		aProc := {}
	ElseIf !Empty(aNaoProc)
		aNaoProc := {}
	EndIf

Return
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} MNT877DTH
Ajusta bens com data de leitura e/ou hora em brancos.

@author Éwerton Cercal
@since 23/06/2015
@version P11
@return Nil Nulo
/*/
//---------------------------------------------------------------------------------------
Function MNT877DTH(cCodBem)

	Local cQry1STP  := ""
	Local cAliasTP1 := GetNextAlias()
	Local cQry2STP  := ""
	Local cAliasTP2 := GetNextAlias()

	Local dDtLeitu := ""
	Local cHoraLei := ""

	cQry1STP := " SELECT R_E_C_N_O_ FROM " + RetSQLName("STP") + " STP "
	cQry1STP += " WHERE TP_FILIAL = " + ValToSQL(xFilial("STP"))
	cQry1STP += " AND TP_CODBEM = " + ValToSQL(cCodBem)
	cQry1STP += " AND TP_TIPOLAN = 'I' "
	cQry1STP += " AND D_E_L_E_T_ <> '*'"

	cQry1STP := ChangeQuery(cQry1STP)
	MPSysOpenQuery(cQry1STP, cAliasTP1)

	dbSelectArea(cAliasTP1)
	dbGoTop()

	cQry2STP := " SELECT R_E_C_N_O_ FROM " + RetSQLName("STP") + " STP "
	cQry2STP += " WHERE TP_FILIAL = " + ValToSQL(xFilial("STP"))
	cQry2STP += " AND TP_CODBEM = " + ValToSQL(cCodBem)
	cQry2STP += " AND TP_TIPOLAN <> 'I' "
	cQry2STP += " AND D_E_L_E_T_ <> '*'"

	cQry2STP += " ORDER BY TP_DTLEITU || TP_HORA "

	cQry2STP := ChangeQuery(cQry2STP)
	MPSysOpenQuery(cQry2STP, cAliasTP2)

	dbSelectArea(cAliasTP2)
	dbGoTop()

	//Se não for fim de arquivo, ou seja, houver 1 registro na query, procede
	If (cAliasTP1)->(!EoF())

		//Se não for fim de arquivo, ou seja, houver 1 registro na query, procede
		If (cAliasTP2)->(!EoF())

			dbSelectArea("STP")
			STP->(dbGoTo((cAliasTP2)->R_E_C_N_O_))

			If !Empty(STP->TP_DTLEITU)
				dDtLeitu := STP->TP_DTLEITU
			EndIf

			If !Empty(STP->TP_HORA)
				cHoraLei := STP->TP_HORA
			EndIf

			STP->(dbGoTo((cAliasTP1)->R_E_C_N_O_))

			If Empty(STP->TP_DTLEITU)	//Verifica se a Data de Leitura está vazia
				If !Empty(STP->TP_DTREAL)	//Caso a Data Real não esteja vazia, é usada como parâmetro comparativo, senão, usa Data Original
					If DTOS(STP->TP_DTREAL) > DTOS(dDtLeitu)	//Se a Data Real for maior que a Data de Leitura base, prossegue
						RecLock("STP", .F.)
						STP->TP_DTLEITU := MNT877DTA(dDtLeitu)
						STP->(MsUnlock())
					Else
						RecLock("STP", .F.)
						STP->TP_DTLEITU := MNT877DTA(STP->TP_DTREAL)
						STP->(MsUnlock())
					EndIf
				ElseIf !Empty(STP->TP_DTORIGI)
					If DTOS(STP->TP_DTORIGI) > DTOS(dDtLeitu)	//Se a Data Original for maior que a Data de Leitura base, prossegue
						RecLock("STP", .F.)
						STP->TP_DTLEITU := MNT877DTA(dDtLeitu)
						STP->(MsUnlock())
					Else
						RecLock("STP", .F.)
						STP->TP_DTLEITU := MNT877DTA(STP->TP_DTORIGI)
						STP->(MsUnlock())
					EndIf
				Else
					RecLock("STP", .F.)
					STP->TP_DTLEITU := MNT877DTA(dDtLeitu)
					STP->(MsUnlock())
				EndIf
			EndIf

			If Empty(STP->TP_HORA)	//Verifica se a hora está vazia
				RecLock("STP", .F.)
				STP->TP_HORA := cHoraLei
				STP->(MsUnlock())
			EndIf

		Else	//Caso a query esteja vazia

			STP->(dbGoTo((cAliasTP1)->R_E_C_N_O_))

			If Empty(STP->TP_DTLEITU)	//Verifica se a data de leitura está vazia
				If !Empty(STP->TP_DTREAL)	//Caso a Data Real não esteja vazia, é usada como parâmetro, senão, usa Data Original
					If DTOS(STP->TP_DTREAL) < DTOS(STP->TP_DTORIGI)
						RecLock("STP", .F.)
						STP->TP_DTLEITU := MNT877DTA(STP->TP_DTREAL)
						STP->(MsUnlock())
					Else
						RecLock("STP", .F.)
						STP->TP_DTLEITU := MNT877DTA(STP->TP_DTORIGI)
						STP->(MsUnlock())
					EndIf
				Else
					RecLock("STP", .F.)
					STP->TP_DTLEITU := MNT877DTA(STP->TP_DTORIGI)
					STP->(MsUnlock())
				EndIf
			EndIf

			If Empty(STP->TP_HORA)	//Verifica se a hora está vazia
				RecLock("STP", .F.)
				STP->TP_HORA := SubStr(Time(), 1, 5)
				STP->(MsUnlock())
			EndIf

		EndIf

	EndIf

	("STP")->(dbCloseArea())
	(cAliasTP1)->(dbCloseArea())
	(cAliasTP2)->(dbCloseArea())

Return
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} MNT877DTA()
Gera uma data anterior a repassada, conforme com o limite de dias de cada mês.

@author Éwerton Cercal
@since 23/06/2015
@version P11
@return Nil Nulo
/*/
//---------------------------------------------------------------------------------------
Function MNT877DTA(dDtInfo)

	Local dDtGer := ""		//Data a ser gerada
	Local cAno := "", cMes := "", cDia := "", nI := 0
	Local nMes := 0, nDia := 0
	Local aMeses := {}

	If ValType(dDtInfo) == "D"	//Verifica se é data. Se for, converte para string.
		dDtInfo := DTOS(dDtInfo)
	EndIf

	cAno := SubStr(dDtInfo, 1, 4)

	//Array com os meses do ano
	aAdd(aMeses, {1, 31})
	aAdd(aMeses, IIf(MNT877BIS(cAno), {2, 29}, {2, 28}))
	aAdd(aMeses, {3, 31})
	aAdd(aMeses, {4, 30})
	aAdd(aMeses, {5, 31})
	aAdd(aMeses, {6, 30})
	aAdd(aMeses, {7, 31})
	aAdd(aMeses, {8, 31})
	aAdd(aMeses, {9, 30})
	aAdd(aMeses, {10, 31})
	aAdd(aMeses, {11, 30})
	aAdd(aMeses, {12, 31})

	If !Empty(dDtInfo)	//Verifica se não está vazio antes de prosseguir

		//Manipula a string
		nMes := Val(SubStr(dDtInfo, 5, 2))
		nDia := Val(SubStr(dDtInfo, 7, 2))

		For nI := 1 To Len(aMeses)

			If nMes == aMeses[nI][1]	//Busca o mês

				If (nDia - 1) == 0	//Caso diminuir um dia o torne igual a 0

					If nI == 1
						nMes := aMeses[12][1]
						nDia := aMeses[12][2]
					Else
						nMes := aMeses[nI - 1][1]
						nDia := aMeses[nI - 1][2]
					EndIf

					Exit
				Else
					nDia := nDia - 1
					Exit
				EndIf

			EndIf

		Next nI

		cMes := STRZERO(nMes, 2, 0)
		cDia := cValToChar(nDia)

		dDtGer := cAno + cMes + cDia

		If ValType(dDtGer) <> "D"
			dDtGer := STOD(dDtGer)
		EndIf
	EndIf

	If Empty(dDtGer)
		dDtGer := CtoD("  /  /    ")
	EndIf

Return dDtGer
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} MNT877BIS
Verifica se o ano é bissexto.

@author Éwerton Cercal
@since 23/06/2015
@version P11
@return Nil Nulo
/*/
//---------------------------------------------------------------------------------------
Function MNT877BIS(cAno)

	Local cFinal	:= SubStr(cAno, 3, 2)
	Local nResult	:= 0
	Local lRet		:= .F.

	If cFinal == "00"
	     nResult := Mod(Val(cAno), 400)
	Else
	     nResult := Mod(Val(cAno), 4)
	EndIf

	If nResult == 0
	     lRet := .T.
	EndIf

Return lRet
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} MNT877VER
Verifica se existem bens sem STP e/ou sem STZ.
Ao encontrá-los, pratica correção, criando STP (pois a STZ é somente para parâmetro
de criação de registro na STP. Caso não exista, a STP é criada com base nos dados da
ST9).

@author Éwerton Cercal
@since 01/07/2015
@version P11
@return .T. - Verdadeiro
/*/
//---------------------------------------------------------------------------------------
Function MNT877VER()

	Local cQryVSTP   := ''
	Local cAliasBens := GetNextAlias()
	Local cBensList  := ''
	Local dDtUltAc   := CtoD("  /  /    ")	//Data do Último Acompanhamento
	Local aAreaSTZ   := {}
	Local aAreaST9   := {}
	Local aDBFB8     := { { 'CODBEM', 'C', 16, 0 } }
	Local aBensSTP   := {}
	Local nI         := 0
	Local bFound     := .T.
	Local cWhere     := ''

	oTmpASTP := FWTemporaryTable():New( 'TRB8', aDBFB8 )
	oTmpASTP:AddIndex( '1', { 'CODBEM' } )
	oTmpASTP:Create()

	// INSERT INTO na tabela temporária com base na query que verifica se há registro de inclusão do bem.
	cQryVSTP := 'INSERT INTO ' + oTmpASTP:GetRealName() + '( CODBEM )'
	cQryVSTP += 	'SELECT DISTINCT '
	cQryVSTP +=			'STP.TP_CODBEM '
	cQryVSTP +=		'FROM '
	cQryVSTP += 		RetSQLName( 'STP' ) + ' STP '
	cQryVSTP += 	'WHERE '
	cQryVSTP +=			'STP.TP_TIPOLAN = '  + ValToSQL( 'I' ) + ' AND '
	cQryVSTP += 		'STP.D_E_L_E_T_ <> ' + ValToSQL( '*' )

	// Se não estiver vazio e tiver vindo da função de Parâmetros
	If !Empty( cBemFim ) .And. !lMark .And. lParam

		cWhere += ' AND STP.TP_CODBEM BETWEEN ' + ValToSQL( cBemIni ) + ' AND ' + ValToSQL( cBemFim )

	// Se não estiver vazio e tiver vindo da função de MarkBrowse
	ElseIf !Empty(aBens) .And. lMark .And. !lParam

		cWhere := ' AND STP.TP_CODBEM IN ( '
		cWhere +=							'SELECT '
		cWhere += 								'TRB.CODBEM '
		cWhere +=		 					'FROM '
		cWhere += 								oTmpTRB:GetRealName() + ' TRB '
		cWhere += 							'WHERE '
		cWhere += 								'TRB.D_E_L_E_T_ <> ' + ValToSQL( '*' ) + ' AND '
		cWhere += 								'TRB.OK <> '         + ValToSQL( ' ' ) + ' )'

	EndIf

	cQryVSTP += cWhere

	// Executa o comando INSERT INTO na tabela temporária.
	TcSQLExec( cQryVSTP )

	// Converte comando para Embedded SQL
	cWhere := '%' + cWhere + '%'

	BeginSQL Alias cAliasBens

		SELECT DISTINCT
			STP.TP_CODBEM,
			STP.TP_FILIAL
		FROM
			%table:STP% STP
		WHERE
			STP.%NotDel%
			%exp:cWhere%

	EndSQL

	// Verifica se existem registros na STP sem inclusão
	If (cAliasBens)->( !EoF() )

		Do While (cAliasBens)->( !EoF() )

			dbSelectArea("TRB8")

			If !DBSeek((cAliasBens)->TP_CODBEM)
				aAdd(aBensSTP, {(cAliasBens)->TP_CODBEM, (cAliasBens)->TP_FILIAL})	//"Bem sem registro de inclusão na STP"
				bFound = .F.
			EndIf

			dbSelectArea(cAliasBens)
			dbSkip()

		EndDo

	EndIf

	(cAliasBens)->( dbCloseArea() )

	If(bFound)
		//Apaga a tabela temporária
		fDelTTab("TRB8")
		Return .T.//Se todos os bens tiverem registro de inclusão na STP, sai da função
	EndIf

	cBensList := ""

	If !Empty(aBensSTP)

		For nI := 1 To Len(aBensSTP)

			dbSelectArea("ST9")
			dbSetOrder(1)

			If dbSeek(aBensSTP[nI,2] + aBensSTP[nI,1])	//Pesquisa pela ST9 com os dados do array

				dbSelectArea("STZ")
				dbSetOrder(1)

				If dbSeek(ST9->T9_FILIAL + ST9->T9_CODBEM)	//Pesquisa na STZ, para poder utilizar dados do registro

					aAreaST9 := ST9->(GetArea())
					aAreaSTZ := STZ->(GetArea())

					//Cria registro de inclusão para o bem com base nos dados da ST9 e STZ
					NGGRAVAHIS(ST9->T9_CODBEM, IIf(STZ->TZ_POSCONT < STZ->TZ_CONTSAI, STZ->TZ_POSCONT, STZ->TZ_CONTSAI),;
								1, STZ->TZ_DATAMOV, IIf(ST9->T9_CONTACU >= 0, ST9->T9_CONTACU, STZ->TZ_POSCONT), 0, STZ->TZ_HORAENT, 1, "I")

					dDtUltAc := STZ->TZ_DATAMOV

					RestArea(aAreaST9)
					RestArea(aAreaSTZ)

					If STZ->TZ_TIPOMOV == "S"	//Caso o registro da STZ seja de Saída, é preciso criar mais um registro, só que de informe

						aAreaST9 := ST9->(GetArea())
						aAreaSTZ := STZ->(GetArea())

						//Neste registro, se leva em consideração o contador de saída, data de saída e hora de saída
						NGGRAVAHIS(ST9->T9_CODBEM, STZ->TZ_CONTSAI, 1, STZ->TZ_DATASAI, ST9->T9_CONTACU, 0, STZ->TZ_HORASAI, 1, "C")

						dDtUltAc := STZ->TZ_DATASAI

						RestArea(aAreaST9)
						RestArea(aAreaSTZ)

					EndIf

					dbSelectArea("ST9")

					RecLock("ST9", .F.)
					ST9->T9_DTULTAC := dDtUltAc	//Data do último acompanhamento
					ST9->(MsUnLock())

					("ST9")->(dbCloseArea())

				EndIf

				("STZ")->(dbCloseArea())

			Else

				If dbSeek(aBensSTP[nI,2] + aBensSTP[nI,1])	//Pesquisa pela ST9 com os dados da TRB

					If !Empty(ST9->T9_DTCOMPR)

						aAreaST9 := ST9->(GetArea())

						//Cria registro de inclusão para o bem com base nos dados da ST9
						NGGRAVAHIS(ST9->T9_CODBEM, ST9->T9_POSCONT, 1, IIf(!Empty(ST9->T9_DTULTAC), ST9->T9_DTULTAC, ST9->T9_DTCOMPR),;
									IIf(ST9->T9_CONTACU >= 0, ST9->T9_CONTACU, 0), 0, "00:00", 1, "I")

						RestArea(aAreaST9)

						dbSelectArea("ST9")

						If Empty(ST9->T9_DTULTAC)

							RecLock("ST9", .F.)
							ST9->T9_DTULTAC := ST9->T9_DTCOMPR
							ST9->(MsUnlock())

						EndIf

						("ST9")->(dbCloseArea())

					EndIf

				EndIf

				If aScan(aNaoProc, {|x| x[1] == aBensSTP[nI,1] }) == 0

					//Array contendo bens que não podem ser processados
					aAdd(aNaoProc, {aBensSTP[nI,1], STR0065})	//"Bem sem registro de movimentação para uma estrutura"

				EndIf

			EndIf

			("ST9")->(dbCloseArea())

			dDtUltAc := CtoD("  /  /    ")

		Next nI

	EndIf

	//Apaga a tabela temporária
	fDelTTab("TRB8")

Return .T.
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} MNT877CGEN
Procura por registros da ST9 sem campo T9_DTULTAC preenchido ou registros da STP
com TP_DTLEITU vazio e os corrige.

@author Éwerton Cercal
@since 01/07/2015
@version P11
@return .T. - Verdadeiro
/*/
//---------------------------------------------------------------------------------------
Function MNT877CGEN()

	Local cAliasCors  := GetNextAlias()
	Local cWhereT9    := '%%'
	Local cWhereTP    := '%%'
	Local cAliasIncor := GetNextAlias()
	Local dDtUltAc    := CtoD("  /  /    ")	//Data do Último Acompanhamento
	Local aAreaST9    := {}

	// Se não estiver vazio e tiver vindo da função de Parâmetros
	If !Empty( cBemFim ) .And. !lMark .And. lParam

		cWhereT9 := '%AND ST9.T9_CODBEM BETWEEN ' + ValToSQL( cBemIni ) + ' AND ' + ValToSQL( cBemFim ) + '%'

		cWhereTP := '%AND STP.TP_CODBEM BETWEEN ' + ValToSQL( cBemIni ) + ' AND ' + ValToSQL( cBemFim ) + '%'

	// Se não estiver vazio e tiver vindo da função de MarkBrowse
	ElseIf !Empty( aBens ) .And. lMark .And. !lParam

		cWhereT9 := '%AND '
		cWhereT9 += 'ST9.T9_CODBEM IN ( '
		cWhereT9 += 						'SELECT '
		cWhereT9 += 							'TRB.CODBEM '
		cWhereT9 += 						'FROM '
		cWhereT9 += 							oTmpTRB:GetRealName() + ' TRB '
		cWhereT9 += 						'WHERE '
		cWhereT9 += 							"TRB.D_E_L_E_T_ <> ' ' AND "
		cWhereT9 += 							"TRB.OK <> ' ' )%"

		cWhereTP := '%AND '
		cWhereTP += 'STP.TP_CODBEM IN ( '
		cWhereTP += 						'SELECT '
		cWhereTP += 							'TRB.CODBEM '
		cWhereTP += 						'FROM '
		cWhereTP += 							oTmpTRB:GetRealName() + ' TRB '
		cWhereTP += 						'WHERE '
		cWhereTP += 							"TRB.D_E_L_E_T_ <> ' ' AND "
		cWhereTP += 							"TRB.OK <> ' ' )%"

	EndIf

	// Query que irá conter todos os bens com T9_DTULTAC e/ou TP_DTLEITU vazios.
	BeginSQL Alias cAliasCors

		SELECT
			ST9.T9_FILIAL ,
			ST9.T9_CODBEM ,
			ST9.T9_DTCOMPR,
			ST9.T9_DTULTAC,
			STP.TP_DTLEITU
		FROM
			%table:ST9% ST9
		JOIN
			%table:STP% STP ON
				STP.TP_CODBEM = ST9.T9_CODBEM AND
				STP.TP_FILIAL = %xFilial:STP% AND
				STP.%NotDel%
		WHERE
			ST9.T9_FILIAL  = %xFilial:ST9% AND
			ST9.T9_DTULTAC =  '' AND
			ST9.T9_DTCOMPR <> '' AND
			ST9.%NotDel%
			%exp:cWhereT9%
		ORDER BY
			ST9.T9_CODBEM

	EndSQL

	Do While (cAliasCors)->( !EoF() )

		dbSelectArea("ST9")
		dbSetOrder(1)

		If dbSeek((cAliasCors)->T9_FILIAL + (cAliasCors)->T9_CODBEM)

			aAreaST9 := ST9->(GetArea())

			MNT877DTH(ST9->T9_CODBEM)

			dbSelectArea("STP")
			dbSetOrder(5)

			If dbSeek((cAliasCors)->T9_FILIAL + (cAliasCors)->T9_CODBEM)
				dDtUltAc := STP->TP_DTLEITU
			EndIf

			("STP")->(dbCloseArea())

			RestArea(aAreaST9)

			RecLock("ST9", .F.)
			ST9->T9_DTULTAC := dDtUltAc
			ST9->(MsUnlock())

		EndIf

		("ST9")->(dbCloseArea())

		dDtUltAc := CtoD("  /  /    ")

		dbSelectArea(cAliasCors)
		dbSkip()

	EndDo

	(cAliasCors)->( dbCloseArea() )

	BeginSQL Alias cAliasIncor

		SELECT
			STP.TP_CODBEM
		FROM
			%table:STP% STP
		JOIN
			%table:ST9% ST9 ON
				ST9.T9_CODBEM  = STP.TP_CODBEM AND
				ST9.T9_FILIAL  = %xFilial:ST9% AND
				ST9.T9_DTCOMPR = ''            AND
				ST9.T9_DTULTAC = ''            AND
				ST9.%NotDel%
		WHERE
			STP.TP_FILIAL  = %xFilial:STP% AND
			STP.TP_DTLEITU = ''            AND
			STP.%NotDel%
			%exp:cWhereTP%

	EndSQL

	Do While (cAliasIncor)->( !EoF() )

		If aScan(aNaoProc, {|x| x[1] == (cAliasIncor)->TP_CODBEM }) == 0
			aAdd(aNaoProc, {(cAliasIncor)->TP_CODBEM, STR0066})
		EndIf

		dbSelectArea(cAliasIncor)
		dbSkip()

	EndDo

	(cAliasIncor)->(DbCloseArea())

	If !Empty(aNaoProc)
		If MsgYesNo(STR0062)	//"Foram encontrados bens que não poderão ser corrigidos! Deseja visualizar o log com estes bens?"
			MNT877LOG(,aNaoProc)
		EndIf
	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fDelTTab
Deleta as tabelas temporárias

@sample
fDelTTab(cTRB)

@param cTRB: Alias do arquivo
@param cTTable: Referência ao TTable
@author Wexlei Silveira
@since 17/05/2016
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fDelTTab(cTRB, cTTable)

Default cTTable := cTRB

DbselectArea(cTRB)
If(cTTable == "TRB")
	oTmpTRB:Delete()
ElseIf(cTTable == "STZ")
	oTmpSTZ:Delete()
ElseIf(cTTable == "STP")
	oTmpSTP:Delete()
ElseIf(cTTable == "TRB5")
	oTmpBem:Delete()
ElseIf(cTTable == "TRB2")
	oTmpInc:Delete()
ElseIf(cTTable == "TRB8")
	oTmpASTP:Delete()
EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT877STZ
Atualiza a STZ com dados já corrigidos do bem pai na STP

@sample
MNT877STZ()

@author Wexlei Silveira
@since 16/09/2016
@version 1.0
/*/
//---------------------------------------------------------------------
Function MNT877STZ(cCodBem)

Local cQrySTZ := ""
Local cQrySTP := ""
Local cQryBSTZ := ""
Local cAliasSTP := GetNextAlias()
Local cAliasSTZ := GetNextAlias()
Local nContSai := 0

cQrySTP := "SELECT TP_CODBEM, TP_POSCONT, TP_DTLEITU, TP_HORA"
cQrySTP += "  FROM " + RetSQLName("STP")
cQrySTP += " WHERE TP_CODBEM IN(SELECT DISTINCT TZ_BEMPAI"
cQrySTP += "                      FROM " + RetSQLName("STZ")
cQrySTP += "                     WHERE TZ_CODBEM = " +ValToSQL(cCodBem)
cQrySTP += "                       AND D_E_L_E_T_ <> '*')"
cQrySTP += "   AND D_E_L_E_T_ <> '*'"
cQrySTP += "   AND TP_TIPOLAN = 'C'"
cQrySTP += " ORDER BY TP_CODBEM, TP_DTLEITU, TP_HORA"

cQryBSTZ := "SELECT TZ_FILIAL, TZ_CODBEM, TZ_BEMPAI, TZ_TIPOMOV, TZ_DATAMOV,"
cQryBSTZ += "       TZ_HORAENT, TZ_HORACO1, TZ_POSCONT, TZ_DATASAI, TZ_HORASAI, TZ_CONTSAI"
cQryBSTZ += "  FROM " + RetSQLName("STZ")
cQryBSTZ += " WHERE D_E_L_E_T_ <> '*' AND TZ_CODBEM = " +ValToSQL(cCodBem)

cQrySTP := ChangeQuery(cQrySTP)
MPSysOpenQuery(cQrySTP, cAliasSTP)

dbSelectArea(cAliasSTP)
dbGoTop()
While (cAliasSTP)->(!Eof())

	cQrySTZ := cQryBSTZ
	cQrySTZ += "   AND TZ_BEMPAI = " + ValToSQL((cAliasSTP)->TP_CODBEM)
	cQrySTZ += " ORDER BY TZ_DATAMOV, TZ_HORACO1, TZ_DATASAI, TZ_HORASAI, TZ_CODBEM"
	cQrySTZ := ChangeQuery(cQrySTZ)
	MPSysOpenQuery(cQrySTZ, cAliasSTZ)

	dbSelectArea(cAliasSTZ)
	dbGoTop()
	While (cAliasSTZ)->(!EoF())

		If (SToD((cAliasSTZ)->TZ_DATAMOV) == SToD((cAliasSTP)->TP_DTLEITU) .And.;
		   ((cAliasSTZ)->TZ_HORAENT == (cAliasSTP)->TP_HORA .Or. (cAliasSTZ)->TZ_HORACO1 == (cAliasSTP)->TP_HORA))

			dbSelectArea("STZ")
			dbSetOrder(5)
			dbSeek((cAliasSTZ)->TZ_FILIAL + (cAliasSTZ)->TZ_BEMPAI + (cAliasSTZ)->TZ_CODBEM + (cAliasSTZ)->TZ_DATAMOV + (cAliasSTZ)->TZ_HORAENT)
			RecLock("STZ", .F.)
			STZ->TZ_POSCONT := (cAliasSTP)->TP_POSCONT
			STZ->TZ_CONTSAI := 0
			STZ->(MsUnlock())
			("STZ")->(DbCloseArea())
		EndIf

		If (SToD((cAliasSTZ)->TZ_DATASAI) > SToD((cAliasSTP)->TP_DTLEITU) .Or.;
		       (SToD((cAliasSTZ)->TZ_DATASAI) == SToD((cAliasSTP)->TP_DTLEITU) .And.;
			   ((cAliasSTZ)->TZ_HORACO1 >= (cAliasSTP)->TP_HORA .Or.(cAliasSTZ)->TZ_HORASAI >= (cAliasSTP)->TP_HORA)) .And.;
		       (cAliasSTZ)->TZ_TIPOMOV == "S")//Registro de saída

			dbSelectArea("STP")
			dbSetOrder(9)
			If dbSeek((cAliasSTZ)->TZ_BEMPAI + (cAliasSTZ)->TZ_DATASAI + MToH(HToM((cAliasSTZ)->TZ_HORASAI) + 1))
				nContSai := STP->TP_POSCONT
			Else
				nContSai := -1
			EndIf
			("STP")->(DbCloseArea())

			dbSelectArea("STZ")
			dbSetOrder(6)
			dbSeek((cAliasSTZ)->TZ_FILIAL + (cAliasSTZ)->TZ_BEMPAI + (cAliasSTZ)->TZ_CODBEM + (cAliasSTZ)->TZ_DATASAI + (cAliasSTZ)->TZ_HORASAI)
			RecLock("STZ", .F.)
			STZ->TZ_CONTSAI := IIF(nContSai != -1, nContSai, (cAliasSTP)->TP_POSCONT)
			STZ->(MsUnlock())
			("STZ")->(DbCloseArea())

		EndIf

		(cAliasSTZ)->(dbSkip())

	End

(cAliasSTZ)->(DbCloseArea())
(cAliasSTP)->(dbSkip())

End

(cAliasSTP)->(DbCloseArea())

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA877ATV
Verifica se o bem está numa posição ativa na estrutura no período informado

@sample
fPosAtiv(cCodBem, dData, cHora)

@param cCodBem: Código do bem a ser pesquisado (Obrigatório)
@param dData: Data em que o bem esteve na estrutura (Obrigatório)
@param cHora: Hora em que o bem esteve na estrutura (Obrigatório)

@author Wexlei Silveira
@since 30/09/2016
@version 1.0
@return True se o bem estiver ativo, False se inativo
/*/
//---------------------------------------------------------------------
Function MNTA877ATV(cCodBem, dData, cHora)

Local lRet      := .F.
Local cQrySTZ   := ""
Local cQrySTC   := ""
Local cAliasSTZ := GetNextAlias()
Local cAliasSTC := GetNextAlias()

Local aArea := GetArea()

If Valtype(dData) == "D"
	dData := DToS(dData)
EndIf

cQrySTZ := "SELECT TZ_BEMPAI, TZ_LOCALIZ"
cQrySTZ += "  FROM " + RetSQLName("STZ")
cQrySTZ += " WHERE D_E_L_E_T_ <> '*'"
cQrySTZ += "   AND TZ_FILIAL = " + ValToSQL(xFilial("STZ"))
cQrySTZ += "   AND TZ_CODBEM = " + ValToSQL(cCodBem)
cQrySTZ += "   AND ((TZ_TIPOMOV = 'E' AND TZ_DATAMOV || TZ_HORACO1 <= " + ValToSQL(dData+cHora) + ")"
cQrySTZ += "    OR (TZ_TIPOMOV = 'S' AND " + ValToSQL(dData) + " BETWEEN TZ_DATAMOV AND TZ_DATASAI"
cQrySTZ += "                         AND (" + ValToSQL(dData+cHora) + " < TZ_DATASAI || TZ_HORASAI )))"

cQrySTZ := ChangeQuery(cQrySTZ)
MPSysOpenQuery(cQrySTZ, cAliasSTZ)
dbSelectArea(cAliasSTZ)

If (cAliasSTZ)->(EoF())
	(cAliasSTZ)->(DbCloseArea())
	Return .T.
EndIf

cQrySTC := " SELECT T9_CODFAMI, T9_TIPMOD, TC_MANUATI "
cQrySTC += " FROM " + RetSqlName("ST9") + " ST9 "
cQrySTC += " JOIN " + RetSqlName("STC") + " STC "
cQrySTC += "    ON TC_FILIAL = " + ValToSQL(xFilial("STC")) + " AND TC_TIPOEST = 'F' "
cQrySTC += "       AND TC_CODBEM = ST9.T9_CODFAMI AND (TC_TIPMOD = ST9.T9_TIPMOD OR TC_TIPMOD = '*') "
cQrySTC += "       AND TC_LOCALIZ =  " + ValToSQL((cAliasSTZ)->TZ_LOCALIZ)
cQrySTC += " WHERE ST9.D_E_L_E_T_ <> '*' "
cQrySTC += "   AND T9_FILIAL = " + ValToSQL(xFilial("ST9"))
cQrySTC += "   AND T9_CODBEM = " + ValToSQL((cAliasSTZ)->TZ_BEMPAI)
cQrySTC += "   AND STC.D_E_L_E_T_ <> '*' "

cQrySTC := ChangeQuery(cQrySTC)
MPSysOpenQuery(cQrySTC, cAliasSTC)

dbSelectArea(cAliasSTC)

lRet := ((cAliasSTC)->(EoF()) .Or. Empty(Trim(((cAliasSTC)->TC_MANUATI))) .Or. (cAliasSTC)->TC_MANUATI == "S")

(cAliasSTZ)->(DbCloseArea())
(cAliasSTC)->(DbCloseArea())

RestArea(aArea)

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fPaiEstr
Retorna o Pai da estrutura do componente

@sample
fPaiEstr(cCodBem)

@param cCodBem: Código do bem a ser pesquisado (Obrigatório)

@author Wexlei Silveira
@since 09/12/2016
@version 1.0
@return cPai: Código do pai da estrutura
/*/
//---------------------------------------------------------------------
Static Function fPaiEstr(cCodBem)

Local cPai := ""
Local aArea := GetArea()
Local cAtuFil := ""

dbSelectArea("ST9")
dbSetOrder(16)
If dbSeek(cCodBem + "A")//Filial em que o bem está ativo
	cAtuFil := T9_FILIAL
Else
	cAtuFil := xFilial("ST9")
EndIf

dbSelectArea("ST9")
dbSetOrder(1)

If dbSeek(xFilial("ST9") + cCodBem)

	If(ST9->T9_TEMCONT == "S")//Contador próprio

		cPai := ST9->T9_CODBEM

	ElseIf(ST9->T9_TEMCONT == "I")//Contador controlado pelo pai imediato

		dbSelectArea("STC")
		dbSetOrder(3)

		If dbSeek(xFilial("STC") + cCodBem)
			cPai := TC_CODBEM
		EndIf

		("STC")->(dbCloseArea())

	ElseIf(ST9->T9_TEMCONT == "P")//Contador controlado pelo pai da estrutura

		dbSelectArea("STC")
		dbSetOrder(3)

		If dbSeek(cAtuFil + cCodBem)
			cPai := fPaiEstr(TC_CODBEM)
		EndIf

		("STC")->(dbCloseArea())

	EndIf

EndIf

("ST9")->(dbCloseArea())

RestArea(aArea)

Return cPai
//---------------------------------------------------------------------
/*/{Protheus.doc} fParam
Popup de parâmetros da grid de importação

Para adicionar uma nova aba de opções, siga as instruções nos comentários
da função e adicione o parâmetro MV_PAR da SX1 na função fCriaParam() nos
mesmos moldes dos parâmetros já existentes lá. Na função principal
(MNTA876) também é necessário inicializar o MV_PAR criado para o parâmetro
da nova aba. Já há um bloco lá para isso.

@sample
fParam()

@author Wexlei Silveira
@since 09/12/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fParam()

Local oDlgPP, oPnlTop, oPnlCenter, oPnlBottom
Local aOpt := {}
Local nOptBI := IIf(MV_PAR01 == 0, 1, MV_PAR01)
Local lOK := .F.
Local aTFolder := {STR0086} //"Bens inativos"

aAdd(aOpt, {STR0087, STR0088}) //"Permitir" ## "Não permitir"

Define MsDialog oDlgPP From 0,0 To 200,420 Title STR0069 Pixel Style DS_MODALFRAME //"Parâmetros"

	oPnlTop := TPanel():New(0, 0,, oDlgPP,,,,,, 200, 20, .F., .F.)
	oPnlCenter := TPanel():New(20, 0,, oDlgPP,,,,,, 200, 100, .F., .F.)
	oPnlBottom := TPanel():New(200, 400,, oDlgPP,,,,,CLR_HGRAY, 200, 15, .F., .F.)
	oPnlTop:Align := CONTROL_ALIGN_TOP
	oPnlBottom:Align := CONTROL_ALIGN_BOTTOM
	oPnlCenter:Align := CONTROL_ALIGN_ALLCLIENT

	oTFolder := TFolder():New(0,0,aTFolder,,oPnlCenter,,,,.T.,,200,100)
	oTFolder:Align := CONTROL_ALIGN_ALLCLIENT

	@ 05, 05 Say OemToAnsi(STR0067) Size 180, 60 Of oPnlTop Pixel

	/*Aba Bens inativos*/
	@ 15, 05 Say OemToAnsi(STR0068) Size 110, 65 Of oTFolder:aDIALOGS[1] Pixel
	@ 15, 125 To 45, 180 LABEL "" of oTFolder:aDIALOGS[1] Pixel
	TRadMenu():New(16, 130, aOpt[1], {|u| IIf (PCount() == 0, nOptBI, nOptBI := u)}, oTFolder:aDIALOGS[1],,,,,,,, 50, 60,,,, .T.)

	/*Barra inferior com os botões OK/Cancelar*/
	@ 3,120 BUTTON STR0089 SIZE 036,010 Pixel OF oPnlBottom ACTION(lOK := .T., oDlgPP:End()) //"OK"
	@ 3,160 BUTTON STR0090 SIZE 036,010 Pixel OF oPnlBottom ACTION(lOK := .F., oDlgPP:End()) //"Cancelar"

	Activate MsDialog oDlgPP Centered

	If lOK //Bloco de If para inserir na SX1 a opção selecionada na nova aba
		MV_PAR01 := nOptBI//MV_PAR criado para manter a opção escolhida ao longo da utilização da rotina.
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} RetParent
Retorna o Bem Pai da estrutura de acordo com período parametrizado.
@type function

@author  Douglas Constancio
@author  Hamilton Soldati
@since   01/03/2019
@version P12 R1
@param cEqpmtCode, character, Bem da estrutura
@param cReadgDate, character, Data e hota de Leitura/ Movimentação
@param cEntryDate, character, Hora de Leitura/ Movimentação
@param character, Pai da estrutura encontrado no período informado
@obs: Não possui o ChangeQuery proprositalmente.
@obs: Função que deve substituir a NGBEMPAI() do padrão.
@return cParent: Código do pai da estrutura
/*/
//-------------------------------------------------------------------
Static Function RetParent(cEqpmtCode, cReadgDate, cEntryDate)

	Local aArea     := GetArea()
	Local cAliasQry := GetNextAlias()
	Local cParent   := ''
	Local cQuery    := ''
	Local _cGetDB 	:= TcGetDb()
	Local cConcat   := If( 'SQL' $ _cGetDB, '+', '||' ) //Função CONCAT() não é reconhecido para SQL Server anterior a 2012

	cQuery := "   WITH

	If _cGetDB $ "POSTGRES"
		cQuery += " RECURSIVE
	EndIf
	cQuery += " 	PARENT_SEARCH
	cQuery += " 	(TZ_CODBEM,TZ_BEMPAI,TZ_DATAMOV,TZ_HORAENT,TZ_DATASAI,TZ_HORASAI,NIVEL) "
	cQuery += "	 	AS ("
	cQuery += " SELECT coalesce(MAX(TZ.TZ_CODBEM), NULL) AS TZ_CODBEM,"
	cQuery += "        coalesce(MAX(TZ.TZ_BEMPAI), " + ValToSQL(cEqpmtCode) + ") AS TZ_BEMPAI,"
	cQuery += "        coalesce(MAX(TZ.TZ_DATAMOV), '') AS TZ_DATAMOV,"
	cQuery += "        coalesce(MAX(TZ.TZ_HORAENT), '') AS TZ_HORAENT,"
	cQuery += "        coalesce(MAX(TZ.TZ_DATASAI), '') AS TZ_DATASAI,"
	cQuery += "        coalesce(MAX(TZ.TZ_HORASAI), '') AS TZ_HORASAI,"
	cQuery += "        0 AS NIVEL"
	cQuery += "   FROM " + RetSQLName('STZ') + " TZ"
	cQuery += "  WHERE TZ.D_E_L_E_T_ <> '*'"
	cQuery += "    AND TZ.TZ_CODBEM = " + ValToSQL(cEqpmtCode)
	cQuery += "    AND TZ.TZ_DATAMOV " + cConcat + " TZ.TZ_HORAENT = " + ValToSQL(cReadgDate + cEntryDate)
	cQuery += "  UNION ALL"
	cQuery += " SELECT TZ.TZ_CODBEM,"
	cQuery += "        TZ.TZ_BEMPAI,"
	cQuery += "        TZ.TZ_DATAMOV,"
	cQuery += "        TZ.TZ_HORAENT,"
	cQuery += "        TZ.TZ_DATASAI,"
	cQuery += "        TZ.TZ_HORASAI,"
	cQuery += "        (PARENT.NIVEL + 1) AS NIVEL"
	cQuery += "   FROM " + RetSQLName('STZ') + " TZ"
	cQuery += "  INNER JOIN PARENT_SEARCH PARENT"
	cQuery += "     ON PARENT.TZ_BEMPAI = TZ.TZ_CODBEM "
	cQuery += "    AND TZ.D_E_L_E_T_ <> '*'"
	cQuery += "   AND TZ.TZ_DATAMOV " + cConcat + " TZ.TZ_HORAENT <= " + ValToSQL(cReadgDate + cEntryDate)
	cQuery += "   AND ( TZ.TZ_DATASAI " + cConcat + " TZ.TZ_HORASAI  = ' ' "
	cQuery += " 		OR TZ.TZ_DATASAI " + cConcat + " TZ.TZ_HORASAI > " + ValToSQL(cReadgDate + cEntryDate)
	cQuery += " ) )"
	If _cGetDB $ "ORACLE/POSTGRES"
		If _cGetDB == "ORACLE"
			cQuery += " SELECT TZ_BEMPAI FROM PARENT_SEARCH WHERE RowNum <= 1 ORDER BY NIVEL DESC"
		Else
			cQuery += " SELECT TZ_BEMPAI FROM PARENT_SEARCH LIMIT 1 "
		EndIf
	Else
		cQuery += " SELECT TOP 1 TZ_BEMPAI FROM PARENT_SEARCH ORDER BY NIVEL DESC"
	EndIf
	MPSysOpenQuery(cQuery, cAliasQry) //Changequery não suporta expressão WITH

	dbSelectArea(cAliasQry)
	dbGoTop()
	If  (cAliasQry)->(!Eof())
		cParent := (cAliasQry)->TZ_BEMPAI
	EndIf

	(cAliasQry)->(dbCloseArea())

	RestArea(aArea)

Return cParent

//-------------------------------------------------------------------
/*/{Protheus.doc} fGeraSTP
Função para criar apontamento de contador para os bens filhos
@type function

@author  Hamilton Soldati
@since   12/12/2019
@version P12 R1
@param aParent, Array, {Bem, Bem Pai, Data e Hora Entrada, Data e Hora Saida}
@param nVezes, numerico, Indica quantas vezes passou pelo. Usado no For.
@param nAcumul, numerico, Contador acumulado do bem
@return nAcumul, numerico, Contador acumulado do bem incrementado
/*/
//-------------------------------------------------------------------
Static Function fGeraSTP(aParent,nVezes, nAcumul)

	Local cAliasSTP	:= GetNextAlias()
	Local aBemMov	:= aParent
	Local lPrime	:= .T.
	Local lPassou	:= .T.
	Local nAcumulPai:= 0
	Local cTipolan  := ""

	// Busca as movimentações da STP dos bens Pais
	BeginSql Alias cAliasSTP
		SELECT
			TP_FILIAL, TP_CODBEM, TP_DTLEITU, TP_HORA, TP_POSCONT, TP_ACUMCON, TP_TIPOLAN
		FROM
			%Table:STP%
		WHERE
			TP_CODBEM = %exp:aBemMov[2]% AND %NotDel%
			AND TP_DTLEITU || TP_HORA BETWEEN  %exp:aBemMov[3]% AND %exp:aBemMov[4]%
		ORDER BY
			TP_DTLEITU, TP_HORA
	EndSql

	// Percorre todos os registros da STP do bem Pai para gerar ao filho.
	While (cAliasSTP)->(!Eof())
		// Verifica se é o mesmo bem pai e se passou 1x. Objetivo é buscar o contador acumulado igual para gravar na entrada da estrutura.
		If nVezes == 1 .And. lPrime
			lPrime	:= .F.
			dBSelectArea("STP")
			dbSetOrder(5) // TP_FILIAL+TP_CODBEM+DTOS(TP_DTLEITU)+TP_HORA
			If MsSeek((cAliasSTP)->TP_FILIAL + aBemMov[1] + aBemMov[3])
				nAcumul		:= STP->TP_ACUMCON
			EndIf

			nAcumulPai	:= (cAliasSTP)->TP_ACUMCON
			cTipolan := "C"
		Else
			cTipolan := (cAliasSTP)->TP_TIPOLAN

			If nVezes > 1 .and. lPassou
				lPassou	:= .F.
			Else
				nAcumul	 := ((cAliasSTP)->TP_ACUMCON - nAcumulPai) + nAcumul
			EndIf
		EndIf

		NGGRAVAHIS(aBemMov[1], (cAliasSTP)->TP_POSCONT, 0, StoD((cAliasSTP)->TP_DTLEITU), nAcumul ,0,(cAliasSTP)->TP_HORA, 1,;
					cTipolan, (cAliasSTP)->TP_FILIAL, (cAliasSTP)->TP_FILIAL)

		nAcumulPai	:= (cAliasSTP)->TP_ACUMCON
		fCalVardia(aBemMov[1],(cAliasSTP)->TP_DTLEITU,(cAliasSTP)->TP_HORA,1,nAcumul,(cAliasSTP)->TP_FILIAL)

		dbSelectArea(cAliasSTP)
		DbSkip()
	EndDo

	(cAliasSTP)->(dbCloseArea())

Return nAcumul

//---------------------------------------------------------------------
/*/{Protheus.doc} fCalVardia
Calcula a variação dia

@author Hamilton Soldati
@since 19/02/2019
@version P12
param cBem		, Caractere	, Código do bem
param dDataLei	, Data		, Data de leitura do contador (TP_DTLEITU/TPP_DTLEITU)
param cHrLei	, Caractere	, Hora de leitura do contador (TP_HORA/TPP_HORA)
param nTipo		, Numerico	, Tipo de contador, 1 para 1º Contador e 2 para 2º Contador
param nContAcu	, Numerico	, Contador acumulado do bem
param cFilCont	, Caractere	, Filial da tabela STP/TPP

@return Nil
/*/
//---------------------------------------------------------------------
Static Function fCalVardia( cBem, dDataLei, cHrLei, nTipo, nContAcu, cFilCont )

	Local nREGVAR 	:= GetNewPar("MV_VARDIA",0)
	Local cAliasCon	:= GetNextAlias()
	Local cQuery	:= ""
	Local cTable 	:= IIF(nTipo == 1, RetSqlName('STP'), RetSqlName('TPP'))
	Local cPrefixo 	:= IIF(nTipo == 1, "TP_", "TPP_")
	Local _cGetDB 	:= TcGetDb()
	Local cConcat   := If( 'SQL' $ _cGetDB, '+', '||' ) //Função CONCAT() não é reconhecido para SQL Server anterior a 2012

	cQuery	:= " WITH Table_VD AS "
	cQuery	+= " 	( SELECT " + cPrefixo + "DTLEITU , "
	cQuery	+= 				cPrefixo + "ACUMCON , "
	cQuery	+= " 			ROW_NUMBER() OVER( "
	cQuery	+= " 				ORDER BY " + cPrefixo + "DTLEITU " + cConcat + "  " + cPrefixo + "HORA DESC ) AS RowNum1 "
	cQuery	+= " FROM " + cTable
	cQuery	+= " 	WHERE " + cPrefixo + "FILIAL = " + ValToSQL(cFilCont) + " AND D_E_L_E_T_ <> '*' AND " + cPrefixo + "CODBEM = " + ValToSQL(cBem)
	cQuery	+= "			 AND " + cPrefixo + "DTLEITU " + cConcat + "  " + cPrefixo + "HORA <= " + ValToSQL(dDataLei+cHrLei) + ")"
	cQuery	+= " 	SELECT ROUND( "
	cQuery	+= " 		CASE WHEN

	If _cGetDB $ "ORACLE/POSTGRES"
		cQuery	+= " 	( TO_DATE( " + ValToSQL(dDataLei) + " ,'YYYYMMDD') - TO_DATE(" +  cPrefixo + "DTLEITU" + ",'YYYYMMDD')) < 1 "
	Else
		cQuery	+= "	datediff(dd," + cPrefixo + "DTLEITU, " + ValToSQL(dDataLei) + " )  < 1"
	EndIF

	cQuery	+= " 		THEN (" + ValToSQL(nContAcu) + "-" + cPrefixo +"ACUMCON) / 1 "
	cQuery	+= " 		ELSE (" + ValToSQL(nContAcu) + "-" + cPrefixo +"ACUMCON) / "

	If AllTrim(_cGetDB) $ "ORACLE/POSTGRES"
		cQuery	+= "    ( TO_DATE( " + ValToSQL(dDataLei) + " ,'YYYYMMDD') - TO_DATE(" +  cPrefixo + "DTLEITU" + ",'YYYYMMDD')) "
	Else
		cQuery	+= " 	datediff(dd," + cPrefixo + "DTLEITU, " + ValToSQL(dDataLei) + " ) "
	EndIf

	cQuery	+= "			END,0) as nVardia FROM Table_VD "
	cQuery	+= "		WHERE CASE "
	cQuery	+= "		WHEN RowNum1 < " + ValToSQL(nREGVAR) + " THEN "
	cQuery	+= "			(SELECT max(RowNum1) "
	cQuery	+= "			FROM Table_VD) "
	cQuery	+= "				ELSE " + ValToSQL(nREGVAR)
	cQuery	+= "			END = RowNum1 "
	MPSysOpenQuery(cQuery, cAliasCon)//Changequery não suporta expressão WITH

	If nTipo == 1 .And. STP->(DbSeek(cFilCont + cBem + dDataLei + cHrLei ))
		RecLock("STP", .F.)
		TP_VARDIA	:= If (!Empty((cAliasCon)->nVardia),(cAliasCon)->nVardia, 1)
		STP->(MsUnLock())
	Else
		DbSelectArea("TPP")
		TPP->(DbSetOrder(5)) // TPP_FILIAL + TPP_CODBEM + TPP_DTLEIT + TPP_HORA
		If TPP->(DbSeek(cFilCont + cBem + dDataLei + cHrLei ))
			RecLock("TPP", .F.)
			TPP_VARDIA	:=  If (!Empty((cAliasCon)->nVardia),(cAliasCon)->nVardia, 1)
			TPP->(MsUnLock())
		EndIf
	EndIf

	(cAliasCon)->(dbCloseArea())

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fAtuSt9
Atualiza a ST9 de acordo com a STP

@author Hamilton Soldati
@since 01/03/2019
@version P12
param cTire , Caractere, Código do bem
param cBranch, Caractere , Código da filial do bem
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fAtuSt9(cTire , cBranch)

	Local cAliasSTP	:= GetNextAlias()

	BeginSql Alias cAliasSTP
		SELECT TP_POSCONT, TP_ACUMCON, TP_VARDIA, TP_DTLEITU
		FROM %Table:STP%
			WHERE TP_CODBEM = %exp:cTire% AND %NotDel% AND TP_FILIAL = %exp:cBranch%
			ORDER BY TP_DTLEITU || TP_HORA DESC
	EndSql

	If (cAliasSTP)->(!Eof())
		//Ajusta o contador acumulado do Bem
		dbSelectArea('ST9')
		dbSetOrder(1)
		If MsSeek( cBranch + cTire )
			Reclock( 'ST9', .F. )
			ST9->T9_CONTACU := (cAliasSTP)->TP_ACUMCON
			ST9->T9_POSCONT	:= (cAliasSTP)->TP_POSCONT
			ST9->T9_VARDIA	:= (cAliasSTP)->TP_VARDIA
			ST9->T9_DTULTAC := StoD((cAliasSTP)->TP_DTLEITU)
			ST9->( MsUnlock())
		EndIf
	EndIf

	(cAliasSTP)->(dbCloseArea())

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fUpdateTQV
Corrige inconsistências da TQV

@author Hamilton Soldati
@since 01/03/2019
@version P12
@param cTire , Caractere, Código do bem
@param cBranch, Caractere , Código da filial do bem
@param dDataIni, date, data da STP de inclusão
@param cHoraIni, hora da STP de inclusão

@return Nil
/*/
//---------------------------------------------------------------------
Static Function fUpdateTQV( cCodBem, cBranch, dDataIni, cHoraIni )

	Local cAliasTQV	:= GetNextAlias()
	Local lFirst    := .T.

	// Busca as alterações de banda e desenho
	BeginSql Alias cAliasTQV
		SELECT TQV_FILIAL, TQV_CODBEM, TQV_DTMEDI, TQV_HRMEDI, TQV_BANDA, TQV_DESENH, TQV_SULCO
	FROM %Table:TQV%
		WHERE TQV_CODBEM = %exp:cCodBem% AND %NotDel% AND TQV_FILIAL = %exp:cBranch%
		ORDER BY TQV_FILIAL || TQV_DTMEDI || TQV_HRMEDI
	EndSql

	DbselectArea("TQV")
	DbSetOrder(01) // TQV_FILIAL+TQV_CODBEM+TQV_DTMEDI+TQV_HRMEDI+TQV_BANDA

	While (cAliasTQV)->(!EoF())
		//-------------------------------------------------------
		// Cria primeiro registro da TQV igual a STP de inclusão
		//-------------------------------------------------------
		If lFirst
			lFirst := .F.
			If !TQV->(DbSeek(xFilial("TQV") + cCodBem + DtoS(dDataIni) + cHoraIni))
				Reclock( "TQV", .T. )
				TQV->TQV_FILIAL	:=	(cAliasTQV)->TQV_FILIAL
				TQV->TQV_CODBEM	:=	(cAliasTQV)->TQV_CODBEM
				TQV->TQV_DTMEDI	:= 	dDataIni
				TQV->TQV_HRMEDI	:= 	cHoraIni
				TQV->TQV_BANDA	:=	(cAliasTQV)->TQV_BANDA
				TQV->TQV_DESENH	:=	(cAliasTQV)->TQV_DESENH
				TQV->TQV_SULCO	:=	(cAliasTQV)->TQV_SULCO
				TQV->( MsUnLock())
			EndIf
		EndIf

		If TQV->(DbSeek((cAliasTQV)->TQV_FILIAL + (cAliasTQV)->TQV_CODBEM + (cAliasTQV)->TQV_DTMEDI + (cAliasTQV)->TQV_HRMEDI))

			//---------------------------------------------------------------------------------
			// Deleta TQV caso a data e hora da medição for menor que o primeiro contador
			//---------------------------------------------------------------------------------
		 	If DtoS(TQV->TQV_DTMEDI) + TQV->TQV_HRMEDI < DtoS(dDataIni) + cHoraIni
		 		Reclock( "TQV", .F. )
		 		dbDelete()
		 		MsUnLock()
		 		Loop
		 	EndIf

			//--------------------------------------------------
		 	// Limpa o campo desenho se a banda é original
			 //------------------------------------------------
			If TQV->TQV_BANDA == "1" .And. !Empty(TQV->TQV_DESENH)
				Reclock( "TQV", .F. )
				TQV->TQV_DESENH	:= ""
				MsUnLock()
			EndIf
		EndIf
		dbSelectArea(cAliasTQV)
		DbSkip()
	EndDo

	(cAliasTQV)->(dbCloseArea())

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GeraStpPai
Gera uma STP para o pai da estrutura com data e hora da entrada do compoennte na STZ
Obs.: é utilizado para quando o pai imediato tem contador próprio

@author Maria Elisandra de Paula
@since 28/07/2020
@param cFather, string, Pai da estrutura
@param cAliasSTZ, string, tabela temporária
@param nRecnoStz, numerico, recno da stz
@param cType, string, E=entrada ou S=saída
@return Nil
/*/
//------------------------------------------------------------------------------------------
Static Function GeraStpPai( cFather, cAliasSTZ, nRecnoStz, cType )

	Local aCount   := {}
	Local dDataStz := IIf( cType == "E", StoD( (cAliasSTZ)->TZ_DATAMOV ), Stod((cAliasSTZ)->TZ_DATASAI ) )
	Local cHoraStz := IIf( cType == "E", (cAliasSTZ)->TZ_HORAENT, (cAliasSTZ)->TZ_HORASAI )

	dbSelectArea("STP")
	dbSetOrder(1)
	If !dbSeek( xFilial("STP", (cAliasSTZ)->TZ_FILIAL )  + cFather + Dtos( dDataStz ) + cHoraStz )

		//----------------------------------
		// busca contador exato ou anterior
		//----------------------------------
		aCount := NGACUMEHIS( cFather, dDataStz, cHoraStz, 1, "E", (cAliasSTZ)->TZ_FILIAL )

		NGGRAVAHIS( cFather, aCount[1], aCount[6], dDataStz, aCount[2], aCount[5],;
					cHoraStz, 1, "C", (cAliasSTZ)->TZ_FILIAL, (cAliasSTZ)->TZ_FILIAL, "MNTA877" )

		//--------------------------------------------
		// Ajusta STZ do componente de acordo com pai
		//--------------------------------------------
		dbSelectArea("STZ")
		dbGoTo( nRecnoStz )
		Reclock("STZ", .F.)
		If cType == "E"
			STZ->TZ_POSCONT := aCount[1]
		Else
			STZ->TZ_CONTSAI := aCount[1]
		EndIf
		MsUnlock()

	EndIf

Return
