#include "rwmake.ch"
#include "PROTHEUS.CH"
#Include "TOPCONN.CH" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³         ºAutor LEONARDO LACERDA                        	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FISCAL - FATURAMENTO COM ICMS                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RELTFICM()                                                                                          

Local cPerg :=  Padr("RELTFICM",10)
Local oReport               

pergunte(cPerg,.F.)
                      


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Interface de impressao                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:=  ReportDefA(cPerg)
oReport:PrintDialog()

	
Return


Static Function ReportDefA(cNome)

Local oReport 
Local oSection1   
//Local oBreak

oReport:=  TReport():New(cNome,"Faturamento com ICMS - Compel Explosivos",cNome, {|oReport| ReportPrintA(oReport)},"Este Relatório tem a finalidade de listar Fatur com ICMS") 
oReport:SetPortrait(.F.)
oReport:SetTotalInLine(.F.)
oReport:ShowHeader()
 
oSection1 :=  TRSection():New(oReport,"Faturamento com ICMS",({"SF2","SA1","SD2"}))
oSection1:SetTotalInLine(.F.)
                                                       

TRCell():New(oSection1, "FILIAL",			"",    'FILIAL', 	         PesqPict("SF2","F2_FILIAL")	,TamSx3("F2_FILIAL")		[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1, "DOCUMENTO", 			"",    'DOCUMENTO', 	         PesqPict("SF2","F2_DOC")	,TamSx3("F2_DOC")		[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1, "SERIE",    		"",    'SERIE', 		     PesqPict("SF2","F2_SERIE")	,TamSx3("F2_SERIE")			[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1, "CLIENTE", 			"",    'CLIENTE', 	             PesqPict("SF2","F2_CLIENTE")	,TamSx3("F2_CLIENTE")		[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1, "NOME",   	"",    'NOME', 		 PesqPict("SA1","A1_NOME")	,TamSx3("A1_NOME")			[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1, "ESTADO",   		"",    'ESTADO', 	         PesqPict("SA1","A1_EST")	,TamSx3("A1_EST")			[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1, "CNPJ",   	    	"",    'CNPJ',              PesqPict("SA1","A1_CGC")	,TamSx3("A1_CGC")		    [1]+9,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1, "CFOP",  		"",    'CFOP', 	         PesqPict("SD2","D2_CF")	,TamSx3("D2_CF")		[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1, "VALBRUTO",       "",    'VALBRUTO', 	     PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")			[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1, "VALINSS",       "",    'VALINSS', 	     PesqPict("SF2","F2_VALINSS")	,TamSx3("F2_VALINSS")			[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1, "VALISS",       "",    'VALISS', 	     PesqPict("SF2","F2_VALISS")	,TamSx3("F2_VALISS")			[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1, "VALICM",       "",    'VALICM', 	     PesqPict("SF2","F2_VALICM")	,TamSx3("F2_VALICM")			[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1, "FRETE",       "",    'FRETE', 	     PesqPict("SF2","F2_FRETE")			,TamSx3("F2_FRETE")			[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1, "DESPESAS",       "",    'DESPESAS', 	     PesqPict("SF2","F2_DESPESA")	,TamSx3("F2_DESPESA")			[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1, "DTEMISSAO",       "",    'DTEMISSAO', 	     PesqPict("SF2","F2_EMISSAO")	,TamSx3("F2_EMISSAO")			[1]+6,/*lPixel*/,/*{|| code-block de impressao }*/)



Return(oReport)



Static Function ReportPrintA(oReport)


Local cQuery :=  '' 
Local _cAlias                               
Local oDados :=  oReport:Section(1)
//Local lRet :=  .F.



cQuery := " SELECT F2_FILIAL FILIAL,"
cQuery += " F2_DOC DOCUMENTO,"
cQuery += " F2_SERIE SERIE,"
cQuery += " F2_CLIENTE CLIENTE,"
cQuery += " A1_NOME NOME,"
cQuery += " A1_EST ESTADO,"
cQuery += " A1_CGC CNPJ,"
cQuery += " D2_CF CFOP,"
cQuery += " F2_VALBRUT VALBRUTO,"
cQuery += " F2_VALINSS VALINSS,"
cQuery += " F2_VALISS VALISS,"
cQuery += " F2_VALICM VALICM,"
cQuery += " F2_FRETE FRETE,"
cQuery += " F2_DESPESA DESPESAS,"
cQuery +=  " CONVERT(CHAR,CAST(F2_EMISSAO AS DATETIME),103) DTEMISSAO "
cQuery += " FROM " + RetSqlName("SF2") + " SF2 "
cQuery += " INNER JOIN SD2010 SD2 ON SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_CLIENTE = SF2.F2_CLIENTE AND SD2.D_E_L_E_T_ = '' AND SF2.F2_EMISSAO = SD2.D2_EMISSAO"
cQuery += " INNER JOIN SA1010 SA1 ON SA1.A1_COD = SF2.F2_CLIENTE AND SA1.D_E_L_E_T_ = '' "
cQuery += " WHERE F2_EMISSAO >= '" + DTOS(MV_PAR01) + "' 
cQuery += " AND F2_EMISSAO <= '" + DTOS(MV_PAR02) + "' 
cQuery += " AND SF2.D_E_L_E_T_ = '' "
cQuery += " AND SF2.F2_FILIAL IN (0101,0104,0106,0108,0109,0110)" 
cQuery += " AND SD2.D2_CF IN (5102,6102,5933,6933,5551,6551,5152,6152) "    
cQuery += " GROUP BY F2_DOC, F2_EMISSAO, A1_NOME, F2_CLIENTE, F2_FILIAL, F2_DOC, F2_SERIE, A1_CGC, F2_FILDEST, F2_FORDES, D2_CF, F2_FILIAL, F2_VALBRUT, F2_VALISS, F2_VALINSS, A1_EST,F2_VALICM, F2_DESPESA, F2_FRETE"
cQuery += " ORDER BY F2_EMISSAO, F2_DOC"




	cQuery :=  ChangeQuery(cQuery)
	
	_cAlias :=  GetNextAlias()
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),_cAlias,.T.,.F.)
	
	
	dbSelectArea(_cAlias)
	dbGoTop()
		
	oDados:Init()
	oDados:SetHeaderSection(.T.)
	
	While !(_cAlias)->(Eof())


		oDados:Cell('FILIAL'):SetValue((_cAlias)->FILIAL)
		oDados:Cell('FILIAL'):SetAlign("LEFT")

		oDados:Cell('DOCUMENTO'):SetValue((_cAlias)->DOCUMENTO)
		oDados:Cell('DOCUMENTO'):SetAlign("LEFT")

		oDados:Cell('SERIE'):SetValue((_cAlias)->SERIE)
		oDados:Cell('SERIE'):SetAlign("LEFT")

		oDados:Cell('CLIENTE'):SetValue((_cAlias)->CLIENTE)
		oDados:Cell('CLIENTE'):SetAlign("LEFT")

		oDados:Cell('NOME'):SetValue((_cAlias)->NOME)
		oDados:Cell('NOME'):SetAlign("LEFT")

		oDados:Cell('ESTADO'):SetValue((_cAlias)->ESTADO)
		oDados:Cell('ESTADO'):SetAlign("LEFT")

		oDados:Cell('CNPJ'):SetValue((_cAlias)->CNPJ)
		oDados:Cell('CNPJ'):SetAlign("LEFT")

		oDados:Cell('CFOP'):SetValue((_cAlias)->CFOP)
		oDados:Cell('CFOP'):SetAlign("LEFT")

		oDados:Cell('VALBRUTO'):SetValue((_cAlias)->VALBRUTO)
		oDados:Cell('VALBRUTO'):SetAlign("LEFT")

		oDados:Cell('VALINSS'):SetValue((_cAlias)->VALINSS)
		oDados:Cell('VALINSS'):SetAlign("LEFT")

		oDados:Cell('VALISS'):SetValue((_cAlias)->VALISS)
		oDados:Cell('VALISS'):SetAlign("LEFT")

     	oDados:Cell('VALICM'):SetValue((_cAlias)->VALICM)
		oDados:Cell('VALICM'):SetAlign("LEFT")
		
		oDados:Cell('FRETE'):SetValue((_cAlias)->FRETE)
		oDados:Cell('FRETE'):SetAlign("LEFT")

		oDados:Cell('DESPESAS'):SetValue((_cAlias)->DESPESAS)
		oDados:Cell('DESPESAS'):SetAlign("LEFT")

     	oDados:Cell('DTEMISSAO'):SetValue((_cAlias)->DTEMISSAO)
		oDados:Cell('DTEMISSAO'):SetAlign("LEFT")

		
		oDados:PrintLine()

		(_cAlias)->(dbSkip())
		
	End
	
	(_cAlias)->(dbCloseArea())


oDados:Finish()


Return








