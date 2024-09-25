#Include "mdta200.ch"
#Include "Protheus.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA200B
Monta markbrowse dos exames

@author Inacio Luiz Kolling
@since 28/03/2000

/*/
//---------------------------------------------------------------------
Function MDTA200B()

	Local oModel		:= Nil

	Local nOpcX 		:= 4
	Local aExamesIni	:= {}
	Local aExamesFim	:= {}

	If !FwIsInCallStack( 'mdta410' )
		oModel	:= FWModelActive()
		nOpcX 	:= oModel:GetOperation()
	EndIf

	Private aRotina	:= MenuDef( nOPCX )

	SetFunName( "MDTA200B" )

	Private lInclui := ( nOpcx == 3 ) //Usada na rotina que monta markbrowse de vinculação de exames a um ASO

	//Ao entrar pelo MDTA410 não deverá perguntar se deseja imprimir ASO, pois já possui um
	//botão para realizar a impressão.
	If IsInCallStack( "MDTA410" )
		Private lImpAso := .f.
	EndIf

	If cNatExam != M->TMY_NATEXA .Or. nOpcx == 5 .Or. nOpcx == 3
		//Ao relacionar o exame pelo MDTA410 deverá ser considerado como alteração para
		//realizar as validações corretas.
		EXAMESTRB( nOPCX, If ( IsInCallStack( "MDTA410" ), 1, 0 ) )
		cNatExam := M->TMY_NATEXA
	Endif

	dbSelectArea( cTRB2200 )
	dbGoTop()
	While ( cTRB2200 ) -> ( !Eof() )

		If ( cTRB2200 )->TM5_NUMFIC = M->TMY_NUMFIC .And. !Empty( ( cTRB2200 )->TM5_OK )
			aAdd( aExamesIni, ( cTRB2200 )->TM5_EXAME + ( cTRB2200 )->TM5_NOMEXA + DTOS( ( cTRB2200 )->TM5_DTPROG ) )
		EndIf

		DbSkip()

	End

	MARKBROW( cTRB2200,"TM5_OK",,aEstExa,lInverte, cMarca, "A200Inexam(cMarca)" )

	dbSelectArea( cTRB2200 )
	dbGoTop()
	While ( cTRB2200 ) -> ( !Eof() )

		If ( cTRB2200 )->TM5_NUMFIC = M->TMY_NUMFIC .And. !Empty( ( cTRB2200 )->TM5_OK )
			aAdd( aExamesFim, ( cTRB2200 )->TM5_EXAME + ( cTRB2200 )->TM5_NOMEXA + DTOS( ( cTRB2200 )->TM5_DTPROG ) )
		EndIf

		DbSkip()

	End

	If !ArrayCompare( aExamesIni, aExamesFim ) .And. !FwIsInCallStack( "MDTA410" )

		oModel:lModify:= .T.
		oModel:lValid := .F.
		oView 		  := FWViewActive()
		oView:ApplyModifyToViewByModel( oModel )

	EndIf

	// Realiza gravação do exame ao ASO
	If IsInCallStack( "MDTA410" )
		MDT200VAR( nOPCX, ,.T. )
	Endif

	SetFunName( "MDTA200B" )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de Menu Funcional

@type function

@source mdta200b.prw

@author Inacio Luiz Kolling
@since 28/03/2000

@param nOpcx, Numérico, Valor da operação a ser relizada

@Obs Tipo de transações a serem efetuadas
@Obs     2 - Simplesmente Mostra os Campos
@Obs     3 - Mostra a relação de exames

@sample MenuDef( .F. )

@return Array, Retorna as opções do menu
/*/
//---------------------------------------------------------------------
Static Function MenuDef( nOPCX )

	Local aRotina
	Private cRelExam   := SuperGetMv( "MV_NGEXREL",.F.,"1" ) // Indica o padrao para o filtro de exames relacionados.

	If nOPCX != 5

		If cRelExam == "1"
			aRotina := { { STR0033 , "EXA200VIS" , 0 , 2 },;//"Visualizar"
						 { STR0142 , "EXA200INC" , 0 , 3 },;//"Relac. Exames"
						 { STR0035 , "EXA200RES" , 0 , 2 } }//"Resultado"

		ElseIf cRelExam == "2"

			aRotina := { { STR0142 , "EXA200INC" , 0 , 3 } } //"Relac. Exames"

		Endif

	Else

		aRotina := { { STR0033 , "EXA200VIS" , 0 , 2 },;//"Visualizar"
					 { STR0035 , "EXA200RES" , 0 , 2 } }//"Resultado"

	Endif

Return aRotina
