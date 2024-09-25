#INCLUDE "PROTHEUS.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTV042
Responsável por realizar o calculo da variável HCAL - Número de horas de um
período considerado (horas de calendário dos itens)

@param De_Data      , Date     , Data início
@param Ate_Data     , Date     , Ate data
@param De_Bem       , Caracter , De bem início
@param [Ate_Bem]    , Caracter , Ate bem fim
@param De_Ccusto    , Caracter , De centro de custo
@param [Ate_Ccusto] , Caracter , Ate centro de custo
@param De_Centra    , Caracter , De centro de trabalho
@param [Ate_Centra] , Caracter , Ate centro de trabalho

@author Guilherme Freudenburg
@since 23/07/2018
@version P12
@return nResult, Numérico, Quanti de horas do bem.
/*/
//------------------------------------------------------------------------------
Function MNTV042(De_Data,Ate_Data,De_Bem,Ate_Bem,De_Ccusto,Ate_Ccusto,;
                 De_Centra,Ate_Centra)

	Local aAreaOld := GetArea()
	Local cAliasST9:= GetNextAlias()
	Local cQuery   := ""
	Local nResult  := 0

	Default De_Bem    := ""
	Default De_Ccusto := ""
	Default De_Centra := ""

	cQuery := "SELECT ST9.T9_CALENDA "
	cQuery += "FROM "+RetSqlName("ST9")+" ST9 "
	cQuery += "WHERE ST9.T9_FILIAL = '"+xFilial("ST9")+"'"
	cQuery += " AND ST9.T9_CODBEM >= '"+De_Bem+"'"
	If ValType(Ate_Bem) == "C"
		cQuery += " AND ST9.T9_CODBEM <= '"+Ate_Bem+"'"
	Endif
	cQuery += " AND ST9.T9_CCUSTO >= '"+De_Ccusto+"'"
	If ValType(Ate_Ccusto) == "C"
		cQuery += " AND ST9.T9_CCUSTO <= '"+Ate_Ccusto+"'"
	Endif
	cQuery += " AND ST9.T9_CENTRAB >= '"+De_Centra+"'"
	If ValType(Ate_Centra) == "C"
		cQuery += " AND ST9.T9_CENTRAB <= '"+Ate_Centra+"'"
	Endif
	cQuery += " AND ST9.D_E_L_E_T_<>'*' "
	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery( cQuery , cAliasST9 )

	dbSelectArea(cAliasST9)
	While (cAliasST9)->(!Eof())
		nResult += NGCONVERHORA( NGCALENHORA(De_Data,"00:00",Ate_Data,"24:00",(cAliasST9)->T9_CALENDA) ,"S","D")
		(cAliasST9)->(dbSkip())
	EndDo
	(cAliasST9)->(DbCloseArea())

	RestArea(aAreaOld)

Return nResult
