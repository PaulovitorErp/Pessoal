#Include "Protheus.ch"
#include "TOTVS.CH"

User Function USERPROD()
	
	Local aArea    := GetArea()
	Local aParam   := PARAMIXB
	Local xRet     := .T.
	Local oObj     := NIL
	Local cIdPonto := Space(0)

	If !aParam == NIL
		oObj     := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]

		If cIdPonto == "MODELPOS"
			nOper := oObj:nOperation
			if nOper == 3
				xRet := .F.
				if SuperGetMv("MV_XUSRPRO")$__cUserID
					xRet := .T.
				endif
			endif
            if nOper == 4
				xRet := .F.
				if SuperGetMv("MV_XUSRPRO")$__cUserID
					xRet := .T.
				endif
			endif
		EndIf
	EndIf

    If xRet == .F.

    FWAlertHelp("Não é permitido Inclusão/Alteração do Produto! Procure o departamento Responsavel","MV_XUSRPRO")

    endif

	RestArea(aArea)
	
return(xRet)
