#include 'mdta156.ch'
#include 'protheus.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} Mdta156
Cadastro de diagn�stico m�dico

@author Gabriel Sokacheski
@since 11/04/2023

/*/
//---------------------------------------------------------------------
Function Mdta156()

    Local oBrowse

    Private aRotina     := {}
    Private MV_MDTGPE   := SuperGetMv( 'MV_MDTGPE'  , .F., 'N'  )
    Private MV_NG2ALTI  := SuperGetMv( 'MV_NG2ALTI' , .F., 'S'  )
    Private MV_NG2COMA  := SuperGetMv( 'MV_NG2COMA' , .F., 'N'  )
    Private MV_NG2DEXC  := SuperGetMv( 'MV_NG2DEXC' , .F., 2    )
    Private MV_NG2ESTN  := SuperGetMv( 'MV_NG2ESTN' , .F., 'N'  )
    Private MV_NG2SEG   := SuperGetMV( 'MV_NG2SEG'  , .F., '2'  )

    If AMiIn( 35 ) // Somente autorizado para SIGAMDT

        oBrowse := FWMBrowse():New()

        oBrowse:SetAlias( 'TMT' )
        oBrowse:SetMenuDef( 'Mdta156' )
        oBrowse:SetDescription( STR0001 ) // "Diagn�stico m�dico"

        If FwIsInCallStack( 'mdta007' )
            oBrowse:SetFilterDefault( 'TMT->TMT_NUMFIC == TM0->TM0_NUMFIC' )
        ElseIf FwIsInCallStack( 'mdta110' )
            oBrowse:SetFilterDefault( 'TMT->TMT_NUMFIC == TM0->TM0_NUMFIC' )
            ccNUMFIC	:= TM0->TM0_NUMFIC //Variavel chamada na fun��o do x3_rela��o 
        EndIf

        If FindFunction( 'MDTX3Tam' )
            MDTX3Tam() //**DEVE SER RETIRADA AP�S LIBERA��O DA PR�XIMA RELEASE 12.1.2410**
        EndIf

        oBrowse:Activate()

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Defini��o do menu

@author Gabriel Sokacheski
@since 11/04/2023

@return aRotina, menu da rotina
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

    aAdd( aRotina, { STR0002, 'ViewDef.Mdta156'                                                                 , 0, 2, 0 } ) // "Visualizar"
    aAdd( aRotina, { STR0003, 'ViewDef.Mdta156'                                                                 , 0, 3, 0 } ) // "Incluir"
    aAdd( aRotina, { STR0004, 'ViewDef.Mdta156'                                                                 , 0, 4, 0 } ) // "Alterar"
    aAdd( aRotina, { STR0005, 'ViewDef.Mdta156'                                                                 , 0, 5, 0 } ) // "Excluir"
    aAdd( aRotina, { STR0006, 'ViewDef.Mdta156'                                                                 , 0, 8, 0 } ) // "Imprimir"
    aAdd( aRotina, { STR0042, 'Mdta685'                                                                         , 0, 6, 0 } ) // "Atestado m�dico"
    aAdd( aRotina, { STR0041, 'Mdtr460'                                                                         , 0, 6, 0 } ) // "Encaminhamento de exames"
    aAdd( aRotina, { STR0029, 'Mdta156His'                                                                      , 0, 6, 0 } ) // "Gravar hist�rico"
    aAdd( aRotina, { STR0039, 'Mdta991( "TMT" )'                                                                , 0, 6, 0 } ) // "Hist. Excl."
    aAdd( aRotina, { STR0013, 'Mdta156a'                                                                        , 0, 6, 0 } ) // "Medicamentos"
    aAdd( aRotina, { STR0051, 'Mdta156Wiz'                                                                      , 0, 6, 0 } ) // "Par�metros"
    aAdd( aRotina, { STR0040, 'Mdtr407( TMT->TMT_NUMFIC, TMT->TMT_DTCONS, TMT->TMT_HRCONS, TMT->TMT_CODUSU )'   , 0, 6, 0 } ) // "Receita m�dica"

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do Modelo

@author Gabriel Sokacheski
@since 11/04/2023

@return oModel, modelo em MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oStructTMT    := FWFormStruct( 1, 'TMT' )
    Local oStructTKJ    := FWFormStruct( 1, 'TKJ' )
	Local oModel        := MPFormModel():New( 'mdta156', Nil, { | oModel | Mdta156Val( oModel ) }, { | oModel | fGrava( oModel ) } )

    // Gatilhos da rotina
    oStructTMT:AddTrigger( 'TMT_NUMFIC',    'TMT_NOMFIC',   { || .T. }, { || TM0->TM0_NOMFIC                                                        } )
    oStructTMT:AddTrigger( 'TMT_NUMFIC',    'TMT_CBO',      { || .T. }, { || Posicione( 'SRJ', 1, xFilial( 'SRJ' ) + TM0->TM0_CODFUN, 'RJ_CBO' )    } )
    oStructTMT:AddTrigger( 'TMT_NUMFIC',    'TMT_CC',       { || .T. }, { || TM0->TM0_CC                                                            } )
    oStructTMT:AddTrigger( 'TMT_NUMFIC',    'TMT_CODFUN',   { || .T. }, { || TM0->TM0_CODFUN                                                        } )
    oStructTMT:AddTrigger( 'TMT_NUMFIC',    'TMT_FILFUN',   { || .T. }, { || TM0->TM0_FILFUN                                                        } )
    oStructTMT:AddTrigger( 'TMT_NUMFIC',    'TMT_MAT',      { || .T. }, { || TM0->TM0_MAT                                                           } )
    oStructTMT:AddTrigger( 'TMT_ACIDEN',    'TMT_CID',      { || .T. }, { || TNC->TNC_CID                                                           } )
    oStructTMT:AddTrigger( 'TMT_ACIDEN',    'TMT_DOENCA',   { || .T. }, { || Posicione( 'TMR', 1, xFilial( 'TMR' ) + TNC->TNC_CID, 'TMR_DOENCA' )   } )
    oStructTMT:AddTrigger( 'TMT_ACIDEN',    'TMT_GRPCID',   { || .T. }, { || ''                                                                     } )
    oStructTMT:AddTrigger( 'TMT_ACIDEN',    'TMT_DESGRP',   { || .T. }, { || ''                                                                     } )
    oStructTMT:AddTrigger( 'TMT_ACIDEN',    'TMT_QTAFAS',   { || .T. }, { || TNC->TNC_QTAFAS                                                        } )
    oStructTMT:AddTrigger( 'TMT_ALTURA',    'TMT_MASSA',    { || .T. }, { || fCalImc()                                                         		} )
    oStructTMT:AddTrigger( 'TMT_PESO',      'TMT_MASSA',    { || .T. }, { || fCalImc()                                                         		} )
    oStructTMT:AddTrigger( 'TMT_TIPDEF',    'TMT_CIDDEF',   { || .T. }, { || IIf( M->TMT_TIPDEF == '0', '', M->TMT_CIDDEF )                         } )
    oStructTMT:AddTrigger( 'TMT_TIPDEF',    'TMT_DOENC3',   { || .T. }, { || IIf( M->TMT_TIPDEF == '0', '', M->TMT_DOENC3 )                         } )

    oStructTKJ:AddTrigger( 'TKJ_GRPCID',    'TKJ_DESGRP', { || .T. }, { || Posicione( 'TLG', 1, xFilial( 'TLG' ) + M->TKJ_GRPCID, 'TLG_DESCRI' )    } )
    oStructTKJ:AddTrigger( 'TKJ_CID',       'TKJ_DOENCA', { || .T. }, { || Posicione( 'TMR', 1, xFilial( 'TMR' ) + M->TKJ_CID, 'TMR_DOENCA' )       } )

    oModel:AddFields( 'TMTMASTER', Nil, oStructTMT )
    oModel:AddGrid( 'TKJDETAIL', 'TMTMASTER', oStructTKJ )
    oModel:SetRelation(;
        'TKJDETAIL', {;
            { 'TKJ_FILIAL', 'xFilial( "TKJ" )' },;
            { 'TKJ_NUMFIC', 'TMT_NUMFIC' },;
            { 'TKJ_DTCONS', 'TMT_DTCONS' },;
            { 'TKJ_HRCONS', 'TMT_HRCONS' };
        },;
        ( 'TKJ' )->( IndexKey( 1 ) );
    )
    oModel:GetModel( 'TKJDETAIL' ):SetOptional( .T. )
    oModel:SetDescription( STR0001 ) // "Diagn�stico m�dico"
    oModel:GetModel( 'TMTMASTER' ):SetDescription( STR0001 ) // "Diagn�stico m�dico"
    oModel:GetModel( 'TKJDETAIL' ):SetDescription( STR0053 ) // "CID Complementar"
    oModel:SetVldActivate( { | oModel | fAlteracao( oModel ) } )

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o da view

@author Gabriel Sokacheski
@since 11/04/2023

@return oView, view em MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

    Local oModel        := FWLoadModel( 'mdta156' )
    Local oStructTMT    := FWFormStruct( 2, 'TMT' )
    Local oStructTKJ    := FWFormStruct( 2, 'TKJ' )
    Local oView         := FWFormView():New()

    oView:SetModel( oModel )
    oView:AddField( 'VIEW_TMT', oStructTMT, 'TMTMASTER' )
    oView:AddGrid( 'VIEW_TKJ', oStructTKJ, 'TKJDETAIL' )
    oView:CreateHorizontalBox( 'SUPERIOR', 70 )
    oView:CreateHorizontalBox( 'INFERIOR', 30 )
    oView:SetOwnerView( 'VIEW_TMT', 'SUPERIOR' )
    oView:SetOwnerView( 'VIEW_TKJ', 'INFERIOR' )

    oStructTKJ:RemoveField( 'TKJ_NUMFIC' )
    oStructTKJ:RemoveField( 'TKJ_DTCONS' )
    oStructTKJ:RemoveField( 'TKJ_HRCONS' )

Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} fGrava
Realiza grava��o dos dados

@author Gabriel Sokacheski
@since 15/06/2023

@return lRet, Indica se os dados foram gravados
/*/
//---------------------------------------------------------------------
Static Function fGrava( oModel )

    Local lRet := .F.

    If FWFormCommit( oModel )

        lRet := .T.

        // Envia email
        If MV_NG2COMA == 'S' .And. TMT->TMT_QTAFAS > 0 .And. !Empty( TMT->TMT_ACIDEN ) .And. !Empty( TM0->TM0_MAT )
			fEMAILDIAG()
		EndIf

    Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fAlteracao
Bloqueia a altera��o e exclus�o dos registros de acordo com o
par�metro MV_NG2ALTI e MV_NG2SEG.

@author Gabriel Sokacheski
@since 17/04/2023

@param, oModel, modelo em MVC

@return lRet, retorno das valida��es realizadas
/*/
//-------------------------------------------------------------------
Static Function fAlteracao( oModel )

    Local aAreaTmk      := ( 'TMK' )->( GetArea() )

    Local lRet          := .T.

    If oModel:GetOperation() == 5 // Exclus�o

        If MV_NG2SEG != '2' .And. Date() > DaySum( MdtDataLo( 'TMT->TMT_USERGI' ), MV_NG2DEXC )

            //---------------------------------------------------------------
            // Mensagens:
            // "Aten��o"
            // "O per�odo em que � permitido a exclus�o do registro j� se encerrou"
            // "Altere o conte�do do par�metro"
            //---------------------------------------------------------------

            Help( Nil, Nil, STR0008, Nil, STR0012 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0010 + Space( 1 ) + 'MV_NG2DEXC' + '.' } )

            lRet := .F.

        EndIf

    EndIf

    If lRet .And. oModel:GetOperation() == 4 .Or. oModel:GetOperation() == 5 // Altera��o ou exclus�o

        If MV_NG2ALTI != 'S'

            //---------------------------------------------------------------
            // Mensagens:
            // "Aten��o"
            // "O diagn�stico n�o pode ser alterado ou exclu�do"
            // "Altere o conte�do do par�metro"
            //---------------------------------------------------------------

            Help( Nil, Nil, STR0008, Nil, STR0009 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0010 + Space( 1 ) + 'MV_NG2ALTI' + '.' } )

            lRet := .F.

        EndIf

        If lRet

            If MV_NG2SEG != '2'

                DbSelectArea( 'TMK' )
                ( 'TMK' )->( DbSetOrder( 1 ) )

                If ( 'TMK' )->( DbSeek( xFilial( "TMK" ) + TMT->TMT_CODUSU ) )

                    If AllTrim( cUserName ) != AllTrim( MdtDataLo( 'TMT->TMT_USERGI', .F. ) );
                    .Or. AllTrim( cUserName ) != AllTrim( TMK->TMK_USUARI )

                        //---------------------------------------------------------------
                        // Mensagens:
                        // "Aten��o"
                        // "Usu�rio sem permiss�o para alterar ou excluir o registro"
                        // "Altere o conte�do do par�metro"
                        //---------------------------------------------------------------

                        Help( Nil, Nil, STR0008, Nil, STR0011 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0010 + Space( 1 ) + 'MV_NG2SEG' + '.' } )

                        lRet := .F.

                    EndIf

                EndIf

            EndIf

        EndIf

    EndIf

    RestArea( aAreaTmk )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Mdta156Val
Fun��o que realiza a p�s valida��o do modelo de dados ( TudoOk )

@author Gabriel Sokacheski
@since 17/04/2023

@param, oModel, modelo em MVC

@return lRet, retorno da valida��o do modelo
/*/
//-------------------------------------------------------------------
Function Mdta156Val( oModel )

    Local aAreaSra := ( 'SRA' )->( GetArea() )
    Local aAreaTmj := ( 'TMJ' )->( GetArea() )
    Local aAreaTm0 := ( 'TM0' )->( GetArea() )
    Local aAreaTmy := ( 'TMY' )->( GetArea() )
    Local aAreaTna := ( 'TNA' )->( GetArea() )
    Local aAreaTnc := ( 'TNC' )->( GetArea() )

    Local lRet      := .T.

    Local oMaster   := oModel:GetModel( 'TMTMASTER' )

    //------------
    // Valida��es
    //------------

    If oModel:GetOperation() == 3

        If ExistCpo( 'TMT', oMaster:GetValue( 'TMT_NUMFIC' ) + DtoS( oMaster:GetValue( 'TMT_DTCONS' ) ) + oMaster:GetValue( 'TMT_HRCONS' ), 3 )

            //---------------------------------------------------------------
            // Mensagens:
            // "Aten��o"
            // "O diagn�stico com essas informa��es j� existe"
            // "Procure pelo registro j� existente"
            //---------------------------------------------------------------
            Help( Nil, Nil, STR0008, Nil, STR0037 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0038 + '.' } )

            lRet := .F.

        EndIf

    EndIf

    //--------------------------------------------------------------------
    // Altera��es realizadas ap�s as opera��es, manter no final da fun��o
    //--------------------------------------------------------------------

    If lRet

        If oModel:GetOperation() == 5 // Exclus�o

            // Exclui poss�vel atendimento agendado
            DbSelectArea( 'TMJ' )
            ( 'TMJ' )->( DbSetOrder( 1 ) )

            If ( 'TMJ' )->( Dbseek( xFilial( 'TMJ' ) + oMaster:GetValue( 'TMT_CODUSU' ) + DtoS( oMaster:GetValue( 'TMT_DTCONS' ) ) + oMaster:GetValue( 'TMT_HRCONS' ) ) )

                Dbselectarea( 'TMY' )
                ( 'TMY' )->( Dbsetorder( 3 ) )

                If !( 'TMY' )->( DbSeek( xFilial( 'TMY' ) + TMJ->TMJ_NUMFIC + DtoS( TMJ->TMJ_DTPROG ) ) )

                    RecLock( 'TMJ', .F. )
                        TMJ->TMJ_DTATEN := StoD( Space( 8 ) )
                    ( 'TMY' )->( MsUnlock() )

                EndIf

            EndIf

            // Exclui poss�vel cadastro de doen�a
            fExcCidDoe( oMaster )

        Else // Qualquer opera��o diferente de exclus�o

            DbSelectArea( 'TM0' )
            ( 'TM0' )->( DbSetOrder( 1 ) )

            If ( 'TM0' )->( DbSeek( xFilial( 'TM0' ) + oMaster:GetValue( 'TMT_NUMFIC' ) ) )

                RecLock( 'TM0', .F. )

                    If oMaster:IsFieldUpdated( 'TMT_PESO' )
                        TM0->TM0_PESO := oMaster:GetValue( 'TMT_PESO' )
                    EndIf

                    If oMaster:IsFieldUpdated( 'TMT_ALTURA' )
                        TM0->TM0_ALTURA := oMaster:GetValue( 'TMT_ALTURA' )
                    EndIf

                    If oMaster:IsFieldUpdated( 'TMT_TIPDEF' )
                        TM0->TM0_TIPDEF := oMaster:GetValue( 'TMT_TIPDEF' )
                    EndIf

                ( 'TM0' )->( MsUnLock() )

                If MV_MDTGPE == 'S' .And. oMaster:IsFieldUpdated( 'TMT_TIPDEF' )

                    DbSelectArea( 'SRA' )
                    ( 'SRA' )->( DbSetOrder( 1 ) )

                    If ( 'SRA' )->( DbSeek( TM0->TM0_FILFUN + TM0->TM0_MAT ) )

                        RecLock( 'SRA', .F. )
                            SRA->RA_TPDEFFI := oMaster:GetValue( 'TMT_TIPDEF' )
                        ( 'SRA' )->( MsUnlock() )

                    EndIf

                EndIf

            EndIf

        EndIf

        If oModel:GetOperation() == 4 // Altera��o

            fAtuCidDoe( 'TMT_CID', TMT->TMT_CID, oMaster )

        EndIf

    EndIf

    RestArea( aAreaSra )
    RestArea( aAreaTmj )
    RestArea( aAreaTmy )
    RestArea( aAreaTm0 )
    RestArea( aAreaTna )
    RestArea( aAreaTnc )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fAtuCidDoe
Atualiza o CID do cadastro de doen�as (TNA)

@author Gabriel Sokacheski
@since 24/04/2023

@param, cCampo, nome do campo
@param, cDoeOri, c�digo da doen�a original antes da altera��o
@param, oMaster, objeto do modelo de dados

/*/
//-------------------------------------------------------------------
Static Function fAtuCidDoe( cCampo, cDoeOri, oMaster )

    If oMaster:IsFieldUpdated( cCampo ) .And. !Empty( oMaster:GetValue( cCampo ) )

        DbSelectArea( 'TNA' )
        ( 'TNA' )->( DbSetOrder( 1 ) )

        If ( 'TNA' )->( DbSeek( xFilial( 'TNA' ) + oMaster:GetValue( 'TMT_NUMFIC' ) + cDoeOri + DtoS( oMaster:GetValue( 'TMT_DTCONS' ) ) ) )

            RecLock( 'TNA', .F. )
                TNA->TNA_CID    := oMaster:GetValue( cCampo )
            ( 'TNA' )->( MsUnLock() )

        EndIf

    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fExcCidDoe
Exclui o registro do cadastro de doen�as (TNA)

@author Gabriel Sokacheski
@since 24/04/2023

@param, oMaster, objeto do modelo de dados

/*/
//-------------------------------------------------------------------
Static Function fExcCidDoe( oMaster )

    If !Empty( oMaster:GetValue( 'TMT_CID' ) )

        DbSelectArea( 'TNA' )
        ( 'TNA' )->( DbSetOrder( 1 ) )

        If ( 'TNA' )->( DbSeek( xFilial( 'TNA' ) + oMaster:GetValue( 'TMT_NUMFIC' ) + oMaster:GetValue( 'TMT_CID' ) + DtoS( oMaster:GetValue( 'TMT_DTCONS' ) ) ) )

            RecLock( 'TNA', .F. )
                ( 'TNA' )->( DbDelete() )
            ( 'TNA' )->( MsUnLock() )

        EndIf

    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Mdta156X3V
Fun��o utilizada no X3_VALID dos campos da rotina

@author Gabriel Sokacheski
@since 25/04/2023

@param cCampo, nome do campo a ser validado

@return lRet, retorno da valida��o do campo
/*/
//-------------------------------------------------------------------
Function Mdta156X3V( cCampo )

    Local lRet      := .T.

    Local oModel    := Nil
    Local oGrid     := Nil
    Local oMaster   := Nil

    If !FwIsInCallStack( 'MDTA410' )
        oModel  := FwModelActive()
        oMaster := oModel:GetModel( 'TMTMASTER' )
        oGrid   := oModel:GetModel( 'TKJDETAIL' )
    EndIf

    If !Empty( &( 'M->' + cCampo ) )

        Do Case
            Case cCampo == 'TMT_NUMFIC'
                fFicha( @lRet )
            Case cCampo == 'TMT_HRRETO'
                fHorRet( @lRet )
            Case cCampo == 'TMT_CODUSU'
                fUsuario( @lRet )
            Case cCampo == 'TMT_DTATEN'
                fDatAte( @lRet )
            Case cCampo == 'TMT_DTCONS'
                fDatCon( @lRet )
            Case cCampo == 'TMT_PRESIS'
                lRet := Positivo()
            Case cCampo == 'TMT_PREDIS'
                lRet := Positivo()
            Case cCampo == 'TMT_OCORRE'
                lRet := Pertence( '123456' )
            Case cCampo == 'TMT_TIPDEF'
                lRet := Pertence( '0123456' )
            Case cCampo == 'TMT_ACIDEN'
                lRet := ExistCpo( 'TNC', M->TMT_ACIDEN )
            Case cCampo == 'TMT_CODUSA'
                lRet := ExistCpo( 'TMK', M->TMT_CODUSA )
            Case cCampo == 'TMT_CID'
                fValCid( @lRet )
            Case cCampo == 'TMT_GRPCID'
                fValGruCid( @lRet )
            Case cCampo == 'TMT_CIDDEF'
                lRet := ExistCpo( 'TMR', M->TMT_CIDDEF )
            Case cCampo == 'TMT_HRCONS'
                fHora( @lRet, AllTrim( M->TMT_HRCONS ) )
            Case cCampo == 'TMT_HRATEN'
                fHora( @lRet, AllTrim( M->TMT_HRATEN ) )
            Case cCampo == 'TM2_CODMED'
                lRet := ExistCpo( 'TM1', M->TM2_CODMED )
            Case cCampo == 'TKJ_GRPCID'
                fValGruCom( @lRet, oGrid )
            Case cCampo == 'TKJ_CID'
                fValCidCom( @lRet, oMaster, oGrid )
        End Case

    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fValCid
Valida o campo TMT_CID

@author Gabriel Sokacheski
@since 30/08/2023

@param, lRet, retorno da fun��o

/*/
//-------------------------------------------------------------------
Static Function fValCid( lRet )

    lRet := ExistCpo( 'TMR', M->TMT_CID )

    If lRet .And. !Empty( M->TMT_GRPCID )

        If M->TMT_GRPCID != SubStr( M->TMT_CID, 1, 3 )

            //---------------------------------------------------------------
            // Mensagens:
            // "Aten��o"
            // "O CID n�o pertence ao grupo de CID informado"
            // "Informe um CID correspondente ao grupo de CID informado"
            //---------------------------------------------------------------
            Help( Nil, Nil, STR0008, Nil, STR0021 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0022 + '.' } )

            lRet := .F.

        EndIf

    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fValGruCid
Valida o campo TMT_CID

@author Gabriel Sokacheski
@since 30/08/2023

@param, lRet, retorno da fun��o

/*/
//-------------------------------------------------------------------
Static Function fValGruCid( lRet )

    lRet := ExistCpo( 'TLG', M->TMT_GRPCID )

    If lRet .And. !Empty( M->TMT_CID )

        If M->TMT_GRPCID != SubStr( M->TMT_CID, 1, 3 )

            //---------------------------------------------------------------
            // Mensagens:
            // "Aten��o"
            // "O CID n�o pertence ao grupo de CID informado"
            // "Informe um CID correspondente ao grupo de CID informado"
            //---------------------------------------------------------------
            Help( Nil, Nil, STR0008, Nil, STR0021 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0022 + '.' } )

            lRet := .F.

        EndIf

    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fValGruCom
Valida o campo TKJ_GRPCID

@author Gabriel Sokacheski
@since 19/06/2023

@param, lRet, retorno da fun��o
@param, oMaster, objeto do modelo

/*/
//-------------------------------------------------------------------
Static Function fValGruCom( lRet, oGrid )

    lRet := ExistCpo( 'TLG', oGrid:GetValue( 'TKJ_GRPCID' ) )

    If lRet .And. !Empty( oGrid:GetValue( 'TKJ_CID' ) )

        If oGrid:GetValue( 'TKJ_GRPCID' ) != SubStr( oGrid:GetValue( 'TKJ_CID' ), 1, 3 )

            //-------------------------------------------------------------------
            // Mensagens:
            // "Aten��o"
            // "Esta doen�a n�o pertence ao grupo informado"
            // "Informe uma doen�a pertencente ao grupo informado anteriormente"
            //-------------------------------------------------------------------
            Help( Nil, Nil, STR0008, Nil, STR0058 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0059 + '.' } )

            lRet := .F.

        EndIf

    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fValCidCom
Valida o campo TKJ_CID

@author Gabriel Sokacheski
@since 19/06/2023

@param, lRet, retorno da fun��o
@param, oMaster, objeto do modelo
@param, oGrid, grid do modelo

/*/
//-------------------------------------------------------------------
Static Function fValCidCom( lRet, oMaster, oGrid )

    Local cCidAtu       := oGrid:GetValue( 'TKJ_CID' )

    Local nRegAtu       := oGrid:GetLine()
    Local nRegistro     := 0
    Local nRegistros    := oGrid:Length()

    lRet := ExistCpo( 'TMR', oGrid:GetValue( 'TKJ_CID' ) )

    If lRet .And. Empty( oMaster:GetValue( 'TMT_CID' ) ) .And. !Empty( oMaster:GetValue( 'TMT_GRPCID' ) )

        If oMaster:GetValue( 'TMT_GRPCID' ) == SubStr( oGrid:GetValue( 'TKJ_CID' ), 1, 3 )

            //-------------------------------------------------------------------------------------------------------------
            // Mensagens:
            // "Aten��o"
            // "No diagn�stico j� foi informado o grupo correspondente a essa doen�a, sem que a doen�a fosse especificada"
            // "Informe esta doen�a no pr�prio diagn�stico"
            //-------------------------------------------------------------------------------------------------------------
            Help( Nil, Nil, STR0008, Nil, STR0054 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0055 + '.' } )

            lRet := .F.

        EndIf

    EndIf

    If lRet .And. !Empty( oMaster:GetValue( 'TMT_CID' ) )

        If oGrid:GetValue( 'TKJ_CID' ) == oMaster:GetValue( 'TMT_CID' )

            //--------------------------------------------------------
            // Mensagens:
            // "Aten��o"
            // "Esta doen�a j� foi informada no diagn�stico"
            // "N�o � necess�rio cadastrar novamente esta informa��o"
            //--------------------------------------------------------
            Help( Nil, Nil, STR0008, Nil, STR0056 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0057 + '.' } )

            lRet := .F.

        EndIf

    EndIf

    If lRet .And. !Empty( oGrid:GetValue( 'TKJ_GRPCID' ) )

        If oGrid:GetValue( 'TKJ_GRPCID' ) != SubStr( oGrid:GetValue( 'TKJ_CID' ), 1, 3 )

            //-------------------------------------------------------------------
            // Mensagens:
            // "Aten��o"
            // "Esta doen�a n�o pertence ao grupo informado"
            // "Informe uma doen�a pertencente ao grupo informado anteriormente"
            //-------------------------------------------------------------------
            Help( Nil, Nil, STR0008, Nil, STR0058 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0059 + '.' } )

            lRet := .F.

        EndIf

    EndIf

    If lRet .And. nRegistros > 1

        For nRegistro := 1 To nRegistros

            oGrid:GoLine( nRegistro )

            If nRegistro != nRegAtu .And. cCidAtu == oGrid:GetValue( 'TKJ_CID' )

                //-------------------------------------------------------------------
                // Mensagens:
                // "Aten��o"
                // "O CID j� foi informado anteriormente como CID complementar"
                // "N�o � necess�rio cadastrar novamente esta informa��o"
                //-------------------------------------------------------------------
                Help( Nil, Nil, STR0008, Nil, STR0060 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0057 + '.' } )

                lRet := .F.
                Exit

            EndIf

        Next nRegistro

        oGrid:GoLine( nRegAtu )

    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fDatCon
Valida o campo TMT_DTCONS

@author Gabriel Sokacheski
@since 28/04/2023

@param, lRet, retorno da fun��o

/*/
//-------------------------------------------------------------------
Static Function fDatCon( lRet )

    If !Empty( M->TMT_DTATEN ) .And. M->TMT_DTATEN < M->TMT_DTCONS

        //---------------------------------------------------------------
        // Mensagens:
        // "Aten��o"
        // "A data de atendimento � menor do que a data da consulta"
        // "Informe uma data menor"
        //---------------------------------------------------------------
        Help( Nil, Nil, STR0008, Nil, STR0026 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0027 + '.' } )

        lRet := .F.

    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fDatAte
Valida o campo TMT_DTATEN

@author Gabriel Sokacheski
@since 28/04/2023

@param, lRet, retorno da fun��o

/*/
//-------------------------------------------------------------------
Static Function fDatAte( lRet )

    If !Empty( M->TMT_DTCONS ) .And. M->TMT_DTATEN < M->TMT_DTCONS

        //---------------------------------------------------------------
        // Mensagens:
        // "Aten��o"
        // "A data de atendimento � menor do que a data da consulta"
        // "Informe uma data maior"
        //---------------------------------------------------------------
        Help( Nil, Nil, STR0008, Nil, STR0026 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0028 + '.' } )

        lRet := .F.

    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fUsuario
Valida o campo TMT_CODUSU

@author Gabriel Sokacheski
@since 28/04/2023

@param, lRet, retorno da fun��o

/*/
//-------------------------------------------------------------------
Static Function fUsuario( lRet )

    Local aArea := ( 'TMK' )->( GetArea() )

    lRet := ExistCpo( 'TMK', M->TMT_CODUSU )

    If lRet

        DbSelectArea( 'TMK' )
        ( 'TMK' )->( DbSetOrder( 1 ) )

        If DbSeek( xFilial( 'TMK' ) + M->TMT_CODUSU )

            If TMK->TMK_SESMT != '1'

                //---------------------------------------------------------------
                // Mensagens:
                // "Aten��o"
                // "O usu�rio informado n�o comp�e o sesmt"
                // "Informe um usu�rio que comp�e o sesmt"
                //---------------------------------------------------------------
                Help( Nil, Nil, STR0008, Nil, STR0023 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0024 + '.' } )

                lRet := .F.

            ElseIf !Empty( TMK->TMK_DTTERM ) .And. Date() > TMK->TMK_DTTERM

                //---------------------------------------------------------------
                // Mensagens:
                // "Aten��o"
                // "O usu�rio informado n�o comp�e mais o sesmt"
                // "Informe um usu�rio que comp�e o sesmt"
                //---------------------------------------------------------------
                Help( Nil, Nil, STR0008, Nil, STR0025 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0024 + '.' } )

                lRet := .F.

            EndIf

        EndIf

    EndIf

    RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fHorRet
Valida o campo TMT_HRRETO

@author Gabriel Sokacheski
@since 25/04/2023

@param, lRet, retorno da fun��o

/*/
//-------------------------------------------------------------------
Static Function fHorRet( lRet )

    lRet := fHora( @lRet, AllTrim( M->TMT_HRRETO ) )

    If lRet .And. M->TMT_HRRETO < M->TMT_HRATEN

        //---------------------------------------------------------------
        // Mensagens:
        // "Aten��o"
        // "O hor�rio de retorno � menor que o de atendimento"
        // "Informar um hor�rio de retorno maior que o de atendimento"
        //---------------------------------------------------------------
        Help( Nil, Nil, STR0008, Nil, STR0019 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0020 + '.' } )

        lRet := .F.

    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fFicha
Valida o campo TMT_NUMFIC

@author Gabriel Sokacheski
@since 25/04/2023

@param, lRet, retorno da fun��o

/*/
//-------------------------------------------------------------------
Static Function fFicha( lRet )

    lRet := ExistCpo( 'TM0', M->TMT_NUMFIC )

    If lRet
        lRet := fSitFun( M->TMT_NUMFIC )
    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fHora
Valida os campos de hora

@author Gabriel Sokacheski
@since 25/04/2023

@param, lRet, retorno da valida��o
@param, cHora, campo de hora

/*/
//-------------------------------------------------------------------
Static Function fHora( lRet, cHora )

    Local nCorte    := At( ':', cHora )
    Local nHora     := Val( SubStr( cHora, 1, ( nCorte - 1 ) ) )
    Local nMinuto   := Val( SubStr( cHora, ( nCorte + 1 ) ) )

    If '-' $ cHora

        //---------------------------------------------------------------
        // Mensagens:
        // "Aten��o"
        // "Hora inv�lida"
        // "Remova o sinal negativo do campo"
        //---------------------------------------------------------------
        Help( Nil, Nil, STR0008, Nil, STR0016 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0017 + '.' } )

        lRet := .F.

    ElseIf ( nHora > 24 .Or. nMinuto > 59 ) .Or. Len( cHora ) != 5

        //---------------------------------------------------------------
        // Mensagens:
        // "Aten��o"
        // "Hora inv�lida"
        // "Informe uma hora v�lida"
        //---------------------------------------------------------------
        Help( Nil, Nil, STR0008, Nil, STR0016 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0018 + '.' } )

        lRet := .F.

    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fSitFun
Verifica a situa��o do funcion�rio

@author Gabriel Sokacheski
@since 27/04/2023

@param cFicha, ficha m�dica do funcion�rio

@return lRet, retorno da valida��o
/*/
//-------------------------------------------------------------------
Static Function fSitFun( cFicha )

    Local aArea := ( 'SRA' )->( GetArea() )

    Local lRet := .T.

    DbSelectArea( 'TM0' )
    ( 'TM0' )->( DbSetOrder( 1 ) )

    If ( 'TM0' )->( DbSeek( xFilial( 'TM0' ) + cFicha ) )

        DbSelectArea( 'SRA' )
        ( 'SRA' )->( DbSetOrder( 1 ) )

        If ( 'SRA' )->( DbSeek( TM0->TM0_FILFUN + TM0->TM0_MAT ) )

            If SRA->RA_SITFOLH == 'T' .Or. SRA->RA_RESCRAI $ '30/31'

                //----------------------------------------------------------------
                // Mensagens:
                // "Aten��o"
                // "O funcion�rio foi transferido. Deseja continuar mesmo assim?"
			    //----------------------------------------------------------------
                lRet := MsgYesNo( STR0014, STR0008 )

            ElseIf SRA->RA_SITFOLH == 'D' .Or. !Empty( SRA->RA_DEMISSA )

                //----------------------------------------------------------------
                // Mensagens:
                // "Aten��o"
                // "O funcion�rio foi demitido. Deseja continuar mesmo assim?"
			    //----------------------------------------------------------------
                lRet := MsgYesNo( STR0015, STR0008 )

            EndIf

        EndIf

    EndIf

    RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Mdta156X3R
Fun��o utilizada no X3_RELACAO dos campos da rotina

@author Gabriel Sokacheski
@since 25/04/2023

@param cCampo, nome do campo a ser verificado

@return xValor, valor a ser recebido pelo campo
/*/
//-------------------------------------------------------------------
Function Mdta156X3R( cCampo )

    Local xValor := ''

    If Inclui
        Do Case
            Case cCampo == 'TMT_DTCONS'
                xValor := Date()
            Case cCampo == 'TMT_DTATEN'
                xValor := Date()
            Case cCampo == 'TMT_HRCONS'
                xValor := Time()
            Case cCampo == 'TMT_HRATEN'
                xValor := Time()
            Case cCampo == 'TMT_OCORRE'
                xValor := '1'
            Case cCampo == 'TMT_TIPDEF'
                xValor := '0'
            Case cCampo == 'TMT_NUMFIC'
                If FwIsInCallStack( 'mdta007' )
                    xValor := TM0->TM0_NUMFIC
                Else
                    xValor := ''
                EndIf
            Case cCampo == 'TMT_CBO'
                If FwIsInCallStack( 'mdta007' )
                    xValor := Posicione( 'SRJ', 1, xFilial( 'SRJ' ) + TM0->TM0_CODFUN, 'RJ_CBO' )
                Else
                    xValor := ''
                EndIf
            Case cCampo == 'TMT_CC'
                If FwIsInCallStack( 'mdta007' )
                    xValor := TM0->TM0_CC
                Else
                    xValor := ''
                EndIf
            Case cCampo == 'TMT_CODFUN'
                If FwIsInCallStack( 'mdta007' )
                    xValor := TM0->TM0_CODFUN
                Else
                    xValor := ''
                EndIf
            Case cCampo == 'TMT_FILFUN'
                If FwIsInCallStack( 'mdta007' )
                    xValor := TM0->TM0_FILFUN
                Else
                    xValor := ''
                EndIf
            Case cCampo == 'TMT_MAT'
                If FwIsInCallStack( 'mdta007' )
                    xValor := TM0->TM0_MAT
                Else
                    xValor := ''
                EndIf
            Case cCampo == 'TMT_NOMUSU'
                xValor := ''
            Case cCampo == 'TMT_NOMFIC'
                If FwIsInCallStack( 'mdta007' )
                    xValor := TM0->TM0_NOMFIC
                Else
                    xValor := ''
                EndIf
            Case cCampo == 'TMT_DESGRP'
                xValor := ''
            Case cCampo == 'TMT_DOENCA'
                xValor := ''
            Case cCampo == 'TMT_DESACI'
                xValor := ''
            Case cCampo == 'TMT_QTAFAS'
                xValor := 0
            Case cCampo == 'TMT_DOENC3'
                If FwIsInCallStack( 'mdta007' )
                    xValor := Posicione( 'TMR', 1, xFilial( 'TMR' ) + TM0->TM0_CODCID, 'TMR_DOENCA' )
                Else
                    xValor := ''
                EndIf
            Case cCampo == 'TMT_CIDDEF'
                If FwIsInCallStack( 'mdta007' )
                    xValor := TM0->TM0_CODCID
                Else
                    xValor := ''
                EndIf
            Case cCampo == 'TM2_NUMFIC'
                xValor := TMT->TMT_NUMFIC
            Case cCampo == 'TM2_NOMFIC'
                xValor := Posicione( 'TM0', 1, xFilial( 'TM0' ) + TMT->TMT_NUMFIC, 'TM0_NOMFIC' )
            Case cCampo == 'TM2_DTCONS'
                xValor := TMT->TMT_DTCONS
            Case cCampo == 'TM2_HRCONS'
                xValor := TMT->TMT_HRCONS
            Case cCampo == 'TM2_SEQMOV'
                xValor := GetSxEnum( 'TM2', 'TM2_SEQMOV' )
            Case cCampo == 'TM2_NOMEDI'
                xValor := ''
            Case cCampo == 'TM2_DESUNI'
                xValor := ''
            Case cCampo == 'TM2_INDREC'
                xValor := '1'
            Case cCampo == 'TKJ_DESGRP'
                xValor := ''
            Case cCampo == 'TKJ_DOENCA'
                xValor := ''
            Case cCampo == 'TMT_MHISPR'
                xValor := ''
            Case cCampo == 'TMT_MDIAGN'
                xValor := ''
            Case cCampo == 'TMT_MDESAT'
                xValor := ''
            Case cCampo == 'TMT_MQUEIX'
                xValor := ''
            Case cCampo == 'TMT_MHDA'
                xValor := ''
            Case cCampo == 'TMT_MCABEC'
                xValor := ''
            Case cCampo == 'TMT_MOLHOS'
                xValor := ''
            Case cCampo == 'TMT_MOUVID'
                xValor := ''
            Case cCampo == 'TMT_MPESCO'
                xValor := ''
            Case cCampo == 'TMT_MAPRES'
                xValor := ''
            Case cCampo == 'TMT_MAPDIG'
                xValor := ''
            Case cCampo == 'TMT_MAPCIR'
                xValor := ''
            Case cCampo == 'TMT_MAPURI'
                xValor := ''
            Case cCampo == 'TMT_MMIS'
                xValor := ''
            Case cCampo == 'TMT_MPELE'
                xValor := ''
            Case cCampo == 'TMT_MEXAME'
                xValor := ''
            Case cCampo == 'TMT_MOROFA'
                xValor := ''
            Case cCampo == 'TMT_MOTOSC'
                xValor := ''
            Case cCampo == 'TMT_MABDOM'
                xValor := ''
            Case cCampo == 'TMT_MAUSCA'
                xValor := ''
            Case cCampo == 'TMT_MAUSPU'
                xValor := ''
        EndCase
    Else
        Do Case
            Case cCampo == 'TMT_NOMFIC'
                xValor := Posicione( 'TM0', 1, xFilial( 'TM0' ) + TMT->TMT_NUMFIC, 'TM0_NOMFIC' )
            Case cCampo == 'TMT_NOMUSU'
                xValor := Posicione( 'TMK', 1, xFilial( 'TMK' ) + TMT->TMT_CODUSU, 'TMK_NOMUSU' )
            Case cCampo == 'TMT_DESGRP'
                xValor := Posicione( 'TLG', 1, xFilial( 'TLG' ) + TMT->TMT_GRPCID, 'TLG_DESCRI' )
            Case cCampo == 'TMT_DOENCA'
                xValor := Posicione( 'TMR', 1, xFilial( 'TMR' ) + TMT->TMT_CID, 'TMR_DOENCA' )
            Case cCampo == 'TMT_DESACI'
                xValor := Posicione( 'TNC', 1, xFilial( 'TNC' ) + TMT->TMT_ACIDEN, 'TNC_DESACI' )
            Case cCampo == 'TMT_DOENC3'
                xValor := Posicione( 'TMR', 1, xFilial( 'TMR' ) + TMT->TMT_CIDDEF, 'TMR_DOENCA' )
            Case cCampo == 'TM2_NOMFIC'
			    xValor := Posicione( 'TM0', 1, xFilial( 'TM0' ) + TMT->TMT_NUMFIC, 'TM0_NOMFIC' )
            Case cCampo == 'TM2_NOMEDI'
                xValor := Posicione( 'TM1', 1, xFilial( 'TM2' ) + TM2->TM2_CODMED, 'TM1_NOMEDI' )
            Case cCampo == 'TM2_DESUNI'
                xValor := Posicione( 'SX5', 1, xFilial( 'SX5' ) + '62' + TM2->TM2_UNIDAD, 'X5_DESCRI' )
            Case cCampo == 'TKJ_DESGRP'
                xValor := Posicione( 'TLG', 1, xFilial( 'TLG' ) + TKJ->TKJ_GRPCID, 'TLG_DESCRI' )
            Case cCampo == 'TKJ_DOENCA'
                xValor := Posicione( 'TMR', 1, xFilial( 'TMR' ) + TKJ->TKJ_CID, 'TMR_DOENCA' )
        EndCase
    EndIf

Return xValor

//-------------------------------------------------------------------
/*/{Protheus.doc} Mdta156X3W
Fun��o utilizada no X3_WHEN dos campos da rotina

@author Gabriel Sokacheski
@since 25/04/2023

@param cCampo, nome do campo a ser verificado

@return lRet, retorno da permiss�o para edi��o
/*/
//-------------------------------------------------------------------
Function Mdta156X3W( cCampo )

    Local lRet      := .T.

    Do Case
        Case cCampo == 'TM2_SEQMOV'
            lRet := .F.
        Case cCampo == 'TMT_ACIDEN'
            lRet := M->TMT_OCORRE $ '234'
        Case cCampo == 'TMT_NUMFIC'
            lRet := !FwIsInCallStack( 'mdta007' )
        Case cCampo == 'TMT_CID'
            lRet := Empty( M->TMT_ACIDEN )
        Case cCampo == 'TMT_CIDDEF'
            lRet := !Empty( M->TMT_TIPDEF ) .And. M->TMT_TIPDEF != '0'
    End Case

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Mdta156X3I
Fun��o utilizada no X3_INIBRW dos campos da rotina

@author Gabriel Sokacheski
@since 25/04/2023

@param cCampo, nome do campo a ser verificado

@return cValor, valor a ser recebido pelo campo
/*/
//-------------------------------------------------------------------
Function Mdta156X3I( cCampo )

    Local cValor    := ''

	Do Case
        Case cCampo == 'TMT_NOMFIC'
            cValor := Posicione( 'TM0', 1, xFilial( 'TM0' ) + TMT->TMT_NUMFIC, 'TM0_NOMFIC' )
        Case cCampo == 'TM2_NOMFIC'
            cValor := Posicione( 'TM0', 1, xFilial( 'TM0' ) + TM2->TM2_NUMFIC, 'TM0_NOMFIC' )
        Case cCampo == 'TM2_NOMEDI'
            cValor := Posicione( 'TM1', 1, xFilial( 'TM1' ) + TM2->TM2_CODMED, 'TM1_NOMEDI' )
	End Case

Return cValor

//-------------------------------------------------------------------
/*/{Protheus.doc} Mdta156His
Grava hist�rico do funcion�rio na ficha m�dica (TM0_DESCRI)

@author Gabriel Sokacheski
@since 31/05/2023

/*/
//-------------------------------------------------------------------
Function Mdta156His()

    Local cMemo := ''
    Local cMed  := fMed()
    Local cExa  := fExa()

    cMemo += STR0030 + ':' + CHR( 13 ) + CHR( 10 ) + DtoC( TMT->TMT_DTATEN ) // "Data de atendimento
    cMemo += CHR( 13 ) + CHR( 10 )
    cMemo += CHR( 13 ) + CHR( 10 )

    If !Empty( TMT->TMT_MQUEIX )
        cMemo += STR0031 + ':' + CHR( 13 ) + CHR( 10 ) + TMT->TMT_MQUEIX // "Queixa"
        cMemo += CHR( 13 ) + CHR( 10 )
        cMemo += CHR( 13 ) + CHR( 10 )
    EndIf

    If !Empty( TMT->TMT_CID )
        cMemo += STR0032 + ':' + CHR( 13 ) + CHR( 10 ) + TMT->TMT_CID // "CID"
        cMemo += CHR( 13 ) + CHR( 10 )
        cMemo += CHR( 13 ) + CHR( 10 )
    EndIf

    If !Empty( cMed )
        cMemo += STR0033 + ':' + CHR( 13 ) + CHR( 10 ) + cMed // "Medicamentos"
        cMemo += CHR( 13 ) + CHR( 10 )
    EndIf

    If !Empty( cExa )
        cMemo += STR0034 + ':' + CHR( 13 ) + CHR( 10 ) + cExa // "Exame"
        cMemo += CHR( 13 ) + CHR( 10 )
    EndIf

    If !Empty( TMT->TMT_MDIAGN )
        cMemo += STR0035 + ':' + CHR( 13 ) + CHR( 10 ) + TMT->TMT_MDIAGN // "Diagn�stico"
        cMemo += CHR( 13 ) + CHR( 10 )
        cMemo += CHR( 13 ) + CHR( 10 )
    EndIf

    DbSelectArea( 'TM0' )
	( 'TM0' )->( DbSetOrder( 1 ) )

	If ( 'TM0' )->( DbSeek( xFilial( 'TM0' ) + TMT->TMT_NUMFIC ) )

		Reclock( 'TM0', .F. )
			TM0->TM0_DESCRI := cMemo
		( 'TM0' )->( MsUnlock() )

	EndIf

    MsgInfo( STR0036 + '.', STR0008 ) // "Aten��o" // "Hist�rico do paciente gravado na ficha m�dica"

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMed
Busca os medicamentos utilizados no diagn�stico

@author Gabriel Sokacheski
@since 01/06/2023

@return cMed, medicamentos utilizados
/*/
//-------------------------------------------------------------------
Static Function fMed()

    Local aAreaTM1 := ( 'TM1' )->( GetArea() )
    Local aAreaTM2 := ( 'TM2' )->( GetArea() )

    Local cMed := ''

    DbSelectArea( 'TM2' )
	( 'TM2' )->( DbSetOrder( 1 ) )

	If ( 'TM2' )->( DbSeek( xFilial( 'TM2' ) + TMT->TMT_NUMFIC + DtoS( TMT->TMT_DTCONS ) + TMT->TMT_HRCONS ) )

        While ( 'TM2' )->( !EoF() )	.And. TM2->TM2_FILIAL == xFilial( 'TM2' ) .And. TM2->TM2_NUMFIC == TMT->TMT_NUMFIC;
        .And. TM2->TM2_DTCONS == TMT->TMT_DTCONS .And. TM2->TM2_HRCONS == TMT->TMT_HRCONS

            cMed += AllTrim( Posicione( 'TM1', 1, xFilial( 'TM1' ) + TM2->TM2_CODMED, 'TM1_NOMEDI' ) )
            cMed += CHR( 13 ) + CHR( 10 )

		    ( 'TM2' )->( DbSkip() )

        End

    EndIf

    RestArea( aAreaTM1 )
    RestArea( aAreaTM2 )

Return cMed

//-------------------------------------------------------------------
/*/{Protheus.doc} fExa
Busca o exame realizado no diagn�stico

@author Gabriel Sokacheski
@since 01/06/2023

@return cExa, exame realizado
/*/
//-------------------------------------------------------------------
Static Function fExa()

    Local aAreaTM4 := ( 'TM4' )->( GetArea() )
    Local aAreaTMJ := ( 'TMJ' )->( GetArea() )

    Local cExa := ''

    DbSelectArea( 'TMJ' )
	( 'TMJ' )->( DbSetOrder( 1 ) )

	If ( 'TMJ' )->( DbSeek( xFilial( 'TMJ' ) + TMT->TMT_CODUSU + DtoS( TMT->TMT_DTCONS ) + TMT->TMT_HRCONS ) )

        cExa += AllTrim( Posicione( 'TM4', 1, xFilial( 'TM1' ) + TMJ->TMJ_EXAME, 'TM4_NOMEXA' ) )
        cExa += CHR( 13 ) + CHR( 10 )

    EndIf

    RestArea( aAreaTM4 )
    RestArea( aAreaTMJ )

Return cExa

//---------------------------------------------------------------------
/*/{Protheus.doc} Mdta156Wiz
Prepara e chama o Wizard de par�metros do diagn�stico m�dico

@author	Gabriel Sokacheski
@since 08/06/2023

/*/
//---------------------------------------------------------------------
Function Mdta156Wiz()

    // 1� Nome
    // 2� Descri��o
    // 3� Tipo ( 1=Caractere;2=Num�rico; )
    // 4� Array de op��es de escolha
    Local aParametro := {}

    If GetMv( 'MV_MDTGPE', .T. )
        // "Indica se habilita a integra��o entre os m�dulos SIGAMDT e SIGAGPE"
		aAdd( aParametro, { 'MV_MDTGPE', STR0050 + '.', 1, { 'S-' + STR0046, 'N-' + STR0047 } } )
	EndIf

    If GetMv( 'MV_NG2COMA', .T. )
        // "Indica se deve enviar um e-mail de aviso na inclus�o ou altera��o de um diagn�stico m�dico"
		aAdd( aParametro, { 'MV_NG2COMA', STR0052 + '.', 1, { 'S-' + STR0046, 'N-' + STR0047 } } )
	EndIf

    If GetMv( 'MV_NG2ALTI', .T. )
        // "Indica se os diagn�sticos m�dicos poder�o ser alterados ou exclu�dos"
		aAdd( aParametro, { 'MV_NG2ALTI', STR0048 + '.', 1, { 'S-' + STR0046, 'N-' + STR0047 } } )
	EndIf

    If GetMv( 'MV_NG2DEXC', .T. )
        // "Indica a quantidade de dias de toler�ncia para exclus�o de diagn�sticos m�dicos"
		aAdd( aParametro, { 'MV_NG2DEXC', STR0049 + '.', 2, {} } )
	EndIf

    If GetMv( 'MV_NG2ESTN', .T. )
        // "Indica se o sistema ir� trabalhar com estoque de medicamentos negativo"
		aAdd( aParametro, { 'MV_NG2ESTN', STR0044 + '.', 1, { 'S-' + STR0046, 'N-' + STR0047 } } )
	EndIf

	If GetMv( 'MV_NG2SEG', .T. )
        // "Indica se h� restri��o das rotinas do m�dulo conforme fun��o do usu�rio"
		aAdd( aParametro, { 'MV_NG2SEG', STR0043 + '.', 1, { '1-' + STR0046, '2-' + STR0047 } } )
	EndIf

    // "Bem vindo ao Wizard de configura��o de par�metros do diagn�stico m�dico"
    MdtWizard( STR0045, aParametro, { | oPainel | Mdta156Par( oPainel, aParametro ) } )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} Mdta156Par
Cria as p�ginas dos par�metros do wizard de par�metros

@author	Gabriel Sokacheski
@since 08/06/2023

@param oPainel, painel utilizado para mostrar as informa��es
@param aParametro, array contendo os par�metros utilizados

/*/
//---------------------------------------------------------------------
Function Mdta156Par( oPainel, aParametro )

	Local nParametro    := 1

    Local oCombo        := Nil
    Local oFonteP   	:= TFont():New( Nil, Nil, -14, .T. )
    Local oEscrever     := Nil

    If aScan( aParImp, { | x | x[ 1 ] == 'MV_MDTGPE' } ) > 0 .And. nParametro <= 5

        // "Indica se habilita a integra��o entre os m�dulos SIGAMDT e SIGAGPE"
        oEscrever := TSay():New( 30 * 1, 20, { || STR0050 + '.' }, oPainel, Nil, oFonteP, Nil, Nil, Nil, .T., Nil, Nil, 200, 20 )

        &( aParametro[ 1, 1 ] ) := aParametro[ 1, 4, aScan( aParametro[ 1, 4 ], { | x | &( aParametro[ 1, 1 ] ) $ x } ) ]

        // "Sim" // "N�o"
        oCombo := TComboBox():New( 30 * 1, 230, { | u | IIf( PCount() > 0, MV_MDTGPE := u, MV_MDTGPE ) }, { 'S-' + STR0046, 'N-' + STR0047 }, 50, 20, oPainel, Nil, { || }, Nil, Nil, Nil, .T., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, 'MV_MDTGPE' )

        nParametro++
        aDel( aParImp, 1 )
        aSize( aParImp, Len( aParImp ) - 1 )

    EndIf

    If aScan( aParImp, { | x | x[ 1 ] == 'MV_NG2COMA' } ) > 0 .And. nParametro <= 5

        // "Indica se deve enviar um e-mail de aviso na inclus�o ou altera��o de um diagn�stico m�dico"
        oEscrever := TSay():New( 30 * 2, 20, { || STR0052 + '.' }, oPainel, Nil, oFonteP, Nil, Nil, Nil, .T., Nil, Nil, 200, 20 )

        &( aParametro[ 2, 1 ] ) := aParametro[ 2, 4, aScan( aParametro[ 2, 4 ], { | x | &( aParametro[ 2, 1 ] ) $ x } ) ]

        // "Sim" // "N�o"
        oCombo := TComboBox():New( 30 * 2, 230, { | u | IIf( PCount() > 0, MV_NG2COMA := u, MV_NG2COMA ) }, { 'S-' + STR0046, 'N-' + STR0047 }, 50, 20, oPainel, Nil, { || }, Nil, Nil, Nil, .T., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, 'MV_NG2COMA' )

        nParametro++
        aDel( aParImp, 1 )
        aSize( aParImp, Len( aParImp ) - 1 )

    EndIf

    If aScan( aParImp, { | x | x[ 1 ] == 'MV_NG2ALTI' } ) > 0 .And. nParametro <= 5

        // "Indica se os diagn�sticos m�dicos poder�o ser alterados ou exclu�dos"
        oEscrever := TSay():New( 30 * 3, 20, { || STR0048 + '.' }, oPainel, Nil, oFonteP, Nil, Nil, Nil, .T., Nil, Nil, 200, 20 )

        &( aParametro[ 3, 1 ] ) := aParametro[ 3, 4, aScan( aParametro[ 3, 4 ], { | x | &( aParametro[ 3, 1 ] ) $ x } ) ]

        // "Sim" // "N�o"
        oCombo := TComboBox():New( 30 * 3, 230, { | u | IIf( PCount() > 0, MV_NG2ALTI := u, MV_NG2ALTI ) }, { 'S-' + STR0046, 'N-' + STR0047 }, 50, 20, oPainel, Nil, { || }, Nil, Nil, Nil, .T., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, 'MV_NG2ALTI' )

        nParametro++
        aDel( aParImp, 1 )
        aSize( aParImp, Len( aParImp ) - 1 )

    EndIf

    If aScan( aParImp, { | x | x[ 1 ] == 'MV_NG2DEXC' } ) > 0 .And. nParametro <= 5

        // "Indica a quantidade de dias de toler�ncia para exclus�o de diagn�sticos m�dicos"
        oEscrever := TSay():New( 30 * 4, 20, { || STR0049 + '.' }, oPainel, Nil, oFonteP, Nil, Nil, Nil, .T., Nil, Nil, 200, 20 )

        oCombo := TGet():New( 30 * 4, 230, { | u | IIf( PCount() > 0, MV_NG2DEXC := u, MV_NG2DEXC ) }, oPainel, 50, 10, '999', Nil, 0, 16777215, Nil, .F., Nil, .T., Nil, .F., Nil, .F., .F., Nil, .F., .F., , 'MV_NG2DEXC', Nil, Nil, Nil, .T. )

        nParametro++
        aDel( aParImp, 1 )
        aSize( aParImp, Len( aParImp ) - 1 )

    EndIf

    If aScan( aParImp, { | x | x[ 1 ] == 'MV_NG2ESTN' } ) > 0 .And. nParametro <= 5

        // "Indica se o sistema ir� trabalhar com estoque de medicamentos negativo"
        oEscrever := TSay():New( 30 * 5, 20, { || STR0044 + '.' }, oPainel, Nil, oFonteP, Nil, Nil, Nil, .T., Nil, Nil, 200, 20 )

        &( aParametro[ 5, 1 ] ) := aParametro[ 5, 4, aScan( aParametro[ 5, 4 ], { | x | &( aParametro[ 5, 1 ] ) $ x } ) ]

        // "Sim" // "N�o"
        oCombo := TComboBox():New( 30 * 5, 230, { | u | IIf( PCount() > 0, MV_NG2ESTN := u, MV_NG2ESTN ) }, { 'S-' + STR0046, 'N-' + STR0047 }, 50, 20, oPainel, Nil, { || }, Nil, Nil, Nil, .T., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, 'MV_NG2ESTN' )

        nParametro++
        aDel( aParImp, 1 )
        aSize( aParImp, Len( aParImp ) - 1 )

    EndIf

    If aScan( aParImp, { | x | x[ 1 ] == 'MV_NG2SEG' } ) > 0 .And. nParametro <= 5

        // "Indica se h� restri��o das rotinas do m�dulo conforme fun��o do usu�rio"
        oEscrever := TSay():New( 30 * 1, 20, { || STR0043 + '.' }, oPainel, Nil, oFonteP, Nil, Nil, Nil, .T., Nil, Nil, 200, 20 )

        &( aParametro[ 6, 1 ] ) := aParametro[ 6, 4, aScan( aParametro[ 6, 4 ], { | x | &( aParametro[ 6, 1 ] ) $ x } ) ]

        // "Sim" // "N�o"
        oCombo := TComboBox():New( 30 * 1, 230, { | u | IIf( PCount() > 0, MV_NG2SEG := u, MV_NG2SEG ) }, { '1-' + STR0046, '2-' + STR0047 }, 50, 20, oPainel, Nil, { || }, Nil, Nil, Nil, .T., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, 'MV_NG2SEG' )

        nParametro++
        aDel( aParImp, 1 )
        aSize( aParImp, Len( aParImp ) - 1 )

    EndIf

Return
