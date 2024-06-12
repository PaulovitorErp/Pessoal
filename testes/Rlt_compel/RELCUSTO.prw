
#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"


User Function RLTCUSTO()

	local oReport
	local cPerg := 'RLTCUSTO'
	local cAlias := getNextAlias()


	Pergunte(cPerg, .f.)

	oReport := reportDef(cAlias, cPerg)
	oReport:printDialog()

return

//+-----------------------------------------------------------------------------------------------+
//! Rotina para montagem dos dados do relatório. !
//+-----------------------------------------------------------------------------------------------+
Static Function ReportPrint(oReport,cAlias)

	local oSecao1 := oReport:Section(1)

	oSecao1:BeginQuery()

	If MV_PAR05 == 1 //Sintetico

		BeginSQL Alias cAlias


SELECT
    D1_FILIAL,
    CASE
        WHEN CTT.CTT_XCD = '' AND SF4.F4_ESTOQUE IN ('S', 'N') AND SF4.F4_ATUATF IN ('S', 'N') THEN 'Cc nao classificado'
        WHEN CTT.CTT_XCD = 'D' AND SF4.F4_ESTOQUE = 'N' AND SF4.F4_ATUATF = 'N' THEN LTRIM(RTRIM(SB1.B1_XCTAD)) + '-' + LTRIM(RTRIM(CT1DESP.CT1_DESC01))
        WHEN CTT.CTT_XCD = 'C' AND SF4.F4_ESTOQUE = 'N' AND SF4.F4_ATUATF = 'N' THEN LTRIM(RTRIM(SB1.B1_XCTAC)) + '-' + LTRIM(RTRIM(CT1CUSTO.CT1_DESC01))
        WHEN CTT.CTT_XCD IN ('D', 'C') AND SF4.F4_ESTOQUE = 'S' THEN LTRIM(RTRIM(SB1.B1_CONTA)) + '-' + LTRIM(RTRIM(CT1PRD.CT1_DESC01))
        WHEN CTT.CTT_XCD IN ('D', 'C') AND SF4.F4_ATUATF = 'S' THEN LTRIM(RTRIM(SB1.B1_XCTAI)) + '-' + LTRIM(RTRIM(CT1ATF.CT1_DESC01))
    END AS descricao,
    CASE
        WHEN SD1.D1_CC = '' THEN 'CC nao informado'
        ELSE LTRIM(RTRIM(SD1.D1_CC)) + '-' + LTRIM(RTRIM(CTT.CTT_DESC01))
    END AS descricaoc,
    SUM(SD1.TOTAL) AS TOTAL,
	CASE 
        WHEN CT1PRD.CT1_XTIPOC = '' THEN 'Conta nao classificada'
        ELSE CT1PRD.CT1_XTIPOC
    END AS Tipoconta
	FROM (
    SELECT
        D1_FILIAL,
        D1_CC,
        D1_COD,
        D1_TES,
        SUM(D1_TOTAL) AS TOTAL
		
		
    FROM %table:SD1% SD1
    WHERE SD1.%notdel%
        AND D1_FILIAL BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02% 
        AND D1_DTDIGIT BETWEEN %exp:DTOS(mv_par03)%	 AND %exp:DTOS(mv_par04)%
        AND SD1.D1_CC BETWEEN %exp:MV_PAR06% AND %exp:MV_PAR07%
	 	GROUP BY D1_FILIAL, D1_CC, D1_COD, D1_TES
) AS SD1
INNER JOIN (
    SELECT DISTINCT B1_COD, B1_CONTA, B1_XCTAD, B1_XCTAC, B1_XCTAI FROM %table:SB1%
) SB1 ON SD1.D1_COD = SB1.B1_COD
INNER JOIN (
    SELECT DISTINCT F4_CODIGO, F4_ESTOQUE, F4_ATUATF,F4_DUPLIC FROM %table:SF4%
) SF4 ON SD1.D1_TES = SF4.F4_CODIGO AND SF4.F4_DUPLIC <>'N'
LEFT JOIN (
    SELECT DISTINCT CT1_CONTA, CT1_DESC01,CT1_XTIPOC  FROM %table:CT1%
) CT1PRD ON SB1.B1_CONTA = CT1PRD.CT1_CONTA
LEFT JOIN (
    SELECT DISTINCT CT1_CONTA, CT1_DESC01 FROM %table:CT1%
) CT1DESP ON SB1.B1_XCTAD = CT1DESP.CT1_CONTA
LEFT JOIN (
    SELECT DISTINCT CT1_CONTA, CT1_DESC01 FROM %table:CT1%
) CT1CUSTO ON SB1.B1_XCTAC = CT1CUSTO.CT1_CONTA
LEFT JOIN (
    SELECT DISTINCT CT1_CONTA, CT1_DESC01 FROM %table:CT1%
) CT1ATF ON SB1.B1_XCTAI = CT1ATF.CT1_CONTA
LEFT JOIN (
    SELECT DISTINCT CTT_CUSTO, CTT_DESC01, CTT_XCD FROM %table:CTT%
) CTT ON CTT.CTT_CUSTO = SD1.D1_CC
GROUP BY
    SD1.D1_FILIAL,
    CTT.CTT_XCD,
    SF4.F4_ESTOQUE,
    SF4.F4_ATUATF,
    SB1.B1_XCTAD,
    SB1.B1_XCTAC,
    SB1.B1_CONTA,
    SB1.B1_XCTAI,
    CT1DESP.CT1_DESC01,
    CT1CUSTO.CT1_DESC01,
    CT1PRD.CT1_DESC01,
    CT1ATF.CT1_DESC01,
    SD1.D1_CC,
    CTT.CTT_DESC01,
	CT1_XTIPOC

	ORDER BY
    SD1.D1_FILIAL,
    descricao,
    TOTAL 


		EndSQL

		oSecao1:EndQuery()
		oReport:SetMeter((cAlias)->(RecCount()))
		oSecao1:Print()

		return

	Else // Analitico

		BeginSQL Alias cAlias


SELECT DISTINCT
  CASE 
    WHEN F1_TIPO = 'N' THEN 'Entrada'
	WHEN F1_TIPO = 'C' THEN 'Entrada Frete'
    WHEN F1_TIPO = 'D' THEN 'Devolucao'
	WHEN F1_TIPO = 'I' THEN 'Compl Icms'
		
  END AS [TipoMovimento],
  D1_FILIAL,
  D1_COD,
  B1_DESC,
  D1_ITEM,
  D1_LOCAL,
  D1_UM,
  D1_QUANT,
  D1_VUNIT,
  D1_VALDESC,
  D1_TOTAL,
  D1_CUSTO,
  D1_TES,
  SF4.F4_ESTOQUE,
  SF4.F4_ATUATF,
  CASE 
  WHEN CTT.CTT_XCD = ''  AND SF4.F4_ESTOQUE IN ('S','N') AND SF4.F4_ATUATF IN ('S','N')   THEN 'Cc nao classificao'
  WHEN CTT.CTT_XCD = 'D' AND SF4.F4_ESTOQUE = 'N' AND SF4.F4_ATUATF = 'N'  THEN LTRIM(RTRIM(SB1.B1_XCTAD)) + '-' + LTRIM(RTRIM(CT1DESP.CT1_DESC01))
  WHEN CTT.CTT_XCD = 'C' AND SF4.F4_ESTOQUE = 'N' AND SF4.F4_ATUATF = 'N'  THEN LTRIM(RTRIM(SB1.B1_XCTAC)) + '-' + LTRIM(RTRIM(CT1CUSTO.CT1_DESC01))
	WHEN CTT.CTT_XCD IN ('D','C') AND SF4.F4_ESTOQUE = 'S'  THEN LTRIM(RTRIM(SB1.B1_CONTA)) + '-' + LTRIM(RTRIM(CT1PRD.CT1_DESC01))
	WHEN CTT.CTT_XCD IN ('D','C') AND SF4.F4_ATUATF  = 'S' THEN LTRIM(RTRIM(SB1.B1_XCTAI)) + '-' + LTRIM(RTRIM(CT1ATF.CT1_DESC01))
  END AS descricao,
  CASE 
    WHEN D1_CC = '' THEN 'CC nao informado'
    ELSE LTRIM(RTRIM(D1_CC)) + '-' + LTRIM(RTRIM(CTT_DESC01)) 
  END AS descricaoc,
  D1_XCODBEM,
  A2_COD,
  A2_LOJA,
  A2_CGC,
  A2_NOME,
  D1_CF,
  D1_EMISSAO, 
  D1_DTDIGIT,
  D1_DOC,
  D1_SERIE,
  CASE 
   WHEN CT1PRD.CT1_XTIPOC = '' THEN 'Conta nao classificada'
   ELSE CT1PRD.CT1_XTIPOC
   END AS Tipoconta

FROM 
  %table:SD1% SD1
INNER JOIN %table:SB1% SB1 ON SD1.D1_COD = SB1.B1_COD
INNER JOIN %table:SA2% SA2 ON SA2.A2_COD =SD1.D1_FORNECE AND SA2.A2_LOJA=SD1.D1_LOJA
INNER JOIN %table:SF4% SF4 ON SD1.D1_TES = SF4.F4_CODIGO
INNER JOIN %table:SF1% SF1 ON SD1.D1_FILIAL = SF1.F1_FILIAL
  AND SD1.D1_DOC = SF1.F1_DOC
  AND SD1.D1_SERIE = SF1.F1_SERIE
  AND SD1.D1_FORNECE = SF1.F1_FORNECE
  AND SD1.D1_LOJA = SF1.F1_LOJA
LEFT JOIN %table:CT1% CT1PRD ON SB1.B1_CONTA = CT1PRD.CT1_CONTA
LEFT JOIN %table:CT1% CT1DESP ON SB1.B1_XCTAD = CT1DESP.CT1_CONTA
LEFT JOIN %table:CT1% CT1CUSTO ON SB1.B1_XCTAC = CT1CUSTO.CT1_CONTA
LEFT JOIN %table:CT1% CT1ATF ON SB1.B1_XCTAI = CT1ATF.CT1_CONTA
LEFT JOIN %table:CTT% CTT ON CTT.CTT_CUSTO = SD1.D1_CC
WHERE SD1.%notdel%
 AND SD1.D1_FILIAL  BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02% 
 AND SD1.D1_DTDIGIT BETWEEN %exp:DTOS(mv_par03)%	 AND %exp:DTOS(mv_par04)%
 AND SD1.D1_CC BETWEEN %exp:MV_PAR06% AND %exp:MV_PAR07%
 AND SF4.F4_DUPLIC <>'N'
 
 ORDER BY D1_FILIAL,D1_DTDIGIT,D1_DOC,D1_ITEM
  


		EndSQL

		oSecao1:EndQuery()
		oReport:SetMeter((cAlias)->(RecCount()))
		oSecao1:Print()

		return

	Endif






//+-----------------------------------------------------------------------------------------------+
//! Função para criação da estrutura do relatório. !
//+-----------------------------------------------------------------------------------------------+
Static Function ReportDef(cAlias, cPerg)

	local cTitle := "Relatorio de Custo"
	local cHelp := "Permite gerar relatorio customizado de custo"
	local oReport
	local oSection1


	Pergunte(cPerg, .f.)

	oReport := TReport():New("RLTCUSTO",cTitle,cPerg,{|oReport|ReportPrint(oReport,cAlias)},cHelp)

	AjustaSx1() // cria as perguntas para gerar o relatorio
	Pergunte(oReport:GetParam(),.F.)

//Primeira sessão
	If MV_PAR05 == 1
		oSection1 := TRSection():New(oReport,"Analise de Custo",{cAlias})


		ocell2:= TRCell():New(oSection1,"D1_FILIAL", cAlias,"Filial")
		ocell:=  TRCell():New(oSection1,"descricao", cAlias,"Conta Conbail/Descricao")
		ocell:=  TRCell():New(oSection1,"descricaoc", cAlias,"Centro de Custo/Descricao")
		ocell:=  TRCell():New(oSection1,"TOTAL", cAlias,"Vlr Total")
		ocell:=  TRCell():New(oSection1,"Tipoconta", cAlias,"Tipo Cta Contabil")
		
		Return(oReport)

	Else
		oSection1 := TRSection():New(oReport,"Analise de Custo",{cAlias})


		ocell2:= TRCell():New(oSection1,"TipoMovimento", cAlias,"TipoMovimento")
		ocell:=  TRCell():New(oSection1,"D1_FILIAL", cAlias,"Filial")
		ocell:=  TRCell():New(oSection1,"D1_COD", cAlias,"Cod Produto")
		ocell:=  TRCell():New(oSection1,"B1_DESC", cAlias,"Desc Produto")
		ocell:=  TRCell():New(oSection1,"D1_ITEM", cAlias,"Item")
		ocell:=  TRCell():New(oSection1,"D1_LOCAL", cAlias,"Armazem")
		ocell:=  TRCell():New(oSection1,"D1_UM", cAlias,"Unidade")
		ocell:=  TRCell():New(oSection1,"D1_QUANT", cAlias,"Quantidade")
		ocell:=  TRCell():New(oSection1,"D1_VUNIT", cAlias,"Vlr Unitario")
		ocell:=  TRCell():New(oSection1,"D1_VALDESC", cAlias,"Vlr Desconto")
		ocell:=  TRCell():New(oSection1,"D1_TOTAL", cAlias,"Vlr Total")
		ocell:=  TRCell():New(oSection1,"D1_CUSTO", cAlias,"Custo Real")
		ocell:=  TRCell():New(oSection1,"descricao", cAlias,"Cont/Desc")
		ocell:=  TRCell():New(oSection1,"descricaoc", cAlias,"CC/Desc")
		ocell:=  TRCell():New(oSection1,"D1_XCODBEM", cAlias,"Cod do Bem")
		ocell:=  TRCell():New(oSection1,"A2_COD", cAlias,"Cod Fornecedor")
		ocell:=  TRCell():New(oSection1,"A2_LOJA", cAlias,"Loja Fornecedor")
		ocell:=  TRCell():New(oSection1,"A2_CGC", cAlias,"Cpf/Cnpj")
		ocell:=  TRCell():New(oSection1,"A2_NOME", cAlias,"Nome")
		ocell:=  TRCell():New(oSection1,"D1_DOC", cAlias,"Numero Nf")
		ocell:=  TRCell():New(oSection1,"D1_SERIE", cAlias,"Serie")
		ocell:=  TRCell():New(oSection1,"D1_CF", cAlias,"Cfop")
		ocell:=  TRCell():New(oSection1,"D1_EMISSAO", cAlias,"Emissao Nf")
		ocell:=  TRCell():New(oSection1,"D1_DTDIGIT", cAlias,"Dt Digitação Nf")
		ocell:=  TRCell():New(oSection1,"Tipoconta", cAlias,"Tipo Cta Contabil")



		Return(oReport)

	Endif

Static Function AjustaSX1()



	Local cPerg := 'RLTCUSTO'
	Local aHelpPor	:= {}
	Local aHelpEng	:= {}
	Local aHelpSpa	:= {}

	U_xPutSX1( cPerg, "01","Da filial ?                 ","","","mv_ch1","C",4,0,0,"G",'',"SM0","","",;
		"mv_par01","","","","","","","","","","","","","","","","",;
		{'Informe a filial inicial','a ser processada.'},aHelpEng,aHelpSpa)

	U_xPutSX1( cPerg, "02","Até a filial ?                 ","","","mv_ch2","C",4,0,0,"G",'',"SM0","","",;
		"mv_par02","","","","","","","","","","","","","","","","",;
		{'Informe a filial Final','a ser processada.'},aHelpEng,aHelpSpa)

	U_xPutSX1( cPerg, "03","Da digitação ?           ","","","mv_ch3","D",8,0,0,"G","","","","",;
		"mv_par03","","","","","","","","","","","","","","","","",;
		{'Informe a data inicial da Digitação','a ser processada.'},aHelpEng,aHelpSpa)

	U_xPutSX1( cPerg, "04","Até a digitação ?                  ","","","mv_ch4","D",8,0,0,"G","(MV_PAR04 >= MV_PAR03)","","","",;
		"mv_par04","","","","","","","","","","","","","","","","",;
		{'Informe a data final da Digitação','a ser processada.'},aHelpEng,aHelpSpa)

	U_xPutSX1( cPerg, "05","Tipo da Visão ?          ","","","mv_ch5","N",1,0,0,"C","","","","",;
		"mv_par05","Sintetico","Sintetico","Sintetico","1","Analitico","Analitico","Analitico","","","","","","","","","",;
		{'Indica tipo da visão','gerencial,',' Sintetico ou Analitico.'},aHelpEng,aHelpSpa)

	U_xPutSX1( cPerg, "06","Do centro de custo ?                 ","","","mv_ch6","C",9,0,0,"G",'',"CTT","","",;
		"mv_par06","","","","","","","","","","","","","","","","",;
		{'Centro de custo','centro de custo.'},aHelpEng,aHelpSpa)

	U_xPutSX1( cPerg, "07","Até o centro de custo ?                 ","","","mv_ch7","C",9,0,0,"G",'',"CTT","","",;
		"mv_par07","","","","","","","","","","","","","","","","",;
		{'Centro de custo','centro de custo.'},aHelpEng,aHelpSpa)

Return(Nil)





