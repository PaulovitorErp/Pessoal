#include 'protheus.ch'
#include 'FWMVCDEF.ch'  
#include 'mntc696.ch' 

#define _CODVEIC_  1  // Codigo do veículo
#define _DTULTMA_  2  // Data da ultima manutenção
#define _TIPACOM_  3  // Tipo de acompanhamento
#define _TEENMAN_  4  // Tempo de incremento
#define _UNENMAN_  5  // Unidade de tempo
#define _CONMANU_  6  // Acumulado da manutenção
#define _INENMAN_  7  // Incremento de Contador
#define _TIPCONT_  8  // Tipo de Contandor utilizado na manutenção
#define _VARIDIA_  9  // Variação dia na ultima manutenção
#define _CONMAN2_  10 // Acumulado na penultima manutenção
#define _ACUMATE_  11 // Acumulado (ATE DATA) 
#define _VDIAATE_  12 // Variação Dia (ATE DATA)

Static cQrySTJ1
Static cQrySTJ2
Static cQrySTJ3
Static cQrySTQ1 

//---------------------------------------------------------------------
/*/{Protheus.doc} Mntc696
Consulta de Manutenções Multiplas
@type function

@author Alexandre Santos
@since 01/08/2023

@param 
@return 
/*/
//---------------------------------------------------------------------
Function Mntc696()

    Local oProc696

    Private cAls696 := GetNextAlias()
    Private oBrw696
    
    If Pergunte( 'MNC696', .T. )
        
        /*-------------------------------------------+
        | Cria e carrega dados na tabela temporária. |
        +-------------------------------------------*/
        fCriaTemp()

        /*-------------------------------------------+
        | Faz a carga de dados na tabela temporária. |
        +-------------------------------------------*/
        oProc696 := MsNewProcess():New ( { |lEnd| fLoadTemp( @oProc696 ) }, STR0027, , .T. ) // Filtrando
        oProc696:Activate()
        
        /*-------------------------------------------------+
        | Cria browse conforme dados da tabela temporária. |
        +-------------------------------------------------*/
        fCriaBrow()

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fCriaTemp
Cria a tabela temporária da rotina.
@type function

@author Alexandre Santos
@since 05/08/2023

@param
@return
/*/
//---------------------------------------------------------------------
Function fCriaTemp( )

    Local aFields  := {}
    Local oTemp696

    aAdd( aFields, { 'FILIAL', 'C', FWSizeFilial()                 , 00                          } )
    aAdd( aFields, { 'CODBEM', 'C', FWTamSX3( 'T9_CODBEM' )[1]     , 00                          } )
    aAdd( aFields, { 'MODELO', 'C', FWTamSX3( 'T9_TIPMOD' )[1]     , 00                          } )
    aAdd( aFields, { 'TAREFA', 'C', FWTamSX3( 'T5_TAREFA' )[1]     , 00                          } )
    aAdd( aFields, { 'DESCTA', 'C', FWTamSX3( 'T5_DESCRIC' )[1]    , 00                          } )
    aAdd( aFields, { 'ULTMAN', 'D', 08                             , 00                          } )
    aAdd( aFields, { 'ULTHOD', 'N', FWTamSX3( 'T5_CONMANU' )[1]    , FWTamSX3( 'T5_CONMANU' )[2] } )
    aAdd( aFields, { 'QTDEXE', 'N', 04                             , 00                          } )
    aAdd( aFields, { 'QTDPRE', 'N', 04                             , 00                          } )
    aAdd( aFields, { 'HODATU', 'N', FWTamSX3( 'T5_CONMANU' )[1]    , FWTamSX3( 'T5_CONMANU' )[2] } )
    aAdd( aFields, { 'INCHOD', 'N', FWTamSX3( 'T5_INENMA' )[1]     , FWTamSX3( 'T5_INENMA' )[2]  } )
    aAdd( aFields, { 'INCTEM', 'C', FWTamSX3( 'T5_TEENMA' )[1] + 10, 00                          } )
    aAdd( aFields, { 'PROXMA', 'D', 08                             , 00                          } )
    aAdd( aFields, { 'KMPERC', 'N', FWTamSX3( 'T5_CONMANU' )[1]    , FWTamSX3( 'T5_CONMANU' )[2] } )
    aAdd( aFields, { 'EXCEKM', 'N', FWTamSX3( 'T5_CONMANU' )[1]    , FWTamSX3( 'T5_CONMANU' )[2] } )
    aAdd( aFields, { 'EXCDIA', 'N', 08                             , 00                          } )
    aAdd( aFields, { 'VENCID', 'C', 03                             , 00                          } )
    
	oTemp696 := FWTemporaryTable():New( cAls696, aFields )
	
    oTemp696:AddIndex( '1' , { 'CODBEM' } )
    oTemp696:AddIndex( '2' , { 'HODATU' } )
    oTemp696:AddIndex( '3' , { 'EXCDIA' } )
    oTemp696:AddIndex( '4' , { 'EXCEKM' } )
    oTemp696:AddIndex( '5' , { 'MODELO', 'CODBEM' } )
    oTemp696:AddIndex( '6' , { 'MODELO', 'HODATU' } )
    oTemp696:AddIndex( '7' , { 'MODELO', 'EXCDIA' } )
    oTemp696:AddIndex( '8' , { 'MODELO', 'EXCEKM' } )

	oTemp696:Create()
    
Return 

//---------------------------------------------------------------------
/*/{Protheus.doc} fLoadTemp
Carga inicial da tabela temporária da rotina.
@type function

@author Alexandre Santos
@since 06/08/2023

@param oProc696, object, Objeto MsNewProcess.
@return
/*/
//---------------------------------------------------------------------
Static Function fLoadTemp( oProc696 )

    Local aBind      := {}
    Local aPeriodic  := {}
    Local cManVencid := ''
    Local cAlsST5    := GetNextAlias()
    Local dProxManut := CToD( '' )
    Local cIncrManut := ''
    Local nContAtual := 0
    Local nContPerco := 0
    Local nExcesCont := 0
    Local nExcesDias := 0
    Local nExcesDia2 := 0
    Local nQtdeTotal := 0
    Local nQtdeAtual := 0
    Local nQtdTotal2 := 0
    Local nQtdAtual2 := 0

    If Empty( cQrySTJ3 )

        cQrySTJ3 := "SELECT "
        cQrySTJ3 +=      "ST9.T9_CODFIL ,
        cQrySTJ3 +=      "ST9.T9_CODBEM ,
        cQrySTJ3 +=      "ST9.T9_TIPMOD ,
        cQrySTJ3 +=      "STF.TF_SERVICO,
        cQrySTJ3 +=      "STF.TF_SEQRELA,
        cQrySTJ3 +=      "STF.TF_TIPACOM,
        cQrySTJ3 +=      "ST5.T5_TAREFA ,
        cQrySTJ3 +=      "ST5.T5_DESCRIC,
        cQrySTJ3 +=      "ST5.T5_DTULTMA,
        cQrySTJ3 +=      "ST5.T5_CONMANU,
        cQrySTJ3 +=      "ST5.T5_INENMA ,
        cQrySTJ3 +=      "ST5.T5_TEENMA ,
        cQrySTJ3 +=      "ST5.T5_UNENMA
        cQrySTJ3 += "FROM "
        cQrySTJ3 +=    RetSQLName( 'ST9' ) + " ST9 "
        cQrySTJ3 += "INNER JOIN "
        cQrySTJ3 +=    RetSQLName( 'STF' ) + " STF ON "
        cQrySTJ3 +=        NGMODCOMP( 'ST9', 'STF', , , , 'T9_CODFIL', 'TF_FILIAL' ) + " AND "
        cQrySTJ3 +=        "STF.TF_CODBEM  = ST9.T9_CODBEM AND "
        cQrySTJ3 +=        "STF.TF_PERIODO = 'M'           AND "
        cQrySTJ3 +=        "STF.TF_ATIVO   = 'S'           AND "
        cQrySTJ3 +=        "STF.D_E_L_E_T_ = ' ' "
        cQrySTJ3 += "INNER JOIN "
        cQrySTJ3 +=    RetSQLName( 'ST5' ) + " ST5 ON "
        cQrySTJ3 +=        "ST5.T5_FILIAL  = STF.TF_FILIAL  AND "
        cQrySTJ3 +=        "ST5.T5_CODBEM  = STF.TF_CODBEM  AND "
        cQrySTJ3 +=        "ST5.T5_SERVICO = STF.TF_SERVICO AND "
        cQrySTJ3 +=        "ST5.T5_SEQRELA = STF.TF_SEQRELA AND "
        cQrySTJ3 +=        "ST5.T5_ATIVA   = '1'            AND "
        cQrySTJ3 +=        "ST5.D_E_L_E_T_ = ' ' "
        cQrySTJ3 += "WHERE "
        cQrySTJ3 +=    "ST9.T9_CODFIL  BETWEEN ? AND ? AND "
        cQrySTJ3 +=    "ST9.T9_CODBEM  BETWEEN ? AND ? AND "
        cQrySTJ3 +=    "ST9.T9_CODFAMI BETWEEN ? AND ? AND "
        cQrySTJ3 +=    "ST9.T9_TIPMOD  BETWEEN ? AND ? AND "
        cQrySTJ3 +=    "( ( ? = 3 )                         OR "
        cQrySTJ3 +=    "  ( ? = 1 AND ST9.T9_SITMAN = 'A' ) OR "
        cQrySTJ3 +=    "  ( ? = 2 AND ST9.T9_SITMAN IN ( 'I', 'T' ) ) ) AND "
        cQrySTJ3 +=    "ST9.D_E_L_E_T_ = ' ' "

        cQrySTJ3 := ChangeQuery( cQrySTJ3 )

    EndIf

    aAdd( aBind, MV_PAR01 )
    aAdd( aBind, MV_PAR02 )
	aAdd( aBind, MV_PAR09 )
    aAdd( aBind, MV_PAR10 )
	aAdd( aBind, MV_PAR05 )
	aAdd( aBind, MV_PAR06 )
    aAdd( aBind, MV_PAR07 )
    aAdd( aBind, MV_PAR08 )
    aAdd( aBind, cValToChar( MV_PAR11 ) )
    aAdd( aBind, cValToChar( MV_PAR11 ) )
    aAdd( aBind, cValToChar( MV_PAR11 ) )

    dbUseArea( .T., 'TOPCONN', TcGenQry2( , , cQrySTJ3, aBind ), cAlsST5, .T., .T. )

    oProc696:SetRegua1( ( nQtdeTotal := fQtdeQuery( ) ) )

    (cAlsST5)->( dbGoTop() )

    While (cAlsST5)->( !EoF() )

        cManVencid := STR0020 // NÃO 
        dProxManut := CToD( '' )
        nContAtual := 0
        nContPerco := 0
        nExcesCont := 0
        nExcesDias := 0
        nExcesDia2 := 0
        nQtdeAtual := 0
        nQtdAtual2 := 0
        cIncrManut := ''
        aPeriodic  := Array( 12, Nil )

        Do Case
            
            Case (cAlsST5)->TF_TIPACOM == 'S'

                /*------------------------------+
                | Acompanhamento por Contador 2 |
                +------------------------------*/
                aPeriodic[_CONMANU_] := (cAlsST5)->T5_CONMANU
                aPeriodic[_INENMAN_] := (cAlsST5)->T5_INENMA
                aPeriodic[_TIPCONT_] := 2

            Case (cAlsST5)->TF_TIPACOM == 'A'

                /*--------------------------------------+
                | Acompanhamento por Contador 1 e Tempo |
                +--------------------------------------*/
                aPeriodic[_CONMANU_] := (cAlsST5)->T5_CONMANU
                aPeriodic[_INENMAN_] := (cAlsST5)->T5_INENMA
                aPeriodic[_TEENMAN_] := (cAlsST5)->T5_TEENMA
                aPeriodic[_UNENMAN_] := (cAlsST5)->T5_UNENMA
                aPeriodic[_TIPCONT_] := 1

            Case (cAlsST5)->TF_TIPACOM == 'T'

                /*-------------------------+
                | Acompanhamento por Tempo |
                +-------------------------*/
                aPeriodic[_TEENMAN_] := (cAlsST5)->T5_TEENMA
                aPeriodic[_UNENMAN_] := (cAlsST5)->T5_UNENMA

            OtherWise

                /*------------------------------+
                | Acompanhamento por Contador 1 |
                +------------------------------*/
                aPeriodic[_CONMANU_] := (cAlsST5)->T5_CONMANU
                aPeriodic[_INENMAN_] := (cAlsST5)->T5_INENMA
                aPeriodic[_TIPCONT_] := 1

        End Case

        aPeriodic[_DTULTMA_] := SToD( (cAlsST5)->T5_DTULTMA )
        aPeriodic[_TIPACOM_] := (cAlsST5)->TF_TIPACOM

        If Empty( aPeriodic[_CODVEIC_] ) .Or.;
            !( aPeriodic[_CODVEIC_] == (cAlsST5)->T5_CODBEM )

            /*-----------------------------------------+
            | Incremento do processamento de veículos. |
            +-----------------------------------------*/
            nQtdeAtual++
            oProc696:IncRegua1( STR0029 + cValToChar( nQtdeAtual ) + STR0028 + cValToChar( nQtdeTotal ) ) // Filtrando veículos XX de XX
            
            oProc696:SetRegua2( ( nQtdTotal2 := fQtdeQuery( (cAlsST5)->T9_CODBEM ) ) )

            aPeriodic[_CODVEIC_] := (cAlsST5)->T9_CODBEM

        EndIf

        /*----------------------------------------+
        | Incremento do processamento de tarefas. |
        +----------------------------------------*/
        nQtdAtual2++
        oProc696:IncRegua2( STR0030 + Trim( (cAlsST5)->T9_CODBEM ) +; // Tarefas do veículo: XXXX
            ' ' + cValToChar( nQtdAtual2 ) + STR0028 + cValToChar( nQtdTotal2 ) ) // XX de XX

        /*---------------------------------+
        | Busca data da ultima manutenção. |
        +---------------------------------*/
        fGetUltima( (cAlsST5)->T9_CODBEM, (cAlsST5)->TF_SERVICO,;
            (cAlsST5)->TF_SEQRELA, (cAlsST5)->T5_TAREFA, @aPeriodic )
        
        /*----------------------------------------------------+
        | Retorna quantidade de previsão e execução da tarefa |
        +----------------------------------------------------*/
        aExecSTQ  := fGetExecut( (cAlsST5)->T9_CODBEM, (cAlsST5)->TF_SERVICO,;
            (cAlsST5)->TF_SEQRELA, (cAlsST5)->T5_TAREFA )

        /*-------------------------------------------------------------+
        | Regras excluisivas para manutenção com controle de contador. |
        +-------------------------------------------------------------*/
        If !( aPeriodic[_TIPACOM_] == 'T' )

            If Empty( aPeriodic[_ACUMATE_] )
                
                /*-----------------------------------------------------------+
                | Retorna acumulado e vardia do bem no ATE DATA ou anterior. |
                +-----------------------------------------------------------*/
                aHisCntATE := NGACUMEHIS( (cAlsST5)->T9_CODBEM, MV_PAR04, '23:59', aPeriodic[_TIPCONT_], 'E' )

                aPeriodic[_ACUMATE_] := aHisCntATE[2]
                aPeriodic[_VDIAATE_] := aHisCntATE[6]

            EndIf

            /*--------------------------------------------------------------------------------+
            | Calculo definido pela subtração do contador acumulado em (ATE DATA) ou anterior |
            | pelo acumulado da ultima manutenção executada.                                  |
            +--------------------------------------------------------------------------------*/
            nContAtual := ( aPeriodic[_ACUMATE_] - aPeriodic[_CONMANU_] )

            /*----------------------------------------------------+
            | Km percorrida da penultima até a ultima manutenção. |
            +----------------------------------------------------*/
            nContPerco := ( aPeriodic[_CONMANU_] - aPeriodic[_CONMAN2_] )

            /*--------------------------------------------------------------------------+
            | Subtração do incremento da manutenção pelo KM atual desde a ultima manut. |
            +--------------------------------------------------------------------------*/
            nExcesCont := ( aPeriodic[_ACUMATE_] - ( aPeriodic[_CONMANU_] + aPeriodic[_INENMAN_] ) )
           
            /*-----------------------------------------------------------------+
            | Conversão do excesso em KM para dias, utilizando a Variação Dia. |
            +-----------------------------------------------------------------*/
            nExcesDias := Round( ( nExcesCont / aPeriodic[_VDIAATE_] ), 0 )

        EndIf

        /*----------------------------------------------------------+
        | Regras excluisivas para manutenção com controle de tempo. |
        +----------------------------------------------------------*/
        If aPeriodic[_TIPACOM_] $ 'A/T'

            Do Case
                
                Case aPeriodic[_UNENMAN_] == 'H'
                    
                    nIncConver := ( aPeriodic[_TEENMAN_] / 24 )
                    cIncrManut := Trim( cValToChar( aPeriodic[_TEENMAN_] ) ) + STR0015 // Hora(s)

                Case aPeriodic[_UNENMAN_] == 'D'

                    nIncConver := ( aPeriodic[_TEENMAN_] )
                    cIncrManut := Trim( cValToChar( aPeriodic[_TEENMAN_] ) ) + STR0016 // Dia(s)

                Case aPeriodic[_UNENMAN_] == 'S'
                    
                    nIncConver := ( aPeriodic[_TEENMAN_] * 7 )
                    cIncrManut := Trim( cValToChar( aPeriodic[_TEENMAN_] ) ) + STR0017 // Semana(s)

                Case aPeriodic[_UNENMAN_] == 'M'
                    
                    nIncConver := ( aPeriodic[_TEENMAN_] * 30 )
                    cIncrManut := Trim( cValToChar( aPeriodic[_TEENMAN_] ) ) + STR0018 // Mes(es)
            
            End Case

            /*-----------------------------------------------+
            | Dias excedidos da data de manutenção prevista. |
            +-----------------------------------------------*/
            nExcesDia2 := Round( ( MV_PAR04 - ( aPeriodic[_DTULTMA_] + nIncConver ) ), 0 )

            /*---------------------------------------------------------------------------+
            | Quando possui controle de Tempo e Contador, pega o menor valor de excesso, |
            | pois está mais proximo de 0 que seria o dia programado da manutenção.      |
            +---------------------------------------------------------------------------*/
            If nExcesDia2 > nExcesDias

                nExcesDias := nExcesDia2

            EndIf

        EndIf
        
        /*-----------------------------------------+
        | Calculo para data da proxima manutenção. |
        +-----------------------------------------*/
        dProxManut  := NGProxMan( aPeriodic[_DTULTMA_], aPeriodic[_TIPACOM_], aPeriodic[_TEENMAN_], aPeriodic[_UNENMAN_],;
            aPeriodic[_CONMANU_], aPeriodic[_INENMAN_], aPeriodic[_ACUMATE_], aPeriodic[_VDIAATE_], aPeriodic[_DTULTMA_],;
            aPeriodic[_CODVEIC_] )

        /*---------------------------------------------------------------------+
        | Se o valor for positido indica que a manutenção encontra-se vencida. |
        +---------------------------------------------------------------------*/
        If nExcesDias > 0 .Or. nExcesCont > 0
            
            cManVencid := STR0019 // SIM

        EndIf
     
        RecLock( (cAls696), .T. )

            FILIAL := (cAlsST5)->T9_CODFIL
            CODBEM := aPeriodic[_CODVEIC_]
            MODELO := (cAlsST5)->T9_TIPMOD
            TAREFA := (cAlsST5)->T5_TAREFA
            DESCTA := (cAlsST5)->T5_DESCRIC
            ULTMAN := aPeriodic[_DTULTMA_]
            ULTHOD := aPeriodic[_CONMANU_]
            QTDEXE := aExecSTQ[1]
            QTDPRE := aExecSTQ[2]
            HODATU := nContAtual
            INCHOD := aPeriodic[_INENMAN_]
            INCTEM := cIncrManut
            PROXMA := dProxManut
            KMPERC := nContPerco
            EXCEKM := nExcesCont
            EXCDIA := nExcesDias
            VENCID := cManVencid

        MsUnLock()

        (cAlsST5)->( dbSkip() )

    End

    (cAlsST5)->( dbCloseArea() )

    FWFreeArray( aBind )
    FWFreeArray( aPeriodic )
    
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fCriaBrow
Cria o browse principal da consulta.
@type function

@author Alexandre Santos
@since 07/08/2023

@param 
@return
/*/
//---------------------------------------------------------------------
Static Function fCriaBrow( )

    Local aFldsBrw := {}
    Local aFiltBrw := {}
    Local aPesqBrw := {}
    Local aTamCont := FWTamSX3( 'T5_CONMANU' )
    Local aTamIneM := FWTamSX3( 'T5_INENMA' )
    
    aAdd( aFldsBrw, { STR0001, 'FILIAL', 'C', FwSizeFilial()                  , 00         , '@!'                      } ) // Filial
    aAdd( aFldsBrw, { STR0002, 'CODBEM', 'C', FWTamSX3( 'T9_CODBEM' )[1]      , 00         , '@!'                      } ) // Veículo
    aAdd( aFldsBrw, { STR0031, 'MODELO', 'C', FWTamSX3( 'TQR_TIPMOD' )[1]     , 00         , '@!'                      } ) // Modelo
    aAdd( aFldsBrw, { STR0003, 'TAREFA', 'C', FWTamSX3( 'T5_TAREFA' )[1]      , 00         , '@!'                      } ) // Tarefa
    aAdd( aFldsBrw, { STR0021, 'DESCTA', 'C', FWTamSX3( 'T5_DESCRIC' )[1]     , 00         , '@!'                      } ) // Desc. Tarefa
    aAdd( aFldsBrw, { STR0004, 'ULTMAN', 'D', 08                              , 00         , '99/99/99'                } ) // Data Ult. Execução
    aAdd( aFldsBrw, { STR0005, 'ULTHOD', 'N', aTamCont[1]                     , aTamCont[2], X3Picture( 'T5_CONMANU' ) } ) // Km Ult. Execução
    aAdd( aFldsBrw, { STR0006, 'QTDEXE', 'N', 04                              , 00         , '9999'                    } ) // Qtd. Exec.
    aAdd( aFldsBrw, { STR0007, 'QTDPRE', 'N', 04                              , 00         , '9999'                    } ) // Qtd. Prev.
    aAdd( aFldsBrw, { STR0008, 'HODATU', 'N', aTamCont[1]                     , aTamCont[2], X3Picture( 'T5_CONMANU' ) } ) // Km Atual
    aAdd( aFldsBrw, { STR0009, 'INCHOD', 'N', aTamIneM[1]                     , aTamIneM[2], X3Picture( 'T5_INENMA' )  } ) // Inc. Cont.
    aAdd( aFldsBrw, { STR0010, 'INCTEM', 'C', FWTamSX3( 'T5_TEENMA'  )[1] + 10, 00         , '@!'                      } ) // Inc. Tempo
    aAdd( aFldsBrw, { STR0011, 'PROXMA', 'D', 08                              , 00         , '99/99/99'                } ) // Data Prox.
    aAdd( aFldsBrw, { STR0012, 'KMPERC', 'N', aTamCont[1]                     , aTamCont[2], X3Picture( 'T5_CONMANU' ) } ) // Km Perc. Ult. Exec.
    aAdd( aFldsBrw, { STR0013, 'EXCEKM', 'N', aTamCont[1]                     , aTamCont[2], X3Picture( 'T5_CONMANU' ) } ) // Excesso Km
    aAdd( aFldsBrw, { STR0014, 'EXCDIA', 'N', 08                              , 00         , '99999999'                } ) // Excesso Dias

    aAdd( aFiltBrw, { 'FILIAL', STR0001, 'C', FWSizeFilial()                  , 00         , '@!'                      } ) // Filial
    aAdd( aFiltBrw, { 'CODBEM', STR0002, 'C', FWTamSX3( 'T9_CODBEM' )[1]      , 00         , '@!'                      } ) // Veículo
    aAdd( aFiltBrw, { 'MODELO', STR0031, 'C', FWTamSX3( 'TQR_TIPMOD' )[1]     , 00         , '@!'                      } ) // Modelo
    aAdd( aFiltBrw, { 'TAREFA', STR0003, 'C', FWTamSX3( 'T5_TAREFA' )[1]      , 00         , '@!'                      } ) // Tarefa
    aAdd( aFiltBrw, { 'DESCTA', STR0021, 'C', FWTamSX3( 'T5_DESCRIC' )[1]     , 00         , '@!'                      } ) // Desc. Tarefa
    aAdd( aFiltBrw, { 'ULTMAN', STR0004, 'D', 08                              , 00         , '99/99/99'                } ) // Data Ult. Execução
    aAdd( aFiltBrw, { 'ULTHOD', STR0005, 'N', aTamCont[1]                     , aTamCont[2], X3Picture( 'T5_CONMANU' ) } ) // Km Ult. Execução
    aAdd( aFiltBrw, { 'QTDEXE', STR0006, 'N', 04                              , 00         , '9999'                    } ) // Qtd. Exec.
    aAdd( aFiltBrw, { 'QTDPRE', STR0007, 'N', 04                              , 00         , '9999'                    } ) // Qtd. Prev.
    aAdd( aFiltBrw, { 'HODATU', STR0008, 'N', aTamCont[1]                     , aTamCont[2], X3Picture( 'T5_CONMANU' ) } ) // Km Atual
    aAdd( aFiltBrw, { 'INCHOD', STR0009, 'N', aTamIneM[1]                     , aTamIneM[2], X3Picture( 'T5_INENMA' )  } ) // Inc. Cont.
    aAdd( aFiltBrw, { 'INCTEM', STR0010, 'C', FWTamSX3( 'T5_TEENMA'  )[1] + 10, 00         , '@!'                      } ) // Inc. Tempo
    aAdd( aFiltBrw, { 'PROXMA', STR0011, 'D', 08                              , 00         , '99/99/99'                } ) // Data Prox.
    aAdd( aFiltBrw, { 'KMPERC', STR0012, 'N', aTamCont[1]                     , aTamCont[2], X3Picture( 'T5_CONMANU' ) } ) // Km Perc. Ult. Exec.
    aAdd( aFiltBrw, { 'EXCEKM', STR0013, 'N', aTamCont[1]                     , aTamCont[2], X3Picture( 'T5_CONMANU' ) } ) // Excesso Km
    aAdd( aFiltBrw, { 'EXCDIA', STR0014, 'N', 08                              , 00         , '99999999'                } ) // Excesso Dias

    aAdd( aPesqBrw, { STR0002, { { '', 'C', 255, 0, '', '@!' } } } )

    oBrw696:= FWMBrowse():New()
	oBrw696:SetDescription( STR0023 ) // Consulta de Manutenções Multíplas
	oBrw696:SetTemporary( .T. )
	oBrw696:SetAlias( cAls696 )
	oBrw696:SetFields( aFldsBrw )
    oBrw696:SetFieldFilter( aFiltBrw )
    oBrw696:DisableReport()
    oBrw696:SetMenuDef( 'MNTC696' )
	oBrw696:SetProfileID( '2' )
    oBrw696:AddLegend( "VENCID == 'NÃO'", 'GREEN', STR0024 ) // Não Vencida
	oBrw696:AddLegend( "VENCID == 'SIM'", 'RED'  , STR0022 ) // Vencida
	oBrw696:SetSeek( .T., aPesqBrw )
	oBrw696:Activate()

    FWFreeArray( aFldsBrw )
    FWFreeArray( aFiltBrw )
    FWFreeArray( aPesqBrw )
    FWFreeArray( aTamCont )
    FWFreeArray( aTamIneM )
    
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetUltima
Busca ultima e penultima apontamento da manutenção.
@type function

@author Alexandre Santos
@since 20/08/2023

@param cCodBem  , string, Código do bem.
@param cCodSer  , string, Serviço.
@param cSeqRel  , string, Sequência da Manutenção.
@param cTarefa  , string, Tarefa Multipla.
@param aPeriodic, array , Detalhes da periodicidade da manutenção.
@return array , [1] - Quant. Prevista.
                [2] - Quant. Executada.
/*/
//---------------------------------------------------------------------
Static Function fGetUltima( cCodBem, cCodSer, cSeqRel, cTarefa, aPeriodic )
    
    Local aBind     := {}
    Local aHistCont := {}
    Local cAlsSTJ   := GetNextAlias()
    Local nLoop     := 0

    If Empty( cQrySTJ1 )
        
        cQrySTJ1 := "SELECT "
        cQrySTJ1 +=   "STJ.TJ_CODBEM , "
        cQrySTJ1 +=   "STJ.TJ_DTMRFIM, "
        cQrySTJ1 +=   "STJ.TJ_HORACO1, "
        cQrySTJ1 +=   "STJ.TJ_HORACO2  "
        cQrySTJ1 += "FROM "
        cQrySTJ1 +=   RetSQLName( 'STJ' ) + " STJ "
        cQrySTJ1 += "INNER JOIN "
        cQrySTJ1 +=   RetSQLName( 'STQ' ) + " STQ ON "
        cQrySTJ1 +=       "STQ.TQ_ORDEM   = STJ.TJ_ORDEM  AND "
        cQrySTJ1 +=       "STQ.TQ_PLANO   = STJ.TJ_PLANO  AND "
        cQrySTJ1 +=       "STQ.TQ_TAREFA  = ?             AND "
        cQrySTJ1 +=       "STQ.TQ_OK     <> ' '           AND "
        cQrySTJ1 +=       "STQ.D_E_L_E_T_ = ' ' "   
        cQrySTJ1 += "WHERE "
        cQrySTJ1 +=   "STJ.TJ_SERVICO = ?   AND "
        cQrySTJ1 +=   "STJ.TJ_SEQRELA = ?   AND "
        cQrySTJ1 +=   "STJ.TJ_CODBEM  = ?   AND "
        cQrySTJ1 +=   "STJ.TJ_TERMINO = 'S' AND "
        cQrySTJ1 +=   "( CASE "
        cQrySTJ1 +=       "WHEN ? > ? THEN ? " 
        cQrySTJ1 +=       "ELSE ? "
        cQrySTJ1 +=     "END ) >= STJ.TJ_DTMRFIM AND "
        cQrySTJ1 +=   "STJ.D_E_L_E_T_ = ' ' " 
        cQrySTJ1 += "ORDER BY "
        cQrySTJ1 +=   "STJ.TJ_DTMRFIM DESC "
        
        cQrySTJ1 := ChangeQuery( cQrySTJ1 )
    
    EndIf

    aAdd( aBind, cTarefa )
	aAdd( aBind, cCodSer )
    aAdd( aBind, cSeqRel )
    aAdd( aBind, cCodBem )
	aAdd( aBind, DToS( aPeriodic[_DTULTMA_] ) )
	aAdd( aBind, DToS( MV_PAR04 ) )
    aAdd( aBind, DToS( MV_PAR04 ) )
    aAdd( aBind, DToS( aPeriodic[_DTULTMA_] ) )

	dbUseArea( .T., 'TOPCONN', TcGenQry2( , , cQrySTJ1, aBind ), cAlsSTJ, .T., .T. )

    If (cAlsSTJ)->( !EoF() )

        /*---------------------------------------------------------------------------+
        | Loop executado apenas para as duas ultimas O.S. finalizadas da manutenção. |
        +---------------------------------------------------------------------------*/
        While nLoop < 2

            If nLoop == 0

                aPeriodic[_DTULTMA_] := SToD( (cAlsSTJ)->TJ_DTMRFIM )
                
                If aPeriodic[_TIPCONT_] == 1

                    /*------------------------------------------------------------------------------+
                    | Calcula Variação e Acumulado do cont. 1 na data de finalização da ultima O.S. |
                    +------------------------------------------------------------------------------*/
                    aHistCont := NGACUMEHIS( (cAlsSTJ)->TJ_CODBEM, aPeriodic[_DTULTMA_],;
                        (cAlsSTJ)->TJ_HORACO1, aPeriodic[_TIPCONT_], 'E' )

                    aPeriodic[_CONMANU_] := aHistCont[2]
                    aPeriodic[_VARIDIA_] := aHistCont[6]

                ElseIf aPeriodic[_TIPCONT_] == 2

                    /*------------------------------------------------------------------------------+
                    | Calcula Variação e Acumulado do cont. 2 na data de finalização da ultima O.S. |
                    +------------------------------------------------------------------------------*/
                    aHistCont := NGACUMEHIS( (cAlsSTJ)->TJ_CODBEM, aPeriodic[_DTULTMA_],;
                        (cAlsSTJ)->TJ_HORACO2, aPeriodic[_TIPCONT_], 'E' )

                    aPeriodic[_CONMANU_] := aHistCont[2]
                    aPeriodic[_VARIDIA_] := aHistCont[6]

                EndIf

            Else

                If (cAlsSTJ)->( !EoF() )

                    If aPeriodic[_TIPCONT_] == 1

                        /*----------------------------------------------------------------------+
                        | Calcula Acumulado do cont. 1 na data de finalização da penultima O.S. |
                        +----------------------------------------------------------------------*/
                        aPeriodic[_CONMAN2_] := NGACUMEHIS( (cAlsSTJ)->TJ_CODBEM, SToD( (cAlsSTJ)->TJ_DTMRFIM ),;
                            (cAlsSTJ)->TJ_HORACO1, aPeriodic[_TIPCONT_], 'E' )[2]

                    ElseIf aPeriodic[_TIPCONT_] == 2

                        /*----------------------------------------------------------------------+
                        | Calcula Acumulado do cont. 2 na data de finalização da penultima O.S. |
                        +----------------------------------------------------------------------*/
                        aPeriodic[_CONMAN2_] := NGACUMEHIS( (cAlsSTJ)->TJ_CODBEM, SToD( (cAlsSTJ)->TJ_DTMRFIM ),;
                            (cAlsSTJ)->TJ_HORACO2, aPeriodic[_TIPCONT_], 'E' )[2]

                    EndIf

                Else

                    /*--------------------------------------------------------------------+
                    | Caso não exista penultima O.S. finalizada, valor considerado será 0 |
                    +--------------------------------------------------------------------*/
                    aPeriodic[_CONMAN2_] := 0

                EndIf

            EndIf

            nLoop++

            (cAlsSTJ)->( dbSkip() )

        End
    
    Else

        /*--------------------------------------------------------------------------------------------+
        | Caso NÃO exista O.S. finalizada, variação será anterior ao informado no parâmetro ATÉ DATA. |
        +--------------------------------------------------------------------------------------------*/
        aHistCont := NGACUMEHIS( cCodBem, aPeriodic[_DTULTMA_], '23:59', aPeriodic[_TIPCONT_], 'E' )

        aPeriodic[_VARIDIA_] := aHistCont[6]
        aPeriodic[_CONMAN2_] := 0
        
    EndIf

    (cAlsSTJ)->( dbCloseArea() )

    FWFreeArray( aHistCont )
    FWFreeArray( aBind )
    
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetExecut
Busca quantidade prevista e executada para determinada tarefa.
@type function

@author Alexandre Santos
@since 25/08/2023

@param cCodBem, string, Código do bem.
@param cCodSer, string, Serviço.
@param cSeqRel, string, Sequência da Manutenção.
@param cTarefa, string, Tarefa Multipla.
@return array , [1] - Quant. Prevista.
                [2] - Quant. Executada.
/*/
//---------------------------------------------------------------------
Static Function fGetExecut( cCodBem, cCodSer, cSeqRel, cTarefa )

    Local aRet    := { 0, 0 }
    Local aBind   := {}
    Local cAlsSTQ := GetNextAlias()

    If Empty( cQrySTQ1 )

        cQrySTQ1 := "SELECT " 
        cQrySTQ1 +=     "PREVISTO.QTDE_PREV, "
        cQrySTQ1 +=     "REALIZAD.QTDE_EXEC "
        cQrySTQ1 += "FROM "
        cQrySTQ1 +=     "(   SELECT " 
        cQrySTQ1 +=             "STQ1.TQ_TAREFA, "
        cQrySTQ1 +=             "COUNT( 1 ) AS QTDE_PREV "
        cQrySTQ1 +=         "FROM "
        cQrySTQ1 +=              RetSQLName( 'STJ' ) + " STJ1 "
        cQrySTQ1 +=         "LEFT JOIN " 
        cQrySTQ1 +=              RetSQLName( 'STQ' ) + " STQ1 ON "
        cQrySTQ1 +=                 "STQ1.TQ_ORDEM   = STJ1.TJ_ORDEM AND "
        cQrySTQ1 +=                 "STQ1.TQ_PLANO   = STJ1.TJ_PLANO AND "
        cQrySTQ1 +=                 "STQ1.TQ_TAREFA  = ?             AND "
        cQrySTQ1 +=                 "STQ1.D_E_L_E_T_ = ' ' "
        cQrySTQ1 +=         "WHERE "
        cQrySTQ1 +=             "STJ1.TJ_SERVICO  = ?   AND "
        cQrySTQ1 +=             "STJ1.TJ_SEQRELA  = ?   AND "
        cQrySTQ1 +=             "STJ1.TJ_CODBEM   = ?   AND "
        cQrySTQ1 +=             "STJ1.TJ_SITUACA <> 'C' AND "
        cQrySTQ1 +=             "STJ1.TJ_DTMPINI BETWEEN ? AND ? AND "
        cQrySTQ1 +=             "STJ1.D_E_L_E_T_ = ' ' "
        cQrySTQ1 +=         "GROUP BY "
        cQrySTQ1 +=             "STQ1.TQ_TAREFA ) PREVISTO "
        cQrySTQ1 += "INNER JOIN "
        cQrySTQ1 +=     "(   SELECT " 
        cQrySTQ1 +=             "STQ2.TQ_TAREFA, "
        cQrySTQ1 +=             "COUNT( 1 ) AS QTDE_EXEC "
        cQrySTQ1 +=         "FROM "
        cQrySTQ1 +=             RetSQLName( 'STJ' ) + " STJ2 "
        cQrySTQ1 +=         "LEFT JOIN " 
        cQrySTQ1 +=             RetSQLName( 'STQ' ) + " STQ2 ON "
        cQrySTQ1 +=                 "STQ2.TQ_ORDEM   = STJ2.TJ_ORDEM AND "
        cQrySTQ1 +=                 "STQ2.TQ_PLANO   = STJ2.TJ_PLANO AND "
        cQrySTQ1 +=                 "STQ2.TQ_TAREFA  = ?             AND "
        cQrySTQ1 +=                 "STQ2.TQ_OK     <> ' '           AND "
        cQrySTQ1 +=                 "STQ2.D_E_L_E_T_ = ' ' "
        cQrySTQ1 +=         "WHERE "
        cQrySTQ1 +=             "STJ2.TJ_SERVICO  = ?   AND "
        cQrySTQ1 +=             "STJ2.TJ_SEQRELA  = ?   AND "
        cQrySTQ1 +=             "STJ2.TJ_CODBEM   = ?   AND "
        cQrySTQ1 +=             "STJ2.TJ_SITUACA <> 'C' AND "
        cQrySTQ1 +=             "STJ2.TJ_DTMPINI BETWEEN ? AND ? AND "
        cQrySTQ1 +=             "STJ2.D_E_L_E_T_ = ' ' "
        cQrySTQ1 +=         "GROUP BY "
        cQrySTQ1 +=             "STQ2.TQ_TAREFA ) REALIZAD "
        cQrySTQ1 += "ON ( REALIZAD.TQ_TAREFA = PREVISTO.TQ_TAREFA ) "
        
        cQrySTQ1 := ChangeQuery( cQrySTQ1 )
    
    EndIf

    aAdd( aBind, cTarefa )
	aAdd( aBind, cCodSer )
    aAdd( aBind, cSeqRel )
    aAdd( aBind, cCodBem )
	aAdd( aBind, DToS( MV_PAR03 ) )
	aAdd( aBind, DToS( MV_PAR04 ) )
    aAdd( aBind, cTarefa )
	aAdd( aBind, cCodSer )
    aAdd( aBind, cSeqRel )
    aAdd( aBind, cCodBem )
	aAdd( aBind, DToS( MV_PAR03 ) )
	aAdd( aBind, DToS( MV_PAR04 ) )

	dbUseArea( .T., 'TOPCONN', TcGenQry2( , , cQrySTQ1, aBind ), cAlsSTQ, .T., .T. )

    If (cAlsSTQ)->( !EoF() )

        aRet[1] := (cAlsSTQ)->QTDE_PREV
        aRet[2] := (cAlsSTQ)->QTDE_EXEC

    EndIf
    
    (cAlsSTQ)->( dbCloseArea() )

    FWFreeArray( aBind )
    
Return aRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fQtdeQuery
Retorna quantidade de registros que serão processados.
@type function

@author Alexandre Santos
@since 04/09/2023

@param [cCodBem], string, Código do bem.
@return integer , Quantidade de registros processados.
/*/
//---------------------------------------------------------------------
Static Function fQtdeQuery( cCodBem )

    Local aBind     := {}
    Local cAlsSTJ   := GetNextAlias()
    Local nResult   := 0

    Default cCodBem := ' '

    If Empty( cQrySTJ2 )

        cQrySTJ2 := "SELECT "
        cQrySTJ2 +=     "COUNT( 1 ) AS QTDE_REG" 
        cQrySTJ2 += "FROM "
        cQrySTJ2 +=    RetSQLName( 'ST9' ) + " ST9 "
        cQrySTJ2 += "INNER JOIN "
        cQrySTJ2 +=    RetSQLName( 'STF' ) + " STF ON "
        cQrySTJ2 +=        NGMODCOMP( 'ST9', 'STF', , , , 'T9_CODFIL', 'TF_FILIAL' ) + " AND "
        cQrySTJ2 +=        "STF.TF_CODBEM  = ST9.T9_CODBEM AND "
        cQrySTJ2 +=        "STF.TF_PERIODO = 'M'           AND "
        cQrySTJ2 +=        "STF.D_E_L_E_T_ = ' ' "
        cQrySTJ2 += "INNER JOIN "
        cQrySTJ2 +=    RetSQLName( 'ST5' ) + " ST5 ON "
        cQrySTJ2 +=        "ST5.T5_FILIAL  = STF.TF_FILIAL  AND "
        cQrySTJ2 +=        "ST5.T5_CODBEM  = STF.TF_CODBEM  AND "
        cQrySTJ2 +=        "ST5.T5_SERVICO = STF.TF_SERVICO AND "
        cQrySTJ2 +=        "ST5.T5_SEQRELA = STF.TF_SEQRELA AND "
        cQrySTJ2 +=        "ST5.D_E_L_E_T_ = ' ' "
        cQrySTJ2 += "WHERE "
        cQrySTJ2 +=    "ST9.T9_CODFIL  BETWEEN ? AND ? AND "
        cQrySTJ2 +=    "( ( ? = ' ' AND ST9.T9_CODBEM  BETWEEN ? AND ? ) OR "
        cQrySTJ2 +=    "  ( ST9.T9_CODBEM = ? ) )      AND "
        cQrySTJ2 +=    "ST9.T9_CODFAMI BETWEEN ? AND ? AND "
        cQrySTJ2 +=    "ST9.T9_TIPMOD  BETWEEN ? AND ? AND "
        cQrySTJ2 +=    "( ( ? = 3 )                         OR "
        cQrySTJ2 +=    "  ( ? = 1 AND ST9.T9_SITMAN = 'A' ) OR "
        cQrySTJ2 +=    "  ( ? = 2 AND ST9.T9_SITMAN IN ( 'I', 'T' ) ) ) AND "
        cQrySTJ2 +=    "ST9.D_E_L_E_T_ = ' ' "

        cQrySTJ2 := ChangeQuery( cQrySTJ2 )

    EndIf

    aAdd( aBind, MV_PAR01 )
    aAdd( aBind, MV_PAR02 )
	aAdd( aBind, cCodBem )
	aAdd( aBind, MV_PAR09 )
    aAdd( aBind, MV_PAR10 )
    aAdd( aBind, cCodBem )
	aAdd( aBind, MV_PAR05 )
	aAdd( aBind, MV_PAR06 )
    aAdd( aBind, MV_PAR07 )
    aAdd( aBind, MV_PAR08 )
    aAdd( aBind, cValToChar( MV_PAR11 ) )
    aAdd( aBind, cValToChar( MV_PAR11 ) )
    aAdd( aBind, cValToChar( MV_PAR11 ) )

    dbUseArea( .T., 'TOPCONN', TcGenQry2( , , cQrySTJ2, aBind ), cAlsSTJ, .T., .T. )

    If (cAlsSTJ)->( !EoF() )

        nResult := (cAlsSTJ)->QTDE_REG
            
    EndIf

    (cAlsSTJ)->( dbCloseArea() )

    FWFreeArray( aBind )
    
Return nResult

//---------------------------------------------------------------------
/*/{Protheus.doc} MNC696Perg
Apresenta o pergunte MNC696 e faz o reload da consulta.
@type function

@author Alexandre Santos
@since 30/08/2023

@param
@return
/*/
//---------------------------------------------------------------------
Function MNC696Perg()

    Local oProc696

	If Pergunte( 'MNC696', .T. )
		
        dbSelectArea( cAls696 )
        Zap

	    oProc696 := MsNewProcess():New ( { |lEnd| fLoadTemp( @oProc696 ) }, STR0027, , .T. ) // Filtrando
        oProc696:Activate()

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu da rotina
@type function

@author Alexandre Santos
@since 30/08/2023

@param
@return
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0025 ACTION 'MNTR696( oBrw696 )' OPERATION 6 ACCESS 0 // Imprimir
    ADD OPTION aRotina TITLE STR0026 ACTION 'MNC696Perg'         OPERATION 3 ACCESS 0 // Nova Consulta

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} Mntc696Vld
Valid. das perguntas MNC696.
@type function

@author Alexandre Santos
@since 30/08/2023

@param cField  , string, Indica qual pergunta será validada.
@return boolean, Indica se o conteúdo digitado esta valido.
/*/
//---------------------------------------------------------------------
Function Mntc696Vld( cField )

    Local lRet := .T.

    Do Case

        Case cField == '01' // De Filial

            If !Empty( MV_PAR01 )

                lRet := ExistCPO( 'SM0', SM0->M0_CODIGO + MV_PAR01 )

            EndIf

            If lRet .And. !Empty( MV_PAR02 ) .And.;
                !( MV_PAR02 == Replicate( 'Z', FwSizeFilial() ) )

                lRet := AteCodigo( 'SM0', SM0->M0_CODIGO + MV_PAR01, SM0->M0_CODIGO + MV_PAR02, 10 )

            EndIf

        Case cField == '02' // Até Filial

            If !( MV_PAR02 == Replicate( 'Z', FwSizeFilial() ) )
			
				lRet := AteCodigo( 'SM0', SM0->M0_CODIGO + MV_PAR01, SM0->M0_CODIGO + MV_PAR02, 10 )
				
			EndIf

        Case cField == '03' // De Data

            lRet := NaoVazio( MV_PAR03 )

            If lRet .And. !Empty( MV_PAR04 ) .And.;
                MV_PAR03 > MV_PAR04

                Help( '', 1, 'DATAINVALI' )

                lRet := .F.

            EndIf

        Case cField == '04' // Até Data

            If MV_PAR03 > MV_PAR04

                Help( '', 1, 'DATAINVALI' )

                lRet := .F.

            EndIf

        Case cField == '05' // De Família

            If !Empty( MV_PAR05 )

                lRet := ExistCPO( 'ST6', MV_PAR05, 1 )

            EndIf

            If lRet .And. !Empty( MV_PAR06 ) .And.;
                !( MV_PAR06 == Replicate( 'Z', FWTamSX3( 'T6_CODFAMI' )[1] ) )

                lRet := AteCodigo( 'ST6', MV_PAR05, MV_PAR06, 10 )

            EndIf

        Case cField == '06' // Até Família

            If !( MV_PAR06 == Replicate( 'Z', FWTamSX3( 'T6_CODFAMI' )[1] ) )
			
				lRet := AteCodigo( 'ST6', MV_PAR05, MV_PAR06, 10 )
				
			EndIf

        Case cField == '07' // De Modelo

            If !Empty( MV_PAR07 )

                lRet := ExistCPO( 'TQR', MV_PAR07, 1 )

            EndIf

            If lRet .And. !Empty( MV_PAR08 ) .And.;
                !( MV_PAR08 == Replicate( 'Z', FWTamSX3( 'TQR_TIPMOD' )[1] ) )

                lRet := AteCodigo( 'TQR', MV_PAR07, MV_PAR08, 10 )

            EndIf

        Case cField == '08' // Até Modelo

            If !( MV_PAR08 == Replicate( 'Z', FWTamSX3( 'TQR_TIPMOD' )[1] ) )
			
				lRet := AteCodigo( 'TQR', MV_PAR07, MV_PAR08, 10 )
				
			EndIf

        Case cField == '09' // De Veículo

            If !Empty( MV_PAR09 )

                lRet := ExistCPO( 'ST9', MV_PAR09, 1 )

            EndIf

            If lRet .And. !Empty( MV_PAR10 ) .And.;
                !( MV_PAR10 == Replicate( 'Z', FWTamSX3( 'T9_CODBEM' )[1] ) )

                lRet := AteCodigo( 'ST9', MV_PAR09, MV_PAR10, 10 )

            EndIf
        
        Case cField == '10' // Até Veículo

            If !( MV_PAR10 == Replicate( 'Z', FWTamSX3( 'T9_CODBEM' )[1] ) )
			
				lRet := AteCodigo( 'ST9', MV_PAR09, MV_PAR10, 10 )
				
			EndIf
        
        Case cField == '11' // Situação do Veículo

            lRet := NaoVazio( MV_PAR11 ) 
        
        Case cField == '12' // Ordenar Por

            lRet := NaoVazio( MV_PAR12 ) 

        Case cField == '13' // Agrupar Por

            lRet := NaoVazio( MV_PAR13 ) 

    End Case
    
Return lRet
