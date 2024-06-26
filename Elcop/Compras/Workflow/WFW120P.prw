#include 'Protheus.ch'
#include 'TOPConn.ch'
#include 'Rwmake.ch'
#include "TbiConn.ch"
#include "TbiCode.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �WFW120P   �Autor  �Andre Castilho	     � Data �  27/01/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada para envio de Workflow na apos confirmacao ���
���          �da Pedido de Compra			                              ���
�������������������������������������������������������������������������͹��
�������������������������������������������������������������������������ͻ��
���Data      � Descricao:                                                 ���
�������������������������������������������������������������������������͹��
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function WFW120P(nOpcao,oProcess,cNivelWF )
	Local cNivelWf    := {}
	Local cAtivaWF    := SuperGetMv("MV_XWORKPC",,.T.) //Logico // Ativa Processo Workflow Sim ou Nao.
	Local aArea  	  := GetArea()
	Local aAreaSCR    := SCR->(GetArea())
	Local aAreaSC7	  := SC7->(GetArea())
	Local lWF         := .T.

	IF cAtivaWF

		If IsBlind()  //Caso seja Workflow ou ExecAuto.

			if FUNNAME() <> 'CNTA120'

				ConOut("************Retorno Workflow******************")
					U_ACOMP003(nOpcao, oProcess,' ')

			EndIf
		Else		

			cNivelWf := U_UltiAprov(SC7->C7_FILIAL,SC7->C7_NUM,'PC')
					U_ACOMP003(nOpcao, oProcess,cNivelWf[1][1],,,altera)				
		Endif

	EndIf

	RestArea(aArea)
	RestArea(aAreaSCR)
	RestArea(aAreaSC7)
Return .T.
