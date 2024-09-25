#INCLUDE "TOTVS.CH"
#INCLUDE "mntc550.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC550D
Monta um browse dos Detalhes da ordem de Manutenção
@author Cauê Girardi Petri
@since 17/11/22
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function MNTC550D()

	Local cTrb			:= IIf(Type("_cTrb") <> "U", _cTrb, "")
    Local aOldOutAco    := IIf(Type("aNgButton") == "A",aClone(aNgButton),{})
	Local aRotina    	:= MenuDef()
	Local cFuncBkp 		:= FunName()
	
	Private cCadastro 	:= OemtoAnsi(STR0011) //"Detalhe da Ordem de Manutencao"

	SetFunName( 'MNTC550D' )

	cMESTRE    := "STL"
    aNgButton  := {}

	If ExistBlock("MNTC550B")
		ExecBlock("MNTC550B",.F.,.F.)
	EndIf

	If Empty(cTrb) .And. !Empty( STJ->TJ_ORDEM )
		M->TJ_ORDEM := STJ->TJ_ORDEM
		M->TJ_PLANO := STJ->TJ_PLANO
	ElseIf !Empty((_cTrb)->TJ_ORDEM)
		M->TJ_ORDEM := (_cTrb)->TJ_ORDEM
		M->TJ_PLANO := (_cTrb)->TJ_PLANO
	EndIf

	dbSelectArea("STL")
	bWHILE := {|| !EoF() .And. STL->TL_ORDEM == M->TJ_ORDEM .And. STL->TL_PLANO == M->TJ_PLANO}
	bFOR   := {|| TL_FILIAL == xFilial("STL") .And. TL_ORDEM == M->TJ_ORDEM .And.;
	TL_PLANO  == M->TJ_PLANO }

	If !Empty(M->TJ_ORDEM) .And. !Empty(M->TJ_PLANO) //Verifica se encontrou algum registro.
		NGCONSULTA("TRBL", M->TJ_ORDEM + M->TJ_PLANO, bWHILE, bFOR, aRotina,{})
	Else
		HELP("",1,"ARQVAZIO") //Chame help de arquivo vazio.
	EndIf
	dbSelectArea("STL")
	dbSetOrder(01)

	dbSelectArea("STJ")
	cMESTRE   := "STJ"
    aNgButton := aClone(aOldOutAco)

	SetFunName( cFuncBkp )

Return .T.

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
