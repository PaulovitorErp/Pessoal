#Include "Protheus.ch"
#include "TOTVS.CH"


User Function WFW120P()
	// Obtem o n�mero do pedido a partir da fun��o PARAMIXB
	Local cPedido := PARAMIXBdBselectArea('SC7')
	dbSetOrder(1)

	// Busca pelo pedido
	If dbSeek(cPedido)   
		// Percorre todos os itens do pedido atual
		While !Eof() .And. SC7->C7_NUM == cPedido
			// Atualiza o campo C7_CONAPRO para 'L'
			SC7->(RECLOCK("SC7",.F.))
			SC7->C7_CONAPRO := 'L'
			SC7->(MSUNLOCK())
			dbSkip()
		Enddo

	Endif

Return


