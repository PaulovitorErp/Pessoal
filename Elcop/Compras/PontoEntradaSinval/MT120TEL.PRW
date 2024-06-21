#Include "Protheus.ch"
/*
LOCALIZAÇÃO : Function A120PEDIDO - Função do Pedido de Compras responsavel pela inclusão, alteração, exclusão e cópia dos PCs.
EM QUE PONTO : Se encontra dentro da rotina que monta a dialog do pedido de compras antes  da montagem dos folders e da chamada da getdados.

Autor: Sinval
*/
 
User Function MT120TEL()
    Local aArea     := GetArea()
    Local oDlg      := PARAMIXB[1] 
    Local aPosGet   := PARAMIXB[2]
    Local nOpcx     := PARAMIXB[4]
    Local nRecPC    := PARAMIXB[5]
    Local lEdit     := IIF(nOpcx == 3 .Or. nOpcx == 4 .Or. nOpcx ==  9, .T., .F.) //Somente será editável, na Inclusão, Alteração e Cópia
    Local oXForpg

    Public cXForpg := ""
 
    //Define o conteúdo para os campos
    SC7->(DbGoTo(nRecPC))
    If nOpcx == 3
        cXForpg := CriaVar("C7_XFORPG",.F.)
    Else
        cXForpg := SC7->C7_XFORPG
    EndIf
 
    //Criando na janela o campo OBS
    @ 062, aPosGet[1,08] - 012 SAY Alltrim(RetTitle("C7_XFORPG")) OF oDlg PIXEL SIZE 050,006
    @ 061, aPosGet[1,09] - 006 MSGET oXForpg VAR cXForpg F3 "24" SIZE 30, 006 OF oDlg COLORS 0, 16777215  PIXEL
    oXForpg:bHelp := {|| ShowHelpCpo( "C7_XFORPG", {GetHlpSoluc("C7_XFORPG")[1]}, 5 )}
 
    If !lEdit
        oXForpg:lActive := .F.
    EndIf
 
    RestArea(aArea)
Return
