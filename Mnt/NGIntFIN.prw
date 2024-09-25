#Include 'totvs.ch'
#Include 'ngintfin.ch'
#Include 'fileio.ch'

//redefined in frameworkng.ch **************
#DEFINE __VALID_OBRIGAT__  'O'
#DEFINE __VALID_UNIQUE__   'U'
#DEFINE __VALID_FIELDS__   'F'
#DEFINE __VALID_BUSINESS__ 'B'
#DEFINE __VALID_ALL__      'OUFB'
#DEFINE __VALID_NONE__     ''
//******************************************

#DEFINE   _BUSINESSOP_GERATITULO_    1
#DEFINE   _BUSINESSOP_BAIXAPARCELA_  2
#DEFINE   _BUSINESSOP_CANCELBAIXA_   3

#DEFINE   _APARCELAS_E2VENCTO_       1
#DEFINE   _APARCELAS_E2VALOR_        2
#DEFINE   _APARCELAS_E2PARCELA_      3
#DEFINE   _APARCELAS_E2HIST_         4
#DEFINE   _APARCELAS_E2DECRESC_      5

//------------------------------
// Força a publicação do fonte
//------------------------------
Function _NGIntFIN()
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIntFIN
Classe de integração com o módulo de financeiro no backoffice.

@author Felipe Nathan Welter
@since 15/05/2013
@version P11
/*/
//---------------------------------------------------------------------
Class NGIntFIN FROM NGGenerico

	Method New( lShow ) CONSTRUCTOR

	//METODOS PUBLICOS
	Method geraTitulo( aInfos )
	Method baixaParcela(dData,cHist,nValor,nDesc)
	Method cancelBaixa(dData,cHist)

	Method setParcelas(aArray)
	Method setRelated(cTable)

	//METODOS PRIVADOS
	Method validBusiness()
	Method setShowMsg( lShow )
	Method getShowMsg()
	Method addErrExec()

	//ATRIBUTOS PUBLICOS
	//--

	//ATRIBUTOS PRIVADOS
	DATA oError As Object
	DATA oStruct As Object
	DATA aParcelas As Array
	DATA cRelateTbl As String
	DATA lShowMsg As Boolean 

EndClass

//---------------------------------------------------------------------
/*/{Protheus.doc} New
Método inicializador da classe.

@author Felipe Nathan Welter
@since 26/04/2013
@version P11
@return Self O objeto criado.
/*/
//---------------------------------------------------------------------
Method New( lShow ) Class NGIntFin

	Local aFields := {"E2_FILIAL","E2_PREFIXO","E2_NUM","E2_TIPO","E2_NATUREZ","E2_FORNECE","E2_LOJA","E2_EMISSAO","E2_VENCTO","E2_BAIXA",;
							"E2_ORIGEM","E2_MOEDA","E2_CCD","E2_CCUSTO","E2_VALOR","E2_VLCRUZ","E2_DECRESC","E2_DESCONT","E2_HIST","E2_PARCELA","E2_LA","E2_XX61A","E2_ITEMD"}

	Default lShow := !IsBlind()

	_Super:New()

	::oError   := NGFWError():New()
	::oStruct  := NGFWStruct():New()

	::SetAlias("SE2",aFields)
	::setValidationType(__VALID_BUSINESS__)
	::initFields(.T.)

	::aParcelas := {}
	::setShowMsg( lShow )

Return Self

//---------------------------------------------------------------------
/*/{Protheus.doc} validBusiness
Método que realiza a validação da regra de negócio da classe.

@protected
@param nBOP Identificador da operação de negócio (_BUSINESSOP_GERATITULO_,
_BUSINESSOP_BAIXAPARCELA_ ou _BUSINESSOP_CANCELBAIXA_)
@author Felipe Nathan Welter
@since 26/04/2013
@version P11
@return lValid Validação ok.
@obs este método não é chamado diretamente.
/*/
//---------------------------------------------------------------------
Method validBusiness(nBOP) Class NGIntFIN

	Local lRet    := .T.
	Local cError  := ''
	Local cAlsSE2 := ''
	Local nX      := 0
	Local nOp     := ::getOperation()

	If nBOP == _BUSINESSOP_GERATITULO_

		If nOp == 3 .Or. nOp == 4

			//001 - MNT deve estar integrado ao FIN, conforme MV_NGMNTFI
			If GetNewPar("MV_NGMNTFI","N") == "N"
				lRet   := .F.
				cError := "Conforme parâmetro MV_NGMNTFI, o MNT não está integrado com módulo FIN."
			EndIf

			//002 - consistir campos obrigatórios para o ExecAuto
			If lRet .And.;
				( 	Empty(::getValue("E2_PREFIXO")) .Or. Empty(::getValue("E2_NUM")) .Or.;
					Empty(::getValue("E2_TIPO")) .Or. Empty(::getValue("E2_NATUREZ")) )
				lRet := .F.
				cError := "Algum campo obrigatório" + " ('" + AllTrim(NGRETTITULO("TRX_PREFIX")) + "', '" + ;
								AllTrim(NGRETTITULO("TRX_NUMSE2")) + "', '" + ;
								AllTrim(NGRETTITULO("TRX_TIPO"))   + "', '" + ;
								AllTrim(NGRETTITULO("TRX_NATURE")) + "', '" + ;
								AllTrim(NGRETTITULO("TRX_CONPAG")) + ;
								"') " + "para a geração de Conta a Pagar não foi preenchido!"
			EndIf

			// 003 - Consistir se já não existe título financeiro com as mesmas informações.
			If lRet .And. nOp == 3

				cAlsSE2 := GetNextAlias()

				BeginSQL Alias cAlsSE2

					SELECT
						COUNT(1) AS nFirst
					FROM
						%table:SE2%
					WHERE
						E2_FILIAL  = %xFilial:SE2%                       AND
						E2_PREFIXO = %exp:Self:getValue( 'E2_PREFIXO' )% AND
						E2_NUM     = %exp:Self:getValue( 'E2_NUM' )%     AND
						E2_TIPO    = %exp:Self:getValue( 'E2_TIPO' )%    AND
						E2_FORNECE = %exp:Self:getValue( 'E2_FORNECE' )% AND
						E2_LOJA    = %exp:Self:getValue( 'E2_LOJA' )%    AND
						%NotDel%

				EndSQL

				If (cAlsSE2)->nFirst > 0

					lRet := .F.
					cError := STR0001 + CRLF + CRLF // Não é possível incluir um novo documento com as informações de um título financeiro já existente:
					cError += STR0002 + Trim( ::getValue( 'E2_PREFIXO' ) ) + CRLF // Prefixo:
					cError += STR0003 + Trim( ::getValue( 'E2_NUM' ) )     + CRLF // Número:
					cError += STR0004 + Trim( ::getValue( 'E2_TIPO' ) )    + CRLF // Tipo:
					cError += STR0005 + Trim( ::getValue( 'E2_FORNECE' ) ) + CRLF // Fornecedor:
					cError += STR0006 + Trim( ::getValue( 'E2_LOJA' ) )    + CRLF // Loja:

				EndIf

				(cAlsSE2)->( dbCloseArea() )

			EndIf

		ElseIf nOp == 5

			//003 - verifica se os registros existem
			dbSelectArea("SE2")
			dbSetOrder(01)
			For nX := 1 To Len(::aParcelas)
				If !dbSeek(xFilial("SE2")+::getValue("E2_PREFIXO")+::getValue("E2_NUM")+::aParcelas[nX,_APARCELAS_E2PARCELA_]+;
						 ::getValue("E2_TIPO")+::getValue("E2_FORNECE")+::getValue("E2_LOJA"))
					lRet := .F.
					cError := 'Registro não localizado (parcela'+::aParcelas[nX,_APARCELAS_E2PARCELA_]+')'
					Exit
				EndIf
			Next nX

		Else
			//000 - operacao deve estar definida como 3/4 ou 5
			lRet := .F.
			cError := 'Operação não definida (setOperation).'

		EndIf

		//000 - consiste informacoes de parcelas
		If lRet .And. Empty(::aParcelas)
			lRet := .F.
			cError := 'Não definidas informações de parcelas (setParcelas).'
		EndIf

		//000 - consiste tabela relacionada
		If lRet .And. !(::cRelateTbl $ "TRX/TS2/TS8")
			lRet := .F.
			cError := 'Tabela relacionada não possui vínculo com documentos (setRelated).'
		EndIf

	ElseIf 	nBOP == _BUSINESSOP_BAIXAPARCELA_ .Or.;
				nBOP == _BUSINESSOP_CANCELBAIXA_

		//005 - verifica se o registro já está carregado
		If Empty(::getValue("E2_NUM"))
			lRet := .F.
			cError := "Nenhum registro carregado."
		EndIf

	EndIf

	If !lRet
		::addError(cError)
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} setParcelas
Define para os titulos a serem gerados, as informações de parcelas.

@param aArray array contendo as parcelas, com a seguinte estrutura:
		   [1] - Data de vencimento (E2_VENCTO)
		   [2] - Valor da parcela (E2_VALOR, E2_VLCRUZ)
		   [3] - Código da parcela (E2_PARCELA)
		   [4] - Histórico (E2_HIST)
@author Felipe Nathan Welter
@since 06/06/13
@version P11
@return lRet .T.
@obs cada parcela informada gera um titulo no SE2.
/*/
//---------------------------------------------------------------------
Method setParcelas(aArray) Class NGIntFIN
	::aParcelas := aClone(aArray)
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} setRelated
Define a tabela de origem do MNT a relacionar-se com os titulos.

@param cTable tabela "TRX", "TS2" ou "TS8"
@author Felipe Nathan Welter
@since 15/06/13
@version P11
@return lRet .T.
/*/
//---------------------------------------------------------------------
Method setRelated(cTable) Class NGIntFIN
	::cRelateTbl := cTable
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} geraTitulo
Gera títulos no módulo financeiro, quando integrado.
@type method

@author Felipe Nathan Welter
@since 20/05/2013

@param  [aInfos], array, Informações complementares enviadas na integração:
							[1], numeric, Valor de Desconto.
							[2], string , Observação.
							[3], boolean , Determina se houve alteração apenas no centro de custo.

@return lRet indica se o título foi gerado.

@obs a opcao de incluir deve considerar os campos obrigatórios: "E2_PREFIXO",
"E2_NUM", "E2_TIPO", "E2_NATUREZ", "E2_FORNECE", "E2_LOJA", "E2_EMISSAO",
"E2_ORIGEM", "E2_MOEDA", "E2_CCD", e os campos "E2_VENCTO",  "E2_VALOR",
"E2_VLCRUZ", "E2_HIST" e "E2_PARCELA" como opção de parcela. A opção de
excluir deve considerar os campos da chave: "E2_PREFIXO", "E2_NUM",
"E2_PARCELA", "E2_TIPO", "E2_FORNECE" e "E2_LOJA" através de setValue.
@sample
	oIntFIN := NGIntFin():New()
	oIntFIN:setOperation(nOpc)
	oIntFIN:setValue("E2_PREFIXO",M->TRX_PREFIX)
	oIntFIN:setValue("E2_NUM",M->TRX_NUMSE2)
	oIntFIN:setValue("E2_TIPO",M->TRX_TIPO)
	oIntFIN:setValue("E2_NATUREZ",M->TRX_NATURE)
	oIntFIN:setValue("E2_FORNECE",TRZ->TRZ_FORNEC)
	oIntFIN:setValue("E2_LOJA",TRZ->TRZ_LOJA)
	oIntFIN:setValue("E2_EMISSAO",M->TRX_DTEMIS)
	oIntFIN:setValue("E2_ORIGEM",FunName())
	oIntFIN:setValue("E2_MOEDA",1)
	oIntFIN:setValue("E2_CCD",M->TRX_CCUSTO)
	oIntFIN:setValue("E2_ITEMD",ST9->T9_ITEMCTA)

	aParcelas := {{M->E2_VENCTO,M->E2_VALOR,M->E2_PARCELA,M->E2_HIST,M->E2_DECRESC}}
	oIntFIN:setParcelas(aParcelas)

	If !oIntFIN:geraTitulo()
		Help(,,'HELP',, oIntFIN:getErrorList()[1],1,0)
		lRet := .F.
	EndIf
/*/
//---------------------------------------------------------------------
Method geraTitulo( aInfos ) Class NGIntFIN

	Local aArea			   := GetArea()
	Local lRet			   := .F.
	Local nTpOp			   := ::getOperation()
	Local nZ			   := 0
	Local nX			   := 0
	Local nUltCol		   := 0 //Utilizada no PE MNTA765E
	Local nOpcPe		   := 0 //Utilizada no PE MNTA765E
	Local aRetTitulo	   := {}
	Local lMNTA7655		   := ExistBlock("MNTA7655")
	Local lMNTA7656		   := ExistBlock("MNTA7656")
	Local lMNTA765E		   := ExistBlock("MNTA765E")
	Local aMNTA765E  	   := {}
	Local lTresParm        := .F.
	Local oModGFR          := FWModelActive() // Backup do modelo ativo

	Private lMsErroAuto    := .F.
	Private aTituloMain    := {}
	Private aTitulo        := {}

	Default aInfos         := { 0.00, '', .F. }

	If Len( aInfos ) == 3

		lTresParm := .T.

	EndIf

	If ::validBusiness(_BUSINESSOP_GERATITULO_)
		lRet := .T.
	EndIf

	If lRet
		//---------------------------------------------------------------------
		//carrega dados do cabecalho do pedido
		//---------------------------------------------------------------------
		If nTpOp == 3 .Or. nTpOp == 4
			_E2NUM := ::getValue("E2_NUM")

			aTituloMain := {	{"E2_PREFIXO",	::getValue("E2_PREFIXO") 	,Nil},;
								{"E2_NUM"	 ,	IIF(_E2NUM==Nil,NGSEQSE2(),_E2NUM),Nil},;
								{"E2_TIPO"   ,	::getValue("E2_TIPO")	 	,Nil},;
								{"E2_NATUREZ",	::getValue("E2_NATUREZ") 	,Nil},;
								{"E2_FORNECE",	::getValue("E2_FORNECE") 	,Nil},;
								{"E2_LOJA"	 ,	::getValue("E2_LOJA")	 	,Nil},;
								{"E2_EMISSAO",	::getValue("E2_EMISSAO") 	,Nil},;
								{"E2_ORIGEM" ,	FunName()					,Nil},;
								{"E2_MOEDA"  ,	1							,Nil},;
								{"E2_CCD"	 ,	::getValue("E2_CCD")		,Nil},;
								{"E2_CCUSTO" ,	::getValue("E2_CCUSTO")		,Nil},;
								{"E2_ITEMD",	::getValue("E2_ITEMD")		,Nil}}

		ElseIf nTpOp == 5

			aTituloMain := {	{"E2_PREFIXO",	::getValue("E2_PREFIXO"),Nil},;
								{"E2_NUM"	 , ::getValue("E2_NUM")		,Nil},;
								{"E2_TIPO"	 , ::getValue("E2_TIPO")	,Nil},;
								{"E2_FORNECE", ::getValue("E2_FORNECE")	,Nil},;
								{"E2_LOJA"	 , ::getValue("E2_LOJA")	,Nil}}

		EndIf


		If lMNTA765E
			If ::cRelateTbl $ 'TRX'
				nOpcPe := 1
			ElseIf ::cRelateTbl $ 'TS2/TS8'
				nOpcPe := 2
			EndIf
			aMNTA765E := ExecBlock("MNTA765E",.F.,.F., {nOpcPe})
		EndIf

		//---------------------------------------------------------------------
		//grava dados
		//---------------------------------------------------------------------

		BEGIN TRANSACTION
			//---------------------------------------------------------------------
			//carrega dados do item do pedido e grava/exclui pedido
			//---------------------------------------------------------------------
			For nX := 1 To Len(::aParcelas)

				aTitulo := aClone(aTituloMain)

				If nTpOp == 3 .Or. nTpOp == 4

					aAdd(aTitulo,{"E2_VENCTO"  ,::aParcelas[nX,_APARCELAS_E2VENCTO_],Nil})
					aAdd(aTitulo,{"E2_VALOR"   ,::aParcelas[nX,_APARCELAS_E2VALOR_],Nil})
					aAdd(aTitulo,{"E2_VLCRUZ"  ,::aParcelas[nX,_APARCELAS_E2VALOR_],Nil})
					If Len(::aParcelas[nX]) >= 3 .And. ::aParcelas[nX,_APARCELAS_E2PARCELA_] != Nil
						aAdd(aTitulo,{"E2_PARCELA",::aParcelas[nX,_APARCELAS_E2PARCELA_],Nil})
					EndIf
					If Len(::aParcelas[nX]) >= 4
						aAdd(aTitulo,{"E2_HIST",::aParcelas[nX,_APARCELAS_E2HIST_],Nil})
					EndIf
					If Len(::aParcelas[nX]) >= 5
						aAdd(aTitulo,{"E2_DECRESC" ,::aParcelas[nX,_APARCELAS_E2DECRESC_],Nil})
					EndIf

					If lMNTA765E
						//Pega ultima posição do array de aParcelas para pegar informações do usuário corretamente.
						nUltCol := Len(::aParcelas[nX])
						For nZ := Len(aMNTA765E) To 1 Step - 1
							aAdd(aTitulo,{aMNTA765E[nZ][2], ::aParcelas[nX][nUltCol], Nil})
							nUltCol--
						Next nZ
					EndIf

					If ::cRelateTbl $ 'TRX'
						If lMNTA7655

							aRetTitulo := ExecBlock("MNTA7655",.F.,.F.,{ aTitulo, Len(::aParcelas) })

							If ValType(aRetTitulo) == "A"
								aTitulo := aClone(aRetTitulo)
							EndIf
						EndIf
					Endif

				ElseIf nTpOp == 5
					aAdd(aTitulo,{"E2_PARCELA",::aParcelas[nX,_APARCELAS_E2PARCELA_],Nil})
				EndIf

				If lTresParm .And. aInfos[3]

					aTitulo := { {'E2_CCD'	 ,	::getValue('E2_CCD')		,Nil},;
								{'E2_CCUSTO' ,	::getValue('E2_CCUSTO')		,Nil}}

					DbSelectArea( 'SE2' )
					DbSetOrder( 1 ) // E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
					MsSeek( FWxFilial( 'SE2' ) + ::getValue( 'E2_PREFIXO' ) + ::getValue( 'E2_NUM' ) + aParcelas[ nX, 3 ] + ::getValue( 'E2_TIPO' ) ) //Alteração deve ter o registro SE2 posicionado

					MSExecAuto( {|x,z,y| FINA050(x,z,y)}, aTitulo, , 4 )

				Else

					MSExecAuto( {|x,z,y| FINA050(x,z,y)}, aTitulo, , nTpOp )

				EndIf

				If lMsErroAuto

					lRet := .F.
					::addErrExec()
					DisarmTransaction()
					Exit

				ElseIf cValToChar(nTpOp) $ "3/4"

					//002 - executa PE MNTA7656
					If lMNTA7656
						ExecBlock("MNTA7656",.F.,.F.)
					EndIf

				ElseIf cValToChar(nTpOp) $ "5"

				EndIf

			Next nX

		END TRANSACTION

		MsUnlockAll()

		//003 - integracao via mensagem unica
		If lRet .And. !lMsErroAuto .And. cValToChar(nTpOp) $ "3/4/5" .And. AllTrim(GetNewPar("MV_NGINTER","N")) == "M"  //Mensagem Unica
			
			lRet := NGMUOrder( SE2->( RecNo() ), 'SE2', .F., nTpOp, Nil, ::aParcelas, ::cRelateTbl, aInfos )

			//caso a integracao nao tenha sucesso, exclui os titulos gerados
			If !lRet

				::addError("Nâo foi possível concluir a integração com backoffice.")

				For nX := 1 To Len(::aParcelas)
					dbSelectArea("SE2")
					dbSetOrder(1)
					dbSeek(xFilial("SE2")+::getValue("E2_PREFIXO")+::getValue("E2_NUM")+::aParcelas[nX,_APARCELAS_E2PARCELA_]+;
							 ::getValue("E2_TIPO")+::getValue("E2_FORNECE")+::getValue("E2_LOJA"))
					aTituloMain := {	{"E2_PREFIXO",	::getValue("E2_PREFIXO") ,Nil},;
											{"E2_NUM"	 , ::getValue("E2_NUM")     ,Nil}}

					aAdd(aTitulo,{"E2_PARCELA",::aParcelas[nX,_APARCELAS_E2PARCELA_],Nil})

					MSExecAuto({|x,z,y| FINA050(x,z,y)},aTituloMain,,5)

					If lMsErroAuto
						::addErrExec()
					EndIf

				Next nX
			EndIf
		EndIf

	EndIf

	If !Empty( oModGFR )

		/*------------------------------------------------------------------+
		| Ativa modelo salvo, visto que o ExecAuto pode ativar outro modelo |
		+------------------------------------------------------------------*/
		oModGFR:Activate()

	EndIf

	RestArea(aArea)

Return lRet


//---------------------------------------------------------------------
/*/{Protheus.doc} baixaParcela
Baixa valor pago para a parcela de um titulo a pagar que esta carregado.

@param nValor	Valor pago na baixa (parcial ou total).
@param nDesc	Desconto relacionado ao pagamento da parcela.
@param dData	Data da baixa.
@param cHist	Observações/Descrição da baixa.
@author Felipe Nathan Welter
@since 07/06/13
@version P11
@return lRet indica se a baixa ocorreu com sucesso.
@obs a baixa deve ser realizada com o registro em memória (Load).
@sample
	oFin := NGIntFin():New()
	If oFin:load({cKeySE2})
		If !oFin:baixaParcela(dDataBase,cObserv,nPago,nDesc)
			cRet := oIntFIN:getErrorList()[1]
			lRet := .F.
		EndIf
	EndIf
/*/
//---------------------------------------------------------------------
Method baixaParcela(dData,cHist,nValor,nDesc) Class NGIntFIN

	Local aArea            := GetArea()
	Local aParcBaixa       := {}
	Local lRet             := .F.
	Local nVlPagto         := 0
	Local cFILSE2          := ::getValue("E2_FILIAL")
	Local cPREFIXO         := ::getValue("E2_PREFIXO")
	Local cNUM             := ::getValue("E2_NUM")
	Local cPARCELA         := ::getValue("E2_PARCELA")
	Local cTIPO            := ::getValue("E2_TIPO")
	Local cFORNECE         := ::getValue("E2_FORNECE")
	Local cLOJA	           := ::getValue("E2_LOJA")

	Private lMsErroAuto    := .F.

	Default nValor         := ::getValue("E2_VALOR")
	Default nDesc          := ::getValue("E2_DESCONT")
	Default dData          := ::getValue("E2_BAIXA")
	Default cHist          := ::getValue("E2_HIST")

	If ::validBusiness(_BUSINESSOP_BAIXAPARCELA_)
		lRet := .T.
	EndIf

	If lRet
		//Monta array com os dados da baixa a pagar do título
		aAdd( aParcBaixa, { 'E2_FILIAL' , cFILSE2                                   , Nil } )
		aAdd( aParcBaixa, { 'E2_PREFIXO', cPREFIXO                                  , Nil } )
		aAdd( aParcBaixa, { 'E2_NUM'    , cNUM                                      , Nil } )
		aAdd( aParcBaixa, { 'E2_PARCELA', cPARCELA                                  , Nil } )
		aAdd( aParcBaixa, { 'E2_TIPO'   , cTIPO                                     , Nil } )
		aAdd( aParcBaixa, { 'E2_FORNECE', cFORNECE                                  , Nil } )
		aAdd( aParcBaixa, { 'E2_LOJA'   , cLOJA                                     , Nil } )
		aAdd( aParcBaixa, { 'AUTMOTBX'  , 'NORMAL'                                  , Nil } )
		aAdd( aParcBaixa, { 'AUTBANCO'  , PadR( '001'  , TamSX3( 'A6_COD' )[1] )    , Nil } )
		aAdd( aParcBaixa, { 'AUTAGENCIA', PadR( '0001' , TamSX3( 'A6_AGENCIA' )[1] ), Nil } )
		aAdd( aParcBaixa, { 'AUTCONTA'  , PadR( '00001', TamSX3( 'A6_NUMCON' )[1] ) , Nil } )
		aAdd( aParcBaixa, { 'AUTDTBAIXA', dData                                     , Nil } )
		aAdd( aParcBaixa, { 'AUTHIST'   , cHist                                     , Nil } )

		AcessaPerg("FIN080", .F.)

		//003 - Verifica se já houve baixa parcial anteriormente e busca o valor que já existe
		//para somar ao valor da nova baixa enviada.
		dbSelectArea("SE2")
		dbSetOrder(01)
		If dbSeek(cFILSE2 + cPREFIXO + cNUM + cPARCELA + cTIPO + cFORNECE + cLOJA)
			nVlPagto := SE2->E2_VALOR - SE2->E2_SALDO - SE2->E2_DESCONT
		EndIf

		nValor := nValor - nVlPagto
		nDesc  := nDesc  - SE2->E2_DESCONT

		AADD(aParcBaixa,{"AUTDESCONT",nDesc ,Nil})
		AADD(aParcBaixa,{"AUTVLRPG"  ,nValor,Nil})

		MsExecAuto ({|x,y| FINA080(x,y)}, aParcBaixa, 3)

		If lMsErroAuto
			::addErrExec()
			lRet := .F.
		EndIf
	EndIf

	RestArea(aArea)

Return lRet


//---------------------------------------------------------------------
/*/{Protheus.doc} cancelBaixa
Cancela a baixa de uma parcela, retornando seu valor pago para zero.

@param dData	Data da movimentacao de cancelamento.
@param cHist	Observações/Descrição para o cancelamento da baixa.
@author Felipe Nathan Welter
@since 07/06/13
@version P11
@return lRet indica se o cancelamento da baixa ocorreu com sucesso.
@obs deve ser realizada com o registro em memória (Load).
@sample
	oFin := NGIntFin():New()
	If oFin:load({cKeySE2})
		If !oFin:cancelBaixa(dDataBase,cObserv)
			cXMLRet := oFin:getErrorList()[1]
			lRet := .F.
		EndIf
	EndIf
/*/
//---------------------------------------------------------------------
Method cancelBaixa(dData,cHist) Class NGIntFIN

	Local aArea            := GetArea()
	Local lRet             := .F.
	Local aCnlBaixa        := {}
	Local aAreaSE5         := {}
	Local cFILSE2          := ::getValue("E2_FILIAL")
	Local cFILSE5          := NGTROCAFILI("SE5",cFILSE2)
	Local cPREFIXO         := ::getValue("E2_PREFIXO")
	Local cNUM             := ::getValue("E2_NUM")
	Local cPARCELA         := ::getValue("E2_PARCELA")
	Local cTIPO            := ::getValue("E2_TIPO")
	Local cFORNECE         := ::getValue("E2_FORNECE")
	Local cLOJA	           := ::getValue("E2_LOJA")

	Private lMsErroAuto    := .F.

	Default dData          := ::getValue("E2_BAIXA")
	Default cHist          := ::getValue("E2_HIST")

	If ::validBusiness(_BUSINESSOP_CANCELBAIXA_)
		lRet := .T.
	EndIf

	If lRet
		//Monta array com os dados da baixa a pagar do título
		aAdd( aCnlBaixa, { 'E2_FILIAL' , cFILSE2                                   , Nil } )
		aAdd( aCnlBaixa, { 'E2_PREFIXO', cPREFIXO                                  , Nil } )
		aAdd( aCnlBaixa, { 'E2_NUM'    , cNUM                                      , Nil } )
		aAdd( aCnlBaixa, { 'E2_PARCELA', cPARCELA                                  , Nil } )
		aAdd( aCnlBaixa, { 'E2_TIPO'   , cTIPO                                     , Nil } )
		aAdd( aCnlBaixa, { 'E2_FORNECE', cFORNECE                                  , Nil } )
		aAdd( aCnlBaixa, { 'E2_LOJA'   , cLOJA	                                   , Nil } ) 
		aAdd( aCnlBaixa, { 'AUTMOTBX'  , 'NORMAL'                                  , Nil } )
		aAdd( aCnlBaixa, { 'AUTBANCO'  , PadR( '001'  , TamSX3( 'A6_COD' )[1] )    , Nil } )
		aAdd( aCnlBaixa, { 'AUTAGENCIA', PadR( '0001' , TamSX3( 'A6_AGENCIA' )[1] ), Nil } )
		aAdd( aCnlBaixa, { 'AUTCONTA'  , PadR( '00001', TamSX3( 'A6_NUMCON' )[1] ) , Nil } )
		aAdd( aCnlBaixa, { 'AUTDTBAIXA', dData                                     , Nil } )
		aAdd( aCnlBaixa, { 'AUTHIST'   , cHist                                     , Nil } )
		aAdd( aCnlBaixa, { 'AUTDESCONT', 0                                         , Nil } )
		aAdd( aCnlBaixa, { 'AUTVLRPG'  , 0                                         , Nil } )

		AcessaPerg("FIN080", .F.)

		//003 - Verifica todas as baixas existentes para cancelar um a um.
		dbSelectArea("SE5")
		dbSetOrder(07)
		If dbSeek(cFILSE5 + cPREFIXO + cNUM + cPARCELA + cTIPO + cFORNECE + cLOJA)
			While !EoF() .And. SE5->E5_FILIAL  == cFILSE5  .And. SE5->E5_PREFIXO == cPREFIXO .And. SE5->E5_NUMERO == cNUM;
			             .And. SE5->E5_PARCELA == cPARCELA .And. SE5->E5_TIPO    == cTIPO    .And. SE5->E5_CLIFOR == cFORNECE;
			             .And. SE5->E5_LOJA    == cLOJA

				If SE5->E5_SITUACA <> "C"

					aAreaSE5       := SE5->(GetArea())
					
					MsExecAuto ({|x,y| FINA080(x,y)},aCnlBaixa,5,,SE5->E5_SEQ)

					If lMsErroAuto
						::addErrExec()
						lRet := .F.
					EndIf
					RestArea(aAreaSE5)

				EndIf

				dbSelectArea("SE5")
				dbSkip()
			End
		EndIf
	EndIf

	RestArea(aArea)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} setShowMsg
Define variável que indica se mensagem será apresentada

@type method

@author Maria Elisandra de Paula
@since 01/07/2021
@return nil
/*/
//---------------------------------------------------------------------
Method setShowMsg( lShow ) Class NGIntFIN

	::lShowMsg := lShow

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} getShowMsg
Retorna variável que indica se mensagem será apresentada

@type method

@author Maria Elisandra de Paula
@since 01/07/2021
@return nil
/*/
//---------------------------------------------------------------------
Method getShowMsg() Class NGIntFIN

Return ::lShowMsg

//---------------------------------------------------------------------
/*/{Protheus.doc} addErrExec
Recupera erro gerado pelo ExecAuto

@type method

@author Maria Elisandra de Paula
@since 01/07/2021

@return Nil
/*/
//---------------------------------------------------------------------
Method addErrExec() Class NGIntFIN

	Local cError := ' '

	If ::getShowMsg()

		MostraErro()

	Else

		cError := MostraErro( GetSrvProfString( 'Startpath', '' ) )

	EndIf

	::addError( cError )

Return nil
