#include 'Protheus.ch'
#include 'TOPConn.ch'
#include 'Rwmake.ch'
#include "TbiConn.ch"
#include "TbiCode.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT160WF   ºAutor  ³Andre Castilho      º Data ³  27/01/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada para envio de Workflow na apos confirmacao º±±
±±º          ³do Pedido de Compra	NA ANALISE DE COTACAO		          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Acelerador Totvs Goias                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º	Dados Adicionais de Alteracao/Ajustes do Fonte                        º±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºData      ³ Descricao:                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
user function MT160WF()
	Local aArea  		:= GetArea()
	Local aAreaSCR		:= SCR->(GetArea())
	Local aAreaSAL		:= SAL->(GetArea())
	Local aAreaSC7		:= SC7->(GetArea())
	Local cNivelWf    	:= {}
	Local cAtivaWF    	:= SuperGetMv("MV_XWORKPC",,.T.) //Logico // Ativa Processo Workflow Sim ou Nao.
	Local lWF         	:= .T.
	Local cFilSC7    	:= SC7->C7_FILIAL
	Local cNumSc7    	:= SC7->C7_NUM                                

	IF cAtivaWF
		DbSelectArea("SC7")   //Posiciona Novamente na SC7
		SC7->(DbGotop())
		SC7->(dbSetOrder(1))
		IF SC7->(DbSeek(cFilSC7+cNumSc7))    
			cNivelWf := U_UltiAprov(SC7->C7_FILIAL,SC7->C7_NUM,'PC')
			U_ACOMP003(,,cNivelWf[1][1],,,)				
		Else
			Alert('Pedido Não Encontrado')
		EndIf
	EndIf

	fvalnotafoR() //Funcao WF Fornecedor

	AVISO("Workflow","Pedido de Compra Gerado - N° "+cNumSc7,{"Fechar"},1) 

	RestArea(aArea)
	RestArea(aAreaSCR)
	RestArea(aAreaSAL)
	RestArea(aAreaSC7)
Return()

Static FUnction fvalnotafoR()

	Local cForneceF := SC8->C8_FORNECE
	Local cLojaF    := SC8->C8_LOJA

	If Select("TRBSC7") > 0;TRBSC7->(DbCloseArea());EndIf

	cQuery := " SELECT DISTINCT(C7_FILIAL) , C7_NUM "
	cQuery += " FROM SC7010 "
	cQuery += " WHERE C7_NUMCOT   = '"+SC8->C8_NUM+"'"
	cQuery += " AND   C7_FILIAL   = '"+SC8->C8_FILIAL+"'"
	Tcquery cQuery new Alias "TRBSC7"

	WHILE !TRBSC7->(EOF())

		cNumPc      := TRBSC7->C7_NUM
		cxFilial    := TRBSC7->C7_FILIAL
		cProduto    := ""
		nPrecoTotal := 0
		nQtdTotal   := 0
		XAIQF       := 0
		nDiv  	    := 0
		nMedProd    := 0
		nQtdProd    := 0 
		nDiv2       := 0

		// percorro todos itens da SC7 da Proposta Ganhadora
		DbselectArea("SC7")
		SC7->(Dbsetorder(1))
		If SC7->(Dbseek(xFilial("SC7")+cNumPC))
			While !SC7->( Eof() ) .and. SC7->C7_FILIAL+SC7->C7_NUM = cxFilial+cNumPc
				
				nQtdProd := 0
				nMedProd := 0

				If Select("TRBHIST") > 0;TRBHIST->(DbCloseArea());EndIf

				// Historico das 3 ultimas cotacoes
				cQuery := " SELECT TOP 3 C8_FILIAL , C8_NUM ,C8_PRODUTO , C8_PRECO , C8_QUANT "
				cQuery += " FROM SC8010 "
				cQuery += " WHERE C8_NUM       <> '"+SC8->C8_NUM+"'  "
				cQuery += " AND   C8_FORNECE    = '"+SC8->C8_FORNECE+"'"
				cQuery += " AND   C8_PRODUTO    = '"+SC7->C7_PRODUTO+"'"
				Tcquery cQuery new Alias "TRBHIST"

				WHILE !TRBHIST->(EOF())

					nQtdProd++
					nMedProd += TRBHIST->C8_PRECO 

				TRBHIST->(DBSKIP())
				ENDDO

				If Select("TRBHIST") > 0;TRBHIST->(DbCloseArea());EndIf

				nDiv2 := nMedProd / nQtdProd
				
				nPrecoTotal += nDiv2
				nQtdTotal++

				//nPrecoTotal += SC7->C7_PRECO 
				//nQtdTotal++

			SC7->(DBSKIP())
			EndDo
		Endif	

		nDiv := nPrecoTotal / nQtdTotal 

		dbSelectArea('SA2')
		SA2->( dbSetOrder(1) )
		if SA2->( dbSeek(xFilial('SA2')+cForneceF+cLojaF) )

			if Reclock("SA2",.F.)
				SA2->A2_XIQFMED := nDiv
				SA2->(MsUnlock())
			endif

			XAIQF := (0.4 * SA2->A2_XNOTLIC) + (0.4 * SA2->A2_XIQFMED) + (0.2 * (SA2->A2_XNOTLIC + SA2->A2_XNOTALV + SA2->A2_XNOTDOC / 3)) 

			if Reclock("SA2",.F.)
				SA2->A2_XIQF := XAIQF

					//Bloqueia Fornecedor
					if XAIQF < 60 
						SA2->A2_MSBLQL := '1'
					Else
						SA2->A2_MSBLQL := '2'
					EndiF

				SA2->(MsUnlock())
			endif
			
		EndIf

	TRBSC7->(DBSKIP())
	ENDDO

	If Select("TRBSC7") > 0;TRBSC7->(DbCloseArea());EndIf
	

Return()


/*A2_XNOTLIC   NOTA ENTREGA
A2_XNOTAVL     CORDIALIDADE
A2_XNOTDOC     NEGOCIAÇÃO
A2_XNOTCOM     FORMA PAGAMENTO
A2_XIQF        IQF FORNECEDOR

A2_XIQF :=((0.4 * A2_XNOTLIC) + (0.4 * A2_XIQFMED) + (0.2 * (A2_XNOTLIC + A2_XNOTAVL + A2_XNOTDOC / 3))    		
SE A2_XIQF FOR MENOR OU IGUAL A 60, O FORNECEDOR SERÁ BLOQUEADO.

*/
