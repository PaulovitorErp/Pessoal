#Include 'Protheus.ch'
User Function F370E2F()
local cQry := PARAMIXB

cQRY := StrTran(cQRY,"AND E2_TIPO NOT IN ('PR ')","")


Return cQry
  