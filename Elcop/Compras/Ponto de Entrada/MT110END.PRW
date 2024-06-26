/*
LOCALIZA��O : Function A110APROV - Fun��o da Solicita��o de Compras responsavel pela aprova��o das SCs.

EM QUE PONTO : Ap�s o acionamento dos bot�es Solicita��o Aprovada, Rejeita ou Bloqueada, deve ser utilizado para valida��es do usuario 
ap�s a execu��o das a��es dos bot�es.

Autor: Sinval

*/
#include "totvs.ch"

User Function MT110END()

    Local nNumSC    := PARAMIXB[1]       // Numero da Solicita��o de compras 
    Local nOpca     := PARAMIXB[2]       // 1 = Aprovar; 2 = Rejeitar; 3 = Bloquear // Valida��es do Usuario
    Local oDlg, oButton, cObs

    if SC1->(DbSeek(xFilial("SC1")+nNumSC))
        cObs := SC1->C1_OBS
    else
        cObs := space(100)
    endif

    if nOpca = 2 .or. nOpca = 3
                                                       
        DEFINE MSDIALOG oDlg FROM 0,0 TO 150,480 PIXEL TITLE 'Observa��es Rejei��o/Bloqueio'
    
        oSay := TSay():New( 05, 10, {|| 'Observa��es: '},oDlg,, ,,,, .T.,,)
        oSay:lTransparent:= .F.			
			                                            
        oGet1   := TGet():New(05,50,{|u| if(PCount()>0,cObs:=u,cObs)},oDlg,150,10,'@!',, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cObs",,,,.T.)
                        //Vert,Hor                      larg,altura
        oButton := tButton():New(45,050,'Ok',oDlg,{||oDlg:End()},40,15,,,,.T.)
    
        ACTIVATE MSDIALOG oDlg CENTERED

        if SC1->(DbSeek(xFilial("SC1")+nNumSC))
            SC1->(RecLock("SC1",.F.))
            SC1->C1_OBS := cObs
            SC1->(msUnLock())
        endif

    endif

return()
