#INCLUDE "PROTHEUS.CH" 
#INCLUDE "RWMAKE.CH"
/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SPDPIS07     ¦ Autor ¦ Claudio Ferreira  ¦ Data ¦ 21/12/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Ponto de entrada                                           ¦¦¦
¦¦¦          ¦ Definir a conta Receita blocos EFD Contribuições           ¦¦¦
¦¦¦          ¦                                                            ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ TOTVS-GO								                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function SPDPIS07()
Local	cFilial		:=	PARAMIXB[1]	//FT_FILIAL
Local	cTpMov		:=	PARAMIXB[2]	//FT_TIPOMOV
Local	cSerie		:=	PARAMIXB[3]	//FT_SERIE
Local	cDoc		:=	PARAMIXB[4]	//FT_NFISCAL
Local	cClieFor	:=	PARAMIXB[5]	//FT_CLIEFOR
Local	cLoja		:=	PARAMIXB[6]	//FT_LOJA
Local	cItem		:=	PARAMIXB[7]	//FT_ITEM
Local	cProd		:=	PARAMIXB[8]	//FT_PRODUTO	 	
Local	cConta		:=	"" 
Local 	aArea  	:= GetArea()
SFT->(DbSetOrder(1))
SFT->(dbSeek(xFilial("SFT")+cTpMov+cSerie+cDoc+cClieFor+cLoja+cItem+cProd))
cConta		:= SFT->FT_CONTA

If cTpMov=='S'
	//posicionando no cliente
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+cClieFor+cLoja))
	//posicionando no produto
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+cProd))
    cConta	:=	U_RetCta(IF(SA1->A1_EST<>'EX','122','123'),U_RetGrpCtb())
    If 'VZA'$Upper(cConta)
    	cConta	:= SFT->FT_CONTA
    Endif
Endif				
RestArea(aArea) 

Return cConta

