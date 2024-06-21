#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "PROTHEUS.CH"

//--------------------------------------------------------------
/*/{Protheus.doc} RCONR013
Description
                                                                
@param xParam Parameter Description                             
@return xRet Return Description
@author teste - teste@hotmail.com                                              
@since 26/01/2020
/*/                                                             
//--------------------------------------------------------------

User Function RCONR013()
Private oButton1,oButton2,oGroup1,oSay1
Private oSay2,oSay3,oSay4,oSay5,oSay6

Private oCredAte
Private cCredAte := "ZZZZZZZZZZZZZZZZZZZZ"
Private oCredDe
Private cCredDe  := Space(20)
Private oDebAte
Private cDebAte  := "ZZZZZZZZZZZZZZZZZZZZ"
Private oDebDe
Private cDebDe   := Space(20)
Private oMovAte
Private cMovAte  := ddatabase
Private oMovDe
Private cMovDe   := ddatabase

Static oDlg

  DEFINE MSDIALOG oDlg TITLE "Exportar Contabilidade" FROM 000, 000  TO 500, 600 COLORS 0, 16777215 PIXEL

    @ 001, 003 GROUP oGroup1 TO 224, 295 PROMPT "Exportar Contabilidade Excel" OF oDlg COLOR 0, 16777215 PIXEL
    
    @ 012, 010 SAY oSay1 PROMPT "Data Mov De :" SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 022, 010 MSGET oMovDe VAR cMovDe SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    
    @ 012, 088 SAY oSay2 PROMPT "Data Mov Ate:" SIZE 054, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 022, 087 MSGET oMovAte VAR cMovAte SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
 /*   
    @ 037, 010 SAY oSay3 PROMPT "Conta Credito De :" SIZE 061, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 062, 010 SAY oSay4 PROMPT "Conta Debito De:" SIZE 051, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 037, 088 SAY oSay5 PROMPT "Conta Credito ate:" SIZE 054, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 062, 087 SAY oSay6 PROMPT "Conta Debito Ate :" SIZE 074, 007 OF oDlg COLORS 0, 16777215 PIXEL
    
    @ 047, 010 MSGET oCredDe  VAR cCredDe  SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL F3 "CT1"
    @ 047, 087 MSGET oCredAte VAR cCredAte SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL F3 "CT1"
    @ 073, 010 MSGET oDebDe   VAR cDebDe   SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL F3 "CT1"
    @ 073, 087 MSGET oDebAte  VAR cDebAte  SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL F3 "CT1"
*/

    @ 231, 234 BUTTON oButton1 PROMPT "Imprimir Excel" SIZE 060, 012 OF oDlg PIXEL Action Processa({||  impriRela()},"Imprimindo arquivo.","Aguarde...") 
    @ 231, 164 BUTTON oButton2 PROMPT "Fechar" SIZE 060, 012 OF oDlg PIXEL Action (Close(Odlg))  

  ACTIVATE MSDIALOG oDlg CENTERED

Return()

Static Function impriRela()
	Local cQuery 		:= ""
	Local cPulaLinha	:= chr(13)+chr(10)
	Local cBody			:= ""
	Local cHeader		:= ""
	Local cTrailer		:= ""
	Local nCont			:= 0

	Private cStartPath
	Private cDirDocs  	:= MsDocPath()
	Private cArquivo 	:= CriaTrab(,.F.)
	Private cPath		:= AllTrim(GetTempPath())
	
	ProcRegua(Reccount())
		
	_aColsXls := {}
	nContador := 1
	
	/*
	_aHeadXls := {  "CT2_FILIAL"  ,;
					"DATA REF"	  ,;
					"MES"	  	  ,;
					"ANO"	  	  ,;										
					"CT2_LOTE"	  ,;
					"CT2_SBLOTE"  ,;
					"CT2_DOC"	  ,;
					"CT2_LINHA"	  ,;
					"CT2_DC"	  ,;
					"DESC_DC"	  ,;
					"CT2_ITEMC"	  ,;
					"CT2_ITEMD"	  ,;
					"NOM_FORNEC"  ,;
					"NOM_CLIENTE" ,;
					"CT2_DEBITO"  ,;
					"CT2_CREDIT"  ,;
					"CT2_VALOR"	  ,;
					"CT2_HIST"	  ,;
					"CT2_CCD"	  ,;
					"CT2_CCC"	  ,;
					"CT2_CLVLDB"  ,;
					"CT2_CLVLCR"  ,;
					"CT2_EMPORI"  ,;
					"CT2_FILORI"  ,;
					"CV3_TABORI"  ,;
					"CV3_HIST"	  ,;
					"DESC_CCUSTO" ,;
					"DESC_CONTA_DEBITO"		,;
					"DESC_CONTA_CREDITO"	,;
					"COD_NATUREZA"	        ,;
					"DESC_NATUREZA",;
					"EMISSAO",;
					"VENCIMENTO",;
					"NUMERO"}

	If(SELECT("TMPCON") > 0)
		TMPCON->(DBCLOSEAREA())
	Endif

	cQuery:= " SELECT CT2_FILIAL,CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC,CT2_LINHA,CT2_DC, "+ cPulaLinha
	cQuery+= " CASE "+ cPulaLinha
	cQuery+= "    WHEN CT2_DC = '1' THEN 'Debito' "+ cPulaLinha
	cQuery+= "    WHEN CT2_DC = '2' THEN 'Credito' "+ cPulaLinha
	cQuery+= "    WHEN CT2_DC = '3' THEN 'Partida Dobrada' "+ cPulaLinha
	cQuery+= "	  WHEN CT2_DC = '4' THEN 'Cont.Hist' "+ cPulaLinha
	cQuery+= "	  WHEN CT2_DC = '5' THEN 'Rateio' "+ cPulaLinha
	cQuery+= "	  WHEN CT2_DC = '6' THEN 'Lcto Padrao' "+ cPulaLinha
	cQuery+= "	Else CT2_DC "+ cPulaLinha
	cQuery+= " END DESC_DC "+ cPulaLinha
	cQuery+= " ,CT2_ITEMC,CT2_ITEMD, "+ cPulaLinha
	cQuery+= "	CASE  "+ cPulaLinha
	cQuery+= "		WHEN SUBSTRING(CT2.CT2_ITEMC,1,1) = 'F'  THEN (SELECT A2_NOME FROM SA2010 SA2A WHERE SUBSTRING(A2_FILIAL,1,2)  = SUBSTRING(CT2_FILIAL,1,2) AND SUBSTRING(CT2_ITEMC,2,8) = SA2A.A2_COD+SA2A.A2_LOJA AND SA2A.D_E_L_E_T_ = ' ') "+ cPulaLinha
	cQuery+= "		WHEN SUBSTRING(CT2.CT2_ITEMD,1,1) = 'F'  THEN (SELECT A2_NOME FROM SA2010 SA2B WHERE SUBSTRING(A2_FILIAL,1,2)  = SUBSTRING(CT2_FILIAL,1,2) AND SUBSTRING(CT2_ITEMD,2,8) = SA2B.A2_COD+SA2B.A2_LOJA AND SA2B.D_E_L_E_T_ = ' ') "+ cPulaLinha
	cQuery+= "	ELSE ' ' "+ cPulaLinha
	cQuery+= " END NOM_FORNEC, "+ cPulaLinha
	cQuery+= "	CASE  "+ cPulaLinha
	cQuery+= "		WHEN SUBSTRING(CT2.CT2_ITEMC,1,1) = 'C'  THEN (SELECT A1_NOME FROM SA1010 SA1A WHERE SUBSTRING(A1_FILIAL,1,2)  = SUBSTRING(CT2_FILIAL,1,2) AND SUBSTRING(CT2_ITEMC,2,8) = SA1A.A1_COD+SA1A.A1_LOJA AND SA1A.D_E_L_E_T_ = ' ') "+ cPulaLinha
	cQuery+= "		WHEN SUBSTRING(CT2.CT2_ITEMD,1,1) = 'C'  THEN (SELECT A1_NOME FROM SA1010 SA1B WHERE SUBSTRING(A1_FILIAL,1,2)  = SUBSTRING(CT2_FILIAL,1,2) AND SUBSTRING(CT2_ITEMD,2,8) = SA1B.A1_COD+SA1B.A1_LOJA AND SA1B.D_E_L_E_T_ = ' ') "+ cPulaLinha
	cQuery+= "	ELSE ' ' "+ cPulaLinha
	cQuery+= " END NOM_CLIENTE "+ cPulaLinha
	cQuery+= " ,CT2_DEBITO,CT2_CREDIT,CT2_VALOR "+ cPulaLinha
	cQuery+= " ,CT2_HP,CT2_HIST,CT2_CCD,CT2_CCC,CT2_ITEMC,CT2_ITEMD "+ cPulaLinha
	cQuery+= " ,CT2_CLVLDB,CT2_CLVLCR,CT2_EMPORI,CT2_FILORI, "+ cPulaLinha
	cQuery+= " CV3_FILIAL,CV3_SEQUEN,CV3_DTSEQ,CV3_LP,CV3_KEY,CV3_DC,CV3_HIST,CV3_DEBITO,CV3_CREDIT,CV3_VLR01,CV3_ITEMC, "+ cPulaLinha
	cQuery+= " CV3_ITEMD,CV3_CCC,CV3_CCD,CV3_TABORI,CV3_RECORI,CV3_RECDES, "+ cPulaLinha
	cQuery+= "	CASE  "+ cPulaLinha
	cQuery+= "		WHEN CT2_CCC <> ' '  THEN (SELECT CTT_DESC01 FROM CTT010 CTTA WHERE SUBSTRING(CTT_FILIAL,1,2)  = SUBSTRING(CT2_FILIAL,1,2) AND CT2_CCC = CTTA.CTT_CUSTO AND CTTA.D_E_L_E_T_ = ' ') "+ cPulaLinha
	cQuery+= "		WHEN CT2_CCD <> ' '  THEN (SELECT CTT_DESC01 FROM CTT010 CTTB WHERE SUBSTRING(CTT_FILIAL,1,2)  = SUBSTRING(CT2_FILIAL,1,2) AND CT2_CCD = CTTB.CTT_CUSTO AND CTTB.D_E_L_E_T_ = ' ') "+ cPulaLinha
	cQuery+= "	ELSE ' ' "+ cPulaLinha
	cQuery+= " END DESC_CCUSTO, "+ cPulaLinha
	cQuery+= "	CASE  "+ cPulaLinha
	cQuery+= "		WHEN CT2_DEBITO <> ' '  THEN (SELECT CT1_DESC01 FROM CT1010 CT1A WHERE SUBSTRING(CT1_FILIAL,1,2)  = SUBSTRING(CT2_FILIAL,1,2) AND CT2_DEBITO = CT1A.CT1_CONTA AND CT1A.D_E_L_E_T_ = ' ') "+ cPulaLinha
	cQuery+= "	ELSE ' ' "+ cPulaLinha
	cQuery+= " END DESC_CONTA_DEBITO, "+ cPulaLinha
	cQuery+= "	CASE  "+ cPulaLinha
	cQuery+= "		WHEN CT2_CREDIT <> ' '  THEN (SELECT CT1_DESC01 FROM CT1010 CT1A WHERE SUBSTRING(CT1_FILIAL,1,2)  = SUBSTRING(CT2_FILIAL,1,2) AND CT2_CREDIT = CT1A.CT1_CONTA AND CT1A.D_E_L_E_T_ = ' ') "+ cPulaLinha
	cQuery+= "	ELSE ' ' "+ cPulaLinha
	cQuery+= " END DESC_CONTA_CREDITO, "+ cPulaLinha
	cQuery+= "	CASE "+ cPulaLinha
	cQuery+= " 		WHEN CV3_TABORI = 'SE1' THEN SE1.E1_NATUREZ "+ cPulaLinha
	cQuery+= " 		WHEN CV3_TABORI = 'SF2' THEN SE1B.E1_NATUREZ "+ cPulaLinha
	cQuery+= " 		WHEN CV3_TABORI = 'SE2' THEN SE2.E2_NATUREZ "+ cPulaLinha
	cQuery+= " 		WHEN CV3_TABORI = 'SE5' THEN SE5.E5_NATUREZ "+ cPulaLinha
	cQuery+= " 		WHEN CV3_TABORI = 'SD1' THEN SE2B.E2_NATUREZ "+ cPulaLinha
	cQuery+= " 		WHEN CV3_TABORI = 'SD2' THEN SE1C.E1_NATUREZ "+ cPulaLinha
	cQuery+= " 	END COD_NATUREZA , "+ cPulaLinha
	cQuery+= " CASE "+ cPulaLinha
	cQuery+= " 	 	WHEN CV3_TABORI = 'SE1' THEN SE1.E1_VENCREA "+ cPulaLinha
	cQuery+= " 	 	WHEN CV3_TABORI = 'SF2' THEN SE1B.E1_VENCREA "+ cPulaLinha
	cQuery+= " 	 	WHEN CV3_TABORI = 'SE2' THEN SE2.E2_VENCREA "+ cPulaLinha
	cQuery+= " 	 	WHEN CV3_TABORI = 'SE5' THEN SE5.E5_VENCTO "+ cPulaLinha
	cQuery+= " 	 	WHEN CV3_TABORI = 'SD1' THEN SE2B.E2_VENCTO "+ cPulaLinha
	cQuery+= " 	 	WHEN CV3_TABORI = 'SD2' THEN SE1C.E1_VENCTO "+ cPulaLinha
	cQuery+= " END VENCTO, "+ cPulaLinha
	cQuery+= " 	CASE "+ cPulaLinha
	cQuery+= " 	 	WHEN CV3_TABORI = 'SE1' THEN SE1.E1_EMISSAO "+ cPulaLinha
	cQuery+= " 	 	WHEN CV3_TABORI = 'SF2' THEN SE1B.E1_EMISSAO "+ cPulaLinha
	cQuery+= " 	 	WHEN CV3_TABORI = 'SE2' THEN SE2.E2_EMISSAO "+ cPulaLinha
	cQuery+= " 	 	WHEN CV3_TABORI = 'SE5' THEN SE5.E5_DATA "+ cPulaLinha
	cQuery+= " 	 	WHEN CV3_TABORI = 'SD1' THEN SE2B.E2_EMISSAO "+ cPulaLinha
	cQuery+= " 		WHEN CV3_TABORI = 'SD2' THEN SE1C.E1_EMISSAO "+ cPulaLinha
	cQuery+= " END EMISSAO, "+ cPulaLinha
	cQuery+= "	CASE "+ cPulaLinha
	cQuery+= "	 	WHEN CV3_TABORI = 'SE1' THEN SE1.E1_NUM "+ cPulaLinha
	cQuery+= "	 	WHEN CV3_TABORI = 'SF2' THEN SE1B.E1_NUM "+ cPulaLinha
	cQuery+= "	 	WHEN CV3_TABORI = 'SE2' THEN SE2.E2_NUM "+ cPulaLinha
	cQuery+= "	 	WHEN CV3_TABORI = 'SE5' THEN SE5.E5_NUMERO "+ cPulaLinha
	cQuery+= "	 	WHEN CV3_TABORI = 'SD1' THEN SE2B.E2_NUM "+ cPulaLinha
	cQuery+= "	 	WHEN CV3_TABORI = 'SD2' THEN SE1C.E1_NUM "+ cPulaLinha
	cQuery+= " END NUMERO "+ cPulaLinha	
	cQuery+= " 	FROM CT2010 CT2 "+ cPulaLinha
	cQuery+= " 		LEFT JOIN CV3010 CV3  ON (CT2.R_E_C_N_O_ = CV3.CV3_RECDES AND CV3.D_E_L_E_T_ = ' ' ) "+ cPulaLinha
	cQuery+= " 		LEFT JOIN SE5010 SE5  ON (SE5.R_E_C_N_O_ = CV3_RECORI) "+ cPulaLinha
	cQuery+= " 		LEFT JOIN SE1010 SE1  ON (SE1.R_E_C_N_O_ = CV3_RECORI) "+ cPulaLinha
	cQuery+= " 		LEFT JOIN SE2010 SE2  ON (SE2.R_E_C_N_O_ = CV3_RECORI) "+ cPulaLinha
	cQuery+= " 		LEFT JOIN SF2010 SF2  ON (SF2.R_E_C_N_O_ = CV3_RECORI AND SF2.D_E_L_E_T_ =  ' ' ) "+ cPulaLinha
	cQuery+= " 		LEFT JOIN SE1010 SE1B ON (SF2.F2_FILIAL  = SE1B.E1_FILIAL AND SE1B.E1_NUM = SF2.F2_DOC AND SE1B.E1_CLIENTE = SF2.F2_CLIENTE AND SE1B.D_E_L_E_T_ = ' ') "+ cPulaLinha
	cQuery+= " 		LEFT JOIN SD1010 SD1  ON (SD1.R_E_C_N_O_ = CV3_RECORI) "+ cPulaLinha
	cQuery+= " 		LEFT JOIN SD2010 SD2  ON (SD2.R_E_C_N_O_ = CV3_RECORI) "+ cPulaLinha
	cQuery+= " 		LEFT JOIN SE2010 SE2B ON (SE2B.E2_FILIAL = SD1.D1_FILIAL AND SD1.D1_DOC = SE2B.E2_NUM AND SE2B.E2_FORNECE = SD1.D1_FORNECE AND SD1.D1_LOJA = SE2B.E2_LOJA AND  SE2B.D_E_L_E_T_ = ' ') "+ cPulaLinha
	cQuery+= " 		LEFT JOIN SE1010 SE1C ON (SE1C.E1_FILIAL = SD2.D2_FILIAL AND SD2.D2_DOC = SE1C.E1_NUM AND SE1C.E1_CLIENTE = SD2.D2_CLIENTE AND SD2.D2_LOJA = SE1C.E1_LOJA AND  SE1C.D_E_L_E_T_ = ' ') "+ cPulaLinha
	cQuery+= " WHERE CT2.D_E_L_E_T_ = ' '  "+ cPulaLinha
	cQuery+= " 	AND CT2_DATA   BETWEEN '"+DTOS(cMovDe)+"' AND '"+DTOS(cMovAte)+"' "+ cPulaLinha
	cQuery+= " 	AND CT2_DEBITO BETWEEN '"+cDebDe+"'  AND '"+cDebAte+"' "+ cPulaLinha
	cQuery+= " 	AND CT2_CREDIT BETWEEN '"+cCredDe+"' AND '"+cCredAte+"' "+ cPulaLinha
	cQuery+= " ORDER BY CT2_FILIAL,CT2_DATA "+ cPulaLinha

	tcquery cQuery new alias "TMPCON"
	MemoWrite("C:\TEMP\CONTAB.sql",cQuery)

	TMPCON->(dbGotop())
	While !TMPCON->(eof())   

		Aadd(_aColsXls,{TMPCON->CT2_FILIAL,; 									   
						STOD(TMPCON->CT2_DATA),;
						cvaltochar(MONTH(STOD(TMPCON->CT2_DATA))),;
						cvaltochar(YEAR(STOD(TMPCON->CT2_DATA))),;										  
						TMPCON->CT2_LOTE,;             						  
						TMPCON->CT2_SBLOTE,;             						     
						TMPCON->CT2_DOC,;              							 
						TMPCON->CT2_LINHA,;      							  
						TMPCON->CT2_DC,;   					 
						TMPCON->DESC_DC,;  			  
						TMPCON->CT2_ITEMC,;           
						TMPCON->CT2_ITEMD,;   
						TMPCON->NOM_FORNEC,;  
						TMPCON->NOM_CLIENTE,;			  
						TMPCON->CT2_DEBITO,;											 
						TMPCON->CT2_CREDIT,;			  
						TMPCON->CT2_VALOR,;												 
						TMPCON->CT2_HIST,;			  
						TMPCON->CT2_CCD,;			  
						TMPCON->CT2_CCC,;			  
						TMPCON->CT2_CLVLDB,;						 
						TMPCON->CT2_CLVLCR,;			  
						TMPCON->CT2_EMPORI,;			  
						TMPCON->CT2_FILORI,;			 
						TMPCON->CV3_TABORI,;			  
						TMPCON->CV3_HIST,;			  
						TMPCON->DESC_CCUSTO,;             
						TMPCON->DESC_CONTA_DEBITO,;             
						TMPCON->DESC_CONTA_CREDITO,;           
						TMPCON->COD_NATUREZA,;
						Posicione('SED',1,xFilial('SED')+TMPCON->COD_NATUREZA,'ED_DESCRIC'),;
						iif( !Empty(TMPCON->EMISSAO) , STOD(TMPCON->EMISSAO) ,''),;
						iif( !Empty(TMPCON->VENCTO)  , STOD(TMPCON->VENCTO)  ,''),;
						TMPCON->NUMERO,;
						})
						
						nContador++

		TMPCON->(dbskip())
	Enddo                                    
	*/

	If(SELECT("TMPCON") > 0)
		TMPCON->(DBCLOSEAREA())
	Endif
		
	cQuery:= " 	SELECT SUBSTRING(CT2_DEBITO,1,2) AS 'Nivel_02', "+ cPulaLinha
	cQuery+= " 	CASE  "+ cPulaLinha
	cQuery+= " 		WHEN CT2_DEBITO <> ' '  THEN (SELECT CT1_DESC01 FROM "+Retsqlname("CT1")+" CT1A WHERE SUBSTRING(CT1A.CT1_FILIAL,1,2)  = SUBSTRING(CT2.CT2_FILIAL,1,2) AND SUBSTRING(CT2.CT2_DEBITO,1,2) = SUBSTRING(CT1A.CT1_CONTA,1,2) AND LEN(CT1A.CT1_CONTA) = 2 AND CT1A.D_E_L_E_T_ = ' ') "+ cPulaLinha
	cQuery+= " 	ELSE ' ' "+ cPulaLinha
	cQuery+= " 	END 'Descnv_02',  "+ cPulaLinha
	cQuery+= " 		SUBSTRING(CT2_DEBITO,1,4) AS 'Nivel_03', "+ cPulaLinha
	cQuery+= " 		CASE  "+ cPulaLinha
	cQuery+= " 			WHEN CT2_DEBITO <> ' '  THEN (SELECT CT1_DESC01 FROM "+Retsqlname("CT1")+" CT1B WHERE SUBSTRING(CT1B.CT1_FILIAL,1,2)  = SUBSTRING(CT2.CT2_FILIAL,1,2) AND SUBSTRING(CT2.CT2_DEBITO,1,4) = SUBSTRING(CT1B.CT1_CONTA,1,4) AND LEN(CT1B.CT1_CONTA) = 4 AND CT1B.D_E_L_E_T_ = ' ') "+ cPulaLinha
	cQuery+= " 		ELSE ' ' "+ cPulaLinha
	cQuery+= " 		END 'Descnv_03', "+ cPulaLinha
	cQuery+= " 		SUBSTRING(CT2_DEBITO,1,6) AS 'Nivel_04', "+ cPulaLinha
	cQuery+= " 		CASE  "+ cPulaLinha
	cQuery+= " 			WHEN CT2_DEBITO <> ' '  THEN (SELECT CT1_DESC01 FROM "+Retsqlname("CT1")+" CT1C WHERE SUBSTRING(CT1C.CT1_FILIAL,1,2)  = SUBSTRING(CT2.CT2_FILIAL,1,2) AND SUBSTRING(CT2.CT2_DEBITO,1,6) = SUBSTRING(CT1C.CT1_CONTA,1,6) AND LEN(CT1C.CT1_CONTA) = 6 AND CT1C.D_E_L_E_T_ = ' ') "+ cPulaLinha
	cQuery+= " 		ELSE ' ' "+ cPulaLinha
	cQuery+= " 		END 'Descnv_04', "+ cPulaLinha	
	cQuery+= " 		CT2.CT2_DATA AS 'Data_Lcto', "+ cPulaLinha
	cQuery+= " 		SUBSTRING(CT2.CT2_DATA,5,2) AS 'MES', "+ cPulaLinha
	cQuery+= " 		SUBSTRING(CT2.CT2_DATA,1,4) AS 'ANO', "+ cPulaLinha
	cQuery+= " 		CT2.CT2_DEBITO    AS 'CONTA', "+ cPulaLinha
	cQuery+= " 		CT1.CT1_DESC01    AS 'CDESCON', "+ cPulaLinha
	cQuery+= " 		CT2.CT2_VALOR *-1 AS 'VALOR', "+ cPulaLinha
	cQuery+= " 		CT2.CT2_HIST      AS 'HIST', "+ cPulaLinha
	cQuery+= " 		CT2.CT2_LP		  AS 'CTLLP', "+ cPulaLinha
	cQuery+= "      CT2.CT2_KEY		  AS 'KEY', " + cPulaLinha	
	cQuery+= " 		CASE WHEN CT2.CT2_CCD <> ' ' THEN CT2.CT2_CCD ELSE CT2.CT2_CCC  END 'CCUSTO', "+ cPulaLinha
	cQuery+= " 		CASE  "+ cPulaLinha
	cQuery+= " 			WHEN CT2_CCD <> ' '  THEN (SELECT CTT_DESC01 FROM "+Retsqlname("CTT")+" CTTA WHERE SUBSTRING(CTT_FILIAL,1,2)  = SUBSTRING(CT2_FILIAL,1,2) AND CT2_CCD = CTTA.CTT_CUSTO AND CTTA.D_E_L_E_T_ = ' ') "+ cPulaLinha
	cQuery+= " 			Else (SELECT CTT_DESC01 FROM "+Retsqlname("CTT")+" CTTB WHERE SUBSTRING(CTT_FILIAL,1,2)  = SUBSTRING(CT2_FILIAL,1,2) AND CT2_CCC = CTTB.CTT_CUSTO AND CTTB.D_E_L_E_T_ = ' ') "+ cPulaLinha
	cQuery+= " 	END 'DESCCC' "+ cPulaLinha
	cQuery+= " 	FROM "+Retsqlname("CT2")+" CT2 "+ cPulaLinha
	cQuery+= " 	INNER JOIN "+Retsqlname("CT1")+" CT1 ON (SUBSTRING(CT1.CT1_FILIAL,1,2)  = SUBSTRING(CT2.CT2_FILIAL,1,2) AND CT2.CT2_DEBITO = CT1.CT1_CONTA AND CT1.D_E_L_E_T_ = ' ') "+ cPulaLinha
	cQuery+= " 	WHERE CT2.D_E_L_E_T_ = ' '  "+ cPulaLinha
	cQuery+= " 	AND CT1_NATCTA = '04'	 "+ cPulaLinha
	cQuery+= " 	AND CT2_DEBITO <> ' ' "+ cPulaLinha
	cQuery+= " 	AND CT2_DATA   BETWEEN '"+DTOS(cMovDe)+"' AND '"+DTOS(cMovAte)+"' "+ cPulaLinha

	cQuery+= " 	UNION ALL "+ cPulaLinha

	cQuery+= " 	SELECT SUBSTRING(CT2_CREDIT,1,2) AS 'Nivel_02', "+ cPulaLinha
	cQuery+= " 		CASE  "+ cPulaLinha
	cQuery+= " 			WHEN CT2_CREDIT <> ' '  THEN (SELECT CT1_DESC01 FROM "+Retsqlname("CT1")+" CT1A WHERE SUBSTRING(CT1A.CT1_FILIAL,1,2)  = SUBSTRING(CT2.CT2_FILIAL,1,2) AND SUBSTRING(CT2.CT2_CREDIT,1,2) = SUBSTRING(CT1A.CT1_CONTA,1,2) AND LEN(CT1A.CT1_CONTA) = 2 AND CT1A.D_E_L_E_T_ = ' ') "+ cPulaLinha
	cQuery+= " 		ELSE ' ' "+ cPulaLinha
	cQuery+= " 	END 'Descnv_02',  "+ cPulaLinha
	cQuery+= " 		SUBSTRING(CT2_CREDIT,1,4) AS 'Nivel_03', "+ cPulaLinha
	cQuery+= " 		CASE  "+ cPulaLinha
	cQuery+= " 			WHEN CT2_CREDIT <> ' '  THEN (SELECT CT1_DESC01 FROM "+Retsqlname("CT1")+" CT1B WHERE SUBSTRING(CT1B.CT1_FILIAL,1,2)  = SUBSTRING(CT2.CT2_FILIAL,1,2) AND SUBSTRING(CT2.CT2_CREDIT,1,4) = SUBSTRING(CT1B.CT1_CONTA,1,4) AND LEN(CT1B.CT1_CONTA) = 4 AND CT1B.D_E_L_E_T_ = ' ') "+ cPulaLinha
	cQuery+= " 		ELSE ' ' "+ cPulaLinha
	cQuery+= " 		END 'Descnv_03', "+ cPulaLinha
	cQuery+= " 		SUBSTRING(CT2_CREDIT,1,6) AS 'Nivel_04', "+ cPulaLinha
	cQuery+= " 		CASE  "+ cPulaLinha
	cQuery+= " 			WHEN CT2_CREDIT <> ' '  THEN (SELECT CT1_DESC01 FROM "+Retsqlname("CT1")+" CT1C WHERE SUBSTRING(CT1C.CT1_FILIAL,1,2)  = SUBSTRING(CT2.CT2_FILIAL,1,2) AND SUBSTRING(CT2.CT2_CREDIT,1,6) = SUBSTRING(CT1C.CT1_CONTA,1,6) AND LEN(CT1C.CT1_CONTA) = 6 AND CT1C.D_E_L_E_T_ = ' ') "+ cPulaLinha
	cQuery+= " 		ELSE ' ' "+ cPulaLinha
	cQuery+= " 		END 'Descnv_04', "+ cPulaLinha	
	cQuery+= " 		CT2.CT2_DATA AS 'Data_Lcto', "+ cPulaLinha
	cQuery+= " 		SUBSTRING(CT2.CT2_DATA,5,2) AS 'MES', "+ cPulaLinha
	cQuery+= " 		SUBSTRING(CT2.CT2_DATA,1,4) AS 'ANO', "+ cPulaLinha
	cQuery+= " 		CT2.CT2_CREDIT    AS 'CONTA', "+ cPulaLinha
	cQuery+= " 		CT1.CT1_DESC01    AS 'CDESCON', "+ cPulaLinha
	cQuery+= " 		CT2.CT2_VALOR     AS 'VALOR', "+ cPulaLinha
	cQuery+= " 		CT2.CT2_HIST      AS 'HIST', "+ cPulaLinha
	cQuery+= " 		CT2.CT2_LP		  AS 'CTLLP', "+ cPulaLinha
	cQuery+= "      CT2.CT2_KEY		  AS 'KEY', " + cPulaLinha
	cQuery+= " 		CASE WHEN CT2.CT2_CCC <> ' ' THEN CT2.CT2_CCC ELSE CT2.CT2_CCD  END 'CCUSTO', "+ cPulaLinha
	cQuery+= " 		CASE  "+ cPulaLinha
	cQuery+= " 			WHEN CT2_CCC <> ' '  THEN (SELECT CTT_DESC01 FROM "+Retsqlname("CTT")+" CTTA WHERE SUBSTRING(CTT_FILIAL,1,2)  = SUBSTRING(CT2_FILIAL,1,2) AND CT2_CCC = CTTA.CTT_CUSTO AND CTTA.D_E_L_E_T_ = ' ') "+ cPulaLinha
	cQuery+= " 			Else (SELECT CTT_DESC01 FROM "+Retsqlname("CTT")+" CTTB WHERE SUBSTRING(CTT_FILIAL,1,2)  = SUBSTRING(CT2_FILIAL,1,2) AND CT2_CCD = CTTB.CTT_CUSTO AND CTTB.D_E_L_E_T_ = ' ') "+ cPulaLinha
	cQuery+= " 		END 'DESCCC' "+ cPulaLinha
	cQuery+= " 		FROM "+Retsqlname("CT2")+" CT2 "+ cPulaLinha
	cQuery+= " 		INNER JOIN "+Retsqlname("CT1")+" CT1 ON (SUBSTRING(CT1.CT1_FILIAL,1,2)  = SUBSTRING(CT2.CT2_FILIAL,1,2) AND CT2.CT2_CREDIT = CT1.CT1_CONTA AND CT1.D_E_L_E_T_ = ' ') "+ cPulaLinha
	cQuery+= " 		LEFT JOIN " +Retsqlname("CTD")+" CTD ON (CTD.CTD_FILIAL = CT2.CT2_FILIAL AND CTD.CTD_ITEM = CT2.CT2_ITEMC AND CTD.D_E_L_E_T_ = ' ') "+ cPulaLinha
	cQuery+= " 		WHERE CT2.D_E_L_E_T_ = ' '  "+ cPulaLinha
	cQuery+= " 		AND CT1_NATCTA = '04'	 "+ cPulaLinha
	cQuery+= " 		AND CT2_CREDIT <> ' ' 	 "+ cPulaLinha
	cQuery+= " 		AND CT2_DATA   BETWEEN '"+DTOS(cMovDe)+"' AND '"+DTOS(cMovAte)+"' "+ cPulaLinha

	tcquery cQuery new alias "TMPCON"
	MemoWrite("C:\TEMP\CONTAB.sql",cQuery)

	TMPCON->(dbGotop())
	While !TMPCON->(eof())   

		cCLIFOR := ""
		CTL->(DbSetOrder(1))
		if CTL->(DbSeek(xFilial("CTL")+TMPCON->CTLLP))
			cAlias 	:= alltrim(CTL->CTL_ALIAS)
			nOrder	:= val(alltrim(CTL->CTL_ORDER))
			cKey	:= alltrim(TMPCON->KEY)

			(cAlias)->(dbSetorder(nOrder))
			if (cAlias)->(DbSeek(cKey))
				if cAlias = 'SE5'
					cNomCliFor := Posicione("SA2",1,XFILIAL("SA2")+SE5->(E5_CLIFOR+E5_LOJA),"A2_NOME")
					if empty(alltrim(cNomCliFor))
						cNomCliFor := Posicione("SA1",1,XFILIAL("SA1")+SE5->(E5_CLIFOR+E5_LOJA),"A1_NOME")
					Endif

					cCLIFOR := SE5->E5_CLIFOR+"-"+SE5->E5_LOJA+"/"+cNomCliFor

				elseif cAlias = 'SE1'
						cNomCliFor := Posicione("SA1",1,XFILIAL("SA1")+SE1->(E1_CLIENTE+E1_LOJA),"A1_NOME")
						cCLIFOR := SE1->E1_CLIENTE+"-"+SE1->E1_LOJA+"/"+cNomCliFor

				elseif cAlias = 'SE2'
						cNomCliFor := Posicione("SA2",1,XFILIAL("SA2")+SE2->(E2_FORNECE+E2_LOJA),"A2_NOME")
						cCLIFOR := SE2->E2_FORNECE+"-"+SE2->E2_LOJA+"/"+cNomCliFor

				elseif cAlias = 'SD1'
						cNomCliFor := Posicione("SA2",1,XFILIAL("SA2")+SD1->(D1_FORNECE+D1_LOJA),"A2_NOME")
						cCLIFOR := SD1->D1_FORNECE+"-"+SD1->D1_LOJA+"/"+cNomCliFor

				elseif cAlias = 'SD2'
						cNomCliFor := Posicione("SA1",1,XFILIAL("SA1")+SD2->(D2_CLIENTE+D2_LOJA),"A1_NOME")
						cCLIFOR := SD2->D2_CLIENTE+"-"+SD2->D2_LOJA+"/"+cNomCliFor

				elseif cAlias = 'SF1'
						cNomCliFor := Posicione("SA2",1,XFILIAL("SA2")+SF1->(F1_CLIENTE+F1_LOJA),"A2_NOME")
						cCLIFOR := SF1->F1_CLIENTE+"-"+SF1->F1_LOJA+"/"+cNomCliFor

				elseif cAlias = 'SF2'
						cNomCliFor := Posicione("SA1",1,XFILIAL("SA1")+SF2->(F2_CLIENTE+F2_LOJA),"A1_NOME")
						cCLIFOR := SF2->F2_CLIENTE+"-"+SF2->F2_LOJA+"/"+cNomCliFor
				else
					cCLIFOR := ""
				Endif
			Endif
		Endif

		Aadd(_aColsXls,{'DRE (Demonstração De Resultado)',; 	
						TMPCON->Nivel_02,;
						TMPCON->Descnv_02,;
						TMPCON->Nivel_03,;
						TMPCON->Descnv_03,;
						TMPCON->Nivel_04,;
						TMPCON->Descnv_04,;
						STOD(TMPCON->Data_Lcto),;
						cValtoChar(TMPCON->MES),;
						cValtoChar(TMPCON->ANO),;
						PADL(cValtoChar( month(STOD(TMPCON->Data_Lcto)) ),02,'0') + '_' + MesExtenso( month(STOD(TMPCON->Data_Lcto)) )+ '_' + cValtoChar( Year(STOD(TMPCON->Data_Lcto)) ),;
						TMPCON->CONTA,;	
						TMPCON->CDESCON,;		
						TMPCON->VALOR,;		
						TMPCON->HIST,;	
						cCLIFOR,;	
						TMPCON->CCUSTO,;		
						TMPCON->DESCCC})
						
//						STOD(TMPCON->CT2_DATA),;
//						cvaltochar(MONTH(STOD(TMPCON->CT2_DATA))),;
//						cvaltochar(YEAR(STOD(TMPCON->CT2_DATA))),;										  
						
						nContador++

		TMPCON->(dbskip())
	Enddo                                    
	
	_aHeadXls := {  "Nivel 01",;
					"Nivel 02",;
					"Desc. Nivel 02",;
					"Nivel 03",;										
					"Desc. Nivel 03",;
					"Nivel 04",;										
					"Desc. Nivel 04",;					
					"Data Lcto",;
					"Mes",;
					"Ano",;
					"Mes Geral",;
					"Cta Contabil",;
					"Desc. Cta",;
					"Valor",;
					"Hist Lanc",;
					"Forn_Cliente",;
					"C Custo",;
					"Desc. C Custo"}
					
	if nContador > 1
		SPCPR06Excel(_aHeadXls,_aColsXls,"Exportando Relatorio Movimentos Contabeis para Excel ") //Exporta para Excel
		
		MsgAlert("Arquivo Excel Imprimido com Sucesso! Verifique !!! ")
	Else
		Alert("Não a Registros para Imprimir")
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

