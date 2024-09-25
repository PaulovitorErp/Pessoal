#include "SGAR250.ch"
#include "protheus.ch"

//-------------------------------------------------------------------------------
/*/{Protheus.doc} SGAR250()
Relatório IBAMA de Fontes Energeticas

@Author: Elynton Fellipe Bazzo
@since: 03/05/2013
@version 110
@return .T.
/*/
//--------------------------------------------------------------------------------
Function SGAR250()

	Local aNGBEGINPRM := NGBEGINPRM()

	Private cCadastro := OemtoAnsi(STR0001) //"Relatório IBAMA de Fontes Energéticas"
	Private cPerg	  := STR0002 //"SGAR250"
	Private oTempTRB
	Private lUpdSGA45 := NGCADICBASE( "TED_CAUTGE", "A", "TED", .F. )

	If !NGCADICBASE("TED_ANO","D","TED",.F.)
		If !NGINCOMPDIC("UPDSGA24","THYPMU",.F.)
			Return .F.
		EndIf
	EndIf

	Pergunte(cPerg,.F.)
	//Cria TRB
	cTRB := GetNextAlias()

	aDBF := TED->(DbStruct())
	aAdd(aDBF, {"TED_BRWTIP","C",30,0})
	aAdd(aDBF, {"UNIDADE"	,"C",2 ,0})
	oTempTRB := FWTemporaryTable():New( cTRB, aDBF )
	oTempTRB:AddIndex( "1", {"TED_ANO","TED_TIPO"} )
	oTempTRB:Create()

	If FindFunction("TRepInUse") .And. TRepInUse()
		//-- Interface de impressao
		oReport := ReportDef()
		oReport:SetLandScape()
		oReport:PrintDialog()
	Else
		SGAR250PAD()
	EndIf

	//Deleta arquivo temporário e restaura area
	oTempTRB:Delete()
	Dbselectarea( "TED" )

	NGRETURNPRM( aNGBEGINPRM )

Return .T.
//-------------------------------------------------------------------------------
/*/{Protheus.doc} SGAR250TRB()
Carrega TRB

@Author: Elynton Fellipe Bazzo
@since: 03/05/2013
@version 110
@return .T.
/*/
//--------------------------------------------------------------------------------
Static Function SGAR250TRB()

	Local i

	dbSelectArea("TED")
	dbSetOrder(1)
	dbSeek(xFilial("TED")+MV_PAR01)
	While !eof() .and. xFilial("TED")+MV_PAR01 == TED->(TED_FILIAL+TED_ANO)
		dbSelectarea(cTRB)
		RecLock(cTRB,.T.)
		For i:=1 to FCount()
			If FieldName(i) == "TED_BRWTIP"
				FieldPut(i, SGAA690BOX(TED->TED_TIPO) )
			ElseIf FieldName(i) == "UNIDADE"
				If TED->TED_TIPO == "8" .or. TED->TED_TIPO == "9" .or. TED->TED_TIPO == "A"//Se nao for Biomassa
					FieldPut(i, "KW")
				Else
					FieldPut(i, "TO")
				Endif
			Else
				FieldPut(i, &("TED->"+FieldName(i)) )
			Endif
		Next i
		MsUnlock(cTRB)
		dbSelectArea("TED")
		dbSkip()
	End

Return .T.
//-------------------------------------------------------------------------------
/*/{Protheus.doc} SGAR250PAD()
Imprime Relatório IBAMA de Fonte Energeticas

@Author: Elynton Fellipe Bazzo
@since: 03/05/2013
@version 110
@return .T.
/*/
//--------------------------------------------------------------------------------
Static Function SGAR250PAD()

	Local WnRel		:= STR0002 //"SGAR250"
	Local Limite	:= 220
	Local cDesc1	:= STR0001 //"Relatório IBAMA de Fontes Energéticas"
	Local cDesc2	:= ""
	Local cDesc3	:= ""
	Local cString	:= "TED"

	Private NomeProg:= STR0002 //"SGAR250"
	Private Tamanho	:= "G"
	Private aReturn	:= {STR0003,1,STR0004,1,2,1,"",1}
	Private Titulo	:= STR0005 //"Relatório IBAMA - Fonte Energéticas"
	Private nTipo	:= 0
	Private nLastKey:= 0
	Private CABEC1,CABEC2

	//---------------------------------------
	// Envia controle para a funcao SETPRINT
	//---------------------------------------
	WnRel:=SetPrint(cString,WnRel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,"")

	If nLastKey = 27
		Set Filter To
		DbSelectArea("TED")
		Return
	EndIf
	SetDefault(aReturn,cString)
	Processa({|lEND| SGAR250Imp(@lEND,WnRel,Titulo,Tamanho)},STR0006)  //"Processando Registros..."

Return .T.
//-------------------------------------------------------------------------------
/*/{Protheus.doc} SGAR250Imp()
Relatório IBAMA de Fontes Energeticas

@Author: Elynton Fellipe Bazzo
@since: 03/05/2013
@version 110
@return .T.
/*/
//--------------------------------------------------------------------------------
Static Function SGAR250Imp(lEND,WnRel,Titulo,Tamanho)

	Local cRodaTxt	:= ""
	Local nCntImpr	:= 0
	Local lImp 		:= .F.

	Private li 		:= 80 ,m_pag := 1
	Private cabec1	:= STR0007 //"Ano   Tipo                                               Auto-Geração                    Rede Pública   Teor Enxofre  Teor Nitrogênio  Teor Cinzas      Quantidade Consumida  Un."
	Private cabec2	:= ""
	/*
	0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3
	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	***************************************************************************************************************************************************************************************************************************************
	Ano   Tipo                                               Auto-Geração                    Rede Pública   Teor Enxofre  Teor Nitrogênio  Teor Cinzas      Quantidade Consumida  Un.

	***************************************************************************************************************************************************************************************************************************************
	9999  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999,999,999,999,999,999,999.99%  999,999,999,999,999,999,999.99%       999.99%          999.99%      999.99%  9,999,999,999,999,999.99  KW

	*/
	//Carrega TRB
	Processa({|| SGAR250TRB()}, STR0008, STR0006, .T.) //"Processando Registros..."

	dbSelectArea( cTRB )
	dbGoTop()
	ProcRegua(Recno())
	While !eof()
		IncProc()
		lImp := .T.
		NGSomali(58)
		@ Li,000 pSay (cTRB)->TED_ANO Picture PesqPict("TED","TED_ANO")
		@ Li,006 pSay (cTRB)->TED_BRWTIP Picture "@!"
		If lUpdSGA45
			@ Li,044 pSay rTrim((cTRB)->TED_CAUTGE) Picture PesqPict("TED","TED_CAUTGE")
			@ Li,068 pSay "%"
			@ Li,077 pSay (cTRB)->TED_CREDPU Picture PesqPict("TED","TED_CREDPU")
		Else
			@ Li,044 pSay (cTRB)->TED_AUTGER Picture PesqPict("TED","TED_AUTGER")
			@ Li,068 pSay "%"
			@ Li,077 pSay (cTRB)->TED_REDPUB Picture PesqPict("TED","TED_REDPUB")
		Endif
		@ Li,101 pSay "%"
		@ Li,109 pSay (cTRB)->TED_TEENXO Picture PesqPict("TED","TED_TEENXO")
		@ Li,115 pSay "%"
		@ Li,126 pSay (cTRB)->TED_TENITR Picture PesqPict("TED","TED_TENITR")
		@ Li,132 pSay "%"
		@ Li,139 pSay (cTRB)->TED_TECINZ Picture PesqPict("TED","TED_TECINZ")
		@ Li,145 pSay "%"
		@ Li,152 pSay (cTRB)->TED_QTCONS Picture PesqPict("TED","TED_QTCONS")
		@ Li,174 pSay (cTRB)->UNIDADE Picture "@!"
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
		MsgInfo(STR0009) //"Não existem dados para montar o relatório."
	Endif

	//--------------------------------------------------
	// Devolve a condicao original do arquivo principal
	//--------------------------------------------------
	RetIndex( "TED" )
	Set Filter To

Return .T.
//-------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()
Define as secoes impressas no relatorio

@Author: Elynton Fellipe Bazzo
@since: 03/05/2013
@version 110
@return oReport
/*/
//--------------------------------------------------------------------------------
Static Function ReportDef()

	Static oReport
	Static oSection0
	Static oSection1
	Static oSection2
	Static oCell

	oReport := TReport():New(STR0002,cCadastro,cPerg,{|oReport| ReportPrint()},cCadastro) //"SGAR250"

	oReport:SetTotalInLine(.F.)

	oSection0 := TRSection():New (oReport,STR0005, {cTRB} ) //"Relatório IBAMA - Fontes Energéticas"
	oCell := TRCell():New(oSection0, "TED_ANO"		, cTRB  , STR0010   	, PesqPict("TED","TED_ANO")		, 04 ) 	//"Ano"
	oCell := TRCell():New(oSection0, "TED_BRWTIP"	, cTRB  , STR0011		, "@!"					   		, 30 ) //"Tipo"
	If lUpdSGA45
		oCell := TRCell():New(oSection0, ("TED_CAUTGE")	, cTRB  , STR0012+" %"	, PesqPict("TED","TED_CAUTGE")	, 30 ) //"Auto-Geração"
   		oCell := TRCell():New(oSection0, ("TED_CREDPU")	, cTRB  , STR0013+" %"	, PesqPict("TED","TED_CREDPU")	, 30 ) //"Rede Pública"
	Else
		oCell := TRCell():New(oSection0, "TED_AUTGER"	, cTRB  , STR0012+" %"	, PesqPict("TED","TED_AUTGER")	, 25 ) //"Auto-Geração"
   		oCell := TRCell():New(oSection0, "TED_REDPUB"	, cTRB  , STR0013+" %"	, PesqPict("TED","TED_REDPUB")	, 25 ) //"Rede Pública"
	Endif
	oCell := TRCell():New(oSection0, "TED_TEENXO"	, cTRB  , STR0014+" %"	, PesqPict("TED","TED_TEENXO")	, 25 ) //"Teor Enxofre"
	oCell := TRCell():New(oSection0, "TED_TENITR"	, cTRB  , STR0015+" %"	, PesqPict("TED","TED_TENITR")	, 25 ) //"Teor Nitrogênio"
	oCell := TRCell():New(oSection0, "TED_TECINZ"	, cTRB  , STR0016+" %"	, PesqPict("TED","TED_TECINZ")	, 25 ) //"Teor Cinzas"
	oCell := TRCell():New(oSection0, "TED_QTCONS"	, cTRB  , STR0017		, PesqPict("TED","TED_QTCONS")	, 25 ) //"Quantidade Consumida"
	oCell := TRCell():New(oSection0, ""				, cTRB  , ""	   		, "@!"							, 10 ) //"Quantidade Consumida"
	oCell := TRCell():New(oSection0, "UNIDADE" 		, cTRB  , STR0019		, "@!"						  	, 02 ) //"Un."

Return oReport
//-------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint()
Imprime o relatorio.

@Author: Elynton Fellipe Bazzo
@since: 03/05/2013
@version 110
@return .T.
/*/
//--------------------------------------------------------------------------------
Static Function ReportPrint()

	//Carrga TRB
	Processa({|| SGAR250TRB()}, STR0008, STR0006, .T.) //"Processando Registros"

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