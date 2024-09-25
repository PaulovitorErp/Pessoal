#INCLUDE 'MNTC550.CH'
#INCLUDE 'PROTHEUS.CH'

//--------------------------------------------------
/*/{Protheus.doc} MNTC550A
Monta um browse com os problemas da ordem

@author Maria Elisandra de paula
@since 18/05/21
@return Nil
/*/
//--------------------------------------------------
Function MNTC550A()
	
    Local cFuncBkp := FunName()
    Local cTrb     := IIf(Type("_cTrb") <> "U", _cTrb, "")
	Local cKey     := ''
	Local cTable   := ''
	Local aRotina  := MenuDef()
	Local lNgCad01 := .F.

	Private cCadastro := OemtoAnsi(STR0014) //"Problemas da Ordem Servico Manutencao"

    SetFunName( 'MNTC550A' )

	If Alias() $ "STS" .And. !Empty( STS->TS_ORDEM )
		M->TS_ORDEM := STS->TS_ORDEM
		M->TS_PLANO := STS->TS_PLANO

		cKey   := M->TS_ORDEM+M->TS_PLANO
		cTable := 'STV'

		dbSelectArea( "STV" )
		dbSetOrder( 01 )

		bWHILE := {|| !EoF() .And. STV->TV_ORDEM == M->TS_ORDEM .And. STV->TV_PLANO == M->TS_PLANO}
		bFOR   := {|| TV_FILIAL == xFilial( "STV" ) .And. TV_ORDEM == M->TS_ORDEM .And. TV_PLANO  == M->TS_PLANO }

	ElseIf !Empty( STJ->TJ_ORDEM ) .And. Empty(cTrb)

		M->TJ_ORDEM := STJ->TJ_ORDEM
		M->TJ_PLANO := STJ->TJ_PLANO

		cKey   := M->TJ_ORDEM+M->TJ_PLANO
		cTable := 'STA'

		dbSelectArea("STA")
		dbSetOrder(01)

		bWHILE := {|| !EoF() .And. STA->TA_ORDEM == M->TJ_ORDEM .And. STA->TA_PLANO == M->TJ_PLANO}
		bFOR   := {|| TA_FILIAL == xFilial("STA") .And. TA_ORDEM == M->TJ_ORDEM .And. TA_PLANO  == M->TJ_PLANO }

	ElseIf !Empty((_cTrb)->TJ_ORDEM)

		M->TJ_ORDEM := (_cTrb)->TJ_ORDEM
		M->TJ_PLANO := (_cTrb)->TJ_PLANO

		cKey   := M->TJ_ORDEM+M->TJ_PLANO
		cTable := 'STA'

		dbSelectArea("STA")
		dbSetOrder(01)
		bWHILE := {|| !EoF() .And. STA->TA_ORDEM == M->TJ_ORDEM .And. STA->TA_PLANO == M->TJ_PLANO}
		bFOR   := {|| TA_FILIAL == xFilial("STA") .And. TA_ORDEM == M->TJ_ORDEM .And. TA_PLANO  == M->TJ_PLANO }

	EndIf

	If !Empty( cKey )

		NGCONSULTA( 'TRBA', cKey, bWHILE, bFOR, aRotina , {} , , , , , , , lNgCad01 )
		dbSelectArea( cTable )
		dbSetOrder( 01 )

	EndIf

    SetFunName( cFuncBkp )

Return 

//--------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu da rotina

@author Maria Elisandra de paula
@since 18/05/21
@return array
/*/
//--------------------------------------------------
Static Function MenuDef()

    Local aReturn := {{ STR0012, 'NGVISUAL(,,, "NGCAD01" )', 0, 2 }} // Visualizar

Return aReturn
