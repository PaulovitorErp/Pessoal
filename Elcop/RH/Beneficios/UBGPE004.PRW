#Include "PROTHEUS.CH"
#include "topconn.ch"   
#INCLUDE 'FWMVCDEF.CH' 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������?��
���Programa  � UBGPE004 � Autor � Adriano Reis        � Data �28/02/2019  ���
�������������������������������������������������������������������������?��
���Desc.     � Processamento Calculo Beneficios Elcop                     ���
�������������������������������������������������������������������������?��
���Uso       � ELCOP                                                      ���
�������������������������������������������������������������������������?��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function UBGPE004()

Local oButton1
Local oButton2
Local oButton3
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Static oDlg

Private cPerg := Padr("UBGPE004",10) 

  DEFINE MSDIALOG oDlg TITLE "Calculo Beneficios ELCOP" FROM 000, 000  TO 300, 600 COLORS 0, 16777215 PIXEL

	@ 004, 004 GROUP oGroup1 TO 130, 300 PROMPT "Processamento Beneficios ELCOP" OF oDlg COLOR 0, 16777215 PIXEL

    @ 016, 007 SAY oSay1 PROMPT "Este Programa tem o objetivo de Realizar o Calculo de Beneficios;" SIZE 250, 007 OF oDlg COLORS 0, 16777215 PIXEL
    
    @ 028, 007 SAY oSay4 PROMPT "Observacoes: " SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL

    @ 039, 007 SAY oSay2 PROMPT "Para Gerar o Calculo Corretamente o Periodo deve Conter informacoes de Dias Trabalhados;" SIZE 283, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 050, 007 SAY oSay3 PROMPT "Cadastrar Regras de Beneficios e vincular ao Calendario e Vincular a Matricula do Funcionario;" SIZE 255, 007 OF oDlg COLORS 0, 16777215 PIXEL

    @ 132, 257 BUTTON oButton1 PROMPT "Sair"        SIZE 040, 012 OF oDlg PIXEL   Action( oDlg:End() )
    @ 132, 006 BUTTON oButton2 PROMPT "Parametros"  SIZE 040, 012 OF oDlg PIXEL   Action( funpar() )
    @ 132, 209 BUTTON oButton3 PROMPT "Calcular"    SIZE 040, 012 OF oDlg PIXEL   Action( CalcBenef() ) 

  ACTIVATE MSDIALOG oDlg CENTERED

Return()

//Fun��o Processamento de Calculo Beneficios
Static Function CalcBenef()
	Local lEnd  := .F.

	AjustaSX1()
	pergunte(cPerg,.T.) 

    Processa({|lEnd| ExecCalcBenef()},"Aguarde...","Processando Calculo....",.T.)

Return()

Static Function ExecCalcBenef()
	Local cQuery    := ""
	Local cAliasSRA := GetNextAlias()

	//BeginSql Alias cAliasSRA
	if SELECT(cAliasSRA) > 0
		(cAliasSRA)->(dbCloseArea())
	endif

	cQuery := " SELECT * FROM "+RetSqlName("SRA")+" SRA "
	cQuery += " WHERE SRA.D_E_L_E_T_ = ' '  "
	cQuery += " AND RA_SITFOLH <> 'D'  AND RA_XREGRA = 'S' AND RA_XCODREG <> ' ' "
	cQuery += " AND RA_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"
	cQuery += " AND RA_MAT    BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"'"
	cQuery += " AND RA_CC     BETWEEN '"+MV_PAR06+"' AND '"+MV_PAR07+"'"
	cQuery += " ORDER BY SRA.RA_MAT "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSRA,.T.,.T.)

	ProcRegua((cAliasSRA)->(RecCount())) 

	dbSelectArea(cAliasSRA)
	dbGoTop()
	While !(cAliasSRA)->(Eof())

		IncProc("Processando Calculo... " + (cAliasSRA)->RA_MAT +" "+ Alltrim((cAliasSRA)->RA_NOME) )
		
		IF (cAliasSRA)->RA_XREGRA = 'S' 

			//1 Primeiro ver se tem Regra de Calculo de Beneficios
			DbSelectarea("U01")
			U01->(Dbgotop())
			U01->(DbSetOrder(1))
			if U01->(DbSeek(xFilial("U01")+(cAliasSRA)->RA_XCODREG))

				////2 Verificar Calendario de Beneficios
				DbSelectarea("U01")
				U02->(Dbgotop())
				U02->(DbSetOrder(1))
				if U02->(DbSeek(xFilial("U02")+U01->U01_CODCAL))
			
					cRoteiro  := 'FOL'
					cPeriodo  := MV_PAR03 //Fazer funcao para Buscar Periodo Anterior Fechado RGB
					cPeriAnt  := SUBSTR(DTOS(MonthSub(STOD(MV_PAR03+"01"),1)),1,6)
					cDiasAbat := 0
					nVal020   := 0

					//Verificar se Busca da SRC ou SRD Periodo Atual ou Periodo Anterior
					if U02->U02_TPCALC = '1' //Mes Atual
						
						dbSelectArea("SRC")
						SRC->(Dbgotop())
						SRC->(dbSetOrder(4))
						If SRC->(dbSeek((cAliasSRA)->RA_FILIAL  + (cAliasSRA)->RA_MAT + cPeriodo + cRoteiro ))
							While !Eof() .And. ( Alltrim((cAliasSRA)->RA_FILIAL+(cAliasSRA)->RA_MAT + cPeriodo + cRoteiro ) = AllTrim(SRC->RC_FILIAL+SRC->RC_MAT+SRC->RC_PERIODO+SRC->RC_ROTEIR))

								//nValLiq += SRC->RC_VALOR
								//nValVrb += SRC->RC_VALOR

								IF SRC->RC_PD = '440'
									cDiasAbat := SRC->RC_HORAS
								EndIf

								IF SRC->RC_PD = '020'
									nVal020   := SRC->RC_VALOR
								EndIf

							SRC->(dbSkip())
							EndDo
						EndIf

						// Movimento Fechado  
						dbSelectArea("SRD")
						SRD->(Dbgotop())
						SRD->(dbSetOrder(3))
						If SRD->(dbSeek((cAliasSRA)->RA_FILIAL  + (cAliasSRA)->RA_MAT + cPeriodo + cRoteiro))
							While !Eof() .And. ( Alltrim((cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT + cPeriodo + cRoteiro) = Alltrim(SRD->RD_FILIAL + SRD->RD_MAT + SRD->RD_PERIODO + SRD->RD_DATARQ) )

								//nValLiq += SRD->RD_VALOR
								//nValVrb += SRD->RD_VALOR

								IF SRD->RD_PD = '440'
									cDiasAbat := SRD->RD_HORAS
								EndIf

								IF SRD->RD_PD = '020'
									nVal020   := SRD->RD_VALOR
								EndIf

							SRD->(dbSkip())
							EndDo
						EndIf

					EndIf

					//Verificar se Busca da SRC ou SRD Periodo Atual ou Periodo Anterior
					if U02->U02_TPCALC = '2' //Periodo Anterior

						// Movimento Fechado  
						dbSelectArea("SRD")
						SRD->(Dbgotop())
						SRD->(dbSetOrder(3))
						If SRD->(dbSeek((cAliasSRA)->RA_FILIAL  + (cAliasSRA)->RA_MAT + cPeriAnt + cRoteiro))
							While !Eof() .And. ( Alltrim((cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT + cPeriodo + cRoteiro) = Alltrim(SRD->RD_FILIAL + SRD->RD_MAT + SRD->RD_PERIODO + SRD->RD_DATARQ) )

								//nValLiq += SRD->RD_VALOR
								//nValVrb += SRD->RD_VALOR

								IF SRD->RD_PD = '440'
									cDiasAbat := SRD->RD_HORAS
								EndIf

								IF SRD->RD_PD = '020'
									nVal020   := SRD->RD_VALOR
								EndIf
								
							SRD->(dbSkip())
							EndDo
						EndIf

					EndIf

					//Inclui movimentacoes Caso nao exista movimentacoes da Matricula no Periodo
					DbSelectarea("U03")
					U03->(Dbgotop())
					U03->(DbSetOrder(2))
					if !U03->(DbSeek(+(cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT + cPeriodo ))
						//IncProc("Gravando Registro... " + (cAliasSRA)->RA_MAT +" "+ Alltrim((cAliasSRA)->RA_NOME) )
						RecLock("U03",.T.)	
					Else
						RecLock("U03",.F.)	
					EndIf
							U03->U03_FILIAL  := (cAliasSRA)->RA_FILIAL
							U03->U03_PERIOD  := cPeriodo
							U03->U03_MAT     := (cAliasSRA)->RA_MAT
							U03->U03_NOME    := (cAliasSRA)->RA_NOME
							U03->U03_DTCALC  := DDATABASE
							U03->U03_REGRA   := U01->U01_CODIGO
							U03->U03_CALEND  := U02->U02_CODIGO
							U03->U03_CC      := (cAliasSRA)->RA_CC
							U03->U03_ADMISS  := STOD((cAliasSRA)->RA_ADMISSA)
							U03->U03_SINDIC  := (cAliasSRA)->RA_SINDICA
							U03->U03_DEPTO   := (cAliasSRA)->RA_DEPTO
							U03->U03_CIC     := (cAliasSRA)->RA_CIC
							U03->U03_SITFOL  := (cAliasSRA)->RA_SITFOLH
							U03->U03_SALARI  := (cAliasSRA)->RA_SALARIO
							U03->U03_FUNCAO  := (cAliasSRA)->RA_CODFUNC
							U03->U03_DTNASC  := CTOD((cAliasSRA)->RA_NASC)
							//Valores Beneficios
							U03->U03_VLVT    := IIF(U01->U01_TPVT='D'  ,(U02->U02_DIASTR-(cDiasAbat)) * U01->U01_VLVT   ,U01->U01_VLVT) 
							U03->U03_VLVR    := IIF(U01->U01_TPVR='D'  ,(U02->U02_DIASTR-(cDiasAbat)) * U01->U01_VLVR   ,U01->U01_VLVR)
							U03->U03_VLVA    := IIF(U01->U01_TPVA='D'  ,(U02->U02_DIASTR-(cDiasAbat)) * U01->U01_VLVA   ,U01->U01_VLVA)
							U03->U03_VLVC    := IIF(U01->U01_TPVC='D'  ,(U02->U02_DIASTR-(cDiasAbat)) * U01->U01_VLVC   ,U01->U01_VLVC)
							U03->U03_VLCEST  := IIF(U01->U01_TPCEST='D',(U02->U02_DIASTR-(cDiasAbat)) * U01->U01_VLCEST ,U01->U01_VLCEST)
							//Informacao de Dias de Cada Beneficios
							//U03->U03_DIASVT  := U02->U02_DIASTR
							//U03->U03_DIASVR  := U02->U02_DIASTR
							//U03->U03_DIASVA  := U02->U02_DIASTR
							//U03->U03_DIASVC  := U02->U02_DIASTR
							//informacoes do mes
							U03->U03_DIASME  := U02->U02_DIASME
							U03->U03_DIASUT  := U02->U02_DIASUT
							U03->U03_DIASTR  := U02->U02_DIASTR
							U03->U03_STATUS  := 'A'						
							U03->U03_DESCVT  := IIF(U01->U01_DEVT='S'  ,nVal020 * 0.06 , 0)
							U03->U03_DESCVR  := IIF(U01->U01_TPVR='S'  ,U03->U03_VLVR * U01->U01_VARIAV, 0)
							U03->U03_DESCVA  := IIF(U01->U01_DEVA='S'.AND. U01->U01_TPDEVA ="P" ,U03->U03_VLVA * U01->U01_VARIAV , U01->U01_DESCVA) // U01_DESCVA O CONTEUDO DO CAMPO E SEMPRE O VALOR E NAO %
							U03->U03_DESCVC  := IIF(U01->U01_DEVC='S'  ,U03->U03_VLVC * U01->U01_VARIAV, 0)
							U03->U03_DESCES  := 0
							U03->U03_JUSTIF  := ''  

						U03->(MsUnLock())

					EndIf
			EndIf
		EndIf


		(cAliasSRA)->(dbSkip())
	EndDo

	//BeginSql Alias cAliasSRA
	if SELECT(cAliasSRA) > 0
		(cAliasSRA)->(dbCloseArea())
	endif

    MsgAlert("Calculo realizado com sucesso!")

Return()

//Fun��o de Par�metros
Static Function funpar()
	AjustaSX1()
	pergunte(cPerg,.T.) 
Return()

Static Function AjustaSX1()
	lOCAL _i := 0
	Private _agrpsx1:={}	

	aadd(_agrpsx1,{cPerg,"01","Filial de?       		","mv_ch1" ,"C",04,0,0,"G",space(60),"mv_par01"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),("SM0")})
	aadd(_agrpsx1,{cPerg,"02","Filial Ate?        		","mv_ch2" ,"C",04,0,0,"G",space(60),"mv_par02"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),("SM0")})
	aadd(_agrpsx1,{cPerg,"03","Periodo ?	    	 	","mv_ch3" ,"C",06,0,0,"G",space(60),"mv_par03"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),		  })
	aadd(_agrpsx1,{cPerg,"04","Matricula De?        	","mv_ch4" ,"C",06,0,0,"G",space(60),"mv_par04"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),("SRA")})
	aadd(_agrpsx1,{cPerg,"05","Matricula Ate?   	 	","mv_ch5" ,"C",06,0,0,"G",space(60),"mv_par05"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),("SRA")})
	aadd(_agrpsx1,{cPerg,"06","C.Custo De?        		","mv_ch6" ,"C",09,0,0,"G",space(60),"mv_par06"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),("CTT")})
	aadd(_agrpsx1,{cPerg,"07","C.Custo Ate?   	 		","mv_ch7" ,"C",09,0,0,"G",space(60),"mv_par07"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),("CTT")})

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


