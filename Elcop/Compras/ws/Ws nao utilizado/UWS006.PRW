#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "topconn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "rwmake.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ UWS006	 บAutorณ Tarcisio Silva	 	 	บDataณ11/07/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Integra็ใo Protheus x Fluig								  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Inclusใo de pedido de compras.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿//NAO UTILIZADO
*/

WSSERVICE UWS006 DESCRIPTION "Integra็ใo Protheus X Fluig"

	WSDATA		EntFornecedor			as Fornecedor
	WSDATA 		RetFornecedores			as ListaRetFornecedores

	WSDATA		EntProdutos				as Produtos
	WSDATA 		RetProdutos				as ListaRetProdutos

	WSDATA		EntCondPagto			as CondPagto
	WSDATA 		RetCondPagtos			as ListaRetCondPagtos

	WSDATA		EntCentroCusto			as CentroCusto
	WSDATA 		RetCentroCustos			as ListaRetCentroCustos

	WSMETHOD 	ConsultaFornecedores	DESCRIPTION "Consulta Fornecedores"
	WSMETHOD 	ConsultaProdutos		DESCRIPTION "Consulta Produtos"
	WSMETHOD 	ConsultaCondPagtos		DESCRIPTION "Consulta Condi็ใo de Pagamentos"
	WSMETHOD 	ConsultaCentroCustos	DESCRIPTION "Consulta Centro de Custos"

ENDWSSERVICE

/////////////////////////////////////////////////////////////////////////////////////
//////////////////     CONSULTA DE FORNECEDORES	 	  ///////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////


WSSTRUCT Fornecedor

	WSDATA 		cDescricao			as String OPTIONAL

ENDWSSTRUCT

WSSTRUCT ListaRetFornecedores

	WSDATA 		cRetorno			as String
	WSDATA 		aFornecedores		as Array of StructRetFornecedores	OPTIONAL

ENDWSSTRUCT

WSSTRUCT StructRetFornecedores

	WSDATA 		cCodigo				as String
	WSDATA 		cLoja				as String
	WSDATA 		cNome				as String
	WSDATA 		cTelefone			as String

ENDWSSTRUCT

/////////////////////////////////////////////////////////////////////////////////////
//////////////////     CONSULTA DE CENTRO DE CUSTOS  ////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

WSSTRUCT CentroCusto

	WSDATA 		cDescricao			as String OPTIONAL

ENDWSSTRUCT

WSSTRUCT ListaRetCentroCustos

	WSDATA 		cRetorno			as String
	WSDATA 		aCentroCustos		as Array of StructRetCentroCustos	OPTIONAL

ENDWSSTRUCT

WSSTRUCT StructRetCentroCustos

	WSDATA 		cCodigo				as String
	WSDATA 		cDescricao			as String

ENDWSSTRUCT

/////////////////////////////////////////////////////////////////////////////////////
//////////////////     CONSULTA DE PRODUTOS			/////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

WSSTRUCT Produtos

	WSDATA 		cDescricao			as String OPTIONAL

ENDWSSTRUCT

WSSTRUCT ListaRetProdutos

	WSDATA 		cRetorno			as String
	WSDATA 		aProdutos			as Array of StructRetProdutos	OPTIONAL

ENDWSSTRUCT

WSSTRUCT StructRetProdutos

	WSDATA 		cCodigo				as String
	WSDATA 		cDescricao			as String

ENDWSSTRUCT

/////////////////////////////////////////////////////////////////////////////////////
//////////////////     CONSULTA DE CONDIวรO DE PAGAMENTO ////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

WSSTRUCT CondPagto

	WSDATA 		cDescricao			as String OPTIONAL

ENDWSSTRUCT

WSSTRUCT ListaRetCondPagtos

	WSDATA 		cRetorno			as String
	WSDATA 		aCondPagtos			as Array of StructRetCondPagtos	OPTIONAL

ENDWSSTRUCT

WSSTRUCT StructRetCondPagtos

	WSDATA 		cCodigo				as String
	WSDATA 		cDescricao			as String
	WSDATA 		cCondicao			as String

ENDWSSTRUCT

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนอฑฑ
ฑฑบPrograma  ณ ConsultaFornecedores บ Autor ณ Tarcisio Silva  บDataณ 10/10/2017 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออฯออออออออออออออออออออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ M้todo de consulta Fornecedores				 					บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 				                                             		บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

WSMETHOD ConsultaFornecedores WSRECEIVE EntFornecedor WSSEND RetFornecedores WSSERVICE UWS006

	Local aArea		:= GetArea()
	Local aRetorno	:= {}
	Local oDadosEnt := Nil
	Local oDadosRet	:= Nil
	Local oStructFor:= Nil
	Local cEOL 		:= Chr(13)+Chr(10)
	Local cQry		:= ""
	Local cMsgRet	:= ""

	oDadosEnt := EntFornecedor
	oDadosRet := RetFornecedores

	Conout("############ Web Services para Consulta de Fornecedores ############")

	cQry := " SELECT A2_COD, A2_LOJA, A2_NOME, A2_TEL					 								" + cEOL
	cQry += " FROM " + RetSqlName("SA2") + "  															" + cEOL
	cQry += " WHERE D_E_L_E_T_ <> '*' 																	" + cEOL
	if !empty(AllTrim(oDadosEnt:cDescricao))
	
		cQry += " AND A2_NOME LIKE '%"+AllTrim(oDadosEnt:cDescricao)+"%'								" + cEOL
	
	endif
	cQry += " AND A2_FILIAL = '"+xFilial("SA2")+"'														" + cEOL

	If Select("QRYSA2") > 0
		QRYSA2->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "QRYSA2"

	if QRYSA2->( !Eof() )

		While QRYSA2->( !Eof() )

			oStructFor	:= NIL
			oStructFor 	:= WsClassNew("StructRetFornecedores")

			oStructFor:cCodigo		:= QRYSA2->A2_COD
			oStructFor:cLoja		:= QRYSA2->A2_LOJA
			oStructFor:cNome		:= QRYSA2->A2_NOME
			oStructFor:cTelefone	:= QRYSA2->A2_TEL

			aAdd(aRetorno,oStructFor)

			QRYSA2->( DbSkip() )

		EndDo

		cMsgRet	:= " Consulta realizada com sucesso!"
		Conout(cMsgRet)
		RetFornecedores:cRetorno  		:= cMsgRet
		RetFornecedores:aFornecedores 	:= aRetorno

	else

		cMsgRet	:= "Nใo foi encontrado fornecedor nos parametros informados"
		oDadosRet:cRetorno := cMsgRet
		Conout(cMsgRet)

	endif

	RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนอฑฑ
ฑฑบPrograma  ณ ConsultaFornecedores บ Autor ณ Tarcisio Silva  บDataณ 10/10/2017 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออฯออออออออออออออออออออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ M้todo de consulta Fornecedores				 					บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 				                                             		บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

WSMETHOD ConsultaProdutos WSRECEIVE EntProdutos WSSEND RetProdutos WSSERVICE UWS006

	Local aArea		:= GetArea()
	Local aRetorno	:= {}
	Local oDadosEnt := Nil
	Local oDadosRet	:= Nil
	Local oStructPrd:= Nil
	Local cEOL 		:= Chr(13)+Chr(10)
	Local cQry		:= ""
	Local cMsgRet	:= ""

	oDadosEnt := EntProdutos
	oDadosRet := RetProdutos

	Conout("############ Web Services para Consulta de Produtos ############")

	cQry := " SELECT B1_COD, B1_DESC								 									" + cEOL
	cQry += " FROM " + RetSqlName("SB1") + " 															" + cEOL
	cQry += " WHERE D_E_L_E_T_ <> '*' 																	" + cEOL
	if !empty(AllTrim(oDadosEnt:cDescricao))
	
		cQry += " AND B1_DESC LIKE '%"+AllTrim(oDadosEnt:cDescricao)+"%'								" + cEOL
	
	endif
	cQry += " AND B1_FILIAL = '"+xFilial("SB1")+"' 														" + cEOL


	If Select("QRYSA2") > 0
		QRYSA2->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "QRYSA2"

	if QRYSA2->( !Eof() )

		While QRYSA2->( !Eof() )

			oStructPrd	:= NIL
			oStructPrd 	:= WsClassNew("StructRetProdutos")

			oStructPrd:cCodigo		:= QRYSA2->B1_COD
			oStructPrd:cDescricao	:= QRYSA2->B1_DESC


			aAdd(aRetorno,oStructPrd)

			QRYSA2->( DbSkip() )

		EndDo

		cMsgRet	:= " Consulta realizada com sucesso!"
		Conout(cMsgRet)
		oDadosRet:cRetorno  := cMsgRet
		oDadosRet:aProdutos := aRetorno

	else

		cMsgRet	:= "Nใo foi encontrado produto nos parametros informados"
		oDadosRet:cRetorno := cMsgRet
		Conout(cMsgRet)

	endif

	RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนอฑฑ
ฑฑบPrograma  ณ ConsultaFornecedores บ Autor ณ Tarcisio Silva  บDataณ 10/10/2017 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออฯออออออออออออออออออออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ M้todo de consulta Fornecedores				 					บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 				                                             		บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

WSMETHOD ConsultaCondPagtos WSRECEIVE EntCondPagto WSSEND RetCondPagtos WSSERVICE UWS006

	Local aArea		:= GetArea()
	Local aRetorno	:= {}
	Local oDadosEnt := Nil
	Local oDadosRet	:= Nil
	Local oStructCp	:= Nil
	Local cEOL 		:= Chr(13)+Chr(10)
	Local cQry		:= ""
	Local cMsgRet	:= ""

	oDadosEnt := EntCondPagto
	oDadosRet := RetCondPagtos

	Conout("############ Web Services para Consulta de Fornecedores ############")

	cQry := " SELECT E4_CODIGO, E4_COND,E4_DESCRI				 										" + cEOL
	cQry += " FROM " + RetSqlName("SE4") + " 															" + cEOL
	cQry += " WHERE D_E_L_E_T_ <> '*' 																	" + cEOL
	if !empty(AllTrim(oDadosEnt:cDescricao))
	
		cQry += " AND E4_DESCRI LIKE '%"+AllTrim(oDadosEnt:cDescricao)+"%'								" + cEOL
	
	endif
	cQry += " AND E4_FILIAL = '"+xFilial("SE4")+"' 														" + cEOL

	If Select("QRYSA2") > 0
		QRYSA2->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "QRYSA2"

	if QRYSA2->( !Eof() )

		While QRYSA2->( !Eof() )

			oStructCp			:= NIL
			oStructCp 			:= WsClassNew("StructRetCondPagtos")

			oStructCp:cCodigo	:= QRYSA2->E4_CODIGO
			oStructCp:cCondicao := QRYSA2->E4_COND
			oStructCp:cDescricao:= QRYSA2->E4_DESCRI

			aAdd(aRetorno,oStructCp)

			QRYSA2->( DbSkip() )

		EndDo

		cMsgRet	:= " Consulta realizada com sucesso!"
		Conout(cMsgRet)
		oDadosRet:cRetorno  	:= cMsgRet
		oDadosRet:aCondPagtos 	:= aRetorno

	else

		cMsgRet	:= "Nใo foi encontrado a condi็ใo de pagamento nos parametros informados"
		oDadosRet:cRetorno := cMsgRet
		Conout(cMsgRet)

	endif

	RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนอฑฑ
ฑฑบPrograma  ณ ConsultaFornecedores บ Autor ณ Tarcisio Silva  บDataณ 10/10/2017 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออฯออออออออออออออออออออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ M้todo de consulta Fornecedores				 					บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 				                                             		บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

WSMETHOD ConsultaCentroCustos WSRECEIVE EntCentroCusto WSSEND RetCentroCustos WSSERVICE UWS006

	Local aArea		:= GetArea()
	Local aRetorno	:= {}
	Local oDadosEnt := Nil
	Local oDadosRet	:= Nil
	Local oStructCC := Nil
	Local cEOL 		:= Chr(13)+Chr(10)
	Local cQry		:= ""
	Local cMsgRet	:= ""

	oDadosEnt := EntCentroCusto
	oDadosRet := RetCentroCustos

	Conout("############ Web Services para Consulta de Fornecedores ############")

	cQry := " SELECT CTT_CUSTO, CTT_DESC01							 									" + cEOL
	cQry += " FROM " + RetSqlName("CTT") + " 															" + cEOL
	cQry += " WHERE D_E_L_E_T_ <> '*' 																	" + cEOL
	
	if !empty(AllTrim(oDadosEnt:cDescricao))
		
		cQry += " AND CTT_DESC01 LIKE '%"+AllTrim(oDadosEnt:cDescricao)+"%'								" + cEOL
	
	endif
	
	cQry += " AND CTT_FILIAL = '"+xFilial("CTT")+"' 													" + cEOL

	If Select("QRYSA2") > 0
		QRYSA2->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "QRYSA2"

	if QRYSA2->( !Eof() )

		While QRYSA2->( !Eof() )

			oStructCC	:= NIL
			oStructCC 	:= WsClassNew("StructRetCentroCustos")

			oStructCC:cCodigo		:= QRYSA2->CTT_CUSTO
			oStructCC:cDescricao	:= QRYSA2->CTT_DESC01

			aAdd(aRetorno,oStructCC)

			QRYSA2->( DbSkip() )

		EndDo


		cMsgRet	:= " Consulta realizada com sucesso!"
		Conout(cMsgRet)
		oDadosRet:cRetorno  	:= cMsgRet
		oDadosRet:aCentroCustos := aRetorno

	else

		cMsgRet	:= "Nใo foi encontrado o centro de custo nos parametros informados"
		oDadosRet:cRetorno := cMsgRet
		Conout(cMsgRet)

	endif

	RestArea(aArea)

Return(.T.)
