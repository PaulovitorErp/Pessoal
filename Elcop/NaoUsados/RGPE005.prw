#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#Include "PROTHEUS.CH"



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRGPE012   บAutor  Andre Castilho       บ Data ณ  06/10/2021 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTela para Imprimir Relatorios de Rescisao.                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Elcop - Engenharia                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


User Function RGPE005()

Private oBitmap1
	Private oButton1
	
	Private oButton2
	Private oButton3
	Private oCheckBo1
	Private lCheckBo1 := .F.
	Private oCheckBo2
	Private lCheckBo2 := .F.
	Private oCheckBo3
	Private lCheckBo3 := .F.
	Private oCheckBo4
	Private lCheckBo4 := .F.
	Private oCheckBo5
	Private lCheckBo5 := .F.
	Private oCheckBo6
	Private lCheckBo6 := .F.
	Private oCheckBo7
	Private lCheckBo7 := .F.
	Private oCheckBo8
	Private lCheckBo8 := .F.
	Private oGet1
	Private cGet1 := Space((TamSX3("RA_FILIAL")[1]))
	Private oGet2
	Private cGet2 := 'ZZZZ' //Space((TamSX3("RA_FILIAL")[1]))
	Private oGet3
	Private cGet3 := Space((TamSX3("RA_MAT")[1]))          
	Private oGet4
	Private cGet4 := 'ZZZZZZ'//Space((TamSX3("RA_MAT")[1]))
	Private oGet5
	Private cGet5 := Space((TamSX3("RA_CC")[1]))
	Private oGet6
	Private cGet6 := 'ZZZZZZZZZ'//Space((TamSX3("RA_CC")[1]))
	Private oSay1
	Private oSay2
	Private oSay3
	Private oSay4
	Private oSay5
	Private oSay6
	Private oSay7
	Private CLINKLOGO := 'https://i.ibb.co/D91LPcS/logo.png'
	Private oOk := LoadBitmap( GetResources(), "LBOK")
	Private oNo := LoadBitmap( GetResources(), "LBNO")
	Private oWBrowse1
	Private aWBrowse1 := {}

	Static oDlg

	DEFINE MSDIALOG oDlg TITLE "Tela de Demitidos" FROM 000, 000  TO 550, 1000 COLORS 0, 16777215 PIXEL

	//
  //  fWBrowse1()

	@ 261, 459 BUTTON oButton1 PROMPT "Imprimir" SIZE 037, 012 OF oDlg PIXEL  Action Processa({|| imprel() },"Imprimindo.","Aguarde...")
	@ 261, 419 BUTTON oButton2 PROMPT "Fechar" SIZE 037, 012 OF oDlg PIXEL Action odlg:end()
//  @ 001, 240 SAY oSay1 PROMPT "Relatorio Folha de Pagamento:" SIZE 088, 007 OF oDlg COLORS 0, 16777215 PIXEL
//	@ 013, 285 MSGET oGet1 VAR cGet1 SIZE 060, 010 OF oDlg COLORS 0, 16777215 F3 "SM0" PIXEL
//	@ 015, 259 SAY oSay2 PROMPT "Filial De :" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
//	@ 015, 361 SAY oSay3 PROMPT "Filial Ate:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 002, 125 MSGET oGet1 VAR cGet1 SIZE 060, 010 OF oDlg COLORS 0, 16777215 F3 "SM0" PIXEL
    @ 022, 125 MSGET oGet2 VAR cGet2 SIZE 060, 010 OF oDlg COLORS 0, 16777215 F3 "SM0" PIXEL
	@ 004, 100 SAY oSay2 PROMPT "Filial De :" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 024, 100 SAY oSay3 PROMPT "Filial Ate:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 012, 458 BUTTON oButton3 PROMPT "Pesquisar" SIZE 037, 012 OF oDlg PIXEL Action Processa({|| PesqSRA() },"Processando Registros.","Aguarde...")
	
	@ 004, 240 SAY oSay4 PROMPT "Mat De:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 004, 260 MSGET oGet3 VAR cGet3 SIZE 060, 010 OF oDlg COLORS 0, 16777215 F3 "SRA" PIXEL
	@ 024, 240 SAY oSay5 PROMPT "Mat Ate:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 024, 260 MSGET oGet4 VAR cGet4 SIZE 060, 010 OF oDlg COLORS 0, 16777215 F3 "SRA" PIXEL 
	@ 001, 003 BITMAP oBitmap1 SIZE 150, 052 OF oDlg NOBORDER PIXEL FILENAME "\system\LGMID"+ALLTRIM(cEmpant)+"_rh.png" NOBORDER PIXEL
	@ 004, 360 SAY oSay6 PROMPT "Data Demissao de:" SIZE 030, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 004, 380 MSGET oGet5 VAR cGet5 SIZE 060, 010 OF oDlg COLORS 0, 16777215 F3 "SRA" PIXEL
	@ 024, 400 MSGET oGet6 VAR cGet6 SIZE 060, 010 OF oDlg COLORS 0, 16777215 F3 "SRA" PIXEL
	@ 024, 390 SAY oSay7 PROMPT "Data Demissao Ate:" SIZE 031, 007 OF oDlg COLORS 0, 16777215 PIXEL

//	@ 004, 100 CHECKBOX oCheckBo1 VAR lCheckBo1 PROMPT "Autoriza็ใo Desconto " 	 	SIZE 080, 008 OF oDlg COLORS 0, 16777215 PIXEL
//	@ 024, 100 CHECKBOX oCheckBo2 VAR lCheckBo2 PROMPT "Contrato De Trabalho "  	SIZE 080, 008 OF oDlg COLORS 0, 16777215 PIXEL
//	@ 035, 100 CHECKBOX oCheckBo3 VAR lCheckBo3 PROMPT "Termo Recebimento Plano de Saude, Cracha, Refei็ใo" 	  SIZE 180, 008 OF oDlg COLORS 0, 16777215 PIXEL
//	@ 014, 003 CHECKBOX oCheckBo4 VAR lCheckBo4 PROMPT "Av.Periodo Exp " 	  	  	SIZE 080, 008 OF oDlg COLORS 0, 16777215 PIXEL
//	@ 024, 003 CHECKBOX oCheckBo5 VAR lCheckBo5 PROMPT "Acordo Comp.Jornada " 	  	SIZE 080, 008 OF oDlg COLORS 0, 16777215 PIXEL
//	@ 035, 003 CHECKBOX oCheckBo6 VAR lCheckBo6 PROMPT "Termo Conf.Sigilo " 	  	SIZE 080, 008 OF oDlg COLORS 0, 16777215 PIXEL
//	@ 014, 100 CHECKBOX oCheckBo7 VAR lCheckBo7 PROMPT "Comp.Ent Cart Trab" 	 	SIZE 080, 008 OF oDlg COLORS 0, 16777215 PIXEL
//	@ 001, 003 CHECKBOX oCheckBo7 VAR lCheckBo8 PROMPT "Termo HAR" 	 	            SIZE 080, 008 OF oDlg COLORS 0, 16777215 PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

Return()
