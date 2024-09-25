#INCLUDE "PROTHEUS.CH"
#INCLUDE "NGMUCH.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} NGMURetIns
Retorna codigo do produto para um determinado insumo e realiza os
tratamentos necessarios para integracao com backoffice.

@param cTipSTL tipo de insumo (TL_TIPOREG)
@param cCodSTL codigo do insumo (TL_CODIGO)
@author Felipe Nathan Welter
@author Hugo Rizzo Pereira
@since 18/07/12
@version MP11
@return cProduto Codigo do Produto.
/*/
//---------------------------------------------------------------------
Function NGMURetIns(cTipSTL, cCodSTL)

	Local cProduto := ""
	Local cRefer, cAlias, cField, cValInt, cValExt

	Do Case
		Case cTipSTL == "P" // Insumo Produto

			cProduto := cCodSTL

		Case cTipSTL == "T" // Terceiros

			cProduto := GetMv("MV_PRODTER") // Produto Terceiros
			cProduto := cProduto+Space(Len(SB1->B1_COD)-Len(cProduto))

		Case cTipSTL == "F" // Ferramenta

			cProduto := GetMv("MV_PRODFER") // Produto Ferramente
			cProduto := cProduto+Space(Len(SB1->B1_COD)-Len(cProduto))

		Case cTipSTL == 'M' // Mao-de-obra

			If ST1->( dbSeek( xFilial( 'ST1' ) + Trim( cCodSTL ), .F. ) )

				//Produto Mao-de-Obra
				cProduto := IIf( FindFunction( 'MntGetPrdM' ), MntGetPrdM(), PadR( 'MOD' + ST1->T1_CCUSTO, TamSX3( 'B1_COD' )[1] ) )

			EndIf

			/*o backoffice Protheus tem de se responsabilizar de incluir produtos no padrao MOD+CC
			  atraves da identificacao de alguma flag na mensagem unica. enquanto nao esta disponivel
			  usamos como artificio o de-para do campo B1_TIPO (escolhido de forma aleatoria) que deve
			  ser cadastrado manualmente na implantacao: caso haja um B1_TIPO para o produto MOD+CC enviamos
			  o produto associado a essa chave, caso nao haja enviamos o proprio codigo MOD+CC, esperando
			  que o mesmo ja tenha sido cadastrado no backoffice do outro sistema.
			*/
			If Upper( SubStr( cProduto, 1, 3 ) ) == 'MOD'

				cRefer  := 'PROTHEUS'
				cAlias  := 'ST1'
				cField  := 'T1_CCUSTO'
				cValInt := cProduto
				cValExt := RTrim( CFGA070Ext( cRefer, cAlias, cField, cValInt ) )

				If !Empty(cValExt)
					cProduto := cValExt
				EndIf

			EndIf

		OtherWise
			cProduto := ''
	EndCase

Return cProduto

//-------------------------------------------------------------------------------
/*/{Protheus.doc} NGMUAtuCus
Atualiza o custo dos insumos (e da OS).
@type function

@author Felipe Nathan Welter
@since 26/02/2013

@sample NGMUAtuCus( '000001' )

@param  cOrdem, Caracter, OS para atualizar.
@param  [lSB2], Lógico  , Atualiza os custos da SB2 antes de calcular (def: .F.).
@return Lógico, Indica se o processo foi realizado com êxito.
/*/
//-------------------------------------------------------------------------------
Function NGMUAtuCus( cOrdem, lSB2 )

	Local aArea    := GetArea()
	Local aAreaSTJ := STJ->( GetArea() )
	Local aAreaSTL := STL->( GetArea() )
	Local aAreaSD3 := SD3->( GetArea() )
	Local cProduct := ''
	Local nTER     := 0
	Local nTRO     := 0
	Local nSUB     := 0
	Local nFER     := 0
	Local nMDO     := 0
	Local nAPO     := 0
	Local lCustFer := NGCADICBASE( 'TJ_CUSTFER', 'A', 'STJ', .F. )
	Local lRet     := .F.

	Default lSB2 := .F.

	dbSelectArea("STJ")
	dbSetOrder(01)
	If dbSeek(xFilial("STJ")+cOrdem)

		dbSelectArea("STL")
		dbSetOrder(01)
		dbSeek(xFilial("STL")+STJ->TJ_ORDEM)
		Do While STL->( !EoF() ) .And. STL->TL_FILIAL == xFilial( 'STL' ) .And. STL->TL_ORDEM == STJ->TJ_ORDEM

			// ATUALIZA SALDOS E CUSTOS DO PRODUTO.
			If lSB2

				If STL->TL_TIPOREG == 'M'

					NGMUStoLvl( MntGetPrdM( STL->TL_CODIGO ), STL->TL_LOCAL, , 'M', STL->TL_CODIGO )

				Else

					NGMUStoLvl( NGMURetIns( STL->TL_TIPOREG, STL->TL_CODIGO ), STL->TL_LOCAL )

				EndIf

			EndIf

			//calcula o custo do insumo
			RecLock("STL",.F.)
			STL->TL_CUSTO := NGCALCUSTI(STL->TL_CODIGO,STL->TL_TIPOREG,STL->TL_QUANTID,STL->TL_LOCAL,;
												  STL->TL_TIPOHOR,/*cEmp*/,/*cFil*/,STL->TL_QUANREC)
			MsUnLock("STL")

			If Val(STL->TL_SEQRELA) > 0

				//atualiza movimentacao no estoque do Protheus (caso haja).
				//nesse caso o estoque Protheus nao eh usado como origem dos custos,
				//mas algumas funcoes podem utiliza-lo, entao eh bom manter atualizado tambem.
				If !Empty(STL->TL_NUMSEQ)
					dbSelectArea("SD3")
					dbSetOrder(04)
					If dbSeek(xFilial("SD3")+STL->TL_NUMSEQ)
						RecLock("SD3",.F.)
						SD3->D3_CUSTO1 := STL->TL_CUSTO
						MsUnLock("SD3")
					EndIf
				EndIf

				If STL->TL_TIPOREG == "T"
					nTER := nTER + stl->tl_custo
				ElseIf STL->TL_TIPOREG == "P"
					If STL->TL_DESTINO == "T"
						nTRO := nTRO + stl->tl_custo
					ElseIf STL->TL_DESTINO == "S"
						nSUB := nSUB + stl->tl_custo
					Else
						nAPO := nAPO + stl->tl_custo
					EndIf
				ElseIf STL->TL_TIPOREG == "F"
					nFER := nFER + stl->tl_custo
				ElseIf STL->TL_TIPOREG == "M"
					nMDO := nMDO + stl->tl_custo
				EndIf

			EndIf

			STL->(dbSkip())
		EndDo

		//atualiza os custos da ordem de servico
		RecLock("STJ",.F.)
		STJ->TJ_CUSTMDO := nMDO
		STJ->TJ_CUSTMAT := nTRO
		STJ->TJ_CUSTMAA := nAPO
		STJ->TJ_CUSTMAS := nSUB
		STJ->TJ_CUSTTER := nTER
		If lCustFer
			STJ->TJ_CUSTFER := nFER
		EndIf
		MsUnLock("STJ")

		lRet := .T.

	EndIf

	RestArea(aAreaSD3)
	RestArea(aAreaSTL)
	RestArea(aAreaSTJ)
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} NGMUError
Busca e concatena os motivos dos problemas apresentados pela mensagem unica

@param xListOfMsg	Objeto do XML que contem o retorno do outro sistema integrado

@author  Lucas Guszak
@version P11
@since   01/10/2014
/*/
//-------------------------------------------------------------------
Function NGMUError( xListOfMsg )

	Local nX := 0
	Local cMotivoUTF := ''
	Local cMotivo := ''
	Local lMDT	:= nModulo == 35

	If ValType(xListOfMsg) == "A"
		For nX := 1 To Len(xListOfMsg)
			If lMDT
				If ValType(xListOfMsg[nX]:Text) <> "U"
					cMotivoUTF := EncodeUTF8(xListOfMsg[nX]:Text)
					cMotivo	 += CRLF + '- ' + DecodeUTF8( cMotivoUTF )
				EndIf
			Else
				If ValType(xListOfMsg[nX]:_Message:Text) <> "U"
				    cMotivoUTF := EncodeUTF8(xListOfMsg[nX]:_Message:Text)
				    cMotivo	 += CRLF + '- ' + DecodeUTF8( cMotivoUTF )
				EndIf
			EndIf
		Next nX
	Else
		If ValType(xListOfMsg:Text) <> "U"
			cMotivoUTF	:= EncodeUTF8( xListOfMsg:Text )
			cMotivo	+= DecodeUTF8( cMotivoUTF )
		EndIf
	EndIf

Return cMotivo

//-----------------------------------------------------------------------
/*/{Protheus.doc} NGMUValRes
Função responsavel por unificar a verificação de envio
e recebimento de Mensagem Unica, tratando a mensagem de erro.
@type function

@author Maicon André Pinheiro
@since  27/02/2018

@sample NGMUValRes( oXmlMU, 'Title', .F. )

@param oXmlMU    , Object  , Objeto que contêm o xml que foi retornado.
@param cTitle    , Caracter, Titulo que erro que será apresentado.
@param [lShowMsg], Lógico  , Define se deve apresentar a mensagem de erro.
@return aXml[1]  , Lógico  , Valor .T. se for "OK" e .F. caso seja "ERROR"
        aXml[2]  , Caracter, Mensagem que será apresentada.
/*/
//-----------------------------------------------------------------------
Function NGMUValRes( oXmlMU, cTitle, lShowMsg )

	Local cObs	     := ""
	Local xObj	     := ""
	Local aXml       := {}
	Local lMDT       := nModulo == 35

	Default lShowMsg := .T.

	AADD( aXml , ( "ERROR" <> Upper(oXmlMU:_TOTVSMESSAGE:_RESPONSEMESSAGE:_PROCESSINGINFORMATION:_STATUS:Text) ) )
	If !aXml[1] //Caso seja "ERROR"
		If lMDT
			cObs := If( Type('Inclui') == 'L' .And. Inclui , STR0025 , If( Type('Altera') == 'L' .And. Altera , STR0026 , STR0027 ) ) //"Não foi possível incluir EPI "##"Não foi possível alterar EPI "##"Não foi possível excluir EPI "
			cObs += AllTrim( If( lMemory, M->CP_PRODUTO , SCP->CP_PRODUTO ) ) + STR0028//" devido inconsistência no backoffice."
		Else
			cObs := cTitle + CRLF
		EndIf
		cObs += STR0031 //"Motivo: "
		xObj := oXmlMU:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message
		cObs += NGMUError(xObj)

		aAdd( aXml , cObs )

		If lShowMsg
			MsgAlert( cObs + CRLF + STR0007, STR0008 ) //Para mais detalhes consulte o log do EAI. # Integração BackOffice
		EndIf

	EndIf

Return aXml