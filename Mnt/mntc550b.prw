#INCLUDE 'MNTC550.CH'
#INCLUDE 'PROTHEUS.CH'

//--------------------------------------------------
/*/{Protheus.doc} MNTC550B
Monta um browse com as etapas da ordem

@author Cauê Girardi Petri
@since 22/11/22
@return Nil
/*/
//--------------------------------------------------
Function MNTC550B()
	
    Local cFuncBkp := FunName()
	Local aRotina  := MenuDef()
    Local cTrb     := IIf( Type( '_cTrb' ) <> 'U', _cTrb, '' )
	Local cKey     := ''
	Local cTable   := ''
	Local lNgCad01 := .F.

	Private cCadastro 	:= OemtoAnsi(STR0015) //"Etapas O. S. Manutencao"
	Private cAliasOS	:= GetNextAlias() //Alias para tabela temporária.
    
    SetFunName( 'MNTC550B' )


	If Alias() $ "STS" .And. !Empty( STS->TS_ORDEM )

		M->TS_ORDEM := STS->TS_ORDEM
		M->TS_PLANO := STS->TS_PLANO

		cKey   := M->TS_ORDEM+M->TS_PLANO
		cTable := 'STX'

		dbSelectArea( "STX" )
		dbSetOrder( 01 )
		bWHILE := {|| !EoF() .And. STX->TX_ORDEM == M->TS_ORDEM .And. STX->TX_PLANO == M->TS_PLANO}
		bFOR   := {|| TX_FILIAL == xFilial( "STX" ) .And. TX_ORDEM == M->TS_ORDEM .And. TX_PLANO  == M->TS_PLANO}

	ElseIf !Empty( STJ->TJ_ORDEM ) .And. Empty(cTrb)

		M->TJ_ORDEM := STJ->TJ_ORDEM
		M->TJ_PLANO := STJ->TJ_PLANO

		cKey   := M->TJ_ORDEM+M->TJ_PLANO
		cTable := 'STQ'

		dbSelectArea("STQ")
		dbSetOrder(01)
		bWHILE := {|| !EoF() .And. STQ->TQ_ORDEM == M->TJ_ORDEM .And. STQ->TQ_PLANO == M->TJ_PLANO}
		bFOR   := {|| TQ_FILIAL == xFilial("STQ") .And. TQ_ORDEM == M->TJ_ORDEM .And. TQ_PLANO  == M->TJ_PLANO}

	ElseIf !Empty((_cTrb)->TJ_ORDEM)

		M->TJ_ORDEM := (_cTrb)->TJ_ORDEM
		M->TJ_PLANO := (_cTrb)->TJ_PLANO

		cKey   := M->TJ_ORDEM+M->TJ_PLANO
		cTable := 'STQ'

		dbSelectArea("STQ")
		dbSetOrder(01)
		bWHILE := {|| !EoF() .And. STQ->TQ_ORDEM == M->TJ_ORDEM .And. STQ->TQ_PLANO == M->TJ_PLANO}
		bFOR   := {|| TQ_FILIAL == xFilial("STQ") .And. TQ_ORDEM == M->TJ_ORDEM .And. TQ_PLANO  == M->TJ_PLANO}

	EndIf

	If !Empty( cKey )

		NGCONSULTA( cAliasOS, cKey, bWHILE, bFOR, aRotina, {} , , , , , , , lNgCad01 )
		dbSelectArea( cTable )
		dbSetOrder( 01 )

	EndIf

    SetFunName( cFuncBkp )

Return 

//--------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu da rotina

@author Caue Girardi Petri
@since 22/11/22
@return array
/*/
//--------------------------------------------------
Static Function MenuDef()

    Local aReturn := { { STR0012 , 'NGVISUAL(,,, "NGCAD01" )', 0, 2 },; //"Visualizar"
				        { STR0025 , 'TPQRESPOS', 0, 4 } }  // 'Opcoes'

Return aReturn
