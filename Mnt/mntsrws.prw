#INCLUDE 'Totvs.ch'
#INCLUDE 'RestFul.ch'
#INCLUDE 'MNTSRWS.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTSRWS
Gera O.S. a partir de uma S.S.

@author Eduardo Mussi
@since  28/04/2022
/*/
//-------------------------------------------------------------------
WSRESTFUL MNTSRWS DESCRIPTION STR0001 // "Solicitação de Serviço SIGAMNT/SIGAGFR"
    
    WsData Value As Character Optional
	WsData Operation As Character Optional

    WsMethod POST Request Description STR0002 Path 'api/v1/request'                     WsSyntax 'api/v1/request' // "Incluir S.S."
    WsMethod PUT  Request Description STR0003 Path 'api/v1/request/{value}/{operation}' WsSyntax 'api/v1/request/{value}/{operation}' // "Incluir O.S a partir de S.S."

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} Request
Gera S.S.

@type   Method

@author Eduardo Mussi
@since  28/04/2022

@return lógico, Define se o processo foi executado corretamente
/*/
//-------------------------------------------------------------------
WSMETHOD POST Request WsService MNTSRWS

    Local aRet := { .T., '' }
    Local lRet := .T.
    Local bError
    Local oError

    printf('Metodo POST Request')
    bError := ErrorBlock( { |oError| MntWSError( Self, oError, ::GetHeader('user'), ::GetContent() ), lRet:= .F., Break( oError ) } )

    Begin Sequence
        
        // Verifica se o ambiente foi inicializado corretamente
        aRet := fValEnv( Self )
        
        If aRet[1]

            Begin Transaction
                
                aRet := NGUpsertSR( Self, 'create', Nil, .F. )
                lRet := PrintPostLog( Self, lRet, aRet )

            Recover
                DisarmTransaction()

            End Transaction

            CloseTransactions( aRet )
        Else
            Self:SetStatus( 400 )
	        Self:SetResponse( EncodeUtf8( aRet[ 2 ] ) )
        EndIf

	End Sequence

	ErrorBlock( bError )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Request
Gera O.S. a partir de uma S.S.

@type   Method

@author Eduardo Mussi
@since  28/04/2022

@return lógico, Define se o processo foi executado corretamente
/*/
//-------------------------------------------------------------------
WSMETHOD PUT Request PATHPARAM value, operation WsService MNTSRWS

    Local aRet := { .T., '' }
    Local lRet := .T.
    Local bError
    Local oError

    printf('Metodo PUT Request')
    bError := ErrorBlock( { |oError| MntWSError( Self, oError, ::GetHeader('user'), ::GetContent() ), lRet:= .F., Break( oError ) } )

    Begin Sequence
        // Verifica se o ambiente foi inicializado corretamente
        aRet := fValEnv( Self )
        
        If aRet[ 1 ]
            Begin Transaction

                aRet := NGUpsertSR( Self, ::operation, ::value, .F. )
                lRet := PrintPostLog( Self, lRet, aRet )

            Recover
                DisarmTransaction()

            End Transaction

            CloseTransactions( aRet )
        Else
            Self:SetStatus( 400 )
	        Self:SetResponse( EncodeUtf8( aRet[ 2 ] ) )
        EndIf

	End Sequence

	ErrorBlock( bError )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fValEnv
Verifica se o ambiente está apto a ser utilizado

@type   Function

@author Eduardo Mussi
@since  28/04/2022

@return array, retorna informações de verificação
                [1] - Define se o ambiente pode ser utilizad
                [2] - Caso encontre alguma inconsistência, retorna mensagem
/*/
//-------------------------------------------------------------------
Static Function fValEnv( oWs )

    Local aRet  := { .T., '' }

    printf('VALIDACAO DO AMBIENTE - FVALENV')
    
    If ValType( oWs:GetHeader( 'tenantId' ) ) != 'C' .Or. Select( 'SM0' ) == 0 .Or. ValType( cEmpAnt ) != 'C' .Or. ValType( cFilAnt ) != 'C' .Or.;
        Empty( cEmpAnt ) .Or. Empty( cFilAnt )

        printf('A requisição está inválida. A empresa/filial não foi aberta corretamente. Favor verificar o valor informadno no tenantId!')
        aRet := { .F., STR0004 } // "A requisição está inválida. A empresa/filial não foi aberta corretamente. Favor verificar o valor informadno no tenantId!"
    EndIf

Return aRet

//---------------------------------------------------------------------
/*/{Protheus.doc} printf
Função para apresentar ou não mensagens no server, utilizado geralmente
para testes de desenvolvimento

@author	Eduardo Mussi
@since  03/05/2022
@return string, log + data e hora
/*/
//---------------------------------------------------------------------
Static Function printf(cLog)
return FwLogMsg( 'INFO', cValToChar( ThreadId() ), 'REST', 'MNTSRWS', '', '01', cLog, 0, 0, {} )

//---------------------------------------------------------------------
/*/{Protheus.doc} PrintPostLog
Realiza operações finais após as operações realizadas nas rotas post

@author	Eduardo Mussi
@since  03/05/2022
@param  oWS, objeto, referência ao webservice
@param  lRet, boolean, indica se as operações ocorreram com sucesso
@param  aRet, array, retorno das operações
				[1] indica se as operações ocorreram com sucesso
				[2] mensagem de erro/sucesso
@return logic, se operações foram realizadas com sucesso de acordo com os parâmetros
/*/
//---------------------------------------------------------------------
Static Function PrintPostLog( oWs, lRet, aRet )

	Local nSize     := 0

	Default aRet := {}

	// Verifica tamanho do array de informações
	nSize := Len( aRet )

	If nSize > 0

		If !aRet[ 1 ]
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( aRet[ 2 ] ), , 400 )
			printf('SetRestFault: 400' )
			printf( aRet[ 2 ] )
		Else
			oWs:SetStatus( 200 )
			If !Empty( aRet[2] )
				oWs:SetResponse( EncodeUtf8( aRet[2] ) )
			EndIf
		EndIf

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} CloseTransactions
Realiza operações pós controle de transação

@author	Eduardo Mussi
@since  03/05/2022
@param aRet, array, retorno das operações
				[1] indica se as operações ocorreram com sucesso
@return nil
/*/
//---------------------------------------------------------------------
Static Function CloseTransactions( aRet )

	//Caso tenha sido executado e tenha caído em uma validação
	If len(aRet) > 0 .And. !aRet[1]
		DisarmTransaction()
	EndIf

	//Garante que todos os BeginTran foram liberados
	While inTransact()
		printf('------------ Liberando transacao ------------')
		EndTran()
	Enddo

	//Garante que todos os registro foram liberados
	DBCommitAll( )
	MsUnlockAll( )

Return
