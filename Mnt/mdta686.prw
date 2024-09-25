#Include 'Mdta686.ch'
#include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} mdta686
Monta o Browse da rotina.

@author	Gabriel Sokacheski
@since 01/09/2021

/*/
//-------------------------------------------------------------------
Function mdta686()

    Local aCampos := {;
        'TNY_NUMFIC',;
        'TNY_NOMFIC',;
        'TNY_DTINIC',;
        'TNY_HRINIC',;
        'TNY_DTFIM',;
        'TNY_HRFIM',;
        'TNY_CID',;
        'TNY_EMITEN',;
        'TNY_NOMUSU',;
        'TNY_NATEST',;
        'TNY_DTCONS',;
        'TNY_HRCONS',;
        'TNY_INDMED',;
        'TNY_OCORRE',;
        'TNY_ACIDEN',;
        'TNY_ATEANT';
    }

    Private oMark := FWMarkBrowse():New()

    Private cMarca := GetMark() // Marcação do browse
    Private cProcesso := '' // Variável necessária no fonte gpea240
    Private cPrograma := 'MDTA685' // Variável necessária no fonte mdta685

    oMark:SetAlias( 'TNY' ) // Define da tabela a ser utilizada
    oMark:SetOnlyFields( aCampos ) // Define os campos apresentados em tela
    oMark:SetFieldMark( 'TNY_COMUOK' ) // Define o campo que sera utilizado para a marcação
    oMark:SetFilterDefault( 'TNY_COMUOK != "OK"' )
    oMark:SetDescription( STR0001 ) // "Atestados não comunicados"
    oMark:SetAllMark( { || FWMsgRun( , { || fAllMark( oMark ) }, "Marcando todos os registros" , "Aguarde..." ) } )

    oMark:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Define as opções da rotina.

@author	Gabriel Sokacheski
@since 01/09/2021

@return	aRotina, array, Contendo as opções da rotina..
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

    Local aRotina := {}

    aAdd( aRotina, { STR0003, 'VIEWDEF.mdta686', 0, 1, 0, Nil } ) // "Visualizar"
    aAdd( aRotina, { STR0002, 'Processa( { || Mdt686Comu() } )', 0, 2, 0, Nil } ) // "Comunicar"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface da rotina.

@author	Gabriel Sokacheski
@since 01/09/2021

@return	oView, Objeto, Contendo a interface.
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

    Local oView := FWLoadView( 'mdta685' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} fTabela
Filtra somente os registros marcados para comunicar por uma query.
Sem isso, seria percorrido todos os registros da tabela TNY,
o que prejudicaria muito a performance.

@author	Gabriel Sokacheski
@since 01/03/2022

@param, cMarca, marcação do markbrowse

@return, cQuery, query com os registros a serem comunicados
/*/
//-------------------------------------------------------------------
Static Function fTabela( cMarca )

    Local aCampos := {}
    Local aLoadSM0 := FwLoadSM0()

    Local cQuery := GetNextAlias()
    Local cTabFil := GetNextAlias()
    Local cNomTabFil := ''

    Local nI := 0

    Local oTabFil := FwTemporaryTable():New( cTabFil ) // Tabela das filiais que o usuário possui acesso

    aAdd( aCampos, { 'GRUPO', 'C', Len( cEmpAnt ), 0 } )
    aAdd( aCampos, { 'FILIAL', 'C', TamSx3( 'TNY_FILIAL' )[1], 0 } )
    aAdd( aCampos, { 'TNY_FILIAL', 'C', TamSx3( 'TNY_FILIAL' )[1], 0 } )
    aAdd( aCampos, { 'TM0_FILIAL', 'C', TamSx3( 'TM0_FILIAL' )[1], 0 } )
    aAdd( aCampos, { 'TNP_FILIAL', 'C', TamSx3( 'TNP_FILIAL' )[1], 0 } )

    oTabFil:SetFields( aCampos )
    oTabFil:AddIndex( '01', { 'FILIAL' } )
    oTabFil:Create()

    dbSelectArea( cTabFil )

    For nI := 1 To Len( aLoadSM0 )

        If aLoadSM0[ nI, 11 ] // Verifica se o usuário tem acesso a filial

            RecLock( cTabFil, .T. )

                ( cTabFil )->GRUPO := aLoadSM0[ nI, 1 ] // Código do grupo da qual a filial pertence
                ( cTabFil )->FILIAL := aLoadSM0[ nI, 2 ] // Código da filial com todos os níveis
                ( cTabFil )->TNY_FILIAL := xFilial( 'TNY', aLoadSM0[ nI, 2 ] ) // Código da filial com compartilhamento da TNY
                ( cTabFil )->TM0_FILIAL := xFilial( 'TM0', aLoadSM0[ nI, 2 ] ) // Código da filial com compartilhamento da TM0
                ( cTabFil )->TNP_FILIAL := xFilial( 'TNP', aLoadSM0[ nI, 2 ] ) // Código da filial com compartilhamento da TNP

            ( cTabFil )->( MsUnlock() )

        EndIf

    Next nI

    cNomTabFil := oTabFil:GetRealName()

    BeginSQL Alias cQuery
		SELECT
            TNY.TNY_FILIAL, TNY.TNY_NUMFIC, TM0.TM0_NOMFIC, TNY.TNY_DTINIC, TNY.TNY_HRINIC, TNY.TNY_DTFIM, TNY.TNY_HRFIM, TNY.TNY_CID,
            TNY.TNY_EMITEN, TNP.TNP_NOME, TNY.TNY_NATEST, TNY.TNY_DTCONS, TNY.TNY_HRCONS, TNY.TNY_INDMED, TNY.TNY_OCORRE, TNY.TNY_ACIDEN,
            TNY.TNY_ATEANT, FIL.GRUPO, FIL.FILIAL
		FROM
            %table:TNY% TNY
                INNER JOIN %temp-table:cNomTabFil% FIL ON
                    FIL.TNY_FILIAL = TNY.TNY_FILIAL
                INNER JOIN %table:TM0% TM0 ON 
                    TM0.TM0_FILIAL = FIL.TM0_FILIAL
                    AND TM0.TM0_NUMFIC = TNY.TNY_NUMFIC 
                    AND TM0.%notDel% 
                INNER JOIN %table:TNP% TNP ON 
                    TNP.TNP_FILIAL = FIL.TNP_FILIAL
                    AND TNP.TNP_EMITEN = TNY.TNY_EMITEN
                    AND TNP.%notDel%
		WHERE
			TNY.TNY_COMUOK != 'OK'
            AND TNY_COMUOK = %exp:cMarca%
			AND TNY.%notDel%
        GROUP BY TNY.TNY_FILIAL, TNY.TNY_NUMFIC, TM0.TM0_NOMFIC, TNY.TNY_DTINIC, TNY.TNY_HRINIC, TNY.TNY_DTFIM,
            TNY.TNY_HRFIM, TNY.TNY_CID, TNY.TNY_EMITEN, TNP.TNP_NOME, TNY.TNY_NATEST, TNY.TNY_DTCONS, TNY.TNY_HRCONS,
            TNY.TNY_INDMED, TNY.TNY_OCORRE, TNY.TNY_ACIDEN, TNY.TNY_ATEANT, FIL.GRUPO, FIL.FILIAL
	EndSQL

    ( cTabFil )->( DbCloseArea() )

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} fAllMark
Marca ou desmarca todos os registros do browse.

@author	Gabriel Sokacheski
@since 02/03/2022

/*/
//-------------------------------------------------------------------
Static Function fAllMark( oMark )

    Local cAlias := oMark:Alias()
    
    dbSelectArea( cAlias )
    dbGoTop()

    While (cAlias)->( !EoF() )

        oMark:MarkRec()

        (cAlias)->( dbSkip() )

    End

    (cAlias)->( dbGoTop() )
    
    oMark:oBrowse:Refresh( .T., Nil, .F., .F. )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Mdt686Comu
Comunica os afastamentos dos atestados selecionados.

@author	Gabriel Sokacheski
@since 01/09/2021

/*/
//-------------------------------------------------------------------
Function Mdt686Comu()

    Local cMarca := oMark:Mark() // Retorna identificador do markBrowse
    Local cQuery := fTabela( cMarca )
    Local cEmpBkp := cEmpAnt
    Local cFilBkp := cFilAnt

    Local nInc := 0
    Local nPor := 100 / fQtdReg( cMarca ) // Porcentagem de conclusão por registro
    Local nDecimal := 0

    Local oModel

    Default lBloqFol := .T.
    Default lMdtBloq := .T.

    ProcRegua( 100 )

    ( cQuery )->( dbGoTop() )

    DbSelectArea( 'TNY' )
    DbSetOrder( 2 )

    While ( cQuery )->( !EoF() )

        If ( cQuery )->TNY_NATEST == ( 'TNY' )->TNY_NATEST .Or. DbSeek( ( cQuery )->TNY_FILIAL + ( cQuery )->TNY_NATEST )

            If ( cQuery )->FILIAL != cFilAnt

                cEmpAnt := ( cQuery )->GRUPO
                cFilAnt := ( cQuery )->FILIAL

            EndIf

            FreeObj( oModel )
            oModel := FWLoadModel( 'mdta685' )
            oModel:SetOperation( 4 )
            oModel:Activate()

            a685Update( Nil, oModel, Nil, .T., lMdtBloq )

            If !lBloqFol .And. lMdtBloq // Quando o afastamento não foi bloqueado pela folha

                RecLock( 'TNY', .F. )
                    ( 'TNY' )->TNY_COMUOK := 'OK' // Marca atestado como comunicado na TNY
                ( 'TNY' )->( MsUnLock() )

                If nPor >= 1

                    For nInc := 1 To nPor
                        IncProc()
                    Next nInc

                ElseIf nDecimal >= 1

                    nDecimal -= 1
                    IncProc()

                Else

                    nDecimal += nPor

                EndIf

            Else // Caso bloquado, interrompe o processo

                Exit

            EndIf

        EndIf

        ( 'TNY' )->( DbSkip() )
        ( cQuery )->( DbSkip() )

    End

    ( cQuery )->( DbCloseArea() )

    cEmpAnt := cEmpBkp
    cFilAnt := cFilBkp

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fQtdReg
Contabiliza a quantidade de registros a serem comunicados.

@author	Gabriel Sokacheski
@since 04/11/2022

@param, cMarca, marcação do markbrowse

@return, nQtdReg, quantidade de registros marcados para comunicar
/*/
//-------------------------------------------------------------------
Static Function fQtdReg( cMarca )

    Local cQuery := GetNextAlias()

    Local nQtdReg := 0

    BeginSQL Alias cQuery
		SELECT
            COUNT( TNY_COMUOK ) AS QTDREG
		FROM
            %table:TNY%
		WHERE
			TNY_COMUOK != 'OK'
            AND TNY_COMUOK = %exp:cMarca%
			AND %notDel%
	EndSQL

    ( cQuery )->( dbGoTop() )
    nQtdReg := ( cQuery )->QTDREG
    ( cQuery )->( DbCloseArea() )

Return nQtdReg
