#INCLUDE "MDTA881.ch"
#INCLUDE "PROTHEUS.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA881
Carga Inicial dos registros do evento S-2240 (Riscos)

@return Nil, sempre nulo

@sample MDTA881()

@author	Luis Fellipy Bett
@since	07/08/2017
/*/
//---------------------------------------------------------------------
Function MDTA881()

	//Armazena as variáveis
	Local aNGBEGINPRM := NGBEGINPRM()
	Local aSay		:= {}
	Local aButton	:= {}
	Local nOpc		:= 0
	Local leSocial	:= IIf( FindFunction( "MDTVldEsoc" ), MDTVldEsoc(), .F. )
	Local lFirst	:= SuperGetMv( "MV_NG2BLEV", .F., "2" ) == "1"

	If leSocial
		If lFirst .And. FindFunction( "MDTIntEsoc" )
			aAdd( aSay, STR0001 ) //"Esta rotina realiza a carga inicial dos Riscos, referente ao evento S-2240 do"
			aAdd( aSay, STR0002 ) //"eSocial, a serem integrados com o Governo através do SIGATAF ou Middleware"
			aAdd( aSay, STR0003 ) //"Importante: Deve ser executado uma única vez por empresa"

			aAdd( aButton, { 1, .T., { | | nOpc := 1, FechaBatch() } } )
			aAdd( aButton, { 2, .T., { | | FechaBatch() } } )

			FormBatch( STR0004, aSay, aButton ) //"CARGA INICIAL DO EVENTO S-2240 DO ESOCIAL"

			If nOpc == 1
				Begin Transaction

				If !fRisS2240()
					DisarmTransaction()
					RollBackSX8()
				Else
					Help( ' ', 1, STR0005, , STR0006, 2, 0 ) //"Atenção"##"Carga inicial realizada com sucesso!"
					PUTMV( "MV_NG2BLEV", "2" ) //Seta valor para que não seja possível abrir a rotina mais de 1 vez
				EndIf

				End Transaction
			EndIf
		Else
			Help( ' ', 1, STR0005, , STR0007, 2, 0 ) //"Atenção"##"Essa ação já foi realizada ou o dicionário não está devidamente atualizado, favor verificar!"
		EndIf
	Else
		Help( ' ', 1, STR0005, , STR0008, 2, 0, , , , , , { STR0009 } ) //"Atenção"##"O parâmetro de integração com o eSocial (MV_NG2ESOC) está desabilitado"##"Para realizar a carga inicial habilite o parâmetro"
	EndIf

	// Devolve as variáveis armazenadas
	NGRETURNPRM( aNGBEGINPRM )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fRisS2240
Realiza a validação e envio das informações do evento S-2240 ao Governo

@sample fRisS2240()

@return lRet, Boolean, .T. caso não existam inconsistências no envio

@author Luis Fellipy Bett
@since	17/03/2021
/*/
//---------------------------------------------------------------------
Static Function fRisS2240()

	//Salva a área
	Local aArea := GetArea()

	//Variáveis para busca das informações
	Local aFuncs := {}
	Local lRet := .T.

	//Variáveis private utilizadas no processo
	Private lMiddleware := IIf( cPaisLoc == 'BRA' .And. Findfunction( "fVerMW" ), fVerMW(), .F. )
	Private lGPEA180 := .F. //Define a variável de chamada da rotina de transferências como .F.

	//Pega todos os funcionários ativos
	aFuncs := MDTGetFunc()

	//Valida se os funcionários estão afastados por motivo diferente de férias e licença maternidade
	fVldAfas( @aFuncs )

	//Valida se o evento S-2240 já existe no SIGATAF
	fEveExis( @aFuncs )

	If Len( aFuncs ) > 0
		lRet := MDTIntEsoc( "S-2240", 3, , aFuncs, .T. ) //Envia informações ao Governo
	EndIf

	//Retorna a área
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldAfas
Valida se os funcionários a serem carregados na carga inicial estão afastados
por motivo diferente de férias ou licença maternidade

@return	 Nil, Nulo

@sample	 fVldAfas( { { "100016" } } )

@param	 aFunVld, Array, Array contendo os funcionários a serem validados

@author  Luis Fellipy Bett
@since   03/02/2022
/*/
//-------------------------------------------------------------------
Static Function fVldAfas( aFunVld )

	//Salva a área
	Local aArea := GetArea()
	
	//Variáveis para busca das informações
	Local dDtEsoc := SuperGetMv( "MV_NG2DTES", .F., SToD( "20211013" ) )
	Local dDtAdmi := SToD( "" )
	Local dDtEnv  := SToD( "" )
	Local aArrExc := {}
	Local nPosReg := 0
	Local nCont	  := 0

	//Valida todos os funcionários verificando os afastamentos
	For nCont := 1 To Len( aFunVld )

		//Busca a data de admissão do funcionário
		dDtAdmi := Posicione( "SRA", 1, xFilial( "SRA", aFunVld[ nCont, 2 ] ) + aFunVld[ nCont, 1 ], "RA_ADMISSA" )

		//Verifica se considera o início de obrigatoriedade ou a admissão do funcionário
		If dDtAdmi > dDtEsoc
			dDtEnv := dDtAdmi
		Else
			dDtEnv := dDtEsoc
		EndIf
		
		//Valida todos os afastamentos do funcionário verificando se são diferente de férias ou licença maternidade
		dbSelectArea( "SR8" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "SR8", aFunVld[ nCont, 2 ] ) + aFunVld[ nCont, 1 ] )
			While SR8->( !Eof() ) .And. SR8->R8_FILIAL == xFilial( "SR8", aFunVld[ nCont, 2 ] ) .And. SR8->R8_MAT == aFunVld[ nCont, 1 ]
				
				//Verifica se o funcionário está afastado no momento da carga e se o afastamento é diferente de férias e licença maternidade
				If !( SR8->R8_TIPOAFA $ "001/006/007/008/010/011/012" ) .And. dDtEnv >= SR8->R8_DATAINI .And. ( dDtEnv <= SR8->R8_DATAFIM .Or. Empty( SR8->R8_DATAFIM ) )
					
					//Caso o funcionário não existir no array
					If aScan( aArrExc, { |x| x == aFunVld[ nCont, 1 ] } ) == 0
						aAdd( aArrExc, aFunVld[ nCont, 1 ] )
					EndIf

				EndIf

				SR8->( dbSkip() )
			End
		EndIf
	
	Next nCont

	//Exclui do array de funcionários os que não devem ser enviados
	For nCont := 1 To Len( aArrExc )

		nPosReg := aScan( aFunVld, { |x| x[ 1 ] == aArrExc[ nCont ] } )
		aDel( aFunVld, nPosReg ) //Deleta registro do array
		aSize( aFunVld, Len( aFunVld ) - 1 ) //Diminui a posição excluída do array

	Next nCont

	//Retorna a área
	RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fEveExis
Valida se o evento S-2240 já existe para o funcionário

@return	 Nil, Nulo

@sample	 fEveExis( { { "100016" } } )

@param	 aFunVld, Array, Array contendo os funcionários a serem validados

@author  Luis Fellipy Bett
@since   03/02/2022
/*/
//-------------------------------------------------------------------
Static Function fEveExis( aFunVld )

	//Salva a área
	Local aArea := GetArea()

	//Variáveis para busca das informações
	Local aArrExc := {}
	Local nPosReg := 0
	Local nCont	  := 0

	//Percorre os funcionários verificando quem já possui registro do S-2240 no SIGATAF/Middleware
	For nCont := 1 To Len( aFunVld )

		If MDTVld2240( aFunVld[ nCont, 1 ], aFunVld[ nCont, 2 ] )
			aAdd( aArrExc, aFunVld[ nCont, 1 ] ) //Salva a matrícula do funcionário no array
		EndIf

	Next nCont

	//Exclui do array de funcionários os que não devem ser enviados
	For nCont := 1 To Len( aArrExc )

		nPosReg := aScan( aFunVld, { |x| x[ 1 ] == aArrExc[ nCont ] } )
		aDel( aFunVld, nPosReg ) //Deleta registro do array
		aSize( aFunVld, Len( aFunVld ) - 1 ) //Diminui a posição excluída do array

	Next nCont

	//Retorna a área
	RestArea( aArea )

Return
