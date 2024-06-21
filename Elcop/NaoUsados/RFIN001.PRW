#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NOVO2     ºAutor  ³Andre CastilhoºData ³ 20/02/19           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relatorio Rateio SEZ								          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Vale do Cerrado.	                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RFIN001()
	Private cStartPath
	Private cDirDocs  	:= MsDocPath()
	Private cArquivo 	:= CriaTrab(,.F.)
	Private cPath		:= AllTrim(GetTempPath())
	Private cQuery 		:= ""
	Private cPerg       := Padr("RFIN010",10) 

	CriaPerg()
	pergunte(cPerg,.F.) //Chama a tela de parametros
	
	processa({|| ExpRel()},"Gerando Relatorio Rateio SEZ : ")

Return()

Static Function ExpRel()
	Local aHeadXls 	:= {}
	Local aColsXls 	:= {}
	Local cPeriodo  := '' 

	procregua(0)
	Incproc()

	If(SELECT("QRYSEZ") > 0)
		QRYSEZ->(DBCLOSEAREA())
	Endif

   cQuery:= " 		 SELECT EZ_FILIAL AS FILIAL, 												"
   cQuery+= "    	   		EZ_NUM AS NUMERO,													"
   cQuery+= "    	   		EZ_PREFIXO AS PREFIXO,												"
   cQuery+= "        		EZ_PARCELA AS PARCELA,											    "
   cQuery+= "   			A2_NREDUZ  AS NOME,													"
   cQuery+= "   			EZ_LOJA    AS LOJA,													"
   cQuery+= "   	        EZ_VALOR   AS VALOR,												"
   cQuery+= "   	        EZ_NATUREZ AS NATUREZA, 											"
   cQuery+= "   	        ED_DESCRIC AS DESCRIC,  											"
   cQuery+= "   	        EZ_CCUSTO ,															"
   cQuery+= "   	        CTT_DESC01, 														"
   cQuery+= "        		E2_EMISSAO,															"
   cQuery+= "        		E2_VENCREA															"
   cQuery+= "   	FROM SEZ010 AS SEZ      													"
   cQuery+= "   	INNER JOIN SA2010 AS SA2 ON A2_COD = EZ_CLIFOR								"
   cQuery+= "   	INNER JOIN SED010 AS SED ON ED_CODIGO = EZ_NATUREZ     						"
   cQuery+= "   	INNER JOIN CTT010 AS CTT ON CTT_CUSTO = EZ_CCUSTO     						"
   cQuery+= "   	INNER JOIN SE2010 AS SE2 ON E2_NUM = EZ_NUM AND E2_FILIAL = EZ_FILIAL AND E2_PREFIXO = EZ_PREFIXO AND E2_FORNECE = EZ_CLIFOR "   						"
   cQuery+= "  		WHERE SA2.D_E_L_E_T_ = '' AND SED.D_E_L_E_T_ = ' ' AND CTT.D_E_L_E_T_ = ' ' AND SE2.D_E_L_E_T_ = ' ' AND SE2.E2_MULTNAT = '1'"
   cQuery+= "  		AND EZ_CCUSTO   BETWEEN '"+mv_par01+"' AND  '"+mv_par02+"' "
   cQuery+= "  		AND E2_EMISSAO  BETWEEN '"+DTOS(mv_par03)+"' AND  '"+DTOS(mv_par04)+"' "
   cQuery+= "  		AND E2_VENCREA  BETWEEN '"+DTOS(mv_par05)+"' AND  '"+DTOS(mv_par06)+"' "
   tcQuery cQuery new alias "QRYSEZ"
   
   	tcSetField("QRY","E2_EMISSAO","D",8,0)
	tcSetField("QRY","E2_VENCREA","D",8,0)
	
	aHeadXls := {"FILIAL","NUMERO","PREFIXO ","PARCELA","NOME","LOJA","VALOR","NATUREZA","DESCRIÇÃO","CENTRO DE CUSTO","DESCRIÇÃO,EMISSÃO,VENCIMENTO"}
    QRYSEZ->(DBGOTOP())
	While !QRYSEZ->(eof())
	
		aAdd(aColsXls,{QRYSEZ->FILIAL,QRYSEZ->NUMERO,QRYSEZ->PREFIXO,QRYSEZ->PARCELA,QRYSEZ->NOME,QRYSEZ->LOJA,QRYSEZ->VALOR,QRYSEZ->NATUREZA,QRYSEZ->DESCRIC ,QRYSEZ->EZ_CCUSTO,QRYSEZ->CTT_DESC01,QRYSEZ->E2_EMISSAO,QRYSEZ->E2_VENCREA})

	QRYSEZ->(dbskip())
	ENDDO
	
	if len(aColsXls) > 0
		SPCPR06Excel(aHeadXls,aColsXls,"Relatorio Rateio SEZ") //Exporta para Excel
	Else
		Alert("Sem Registros")
	EndIf
   
Return()

Static Function CriaPerg()

	Private _agrpsx1:={}	
	
	aadd(_agrpsx1,{cPerg,"01","Centro de Custo de?       		","mv_ch1" ,"C",06,0,0,"G",space(60),"mv_par01"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),("SM0")})
	aadd(_agrpsx1,{cPerg,"02","Centro de Custo Ate?       	 	","mv_ch2" ,"C",06,0,0,"G",space(60),"mv_par02"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),("SM0")})
	aadd(_agrpsx1,{cPerg,"03","Emissao de?       				","mv_ch3" ,"C",08,0,0,"G",space(60),"mv_par03"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),("")})
	aadd(_agrpsx1,{cPerg,"04","Emissao Ate?        				","mv_ch4" ,"C",08,0,0,"G",space(60),"mv_par04"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),("")})
	aadd(_agrpsx1,{cPerg,"05","Vencimento de?       			","mv_ch5" ,"C",08,0,0,"G",space(60),"mv_par05"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),("SB1")})
	aadd(_agrpsx1,{cPerg,"06","Vencimento Ate?        			","mv_ch6" ,"C",08,0,0,"G",space(60),"mv_par06"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),("SB1")})
	
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

Static Function SPCPR06Excel(_aHeadXls,_aColsXls,cTitulo)
	Local oFWMSExcel := FWMSExcel():New()
	Local oMsExcel
	Local aCells
	Local cType
	Local cColumn
	Local cFile
	Local cFileTMP
	Local cPicture
	Local lTotal
	Local nRow
	Local nRows
	Local nField
	Local nFields
	Local nAlign
	Local nFormat
	Local uCell

	Local cWorkSheet := cTitulo+AllTrim(SM0->M0_NOME)+" em "+DtoC(Date())+" as "+Time()
	Local cTable     := cWorkSheet
	Local lTotalize  := .T.
	Local lPicture   := .F.

	BEGIN SEQUENCE

		oFWMSExcel:AddworkSheet(cWorkSheet)
		oFWMSExcel:AddTable(cWorkSheet,cTable)

		nFields := Len( _aHeadXls )
		For nField := 1 To nFields
			cType   := "C"
			cType   := ValType(_aColsXls[1][nField])
			nAlign  := IF(cType=="C",1,IF(cType=="N",3,2))
			nFormat := IF(cType=="D",4,IF(cType=="N",3,1))//2
			cColumn := _aHeadXls[nField]
			lTotal  := ( lTotalize .and. cType == "N" )
			oFWMSExcel:AddColumn(@cWorkSheet,@cTable,@cColumn,@nAlign,@nFormat,@lTotal)
		Next nField

		oFWMSExcel:CBGCOLOR2LINE := '#FFFFFF'
		oFWMSExcel:CBGCOLORLINE  := '#FFFFFF'

		aCells := Array(nFields)
		nRows  := Len( _aColsXls )
		For nRow := 1 To nRows
			IncProc("Gerando planilha.. [Linha: "+TRANSFORM(nRow,"@E 999999")+"]")
			For nField := 1 To nFields
				uCell := _aColsXls[nRow][nField]
				If Valtype(uCell) == "D" .AND. EMPTY(uCell)
					aCells[nField] := space(8)
				Else
					aCells[nField] := uCell
				Endif
			Next nField
			oFWMSExcel:AddRow(@cWorkSheet,@cTable,aClone(aCells))
		Next nRow
		oFWMSExcel:Activate()

		cFile := ( CriaTrab( NIL, .F. ) + ".xls" )

		While File( cFile )
			cFile := ( CriaTrab( NIL, .F. ) + ".xls" )
		End While

		oFWMSExcel:GetXMLFile( cFile )
		oFWMSExcel:DeActivate()

		IF .NOT.( File( cFile ) )
			cFile := ""
			BREAK
		EndIF

		cFileTMP := ( GetTempPath() + cFile )
		IF .NOT.( __CopyFile( cFile , cFileTMP ) )
			fErase( cFile )
			cFile := ""
			BREAK
		EndIF

		fErase( cFile )

		cFile := cFileTMP

		IF .NOT.( File( cFile ) )
			cFile := ""
			BREAK
		EndIF

		IF .NOT.( ApOleClient("MsExcel") )
			BREAK
		EndIF

		oMsExcel:= MsExcel():New()
		oMsExcel:WorkBooks:Open( cFile )
		oMsExcel:SetVisible( .T. )
		oMsExcel:= oMsExcel:Destroy()
	END SEQUENCE

	oFWMSExcel := FreeObj( oFWMSExcel )
Return( cFile )


