#include "SGAR290.ch"
#include "protheus.ch"

#DEFINE _nVERSAO 2 //Versao do fonte
//---------------------------------------------------------------------
/*/{Protheus.doc} SGAR290()
Relatório IBAMA de Produtos e SubProdutos 

@author  Elynton Fellipe Bazzo
@since   03/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Function SGAR290()
	
	Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)
	Local oTempTRB
	
	Private cCadastro := OemtoAnsi(STR0001) //"Relatório IBAMA de Produtos e SubProdutos"
	Private cPerg	  := STR0002 //"SGAR290"
	Private aPerg	  := {}
		
	If !NGCADICBASE("TEJ_CODIGO","D","TEJ",.F.)
		If !NGINCOMPDIC("UPDSGA30","THYQNJ",.F.)
			Return .F.
		EndIf
	EndIf
	
	Pergunte(cPerg,.F.)
	//Cria TRB
	cTRB := GetNextAlias()
	
	aDBF := {}
	aAdd(aDBF,{ "ANO"		, "C" ,04, 0 })
	aAdd(aDBF,{ "TEJ_CODIGO", "C" ,10, 0 })
	aAdd(aDBF,{ "TEJ_DESCRI", "C" ,30, 0 })
	aAdd(aDBF,{ "TEM_NOMPRO", "C", 30, 0 })
	aAdd(aDBF,{ "QUANTIDADE", "N" ,14, 2 })
	aAdd(aDBF,{ "B1_UM"		, "C" ,02, 0 })
	aAdd(aDBF,{ "TEJ_CAPMAX", "N" ,14, 2 })
	aAdd(aDBF,{ "TEJ_UNIMED", "C" ,02, 0 })
	aAdd(aDBF,{ "TEJ_SIGILO", "C" ,03, 0 })
	aAdd(aDBF,{ "TEJ_TPSIGI", "C" ,25, 0 })
	aAdd(aDBF,{ "TEJ_CODLEG", "C" ,12, 0 })
	aAdd(aDBF,{ "TA0_EMENTA", "C" ,40, 0 })
	aAdd(aDBF,{ "TEJ_INFSI"	, "M" ,10, 0 })

	oTempTRB := FWTemporaryTable():New( cTRB, aDBF )
	oTempTRB:AddIndex( "1", {"TEJ_CODIGO"} )
	oTempTRB:Create()
	
	If FindFunction("TRepInUse") .And. TRepInUse()
		//-- Interface de impressao
		oReport := ReportDef()
		oReport:SetLandScape()
		oReport:PrintDialog()
	Else
		SGAR290PAD()
	EndIf
	
	//Deleta arquivo temporário e restaura area
	oTempTRB:Delete()
	Dbselectarea( "TEJ" )
	
	NGRETURNPRM( aNGBEGINPRM )
	
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} SGAR290TRB()
Carrega TRB

@author  Elynton Fellipe Bazzo
@since   03/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Static Function SGAR290TRB()

	Local cDataIni := MV_PAR01+"0101"//Monta data Inicio
	Local cDataFim := MV_PAR01+"1231"//Monta data Fim
	Local aTotalUn := {}, i, cUnidade := "", nQtd := 0
	dbSelectArea(cTRB)
	ZAP

	//Percorre ProdList
	dbSelectArea("TEJ") //Cadastro Agropesca/Prodlist. 
	dbSetOrder(1)
	dbSeek(xFilial("TEJ"))
	ProcRegua(TEJ->(RecCount()))
	While !Eof() .and. TEJ->TEJ_FILIAL == xFilial("TEJ")
		IncProc()
		//Verifica se o prodlist deve ser impresso
		If TEJ->TEJ_RELATO == "1" .or. TEJ->TEJ_RELATO == "4"
			dbSelectArea("TEJ")
			dbSkip()
			Loop
		Endif
		aTotalUn := {}
		cUnidade := ""
		nQtd := 0
		//Ja adiciona a Unidade de medida do ProdList
		aAdd(aTotalUn, {TEJ->TEJ_UNIMED, nQtd})
		i:=0
		//Percorre produtos da lista
		dbSelectArea("TEM")
		dbSetOrder(1)
		dbSeek(xFilial("TEM")+TEJ->TEJ_CODIGO)
		While !eof() .and. TEM->TEM_FILIAL+TEM->TEM_CODIGO == xFilial("TEM")+TEJ->TEJ_CODIGO
			i++
			//Posiciona no Produto                                                          
			dbSelectArea("SB1")
			dbSetOrder(1) 
			If dbSeek(xFilial("SB1")+TEM->TEM_CODPRO)          
				cAliasQry := GetNextAlias()
				cQuery := "SELECT ISNULL(SUM(SD3.D3_QUANT),0) AS QUANTIDADE "
				cQuery += "FROM "+RetSqlName("SD3")+" SD3 "
				cQuery += "JOIN "+RetSqlName("SF5")+" SF5 ON (SF5.D_E_L_E_T_ <> '*' AND SF5.F5_FILIAL = '"+xFilial("SF5")+"' AND SF5.F5_CODIGO = SD3.D3_TM AND "
				cQuery += "SF5.F5_TIPO = 'P') "
				cQuery += "WHERE SUBSTRING(SD3.D3_CF,1,2) = 'PR'  AND SD3.D_E_L_E_T_ <> '*' AND SD3.D3_ESTORNO = '' "
				cQuery += "AND SD3.D3_FILIAL = '"+xFilial("SD3")+"' AND SD3.D3_EMISSAO >= '"+cDataIni+"' AND SD3.D3_EMISSAO <= '"+cDataFim+"' AND "
				cQuery += "SD3.D3_UM = '"+SB1->B1_UM+"' AND SD3.D3_COD = '"+SB1->B1_COD+"' "
				cQuery := ChangeQuery(cQuery)
				MPSysOpenQuery( cQuery , cAliasQry )
				//Verifica se as unidades de medidas sao iguais			
				If AllTrim(SB1->B1_UM) == AllTrim(TEJ->TEJ_UNIMED)
					cUnidade := AllTrim(SB1->B1_UM)
					nQtd := (cAliasQry)->QUANTIDADE
				ElseIf AllTrim(SB1->B1_SEGUM) == AllTrim(TEJ->TEJ_UNIMED) .AND. !Empty(SB1->B1_CONV)//Faz a conversao para segunda unidade
					cUnidade := AllTrim(SB1->B1_SEGUM)
					nQtd := (cAliasQry)->QUANTIDADE*SB1->B1_CONV
				Else
					cUnidade := AllTrim(SB1->B1_UM)
					nQtd := (cAliasQry)->QUANTIDADE				
				Endif		
				//Grava registro
				RecLock(cTRB,.T.)
				(cTRB)->ANO			:= MV_PAR01
				(cTRB)->TEJ_CODIGO	:= TEJ->TEJ_CODIGO
				(cTRB)->TEJ_DESCRI	:= Substr(TEJ->TEJ_DESCRI,1,30)
				(cTRB)->TEM_NOMPRO	:= NgSeek("SB1",TEM->TEM_CODPRO,1,"B1_DESC")
				(cTRB)->QUANTIDADE	:= nQtd
				(cTRB)->B1_UM		:= If(!EmptY(cUnidade),cUnidade,SB1->B1_UM)
				(cTRB)->TEJ_CAPMAX	:= TEJ->TEJ_CAPMAX
				(cTRB)->TEJ_UNIMED	:= TEJ->TEJ_UNIMED
				//Somente na primeira vez imprime tudo
				(cTRB)->TEJ_SIGILO	:= NGRETSX3BOX("TEJ_SIGILO",TEJ->TEJ_SIGILO)
				(cTRB)->TEJ_TPSIGI	:= NGRETSX3BOX("TEJ_TPSIGI",TEJ->TEJ_TPSIGI)
				(cTRB)->TEJ_CODLEG	:= TEJ->TEJ_CODLEG
				(cTRB)->TA0_EMENTA	:= Substr(NGSEEK("TA0",TEJ->TEJ_CODLEG,1,"TA0_EMENTA"),1,40)
				(cTRB)->TEJ_INFSI	:= TEJ->TEJ_INFSI
				MsUnlock(cTRB)
				cUnidade := ""
				nQtd     := 0
			Endif
			dbSelectArea("TEM")
			dbSkip()
		End
		dbSelectArea("TEJ")
		dbSkip()
	End

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} SGAR290TRB()
Imprime relatório IBAMA de Resíduos Sólidos 

@author  Elynton Fellipe Bazzo
@since   03/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Static Function SGAR290PAD()

	Local WnRel		:= STR0002 //"SGAR290"
	Local Limite	:= 220
	Local cDesc1	:= STR0001 //"Relatório IBAMA de Produtos e SubProdutos"
	Local cDesc2	:= ""
	Local cDesc3	:= ""
	Local cString	:= "TEJ"
	
	Private NomeProg:= STR0002 //"SGAR290"
	Private Tamanho	:= "M"
	Private aReturn	:= {STR0003,1,STR0004,1,2,1,"",1}
	Private Titulo	:= STR0005 //"Relatório IBAMA - Produtos e SubProdutos"
	Private nTipo	:= 0
	Private nLastKey:= 0
	Private CABEC1,CABEC2

	//----------------------------------------
	// Envia controle para a funcao SETPRINT
	//----------------------------------------
	WnRel:=SetPrint(cString,WnRel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,"")
	
	If nLastKey = 27
		Set Filter To
		DbSelectArea("TAX")
		Return
	EndIf
	SetDefault(aReturn,cString)
	Processa({|lEND| SGAR290Imp(@lEND,WnRel,Titulo,Tamanho)},STR0006) //"Processando Registros..."
	
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} SGAR290Imp()
Imprime relatório de FMR x MTR

@author  Elynton Fellipe Bazzo
@since   03/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Static Function SGAR290Imp(lEND,WnRel,Titulo,Tamanho)

	Local cRodaTxt	:= ""
	Local nCntImpr	:= 0
	Local lImp 		:= .F., nLinha,i
	Local cMemo 	:= ""
	
	Private li 		:= 80 ,m_pag := 1
	Private cabec1	:= STR0007 //"Ano   Cód ProdList  Descrição ProdList                Capacidade Instalada  Un  "
	Private cabec2	:= ""
	/*
	0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3
	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	***************************************************************************************************************************************************************************************************************************************
	Ano   Código      Descrição                         Qtde. Produzida Un  Capacidade Instalada Un  Sigilo  Tp. Sigilo                 Legislação    Ementa                        
	***************************************************************************************************************************************************************************************************************************************
	9999  xxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  9,999,999,999.999 TO     9,999,999,999.999 TO  xxx     xxxxxxxxxxxxxxxxxxxxxxxxx  xxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	      Informação Sigilosa: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	*/
	//Carrega TRB
	Processa({|| SGAR290TRB()}, STR0008, STR0009, .T.) //"Processando Registros"
	cCodPro := ""
	aCodPro:= {'','','','','',0}
	dbSelectArea(cTRB)
	dbGoTop()
	ProcRegua(Recno())
	While !eof()
		
		IncProc()
			
		If lImp .And. cCodPro <> (cTRB)->TEJ_CODIGO 		
			cMemo := aCodPro[5]
			If MLCount(cMemo,150) == 0
				nLinha:= 1 		
			Else
				nLinha:= MLCount(cMemo,50)
			EndIf	
			NGSomali(58)					
			For i:= 1 To nLinha
				If i == 1
					NGSomali(58)
					@ Li,000 pSay STR0010 //"Sigilo    Tp. Sigilo                 Legislação    Ementa                                   Informação Sigilosa "
					NGSomali(58)
					@ Li, 000 PSAY aCodPro[1]
					@ Li, 010 PSAY aCodPro[2]
					@ Li, 037 PSAY aCodPro[3]
					@ Li, 051 PSAY aCodPro[4]
				Endif
				@ Li,092 PSAY Memoline(cMemo,30,i)
				If nLinha <> 1 
					NGSomali(58)
				EndIf	
			Next nX			
			NGSomali(58)
			@ Li,000 PSAY STR0011 //"________________________________________________________________________________________ Total (por Un. ProdList):"
			@ Li,114 PSAY PADL(Transform(aCodPro[6],"@E 9,999,999,999.999"),17)
			@ Li,132 PSAY aCodPro[7]
			NGSomali(58)
			aCodPro[6] := 0			
		EndIf			
		NGSomali(58)
		If cCodPro <> (cTRB)->TEJ_CODIGO  	
			@ Li,000 pSay (cTRB)->ANO
			@ Li,006 pSay (cTRB)->TEJ_CODIGO Picture "@!"
			@ Li,020 pSay (cTRB)->TEJ_DESCRI Picture "@!"
			@ Li,057 pSay (cTRB)->TEJ_CAPMAX Picture "@E 9,999,999,999.999"
			@ Li,076 pSay (cTRB)->TEJ_UNIMED Picture "@!"
			NGSomali(58)
			NGSomali(58)
			@ Li,000 pSay STR0012 //"Descr Produto                     Qtde. Produzida  Un  "
			NGSomali(58)
		EndIf	
		lImp := .T.	
		@ Li,000 pSay (cTRB)->TEM_NOMPRO Picture "@!"		
		@ Li,032 pSay (cTRB)->QUANTIDADE Picture "@E 9,999,999,999.999"
		@ Li,051 pSay (cTRB)->B1_UM Picture "@!"	
	
		
		If aCodPro[6] <> 0
			aCodPro:= {(cTRB)->TEJ_SIGILO,(cTRB)->TEJ_TPSIGI,(cTRB)->TEJ_CODLEG,(cTRB)->TA0_EMENTA,(cTRB)->TEJ_INFSI,aCodPro[6],TEJ_UNIMED}
		Else
			aCodPro:= {(cTRB)->TEJ_SIGILO,(cTRB)->TEJ_TPSIGI,(cTRB)->TEJ_CODLEG,(cTRB)->TA0_EMENTA,(cTRB)->TEJ_INFSI,0,TEJ_UNIMED}
		EndIf
			
		dbSelectArea(cTRB)
		cCodPro := (cTRB)->TEJ_CODIGO
		If B1_UM == aCodPro[7]
			aCodPro[6]+= (cTRB)->QUANTIDADE
		EndIf
		dbSkip()	
	End
	
	If lImp		
		cMemo := aCodPro[5]
		nLinha:= MLCount(cMemo,30)
		NGSomali(58)					
		For i:= 1 To nLinha								
			If i == 1
				NGSomali(58)
				@ Li,000 pSay STR0010 //"Sigilo    Tp. Sigilo                 Legislação    Ementa                                   Informação Sigilosa "
				NGSomali(58)
				@ Li, 000 PSAY aCodPro[1]
				@ Li, 010 PSAY aCodPro[2]
				@ Li, 037 PSAY aCodPro[3]
				@ Li, 051 PSAY aCodPro[4]
			Endif				
			@ Li,092 PSAY Memoline(cMemo,50,i)
			NGSomali(58)						
		Next nX
		NGSomali(58)
		NGSomali(58)
		@ Li,000 PSAY STR0011 //"________________________________________________________________________________________ Total (por Un. ProdList):"
		@ Li,114 PSAY PADL(Transform(aCodPro[6],"@E 9,999,999,999.999"),17)
		@ Li,132 PSAY aCodPro[7]
		NGSomali(58)
		aCodPro[6] := 0			
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
		MsgInfo(STR0013) //"Não existem dados para montar o relatório."
	Endif
	
	//---------------------------------------------------
	// Devolve a condicao original do arquivo principal
	//---------------------------------------------------
	RetIndex("TAX")
	Set Filter To

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()
Define as secoes impressas no relatorio

@author  Elynton Fellipe Bazzo
@since   03/05/2013
@version P11
@return  oReport
/*/
//---------------------------------------------------------------------
Static Function ReportDef()

	Static oReport
	Static oSection0
	Static oSection1
	Static oSection2
	Static oSection3
	Static oCell

	oReport := TReport():New(STR0002,cCadastro,cPerg,{|oReport| ReportPrint()},cCadastro) //"SGAR290"
	
	oReport:SetTotalInLine(.F.)
	oReport:SetLandScape()
	
	//********************* Secao 0 - Residuos Solidos
	oSection0 := TRSection():New (oReport,STR0005, {cTRB} ) //"Relatório IBAMA - Produtos e SubProdutos"
	oCell := TRCell():New(oSection0, "ANO"			, cTRB  , STR0014   , "@!"					, 04 	) //"Ano"
	oCell := TRCell():New(oSection0, "TEJ_CODIGO"	, cTRB  , STR0015   , "@!"					, 20 	) //"Cód ProdList"
	oCell := TRCell():New(oSection0, "TEJ_DESCRI"	, cTRB  , STR0016	, "@!"					, 30 	) //"Descrição ProdList"
	oCell := TRCell():New(oSection0, "TEJ_CAPMAX"	, cTRB  , STR0017	, "@E 9,999,999,999.999", 20 	) //"Capacidade Instalada"
	oCell := TRCell():New(oSection0, " "			, cTRB  , " "		, "@!"					, 10 	)
	oCell := TRCell():New(oSection0, "TEJ_UNIMED"	, cTRB  , STR0018	, "@!"					, 10 	) //"Un."
	
	oSection1 := TRSection():New (oReport,"", {cTRB} )
	oCell := TRCell():New(oSection1, "TEJ_SIGILO"	, cTRB  , STR0019	, "@!"					, 03 	) //"Sigilo"
	oCell := TRCell():New(oSection1, "TEJ_TPSIGI"	, cTRB  , STR0020	, "@!"					, 25 	) //"Tp. Sigilo"
	oCell := TRCell():New(oSection1, "TEJ_CODLEG"	, cTRB  , STR0021	, "@!"					, 30 	) //"Legislação"
	oCell := TRCell():New(oSection1, "TA0_EMENTA"	, cTRB  , STR0022	, "@!"					, 50 	) //"Ementa"
	oCell := TRCell():New(oSection1, "TEJ_INFSI"	, cTRB  , STR0023	, "@!"					, 37 	) //"Informção Sigilosa"
	
	oSection2 := TRSection():New (oReport,"", {cTRB} )
	oCell := TRCell():New(oSection2, "TEM_NOMPRO"   , cTRB  , STR0024	, "@!"					, 30 	) //"Descrição Produto"
	oCell := TRCell():New(oSection2, "QUANTIDADE"	, cTRB  , STR0025	, "@E 9,999,999,999.999", 10 	) //"Qtde. Produzida"
   	oCell := TRCell():New(oSection2, " "			, cTRB  , " "		, "@!"					, 10 	)
	oCell := TRCell():New(oSection2, "B1_UM"		, cTRB  , STR0018	, "@!"					, 05 	) //"Un."
	
	oSection3 := TRSection():New (oReport,"", {cTRB} )
	oCel  := TRCell():New (oSection3, " "         , cTRB, STR0026		, "@!" , 10, /*lPixel*/ , {|| nTotal } ) //"Total(por Un. ProdList)"
	

Return oReport
//---------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint()
Imprime o relatorio.

@author  Elynton Fellipe Bazzo
@since   03/05/2013
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Static Function ReportPrint()

	cCodPro := ""
	nTotal  := 0
	lPrim   := .F.
	
	//Carrga TRB
	Processa({|| SGAR290TRB(.T.)}, STR0027, STR0028, .T.) //"Processando Registros"
	
	//Percorre TRB
	dbSelectArea(cTRB)
	dbGoTop()
	oReport:SetMeter(RecCount())
	While !eof()
		oReport:IncMeter()
		If cCodPro <> (cTRB)->TEJ_CODIGO  		
			If lPrim
				oSection2:Finish()	
				If cCodPro <> (cTRB)->TEJ_CODIGO  	
					oSection1:Init()
					(cTRB)->(dbSkip(-1))
					oSection1:PrintLine()
					(cTRB)->(dbSkip())
					oSection1:Finish()
				EndIf						
				oSection3:Init()
				oSection3:PrintLine()
				oSection3:Finish()
				nTotal := 0
			EndIf
			oSection0:Init()		
			oSection0:PrintLine()
			oSection0:Finish()
			oSection2:Init()					
		EndIf
		oSection2:PrintLine()
		dbSelectArea(cTRB)		
		cCodPro := (cTRB)->TEJ_CODIGO
		If lPrim .And. (cTRB)->TEJ_UNIMED == (cTRB)->B1_UM
			nTotal += (cTRB)->QUANTIDADE
		EndIf
		lPrim := .T.
		dbSkip()	
	End
	If (cTRB)->(RecCount()) > 0	
		If cCodPro == (cTRB)->TEJ_CODIGO .And. (cTRB)->TEJ_UNIMED == (cTRB)->B1_UM
			nTotal += (cTRB)->QUANTIDADE
		EndIf
		oSection2:Finish()	
		If cCodPro <> (cTRB)->TEJ_CODIGO  	
		oSection1:Init()
		(cTRB)->(dbSkip(-1))
		oSection1:PrintLine()
		(cTRB)->(dbSkip())
		oSection1:Finish()
		oSection3:Init()
		oSection3:PrintLine()
		oSection3:Finish()
		nTotal := 0
		EndIf
	Endif
	
Return .T.