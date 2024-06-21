#Include "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � PROXSB1  � Autor � Adriano Reis        � Data �28/02/2019  ���
�������������������������������������������������������������������������͹��
���Desc.     � Proximo Numera��o Cadastro de MOTORISTAS          		  ���
�������������������������������������������������������������������������͹��
���Uso       � 				                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


User Function PROXDA4(_alias,_campo)

	LOCAL _CLOCAL	:= GETAREA()
	LOCAL _NPROX	:= ''
	LOCAL _CCAMPO	:= _campo
	LOCAL _CALIAS	:= _alias
	LOCAL _TAM		:= 6

cQry := "	SELECT MAX(CAST(DA4_COD AS CHAR)) PROX "
cQry += "	FROM DA4010"
cQry += "	WHERE D_E_L_E_T_<> '*' "
cQry += "	AND DA4_COD NOT LIKE 'TERCEIROS%' "
cQry += "	AND DA4_COD NOT LIKE 'MANUTENCAO%' "
cQry += "	AND DA4_COD NOT LIKE 'MOD%' "
cQry += "	AND DA4_COD NOT LIKE '999991%' "
cQry += "	AND DA4_COD NOT LIKE '999990%' "
cQry += "	AND DA4_COD NOT LIKE '5719%' "
cQry += "	AND DA4_COD NOT LIKE '2704%' "
cQry += "	AND DA4_COD NOT LIKE '1208%' "
cQry += "	AND DA4_COD NOT LIKE '03290%' "
cQry += "	AND DA4_COD NOT LIKE '03134%' "
cQry += "	AND DA4_COD NOT LIKE '03132%' "
cQry += "	AND DA4_COD NOT LIKE '03131%' "
cQry += "	AND DA4_COD NOT LIKE '03007%' "
cQry += "	AND DA4_COD NOT LIKE '03130%' "
cQry += "	AND DA4_COD NOT LIKE '02604%'"
cQry += "	AND DA4_COD NOT LIKE 'E%'"


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
/*
