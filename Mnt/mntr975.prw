#INCLUDE "MNTR975.ch"
#include "Protheus.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR975
Relatorio de Despesas com Fornecedor
@author Rafael Diogo Richter
@since 23/03/2007
@version undefined
@type function
@obs uso SigaMNT
/*/
//---------------------------------------------------------------------
Function MNTR975()
	
	Local WNREL       := "MNTR975"
	Local LIMITE      := 132
	Local cDESC1      :=	STR0001 //"O relatório apresentará os valores das despesas tabulando por serviço, mês e ano"
	Local cDESC2      := ""
	Local cDESC3      := ""
	Local cSTRING     := "TS8"
	Private cCadastro := OemtoAnsi(STR0005) //"Relatório de Despesas com Fornecedor"
	Private cPerg     := "MNR975"
	Private aPerg     := {}
	Private NOMEPROG  := "MNTR975"
	Private TAMANHO   := "G"
	Private aRETURN   := {STR0003,1,STR0004,1,2,1,"",1} //"Zebrado"###"Administracao"
	Private TITULO   := STR0005 //"Relatório de Despesas com Fornecedor"
	Private nTIPO    := 0
	Private nLASTKEY := 0
	Private CABEC1,CABEC2
	Private aVETINR := {}
	Private lFilial
	Private lGera := .T.
	//Alias da Tabela Temporaria	
	Private cTRB	:= GetNextAlias()

	//+-----------------------------------------------------+
	//| Tabelas  | TS8 - Honorarios de Despachante          |
	//|          | SA2 - Fornecedores                       |  
	//|          | ST4 - Servicos                           | 
	//|          | ST9 - Bens   							|
	//+-----------------------------------------------------+

	SetKey( VK_F9, { | | NGVersao( "MNTR975" , 2 ) } )

	Pergunte(cPERG,.F.)

	//+--------------------------------------------------------------+
	//| Envia controle para a funcao SETPRINT                        |
	//+--------------------------------------------------------------+
	WNREL:=SetPrint(cSTRING,WNREL,cPERG,TITULO,cDESC1,cDESC2,cDESC3,.F.,"")
	If nLASTKEY = 27
		Set Filter To
		DbSelectArea("TS8")
		Return
	EndIf
	SetDefault(aReturn,cSTRING)
	Processa({|lEND| MNTR975IMP(@lEND,WNREL,TITULO,TAMANHO)},STR0018) //"Processando Registros..."
	Dbselectarea("TS8")

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR975Imp
Chamada do Relatório 
@author Rafael Diogo Richter
@since 22/03/2007
@version undefined
@param lEND, logical, descricao
@param WNREL, , descricao
@param TITULO, , descricao
@param TAMANHO, , descricao
@type function
@obs MNTR975
/*/
//---------------------------------------------------------------------
Function MNTR975Imp(lEND,WNREL,TITULO,TAMANHO)
	
	Local nAcu := 0
	Local oTempTable                        //Tabela Temporaria
	Local nSizeFil := IIf(FindFunction("FWSizeFilial"), FwSizeFilial(), Len(SA2->A2_FILIAL))
	
	Private cFornecAnt := ""
	Private lFirst     := .T.
	Private cFilAntiga := ""
	Private li         := 80 
	Private m_pag      := 1
	Private cRODATXT   := ""
	Private nCNTIMPR   := 0
	Private nQtd       := 0
	Private nAcuFor    := 0
	Private nAcuFil    := 0

	aDBF :=	{{"FILIAL"	, "C", nSizeFil,0},;
			 {"DTPGTO"	, "D", 08,0},;
			 {"MES"		, "C", 07,0},;
			 {"ANO"		, "C", 04,0},;
			 {"CODSER"	, "C", 06,0},;
			 {"NOMSER"	, "C", 30,0},;
			 {"FORNEC"	, "C", TAMSX3("A2_COD")[1],0},;
			 {"LOJA"	, "C", TAMSX3("A2_LOJA")[1],0},;
			 {"NOMFOR"	, "C", 30,0},;
			 {"CODBEM"	, "C", 16,0},;
			 {"NOMBEM"	, "C", 30,0},;
			 {"PLACA"	, "C", 08,0},;
			 {"CCUSTO"	, "C", TAMSX3("CTT_CUSTO")[1],0},;
			 {"PARCELA"	, "C", 01,0},;        	 
			 {"VALOR"	, "N", 09,2}}

	//Intancia classe FWTemporaryTable
	oTempTable  := FWTemporaryTable():New( cTRB, aDBF ) 
	//Cria indices
	oTempTable:AddIndex( "Ind01" , {"FILIAL","FORNEC","DTPGTO","CODSER"}  )
	//Cria a tabela temporaria
	oTempTable:Create()

	MsgRun(OemToAnsi(STR0020),OemToAnsi(STR0021),{|| MNTR975TMP()}) //"Processando Arquivo..."###"Aguarde"

	If !lGera
		oTempTable:Delete()
		Return
	Endif

	/* 
	0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7
	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	***************************************************************************************************************************************************************************
	Dt.Pgto.    Mês      Ano   Serviço  Nome                            Veículo           Placa     C.Custo               Parcela        Valor
	***************************************************************************************************************************************************************************
	99/99/9999  99/9999  9999  XXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXX  XXXXXXXX  XXXXXXXXXXXXXXXXXXXX        1   999.999,99
	99/99/9999  99/9999  9999  XXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXX  XXXXXXXX  XXXXXXXXXXXXXXXXXXXX        1   999.999,99
	99/99/9999  99/9999  9999  XXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXX  XXXXXXXX  XXXXXXXXXXXXXXXXXXXX        1   999.999,99
	99/99/9999  99/9999  9999  XXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXX  XXXXXXXX  XXXXXXXXXXXXXXXXXXXX        1   999.999,99

	Total Geral:    9.999.999,99
	/*/

	Cabec1 := STR0022 //"Dt.Pgto.    Mês      Ano   Serviço  Nome                            Veículo           Placa     C.Custo               Parcela        Valor"
	Cabec2 := ""

	dbSelectArea(cTRB)
	dbSetOrder(1)
	dbGoTop()
	ProcRegua(Reccount())
	While !Eof()
		IncProc()

		NgSomaLi(58)

		If	cFilAntiga <> (cTRB)->FILIAL
			DbSelectArea("SM0")
			SM0->(DbSetOrder(1))	
			If MsSeek(SM0->M0_CODIGO+(cTRB)->FILIAL)   
				NgSomaLi(58)
				@ Li,000   Psay STR0026 + (cTRB)->FILIAL + " - " + SM0->M0_FILIAL //"Filial: "
				NgSomaLi(58)     
			Endif	
		EndIf               
		cFilAntiga := (cTRB)->FILIAL
		If cFornecAnt <> (cTRB)->NOMFOR
			NgSomaLi(58)
			@ Li,000   Psay STR0027 + AllTrim((cTRB)->FORNEC) + '/' + AllTrim((cTRB)->LOJA) + ' - ' + (cTRB)->NOMFOR //"Fornecedor/Loja: "
			NgSomaLi(58)     
			NgSomaLi(58)
			NgSomaLi(58)
		Endif
		cFornecAnt := (cTRB)->NOMFOR

		@ Li,000		Psay StrZero(DAY((cTRB)->DTPGTO),2)+'/'+StrZero(Month((cTRB)->DTPGTO),2)+'/'+Transf(Year((cTRB)->DTPGTO),'9999')
		@ Li,012		Psay (cTRB)->MES
		@ Li,021		Psay (cTRB)->ANO
		@ Li,027		Psay (cTRB)->CODSER
		@ Li,036		Psay (cTRB)->NOMSER
		@ Li,068		Psay (cTRB)->CODBEM
		@ Li,086		Psay (cTRB)->PLACA
		@ Li,096		Psay (cTRB)->CCUSTO
		@ Li,124		Psay (cTRB)->PARCELA
		@ Li,128		Psay (cTRB)->VALOR Picture "@E 999,999.99"

		nAcu += (cTRB)->VALOR
		nAcuFor += (cTRB)->VALOR
		nAcuFil += (cTRB)->VALOR

		DbSelectArea(cTRB)
		DbSkip()
		MNTR975TOT()
	End

	NgSomaLi(58)
	NgSomaLi(58)
	@ Li,110		Psay STR0023 //"Total Geral"
	@ Li,126		Psay nAcu Picture "@E 9,999,999.99"

	oTempTable:Delete()//Deleta Tabela Temporaria 

	RODA(nCNTIMPR,cRODATXT,TAMANHO)

	//+--------------------------------------------------------------+
	//| Devolve a condicao original do arquivo principal             |
	//+--------------------------------------------------------------+
	RetIndex("TS8")
	Set Filter To
	Set Device To Screen
	If aReturn[5] == 1
		Set Printer To
		dbCommitAll()
		OurSpool(WNREL)
	EndIf
	MS_FLUSH()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR975TMP
Geracao do arquivo temporario  
@author Rafael Diogo Richter
@since 22/03/2007
@version undefined
@type function
@obs MNTA975
/*/
//---------------------------------------------------------------------
Function MNTR975TMP()
	Local cAliasQry := ""

	cAliasQry := "TETS8"

	cQuery := "	SELECT TS8.TS8_FILIAL, TS8.TS8_DTPGTO, TS8.TS8_SERVIC, TS4.TS4_DESCRI, TS8.TS8_FORNEC, SA2.A2_NOME, "
	cQuery += "	TS8.TS8_CODBEM, ST9.T9_NOME, TS8.TS8_PLACA, ST9.T9_CCUSTO, TS8.TS8_VALOR, TS8.TS8_PARCEL, TS8.TS8_LOJA "
	cQuery += "	FROM " + RetSQLName("TS8") + " TS8 "
	cQuery += "	JOIN " + RetSQLName("ST9") + " ST9 ON ST9.T9_FILIAL = '" + xFilial("ST9") + "'"
	cQuery += "	AND ST9.T9_CODBEM = TS8.TS8_CODBEM "
	cQuery += "	AND ST9.T9_TIPMOD BETWEEN '"+mv_par05+"' AND '"+mv_par06+"'"
	cQuery += "	AND ST9.D_E_L_E_T_ <> '*' "
	cQuery += "	JOIN " + RetSQLName("SA2") + " SA2 ON SA2.A2_FILIAL = '" + xFilial("SA2") + "'"
	cQuery += "	AND SA2.A2_COD = TS8.TS8_FORNEC "
	cQuery += "	AND SA2.A2_LOJA = TS8.TS8_LOJA "
	cQuery += "	AND SA2.D_E_L_E_T_ <> '*' "
	cQuery += "	JOIN " + RetSQLName("TS4") + " TS4 ON TS4.TS4_FILIAL = '" + xFilial("TS4") + "'"
	cQuery += "	AND TS4.TS4_CODSDP = TS8.TS8_SERVIC "
	cQuery += "	AND TS4.D_E_L_E_T_ <> '*' "
	cQuery += "	WHERE TS8.TS8_DTPGTO BETWEEN '"+DTOS(mv_par01)+"' AND '"+DTOS(mv_par02)+"'"
	cQuery += "	AND TS8.TS8_FILIAL BETWEEN '"+mv_par03+"' AND '"+mv_par04+"'"
	cQuery += "	AND TS8.TS8_CODBEM BETWEEN '"+mv_par07+"' AND '"+mv_par08+"'"
	cQuery += "	AND TS8.TS8_FORNEC BETWEEN '"+mv_par09+"' AND '"+mv_par10+"'"
	cQuery += "	AND TS8.TS8_SERVIC BETWEEN '"+mv_par11+"' AND '"+mv_par12+"'"
	cQuery += "	AND TS8.D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY TS8.TS8_FILIAL, TS8.TS8_DTPGTO, TS8.TS8_SERVIC, TS8.TS8_FORNEC "

	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	/*
	cAliasQry := GetNextAlias()

	MakeSqlExpr(cPerg)

	BeginSql Alias cAliasQry
	SELECT TS8.TS8_FILIAL, TS8.TS8_DTPGTO, TS8.TS8_SERVIC, ST4.T4_NOME, TS8.TS8_FORNEC, SA2.A2_NOME,
	TS8.TS8_CODBEM, ST9.T9_NOME, TS8.TS8_PLACA, ST9.T9_CCUSTO, TS8.TS8_VALOR
	FROM %Table:TS8% TS8
	JOIN %Table:ST9% ST9 ON ST9.T9_FILIAL = %xFilial:ST9%
	AND ST9.T9_CODBEM = TS8.TS8_CODBEM
	AND ST9.T9_TIPMOD BETWEEN %Exp:mv_par05% AND %Exp:mv_par06%
	AND ST9.%NotDel%
	JOIN %Table:SA2% SA2 ON SA2.A2_FILIAL = %xFilial:SA2%
	AND SA2.A2_COD = TS8.TS8_FORNEC
	AND SA2.A2_LOJA = TS8.TS8_LOJA
	AND SA2.%NotDel%
	JOIN %Table:ST4% ST4 ON ST4.T4_FILIAL = %xFilial:ST4%
	AND ST4.T4_SERVICO = TS8.TS8_SERVIC
	AND ST4.%NotDel%
	WHERE TS8.TS8_DTPGTO BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
	AND TS8.TS8_FILIAL BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
	AND TS8.TS8_CODBEM BETWEEN %Exp:mv_par07% AND %Exp:mv_par08%
	AND TS8.TS8_FORNEC BETWEEN %Exp:mv_par09% AND %Exp:mv_par10%
	AND TS8.TS8_SERVIC BETWEEN %Exp:mv_par11% AND %Exp:mv_par12%
	AND TS8.%NotDel%
	ORDER BY TS8.TS8_FILIAL, TS8.TS8_DTPGTO, TS8.TS8_SERVIC, TS8.TS8_FORNEC
	EndSql
	*/

	dbSelectArea(cAliasQry)
	dbGoTop()

	If Eof()
		MsgInfo(STR0024,STR0025) //"Não existem dados para montar o Relatório!"###"Atenção!"
		(cAliasQry)->(dbCloseArea())
		lGera := .f.
		Return
	Endif

	While (cAliasQry)->( !Eof() )

		dbSelectArea(cTRB)
		dbSetOrder(1)
		RecLock((cTRB), .T.)
		(cTRB)->FILIAL 	:= (cAliasQry)->TS8_FILIAL
		(cTRB)->DTPGTO		:= STOD((cAliasQry)->TS8_DTPGTO)
		(cTRB)->MES			:= StrZero(Month(STOD((cAliasQry)->TS8_DTPGTO)),2)+'/'+Transf(Year(STOD((cAliasQry)->TS8_DTPGTO)),'9999')
		(cTRB)->ANO			:= Transf(Year(STOD((cAliasQry)->TS8_DTPGTO)),'9999')
		(cTRB)->CODSER		:= (cAliasQry)->TS8_SERVIC
		(cTRB)->NOMSER		:= SubStr((cAliasQry)->TS4_DESCRI,1,30)
		(cTRB)->FORNEC		:= (cAliasQry)->TS8_FORNEC
		(cTRB)->LOJA		:= (cAliasQry)->TS8_LOJA
		(cTRB)->NOMFOR		:= SubStr((cAliasQry)->A2_NOME,1,30)
		(cTRB)->CODBEM		:= (cAliasQry)->TS8_CODBEM
		(cTRB)->NOMBEM		:= SubStr((cAliasQry)->T9_NOME,1,30)
		(cTRB)->PLACA		:= (cAliasQry)->TS8_PLACA
		(cTRB)->CCUSTO		:= (cAliasQry)->T9_CCUSTO
		(cTRB)->PARCELA	:= (cAliasQry)->TS8_PARCEL
		(cTRB)->VALOR		:= (cAliasQry)->TS8_VALOR

		MsUnLock(cTRB)
		(cAliasQry)->(dbSkip())
	End

	(cAliasQry)->(dbCloseArea())

	dbSelectArea(cTRB)
	dbGoTop()
	If Eof()
		MsgInfo(STR0024,STR0025) //"Não existem dados para montar o Relatório!"###"Atenção!"
		(cTRB)->(dbGoTop())
		Return .F.
	Endif

	(cTRB)->(dbGoTop())

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT975FL
Valida o parametro filial
@author Rafael Diogo Richter
@since 22/03/2007
@version undefined
@param nOpc, numeric, descricao
@type function
@obs uso MNTR975
/*/
//---------------------------------------------------------------------
Function MNT975FL(nOpc)

	If (Empty(mv_par03) .And. mv_par04 = 'ZZ')
		Return .t.
	Else
		If nOpc == 1
			lRet := IIf(Empty(Mv_Par03),.t.,ExistCpo('SM0',SM0->M0_CODIGO+Mv_par03))
			If !lRet
				Return .f.
			EndIf
		EndIf

		If nOpc == 2
			If mv_par04 = 'ZZ'
				Return .t.
			Endif
			lRet := IIF(ATECODIGO('SM0',SM0->M0_CODIGO+Mv_par03,SM0->M0_CODIGO+Mv_Par04,02),.T.,.F.)
			If !lRet
				Return .F.
			EndIf
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR975TOT
Totalizador por Fornecedor do campo Valor 
@author Marcos Wagner Junior
@since 21/02/2008
@version undefined
@type function
@obs MNTR975
/*/
//---------------------------------------------------------------------
Function MNTR975TOT()

	If Eof() .OR. cFornecAnt != (cTRB)->NOMFOR .OR. cFilAntiga != (cTRB)->FILIAL
		NgSomaLi(58)
		NgSomaLi(58)
		@ Li,103		Psay STR0028 //"Total do Fornecedor: "
		@ Li,126		Psay nAcuFor Picture "@E 9,999,999.99"
		nAcuFor := 0
		NgSomaLi(58)
		If Eof() .OR. cFilAntiga != (cTRB)->FILIAL
			@ Li,103		Psay STR0029 //"Total da Filial: "
			@ Li,126		Psay nAcuFil Picture "@E 9,999,999.99"
			nAcuFil := 0
		Endif
	Endif

Return .T.