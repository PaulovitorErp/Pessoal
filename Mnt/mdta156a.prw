#include 'mdta156a.ch'
#include 'protheus.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} Mdta156a
Cadastro de medicamentos utilizados

@author Gabriel Sokacheski
@since 25/04/2023

/*/
//---------------------------------------------------------------------
Function Mdta156a()

    Local oBrowse

    Default MV_NG2SEG   := SuperGetMV( 'MV_NG2SEG', .F., '2' )
    Default MV_NG2DEXC  := SuperGetMv( 'MV_NG2DEXC', .F., 2 )
    Default MV_NG2ESTN  := SuperGetMv( 'MV_NG2ESTN', .F., 'N' )

    If AMiIn( 35 ) // Somente autorizado para SIGAMDT

        oBrowse := FWMBrowse():New()

        oBrowse:SetAlias( 'TM2' )
        oBrowse:SetMenuDef( 'Mdta156a' )
        oBrowse:SetDescription( STR0001 ) // "Medicamentos utilizados"
        oBrowse:SetFilterDefault( 'TM2->TM2_NUMFIC == TMT->TMT_NUMFIC .And. TM2->TM2_DTCONS == TMT->TMT_DTCONS .And. TM2->TM2_HRCONS == TMT->TMT_HRCONS' )

        oBrowse:Activate()

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu

@author Gabriel Sokacheski
@since 25/04/2023

@return aRotina, menu da rotina
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

    aAdd( aRotina, { STR0002, 'ViewDef.Mdta156a' , 0, 2, 0 } ) // "Visualizar"
    aAdd( aRotina, { STR0003, 'ViewDef.Mdta156a' , 0, 3, 0 } ) // "Incluir"
    aAdd( aRotina, { STR0004, 'ViewDef.Mdta156a' , 0, 4, 0 } ) // "Alterar"
    aAdd( aRotina, { STR0005, 'ViewDef.Mdta156a' , 0, 5, 0 } ) // "Excluir"
    aAdd( aRotina, { STR0006, 'ViewDef.Mdta156a' , 0, 8, 0 } ) // "Imprimir"

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do Modelo

@author Gabriel Sokacheski
@since 25/04/2023

@return oModel, modelo em MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oStructTM2    := FWFormStruct( 1, 'TM2' )
	Local oModel        := MPFormModel():New( 'mdta156a', Nil, { | oModel | Mdta156aOk( oModel ) } )

    oStructTM2:AddTrigger( 'TM2_CODMED', 'TM2_QTDATU', { || .T. }, { || Posicione( 'TM1', 1, xFilial( 'TM1' ) + TM2->TM2_CODMED, 'TM1_QTATUA' ) } )
    oStructTM2:AddTrigger( 'TM2_CODMED', 'TM2_QTDMIN', { || .T. }, { || Posicione( 'TM1', 1, xFilial( 'TM1' ) + TM2->TM2_CODMED, 'TM1_QTMINI' ) } )

    oModel:AddFields( 'TM2MASTER', Nil, oStructTM2 )
    oModel:SetDescription( STR0001 ) // "Medicamentos utilizados"
    oModel:GetModel( 'TM2MASTER' ):SetDescription( STR0001 ) // "Medicamentos utilizados"
    oModel:SetVldActivate( { | oModel | fAlteracao( oModel ) } )

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da view

@author Gabriel Sokacheski
@since 25/04/2023

@return oView, view em MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

    Local oModel        := FWLoadModel( 'Mdta156a' )
    Local oStructTM2    := FWFormStruct( 2, 'TM2' )
    Local oView         := FWFormView():New()

    oView:SetModel( oModel )
    oView:AddField( 'VIEW_TM2', oStructTM2, 'TM2MASTER' )
    oView:CreateHorizontalBox( 'TELA' , 100 )
    oView:SetOwnerView( 'VIEW_TM2', 'TELA' )

    oStructTM2:RemoveField( 'TM2_NUMFIC' )
    oStructTM2:RemoveField( 'TM2_NOMFIC' )
    oStructTM2:RemoveField( 'TM2_DTCONS' )
    oStructTM2:RemoveField( 'TM2_HRCONS' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} Mdta156aOk
Função que realiza a pós validação do modelo de dados ( TudoOk )

@author Gabriel Sokacheski
@since 25/04/2023

@param, oModel, modelo em MVC

@return lRet, retorno da validação do modelo
/*/
//-------------------------------------------------------------------
Function Mdta156aOk( oModel )

    Local aAreaTM1 := GetArea( 'TM1' )
    Local aAreaTM3 := GetArea( 'TM3' )

    Local oMaster   := oModel:GetModel( 'TM2MASTER' )

    Local cMov      := oMaster:GetValue( 'TM2_SEQMOV' )
    Local cMed      := oMaster:GetValue( 'TM2_CODMED' )

    Local lRet      := .T.

    Local nBaixa    := oMaster:GetValue( 'TM2_QTUTES' )

    If oModel:GetOperation() == 3 // Inclusão

        If !ExistChav( 'TM2', oMaster:GetValue( 'TM2_NUMFIC' ) + DtoS( oMaster:GetValue( 'TM2_DTCONS' ) ) + oMaster:GetValue( 'TM2_HRCONS' ) + cMed )
            lRet := .F.
        EndIf

    EndIf

    //--------------------------------------------------------------------
    // Alterações realizadas após as operações, manter no final da função
    //--------------------------------------------------------------------

    If lRet

        DbSelectArea( 'TM1' )
        ( 'TM1' )->( DbSetOrder( 1 ) )

        If ( 'TM1' )->( DbSeek( xFilial( 'TM1' ) + oMaster:GetValue( 'TM2_CODMED' ) ) )

            If TM1->TM1_INDEST != "2" // Verifica se controla estoque

                If oModel:GetOperation() == 3

                    If MV_NG2ESTN == 'N' // Verifica se trabalha com estoque negativo

                        lRet := fValEst( oMaster )

                    EndIf

                    If lRet

                        //-------------------
                        // Cria movimentação
                        //-------------------

                        DbSelectArea( 'TM3' )
                        ( 'TM3' )->( DbSetOrder( 3 ) )

                        If !( 'TM3' )->( DbSeek( xFilial( 'TM3' ) + cMov ) )

                                RecLock( 'TM3', .T. )
                                    TM3->TM3_FILIAL := xFilial( 'TM2' )
                                    TM3->TM3_SEQMOV := cMov
                                    TM3->TM3_DTMOVI := TMT->TMT_DTCONS
                                    TM3->TM3_INDMOV := '5'
                                    TM3->TM3_QTMOVI := nBaixa
                                    TM3->TM3_CODMED := cMed
                                ( 'TM3' )->( MsUnLock() )

                        EndIf

                        //------------------
                        // Atualiza estoque
                        //------------------

                        RecLock( 'TM1', .F. )
                            TM1->TM1_QTATUA := TM1->TM1_QTATUA - nBaixa
                        ( 'TM1' )->( MsUnLock() )

                    EndIf

                ElseIf  oModel:GetOperation() == 5

                    //---------------------
                    // Exclui movimentação
                    //---------------------

                    DbSelectArea( 'TM3' )
                    ( 'TM3' )->( DbSetOrder( 3 ) )

                    If ( 'TM3' )->( DbSeek( xFilial( 'TM3' ) + cMov ) )

                        RecLock( 'TM3', .F. )
                            ( 'TM3' )->( DbDelete() )
                        ( 'TM3' )->( MsUnLock() )

                    EndIf

                    //--------------------
                    // Atualiza o estoque
                    //--------------------
                    DbSelectArea( 'TM1' )
                    ( 'TM1' )->( DbSetOrder( 1 ) )

                    If ( 'TM1' )->( Dbseek( xFilial( 'TM1' ) + cMed ) ) .And. nBaixa > 0

                        RecLock( 'TM1', .F. )
                            TM1->TM1_QTATUA := TM1->TM1_QTATUA + nBaixa
                        ( 'TM1' )->( MsUnLock() )

                    EndIf

                EndIf

            EndIf

        EndIf

    EndIf

    RestArea( aAreaTM1 )
    RestArea( aAreaTM3 )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fValEst
Valida se a movimentação é válida de acordo com o estoque

@author Gabriel Sokacheski
@since 30/05/2023

@param, oMaster, objeto do modelo

@return lRet, retorno da validação do modelo
/*/
//-------------------------------------------------------------------
Static Function fValEst( oMaster )

    Local lRet      := .T.

    Local nBaixa    := oMaster:GetValue( 'TM2_QTUTES' )

    If lRet .And. ( TM1->TM1_QTATUA - nBaixa ) < 0

        //------------------------------------------------
        // Mensagens:
        // "Atenção"
        // "Estoque de Medicamentos sem saldo suficiente"
        // "Aumente o saldo do medicamento"
        //------------------------------------------------

        Help( Nil, Nil, STR0010, Nil, STR0009 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0011 + '.' } )

        lRet := .F.

    EndIf

    If lRet .And. TM1->TM1_QTMINI > 0 .And. ( TM1->TM1_QTATUA - nBaixa ) < TM1->TM1_QTMINI

        // "É recomendável que o estoque de medicamentos não atinja uma quantidade inferior à quantidade mínima. Deseja continuar mesmo assim?"
        lRet := MsgYesNo( STR0008 )

        If !lRet

            //------------------------------------------------------------------------------------------
            // Mensagens:
            // "Atenção"
            // "O cadastro não será permitido para manter a capacidade mínima do medicamento em estoque"
            // "Não reduza o estoque do medicamento abaixo da capacidade mínima"
            //------------------------------------------------------------------------------------------

            Help( Nil, Nil, STR0010, Nil, STR0014 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0015 + '.' } )

            lRet := .F.

        EndIf

    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fAlteracao
Bloqueia a alteração e exclusão dos registros de acordo com o
parâmetro MV_NG2ALTI e MV_NG2SEG.

@author Gabriel Sokacheski
@since 17/04/2023

@param, oModel, modelo em MVC

@return lRet, retorno das validações realizadas
/*/
//-------------------------------------------------------------------
Static Function fAlteracao( oModel )

    Local lRet          := .T.

    If oModel:GetOperation() == 5 // Exclusão

        If MV_NG2SEG != '2' .And. Date() > DaySum( MdtDataLo( 'TMT->TMT_USERGI' ), MV_NG2DEXC )

            //----------------------------------------------------------------------
            // Mensagens:
            // "Atenção"
            // "O período em que é permitido a exclusão do registro já se encerrou"
            // "Altere o conteúdo do parâmetro"
            //----------------------------------------------------------------------

            Help( Nil, Nil, STR0008, Nil, STR0012 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0013 + Space( 1 ) + 'MV_NG2DEXC' + '.' } )

            lRet := .F.

        EndIf

    EndIf

Return lRet
