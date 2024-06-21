#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"

User Function LIBSC7()

	Local aSays        := {}
	Local aButtons     := {}
	Local lOk          := .F.
	Local cPerg        := "LIBSC7"
	Local cUser        := __cUserID
	local cAlias       := getNextAlias()
	Local xRet         := .F.

	if __cUserID$SuperGetMv("MV_XUSRPED")
		xRet := .T.
	endif
//Popula as linhas que ser�o mostradas na tela
	aAdd(aSays, "Esse programa tem como objetivo aprovar pedidos de compras em massa!")


//Bot�es da tela, cada bot�o tem um Bloco de C�digo
	aAdd(aButtons, { 5, .T., {|| Pergunte(cPerg, .T. ) } } )
	aAdd(aButtons, { 1, .T., {|| lOk := .T., FechaBatch() }} )
	aAdd(aButtons, { 2, .T., {|| lOk := .F., FechaBatch() }} )

//Chama a tela principal
	FormBatch("Aprovar pedidos", aSays, aButtons)

//Se foi confirmado a tela

	If lOk
		If xRet = .T.
			BeginSQL Alias cAlias

 SELECT C7_FILIAL, C7_NUM,C7_ITEM,C7_SEQUEN
 FROM %table:SC7% SC7
 WHERE SC7.%notdel%
 AND C7_FILIAL BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02% 
 AND C7_NUM    BETWEEN %exp:MV_PAR03% AND %exp:MV_PAR04% 
 AND C7_CONAPRO='B'


			EndSQL

			WHILE !(cAlias)->(EOF())

				IF SC7-> ( DBSETORDER(1),DBSEEK( (cAlias)->C7_FILIAL + (cAlias)->C7_NUM + (cAlias)->C7_ITEM + (cAlias)->C7_SEQUEN )) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
					SC7->(RECLOCK("SC7",.F.))
					SC7->C7_CONAPRO = 'L'
					SC7->(MSUNLOCK())
				ENDIF
				(cAlias)->(DBSKIP())

			ENDDO




		Endif
	EndIf
	If xRet = .F.
		MsgInfo("Usuario sem permissao para executar essa rotina!", "Atencao")
	Endif
	If xRet = .T.
		MsgInfo("Pedidos Liberados com Sucesso!", "Atencao")
	Endif
Return

