#INCLUDE "MDTPGONL.ch"
#Include "PanelOnLine.ch"

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁFun┤┘o    ЁMDTPGONL  Ё Autor Ё Ricardo Dal Ponte     Ё Data Ё 26/03/2007 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤┘o ЁPainel de Gestao.                                             Ё╠╠
╠╠Ё          ЁChama Painel de Gestao na entrada do sistema (SIGAMDI).    	Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   ЁMDTPGONL(oPGOnline)                                           Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       ЁGenerico                                                      Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function MDTPGONL(oPGOnline)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁAcidentes por Centro de Custo                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0001; //"Acidentes por Centro de Custo"
	DESCR STR0001; //"Acidentes por Centro de Custo"
	TYPE 5 ; 
	PARAMETERS "MDTP010" ;
	ONLOAD "MDTP010" ;
	REFRESH 300 ;
	NAME "1"    

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁAcidentes por Parte Atingida                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0002; //"Acidentes por Parte Atingida"
	DESCR STR0002; //"Acidentes por Parte Atingida"
	TYPE 5 ; 
	PARAMETERS "MDTP020" ;
	ONLOAD "MDTP020" ;
	REFRESH 300 ;
	NAME "2"    

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁDias sem Acidentes                                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0003; //"Dias sem Acidentes"
	DESCR STR0003; //"Dias sem Acidentes"
	TYPE 1 ; 
	PARAMETERS "MDTP030" ;
	ONLOAD "MDTP030" ;
	REFRESH 300 ;
	NAME "3"    
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁIndice de Anormalidade no Resultado dos Exames                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0004; //"мndice de Anormalidade no Resultado dos Exames"
	DESCR STR0004; //"мndice de Anormalidade no Resultado dos Exames"
	TYPE 3 ; 
	PARAMETERS "MDTP040" ;
	ONLOAD "MDTP040" ;
	REFRESH 300 ;
	NAME "4"    
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁOcorrencias de Doencas Ocupacionais                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0005; //"OcorrЙncias de DoenГas Ocupacionais"
	DESCR STR0005; //"OcorrЙncias de DoenГas Ocupacionais"
	TYPE 5 ; 
	PARAMETERS "MDTP050" ;
	ONLOAD "MDTP050" ;
	REFRESH 300 ;
	NAME "5"    
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁAsos's Emitidos (Aptos/Inaptos)                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0006; //"Asos's Emitidos"
	DESCR STR0006; //"Asos's Emitidos"
	TYPE 1 ; 
	PARAMETERS "MDTP060" ;
	ONLOAD "MDTP060" ;
	REFRESH 300 ;
	NAME "6"    
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁPlanos de Acao da CIPA (Abertas/Fechadas)                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0007; //"Planos de AГЦo da CIPA"
	DESCR STR0007; //"Planos de AГЦo da CIPA"
	TYPE 1 ; 
	PARAMETERS "MDTP070" ;
	ONLOAD "MDTP070" ;
	REFRESH 300 ;
	NAME "7"    
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁDias Perdidos em Acidentes de Trabalho                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0008; //"Dias Perdidos em Acidentes de Trabalho"
	DESCR STR0008; //"Dias Perdidos em Acidentes de Trabalho"
	TYPE 1 ; 
	PARAMETERS "MDTP080" ;
	ONLOAD "MDTP080" ;
	REFRESH 300 ;
	NAME "8"    

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁDespesas com Acidentes de Trabalho                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0009; //"Despesas com Acidentes de Trabalho"
	DESCR STR0009; //"Despesas com Acidentes de Trabalho"
	TYPE 1 ; 
	PARAMETERS "MDTP090" ;
	ONLOAD "MDTP090" ;
	REFRESH 300 ;
	NAME "9"    
Return .T.