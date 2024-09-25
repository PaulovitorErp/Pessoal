#Include "mdta110.ch"
#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA110D
Consultas do Funcionario Selecionado

@author  Rafael Diogo Richter
@since   25/08/2003

@return  Lógico, Verdadeiro quando a fonção for executada normalmente
/*/
//-------------------------------------------------------------------
Function MDTA110D()

	Local nPos
	Local aBkpMenu    := {}
	Local aAreaTM0    := TM0->(GetArea())
	Local aNGBEGINPRM := NGBEGINPRM(,"MDTA075")

	If !IsInCallStack( "MDTA110" ) .And. !IsBlind()
		ShowHelpDlg( STR0035, ;          //"ATENÇÃO"
					{ STR0046 }, 1,;     //"Execução não permitida."
					{ STR0047, "" }, 1 ) //"Rotina somente pode ser executada pelo menu de Ocorrências Ficha (MDTA110)."
		Return .F.
	EndIf

	//Verifica se o funcionario esta demitido
	If !SitFunFicha(TM0->TM0_NUMFIC,.F.,.T.,.T.)
		NGRETURNPRM(aNGBEGINPRM)
		Return
	EndIf

	If (nPos := aScan(aSMenu,{|x| "MDTRELHIS" $ x[2]})) > 0
		aBkpMenu := aSMenu
		aSMenu[nPos,2] := MDT075TRO(@aSMenu,nPos,"TMJ")
	EndIf

	oldROTINA := aCLONE(aROTINA)
	look := .F.

	Private cCadant := cCadastro
	Private cCodusu := TML->TML_CODUSU
	Private aRotina := MenuDef()

	If FindFunction("MDTRESTRI") .And. !MDTRESTRI("MDTA160")
		NGRETURNPRM(aNGBEGINPRM)
		Return .F.
	EndIf

	SetFunName("MDTA110D")

	cCadastro := STR0019 //"Consultas Funcionario"

	cCadastro := OemtoAnsi(cCadastro)

	aCHOICE := { "TMJ_CODUSU"   ,;
				"TMJ_NOMUSU"   ,;
				"TMJ_DTCONS"   ,;
				"TMJ_HRCONS"   ,;
				"TMJ_NUMFIC"   ,;
				"TMJ_NOMFIC"   ,;
				"TMJ_MOTIVO"   ,;
				"TMJ_NOMOTI"   ,;
				"TMJ_EXAME"    ,;
				"TMJ_NOMEXA"   ,;
				"TMJ_DTATEN"   ,;
				"TMJ_OBSCON"    }

	aCHKDEL := { }
	DbSelectArea("TM0")
	DbSetOrder(1)
	DbSelectArea("TMJ")
	DbSetOrder(1)
	//Condição deverá ser em SQL
	//Realiza o filtro no Funcionário selecionado para trazer somente as consultas dele.
	cFilBrw := "TMJ_FILIAL = " + ValToSQL( xFilial( 'TMJ' ) ) + " AND TMJ_NUMFIC = " + ValToSQL( TM0->TM0_NUMFIC ) + ;
				" AND TMJ_DTATEN <> " + ValToSQL( SToD( Space(8) ) )

	mBrowse( 6 , 1 , 22 , 75 , "TMJ", NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , cFilBrw )

	aROTINA   := aCLONE(oldROTINA)
	cCadastro := cCadant

	DbSelectArea("TMJ")
	DbSetOrder(1)
	dBSEEK(XFILIAL("TMJ"))
	If Len(aBkpMenu) > 0
		aSMenu := aBkpMenu
	EndIf
	NGRETURNPRM(aNGBEGINPRM)
	RestArea(aAreaTM0)
	SetFunName("MDTA110")

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de Menu Funcional
@type static function
@author Rafael Diogo Richter
@since 11/01/2007
@return array, opções do menu com o seguinte layout:
				Parametros do array a Rotina:
				1. Nome a aparecer no cabecalho
				2. Nome da Rotina associada
				3. Reservado
				4. Tipo de Transação a ser efetuada:
					1 - Pesquisa e Posiciona em um Banco de Dados
					2 - Simplesmente Mostra os Campos
					3 - Inclui registros no Bancos de Dados
					4 - Altera o registro corrente
					5 - Remove o registro corrente do Banco de Dados
				5. Nivel de acesso
				6. Habilita Menu Funcional

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local lSigaMdtPS	:=	SuperGetMv("MV_MDTPS",.F.,"N") == "S"
	Local aRotina := { { STR0018, "AxPesqui"  , 0 , 1 }, ; //"Pesquisar "
					   { STR0005, "NGCAD01"   , 0 , 2 }  } //"Visualizar"

	If !lSigaMdtPS .And. SuperGetMv("MV_NG2AUDI",.F.,"2") == "1"
		aAdd( aRotina , { STR0031,"MDTA991('TMJ',{'TMJ_FILIAL','TMJ_NUMFIC','TMJ_USERGI'},{'"+xFilial('TMJ')+"','"+TM0->TM0_NUMFIC+"',STOD('"+DTOS(TM0->TM0_DTIMPL)+"')})" , 0 , 3 } )//"Hist. Exc."
	EndIf
Return aRotina