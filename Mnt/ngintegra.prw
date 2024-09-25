#include 'protheus.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} ngIntegra
Fonte com as integrações realizadas por parte da NG

@author Gabriel Sokacheski
@since 16/05/2022

@param aParam, contém os parâmetros que serão utilizados na função

/*/
//---------------------------------------------------------------------
Function NgIntegra( aParam )

    Local lRet      := .T. // Não excluir pois é utilizada no retorno da NgIntegra no GPEA010
    Local lGpea010  := FWIsInCallStack( 'Gpea010' ) // Cadastro de funcionário
    Local lGpea030  := FWIsInCallStack( 'Gpea030' ) // Função
    Local lGpem040  := FWIsInCallStack( 'Gpem040' ) // Rescisão de funcionário
    Local lRspm001  := FWIsInCallStack( 'Rspm001' ) // Admissão de candidato
    Local lTcfa040  := ( FWIsInCallStack( 'Tcfa040' ) .Or. FWIsInCallStack( 'MdtExe' ) ) // Aprovação de atestados

    // Caso for chamado pelo módulo do GPE e houver integração
    If ( cModulo == 'MDT' .Or. cModulo == 'GPE' .Or. cModulo == 'RSP' ) .And. SuperGetMv( 'MV_MDTGPE', Nil, 'N' ) == 'S'

        Do Case
            Case lGpea010 .Or. lRspm001
                fCadFun( aParam )
            Case lGpea030
                fAltFun( aParam )
            Case lGpem040
                fRescFun( aParam )
            Case lTcfa040 .And. SuperGetMv( 'MV_MDTMRH', Nil, .F. )
                lRet := fAtestado( aParam )
        EndCase

    EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fCadFun
Faz as chamadas das funções do processo de cadastro de funcionário

@author Luis Fellipy Bett
@since  07/06/2022

@param aParam, contém os parâmetros que serão utilizados na função
    1° Posição: Operação que está sendo realizada (inclusão ou alteração)
    2° Posição: Indica se é admissão preliminar
/*/
//---------------------------------------------------------------------
Static Function fCadFun( aParam )

    //Salva a área
    Local aArea := GetArea()

    //Variáveis de parâmetros
    Local lMDTAdic := SuperGetMv( "MV_MDTADIC", , .F. )

    //Variáveis de chamadas
    Local lGPEA180 := FWIsInCallStack( "GPEA180" )

    //Variáveis de busca das informações
    Local nOpc    := aParam[ 1 ]
    Local lAdmPre := aParam[ 2 ]
    Local cVerGPE := ""

    //---------------------------------------------------------
    // Verifica o fluxo a ser seguido de acordo com a operação
    //---------------------------------------------------------
    If nOpc == 3 //Inclusão

        //Inclui a ficha médica do funcionário
        If FindFunction( "MdtAltTrf" )

            MdtAltTrf( xFilial( "SRA" ), SRA->RA_MAT )

        EndIf

    ElseIf nOpc == 4 //Alteração

        //Altera a ficha médica do funcionário (se necessário)        
        If FindFunction( "MdtAltFicha" )

            MdtAltFicha( xFilial( "SRA" ), SRA->RA_MAT )

        EndIf

        //Caso os campos estejam na memória
        If IsMemVar( "RA_SITFOLH" ) .And. IsMemVar( "RA_DEMISSA" )

            //Caso o funcionário foi demitido
            If ( M->RA_SITFOLH == "D" ) .Or. ( !Empty( M->RA_DEMISSA ) )

                If FindFunction( "MdtDelExames" )

                    //Deleta os exames do funcionário
                    MdtDelExames( SRA->RA_MAT, xFilial( "SRA" ), M->RA_DEMISSA )

                EndIf

                If FindFunction( "MdtDelCandCipa" )

                    //Deleta a candidatura da CIPA
                    MdtDelCandCipa( SRA->RA_MAT )

                EndIf

            EndIf

        EndIf

    EndIf

    //Verifica se é o SIGAMDT que ajustará a insalubridade/periculosidade
    If lMDTAdic

        //Verifica se a função existe no RPO
        If FindFunction( "MDT180AGL" ) .And. SRJ->( ColumnPos( "RJ_CUMADIC" ) ) > 0 .And. Posicione( "SRJ", 1, xFilial( "SRJ" ) + SRA->RA_CODFUNC, "RJ_CUMADIC" ) == "2"

            MDT180AGL( SRA->RA_MAT, "", SRA->RA_FILIAL, nOpc )

        ElseIf FindFunction( "MDT180INT" )

            MDT180INT( SRA->RA_MAT, "", .F., nOpc, SRA->RA_FILIAL )//Preenchimento dos campos de Insalubridade e periculosidade da SRA

        EndIf

    EndIf

    //Integração do S-2240 com o SIGATAF/Middleware
    If FindFunction( "MDTIntEsoc" )

        //Busca a versão de envio do SIGAGPE
        fVersEsoc( "S2200", .F., , , @cVerGPE )

        //Caso for admissão preliminar, o leiaute for maior ou igual ao S-1.0 e não for chamada pelo GPEA180
        If lAdmPre .And. !( cVerGPE < "9.0.00" ) .And. !lGPEA180

            //Integra o evento com o TAF/Mid
            MDTIntEsoc( "S-2240", nOpc, Nil, { { SRA->RA_MAT } }, .T. )

        EndIf

    EndIf

    //Retorna a área
    RestArea( aArea )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fRescFun
Faz as chamadas das funções do processo de rescisão de funcionário

@author Luis Fellipy Bett
@since  07/06/2022

@param aParam, contém os parâmetros que serão utilizados na função
    1° Posição: Matrícula do funcionário
    2° Posição: Data de demissão/rescisão
/*/
//---------------------------------------------------------------------
Static Function fRescFun( aParam )

    //Salva a área
    Local aArea := GetArea()

    //Variáveis de busca das informações
    Local cMatFun := aParam[ 1 ]
    Local dDtResc := aParam[ 2 ]

    If Inclui

        //Finaliza o programa de saúde e as tarefas do funcionário
        fTermFunc( cMatFun, dDtResc )

        //Deleta os exames do funcionário
        MdtDelExames( cMatFun, xFilial( "SRA" ), dDtResc )

        //Deleta a candidatura da CIPA do funcionário
        MdtDelCandCipa( cMatFun )

        //Retorna a área
        RestArea( aArea )

    Else

        //Exclui a data fim da tarefa
        fExcResc( cMatFun, dDtResc )

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fTermFunc
Termina o programa de saúde e a tarefa do funcionário de acordo com a
data de rescisão.

@author Gabriel Sokacheski
@since  16/05/2022

@param cMatFun, Caracter, Matrícula do funcionário
@param dDtResc, Data, Data de rescisão de contrato do funcionário
/*/
//---------------------------------------------------------------------
Static Function fTermFunc( cMatFun, dDtResc )

    Local aFun := {}
    Local aArea := GetArea()

    Local lGera2240 := SuperGetMV( 'MV_MDTENRE', Nil, .F. )

    //Posiciona na ficha médica do funcionário para buscar pelo programa de saúde
    dbSelectArea( 'TM0' )
	dbSetOrder( 3 )
	If dbSeek( xFilial( 'TM0' ) + cMatFun )

		dbSelectArea( 'TMN' )
		dbSetOrder( 2 )

		If dbSeek( xFilial( 'TMN' ) + TM0->TM0_NUMFIC )

			While TMN->( !Eof() ) .And. TMN->TMN_NUMFIC == TM0->TM0_NUMFIC

				If Empty( TMN->TMN_DTTERM )

					RecLock( 'TMN', .F. )
						TMN->TMN_DTTERM := dDtResc
					TMN->( MsUnlock() )

				EndIf

				TMN->( dbSkip() )

			End

		EndIf

	EndIf

    //Posiciona nas tarefas do funcionário
    dbSelectArea( 'TN6' )
    dbSetOrder( 2 )
    If dbSeek( xFilial( 'TN6' ) + cMatFun )

        While TN6->( !Eof() ) .And. TN6->TN6_MAT == cMatFun

            If Empty( TN6->TN6_DTTERM )

                RecLock( 'TN6', .F. )
                    TN6->TN6_DTTERM := dDtResc
                TN6->( MsUnlock() )

                aAdd( aFun, { TN6->TN6_MAT, Nil, Nil, TN6->TN6_CODTAR, TN6->TN6_DTINIC, dDtResc } )

            EndIf

            TN6->( dbSkip() )

        End

        If lGera2240 .And. Len( aFun ) > 0
            MdtEsoFimT()
            MdtIntEsoc( 'S-2240', 4, Nil, aFun, .T. )
        EndIf

    EndIf

    //Retorna a área
    RestArea( aArea )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fExcResc
Caso seja excluido a rescisão retira a data de fim da tarefa do 
funcionário

@author Eloisa Anibaletto
@since 13/04/2023

@param cMatFun, matrícula do funcionário
@param dDtResc, data de rescisão de contrato do funcionário
/*/
//---------------------------------------------------------------------
Static Function fExcResc( cMatFun, dDtResc )

    Local aArea := ( 'TN6' )->( GetArea() )

    dbSelectArea( 'TN6' )
    dbSetOrder( 2 )
    If dbSeek( xFilial( 'TN6' ) + cMatFun )

        While TN6->( !Eof() ) .And. TN6->TN6_MAT == cMatFun

            If !Empty( TN6->TN6_DTTERM ) 

                RecLock( 'TN6', .F. )
                    TN6->TN6_DTTERM := SToD( "" )
                TN6->( MsUnlock() )

            EndIf

            TN6->( dbSkip() )

        End

    EndIf

    RestArea( aArea )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fAltFun
Na alteração do campo de requisitos, altera os eventos S-2240

@author Gabriel Sokacheski
@since 22/08/2023

@param aParam, contém os parâmetros que serão utilizados na função
    1° Posição: Conteúdo do campo de requisitos antes da alteração

/*/
//---------------------------------------------------------------------
Static Function fAltFun( aParam )

    Local aFun      := {}
    Local aAreaSRA  := ( 'SRA' )->( GetArea() )

    Local cVersao   := ''

    Local nEvento   := 0
    Local nEventos  := 0

    Private cReqAnt := aParam[ 1 ]

    // Se a descrição das atividades no eSocial é correspondente ao campo de requisitos da função
    If SuperGetMv( 'MV_NG2TDES', .F., '1' ) == '3' .And. FindFunction( 'MDTIntEsoc' )

        fVersEsoc( 'S2200', .F., Nil, Nil, @cVersao ) // Busca a versão de envio do SIGAGPE

        If !( cVersao < '9.0.00' ) // Se o leiaute for maior ou igual ao S-1.0

            DbSelectArea( 'SRA' )
            ( 'SRA' )->( DbSetOrder( 7 ) )

            If ( 'SRA' )->( DbSeek( xFilial( 'SRA' ) + M->RJ_FUNCAO ) )

                While ( 'SRA' )->( !Eof() .And. SRA->RA_FILIAL + SRA->RA_CODFUNC == xFilial( 'SRA' ) + M->RJ_FUNCAO )

                    nEventos := MdtEsoDatF( SRA->RA_MAT )[ 2 ] // Verifica quantos eventos existem com a função

                    For nEvento := 1 To nEventos
                        aAdd( aFun, { SRA->RA_MAT } )
                    Next nEvento

                    ( 'SRA' )->( DbSkip() )

                End

            EndIf

            If Len( aFun ) > 0
                MDTIntEsoc( 'S-2240', 4, Nil, aFun, .T. )
            EndIf

        EndIf

    EndIf

    RestArea( aAreaSRA )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fAtestado
Cria atestado médico com as informações recebidas do MeuRh (TCFA040)

@author Gabriel Sokacheski
@since  26/04/2023

@sample NGIntegra( { 'D MG 01', '01', '004', 'A00.0', '01', CtoD( '01/08/2023' ), CtoD( '01/08/2023' ), '1', 'NUMID', .F. } )

@param aParam, contém os parâmetros que serão utilizados na função
    1° Posição: Filial
    2° Posição: Matrícula
    3° Posição: Tipo afastamento
    4° Posição: Cid
    5° Posição: Motivo afastamento
    6° Posição: Data início
    7° Posição: Data fim
    8° Posição: CRM Emitente
    9° Posição: ID da SR8 (imagem do atestado)
    10° Posição: Verdadeiro caso aprovação em lote

/*/
//---------------------------------------------------------------------
Static Function fAtestado( aAtestado )

    Local aErros    := {}
    Local aAreaTnp  := ( 'TNP' )->( GetArea() )

    Local cNome     := ''
    Local cFicha    := ''
    Local cBackup   := cFilAnt
    Local cEmitente := ''

    Local lRet      := .T.
    Local lExe      := .T. // Primeira execução do loop

    Local nDiaAfa   := 0
    Local nRetorno  := 0

    Local oModelTNY := Nil

    Private aMeuRh      := {} // Informações do MeuRh

    Private cPrograma   := 'MDTA685'
    Private cSR8NumId   := aAtestado[ 9 ] // Valor para gravar no campo R8_NUMID

    Private lMsErroAuto := .F.

    If cFilAnt != aAtestado[ 1 ]
        cFilAnt := aAtestado[ 1 ]
    EndIf

    cNome   := Posicione( 'SRA', 1, xFilial( 'SRA' ) + aAtestado[ 2 ], 'RA_NOME' )
    cFicha  := Posicione( 'TM0', 11, xFilial( 'TM0' ) + aAtestado[ 2 ], 'TM0_NUMFIC' )
    nDiaAfa := IIf( !Empty( aAtestado[ 7 ] ), DateDiffDay( aAtestado[ 6 ], aAtestado[ 7 ] ) + 1, 0 )

    aAdd( aMeuRh, aAtestado[ 10 ]   ) // Variável lógica, indica se é aprovação em lote
    aAdd( aMeuRh, !Empty( cFicha )  ) // Variável lógica, indica se encontrou a ficha médica
    aAdd( aMeuRh, aAtestado[ 2 ]    ) // Variável caractere, matrícula do funcionário em questão

    DbSelectArea( 'TNP' )
    ( 'TNP' )->( DbSetOrder( 5 ) )
    ( 'TNP' )->( DbGoTop() )

    If ( 'TNP' )->( DbSeek( xFilial( 'TNP' ) + AllTrim( aAtestado[ 8 ] ) ) )

        If AllTrim( TNP->TNP_NUMENT ) == AllTrim( aAtestado[ 8 ] );
        .And. TNP->TNP_INDFUN $ SuperGetMV( 'MV_NG2FUNM', .F., '1/6/A/C' )

            cEmitente := TNP->TNP_EMITEN

        EndIf

    EndIf

    RestArea( aAreaTnp )

    oModelTNY := FwLoadModel( 'MDTA685' )

    oModelTNY:SetOperation( 3 )

    oModelTNY:Activate()

    //-----------------
    // Atestado médico
    //-----------------

    // Obrigatórias
    oModelTNY:LoadValue( 'TNYMASTER1', 'TNY_NUMFIC', cFicha             )
    oModelTNY:SetValue( 'TNYMASTER1', 'TNY_FILIAL', xFilial( 'TNY' )    )

    If !Empty( cFicha )
        oModelTNY:SetValue( 'TNYMASTER1', 'TNY_NOMFIC', cNome )
    EndIf

    oModelTNY:SetValue( 'TNYMASTER1', 'TNY_DTINIC', aAtestado[ 6 ]      )
    oModelTNY:SetValue( 'TNYMASTER1', 'TNY_HRINIC', '00:00'             )
    oModelTNY:SetValue( 'TNYMASTER1', 'TNY_EMITEN', cEmitente           )

    // Não obrigatórias
    oModelTNY:SetValue( 'TNYMASTER1', 'TNY_DTFIM'   , aAtestado[ 7 ]                    )
    oModelTNY:SetValue( 'TNYMASTER1', 'TNY_HRFIM'   , '23:59'                           )
    oModelTNY:SetValue( 'TNYMASTER1', 'TNY_QTDIAS'  , nDiaAfa                           )
    oModelTNY:SetValue( 'TNYMASTER1', 'TNY_GRPCID'  , SubStr( aAtestado[ 4 ], 1, 3 )    )
    oModelTNY:SetValue( 'TNYMASTER1', 'TNY_CID'     , aAtestado[ 4 ]                    )
    oModelTNY:SetValue( 'TNYMASTER1', 'TNY_CODAFA'  , aAtestado[ 3 ]                    )
    oModelTNY:SetValue( 'TNYMASTER1', 'TNY_TPEFD'   , aAtestado[ 5 ]                    )

    //-------------
    // Afastamento
    //-------------
    oModelTNY:SetValue( 'TYZDETAIL', 'TYZ_FILIAL',  xFilial( 'TYZ' )    )
    oModelTNY:SetValue( 'TYZDETAIL', 'TYZ_MAT',     aAtestado[ 2 ]      )
    oModelTNY:SetValue( 'TYZDETAIL', 'TYZ_DTSAID',  aAtestado[ 6 ]      )
    oModelTNY:SetValue( 'TYZDETAIL', 'TYZ_DTALTA',  aAtestado[ 7 ]      )

    While lExe .Or. ( nRetorno == 0 .And. !lRet )

        lExe := .F.

        If Empty( cEmitente ) .Or. !lRet
            nRetorno := FWExecView( Nil, 'mdta685', 3, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, oModelTNY )
            oModelTNY:Activate()
            Exit // Encerra o loop pois o registro é cadastrado aqui ou a ação é cancelada
        EndIf

        If nRetorno == 0

            If oModelTNY:VldData()
                If !oModelTNY:CommitData()
                    aErros := oModelTNY:GetErrorMessage()
                EndIf
            Else
                aErros := oModelTNY:GetErrorMessage()
            EndIf

            // Caso o sistema tenha retornado algum erro
            If Len( aErros ) > 0
                lRet := .F.
            EndIf

        EndIf

    End

    If nRetorno != 0
        lRet := .F.
    EndIf

    oModelTNY:DeActivate()

    oModelTNY:Destroy()

    oModelTNY := Nil

    If cFilAnt != cBackup
        cFilAnt := cBackup
    EndIf

Return lRet
