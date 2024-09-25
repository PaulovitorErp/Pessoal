#INCLUDE "PROTHEUS.CH"
#INCLUDE "MDTA883.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA883
Rotina que realiza a verificação diária da alteração das informações do
recibo da CAT, recibo da CAT origem e data do recebimento da CAT por
parte do governo. Essas informações devem ser atualizadas periodicamente
para que essas informações sejam impressas corretamente no relatório
da CAT eSocial (MDTR832). A rotina pode ser executada tanto via schedule
(job) ou manualmente através do botão "Outras Ações/Sincronizar Infos. CAT"
contido na rotina de cadastro de acidentes (MDTA640)

@return .T., Boolean, Sempre verdadeiro

@sample MDTA883()

@author Luis Fellipy Bett
@since  28/02/2022
/*/
//---------------------------------------------------------------------
Function MDTA883()

	//Armazena as variáveis
	Local leSocial := IIf( FindFunction( "MDTVldEsoc" ), MDTVldEsoc(), .F. )
    Local aNGBEGINPRM

    //Variáveis private utilizadas no processo
    Private lMiddleware := IIf( cPaisLoc == 'BRA' .And. Findfunction( "fVerMW" ), fVerMW(), .F. )
    Private lJob := IsBlind()

    //Caso a integração com o eSocial estiver habilitada
    If leSocial

        //Caso os campos novos do recibo existirem na tabela TNC
        If FindFunction( "MDT640Rcb" ) .And. MDT640Rcb( 1 )

            //---------------------------------------------------
            // Caso não for execução via job inicia as variáveis
            //---------------------------------------------------
            If !lJob
                aNGBEGINPRM := NGBEGINPRM()
            EndIf

            //-------------------------------------------------------
            // Chama a função de processamento das informaçõs da CAT
            //-------------------------------------------------------
            fProcCAT()

            If lJob
                FWLogMsg( 'WARN', , 'BusinessObject', 'MDTA883', '', '01', STR0002, 0, 0, {} ) //"Execução do schedule finalizada com sucesso!"
            Else
                Help( ' ', 1, STR0001, , STR0003, 2, 0 ) //"Processamento finalizado com sucesso!"
            EndIf

            //----------------------------------------------------
            // Caso não for execução via job retorna as variáveis
            //----------------------------------------------------
            If !lJob
                NGRETURNPRM( aNGBEGINPRM )
            EndIf

        Else

            If lJob
                FWLogMsg( 'WARN', , 'BusinessObject', 'MDTA883', '', '01', STR0004, 0, 0, {} ) //"O sistema não possui os campos TNC_RECIBO, TNC_RECORI e TNC_DTRECB no dicionário ou está com o pacote de fontes desatualizado"
            Else
                Help( ' ', 1, STR0001, , STR0004, 2, 0, , , , , , { STR0005 } ) //"O sistema não possui os campos TNC_RECIBO, TNC_RECORI e TNC_DTRECB no dicionário ou está com o pacote de fontes desatualizado" ## "Favor atualizar o sistema para poder utilizar a rotina de atualização automática dos campos do acidente"
            EndIf

        EndIf

    Else

        If lJob
            FWLogMsg( 'WARN', , 'BusinessObject', 'MDTA883', '', '01', STR0006, 0, 0, {} ) //"A integração com o eSocial não está habilitada" ##
        Else
            Help( ' ', 1, "Atenção", , STR0006, 2, 0, , , , , , { STR0007 } ) //"A integração com o eSocial não está habilitada" ## "Favor ativar o parâmetro MV_NG2ESOC para poder utilizar a rotina de atualização automática dos campos do acidente"
        EndIf

    EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fProcCAT
Função que processa a busca as informações do recibo da CAT, recibo da
CAT origem e data do recebimento da CAT do SIGATAF/Middleware. Caso o
envio for via job cria as pastas e o arquivo .txt com as CAT's atualizadas
dentro da pasta system

@return Nil, Nulo

@sample fProcCAT()

@author Luis Fellipy Bett
@since  28/02/2022
/*/
//---------------------------------------------------------------------
Function fProcCAT()

    //Variáveis de composição do arquivo .txt
	Local cBarras := IIf( IsSrvUnix(), "/", "\" )
    Local cDirPai := cBarras + 'esocial_mdt'
    Local cDirFil := cBarras + 'esocial_mdt' + cBarras + 'upd_cpos_cat'
    Local cMsgAux := ""
    Local cMsg    := ""

	//Se for execução via schedule
    If lJob

		//Verifica se a pasta pai existe na system
		If !File( cDirPai )
			MakeDir( cDirPai )
		EndIf

        //Verifica se a pasta filha existe na system
		If !File( cDirFil )
			MakeDir( cDirFil )
		EndIf

        //Define o nome do arquivo que será criado
		cArqPesq := cDirFil + cBarras + "mdta883_" + DToS( Date() ) + "_" + StrTran( Time(), ":", "" ) + ".txt"

		//Cria arquivo no diretório
        nHandle := FCREATE( cArqPesq, 0 )

        //Caso o arquivo tenha sido criado corretamente
		If FERROR() == 0

            //Define cabeçalho da mensagem
            cMsg += "----------------------     MDTA883 | " + DToC( Date() ) + " " + Time() + "     ----------------------" + CRLF + CRLF

            //Chama a função de atualização dos campos
            fUpdCpsCAT( @cMsgAux )

            //Adiciona a mensagem retornada com as CAT's atualizadas
            cMsg += cMsgAux

            //Caso alguma CAT tiver sido atualizada
            If !Empty( cMsgAux )

                cMsg += CRLF + "----------------------     " + STR0008 + "    ----------------------" //"CAT's atualizadas com sucesso!"

            Else

                cMsg += CRLF + "------------------------    " + STR0009 + "    ------------------------" //"Nenhuma CAT foi atualizada!"

            EndIf

			FWrite( nHandle, cMsg )

			FCLOSE( nHandle )

		EndIf

	Else //Se for execução via rotina

        fUpdCpsCAT( @cMsg )

        //Caso alguma CAT tenha sido atualizada
        If !Empty( cMsg )

            NGMSGMEMO( STR0010, cMsg ) //"CAT's atualizadas"

        Else

            Help( ' ', 1, STR0001, , STR0009, 2, 0 ) //"Nenhuma CAT foi atualizada!"

        EndIf

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fUpdCpsCAT
Função que gerencia as chamadas das funções de busca dos acidentes do
sistema, de busca das informações do recibo, recibo origem e data do 
recebimento da CAT por parte do governo e de atualização dos campos
na tabela TNC

@sample fUpdCpsCAT( "" )

@param  cMsg, Caracter, Variável que retorna por referência as CAT's
que foram atualizadas na tabela TNC

@return Nil, Nulo

@author Luis Fellipy Bett
@since  07/03/2022
/*/
//-------------------------------------------------------------------
Static Function fUpdCpsCAT( cMsg )

    //Salva a área
    Local aArea := GetArea()

    //Variáveis de busca das informações
	Local aAcids := {}

    //--------------------------------------------------
    // Busca os acidentes a terem os campos atualizados
    //--------------------------------------------------
    If lJob
        aAcids := fGetCATs()
    Else
        Processa( { || aAcids := fGetCATs() }, STR0011 ) //"Aguarde, buscando acidentes..."
    EndIf

    //--------------------------------------------------------------------------------
    // Busca as informações do SIGATAF/Middleware para atualizar nos registros da TNC
    //--------------------------------------------------------------------------------
    If lJob
        fGetInfRET( @aAcids )
    Else
        Processa( { || fGetInfRET( @aAcids ) }, STR0012 + IIf( lMiddleware, STR0013, STR0014 ) + "..." ) //"Aguarde, buscando as informações do " ## "Middleware" ## "SIGATAF"
    EndIf

    //--------------------------------------------------------------------------------------------
    // Atualiza as informações da CAT na tabela TNC de acordo com o retorno do SIGATAF/Middleware
    //--------------------------------------------------------------------------------------------
    If lJob
        fUpdCpsTNC( aAcids, @cMsg )
    Else
        Processa( { || fUpdCpsTNC( aAcids, @cMsg ) }, STR0015 ) //"Aguarde, atualizando informações na tabela TNC..."
    EndIf

    //Retorna a área
    RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetCATs
Busca os acidentes ativos cadastrados na tabela TNC

@sample fGetCATs()

@return aAcids, Array, Array contendo os acidentes a serem atualizados

@author Luis Fellipy Bett
@since  07/03/2022
/*/
//-------------------------------------------------------------------
Static Function fGetCATs()

    Local aArea     := GetArea()
    Local aAcids    := {}

    Local cHoraAci  := ''
    Local cAliasTNC := GetNextAlias()

    BeginSQL Alias cAliasTNC

        SELECT
            TNC.TNC_ACIDEN, TNC.TNC_DTACID, TNC.TNC_HRACID, TNC.TNC_TIPCAT, TM0.TM0_MAT, TNC.TNC_INDACI
        FROM
            %Table:TNC% TNC
        INNER JOIN %Table:TM0% TM0 ON
            TM0.TM0_FILIAL = %xFilial:TM0% AND
            TM0.TM0_NUMFIC = TNC.TNC_NUMFIC AND
            TM0.TM0_MAT != '' AND
            TM0.%NotDel%
        WHERE
            TNC.TNC_FILIAL = %xFilial:TNC% AND
            TNC.%NotDel%
        GROUP BY
            TNC.TNC_ACIDEN, TNC.TNC_DTACID, TNC.TNC_HRACID, TNC.TNC_TIPCAT, TM0.TM0_MAT, TNC.TNC_INDACI

    EndSQL

    //Posiciona na tabela
    dbSelectArea( cAliasTNC )
    ( cAliasTNC )->( dbGoTop() )

    //Caso for execução manual, seta a régua de processamento
    If !lJob
        ProcRegua( RecCount() )
    EndIf

    //Percorre os acidentes adicionando no array
    While ( cAliasTNC )->( !Eof() )

        //Caso for execução manual, incrementa a régua de processamento
        If !lJob
            IncProc()
        EndIf

        If ( cAliasTNC )->TNC_INDACI != '3' // Quando acidente é originado de doença a hora não é gravada no XML
            cHoraAci := StrTran( ( cAliasTNC )->TNC_HRACID, ":", "" )
        EndIf

        //Adiciona as informações do acidente no array
        aAdd( aAcids, {;
            { ( cAliasTNC )->TNC_ACIDEN },; // [1]
            { ( cAliasTNC )->TM0_MAT },; // [2]
            {;
                ( cAliasTNC )->TNC_DTACID,; // [3, 1]
                cHoraAci,; // [3, 2]
                ( cAliasTNC )->TNC_TIPCAT; // [3, 3]
            },; // [3]
            {}; // [4]
        } )

        cHoraAci := ''

        //Pula para o próximo registro
        ( cAliasTNC )->( dbSkip() )

    End

    //Fecha a tabela temporária
    ( cAliasTNC )->( dbCloseArea() )

    //Retorna a área
    RestArea( aArea )

Return aAcids

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetInfRET
Busca as informações de recibo, recibo da CAT origem (se houver) e data
do recebimento da CAT do SIGATAF/Middleware

@sample fGetInfRET( { { "000231" } } )

@param  aAcids, Array, Array contendo os acidentes a terem as informações atualizadas

@return Nil, Nulo

@author Luis Fellipy Bett
@since  07/03/2022
/*/
//-------------------------------------------------------------------
Static Function fGetInfRET( aAcids )

	//Salva a área
    Local aArea := GetArea()
    
    //Variáveis de busca das informações
    Local cIDFunc  := ""
    Local cRecibo  := ""
    Local cDtRecb  := ""
    Local cTipoCAT := ""
    Local dDtAcid  := SToD( "" )
    Local cHrAcid  := ""
    Local nCont    := 0
    Local aArrTAF  := {}
    Local aEvento  := {}
    Local nEvento  := 0

    //Variáveis private utilizadas dentro da função MDTCATOrig
    Private cNumMat := ""
    Private cNrRecCatOrig := ""

    //Caso o envio for via Middleware
    If lMiddleware

        //Seta a régua de processamento
        If !lJob
            ProcRegua( Len( aAcids ) )
        EndIf

        //Percorre os acidentes buscando as informações
        For nCont := 1 To Len( aAcids )

            //Incrementa a régua de processamento
            If !lJob
                IncProc()
            EndIf

            //Adiciona a matrícula do funcionário na variável
            cNumMat := aAcids[ nCont, 2, 1 ]

            //Busca os Xml's do evento S-2210 para o funcionário
            aEvento := MDTLstXml( "S2210", aAcids[ nCont, 2, 1 ] )

            //Verifica entre os Xml's encontrados qual se refere a CAT
            For nEvento := 1 To Len( aEvento )

                //Adiciona as informações do acidente nas variáveis
                dDtAcid  := MDTXmlVal( "S2210", aEvento[ nEvento, 1 ], "/ns:eSocial/ns:evtCAT/ns:cat/ns:dtAcid", "D" )
                cHrAcid  := MDTXmlVal( "S2210", aEvento[ nEvento, 1 ], "/ns:eSocial/ns:evtCAT/ns:cat/ns:hrAcid", "C" )
                cTipoCAT := MDTXmlVal( "S2210", aEvento[ nEvento, 1 ], "/ns:eSocial/ns:evtCAT/ns:cat/ns:tpCat", "C" )

                //Caso o xml conter as informações iguais ao do acidente
                If ( dDtAcid == SToD( aAcids[ nCont, 3, 1 ] ) ) .And. ;
                ( cHrAcid == aAcids[ nCont, 3, 2 ] ) .And. ;
                ( cTipoCAT == aAcids[ nCont, 3, 3 ] )

                    //Salva as informações da CAT
                    cRecibo := AllTrim( aEvento[ nEvento, 2 ] )
                    cDtRecb := aEvento[ nEvento, 2 ]
                    MDTCATOrig( cTipoCAT, dDtAcid, cHrAcid ) //Função para buscar o recibo da CAT origem

                    //Sai do laço pois encontrou as informações da CAT
                    Exit

                EndIf

            Next nEvento

            //Caso tenha sido encontrada alguma das informações
            If !Empty( cRecibo ) .Or. !Empty( cNrRecCatOrig ) .Or. !Empty( cDtRecb )

                //Adiciona as informações do SIGATAF/Middleware no array
                aAdd( aAcids[ nCont, 4 ], { cRecibo, cNrRecCatOrig, cDtRecb } )

            EndIf

            //Zera as variáveis para buscar as informações da próxima CAT do laço
            cNrRecCatOrig := ""
            cRecibo := ""
            cDtRecb := ""

        Next nCont

    Else //Caso o envio for via SIGATAF

        //Caso a função de busca do TAF exista no RPO
        If FindFunction( "ConsultaCAT" )

            //Percorre os acidentes a serem atualizados para montar o array a ser passado na função ConsultaCAT do SIGATAF
            For nCont := 1 To Len( aAcids )

                //Guarda a matrícula do funcionário na variável private
                cNumMat := aAcids[ nCont, 2, 1 ]

                //Busca o TAFKEY da CAT, se houver
                cTAFKey := MDTGetTKEY( aAcids[ nCont, 3, 1 ] + aAcids[ nCont, 3, 2 ] + aAcids[ nCont, 3, 3 ] )

                //Busca o ID do funcionário no TAF
                cIDFunc := MDTGetIdFun( cNumMat )

                aAdd( aArrTAF,;
                    { xFilial( "CM0" ),; // [1]
                    cTAFKey,; // [2]
                    cIDFunc,; // [3]
                    aAcids[ nCont, 3, 1 ],; // [4]
                    aAcids[ nCont, 3, 2 ],; // [5]
                    aAcids[ nCont, 3, 3 ]; // [6]
                } )

            Next nCont

            //Busca as informações da CAT do SIGATAF
            aInfTAF := ConsultaCAT( aArrTAF )

            //Adiciona as informações ao array de retorno
            For nCont := 1 To Len( aAcids )

                //Pega as informações do array retornado do SIGATAF
                cRecibo := aInfTAF[ nCont, 7 ]
                cNrRecCatOrig := aInfTAF[ nCont, 8 ]
                cDtRecb := aInfTAF[ nCont, 9 ]

                //Caso tenha sido encontrada alguma das informações
                If !Empty( cRecibo ) .Or. !Empty( cNrRecCatOrig ) .Or. !Empty( cDtRecb )

                    //Adiciona as informações do SIGATAF/Middleware no array
                    aAdd( aAcids[ nCont, 4 ], { cRecibo, cNrRecCatOrig, cDtRecb } )

                EndIf

                //Zera as variáveis para buscar as informações da próxima CAT do laço
                cNrRecCatOrig := ""
                cRecibo := ""
                cDtRecb := ""

            Next nCont
        
        Else

            //Seta a régua de processamento
            If !lJob
                ProcRegua( Len( aAcids ) )
            EndIf

            //Percorre os acidentes buscando as informações
            For nCont := 1 To Len( aAcids )

                //Incrementa a régua de processamento
                If !lJob
                    IncProc()
                EndIf

                //Adiciona a matrícula do funcionário na variável
                cNumMat := aAcids[ nCont, 2, 1 ]

                //Busca o ID do funcionário no TAF
                cIDFunc := MDTGetIdFun( aAcids[ nCont, 2, 1 ] )

                //Busca o registro do acidente no TAF
                dbSelectArea( "CM0" )
                dbSetOrder( 4 )
                If dbSeek( xFilial( "CM0" ) + cIDFunc + aAcids[ nCont, 3, 1 ] + aAcids[ nCont, 3, 2 ] + aAcids[ nCont, 3, 3 ] )

                    //Busca o acidente mais atual para pegar as informações
                    While CM0->( !Eof() ) .And. ;
                        CM0->CM0_FILIAL == xFilial( "CM0" ) .And. ;
                        CM0->CM0_TRABAL == cIdFunc .And. ;
                        DToS( CM0->CM0_DTACID ) == aAcids[ nCont, 3, 1 ] .And. ;
                        StrTran( CM0->CM0_HRACID, ":", "" ) == aAcids[ nCont, 3, 2 ] .And. ;
                        CM0->CM0_TPCAT == aAcids[ nCont, 3, 3 ]

                        //Adiciona as informações do acidente nas variáveis
                        dDtAcid  := CM0->CM0_DTACID
                        cHrAcid  := StrTran( CM0->CM0_HRACID, ":", "" )
                        cTipoCAT := CM0->CM0_TPCAT

                        //Salva as informações da CAT
                        cRecibo := AllTrim( CM0->CM0_PROTUL )
                        cDtRecb := DToS( CM0->CM0_DTRECP )
                        MDTCATOrig( cTipoCAT, dDtAcid, cHrAcid ) //Função para buscar o recibo da CAT origem
                        
                        //Pula o registro
                        CM0->( dbSkip() )

                    End

                EndIf

                //Caso tenha sido encontrada alguma das informações
                If !Empty( cRecibo ) .Or. !Empty( cNrRecCatOrig ) .Or. !Empty( cDtRecb )

                    //Adiciona as informações do SIGATAF/Middleware no array
                    aAdd( aAcids[ nCont, 4 ], { cRecibo, cNrRecCatOrig, cDtRecb } )

                EndIf

                //Zera as variáveis para buscar as informações da próxima CAT do laço
                cNrRecCatOrig := ""
                cRecibo := ""
                cDtRecb := ""

            Next nCont

        EndIf

    EndIf

    //Retorna a área
    RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fUpdCpsTNC
Atualiza as os campos da tabela TNC com o retorno das informações do
recibo, recibo da CAT origem (se houver) e data do recebimento da CAT
do SIGATAF/Middleware

@sample fUpdCpsTNC( { { "000217" } }, "" )

@param  aAcids, Array, Array contendo as informações do acidente
@param  cMsg, Caracter, Variável que retorna por referência as CAT's
que foram atualizadas na tabela TNC

@return Nil, Nulo

@author Luis Fellipy Bett
@since  07/03/2022
/*/
//-------------------------------------------------------------------
Static Function fUpdCpsTNC( aAcids, cMsg )

    //Salva a área
    Local aArea := GetArea()

    //Variáveis de busca das informações
    Local nCont := 0

    //Seta a régua de processamento
    If !lJob
        ProcRegua( Len( aAcids ) )
    EndIf

    //Percorre os acidentes para atualizar as informações na TNC
    For nCont := 1 To Len( aAcids )

        //Incrementa a régua de processamento
        If !lJob
            IncProc()
        EndIf

        dbSelectArea( "TNC" )
        dbSetOrder( 1 )
        If dbSeek( xFilial( "TNC" ) + aAcids[ nCont, 1, 1 ] ) .And. Len( aAcids[ nCont, 4 ] ) > 0

            RecLock( "TNC", .F. )

                TNC->TNC_RECIBO := aAcids[ nCont, 4, 1, 1 ]
                TNC->TNC_RECORI := aAcids[ nCont, 4, 1, 2 ]
                TNC->TNC_DTRECB := SToD( aAcids[ nCont, 4, 1, 3 ] )
 
            TNC->( MsUnlock() )

            //Adiciona na variável para informar ao usuário
            cMsg += STR0016 + ": " + AllTrim( aAcids[ nCont, 1, 1 ] ) + CRLF //"Acidente"
            cMsg += "- " + STR0017 + ": " + AllTrim( aAcids[ nCont, 4, 1, 1 ] ) + CRLF //"Recibo"
            cMsg += "- " + STR0018 + ": " + AllTrim( aAcids[ nCont, 4, 1, 2 ] ) + CRLF //"Recibo CAT Origem"
            cMsg += "- " + STR0019 + ": " + DToC( SToD( aAcids[ nCont, 4, 1, 3 ] ) ) + CRLF + CRLF //"Data do Recebimento"

        EndIf

    Next nCont

    //Retorna a área
    RestArea( aArea )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Execução de Parâmetros na Definição do Schedule

@return aParam, Array, Conteudo com as definições de parâmetros para WF

@sample SchedDef()

@author Luis Fellipy bett
@since  07/03/2022
/*/
//---------------------------------------------------------------------
Static Function SchedDef()
Return { "P", "PARAMDEF", "", {}, "Param" }
