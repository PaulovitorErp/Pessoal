#INCLUDE 'mntr696.ch' 

//---------------------------------------------------------------------
/*/{Protheus.doc} Mntr696
Relatório de manutenções múltiplas.
@type function

@author Alexandre Santos 
@since 07/08/2023

@param oFilter, object, Objeto FWMbrowse contendo filtros aplicados.
@return
/*/
//---------------------------------------------------------------------
Function MNTR696( oFilter )

    Local cFilter   := fGetFilter( oFilter:oFwFilter )
    Local nSizeCont := FWTamSX3( 'T5_CONMANU' )[1] + FWTamSX3( 'T5_CONMANU' )[2] 
    Local oSec1
    Local oSec2
    Local oReport   := TReport():New( 'MNTR696', STR0019, '',; // Manutenções Multíplas
        { |oReport| ReportPrint( oReport, cFilter ) }, , .T. )
    
    If MV_PAR13 == 2

        oSec1 := TRSection():New( oReport, STR0016, cAls696 ) // Modelo

        TRCell():New( oSec1, 'MODELO', cAls696, STR0016, , FWTamSX3( 'TQR_TIPMOD' )[1]  ) // Modelo

    EndIf

    oSec2 := TRSection():New( oReport, STR0004, cAls696 ) // Tarefa

    TRCell():New( oSec2, 'CODBEM', cAls696, STR0003, , FWTamSX3( 'T9_CODBEM' )[1]       ) // Veículo
    TRCell():New( oSec2, 'TAREFA', cAls696, STR0004, , FWTamSX3( 'T5_TAREFA' )[1]       ) // Tarefa
    TRCell():New( oSec2, 'DESCTA', cAls696, STR0018, , FWTamSX3( 'T5_DESCRIC' )[1]      ) // Desc. Tarefa
    TRCell():New( oSec2, 'ULTMAN', cAls696, STR0005, , 10                               ) // Dt. Ult. Exec.
    TRCell():New( oSec2, 'ULTHOD', cAls696, STR0006, , nSizeCont                        ) // KM Ult. Exec.
    TRCell():New( oSec2, 'QTDEXE', cAls696, STR0007, , 04                               ) // Qtde. Exec.
    TRCell():New( oSec2, 'QTDPRE', cAls696, STR0008, , 04                               ) // Qtde. Prev.
    TRCell():New( oSec2, 'HODATU', cAls696, STR0009, , nSizeCont                        ) // KM Atual
    TRCell():New( oSec2, 'INCHOD', cAls696, STR0010, , nSizeCont                        ) // Inc. Cont.
    TRCell():New( oSec2, 'INCTEM', cAls696, STR0011, , FWTamSX3( 'T5_TEENMA'  )[1] + 10 ) // Inc. Temp.
    TRCell():New( oSec2, 'PROXMA', cAls696, STR0012, , 10                               ) // Dt. Prox.
    TRCell():New( oSec2, 'KMPERC', cAls696, STR0015, , nSizeCont                        ) // KM Perc.
    TRCell():New( oSec2, 'EXCEKM', cAls696, STR0013, , nSizeCont                        ) // Excesso KM
    TRCell():New( oSec2, 'EXCDIA', cAls696, STR0014, , 04                               ) // Excesso Dias
    TRCell():New( oSec2, 'VENCID', cAls696, STR0017, ,                                  ) // Manut. Vencida

    oReport:DisableOrientation() 
    oReport:SetLandscape()
    oReport:PrintDialog()
    
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Impressão do relatório.
@type function

@author Alexandre Santos 
@since 07/08/2023

@param oReport, objeto, TReport.
@param cFilter, string, Filtro aplicado ao browse MNTC696.
/*/
//---------------------------------------------------------------------
Static Function ReportPrint( oReport, cFilter )
    
    Local nIndTab := 0
    Local nTotReg := 0
    Local oSec1   := Nil
    Local oSec2   := Nil

    Set Filter To &( cFilter )

    Count To nTotReg

    oReport:SetMeter( nTotReg )

    If MV_PAR13 == 2
        
         Do Case

            Case MV_PAR12 == 1

                nIndTab := 5 // MODELO + CODBEM

            Case MV_PAR12 == 2

                nIndTab := 6 // MODELO + HODATU

            Case MV_PAR12 == 3

                nIndTab := 7 // MODELO + EXCDIA

            Case MV_PAR12 == 4

                nIndTab := 8 // MODELO + EXCEKM

        End Case

        oSec1 := oReport:Section( 1 )
        oSec2 := oReport:Section( 2 )

        

        dbSelectArea( cAls696 )
        dbSetOrder( nIndTab )
        dbGoTop()

        While (cAls696)->( !EoF() )

            oSec1:Init()
            oSec1:PrintLine()

            cLoop := (cAls696)->MODELO 

            oSec2:Init()

            While (cAls696)->( !EoF() ) .And. cLoop == (cAls696)->MODELO

                oReport:IncMeter()

                oSec2:PrintLine()

                (cAls696)->( dbSkip() )

            End

            oSec2:Finish()
            oSec1:Finish()

        End
        
        

    Else

        Do Case

            Case MV_PAR12 == 1

                nIndTab := 1 // CODBEM

            Case MV_PAR12 == 2

                nIndTab := 2 // HODATU

            Case MV_PAR12 == 3

                nIndTab := 3 // EXCDIA

            Case MV_PAR12 == 4

                nIndTab := 4 // EXCEKM

        End Case

        oSec1 := oReport:Section( 1 )

        oSec1:Init()

        dbSelectArea( cAls696 )
        dbSetOrder( nIndTab )
        dbGoTop()

        While (cAls696)->( !EoF() )

            oSec1:PrintLine()

            (cAls696)->( dbSkip() )

        End
        
        oSec1:Finish()

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetFilter
Busca filtro aplicado no browse da consulta MNTC696.
@type function

@author Alexandre Santos 
@since 04/09/2023

@param oFilter, objeto, Objeto filtro aplicado ao browse MNTC696.
/*/
//---------------------------------------------------------------------
Static Function fGetFilter( oFilter )

    Local cFilter := ''
    Local nInd1   := 1

    For nInd1 := 1 To Len( oFilter:aFilter )

        If oFilter:aFilter[nInd1,6]

            If !Empty( cFilter )

                cFilter += ' .And. '
                
            EndIf

            cFilter += oFilter:aFilter[nInd1,2]

        EndIf
        
    Next nInd1
    
Return cFilter
