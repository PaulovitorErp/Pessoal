/*             
https://tdn.totvs.com/display/public/mp/F50DTDSD+-+Calcula+parcelas+do+desdobramento+--+11824
https://centraldeatendimento.totvs.com/hc/pt-br/articles/360031234634--MP-SIGAFIN-FINA050-Pontos-de-Entrada

https://centraldeatendimento.totvs.com/hc/pt-br/articles/360018602371-MP-SIGAFIN-FINA050-Cancelamento-de-Desdobramento

verificar o Parâmetro MV_NRASDSD

Ponto-de-Entrada: F50DTDSD - Calcula parcelas do desdobramento
Descrição:
Este ponto de entrada manipula data inicial para cálculo das parcelas do desdobramento. 
Esta data será usada como base para o calculo dos vencimentos das parcelas geradas
Programa Fonte

Sintaxe
F50DTDSD - Calcula parcelas do desdobramento ( < UPAR> ) --> URET

Retorno
URET(qualquer)
Data desejada como base para calculo dos venctos das parcelas
*/

user function F50DTDSD
Local oDlg, oButton
private dDatRet := M->E2_VENCREA
                                                       
DEFINE MSDIALOG oDlg FROM 0,0 TO 150,280 PIXEL TITLE 'Data Inicial de Vencimento'
oSay := TSay():New( 05, 10, {|| 'Data Inicial Vencimento:'},oDlg,, ,,,, .T.,,)
oSay:lTransparent:= .F.			
			                                            
oGet1:= TGet():New(05,80,{|u| if(PCount()>0,dDatRet:=u,dDatRet)},oDlg,40,10,'99/99/9999',,,,,,,.T.,,,,,,,,,,'dDatRet')
                        //Vert,Hor                      larg,altura
oButton:=tButton():New(45,050,'Ok',oDlg,{||oDlg:End()},40,15,,,,.T.)
ACTIVATE MSDIALOG oDlg CENTERED

return(dDatRet)