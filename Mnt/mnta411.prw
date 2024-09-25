#include 'protheus.ch'
#include 'fwmvcdef.ch'
#include 'mnta411.ch'

Static oVie411
Static oMod411
Static oMaster
Static oGrid01
Static oGrid02
Static oTempVeic
Static oTempManu
Static oBtnConsu
Static oBtnGerOS
Static oBtnNvCon

Static cQryVeicul
Static cQryQtdeOS
Static cQryDepend
Static cQryDepen2

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA411
O.S. Preventiva Múltipla
@type function

@author Alexandre Santos
@since 20/09/2023                           	
/*/
//-------------------------------------------------------------------
Function MNTA411()

    If MNTAmIIn( 19, 95 )

        /*------------------------------------+
        | Cria tabelas temporárias da rotina. |
        +------------------------------------*/
        fCriaTemp()

        /*---------------------------+
        | Inicializa view da rotina. |
        +---------------------------*/
	    FWExecView( STR0001, 'MNTA411', MODEL_OPERATION_INSERT, , { || .T. } ) // Ordem de Serviço

    EndIf

Return

//---------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Regras de Modelagem e gravação.

@author Alexandre Santos
@since 20/09/2023

@return object, modelo de dados
/*/
//---------------------------------------------------------------------------------
Static Function ModelDef()

    Local oModel   := Nil
	Local oStruct1 := FWFormModelStruct():New()
	Local oStruct2 := FWFormModelStruct():New()
    Local oStruct3 := FWFormModelStruct():New()

    oStruct1:AddField( STR0002, '', 'DEFILIAL' , 'C', FWSizeFilial()            , 0,; // De Filial:
        , { || fWhenFld() } )
    oStruct1:AddField( STR0003, '', 'ATEFILIAL', 'C', FWSizeFilial()            , 0,; // Até Filial:
        , { || fWhenFld() } )
    oStruct1:AddField( STR0004, '', 'DEVEICULO', 'C', FWTamSX3( 'T9_CODBEM' )[1], 0,; // De Veículo:
        , { || fWhenFld() } )
    oStruct1:AddField( STR0005, '', 'ATEVEICUL', 'C', FWTamSX3( 'T9_CODBEM' )[1], 0,; // Até Veículo:
        , { || fWhenFld() } )
    oStruct1:AddField( STR0006, '', 'DATAPREVI', 'D', 8                         , 0,; // Data Prevista:
        )
    oStruct1:AddField( STR0007, '', 'HORAPREVI', 'C', 5                         , 0,; // Hora Prevista:
        )
    oStruct1:AddField( STR0008, '', 'ORDENAPOR', 'N', 1                         , 0,; // Ordenar Por:
        )
    oStruct1:AddField( 'PRKEY', '', 'PRIMARKEY', 'C', 2                         , 0, , , , , { || 'XX' } )

    oStruct1:SetProperty( 'DEFILIAL' , MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, "MNTA411Vld( '01' )" ) )
    oStruct1:SetProperty( 'ATEFILIAL', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, "MNTA411Vld( '02' )" ) )
    oStruct1:SetProperty( 'DEVEICULO', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, "MNTA411Vld( '03' )" ) )
    oStruct1:SetProperty( 'ATEVEICUL', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, "MNTA411Vld( '04' )" ) )
    oStruct1:SetProperty( 'DATAPREVI', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, "MNTA411Vld( '05' )" ) )
    oStruct1:SetProperty( 'HORAPREVI', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, "MNTA411Vld( '06' )" ) )
    oStruct1:SetProperty( 'ORDENAPOR', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, "MNTA411Vld( '07' )" ) )

    oStruct2:AddField( FWX3Titulo( 'T9_CODBEM' ) , '', 'CODVEIC1'  , 'C',;
        FWTamSX3( 'T9_CODBEM' )[1] , 0 ) 
    oStruct2:AddField( FWX3Titulo( 'T9_NOME' )   , '', 'T9_NOME'   , 'C',;
        FWTamSX3( 'T9_NOME' )[1]   , 0 ) 
    oStruct2:AddField( FWX3Titulo( 'TF_SERVICO' ), '', 'TF_SERVICO', 'C',;
        FWTamSX3( 'TF_SERVICO' )[1], 0 ) 
    oStruct2:AddField( FWX3Titulo( 'TF_SEQRELA' ), '', 'TF_SEQRELA', 'C',;
        FWTamSX3( 'TF_SEQRELA' )[1], 0 ) 
    oStruct2:AddField( FWX3Titulo( 'T9_PLACA' )  , '', 'T9_PLACA'  , 'C',;
        FWTamSX3( 'T9_PLACA' )[1]  , 0 )
    oStruct2:AddField( STR0023                   , '', 'KMATUAL2'  , 'N',;
        FWTamSX3( 'T5_CONMANU' )[1], 0 )
    oStruct2:AddField( 'PRKEY'                   , '', 'PRIMARKEY' , 'C',;
        2                          , 0, Nil, Nil, {}, .F., {||''}, .F., .F., .F. ) 

    oStruct3:AddField( FWX3Titulo( 'T9_CODBEM' ) , '', 'CODVEIC2'  , 'C',;
        FWTamSX3( 'T9_CODBEM' )[1] , 0 )
    oStruct3:AddField( ''                        , '', 'OK'        , 'L',;
        02                         , 0 )
	oStruct3:AddField( ''                        , '', 'LEGEND'    , 'C',;
        50                         , 0, , { || fWhenFld( '01' ) } )
    oStruct3:AddField( FWX3Titulo( 'T5_TAREFA' ) , '', 'T5_TAREFA' , 'C',;
        FWTamSX3( 'T5_TAREFA' )[1] , 0 )
    oStruct3:AddField( FWX3Titulo( 'T5_DESCRIC' ), '', 'T5_DESCRIC', 'C',;
        FWTamSX3( 'T5_DESCRIC' )[1], 0 )
    oStruct3:AddField( FWX3Titulo( 'T5_DTULTMA' ), '', 'T5_DTULTMA', 'D',;
        FWTamSX3( 'T5_DTULTMA' )[1], 0 )
    oStruct3:AddField( FWX3Titulo( 'T5_CONMANU' ), '', 'T5_CONMANU', 'N',;
        FWTamSX3( 'T5_CONMANU' )[1], 0 )
    oStruct3:AddField( STR0023                   , '', 'KMATUAL3'  , 'N',;
        FWTamSX3( 'T5_CONMANU' )[1], 0 )
    oStruct3:AddField( STR0024                   , '', 'KMEXCESSO' , 'N',;
        FWTamSX3( 'T5_CONMANU' )[1], 0 )
    oStruct3:AddField( STR0025                   , '', 'DIASEXCES' , 'N',;
        8                          , 0 )
    
    oStruct3:SetProperty( 'OK', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, "MNTA411Vld( '08' )" ) )
    
    oModel := MPFormModel():New( 'MNTA411', , , { || .T. }, { || .T.} )
    oModel:SetDescription( STR0022 ) // Preventiva Múltipla
    
    oModel:AddFields( 'MASTER', , oStruct1 )
    oModel:GetModel( 'MASTER' ):SetDescription( 'MODEL' )
	oModel:SetPrimaryKey( { 'PRIMARKEY' } )

    oModel:AddGrid( 'GRID01', 'MASTER', oStruct2 )
	oModel:GetModel( 'GRID01' ):SetDescription( 'GRID' )
    
    oModel:AddGrid( 'GRID02', 'GRID01', oStruct3 )
	oModel:GetModel( 'GRID02' ):SetDescription( 'GRID' )
    oModel:SetRelation( 'GRID02', { {"CODVEIC2", 'CODVEIC1'} } )

Return oModel

//---------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Regras da interface

@author Alexandre Santos
@since 20/09/2023

@return object, view
/*/
//---------------------------------------------------------------------------------
Static Function ViewDef()

    Local oView    := Nil
    Local oModel   := FWLoadModel( 'MNTA411' )
    Local oStruct1 := FWFormViewStruct():New()
	Local oStruct2 := FWFormViewStruct():New()
    Local oStruct3 := FWFormViewStruct():New()

	oStruct1:AddField( 'DEFILIAL' , '01', STR0002, STR0002, { '' },;
        'C', '@!'   , Nil, 'DLB', .T., Nil, '1' )
    oStruct1:AddField( 'ATEFILIAL', '02', STR0003, STR0003, { '' },;
        'C', '@!'   , Nil, 'DLB', .T., Nil, '1' )
    oStruct1:AddField( 'DEVEICULO', '03', STR0004, STR0004, { '' },;
        'C', '@!'   , Nil, 'ST9', .T., Nil, '1' )
    oStruct1:AddField( 'ATEVEICUL', '04', STR0005, STR0005, { '' },;
        'C', '@!'   , Nil, 'ST9', .T., Nil, '1' )
    oStruct1:AddField( 'DATAPREVI', '05', STR0006, STR0006, { '' },;
        'D', ''     , Nil, Nil  , .T., Nil, '1' )
    oStruct1:AddField( 'HORAPREVI', '06', STR0007, STR0007, { '' },;
        'C', '99:99', Nil, Nil  , .T., Nil, '1' )
    oStruct1:AddField( 'ORDENAPOR', '07', STR0008, STR0008, { '' },;
        'N', ''     , Nil, Nil  , .T., Nil, '1', {  STR0015,;   // 1=Veículo
                                                    STR0009,;   // 2=Km Atual
                                                    STR0010,;   // 3=Km Excesso
                                                    STR0011 } ) // 4=Dias Excesso

    oStruct2:AddField( 'CODVEIC1' , '01', FWX3Titulo( 'T9_CODBEM' ), FWX3Titulo( 'T9_CODBEM' ),;
        { '' }, 'C', '@!', Nil, Nil, .F., Nil, '1' )
    oStruct2:AddField( 'T9_NOME'  , '02', FWX3Titulo( 'T9_NOME' )  , FWX3Titulo( 'T9_NOME' )  ,;
        { '' }, 'C', '@!', Nil, Nil, .F., Nil, '1' )
    oStruct2:AddField( 'T9_PLACA' , '03', FWX3Titulo( 'T9_PLACA' ) , FWX3Titulo( 'T9_PLACA' ) ,;
        { '' }, 'C', '@!', Nil, Nil, .F., Nil, '1' )
    oStruct2:AddField( 'KMATUAL2' , '04', STR0023                  , STR0023                  ,;
        { '' }, 'N', '@!', Nil, Nil, .F., Nil, '1' )

    oStruct3:AddField( 'OK'        , '01', ''                        , ''                        ,;
        { '' }, 'L',       , Nil, Nil, .T., Nil, '1' )
	oStruct3:AddField( 'LEGEND'    , '02', ''                        , ''                        ,;
        { '' }, 'C', '@BMP', Nil, Nil, .T., Nil, '1' )
    oStruct3:AddField( 'T5_TAREFA' , '03', FWX3Titulo( 'T5_TAREFA' ) , FWX3Titulo( 'T5_TAREFA' ) ,;
        { '' }, 'C', '@!'  , Nil, Nil, .F., Nil, '1' )
    oStruct3:AddField( 'T5_DESCRIC', '04', FWX3Titulo( 'T5_DESCRIC' ), FWX3Titulo( 'T5_DESCRIC' ),;
        { '' }, 'C', '@!'  , Nil, Nil, .F., Nil, '1' )
    oStruct3:AddField( 'T5_DTULTMA', '05', FWX3Titulo( 'T5_DTULTMA' ), FWX3Titulo( 'T5_DTULTMA' ),;
        { '' }, 'D', '@!'  , Nil, Nil, .F., Nil, '1' )
    oStruct3:AddField( 'T5_CONMANU', '06', FWX3Titulo( 'T5_CONMANU' ), FWX3Titulo( 'T5_CONMANU' ),;
        { '' }, 'N', '@!'  , Nil, Nil, .F., Nil, '1' )
    oStruct3:AddField( 'KMATUAL3'  , '07', STR0023                   , STR0023                   ,;
        { '' }, 'N', '@!'  , Nil, Nil, .F., Nil, '1' )
    oStruct3:AddField( 'KMEXCESSO' , '08', STR0024                   , STR0024                   ,;
        { '' }, 'N', '@!'  , Nil, Nil, .F., Nil, '1' )
    oStruct3:AddField( 'DIASEXCES' , '09', STR0025                   , STR0025                   ,;
        { '' }, 'N', '@!'  , Nil, Nil, .F., Nil, '1' )

    oView := FWFormView():New()
    oView:SetCloseOnOk( { || .F. } ) //Força o fechamento da janela na confirmação
	oView:SetModel( oModel )

    oView:CreateHorizontalBox( 'TOP'   , 25 )
    oView:CreateHorizontalBox( 'CENTER', 10 )
    oView:CreateHorizontalBox( 'BOTTOM', 65 )

    oView:AddField( 'VIEW_MASTER', oStruct1, 'MASTER' )
    oView:SetOwnerView( 'VIEW_MASTER', 'TOP' )

    oView:CreateVerticalBox( 'LEFT' , 50, 'BOTTOM' )
    oView:AddGrid( 'VIEW_GRID01', oStruct2, 'GRID01' )
    oView:SetOwnerView( 'VIEW_GRID01', 'LEFT' )

    oView:CreateVerticalBox( 'RIGHT', 50, 'BOTTOM' )
    oView:AddGrid( 'VIEW_GRID02', oStruct3, 'GRID02' )
    oView:SetOwnerView( 'VIEW_GRID02', 'RIGHT' )

    oView:AddOtherObject( 'BOTAO1', { |oPanel| fCreatButt( oPanel ) } )
	oView:SetOwnerView( 'BOTAO1', 'CENTER' )
    
Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} fCreatButt
Cria botões apresentados na view.
@type function

@author Alexandre Santos
@since 20/09/2023

@param oPanel, object, Interface onde os botões serão criados.
@return
/*/
//---------------------------------------------------------------------
Static Function fCreatButt( oPanel )

    @ 005, 005 BUTTON oBtnConsu PROMPT STR0012 SIZE 045,015 FONT oPanel:oFont;
        ACTION fConsult() OF oPanel PIXEL // Consulta
    
    @ 005, 055 BUTTON oBtnGerOS PROMPT STR0013 SIZE 045,015 FONT oPanel:oFont;
        ACTION fGerOSPr() OF oPanel PIXEL // Gera OS
    
    @ 005, 105 BUTTON oBtnNvCon PROMPT STR0014 SIZE 045,015 FONT oPanel:oFont;
        ACTION fNewCons() OF oPanel PIXEL // Nova Consulta
    
    oBtnGerOS:Disable()
    oBtnNvCon:Disable()

Return 

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA411Vld
Valid. dos parâmetros iniciais da rotina.
@type function

@author Alexandre Santos
@since 21/09/2023

@param cField  , string, Indica qual parâmetro será validada.
@return boolean, Indica se o conteúdo digitado esta valido.
/*/
//---------------------------------------------------------------------
Function MNTA411Vld( cField )

    Local lRet    := .T.

    oMod411 := FWModelActive()
    oMaster := oMod411:GetModel( 'MASTER' )

    Do Case

        Case cField == '01' // De Filial

            If !Empty( oMaster:GetValue( 'DEFILIAL' ) )

                lRet := ExistCPO( 'SM0', SM0->M0_CODIGO +;
                    oMaster:GetValue( 'DEFILIAL' ) )

            EndIf

            If lRet .And. !Empty( oMaster:GetValue( 'ATEFILIAL' ) ) .And.;
                !( oMaster:GetValue( 'ATEFILIAL' ) == Replicate( 'Z', FwSizeFilial() ) )

                lRet := AteCodigo( 'SM0', SM0->M0_CODIGO + oMaster:GetValue( 'DEFILIAL' ),;
                    SM0->M0_CODIGO + oMaster:GetValue( 'ATEFILIAL' ), 10 )

            EndIf

        Case cField == '02' // Até Filial

            If !( oMaster:GetValue( 'ATEFILIAL' ) == Replicate( 'Z', FwSizeFilial() ) )
			
				lRet := AteCodigo( 'SM0', SM0->M0_CODIGO + oMaster:GetValue( 'DEFILIAL' ),;
                    SM0->M0_CODIGO + oMaster:GetValue( 'ATEFILIAL' ), 10 )
				
			EndIf

        Case cField == '03' // De Veículo

            If !Empty( oMaster:GetValue( 'DEVEICULO' ) )

                lRet := ExistCPO( 'ST9', oMaster:GetValue( 'DEVEICULO' ), 1 )

            EndIf

            If lRet .And. !Empty( oMaster:GetValue( 'ATEVEICUL' ) ) .And.;
                !( oMaster:GetValue( 'ATEVEICUL' ) == Replicate( 'Z', FWTamSX3( 'T9_CODBEM' )[1] ) )
			
				lRet := AteCodigo( 'ST9', oMaster:GetValue( 'DEVEICULO' ),;
                    oMaster:GetValue( 'ATEVEICUL' ), 10 )
				
			EndIf

        Case cField == '04' // Até Veículo

            If !( oMaster:GetValue( 'ATEVEICUL' ) == Replicate( 'Z', FWTamSX3( 'T9_CODBEM' )[1] ) )
			
				lRet := AteCodigo( 'ST9', oMaster:GetValue( 'DEVEICULO' ),;
                    oMaster:GetValue( 'ATEVEICUL' ), 10 )
				
			EndIf
        
        Case cField == '05' // Data Prevista

            lRet := !Empty( oMaster:GetValue( 'DATAPREVI' ) )

        Case cField == '06' // Hora Prevista

            lRet := NGValHora( oMaster:GetValue( 'HORAPREVI' ), .T., .T. )
 
        Case cField == '08' // OK

            If oGrid02:GetValue( 'OK' )

                /*-------------------------------------------------------------+
                | Atualiza situação da legenda antes do processo de validação. |
                +-------------------------------------------------------------*/
                oGrid02:LoadValue( 'LEGEND', fLegend( oGrid02:GetValue( 'T5_TAREFA' ) , oGrid02:GetValue( 'CODVEIC2' ) ,;
                    oGrid01:GetValue( 'TF_SERVICO' ), oGrid01:GetValue( 'TF_SEQRELA' ), oGrid02:GetValue( 'KMEXCESSO' ), oGrid02:GetValue( 'DIASEXCES' ) ) )

                If Trim( oGrid02:GetValue( 'LEGEND' ) ) == 'BR_VERMELHO'

                    oGrid02:LoadValue( 'LEGEND', 'BR_VERMELHO' )

                    Help( '', 1, 'OSABERT', , Chr( 13 ) + STR0031 + Space( 35 ), 2 ) // Está tarefa não podera ser marcada, pois já possui O.S. aberta

                    lRet := .F.
                
                Else
                
                    /*-----------------------------------------------------------+
                    | Ao marcar uma tarefa, todas suas dependencias são marcadas |
                    | automaticamente.                                           |
                    +-----------------------------------------------------------*/
                    fMarkDep()

                EndIf

            Else

                /*--------------------------------------------------------+
                | Valid. ao desmarcar, quando a tarefa é dependencia para |
                | outra impede a ação de desmarcar a tarefa.              |
                +--------------------------------------------------------*/
                lRet := fValiDep()

            EndIf

    End Case
    
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fWhenFld
Controle da abertura dos campos para edição.
@type function

@author Alexandre Santos
@since 20/09/2023

@param cField  , string, Indica qual campos será verificado.
@return boolean, Define se o campo será aberto para edição.
/*/
//---------------------------------------------------------------------
Static Function fWhenFld( cField )

    Local cAlsVeic := oTempVeic:GetAlias()
    Local lRet     := .T.

    Do Case

        Case cField == '01' // Legenda

            BrwLegenda( STR0030, STR0030,;         // Legenda
                {   { 'BR_VERDE'   , STR0029 },;   // Existe O.S. aberta para esta tarefa
		            { 'BR_AMARELO' , STR0028 },;   // Tarefa atrasada e sem O.S. aberta
                    { 'BR_VERMELHO', STR0027 } } ) // Tarefa em dia e sem O.S. aberta

            lRet := .F.

        OtherWise
            
            dbSelectArea( cAlsVeic )
            dbGoTop()

            If (cAlsVeic)->( !EoF() )

                /*------------------------------------------------+
                | Se a tabela possuir registros, fecha os campos. |
                +------------------------------------------------*/
                lRet := .F.

            EndIf

    End Case
    
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fConsult
Gera consulta de veículos e manutenções conforme os parâmetros.
@type function

@author Alexandre Santos
@since 20/09/2023

@param
@return
/*/
//---------------------------------------------------------------------
Static Function fConsult()

    Local aBind    := {}
    Local cAlsST9  := GetNextAlias()

    oMod411 := FWModelActive()
    oMaster := oMod411:GetModel( 'MASTER' )

    oGrid01 := oMod411:GetModel( 'GRID01' )
    oGrid01:ClearData()
    
    oGrid02 := oMod411:GetModel( 'GRID02' )
    oGrid02:ClearData()

    oVie411 := FWViewActive()

    /*---------------------------------------------+
    | Valid. preenchimento dos campos obrigatórios |
    +---------------------------------------------*/
    If fObrigat()

        If Empty( cQryVeicul )

            cQryVeicul := "SELECT "
            cQryVeicul +=     "ST9.T9_CODBEM , "
            cQryVeicul +=     "ST9.T9_NOME   , "
            cQryVeicul +=     "ST9.T9_PLACA  , "
            cQryVeicul +=     "ST5.T5_TAREFA , "
            cQryVeicul +=     "ST5.T5_DESCRIC, "
            cQryVeicul +=     "ST5.T5_DTULTMA, "
            cQryVeicul +=     "ST5.T5_CONMANU, "
            cQryVeicul +=     "ST5.T5_TEENMA , "
            cQryVeicul +=     "ST5.T5_UNENMA , "
            cQryVeicul +=     "ST5.T5_INENMA , "
            cQryVeicul +=     "STF.TF_SERVICO, "
            cQryVeicul +=     "STF.TF_SEQRELA, "
            cQryVeicul +=     "STF.TF_TIPACOM, "
            cQryVeicul +=     "CASE "
            cQryVeicul +=       "WHEN STF.TF_TIPACOM = 'S' THEN 2 "
            cQryVeicul +=       "WHEN STF.TF_TIPACOM = 'T' THEN 0 "
            cQryVeicul +=       "ELSE 1 "
            cQryVeicul +=     "END CONTADOR "
            cQryVeicul += "FROM "
            cQryVeicul +=    RetSQLName( 'ST9' ) + " ST9 "
            cQryVeicul += "INNER JOIN "
            cQryVeicul +=    RetSQLName( 'STF' ) + " STF ON "
            cQryVeicul +=        NGMODCOMP( 'ST9', 'STF', , , , 'T9_CODFIL', 'TF_FILIAL' ) + " AND "
            cQryVeicul +=        "STF.TF_CODBEM  = ST9.T9_CODBEM AND "
            cQryVeicul +=        "STF.TF_PERIODO = 'M'           AND "
            cQryVeicul +=        "STF.TF_ATIVO   = 'S'           AND "
            cQryVeicul +=        "STF.D_E_L_E_T_ = ' ' "
            cQryVeicul += "INNER JOIN "
            cQryVeicul +=    RetSQLName( 'ST5' ) + " ST5 ON "
            cQryVeicul +=        "ST5.T5_FILIAL  = STF.TF_FILIAL  AND "
            cQryVeicul +=        "ST5.T5_CODBEM  = STF.TF_CODBEM  AND "
            cQryVeicul +=        "ST5.T5_SERVICO = STF.TF_SERVICO AND "
            cQryVeicul +=        "ST5.T5_SEQRELA = STF.TF_SEQRELA AND "
            cQryVeicul +=        "ST5.D_E_L_E_T_ = ' ' "
            cQryVeicul += "WHERE "
            cQryVeicul +=    "ST9.T9_CODFIL BETWEEN ? AND ? AND "
            cQryVeicul +=    "ST9.T9_CODBEM BETWEEN ? AND ? AND "
            cQryVeicul +=    "ST9.T9_SITMAN  = 'A'          AND "
            cQryVeicul +=    "ST9.D_E_L_E_T_ = ' ' "
            cQryVeicul += "ORDER BY "
            cQryVeicul +=    "ST9.T9_CODBEM, "
            cQryVeicul +=    "ST5.T5_TAREFA "

            cQryVeicul := ChangeQuery( cQryVeicul )

        EndIf

        aAdd( aBind, oMaster:GetValue( 'DEFILIAL'  ) )
        aAdd( aBind, oMaster:GetValue( 'ATEFILIAL' ) )
        aAdd( aBind, oMaster:GetValue( 'DEVEICULO' ) )
        aAdd( aBind, oMaster:GetValue( 'ATEVEICUL' ) )

        dbUseArea( .T., 'TOPCONN', TcGenQry2( , , cQryVeicul, aBind ), cAlsST9, .T., .T. )

        /*---------------------------------------------+
        | Grava retorno da query na tabela temporária. |
        +---------------------------------------------*/
        fGravaTemp( cAlsST9 )

        /*------------------------------------------------+
        | Atualiza modelo com dados da tabela temporária. |
        +------------------------------------------------*/
        fLoadModel( )

        oBtnConsu:Disable()
        oBtnGerOS:Enable()
        oBtnNvCon:Enable()

        (cAlsST9)->( dbCloseArea() )

    EndIf
    
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fGerOSPr
Gera O.S. conforme tarefas marcadas no markBrowse.
@type function

@author Alexandre Santos
@since 20/09/2023

@param
@return
/*/
//---------------------------------------------------------------------
Static Function fGerOSPr()

    Local aNewOS  := {}
    Local aRetOS  := {}
    Local aTaref  := {}
    Local nInd1   := 0
    Local nInd2   := 0

    For nInd1 := 1 To oGrid01:Length()
        
        aTaref := {}

        oGrid01:GoLine( nInd1 )

        For nInd2 := 1 To oGrid02:Length()

            oGrid02:GoLine( nInd2 )

            If !Empty( oGrid02:GetValue( 'OK' ) )

                aAdd( aTaref, oGrid02:GetValue( 'T5_TAREFA' ) )

            EndIf

        Next nInd2

        If !Empty( aTaref )
        
            aRetOS := NgGeraOS(; 
                'P',;
                oMaster:GetValue( 'DATAPREVI' ) ,; // Data Inicio
                oGrid01:GetValue( 'CODVEIC1' )  ,; // Veículo
                oGrid01:GetValue( 'TF_SERVICO' ),; // Serviço
                oGrid01:GetValue( 'TF_SEQRELA' ),; // Sequéncia
                'S',;
                'S',;
                'S',;
                FWxFilial( 'STJ' ),;
                'L',;
                .T.,;
                .T.,;
                Nil,;
                'B',;
                Nil,;
                Nil,;
                Nil,; 
                Nil,;
                aTaref ) // Itens da Manutenção Múltipla

            If aRetOS[1,1] == 'S'

                /*-----------------------------------------------------------+
                | Salva o número das O.S. geradas para utilizar na consulta. |
                +-----------------------------------------------------------*/
                aAdd( aNewOS, aRetOS[1,3])

            EndIf

        EndIf

    Next nInd1

    If !Empty( aNewOS ) .And.;
        MsgYesNo( STR0026, '' ) // Deseja consultar as ordens de serviço geradas?
        
        MNTC550C( aNewOS )

    EndIf

    /*-----------------------------------------------------------------+
    | Atualiza legendas, já considerando as O.S. inclusas no processo. |
    +-----------------------------------------------------------------*/
    fUpdLegend()

    FWFreeArray( aTaref )
    FWFreeArray( aNewOS )
    FWFreeArray( aRetOS )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fNewCons
Libera o browse para uma nova consulta.
@type function

@author Alexandre Santos
@since 20/09/2023

@param
@return
/*/
//---------------------------------------------------------------------
Static Function fNewCons()

    Local cAlsVeic  := oTempVeic:GetAlias()
    Local cAlsManu  := oTempManu:GetAlias()

    /*------------------------------------------------+
    | Habilita/Desabilita botões conforme o processo. |
    +------------------------------------------------*/
    oBtnConsu:Enable()
    oBtnGerOS:Disable()
    oBtnNvCon:Disable()

    /*-----------------------+
    | Limpa todos os modelos |
    +-----------------------*/
    oMaster:ClearField( 'DEFILIAL' )
    oMaster:ClearField( 'ATEFILIAL' )
    oMaster:ClearField( 'DEVEICULO' )
    oMaster:ClearField( 'ATEVEICUL' )
    oMaster:ClearField( 'DATAPREVI' )
    oMaster:ClearField( 'HORAPREVI' )
    oMaster:ClearField( 'ORDENAPOR' )
    oMaster:ClearField( 'PRIMARKEY' )
    oGrid01:ClearData()
    oGrid02:ClearData()

    /*------------------------------------+
    | Limpa tabela temporária de veículos |
    +------------------------------------*/
    dbSelectArea( cAlsVeic )
    Zap

    /*---------------------------------------+
    | Limpa tabela temporária de manutenções |
    +---------------------------------------*/
    dbSelectArea( cAlsManu )
    Zap

    /*---------------------------------------+
    | Atualiza View com alterações do modelo |
    +---------------------------------------*/
    oVie411:ApplyModifyToViewByModel()
    oVie411:Refresh()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fObrigat
Valida preenchimento dos campos obrigatórios.
@type function

@author Alexandre Santos
@since 20/09/2023

@param
@return
/*/
//---------------------------------------------------------------------
Static Function fObrigat()

    Local lRet := .T.

    Do Case

        Case Empty( oMaster:GetValue( 'ATEFILIAL' ) ) // Até Filial

            Help( '', 1, 'OBRIGAT', , Chr( 13 ) + STR0003 + Space( 35 ), 3 )

            lRet := .F.

        Case Empty( oMaster:GetValue( 'ATEVEICUL' ) ) // Até Veículo

            Help( '', 1, 'OBRIGAT', , Chr( 13 ) + STR0005 + Space( 35 ), 3 )

            lRet := .F.

        Case Empty( oMaster:GetValue( 'DATAPREVI' ) ) // Data Prevista

            Help( '', 1, 'OBRIGAT', , Chr( 13 ) + STR0006 + Space( 35 ), 3 )

            lRet := .F.

        Case Empty( oMaster:GetValue( 'HORAPREVI' ) ) // Hora Prevista

            Help( '', 1, 'OBRIGAT', , Chr( 13 ) + STR0007 + Space( 35 ), 3 )

            lRet := .F.
        
        Case Empty( oMaster:GetValue( 'ORDENAPOR' ) ) // Ordenar Por

            Help( '', 1, 'OBRIGAT', , Chr( 13 ) + STR0008 + Space( 35 ), 3 )

            lRet := .F.

    End Case
    
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fLegend
Gera legenda para a situação da tarefa.
@type function

@author Alexandre Santos
@since 20/09/2023

@param [cCodTar], string , Tarefa da Manutenção.
@param [cCodBem], string , Código do Bem.
@param [cCodSer], string , Serviço da Manutenção.
@param [cSeqMan], string , Sequência da Manutenção.
@param [nExceKM], integer, Valor excedido em Km do previsto.
@param [nExcDia], integer, Valor excedido em dias do previsto.

@return
/*/
//---------------------------------------------------------------------
Static Function fLegend( cCodTar, cCodBem, cCodSer, cSeqMan, nExceKM, nExcDia )
    
    Local aBind    := {}
    Local cAlsSTJ  := GetNextAlias()
    Local cAlsVeic := oTempVeic:GetAlias()
    Local cAlsManu := oTempManu:GetAlias()
    Local cClrRet  := ''

    Default cCodTar := (cAlsManu)->TAREFA
    Default cCodBem := (cAlsManu)->CODBEM
    Default cCodSer := (cAlsVeic)->SERVIC
    Default cSeqMan := (cAlsVeic)->SEQREL
    Default nExceKM := (cAlsManu)->EXCEKM
    Default nExcDia := (cAlsManu)->EXCDIA 

    If Empty( cQryQtdeOS )

        cQryQtdeOS := "SELECT "
        cQryQtdeOS +=     "1 "
        cQryQtdeOS += "FROM "
        cQryQtdeOS +=    RetSQLName( 'STJ' ) + " STJ "
        cQryQtdeOS += "INNER JOIN "
        cQryQtdeOS +=    RetSQLName( 'ST9' ) + " ST9 ON "
        cQryQtdeOS +=       NGModComp( 'ST9', 'STJ' )   + " AND "
        cQryQtdeOS +=       "ST9.T9_CODBEM  = STJ.TJ_CODBEM AND "
        cQryQtdeOS +=       "ST9.D_E_L_E_T_ = ' ' "
        cQryQtdeOS += "RIGHT JOIN "
        cQryQtdeOS +=    RetSQLName( 'STL' ) + " STL ON "
        cQryQtdeOS +=       "STL.TL_FILIAL  = STJ.TJ_FILIAL AND "
        cQryQtdeOS +=       "STL.TL_ORDEM   = STJ.TJ_ORDEM  AND "
        cQryQtdeOS +=       "STL.TL_PLANO   = STJ.TJ_PLANO  AND "
        cQryQtdeOS +=       "STL.TL_TAREFA  = ?             AND "
        cQryQtdeOS +=       "STL.D_E_L_E_T_ = ' ' "
        cQryQtdeOS += "WHERE "
        cQryQtdeOS +=    "STJ.TJ_CODBEM   = ?   AND "
        cQryQtdeOS +=    "STJ.TJ_SERVICO  = ?   AND "
        cQryQtdeOS +=    "STJ.TJ_SEQRELA  = ?   AND "
        cQryQtdeOS +=    "STJ.TJ_TERMINO  = 'N' AND "
        cQryQtdeOS +=    "STJ.TJ_SITUACA <> 'C' AND "
        cQryQtdeOS +=    "STJ.D_E_L_E_T_ = ' ' "

        cQryQtdeOS +=    "UNION "

        cQryQtdeOS += "SELECT "
        cQryQtdeOS +=     "1 "
        cQryQtdeOS += "FROM "
        cQryQtdeOS +=    RetSQLName( 'STJ' ) + " STJ "
        cQryQtdeOS += "INNER JOIN "
        cQryQtdeOS +=    RetSQLName( 'ST9' ) + " ST9 ON "
        cQryQtdeOS +=       NGModComp( 'ST9', 'STJ' )   + " AND "
        cQryQtdeOS +=       "ST9.T9_CODBEM  = STJ.TJ_CODBEM AND "
        cQryQtdeOS +=       "ST9.D_E_L_E_T_ = ' ' "
        cQryQtdeOS += "RIGHT JOIN "
        cQryQtdeOS +=    RetSQLName( 'STQ' ) + " STQ ON "
        cQryQtdeOS +=       "STQ.TQ_FILIAL  = STJ.TJ_FILIAL AND "
        cQryQtdeOS +=       "STQ.TQ_ORDEM   = STJ.TJ_ORDEM  AND "
        cQryQtdeOS +=       "STQ.TQ_PLANO   = STJ.TJ_PLANO  AND "
        cQryQtdeOS +=       "STQ.TQ_TAREFA  = ?             AND "
        cQryQtdeOS +=       "STQ.D_E_L_E_T_ = ' ' "
        cQryQtdeOS += "WHERE "
        cQryQtdeOS +=    "STJ.TJ_CODBEM   = ?   AND "
        cQryQtdeOS +=    "STJ.TJ_SERVICO  = ?   AND "
        cQryQtdeOS +=    "STJ.TJ_SEQRELA  = ?   AND "
        cQryQtdeOS +=    "STJ.TJ_TERMINO  = 'N' AND "
        cQryQtdeOS +=    "STJ.TJ_SITUACA <> 'C' AND "
        cQryQtdeOS +=    "STJ.D_E_L_E_T_ = ' ' "

        cQryQtdeOS := ChangeQuery( cQryQtdeOS )

    EndIf

    aAdd( aBind, cCodTar )
    aAdd( aBind, cCodBem )
    aAdd( aBind, cCodSer )
    aAdd( aBind, cSeqMan )
    aAdd( aBind, cCodTar)
    aAdd( aBind, cCodBem )
    aAdd( aBind, cCodSer )
    aAdd( aBind, cSeqMan )

    dbUseArea( .T., 'TOPCONN', TcGenQry2( , , cQryQtdeOS, aBind ), cAlsSTJ, .T., .T. )

    If (cAlsSTJ)->( !EoF() )

        /*---------------------------------------------------+
        | Caso exista qualquer O.S. aberta para esta tarefa. |
        +---------------------------------------------------*/
        cClrRet := 'BR_VERMELHO'

    Else

        If nExceKM > 0 .Or.;
            nExcDia > 0
            
            /*-----------------------------------+
            | Tarefa atrasada e sem O.S. aberta. |
            +-----------------------------------*/
            cClrRet := 'BR_AMARELO'

        Else

            /*---------------------------------+
            | Tarefa em dia e sem O.S. aberta. |
            +---------------------------------*/
            cClrRet := 'BR_VERDE'

        EndIf

    EndIf

    FWFreeArray( aBind )

Return cClrRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fMarkDep
Marca todas as tarefas que são dependencia.
@type function

@author Alexandre Santos
@since 20/09/2023

@param
@return
/*/
//---------------------------------------------------------------------
Static Function fMarkDep()

    Local aBind   := {}
    Local cAlsSTM := GetNextAlias()

    If Empty( cQryDepend )

        cQryDepend := "SELECT "
        cQryDepend +=     "STM.TM_DEPENDE, "
        cQryDepend +=     "STM.TM_TAREFA , "
        cQryDepend +=     "STM.TM_CODBEM "
        cQryDepend += "FROM "
        cQryDepend +=    RetSQLName( 'STM' ) + " STM "
        cQryDepend += "WHERE "
        cQryDepend +=    "STM.TM_FILIAL  = ? AND "
        cQryDepend +=    "STM.TM_CODBEM  = ? AND "
        cQryDepend +=    "STM.TM_SERVICO = ? AND "
        cQryDepend +=    "STM.TM_SEQRELA = ? AND "
        cQryDepend +=    "STM.TM_TAREFA  = ? AND "
        cQryDepend +=    "STM.D_E_L_E_T_ = ' ' "

        cQryDepend := ChangeQuery( cQryDepend )

    EndIf

    aAdd( aBind, FWxFilial( 'STM' ) )
    aAdd( aBind, oGrid01:GetValue( 'CODVEIC1' ) )
    aAdd( aBind, oGrid01:GetValue( 'TF_SERVICO' ) )
    aAdd( aBind, oGrid01:GetValue( 'TF_SEQRELA' ) )
    aAdd( aBind, oGrid02:GetValue( 'T5_TAREFA' ) )

    dbUseArea( .T., 'TOPCONN', TcGenQry2( , , cQryDepend, aBind ), cAlsSTM, .T., .T. )

    While (cAlsSTM)->( !EoF() )

        If oGrid02:SeekLine( { { 'CODVEIC2', (cAlsSTM)->TM_CODBEM },;
            { 'T5_TAREFA', (cAlsSTM)->TM_DEPENDE } } )

            If !( Trim( oGrid02:GetValue( 'LEGEND' ) ) == 'BR_VERMELHO' )
                
                oGrid02:LoadValue( 'OK' , .T. )

                /*-----------------------------------------------------------+
                | Ao marcar uma tarefa, todas suas dependencias são marcadas |
                | automaticamente.                                           |
                +-----------------------------------------------------------*/
                fMarkDep()

            EndIf

        EndIf

        oGrid02:SeekLine( { { 'CODVEIC2', (cAlsSTM)->TM_CODBEM },;
            { 'T5_TAREFA', (cAlsSTM)->TM_TAREFA } } )

        (cAlsSTM)->( dbSkip() )

    End

    oVie411:ApplyModifyToViewByModel()
    oVie411:Refresh()

    (cAlsSTM)->( dbCloseArea() )

    FWFreeArray( aBind )
    
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fValiDep
Valida a desmarcação de uma tarefa dependencia.
@type function

@author Alexandre Santos
@since 20/09/2023

@param
@return
/*/
//---------------------------------------------------------------------
Static Function fValiDep()
    
    Local aBind   := {}
    Local cAlsSTM := GetNextAlias()
    Local lRet    := .T.

    If Empty( cQryDepen2 )

        cQryDepen2 := "SELECT "
        cQryDepen2 +=     "STM.TM_TAREFA, "
        cQryDepen2 +=     "STM.TM_CODBEM, "
        cQryDepen2 +=     "STM.TM_DEPENDE "
        cQryDepen2 += "FROM "
        cQryDepen2 +=    RetSQLName( 'STM' ) + " STM "
        cQryDepen2 += "WHERE "
        cQryDepen2 +=    "STM.TM_FILIAL  = ? AND "
        cQryDepen2 +=    "STM.TM_CODBEM  = ? AND "
        cQryDepen2 +=    "STM.TM_SERVICO = ? AND "
        cQryDepen2 +=    "STM.TM_SEQRELA = ? AND "
        cQryDepen2 +=    "STM.TM_DEPENDE = ? AND "
        cQryDepen2 +=    "STM.D_E_L_E_T_ = ' ' "

        cQryDepen2 := ChangeQuery( cQryDepen2 )

    EndIf

    aAdd( aBind, FWxFilial( 'STM' ) )
    aAdd( aBind, oGrid01:GetValue( 'CODVEIC1' ) )
    aAdd( aBind, oGrid01:GetValue( 'TF_SERVICO' ) )
    aAdd( aBind, oGrid01:GetValue( 'TF_SEQRELA' ) )
    aAdd( aBind, oGrid02:GetValue( 'T5_TAREFA' ) )

    dbUseArea( .T., 'TOPCONN', TcGenQry2( , , cQryDepen2, aBind ), cAlsSTM, .T., .T. )

    While (cAlsSTM)->( !EoF() )

        If oGrid02:SeekLine( { { 'CODVEIC2', (cAlsSTM)->TM_CODBEM },;
            { 'T5_TAREFA', (cAlsSTM)->TM_TAREFA } } )

            /*-----------------------------------------------+
            | Impede a desmarcação de uma tarefa dependente. |
            +-----------------------------------------------*/
            If oGrid02:GetValue( 'OK' )
                
                oMod411:SetErrorMessage( 'GRID02', 'OK', 'GRID02', , 'DEPENDTAR', STR0020 +; // Esta tarefa não podera ser desmarcada, pois é dependencia para a tarefa: XXXXXX
                    Trim( (cAlsSTM)->TM_TAREFA ), STR0021 ) // Desmarque a tarefa dependente, para então desmarcar esta tarefa.
                
                lRet := .F.

                /*-----------------------------------------------------+
                | Devolve a posição a tarefa que originou a validação. |
                +-----------------------------------------------------*/
                oGrid02:SeekLine( { { 'CODVEIC2', (cAlsSTM)->TM_CODBEM },;
                    { 'T5_TAREFA', (cAlsSTM)->TM_DEPENDE } } )

                Exit

            EndIf

        EndIf

        (cAlsSTM)->( dbSkip() )

    End

    (cAlsSTM)->( dbCloseArea() )

    FWFreeArray( aBind )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fCriaTemp
Cria a tabela temporária da rotina.
@type function

@author Alexandre Santos
@since 13/09/2023

@param
@return
/*/
//---------------------------------------------------------------------
Static Function fCriaTemp()
    
    Local aFldVeic := {}
    Local aFldManu := {}
    Local cAlsVeic := GetNextAlias()
    Local cAlsManu := GetNextAlias()

    aAdd( aFldVeic, { 'CODBEM', 'C', FWTamSX3( 'T9_CODBEM' )[1]     , 00                          } )
    aAdd( aFldVeic, { 'DSCBEM', 'C', FWTamSX3( 'T9_NOME' )[1]       , 00                          } )
    aAdd( aFldVeic, { 'PLACA' , 'C', FWTamSX3( 'T9_PLACA' )[1]      , 00                          } )
    aAdd( aFldVeic, { 'ACUVEI', 'N', FWTamSX3( 'T5_CONMANU' )[1]    , FWTamSX3( 'T5_CONMANU' )[2] } )
    aAdd( aFldVeic, { 'VARDIA', 'N', FWTamSX3( 'T9_VARDIA' )[1]     , FWTamSX3( 'T9_VARDIA' )[2]  } )
    aAdd( aFldVeic, { 'SERVIC', 'C', FWTamSX3( 'TF_SERVICO' )[1]    , 00                          } )
    aAdd( aFldVeic, { 'SEQREL', 'C', FWTamSX3( 'TF_SEQRELA' )[1]    , FWTamSX3( 'T5_CONMANU' )[2] } )
    
	oTempVeic := FWTemporaryTable():New( cAlsVeic, aFldVeic )
	
    oTempVeic:AddIndex( '1' , { 'CODBEM' } )

	oTempVeic:Create()

    aAdd( aFldManu, { 'CODBEM', 'C', FWTamSX3( 'T9_CODBEM' )[1]     , 00                          } )
    aAdd( aFldManu, { 'TAREFA', 'C', FWTamSX3( 'T5_TAREFA' )[1]     , 00                          } )
    aAdd( aFldManu, { 'DESCTA', 'C', FWTamSX3( 'T5_DESCRIC' )[1]    , 00                          } )
    aAdd( aFldManu, { 'ULTMAN', 'D', 08                             , 00                          } )
    aAdd( aFldManu, { 'INCHOD', 'N', FWTamSX3( 'T5_INENMA' )[1]     , FWTamSX3( 'T5_INENMA' )[2]  } )
    aAdd( aFldManu, { 'INCTEM', 'C', FWTamSX3( 'T5_TEENMA' )[1] + 10, 00                          } )
    aAdd( aFldManu, { 'ACUMAN', 'N', FWTamSX3( 'T5_CONMANU' )[1]    , FWTamSX3( 'T5_CONMANU' )[2] } )
    aAdd( aFldManu, { 'ACUATU', 'N', FWTamSX3( 'T5_CONMANU' )[1]    , FWTamSX3( 'T5_CONMANU' )[2] } )
    aAdd( aFldManu, { 'EXCEKM', 'N', FWTamSX3( 'T5_CONMANU' )[1]    , FWTamSX3( 'T5_CONMANU' )[2] } )
    aAdd( aFldManu, { 'EXCDIA', 'N', 08                             , 00                          } )
    
	oTempManu := FWTemporaryTable():New( cAlsManu, aFldManu )
	
    oTempManu:AddIndex( '1' , { 'CODBEM', 'TAREFA' } )
    oTempManu:AddIndex( '2' , { 'ACUATU', 'CODBEM', 'TAREFA' } )
    oTempManu:AddIndex( '3' , { 'EXCEKM', 'CODBEM', 'TAREFA' } )
    oTempManu:AddIndex( '4' , { 'EXCDIA', 'CODBEM', 'TAREFA' } )

	oTempManu:Create()

    FWFreeArray( aFldVeic )
    FWFreeArray( aFldManu )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fGravaTemp
Cria a tabela temporária da rotina.
@type function

@author Alexandre Santos
@since 13/09/2023

@param
@return
/*/
//---------------------------------------------------------------------
Static Function fGravaTemp( cAlsST9 )
    
    Local aHistCnt  := {}
    Local cAlsVeic  := oTempVeic:GetAlias()
    Local cAlsManu  := oTempManu:GetAlias()
    Local cIncrManu := ''
    Local nCntAtual := 0
    Local nExcesCnt := 0
    Local nExcesDia := 0
    Local nExceDia2 := 0
    Local nIncConve := 0
    Local nAcumVeic := 0
    Local nVariaDia := 0

    /*------------------------------------+
    | Limpa tabela temporária de veículos |
    +------------------------------------*/
    dbSelectArea( cAlsVeic )
    Zap

    /*---------------------------------------+
    | Limpa tabela temporária de manutenções |
    +---------------------------------------*/
    dbSelectArea( cAlsManu )
    Zap

    While (cAlsST9)->( !EoF() )

        nCntAtual := 0
        nExcesCnt := 0
        nExcesDia := 0
        nExceDia2 := 0
        nIncConve := 0
        nAcumVeic := 0
        nVariaDia := 0
        cIncrManu := ''

        dbSelectArea( cAlsVeic )
        dbSetOrder( 1 )

        If !msSeek( (cAlsST9)->T9_CODBEM )

            If (cAlsST9)->CONTADOR != 0
            
                /*-----------------------------------------------------------+
                | Retorna acumulado e vardia do bem no ATE DATA ou anterior. |
                +-----------------------------------------------------------*/
                aHistCnt := NGACUMEHIS( (cAlsST9)->T9_CODBEM, oMaster:GetValue( 'DATAPREVI' ),;
                    oMaster:GetValue( 'HORAPREVI' ), (cAlsST9)->CONTADOR, 'E' )

                nAcumVeic := aHistCnt[2]
                nVariaDia := aHistCnt[6]

            Else

                nAcumVeic := 0
                nVariaDia := 0

            EndIf

            RecLock( cAlsVeic, .T. )
                
                (cAlsVeic)->CODBEM := (cAlsST9)->T9_CODBEM
                (cAlsVeic)->DSCBEM := (cAlsST9)->T9_NOME
                (cAlsVeic)->PLACA  := (cAlsST9)->T9_PLACA
                (cAlsVeic)->SERVIC := (cAlsST9)->TF_SERVICO
                (cAlsVeic)->SEQREL := (cAlsST9)->TF_SEQRELA
                (cAlsVeic)->ACUVEI := nAcumVeic
                (cAlsVeic)->VARDIA := nVariaDia

            MsUnLock()

        Else

            /*---------------------------------------------+
            | Valores de contador já carregados na tabela. |
            +---------------------------------------------*/
            nAcumVeic := (cAlsVeic)->ACUVEI
            nVariaDia := (cAlsVeic)->VARDIA
		
        EndIf

        /*-------------------------------------------------------------+
        | Regras excluisivas para manutenção com controle de contador. |
        +-------------------------------------------------------------*/
        If !( (cAlsST9)->TF_TIPACOM == 'T' )

            /*----------------------------------------------------------------+
            | Calculo definido pela subtração do contador acumulado do veiculo |
            | pelo acumulado da ultima manutenção executada.                   |
            +-----------------------------------------------------------------*/
            nCntAtual := ( nAcumVeic - (cAlsST9)->T5_CONMANU )

            /*--------------------------------------------------------------------------+
            | Subtração do incremento da manutenção pelo KM atual desde a ultima manut. |
            +--------------------------------------------------------------------------*/
            nExcesCnt := ( nAcumVeic - ( (cAlsST9)->T5_CONMANU + (cAlsST9)->T5_INENMA ) )

            /*-----------------------------------------------------------------+
            | Conversão do excesso em KM para dias, utilizando a Variação Dia. |
            +-----------------------------------------------------------------*/
            nExcesDia := Round( ( nExcesCnt / nVariaDia ), 0 )

        EndIf

        /*----------------------------------------------------------+
        | Regras excluisivas para manutenção com controle de tempo. |
        +----------------------------------------------------------*/
        If (cAlsST9)->TF_TIPACOM $ 'A/T'

            Do Case
                
                Case (cAlsST9)->T5_UNENMA == 'H'
                    
                    nIncConve := ( (cAlsST9)->T5_TEENMA / 24 )
                    cIncrManu := Trim( cValToChar( (cAlsST9)->T5_TEENMA ) ) + STR0016 // Hora(s)

                Case (cAlsST9)->T5_UNENMA == 'D'

                    nIncConve := ( (cAlsST9)->T5_TEENMA )
                    cIncrManu := Trim( cValToChar( (cAlsST9)->T5_TEENMA ) ) + STR0017 // Dia(s)

                Case (cAlsST9)->T5_UNENMA == 'S'
                    
                    nIncConve := ( (cAlsST9)->T5_TEENMA * 7 )
                    cIncrManu := Trim( cValToChar( (cAlsST9)->T5_TEENMA ) ) + STR0018 // Semana(s)

                Case (cAlsST9)->T5_UNENMA == 'M'
                    
                    nIncConve := ( (cAlsST9)->T5_TEENMA * 30 )
                    cIncrManu := Trim( cValToChar( (cAlsST9)->T5_TEENMA ) ) + STR0019 // Mes(es)
            
            End Case

            /*-----------------------------------------------+
            | Dias excedidos da data de manutenção prevista. |
            +-----------------------------------------------*/
            nExceDia2 := Round( oMaster:GetValue( 'DATAPREVI' ) -;
                ( SToD( (cAlsST9)->T5_DTULTMA ) + nIncConve ), 0 )

            /*---------------------------------------------------------------------------+
            | Quando possui controle de Tempo e Contador, pega o maior valor de excesso, |
            | pois está mais proximo do vencimento.                                      |
            +---------------------------------------------------------------------------*/
            If nExceDia2 > nExcesDia

                nExcesDia := nExceDia2

            EndIf

        EndIf

        RecLock( cAlsManu, .T. )

            (cAlsManu)->CODBEM := (cAlsST9)->T9_CODBEM
            (cAlsManu)->TAREFA := (cAlsST9)->T5_TAREFA
            (cAlsManu)->DESCTA := (cAlsST9)->T5_DESCRIC
            (cAlsManu)->ULTMAN := SToD( (cAlsST9)->T5_DTULTMA )
            (cAlsManu)->INCHOD := (cAlsST9)->T5_INENMA
            (cAlsManu)->INCTEM := cIncrManu
            (cAlsManu)->ACUMAN := (cAlsST9)->T5_CONMANU
            (cAlsManu)->ACUATU := nCntAtual
            (cAlsManu)->EXCEKM := nExcesCnt
            (cAlsManu)->EXCDIA := nExcesDia

        MsUnLock()

        (cAlsST9)->( dbSkip() )

    End

    FWFreeArray( aHistCnt )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fLoadModel
Cria a tabela temporária da rotina.
@type function

@author Alexandre Santos
@since 20/09/2023

@param
@return
/*/
//---------------------------------------------------------------------
Static Function fLoadModel()
    
    Local cAlsVeic := oTempVeic:GetAlias()
    Local cAlsManu := oTempManu:GetAlias()
    Local cCodVeic := ''

    oGrid01:SetNoInsertLine( .F. )
    oGrid01:ClearData()

    oGrid02:SetNoInsertLine( .F. )
    oGrid02:ClearData()

    dbSelectArea( cAlsManu )
    dbSetOrder( oMaster:GetValue( 'ORDENAPOR' ) )
    dbGoTop()

    While (cAlsManu)->( !EoF() )
        
        If !oGrid01:SeekLine( { { 'CODVEIC1', (cAlsManu)->CODBEM } } )

            dbSelectArea( cAlsVeic )
            dbSetOrder( 1 )
            msSeek( (cAlsManu)->CODBEM )

            If !oGrid01:IsEmpty()
        
                oGrid01:AddLine()
        
                oGrid01:GoLine( oGrid01:Length() )

            Endif

            oGrid01:LoadValue( 'CODVEIC1'  , (cAlsVeic)->CODBEM )
            oGrid01:LoadValue( 'T9_NOME'   , (cAlsVeic)->DSCBEM )
            oGrid01:LoadValue( 'T9_PLACA'  , (cAlsVeic)->PLACA  )
            oGrid01:LoadValue( 'KMATUAL2'  , (cAlsVeic)->ACUVEI )
            oGrid01:LoadValue( 'TF_SERVICO', (cAlsVeic)->SERVIC  )
            oGrid01:LoadValue( 'TF_SEQRELA', (cAlsVeic)->SEQREL )
            oGrid01:LoadValue( 'PRIMARKEY' , 'XX' )

            cCodVeic := (cAlsManu)->CODBEM
		
        EndIf

        If !oGrid02:IsEmpty()
        
            oGrid02:AddLine()
        
            oGrid02:GoLine( oGrid02:Length() )

        EndIf

        oGrid02:LoadValue( 'OK'        , .F.                )
        oGrid02:LoadValue( 'LEGEND'    , fLegend()          )
        oGrid02:LoadValue( 'CODVEIC2'  , (cAlsManu)->CODBEM )
        oGrid02:LoadValue( 'T5_TAREFA' , (cAlsManu)->TAREFA )
        oGrid02:LoadValue( 'T5_DESCRIC', (cAlsManu)->DESCTA )
        oGrid02:LoadValue( 'T5_DTULTMA', (cAlsManu)->ULTMAN )
        oGrid02:LoadValue( 'T5_CONMANU', (cAlsManu)->ACUMAN )
        oGrid02:LoadValue( 'KMATUAL3'  , (cAlsManu)->ACUATU )
        oGrid02:LoadValue( 'KMEXCESSO' , (cAlsManu)->EXCEKM )
        oGrid02:LoadValue( 'DIASEXCES' , (cAlsManu)->EXCDIA )
        
        oGrid02:GoLine( 1 )

        (cAlsManu)->( dbSkip() )

    End

    oGrid01:SetNoInsertLine( .T. )
    oGrid01:GoLine( 1 )

    oGrid02:SetNoInsertLine( .T. )
    oGrid02:GoLine( 1 )
    
    oVie411:ApplyModifyToViewByModel()
    oVie411:Refresh()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fUpdLegend
Atualiza legenda das tarefas com situação atual das tarefas.
@type function

@author Alexandre Santos
@since 17/01/2024

@param
@return
/*/
//---------------------------------------------------------------------
Static Function fUpdLegend()

    Local nInd1   := 0
    Local nInd2   := 0
    Local nLinGD1 := 0
    Local nLinGD2 := 0

    oGrid02:SetNoInsertLine( .F. )

    For nInd1 := 1 To oGrid01:Length()

        oGrid01:GoLine( nInd1 )

        For nInd2 := 1 To oGrid02:Length()

            oGrid02:GoLine( nInd2 )

            If oGrid02:GetValue( 'OK' )

                If Empty( nLinGD2 )

                    nLinGD1 := nInd1
                    nLinGD2 := nInd2

                EndIf

                /*------------------------------+
                | Atualiza situação da legenda. |
                +------------------------------*/
                oGrid02:LoadValue( 'LEGEND', fLegend( oGrid02:GetValue( 'T5_TAREFA' ) , oGrid02:GetValue( 'CODVEIC2' ), oGrid01:GetValue( 'TF_SERVICO' ),;
                    oGrid01:GetValue( 'TF_SEQRELA' ), oGrid02:GetValue( 'KMEXCESSO' ), oGrid02:GetValue( 'DIASEXCES' ) ) )
                
                /*----------------------------------------------------+
                | Remove a marcação da tarefa que já teve O.S. gerada |
                +----------------------------------------------------*/
                oGrid02:LoadValue( 'OK', .F. )

            EndIf

        Next nInd2

    Next nInd1

    If !Empty( nLinGD2 )
        
        /*-----------------------------------------------------+
        | Posiciona na primeira tarefa marcada para gerar O.S. |
        +-----------------------------------------------------*/
        oGrid01:GoLine( nLinGD1 )
        oGrid02:GoLine( nLinGD2 )

    EndIf

    oGrid02:SetNoInsertLine( .T. )

    oVie411:ApplyModifyToViewByModel()
    oVie411:Refresh()
    
Return
