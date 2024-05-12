
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

	If MV_PAR05 == 1

		BeginSQL Alias cAlias


SELECT DISTINCT
  CASE 
    WHEN FT_TIPOMOV = 'E' THEN 'Entrada'
    WHEN FT_TIPOMOV = 'S' THEN 'Saída'
  END AS [TipoMovimento],
  D1_FILIAL,
  D1_COD,
  B1_DESC,
  D1_ITEM,
  D1_LOCAL,
  D1_UM,
  D1_QUANT,
  D1_VUNIT,
  D1_TOTAL,
  D1_CUSTO,
  D1_TES,
  CASE 
    WHEN LTRIM(RTRIM(B1_CONTA)) = '' THEN 'Ctb nao informada'
    ELSE LTRIM(RTRIM(B1_CONTA)) + '-' + LTRIM(RTRIM(CT1_DESC01)) 
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
  D1_SERIE

FROM 
  %table:SD1% SD1
INNER JOIN %table:SB1% SB1 ON SD1.D1_COD = SB1.B1_COD
INNER JOIN %table:SA2% SA2 ON SA2.A2_COD =SD1.D1_FORNECE AND SA2.A2_LOJA=SD1.D1_LOJA
INNER JOIN %table:SFT% SFT ON SD1.D1_FILIAL = SFT.FT_FILIAL
  AND SD1.D1_DOC = SFT.FT_NFISCAL
  AND SD1.D1_SERIE = SFT.FT_SERIE
  AND SD1.D1_FORNECE = SFT.FT_CLIEFOR
  AND SD1.D1_LOJA = SFT.FT_LOJA
LEFT JOIN %table:CT1% CT1 ON SB1.B1_CONTA = CT1.CT1_CONTA
LEFT JOIN %table:CTT% CTT ON CTT.CTT_CUSTO = SD1.D1_CC
WHERE SD1.%notdel%
 AND SD1.D1_FILIAL  BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02% 
 AND SD1.D1_DTDIGIT BETWEEN %exp:DTOS(mv_par03)%	 AND %exp:DTOS(mv_par04)%
 
 ORDER BY D1_FILIAL,D1_DTDIGIT,D1_DOC,D1_ITEM
  


		EndSQL

		oSecao1:EndQuery()
		oReport:SetMeter((cAlias)->(RecCount()))
		oSecao1:Print()

		return

	Else
		BeginSQL Alias cAlias


SELECT DISTINCT
  CASE 
    WHEN FT_TIPOMOV = 'E' THEN 'Entrada'
    WHEN FT_TIPOMOV = 'S' THEN 'Saída'
  END AS [TipoMovimento],
  D1_FILIAL,
  D1_COD,
  B1_DESC,
  D1_ITEM,
  D1_LOCAL,
  D1_UM,
  D1_QUANT,
  D1_VUNIT,
  D1_TOTAL,
  D1_CUSTO,
  D1_TES,
  CASE 
    WHEN LTRIM(RTRIM(B1_CONTA)) = '' THEN 'Ctb nao informada'
    ELSE LTRIM(RTRIM(B1_CONTA)) + '-' + LTRIM(RTRIM(CT1_DESC01)) 
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
  D1_SERIE

FROM 
  %table:SD1% SD1
INNER JOIN %table:SB1% SB1 ON SD1.D1_COD = SB1.B1_COD
INNER JOIN %table:SA2% SA2 ON SA2.A2_COD =SD1.D1_FORNECE AND SA2.A2_LOJA=SD1.D1_LOJA
INNER JOIN %table:SFT% SFT ON SD1.D1_FILIAL = SFT.FT_FILIAL
  AND SD1.D1_DOC = SFT.FT_NFISCAL
  AND SD1.D1_SERIE = SFT.FT_SERIE
  AND SD1.D1_FORNECE = SFT.FT_CLIEFOR
  AND SD1.D1_LOJA = SFT.FT_LOJA
LEFT JOIN %table:CT1% CT1 ON SB1.B1_CONTA = CT1.CT1_CONTA
LEFT JOIN %table:CTT% CTT ON CTT.CTT_CUSTO = SD1.D1_CC
WHERE SD1.%notdel%
 AND SD1.D1_FILIAL  BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02% 
 AND SD1.D1_DTDIGIT BETWEEN %exp:DTOS(mv_par03)%	 AND %exp:DTOS(mv_par04)%
 
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



Return(oReport)

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





