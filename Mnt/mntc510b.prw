#include 'protheus.ch'
#include 'mntc510.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC510B
Apresenta ordens de serviço - busca pela st9

@author Inacio Luiz Kolling
@param cAlias, string, tabela 
@param nReg, numérico, registro
@param nOpcX, numérico, operação
@since 02/07/97
@obs refeito por Maria Elisandra de Paula em 24/03/2021
@return Nil
/*/
//---------------------------------------------------------------------
Function MNTC510B( cAlias, nReg, nOpcX )

	Local cAliasTrb := GetNextAlias()
	Local cFuncBkp  := FunName()
    Local aMenu     := Menudef()
    Local cKey      := 'B' + ST9->T9_CODBEM
    Local bWhile
	Local bWhile2
	Local bFor
	Local bFor2
	Local bDBFFUNC

    SetFunName( 'MNTC510B' )

	Private cCadastro := OemtoAnsi(STR0007) //"Historico de Manutencao"
	Private lCorret   := .F.

	DbSelectArea('STS')
	DbSetOrder(02)

	DbSelectArea('STJ')
	DbSetOrder(02)

    bWhile   := {|| !Eof() .And. STJ->TJ_TIPOOS == 'B' .And. STJ->TJ_CODBEM == ST9->T9_CODBEM }
    bWhile2  := {|| !Eof() .And. STS->TS_TIPOOS == 'B' .And. STS->TS_CODBEM == ST9->T9_CODBEM }
    bFor     := {|| STJ->TJ_FILIAL == xFilial( 'STJ' )}
    bFor2    := {|| STS->TS_FILIAL == xFilial( 'STS' )}
	bDBFFUNC := {|| NG510PROC( 'TJ_', 'TS_' , 'STS', cKey, bWhile2, bFor2 ) }

	NGCONSULTA( cAliasTrb, cKey, bWhile, bFOR, aMenu, {}, bDBFFUNC,,,,,, .F. )

	DbSelectArea( 'STS' )
	DbSetOrder(1)

	DbSelectArea( 'STJ')
	DbSetOrder(1)

    SetFunName( cFuncBkp )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} Menudef
Menu da rotina

@author Inacio Luiz Kolling
@since 02/07/97
@obs refeito por Maria Elisandra de Paula em 24/03/2021
@return array
/*/
//---------------------------------------------------------------------
Static Function Menudef()

    Local aRotina := {{ STR0008, 'MNTC510GE', 0, 2 },; // 'Visualisar'
				    	{ STR0009, 'OSDETALH', 0, 2 },; // 'Detalhes'
				    	{ STR0010, 'OSHISTOCO', 0, 4 },; // 'Ocorrencia'
				    	{ STR0011, 'OshistPro', 0, 4 },; // 'Problema'
				    	{ STR0013, 'MNTC510H', 0, 4, 0 },; // 'Motivo Atraso'
				    	{ STR0012, 'OshistEta', 0, 4 } } // 'Etapas'

	If ExistBlock( 'MNTC510B1' )
		aRotina := ExecBlock( 'MNTC510B1', .F., .F., { aRotina } )
	EndIf

Return aRotina
