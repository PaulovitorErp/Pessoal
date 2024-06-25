#include "TOTVS.CH"


User Function WFW120P()
	// Obtem o número do pedido a partir da função PARAMIXB
	Local cPedido := PARAMIXB
	Local cUser   := __cUserID
	Local cincuser := SuperGetMv("MV_XUSINCP")

	dBselectArea('SC7')
	dbSetOrder(1)

	// Busca pelo pedido
	if cUser$cincuser
		If dbSeek(cPedido)
			// Percorre todos os itens do pedido atual
			While !Eof() .AND. SC7->C7_FILIAL + SC7->C7_NUM == cPedido

				// Atualiza o campo C7_CONAPRO para 'L'
				SC7->(RECLOCK("SC7",.F.))
				SC7->C7_CONAPRO = 'L'
				SC7->(MSUNLOCK())
				dbSkip()
			Enddo


		Endif
	Endif
Return


