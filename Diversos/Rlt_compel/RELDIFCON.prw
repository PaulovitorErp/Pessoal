
#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"


User Function RELDIFCON()

	local oReport
	local cPerg := 'RELDIFCON'
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

	BeginSQL Alias cAlias

SELECT DISTINCT
D1_FILIAL,D1_DOC,D1_SERIE,A2_COD,A2_LOJA,A2_NOME,D1_EMISSAO,D1_DTDIGIT,F4_CODIGO,F4_SITTRIB,F4_TEXTO,SD1.R_E_C_N_O_ AS RECSD1,CV3_RECORI AS RECORICV3,CV3_RECDES AS RECDESCV3,CT2.R_E_C_N_O_ AS RECCT2,CV3_LP,CV3_LPSEQ,CT2_DEBITO,CT2_CREDIT,CT2_VALOR,D1_TOTAL,F3_ESPECIE,D1_TES
FROM 
SD1010 SD1
INNER JOIN %table:SA2% SA2 ON SD1.D1_FORNECE = SA2.A2_COD AND SD1.D1_LOJA = SA2.A2_LOJA AND SD1.D_E_L_E_T_ = SA2.D_E_L_E_T_
INNER JOIN %table:SF4% SF4 ON SD1.D1_TES = SF4.F4_CODIGO AND SD1.D_E_L_E_T_ = SF4.D_E_L_E_T_
INNER JOIN %table:CV3% CV3 ON SD1.R_E_C_N_O_ = CV3.CV3_RECORI AND SD1.D_E_L_E_T_ = CV3.D_E_L_E_T_
INNER JOIN %table:CT2% CT2 ON CT2.R_E_C_N_O_ = CV3.CV3_RECDES AND CT2.D_E_L_E_T_ = CV3.D_E_L_E_T_
INNER JOIN %table:SF3% SF3 ON SF3.F3_NFISCAL = SD1.D1_DOC AND SF3.F3_SERIE = SD1.D1_SERIE AND SF3.F3_CLIEFOR = SD1.D1_FORNECE AND SF3.F3_LOJA  = SD1.D1_LOJA AND SD1.D_E_L_E_T_ = SF3.D_E_L_E_T_
WHERE SD1.%notdel%
AND
D1_DTDIGIT BETWEEN %exp:DTOS(mv_par01)%	 AND %exp:DTOS(mv_par02)%
AND
SF4.F4_DUPLIC <>'S'
AND
CT2_CREDIT='210404001'
AND
CV3_TABORI='SD1'
AND
CV3_RECDES <>''

ORDER BY D1_DTDIGIT


	EndSQL

	oSecao1:EndQuery()
	oReport:SetMeter((cAlias)->(RecCount()))
	oSecao1:Print()

return


//+-----------------------------------------------------------------------------------------------+
//! Função para criação da estrutura do relatório. !
//+-----------------------------------------------------------------------------------------------+
Static Function ReportDef(cAlias, cPerg)

	local cTitle := "Relatorio Diferença Contabil"
	local cHelp := "Permite gerar relatorio diferença contabil documento de entrada"
	local oReport
	local oSection1


	Pergunte(cPerg, .f.)

	oReport := TReport():New("RELDIFCON",cTitle,cPerg,{|oReport|ReportPrint(oReport,cAlias)},cHelp)

	Pergunte(oReport:GetParam(),.F.)

//Primeira sessão

	oSection1 := TRSection():New(oReport,"Contabilização Folha",{cAlias})


	ocell2:= TRCell():New(oSection1,"D1_FILIAL", cAlias,"Filial")
	ocell:=  TRCell():New(oSection1,"D1_DOC", cAlias,"Nota Fiscal")
	ocell:=  TRCell():New(oSection1,"D1_SERIE", cAlias,"Serie")
	ocell:=  TRCell():New(oSection1,"A2_COD", cAlias,"Cod. Fornecedor")
	ocell:=  TRCell():New(oSection1,"A2_LOJA", cAlias,"Loja Fornecedor")
	ocell:=  TRCell():New(oSection1,"A2_NOME", cAlias,"Nome Fornecedor")
	ocell:=  TRCell():New(oSection1,"D1_EMISSAO", cAlias,"Emissao")
	ocell:=  TRCell():New(oSection1,"D1_DTDIGIT", cAlias,"Dt. Digitacao")
	ocell:=  TRCell():New(oSection1,"F4_CODIGO", cAlias,"Tes")
	ocell:=  TRCell():New(oSection1,"F4_SITTRIB", cAlias,"Sit. Icms")
	ocell:=  TRCell():New(oSection1,"F4_TEXTO", cAlias,"Finalidade Tes")
	ocell:=  TRCell():New(oSection1,"RECSD1", cAlias,"RECSD1")
	ocell:=  TRCell():New(oSection1,"RECORICV3", cAlias,"RECORICV3")
	ocell:=  TRCell():New(oSection1,"RECDESCV3", cAlias,"RECDESCV3")
	ocell:=  TRCell():New(oSection1,"RECCT2", cAlias,"RECCT2")
	ocell:=  TRCell():New(oSection1,"CV3_LP", cAlias,"Lcto Padrao")
	ocell:=  TRCell():New(oSection1,"CV3_LPSEQ", cAlias,"Seq. Lcto Padrao")
	ocell:=  TRCell():New(oSection1,"CT2_DEBITO", cAlias,"Cta Debito")
	ocell:=  TRCell():New(oSection1,"CT2_CREDIT", cAlias,"Cta Credito")
	ocell:=  TRCell():New(oSection1,"CT2_VALOR", cAlias,"Valor Contabilizado")
	ocell:=  TRCell():New(oSection1,"D1_TOTAL", cAlias,"Vlr Total Produto")
	ocell:=  TRCell():New(oSection1,"F3_ESPECIE", cAlias,"Especie")
	ocell:=  TRCell():New(oSection1,"D1_TES", cAlias,"Tes")

	





Return(oReport)












