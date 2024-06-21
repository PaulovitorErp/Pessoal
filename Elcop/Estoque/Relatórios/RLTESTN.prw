
#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"


User Function RLTESTN()

	local oReport
	local cPerg := 'RLTESTN'
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


SELECT 
    ZD6_COD AS Codigo,
    B1_DESC AS Descricao,
    ZD6_LOCDEV AS Armazem,
    ZD6_NUMDOC AS Documento,
    ZD6_QTDDEV AS Quant_Devolvida,
    CAST(REPLACE(B1_UPRC, ',', '.') AS DECIMAL(10, 2)) AS Ult_preco_compra, 
    CAST(REPLACE(B1_UPRC * ZD6_QTDDEV, ',', '.') AS DECIMAL(10, 2)) AS Valor_Devolucao
FROM 
    %table:ZD6% ZD6 
    INNER JOIN %table:SB1% B1 ON B1.B1_COD = ZD6.ZD6_COD AND ZD6.D_E_L_E_T_=B1.D_E_L_E_T_
    
WHERE 
    ZD6.%notdel%
    AND ZD6_REPOR = 'N'
    AND ZD6_DTADEV BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%
    ORDER BY ZD6_COD


		EndSQL

		oSecao1:EndQuery()
		oReport:SetMeter((cAlias)->(RecCount()))
		oSecao1:Print()

		return

	
//+-----------------------------------------------------------------------------------------------+
//! Função para criação da estrutura do relatório. !
//+-----------------------------------------------------------------------------------------------+
Static Function ReportDef(cAlias, cPerg)

	local cTitle := "Relatorio Requisição sem Movimentação"
	local cHelp := "Permite gerar relatorio customizado de Movimentação atualiza estoque =não"
	local oReport
	local oSection1


	Pergunte(cPerg, .f.)

	oReport := TReport():New('RLTESTN',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAlias)},cHelp)

//Primeira sessão
	oSection1 := TRSection():New(oReport,"Analise Estoque",{cAlias})


	ocell2:= TRCell():New(oSection1,"Codigo", cAlias,"Codigo")
	ocell:=  TRCell():New(oSection1,"Descricao", cAlias,"Descricao")
	ocell:=  TRCell():New(oSection1,"Armazem", cAlias,"Armazem")
	ocell:=  TRCell():New(oSection1,"Documento", cAlias,"Documento")
	ocell:=  TRCell():New(oSection1,"Quant_Devolvida", cAlias,"Quant. Devolvida")
	ocell:=  TRCell():New(oSection1,"Ult_preco_compra", cAlias,"Ult. Vlr Compra")
	ocell:=  TRCell():New(oSection1,"Valor_Devolucao", cAlias,"Valor Devolucao")
	


Return(oReport)
