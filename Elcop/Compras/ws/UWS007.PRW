#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "topconn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � UWS007	 �Autor� Tarcisio Silva	 	 	�Data�11/07/2018  ���
�������������������������������������������������������������������������͹��
���Desc.     � Integra��o Protheus x Fluig								  ���
�������������������������������������������������������������������������͹��
���Uso       � Inclus�o de Solicitacao de Compras                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

WSSERVICE UWS007 DESCRIPTION "Integra��o Protheus X Fluig"

	/////////////////////////////////////////////////////////////////////////////
	///////////////////// ESTRUTURA DO PEDIDO DE COMPRAS ////////////////////////
	/////////////////////////////////////////////////////////////////////////////

	WSDATA 		IncSolicitaCompra	    	as ListaIncSC
	WSDATA 		RetIncSolicitaCompra		as ListaRetIncSolicitaCompra

	WSDATA 		IncTransferenciaEstoque    	as TransferenciaEstoque
	WSDATA 		RetInctransferenciaEstoque	as ListaRetIncTransferenciaEstoque
	
	WSDATA      EntOrdemServico             as OrdemServico
	WSDATA      RetOrdemServico             as ListaRetOrdemServico

	WSDATA		EntPecasVeiculos			as PecasVeiculos
	WSDATA 		RetPecasVeiculos			as ListaRetPecasVeiculos

	WSDATA 		EntHistoricoCompras			as HistoricoCompras
	WSDATA		RetHistoricoCompras			as ListaRetHistoricoCompras

	WSDATA		EntLocaisEstoque			as LocaisEstoque
	WSDATA 		RetLocaisEstoque			as ListaRetLocaisEstoque

	WSDATA		EntProdutoFabrica			as ProdutoFabrica
	WSDATA 		RetProdutoFabrica			as ListaRetProdutoFabrica

	WSDATA		EntEstoqueProdutos			as EstoqueProdutos
	WSDATA 		RetEstoqueProdutos			as ListaRetEstoqueProdutos

	WSDATA		EntAniversariantes			as Aniversariantes
	WSDATA 		RetAniversariantes			as ListaRetAniversariantes

	WSMETHOD 	IncluiSolicitaCompra		DESCRIPTION "Inclus�o de Solicitac�o de Compras"
	WSMETHOD    ConsultaOrdemServico        DESCRIPTION "Consulta OS"
	WSMETHOD 	ConsultaPecasVeiculos		DESCRIPTION "Consulta Produtos Veiculos"
	WSMETHOD 	ConsultaHistoricoCompras	DESCRIPTION "Consulta Hist�rico de Compras"
	WSMETHOD	ConsultaLocaisEstoque		DESCRIPTION "Consulta Locais dos Estoque"
	WSMETHOD	ConsultaProdutoFabrica		DESCRIPTION "Consulta Produtos x Fabricantes"
	WSMETHOD	ConsultaEstoqueProdutos		DESCRIPTION "Consulta Estoque dos Produtos"
	WSMETHOD	IncluiTransferenciaEstoque	DESCRIPTION "Transferencia de Estoque Protheus"
	WSMETHOD 	ConsultaAniversariantes		DESCRIPTION "Consulta Aniversariantes M�s"

ENDWSSERVICE

/////////////////////////////////////////////////////////////////////////////////////
//////////////////     ATRIBUTOS DE SOLICITACAO COMPRAS			/////////////////////
/////////////////////////////////////////////////////////////////////////////////////

WSSTRUCT ListaIncSC

//	WSDATA 		cEmissao      			as String 
	WSDATA 		cContato				as String
	WSDATA 		aIncItensSolicitaCompra	as Array of StructIncRetSolicitaCompra

ENDWSSTRUCT

WSSTRUCT StructIncRetSolicitaCompra

	WSDATA 		cCc  			as String
	WSDATA 		cObs 			as String
	WSDATA 		cProduto		as String
	WSDATA 		nQuant			as Float
	WSDATA 		cNumOs			as String 
	WSDATA		cDataNecessita	as String
	WSDATA		cCodFabrica		as String

ENDWSSTRUCT

WSSTRUCT ListaRetIncSolicitaCompra

	WSDATA 		cInformacao			as String

ENDWSSTRUCT

/////////////////////////////////////////////////////////////////////////////////////
//////////////////     TRANSFERENCIA DE ESTOQUE PROTHEUS 		/////////////////////
/////////////////////////////////////////////////////////////////////////////////////

WSSTRUCT TransferenciaEstoque

	WSDATA 		aIncItensTransferenciaEstoque	as Array of StructIncRetTransferenciaEstoque

ENDWSSTRUCT

WSSTRUCT StructIncRetTransferenciaEstoque

	WSDATA 		cLocalOrigem	as String
	WSDATA 		cLocalDestino	as String
	WSDATA 		cProduto		as String
	WSDATA		cDescricao		as String
//	WSDATA		cUM				as String
	WSDATA 		nQuant			as Float

ENDWSSTRUCT

WSSTRUCT ListaRetIncTransferenciaEstoque

	WSDATA 		cInformacao			as String

ENDWSSTRUCT

/////////////////////////////////////////////////////////////////////////////////////
//////////////////     CONSULTA ORDEM DE SERVICO		 		/////////////////////
/////////////////////////////////////////////////////////////////////////////////////

WSSTRUCT OrdemServico

	WSDATA cOS                          as String OPTIONAL

ENDWSSTRUCT

WSSTRUCT ListaRetOrdemServico

	WSDATA cRetorno                     as String
	WSDATA aOrdemServico				as Array of StructRetOrdemServico OPTIONAL

ENDWSSTRUCT

WSSTRUCT StructRetOrdemServico

	WSDATA cCcusto                      as String
	WSDATA cNumOS                       as String
	WSDATA cPlaca						as String
	WSDATA cNomeVeiculo					as String

ENDWSSTRUCT

/////////////////////////////////////////////////////////////////////////////////////
//////////////////     CONSULTA DE PRODUTOS			/////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

WSSTRUCT PecasVeiculos

	WSDATA 		cDescricao			as String OPTIONAL

ENDWSSTRUCT

WSSTRUCT ListaRetPecasVeiculos

	WSDATA 		cRetorno			as String
	WSDATA 		aPecasVeiculos		as Array of StructRetPecasVeiculos	OPTIONAL

ENDWSSTRUCT

WSSTRUCT StructRetPecasVeiculos

	WSDATA 		cCodigo				as String
	WSDATA 		cDescricao			as String

ENDWSSTRUCT

/////////////////////////////////////////////////////////////////////////////////////
//////////////////     CONSULTA DE HIST�RICO DE COMPRAS    //////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

WSSTRUCT HistoricoCompras

	WSDATA 		cCodProduto			as String OPTIONAL

ENDWSSTRUCT

WSSTRUCT ListaRetHistoricoCompras

	WSDATA 		cRetorno			as String
	WSDATA 		aHistoricoCompras	as Array of StructRetHistoricoCompras	OPTIONAL

ENDWSSTRUCT

WSSTRUCT StructRetHistoricoCompras

	WSDATA 		cNomeFornec			as String
	WSDATA 		cUMProduto			as String
	WSDATA 		nQuantidade			as Float
	WSDATA 		cVlrUnitario		as String
	WSDATA 		cDataEntrada		as String
	WSDATA 		cTipoOper			as String

ENDWSSTRUCT

/////////////////////////////////////////////////////////////////////////////////////
//////////////////     CONSULTA DE LOCAIS DE ESTOQUE   //////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

WSSTRUCT LocaisEstoque

	WSDATA 		cDescricao			as String OPTIONAL

ENDWSSTRUCT

WSSTRUCT ListaRetLocaisEstoque

	WSDATA 		cRetorno			as String
	WSDATA 		aLocaisEstoque		as Array of StructRetLocaisEstoque	OPTIONAL

ENDWSSTRUCT

WSSTRUCT StructRetLocaisEstoque

	WSDATA 		cCodigo				as String
	WSDATA 		cDescricao			as String

ENDWSSTRUCT

/////////////////////////////////////////////////////////////////////////////////////
//////////////////     CONSULTA PRODUTOS X FABRICANTES  /////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

WSSTRUCT ProdutoFabrica

	WSDATA 		cDescricao			as String OPTIONAL

ENDWSSTRUCT

WSSTRUCT ListaRetProdutoFabrica

	WSDATA 		cRetorno			as String
	WSDATA 		aProdutoFabrica		as Array of StructRetProdutoFabrica	OPTIONAL

ENDWSSTRUCT

WSSTRUCT StructRetProdutoFabrica

	WSDATA 		cCodigo				as String
	WSDATA 		cDescricao			as String

ENDWSSTRUCT

/////////////////////////////////////////////////////////////////////////////////////
//////////////////     CONSULTA DE ESTOQUE PRODUTOS    //////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

WSSTRUCT EstoqueProdutos

	WSDATA 		cUsuarioFluig			as String OPTIONAL

ENDWSSTRUCT

WSSTRUCT ListaRetEstoqueProdutos

	WSDATA 		cRetorno			as String
	WSDATA 		aEstoqueProdutos	as Array of StructRetEstoqueProdutos	OPTIONAL

ENDWSSTRUCT

WSSTRUCT StructRetEstoqueProdutos

	WSDATA 		cCodigo				as String
	WSDATA 		cDescricao			as String
	WSDATA		cLocalEstoque		as String
	WSDATA		cUnidade			as String
	WSDATA		nQtdeEstoque		as Float

ENDWSSTRUCT

/////////////////////////////////////////////////////////////////////////////////////
//////////////////     CONSULTA ANIVERSARIANTES        //////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

WSSTRUCT Aniversariantes

	WSDATA 		cMes			as String OPTIONAL

ENDWSSTRUCT

WSSTRUCT ListaRetAniversariantes

	WSDATA 		cRetorno			as String
	WSDATA 		aAniversariantes	as Array of StructRetAniversariantes	OPTIONAL

ENDWSSTRUCT

WSSTRUCT StructRetAniversariantes

	WSDATA 		cMatricula			as String
	WSDATA 		cNome				as String
	WSDATA		cAdmissao			as String
	WSDATA		cNascimento			as String
	WSDATA		cCentroCusto		as String

ENDWSSTRUCT


/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
������������������������������������������������������������������������������͹ͱ�
���Programa  � IncluiSolicitaoCompra �Autor�  		     	   �Data�11/07/2018 ���
�������������������������������������������������������������������������������͹��
���Desc.     � Metodo responsavel por efetuar a inclus�o do Solicit de compras.	���
�������������������������������������������������������������������������������͹��
���Uso       � Elcop.		                                              		���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/

WSMETHOD ConsultaOrdemServico WSRECEIVE EntOrdemServico WSSEND RetOrdemServico WSSERVICE UWS007

	Local aArea		:= GetArea()
	Local aRetorno	:= {}
	Local oDadosEnt := Nil
	Local oDadosRet	:= Nil
	Local oStructSer:= Nil
	Local cEOL 		:= Chr(13)+Chr(10)
	Local cQry		:= ""
	Local cMsgRet	:= ""
	

	oDadosEnt := EntOrdemServico
	oDadosRet := RetOrdemServico

	Conout("############ Web Services para Consulta de OS  ############")

	cQry := " SELECT TOP 30 TJ_ORDEM, TJ_CCUSTO, T9_PLACA, T9_NOME " + cEOL
	cQry += " FROM " + RetSqlName("STJ") + " STJ " + cEOL
	cQry += " INNER JOIN "+RetSqlName("ST9")+ " ST9 "+"ON (ST9.D_E_L_E_T_ = ' ' AND ST9.T9_CODBEM = STJ.TJ_CODBEM)  " + cEOL
	cQry += " WHERE STJ.D_E_L_E_T_ <> '*' AND STJ.TJ_SITUACA = 'L'														" + cEOL

	if !empty(AllTrim(oDadosEnt:cOS))
		cQry += " AND TJ_ORDEM LIKE '%"+AllTrim(oDadosEnt:cOS)+"%'								" + cEOL
	endif

	TcQuery cQry New Alias "QRYSTJ"

	if QRYSTJ->( !Eof() )

		While QRYSTJ->( !Eof() )

			oStructSer	:= NIL
			oStructSer	:= WsClassNew("StructRetOrdemServico")

			oStructSer:cNumOS		:= QRYSTJ->TJ_ORDEM
			oStructSer:cCcusto		:= QRYSTJ->TJ_CCUSTO
			oStructSer:cPlaca		:= QRYSTJ->T9_PLACA
			oStructSer:cNomeVeiculo := QRYSTJ->T9_NOME

			aAdd(aRetorno,oStructSer)

			QRYSTJ->( DbSkip() )

		EndDo

		cMsgRet	:= " Consulta realizada com sucesso!"
		Conout(cMsgRet)
		oDadosRet:cRetorno  	:= cMsgRet
		oDadosRet:aOrdemServico := aRetorno
	else

		cMsgRet	:= "N�o foi encontrado OS nos parametros informados"
		oDadosRet:cRetorno := cMsgRet
		Conout(cMsgRet)

	endif
	QRYSTJ->(DbCloseArea())
	RestArea(aArea)

Return(.T.)

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
������������������������������������������������������������������������������͹ͱ�
���Programa  � IncluiSolicita��o de Compras �Autor� 		   �Data�11/07/2018 ���
�������������������������������������������������������������������������������͹��
���Desc.     � Metodo responsavel por efetuar a inclus�o do pedido de compras.	���
�������������������������������������������������������������������������������͹��
���Uso       � Elcop.		                                              		���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/

WSMETHOD IncluiSolicitaCompra WSRECEIVE IncSolicitaCompra WSSEND RetIncSolicitaCompra WSSERVICE UWS007
	Local cQry			:= ""
	Local cCusto 		:= ""
	Local oCabPc 		:= Nil
	Local oItensPc		:= Nil
	Local aCabec		:= {}
	Local aItens		:= {}
	Local aLinha		:= {}
	Local nX			:= 1
	Local cMsgRet		:= ""
	Local cEOL 			:= Chr(13)+Chr(10)
	Local cTipo			:= ""

	Default cFilAnt 	:= ""

	Conout("############ Web Services para Inclus�o Solicitacao de compras ############")

	Private lMsErroAuto := .F.

	oCabPc 		:= IncSolicitaCompra
	oItensPc	:= IncSolicitaCompra:aIncItensSolicitaCompra

	//aadd(aCabec,{"C1_NUM" 		,cPedido         		,Nil})
	aadd(aCabec,{"C1_SOLICIT" 	, oCabPc:cContato			,Nil})
	aadd(aCabec,{"C1_EMISSAO" 	, dDataBase /*oCabPc:cEmissao*/		    ,Nil})
	
	for nX := 1 to len(oItensPc)
	
		cCusto := ""
		
		if !empty(oItensPc[nX]:cNumOS)
		
			If Select("QRYSA2") > 0
		
				QRYSA2->(DbCloseArea())
		
			EndIf

			cQry := " SELECT TJ_ORDEM, TJ_CCUSTO				 				" + cEOL
			cQry += " FROM " + RetSqlName("STJ") + "  							" + cEOL
			cQry += " WHERE D_E_L_E_T_ <> '*' 									" + cEOL
			cQry += " AND TJ_ORDEM LIKE '%"+AllTrim(oItensPc[nX]:cNumOS)+"%'	" + cEOL
			
			TcQuery cQry New Alias "QRYSA2"
			
			if !QRYSA2->(Eof())

				cCusto := AllTrim(QRYSA2->TJ_CCUSTO)

			endif
			
		endif

		aadd(aLinha,{"C1_ITEM"		,StrZero(nX,4)										 , Nil})
		aadd(aLinha,{"C1_PRODUTO"	,oItensPc[nX]:cProduto								 , Nil})
		aadd(aLinha,{"C1_QUANT"		,oItensPc[nX]:nQuant								 , Nil})
//		aadd(aLinha,{"C1_XTIPPRO"	,Posicione("SB1",1,XFILIAL("SB1")+oItensPc[nX]:cProduto,"B1_TIPO"), Nil})
		
		if !empty(cCusto)
		
			aadd(aLinha,{"C1_CC"	,cCusto						,Nil})
		
		else
		
			aadd(aLinha,{"C1_CC"	,oItensPc[nX]:cCc	,Nil})
		
		endif
		//PadR(AllTrim(oItensPc[nX]:cNumOS),TamSx3("C1_OS")[1])
		aadd(aLinha,{"C1_OS"	    ,oItensPc[nX]:cNumOS		,Nil})
		aadd(aLinha,{"C1_OBS"	    ,oItensPc[nX]:cObs			,Nil})
		aadd(aLinha,{"C1_DATPRF"	,ctod(substr(oItensPc[nX]:cDataNecessita,9,2)+"/"+;
										  substr(oItensPc[nX]:cDataNecessita,6,2)+"/"+;
										  substr(oItensPc[nX]:cDataNecessita,1,4)),Nil})
		
		cTipo := Posicione("SB1",1,XFILIAL("SB1")+oItensPc[nX]:cProduto,"B1_TIPO")

		if alltrim(cTipo) $ "M1-M2-M3"
			aadd(aLinha,{"C1_APROV"	    ,"B"					,Nil})
		else
			aadd(aLinha,{"C1_APROV"	    ,"L"					,Nil})
		endif

	//	aadd(aLinha,{"C1_XFABRIC"	    ,oItensPc[nX]:cCodFabrica	,Nil})

		aadd(aItens,aLinha)
		aLinha := {}

	Next nX

	Begin Transaction
		MSExecAuto({|x,y| mata110(x,y)},aCabec,aItens,3)

		If !lMsErroAuto

			cMsgRet := ("Solicitacao de Compras Incluida com Sucesso!" + SC1->C1_NUM)
			Conout(cMsgRet)
			RetIncSolicitaCompra:cInformacao	:= cMsgRet
			ConfirmSx8()

		Else

			cMsgRet := MostraErro("\temp") + chr(13)+chr(10) 
			Conout(cMsgRet)
			RetIncSolicitaCompra:cInformacao	:= cMsgRet
			RollbackSx8()
			DisarmTransaction()

		EndIf

	End Transaction 

Return(!lMsErroAuto)


/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
������������������������������������������������������������������������������͹ͱ�
���Programa  � Inclui Transferencia Estoque �Autor� 		   �Data�11/07/2018 ���
�������������������������������������������������������������������������������͹��
���Desc.     � Metodo responsavel por efetuar a inclus�o transferencia Estoque.	���
�������������������������������������������������������������������������������͹��
���Uso       � Elcop.		                                              		���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/

WSMETHOD IncluiTransferenciaEstoque WSRECEIVE IncTransferenciaEstoque WSSEND RetInctransferenciaEstoque WSSERVICE UWS007
	Local oCab 			:= Nil
	Local oItens		:= Nil
	Local aAuto			:= {}
	Local aLinha		:= {}
	Local nX			:= 1
	Local cMsgRet		:= ""
	Local nOpcAuto 		:= 3 // Inclusao

	Default cFilAnt 	:= ""

	Private lMsErroAuto := .F.

	Conout("############ Web Services para Inclus�o Transferencia de Estoque ############")

	oCab 		:= IncTransferenciaEstoque
	oItens		:= IncTransferenciaEstoque:aIncItensTransferenciaEstoque

	//Cabecalho a Incluir
	aadd(aAuto,{GetSxeNum("SD3","D3_DOC"),dDataBase}) //Cabecalho

	//Itens a Incluir
	for nX := 1 to len(oItens)
    	aLinha := {}
    	
		//Origem
    	aadd(aLinha,{"ITEM"			,'00'+cvaltochar(nX)		, Nil})
    	aadd(aLinha,{"D3_COD"		, oItens[nX]:cProduto		, Nil}) //Cod Produto origem
    	aadd(aLinha,{"D3_DESCRI"	, oItens[nX]:cDescricao		, Nil}) //descr produto origem
    	aadd(aLinha,{"D3_UM"		, Posicione("SB1",1,xFilial("SB1")+oItens[nX]:cProduto,"B1_UM"), Nil}) //unidade medida origem
    	aadd(aLinha,{"D3_LOCAL"		, oItens[nX]:cLocalOrigem	, Nil}) //armazem origem
    	aadd(aLinha,{"D3_LOCALIZ"	, ""						, Nil}) //Informar endereço origem
    
    	//Destino
    	aadd(aLinha,{"D3_COD"		, oItens[nX]:cProduto		, Nil}) //cod produto destino
    	aadd(aLinha,{"D3_DESCRI"	, oItens[nX]:cDescricao		, Nil}) //descr produto destino
    	aadd(aLinha,{"D3_UM"		, Posicione("SB1",1,xFilial("SB1")+oItens[nX]:cProduto,"B1_UM"), Nil}) //unidade medida destino
    	aadd(aLinha,{"D3_LOCAL"		, oItens[nX]:cLocalDestino	, Nil}) //armazem destino
    	aadd(aLinha,{"D3_LOCALIZ"	, ""						, Nil}) //Informar endereço destino
    
    	aadd(aLinha,{"D3_NUMSERI"	, ""						, Nil}) //Numero serie
    	aadd(aLinha,{"D3_LOTECTL"	, ""						, Nil}) //Lote Origem
    	aadd(aLinha,{"D3_NUMLOTE"	, ""						, Nil}) //sublote origem
    	aadd(aLinha,{"D3_DTVALID"	, ""						, Nil}) //data validade
    	aadd(aLinha,{"D3_POTENCI"	, 0							, Nil}) // Potencia
    	aadd(aLinha,{"D3_QUANT"		, oItens[nX]:nQuant			, Nil}) //Quantidade
    	aadd(aLinha,{"D3_QTSEGUM"	, 0							, Nil}) //Seg unidade medida
    	aadd(aLinha,{"D3_ESTORNO"	, ""						, Nil}) //Estorno
    	aadd(aLinha,{"D3_NUMSEQ"	, ""						, Nil}) // Numero sequencia D3_NUMSEQ
    
    	aadd(aLinha,{"D3_LOTECTL"	, ""						, Nil}) //Lote destino
    	aadd(aLinha,{"D3_NUMLOTE"	, ""						, Nil}) //sublote destino
    	aadd(aLinha,{"D3_DTVALID"	, ""						, Nil}) //validade lote destino
    	aadd(aLinha,{"D3_ITEMGRD"	, ""						, Nil}) //Item Grade
    
    	aadd(aLinha,{"D3_CODLAN"	, ""						, Nil}) //cat83 prod origem
    	aadd(aLinha,{"D3_CODLAN"	, ""						, Nil}) //cat83 prod destino
    
    	aAdd(aAuto,aLinha)

		SB2->(DbSetOrder(1))
		if !SB2->(DBSEEK(xFilial("SB2") + oItens[nX]:cProduto + oItens[nX]:cLocalDestino ))
			CriaSB2( oItens[nX]:cProduto, oItens[nX]:cLocalDestino)
		endif
	Next nX

	Begin Transaction
	
		MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcAuto)

		if !lMsErroAuto

    		conout("Inclus�o de movimenta��o multipla efetuada com sucesso")
			Conout(cMsgRet)
			RetInctransferenciaEstoque:cInformacao	:= cMsgRet
			ConfirmSx8()

		else
			cMsgRet := MostraErro("\temp") + chr(13)+chr(10) 
			Conout(cMsgRet)
			RetInctransferenciaEstoque:cInformacao	:= cMsgRet
			RollbackSx8()
			DisarmTransaction()
�		EndIf

	end Transaction
	
Return(!lMsErroAuto)


/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
������������������������������������������������������������������������������͹ͱ�
���Programa  � Consulta Produtos    � Autor � Sinval Gedolin  �Data� 15/10/2020 ���
�������������������������������������������������������������������������������͹��
���Desc.     � M�todo de consulta Fornecedores				 					���
�������������������������������������������������������������������������������͹��
���Uso       � 				                                             		���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/

WSMETHOD ConsultaPecasVeiculos WSRECEIVE EntPecasVeiculos WSSEND RetPecasVeiculos WSSERVICE UWS007

	Local aArea		:= GetArea()
	Local aRetorno	:= {}
	Local oDadosEnt := Nil
	Local oDadosRet	:= Nil
	Local oStructPrd:= Nil
	Local cEOL 		:= Chr(13)+Chr(10)
	Local cQry		:= ""
	Local cMsgRet	:= ""

	oDadosEnt := EntPecasVeiculos
	oDadosRet := RetPecasVeiculos

	Conout("############ Web Services para Consulta de Produtos ############")

	cQry := " SELECT TOP 300 B1_COD, B1_DESC								" + cEOL
	cQry += " FROM " + RetSqlName("SB1") + " 									" + cEOL
	cQry += " WHERE D_E_L_E_T_ <> '*' AND B1_XBLOQ = '2' AND B1_TIPO IN ('PV','SV') " + cEOL
	if !empty(AllTrim(oDadosEnt:cDescricao))

		cQry += " AND B1_DESC LIKE '%"+AllTrim(oDadosEnt:cDescricao)+"%'						" + cEOL

	endif
	cQry += " AND B1_FILIAL = '"+xFilial("SB1")+"' 												" + cEOL


	If Select("QRYSA2") > 0
		QRYSA2->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "QRYSA2"

	if QRYSA2->( !Eof() )

		While QRYSA2->( !Eof() )
			oStructPrd	:= NIL
			oStructPrd 	:= WsClassNew("StructRetPecasVeiculos")

			oStructPrd:cCodigo		:= QRYSA2->B1_COD
			oStructPrd:cDescricao	:= QRYSA2->B1_DESC

			aAdd(aRetorno,oStructPrd)

			QRYSA2->( DbSkip() )

		EndDo

		cMsgRet	:= " Consulta realizada com sucesso!"
		Conout(cMsgRet)
		oDadosRet:cRetorno  	 := cMsgRet
		oDadosRet:aPecasVeiculos := aRetorno

	else

		cMsgRet	:= "N�o foi encontrado produto nos parametros informados"
		oDadosRet:cRetorno := cMsgRet
		Conout(cMsgRet)

	endif
	QRYSA2->(DbCloseArea())
	
	RestArea(aArea)

Return(.T.)

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
������������������������������������������������������������������������������͹ͱ�
���Programa  � Hist�rico Compras    � Autor � Sinval Gedolin  �Data� 15/10/2020 ���
�������������������������������������������������������������������������������͹��
���Desc.     � Consulta Hist�rico de Compras do Produto		 					���
�������������������������������������������������������������������������������͹��
���Uso       � 				                                             		���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/

WSMETHOD ConsultaHistoricoCompras WSRECEIVE EntHistoricoCompras WSSEND RetHistoricoCompras WSSERVICE UWS007

	Local aArea		:= GetArea()
	Local aRetorno	:= {}
	Local oDadosEnt := Nil
	Local oDadosRet	:= Nil
	Local oStructPrd:= Nil
	Local cEOL 		:= Chr(13)+Chr(10)
	Local cQry		:= ""
	Local cMsgRet	:= ""

	oDadosEnt := EntHistoricoCompras
	oDadosRet := RetHistoricoCompras

	Conout("############ Web Services para Consulta Hist�rico de Compras ############")

	cQry := " SELECT TOP 30 
	cQry += " SA2.A2_NOME, SD1.D1_UM, SD1.D1_QUANT, Round(SD1.D1_VUNIT,3) D1_VUNIT, SD1.D1_DTDIGIT, SF4.F4_TEXTO								" + cEOL
	cQry += " FROM "+ RetSqlName("SD1") + " SD1 																			" + cEOL
	cQry += " INNER JOIN "+RetSqlName("SB1") + " SB1 ON (SB1.D_E_L_E_T_ = ' ' AND SB1.B1_COD = SD1.D1_COD)					" + cEOL 
	cQry += " INNER JOIN "+RetSqlName("SA2") + " SA2 ON (SA2.D_E_L_E_T_ = ' ' AND SA2.A2_COD = SD1.D1_FORNECE AND SA2.A2_LOJA = SD1.D1_LOJA) " + cEOL
	cQry += " INNER JOIN "+RetSqlName("SF4") + " SF4 ON (SF4.D_E_L_E_T_ = ' ' AND SF4.F4_CODIGO = SD1.D1_TES)				" + cEOL 
	cQry += " WHERE SD1.D_E_L_E_T_= ' ' AND SD1.D1_COD = '"+AllTrim(oDadosEnt:cCodProduto)+"' 														" + cEOL 
//	cQry += " WHERE SD1.D_E_L_E_T_= ' ' AND SD1.D1_COD = '000453' 														" + cEOL 
	cQry += " ORDER BY D1_DTDIGIT DESC

	If Select("QRYSD1") > 0
		QRYSD1->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "QRYSD1"
//	TCSetField("QRYSD1", "D1_DTDIGIT", "D")
	
	if QRYSD1->( !Eof() )

		While QRYSD1->( !Eof() )
			oStructPrd	:= NIL
			oStructPrd 	:= WsClassNew("StructRetHistoricoCompras")

			oStructPrd:cNomeFornec	:= QRYSD1->A2_NOME
			oStructPrd:cUMProduto	:= QRYSD1->D1_UM
			oStructPrd:nQuantidade	:= QRYSD1->D1_QUANT
			oStructPrd:cVlrUnitario	:= transform(QRYSD1->D1_VUNIT,"@e 999,999,999.999")
			oStructPrd:cDataEntrada	:= 	substr(QRYSD1->D1_DTDIGIT,7,2)+"/"+;
										substr(QRYSD1->D1_DTDIGIT,5,2)+"/"+;
										substr(QRYSD1->D1_DTDIGIT,1,4)
			oStructPrd:cTipoOper	:= QRYSD1->F4_TEXTO

			aAdd(aRetorno,oStructPrd)

			QRYSD1->( DbSkip() )

		EndDo

		cMsgRet	:= " Consulta realizada com sucesso!"
		Conout(cMsgRet)
		oDadosRet:cRetorno  	 	:= cMsgRet
		oDadosRet:aHistoricoCompras := aRetorno

	else

		cMsgRet	:= "N�o foi encontrado produto nos parametros informados"
		oDadosRet:cRetorno := cMsgRet
		Conout(cMsgRet)

	endif
	QRYSD1->(DbCloseArea())
	
	RestArea(aArea)

Return(.T.)

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
������������������������������������������������������������������������������͹ͱ�
���Programa  � Consulta Locais Estoque � Autor � Sinval Gedolin  �Data� 15/10/2020 ���
�������������������������������������������������������������������������������͹��
���Desc.     � M�todo de consulta Locais de Estoque			 					���
�������������������������������������������������������������������������������͹��
���Uso       � 				                                             		���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/

WSMETHOD ConsultaLocaisEstoque WSRECEIVE EntLocaisEstoque WSSEND RetLocaisEstoque WSSERVICE UWS007

	Local aArea		:= GetArea()
	Local aRetorno	:= {}
	Local oDadosEnt := Nil
	Local oDadosRet	:= Nil
	Local oStructNNR:= Nil
	Local cEOL 		:= Chr(13)+Chr(10)
	Local cQry		:= ""
	Local cMsgRet	:= ""

	oDadosEnt := EntLocaisEstoque
	oDadosRet := RetLocaisEstoque

	Conout("############ Web Services para Consulta dos Locais de Estoque ############")

	cQry := " SELECT TOP 30 NNR_CODIGO, NNR_DESCRI						    " + cEOL
	cQry += " FROM " + RetSqlName("NNR") + " 								" + cEOL
	cQry += " WHERE D_E_L_E_T_ <> '*' AND NNR_FILIAL = '0101'				" + cEOL
	if !empty(AllTrim(oDadosEnt:cDescricao))

		cQry += " AND NNR_DESCRI LIKE '%"+AllTrim(oDadosEnt:cDescricao)+"%'	" + cEOL

	endif
//	cQry += " AND B1_FILIAL = '"+xFilial("SB1")+"' 							" + cEOL

	If Select("QRYNNR") > 0
		QRYNNR->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "QRYNNR"

	if QRYNNR->( !Eof() )

		While QRYNNR->( !Eof() )
			oStructNNR	:= NIL
			oStructNNR 	:= WsClassNew("StructRetLocaisEstoque")

			oStructNNR:cCodigo		:= QRYNNR->NNR_CODIGO
			oStructNNR:cDescricao	:= QRYNNR->NNR_DESCRI

			aAdd(aRetorno,oStructNNR)

			QRYNNR->( DbSkip() )

		EndDo

		cMsgRet	:= " Consulta realizada com sucesso!"
		Conout(cMsgRet)
		oDadosRet:cRetorno  	 := cMsgRet
		oDadosRet:aLocaisEstoque := aRetorno

	else

		cMsgRet	:= "N�o foi encontrado Locais de Estoque nos parametros informados"
		oDadosRet:cRetorno := cMsgRet
		Conout(cMsgRet)

	endif
	QRYNNR->(DbCloseArea())
	
	RestArea(aArea)

Return(.T.)

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
������������������������������������������������������������������������������͹ͱ�
���Programa  � Consulta Produtos x Fabricantes � Autor � Sinval Gedolin  �Data� 15/10/2020 ���
�������������������������������������������������������������������������������͹��
���Desc.     � M�todo de consulta Produtos x Fabricantes	 					���
�������������������������������������������������������������������������������͹��
���Uso       � 				                                             		���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/

WSMETHOD ConsultaProdutoFabrica WSRECEIVE EntProdutoFabrica WSSEND RetProdutoFabrica WSSERVICE UWS007
	Local aArea		:= GetArea()
	Local aRetorno	:= {}
	Local oDadosEnt := Nil
	Local oDadosRet	:= Nil
	Local oStructZCS:= Nil
	Local cEOL 		:= Chr(13)+Chr(10)
	Local cQry		:= ""
	Local cMsgRet	:= ""

	oDadosEnt := EntProdutoFabrica
	oDadosRet := RetProdutoFabrica

	Conout("############ Web Services para Consulta de Produtos x Fabricantes ############")

	cQry := " SELECT ZCS_CODIGO, ZCS_FABRIC									" + cEOL
	cQry += " FROM " + RetSqlName("ZCS") + " ZCS " + "  					" + cEOL
	cQry += " WHERE D_E_L_E_T_ <> '*' AND ZCS_BLOQ <> 'S'					" + cEOL
	if !empty(AllTrim(oDadosEnt:cDescricao))

		cQry += " AND ZCS_FABRIC LIKE '%"+AllTrim(oDadosEnt:cDescricao)+"%'	" + cEOL

	endif

	If Select("QRYZCS") > 0
		QRYZCS->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "QRYZCS"

	if QRYZCS->( !Eof() )

		While QRYZCS->( !Eof() )
			oStructZCS	:= NIL
			oStructZCS 	:= WsClassNew("StructRetProdutoFabrica")

			oStructZCS:cCodigo		:= QRYZCS->ZCS_CODIGO
			oStructZCS:cDescricao	:= QRYZCS->ZCS_DESCRI

			aAdd(aRetorno,oStructZCS)

			QRYZCS->( DbSkip() )

		EndDo

		cMsgRet	:= " Consulta realizada com sucesso!"
		Conout(cMsgRet)
		oDadosRet:cRetorno  	 := cMsgRet
		oDadosRet:aLocaisEstoque := aRetorno

	else

		cMsgRet	:= "N�o foi encontrado Fabricantes para este Produto"
		oDadosRet:cRetorno := cMsgRet
		Conout(cMsgRet)

	endif
	QRYZCS->(DbCloseArea())
	
	RestArea(aArea)

Return(.T.)

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
������������������������������������������������������������������������������͹ͱ�
���Programa  � Estoque De produtos  � Autor � Sinval Gedolin  �Data� 15/10/2020 ���
�������������������������������������������������������������������������������͹��
���Desc.     � Consulta Estoque de produtos- SB2      		 					���
�������������������������������������������������������������������������������͹��
���Uso       � 				                                             		���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/

WSMETHOD ConsultaEstoqueProdutos WSRECEIVE EntEstoqueProdutos WSSEND RetEstoqueProdutos WSSERVICE UWS007

	Local aArea		:= GetArea()
	Local aRetorno	:= {}
	Local oDadosEnt := Nil
	Local oDadosRet	:= Nil
	Local oStructEst:= Nil
	Local cEOL 		:= Chr(13)+Chr(10)
	Local cQry		:= ""
	Local cMsgRet	:= ""
	Local cLocalFluig := "ZZ"
	
	oDadosEnt := EntEstoqueProdutos
	oDadosRet := RetEstoqueProdutos

	Conout("############ Web Services para Consulta Estoque Produtos ############")

	cLocalFluig := alltrim(POSICIONE("ZC3",1,xFilial("ZC3")+oDadosEnt:cUsuarioFluig,"ZC3_LOCAL"))

	cQry := " SELECT SB2.B2_FILIAL, SB2.B2_LOCAL, SB2.B2_COD, SB1.B1_DESC, SB1.B1_UM, SB2.B2_QATU 			" + cEOL
	cQry += " FROM "+ RetSqlName("SB2") + " SB2 															" + cEOL
	cQry += " INNER JOIN "+RetSqlName("SB1") + " SB1 ON (SB1.D_E_L_E_T_ = ' ' AND SB1.B1_COD = SB2.B2_COD)	" + cEOL
	cQry += " WHERE SB2.D_E_L_E_T_ = ' ' AND SB2.B2_LOCAL LIKE "+"'%"+cLocalFluig+"%'"+"			  		" + cEOL
	cQry += " AND SB2.B2_QATU > 0 AND SB2.B2_FILIAL = '0101'	  											" + cEOL
	cQry += " ORDER BY B2_LOCAL, B1_DESC																	" + cEOL

	If Select("QRYSB2") > 0
		QRYSB2->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "QRYSB2"
	
	if QRYSB2->( !Eof() )

		While QRYSB2->( !Eof() )
			oStructEst	:= NIL
			oStructEst 	:= WsClassNew("StructRetEstoqueProdutos")

			oStructEst:cCodigo		:= QRYSB2->B2_COD
			oStructEst:cDescricao	:= QRYSB2->B1_DESC
			oStructEst:cUnidade		:= QRYSB2->B1_UM
			oStructEst:nQtdeEstoque	:= QRYSB2->B2_QATU
			oStructEst:cLocalEstoque:= QRYSB2->B2_LOCAL

			aAdd(aRetorno,oStructEst)

			QRYSB2->( DbSkip() )

		EndDo

		cMsgRet	:= " Consulta de Produto em Estoque realizada com sucesso!"
		Conout(cMsgRet)
		oDadosRet:cRetorno  	 	:= cMsgRet
		oDadosRet:aEstoqueProdutos	:= aRetorno

	else

		cMsgRet	:= "N�o foi encontrado produto nos parametros informados"
		oDadosRet:cRetorno := cMsgRet
		Conout(cMsgRet)

	endif
	QRYSB2->(DbCloseArea())
	
	RestArea(aArea)

Return(.T.)

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
������������������������������������������������������������������������������͹ͱ�
���Programa  �                       � Autor � Sinval Gedolin  �Data�   03/2021 ���
�������������������������������������������������������������������������������͹��
���Desc.     � Consulta Aniversariantes do M�s       		 					���
�������������������������������������������������������������������������������͹��
���Uso       � 				                                             		���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/

WSMETHOD ConsultaAniversariantes WSRECEIVE EntAniversariantes WSSEND RetAniversariantes WSSERVICE UWS007

	Local aArea		:= GetArea()
	Local aRetorno	:= {}
	Local oDadosEnt := Nil
	Local oDadosRet	:= Nil
	Local oStruct	:= Nil
	Local cEOL 		:= Chr(13)+Chr(10)
	Local cQry		:= ""
	Local cMsgRet	:= ""
	
	oDadosEnt := EntAniversariantes
	oDadosRet := RetAniversariantes

	Conout("############ Web Services para Consulta Aniversariantes do M�s ############")

	cQry := " SELECT SRA.RA_MAT, SRA.RA_NOME, SRA.RA_NASC, SRA.RA_ADMISSA, SRA.RA_CC, CTT.CTT_DESC01		" + cEOL
	cQry += " FROM "+ RetSqlName("SRA") + " SRA 															" + cEOL
	cQry += " INNER JOIN "+RetSqlName("CTT") + " CTT ON (CTT.D_E_L_E_T_ = ' ' AND CTT.CTT_CUSTO = SRA.RA_CC	" + cEOL
	cQry += " WHERE SRA.D_E_L_E_T_ = ' ' AND SRA.RA_SITFOL <> 'D' 									  		" + cEOL
	cQry += " AND SUBSTRING(SRA.RA_NASC,5,2) = '"+oDadosEnt:cMes+"' 										" + cEOL
	cQry += " ORDER BY RA_NASC																				" + cEOL

	If Select("QRYSRA") > 0
		QRYSRA->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "QRYSRA"
	
	if QRYSRA->( !Eof() )

		While QRYSRA->( !Eof() )
			oStruct		:= NIL
			oStruct 	:= WsClassNew("StructRetAniversariantes")

			oStruct:cMatricula	:= QRYSRA->RA_MAT
			oStruct:cNome		:= QRYSRA->RA_NOME
			oStruct:cAdmissao	:= dtoc(stod(QRYSRA->RA_ADMISSA))
			oStruct:cNascimento	:= dtoc(stod(QRYSRA->RA_NASC))
			oStruct:cCentroCusto:= QRYSRA->RA_CC+" "+QRYSRA->CTT_DESC01

			aAdd(aRetorno,oStruct)

			QRYSRA->( DbSkip() )

		EndDo

		cMsgRet	:= " Consulta dos Aniversariantes do M�s realizada com sucesso!"
		Conout(cMsgRet)
		oDadosRet:cRetorno  	 	:= cMsgRet
		oDadosRet:aAniversariantes	:= aRetorno

	else

		cMsgRet	:= "N�o foi encontrado produto nos parametros informados"
		oDadosRet:cRetorno := cMsgRet
		Conout(cMsgRet)

	endif
	QRYSRA->(DbCloseArea())
	
	RestArea(aArea)

Return(.T.)
