#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNOVO2     บAutor  ณAndre CastilhoบData ณ 21/04/18           บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRelatorio Admitidos p/ Seguradora					          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Vale do Cerrado.	                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function RGPER003()
	Private cStartPath
	Private cDirDocs  	:= MsDocPath()
	Private cArquivo 	:= CriaTrab(,.F.)
	Private cPath		:= AllTrim(GetTempPath())
	Private cQuery 		:= ""
	Private cperg       :="RGPER003"

	AjustaSX1(cperg) //Cria Perguntas

	If Pergunte(cperg,.T.,"")
		processa({|| ExpRel()},"Gerando Relatorio Seguro de Vida : ")
	Endif
Return()

Static Function ExpRel()
	Local aHeadXls 	:= {}
	Local aColsXls 	:= {}
	Local cPeriodo  := '' 

	procregua(0)
	Incproc()

	If(SELECT("QRYSRA") > 0)
		QRYSE1->(DBCLOSEAREA())
	Endif

   cQuery:= " 		 SELECT RA_MAT AS MATRICULA, 												"
   cQuery+= "    	RA_NOME AS NOME,															"
   cQuery+= "        CONVERT(char(10),CAST(RA_NASC as smalldatetime),103) AS NASCIMENTO,		"
   cQuery+= "        CONVERT(char(10),CAST(RA_ADMISSA as smalldatetime),103) AS ADMISSAO,	    "
   cQuery+= "   	RA_SALARIO AS SALARIO, 	  													"
   cQuery+= "   	RJ_DESC AS FUNCAO,         													"
   cQuery+= "   	CTT_CUSTO AS 'CCUSTO',      												"
   cQuery+= "   	RA_PIS AS PIS,			   													"
   cQuery+= "   	RA_CIC AS CPF,             													"
   cQuery+= "   	RA_BCDEPSA AS 'BANCO', 														"
   cQuery+= "   	RA_CTDEPSA AS CONTA 														"
   cQuery+= "   	FROM SRA010 AS SRA      													"
   cQuery+= "   	INNER JOIN SRJ010 AS SRJ  ON RJ_FUNCAO = RA_CODFUNC  AND SUBSTRING(RA_FILIAL, 1, 2)  = RJ_FILIAL "
   cQuery+= "   	INNER JOIN CTT010 AS CTT ON CTT_CUSTO = RA_CC        						"
   cQuery+= "  		WHERE SRA.D_E_L_E_T_ = '' AND SRJ.D_E_L_E_T_ = ' ' AND CTT.D_E_L_E_T_ = ' ' "
   cQuery+= "  		AND RA_CC  BETWEEN '"+MV_PAR01+"' AND  '"+MV_PAR02+"' " 
   cQuery+= "  		AND RA_SITFOLH <>'D' "  
   
	tcQuery cQuery new alias "QRYSRA"

	aHeadXls := {"MATRICULA","FUNCIONARIO ","DTA NASCIMENTO","DTA ADMISSAO","SALARIO","FUNวรO","C.CUSTO","PIS","CPF","BANCO/AGENCIA","CONTA"}
    QRYSRA->(DBGOTOP())
	While !QRYSRA->(eof())
	
	aAdd(aColsXls,{QRYSRA->MATRICULA,QRYSRA->NOME,QRYSRA->NASCIMENTO,QRYSRA->ADMISSAO,QRYSRA->SALARIO,QRYSRA->FUNCAO,QRYSRA->CCUSTO,QRYSRA->PIS,QRYSRA->CPF,QRYSRA->BANCO,QRYSRA->CONTA})

	QRYSRA->(dbskip())
	ENDDO
	if len(aColsXls) > 0
		SPCPR06Excel(aHeadXls,aColsXls,"Relatorio Seguro de Vida ") //Exporta para Excel
	Else
		Alert("Sem Registros")
	EndIf
   
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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออฑฑ
ฑฑบPrograma  ณAJUSTASX1	บAutor		ณAndre Castilho	บ Data	ณ 21/04/2018  บฑฑ
ฑฑอออออออออออออออออออออออออออฯออออออออออออออออออออออออออฯออออออออออออออออออฑฑ
ฑฑบDesc.     ณ Cria Perguntas บฑฑ
ฑฑออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function AjustaSX1(cPerg)
	cAlias	:= Alias()

	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PADR(cPerg,10)

	PutSx1(cperg,"01","Do C.Custo   ?" ,".",".","mv_ch1","C",06,0,0,"C","NaoVazio()","","","",,"mv_par01","","","","","","","","","","","","","","","","")
	PutSx1(cperg,"02","Ate C.Custo  ?" ,".",".","mv_ch2","C",06,0,0,"C","NaoVazio()","","","",,"mv_par02","","","","","","","","","","","","","","","","")
	PutSx1(cperg,"03","Sit. Folha   ?" ,".",".","mv_ch3","C",01,0,0,"C","","","","",,"mv_par03","","","","","","","","","","","","","","","","")
//	PutSx1(cperg,"04","Ate Vencto  ?" ,".",".","mv_ch4","D",08,0,0,"G","NaoVazio()",""   ,"","",,"mv_par04","","","","","","","","","","","","","","","","")
//	PutSx1(cperg,"05","Do Cliente  ?" ,".",".","mv_ch5","C",(TamSx3("A1_COD")[1]),0,0,"G",""            ,"SA1","","",,"mv_par05","","","","","","","","","","","","","","","","")
//	PutSx1(cperg,"06","Ate Cliente ?" ,".",".","mv_ch6","C",(TamSx3("A1_COD")[1]),0,0,"G","NaoVazio()"  ,"SA1","","",,"mv_par06","","","","","","","","","","","","","","","","")
//	PutSx1(cperg,"07","Status      ?" ,"",""  ,"mv_ch7","C",01,0,0,"C","","","","","MV_PAR07","TODOS","","","","SUSPENSO","","","CANCELADO","","","ATIVO","","","","","")
//	PutSx1(cperg,"08","Ordem       ?" ,"",""  ,"mv_ch8","C",01,0,0,"C","","","","","MV_PAR08","VENCIMENTO","","","","STATUS","","","","","","","","","","","")

	DbSelectArea(cAlias)
Return()
