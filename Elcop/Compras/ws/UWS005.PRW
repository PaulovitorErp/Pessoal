#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "topconn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � UWS005	 �Autor� Tarcisio Silva	 	 	�Data�11/07/2018  ���
�������������������������������������������������������������������������͹��
���Desc.     � Integra��o Protheus x Fluig								  ���
�������������������������������������������������������������������������͹��
���Uso       � Inclus�o de pedido de compras.                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

WSSERVICE UWS005 DESCRIPTION "integracao Protheus X Fluig"

	/////////////////////////////////////////////////////////////////////////////
	///////////////////// ESTRUTURA DO PEDIDO DE COMPRAS ////////////////////////
	/////////////////////////////////////////////////////////////////////////////

	WSDATA 		IncPedidoCompra	    	as ListaIncPedidoCompra
	WSDATA 		RetIncPedidoCompra		as ListaRetIncPedidoCompra

	WSDATA 		AltPedidoCompra	    	as ListaAltPedidoCompra
	WSDATA 		RetAltPedidoCompra		as ListaRetAltPedidoCompra

	WSDATA 		ExcPedidoCompra	    	as ListaExcPedidoCompra
	WSDATA 		RetExcPedidoCompra		as ListaRetExcPedidoCompra

	/////////////////////////////////////////////////////////////////////////////
	///////////////////////   M�TODOS DE CONSULTA       /////////////////////////
	/////////////////////////////////////////////////////////////////////////////

	WSDATA		EntFornecedor			as Fornecedor
	WSDATA 		RetFornecedores			as ListaRetFornecedores

	WSDATA		EntProdutos				as Produtos
	WSDATA 		RetProdutos				as ListaRetProdutos

	WSDATA		EntProdutosFabrica		as ProdutosFabrica
	WSDATA 		RetProdutosFabrica		as ListaRetProdutosFabrica

	WSDATA		EntCondPagto			as CondPagto
	WSDATA 		RetCondPagtos			as ListaRetCondPagtos

	WSDATA		EntCentroCusto			as CentroCusto
	WSDATA 		RetCentroCustos			as ListaRetCentroCustos

	WSDATA		EntFuncionarios			as Funcionarios
	WSDATA 		RetFuncionarios			as ListaRetFuncionarios

	////////////////////////////////////////////////////////////////////////////////////
	///////////////////////   M�TODOS INCLUSAO				   /////////////////////////
	////////////////////////////////////////////////////////////////////////////////////

	WSDATA 		Fornecedores	    	as ListaFornecedores
	WSDATA 		RetIncFornecedores      as ListaRetIncFornecedores

	/////////////////////////////////////////////////////////////////////////////
	///////////////////////   M�TODOS DO WEB SERVICES   /////////////////////////
	/////////////////////////////////////////////////////////////////////////////

	WSMETHOD 	IncluiPedidoCompra			DESCRIPTION "Inclus�o de Pedido de Compras"
	WSMETHOD 	AlteraPedidoCompra			DESCRIPTION "Altera��o de Pedido de Compras"
	WSMETHOD 	ExcluiPedidoCompra			DESCRIPTION "Exclus�o de Pedido de Compras"
	WSMETHOD 	ConsultaFornecedores		DESCRIPTION "Consulta Fornecedores"
	WSMETHOD 	ConsultaProdutos			DESCRIPTION "Consulta Produtos"
	WSMETHOD 	ConsultaProdutosFabrica		DESCRIPTION "Consulta Produtos x Fabricante"
	WSMETHOD 	ConsultaCondPagtos			DESCRIPTION "Consulta Condi��o de Pagamentos"
	WSMETHOD 	ConsultaCentroCustos		DESCRIPTION "Consulta Centro de Custos"
	WSMETHOD	ConsultaFuncionarios		DESCRIPTION "Consulta Cadastro de Funcionarios"

	WSMETHOD 	CadastraFornecedor			DESCRIPTION "Cadastro de Fornecedores"

ENDWSSERVICE

/////////////////////////////////////////////////////////////////////////////////////
//////////////////     ATRIBUTOS DA INCLUS�O PEDIDO DE COMPRAS	/////////////////////
/////////////////////////////////////////////////////////////////////////////////////

WSSTRUCT ListaIncPedidoCompra 

	WSDATA 		cEmissao				as String
	WSDATA 		cPrvEntrega				as String
	WSDATA 		cFornecedor				as String
	WSDATA 		cLoja					as String
	WSDATA 		cCondPagto				as String
	WSDATA 		cContato				as String
	WSDATA 		aIncItensPedidoCompra	as Array of StructIncRetPedidoCompra

ENDWSSTRUCT

WSSTRUCT StructIncRetPedidoCompra

	WSDATA 		cProduto		as String
	WSDATA 		cObs			as String
	WSDATA 		cCC				as String
	WSDATA 		cNumPlaca		as String
	WSDATA 		nQuant			as Float
	WSDATA 		nPreco			as Float
	WSDATA 		nTotal			as Float

ENDWSSTRUCT

/////////////////////////////////////////////////////////////////////////////////////
//////////////////     ATRIBUTOS DA ALTERA��O PEDIDO DE COMPRAS	/////////////////////
/////////////////////////////////////////////////////////////////////////////////////

WSSTRUCT ListaAltPedidoCompra 

	WSDATA 		cPedido					as String
	WSDATA 		cEmissao				as String
	WSDATA 		cPrvEntrega				as String
	WSDATA 		cFornecedor				as String
	WSDATA 		cLoja					as String
	WSDATA 		cCondPagto				as String
	WSDATA 		cContato				as String
	WSDATA 		aAltItensPedidoCompra	as Array of StructAltRetPedidoCompra

ENDWSSTRUCT

WSSTRUCT StructAltRetPedidoCompra

	WSDATA 		cItem			as String
	WSDATA 		cProduto		as String
	WSDATA 		cObs			as String
	WSDATA 		cCC				as String
	WSDATA 		cNumPlaca		as String
	WSDATA 		nQuant			as Float
	WSDATA 		nPreco			as Float
	WSDATA 		nTotal			as Float

ENDWSSTRUCT

WSSTRUCT ListaExcPedidoCompra 

	WSDATA 		cPedido					as String

ENDWSSTRUCT

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
//////////////////     CONSULTA DE FUNCIONARIOS      ////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

WSSTRUCT Funcionarios

	WSDATA 		cNomeFuncionario			as String OPTIONAL

ENDWSSTRUCT

WSSTRUCT ListaRetFuncionarios

	WSDATA 		cRetorno			as String
	WSDATA 		aFuncionarios		as Array of StructRetFuncionarios	OPTIONAL

ENDWSSTRUCT

WSSTRUCT StructRetFuncionarios

	WSDATA 		cCodigo				as String
	WSDATA 		cNomeFuncionario	as String
	WSDATA		cCPF				as String
	WSDATA		cCC					as String
	WSDATA 		cDescCC				as String
	WSDATA		cDataAdmissao		as String
	WSDATA		cCargoFuncao		as String
	WSDATA		nSalario			as Float
	WSDATA		cCartao 			as String

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
	WSDATA		cTipo				as String
	WSDATA 		cDescricao			as String

ENDWSSTRUCT

/////////////////////////////////////////////////////////////////////////////////////
//////////////////     CONSULTA DE PRODUTOS	X FABRICANTES  //////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

WSSTRUCT ProdutosFabrica

	WSDATA 		cDescricao			as String OPTIONAL

ENDWSSTRUCT

WSSTRUCT ListaRetProdutosFabrica

	WSDATA 		cRetorno			as String
	WSDATA 		aProdutos			as Array of StructRetProdutosFabrica	OPTIONAL

ENDWSSTRUCT

WSSTRUCT StructRetProdutosFabrica

	WSDATA 		cCodigo				as String
	WSDATA		cTipo				as String
	WSDATA 		cDescricao			as String
	WSDATA		cNomeFabrica		as String
	WSDATA		cCodFabrica			as String

ENDWSSTRUCT


/////////////////////////////////////////////////////////////////////////////////////
//////////////////     CONSULTA DE CONDI��O DE PAGAMENTO ////////////////////////////
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


/////////////////////////////////////////////////////////////////////////////////////
//////////////////     ATRIBUTOS DE RETORNO						/////////////////////
/////////////////////////////////////////////////////////////////////////////////////


WSSTRUCT ListaRetIncPedidoCompra

	WSDATA 		cInformacao			as String

ENDWSSTRUCT

WSSTRUCT ListaRetAltPedidoCompra

	WSDATA 		cInformacao			as String

ENDWSSTRUCT

WSSTRUCT ListaRetExcPedidoCompra

	WSDATA 		cInformacao			as String

ENDWSSTRUCT

/////////////////////////////////////////////////////////////////////////////////////
//////////////////    Inclusao de Fornecedores	 	  ///////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

WSSTRUCT ListaFornecedores

	WSDATA 		aFornecedores	as Array of StructFornecedores

ENDWSSTRUCT

WSSTRUCT StructFornecedores

	WSDATA 		cOperacao		as String
	WSDATA 		cCodigo			as String
	WSDATA 		cTipo			as String  
	WSDATA		cCGC			as String
	WSDATA		cNome			as String
	WSDATA		cNomeFantasia	as String
	WSDATA		cEndereco		as String
	WSDATA		cBairro			as String
	WSDATA		cEstado			as String
	WSDATA		cCodMunicipio	as String
	WSDATA		cCEP			as String
	WSDATA		cDDD			as String
	WSDATA		cTelefone		as String
	WSDATA		cInscEstadual	as String
	WSDATA		cInscMunicipal	as String
	WSDATA		cPais			as String
	WSDATA		cEmail			as String
	WSDATA      cCnae           as String
	WSDATA      cComplem        as String 
	WSDATA      cContato        as String
	WSDATA      cgrptrib        as string
	WSDATA      csegment        as string
	WSDATA      csolecm         as string
	WSDATA      csimpnac        as string 
	WSDATA		lBloqueado		as Boolean

ENDWSSTRUCT

WSSTRUCT ListaRetIncFornecedores

	WSDATA 		lLogin			as Boolean
	WSDATA 		aFornecedores	as Array of StructRetIncFornecedores OPTIONAL

ENDWSSTRUCT

WSSTRUCT StructRetIncFornecedores

	WSDATA 		cCodigo			as String
	WSDATA 		cNome			as String
	WSDATA 		lStatus			as String //Boolean
	WSDATA 		cErro			as String

ENDWSSTRUCT

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
������������������������������������������������������������������������������͹ͱ�
���Programa  � IncluiPedidoCompra �Autor� Tarcisio Silva	   �Data�11/07/2018 ���
�������������������������������������������������������������������������������͹��
���Desc.     � Metodo responsavel por efetuar a inclus�o do pedido de compras.	���
�������������������������������������������������������������������������������͹��
���Uso       � Elcop.		                                              		���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/

WSMETHOD IncluiPedidoCompra WSRECEIVE IncPedidoCompra WSSEND RetIncPedidoCompra WSSERVICE UWS005

	Local oCabPc 		:= Nil
	Local oItensPc		:= Nil
	Local aCabec		:= {}
	Local aItens		:= {}
	Local aLinha		:= {}
	//Local cPedido 		:= GetSxeNum("SC7","C7_NUM")
	Local cPedido 		:= ""
	Local nX			:= 1
	Local cMsgRet		:= ""

	Default cFilAnt 	:= ""

	Conout("############ Web Services para Inclus�o de pedido de compras ############")

	Private lMsErroAuto := .F.

	oCabPc 		:= IncPedidoCompra
	oItensPc	:= IncPedidoCompra:aIncItensPedidoCompra

	aadd(aCabec,{"C7_NUM" 		,cPedido					,Nil})
	aadd(aCabec,{"C7_EMISSAO" 	,cTod(oCabPc:cEmissao)		,Nil})
	aadd(aCabec,{"C7_DATPRF" 	,cTod(oCabPc:cPrvEntrega)	,Nil})
	aadd(aCabec,{"C7_FORNECE" 	,oCabPc:cFornecedor			,Nil})
	aadd(aCabec,{"C7_LOJA" 		,oCabPc:cLoja				,Nil})
	aadd(aCabec,{"C7_COND" 		,oCabPc:cCondPagto			,Nil})
	aadd(aCabec,{"C7_CONTATO" 	,oCabPc:cContato			,Nil})
	aadd(aCabec,{"C7_FILENT" 	,cFilAnt					,Nil})

	for nX := 1 to len(oItensPc)

		aadd(aLinha,{"C7_ITEM"		,StrZero(nX,3)				,Nil})
		aadd(aLinha,{"C7_PRODUTO"	,oItensPc[nX]:cProduto		,Nil})
		aadd(aLinha,{"C7_QUANT"		,oItensPc[nX]:nQuant		,Nil})
		aadd(aLinha,{"C7_PRECO"		,oItensPc[nX]:nPreco		,Nil})
		aadd(aLinha,{"C7_TOTAL"		,oItensPc[nX]:nTotal		,Nil})
		aadd(aLinha,{"C7_XOBS"		,oItensPc[nX]:cObs			,Nil})
		aadd(aLinha,{"C7_CC"		,oItensPc[nX]:cCC			,Nil})
		aadd(aLinha,{"C7_XPLACA"	,oItensPc[nX]:cNumPlaca		,Nil})
		aadd(aItens,aLinha)
		aLinha := {}

	Next nX

	Begin Transaction

		MATA120(1,aCabec,aItens,3)

		If !lMsErroAuto

			cMsgRet := "Pedido de compras incluso com sucesso!"
			Conout(cMsgRet)
			RetIncPedidoCompra:cInformacao	:= cMsgRet
			ConfirmSx8()

		Else

			cMsgRet := MostraErro("\temp") + chr(13)+chr(10) 
			Conout(cMsgRet)
			RetIncPedidoCompra:cInformacao	:= cMsgRet
			RollbackSx8()
			DisarmTransaction()

		EndIf

	End Transaction 

Return(.T.)

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
������������������������������������������������������������������������������͹ͱ�
���Programa  � AlteraPedidoCompra �Autor� Tarcisio Silva	   �Data�11/07/2018 ���
�������������������������������������������������������������������������������͹��
���Desc.     � Metodo responsavel por efetuar a Altera��o do pedido de compras.	���
�������������������������������������������������������������������������������͹��
���Uso       � Elcop.		                                              		���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/

WSMETHOD AlteraPedidoCompra WSRECEIVE AltPedidoCompra WSSEND RetAltPedidoCompra WSSERVICE UWS005

	Local aArea			:= GetArea()
	Local aAreaSC7 		:= SC7->(GetArea())
	Local oCabPc 		:= Nil
	Local oItensPc		:= Nil
	Local aCabec		:= {}
	Local aItens		:= {}
	Local aLinha		:= {}
	Local nX			:= 1
	Local cMsgRet		:= ""

	Default cFilAnt 	:= ""

	Conout("############ Web Services para altera��o de pedido de compras ############")

	Private lMsErroAuto := .F.

	SC7->(DbSelectArea("SC7"))
	SC7->(DbSetOrder(1))
	SC7->(DbGotop())

	oCabPc 		:= AltPedidoCompra
	oItensPc	:= AltPedidoCompra:aAltItensPedidoCompra

	if SC7->(DbSeek(xFilial("SC7")+oCabPc:cPedido))

		aadd(aCabec,{"C7_NUM" 		,oCabPc:cPedido				,Nil})
		aadd(aCabec,{"C7_EMISSAO" 	,cTod(oCabPc:cEmissao)		,Nil})
		aadd(aCabec,{"C7_DATPRF" 	,cTod(oCabPc:cPrvEntrega)	,Nil})
		aadd(aCabec,{"C7_FORNECE" 	,oCabPc:cFornecedor			,Nil})
		aadd(aCabec,{"C7_LOJA" 		,oCabPc:cLoja				,Nil})
		aadd(aCabec,{"C7_COND" 		,oCabPc:cCondPagto			,Nil})
		aadd(aCabec,{"C7_CONTATO" 	,oCabPc:cContato			,Nil})
		aadd(aCabec,{"C7_FILENT" 	,cFilAnt					,Nil})

		for nX := 1 to len(oItensPc)

			aadd(aLinha,{"C7_ITEM"		,oItensPc[nX]:cItem				,Nil})
			aadd(aLinha,{"C7_PRODUTO"	,oItensPc[nX]:cProduto			,Nil})
			aadd(aLinha,{"C7_QUANT"		,oItensPc[nX]:nQuant			,Nil})
			aadd(aLinha,{"C7_PRECO"		,oItensPc[nX]:nPreco			,Nil})
			aadd(aLinha,{"C7_TOTAL"		,oItensPc[nX]:nTotal			,Nil})
			aadd(aLinha,{"C7_XOBS"		,oItensPc[nX]:cObs				,Nil})
			aadd(aLinha,{"C7_CC"		,oItensPc[nX]:cCC				,Nil})
			aadd(aLinha,{"C7_XPLACA"	,oItensPc[nX]:cNumPlaca			,Nil})
			aadd(aItens,aLinha)
			aLinha := {}

		Next nX

		Begin Transaction

			MATA120(1,aCabec,aItens,4)

			If !lMsErroAuto

				cMsgRet := "Pedido de compras alterado com sucesso!"
				Conout(cMsgRet)
				RetAltPedidoCompra:cInformacao	:= cMsgRet

			Else

				cMsgRet := MostraErro("\temp") + chr(13)+chr(10) 
				Conout(cMsgRet)
				RetAltPedidoCompra:cInformacao	:= cMsgRet
				DisarmTransaction()

			EndIf

		End Transaction 

	else 


		cMsgRet := "N�o � possivel efetuar a altera��o do pedido, Motivo : Pedido n�o encontrado.!"
		Conout(cMsgRet)
		RetAltPedidoCompra:cInformacao	:= cMsgRet

	endif

	RestArea(aArea)
	RestArea(aAreaSC7)

Return(.T.)

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
������������������������������������������������������������������������������͹ͱ�
���Programa  � ExcluiPedidoCompra �Autor� Tarcisio Silva	   �Data�11/07/2018 ���
�������������������������������������������������������������������������������͹��
���Desc.     � Metodo responsavel por efetuar a Exclus�o do pedido de compras.	���
�������������������������������������������������������������������������������͹��
���Uso       � Elcop.		                                              		���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/

WSMETHOD ExcluiPedidoCompra WSRECEIVE ExcPedidoCompra WSSEND RetExcPedidoCompra WSSERVICE UWS005

	Local aArea			:= GetArea()
	Local aAreaSC7 		:= SC7->(GetArea())
	Local oCabPc 		:= Nil
	Local aCabec		:= {}
	Local aItens		:= {}
	Local aLinha		:= {}
//	Local nX			:= 1
	Local cMsgRet		:= ""

	Default cFilAnt 	:= ""

	Conout("############ Web Services para Exclus�o do pedido de compras ############")

	Private lMsErroAuto := .F.

	SC7->(DbSelectArea("SC7"))
	SC7->(DbSetOrder(1))
	SC7->(DbGotop())

	oCabPc 		:= ExcPedidoCompra

	if SC7->(DbSeek(xFilial("SC7")+oCabPc:cPedido))

		aadd(aCabec,{"C7_NUM" 		,SC7->C7_NUM		,Nil})
		aadd(aCabec,{"C7_EMISSAO" 	,SC7->C7_EMISSAO	,Nil})
		aadd(aCabec,{"C7_FORNECE" 	,SC7->C7_FORNECE	,Nil})
		aadd(aCabec,{"C7_LOJA" 		,SC7->C7_LOJA		,Nil})
		aadd(aCabec,{"C7_COND" 		,SC7->C7_COND		,Nil})
		aadd(aCabec,{"C7_CONTATO" 	,SC7->C7_CONTATO	,Nil})
		aadd(aCabec,{"C7_FILENT" 	,SC7->C7_FILENT		,Nil})

		While !SC7->(Eof()) .AND. SC7->C7_FILIAL == xFilial("SC7") .AND. SC7->C7_NUM == oCabPc:cPedido

			aadd(aLinha,{"C7_ITEM"		,SC7->C7_ITEM	,Nil})
			aadd(aLinha,{"C7_PRODUTO"	,SC7->C7_PRODUTO,Nil})
			aadd(aLinha,{"C7_QUANT"		,SC7->C7_QUANT	,Nil})
			aadd(aLinha,{"C7_PRECO"		,SC7->C7_PRECO	,Nil})
			aadd(aLinha,{"C7_TOTAL"		,SC7->C7_TOTAL	,Nil})
			aadd(aLinha,{"C7_XOBS"		,SC7->C7_XOBS	,Nil})
			aadd(aLinha,{"C7_CC"		,SC7->C7_CC		,Nil})
			aadd(aLinha,{"C7_REC_WT" 	,SC7->(RecNo()) ,Nil})
			aadd(aItens,aLinha)
			aLinha := {}

			SC7->(DbSkip())

		enddo

		Begin Transaction

			MATA120(1,aCabec,aItens,5)

			If !lMsErroAuto

				cMsgRet := "Pedido de compras Excluso com sucesso!"
				Conout(cMsgRet)
				RetExcPedidoCompra:cInformacao	:= cMsgRet

			Else

				cMsgRet := MostraErro("\temp") + chr(13)+chr(10) 
				Conout(cMsgRet)
				RetExcPedidoCompra:cInformacao	:= cMsgRet
				DisarmTransaction()

			EndIf

		End Transaction 

	else 

		cMsgRet := "Pedido de compras n�o localizado!"
		Conout(cMsgRet)
		RetExcPedidoCompra:cInformacao	:= cMsgRet

	endif

	RestArea(aArea)
	RestArea(aAreaSC7)

Return(.T.)

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
������������������������������������������������������������������������������͹ͱ�
���Programa  � ConsultaFornecedores � Autor � Tarcisio Silva  �Data� 10/10/2017 ���
�������������������������������������������������������������������������������͹��
���Desc.     � M�todo de consulta Fornecedores				 					���
�������������������������������������������������������������������������������͹��
���Uso       � 				                                             		���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/

WSMETHOD ConsultaFornecedores WSRECEIVE EntFornecedor WSSEND RetFornecedores WSSERVICE UWS005

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

	cQry := " SELECT TOP 30 A2_COD, A2_LOJA, A2_NOME, A2_TEL					 						" + cEOL
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

		cMsgRet	:= "N�o foi encontrado fornecedor nos parametros informados"
		oDadosRet:cRetorno := cMsgRet
		Conout(cMsgRet)

	endif

	RestArea(aArea)

Return(.T.)

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
������������������������������������������������������������������������������͹ͱ�
���Programa  � ConsultaFornecedores � Autor � Tarcisio Silva  �Data� 10/10/2017 ���
�������������������������������������������������������������������������������͹��
���Desc.     � M�todo de consulta Produtos      			 					���
�������������������������������������������������������������������������������͹��
���Uso       � 				                                             		���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/

WSMETHOD ConsultaProdutos WSRECEIVE EntProdutos WSSEND RetProdutos WSSERVICE UWS005

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

	cQry := " SELECT SB1.B1_COD, SB1.B1_TIPO, SB1.B1_DESC	" + cEOL
	cQry += " FROM " + RetSqlName("SB1") + " SB1 "+ "			  		    " + cEOL
//	cQry += " INNER JOIN "+RetSqlName("ST7")+ " ST7 "+" ON (ST7.D_E_L_E_T_ = ' ' AND             " + cEOL
	cQry += " WHERE SB1.D_E_L_E_T_ <> '*' AND SB1.B1_XBLOQ ='2'				" + cEOL

	if !empty(AllTrim(oDadosEnt:cDescricao))

		cQry += " AND SB1.B1_DESC LIKE '%"+AllTrim(oDadosEnt:cDescricao)+"%'	" + cEOL

	endif
	//cQry += " AND B1_FILIAL = '"+xFilial("SB1")+"'							" + cEOL

	If Select("QRYSA2") > 0
		QRYSA2->(DbCloseArea())
	EndIf

	conout(cQry)

	TcQuery cQry New Alias "QRYSA2"

	if QRYSA2->( !Eof() )

		While QRYSA2->( !Eof() )

			oStructPrd	:= NIL
			oStructPrd 	:= WsClassNew("StructRetProdutos")

			oStructPrd:cCodigo		:= QRYSA2->B1_COD
			oStructPrd:cTipo		:= QRYSA2->B1_TIPO
			oStructPrd:cDescricao	:= QRYSA2->B1_DESC


			aAdd(aRetorno,oStructPrd)

			QRYSA2->( DbSkip() )

		EndDo

		cMsgRet	:= " Consulta realizada com sucesso!"
		Conout(cMsgRet)
		oDadosRet:cRetorno  := cMsgRet
		oDadosRet:aProdutos := aRetorno

	else

		cMsgRet	:= "N�o foi encontrado produto nos parametros informados"
		oDadosRet:cRetorno := cMsgRet
		Conout(cMsgRet)

	endif

	RestArea(aArea)

Return(.T.)

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
������������������������������������������������������������������������������͹ͱ�
���Programa  � ConsultaProdutosFabtica � Autor � Sinval		  �Data� 08/06/2021 ���
�������������������������������������������������������������������������������͹��
���Desc.     � M�todo de consulta Produtos x Fabricantes      			 					���
�������������������������������������������������������������������������������͹��
���Uso       � 				                                             		���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/

WSMETHOD ConsultaProdutosFabrica WSRECEIVE EntProdutosFabrica WSSEND RetProdutosFabrica WSSERVICE UWS005

	Local aArea		:= GetArea()
	Local aRetorno	:= {}
	Local oDadosEnt := Nil
	Local oDadosRet	:= Nil
	Local oStructPrd:= Nil
	Local cEOL 		:= Chr(13)+Chr(10)
	Local cQry		:= ""
	Local cMsgRet	:= ""

	oDadosEnt := EntProdutosFabrica
	oDadosRet := RetProdutosFabrica

	Conout("############ Web Services para Consulta de Produtos x Fabricantes ############")

	cQry := " SELECT TOP 30 SB1.B1_COD, SB1.B1_TIPO, SB1.B1_DESC, ZCS.ZCS_NOMFAB, ZCS.ZCS_FABRIC " + cEOL
	cQry += " FROM " + RetSqlName("SB1") + " SB1 " + "											 " + cEOL
	cQry += " INNER JOIN "+RetSqlName("ZCS")+ " ZCS "+" ON (ZCS.D_E_L_E_T_ = ' ' AND             " + cEOL
	cQry += " ZCS.ZCS_CODPRO = SB1.B1_COD AND ZCS.ZCS_BLOQ <> 'N' )"
	cQry += " WHERE SB1.D_E_L_E_T_ <> '*' AND SB1.B1_XBLOQ = '2' ' " + cEOL
	if !empty(AllTrim(oDadosEnt:cDescricao))

		cQry += " AND SB1.B1_DESC LIKE '%"+AllTrim(oDadosEnt:cDescricao)+"%'					 " + cEOL

	endif
	cQry += " AND SB1.B1_FILIAL = '"+xFilial("SB1")+"' 											 " + cEOL

	If Select("QRYSA2") > 0
		QRYSA2->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "QRYSA2"

	if QRYSA2->( !Eof() )

		While QRYSA2->( !Eof() )

			oStructPrd	:= NIL
			oStructPrd 	:= WsClassNew("StructRetProdutos")

			oStructPrd:cCodigo		:= QRYSA2->B1_COD
			oStructPrd:cTipo		:= QRYSA2->B1_TIPO
			oStructPrd:cDescricao	:= QRYSA2->B1_DESC
			oStructPrd:cNomeFabrica := QRYSA2->ZCS_NOMFAB
			oStructPrd:cCodFabrica  := QRYSA2->ZCS_FABRIC

			aAdd(aRetorno,oStructPrd)

			QRYSA2->( DbSkip() )

		EndDo

		cMsgRet	:= " Consulta realizada com sucesso!"
		Conout(cMsgRet)
		oDadosRet:cRetorno  := cMsgRet
		oDadosRet:aProdutos := aRetorno

	else

		cMsgRet	:= "N�o foi encontrado produto nos parametros informados"
		oDadosRet:cRetorno := cMsgRet
		Conout(cMsgRet)

	endif

	RestArea(aArea)

Return(.T.)

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
������������������������������������������������������������������������������͹ͱ�
���Programa  � ConsultaFornecedores � Autor � Tarcisio Silva  �Data� 10/10/2017 ���
�������������������������������������������������������������������������������͹��
���Desc.     � M�todo de consulta Fornecedores				 					���
�������������������������������������������������������������������������������͹��
���Uso       � 				                                             		���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/

WSMETHOD ConsultaCondPagtos WSRECEIVE EntCondPagto WSSEND RetCondPagtos WSSERVICE UWS005

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

		cMsgRet	:= "N�o foi encontrado a condi��o de pagamento nos parametros informados"
		oDadosRet:cRetorno := cMsgRet
		Conout(cMsgRet)

	endif

	RestArea(aArea)

Return(.T.)

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
������������������������������������������������������������������������������͹ͱ�
���Programa  � ConsultaFornecedores � Autor � Tarcisio Silva  �Data� 10/10/2017 ���
												Sinval               11/2020
�������������������������������������������������������������������������������͹��
���Desc.     � M�todo de consulta Fornecedores				 					���
�������������������������������������������������������������������������������͹��
���Uso       � 				                                             		���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/

WSMETHOD ConsultaCentroCustos WSRECEIVE EntCentroCusto WSSEND RetCentroCustos WSSERVICE UWS005

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

	Conout("############ Web Services para Consulta de centro de custos ############")

	cQry := " SELECT TOP 100 CTT_CUSTO, CTT_DESC01							 							" + cEOL
	cQry += " FROM " + RetSqlName("CTT") + " 															" + cEOL
	cQry += " WHERE D_E_L_E_T_ <> '*' AND CTT_BLOQ = '2' AND CTT_CLASSE='2'								" + cEOL
	cQry += " AND CTT_CUSTO NOT IN ('20101','20201')													" + cEOL

	if !empty(AllTrim(oDadosEnt:cDescricao))

		cQry += " AND CTT_DESC01 LIKE '%"+AllTrim(oDadosEnt:cDescricao)+"%'								" + cEOL

	endif

	cQry += " AND CTT_FILIAL = '"+xFilial("CTT")+"' 													" + cEOL
	cQry += " ORDER BY CTT_DESC01																		" + cEOL

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

		cMsgRet	:= "N�o foi encontrado o centro de custo nos parametros informados"
		oDadosRet:cRetorno := cMsgRet
		Conout(cMsgRet)

	endif

	RestArea(aArea)

Return(.T.)


/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
������������������������������������������������������������������������������͹ͱ�
���Programa  � ConsultaFuncionarios � Autor � Sinval          �Data� 02/02/2021 ���
�������������������������������������������������������������������������������͹��
���Desc.     � M�todo de consulta Funcionarios				 					���
�������������������������������������������������������������������������������͹��
���Uso       � 				                                             		���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/

WSMETHOD ConsultaFuncionarios WSRECEIVE EntFuncionarios WSSEND RetFuncionarios WSSERVICE UWS005

	Local aArea		:= GetArea()
	Local aRetorno	:= {}
	Local oDadosEnt := Nil
	Local oDadosRet	:= Nil
	Local oStructFu := Nil
	Local cEOL 		:= Chr(13)+Chr(10)
	Local cQry		:= ""
	Local cMsgRet	:= ""

	oDadosEnt := EntFuncionarios
	oDadosRet := RetFuncionarios

	Conout("############ Web Services para Consulta de Funcionarios ############")

	cQry := " SELECT TOP 100 RA_MAT, RA_NOME, RA_CIC, RA_CC, CTT_DESC01, RA_SALARIO,RA_XCART,			" + cEOL
	cQry += " RJ_DESC, RA_ADMISSA 																		" + cEOL
	cQry += " FROM " + RetSqlName("SRA") + " SRA																" + cEOL
	cQry += " INNER JOIN " + retSqlName("CTT") + " CTT ON (CTT.D_E_L_E_T_ = ' ' AND CTT.CTT_CUSTO = SRA.RA_CC ) " + cEOL
	cQry += " INNER JOIN " + retSqlName("SRJ") + " SRJ ON (SRJ.D_E_L_E_T_ = ' ' AND SRJ.RJ_FUNCAO = SRA.RA_CODFUNC ) " + cEOL
	cQry += " WHERE SRA.D_E_L_E_T_ <> '*' AND SRA.RA_SITFOLH <> 'D'												" + cEOL

	if !empty(AllTrim(oDadosEnt:cNomeFuncionario))

		cQry += " AND SRA.RA_NOME LIKE '%"+AllTrim(oDadosEnt:cNomeFuncionario)+"%'								" + cEOL

	endif

	cQry += " AND RA_FILIAL = '"+xFilial("SRA")+"' 																" + cEOL
	cQry += " ORDER BY RA_NOME																					" + cEOL

	//Conout(cQry)

	If Select("QRYSRA") > 0
		QRYSRA->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "QRYSRA"

	if QRYSRA->( !Eof() )

		While QRYSRA->( !Eof() )

			oStructFu	:= NIL
			oStructFu 	:= WsClassNew("StructRetFuncionarios")

			oStructFu:cCodigo			:= QRYSRA->RA_MAT
			oStructFu:cNomeFuncionario	:= QRYSRA->RA_NOME
			oStructFu:cCPF				:= transform(QRYSRA->RA_CIC, "@R 999.999.999-99")
			oStructFu:cCC				:= QRYSRA->RA_CC
			oStructFu:cDescCC			:= QRYSRA->CTT_DESC01
			oStructFu:cDataAdmissao		:= dtoc(stod(QRYSRA->RA_ADMISSA))
			oStructFu:cCargoFuncao		:= QRYSRA->RJ_DESC
			oStructFu:nSalario			:= QRYSRA->RA_SALARIO
			oStructFu:cCartao			:= QRYSRA->RA_XCART

			aAdd(aRetorno,oStructFu)

			QRYSRA->( DbSkip() )

		EndDo


		cMsgRet	:= " Consulta de Funcion�rios realizada com sucesso!"
		Conout(cMsgRet)
		oDadosRet:cRetorno  	:= cMsgRet
		oDadosRet:aFuncionarios := aRetorno

	else

		cMsgRet	:= "N�o foi encontrado o centro de custo nos parametros informados"
		oDadosRet:cRetorno := cMsgRet
		Conout(cMsgRet)

	endif

	RestArea(aArea)

Return(.T.)


/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
������������������������������������������������������������������������������͹ͱ�
���Programa  � Cadastro de Fornecedor � Autor �     	      �Data� 10/10/2017 ���
�������������������������������������������������������������������������������͹��
���Desc.     � WS Metodo De Cadastro de Fornecedor	    		 				���
�������������������������������������������������������������������������������͹��
���Uso       � 				                                             		���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/

WSMETHOD CadastraFornecedor WSRECEIVE Fornecedores WSSEND RetIncFornecedores WSSERVICE UWS005

	Local oFornecedor		:= NIL
	Local oRetFornecedor	:= NIL
	Local aRetorno			:= {}
	Local cEmp				:= ""
	Local cFil				:= ""
	Local cOperacao			:= ""
	Local cMsgErro			:= ""
	Local nX				:= 1
	Local nOpcao			:= 0
	Local lLogin			:= .T.
	Local lAmbiente			:= .F.
	Local nTentativa		:= 0
	Local cCodEmp		    := "01"
	Local cCodFil		    := "00"
	Private lMsHelpAuto		:= .T.
	Private lMsErroAuto 	:= .F.
	
	Conout("############ Web Services para cadastro de Fornecedores ############")

	RpcSetType(3)
	Reset Environment
	lConnect := RpcSetEnv(cCodEmp,cCodFil) 

	// se conseguiu logar na empresa
	if lConnect

		if Len(Self:Fornecedores:aFornecedores) > 0

			For nX := 1 To Len(Self:Fornecedores:aFornecedores)

				// Inicializo as variaveis do execauto
				lMsHelpAuto	:= .T.
				lMsErroAuto := .F.

				cMsgErro	:= "" // Variavel para armazenar a mensagem de erro por fornecedor
				oFornecedor := Self:Fornecedores:aFornecedores[nX]
				cOperacao	:= oFornecedor:cOperacao

				cCodigo := ''
				cNome   := ''

				If !(cOperacao $ "I/A")

					cMsgErro := "A operacao informada e invalida!"

					// verifico qual a estrutura do retorno do fornecedor
					oRetIncFornecedor := WsClassNew("StructRetIncFornecedores")

					// preencho os dados do retorno do cliente
					oRetIncFornecedor:cCodigo 	:= ''
					oRetIncFornecedor:cNome 	:= ''
					oRetIncFornecedor:lStatus 	:= 'N'
					oRetIncFornecedor:cErro		:= 'A operacao informada e invalida!'

					aadd(aRetorno,oRetIncFornecedor)

				Else

					if Alltrim(oFornecedor:cTipo) <> 'X'

						DbSelectArea("SA2")
						SA2->(DbSetOrder(3))
						IF SA2->(MsSeek(xFilial("SA2") + oFornecedor:cCGC))
							Conout("Fornecedor ja existe!")

							if cOperacao $ "I" 
								cMsgErro := "Nao foi possivel incluir o fornecedor. CNPJ ja cadastrado no protheus!"
							EndIf

							Public ALTERA := .T.
							Public Inclui := .F. 							
							cOperacao := "A"
							nOpcao := 4

						Else

							Conout("Fornecedor nao existe!")

							if cOperacao $ "A" 
								cMsgErro := "Nao foi poss�vel incluir o fornecedor. CNPJ ja cadastrado no protheus!"
							EndIf

							Public ALTERA := .F.
							Public Inclui := .T. 							
							cOperacao := "I"
							nOpcao := 3

						EndIf
					
					EndIf

					if Alltrim(oFornecedor:cTipo) = 'X'

							Public ALTERA := .F.
							Public Inclui := .T. 							
							cOperacao := "I"
							nOpcao := 3

					EndIf

					if Empty(cMsgErro)

						aDados := {}

						// Na Inclus�o, a Loja Serie sempre 001, na Altera��o e Exclus�o Seria a loja posicionada

						aadd(aDados , {"A2_TIPO"    	, oFornecedor:cTipo												, Nil})
						
						If cOperacao == "I"
							aadd(aDados , {"A2_LOJA"   	, "01"															, NIL})
						Else
							aadd(aDados , {"A2_COD"  	, SA2->A2_COD													, NIL})
							aadd(aDados , {"A2_LOJA"   	, SA2->A2_LOJA													, NIL})
						EndIf


						cDescMun := Alltrim(oFornecedor:cCodMunicipio) 
						cCodMun := ""
						cQry	:= ""

						If Select("QRYTMP") > 0
							QRYTMP->(DbCloseArea())
						EndIf
						
						cQry := " 	SELECT CC2_EST,CC2_CODMUN,CC2_MUN  " 
						cQry += " 	FROM " + RetSqlName("CC2") + " CC2 "  
						cQry += " 	WHERE CC2.D_E_L_E_T_ <> '*' " 
						cQry += " 	AND CC2.CC2_MUN LIKE '%"+cDescMun+"%' " 

						cQry := ChangeQuery(cQry)
						TcQuery cQry New Alias "QRYTMP"   
						if QRYTMP->( !Eof() )
							While QRYTMP->( !Eof() )
								cCodMun := Alltrim(QRYTMP->CC2_CODMUN)
							QRYTMP->( DbSkip() )
							EndDo
						EndIf

						aadd(aDados , {"A2_CGC"     	, oFornecedor:cCGC												, Nil})
						aadd(aDados , {"A2_NOME"     	, oFornecedor:cNome												, Nil})
						aadd(aDados , {"A2_NREDUZ"     	, oFornecedor:cNomeFantasia 									, Nil})
						aadd(aDados , {"A2_END"   	 	, oFornecedor:cEndereco											, Nil})
						aadd(aDados , {"A2_BAIRRO"     	, oFornecedor:cBairro											, Nil})
						aadd(aDados , {"A2_EST"     	, oFornecedor:cEstado											, Nil})
						aadd(aDados , {"A2_COD_MUN"    	, cCodMun														, Nil})
						aadd(aDados , {"A2_CEP"      	, oFornecedor:cCEP 												, Nil}) 
						aadd(aDados , {"A2_DDD"     	, oFornecedor:cDDD												, Nil})
						aadd(aDados , {"A2_TEL"      	, oFornecedor:cTelefone 										, Nil})
						aadd(aDados , {"A2_INSCRM"      , oFornecedor:cInscMunicipal									, Nil})
						aadd(aDados , {"A2_INSCR"     	, oFornecedor:cInscEstadual										, Nil})
						aadd(aDados , {"A2_CODPAIS"     , oFornecedor:cPais												, Nil}) 
						aadd(aDados , {"A2_EMAIL"     	, oFornecedor:cEmail											, Nil})
						aadd(aDados , {"A2_CNAE"     	, oFornecedor:cCnae 											, Nil})
						aadd(aDados , {"A2_COMPLEM"     , oFornecedor:cComplem 											, Nil})			
						//aadd(aDados , {"A2_RT"  	    , oFornecedor:cContato 											, Nil})			
						aadd(aDados , {"A2_CONTATO"     , oFornecedor:cContato 											, Nil})
						aadd(aDados , {"A2_TPCLASS"     , 'F'				 											, Nil})					
						aadd(aDados , {"A2_GRPTRIB"     , oFornecedor:cgrptrib 											, Nil})
						aadd(aDados , {"A2_SEGMENT"     , oFornecedor:csegment 											, Nil})			
						//aadd(aDados , {"A2_SOLECM"  	, oFornecedor:csolecm 											, Nil})			
						aadd(aDados , {"A2_SIMPNAC"     , oFornecedor:csimpnac				 							, Nil})					


						// se existir campo de bloqueio para este ALIAS
						if SA2->(FieldPos("A2_MSBLQL")) > 0
							aadd(aDados , {"A2_MSBLQL"     	, iif(oFornecedor:lBloqueado,"1","2") 					, Nil})
						endif

						Conout("Opcao no Mata020: " + AllTrim(Str(nOpcao)))
						MSExecAuto({|x,y| MATA020(x,y)},aDados,nOpcao)

						if lMsErroAuto
							RollBackSX8()
							cMsgErro += " " + MostraErro("\temp") + chr(13)+chr(10)
							Conout(cMsgErro)
						Else
						
						Conout(" - Fornecedor " + SA2->A2_COD + " incluido com sucesso!")
	

							//Tratamento Para Fornecedor X - Outros
							if Alltrim(oFornecedor:cTipo) = 'X'
									cCodigo := SA2->A2_COD
									cNome   := SA2->A2_NOME
							EndIf

							ConfirmSX8()

							if Alltrim(oFornecedor:cTipo) <> 'X'
								DbSelectArea("SA2")
								SA2->(DbSetOrder(3))
								IF SA2->(MsSeek(xFilial("SA2") + oFornecedor:cCGC))
									cCodigo := SA2->A2_COD
									cNome   := SA2->A2_NOME
								EndIf
							EndIf

							if nOpcao == 3
								Conout(" - Fornecedor " + AllTrim(oFornecedor:cCGC) + " incluido com sucesso!")
							Elseif nOpcao == 4
								Conout(" - Fornecedor " + AllTrim(oFornecedor:cCGC) + " alterado com sucesso!")
							Else
								Conout(" - Fornecedor " + AllTrim(oFornecedor:cCGC) + " excluido com sucesso!")
							Endif

						Endif

					Else
						Conout(" - " + cMsgErro)
					Endif

					// verifico qual a estrutura do retorno do fornecedor
					oRetIncFornecedor := WsClassNew("StructRetIncFornecedores")

					// preencho os dados do retorno do cliente
					oRetIncFornecedor:cCodigo 	:= cCodigo
					oRetIncFornecedor:cNome 	:= cNome
					oRetIncFornecedor:lStatus 	:= iif(Empty(cMsgErro),'S','N')
					oRetIncFornecedor:cErro		:= cMsgErro

					aadd(aRetorno,oRetIncFornecedor)

				Endif

			Next nX

		Else
		
			Conout(" - Nao foram informados os fornecedores!")

			// verifico qual a estrutura do retorno do fornecedor
			oRetIncFornecedor := WsClassNew("StructRetIncFornecedores")

			// preencho os dados do retorno do cliente
			oRetIncFornecedor:cCodigo 	:= ''
			oRetIncFornecedor:cNome 	:= ''
			oRetIncFornecedor:lStatus 	:= 'N'
			oRetIncFornecedor:cErro		:= 'Dados Fornecedor Incorreto'

			aadd(aRetorno,oRetIncFornecedor)

		Endif
	
	Else

		// verifico qual a estrutura do retorno do fornecedor
		oRetIncFornecedor := WsClassNew("StructRetIncFornecedores")

		// preencho os dados do retorno do cliente
		oRetIncFornecedor:cCodigo 	:= ''
		oRetIncFornecedor:cNome 	:= ''
		oRetIncFornecedor:lStatus 	:= 'N'
		oRetIncFornecedor:cErro		:= 'Nao Foi Possivel Conectar a Empresa/Filial'

		aadd(aRetorno,oRetIncFornecedor)

	EndIf

	RetIncFornecedores:lLogin 			:= lLogin
	RetIncFornecedores:aFornecedores 	:= aRetorno

//	Reset Environment


Return(.T.)
