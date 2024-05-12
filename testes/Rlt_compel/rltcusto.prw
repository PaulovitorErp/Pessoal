USER FUNCTION GerarRelatorioClientes()
    BEGIN SQL
        LOCAL cSQL := "SELECT Nome, Endereco FROM Clientes"
        INTO :Nome, :Endereco
        FROM DBCENTRAL
    END SQL

    // Crie um objeto TReport para o relatório
    LOCAL oReport := TReport():New()
    oReport:Start()
    oReport:Create()
    oReport:SetReportName("RelatorioClientes")
    
    // Defina as configurações do relatório, como layout e estilo
    oReport:SetLayout("Standard.lay")
    oReport:SetStyle("Standard.sty")
    
    // Adicione os campos do resultado da consulta ao relatório
    oReport:AddField("Nome", Nome)
    oReport:AddField("Endereco", Endereco)
    
    // Gere o relatório
    oReport:End()
    
    // Libere os recursos
    oReport:Release()
    
RETURN .T.
