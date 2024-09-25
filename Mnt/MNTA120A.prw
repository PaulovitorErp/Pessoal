#Include 'Totvs.ch'
#Include "MNTA120.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA120A
Função criada para validar permissões de acesso pelo Menudef

@type   Function

@author Eduardo Mussi
@since  01/12/2023

/*/
//-------------------------------------------------------------------
Function MNTA120A()

    Local cBkpFun := FunName()
    Local aMenu   := MenuDef()

    SetFunName( 'MNTA120A' )

    MNTA120OP2( aMenu )

    SetFunName( cBkpFun )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu de opções

@type   Function

@author Eduardo Mussi
@since  01/12/2023

@return Array, opções disponiveis na rotina
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aReturn := {  { STR0004, 'AxPesqui' , 0, 1 },;    //"Pesquisar"
						{ STR0005, 'NGCAD01'  , 0, 2 },;    //"Visual."
						{ STR0059, 'MNTC550D' , 0, 4 },;    //"Detalhes"
						{ STR0060, 'MNTC550E' , 0, 4 },;    //"Ocorren."
						{ STR0061, 'MNTC550A' , 0, 4 },;    //"proBlemas"
						{ STR0062, 'NGATRASOS', 0, 4, 0},;  //"Motivo Atraso"
						{ STR0028, 'MNTC550B' , 0, 4 },;    //"Etapas   "
						{ STR0088, 'MNT120IMP', 0, 4 }}     //"Imprimir"

Return aReturn
