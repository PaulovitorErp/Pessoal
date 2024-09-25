#INCLUDE "Totvs.ch"
#INCLUDE "FWADAPTEREAI.CH" // Integração via Mensagem Única
//redefined in frameworkng.ch **************
#DEFINE __VALID_OBRIGAT__  'O'
#DEFINE __VALID_UNIQUE__   'U'
#DEFINE __VALID_FIELDS__   'F'
#DEFINE __VALID_BUSINESS__ 'B'
#DEFINE __VALID_ALL__      'OUFB'
#DEFINE __VALID_NONE__     ''
//******************************************

#DEFINE ARQUIVO_STRUCT 1
#DEFINE   CAMPO_STRUCT 2
#DEFINE    TIPO_STRUCT 3
#DEFINE TAMANHO_STRUCT 4
#DEFINE DECIMAL_STRUCT 5
#DEFINE  TITULO_STRUCT 6
#DEFINE DESCRIC_STRUCT 7
#DEFINE PICTURE_STRUCT 8
#DEFINE CONTEXT_STRUCT 9
#DEFINE OBRIGAT_STRUCT 10

#DEFINE TABLE_MEMORY 1
#DEFINE FIELD_MEMORY 2
#DEFINE VALUE_MEMORY 3
#DEFINE TOTAL_MEMORY 3

#DEFINE INTEG_MVNGINTER 1
#DEFINE INTEG_MVPIMSINT 2

//------------------------------
// Força a publicação do fonte
//------------------------------
Function _NGMovBem()
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} NGMovBem
Classe de Movimentacao de Bens.

@author Felipe Nathan Welter
@since 12/02/2013
@version P12
/*/
//------------------------------------------------------------------------------
Class NGMovBem FROM NGGenerico

	Method New() CONSTRUCTOR

	//METODOS PUBLICOS
	Method validBusiness()
	Method upsert()
	Method delete()

	Method ableContador(lAble)

	//METODOS PRIVADOS
	//--

	//ATRIBUTOS PUBLICOS
	//--

	//ATRIBUTOS PRIVADOS
	Data lAbleContador	AS Boolean
	Data lClassAsset	As Boolean  // Permite identificar se a gravação é originada da classe de bens

EndClass

//------------------------------------------------------------------------------
/*/{Protheus.doc} New
Método inicializador da classe.

@author Felipe Nathan Welter
@since 12/03/2013
@version P12
@return Self O objeto criado.
/*/
//------------------------------------------------------------------------------
Method New( oST9 ) Class NGMovBem

	Local nPosInteg := 0 //028963

	_Super:New()
	::SetAlias("TPN")
	::initFields(.T.)

	::setUniqueField("TPN_FILIAL")
	::setUniqueField("TPN_CODBEM")
	::setUniqueField("TPN_DTINIC")
	::setUniqueField("TPN_HRINIC")
	::setUniqueField("TPN_CCUSTO")
	::setUniqueField("TPN_CTRAB")
	::setUniqueField("TPN_POSCON")
	//TPN_POSCO2 - permite alteracao desde que esteja vazio

	::lAbleContador := .T.
	::lClassAsset	:= ( ValType( oST9 ) == "O" )

	//--inicio--SS 028963 //
	aAdd(::aInteg,.T.)
	nPosInteg := Len(::aInteg)
	If FunName() == "MNTA080" .Or. FunName() == "MNTA083" .Or. FunName() == "MNTA084"
		//Caso a chamada do NGMovBem seja via Cadastro de Bem/Veículo/Pneus (MNTA080,083,084(MNTBEM/MNTVEICULO/MNTPNEU-Integração)
		//não deverá realizar a chamada FWIntegDef do MNTA080, pois essa chamada é duplicada visto que o próprio MNTA080/083/084 já o
		//fez. Quando no MNTA082 a chamada será feita como MNTA084 por esse motivo só validado o cadastro veículo(MNTA084) e não o
		//cadastro de Veículo TMS (MNTA082.)
		::aInteg[nPosInteg] := .F.
	EndIf
	//---fim----SS 028963 //

	If !FindFunction("MNTI080")
		nPos := asCan(::aInteg, {|x| x[1] == INTEG_MVPIMSINT})
		::aInteg[nPos][2] := .F.
	EndIf

Return Self

//------------------------------------------------------------------------------
/*/{Protheus.doc} validBusiness
Método que realiza a validação da regra de negócio da classe.

@param nOp Número da operação (3(insert)/4(update)=upsert; 5=delete)
@author Felipe Nathan Welter
@since 13/02/2013
@version P12
@return lValid Validação ok.
@obs este método não é chamado diretamente.
/*/
//------------------------------------------------------------------------------
Method ValidBusiness() Class NGMovBem

	Local lRet := .T.
	Local cError := ''
	Local cQuery := ''

	If ::IsUpsert()
		//001 - valida codigo do bem
		If !NGIFDBSEEK("ST9",M->TPN_CODBEM,1) .And. .Not. ::lClassAsset
			lRet := .F.
			cError := "Código do bem não cadastrado."
		EndIf

		//002 - data deve estar preenchida
		//003 - data deve ser menor ou igual a data do sistema
		If lRet .And. (Empty(M->TPN_DTINIC) .Or. M->TPN_DTINIC > dDataBase)
	      lRet := .F.
			cError := "Data devera ser menor ou igual a data atual"
		EndIf

		//004 - valida formato da hora
		If lRet .And. !NGVALHORA(M->TPN_HRINIC,.F.)
			lRet := .F.
			cError := "Formato de hora inválido."
		EndIf

		//005 - valida se centro de custo existe
		If lRet
			lRet   := NGIFDBSEEK( "CTT",M->TPN_CCUSTO,1 ) // I3_FILIAL+I3_CUSTO+I3_CONTA+I3_MOEDA
			cError := If(lRet,'',"Centro de Custo não existe.")
		EndIf

		//006- valida centro de custo conforme CTB
		If lRet .And. !CTB105CC(M->TPN_CCUSTO)
			lRet := .F.
			cError := "Centro de Custo inválido."
		EndIf

		//007 - valida se centro de trabalho existe
		If lRet .And. !Empty(M->TPN_CTRAB)
			If !NGIFDBSEEK('SHB',M->TPN_CTRAB,1)
				lRet := .F.
				cError := "Centro de Trabalho não existe."
			Else
				//008 - verifica se centro de trabalho está vinculado ao centro de custo
				If !CHKCENTRAB(M->TPN_CTRAB,M->TPN_CCUSTO)
					lRet := .F.
					cError := "Centro de Trabalho não está relacionado ao Centro de Custo."
				EndIf
			EndIf
		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// 009 - C.C.+C.T. deve ser diferente do C.C.+C.T. anterior e/ou posterior
	//--------------------------------------------------------------------------
	If lRet .And. ::IsUpsert() .And. .Not. ::lClassAsset
		aAnterior := {}
		aPosterior:= {}
		dbSelectArea("TPN")
		dbSetOrder(01)
		dbSeek(M->TPN_FILIAL+M->TPN_CODBEM+DTOS(M->TPN_DTINIC)+M->TPN_HRINIC,.T.)
		//localiza registro anterior
		dbSkip(-1)
		If !Bof() .And. TPN->TPN_FILIAL == M->TPN_FILIAL .And. TPN->TPN_CODBEM == M->TPN_CODBEM
			aAnterior := {TPN->TPN_CCUSTO, TPN->TPN_CTRAB}
		EndIf
		//localiza registro posterior
		dbSkip(1)
		If TPN->TPN_FILIAL == M->TPN_FILIAL .And. TPN->TPN_CODBEM == M->TPN_CODBEM .And.;
		TPN->TPN_DTINIC != M->TPN_DTINIC .And. TPN->TPN_HRINIC != M->TPN_HRINIC
			aPosterior := {TPN->TPN_CCUSTO, TPN->TPN_CTRAB}
		EndIf

		// Compara C.C. e C.T. caso não se trate de um bem que esteja entrando em uma estrutura

		If !( (Empty(aAnterior) .Or. aAnterior[1]+aAnterior[2] <> M->TPN_CCUSTO+M->TPN_CTRAB) .And.;
		(Empty(aPosterior) .Or. aPosterior[1]+aPosterior[2] <> M->TPN_CCUSTO+M->TPN_CTRAB))
			lRet := .F.
			cError := "Centro de custo informado deve ser diferente do centro de custo anterior e/ou posterior ou "
			cError += "centro de trabalho informado deve ser diferente do centro de trabalho anterior e/ou posterior."
		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// 010 - Valida campo 'Utilizado' conforme opcoes do combobox ("UDP")
	//--------------------------------------------------------------------------
	If lRet .And. ::IsUpsert() .And. !(M->TPN_UTILIZ $ "UDP")
		lRet := .F.
		cError := 'Conteúdo inválido para o campo "utilizado".'
	EndIf

	//--------------------------------------------------------------------------
	// 011 - valida se bem tem contador 1 na inclusao
	//--------------------------------------------------------------------------
	If lRet .And. ::IsInsert() .And. ::lAbleContador .And. .Not. ::lClassAsset
		If NGSEEK("ST9",M->TPN_CODBEM,1,'T9_TEMCONT') == "S"
			If Empty(M->TPN_POSCON)
				lRet := .F.
				cError := "Contador 1 não informado."
			//012 - valida contador 1 positivo
			ElseIf !(M->TPN_POSCON > 0)
				lRet := .F.
				cError := "Contador 1 deve ser positivo."
			//013 - valida limite do contador 1
			ElseIf !CHKPOSLIM(M->TPN_CODBEM,M->TPN_POSCON,1)
				lRet := .F.
				cError := "Contador 1 supera o limite."
			EndIf
			//014 - valida historico de contador 1
			If lRet .And. !NGCHKHISTO( M->TPN_CODBEM, M->TPN_DTINIC, M->TPN_POSCON, M->TPN_HRINIC, 1,, .T.)
				lRet := .F.
				cError := "Problema com histórico do contador 1."
			EndIf
			//015 - valida variacao dia do contador 1
			If lRet .And. !NGVALIVARD(M->TPN_CODBEM, M->TPN_POSCON, M->TPN_DTINIC, M->TPN_HRINIC, 1, .T.)
				lRet := .F.
				cError := "Problema na variação dia do contador 1."
			EndIf
		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// 016 - valida se bem tem contador 2 na inclusao
	//--------------------------------------------------------------------------
	If lRet .And. ::IsInsert() .And. ::lAbleContador .And. .Not. ::lClassAsset
		If NGIFDBSEEK("TPE",M->TPN_CODBEM,1) .And. TPE->TPE_SITUAC <> '2'
			If Empty(M->TPN_POSCO2)
				lRet := .F.
				cError := "Contador 2 não informado."
			//017 - valida contador 2 positivo
			ElseIf !(M->TPN_POSCO2 > 0)
				lRet := .F.
				cError := "Contador 2 deve ser positivo."
			//018 - valida limite do contador 2
			ElseIf !CHKPOSLIM(M->TPN_CODBEM,M->TPN_POSCO2,2)
				lRet := .F.
				cError := "Contador 2 supera o limite."
			EndIf
			//019 - valida historico de contador 2, se for inclusao
			If lRet .And. !NGCHKHISTO( M->TPN_CODBEM, M->TPN_DTINIC, M->TPN_POSCO2, M->TPN_HRINIC, 2,, .T.)
				lRet := .F.
				cError := "Problema com histórico do contador 2."
			EndIf
			//020 - valida variacao dia do contador 2, se for inclusao
			If lRet .And. !NGVALIVARD(M->TPN_CODBEM, M->TPN_POSCO2, M->TPN_DTINIC, M->TPN_HRINIC, 2, .T.)
				lRet := .F.
				cError := "Problema na variação dia do contador 2."
			EndIf
		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// 021 - nao permite excluir unica movimentacao do bem caso o bem nao tenha sido excluido
	//--------------------------------------------------------------------------
	If ::IsDelete() .And. .Not. ::lClassAsset

		cQuery := " SELECT COUNT(TPN_CODBEM) AS TOTAL FROM " + RetSQLName("TPN") + " TPN"
		cQuery += " WHERE TPN.TPN_FILIAL = " + ValToSql(xFilial("TPN"))
		cQuery += "   AND TPN.TPN_CODBEM = " + ValToSql(M->TPN_CODBEM)
		cQuery += "   AND D_E_L_E_T_ <> '*'"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		If (cAliasQry)->TOTAL == 1
			dbSelectArea("ST9")
			dbSetOrder(01)
			If dbSeek( xFilial("ST9") + M->TPN_CODBEM )
				lRet := .F.
				cError := "Não é permitido excluir a única movimentação do bem."
			EndIf
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf

	If !lRet
		::addError(cError)
	EndIf

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} upsert
Método para inclusao e alteracao dos alias definidos para a classe.

@author Felipe Nathan Welter
@since 12/04/2013
@version P12
@return lUpsert Operação ok.
@sample If oObj:valid()
           oObj:upsert()
        Else
           Help(,,'HELP',, oTPN:getErrorList()[1],1,0)
        EndIf
/*/
//------------------------------------------------------------------------------
Method Upsert() Class NGMovBem

	Local aAreaTPN  := TPN->(GetArea())
	Local aRet      := {}
	Local lRet      := .T.
	Local cGERAPREV := AllTrim(GetMv("MV_NGGERPR"))
	Local lTAG      := ((NGCADICBASE("TPN_TAG","D","TPN",.F.) .And. NGCADICBASE("T9_TAG","D","ST9",.F.),.F.))
	Local nOp       := ::getOperation()
	Local nI        := 0
	Local nPosInteg := Len(::aInteg) //028963
	Local lPIMSINT	:= SuperGetMV("MV_PIMSINT",.F.,.F.)
	Local lOMainWnd := Type("oMainWnd") == "O"
	Local lIntATF   := SuperGetMv("MV_NGMNTAT",.F.,"N") $ '2/3'

	//carrega todas os campos da classe em memoria de trabalho
	::classToMemory()

	BEGIN TRANSACTION

	//--------------------------------------------------------------------------
	// 001 - inclui/atualiza registro na TPN
	//--------------------------------------------------------------------------
	_Super:Upsert()

	//--------------------------------------------------------------------------
	// Processa rotinas de integração
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsInsert()
		For nI := 1 To Len( ::aInteg )

			//007 - integracao com o PIMS atraves do EAI
			nPos := asCan(::aInteg, {|x| x[1] == INTEG_MVPIMSINT})
			If nI == INTEG_MVPIMSINT .And. ::aInteg[nPos][2]
				If lPIMSINT
					NGIntPIMS("TPN",::getRecNo("TPN"),nOp)
				EndIf
			EndIf

			//008 - integração via mensagem unica (MNTI080)
			nPos := asCan(::aInteg, {|x| x[1] == INTEG_MVNGINTER})
			If nI == INTEG_MVNGINTER .And. ::aInteg[nPos][2] .And. ::aInteg[nPosInteg]

				If AllTrim( GetNewPar( "MV_NGINTMB","2" ) ) == "1" // Integração com Mensagem única ativada
					aRet   := {.F.,'Problema no processo de integração (Equipment)'}
					bBlock := { || aRet := FWIntegDef("MNTA080", EAI_MESSAGE_BUSINESS, TRANS_SEND, Nil ) }

					If lOMainWnd
						MsgRun('Aguarde integração com backoffice...','Equipment',bBlock)
					Else
						Eval(bBlock)
					EndIf

					If ValType(aRet) == "A" .And. !aRet[1]
						lRet := .F.
						DisarmTransaction()
						::addError(aRet[2])
					EndIf

				EndIf
			EndIf
		Next nI
	EndIf

	//--------------------------------------------------------------------------
	// Grava contadores
	//--------------------------------------------------------------------------
	If lRet .And. ::IsInsert() .And. ::lAbleContador .And. .Not. ::lClassAsset

		//002 - reporte de contador 1
		If NGSEEK("ST9",M->TPN_CODBEM,1,'T9_TEMCONT') == "S" .And. M->TPN_POSCON > 0
			NGTRETCON(M->TPN_CODBEM,M->TPN_DTINIC,M->TPN_POSCON,M->TPN_HRINIC,1,,.T.)
		EndIf

		//003 - reporte de contador 2
		If NGIFDBSEEK("TPE",M->TPN_CODBEM,1) .And. TPE->TPE_SITUAC <> '2' .And. M->TPN_POSCO2 > 0
			NGTRETCON(M->TPN_CODBEM,M->TPN_DTINIC,M->TPN_POSCO2,M->TPN_HRINIC,2,,.F.)
		EndIf

		//004 - Gera OS automatica por contador
		If (cGERAPREV = "S" .Or. cGERAPREV = "C") .And. (!Empty(M->TPN_POSCON) .Or. !Empty(M->TPN_POSCO2))
			If NGCONFOSAUT(cGERAPREV)
				NGGEROSAUT(M->TPN_CODBEM,If(!Empty(M->TPN_POSCON),M->TPN_POSCON,M->TPN_POSCO2))
			EndIf
		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// Integra com Ativo Fixo
	//--------------------------------------------------------------------------
	If lRet .And. ::IsInsert()

		If !( ::lClassAsset )

			//carrega o centro de custo posterior
			DBSelectArea("TPN")
			DBSetOrder(01)
			DBSeek(xFilial("TPN")+M->TPN_CODBEM+DTOS(M->TPN_DTINIC)+M->TPN_HRINIC)
			DBSkip()
			If TPN->TPN_FILIAL + TPN->TPN_CODBEM == M->TPN_FILIAL + M->TPN_CODBEM
				cCCustoD := TPN->TPN_CCUSTO
			Else
				cCCustoD := ''
			EndIf

			//005 - Atualiza CC e CT do bem, da estrutura e demais operações realizadas pela função NGRETCC()
			If lRet
				lRet := NGRETCC( M->TPN_CODBEM,M->TPN_DTINIC,M->TPN_CCUSTO,M->TPN_CTRAB,M->TPN_HRINIC,M->TPN_UTILIZ,;
					M->TPN_OBSERV,,,cCCustoD,If(lTAG,TPN->TPN_TAG,Nil ))
				If !lRet
					::addError( 'Problema no processo de integração com Ativo Fixo.' )
				EndIf
			EndIf
		Else
			// Caso centro de custo do bem cadastrado pelo Ativo fixo estiver vazio,
			// faz repasse do centro de custo informado no bem MNT
			If lIntATF .And. FindFunction( 'MNTALTATF' )
				aRet := MNTALTATF( M->T9_CODIMOB, M->T9_CCUSTO, .F. )
				If !aRet[ 1 ]
					::addError( aRet[ 2 ] )
				EndIf
			EndIf
		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// Atualiza conjustos hridaulicos
	//--------------------------------------------------------------------------
	If lRet .And. ::IsInsert() .And. .Not. ::lClassAsset

		//006 - Atualização do conjunto hidráulico (TKS)
		TPN->(RestArea(aAreaTPN))
		If NGCADICBASE("TKS_BEM","A","TKS",.F.)
			//conjuntos hidraulicos relacionados ao bem devem estar sempre com o centro
			//de custo atual do bem
			DBSelectArea( "TPN" )
			DBSetOrder( 1 )
			DBSeek(xFilial("TPN")+M->TPN_CODBEM+DTOS(M->TPN_DTINIC)+M->TPN_HRINIC)
			DBSkip()
			If TPN->TPN_FILIAL + TPN->TPN_CODBEM != M->TPN_FILIAL + M->TPN_CODBEM
				//se eh o ultimo registro, atualiza conjuntos hidraulicos
				DBSelectArea( "TKS" )
				DBSetOrder( 6 )
				DBSeek( xFilial("TKS") + M->TPN_CODBEM )
				While .Not. Eof() .And. TKS->TKS_BEM == M->TPN_CODBEM
					RecLock("TKS",.F.)
					TKS->TKS_CCCJN := M->TPN_CCUSTO
					TKS->(MsUnLock())
					dbSkip()
				EndDo
			EndIf
		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// Finaliza processo de gravação
	//--------------------------------------------------------------------------
	If !::IsValid()
		DisarmTransaction()
	EndIf

	END TRANSACTION
	MsUnlockAll()

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} delete
Método para exclusão dos alias definidos para a classe.

@author Felipe Nathan Welter
@since 12/04/2013
@version P12
@return lDelete Confirmação da operação.
@sample If oObj:valid()
           oObj:upsert()
        Else
           Help(,,'HELP',, oTPN:getErrorList()[1],1,0)
        EndIf
/*/
//------------------------------------------------------------------------------
Method Delete() Class NGMovBem

	Local cQuery   := ''
	Local aAreaTPN := TPN->(GetArea())

	//carrega todas os campos da classe em memoria de trabalho
	::classToMemory()

	BEGIN TRANSACTION

	If ::IsValid() .And. ::lAbleContador .And. .Not. ::lClassAsset

		//----------------------------------------------------------------------
		// 001 - Exclui o lancamento de contador 1
		//----------------------------------------------------------------------
		If NGSEEK("ST9",TPN->TPN_CODBEM,1,'T9_TEMCONT') == "S" .And. TPN->TPN_POSCON > 0
			MNT470EXCO(TPN->TPN_CODBEM,TPN->TPN_DTINIC,TPN->TPN_HRINIC,1)
		EndIf
		//----------------------------------------------------------------------
		// 002 - Exclui o lancamento de contador  2
		//----------------------------------------------------------------------
		If NGIFDBSEEK("TPE",TPN->TPN_CODBEM,1) .And. TPN->TPN_POSCO2 > 0
			MNT470EXCO(TPN->TPN_CODBEM,TPN->TPN_DTINIC,TPN->TPN_HRINIC,2)
		EndIf
	EndIf

	If ::IsValid() .And. .Not. ::lClassAsset

		//----------------------------------------------------------------------
		// Se for a ultima movimentacao registrada, precisa atualizar o bem e a estrutura
		//----------------------------------------------------------------------
		cQuery := " SELECT COUNT(TPN_CODBEM) AS TOTAL FROM " + RetSQLName("TPN") + " TPN"
		cQuery += " WHERE TPN.TPN_FILIAL = " + ValToSql(xFilial("TPN"))
		cQuery += "   AND TPN.TPN_CODBEM = " + ValToSql(TPN->TPN_CODBEM)
		cQuery += "   AND TPN.TPN_DTINIC || TPN.TPN_HRINIC > "+ValToSql(DTOS(TPN->TPN_DTINIC)+TPN->TPN_HRINIC)
		cQuery += "   AND D_E_L_E_T_ <> '*'"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		lAtuStruct := ((cAliasQry)->TOTAL == 0)
		(cAliasQry)->(dbCloseArea())

		//----------------------------------------------------------------------
		// Busca o centro de custo anterior à movimentacao
		//----------------------------------------------------------------------
		TPN->(RestArea(aAreaTPN))
		cQuery := " SELECT TPN.TPN_CCUSTO, TPN.TPN_CTRAB, TPN.TPN_DTINIC, TPN.TPN_HRINIC FROM " + RetSQLName( "TPN" ) + " TPN"
		cQuery += " WHERE TPN.TPN_FILIAL = " + ValToSql( TPN->TPN_FILIAL )
		cQuery += "  AND TPN.TPN_CODBEM = " + ValToSql( TPN->TPN_CODBEM )
		cQuery += "  AND TPN.TPN_DTINIC || TPN.TPN_HRINIC = "
		cQuery += "  (SELECT MAX( TPN1.TPN_DTINIC || TPN1.TPN_HRINIC ) FROM " + RetSQLName( "TPN" ) + " TPN1"
		cQuery += " WHERE TPN1.TPN_FILIAL = " + ValToSql( TPN->TPN_FILIAL )
		cQuery += "  AND TPN_CODBEM = " + ValToSql( TPN->TPN_CODBEM )
		cQuery += "  AND D_E_L_E_T_ <> '*'
		cQuery += "  AND TPN_DTINIC || TPN_HRINIC < " + ValToSql(DTOS( TPN->TPN_DTINIC )+TPN->TPN_HRINIC) + ")"
		cQuery += "  AND D_E_L_E_T_ <> '*'"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		cCUSANT := (cAliasQry)->TPN_CCUSTO
		cTRAANT := (cAliasQry)->TPN_CTRAB
		dDTAANT := (cAliasQry)->TPN_DTINIC
		cHORANT := (cAliasQry)->TPN_HRINIC
		(cAliasQry)->(dbCloseArea())

		cCODBEMTPN := TPN->TPN_CODBEM
		dDATAIVTPN := TPN->TPN_DTINIC
		cCCUSTOTPN := TPN->TPN_CCUSTO
		cCENTRATPN := TPN->TPN_CTRAB
		cHORAINTPN := TPN->TPN_HRINIC

		//----------------------------------------------------------------------
		// 003 - Exclui a movimentacao de centro de custo dos filhos
		//----------------------------------------------------------------------
		NGATUEX470( cCODBEMTPN,dDATAIVTPN,cCCUSTOTPN,cCENTRATPN,;
						cHORAINTPN,cCUSANT,cTRAANT,dDTAANT,cHORANT,lAtuStruct)

		//----------------------------------------------------------------------
		// 004 - Atualização do conjunto hidráulico (TKS)
		//----------------------------------------------------------------------
		If NGCADICBASE("TKS_BEM","A","TKS",.F.) .And. lAtuStruct
			dbSelectArea("TKS")
			dbSetOrder(6)
			If dbSeek(xFilial("TKS")+TPN->TPN_CODBEM)
				While !Eof() .and. TKS->TKS_BEM == TPN->TPN_CODBEM
					RecLock("TKS",.F.)
					TKS->TKS_CCCJN := cCUSANT
					TKS->(MsUnLock())
					dbSkip()
				EndDo
			EndIf
		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// 005 - Funcao de integracao com o PIMS atraves do EAI
	//--------------------------------------------------------------------------
	If ::IsValid()
		If SuperGetMV("MV_PIMSINT",.F.,.F.) .And. FindFunction("NGIntPIMS")
			NGIntPIMS( 'TPN' , ::GetRecno('TPN') , ::GetOperation() )
		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// Exclui movimentação e relacionados
	//--------------------------------------------------------------------------
	_Super:Delete()

	//--------------------------------------------------------------------------
	// Finaliza processamento
	//--------------------------------------------------------------------------
	If !::IsValid()
		DisarmTransaction()
	EndIf

	END TRANSACTION
	MsUnlockAll()

Return ::IsValid()
//---------------------------------------------------------------------
/*/{Protheus.doc} ableContador
Permite desconsiderar funcionalidades de contador, que envolve
validações,  gravação e exclusão do registro de histórico.

@param lAble Indica se considera ou não processamentos de contador.
@author Felipe Nathan Welter
@since 25/04/2013
@version P12
@return Nil
@obs Rotinas que já realizam validação e reporte de contador e ao mesmo
     tempo gravam o histórico de movimentação de centro de custo podem
     desabilitar essa funcionalidade pontualmente. Um exemplo é o
     cadastro de equipamentos. Por padrão, contador é considerado.
@sample oObj:ableContador(.F.)
/*/
//---------------------------------------------------------------------
Method ableContador(lAble) Class NGMovBem
	::lAbleContador := lAble
Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} NGATUEX470
Atualiza o centro de custo do registro que foi excluído e dos filhos
da estrutura

@param String cBem: indica código do bem, obrigatório
@param Date dLeit: Data Início, obrigatório
@param String cCusto: indica Centro de Custo, obrigatório
@param String cTrab: indica Centro de Trabalho, obrigatório
@param String cHora: indica Hora Início, obrigatório
@param String cCUSTOAN: indica Centro de Custo Anterior, obrigatório
@param String cCTRABAN: indica Centro de Trabalho anterior, obrigatório
@param Date dDATAAN: indica Data Anterior, obrigatório
@param String cHORANT: indica Hora Anterior, obrigatório
@param Boolean lATUST9: indica se deve atualizar o centro de custo no cadastro
do bem

@author Elisangela Costa
@since 08/08/2006
@version P11
@return Boolean lRet: ever true
/*/
//---------------------------------------------------------------------

Static Function NGATUEX470( cBEM,dLEIT,cCUSTO,cTRAB,cHORA,cCUSTOAN,cCTRABAN,dDATAAN,cHORANT,lATUST9 )

	Local lRet := .T.
	Private lSim := .F. //Variável lógica que armazena .T. caso seja respondido "Sim" e .F. para "Não"

	Private aVETBENS := {}

	If lATUST9
	   DbSelectArea( "ST9" )
	   DbSetOrder( 01 ) // T9_FILIAL+T9_CODBEM
	   If DbSeek( xFilial( "ST9" ) + cBEM )
		   RecLock( "ST9",.F. )
		   ST9->T9_CCUSTO  := cCUSTOAN
		   ST9->T9_CENTRAB := If( !Empty(cCTRABAN),cCTRABAN,"" )
		   MsUnLock( "ST9" )

		   //Atualiza o centro de custo no ativo fixo
		   NGATUATF( ST9->T9_CODIMOB,cCUSTOAN )
		EndIf
	EndIf

	//-----------------------------------------------------------------
	// Atualiza o Centro de Custo e Centro de Trabalho dos Bens Filhos
	//-----------------------------------------------------------------
	aAdd( aVETBENS,{ cBEM,dDATAAN,cHORANT,cCUSTOAN,cCTRABAN } )
	NGEXATCCFI( cBEM,cCUSTO,cTRAB,dLEIT,cHORA )


   //Busca as ordens de servico do intervalo do centro de custo
   If IsInCallStack( "MNTA470" ) .And. MsgYesNo( "Deseja VERIFICAR se existem O.S. a serem"+CRLF+;
              "transferidas de Centro de Custo/Centro de Trabalho" + CRLF + CRLF + ;
              "após a data de movimentação" + CRLF + CRLF + ;
              DtoC(M->TPN_DTINIC) + " - Hora " + Alltrim(M->TPN_HRINIC)+ "?" + CRLF + CRLF + ;
              "Confirma ?","ATENCAO" )
      lSim := .T.
      NGMOVCCUS( , , ,.F.,dDATAAN,cHORANT,cCUSTOAN,dLEIT,cHORA, lSim)
   EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} NGEXATCCFI
Exclui o registro dos filhos do TPN e atualiza ST9 se o bem pai não
possuir registro posterior

@param String cBEM: indica código do bem
@param String cCUSTO: indica Centro de Custo
@param String cTRAB: indica Centro de Trabalho
@param Date dLEIT: indica Data Início
@param String cHORA: indica Hora Início

@author Elisangela Costa
@since 08/08/2006
@version P11
@return Boolean lRet: ever true
/*/
//---------------------------------------------------------------------

Static Function NGEXATCCFI( cBEM,cCUSTO,cTRAB,dLEIT,cHORA )

	Local lRet 		:= .T.
	Local aESTSTZ 	:= {}, nn, lATUST9TPN := .F.
	Local cCUSTOANT := Space(Len(TPN->TPN_CCUSTO)),cCENTRAN := Space(06), dDATAANT := CTOD("  /  /  "), cHORAANT:= "  :  "
	Local lPIMSINT	:= SuperGetMV("MV_PIMSINT",.F.,.F.)

	// CARREGA OS BENS FILHOS
	aESTSTZ := NGRETSTCDT( cBEM, dLEIT, cHORA )
	If Len(aESTSTZ) > 0
	   For nn := 1 To Len(aESTSTZ)

	      If aESTSTZ[nn][1] <> cBEM
		      lATUST9TPN := .F.
		      dbSelectArea("ST9")
		      dbSetOrder(01)
		      If dbSeek(xFilial("ST9")+aESTSTZ[nn][1])
		         If ST9->T9_MOVIBEM == "S"
		            dbselectarea("TPN")
		            dbsetorder(1)
		            If dbseek(xFilial("TPN")+aESTSTZ[nn][1]+Dtos(dLEIT)+cHORA)

		               dbSkip(-1)
		               If !Bof() .And. TPN->TPN_FILIAL == xFilial("TPN") .And. TPN->TPN_CODBEM == aESTSTZ[nn][1]
		                  cCUSTOANT:= TPN->TPN_CCUSTO
		                  cCENTRAN := TPN->TPN_CTRAB
		                  dDATAANT := TPN->TPN_DTINIC
		                  cHORAANT := TPN->TPN_HRINIC
		               EndIf
		               dbSkip()

		               dbSkip()
		               If !Eof() .And. TPN->TPN_FILIAL <> xFilial("TPN") .Or. TPN->TPN_CODBEM <> aESTSTZ[nn][1]
		                  lATUST9TPN := .T.
		               EndIf
		            EndIf

		            If lATUST9TPN
		               dbSelectArea("ST9")
		               RecLock("ST9",.F.)
		               If !Empty(cCUSTO)
		                  ST9->T9_CCUSTO  := If(!Empty(cCUSTOANT),cCUSTOANT,ST9->T9_CCUSTO)
		                  ST9->T9_CENTRAB := If(!Empty(cCENTRAN),cCENTRAN,"")
		               EndIf
		               MsUnLock("ST9")

		               //Atualiza o centro de custo no ativo fixo
		               If !Empty(cCUSTOANT)
		                  NGATUATF(ST9->T9_CODIMOB,cCUSTOANT)
		               EndIf
		            EndIf
		         EndIf
		      EndIf
	      dbselectarea("TPN")
	      dbsetorder(2)
	      If dbseek(xFilial("TPN")+aESTSTZ[nn][1]+cCUSTO+cTRAB+Dtos(dLEIT)+cHORA)

				oTPN := NGMovBem():New()
				oTPN:setOperation(5)
				If !oTPN:Load({xFilial("TPN")+aESTSTZ[nn][1]+Dtos(dLEIT)+cHORA})
					MsgInfo(oTPN:getErrorList()[1])
				Else
					If oTPN:valid()
						oTPN:delete()
					Else
						Help(" ",1,"NAO CONFORMIDADE",,oTPN:getErrorList()[1],3,1)
					EndIf
				EndIf
				oTPN:Free()

				//Funcao de integracao com o PIMS atraves do EAI
				If lPIMSINT
					NGIntPIMS("TPN",TPN->(RecNo()),5)
				EndIf

	      EndIf
	      AAdd(aVETBENS,{aESTSTZ[nn][1],dDATAANT,cHORAANT,cCUSTOANT,cCENTRAN})
	     EndIf
	   Next nn
	EndIf

Return lRet
