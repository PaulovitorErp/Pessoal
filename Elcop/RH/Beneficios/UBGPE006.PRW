#Include "PROTHEUS.CH"
#include "topconn.ch"   
#INCLUDE 'FWMVCDEF.CH' 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ UBGPE006 º Autor ³ Adriano Reis        º Data ³28/02/2019  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Fechamento Beneficios por Periodo                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ELCOP                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function UBGPE006()

Local oButton1
Local oButton2
Local oButton3
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Static oDlg

Private cPerg := Padr("UBGPE006",10) 

  DEFINE MSDIALOG oDlg TITLE "Fechamento Beneficios ELCOP" FROM 000, 000  TO 300, 600 COLORS 0, 16777215 PIXEL

	@ 004, 004 GROUP oGroup1 TO 130, 300 PROMPT "Processamento Fechamento Beneficios ELCOP" OF oDlg COLOR 0, 16777215 PIXEL

    @ 014, 006 SAY oSay1 PROMPT "Este Programa tem o objetivo de Realizar o Fechamento do Calculo de Beneficios;" SIZE 250, 007 OF oDlg COLORS 0, 16777215 PIXEL
    
    //@ 026, 006 SAY oSay4 PROMPT "Observacoes: " SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL

    //@ 037, 006 SAY oSay2 PROMPT "Para Gerar o Calculo Corretamente o Periodo deve Conter informações de Dias Trabalhados;" SIZE 283, 007 OF oDlg COLORS 0, 16777215 PIXEL
    //@ 048, 006 SAY oSay3 PROMPT "Cadastrar Regras de Beneficios e vincular ao Calendario e Vincular a Matricula do Funcionario;" SIZE 255, 007 OF oDlg COLORS 0, 16777215 PIXEL

    @ 132, 257 BUTTON oButton1 PROMPT "Sair"         SIZE 040, 012 OF oDlg PIXEL   Action( oDlg:End() )
    @ 132, 006 BUTTON oButton2 PROMPT "Parametros"   SIZE 040, 012 OF oDlg PIXEL   Action( funpar() )
    @ 132, 209 BUTTON oButton3 PROMPT "Processar"    SIZE 040, 012 OF oDlg PIXEL   Action( CalcBenef() ) 

  ACTIVATE MSDIALOG oDlg CENTERED

Return()

//Função Processamento de Calculo Beneficios
Static Function CalcBenef()
	Local lEnd  := .F.

	AjustaSX1()
	pergunte(cPerg,.T.) 
    Processa({|lEnd| ExecCalcBenef()},"Aguarde...","Processando Fechamento....",.T.)

Return()

Static Function ExecCalcBenef()

Return()

//Função de Parâmetros
Static Function funpar()
	AjustaSX1()
	pergunte(cPerg,.T.) 
Return()

Static Function AjustaSX1()
	lOCAL _i := 0
	Private _agrpsx1:={}	

//	aadd(_agrpsx1,{cPerg,"01","Filial de?       		","mv_ch1" ,"C",04,0,0,"G",space(60),"mv_par01"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),("SM0")})
//	aadd(_agrpsx1,{cPerg,"02","Filial Ate?        		","mv_ch2" ,"C",04,0,0,"G",space(60),"mv_par02"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),("SM0")})
	aadd(_agrpsx1,{cPerg,"01","Periodo ?	    	 	","mv_ch1" ,"C",06,0,0,"G",space(60),"mv_par01"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),		  })
//	aadd(_agrpsx1,{cPerg,"04","Matricula De?        	","mv_ch4" ,"C",06,0,0,"G",space(60),"mv_par04"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),("SRA")})
//	aadd(_agrpsx1,{cPerg,"05","Matricula Ate?   	 	","mv_ch5" ,"C",06,0,0,"G",space(60),"mv_par05"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),("SRA")})
//	aadd(_agrpsx1,{cPerg,"06","C.Custo De?        		","mv_ch6" ,"C",09,0,0,"G",space(60),"mv_par06"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),("CTT")})
//	aadd(_agrpsx1,{cPerg,"07","C.Custo Ate?   	 		","mv_ch7" ,"C",09,0,0,"G",space(60),"mv_par07"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),("CTT")})

	For _i:=1 to len(_agrpsx1)
		if !sx1->(dbseek(_agrpsx1[_i,1]+_agrpsx1[_i,2]))
			sx1->(reclock("SX1",.t.))
			sx1->x1_grupo  :=_agrpsx1[_i,01]
			sx1->x1_ordem  :=_agrpsx1[_i,02]
			sx1->x1_pergunt:=_agrpsx1[_i,03]
			sx1->x1_variavl:=_agrpsx1[_i,04]
			sx1->x1_tipo   :=_agrpsx1[_i,05]
			sx1->x1_tamanho:=_agrpsx1[_i,06]
			sx1->x1_decimal:=_agrpsx1[_i,07]
			sx1->x1_presel :=_agrpsx1[_i,08]
			sx1->x1_gsc    :=_agrpsx1[_i,09]
			sx1->x1_valid  :=_agrpsx1[_i,10]
			sx1->x1_var01  :=_agrpsx1[_i,11]
			sx1->x1_def01  :=_agrpsx1[_i,12]
			sx1->x1_cnt01  :=_agrpsx1[_i,13]
			sx1->x1_var02  :=_agrpsx1[_i,14]
			sx1->x1_def02  :=_agrpsx1[_i,15]
			sx1->x1_cnt02  :=_agrpsx1[_i,16]
			sx1->x1_var03  :=_agrpsx1[_i,17]
			sx1->x1_def03  :=_agrpsx1[_i,18]
			sx1->x1_cnt03  :=_agrpsx1[_i,19]
			sx1->x1_var04  :=_agrpsx1[_i,20]
			sx1->x1_def04  :=_agrpsx1[_i,21]
			sx1->x1_cnt04  :=_agrpsx1[_i,22]
			sx1->x1_var05  :=_agrpsx1[_i,23]
			sx1->x1_def05  :=_agrpsx1[_i,24]
			sx1->x1_cnt05  :=_agrpsx1[_i,25]
			sx1->x1_f3     :=_agrpsx1[_i,26]
			sx1->(msunlock())
		EndIf
	Next

Return()

