#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE 'RESTFUL.CH'
#INCLUDE "topconn.ch"
#INCLUDE "TBICONN.CH"


User Function PROXSRA(_alias,_campo)

	LOCAL _CLOCAL	:= GETAREA()
	LOCAL _NPROX	:= ''
	LOCAL _CCAMPO	:= _campo
	LOCAL _CALIAS	:= _alias
	LOCAL _TAM		:= 6

cQry := "  SELECT MAX(CAST(RA_MAT AS CHAR)) PROX "
cQry += " FROM SRA010 "
cQry += " WHERE D_E_L_E_T_<> '*' "
        
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