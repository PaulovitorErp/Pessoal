#INCLUDE "MDTR990.ch"
#Include "Protheus.ch"

#DEFINE _nQTDTIT 15//Quantidade de caracteres utilizados no titulo
#DEFINE _nQTDSEP 75//Quantidade de caracteres de separacao de campos

#DEFINE _cDBCONPAD AdvConnection()

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR990
Geração de relatório de histórico do registro
Uso Genérico

@return

@sample
MDTR990()

@author Jackson Machado
@since 21/08/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDTR990( cAlias, aRecnos, cConexao, cIp, nPorta )

	//---------------------------------------------------
	// Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	//---------------------------------------------------
	Local aNGBEGINPRM := NGBEGINPRM()

	//---------------------
	// Define Variaveis
	//---------------------
	Local _nRet //Retorno do Erro
	Local _nCon //Conexao com o BD
	Local cString
	Local cErro, cTitulo
	Local wnrel   := "MDTR990" //Nome do Relatorio
	Local limite  := 132 // Limite do Relatório
	Local cDesc1  := STR0001//Descricao inicial //"Histórico de Registro"
	Local cDesc2  := STR0002 //Segunda descricao //"Através deste relatório é possível verificar todo o histórico do resgitro desejado."
	Local cDesc3  := "" //Terceira descricao
	Local cParIP  := "" //Parametro com o IP/Porta do servidor audit trail

	Private nomeprog := "MDTR990"//Define o nome do programa
	Private tamanho  := "G"//Define o tamanho do relatorio
	Private aReturn  := { STR0003, 1, STR0004, 2, 2, 1, "", 1 } //Define as propriedades do relatorio //"Zebrado"###"Administracao"
	Private titulo   := STR0001//Define o titulo do relatorio //"Histórico de Registro"
	Private nTipo    := 0 //Define o tipo de acordo com as propriedades
	Private nLastKey := 0 //Variavel de controle dos botoes do SetPrint
	Private cabec1, cabec2 //Cabecalhos

	Default cAlias   := "TM0"
	Default aRecnos  := {{"TM0",{1}}}

	cabec1 := STR0005  //"Usuario                       Campo              Titulo            Operação       Data           Hora       Conteúdo Inicial                                 Conteúdo Alteração"
	cabec2 := " "
	cString := cAlias //Alias princial

	If !MDTRESTRI(cPrograma)
		//-------------------------------------------------
		// Devolve variaveis armazenadas (NGRIGHTCLICK)
		//-------------------------------------------------
		NGRETURNPRM(aNGBEGINPRM)
		Return .F.
	Endif

	If Len(aRecnos) == 0
		MsgStop(STR0006) //"Não há dados para a montagem do relatório."
		Return .F.
	Endif

	//Seta a conexao padrao
	TcConType("TCPIP")

	_nCon := TCLink( cConexao, cIp, nPorta ) //MSSQL/Auditoria ##192.168.0.167 ##7890

	//Eliminar mensagem de erro depois...
	If (_nCon < 0)
		cTitulo := STR0007 + ": " + Str( _nCon, 4, 0 ) //"Falha Conexao na Base - Erro"
		cErro   := cTitulo + ( CHR(13) + CHR(10) )  + ;
						STR0008 + ": " + cIp + ( CHR(13) + CHR(10) ) + ; //"IP"
						STR0009 + ": " + cValToChar( nPorta ) + ( CHR(13) + CHR(10) ) + ; //"Porta"
						STR0010 + ": " + AllTrim( cConexao ) + ( CHR(13) + CHR(10) ) + ; //"DBMS/Base de Dados"
						STR0035 + ": " + ( CHR(13) + CHR(10) ) + ;
						"http://tdn.totvs.com/display/public/PROT/Configurar+Embedded+Audit+Trail" + ( CHR(13) + CHR(10) ) + ;
						STR0011 + ( CHR(13) + CHR(10) ) + "---------------------------------------------" + ; //"Contate o Administrador de Sistemas."
						( CHR(13) + CHR(10) ) + TcSqlError()

		NGMSGMEMO(cTitulo,cErro)

		//Retorna a conexao inicial
		TCSETCONN(_cDBCONPAD)

		Return Nil
	Endif

	TCSETCONN(_nCon)
	//Valida se tabela de auditoria existe
	If (_nRet := TcSqlExec("SELECT * FROM AUDIT_TRAIL")) < 0
		cTitulo := STR0012 + "(" + Str( _nRet, 4) + ")" //"Falha de Banco de Dados ("
		cErro   := cTitulo + ( CHR(13) + CHR(10) )  + ;
						STR0008 + ": " + cIp + ( CHR(13) + CHR(10) ) + ; //"IP"
						STR0009 + ": " + cValToChar( nPorta ) + ( CHR(13) + CHR(10) ) + ; //"Porta"
						STR0010 + ": " + AllTrim( cConexao ) + ( CHR(13) + CHR(10) ) + ; //"DBMS/Base de Dados"
						STR0035 + ": " + ( CHR(13) + CHR(10) ) + ;
						"http://tdn.totvs.com/display/public/PROT/Configurar+Embedded+Audit+Trail" + ( CHR(13) + CHR(10) ) + ;
						STR0011 + ( CHR(13) + CHR(10) ) + "---------------------------------------------" + ;
						( CHR(13) + CHR(10) ) + TcSqlError()

		NGMSGMEMO(cTitulo,cErro)

		//Retorna a conexao inicial
		TCSETCONN(_cDBCONPAD)

		Return Nil
	EndIf

	TCSETCONN(_cDBCONPAD)
	//-----------------------------------------
	// Envia controle para a funcao SETPRINT
	//-----------------------------------------
	wnrel := "MDTR990"

	wnrel := SetPrint(cString,wnrel," ",titulo,cDesc1,cDesc2,cDesc3,.F.,"")

	If nLastKey == 27
		Set Filter to
		//-------------------------------------------------
		// Devolve variaveis armazenadas (NGRIGHTCLICK)
		//-------------------------------------------------
		NGRETURNPRM(aNGBEGINPRM)
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Set Filter to
		//-------------------------------------------------
		// Devolve variaveis armazenadas (NGRIGHTCLICK)
		//-------------------------------------------------
		NGRETURNPRM(aNGBEGINPRM)
		Return
	Endif

	RptStatus({|lEnd| fImprime(@lEnd,wnRel,titulo,tamanho,aRecnos,_nCon,cConexao)},titulo)

	Set Filter To
	Set device to Screen
	If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
	Endif
	MS_FLUSH()


	//Finaliza a conexao
	TCSETCONN(_cDBCONPAD)//Retorna a conexao atual
	TCUNLINK(_nCon)

	//-------------------------------------------------
	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	//-------------------------------------------------
	NGRETURNPRM(aNGBEGINPRM)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fImprime
Imprime o relatório
Uso Genérico

@return

@sample
fImprime()

@author Jackson Machado
@since 21/08/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fImprime(lEnd,wnRel,titulo,tamanho,aRecnos,nConexao,cConexao)

	Local nX,nY,nZ
	Local nPosicao := 000
	Local aCampos  := {}
	Local cAliHist := GetNextAlias()
	Local cCrip    := ""
	Local lTemHist := .F.
	Local cTipo    := ''
	//-------------------------------------------------
	// Contadores de linha e pagina
	//-------------------------------------------------
	Private li := 80, m_pag := 1

	nTipo  := IIF( aReturn[4] == 1, 15, 18 )

	TCSETCONN(_cDBCONPAD)

	//-----------------------------------------------
	// Exemplo do Array de Recnos
	// - aRecnos - Array
	// 		- aRecnos[1] - Tabela (TM0)
	// 		- aRecnos[2] - Array (Recnos)
	// 			- aRecnos[2][1] - Numero do Recno
	//-----------------------------------------------
	For nX := 1 To Len(aRecnos)

		dbSelectArea(aRecnos[nX,1])

		For nY := 1 To Len(aRecnos[nX,2])

			dbSelectArea(aRecnos[nX,1])
			dbGoTo(aRecnos[nX,2,nY])

			aRotSetOpc( aRecnos[nX,1], aRecnos[nX,2,nY], 2 ) //Inicializa variaveis para modo de visualizacao (Ex: INCLUI e ALTERA)

			RegToMemory( aRecnos[nX,1], .F. )  //Inicializa variaveis de memoria (M->)

			dbSelectArea("SX2")
			dbSetOrder(1)
			dbSeek(aRecnos[nX,1])

			SomaLinha()
			@ Li,000 Psay STR0013 + ": " + aRecnos[nX,1] + " - " + AllTrim(X2Nome()) //"Tabela"
			SomaLinha()
			@ Li,000 Psay STR0014 + ": " //"Registro Atual"
			SomaLinha()

			aCampos := NGCAMPNSX3(aRecnos[nX,1])

			For nZ := 1 To Len(aCampos)

				fImpCampo(Li,@nPosicao,aCampos,nZ,aRecnos[nX,1]) //Funcao de impressao dos campos da tabela

				If nPosicao > 145
					nPosicao := 000
					SomaLinha()
				Else
					nPosicao += _nQTDSEP
				Endif

			Next nZ

			SomaLinha()
			@ Li,005 Psay STR0015 //"Histórico"
			SomaLinha()
			@ Li,000 Psay __PrtThinLine()
			fBuscaReg(nConexao,cAliHist,aRecnos[nX,1],aRecnos[nX,2,nY],NGRETX2(aRecnos[nX,1]),cConexao)//Busca todos os registros do Recno

			lTemHist := .F.
			If Select(cAliHist) > 0
				dbSelectArea(cAliHist)
				dbGoTop()
				While (cAliHist)->(!Eof())

					lTemHist := .T.
					SomaLinha()
					cTipo := GetSx3Cache( (cAliHist)->AT_FIELD, 'X3_TIPO' )

					@ Li,000 Psay SubStr((cAliHist)->AT_NAME,1,25)
					@ Li,030 Psay If(!Empty((cAliHist)->AT_FIELD),SubStr((cAliHist)->AT_FIELD,1,10)," ") Picture "@S10"
					@ Li,050 Psay If(!Empty((cAliHist)->AT_FIELD),AllTrim(NGRETTITULO((cAliHist)->AT_FIELD))," ") Picture "@S12"
					If (cAliHist)->AT_OP == "U"
						@ Li,067 Psay STR0016 //"Alteração"
					ElseIf (cAliHist)->AT_OP == "D"
						@ Li,067 Psay STR0017 //"Exclusão"
					ElseIf (cAliHist)->AT_OP == "O"
						@ Li,067 Psay STR0018 //"Operação"
					Else
						@ Li,067 Psay STR0019 //"Inclusão"
					Endif
					@ Li,082 Psay DTOC(STOD((cAliHist)->AT_DATE))
					@ Li,097 Psay (cAliHist)->AT_TIME
					If "_USERGI" $ (cAliHist)->AT_FIELD .OR. "_USERGA" $ (cAliHist)->AT_FIELD .OR.;
							"_USERLGI" $ (cAliHist)->AT_FIELD  .OR. "_USERLGA" $ (cAliHist)->AT_FIELD
						cCrip := SubStr((cAliHist)->AT_CONTENT,1,17)
						@ Li,108 Psay If(!Empty(cCrip),AllTrim(MDTDATALO(cCrip,.F.,.F.))+" - "+DTOC(MDTDATALO(cCrip,.T.,.F.))," ") Picture "@S45"
						cCrip := SubStr((cAliHist)->AT_NEWCONT,1,17)
						@ Li,157 Psay If(!Empty(cCrip),AllTrim(MDTDATALO(cCrip,.F.,.F.))+" - "+DTOC(MDTDATALO(cCrip,.T.,.F.))," ") Picture "@S45"
					Else
						If cTipo == "C" .AND. !Empty( GetSx3Cache( (cAliHist)->AT_FIELD, 'X3_CBOX') )
							@ Li,108 Psay If(!Empty((cAliHist)->AT_CONTENT),AllTrim(NGRETSX3BOX((cAliHist)->AT_FIELD,AllTrim((cAliHist)->AT_CONTENT)))," ") Picture "@S45"
							@ Li,157 Psay If(!Empty((cAliHist)->AT_NEWCONT),AllTrim(NGRETSX3BOX((cAliHist)->AT_FIELD,AllTrim((cAliHist)->AT_NEWCONT)))," ") Picture "@S45"
						ElseIf cTipo == "D"
							@ Li,108 Psay STOD(AllTrim((cAliHist)->AT_CONTENT)) Picture "99/99/9999"
							@ Li,157 Psay STOD(AllTrim((cAliHist)->AT_NEWCONT)) Picture "99/99/9999"
						ElseIf cTipo == "L"
							If AllTrim((cAliHist)->AT_CONTENT) == "T"
								@ Li,108 Psay STR0020 Picture "@S45" //"Verdadeiro"
							Else
								@ Li,108 Psay STR0021 Picture "@S45" //"Falso"
							Endif

							If AllTrim((cAliHist)->AT_NEWCONT) == "T"
								@ Li,157 Psay STR0020 Picture "@S45" //"Verdadeiro"
							Else
								@ Li,157 Psay STR0021 Picture "@S45" //"Falso"
							Endif
						Else
							@ Li,108 Psay If(!Empty((cAliHist)->AT_CONTENT),AllTrim((cAliHist)->AT_CONTENT)," ") Picture "@S45"
							@ Li,157 Psay If(!Empty((cAliHist)->AT_NEWCONT),AllTrim((cAliHist)->AT_NEWCONT)," ") Picture "@S45"
						Endif
					Endif
					dbSelectArea(cAliHist)
					(cAliHist)->(dbSkip())
				End
				(cAliHist)->(dbCloseArea())
			EndIf

			If !lTemHist//Caso nao tenha historico
				SomaLinha()
				@ Li,000 Psay "*** "+STR0022//"Este registro não possui dados auditorados"
			Endif
			//Quebra pagina por registro
			li       := 80
			nPosicao := 000
		Next nY

	Next nX

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fImpCampo
Retorna os campos do SX3 de um determinado ALIAS
Uso Genérico

@return
@sample

@author Jackson Machado
@since 21/08/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fImpCampo(nLin,nPos,aCampos,nZ,cAlias)

	Local nLinTotal := 0
	Local nContLine := 1
	Local cCampo    := ""
	Local cImprime  := ""
	Local cNomCpo   := aCampos[nZ]
	Local cPicture  := X3Picture(cNomCpo)
	Local cTipo     := GetSx3Cache( cNomCpo, 'X3_TIPO' )

	If Empty(cPicture)//Caso campo nao possua picture, utiliza picture generica
		cPicture := "@S55"
	EndIf
	cCampo  := (cAlias)->&(cNomCpo)
	@ nLin,nPos PSay AllTrim( Posicione('SX3', 2, cNomCpo, 'X3Titulo()') )+": " Picture "@S15"
	If GetSx3Cache( cNomCpo, 'X3_CONTEXT' )  <> "V"
		If cTipo == "C"
			If GetSx3Cache( cNomCpo, 'X3_CBOX' )
		   		cImprime := SubStr(cCampo,1,55)
		 	Else
		 		cImprime := SubStr(NGRETSX3BOX(cNomCpo,cCampo),1,55)
		 	Endif
		ElseIf cTipo == "N"
			cImprime := cCampo
		ElseIf cTipo == "D"
			cImprime := DTOC(cCampo)
		ElseIf cTipo == "M"
			nLinTotal := MlCount( cCampo, 55 )
			While nContLine <= nLinTotal
				If nContLine <> 1
					SomaLinha()
				Endif
				nLin := Li
				cImprime  := MemoLine( cCampo, 55, nContLine )
				@ nLin,nPos+_nQTDTIT PSay If(!Empty(cImprime),cImprime," ") Picture "@S55"
				nContLine++
			End
			If nContLine > 1
				nPos := 500 //Caso campo memo ocupe mais de uma linha, estoura o contador de colunas para zerar
			Endif
		ElseIf cTipo == "L"
			If cCampo
				cImprime := STR0020 //"Verdadeiro"
			Else
				cImprime := STR0021 //"Falso"
			Endif
		Endif
	Else
		cImprime := InitPad( GetSx3Cache( cNomCpo, 'X3_RELACAO') )
		If cTipo == "C"
			cImprime := SubStr(cImprime,1,55)
		Endif
	Endif
	If cTipo <> "M"
		@ nLin,nPos+_nQTDTIT Psay If(!Empty(cImprime),cImprime," ") Picture cPicture
	Endif

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fBuscaReg
Busca os Registros de Historico
Uso Genérico

@return

@sample
fRetCampos(0)

@author Jackson Machado
@since 21/08/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fBuscaReg(_nCon,cNewAlias,cAlias,nRecno,cArquivo,cConexao)

	Local _nRet
	Local cQuery := ""
	Local cErro  := "", cTitulo := ""

	//Realiza conexao com o banco de audit trail
	TCSETCONN(_nCon)

	//------------------------------------------------
	// Query para retornar os registros de Historico
	//------------------------------------------------
	cQuery := " SELECT * FROM AUDIT_TRAIL WHERE AT_TABLE = "+ValToSql(cArquivo)+" AND AT_RECID = "+ValToSql(nRecno)

	If (_nRet := TcSqlExec(cQuery)) < 0
		cTitulo := STR0012 + "(" + Str( _nRet, 4) + ")" //"Falha de Banco de Dados"
		cErro   := cTitulo + ( CHR(13) + CHR(10) )  + ;
						STR0008 + ": " + cIp + ( CHR(13) + CHR(10) ) + ; //"IP"
						STR0009 + ": " + cValToChar( nPorta ) + ( CHR(13) + CHR(10) ) + ; //"Porta"
						STR0010 + ": " + AllTrim( cConexao ) + ( CHR(13) + CHR(10) ) + ; //"DBMS/Base de Dados"
						STR0011 + ( CHR(13) + CHR(10) ) + "---------------------------------------------" + ; //"Contate o Administrador de Sistemas."
						( CHR(13) + CHR(10) ) + TcSqlError()

		NGMSGMEMO(cTitulo,cErro)

		//Retorna a conexao inicial
		TCSETCONN(_cDBCONPAD)

		Return Nil
	EndIf

	//-----------------------------------
	// Verifica se o alias esta em uso
	//-----------------------------------
	If Select(cNewAlias) > 0
		dbSelectArea(cNewAlias)
		(cNewAlias)->(dbCloseArea())
	EndIf

	//---------------------------------
	// Cria o alias executando a query
	//---------------------------------
	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery( cQuery, cNewAlias )

	//Retorna a conexao inicial
	TCSETCONN(_cDBCONPAD)

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fBuscaReg
Controle de saltos de paginas e linhas
Uso Genérico

@return

@sample
Somalinha()

@author Jackson Machado
@since 21/08/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function Somalinha()

    Li++
    If Li > 58
        Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo,,.F.)
    EndIf

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT990VSX6
Valida parametro SX6 digitado
Uso Genérico

@return

@sample
MDT990VSX6(.T.)

@author Jackson Machado
@since 21/08/2012
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDT990VSX6(cCampVal,lDBMS)

	Local cConteudo := ""
	Local cIdiom := FwRetIdiom()
	
	Do Case
		Case cIdiom == "pt-br" .Or. cIdiom == "pt-pt"
			cConteudo := "X6_CONTEUD"
		Case cIdiom == "en"
			cConteudo := "X6_CONTENG"
		Case cIdiom == "es"
			cConteudo := "X6_CONTSPA"
	EndCase

	Default lDBMS    := .F.
	Default cCampVal := M->&(cConteudo)

	If !Empty( cCampVal ) .And. !("/" $ cCampVal)
		If lDBMS
			ShowHelpDlg(STR0023,; //"ATENÇÃO"
							{STR0024},2,; //"DBMS/Base de Dados informada no parametro MV_NG2DBAU invalido."
							{STR0025},2) //"Informe no seguinte formanto: DBMS/Base de Dados (MSSQL7/Auditoria)."
			Return .F.
		Else
			ShowHelpDlg(STR0023,; //"ATENÇÃO"
						{STR0026},2,; //"Porta/IP informada no parametro MV_NG2PRIP inválido."
						{STR0027},2) //"Informe no seguinte formanto: IP/PORTA (127.0.0.1/7890)."
			Return .F.
		Endif
	Endif

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT990VDL
Valida a data de inclusao do registro de acordo com a Auditoria
Uso Genérico

@return Logico - Indica se o registro e' valido para o relatorio

@param cAlias - Alias principal
@param nRecno - Valor de Recno
@param dDataVal - Data para validacao

@sample
MDT990VDL( "TM0", 2, '20130117' )

@author Jackson Machado
@since 17/01/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDT990VDL( cAlias, nRecno, dDataVal )

	Local nPos
	Local cFilter, cQuery, cNewAlias := GetNextAlias()
	Local _cErro, _cTitulo
	Local _cDBCONECT
	Local _nCon
	Local cPorta, cIpAud, cPortAud
	Local lRet := .T.

	#IFNDEF TOP
		MsgInfo(STR0034)//"Funcionalidade apenas disponível para ambientes TOP CONNECT."
		Return .F.
	#ENDIF

	If SuperGetMv("MV_MDTPS",.F.,"N") == "S"
		ShowHelpDlg(STR0023,;
					{STR0028},2,;//"Opção não disponível para Prestador de Serviço."
					{STR0029},2)//"Favor contate administrador de sistema."
		Return .F.
	EndIf

	aAlias  := GetArea()
	cFilter := dbFilter()

	If Type("INCLUI") == "L" .AND. INCLUI
		ShowHelpDlg(STR0023,;//"ATENÇÃO"
					{STR0030},2,;//"Opção não disponível no modo de Inclusão."
					{STR0031},2)//"Para acessar esta opção, favor visualizar/alterar/excluir o registro."
		Return .F.
	Endif

	If SuperGetMv("MV_NG2AUDI",.F.,"2") == "2"
		ShowHelpDlg(STR0023,;
					{STR0032},2,;//"Parâmetro de auditoria não ativado."
					{STR0033},2)//"Para utilização deste recurso é necessaria a ativacao do parametro MV_NG2AUDI juntamente com a auditoria de sistema."
		Return .F.
	Endif

	cPorta     := AllTrim(SuperGetMv("MV_NG2PRIP",.F.," "))
	_cDBCONECT := AllTrim(SuperGetMv("MV_NG2DBAU",.F.," "))

	If !MDT990VSX6(cPorta,.F.)
		Return .F.
	ElseIf !MDT990VSX6(_cDBCONECT,.T.)
		Return .F.
	Endif

	nPos     := At("/",cPorta)
	cIpAud   := SubStr(cPorta,1,nPos-1)
	cPortAud := AllTrim(SubStr(cPorta,nPos+1))

	//Seta a conexao padrao
	TcConType("TCPIP")

	_nCon := TCLink( _cDBCONECT, cIpAud, Val(cPortAud) ) //MSSQL/Auditoria ##192.168.0.167 ##7890

	//Eliminar mensagem de erro depois...
	If (_nCon < 0) .Or. (_nRet := TcSqlExec("SELECT * FROM AUDIT_TRAIL")) < 0
		_cTitulo := STR0012 + "(" + Str( _nRet, 4) + ")" //"Falha de Banco de Dados ("
		_cErro   := _cTitulo + ( CHR(13) + CHR(10) ) + ;
						STR0008 + ": " + cIpAud + ( CHR(13) + CHR(10) ) + ;//"IP:"
						STR0009 + ": " + cPortAud + ( CHR(13) + CHR(10) ) + ;//"Porta:"
						STR0010 + ": " + AllTrim(_cDBCONECT) + ( CHR(13) + CHR(10) ) + ;//"DBMS/Base de Dados:"
						STR0035 + ": " + ( CHR(13) + CHR(10) ) + ;
						"http://tdn.totvs.com/display/public/PROT/Configurar+Embedded+Audit+Trail" + ( CHR(13) + CHR(10) ) + ;
						STR0011 + ( CHR(13) + CHR(10) ) + "---------------------------------------------" + ; //"Contate o Administrador de Sistemas."
						( CHR(13) + CHR(10) ) + TcSqlError()

		NGMSGMEMO(_cTitulo,_cErro)

		//Retorna a conexao inicial
		TCSETCONN(AdvConnection())

		Return .F.
	Endif

	//Retorna a conexao inicial
	TCSETCONN(AdvConnection())
	TCUNLINK(_nCon)

	cQuery := " SELECT * FROM AUDIT_TRAIL WHERE AT_TABLE = "+ValToSql( NGRETX2( cAlias ) )+" AND AT_RECID = "+ValToSql( cValToChar( nRecno ) )
	cQuery += " AND AT_OP = 'I' "

	//Elimina o Alias caso existak
	If Select(cNewAlias) > 0
		dbSelectArea(cNewAlias)
		(cNewAlias)->(dbCloseArea())
	EndIf

	//---------------------------------
	// Cria o alias executando a query
	//---------------------------------
	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery( cQuery, cNewAlias )

	dbSelectArea( cNewAlias )
	dbGoTop()
	If (cNewAlias)->( !Eof() ) .AND. (cNewAlias)->AT_DATE < dDataVal
		lRet := .F.
	EndIf
	//Retorna a conexao inicial
	TCSETCONN(AdvConnection())
	If _nCon > 0
		TCUNLINK(_nCon)
	Endif

	(cNewAlias)->( dbCloseArea() )

	RestArea(aAlias)
	If !Empty(cFilter)
		Set Filter To &(cFilter)
	EndIf

Return lRet
