#INCLUDE "SGAR230.CH"
#include "protheus.ch"

#DEFINE _nVERSAO 2 //Versao do fonte
//---------------------------------------------------------------------
/*/{Protheus.doc} SGAR230()
Relatório IBAMA de Certificados Ambientais

@author  Elynton Fellipe Bazzo
@since   02/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Function SGAR230()

	Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)
	Local oTempTRB
	
	Private cCadastro := OemtoAnsi(STR0001)  //"Relatório IBAMA de Certificados Ambientais"
	Private cPerg	  := STR0002  //"SGAR230"	
	Private aPerg	  := {}
	//Variaveis com tamanho dos campos
	Private nTamTA0   := If((TAMSX3("TA0_CODLEG")[1]) < 1,20,(TAMSX3("TA0_CODLEG")[1]))
	
	If !NGCADICBASE("TE8_CODLEG","D","TE8",.F.)
		If !NGINCOMPDIC("UPDSGA22","THYNTL",.F.)
			Return .F.
		EndIf
	EndIf
	
	Pergunte(cPerg,.F.)
	//Cria TRB
	cTRB := GetNextAlias()
	
	aDBF := {}
	aAdd(aDBF,{ "ANO"		, "C" ,04, 0 })
	aAdd(aDBF,{ "TA0_CODLEG", "C" ,nTamTA0, 0 })
	aAdd(aDBF,{ "TA0_EMENTA", "C" ,40, 0 })
	aAdd(aDBF,{ "TA0_TIPCER", "C" ,10, 0 })
	aAdd(aDBF,{ "TA0_ORGCER", "C" ,03, 0 })
	aAdd(aDBF,{ "TA0_NOMCER", "C" ,40, 0 })
	aAdd(aDBF,{ "TA0_DTVIGE", "D" ,08, 0 })
	aAdd(aDBF,{ "TA0_DTVENC", "D" ,08, 0 })
	aAdd(aDBF,{ "TA0_SITUAC", "C" ,10, 0 })
	
	oTempTRB := FWTemporaryTable():New( cTRB, aDBF )
	oTempTRB:AddIndex( "1", {"TA0_CODLEG"} )
	oTempTRB:Create()
	
	If FindFunction("TRepInUse") .And. TRepInUse()
		//-- Interface de impressao
		oReport := ReportDef()
		oReport:SetLandScape()
		oReport:PrintDialog()
	Else
		SGAR230PAD()
	EndIf

	//Deleta arquivo temporário e restaura area
	oTempTRB:Delete()
	Dbselectarea( "TA0" )
	
	NGRETURNPRM(aNGBEGINPRM)
	
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} SGAR230TRB()
Carrega TRB 

@author  Elynton Fellipe Bazzo
@since   02/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Static Function SGAR230TRB()

	Local cDataIni := MV_PAR01+"0101"//Monta data Inicio
	Local cDataFim := MV_PAR01+"1231"//Monta data Fim
	Local aHist, lOk

	dbSelectArea(cTRB)
	ZAP
	
	dbSelectArea( "TA0" )
	dbSetOrder( 01 )
	dbSeek( xFilial( "TA0" ))
	ProcRegua(TA0->(RecCount()))
	While !eof() .and. TA0->TA0_FILIAL == xFilial("TA0")
		IncProc()
		lOk := .F.
		aHist := {"", "", CTOD(""), CTOD(""), "", "", ""}
		//Verifica historico
		dbSelectArea("TE8")
		dbSetOrder(1)
		dbSeek(xFilial("TE8")+TA0->TA0_CODLEG)
		While !eof() .and. TE8->(TE8_FILIAL+TE8_CODLEG) == xFilial("TE8")+TA0->TA0_CODLEG .and. DTOS(TE8->TE8_DATA) <= cDataFim
			If aHist[1]+aHist[2] <= DTOS(TE8->TE8_DATA)+TE8->TE8_HORA
				aHist := {DTOS(TE8->TE8_DATA), TE8->TE8_HORA, TE8->TE8_DTVIGE, TE8->TE8_DTVENC, TE8->TE8_TIPCER, TE8->TE8_ORGCER, TE8->TE8_SITUAC}
			Endif
			dbSelectArea("TE8")
			dbSkip()
		End
		If !Empty(aHist[1])
			//Verifica se as datas de vencimento e vigencia estao OK e se o certificador esta preenchdio
			If (Empty(aHist[3]) .or. DTOS(aHist[3]) <= cDataFim) .and. (Empty(aHist[4]) .or. DTOS(aHist[4]) >= cDataIni) .and. !Empty(aHist[6])
				lOk := .T.
			Endif
		Endif
		
		If !lOk
			//Verifica se as datas de vencimento e vigencia estao OK e se o certificador esta preenchdio
			If (Empty(TA0->TA0_DTVIGE) .or. DTOS(TA0->TA0_DTVIGE) <= cDataFim) .and. ;
				(Empty(TA0->TA0_DTVENC) .or. DTOS(TA0->TA0_DTVENC) >= cDataIni) .and. !Empty(TA0->TA0_ORGCER)
				lOK := .T.
				aHist := {DTOS(dDataBase), Time(), TA0->TA0_DTVIGE, TA0->TA0_DTVENC, TA0->TA0_TIPCER, TA0->TA0_ORGCER, TA0->TA0_SITUAC}
			Endif
		Endif
		
		//Se nao estiver nas datas ou nao obecer o parametro
		If (!lOk) .or. (MV_PAR02 == 1 .and. aHist[7] == "2") .or. (MV_PAR02 == 2 .and. aHist[7] <> "2")
			dbSelectArea("TA0")
			dbSkip()
			Loop
		Endif
		
		RecLock(cTRB,.T.)
		(cTRB)->ANO 		:= MV_PAR01
		(cTRB)->TA0_CODLEG 	:= TA0->TA0_CODLEG
		(cTRB)->TA0_EMENTA 	:= Substr(TA0->TA0_EMENTA,1,40)
		(cTRB)->TA0_TIPCER 	:= NGRETSX3BOX("TA0_TIPCER",aHist[5])
		(cTRB)->TA0_ORGCER 	:= aHist[6]
		(cTRB)->TA0_NOMCER 	:= Substr(NGSEEK("TE9",aHist[6],1,"TE9->TE9_DESCRI"),1,40)
		(cTRB)->TA0_DTVIGE 	:= aHist[3]
		(cTRB)->TA0_DTVENC 	:= aHist[4]
		(cTRB)->TA0_SITUAC 	:= NGRETSX3BOX("TA0_SITUAC",aHist[7])
		MsUnlock(cTRB)
		dbSelectArea( "TA0" )
		dbSkip()
	End

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} SGAR230PAD()                    

Imprime Relatório IBAMA de Certificados Ambientais

@author  Elynton Fellipe Bazzo
@since   02/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Static Function SGAR230PAD()
   
	Local WnRel		 := STR0002  //"SGAR230"
	Local Limite	 := 220
	Local cDesc1	 := STR0001  //"Relatório IBAMA de Certificados Ambientais"
	Local cDesc2	 := ""
	Local cDesc3	 := ""
	Local cString	 := "TA0"
	
	Private NomeProg := STR0002  //"SGAR230"
	Private Tamanho	 := "M"
	Private aReturn	 := {STR0003,1,STR0004,1,2,1,"",1}  //"Zebrado" //"Administracao"
	Private Titulo	 := STR0005  //"Relatório IBAMA - Certificados Ambientais"
	Private nTipo	 := 0
	Private nLastKey := 0

	/*---------------------------------------------------------------------
	||	Envia controle para a funcao SETPRINT   
	---------------------------------------------------------------------*/
	WnRel:=SetPrint(cString,WnRel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,"")

	If nLastKey = 27
		Set Filter To
		DbSelectArea( "SB1" )
		Return
	EndIf
	SetDefault(aReturn,cString)
	Processa({|lEND| SGAR230Imp(@lEND,WnRel,Titulo,Tamanho)},STR0006)  //"Processando Registros..."

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} SGAR230Imp()
Imprime Relatório IBAMA de Certificados Ambientais

@author  Elynton Fellipe Bazzo
@since   02/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Static Function SGAR230Imp(lEND,WnRel,Titulo,Tamanho)

	Local cRodaTxt	:= ""
	Local nCntImpr	:= 0
	Local lImp 		:= .F., nLinha,i
	Local cProd		:= ""
	
	Private li 		:= 80 ,m_pag := 1
	Private cabec1	:= STR0007  //"Ano   Certificado   Ementa                                    Tp. Certificado  Codigo   Nome Certificador                         Vigência    Vencimento  Situação"
	Private cabec2	:= ""
	/*
	0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8        
	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678
	*********************************************************************************************************************************************************************************************
	Ano   Certificado   Ementa                                    Tp. Certificado  Codigo   Nome Certificador                         Vigência    Vencimento  Situação
	*********************************************************************************************************************************************************************************************
	9999  xxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xxxxxxxxxx       xxx      xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  99/99/9999  99/99/9999  xxxxxxxxxx
	
	*/
	//Carrega TRB
	Processa({|| SGAR230TRB()}, STR0008, STR0006, .T.)  //"Aguarde"
	
	dbSelectArea(cTRB)
	dbGoTop()
	ProcRegua((cTRB)->(RecCount()))
	While !eof()
		IncProc()
		lImp := .T.
		NGSomaLi(58)
		@ Li,000 pSay (cTRB)->ANO
		@ Li,006 pSay (cTRB)->TA0_CODLEG Picture "@!"
		@ Li,020 pSay SubStr((cTRB)->TA0_EMENTA,1,20) Picture "@!"
		@ Li,043 pSay (cTRB)->TA0_TIPCER Picture "@!"
		@ Li,060 pSay (cTRB)->TA0_ORGCER Picture "@!"
		@ Li,069 pSay SubStr((cTRB)->TA0_NOMCER,1,30) Picture "@!"
		@ Li,101 pSay (cTRB)->TA0_DTVIGE Picture "99/99/9999"
		@ Li,113 pSay (cTRB)->TA0_DTVENC Picture "99/99/9999"
		@ Li,125 pSay (cTRB)->TA0_SITUAC Picture "@!"
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
		MsgInfo(STR0009)  //"Não existem dados para montar o relatório."
	Endif

	/*---------------------------------------------------------------------
	||Devolve a condicao original do arquivo principal   
	---------------------------------------------------------------------*/
	RetIndex( "TA0" )
	Set Filter To

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()
Define as secoes impressas no relatorio

@author  Elynton Fellipe Bazzo
@since   02/05/2013
@version P11
@return  oReport
/*/
//---------------------------------------------------------------------
Static Function ReportDef()
	
	Static oReport
	Static oSection0
	Static oSection1
	Static oSection2
	Static oCell

	oReport := TReport():New(STR0002,cCadastro,cPerg,{|oReport| ReportPrint()},cCadastro) //"SGAR230"
	
	oReport:SetTotalInLine(.F.)
	
	//********************* Secao 0 - ProdList
	oSection0 := TRSection():New (oReport,STR0005, {cTRB} )  //"Relatório IBAMA - Certificados Ambientais"
	oCell := TRCell():New(oSection0, "ANO"			, cTRB  , STR0010  	, "@!"			, 10 )// "Ano"
	oCell := TRCell():New(oSection0, "TA0_CODLEG"	, cTRB  , STR0011	, "@!"			, 20 )// "Certificado"
	oCell := TRCell():New(oSection0, "TA0_EMENTA"	, cTRB  , STR0012	, "@!"			, 55 )// "Ementa"
	oCell := TRCell():New(oSection0, "TA0_TIPCER"	, cTRB  , STR0013	, "@!"			, 20 )// "Tp. Certificado"
	oCell := TRCell():New(oSection0, "TA0_ORGCER"	, cTRB  , STR0014 	, "@!"			, 10 )// "Codigo"
	oCell := TRCell():New(oSection0, "TA0_NOMCER"	, cTRB  , STR0015	, "@!"			, 50 )// "Nome Certificador"
	oCell := TRCell():New(oSection0, "TA0_DTVIGE"	, cTRB  , STR0016	, "99/99/9999"	, 20 )// "Vigência"
	oCell := TRCell():New(oSection0, "TA0_DTVENC"	, cTRB  , STR0017	, "99/99/9999"	, 20 )// "Vencimento"
	oCell := TRCell():New(oSection0, "TA0_SITUAC"	, cTRB  , STR0018	, "@!"			, 20 )// "Situação"
	
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
	Processa({|| SGAR230TRB()}, STR0008, STR0006, .T.)

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