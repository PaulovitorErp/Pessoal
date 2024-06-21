#Include "Protheus.ch"
/*
LOCALIZA��O : Function A120PEDIDO - Fun��o do Pedido de Compras responsavel pela inclus�o, altera��o, exclus�o e c�pia dos PCs.
EM QUE PONTO : Se encontra dentro da rotina que monta a dialog do pedido de compras antes  da montagem dos folders e da chamada da getdados.

Autor: Sinval
*/
 
User Function MT120TEL()
    Local aArea     := GetArea()
    Local oDlg      := PARAMIXB[1] 
    Local aPosGet   := PARAMIXB[2]
    Local nOpcx     := PARAMIXB[4]
    Local nRecPC    := PARAMIXB[5]
    Local lEdit     := IIF(nOpcx == 3 .Or. nOpcx == 4 .Or. nOpcx ==  9, .T., .F.) //
    Local oXForpg
    Local oXNumCard

    Public cXForpg := ""
    Public cXNumCard :=""
 
    //Define o conte�do para os campos
    SC7->(DbGoTo(nRecPC))
    If nOpcx == 3
        cXForpg := CriaVar("C7_XFORPG",.F.)
        cXNumCard := CriaVar("C7_XCREDIT",.F.)
    Else
        cXForpg := SC7->C7_XFORPG
        cXNumCard := SC7->C7_XCREDIT
    EndIf

    //Criando na janela o campo OBS
    @ 062, aPosGet[1,08] - 012 SAY Alltrim(RetTitle("C7_XFORPG")) OF oDlg PIXEL SIZE 050,006
    @ 061, aPosGet[1,09] - 006 MSGET oXForpg VAR cXForpg F3 "24" SIZE 30, 006 OF oDlg COLORS 0, 16777215  PIXEL
    @ 062, aPosGet[1,10] - 001 SAY Alltrim(RetTitle("C7_XCREDIT")) OF oDlg PIXEL SIZE 100,006
    @ 061, aPosGet[1,11] - 050 MSGET oXNumCard VAR cXNumCard F3 "W9" SIZE  050, 006 OF oDlg COLORS 0, 16777215 PIXEL 

    oXForpg:bHelp := {|| ShowHelpCpo( "C7_XFORPG", {GetHlpSoluc("C7_XFORPG")[1]}, 5 )}
 
    If !lEdit
        oXForpg:lActive := .F.
        oXNumCard:lActive := .F.
    EndIf
 
    
    RestArea(aArea)
Return
