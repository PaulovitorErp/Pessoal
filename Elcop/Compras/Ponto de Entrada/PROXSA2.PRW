#Include "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PROXSB1  บ Autor ณ Adriano Reis        บ Data ณ28/02/2019  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Proximo Numera็ใo Cadastro de Produtos           		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 				                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


User Function PROXSA2(_alias,_campo)

	LOCAL _CLOCAL	:= GETAREA()
	LOCAL _NPROX	:= ''
	LOCAL _CCAMPO	:= _campo
	LOCAL _CALIAS	:= _alias
	LOCAL _TAM		:= 6

cQry := "  SELECT MAX(CAST(A2_COD AS CHAR)) PROX "
cQry += " FROM SA2010 "
cQry += " WHERE D_E_L_E_T_<> '*' "
cQry += " AND A2_COD NOT LIKE 'INPS%' "
cQry += " AND A2_COD NOT LIKE '6000%' "
cQry += " AND A2_COD NOT LIKE '5590%' "
cQry += " AND A2_COD NOT LIKE '5166%' "
cQry += " AND A2_COD NOT LIKE '6003%' "
cQry += " AND A2_COD NOT LIKE '6002%' "
cQry += " AND A2_COD NOT LIKE '6001%' "
cQry += " AND A2_COD NOT LIKE '07010%' "
cQry += " AND A2_COD NOT LIKE '07009%' "
cQry += " AND A2_COD NOT LIKE '07008%' "
cQry += " AND A2_COD NOT LIKE '07007%' "
cQry += " AND A2_COD NOT LIKE '07009%' "
cQry += " AND A2_COD NOT LIKE '07006%' "
cQry += " AND A2_COD NOT LIKE '07005%' "  
cQry += " AND A2_COD NOT LIKE '07004%' " 
cQry += " AND A2_COD NOT LIKE '07002%' "
cQry += " AND A2_COD NOT LIKE '07001%' "
cQry += " AND A2_COD NOT LIKE '07000%' "
cQry += " AND A2_COD NOT LIKE '06999%' "         


	If Select("QAUX") > 0
		QAUX->(dbCloseArea())
	EndIf

	cQry := ChangeQuery(cQry)
	dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQry), "QAUX", .F., .T.)

	IF EMPTY(QAUX->PROX)
		_NPROX  := STRZERO(1,_TAM)
	ELSE
		_NPROX 	:= STRZERO(val(QAUX->PROX)+1,_TAM)
		_NAUX   := VAL(_NPROX)

		FreeUsedCode()
		While !MayIUseCode(_CALIAS+xFilial(_CALIAS)+STRZERO(_NAUX,_TAM))
			_NAUX+=1
		EndDo

		_NPROX:= STRZERO(_NAUX,_TAM)

	ENDIF

	QAUX->(DBCLOSEAREA())

Return(_NPROX)
