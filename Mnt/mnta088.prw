#Include 'Totvs.ch'
#Include 'MNTA088.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA088
Carga Inicial BroBot

@type   Function

@author Eduardo Mussi
@since  22/12/2023
/*/
//-------------------------------------------------------------------
Function MNTA088()

    Local aColumns := {}

    Private oMark088
    Private oTmpTbl
    
    fCreateTRB( @aColumns )
    fLoadData( oTmpTbl:GetAlias() )

    oMark088 := FWMarkBrowse():New()
    oMark088:SetAlias( oTmpTbl:GetAlias() )
    oMark088:SetColumns( aColumns )
    oMark088:SetTemporary( .T. )
    oMark088:SetMenuDef( 'MNTA088' )
    oMark088:SetDescription( STR0001 ) // 'Carga Brobot'
    oMark088:SetFieldMark( 'T9_OK' )
    oMark088:SetMark( 'OK', oTmpTbl:GetAlias(), 'T9_OK')
    oMark088:DisableReport()
    oMark088:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fCreateTRB
Criação do TRB para o MarkBrowse

@author Eduardo Mussi
@since  22/12/2023
@param  aColumns, Array, Array responsável pelos objetos de coluna do MarkBrowse
/*/
//-------------------------------------------------------------------
Static Function fCreateTRB( aColumns )

    Local aFields   := {}
    Local cAliasTmp := GetNextAlias()

    // Campos usados para criação do TRB
    aAdd( aFields, { 'T9_OK'     , 'C', 2, 0 } )
    aAdd( aFields, { 'T9_FILIAL' , 'C', FwTamSx3( 'T9_FILIAL'  )[ 1 ], 0 } )
    aAdd( aFields, { 'T9_PLACA'  , 'C', FwTamSx3( 'T9_PLACA'   )[ 1 ], 0 } )
    aAdd( aFields, { 'T9_RENAVAM', 'C', FwTamSx3( 'T9_RENAVAM' )[ 1 ], 0 } )
    aAdd( aFields, { 'T9_CODBEM' , 'C', FwTamSx3( 'T9_CODBEM'  )[ 1 ], 0 } )
    aAdd( aFields, { 'T9_NOME'   , 'C', FwTamSx3( 'T9_NOME'    )[ 1 ], 0 } )
    aAdd( aFields, { 'T9_CODFAMI', 'C', FwTamSx3( 'T9_CODFAMI' )[ 1 ], 0 } )
    aAdd( aFields, { 'T9_NOMFAMI', 'C', FwTamSx3( 'T9_NOMFAMI' )[ 1 ], 0 } )
    aAdd( aFields, { 'T9_TIPMOD' , 'C', FwTamSx3( 'T9_TIPMOD'  )[ 1 ], 0 } )
    aAdd( aFields, { 'T9_DESMOD' , 'C', FwTamSx3( 'T9_DESMOD'  )[ 1 ], 0 } )
    aAdd( aFields, { 'T9_UFEMPLA', 'C', FwTamSx3( 'T9_UFEMPLA' )[ 1 ], 0 } )

    oTmpTbl := FWTemporaryTable():New( cAliasTmp, aFields )
	oTmpTbl:AddIndex( '01', { 'T9_FILIAL', 'T9_CODBEM' } )
	oTmpTbl:AddIndex( '02', { 'T9_PLACA' } )
    oTmpTbl:AddIndex( '03', { 'T9_OK' } )
	oTmpTbl:Create()

    fArrayCol( cAliasTmp, aFields, @aColumns )
    
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fArrayCol
Gera as Colunas do Browse conforme os campos informados no aFldCon.

@type   Static Function
@author Eduardo Mussi
@since  20/12/2023

@param  cAliasTRB, Caracter, Alias pela tabela temporária.
		aFldCon  , Array   , Campos que serão apresentados no Browse.
        aColumns , Array   , Array contendo os objetos oColumn do Browse

/*/
//---------------------------------------------------------------------
Static Function fArrayCol( cAliasTRB, aFldCon, aColumns )
	
	Local nInd 	:= 0

	// Cria Colunas do Browse
	For nInd := 2 To Len( aFldCon )
		aAdd( aColumns, fCreateCol( "{ | | " + ( cAliasTRB ) + "->" + aFldCon[ nInd, 1 ] + " }", aFldCon[ nInd, 1 ] ) )
	Next nInd

Return 

//---------------------------------------------------------------------
/*/{Protheus.doc} fCreateCol
Criação das Colunas do Browse.

@type   Static Function
@author Eduardo Mussi
@since  20/12/2023

@param  cDadosCol, Caracter, Indica a busca do valor do campo
		cCampoCol, Caracter, Campo a ser criado na coluna do Browse.

@return oColumn, Objeto da Coluna
/*/
//---------------------------------------------------------------------
Static Function fCreateCol( cDadosCol, cCampoCol )

	Local aArea		  := FwGetArea()
	Local cTitleCol   := ''	// Caracter Indica o titulo do campo
	Local cTipeCol	  := ''	// Caracter Indica o tipo do campo
	Local cPictureCol := ''	// Caracter Indica a Picture do campo
	Local oColumn			// Objeto de criação das colunas do Browse
	Local nTamCol	  := 0	// Numerico Indica o tamanho do campo

	// Busca as informações no dicionário
	cTitleCol	:= AllTrim( Posicione( 'SX3', 2, cCampoCol, 'X3Titulo()' ) )
	cTipeCol	:= Posicione( 'SX3', 2, cCampoCol, 'X3_TIPO' )
	nTamCol		:= Posicione( 'SX3', 2, cCampoCol, 'X3_TAMANHO' ) + Posicione( 'SX3', 2, cCampoCol, 'X3_DECIMAL' )
	cPictureCol	:= Posicione( 'SX3', 2, cCampoCol, 'X3_PICTURE' )

	// Adiciona as colunas do Browse
	oColumn := FWBrwColumn():New()    // Cria objeto
	oColumn:SetData( &( cDadosCol ) ) // Define valor
	oColumn:SetEdit( .F. )	      	  // Indica se é editavel
	oColumn:SetTitle( cTitleCol )     // Define titulo
	oColumn:SetType( cTipeCol )       // Define tipo
	oColumn:SetSize( nTamCol )	      // Define tamanho
	oColumn:SetPicture( cPictureCol ) // Define picture

	FwRestArea( aArea )

Return oColumn

//-------------------------------------------------------------------
/*/{Protheus.doc} fLoadData
Carga browse

@author Eduardo Mussi
@since  22/12/2023
@param  cAliasTRB, caracter, Alias TRB do MarkBrowse

/*/
//-------------------------------------------------------------------
Static Function fLoadData( cAliasTRB )

    Local cIsNull    := '%'
    Local cGetDB     := TcGetDb()
    Local cAliasLoad := GetNextAlias()

    If cGetDB == 'ORACLE'
		cIsNull += "NVL( TQR.TQR_DESMOD, '')  AS T9_DESMOD,%"//"COALESCE"
	ElseIf cGetDB == 'POSTGRES'
		cIsNull += "COALESCE( TQR.TQR_DESMOD, '')  AS T9_DESMOD,%"//"COALESCE"
	Else
		cIsNull +="IsNull( TQR.TQR_DESMOD, '')  AS T9_DESMOD,%"
	EndIf

    BeginSQL Alias cAliasLoad
    
        SELECT  ST9.T9_FILIAL,
                ST9.T9_PLACA,
                ST9.T9_RENAVAM,
                ST9.T9_CODBEM,
                ST9.T9_NOME,
                ST9.T9_CODFAMI,
                ST6.T6_NOME AS T9_NOMFAMI,
                ST9.T9_TIPMOD,
                %exp:cIsNull%
                T9_UFEMPLA
        FROM %table:ST9% ST9
        INNER JOIN %table:ST6% ST6
            ON  ST6.T6_FILIAL = %xFilial:ST6% 
            AND ST6.T6_CODFAMI = ST9.T9_CODFAMI 
            AND ST6.%NotDel%
        LEFT JOIN %table:TQR% TQR 
            ON  TQR.TQR_FILIAL = %xFilial:TQR%
            AND TQR.TQR_TIPMOD = ST9.T9_TIPMOD
            AND TQR.%NotDel%
        WHERE   ST9.T9_FILIAL = %xFilial:ST9%
            AND ST9.T9_CATBEM = '4'
            AND ST9.T9_PLACA <> ''
            AND ST9.T9_RENAVAM <> ''
            AND ST9.T9_UFEMPLA <> ''
            AND ST9.%NotDel%
            
    EndSQL

    While (cAliasLoad)->( !EoF() )
        
        dbSelectArea( cAliasTRB )
        RecLock( (cAliasTRB), .T. )
        (cAliasTRB)->T9_FILIAL  := (cAliasLoad)->T9_FILIAL
        (cAliasTRB)->T9_PLACA   := (cAliasLoad)->T9_PLACA
        (cAliasTRB)->T9_RENAVAM := (cAliasLoad)->T9_RENAVAM
        (cAliasTRB)->T9_CODBEM  := (cAliasLoad)->T9_CODBEM
        (cAliasTRB)->T9_NOME    := (cAliasLoad)->T9_NOME
        (cAliasTRB)->T9_CODFAMI := (cAliasLoad)->T9_CODFAMI
        (cAliasTRB)->T9_NOMFAMI := (cAliasLoad)->T9_NOMFAMI
        (cAliasTRB)->T9_TIPMOD  := (cAliasLoad)->T9_TIPMOD
        (cAliasTRB)->T9_DESMOD  := (cAliasLoad)->T9_DESMOD
        (cAliasTRB)->T9_UFEMPLA := (cAliasLoad)->T9_UFEMPLA
        
        (cAliasTRB)->( MsUnLock() )

        (cAliasLoad)->( dbSkip() )

    EndDo
        
    (cAliasLoad)->( dbCloseArea() ) 

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu da Rotina

@author Eduardo Mussi
@since  22/12/2023

@return Array, Retorna opção do menu
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Return { { STR0002, 'FWMsgRun( ,{ || MNTA088IM() }, "' + STR0003 + '", "' + STR0004 + '" )', 0, 3 } } // 'Importar P/ Brobot' ## "Aguarde" ## "Importando Registros"

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA088IM
Realiza importação dos veiculos para o Brobot

@author Eduardo Mussi
@since  22/12/2023
/*/
//-------------------------------------------------------------------
Function MNTA088IM()

    Local cBroBot    := GetNewPar( 'MV_NGBROBO' )
    Local aHeadStr   := { 'token: ' + cBroBot, 'Content-Type: application/json; charset=UTF-8' } 
    Local cAliasTRB  := oTmpTbl:GetAlias()
    Local cGetPost   := ''
    Local cResponse  := ''
    Local cError     := ''
    Local cNotImpMsg := ''
    Local nStatus    := 0
    Local nDataImp   := 0
    Local oParser

    // validar cenário com parametro informado errado
    If !Empty( cBroBot )

        dbSelectArea( cAliasTRB )
        dbSetOrder( 3 )
        dbSeek( 'OK' )

        While (cAliasTRB)->( !EoF() ) .And. (cAliasTRB)->T9_OK == 'OK'

            cGetPost := '{ "plate":"'   + (cAliasTRB)->T9_PLACA   + '",'
            cGetPost += '  "renavam":"' + (cAliasTRB)->T9_RENAVAM + '",'
            cGetPost += '  "uf":"'      + (cAliasTRB)->T9_UFEMPLA + '"}'

            cResponse := HTTPPost( 'https://api.platform.brobot.com.br/api/v2/vehicles', /*cGetParms*/, cGetPost, /*nTimeOut*/, aHeadStr )
            
            // Verificar e tratar o retorno para quando existir erros de processos.
            nStatus    := HTTPGetStatus( cError )

            If nStatus == 201

                nDataImp++

            ElseIf nStatus == 403
                                
                cNotImpMsg += STR0005 + CRLF// 'Token informado no parâmetro MV_NGBROBO está incorreto!'
                cNotImpMsg += STR0006 + CRLF// 'Mensagem BroBot: '
                
                If FWJsonDeserialize( cResponse, @oParser ) .And. AttIsMemberOf( oParser, 'Data' ) .And. AttIsMemberOf( oParser:Data, 'Errors' )
                    cNotImpMsg += '   - ' + DecodeUTF8( oParser:Data:Errors[ 1 ] )
                EndIf
                
                Exit

            Else

                If Empty( cNotImpMsg )
                    cNotImpMsg := STR0007  + CRLF // 'Inconsistências:'
                EndIf

                // Salva mensagem de retorno da API para ser apresentada no relatório caso cliente queira ver
                cNotImpMsg += STR0008 + (cAliasTRB)->T9_PLACA + STR0009 + AllTrim( (cAliasTRB)->T9_RENAVAM ) + STR0010 // 'Placa: ' ## ' / Renavam: '  ## ' / Mensagem: '

                If FWJsonDeserialize( cResponse, @oParser ) .And. AttIsMemberOf( oParser, 'Errors' )
                    cNotImpMsg += DecodeUTF8( oParser:Errors[ 1 ] ) + CRLF
                EndIf

            EndIf    

            (cAliasTRB)->( dbSkip() )

        EndDo

        If nDataImp > 0 .And. Empty( cNotImpMsg )
            Help( '', 1, STR0011, , STR0012 + cValToChar( nDataImp ) + STR0013, 2, 0 ) // 'Importação' ## 'Todos os veículos selecionados(' ## ') foram importados com sucesso!'
        ElseIf !Empty( cNotImpMsg ) .And. MsgYesNo( STR0014, STR0015 ) // 'Um ou mais veiculos não foram importados, deseja verificar?' ## 'Atenção!'
            NGMSGMEMO( STR0016, cNotImpMsg ) //'Veículos não importados'
        EndIf

        dbSelectArea( cAliasTRB )
        dbSetOrder( 1 )
        dbGoTop()
        
    Else
        Help( '', 1, STR0015, , STR0017, 2, 0 ) //'Atenção' ## 'O ambiente não foi configurado corretamente, favor verificar o parâmetro MV_NGBROBO'
    EndIf
    
    oMark088:GoTop()
    oMark088:Refresh(.T.)
    oMark088:GoTop()

Return 
