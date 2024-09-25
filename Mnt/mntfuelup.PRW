#include 'Totvs.ch'
#include 'RestFul.ch'
#include 'mntfuelup.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} mntFuelUp
WebService REST para importação de abastecimento SIGAMNT/SIGAGFR

@author Cauê Girardi Petri
@since	16/03/2023
@return	boolean
/*/
//---------------------------------------------------------------------

WSRestFul mntFuelUp Description STR0004 //'Web Service para importação de abastecimento'

    WsMethod POST   FuelUp Description STR0001 Path 'api/v1/fuelup' WsSyntax 'api/v1/fuelup' //'Inclusão de abastecimento'
    WsMethod PUT    FuelUp Description STR0002 Path 'api/v1/fuelup' WsSyntax 'api/v1/fuelup' //'Alteração de abastecimento'
    WsMethod DELETE FuelUp Description STR0003 Path 'api/v1/fuelup' WsSyntax 'api/v1/fuelup' //'Deleção de abastecimento'

End WsRestFul

//---------------------------------------------------------------------
/*/{Protheus.doc} Create
Método REST para inclusão de abastecimento SIGAMNT/SIGAGFR

@author Cauê Girardi Petri
@since	16/03/2023
@return	Lógico, Define se o processo foi concluido com sucesso
/*/
//---------------------------------------------------------------------

WsMethod POST FuelUp WsService mntFuelUp

    Local lRet  := .F.
    Local oError

    ::ClearResponse()
    ::SetContentType('application/json')

    bError := ErrorBlock( { |oError| MntWSError( oError ), lRet:= .F., Break( oError ) } )

    Begin Sequence

        lRet := fExecute(STR0005 , Self , 3) //' incluido com sucesso'
            
	End Sequence

	ErrorBlock( bError )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} Update
Método REST para alteração de abastecimento SIGAMNT/SIGAGFR

@author Cauê Girardi Petri
@since	16/03/2023
@return	Lógico, Define se o processo foi concluido com sucesso
/*/
//---------------------------------------------------------------------

WsMethod PUT FuelUp WsService mntFuelUp

    Local lRet  := .F.
    Local oError

    ::ClearResponse()
    ::SetContentType('application/json')

    bError := ErrorBlock( { |oError| MntWSError( oError ), lRet:= .F., Break( oError ) } )

    Begin Sequence

        lRet := fExecute(STR0006 , Self , 4) //' alterado com sucesso '
            
	End Sequence

	ErrorBlock( bError )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} Delete
Método REST para deleção de abastecimento SIGAMNT/SIGAGFR

@author Cauê Girardi Petri
@since	16/03/2023
@return	Lógico, Define se o processo foi concluido com sucesso
/*/
//---------------------------------------------------------------------

WsMethod DELETE FuelUp WsService mntFuelUp

    Local lRet  := .F.
    Local oError

    ::ClearResponse()
    ::SetContentType('application/json')

    bError := ErrorBlock( { |oError| MntWSError( oError ), lRet:= .F., Break( oError ) } )

    Begin Sequence

        lRet := fExecute(STR0007 , Self , 5) //' deletado com sucesso '
            
	End Sequence

	ErrorBlock( bError )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fVldExec
Executa o ExecAuto para os metodos

@param oWs, Objeto, referência ao webservice
@param nOpcx, numérico, numero da operação.
    3- Inclusão
    4- Alteração
    5- Deleção
@param cMsg, String, Mensagem vinda dos requests 
@author Cauê Girardi Petri
@since	16/03/2023
@return	String, Se gerar, retorna erro do execauto
/*/
//---------------------------------------------------------------------

Static Function fVldExec(oJson,nOpcx, cMsg)

    Local aAbast    := {}
    Local cError    := ''
    Local cCampErro := ''
    Local lRet      := .T.

    Private lMSErroAuto := .F.

    If ValType( ( oJson['TQN_PLACA'] ) ) != 'U'
        aAdd( aAbast, { 'TQN_PLACA', PadR( oJson['TQN_PLACA'], TAMSX3( 'TQN_PLACA' )[1] ), Nil } )
    EndIf
    If ValType( ( oJson['TQN_FROTA'] ) ) != 'U'
        aAdd( aAbast, { 'TQN_FROTA', PadR( oJson['TQN_FROTA'], TAMSX3( 'TQN_FROTA' )[1] ), Nil } )
    Else
        cCampErro := "TQN_FROTA"
        lRet := .F.
    EndIf
    If ValType( ( oJson['TQN_CODCOM'] ) ) != 'U'
        aAdd( aAbast, { 'TQN_CODCOM', PadR( oJson['TQN_CODCOM'], TAMSX3( 'TQN_CODCOM' )[1] ), Nil } )
    EndIf
    If ValType( ( oJson['TQN_POSTO'] ) ) != 'U'
        aAdd( aAbast, { 'TQN_POSTO', PadR( oJson['TQN_POSTO'], TAMSX3( 'TQN_POSTO' )[1] ), Nil } )
    EndIf
    If ValType( ( oJson['TQN_LOJA'] ) ) != 'U'
        aAdd( aAbast, { 'TQN_LOJA',PadR( oJson['TQN_LOJA'], TAMSX3( 'TQN_LOJA' )[1] ), Nil } )
    EndIf
    If ValType( ( oJson['TQN_CNPJ'] ) ) != 'U'
        aAdd( aAbast, { 'TQN_CNPJ', PadR( oJson['TQN_CNPJ'], TAMSX3( 'TQN_CNPJ' )[1] ), Nil } )
    EndIf
    If ValType( ( oJson['TQN_DTABAS'] ) ) != 'U'
        aAdd( aAbast, { 'TQN_DTABAS', Stod( oJson['TQN_DTABAS'] ), Nil } )
    Else
        cCampErro := "TQN_DTABAS"
        lRet := .F.
    EndIf
    If ValType( ( oJson['TQN_HRABAS'] ) ) != 'U'
        aAdd( aAbast, { 'TQN_HRABAS', PadR( oJson['TQN_HRABAS'], TAMSX3( 'TQN_HRABAS' )[1] ), Nil } )
    Else
        cCampErro := "TQN_HRABAS"
        lRet := .F.
    EndIf
    If ValType( ( oJson['TQN_TANQUE'] ) ) != 'U'
        aAdd( aAbast, { 'TQN_TANQUE',PadR( oJson['TQN_TANQUE'], TAMSX3( 'TQN_TANQUE' )[1] ), Nil } )
    EndIf
    If ValType( ( oJson['TQN_BOMBA'] ) ) != 'U'
        aAdd( aAbast, { 'TQN_BOMBA', PadR( oJson['TQN_BOMBA'], TAMSX3( 'TQN_BOMBA' )[1] ), Nil } )
    EndIf
    If ValType( ( oJson['TQN_QUANT'] ) ) != 'U'
        aAdd( aAbast, { 'TQN_QUANT', oJson['TQN_QUANT'], Nil } )
    EndIf
    If ValType( ( oJson['TQN_VALUNI'] ) ) != 'U'
        aAdd( aAbast, { 'TQN_VALUNI', oJson['TQN_VALUNI'], Nil } )
    EndIf
    If ValType( ( oJson['TQN_VALTOT'] ) ) != 'U'
        aAdd( aAbast, { 'TQN_VALTOT', oJson['TQN_VALTOT'], Nil } )
    EndIf
    If ValType( ( oJson['TQN_HODOM'] ) ) != 'U'
        aAdd( aAbast, { 'TQN_HODOM', oJson['TQN_HODOM'], Nil } )
    EndIf
    If ValType( ( oJson['TQN_POSCO2'] ) ) != 'U'
        aAdd( aAbast, { 'TQN_POSCO2', oJson['TQN_POSCO2'], Nil } )
    EndIf
    If ValType( ( oJson['TQN_CODMOT'] ) ) != 'U'
        aAdd( aAbast, { 'TQN_CODMOT', PadR( oJson['TQN_CODMOT'], TAMSX3( 'TQN_CODMOT' )[1] ), Nil } )
    EndIf
    If ValType( ( oJson['TQN_NOTFIS'] ) ) != 'U'
        aAdd( aAbast, { 'TQN_NOTFIS', PadR( oJson['TQN_NOTFIS'], TAMSX3( 'TQN_NOTFIS' )[1]), Nil } )
    EndIf
    If ValType( ( oJson['TQN_CODVIA'] ) ) != 'U'
        aAdd( aAbast, { 'TQN_CODVIA',PadR( oJson['TQN_CODVIA'], TAMSX3( 'TQN_CODVIA' )[1] ), Nil } )
    EndIf
    If ValType( ( oJson['TQN_ESCALA'] ) ) != 'U'
        aAdd( aAbast, { 'TQN_ESCALA',PadR( oJson['TQN_ESCALA'], TAMSX3( 'TQN_ESCALA' )[1] ), Nil } )
    EndIf

    If lRet

        If ( nOpcx == 4 .OR. nOpcx == 5 ) .AND. ( aScan( aAbast, { |x| x[1] == 'TQN_FROTA' } ) > 0 .AND. aScan( aAbast, { |x| x[1] == 'TQN_DTABAS' } ) > 0 .AND. aScan( aAbast, { |x| x[1] == 'TQN_HRABAS' } ) > 0 )

            DBSelectArea( 'TQN' )
            DBSetOrder( 1 ) //TQN_FROTA + TQN_DTABAS + TQN_HRABAS
            If MsSeek( FwxFilial('TQN') + PadR( oJson['TQN_FROTA'], TAMSX3( 'TQN_FROTA' )[1] ) + oJson['TQN_DTABAS'] + PadR( oJson['TQN_HRABAS'], TAMSX3( 'TQN_HRABAS' )[1] ) )

                cMsg := FwhttpEncode( STR0010 + TQN->TQN_NABAST + cMsg ) //'Abastecimento '

            EndIf

        EndIf

        MSExecAuto( { | v, x, y | MNTA655( v, x, y ) }, , aAbast, nOpcx )


        If lMsErroAuto
            cError := MostraErro( GetSrvProfString( 'Startpath', '' ) )
        EndIf

        If nOpcx == 3 .AND. !lMsErroAuto

            DBSelectArea( 'TQN' )
            DBSetOrder( 1 ) //TQN_FROTA + TQN_DTABAS + TQN_HRABAS
            If MsSeek( FwxFilial('TQN') + PadR( oJson['TQN_FROTA'], TAMSX3( 'TQN_FROTA' )[1] ) + oJson['TQN_DTABAS'] + PadR( oJson['TQN_HRABAS'], TAMSX3( 'TQN_HRABAS' )[1] ) )

                cMsg := FwhttpEncode( STR0010 + TQN->TQN_NABAST + cMsg ) //'Abastecimento '

            EndIf

        EndIf

    Else

        cError := STR0012 + cCampErro + STR0013

    EndIf

    FwFreeArray( aAbast )

Return cError

//---------------------------------------------------------------------
/*/{Protheus.doc} printf
Função para apresentar ou não mensagens no server, utilizado geralmente
para testes de desenvolvimento

@author	Cauê Girardi Petri
@since  21/03/2023
@return string, log + data e hora
/*/
//---------------------------------------------------------------------
Static Function printf(cLog)
return FwLogMsg( 'INFO', cValToChar( ThreadId() ), 'REST', 'mntFuelUp', '', '01', cLog, 0, 0, {} )

//--------------------------------------------------------------------------------
/*/{Protheus.doc} fExecute
Função para chamar a função do ExecAuto e adicionar uma mensagem

@param cMsg, String, Mensagem a ser mostrada ao final da execução
@param oWs, Objeto, referência ao webservice
@param nOpcx, numérico, numero da operação.
    3- Inclusão
    4- Alteração
    5- Deleção 
@author	Cauê Girardi Petri
@since  21/03/2023
@return Lógico, Retorna .F. caso o processo retorne com erro, e .T. caso sucesso
/*/
//--------------------------------------------------------------------------------
Static Function fExecute(cMsg, oWs, nOpcx)

    Local cError    := ''
    Local lRet      := .F.
    Local oJson     := JsonObject():New()

    cError := oJson:FromJson( oWs:GetContent() )

    If Valtype( cError ) == 'C' 

        lRet := .F.
        cError := FwhttpEncode( STR0008 + cError ) //'Json inválido'
        printf( STR0009 + cError ) //'Erro: '
        SetRestFault( 500, cError )
 
    Else

        cError := fVldExec(oJson, nOpcx, @cMsg)

        If !Empty( cError )

            lRet := .F.
            cError := FwhttpEncode( cError )
            printf( STR0009 + cError ) //'Erro: '
            SetRestFault( 500, cError )

        Else

            lRet  := .T.
            
            printf( cMsg )

            oWs:SetStatus( 200 )
	        oWs:SetResponse( cMsg )

        EndIf

    EndIf  

Return lRet
