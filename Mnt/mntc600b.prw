#INCLUDE 'MNTC600.CH'
#INCLUDE 'PROTHEUS.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTC600B
Monta um browse com as ordens de Manutencao do Bem

@author  Inacio Luiz Kolling
@since 02/08/97
@param cCODBEMC600, string, codigo do bem
@param cFILTER, string, filtro do browser
@return nil
/*/
//-------------------------------------------------------------------
Function MNTC600B( cCODBEMC600, cFILTER )

    Local cBkpFun := FunName()
    Local aMenu   := MenuDef()

    SetFunName( 'MNTC600B' ) // Seta rotina para identificar as restrições de acesso

    MNC600ORD2( cCODBEMC600, cFILTER, aMenu ) // Aciona rotina principal com menu padrão do fonte

    SetFunName( cBkpFun ) // Retorna backup de nome da rotina

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Retorna menu da rotina

@author Inacio Luiz Kolling
@since 02/08/97
@return array
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

    Local aReturn := { {STR0002,'MNT600VIS' , 0, 2},; // 'Visual.'
                    {STR0021,'MNTCOSDE'  , 0, 3, 0},; // 'Detalhes'
    				{STR0022,'MNTCOCOR'  , 0, 4, 0},; // 'Ocorren.'
					{STR0023,'MNTC550A', 0, 4, 0},; // 'proBlemas'
					{STR0026,'NGATRASOS' , 0, 4, 0},; // 'Motivo Atraso'
					{STR0016,'MNTC550B'  , 0, 4}}     // 'Etapas'

    If ExistBlock( 'MNTC600B1' )
		aReturn := ExecBlock( 'MNTC600B1', .F., .F., { aReturn } )
	EndIf


Return aReturn

