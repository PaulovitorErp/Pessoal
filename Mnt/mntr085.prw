#include "PROTHEUS.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "MNTR085.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR085
Etiquetas de Pneus

@author Maria Elisandra de Paula
@since 08/09/20

@return
/*/
//---------------------------------------------------------------------
Function MNTR085()

    Local cPerg := PadR( "MNTR085", 10 )

    If Pergunte( cPerg, .T. )

        Processa({|| MNTR085IMP()})

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR085IMP
Impressão do relatório

@author Maria Elisandra de Paula
@since 08/09/20
@return
/*/
//---------------------------------------------------------------------
Static Function MNTR085IMP()

    Local nWidth    := 0
    Local nInd      := 0
    Local nCol1     := 200
    Local nCol2     := 900
    Local nCol3     := 1200
    Local nCol4     := 1500
    Local nCol5     := 1800
    Local nCol6     := 2200
    Local nLin1     := 400
    Local nLin2     := 650
    Local nLin3     := 900
    Local nLin4     := 1150
    Local nLin5     := 1400
    Local nInc      := 1400
    Local aBox      := {}
    Local aInf      := {}
    Local oFont1    := TFont():New( "Arial" ,,14,,.F.)
    Local oFont2    := TFont():New( "Arial" ,,22,,.T.)
    Local oFont3    := TFont():New( "Arial" ,,30,,.T.)
    Local oFont4    := TFont():New( "Arial" ,,35,,.T.)
    Local oPrint
    Local lQrCode   := MV_PAR07 == 1
    Local cFilNF    := ''
    Local cCiclo    := ''
    Local cSulco    := ''
    Local cAliasQry := GetNextAlias()

	If CreateTmp( cAliasQry )

        oPrint := FWMSPrinter():New( STR0003, IMP_PDF ) //"Etiquetas de Pneus"
        If oPrint:nModalResult == PD_OK

            nWidth := oPrint:nHorzRes() // Largura do relatório
            oPrint:SetPortrait() //Retrato
            oPrint:SetPaperSize(9)//A4

            aAdd( aBox, { nLin1, nCol1, nLin2, nCol5 + 2 } ) // produto
            aAdd( aBox, { nLin1, nCol5, nLin2, nCol6     } ) // armazém
            aAdd( aBox, { nLin2, nCol1, nLin3, nCol4 + 2 } ) // descri
            aAdd( aBox, { nLin2, nCol4, nLin3, nCol5     } ) // empresa
            aAdd( aBox, { nLin2, nCol5, nLin3, nCol6     } ) // filial

            If lQrCode
                aAdd( aBox, { nLin3, nCol2, nLin4, nCol6 + 2 } ) // pneu
                aAdd( aBox, { nLin3, nCol1, nLin5, nCol2     } ) // qrcode
                aAdd( aBox, { nLin4, nCol2, nLin5, nCol3+2   } ) // ciclo
                aAdd( aBox, { nLin4, nCol3, nLin5, nCol4+2   } ) // sulco
                aAdd( aBox, { nLin4, nCol4, nLin5, nCol6     } ) // dot
            Else
                aAdd( aBox, { nLin3, nCol1, nLin4, nCol4 + 2 } ) // pneu
                aAdd( aBox, { nLin4, nCol1, nLin5, nCol5 + 2 } ) // barra
                aAdd( aBox, { nLin3, nCol4, nLin4, nCol5 + 2 } ) // ciclo
                aAdd( aBox, { nLin3, nCol5, nLin4, nCol6 + 2 } ) // sulco
                aAdd( aBox, { nLin4, nCol5, nLin5, nCol6     } ) // dot
            EndIf

            aAdd( aInf, { nLin1, nCol1, '(cAliasQry)->T9_CODESTO', nCol5, STR0004, oFont3 }) // "CÓDIGO DO PRODUTO"
            aAdd( aInf, { nLin1, nCol5, '(cAliasQry)->T9_LOCPAD',  nCol6, STR0005, oFont3 }) // "ARMAZÉM"
            aAdd( aInf, { nLin2, nCol1, '(cAliasQry)->B1_DESC',    nCol4, STR0006, oFont1 }) // "DESCRIÇÃO"
            aAdd( aInf, { nLin2, nCol4, '(cEmpAnt)',               nCol5, STR0007, oFont2 }) // "EMPRESA NF"
            aAdd( aInf, { nLin2, nCol5, '(cFilNF)',                nCol6, STR0008, oFont2 }) // "FILIAL NF"

            If lQrCode
                aAdd( aInf, { nLin3, nCol2, '(cAliasQry)->T9_CODBEM', nCol6, STR0009, oFont4 }) // "PNEU"
                aAdd( aInf, { nLin4, nCol2, '(cCiclo)',               nCol3, STR0010, oFont2 }) // "CICLO"
                aAdd( aInf, { nLin4, nCol3, 'cSulco',                 nCol4, STR0011, oFont2 }) // "SULCO ATUAL"
                aAdd( aInf, { nLin4, nCol4, '(cAliasQry)->TQS_DOT',   nCol6, STR0012, oFont4 }) //
            Else
                aAdd( aInf, { nLin3, nCol1, '(cAliasQry)->T9_CODBEM', nCol4, STR0009, oFont3 }) // "PNEU"
                aAdd( aInf, { nLin3, nCol4, '(cCiclo)',               nCol5, STR0010, oFont2 }) // "CICLO"
                aAdd( aInf, { nLin3, nCol5, 'cSulco',                 nCol6, STR0011, oFont2 }) // "SULCO ATUAL"
                aAdd( aInf, { nLin4, nCol5, '(cAliasQry)->TQS_DOT',   nCol6, STR0012, oFont4 }) // "DOT"
            EndIf

            While (cAliasQry)->( !EoF() )

                If nInc == 1400
                    nInc := 0
                    oPrint:EndPage()
                    oPrint:StartPage() // Inicia página nova
                Else
                    nInc := 1400
                EndIf

                cCiclo := (cAliasQry)->TQS_BANDAA + '-' + NGRETSX3BOX("TQS_BANDAA",(cAliasQry)->TQS_BANDAA)
                If Empty((cAliasQry)->T9_NFCOMPR)
                    cFilNF := cFilAnt
                Else
                    cFilNF := fRetFil( (cAliasQry)->T9_CODBEM ,(cAliasQry)->T9_NFCOMPR, (cAliasQry)->T9_SERIE, (cAliasQry)->T9_FORNECE, ;
                                (cAliasQry)->T9_LOJA, (cAliasQry)->T9_CODESTO )
                EndIf

                cSulco := cValtoChar( (cAliasQry)->TQS_SULCAT )

                // Imprime caixas
                For nInd := 1 to Len( aBox )
                    oPrint:Box( aBox[nInd,1] + nInc, aBox[nInd,2], aBox[nInd,3] + nInc, aBox[nInd,4] )
                Next nInd

                oFont1 := TFont():New( "Arial" ,,14,,.F.)

                If nInc == 0
                    oPrint:SayAlign(200,1, STR0013,oFont1,nWidth,1,,2,1)  //"Relatório de Etiqueta de Pneus"
                EndIf

                For nInd := 1 to Len( aInf )

                    // Imprime descrições
                    oPrint:SayAlign( aInf[nInd,1] + 20 + nInc , aInf[nInd,2], aInf[nInd,5], oFont1,;
                                    aInf[nInd,4] - aInf[nInd,2] , aInf[nInd,1] + 20 + nInc, , 2, 1 )

                    // Imprime informações
                    oPrint:SayAlign( aInf[nInd,1] + 100 + nInc , aInf[nInd,2], Alltrim( &(aInf[nInd,3])), aInf[nInd,6],;
                                    aInf[nInd,4] - aInf[nInd,2] ,aInf[nInd,1] + 100 + nInc, , 2, 1 )

                Next nInd

                // Imprime código
                If lQrCode
                    oPrint:QrCode( 1350 + nInc, nCol1 + 100 ,(cAliasQry)->T9_CODESTO, 100 )
                Else
                    oPrint:Say( 1200 + nInc, nCol1 + 720, 'PRODUTO', oFont1 )
                    oPrint:Code128(1235 + nInc /*nRow*/, nCol1 + 320 /*nCol*/, (cAliasQry)->T9_CODESTO/*cCode*/,1/*nWidth*/,25/*nHeigth*/,.F./*lSay*/,,250)
                    oPrint:Say( 1370 + nInc, nCol1 + 490 + fSzField( (cAliasQry)->T9_CODESTO ), (cAliasQry)->T9_CODESTO, oFont1 )
                EndIf

                (cAliasQry)->( dbSkip() )

            EndDo

            oPrint:Preview()

            FreeObj( oPrint )

        EndIf

    Else

	    MsgStop( STR0002, STR0001 ) //"Não há pneus para impressão de etiquetas"# "Atenção"

	EndIf

    (cAliasQry)->( dbCloseArea() )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} CreateTmp
Cria tabela temporária

@param cAliasQry, string, alias da temporária
@author Maria Elisandra de Paula
@since 08/09/20
@return
/*/
//---------------------------------------------------------------------
Static Function CreateTmp(cAliasQry)

    BeginSql Alias cAliasQry

        SELECT ST9.T9_CODBEM,
            ST9.T9_NFCOMPR,
            ST9.T9_SERIE,
            ST9.T9_FORNECE,
            ST9.T9_LOJA,
            ST9.T9_CODESTO,
            SB1.B1_DESC,
            ST9.T9_LOCPAD,
            TQS.TQS_BANDAA,
            TQS.TQS_SULCAT,
            TQS.TQS_DOT
        FROM %table:ST9% ST9
        JOIN %table:SB1% SB1
            ON SB1.B1_FILIAL = %xFilial:SB1%
            AND SB1.B1_COD = ST9.T9_CODESTO
            AND SB1.%notdel%
        JOIN %table:TQS% TQS
            ON TQS.TQS_FILIAL = %xFilial:TQS%
            AND ST9.T9_CODBEM = TQS.TQS_CODBEM
            AND TQS.%notdel%
            AND TQS.TQS_DOT BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
        WHERE ST9.T9_FILIAL = %xFilial:ST9%
            AND ST9.T9_CODFAMI BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
            AND ST9.T9_CODBEM BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
            AND ST9.%notdel%
            ORDER BY ST9.T9_CODBEM

    EndSql

Return (cAliasQry)->( !EoF() )

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR085VLD
Valida parâmetros

@author Maria Elisandra de Paula
@since 08/09/20

@param nPerg, numerico, parametro do pergunte que será validado 

@return lógico, define se o conteúdo informado no MV_PARXX é valido
/*/
//---------------------------------------------------------------------
Function MNTR085VLD( nPerg )

    Local aArea := GetArea()
    Local lRet  := .T.

	DO CASE

	    CASE nPerg == 1

	    	lRet := IIf( Empty(MV_PAR01),.T., ExistCpo('ST6',MV_PAR01) )

	    CASE nPerg == 2

			lRet := AteCodigo('ST6', MV_PAR01, MV_PAR02)

		CASE nPerg == 3

            If !Empty( MV_PAR03 ) .And. ExistCpo( 'ST9', MV_PAR03 )

                dbSelectArea( 'ST9' )
                dbSetOrder( 1 ) // T9_FILIAL + T9_CODBEM
                If dbSeek( xFilial( 'ST9' ) + MV_PAR03 ) .And. ST9->T9_CATBEM != '3'

                    Help( ,, STR0014, , STR0015 , 1, 0) // "NÃO CONFORMIDADE" # "O Bem digitado não é um Pneu!"

                    lRet := .F.

                EndIf

            EndIf

        CASE nPerg == 4

            If MV_PAR04 != Replicate( 'Z', Len( MV_PAR04 ) ) .And. ExistCpo("ST9", MV_PAR04)

                dbSelectArea( 'ST9' )
                dbSetOrder( 1 ) // T9_FILIAL + T9_CODBEM
                If dbSeek( xFilial( 'ST9' ) + MV_PAR04 ) .And. ST9->T9_CATBEM != '3'

                    Help( ,, STR0014, , STR0015 , 1, 0) // "NÃO CONFORMIDADE" # "O Bem digitado não é um Pneu!"

                    lRet := .F.

                Else

                    lRet := ATECODIGO("ST9", MV_PAR03, MV_PAR04, Len( MV_PAR04 ) )

                EndIf

            EndIf

        CASE nPerg == 5

            lRet := ValidaDot( MV_PAR05 )

        CASE nPerg == 6

            If MV_PAR06 != Replicate( 'Z', Len( MV_PAR06 ) )

                lRet := ValidaDot( MV_PAR06 )

                If lRet .And. !Empty( MV_PAR05 ) .And. !Empty( MV_PAR06 ) .And. MV_PAR05 > MV_PAR06

                    Help( '', 1, 'DEATEINVAL' )
                    lRet := .F.

                EndIf

            EndIf

    ENDCASE

    RestArea( aArea )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidaDot
Valida parâmetro DOT

@author Maria Elisandra de Paula
@since 08/09/20

@param cDot, string, numero dot

@return lógico, Define se o dot informado é valido
/*/
//---------------------------------------------------------------------
Static Function ValidaDot( cDot )

    Local cError  := ''
    Local cSemFab := ''
    Local dAnoFab := ''
    Local cSemCor := ''
    Local dAnoCor := ''
    Local cDotM   := ''
    Local lOk     := .T.

    If !Empty( cDot )
        cSemFab := Left(cDot,2) //semana de fabricacao
        dAnoFab := CToD("01/01/"+Right(cDot,2)) //ano de fabricacao
        cSemCor := StrZero(NGSEMANANO(dDataBase),2) //semana corrente
        dAnoCor := CToD("01/01/"+Right(cValToChar(YEAR(dDataBase)),2))  //ano corrente

        cDotM := AllTrim( cDot )
        If Len( cDotM ) < Len( cDot )
            lOk := .F.
            cError := STR0016 + " " // "Não foi preenchito corretamente o campo"
            cError += NGRETTITULO("TQS_DOT")
        EndIf

        If lOk .And. !NGSOCARACTER(cSemFab,"D",.F.)[1]
            lOk := .F.
            cError := STR0017 // "Semana de fabricação é invalida."
        EndIf

        cAnoCor := Right( cDotM , 2 )
        If lOk .And. !NGSOCARACTER(cAnoCor,"D",.F.)[1]
            lOk := .F.
            cError := STR0018 // "Ano de fabricação inválido."
        EndIf

        If lOk .And. Val(cSemFab) > 0 .AnD. Val(cSemFab) <= 53 //total de semanas por ano (365/7)
            If dAnoFab == dAnoCor
                If cSemFab > cSemCor
                    lOk := .F.
                    cError := STR0019 // "A semana de fabricação deve ser igual ou menor à semana corrente"
                    cError += " (" + cSemCor + ")."
                EndIf
            ElseIf dAnoFab > dAnoCor
                lOk := .F.
                cError := STR0020 // "Ano de fabricação deve ser igual ou menor ao ano corrente."
            EndIf
        ElseIf lOk
            lOk := .F.
            If Val( cSemFab ) > 52
                cError := STR0021// "Semana de fabricação ultrapassa o limite de semanas por ano."
            Else
                cError := STR0022 // "Semana de fabricação inválida."
            EndIf
        EndIf
    EndIf

    If !Empty( cError )
        Help( ,, STR0014, , cError  , 1, 0) //"NÃO CONFORMIDADE"
    EndIf

Return Empty( cError )

//---------------------------------------------------------------------
/*/{Protheus.doc} fRetFil
retorna filial da nota fiscal de reforma ou compra

@author Maria Elisandra de Paula
@since 08/09/20

@param cCodBem , string, código do bem
@param cNfGen  , string, numero da nf
@param cSerie  , string, serie da nf
@param cFornece, string, fornecedor da nf
@param cLoja   , string, loja da nf
@param cCodesto, string, código do produto

@return string, retorna filial SD1
/*/
//---------------------------------------------------------------------
Static Function fRetFil( cCodBem, cNfGen, cSerie, cFornece, cLoja, cCodesto )

    Local cCodFil   := cFilAnt
    Local cAliasQry := GetNextAlias()
    Local cServRef  := AllTrim( SuperGetMv( 'MV_NGSEREF', .F., '' ) )
    Local aServRef 	:= StrTokArr( cServRef, ';' )
    Local nX

    //Preenche a variavel cServRef com todos os serviços do parametro MV_NGSEREF
    If !Empty( cServRef )

	    For nX := 1 To Len(aServRef)
	    	If nX == 1
	    		cServRef := "'"+aServRef[nX]+"'"
	    	Else
	    		cServRef += ",'"+aServRef[nX]+"'"
	    	EndIf
	    Next nX

    Else

        cServRef := "' '"

    EndIf

    cServRef := "% AND TR7.TR7_SERVIC IN ("+ cServRef +")%"

    BeginSql Alias cAliasQry
        SELECT TR7.TR7_NFE,
            TR7.TR7_SERIE,
            TR7.TR7_FORNEC,
            TR7.TR7_LOJA
        FROM %table:TR7% TR7
        JOIN %table:TR8% TR8
            ON TR8.TR8_FILIAL = %xFilial:TR8%
            AND TR7.TR7_LOTE = TR8.TR8_LOTE
            AND TR8.TR8_CODBEM = %Exp:cCodBem%
            AND TR8.%notdel%
        WHERE TR7.TR7_FILIAL = %xFilial:TR7%
            AND TR7.%notdel%
            %Exp:cServRef%
        ORDER BY TR7_DTRECI || TR7.TR7_HRRECI DESC
    EndSql

    If (cAliasQry)->( !EoF() )
        cNfGen   := (cAliasQry)->TR7_NFE
        cSerie   := (cAliasQry)->TR7_SERIE
        cFornece := (cAliasQry)->TR7_FORNEC
        cLoja    := (cAliasQry)->TR7_LOJA
    EndIf

    (cAliasQry)->( dbCloseArea() )

    cNfGen   := Padr( cNfGen  , TAMSX3('D1_DOC')[1] )
    cSerie   := Padr( cSerie  , TAMSX3('D1_SERIE')[1] )
    cFornece := Padr( cFornece, TAMSX3('D1_FORNECE')[1] )
    cLoja    := Padr( cLoja   , TAMSX3('D1_LOJA')[1] )
    cCodesto := Padr( cCodesto, TAMSX3('D1_COD')[1] )

    dbSelectArea( 'SD1' )
    dbSetOrder( 1 ) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
    If dbSeek( xFilial('SD1') + cNfGen + cSerie + cFornece + cLoja + cCodesto )

        cCodFil := IIf( !Empty( SD1->D1_FILORI ), SD1->D1_FILORI, SD1->D1_FILIAL )

    EndIf

Return cCodFil

//-------------------------------------------------------------------
/*/{Protheus.doc} fSzField
Calcula a diferença de tamanho do campo para os caracteres utilizados

@type   Function

@author Eduardo Mussi
@since  16/07/2021

@Param  cField, Caracter, Codigo do produto( T9_CODESTO )

@return Numerico, retorna quantidade a ser adicionada na coluna
/*/
//-------------------------------------------------------------------
Static Function fSzField( cField )

    Local nSzField := TamSx3( 'T9_CODESTO' )[ 1 ] - Len( AllTrim( cField ) )

Return nSzField * 10
