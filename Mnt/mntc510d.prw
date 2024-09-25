#include 'protheus.ch'
#include 'mntc510.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC510D
Insumos da ordem de serviço

@author Maria Elisandra de Paula
@since 26/03/21
@return Nil
/*/
//---------------------------------------------------------------------
Function MNTC510D()

	Local cAliasTrb := GetNextAlias()
	Local cFuncBkp  := FunName()
    Local aMenu     := Menudef()
	Local cKeyTT    := ''
	Local cKey      := ''
	Local bWhile
	Local bWhile2
	Local bFor
	Local bFor2

    SetFunName( 'MNTC510D' )

	Private cCadastro := STR0016 // 'Historico dos Detalhes'

	DbSelectArea('STJ')
	DbSetOrder(4)
	DbSeek( xFilial('STJ')+(_cTRB)->TJ_SERVICO+(_cTRB)->TJ_TIPOOS+(_cTRB)->TJ_CODBEM+(_cTRB)->TJ_SEQRELA+(_cTRB)->TJ_ORDEM )

	M->TJ_ORDEM := STJ->TJ_ORDEM
	M->TJ_PLANO := STJ->TJ_PLANO

	cKeyTT := M->TJ_ORDEM + M->TJ_PLANO
	cKey := M->TJ_ORDEM + M->TJ_PLANO

	DbSelectArea('STT')
	DbSetOrder(01)

	bWhile2  := {|| !Eof() .And. STT->TT_ORDEM == M->TJ_ORDEM .And. STT->TT_PLANO == M->TJ_PLANO }
	bFOR2    := {|| TT_FILIAL == xFilial('STT') .And. TT_ORDEM  == M->TJ_ORDEM .And. TT_PLANO  == M->TJ_PLANO }
	bDBFFUNC := {|| NG510PROC('TL_','TT_','STT', cKeyTT, bWhile2, bFOR2 ) }

	DbSelectArea('STL')
	DbSetOrder(01)
	bWhile := {|| !Eof() .And. STL->TL_ORDEM == M->TJ_ORDEM .And. STL->TL_PLANO == M->TJ_PLANO }
	bFOR   := {|| TL_FILIAL == xFilial('STL') .And. TL_ORDEM  == M->TJ_ORDEM .And. TL_PLANO  == M->TJ_PLANO }

	NGCONSULTA( cAliasTrb, cKey, bWhile, bFOR, aMenu, {}, bDBFFUNC,,,,,, .F. )
	DbSelectArea('STL')
	DbSetOrder(01)

	aTrocaF3 := {}

    SetFunName( cFuncBkp )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} Menudef
Menu da rotina

@author Maria Elisandra de Paula
@since 26/03/21
@return array
/*/
//---------------------------------------------------------------------
Static Function Menudef()

Return { { STR0002, 'MNTC510GE', 0, 2 } } // 'Visualizar'
