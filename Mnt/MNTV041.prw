#INCLUDE "PROTHEUS.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTV041
Quantidade consumida de aditivo

@param De_Data			Data inicio
@param Ate_Data			Ate data
@param De_Familia		De Familia
@param Ate_Familia		Ate Familia
@param De_Modelo		De Modelo
@param Ate_Modelo		Ate Modelo
@param De_Ccusto		De centro de custo
@param Ate_Ccusto		Ate centro de custo
@param De_CenTra		De centro de trabalho
@param Ate_CenTra		Ate sentro de trabalho
@param Aditivo			Aditivo

@author Lucio Amorim
@since 08/01/2015
@author Rodrigo Luan Backes
@since 01/07/2016
@version MP11
@return nQtdAd  Quantidade Aditivo
/*/
//---------------------------------------------------------------------
Function MNTV041 (De_Data,Ate_Data,De_Familia,Ate_Familia,De_Modelo,Ate_Modelo,De_Ccusto,Ate_Ccusto,De_CenTra,Ate_CenTra,Aditivo)

	Local aAreaOLD   	:= GetArea(), nQtdAdt := 0
	Local De_FamiliaL	:= If( De_Familia  = Nil , Space( TamSX3( "T9_CODFAMI" )[1] ) , De_Familia  )
	Local Ate_FamiliaL	:= If( Ate_Familia = Nil , Space( TamSX3( "T9_CODFAMI" )[1] ) , Ate_Familia )
	Local De_ModeloL 	:= If( De_Modelo   = Nil , Space( TamSX3( "T9_TIPMOD"  )[1] ) , De_Modelo   )
	Local Ate_ModeloL	:= If( Ate_Modelo  = Nil , Space( TamSX3( "T9_TIPMOD"  )[1] ) , Ate_Modelo  )
	Local De_CcustoL 	:= If( De_Ccusto   = Nil , Space( TamSX3( "TQN_CCUSTO" )[1] ) , De_Ccusto   )
	Local De_CenTraL 	:= If( De_CenTra   = Nil , Space( TamSX3( "TQN_CENTRA" )[1] ) , De_CenTra   )
	Local AditivoL		:= If( Aditivo     = Nil , Space( TamSX3( "TL_CODIGO"  )[1] ) , Aditivo     )

	// Variaveis de Histórico de Indicadores
	Local lMV_HIST  := NGI6MVHIST()
	Local aParams   := {}
	Local cCodIndic := "MNTV041"
	Local nResult   := 0

	// Armazena os Parâmetros.
	If lMV_HIST
		aParams := {}
		aAdd(aParams, {"DE_DATA"    , De_Data})
		aAdd(aParams, {"ATE_DATA"   , Ate_Data})
		aAdd(aParams, {"DE_FAMILIA" , De_Familia})
		aAdd(aParams, {"ATE_FAMILIA", Ate_Familia})
		aAdd(aParams, {"DE_MODELO"  , De_Modelo})
		aAdd(aParams, {"ATE_MODELO" , Ate_Modelo})
		aAdd(aParams, {"ADITIVO"    , Aditivo})

		NGI6PREPPA(aParams, cCodIndic)
	EndIf

	If ValType(De_Data) != "D" .or. ValType(Ate_Data) != "D"
		NGI6PREPVA(cCodIndic, nResult)
		Return nResult
	Endif

	cAliasQry := GetNextAlias()
	// Query
	If lMV_HIST
		cQuery := " SELECT * "
	Else
		cQuery := " SELECT  SUM(TL_QUANTID) AS TL_QUANTID "
	EndIf
	cQuery += " FROM "+RetSQLName("STL")+" STL "
	cQuery += " INNER JOIN "+RetSQLName("STJ")+" STJ ON "
	cQuery += " STL.TL_ORDEM = STJ.TJ_ORDEM "
	cQuery += " INNER JOIN "+RetSQLName("ST9")+" ST9 ON "
	cQuery += " ST9.T9_CODBEM = STJ.TJ_CODBEM "
	cQuery += " WHERE "
	cQuery += " ST9.T9_TIPMOD      >= " + ValToSQL(De_ModeloL)   + " "
	cQuery += " AND ST9.T9_TIPMOD  <= " + ValToSQL(Ate_ModeloL)  + " "
	cQuery += " AND ST9.T9_CODFAMI >= " + ValToSQL(De_FamiliaL)  + " "
	cQuery += " AND ST9.T9_CODFAMI <= " + ValToSQL(Ate_FamiliaL) + " "
	cQuery += " AND STL.TL_DTINICI >= " + ValToSQL(De_Data)      + " "
	cQuery += " AND STL.TL_DTFIM   <= " + ValToSQL(Ate_Data)     + " "
	cQuery += " AND STL.TL_CODIGO  =  " + ValToSQL(AditivoL)     + " "
	cQuery += " AND STL.TL_SEQRELA <> 0  "
	cQuery += " AND ST9.D_E_L_E_T_ <> '*' "


	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	NGI6PREPDA(cAliasQry, cCodIndic)

	dbSelectArea(cAliasQry)
	dbGoTop()
	While !Eof()
		nQtdAdt := nQtdAdt + (cAliasQry)->TL_QUANTID
		dbSkip()
	End
	(cAliasQry)->(dbCloseArea())



	// RESULTADO
	nResult := nQtdAdt
	NGI6PREPVA(cCodIndic, nResult)

	RestArea(aAreaOLD)

Return nResult