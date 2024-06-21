#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "topconn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ UWSGL001	 ºAutor³ Adriano 		 	 	ºData³17/03/2020  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Integração Protheus Web	        						  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Integração Webservice FLUIG   .                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

WSSERVICE UWSGL001 DESCRIPTION "Integracao Protheus X FLUIG WEB"

	/////////////////////////////////////////////////////////////////////////////
	///////////////////////   MÉTODOS DE CONSULTA       /////////////////////////
	/////////////////////////////////////////////////////////////////////////////

	WSDATA		EntFornec				as Fornec
	WSDATA 		RetForneces				as ListaRetForneces
	
	WSDATA		EntCliente				as Cliente
	WSDATA 		RetClientes				as ListaRetClientes

	WSDATA		EntProd					as Prod
	WSDATA 		RetProd					as ListaRetProd

	WSDATA		EntUnMedida				as UnMedida
	WSDATA 		RetUnMedidas			as ListaRetUnMedidas
			
	WSDATA		EntCondPg			as CondPg
	WSDATA 		RetCondPgs			as ListaRetCondPgs

	WSDATA		EntCCusto				as CCusto
	WSDATA 		RetCCustos				as ListaRetCCustos

	WSDATA		EntTipoProduto  		as TipoProduto
	WSDATA 		RetTipoProdutos	    	as ListaRetTipoProdutos

	WSDATA		EntContaContabil  		as ContaContabil
	WSDATA 		RetContaContabeis		as ListaRetContaContabeis

	WSDATA		EntArmazem	 	 		as Armazem
	WSDATA 		RetArmazem				as ListaRetArmazem
 
	WSDATA		EntGrupoTributario  	as GrupoTributario
	WSDATA 		RetGrupoTributarios	    as ListaRetGrupoTributarios

	////////////////////////////////////////////////////////////////////////////////////
	///////////////////////   MÉTODOS DO WEB SERVICES PESQUISA /////////////////////////
	////////////////////////////////////////////////////////////////////////////////////
	
	WSMETHOD 	ConsultaCliente			DESCRIPTION "Consulta Clientes"
	WSMETHOD 	ConsultaFornecedores	DESCRIPTION "Consulta Fornecedores"	    
	WSMETHOD 	ConsultaProdutos		DESCRIPTION "Consulta Produtos"
	WSMETHOD 	ConsultaUnMedidas		DESCRIPTION "Unidades de Medidas"			
	WSMETHOD 	ConsultaCondPagtos		DESCRIPTION "Consulta Condicao de Pagamentos"	
	WSMETHOD 	ConsultaCentroCustos	DESCRIPTION "Consulta Centro de Custos"	
	WSMETHOD 	ConsultaTipoProduto		DESCRIPTION "Consulta Tipo Produto"
	WSMETHOD 	ConsultaContaContabil	DESCRIPTION "Consulta Conta Contabil"
	WSMETHOD 	ConsultaArmazem			DESCRIPTION "Consulta Armazem"
	WSMETHOD 	ConsultaGrupoTributario	DESCRIPTION "Consulta Grupo Tributario"	


ENDWSSERVICE
 

/////////////////////////////////////////////////////////////////////////////////////
//////////////////     CONSULTA DE CLIENTE	 	  ///////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////


WSSTRUCT Cliente

	WSDATA 		cCNPJCliente		as String OPTIONAL

ENDWSSTRUCT

WSSTRUCT ListaRetClientes

	WSDATA 		cRetorno			as String
	WSDATA 		aClientes			as Array of StructRetClientes	OPTIONAL

ENDWSSTRUCT

WSSTRUCT StructRetClientes

	WSDATA 		cCodigo				as String
	WSDATA 		cLoja				as String
	WSDATA 		cNome				as String
	WSDATA 		cNomeReduz			as String
	WSDATA 		cEnd				as String
	WSDATA 		cBairro				as String
	WSDATA 		cEst				as String
	WSDATA 		cCEP				as String
	WSDATA 		cTelefone			as String
	WSDATA 		cEmail				as String
	WSDATA 		cInscEstadual		as String
	WSDATA 		cCNPJ				as String

ENDWSSTRUCT

/////////////////////////////////////////////////////////////////////////////////////
//////////////////     CONSULTA DE PRODUTOS			/////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

WSSTRUCT Prod

	WSDATA 		cDescricao			as String OPTIONAL
	WSDATA 		cCodigo   			as String OPTIONAL
	WSDATA 		cxCodFil			as String OPTIONAL

ENDWSSTRUCT

WSSTRUCT ListaRetProd

	WSDATA 		cRetorno			as String
	WSDATA 		aProd				as Array of StructRetProd	OPTIONAL

ENDWSSTRUCT

WSSTRUCT StructRetProd

	WSDATA      cxFilial            as String
	WSDATA 		cCodigo				as String
	WSDATA 		cDescricao			as String
	WSDATA		cUM					as String
	WSDATA		cUmSegum			as String
	WSDATA		cForPad				as String
	WSDATA		cDescForPad			as String
	WSDATA		cCONV				as String
	WSDATA		cCodBar				as String
			
ENDWSSTRUCT
 

/////////////////////////////////////////////////////////////////////////////////////
//////////////////     CONSULTA DE CONDIÇÃO DE PAGAMENTO ////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

WSSTRUCT CondPg

	WSDATA 		cDescricao			as String OPTIONAL

ENDWSSTRUCT

WSSTRUCT ListaRetCondPgs

	WSDATA 		cRetorno			as String
	WSDATA 		aCondPgs			as Array of StructRetCondPgs	OPTIONAL

ENDWSSTRUCT

WSSTRUCT StructRetCondPgs

	WSDATA 		cCodigo				as String
	WSDATA 		cDescricao			as String
	WSDATA 		cCondicao			as String

ENDWSSTRUCT
 
/////////////////////////////////////////////////////////////////////////////////////
//////////////////     CONSULTA UN					     ////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

WSSTRUCT UnMedida

	WSDATA 		cdescricao			as String OPTIONAL

ENDWSSTRUCT

WSSTRUCT ListaRetUnMedidas

	WSDATA 		cRetorno			as String
	WSDATA 		aUnMedidas			as Array of StructRetUnMedidas	OPTIONAL

ENDWSSTRUCT

WSSTRUCT StructRetUnMedidas

	WSDATA 		cCodigo				as String
	WSDATA 		cDescricao			as String

ENDWSSTRUCT

/////////////////////////////////////////////////////////////////////////////////////
//////////////////     CONSULTA DE FORNECEDORES	 	  ///////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////


WSSTRUCT Fornec

	WSDATA 		cDescricao			as String OPTIONAL
	WSDATA 		cCNPJ				as String OPTIONAL

ENDWSSTRUCT

WSSTRUCT ListaRetForneces

	WSDATA 		cRetorno			as String
	WSDATA      lStatus             as Boolean
	WSDATA 		aForneces		as Array of StructRetForneces	OPTIONAL

ENDWSSTRUCT

WSSTRUCT StructRetForneces

	WSDATA 		cCodigo				as String
	WSDATA 		cLoja				as String
	WSDATA 		cNome				as String
	WSDATA 		cTelefone			as String
	WSDATA 		cCNPJFOR			as String
	WSDATA 		cNREDUZ				as String
	WSDATA 		cEND		        as String
	WSDATA 		cCOMPLEM	 		as String
	WSDATA 		cNR_END				as String
	WSDATA 		cBAIRRO				as String
	WSDATA 		cCEP				as String
	WSDATA 		cEST				as String	
	WSDATA 		cMUN				as String
	WSDATA 		cINSCR				as String
	WSDATA 		cINSCRM				as String
	WSDATA 		cTIPO				as String
	WSDATA 		cCONTATO			as String
	WSDATA 		cEMAIL				as String
	WSDATA      cDDD 				as String 

ENDWSSTRUCT

/////////////////////////////////////////////////////////////////////////////////////
//////////////////     CONSULTA DE CENTRO DE CUSTOS  ////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

WSSTRUCT CCusto

	WSDATA 		cxCodFil    		as String OPTIONAL
	WSDATA 		cDescricao			as String OPTIONAL

ENDWSSTRUCT

WSSTRUCT ListaRetCCustos

	WSDATA 		cRetorno			as String
	WSDATA 		aCCustos		as Array of StructRetCCustos	OPTIONAL

ENDWSSTRUCT

WSSTRUCT StructRetCCustos

	WSDATA 		cxFilial			as String
	WSDATA 		cCodigo				as String
	WSDATA 		cDescricao			as String

ENDWSSTRUCT
  
/////////////////////////////////////////////////////////////////////////////////////
//////////////////     CONSULTA TIPO PRODUTOS        ////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

WSSTRUCT TipoProduto

	WSDATA 		cDescricao			as String OPTIONAL

ENDWSSTRUCT

WSSTRUCT ListaRetTipoProdutos

	WSDATA 		cRetorno			as String
	WSDATA 		aTipoProdutos		as Array of StructRetTipoProdutos	OPTIONAL

ENDWSSTRUCT

WSSTRUCT StructRetTipoProdutos

	WSDATA 		cCodigo				as String
	WSDATA 		cDescricao			as String

ENDWSSTRUCT

/////////////////////////////////////////////////////////////////////////////////////
//////////////////     Consulta Grupo Tributarios    ////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

WSSTRUCT GrupoTributario

	WSDATA 		cDescricao			as String OPTIONAL

ENDWSSTRUCT

WSSTRUCT ListaRetGrupoTributarios

	WSDATA 		cRetorno				as String
	WSDATA 		aGrupoTributarios		as Array of StructRetGrupoTributarios	OPTIONAL

ENDWSSTRUCT

WSSTRUCT StructRetGrupoTributarios

	WSDATA 		cCodigo				as String
	WSDATA 		cDescricao			as String

ENDWSSTRUCT
 

/////////////////////////////////////////////////////////////////////////////////////
//////////////////     CONSULTA CONTA CONTABIL       ////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

WSSTRUCT ContaContabil

	WSDATA 		cDescricao			as String OPTIONAL

ENDWSSTRUCT

WSSTRUCT ListaRetContaContabeis

	WSDATA 		cRetorno			as String
	WSDATA 		aContaContabeis		as Array of StructRetContaContabeis	OPTIONAL

ENDWSSTRUCT

WSSTRUCT StructRetContaContabeis

	WSDATA 		cCodigo				as String
	WSDATA 		cDescricao			as String

ENDWSSTRUCT

/////////////////////////////////////////////////////////////////////////////////////
//////////////////     CONSULTA ARMAZEM		         ////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

WSSTRUCT Armazem

	WSDATA 		cDescricao			as String OPTIONAL

ENDWSSTRUCT

WSSTRUCT ListaRetArmazem

	WSDATA 		cRetorno			as String
	WSDATA 		aArmazem			as Array of StructRetArmazem	OPTIONAL

ENDWSSTRUCT

WSSTRUCT StructRetArmazem

	WSDATA 		cCodigo				as String
	WSDATA 		cDescricao			as String

ENDWSSTRUCT

/////////////////////////////////////////////////////////////////////////////////////
//////////////////     CONSULTA GRUPO TP PRODUTO     ////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

WSSTRUCT GrupoTpProd

	WSDATA 		cDescricao			as String OPTIONAL

ENDWSSTRUCT

WSSTRUCT ListaRetGrupoTpProd

	WSDATA 		cRetorno			as String
	WSDATA 		aGrupoTpProd		as Array of StructRetGrupoTpProd	OPTIONAL

ENDWSSTRUCT

WSSTRUCT StructRetGrupoTpProd

	WSDATA 		cCodigo				as String
	WSDATA 		cDescricao			as String

ENDWSSTRUCT 
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹Í±±
±±ºPrograma  ³ Consulta Clientes º Autor ³  			      ºData³ 10/10/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Método de consulta Cliente					 					º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 				                                             		º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

WSMETHOD ConsultaCliente WSRECEIVE EntCliente WSSEND RetClientes WSSERVICE UWSGL001

	Local aArea		:= GetArea()
	Local aRetorno	:= {}
	Local oDadosEnt := Nil
	Local oDadosRet	:= Nil
	Local oStructFor:= Nil
	Local cEOL 		:= Chr(13)+Chr(10)
	Local cQry		:= ""
	Local cMsgRet	:= ""

	oDadosEnt := EntCliente
	oDadosRet := RetClientes

	Conout("############ Web Services para Consulta de Cliente ############")

	cQry := " SELECT TOP 100 A1_COD, A1_LOJA, A1_NOME, A1_NREDUZ ,A1_END , A1_MUN , A1_EST , A1_CEP , A1_TEL , A1_EMAIL , A1_INSCR , A1_CGC " + cEOL
	cQry += " FROM " + RetSqlName("SA1") + "  															" + cEOL
	cQry += " WHERE D_E_L_E_T_ <> '*' 																	" + cEOL
	
	if !Empty(AllTrim(oDadosEnt:cCNPJCliente))

		cQry += " AND A1_CGC LIKE '%"+AllTrim(oDadosEnt:cCNPJCliente)+"%'								" + cEOL

	Endif
	
	cQry += " AND A1_FILIAL = '"+xFilial("SA1")+"'														" + cEOL

	If Select("QRYSA1") > 0
		QRYSA1->(DbCloseArea())
	EndIf
	
	cQry := ChangeQuery(cQry)
	TcQuery cQry New Alias "QRYSA1"

	if QRYSA1->( !Eof() )

		While QRYSA1->( !Eof() )

			oStructCli	:= NIL
			oStructCli 	:= WsClassNew("StructRetClientes")

			oStructCli:cCodigo		 := Alltrim(QRYSA1->A1_COD)
			oStructCli:cLoja		 := Alltrim(QRYSA1->A1_LOJA)
			oStructCli:cNome		 := Alltrim(QRYSA1->A1_NOME)
			oStructCli:cNomeReduz	 := Alltrim(QRYSA1->A1_NREDUZ)
			oStructCli:cEnd			 := Alltrim(QRYSA1->A1_END)	
			oStructCli:cBairro		 := Alltrim(QRYSA1->A1_MUN)
			oStructCli:cEst			 := Alltrim(QRYSA1->A1_EST)
			oStructCli:cCEP			 := Alltrim(QRYSA1->A1_CEP)																		
			oStructCli:cTelefone	 := Alltrim(QRYSA1->A1_TEL)
			oStructCli:cEmail		 := Alltrim(QRYSA1->A1_EMAIL)
			oStructCli:cInscEstadual := Alltrim(QRYSA1->A1_INSCR)
			oStructCli:cCNPJ		 := Alltrim(QRYSA1->A1_CGC)

			aAdd(aRetorno,oStructCli)

			QRYSA1->( DbSkip() )

		EndDo

		cMsgRet	:= " Consulta realizada com sucesso!"
		Conout(cMsgRet)
		RetClientes:cRetorno  		:= cMsgRet
		RetClientes:aClientes 	 	:= aRetorno

	else

		cMsgRet	:= "Nao foi encontrado Clientes nos parametros informados"
		oDadosRet:cRetorno := cMsgRet
		Conout(cMsgRet)

	endif

	RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹Í±±
±±ºPrograma  ³ ConsultaProdutos º Autor ³ Adriano Reis        ºData³ 10/10/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Método de consulta Produto					    				º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 				                                             		º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
 
WSMETHOD ConsultaProdutos WSRECEIVE EntProd WSSEND RetProd WSSERVICE UWSGL001

	Local aArea		:= GetArea()
	Local aRetorno	:= {}
	Local oDadosEnt := Nil
	Local oDadosRet	:= Nil
	Local oStructPrd:= Nil
	Local cEOL 		:= Chr(13)+Chr(10)
	Local cQry		:= ""
	Local cMsgRet	:= ""

	oDadosEnt := EntProd
	oDadosRet := RetProd

	Conout("############ Web Services para Consulta de Prod ############")

	cQry := " SELECT TOP 100 B1_FILIAL,B1_COD, B1_DESC,B1_UM,B1_SEGUM,B1_PROC,B1_CONV,B1_CODBAR	"    + cEOL
	cQry += " FROM " + RetSqlName("SB1") + " 															" + cEOL
	cQry += " WHERE D_E_L_E_T_ <> '*' 																	" + cEOL

	if !Empty(AllTrim(oDadosEnt:cDescricao))
		cQry += " AND B1_DESC LIKE '%" + UPPER(AllTrim(oDadosEnt:cDescricao)) + "%'								" + cEOL
	Endif
	if !Empty(AllTrim(oDadosEnt:cCodigo))
		cQry += " AND B1_COD LIKE '%" + UPPER(AllTrim(oDadosEnt:cCodigo)) + "%'								" + cEOL
	Endif	
	if !Empty(AllTrim(oDadosEnt:cxCodFil))
		cQry += " AND B1_FILIAL = '" + AllTrim(substr(oDadosEnt:cxCodFil,1,2)) + "'								" + cEOL
	Endif

	//cQry += " AND B1_FILIAL = '"+xFilial("SB1")+"' 													" + cEOL
	cQry += " 	AND  B1_MSBLQL = '2' 																	" + cEOL
	
	If Select("QRYSB1") > 0
		QRYSB1->(DbCloseArea())
	EndIf
	
	cQry := ChangeQuery(cQry)
	TcQuery cQry New Alias "QRYSB1"

	if QRYSB1->( !Eof() )

		While QRYSB1->( !Eof() )

			oStructPrd	:= NIL
			oStructPrd 	:= WsClassNew("StructRetProd")

			oStructPrd:cxFilial		:= Alltrim(QRYSB1->B1_FILIAL)
			oStructPrd:cCodigo		:= Alltrim(QRYSB1->B1_COD)
			oStructPrd:cDescricao	:= Alltrim(QRYSB1->B1_DESC)
			oStructPrd:cUM			:= Alltrim(QRYSB1->B1_UM)
			oStructPrd:cUmSegum		:= Alltrim(QRYSB1->B1_SEGUM)
			oStructPrd:cForPad		:= Alltrim(QRYSB1->B1_PROC)
			oStructPrd:cDescForPad	:= Alltrim(posicione("SA2",1,xfilial("SA2")+QRYSB1->B1_PROC,"A2_NREDUZ")) 
			oStructPrd:cCONV		:= Transform( QRYSB1->B1_CONV ,"@E 9999.999")    
			oStructPrd:cCodBar		:= Alltrim(QRYSB1->B1_CODBAR)

			aAdd(aRetorno,oStructPrd)

			QRYSB1->( DbSkip() )

		EndDo

		cMsgRet	:= " Consulta realizada com sucesso!"
		Conout(cMsgRet)
		oDadosRet:cRetorno  := cMsgRet
		oDadosRet:aProd := aRetorno

	else

		cMsgRet	:= "Nao foi encontrado produto nos parametros informados"
		oDadosRet:cRetorno := cMsgRet
		Conout(cMsgRet)

	endif

	RestArea(aArea)

Return(.T.)
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹Í±±
±±ºPrograma  ³  º Autor ³ Adriano Reis    ºData³ 10/10/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Método de consulta Clientes				 					º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 				                                             		º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

WSMETHOD ConsultaCondPagtos WSRECEIVE EntCondPg WSSEND RetCondPgs WSSERVICE UWSGL001

	Local aArea		:= GetArea()
	Local aRetorno	:= {}
	Local oDadosEnt := Nil
	Local oDadosRet	:= Nil
	Local oStructCp	:= Nil
	Local cEOL 		:= Chr(13)+Chr(10)
	Local cQry		:= ""
	Local cMsgRet	:= ""

	oDadosEnt := EntCondPg
	oDadosRet := RetCondPgs

	Conout("############ Web Services para Consulta de Condicao de Pagamentos ############")

	cQry := " SELECT E4_CODIGO, E4_COND,E4_DESCRI				 										" + cEOL
	cQry += " FROM " + RetSqlName("SE4") + " 															" + cEOL
	cQry += " WHERE D_E_L_E_T_ <> '*' 																	" + cEOL
	if !empty(AllTrim(oDadosEnt:cDescricao))

		cQry += " AND E4_DESCRI LIKE '%"+AllTrim(oDadosEnt:cDescricao)+"%'								" + cEOL

	endif
	cQry += " AND E4_FILIAL = '"+xFilial("SE4")+"' 														" + cEOL

	If Select("QRYSE4") > 0
		QRYSE4->(DbCloseArea())
	EndIf
	
	cQry := ChangeQuery(cQry)
	TcQuery cQry New Alias "QRYSE4"

	if QRYSE4->( !Eof() )

		While QRYSE4->( !Eof() )

			oStructCp			:= NIL
			oStructCp 			:= WsClassNew("StructRetCondPgs")

			oStructCp:cCodigo	:= Alltrim(QRYSE4->E4_CODIGO)
			oStructCp:cCondicao := Alltrim(QRYSE4->E4_COND)
			oStructCp:cDescricao:= Alltrim(QRYSE4->E4_DESCRI)

			aAdd(aRetorno,oStructCp)

			QRYSE4->( DbSkip() )

		EndDo

		cMsgRet	:= " Consulta realizada com sucesso!"
		Conout(cMsgRet)
		oDadosRet:cRetorno  	:= cMsgRet
		oDadosRet:aCondPgs 		:= aRetorno

	else

		cMsgRet	:= "Nao foi encontrado a condicao de pagamento nos parametros informados"
		oDadosRet:cRetorno := cMsgRet
		Conout(cMsgRet)

	endif

	RestArea(aArea)

Return(.T.)
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹Í±±
±±ºPrograma  ³  º Autor ³ Adriano Reis    ºData³ 10/10/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Método de consulta UnMedidas					 					º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 				                                             		º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

WSMETHOD ConsultaUnMedidas WSRECEIVE EntUnMedida WSSEND RetUnMedidas WSSERVICE UWSGL001

	Local aArea		:= GetArea()
	Local aRetorno	:= {}
	Local oDadosEnt := Nil
	Local oDadosRet	:= Nil
	Local oStructCp	:= Nil
	Local cEOL 		:= Chr(13)+Chr(10)
	Local cQry		:= ""
	Local cMsgRet	:= ""

	oDadosEnt := EntUnMedida
	oDadosRet := RetUnMedidas

	Conout("############ Web Services para Consulta de UN Medidas ############")

	cQry := " SELECT AH_UNIMED, AH_DESCPO	    				 										" + cEOL
	cQry += " FROM " + RetSqlName("SAH") + " 															" + cEOL
	cQry += " WHERE D_E_L_E_T_ <> '*' 																	" + cEOL
	if !Empty(AllTrim(oDadosEnt:cdescricao))
		cQry += " AND AH_DESCPO LIKE '%"+AllTrim(oDadosEnt:cdescricao)+"%'									" + cEOL
	Endif

	If Select("QRYSAH") > 0
		QRYSAH->(DbCloseArea())
	EndIf
	
	cQry := ChangeQuery(cQry)
	TcQuery cQry New Alias "QRYSAH"

	if QRYSAH->( !Eof() )

		While QRYSAH->( !Eof() )

			oStructCp			:= NIL
			oStructCp 			:= WsClassNew("StructRetUnMedidas")

			oStructCp:cCodigo	 := Alltrim(QRYSAH->AH_UNIMED)
			oStructCp:cDescricao := Alltrim(QRYSAH->AH_DESCPO)

			aAdd(aRetorno,oStructCp)

			QRYSAH->( DbSkip() )

		EndDo

		cMsgRet	:= " Consulta realizada com sucesso!"
		Conout(cMsgRet)
		oDadosRet:cRetorno  		:= cMsgRet
		oDadosRet:aUnMedidas 		:= aRetorno

	else

		cMsgRet	:= "Nao foi encontrado a Unidade de Medidas nos parametros informados"
		oDadosRet:cRetorno := cMsgRet
		Conout(cMsgRet)

	endif

	RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹Í±±
±±ºPrograma  ³ ConsultaFornecedores º Autor ³  				  ºData³ 10/10/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Método de consulta Fornecedores				 					º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 				                                             		º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

WSMETHOD ConsultaFornecedores WSRECEIVE EntFornec WSSEND RetForneces WSSERVICE UWSGL001

	Local aArea		:= GetArea()
	Local aRetorno	:= {}
	Local oDadosEnt := Nil
	Local oDadosRet	:= Nil
	Local oStructFor:= Nil
	Local cEOL 		:= Chr(13)+Chr(10)
	Local cQry		:= ""
	Local cMsgRet	:= ""

	oDadosEnt := EntFornec
	oDadosRet := RetForneces

	Conout("############ Web Services para Consulta de Fornecedores ############")

	cQry := " SELECT TOP 100 A2_COD,A2_LOJA,A2_NOME,A2_TEL,A2_CGC,A2_NREDUZ,A2_END,A2_COMPLEM,A2_NR_END,A2_BAIRRO,A2_CEP,A2_EST,A2_MUN,A2_INSCR,A2_INSCRM,A2_TIPO,A2_CONTATO,A2_EMAIL,A2_DDD	" + cEOL
	cQry += " FROM " + RetSqlName("SA2") + "  															" + cEOL
	cQry += " WHERE D_E_L_E_T_ <> '*' 																	" + cEOL
	if !Empty(AllTrim(oDadosEnt:cDescricao))
		cQry += " AND A2_NREDUZ LIKE '%"+AllTrim(oDadosEnt:cDescricao)+"%'								" + cEOL
	Endif
	if !Empty(AllTrim(oDadosEnt:cCNPJ))
		cQry += " AND A2_CGC LIKE '%"+AllTrim(oDadosEnt:cCNPJ)+"%'								    	" + cEOL
	Endif

	cQry += " AND A2_FILIAL = '"+xFilial("SA2")+"'														" + cEOL

	If Select("QRYSA2") > 0
		QRYSA2->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "QRYSA2"

	if QRYSA2->( !Eof() )

		While QRYSA2->( !Eof() )

			oStructFor	:= NIL
			oStructFor 	:= WsClassNew("StructRetForneces")

			oStructFor:cCodigo		:= Alltrim(QRYSA2->A2_COD)
			oStructFor:cLoja		:= Alltrim(QRYSA2->A2_LOJA)
			oStructFor:cNome		:= Alltrim(QRYSA2->A2_NOME)
			oStructFor:cTelefone	:= Alltrim(QRYSA2->A2_TEL)
			oStructFor:cCNPJFor    	:= Alltrim(QRYSA2->A2_CGC)
			oStructFor:cNREDUZ		:= Alltrim(QRYSA2->A2_NREDUZ)
			oStructFor:cEND			:= Alltrim(QRYSA2->A2_END)
			oStructFor:cCOMPLEM		:= Alltrim(QRYSA2->A2_COMPLEM)
			oStructFor:cNR_END		:= Alltrim(QRYSA2->A2_NR_END)	
			oStructFor:cBAIRRO		:= Alltrim(QRYSA2->A2_BAIRRO)
			oStructFor:cCEP			:= Alltrim(QRYSA2->A2_CEP)
			oStructFor:cEST			:= Alltrim(QRYSA2->A2_EST)
			oStructFor:cMUN			:= Alltrim(QRYSA2->A2_MUN)
			oStructFor:cINSCR		:= Alltrim(QRYSA2->A2_INSCR)
			oStructFor:cINSCRM		:= Alltrim(QRYSA2->A2_INSCRM)
			oStructFor:cTIPO		:= Alltrim(QRYSA2->A2_TIPO)
			oStructFor:cCONTATO		:= Alltrim(QRYSA2->A2_CONTATO)
			oStructFor:cEMAIL		:= Alltrim(QRYSA2->A2_EMAIL)
			oStructFor:cDDD			:= Alltrim(QRYSA2->A2_DDD)

			aAdd(aRetorno,oStructFor)

			QRYSA2->( DbSkip() )

		EndDo

		cMsgRet	:= " Consulta realizada com sucesso!"
		Conout(cMsgRet)
		oDadosRet:cRetorno := cMsgRet
		oDadosRet:lstatus := .T.
		oDadosRet:aForneces := aRetorno

	Else

		oStructFor	:= NIL
		oStructFor 	:= WsClassNew("StructRetForneces")

		oStructFor:cCodigo		:= ''
		oStructFor:cLoja		:= ''
		oStructFor:cNome		:= ''
		oStructFor:cTelefone	:= ''
		oStructFor:cCNPJFor    	:= ''
		oStructFor:cNREDUZ		:= ''
		oStructFor:cEND			:= ''
		oStructFor:cCOMPLEM		:= ''
		oStructFor:cNR_END		:= ''	
		oStructFor:cBAIRRO		:= ''
		oStructFor:cCEP			:= ''
		oStructFor:cEST			:= ''
		oStructFor:cMUN			:= ''
		oStructFor:cINSCR		:= ''
		oStructFor:cINSCRM		:= ''
		oStructFor:cTIPO		:= ''
		oStructFor:cCONTATO		:= ''
		oStructFor:cEMAIL		:= ''
		oStructFor:cDDD			:= ''

		aAdd(aRetorno,oStructFor)
			
		cMsgRet	:= "Nao foi encontrado Fornec nos parametros informados"
		Conout(cMsgRet)
		oDadosRet:cRetorno := cMsgRet
		oDadosRet:lstatus  := .F.		
		oDadosRet:aForneces := aRetorno
		
	Endif

	RestArea(aArea)

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹Í±±
±±ºPrograma  ³ Centro de Custos   º Autor ³ 				  ºData³ 10/10/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Método de consulta Centro de Custos								º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 				                                             		º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

 
WSMETHOD ConsultaCentroCustos WSRECEIVE EntCCusto WSSEND RetCCustos WSSERVICE UWSGL001

	Local aArea		:= GetArea()
	Local aRetorno	:= {}
	Local oDadosEnt := Nil
	Local oDadosRet	:= Nil
	Local oStructCC := Nil
	Local cEOL 		:= Chr(13)+Chr(10)
	Local cQry		:= ""
	Local cMsgRet	:= ""

	oDadosEnt := EntCCusto
	oDadosRet := RetCCustos

	Conout("############ Web Services para Consulta de Fornecedores ############")

	cQry := " SELECT CTT_CUSTO, CTT_DESC01 ,CTT_FILIAL							 						" + cEOL
	cQry += " FROM " + RetSqlName("CTT") + " 															" + cEOL
	cQry += " WHERE D_E_L_E_T_ <> '*' AND CTT_BLOQ = '2' AND CTT_CUSTO NOT IN ('20101','20201')         " + cEOL
	cQry += " AND CTT_CLASSE = '2'	 																	" + cEOL
	cQry += " AND CTT_DTEXSF = ' ' 																		" + cEOL

	if !empty(AllTrim(oDadosEnt:cDescricao))
		cQry += " AND ( CTT_DESC01 LIKE '%"+AllTrim(oDadosEnt:cDescricao)+"%' OR CTT_CUSTO LIKE '%"+AllTrim(oDadosEnt:cDescricao)+"%' ) " + cEOL
	Endif

	if !Empty(AllTrim(oDadosEnt:cxCodFil))
		cQry += " AND CTT_FILIAL = '" + AllTrim(substr(oDadosEnt:cxCodFil,1,2)) + "'					" + cEOL
	Endif

	cQry += " AND CTT_BLOQ   = '2' 																		" + cEOL
	
	If Select("QRYCTT") > 0
		QRYCTT->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "QRYCTT"

	if QRYCTT->( !Eof() )

		While QRYCTT->( !Eof() )

			oStructCC	:= NIL
			oStructCC 	:= WsClassNew("StructRetCCustos")

			oStructCC:cxFilial		:= Alltrim(QRYCTT->CTT_FILIAL)
			oStructCC:cCodigo		:= Alltrim(QRYCTT->CTT_CUSTO)
			oStructCC:cDescricao	:= Alltrim(QRYCTT->CTT_DESC01)

			aAdd(aRetorno,oStructCC)

			QRYCTT->( DbSkip() )

		EndDo


		cMsgRet	:= " Consulta realizada com sucesso!"
		Conout(cMsgRet)
		oDadosRet:cRetorno  	:= cMsgRet
		oDadosRet:aCCustos := aRetorno

	else

		cMsgRet	:= "Nao foi encontrado o centro de custo nos parametros informados"
		oDadosRet:cRetorno := cMsgRet
		Conout(cMsgRet)

	endif

	RestArea(aArea)

Return(.T.)
  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹Í±±
±±ºPrograma  ³ Grupo Produto	   º Autor ³ 				  ºData³ 10/10/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Método de consulta Tipo Produto									º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 				                                             		º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


WSMETHOD ConsultaTipoProduto WSRECEIVE EntTipoProduto WSSEND RetTipoProdutos WSSERVICE UWSGL001

	Local aArea		:= GetArea()
	Local aRetorno	:= {}
	Local oDadosEnt := Nil
	Local oDadosRet	:= Nil
	Local oStructCC := Nil
	Local cEOL 		:= Chr(13)+Chr(10)
	Local cQry		:= ""
	Local cMsgRet	:= ""

	oDadosEnt := EntTipoProduto
	oDadosRet := RetTipoProdutos

	Conout("############ Web Services para Consulta de Tipo de Produto ############")

	cQry := " SELECT X5_CHAVE, X5_DESCRI				 				 								" + cEOL
	cQry += " FROM " + RetSqlName("SX5") + " 															" + cEOL
	cQry += " WHERE D_E_L_E_T_ <> '*' 																	" + cEOL

	if !Empty(AllTrim(oDadosEnt:cDescricao))
		cQry += " AND X5_DESCRI LIKE '%"+AllTrim(oDadosEnt:cDescricao)+"%'								" + cEOL
	endif

	cQry += " AND X5_TABELA = '02' AND X5_FILIAL = '00'  												" + cEOL

	If Select("QRYTMP") > 0
		QRYTMP->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "QRYTMP"

	if QRYTMP->( !Eof() )

		While QRYTMP->( !Eof() )

			oStruct	:= NIL
			oStruct := WsClassNew("StructRetTipoProdutos")

			oStruct:cCodigo			:= UPPER(Alltrim(QRYTMP->X5_CHAVE))
			oStruct:cDescricao		:= UPPER(Alltrim(QRYTMP->X5_DESCRI))
						
			aAdd(aRetorno,oStruct)

			QRYTMP->( DbSkip() )

		EndDo


		cMsgRet	:= " Consulta realizada com sucesso!"
		Conout(cMsgRet)
		oDadosRet:cRetorno  		:= cMsgRet
		oDadosRet:aTipoProdutos  	:= aRetorno

	else

		cMsgRet	:= "Nao foi encontrado o Tipo de Produto nos parametros informados"
		oDadosRet:cRetorno := cMsgRet
		Conout(cMsgRet)

	endif

	RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹Í±±
±±ºPrograma  ³ Grupo Produto	   º Autor ³ 				  ºData³ 10/10/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Método de consulta Grupo Tributarios								º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 				                                             		º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


WSMETHOD ConsultaGrupoTributario WSRECEIVE EntGrupoTributario WSSEND RetGrupoTributarios WSSERVICE UWSGL001

	Local aArea		:= GetArea()
	Local aRetorno	:= {}
	Local oDadosEnt := Nil
	Local oDadosRet	:= Nil
	Local oStructCC := Nil
	Local cEOL 		:= Chr(13)+Chr(10)
	Local cQry		:= ""
	Local cMsgRet	:= ""

	oDadosEnt := EntGrupoTributario
	oDadosRet := RetGrupoTributarios

	Conout("############ Web Services para Consulta de Grupo Tributarios ############")

	cQry := " SELECT X5_CHAVE, X5_DESCRI				 				 								" + cEOL
	cQry += " FROM " + RetSqlName("SX5") + " 															" + cEOL
	cQry += " WHERE D_E_L_E_T_ <> '*' 																	" + cEOL

	if !Empty(AllTrim(oDadosEnt:cDescricao))
		cQry += " AND X5_DESCRI LIKE '%"+AllTrim(oDadosEnt:cDescricao)+"%'								" + cEOL
	endif

	cQry += " AND X5_TABELA = 'Z6' AND X5_FILIAL = '00'  												" + cEOL

	If Select("QRYTMP") > 0
		QRYTMP->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "QRYTMP"

	if QRYTMP->( !Eof() )

		While QRYTMP->( !Eof() )

			oStruct	:= NIL
			oStruct := WsClassNew("StructRetGrupoTributarios")

			oStruct:cCodigo			:= UPPER(Alltrim(QRYTMP->X5_CHAVE))
			oStruct:cDescricao		:= UPPER(Alltrim(QRYTMP->X5_DESCRI))
						
			aAdd(aRetorno,oStruct)

			QRYTMP->( DbSkip() )

		EndDo


		cMsgRet	:= " Consulta realizada com sucesso!"
		Conout(cMsgRet)
		oDadosRet:cRetorno  			:= cMsgRet
		oDadosRet:aGrupoTributarios  	:= aRetorno

	else

		cMsgRet	:= "Nao foi encontrado o Grupo Tributario nos parametros informados"
		oDadosRet:cRetorno := cMsgRet
		Conout(cMsgRet)

	endif

	RestArea(aArea)

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹Í±±
±±ºPrograma  ³ Grupo Produto	   º Autor ³ 				  ºData³ 10/10/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Método de consulta Conta Contabil								º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 				                                             		º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


WSMETHOD ConsultaContaContabil WSRECEIVE EntContaContabil WSSEND RetContaContabeis WSSERVICE UWSGL001

	Local aArea		:= GetArea()
	Local aRetorno	:= {}
	Local oDadosEnt := Nil
	Local oDadosRet	:= Nil
	Local oStructCC := Nil
	Local cEOL 		:= Chr(13)+Chr(10)
	Local cQry		:= ""
	Local cMsgRet	:= ""

	oDadosEnt := EntContaContabil
	oDadosRet := RetContaContabeis

	Conout("############ Web Services para Consulta de Conta Contabeis ############")

	cQry := " SELECT CT1_CONTA, CT1_DESC01				 				 								" + cEOL
	cQry += " FROM " + RetSqlName("CT1") + " 															" + cEOL
	cQry += " WHERE D_E_L_E_T_ <> '*' 																	" + cEOL

	if !Empty(AllTrim(oDadosEnt:cDescricao))
		cQry += " AND CT1_DESC01 LIKE '%"+AllTrim(oDadosEnt:cDescricao)+"%'								" + cEOL
	endif

	cQry += " AND CT1_CLASSE = '2' 						  												" + cEOL

	If Select("QRYTMP") > 0
		QRYTMP->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "QRYTMP"

	if QRYTMP->( !Eof() )

		While QRYTMP->( !Eof() )

			oStruct	:= NIL
			oStruct := WsClassNew("StructRetContaContabeis")

			oStruct:cCodigo			:= UPPER(Alltrim(QRYTMP->CT1_CONTA))
			oStruct:cDescricao		:= UPPER(Alltrim(QRYTMP->CT1_DESC01))
						
			aAdd(aRetorno,oStruct)

			QRYTMP->( DbSkip() )

		EndDo


		cMsgRet	:= " Consulta realizada com sucesso!"
		Conout(cMsgRet)
		oDadosRet:cRetorno  		:= cMsgRet
		oDadosRet:aContaContabeis  	:= aRetorno

	else

		cMsgRet	:= "Nao foi encontrado o Psicotropico nos parametros informados"
		oDadosRet:cRetorno := cMsgRet
		Conout(cMsgRet)

	endif

	RestArea(aArea)

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹Í±±
±±ºPrograma  ³ Grupo Produto	   º Autor ³ 				  ºData³ 10/10/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Método de consulta Armazem	    								º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 				                                             		º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


WSMETHOD ConsultaArmazem WSRECEIVE EntArmazem WSSEND RetArmazem WSSERVICE UWSGL001

	Local aArea		:= GetArea()
	Local aRetorno	:= {}
	Local oDadosEnt := Nil
	Local oDadosRet	:= Nil
	Local oStructCC := Nil
	Local cEOL 		:= Chr(13)+Chr(10)
	Local cQry		:= ""
	Local cMsgRet	:= ""

	oDadosEnt := EntArmazem
	oDadosRet := RetArmazem

	Conout("############ Web Services para Consulta de Armazem ############")

	cQry := " SELECT NNR_CODIGO, NNR_DESCRI				 				 								" + cEOL
	cQry += " FROM " + RetSqlName("NNR") + " 															" + cEOL
	cQry += " WHERE D_E_L_E_T_ <> '*' 																	" + cEOL

	if !Empty(AllTrim(oDadosEnt:cDescricao))
		cQry += " AND NNR_DESCRI LIKE '%"+AllTrim(oDadosEnt:cDescricao)+"%'								" + cEOL
	endif


	If Select("QRYTMP") > 0
		QRYTMP->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "QRYTMP"

	if QRYTMP->( !Eof() )

		While QRYTMP->( !Eof() )

			oStruct	:= NIL
			oStruct := WsClassNew("StructRetArmazem")

			oStruct:cCodigo			:= UPPER(Alltrim(QRYTMP->NNR_CODIGO))
			oStruct:cDescricao		:= UPPER(Alltrim(QRYTMP->NNR_DESCRI))
						
			aAdd(aRetorno,oStruct)

			QRYTMP->( DbSkip() )

		EndDo


		cMsgRet	:= " Consulta realizada com sucesso!"
		Conout(cMsgRet)
		oDadosRet:cRetorno  		:= cMsgRet
		oDadosRet:aArmazem  	:= aRetorno

	else

		cMsgRet	:= "Nao foi encontrado o Armazem nos parametros informados"
		oDadosRet:cRetorno := cMsgRet
		Conout(cMsgRet)

	endif

	RestArea(aArea)

Return(.T.)
 
   
