#include 'protheus.ch'
#include 'mntc510.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC510E
Ocorrências da ordem

@author Inacio Luiz Kolling
@since 02/07/97
@obs refeito por Maria Elisandra de Paula em 24/03/2021
@return Nil
/*/
//---------------------------------------------------------------------
Function MNTC510E()

	Local cAliasTrb := GetNextAlias()
	Local cFuncBkp  := FunName()
    Local aMenu     := Menudef()
	Local cKey      :=''
	Local bWhile
	Local bFor
	Local bWhile2
	Local bFor2
	Local bDBFFUNC

	SetFunName( 'MNTC510E' )

	Private cCadastro := STR0014 // 'Historico das Ocorrencias'

	dbSelectArea('STN')
	dbSetOrder(01)
	bWhile := {|| !Eof() .And. STN->TN_ORDEM == M->TJ_ORDEM .And. STN->TN_PLANO == M->TJ_PLANO }
	bFor   := {|| TN_FILIAL  == xFilial('STN')}

	If Type( '_cTrb' ) <> 'U'
		If Select( _cTrb ) > 0
			dbSelectArea('STJ')
			dbSetOrder(4)
			dbSeek( xFilial('STJ') + (_cTRB)->TJ_SERVICO + (_cTRB)->TJ_TIPOOS + (_cTRB)->TJ_CODBEM + (_cTRB)->TJ_SEQRELA + (_cTRB)->TJ_ORDEM )
		EndIf
	EndIf

	M->TJ_ORDEM := STJ->TJ_ORDEM
	M->TJ_PLANO := STJ->TJ_PLANO
	cKey        := M->TJ_ORDEM+M->TJ_PLANO
	aTrocaF3    := {}

	dbSelectArea('STF')
	dbSetOrder(1)
	dbSeek( xFilial('STF') + STJ->TJ_CODBEM + STJ->TJ_SERVICO + STJ->TJ_SEQRELA )
	If Val( STJ->TJ_PLANO ) == 0 .And. NGUSATARPAD()
		aAdd( aTrocaF3, { 'TN_TAREFA', 'TT9' } )
	EndIf

	dbSelectArea('STU')
	dbSetOrder(01)
	bWhile2  := {|| !Eof() .And. STU->TU_ORDEM == M->TJ_ORDEM .And. STU->TU_PLANO == M->TJ_PLANO }
	bFor2    := {|| TU_FILIAL == xFilial('STU')}
	bDBFFUNC := {|| NG510PROC( 'TN_', 'TU_', 'STU', cKey, bWhile2, bFor2 ) }

	dbSelectArea('STN')
	dbSetOrder(01)
	bWhile := {|| !Eof() .And. STN->TN_ORDEM == M->TJ_ORDEM .And. STN->TN_PLANO == M->TJ_PLANO }
	bFor   := {|| TN_FILIAL  == xFilial('STN')}

	NGCONSULTA( cAliasTrb, cKey, bWhile, bFor, aMenu, {}, bDBFFUNC,,,,,, .F. )
	dbSelectArea('STN')
	dbSetOrder(01)
	aTrocaF3:= {}

    SetFunName( cFuncBkp )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} Menudef
Menu da rotina

@author Inacio Luiz Kolling
@since 02/07/97
@obs refeito por Maria Elisandra de Paula em 26/03/2021
@return array
/*/
//---------------------------------------------------------------------
Static Function Menudef()

Return { { STR0002, 'MNTC510GE', 0, 2 } }  // 'Visualizar'
