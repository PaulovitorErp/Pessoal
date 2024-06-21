#Include "PROTHEUS.CH"
#include "topconn.ch"   
#INCLUDE 'FWMVCDEF.CH' 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ UCOMR008 º Autor ³ Adriano Reis        º Data ³28/02/2019  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio  Nota Fornecedor                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ELCOP                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function UCOMR008()
	Private oSecCab  	 := Nil
	Private cPerg 		 := Padr("UCOMR008",10) 
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
		
			SELECT 
            A2_COD      ,
            A2_NOME     ,
            A2_CGC      , 
            A2_XNOTLIC  ,
            A2_XIQF     ,
            A2_XNOTALV  ,
            A2_XIQFMED  ,
            A2_XNOTCOM  ,
            A2_XTIPDOC  ,
            A2_XTIPO    ,
            CASE 
                WHEN A2_MSBLQL = 1 THEN 'SIM'
                WHEN A2_MSBLQL = 2 THEN 'NÃO'
                ELSE    'Outro Valor'  
            END AS      'A2_MSBLQL'
            FROM			
			%table:SA2% SA2
			WHERE SA2.%notdel%			
            AND A2_XTIPO = 'O'
			ORDER BY A2_NOME
					
		ENDSQL

    //AND U03.U03_CC       BETWEEN %exp:MV_PAR05% AND %exp:MV_PAR06%

	MakeSQLExpr("cperg") // Pergunta com o parâmetro do Tipo Range
	oReport:Section(1):EndQuery()
	oReport:Section(1):Print()

Return Nil

Static Function ReportDef()			
					
	Local Qry := GetNextAlias()

	oReport := TReport():New("UBGPE005"," Relatorio de IQF"+DTOC(DDATABASE),cPerg,{|oReport|PrintReport(oReport,Qry)}," .")
	oReport:SetLandscape(.T.)

	oSection1 := TRSection():New( oReport, " Relatorio de IQF", {"QRY"} )

	TRCell():New( oSection1, "A2_COD"  	  	   , "QRY",'CODIGO')
	TRCell():New( oSection1, "A2_NOME"         , "QRY",'NOME')		
	TRCell():New( oSection1, "A2_CGC"          , "QRY",'CNPJ')		
	TRCell():New( oSection1, "A2_XNOTLIC"      , "QRY",'NOTA ENTREGA')	
	TRCell():New( oSection1, "A2_XIQF"         , "QRY",'IQF FORNECEDOR')	
	TRCell():New( oSection1, "A2_XNOTALV"      , "QRY",'CORDIALIDADE')								
	TRCell():New( oSection1, "A2_XIQFMED"      , "QRY",'IQF MEDIO')
	TRCell():New( oSection1, "A2_XNOTCOM" 	   , "QRY","NOTA PAGAM")
	TRCell():New( oSection1, "A2_XTIPDOC"      , "QRY",'TIPO DOC')	
	TRCell():New( oSection1, "A2_XTIPO"        , "QRY",'TIPO IQF')
	TRCell():New( oSection1, "A2_MSBLQL"       , "QRY",'BLOQUEIO')	

Return(oReport)   


Static Function AjustaSX1()
	lOCAL _i := 0
	Private _agrpsx1:={}	

	aadd(_agrpsx1,{cPerg,"01","Fornecedor de?       		","mv_ch1" ,"C",06,0,0,"G",space(60),"mv_par01"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),("SA2")})
	aadd(_agrpsx1,{cPerg,"02","FornecedorAte?        		","mv_ch2" ,"C",06,0,0,"G",space(60),"mv_par02"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),("SA2")})

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

