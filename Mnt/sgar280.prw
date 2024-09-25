#include "SGAR280.ch"
#include "protheus.ch"

#DEFINE _nVERSAO 2 //Versao do fonte
//---------------------------------------------------------------------
/*/{Protheus.doc} SGAR280()
Relatório IBAMA de Matéria Prima e Insumos 

@author  Elynton Fellipe Bazzo
@since   02/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Function SGAR280()

	Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)
	Local oTempTRB
	
	Private cCadastro := OemtoAnsi(STR0001) //"Relatório IBAMA de Matéria Prima e Insumos"
	Private cPerg	  := STR0002 //"SGAR280"
	Private aPerg	  := {}
	//Variaveis com tamanho dos campos
	Private nTamProd  := If((TAMSX3("B1_COD")[2]) < 1,15,(TAMSX3("B1_COD")[2]))
	Private aGrClass  := {  "6810", "6815", "6820", "6830", "7960", "8110", "8115", "8120", "8125", "8130", "8140", ;
							"8150", "8550", "9010", "9130", "9150", "9210", "9220", "9230", "9240", "9250", "9410", ;
							"9420", "9440", "9480", "9505", "9510", "9515", "9520", "9610", "9615", "9620", "9625", ;
							"9630", "9640", "9645", "9650", "9655", "9660", "9665", "9670", "9680", "9720", "9730", ;
							"9760", "9765", "9766", "9770", "9775", "9820", "9905", "9998", "9999"}
	
	If !NGCADICBASE("B1_ORIGIBA","D","SB1",.F.)
		If !NGINCOMPDIC("UPDSGA25","THYVBJ",.F.)
			Return .F.
		EndIf
	EndIf
	
	If !NGCADICBASE("TEJ_CODIGO","D","TEJ",.F.)
		If !NGINCOMPDIC("UPDSGA30","THYQNJ",.F.)
			Return .F.
		EndIf
	EndIf
	
	Pergunte(cPerg,.F.)
	//Cria TRB
	cTRB := GetNextAlias()

	aDBF := {}
	aAdd(aDBF,{ "ANO"		 , "C" ,04		, 0 })
	aAdd(aDBF,{ "TEJ_CODIGO" , "C" ,15		, 0 })
	aAdd(aDBF,{ "TEJ_DESCR"  , "C" ,30		, 0 })
	aAdd(aDBF,{ "TEJ_NUM"    , "C" ,02		, 0 })
	aAdd(aDBF,{ "B1_COD"	 , "C" ,nTamProd, 0 })
	aAdd(aDBF,{ "B1_DESC"	 , "C" ,60		, 0 })
	aAdd(aDBF,{ "B1_UM"		 , "C" ,02		, 0 })
	aAdd(aDBF,{ "CONSUMO"	 , "N" ,14		, 4 })
	aAdd(aDBF,{ "DEVCONSUMO" , "N" ,14		, 4 })
	aAdd(aDBF,{ "SALDOCONS"	 , "N" ,14		, 4 })
	aAdd(aDBF,{ "B1_PROCED"	 , "C" ,10		, 0 })
	aAdd(aDBF,{ "B1_ARMAZE"	 , "C" ,20		, 0 })
	aAdd(aDBF,{ "B1_ORIGIBA" , "C" ,10		, 0 })

	oTempTRB := FWTemporaryTable():New( cTRB, aDBF )
	oTempTRB:AddIndex( "1", {"TEJ_CODIGO"} )
	oTempTRB:AddIndex( "2", {"B1_DESC"} )
	oTempTRB:Create()
	
	If FindFunction("TRepInUse") .And. TRepInUse()
		//-- Interface de impressao
		oReport := ReportDef()
		oReport:SetLandScape()
		oReport:PrintDialog()
	Else
		SGAR280PAD()
	EndIf
	
	//Deleta arquivo temporário e restaura area
	oTempTRB:Delete()
	
	Dbselectarea( "SB1" )

	NGRETURNPRM(aNGBEGINPRM)
	
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} SGAR280()
Carrega TRB

@author  Elynton Fellipe Bazzo
@since   02/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Static Function SGAR280TRB()

	Local cDataIni 	:= MV_PAR01+"0101"//Monta data Inicio
	Local cDataFim 	:= MV_PAR01+"1231"//Monta data Fim
	Local nCons 	:= nDevCons := nQtde := 0
	dbSelectArea(cTRB)
	ZAP
	
	//Percorre ProdList
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1"))
	ProcRegua(SB1->(RecCount()))
	While !Eof() .and. xFilial("SB1") == SB1->B1_FILIAL
		IncProc()
		cAliasQry := GetNextAlias()
		cQuery := "SELECT COUNT(*) AS CONTAGEM "
		cQuery += "FROM "+RetSqlName("TEM")+" TEM "
		cQuery += "JOIN "+RetSqlName("TEJ")+" TEJ ON(TEJ.D_E_L_E_T_ <> '*' AND TEJ.TEJ_FILIAL = '"+xFilial("TEJ")+"' AND "
		cQuery += "TEJ.TEJ_CODIGO = TEM.TEM_CODIGO AND (TEJ.TEJ_RELATO = '1' OR TEJ.TEJ_RELATO = '3')) "
		cQuery += "WHERE TEM.D_E_L_E_T_ <> '*' AND TEM.TEM_FILIAL = '"+xFilial("TEM")+"' AND TEM.TEM_CODPRO = '"+SB1->B1_COD+"' "
		cQuery := ChangeQuery(cQuery)
		MPSysOpenQuery( cQuery , cAliasQry )
		//Recebe Quantidade
		nQtde := (cAliasQry)->CONTAGEM	
		(cAliasQry)->(dbCloseArea())
		
		//Receb o codigo do ProdList.
		cAliasQry := GetNextAlias()
		cQuery := "SELECT TEJ_CODIGO "
		cQuery += "FROM "+RetSqlName("TEM")+" TEM "
		cQuery += "JOIN "+RetSqlName("TEJ")+" TEJ ON(TEJ.D_E_L_E_T_ <> '*' AND TEJ.TEJ_FILIAL = '"+xFilial("TEJ")+"' AND "
		cQuery += "TEJ.TEJ_CODIGO = TEM.TEM_CODIGO AND (TEJ.TEJ_RELATO = '1' OR TEJ.TEJ_RELATO = '3')) "
		cQuery += "WHERE TEM.D_E_L_E_T_ <> '*' AND TEM.TEM_FILIAL = '"+xFilial("TEM")+"' AND TEM.TEM_CODPRO = '"+SB1->B1_COD+"' "
		cQuery := ChangeQuery(cQuery)
		MPSysOpenQuery( cQuery , cAliasQry )
		nCodProd  := (cAliasQry)->TEJ_CODIGO
		nDescProd := NgSeek("TEJ",(cAliasQry)->TEJ_CODIGO,1,"TEJ_DESCRI")
		cUni	  := TEJ->TEJ_UNIMED
		(cAliasQry)->(dbCloseArea())

		If nQtde > 0 //.and. aScan(aGrClass, {|x| x == SB1->B1_GRCLASS}) > 0
			nCons    := 0
			nDevCons := 0
			
			//Carrega Consumo
			cAliasQry := GetNextAlias()
			cQuery := "SELECT ISNULL(SUM(SD3.D3_QUANT),0) AS CONSUMO "
			cQuery += "FROM "+RetSqlName("SD3")+" SD3 "
			cQuery += "WHERE SD3.D_E_L_E_T_ <> '*' AND SD3.D3_ESTORNO <> 'S' "
			cQuery += "AND SD3.D3_EMISSAO >= '"+cDataIni+"' AND SD3.D3_EMISSAO <= '"+cDataFim+"' AND "
			cQuery += "SD3.D3_COD = '"+SB1->B1_COD+"' AND (SD3.D3_CF = 'RE0' OR SD3.D3_CF = 'RE1') AND "
			cQuery += "SD3.D3_DOC <> 'INVENT' AND SD3.D3_LOCAL >= '01' AND SD3.D3_LOCAL <= '89' "
			cQuery += "AND SD3.D3_FILIAL = '"+xFilial("SB1")+"' "
			cQuery := ChangeQuery(cQuery)
			MPSysOpenQuery( cQuery , cAliasQry )
			//Recebe Quantidade
			If AllTrim(SB1->B1_UM) ==  AllTrim(TEJ->TEJ_UNIMED)
			   cUnidade := SB1->B1_UM
				nCons    := (cAliasQry)->CONSUMO
			ElseIf AllTrim(SB1->B1_SEGUM) == AllTrim(TEJ->TEJ_UNIMED) .AND. !Empty(SB1->B1_CONV)
				cUnidade := SB1->B1_SEGUM
				nCons    := (cAliasQry)->CONSUMO*SB1->B1_CONV
			Else	
				cUnidade := AllTrim(SB1->B1_UM)
				nCons := (cAliasQry)->CONSUMO				
			Endif			
				
			(cAliasQry)->(dbCloseArea())
		
			// Carrega Devolucao Consumo
			cAliasQry := GetNextAlias()
			cQuery := "SELECT ISNULL(SUM(SD3.D3_QUANT),0) AS DEVOLUCAO "
			cQuery += "FROM "+RetSqlName("SD3")+" SD3 "
			cQuery += "WHERE SD3.D_E_L_E_T_ <> '*' AND SD3.D3_ESTORNO <> 'S' "
			cQuery += "AND SD3.D3_EMISSAO >= '"+cDataIni+"' AND SD3.D3_EMISSAO <= '"+cDataFim+"' AND "
			cQuery += "SD3.D3_COD = '"+SB1->B1_COD+"' AND SD3.D3_CF = 'DE0' AND "
			cQuery += "SD3.D3_DOC <> 'INVENT' AND SD3.D3_LOCAL >= '01' AND SD3.D3_LOCAL <= '89' "
			cQuery += "AND SD3.D3_FILIAL = '"+xFilial("SB1")+"' "
			cQuery := ChangeQuery(cQuery)
			MPSysOpenQuery( cQuery , cAliasQry )
			//Recebe Quantidade
			nDevCons := (cAliasQry)->DEVOLUCAO
			(cAliasQry)->(dbCloseArea())

			//Grava registro
			RecLock(cTRB,.T.)
			(cTRB)->ANO		    := MV_PAR01
			(cTRB)->TEJ_CODIGO  := nCodProd
			(cTRB)->TEJ_DESCR   := nDescProd
			(cTRB)->TEJ_NUM     := cUni
			(cTRB)->B1_COD	    := B1_COD
			(cTRB)->B1_DESC		:= AllTrim(SB1->B1_DESC)
			(cTRB)->B1_UM		:= cUnidade
			(cTRB)->CONSUMO		:= nCons
			(cTRB)->DEVCONSUMO	:= nDevCons
			(cTRB)->SALDOCONS	:= nCons - nDevCons
			(cTRB)->B1_ORIGIBA	:= AllTrim(NGRETSX3BOX("B1_ORIGIBA"	,SB1->B1_ORIGIBA))
			(cTRB)->B1_PROCED	:= AllTrim(NGRETSX3BOX("B1_PROCED"	,SB1->B1_PROCED	))
			(cTRB)->B1_ARMAZE	:= AllTrim(NGRETSX3BOX("B1_ARMAZE"	,SB1->B1_ARMAZE	))
			MsUnlock(cTRB)
	    Endif
	    
		dbSelectArea("SB1")
		dbSkip()
	End

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} SGAR280PAD()
Imprime Relatório IBAMA de Matéria Prima e Insumoss 

@author  Elynton Fellipe Bazzo
@since   02/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Static Function SGAR280PAD()

	Local WnRel		:= STR0002 //"SGAR280"
	Local Limite	:= 220
	Local cDesc1	:= STR0001 //"Relatório IBAMA de Matéria Prima e Insumos"
	Local cDesc2	:= ""
	Local cDesc3	:= ""
	Local cString	:= "SB1"
	
	Private NomeProg:= STR0002 //"SGAR280"
	Private Tamanho	:= "G"
	Private aReturn	:= {STR0003,1,STR0004,1,2,1,"",1}
	Private Titulo	:= STR0005 //"Relatório IBAMA - Matéria Prima e Insumos"
	Private nTipo	:= 0
	Private nLastKey:= 0
	Private CABEC1,CABEC2
	
	//----------------------------------------
	// Envia controle para a funcao SETPRINT
	//----------------------------------------
	WnRel:=SetPrint(cString,WnRel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,"")
	
	If nLastKey = 27
		Set Filter To
		DbSelectArea("SB1")
		Return
	EndIf
	SetDefault(aReturn,cString)
	Processa({|lEND| SGAR280Imp(@lEND,WnRel,Titulo,Tamanho)},STR0006) //"Processando Registros..."

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} SGAR280Imp()
Relatório IBAMA de Matéria Prima e Insumos

@author  Elynton Fellipe Bazzo
@since   02/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Static Function SGAR280Imp(lEND,WnRel,Titulo,Tamanho)

	Local cRodaTxt	:= ""
	Local nCntImpr	:= 0
	Local lImp 		:= .F., nLinha,i
	Local cProd		:= ""
	
	Private li 		:= 80 ,m_pag := 1
	Private cabec1	:= STR0007 //"Ano   Cod. ProdList    Descr ProdList                 Unidade"
	Private cabec2	:= ""
	/*
	0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3
	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	***************************************************************************************************************************************************************************************************************************************
	Descrição Produto                                             Un.          Consumos     Dev. Consumos     Sld. Consumos  Procedência  Armazenamento      Origem
	
	***************************************************************************************************************************************************************************************************************************************
	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xx   999,999,999.9999  999,999,999.9999  999,999,999.9999  xxxxxxxxxx   xxxxxxxxxxxxxxxxx  xxxxxxxxx
	*/
	//Carrega TRB
	Processa({|| SGAR280TRB()}, STR0008, STR0009, .T.) //"Processando Registros"
	cCodPro := ""
	aCodPro := 0
	dbSelectArea(cTRB)
	dbGoTop()
	ProcRegua(Recno())
	While !eof()

		IncProc()
		
		NGSomali(58)
		If lImp .And. cCodPro <> (cTRB)->TEJ_CODIGO		
			NGSomali(58) 
			@ Li,000 pSay STR0010 //"_______________________________________________________________________________________________________________________Saldo Consumido (por Un. ProdList):"
			@ Li,154 pSay PADL(Transform(aCodPro,"@E 9,999,999,999.999"),17)
			NGSomali(58)
			NGSomali(58)
		EndIf
		If cCodPro <> (cTRB)->TEJ_CODIGO			  
			@ Li,000 pSay AllTrim((cTRB)->ANO) Picture "@!"
			@ Li,006 pSay AllTrim((cTRB)->TEJ_CODIGO) Picture "@!"
			@ Li,023 pSay AllTrim((cTRB)->TEJ_DESCR) Picture "@!" 
			@ Li,54 pSay AllTrim((cTRB)->TEJ_NUM) Picture "@!"
			NGSomali(58)
			NGSomali(58)
			@ Li,000 pSay STR0011 //"Descr Produto                                         Unidade         Consumos           Dev. Consumos        Sld. Consumos    Procedência  Armazenamento      Origem" 
			NGSomali(58)		
			aCodPro := 0
		EndIf
		lImp := .T.	
		@ Li,000 pSay AllTrim((cTRB)->B1_DESC) Picture "@!"
		@ Li,054 pSay AllTrim((cTRB)->B1_UM) Picture "@!"
		@ Li,062 pSay (cTRB)->CONSUMO Picture "@E 999,999,999.9999"
		@ Li,086 pSay (cTRB)->DEVCONSUMO Picture "@E 999,999,999.9999"
		@ Li,107 pSay (cTRB)->SALDOCONS Picture "@E 999,999,999.9999"
		@ Li,127 pSay AllTrim((cTRB)->B1_PROCED) Picture "@!"
		@ Li,140 pSay AllTrim((cTRB)->B1_ARMAZE) Picture "@!"
		@ Li,164 pSay AllTrim((cTRB)->B1_ORIGIBA) Picture "@!"	                                                      
		dbSelectArea(cTRB)
		cCodPro := (cTRB)->TEJ_CODIGO
		If (cTRB)->B1_UM == (cTRB)->TEJ_NUM
			aCodPro += (cTRB)->SALDOCONS
		EndIf
		dbSkip()
	End
	
	If lImp
		NGSomali(58)
		NGSomali(58) 
		@ Li,000 pSay STR0010 //"_______________________________________________________________________________________________________________________Saldo Consumido (por Un. ProdList):"
		@ Li,154 pSay PADL(Transform(aCodPro,"@E 9,999,999,999.999"),17)
		NGSomali(58)
		NGSomali(58)
	EndIf
	
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
		MsgInfo(STR0012) //"Não existem dados para montar o relatório."
	Endif
	
	//---------------------------------------------------
	// Devolve a condicao original do arquivo principal
	//---------------------------------------------------
	RetIndex("SB1")
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

	oReport := TReport():New(STR0002,cCadastro,cPerg,{|oReport| ReportPrint()},cCadastro) //"SGAR280"
	
	oReport:SetTotalInLine(.F.)
	
	//********************* Secao 1 - Prod Linst.
	oSection0 := TRSection():New (oReport,STR0005, {cTRB} ) //"Relatório IBAMA - Matéria Prima e Insumos" 
	oCell := TRCell():New(oSection0, "ANO"          , cTRB  , STR0017  	, "@!"					, 10 ) //"Ano"
	oCell := TRCell():New(oSection0, "TEJ_CODIGO"   , cTRB  , STR0018  	, "@!"					, 20 ) //"Cod. ProdList"
	oCell := TRCell():New(oSection0, "TEJ_DESCR"    , cTRB  , STR0019  	, "@!"					, 40 ) //"Descr ProdList"
	oCell := TRCell():New(oSection0, "TEJ_NUM"      , cTRB  , STR0020  	, "@!"					, 02 ) //"Un."
	//********************* Secao 1 - Produto. 
	oSection1 := TRSection():New (oReport,"", {cTRB} )  
	oCell := TRCell():New(oSection1, "B1_DESC"		, cTRB  , STR0021  	, "@!"					, 60 ) //"Descr Produto"
	oCell := TRCell():New(oSection1, "B1_UM"	    , cTRB  , STR0020	, "@!"					, 02 ) //"Un."
	oCell := TRCell():New(oSection1, "CONSUMO"		, cTRB  , STR0022   , "@E 999,999,999.9999"	, 20 ) //"Consumos"
	oCell := TRCell():New(oSection1, "DEVCONSUMO"	, cTRB  , STR0023	, "@E 999,999,999.9999"	, 20 ) //"Dev. Consumos"
	oCell := TRCell():New(oSection1, "SALDOCONS"  	, cTRB  , STR0024	, "@E 999,999,999.9999"	, 20 ) //"Sld. Consumos"
	oCell := TRCell():New(oSection1, ""				, cTRB  , ""		, "@!"					, 10 )
	oCell := TRCell():New(oSection1, "B1_PROCED"	, cTRB  , STR0025	, "@!"					, 20 ) //"Procedência"
	oCell := TRCell():New(oSection1, "B1_ARMAZE"	, cTRB  , STR0026	, "@!"					, 30 ) //"Armazenamento"
	oCell := TRCell():New(oSection1, "B1_ORIGIBA"	, cTRB  , STR0027	, "@!"					, 20 ) //"Origem"
	//********************* Secao 2 - Total.
	oSection2 := TRSection():New (oReport,"", {cTRB} )  
	oCel  := TRCell():New (oSection2, " "         	, cTRB	, STR0016	, "@E 999,999,999.9999" , 14, /*lPixel*/, {|| nTotal } ) //"Saldo Consumido (por Un. ProdList)"
	
	
	//Definicao para imprimir os cabecalhos de campos numericos da esquerda para a direita
	oSection1:Cell(STR0013):SetHeaderAlign("RIGHT") //"CONSUMO"
	oSection1:Cell(STR0014):SetHeaderAlign("RIGHT") //"DEVCONSUMO"
	oSection1:Cell(STR0015):SetHeaderAlign("RIGHT") //"SALDOCONS"

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
	Processa({|| SGAR280TRB()}, STR0008, STR0009, .T.) //"Processando Registros"
	
	cCodPro := ""
	nTotal  := 0
	lPrim   := .F.

	//Percorre TRB
	dbSelectArea(cTRB)
	dbGoTop()
	
	oReport:SetMeter(RecCount())

	While !eof()
		oReport:IncMeter()
		If cCodPro <> (cTRB)->TEJ_CODIGO  		
			If lPrim
	      	oSection1:Finish()
	      	oSection2:Init()
				oSection2:PrintLine()
				oSection2:Finish()
				nTotal := 0	
			EndIf
			oSection0:Init()		
			oSection0:PrintLine()
			oSection0:Finish()
			oSection1:Init()
		EndIf
		oSection1:PrintLine()
		dbSelectArea(cTRB)
		If lPrim .And. (cTRB)->TEJ_NUM == (cTRB)->B1_UM
			nTotal += (cTRB)->SALDOCONS
		EndIf		
		cCodPro := (cTRB)->TEJ_CODIGO
		lPrim := .T.
		dbSkip()
	End
	
	If (cTRB)->(RecCount()) > 0	
		If cCodPro == (cTRB)->TEJ_CODIGO .And. (cTRB)->TEJ_UNIMED == (cTRB)->B1_UM
			nTotal += (cTRB)->QUANTIDADE
		EndIf
		oSection1:Finish()	
		If cCodPro <> (cTRB)->TEJ_CODIGO  	
		oSection2:Init()
		oSection2:PrintLine()
		oSection2:Finish()
		nTotal := 0
		EndIf	
	EndIf
			
Return .T.