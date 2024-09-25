#include "Totvs.ch"
#INCLUDE "MDTA621.ch"
//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA621
Avaliação de Equipamentos
Rotina que permite avaliar os Equipamentos fornecidos

@return Nil

@sample MDTA621()

@author Jackson Machado
@since 02/02/2016
@version 1.0
/*/
//---------------------------------------------------------------------
Function MDTA621()

	//-----------------------------------------------
	// Guarda conteudo e declara variaveis padroes
	//-----------------------------------------------
	Local aNGBEGINPRM := NGBEGINPRM()
	Local cPerg :=  PADR( "MDT621" , 10 ) //Grupo de perguntas

	//Declara variáveis de utilização comum
	Private cPrograma 	:= "MDTA621"
	Private cCadastro 	:= STR0001 //"Avaliação dos EPIs"
	Private lSigaMDTPs	:= SuperGetMv( "MV_MDTPS" , .F. , "N" ) == "S"
	Private aRotina		:= MenuDef()

	//Efetua as perguntas.
	Pergunte( cPerg , .F. )

	//---------------------------------------
	// Adiciona funcionalidade ao F12
	//---------------------------------------
	SetKey( VK_F12 , { | | MDT621OBD(cPerg)} )

	If lSigaMDTPs
		ShowHelpDlg( STR0002 , ; //"Atenção"
					{ STR0003 } , 2 , ; //"Rotina não autorizada para Prestador de Serviço."
					{ STR0004 } , 2 ) //"Contate administrador de sistema."
	Else
		dbSelectArea( "SA2" )
		dbSetOrder( 1 )
		SetBrwCHGAll( .F. ) // nao apresentar a tela para informar a filial
		mBrowse( 6 , 1 , 22 , 75 , "SA2" )
	EndIf
	//-----------------------------------------------
	// Retorna conteudo de variaveis padroes
	//-----------------------------------------------
	NGRETURNPRM( aNGBEGINPRM )
Return
//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de Menu Funcional.

@return aRotina  - 	Array com as opções de menu.
					Parametros do array a Rotina:
					1. Nome a aparecer no cabecalho
					2. Nome da Rotina associada
					3. Reservado
					4. Tipo de Transa‡„o a ser efetuada:
						1 - Pesquisa e Posiciona em um Banco de Dados
						2 - Simplesmente Mostra os Campos
						3 - Inclui registros no Bancos de Dados
						4 - Altera o registro corrente
						5 - Remove o registro corrente do Banco de Dados
					5. Nivel de acesso
					6. Habilita Menu Funcional

@param nMenu

@sample MenuDef()

@author Jackson Machado
@since 02/02/2016
/*/
//---------------------------------------------------------------------
Static Function MenuDef( nMenu )

	Local aRotina

	Default nMenu := 1

	If nMenu == 1
		aRotina := { { STR0005,   "AxPesqui"  , 0 , 1},; //"Pesquisar"
		             { STR0006,   "NGCAD01"   , 0 , 2},; //"Visualizar"
		             { STR0007,   "MDT621EPI" , 0 , 4} } //"EPIs"
	ElseIf nMenu == 2
		aRotina :=	{ { STR0005, "AxPesqui"	 , 0 , 1},; //"Pesquisar"
			  		  { STR0006, "NGCAD01"	 , 0 , 2},; //"Visualizar"
					  { STR0008, "MDT621AVA" , 0 , 4} } //"Avaliações"
	ElseIf nMenu == 3
		aRotina :=	{ { STR0006, "MDT621CAD" , 0 , 2},; //"Visualizar"
			  		  { STR0009, "MDT621CAD"	 , 0 , 3},; //"Incluir"
			  		  { STR0010, "MDT621CAD"	 , 0 , 4},; //"Alterar"
					  { STR0011, "MDT621CAD"	,  0 , 5 , 3 }} //"Excluir"
	Endif

Return aRotina
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT621EPI
Monta o Browse com os EPI's a serem avaliados

@return Nil

@sample MDT621EPI()

@author Jackson Machado
@since 02/02/2016
/*/
//---------------------------------------------------------------------
Function MDT621EPI()

	Local aOldRot := aClone( aRotina )

	aRotina := MenuDef( 2 )

	dbSelectArea( "TN3" )
	dbSetOrder( 1 )
	Set Filter To TN3_FORNEC+TN3_LOJA == SA2->A2_COD+SA2->A2_LOJA
	SetBrwCHGAll( .F. ) // nao apresentar a tela para informar a filial
	mBrowse( 6 , 1 , 22 , 75 , "TN3" )

	dbSelectArea( "TN3" )
	dbSetOrder( 1 )
	Set Filter To

	aRotina := aClone( aOldRot )
Return
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT621AVA
Monta um Browse com as avaliações

@return Nil

@sample MDT621AVA()

@author Jackson Machado
@since 05/02/2016
/*/
//---------------------------------------------------------------------
Function MDT621AVA()

	Local aOldRot := aClone( aRotina )
	Local cExprFilTop := " TY8_FORNEC = "+ ValToSQL( SA2->A2_COD ) + " AND " + ;
						" TY8_LOJA = "+ ValToSQL( SA2->A2_LOJA ) + " AND " + ;
						" TY8_CODEPI = "+ ValToSQL( TN3->TN3_CODEPI ) + " AND " + ;
						" TY8_FILIAL = " + ValToSQL( xFilial( "TY8" ) ) + " AND " + ;
						" TY8_QUESTA = " + ValToSQL( "001" )

	aRotina := MenuDef( 3 )

	mBrowse( 6 , 1 , 22 , 75 , "TY8" , , , , , , , , , , , , , , cExprFilTop )

	aRotina := aClone( aOldRot )
Return
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT621CAD
Monta tela de manutenção da TY8

@return Nil

@sample MDT621CAD( "TY8" , 0 , 3 )

@author Jackson Machado
@since 05/02/2016
/*/
//---------------------------------------------------------------------
Function MDT621CAD( cAlsBro , nRecno , nOpcx )
	Local i
	Local oMainWnd
	Local lVisual := .f.
	Local nYY,nXX
	Local aBtn_Topo := {}

	//Variaveis que definem o questionário
	Local cQuest	:= Space( 6 )
	Local dDtReal	:= StoD( Space( 8 ) )
	Local cMat		:= Space( 6 )

	Local aOldRot   := aClone(aRotina)
	Local oDlgInd
	Local oPaiFic
	Local cTitulo := ""
	Local nLimPnl  := 0
	Local nPosHRod := 0

	Private oFont    := TFont():New( "Arial" , , -10 , .F. , .F. )
	Private oFont12  := TFont():New( "Arial" , , -12 , .T. , .T. )
	Private oFont16  := TFont():New( "Arial" , , -16 , .T. , .T. )
	Private aSize := MsAdvSize(,.f.,430), aObjects := {}
	Private nPosPnl  := 0
	Private oPnlPrin
	Private oPnlPai
	Private aIndNG
	Private oBtnFirst
	Private oBtnNext
	Private oBtnPrevi
	Private oBtnLast
	Private nLastPanel := 1 //Indica última página de perguntas apresentada
	Private nLinObj := 0
    Private lAprovacao := .F.
    Private aCadTipo := {}

	nOpcx := nOpcx + 1
	If nOpcx == 2 .or. nOpcx == 5
		lVisual := .t.
	Endif

	aRotina := { { STR0005	, "AxPesqui"  , 0 , 1 } , ; //"Pesquisar"
					{ STR0006	, "NGCAD01"  , 0 , 2 } , ; //"Visualizar"
					{ STR0009	, "NGCAD01"  , 0 , 3 } , ; //"Incluir"
					{ STR0010	, "NGCAD01"  , 0 , 4 } , ; //"Alterar"
					{ STR0011	, "NGCAD01"  , 0 , 5, 3 } } //"Excluir"


	aAdd( aBtn_Topo , { "HISTORIC"  , { | | fImpRel( cQuest , dDtReal , cMat ) } , STR0018 , STR0019 } ) //"Imprimir Questionário"###"Imprimir"

	Aadd(aObjects,{200,200,.t.,.f.})
	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObjects,.t.)
	If aSize[6] > 900
		aPosObj[1,3] := aPosObj[1,3] * ( aSize[6] / 560 )
	ElseIf aSize[6] > 650
		aPosObj[1,3] := aPosObj[1,3] * ( aSize[6] / 590 )
	Else
		aPosObj[1,3] := aPosObj[1,3] * ( aSize[6] / 610 )
	Endif

	aCadTipo := {} //Limpa array de perguntas

	dbSelectArea( "TY8" )
	RegToMemory( "TY8" , nOpcx == 3 )

	lConfirm := .F.
	If nOpcx == 3
		lConfirm := fTelaInicial( @cQuest , @dDtReal , @cMat )
	Else
		cQuest := ( cAlsBro )->TY8_QUESTI
		dDtReal := ( cAlsBro )->TY8_DTREAL
		cMat	:= ( cAlsBro )->TY8_MAT
		lConfirm := .T.
	Endif

	lOk := .F.

	If lConfirm
		dbSelectArea( "TMH" )
		dbSetOrder( 1 )
		dbSeek( xFilial("TMH") + cQuest )
		While TMH->( !Eof() ) .And. xFilial( "TMH" ) == TMH->TMH_FILIAL .And. cQuest == TMH->TMH_QUESTI
			//Verifica se usuario precisa responder a pergunta
			If TMH->TMH_INDSEX <> "3"
				If ( TMH->TMH_INDSEX == "1" .And. SRA->RA_SEXO == "F" ) .Or.;
					( TMH->TMH_INDSEX == "2" .and. SRA->RA_SEXO == "M" )
					TMH->( dbSkip() )
					Loop
				Endif
			Endif
			aTipoTMH := {}
			If !Empty( TMH->TMH_RESPOS )
				aTipoTMH := fRetCombo( Alltrim( TMH->TMH_RESPOS ) )
			Endif
			aTemp := Array( Len( aTipoTMH ) , 3 )
			For nXX := 1 To Len( aTemp )
				If ( TMH->TMH_TPLIST == "1" )
					aTemp[ nXX , 1 ] := 0
				Else
					aTemp[ nXX , 1 ] := .F.
				Endif
				If nOpcx != 3
					dbSelectArea( "TY8" )
					dbSetOrder( 1 )
					If dbSeek( xFilial( "TY8" ) + SA2->A2_COD + SA2->A2_LOJA + TN3->TN3_CODEPI + cMat + DToS( dDtReal ) + cQuest + TMH->TMH_QUESTA + SubStr( aTipoTMH[ nXX ] , 1 , 1 ) )
						If ( TMH->TMH_TPLIST == "1" )
							aTemp[ nXX , 1 ] := 1
						Else
							aTemp[ nXX , 1 ] := .T.
						Endif
					Endif
				Else
					If SubStr( aTipoTMH[ nXX ] , 1 , 1 ) == TMH->TMH_DEFAUL
						If ( TMH->TMH_TPLIST == "1" )
							aTemp[ nXX , 1 ] := 1
						Else
							aTemp[ nXX , 1 ] := .T.
						Endif
					Endif
				Endif
			Next nXX

			//Se não for inclusão
			cMemoM6 := ""
			If nOpcx != 3
				dbSelectArea( "TY8" )
				dbSetOrder( 1 )
				If dbSeek( xFilial( "TY8" ) + SA2->A2_COD + SA2->A2_LOJA + TN3->TN3_CODEPI + cMat + DToS( dDtReal ) + cQuest + TMH->TMH_QUESTA + "#" )
					cMemoM6 := Alltrim( TY8->TY8_DESCRI )
				Endif
			Endif

			//1 - Codigo Questão
			//2 - Descrição Questão
			//3 - Grupo
			//4 - Array de Opções
			//5 - Cbox
			//6 - Indica se é RADIO (.T.) ou CHECK (.F.)
			//7 - Indica se tem campo Memo
			//8 - Array (respostas,objeto)
			//9 - Ordem
			//10- Campo Memo
			//11- Questionario
			//12- Qtd. Objetos x Pergunta
			//13- Página onde ficará a pergunta
			aAdd( aCadTipo , { TMH->TMH_QUESTA , Capital( TMH->TMH_PERGUN ) , TMH->TMH_CODGRU , aTipoTMH ,;
								TMH->TMH_RESPOS , ( TMH->TMH_TPLIST == "1" ) , ;
								( TMH->TMH_ONMEMO == "1" ) , aTemp , TMH->TMH_ORDEM , cMemoM6 ," " , 0 , 0 } )
			dbSelectArea( "TMH" )
			dbSkip()
		End

		aSort( aCadTipo , , , { | x , y | x[ 9 ] < y[ 9 ] } )

		If Len( aCadTipo ) > 0
			aIndNG := Array( Len( aCadTipo ) , 3 )
		Endif

		aAreaTY8 := {}
		cChvTmp  := xFilial("TY8") + ( cAlsBro )->TY8_MAT
		dbSelectArea( "TY8" )
		dbSetOrder( 1 )
		dbSeek( cChvTmp )
		While TY8->( !EoF() ) .and. cChvTmp == TY8->TY8_FILIAL + TY8->TY8_MAT
			If Replicate( "#" , Len( TY8->TY8_QUESTA ) ) == TY8->TY8_QUESTA
				If aScan( aAreaTY8 , { | x | x == TY8->TY8_DTREAL }) == 0
					aAdd( aAreaTY8 , TY8->TY8_DTREAL )
				Endif
			Endif
			dbSelectArea( "TY8" )
			dbSkip()
		End
		aSort( aAreaTY8 , , , { | x , y | x > y } )
		For nXX := 1 To Len( aAreaTY8 )
			If nXX == 1
				cObsAnt := ""
			Endif
			cObsAnt += DToC( aAreaTY8[ nXX ] ) + "  "
		Next nXX

		nFatMlt := 1.95
		If aPosObj[ 1 , 4 ] <= 410
			nFatMlt := 1.9
		ElseIf aPosObj[ 1 , 4 ] <= 550
			nFatMlt := 1.93
		Endif

		Define MsDialog oDlgInd Title OemToAnsi( cCadastro ) From aSize[ 7 ] , 0 To aSize[ 6 ] , aSize[ 5 ] Of oMainWnd Pixel
			oDlgInd:lEscClose := .F.
			oDlgInd:lMaximized := .T.
			nLinObj := 2

			dbSelectArea( "SB1" )
			dbSetOrder( 1 )
			dbSeek( xFilial( "SB1" ) + TN3->TN3_CODEPI )
			cTitulo :=	AllTrim( SB1->B1_DESC ) + " - C.A. " + TN3->TN3_NUMCAP

			//---------------------------------------------------
			// Cria Panel pai que engloba a tela p/ alinhamento
			//---------------------------------------------------
			oPnlPai := TPanel():New( 000 , 000 , , oDlgInd , , , , , CLR_WHITE , 000 , 000 , .F. , .F. )
				oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT
				oPaiFic := TPanel():New( 000 , 000 , , oPnlPai , , , , , CLR_WHITE , 000 , 028 , .F. , .F. )
					oPaiFic:Align := CONTROL_ALIGN_TOP
					//---------------------------
					// Título do Ficha Médica
					//---------------------------
					oPanelTmp := TPaintPanel():New( nLinObj - 1 , -4 , aPosObj[ 1 , 4 ] + 5 , 14 , oPaiFic )
						oPanelTmp:addShape( "id=2;type=1;left=0;top=0;width=" + Alltrim( Str( aPosObj[ 1 , 4 ] * 2.2 , 5 ) ) + ";height=28;" + ;
											"gradient=1,0,-15,0,40,0.4,#C3DBF9,0.9,#83AAE2,0.0,#FFF6FF;pen-width=0;" + ;
											"pen-color=#B0C4DE;can-move=0;can-mark=0;is-blinker=1;" )

						@ 2, 11 SAY oSayDesc Prompt cTitulo PIXEL OF oPanelTmp Font oFont16 COLOR CLR_WHITE
						@ 2, 10 SAY oSayDesc Prompt cTitulo PIXEL OF oPanelTmp Font oFont16 COLOR RGB(67,70,87)

						@ 2, ( aPosObj[ 1 , 4 ] /2 ) SAY oGrpDtEx Prompt SubStr( DtoC( dDtReal ) , 1 , 6 ) + StrZero( Year( dDtReal ) , 4 ) Of oPanelTmp Font oFont16 COLOR CLR_WHITE Pixel
						@ 2, ( aPosObj[ 1 , 4 ] /2 ) - 1 SAY oGrpDtEx Prompt SubStr( DtoC( dDtReal ) , 1 , 6 ) + StrZero( Year( dDtReal ) , 4 ) Of oPanelTmp Font oFont16 COLOR RGB( 67 , 70 , 87 ) Pixel
						@ 2, aPosObj[ 1 , 4 ] - 120 SAY oGrpQues Prompt Space( 20 ) Of oPanelTmp Font oFont16 COLOR CLR_WHITE Pixel

				nLinObj += 15

				cOldGrupo := "#"
				nLimPnl	  := 620 //Limite de objetos por tela
				nTotAlt   := 0   //Totalizador de objetos por página
				nContPg   := 1   //Contador de páginas
				For nYY := 1 To Len( aCadTipo )
					aCadTipo[ nYY , 12 ] := fQtdObject( aCadTipo[nYY] , cOldGrupo )
					nTotAlt += aCadTipo[ nYY , 12 ]
					If nTotAlt > nLimPnl
						nContPg += 1
						aCadTipo[ nYY , 13 ] := nContPg
						nTotAlt := 0
					Else
						aCadTipo[ nYY , 13 ] := nContPg
					EndIf
					cOldGrupo := aCadTipo[ nYY , 3 ]
				Next nYY
				cOldGrupo := "#"
				nPosPnl := 0
				@ 000,000 SCROLLBOX oPnlPrinc VERTICAL OF oPnlPai
				oPnlPrinc:Align := CONTROL_ALIGN_ALLCLIENT
				For nYY := 1 to Len( aCadTipo )
					If aCadTipo[ nYY , 13 ] == 1 //Monta perguntas da primeira página
						fMontaPag( cOldGrupo , nYY , lVisual , oPnlPrinc )
						cOldGrupo := aCadTipo[ nYY , 3 ]
					EndIf
				Next nYY
				//nLinObj += 13

				oPanelRod := TPanel():New( 000 , 000 , , oPnlPai , , , , , CLR_WHITE , 000 , 020 , .F. , .F. )
					oPanelRod:Align := CONTROL_ALIGN_BOTTOM

					nPosHRod := ( aPosObj[ 1 , 4 ] / 2 ) - 155

					oBtnFirst := TButton():New( 010 , 010 + nPosHRod , STR0020 , oPanelRod , ; //"Primeira"
												{ | | MsgRun( STR0021 , , { | | fMovPnl( .T. , 0 , , lVisual ) } ) } , ; //"Montando Tela..."
												50 , 10 , , , .F. , .T. , .F. , , .F. , , , .F. )
						oBtnFirst:Disable()
					oBtnPrevi := TButton():New( 010 , 070 + nPosHRod , STR0022 , oPanelRod , ; //"Anterior"
												{ | | MsgRun( STR0021 , , { | | fMovPnl( .F. , 0 , .F., lVisual ) } ) } , ; //"Montando Tela..."
												50 , 10 , , , .F. , .T. , .F. , , .F. , , , .F. )
						oBtnPrevi:Disable()

					@ 010, 130 + nPosHRod Say STR0023 Of oPanelRod Font oFont12 Pixel //"Ir para: "
						aCombo := {STR0024+" 01"} //"Página"
						For nYY := 2 to nContPg
							AADD(aCombo,STR0024+StrZero(nYY,2)) //"Página"
						Next nYY
						cCombo := aCombo[1]
						oCombo := tComboBox():New( 010 , 155 + nPosHRod , { | u | If( PCount()>0 , cCombo := u , cCombo ) } , ;
													aCombo , 55 , 10 , oPanelRod , , , ;
													{ | | MsgRun(STR0021 , , { | | fMovPnl( .F. , oCombo:nAt , , lVisual ) } ) } , ; //"Montando Tela..."
													, , .T. , , , , { | | .T. } , , , , , "cCombo" )
					oBtnNext := TButton():New( 010 , 220 + nPosHRod , STR0025 , oPanelRod , ; //"Próximo"
												{ | | MsgRun( STR0021 , , { | | fMovPnl( .F. , 0 , .T. , lVisual ) } ) } , ; //"Montando Tela..."
												50 , 10 , , , .F. , .T. , .F. , , .F. , , , .F. )
						IIF( nContPg == 1 , oBtnNext:Disable() , )
					oBtnLast := TButton():New( 010 , 280 + nPosHRod , STR0026 , oPanelRod , ; //"Última"
												{ | | MsgRun( STR0021 , , { | | fMovPnl( .F. , nContPg , , lVisual ) } ) } , ; //"Montando Tela..."
												50 , 10 , , , .F. , .T. , .F. , , .F. , , , .F. )
						IIF( nContPg == 1 , oBtnLast:Disable() , )

			If Len(aSMenu) > 0
				If Type( "oPnlPrinc" ) == "O"
					NGPOPUP( aSMenu , @oMenu )
					oPnlPrinc:bRClicked:= { | o , x , y | oMenu:Activate( x , y , oPnlPrinc ) }
				EndIf
			EndIf

		Activate MsDialog oDlgInd On Init EnchoiceBar( oDlgInd , ;
														{ | | lOk := .T. , If( fTudoOk( .F. ) , oDlgInd:End() , lOk := .F. ) } , ;
														{ | | lOk := .F. , oDlgInd:End() } , , aBtn_Topo )
		If lOk
			Begin Transaction
				fGravaReg( nOpcx , cQuest , dDtReal , cMat )
			End Transaction
		EndIf

	EndIf

	aRotina := aClone(aOldRot)

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fTelaInicial
Tele Inicial para Definição dos Cadastros

@return lOk Lógico Retorna verdadeiro na confirmação da tela

@param cQuest Caracter Codigo do Questionário
@param dDtReal Data Data de Realização do Questionário
@param cMat Caracter Código da Matrícula

@sample fTelaInicial( "" , "" , "" )

@author Jackson Machado
@since 05/02/2016
/*/
//---------------------------------------------------------------------
Static Function fTelaInicial( cQuest , dDtReal , cMat )

	Local cTitulo := ""
	Local lOk := .F.
	Local oDlgPar, oPnlText, oPanelTmp
	Local oSayDesc
	Local oGetData, oGetQuest, oGetMat
	Local oSetData, oSetQuest, oSetMat

	Define MsDialog oDlgPar Title OemToAnsi( cCadastro ) From 0,0 To 250,450 Of oMainWnd Pixel

		oDlgPar:lEscClose := .f.
		nLinObj := 2
		oPnlText := TPanel():New( 000 , 000 , , oDlgPar , , , , , CLR_WHITE , 000 , 000 , .F. , .F. )
			oPnlText:Align := CONTROL_ALIGN_ALLCLIENT

			@ 28, 012 Say oSetData Prompt STR0027 OF oPnlText Font oFont12 Pixel //"Data"
			@ 28, 085 MsGet oGetData Var dDtReal Size 60,9 Valid fValData( dDtReal ) Of oPnlText HasButton Pixel
			@ 42, 012 Say oSetQuest Prompt STR0028 OF oPnlText Font oFont12 Pixel //"Código do Questionário"
			@ 42, 085 MsGet oGetQuest Var cQuest Size 60,8 Valid ExistCPO( "TMG" , cQuest ) F3 "TMG" Of oPnlText HasButton Pixel
			@ 56, 012 Say oSetMat Prompt STR0029 OF oPnlText Font oFont12 Pixel //"Funcionário"
			@ 56, 085 MsGet oGetMat Var cMat Size 60,8 Valid ExistCPO( "SRA" , cMat ) F3 "SRA" Of oPnlText HasButton Pixel

			dbSelectArea( "SB1" )
			dbSetOrder( 1 )
			dbSeek( xFilial( "SB1" ) + TN3->TN3_CODEPI )
			cTitulo :=	AllTrim( SB1->B1_DESC ) + " - C.A. " + TN3->TN3_NUMCAP
			//---------------------------
			// Título do Grupo
			//---------------------------
			oPanelTmp := TPaintPanel():New( nLinObj - 1 , -4 , aPosObj[ 1 , 4 ] + 5 , 14 , oPnlText )
			oPanelTmp:addShape( "id=2;type=1;left=0;top=0;width=" + AllTrim( Str( aPosObj[ 1 , 4 ] * 2.2 , 5 ) ) + ";height=28;" + ;
								"gradient=1,0,-15,0,40,0.4,#C3DBF9,0.9,#83AAE2,0.0,#FFF6FF;pen-width=0;" + ;
								"pen-color=#B0C4DE;can-move=0;can-mark=0;is-blinker=1;")
			@ 2, 10 Say oSayDesc Prompt cTitulo Of oPanelTmp Font oFont16 COLOR RGB( 67 , 70 , 87 ) Pixel
			@ 2, 11 Say oSayDesc Prompt cTitulo Of oPanelTmp Font oFont16 COLOR CLR_WHITE Pixel

			oGetData:SetFocus()

	Activate MsDialog oDlgPar On Init EnchoiceBar( oDlgPar , ;
													{ | | If( fValData( dDtReal ) .And. fValRegis( cQuest , dDtReal , cMat) , ( lOk := .T. , oDlgPar:End() ) , lOk := .F. ) },;
													{ | | lOk := .F. , oDlgPar:End()} ) Centered

Return lOk
//---------------------------------------------------------------------
/*/{Protheus.doc} fValData
Valida a data do questionário

@return lRet Logico Retorna verdadeiro se a Data está correta

@param dData Data Data de Realização do Questionário

@sample fValData( "01/01/2016" )

@author Jackson Machado
@since 05/02/2016
/*/
//---------------------------------------------------------------------
Static Function fValData( dData )

	Local lRet := .T.

	If dData > dDataBase
		Help( " " , 1 , "NGATENCAO" , , STR0030 , 3 , 1 ) //"A data do questionário não pode ser maior que a data atual."
		lRet := .F.
	Endif
	If lRet .And. !NaoVazio( dData )
		lRet := .F.
	Endif

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fGravaReg
Realiza a gravação

@return Sempre verdadeiro

@param nOpcX Numerico Indica o valor da operação
@param cQuest Caracter Codigo do Questionário
@param dDtReal Data Data de Realização do Questionário
@param cMat Caracter Código da Matrícula

@sample fGravaReg( 3 )

@author Jackson Machado
@since 05/02/2016
/*/
//---------------------------------------------------------------------
Function fGravaReg( nOpcX , cQuest , dDtReal , cMat )

	Local ny,nx,cOrd,nXX,nYY,nZZ
	Local aTY8 := {}
	Local cChave := "", cNumFicha := ""

	If nOpcx == 3 .or. nOpcx == 4
		For nYY := 1 to Len( aCadTipo )
			aRespost := {}
			For nXX := 1 To Len( aCadTipo[ nYY , 4 ] )
				cStrXX := AllTrim( Str( nXX ) )
				If aCadTipo[ nYY , 6 ] //Radio
					If ValType( aCadTipo[ nYY , 8 , nXX , 1 ] ) == "N"
						If aCadTipo[ nYY , 8 , nXX , 1 ] == 1
							aAdd( aRespost , aCadTipo[ nYY , 4 , nXX ] )
						Endif
					Endif
				Else //Check
					If ValType( aCadTipo[ nYY , 8 , nXX , 1 ] ) == "L"
						If aCadTipo[ nYY , 8 , nXX , 1 ]
							aAdd( aRespost , aCadTipo[ nYY , 4 , nXX ] )
						Endif
					Endif
				Endif
			Next nXX
			If ValType( aCadTipo[ nYY , 10 ] ) == "C" //Adiciona campo memo para gravação
				If !Empty( aCadTipo[ nYY , 10 ] )
					aAdd( aRespost , "#" )
				Endif
			Endif

			//Se encontrou informação para a pergunta, grava
			For nZZ := 1 To Len( aRespost )
				dbSelectArea( "TY8" )
				dbSetOrder( 1 )
				If dbSeek( xFilial( "TY8" ) + SA2->A2_COD + SA2->A2_LOJA + TN3->TN3_CODEPI + cMat + DToS( dDtReal ) + cQuest + aCadTipo[ nYY , 1 ] + aRespost[ nZZ ] )
					RecLock( "TY8" , .F. )
					TY8->TY8_RESPOS := aRespost[ nZZ ]
					TY8->TY8_APROVA := If( lAprovacao , "1" , "2" )
				Else
					RecLock("TY8",.T.)
					TY8->TY8_FILIAL := xFilial("TY8")
					TY8->TY8_FORNEC := SA2->A2_COD
					TY8->TY8_LOJA   := SA2->A2_LOJA
					TY8->TY8_CODEPI := TN3->TN3_CODEPI
					TY8->TY8_MAT    := cMat
					TY8->TY8_QUESTI := cQuest
					TY8->TY8_DTREAL := dDtReal
					TY8->TY8_QUESTA := aCadTipo[ nYY , 1 ]
					TY8->TY8_RESPOS := aRespost[ nZZ ]
					TY8->TY8_APROVA := If( lAprovacao , "1" , "2" )
				Endif
				If aRespost[ nZZ ] == "#"
					TY8->TY8_DESCRI := aCadTipo[ nYY , 10 ]
				Endif
				TY8->( MsUnLock() )
				aAdd( aTY8 , TY8->( Recno() ) )
			Next nZZ
		Next nYY

		//Inclui ou altera o cadastro de itens do Tipo de Ficha
		dbSelectArea( "TY8" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "TY8" ) + SA2->A2_COD + SA2->A2_LOJA + TN3->TN3_CODEPI + cMat + DToS( dDtReal ) + cQuest )
			While TY8->( !Eof() ) .And. ;
				xFilial( "TY8" ) == TY8->TY8_FILIAL .And. ;
				TY8->TY8_FORNEC == SA2->A2_COD .And. TY8->TY8_LOJA == SA2->A2_LOJA .And. ;
				TY8->TY8_CODEPI == TN3->TN3_CODEPI .And. TY8->TY8_MAT == cMat .And. ;
				TY8->TY8_QUESTI == cQuest .And. TY8->TY8_DTREAL == dDtReal

				If TY8->TY8_QUESTA == Replicate( "#" , Len( TY8->TY8_QUESTA ) ) .Or. ;
					TY8->TY8_QUESTA == Replicate( "@" , Len( TY8->TY8_QUESTA ) )
					dbSelectArea( "TY8" )
					TY8->( dbSkip() )
					Loop
				EndIf

				If aScan( aTY8 , { | x | x == TY8->( Recno() ) } ) == 0
					dbSelectArea( "TY8" )
					RecLock( "TY8" , .F. )
					dbDelete()
					TY8->( MsUnLock() )
				Endif

				dbSelectArea( "TY8" )
				TY8->( dbSkip() )
			End
		Endif
	ElseIf nOpcx == 5

		dbSelectArea( "TY8" )
		dbSetOrder(1)
		If dbSeek( xFilial( "TY8" ) + SA2->A2_COD + SA2->A2_LOJA + TN3->TN3_CODEPI + cMat + DToS( dDtReal ) + cQuest )
			While TY8->( !Eof() ) .And. ;
				xFilial( "TY8" ) == TY8->TY8_FILIAL .And. ;
				TY8->TY8_FORNEC == SA2->A2_COD .And. TY8->TY8_LOJA == SA2->A2_LOJA .And. ;
				TY8->TY8_CODEPI == TN3->TN3_CODEPI .And. TY8->TY8_MAT == cMat .And. ;
				TY8->TY8_QUESTI == cQuest .And. TY8->TY8_DTREAL == dDtReal

				dbSelectArea( "TY8" )
				RecLock( "TY8" , .F. )
				TY8->( dbDelete() )
				TY8->( MsUnLock() )
				TY8->( dbSkip() )
			End
		EndIf
	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fRetCombo
Realiza a gravação

@return aArray2 Array Valores do ComboBox

@param cVar Caracter Valor do ComboBox

@sample fRetCombo( "" )

@author Jackson Machado
@since 05/02/2016
/*/
//---------------------------------------------------------------------
Static Function fRetCombo( cVar )

	Local aArray1 := RetSx3Box( cVar , , , 1 )
	Local nCont,aArray2 := {}

	For nCont := 1 To Len( aArray1 )
		If !Empty( aArray1[ nCont , 1 ] )
			aAdd( aArray2 , AllTrim( aArray1[ nCont , 1 ] ) )
		Endif
	Next nCont

Return aClone( aArray2 )
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT621RAD
Validação dos campos de Radio

@return Sempre verdadeiro

@param nTmpYY Numérico Primeira posição a ser utilizada no aCadTipo
@param nTmpXX Numérico Valor marcado

@sample MDT621RAD( 1 , 1 )

@author Jackson Machado
@since 05/02/2016
/*/
//---------------------------------------------------------------------
Function MDT621RAD( nTmpYY , nTmpXX )

	Local nX

	For nX := 1 To Len( aCadTipo[ nTmpYY , 8 ] )
		If nX == nTmpXX
			aCadTipo[ nTmpYY , 8 , nX , 1] := 1
			aCadTipo[ nTmpYY , 8 , nX , 2]:LoadBitmaps( "ngradiook" )
		Else
			If aCadTipo[nTmpYY,8,nX,1] <> 0
				aCadTipo[ nTmpYY , 8 , nX , 1 ] := 0
				aCadTipo[ nTmpYY , 8 , nX , 2 ]:LoadBitmaps( "ngradiono" )
			Endif
		Endif
	Next nX

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fImpRel
Realiza a impressão do relatório

@return Nil

@sample fImpRel()

@author Jackson Machado
@since 08/02/2016
/*/
//---------------------------------------------------------------------
Static Function fImpRel( cQuest , dDtReal , cMat )

	Local aOldTipo	:= aClone(aCadTipo)
	Local aDados	:= {}

	Private nPag410 := 0
	Private oPrint
	Private nSizeTMH := (TAMSX3("TMH_PERGUN")[1])
	Private lPrintTel := .t.
	nSizeTMH := If( nSizeTMH > 0 , nSizeTMH , 60 )

	aAdd( aDados , { "MV_PAR01" , cQuest } )
	aAdd( aDados , { "MV_PAR02" , cQuest } )
	aAdd( aDados , { "MV_PAR03" , cMat } )
	aAdd( aDados , { "MV_PAR04" , cMat } )
	aAdd( aDados , { "MV_PAR05" , dDtReal } )
	aAdd( aDados , { "MV_PAR06" , dDtReal } )
	aAdd( aDados , { "MV_PAR07" , SA2->A2_COD } )
	aAdd( aDados , { "MV_PAR08" , SA2->A2_LOJA } )
	aAdd( aDados , { "MV_PAR09" , SA2->A2_COD } )
	aAdd( aDados , { "MV_PAR10" , SA2->A2_LOJA } )
	aAdd( aDados , { "MV_PAR11" , TN3->TN3_CODEPI } )
	aAdd( aDados , { "MV_PAR12" , TN3->TN3_CODEPI } )
	aAdd( aDados , { "MV_PAR13" , 2 } )
	aAdd( aDados , { "MV_PAR14" , 1 } )
	aAdd( aDados , { "MV_PAR15" , 1 } )

	MDTR412( aDados )

	aCadTipo := aClone(aOldTipo)

	//Efetua as perguntas.
	Pergunte( "MDT621" , .F. )

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fValRegis
Validação dos campos de Radio

@return Sempre verdadeiro

@param cQuest Caracter Codigo do Questionário
@param dDtReal Data Data de Realização do Questionário
@param cMat Caracter Código da Matrícula

@sample fValRegis( "000001" , "01/01/2016" , "000001" )

@author Jackson Machado
@since 05/02/2016
/*/
//---------------------------------------------------------------------
Static Function fValRegis( cQuest , dDtReal , cMat )

	Local lRet := .T.

	dbSelectArea( "TY8" )
	dbSetOrder( 1 )
	If dbSeek( xFilial( "TY8" ) + SA2->A2_COD + SA2->A2_LOJA + TN3->TN3_CODEPI + cMat + DToS( dDtReal ) + cQuest )
		MsgStop( STR0031 ) //"Já existe um Questionário para essa Data."
		lRet := .F.
	EndIf
	If Empty( dDtReal ) .Or. Empty( cMat ) .Or. Empty( cQuest )
		MsgInfo( STR0032 ) //"O preenchimento de todos os campos é obrigatório."
	EndIf

	If lRet .And. !ExistCPO( "SRA" , cMat , 1 )
		lRet := .F.
	EndIf
	If lRet .And. !ExistCPO( "TMG" , cQuest , 1 )
		lRet := .F.
	EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fTudoOk
Validação da Confirmação da Tela

@return lRet Logico Retorna verdadeiro quando respostas estao corretas

@sample fTudoOk()

@author Jackson Machado
@since 05/02/2016
/*/
//---------------------------------------------------------------------
Static Function fTudoOk()

	Local nRepost := 0
	Local nXX  := 0, nYY := 0
	Local lRet := .T.

	For nYY := 1 to Len( aCadTipo )
		For nXX := 1 To Len( aCadTipo[ nYY , 4 ] )
			cStrXX := Alltrim( Str( nXX ) )
			If aCadTipo[ nYY , 6 ] //Radio
				If ValType( aCadTipo[ nYY , 8 , nXX , 1 ] ) == "N"
					If aCadTipo[ nYY , 8 , nXX , 1 ] == 1
						nRepost += 1
					Endif
				Endif
			Else //Check
				If ValType( aCadTipo[ nYY , 8 , nXX , 1 ] ) == "L"
					If aCadTipo[ nYY , 8 , nXX , 1 ]
						nRepost += 1
					Endif
				Endif
			Endif
		Next nXX
		If Empty( aCadTipo[ nYY , 4 ] ) .And. !Empty( aCadTipo[ nYY , 10 ] )
			nRepost += 1
		EndIf
	Next nYY
	If nRepost < Len( aCadTipo ) .And.  ( Inclui .or. Altera )
		If !( MsgYesNo( STR0033 , STR0002 ) )//"Há perguntas que ainda não foram respondidas!"###"ATENÇÃO"
			lRet := .F.
		Endif
	EndIf

	If ( Inclui .or. Altera )
		lAprovacao := MsgYesNo( STR0034 ) //"O equipamento foi devidamente aprovado pelo funcionário?"
	EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fQtdObject
Função que calcula a quantidade de objetos que serão criados por essa pergunta.

@return nRet Numerico Quantidade de objetos

@param aPerg Array com os valores da pergunta
@param cOldGrupo Caracter Código do Grupo para Controle

@sample fQtdObject( {} , "" )

@author Jackson Machado
@since 05/02/2016
/*/
//---------------------------------------------------------------------
Static Function fQtdObject( aPerg , cOldGrupo )

	Local nRet 	:= 0

	If aPerg[ 3 ] <> cOldGrupo //Panel do grupo
		nRet += 2
	EndIf
	If aPerg[ 6 ] //Radio
		nRet += 2
	Else //CheckBox
		nRet += 1
	EndIf
	If aPerg[ 7 ] //Objeto Memo
		nRet += 1
	EndIf
	nRet += 2 // Acrescenta objeto da pergunta e groupbox

Return nRet
//---------------------------------------------------------------------
/*/{Protheus.doc} fMovPnl
Função que controla apresentação dos panels(paginação).

@return Nil

@param lPrim Logico com os valores da pergunta
@param nForcePainel Numerico Indica o número fixo do painel
@param lProxima Logico Indica se é próximo painel
@param lVisual Logico Inddica se é visualização

@sample fMovPnl( .F. , nContPg , , lVisual )

@author Jackson Machado
@since 05/02/2016
/*/
//---------------------------------------------------------------------
Static Function fMovPnl(lPrim,nForcePainel,lProxima,lVisual)

	Local n := 0
	Local cOldGrupo := ""

	If nForcePainel == 0 .And. !lPrim
		If lProxima
			nForcePainel := nLastPanel + 1
		Else
			nForcePainel := nLastPanel - 1
		EndIf
	Endif
	oPnlPrinc:FreeChildren() //Desabilita Panel anterior

	If !lPrim
		If nForcePainel == aCadTipo[ Len( aCadTipo ) , 13 ]
			nLinObj := 27
			nPosPnl := 0
			cOldGrupo := "#"
			For n := 1 to Len( aCadTipo )
				If aCadTipo[ n , 13 ] == nForcePainel
					fMontaPag( cOldGrupo , n , lVisual , oPnlPrinc )
					cOldGrupo := aCadTipo[ n , 3 ]
				EndIf
			Next n
			oBtnFirst:Enable()
			oBtnPrevi:Enable()
			oBtnLast:Disable()
			oBtnNext:Disable()
			nLastPanel := nForcePainel
		Else
			nLinObj := 27
			nPosPnl := 0
			cOldGrupo := "#"
			For n := 1 to Len( aCadTipo )
				If aCadTipo[ n , 13 ] == nForcePainel
					fMontaPag( cOldGrupo , n , lVisual , oPnlPrinc )
					cOldGrupo := aCadTipo[ n , 3 ]
				EndIf
			Next n
			nLastPanel := nForcePainel
			If nForcePainel <> 1
				oBtnFirst:Enable()
				oBtnPrevi:Enable()
				oBtnLast:Enable()
				oBtnNext:Enable()
			Else
				oBtnFirst:Disable()
				oBtnPrevi:Disable()
				oBtnLast:Enable()
				oBtnNext:Enable()
			EndIf
		EndIf
	ElseIf lPrim
		nPosPnl := 0
		nLinObj := 27
		cOldGrupo := "#"
		For n := 1 to Len( aCadTipo )
			If aCadTipo[ n , 13 ] == 1
				fMontaPag( cOldGrupo , n , lVisual , oPnlPrinc )
				cOldGrupo := aCadTipo[ n , 3 ]
			EndIf
		Next n
		nLastPanel := 1
		oBtnFirst:Disable()
		oBtnPrevi:Disable()
		oBtnLast:Enable()
		oBtnNext:Enable()
	EndIf

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} fMontaPag
Função que so objetos de tela referente as perguntas do questionário.

@return Nil

@param cOldGrupo Caracter Código do Grupo para Controle
@param nPos Numerico posição do aCadTipo a ser montada
@param lVisual Logico Indica se é apenas visualização
@param oObjPai Objeto Objeto onde deverá ser montado

@sample fMontaPag( "Grupo" , 1 , .F. , oObjeto )

@author Jackson Machado
@since 05/02/2016
/*/
//---------------------------------------------------------------------
Static Function fMontaPag( cOldGrupo , nPos , lVisual , oObjPai )

	Local nXX := 0
	Local cDesGrupo

	If cOldGrupo <> aCadTipo[ nPos , 3 ]
		cOldGrupo := aCadTipo[ nPos , 3 ]
		cDesGrupo := " "
		dbSelectArea( "TK0" )
		dbSetOrder( 01 )
		If dbSeek( xFilial( "TK0" ) + cOldGrupo )
			If !Empty( TK0->TK0_DESCRI )
				cDesGrupo := Capital( Alltrim( TK0->TK0_DESCRI ) )
			Endif
		Endif
		//---------------------
		// Titulo do Grupo
		//---------------------
		oPanelTmp := TPaintPanel():New( nPosPnl - 1 , 0 , aPosObj[ 1 , 4 ] , 10 , oObjPai )
		oPanelTmp:addShape( "id=1;type=1;left=0;top=0;width=" + AllTrim( Str( aPosObj[ 1 , 4 ] * 2,5 ) ) + ";height=20;" + ;
							"gradient=1,0,0,0,15,0.0,#FFFFFF,0.1,#FFFFFF,1.0,#FFFFFF;pen-width=1;" + ;
							"pen-color=#FFFFFF;can-move=0;can-mark=0;is-blinker=1;" )

		oPanelTmp:addShape( "id=2;type=2;left=10;top=0;width=" + Alltrim( Str( aPosObj[ 1 , 4 ] * nFatMlt , 5 ) ) + ";height=20;" + ;
							"gradient=1,0,0,0,15,0.0,#FFFFFF,0.1,#FDFBFD,1.0,#CDD1D4;pen-width=1;" + ;
							"pen-color=#B0C4DE;can-move=0;can-mark=0;is-blinker=1;" )

		@ 1, 11 Say aIndNG[ nPos , 3 ] Prompt Space(40) Of oPanelTmp Font oFont12 Pixel
		aIndNG[ nPos , 3 ]:SetText( cDesGrupo )
		nLinObj += 13
		nPosPnl += 13
	Endif

	cStrYY := Alltrim( Str( nPos ) )
	//---------------------
	// Titulo Questão
	//---------------------
	nPosOld := nPosPnl + 7
	@ nPosPnl, 009 Say aIndNG[ nPos , 1 ] Prompt Space( 40 ) Of oObjPai Font oFont12 Pixel
	aIndNG[ nPos , 1 ]:bSetGet := ;
		&( "{ | u | If( pCount() == 0 , aCadTipo[ " + cStrYY + " , 2 ] , aCadTipo[ " + cStrYY + " , 2 ] := u ) }" )
	aIndNG[ nPos , 1 ]:SetText( aCadTipo[ nPos , 2 ] )

	//------------------------------------------------------
	// Montando lista de opcoes (radio ou check)
	//------------------------------------------------------
	nLimCol   := aSize[ 5 ] / 8
	nAcumLi := 0
	For nXX := 1 To Len( aCadTipo[ nPos , 4 ] )
		cStrXX := AllTrim( Str( nXX ) )
		cDescBox := SubStr( aCadTipo[ nPos , 4 , nXX ] , 3 )
		If ( nAcumLi + Len( cDescBox ) + 5 ) > nLimCol .Or. nXX == 1
			nLinObj += 9
			nAcumLi := 0
			nPosPnl += 9
		Endif
		If aCadTipo[ nPos , 6 ]
			aCadTipo[ nPos , 8 , nXX , 2 ] := TBtnBmp2():New( nPosPnl*2,26+(nAcumLi*7),14,14, ;
						If( aCadTipo[ nPos , 8 , nXX , 1 ] == 0 , "ngradiono" , "ngradiook" ) , , , , { || } , oObjPai , , , .T. )
			@ nPosPnl , 22 + ( nAcumLi * 3.5 ) Say aCadTipo[ nPos , 8 , nXX , 3 ] Prompt Space( 30 ) Of oObjPai Pixel
			aCadTipo[ nPos , 8 , nXX , 3 ]:SetText( cDescBox )
			If lVisual
				aCadTipo[ nPos , 8 , nXX , 2 ]:lReadOnly := .T.
			Else
				aCadTipo[ nPos , 8 , nXX , 3 ]:bLClicked := &( " { | | MDT621RAD( " + cStrYY + " , " + cStrXX + " ) }")
				aCadTipo[ nPos , 8 , nXX , 2 ]:bAction := &( " { | | MDT621RAD( " + cStrYY + " , " + cStrXX + " ) }")
			Endif
		Else
			aCadTipo[ nPos , 8 , nXX , 2 ] := TCheckBox():New( nPosPnl , 13 + ( nAcumLi * 3.5 ) , cDescBox , , oObjPai , 13 + ( Len( cDescBox ) * 3.9 ) , 7 , , , , , , , , .T. )
			aCadTipo[ nPos , 8 , nXX , 2 ]:bSetGet := &( "{ | u | If( PCount() == 0 , aCadTipo[ " + cStrYY + " , 8 , " + cStrXX + " , 1 ] , aCadTipo[ " + cStrYY + " , 8 , " + cStrXX + " , 1 ] := u ) } " )
			If lVisual
				aCadTipo[ nPos , 8 , nXX , 2 ]:lReadOnly := .T.
			Endif
		Endif
		nAcumLi += Len( cDescBox ) + 8
	Next nXX

	If aCadTipo[ nPos , 7 ]
		//---------------
		// Campo Memo
		//---------------
		nLinObj += 10
		nPosPnl += 10
		aIndNG[nPos,2] := TMultiGet():New( nPosPnl , 12 , , oObjPai , aPosObj[ 1 , 4 ] - 30 , 18 , , , , , , .T. )
		aIndNG[nPos,2]:EnableHScroll( .T. )
		aIndNG[nPos,2]:EnableVScroll( .T. )
		aIndNG[nPos,2]:bWhen := &( " { | | MDT621OBS( "+ cStrYY +" ) } " ) //Função para atualizar o When do campo Memo
		aIndNG[nPos,2]:bSetGet := ;
			&( " { | u | If( pCount() == 0 , aCadTipo[ " + cStrYY + " , 10 ] , aCadTipo[ " + cStrYY + " , 10 ] := u ) } " )
		nLinObj += 12
		nPosPnl += 12
		If lVisual
			aIndNG[ nPos , 2 ]:lReadOnly := .T.
		Endif
		aIndNG[ nPos , 2 ]:Refresh()
	Endif
	nLinObj += 13
	nPosPnl += 13
	@ nPosOld , 09 TO nPosPnl - 3 , aPosObj[ 1 , 4 ] - 15 Of oObjPai Pixel

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT621OBS
Habilita campo de observação se opção da Resposta for 'Sim' ou
se for varias opções para selecionar.

@return lRet Logico Retorna verdadeiro quando campo memo atualizado

@param nPosObj Numerico Posição do Objeto

@sample MDT621OBS( 1 )

@author Jackson Machado
@since 05/02/2016
/*/
//---------------------------------------------------------------------
Function MDT621OBS( nPosObj )

	Local lRet := .F.
	Local nOpcoes := Len( aCadTipo[ nPosObj , 4 ] ) //Variavel para verificar se possui opções para escolher

	If nOpcoes > 0 .And. mv_par01 == 1
		nPosYes := aScan( aCadTipo[ nPosObj , 4 ] , { |x| UPPER( STR0035 ) $ AllTrim( UPPER( x ) ) } ) //Verifica se Sim esta nas opções###"Sim"
		If nPosYes > 0
			If ValType( aCadTipo[ nPosObj , 8 , nPosYes , 1 ] ) == "N" //Verifica se a posição é numérica
				lRet := aCadTipo[ nPosObj , 8 , nPosYes , 1 ] == 1
				If !lRet //Se for a opção Não, vai limpar Memo
					aCadTipo[ nPosObj , 10] := ""
				EndIf
			EndIf
		EndIf
		If ValType( aCadTipo[ nPosObj , 8 , 1 , 1 ] ) == "L" //Verifica se a posição é Lógica
			lRet := .T. //Se for Opção Exclusiva, e a selecionada for diferente de 'Sim'.
		EndIf
	Else
		lRet := .T.
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT621OBD
Função responsavel por habilitar o preenchimento do campo de Observação,
mesmo não existindo campos de perguntas.

@Param cPerg - Pergunta utilizada.

@author Guilherme Freudenburg
@since 09/05/2016
@return
/*/
//---------------------------------------------------------------------
Static Function MDT621OBD(cPerg)

Local nBck := 0 //Backup para a opção selecionada
Local lPerg := .F. //Determina se foi alterado a opção

//Cria Backup da opção selecionada atualmente
nBck := mv_par01

lPerg:= Pergunte( cPerg , .T. )

If !lPerg
	mv_par01 := nBck //Caso não confirme será retorna a opção anterior
Endif

Return