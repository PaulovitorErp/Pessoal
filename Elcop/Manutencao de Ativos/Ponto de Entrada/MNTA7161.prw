//----------------------------------------------------------------------------
/*/{Protheus.doc} MNTA7161
Realiza verificação por linha se deve importar os registros de abastecimentos. 
 
@type function

@author Sinval 
@since 01/05/2020

@sample MNTA7161()

@param 
@return lRetorno
/*/
//----------------------------------------------------------------------------

#Include 'PROTHEUS.ch'

User Function MNTA7161()
Local lRetorno  := .T.
Local _aAreas 	:= getArea()  

ST9->(DbSetOrder(14))
if ST9->(DbSeek(AINCLTR6[5][1]))
	if Posicione("ST9",14,AINCLTR6[5][1],"T9_LUBRIFI") = "2"
		lRetorno := .F.
	endif
else
	lRetorno := .T.	
endif

if lRetorno
	TR6->(DbSetOrder(1))
	if TR6->(DbSeek( alltrim(AINCLTR6[9][1])) )
		if TR6->TR6_PLACA = alltrim(AINCLTR6[5][1])
			lRetorno := .F. // não irá importar o Lançamento
		else
			AINCLTR6[9][1] := alltrim(str(val(AINCLTR6[9][1])+1))
		endif	
	endif
endif

if lRetorno
	AINCLTR6[1][1] := AINCLTR6[1][1] / 100	
	AINCLTR6[2][1] := AINCLTR6[2][1] / 100
	AINCLTR6[8][1] := "00604122000197"       

	if AINCLTR6[6][1] = "002" //ETANOL COMUM
		AINCLTR6[6][1] := "001"   
	elseif AINCLTR6[6][1] = "004" //DIESEL COMUM
		AINCLTR6[6][1] := "003"   
	elseif AINCLTR6[6][1] = "006" // GASOLINA COMUM
		AINCLTR6[6][1] := "002"   	
	elseif AINCLTR6[6][1] = "012" // DIESEL S-10
		AINCLTR6[6][1] := "005"   
	endif	

	AINCLTR6[10][1] := "99999999999" //CPF PADRÃO
	AINCLTR6[11][1] := "8" //Codigo do Convênio               
endif	        
restArea(_aAreas)	       
Return lRetorno
