#Include "PROTHEUS.CH"
#include "topconn.ch"   
#INCLUDE 'FWMVCDEF.CH' 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � UBGPE005 � Autor � Adriano Reis        � Data �28/02/2019  ���
�������������������������������������������������������������������������͹��
���Desc.     � Relatorio  Beneficios Por Funcionario                      ���
�������������������������������������������������������������������������͹��
���Uso       � ELCOP                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function UBGPE005()
	Private oSecCab  	 := Nil
	Private cPerg 		 := Padr("UBGPE005",10) 
	Private cQtdVendas   := ' '
	Private cAlias       := "QRY"
	Private aOrdem   	 := {"Proposta"}
	Private aArea		 := Getarea()
	Private	cAliasSD1 	 := "QRY"	 
	Private oSection1
	Private oSection2
	Private oReport 

	AjustaSX1()
	pergunte(cPerg,.F.) 

	ReportDef()
	oReport:PrintDialog()

Return Nil

Static Function PrintReport(oReport,Qry)
	
	oReport:Section(1):BeginQuery()
	
		BEGINSQL ALIAS Qry
		
			SELECT * FROM			
			%table:U03% U03
			WHERE U03.%notdel%			
			AND U03.U03_DTCALC   BETWEEN %exp:dtos(MV_PAR03)%  AND %exp:dtos(MV_PAR04)%			
			AND U03.U03_FILIAL   BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%
			AND U03.U03_MAT      BETWEEN %exp:MV_PAR05% AND %exp:MV_PAR06%
            AND U03.U03_CC       BETWEEN %exp:MV_PAR05% AND %exp:MV_PAR06%
			ORDER BY U03_FILIAL,U03_MAT,U03_DTCALC
					
		ENDSQL

    //tcSetField("QRYSF2","U03_DTCALC","D",8,0)
    //tcSetField("QRYSF2","U03_ADMISS","D",8,0)
    //tcSetField("QRYSF2","U03_DTENCE","D",8,0)

	MakeSQLExpr("cperg") // Pergunta com o par�metro do Tipo Range
	oReport:Section(1):EndQuery()
	oReport:Section(1):Print()

Return Nil

Static Function ReportDef()			
					
	Local Qry := GetNextAlias()

	oReport := TReport():New("UBGPE005"," Relatorio Liquido Beneficios "+DTOC(DDATABASE),cPerg,{|oReport|PrintReport(oReport,Qry)}," .")
	oReport:SetLandscape(.T.)

	oSection1 := TRSection():New( oReport, "Relatorio Liquido Beneficios", {"QRY"} )
	//oSecCab:SetTotalInLine(.T.)
	TRCell():New( oSection1, "U03_FILIAL"  	  	  , "QRY",'FILIAL')
	TRCell():New( oSection1, "U03_PERIOD"         , "QRY",'PERIODO')		
	TRCell():New( oSection1, "U03_MAT"            , "QRY",'MATRICULA')		
	TRCell():New( oSection1, "U03_NOME"           , "QRY",'NOME')	
	TRCell():New( oSection1, "U03_DTCALC"         , "QRY",'DT CALCULO')	
	TRCell():New( oSection1, "U03_REGRA"          , "QRY",'REGRA')								
	TRCell():New( oSection1, "U03_CALEND"         , "QRY",'CALENDARIO')
	TRCell():New( oSection1, "U03_CC" 	  	 	  , "QRY","C.CUSTO")
	TRCell():New( oSection1, "U03_ADMISS"         , "QRY",'ADMISSAO')	
	TRCell():New( oSection1, "U03_CIC"            , "QRY",'CPF')
	TRCell():New( oSection1, "U03_SITFOL"         , "QRY",'SIT.FOL')	
	TRCell():New( oSection1, "U03_SALARI"         , "QRY",'SALARIO')	
	TRCell():New( oSection1, "U03_FUNCAO"         , "QRY",'FUNCAO')	
	TRCell():New( oSection1, "U03_VLVT"           , "QRY",'VALOR VT')	
	TRCell():New( oSection1, "U03_VLVR"           , "QRY",'VALOR VR')	
	TRCell():New( oSection1, "U03_VLVA"           , "QRY",'VALOR VA')
	TRCell():New( oSection1, "U03_VLVC"           , "QRY",'VALOR VC')
	TRCell():New( oSection1, "U03_VLCEST"         , "QRY",'VALOR CESTA')	
	TRCell():New( oSection1, "U03_DESCVT"         , "QRY",'DESC VT')	
	TRCell():New( oSection1, "U03_DESCVR"         , "QRY",'DESC VR')	
	TRCell():New( oSection1, "U03_DESCVA"         , "QRY",'DESC VA')
	TRCell():New( oSection1, "U03_DESCVC"         , "QRY",'DESC VC')
	TRCell():New( oSection1, "U03_DESCES"         , "QRY",'DESC CESTA')							
	TRCell():New( oSection1, "U03_DIASME"    	  , "QRY",'DIAS MES')	
	TRCell():New( oSection1, "U03_DIASUT"         , "QRY",'DIAS UTEIS')								
	TRCell():New( oSection1, "U03_DIASTR"         , "QRY",'DIAS TRABALHADOS')									
	TRCell():New( oSection1, "U03_STATUS"         , "QRY",'STATUS')	
	TRCell():New( oSection1, "U03_DTENCE"         , "QRY",'DT ENCERR.')	

Return(oReport)   


Static Function AjustaSX1()
	lOCAL _i := 0
	Private _agrpsx1:={}	

	aadd(_agrpsx1,{cPerg,"01","Filial de?       		","mv_ch1" ,"C",04,0,0,"G",space(60),"mv_par01"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),("SM0")})
	aadd(_agrpsx1,{cPerg,"02","Filial Ate?        		","mv_ch2" ,"C",04,0,0,"G",space(60),"mv_par02"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),("SM0")})
	aadd(_agrpsx1,{cPerg,"03","Data De ?	    	 	","mv_ch3" ,"D",08,0,0,"G",space(60),"mv_par03"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),		  })
	aadd(_agrpsx1,{cPerg,"04","Data Ate?    	 		","mv_ch4" ,"D",08,0,0,"G",space(60),"mv_par04"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),		  })
	aadd(_agrpsx1,{cPerg,"05","Matricula De?        	","mv_ch5" ,"C",06,0,0,"G",space(60),"mv_par05"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),("SRA")})
	aadd(_agrpsx1,{cPerg,"06","Matricula Ate?   	 	","mv_ch6" ,"C",06,0,0,"G",space(60),"mv_par06"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),("SRA")})
	aadd(_agrpsx1,{cPerg,"07","C.Custo De?        		","mv_ch7" ,"C",06,0,0,"G",space(60),"mv_par07"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),("CTT")})
	aadd(_agrpsx1,{cPerg,"08","C.Custo Ate?   	 		","mv_ch8" ,"C",06,0,0,"G",space(60),"mv_par08"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),("CTT")})

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

