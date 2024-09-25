#include "SGAR270.ch"
#include "protheus.ch"

#DEFINE _nVERSAO 2 //Versao do fonte
//---------------------------------------------------------------------
/*/{Protheus.doc} SGAR270()
Relatório IBAMA de Licenças Ambientais

@author  Elynton Fellipe Bazzo
@since   02/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Function SGAR270()

	Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)
	Local oTempTRB
	Private cCadastro := OemtoAnsi(STR0001)//"Relatório IBAMA de Licenças Ambientais"
	Private cPerg	  := STR0002 //"SGAR270"
	Private aPerg	  := {}
	//Variaveis com tamanho dos campos
	Private nTamTA0   := If((TAMSX3("TA0_CODLEG")[1]) < 1,12,(TAMSX3("TA0_CODLEG")[1]))
	
	If !NGCADICBASE("TE8_CODLEG","D","TE8",.F.)
		If !NGINCOMPDIC("UPDSGA22","THYNTL",.F.)
			Return .F.
		EndIf
	EndIf
	
	Pergunte(cPerg,.F.)
	//Cria TRB
	cTRB := GetNextAlias()
	
	aDBF := {}
	aAdd(aDBF,{ "ANO"		, "C" ,04		, 0 })
	aAdd(aDBF,{ "TA0_CODLEG", "C" ,nTamTA0	, 0 })
	aAdd(aDBF,{ "TA0_EMENTA", "C" ,40		, 0 })
	aAdd(aDBF,{ "TCK_CODPRO", "C" ,20		, 0 })
	aAdd(aDBF,{ "TCK_ORGAO"	, "C" ,50		, 0 })
	aAdd(aDBF,{ "TA0_DTVIGE", "D" ,08		, 0 })
	aAdd(aDBF,{ "TA0_DTVENC", "D" ,08		, 0 })
	aAdd(aDBF,{ "TA0_SITUAC", "C" ,10		, 0 })
			
	oTempTRB := FWTemporaryTable():New( cTRB, aDBF )
	oTempTRB:AddIndex( "1", {"TA0_CODLEG"} )
	oTempTRB:Create()
	
	If FindFunction("TRepInUse") .And. TRepInUse()
		//-- Interface de impressao
		oReport := ReportDef()
		oReport:SetLandScape()
		oReport:PrintDialog()
	Else
		SGAR270PAD()
	EndIf
	
	//Deleta arquivo temporário e restaura area
	oTempTRB:Delete()
	Dbselectarea( "TA0" )
	
	NGRETURNPRM( aNGBEGINPRM )

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} SGAR270TRB()
Carrega TRB

@author  Elynton Fellipe Bazzo
@since   02/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Static Function SGAR270TRB()

	Local cDataIni := MV_PAR01+"0101"//Monta data Inicio
	Local cDataFim := MV_PAR01+"1231"//Monta data Fim
	Local aHist, lOk
	dbSelectArea(cTRB)
	ZAP
	
	dbSelectArea("TA0")
	dbSetOrder(1)
	dbSeek(xFilial("TA0"))
	ProcRegua(TA0->(RecCount()))
	While !eof() .and. TA0->TA0_FILIAL == xFilial("TA0")
		IncProc()
		lOk   := .F.
		aHist := {"", "", CTOD(""), CTOD(""), "", "", ""}
		//Verifica historico
		dbSelectArea("TE8")
		dbSetOrder(1)
		dbSeek(xFilial("TE8")+TA0->TA0_CODLEG)
		While !eof() .and. TE8->(TE8_FILIAL+TE8_CODLEG) == xFilial("TE8")+TA0->TA0_CODLEG //.and. DTOS(TE8->TE8_DATA) <= cDataFim
			If aHist[1]+aHist[2] <= DTOS(TE8->TE8_DATA)+TE8->TE8_HORA
				aHist := {DTOS(TE8->TE8_DATA), TE8->TE8_HORA, TE8->TE8_DTVIGE, TE8->TE8_DTVENC, TE8->TE8_SITUAC, "", "", TE8->TE8_ORGCER}
			Endif
			dbSelectArea("TE8")
			dbSkip()
		End
		If !Empty(aHist[1])
			//Verifica se as datas de vencimento e Vigencia estao OK
			If (Empty(aHist[3]) .or. DTOS(aHist[3]) <= cDataFim) .and. (Empty(aHist[4]) .or. DTOS(aHist[4]) >= cDataIni)
				lOk := .T.
			Endif
		Endif
		
		If !lOk
			//Verifica se as datas de vencimento e Vigencia estao OK
			If (Empty(TA0->TA0_DTVIGE) .or. DTOS(TA0->TA0_DTVIGE) <= cDataFim) .and. (Empty(TA0->TA0_DTVENC) .or. DTOS(TA0->TA0_DTVENC) >= cDataIni)
				lOK   := .T.
				aHist := {DTOS(dDataBase), Time(), TA0->TA0_DTVIGE, TA0->TA0_DTVENC, TA0->TA0_SITUAC, "", ""}
			Endif
		Endif
		
		//Verifica TCK - Protocolos
		If lOk
			dbSelectArea("TCK")
			dbSetOrder(1)
			dbSeek(xFilial("TCK")+TA0->TA0_CODLEG)
			While !eof() .and. TCK->TCK_FILIAL+TCK->TCK_CODLEG == xFilial("TCK")+TA0->TA0_CODLEG
				If DTOS(TCK->TCK_DTENTR) <= cDataFim .and. TCK->TCK_STATUS == "2" .and. !Empty(TCK->TCK_ORGAO)
					aHist[6] := TCK->TCK_CODPRO
					aHist[7] := TCK->TCK_ORGAO
				Endif
				dbSelectArea("TCK")
				dbSkip()
			End
		Endif
		//Se nao estiver nas datas ou nao obecer o parametro ou orgao vazio
		If (!lOk) .or. (MV_PAR02 == 1 .and. aHist[5] == "2") .or. (MV_PAR02 == 2 .and. aHist[5] <> "2") .or. Empty(aHist[7])
			dbSelectArea("TA0")
			dbSkip()
			Loop
		Endif
		
		RecLock(cTRB,.T.)
		(cTRB)->ANO := MV_PAR01
		(cTRB)->TA0_CODLEG := TA0->TA0_CODLEG
		(cTRB)->TA0_EMENTA := Substr(TA0->TA0_EMENTA,1,40)
		(cTRB)->TCK_CODPRO := AllTrim(aHist[6])
		(cTRB)->TCK_ORGAO  := Substr(aHist[7],1,50)
		(cTRB)->TA0_DTVIGE := aHist[3]
		(cTRB)->TA0_DTVENC := aHist[4]
		(cTRB)->TA0_SITUAC := NGRETSX3BOX("TA0_SITUAC",aHist[5])
		MsUnlock(cTRB)
		dbSelectArea("TA0")
		dbSkip()
	End

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} SGAR270PAD()
Imprime Relatório IBAMA de Licenças Ambientais

@author  Elynton Fellipe Bazzo
@since   02/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Static Function SGAR270PAD()

	Local WnRel		:= STR0002 //"SGAR270"
	Local Limite	:= 220
	Local cDesc1	:= STR0001 //"Relatório IBAMA de Licenças Ambientais"
	Local cDesc2	:= ""
	Local cDesc3	:= ""
	Local cString	:= "TA0"
	
	Private NomeProg:= STR0002 //"SGAR270"
	Private Tamanho	:= "G"
	Private aReturn	:= {STR0003,1,STR0004,1,2,1,"",1}
	Private Titulo	:= STR0005 //"Relatório IBAMA - Licenças Ambientais"
	Private nTipo	:= 0
	Private nLastKey:= 0
	
	//---------------------------------------
	// Envia controle para a funcao SETPRINT
	//---------------------------------------
	WnRel:=SetPrint(cString,WnRel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,"")
	
	If nLastKey = 27
		Set Filter To
		DbSelectArea("SB1")
		Return
	EndIf
	SetDefault(aReturn,cString)
	Processa({|lEND| SGAR270Imp(@lEND,WnRel,Titulo,Tamanho)},STR0006) //"Processando Registros..."

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} SGAR270Imp(lEND,WnRel,Titulo,Tamanho)
Relatório IBAMA de Licenças Ambientais

@author  Elynton Fellipe Bazzo
@since   02/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Static Function SGAR270Imp(lEND,WnRel,Titulo,Tamanho)

	Local cRodaTxt	:= ""
	Local nCntImpr	:= 0
	Local lImp 		:= .F., nLinha,i
	Local cProd		:= ""
	
	Private li 		:= 80 ,m_pag := 1
	Private cabec1	:= STR0007 //"Ano   Licença       Ementa                                    Nº do Processo         Orgão                                               Vigência    Vencimento  Situacao"
	Private cabec2	:= ""
	/*
	0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8        
	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678
	*********************************************************************************************************************************************************************************************
	Ano   Licença       Ementa                                    Nº do Processo         Orgão                                               Vigência    Vencimento  Situacao
	*********************************************************************************************************************************************************************************************
	9999  xxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxx   xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  99/99/9999  99/99/9999  xxxxxxxxxx
	
	*/
	//Carrega TRB
	Processa({|| SGAR270TRB()}, STR0008, STR0009, .T.)

	dbSelectArea(cTRB)
	dbGoTop()
	ProcRegua((cTRB)->(RecCount()))
	While !eof()
		IncProc()
		lImp := .T.
		NGSomaLi(58)
		@ Li,000 pSay (cTRB)->ANO
		@ Li,006 pSay (cTRB)->TA0_CODLEG Picture "@!"
		@ Li,020 pSay (cTRB)->TA0_EMENTA Picture "@!"
		@ Li,062 pSay (cTRB)->TCK_CODPRO Picture "@!"
		@ Li,085 pSay (cTRB)->TCK_ORGAO  Picture "@!"
		@ Li,137 pSay (cTRB)->TA0_DTVIGE Picture "99/99/9999"
		@ Li,149 pSay (cTRB)->TA0_DTVENC Picture "99/99/9999"
		@ Li,161 pSay (cTRB)->TA0_SITUAC Picture "@!"
		dbSelectArea(cTRB)
		dbSkip()
	End
	
	If lImp
		RODA(nCntImpr,cRodaTxt,Tamanho)
		Set Device To Screen
		If aReturn[5] == 1
		   Set Printer To
		   dbCommitAll()
		   OurSpool(WnRel)
		EndIf
		MS_FLUSH()
	Else
		MsgInfo(STR0010) //"Não existem dados para montar o relatório."
	Endif

	//--------------------------------------------------
	// Devolve a condicao original do arquivo principal
	//--------------------------------------------------
	RetIndex("TA0")
	Set Filter To

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()
Define as secoes impressas no relatorio

@author  Elynton Fellipe Bazzo
@since   02/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Static Function ReportDef()

	Static oReport
	Static oSection0
	Static oSection1
	Static oSection2
	Static oCell

	oReport := TReport():New("SGAR270",cCadastro,cPerg,{|oReport| ReportPrint()},cCadastro)
	oReport:SetTotalInLine(.F.)
	oReport:SetLandScape()
	
	//********************* Secao 0 - ProdList
	oSection0 := TRSection():New (oReport,STR0005, {cTRB} ) //"Relatório IBAMA - Licenças Ambientais"
	oCell := TRCell():New(oSection0, "ANO"			, cTRB  , STR0011 , "@!"			, 10	) //"Ano"
	oCell := TRCell():New(oSection0, "TA0_CODLEG"	, cTRB  , STR0012 , "@!"			, 30	) //"Licença"
	oCell := TRCell():New(oSection0, "TA0_EMENTA"	, cTRB  , STR0013 , "@!"			, 70 	) //"Ementa"
	oCell := TRCell():New(oSection0, "TCK_CODPRO"	, cTRB  , STR0014 , "@!"			, 35 	) //"Nº do Processo"
	oCell := TRCell():New(oSection0, "TCK_ORGAO"	, cTRB  , STR0015 , "@!"			, 80	) //"Orgão"
	oCell := TRCell():New(oSection0, "TA0_DTVIGE"	, cTRB  , STR0016 , "99/99/9999"	, 20	) //"Vigência"
	oCell := TRCell():New(oSection0, "TA0_DTVENC"	, cTRB  , STR0017 , "99/99/9999"	, 20	) //"Vencimento"
	oCell := TRCell():New(oSection0, "TA0_SITUAC"	, cTRB  , STR0018 , "@!"			, 20	) //"Situação"

Return oReport
//---------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint()
Imprime o relatorio.

@author  Elynton Fellipe Bazzo
@since   02/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Static Function ReportPrint()

	Local cProd := ""
	//Carrga TRB
	Processa({|| SGAR270TRB()}, STR0008, STR0009, .T.)
	
	//Percorre TRB
	dbSelectArea(cTRB)
	dbGoTop()
	If (cTRB)->(RecCount()) > 0
		oSection0:Init()
	Endif
	oReport:SetMeter(RecCount())
	While !eof()
		oReport:IncMeter()
		oSection0:PrintLine()
		dbSelectArea(cTRB)
		dbSkip()
	End
	If (cTRB)->(RecCount()) > 0
		oSection0:Finish()
	Endif
	
Return .T.