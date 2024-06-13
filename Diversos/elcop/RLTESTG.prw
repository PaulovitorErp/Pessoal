
#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"


User Function RLTESTG()

	local oReport
	local cPerg := 'RLTESTG'
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


SELECT B2_FILIAL AS filial,
       B2_COD AS cod_Produto,
       B1_DESC AS descricao,
       B2_LOCAL AS local_armazem,
       B1_XLOCALI AS localizacao_do_produto,
       SUM(B2_QATU) AS saldo_estoque_atual,
       CAST(REPLACE(B2_VATU1, ',', '.') AS DECIMAL(10, 2)) AS valor_estoque,
       CAST(REPLACE(B1_UPRC, ',', '.') AS DECIMAL(10, 2)) AS ultimo_preco_de_compra
FROM %table:SB2% B2 
INNER JOIN %table:SB1% B1 ON B1.B1_COD=B2.B2_COD AND B2.D_E_L_E_T_=B1.D_E_L_E_T_
                         
WHERE B1.%notdel%
  AND B2_LOCAL BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%
                
  AND B2_QATU>0
GROUP BY B2_FILIAL,
         B2_COD,
         B2_LOCAL,
         B2_LOCALIZ,
         B1_DESC,
         B1_XLOCALI,
         B2_VATU1,
         B1_UPRC
ORDER BY B2_FILIAL,
         B2_COD


		EndSQL

		oSecao1:EndQuery()
		oReport:SetMeter((cAlias)->(RecCount()))
		oSecao1:Print()

		return

	
//+-----------------------------------------------------------------------------------------------+
//! Função para criação da estrutura do relatório. !
//+-----------------------------------------------------------------------------------------------+
Static Function ReportDef(cAlias, cPerg)

	local cTitle := "Relatorio Estoque Gerencial"
	local cHelp := "Permite gerar relatorio customizado estoque gerencial armazens 04/05"
	local oReport
	local oSection1


	Pergunte(cPerg, .f.)

	oReport := TReport():New('RLTESTG',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAlias)},cHelp)

//Primeira sessão
	oSection1 := TRSection():New(oReport,"Analise Estoque",{cAlias})


	ocell2:= TRCell():New(oSection1,"filial", cAlias,"Filial")
	ocell:=  TRCell():New(oSection1,"cod_Produto", cAlias,"Cod. Produto")
	ocell:=  TRCell():New(oSection1,"descricao", cAlias,"Desc. Produto")
	ocell:=  TRCell():New(oSection1,"local_armazem", cAlias,"Armazem")
	ocell:=  TRCell():New(oSection1,"localizacao_do_produto", cAlias,"Localiz. do Produto")
	ocell:=  TRCell():New(oSection1,"saldo_estoque_atual", cAlias,"Saldo Atu. Estoque")
	ocell:=  TRCell():New(oSection1,"valor_estoque", cAlias,"Valor Estoque")
    ocell:=  TRCell():New(oSection1,"ultimo_preco_de_compra", cAlias,"Ult. Vlr Compra")
	


Return(oReport)
