#include 'PROTHEUS.ch'
#Include 'FWMVCDef.ch'
#Include 'MNTA087.ch'

Static aField1    := {}
Static aField2    := {}
Static aSimilar87 := { {}, {}, {}, {} }

#Define _POSICST9_ 1
#Define _POSICTQS_ 2
#Define _POSICSTB_ 3
#Define _POSICTPE_ 4

//---------------------------------------------------------------------------------
/*/{Protheus.doc} MNTA087
Gera pneus a partir de uma veículo

@author Maria Elisandra de Paula
@since 29/09/20
/*/
//---------------------------------------------------------------------------------

//---------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Regras de Modelagem da gravacao

@author Maria Elisandra de Paula
@since 29/09/20

@return object, modelo de dados
/*/
//---------------------------------------------------------------------------------
Static Function ModelDef()

	Local oModel    := MPFormModel():New('MNTA087', /*bPre*/, {|oModel| ValidPos( oModel )  }, {|oModel| Commit087( oModel )  } )
	Local oStruct1  := FWFormModelStruct():New()
	Local oStruct2  := FWFormModelStruct():New()
	Local nIndex    := 0

    //------------------------------
	// Carrega variáveis iniciais
	//------------------------------
	LoadStart()

	For nIndex := 1 to Len( aField1 )

		oStruct1:AddField( aField1[nIndex,1],;
					aField1[nIndex,2], ;
					aField1[nIndex,2], ;
					aField1[nIndex,3], ;
					aField1[nIndex,4], ;
					aField1[nIndex,5])
	Next nIndex

	oStruct1:SetProperty( 'PNESIMILAR', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, 'MNTA087VLD("PNESIMILAR")' ) )
	oStruct1:AddTrigger('PNESIMILAR', 'NOMEPNEU', {|| .T. }, { || Trigger()  })

	oStruct2:AddField( '', '', 'OK',     'L', 2,  0, FWBuildFeature( STRUCT_FEATURE_VALID, 'MNTA087VLD("OK")' ),;
		Nil, {}, .F., {|| '' }, .F., .F., .F.)
	oStruct2:AddField( '', '', 'LEGEND', 'C', 50, 0, Nil, {||.F. }, {}, Nil, {|| }, .F., .T., .F. )

	For nIndex := 1 to Len( aField2 )

		oStruct2:AddField( aField2[nIndex,1],;
					aField2[nIndex,2], ;
					aField2[nIndex,2], ;
					aField2[nIndex,3], ;
					aField2[nIndex,4], ;
					aField2[nIndex,5], ;
					Nil,;
					Nil,;
					{},;
					.F.,;
					{|| '' },;
					.F.,.F.,.F.)

	Next nIndex

	oModel:SetVldActivate( { || ValidPre() }  )

	oModel:SetDescription( STR0001 ) // 'Inclusão de Estrutura'
    oModel:AddFields('MASTER',,oStruct1,,, {|| LoadMaster() } )
	oModel:AddGrid( 'DETAIL','MASTER', oStruct2,,,,, {|| LoadDetail() } )
	oModel:SetPrimaryKey({'T9_CODBEM'})
    oModel:GetModel('MASTER'):SetDescription( 'MODEL' )
	oModel:GetModel('DETAIL'):SetDescription( 'GRID' )

Return oModel

//---------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Regras da interface

@author Maria Elisandra de Paula
@since 29/09/20

@return object, view
/*/
//---------------------------------------------------------------------------------
Static Function ViewDef()

    Local oModel   := FWLoadModel('MNTA087')
    Local oStruct1 := FWFormViewStruct():New()
	Local oStruct2 := FWFormViewStruct():New()
    Local oView    := FWFormView():New()
	Local nIndex   := 0

	oStruct1:AddGroup( '1', STR0002 ,'', 2) // 'Veículo'
	oStruct1:AddGroup( '2', STR0003 ,'',2) //'Pneu Similar'

	For nIndex := 1 to Len( aField1 )
		oStruct1:AddField( aField1[nIndex,2],;
						cValtochar( nIndex ),;
						aField1[nIndex,1],;
						aField1[nIndex,1],;
						{ aField1[nIndex,7] },;
						aField1[nIndex,3],;
						aField1[nIndex,6],;
						Nil, Nil,.F.,,'1')
	Next nIndex

	oStruct1:SetProperty( 'PNESIMILAR', MVC_VIEW_LOOKUP, 'PNEUSI' ) // F3
	oStruct1:SetProperty( 'PNESIMILAR', MVC_VIEW_CANCHANGE, .T. ) // Alterável
	oStruct1:SetProperty( 'PNESIMILAR', MVC_VIEW_GROUP_NUMBER, '2' )
	oStruct1:SetProperty( 'NOMEPNEU', MVC_VIEW_GROUP_NUMBER, '2' )

 	oStruct2:AddField( 'OK',    '01', 'OK', 'OK',{''},       'L',,       Nil, Nil,.T. )
	oStruct2:AddField( 'LEGEND','02', '',   '',  {''},'C','@BMP', Nil, Nil,.T. )

	For nIndex := 1 to Len( aField2 )

		oStruct2:AddField( aField2[nIndex,2],;
				cValtochar( nIndex + 2 ),;
				aField2[nIndex,1],;
				aField2[nIndex,1],;
				{ aField2[nIndex,7] },;
				aField2[nIndex,3],;
				aField2[nIndex,6],;
				Nil, Nil,.F.,,'1')

	Next nIndex

	oStruct2:RemoveField('TQ1_EIXO')
	oStruct2:RemoveField('TQ1_TIPEIX')

    oView:SetCloseOnOk({|| .T. })//Força o fechamento da janela na confirmação
	oView:SetModel(oModel)
	oView:CreateHorizontalBox('SUPERIOR',50)
    oView:CreateHorizontalBox('INFERIOR',50)
	oView:AddField('VIEW_MASTER', oStruct1, 'MASTER')
	oView:AddGrid('VIEW_DETAIL', oStruct2, 'DETAIL')
    oView:SetOwnerView('VIEW_MASTER','SUPERIOR')
	oView:SetOwnerView('VIEW_DETAIL','INFERIOR')

	oView:AddUserButton( STR0025, "MAGIC_BMP", {|oView| MNTA087PN( oView ) }, STR0025,,,.T.) //"Pneu Modelo"

Return oView

//---------------------------------------------------------------------------------
/*/{Protheus.doc} LoadStart
Carrega variáveis iniciais

@author Maria Elisandra de Paula
@since 01/10/20

@return Nil
/*/
//---------------------------------------------------------------------------------
Static Function LoadStart()

	aField1 := {}
	aField2 := {}

	//-----------------------------------------------------------
	// campos para tela superior
	//-----------------------------------------------------------
	aAdd( aField1, { NGRETTITULO('T9_CODBEM'),	'T9_CODBEM', 'C', TAMSX3('T9_CODBEM')[1], 0, '@!','', 'ST9->T9_CODBEM' })
	aAdd( aField1, { NGRETTITULO('T9_NOME'),	'T9_NOME',   'C', TAMSX3('T9_NOME')[1],   0, '@!', '', 'ST9->T9_NOME' })
	aAdd( aField1, { NGRETTITULO('T6_CODFAMI'),	'T6_CODFAMI','C', TAMSX3('T6_CODFAMI')[1],0, '@!', '', 'ST6->T6_CODFAMI' })
	aAdd( aField1, { NGRETTITULO('T6_NOME'),	'T6_NOME',   'C', TAMSX3('T6_NOME')[1],   0, '@!', '', 'ST6->T6_NOME' })
	aAdd( aField1, { NGRETTITULO('TQR_TIPMOD'),	'TQR_TIPMOD','C', TAMSX3('TQR_TIPMOD')[1],0, '@!', '', 'TQR->TQR_TIPMOD' })
	aAdd( aField1, { NGRETTITULO('TQR_DESMOD'),	'TQR_DESMOD','C', TAMSX3('TQR_DESMOD')[1],0, '@!', '', 'TQR->TQR_DESMOD' })
    aAdd( aField1, { NGRETTITULO('T9_PLACA'),	'T9_PLACA',  'C', TAMSX3('T9_PLACA')[1],  0, '@!', '', 'ST9->T9_PLACA' })
	aAdd( aField1, { "Pneu Similar",            'PNESIMILAR',	 'C', TAMSX3('T9_CODBEM')[1], 0, '@!', STR0004, '' }) //'Código do bem que será utilizado como referência para gerar pneus.'
	aAdd( aField1, { "Nome Pneu",               'NOMEPNEU',  'C', TAMSX3('T9_NOME')[1],   0, '@!', STR0005,'' }) // "Nome do bem que será utilizado como referência para gerar pneus."

	//-----------------------------------------------------------
	// campos para tela inferior
	//-----------------------------------------------------------
	aAdd( aField2,{ NGRETTITULO('T6_CODFAMI'), "T6_CODFAMI", "C", TAMSX3( "T6_CODFAMI" )[1], 0, '@!','' })
	aAdd( aField2,{ NGRETTITULO('T6_NOME') ,   "T6_NOME",    "C", TAMSX3( "T6_NOME" )[1],    0, '@!','' })
	aAdd( aField2,{ NGRETTITULO('TPS_CODLOC'), "TPS_CODLOC", "C", TAMSX3( "TPS_CODLOC" )[1], 0, '@!','' })
	aAdd( aField2,{ NGRETTITULO('TPS_NOME'),   "TPS_NOME",   "C", TAMSX3( "TPS_NOME" )[1],   0, '@!','' })
	aAdd( aField2,{ NGRETTITULO('TC_COMPONE'), "TC_COMPONE", "C", TAMSX3( "TC_COMPONE" )[1], 0, '@!','' })
    aAdd( aField2,{ NGRETTITULO('TQ1_EIXO'),   "TQ1_EIXO",   "C", TAMSX3( "TQ1_EIXO" )[1], 0, '@!','' })
	aAdd( aField2,{ NGRETTITULO('TQ1_TIPEIX'), "TQ1_TIPEIX", "C", TAMSX3( "TQ1_TIPEIX" )[1], 0, '@!','' })

Return

//---------------------------------------------------------------------------------
/*/{Protheus.doc} LoadMaster
Carrega informações da master

@author Maria Elisandra de Paula
@since 29/09/20

@return array, dados para carregar os campos
/*/
//---------------------------------------------------------------------------------
Static Function LoadMaster()

	Local aLoad  := {}
	Local aAux   := {}
	Local nIndex := 0

	dbSelectArea('ST6')
	dbSetOrder(1)
	dbSeek( xFilial('ST6') + ST9->T9_CODFAMI )

	dbSelectArea('TQR')
	dbSetOrder(1)
	dbSeek( xFilial('TQR') + ST9->T9_TIPMOD )

	For nIndex := 1 to Len( aField1 )
		aAdd( aAux, &(aField1[nIndex,8]) )
	Next nIndex

   aAdd( aLoad, aAux )
   aAdd( aLoad, 1 ) //recno

Return aLoad

//---------------------------------------------------------------------------------
/*/{Protheus.doc} LoadDetail
Carrega informações da detail

@author Maria Elisandra de Paula
@since 29/09/20

@return array, dados para carregar os campos da grid
/*/
//---------------------------------------------------------------------------------
Static Function LoadDetail()

	Local aLoad    := {}
	Local aPN      := { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }
	Local nIndex   := 0
	Local cFamily  := ''
	Local cLocaliz := ''
	Local cCompon  := ''

	//---------------------------------------------
	// Esquema padrão do veículo
	//---------------------------------------------
	dbSelectArea("TQ1")
	dbSetOrder(01)
	If dbSeek( xFilial("TQ1") + ST9->T9_CODFAMI + ST9->T9_TIPMOD )
		While !EoF() .And. TQ1->TQ1_FILIAL == xFilial("TQ1") .And. ST9->T9_CODFAMI + ST9->T9_TIPMOD == TQ1->TQ1_DESENH + TQ1->TQ1_TIPMOD
			For nIndex := 1 To TQ1->TQ1_QTDPNE

				cFamily  := &("TQ1->TQ1_FAMIL" + aPn[nIndex])
				cLocaliz := &("TQ1->TQ1_LOCPN" + aPn[nIndex])
				cCompon  := Componente( cLocaliz )

				aAdd(aLoad,{ 0,{ .F.,; // todos desmarcados
								IIF( !Empty(cCompon), "BR_VERMELHO","BR_VERDE"),;
								cFamily,;
								NGSEEK('ST6', cFamily, 1, 'T6_NOME' ),;
								cLocaliz,;
								NGSEEK('TPS', cLocaliz, 1, 'TPS_NOME' ),;
								cCompon, IIf( Alltrim(TQ1->TQ1_EIXO) == 'RESERVA', 'R', TQ1->TQ1_EIXO ) , TQ1->TQ1_TIPEIX}})
			Next nIndex
			TQ1->( dbSkip() )
		EndDo
	EndIf

Return aLoad

//---------------------------------------------------------------------------------
/*/{Protheus.doc} Componente
Retorna código do componente aplicado no veículo referente a localização

@param cLocaliz, string, código da localização
@author Maria Elisandra de Paula
@since 29/09/20

@return string, código do componente
/*/
//---------------------------------------------------------------------------------
Static Function Componente( cLocaliz )

	Local cRet := ''
	Local cAliasQry := GetNextAlias()

	BeginSql Alias cAliasQry

		SELECT TC_COMPONE
		FROM %table:STC% STC
		WHERE STC.%Notdel%
			AND STC.TC_CODBEM = %exp:ST9->T9_CODBEM%
			AND STC.TC_FILIAL = %xFilial:STC%
			AND STC.TC_LOCALIZ = %exp:cLocaliz%

	EndSql

	If !(cAliasQry)->( Eof() )
		cRet := (cAliasQry)->TC_COMPONE
	EndIf

	(cAliasQry)->( dbCloseArea() )

    If Empty( cRet )

		BeginSql Alias cAliasQry

			SELECT TQS_CODBEM
			FROM %table:TQS% TQS
			WHERE TQS.%Notdel%
				AND TQS.TQS_PLACA = %exp:ST9->T9_PLACA%
				AND TQS.TQS_FILIAL = %xFilial:TQS%
				AND TQS.TQS_POSIC = %exp:cLocaliz%

		EndSql

		If !(cAliasQry)->( Eof() )
			cRet := (cAliasQry)->TQS_CODBEM
		EndIf

		(cAliasQry)->( dbCloseArea() )

	EndIf

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA087PN
Tela para informar detalhes do pneu sample

@param oViewPai, object, tela principal
@author Maria Elisandra de Paula
@since 30/09/2020
@return boolean
/*/
//---------------------------------------------------------------------
Static Function MNTA087PN( oViewPai ) // não alterar o nome desta função pois há verificações de sua chamada em outros fontes

	Local aSaveLine := FWSaveRows()
	Local oModelPai := oViewPai:GetModel()
	Local cSimilar  := oModelPai:GetValue('MASTER', 'PNESIMILAR')
	Local cFamily  := FamilyMark( oModelPai )
	Local cError   := ''
	Local aValues  := {}

	//---------------------------------------------
	// Pelo menos uma posição deve estar marcada
	//---------------------------------------------
	If Empty( cFamily )
		cError := STR0021 // 'Nenhuma posição está marcada.'
	EndIf

	If Empty( cError )

		aAdd( aValues, { 'T9_STATUS',  Alltrim( SuperGetMv( 'MV_NGSTAFG', .F., '' ) ) } )
		aAdd( aValues, { 'T9_DTGARAN',  CTOD("  /  /    ") })
		aAdd( aValues, { 'T9_DTCOMPR',  CTOD("") } )
		aAdd( aValues, { 'T9_ESTRUTU', 'N'  } )
		aAdd( aValues, { 'T9_SERIE',   '' } )
		aAdd( aValues, { 'T9_FORNECE', '' } )
		aAdd( aValues, { 'T9_VALCPA',  0 } )
		aAdd( aValues, { 'T9_NFCOMPR', '' } )
		aAdd( aValues, { 'T9_SITMAN',  'A' } )
		aAdd( aValues, { 'T9_PARTEDI', '2' } )
		aAdd( aValues, { 'T9_CODFAMI',  cFamily } )

		//-----------------------------------------------------------
		// Apresenta tela de pneu
		//-----------------------------------------------------------
		cError := MNTA085SI( oViewPai, oModelPai, cSimilar, aValues, @aSimilar87, cFamily )[1]

	EndIf

	If !Empty( cError )

		Help(' ',1, STR0006  ,, cError ,2,0) // Não Conformidade

	EndIf

	FWRestRows( aSaveLine )

Return Empty( cError )

//---------------------------------------------------------------------
/*/{Protheus.doc} HasBackup
Verifica se já tem backup de informações

@aAux, array, infos de similar
@author Maria Elisandra de Paula
@since 20/10/2020
@return boolean
/*/
//---------------------------------------------------------------------
Static Function HasBackup( aAux )

	Local lEmpty := Empty( aAux[_POSICST9_] ) .And. Empty( aAux[_POSICTQS_] ) .And. ;
					Empty( aAux[_POSICSTB_] ) .And. Empty( aAux[_POSICTPE_] )

Return !lEmpty

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT087TIRE
Validação do pneu sample

@author Maria Elisandra de Paula
@since 01/10/2020
@return boolean
/*/
//---------------------------------------------------------------------
Function MNT087TIRE( cFamily )

	Local oModelPneu := FWModelActive()
	Local cId        := oModelPneu:cId + '_ST9'
    Local cStFire    := Alltrim( SuperGetMv( 'MV_NGSTAFG', .F., '' ) )
	Local cMsg       := ''

    // O campo status deve ser preenchido
    If Empty( oModelPneu:GetValue( cId, 'T9_STATUS') )

		cMsg := STR0010 // "O campo Status deve ser informado."

    	// Caso o status do pneu seja diferente de 'Aguardando Marcação de Fogo' (MV_NGSTAFG)
    	// o cadastro deve passar por todas as validações para salvar o modelo
	ElseIf IsInCallStack('MNTA087PN') .And. ; // Gera Pneus a partir de um veículo
		Alltrim( oModelPneu:GetValue( cId, 'T9_CODFAMI') ) != Alltrim( cFamily )

		cMsg := STR0011 // 'O campo família deve ser o mesmo da estrutura marcada.'

	ElseIf Alltrim( oModelPneu:GetValue( cId, 'T9_STATUS') ) != cStFire .And. !oModelPneu:VldData()

        cMsg := Alltrim( oModelPneu:GetErrorMessage()[6] )

	EndIf

	If !Empty( cMsg )

		Help(' ',1, STR0006  ,, cMsg  ,2,0)

	EndIf

Return Empty( cMsg )

//----------------------------------------------------------------------
/*/{Protheus.doc} ValidPre
Validações iniciais para acessar a rotina

@author Maria Elisandra de Paula
@since 01/10/2020
@return boolean
/*/
//---------------------------------------------------------------------
Static Function ValidPre()

	Local aInfos := {}
	Local nIndex := 0
	Local lRet   := .T.
    Local cStFire := Alltrim( SuperGetMv( 'MV_NGSTAFG', .F., '' ) )

	aSimilar87 := { {}, {}, {}, {} }

	dbSelectArea( 'TQZ' )
	If Select( 'ST9' ) == 0 .Or. !FindFunction( 'MNTA085SI' ) .Or. TQZ->( FieldPos( 'TQZ_NUMSEQ' ) ) == 0 // Verifica se pacote com a funcionaldiade está aplicado
		lRet := .F.
		Help( Nil, Nil, STR0020, Nil, STR0023, 1, 0) // "Opção indisponível neste release, será liberada apenas no release 12.1.2310"
	EndIf

	If lRet
	
		If Empty( cStFire )

			Help(' ',1, STR0006  ,, STR0012  ,2,0) // "Para utilizar esta rotina é necessário configurar o parâmetro 'MV_NGSTAFG'"
			lRet := .F.

		Else

			dbSelectArea( "TQY" )
			dbSetOrder(1)
			If !dbSeek( xFilial("TQY") + Trim(cStFire) )
				Help(' ',1, STR0006  ,, STR0013 + "'" +  cStFire + "'"  + STR0014 ,2,0) // "O status" "configurado no parâmetro 'MV_NGSTAFG' não foi encontrado na tabela de Status (TQY)."
				lRet := .F.
			EndIf

		EndIf

		//---------------------------------------------
		// Esquema padrão do veículo
		//---------------------------------------------
		dbSelectArea("TQ1")
		dbSetOrder(01)
		If lRet .And. !dbSeek( xFilial("TQ1") + ST9->T9_CODFAMI + ST9->T9_TIPMOD )
			Help( ,, STR0006, , STR0015 , 1, 0 ) //"Este veículo não possui um esquema padrão cadastrado."
			lRet := .F.
		EndIf

		If lRet .And. Empty( ST9->T9_PLACA )
			Help(' ',1, STR0006,, STR0024, 2, 0 ) // 'Para utilizar esta operação o campo placa do veículo deve estar preenchido.' 
			lRet := .F.
		EndIf

		If lRet

			lRet := .F.
			aInfos := LoadDetail()
			For nIndex := 1 To Len( aInfos )
				If Empty( aInfos[nIndex,2,7] )
					lRet := .T.
					Exit
				EndIf
			Next nIndex

			If !lRet
				Help( ,, STR0006, , STR0016 , 1, 0 ) //"Todas as posições deste veículo já possuem pneus cadastrados."
			EndIf

		EndIf

	EndIf

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} Commit087
Operações após confirmar última tela - gera pneus

@oModel, object, modelo de dados
@author Maria Elisandra de Paula
@since 01/10/20
@return .T.
/*/
//---------------------------------------------------------------------
Static Function Commit087( oModel )

	Local oGrid      := oModel:GetModel('DETAIL')
	Local cPlaca     := oModel:GetValue('MASTER', 'T9_PLACA')
	Local cSimilar   := oModel:GetValue('MASTER', 'PNESIMILAR')
	Local aAgerar    := {}
	Local aTires     := {}
	Local lValid     := .F.
	Local nIndex     := 0
	Local cStFire    := Alltrim( SuperGetMv( 'MV_NGSTAFG', .F., '' ) )
	Local cXCodBem   := ''
	Local oModelPneu

	//------------------------------------------------------
	// verifica quantidade de pneus que serão gerados
	//------------------------------------------------------
	For nIndex := 1 To oGrid:Length()
		oGrid:GoLine( nIndex )
		If oGrid:GetValue('OK')
			aAdd( aAgerar, { oGrid:GetValue('T6_CODFAMI'),;
							oGrid:GetValue('TPS_CODLOC'),;
							oGrid:GetValue('TQ1_EIXO'),;
							oGrid:GetValue('TQ1_TIPEIX')  })
		EndIf
	Next nIndex

	If !Empty( cSimilar )
		dbSelectArea('ST9')
		dbSetOrder(1)
		dbSeek( xFilial('ST9') + cSimilar )
	EndIf

	//-----------------------------------------------------
	// Cria MODELO de pneu
	//-----------------------------------------------------
	oModelPneu := FWLoadModel( 'MNTA083' )
	oModelPneu:SetOperation( 3 )
	oModelPneu:Activate( !Empty( cSimilar ) )
	oModelPneu := MNT085BKP( oModelPneu, 2, aSimilar87 )[2] // recupera informações do pneu modelo

	cXCodBem := oModelPneu:GetValue( oModelPneu:cId + '_ST9', 'T9_CODBEM')

	For nIndex := 1 To Len( aAgerar )

		Begin Transaction

			lValid := oModelPneu:SetValue( oModelPneu:cId + '_ST9', 'T9_CODBEM', cXCodBem ) .And. ;
					oModelPneu:SetValue( oModelPneu:cId + '_TQS', 'TQS_PLACA', cPlaca ) .And. ;
					oModelPneu:SetValue( oModelPneu:cId + '_TQS', 'TQS_POSIC', Alltrim( aAgerar[nIndex, 2] ) ) .And. ;
					oModelPneu:SetValue( oModelPneu:cId + '_TQS', 'TQS_EIXO', Alltrim( aAgerar[nIndex, 3] ) ) .And. ;
					oModelPneu:SetValue( oModelPneu:cId + '_TQS', 'TQS_TIPEIX', Alltrim( aAgerar[nIndex, 4] ) ) .And.;
					oModelPneu:VldData() .And. oModelPneu:CommitData()

			If lValid

				aAdd( aTires, { cXCodBem, Alltrim( oModelPneu:GetValue( oModelPneu:cId + '_ST9', 'T9_STATUS') ) })

			Else

				//------------------------------------------
				// Grava tabelas manualmente
				//------------------------------------------
				MNTA085REC( oModelPneu, cXCodBem, cStFire, ;
							{ cPlaca,;
							Alltrim( aAgerar[nIndex, 2] ),;
							Alltrim( aAgerar[nIndex, 3] ), ;
							Alltrim( aAgerar[nIndex, 4] ) })

				aAdd( aTires, { cXCodBem, cStFire })

			EndIf

		End Transaction

		cXCodBem := MNTA85NEXT( cXCodBem ) // busca próximo código do bem

	Next nIndex

	//----------------------------------------
	// Apresenta tela de pneus gerados
	//----------------------------------------
	MNT085SHOW( aTires )

Return .T.

//---------------------------------------------------------------------------------
/*/{Protheus.doc} MNTA087VLD
Validação campo

@param cField, string, campo a ser validado
@author Maria Elisandra de Paula
@since 06/10/20
@return boolean, se informações são válidas
/*/
//---------------------------------------------------------------------------------
Function MNTA087VLD( cField )

	Local aSaveLine := FWSaveRows()
	Local aAreaSt9  := ST9->( GetArea() )
	Local lRet      := .T.
	Local oModel    := FwModelActive()
	Local oMaster   := oModel:GetModel('MASTER')
	Local oGrid     := oModel:GetModel('DETAIL')
	Local cSimilar  := oMaster:GetValue('PNESIMILAR')
	Local nIndex    := 0
	Local nCurrent  := 0
	Local cFamily   := ''

	If cField == 'PNESIMILAR'

		If !Empty( cSimilar )

			lRet := ExistCpo('ST9', cSimilar )

			dbSelectArea("ST9")
			dbSetOrder(01)
			If lRet .And. dbSeek(xFilial("ST9") + cSimilar ) .And. ST9->T9_CATBEM != '3'
				Help( ,, STR0006, , STR0017  , 1, 0 ) //"O Bem digitado não é um Pneu!"
				lRet := .F.
				oMaster:SetValue('NOMEPNEU', '' )
			EndIf

			If lRet
				For nIndex := 1 To oGrid:Length()
					oGrid:GoLine( nIndex )
					If oGrid:GetValue('OK') .And. oGrid:GetValue('T6_CODFAMI') != ST9->T9_CODFAMI
						Help( ,, STR0006, , STR0018 , 1, 0 ) // "A família deste pneu é diferente da família marcada na grid."
						lRet := .F.
						Exit
					EndIf
				Next nIndex
			EndIf

		EndIf

	ElseIf cField == 'OK'

		If oGrid:GetValue('OK') // está marcando o item selecionado
			If lRet .And. !Empty( cSimilar )

				dbSelectArea('ST9')
				dbSetOrder(1)
				If dbSeek( xFilial('ST9') + cSimilar ) .And. ST9->T9_CODFAMI != oGrid:GetValue('T6_CODFAMI')
					Help(' ',1, STR0006  ,, STR0007 ,2,0) // "NÃO CONFORMIDADE" #'A família desta posição é diferente da família do pneu similar informado'
					lRet := .F.
				EndIf

			EndIf

			If lRet .And. !Empty( oGrid:GetValue('TC_COMPONE') )
				Help(' ',1, STR0006  ,, STR0008 ,2,0) // "NÃO CONFORMIDADE" 'Já existe um componente nesta posição.'
				lRet := .F.
			EndIf

			If lRet
				nCurrent := oGrid:GetLine()
				cFamily  := oGrid:GetValue('T6_CODFAMI')
				For nIndex := 1 To oGrid:Length()
					If nCurrent != nIndex
						oGrid:GoLine( nIndex )
						If oGrid:GetValue('OK') .And. oGrid:GetValue('T6_CODFAMI') != cFamily
							Help(' ',1, STR0006  ,, STR0009 ,2,0) // 'Esta posição possui uma família diferente de outros itens já selecionados.'
							lRet := .F.
						EndIf
					EndIf
				Next
			EndIf

		EndIf

	EndIf

	RestArea( aAreaSt9 )
	FWRestRows( aSaveLine )

Return lRet

//---------------------------------------------------------------------------------
/*/{Protheus.doc} ValidPos
Validação pneu similar

@author Maria Elisandra de Paula
@since 06/10/20
@return boolean, se deve prosseguir com a operação
/*/
//---------------------------------------------------------------------------------
Static Function ValidPos( oModel )

	Local cError  := ''
	Local cFamily := FamilyMark( oModel )

	If Empty( cFamily )

		cError := STR0021 // 'Nenhuma posição está marcada.'

	ElseIf !HasBackup( aSimilar87 )

		cError := STR0022 // 'O Pneu Modelo ainda não foi definido !'

	EndIf

	If !Empty( cError )

		Help(' ',1, STR0006  ,, cError ,2,0) // Não Conformidade

	EndIf

Return Empty( cError )

//---------------------------------------------------------------------------------
/*/{Protheus.doc} FamilyMark
Retorna o código da família marcada no markbrowse

@author Maria Elisandra de Paula
@since 20/10/20
@return boolean, se deve proceguir com a operação
/*/
//---------------------------------------------------------------------------------
Static Function FamilyMark( oModel )

	Local aSaveLine := FWSaveRows()
	Local cRet   := ''
	Local nIndex := 0
	Local oGrid  := oModel:GetModel('DETAIL')

	For nIndex := 1 To oGrid:Length()
		oGrid:GoLine( nIndex )
		If oGrid:GetValue('OK')
			cRet := oGrid:GetValue('T6_CODFAMI')
			Exit
		EndIf
	Next nIndex

	FWRestRows( aSaveLine )

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} Trigger
Gatilho de campo

@author Maria Elisandra de Paula
@since 21/10/2020
@return boolean
/*/
//---------------------------------------------------------------------
Static Function Trigger()

	Local oModel := FwModelActive()
	Local cRet   := NGSEEK( 'ST9', oModel:GetValue( 'MASTER', 'PNESIMILAR'), 1, 'T9_NOME' )

	aSimilar87   := { {}, {}, {}, {} }

Return cRet
