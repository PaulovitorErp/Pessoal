#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} RUP_MDT
Função exemplo de compatibilização do release incremental. Esta função é relativa ao módulo Medicina e Segurança do Trabalho.
Serão chamadas todas as funções compiladas referentes aos módulos cadastrados do Protheus
Será sempre considerado prefixo "RUP_" acrescido do nome padrão do módulo sem o prefixo SIGA.
Ex: para o módulo SIGAMDT criar a função RUP_MDT

@param  cVersion 	Caracter Versão do Protheus
@param  cMode 		Caracter Modo de execução. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart 	Caracter Release de partida Ex: 002
@param  cRelFinish 	Caracter Release de chegada Ex: 005
@param  cLocaliz 	Caracter Localização (país) Ex: BRA

@Author Jean Pytter da Costa
@since 03/03/2016
@version P12.1.7
/*/
//-------------------------------------------------------------------
Function RUP_MDT( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )

	Local cDurMin	 := MTOH( 5 ) //Duração mínima de consulta
	Local cHrConsNew := "" 	//Novo horario da consulta
	Local lAchou  	 := .F.	//Se achou um novo horário válido
	Local cHrFimAnt	 := ""

	Local aCampos	 := {}
	Local nMemo		 := 0
	Local cGetDB 	 := TcGetDb() //Traz a base de dados
	Local lMdTMY	 := FWModeAccess("TMY") == "E"

	//Variáveis de alias genérico para atualização
	Local cGenAls := GetNextAlias()

	//Variaveis para alteração SOYUZ Atestado Médico
	Local aCont   := {}
	Local nSaid   := 0
	Local nPosCam := 0
	Local nQtdDia := 0
	Local nX 	  := 0
	Local nY      := 0
	Local cMat    := ""
	Local dDtSeek := SToD( "" )

	//Definições de Banco de Dados
	Local _cGetDB  := TcGetDb()
	Local cIsNull  := ""
	Local cBgNull  := ""
	Local cQuery   := ""
	Local cQryTM0  := ""

	Local cSeq      := ''		// Numero da Sequência da SR8.
	Local dDtaSaida := cTod('') // Data Saida para Afastamento.
	Local dDtaAlta  := cTod('') // Data Fim do Afastamento.
	Local cTipo     := ''
	Local lRodRUP	:= .T. //Verifica se roda o RUP

	Private  cHorasTMJ := GetNextAlias()

	If Upper( _cGetDB ) == "ORACLE" .Or. Upper( _cGetDB ) == "INFORMIX"
		cIsNull := "NVL"
	ElseIf "DB2" $ Upper( _cGetDB ) .Or. Upper( _cGetDB ) == "POSTGRES"
		cIsNull := "COALESCE"
	ElseIf Upper( _cGetDB ) == "OPENEDGE"
		cIsNull := "IFNULL"
		lRodRUP := .F. //Caso for OpenEdge/Progress não executa o RUP pois o Protheus não está homologado para o banco
	Else
		cIsNull := "ISNULL"
	EndIf
	cBgNull := "%" + cIsNull + "%"

	If lRodRUP
		//Trativa para quando executado ambiente TOTVS PDV
		#IFDEF TOP
		//-- Regra geral : só executar atualização quando release de partida diferente do release de chegada
		//If cRelStart <> cRelFinish
		If ( cVersion == "12" ) // Executa somente para versão 7

			//Alterações definidas para o Release 007 ou superiores
			If cRelFinish >= "007" .And. cRelStart <= "007"
				If cMode == "1" //Executa para cada Grupo de Empresa
					//+---------------------------------------------------------------------------+
					//| [Início] Inicialização da tabela de Usuários                              |
					//+---------------------------------------------------------------------------+
					// Alteração de novo campo de Responsável criado na TMK, valor '1'
					cQuery := " UPDATE " + RetSqlName( "TMK" ) + " SET TMK_RESAMB = '1' WHERE TMK_INDFUN = '4' AND TMK_RESAMB = '' AND D_E_L_E_T_ <> '*' "
					TcSqlExec( cQuery )

					// Alteração de novo campo de Responsável criado na TMK, valor '2' (Nao)
					cQuery := " UPDATE " + RetSqlName( "TMK" ) + " SET TMK_RESAMB = '2' WHERE TMK_INDFUN <> '4' AND TMK_RESAMB = '' AND D_E_L_E_T_ <> '*' "
					TcSqlExec( cQuery )

					//+---------------------------------------------------------------------------+
					//| [Fim] Inicialização da tabela de Usuários                                 |
					//+---------------------------------------------------------------------------+

					//+---------------------------------------------------------------------------+
					//| [Inicio] Repasse atualizações NGUPDATE                                    |
					//+---------------------------------------------------------------------------+
					fValueDef("TLI", "TLI_INDRES", "3")
					fValueDef("TMV", "TMV_TIPODT", "2")
					fValueDef("TO0", "TO0_TIPREL", "1")
					fValueDef("TNY", "TNY_OCORRE", "1")
					fValueDef("TLX", "TLX_INDCLA", "1")
					fValueDef("TLX", "TLX_TIPOSA", "1")
					fValueDef("TN3", "TN3_TPDURA", "G")
					fValueDef("TMH", "TMH_TPLIST", "1")
					fValueDef("TMH", "TMH_ONMEMO", "2")
					fValueDef("TL6", "TL6_SEXO", "3")
					fValueDef("TL6", "TL6_CC", "2")
					fValueDef("TL6", "TL6_FUNC", "2")
					fValueDef("TL6", "TL6_FNCR", "2")
					fValueDef("TN2", "TN2_TIPOEX", "11")
					fValueDef("TN8", "TN8_TIPOEX", "11")
					fValueDef("TN9", "TN9_TIPOEX", "11")
					fValueDef("TNB", "TNB_COMBO", "1")
					fValueDef("TNS", "TNS_TIPPAR", "1")
					fValueDef("TNI", "TNI_TIPOPL", "3")
					fValueDef("TLB", "TLB_CATEGO", "1")
					fValueDef("TLC", "TLC_CATEGO", "1")
					fValueDef("TLD", "TLD_CATEGO", "1")
					fValueDef("TLD", "TLD_RECEBI", "1", "TLD_RECEBI = '' AND TLD_SITUAC = '2'")
					fValueDef("TLD", "TLD_RECEBI", "2", "TLD_RECEBI = '' AND TLD_SITUAC = '1'")
					fValueDef("TNC", "TNC_INDLOC", "9", "TNC_INDLOC = '5'")
					fValueDef("TTD", "TTD_SEQFAM", "001")
					fValueDef("TTE", "TTE_SEQFAM", "001")
					fValueDef("TZ5", "TZ5_ATIVO", "1")

					cQuery := "UPDATE "
					cQuery += RetSqlName("TM0")+" "
					cQuery +="SET TM0_TIPDEF = "+cIsNull+"((SELECT RA_TPDEFFI FROM "+ RetSqlName('SRA') +" WHERE RA_MAT = TM0_MAT ),0) "
					cQuery +="WHERE TM0_TIPDEF = ' ' "
					TcSqlExec( cQuery )

					// ALTERAÇÕES POR CODEBASE - Não há como alterar os trechos abaixo devido a complexidade de atribuições
					If AliasInDic("TJF")
						If NGCADICBASE("TJF_NUMRIS","B","TJF",.F.) .And. NGCADICBASE("TN0_MEDCON","B","TN0",.F.)
							BeginSQL Alias cGenAls
								SELECT TN0.TN0_FILIAL, TN0.TN0_NUMRIS, TN0.TN0_MEDCON FROM %table:TN0% TN0
									WHERE TN0.TN0_MEDCON <> ' ' AND TN0.%notDel%
							EndSQL
							While ( cGenAls )->( !Eof() )
								dbSelectArea("TJF")
								dbSetOrder(1)
								If !dbSeek(xFilial("TJF",( cGenAls )->TN0_FILIAL)+( cGenAls )->TN0_NUMRIS+( cGenAls )->TN0_MEDCON)
									RecLock("TJF", .T.)
									TJF->TJF_FILIAL := xFilial("TJF",( cGenAls )->TN0_FILIAL)
									TJF->TJF_NUMRIS := ( cGenAls )->TN0_NUMRIS
									TJF->TJF_MEDCON := ( cGenAls )->TN0_MEDCON
									TJF->(MsUnlock())
								EndIf

								dbSelectArea("TN0")
								dbSetOrder( 1 )
								If dbSeek( ( cGenAls )->TN0_FILIAL + ( cGenAls )->TN0_NUMRIS )
									RecLock("TN0", .F.)
									TN0->TN0_MEDCON := ""
									TN0->(MsUnlock())
								EndIf
								( cGenAls )->( dbSkip() )
							End
							( cGenAls )->( dbCloseArea() )
						EndIf
					EndIf
					DbselectArea("TOK")
					If NGCADICBASE("TOK_GRUPO","A","TOK",.F.) .And. ;
						TOK->(RecCount()) == 0 .And. FindFunction("MDTAliTOK")
						MDTAliTOK()
					EndIf

					//+------------+
					//| TN5_DESCRI |
					//+------------+
					If NGCADICBASE("TN5_DESCRI","B","TN5",.F.)
						BeginSQL Alias cGenAls
							SELECT TN5.TN5_FILIAL, TN5.TN5_CODTAR
								FROM %table:TN5% TN5
								WHERE ( TN5.TN5_DESTAR <> '' OR
										TN5.TN5_DESCR1 <> '' OR
										TN5.TN5_DESCR2 <> '' OR
										TN5.TN5_DESCR3 <> '' OR
										TN5.TN5_DESCR4 <> '' ) AND
										TN5.TN5_DESCRI IS NULL AND
										TN5.%notDel%

						EndSQL
						//Pega os valores do campo antigo e grava no campo memo.
						While ( cGenAls )->( !EoF() )
							dbSelectArea( "TN5" )
							dbSetOrder( 1 )
							If dbSeek( ( cGenAls )->TN5_FILIAL + ( cGenAls )->TN5_CODTAR )
								RecLock( "TN5" , .F. )
								TN5->TN5_DESCRI = AllTrim(TN5->TN5_DESTAR) + ' ' + AllTrim(TN5->TN5_DESCR1) + ' ' + AllTrim(TN5->TN5_DESCR2) + ' ' + AllTrim(TN5->TN5_DESCR3) + ' ' + AllTrim(TN5->TN5_DESCR4)
								TN5->( MsUnLock() )
							EndIf
							( cGenAls )->( dbSkip() )
						End
						( cGenAls )->( dbCloseArea() )
					EndIf
					//+---------------------------------------------------------------------------+
					//| [Fim] Repasse atualizações NGUPDATE                                       |
					//+---------------------------------------------------------------------------+

				ElseIf cMode == "2" //Executa para cada Grupo de Empresa + Filial em separado
					//+-------------------------------------------------------------------------------+
					//| [Início] Inicialização da tabela de medicamentos do atendimento de Enfermagem |
					//+-------------------------------------------------------------------------------+
					BeginSQL Alias cGenAls
						SELECT TL5.TL5_FILIAL, TL5.TL5_NUMFIC, TL5.TL5_DTATEN, TL5.TL5_HRATEN,
								TL5.TL5_INDICA, TL5.TL5_CODMED
							FROM %table:TL5% TL5
							WHERE ( TL5.TL5_CODMED <> ' ' OR TL5_OBSERV <> ' ' ) AND
									TL5.TL5_FILIAL = %xFilial:TL5% AND
									TL5.%notDel%
					EndSQL
					//Pega os valores do campo antigo e grava no campo memo.
					While ( cGenAls )->( !EoF() )
						dbSelectArea( "TL5" )
						dbSetOrder( 1 )
						dbSeek( ( cGenAls )->TL5_FILIAL + ( cGenAls )->TL5_NUMFIC + ( cGenAls )->TL5_DTATEN + ( cGenAls )->TL5_HRATEN + ( cGenAls )->TL5_INDICA + ( cGenAls )->TL5_CODMED )
						If !Empty( TL5->TL5_OBSERV ) .And. Empty( TL5->TL5_OBSSYP )
							RecLock( "TL5", .F. )
							MSMM(,TAMSX3("TL5_OBSERV")[1],,TL5->TL5_OBSERV,1,,050,"TL5","TL5_OBSSYP")
							TL5->( MsUnLock() )
						EndIf
						If !Empty( TL5->TL5_CODMED )
							dbSelectArea( "TY3" )
							dbSetOrder( 1 )
							If dbSeek( xFilial( "TY3", TL5->TL5_FILIAL ) + TL5->TL5_NUMFIC + DtoS( TL5->TL5_DTATEN ) + TL5->TL5_HRATEN + TL5->TL5_INDICA + TL5->TL5_CODMED )
								RecLock( "TY3", .T. )
								TY3->TY3_FILIAL	:= xFilial( "TY3", TL5->TL5_FILIAL )
								TY3->TY3_NUMFIC	:= TL5->TL5_NUMFIC
								TY3->TY3_DTATEN	:= TL5->TL5_DTATEN
								TY3->TY3_HRATEN	:= TL5->TL5_HRATEN
								TY3->TY3_INDICA	:= TL5->TL5_INDICA
								TY3->TY3_CODMED	:= TL5->TL5_CODMED
								TY3->TY3_QUANT 	:= TL5->TL5_QTDADE
								TY3->( MsUnLock() )
							EndIf
						EndIf
						( cGenAls )->( dbSkip() )
					End
					( cGenAls )->( dbCloseArea() )
					//+----------------------------------------------------------------------------+
					//| [Fim] Inicialização da tabela de medicamentos do atendimento de Enfermagem |
					//+----------------------------------------------------------------------------+

					//+---------------------------------------------------------------------------+
					//| [Início] Inicialização da tabela de Atestado (ASO)                        |
					//+---------------------------------------------------------------------------+
					BeginSQL Alias cGenAls
						SELECT TMY.TMY_FILIAL, TMY.TMY_NUMASO, TMY.TMY_NUMFIC
							FROM %table:TMY% TMY
							WHERE TMY.TMY_NATEXA = '3' AND
									TMY.TMY_FILIAL = %xFilial:TMY% AND
									TMY.%notDel%
					EndSQL
					While ( cGenAls )->( !Eof() )
						//Verifica se tabela é exclusiva
						cFilTMY := If( lMdTMY , ( cGenAls )->TMY_FILIAL, Space(8) )

						If Empty( cFilTMY )
							DbSelectArea( "TM0" )
							DbSetOrder(1)
							DbGoTop()
							If dbSeek( xFilial( "TM0" ) + ( cGenAls )->TMY_NUMFIC )
								If Empty( TM0->TM0_CANDID )
									cFilTMY := cFilAnt
								Else
									cFilTMY := TM0->TM0_FILFUN
								EndIf
							EndIf
						EndIf

						dbSelectArea( "TMY" )
						dbSetOrder( 1 )
						dbSeek( ( cGenAls )->TMY_FILIAL + ( cGenAls )->TMY_NUMASO )
						RecLock("TMY",.F.)
						TMY->TMY_EMPFUT := cEmpAnt
						TMY->TMY_FILFUT := cFilTMY
						TMY->(MsUnlock())

						( cGenAls )->( dbSkip()	)
					End
					( cGenAls )->( dbCloseArea() )
					//+---------------------------------------------------------------------------+
					//| [Fim] Inicialização da tabela de Atestado (ASO)                           |
					//+---------------------------------------------------------------------------+
				EndIf
			EndIf

			If cRelFinish >= "013" .And. cRelStart <= "013"

				//+----------------------------------------------------------+
				//|Todos os Riscos receberão "*" no campo de Departamento    |
				//+----------------------------------------------------------+
				fValueDef("TN0", "TN0_DEPTO", "*")

				//+------------------------------------------+
				//| Adiciona a Departamento utilizado na SRA |
				//|  para todas as ficha médicas.            |
				//+------------------------------------------+
				BeginSQL Alias cGenAls
					SELECT TM0.TM0_FILIAL, TM0.TM0_NUMFIC, SRA.RA_DEPTO
						FROM %table:TM0% TM0
						LEFT JOIN %table:SRA% SRA ON
							SRA.RA_FILIAL = TM0.TM0_FILFUN AND SRA.RA_MAT = TM0.TM0_MAT AND SRA.%notDel%
						WHERE TM0.TM0_MAT <> '' AND
								TM0.TM0_DEPTO = '' AND
								TM0.%notDel% AND %exp:cBgNull%(SRA.RA_DEPTO,'') <> ''
				EndSQL
				While ( cGenAls )->( !Eof() )
					dbSelectArea("TM0")
					dbSetOrder( 1 )
					If dbSeek( ( cGenAls )->TM0_FILIAL + ( cGenAls )->TM0_NUMFIC )
						TM0->( RecLock( "TM0" , .F. ) )
						TM0->TM0_DEPTO := ( cGenAls )->RA_DEPTO
						TM0->( MSUnlock() )
					EndIf
					( cGenAls )->( dbSkip() )
				End
				( cGenAls )->( dbCloseArea() )
			EndIf

			If cRelFinish >= "017" .And. cMode == "1"
				//------------------------------
				// Alteração dos registro da TNL
				//------------------------------
				TCSqlExec("UPDATE " + RetSqlName("TNL") + " SET TNL_TIPDES = 'Z' WHERE TNL_TIPDES = '5'")
				TCSqlExec("UPDATE " + RetSqlName("TNL") + " SET TNL_TIPDES = '5' WHERE TNL_TIPDES = '6'")
				TCSqlExec("UPDATE " + RetSqlName("TNL") + " SET TNL_TIPDES = '6' WHERE TNL_TIPDES = '7'")
			EndIf

			//Alterações definidas para o Release 017 ou superiores
			If cRelStart <= "017" .And. cRelFinish >= "017"
				If cMode == "1"
					//----------------------------------------------------------------------------------------------
					// [Início] Atualização da tabela de Acidentes (TNC), passando os valores de Agente Causador
					// e Código da Parte atingida, para tabelas relacionais.
					//---------------------------------------------------------------------------------------------
					If AliasInDic("TYE") .And. AliasInDic("TYF")
						BeginSQL Alias cGenAls
							SELECT TNC.TNC_FILIAL, TNC.TNC_ACIDEN
								FROM %table:TNC% TNC
								WHERE ( TNC.TNC_CODPAR <> '' OR TNC.TNC_CODOBJ <> '' ) AND
										TNC.%notDel%
						EndSQL
						While ( cGenAls )->( !Eof() )
							dbSelectArea( "TNC" )
							dbSetOrder( 1 )
							dbSeek( ( cGenAls )->TNC_FILIAL + ( cGenAls )->TNC_ACIDEN )
							dbSelectArea( "TYF" )
							dbSetOrder(1)
							If !Empty(TNC->TNC_CODPAR) .And. !dbSeek(xFilial("TYF", TNC->TNC_FILIAL) + TNC->TNC_ACIDEN + TNC->TNC_CODPAR )//Código da Parte
								RecLock("TYF",.T.)
								TYF->TYF_FILIAL := xFilial("TYF", TNC->TNC_FILIAL)
								TYF->TYF_ACIDEN := TNC->TNC_ACIDEN
								TYF->TYF_CODPAR := TNC->TNC_CODPAR
								TYF->TYF_LATERA := '3'
								TYF->(MsUnlock())
							EndIf
							dbSelectArea( "TYE" )
							dbSetOrder(1)
							If !Empty(TNC->TNC_CODOBJ) .And. !dbSeek(xFilial("TYE", TNC->TNC_FILIAL) + TNC->TNC_ACIDEN + TNC->TNC_CODOBJ )//Agente Causador
								RecLock("TYE",.T.)
								TYE->TYE_FILIAL := xFilial("TYE", TNC->TNC_FILIAL)
								TYE->TYE_ACIDEN := TNC->TNC_ACIDEN
								TYE->TYE_CAUSA  := TNC->TNC_CODOBJ
								TYE->(MsUnlock())
							EndIf
							( cGenAls )->(dbSkip())
						End
						( cGenAls )->( dbCloseArea() )
					EndIf
					//----------------------------------------------------------------------------------------------
					// [Fim] Atualização da tabela de Acidentes (TNC), passando os valores de Agente Causador
					// e Código da Parte atingida, para tabelas relacionais.
					//---------------------------------------------------------------------------------------------

					//Verificação a existência de informações nos campos antigos da TMT tranferindo
					//as informação para os novos campos memo.

					aCampos	:= { 	{ "TMT_QUEIXA",	"TMT_QUESYP", "TMT_MQUEIX"}, ;
									{"TMT_DESATE",	"TMT_DATSYP", "TMT_MDESAT"}, ;
									{"TMT_DIAGNO",	"TMT_DIASYP", "TMT_MDIAGN"}, ;
									{"TMT_HDA",		"TMT_HDASYP", "TMT_MHDA"}, ;
									{"TMT_HISPRE",	"TMT_HISSYP", "TMT_MHISPR"}, ;
									{"TMT_CABECA",	"TMT_CABSYP", "TMT_MCABEC"}, ;
									{"TMT_OLHOS",	"TMT_OLHSYP", "TMT_MOLHOS"}, ;
									{"TMT_OUVIDO",	"TMT_OUVSYP", "TMT_MOUVID"}, ;
									{"TMT_PESCOC",	"TMT_PESSYP", "TMT_MPESCO"}, ;
									{"TMT_APRESP",	"TMT_APRSYP", "TMT_MAPRES"}, ;
									{"TMT_APDIGE",	"TMT_APDSYP", "TMT_MAPDIG"}, ;
									{"TMT_APCIRC",	"TMT_APCSYP", "TMT_MAPCIR"}, ;
									{"TMT_APURIN",	"TMT_APUSYP", "TMT_MAPURI"}, ;
									{"TMT_MMIISS",	"TMT_MISSYP", "TMT_MMIS"}, ;
									{"TMT_PELE",	"TMT_PELSYP", "TMT_MPELE"}, ;
									{"TMT_EXAMEF",	"TMT_EXFSYP", "TMT_MEXAME"}, ;
									{"TMT_OROFAR",	"TMT_ORFSYP", "TMT_MOROFA"}, ;
									{"TMT_OTOSCO",	"TMT_OTSSYP", "TMT_MOTOSC"}, ;
									{"TMT_ABDOME",	"TMT_ABDSYP", "TMT_MABDOM"}, ;
									{"TMT_AUSCAR",	"TMT_AUCSYP", "TMT_MAUSCA"}, ;
									{"TMT_AUSPUL",	"TMT_AUPSYP", "TMT_MAUSPU"} }

					dbSelectArea( "TMT" )
					dbSetOrder( 1 )
					dbGotop()
					While TMT->( !Eof() )
						For nMemo := 1 To Len( aCampos )
							If !Empty(TMT->&( aCampos[ nMemo , 1 ] )) .And. Empty(TMT->&( aCampos[ nMemo , 2 ] ))

								MSMM(	TMT->( &( aCampos[ nMemo , 2 ] ) )	, TamSx3( aCampos[ nMemo , 3 ] )[ 1 ] , , ;
								TMT->&( aCampos[ nMemo , 1 ] ) , 1 , , , "TMT" , aCampos[ nMemo , 2 ] )

							EndIf
						Next nMemo
						TMT->( dbSkip() )
					EndDo

				ElseIf cMode == "2"

					If AliasInDic( "TYZ" )
						//Alteração projeto SOYUZ na rotina de Atestado Médico.
						BeginSQL Alias cGenAls
							SELECT TNY.TNY_FILIAL, TNY.TNY_NUMFIC, TNY.TNY_DTINIC, TNY.TNY_HRINIC
								FROM %table:TNY% TNY
								WHERE ( TNY.TNY_DTSAID <> '' OR TNY.TNY_DTSAI2 <> '' OR TNY.TNY_DTSAI3 <> '' ) AND
										TNY.TNY_FILIAL = %xFilial:TNY% AND
										TNY.%notDel%
						EndSQL
						While ( cGenAls )->( !Eof() )
							dbSelectArea( "TNY" )
							dbSetOrder( 1 )
							dbSeek( ( cGenAls )->TNY_FILIAL + ( cGenAls )->TNY_NUMFIC + ( cGenAls )->TNY_DTINIC + ( cGenAls )->TNY_HRINIC )
							If Empty(TNY->TNY_ATEANT) //Caso não seja Continuação.
								If !Empty(TNY->TNY_DTSAID) .Or. !Empty(TNY->TNY_DTALTA)
									nSaid := 1
								EndIf
								If !Empty(TNY->TNY_DTSAI2) .Or. !Empty(TNY->TNY_DTALT2)
									nSaid := 2
								EndIf
								If !Empty(TNY->TNY_DTSAI3) .Or. !Empty(TNY->TNY_DTALT3)
									nSaid := 3
								EndIf
								If nSaid > 0
									cMat := Posicione("TM0",1,xFilial("TM0")+TNY->TNY_NUMFIC,"TM0_MAT")
									If !Empty( cMat ) //Somente gera afastamento se não for Candidato
										For nX := 1 To nSaid
											If nX == 1 //Caso tenha preenchido a primeira Saída.
												dDtSeek := TNY->TNY_DTSAID
											ElseIf nX == 2 //Caso tenha preenchido a segunda Saída.
												dDtSeek := TNY->TNY_DTSAI2
											ElseIf nX == 3//Caso tenha preenchido a terceira Saída.
												dDtSeek := TNY->TNY_DTSAI3
											EndIf

											dbSelectArea("SR8")
											dbSetOrder(1)//R8_FILIAL+R8_MAT+DTOS(R8_DATAINI)+R8_TIPO
											If Dbseek(xFilial("SR8")+cMat+DTOS(dDtSeek)+SubSTR(TNY->TNY_TIPAFA,1,2))
												cSeq      := SR8->R8_SEQ 		// Numero da Sequência da SR8.
												dDtaSaida := SR8->R8_DATAINI  // Data Saida para Afastamento.
												dDtaAlta  := SR8->R8_DATAFIM  // Data Fim do Afastamento.
											EndIf

											If !Empty(TNY->TNY_TIPAFA)
												cTipo := TNY->TNY_TIPAFA
											Else
												cTipo := SubStr(Posicione( "RCM", 1 , xFilial("RCM")+TNY->TNY_CODAFA , "RCM_CODSEF" ),1,1)
											EndIf

											If !MDTSeekTYZ(xFilial('TYZ', TNY->TNY_FILIAL),cMat,dDtaSaida,cTipo,TNY->TNY_CODAFA,TNY->TNY_NATEST)
												RecLock( "TYZ" , .T. )
												TYZ->TYZ_FILIAL := xFilial('TYZ', TNY->TNY_FILIAL) //Filial Utilizada.
												TYZ->TYZ_MAT    := cMat  // Matricula do Funcionário.
												TYZ->TYZ_TIPO   := cTipo  // Tipo de Afastamento.
												TYZ->TYZ_NATEST := TNY->TNY_NATEST // Numero de Atestado.
												TYZ->TYZ_TIPOAF := TNY->TNY_CODAFA // Código de Afastamento.
												TYZ->TYZ_SEQ    := cSeq 	   // Numero da Sequência da SR8.
												TYZ->TYZ_DTSAID := dDtaSaida  // Data Saida para Afastamento.
												TYZ->TYZ_DTALTA := dDtaAlta   // Data Fim do Afastamento.
												TYZ->(MsUnLock())
											EndIf
										Next nX
									EndIf
								EndIf
								//Zera valores para próximo registro
								cSeq		:= ''		 // Numero da Sequência da SR8.
								dDtaSaida	:= SToD('') // Data Saida para Afastamento.
								dDtaAlta	:= SToD('') // Data Fim do Afastamento.
								nSaid 		:= 0
								cMat 		:= ""
							Else //Caso seja Continuação.
								cMat := Posicione("TM0",1,xFilial("TM0")+TNY->TNY_NUMFIC,"TM0_MAT") //Busca a Matricula.

								aAdd( aCont , { TNY->TNY_NATEST, TNY->TNY_ATEANT, TNY->TNY_FILIAL, cMat, ;
												If(Empty(TNY->TNY_TIPAFA),SubStr(Posicione( "RCM", 1 , xFilial("RCM")+TNY->TNY_CODAFA , "RCM_CODSEF" ),1,1),TNY->TNY_TIPAFA),;
												TNY->TNY_CODAFA, { TNY->TNY_DTSAID, TNY->TNY_DTSAI2, TNY->TNY_DTSAI3 } } )
								//Deleta o Registro da Tabela.
								RecLock( "TNY" , .F. )
								dbDelete()
								TNY->(MsUnLock())
							EndIf

							( cGenAls )->(dbSkip())
						End
						//Ordena o registro do por numero do atestado.
						aSORT(aCont,,,{|x,y| x[2] < y[2] })
						//Caso tenha alguma continuação de Atestado.
						If Len(aCont) > 0
							For nX := Len(aCont) To 1 Step -1
								nPosCam := aSCAN(aCont,{|x| x[1] == aCont[nX,2]})
								If nPosCam > 0  //Caso encontre alguma outra continuação.
									For nY := 1 To Len(aCont[nX,7])
										aAdd( aCont[nPosCam,7] , aCont[nX,7,nY] )
									Next nY
									//Deleta a continuação do Atestado.
									aDel(aCont,nX)
									aSize(aCont,Len(aCont)-1)
								EndIf
							Next nX
						EndIf
						If Len(aCont) > 0
							For nX := 1 To Len(aCont)
								nQtdDia := 0
								For nY := 1 To Len(aCont[nX,7])
									dbSelectArea("SR8")
									dbSetOrder(1)//R8_FILIAL+R8_MAT+DTOS(R8_DATAINI)+R8_TIPO
									If Dbseek(aCont[nX,3]+aCont[nX,4]+DTOS(aCont[nX,7,nY])+SubSTR(aCont[nX,5],1,2))
										dbSelectArea("TYZ")
										dbSetOrder(1)//TYZ_FILIAL+TYZ_MAT+DTOS(TYZ_DTSAID)+TYZ_TIPO+TYZ_TIPOAF
										If !dbSeek(xFilial("TYZ", aCont[nX,3] )+aCont[nX,4]+DTOS(SR8->R8_DATAINI)+aCont[nX,5]+aCont[nX,6])
											RecLock( "TYZ" , .T. )
											TYZ->TYZ_FILIAL := xFilial("TYZ", aCont[nX,3] ) //Filial Utilizada.
											TYZ->TYZ_MAT    :=  aCont[nX,4] // Matricula do Funcionário.
											TYZ->TYZ_TIPO   :=  aCont[nX,5] // Tipo de Afastamento.
											TYZ->TYZ_NATEST :=  aCont[nX,2] // Numero de Atestado.
											TYZ->TYZ_TIPOAF :=  aCont[nX,6] // Código de Afastamento.
											TYZ->TYZ_SEQ    := SR8->R8_SEQ 	   // Numero da Sequência da SR8.
											TYZ->TYZ_DTSAID := SR8->R8_DATAINI // Data Saida para Afastamento.
											TYZ->TYZ_DTALTA := SR8->R8_DATAFIM // Data Fim do Afastamento.
											TYZ->(MsUnLock())
											nQtdDia += SR8->R8_DATAFIM - SR8->R8_DATAINI
										EndIf
									EndIf
								Next nY
								dbSelectArea("TNY")
								dbSetOrder(2)//TNY_FILIAL+TNY_NATEST
								If dbSeek(xFilial("TNY")+aCont[nX,2]) .And. nQtdDia > 0
									RecLock( "TNY" , .F. )
									TNY->TNY_QTDIAS := nQtdDia
									TNY->(MsUnLock())
								EndIf
							Next nX
						EndIf
					Endif
					//Fim da Alteração SOYUZ Atestado Médico.
					If AliasInDic( "TY9" )

						cQryTMJ := "UPDATE " + RetSqlName( "TMJ" ) //Atendimento médico
						cQryTMJ += " SET " //Atualiza o campos de horario e quantidade
						cQryTMJ += " TMJ_QTDHRS = " + ValToSQL( cDurMin )
						cQryTMJ += " WHERE TMJ_QTDHRS = ' '"
						cQryTMJ += " AND TMJ_FILIAL  = " + ValToSql( xFilial( "TMJ" ) )
						cQryTMJ += " AND D_E_L_E_T_ <> '*' "
						TCSQLExec( cQryTMJ )

						cQryTMK := "UPDATE " + RetSqlName( "TMK" ) //Usuários de Medicina e Segurança
						cQryTMK += " SET " //Atualiza o campos de horario e quantidade
						cQryTMK += " TMK_QTDHRS = " + ValToSQL( cDurMin )
						cQryTMK += " WHERE TMK_QTDHRS = ' '"
						cQryTMK += " AND TMK_FILIAL  = " + ValToSql( xFilial( "TMK" ) )
						cQryTMK += " AND D_E_L_E_T_ <> '*' "
						TCSQLExec( cQryTMK )

						cQryTML := "UPDATE " + RetSqlName( "TML" ) //Usuários com agenda
						cQryTML += " SET " //Atualiza o campos de horario e quantidade
						cQryTML += " TML_QTDHRS = " + ValToSQL( cDurMin )
						cQryTML += " WHERE TML_QTDHRS = ' '"
						cQryTML += " AND TML_FILIAL  = " + ValToSql( xFilial( "TML" ) )
						cQryTML += " AND D_E_L_E_T_ <> '*' "
						TCSQLExec( cQryTML )

						//Validação na TMJ para verificar se é necessário realizar a tratativa nos horários
						If cGetDB == "ORACLE"
							cExprHrs := "% MOD(to_number(to_char(to_date(TMJ.TMJ_HRCONS,'hh24:mi'),'mi')), 5) <> 0 %"
						ElseIf cGetDB == "POSTGRES"
							cExprHrs := "% CAST(SUBSTR(TMJ.TMJ_HRCONS, 4, 2) As Integer) % 5 <> 0 %"
						ElseIf "DB2" $ cGetDB
							cExprHrs := "% MOD(HOUR(TMJ.TMJ_HRCONS)*60 + MINUTE(TMJ.TMJ_HRCONS),5) <> 0 %"
						ElseIf cGetDB == "INFORMIX" .Or. cGetDB == "OPENEDGE"
							cExprHrs := "% MOD(SUBSTR(TMJ.TMJ_HRCONS, 4, 2), 5) <> 0 %"
						Else
							cExprHrs := "% (DATEDIFF(MINUTE,0,TMJ.TMJ_HRCONS) % 5) <> 0 %"
						EndIf

						//Busca horários 'quebrados', com término diferente de 0 ou 5 para serem ajustados, na agenda de consultas médicas
						BeginSQL Alias cHorasTMJ
							SELECT TMJ.TMJ_FILIAL, TMJ.TMJ_NUMFIC, TMJ.TMJ_CODUSU, TMJ.TMJ_DTCONS, TMJ.TMJ_HRCONS
							FROM %table:TMJ% TMJ
							WHERE
							TMJ.TMJ_FILIAL = %xFilial:TMJ% AND
							TMJ.%notDel% AND
							%exp:cExprHrs%
							ORDER BY TMJ_FILIAL, TMJ_NUMFIC, TMJ_CODUSU, TMJ_DTCONS, TMJ_HRCONS
						EndSQL

						dbSelectArea(cHorasTMJ)
						If !(cHorasTMJ)->(EoF()) .Or. !(cHorasTMJ)->(BoF()) //Se houverem registros a serem modificados

							While (cHorasTMJ)->(!EoF())
								lAchou	 := .F.
								// Novo horário da consulta terminando em 0 ou 5
								cHrConsNew := MTOH( HTOM( (cHorasTMJ)->TMJ_HRCONS ) - ( HTOM( (cHorasTMJ)->TMJ_HRCONS ) % 5 ) )

								//Tenta encaixar no novo horário
								dbSelectArea("TMJ")
								dbSetOrder(1) //TMJ_FILIAL +TMJ_CODUSU + TMJ_DTCONS + TMJ_HRCONS
								If !dbSeek( xFilial("TMJ") + (cHorasTMJ)->TMJ_CODUSU + (cHorasTMJ)->TMJ_DTCONS + cHrConsNew, .T. ) //Se naõ houver alguém no novo horário
									TMJ->(dbSkip(-1)) //Vai na consulta  anterior
									If TMJ->( !BoF() )
										If TMJ->TMJ_DTCONS == SToD((cHorasTMJ)->TMJ_DTCONS) .And. TMJ->TMJ_CODUSU == (cHorasTMJ)->TMJ_CODUSU .And. ;
										TMJ->TMJ_FILIAL == (cHorasTMJ)->TMJ_FILIAL

											cHrFimAnt := MTOH( HTOM(TMJ->TMJ_HRCONS) + HTOM(TMJ->TMJ_QTDHRS) ) //Horario fim da consulta anteiror ao novo horário

											If cHrFimAnt > cHrConsNew //Se a duração passa do novo horário
												cHrConsNew 	:= TMJ->TMJ_HRCONS
												lAchou 		:= .F.
											Else //Se acaba antes do novo horário
												lAchou := .T.
											EndIf
										EndIf
									Else
										lAchou := .T.
									EndIf
								EndIf
								//Se não achou, vai tentando encaixar nos horáriso seguintes a consuta que está sendo modificada
								If !lAchou
									//Procura depois
									fSchNextHour( @lAchou, @cHrConsNew )
								EndIf
								//Se não achou e o fim da ultima consulta for antes das 23:55
								If !lAchou
									dbSelectArea("TMJ")
									dbSetOrder(1) //TMJ_FILIAL +TMJ_CODUSU + TMJ_DTCONS + TMJ_HRCONS
									dbSeek( xFilial("TMJ") + (cHorasTMJ)->TMJ_CODUSU + (cHorasTMJ)->TMJ_DTCONS + (cHorasTMJ)->TMJ_HRCONS )
									TMJ->( dbSkip(-1) )
									cHrConsNew := TMJ->TMJ_HRCONS
									//Procura antes
									fSchBefHour( @lAchou, @cHrConsNew )
								EndIf

								If lAchou
									//---------------------------
									//Grava novo valor em base
									//---------------------------
									DbSelectArea( "TMJ" )
									DbsetOrder( 1 ) //TMJ_FILIAL+TMJ_CODUSU+DTOS(TMJ_DTCONS)+TMJ_HRCONS
									If DbSeek( xFilial( "TMJ" ) + (cHorasTMJ)->TMJ_CODUSU + (cHorasTMJ)->TMJ_DTCONS + (cHorasTMJ)->TMJ_HRCONS )

										cQryTMJ := "UPDATE " + RetSqlName( "TMJ" )
										cQryTMJ += " SET TMJ_HRCONS = " + ValToSQL( cHrConsNew ) + " ," //Atualiza o campos de horario e quantidade
										cQryTMJ += " TMJ_QTDHRS = " + ValToSQL( cDurMin )
										cQryTMJ += " WHERE TMJ_FILIAL = " + ValToSQL( xFilial("TMJ") )
										cQryTMJ += " AND TMJ_CODUSU = '" + (cHorasTMJ)->TMJ_CODUSU + "'"
										cQryTMJ += " AND TMJ_NUMFIC = '" + (cHorasTMJ)->TMJ_NUMFIC + "'"
										cQryTMJ += " AND TMJ_DTCONS = '" + (cHorasTMJ)->TMJ_DTCONS + "'"
										cQryTMJ += " AND TMJ_HRCONS = '" + (cHorasTMJ)->TMJ_HRCONS + "'"
										cQryTMJ += " AND D_E_L_E_T_ <> '*' "
										TCSQLExec( cQryTMJ )

										cQryTMT := "UPDATE " + RetSqlName( "TMT" )
										cQryTMT += " SET TMT_HRCONS = " + ValToSQL( cHrConsNew )
										cQryTMT += " WHERE TMT_FILIAL = " + ValToSQL( xFilial("TMT") )
										cQryTMT += " AND TMT_NUMFIC = '" + (cHorasTMJ)->TMJ_NUMFIC + "'"
										cQryTMT += " AND TMT_DTCONS = '" + (cHorasTMJ)->TMJ_DTCONS + "'"
										cQryTMT += " AND TMT_HRCONS = '" + (cHorasTMJ)->TMJ_HRCONS + "'"
										cQryTMT += " AND D_E_L_E_T_ <> '*' "
										TCSQLExec( cQryTMT )

										cQryTM2 := "UPDATE " + RetSqlName( "TM2" )
										cQryTM2 += " SET TM2_HRCONS = " + ValToSQL( cHrConsNew )
										cQryTM2 += " WHERE TM2_FILIAL = " + ValToSQL( xFilial("TM2") )
										cQryTM2 += " AND TM2_NUMFIC = '" + (cHorasTMJ)->TMJ_NUMFIC + "'"
										cQryTM2 += " AND TM2_DTCONS = '" + (cHorasTMJ)->TMJ_DTCONS + "'"
										cQryTM2 += " AND TM2_HRCONS = '" + (cHorasTMJ)->TMJ_HRCONS + "'"
										cQryTM2 += " AND D_E_L_E_T_ <> '*' "
										TCSQLExec( cQryTM2 )

										cQryTNY := "UPDATE " + RetSqlName( "TNY" )
										cQryTNY += " SET TNY_HRCONS = " + ValToSQL( cHrConsNew )
										cQryTNY += " WHERE TNY_FILIAL = " + ValToSQL( xFilial("TNY") )
										cQryTNY += " AND TNY_NUMFIC = '" + (cHorasTMJ)->TMJ_NUMFIC + "'"
										//Deverá verificar os campos de data coonsulta e horario da consulta
										cQryTNY += " AND TNY_DTCONS = '" + (cHorasTMJ)->TMJ_DTCONS + "'"
										cQryTNY += " AND TNY_HRCONS = '" + (cHorasTMJ)->TMJ_HRCONS + "'"
										cQryTNY += " AND D_E_L_E_T_ <> '*' "
										TCSQLExec( cQryTNY )

										cQryTKJ := "UPDATE " + RetSqlName( "TKJ" )
										cQryTKJ += " SET TKJ_HRCONS = " + ValToSQL( cHrConsNew )
										cQryTKJ += " WHERE TKJ_FILIAL = " + ValToSQL( xFilial("TKJ") )
										cQryTKJ += " AND TKJ_NUMFIC = '" + (cHorasTMJ)->TMJ_NUMFIC + "'"
										cQryTKJ += " AND TKJ_DTCONS = '" + (cHorasTMJ)->TMJ_DTCONS + "'"
										cQryTKJ += " AND TKJ_HRCONS = '" + (cHorasTMJ)->TMJ_HRCONS + "'"
										cQryTKJ += " AND D_E_L_E_T_ <> '*' "
										TCSQLExec( cQryTKJ )

									EndIf
									//------------------
								Else //Se não achou horário para encaixar, exclui os registros relcionados a consulta

									dbSelectArea( "TMJ" ) //Agenda de Atendimento Médico
									dbSetOrder( 1 ) //TMJ_FILIAL +TMJ_CODUSU + TMJ_DTCONS + TMJ_HRCONS
									If dbSeek( (cHorasTMJ)->TMJ_FILIAL +(cHorasTMJ)->TMJ_CODUSU + (cHorasTMJ)->TMJ_DTCONS + (cHorasTMJ)->TMJ_HRCONS )
										RecLock( "TMJ", .F. )
										TMJ->( dbDelete() )
										TMJ->( MsUnLock() )
									EndIf
									DbSelectArea( "TMT" ) //Diagnóstico
									DbsetOrder( 3 ) //TMT_FILIAL+TMT_NUMFIC+DTOS(TMT_DTCONS)+TMT_HRCONS
									If DbSeek( xFilial( "TMT" ) + (cHorasTMJ)->TMJ_NUMFIC + (cHorasTMJ)->TMJ_DTCONS + (cHorasTMJ)->TMJ_HRCONS )
										RecLock( "TMT", .F. )
										TMT->( dbDelete() )
										TMT->( MsUnLock() )
									EndIf
									DbSelectArea( "TM2" )//Medicamentos Utilizados
									DbSetOrder( 1 ) //TM2_FILIAL+TM2_NUMFIC+DTOS(TM2_DTCONS)+TM2_HRCONS+TM2_CODMED
									If DbSeek( xFilial( "TM2" ) + (cHorasTMJ)->TMJ_NUMFIC + (cHorasTMJ)->TMJ_DTCONS + (cHorasTMJ)->TMJ_HRCONS )
										RecLock( "TM2", .F. )
										TM2->( dbDelete() )
										TM2->( MsUnLock() )
									EndIf
									DbSelectArea( "TNY" )//Atestados Médicos
									DbSetOrder( 1 ) //TNY_FILIAL+TNY_NUMFIC+DTOS(TNY_DTINIC)+TNY_HRINIC
									If DbSeek( xFilial( "TNY" ) + (cHorasTMJ)->TMJ_NUMFIC )
										RecLock( "TNY", .F. )
										TNY->( dbDelete() )
										TNY->( MsUnLock() )
									EndIf
									DbSelectArea( "TKJ" )//Cid Complementar
									DbSetOrder( 1 ) //TKJ_FILIAL+TKJ_NUMFIC+DTOS(TKJ_DTCONS)+TKJ_HRCONS+TKJ_GRPCID+TKJ_CID
									If DbSeek( xFilial( "TKJ" ) + (cHorasTMJ)->TMJ_NUMFIC + (cHorasTMJ)->TMJ_DTCONS + (cHorasTMJ)->TMJ_HRCONS )
										RecLock( "TKJ", .F. )
										TKJ->( dbDelete() )
										TKJ->( MsUnLock() )
									EndIf
								EndIf

								(cHorasTMJ)->(dbSkip())

							EndDo
						EndIf
					EndIf
				EndIf
			EndIf

			// Alterações para a versão 12.1.2310 do Protheus
			If cRelFinish == '2310'
				If cMode == '2' // Alterações para todas as filiais
					fAtuDiaMem()
				EndIf
			EndIf

			//--------------------------------------------------------
			// Liberações pontuais (legislações) em meios de release
			//--------------------------------------------------------
			If	cMode == "1"

				If TM0->( ColumnPos( "TM0_CTPCD" ) ) > 0 .And. SRA->( ColumnPos( "RA_CTPCD" ) ) > 0

					cQryTM0 := "UPDATE " + RetSQLName( "TM0" )
					cQryTM0 += "  SET TM0_CTPCD = " + cIsNull + "(("
					cQryTM0 += "    SELECT SRA.RA_CTPCD FROM " + RetSQLName( "SRA" ) + " SRA "
					cQryTM0 += "      WHERE SRA.RA_FILIAL = TM0_FILFUN AND SRA.RA_MAT = TM0_MAT AND "
					cQryTM0 += "      SRA.D_E_L_E_T_ <> '*' "
					cQryTM0 += "  ),'')"
					cQryTM0 += "WHERE"
					cQryTM0 += "  TM0_CTPCD = '' AND D_E_L_E_T_ <> '*'"
					TCSQLExec( cQryTM0 )

				EndIf

				//Exclusão do relacionamento entre TNE e TYG não mais utilizado
				fDeletaSX9( 'TNE', 'TYG', 'TNE_CODAMB', 'TYG_CODAMB' )
				fDeletaSX9( 'TMA', 'TYG', 'TMA_AGENTE', 'TYG_AGENTE' )

				//Atualiza o inicializador padrão (X3_RELACAO) passado por parâmetro
				fAtuIniPad( 'TOF_NOMFIC', 'MDT920SX3(2,"TOF_NOMFIC")' )
				fAtuIniPad( 'TOQ_DESCCC', 'MDT165SX3(2,"TOQ_DESCCC")' )

			ElseIf cMode == "2"

                // Atualizacao do Valor do campo TMY_PLAT de acordo com a existencia de permissoes
                If TMY->(ColumnPos("TMY_PLAT")) > 0

                    cQuery := "UPDATE " + RetSqlName("TMY") + " "
                    cQuery += "SET TMY_PLAT = '1' "
                    cQuery += "WHERE TMY_NUMASO "
                    cQuery += "IN ( "
                    cQuery += "SELECT TY7.TY7_NUMASO "
                    cQuery += "FROM " + RetSqlName("TY7") + " TY7 "
                    cQuery += "WHERE TY7.D_E_L_E_T_ = '' "
                    cQuery += "AND TMY_NUMASO = TY7.TY7_NUMASO "
                    cQuery += "AND TY7.TY7_FILIAL = " + ValToSql(xFilial("TY7"))
                    cQuery += "AND TY7.TY7_TIPERM = '1'  )"
                    cQuery += "AND D_E_L_E_T_ = '' "
                    cQuery += "AND TMY_FILIAL =  " + ValToSql(xFilial("TMY"))
                    TcSqlExec( cQuery )

                    cQuery := "UPDATE " + RetSqlName("TMY") + " "
                    cQuery += "SET TMY_PLAT = '2' "
                    cQuery += "WHERE TMY_PLAT = '' AND D_E_L_E_T_ = '' "
                    TcSqlExec( cQuery )

                EndIf
				
                // Atualizacao do Valor do campo TMY_MANCIV de acordo com a existencia de permissoes
                If TMY->(ColumnPos("TMY_MANCIV")) > 0

                    cQuery := "UPDATE " + RetSqlName("TMY") + " "
                    cQuery += "SET TMY_MANCIV = '1' "
                    cQuery += "WHERE TMY_NUMASO "
                    cQuery += "IN ( "
                    cQuery += "SELECT TY7.TY7_NUMASO "
                    cQuery += "FROM " + RetSqlName("TY7") + " TY7 "
                    cQuery += "WHERE TY7.D_E_L_E_T_ = '' "
                    cQuery += "AND TMY_NUMASO = TY7.TY7_NUMASO "
                    cQuery += "AND TY7.TY7_FILIAL = " + ValToSql(xFilial("TY7"))
                    cQuery += "AND TY7.TY7_TIPERM = '2'  )"
                    cQuery += "AND D_E_L_E_T_ = '' "
                    cQuery += "AND TMY_FILIAL =  " + ValToSql(xFilial("TMY"))
                    TcSqlExec( cQuery )

                    cQuery := "UPDATE " + RetSqlName("TMY") + " "
                    cQuery += "SET TMY_MANCIV = '2' "
                    cQuery += "WHERE TMY_MANCIV = '' AND D_E_L_E_T_ = '' "
                    TcSqlExec( cQuery )

                EndIf

                // Atualizacao do Valor do campo TMY_EXPLO de acordo com a existencia de permissoes
                If TMY->(ColumnPos("TMY_EXPLO")) > 0

                    cQuery := "UPDATE " + RetSqlName("TMY") + " "
                    cQuery += "SET TMY_EXPLO = '1' "
                    cQuery += "WHERE TMY_NUMASO "
                    cQuery += "IN ( "
                    cQuery += "SELECT TY7.TY7_NUMASO "
                    cQuery += "FROM " + RetSqlName("TY7") + " TY7 "
                    cQuery += "WHERE TY7.D_E_L_E_T_ = '' "
                    cQuery += "AND TMY_NUMASO = TY7.TY7_NUMASO "
                    cQuery += "AND TY7.TY7_FILIAL = " + ValToSql(xFilial("TY7"))
                    cQuery += "AND TY7.TY7_TIPERM = '3'  )"
                    cQuery += "AND D_E_L_E_T_ = '' "
                    cQuery += "AND TMY_FILIAL =  " + ValToSql(xFilial("TMY"))
                    TcSqlExec( cQuery )

                    cQuery := "UPDATE " + RetSqlName("TMY") + " "
                    cQuery += "SET TMY_EXPLO = '2' "
                    cQuery += "WHERE TMY_EXPLO = '' AND D_E_L_E_T_ = '' "
                    TcSqlExec( cQuery )

                EndIf

                // Atualizacao do Valor do campo TMY_ALTURA de acordo com a existencia de permissoes
                If TMY->(ColumnPos("TMY_ALTURA")) > 0

                    cQuery := "UPDATE " + RetSqlName("TMY") + " "
                    cQuery += "SET TMY_ALTURA = '1' "
                    cQuery += "WHERE TMY_NUMASO "
                    cQuery += "IN ( "
                    cQuery += "SELECT TY7.TY7_NUMASO "
                    cQuery += "FROM " + RetSqlName("TY7") + " TY7 "
                    cQuery += "WHERE TY7.D_E_L_E_T_ = '' "
                    cQuery += "AND TMY_NUMASO = TY7.TY7_NUMASO "
                    cQuery += "AND TY7.TY7_FILIAL = " + ValToSql(xFilial("TY7"))
                    cQuery += "AND TY7.TY7_TIPERM = '4'  )"
                    cQuery += "AND D_E_L_E_T_ = '' "
                    cQuery += "AND TMY_FILIAL =  " + ValToSql(xFilial("TMY"))
                    TcSqlExec( cQuery )

                    cQuery := "UPDATE " + RetSqlName("TMY") + " "
                    cQuery += "SET TMY_ALTURA = '2' "
                    cQuery += "WHERE TMY_ALTURA = '' AND D_E_L_E_T_ = '' "
                    TcSqlExec( cQuery )

                EndIf

                // Atualizacao do Valor do campo TMY_ESCAV de acordo com a existencia de permissoes
                If TMY->(ColumnPos("TMY_ESCAV")) > 0

                    cQuery := "UPDATE " + RetSqlName("TMY") + " "
                    cQuery += "SET TMY_ESCAV = '1' "
                    cQuery += "WHERE TMY_NUMASO "
                    cQuery += "IN ( "
                    cQuery += "SELECT TY7.TY7_NUMASO "
                    cQuery += "FROM " + RetSqlName("TY7") + " TY7 "
                    cQuery += "WHERE TY7.D_E_L_E_T_ = '' "
                    cQuery += "AND TMY_NUMASO = TY7.TY7_NUMASO "
                    cQuery += "AND TY7.TY7_FILIAL = " + ValToSql(xFilial("TY7"))
                    cQuery += "AND TY7.TY7_TIPERM = '5'  )"
                    cQuery += "AND D_E_L_E_T_ = '' "
                    cQuery += "AND TMY_FILIAL =  " + ValToSql(xFilial("TMY"))
                    TcSqlExec( cQuery )

                    cQuery := "UPDATE " + RetSqlName("TMY") + " "
                    cQuery += "SET TMY_ESCAV = '2' "
                    cQuery += "WHERE TMY_ESCAV = '' AND D_E_L_E_T_ = '' "
                    TcSqlExec( cQuery )

                EndIf

				// Atualizacao do Valor do campo TMY_ELETRI de acordo com a existencia de permissoes
				If TMY->(ColumnPos("TMY_ELETRI")) > 0

					cQuery := "UPDATE " + RetSqlName("TMY") + " "
					cQuery += "SET TMY_ELETRI = '1' "
					cQuery += "WHERE TMY_NUMASO "
					cQuery += "IN ( "
					cQuery += "SELECT TY7.TY7_NUMASO "
					cQuery += "FROM " + RetSqlName("TY7") + " TY7 "
					cQuery += "WHERE TY7.D_E_L_E_T_ <> '*' "
					cQuery += "AND TMY_NUMASO = TY7.TY7_NUMASO "
					cQuery += "AND TY7.TY7_FILIAL = " + ValToSql(xFilial("TY7"))
					cQuery += "AND TY7.TY7_TIPERM = '6'  )"
					cQuery += "AND D_E_L_E_T_ <> '*' "
					cQuery += "AND TMY_FILIAL =  " + ValToSql(xFilial("TMY"))
					TcSqlExec( cQuery )

					cQuery := "UPDATE " + RetSqlName("TMY") + " "
					cQuery += "SET TMY_ELETRI = '2' "
					cQuery += "WHERE TMY_ELETRI = '' AND D_E_L_E_T_ <> '*' "
					TcSqlExec( cQuery )

				EndIf

				// Atualizacao do Valor do campo TMY_SOLDA de acordo com a existencia de permissoes
				If TMY->(ColumnPos("TMY_SOLDA")) > 0

					cQuery := "UPDATE " + RetSqlName("TMY") + " "
					cQuery += "SET TMY_SOLDA = '1' "
					cQuery += "WHERE TMY_NUMASO "
					cQuery += "IN ( "
					cQuery += "SELECT TY7.TY7_NUMASO "
					cQuery += "FROM " + RetSqlName("TY7") + " TY7 "
					cQuery += "WHERE TY7.D_E_L_E_T_ = '' "
					cQuery += "AND TMY_NUMASO = TY7.TY7_NUMASO "
					cQuery += "AND TY7.TY7_FILIAL = " + ValToSql(xFilial("TY7"))
					cQuery += "AND TY7.TY7_TIPERM = '7'  )"
					cQuery += "AND D_E_L_E_T_ = '' "
					cQuery += "AND TMY_FILIAL =  " + ValToSql(xFilial("TMY"))
					TcSqlExec( cQuery )

					cQuery := "UPDATE " + RetSqlName("TMY") + " "
					cQuery += "SET TMY_SOLDA = '2' "
					cQuery += "WHERE TMY_SOLDA = '' AND D_E_L_E_T_ = '' "
					TcSqlExec( cQuery )

				EndIf

				// Atualizacao do Valor do campo TMY_CONFIN de acordo com a existencia de permissoes
				If TMY->(ColumnPos("TMY_CONFIN")) > 0

					cQuery := "UPDATE " + RetSqlName("TMY") + " "
					cQuery += "SET TMY_CONFIN = '1' "
					cQuery += "WHERE TMY_NUMASO "
					cQuery += "IN ( "
					cQuery += "SELECT TY7.TY7_NUMASO "
					cQuery += "FROM " + RetSqlName("TY7") + " TY7 "
					cQuery += "WHERE TY7.D_E_L_E_T_ = '' "
					cQuery += "AND TMY_NUMASO = TY7.TY7_NUMASO "
					cQuery += "AND TY7.TY7_FILIAL = " + ValToSql(xFilial("TY7"))
					cQuery += "AND TY7.TY7_TIPERM = '8'  )"
					cQuery += "AND D_E_L_E_T_ = '' "
					cQuery += "AND TMY_FILIAL =  " + ValToSql(xFilial("TMY"))
					TcSqlExec( cQuery )

					cQuery := "UPDATE " + RetSqlName("TMY") + " "
					cQuery += "SET TMY_CONFIN = '2' "
					cQuery += "WHERE TMY_CONFIN = '' AND D_E_L_E_T_ = '' "
					TcSqlExec( cQuery )

				EndIf

				// Atualizacao do Valor do campo TMY_FRIO de acordo com a existencia de permissoes
				If TMY->(ColumnPos("TMY_FRIO")) > 0

					cQuery := "UPDATE " + RetSqlName("TMY") + " "
					cQuery += "SET TMY_FRIO = '1' "
					cQuery += "WHERE TMY_NUMASO "
					cQuery += "IN ( "
					cQuery += "SELECT TY7.TY7_NUMASO "
					cQuery += "FROM " + RetSqlName("TY7") + " TY7 "
					cQuery += "WHERE TY7.D_E_L_E_T_ = '' "
					cQuery += "AND TMY_NUMASO = TY7.TY7_NUMASO "
					cQuery += "AND TY7.TY7_FILIAL = " + ValToSql(xFilial("TY7"))
					cQuery += "AND TY7.TY7_TIPERM = '9'  )"
					cQuery += "AND D_E_L_E_T_ = '' "
					cQuery += "AND TMY_FILIAL =  " + ValToSql(xFilial("TMY"))
					TcSqlExec( cQuery )

					cQuery := "UPDATE " + RetSqlName("TMY") + " "
					cQuery += "SET TMY_FRIO = '2' "
					cQuery += "WHERE TMY_FRIO = '' AND D_E_L_E_T_ = '' "
					TcSqlExec( cQuery )

				EndIf

				// Atualizacao do Valor do campo TMY_RADIA de acordo com a existencia de permissoes
				If TMY->(ColumnPos("TMY_RADIA")) > 0

					cQuery := "UPDATE " + RetSqlName("TMY") + " "
					cQuery += "SET TMY_RADIA = '1' "
					cQuery += "WHERE TMY_NUMASO "
					cQuery += "IN ( "
					cQuery += "SELECT TY7.TY7_NUMASO "
					cQuery += "FROM " + RetSqlName("TY7") + " TY7 "
					cQuery += "WHERE TY7.D_E_L_E_T_ = '' "
					cQuery += "AND TMY_NUMASO = TY7.TY7_NUMASO "
					cQuery += "AND TY7.TY7_FILIAL = " + ValToSql(xFilial("TY7"))
					cQuery += "AND TY7.TY7_TIPERM = 'A'  )"
					cQuery += "AND D_E_L_E_T_ = '' "
					cQuery += "AND TMY_FILIAL =  " + ValToSql(xFilial("TMY"))
					TcSqlExec( cQuery )

					cQuery := "UPDATE " + RetSqlName("TMY") + " "
					cQuery += "SET TMY_RADIA = '2' "
					cQuery += "WHERE TMY_RADIA = '' AND D_E_L_E_T_ = '' "
					TcSqlExec( cQuery )

				EndIf

				// Atualizacao do Valor do campo TMY_PRESS de acordo com a existencia de permissoes
				If TMY->(ColumnPos("TMY_PRESS")) > 0

					cQuery := "UPDATE " + RetSqlName("TMY") + " "
					cQuery += "SET TMY_PRESS = '1' "
					cQuery += "WHERE TMY_NUMASO "
					cQuery += "IN ( "
					cQuery += "SELECT TY7.TY7_NUMASO "
					cQuery += "FROM " + RetSqlName("TY7") + " TY7 "
					cQuery += "WHERE TY7.D_E_L_E_T_ = '' "
					cQuery += "AND TMY_NUMASO = TY7.TY7_NUMASO "
					cQuery += "AND TY7.TY7_FILIAL = " + ValToSql(xFilial("TY7"))
					cQuery += "AND TY7.TY7_TIPERM = 'B'  )"
					cQuery += "AND D_E_L_E_T_ = '' "
					cQuery += "AND TMY_FILIAL =  " + ValToSql(xFilial("TMY"))
					TcSqlExec( cQuery )

					cQuery := "UPDATE " + RetSqlName("TMY") + " "
					cQuery += "SET TMY_PRESS = '2' "
					cQuery += "WHERE TMY_PRESS = '' AND D_E_L_E_T_ = '' "
					TcSqlExec( cQuery )

				EndIf

				// Atualizacao do Valor do campo TMY_OUTROS de acordo com a existencia de permissoes
				If TMY->(ColumnPos("TMY_OUTROS")) > 0

					cQuery := "UPDATE " + RetSqlName("TMY") + " "
					cQuery += "SET TMY_OUTROS = '1' "
					cQuery += "WHERE TMY_NUMASO "
					cQuery += "IN ( "
					cQuery += "SELECT TY7.TY7_NUMASO "
					cQuery += "FROM " + RetSqlName("TY7") + " TY7 "
					cQuery += "WHERE TY7.D_E_L_E_T_ = '' "
					cQuery += "AND TMY_NUMASO = TY7.TY7_NUMASO "
					cQuery += "AND TY7.TY7_FILIAL = " + ValToSql(xFilial("TY7"))
					cQuery += "AND TY7.TY7_TIPERM = 'X'  )"
					cQuery += "AND D_E_L_E_T_ = '' "
					cQuery += "AND TMY_FILIAL =  " + ValToSql(xFilial("TMY"))
					TcSqlExec( cQuery )

					cQuery := "UPDATE " + RetSqlName("TMY") + " "
					cQuery += "SET TMY_OUTROS = '2' "
					cQuery += "WHERE TMY_OUTROS = '' AND D_E_L_E_T_ = '' "
					TcSqlExec( cQuery )

				EndIf

			EndIf

		EndIf

		#ENDIF
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fAtuDiaMem
Atualiza os campos memo do diagnóstico médico (TMT)

@author Gabriel Sokacheski
@since 20/06/2023

/*/
//-------------------------------------------------------------------
Static Function fAtuDiaMem()

	Local aCampo := {;
		{ 'TMT_HISSYP', 'TMT_MHISPR' 	},;
		{ 'TMT_AUPSYP', 'TMT_MAUSPU' 	},;
		{ 'TMT_DIASYP', 'TMT_MDIAGN' 	},;
		{ 'TMT_DATSYP', 'TMT_MDESAT' 	},;
		{ 'TMT_QUESYP', 'TMT_MQUEIX'	},;
		{ 'TMT_HDASYP', 'TMT_MHDA' 		},;
		{ 'TMT_CABSYP', 'TMT_MCABEC' 	},;
		{ 'TMT_OLHSYP', 'TMT_MOLHOS' 	},;
		{ 'TMT_OUVSYP', 'TMT_MOUVID' 	},;
		{ 'TMT_PESSYP', 'TMT_MPESCO' 	},;
		{ 'TMT_APRSYP', 'TMT_MAPRES' 	},;
		{ 'TMT_APDSYP', 'TMT_MAPDIG' 	},;
		{ 'TMT_APCSYP', 'TMT_MAPCIR' 	},;
		{ 'TMT_APUSYP', 'TMT_MAPURI' 	},;
		{ 'TMT_MISSYP', 'TMT_MMIS' 		},;
		{ 'TMT_PELSYP', 'TMT_MPELE' 	},;
		{ 'TMT_EXFSYP', 'TMT_MEXAME' 	},;
		{ 'TMT_ORFSYP', 'TMT_MOROFA' 	},;
		{ 'TMT_OTSSYP', 'TMT_MOTOSC' 	},;
		{ 'TMT_ABDSYP', 'TMT_MABDOM' 	},;
		{ 'TMT_AUCSYP', 'TMT_MAUSCA' 	};
	}

	Local cTexto := ''

	Local nCampo := 0

	DbSelectArea( 'TMT' )
	DbSetOrder( 1 )
	( 'TMT' )->( DbGoTop() )

	While ( 'TMT' )->( !Eof() )

		For nCampo := 1 To Len ( aCampo )

			cTexto = ''

			If !Empty( TMT->&( aCampo[ nCampo, 1 ] ) ) .And. Empty( TMT->&( aCampo[ nCampo, 2 ] ) )

				DbSelectArea( 'SYP' )
				DbSetOrder( 1 )

				If ( 'SYP' )->( DbSeek( xFilial( 'SYP' ) + TMT->&( aCampo[ nCampo, 1 ] ) ) )

					While ( 'SYP' )->( !Eof() ) .And. SYP->YP_FILIAL == xFilial( 'SYP' );
					.And. SYP->YP_CHAVE == TMT->&( aCampo[ nCampo, 1 ] ) .And. SYP->YP_CAMPO == aCampo[ nCampo, 1 ]

						cTexto += SYP->YP_TEXTO

						fForCamMem( @cTexto )

						( 'SYP' )->( DbSkip() )

					End

					RecLock( 'TMT', .F. )
						TMT->&( aCampo[ nCampo, 2 ] ) := cTexto
					( 'TMT' )->( MsUnLock() )

				EndIf

			EndIf

		Next nCampo

		( 'TMT' )->( DbSkip() )

	End

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fForCamMem
Formata o conteúdo do campo memo para gravação

@author Gabriel Sokacheski
@since 26/06/2023

@param, cTexto, texto a ser formatado para gravação

/*/
//-------------------------------------------------------------------
Static Function fForCamMem( cTexto )

	Local nQueLin := 0

	cTexto := AllTrim( cTexto )
	nQueLin := At( '\13\10', cTexto )

	If nQueLin > 0
		cTexto := SubStr( cTexto, 1, nQueLin - 1 ) + Chr( 13 ) + Chr( 10 )
	Else
		fAdiEspMem( @cTexto )
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fAdiEspMem
Formata o conteúdo do campo memo para gravação

@author Gabriel Sokacheski
@since 26/06/2023

@param, cTexto, texto a ter o espaçamento verificado

/*/
//-------------------------------------------------------------------
Static Function fAdiEspMem( cTexto )

	If Len( cTexto ) < 10
		cTexto += Space( 1 )
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fSchNextHour
Busca próximo horário disponível nos registros posteriores

@param lAchou, lógico, se achou uma novca hora válida
@param cHrConsNew, caracter, novo horário válido

@sample fSchNextHour( @lAchou, @cHrConsNew )

@return Nil, sempre nulo

@author Julia Kondlatsch
@since  12/03/2018
/*/
//-------------------------------------------------------------------
Static Function fSchNextHour(lAchou,cHrConsNew)

	Local cHrInic	:= '' //Hora de início da consulta atual
	Local nLoop		:= 0
	Local lEncaixe  := .F.
	Local nRegTMJ	:= 0

	dbSelectArea("TMJ")
	dbSetOrder(1) //TMJ_FILIAL +TMJ_CODUSU + TMJ_DTCONS + TMJ_HRCONS
	//Posiciona na consulta que está sendo modificada
	If dbSeek( xFilial("TMJ") + (cHorasTMJ)->TMJ_CODUSU + (cHorasTMJ)->TMJ_DTCONS + cHrConsNew )
		While TMJ->( !EoF() ) .And. TMJ->TMJ_FILIAL == (cHorasTMJ)->TMJ_FILIAL .And. TMJ->TMJ_CODUSU == (cHorasTMJ)->TMJ_CODUSU .And. ;
		TMJ->TMJ_DTCONS == SToD((cHorasTMJ)->TMJ_DTCONS) .And. !lAchou .And. cHrConsNew <= "23:55"

			cHrInic := TMJ->TMJ_HRCONS

			If HTOM( TMJ->TMJ_QTDHRS ) % 5 == 0
				nRegTMJ  := TMJ->( Recno() )
				nLoop	 := 0
				lEncaixe := .F.
				While MTOH( HTOM( TMJ->TMJ_HRCONS ) + HTOM( TMJ->TMJ_QTDHRS ) ) > cHrConsNew
					nLoop ++
					cHrConsNew := MTOH( HTOM( TMJ->TMJ_HRCONS ) + HTOM( "00:05" ) )
					If !dbSeek( xFilial( "TMJ" ) + (cHorasTMJ)->TMJ_CODUSU + (cHorasTMJ)->TMJ_DTCONS + cHrConsNew ) .And. ;
					cHrConsNew <= "23:55"
						lEncaixe := .T.
						Exit
					EndIf
				End
				dbSelectArea( "TMJ" )
				dbGoTo( nRegTMJ )
				If lEncaixe
					RecLock( "TMJ" , .F. )
					TMJ->TMJ_QTDHRS := MTOH( 5 * nLoop )
					TMJ->( MsUnLock() )
					lAchou := .T.
				Else
					TMJ->( dbSkip() )
				EndIf
			Else
				TMJ->( dbSkip() )
			EndIf
		EndDo
	Else
		lAchou := .T.
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} fSchBefHour
Busca próximo horário disponível nos registros ateriores

@param lAchou, lógico, se achou uma novca hora válida
@param cHrConsNew, caracter, novo horário válido

@sample fSchBefHour( @lAchou, @cHrConsNew )

@return Nil, sempre nulo

@author Julia Kondlatsch
@since  12/03/2018
/*/
//-------------------------------------------------------------------
Static Function fSchBefHour(lAchou,cHrConsNew)

	Local cSvHor 	:= ""
	Local nLoop	 	:= 0
	Local lEncaixe 	:= .F.

	While cHrConsNew >= "00:00"
		cSvHor := cHrConsNew
		dbSelectArea("TMJ")
		dbSetOrder(1) //TMJ_FILIAL +TMJ_CODUSU + TMJ_DTCONS + TMJ_HRCONS
		//Posiciona na consulta que está sendo modificada
		If dbSeek( xFilial("TMJ") + (cHorasTMJ)->TMJ_CODUSU + (cHorasTMJ)->TMJ_DTCONS + cHrConsNew , .T. )
			While MTOH( HTOM( TMJ->TMJ_HRCONS ) + HTOM( TMJ->TMJ_QTDHRS ) ) > cHrConsNew
				nLoop ++
				cHrConsNew := MTOH( HTOM( TMJ->TMJ_HRCONS ) + HTOM( "00:05" ) )
				If !dbSeek( xFilial( "TMJ" ) + (cHorasTMJ)->TMJ_CODUSU + (cHorasTMJ)->TMJ_DTCONS + cHrConsNew ) .And. ;
				cHrConsNew <= "23:55"
					lEncaixe := .T.
					Exit
				EndIf
			End
			dbSelectArea( "TMJ" )
			If lEncaixe
				RecLock( "TMJ" , .F. )
				TMJ->TMJ_QTDHRS := MTOH( 5 * nLoop )
				TMJ->( MsUnLock() )
				lAchou := .T.
				Exit
			EndIf
		Else
			TMJ->( dbSkip( -1 ) )
			If TMJ->( BoF() )
				lAchou := .T.
				Exit
			Else
				If TMJ->TMJ_DTCONS <> SToD((cHorasTMJ)->TMJ_DTCONS) .Or. TMJ->TMJ_CODUSU <> (cHorasTMJ)->TMJ_CODUSU .Or. ;
				TMJ->TMJ_FILIAL <> (cHorasTMJ)->TMJ_FILIAL .Or. MTOH( HTOM( TMJ->TMJ_HRCONS ) + HTOM( TMJ->TMJ_QTDHRS ) ) < cHrConsNew
					lAchou := .T.
					Exit
				EndIf
			EndIf
		EndIf
		cHrConsNew := MTOH( HTOM( cSvHor ) - HTOM( "00:05" ) )
	EndDo

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} fValueDef
Atribui valor default dos campos
@type  Static Function
@author Bruno Lobo de Souza
@since 27/11/2017
@version P12
@param cTblAlias, Caracter, Alias da tabela cujo campo receberá um valor default
@param cTblField, Caracter, Campo que receberá um valor default
@param cValueDef, Caracter, Valor default a ser atribuido ao campo
@param cCondition, Caracter, Condição para atribuição do valor default ao campo
@return Nil
@example
fValueDef("TLD", "TLD_RECEBI", "1", "TLD_RECEBI = '' AND TLD_SITUAC = '2'")

/*/
//-------------------------------------------------------------------
Static Function fValueDef(cTblAlias, cTblField, cValueDef, cCondition)

	Local cQuery
	Default cCondition := cTblField + " = ''"

	cQuery := "UPDATE "
	cQuery += RetSqlName( cTblAlias )
	cQuery += " SET " + cTblField + " = " + ValToSql(cValueDef)
	cQuery += " WHERE " + cCondition
	TcSqlExec( cQuery )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fDeletaSX9
Deleta o relacionamento SX9 passado por parâmetro

@sample	fDeletaSX9( 'TNE', 'TYG', 'TNE_CODAMB', 'TYG_CODAMB' )

@param cTblDom, Caracter, Tabela de domínio
@param cTblCDom, Caracter, Tabela de contra domínio
@param cCpoDom, Caracter, Campo de domínio
@param cCpoCDom, Caracter, Campo de contra domínio

@author	Luis Fellipy Bett
@since	05/07/2021

@return Nil, Nulo
/*/
//---------------------------------------------------------------------
Static Function fDeletaSX9( cTblDom, cTblCDom, cCpoDom, cCpoCDom )

	Local aArea := GetArea()

	dbSelectArea( "SX9" )
	dbSetOrder( 2 )
	If dbSeek( cTblCDom + cTblDom )
		While SX9->( !Eof() ) .And. AllTrim( SX9->X9_CDOM ) == cTblCDom .And. AllTrim( SX9->X9_DOM ) == cTblDom
			If AllTrim( SX9->X9_EXPDOM ) == cCpoDom .And. AllTrim( SX9->X9_EXPCDOM ) == cCpoCDom
				SX9->( RecLock( 'SX9', .F. ) )
				SX9->( dbDelete() )
				SX9->( MsUnLock() )
			EndIf
			SX9->( dbSkip() )
		End
	EndIf

	RestArea( aArea )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fAtuIniPad
Atualiza o conteúdo do inicializador padrão do campo paassado por parâmetro

@sample	fAtuIniPad( 'TOQ_DESCCC', 'MDT165SX3(2,"TOQ_DESCCC")' )

@param cCampo, Caracter, Campo a ter o X3_RELACAO atualizado
@param cContNov, Caracter, Conteúdo novo a ser inserido no X3_RELACAO do campo

@author	Luis Fellipy Bett
@since	30/08/2021

@return Nil, Nulo
/*/
//---------------------------------------------------------------------
Static Function fAtuIniPad( cCampo, cContNov )

	dbSelectArea( "SX3" )
	dbSetOrder( 2 )
	If dbSeek( cCampo )
		If AllTrim( SX3->X3_RELACAO ) <> AllTrim( cContNov )
			RecLock( "SX3", .F. )
				SX3->X3_RELACAO := AllTrim( cContNov )
			SX3->( MsUnlock() )
		EndIf
	EndIf

Return
