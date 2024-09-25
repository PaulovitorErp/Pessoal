#include "Protheus.Ch"
#Include "PanelOnLine.ch"

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    Ё SGAPGONL Ё Autor Ё Rafael Diogo Richter  Ё Data Ё05/03/2007Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o ЁDefinicao dos Paineis de Gestao On-Line do modulo de Gestao Ё╠╠
╠╠Ё          ЁAmbiental.                                                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe	 Ё SGAPGONL  										   	  			     Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё SigaSGA                                                    Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.             Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё F.O  Ё  Motivo da Alteracao                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            Ё        Ё      Ё                                          Ё╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function SGAPGONL(oPGOnline)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁOcorrencias por Plano Emergencial                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PANELONLINE oPGOnline ADDPANEL ;
	TITLE "OcorrЙncias por Plano Emergencial" ;
	DESCR "OcorrЙncias por Plano Emergencial" ;
	TYPE 5 ;
	ONLOAD "SGAP010" ;
	REFRESH 300 ;
	NAME "1"

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁMetas Alcancadas por Objetivos                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PANELONLINE oPGOnline ADDPANEL ;
	TITLE "Metas alcanГadas por Objetivos" ;
	DESCR "Metas alcanГadas por Objetivos" ;
	TYPE 5 ;
	ONLOAD "SGAP020" ;
	REFRESH 300 ;
	NAME "2"

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁPercentual de Metas Alcancadas                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PANELONLINE oPGOnline ADDPANEL ;
	TITLE "Percentual de Metas AlcanГadas" ;
	DESCR "Percentual de Metas AlcanГadas" ;
	TYPE 3 ;
	ONLOAD "SGAP030" ;
	REFRESH 300 ;
	NAME "3"

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁSituacao Demandas                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PANELONLINE oPGOnline ADDPANEL ;
	TITLE "SituaГЦo Demandas" ;
	DESCR "SituaГЦo Demandas" ;
	TYPE 1 ;
	ONLOAD "SGAP040" ;
	REFRESH 300 ;
	NAME "4"
	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁDocumentos a serem revisados                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PANELONLINE oPGOnline ADDPANEL ;
	TITLE "Qtde de Documentos Ю serem lidos" ;
	DESCR "Qtde de Documentos Ю serem lidos" ;
	TYPE 5 ;
	ONLOAD "SGAP050" ;
	REFRESH 300 ;
	NAME "5"

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁDias sem ocorrencias do P.E.                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PANELONLINE oPGOnline ADDPANEL ;
	TITLE "Dias sem ocorrЙncias do P.E." ;
	DESCR "Dias sem ocorrЙncias do P.E." ;
	TYPE 1 ;
	ONLOAD "SGAP060" ;
	REFRESH 300 ;
	NAME "6"

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁPlanos de Acao Pendentes                                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PANELONLINE oPGOnline ADDPANEL ;
	TITLE "Planos de AГЦo Pendentes" ;
	DESCR "Planos de AГЦo Pendentes" ;
	TYPE 2 ;
	ONLOAD "SGAP070" ;
	REFRESH 300 ;
	DEFAULT 2;
	NAME "7"


Return