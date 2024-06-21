#INCLUDE "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SF1140I º Autor ³ Andre Castilho     º Data ³  31/10/12    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ponto de Entrada na Inclusão da Pre Nota Fiscal            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Elcop                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function SF1140I()
    Local _aSF1 := SF1->( GetArea() )
    Local _aSA1 := SA1->( GetArea() )
    Local _aSD1 := SD1->( GetArea() )
    Local _aSA2 := SA2->( GetArea() )

    if funname()=="MATA140"

           // MsgAlert("Teste Andre ")

    			_DtReceb := U_TelaReceb() 

			DbSelectArea("SD1")
			SD1->(dbSetOrder(1))
			if SD1->(dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
				While SD1->(!Eof() .AND. D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA == xFilial('SD1')+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))
					DbSelectArea("SC7") 
					SC7->(dbSetOrder(1))
					If SC7->(MsSeek(xFilial("SC7")+SD1->(D1_PEDIDO+D1_ITEMPC)))
						DbSelectArea("SA2")
						SA2->( dbSetOrder(1))
						If SA2->(Dbseek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA))
							//Qual o nome do campo da SC7 para comparar ?
							//Qual a logica se a data de recebimento for mairo que o datprf  se for maior, grava 0 no SA2, caso contrario grava 100 ? 

								IF _DtReceb > SC7->C7_DATPRF //Se a data do Recebimento for Maior que o SC7->C7_DATAPRF 
								//qual o campo nota na sa2 peri A2_XNOTLIC
									RecLock( "SA2" , .F. )
										SA2->A2_XNOTLIC := 0
									MsUnLock()	
								Else
									RecLock( "SA2" , .F. )
										SA2->A2_XNOTLIC := 100
									MsUnLock()									
								EndiF

                                XAIQF := (0.4 * SA2->A2_XNOTLIC) + (0.4 * SA2->A2_XIQFMED) + (0.2 * (SA2->A2_XNOTLIC + SA2->A2_XNOTALV + SA2->A2_XNOTDOC / 3)) 
								
                                RecLock( "SA2" , .F. )
								    SA2->A2_XIQF := XAIQF

                                    //Bloqueia Fornecedor
                                    if XAIQF < 60 
                                        SA2->A2_MSBLQL := '1'
                                    Else    
                                        SA2->A2_MSBLQL := '2'
                                    Endif

								MsUnLock()	
                                    
								
						EndIf
					EndIf
				SD1->(DbSkip())			
				enddo
			EndIf	        
        
    endif

    RestArea(_aSF1)
    RestArea(_aSD1)
    RestArea(_aSA2)
    RestArea(_aSA1)
Return(.T.)


User Function TelaReceb()
	Local oButton1
	Local oButton2
	Local oGet1
	Local cGet1 := ddatabase
	Local oSay1
	Local oSay2
	Static oDlg

	DEFINE MSDIALOG oDlg TITLE "Nota Fornecedor" FROM 000, 000  TO 200, 400 COLORS 0, 16777215 PIXEL

		@ 019, 006 SAY oSay1 PROMPT "Data Recebimento: " SIZE 162, 007 OF oDlg COLORS 0, 16777215 PIXEL
		@ 006, 006 SAY oSay2 PROMPT "Informe a Data de Recebimento da Nota Fiscal:" SIZE 158, 007 OF oDlg COLORS 0, 16777215 PIXEL
		
		@ 033, 006 MSGET oGet1 VAR cGet1 SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
		
		@ 082, 159 BUTTON oButton1 PROMPT "Confirmar" SIZE 037, 012 OF oDlg PIXEL ACTION (oDlg:End())    
		@ 082, 117 BUTTON oButton2 PROMPT "Fechar"    SIZE 037, 012 OF oDlg PIXEL ACTION (oDlg:End())    
 
	ACTIVATE MSDIALOG oDlg CENTERED

Return(cGet1)

