#INCLUDE 'Totvs.ch'
#INCLUDE 'MNTA400A.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA400A
Programa para inclusão de insumos realizados.
@type function

@author	Alexandre Santos
@since	13/06/2019

@param cAlias, Caracter, Tabela corrente.
@param nRecNo, Númerico, Número do registro.
@param nOpcX , Númerico, Operação selecionada.
@return
/*/
//---------------------------------------------------------------------
Function MNTA400A( cAlias, nRecNo, nOpcX )

	Local nIndex     := 0
	Local cOldProg   := FunName()
	Local acbrowold  := acbrowse
	Local lRet       := .F.
	Local oTmpTbl2               // Obj. Tabela Temporária 2

	Private cTRBR400 := GetNextAlias()
	Private cLocaliz := Space( Len( TPS->TPS_CODLOC ) )  // Código de Localização
	Private aRotina  := MenuDef()

	// Valida se a O.S. não foi cancelada paralelamente em outra rotina.
	If !FindFunction( 'MNTA400Can' ) .Or. MNTA400Can()

		SetFunName( 'MNTA400A' ) // Assume a função posicionada como Pai.

		/* Ponto de entrada para retornar um valor logico de maneira que permita validar se e possivel agregar ou modificar
		insumos para OS selecionada pelo usuario. */
		If ExistBlock( 'MNTA400L' )
			lRet := ExecBlock( 'MNTA400L', .F., .F. )

			If !lRet
				Return .F.
			EndIf

		EndIf

		acbrowse := 'xxxxxxxxxx'
		dbSelectArea( 'STJ' )
		nINDSTJ := IndexOrd()

		aIndSTL    := {}
		bFiltraBrw := { || Nil }
		condSTL    := 'STL->TL_FILIAL = ' + ValToSQL( xFilial( 'STL' ) ) + ' .And. STL->TL_ORDEM = STJ->TJ_ORDEM .And.'
		condSTL    += '  ( AllTrim( STL->TL_SEQRELA ) <> "0" .Or. Val( STL->TL_SEQRELA ) != 0 )'

		If STJ->TJ_TIPOOS == 'B'

			If !NGBEMATIV( STJ->TJ_CODBEM )
				Return .F.
			EndIf

			If !NGMANATIV( STJ->TJ_CODBEM, STJ->TJ_SERVICO, STJ->TJ_SEQRELA )
				Return .F.
			EndIf

		EndIf

		cUSAINT1 := AllTrim( GetMv( 'MV_NGMNTPC' ) )
		cUsaInt2 := AllTrim( GetMv( 'MV_NGMNTCM' ) )
		cUsaInt3 := AllTrim( GetMv( 'MV_NGMNTES' ) )
		lESTNEGA := AllTrim( GetMv( 'MV_ESTNEG' ) ) == 'S'

		dbSelectArea( 'STJ' )
		If Empty( STJ->TJ_ORDEM )
			Return Nil
		EndIf

		lCORRET := Val( STJ->TJ_PLANO ) == 0
		cMestre := 'STJ'

		Private cCodBem := STJ->TJ_CODBEM
		Private cOrdem  := STJ->TJ_ORDEM
		Private cPlano  := STJ->TJ_PLANO

		aPOS1     := { 15, 1, 95, 315 }
		lRETORNO  := .T.
		cCADASTRO := Oemtoansi( STR0008 ) // Retorno Tarefas

		dbSelectArea( 'STF' )
		dbSetOrder( 1 )
		dbSeek( xFilial( 'STF' ) + STJ->TJ_CODBEM + STJ->TJ_SERVICO + STJ->TJ_SEQRELA )
		M->TF_CODBEM  := STJ->TJ_CODBEM
		M->TF_SERVICO := STJ->TJ_SERVICO
		M->TF_SEQRELA := STJ->TJ_SEQRELA
		M->TJ_ORDEM   := STJ->TJ_ORDEM
		M->TJ_PLANO   := STJ->TJ_PLANO
		MV_PAR01      := STJ->TJ_CODBEM
		MV_PAR02      := STJ->TJ_SERVICO
		MV_PAR05      := STJ->TJ_SEQRELA
		cPar01        := MV_PAR01
		cPar02        := MV_PAR02
		cPar05        := MV_PAR05

		dbSelectArea( 'STL' )
		nINDSTL := IndexOrd()

		dbSetOrder( 1 )
		dbSeek( xFilial( 'STL' ) + STJ->TJ_ORDEM )

		If ExistBlock( 'NGTERMOR' )

			aDBFR := STL->( dbStruct() )

			oTmpTbl2:= FWTemporaryTable():New( cTRBR400, aDBFR )
			oTmpTbl2:AddIndex( 'Ind01', { 'TL_ORDEM', 'TL_PLANO', 'TL_TAREFA', 'TL_TIPOREG', 'TL_CODIGO', 'TL_SEQRELA' } )
			oTmpTbl2:Create()

			dbSelectArea( 'STL' )
			dbSetOrder( 1 )
			dbSeek( xFilial( 'STL' ) + STJ->TJ_ORDEM )
			Do While STL->( !EoF() ) .And. STL->TL_FILIAL == xFilial( 'STL' ) .And. STL->TL_ORDEM == STJ->TJ_ORDEM

				If STL->TL_TIPOREG == 'P' .And. Trim( STL->TL_SEQRELA ) == '0'

					RecLock( cTRBR400, .T. )
					dbSelectArea( 'STL' )

					For nIndex := 1 To fCount()

						ny   := (cTRBR400)+"->" + Fieldname( nIndex )
						nx   := "STL->" + Fieldname( nIndex )
						&ny. := &nx.

					Next nIndex

				EndIf

				STL->( dbSkip() )

			EndDo

		EndIf

		dbSelectArea( 'STL' )
		dbSetOrder( 1 )
		dbSeek( xFilial( 'STL' ) + STJ->TJ_ORDEM )

		NG400FILSTL()

		dbSelectArea( 'STL' )
		SetBrwCHGAll( .F. ) // Não apresentar a tela para informar a filial
		mBrowse( 6, 1, 22, 75, 'STL' )
		aEval( aIndSTL, { |x| FErase( x[1] + OrdBagExt() ) } )
		ENDFILBRW( 'STL', aIndSTL )

		dbSelectArea( 'STL' )
		Set Filter To
		dbSetOrder( 1 )
		dbSeek( xFilial( 'STL' ) )

		NG400PROC( STJ->TJ_ORDEM + STJ->TJ_PLANO )

		If ExistBlock( 'NGTERMOR' )
			oTmpTbl2:Delete() // Deleta Tabela Temporária 2
		EndIf

		dbSelectArea( 'STJ' )
		nREGTAR := Recno()

		If Type( 'aIndSTJ' ) == 'A' .And. Type( 'cCondicao' ) == 'C'

			bFiltraBrw := { || FilBrowse( 'STJ', @aIndSTJ, @cCondicao ) }
			Eval( bFiltraBrw )
			dbGoto( nREGTAR )

		Else

			bFiltraBrw := { || Nil }
			dbSetOrder( nINDSTJ )
			lREFRESH := .T.

		EndIf

		acbrowse := acbrowold
		SetFunName( cOldProg ) // Retoma a função de origem como Pai.

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de Menu Funcional.
@type static

@author	Alexandre Santos
@since	13/06/2019

@return Array,  [1] - Nome que é apresentado no cabeçalho.
				[2] - Nome da rotina associada.
				[3] - Reservado.
				[4] - Tipo de transação a ser efetuada.
				[5] - Nível de acesso.
				[6] - Habilita menu funcional.
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local lPyme   := IIf( Type( '__lPyme' ) != 'U', __lPyme, .F. )
	Local lIntEst := AllTrim( SuperGetMv( 'MV_NGMNTES' ) ) == 'S'
	Local aRotina := { { STR0001, 'PesqBrw'  , 0, 1, , .F. },;      // Pesquisar
					   { STR0002, 'MNT400VIS', 0, 2, , .F. },;      // Visualizar
					   { STR0003, 'NG401INC' , 0, 3, , .F. },;      // Incluir
					   { STR0004, 'NG401INC' , 0, 4, , .F. },;      // Alterar
					   { STR0005, 'NG401INC' , 0, 5, 3, .F.};       // Excluir
					 }

	If !lPyme
		aAdd( aRotina, { STR0006, 'MsDocument', 0, 4, , .F. } )   // Conhecimento
	EndIf

	If lIntEst
		aAdd( aRotina, { STR0007, 'MNTA400COM()', 0, 4, , .F. } ) // C&omplemento
	EndIf

Return aRotina
