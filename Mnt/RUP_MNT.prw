#Include 'Protheus.ch'
#Include "Topconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} RUP_MNT
Função exemplo de compatibilização do release incremental. Esta função é relativa ao módulo Manutenção de Ativos.
Serão chamadas todas as funções compiladas referentes aos módulos cadastrados do Protheus
Será sempre considerado prefixo "RUP_" acrescido do nome padrão do módulo sem o prefixo SIGA.
Ex: para o módulo SIGAMNT criar a função RUP_MNT

@param  cVersion   - Versão do Protheus
@param  cMode      - Modo de execução. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida Ex: 002
@param  cRelFinish - Release de chegada Ex: 005
@param  cLocaliz   - Localização (país) Ex: BRA

@Author Tainã Alberto Cardoso
@since 17/09/2015
@version P12
/*/
//-------------------------------------------------------------------
Function RUP_MNT( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )

	Local cQuery     := ""
	Local cModComp   := ''
	Local cAlsTUB    := ''
	Local aRegDelSX9 := {}
	Local lFrota     := ""

	//Trativa para quando executado ambiente TOTVS PDV
	#IFDEF TOP

		lFrota     := GetNewPar("MV_NGMNTFR","N") == "S"

		FWLogMsg('WARN',, 'BusinessObject', 'RUP_MNT', '', '01', "Executar RUP", 0, 0, {})

		/*  ---  DOCUMENTAÇÃO DE EXECUÇÃO DO UPDDISTR - [ https://tdn.totvs.com/x/XiYXEQ ] ---

		Regra geral : só executar atualização quando release de partida diferente do release de chegada
		A decisão, no entanto, cabe ao desenvolvedor
		A decisão de executar ou não pode estar condicionada a outros fatores

		If !( cRelStart == cRelFinish )

			ConOut( "Executei o update do faturamento")
			ConOut( "Modo - " + If( cMode == "1", "Grupo de empresas", "Grupo de empresas + filial" ) )
			ConOut( "Grupo de empresas " + cEmpAnt )   // cEmpAnt está disponível
			ConOut( "Localização (país) " + cLocaliz ) // Pode-se tomar decisões baseado no país

			If cMode == "2"
				Através do controle de cModo, é possível escolher entre processos que devem rodar para
				todo o grupo de empresa ( cModo = 1 ) ou processos que serão disparados por grupo + filial
				Ambas as opções serão executadas cabendo ao desenvolvedor escolher
				ConOut( "Filial " + cFilAnt )	// cFilAnt está disponível
			EndIf

			A versão é passada ( Ex "12" ) e pode ser necessária no futuro
			ConOut( "Versão - " + cVersion )

			Os releases de partida (início) e chegada (fim) são no formato caractere com 3 dígitos.
			Exemplo : 001, 003

			ConOut( "Release de partida - " + cRelStart )
			ConOut( "Release de chegada - " + cRelFinish )
		EndIf
		*/
		If cMode == '1'

			cModComp := '%AND ' + NGModComp( 'TAF', 'TUB' ) + '%'
			cAlsTUB  := GetNextAlias()

			// TUB_OPCAO
			BeginSQL Alias cAlsTUB

				SELECT
					TUB.TUB_FILIAL
				FROM
					%table:TUB% TUB
				INNER JOIN
					%table:TAF% TAF ON
						TAF.TAF_CODNIV = TUB.TUB_CODIGO AND
						TAF.TAF_INDCON = '1'            AND
						TAF.%NotDel%
						%exp:cModComp%
				WHERE
					TUB.TUB_OPCAO = '8' AND
					TUB.%NotDel%

			EndSQL

			If (cAlsTUB)->( !EoF() )

				cQuery := 'UPDATE '
				cQuery += 	RetSQLName( 'TUB' )
				cQuery += ' SET '
				cQuery += 	"TUB_OPCAO  = '0', "
				cQuery += 	"TUB_CODIGO = TAF.TAF_CODCON "
				cQuery += "FROM "
				cQuery += 	RetSQLName( 'TUB' ) + " TUB "
				cQuery += "INNER JOIN "
				cQuery += 	RetSQLName( 'TAF' ) + " TAF ON "
				cQuery += 	  "TAF.TAF_CODNIV = TUB.TUB_CODIGO AND "
				cQuery += 	  "TAF.TAF_INDCON = '1'            AND "
				cQuery += 	  "TAF.D_E_L_E_T_ <> '*'           AND "
				cQuery += 	  NGModComp( 'TAF', 'TUB' )
				cQuery += "WHERE "
				cQuery += 	"TUB.D_E_L_E_T_ <> '*' AND "
				cQuery += 	"TUB.TUB_OPCAO = '8'"

				TCSqlExec( cQuery )

			EndIf

			(cAlsTUB)->( dbCloseArea() )

			// TTD_SEQFAM
			cQuery := " UPDATE "
			cQuery += RetSqlName("TTD")+" "
			cQuery += " SET TTD_SEQFAM = '001' "
			cQuery += " WHERE TTD_SEQFAM =  ' ' "
			TcSqlExec(cQuery)

			// TTE_SEQFAM
			cQuery := " UPDATE "
			cQuery += RetSqlName("TTE")+" "
			cQuery += " SET TTE_SEQFAM = '001' "
			cQuery += " WHERE TTE_SEQFAM = ' ' "
			TcSqlExec(cQuery)

			// TAF_SITNIV
			cQuery := "UPDATE "
			cQuery += RetSqlName("TAF") + " "
			cQuery += " SET TAF_SITNIV = '1' "
			cQuery += " WHERE TAF_SITNIV = ' ' "
			TcSqlExec(cQuery)

			// TZ5_ATIVO
			cQuery := "UPDATE "
			cQuery += RetSqlName("TZ5")+" "
			cQuery += " SET TZ5_ATIVO = '1' "
			cQuery += " WHERE TZ5_ATIVO = ' ' "
			TcSqlExec(cQuery)

			// Aqui escolhi processar alguma coisa release 004 ou maior
			If cRelStart < '004' .And. cRelFinish >= "004" .And. lFrota

				// Alteração de novo campo criado na ST6, valor padrão '1'
				cQuery := " UPDATE " + RetSQLName("ST6")
				cQuery += " SET T6_SINCRON = '1'"
				cQuery += " WHERE D_E_L_E_T_ <> " + ValToSql("*")
				cQuery += "   AND T6_SINCRON = ' ' "
				TcSqlExec( cQuery )

				// Alteração de novo campo criado na ST9, valor padrão '2' (Nao)
				cQuery := " UPDATE " + RetSQLName("ST9")
				cQuery += " SET T9_PARTEDI = '2'"
				cQuery += " WHERE D_E_L_E_T_ <> " + ValToSql("*")
				cQuery += "   AND T9_PARTEDI = ' ' "
				TcSqlExec( cQuery )

				//Adiciona relacionamentos incorretos no array para exclusão
				aAdd( aRegDelSX9, { 'TTB', 'TTC', 'TTB_CDSINT', 'TTC_ ORDEM+TTC_CDSINT' } )
				aAdd( aRegDelSX9, { 'TT9', 'TPM', 'TT9_TAREFA', 'TPM_DEPEND' } )
				aAdd( aRegDelSX9, { 'TT9', 'TPM', 'TT9_TAREFA', 'TPM_TAREFA' } )
				aAdd( aRegDelSX9, { 'TT9', 'STM', 'TT9_TAREFA', 'TM_DEPENDE' } )
				aAdd( aRegDelSX9, { 'TT9', 'STM', 'TT9_TAREFA', 'TM_TAREFA'  } )
				aAdd( aRegDelSX9, { 'TU2', 'TU2', 'TU2_CODFAM+TU2_TIPMOD', 'TU3_CODFAM+TU3_TIPMOD' } )
				aAdd( aRegDelSX9, { 'TU3', 'TU2', 'TU3_CODFAM+TU3_TIPMOD', 'TU2_CODFAM+TU2_TIPMOD' } )
				aAdd( aRegDelSX9, { 'TUP', 'TUN', 'TUN_CODIGO', 'TUP_CODGRU' } )

			EndIf

			If cRelStart < '007' .And. cRelFinish >= "007"

				//-------------------------------------------------------------------
				// [Início] Inicialização dos campos criados no Construção Civil
				//-------------------------------------------------------------------

				//Inicializa campos T9_PROPRIE e T9_LUBRIFI
				If NGCADICBASE('T9_LUBRIFI','A','ST9',.F.) .And. lFrota
					FWLogMsg('WARN',, 'BusinessObject', 'RUP_MNT', '', '01', "Entrou na verificação do Construção Civil - Vai Atualizar Base", 0, 0, {})
					cQuery := " UPDATE " + RetSQLName("ST9")
					cQuery += " SET T9_PROPRIE = '1',"
					cQuery += " 	T9_LUBRIFI = '1'
					cQuery += " WHERE D_E_L_E_T_ <> " + ValToSql("*")
					cQuery += "   AND T9_PROPRIE = ' ' "
					cQuery += "   AND T9_LUBRIFI = ' ' "
					TCSqlExec( cQuery )

					//Inicializa o campo TTA_ORIGEM
					cQuery := " UPDATE " + RetSQLName("TTA")
					cQuery += " SET TTA_ORIGEM = 'MNTA656'"
					cQuery += "	WHERE D_E_L_E_T_ <> " + ValToSql("*")
					cQuery += "		AND TTA_ORIGEM = ' ' "
					TCSqlExec( cQuery )

					//-------------------------------------------------------------------
					// [Fim] Inicialização dos campos criados no Construção Civil
					//-------------------------------------------------------------------
				EndIf

				If NGCADICBASE('T6_CATBEM','A','ST6',.F.) .And. lFrota
					// Novo campo de local de estoque no cadastro de pneus
					If TcGetDb() == "ORACLE"
						fUpdateST9()
					Else
						cQuery := " UPDATE ST9"
						cQuery += "    SET ST9.T9_LOCPAD = TQZ.TQZ_ALMOX "
						cQuery += "   FROM " + RetSqlName( "ST9" ) + " ST9 "
						cQuery += "  INNER JOIN " + RetSqlName( "TQZ" ) + " TQZ "
						cQuery += "     ON ST9.T9_FILIAL  = TQZ.TQZ_FILIAL "
						cQuery += "    AND ST9.T9_CODBEM  = TQZ.TQZ_CODBEM "
						cQuery += "  WHERE ST9.D_E_L_E_T_ <> " + ValToSql( "*" )
						cQuery += "    AND TQZ.D_E_L_E_T_ <> " + ValToSql( "*" )
						cQuery += "    AND TQZ.R_E_C_N_O_ = ( SELECT MAX(TQZ2.R_E_C_N_O_) "
						cQuery += "                             FROM " + RetSqlName( "TQZ" ) + " TQZ2 "
						cQuery += "                            WHERE TQZ2.TQZ_FILIAL = TQZ.TQZ_FILIAL "
						cQuery += "                              AND TQZ2.TQZ_CODBEM = TQZ.TQZ_CODBEM "
						cQuery += "                              AND TQZ2.D_E_L_E_T_ <> "+ ValToSql("*") +" ) "
						TcSqlExec( cQuery )
					EndIf
				EndIf
			EndIf

			// Release 12.1.16 ou maior
			If cRelStart < '016' .And. cRelFinish >= '016' .And. NGCADICBASE("TPE_SITUAC","A","TPE",.F.)
				// Nova opção do campo Tipo Usuário (TPE_SITUAC)
				cQuery := " UPDATE " + RetSQLName("TPE")
				cQuery += "    SET TPE_SITUAC  = '1' "
				cQuery += "  WHERE D_E_L_E_T_ <> " + ValToSql("*")
				cQuery += "    AND TPE_SITUAC  = ' ' "
				TcSqlExec( cQuery )
			EndIf

			// Release 017 ou maior
			If cRelStart < '017' .And. cRelFinish >= '017' .And. NGCADICBASE("TT8_TIPO","A","TT8",.F.)
				// Nova opção do campo Tipo Combustivel (TT8_TIPO)
				cUpdate := " UPDATE " + RetSQLName("TT8")
				cUpdate += " SET TT8_TIPO = '1' "
				cUpdate += " WHERE "
				cUpdate += " D_E_L_E_T_ <> " + ValToSql("*")
				cUpdate += " AND TT8_TIPO = '" + Space( TAMSX3( 'TT8_TIPO' )[ 1 ] ) + "'"
				TcSqlExec(cUpdate)
			EndIf

			If cRelStart < '023' .And. cRelFinish >= '023'

				// Para deletar relação (SX9) que gerava erro
				aAdd( aRegDelSX9, { 'TAF', 'TJL', 'TAF_CODEST', 'TJL_CODEST' } )
				aAdd( aRegDelSX9, { 'TQM', 'TQQ', 'TQM_CODCOM', 'TQQ_HODOM'  } )

				// Deletando gatilho (SX7) que agora é feito por valid
				dbSelectArea("SX7")
				dbSetOrder(1)
				If dbSeek( 'T9_FORNECE' )
					While SX7->( !EoF() ) .And. SX7->X7_CAMPO == 'T9_FORNECE'
						If AllTrim( SX7->X7_REGRA ) == "SA2->A2_LOJA" .And. SX7->X7_SEQUENC == "001"
							Reclock( "SX7", .F. )
								dbDelete()
							SX7->( MsUnLock() )
						EndIf
						SX7->( dbSkip() )
					EndDo
				EndIf

				// Exclui gatilho TTF_HORA, pois foi incluído erroneamente.
				dbSelectArea("SX7")
				dbSetOrder(1)
				If dbSeek('TTF_HORA') .And. SX7->X7_SEQUENC == "001"
					Reclock( "SX7", .F. )
					dbDelete()
					SX7->( MsUnLock() )
				EndIf

				If Posicione("SX3",2,"TQQ_OBSERV","X3_TIPO") == "M"
					fAjsMmReal("TQQ") // Abastecimentos Rejeitados
				EndIf

				If Posicione("SX3",2,"TR6_OBSERV","X3_TIPO") == "M"
					fAjsMmReal("TR6") // Abastecimentos Importados
				EndIf

				If Posicione("SX3",2,"TUI_OBSERV","X3_CONTEXT") == "R"
					fAjsMmReal("TUI") // Transferência de Combustível
				EndIf

			EndIf

			If cRelStart < '037' .And. cRelFinish >= '037'

				// Relacionamento excluido já que estava gerando inconsistência durante a exclusão de uma medição de tanque
				aAdd( aRegDelSX9, { 'TQK', 'TQF', 'TQK_POSTO+TQK_LOJA', 'TQF_CODIGO+TQF_LOJA' } )
				
			EndIf

			/*---------------------------+
			| Release 12.1.2310 ou maior |
			+---------------------------*/
			If cRelStart < '2310' .And. cRelFinish >= '2310'
				
				aAdd( aRegDelSX9, { 'TRX', 'TSI', 'TRX_MULTA', 'TSI_MULTA' } )

			EndIf

			/*----------------------------------+
			| Preenchimento do campo TT9_CARACT |
			+----------------------------------*/
			If NGCADICBASE( 'TT9_CARACT', 'A', 'TT9', .F. )

				cQuery := "UPDATE "
				cQuery += 	RetSQLName( 'TT9' ) + " "
				cQuery += "SET "
				cQuery += 	"TT9_CARACT = '4' "
				cQuery += "WHERE "
				cQuery += 	"TT9_CARACT = ' ' AND "
				cQuery += 	"D_E_L_E_T_ = ' ' "

				TcSqlExec( cQuery )

			EndIf

			//-------------------------------------------------------------------
			// Corrige o Campo TRX_DTENRE DA Tabela TRX
			//-------------------------------------------------------------------
			dbSelectArea("SX3")
			dbSetOrder(2)
			If dbSeek("TRX_DTENRE")
				SX3->(RecLock('SX3', .F.))
				SX3->X3_CBOX    := ''
				SX3->X3_CBOXSPA := ''
				SX3->X3_CBOXENG := ''
				SX3->(MsUnLock())
			EndIf

			//-------------------------------------------------------------------
			//Realiza exclusão forçada de relacionamentos com problema no AtuSX.
			//-------------------------------------------------------------------
			fDeleteSX9( aRegDelSX9 )

			If cRelFinish >= '025'

				If Posicione("SX3",2,"TQB_CCUSTO","X3_VISUAL") == "V"
					dbSelectArea("SX3")
					dbSetOrder(2)
					If dbSeek('TQB_CCUSTO')
						RecLock("SX3",.F.)
						SX3->X3_VISUAL := 'A'
						MsUnLock()
					Endif
				EndIf

				If Posicione("SX3",2,"TS3_DESCR","X3_CONTEXT") == "R"
					fAjsMmReal("TS3") // Veículos Penhorados
				EndIf

				If Posicione("SX3",2,"TSV_OBSERV","X3_CONTEXT") == "R"
					fAjsMmReal("TSV") // Bem X Serviço X Fornecedor
				EndIf

				If Posicione("SX3",2,"TSX_OBSERV","X3_CONTEXT") == "R"
					fAjsMmReal("TSX") // Solicitantes Serviço Cartório
				EndIf

			EndIf

			//-------------------------------------------------------------------
			//Preenche os campos de tipo modelo, em padrões, com o valor * quando vazios.
			//-------------------------------------------------------------------
			If !lFrota .And. (cRelStart < '033' .And. cRelFinish >= '033')
				fIncTipMod()
			EndIf

		EndIf

	#ENDIF

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} fDeleteSX9
Realiza exclusão forçada de uma lista pré-determinada de relacionamentos.

@param aRegDelSX9 - Onde: [1] Domínio (X9_DOM)
							 [2] Contra-Domínio (X9_CDOM)
							 [3] Expressão Domínio (X9_EXPDOM)
							 [4] Expressão Contra-Domínio (X9_EXPCDOM)

@sample fDeleteSX9( aRegDelSX9 )

@obs A remoção forçada é realizada quando um relacionamento incorreto é removido
do AtuSX pela equipe do Framework (esse pedido é feito por e-mail indicando qual
o relacionamento a ser excluído). Esse tipo de remoção é necessário pois o núcleo
do UPDDISTR não deleta informações já existentes, então temos que fazer isso
manualmente. Ex:

- Até o release 12.1.4 o relacionamento entre as tabelas TT9 x STM existia. No
release 12.1.5 do AtuSX solicitamos a exclusão deste relacionamento por estar
incorreto. Caso alguém resolva migrar do release 12.1.4 para 12.1.7 (atual),
ele ainda terá o relacionamento no dicionário pois embora o relacionamento não
exista mais, o UPDDISTR não o removeu.

@author Pedro Henrique Soares de Souza
@since 03/11/2015
/*/
//------------------------------------------------------------------------------
Static Function fDeleteSX9( aRegDelSX9 )

	Local aAreaOld := GetArea()
	Local nSX9		 := 0

	If Len(aRegDelSX9) > 0

		dbSelectArea("SX9")
		dbSetOrder(1)

		For nSX9 := 1 To Len(aRegDelSX9)

			If dbSeek( aRegDelSX9[nSX9, 1] )

				While SX9->( !EoF() ) .And. AllTrim( SX9->X9_DOM ) == aRegDelSX9[nSX9, 1]

					If AllTrim( SX9->X9_CDOM ) == aRegDelSX9[nSX9, 2] .And.;
						AllTrim( SX9->X9_EXPDOM ) == aRegDelSX9[nSX9, 3] .And.;
						AllTrim( SX9->X9_EXPCDOM ) == aRegDelSX9[nSX9, 4]

						SX9->( RecLock('SX9', .F.) )
						SX9->( dbDelete() )
						SX9->( MsUnLock() )

					EndIf

					SX9->( dbSkip() )
				EndDo

			EndIf

		Next nSX9

	EndIf

	RestArea( aAreaOld )

Return Nil
//------------------------------------------------------------------------------
/*/{Protheus.doc} fUpdateST9
Realiza UPDATE com InnerJoin na ST9 em bancos Oracle.

Devido a dificuldade de fazer esse tipo de execução, foi alterada a lógica
para procurar o RECNO da ST9 que deve ser alterado, bem como o TQZ_ALMOX que
irá substitui o T9_LOCPAD.

Dessa forma a tabela temporaria (cAliasQry) será percorrida utilizando o RECNO para
pesquisar o registro na ST9 e utilizando o ALMOX para dar update na mesma.

@sample fDeleteSX9( aRegDelSX9 )
@author Maicon André Pinheiro
@since 28/11/2016
/*/
//------------------------------------------------------------------------------
Static Function fUpdateST9()

	Local cQuery    := ""
	Local cAliasQry := GetNextAlias()
	Local aAreaQRY  := {}

	cQuery := "SELECT ST9.R_E_C_N_O_ AS RECNO, TQZ.TQZ_ALMOX AS ALMOX "
	cQuery += "  FROM " + RetSqlName( "ST9" ) + " ST9, " + RetSqlName( "TQZ" ) + " TQZ "
	cQuery += " WHERE ST9.T9_FILIAL  = TQZ.TQZ_FILIAL "
	cQuery += "   AND ST9.T9_CODBEM  = TQZ.TQZ_CODBEM "
	cQuery += "   AND ST9.T9_LOCPAD <> TQZ.TQZ_ALMOX "
	cQuery += "   AND ST9.D_E_L_E_T_ <> " + ValToSql( "*" )
	cQuery += "   AND TQZ.D_E_L_E_T_ <> " + ValToSql( "*" )
	cQuery += "   AND TQZ.R_E_C_N_O_ = (SELECT MAX(TQZ2.R_E_C_N_O_) "
	cQuery += "                           FROM " + RetSqlName( "TQZ" ) + " TQZ2 "
	cQuery += "                           WHERE TQZ2.TQZ_FILIAL = TQZ.TQZ_FILIAL "
	cQuery += "                           AND TQZ2.TQZ_CODBEM = TQZ.TQZ_CODBEM "
	cQuery += "                           AND TQZ2.D_E_L_E_T_ <> " + ValToSql( "*" ) + ")"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	While !EoF()

		aAreaQRY := (cAliasQry)->(GetArea())

		dbSelectArea("ST9")
		dbGoTo((cAliasQry)->RECNO)
		RecLock("ST9",.F.)
		ST9->T9_LOCPAD := (cAliasQry)->ALMOX
		MsUnLock()

		RestArea(aAreaQRY)
		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(dbCloseArea())

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} fAjsMmReal
Realiza o Ajuste dos campos MEMO após os mesmos se tornarem real, buscando a descrição na
SYP com base no campo de Código (XXX_CODOBS) e gravando no campo MEMO (XXX_OBSERV)

@author Maicon André Pinheiro
@param  cTabela, C, tabela a ser atualizada
@since  28/11/2016
/*/
//------------------------------------------------------------------------------
Static Function fAjsMmReal(cTabela)

	Local cAliasQry := GetNextAlias()
	Local aAreaOld  := GetArea()

	If cTabela == "TQQ"

		// Busca os registros que possuem valor no campo memo.
		BeginSql Alias cAliasQry
			SELECT TQQ.R_E_C_N_O_, SYP.YP_TEXTO AS MEMO
			FROM %Table:TQQ% TQQ
				INNER JOIN %Table:SYP% SYP ON TQQ.TQQ_CODOBS = SYP.YP_CHAVE
				WHERE TQQ.TQQ_CODOBS != '' AND TQQ.%NotDel%
				ORDER BY TQQ.TQQ_CODOBS
		EndSql

		dbSelectArea(cAliasQry)
		dbGoTop()
		While (cAliasQry)->(!Eof())

			dbSelectArea("TQQ")
			dbGoTo((cAliasQry)->R_E_C_N_O_)
			RecLock("TQQ",.F.)
			If !Empty(TQQ->TQQ_CODOBS)
				TQQ->TQQ_CODOBS  := ""
			EndIf
			TQQ->TQQ_OBSERV += RTrim((cAliasQry)->MEMO)
			MsUnLock()

			(cAliasQry)->(dbSkip())
		End

		(cAliasQry)->(dbCloseArea())

	ElseIf cTabela == "TR6"

		// Busca os registros que possuem valor no campo memo.
		BeginSql Alias cAliasQry
			SELECT TR6.R_E_C_N_O_, SYP.YP_TEXTO AS MEMO
			FROM %Table:TR6% TR6
				INNER JOIN %Table:SYP% SYP ON TR6.TR6_CODOBS = SYP.YP_CHAVE
				WHERE TR6.TR6_CODOBS != '' AND TR6.%NotDel%
				ORDER BY TR6.TR6_CODOBS
		EndSql

		dbSelectArea(cAliasQry)
		dbGoTop()
		While (cAliasQry)->(!Eof())

			dbSelectArea("TR6")
			dbGoTo((cAliasQry)->R_E_C_N_O_)
			RecLock("TR6",.F.)
			If !Empty(TR6->TR6_CODOBS)
				TR6->TR6_CODOBS  := ""
			EndIf
			TR6->TR6_OBSERV += RTrim((cAliasQry)->MEMO)
			MsUnLock()

			(cAliasQry)->(dbSkip())
		End

		(cAliasQry)->(dbCloseArea())

	ElseIf cTabela == "TUI"

		// Busca os registros que possuem valor no campo memo.
		BeginSql Alias cAliasQry
			SELECT TUI.R_E_C_N_O_, SYP.YP_TEXTO AS MEMO
			FROM %Table:TUI% TUI
				INNER JOIN %Table:SYP% SYP ON TUI.TUI_CODOBS = SYP.YP_CHAVE
				WHERE TUI.TUI_CODOBS != '' AND TUI.%NotDel%
				ORDER BY TUI.TUI_CODOBS
		EndSql

		dbSelectArea(cAliasQry)
		dbGoTop()
		While (cAliasQry)->(!Eof())

			dbSelectArea("TUI")
			dbGoTo((cAliasQry)->R_E_C_N_O_)
			RecLock("TUI",.F.)
			If !Empty(TUI->TUI_CODOBS)
				TUI->TUI_CODOBS  := ""
			EndIf
			TUI->TUI_OBSERV += RTrim((cAliasQry)->MEMO)
			MsUnLock()

			(cAliasQry)->(dbSkip())
		End

		(cAliasQry)->(dbCloseArea())

	ElseIf cTabela == "TS3"
		// Busca os registros que possuem valor no campo memo.
		BeginSql Alias cAliasQry
			SELECT TS3.R_E_C_N_O_, SYP.YP_TEXTO AS MEMO
			FROM %Table:TS3% TS3
				INNER JOIN %Table:SYP% SYP ON TS3.TS3_CDDESC = SYP.YP_CHAVE
				WHERE TS3.TS3_CDDESC != '' AND TS3.%NotDel%
				ORDER BY TS3.TS3_CDDESC
		EndSql

		dbSelectArea(cAliasQry)
		dbGoTop()
		While (cAliasQry)->(!Eof())

			dbSelectArea("TS3")
			dbGoTo((cAliasQry)->R_E_C_N_O_)
			RecLock("TS3",.F.)
			If !Empty(TS3->TS3_CDDESC)
				TS3->TS3_CDDESC  := ""
			EndIf
			TS3->TS3_DESCR += RTrim((cAliasQry)->MEMO)
			MsUnLock()

			(cAliasQry)->(dbSkip())
		End

		(cAliasQry)->(dbCloseArea())

	ElseIf cTabela == "TSV"
		// Busca os registros que possuem valor no campo memo.
		BeginSql Alias cAliasQry
			SELECT TSV.R_E_C_N_O_, SYP.YP_TEXTO AS MEMO
			FROM %Table:TSV% TSV
				INNER JOIN %Table:SYP% SYP ON TSV.TSV_MMOBS = SYP.YP_CHAVE
				WHERE TSV.TSV_MMOBS != '' AND TSV.%NotDel%
				ORDER BY TSV.TSV_MMOBS
		EndSql

		dbSelectArea(cAliasQry)
		dbGoTop()
		While (cAliasQry)->(!Eof())

			dbSelectArea("TSV")
			dbGoTo((cAliasQry)->R_E_C_N_O_)
			RecLock("TSV",.F.)
			If !Empty(TSV->TSV_MMOBS)
				TSV->TSV_MMOBS  := ""
			EndIf
			TSV->TSV_OBSERV += RTrim((cAliasQry)->MEMO)
			MsUnLock()

			(cAliasQry)->(dbSkip())
		End

		(cAliasQry)->(dbCloseArea())

	ElseIf cTabela == "TSX"
		// Busca os registros que possuem valor no campo memo.
		BeginSql Alias cAliasQry
			SELECT TSX.R_E_C_N_O_, SYP.YP_TEXTO AS MEMO
			FROM %Table:TSX% TSX
				INNER JOIN %Table:SYP% SYP ON TSX.TSX_MMOBS = SYP.YP_CHAVE
				WHERE TSX.TSX_MMOBS != '' AND TSX.%NotDel%
				ORDER BY TSX.TSX_MMOBS
		EndSql

		dbSelectArea(cAliasQry)
		dbGoTop()
		While (cAliasQry)->(!Eof())

			dbSelectArea("TSX")
			dbGoTo((cAliasQry)->R_E_C_N_O_)
			RecLock("TSX",.F.)
			If !Empty(TSX->TSX_MMOBS)
				TSX->TSX_MMOBS  := ""
			EndIf
			TSX->TSX_OBSERV += RTrim((cAliasQry)->MEMO)
			MsUnLock()

			(cAliasQry)->(dbSkip())
		End

	EndIf

	RestArea( aAreaOld )

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} fIncTipMod
Efetua a carga dos campos Tipo Modelo vazios com o conteúdo * nas tabelas
onde o campo XXX_TIPMOD passa a ser obrigatório para rotinas Padrão
(Bens Padrão, Manutenção Padrão, etc.).

@sample fIncTipMod()

@author Wexlei Silveira
@since 23/04/2020
/*/
//------------------------------------------------------------------------------
Static Function fIncTipMod()

	Local nX        := 0
	Local aTable    := { 'TP2', 'TP5', 'TP9', 'TPB', 'TPF', 'TPG', 'TPH', 'TPK', 'TPM', 'TQ0', 'TQ1', 'TTD', 'TTE' }
	Local cQuery    := ''
	Local cAliasTQR := GetNextAlias()
	Local lNoModel  := .F.

	BeginSQL Alias cAliasTQR

		SELECT COUNT( TQR_FILIAL ) nModelo
			FROM %Table:TQR%
		WHERE   TQR_TIPMOD = %exp:Padr( '*', TAMSX3( 'TQR_TIPMOD' )[ 1 ] )%
			AND %NotDel%

	EndSQL

	// Caso encontre algum modelo cadastrado como * não altera nenhum registro das tabelas de padrão
	lNoModel := (cAliasTQR)->nModelo == 0

	// Realiza fechamento da query para que caso haja uma queda no meio
	// do processo de update a tabela temporária seja excluida
	(cAliasTQR)->( dbCloseArea() )

	If lNoModel

		For nX := 1 To Len( aTable )

			cQuery := " UPDATE "
			cQuery += RetSqlName( aTable[ nX ] )
			cQuery += "    SET " + aTable[ nX ] + '_TIPMOD' + " = '*'"
			cQuery += "  WHERE " + aTable[ nX ] + '_TIPMOD' + " = ' '"
			cQuery += "    AND D_E_L_E_T_ = ' '"

			TcSqlExec( cQuery )

		Next nX

		// Executa carga do campo modelo fora do For para evitar adicionar um If dentro do laço
		cQuery := " UPDATE "
		cQuery += RetSqlName( 'STC' )
		cQuery += "    SET TC_TIPMOD  = '*'"
		cQuery += "  WHERE TC_TIPMOD  = ' '"
		cQuery += "    AND TC_TIPOEST = 'F'"
		cQuery += "    AND D_E_L_E_T_ = ' '"

		TcSqlExec( cQuery )

	EndIf

Return
