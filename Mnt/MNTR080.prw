#Include "Protheus.ch"
#Include "MNTR080.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR080
Relatório de Idade Média da Frota

@author Éwerton Cercal
@since 23/07/15
@return .T. - Lógico
/*/
//---------------------------------------------------------------------
Function MNTR080()

	//------------------------------------
	//	Armazena variáveis para devolução
	//------------------------------------
	Local aNGBeginPRM	:= NGBeginPRM()
	Local oReport

	// A partir do release 12.1.33, o parâmetro MV_NGMNTFR será descontinuado
	// Haverá modulo específico para a gestão de Frotas no padrão do produto
	Local lFrota  := IIF( FindFunction('MNTFrotas'), MNTFrotas(), GetNewPar('MV_NGMNTFR','N') == 'S' )
	Local lImpRel := .T.

	Private nSizeFil := TamSX3( "T9_FILIAL" )[1]
	Private nSizeFam := TamSX3( "T6_CODFAMI" )[1]

	// Variaveis utilizadas SX1
	Private aPerg	:= {}
	Private cPerg	:= "MNTR080"

	// Variáveis utilizadas TRB Principal
	Private aDBFFrota	:= {}
	Private cTRBFrota	:= GetNextAlias() //Alias Tab. Temporária
	Private oArqFrota //Obj. Tabela Temporária

	Private aFamilia	:= {}

	If !lFrota

		If GetRPORelease() < '12.1.033'

			//-------------------------------------------------------------------------
			// Este relatório só pode ser utilizado quando o Frota estiver habilitado!
			// Configure o parâmetro MV_NGMNTFR como S (Sim) caso queira utilizar o relatório.
			//-------------------------------------------------------------------------
			ShowHelpDlg( "NGATENCAO", {STR0018}, 1, {STR0019}, 1 )

		Else

			//-------------------------------------------------------------------------
			// Este relatório só pode ser utilizado no módulo de Gestão de Frotas(95).
			// Acesse o módulo de Gestão de Frotas caso queira utilizar este relatório.
			//-------------------------------------------------------------------------
			ShowHelpDlg( "NGATENCAO", {STR0038}, 1, {STR0039}, 1 )
			
		EndIf

		Return .F.

	EndIf

	/*--------------------------------------------------\
	|	Variáveis utilizadas para parâmetros			|
	|	mv_par01     // De  FILIAL						|
	|	mv_par02     // Até FILIAL						|
	|	mv_par03     // De  Família						|
	|	mv_par04     // Até Família						|
	|	mv_par05     // De Modelo						|
	|	mv_par06     // Até Modelo						|
	\--------------------------------------------------*/

	If Pergunte( cPerg, .T. )
		//TRB que armazena os veículos e suas datas de compras
		//para cálculo de idade da frota
		aDBFFrota := {	{"FILIAL", "C", nSizeFil, 0 },;
						{"TEMPO" , "C", 10, 0 },;
						{"DESTMP", "C", 20, 0 },;
						{"FAM01" , "N", 10, 0 },;
						{"FAM02" , "N", 10, 0 },;
						{"FAM03" , "N", 10, 0 },;
						{"FAM04" , "N", 10, 0 },;
						{"FAM05" , "N", 10, 0 },;
						{"FAM06" , "N", 10, 0 },;
						{"FAM07" , "N", 10, 0 },;
						{"TOTTMP", "N", 10, 0 }}

		//Cria Tabela Temporária
		oArqFrota	:= NGFwTmpTbl(cTRBFrota,aDBFFrota,{{ "FILIAL","TEMPO"},{"FILIAL","TEMPO","DESTMP"}})

		Processa( { |lEnd| MNR080ST9(@lImpRel) }, STR0017 )	//"Processando Idade da Frota... Aguarde..."

		If lImpRel
			oReport := ReportDef()
			oReport:SetLandscape() //Default Paisagem
			oReport:PrintDialog()
		EndIf
	EndIf

	//---------------------------------
	//	Devolve variáveis armazenadas
	//---------------------------------
	NGReturnPRM(aNGBeginPRM)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Define as seções impressas no relatório.

@author Bruno Lobo de Souza
@since 11/03/16
@version 1.0
@return oReport
/*/
//---------------------------------------------------------------------
Static Function ReportDef()

	Local oReport
	Local oSection

	//Variaveis de totalizadores.
	Private nTotFam01, nTotFam02, nTotFam03, nTotFam04, nTotFam05, nTotFam06, nTotFam07
	Private nMedFam01, nMedFam02, nMedFam03, nMedFam04, nMedFam05, nMedFam06, nMedFam07
	Private cIdaFam01, cIdaFam02, cIdaFam03, cIdaFam04, cIdaFam05, cIdaFam06, cIdaFam07

	dbSelectArea( cTRBFrota )
	dbSetOrder( 2 )

	// Objeto para construção do relatorio
	oReport  := TReport():New( "MNTR080", "",, { |oReport| ReportPrint( oReport ) } )
	oReport:SetTotalInLine( .F. )

	//Seção principal
	oSection1 := TRSection():New( oReport, "Filial",{ cTRBFrota, "SM0" } )
	TRCell():New( oSection1, "FILIAL", cTRBFrota, STR0021,/*Picture*/, nSizeFil )
	TRCell():New( oSection1,"", , "",/*Picture*/, 100, , {|| FWFILIALNAME(, (cTRBFrota)->FILIAL ) } )

	oSection2 := TRSection():New(oReport,"Bens",{cTRBFrota,"ST9"})
	oSection2:SetHeaderBreak() // sempre que houver quebra imprime o cabeçalho da seção
		oCell := TRCell():New( oSection2, "DESTMP",  cTRBFrota, STR0014,	"@!", 30 )
		oCell := TRCell():New( oSection2, "FAM01",  cTRBFrota, /*cTitle*/,	"@E 9,999,999,999", 25 )
		oCell := TRCell():New( oSection2, "FAM02",  cTRBFrota, /*cTitle*/,	"@E 9,999,999,999", 25 )
		oCell := TRCell():New( oSection2, "FAM03",  cTRBFrota, /*cTitle*/,	"@E 9,999,999,999", 25 )
		oCell := TRCell():New( oSection2, "FAM04",  cTRBFrota, /*cTitle*/,	"@E 9,999,999,999", 25 )
		oCell := TRCell():New( oSection2, "FAM05",  cTRBFrota, /*cTitle*/,	"@E 9,999,999,999", 25 )
		oCell := TRCell():New( oSection2, "FAM06",  cTRBFrota, /*cTitle*/,	"@E 9,999,999,999", 25 )
		oCell := TRCell():New( oSection2, "FAM07",  cTRBFrota, /*cTitle*/,	"@E 9,999,999,999", 25 )
		oCell := TRCell():New( oSection2, "TOTTMP", cTRBFrota, STR0031,		"@E 9,999,999,999", 10 )

		oSection2:Cell("FAM01"):SetHeaderAlign("RIGHT")
		oSection2:Cell("FAM02"):SetHeaderAlign("RIGHT")
		oSection2:Cell("FAM03"):SetHeaderAlign("RIGHT")
		oSection2:Cell("FAM04"):SetHeaderAlign("RIGHT")
		oSection2:Cell("FAM05"):SetHeaderAlign("RIGHT")
		oSection2:Cell("FAM06"):SetHeaderAlign("RIGHT")
		oSection2:Cell("FAM07"):SetHeaderAlign("RIGHT")
		oSection2:Cell("TOTTMP"):SetHeaderAlign("RIGHT")

		//Totalizadores

		//#Total de Bens#
		oBreak1 := TRBreak():New(oSection2,".T.",STR0028,.F.)
		TRFunction():New(oSection2:Cell("FAM01"),nTotFam01,"SUM",oBreak1,/*cTitle*/,"@E 9,999,999,999",/*{ | | nTot / nBens }*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/,/*oSection1*/)
		TRFunction():New(oSection2:Cell("FAM02"),nTotFam02,"SUM",oBreak1,/*cTitle*/,"@E 9,999,999,999",/*{ | | nTot / nBens }*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/,/*oSection1*/)
		TRFunction():New(oSection2:Cell("FAM03"),nTotFam03,"SUM",oBreak1,/*cTitle*/,"@E 9,999,999,999",/*{ | | nTot / nBens }*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/,/*oSection1*/)
		TRFunction():New(oSection2:Cell("FAM04"),nTotFam04,"SUM",oBreak1,/*cTitle*/,"@E 9,999,999,999",/*{ | | nTot / nBens }*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/,/*oSection1*/)
		TRFunction():New(oSection2:Cell("FAM05"),nTotFam05,"SUM",oBreak1,/*cTitle*/,"@E 9,999,999,999",/*{ | | nTot / nBens }*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/,/*oSection1*/)
		TRFunction():New(oSection2:Cell("FAM06"),nTotFam06,"SUM",oBreak1,/*cTitle*/,"@E 9,999,999,999",/*{ | | nTot / nBens }*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/,/*oSection1*/)
		TRFunction():New(oSection2:Cell("FAM07"),nTotFam07,"SUM",oBreak1,/*cTitle*/,"@E 9,999,999,999",/*{ | | nTot / nBens }*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/,/*oSection1*/)

		//#Média (Anos)#
		oBreak2 := TRBreak():New(oSection2,".T.",STR0029,.F.)
		TRFunction():New(oSection2:Cell("FAM01"),nMedFam01,"ONPRINT",oBreak2,/*cTitle*/,"@E 9,999,999,999.99",{ | | (nMedFam01/nTotFam01)/12 },.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/,/*oSection1*/)
		TRFunction():New(oSection2:Cell("FAM02"),nMedFam02,"ONPRINT",oBreak2,/*cTitle*/,"@E 9,999,999,999.99",{ | | (nMedFam02/nTotFam02)/12 },.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/,/*oSection1*/)
		TRFunction():New(oSection2:Cell("FAM03"),nMedFam03,"ONPRINT",oBreak2,/*cTitle*/,"@E 9,999,999,999.99",{ | | (nMedFam03/nTotFam03)/12 },.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/,/*oSection1*/)
		TRFunction():New(oSection2:Cell("FAM04"),nMedFam04,"ONPRINT",oBreak2,/*cTitle*/,"@E 9,999,999,999.99",{ | | (nMedFam04/nTotFam04)/12 },.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/,/*oSection1*/)
		TRFunction():New(oSection2:Cell("FAM05"),nMedFam05,"ONPRINT",oBreak2,/*cTitle*/,"@E 9,999,999,999.99",{ | | (nMedFam05/nTotFam05)/12 },.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/,/*oSection1*/)
		TRFunction():New(oSection2:Cell("FAM06"),nMedFam06,"ONPRINT",oBreak2,/*cTitle*/,"@E 9,999,999,999.99",{ | | (nMedFam06/nTotFam06)/12 },.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/,/*oSection1*/)
		TRFunction():New(oSection2:Cell("FAM07"),nMedFam07,"ONPRINT",oBreak2,/*cTitle*/,"@E 9,999,999,999.99",{ | | (nMedFam07/nTotFam07)/12 },.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/,/*oSection1*/)

		//#Idade#
		oBreak3 := TRBreak():New(oSection2,".T.",STR0030,.T.)
		TRFunction():New(oSection2:Cell("FAM01"),cIdaFam01,"ONPRINT",oBreak3, /*cTitle*/,"@!",{ | | Padl(fTempoExt( nMedFam01/nTotFam01 ),50) },.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/,/*oSection1*/)
		TRFunction():New(oSection2:Cell("FAM02"),cIdaFam02,"ONPRINT",oBreak3, /*cTitle*/,"@!",{ | | Padl(fTempoExt( nMedFam02/nTotFam02 ),50) },.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/,/*oSection1*/)
		TRFunction():New(oSection2:Cell("FAM03"),cIdaFam03,"ONPRINT",oBreak3, /*cTitle*/,"@!",{ | | Padl(fTempoExt( nMedFam03/nTotFam03 ),50) },.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/,/*oSection1*/)
		TRFunction():New(oSection2:Cell("FAM04"),cIdaFam04,"ONPRINT",oBreak3, /*cTitle*/,"@!",{ | | Padl(fTempoExt( nMedFam04/nTotFam04 ),50) },.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/,/*oSection1*/)
		TRFunction():New(oSection2:Cell("FAM05"),cIdaFam05,"ONPRINT",oBreak3, /*cTitle*/,"@!",{ | | Padl(fTempoExt( nMedFam05/nTotFam05 ),50) },.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/,/*oSection1*/)
		TRFunction():New(oSection2:Cell("FAM06"),cIdaFam06,"ONPRINT",oBreak3, /*cTitle*/,"@!",{ | | Padl(fTempoExt( nMedFam06/nTotFam06 ),50) },.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/,/*oSection1*/)
		TRFunction():New(oSection2:Cell("FAM07"),cIdaFam07,"ONPRINT",oBreak3, /*cTitle*/,"@!",{ | | Padl(fTempoExt( nMedFam07/nTotFam07 ),50) },.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/,/*oSection1*/)

Return oReport

//---------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Define conteúdo que será impresso no relatório.

@author Bruno Lobo de Souza
@since 11/03/16
@version 1.0
@return .T.
/*/
//---------------------------------------------------------------------
Static Function ReportPrint(oReport)

	// Seleciona seção
	Local oSection01 := oReport:Section(1)
	Local oSection02 := oReport:Section(2)
	Local oBreak01	 := oReport:Section(2):aBreak[1]
	Local oBreak02	 := oReport:Section(2):aBreak[2]
	Local oBreak03	 := oReport:Section(2):aBreak[3]

	Local cFilAtu //Variaveis para controle de quebra da seção.
	Local nSec := 0
	Local n

	// Define conteudo a ser impresso
	MsgRun( STR0013, STR0012 )

	dbSelectArea(cTRBFrota)
	dbSetOrder(2)
	dbGotop()

	oReport:SetMeter(RecCount()) // Atribui valores para o objeto Meter (Barra de Progresso)

	//Percorre Alias, imprimindo seu conteudo
	While (cTRBFrota)->(!Eof()) .And. !oReport:Cancel()

	    oSection01:Init()      // Inicializa seção
	    oSection01:PrintLine() // Impressao de conteudo

	    nMedFam01 := 0
	    nMedFam02 := 0
	    nMedFam03 := 0
	    nMedFam04 := 0
	    nMedFam05 := 0
	    nMedFam06 := 0
	    nMedFam07 := 0

	    nTotFam01 := 0
		nTotFam02 := 0
		nTotFam03 := 0
		nTotFam04 := 0
		nTotFam05 := 0
		nTotFam06 := 0
		nTotFam07 := 0

		cFilAtu := (cTRBFrota)->FILIAL
		nPosFil := aScan( aFamilia, {|x| x[1] == cFilAtu } )

		For n := 1 To 7
			If n <= Len( aFamilia[nPosFil][2] )
				oSection02:aCell[n+1]:Enable()
				oSection02:aCell[n+1]:SetPrintCell(.T.)
				oBreak01:aFunction[n]:Enable()
				oBreak02:aFunction[n]:Enable()
				oBreak03:aFunction[n]:Enable()
			Else
				oSection02:aCell[n+1]:Disable()
				oSection02:aCell[n+1]:SetPrintCell(.F.)
				oBreak01:aFunction[n]:Disable()
				oBreak02:aFunction[n]:Disable()
				oBreak03:aFunction[n]:Disable()
			EndIf
		Next n

		For n := 1 To Len( oBreak03:aFunction )
			oBreak03:aFunction[n]:cTitle := ""
			oBreak03:aFunction[n]:lHeaderSize := .F.
			oBreak03:aFunction[n]:nSize := 50
		Next n

		For n := 1 To Min( Len( aFamilia[nPosFil][2] ), 6 )
			oSection02:aCell[n+1]:SetTitle( SubStr( aFamilia[nPosFil][2][n][2], 1, 20 ) )
			oBreak03:aFunction[n]:cTitle := SubStr( AllTrim( aFamilia[nPosFil][2][n][2] ), 1, 20 )+;
				Replicate( ".", 20 - Len( AllTrim( aFamilia[nPosFil][2][n][2] ) ) )
		Next n

		If( Len(aFamilia[nPosFil][2]) > 6 )
			oSection02:aCell[8]:SetTitle( STR0015 )
			oBreak03:aFunction[7]:cTitle := STR0015 + Replicate( ".", 14 )
		Endif

		oReport:IncMeter() // Incremento na barra de progresso
		oSection02:Init()

		While !EOF() .And. (cTRBFrota)->FILIAL == cFilAtu

			nMedFam01 += (cTRBFrota)->FAM01 * Val((cTRBFrota)->TEMPO)
			nMedFam02 += (cTRBFrota)->FAM02 * Val((cTRBFrota)->TEMPO)
			nMedFam03 += (cTRBFrota)->FAM03 * Val((cTRBFrota)->TEMPO)
			nMedFam04 += (cTRBFrota)->FAM04 * Val((cTRBFrota)->TEMPO)
			nMedFam05 += (cTRBFrota)->FAM05 * Val((cTRBFrota)->TEMPO)
			nMedFam06 += (cTRBFrota)->FAM06 * Val((cTRBFrota)->TEMPO)
			nMedFam07 += (cTRBFrota)->FAM07 * Val((cTRBFrota)->TEMPO)

			nTotFam01 += (cTRBFrota)->FAM01
			nTotFam02 += (cTRBFrota)->FAM02
			nTotFam03 += (cTRBFrota)->FAM03
			nTotFam04 += (cTRBFrota)->FAM04
			nTotFam05 += (cTRBFrota)->FAM05
			nTotFam06 += (cTRBFrota)->FAM06
			nTotFam07 += (cTRBFrota)->FAM07

			oSection02:PrintLine() // Impressao de conteudo
			oReport:IncMeter()     // Incremento na barra de progresso
			dbSelectArea(cTRBFrota)
			(cTRBFrota)->(dbSkip())
		End

		oSection02:Finish() // Finaliza seção atual
		oReport:SkipLine(2)
		oSection01:Finish() // Finaliza seção atual

		cFilAtu := (cTRBFrota)->FILIAL

		nSec++
	End

	If nSec < 1
		MsgInfo( STR0020 )
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNR080ST9
Busca na base os dados a serem utilizados no relatório conforme
os parâmetros especificados.

@author Éwerton Cercal
@since 27/07/15
@version 1.0
@return .T. - Lógico
/*/
//---------------------------------------------------------------------
Function MNR080ST9(lImpRel)

	Local cQuery	:= ""
	Local cAliQryDt	:= GetNextAlias()
	Local cAliQryQt	:= GetNextAlias()
	Local cTempo	:= ""
	Local nTempo	:= 0

	// Retorna a quantidade de bens por família e data de compra.
	cQuery := " SELECT ST9.T9_FILIAL, ST9.T9_DTCOMPR, "
	cQuery += " ST9.T9_CODFAMI, ST6.T6_NOME, COUNT(ST9.T9_CODBEM) AS TOTAL FROM " + RetSQLName("ST9") + " ST9 "
	cQuery += " INNER JOIN " + RetSQLName("ST6") + " ST6 ON (ST9.T9_CODFAMI = ST6.T6_CODFAMI) "
	cQuery += " WHERE ST9.T9_FILIAL BETWEEN " + ValToSQL(mv_par01) + " AND " + ValToSQL(mv_par02)
	cQuery += " AND ST9.T9_CODFAMI BETWEEN " + ValToSQL(mv_par03) + " AND " + ValToSQL(mv_par04)
	cQuery += " AND ST9.T9_TIPMOD BETWEEN " + ValToSQL(mv_par05) + " AND " + ValToSQL(mv_par06)
	cQuery += " AND ( ST9.T9_CATBEM = '2' OR ST9.T9_CATBEM = '4' )"
	cQuery += " AND ST9.T9_SITBEM = 'A' "
	cQuery += " AND ST9.D_E_L_E_T_ <> '*' "
	cQuery += " AND ST6.D_E_L_E_T_ <> '*' "
	cQuery += " GROUP BY ST9.T9_FILIAL, ST9.T9_DTCOMPR, ST9.T9_CODFAMI, ST6.T6_NOME "
	cQuery += " ORDER BY ST9.T9_DTCOMPR ASC "
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery), cAliQryDt, .F., .T. )

	// Retorna a quantidade de bens por família.
	cQuery := " SELECT ST9.T9_FILIAL,"
	cQuery += " ST9.T9_CODFAMI, ST6.T6_NOME, COUNT(ST9.T9_CODBEM) AS TOTAL FROM " + RetSQLName("ST9") + " ST9 "
	cQuery += " INNER JOIN " + RetSQLName("ST6") + " ST6 ON (ST9.T9_CODFAMI = ST6.T6_CODFAMI) "
	cQuery += " WHERE ST9.T9_FILIAL BETWEEN " + ValToSQL(mv_par01) + " AND " + ValToSQL(mv_par02)
	cQuery += " AND ST9.T9_CODFAMI BETWEEN " + ValToSQL(mv_par03) + " AND " + ValToSQL(mv_par04)
	cQuery += " AND ST9.T9_TIPMOD BETWEEN " + ValToSQL(mv_par05) + " AND " + ValToSQL(mv_par06)
	cQuery += " AND ( ST9.T9_CATBEM = '2' OR ST9.T9_CATBEM = '4' )"
	cQuery += " AND ST9.T9_SITBEM = 'A' "
	cQuery += " AND ST9.D_E_L_E_T_ <> '*' "
	cQuery += " AND ST6.D_E_L_E_T_ <> '*' "
	cQuery += " GROUP BY ST9.T9_FILIAL, ST9.T9_CODFAMI, ST6.T6_NOME "
	cQuery += " ORDER BY TOTAL DESC "
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery), cAliQryQt, .F., .T. )

	dbSelectArea( cAliQryDt )
	dbGoTop()

	If ReCountTMP(cAliQryDt) == 0
		MsgInfo( STR0020 ) //"Não há dados para serem exibidos no relatório! Encerrando execução."
		(cAliQryDt)->( dbCloseArea() )
		lImpRel := .F.
		Return .F.
	EndIf

	dbSelectArea( cAliQryQt )
	dbGoTop()
	While (cAliQryQt)->(!EoF())

		If ( nPosFil := aScan( aFamilia, {|x| x[1] == (cAliQryQt)->T9_FILIAL } ) ) == 0
			aAdd( aFamilia, { (cAliQryQt)->T9_FILIAL, {} } )
			nPosFil := Len( aFamilia )
		Endif

		//Ordena famílias por bens de forma decrescente
		If Len( aFamilia[nPosFil][2] ) < 7
			If aScan( aFamilia[nPosFil][2], {|x| x[1] == (cAliQryQt)->T9_CODFAMI } ) == 0
				aAdd( aFamilia[nPosFil][2], { (cAliQryQt)->T9_CODFAMI, (cAliQryQt)->T6_NOME } )
			Endif
			(cAliQryQt)->(dbSkip())
		Else
			aDel( aFamilia[nPosFil][2], Len( aFamilia[nPosFil][2] ) )
			aSize( aFamilia[nPosFil][2], Len( aFamilia[nPosFil][2] ) -1 )
			Exit
		EndIf

	End

	dbSelectArea( cTRBFrota )
	dbSetOrder( 1 )

	dbSelectArea( cAliQryDt )
	dbGoTop()
	While (cAliQryDt)->(!EoF())
		nTempo := DateDiffMonth( dDataBase, StoD( (cAliQryDt)->T9_DTCOMPR ) )
		cTempo := fTempoExt( nTempo )

		//Atribui Valores ao TRB
		If ( cTRBFrota )->(dbSeek((cAliQryDt)->T9_FILIAL + StrZero( nTempo, 10 ) ) )
			RecLock( cTRBFrota, .F. )
		Else
			RecLock( cTRBFrota, .T. )
			( cTRBFrota )->FILIAL	:= (cAliQryDt)->T9_FILIAL
			( cTRBFrota )->TEMPO	:= StrZero( nTempo, 10 )
			( cTRBFrota )->DESTMP	:= cTempo
		EndIf

		nPosFil := aScan( aFamilia, {|x| x[1] == (cAliQryDt)->T9_FILIAL } )

		If( nPos := aScan( aFamilia[nPosFil][2], { |x| x[1] == (cAliQryDt)->T9_CODFAMI } ) ) > 0
			&( "( cTRBFrota )->FAM" + StrZero( nPos, 2 ) ) += (cAliQryDt)->TOTAL
		Else
			( cTRBFrota )->FAM07 += (cAliQryDt)->TOTAL
		EndIf
		( cTRBFrota )->TOTTMP += (cAliQryDt)->TOTAL
		( cTRBFrota )->(MsUnlock())

		(cAliQryDt)->(dbSkip())

	End

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fTempoExt
Retorna a idade da frota por extenso

@author Bruno Lobo de Souza
@since 14/03/16
@version 1.0
@return cTempo - tempo em anos/meses por extenso.
/*/
//---------------------------------------------------------------------
Static Function fTempoExt( nMonths )

	Local nAnos	:= Int( nMonths/12 )
	Local nMeses	:= nMonths - ( nAnos*12 )
	Local cTempo	:= ""

	If nAnos > 0
		If nAnos > 1
			cTempo := cValToChar( nAnos ) + STR0034
		Else
			cTempo := cValToChar( nAnos ) + STR0033
		EndIf
	EndIf

	If nMeses > 0
		If nMeses >= 2
			cTempo += If( nAnos > 0, STR0035, "" ) + cValToChar(Int(nMeses)) + STR0032
		ElseIf nMeses >= 1 .And. nMeses < 2
			cTempo += If( nAnos > 0, STR0035, "" ) + cValToChar(Int(nMeses)) + STR0036
		ElseIf nAnos <= 0
			cTempo += STR0037
		EndIf
	ElseIf nAnos <= 0
		cTempo += STR0037
	EndIf

Return cTempo
