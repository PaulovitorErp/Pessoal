#include "rwmake.ch"

//EM QUE PONTO : Apos a atualizacao do SC8 (Cotacoes)

User Function MT150GRV()

    /*
    Private oButton1
    Private oButton2
    Private oGet1
  //  Private cGet1 := SC8->C8_XFORPG
    Private oGroup1
    Private oSay1
    Static oDlg
    */
    //DEFINE MSDIALOG oDlg TITLE "Selecione a Forma de Pagamento:" FROM 000, 000  TO 150, 500 COLORS 0, 16777215 PIXEL

 //       @ 003, 005 GROUP oGroup1 TO 058, 244 PROMPT "Digite a Forma de Pagamento:" OF oDlg COLOR 0, 16777215 PIXEL
//        @ 018, 015 SAY oSay1 PROMPT "Forma de Pagamento:" SI(ZE 084, 007 OF oDlg COLORS 0, 16777215 PIXEL    
//        @ 030, 015 MSGET oGet1 VAR cGet1 SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL F3 "24"   

//        ACTIVATE MSDIALOG oDlg CENTERED
    

  //  TelaNotaFor()

RETURN()

