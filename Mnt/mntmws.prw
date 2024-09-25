#Include 'Totvs.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTMWS
Schedule responsável pela integração com a Brobot.
Pega multas recebidas pela brobot e insere no protheus.

@type   Function

@author Eduardo Mussi
@since  01/02/2024

/*/
//-------------------------------------------------------------------
Function MNTMWS()

    Local aBroBotFi  := StrTokArr( SuperGetMV( 'MV_NGBROFI', .F., '' ), ';' )
    Local cBroBot    := SuperGetMV( 'MV_NGBROBO', .F., '')
    Local aHeadStr   := { 'token: ' + cBroBot, 'Content-Type: application/json; charset=UTF-8' }
    Local nTickets   := 0
    Local cBranchTRX := FwxFilial( 'TRX' )
    Local cURL       := 'https://api.platform.brobot.com.br/cm-frotas/multas?per_page=999' // Requisição Brobot + definição da quantidade maxima de multas na requisição(999)
    Local cError     := ''
    Local cHour      := ''
    Local lNgIntFi   := SuperGetMV( 'MV_NGMNTFI', .F., 'N' ) == 'S'
    Local nSizePl    := FwTamSx3( 'TRX_PLACA' )[ 1 ]
    Local nSizeDt    := FwTamSx3( 'TRX_DTINFR' )[ 1 ]
    Local nSizeHr    := FwTamSx3( 'TRX_RHINFR' )[ 1 ]
    Local nStatus    := 0
    Local oParser

    // Utilizado na rotina MNTA765
    Private nOpcao   := 3

    If !FWSIXUtil():ExistIndex( 'TRX', '9' )
        
        fSaveLog( 'Tabela TRX não possui o indice necessário para o correto funcionamento deste Schedule.' )

    ElseIf lNgIntFi .And. Len( aBroBotFi ) < 4
        
        fSaveLog( 'O parâmetro MV_NGBROFI não foi configurado corretamente!' )

    ElseIf Empty( cBroBot )
        
        fSaveLog( 'O parâmetro MV_NGBROBO está vazio!' )

    Else
    
        MNTA765VAR()
        SetInclui()
        // Caso cliente insira os campos De/Até 
        If !Empty( MV_PAR01 ) .And. !Empty( MV_PAR02 )
            cURL += '&q[period_type]=expired_at&q[start_date]='
            cURL += FWTimeStamp( 6, MV_PAR01, '00:00:00' )
            cURL += '&q[end_date]='
            cURL += FWTimeStamp( 6, MV_PAR02, '23:59:59' )
        EndIf
        
        // Caso o parametro MV_PAR03 seja definido como 2 pelo usuário, 
        // define que será criado um órgão autuador genérico
        If MV_PAR03 == 2
            // O código 000000 foi definido devido ao campo ser de auto incremento, começando sempre em 000001, 
            // assim criando o código de 000000 não trará nenhuma diferença em um ambiente com dados já existentes em base
            dbSelectArea( 'TRZ' )
            dbSetOrder( 1 )
            If !MsSeek( FwxFilial( 'TRZ' ) + '000000' )
                RecLock( 'TRZ', .T. )
                TRZ->TRZ_FILIAL := FwxFilial( 'TRZ' )
                TRZ->TRZ_CODOR  := '000000'
                TRZ->TRZ_NOMOR  := 'Uso exclusivo Integração Brobot'
                If lNgIntFi
                    TRZ->TRZ_FORNEC := MV_PAR04
                    TRZ->TRZ_LOJA   := MV_PAR05
                    TRZ->TRZ_CONPAG := MV_PAR06
                EndIf
                TRZ->( MsUnLock() )
            EndIf
        EndIf

        cResponse := HTTPGet( cURL, /*cGetParms*/, /*nTimeOut*/, aHeadStr )

        // Verificar e tratar o retorno para quando existir erros de processos.
        nStatus    := HTTPGetStatus( cError )

        If nStatus == 200

            If FWJsonDeserialize( cResponse, @oParser ) .And. AttIsMemberOf( oParser, 'data' )
                
                For nTickets := 1 To  Len( oParser:Data )

                    // Somente incluir multas que ainda não foram pagas e multas que já passaram data de pagamento
                    If oParser:Data[ nTickets ]:status == 'opened' .Or. oParser:Data[ nTickets ]:status == 'expired'

                        aInfo := FwDateTimeToLocal( oParser:Data[ nTickets ]:created_at )
                        cHour := SubStr( aInfo[ 2 ], 1, 5 )

                        dbSelectArea( 'TRX' )
                        dbSetOrder( 9 ) // TRX_PLACA + TRX_DTINFR + TRX_RHINFR
                        If !dbSeek( Padr( oParser:Data[ nTickets ]:plate, nSizePl ) + Padr( DtoS( aInfo[ 1 ] ), nSizeDt ) + Padr( cHour, nSizeHr ) )
                        
                            oModel := FwLoadModel( 'MNTA765' )
                            oModel:SetOperation( 3 )
                            oModel:Activate()

                            oModel:SetValue( 'MULTAS', 'TRX_FILIAL', Posicione( 'ST9', 14, oParser:Data[ nTickets ]:plate, 'T9_FILIAL' ) )
                            oModel:SetValue( 'MULTAS', 'TRX_MULTA' , fValSXE( cBranchTRX ) )
                            oModel:SetValue( 'MULTAS', 'TRX_DTINFR', aInfo[ 1 ] )
                            oModel:SetValue( 'MULTAS', 'TRX_RHINFR', cHour )
                            oModel:SetValue( 'MULTAS', 'TRX_NUMAIT', oParser:Data[ nTickets ]:ait )
                            oModel:SetValue( 'MULTAS', 'TRX_CODINF', cValToChar( oParser:Data[ nTickets ]:code ) )
                            oModel:SetValue( 'MULTAS', 'TRX_LOCAL' , oParser:Data[ nTickets ]:local )
                            oModel:SetValue( 'MULTAS', 'TRX_UFINF' , oParser:Data[ nTickets ]:uf )
                            
                            // Tratamento realizado para que ao receber uma multa onde não esteja preenchido o órgão autuador,
                            // adiciona um órgão genérico para conseguir realizar a importação
                            If ValType( oParser:Data[ nTickets ]:issuing_authority ) == 'C'
                                oModel:SetValue( 'MULTAS', 'TRX_CODOR' , oParser:Data[ nTickets ]:issuing_authority )
                            Else
                                oModel:SetValue( 'MULTAS', 'TRX_CODOR' , '000000' )
                            EndIf
                            
                            oModel:SetValue( 'MULTAS', 'TRX_PLACA' , oParser:Data[ nTickets ]:plate )
                            oModel:SetValue( 'MULTAS', 'TRX_ORIGEM', '1' )
                            
                            //Existem cenários onde o retorno da Brobot vem como Nulo.
                            If ValType( oParser:Data[ nTickets ]:value_cents ) == 'N'
                                oModel:SetValue( 'MULTAS', 'TRX_VALOR' , oParser:Data[ nTickets ]:value_cents / 100 )
                            EndIf
                            
                            oModel:SetValue( 'MULTAS', 'TRX_DTEMIS', aInfo[ 1 ] )
                            oModel:SetValue( 'MULTAS', 'TRX_TPMULT', 'TRANSITO' )
                            
                            // O campo referente a data de vencimento poderá não ser carregado em alguns cenários.
                            If ValType( oParser:Data[ nTickets ]:expired_at ) == 'C'
                                oModel:SetValue( 'MULTAS', 'TRX_DTVECI', StoD( oParser:Data[ nTickets ]:expired_at ) )
                            EndIf

                            If lNgIntFi
                                oModel:SetValue( 'MULTAS', 'TRX_PREFIX', aBroBotFi[ 1 ] )
                                oModel:SetValue( 'MULTAS', 'TRX_TIPO'  , aBroBotFi[ 2 ] )
                                oModel:SetValue( 'MULTAS', 'TRX_NATURE', aBroBotFi[ 3 ] )
                                oModel:SetValue( 'MULTAS', 'TRX_CONPAG', aBroBotFi[ 4 ] )
                            EndIf

                            If oModel:VldData()
                                oModel:CommitData()
                            Else
                                VarInfo( 'Erro ao incluir multa ', oModel:GetErrorMessage() )
                                RollBackSXE( 'TRX', 'TRX_MULTA' )
                            EndIf

                            oModel:DeActivate()
                            oModel:Destroy()
                            oModel := NIL
                            MNTA765VAR()

                        EndIf

                    EndIf

                Next nTickets

            EndIf

        ElseIf nStatus == 403
            
            fSaveLog( 'Token informado no parâmetro MV_NGBROBO está incorreto!' )

        EndIf

    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fValSXE
Valida numero do campo TRX_MULTA

@type   Function

@author Eduardo Mussi
@since  02/02/2024
@param  cBranchTRX, caracter, Filial TRX

@return cTicket, Retorna o numero disponivel pelo SXE.
/*/
//-------------------------------------------------------------------
Static Function fValSXE( cBranchTRX )

    Local aArea   := FwGetArea()
    Local cTicket := GetSxeNum( 'TRX', 'TRX_MULTA' )
    Local lFound  := .T.

    dbSelectArea( 'TRX' )
    dbSetOrder( 1 )

    While lFound
        
        If dbSeek( cBranchTRX + cTicket )
            
            cTicket := GetSxeNum( 'TRX', 'TRX_MULTA' )

        Else
            
            lFound := .F.

        EndIf

    EndDo

    FwRestArea( aArea )

Return cTicket

//-------------------------------------------------------------------
/*/{Protheus.doc} fSaveLog
Salva possiveis problemas encontrados ao rodar o schedule.

@type   Function

@author Eduardo Mussi
@since  14/02/2024
@param  cMsg, Caracter, Mensagem de inconsistência

/*/
//-------------------------------------------------------------------
Static Function fSaveLog(cMsg)

    Local cFileName :='\MNTMWS' + dToS( Date() ) + StrTran( Time(), ':' ) + '.txt'
    Local cText     := ''
 
    // Montando a mensagem
    cText += 'Usuário  - ' + cUserName         + CRLF
    cText += 'Data     - ' + dToC( dDataBase ) + CRLF
    cText += 'Hora     - ' + Time()            + CRLF
    cText += 'Mensagem - ' + cMsg

    MemoWrite( cFileName, cText )
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Execução de Parâmetros na Definição do Schedule

@type    function
@author  Eduardo Mussi
@since   02/02/2024
@sample  SchedDef()

@return  aParam, Array, Contém as definições de parâmetros
/*/
//-------------------------------------------------------------------
Static Function SchedDef()

    Local cPerg := 'PARAMDEF'

    If !Empty( Posicione( 'SX1', 1, 'MNTMWS', 'X1_ORDEM' ) )
        
        If SuperGetMV( 'MV_NGMNTFI', .F., 'N' ) == 'S'
            cPerg := 'MNTMWSF'
        Else
            cPerg := 'MNTMWS'
        EndIf

    EndIf

Return { 'P', cPerg, '', {}, 'Caça Multas - Brobot' }
