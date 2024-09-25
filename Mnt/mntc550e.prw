#INCLUDE "TOTVS.CH"
#INCLUDE "mntc550.ch"


//--------------------------------------------------
/*/{Protheus.doc} MNTC550E
Monta um browse com os problemas da ordem

@author Cauê Girardi Petri
@since 22/11/22
@return Nil
/*/
//--------------------------------------------------
Function MNTC550E()
	
    Local cFuncBkp := FunName()
    Local cTrb			:= IIf(Type("_cTrb") <> "U", _cTrb, "")
	Private cCadastro   := OemtoAnsi(STR0013) //"Ocorrencias da Ordem Servico Manutencao"

    SetFunName( 'MNTC550E' )

	aRotina   := MenuDef()

	If Empty(cTrb) .And. !Empty( STJ->TJ_ORDEM )
		M->TJ_ORDEM := STJ->TJ_ORDEM
		M->TJ_PLANO := STJ->TJ_PLANO
	ElseIf !Empty((_cTrb)->TJ_ORDEM)
		M->TJ_ORDEM := (_cTrb)->TJ_ORDEM
		M->TJ_PLANO := (_cTrb)->TJ_PLANO
	EndIf

	dbSelectArea("STN")
	dbSetOrder(01)
	bWHILE := {|| !EoF() .And. STN->TN_ORDEM == M->TJ_ORDEM .And. STN->TN_PLANO == M->TJ_PLANO}
	bFOR   := {|| TN_FILIAL == xFilial("STN") .And. TN_ORDEM == M->TJ_ORDEM .And. ;
	TN_PLANO  == M->TJ_PLANO}

	NGCONSULTA("TRBN", M->TJ_ORDEM+M->TJ_PLANO, bWHILE, bFOR, aRotina,{})
	dbSelectArea("STN")
	dbSetOrder(01)

    SetFunName( cFuncBkp )

Return 

//---------------------------------------------------------------------
/*/{Protheus.doc} Menudef
Menu da rotina

@author Cauê Girardi Petri
@since 17/11/22
@return array
/*/
//---------------------------------------------------------------------
Static Function Menudef()

    Local aReturn  := {{STR0012,'NGVISUAL(,,, "NGCAD01" )' , 0, 2}}  //"Visualizar"

Return aReturn
