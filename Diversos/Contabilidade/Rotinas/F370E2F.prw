#Include 'Protheus.ch'
User Function F370E2F()
local cQry := PARAMIXB

cQry += " AND SE2.E2_TIPO = 'PR' "
cQry += " AND SE2.E2_PREFIXO = 'EMP' "
cQry += " AND SE2.E2_ORIGEM = 'FINA171' "
cQry += " AND SE2.E2_JUROS > 0 "

Return cQry
  