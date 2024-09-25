#INCLUDE "MNTR920.ch"
#include "Protheus.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR920
Relatorio de Documentos por UF de licenciamento
@author Rafael Diogo Richter
@since 22/03/2007
@version undefined
@table TS0, TS2, TS8, ST9
@type function
@obs Uso SigaMNT
/*/
//---------------------------------------------------------------------
Function MNTR920()

	Local WNREL      := "MNTR920"
	Local LIMITE     := 132                                
	Local aSVArea
	Local cDESC1     :=	STR0001+; //"O relatório permitirá filtrar por documento, filial, período e UF. Totalizará os valores "
	STR0002 //"pagos e a pagar."
	Local cDESC2     := ""
	Local cDESC3     := ""
	Local cSTRING    := "TS2"
	
	Private cCadastro := OemtoAnsi(STR0003) //"Documentos por UF de Licenciamento"
	Private cPerg     := "MNR920"
	Private aPerg     := {}
	Private NOMEPROG := "MNTR920"
	Private TAMANHO  := "G"
	Private aRETURN  := {STR0004,1,STR0005,1,2,1,"",1} //"Zebrado"###"Administracao"
	Private TITULO   := STR0003 //"Documentos por UF de Licenciamento"
	Private nTIPO    := 0
	Private nLASTKEY := 0
	Private CABEC1,CABEC2
	Private aVETINR := {}
	Private lFilial
	Private lGera := .t.
	Private nSizeFil := If(FindFunction("FWSizeFilial"),FwSizeFilial(),Len(TS2->TS2_FILIAL))

	SetKey( VK_F9, { | | NGVersao( "MNTR920" , 2 ) } )//Versão do Fonte

	aSVArea := SM0->(GetArea())

	Pergunte(cPERG,.F.)

	//----------------------------------------------------------------
	//| Envia controle para a funcao SETPRINT                        |
	//----------------------------------------------------------------
	WNREL:=SetPrint(cSTRING,WNREL,cPERG,TITULO,cDESC1,cDESC2,cDESC3,.F.,"")
	If nLASTKEY = 27
		Set Filter To
		DbSelectArea("TS2")
		Return
	EndIf
	SetDefault(aReturn,cSTRING)

	RestArea(aSVArea)

	Processa({|lEND| MNTR920IMP(@lEND,WNREL,TITULO,TAMANHO)},STR0019) //"Processando Registros..."
	Dbselectarea("TS2")

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR920Imp
Chamada do Relatório 
@author Rafael Diogo Richter
@since 22/03/2007
@version undefined
@param lEND, logical
@param WNREL
@param TITULO
@param TAMANHO
@type function
@obs Uso MNTR920
/*/
//---------------------------------------------------------------------
Function MNTR920Imp(lEND,WNREL,TITULO,TAMANHO)
	
	Local nAcu := 0
	Local oTempTable		//Tabela Temporaria
	
	Private li 		 := 80 
	Private m_pag 	 := 1
	Private cRODATXT := ""
	Private nCNTIMPR := 0
	Private nQtd 	 := 0
	Private cTRB	 := GetNextAlias()

	aDBF :=	{{"FILIAL"	, "C", nSizeFil,0},;
			 {"DOCTO"	, "C", 06,0},;
			 {"DTEMIS"	, "D", 08,0},;
			 {"PLACA"	, "C", 08,0},;
			 {"CODBEM"	, "C", 16,0},;
			 {"NOMBEM"	, "C", 30,0},;
			 {"UF"		, "C", 02,0},;
			 {"PARCEL"	, TAMSX3("TS2_PARCEL")[3], TAMSX3("TS2_PARCEL")[1],0},;
			 {"DTPGTO"	, "D", 08,0},;
			 {"DTVENC"	, "D", 08,0},;
			 {"NOTFIS"	, "C", 06,0},;
			 {"VALDOC"	, "N", 09,2}}
 
	//Instancia classe FWTemporaryTable
	oTempTable  := FWTemporaryTable():New( cTRB, aDBF )
	//Cria indices
	oTempTable:AddIndex( "Ind01" ,  {"FILIAL","CODBEM","DOCTO","DTVENC"}  )
	//Cria a tabela temporaria
	oTempTable:Create()
	
	MsgRun(OemToAnsi(STR0021),OemToAnsi(STR0022),{|| MNTR920TMP()}) //"Processando Arquivo..."###"Aguarde"

	If !lGera
		oTempTable:Delete()//Deleta Arquivo temporário 1
		Return .F.
	Endif

	/* 
	0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7
	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	***************************************************************************************************************************************************************************
	Filial            Docto.  Dt.Emissão  Placa     Bem               Nome                            UF  Parc.  Dt.Pgto.    Dt.Venc.    NF           Valor
	***************************************************************************************************************************************************************************

	XXXXXXXXXXXX      XXXXXX  99/99/9999  XXXXXXXX  XXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XX      9  99/99/9999  99/99/9999  XXXXXX  999.999,99
	XXXXXXXXXXXX      XXXXXX  99/99/9999  XXXXXXXX  XXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XX      9  99/99/9999  99/99/9999  XXXXXX  999.999,99
	XXXXXXXXXXXX      XXXXXX  99/99/9999  XXXXXXXX  XXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XX      9  99/99/9999  99/99/9999  XXXXXX  999.999,99
	XXXXXXXXXXXX      XXXXXX  99/99/9999  XXXXXXXX  XXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XX      9  99/99/9999  99/99/9999  XXXXXX  999.999,99
	XXXXXXXXXXXX      XXXXXX  99/99/9999  XXXXXXXX  XXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XX      9  99/99/9999  99/99/9999  XXXXXX  999.999,99

	Total Geral:        9.999.999,99
	/*/

	Cabec1 := STR0023 //"Filial            Docto.  Dt.Emissão  Placa     Bem               Nome                            UF  Parc.  Dt.Pgto.    Dt.Venc.    NF           Valor"
	Cabec2 := ""

	dbSelectArea(cTRB)
	dbSetOrder(1)
	dbGoTop()
	ProcRegua(Reccount())
	While !Eof()
		IncProc()

		NgSomaLi(58)

		@ Li,000		Psay (cTRB)->FILIAL
		@ Li,018		Psay (cTRB)->DOCTO
		@ Li,026		Psay (cTRB)->DTEMIS
		@ Li,038		Psay (cTRB)->PLACA
		@ Li,048		Psay (cTRB)->CODBEM
		@ Li,066		Psay (cTRB)->NOMBEM
		@ Li,098		Psay (cTRB)->UF
		@ Li,106		Psay (cTRB)->PARCEL
		@ Li,109		Psay (cTRB)->DTPGTO
		@ Li,121		Psay (cTRB)->DTVENC
		@ Li,133		Psay (cTRB)->NOTFIS
		@ Li,141		Psay (cTRB)->VALDOC Picture "@E 999,999.99"

		nAcu += (cTRB)->VALDOC

		(cTRB)->(DbSkip())
	End
	NgSomaLi(58)
	NgSomaLi(58)
	@ Li,119		Psay STR0027 //"Total Geral"
	@ Li,139		Psay nAcu Picture "@E 9,999,999.99"


	oTempTable:Delete()// Deleta Tabela temporaria 1

	RODA(nCNTIMPR,cRODATXT,TAMANHO)

	//----------------------------------------------------------------
	//| Devolve a condicao original do arquivo principal             |
	//----------------------------------------------------------------
	RetIndex("TS2")
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
/*/{Protheus.doc} MNTR920TMP
Geracao do arquivo temporario  
@author Rafael Diogo Richter 
@since 22/03/2007
@version undefined
@type function
@obs Uso MNTA920
/*/
//---------------------------------------------------------------------
Function MNTR920TMP()
	Local cAliasQry := ""

	cAliasQry := "TETS2"

	cQuery := "	SELECT TS2.TS2_FILIAL, TS2.TS2_DOCTO, TS2.TS2_DTEMIS, TS2.TS2_PLACA, TS2.TS2_CODBEM, ST9.T9_NOME, "
	cQuery += "	TS2.TS2_UFEMIS, TS2.TS2_PARCEL, TS2.TS2_DTPGTO, TS2.TS2_DTVENC, TS2.TS2_NOTFIS, TS2.TS2_VALOR "
	cQuery += "	FROM " + RetSQLName("TS2") + " TS2 "
	cQuery += "	JOIN " + RetSQLName("ST9") + " ST9 ON ST9.T9_CODBEM = TS2.TS2_CODBEM "
	cQuery += "	AND ST9.D_E_L_E_T_ <> '*' "
	cQuery += "	WHERE TS2.TS2_DTVENC BETWEEN '"+DTOS(mv_par01)+"' AND '"+DTOS(mv_par02)+"'"

	//Inclusão de variável nTamFilial para que seja encontrado o registro com compartilhamento nas tabelas TS2 e TS1.
	nTamFilial := Len(Alltrim(xFilial("TS2")))

	cQuery += "	AND TS2.TS2_FILIAL BETWEEN '"+SubStr(mv_par03,1,nTamFilial)+"' AND '"+SubStr(mv_par04,1,nTamFilial)+"'"

	cQuery += "	AND TS2.TS2_DOCTO BETWEEN '"+mv_par06+"' AND '"+mv_par07+"'"
	cQuery += "	AND TS2.D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY TS2.TS2_FILIAL, TS2.TS2_DOCTO, TS2.TS2_DTVENC "

	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	dbSelectArea(cAliasQry)
	dbGoTop()
	While (cAliasQry)->( !Eof() )

		If !Empty(Mv_Par05) .And. Mv_Par05 <> (cAliasQry)->TS2_UFEMIS
			(cAliasQry)->(dbSkip())
			Loop
		EndIf

		If Mv_par08 == 2
			If STOD((cAliasQry)->TS2_DTVENC) > dDataBase
				(cAliasQry)->(dbSkip())
				Loop
			EndIf
		ElseIf Mv_par08 == 3
			If STOD((cAliasQry)->TS2_DTVENC) <= dDataBase
				(cAliasQry)->(dbSkip())
				Loop
			EndIf
		EndIf

		If Mv_Par09 == 2
			If Empty((cAliasQry)->TS2_DTPGTO)
				(cAliasQry)->(dbSkip())
				Loop
			EndIf
		ElseIf Mv_Par09 == 3
			If !Empty((cAliasQry)->TS2_DTPGTO)
				(cAliasQry)->(dbSkip())
				Loop
			EndIf
		EndIf

		dbSelectArea(cTRB)
		dbSetOrder(1)
		If !dbSeek((cAliasQry)->TS2_FILIAL+(cAliasQry)->TS2_CODBEM+(cAliasQry)->TS2_DOCTO+(cAliasQry)->TS2_DTVENC)
			RecLock((cTRB), .T.)
		Else
			RecLock((cTRB), .F.)
		EndIf
		(cTRB)->FILIAL 	:= (cAliasQry)->TS2_FILIAL
		(cTRB)->DOCTO		:= (cAliasQry)->TS2_DOCTO
		(cTRB)->DTEMIS		:= STOD((cAliasQry)->TS2_DTEMIS)
		(cTRB)->PLACA		:= (cAliasQry)->TS2_PLACA
		(cTRB)->CODBEM		:= (cAliasQry)->TS2_CODBEM
		(cTRB)->NOMBEM		:= SubStr((cAliasQry)->T9_NOME,1,30)
		(cTRB)->UF			:= (cAliasQry)->TS2_UFEMIS
		(cTRB)->PARCEL		:= (cAliasQry)->TS2_PARCEL
		(cTRB)->DTPGTO		:= STOD((cAliasQry)->TS2_DTPGTO)
		(cTRB)->DTVENC		:= STOD((cAliasQry)->TS2_DTVENC)
		(cTRB)->NOTFIS		:= (cAliasQry)->TS2_NOTFIS
		(cTRB)->VALDOC		:= (cAliasQry)->TS2_VALOR
		MsUnLock(cTRB)
		(cAliasQry)->(dbSkip())
	End

	(cAliasQry)->(dbCloseArea())

	dbSelectArea(cTRB)
	dbGoTop()
	If Eof()
		MsgInfo(STR0024,STR0025) //"Não existem dados para montar o Relatório!"###"Atenção!"
		(cTRB)->(dbGoTop())
		lGera := .F.
		Return .F.
	Endif

	(cTRB)->(dbGoTop())

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT920FL
Valida o parametro filial
@author Rafael Diogo Richter
@since 22/03/2007
@version undefined
@param nOpc, numeric
@type function
@obs Uso MNTR920 
/*/
//---------------------------------------------------------------------
Function MNT920FL(nOpc)

	If Empty(mv_par03) .And. mv_par04 = Replicate('Z', nSizeFil)
		Return .T.
	Else
		If nOpc == 1
			lRet := IIf(Empty(Mv_Par03),.t.,ExistCpo('SM0',SM0->M0_CODIGO+Mv_par03))
			If !lRet
				Return .F.
			EndIf
		EndIf

		If nOpc == 2
			If MV_PAR04 = Replicate('Z', nSizeFil)
				Return .T.		
			Endif
			lRet := IIF(ATECODIGO('SM0',SM0->M0_CODIGO+Mv_par03,SM0->M0_CODIGO+Mv_Par04,02),.T.,.F.)
			If !lRet
				Return .F.
			EndIf
		EndIf
	EndIf

Return .T.