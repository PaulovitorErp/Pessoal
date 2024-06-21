#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#Include "PROTHEUS.CH"




/*=================================================Conferencia Inss=====================================================*/
/*@autor:Andre Castilho=================================================================================================*/

User Function RGPER004()

	Private cStartPath
	Private cDirDocs  	:= MsDocPath()
	Private cArquivo 	:= CriaTrab(,.F.)
	Private cPath		:= AllTrim(GetTempPath())
	Private cQuery 		:= ""
	Private cperg       :="RGPER004"

//	u_xParamBox() //Cria Perguntas

	If Pergunte(cperg,.T.,"")
		processa({|| ExpRel()},"Gerando Relatorio Conferencia Folha : ")
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

If MV_PAR06 = 2
		 
	cQuery+= " SELECT  RA_FILIAL, "
	cQuery+= " RA_MAT AS MATRICULA, "
	cQuery+= " RA_NOME AS NOME, "
	cQuery+= " RA_CC AS CCUSTO, "
	cQuery+= " RA_CIC AS CIC, "
	cQuery+= " RA_SALARIO AS SALARIO, "
	cQuery+= " CTT_DESC01 AS DESCC, "
	cQuery+= " RA_CATFUNC AS CATEGORIA, "
	cQuery+= " RA_ADMISSA  AS ADMISSAO, "
	cQuery+= " RA_DEMISSA AS DEMISSAO, "
	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '020' THEN SRD.RD_VALOR ELSE 0 END) V_SALARIO, "
	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '029' THEN SRD.RD_VALOR ELSE 0 END) V_DSR_HE, "
	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '039' THEN SRD.RD_VALOR ELSE 0 END) V_PREMIO, "
	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '073' THEN SRD.RD_VALOR ELSE 0 END) V_PERICULOSIDADE, "
	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '098' THEN SRD.RD_VALOR ELSE 0 END) V_PERICULOSIDADE_FERIAS, "
	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '111' THEN SRD.RD_VALOR ELSE 0 END) V_HORAS_EXTRAS_50, "
	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '125' THEN SRD.RD_VALOR ELSE 0 END) V_PERICULOSIDADE_ABONO, "
	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '565' THEN SRD.RD_VALOR ELSE 0 END) V_ASSIS_MEDICA, "
	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '401' THEN SRD.RD_VALOR ELSE 0 END) V_INSS, "
	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '563' THEN SRD.RD_VALOR ELSE 0 END) V_DESC_VALE_ALIMENT, "
	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '702' THEN SRD.RD_VALOR ELSE 0 END) V_BASE_INSS_ACIMA_LIMI, "
	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '725' THEN SRD.RD_VALOR ELSE 0 END) V_BASE_IR_SALARIO, "
	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '745' THEN SRD.RD_VALOR ELSE 0 END) V_BASE_FGTS, "
	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '755' THEN SRD.RD_VALOR ELSE 0 END) V_FGTS, "
	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '815' THEN SRD.RD_VALOR ELSE 0 END) V_INSS_EMPRESA, "
	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '816' THEN SRD.RD_VALOR ELSE 0 END) V_TERCEIROS, "
	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '817' THEN SRD.RD_VALOR ELSE 0 END) V_ACID_TRABALHO, "
//	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '930' THEN SRD.RD_VALOR ELSE 0 END) V_DED_INSS_SALARIO, "
//	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '401' THEN SRD.RD_VALOR ELSE 0 END) V_DESCONTO_INSS, " 
//	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '403' THEN SRD.RD_VALOR ELSE 0 END) V_INSS_13_SALARIO, "
	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '990' THEN SRD.RD_VALOR ELSE 0 END) V_SALARIO_MES, "
	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '999' THEN SRD.RD_VALOR ELSE 0 END) V_LIQUIDO_A_RECEBER, "
	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '402' THEN SRD.RD_VALOR ELSE 0 END) V_INSS_FERIAS, "
	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '130' THEN SRD.RD_VALOR ELSE 0 END) V_FERIAS, "
	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '131' THEN SRD.RD_VALOR ELSE 0 END) V_UM_TERCO_FERIAS, "
	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '132' THEN SRD.RD_VALOR ELSE 0 END) V_ABONO_PECUNIARIO, "
	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '133' THEN SRD.RD_VALOR ELSE 0 END) V_UM_TERCO_ABONO_PECUNIARIO, "
	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '134' THEN SRD.RD_VALOR ELSE 0 END) V_MEDIA_FERIAS_VALOR, "
	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '293' THEN SRD.RD_VALOR ELSE 0 END) V_MEDIA_VALOR_S_ABONO, "
	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '420' THEN SRD.RD_VALOR ELSE 0 END) V_IRRF, "
	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '422' THEN SRD.RD_VALOR ELSE 0 END) V_IRFERIAS, "
	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '450' THEN SRD.RD_VALOR ELSE 0 END) V_DES_ADIANTAMENTO, "
	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '470' THEN SRD.RD_VALOR ELSE 0 END) V_LIQUI_PG_FERIAS, "
	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '566' THEN SRD.RD_VALOR ELSE 0 END) V_ASSIS_ODONT, "
	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '568' THEN SRD.RD_VALOR ELSE 0 END) V_ASSIS_ODONT_DEPEN_AGREG, "
	cQuery+= " SUM(CASE WHEN SRD.RD_PD  = '519' THEN SRD.RD_VALOR ELSE 0 END) V_DESC_COMBUSTIVEL "


	cQuery+= " FROM SRA010 AS SRA, "
	cQuery+= " SRD010 AS SRD,"
	cQuery+= " CTT010 AS CTT "
	cQuery+= " WITH (NOLOCK) "

	cQuery+= " WHERE  SRD.RD_MAT    = SRA.RA_MAT "
	cQuery+= " AND SRA.RA_CC        = CTT.CTT_CUSTO "
	cQuery+= " AND SRD.RD_PERIODO   = '"+MV_PAR01+"' "
	cQuery+= " AND RA_MAT  BETWEEN '"+MV_PAR02+"' AND  '"+MV_PAR03+"' " 
	cQuery+= " AND RA_CC  BETWEEN '"+MV_PAR04+"' AND  '"+MV_PAR05+"' " 
	cQuery+= " AND SRD.D_E_L_E_T_   = ' ' "
	cQuery+= " AND SRA.D_E_L_E_T_   = ' ' "

	cQuery+= " GROUP BY RA_FILIAL, "
	cQuery+= " RA_MAT, "
	cQuery+= " RA_NOME, "
	cQuery+= " RA_CC, "
	cQuery+= " RA_CIC, "
	cQuery+= " RA_SALARIO, "
	cQuery+= " RA_CATFUNC, "
	cQuery+= " CTT_DESC01, "
	cQuery+= " RA_ADMISSA, "
	cQuery+= " RA_DEMISSA "

	tcQuery cQuery new alias "QRYSRA"

	aHeadXls := {"MATRICULA","NOME","CCUSTO","CIC","SALARIO","DESCC","CATEGORIA","ADMISSAO","DEMISSAO","V_SALARIO","V_DSR_HE","V_PREMIO ","V_PERICULOSIDADE","V_PERICULOSIDADE_FERIAS","V_HORAS_EXTRAS_50",;
		"V_PERICULOSIDADE_ABONO","V_ASSIS_MEDICA","V_INSS","V_DESC_VALE_ALIMENT","V_BASE_INSS_ACIMA_LIMI","V_BASE_IR_SALARIO",;
		"V_BASE_FGTS","V_FGTS","V_INSS_EMPRESA","V_TERCEIROS","V_ACID_TRABALHO","V_DED_INSS_SALARIO","V_SALARIO_MES","V_LIQUIDO_A_RECEBER","V_INSS_FERIAS",;
		"V_FERIAS","V_UM_TERCO_FERIAS","V_ABONO_PECUNIARIO","V_MEDIA_FERIAS_VALOR","V_MEDIA_VALOR_S_ABONO","V_IRRF","V_IRFERIAS","V_DES_ADIANTAMENTO","V_LIQUI_PG_FERIAS",;
		"V_ASSIS_ODONT","V_ASSIS_ODONT_DEPEN_AGREG","V_DESC_COMBUSTIVEL"}
	QRYSRA->(DBGOTOP())
	While !QRYSRA->(eof())

		aAdd(aColsXls,{QRYSRA->MATRICULA,QRYSRA->NOME,QRYSRA->CCUSTO,QRYSRA->CIC,QRYSRA->SALARIO,QRYSRA->DESCC,QRYSRA->CATEGORIA,QRYSRA->ADMISSAO,QRYSRA->DEMISSAO,;
			QRYSRA->V_SALARIO,QRYSRA->V_DSR_HE,QRYSRA->V_PREMIO,QRYSRA->V_PERICULOSIDADE,QRYSRA->V_PERICULOSIDADE_FERIAS,QRYSRA->V_HORAS_EXTRAS_50,;
			QRYSRA->V_PERICULOSIDADE_ABONO,QRYSRA->V_ASSIS_MEDICA,QRYSRA->V_INSS,QRYSRA->V_DESC_VALE_ALIMENT,QRYSRA->V_BASE_INSS_ACIMA_LIMI,QRYSRA->V_BASE_IR_SALARIO,;
			QRYSRA->V_BASE_FGTS,QRYSRA->V_FGTS,QRYSRA->V_INSS_EMPRESA,QRYSRA->V_TERCEIROS,QRYSRA->V_ACID_TRABALHO,QRYSRA->V_DED_INSS_SALARIO,QRYSRA->V_SALARIO_MES,QRYSRA->V_LIQUIDO_A_RECEBER,;
			QRYSRA->V_INSS_FERIAS,QRYSRA->V_FERIAS,QRYSRA->V_UM_TERCO_FERIAS,QRYSRA->V_ABONO_PECUNIARIO,QRYSRA->V_MEDIA_FERIAS_VALOR,QRYSRA->V_MEDIA_VALOR_S_ABONO,QRYSRA->V_IRRF,QRYSRA->V_IRFERIAS,;
			QRYSRA->V_DES_ADIANTAMENTO,QRYSRA->V_LIQUI_PG_FERIAS,QRYSRA->V_ASSIS_ODONT,QRYSRA->V_ASSIS_ODONT_DEPEN_AGREG,QRYSRA->V_DESC_COMBUSTIVEL})

		QRYSRA->(dbskip())
	ENDDO
	if len(aColsXls) > 0
		SPCPR06Excel(aHeadXls,aColsXls,"Relatorio Conferencia Folha ") //Exporta para Excel
		MsgAlert("Relatorio  Gerado com Sucesso!")
	Else
		Alert("Sem Registros")
	EndIf


Else
	
	cQuery+= " SELECT  RA_FILIAL, "
	cQuery+= " RA_MAT AS MATRICULA, "
	cQuery+= " RA_NOME AS NOME, "
	cQuery+= " RA_CC AS CCUSTO, "
	cQuery+= " RA_CIC AS CIC, "
	cQuery+= " RA_SALARIO AS SALARIO, "
	cQuery+= " CTT_DESC01 AS DESCC, "
	cQuery+= " RA_CATFUNC AS CATEGORIA, "
	cQuery+= " RA_ADMISSA  AS ADMISSAO, "
	cQuery+= " RA_DEMISSA AS DEMISSAO, "
    cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '020' THEN SRC.RC_VALOR ELSE 0 END) V_SALARIO, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '290' THEN SRC.RC_VALOR ELSE 0 END) V_13_1PARC_SALARIO, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '180' THEN SRC.RC_VALOR ELSE 0 END) V_LIQ_1PARC_, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '746' THEN SRC.RC_VALOR ELSE 0 END) V_BASE_FGTS13_SAL, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '756' THEN SRC.RC_VALOR ELSE 0 END) V_FGTS_13_SALARIO, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '029' THEN SRC.RC_VALOR ELSE 0 END) V_DSR_HE, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '039' THEN SRC.RC_VALOR ELSE 0 END) V_PREMIO, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '073' THEN SRC.RC_VALOR ELSE 0 END) V_PERICULOSIDADE, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '098' THEN SRC.RC_VALOR ELSE 0 END) V_PERICULOSIDADE_FERIAS, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '111' THEN SRC.RC_VALOR ELSE 0 END) V_HORAS_EXTRAS_50, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '125' THEN SRC.RC_VALOR ELSE 0 END) V_PERICULOSIDADE_ABONO, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '565' THEN SRC.RC_VALOR ELSE 0 END) V_ASSIS_MEDICA, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '401' THEN SRC.RC_VALOR ELSE 0 END) V_INSS, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '563' THEN SRC.RC_VALOR ELSE 0 END) V_DESC_VALE_ALIMENT, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '702' THEN SRC.RC_VALOR ELSE 0 END) V_BASE_INSS_ACIMA_LIMI, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '725' THEN SRC.RC_VALOR ELSE 0 END) V_BASE_IR_SALARIO, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '745' THEN SRC.RC_VALOR ELSE 0 END) V_BASE_FGTS, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '755' THEN SRC.RC_VALOR ELSE 0 END) V_FGTS, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '815' THEN SRC.RC_VALOR ELSE 0 END) V_INSS_EMPRESA, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '816' THEN SRC.RC_VALOR ELSE 0 END) V_TERCEIROS, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '817' THEN SRC.RC_VALOR ELSE 0 END) V_ACID_TRABALHO, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '930' THEN SRC.RC_VALOR ELSE 0 END) V_DED_INSS_SALARIO, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '990' THEN SRC.RC_VALOR ELSE 0 END) V_SALARIO_MES, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '999' THEN SRC.RC_VALOR ELSE 0 END) V_LIQUIDO_A_RECEBER, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '402' THEN SRC.RC_VALOR ELSE 0 END) V_INSS_FERIAS, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '130' THEN SRC.RC_VALOR ELSE 0 END) V_FERIAS, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '131' THEN SRC.RC_VALOR ELSE 0 END) V_UM_TERCO_FERIAS, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '132' THEN SRC.RC_VALOR ELSE 0 END) V_ABONO_PECUNIARIO, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '133' THEN SRC.RC_VALOR ELSE 0 END) V_UM_TERCO_ABONO_PECUNIARIO, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '134' THEN SRC.RC_VALOR ELSE 0 END) V_MEDIA_FERIAS_VALOR, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '293' THEN SRC.RC_VALOR ELSE 0 END) V_MEDIA_VALOR_S_ABONO, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '420' THEN SRC.RC_VALOR ELSE 0 END) V_IRRF, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '422' THEN SRC.RC_VALOR ELSE 0 END) V_IRFERIAS, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '450' THEN SRC.RC_VALOR ELSE 0 END) V_DES_ADIANTAMENTO, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '470' THEN SRC.RC_VALOR ELSE 0 END) V_LIQUI_PG_FERIAS, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '566' THEN SRC.RC_VALOR ELSE 0 END) V_ASSIS_ODONT, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '568' THEN SRC.RC_VALOR ELSE 0 END) V_ASSIS_ODONT_DEPEN_AGREG, "
	cQuery+= " SUM(CASE WHEN SRC.RC_PD  = '519' THEN SRC.RC_VALOR ELSE 0 END) V_DESC_COMBUSTIVEL "


	cQuery+= " FROM SRA010 AS SRA, "
	cQuery+= " SRC010 AS SRC,"
	cQuery+= " CTT010 AS CTT "
	cQuery+= " WITH (NOLOCK) "

	cQuery+= " WHERE  SRC.RC_MAT    = SRA.RA_MAT "
	cQuery+= " AND SRA.RA_CC        = CTT.CTT_CUSTO "
	cQuery+= " AND SRC.RC_PERIODO   = '"+MV_PAR01+"' "
	cQuery+= " AND RA_MAT  BETWEEN '"+MV_PAR02+"' AND  '"+MV_PAR03+"' " 
	cQuery+= " AND RA_CC  BETWEEN '"+MV_PAR04+"' AND  '"+MV_PAR05+"' " 
	cQuery+= " AND SRC.D_E_L_E_T_   = ' ' "
	cQuery+= " AND SRA.D_E_L_E_T_   = ' ' "

	cQuery+= " GROUP BY RA_FILIAL, "
	cQuery+= " RA_MAT, "
	cQuery+= " RA_NOME, "
	cQuery+= " RA_CC, "
	cQuery+= " RA_CIC, "
	cQuery+= " RA_SALARIO, "
	cQuery+= " RA_CATFUNC, "
	cQuery+= " CTT_DESC01, "
	cQuery+= " RA_ADMISSA, "
	cQuery+= " RA_DEMISSA "

	tcQuery cQuery new alias "QRYSRA"

	aHeadXls := {"V_13_1PARC_SALARIO","V_LIQ_1PARC_","V_BASE_FGTS13_SAL","V_FGTS_13_SALARIO","MATRICULA","NOME","CCUSTO","CIC",;
	    "SALARIO","DESCC","CATEGORIA","ADMISSAO","DEMISSAO","V_SALARIO","V_DSR_HE","V_PREMIO ","V_PERICULOSIDADE","V_PERICULOSIDADE_FERIAS","V_HORAS_EXTRAS_50",;
		"V_PERICULOSIDADE_ABONO","V_ASSIS_MEDICA","V_INSS","V_DESC_VALE_ALIMENT","V_BASE_INSS_ACIMA_LIMI","V_BASE_IR_SALARIO",;
		"V_BASE_FGTS","V_FGTS","V_INSS_EMPRESA","V_TERCEIROS","V_ACID_TRABALHO","V_DED_INSS_SALARIO","V_SALARIO_MES","V_LIQUIDO_A_RECEBER","V_INSS_FERIAS",;
		"V_FERIAS","V_UM_TERCO_FERIAS","V_ABONO_PECUNIARIO","V_MEDIA_FERIAS_VALOR","V_MEDIA_VALOR_S_ABONO","V_IRRF","V_IRFERIAS","V_DES_ADIANTAMENTO","V_LIQUI_PG_FERIAS",;
		"V_ASSIS_ODONT","V_ASSIS_ODONT_DEPEN_AGREG","V_DESC_COMBUSTIVEL"}
	QRYSRA->(DBGOTOP())
	While !QRYSRA->(eof())

		aAdd(aColsXls,{QRYSRA->V_13_1PARC_SALARIO,QRYSRA->V_LIQ_1PARC_,QRYSRA->V_BASE_FGTS13_SAL,QRYSRA->V_FGTS_13_SALARIO,QRYSRA->MATRICULA,;
			QRYSRA->NOME,QRYSRA->CCUSTO,QRYSRA->CIC,QRYSRA->SALARIO,QRYSRA->DESCC,QRYSRA->CATEGORIA,QRYSRA->ADMISSAO,QRYSRA->DEMISSAO,;
			QRYSRA->V_SALARIO,QRYSRA->V_DSR_HE,QRYSRA->V_PREMIO,QRYSRA->V_PERICULOSIDADE,QRYSRA->V_PERICULOSIDADE_FERIAS,QRYSRA->V_HORAS_EXTRAS_50,;
			QRYSRA->V_PERICULOSIDADE_ABONO,QRYSRA->V_ASSIS_MEDICA,QRYSRA->V_INSS,QRYSRA->V_DESC_VALE_ALIMENT,QRYSRA->V_BASE_INSS_ACIMA_LIMI,QRYSRA->V_BASE_IR_SALARIO,;
			QRYSRA->V_BASE_FGTS,QRYSRA->V_FGTS,QRYSRA->V_INSS_EMPRESA,QRYSRA->V_TERCEIROS,QRYSRA->V_ACID_TRABALHO,QRYSRA->V_DED_INSS_SALARIO,QRYSRA->V_SALARIO_MES,QRYSRA->V_LIQUIDO_A_RECEBER,;
			QRYSRA->V_INSS_FERIAS,QRYSRA->V_FERIAS,QRYSRA->V_UM_TERCO_FERIAS,QRYSRA->V_ABONO_PECUNIARIO,QRYSRA->V_MEDIA_FERIAS_VALOR,QRYSRA->V_MEDIA_VALOR_S_ABONO,QRYSRA->V_IRRF,QRYSRA->V_IRFERIAS,;
			QRYSRA->V_DES_ADIANTAMENTO,QRYSRA->V_LIQUI_PG_FERIAS,QRYSRA->V_ASSIS_ODONT,QRYSRA->V_ASSIS_ODONT_DEPEN_AGREG,QRYSRA->V_DESC_COMBUSTIVEL})

		QRYSRA->(dbskip())
	ENDDO
	if len(aColsXls) > 0
		SPCPR06Excel(aHeadXls,aColsXls,"Relatorio Conferencia Folha ") //Exporta para Excel
		MsgAlert("Relatorio  Gerado com Sucesso!")
	Else
		Alert("Sem Registros")
	EndIf

Endif
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
User Function xParamBox()

	Local aPergs   := {}
	Local dDataDe  := FirstDate(Date())
	Local cCustDe  := Space(TamSX3('CTT_CC')[01])
	Local cCustAt  := Space(TamSX3('CTT_CC')[01])

//aAdd(aPergs, {1, "Periodo",     dDataDe,  "", ".T.", "", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Centro Custo De",  cCustDe,  "", ".T.", "CTT", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Centro de Custo Até", cCustAt,  "", ".T.", "CTT", ".T.", 80,  .T.})


	If ParamBox(aPergs, "Informe os parâmetros")
		Alert(MV_PAR01)
		Alert(MV_PAR02)
	//	Alert(MV_PAR03)
		
	EndIf

*/

Static Function AjustaSX1()

Private cPerg  := Padr("RGPER004",10)
Private _agrpsx1 := {}

	 AjustaSX1()
	     pergunte(cPerg,.T.)	

	aadd(_agrpsx1,{cPerg,"01","Periodo?       		        ","mv_ch1" ,"C",06,0,0,"G",space(60),"mv_par01"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),("SA1")})
	aadd(_agrpsx1,{cPerg,"02","Matricula De?        		","mv_ch2" ,"C",06,0,0,"G",space(60),"mv_par02"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),("SA1")})
	aadd(_agrpsx1,{cPerg,"03","Matricula Ate?        		","mv_ch3" ,"C",06,0,0,"G",space(60),"mv_par03"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),("SA1")})
	aadd(_agrpsx1,{cPerg,"04","Centro de Custo De?        	","mv_ch4" ,"C",08,0,0,"G",space(60),"mv_par04"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),     })
	aadd(_agrpsx1,{cPerg,"05","Centro de Custo Ate?         ","mv_ch5" ,"C",08,0,0,"G",space(60),"mv_par05"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),     })
	aadd(_agrpsx1,{cPerg,"06","Periodo Aberto     ?         ","mv_ch6" ,"C",01,0,0,"G",space(60),"mv_par06"       ,space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),space(15),space(15)        ,space(30),     })

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





