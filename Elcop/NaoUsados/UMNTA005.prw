#Include "Protheus.ch"

/*/-------------------------------------------------------------------
- Programa: UMNTA005
- Autor: Tarcisio Silva Miranda
- Data: 18/01/2023
- Descrição: Popula as informações do pedido e aciona o execauto.
-------------------------------------------------------------------/*/

User Function UMNTA005(cJson,nOpc,cMsgLog)

	Local lReturn    := .F.
	Local aDadosSC5  := {}
	Local aDadosSC6  := {}
	Local oResponse	 := JsonObject():New()
	Local cBkpFun    := FunName()
	Local cErr 		 := ""
	Default cJson 	 := ""
	Default nOpc   	 := 0
	Default cMsgLog	 := ""
	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	//Função para converter a json para objto.
	cErr := oResponse:FromJson(cJson)
	//Verfico se houve erro na conversão acima.
	if ( empty(cErr) .AND. nOpc!=5) .OR. (nOpc==5 .AND. empty(cJson))
		if nOpc == 3
			fGetInc(@aDadosSC5,@aDadosSC6,oResponse,nOpc)
		elseif nOpc == 4
			fGetAltExc(,@aDadosSC6,nOpc)
			fGetInc(@aDadosSC5,@aDadosSC6,oResponse,nOpc)
		elseif nOpc == 5
			fGetAltExc(@aDadosSC5,@aDadosSC6,nOpc)
		endif
		SetFunName("MATA410")
		MsExecAuto({|x, y, z| MATA410(x, y, z)}, aDadosSC5, aDadosSC6, nOpc)
		if !lMsErroAuto
			lReturn := .T.
			cMsgLog := SC5->C5_NUM
			FWLogMsg("INFO",, FunName(),,,, "Registro atualizado com sucesso, Pedido : "+cMsgLog,,,)
		else
			cMsgLog := MostraErro("/")
			FWLogMsg("ERROR",, FunName(),,,, cMsgLog,,,)
		endif
		SetFunName(cBkpFun)
	else
		FWLogMsg("ERROR",, FunName(),,,, "Erro ao fazer a conversão do JSON para objeto." + cErr ,,,)
	endif

Return(lReturn)

/*/-------------------------------------------------------------------
- Programa: fGetAltExc
- Autor: Tarcisio Silva Miranda
- Data: 18/01/2023
- Descrição: Função acionada tanto para exclusão, quanto para alteração.
-------------------------------------------------------------------/*/

Static Function fGetAltExc(aDadosSC5,aDadosSC6,nOpc)

	Local aAreaSC5      := SC5->(FwGetArea())
	Local aAreaSC6      := SC6->(FwGetArea())
	Local aLinhaSC6     := {}
	Local cFilials      := SC5->C5_FILIAL
	Local cNumPv        := SC5->C5_NUM
	Default aDadosSC6   := {}
	Default nOpc        := 0
	Default aDadosSC5 	:= {}

	if nOpc == 5
		aAdd(aDadosSC5, {"C5_NUM"		, SC5->C5_NUM		, Nil })
		aAdd(aDadosSC5, {"C5_CLIENTE"	, SC5->C5_CLIENTE   , Nil })
		aAdd(aDadosSC5, {"C5_LOJACLI"	, SC5->C5_LOJACLI   , Nil })
		aAdd(aDadosSC5, {"C5_CONDPAG"	, SC5->C5_CONDPAG   , Nil })
		aAdd(aDadosSC5, {"C5_NATUREZ"	, SC5->C5_NATUREZ	, Nil })
		aDadosSC5 := FWVetByDic(aDadosSC5, "SC5")
	endif

	SC6->(DbSelectArea("SC6"))
	SC6->(DbSetOrder(1))
	SC6->(DbGotop())

	if SC6->(DbSeek( cFilials + cNumPv ))
		While !SC6->(Eof()) .AND. SC6->C6_FILIAL == cFilials .AND. SC6->C6_NUM == cNumPv
			aLinhaSC6 := {}
			aAdd(aLinhaSC6, {"LINPOS"     , "C6_ITEM"       , SC6->C6_ITEM  })
			aAdd(aLinhaSC6, {"C6_PRODUTO", SC6->C6_PRODUTO  , Nil           })
			aAdd(aLinhaSC6, {"C6_QTDVEN" , SC6->C6_QTDVEN   , NIL           })
			aAdd(aLinhaSC6, {"C6_PRCVEN" , SC6->C6_PRCVEN   , NIL           })
			aAdd(aLinhaSC6, {"C6_VALOR"	 , SC6->C6_VALOR    , NIL           })
			aAdd(aLinhaSC6, {"C6_TES"	 , SC6->C6_TES	    , NIL           })
			aAdd(aLinhaSC6 ,{"AUTDELETA" ,  "S"             , Nil           })
			aLinhaSC6 := FWVetByDic(aLinhaSC6, "SC6")
			aAdd(aDadosSC6, aLinhaSC6)
			SC6->(DbSkip())
		enddo
	endif

	FwRestArea(aAreaSC5)
	FwRestArea(aAreaSC6)

Return(Nil)

/*/-------------------------------------------------------------------
- Programa: fGetInc
- Autor: Tarcisio Silva Miranda
- Data: 18/01/2023
- Descrição: Pega os dados de inclusão do json.
-------------------------------------------------------------------/*/

Static Function fGetInc(aDadosSC5,aDadosSC6,oResponse,nOpc)

	Local nX            := 1
	Local nY            := 1
	Local aLinhaSC6     := {}
	Local aCamposSC5    := {}
	Local aCamposSC6    := {}
	Local aItensSC6     := {}
	Default aDadosSC5   := {}
	Default aDadosSC6   := {}
	Default oResponse   := Nil

	//Pego os campos do cabeçalho.
	aCamposSC5 := oResponse["PEDIDO"]:GetNames()
	//Percorro os campos para preencher o execauto.
	for nX := 1 to len(aCamposSC5)
		aAdd(aDadosSC5,{aCamposSC5[nX] , fConvVar( aCamposSC5[nX], oResponse["PEDIDO"][aCamposSC5[nX]]  ) , Nil  })
	next nX
	if nOpc == 4
		aAdd(aDadosSC5, {"C5_NUM" , SC5->C5_NUM , Nil})
	endif
	//Ordeno o array do execauto para não dar erro de gatilho.
	aDadosSC5 := FWVetByDic(aDadosSC5, "SC5")

	//Transoformo os itens do pedido venda do json em array, para trabalhar melhor a manipulação dos dados.
	//Trato também os dados para quando vir do tipo objeto.
	aItensSC6   := iif(ValType(oResponse["ITENS"])=="O",{oResponse["ITENS"]},oResponse["ITENS"])
	//Percorro os itens do pedido.
	for nX := 1 to len(aItensSC6)
		//Limpo a variavel da linha.
		aLinhaSC6 := {}
		//Pego os campo dos intes.
		aCamposSC6 := aItensSC6[nX]:GetNames()
		//Percorro os campos para preencher o execauto.
		for nY := 1 to len(aCamposSC6)
			aAdd(aLinhaSC6,{aCamposSC6[nY] , fConvVar( aCamposSC6[nY], aItensSC6[nX][aCamposSC6[nY]]  ) , Nil  })
		next nY
		//Preencho o item para não precisar de passar no json.
		aAdd(aLinhaSC6, {"C6_ITEM"  , StrZero(nX,2)	, Nil })
		aAdd(aLinhaSC6, {"AUTDELETA", "N"           , Nil })
		//Ordeno o array do execauto para não dar erro de gatilho.
		aLinhaSC6 := FWVetByDic(aLinhaSC6, "SC6")
		//Alimento o array de item do execauto.
		aAdd(aDadosSC6, aLinhaSC6)
	next nX

Return(Nil)

/*/-------------------------------------------------------------------
	- Programa: fConvVar
	- Autor: Tarcisio Silva Miranda
	- Data: 04/01/2023
	- Descrição: Função que converte variavel.
-------------------------------------------------------------------/*/

Static Function fConvVar( cCampo, xConteudo )

	Local xReturn
	Default cCampo      := ""
	Default xConteudo   := Nil

	if TamSx3(cCampo)[3] == "C"
		xReturn := PadR(AllTrim(xConteudo),TamSx3(cCampo)[1])
	elseif TamSx3(cCampo)[3] == "D"
		xReturn := cTod(xConteudo)
	elseif TamSx3(cCampo)[3] == "N"
		xReturn := xConteudo
	endif

Return(xReturn)
