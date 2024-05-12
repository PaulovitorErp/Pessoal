#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'TOPCONN.CH'

user function RFISM001()
	Local oReport := nil
	Local cPerg:= Padr("RFISM001",10)
	
	//Incluo/Altero as perguntas na tabela SX1
	AjustaSX1(cPerg)	
	//gero a pergunta de modo oculto, ficando dispon�vel no   relacionadas
	Pergunte(cPerg,.F.)	          
		
	oReport := RptDef(cPerg)
	oReport:PrintDialog()
Return
 
Static Function RptDef(cNome)
	Local oReport := Nil
	Local oSection1:= Nil
	
	/*Sintaxe: TReport():New(cNome,cTitulo,cPerguntas,bBlocoCodigo,cDescricao)*/
	oReport := TReport():New(cNome,"Relatorio Fiscal Pis/Cofins",cNome,{|oReport| ReportPrint(oReport)},"Relatorio Fiscal Pis/Cofins")
	//oReport:SetPortrait() retrato 
	oReport:SetLandscape () //paisagem  
	oReport:SetTotalInLine(.F.)
	
	//Monstando a primeira se��o
	//ter� toda a liberdade de modifica-los via relatorio. 
	oSection1:= TRSection():New(oReport, "Livros Fiscais Por Item de NF", {"SFT"}, , .F., .T.)	
	
	Do case 
		Case MV_PAR07 == 1	
			TRCell():New(oSection1,"FT_FILIAL"	,"TRBSFT",GetSx3Cache("F1_FILIAL",'X3_TITULO')	,X3Picture("FT_FILIAL")		,tamSx3("FT_FILIAL")[1])
			TRCell():New(oSection1,"FT_ENTRADA" ,"TRBSFT",GetSx3Cache("FT_ENTRADA",'X3_TITULO') ,X3Picture("FT_ENTRADA")	,tamSx3("FT_ENTRADA")[1])
			TRCell():New(oSection1,"FT_EMISSAO" ,"TRBSFT",GetSx3Cache("FT_EMISSAO",'X3_TITULO') ,X3Picture("FT_EMISSAO")	,tamSx3("FT_EMISSAO")[1])
			TRCell():New(oSection1,"FT_NFISCAL" ,"TRBSFT",GetSx3Cache("FT_NFISCAL",'X3_TITULO') ,X3Picture("FT_NFISCAL")	,tamSx3("FT_NFISCAL")[1])
			TRCell():New(oSection1,"FT_SERIE"   ,"TRBSFT",GetSx3Cache("FT_SERIE",'X3_TITULO')   ,X3Picture("FT_SERIE")		,tamSx3("FT_SERIE")[1])
			TRCell():New(oSection1,"FT_ESTADO"  ,"TRBSFT",GetSx3Cache("FT_ESTADO",'X3_TITULO')   ,X3Picture("FT_ESTADO")	,tamSx3("FT_ESTADO")[1])		
			TRCell():New(oSection1,"FT_CFOP"    ,"TRBSFT",GetSx3Cache("FT_CFOP",'X3_TITULO')    ,X3Picture("FT_CFOP")		,tamSx3("FT_CFOP")[1])
			TRCell():New(oSection1,"FT_VALCONT" ,"TRBSFT",GetSx3Cache("FT_VALCONT",'X3_TITULO') ,X3Picture("FT_VALCONT")	,tamSx3("FT_VALCONT")[1])
			TRCell():New(oSection1,"FT_TOTAL"   ,"TRBSFT",GetSx3Cache("FT_TOTAL",'X3_TITULO') 	,X3Picture("FT_TOTAL")		,tamSx3("FT_TOTAL")[1])
			TRCell():New(oSection1,"FT_ALIQICM" ,"TRBSFT",GetSx3Cache("FT_ALIQICM",'X3_TITULO') ,X3Picture("FT_ALIQICM")	,tamSx3("FT_ALIQICM")[1])
			TRCell():New(oSection1,"FT_BASEICM" ,"TRBSFT",GetSx3Cache("FT_BASEICM",'X3_TITULO') ,X3Picture("FT_BASEICM")	,tamSx3("FT_BASEICM")[1])
			TRCell():New(oSection1,"FT_VALICM"  ,"TRBSFT",GetSx3Cache("FT_VALICM",'X3_TITULO')  ,X3Picture("FT_VALICM")		,tamSx3("FT_VALICM")[1])
			TRCell():New(oSection1,"FT_OBSERV"  ,"TRBSFT",GetSx3Cache("FT_OBSERV",'X3_TITULO')  ,X3Picture("FT_OBSERV")		,tamSx3("FT_OBSERV")[1])
			TRCell():New(oSection1,"FT_PDV"	    ,"TRBSFT",GetSx3Cache("FT_PDV",'X3_TITULO')     ,X3Picture("FT_PDV")		,tamSx3("FT_PDV")[1])
			TRCell():New(oSection1,"FT_PRODUTO" ,"TRBSFT",GetSx3Cache("FT_PRODUTO",'X3_TITULO') ,X3Picture("FT_PRODUTO")	,tamSx3("FT_PRODUTO")[1])
			TRCell():New(oSection1,"B1_DESC" 	,"TRBSFT",GetSx3Cache("B1_DESC",'X3_TITULO') 	,X3Picture("B1_DESC")		,tamSx3("B1_DESC")[1])
			TRCell():New(oSection1,"B1_POSIPI" 	,"TRBSFT",GetSx3Cache("B1_POSIPI",'X3_TITULO') 	,X3Picture("B1_POSIPI")		,tamSx3("B1_POSIPI")[1])
			TRCell():New(oSection1,"FT_CLASFIS" ,"TRBSFT",GetSx3Cache("FT_CLASFIS",'X3_TITULO') ,X3Picture("FT_CLASFIS")	,tamSx3("FT_CLASFIS")[1])
			TRCell():New(oSection1,"FT_NFORI"   ,"TRBSFT",GetSx3Cache("FT_NFORI",'X3_TITULO')   ,X3Picture("FT_NFORI")		,tamSx3("FT_NFORI")[1])
			TRCell():New(oSection1,"FT_SERORI"	,"TRBSFT",GetSx3Cache("FT_SERORI",'X3_TITULO')  ,X3Picture("FT_SERORI")		,tamSx3("FT_SERORI")[1])
			TRCell():New(oSection1,"FT_ALIQPIS" ,"TRBSFT",GetSx3Cache("FT_ALIQPIS",'X3_TITULO') ,X3Picture("FT_ALIQPIS")	,tamSx3("FT_ALIQPIS")[1])
			TRCell():New(oSection1,"FT_BASEPIS" ,"TRBSFT",GetSx3Cache("FT_BASEPIS",'X3_TITULO') ,X3Picture("FT_BASEPIS")	,tamSx3("FT_BASEPIS")[1])
			TRCell():New(oSection1,"FT_VALPIS"	,"TRBSFT",GetSx3Cache("FT_VALPIS",'X3_TITULO')  ,X3Picture("FT_VALPIS")		,tamSx3("FT_VALPIS")[1])
			TRCell():New(oSection1,"FT_ALIQCOF" ,"TRBSFT",GetSx3Cache("FT_ALIQCOF",'X3_TITULO') ,X3Picture("FT_ALIQCOF")	,tamSx3("FT_ALIQCOF")[1])
			TRCell():New(oSection1,"FT_BASECOF" ,"TRBSFT",GetSx3Cache("FT_BASECOF",'X3_TITULO') ,X3Picture("FT_BASECOF")	,tamSx3("FT_BASECOF")[1])
			TRCell():New(oSection1,"FT_VALCOF"	,"TRBSFT",GetSx3Cache("FT_VALCOF",'X3_TITULO')  ,X3Picture("FT_VALCOF")		,tamSx3("FT_VALCOF")[1])
			TRCell():New(oSection1,"FT_CSTPIS"  ,"TRBSFT",GetSx3Cache("FT_CSTPIS",'X3_TITULO')  ,X3Picture("FT_CSTPIS")		,tamSx3("FT_CSTPIS")[1])
			TRCell():New(oSection1,"FT_CSTCOF"  ,"TRBSFT",GetSx3Cache("FT_CSTCOF",'X3_TITULO')  ,X3Picture("FT_CSTCOF")		,tamSx3("FT_CSTCOF")[1])
			TRCell():New(oSection1,"FT_CODBCC"  ,"TRBSFT",GetSx3Cache("FT_CODBCC",'X3_TITULO')  ,X3Picture("FT_CODBCC")		,tamSx3("FT_CODBCC")[1])
			TRCell():New(oSection1,"FT_INDNTFR" ,"TRBSFT",GetSx3Cache("FT_INDNTFR",'X3_TITULO') ,X3Picture("FT_INDNTFR")	,tamSx3("FT_INDNTFR")[1])
			TRCell():New(oSection1,"FT_TNATREC" ,"TRBSFT",GetSx3Cache("FT_TNATREC",'X3_TITULO') ,X3Picture("FT_TNATREC")	,tamSx3("FT_TNATREC")[1])
			TRCell():New(oSection1,"FT_CNATREC" ,"TRBSFT",GetSx3Cache("FT_TNATREC",'X3_TITULO') ,X3Picture("FT_CNATREC")	,tamSx3("FT_CNATREC")[1])
			TRCell():New(oSection1,"FT_GRUPONC" ,"TRBSFT",GetSx3Cache("FT_GRUPONC",'X3_TITULO') ,X3Picture("FT_GRUPONC")	,tamSx3("FT_GRUPONC")[1])
		Case MV_PAR07 == 2
			TRCell():New(oSection1,"FT_FILIAL"	,"TRBSFT",GetSx3Cache("F1_FILIAL",'X3_TITULO')	,X3Picture("FT_FILIAL")		,tamSx3("FT_FILIAL")[1])
			TRCell():New(oSection1,"FT_ENTRADA" ,"TRBSFT",GetSx3Cache("FT_ENTRADA",'X3_TITULO') ,X3Picture("FT_ENTRADA")	,tamSx3("FT_ENTRADA")[1])
			TRCell():New(oSection1,"FT_EMISSAO" ,"TRBSFT",GetSx3Cache("FT_EMISSAO",'X3_TITULO') ,X3Picture("FT_EMISSAO")	,tamSx3("FT_EMISSAO")[1])
			TRCell():New(oSection1,"FT_NFISCAL" ,"TRBSFT",GetSx3Cache("FT_NFISCAL",'X3_TITULO') ,X3Picture("FT_NFISCAL")	,tamSx3("FT_NFISCAL")[1])
			TRCell():New(oSection1,"FT_SERIE"   ,"TRBSFT",GetSx3Cache("FT_SERIE",'X3_TITULO')   ,X3Picture("FT_SERIE")		,tamSx3("FT_SERIE")[1])
			TRCell():New(oSection1,"FT_ESTADO"  ,"TRBSFT",GetSx3Cache("FT_ESTADO",'X3_TITULO')   ,X3Picture("FT_ESTADO")	,tamSx3("FT_ESTADO")[1])		
			TRCell():New(oSection1,"FT_CFOP"    ,"TRBSFT",GetSx3Cache("FT_CFOP",'X3_TITULO')    ,X3Picture("FT_CFOP")		,tamSx3("FT_CFOP")[1])
			TRCell():New(oSection1,"FT_OBSERV"  ,"TRBSFT",GetSx3Cache("FT_OBSERV",'X3_TITULO')  ,X3Picture("FT_OBSERV")		,tamSx3("FT_OBSERV")[1])
			TRCell():New(oSection1,"FT_ESPECIE" ,"TRBSFT",GetSx3Cache("FT_ESPECIE",'X3_TITULO') ,X3Picture("FT_ESPECIE")	,tamSx3("FT_ESPECIE")[1])
			TRCell():New(oSection1,"FT_TIPOMOV" ,"TRBSFT",GetSx3Cache("FT_TIPOMOV",'X3_TITULO') ,X3Picture("FT_TIPOMOV")	,tamSx3("FT_TIPOMOV")[1])
			TRCell():New(oSection1,"FT_PRODUTO" ,"TRBSFT",GetSx3Cache("FT_PRODUTO",'X3_TITULO') ,X3Picture("FT_PRODUTO")	,tamSx3("FT_PRODUTO")[1])
			TRCell():New(oSection1,"B1_DESC" 	,"TRBSFT",GetSx3Cache("B1_DESC",'X3_TITULO') 	,X3Picture("B1_DESC")		,tamSx3("B1_DESC")[1])	
			TRCell():New(oSection1,"FT_QUANT" 	,"TRBSFT",GetSx3Cache("FT_QUANT",'X3_TITULO') 	,X3Picture("FT_QUANT")		,tamSx3("FT_QUANT")[1])
			TRCell():New(oSection1,"FT_PRCUNIT" ,"TRBSFT",GetSx3Cache("FT_PRCUNIT",'X3_TITULO') ,X3Picture("FT_PRCUNIT")	,tamSx3("FT_PRCUNIT")[1])
			TRCell():New(oSection1,"FT_DESCONT" ,"TRBSFT",GetSx3Cache("FT_DESCONT",'X3_TITULO') ,X3Picture("FT_DESCONT")	,tamSx3("FT_DESCONT")[1])
			TRCell():New(oSection1,"FT_TOTAL"   ,"TRBSFT",GetSx3Cache("FT_TOTAL",'X3_TITULO') 	,X3Picture("FT_TOTAL")		,tamSx3("FT_TOTAL")[1])
			TRCell():New(oSection1,"FT_VALCONT" ,"TRBSFT",GetSx3Cache("FT_VALCONT",'X3_TITULO') ,X3Picture("FT_VALCONT")	,tamSx3("FT_VALCONT")[1])
			TRCell():New(oSection1,"FT_CHVNFE" 	,"TRBSFT",GetSx3Cache("FT_CHVNFE",'X3_TITULO') 	,X3Picture("FT_CHVNFE")		,tamSx3("FT_CHVNFE")[1])
		Case MV_PAR07 == 3
			TRCell():New(oSection1,"FT_FILIAL"	,"TRBSFT",GetSx3Cache("F1_FILIAL",'X3_TITULO')	,X3Picture("FT_FILIAL")		,tamSx3("FT_FILIAL")[1])
			TRCell():New(oSection1,"FT_ENTRADA" ,"TRBSFT",GetSx3Cache("FT_ENTRADA",'X3_TITULO') ,X3Picture("FT_ENTRADA")	,tamSx3("FT_ENTRADA")[1])
			TRCell():New(oSection1,"FT_EMISSAO" ,"TRBSFT",GetSx3Cache("FT_EMISSAO",'X3_TITULO') ,X3Picture("FT_EMISSAO")	,tamSx3("FT_EMISSAO")[1])
			TRCell():New(oSection1,"FT_NFISCAL" ,"TRBSFT",GetSx3Cache("FT_NFISCAL",'X3_TITULO') ,X3Picture("FT_NFISCAL")	,tamSx3("FT_NFISCAL")[1])
			TRCell():New(oSection1,"FT_SERIE"   ,"TRBSFT",GetSx3Cache("FT_SERIE",'X3_TITULO')   ,X3Picture("FT_SERIE")		,tamSx3("FT_SERIE")[1])
			TRCell():New(oSection1,"A2_CGC"  	,"TRBSFT",GetSx3Cache("A2_CGC",'X3_TITULO')   	,X3Picture("A2_CGC")		,tamSx3("A2_CGC")[1])
			TRCell():New(oSection1,"A2_NOME"  	,"TRBSFT",GetSx3Cache("A2_NOME",'X3_TITULO')   	,X3Picture("A2_NOME")		,tamSx3("A2_NOME")[1])
			TRCell():New(oSection1,"A2_EST"  	,"TRBSFT",GetSx3Cache("A2_EST",'X3_TITULO')   	,X3Picture("A2_EST")		,tamSx3("A2_EST")[1])		
			TRCell():New(oSection1,"FT_CFOP"    ,"TRBSFT",GetSx3Cache("FT_CFOP",'X3_TITULO')    ,X3Picture("FT_CFOP")		,tamSx3("FT_CFOP")[1])
			TRCell():New(oSection1,"FT_PRODUTO" ,"TRBSFT",GetSx3Cache("FT_PRODUTO",'X3_TITULO') ,X3Picture("FT_PRODUTO")	,tamSx3("FT_PRODUTO")[1])
			TRCell():New(oSection1,"B1_DESC" 	,"TRBSFT",GetSx3Cache("B1_DESC",'X3_TITULO') 	,X3Picture("B1_DESC")		,tamSx3("B1_DESC")[1])	
			TRCell():New(oSection1,"D1_LOCAL" 	,"TRBSFT",GetSx3Cache("D1_LOCAL",'X3_TITULO') 	,X3Picture("D1_LOCAL")		,tamSx3("D1_LOCAL")[1])
			TRCell():New(oSection1,"FT_QUANT" 	,"TRBSFT",GetSx3Cache("FT_QUANT",'X3_TITULO') 	,X3Picture("FT_QUANT")		,tamSx3("FT_QUANT")[1])
			TRCell():New(oSection1,"FT_PRCUNIT" ,"TRBSFT",GetSx3Cache("FT_PRCUNIT",'X3_TITULO') ,X3Picture("FT_PRCUNIT")	,tamSx3("FT_PRCUNIT")[1])
			TRCell():New(oSection1,"FT_VALCONT" ,"TRBSFT",GetSx3Cache("FT_VALCONT",'X3_TITULO') ,X3Picture("FT_VALCONT")	,tamSx3("FT_VALCONT")[1])
		Case MV_PAR07 == 4	
			TRCell():New(oSection1,"FT_FILIAL"	,"TRBSFT",GetSx3Cache("FT_FILIAL",'X3_TITULO')	,X3Picture("FT_FILIAL")		,tamSx3("FT_FILIAL")[1])
			TRCell():New(oSection1,"FT_CLIEFOR" ,"TRBSFT",GetSx3Cache("FT_CLIEFOR",'X3_TITULO') ,X3Picture("FT_CLIEFOR")	,tamSx3("FT_CLIEFOR")[1])
			TRCell():New(oSection1,"FT_LOJA" 	,"TRBSFT",GetSx3Cache("FT_LOJA",'X3_TITULO') 	,X3Picture("FT_LOJA")		,tamSx3("FT_LOJA")[1])
			TRCell():New(oSection1,"A2_CGC" 	,"TRBSFT",GetSx3Cache("A2_CGC",'X3_TITULO') 	,X3Picture("A2_CGC")		,tamSx3("A2_CGC")[1])
			TRCell():New(oSection1,"A2_NOME"   	,"TRBSFT",GetSx3Cache("A2_NOME",'X3_TITULO')   	,X3Picture("A2_NOME")		,tamSx3("A2_NOME")[1])			
			TRCell():New(oSection1,"A2_MUN" 	,"TRBSFT",GetSx3Cache("A2_MUN",'X3_TITULO') 	,X3Picture("A2_MUN")		,tamSx3("A2_MUN")[1])
			TRCell():New(oSection1,"A2_EST" 	,"TRBSFT",GetSx3Cache("A2_EST",'X3_TITULO') 	,X3Picture("A2_EST")		,tamSx3("A2_EST")[1])
			TRCell():New(oSection1,"FT_ENTRADA" ,"TRBSFT",GetSx3Cache("FT_ENTRADA",'X3_TITULO') ,X3Picture("FT_ENTRADA")	,tamSx3("FT_ENTRADA")[1])
			TRCell():New(oSection1,"FT_EMISSAO" ,"TRBSFT",GetSx3Cache("FT_EMISSAO",'X3_TITULO') ,X3Picture("FT_EMISSAO")	,tamSx3("FT_EMISSAO")[1])
			TRCell():New(oSection1,"FT_NFISCAL" ,"TRBSFT",GetSx3Cache("FT_NFISCAL",'X3_TITULO') ,X3Picture("FT_NFISCAL")	,tamSx3("FT_NFISCAL")[1])
			TRCell():New(oSection1,"FT_SERIE"   ,"TRBSFT",GetSx3Cache("FT_SERIE",'X3_TITULO')   ,X3Picture("FT_SERIE")		,tamSx3("FT_SERIE")[1])
			TRCell():New(oSection1,"FT_ESTADO"  ,"TRBSFT",GetSx3Cache("FT_ESTADO",'X3_TITULO')   ,X3Picture("FT_ESTADO")	,tamSx3("FT_ESTADO")[1])		
			TRCell():New(oSection1,"FT_CFOP"    ,"TRBSFT",GetSx3Cache("FT_CFOP",'X3_TITULO')    ,X3Picture("FT_CFOP")		,tamSx3("FT_CFOP")[1])
			TRCell():New(oSection1,"FT_VALCONT" ,"TRBSFT",GetSx3Cache("FT_VALCONT",'X3_TITULO') ,X3Picture("FT_VALCONT")	,tamSx3("FT_VALCONT")[1])
			TRCell():New(oSection1,"FT_TOTAL"   ,"TRBSFT",GetSx3Cache("FT_TOTAL",'X3_TITULO') 	,X3Picture("FT_TOTAL")		,tamSx3("FT_TOTAL")[1])
			TRCell():New(oSection1,"FT_ALIQICM" ,"TRBSFT",GetSx3Cache("FT_ALIQICM",'X3_TITULO') ,X3Picture("FT_ALIQICM")	,tamSx3("FT_ALIQICM")[1])
			TRCell():New(oSection1,"FT_BASEICM" ,"TRBSFT",GetSx3Cache("FT_BASEICM",'X3_TITULO') ,X3Picture("FT_BASEICM")	,tamSx3("FT_BASEICM")[1])
			TRCell():New(oSection1,"FT_VALICM"  ,"TRBSFT",GetSx3Cache("FT_VALICM",'X3_TITULO')  ,X3Picture("FT_VALICM")		,tamSx3("FT_VALICM")[1])
			TRCell():New(oSection1,"FT_PRODUTO" ,"TRBSFT",GetSx3Cache("FT_PRODUTO",'X3_TITULO') ,X3Picture("FT_PRODUTO")	,tamSx3("FT_PRODUTO")[1])
			TRCell():New(oSection1,"B1_DESC" 	,"TRBSFT",GetSx3Cache("B1_DESC",'X3_TITULO') 	,X3Picture("B1_DESC")		,tamSx3("B1_DESC")[1])
			TRCell():New(oSection1,"B1_POSIPI" 	,"TRBSFT",GetSx3Cache("B1_POSIPI",'X3_TITULO') 	,X3Picture("B1_POSIPI")		,tamSx3("B1_POSIPI")[1])
			TRCell():New(oSection1,"FT_CLASFIS" ,"TRBSFT",GetSx3Cache("FT_CLASFIS",'X3_TITULO') ,X3Picture("FT_CLASFIS")	,tamSx3("FT_CLASFIS")[1])
	ENDCASE
	oReport:SetTotalInLine(.F.)			
Return(oReport)
 
Static Function ReportPrint(oReport)
	Local oSection1 := oReport:Section(1)	 
	Local cQuery    := ""	      
 
	//Monto minha consulta conforme parametros passado
	DO Case
		Case MV_PAR07 == 3 .OR. MV_PAR07 == 4 
			cQuery := "	SELECT FT_FILIAL,
			cQuery += "	convert(varchar(10),cast (FT_ENTRADA as date),103) FT_ENTRADA,
			cQuery += "	convert(varchar(10),cast (FT_EMISSAO as date),103) FT_EMISSAO,
			cQuery += "	FT_NFISCAL,
			cQuery += "	FT_SERIE,
			cQuery += "	FT_CFOP,
			cQuery += "	FT_VALCONT,
			cQuery += "	FT_TOTAL,
			cQuery += "	FT_ALIQICM,
			cQuery += "	FT_BASEICM,
			cQuery += "	FT_VALICM,
			cQuery += "	FT_OBSERV,
			cQuery += "	FT_PDV,	
			cQuery += "	FT_PRODUTO,
			cQuery += "	FT_CLASFIS,
			cQuery += "	FT_NFORI,
			cQuery += "	FT_SERORI,	
			cQuery += "	FT_ALIQPIS,
			cQuery += "	FT_BASEPIS,
			cQuery += "	FT_VALPIS,	
			cQuery += "	FT_ALIQCOF,
			cQuery += "	FT_BASECOF,
			cQuery += "	FT_VALCOF,	
			cQuery += "	FT_CSTPIS,
			cQuery += "	FT_CSTCOF,
			cQuery += "	FT_CODBCC,
			cQuery += "	FT_INDNTFR,
			cQuery += "	FT_TNATREC,
			cQuery += "	FT_CNATREC,
			cQuery += "	FT_GRUPONC,
			cQuery += "	FT_CHVNFE,
			cQuery += "	FT_DESCONT,
			cQuery += "	FT_PRCUNIT,
			cQuery += "	FT_QUANT,
			cQuery += "	FT_TIPOMOV,
			cQuery += "	FT_ESPECIE,
			cQuery += "	FT_ESTADO,
			cQuery += "	B1_DESC,
			cQuery += "	B1_POSIPI,
			cQuery += "	D1_LOCAL,
			cQuery += "	FT_CLIEFOR,
			cQuery += "	FT_LOJA,
			cQuery += "	A2_NOME,
			cQuery += "	A2_CGC,
			cQuery += "	A2_EST,
			cQuery += "	A2_MUN,
			cQuery += "	FT_NFORI
			cQuery += "	FROM "+RETSQLNAME("SFT")+" SFT (NOLOCK)"
			cQuery += "	INNER JOIN "+RETSQLNAME("SB1")+" SB1 (NOLOCK) ON
			cQuery += "	SB1.B1_COD = FT_PRODUTO
			If MV_PAR07 == 3
				cQuery += "	AND SB1.B1_GRUPO = '0001'
			EndIf
			cQuery += "	AND SB1.D_E_L_E_T_ = ''
			cQuery += "	LEFT JOIN "+RETSQLNAME("SA2")+" SA2 (NOLOCK) ON
			cQuery += "	SA2.A2_COD = FT_CLIEFOR
			cQuery += "	AND SA2.A2_LOJA = FT_LOJA
			cQuery += "	AND SA2.D_E_L_E_T_ = ''
			cQuery += "	INNER JOIN "+RETSQLNAME("SD1")+" SD1 (NOLOCK) ON
			cQuery += "	SD1.D1_DOC = FT_NFISCAL
			cQuery += "	AND SD1.D1_SERIE = FT_SERIE
			cQuery += "	AND SD1.D1_ITEM = FT_ITEM
			cQuery += "	AND SD1.D1_FORNECE = FT_CLIEFOR
			cQuery += "	AND SD1.D1_LOJA = FT_LOJA
			cQuery += "	AND SD1.D_E_L_E_T_ = ''
			cQuery += "	WHERE FT_ENTRADA BETWEEN '"+dtos(mv_par01)+"' AND '"+dtos(mv_par02)+"'
			cQuery += "	AND FT_CFOP BETWEEN '"+mv_par03+"' AND '"+mv_par04+"'
			cQuery += "	AND FT_FILIAL BETWEEN '"+mv_par05+"' AND '"+mv_par06+"'
			cQuery += "	AND FT_CFOP <= '5000'
			cQuery += "	AND SFT.D_E_L_E_T_ = ''
			cQuery += "	ORDER BY FT_FILIAL,FT_NFISCAL,FT_SERIE,FT_CFOP,FT_PRODUTO
		OtherWise
			cQuery := "	SELECT FT_FILIAL,
			cQuery += "	convert(varchar(10),cast (FT_ENTRADA as date),103) FT_ENTRADA,
			cQuery += "	convert(varchar(10),cast (FT_EMISSAO as date),103) FT_EMISSAO,
			cQuery += "	FT_NFISCAL,
			cQuery += "	FT_SERIE,
			cQuery += "	FT_CFOP,
			cQuery += "	FT_VALCONT,
			cQuery += "	FT_TOTAL,
			cQuery += "	FT_ALIQICM,
			cQuery += "	FT_BASEICM,
			cQuery += "	FT_VALICM,
			cQuery += "	FT_OBSERV,
			cQuery += "	FT_PDV,	
			cQuery += "	FT_PRODUTO,
			cQuery += "	FT_CLASFIS,
			cQuery += "	FT_NFORI,
			cQuery += "	FT_SERORI,	
			cQuery += "	FT_ALIQPIS,
			cQuery += "	FT_BASEPIS,
			cQuery += "	FT_VALPIS,	
			cQuery += "	FT_ALIQCOF,
			cQuery += "	FT_BASECOF,
			cQuery += "	FT_VALCOF,	
			cQuery += "	FT_CSTPIS,
			cQuery += "	FT_CSTCOF,
			cQuery += "	FT_CODBCC,
			cQuery += "	FT_INDNTFR,
			cQuery += "	FT_TNATREC,
			cQuery += "	FT_CNATREC,
			cQuery += "	FT_GRUPONC,
			cQuery += "	FT_CHVNFE,
			cQuery += "	FT_DESCONT,
			cQuery += "	FT_PRCUNIT,
			cQuery += "	FT_QUANT,
			cQuery += "	FT_TIPOMOV,
			cQuery += "	FT_ESPECIE,
			cQuery += "	FT_ESTADO,
			cQuery += "	B1_DESC,
			cQuery += "	B1_POSIPI
			cQuery += "	FROM "+RETSQLNAME("SFT")+" SFT (NOLOCK)"
			cQuery += "	INNER JOIN "+RETSQLNAME("SB1")+" SB1 (NOLOCK) ON
			cQuery += "	SB1.B1_COD = FT_PRODUTO
			cQuery += "	AND SB1.D_E_L_E_T_ = ''
			cQuery += "	WHERE FT_ENTRADA BETWEEN '"+dtos(mv_par01)+"' AND '"+dtos(mv_par02)+"'
			cQuery += "	AND FT_CFOP BETWEEN '"+mv_par03+"' AND '"+mv_par04+"'
			cQuery += "	AND FT_FILIAL BETWEEN '"+mv_par05+"' AND '"+mv_par06+"'
			cQuery += "	AND SFT.D_E_L_E_T_ = ''
			cQuery += "	ORDER BY FT_FILIAL,FT_NFISCAL,FT_SERIE,FT_CFOP,FT_PRODUTO
	ENDCASE
	//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
	IF Select("TRBSFT") > 0
		DbSelectArea("TRBSFT")
		DbCloseArea()
	ENDIF
	
	//crio o novo alias
	TCQUERY cQuery NEW ALIAS "TRBSFT"	
	
	dbSelectArea("TRBSFT")
	TRBSFT->(dbGoTop())
	
	oReport:SetMeter(TRBSFT->(LastRec()))	
	//Irei percorrer todos os meus registros
	//inicializo a primeira secao
	oSection1:Init()
	While TRBSFT->(!Eof())
		
		If oReport:Cancel()
			Exit
		EndIf
		IncProc("Imprimindo "+TRBSFT->FT_NFISCAL+"/"+TRBSFT->FT_SERIE)
		
		//imprimo a primeira secao	
		DO Case
		Case MV_PAR07 == 1		
			oSection1:Cell("FT_FILIAL"):SetValue(TRBSFT->FT_FILIAL)
			oSection1:Cell("FT_ENTRADA"):SetValue(TRBSFT->FT_ENTRADA)
			oSection1:Cell("FT_EMISSAO"):SetValue(TRBSFT->FT_EMISSAO)
			oSection1:Cell("FT_NFISCAL"):SetValue(TRBSFT->FT_NFISCAL)
			oSection1:Cell("FT_SERIE"):SetValue(TRBSFT->FT_SERIE)
			oSection1:Cell("FT_ESTADO"):SetValue(TRBSFT->FT_ESTADO)  
			oSection1:Cell("FT_CFOP"):SetValue(TRBSFT->FT_CFOP)
			oSection1:Cell("FT_VALCONT"):SetValue(TRBSFT->FT_VALCONT)
			oSection1:Cell("FT_TOTAL"):SetValue(TRBSFT->FT_TOTAL)
			oSection1:Cell("FT_ALIQICM"):SetValue(TRBSFT->FT_ALIQICM)
			oSection1:Cell("FT_BASEICM"):SetValue(TRBSFT->FT_BASEICM)
			oSection1:Cell("FT_VALICM"):SetValue(TRBSFT->FT_VALICM)
			oSection1:Cell("FT_OBSERV"):SetValue(TRBSFT->FT_OBSERV)
			oSection1:Cell("FT_PDV"):SetValue(TRBSFT->FT_PDV)
			oSection1:Cell("FT_PRODUTO"):SetValue(TRBSFT->FT_PRODUTO)
			oSection1:Cell("B1_DESC"):SetValue(TRBSFT->B1_DESC)
			oSection1:Cell("B1_POSIPI"):SetValue(TRBSFT->B1_POSIPI)
			oSection1:Cell("FT_CLASFIS"):SetValue(TRBSFT->FT_CLASFIS)
			oSection1:Cell("FT_NFORI"):SetValue(TRBSFT->FT_NFORI)
			oSection1:Cell("FT_SERORI"):SetValue(TRBSFT->FT_SERORI)	
			oSection1:Cell("FT_ALIQPIS"):SetValue(TRBSFT->FT_ALIQPIS)
			oSection1:Cell("FT_BASEPIS"):SetValue(TRBSFT->FT_BASEPIS)
			oSection1:Cell("FT_VALPIS"):SetValue(TRBSFT->FT_VALPIS)
			oSection1:Cell("FT_ALIQCOF"):SetValue(TRBSFT->FT_ALIQCOF)
			oSection1:Cell("FT_BASECOF"):SetValue(TRBSFT->FT_BASECOF)
			oSection1:Cell("FT_VALCOF"):SetValue(TRBSFT->FT_VALCOF)
			oSection1:Cell("FT_CSTPIS"):SetValue(TRBSFT->FT_CSTPIS)
			oSection1:Cell("FT_CSTCOF"):SetValue(TRBSFT->FT_CSTCOF)
			oSection1:Cell("FT_CODBCC"):SetValue(TRBSFT->FT_CODBCC)
			oSection1:Cell("FT_INDNTFR"):SetValue(TRBSFT->FT_INDNTFR)
			oSection1:Cell("FT_TNATREC"):SetValue(TRBSFT->FT_TNATREC)
			oSection1:Cell("FT_CNATREC"):SetValue(TRBSFT->FT_CNATREC)
			oSection1:Cell("FT_GRUPONC"):SetValue(TRBSFT->FT_GRUPONC)
		Case MV_PAR07 == 2
			oSection1:Cell("FT_FILIAL"):SetValue(TRBSFT->FT_FILIAL)	
			oSection1:Cell("FT_ENTRADA"):SetValue(TRBSFT->FT_ENTRADA) 
			oSection1:Cell("FT_EMISSAO"):SetValue(TRBSFT->FT_EMISSAO) 
			oSection1:Cell("FT_NFISCAL"):SetValue(TRBSFT->FT_NFISCAL) 
			oSection1:Cell("FT_SERIE"):SetValue(TRBSFT->FT_SERIE)   
			oSection1:Cell("FT_ESTADO"):SetValue(TRBSFT->FT_ESTADO)  
			oSection1:Cell("FT_CFOP"):SetValue(TRBSFT->FT_CFOP)    
			oSection1:Cell("FT_OBSERV"):SetValue(TRBSFT->FT_OBSERV)  
			oSection1:Cell("FT_ESPECIE"):SetValue(TRBSFT->FT_ESPECIE) 
			oSection1:Cell("FT_TIPOMOV"):SetValue(TRBSFT->FT_TIPOMOV) 
			oSection1:Cell("FT_PRODUTO"):SetValue(TRBSFT->FT_PRODUTO) 
			oSection1:Cell("B1_DESC"):SetValue(TRBSFT->B1_DESC)
			oSection1:Cell("FT_QUANT"):SetValue(TRBSFT->FT_QUANT) 	
			oSection1:Cell("FT_PRCUNIT"):SetValue(TRBSFT->FT_PRCUNIT) 
			oSection1:Cell("FT_DESCONT"):SetValue(TRBSFT->FT_DESCONT) 
			oSection1:Cell("FT_TOTAL"):SetValue(TRBSFT->FT_TOTAL)   
			oSection1:Cell("FT_VALCONT"):SetValue(TRBSFT->FT_VALCONT) 
			oSection1:Cell("FT_CHVNFE"):SetValue(TRBSFT->FT_CHVNFE)
		Case MV_PAR07 == 3
			oSection1:Cell("FT_FILIAL"):SetValue(TRBSFT->FT_FILIAL)	
			oSection1:Cell("FT_ENTRADA"):SetValue(TRBSFT->FT_ENTRADA) 
			oSection1:Cell("FT_EMISSAO"):SetValue(TRBSFT->FT_EMISSAO) 
			oSection1:Cell("FT_NFISCAL"):SetValue(TRBSFT->FT_NFISCAL)
			oSection1:Cell("FT_SERIE"):SetValue(TRBSFT->FT_SERIE)  
			IF !EMPTY(TRBSFT->FT_NFORI)
				oSection1:Cell("A2_CGC"):SetValue(Posicione("SA1",1,xFilial("SA1")+TRBSFT->FT_CLIEFOR+TRBSFT->FT_LOJA,"A1_CGC"))   
				oSection1:Cell("A2_NOME"):SetValue(Posicione("SA1",1,xFilial("SA1")+TRBSFT->FT_CLIEFOR+TRBSFT->FT_LOJA,"A1_NOME"))   
				oSection1:Cell("A2_EST"):SetValue(Posicione("SA1",1,xFilial("SA1")+TRBSFT->FT_CLIEFOR+TRBSFT->FT_LOJA,"A1_EST"))
			else
				oSection1:Cell("A2_CGC"):SetValue(TRBSFT->A2_CGC)   
				oSection1:Cell("A2_NOME"):SetValue(TRBSFT->A2_NOME)   
				oSection1:Cell("A2_EST"):SetValue(TRBSFT->A2_EST)
			ENDIF  
			oSection1:Cell("FT_CFOP"):SetValue(TRBSFT->FT_CFOP) 
			oSection1:Cell("FT_PRODUTO"):SetValue(TRBSFT->FT_PRODUTO) 
			oSection1:Cell("B1_DESC"):SetValue(TRBSFT->B1_DESC)
			oSection1:Cell("D1_LOCAL"):SetValue(TRBSFT->D1_LOCAL)
			oSection1:Cell("FT_QUANT"):SetValue(TRBSFT->FT_QUANT) 	
			oSection1:Cell("FT_PRCUNIT"):SetValue(TRBSFT->FT_PRCUNIT) 
			oSection1:Cell("FT_VALCONT"):SetValue(TRBSFT->FT_VALCONT)
		Case MV_PAR07 == 4		
			oSection1:Cell("FT_FILIAL"):SetValue(TRBSFT->FT_FILIAL)
			oSection1:Cell("FT_CLIEFOR"):SetValue(TRBSFT->FT_CLIEFOR)   
			oSection1:Cell("FT_LOJA"):SetValue(TRBSFT->FT_LOJA)  
			IF !EMPTY(TRBSFT->FT_NFORI)
				oSection1:Cell("A2_CGC"):SetValue(Posicione("SA1",1,xFilial("SA1")+TRBSFT->FT_CLIEFOR+TRBSFT->FT_LOJA,"A1_CGC"))   
				oSection1:Cell("A2_NOME"):SetValue(Posicione("SA1",1,xFilial("SA1")+TRBSFT->FT_CLIEFOR+TRBSFT->FT_LOJA,"A1_NOME"))   
				oSection1:Cell("A2_MUN"):SetValue(Posicione("SA1",1,xFilial("SA1")+TRBSFT->FT_CLIEFOR+TRBSFT->FT_LOJA,"A1_MUN"))
				oSection1:Cell("A2_EST"):SetValue(Posicione("SA1",1,xFilial("SA1")+TRBSFT->FT_CLIEFOR+TRBSFT->FT_LOJA,"A1_EST"))
			else
				oSection1:Cell("A2_CGC"):SetValue(TRBSFT->A2_CGC)   
				oSection1:Cell("A2_NOME"):SetValue(TRBSFT->A2_NOME)   
				oSection1:Cell("A2_MUN"):SetValue(TRBSFT->A2_MUN)
				oSection1:Cell("A2_EST"):SetValue(TRBSFT->A2_EST)
			ENDIF  
			oSection1:Cell("FT_ENTRADA"):SetValue(TRBSFT->FT_ENTRADA)
			oSection1:Cell("FT_EMISSAO"):SetValue(TRBSFT->FT_EMISSAO)
			oSection1:Cell("FT_NFISCAL"):SetValue(TRBSFT->FT_NFISCAL)
			oSection1:Cell("FT_SERIE"):SetValue(TRBSFT->FT_SERIE)
			oSection1:Cell("FT_ESTADO"):SetValue(TRBSFT->FT_ESTADO)  
			oSection1:Cell("FT_CFOP"):SetValue(TRBSFT->FT_CFOP)
			oSection1:Cell("FT_VALCONT"):SetValue(TRBSFT->FT_VALCONT)
			oSection1:Cell("FT_TOTAL"):SetValue(TRBSFT->FT_TOTAL)
			oSection1:Cell("FT_ALIQICM"):SetValue(TRBSFT->FT_ALIQICM)
			oSection1:Cell("FT_BASEICM"):SetValue(TRBSFT->FT_BASEICM)
			oSection1:Cell("FT_VALICM"):SetValue(TRBSFT->FT_VALICM)
			oSection1:Cell("FT_PRODUTO"):SetValue(TRBSFT->FT_PRODUTO)
			oSection1:Cell("B1_DESC"):SetValue(TRBSFT->B1_DESC)
			oSection1:Cell("B1_POSIPI"):SetValue(TRBSFT->B1_POSIPI)
			oSection1:Cell("FT_CLASFIS"):SetValue(TRBSFT->FT_CLASFIS)
		ENDCASE
		oSection1:Printline()
		TRBSFT->(dbSkip())
 		oReport:IncMeter()
	Enddo
	//finalizo a primeira selecao
 	oSection1:Finish()
Return
 
static function ajustaSx1(cPerg)
	//Aqui utilizo a funcao putSx1, ela cria a pergunta na tabela de perguntas
	putSx1(cPerg, "01", "Da Dt. Entrada?"		, "", "", "mv_ch1", "D", 08						, 0, 0, "G", "", "", "", "", "mv_par01")
	putSx1(cPerg, "02", "Até a Dt. Entrada?"	, "", "", "mv_ch2", "D", 08						, 0, 0, "G", "", "", "", "", "mv_par02")
	putSx1(cPerg, "03", "Do Cfop?"	  			, "", "", "mv_ch3", "C", tamSx3("FT_CFOP")[1]	, 0, 0, "G", "", "", "", "", "mv_par03")
	putSx1(cPerg, "04", "Até o Cfop?"	  		, "", "", "mv_ch4", "C", tamSx3("FT_CFOP")[1]	, 0, 0, "G", "", "", "", "", "mv_par04")
	putSx1(cPerg, "05", "Da Filial?"	  		, "", "", "mv_ch5", "C", 4						, 0, 0, "G", "", "", "", "", "mv_par05")
	putSx1(cPerg, "06", "Até a Filial?"	  		, "", "", "mv_ch6", "C", 4						, 0, 0, "G", "", "", "", "", "mv_par06")
	PutSx1( cPerg, "07","Layout"				,"","","mv_ch7","N",2,0,1,"C","","","","S","MV_PAR07","Layout 1","","","","Layout 2","","","","","","","","","","","",{},{},{})
return
