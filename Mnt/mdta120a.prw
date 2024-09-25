#Include 'mdta120a.ch'
#Include 'protheus.ch'
#Include 'fwmvcdef.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} Mdta120a
Cadastro de exames do funcionário

@author Gabriel Sokacheski
@since 26/09/2023

/*/
//---------------------------------------------------------------------
Function Mdta120a()

    Local oBrowse   := Nil

    cNUMFIC := TM0->TM0_NUMFIC

    SetFunName( 'Mdta120a' )

    If AMiIn( 35 ) // Somente autorizado para SIGAMDT

        If ISINCALLSTACK( 'MDTA110' )
            Private aRotina  := MenuDef()
            Private LENUMFIC := .F.
        EndIf

        oBrowse := FWMBrowse():New()

        oBrowse:SetAlias( 'TM5' )
        oBrowse:SetMenuDef( 'Mdta120a' )
        oBrowse:SetDescription( STR0001 ) // "Exames do funcionário"
        oBrowse:SetChgAll( .F. ) // Proíbe alterar registro de outras filiais
        oBrowse:SetSeeAll( .F. ) // Oculta registro de outras filiais

		oBrowse:AddLegend( { || !Empty( TM5->TM5_DTRESU ) }		, 'Green'	, STR0010 ) // "Realizado"
		oBrowse:AddLegend( { || TM5->TM5_DTPROG >= dDataBase }	, 'Yellow'	, STR0008 ) // "Não realizado e a vencer"
		oBrowse:AddLegend( { || TM5->TM5_DTPROG < dDataBase }	, 'Red'		, STR0009 ) // "Não realizado e vencido"

        oBrowse:SetFilterDefault( fFiltro() )

        oBrowse:Activate()

        SetFunName( 'Mdta120' )

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu

@author Gabriel Sokacheski
@since 26/09/2023

@return aRotina, menu da rotina
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

    aAdd( aRotina, { STR0002, 'ViewDef.Mdta120a', 0, 2 } ) // "Visualizar"
    aAdd( aRotina, { STR0003, 'ViewDef.Mdta120a', 0, 3 } ) // "Incluir"
    aAdd( aRotina, { STR0004, 'ViewDef.Mdta120a', 0, 4 } ) // "Alterar"
    aAdd( aRotina, { STR0005, 'ViewDef.Mdta120a', 0, 5 } ) // "Excluir"
    aAdd( aRotina, { STR0006, 'REXAME120'	    , 0, 6 } ) // "Resultado"
    aAdd( aRotina, { STR0007, "MDTA991( 'TM5', { 'TM5_NUMFIC', 'TM5_USERGI' }, {'" + TM0->TM0_NUMFIC + "', StoD('" + DtoS( TM0->TM0_DTIMPL ) + "' ) }) ", 0, 6 } ) // "Histórico de exclusão"

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo

@author Gabriel Sokacheski
@since 26/09/2023

@return oModel, modelo em MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oStructTM5    := FWFormStruct( 1, 'TM5' )
	Local oModel        := MPFormModel():New( 'mdta120a', Nil, { | oModel | mdta120aVa( oModel )  }, { | oModel | fGrava( oModel ) } )

    oStructTM5:SetProperty( 'TM5_NUMFIC'    , MODEL_FIELD_INIT, { || TM0->TM0_NUMFIC } )
    oStructTM5:SetProperty( 'TM5_NOMFIC'    , MODEL_FIELD_INIT, { || TM0->TM0_NOMFIC } )
    oStructTM5:SetProperty( 'TM5_FILFUN'    , MODEL_FIELD_INIT, { || TM0->TM0_FILFUN } )

    oStructTM5:AddTrigger( 'TM5_CODRES', 'TM5_RESULT', { || .T. }, { || Posicione( 'TMU', 1, xFilial( 'TMU' ) + M->TM5_CODRES, 'TMU_RESULT' ) } )

	DbSelectArea( 'SRA' )
	( 'SRA' )->( DbSetOrder( 1 ) )

	If ( 'SRA' )->( DbSeek( TM0->TM0_FILFUN + TM0->TM0_MAT ) .And. Empty( TM0->TM0_NUMDEP ) )

        oStructTM5:SetProperty( 'TM5_MAT'       , MODEL_FIELD_INIT, { || SRA->RA_MAT                } )
        oStructTM5:SetProperty( 'TM5_CC'        , MODEL_FIELD_INIT, { || SRA->RA_CC                 } )
        oStructTM5:SetProperty( 'TM5_CODFUN'    , MODEL_FIELD_INIT, { || SRA->RA_CODFUNC            } )
        oStructTM5:SetProperty( 'TM5_CBO'       , MODEL_FIELD_INIT, { || fCbo( SRA->RA_CODFUNC )    } )
        oStructTM5:SetProperty( 'TM5_TNOTRA'    , MODEL_FIELD_INIT, { || SRA->RA_TNOTRAB            } )

    Else

        oStructTM5:SetProperty( 'TM5_CC'        , MODEL_FIELD_INIT, { || TM0->TM0_CC                } )
        oStructTM5:SetProperty( 'TM5_CODFUN'    , MODEL_FIELD_INIT, { || TM0->TM0_CODFUN            } )
        oStructTM5:SetProperty( 'TM5_CBO'       , MODEL_FIELD_INIT, { || fCbo( TM0->TM0_CODFUN )    } )

    EndIf

    oModel:AddFields( 'TM5MASTER', Nil, oStructTM5 )
    oModel:SetDescription( STR0001 ) // "Exames do funcionário"
    oModel:GetModel( 'TM5MASTER' ):SetDescription( STR0001 ) // "Exames do funcionário"

    //oModel:SetVldActivate( { | oModel | fAlteracao( oModel ) } )

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da view

@author Gabriel Sokacheski
@since 26/09/2023

@return oView, view em MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

    Local oModel        := FWLoadModel( 'mdta120a' )
    Local oStructTM5    := FWFormStruct( 2, 'TM5' )
    Local oView         := FWFormView():New()

    oView:SetModel( oModel )
    oView:AddField( 'VIEW_TM5', oStructTM5, 'TM5MASTER' )
    oView:CreateHorizontalBox( 'TELA' , 100 )
    oView:SetOwnerView( 'VIEW_TM5', 'TELA' )

Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} fFiltro
Filtro do browse da rotina

@author Gabriel Sokacheski
@since 26/09/2023

@return, cFiltro, filtro completo para utilizar no browse
/*/
//---------------------------------------------------------------------
Static Function fFiltro()

    Local cFiltro := ''

    cFiltro +=  'TM0->TM0_NUMFIC == TM5->TM5_NUMFIC'
    cFiltro +=  Space( 1 ) + '.And.' + Space( 1 ) + '(' + Space( 1 )
    cFiltro +=      '('
    cFiltro +=          '!Empty( TM5->TM5_MAT ) .And.' + Space( 1 ) + "'" + xFilial( 'SRA' ) + "'" + Space( 1 ) + '=' + Space( 1 ) + 'TM5->TM5_FILFUN' + Space( 1 )
    cFiltro +=      ')'
    cFiltro +=      '.Or.' + Space( 1 )
    cFiltro +=      '(' 
    cFiltro +=          'Empty( TM5->TM5_MAT ) .And.' + Space( 1 ) + "'" + xFilial( 'TM5' ) + "'" + Space( 1 ) + '=' + Space( 1 ) + 'TM5->TM5_FILIAL' + Space( 1 )
    cFiltro +=      ')' + Space( 1 )
    cFiltro += ')'

Return cFiltro

//-------------------------------------------------------------------
/*/{Protheus.doc} fAlteracao
Valida se a operação pode ser executada

@author Gabriel Sokacheski
@since 26/09/2023

@param, oModel, modelo em MVC
/*/
//-------------------------------------------------------------------
Static Function fAlteracao( oModel )

    Local lRet      := .T.

	DbSelectArea( 'SRA' )
	( 'SRA' )->( DbSetOrder( 01 ) )

	// "Este funcionário está demitido. Deseja realmente manipular seus exames ?"
	If ( 'SRA' )->( DbSeek( xFilial( 'SRA', TM0->TM0_FILFUN ) + TM0->TM0_MAT ) ) .And. !Empty( SRA->RA_DEMISSA ) .And. !MsgYesNo( STR0014 )

		//-----------------------------------------
		// Mensagens:
		// "Atenção"
		// "O funcionário foi demitido"
		// "Não será possível manipular os exames"
		//-----------------------------------------
		Help( Nil, Nil, STR0011, Nil, STR0012 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0013 + '.' } )

		lRet := .F.

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} mdta120aVa
Função que realiza a pós validação do modelo de dados ( TudoOk )

@author Gabriel Sokacheski
@since 28/09/2023

@param, oModel, modelo em MVC

@return lRet, retorno da validação do modelo
/*/
//-------------------------------------------------------------------
Function mdta120aVa( oModel )

    Local lRet      := .T.

    Local oMaster   := oModel:GetModel( 'TM5MASTER' )

    If oModel:GetOperation() == 4 // Alteração

        lRet := CarreLoja()        

    ElseIf oModel:GetOperation() == 3 // Inclusão

        //Verifica se já existe o exame cadastrado e emite mensagem caso exista
        If ExistCpo( 'TM5', oMaster:GetValue( 'TM5_NUMFIC' ) + DtoS( oMaster:GetValue( 'TM5_DTPROG' ) ) + oMaster:GetValue( 'TM5_HRPROG' ) + oMaster:GetValue( 'TM5_EXAME' ), 8 )

            Help( Nil, Nil, STR0011, Nil, STR0015, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0016 } )

            lRet := .F.

        EndIf

    EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fGrava
Realiza gravação dos dados

@author Gabriel Sokacheski
@since 28/09/2023

@return lRet, Indica se os dados foram gravados
/*/
//---------------------------------------------------------------------
Static Function fGrava( oModel )

    Local lRet := .F.

    If FWFormCommit( oModel )

        lRet := .T.

        If oModel:GetOperation() == 5
            ExExa120( 'TM5', Recno(), 5 ) // Realiza a exclusão de algumas tabelas adicionais
        EndIf

    Endif

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fCbo
Retorna o CBO

@author Gabriel Sokacheski
@since 28/09/2023

@param, cFuncao, código da função para pesquisa na SRJ

@return, cCbo, CBO do funcionário
/*/
//---------------------------------------------------------------------
Static Function fCbo( cFuncao )

    Local cCbo := ''

    DbSelectArea( 'SRJ' )
    ( 'SRJ' )->( DbSetOrder( 1 ) )

    If ( 'SRJ' )->( DbSeek( xFilial( 'SRJ' ) + cFuncao ) )

        cCBO  := SRJ->RJ_CBO

        If !Empty( SRJ->RJ_CODCBO )
            cCBO := SRJ->RJ_CODCBO
        Endif

    EndIf

Return cCbo
