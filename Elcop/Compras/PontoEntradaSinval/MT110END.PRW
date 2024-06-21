/*
LOCALIZAÇÃO : Function A110APROV - Função da Solicitação de Compras responsavel pela aprovação das SCs.

EM QUE PONTO : Após o acionamento dos botões Solicitação Aprovada, Rejeita ou Bloqueada, deve ser utilizado para validações do usuario 
após a execução das ações dos botões.

Autor: Sinval

*/
#include "totvs.ch"

User Function MT110END()

    Local nNumSC    := PARAMIXB[1]       // Numero da Solicitação de compras 
    Local nOpca     := PARAMIXB[2]       // 1 = Aprovar; 2 = Rejeitar; 3 = Bloquear // Validações do Usuario
    Local oDlg, oButton, cObs

    if SC1->(DbSeek(xFilial("SC1")+nNumSC))
        cObs := SC1->C1_OBS
    else
        cObs := space(100)
    endif

    if nOpca = 2 .or. nOpca = 3
                                                       
        DEFINE MSDIALOG oDlg FROM 0,0 TO 150,480 PIXEL TITLE 'Observações Rejeição/Bloqueio'
    
        oSay := TSay():New( 05, 10, {|| 'Observações: '},oDlg,, ,,,, .T.,,)
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
