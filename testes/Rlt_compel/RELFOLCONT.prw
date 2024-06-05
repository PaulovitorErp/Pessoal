
#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"


User Function RELFOLCONT()

	local oReport
	local cPerg := 'RELFOLCONT'
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
CASE 
WHEN RV_TIPOCOD = '1' THEN 'Provento'
WHEN RV_TIPOCOD = '2' THEN 'Desconto'
WHEN RV_TIPOCOD = '3' THEN 'Base Provento'
WHEN RV_TIPOCOD = '4' THEN 'Base Desconto'
END AS [TipoEvento],
RZ_PD,RV_COD,RV_DESC,RV_LCTOP
FROM 
 %table:SRZ% SRZ 
INNER JOIN  %table:SRV% SRV ON SRZ.RZ_PD = SRV.RV_COD AND SRZ.D_E_L_E_T_ = SRV.D_E_L_E_T_ 
WHERE SRZ.%notdel%
AND RZ_FILIAL BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02% 
AND RV_LCTOP NOT IN ('A50')


ORDER BY RV_LCTOP

	EndSQL

	oSecao1:EndQuery()
	oReport:SetMeter((cAlias)->(RecCount()))
	oSecao1:Print()

return


//+-----------------------------------------------------------------------------------------------+
//! Função para criação da estrutura do relatório. !
//+-----------------------------------------------------------------------------------------------+
Static Function ReportDef(cAlias, cPerg)

	local cTitle := "Relatorio eventos folha"
	local cHelp := "Permite gerar relatorio eventos folha sem contabilização"
	local oReport
	local oSection1


	Pergunte(cPerg, .f.)

	oReport := TReport():New("RELFOLCONT",cTitle,cPerg,{|oReport|ReportPrint(oReport,cAlias)},cHelp)

	Pergunte(oReport:GetParam(),.F.)

//Primeira sessão

	oSection1 := TRSection():New(oReport,"Contabilização Folha",{cAlias})


	ocell2:= TRCell():New(oSection1,"RZ_PD", cAlias,"Cod. Evento")
	ocell:=  TRCell():New(oSection1,"RV_DESC", cAlias,"Descrição do Evento")
	ocell:=  TRCell():New(oSection1,"RV_LCTOP", cAlias,"Lançamento Padrão")
	ocell:=  TRCell():New(oSection1,"TipoEvento", cAlias,"Tipo do Evento")


Return(oReport)












