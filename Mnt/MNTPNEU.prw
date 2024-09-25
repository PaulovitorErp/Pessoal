#Include "PROTHEUS.CH"
#Include "MNTPNEU.CH"

Static lRel12133 := GetRPORelease() >= '12.1.033'

// Força a publicação do fonte
Function _MntPneu()
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} MntPneu
Classe de Pneus

@author NG Informática Ltda.
@since 01/01/2015
@version P12
/*/
//------------------------------------------------------------------------------
Class MntPneu FROM MntBem

	Method New() CONSTRUCTOR

	// Metodos Publicos
	Method ValidBusiness()
	Method Upsert()
	Method Delete()

	// Metodos Privados
	Method IsAplicado()

EndClass

//------------------------------------------------------------------------------
/*/{Protheus.doc} New
Método inicializador da classe

@author NG Informática Ltda.
@since 07/10/2014
@version P11
@return Self O objeto criado.
/*/
//------------------------------------------------------------------------------
Method New() Class MntPneu

	_Super:New()

	// Alias formulario
	::SetAlias( 'TQS' )

Return Self

//------------------------------------------------------------------------------
/*/{Protheus.doc} ValidBusiness
Método que realiza a validação da regra de negócio da classe.

@param nOp Número da operação (3(insert)/4(update)=upsert; 5=delete)
@author NG Informática Ltda.
@since 07/10/2014
@version P12
@return lValid Validação ok.
@obs este método não é chamado diretamente.
/*/
//------------------------------------------------------------------------------
Method ValidBusiness() Class MntPneu

	Local cError    := '' // Retorno: Indicam consistência do resgitro
	Local lFound    := .F.
	Local aAreaST9
	Local nField
	Local lExistTwi := TQS->( FieldPos("TQS_TWI") ) > 0
	Local cAliasQry := ''
	Local cPneu     := ''
	Local cTipExTQS := ''
	Local cEixo		:= ''

	//--------------------------------------------------------------------------
	// Validação inicial para frotas
	//--------------------------------------------------------------------------
	If GetRPORelease() < '12.1.033' .And. GetNewPar('MV_NGMNTFR','N') != 'S'
		::AddError( STR0001 ) //'Para cadastro de pneus, precisa integração com Frotas(MV_NGMNTFR).'
	ElseIf GetNewPar('MV_NGPNEUS','N') != 'S'
		::AddError( STR0002 ) //'Para cadastro de pneus, precisa integração com Pneus(MV_NGPNEUS).'
	ElseIf ::GetValue('T9_CATBEM') != '3'
		::AddError( STR0003 ) //'Para cadastro de pneus, o bem precisa ser da categoria tipo 3 (Pneu).'
	EndIf

	//--------------------------------------------------------------------------
	// Consistencia com a regra de negocio da classe de bens
	//--------------------------------------------------------------------------
	If ::IsValid()
		_Super:ValidBusiness()
	EndIf

	//--------------------------------------------------------------------------
	// Valida exclusão de um pneu com vínculo com nf
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsDelete() .And. TQZ->( FieldPos("TQZ_NUMSEQ") ) > 0 .And. !FwIsInCallStack( 'MATA103' )

		cAliasQry := GetNextAlias()
		cPneu     := ::GetValue('T9_CODBEM')

		BeginSQL Alias cAliasQry

			SELECT TQZ.TQZ_NUMSEQ
			FROM %table:TQZ% TQZ
			WHERE TQZ.TQZ_FILIAL = %xFilial:TQZ%
				AND TQZ.TQZ_CODBEM = %exp:cPneu%
				AND TQZ.TQZ_NUMSEQ <>  ' '
				AND TQZ.TQZ_ORIGEM = 'SD1'
				AND TQZ.%NotDel%

		EndSQL

		If !(cAliasQry)->( Eof() )
			::AddError( STR0025  + ' ' + (cAliasQry)->TQZ_NUMSEQ) // 'Esse pneu tem vínculo com uma nota fiscal.'
		EndIf

		(cAliasQry)->( dbCloseArea() )

	EndIf

	//--------------------------------------------------------------------------
	// Campos obrigatórios do Pneus
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpsert()

		//
		If Empty( ::GetValue('T9_STATUS') )

			::AddError( ::MsgRequired( "T9_STATUS" ) )

			//
		ElseIf ::GetValue('TQS_BANDAA') != '1'  .And.;
		!Empty( ::GetValue('TQS_BANDAA') ) .And.;
		Empty( ::GetValue('TQS_DESENH') )

			::AddError( ::MsgRequired( "TQS_DESENH" ) )

			//
		ElseIf Empty( ::GetValue('TQS_DTMEAT') )

			::AddError( ::MsgRequired( "TQS_DTMEAT" ) )

			//
		ElseIf Empty( ::GetValue('TQS_HRMEAT') ) .Or.;
		::GetValue('TQS_HRMEAT') == '  :  '

			::AddError( ::MsgRequired( "TQS_HRMEAT" ) )
		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// Campos obrigatórios para pneu aplicado
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ( ::IsInsert() .Or. IsInCallStack( 'MNTA086' ) ) .And. ::IsAplicado()
		// 008 -
		If Empty( ::GetValue('TQS_PLACA') )

			::AddError( ::MsgRequired( "TQS_PLACA" ) )

		// 009 -
		ElseIf Empty( ::GetValue('TQS_POSIC') )

			::AddError( ::MsgRequired( "TQS_POSIC" ) )

		// 010 -
		ElseIf Empty( ::GetValue('TQS_TIPEIX') )

			::AddError( ::MsgRequired( "TQS_TIPEIX" ) )

		// 011 -
		ElseIf Empty( ::GetValue('TQS_EIXO') )

			::AddError( ::MsgRequired( "TQS_EIXO" ) )

		ElseIf lExistTwi .And. ::GetValue("TQS_TWI") > 0
			If !Empty( ::GetValue("TQS_POSIC") ) .And. ::GetValue("TQS_SULCAT") < ::GetValue("TQS_TWI")
				::AddError(STR0023 + '"' + AllTrim( ::GetValue("T9_NOME") ) + '" ' + STR0024 )
			EndIf
		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// Campos obrigatórios de estoque
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpsert() .And.;
	( .Not. Empty( ::GetValue('T9_CODESTO') ) .Or. .Not. Empty( ::GetValue('T9_LOCPAD') ) )

		If Empty( ::GetValue('T9_CODESTO') )
			::AddError( ::MsgRequired( "T9_CODESTO" ) )
		ElseIf Empty( ::GetValue('T9_LOCPAD') )
			::AddError( ::MsgRequired( "T9_LOCPAD" ) )
		EndIf
	EndIf

	//--------------------------------------------------------------------------
	// Status
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpsert() .And. SuperGetMv("MV_NGSTARI",.F.," ") == ::GetValue('T9_STATUS')
		::AddError( STR0005 ) //"'Status Bem' deverá ser diferente do conteúdo do parâmetro 'MV_NGSTARI'."
	EndIf

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsInsert() .And. .Not. Empty( ::GetValue('TQS_PLACA') )
		aAreaST9 := ST9->( GetArea() )

		DBSelectArea( 'ST9' )
		DBSetOrder( 14 )
		DBSeek( ::GetValue('TQS_PLACA') + 'A' )

		If Found()

			DBSelectArea( 'STC' )
			DBSetOrder( 6 )
			DBSeek( xFilial('STC') + ST9->T9_CODBEM+ST9->T9_TIPMOD+"B"+::GetValue('TQS_POSIC') )
			If Found() .And. ::GetValue('TQS_CODBEM') != STC->TC_COMPONE

				::AddError( STR0006 ) //"Localização já existe."
			EndIf
		EndIf
		RestArea( aAreaST9 )
	EndIf

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpsert() .And. AllTrim(::GetValue('TQS_BANDAA') ) == "1"

		DBSelectArea( 'TQX' )
		DBSetOrder( 1 )
		DBSeek( xFilial('TQX') + ::GetValue('TQS_MEDIDA') + ::GetValue('T9_TIPMOD') )

		//Se o Sulco informado for maior que o Sulco definido na rotina Medida x Modelo.
		If Found() .And. ::GetValue('TQS_SULCAT') > TQX->TQX_SULCOO
			::AddError( STR0007 ) //"Sulco do pneu não pode ser maior que o definido na sua medida e modelo"
		EndIf
	EndIf

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpsert() .And. AllTrim(::GetValue('TQS_BANDAA') ) != "1" .And.;
	.Not. Empty( ::GetValue('TQS_DESENH') )

		DBSelectArea( 'TQU' )
		DBSetOrder( 1 )
		DBSeek( xFilial('TQU') + AllTrim( ::GetValue('TQS_DESENH') ) )

		// Se o Sulco informado for maior que o Sulco definido na rotina de Desenho.
		If Found() .And. ::GetValue('TQS_SULCAT') > TQU->TQU_SULCO
			::AddError( STR0008 ) //"Sulco do pneu não pode ser maior que o definido no Desenho."
		EndIf
	EndIf

	//--------------------------------------------------------------------------
	//
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsUpsert() .And. ::IsAplicado() .And.;
	.Not. Empty(::GetValue('TQS_PLACA')) .And. NGIFdbSeek( "ST9" , ::GetValue('TQS_PLACA') + "A" , 14 )

		DBSelectArea( 'TQ0' )
		DBSetOrder( 1 )

		If lRel12133
			MNTSeekPad( 'TQ0', 1, ST9->T9_CODFAMI, ST9->T9_TIPMOD )
		Else
			DBSeek( xFilial('TQ0') + ST9->T9_CODFAMI + ST9->T9_TIPMOD )
		EndIf

		If .Not. Found()
			::AddError( STR0009 ) //"Esse veículo não possui esquema padrão."
		EndIf

		If ::IsValid() .And. .Not. Empty( ::GetValue('TQS_POSIC') )
			cAliasQry := GetNextAlias()
			cQuery := " SELECT COUNT(1) COUNTER "
			cQuery += " FROM " + RetSqlName("TQ1")
			cQuery += " WHERE "
			cQuery += "     TQ1_FILIAL  =  " + ValToSql( xFilial( "TQ1" ) )
			cQuery += " AND TQ1_DESENH  =  " + ValToSql( TQ0->TQ0_DESENH )
			cQuery += " AND TQ1_TIPMOD  =  " + ValToSql( TQ0->TQ0_TIPMOD )
			cQuery += " AND TQ1_TIPEIX  =  " + ValToSql( ::GetValue('TQS_TIPEIX') )
			cQuery += " AND D_E_L_E_T_ = '' "
			If AllTrim(::GetValue('TQS_EIXO')) == "R"

    			cEixo := 'RESERVA'

			Else

     			cEixo := AllTrim(::GetValue('TQS_EIXO'))

			EndIf
			cQuery += " AND LTRIM( RTRIM( TQ1_EIXO ) ) = " + ValToSql( cEixo )
			cQuery += " AND ("
			For nField := 0 To 9
				If nField != 0
					cQuery += " OR "
				EndIf
				cQuery += " ( "
				cQuery += "     TQ1_LOCPN" + cValToChar( nField ) +  " = " + ValToSql( ::GetValue('TQS_POSIC') )
				cQuery += " AND TQ1_FAMIL" + cValToChar( nField ) +  " = " + ValToSql( ::GetValue('T9_CODFAMI') )
				cQuery += " ) "
			Next
			cQuery += "     ) "
			cQuery := ChangeQuery( cQuery )
			dbUseArea( .T. , "TOPCONN" , TCGENQRY( , , cQuery ) , cAliasQry , .F. , .T. )
			If (cAliasQry)->COUNTER > 0
				lFound := .T.
			EndIf
			( cAliasQry )->( dbCloseArea() )
		EndIf

		If ::IsValid() .And. .Not. lFound
			DBSelectArea( 'TQ1' )
			DBSetOrder( 1 )
			DBSeek( xFilial('TQ1') + ST9->T9_CODFAMI + ST9->T9_TIPMOD )
			While .Not. TQ1->( EoF() )

				cEixoTQS := AllTrim( ::GetValue('TQS_EIXO') )
				cTipExTQS := ::GetValue('TQS_TIPEIX')

				If .Not. Empty(TQ1->TQ1_EIXO) .And.(;
				cEixoTQS == Substr(AllTrim(TQ1->TQ1_EIXO),1,1) .Or.;
				cEixoTQS == Substr(AllTrim(TQ1->TQ1_EIXO),1,2) )
					If (cEixoTQS + cTipExTQS != Substr(AllTrim(TQ1->TQ1_EIXO),1,1) + TQ1->TQ1_TIPEIX) .Or.;
					(cEixoTQS + cTipExTQS != Substr(AllTrim(TQ1->TQ1_EIXO),1,2) + TQ1->TQ1_TIPEIX)
						cError := Trim( RetTitle("TQS_TIPEIX") )
						cError += ' ' + STR0010 + ' ' // "diverge do esquema padrão"
						cError += Trim( RetTitle("TQ1_TIPEIX") )
						cError += ' ' + STR0013 + ' ' // "não é o cadastrado para este eixo, altere"
						cError += Trim( RetTitle("TQS_TIPEIX") )
						cError += ' ' + STR0014 + ' ' // "ou"
						cError += Trim( RetTitle("TQS_EIXO") )
						::AddError( cError )
						Exit
					EndIf
				Else
					cError := Trim( RetTitle("TQS_EIXO") )
					cError += ' ' + STR0015 + ' ' // "não coincide com"
					cError += Trim( RetTitle("TQS_TIPEIX") )
					cError += ' ' + STR0016 + ' ' // "Altere para um"
					cError += Trim( RetTitle("TQS_EIXO") )
					cError += ' ' + STR0017 // "compatível"
					::AddError( cError )
					Exit
				EndIf

				cPosicTQS := ::GetValue('TQS_POSIC')
				cFamilST9 := ::GetValue('T9_CODFAMI')

				If !Empty( cPosicTQS ) .And.;
				(cPosicTQS != TQ1->TQ1_LOCPN1) .And.;
				(cPosicTQS != TQ1->TQ1_LOCPN2) .And.;
				(cPosicTQS != TQ1->TQ1_LOCPN3) .And.;
				(cPosicTQS != TQ1->TQ1_LOCPN4) .And.;
				(cPosicTQS != TQ1->TQ1_LOCPN5) .And.;
				(cPosicTQS != TQ1->TQ1_LOCPN6) .And.;
				(cPosicTQS != TQ1->TQ1_LOCPN7) .And.;
				(cPosicTQS != TQ1->TQ1_LOCPN8) .And.;
				(cPosicTQS != TQ1->TQ1_LOCPN9) .And.;
				(cPosicTQS != TQ1->TQ1_LOCPN0)

					cError := Trim(RetTitle("TQS_POSIC"))
					cError += ' ' + STR0010 + ' ' // "diverge do esquema padrão"
					cError += CRLF + STR0019 //"Altere a posição de acordo com o"
					cError += ' ' + Trim( RetTitle("TQS_EIXO") )
					::AddError( cError )
					Exit

				EndIf

				If !Empty( cPosicTQS ) .And. !Empty( cFamilST9 ) .And.;
				(cPosicTQS == TQ1->TQ1_LOCPN1 .And. cFamilST9 != TQ1->TQ1_FAMIL1) .Or.;
				(cPosicTQS == TQ1->TQ1_LOCPN2 .And. cFamilST9 != TQ1->TQ1_FAMIL2) .Or.;
				(cPosicTQS == TQ1->TQ1_LOCPN3 .And. cFamilST9 != TQ1->TQ1_FAMIL3) .Or.;
				(cPosicTQS == TQ1->TQ1_LOCPN4 .And. cFamilST9 != TQ1->TQ1_FAMIL4) .Or.;
				(cPosicTQS == TQ1->TQ1_LOCPN5 .And. cFamilST9 != TQ1->TQ1_FAMIL5) .Or.;
				(cPosicTQS == TQ1->TQ1_LOCPN6 .And. cFamilST9 != TQ1->TQ1_FAMIL6) .Or.;
				(cPosicTQS == TQ1->TQ1_LOCPN7 .And. cFamilST9 != TQ1->TQ1_FAMIL7) .Or.;
				(cPosicTQS == TQ1->TQ1_LOCPN8 .And. cFamilST9 != TQ1->TQ1_FAMIL8) .Or.;
				(cPosicTQS == TQ1->TQ1_LOCPN9 .And. cFamilST9 != TQ1->TQ1_FAMIL9) .Or.;
				(cPosicTQS == TQ1->TQ1_LOCPN0 .And. cFamilST9 != TQ1->TQ1_FAMIL0)
						cError := Trim(RetTitle("T9_CODFAMI"))
						cError += ' ' + STR0010 + ' ' // "diverge do esquema padrão"
						cError += STR0018 // "Verifique a familia no folder Bem. Ela deve coincidir com a familia cadastrada no esquema padrão para este eixo"
						::AddError( cError )
						Exit
				EndIf
				
				TQ1->( dbSkip() )
			End
		EndIf

		If ::IsValid() .And. NGIFdbSeek("STC",ST9->T9_CODBEM+ST9->T9_TIPMOD+"B"+::GetValue('TQS_POSIC'),6)
			If ::GetValue('TQS_CODBEM') <> STC->TC_COMPONE
				::AddError( STR0006 ) //"Localização já existe."
			EndIf
		EndIf

		If ::IsValid() .And. Empty( ::GetValue('T9_DTULTAC') )
			cError := STR0020 //"Para aplicar esse pneu na estrutura é necessário informar o campo'"
			cError += RetTitle( 'T9_DTULTAC' )
			cError += STR0021 // "' e que ele seja controlado por contador."
			::AddError( cError )
		EndIf
	EndIf

Return ::IsValid()

//------------------------------------------------------------------------------
/*/{Protheus.doc} Upsert
Método para inclusao e alteracao dos alias definidos para a classe.

@author NG Informática Ltda.
@since 10/10/2014
@version P11
@return lUpsert Operação ok.
@sample If oObj:valid()
oObj:upsert()
Else
Help(,,'HELP',, oTPN:getErrorList()[1],1,0)
EndIf
/*/
//------------------------------------------------------------------------------
Method Upsert() Class MntPneu

	Local aAreaST9
	Local cSeq := ''
	Local cSeekKey := ''

	//carrega todas os campos da classe em memoria de trabalho
	::classToMemory()

	BEGIN TRANSACTION

	_Super:upsert()

	//--------------------------------------------------------------------------
	// Aplica pneu na estrutura
	//--------------------------------------------------------------------------
	If ::IsValid() .And. ::IsAplicado() .And.;
		!Empty(::GetValue('TQS_PLACA')) .And.;
		NGIFdbSeek("ST9",::GetValue('TQS_PLACA')+"A",14) .And.;
		fSeekPad( ST9->T9_CODFAMI, ST9->T9_TIPMOD ) .And.;
		NGIFDBSEEK( "TQ1" , TQ0->TQ0_DESENH + TQ0->TQ0_TIPMOD , 1 )

		// Armazena seqrela
		DBSelectArea( 'STC' )
		DBSetOrder( 1 )
		DBSeek( xFilial( 'STC' ) + ::GetValue('TQS_CODBEM') , .T. )
		cSeq := Space( Len( STC->TC_SEQRELA ) )

		// Amrazena posicionamento atual
		aAreaST9 := ST9->( GetArea() )

		// Posiciona registro do pai da estrutura
		DBSelectArea( 'ST9' )
		DBSetOrder( 14 )
		DBSeek( ::GetValue('TQS_PLACA') + 'A' )

		// Verifica se ja existe informaçãoes da estrutura e grava estrutura
		DBSelectArea( 'STC' )
		DBSetOrder( 1 )
		DBSeek( xFilial('STC') + ST9->T9_CODBEM + ::GetValue('TQS_CODBEM')+ "B" + ::GetValue('TQS_POSIC') )
		If .Not. STC->( Found() )
			RecLock( 'STC' , .T. )
			STC->TC_FILIAL  := xFilial("STC")
			STC->TC_CODBEM  := ST9->T9_CODBEM
			STC->TC_COMPONE := ::GetValue('TQS_CODBEM')
			STC->TC_TIPOEST := "B"
			STC->TC_LOCALIZ := ::GetValue('TQS_POSIC')
		Else
			RecLock( 'STC' , .F. )
		EndIf
		STC->TC_TIPMOD  := ST9->T9_TIPMOD
		STC->TC_DATAINI := ::GetValue('T9_DTULTAC')
		STC->TC_SEQRELA := cSeq
		MsUnLock( 'STC' )

		// Grava histórico de movimentação de estrutura
		DBSelectArea( 'STZ' )
		DBSetOrder( 1 )
		DBSeek( xFilial( 'STZ' ) + ::GetValue('TQS_CODBEM') + 'E' )
		If .Not. STZ->( Found() )
			RecLock( 'STZ' , .T. )
			STZ->TZ_FILIAL  := xFilial("STZ",ST9->T9_FILIAL)
			STZ->TZ_CODBEM  := ::GetValue('TQS_CODBEM')
			STZ->TZ_BEMPAI  := ST9->T9_CODBEM
			STZ->TZ_LOCALIZ := ::GetValue('TQS_POSIC')
			STZ->TZ_DATAMOV := ::GetValue('T9_DTULTAC')
			STZ->TZ_POSCONT := ST9->T9_POSCONT
			STZ->TZ_TIPOMOV := "E"
			//Verificar se o bem tem 1º contador
			If ::GetValue('T9_TEMCONT') <> "N"
				STZ->TZ_HORACO1 := Time()
			EndIf
			STZ->TZ_HORAENT := Time()
			STZ->TZ_TEMCONT := ::GetValue('T9_TEMCONT')
			STZ->TZ_TEMCPAI := ST9->T9_TEMCONT
			STZ->TZ_USUARIO := cUserName
			MsUnLock( 'STZ' )
		EndIf

		//------------------------------
		// Atualiza campo do pneu
		//------------------------------
		If NGIFDBSEEK( "ST9", ::GetValue('TQS_CODBEM'), 1 )
			RecLock("ST9",.F.)
			ST9->T9_ESTRUTU := 'S'
			MsUnLock("ST9")
		EndIf

		// Retorna posicionamento
		RestArea( aAreaST9 )

	EndIf

	//--------------------------------------------------------------------------
	// Grava histórico de sulco do pneu
	//--------------------------------------------------------------------------
	If ::IsValid() .And. .Not. Empty( ::GetValue('TQS_DTMEAT') )

		DBSelectArea( 'TQV' )
		DBSetOrder( 1 )

		cSeekKey := xFilial("TQV")
		cSeekKey += ::GetValue('T9_CODBEM' )
		cSeekKey += DToS( ::GetValue('TQS_DTMEAT') )
		cSeekKey += ::GetValue('TQS_HRMEAT')
		cSeekKey += ::GetValue('TQS_BANDAA')

		DBSeek( cSeekKey )
		If .Not. TQV->( Found() )
			RecLock( 'TQV' , .T. )
			TQV->TQV_FILIAL := xFilial("TQV")
			TQV->TQV_CODBEM := ::GetValue('T9_CODBEM' )
			TQV->TQV_DTMEDI := ::GetValue('TQS_DTMEAT')
			TQV->TQV_HRMEDI := ::GetValue('TQS_HRMEAT')
			TQV->TQV_BANDA  := ::GetValue('TQS_BANDAA')
			TQV->TQV_DESENH := ::GetValue('TQS_DESENH')
		Else
			RecLock( 'TQV' , .F. )
		EndIf
		TQV->TQV_SULCO  := ::GetValue('TQS_SULCAT')
		MsUnLock( 'TQV' )
	EndIf

	//--------------------------------------------------------------------------
	// Grava histórico de status do pneu
	//--------------------------------------------------------------------------
	If ::IsValid() .And. .Not. Empty( ::GetValue('T9_STATUS') )

		If .Not. Empty( ::GetValue('TQS_DTMEAT') )
			dDtStatus := ::GetValue('TQS_DTMEAT')
			cHrStatus := ::GetValue('TQS_HRMEAT')
		Else
			dDtStatus := ::GetValue('T9_DTINSTA')
			cHrStatus := Time()
		EndIf

		DBSelectArea( 'TQZ' )
		DBSetOrder( 1 )

		cSeekKey := xFilial("TQZ")
		cSeekKey += ::GetValue('T9_CODBEM' )
		cSeekKey += DToS( dDtStatus )
		cSeekKey += cHrStatus
		cSeekKey += ::GetValue('T9_STATUS')

		DBSeek( cSeekKey )
		If .Not. TQZ->( Found() )
			RecLock( 'TQZ' , .T. )
			TQZ->TQZ_FILIAL := xFilial("TQZ")
			TQZ->TQZ_CODBEM := ::GetValue('T9_CODBEM')
			TQZ->TQZ_DTSTAT := dDtStatus
			TQZ->TQZ_HRSTAT := cHrStatus
			TQZ->TQZ_STATUS := ::GetValue('T9_STATUS')
			TQZ->TQZ_PRODUT := ::GetValue('T9_CODESTO')
			TQZ->TQZ_ALMOX  := ::GetValue('T9_LOCPAD')
		Else
			RecLock( 'TQZ' , .F. )
		EndIf
		TQZ->TQZ_PRODUT := ::GetValue('T9_CODESTO')
		If .Not. Empty(::GetValue('T9_LOCPAD'))
			TQZ->TQZ_ALMOX  := ::GetValue('T9_LOCPAD')
		EndIf
		MsUnLock( 'TQZ' )
	EndIf

	//--------------------------------------------------------------------------
	// Grava relacionamento multi-empresa
	//--------------------------------------------------------------------------

	//Comentado devido não ser necessária validação para um Bem do tipo Pneu.
/*
	If ::IsValid() .And. ::GetValue('T9_CATBEM') != '1'

		DBSelectArea( 'TTM' )
		DBSetOrder( 1 ) //TTM_CODBEM+TTM_PLACA
		DBSeek( xFilial("TTM") + ::GetValue('T9_CODBEM') )
		If .Not. TTM->( Found() )
			RecLock( 'TTM' , .T. )
			TTM->TTM_FILIAL := xFilial( 'TTM' )
			TTM->TTM_CODBEM := ::GetValue('T9_CODBEM')
		Else
			RecLock('TTM',.F.)
		EndIf

		TTM->TTM_EMPROP := SM0->M0_CODIGO
		TTM->TTM_FILPRO := xFilial( "ST9" )
		TTM->TTM_CATBEM := ::GetValue('T9_CATBEM')
		TTM->TTM_ALUGUE := ::GetValue('T9_ALUGUEL')
        TTM->TTM_PROPRI := ::GetValue('T9_PROPRIE')
		MsUnLock( 'TTM' )
	EndIf
*/

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
/*/{Protheus.doc}Delete
Método para exclusão dos alias definidos para a classe.

@author NG Informática Ltda.
@since 10/10/2014
@version P11
@return lDelete Confirmação da operação.
@sample If oObj:valid()
oObj:upsert()
Else
Help(,,'HELP',, oTPN:getErrorList()[1],1,0)
EndIf
/*/
//------------------------------------------------------------------------------
Method Delete() Class MntPneu

	// Carrega todas os campos da classe em memoria de trabalho
	::ClassToMemory()

	BEGIN TRANSACTION

	//--------------------------------------------------------------------------
	// Exclui relacionamento multi-empresa
	//--------------------------------------------------------------------------
	/*If ::IsValid() .And. NGIFdbSeek( 'TTM' , ::GetValue('T9_CODBEM') ,1 )

		RecLock( 'TTM' , .F. )
		DBDelete()
		MsUnLock( 'TTM' )
	EndIf*/

	//--------------------------------------------------------------------------
	// Exclui veiculo e relacionados
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
/*/{Protheus.doc}IsAplicado
Indica que o pneu esta aplicado na estrutura

@author NG Informática Ltda.
@since 10/10/2014
@version P11

/*/
//------------------------------------------------------------------------------
Method IsAplicado() Class MntPneu
Return AllTrim( GetNewPar("MV_NGSTAPL") ) == AllTrim( ::GetValue('T9_STATUS') )

//------------------------------------------------------------------------------
/*/{Protheus.doc}fSeekPad
Verifica se existe Esquema Padrão (TQ0) para uma determinada familia e Modelo.

@author Eduardo Mussi
@since  01/07/2021

@param cFamilia, Caracter, Familia a ser utilizada na busca pelo esquema padrão
@param cModelo, Caracter, Tipo Modelo a ser utilizado na busca pelo esquema padrão

@return Lógico, Se encontrou esquema padrão (TQ0)
/*/
//------------------------------------------------------------------------------
Static Function fSeekPad( cFamilia, cModelo )

	Local lFound := .F.

	If lRel12133
		lFound := MNTSeekPad( 'TQ0', 1, cFamilia, cModelo )
	Else
		lFound := NGIFDBSEEK( "TQ0" , cFamilia + cModelo , 1 )
	EndIf

Return lFound
