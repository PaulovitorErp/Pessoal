#INCLUDE "PROTHEUS.CH"
#INCLUDE "MNTBEM.CH"
#INCLUDE "FWADAPTEREAI.CH"

// Força a publicação do fonte
Function _MntBem()
Return

#DEFINE _OPERATION_INACTIVATE_   6 // Inativar

//------------------------------------------------------------------------------
/*/{Protheus.doc} MntBem
Classe de Bens

@author NG Informática Ltda.
@since 01/01/2015
@version P12
/*/
//------------------------------------------------------------------------------
Class MntBem FROM NGGenerico

	Method New() CONSTRUCTOR

	// Metodos Publicos
	Method ValidBusiness()
	Method Upsert()
	Method Delete()
	Method Inactivate()

	// Metodos Privados
	Method GetAssetAtt()
	Method IsMainAsset()
	Method IsHasStruc()
	Method IsInactivate()
	Method IsSale()

	// Atributos Privados
	Data aMntOs		  As Array  Init {} // Ordens de Serviços
	Data aNGMovBem	  As Array  Init {} // Historico de movimentacao de C.C.
	Data aInactive    As Array  Init {} // Atributos para inativação
	Data cMotivo      As STRING Init " "
	Data cTPCONT      As STRING Init " "
	Data lReactivate  As BOOLEAN Init .F.

EndClass

//------------------------------------------------------------------------------
/*/{Protheus.doc} New
Método inicializador da classe

@author NG Informática Ltda.
@since 01/01/2015
@version P12
@return Self O objeto criado.
/*/
//------------------------------------------------------------------------------
Method New() Class MntBem

	_Super:New()

	// Alias formulario
	::SetAlias( 'ST9' )
	::SetAlias( 'TPE' )

	// Alias grid
	::SetAliasGrid( 'STB' )
	::SetAliasGrid( 'TPY' )

	// Campos não-alteraveis
	::SetUniqueField( 'T9_FILIAL' )
	::SetUniqueField( 'T9_CODBEM' )

	// Define o tipo de validação da classe
	::SetValidationType('OUB')

	// Define quais tabelas não relacionadas
	::SetNoDelete('TPN')
	::SetNoDelete('TCJ')
	::SetNoDelete('SN1')

	// O informe da tabela não é obrigatório
	::SetOptional('TPE')

	::aMntOs	  := {}
	::aNGMovBem	  := {}
	::aInactive   := {}
	::cMotivo     := " "
	::cTPCONT     := " "
	::lReactivate := .F. //Indica se o bem está sendo reativado.

Return Self

//------------------------------------------------------------------------------
/*/{Protheus.doc} ValidBusiness
Método que realiza a validação da regra de negócio da classe.

@param nOp Número da operação (3(insert)/4(update)=upsert; 5=delete)
@author NG Informática Ltda.
@since 01/01/2015
@version P12
@return lValid Validação ok.
@obs este método não é chamado diretamente.
/*/
//------------------------------------------------------------------------------
Method ValidBusiness() Class MntBem

	// Alias: Armazena posição de registros
	Local aAreaST6 := ST6->(GetArea())
	Local aAreaTPE := TPE->(GetArea())
	Local aAreaSTC := STC->(GetArea())
	Local aAreaSTJ := STJ->(GetArea())

	// Grid: Auxiliares para leitura
	Local nLine, aHeaderAux, aColsAux

	// Header(STB): Caracteriticas
	Local nCodCar, nCodDet

	// Header(TPY): Pecas de Reposicao
	Local nCodPro, nQuanti, nQtdGar, nUniGar

	// Auxiliares de Query
	Local cQuery    := ''
	Local cAliasQry := ''

	// Variaveis gerais
	Local dDtIniTPN, cSeekKey, oSTJ, oTPN, bBlock, nStatus

	// Armazena a situação anterior a alteração
	Local cSitOld := NGSEEK("ST9" , ::GetValue('T9_CODBEM') , 1 , "T9_SITBEM" )

	//Variaveis de inativação
	Local cCause     := ""
	Local cHourCont1 := ""
	Local dDateCont2 := CtoD("  /  /    ")
	Local cHourCont2 := ""

	Local cVCBEM     := ::GetValue("T9_CODBEM")  // Código do Bem alterado

	Local aLog := {}
	Local nInd := 0
	Local nTot := 0

	//--------------------------------------------------------------------------
	// MNTBEM.010 - Campos obrigatórios de Contador
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpsert()

		If 	::GetValue('T9_TEMCONT') $ 'SPI'

			// MNTBEM.010.001 - Tipo do contador
			If Empty(::GetValue('T9_TPCONTA'))
				::AddError(::MsgRequired('T9_TPCONTA'))

			// MNTBEM.010.002 - Data do ultimo acompanhamento
			ElseIf Empty(::GetValue('T9_DTULTAC'))
				::AddError(::MsgRequired('T9_DTULTAC'))
			EndIf

		EndIf

		If ::IsValid() .And. ::GetValue('T9_TEMCONT') == "I"

			// MNTBEM.010.003 - Limite do contador
			If Empty(::GetValue('T9_LIMICON'))
				::AddError(::MsgRequired("T9_LIMICON"))
			EndIf

		ElseIf  ::IsValid() .And. ::GetValue('T9_TEMCONT') == "S"

			// MNTBEM.010.004 - Posicao atual do contador
			If Empty(::GetValue('T9_POSCONT'))
				::AddError(::MsgRequired("T9_POSCONT"))

			// MNTBEM.010.005 - Variacao dia
			ElseIf Empty(::GetValue('T9_VARDIA'))
				::AddError(::MsgRequired("T9_VARDIA"))

			// MNTBEM.010.006 - Limite do contador
			ElseIf Empty(::GetValue('T9_LIMICON'))
				::AddError(::MsgRequired("T9_LIMICON"))

			// MNTBEM.010.007 - Contador acumulado
			ElseIf Empty(::GetValue('T9_CONTACU'))
				::AddError(::MsgRequired("T9_CONTACU"))

			EndIf
		EndIf

	    If ::GetOperation() == 4

			::lReactivate := ST9->T9_SITBEM == "I" .And. ::GetValue("T9_SITBEM") == "A" //Indica se está reativando o Bem.
			::cTPCONT     := NGSEEK("ST9",::GetValue("T9_CODBEM") ,1,"T9_TEMCONT")      //Como estava o Tipo do contador antes da alteração.

	        If ::IsHasStruc() .And. ::GetValue('T9_TEMCONT') <> ST9->T9_TEMCONT
	            ::cMotivo := MNTA080TRC(::cTPCONT)
	        EndIf

	    EndIf

	EndIf

	//--------------------------------------------------------------------------
	// MNTBEM.020 - Campos obrigatórios de Venda
	//-------------------------------------------------------------------------
	If  ::IsValid() .And. ::IsUpsert() .And. (.Not. Empty(::GetValue('T9_DTVENDA')) .Or. .Not. Empty(::GetValue('T9_COMPRAD')) .Or.;
	                                          .Not. Empty(::GetValue('T9_NFVENDA')))

		// MNTBEM.020.001 - Data de venda
		If Empty(::GetValue('T9_DTVENDA'))
			::AddError(::MsgRequired("T9_DTVENDA"))

		// MNTBEM.020.002 - Comprador
		ElseIf Empty(::GetValue('T9_COMPRAD') )
			::AddError(::MsgRequired("T9_COMPRAD"))

		// MNTBEM.020.003 - Nota fiscal de venda
		ElseIf Empty(::GetValue('T9_NFVENDA') )
			::AddError(::MsgRequired("T9_NFVENDA"))

		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// MNTBEM.030 - Campos obrigatórios de Garantia
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpsert()

		// MNTBEM.030.001 - Unidade de garantia
		If .Not. Empty(::GetValue('T9_PRGARAN') ) .And. Empty(::GetValue('T9_UNGARAN') )
			::AddError(::MsgRequired("T9_UNGARAN"))

		// MNTBEM.030.002 - Prazo de garantia
		ElseIf .Not. Empty(::GetValue('T9_UNGARAN') ) .And. Empty(::GetValue('T9_PRGARAN') )
			::AddError(::MsgRequired("T9_PRGARAN"))

		// MNTBEM.030.003 - Variacao dia
		ElseIf ::GetValue('T9_UNGARAN') == "K" .And. Empty(::GetValue('T9_VARDIA') )
			::AddError(::MsgRequired("T9_VARDIA"))

		// MNTBEM.030.004 - Data de instalacao do bem
		ElseIf ::GetValue('T9_UNGARAN') == "H" .And. Empty(::GetValue('T9_DTINSTA') )
			::AddError(::MsgRequired("T9_DTINSTA"))

		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// MNTBEM.040 - Campos obrigatórios de Vida Util
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpsert()

	 	// MNTBEM.040.001 - Unidade de vida util
	 	If .Not. Empty(::GetValue('T9_VALODES') ) .And. Empty(::GetValue('T9_UNIDDES') )
			::AddError(::MsgRequired("T9_UNIDDES"))

		// MNTBEM.040.002 - Valor de vida util
		ElseIf .Not. Empty(::GetValue('T9_UNIDDES') ) .And. Empty(::GetValue('T9_VALODES') )
			::AddError(::MsgRequired("T9_VALODES"))

		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// MNTBEM.050 - Campos obrigatórios de Recurso
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpsert()
		// MNTBEM.050.001 - Recurso
		If .Not. Empty(::GetValue('T9_FERRAME') ) .And. Empty(::GetValue('T9_RECFERR') )
			::AddError(::MsgRequired("T9_RECFERR"))
		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// MNTBEM.060 - Campos obrigatórios de Inativação
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsInactivate()

		// MNTBEM.060.001 - Motivo da Baixa
		If Empty(::GetValue('T9_MTBAIXA') )
			::AddError(::MsgRequired("T9_MTBAIXA"))

		// MNTBEM.060.002 - Data da Baixa
		ElseIf Empty(::GetValue('T9_DTBAIXA') )
			::AddError(::MsgRequired("T9_DTBAIXA"))

		// MNTBEM.060.003 - Causa da Baixa
		ElseIf ::IsMainAsset() .And. Empty(::GetAssetAtt('cCause') )
			::AddError(STR0001) //"O campo de causa não foi preenchido"

		// MNTBEM.060.004 - Status
		ElseIf Empty(::GetValue('T9_STATUS') ) .And. ::GetValue('T9_CATBEM') == "3"
			::AddError(::MsgRequired("T9_STATUS"))

		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// MNTBEM.070 - Campos obrigatórios de Características
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpsert()

		aHeaderAux := ::GetHeader('STB')
		aColsAux   := ::GetCols('STB')
		nCodCar    := aScan(aHeaderAux,{|x| Trim(Upper(x[2])) == "TB_CARACTE"})
		nCodDet    := aScan(aHeaderAux,{|x| Trim(Upper(x[2])) == "TB_DETALHE"})

		For nLine := 1 To Len(aColsAux)

			//Somente linhas não-excluidas
			If aTail(aColsAux[nLine])
				Loop
			EndIf

			//Ultima linha totalmente vazia, não valida
			If nLine == Len(aColsAux) .And. _Super:EmptyLine('STB')
				Exit
			EndIf

			//Termina verificação, se existir campo não preenchido
			If .Not. ::IsValid()
				Exit
			EndIf

			// MNTBEM.070.001 - Codido da caracteristica
			If Empty( aColsAux[nLine][nCodCar] )
				::AddError(::MsgRequired('TB_CARACTE'))

			// MNTBEM.070.001 - Detalhe da caracteristica
			ElseIf Empty(aColsAux[nLine][nCodDet])
				::AddError(::MsgRequired('TB_DETALHE'))

			EndIf
		Next nLine
	EndIf

	//--------------------------------------------------------------------------
	// MNTBEM.080 - Campos obrigatórios de Peças de Reposição
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpsert()

		aHeaderAux := ::GetHeader( 'TPY' )
		aColsAux   := ::GetCols( 'TPY' )
		nCodPro    := aScan(aHeaderAux,{|x| Trim(Upper(x[2])) == "TPY_CODPRO"})
		nQuanti    := aScan(aHeaderAux,{|x| Trim(Upper(x[2])) == "TPY_QUANTI"})
		nQtdGar    := aScan(aHeaderAux,{|x| Trim(Upper(x[2])) == "TPY_QTDGAR"})
		nUniGar    := aScan(aHeaderAux,{|x| Trim(Upper(x[2])) == "TPY_UNIGAR"})

		For nLine := 1 To Len(aColsAux)

			//Somente linhas não-excluidas
			If aTail(aColsAux[nLine])
				Loop
			EndIf

			//Ultima linha totalmente vazia, não valida
			If nLine == Len(aColsAux) .And. _Super:EmptyLine('TPY')
				Exit
			EndIf

			//Termina verificação, se existir campo não preenchido
			If .Not. ::IsValid()
				Exit
			EndIf

			// MNTBEM.080.001 - Codigo do produto
			If Empty(aColsAux[nLine][nCodPro])
				::AddError(::MsgRequired('TPY_CODPRO'))

			// MNTBEM.080.002 - Quantidade
			ElseIf Empty(aColsAux[nLine][nQuanti])
				::AddError(::MsgRequired('TPY_QUANTI'))

			// MNTBEM.080.003 - Unidade de Garantia
			ElseIf .Not. Empty(aColsAux[nLine][nQtdGar]) .And. Empty(aColsAux[nLine][nUniGar])
				::AddError(::MsgRequired('TPY_UNIGAR'))

			// MNTBEM.080.004 - Quantidade Garantia
			ElseIf .Not. Empty(aColsAux[nLine][nUniGar]) .And. Empty(aColsAux[nLine][nQtdGar])
				::AddError(::MsgRequired('TPY_QTDGAR'))

			EndIf
		Next nLine
	EndIf

	//--------------------------------------------------------------------------
	// MNTBEM.090 - Instalação do Bem
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsInsert() .And. ::GetValue('T9_CATBEM') <> "3" .And. ;
	   .Not. Empty(::GetValue('T9_STATUS')) .And. Empty(::GetValue('T9_DTINSTA'))

		::AddError( STR0002 ) //"Para garantir a integridade do historico de status é necessario informar a data de instalação do bem."
	EndIf

	//--------------------------------------------------------------------------
	// Verifica limites e posição do contador
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpsert() .And. ::GetValue('T9_TEMCONT') <> "P";
	               .And. ::GetValue('T9_POSCONT') > ::GetValue('T9_LIMICON')

		::AddError(STR0003) //"A posição informada não pode ser maior que o limite do contador."
	EndIf

	//--------------------------------------------------------------------------
	// Verifica limites da variação dia bem
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpsert() .And. ::GetValue('T9_TEMCONT') <> "N" .And. NGIFDBSEEK("ST6",::GetValue('T9_CODFAMI'),1)

		//020 - valida limite da variacao dia contador 1
		If .Not. Empty( ST6->T6_VARDIA1 ) .And. ::GetValue('T9_VARDIA') > ST6->T6_VARDIA1
			::AddError(STR0004) //"A variação dia informada não pode ser maior que a da família. (Contador 1)"

		//021 - valida limite da variacao dia contador 2
		ElseIf NGIFDBSEEK("TPE" , ::GetValue('T9_CODBEM') , 1 ) .And. .Not. Empty( ST6->T6_VARDIA2 ) .And. TPE->TPE_VARDIA > ST6->T6_VARDIA2
			::AddError(STR0005) //"A variação dia informada não pode ser maior que a da família. (Contador 2)"

		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// Garantia do Bem
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpsert() .And. .Not. Empty(::GetValue('T9_DTGARAN') ) .And. ::GetValue('T9_DTCOMPR') > ::GetValue('T9_DTGARAN')
		::AddError( STR0006 ) //"A data de compra informada não pode ser maior que a data de garantia."
	EndIf

	//--------------------------------------------------------------------------
	// Categoria do Status
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpdate() .And. .Not. Empty(::GetValue('T9_STATUS'))

		cCatSta := NGSEEK("TQY",::GetValue('T9_STATUS'),1,"TQY_CATBEM")
		If !(Empty(cCatSta) .Or. cCatSta == ::GetValue('T9_CATBEM') )
			::AddError( STR0007 ) //"Categoria do Status não corresponde à categoria do Bem."
		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// Validação de venda do bem - Transferencia do bem
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpsert() .And. ::GetValue('T9_SITBEM') == "T"
		::AddError( STR0008 ) //"O bem só pode assumir situação 'Transferido' através do processo de Transferência."
	EndIf

	//--------------------------------------------------------------------------
	// Valida inativação da manutenção
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpdate() .And. ::GetValue('T9_SITMAN') == "I"

		If NGIFDBSEEK("STJ" , "B" + ::GetValue('T9_CODBEM') , 6 )
			cAliasQry := GetNextAlias()
			cQuery := " SELECT COUNT(TJ_CODBEM) COUNTER "
			cQuery += " FROM " + RetSqlName("STJ")
			cQuery += " WHERE "
			cQuery += "     TJ_FILIAL  =  " + ValToSql( xFilial("STJ"))
			cQuery += " AND TJ_PLANO   <> " + ValToSql("000000" )
			cQuery += " AND TJ_CODBEM  =  " + ValToSql(::GetValue('T9_CODBEM'))
			cQuery += " AND TJ_TIPOOS  =  " + ValToSql("B" )
			cQuery += " AND TJ_TERMINO =  " + ValToSql("N" )
			cQuery += " AND TJ_SITUACA <> " + ValToSql("C" )
			cQuery += " AND D_E_L_E_T_ <> " + ValToSql("*" )
			cQuery := ChangeQuery( cQuery )
			dbUseArea(.T.,"TOPCONN",TCGENQRY( , , cQuery ) , cAliasQry ,.F.,.T.)
			If (cAliasQry)->COUNTER > 0
				::AddError( STR0009 ) //"Para inativação da manutenção é necessário que sejam finalizadas as ordens de serviço preventivas em aberto."
			EndIf
			( cAliasQry )->( dbCloseArea() )
		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// Valida inativação do bem
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsInactivate()

		If NGIFDBSEEK("STJ" , "B" + ::GetValue('T9_CODBEM') , 6 )
			cAliasQry := GetNextAlias()
			cQuery := " SELECT COUNT(TJ_CODBEM) COUNTER "
			cQuery += " FROM " + RetSqlName("STJ")
			cQuery += " WHERE "
			cQuery += "     TJ_FILIAL  =  " + ValToSql( xFilial("STJ"))
			cQuery += " AND TJ_CODBEM  =  " + ValToSql(::GetValue('T9_CODBEM'))
			cQuery += " AND TJ_TIPOOS  =  " + ValToSql("B" )
			cQuery += " AND TJ_TERMINO =  " + ValToSql("N" )
			cQuery += " AND TJ_SITUACA <> " + ValToSql("C" )
			cQuery += " AND D_E_L_E_T_ <> " + ValToSql("*" )
			cQuery := ChangeQuery( cQuery )
			dbUseArea(.T., "TOPCONN" , TCGENQRY(,,cQuery ) , cAliasQry ,.F.,.T.)
			If (cAliasQry)->COUNTER > 0
				::AddError(STR0010 + "(" + AllTrim(::GetValue('T9_CODBEM')) + ")") //"Para inativação do bem é necessário que sejam finalizadas as ordens de serviço em aberto."
			EndIf
			(cAliasQry)->(dbCloseArea())
		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// Validação de venda do bem - Inativação da estrutura
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpdate() .And. ::IsInactivate()
		// 010 - Verifica se o bem faz parte da estrutura(é filho) da estrutura
		If NGIFDBSEEK('STC',::GetValue('T9_CODBEM'),3)
			::AddError( STR0013  + "(" + AllTrim(::GetValue('T9_CODBEM')) + ")") //"Operacao nao aceita. O bem faz parte de uma estrutura."
		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// Validação de venda do bem - Bem Inativo
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpdate() .And. ::IsSale() .And. ::GetValue('T9_SITBEM') != "I"
		::AddError(STR0014) //"O bem precisa estar inativo para ser vendido."
	EndIf

	//--------------------------------------------------------------------------
	// Validação de venda do bem - Manutenção Inativa
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpdate() .And. ::IsSale() .And. ::GetValue('T9_SITMAN') != "I"
		::AddError( STR0015 ) //"A manutenção precisa estar inativa para o bem ser vendido."
	EndIf

	//--------------------------------------------------------------------------
	// Inativa os bens selecionados
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsInactivate() .And. ::IsMainAsset()

		cAliasQry  := ::GetAssetAtt('cTempTable')
		cCause	   := ::GetAssetAtt('cCause')
		cHourCont1 := ::GetAssetAtt('cHourCont1')
		dDateCont2 := ::GetAssetAtt('dDateCont2')
		cHourCont2 := ::GetAssetAtt('cHourCont2')

		While !(cAliasQry)->(EoF())

			If Empty((cAliasQry)->OK) .Or. (cAliasQry)->CODBEM == ST9->T9_CODBEM
				dbSelectArea(cAliasQry)
				(cAliasQry)->(dbSkip())
				Loop
			EndIf

			aIndexST9 := {}
			aAdd(aIndexST9,xFilial('ST9') + (cAliasQry)->CODBEM)
			If NGIFdbSeek('TPE',(cAliasQry)->CODBEM,1)
				aAdd(aIndexST9,xFilial('TPE') + (cAliasQry)->CODBEM)
			Else
				aAdd(aIndexST9,'')
			EndIf

			oST9 := MntBem():New
			oST9:SetOperation(6)
			oST9:Load(aIndexST9)
			oST9:SetValue('T9_SITBEM' ,'I')
			oST9:SetValue('T9_SITMAN' ,'I')
			oST9:SetValue('T9_DTBAIXA',::GetValue('T9_DTBAIXA'))
			oST9:SetValue('T9_MTBAIXA',::GetValue('T9_MTBAIXA'))

			oST9:Inactivate(cCause,cHourCont1,dDateCont2,cHourCont2,cTempTable,.T.)

			oST9:Valid()

			If oST9:IsValid()
				aAdd(::aInactive,oST9)
			Else
				::AddError(oST9:GetErrorList()[1])
				oST9:Free()
				Exit
			EndIf

			dbSelectArea(cAliasQry)
			(cAliasQry)->(dbSkip())
		End
	EndIf

	//--------------------------------------------------------------------------
	// Validação de venda do bem - O.S. Abertas
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpdate() .And. ::IsSale()

		cAliasQry := GetNextAlias()
		cQuery := " SELECT COUNT(TJ_CODBEM) COUNTER "
		cQuery += "   FROM " + RetSqlName("STJ")
		cQuery += "  WHERE TJ_FILIAL  =  " + ValToSql(xFilial("STJ"))
		cQuery += "    AND TJ_CODBEM  =  " + ValToSql(::GetValue('T9_CODBEM'))
		cQuery += "    AND TJ_TIPOOS  =  " + ValToSql("B")
		cQuery += "    AND TJ_TERMINO =  " + ValToSql("N")
		cQuery += "    AND TJ_SITUACA =  " + ValToSql("L")
		cQuery += "    AND D_E_L_E_T_ <> " + ValToSql("*")
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T. , "TOPCONN" , TCGENQRY( , , cQuery ) , cAliasQry , .F. , .T. )
		If (cAliasQry)->COUNTER > 0
			::AddError( STR0016 ) //"A venda do bem não poderá ser efetuada, pois existe(m) OS(s) aberta(s) para o mesmo"
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf

	//--------------------------------------------------------------------------
	// Valida inclusão do Historico de movimentação de Centro de Custo
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpsert() .And. .Not. Empty(::GetValue('T9_CCUSTO') ) .And. ::GetValue('T9_MOVIBEM') == 'S'

		::aNGMovBem := {}

		dbSelectArea('TPN')
		dbSetOrder(1)
		If !dbSeek( xFilial('TPN') + ::GetValue('T9_CODBEM') ) .Or. ( ::GetValue('T9_CCUSTO') != ST9->T9_CCUSTO .Or.;
			::GetValue('T9_CENTRAB') != ST9->T9_CENTRAB )

			// Quando alterado o C.C. ou C.T. utiliza da data do sistema.
			If ::GetValue('T9_CCUSTO') != ST9->T9_CCUSTO .Or. ::GetValue('T9_CENTRAB') != ST9->T9_CENTRAB

				dDtIniTPN := dDataBase

			Else

				// Define qual a data inicio de movimentação
				If !Empty(::GetValue('T9_DTCOMPR') )
					dDtIniTPN := ::GetValue('T9_DTCOMPR')
				ElseIf !Empty(::GetValue('T9_DTINSTA') )
					dDtIniTPN := ::GetValue('T9_DTINSTA')
				Else
					dDtIniTPN := dDataBase
				EndIf

			EndIf

			oTPN := NGMovBem():New(Self)
			oTPN:setOperation(3)
			oTPN:setValue("TPN_CODBEM",::GetValue('T9_CODBEM'))
			oTPN:setValue("TPN_DTINIC",dDtIniTPN)
			oTPN:setValue("TPN_HRINIC",Time())
			oTPN:setValue("TPN_CCUSTO",::GetValue('T9_CCUSTO'))
			oTPN:setValue("TPN_CTRAB" ,::GetValue('T9_CENTRAB'))
			oTPN:setValue("TPN_UTILIZ",'U')
			oTPN:setValue("TPN_POSCON",::GetValue('T9_POSCONT'))
			oTPN:setValue("TPN_POSCO2",0)

			If NGCADICBASE('T9_TAG','D','ST9',.F.)
				oTPN:setValue("TPN_TAG",::GetValue('T9_TAG'))
			EndIf

			oTPN:Valid()

			If oTPN:IsValid()
				aAdd(::aNGMovBem,oTPN)
			Else
				::AddError(oTPN:GetErrorList()[1])
				oTPN:Free()
			EndIf
		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// Valida exclusão do Historico de movimentação de Centro de Custo
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsDelete()

		::aNGMovBem := {}

		cAliasQry := GetNextAlias()
		cQuery := " SELECT TPN_FILIAL, TPN_CODBEM ,TPN_DTINIC, TPN_HRINIC"
		cQuery += "   FROM " + RetSqlName("TPN")
		cQuery += "  WHERE TPN_FILIAL  = " + ValToSql(xFilial("TPN"))
		cQuery += "    AND TPN_CODBEM  = " + ValToSql(::GetValue('T9_CODBEM'))
		cQuery += "    AND D_E_L_E_T_ <> " + ValToSql("*" )
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T. ,"TOPCONN", TCGENQRY(,,cQuery) , cAliasQry , .F. , .T. )
		While .Not. ( cAliasQry )->( EoF() )

			cSeekKey := (cAliasQry)->TPN_FILIAL
			cSeekKey += (cAliasQry)->TPN_CODBEM
			cSeekKey += (cAliasQry)->TPN_DTINIC
			cSeekKey += (cAliasQry)->TPN_HRINIC

			oTPN := NGMovBem():New(Self)
			oTPN:SetOperation(5)
			oTPN:Load({cSeekKey})
			oTPN:Valid()

			If oTPN:IsValid()
				aAdd(::aNGMovBem,oTPN)
			Else
				::AddError(oTPN:GetErrorList()[1])
				oTPN:Free()
				Exit
			EndIf
			(cAliasQry)->(dbSkip())
		End
		(cAliasQry)->(dbCloseArea())
	EndIf

	//--------------------------------------------------------------------------
	// Valida exclusão de um bem integrado com o processo de mobilidade
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsDelete() .And. GetNewPar("MV_NGINTMB","2" ) == "1"
		::AddError(STR0017) //"O processo de exclusão de bens não é permitido caso a integração do processo de mobilidade esteja habilitada.
		                    // Verifique o parâmetro MV_NGINTMB."
	EndIf

	//--------------------------------------------------------------------------
	// Integração via mensagem única do cadastro de Bem
	//--------------------------------------------------------------------------
	If ::IsValid() .And. MN080INTMB(::GetValue('T9_CODFAMI'),,::GetValue('T9_PARTEDI')) .And. (::IsUpsert() .Or. ::IsInactivate())

		If ::GetValue('T9_VALCPA') > 0 // Para enviar o bem ao patrimonio do RM é necessário ter valor de compra do bem.

			dbSelectArea("ST9")

			// Define array private que será usado dentro da integração
			aParamMensUn    := Array(4)
			aParamMensUn[1] := ::GetRecno('ST9') // Indica numero do registro
			aParamMensUn[2] := ::GetOperation()  // Indica tipo de operação que esta invocando a mensagem unica
			aParamMensUn[3] := .T.               // Indica que se deve recuperar dados da memória

			// A=Ativo;I=Inativo;T=Transferido
			nStatus         := IIf(::GetValue('T9_SITBEM') == "I",2,1)
			aParamMensUn[4] := nStatus // Indica se deve inativar o bem (1 ativo,2 - inativo)
			lMuEquip        := .F.
			bBlock          := {||FWIntegDef("MNTA080",EAI_MESSAGE_BUSINESS,TRANS_SEND,Nil)}

			If Type("oMainWnd" ) == "O"
				MsgRun(STR0018,"Equipment",bBlock) //"Aguarde integração com backoffice..."
			Else
				Eval(bBlock)
			EndIf

			If .Not. lMuEquip
				::AddError(STR0019) //'Problema no processo de integração com backoffice.'
			EndIf
		Else
			lMuEquip := .F.
			::AddError(::MsgRequired('T9_VALCPA'))
		EndIf
	EndIf

	If ::IsInactivate() .And. ::IsMainAsset()

		// Atualiza o centro de custo no ativo fixo
		If ::IsValid() .And. .Not. Empty(::GetValue('T9_CODIMOB') )
			If !NGATUATF(::GetValue('T9_CODIMOB'),(cTempTable)->CCUSTO,.F.)
				aLog := GetAutoGRLog()
				nTot := Len(aLog)
				For nInd := 1 To nTot
					::AddError(aLog[nInd])
				Next nInd
			EndIf
		EndIf

	EndIf

	//--------------------------------------------------------------------------
	// Valida o campo de Fornecedor e Loja
	//--------------------------------------------------------------------------
	//Ao Incluir ou alterar deve validar
	If ( ::IsInsert() .Or. ::IsUpsert() ) .And. ::IsValid()

		If !Empty(::GetValue('T9_FORNECE') ) .And. Empty(::GetValue('T9_LOJA') )
			::AddError( STR0021 ) //"Ao informar um Fornecedor deverá preencher o campo Loja."
		EndIf

	EndIf

	//--------------------------------------------------------------------------
	// Restaura posicionamento de tabelas
	//--------------------------------------------------------------------------
	RestArea(aAreaST6)
	RestArea(aAreaTPE)
	RestArea(aAreaSTC)
	RestArea(aAreaSTJ)

Return ::IsValid()

//------------------------------------------------------------------------------
/*/{Protheus.doc} Upsert
Método para inclusao e alteracao dos alias definidos para a classe.

@author NG Informática Ltda.
@since 01/01/2015
@version P12
@return lUpsert Operação ok.
@sample If oObj:valid()
           oObj:upsert()
        Else
           Help(,,'HELP',, oTPN:getErrorList()[1],1,0)
        EndIf
/*/
//------------------------------------------------------------------------------
Method Upsert() Class MntBem

	Local cQuery, cSitOld, cAtvOld, dDtIniTPN, oTPN, nObject, cCause, cHourCont1, dDateCont2, cHourCont2, cTempTable, cSeekKey, cHourCont, nAcresc
	Local cFamOld   := ''
	Local cModOld   := ''
	Local aRet      := {}
	Local aPeriodic := { 0, { } }
	Local nPosCon1  := 0
	Local nPosCon2  := 0
	Local nCONTSAI1 := 0
	Local nACUMSAI1 := 0
	Local nVARDIA1  := 0
	Local nCONTSAI2 := 0
	Local nACUMSAI2 := 0
	Local nVARDIA2  := 0
	Local cCodeT9   := ''
	Local cBEMREL   := Space(Len(ST9->T9_CODBEM))
	Local cVCBEM    := Space(Len(ST9->T9_CODBEM))
	Local cBemSalvo := ST9->T9_CODBEM
	Local _cGetDB   := TcGetDb()
	Local cAltATF   := SuperGetMv("MV_NGMNTAT",.F.,"N") //Integracao Manutencao (MNT) c/Ativo (ATF)
	Local cAlsSN1   := ''
	Local lPimSint	:= SuperGetMV("MV_PIMSINT",.F.,.F.)
	Local cDescSN1	:= SubStr(::GetValue('T9_NOME'),1,TamSX3('N1_DESCRIC')[1]) //Garante que o tamanho da descrição do bem seja o mesmo da SN1

	//Inicio Variaveis utilizadas no ExecAuto do ATFA036
	Local cMetDepr  := SuperGetMv("MV_ATFDPBX",.F.,"0")
	Local aArea     := {}
	Local aCab      := {}
	Local aAtivo    := {}
	Local cBase     := ""
	Local cItem     := ""
	Local cTipo     := ""
	Local cTpSaldo  := ""
	Local cSeq      := ""
	Local cSeqReav  := ""
	Local cFilOri   := ""
	Local lActive   := .T.
	Local lTipMod   := .F.
	Local lRel12133 := GetRpoRelease() >= '12.1.033'

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.
	//Fim Variaveis utilizadas no ExecAuto do ATFA036

	Private cCodST9Est, cCodST9Alm
	Private lFROTA      := IIf( FindFunction('MNTFrotas'), MNTFrotas(), GetNewPar('MV_NGMNTFR','N') == 'S' )

	lTipMod := lRel12133 .Or. lFROTA

	// Carrega todas os campos da classe em memoria de trabalho
	::ClassToMemory()

	// Armazena a situação anterior a alteração
	cSitOld := NGSEEK("ST9" , ::GetValue('T9_CODBEM') , 1 , "T9_SITBEM" )

	// Armazena o código do ativo fixo anterior a alteração
	cAtvOld := NGSEEK("ST9" , ::GetValue('T9_CODBEM') , 1 , "T9_CODIMOB" )

	/*-----------------------------------------------+
	| Salva o código da família anterior a alteração |
	+-----------------------------------------------*/
	cFamOld := NGSeek( 'ST9', ::GetValue( 'T9_CODBEM' ), 1 , 'T9_CODFAMI' )

	/*-----------------------------------------------+
	| Salva o código do modelo anterior a alteração |
	+-----------------------------------------------*/
	cModOld := NGSeek( 'ST9', ::GetValue( 'T9_CODBEM' ), 1 , 'T9_TIPMOD' )

	// Carrega atributos para inativação da estrutura
	If ::IsInactivate() .And. ::IsMainAsset()
		cCause	   := ::GetAssetAtt('cCause')
		cHourCont1 := ::GetAssetAtt('cHourCont1')
		dDateCont2 := ::GetAssetAtt('dDateCont2')
		cHourCont2 := ::GetAssetAtt('cHourCont2')
		cTempTable := ::GetAssetAtt('cTempTable')
	EndIf

	BEGIN TRANSACTION

	//--------------------------------------------------------------------------
	// Grava Equipamento e grids
	//--------------------------------------------------------------------------
	_Super:Upsert()

	//--------------------------------------------------------------------------
	// Atualiza o tipo modelo na STC ( Estrutura )
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpdate()
		cQuery := " UPDATE " + RetSqlName("STC" )
		cQuery += "    SET TC_TIPMOD   = " + ValToSql(::GetValue('T9_TIPMOD'))
		cQuery += "  WHERE TC_FILIAL   = " + ValToSql(xFilial("STC" ))
		cQuery += "    AND TC_CODBEM   = " + ValToSql(::GetValue('T9_CODBEM'))
		cQuery += "    AND D_E_L_E_T_ != " + ValToSql("*")
		If TcSqlExec( cQuery ) < 0
			::AddError( TCSQLError() )
    	EndIf
	EndIf

	//--------------------------------------------------------------------------
	// Atualiza o nome do nivel na TAF ( Nivel Organizacional )
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpdate()
		cQuery := " UPDATE " + RetSqlName("TAF" )
		cQuery += "    SET TAF_NOMNIV  = " + ValToSql( Left( ::GetValue('T9_CODBEM') + ::GetValue('T9_NOME'), TamSX3('TAF_NOMNIV')[1] ) )
		cQuery += "  WHERE TAF_FILIAL  = " + ValToSql(xFilial("TAF"))
		cQuery += "    AND TAF_CODCON  = " + ValToSql(::GetValue('T9_CODBEM'))
		cQuery += "    AND TAF_MODMNT  = " + ValToSql("X")
		cQuery += "    AND TAF_INDCON  = " + ValToSql("1")
		cQuery += "    AND D_E_L_E_T_ != " + ValToSql("*")
		If TcSqlExec( cQuery ) < 0
			::AddError( TCSQLError() )
    	EndIf
	EndIf

	//--------------------------------------------------------------------------
	// Atualiza conjuntos hidráulicos relacionados bem
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpdate()
		cQuery := " UPDATE " + RetSqlName("TKS" )
		cQuery += "    SET TKS_FAMCJN  = " + ValToSql(::GetValue('T9_CODFAMI')) + ","
		cQuery += "        TKS_FORNEC  = " + ValToSql(::GetValue('T9_FORNECE')) + ","
		cQuery += "        TKS_LOJA    = " + ValToSql(::GetValue('T9_LOJA'))    + ","
		cQuery += "        TKS_CCCJN   = " + ValToSql(::GetValue('T9_CCUSTO' )) + ","
		cQuery += "        TKS_TURCJN  = " + ValToSql(::GetValue('T9_CALENDA')) + ","
		cQuery += "        TKS_DTCOMP  = " + ValToSql(::GetValue('T9_DTCOMPR')) + ","
		cQuery += "        TKS_ANOFAB  = " + ValToSql(::GetValue('T9_ANOFAB'))  + ","
		cQuery += "        TKS_FABRIC  = " + ValToSql(::GetValue('T9_FABRICA')) + ","
		cQuery += "        TKS_MODELO  = " + ValToSql(::GetValue('T9_MODELO'))
		cQuery += "  WHERE TKS_FILIAL  = " + ValToSql(xFilial("TKS"))
		cQuery += "    AND TKS_BEM     = " + ValToSql(::GetValue('T9_CODBEM'))
		cQuery += "    AND D_E_L_E_T_ != " + ValToSql("*")
		If TcSqlExec( cQuery ) < 0
			::AddError( TCSQLError() )
    	EndIf
	EndIf

	//--------------------------------------------------------------------------
	// Integração do Bem com Ativo Fixo - Remoção do vinculo com o Ativo
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpdate() .And. GetNewPar("MV_NGMNTAT",' ') $ "2/3";
	               .And. ::GetValue('T9_CODIMOB') <> cAtvOld .And. .Not. Empty( cAtvOld )

		cQuery := "UPDATE " + RetSqlName("SN1")
		cQuery += "   SET N1_CODBEM  = ' ' "
		cQuery += " WHERE N1_FILIAL  =    "         + ValToSql(xFilial("SN1"))
		If Upper(_cGetDB) $ 'ORACLE,POSTGRES,INFORMIX' .OR. Upper(_cGetDB) $ 'DB2'
			cQuery += "   AND N1_CBASE   || N1_ITEM = " + ValToSql(cAtvOld)
		Else
			cQuery += "   AND N1_CBASE   +  N1_ITEM = " + ValToSql(cAtvOld)
		EndIf
		cQuery += "   AND D_E_L_E_T_ != "         + ValToSql("*")
		If TcSqlExec( cQuery ) < 0
			::AddError( TCSQLError() )
    	EndIf
	EndIf

	//--------------------------------------------------------------------------
	// Grava relacionamento com Construção civil
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::GetValue('T9_CATBEM') == '1'
		If .Not. NGIFdbSeek( 'TTM' , ::GetValue('T9_CODBEM') , 1 )
			RecLock( 'TTM' , .T. )
			TTM->TTM_FILIAL := xFilial( 'TTM' )
			TTM->TTM_CODBEM := ::GetValue('T9_CODBEM')
		Else
			RecLock('TTM',.F.)
		EndIf
		TTM->TTM_EMPROP := SM0->M0_CODIGO
		TTM->TTM_FILPRO := xFilial( "ST9" )
		TTM->TTM_CATBEM := ::GetValue('T9_CATBEM' )
		TTM->TTM_ALUGUE := ::GetValue('T9_ALUGUEL')
        TTM->TTM_PROPRI := ::GetValue('T9_PROPRIE')
		MsUnLock()
	EndIf


	// Integração do Bem com Ativo Fixo - Atualização do Ativo
	If ::IsValid() .And. cAltATF $ "2#3"

		cAlsSN1 := GetNextAlias()
		cCodeT9 := ::GetValue( 'T9_CODBEM' )

		// Verifica se já existe ativo vinculado a este bem.
		BeginSQL Alias cAlsSN1

			SELECT
				N1_CBASE,
				N1_ITEM
			FROM
				%table:SN1%
			WHERE
				N1_CODBEM = %exp:cCodeT9% AND
				N1_FILIAL = %xFilial:SN1% AND
				N1_BAIXA  = ' '           AND
				%NotDel%

		EndSQL

		If (cAlsSN1)->( !EoF() )

			dbSelectArea( 'SN1' )
			dbSetOrder( 1 )
			If dbSeek( xFilial( 'SN1' ) + (cAlsSN1)->N1_CBASE + (cAlsSN1)->N1_ITEM ) .And.;
				(cAlsSN1)->N1_CBASE + (cAlsSN1)->N1_ITEM != ::GetValue( 'T9_CODIMOB' )

				RecLock( 'SN1', .F. )
					SN1->N1_CODBEM := ''
				SN1->( MsUnLock() )

			EndIf

		EndIf

		(cAlsSN1)->( dbCloseArea() )

		If ::IsUpsert() .And. !Empty( ::GetValue( 'T9_CODIMOB' ) )

			cQuery := " UPDATE " + RetSqlName("SN1" )
			cQuery += "    SET N1_DESCRIC = " + ValToSql(cDescSN1)				   + ","
			cQuery += "        N1_AQUISIC = " + ValToSql(::GetValue('T9_DTCOMPR')) + ","
			cQuery += "        N1_CHAPA   = " + ValToSql(::GetValue('T9_CHAPA'))   + ","
			cQuery += "        N1_LOCAL   = " + ValToSql(::GetValue('T9_LOCAL'))   + ","
			cQuery += "        N1_FORNEC  = " + ValToSql(::GetValue('T9_FORNECE')) + ","
			cQuery += "        N1_LOJA    = " + ValToSql(::GetValue('T9_LOJA'))    + ","
			cQuery += "        N1_NFISCAL = " + ValToSql(::GetValue('T9_NFCOMPR')) + ","
			cQuery += "        N1_CODBEM  = " + ValToSql(::GetValue('T9_CODBEM'))
			cQuery += "  WHERE N1_FILIAL  = " + ValToSql(xFilial("SN1"))
			If Upper(_cGetDB) $ 'ORACLE,POSTGRES,INFORMIX' .OR. Upper(_cGetDB) $ 'DB2'
				cQuery += "    AND N1_CBASE || N1_ITEM  =  " + ValToSql(::GetValue('T9_CODIMOB'))
			Else
				cQuery += "    AND N1_CBASE +  N1_ITEM  =  " + ValToSql(::GetValue('T9_CODIMOB'))
			EndIf
			cQuery += "    AND N1_QUANTD   = " + ValToSql("1")
			cQuery += "    AND D_E_L_E_T_ != " + ValToSql("*")
			If TcSqlExec( cQuery ) < 0
				::AddError( TCSQLError() )
			EndIf
		EndIf

		// Caso centro de custo do bem cadastrado pelo Ativo fixo estiver vazio,
		// faz repasse do centro de custo informado no bem MNT
		If ::IsUpdate() .And. FindFunction( 'MNTALTATF' )
			aRet := MNTALTATF( ::GetValue( 'T9_CODIMOB' ), ::GetValue( 'T9_CCUSTO' ), .F. )
			If !aRet[ 1 ]
				::AddError( aRet[ 2 ] )
			EndIf
		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// Inativa as manutencoes do bem
	//--------------------------------------------------------------------------
	If ::IsValid() .And. (::IsUpdate() .And. ::GetValue('T9_SITMAN') == "I" .Or. ::IsInactivate());
	               .And. NGIFDBSEEK('STF',::GetValue('T9_CODBEM'),1)
		cQuery := " UPDATE " + RetSqlName("STF" )
		cQuery += "    SET TF_ATIVO    = " + ValToSql("N")
		cQuery += "  WHERE TF_FILIAL   = " + ValToSql(xFilial("STF"))
		cQuery += "    AND TF_CODBEM   = " + ValToSql(::GetValue('T9_CODBEM'))
		cQuery += "    AND D_E_L_E_T_ != " + ValToSql("*")
		If TcSqlExec( cQuery ) < 0
			::AddError( TCSQLError() )
    	EndIf
	EndIf

	//--------------------------------------------------------------------------
	// Grava Historico na TPN ( Centro de Custo )
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpsert()
		For nObject := 1 To Len(::aNGMovBem )
			::aNGMovBem[nObject]:Upsert()
			::aNGMovBem[nObject]:Free()
		Next
	EndIf

	//--------------------------------------------------------------------------
	// Cancela O.S. Pendentes na venda de um bem
	//--------------------------------------------------------------------------
	//TODO: Remover esse processo após a liberação da classe de O.S.
	If ::IsValid() .And. ::IsUpdate() .And. ::IsSale()

		dbSelectArea( 'STJ' )
		dbSetOrder( 2 )
		dbSeek( xFilial( 'STJ' ) + 'B' + ::GetValue('T9_CODBEM') )

		//Busca por O.S. do bem
		While .Not. STJ->( EoF() ) .And.;
			STJ->TJ_FILIAL == xFilial( 'STJ' ) .And.;
			STJ->TJ_TIPOOS == 'B' .And.;
			STJ->TJ_CODBEM == ::GetValue('T9_CODBEM')

			//Caso a O.S. ter status pendente
			If STJ->TJ_SITUACA == 'P'

				//Exclui a O.S.
				NGDELETOS( STJ->TJ_ORDEM , STJ->TJ_PLANO )
			EndIf

			//Proxima O.S.
			STJ->( dbSkip() )
		End
	EndIf

	//--------------------------------------------------------------------------
	// Atualiza histórico do Nivel Organizacional
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpdate() .And. ::GetValue('T9_SITBEM') <> cSitOld

		dbSelectArea( 'TAF' )
		dbSetOrder( 6 )
		dbSeek( xFilial( 'TAF' ) + 'X1' + ::GetValue('T9_CODBEM') )
		If Found()

			dbSelectArea( 'TCJ' )
			dbSetOrder( 1 )
			dbSeek( xFilial( 'TCJ' ) + TAF->TAF_CODNIV + TAF->TAF_NIVSUP + ::GetValue('T9_SITBEM') + DToS( dDataBase ) + Time() )
			If .Not. Found()

				//Grava Registro
				RecLock( 'TCJ' , .T. )
				TCJ->TCJ_FILIAL := xFilial( 'TCJ' )
				TCJ->TCJ_CODNIV := TAF->TAF_CODNIV
				TCJ->TCJ_DESNIV := SubStr( TAF->TAF_NOMNIV , 1 , 40 )
				TCJ->TCJ_NIVSUP := TAF->TAF_NIVSUP
				TCJ->TCJ_TIPROC := ::GetValue('T9_SITBEM')
				TCJ->TCJ_DATA   := dDatabase
				TCJ->TCJ_HORA   := Time()
				MsUnLock( 'TCJ' )
			EndIf
		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// Exclui primeiro registro do 1º contador ( STP )
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpdate() .And. NGIFDBSEEK('STP',::GetValue('T9_CODBEM'),2)

		/* Observações:
		- Verifica se houve alterações nos campos de contador,
		excluindo e recriando STP caso necessário.
		- Os campos de contador estarão abertos para modificação
		caso exista apenas um registro no STP (TP_TIPOLAN = I),
		sendo necessário ajustar o STP em cada alteração
		*/

		// Pula para próximo registro da STP
		STP->( dbSkip() )

		// Verifica se o próximo registro é do mesmo Bem.
		If !( STP->TP_FILIAL == xFilial( 'STP' ) .And. STP->TP_CODBEM == ::GetValue('T9_CODBEM') )

			//Volta registro do STP
			STP->( dbSkip( -1 ) )

			//Verifica se houve alterações nos campos relacionados ao STP e ST9
			If	STP->TP_DTULTAC <> ::GetValue('T9_DTULTAC') .Or.;
			STP->TP_VARDIA <> ::GetValue('T9_VARDIA') .Or.;
			STP->TP_POSCONT <> ::GetValue('T9_POSCONT') .Or.;
			STP->TP_ACUMCON <> ::GetValue('T9_CONTACU')

				//Excluir contador na STP
				RecLock( 'STP' , .F. )
				dbDelete()
				MsUnlock( 'STP' )
			EndIf
		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// Exclui primeiro registro do 2º contador ( TPP )
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpdate() .And. NGIFDBSEEK( 'TPP' , ::GetValue('T9_CODBEM') , 2 )

		//Observações:
		//- Verifica se houve alterações nos campos de contador,
		//excluindo e recriando TPP caso necessário.
		//- Os campos de contador estarão abertos para modificação
		//caso exista apenas um registro no TPP, sendo necessário
		//ajustar o TPE em cada alteração.

		// Pula para próximo registro da TPP
		TPP->( dbSkip() )

		// Verifica se o próximo registro é do mesmo Bem.
		If !( TPP->TPP_FILIAL == xFilial( 'TPP' ) .And. TPP->TPP_CODBEM == ::GetValue('T9_CODBEM') ) //.And. ::GetValue('TPE_SITUAC') != "2"

			//Volta registro do TPP
			TPP->( dbSkip( -1 ) )

			//Verifica se houve alterações nos campos relacionados ao TPP e ST9
			If	TPP->TPP_DTULTA <> ::GetValue('TPE_DTULTA') .Or.;
				TPP->TPP_VARDIA <> ::GetValue('TPE_VARDIA') .Or.;
				TPP->TPP_POSCON <> ::GetValue('TPE_POSCON') .Or.;
				TPP->TPP_ACUMCO <> ::GetValue('TPE_CONTAC') .Or.;
				Empty(::GetValue('T9_TPCONTA') )

				//Excluir contador na TPP
				RecLock( 'TPP' , .F. )
				dbDelete()
				MsUnlock( 'TPP' )

				If Empty(::GetValue('T9_TPCONTA') ) .And.;
				NGIFDBSEEK( 'TPE' , ::GetValue('T9_CODBEM') , 1 )
					//Excluir contador na TPE
					RecLock( 'TPE' , .F. )
					dbDelete()
					MsUnlock( 'TPE' )
				EndIf
			EndIf
		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// Grava o informe inicial do 1º Contador
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpsert() .And. ::GetValue('T9_TEMCONT') != 'N'

		//Se nao haver historico para o contador 1
		If !NGIFDBSEEK( 'STP' , ::GetValue('T9_CODBEM') , 2 )

			//Grava primeira posição do contador 1
			NGGRAVAHIS(;
			::GetValue('T9_CODBEM' ),;
			::GetValue('T9_POSCONT'),;
			::GetValue('T9_VARDIA' ),;
			::GetValue('T9_DTULTAC'),;
			::GetValue('T9_CONTACU'),;
			::GetValue('T9_VIRADAS'),;
			Time(),;
			1,;
			'I',;
			xFilial('ST9');
			)
		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// Grava o informe inicial do 2º Contador
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpsert() .And. ::GetValue('T9_TEMCONT') != 'N' .And.;
	.Not. Empty(::GetValue('TPE_POSCON') )

		//Se nao haver historico para o contador 2
		If .Not. NGIFDBSEEK( 'TPP' , ::GetValue('T9_CODBEM') , 5 )

			//Grava primeira posição do contador 2
			NGGRAVAHIS(;
			::GetValue('T9_CODBEM'),;
			::GetValue('TPE_POSCON'),;
			::GetValue('TPE_VARDIA'),;
			::GetValue('TPE_DTULTA'),;
			::GetValue('TPE_CONTAC'),;
			::GetValue('TPE_VIRADA'),;
			Time(),;
			2,;
			'I';
			)
		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// Exclui a garantia dos insumos apagados na grid TPY
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpsert()
		dbSelectArea('TPY')
		dbSetOrder(1)

		dbSelectArea('TPZ')
		dbSetOrder(1)

		TPZ->( dbSeek( xFilial('TPZ') + ::GetValue('T9_CODBEM') + "P"))
		While !TPZ->( EoF() ) .And.;
		TPZ->TPZ_CODBEM == ::GetValue('T9_CODBEM') .And.;
		TPZ->TPZ_TIPORE == "P"

			If !TPY->( dbSeek( xFilial('TPY') + ::GetValue('T9_CODBEM') + TPZ->TPZ_CODIGO + TPZ->TPZ_LOCGAR ) )
				RecLock( 'TPZ' , .F. )
				TPZ->( DBDelete() )
				MsUnlock( 'TPZ' )
			EndIf
			TPZ->( dbSkip() )
		End
	EndIf

	//--------------------------------------------------------------------------
	// Grava garantia dos insumos existentes na grid TPY
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpsert()
		dbSelectArea('TPZ')
		dbSetOrder(1)

		dbSelectArea('TPY')
		dbSetOrder(1)

		dbSeek( xFilial('TPY') + ::GetValue('T9_CODBEM') )
		While !EoF() .And.  TPY->TPY_CODBEM == ::GetValue('T9_CODBEM')

			If ( TPY->TPY_QTDGAR <> 0 .And. !Empty( TPY->TPY_UNIGAR ) ) .Or.;
			(!Empty( TPY->TPY_CONGAR ) .And. TPY->TPY_QTDCON <> 0 )

				If TPZ->( dbSeek( xFilial('TPZ') + ::GetValue('T9_CODBEM') + "P" + TPY->TPY_CODPRO + TPY->TPY_LOCGAR ) )
					RecLock("TPZ",.F.)
				Else
					RecLock("TPZ",.T.)
					TPZ->TPZ_FILIAL := xFilial("TPZ")
					TPZ->TPZ_CODBEM := ::GetValue('T9_CODBEM')
					TPZ->TPZ_TIPORE := "P"
					TPZ->TPZ_CODIGO := TPY->TPY_CODPRO
					TPZ->TPZ_LOCGAR := TPY->TPY_LOCGAR
				EndIf

				TPZ->TPZ_QTDGAR := TPY->TPY_QTDGAR
				TPZ->TPZ_UNIGAR := TPY->TPY_UNIGAR
				TPZ->TPZ_DTGARA := ::GetValue('T9_DTCOMPR')
				TPZ->TPZ_CONGAR := TPY->TPY_CONGAR
				TPZ->TPZ_QTDCON := TPY->TPY_QTDCON
				MSUnLock("TPZ")
			EndIf
			TPY->( dbSkip() )
		End
	EndIf

	//Atualizacao do motivo da alteracao do controle do bem (TEMCONT) 030015
	If ::IsValid() .And. ::IsUpsert() .And. ::GetOperation() == 4 .And. ::IsHasStruc()

		cBEMREL  := Space(Len(ST9->T9_CODBEM)) // Código do Bem Pai
		cVCBEM   := ::GetValue("T9_CODBEM")    // Código do Bem alterado
		cVTPCONT := ::GetValue("T9_TEMCONT")   // Como deverá ficar o Tipo do contador depois da alteração.

		If ::cTPCONT <> cVTPCONT
			// PROCURAR O PAI
			If ::cTPCONT = "S" // Estava
				nCONTSAI1 := ::GetValue("T9_POSCONT")
				nACUMSAI1 := ::GetValue("T9_CONTACU")
				nVARDIA1  := ::GetValue("T9_VARDIA" )
				If NGIFdbSeek("TPE",cVCBEM,1)
					nCONTSAI2 := TPE->TPE_POSCON
					nACUMSAI2 := TPE->TPE_CONTAC
					nVARDIA2  := TPE->TPE_VARDIA
				EndIf
			ElseIf ::cTPCONT $ "PI" //Pai da estutrura / Pai imediato.
				cBEMREL := MNTPROBRE(cVCBEM,::cTPCONT)
				If !Empty(cBEMREL)
					If NGIFdbSeek("ST9",cBEMREL,1)
						nCONTSAI1 := ST9->T9_POSCONT
						nACUMSAI1 := ST9->T9_CONTACU
						nVARDIA1  := ST9->T9_VARDIA
						If NGIFdbSeek("TPE",cVCBEM,1)
							nCONTSAI2 := TPE->TPE_POSCON
							nACUMSAI2 := TPE->TPE_CONTAC
							nVARDIA2  := TPE->TPE_VARDIA
						EndIf
					EndIf
				EndIf
			EndIf

			If NGIFdbSeek("STZ",cVCBEM+"E",1)

				//Pai da estutrura / Pai imediato.
				If ::cTPCONT $ "PI"
					If nCONTSAI1 > 0
						NGTRETCON(cVCBEM,ST9->T9_DTULTAC,nCONTSAI1,Time(),1,,,"C") ///ATENÇÃO
					EndIf

					If nCONTSAI2 > 0
						NGTRETCON(cVCBEM,ST9->T9_DTULTAC,nCONTSAI2,Time(),2,,,"C")
					EndIf
				EndIf

				NGIFdbSeek('STZ',cVCBEM+"E",1)
				cBEMPAIN := STZ->TZ_BEMPAI
				cLOCBEMN := STZ->TZ_LOCALIZ
				cTIPCOMN := STZ->TZ_TEMCPAI

				RecLock("STZ",.F.)
				STZ->TZ_TIPOMOV := 'S'
				STZ->TZ_DATASAI := ST9->T9_DTULTAC
				STZ->TZ_CONTSAI := nCONTSAI1
				STZ->TZ_CAUSA   := ::cMOTIVO
				STZ->TZ_CONTSA2 := nCONTSAI2
				STZ->TZ_HORASAI := Time()
				If NGCADICBASE("TZ_USUARIO","D","STZ",.F.)
					STZ->TZ_USUARIO := cUserName
				EndIf
				MsUnLock("STZ")

				nCONTSAI1 := 0
				nACUMSAI1 := 0
				nVARDIA1  := 0
				nCONTSAI2 := 0
				nACUMSAI2 := 0
				nVARDIA2  := 0

				If cVTPCONT = "S" // Tem contador próprio

					If NGIFdbSeek('ST9',cVCBEM,1)
						nCONTSAI1 := ST9->T9_POSCONT
						nACUMSAI1 := ST9->T9_CONTACU
						nVARDIA1  := ST9->T9_VARDIA
					EndIf

					If NGIFdbSeek('TPE',cVCBEM,1)
						nCONTSAI2 := TPE->TPE_POSCON
						nACUMSAI2 := TPE->TPE_CONTAC
						nVARDIA2  := TPE->TPE_VARDIA
					EndIf

				ElseIf cVTPCONT $ "PI" //Pai da estutrura / Pai imediato.

					cBEMREL := MNTPROBRE(cVCBEM,cVTPCONT)
					If !Empty(cBEMREL)
						If NGIFdbSeek('ST9',cBEMREL,1)
							nCONTSAI1 := ST9->T9_POSCONT
							nACUMSAI1 := ST9->T9_CONTACU
							nVARDIA1  := ST9->T9_VARDIA
							If NGIFdbSeek('TPE',cVCBEM,1)
								nCONTSAI2 := TPE->TPE_POSCON
								nACUMSAI2 := TPE->TPE_CONTAC
								nVARDIA2  := TPE->TPE_VARDIA
							EndIf
						EndIf
					EndIf
				EndIf

				RecLock("STZ",.T.)
				STZ->TZ_FILIAL  := xFilial('STZ')
				STZ->TZ_CODBEM  := cVCBEM
				STZ->TZ_BEMPAI  := cBEMPAIN
				STZ->TZ_TIPOMOV := 'E'
				STZ->TZ_DATAMOV := ST9->T9_DTULTAC
				STZ->TZ_POSCONT := nCONTSAI1
				STZ->TZ_LOCALIZ := cLOCBEMN
				STZ->TZ_POSCON2 := nCONTSAI2
				STZ->TZ_TEMCONT := cVTPCONT
				STZ->TZ_TEMCPAI := cTIPCOMN
				STZ->TZ_HORAENT := Time()

				//Verificar se o bem tem 1º contador
				If cVTPCONT <> "N"
					STZ->TZ_HORACO1 := Time()
				EndIf

				//Verificar se o bem tem 2º contador
				If NGIFdbSeek('TPE',cVCBEM,1)
					STZ->TZ_HORACO2 := Time()
				EndIf

				If NGCADICBASE("TZ_USUARIO","D","STZ",.F.)
					STZ->TZ_USUARIO := cUserName
				EndIf
				MsUnLock("STZ")

				//Pai da estutrura / Pai imediato.
				If cVTPCONT $ "PI"
					If nCONTSAI1 > 0
						NGTRETCON(cBEMREL,ST9->T9_DTULTAC,nCONTSAI1,Time(),1,,,"C")
					EndIf

					If nCONTSAI2 > 0
						NGTRETCON(cBEMREL,ST9->T9_DTULTAC,nCONTSAI2,Time(),2,,,"C")
					EndIf
				EndIf
			EndIf

		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// Grava leitura do primeiro contador para inativação da estrutura
	//--------------------------------------------------------------------------
	If ::IsInactivate() .And. ::IsMainAsset() .And. ::GetValue('T9_TEMCONT') == "S" .And. ::GetValue('T9_POSCONT') > 0
		NGTRETCON(;
		::GetValue('T9_CODBEM' ),;
		::GetValue('T9_DTBAIXA'),;
		::GetValue('T9_POSCONT'),;
		cHourCont1 , 1 , , .T. )
	EndIf

	//--------------------------------------------------------------------------
	// Grava leitura do segundo contador para inativação da estrutura
	//--------------------------------------------------------------------------
	If ::IsInactivate() .And. ::IsMainAsset() .And. NGIFDBSEEK('TPE',::GetValue('T9_CODBEM'),1) .And. ::GetValue('TPE_POSCON') > 0
		NGTRETCON(;
		::GetValue('T9_CODBEM' ),;
		dDateCont2,;
		::GetValue('TPE_POSCON'),;
		cHourCont2 , 2 , , .F. )
	EndIf

	If ::IsInactivate() .And. ::IsMainAsset()
		cHourCont := IIf( AllTrim( cHourCont1 ) == ":" , Time() , cHourCont1 )
		cHourCont := SubStr( cHourCont , 1 , 5 )
	EndIf

	//--------------------------------------------------------------------------
	// Tratamento para todos os bens
	//--------------------------------------------------------------------------
	If ::IsInactivate() .And. ::IsMainAsset()
		NGSETIFARQUI(cTempTable)
	EndIf
	While ::IsInactivate() .And. ::IsMainAsset() .And. .Not. (cTempTable)->( EoF() )

		//----------------------------------------------------------------------
		// Busca a posicao dos contadores
		//----------------------------------------------------------------------
		If ::IsValid() .And. NGIFDBSEEK( 'ST9' , (cTempTable)->CODBEM , 1 )

			If ST9->T9_TEMCONT $ "P/I"
				If ST9->T9_TEMCONT == "I"
					cBemSalvo := NGBEMIME((cTempTable)->CODBEM)
				Else //Estrutura
					cBemSalvo := NGBEMPAI((cTempTable)->CODBEM)
				EndIf
				If NGIFDBSEEK('ST9',cBemSalvo,1)
					nPosCon1 := ST9->T9_POSCONT
					If NGIFDBSEEK('TPE',cBemSalvo,1)
						nPosCon2 := TPE->TPE_POSCON
					EndIf
				EndIf
			Else
				nPosCon1 := ST9->T9_POSCONT
				If NGIFDBSEEK('TPE',(cTempTable)->CODBEM,1)
					nPosCon2 := TPE->TPE_POSCON
				EndIf
			EndIf
		EndIf

		//----------------------------------------------------------------------
		// Grava Historico de Centro de Custo
		//----------------------------------------------------------------------
		If ::IsValid() .And. NGIFDBSEEK( 'ST9' , (cTempTable)->CODBEM , 1 ) .And.;
		ST9->T9_MOVIBEM = "S" .And.;
		(ST9->T9_CCUSTO != (cTempTable)->CCUSTO .Or. ST9->T9_CENTRAB != (cTempTable)->CTRABA)

			NGDBAREAORDE("TPN",1)
			RecLock("TPN",.T.)
			TPN->TPN_FILIAL := xFilial("TPN")
			TPN->TPN_CODBEM := ST9->T9_CODBEM
			TPN->TPN_DTINIC := ::GetValue('T9_DTBAIXA')
			TPN->TPN_HRINIC := cHourCont
			TPN->TPN_CCUSTO := (cTempTable)->CCUSTO
			TPN->TPN_CTRAB  := (cTempTable)->CTRABA
			TPN->TPN_UTILIZ := "U"
			TPN->TPN_POSCON := nPosCon1
			TPN->TPN_POSCO2 := nPosCon2
			MsUnLock("TPN")

         	//Funcao de integracao com o PIMS atraves do EAI
			If lPimSint
				NGIntPIMS("TPN" , TPN->(RecNo()) , 3 )
			EndIf
		EndIf

		//----------------------------------------------------------------------
		// Caso for pneu limpa campos TQS
		//----------------------------------------------------------------------
		If ::IsValid() .And. NGIFDBSEEK( 'ST9' , (cTempTable)->CODBEM , 1 ) .And.;
		ST9->T9_CATBEM $ "3"

		   	// limpa campos TQS
			If NGIFDBSEEK('TQS',ST9->T9_CODBEM,1)
				RecLock("TQS",.F.)
				TQS->TQS_PLACA  := ""
				TQS->TQS_POSIC  := ""
				TQS->TQS_TIPEIX := ""
				TQS->TQS_EIXO   := ""
				MsUnLock("TQS")
			EndIf

         	//Grava historico de status para pneus
			If ST9->T9_STATUS  != (cTempTable)->ST_BEM

				cSeekKey := ST9->T9_CODBEM
				cSeekKey += DToS(::GetValue('T9_DTBAIXA') )
				cSeekKey += IIf(AllTrim(cHourCont1)==":",SubStr(Time(),1,5),cHourCont1)
				cSeekKey += (cTempTable)->ST_BEM
				cSeekKey += ::GetValue('T9_CODESTO')
				cSeekKey += ::GetValue('T9_LOCPAD')

				If !NGIFDBSEEK( 'TQZ' , cSeekKey , 2 )
					RecLock("TQZ", .T.)
					TQZ->TQZ_FILIAL := xFilial("TQZ")
					TQZ->TQZ_CODBEM := ST9->T9_CODBEM
					TQZ->TQZ_DTSTAT := ::GetValue('T9_DTBAIXA')
					TQZ->TQZ_HRSTAT := cHourCont
					TQZ->TQZ_STATUS := (cTempTable)->ST_BEM
					TQZ->TQZ_PRODUT := ::GetValue('T9_CODESTO')
					TQZ->TQZ_ALMOX  := ::GetValue('T9_LOCPAD')
					MsUnLock("TQZ")
				EndIf
			EndIf
		EndIf

		//----------------------------------------------------------------------
		// Bem nao possui mais estrutura
		//----------------------------------------------------------------------
		If ::IsValid() .And. NGIFDBSEEK( 'ST9' , (cTempTable)->CODBEM , 1 )

			// ---------------------------------------------------
			// Verifica se posição na estrutura tem contador ativo
			// ---------------------------------------------------
			lActive := MNTVERATV( (cTempTable)->CODBEM, ::GetValue('T9_DTBAIXA'), cHourCont )

			If ( nPosCon1 - ST9->T9_POSCONT ) < 0
				nAcresc :=  ( ST9->T9_LIMICON - ST9->T9_POSCONT ) + nPosCon1
			Else
				nAcresc := nPosCon1 - ST9->T9_POSCONT
			EndIf

			RecLock( 'ST9' , .F. )
			ST9->T9_ESTRUTU := "N"
			ST9->T9_STATUS  := (cTempTable)->ST_BEM
			ST9->T9_CCUSTO  := (cTempTable)->CCUSTO
			ST9->T9_CENTRAB := (cTempTable)->CTRABA

			If lActive
				ST9->T9_CONTACU := ST9->T9_CONTACU + nAcresc
				ST9->T9_POSCONT := nPosCon1
			EndIf

			MsUnLock( 'ST9' )
		EndIf

		//----------------------------------------------------------------------
		// Movimentacao do Bem na Estrutura para Saida
		//----------------------------------------------------------------------
		If ::IsValid() .And. NGIFDBSEEK('STZ',(cTempTable)->CODBEM + 'E',1)

			cQuery := " UPDATE " + RetSqlName("STZ" )
			cQuery += "    SET TZ_TIPOMOV  = " + ValToSql("S")                      + ","
			cQuery += "        TZ_DATASAI  = " + ValToSql(::GetValue('T9_DTBAIXA')) + ","
			cQuery += "        TZ_CAUSA    = " + ValToSql(cCause)                   + ","
			cQuery += "        TZ_HORASAI  = " + ValToSql(cHourCont)                + ","
			cQuery += "        TZ_CONTSAI  = " + ValToSql(nPosCon1)                 + ","
			cQuery += "        TZ_CONTSA2  = " + ValToSql(nPosCon2)                 + ","
			cQuery += "        TZ_USUARIO  = " + ValToSql(cUserName)
			cQuery += "  WHERE TZ_FILIAL   = " + ValToSql(xFilial("STZ"))
			cQuery += "    AND TZ_CODBEM   = " + ValToSql((cTempTable)->CODBEM)
			cQuery += "    AND TZ_TIPOMOV  = " + ValToSql("E")
			cQuery += "    AND TZ_DATASAI  = ' ' "
			cQuery += "    AND D_E_L_E_T_ != " + ValToSql("*")
			If TcSqlExec( cQuery ) < 0
				::AddError( TCSQLError() )
	    	EndIf
		EndIf

		dbSelectArea( cTempTable )
		(cTempTable)->( DBSkip() )
	End

	//--------------------------------------------------------------------------
	// Inativa os bens selecionados
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsInactivate() .And. ::IsMainAsset()

		NGSETIFARQUI(cTempTable)
		While .Not. (cTempTable)->( EoF() )

			If Empty( (cTempTable)->OK )
				dbSelectArea( cTempTable )
				(cTempTable)->( DBSkip() )
				Loop
			EndIf

			//------------------------------------------------------------------
			// Inativa o bem
			//------------------------------------------------------------------
			If NGIFDBSEEK( 'ST9' , (cTempTable)->CODBEM , 1 )
				RecLock( 'ST9' , .F. )
				ST9->T9_DTBAIXA := ::GetValue('T9_DTBAIXA')
				ST9->T9_MTBAIXA := ::GetValue('T9_MTBAIXA')
				ST9->T9_SITBEM	:= "I"
				ST9->T9_SITMAN  := "I"
				MsUnLock( 'ST9' )
			EndIf

			//------------------------------------------------------------------
			// Inativa as manutencoes do bem
			//------------------------------------------------------------------
			If ::IsValid() .And. NGIFDBSEEK( 'STF' , (cTempTable)->CODBEM , 1 )
				cQuery := " UPDATE " + RetSqlName("STF" )
				cQuery += "    SET TF_ATIVO    = " + ValToSql("N")
				cQuery += "  WHERE TF_FILIAL   = " + ValToSql(xFilial("STF"))
				cQuery += "    AND TF_CODBEM   = " + ValToSql((cTempTable)->CODBEM)
				cQuery += "    AND D_E_L_E_T_ != " + ValToSql("*")
				If TcSqlExec( cQuery ) < 0
					::AddError( TCSQLError() )
				EndIf
			EndIf

			dbSelectArea( cTempTable )
			(cTempTable)->( DBSkip() )
		End
	EndIf

	//--------------------------------------------------------------------------
	// Inativa o bem pai
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsInactivate() .And.;
	NGIFDBSEEK( 'ST9' , ::GetValue('T9_CODBEM') , 1 )

		RecLock( 'ST9' , .F. )
		ST9->T9_DTBAIXA := ::GetValue('T9_DTBAIXA')
		ST9->T9_MTBAIXA := ::GetValue('T9_MTBAIXA')
		ST9->T9_STATUS  := ::GetValue('T9_STATUS')
		ST9->T9_SITBEM	:= 'I'
		ST9->T9_SITMAN  := "I"
		MsUnLock( 'ST9' )
	EndIf

	//--------------------------------------------------------------------------
	// Exclui registro na estrutura
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsInactivate() .And. ::IsMainAsset()

		NGSETIFARQUI(cTempTable)
		While .Not. (cTempTable)->( EoF() )

			If NGIFDBSEEK( 'STC' , (cTempTable)->CODBEM , 3 )
				RecLock( 'STC' , .F. )
				STC->( DBDelete() )
				MsUnlock( 'STC' )
			EndIf

			dbSelectArea( cTempTable )
			(cTempTable)->( DBSkip() )
		End
	EndIf

	//--------------------------------------------------------------------------
	// Exclui registro se estiver em uma estrutura (sendo filho)
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsInactivate() .And. ::IsMainAsset() .And.;
	NGIFDBSEEK( 'STC' , ::GetValue('T9_CODBEM') , 3 )

		RecLock( 'STC' , .F. )
		STC->( DBDelete() )
		MsUnlock( 'STC' )
	EndIf

	//--------------------------------------------------------------------------
	// Movimentacao do Bem na Estrutura para Saida
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsInactivate() .And. ::IsMainAsset() .And.;
	NGIFDBSEEK( 'STZ' , ::GetValue('T9_CODBEM') + 'E' , 1 )

		cQuery := " UPDATE " + RetSqlName("STZ" )
		cQuery += "    SET TZ_TIPOMOV  = " + ValToSql("S")
		cQuery += "        TZ_DATASAI  = " + ValToSql(::GetValue('T9_DTBAIXA'))
		cQuery += "        TZ_CAUSA    = " + ValToSql(cCause)
		cQuery += "        TZ_HORASAI  = " + ValToSql(cHourCont)
		cQuery += "        TZ_USUARIO  = " + ValToSql(cUserName)
		cQuery += "  WHERE TZ_FILIAL   = " + ValToSql(xFilial("STZ" ))
		cQuery += "    AND TZ_CODBEM   = " + ValToSql(::GetValue('T9_CODBEM'))
		cQuery += "    AND TZ_TIPOMOV  = " + ValToSql("E")
		cQuery += "    AND TZ_DATASAI  = ' ' "
		cQuery += "    AND D_E_L_E_T_ != " + ValToSql("*")
		If TcSqlExec( cQuery ) < 0
			::AddError( TCSQLError() )
    	EndIf
	EndIf

	//--------------------------------------------------------------------------
	// Integração do Equipamento com PIMS
	//--------------------------------------------------------------------------
	If ::IsValid() .And. GetNewPar("MV_PIMSINT",'.F.')
		NGIntPIMS( 'ST9' , ::GetRecno('ST9') , ::GetOperation() )
	EndIf

	If ::IsValid() .And. ::IsUpsert() .And. ::GetOperation() == 4 .And. ::lReactivate

		//Verifica se o sistema está integrado com ATF e alterações no MNT impactam no ATF( parâmetros 2 e 3).
		//E se o bem que está sendo reativado também está.
		If cAltATF $ "2#3" .And. NGIfDBSeek("SN1",::GetValue("T9_CODIMOB"),1)

			aArea := GetArea()
			cBase := SubStr(::GetValue("T9_CODIMOB"),1,TamSX3("N1_CBASE")[1])
			cItem := SubStr(::GetValue("T9_CODIMOB"),TamSX3("N1_CBASE")[1] + 1,Len(::GetValue("T9_CODIMOB")))

			dbSelectArea("SN3")
			dbSetOrder(1)
			If dbSeek(xFilial("SN3") + M->T9_CODIMOB)
				cTipo    := SN3->N3_TIPO
				cTpSaldo := SN3->N3_TPSALDO
				cSeq     := SN3->N3_SEQ
				cSeqReav := SN3->N3_SEQREAV
				cFilOri  := SN3->N3_FILORIG
			EndIf

			aCab := { {"FN6_FILIAL",xFilial("FN6"),NIL},;
				      {"FN6_CBASE" ,cBase         ,NIL},;
				      {"FN6_CITEM" ,cItem         ,NIL},;
                      {"FN6_DTBAIX",""            ,NIL},;
				      {"FN6_MOTIVO","08"          ,NIL},;
				      {"FN6_DEPREC",cMetDepr      ,NIL}}

			aAtivo := {{"N3_FILIAL" ,xFilial("SN3"),NIL},;
				       {"N3_CBASE"  ,cBase         ,NIL},;
				       {"N3_ITEM"   ,cItem         ,NIL},;
				       {"N3_TIPO"   ,cTipo         ,NIL},;
				       {"N3_BAIXA"  ,"1"           ,NIL},;
				       {"N3_TPSALDO",cTpSaldo      ,NIL},;
				       {"N3_SEQ"    ,cSeq          ,NIL},;
				       {"N3_SEQREAV",cSeqReav      ,NIL},;
				       {"N3_FILORIG",cFilOri       ,NIL}}

			MsExecAuto({|a,b,c,d,e,f|ATFA036(a,b,c,d,e,f)},aCab,aAtivo,5,,.T.,) //Chama o ExecAuto do ATFA036 afim de reativar o Ativo.
			If lMsErroAuto
				MostraErro()
			EndIf
			RestArea(aArea)
		EndIf
	EndIf

	If ::IsValid() .And. ::IsUpdate() .And. !::IsInactivate() .And.;
		( ::GetValue( 'T9_CODFAMI' ) != cFamOld .Or. ::GetValue( 'T9_TIPMOD' ) != cModOld )

		/*---------------------------------------------------+
		| Existindo uma manutenção padrão para nova família, | 
		| gerar automaticamente a manutenção.                |
		+---------------------------------------------------*/
		If MNTSeekPad( 'TPF', 4, cFamOld, cModOld )

			/*-----------------------------------------------------------------+
			| Inativa manutenções geradas por manut padrão da família alterada | 
			+-----------------------------------------------------------------*/
			aPeriodic := MNTA120Ina( ::GetValue( 'T9_CODBEM' ), cFamOld, cModOld )

		EndIf

		/*---------------------------------------------------+
		| Existindo uma manutenção padrão para nova família, | 
		| gerar automaticamente a manutenção.                |
		+---------------------------------------------------*/
		If MNTSeekPad( 'TPF', 4, ::GetValue( 'T9_CODFAMI' ),;
			::GetValue( 'T9_TIPMOD' ) )

			/*---------------------------------------------------------------------------+
			| Reativa manutenções geradas por manut padrão, caso exista alguma inativada | 
			+---------------------------------------------------------------------------*/
			If !MNTA120Atv( ::GetValue( 'T9_CODBEM' ), ::GetValue( 'T9_CODFAMI' ),;
				::GetValue( 'T9_TIPMOD' ), aPeriodic[1] )

				/*-----------------------------------------------------------------+
				| Inativa manutenções geradas por manut padrão da família alterada | 
				+-----------------------------------------------------------------*/
				MNTA081( { ::GetValue( 'T9_CODBEM' ), ::GetValue( 'T9_CODFAMI' ),;
					::GetValue( 'T9_TIPMOD' ), TPF->TPF_SERVIC }, aPeriodic[2] )

			EndIf

		EndIf

	EndIf

	//--------------------------------------------------------------------------
	// Alerta sobre Manutenção Padrão já cadastrada
	//--------------------------------------------------------------------------
	If .Not.::IsUpdate() .And. .Not.::IsInactivate()
		aVet := {M->T9_CODBEM,M->T9_CODFAMI}
	    If lTipMod
			aAdd(aVet,M->T9_TIPMOD)
		EndIf

	    If MNTSeekPad( 'TPF', 4, M->T9_CODFAMI, M->T9_TIPMOD )

	    	MNTA081(aVet)

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

	FWFreeArray( aPeriodic )

Return ::IsValid()

//------------------------------------------------------------------------------
/*/{Protheus.doc}Delete
Método para exclusão dos alias definidos para a classe.

@author NG Informática Ltda.
@since 01/01/2015
@version P12
@return lDelete Confirmação da operação.
@sample If oObj:valid()
           oObj:upsert()
        Else
           Help(,,'HELP',, oTPN:getErrorList()[1],1,0)
        EndIf
/*/
//------------------------------------------------------------------------------
Method Delete() Class MntBem

	Local cQuery := ''
	Local nRegMov

	// Carrega todas os campos da classe em memoria de trabalho
	::ClassToMemory()

	BEGIN TRANSACTION

	//--------------------------------------------------------------------------
	// Remove associação com Construção civil
	//--------------------------------------------------------------------------
	If FieldPos("TTM_FILIAL") > 0 //pode ser removido a partir da 12.1.13
		If ::IsValid() .And. NGIFdbSeek( 'TTM' , ::GetValue('T9_CODBEM') ,1 )
			RecLock( 'TTM' , .F. )
			dbDelete()
			MsUnLock( 'TTM' )
		EndIf
	EndIf
	//--------------------------------------------------------------------------
	// Remove associação com ativo fixo
	//--------------------------------------------------------------------------
	If ::IsValid() .And. GetNewPar("MV_NGMNTAT",'') $ "1/2"
		cQuery := " UPDATE " + RetSqlName("SN1")
		cQuery += "    SET N1_CODBEM   = ' ' "
		cQuery += "  WHERE N1_FILIAL   = " + ValToSql(xFilial("SN1"))
		cQuery += "    AND N1_CODBEM   = " + ValToSql(::GetValue('T9_CODBEM'))
		cQuery += "    AND D_E_L_E_T_ != " + ValToSql("*")
		If TcSqlExec( cQuery ) < 0
			::AddError( TCSQLError() )
    	EndIf
	EndIf

	//--------------------------------------------------------------------------
	// Historico de movimentacao estrutura organizacional
	//--------------------------------------------------------------------------
	If ::IsValid()

		dbSelectArea( 'TAF' )
		dbSetOrder( 6 )
		dbSeek( xFilial( 'TAF' ) + 'X1' + ::GetValue('T9_CODBEM') )
		If Found()

			dbSelectArea( 'TCJ' )
			dbSetOrder( 1 )
			dbSeek( xFilial( 'TCJ' ) + TAF->TAF_CODNIV + TAF->TAF_NIVSUP + "E" + DToS( dDataBase ) + Time() )
			If .Not. Found()

				RecLock("TCJ" , .T. )
				TCJ->TCJ_FILIAL := xFilial("TCJ" )
				TCJ->TCJ_CODNIV := TAF->TAF_CODNIV
				TCJ->TCJ_DESNIV := SubStr( TAF->TAF_NOMNIV , 1 , 40 )
				TCJ->TCJ_NIVSUP := TAF->TAF_NIVSUP
				TCJ->TCJ_DATA   := dDatabase
				TCJ->TCJ_HORA   := Time()
				TCJ->TCJ_TIPROC := "E"
				MsUnLock("TCJ" )
			EndIf
		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// Exclui Historico da TPN ( Centro de Custo )
	//--------------------------------------------------------------------------
	If ::IsValid()
		For nRegMov := 1 To Len(::aNGMovBem )
			::aNGMovBem[nRegMov]:Delete()
			::aNGMovBem[nRegMov]:Free()
		Next
	EndIf

	//--------------------------------------------------------------------------
	// Exclui equipamento e relacionados
	//--------------------------------------------------------------------------
	_Super:Delete()

	//--------------------------------------------------------------------------
	// Finaliza processo de gravação
	//--------------------------------------------------------------------------
	If !::IsValid()
		//END TRANSACTION
		//MsUnlockAll()
	//Else
		DisarmTransaction()
	EndIf

	END TRANSACTION
	MsUnlockAll()
Return ::IsValid()

//------------------------------------------------------------------------------
/*/{Protheus.doc} Inactivate
Incializa atributos para a inativação do bem e seus componentes

@author NG Informática Ltda.
@since 01/01/2015
/*/
//------------------------------------------------------------------------------
Method Inactivate( cCause , cHourCont1 , dDateCont2 , cHourCont2 , cTempTable , lMainAsset ) Class MntBem

	// Código da causa para o histórico de movimentação de estrutura
	aAdd(::aInactive , { 'cCause' 	   , cCause } )

	// Hora de leitura para o contador 1
	aAdd(::aInactive , { 'cHourCont1' , cHourCont1 } )

	// Data de leitura para o contador 2
	aAdd(::aInactive , { 'dDateCont2' , dDateCont2 } )

	// Hora de leitura para o contador 2
	aAdd(::aInactive , { 'cHourCont2' , cHourCont2 } )

	// Hora de leitura para o contador 1
	aAdd(::aInactive , { 'cTempTable' , cTempTable } )

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetAssetAtt
Retorna atributo especifico de bem

@author NG Informática Ltda.
@since 01/01/2015
/*/
//------------------------------------------------------------------------------
Method GetAssetAtt(cAttribute) Class MntBem

	Local nPos := 0

	nPos := aScan(::aInactive,{|a| a[1] == AllTrim(cAttribute)})
	If nPos == 0
		ExUserException("GetAssetAtt error: "+cAttribute) //Erro
	EndIf

Return ::aInactive[nPos][2]

//------------------------------------------------------------------------------
/*/{Protheus.doc} IsInactivate
Indica se é um processo de inativação do bem

@author NG Informática Ltda.
@since 01/01/2015
@return bool -	.T. - Inativação, .F. - Outro Processo
/*/
//------------------------------------------------------------------------------
Method IsInactivate() Class MntBem
Return ::GetOperation() == _OPERATION_INACTIVATE_

//------------------------------------------------------------------------------
/*/{Protheus.doc} IsMainAsset
Indica se o bem é pai de uma estrutura

@author NG Informática Ltda.
@since 01/01/2015
@return bool -	.T. - Pai, .F. - Não é Pai
/*/
//------------------------------------------------------------------------------
Method IsMainAsset() Class MntBem
Return NGIFdbSeek( 'STC' , ::GetValue('T9_CODBEM') , 1 )

//------------------------------------------------------------------------------
/*/{Protheus.doc} IsMainAsset
Indica se o bem faz parte de uma estrutura

@author NG Informática Ltda.
@since 01/01/2015
@return bool -	.T. - Faz parte de estrutura, .F. - Não faz parte
/*/
//------------------------------------------------------------------------------
Method IsHasStruc() Class MntBem

	Local lIsStruc := .F.

	If NGIFdbSeek("STC",::GetValue("T9_CODBEM"),1)
		If STC->TC_TIPOEST = "B"
			lIsStruc := .T.
		EndIf
	EndIf

	If !lIsStruc
		If NGIFdbSeek("STC",::GetValue("T9_CODBEM"),3)
			If STC->TC_TIPOEST = "B"
				lIsStruc := .T.
			EndIf
		EndIf
	EndIf

Return lIsStruc

//------------------------------------------------------------------------------
/*/{Protheus.doc} IsSale
Indica se a operação é uma venda do equipamento

@author NG Informática Ltda.
@since 01/01/2015
/*/
//------------------------------------------------------------------------------
Method IsSale() Class MntBem

	Local lSale := .F.

	If .Not. Empty(::GetValue('T9_DTVENDA') ) .And.;
	.Not. Empty(::GetValue('T9_COMPRAD') ) .And.;
	.Not. Empty(::GetValue('T9_NFVENDA') )
		lSale := .T.
	EndIf

Return lSale
