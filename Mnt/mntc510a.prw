#include 'protheus.ch'
#include 'mntc510.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC510A
Apresenta o histórico da Manutenção

@author Inacio Luiz Kolling
@param cCodBem, string, código do bem
@param cServico, string, código do serviço
@param cSeqrela, string, sequencia
@since 02/07/97
@obs refeito por Maria Elisandra de Paula em 04/02/2021
@return Nil
/*/
//---------------------------------------------------------------------
Function MNTC510A( cCodBem, cServico, cSeqrela )

	Local cAliasTRB := GetNextAlias()
	Local aMenu     := Menudef()
	Local aColors	:= {}
	Local cFilter   := ''
    Local cKey      := ''
    Local cFuncBkp  := FunName()
    Local bWhile
    Local bFor
    Local bWhile2
    Local bFor2
    Local bFunction

    SetFunName( 'MNTC510A' )

    Private cCadastro := OemtoAnsi( STR0007 ) //'Histórico de Manutenção'
    Private lCorret   := .F.

    M->TF_CODBEM  := IIf( ValType( cCodBem ) == 'C', cCodBem , (_cTRB)->TF_CODBEM )
    M->TF_SERVICO := IIf( ValType( cServico ) == 'C', cServico, (_cTRB)->TF_SERVICO )
    M->TF_SEQRELA := IIf( ValType( cSeqrela ) == 'C', cSeqrela, (_cTRB)->TF_SEQRELA )

    cKey      := 'B'+ M->TF_CODBEM + M->TF_SERVICO + M->TF_SEQRELA
    bWhile    := {|| !Eof() .And. STJ->TJ_TIPOOS == 'B' .And. STJ->TJ_CODBEM  == M->TF_CODBEM .And. STJ->TJ_SERVICO == M->TF_SERVICO .And. STJ->TJ_SEQRELA == M->TF_SEQRELA }
    bFor      := {|| STJ->TJ_FILIAL == xFilial( 'STJ' )}
    bWhile2   := {|| !Eof() .And. STS->TS_TIPOOS == 'B' .And. STS->TS_CODBEM  == M->TF_CODBEM .And. STS->TS_SERVICO == M->TF_SERVICO .And. STS->TS_SEQRELA == M->TF_SEQRELA }
    bFor2     := {|| STS->TS_FILIAL  == xFilial( 'STS' )}
    bFunction := {|| NG510PROC( 'TJ_', 'TS_', 'STS', cKey, bWhile2, bFor2 )}

    //---------------------------------------------
    // Ponto de entrada para cores do browse
    //---------------------------------------------
    
    If ExistBlock( 'MNTC5101' )
        aColors := aClone( ExecBlock("MNTC5101",.F.,.F.) )
    EndIf

    //---------------------------------------------------
    // Ponto de entrada para filtro do browse
    //---------------------------------------------------
    If ExistBlock( 'MNTC5103' )
        cFilter := ExecBlock( 'MNTC5103', .F., .F. )
    EndIf

	If !Empty( cFilter )
        cFilter += ' .And. '
    EndIf

    cFilter += "TJ_SITUACA != 'C' "

    DbSelectArea('STS')
    DbSetOrder(02)

    DbSelectArea('STJ')
    DbSetOrder(02)

    NGCONSULTA( cAliasTRB, cKey, bWhile, bFor, aMenu, {}, bFunction, , , , aColors, cFilter,.F. )

    DbSelectArea( 'STS')
    DbSetOrder(01)

    DbSelectArea( 'STJ' )
    DbSetOrder(01)

    SetFunName( cFuncBkp )

Return 

//---------------------------------------------------------------------
/*/{Protheus.doc} Menudef
Menu da rotina

@author Inacio Luiz Kolling
@since 02/07/97
@obs refeito por Maria Elisandra de Paula em 04/02/2021
@return array
/*/
//---------------------------------------------------------------------
Static Function Menudef()

    Local nIndex   := 0
    Local aButtons := {}
    Local aReturn  := {{ STR0008, 'MNTC510GE', 0, 2 },;    //"Visualisar"
				        { STR0009, 'OSDETALH',   0, 2 },;   //"Detalhes"
				        { STR0010, 'OSHISTOCO',  0, 4 },;    //"Ocorrencia"
				        { STR0011, 'OshistPro',  0, 4 },;    //"Problema"
				        { STR0013, 'MNTC510H',  0, 4, 0},;  //"Motivo Atraso"
				        { STR0012, 'OshistEta',  0, 4 } }     //"Etapas"


    //-----------------------------------------
    // Botões adicionais
    //-----------------------------------------
    If ExistBlock( 'MNTC5102' )
        aButtons := aClone( ExecBlock( 'MNTC5102', .F., .F. ) )
        For nIndex := 1 To Len( aButtons )
            aAdd( aReturn, aButtons[nIndex])
        Next nX
    EndIf

Return aReturn
