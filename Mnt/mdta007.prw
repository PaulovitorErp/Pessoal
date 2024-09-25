#include 'mdta007.ch'
#include 'protheus.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} mdta007
Cadastro de ficha médica

@author Gabriel Sokacheski
@since 05/08/2022

/*/
//---------------------------------------------------------------------
Function mdta007()

    Local bSituacao     := { || Posicione( 'SRA', 1, TM0->TM0_FILFUN + TM0->TM0_MAT, 'RA_SITFOLH' ) }
    Local bTransfer     := { || Posicione( 'SRA', 1, TM0->TM0_FILFUN + TM0->TM0_MAT, 'RA_RESCRAI' ) }

    Local oBrowse       := Nil

    Private MV_NG2ATM0  := SuperGetMv( 'MV_NG2ATM0', .F., '3' )
    Private MV_NG2BIOM  := SuperGetMv( 'MV_NG2BIOM', .F., '2' )
    Private MV_NG2FICH  := SuperGetMv( 'MV_NG2FICH', .F., '2' )

    If AMiIn( 35 ) // Somente autorizado para SIGAMDT

        oBrowse := FWMBrowse():New()

        oBrowse:SetAlias( 'TM0' )
        oBrowse:SetMenuDef( 'mdta007' )
        oBrowse:SetDescription( STR0001 ) // "Ficha médica"

        oBrowse:AddLegend( { || Empty( Eval( bSituacao ) ) }    , 'Green'   , STR0025 ) // "Situação normal"
        oBrowse:AddLegend( { || Eval( bTransfer ) $ '30/31' }   , 'Pink'    , STR0026 ) // "Transferido"
        oBrowse:AddLegend( { || Eval( bSituacao ) == 'D' }      , 'Red'     , STR0027 ) // "Desligado"
        oBrowse:AddLegend( { || Eval( bSituacao ) == 'A' }      , 'Yellow'  , STR0028 ) // "Afastado"
        oBrowse:AddLegend( { || Eval( bSituacao ) == 'F' }      , 'Blue'    , STR0029 ) // "Férias"

        If FindFunction( 'MDTX3Tam' )
            MDTX3Tam() //**DEVE SER RETIRADA APÓS LIBERAÇÃO DA PRÓXIMA RELEASE 12.1.2410**
        EndIf

        oBrowse:Activate()

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu

@author Gabriel Sokacheski
@since 05/08/2022

@return aRotina, menu da rotina
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

    aAdd( aRotina, { STR0002, 'ViewDef.mdta007' , 0, 2, 0 } ) // "Visualizar"
    aAdd( aRotina, { STR0003, 'ViewDef.mdta007' , 0, 3, 0 } ) // "Incluir"
    aAdd( aRotina, { STR0004, 'ViewDef.mdta007' , 0, 4, 0 } ) // "Alterar"
    aAdd( aRotina, { STR0005, 'ViewDef.mdta007' , 0, 5, 0 } ) // "Excluir"
    aAdd( aRotina, { STR0006, 'ViewDef.mdta007' , 0, 8, 0 } ) // "Imprimir"
    aAdd( aRotina, { STR0045, 'MDTRegBio'       , 0, 6, 0 } ) // "Biometria"
    aAdd( aRotina, { STR0063, 'MsDocument'      , 0, 6, 0 } ) // "Conhecimento"
    aAdd( aRotina, { STR0042, 'mdta076'         , 0, 6, 0 } ) // "Consulta médica"
    aAdd( aRotina, { STR0036, 'mdta156'        	, 0, 6, 0 } ) // "Diagnóstico"
    aAdd( aRotina, { STR0058, 'Mdta007Wiz'      , 0, 6, 0 } ) // "Parâmetros"
    aAdd( aRotina, { STR0046, 'Mdta007Tar'      , 0, 6, 0 } ) // "Tarefas"

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do Modelo

@author Gabriel Sokacheski
@since 05/08/2022

@return oModel, modelo em MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oStructTM0    := FWFormStruct( 1, 'TM0' )
	Local oModel        := MPFormModel():New( 'mdta007', Nil, { | oModel | mdta007Val( oModel ) } )

    // Gatilhos da rotina
	oStructTM0:AddTrigger( 'TM0_CANDID' , 'TM0_FILFUN'  , { || .T. }, { || xFilial( 'TM0' )                                                 		                                } )
    oStructTM0:AddTrigger( 'TM0_MAT'    , 'TM0_FILFUN'  , { || .T. }, { || SRA->RA_FILIAL                                                 		                                    } )
    oStructTM0:AddTrigger( 'TM0_MAT'    , 'TM0_NOMFIC'  , { || .T. }, { || SRA->RA_NOME                                                   		                                    } )
    oStructTM0:AddTrigger( 'TM0_MAT'    , 'TM0_DTNASC'  , { || .T. }, { || SRA->RA_NASC                                                   		                                    } )
    oStructTM0:AddTrigger( 'TM0_MAT'    , 'TM0_RG'      , { || .T. }, { || SRA->RA_RG                                                     		                                    } )
    oStructTM0:AddTrigger( 'TM0_MAT'    , 'TM0_SEXO'    , { || .T. }, { || IIf( 'M' == SRA->RA_SEXO, '1', '2' )                           		                                    } )
    oStructTM0:AddTrigger( 'TM0_MAT'    , 'TM0_DTIMPL'  , { || .T. }, { || IIf( Empty( M->TM0_DTIMPL ), SRA->RA_ADMISSA, M->TM0_DTIMPL )  		                                    } )
    oStructTM0:AddTrigger( 'TM0_MAT'    , 'TM0_CODFUN'  , { || .T. }, { || SRA->RA_CODFUNC                                                		                                    } )
    oStructTM0:AddTrigger( 'TM0_CODFUN' , 'TM0_DESCFU'  , { || .T. }, { || Posicione( 'SRJ', 1, xFilial( 'SRJ' ) + M->TM0_CODFUN, 'RJ_DESC' ) 	                                    } )
	oStructTM0:AddTrigger( 'TM0_MAT'    , 'TM0_CC'      , { || .T. }, { || SRA->RA_CC                                                     		                                    } )
    oStructTM0:AddTrigger( 'TM0_CC'     , 'TM0_CCDESC'  , { || .T. }, { || Posicione( 'CTT', 1, xFilial( 'CTT' ) + M->TM0_CC, 'CTT_DESC01' ) 		                                } )
	oStructTM0:AddTrigger( 'TM0_MAT'    , 'TM0_CPF'     , { || .T. }, { || SRA->RA_CIC                                                    		                                    } )
    oStructTM0:AddTrigger( 'TM0_MAT'    , 'TM0_NOMSOC'  , { || .T. }, { || SRA->RA_NSOCIAL                                                		                                    } )
    oStructTM0:AddTrigger( 'TM0_MAT'    , 'TM0_DEPTO'   , { || .T. }, { || SRA->RA_DEPTO                                                  		                                    } )
    oStructTM0:AddTrigger( 'TM0_DEPTO'  , 'TM0_DESCDP'  , { || .T. }, { || Posicione( 'SQB', 1, xFilial( 'SQB' ) + M->TM0_DEPTO, 'QB_DESCRIC' ) 	                                } )
	oStructTM0:AddTrigger( 'TM0_MAT'    , 'TM0_NUMCP'   , { || .T. }, { || SRA->RA_NUMCP                                                  		                                    } )
    oStructTM0:AddTrigger( 'TM0_MAT'    , 'TM0_SERCP'   , { || .T. }, { || SRA->RA_SERCP                                                  		                                    } )
    oStructTM0:AddTrigger( 'TM0_MAT'    , 'TM0_UFCP'    , { || .T. }, { || SRA->RA_UFCP                                                   		                                    } )
    oStructTM0:AddTrigger( 'TM0_MAT'    , 'TM0_TIPDEF'  , { || .T. }, { || SRA->RA_TPDEFFI                                                		                                    } )
    oStructTM0:AddTrigger( 'TM0_MAT'    , 'TM0_ESTCIV'  , { || .T. }, { || SRA->RA_ESTCIVI                                                		                                    } )
    oStructTM0:AddTrigger( 'TM0_MAT'    , 'TM0_CTPCD'   , { || .T. }, { || SRA->RA_CTPCD                                                  		                                    } )
    oStructTM0:AddTrigger( 'TM0_MAT'    , 'TM0_CORPEL'  , { || .T. }, { || fCorFicha( SRA->RA_RACACOR )                                   		                                    } )
    oStructTM0:AddTrigger( 'TM0_ALTURA' , 'TM0_MASSA'   , { || .T. }, { || fCalImc()                                                         		                                } )
    oStructTM0:AddTrigger( 'TM0_PESO'   , 'TM0_MASSA'   , { || .T. }, { || fCalImc()                                                         		                                } )
    oStructTM0:AddTrigger( 'TM0_NUMDEP' , 'TM0_NOMFIC'  , { || .T. }, { || SubStr( Posicione( 'SRB', 1, xFilial( 'SRB' ) + M->TM0_MAT + M->TM0_NUMDEP, 'RB_NOME' ), 1, 40 )         } )
    oStructTM0:AddTrigger( 'TM0_NUMDEP' , 'TM0_DTNASC'  , { || .T. }, { || Posicione( 'SRB', 1, xFilial( 'SRB' ) + M->TM0_MAT + M->TM0_NUMDEP, 'RB_DTNASC' )                        } )
    oStructTM0:AddTrigger( 'TM0_NUMDEP' , 'TM0_SEXO'    , { || .T. }, { || IIf( 'M' == Posicione( 'SRB', 1, xFilial( 'SRB' ) + M->TM0_MAT + M->TM0_NUMDEP, 'RB_SEXO' ), '1', '2' )  } )
    oStructTM0:AddTrigger( 'TM0_NUMDEP' , 'TM0_CPF'     , { || .T. }, { || Posicione( 'SRB', 1, xFilial( 'SRB' ) + M->TM0_MAT + M->TM0_NUMDEP, 'RB_CIC' )                           } )

    oModel:AddFields( 'TM0MASTER', Nil, oStructTM0 )
    oModel:SetDescription( STR0001 ) // "Ficha médica"
    oModel:GetModel( 'TM0MASTER' ):SetDescription( STR0001 ) // "Ficha médica"
    oModel:SetVldActivate( { | oModel | fAlteracao( oModel ) } )

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da view

@author Gabriel Sokacheski
@since 05/08/2022

@return oView, view em MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

    Local oModel        := FWLoadModel( 'mdta007' )
    Local oStructTM0    := FWFormStruct( 2, 'TM0' )
    Local oView         := FWFormView():New()

    Default MV_NG2BIOM  := SuperGetMv( 'MV_NG2BIOM', .F., '2' )

    oView:SetModel( oModel )
    oView:AddField( 'VIEW_TM0', oStructTM0, 'TM0MASTER' )
    oView:CreateHorizontalBox( 'TELA' , 100 )
    oView:SetOwnerView( 'VIEW_TM0', 'TELA' )

    // Campos removidos da tela
    oStructTM0:RemoveField( 'TM0_OK'        )
    oStructTM0:RemoveField( 'TM0_LOJA'      )
    oStructTM0:RemoveField( 'TM0_CLIENT'    )
    oStructTM0:RemoveField( 'TM0_NOMCLI'    )
    oStructTM0:RemoveField( 'TM0_REGBIO'    )
    oStructTM0:RemoveField( 'TM0_DOENCA'    )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} fAlteracao
Bloqueia a alteração dos registros de acordo com o parâmetro
MV_NG2ATM0.

@author Gabriel Sokacheski
@since 05/08/2022

@param, oModel, modelo em MVC
/*/
//-------------------------------------------------------------------
Static Function fAlteracao( oModel )

    Local bHelp     := { || Help(;
        Nil,;
        Nil,;
        STR0009,;
        Nil,;
        STR0010 + '.',;
        1,;
        0,;
        Nil,;
        Nil,;
        Nil,;
        Nil,;
        Nil,;
        { STR0011 + Space( 1 ) + 'MV_NG2ATM0' + '.' };
    ) }

    Local lRet      := .T.

    Default MV_NG2ATM0  := SuperGetMv( 'MV_NG2ATM0', .F., '3' )

    //---------------------------------------------------------------
    // Mensagens:
    // "Atenção"
    // "A ficha médica não pode ser alterada"
    // "Altere o conteúdo do parâmetro"
    //---------------------------------------------------------------
    If oModel:GetOperation() == 4 // Alteração

        If MV_NG2ATM0 == '1'

            lRet := .F.
            Eval( bHelp )

        ElseIf MV_NG2ATM0 == '2'

            If !MsgYesNo( STR0008, 'MV_NG2ATM0' )
                lRet := .F.
                Eval( bHelp )
            EndIf

        EndIf

    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} mdta007Val
Função que realiza a pós validação do modelo de dados ( TudoOk )

@author Gabriel Sokacheski
@since 05/08/2022

@param, oModel, modelo em MVC

@return lRet, retorno da validação do modelo
/*/
//-------------------------------------------------------------------
Function mdta007Val( oModel )

    Local aAreaTM0 := ( 'TM0' )->( GetArea() )

    Local oMaster       := oModel:GetModel( 'TM0MASTER' )

    Local lRet          := .T.

    If oModel:GetOperation() == 3 // Inclusão

        If !Empty( oMaster:GetValue( 'TM0_MAT' ) ) .And. !Empty( oMaster:GetValue( 'TM0_CANDID' ) )

            //-----------------------------------------------------------------------------
            // Mensagens:
            // "Atenção"
            // "Os campos de matrícula e candidato estão preenchidos"
            // "Não é necessário preencher ambos os campos na criação de uma ficha médica"
            //-----------------------------------------------------------------------------
            Help( Nil, Nil, STR0009, Nil, STR0016 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0017 + '.' } )

            lRet := .F.

        EndIf

    EndIf

    If lRet .And. ( oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4 ) // Inclusão ou alteração

        If !Empty( oMaster:GetValue( 'TM0_MAT' ) ) .And. oMaster:IsFieldUpdated( 'TM0_MAT' );
        .And. Empty( oMaster:GetValue( 'TM0_NUMDEP' ) ) .And. ExistCpo( 'TM0', oMaster:GetValue( 'TM0_MAT' ), 11 )

            //---------------------------------------------------------------
            // Mensagens:
            // "Atenção"
            // "Já existe uma ficha médica para a matrícula informada"
            // "Não é necessário cadastrar outra ficha médica"
            //---------------------------------------------------------------
            Help( Nil, Nil, STR0009, Nil, STR0031 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0032 + '.' } )

            lRet := .F.

        EndIf

        If lRet .And. !Empty( oMaster:GetValue( 'TM0_MAT' ) ) .And. !Empty( oMaster:GetValue( 'TM0_NUMDEP' ) )

            DbSelectArea( 'TM0' )
            ( 'TM0' )->( DbSetOrder( 3 ) )

            If ( 'TM0' )->( DbSeek( oMaster:GetValue( 'TM0_FILFUN' ) + oMaster:GetValue( 'TM0_MAT' ) + oMaster:GetValue( 'TM0_NUMDEP' ) ) )

                //----------------------------------------------------------
                // Mensagens:
                // "Atenção"
                // "Já existe uma ficha médica para o dependente informado"
                // "Não é necessário cadastrar outra ficha médica"
                //----------------------------------------------------------
                Help( Nil, Nil, STR0009, Nil, STR0059 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0060 + '.' } )

                lRet := .F.

            EndIf

        EndIf

        If lRet .And. Empty( oMaster:GetValue( 'TM0_MAT' ) ) .And. Empty( oMaster:GetValue( 'TM0_CANDID' ) )

            //-----------------------------------------------------------------------------
            // Mensagens:
            // "Atenção"
            // "A ficha médica deve possuir obrigatóriamente matrícula ou candidato"
		    // "Informe uma das duas informações"
            //-----------------------------------------------------------------------------
            Help( Nil, Nil, STR0009, Nil, STR0061 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0062 + '.' } )

            lRet := .F.

        EndIf

        If !Empty( oMaster:GetValue( 'TM0_MAT' ) ) .And. oMaster:IsFieldUpdated( 'TM0_MAT' );
        .And. !ExistCpo( 'TM0', oMaster:GetValue( 'TM0_MAT' ), 11 )

            fAtuAtl( oMaster:GetValue( 'TM0_NUMFIC' ), oMaster:GetValue( 'TM0_MAT' ), oMaster:GetValue( 'TM0_FILFUN' ) )

        EndIf

    EndIf

    If lRet .And. oMaster:IsFieldUpdated( 'TM0_MAT' ) .And. oModel:GetOperation() == 4
        fValAsoAdm( oMaster:GetValue( 'TM0_NUMFIC' ) )
    EndIf

    RestArea( aAreaTM0 )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} mdta007X3R
Função utilizada no X3_RELACAO dos campos da rotina

@author Gabriel Sokacheski
@since 03/04/2022

@param cCampo, nome do campo a ser verificado

@return xValor, conteúdo a ser recebido no campo
/*/
//-------------------------------------------------------------------
Function mdta007X3R( cCampo )

    Local xValor    := ''

    If Inclui
        Do Case
            Case cCampo == 'TM0_NUMFIC'
                xValor := GetSxEnum( 'TM0', 'TM0_NUMFIC' )
            Case cCampo == 'TM0_FILFUN'
                xValor := xFilial( 'TM0' )
            Case cCampo == 'TM0_INDBIO'
                xValor := '2'
            Case cCampo == 'TM0_DOADOR'
			    xValor := '2'
            Case cCampo == 'TM0_SANGUE'
                xValor := '5'
            Case cCampo == 'TM0_FATORH'
                xValor := '1'
            Case cCampo == 'TM0_SEXO'
                xValor := '1'
            Case cCampo == 'TM0_FUMA'
                xValor := '2'
            Case cCampo == 'TM0_TIPDEF'
                xValor := '0'
            Case cCampo == 'TM0_CTPCD'
                xValor := '2'
        End Case
    Else
        Do Case
            Case cCampo == 'TM0_DOENCA'
                xValor := TMR->( VDisp( TM0->TM0_CODCID, 'TMR_DOENCA' ) )
            Case cCampo == 'TM0_DESCFU'
                xValor := Posicione( 'SRJ', 1, xFilial( 'SRJ' ) + TM0->TM0_CODFUN, 'RJ_DESC' )
            Case cCampo == 'TM0_DESCDP'
                xValor := Posicione( 'SQB', 1, xFilial( 'SQB' ) + TM0->TM0_DEPTO, 'QB_DESCRIC' )
            Case cCampo == 'TM0_CCDESC'
                xValor := Posicione( 'CTT', 1, xFilial( 'CTT' ) + TM0->TM0_CC, 'CTT_DESC01' )
        End Case
    EndIf

Return xValor

//-------------------------------------------------------------------
/*/{Protheus.doc} mdta007X3V
Função utilizada no X3_VALID dos campos da rotina

@author Gabriel Sokacheski
@since 19/08/2022

@param cCampo, nome do campo a ser validado

@return lRet, retorno da validação do campo
/*/
//-------------------------------------------------------------------
Function mdta007X3V( cCampo )

    Local lRet      := .T.

    Local nOperacao := 0

    Local oModel    := Nil

    If FwIsInCallStack( 'MDTA410' )
        nOperacao := nOpcPro
    Else
        oModel      := FWModelActive()
        nOperacao   := oModel:GetOperation()
    EndIf

    Do Case
        Case cCampo == 'TM0_CANDID'
            fValCan( @lRet, nOperacao )
        Case cCampo == 'TM0_MAT'
            fValMat( @lRet, nOperacao )
        Case cCampo == 'TM0_NUMDEP'
            fValDep( @lRet )
        Case cCampo == 'TM0_CPF'
            fValCpf( @lRet, nOperacao )
        Case cCampo == 'TM0_NOMFIC'
            fValRel( @lRet, nOperacao )
        Case cCampo == 'TM0_DTIMPL'
            fValDatAtu( @lRet, M->TM0_DTIMPL )
        Case cCampo == 'TM0_DTDOAC'
            fValDatAtu( @lRet, M->TM0_DTDOAC )
        Case cCampo == 'TM0_DTNASC'
            fValDatAtu( @lRet, M->TM0_DTNASC )
        Case cCampo == 'TM0_NUMFIC' .And. !Empty( M->TM0_NUMFIC )
            lRet := ExistChav( 'TM0', M->TM0_NUMFIC )
        Case cCampo == 'TM0_UFCP' .And. !Empty( M->TM0_UFCP )
            lRet := ExistCpo( 'SX5', '12' + M->TM0_UFCP )
        Case cCampo == 'TM0_ESTCIV' .And. !Empty( M->TM0_ESTCIV )
            lRet := ExistCpo( 'SX5', '33' + M->TM0_ESTCIV )
        Case cCampo == 'TM0_FATORH'
            lRet := Pertence( '12' )
        Case cCampo == 'TM0_FUMA'
            lRet := Pertence( '12' )
        Case cCampo == 'TM0_SANGUE'
            lRet := Pertence( '12345' )
        Case cCampo == 'TM0_INDBIO'
            lRet := Pertence( '12' )
        Case cCampo == 'TM0_CTPCD'
            lRet := Pertence( '12' )
        Case cCampo == 'TM0_COROLH'
            lRet := Pertence( '12345' )
        Case cCampo == 'TM0_TIPDEF'
            lRet := Pertence( '0123456' )
        Case cCampo == 'TM0_CORCAB'
            lRet := Pertence( '123456789' )
        Case cCampo == 'TM0_CODFUN' .And. !Empty( M->TM0_CODFUN )
            lRet := ExistCpo( 'SRJ', M->TM0_CODFUN )
        Case cCampo == 'TM0_CC' .And. !Empty( M->TM0_CC )
            lRet := ExistCpo( 'CTT', M->TM0_CC )
        Case cCampo == 'TM0_DEPTO' .And. !Empty( M->TM0_DEPTO )
            lRet := ExistCpo( 'SQB', M->TM0_DEPTO )
    End Case

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} mdta007X3W
Função utilizada no X3_WHEN dos campos da rotina

@author Gabriel Sokacheski
@since 03/04/2022

@param cCampo, nome do campo a ser verificado

@return lRet, retorno da permissão para edição
/*/
//-------------------------------------------------------------------
Function mdta007X3W( cCampo )

    Local lRet      := .T.

    Do Case
        Case cCampo == 'TM0_CPF'
            fMatPre( @lRet )
        Case cCampo == 'TM0_CODFUN'
            fMatPre( @lRet )
        Case cCampo == 'TM0_CC'
            fMatPre( @lRet )
        Case cCampo == 'TM0_DEPTO'
            fMatPre( @lRet )
        Case cCampo == 'TM0_DTNASC'
            fMatPre( @lRet )
        Case cCampo == 'TM0_SEXO'
            fMatPre( @lRet )
        Case cCampo == 'TM0_INDBIO'
            fEdiBio( @lRet )
        Case cCampo == 'TM0_QTCIG'
            fEdiCig( @lRet )
        Case cCampo == 'TM0_QTTEMP'
            fEdiCig( @lRet )
        Case cCampo == 'TM0_NUMDEP'
            fEdiDep( @lRet )
        Case cCampo == 'TM0_CANDID'
            fEdiCan( @lRet )
    End Case

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fEdiCan
Valida se permite alterar o campo TM0_CANDID

@author Gabriel Sokacheski
@since 22/08/2023

@param, lRet, retorno da função

/*/
//-------------------------------------------------------------------
Static Function fEdiCan( lRet )

	If !Empty( M->TM0_MAT )
		lRet := .F.
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fEdiDep
Valida se permite alterar o campo TM0_NUMDEP

@author Gabriel Sokacheski
@since 16/05/2023

@param, lRet, retorno da função

/*/
//-------------------------------------------------------------------
Static Function fEdiDep( lRet )

	If Empty( M->TM0_MAT )
		lRet := .F.
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fEdiCig
Valida se permite alterar os campos TM0_QTCIG e TM0_QTTEMP

@author Gabriel Sokacheski
@since 03/04/2023

@param, lRet, retorno da função

/*/
//-------------------------------------------------------------------
Static Function fEdiCig( lRet )

	If M->TM0_FUMA == '2'
		lRet := .F.
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fEdiBio
Valida se permite alterar o campo TM0_INDBIO

@author Gabriel Sokacheski
@since 03/04/2023

@param, lRet, retorno da função

/*/
//-------------------------------------------------------------------
Static Function fEdiBio( lRet )

	lRet := !Empty( M->TM0_MAT ) .And. Empty( M->TM0_NUMDEP )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMatPre
Verifica se a matrícula foi preenchida

@author Gabriel Sokacheski
@since 03/04/2023

@param, lRet, retorno da função

/*/
//-------------------------------------------------------------------
Static Function fMatPre( lRet )

	lRet := Empty( M->TM0_MAT )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fValCpf
Valida o campo TM0_CPF

@author Gabriel Sokacheski
@since 03/04/2023

@param, lRet, retorno da função
@param, nOperacao, operação da rotina

/*/
//-------------------------------------------------------------------
Static Function fValCpf( lRet, nOperacao )

   	fValRel( @lRet, nOperacao )

	If lRet .And. !Empty( M->TM0_CPF )
		lRet := ChkCpf( M->TM0_CPF )
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fValRel
Valida o campo TM0_NOMFIC e TM0_CPF

@author Gabriel Sokacheski
@since 03/04/2023

@param, lRet, retorno da função
@param, nOperacao, operação da rotina

/*/
//-------------------------------------------------------------------
Static Function fValRel( lRet, nOperacao )

   	If nOperacao == 4 // Alteração 

		lRet := FwCheckSX9( 'TM0', Nil, { 'TKD', 'TMY', 'TM5' }, Nil, .F. )

		If !lRet

			//----------------------------------------------
			// Mensagens:
			// "Atenção"
			// "Não é possível alterar o campo"
			// "Como a ficha médica já foi utilizada em outros cadastros não será permitido realizar a alteração deste campo"
			//----------------------------------------------
			Help( Nil, Nil, STR0009, Nil, STR0043 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0044 + '.' } )

		EndIf

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fValDatAtu
Valida o campo TM0_DTIMPL e TM0_DTDOAC

@author Gabriel Sokacheski
@since 30/03/2023

@param, lRet, retorno da função
@param, dValor, data valor do campo a ser comparado

/*/
//-------------------------------------------------------------------
Static Function fValDatAtu( lRet, dValor )

    If !Empty( dValor ) .And. dValor > dDataBase

        //----------------------------------------------
        // Mensagens:
        // "Atenção"
        // "Data inválida"
        // "A data não pode ser maior que a data atual"
        //----------------------------------------------
        Help( Nil, Nil, STR0009, Nil, STR0040 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0041 + '.' } )

        lRet := .F.

    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fValCan
Valida o campo TM0_CANDID

@author Gabriel Sokacheski
@since 19/08/2022

@param, lRet, retorno da função
@param, nOperacao, operação da rotina

/*/
//-------------------------------------------------------------------
Static Function fValCan( lRet, nOperacao )

    Local aArea := ( 'TM0' )->( GetArea() )

    If nOperacao == 4 // Alteração

        If TM0->TM0_CANDID != M->TM0_CANDID

            //----------------------------------------------------------------------------
            // Mensagens:
            // "Atenção"
            // "Não é possível alterar o campo de candidato na alteração da ficha médica"
            // "Deixe o campo de candidato em branco"
            //----------------------------------------------------------------------------
            Help( Nil, Nil, STR0009, Nil, STR0018 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0019 + '.' } )

            lRet := .F.

        EndIf

    EndIf

    If lRet .And. !Empty( M->TM0_CANDID )

        DbSelectArea( 'TM0' )
        DbSetOrder( 5 )
        If ( 'TM0' )->( DbSeek( xFilial( 'TM0' ) + M->TM0_CANDID ) );
        .And. M->TM0_NUMFIC != TM0->TM0_NUMFIC

            //---------------------------------------------------------------
            // Mensagens:
            // "Atenção"
            // "O candidato já existe"
            // "Preencher outro valor"
            //---------------------------------------------------------------
            Help( Nil, Nil, STR0009, Nil, STR0014 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0015 + '.' } )

            lRet := .F.

        EndIf

    EndIf

    RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fValMat
Valida o campo TM0_MAT

@author Gabriel Sokacheski
@since 26/08/2022

@param, lRet, retorno da função
@param, nOperacao, operação da rotina

/*/
//-------------------------------------------------------------------
Static Function fValMat( lRet, nOperacao )

    Local aArea         := ( 'TM0' )->( GetArea() )

    Local cCpf          := M->TM0_CPF
    Local cMatricula    := M->TM0_MAT

    If !Empty( cMatricula ) .And. !ExistCpo( 'SRA', cMatricula )
        lRet := .F.
    EndIf

    If lRet

        If nOperacao == 4

            If !Empty( TM0->TM0_MAT ) .And. Empty( cMatricula )
                fValRel( @lRet, nOperacao )
            ElseIf !Empty( TM0->TM0_MAT ) .And. TM0->TM0_MAT != cMatricula
                fValRel( @lRet, nOperacao )
            EndIf

        EndIf

    EndIf

    If lRet .And. !Empty( cMatricula )

        DbSelectArea( 'SRA' )
        DbSetOrder( 1 )
        If ( 'SRA' )->( DbSeek( xFilial( 'SRA' ) + cMatricula ) )

            If !Empty( SRA->RA_CIC ) .And. !Empty( cCpf ) .And. SRA->RA_CIC != cCpf

                //-------------------------------------------------------------------------------------------------------
                // Mensagens:
                // "Atenção"
                // "O CPF informado na ficha médica não corresponde ao cadastrado para esta matrícula. Deseja continuar?"
                //-------------------------------------------------------------------------------------------------------

                lRet := MsgYesNo( STR0030, STR0009 )

                If !lRet
                    //---------------------------------------------------------------
                    // Mensagens:
                    // "Atenção"
                    // "Preenchimento inválido"
                    // "Informe outra matrícula"
                    //---------------------------------------------------------------
                    Help( Nil, Nil, STR0009, Nil, STR0047 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0048 + '.' } )
                EndIf

            EndIf

        EndIf

    EndIf

    RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fValDep
Valida o campo TM0_NUMDEP

@author Gabriel Sokacheski
@since 12/08/2022

@param, lRet, retorno da função

/*/
//-------------------------------------------------------------------
Static Function fValDep( lRet, oModel, oMaster )

    Local aArea := ( 'TM0' )->( GetArea() )

    If lRet .And. !Empty( M->TM0_NUMDEP )

        DbSelectArea( 'TM0' )
        DbSetOrder( 3 )
        If ( 'TM0' )->( DbSeek( M->TM0_FILFUN + M->TM0_MAT + M->TM0_NUMDEP ) );
        .And. M->TM0_NUMFIC != TM0->TM0_NUMFIC

            //---------------------------------------------------------------
            // Mensagens:
            // "Atenção"
            // "O dependente já existe"
            // "Verifique a outra ficha médica existente para a mesma matrícula"
            //---------------------------------------------------------------
            Help( Nil, Nil, STR0009, Nil, STR0012 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0013 + '.' } )

            lRet := .F.

        EndIf

    EndIf

    RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fCalImc
Calcula o IMC

@author Gabriel Sokacheski
@since 19/08/2022

@return cRet, retorna a condição baseada no IMC
/*/
//-------------------------------------------------------------------
Function fCalImc()

    Local oModel    := FWModelActive()
    Local oMaster   := Nil

	Local cRet      := ''

    Local nPeso     := 0
    Local nAltura   := 0
	Local nIMC      := 0

	If oModel:GetId() == 'mdta007'
		oMaster := oModel:GetModel( 'TM0MASTER' )
		nPeso 	:= oMaster:GetValue( 'TM0_PESO' )
    	nAltura := oMaster:GetValue( 'TM0_ALTURA' )
	ElseIf oModel:GetId() == 'mdta156'
		oMaster := oModel:GetModel( 'TMTMASTER' )
		nPeso 	:= oMaster:GetValue( 'TMT_PESO' )
    	nAltura := oMaster:GetValue( 'TMT_ALTURA' )
	EndIf

	If !Empty( nPeso ) .And. !Empty( nAltura )

	    nIMC := nPeso / ( nAltura * nAltura )

        Do Case
            Case nIMC >= 0 .And. nIMC < 18.5
                cRet := STR0020 // "Magreza"
            Case nIMC >= 18.5 .And. nIMC < 25
                cRet :=  STR0021 // "Normal"
            Case nIMC >= 25 .And. nIMC < 30
                cRet := STR0022 // "Sobrepeso"
            Case nIMC >= 30 .And. nIMC < 40
                cRet := STR0023 // "Obesidade"
            Case nIMC >= 40
                cRet := STR0024 // "Obesidade grave"
        End Case

    EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MdtAltTrf
Altera os dados da ficha médica. Chamada a partir do cadastro de
funcionários e dependentes nos fontes ngintegra e gpea020
respectivamente.

@author Gabriel Sokacheski
@since 20/03/2023

@param cFilFun, filial do funcionário
@param cMatFun, matrícula do funcionário
@param aDep, informações do dependente
    { código, nome, data de Nascimento, sexo, cpf }

/*/
//-------------------------------------------------------------------
Function MdtAltTrf( cFilFun, cMatFun, aDep )

    Local aAreaSRA  := GetArea( 'SRA' )
    Local aAreaTM0  := GetArea( 'TM0' )
    Local aAreaTMJ  := GetArea( 'TMJ' )
    Local aAreaTMT  := GetArea( 'TMT' )
    Local aAreaTNC  := GetArea( 'TNC' )
    Local aAreaTM5  := GetArea( 'TM5' )
    Local aAreaTKD  := GetArea( 'TKD' )
    Local aAreaTN6  := GetArea( 'TN6' )

    Local lCopTar   := .F.
    Local lGpeAuto  := IIf( Type( 'lGp010Auto' ) != 'U', lGp010Auto, .F. ) .Or. IsBlind()

    Local nFichas   := 0

    Private cFicha  := ''

    Default MV_NG2FICH  := SuperGetMv( 'MV_NG2FICH', .F., '2' )

    If FwIsInCallStack( 'gpea020' ) // Cadastro de dependentes (gpea020)

        DbSelectArea( 'TM0' )
        DbSetOrder( 3 ) // TM0_FILFUN + TM0_MAT + TM0_NUMDEP

        If ( 'TM0' )->( DbSeek( cFilFun + cMatFun + aDep[ 1 ] ) )

            RecLock( 'TM0', .F. )

                TM0->TM0_NOMFIC	:= aDep[ 2 ]
                TM0->TM0_DTNASC := aDep[ 3 ]
                TM0->TM0_CPF    := aDep[ 5 ]

                If aDep[ 4 ] == 'M'
                    TM0->TM0_SEXO := '1'
                ElseIf aDep[ 4 ] == 'F'
                    TM0->TM0_SEXO := '2'
                EndIf

		    ( 'TM0' )->( MsUnLock() )

        EndIf

    ElseIf MV_NG2FICH == '1' // Cadastro de funcionário (ngintegra)

        DbSelectArea( 'SRA' )
        ( 'SRA' )->( DbSetOrder( 1 ) )

        If ( 'SRA' )->( DbSeek( cFilFun + cMatFun ) ) .And. !Empty( SRA->RA_CIC )

            DbSelectArea( 'TM0' )
            ( 'TM0' )->( DbSetOrder( 10 ) )

            If ( 'TM0' )->( DbSeek( xFilial( 'TM0' ) + SRA->RA_CIC ) )

                If lGpeAuto .Or. ( MsgYesNo( STR0035, STR0009 ) )

                    While TM0->TM0_FILIAL == xFilial( 'TM0' ) .And. TM0->TM0_CPF == SRA->RA_CIC

                        If ( Empty( TM0->TM0_MAT ) .Or. FwCheckSX9( 'TM0', Nil, { 'TKD', 'TMY', 'TM5' }, Nil, .F. ) )
                            cFicha := TM0->TM0_NUMFIC
                            nFichas++
                        EndIf

                        ( 'TM0' )->( DbSkip() )

                    End

                    If nFichas != 0

                        If nFichas > 1 .And. !lGpeAuto // Abre tela para selecionar outra ficha médica
                            cFicha := ''
                            mdta007a()
                        EndIf

                        If !Empty( cFicha )

                            DbSelectArea( 'TM0' )
                            ( 'TM0' )->( DbSetOrder( 1 ) )

                            If ( 'TM0' )->( DbSeek( xFilial( 'TM0' ) + cFicha ) )

                                RecLock( 'TM0', .F. )

                                    TM0->TM0_FILFUN := SRA->RA_FILIAL
                                    TM0->TM0_NOMFIC := SRA->RA_NOME
                                    TM0->TM0_MAT    := SRA->RA_MAT
                                    TM0->TM0_CODFUN := SRA->RA_CODFUNC
                                    TM0->TM0_CC		:= SRA->RA_CC
                                    TM0->TM0_DTNASC := SRA->RA_NASC
                                    TM0->TM0_RG     := SRA->RA_RG
                                    TM0->TM0_ESTCIV := SRA->RA_ESTCIVI
                                    TM0->TM0_NUMCP  := SRA->RA_NUMCP
                                    TM0->TM0_SERCP  := SRA->RA_SERCP
                                    TM0->TM0_UFCP   := SRA->RA_UFCP
                                    TM0->TM0_NUMDEP := ''
                                    TM0->TM0_NOMSOC := SRA->RA_NSOCIAL
                                    TM0->TM0_DEPTO := SRA->RA_DEPTO
                                    TM0->TM0_CTPCD := SRA->RA_CTPCD

                                    If SRA->RA_SEXO == 'M'
                                        TM0->TM0_SEXO := '1'
                                    ElseIf SRA->RA_SEXO == 'F'
                                        TM0->TM0_SEXO := '2'
                                    EndIf

                                    If !Empty( SRA->RA_RACACOR )
                                        TM0->TM0_CORPEL := fCorFicha( SRA->RA_RACACOR )
                                    EndIf

                                ( 'TM0' )->( MsUnlock() )

                                fValAsoAdm( cFicha )

                            EndIf

                        EndIf

                    EndIf

                    //---------------------------------------------------------------------------
                    // Atualiza consultas medicas, diagnosticos, acidentes e exames do candidato 
                    //---------------------------------------------------------------------------

                    dbSelectArea( 'TMJ' )
					dbSetOrder( 2 )

					If ( 'TMJ' )->( DbSeek( xFilial( 'TMJ' ) + cFicha ) )

                        While ( 'TMJ' )->( !Eof() ) .And. TMJ->TMJ_NUMFIC == cFicha

                            RecLock( 'TMJ', .F. )
                                TMJ->TMJ_MAT := cMatFun
                            ( 'TMJ' )->( MsUnLock() )

                            ( 'TMJ' )->( DbSkip() )

                        End

					EndIf

					dbSelectArea( 'TMT' )
					dbSetOrder( 1 )

					If ( 'TMT' )->( DbSeek( xFilial( 'TMT' ) + cFicha ) )

                        While ( 'TMT' )->( !Eof() ) .And. TMT->TMT_NUMFIC == cFicha

                            RecLock( 'TMT', .F. )
                                 TMT->TMT_MAT := cMatFun
                            ( 'TMT' )->( MsUnLock() )

                            ( 'TMT' )->( DbSkip() )

                        End

					EndIf

                    dbSelectArea( 'TNC' )
					dbSetOrder( 7 )

					If ( 'TNC' )->( DbSeek( xFilial( 'TNC' ) + cFicha ) )

                        While ( 'TNC' )->( !Eof() ) .And. TNC->TNC_NUMFIC == cFicha

                            RecLock( 'TNC', .F. )
                                TNC->TNC_MAT := cMatFun
                            ( 'TNC' )->( MsUnLock() )

                            ( 'TNC' )->( DbSkip() )

                        End

					EndIf

                    dbSelectArea( 'TM5' )
					dbSetOrder( 1 )

                    If ( 'TM5' )->( DbSeek( xFilial( 'TM5' ) + cFicha ) )

						While ( 'TM5' )->( !Eof() ) .And. TM5->TM5_NUMFIC == cFicha .And. Empty( TM5->TM5_MAT )

                            RecLock( 'TM5', .F. )
                                TM5->TM5_MAT    := cMatFun
                                TM5->TM5_FILFUN := cFilFun
                            ( 'TM5' )->( MsUnLock() )

                            ( 'TM5' )->( DbSkip() )

						End

					EndIf

                    //--------------------------------------------------------------------
                    // Atualiza tarefas do candidato e cadastra as tarefas do funcionário
                    //--------------------------------------------------------------------

                    DbSelectArea( 'TKD' )
                    DbSetOrder( 1 )

                    If ( 'TKD' )->( DbSeek( xFilial( 'TKD' ) + cFicha ) )

                        //-----------------------------------------------------------------------------
                        // Mensagens:
                        // "Atenção"
                        // "Existem tarefas de candidato relacionadas a esta ficha médica.
                        //      Deseja converter as tarefas de candidato para tarefas de funcionário?"
                        //-----------------------------------------------------------------------------
                        If !lGpeAuto .And. ( MsgYesNo( STR0039, STR0009 ) )
                            lCopTar := .T.
                        EndIf

                        DbSelectArea( 'TN6' )
                        DbSetOrder( 1 )

                        While ( 'TKD' )->( !Eof() ) .And. TKD->TKD_NUMFIC == cFicha

                            If ( 'TN6' )->( !DbSeek( xFilial( 'TN6' ) + TKD->TKD_CODTAR + cMatFun + DtoS( TKD->TKD_DTINIC ) ) )

                                If ( Empty( TKD->TKD_DTTERM ) .Or. SRA->RA_ADMISSA < TKD->TKD_DTTERM )

                                    If lCopTar

                                        RecLock( 'TN6', .T. )
                                            TN6->TN6_FILIAL := xFilial( 'TN6' )
                                            TN6->TN6_CODTAR := TKD->TKD_CODTAR 
                                            TN6->TN6_MAT    := cMatFun
                                            TN6->TN6_DTINIC := SRA->RA_ADMISSA
                                            TN6->TN6_DTTERM := TKD->TKD_DTTERM
                                        ( 'TN6' )->( MsUnLock() )

                                    EndIf

                                EndIf

                            EndIf

                            If ( Empty( TKD->TKD_DTTERM ) .And. SRA->RA_ADMISSA >= TKD->TKD_DTINIC )

                                RecLock( 'TKD', .F. )
                                    TKD->TKD_DTTERM := SRA->RA_ADMISSA
                                ( 'TKD' )->( MsUnLock() )

                            EndIf

                            ( 'TKD' )->( DbSkip() )

                        End

                    EndIf

                Else

                    fIncFic( cFilFun, cMatFun )

                EndIf

            Else

                fIncFic( cFilFun, cMatFun )

            EndIf

        EndIf

        RestArea( aAreaSRA )
        RestArea( aAreaTM0 )
        RestArea( aAreaTMJ )
        RestArea( aAreaTMT )
        RestArea( aAreaTNC )
        RestArea( aAreaTM5 )
        RestArea( aAreaTKD )
        RestArea( aAreaTN6 )

    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fCorFicha
Converte a cor do funcionário para os valores aceitos na ficha médica

@author Gabriel Sokacheski
@since 22/03/2023

@param cCor, valor vindo da SRA (cadastro de funcionários)

@return, cCor, valor aceito na TM0 para salvar no campo TM0_CORPEL
/*/
//-------------------------------------------------------------------
Static Function fCorFicha( cCorSRA )

    Local cCorTM0 := ''

    Do case
        Case SRA->RA_RACACOR == '1' // Indígena
            cCorTM0 := '5'
        Case SRA->RA_RACACOR == '2' // Branco
            cCorTM0 := '1'
        Case SRA->RA_RACACOR == '4' // Negro
            cCorTM0 := '2'
        Case SRA->RA_RACACOR == '6' // Amarelo
            cCorTM0 := '4'
        Case SRA->RA_RACACOR == '8' // Pardo
            cCorTM0 := '3'
    EndCase

Return cCorTM0

//-------------------------------------------------------------------
/*/{Protheus.doc} fIncFic
Inclui uma ficha médica

@author Gabriel Sokacheski
@since 15/05/2023

@param cFilFun, filial do funcionário
@param cMatFun, matrícula do funcionário

/*/
//-------------------------------------------------------------------
Static Function fIncFic( cFilFun, cMatFun )

    Local cNumFic := GetSXEnum( 'TM0', 'TM0_NUMFIC' )

    ConfirmSX8()

    RecLock( 'TM0', .T. )

        TM0->TM0_CC		:= SRA->RA_CC
        TM0->TM0_RG     := SRA->RA_RG
        TM0->TM0_CPF	:= SRA->RA_CIC
        TM0->TM0_MAT    := SRA->RA_MAT
        TM0->TM0_UFCP   := SRA->RA_UFCP
        TM0->TM0_NUMCP  := SRA->RA_NUMCP
        TM0->TM0_SERCP  := SRA->RA_SERCP
        TM0->TM0_CTPCD  := SRA->RA_CTPCD
        TM0->TM0_DEPTO  := SRA->RA_DEPTO
        TM0->TM0_FILIAL := xFilial( 'TM0' )
        TM0->TM0_NUMFIC := cNumFic
        TM0->TM0_TIPDEF := SRA->RA_TPDEFFI
	    TM0->TM0_NOMFIC := SRA->RA_NOME
        TM0->TM0_FILFUN := cFilFun
        TM0->TM0_DTIMPL := SRA->RA_ADMISSA
        TM0->TM0_DTNASC := SRA->RA_NASC
        TM0->TM0_CODFUN := SRA->RA_CODFUNC
        TM0->TM0_ESTCIV := SRA->RA_ESTCIVI
        TM0->TM0_INDBIO	:= '2'

        If !Empty( SRA->RA_NSOCIAL )
		    TM0->TM0_NOMSOC := SRA->RA_NSOCIAL
	    EndIf

        If SRA->RA_SEXO == 'M'
            TM0->TM0_SEXO := '1'
        ElseIf SRA->RA_SEXO == 'F'
            TM0->TM0_SEXO := '2'
        EndIf

        If !Empty( SRA->RA_RACACOR )
            TM0->TM0_CORPEL := fCorFicha( SRA->RA_RACACOR )
        EndIf

    ( 'TM0' )->( MsUnLock() )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Mdta007Tar
Cadastro de tarefas do funcionário ou candidato

@author Gabriel Sokacheski
@since 16/05/2023

/*/
//-------------------------------------------------------------------
Function Mdta007Tar()

    If !Empty( TM0->TM0_MAT ) // Tarefas do funcionário
        FWExecView( Nil, 'mdta007b', 4 )
    Else // Tarefas do candidato
        FWExecView( Nil, 'mdta092', 4 )
    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} Mdta007Wiz
Prepara e chama o Wizard de parâmetros da ficha médica

@author	Gabriel Sokacheski
@since 13/06/2023

/*/
//---------------------------------------------------------------------
Function Mdta007Wiz()

    // 1° Nome
    // 2° Descrição
    // 3° Tipo ( 1=Caractere;2=Numérico; )
    // 4° Array de opções de escolha
    Local aParametro := {}

    If GetMv( 'MV_NG2ATM0', .T. )
        // "Indica a ação a ser realizada na alteração das fichas médicas"
		aAdd( aParametro, { 'MV_NG2ATM0', STR0049 + '.', 1, { '1-' + STR0050, '2-' + STR0051, '3-' + STR0052 } } )
	EndIf

	If GetMv( 'MV_NG2BIOM', .T. )
        // "Indica se utiliza biometria na entrega de EPI"
		aAdd( aParametro, { 'MV_NG2BIOM', STR0053 + '.', 1, { '1-' + STR0054, '2-' + STR0055 } } )
	EndIf

    If GetMv( 'MV_NG2FICH', .T. )
        // "Indica se na inclusão de um funcionário deverá ser gerado uma ficha médica automaticamente"
		aAdd( aParametro, { 'MV_NG2FICH', STR0056 + '.', 1, { '1-' + STR0054, '2-' + STR0055 } } )
	EndIf

    // "Bem vindo ao Wizard de configuração de parâmetros da ficha médica"
    MdtWizard( STR0057, aParametro, { | oPainel | Mdta007Par( oPainel, aParametro ) } )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} Mdta007Par
Cria as páginas dos parâmetros do wizard de parâmetros

@author	Gabriel Sokacheski
@since 08/06/2023

@param oPainel, painel utilizado para mostrar as informações
@param aParametro, array contendo os parâmetros utilizados

/*/
//---------------------------------------------------------------------
Function Mdta007Par( oPainel, aParametro )

	Local nParametro    := 1

    Local oCombo        := Nil
    Local oFonteP   	:= TFont():New( Nil, Nil, -14, .T. )
    Local oEscrever     := Nil

    If aScan( aParImp, { | x | x[ 1 ] == 'MV_NG2ATM0' } ) > 0 .And. nParametro <= 5

        // "Indica a ação a ser realizada na alteração das fichas médicas"
        oEscrever := TSay():New( 30 * 1, 20, { || STR0049 + '.' }, oPainel, Nil, oFonteP, Nil, Nil, Nil, .T., Nil, Nil, 200, 20 )

        &( aParametro[ 1, 1 ] ) := aParametro[ 1, 4, aScan( aParametro[ 1, 4 ], { | x | &( aParametro[ 1, 1 ] ) $ x } ) ]

        oCombo := TComboBox():New( 30 * 1, 230, { | u | IIf( PCount() > 0, MV_NG2ATM0 := u, MV_NG2ATM0 ) }, { '1-' + STR0050, '2-' + STR0051, '3-' + STR0052 }, 50, 20, oPainel, Nil, { || }, Nil, Nil, Nil, .T., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, 'MV_NG2ATM0' )

        nParametro++
        aDel( aParImp, 1 )
        aSize( aParImp, Len( aParImp ) - 1 )

    EndIf

    If aScan( aParImp, { | x | x[ 1 ] == 'MV_NG2BIOM' } ) > 0 .And. nParametro <= 5

        // "Indica se utiliza biometria na entrega de EPI"
        oEscrever := TSay():New( 30 * 2, 20, { || STR0053 + '.' }, oPainel, Nil, oFonteP, Nil, Nil, Nil, .T., Nil, Nil, 200, 20 )

        &( aParametro[ 2, 1 ] ) := aParametro[ 2, 4, aScan( aParametro[ 2, 4 ], { | x | &( aParametro[ 2, 1 ] ) $ x } ) ]

        oCombo := TComboBox():New( 30 * 2, 230, { | u | IIf( PCount() > 0, MV_NG2BIOM := u, MV_NG2BIOM ) }, { '1-' + STR0054, '2-' + STR0055 }, 50, 20, oPainel, Nil, { || }, Nil, Nil, Nil, .T., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, 'MV_NG2BIOM' )

        nParametro++
        aDel( aParImp, 1 )
        aSize( aParImp, Len( aParImp ) - 1 )

    EndIf

    If aScan( aParImp, { | x | x[ 1 ] == 'MV_NG2FICH' } ) > 0 .And. nParametro <= 5

        // "Bem vindo ao Wizard de configuração de parâmetros da ficha médica"
        oEscrever := TSay():New( 30 * 3, 20, { || STR0056 + '.' }, oPainel, Nil, oFonteP, Nil, Nil, Nil, .T., Nil, Nil, 200, 20 )

        &( aParametro[ 3, 1 ] ) := aParametro[ 3, 4, aScan( aParametro[ 3, 4 ], { | x | &( aParametro[ 3, 1 ] ) $ x } ) ]

        oCombo := TComboBox():New( 30 * 3, 230, { | u | IIf( PCount() > 0, MV_NG2FICH := u, MV_NG2FICH ) }, { '1-' + STR0054, '2-' + STR0055 }, 50, 20, oPainel, Nil, { || }, Nil, Nil, Nil, .T., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, 'MV_NG2FICH' )

        nParametro++
        aDel( aParImp, 1 )
        aSize( aParImp, Len( aParImp ) - 1 )

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fValAsoAdm
Valida se existe um ASO admissional do funcionário e gera o evento
S-2220

@author	Gabriel Sokacheski
@since 22/12/2023

@param cFicha, ficha médica

/*/
//---------------------------------------------------------------------
Static Function fValAsoAdm( cFicha )

    Local aArea := ( 'TMY' )->( GetArea() )

    DbSelectArea( 'TMY' )
    ( 'TMY' )->( DbSetOrder( 2 ) )

    If ( 'TMY' )->( DbSeek( xFilial( 'TMY' ) + cFicha ) ) .And. TMY->TMY_NATEXA == '1'

        If MDTIntEsoc( 'S-2220', 3, cFicha, Nil, .F. )
            MDTIntEsoc( 'S-2220', 3, cFicha, Nil, Nil, Nil, Nil, Nil, DToS( TMY->TMY_DTEMIS ) )
	    EndIf

    EndIf

    RestArea( aArea )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fAtuAtl
Atualiza consultas, diagnósticos, exames, acidentes e tarefas do 
candidato onde a matrícula esteja vazia e esteja alterando a ficha 
médica para funcionário com sua respectiva matrícula

@author	Eloisa Anibaletto
@since 19/02/2024

@param cFicha, ficha médica
@param cMat, matrícula
@param cFilFun, filial do funcionário

/*/
//---------------------------------------------------------------------
Static Function fAtuAtl( cFicha, cMat, cFilFun )

    Local aAreaSRA  := GetArea( 'SRA' )
    Local aAreaTM0  := GetArea( 'TM0' )
    Local aAreaTMJ  := GetArea( 'TMJ' )
    Local aAreaTMT  := GetArea( 'TMT' )
    Local aAreaTNC  := GetArea( 'TNC' )
    Local aAreaTM5  := GetArea( 'TM5' )
    Local aAreaTKD  := GetArea( 'TKD' )
    Local aAreaTN6  := GetArea( 'TN6' )

    Local lCopTar   := .F.

    DbSelectArea( 'SRA' )
    ( 'SRA' )->( DbSetOrder( 1 ) )

    If ( 'SRA' )->( DbSeek( cFilFun + cMat ) ) .And. !Empty( SRA->RA_CIC )

        DbSelectArea( 'TM0' )
        ( 'TM0' )->( DbSetOrder( 1 ) )

        If ( 'TM0' )->( DbSeek( xFilial( 'TM0' ) + cFicha ) )
            
            dbSelectArea( 'TMJ' )
            dbSetOrder( 2 )

            If ( 'TMJ' )->( DbSeek( xFilial( 'TMJ' ) + cFicha ) )

                While ( 'TMJ' )->( !Eof() ) .And. TMJ->TMJ_NUMFIC == cFicha .And. Empty( TMJ->TMJ_MAT )

                    RecLock( 'TMJ', .F. )
                        TMJ->TMJ_MAT := cMat
                    ( 'TMJ' )->( MsUnLock() )

                    ( 'TMJ' )->( DbSkip() )

                End

            EndIf

            dbSelectArea( 'TMT' )
            dbSetOrder( 1 )

            If ( 'TMT' )->( DbSeek( xFilial( 'TMT' ) + cFicha ) )

                While ( 'TMT' )->( !Eof() ) .And. TMT->TMT_NUMFIC == cFicha .And. Empty( TMT->TMT_MAT )

                    RecLock( 'TMT', .F. )
                        TMT->TMT_MAT := cMat
                    ( 'TMT' )->( MsUnLock() )

                    ( 'TMT' )->( DbSkip() )

                End

            EndIf

            dbSelectArea( 'TNC' )
            dbSetOrder( 7 )

            If ( 'TNC' )->( DbSeek( xFilial( 'TNC' ) + cFicha ) )

                While ( 'TNC' )->( !Eof() ) .And. TNC->TNC_NUMFIC == cFicha .And. Empty( TNC->TNC_MAT )

                    RecLock( 'TNC', .F. )
                        TNC->TNC_MAT    := cMat
                        TNC->TNC_FILFUN := cFilFun
                    ( 'TNC' )->( MsUnLock() )

                    ( 'TNC' )->( DbSkip() )

                End

            EndIf

            dbSelectArea( 'TM5' )
            dbSetOrder( 1 )

            If ( 'TM5' )->( DbSeek( xFilial( 'TM5' ) + cFicha ) )

                While ( 'TM5' )->( !Eof() ) .And. TM5->TM5_NUMFIC == cFicha .And. Empty( TM5->TM5_MAT )

                    RecLock( 'TM5', .F. )
                        TM5->TM5_MAT    := cMat
                        TM5->TM5_FILFUN := cFilFun
                    ( 'TM5' )->( MsUnLock() )

                    ( 'TM5' )->( DbSkip() )

                End

            EndIf

            DbSelectArea( 'TKD' )
            DbSetOrder( 1 )

            If ( 'TKD' )->( DbSeek( xFilial( 'TKD' ) + cFicha ) )

                If ( MsgYesNo( STR0039, STR0009 ) )
                    lCopTar := .T.
                EndIf

                DbSelectArea( 'TN6' )
                DbSetOrder( 1 )

                While ( 'TKD' )->( !Eof() ) .And. TKD->TKD_NUMFIC == cFicha

                    If ( 'TN6' )->( !DbSeek( xFilial( 'TN6' ) + TKD->TKD_CODTAR + cMat + DtoS( TKD->TKD_DTINIC ) ) )

                        If ( Empty( TKD->TKD_DTTERM ) .Or. SRA->RA_ADMISSA < TKD->TKD_DTTERM )

                            If lCopTar

                                RecLock( 'TN6', .T. )
                                    TN6->TN6_FILIAL := xFilial( 'TN6' )
                                    TN6->TN6_CODTAR := TKD->TKD_CODTAR 
                                    TN6->TN6_MAT    := cMat
                                    TN6->TN6_DTINIC := SRA->RA_ADMISSA
                                    TN6->TN6_DTTERM := TKD->TKD_DTTERM
                                ( 'TN6' )->( MsUnLock() )

                            EndIf

                        EndIf

                    EndIf

                    If ( Empty( TKD->TKD_DTTERM ) .And. SRA->RA_ADMISSA >= TKD->TKD_DTINIC )

                        RecLock( 'TKD', .F. )
                            TKD->TKD_DTTERM := SRA->RA_ADMISSA
                        ( 'TKD' )->( MsUnLock() )

                    EndIf

                    ( 'TKD' )->( DbSkip() )

                End

            EndIf

        EndIf

    EndIf

    RestArea( aAreaSRA )
    RestArea( aAreaTM0 )
    RestArea( aAreaTMJ )
    RestArea( aAreaTMT )
    RestArea( aAreaTNC )
    RestArea( aAreaTM5 )
    RestArea( aAreaTKD )
    RestArea( aAreaTN6 )

Return
