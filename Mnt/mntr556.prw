#INCLUDE "MNTR556.ch"
#INCLUDE "PROTHEUS.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR556
Relatório de Pneus não aplicados

@author Maria Elisandra de Paula
@since 27/10/2020
@return nil
/*/
//---------------------------------------------------------------------
Function MNTR556()

    Local cPerg := "MNTR556"
    Local oReport
	Local cAliasQry := ''

	/*---------------------------
	Parâmetros:
	MV_PAR01 -> De Filial O.S
	MV_PAR02 -> Até Filial O.S
	MV_PAR03 -> De Veiculo
	MV_PAR04 -> Até Veículo
	MV_PAR05 -> De O.S
	MV_PAR06 -> Até O.S
	MV_PAR07 -> De Data Movimentação (Baixa do Pneu STL)
	MV_PAR08 -> Até Data Movimentação (Baixa do Pneu STL)
	---------------------------*/

	If Pergunte( cPerg, .T. )
		cAliasQry := GetNextAlias()
		oReport := ReportDef( cAliasQry )
		oReport:SetPortrait() // Retrato
		oReport:PrintDialog()
		(cAliasQry)->( dbCloseArea() )
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Definição das seções do relatório

@param cAliasQry, string, alias da tabela/query
@author Maria Elisandra de Paula
@since 27/10/2020
@return object, objeto da classe Treport
/*/
//---------------------------------------------------------------------
Static Function ReportDef( cAliasQry )
	
    Local oReport   := TReport():New('MNTR556', STR0001,, {|oReport| ReportPrint( oReport, cAliasQry )},'') // 'Relatório de Pneus Aguardando Aplicação'
    Local oSection1 := TRSection():New(oReport, STR0002,{ cAliasQry, 'STJ' })//'Ordem de Serviço'
	Local oSection2 := TRSection():New(oReport, STR0003,{ cAliasQry, 'ST9' },,,,,,,,,,3) //'Pneu'

	//Veículo
    TRCell():New( oSection1 ,'TJ_FILIAL', cAliasQry, NGRETTITULO('TJ_FILIAL'),,FWSIZEFILIAL())
	TRCell():New( oSection1 ,'TJ_ORDEM', cAliasQry, NGRETTITULO('TJ_ORDEM'),,TAMSX3('TJ_ORDEM')[1])
	TRCell():New( oSection1 ,'TJ_CCUSTO', cAliasQry, NGRETTITULO('TJ_CCUSTO'),,TAMSX3('TJ_CCUSTO')[1])
    TRCell():New( oSection1 ,'VEICULO', cAliasQry, NGRETTITULO('T9_CODBEM'),,TAMSX3('T9_CODBEM')[1])
	TRCell():New( oSection1 ,'NOMEVEI', cAliasQry, NGRETTITULO('T9_NOME'),,TAMSX3('T9_NOME')[1])

	// Pneus
    TRCell():New( oSection2 ,'PNEU', cAliasQry, NGRETTITULO('T9_CODBEM'),,TAMSX3('T9_CODBEM')[1])
	TRCell():New( oSection2 ,'NOMEPNEU', cAliasQry, NGRETTITULO('T9_NOME'),,TAMSX3('T9_NOME')[1])
	TRCell():New( oSection2 ,'T9_CODFAMI', cAliasQry, NGRETTITULO('T9_CODFAMI'),,TAMSX3('T9_CODFAMI')[1])
	TRCell():New( oSection2 ,'T9_TIPMOD', cAliasQry, NGRETTITULO('T9_TIPMOD'),,TAMSX3('T9_TIPMOD')[1])
	TRCell():New( oSection2 ,'D3_NUMSEQ', cAliasQry, NGRETTITULO('D3_NUMSEQ'),,TAMSX3('D3_NUMSEQ')[1])
	TRCell():New( oSection2 ,'D3_EMISSAO', cAliasQry, NGRETTITULO('D3_EMISSAO'),,TAMSX3('D3_EMISSAO')[1],,{|| Stod( (cAliasQry)->D3_EMISSAO ) })

Return oReport

//---------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Impressão do relatório

@param cAliasQry, string, alias da tabela/query
@param oReport, object, objeto da classe Treport
@author Maria Elisandra de Paula
@since 27/10/2020
@return boolean
/*/
//---------------------------------------------------------------------
Static Function ReportPrint( oReport, cAliasQry )

	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)
	Local cOrdem    := ''
	Local cFilOrdem := ''
	Local cStJPneu  := '%AND ' + NGMODCOMP('STJ', 'ST9',,,,'STJ.TJ_FILIAL','PNEU.T9_FILIAL') + '%' 
	Local cStJVei   := '%AND ' + NGMODCOMP('STJ', 'ST9',,,,'STJ.TJ_FILIAL','VEI.T9_FILIAL') + '%' 
	Local cStJSd3   := '%AND ' + NGMODCOMP('STJ', 'SD3') + '%' 

	xRobo := NGMODCOMP('STJ', 'ST9',, cFilAnt ,cFilAnt)

	BeginSql Alias cAliasQry

		SELECT STJ.TJ_FILIAL,
			STJ.TJ_ORDEM,
			STJ.TJ_CCUSTO,
			STJ.TJ_CODBEM,
			PNEU.T9_CODBEM PNEU,
			PNEU.T9_NOME NOMEPNEU,
			PNEU.T9_CODFAMI,
			PNEU.T9_TIPMOD,
			VEI.T9_CODBEM VEICULO,
			VEI.T9_NOME NOMEVEI,
			SD3.D3_NUMSEQ,
			SD3.D3_EMISSAO
		FROM %table:STJ% STJ
		INNER JOIN %table:SD3% SD3
			ON STJ.TJ_ORDEM = SD3.D3_ORDEM
			AND SD3.D3_EMISSAO BETWEEN %exp:MV_PAR07% AND %exp:MV_PAR08%
			AND SD3.D3_ORDEM <> ' '
			AND SD3.D3_PNEU <> ' '
			AND SD3.D3_ESTORNO <> 'S'
			AND SD3.%notDel%
			%exp:cStJSd3%
		INNER JOIN %table:ST9% PNEU
			ON PNEU.T9_CODBEM = SD3.D3_PNEU
			AND PNEU.T9_CATBEM = '3'
			AND PNEU.T9_STATUS <> ' '
			AND PNEU.T9_STATUS = %exp:Alltrim( SuperGetMv( 'MV_NGSTAGA', .F., '' ) )% // Aguardando aplicação
			AND PNEU.%notdel%
			%exp:cStJPneu%
		INNER JOIN %table:ST9% VEI
			ON VEI.T9_CODBEM = STJ.TJ_CODBEM
			AND VEI.%notdel%
			%exp:cStJVei%
		WHERE STJ.%notdel%
			AND STJ.TJ_FILIAL BETWEEN %exp:xFilial('STJ', MV_PAR01)% AND %exp:xFilial('STJ', MV_PAR02)%
			AND STJ.TJ_CODBEM BETWEEN %exp:MV_PAR03% AND %exp:MV_PAR04%
			AND STJ.TJ_ORDEM BETWEEN %exp:MV_PAR05% AND %exp:MV_PAR06%
		ORDER BY STJ.TJ_FILIAL, STJ.TJ_ORDEM, PNEU.T9_CODBEM

	EndSql

	dbSelectArea('STJ')
	dbSetOrder(1)

	dbSelectArea('ST9')
	dbSetOrder(1)

	While !(cAliasQry)->( Eof() )

		// Seek na ordem para que seja possível a customização do relatório
		STJ->( dbSeek( TJ_FILIAL + (cAliasQry)->TJ_ORDEM ) )
		

		oSection1:Init()
		oSection1:PrintLine()
		oSection1:Finish()

		cFilOrdem := (cAliasQry)->TJ_FILIAL
		cOrdem    := (cAliasQry)->TJ_ORDEM

		oSection2:Init()

		While !(cAliasQry)->( Eof() ) .And. (cAliasQry)->TJ_FILIAL + (cAliasQry)->TJ_ORDEM == cFilOrdem + cOrdem
			
			// Seek no pneu para que seja possível a customização do relatório
			ST9->( dbSeek( xFilial('ST9', (cAliasQry)->TJ_FILIAL ) + (cAliasQry)->PNEU ) )

			cFilOrdem := (cAliasQry)->TJ_FILIAL
			cOrdem    := (cAliasQry)->TJ_ORDEM

			oSection2:PrintLine()

			(cAliasQry)->( dbSkip() )

		EndDo

		oSection2:Finish()

	EndDo

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR556VLD
Validação de parâmetros

@param nSelect, numérico, parâmetro
@author Maria Elisandra de Paula
@since 27/10/2020
@return boolean
/*/
//---------------------------------------------------------------------
Function MNTR556VLD( nSelect )

	Local lRet := .T.

	DO CASE
		CASE nSelect == 1 // De Filial
			lRet := NgFilial( 1, MV_PAR01 )
		CASE nSelect == 2 // Até Filial
			lRet := NgFilial( 2, MV_PAR01, MV_PAR02 )
		CASE nSelect == 3 // De Veículo
			If !Empty( MV_PAR03 )
				lRet := ExistCpo( 'ST9', MV_PAR03 )
			EndIf
		CASE nSelect == 4 // Até Veículo
			lRet := AteCodigo( 'ST9', MV_PAR03, MV_PAR04 )
		CASE nSelect == 5 // De O.S
			If !Empty( MV_PAR05 )
				lRet := ExistCpo( 'STJ', MV_PAR05 )
			EndIf
		CASE nSelect == 6 // Até O.S
			lRet := AteCodigo( 'STJ', MV_PAR05, MV_PAR06 )
		CASE nSelect == 7 // De Data Mov
			lRet := NaoVazio()
			If lRet .And. !Empty( MV_PAR07 ) .And. !Empty( MV_PAR08 ) 
				lRet := VALDATA( MV_PAR07, MV_PAR08 , "DATAMAIOR" )
			EndIf
		CASE nSelect == 8 // Até Data Mov
			lRet := NaoVazio() 
			If lRet .And. !Empty( MV_PAR08 )
				lRet := VALDATA( MV_PAR07, MV_PAR08 , "DATAMENOR" )
			EndIf
	ENDCASE

Return lRet
