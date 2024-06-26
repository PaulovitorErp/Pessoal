#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NOVO11    �Autor  �Microsiga           � Data �  05/19/18   ���
�������������������������������������������������������������������������͹��
���Desc.     �Adiciona Menus Customizados no Pedido de Compras            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Illuminato                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MT120BRW()
	Local area 	  := GetArea()

	aadd(aRotina,{"Forma de Pagamento"     ,"U_ACOM013()"    , 0, 2, 0, NIL }) 
				
	RestArea(area)
Return()

User Function ACOM013()

    Private oButton1
    Private oButton2
    Private oGet1
    Private cGet1 := SC7->C7_XFORPG
    Private oGroup1
    Private oSay1
    Static oDlg

    DEFINE MSDIALOG oDlg TITLE "Selecione a Forma de Pagamento:" FROM 000, 000  TO 150, 500 COLORS 0, 16777215 PIXEL

        @ 003, 005 GROUP oGroup1 TO 058, 244 PROMPT "Digite a Forma de Pagamento: " OF oDlg COLOR 0, 16777215 PIXEL
        @ 018, 015 SAY oSay1 PROMPT "Forma de Pagamento:" SIZE 084, 007 OF oDlg COLORS 0, 16777215 PIXEL    
        @ 030, 015 MSGET oGet1 VAR cGet1 SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL F3 "24"   

        @ 060, 206 BUTTON oButton1 PROMPT "Gravar" SIZE 037, 012 OF oDlg PIXEL Action( GrvForPg() )
        @ 060, 160 BUTTON oButton2 PROMPT "Fechar" SIZE 037, 012 OF oDlg PIXEL Action( oDlg:End() )

    ACTIVATE MSDIALOG oDlg CENTERED

Return()

Static Function GrvForPg()
	RecLock("SC7",.F.)		
	    SC7->C7_XFORPG 		:= Alltrim(cGet1)
	SC7->(MsUnLock())
    oDlg:End()
Return()
