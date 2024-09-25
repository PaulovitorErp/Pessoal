#include 'protheus.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} ngIntegra
Fonte com as integra��es realizadas por parte da NG

@author Gabriel Sokacheski
@since 16/05/2022

@param aParam, cont�m os par�metros que ser�o utilizados na fun��o

/*/
//---------------------------------------------------------------------
Function NgIntegra( aParam )

    Local lRet      := .T. // N�o excluir pois � utilizada no retorno da NgIntegra no GPEA010
    Local lGpea010  := FWIsInCallStack( 'Gpea010' ) // Cadastro de funcion�rio
    Local lGpea030  := FWIsInCallStack( 'Gpea030' ) // Fun��o
    Local lGpem040  := FWIsInCallStack( 'Gpem040' ) // Rescis�o de funcion�rio
    Local lRspm001  := FWIsInCallStack( 'Rspm001' ) // Admiss�o de candidato
    Local lTcfa040  := ( FWIsInCallStack( 'Tcfa040' ) .Or. FWIsInCallStack( 'MdtExe' ) ) // Aprova��o de atestados

    // Caso for chamado pelo m�dulo do GPE e houver integra��o
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
Faz as chamadas das fun��es do processo de cadastro de funcion�rio

@author Luis Fellipy Bett
@since  07/06/2022

@param aParam, cont�m os par�metros que ser�o utilizados na fun��o
    1� Posi��o: Opera��o que est� sendo realizada (inclus�o ou altera��o)
    2� Posi��o: Indica se � admiss�o preliminar
/*/
//---------------------------------------------------------------------
Static Function fCadFun( aParam )

    //Salva a �rea
    Local aArea := GetArea()

    //Vari�veis de par�metros
    Local lMDTAdic := SuperGetMv( "MV_MDTADIC", , .F. )

    //Vari�veis de chamadas
    Local lGPEA180 := FWIsInCallStack( "GPEA180" )

    //Vari�veis de busca das informa��es
    Local nOpc    := aParam[ 1 ]
    Local lAdmPre := aParam[ 2 ]
    Local cVerGPE := ""

    //---------------------------------------------------------
    // Verifica o fluxo a ser seguido de acordo com a opera��o
    //---------------------------------------------------------
    If nOpc == 3 //Inclus�o

        //Inclui a ficha m�dica do funcion�rio
        If FindFunction( "MdtAltTrf" )

            MdtAltTrf( xFilial( "SRA" ), SRA->RA_MAT )

        EndIf

    ElseIf nOpc == 4 //Altera��o

        //Altera a ficha m�dica do funcion�rio (se necess�rio)        
        If FindFunction( "MdtAltFicha" )

            MdtAltFicha( xFilial( "SRA" ), SRA->RA_MAT )

        EndIf

        //Caso os campos estejam na mem�ria
        If IsMemVar( "RA_SITFOLH" ) .And. IsMemVar( "RA_DEMISSA" )

            //Caso o funcion�rio foi demitido
            If ( M->RA_SITFOLH == "D" ) .Or. ( !Empty( M->RA_DEMISSA ) )

                If FindFunction( "MdtDelExames" )

                    //Deleta os exames do funcion�rio
                    MdtDelExames( SRA->RA_MAT, xFilial( "SRA" ), M->RA_DEMISSA )

                EndIf

                If FindFunction( "MdtDelCandCipa" )

                    //Deleta a candidatura da CIPA
                    MdtDelCandCipa( SRA->RA_MAT )

                EndIf

            EndIf

        EndIf

    EndIf

    //Verifica se � o SIGAMDT que ajustar� a insalubridade/periculosidade
    If lMDTAdic

        //Verifica se a fun��o existe no RPO
        If FindFunction( "MDT180AGL" ) .And. SRJ->( ColumnPos( "RJ_CUMADIC" ) ) > 0 .And. Posicione( "SRJ", 1, xFilial( "SRJ" ) + SRA->RA_CODFUNC, "RJ_CUMADIC" ) == "2"

            MDT180AGL( SRA->RA_MAT, "", SRA->RA_FILIAL, nOpc )

        ElseIf FindFunction( "MDT180INT" )

            MDT180INT( SRA->RA_MAT, "", .F., nOpc, SRA->RA_FILIAL )//Preenchimento dos campos de Insalubridade e periculosidade da SRA

        EndIf

    EndIf

    //Integra��o do S-2240 com o SIGATAF/Middleware
    If FindFunction( "MDTIntEsoc" )

        //Busca a vers�o de envio do SIGAGPE
        fVersEsoc( "S2200", .F., , , @cVerGPE )

        //Caso for admiss�o preliminar, o leiaute for maior ou igual ao S-1.0 e n�o for chamada pelo GPEA180
        If lAdmPre .And. !( cVerGPE < "9.0.00" ) .And. !lGPEA180

            //Integra o evento com o TAF/Mid
            MDTIntEsoc( "S-2240", nOpc, Nil, { { SRA->RA_MAT } }, .T. )

        EndIf

    EndIf

    //Retorna a �rea
    RestArea( aArea )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fRescFun
Faz as chamadas das fun��es do processo de rescis�o de funcion�rio

@author Luis Fellipy Bett
@since  07/06/2022

@param aParam, cont�m os par�metros que ser�o utilizados na fun��o
    1� Posi��o: Matr�cula do funcion�rio
    2� Posi��o: Data de demiss�o/rescis�o
/*/
//---------------------------------------------------------------------
Static Function fRescFun( aParam )

    //Salva a �rea
    Local aArea := GetArea()

    //Vari�veis de busca das informa��es
    Local cMatFun := aParam[ 1 ]
    Local dDtResc := aParam[ 2 ]

    If Inclui

        //Finaliza o programa de sa�de e as tarefas do funcion�rio
        fTermFunc( cMatFun, dDtResc )

        //Deleta os exames do funcion�rio
        MdtDelExames( cMatFun, xFilial( "SRA" ), dDtResc )

        //Deleta a candidatura da CIPA do funcion�rio
        MdtDelCandCipa( cMatFun )

        //Retorna a �rea
        RestArea( aArea )

    Else

        //Exclui a data fim da tarefa
        fExcResc( cMatFun, dDtResc )

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fTermFunc
Termina o programa de sa�de e a tarefa do funcion�rio de acordo com a
data de rescis�o.

@author Gabriel Sokacheski
@since  16/05/2022

@param cMatFun, Caracter, Matr�cula do funcion�rio
@param dDtResc, Data, Data de rescis�o de contrato do funcion�rio
/*/
//---------------------------------------------------------------------
Static Function fTermFunc( cMatFun, dDtResc )

    Local aFun := {}
    Local aArea := GetArea()

    Local lGera2240 := SuperGetMV( 'MV_MDTENRE', Nil, .F. )

    //Posiciona na ficha m�dica do funcion�rio para buscar pelo programa de sa�de
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

    //Posiciona nas tarefas do funcion�rio
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

    //Retorna a �rea
    RestArea( aArea )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fExcResc
Caso seja excluido a rescis�o retira a data de fim da tarefa do 
funcion�rio

@author Eloisa Anibaletto
@since 13/04/2023

@param cMatFun, matr�cula do funcion�rio
@param dDtResc, data de rescis�o de contrato do funcion�rio
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
Na altera��o do campo de requisitos, altera os eventos S-2240

@author Gabriel Sokacheski
@since 22/08/2023

@param aParam, cont�m os par�metros que ser�o utilizados na fun��o
    1� Posi��o: Conte�do do campo de requisitos antes da altera��o

/*/
//---------------------------------------------------------------------
Static Function fAltFun( aParam )

    Local aFun      := {}
    Local aAreaSRA  := ( 'SRA' )->( GetArea() )

    Local cVersao   := ''

    Local nEvento   := 0
    Local nEventos  := 0

    Private cReqAnt := aParam[ 1 ]

    // Se a descri��o das atividades no eSocial � correspondente ao campo de requisitos da fun��o
    If SuperGetMv( 'MV_NG2TDES', .F., '1' ) == '3' .And. FindFunction( 'MDTIntEsoc' )

        fVersEsoc( 'S2200', .F., Nil, Nil, @cVersao ) // Busca a vers�o de envio do SIGAGPE

        If !( cVersao < '9.0.00' ) // Se o leiaute for maior ou igual ao S-1.0

            DbSelectArea( 'SRA' )
            ( 'SRA' )->( DbSetOrder( 7 ) )

            If ( 'SRA' )->( DbSeek( xFilial( 'SRA' ) + M->RJ_FUNCAO ) )

                While ( 'SRA' )->( !Eof() .And. SRA->RA_FILIAL + SRA->RA_CODFUNC == xFilial( 'SRA' ) + M->RJ_FUNCAO )

                    nEventos := MdtEsoDatF( SRA->RA_MAT )[ 2 ] // Verifica quantos eventos existem com a fun��o

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
Cria atestado m�dico com as informa��es recebidas do MeuRh (TCFA040)

@author Gabriel Sokacheski
@since  26/04/2023

@sample NGIntegra( { 'D MG 01', '01', '004', 'A00.0', '01', CtoD( '01/08/2023' ), CtoD( '01/08/2023' ), '1', 'NUMID', .F. } )

@param aParam, cont�m os par�metros que ser�o utilizados na fun��o
    1� Posi��o: Filial
    2� Posi��o: Matr�cula
    3� Posi��o: Tipo afastamento
    4� Posi��o: Cid
    5� Posi��o: Motivo afastamento
    6� Posi��o: Data in�cio
    7� Posi��o: Data fim
    8� Posi��o: CRM Emitente
    9� Posi��o: ID da SR8 (imagem do atestado)
    10� Posi��o: Verdadeiro caso aprova��o em lote

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
    Local lExe      := .T. // Primeira execu��o do loop

    Local nDiaAfa   := 0
    Local nRetorno  := 0

    Local oModelTNY := Nil

    Private aMeuRh      := {} // Informa��es do MeuRh

    Private cPrograma   := 'MDTA685'
    Private cSR8NumId   := aAtestado[ 9 ] // Valor para gravar no campo R8_NUMID

    Private lMsErroAuto := .F.

    If cFilAnt != aAtestado[ 1 ]
        cFilAnt := aAtestado[ 1 ]
    EndIf

    cNome   := Posicione( 'SRA', 1, xFilial( 'SRA' ) + aAtestado[ 2 ], 'RA_NOME' )
    cFicha  := Posicione( 'TM0', 11, xFilial( 'TM0' ) + aAtestado[ 2 ], 'TM0_NUMFIC' )
    nDiaAfa := IIf( !Empty( aAtestado[ 7 ] ), DateDiffDay( aAtestado[ 6 ], aAtestado[ 7 ] ) + 1, 0 )

    aAdd( aMeuRh, aAtestado[ 10 ]   ) // Vari�vel l�gica, indica se � aprova��o em lote
    aAdd( aMeuRh, !Empty( cFicha )  ) // Vari�vel l�gica, indica se encontrou a ficha m�dica
    aAdd( aMeuRh, aAtestado[ 2 ]    ) // Vari�vel caractere, matr�cula do funcion�rio em quest�o

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
    // Atestado m�dico
    //-----------------

    // Obrigat�rias
    oModelTNY:LoadValue( 'TNYMASTER1', 'TNY_NUMFIC', cFicha             )
    oModelTNY:SetValue( 'TNYMASTER1', 'TNY_FILIAL', xFilial( 'TNY' )    )

    If !Empty( cFicha )
        oModelTNY:SetValue( 'TNYMASTER1', 'TNY_NOMFIC', cNome )
    EndIf

    oModelTNY:SetValue( 'TNYMASTER1', 'TNY_DTINIC', aAtestado[ 6 ]      )
    oModelTNY:SetValue( 'TNYMASTER1', 'TNY_HRINIC', '00:00'             )
    oModelTNY:SetValue( 'TNYMASTER1', 'TNY_EMITEN', cEmitente           )

    // N�o obrigat�rias
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
            Exit // Encerra o loop pois o registro � cadastrado aqui ou a a��o � cancelada
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
