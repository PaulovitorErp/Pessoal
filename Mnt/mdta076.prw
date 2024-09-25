#Include "Protheus.ch"
#Include "Colors.ch"
#Include "MDTA076.ch"

//Codificacoes de SQL
Static cSubString := IIf( "MSSQL" $ Upper( TCGetDB() ), "SUBSTRING", "SUBSTR" )

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA076
Interface de Agendamento Médico

@type function
@source MDTA076.prw
@author Bruno Lobo
@since 10/09/2014

@sample MDTA076()

@return Nulo, Sempre Nulo
@todo Tratar para fazer quebra de horário para dias diferentes.
/*/
//---------------------------------------------------------------------
Function MDTA076()
	//---------------------------------------------
	// Guarda conteudo e declara variaveis padroes
	//---------------------------------------------
	Local aNGBEGINPRM := NGBEGINPRM()

	Local oDlg
	Local oPnlScreen
	Local oPnlBtn
	Local oPnlLeg
	Local oPnlTNGAG
	Local oPnlTop
	Local oPnlLeft
	Local nWidScr
	Local nHeiScr
	Local nRegua
	Local nTamReg
	Local nId		:= 0
	Local aColor	:= NGCOLOR()
	Local cTitle 	:= STR0001 //"Agenda Médica Mod. 2"
	Local cHex		:= NGRGBHEX( ConvRGB( NGColor()[2] ) )
	Local aMedicos 	:= {}
	Local aRegua	:= { "", "10min.", "", "20min.", "", "30min.", "", "40min.", "", "50min.", "" }
	Local lValid	:= .F.

	Private cNewHrIni	:= "" //Novo horario inicial da consulta
	Private cNewQtHour	:= "" //Novo tempo de consulta

	//Indica se atualiza tela
	//variavel criada, pq ao entrar no MDTA410 e realizar a transferencia
	//e possuir interferencias a tela é atualizada
	//Então ao sair do MDTA410 a variavel receberá .F. para não atualizar novamente
	Private lAtualTela := .T.

	Private aSize	   := MsAdvSize( , .F., 430 )
	Private aObjects   := {}
	Private aPerg	   := {}
	Private nIdNDate   := 0
	Private nPosNDate  := 0
	Private nPosMed	   := 1
	Private nIdNMed	   := 0
	Private nOpcX	   := 0
	Private cQtHrCons  := "" //Quantidade de horas da consulta ao realizar transferencia
	Private aTRBAte    := {}
	Private cPerg	   := PadR( "MDT076", 10 )
	Private oTNGAG
	Private oCalend
	Private oTPanel
	Private oHorario
	Private cAliasMed
	Private cAliasCal
	Private cAliasAte
	Private cMedico
	Private cCalend
	Private dDiaAtu


	//Variáveis necessárias para o MDTA160
	Private LEDTEMIS	:= .T. //Abertura do campo para atender ao eSocial (ASO's de terceiros)
	Private LEDTCANC	:= .F.
	Private LEEXAME		:= .F.
	Private LENUMFIC	:= .T.
	Private LECODUSU	:= .T.
	Private LEDTPROG	:= .T.
	Private TMTNUMFIC	:= .F.// DESABILITA CAMPO TMT_NUMFIC DO TMT
	Private TMTDTCONS	:= .F.// DESABILITA CAMPO TMT_DTCONS DO TMT
	Private TMTHRCONS	:= .F.// DESABILITA CAMPO TMT_HRCONS DO TMT
	Private TMTHRRETO	:= .F.// DESABILITA CAMPO TMT_HRCONS DO TMT
	Private TMTCODUSU	:= .F.// DESABILITA CAMPO TMT_CODUSU DO TMT
	Private lEmail		:= Alltrim( GetMV( "MV_NG2COMA" ) ) == "S"
	Private cCadastro	:= STR0002 //"Atendimento Médico"

	//Variaveis FwTemporaryTable
	Private oTempMed, oTempAte, oTempCal

	//Sem suporte para P.S.
	Private lSigaMdtPS	:= .F.

	aAdd( aObjects, { 050, 050, .T., .T. } )
	aAdd( aObjects, { 020, 020, .T., .T. } )
	aAdd( aObjects, { 100, 100, .T., .T. } )

	If !AliasInDic( "TY9" )
		ShowHelpDlg( STR0003,;      //"ATENÇÃO"
					 { STR0004 }, 2,; //"A tabela de Reserva/Bloqueio não existe."
					 { STR0005 }, 2 ) //"Está rotina estara disponível a partir da release 12.1.17."
		Return .F.
	EndIf

	aInfo	:= { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	fCreateTRB( @cAliasMed, @cAliasCal )

	fGetAgenda( cAliasMed, @aMedicos ) //Busca dados referentes a agenda

	//se não possuir médicos ou agenda, devera informar se o mesmo deseja incluir
	If ( cAliasMed )->( RecCount() ) == 0

		If SuperGetMV( "MV_NG2SEG", .F., "2" ) == "1"
			If MsgYesNo( STR0006 + STR0112 ) //"Usuário não possui agenda médica cadastrada."###"Deseja incluir uma agenda para o médico ?"
				INCLUI := .T.
				If NGCAD01( "TML", TML->( RecNo() ), 3 ) == 1
					fGetAgenda( cAliasMed, @aMedicos ) //Busca dados referentes a agenda
				Else
					lValid := .T. //indica que deverá apresentar a outra mensagem caso não incluir
				EndIf
			EndIf
		Else
			//verifica se possui médico
			If MDT076VERI() //retorna .T. se possuir médicos e .F. se não possuir
				If MsgYesNo( STR0006 + STR0112 ) //"Usuário não possui agenda médica cadastrada."###"Deseja incluir uma agenda para o médico ?"
					INCLUI := .T.
					If NGCAD01( "TML", TML->( RecNo() ), 3 ) == 1
						fGetAgenda( cAliasMed, @aMedicos ) //Busca dados referentes a agenda
					Else
						lValid := .T. //indica que deverá apresentar a outra mensagem caso não incluir
					EndIf
				EndIf
			Else
				If MsgYesNo( STR0008 + " " + STR0113 ) //"Não existe médico com agenda cadastrada."###"Deseja incluir um médico?"
					If MDT076MED( 3, .F., , , , , , , , , , , , oDlg ) //incluir médico
						fGetAgenda( cAliasMed, @aMedicos ) //Busca dados referentes a agenda
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If ( cAliasMed )->( RecCount() ) > 0 .And. Len( aMedicos ) != 0

		fGetAtend( cAliasAte, aTRBAte, ( cAliasMed )->CODUSU, dDataBase )

		//Tamanho da tela, minimo aceitavel
		If aSize[6] < 603 .Or. aSize[5] < 1349
			nValVer := 603
			nValHor := 1349
		Else
			nValVer := aSize[6]
			nValHor := aSize[5]
		EndIf

		//Criação da tela dos agendamentos
		DEFINE MSDIALOG oDLG FROM aSize[7], 0 To nValVer, nValHor TITLE cTitle PIXEL

			oPnlScreen := TPanel():New( 0, 0, , oDlg, , , , , aColor[ 2 ], 0, 0, .F., .F. )
				oPnlScreen:Align := CONTROL_ALIGN_ALLCLIENT
				nWidScr := oPnlScreen:nClientWidth
				nHeiScr := oPnlScreen:nClientHeight

				oPnlLeft := TPanel():New( 0, 0, , oPnlScreen, , , , , aColor[ 2 ], 15, 0, .F., .F. )
					oPnlLeft:Align := CONTROL_ALIGN_LEFT

					oPnlBtn := TPanel():New( 0, 0, , oPnlLeft, , , , , aColor[ 2 ], 0, 0, .F., .F. )
						oPnlBtn:Align := CONTROL_ALIGN_ALLCLIENT

				oPnlLeg := TPanel():New( 15, 0, , oPnlScreen, , , , , aColor[ 2 ], nWidScr, 15, .F., .F. )
					oPnlLeg:Align := CONTROL_ALIGN_BOTTOM

				fAgPnlLeg( @oPnlLeg ) //Monta painel de legendas

				oPnlTop := TPanel():New( 0, 0, , oPnlScreen, , , , , aColor[ 2 ], nWidScr, 70, .F., .F. )
					oPnlTop:Align := CONTROL_ALIGN_TOP

					//----------------------------
					// Calendario
					//----------------------------
					nIdNDate := Val( SumId( @nId ) )
					oCalend := MsCalend():New( 02, 02, oPnlTop, .F. )
					oCalend:bChange := {|| oCalend:CtrlRefresh(), fChangeDay( oCalend, nIdNDate, nPosNDate, oTPanel, oTNGAG, cAliasAte ) }
					oCalend:bChangeMes := {|| oCalend:CtrlRefresh(), fChangeMonth( oCalend, nIdNDate, nPosNDate, oTPanel, oTNGAG, cAliasAte ) }
					oCalend:Align := CONTROL_ALIGN_LEFT
					dDiaAtu := oCalend:dDiaAtu

					oTPanel := TPaintPanel():New( 0, 0, 300, 200, oPnlTop )
					oTPanel:Align := CONTROL_ALIGN_ALLCLIENT

					nWidF := oTPanel:nClientWidth
					nHeiF := oTPanel:nClientHeight
					nTamReg	:= nWidF / 12


					oTPanel:addShape( "id=" + SumId( @nId ) + ";type=1;" +;
									 "left=0;top=2;width=" + cValToChar( nWidF ) + ";height=" + cValToChar( nHeiF ) + ";" +;
									 "gradient=1,0,0,0,40,0.0,#" + cHex + ";pen-width=1;pen-color=#D8E4F4;can-move=0;can-mark=0;is-container=1;" )
					//----------------------------
					//	Shape Mês/Ano
					//----------------------------
					oTPanel:addShape( "id=" + SumId( @nId ) + ";type=1;" +;
									 "left=0;top=2;width=" + cValToChar( nWidF ) + ";height=50;" +;
									 "gradient=1,0,0,0,30,0.0,#DDEAFB,0.5,#C9DAF4,1.0,#D8E4F4;pen-width=1;" +;
									 "pen-color=#FFFFFF;can-move=0;can-mark=0;is-container=1;" )

					nPosNDate := nWidF

					//----------------------------
					//	Médico
					//----------------------------
					oTPanel:addShape( "id=" + SumId( @nId ) + ";type=1;" +;
									 "left=0;top=50;width=" + cValToChar( nWidF ) + ";height=52;" +;
									 "gradient=1,0,0,0,0,0.0,#FFFFFF;pen-width=1;pen-color=#FFFFFF;can-move=0;can-mark=0;is-container=1;" )

					oTPanel:addShape( "id=" + SumId( @nId ) + ";type=2;" +;
									 "left=25;top=55;width=" + cValToChar( nWidF - 50 ) + ";height=042;" +;
									 "gradient=1,0,0,0,30,0.0,#DDEAFB,0.5,#C9DAF4,1.0,#D8E4F4;pen-width=1;" +;
									 "pen-color=#ffffff;can-move=0;can-mark=0;is-blinker=1;large=10;" )

					ChangeMed( 0, @nId, aMedicos, @nPosMed, oTPanel, @nIdNMed )

					oBtnLeft := TButton():New( 025, 000, "<", oTPanel, , 10, 25, , , .F., .T., .F., , .F., , , .F. )
					oBtnLeft:bAction := { |x, y| ChangeMed( 1, @nId, aMedicos, @nPosMed, oTPanel, @nIdNMed, oTNGAG, oCalend, nIdNDate, nPosNDate, cAliasAte ) }
					oBtnLeft:SetCSS( "QPushButton{ background-color: #F4F4F4; color: #BEBEBE; font-size: 20px; border: 1px solid #D3D3D3; font-weight: bold } " +;
									 "QPushButton:Focus{ background-color: #FFFAFA; } " +;
									 "QPushButton:Hover{ background-color: #F4F4F4; color: #000000; border: 1px solid #D3D3D3; } " )

					oBtnRight := TButton():New( 025, ( nWidF / 2 ) - 11, ">", oTPanel, , 10, 25, , , .F., .T., .F., , .F., , , .F. )
					oBtnRight:bAction := { |x, y| ChangeMed( 2, @nId, aMedicos, @nPosMed, oTPanel, @nIdNMed, oTNGAG, oCalend, nIdNDate, nPosNDate, cAliasAte ) }
					oBtnRight:SetCSS( "QPushButton{ background-color: #F4F4F4; color: #BEBEBE; font-size: 20px; border: 1px solid #D3D3D3; font-weight: bold } " +;
									 "QPushButton:Focus{ background-color: #FFFAFA; } " +;
									 "QPushButton:Hover{ background-color: #F4F4F4; color: #000000; border: 1px solid #D3D3D3; } " )

					//----------------------------
					//	Regua
					//----------------------------
					oTPanel:addShape( "id=" + SumId( @nId ) + ";type=1;" +;
									 "left=0;top=102;width=" + cValToChar( nWidF ) + ";height=40;" +;
									 "gradient=1,0,0,0,30,0.0,#DDEAFB,0.5,#C9DAF4,1.0,#D8E4F4;pen-width=1;pen-color=#FFFFFF;" +;
									 "can-move=0;can-mark=0;is-container=1;" )

					nLftReg := nTamReg
					For nRegua := 1 To Len( aRegua )
						oTPanel:addShape( "id=" + SumId( @nId ) + ";type=7;" +;
										 "left=" + cValToChar( nLftReg - 20 ) + ";top=110;width=40;height=20;" +;
										 "font=arial,10,0,0,1;text=" + aRegua[nRegua] + ";pen-color=#434657;pen-width=2;" +;
										 "gradient=1,0,0,0,0,0,#434657;" )

						oTPanel:addShape( "id=" + SumId( @nId ) + ";type=9;" +;
										 "from-left=" + cValToChar( nLftReg ) + ";from-top=130;to-left=" + cValToChar( nLftReg ) +;
										 ";to-top=140;pen-width=1;pen-color=#434657;" )

						nLftReg := nLftReg + nTamReg
					Next nRegua

				oPnlTNGAG := TPanel():New( 10, 0, , oPnlScreen, , , , , aColor[ 2 ], nWidScr - 15, nHeiScr - 15, .F., .F. )
					oPnlTNGAG:Align := CONTROL_ALIGN_ALLCLIENT

					//--------------------------------------------------
					// Instancia Objeto da classe TNGAG - Agenda Médica
					//--------------------------------------------------
					oTNGAG := TNGAG():New( oPnlTNGAG, 248, 0, 5 /*tempo minimo da consulta*/,;
										 { | x, y | fLClick( x, y, oTNGAG, cAliasAte, oTNGAG, oCalend, nIdNDate, nPosNDate, oTPanel ) },;
										 { | x, y, o | fRClick( x, y, oTNGAG, oCalend, nIdNDate, nPosNDate, oTPanel, oTNGAG, cAliasAte ) } )
						oTNGAG:HalfBox()

						oHorario := oTNGAG
						//criação dos botoes laterais
						fAgPnlBtn( oPnlBtn, oDlg, aMedicos, oTPanel, oTNGAG, oCalend, cAliasAte,;
								 nIdNDate, nPosNDate, cAliasMed, @nIdNMed, @nPosMed, @nId ) //Monta painel de botões

						//Executa a Inclusão dos Atendimentos Iniciais
						fChangeDay( oCalend, nIdNDate, nPosNDate, oTPanel, oTNGAG, cAliasAte )

						fChgColDay( oCalend, cAliasAte )

		ACTIVATE MSDIALOG oDlg

	EndIf
	oTempMed:Delete()
	oTempAte:Delete()
	oTempCal:Delete()

	lREFRESH := .T.

	//-----------------------------------------
	// Retorna conteudo de variaveis padroes
	//-----------------------------------------
	NGRETURNPRM( aNGBEGINPRM )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SumId
Soma os IDs

@type function

@source MDTA076.prw
@author Bruno Lobo
@since 10/09/2014

@param nId, Numerico, Último ID utilizado
@sample SumId( @nVarId )
@return Caracter, Valor do Próximo ID
/*/
//---------------------------------------------------------------------
Function SumId( nId )
Return cValToChar( nId++ )

//---------------------------------------------------------------------
/*/{Protheus.doc} fLClick
Função do duplo clique

@author Bruno Lobo
@since 10/09/2014

@param x, Distância horizontal da janela
@param y, Distância Vertical da janela
@param oTPanel, Objeto do TPaintPanel
@param cAliasAte, TRB do Atendimento.
@param oHorario, Objeto do TNGAG
@param oCalend, Objeto do MsCalend
@param nIdNDate, Id da data do calendário
@param nPosNDate, Numerico

/*/
//---------------------------------------------------------------------
Static Function fLClick( x, y, oTPanel, cAliasAte, oHorario, oCalend, nIdNDate, nPosNDate )

	Local aNao 		:= {}
	Local cText 	:= ""
	Local lInfor 	:= .F. //Variavel para verificar se deve informar o horario de chegada
	Local nIDPos	:= oTPanel:GetId()
	Local nDiag		:= 0
	Local nRet		:= 0
	Local nOpca

	Private cHora 	:= oTPanel:GetHoraRef( cValToChar( nIDPos ) )
	Private dDiaAtu	:= oCalend:dDiaAtu
	Private cFicha	:= ""

	//Posiciona na tabela para buscar a ficha correta
	dbSelectArea( cAliasAte )
	dbSetOrder( 4 ) //CODUSU+DtoS(DTCONS)+HRCONS
	If dbSeek( cMedico + DtoS( dDiaAtu ) + cHora )
		Private cFicha	:= ( cAliasAte )->NUMFIC
	EndIf

	//verifica se o duplo clique é sobre algum horario reservado ou bloqueado.
	If Empty( cFicha )
		dbSelectArea( "TY9" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "TY9" ) + cMedico + DtoS( dDiaAtu ) + cHora )
			If Len( AllTrim( cHora ) ) == 5 //verifica se foi clicado em algum horário valido
				If TY9->TY9_TIPOAG == "1" //reservar
					If MsgYesno( STR0009 )//"Este horário está reservado, deseja realizar o agendamento ?"
						MDT076AGE( oTPanel, oCalend, nIdNDate, nPosNDate, oTPanel, oHorario, cAliasAte, cHora, dDiaAtu, .F. )
						Return .T.
					Else
						Return .F.
					EndIf
				ElseIf TY9->TY9_TIPOAG == "2" //bloquear
					If MsgYesno( STR0010 )//"Este horário está bloqueado, deseja realizar o agendamento ?"
						MDT076AGE( oTPanel, oCalend, nIdNDate, nPosNDate, oTPanel, oHorario, cAliasAte, cHora, dDiaAtu, .F. )
						Return .T.
					Else
						Return .F.
					EndIf
				EndIf
			EndIf
		Else
			If Len( AllTrim( cHora ) ) == 5 //verifica se foi clicado em algum horário valido
				nRet := Aviso( STR0001, STR0011, { STR0012, STR0013, STR0014, STR0015 } )//"Agenda Médica Mod. 2"###"Selecione a opção desejada para o horário escolhido."###"Agendar"###"Bloquear"###"Reservar"###"Voltar"

				If nRet == 1
					MDT076AGE( oTPanel, oCalend, nIdNDate, nPosNDate, oTPanel, oHorario, cAliasAte, cHora, dDiaAtu )
				ElseIf nRet == 2
					MDT076RES( oHorario, oCalend, nIdNDate, nPosNDate, oTPanel, oHorario, cAliasAte, "2", cHora, dDiaAtu, .T. )
				ElseIf nRet == 3
					MDT076RES( oHorario, oCalend, nIdNDate, nPosNDate, oTPanel, oHorario, cAliasAte, "1", cHora, dDiaAtu, .T. )
				ElseIf nRet == 4
					Return .F.
				EndIf
			EndIf
		EndIf
		//------------------------------------------

	Else
		cText := STR0019 //"Selecione a opção desejada para o horário escolhido. "
		cText += STR0020 //"Informar o horário de chegada do funcionário, realizar o atendimento médico ou fazer o encaixe de uma nova consulta."

		nRet := Aviso( STR0001, cText, { STR0016, STR0017, STR0018, STR0015 } )//"Agenda Médica Mod. 2"###"Hora chegada"###"Atender"###"Encaixar"###"Voltar"

		If nRet == 1 .Or. nRet == 2

			//verifica se foi informado horario de chegada
			If nRet == 2

				//se o dia selecionado para realizar o atendimento
				//é maior que a data atual, devera bloquear
				If dDiaAtu > dDataBase
					ShowHelpDlg( STR0003, { STR0021 }, 2,; //"Atenção"###"A data selecionada é superior a data atual."
								 { STR0022 }, 2 )         //"Favor selecionar uma data igual ou inferior."
					Return .F.
				EndIf

				dbSelectArea( "TMJ" )
				dbSetOrder( 1 )
				If dbSeek( xFilial( "TMJ" ) + cMedico + DTOS( dDiaAtu ) + cHora )

					If Len( AllTrim( TMJ->TMJ_HRCHGD ) ) != 5

						//-------------------------------------------------------
						// Mensagens:
						// "Atenção"
						// "O campo Horário de Chegada não foi informado."
						// "Favor informar o Horário de Chegada do Funcionário."
						//-------------------------------------------------------
						Help( Nil, Nil, STR0003, Nil, STR0023, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0024 } )

						lInfor := .T.

					EndIf

				EndIf

			EndIf

			If nRet == 1 .Or. lInfor
				//Atribui valor as variaveis de tela
				dbSelectArea( "TMJ" )
				RegToMemory( "TMJ", .F., , .F. )

				//Atribui valor para memória
				//---------------------------------------
				dbSelectArea( "TMJ" )
				dbSetOrder( 1 )
				If dbSeek( xFilial( "TMJ" ) + cMedico + DTOS( dDiaAtu ) + cHora )
					M->TMJ_CODUSU	:= cMedico
					M->TMJ_NOMUSU	:= NGSeek( "TMK", cMedico, 1, "TMK_NOMUSU" )
					M->TMJ_DTCONS	:= dDiaAtu
					M->TMJ_HRCONS	:= cHora
					M->TMJ_NUMFIC	:= TMJ->TMJ_NUMFIC
					M->TMJ_NOMFIC	:= NGSeek( "TM0", TMJ->TMJ_NUMFIC, 1, "TM0_NOMFIC" )
					M->TMJ_MOTIVO	:= TMJ->TMJ_MOTIVO
					M->TMJ_NOMOTI	:= NGSeek( "TMS", TMJ->TMJ_MOTIVO, 1, "TMS_NOMOTI" )
					If Len( AllTrim( TMJ->TMJ_HRCHGD ) ) == 5 //verifica se o campo ja foi preenchido
						M->TMJ_HRCHGD := TMJ->TMJ_HRCHGD
					EndIf
				EndIf
				//---------------------------------------

				Define MsDialog oDlgTMJ Title cCadastro From aSize[ 7 ], 0 To aSize[ 6 ] / 4, aSize[ 5 ] / 2.5 Of oMainWnd Pixel //"Atendimento Médico"

					//Campos que podem ser editados
				aCpos := { "TMJ_HRCHGD" }

					//Campos que não vao ser mostrados no browse
				aNao := { "TMJ_CODUSU", "TMJ_NOMUSU", "TMJ_NUMFIC", "TMJ_NOMFIC", "TMJ_DTCONS", "TMJ_HRCONS", "TMJ_EXAME", "TMJ_NOMEXA",;
						 "TMJ_MOTIVO", "TMJ_NOMOTI", "TMJ_OBSCON", "TMJ_MAT", "TMJ_CONVOC", "TMJ_DTPROG", "TMJ_DTATEN", "TMJ_PCMSO", "TMJ_ATEENF",;
						 "TMJ_CODENF", "TMJ_INDENF", "TMJ_DTENFE", "TMJ_HRENFE", "TMJ_DESENF", "TMJ_QTDHRS", "TMJ_HRSAID"  }

				aChoice  := NGCAMPNSX3( "TMJ", aNao )

				oPnlPai := TPanel():New( 00, 00, , oDlgTMJ, , , , , , 0, 0, .F., .F. )
					oPnlPai:Align   := CONTROL_ALIGN_ALLCLIENT
					oEnchoice:= MsMGet():New( "TMJ", , 3, , , , aChoice, { 0, 0, aSize[ 6 ]/2, aSize[ 5 ]/2 }, aCpos, , , , , oPnlPai )

				If ExistBlock( "Mdta0761" ) // PE para o preenchimento automatico do campo Hora Chegada.
					ExecBlock( "Mdta0761", .F., .F.)
				EndIf

				//Ativacao do Dialog
				ACTIVATE MSDIALOG oDlgTMJ ON INIT EnchoiceBar( oDlgTMJ,;
															 { || nOpca := 1, IIf( NGVALHORA( M->TMJ_HRCHGD, , .T. ), oDlgTMJ:End(), Nil ) },; //Confirmar
															 { || nOpca := 0, oDlgTMJ:End() } ) CENTERED //Cancelar

				If nOpca == 1
					dbSelectArea( "TMJ" )
					dbSetOrder( 1 )
					If dbSeek( xFilial( "TMJ" ) + cMedico + DTOS( dDiaAtu ) + cHora )
						RecLock( "TMJ", .F. )
						TMJ->TMJ_HRCHGD := M->TMJ_HRCHGD
						Msunlock( "TMJ" )
					EndIf
				Else
					Return .F.
				EndIf
			EndIf

			If nRet == 2
				dbSelectArea( cAliasAte )
				dbSetOrder( 3 )
				If dbSeek( cFicha + DtoS( dDiaAtu ) + cHora )
					dbSelectArea( "TMJ" )
					dbSetOrder( 1 )
					If dbSeek( xFilial( "TMJ" ) + ( cAliasAte )->CODUSU + DtoS( ( cAliasAte )->DTCONS ) + ( cAliasAte )->HRCONS )

						//Chama função para ser realizado o Diagnótisco
						//-------------------------------------------------
						MDTA410( cFicha, cMedico )
						//-------------------------------------------------

						//Posiciona na TMT para verificar se já existe Diagnóstico
						dbSelectArea( "TMT" )
						dbSetOrder( 2 )
						If dbSeek( xFilial( "TMT" ) + ( cAliasAte )->CODUSU + DtoS( ( cAliasAte )->DTCONS ) + ( cAliasAte )->HRCONS )

							While !Eof()
								If cFicha == TMT->TMT_NUMFIC
									dDtAten := TMT->TMT_DTATEN
									cHrAten := TMT->TMT_HRATEN
									cDiagno := MsMM( TMT->TMT_DIASYP ) //retorna o valor do campo memo

									//verifica se os campos estao preenchidos
									//para salvar os valores na TMJ
									If !Empty( dDtAten ) .And. Len( AllTrim( cHrAten ) ) == 5
										dbSelectArea( "TMJ" )
										dbSetOrder( 1 )
										If dbSeek( xFilial( "TMJ" ) + ( cAliasAte )->CODUSU + DtoS( ( cAliasAte )->DTCONS ) + ( cAliasAte )->HRCONS )
											RecLock( "TMJ", .F. )
												//caso o campo de diagnóstico for apagado, devera zerar a data de atendimento
											If Empty( cDiagno )
												TMJ->TMJ_DTATEN := CTOD( "  /  /    " )
												TMJ->TMJ_HRSAID := ""
											Else
												TMJ->TMJ_DTATEN := dDtAten
												TMJ->TMJ_HRSAID := cHrAten
											EndIf
											( "TMJ" )->( MsUnLock() )
										EndIf
									EndIf
									Exit
								EndIf
								dbSelectArea( "TMT" )
								( "TMT" )->( dbSkip() )
							End
						EndIf
						//chama fora do Seek da TMT
						//pois pode ser inclusão ou exclusao do atendimento
						//e devera sempre atualizar a tela
						If lAtualTela
							fChangeDay( oCalend, nIdNDate, nPosNDate, oTPanel, oHorario, cAliasAte, .F., "TMJ" )
						Else
							lAtualTela := .T. //recebe verdadeiro para atualizar tela se ñ possuir interferencias
						EndIf

					EndIf
				EndIf
			EndIf
		ElseIf	nRet == 3
			MDT076ATE( cMedico, dDiaAtu, cHora, cAliasAte, oHorario, oCalend, nIdNDate, nPosNDate, oTPanel )
		ElseIf nRet == 4
			Return .F.
		EndIf

	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fRClick
Função do clique da direita

@type function

@source MDTA076.prw

@author Bruno Lobo
@since 10/09/2014

@param x		, Numerico	, Distância horizontal da janela
@param y		, Numerico	, Distância Vertical da janela
@param oPanel   , Objeto	, Objeto do TPaintPanel
@param oCalend  , Objeto	, Objeto do MsCalend
@param nIdNDate , Numerico	, Id da data do calendário
@param nPosNDate, Numerico
@param oTPanel  , Objeto	, Objeto do TPaintPanel
@param oHorario , Objeto	, Objeto do TNGAG
@param cAliasAte, Caracter	, TRB do Atendimento.

@sample fRClick( 80 , 40 , oTNGAG , oCalend , 115 , nPosNDate , oTNGAG , oHorario , cAliasAte )
@return Lógico, Indica se todas validações estão corretas.
/*/
//---------------------------------------------------------------------
Static Function fRClick( x, y, oPanel, oCalend, nIdNDate, nPosNDate, oTPanel, oHorario, cAliasAte )

	Local nIDPos	:= oPanel:GetId()
	Local cHora 	:= oPanel:GetHoraRef( cValToChar( nIDPos ) )
	Local dDiaAtu	:= oCalend:dDiaAtu
	Local lBotInc	:= .T.
	Local lBotExc 	:= .F. //Não deverá ser apresentado o botão de excluir se ñ possuir agendamentos ou reservas/bloqueios
	Local cFicha	:= ""

	//Retorna resolução da tela.
	//-------------------------------------
	Local nLargura 	:= GetScreenRes()[1]
	Local nAltura 	:= GetScreenRes()[2]
	//-------------------------------------

	//Posiciona na tabela para buscar a ficha correta
	dbSelectArea( cAliasAte )
	dbSetOrder( 4 ) //CODUSU+DtoS(DTCONS)+HRCONS
	If dbSeek( cMedico + DtoS( dDiaAtu ) + cHora )
		cFicha	:= ( cAliasAte )->NUMFIC
	EndIf

	//se possuir algum registro posicionado no click da direita
	//não vai apresentar a opção de Incluir
	//-------------------------------------------
	dbSelectArea( "TMJ" )
	dbSetOrder( 1 )
	If dbSeek( xFilial( "TMJ" ) + cMedico + DtoS( dDiaAtu ) +cHora )
		lBotInc := .F.
		lBotExc := .T.
	EndIf
	dbSelectArea( "TY9" )
	dbSetOrder( 1 )
	If dbSeek( xFilial( "TY9" ) + cMedico + DtoS( dDiaAtu ) +cHora )
		lBotInc := .F.
		lBotExc := .T.
	EndIf
	//-------------------------------------------

	//verifica se foi clicado em algum horário valido
	If Len( AllTrim( cHora ) ) == 5
		oMenu := TMenu():New( 0, 0, 0, 0, .T., , oTPanel )
		If lBotInc //botão só sera apresentado se o horario selecionado ñ possuir agendamentos
			oItem := TMenuItem():New( oMenu:Owner(), STR0025, , , .T., { | | MDT076AGE( oPanel, oCalend, nIdNDate, nPosNDate,;
									 oTPanel, oHorario, cAliasAte, cHora, dDiaAtu ) }, , , , , , , , , .T. ) //"Incluir"
			oMenu:Add( oItem )
		EndIf
		If lBotExc //só será apresentado se o horario selecionado possuir algum agendamento
			oItem1 := TMenuItem():New( oMenu:Owner(), STR0026, , , .T., { | | MDT076EXC( oPanel, oCalend, nIdNDate, nPosNDate,;
									 oTPanel, oHorario, cAliasAte ) }, , , , , , , , , .T. ) //"Excluir"
			oMenu:Add( oItem1 )
		EndIf
		If !Empty( cFicha ) //só será apresentado se possuir uma ficha médica no agendamento
			oItem2 := TMenuItem():New( oMenu:Owner(), STR0027, , , .T., { | | NG160MUD( "MDTA076", cFicha, oHorario, oCalend,;
									 nIdNDate, nPosNDate, oTPanel ) }, , , , , , , , , .T. ) //"Transferência"
			oMenu:Add( oItem2 )
		EndIf
	Else
		Return .F.
	EndIf
	//Se for periodo da tarde soma 100 no popup, para o mesmo ñ ficar longe de onde foi clicado
	If nIDPos >= 147
		nIDPos := nIDPos + 100
	EndIf

	oMenu:Activate( x /*Horizontal*/, nIDPos /*Vertical*/, oPanel )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} ChangeMed
Modifica a sequência de médicos a ser apresentada

@type function

@source MDTA076.prw

@author Bruno Lobo
@since 10/09/2014

@param nBtn		, Numerico	, Opção selecionada do botão
@param nId		, Numerico	, Último ID utilizado
@param aMedicos	, Array		, Array dos Médicos
@param nPosMed	, Numerico	, Posição do Médico
@param oTPanel	, Objeto	, Objeto do TPaintPanel
@param nIdNMed	, Numerico	, Id do Médico
@param oHorario	, Objeto	, Objeto do TNGAG
@param oCalend	, Objeto	, Objeto do MsCalend
@param nIdNDate	, Numerico	, Id da data do calendário
@param nPosNDate, Numerico
@param cAliasAte, Caracter	, TRB do Atendimento.
@param [nOrdUsu], Numerico	, Indica a ordem do usuário(1,2,3,4,...).

@sample ChangeMed( 1 , @nId , aMedicos , @nPosMed , oTNGAG , @nIdNMed , oHorario , oCalend , nIdNDate , nPosNDate , cAliasAte, 2 )

@return Nulo, Sempre nulo
/*/
//---------------------------------------------------------------------
Function ChangeMed( nBtn, nId, aMedicos, nPosMed, oTPanel, nIdNMed, oHorario, oCalend, nIdNDate, nPosNDate, cAliasAte, nOrdUsu )

	Local aMed
	Local lAtu		:= .T.
	Local nTop 		:= 52
	Local nHei 		:= nTop + 50
	Local nLeftTxt
	Local nMed
	Local nIdMed

	Default nOrdUsu := 0

	If nBtn == 1 .Or. nBtn == 2
		If nBtn == 1
			If nPosMed == 1
				Alert( STR0028 ) //"Não há registros anteriores."
				lAtu := .F.
			Else
				nPosMed--
			EndIf
		ElseIf nBtn == 2
			If nPosMed + 1 > Len( aMedicos )
				Alert( STR0029 ) //"Não há registros posteriores."
				lAtu := .F.
			Else
				nPosMed++
			EndIf
		EndIf
		aMed := aMedicos[ nPosMed ]
	ElseIf nBtn == 0
		If nOrdUsu > 0
			aMed := aMedicos[ nOrdUsu ]
			nPosMed := nOrdUsu
		Else
			aMed := aMedicos[ 1 ]
			nPosMed := 1
		EndIf
	EndIf

	cMedico := aMed[ 1 ]
	cCalend := aMed[ 3 ]

	If lAtu
		nLeftTxt:= 28
		nWidth	:= oTPanel:nClientWidth

		If nIdNMed == 0
			nIdNMed := Val( SumId( @nId ) )
		Else
			oTPanel:DeleteItem( nIdNMed )
		EndIf

		nIdMed := cValToChar( nIdNMed )

		oTPanel:addShape( "id=" + nIdMed + ";type=7;" +;
						 "left=" + cValToChar( nLeftTxt ) + ";top=" + cValToChar( nTop + 17 ) + ";width=" +;
						  cValToChar( nWidth ) + ";height=" + cValToChar( nHei ) + ";" + "font=arial,12,0,0,3;text="+;
						  Alltrim( aMed[ 2 ] ) + ";pen-color=#434657;pen-width=2;" + "gradient=1,0,0,0,0,0,#FFFFFF;" )

		If nBtn == 1 .Or. nBtn == 2
			fChangeDay( oCalend, nIdNDate, nPosNDate, oTPanel, oHorario, cAliasAte )
		EndIf

	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fChangeDay
Executa a inclusão dos atendimentos iniciais

@type function

@source MDTA076.prw

@author Bruno Lobo
@since 10/09/2014

@param oCalend		, Objeto	, Objeto do MsCalend
@param nIdNDate		, Numerico	, Id da data do calendário
@param nPosNDate	, Numerico
@param oTPanel		, Objeto	, Objeto do TPaintPanel
@param oHorario		, Objeto	, Objeto do TNGAG
@param cAliasAte	, Caracter	, TRB do Atendimento.
@param [lEntRot]	, Logico	, Indica se esta realizando a abertura da rotina .T., ou .F. quando esta
chamando a função para atualizar a tela.
@param [cAliasTab]	, Caracter	, Indica o Alias para atualizar o TRB.

@sample fChangeDay( oCalend , 445 , nPosNDate , oTNGAG , oHorario , cAliasAte, .F., "TMJ" )

@return Nulo, Sempre nulo
/*/
//---------------------------------------------------------------------
Function fChangeDay( oCalend, nIdNDate, nPosNDate, oTPanel, oHorario, cAliasAte, lEntRot, cAliasTab )

	Local cHrSrc
	Local cAliasSrc 	:= ""
	Local cPrefixMem	:= "M->" + PrefixoCPO( cAliasTab )
	Local cObsAge		:= ""
	Local dDiaAtu 		:= oCalend:dDiaAtu
	Local nHora, nMinuto
	Local nCntShp
	Local nQtdShp
	Local nPosicShp
	Local nDiag 		:= 0
	Local nOpcX
	Local cGradient 	:= ""

	Default lEntRot := .T.
	Default cAliasTab := ""

	If lEntRot
		//Cria o Painel Superior mostrando o Mês e Ano
		oTPanel:DeleteItem( nIdNDate )

		oTPanel:addShape( "id=" + cValToChar( nIdNDate ) + ";type=7;" + ;
						 "left=0;top=17;width=" + cValToChar( nPosNDate ) + ";height=50;" + "font=arial,12,0,0,3;text=" +;
						 MesExtenso( dDiaAtu ) + " " + StrZero( Year( dDiaAtu ), 4 ) + ";pen-color=#434657;pen-width=2;" +;
						 "gradient=1,0,0,0,0,0,#434657;" )

	Else
		//se for inclusao devera adicionar no TRB
		//devera verificar se o campo esta preenchido
		//pois ao atender e voltar vem com os campos vazios
		If !Empty( &( cPrefixMem + "_DTCONS" ) )
			dbSelectArea( cAliasAte )
			dbSetOrder( 4 )
			If !dbSeek( &( cPrefixMem + "_CODUSU" ) + DtoS( &( cPrefixMem + "_DTCONS" ) ) + &( cPrefixMem + "_HRCONS" ) )
				RecLock( cAliasAte, .T. )
				( cAliasAte )->CODUSU := &( cPrefixMem + "_CODUSU" )
				( cAliasAte )->DTCONS := &( cPrefixMem + "_DTCONS" )
				( cAliasAte )->HRCONS := &( cPrefixMem + "_HRCONS" )
				If cAliasTab == "TMJ"
					( cAliasAte )->NUMFIC	:= M->TMJ_NUMFIC
					( cAliasAte )->MAT	 	:= M->TMJ_MAT
				EndIf
				( cAliasAte )->( MsUnLock() )
			EndIf
		EndIf
		//Define as cores corretas para cada opção
		If cAliasTab == "TMJ"
			If dDataBase < ( cAliasAte )->DTCONS .Or. ( dDataBase == ( cAliasAte )->DTCONS .And. Time() <= ( cAliasAte )->HRCONS )
				cGradient := "1,0,0,0,0,0,#67cf67"
			Else
				cGradient := "1,0,0,0,0,0,#e84848"
			EndIf
		Else //TY9
			If	M->TY9_TIPOAG == "1"
				cGradient := "1,0,0,0,0,0,#f7e6cb"
			Else //se for bloqueio
				cGradient := "1,0,0,0,0,0,#a6a5a4"
			EndIf
		EndIf

	EndIf
	//Zera os valores do Shap, retirando as cores
	MsgRun( STR0132 + "...", STR0133, { | | oHorario:DelBox() } ) //"Processando atendimentos" # "Aguarde"

	//Atualiza horarios do periodo para dias diferentes
	//-----------------------------------
	aTurnos := MDT076TUR( dDiaAtu )
	oHorario:CriateScr( aTurnos )
	//-----------------------------------

	aHrTrab := NGCALENDAH( cCalend )
	If SuperGetMV( "MV_NG2HRAG", .F., "1" ) == "1" // Indica se marcará em cinza os horários fora do atendimento dos médicos 1 = Sim, 2 = Não
		//Realiza a tratativa dos Horários conforme a Agenda
		For nHora := 0 To 23//Percorre todos os horários
			For nMinuto := 0 To 11//Percorre todos os minutos
				//Monta a hora a ser buscada
				cHrVld := StrZero( nHora, 2 ) + ":" + StrZero( nMinuto * 5, 2 )
				nIdHr := oHorario:GetIdHora( cHrVld )

				//Valida se o horário é um horário válido para o médico
				If aScan( aHrTrab[Dow( dDiaAtu ), 2], { | x | cHrVld >= x[ 1 ] .And. cHrVld < x[ 2 ] } ) == 0
					oHorario:SetGradShp( nIdHr, "1,0,0,0,0,0,#a6a5a4" )
				EndIf
			Next
		Next
	EndIf

	// Adiciona os Atendimentos na Tela da Agenda
	fGetAtend( cAliasAte, aTRBAte, cMedico, dDiaAtu )
	dbSelectArea( cAliasAte )
	dbSetOrder( 4 )
	dbGoTop()

	While ( cAliasAte )->( !Eof() )

		// verifica se encontra algum diagnóstico para ficha selecionada
		lReg := .F. //verifica se possui registro na TMT

		dbSelectArea( "TMT" )
		dbSetOrder( 2 ) //TMT_FILIAL+TMT_CODUSU+DTOS(TMT_DTCONS)+TMT_HRCONS
		If dbSeek( xFilial( "TMT" ) + ( cAliasAte )->CODUSU + DTOS( ( cAliasAte )->DTCONS ) +  ( cAliasAte )->HRCONS )
			//necessário verificar pois poderá ter mais diagnósticos no mesmo horario de fichas diferentes
			While !Eof()
				If ( cAliasAte )->NUMFIC == TMT->TMT_NUMFIC
					If Empty( MsMM( TMT->TMT_DIASYP ) )//Parcialmente atendido
						If Len( AllTrim( TMT->TMT_HRRETO ) ) == 5 //Retorno ao Atendimento
							lReg := .T.
							nDiag := 1
						Else //Parcialmente Atendido
							lReg := .T.
							nDiag := 2
						EndIf
					Else //Atendido
						lReg := .T.
						nDiag := 3
					EndIf
					Exit
				EndIf
				dbSelectArea( "TMT" )
				( "TMT" )->( dbSkip() )
			End
		EndIf

		If lReg
			If nDiag == 1 //Retorno ao Atendimento
				cGradient := "1,0,0,0,0,0,#f2e56f"
			ElseIf nDiag == 2 //Parcialmente Atendido
				cGradient := "1,0,0,0,0,0,#edb48c"
			ElseIf nDiag == 3 //Atendido
				cGradient := "1,0,0,0,0,0,#6790d6"
			EndIf
			cAliasSrc := "TMJ"
		Else

			If !Empty( ( cAliasAte )->NUMFIC )
				If dDataBase < ( cAliasAte )->DTCONS .Or. ( dDataBase == ( cAliasAte )->DTCONS .And. Time() <= ( cAliasAte )->HRCONS )
					cGradient := "1,0,0,0,0,0,#67cf67"
				Else
					cGradient := "1,0,0,0,0,0,#e84848"
				EndIf
				cAliasSrc := "TMJ"
			Else
				dbSelectArea( "TY9" )
				dbSetOrder( 1 )
				If dbSeek( xFilial( "TY9" ) + cMedico + DTOS( ( cAliasAte )->DTCONS ) + ( cAliasAte )->HRCONS )
					If	TY9->TY9_TIPOAG == "1"
						cGradient := "1,0,0,0,0,0,#f7e6cb"
					Else //se for bloqueio
						cGradient := "1,0,0,0,0,0,#a6a5a4"
					EndIf
				EndIf
				cAliasSrc := "TY9"
			EndIf
		EndIf

		cHrSrc := ( cAliasAte )->HRCONS
		nIdHr := oHorario:GetIdHora( cHrSrc )
		cLeftShp := oHorario:GetLeft( cValToChar( nIdHr ) )
		nQtdShp := MDT076SHP( cMedico, dDiaAtu, cHrSrc, nOpcX, cAliasSrc ) //Chama função para verificar quantidade correta de shapes
		nTmpWidt := 0
		nTmpId := nIdHr
		nTmpId2:= nIdHr
		nPosicShp := ( Val( SubStr( cHrSrc, At( ":", cHrSrc ) + 1 ) ) / 5 ) + 1
		If nPosicShp + nQtdShp > 12
			lFirst := .T.
			nQtdLin := 1
			nStart := nPosicShp
			nFinish := 12
			nDiff := nQtdShp - ( ( nFinish - nStart ) + 1 )
			While nDiff >= 0
				For nCntShp := nStart To nFinish
					If !lFirst
						cHrSrc := SubStr( IncTime( cHrSrc, 0, 5 /*tempo minimo da consulta*/ ), 1, 5 )
					Else
						lFirst := .F.
					EndIf

					nIdHr := oHorario:GetIdHora( cHrSrc )

					If nCntShp == 1
						nTmpId2 := nIdHr
					EndIf
					If nQtdLin > 1 .And. nCntShp == 1
						cLeftShp := oHorario:GetLeft( cValToChar( nIdHr ) )
					EndIf

					nTmpWidt += Val( oHorario:GetWidth( cValToChar( nIdHr ) ) )
				Next nCntShp

				nIdHr := nTmpId2
				cWidthShp := cValToChar( nTmpWidt )

				oHorario:SetGradShp( nIdHr, cGradient, cLeftShp, cWidthShp, , IIf( nIdHr == nTmpId, nTmpId, nTmpId2 ), nTmpId )
				If cAliasSrc == "TMJ"
					//cFicha	:= AllTrim( oHorario:GetText( cValToChar( nTmpId ) ) )
					cNomPac	:= NGSeek( "TM0", ( cAliasAte )->NUMFIC, 1, "TM0_NOMFIC" )
					cHora 	:= oHorario:GetHora( cValToChar( nTmpId ) )
					fBalaoAjd( nIdHr, cNomPac, cHora, cAliasSrc, oHorario )

				Else
					dbSelectArea( "TY9" )
					dbSetOrder( 1 )
					If dbSeek( xFilial( "TY9" ) + cMedico + DTOS( ( cAliasAte )->DTCONS ) + ( cAliasAte )->HRCONS )
						cObsAge := TY9->TY9_OBSCON
					EndIf
					cHora 	:= oHorario:GetHora( cValToChar( nTmpId ) )
					fBalaoAjd( nIdHr, cObsAge, cHora, cAliasSrc, oHorario )

				EndIf

				nTmpWidt := 0
				nQtdLin++
				If nDiff == 0
					Exit
				Else
					nStart := 1
					nFinish := IIf( nDiff > 12, 12, nDiff )
					nDiff := nDiff - ( ( nFinish - nStart ) + 1 )
				EndIf
			End
		Else
			For nCntShp := 1 To nQtdShp
				If nCntShp != 1
					cHrSrc := IncTime( cHrSrc, 0, 5 /*tempo minimo da consulta*/ )
				EndIf

				nIdHr := oHorario:GetIdHora( cHrSrc )

				nTmpWidt += Val( oHorario:GetWidth( cValToChar( nIdHr ) ) )
			Next nCntShp
			nIdHr := nTmpId
			cWidthShp := cValToChar( nTmpWidt )

			oHorario:SetGradShp( nIdHr, cGradient, cLeftShp, cWidthShp )

			If cAliasSrc == "TMJ"
				//cFicha	:= AllTrim( oHorario:GetText( cValToChar( nIdHr ) ) )
				cNomPac	:= NGSeek( "TM0", ( cAliasAte )->NUMFIC, 1, "TM0_NOMFIC" )
				cHora 	:= oHorario:GetHora( cValToChar( nIdHr ) )
				fBalaoAjd( nIdHr, cNomPac, cHora, cAliasSrc, oHorario )

			Else
				dbSelectArea( "TY9" )
				dbSetOrder( 1 )
				If dbSeek( xFilial( "TY9" ) + cMedico + DTOS( ( cAliasAte )->DTCONS ) + ( cAliasAte )->HRCONS )
					cObsAge := TY9->TY9_OBSCON
				EndIf
				cHora 	:= oHorario:GetHora( cValToChar( nIdHr ) )
				fBalaoAjd( nIdHr, cObsAge, cHora, cAliasSrc, oHorario )
			EndIf
		EndIf
    //Deslocado para que não seja sobreposto.
    oHorario:SetDescriShp( nIdHr, AllTrim( SubStr( NGSEEK( "TM0", ( cAliasAte )->NUMFIC, 1, "TM0_NOMFIC" ), 1, 10 ) ), cHrSrc )

	dbSelectArea( cAliasAte )
	( cAliasAte )->( dbSkip() )
	End
	//Atualiza o calendario quando estiver 100% ou 90%
	//-------------------------------------------------------
	fChangeMonth( oCalend, nIdNDate, nPosNDate, oTPanel, oTNGAG, cAliasAte )
	oCalend:CtrlRefresh()
	//-------------------------------------------------------

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fChangeMonth
Executa a inclusão do meses no calendário

@type function

@source MDTA076.prw

@author Bruno Lobo
@since 10/09/2014

@param oCalend	, Objeto	, Objeto do MsCalend
@param nIdNDate	, Numerico	, Id da data do calendário
@param nPosNDate, Numerico
@param oTPanel	, Objeto	, Objeto do TPaintPanel
@param oHorario	, Objeto	, Objeto do TNGAG
@param cAliasAte, Caracter	, TRB do Atendimento.

@sample fChangeMonth( oCalend , 114 , nPosNDate , oTNGAG , oHorario , cAliasAte )

@return Nulo, Sempre nulo
/*/
//---------------------------------------------------------------------
Static Function fChangeMonth( oCalend, nIdNDate, nPosNDate, oTPanel, oHorario, cAliasAte )

	fChgColDay( oCalend, cAliasAte )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fAgPnlBtn
Monta o painel de botões laterais

@type function

@source MDTA076.prw

@author Bruno Lobo
@since 10/09/2014

@param oPnlBtn	, Objeto	, Objeto do TPanel
@param oDlg		, Objeto	, Objeto no qual os botoes iram ser criados
@param aMedicos	, Array		, Array dos Médicos
@param oTPanel	, Objeto	, Objeto do TPaintPanel
@param oHorario	, Objeto	, Objeto do TNGAG
@param oCalend	, Objeto	, Objeto do MsCalend
@param cAliasAte, Caracter	, TRB do Atendimento.
@param nIdNDate	, Numerico	, Id da data do calendário
@param nPosNDate, Numerico
@param cAliasMed, Caracter	, Alias do Médico(TRB).
@param nIdNMed	, Numerico	, Id do Médico
@param nPosMed	, Numerico	, Posição do Médico
@param nId		, Numerico	, Último ID utilizado

@sample fAgPnlBtn( oPnlBtn, oDlg, aMedicos, oTNGAG, oTNGAG, oCalend, cAliasAte, 12, nPosNDate, cAliasMed , @nIdNMed , @nPosMed , @nId )

@return Nulo, Sempre nulo
/*/
//---------------------------------------------------------------------
Static Function fAgPnlBtn( oPnlBtn, oDlg, aMedicos, oTPanel, oHorario, oCalend, cAliasAte, nIdNDate, nPosNDate, cAliasMed, nIdNMed, nPosMed, nId )

	Local nBtn
	Local nTop		:= 02
	Local aButtons 	:= {	;
						 { "ng_ico_incMed", { || MDT076MED( 3, .T., aMedicos, oTPanel, oHorario, oCalend, cAliasAte, nIdNDate, nPosNDate, cAliasMed, @nIdNMed, @nPosMed, @nId ) }, STR0050 },; //"Incluir Médico"
						 { "icone_mdt_01", { || MDT076MED( 4, .T., aMedicos, oTPanel, oHorario, oCalend, cAliasAte, nIdNDate, nPosNDate, cAliasMed, @nIdNMed, @nPosMed, @nId ) }, STR0052 },; //"Alterar Médico"
						 { "ng_ico_excMed", { || MDT076MED( 5, .T., aMedicos, oTPanel, oHorario, oCalend, cAliasAte, nIdNDate, nPosNDate, cAliasMed, @nIdNMed, @nPosMed, @nId, oDlg ) }, STR0051 },; //"Excluir Médico"
						 { "ng_ico_localizar", { || MDT076BUS( oHorario, oCalend, cAliasAte, nIdNDate, nPosNDate, aMedicos, oTPanel, @nIdNMed, @nPosMed, @nId ) }, STR0053 },; //"Buscar Médico"
						 { "agenda_inserir", { || MDT076QTD( 3, aMedicos, oTPanel, oHorario, oCalend, cAliasAte, nIdNDate, nPosNDate, cAliasMed, @nIdNMed, @nPosMed, @nId ) }, STR0118 },; //"Incluir Agenda"
						 { "agenda_editar", { || MDT076QTD( 4, aMedicos, oTPanel, oHorario, oCalend, cAliasAte, nIdNDate, nPosNDate, cAliasMed, @nIdNMed, @nPosMed, @nId ) }, STR0120 },; //"Alterar Agenda""
						 { "agenda_excluir", { || MDT076QTD( 5, aMedicos, oTPanel, oHorario, oCalend, cAliasAte, nIdNDate, nPosNDate, cAliasMed, @nIdNMed, @nPosMed, @nId, oDlg ) }, STR0119 },; //"Excluir Agenda"
						 { "ng_ico_resHora", { || MDT076RES( oHorario, oCalend, nIdNDate, nPosNDate, oTPanel, oHorario, cAliasAte, "1", , , .F. ) }, STR0054 },; //"Reservar horário"
						 { "ng_ico_bloqHora", { || MDT076RES( oHorario, oCalend, nIdNDate, nPosNDate, oTPanel, oHorario, cAliasAte, "2", , , .F. ) }, STR0055 },; //"Bloquear horário"
						 { "NG_ICO_IMP", { || MDTR755() }, STR0056 },;//"Imprimir Agenda"
						 { "ng_ico_final", { || oDlg:End() }, STR0057 };//"Sair"
						 }

	For nBtn := 1 To Len( aButtons )
		TBtnBmp2():New( nTop, 02, 26, 26, aButtons[ nBtn, 1 ], , , , aButtons[ nBtn, 2 ], oPnlBtn, aButtons[ nBtn, 3 ], , .T. )
		nTop += 28
	Next nBtn

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fAgPnlLeg
Monta legenda do agendamento

@type function

@source MDTA076.prw

@author Bruno Lobo
@since 10/09/2014

@param oPnlLeg, Objeto, Objeto do TPanel


@sample fAgPnlLeg( @oPnlLeg )

@return Nulo, Sempre nulo
/*/
//---------------------------------------------------------------------
Static Function fAgPnlLeg( oPnlLeg )

	Local oBmp, oSay

	oSay := TSay():New( 5, 015, { || STR0030 }, oPnlLeg, , , , , , .T., , , 200, 10 ) //"Legenda: "

	oBmp := TBitmap():New( 3, 043, 20, 10, "ico_calend_green", , .T., oPnlLeg, , , .F., .F., , , .F., , .T., , .F. )
	oBmp:lAutoSize := .T.
	oSay := TSay():New( 5, 055, { || STR0031 }, oPnlLeg, , , , , , .T., , , 200, 10 ) //"Disponível"

	oBmp := TBitmap():New( 3, 088, 20, 10, "ico_calend_yellow", , .T., oPnlLeg, , , .F., .F., , , .F., , .T., , .F. )
	oBmp:lAutoSize := .T.
	oSay := TSay():New( 5, 100, { || STR0032 }, oPnlLeg, , , , , , .T., , , 200, 10 ) //"90% Ocupado"

	oBmp := TBitmap():New( 3, 143, 20, 10, "ico_calend_red", , .T., oPnlLeg, , , .F., .F., , , .F., , .T., , .F. )
	oBmp:lAutoSize := .T.
	oSay := TSay():New( 5, 155, { || STR0033 }, oPnlLeg, , , , , , .T., , , 200, 10 ) //"100% Ocupado"

	oBmp := TBitmap():New( 5, 211, 20, 10, "atendido_ico", , .T., oPnlLeg, , , .F., .F., , , .F., , .T., , .F. )
	oBmp:lAutoSize := .T.
	oSay := TSay():New( 5, 225, { || STR0034 }, oPnlLeg, , , , , , .T., , , 200, 10 ) //"Atendido"

	oBmp := TBitmap():New( 5, 251, 20, 10, "naoatendido_ico", , .T., oPnlLeg, , , .F., .F., , , .F., , .T., , .F. )
	oBmp:lAutoSize := .T.
	oSay := TSay():New( 5, 265, { || STR0035 }, oPnlLeg, , , , , , .T., , , 200, 10 ) //"Não Atendido"

	oBmp := TBitmap():New( 5, 301, 20, 10, "AtendParc_ico", , .T., oPnlLeg, , , .F., .F., , , .F., , .T., , .F. )
	oBmp:lAutoSize := .T.
	oSay := TSay():New( 5, 315, { || STR0036 }, oPnlLeg, , , , , , .T., , , 200, 10 ) //"Atendido Parcialmente"

	oBmp := TBitmap():New( 5, 376, 20, 10, "RetMed_ico", , .T., oPnlLeg, , , .F., .F., , , .F., , .T., , .F. )
	oBmp:lAutoSize := .T.
	oSay := TSay():New( 5, 390, { || STR0037 }, oPnlLeg, , , , , , .T., , , 200, 10 ) //"Retorno ao Atendimento"

	oBmp := TBitmap():New( 5, 451, 20, 10, "agendado_ico", , .T., oPnlLeg, , , .F., .F., , , .F., , .T., , .F. )
	oBmp:lAutoSize := .T.
	oSay := TSay():New( 5, 465, { || STR0038 }, oPnlLeg, , , , , , .T., , , 200, 10 ) //"Agendado"

	oBmp := TBitmap():New( 5, 496, 20, 10, "bloqueio_ico", , .T., oPnlLeg, , , .F., .F., , , .F., , .T., , .F. )
	oBmp:lAutoSize := .T.
	oSay := TSay():New( 5, 510, { || STR0039 }, oPnlLeg, , , , , , .T., , , 200, 10 ) //"Bloqueado"

	oBmp := TBitmap():New( 5, 541, 20, 10, "reserva_ico", , .T., oPnlLeg, , , .F., .F., , , .F., , .T., , .F. )
	oBmp:lAutoSize := .T.
	oSay := TSay():New( 5, 555, { || STR0040 }, oPnlLeg, , , , , , .T., , , 200, 10 ) //"Reservado"

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fCreateTRB
Busca os valores para montar a agenda médica

@type function

@source MDTA076.prw

@author Bruno Lobo
@since 10/09/2014

@param cAliasMed, Caracter, Alias do Médico(TRB).
@param cAliasCal, Caracter, Alias do Calendário(TRB).

@sample fCreateTRB( @cAliasMed , @cAliasAte, @cAliasCal )

@return Nulo, Sempre nulo
/*/
//---------------------------------------------------------------------
Static Function fCreateTRB( cAliasMed, cAliasCal )

	Local aTRBMed 	:= {}
	Local aTRBFIC 	:= {}
	Local aTRBCAL 	:= {}
	Local aTRBRes	:= {}

	//---------------------------
	// Criação TRB Médicos
	//---------------------------
	aAdd( aTRBMed, { "CODUSU", "C", 12, 0 } )
	aAdd( aTRBMed, { "NOMUSU", "C", 40, 0 } )
	aAdd( aTRBMed, { "CALEND", "C", 03, 0 } )
	aAdd( aTRBMed, { "DTINIC", "D", 08, 0 } )
	aAdd( aTRBMed, { "DTTERM", "D", 08, 0 } )

	cAliasMed	:= GetNextAlias()
	oTempMed := FWTemporaryTable():New( cAliasMed, aTRBMed )
	oTempMed:AddIndex( "1", {"CODUSU"} )
	oTempMed:Create()

	//---------------------------
	// Criação TRB Atendimentos
	//---------------------------
	aAdd( aTRBAte, { "CODUSU", "C", 12, 0 } )
	aAdd( aTRBAte, { "NOMUSU", "C", 40, 0 } )
	aAdd( aTRBAte, { "CALEND", "C", 03, 0 } )
	aAdd( aTRBAte, { "DTCONS", "D", 08, 0 } )
	aAdd( aTRBAte, { "HRCONS", "C", 05, 0 } )
	aAdd( aTRBAte, { "NUMFIC", "C", 09, 0 } )
	aAdd( aTRBAte, { "DTATEN", "D", 08, 0 } )
	aAdd( aTRBAte, { "MAT", "C", 06, 0 } )

	cAliasAte	:= GetNextAlias()
	oTempAte := FWTemporaryTable():New( cAliasAte, aTRBAte )
	oTempAte:AddIndex( "1", { "CODUSU" } )
	oTempAte:AddIndex( "2", { "DTCONS", "HRCONS" } )
	oTempAte:AddIndex( "3", { "NUMFIC", "DTCONS", "HRCONS" } )
	oTempAte:AddIndex( "4", { "CODUSU", "DTCONS", "HRCONS" } )
	oTempAte:Create()

	//---------------------------
	// Criação TRB Calendário
	//---------------------------
	aAdd( aTRBCAL, { "DAY", "C", 02, 0 } )
	aAdd( aTRBCAL, { "QTD", "N", 20, 0 } )

	cAliasCal	:= GetNextAlias()
	oTempCal := FWTemporaryTable():New( cAliasCal, aTRBCAL )
	oTempCal:AddIndex( "1", { "DAY" } )
	oTempCal:Create()

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetAgenda
Busca os valores para montar a agenda médica

@type function

@source MDTA076.prw

@author Bruno Lobo
@since 10/09/2014

@param cAliasMed, Caracter	, Alias do Médico(TRB).
@param aMedicos	, Array		, Array dos Médicos

@sample fGetAgenda( cAliasMed , @aMedicos )

@return Nulo, Sempre nulo
/*/
//---------------------------------------------------------------------
Function fGetAgenda( cAliasMed, aMedicos )

	Local cQryMed		:= ""
	Local cCodusu		:= ""
	Local cAliQryMed	:= GetNextAlias()
	Local dDataAtu      := dDataBase

	//---------------------------
	// Query Medicos
	//---------------------------
	cQryMed := "SELECT TMK.TMK_CODUSU, TMK.TMK_NOMUSU, TML.TML_CALEND, TMK.TMK_DTINIC, TMK.TMK_DTTERM, TMK.TMK_USUARI "
	cQryMed += "FROM " + RetSqlName( "TMK" ) + " TMK "
	cQryMed += "INNER JOIN " + RetSqlName( "TML" ) + " TML ON "
	cQryMed += 		"TML.TML_CODUSU = TMK.TMK_CODUSU "
	cQryMed += "JOIN " + RetSqlName( "SH7" ) + " SH7 ON "
	cQryMed +=      "SH7.H7_FILIAL = '" + xFilial( "SH7" ) + "' "
	cQryMed +=      "AND TML.TML_CALEND = SH7.H7_CODIGO "
	cQryMed += 		"AND SH7.D_E_L_E_T_ != '*' "
	cQryMed += "WHERE "
	cQryMed += 		"TMK.TMK_FILIAL = '" + xFilial( "TMK" ) + "' "
	cQryMed += 		"AND ( TMK.TMK_DTTERM = ' ' OR TMK.TMK_DTTERM >= " + ValToSql( dDataAtu ) + ') '
	cQryMed += 		"AND TMK.D_E_L_E_T_ != '*' "
	cQryMed += 		"AND TML.TML_FILIAL = '" + xFilial( "TML" ) + "' "
	cQryMed += 		"AND TML.D_E_L_E_T_ != '*' "
	If SuperGetMV( "MV_NG2SEG", .F., "2" ) == "1"
		cQryMed += " AND TMK.TMK_USUARI = " + ValToSQL( cUserName )
	EndIf
	cQryMed += "GROUP BY TMK.TMK_CODUSU, TMK.TMK_NOMUSU, TML.TML_CALEND, TMK.TMK_DTINIC, TMK.TMK_DTTERM, TMK.TMK_USUARI "
	cQryMed := ChangeQuery( cQryMed )

	MPSysOpenQuery( cQryMed, cAliQryMed )

	dbSelectArea( cAliQryMed )
	( cAliQryMed )->( dbGoTop() )
	While ( cAliQryMed )->( !Eof() )
		dbSelectArea( cAliasMed )
		RecLock( cAliasMed, .T. )
			( cAliasMed )->CODUSU := ( cAliQryMed )->TMK_CODUSU
			( cAliasMed )->NOMUSU := ( cAliQryMed )->TMK_NOMUSU
			( cAliasMed )->CALEND := ( cAliQryMed )->TML_CALEND
			( cAliasMed )->DTINIC := StoD( ( cAliQryMed )->TMK_DTINIC )
			( cAliasMed )->DTTERM := StoD( ( cAliQryMed )->TMK_DTTERM )
		( cAliasMed )->( MsUnLock() )
		If ( cAliasMed )->CODUSU != cCodusu .And. ( Empty( ( cAliQryMed )->TMK_DTTERM ) .Or. SToD( ( cAliQryMed )->TMK_DTTERM ) >= dDataBase )
			aAdd( aMedicos, { ( cAliasMed )->CODUSU, ( cAliasMed )->NOMUSU, ( cAliasMed )->CALEND } )
		EndIf
		cCodusu := ( cAliQryMed )->TMK_CODUSU
		( cAliQryMed )->( dbSkip() )
	End
	( cAliQryMed )->( dbCloseArea() )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetAtend
Busca os valores para montar os atendimentos da agenda

@type function

@source MDTA076.prw

@author Bruno Lobo
@since 10/09/2014

@param cAliasAte, Caracter, TRB do Atendimento.
@param aTRBAte,   Array,    Array com a estrutura do TRB de atendimentos

@sample fGetAtend( cAliasAte )

@return Nulo, Sempre nulo
/*/
//---------------------------------------------------------------------
Static Function fGetAtend( cAliasAte, aTRBAte, cCodMed, dDtCons )

	Local cQryAte		:= ""
	Local cQryFic		:= ""
	Local cAliQryFic	:= GetNextAlias()

	dbSelectArea( cAliasAte )
	( cAliasAte )->( dbGoTop() )
	While ( cAliasAte )->( !Eof() )
		( cAliasAte )->( dbDelete() )
		( cAliasAte )->( dbSkip() )
	End

	//---------------------------
	// Query Atendimentos
	//---------------------------
	cQryAte := "SELECT TMK.TMK_CODUSU CODUSU, TMK.TMK_NOMUSU NOMUSU, TML.TML_CALEND CALEND, TMK.TMK_DTINIC, TMK.TMK_DTTERM, "
	cQryAte += "TMJ.TMJ_DTCONS DTCONS, TMJ.TMJ_HRCONS HRCONS, TMJ.TMJ_DTATEN DTATEN, TMJ.TMJ_NUMFIC NUMFIC, TMJ.TMJ_MAT MAT "
	cQryAte += "FROM " + RetSqlName( "TMK" ) + " TMK "
	cQryAte += 	"INNER JOIN " + RetSqlName( "TMJ" ) + " TMJ ON "
	cQryAte += 		"TMJ.TMJ_CODUSU = TMK.TMK_CODUSU "
	cQryAte += 	"INNER JOIN " + RetSqlName( "TML" ) + " TML ON "
	cQryAte += 		"TML.TML_CODUSU = TMK.TMK_CODUSU "
	cQryAte += "WHERE "
	cQryAte += 		"TMK.TMK_FILIAL = " + ValToSQL( xFilial( "TMK" ) )
	cQryAte += 		" AND TMK.D_E_L_E_T_ <> '*'"
	cQryAte += 		" AND TMJ.TMJ_FILIAL = " + ValToSQL( xFilial( "TMJ" ) )
	cQryAte += 		" AND TMJ.TMJ_NUMFIC <> " + ValToSQL( Space( Len( TMJ->TMJ_NUMFIC ) ) )
	cQryAte += 		" AND TMJ.TMJ_CODUSU = " + ValToSQL( cCodMed )
	cQryAte += 		" AND TMJ.TMJ_DTCONS = " + ValToSQL( dDtCons )
	cQryAte += 		" AND TMJ.D_E_L_E_T_ <> '*'"
	cQryAte += "GROUP BY TMK.TMK_CODUSU, TMK.TMK_NOMUSU, TML.TML_CALEND, TMK.TMK_DTINIC, TMK.TMK_DTTERM, "
	cQryAte += "TMJ.TMJ_DTCONS, TMJ.TMJ_HRCONS, TMJ.TMJ_DTATEN, TMJ.TMJ_NUMFIC, TMJ.TMJ_MAT"

	cQryAte += " UNION "

	//---------------------------
	// Query Reserva e Bloqueio
	//---------------------------
	cQryAte += "SELECT TMK.TMK_CODUSU CODUSU, TMK.TMK_NOMUSU NOMUSU, TML.TML_CALEND CALEND, TMK.TMK_DTINIC, TMK.TMK_DTTERM, "
	cQryAte += "TY9.TY9_DTCONS DTCONS, TY9.TY9_HRCONS HRCONS, '' DTATEN, '' NUMFIC, '' MAT "
	cQryAte += "FROM " + RetSqlName( "TMK" ) + " TMK "
	cQryAte += 	"INNER JOIN " + RetSqlName( "TY9" ) + " TY9 ON "
	cQryAte += 		"TY9.TY9_CODUSU = TMK.TMK_CODUSU "
	cQryAte += 	"INNER JOIN " + RetSqlName( "TML" ) + " TML ON "
	cQryAte += 		"TML.TML_CODUSU = TMK.TMK_CODUSU "
	cQryAte += "WHERE "
	cQryAte += 		"TMK.TMK_FILIAL = " + ValToSQL( xFilial( "TMK" ) )
	cQryAte += 		" AND TMK.D_E_L_E_T_ <> '*' "
	cQryAte += 		" AND TY9.TY9_FILIAL = " + ValToSQL( xFilial( "TY9" ) )
	cQryAte += 		" AND TY9.TY9_CODUSU = " + ValToSQL( cCodMed )
	cQryAte += 		" AND TY9.TY9_DTCONS = " + ValToSQL( dDtCons )
	cQryAte += 		" AND TY9.D_E_L_E_T_ <> '*'"
	cQryAte += "GROUP BY TMK.TMK_CODUSU, TMK.TMK_NOMUSU, TML.TML_CALEND, TMK.TMK_DTINIC, TMK.TMK_DTTERM, "
	cQryAte += "TY9.TY9_DTCONS, TY9.TY9_HRCONS"
	cQryAte := ChangeQuery( cQryAte )

	SqlToTrb( cQryAte, aTRBAte, cAliasAte )

	//---------------------------
	// Query Fichas Médicas
	//---------------------------
	cQryFic := "SELECT TM0.TM0_NUMFIC,TM0.TM0_NOMFIC,TM0.TM0_RG,TM0.TM0_DTNASC "
	cQryFic += "FROM " + RetSqlName( "TM0" ) + " TM0 "
	cQryFic += "WHERE D_E_L_E_T_ <> '*' AND "
	cQryFic += "TM0.TM0_FILIAL = '" + xFilial( "TM0" ) + "'"

	cQryFic := ChangeQuery( cQryFic )
	MPSysOpenQuery( cQryFic, cAliQryFic )

	( cAliQryFic )->( dbCloseArea() )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fChgColDay
Executa a inclusão dos dias no calendário conforme a disponibilidade do dia
sendo verde disponivel, amarelo 90% oculpado e vermelho cheio.

@type function

@source MDTA076.prw

@author Bruno Lobo
@since 10/09/2014

@param oCalend	, Objeto	, Objeto do MsCalend
@param cAliasAte, Caracter	, TRB do Atendimento.

@sample fChgColDay( oCalend , cAliasAte )

@return Nulo, Sempre nulo
/*/
//---------------------------------------------------------------------
Static Function fChgColDay( oCalend, cAliasAte )

	Local aHrTot	:= {}
	Local cHrSum	:= "00:00"
	Local cHrTot 	:= ""
	Local cHrCons	:= ""
	Local dDiaAtu 	:= oCalend:dDiaAtu
	Local dDiaCons
	Local nTotMes
	Local nX
	Local aAreaAtu  := GetArea()

	nTotMes := fGetDays( Month( dDiaAtu ), Year( dDiaAtu ) )
	aHrTot := NGCALENDAH( cCalend )

	For nX := 1 To nTotMes

		dDiaCons	:= StoD( cValToChar( StrZero( Year( dDiaAtu ), 4 ) ) + cValToChar( StrZero( Month( dDiaAtu ), 2 ) ) + cValToChar( StrZero( nX, 2 ) ) )
		cHrSum		:= ""
		cHrTot		:= aHrTot[ Dow( dDiaCons ), 1 ]

		If cHrTot == "00:00"
			oCalend:AddRestri( nX, CLR_HGRAY, CLR_WHITE )
		Else

			dbSelectArea( "TMJ" )
			dbSetOrder( 1 )
			Set Filter To TMJ->TMJ_FILIAL == xFilial( "TMJ" ) .And. ;
							TMJ->TMJ_CODUSU == cMedico .And. ;
							TMJ->TMJ_DTCONS == dDiaCons
			dbGoTop()

			While TMJ->( !Eof() )
				cHrCons := TMJ->TMJ_QTDHRS

				// Se não possuir o campo de quantidade de horas informado, deverá considerar o campo da TML
				If Empty( cHrCons )
					cHrCons := NGSEEK( "TML", ( cAliasAte )->CODUSU, 1, "TML_QTDHRS" )
				EndIf

				If Empty( cHrSum )
					nHrTmp  := HtoM( cHrCons )
					nHrTmp2 := Int( nHrTmp / 60 )
					nHrTmp3 := nHrTmp - nHrTmp2
					cHrSum  := StrZero( nHrTmp2, 2 ) + ":" + Substr( cHrCons, 4, 5 )
				Else
					nHrTmp  := HtoM( cHrCons )
					nHrTmp2 := Int( nHrTmp / 60 )
					nHrTmp3 := nHrTmp - nHrTmp2
					cHrSum  := MtoH( HtoM( cHrSum ) + nHrTmp )
				EndIf
				TMJ->( dbSkip() )
			End

			nHrSum := HtoM( SubStr( cHrSum, 1, 5 ) )
			cHrSum := ""

			dbSelectArea( "TY9" )
			dbSetOrder( 1 )
			Set Filter To TY9->TY9_FILIAL == xFilial( "TY9" ) .And. ;
							TY9->TY9_CODUSU == cMedico .And. ;
							TY9->TY9_DTCONS == dDiaCons
			dbGoTop()

			While TY9->( !Eof() )
				cHrCons := TY9->TY9_QTDHRS

				// Se não possuir o campo de quantidade de horas informado, deverá considerar o campo da TML
				If Empty( cHrCons )
					cHrCons := NGSEEK( "TML", ( cAliasAte )->CODUSU, 1, "TML_QTDHRS" )
				EndIf

				If Empty( cHrSum )
					nHrTmp  := HtoM( cHrCons )
					nHrTmp2 := Int( nHrTmp / 60 )
					nHrTmp3 := nHrTmp - nHrTmp2
					cHrSum  := StrZero( nHrTmp2, 2 ) + ":" + Substr( cHrCons, 4, 5 )
				Else
					nHrTmp  := HtoM( cHrCons )
					nHrTmp2 := Int( nHrTmp / 60 )
					nHrTmp3 := nHrTmp - nHrTmp2
					cHrSum  := MtoH( HtoM( cHrSum ) + nHrTmp )
				EndIf
				TY9->( dbSkip() )
			End

			nHrTot := HtoM( cHrTot )
			nHrSum += HtoM( SubStr( cHrSum, 1, 5 ) )
			nPerce := ( ( nHrSum * 100 ) / nHrTot )

			// Altera a cor dos dias no calendário conforme o agendamento diário
			If nPerce >= 90 .And. nPerce < 100
				// Alterado do amarelo para laranja. Utilizado função RGB, pois não existe CLR_ORANGE
				oCalend:AddRestri( nX, RGB( 255, 165, 0 ), CLR_WHITE )
			ElseIf cHrTot > cHrSum
				oCalend:AddRestri( nX, CLR_GREEN, CLR_WHITE )
			Else
				oCalend:AddRestri( nX, CLR_HRED, CLR_WHITE )
			EndIf

		EndIf

	Next nX

	dbSelectArea( "TMJ" )
	Set Filter To
	dbSelectArea( "TY9" )
	Set Filter To

	RestArea( aAreaAtu )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetDays
Retorna a quantidade de dias do mes e ano desejado.

@type function

@source MDTA076.prw

@author Bruno Lobo
@since 10/09/2014

@param nMonth	, Numerico, Mes do ano
@param nAno		, Numerico, Ano

@sample fGetDays( 2 , 2005 )

@return Numerico, Quantidade de dias do mes.
/*/
//---------------------------------------------------------------------
Static Function fGetDays( nMonth, nAno )

	Local nQtdDia

	If nMonth == 2
		nQtdDia := 28
		If fBissexto( cValToChar( nAno ) )
			nQtdDia := 29
		EndIf
	ElseIf cValToChar( nMonth ) $ "1/3/5/7/8/10/12"
		nQtdDia := 31
	Else
		nQtdDia := 30
	EndIf

Return nQtdDia

//---------------------------------------------------------------------
/*/{Protheus.doc} fBissexto
Função para tratar se fora ano bissexto

@type function

@source MDTA076.prw

@author Bruno Lobo
@since 10/09/2014

@param cAno, Caracter, Ano

@sample fBissexto(2010)

@return Logico, Verdadeiro se for ano bissexto.
/*/
//---------------------------------------------------------------------
Static Function fBissexto( cAno )

	Local cFinal 	:= SubStr( cAno, 3, 2 )
	Local nResult	:= 0
	Local lRet		:= .F.

	If cFinal == "00"
		nResult := Mod( Val( cAno ), 400 )
	Else
		nResult := Mod( Val( cAno ), 4 )
	EndIf

	lRet := nResult == 0

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076AGE
Função para Cadastrar o Agendamento

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 28/12/2015

@param oPanel	, Objeto	, Objeto do TPaintPanel
@param oCalend	, Objeto	, Objeto do MsCalend
@param nIdNDate	, Numerico	, Id da data do calendário
@param nPosNDate, Numerico
@param oTPanel	, Objeto	, Objeto do TPaintPanel
@param oHorario	, Objeto	, Objeto do TNGAG
@param cAliasAte, Caracter	, TRB do Atendimento.
@param cHora	, Caracter	, Horário selecionado.
@param dDiaAtu	, Data		, Dia do atendimento
@param [lValid]	, Logico	, Indica se é reserva ou bloqueio.

@sample MDT076AGE( oPanel , oCalend , 42 , nPosNDate , oTNGAG , oTNGAG , cAliasAte, "08:20", 25/11/2001, .T. )

@return Logico, Sempre verdadeiro.
/*/
//---------------------------------------------------------------------
Function MDT076AGE( oPanel, oCalend, nIdNDate, nPosNDate, oTPanel, oHorario, cAliasAte, cHora, dDiaAtu, lValid )

	Local aNao		:= {}
	Local aSize		:= MsAdvSize( , .F., 430 )
	Local cQtdHr	:= "  :  "
	Local nOpcX		:= 3
	Local nOpca

	Private aRotina := {}

	Default lValid := .T. //só deve validar quando estiver sendo incluso uma reserva ou bloqueio

	If !MDT076DTMD( cMedico )
		Return .F.
	EndIf

	aAdd( aRotina, { STR0041, "AxPesqui", 0, 1 } ) //"Pesquisar"
	aAdd( aRotina, { STR0042, "AxVisual", 0, 2 } ) //"Visualizar"
	aAdd( aRotina, { STR0025, "AxInclui", 0, 3 } ) //"Incluir"
	aAdd( aRotina, { STR0043, "AxAltera", 0, 4 } ) //"Alterar"
	aAdd( aRotina, { STR0026, "AxDeleta", 0, 5 } ) //"Excluir"

	//só deve verificar se for incluir TMJ sobre TY9
	If !lValid
		//Verifica se o campo de quantidade de horas esta preenchido para alimentar o campo de memoria, ao incluir a TMJ sobre a TY9
		dbSelectArea( "TY9" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "TY9" ) + cMedico + DTOS( dDiaAtu ) + cHora )
			cQtdHr := TY9->TY9_QTDHRS
			If Len( AllTrim( cQtdHr ) ) != 5
				cQtdHr := fVldQtdHrs( cMedico )
			EndIf
		EndIf
	EndIf

	//Atribui valor as variaveis de tela
	dbSelectArea( "TMJ" )
	RegToMemory( "TMJ", .T., , .F. )

	//Atribui valor para memória
	//---------------------------------------
	M->TMJ_CODUSU	:= cMedico
	M->TMJ_NOMUSU	:= NGSeek( "TMK", cMedico, 1, "TMK_NOMUSU" )
	M->TMJ_DTCONS	:= dDiaAtu
	M->TMJ_HRCONS	:= cHora
	If Len( AllTrim( cQtdHr ) ) == 5
		M->TMJ_QTDHRS := cQtdHr
	EndIf
	//---------------------------------------

	//Monta a Tela
	Define MsDialog oDlgTMJ Title cCadastro From aSize[ 7 ], 0 To aSize[ 6 ], aSize[ 5 ] Of oMainWnd Pixel //"Atendimento Médico"

		//Campos que podem ser editados
		aCpos := { "TMJ_NUMFIC", "TMJ_EXAME", "TMJ_MOTIVO", "TMJ_OBSCON" }
		If Len( AllTrim( cQtdHr ) ) != 5
			aAdd( aCpos, "TMJ_QTDHRS" )
		EndIf

		//Campos que não vao ser mostrados no browse
		aNao := { "TMJ_MAT", "TMJ_CONVOC", "TMJ_DTPROG", "TMJ_DTATEN", "TMJ_PCMSO", "TMJ_ATEENF", "TMJ_CODENF",;
				 "TMJ_INDENF", "TMJ_DTENFE", "TMJ_HRENFE", "TMJ_DESENF", "TMJ_HRCHGD", "TMJ_HRSAID" }

		aChoice  := NGCAMPNSX3( "TMJ", aNao )

		oPnlPai := TPanel():New( 00, 00, , oDlgTMJ, , , , , , 0, 0, .F., .F. )
			oPnlPai:Align   := CONTROL_ALIGN_ALLCLIENT
			oEnchoice:= MsMGet():New( "TMJ", , 3, , , , aChoice, { 0, 0, aSize[ 6 ]/2, aSize[ 5 ]/2 }, aCpos, , , , , oPnlPai )

	//Ativacao do Dialog
	ACTIVATE MSDIALOG oDlgTMJ ON INIT EnchoiceBar( oDlgTMJ,;
												 { || nOpca := 1, IIf( MDT076TDOK( "TMJ", cCalend, lValid, cAliasAte ), oDlgTMJ:End(), Nil ) },;//Confirmar
												 { || nOpca := 0, oDlgTMJ:End() } ) CENTERED //Cancelar

	If nOpca == 1
		//Atualiza shape
		fChangeDay( oCalend, nIdNDate, nPosNDate, oTPanel, oHorario, cAliasAte, .F., "TMJ" )
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076INT
Função para verificar interferências

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 11/10/2016

@param cAliasSrc, Caracter	, Alias posicionado no momento. TY9 ou TMJ
@param lTransf  , Logico	, Indica se é transferencia(.T.).
@param lButton	, Logico	, Indica se foi clicado no botão de Reservar/Bloquear.
@param cNewHr161, Caracter	, Retorna o novo horario de atendimento para o MDTA161
@param cNewQt161, Caracter	, Retorna a nova Quantidade de horas de atendimento para o MDTA161

@sample MDT076INT( "TY9", .F., .F., "10:30", "00:20")

@return Logico, Indica se todas validações estão corretas.
/*/
//---------------------------------------------------------------------
Function MDT076INT( cAliasSrc, lTransf, lButton, cNewHr161, cNewQt161 )

	Local lRet			:= .T.
	Local lStack 		:= IsInCallStack( "MDTA075" ) .Or. IsInCallStack( "MDTA160" ) .Or. ;
							IsInCallStack( "MDTA410" ) .Or. IsInCallStack( "MDTA161" )
	Local lGrava 		:= .T.
	Local cHrIniPrim	:= "" //Indica o horario inicial da consulta de transferencia
	//Variaveis da Query
	//----------------------------------
	Local cAliasInt := GetNextAlias()
	Local cTabTMJ 	:= RetSqlName( "TMJ" )
	Local cTabTY9 	:= RetSqlName( "TY9" )
	//----------------------------------

	Local aArea      := {}

	//Variaveis utilizadas no MDTA410
	//----------------------------------
	Private cUsuario := ""
	Private dDtAgend := STOD( Space( TAMSX3( "TMJ_DTCONS" )[1] ) )
	Private cHrAgend := ""
	//----------------------------------

	Private cHrIniCons 	:= ""
	Private cHrFinCons 	:= ""

	If lStack
		Private cNewHrIni	:= "" //Novo horario inicial da consulta
		Private cNewQtHour	:= "" //Novo tempo de consulta
	EndIf

	Default lTransf := .F.
	Default lButton := .F.
	Default cNewHr161 := ""
	Default cNewQt161 := ""

	If IsInCallStack( "MDTA410" )
		cHrFim := MTOH( HTOM( M->TMJ_HRCONS ) + HTOM( M->TMJ_QTDHRS ) )
		aArea := GetArea()
		dbSelectArea( 'TMJ' )
		dbSetOrder( 7 ) //TMJ_FILIAL+TMJ_CODUSU+DTOS(TMJ_DTCONS)+TMJ_NUMFIC+TMJ_EXAME
		dbSeek( xFilial( 'TMJ' ) + M->TMJ_CODUSU + DTOS( M->TMJ_DTCONS ) + M->TMJ_NUMFIC )
		While (TMJ->(!EoF()) .And. TMJ->TMJ_FILIAL == xFilial( 'TMJ' ) .And. ;
			TMJ->TMJ_CODUSU == M->TMJ_CODUSU .And. ;
			TMJ->TMJ_NUMFIC == M->TMJ_NUMFIC .And. ;
			TMJ->TMJ_DTCONS == M->TMJ_DTCONS)
			cHrConsFim := MTOH( HTOM( TMJ->TMJ_HRCONS ) + HTOM( TMJ->TMJ_QTDHRS ) )
			If( TMJ->TMJ_HRCONS < cHrFim .And. TMJ->TMJ_HRCONS > M->TMJ_HRCONS ) .Or.;
				 ( M->TMJ_HRCONS > TMJ->TMJ_HRCONS .And. M->TMJ_HRCONS < cHrConsFim )
				ShowHelpDlg( STR0003, { STR0134 + TMJ->TMJ_NUMFIC + STR0135 + DTOC( TMJ->TMJ_DTCONS );//"Não é possível incluir o agendamento pois já existe um similar para a ficha "##" no dia "
					 + STR0136 + TMJ->TMJ_HRCONS + STR0047 + cHrConsFim + STR0137 + TMJ->TMJ_CODUSU },; //" das "##" às "##" com o usuário "
					 2, { STR0125 }, 2 )//"Atenção"###"Favor informar outro horário que não ocorra conflito."
				Return .F.
			EndIf
			TMJ->( dbSkip() )
		EndDo
		RestArea( aArea )
	EndIf

	If IsInCallStack( "MDTA161" )
		cMedico    := M->TMJ_CODUSU
		dDtConsVal := M->TMJ_DTCONS
		cHrConsInf := M->TMJ_HRCONS
		cHrQntdInf := IIf( !Empty( M->TMJ_QTDHRS ), M->TMJ_QTDHRS, fVldQtdHrs( cMedico ) )

		cMedAnt    := cMedico
		cHrIniPrim := cHrConsInf
		dDtTranAnt := dDtConsVal
	Else
		If lTransf
			If IsInCallStack( "MDTA410" ) .And. INCLUI
				cMedico    := M->TMJ_CODUSU
				dDtConsVal := M->TMJ_DTCONS
				cHrConsInf := M->TMJ_HRCONS
				cHrQntdInf := IIf( !Empty( M->TMJ_QTDHRS ), M->TMJ_QTDHRS, fVldQtdHrs( cMedico ) )
			Else
				cMedico    := cCodMed
				dDtConsVal := dDtCons
				cHrConsInf := cHrcons
				cHrQntdInf := cQtHrCons
			EndIf

			//Validação para verificar a inclusão do 1º e 2º agendamento
			If IsInCallStack( "MDTA410" )
				cMedAnt    := cMedico
				cHrIniPrim := cHrConsInf
				dDtTranAnt := dDtConsVal
			else
				cMedAnt    := __cMedico
				cHrIniPrim := __cHrCons
				dDtTranAnt := __dDtCons
			EndIf
		EndIf
	EndIf

	If lRet
		//seleciona todos horarios do dia
		cQueryInt := "SELECT TMJ.TMJ_CODUSU AS CODUSU, TMJ.TMJ_DTCONS AS DTCONS, TMJ.TMJ_HRCONS AS HRCONS,"
		cQueryInt += "TMJ.TMJ_QTDHRS AS QTDHRS "
		cQueryInt += "FROM " + cTabTMJ + " TMJ "
		cQueryInt += "WHERE TMJ.TMJ_CODUSU = '"+ cMedico +"' AND TMJ.TMJ_DTCONS = '"+ DTOS( dDtConsVal )
		cQueryInt += "' AND "
		cQueryInt += 		"TMJ.D_E_L_E_T_ <> '*' "

		cQueryInt += " UNION"

		cQueryInt += "SELECT TY9.TY9_CODUSU AS CODUSU, TY9.TY9_DTCONS AS DTCONS, TY9.TY9_HRCONS AS HRCONS,"
		cQueryInt += "TY9.TY9_QTDHRS AS QTDHRS "
		cQueryInt += "FROM " + cTabTY9 + " TY9 "
		cQueryInt += "WHERE TY9.TY9_CODUSU = '"+ cMedico +"' AND TY9.TY9_DTCONS = '"+ DTOS( dDtConsVal )
		cQueryInt += "' AND "
		cQueryInt += 		"TY9.D_E_L_E_T_ <> '*' "
		cQueryInt := ChangeQuery( cQueryInt )
		MPSysOpenQuery( cQueryInt, cAliasInt )

		//----------------------------------------------------------------------------------------------------
		//Validação para caso seja feita uma transferencia do horario selecionado para dentro do seu tempo de duração
		//por exemplo, tenho um agendamento das 10:00 as 10:15 e realizo uma transferencia para as 10:05
		//Deverá ser verificado se possui algum horario posterior que vá interferir, caso não possuir deverá alterar somente
		//o horario selecionado
		//----------------------------------------------------------------------------------------------------
		If lTransf

			//horario final da consulta que será transferida
			cTmpConsul := MTOH( HTOM( cHrConsInf ) + HTOM( cHrQntdInf ) )

			//Verifica quantos registros possui em base e caso for transferencia verifica se deverá abrir tela de opções
			dbSelectArea( cAliasInt )
			DbGoTop()
			//verifica se foi feita no mesmo usuário, caso contrário devera verifica por interferencias
			While ( cAliasInt )->( !Eof() ) .And. ( cAliasInt )->CODUSU == cMedico

				cHrIniCons := ( cAliasInt )->HRCONS
				cHrQtdCons := ( cAliasInt )->QTDHRS
				If Empty( cHrQtdCons ) //se Quantidade de tempo vazio deverá verificar na TML
					cHrQtdCons := fVldQtdHrs( ( cAliasInt )->CODUSU )
				EndIf
				cHrFinCons := MTOH( HTOM( cHrIniCons ) + HTOM( cHrQtdCons ) )

				//verifica se horario inicial esta entre alguma consulta
				If cHrConsInf >= cHrIniCons .And. cHrConsInf < cHrFinCons
					//caso horario inicial do selecionado for igual ou diferente do encontrado, possui interferencia
					lGrava := .F.
					Exit
				//verifica se horario final termina entre alguma consulta
				ElseIf cTmpConsul > cHrIniCons .And. cTmpConsul <= cHrFinCons
					lGrava := .F.
					Exit
				ElseIf !MDT076SOB() //verifica se o novo atendimento vai sobrepor algum horario antigo
					lGrava := .F.
					Exit
				EndIf

				dbSelectArea( cAliasInt )
				( cAliasInt )->( DbSkip() )
			EndDo

			If lGrava
				//Alteração dos valores em base devera ser feito por aqui
				dbSelectArea( "TMJ" )
				dbSetOrder( 1 )
				If dbSeek( xFilial( "TMJ" ) + cMedAnt + DtoS( dDtTranAnt ) + cHrIniPrim )
					RecLock( "TMJ", .F. )
						TMJ->TMJ_CODUSU := cMedico
						TMJ->TMJ_DTCONS := dDtConsVal
						TMJ->TMJ_HRCONS := cHrConsInf
					Msunlock( "TMJ" )
				EndIf
				If IsInCallStack( "MDTA076" )
					//deve atualizar o TRB, para atualizar o shape
					dbSelectArea( cAliasAte )
					dbSetOrder( 4 ) //CODUSU+DtoS(DTCONS)+HRCONS
					If dbSeek( cMedAnt + DtoS( dDtTranAnt ) + cHrIniPrim ) //se encontrar o valor antigo, devera atualizar
						RecLock( cAliasAte, .F. )
						( cAliasAte )->CODUSU := cMedico
						( cAliasAte )->DTCONS := dDtConsVal
						( cAliasAte )->HRCONS := cHrConsInf
						( cAliasAte )->( MsUnLock() )
					EndIf
				EndIf

				Return .T.

			EndIf
		EndIf


		dbSelectArea( cAliasInt )
		DbGoTop()
		While ( cAliasInt )->( !Eof() )

			cHrIniCons := ( cAliasInt )->HRCONS
			cHrQtdCons := ( cAliasInt )->QTDHRS
			If Empty( cHrQtdCons ) //se Quantidade de tempo vazio deverá verificar na TML
				cHrQtdCons := fVldQtdHrs( ( cAliasInt )->CODUSU )
			EndIf
			cHrFinCons := MTOH( HTOM( cHrIniCons ) + HTOM( cHrQtdCons ) )
			cTmpConsul := MTOH( HTOM( cHrConsInf ) + HTOM( cHrQntdInf ) )

			//---------------------------------------------

			//Variaveis utilizado no MDTA410
			If IsInCallStack( "MDTA410" ) .And. INCLUI
				cUsuario := ( cAliasInt )->CODUSU
				dDtAgend := STOD( ( cAliasInt )->DTCONS )
				cHrAgend := ( cAliasInt )->HRCONS
			EndIf

			//verifica se horario inicial esta entre alguma consulta
			If cHrConsInf >= cHrIniCons .And. cHrConsInf < cHrFinCons

				If lButton
					ShowHelpDlg( STR0003, { STR0124 },; //"Não é possível incluir uma Reserva/Bloqueio de horário sobre outro horário."
					 			 2, { STR0125 }, 2 )    //"Atenção"###"Favor informar outro horário que não ocorra conflito."
					lRet := .F.
				EndIf

				If lRet
					If lTransf
						lRet := MDT076VLEN( cMedico, dDtConsVal, cHrIniCons, cHrConsInf, cHrQntdInf, lTransf )
					Else
						lRet := MDT076NEW( cAliasSrc, cHrConsInf, cHrQntdInf, cTmpConsul, dDtConsVal, cHrIniCons )
					EndIf
				EndIf
				Exit
			EndIf

			//verifica se horario final termina entre alguma consulta
			If cTmpConsul > cHrIniCons .And. cTmpConsul <= cHrFinCons
				If lButton

					//-------------------------------------------------------------------------------
					// Mensagens:
					// "Atenção"
					// "Não é possível incluir uma Reserva/Bloqueio de horário sobre outro horário."
					// "Favor informar outro horário que não ocorra conflito."
					//-------------------------------------------------------------------------------
					Help( Nil, Nil, STR0003, Nil, STR0124, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0125 } )

					lRet := .F.

				EndIf
				If lRet
					If lTransf
						lRet := MDT076VLEN( cMedico, dDtConsVal, cHrIniCons, cHrConsInf, cHrQntdInf, lTransf )
					Else
						lRet := MDT076NEW( cAliasSrc, cHrConsInf, cHrQntdInf, cTmpConsul, dDtConsVal, cHrIniCons )
					EndIf
				EndIf
				Exit
			EndIf

			//verifica se o novo atendimento vai sobrepor algum horario antigo
			If !MDT076SOB()
				If lButton
					ShowHelpDlg( STR0003, { STR0124 },; //"Não é possível incluir uma Reserva/Bloqueio de horário sobre outro horário."
								 2, { STR0125 }, 2 )    //"Atenção"###"Favor informar outro horário que não ocorra conflito."
					lRet := .F.
				EndIf
				If lRet
					If lTransf
						lRet := MDT076VLEN( cMedico, dDtConsVal, cHrIniCons, cHrConsInf, cHrQntdInf, lTransf )
					Else
						lRet := MDT076NEW( cAliasSrc, cHrConsInf, cHrQntdInf, cTmpConsul, dDtConsVal, cHrIniCons )
					EndIf
				EndIf
				Exit
			EndIf

			dbSelectArea( cAliasInt )
			( cAliasInt )->( DbSkip() )
		End
	EndIf

	If lRet
		If IsInCallStack( "MDTA161" )
			cNewHr161 := cNewHrIni
			cNewQt161 := cNewQtHour
		Else
			//Só deverá realizar gravação se não for Transferencia
			If !lTransf
				//Faz inclusão na tabela
				If !Empty( cNewHrIni ) .Or. !Empty( cNewQtHour )
					MDT076INC( cAliasSrc, cNewHrIni, cNewQtHour )
					//Deverá limpar as variaveis, para ao incluir o próximo registro ñ ficar com os valores da anterior
				Else //se ñ possui interferencias grava o valor informado
					//Faz inclusão na tabela
					MDT076INC( cAliasSrc, cHrConsInf, cHrQntdInf )
				EndIf
			EndIf
			//Deverá limpar as variaveis, para ao incluir o próximo registro ñ ficar com os valores da anterior
			cNewHrIni := ""
			cNewQtHour := ""
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076SOB
Função para verificar horarios sobrepostos.
Se o horário da nova consulta for das 08:00 as 08:40 e
possuir um agendamento das das 08:10 as 08:20 deverá validar
que a nova consulta ficará sobre a mesma.

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 11/10/2016

@param

@sample MDT076SOB()

@return Logico, Indica se todas validações estão corretas.
/*/
//---------------------------------------------------------------------
Function MDT076SOB()

	Local lRet := .T.

	Local cAliasSob := GetNextAlias()
	Local cTabTMJ   := RetSqlName( "TMJ" )
	Local cTabTY9   := RetSqlName( "TY9" )

	cQuery := "SELECT TMJ.TMJ_CODUSU AS CODUSU, TMJ.TMJ_DTCONS AS DTCONS, TMJ.TMJ_HRCONS AS HRCONS, TMJ.TMJ_QTDHRS AS QTDHRS "
	cQuery += "FROM " + cTabTMJ + " TMJ "
	cQuery += "WHERE TMJ.TMJ_CODUSU = '"+ cMedico +"' AND TMJ.TMJ_DTCONS = '"+ DTOS( dDtConsVal )
	cQuery += "' AND ( ('" + cHrIniCons + "'Between '" + cHrConsInf + "' AND '"+ cTmpConsul  +"') OR "
	cQuery += " ('" + cHrFinCons + "'Between '" + cHrConsInf + "' AND '"+ cTmpConsul  +"') ) AND "
	cQuery += 		"TMJ.D_E_L_E_T_ <> '*'"

	cQuery += " UNION"

	cQuery += "SELECT TY9.TY9_CODUSU AS CODUSU, TY9.TY9_DTCONS AS DTCONS, TY9.TY9_HRCONS AS HRCONS, TY9.TY9_QTDHRS AS QTDHRS "
	cQuery += "FROM " + cTabTY9 + " TY9 "
	cQuery += "WHERE TY9.TY9_CODUSU = '"+ cMedico +"' AND TY9.TY9_DTCONS = '"+ DTOS( dDtConsVal )
	cQuery += "' AND ( ('" + cHrIniCons + "'Between '" + cHrConsInf + "' AND '"+ cTmpConsul  +"') OR "
	cQuery += " ('" + cHrFinCons + "'Between '" + cHrConsInf + "' AND '"+ cTmpConsul  +"') ) AND "
	cQuery += 		"TY9.D_E_L_E_T_ <> '*'"
	cQuery := ChangeQuery( cQuery )
	MPSysOpenQuery( cQuery, cAliasSob )

	//verifica se possui uma consulta 'dentro' da nova consulta
	//Se consulta nova for das 08:00 as 08:40 e a antiga for das 08:10 as 08:20
	dbSelectArea( cAliasSob )
	DbGoTop()
	While ( cAliasSob )->( !Eof() )
		cConsBase := ( cAliasSob )->HRCONS //horario inicial da consulta da base
		cTempCons := MTOH( HTOM( ( cAliasSob )->HRCONS ) + HTOM( ( cAliasSob )->QTDHRS ) ) //horario final da consulta da base
		If cConsBase > cHrConsInf .And. cConsBase < cTmpConsul //se horario inicial esta entre o novo
			If cTempCons > cHrConsInf .And. cTempCons < cTmpConsul //se horario final esta entre o novo
				lRet := .F.
				Exit
			EndIf
		EndIf
		dbSelectArea( cAliasSob )
		( cAliasSob )->( DbSkip() )
	End

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076SHP
Função para verificar a quantidade de Shapes necessários para o atendimento

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 04/02/2016

@param cMedico	, Caracter	, Código do Médico
@param dDiaAtu	, Data		, Dia do atendimento
@param cHrSrc	, Caracter	, Horário que vai ser realizado o atendimento
@param [nOpcX]	, Numerico	, Opção a ser executada no momento
@param cAlsSrch	, Caracter	, Alias posicionado no momento. TY9 ou TMJ

@sample MDT076SHP( "000005", 20/08/2015, "14:25", 3, "TY9" )

@return Numerico, Quantidade de shapes.
/*/
//---------------------------------------------------------------------
Function MDT076SHP( cMedico, dDiaAtu, cHrSrc, nOpcX, cAlsSrch )

	Local aArea 		:= GetArea()
	Local cPrefixTab 	:= cAlsSrch + "->" + PrefixoCPO( cAlsSrch )
	Local cPrefixMem 	:= "M->" + PrefixoCPO( cAlsSrch )
	Local nQntShp 		:= 0
	Local nQntHrs 		:= 15

	Default nOpcX 		:= 1

	//Verifica se foi informado o campo TML_QTDHRS da Agenda
	//Caso informado atribui o valor, se não sera atribuido o valor padrão
	dbSelectArea( "TML" )
	dbSetOrder( 1 ) //TML_FILIAL+TML_CODUSU
	If dbSeek( xFilial( "TML" ) + cMedico )
		nQntHrs := IIf( Len( AllTrim( TML->TML_QTDHRS ) ) == 5, TML->TML_QTDHRS, nQntHrs )
	EndIf

	//Verifica se foi informado o campo TMJ_QTDHRS do Atendimento
	//Deve ser priorizado, pois é o Médico que informa o campo
	//Caso informado atribui o valor, se não sera atribuido o valor da TML
	If nOpcX == 3
		dDiaSel := IIf ( nOpcX == 3, &( cPrefixMem + "_DTCONS" ), dDiaAtu )
		nQntHrs := IIf( Len( AllTrim( &( cPrefixMem + "_QTDHRS" ) ) ) == 5, &( cPrefixMem + "_QTDHRS"), nQntHrs )
	Else
		dbSelectArea( cAlsSrch )
		dbSetOrder( 1 ) //TMJ_FILIAL+TMJ_CODUSU+DTOS(TMJ_DTCONS)+TMJ_HRCONS
		If dbSeek( xFilial( cAlsSrch ) + cMedico + DTOS( dDiaAtu ) + cHrSrc )
			nQntHrs := IIf( Len( AllTrim( &( cPrefixTab + "_QTDHRS" ) ) ) == 5, &( cPrefixTab + "_QTDHRS" ), nQntHrs )
		EndIf
	EndIf

	//Se vir como caracter converte o horário para o formato correto
	If Valtype( nQntHrs ) != "N"
		nQntHrs := HTOM( nQntHrs )
	EndIf
	//Verifica se a quantidade de horas totais do atendimento ultrapassa 24
	If HTOM( cHrSrc ) + nQntHrs > HTOM( "24:00" )
		nQntHrs := HTOM( "24:00" ) - HTOM( cHrSrc )
	EndIf

	//Verifica se o horário é divisor de 5
	//Para buscar a quantidade de shapes correta
	//--------------------------------------------------------
	If ( nQntHrs % 5 ) != 0
		nDiv := nQntHrs % 5
		nQntHrs := nQntHrs - nDiv
	EndIf
	//--------------------------------------------------------

	//Faz a divisão para definir a Quantidade de shapes necessário para o Atendimento Médico
	nQntShp := nQntHrs / 5 /*tempo minimo da consulta*/

	RestArea( aArea )

Return nQntShp

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076INC
Função para Incluir o agendamento

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 05/04/2016

@param cAliasInc	, Caracter, Alias de inclusao TMJ ou TY9.
@param cHrCons		, Caracter, Horário da consulta
@param cQntdHrAtu	, Caracter, Quantidade de horas da consulta

@sample MDT076INC( "TMJ", "08:30" , "00:15" )

@return Logico, Sempre verdadeiro.
/*/
//---------------------------------------------------------------------
Function MDT076INC( cAliasInc, cHrCons, cQntdHrAtu )

	Local cPrefixTab := cAliasInc + "->" + PrefixoCPO( cAliasInc )
	Local cPrefixMem := "M->" + PrefixoCPO( cAliasInc )

	dbSelectArea( cAliasInc )
	dbSetOrder( 1 )
	If !dbSeek( xFilial( cAliasInc ) + &( cPrefixMem + "_CODUSU" ) + DTOS( &( cPrefixMem + "_DTCONS" ) ) + cHrCons )
		RecLock( cAliasInc, .T. )
			If cAliasInc == "TMJ"
				&( cPrefixTab + "_FILFUN" ) := xFilial( cAliasInc )
				&( cPrefixTab + "_NUMFIC" ) := &( cPrefixMem + "_NUMFIC" )
				&( cPrefixTab + "_MAT"    )	:= &( cPrefixMem + "_MAT" )
				&( cPrefixTab + "_DTPROG" ) := &( cPrefixMem + "_DTCONS" )
				&( cPrefixTab + "_EXAME"  ) := &( cPrefixMem + "_EXAME" )
				&( cPrefixTab + "_MOTIVO" ) := &( cPrefixMem + "_MOTIVO" )
			Else
				&( cPrefixTab + "_TIPOAG" ) := &( cPrefixMem + "_TIPOAG" )
			EndIf
			&( cPrefixTab + "_FILIAL" ) := xFilial( cAliasInc )
			&( cPrefixTab + "_CODUSU" ) := &( cPrefixMem + "_CODUSU" )
			&( cPrefixTab + "_DTCONS" ) := &( cPrefixMem + "_DTCONS" )
			&( cPrefixTab + "_HRCONS" ) := cHrCons
			&( cPrefixTab + "_OBSCON" ) := &( cPrefixMem + "_OBSCON" )
			&( cPrefixTab + "_QTDHRS" ) := cQntdHrAtu
		( cAliasInc )->( MsUnlock() )
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076EXC
Função para deletar o agendamento

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 16/03/2016

@param oPanelPai, Objeto	, Objeto do TPaintPanel
@param oCalend	, Objeto	, Objeto do MsCalend
@param nIdNDate	, Numerico	, Id da data do calendário
@param nPosNDate, Numerico
@param oPanelShp, Objeto	, Objeto do TPaintPanel
@param oHorario	, Objeto	, Objeto do TNGAG
@param cAliasAte, Caracter	, TRB do Atendimento.

@sample MDT076EXC( oPanelPai , oCalend , 21 , nPosNDate , oPanelShp , oTNGAG , cAliasAte )

@return Logico, Sempre verdadeiro.
/*/
//---------------------------------------------------------------------
Function MDT076EXC( oPanelPai, oCalend, nIdNDate, nPosNDate, oPanelShp, oHorario, cAliasAte )

	Local nIDPos	:= oPanelPai:GetId()
	Local cFicha	:= AllTrim( oPanelPai:GetTextRef( cValToChar( nIDPos ) ) )
	Local cHora 	:= oPanelPai:GetHoraRef( cValToChar( nIDPos ) )
	Local dDiaAtu	:= oCalend:dDiaAtu
	Local lDelet 	:= .T.
	Local nRetTY9 	:= 0
	Local nRetTMJ 	:= 0

	Private aCHOICE := {}

	dbSelectArea( cAliasAte )
	dbSetOrder( 4 )
	If dbSeek( cMedico + DtoS( dDiaAtu ) + cHora )
		dbSelectArea( "TY9" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "TY9" ) + ( cAliasAte )->CODUSU + DtoS( ( cAliasAte )->DTCONS ) + ( cAliasAte )->HRCONS )
			nRetTY9 := NGCAD01( "TY9", TY9->( RecNo() ), 5 )
		EndIf
	EndIf

	If !Empty( cFicha ) .And. nRetTY9 == 0
		dbSelectArea( cAliasAte )
		dbSetOrder( 4 )
		If dbSeek( cMedico + DtoS( dDiaAtu ) + cHora )

			dbSelectArea( "TMJ" )
			dbSetOrder( 1 )
			If dbSeek( xFilial( "TMJ" ) + ( cAliasAte )->CODUSU + DtoS( ( cAliasAte )->DTCONS ) + ( cAliasAte )->HRCONS )
				//Deleta os possiveis relacionamentos
				dbSelectArea( "TMT" )
				dbSetOrder( 2 ) //TMT_FILIAL+TMT_CODUSU+DTOS(TMT_DTCONS)+TMT_HRCONS
				If dbSeek( xFilial( "TMT" ) + ( cAliasAte )->CODUSU + DTOS( ( cAliasAte )->DTCONS ) + ( cAliasAte )->HRCONS )
					While !Eof()
						If ( cAliasAte )->NUMFIC == TMT->TMT_NUMFIC
							MsgAlert( STR0046, STR0003 ) // "Ao excluir esta ficha os atendimentos e medicamentos relacionados também serão excluídos."###"Atenção"
							nRetTMJ :=  NGCAD01( "TMJ", TMJ->( RecNo() ), 5 )
							If nRetTMJ == 1 //só deve excluir se confirmar a tela
								RecLock( "TMT", .F. )
									( "TMT" )->( dbDelete() )
								Msunlock( "TMT" )
							EndIf
							Exit
						EndIf
						dbSelectArea( "TMT" )
						( "TMT" )->( dbSkip() )
					End
				Else //se não possuir atendimento

					aCHOICE := { "TMJ_CODUSU",; //campos que serão apresentados em tela
					             "TMJ_NOMUSU",;
					             "TMJ_DTCONS",;
					             "TMJ_HRCONS",;
					             "TMJ_NUMFIC",;
					             "TMJ_NOMFIC",;
					             "TMJ_MOTIVO",;
					             "TMJ_NATEXA",;
					             "TMJ_NOMOTI",;
					             "TMJ_EXAME",;
					             "TMJ_NOMEXA",;
					             "TMJ_OBSCON",;
					             "TMJ_QTDHRS" }

					nRetTMJ := NGCAD01( "TMJ", TMJ->( RecNo() ), 5 )

				EndIf
				If nRetTMJ == 1
					dbSelectArea( "TM2" )
					dbSetOrder( 1 ) //TM2_FILIAL+TM2_NUMFIC+DTOS(TM2_DTCONS)+TM2_HRCONS+TM2_CODMED
					If dbSeek( xFilial( "TM2" ) + ( cAliasAte )->NUMFIC + DTOS( ( cAliasAte )->DTCONS ) + ( cAliasAte )->HRCONS )
						RecLock( "TM2", .F. )
							( "TM2" )->( dbDelete() )
						Msunlock( "TM2" )
					EndIf
				EndIf

			EndIf

		EndIf
	EndIf

	If nRetTY9 == 1 .Or. nRetTMJ == 1
		RecLock( cAliasAte, .F. )
		( cAliasAte )->( dbDelete() )
		( cAliasAte )->( MsUnLock() )
		//Atualiza shape
		fChangeDay( oCalend, nIdNDate, nPosNDate, oPanelShp, oHorario, cAliasAte )
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076TUR
Função para receber os horarios do turno da manha e do turno da tarde

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 08/04/2016

@param dDiaSel, Data, Dia selecionado

@sample MDT076TUR( 28/04/2008 )

@return Array, Horarios do turno.
/*/
//---------------------------------------------------------------------
Function MDT076TUR( dDiaSel )

	Local aTurnos	:= {}
	Local aHrTur	:= {} //Horarios do turno
	Local aHrTurAux := {} //Auxiliar dos horarios do turno

	Local cManhaAux := ""
	Local cTardeAux := ""
	Local cTarde 	:= ""
	Local cManha 	:= ""
	Local cTarInf	:= ""

	Local nHora, nMinuto, n

	aHrTrab := NGCALENDAH( cCalend ) //Recebe os horario do turno

	//verifica ql dia da semana - sendo Domingo=1 e Sábado=7
	nDia := Dow( dDiaSel )

	//Realiza a tratativa dos Horários conforme a Agenda
	For nHora := 0 To 23//Percorre todos os horários
		For nMinuto := 0 To 11//Percorre todos os minutos
			//Monta a hora a ser buscada
			cHrVld := StrZero( nHora, 2 ) + ":" + StrZero( nMinuto * 5, 2 )
			//nIdHr := oHorario:GetIdHora( cHrVld )

			//Valida se o horário é um horário válido para o médico
			If aScan( aHrTrab[ nDia, 2 ], { | x | cHrVld >= x[ 1 ] .And. cHrVld <= x[ 2 ] } ) != 0
				aAdd( aHrTur, { cHrVld } )
			Else
				If Len( aHrTur ) > 0
					aAdd( aHrTurAux, { aHrTur[1], aTail( aHrTur ) } ) //add a primeira e ultima posição do array
					aHrTur := {} //Zera array, para pegar os valores do horario do turno. ex - 7hrs as 8hrs, 11hrs as 12hrs, 14hrs as 18hrs
				EndIf
			EndIf
		Next
	Next

	//Pega os valores de cada horario do turno e apresenta em tela
	For n := 1 To Len( aHrTurAux )

		If aHrTurAux[n, 1, 1] >= "00:00" .And. aHrTurAux[n, 2, 1] <= "12:00"
			cManha := aHrTurAux[n, 1, 1] + STR0047 + aHrTurAux[n, 2, 1] //" às "
			If !Empty( cManhaAux )
				cManhaAux := cManhaAux + STR0048 + cManha //" e "
			Else
				cManhaAux := cManha
			EndIf
		//Vai entrar somente 1 vez aqui. Ex: 10:00 as 13:30 - Vai separar das 10:00 às 12:00
		//e das 12:00 às 13:30
		//---------------------------------------------------------------------
		ElseIf aHrTurAux[n, 1, 1] >= "00:00" .And. aHrTurAux[n, 1, 1] < "12:00" .And. aHrTurAux[n, 2, 1] >= "12:00"

			If !Empty( cManhaAux )
				cManhaAux := cManhaAux + STR0047 + aHrTurAux[n, 1, 1] + STR0047 + "12:00" //" às "
			Else
				cManhaAux := aHrTurAux[n, 1, 1] + STR0047 + "12:00" //" às "
			EndIf
			cTarde := "12:00" + STR0047 + aHrTurAux[n, 2, 1] //" às "

		//---------------------------------------------------------------------
		ElseIf aHrTurAux[n, 1, 1] >= "12:00" .And. aHrTurAux[n, 2, 1] <= "23:59"
			If !Empty( cTarde )
				cTarde := cTarde + STR0047 + aHrTurAux[n, 1, 1] + STR0047 + aHrTurAux[n, 2, 1] //" às "
			EndIf
			If !Empty( cTardeAux )
				cTardeAux := cTardeAux + STR0048 + aHrTurAux[n, 1, 1] + STR0047 + aHrTurAux[n, 2, 1] //" e "###" às "
			Else
				cTardeAux := aHrTurAux[n, 1, 1] + STR0047 + aHrTurAux[n, 2, 1] //" às "
			EndIf

		EndIf
	Next

	cTarInf := IIf( !Empty( cTardeAux ), cTardeAux, cTarde ) //Verifica ql variavel foi informada e add nela

	aAdd( aTurnos, { cManhaAux, cTarInf } ) //Add no array os horarios do turno

Return aTurnos

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076MED
Função para incluir, Alterar ou excluir um Médico e sua Agenda

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 11/04/2016

@param nOpca	, Numerico	, Opção a ser executada no momento.
@param lAtual	, Logico	, Indica se devera atualizar tela.
@param aMedicos	, Array		, Array dos Médicos
@param oTPanel	, Objeto	, Objeto do TPaintPanel
@param oHorario	, Objeto	, Objeto do TNGAG
@param oCalend	, Objeto	, Objeto do MsCalend
@param cAliasAte, Caracter	, TRB do Atendimento.
@param nIdNDate	, Numerico	, Id da data do calendário
@param nPosNDate, Numerico
@param cAliasMed, Caracter	, Alias do Médico(TRB).
@param nIdNMed	, Numerico	, Id do Médico
@param nPosMed	, Numerico	, Posição do Médico
@param nId		, Numerico	, Último ID utilizado
@param oDlg		, Objeto	, Objeto do painel principal.

@sample MDT076MED( 3, aMedicos, oTNGAG, oTNGAG, oCalend, cAliasAte, 14 , nPosNDate, cAliasMed , @nIdNMed , @nPosMed , @nId  )

@return Logico, Indica se foi confirmado a tela.
/*/
//---------------------------------------------------------------------
Function MDT076MED( nOpca, lAtual, aMedicos, oTPanel, oHorario, oCalend, cAliasAte, nIdNDate, nPosNDate, cAliasMed, nIdNMed, nPosMed, nId, oDlg  )

	Local aSize		:= MsAdvSize( , .F., 430 )
	Local aNao  	:= {} //Campos que não vao ser mostrados no browse
	Local aCpos 	:= {} //Campos que podem ser editados
	Local lAgenda	:= .F.
	Local nCont 	:= 0
	Local nOpc
	Local oDlgMED

	Private ALTERA	:= .F.
	Private INCLUI	:= .F.

	If nOpca == 3 .Or. nOpca == 5 //Inclusão do Médico

		If nOpca == 5
			dbSelectArea( "TMK" )
			dbSetOrder( 1 )
			dbSeek( xFilial( "TMK" ) + cMedico )
			RegToMemory( "TMK", .F. )
		Else
			dbSelectArea( "TMK" )
			RegToMemory( "TMK", .T. )
		EndIf

		//Monta a Tela
		Define MsDialog oDlgMED Title STR0049 From aSize[ 7 ], 0 To aSize[ 6 ], aSize[ 5 ] Of oMainWnd Pixel //"Agenda do médico"

			//Campos que podem ser editados
			aCpos := { "TMK_CODUSU", "TMK_NOMUSU", "TMK_ENTCLA", "TMK_NUMENT", "TMK_DTINIC", "TMK_DTTERM", "TMK_REGMTB",;
					 "TMK_SESMT", "TMK_INDFUN", "TMK_CALEND", "TMK_ENDUSU", "TMK_UF", "TMK_TELUSU", "TMK_NIT", "TMK_CC",;
					 "TMK_MONBIO", "TMK_RESAMB", "TMK_EMAIL", "TMK_CIC", "TMK_USUARI", "TMK_ESOC", "TMK_QTDHRS" }

					//Campos que não vao ser mostrados no browse
			aNao := { "" }

			aChoice  := NGCAMPNSX3( "TMK", aNao )

			oPnlPai := TPanel():New( 00, 00, , oDlgMED, , , , , , 0, 0, .F., .F. )
				oPnlPai:Align   := CONTROL_ALIGN_ALLCLIENT
				oEnchoice:= MsMGet():New( "TMK", , nOpca, , , , aChoice, { 0, 0, aSize[ 6 ]/2, aSize[ 5 ]/2 }, aCpos, , , , , oPnlPai, , , , , , , , , .T. )

		//Ativacao do Dialog
		ACTIVATE MSDIALOG oDlgMED ON INIT EnchoiceBar( oDlgMED,;
													 { || nOpc := 1, IIf( fValidMed( nOpca ), oDlgMED:End(), Nil ) },;//Confirmar
													 { || nOpc := 0, oDlgMED:End() } ) CENTERED //Cancelar*/

		If nOpc == 1
			If nOpca == 3
				dbSelectArea( "TMK" )
				dbSetOrder( 1 )
				If !dbSeek( xFilial( "TMK" ) + M->TMK_CODUSU )
					RecLock( "TMK", .T. )
						TMK->TMK_FILIAL := xFilial( "TMK" )
						TMK->TMK_CODUSU := M->TMK_CODUSU
						TMK->TMK_NOMUSU := M->TMK_NOMUSU
						TMK->TMK_ENTCLA := M->TMK_ENTCLA
						TMK->TMK_NUMENT := M->TMK_NUMENT
						TMK->TMK_DTINIC := M->TMK_DTINIC
						TMK->TMK_DTTERM := M->TMK_DTTERM
						TMK->TMK_REGMTB := M->TMK_REGMTB
						TMK->TMK_SESMT 	:= M->TMK_SESMT
						TMK->TMK_INDFUN := M->TMK_INDFUN
						TMK->TMK_CALEND := M->TMK_CALEND
						TMK->TMK_ENDUSU	:= M->TMK_ENDUSU
						TMK->TMK_UF 	:= M->TMK_UF
						TMK->TMK_TELUSU := M->TMK_TELUSU
						TMK->TMK_NIT 	:= M->TMK_NIT
						TMK->TMK_CC 	:= M->TMK_CC
						TMK->TMK_MONBIO := M->TMK_MONBIO
						TMK->TMK_RESAMB := M->TMK_RESAMB
						TMK->TMK_EMAIL 	:= M->TMK_EMAIL
						TMK->TMK_CIC 	:= M->TMK_CIC
						TMK->TMK_USUARI := M->TMK_USUARI
						TMK->TMK_ESOC 	:= M->TMK_ESOC
						TMK->TMK_QTDHRS	:= M->TMK_QTDHRS
					( "TMK" )->( MsUnLock() )

					dbSelectArea( "TML" )
					dbSetOrder( 1 )
					If !dbSeek( xFilial( "TML" ) + M->TMK_CODUSU )
						RecLock( "TML", .T. )
							TML->TML_FILIAL := xFilial( "TML" )
							TML->TML_CODUSU := M->TMK_CODUSU
							TML->TML_CALEND := M->TMK_CALEND
							TML->TML_QTDHRS := M->TMK_QTDHRS //"00:15" //tempo padrão
						( "TML" )->( MsUnLock() )
					EndIf
				EndIf
			Else //Exclusão

				dbSelectArea( "TML" )
				dbSetOrder( 1 )
				If dbSeek( xFilial( "TML" ) + cMedico )
					RecLock( "TML", .F. )
						( "TML" )->( dbDelete() )
					( "TML" )->( MsUnLock() )
				EndIf

				dbSelectArea( "TMK" )
				dbSetOrder( 1 )
				If dbSeek( xFilial( "TMK" ) + cMedico )
					RecLock( "TMK", .F. )
						( "TMK" )->( dbDelete() )
					( "TMK" )->( MsUnLock() )
				EndIf
			EndIf
		Else
			Return .F.
		EndIf

	EndIf

	If lAtual
		If nOpca == 3

			INCLUI := .T.

			//Atualiza os Médicos
			aMedicos := {}
			fGetAgenda( cAliasMed, @aMedicos )
			nNewCod := aScan( aMedicos, { | x | x[ 1 ] == TMK->TMK_CODUSU } )
			//--------------------
			nId		:= Val( SumId( @nId ) )
			ChangeMed( 0, @nId, aMedicos, @nPosMed, oTPanel, @nIdNMed, , , , , , nNewCod )
			//--------------------
			fChangeDay( oCalend, nIdNDate, nPosNDate, oTPanel, oHorario, cAliasAte )

		ElseIf nOpca == 4 //Alteração do Médico

			ALTERA := .T.

			dbSelectArea( "TMK" )
			dbSetOrder( 1 )
			dbSeek( xFilial( "TMK" ) + cMedico )
			If NGCAD01( "TMK", TMK->( RecNo() ), 4 ) == 1
				//Atualiza os Médicos
				aMedicos := {}
				fGetAgenda( cAliasMed, @aMedicos )

				nNewCod := aScan( aMedicos, { | x | x[ 1 ] == TMK->TMK_CODUSU } )
				//--------------------
				nId		:= Val( SumId( @nId ) )
				ChangeMed( 0, @nId, aMedicos, @nPosMed, oTPanel, @nIdNMed, , , , , , nNewCod )

				//--------------------

				fChangeDay( oCalend, nIdNDate, nPosNDate, oTPanel, oHorario, cAliasAte )
			EndIf

		ElseIf nOpca == 5 //Exclusão do Médico

			dbSelectArea( cAliasMed )
			RecLock( cAliasMed, .F. )
				( cAliasMed )->( dbDelete() )
			( cAliasMed )->( MsUnLock() )

			//Atualiza os Médicos
			aMedicos := {}
			fGetAgenda( cAliasMed, @aMedicos )

			//se excluir o ultimo médico devera sair da rotina
			If Len( aMedicos ) == 0
				MsgAlert( STR0114, STR0003 )// ""Não possui mais médicos cadastrados.""###"Atenção"
				oDlg:End()
				Return .F.
			EndIf

			//--------------------
			nId		:= Val( SumId( @nId ) )
			ChangeMed( 0, @nId, aMedicos, @nPosMed, oTPanel, @nIdNMed )
			//--------------------
			fChangeDay( oCalend, nIdNDate, nPosNDate, oTPanel, oHorario, cAliasAte )

		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076REL
Função para trazer o nome correto do Atendente no NGCAD02

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 13/04/2016

@param

@sample MDT076REL()

@return Caracter, Nome do usuario.
/*/
//---------------------------------------------------------------------
Function MDT076REL()

	Local cRet := ""

	If IsInCallStack( "MDTA076" )
		dbSelectArea( "TML" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "TML" ) + TML->TML_CODUSU )
			cRet := Posicione( "TMK", 1, xFilial( "TMK" ) + TML->TML_CODUSU, "TMK_NOMUSU" )
		EndIf
	Else
		cRet := Posicione( "TMK", 1, xFilial( "TMK" ) + TML->TML_CODUSU, "TMK_NOMUSU" )
	EndIf

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076BUS
Função para buscar os Atendimentos selecionados do Médico posicionado

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 29/06/2016

@param oHorario	, Objeto	, Objeto do TNGAG
@param oCalend	, Objeto	, Objeto do MsCalend
@param cAliasAte, Caracter	, TRB do Atendimento.
@param nIdNDate	, Numerico	, Id da data do calendário
@param nPosNDate, Numerico
@param aMedicos	, Array		, Array dos Médicos
@param oTPanel	, Objeto	, Objeto do TPaintPanel
@param nIdNMed	, Numerico	, Id do Médico
@param nPosMed	, Numerico	, Posição do Médico
@param nId		, Numerico	, Último ID utilizado

@sample MDT076BUS( oTNGAG, oCalend, cAliasAte, 47 , nPosNDate, aMedicos, oTPanel, @nIdNMed , @nPosMed , @nId )

@return Logico, Sempre verdadeiro.
/*/
//---------------------------------------------------------------------
Function MDT076BUS( oHorario, oCalend, cAliasAte, nIdNDate, nPosNDate, aMedicos, oTPanel, nIdNMed, nPosMed, nId )

	Local aSize		:= MsAdvSize( , .F., 430 )
	Local cCodPesq 	:= Space( 12 )
	Local oDlgBus

	DEFINE MSDIALOG oDlgBus TITLE STR0053 From aSize[7], 0 To aSize[6] / 5, aSize[5] / 3 OF oMainWnd PIXEL //"Buscar Médico"
		//Painel de Fundo
		oPnlFund := TPanel():New( 00, 00, , oDlgBus, , .T., , , , , , .F., .F. )
		oPnlFund:Align := CONTROL_ALIGN_ALLCLIENT

		oSay := tSay():New( 005, 005, { | | OemtoAnsi( STR0058 ) }, oPnlFund, , , , , , .T., , , 200, 010 ) //"Buscar por Médico"

		oGet := tGet():New( 004, 060, { | u | IIf( PCount() > 0, cCodPesq := u, cCodPesq ) }, oPnlFund, 70, 03, "@!",;
						 { | | fValidTMK( cCodPesq ) }, , , , , , .T., , , , .F., , , .F., .F., "TMKAGE", , , , , .T. )

	Activate MsDialog oDlgBus On Init EnchoiceBar( oDlgBus,;
									 { || nOpcao := 1, IIf( fBuscVal( cCodPesq, oHorario, oCalend, cAliasAte, nIdNDate, nPosNDate, aMedicos, oTPanel, @nIdNMed, @nPosMed, @nId ), oDlgBus:End(), Nil ) },; //Ok
									 { || nOpcao := 0, oDlgBus:End() } )CENTERED //Cancel

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076RES
Função para Incluir um novo Atendimento e informar se é Reserva ou Bloqueio

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 15/04/2016

@param oPanel	, Objeto	, Objeto do TPaintPanel
@param oCalend	, Objeto	, Objeto do MsCalend
@param nIdNDate	, Numerico	, Id da data do calendário
@param nPosNDate, Numerico
@param oTPanel	, Objeto	, Objeto do TPaintPanel
@param oHorario	, Objeto	, Objeto do TNGAG
@param cAliasAte, Caracter	, TRB do Atendimento.
@param cTipoAg	, Caracter	, Indica o tipo de Agendamento. Sendo 1-Reservar e 2-Bloquear.
@param [cHora]	, Caracter	, Horário selecionado.
@param [dDiaAtu], Data		, Dia do horario selecionado.
@Param lDbClick	, Logico	, Verifica se esta sendo chamado do duplo clique.

@sample MDT076RES( oPanel, oCalend, nIdNDate , nPosNDate, oTPanel, oHorario, cAliasAte, "1", "11:25", 10/05/2016, .T. )

@return Nulo, Sempre Nulo.
/*/
//---------------------------------------------------------------------
Function MDT076RES( oPanel, oCalend, nIdNDate, nPosNDate, oTPanel, oHorario, cAliasAte, cTipoAg, cHora, dDiaAtu, lDbClick )

	Local aSize	:= MsAdvSize( , .F., 430 )
	Local aNao  := {} //Campos que não vao ser mostrados no browse
	Local aCpos := {} //Campos que podem ser editados
	Local nOpcX := 3
	Local nOpcao

	//Caso for chamado do botão lateral deve receber vazio, pois ñ possui horario escolhido
	//--------------------------------------
	Default cHora 	:= "  :  "
	Default dDiaAtu := STOD( Space( TAMSX3( "TMJ_DTCONS" )[1] ) )
	//--------------------------------------

	If !MDT076DTMD( cMedico )
		Return .F.
	EndIf

	//Atribui valor as variaveis de tela
	dbSelectArea( "TY9" )
	RegToMemory( "TY9", .T., , .F. )

	//Recebe os valores
	M->TY9_CODUSU := cMedico
	M->TY9_NOMUSU := NGSEEK( 'TMK', M->TY9_CODUSU, 1, 'TMK_NOMUSU' )
	M->TY9_DTCONS := dDiaAtu
	M->TY9_HRCONS := cHora
	M->TY9_TIPOAG := cTipoAg //1-Reservar, 2 -Bloquear

	If cTipoAg == "1"
		cTitle := STR0054 //"Reservar horário"
	Else
		cTitle := STR0055 //"Bloquear horário"
	EndIf
	//Monta a Tela
	Define MsDialog oDlgTY9 Title OemToAnsi( cTitle ) From aSize[ 7 ], 0 To aSize[ 6 ] / 3, aSize[ 5 ] / 1.75 Of oMainWnd Pixel

	//Campos que podem ser editados
	If lDbClick
		aCpos := { "TY9_OBSCON", "TY9_QTDHRS" }
	Else
		aCpos := { "TY9_DTCONS", "TY9_HRCONS", "TY9_OBSCON", "TY9_QTDHRS" }
	EndIf

	//Campos que não vao ser mostrados no browse
	aNao := { "TY9_CODUSU", "TY9_NOMUSU", "TY9_NOMOTI", "TY9_TIPOAG" }

	aChoice  := NGCAMPNSX3( "TY9", aNao )

	oPnlPai := TPanel():New( 00, 00, , oDlgTY9, , , , , , 0, 0, .F., .F. )
	oPnlPai:Align   := CONTROL_ALIGN_ALLCLIENT
	oEnchoice:= MsMGet():New( "TY9", , 3, , , , aChoice, { 0, 0, aSize[ 6 ] / 6, ( aSize[ 5 ] / 3.5 ) + 10  }, aCpos, , , , , oPnlPai, , , , , , , , , , .F. )

	//Ativacao do Dialog
	Activate MsDialog oDlgTY9 On Init EnchoiceBar( oDlgTY9,;
									{ || nOpcao := 1, IIf( MDT076TDOK( "TY9", cCalend, , cAliasAte, .T. ), oDlgTY9:End(), Nil ) },; //Ok
									{ || nOpcao := 0, oDlgTY9:End() } )CENTERED //Cancel

	If nOpcao == 1
		fChangeDay( oCalend, nIdNDate, nPosNDate, oTPanel, oHorario, cAliasAte, .F., "TY9" )
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076TDOK
Função para verificar validações antes de incluir

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 15/04/2016

@param cAliasSrc	, Caracter	, Alias posicionada no momento. TY9 ou TMJ.
@param [cCalendario], Caracter	, Calendario do usuário - MDTA075
@param lValid		, Logico	, Indica se devera fazer algumas validação.
@param cAliasAte	, Caracter	, TRB do Atendimento.
@param lButton		, Logico	, Indica se foi clicado no botão de Reservar/Bloquear.
@sample MDT076TDOK( "TMJ", cCalendario, .T., cAliasAte )

@return Lógico, Indica se todas validações estão corretas.
/*/
//---------------------------------------------------------------------
Function MDT076TDOK( cAliasSrc, cCalendario, lValid, cAliasAte, lButton )

	Local lRet 			:= .T.
	Local cPrefix 		:= "M->" + PrefixoCPO( cAliasSrc )
	Local cMotivo		:= &( cPrefix + "_MOTIVO" )

	Private cHrConsInf 	:= &( cPrefix + "_HRCONS" )
	Private cHrQntdInf 	:= &( cPrefix + "_QTDHRS" )
	Private dDtConsVal 	:= &( cPrefix + "_DTCONS" )	//data da consulta atual
	Private cMedico 	:= &( cPrefix + "_CODUSU" ) // recebe codigo do medico atual

	Default cCalendario	:= ""
	Default lValid		:= .F.
	Default lButton 	:= .F.

	//verifica se campo de quantidade de horas não foi criado
	If cAliasSrc == "TMJ"
		If ValType( cHrQntdInf ) == "U"
			cHrQntdInf := "00:05" //recebe o tempo minimo padrao
		EndIf
	EndIf

	//se quantidade de horas estiver vazio, deverá considerar o tempo da TML
	If Len( AllTrim( cHrQntdInf ) ) != 5
		cHrQntdInf := fVldQtdHrs( cMedico )
	EndIf

	If lRet
		If Len( AllTrim( cHrConsInf ) ) != 5 .Or. Empty( dDtConsVal )
			ShowHelpDlg( STR0003, { STR0061 }, 2, { STR0062 }, 2 ) //"Atenção"###"Possui campos obrigatórios vazios."###"Favor verificar os campos e preencher."
			lRet := .F.
		EndIf
	EndIf

	//função para verificar se horario vai ficar entre um dia e outro, por exemplo, das 23:50 as 00:10.
	If lRet
		lRet := MDT076DIA( cHrConsInf, cHrQntdInf )
	EndIf

	//verifica se algum horario vai ficar fora do turno do médico
	If lRet
		lRet := MDT076BLOQ( cHrConsInf, cHrQntdInf, dDtConsVal, , cCalendario )
	EndIf

	//função para verificar horario informado
	If lRet
		lRet := MDT076HOR( cHrConsInf, cHrQntdInf )
	EndIf

	If lRet
		dbSelectArea( "TML" )
		dbSetOrder( 1 ) //TML_FILIAL+TML_CODUSU
		If dbSeek( xFilial( "TML" ) + cMedico )
			If Len( AllTrim( TML->TML_QTDHRS ) ) != 5
				If Empty( cHrQntdInf )
					If Empty( TML->TML_QTDHRS )
						ShowHelpDlg( STR0003, { STR0059 }, 2, { STR0060 }, 2 ) //"Atenção"###"O campo de Quantidade Horas está vazio."###"Favor preencher o campo."
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If lRet
		If cAliasSrc == "TMJ"
			If Empty( &( cPrefix + "_NUMFIC" ) ) .Or. Empty( cMotivo ) .Or.;
					Empty( dDtConsVal ) .Or. Empty( cHrConsInf )
				lRet := .F.
			EndIf
		EndIf
		If !lRet
			ShowHelpDlg( STR0003, { STR0061 }, 2, { STR0062 }, 2 ) //"Atenção"###"Possui campos obrigatórios vazios."###"Favor verificar os campos e preencher."
		EndIf

	EndIf

	//---------------------
	//lButton
	//Condição para verificar se está sendo incluso uma Reserva/Bloqueio sobre outra Reserva/Bloqueio.
	//---------------------
	If lValid .Or. lButton
		//verifica se possui Reserva ou Bloqueio no horario
		If lRet
			dbSelectArea( "TY9" )
			dbSetOrder( 1 ) //TMJ_FILIAL+TMJ_CODUSU+DTOS(TMJ_DTCONS)+TMJ_HRCONS
			If dbSeek( xFilial( "TY9" ) + cMedico + DToS( dDtConsVal ) + cHrConsInf )
				ShowHelpDlg( STR0003, { STR0063 }, 2,; //"Atenção"###"Já possui Reserva ou Bloqueio nesse horário."
							 { STR0064 }, 2 )         //"Favor informar um horário disponível."
				lRet := .F.
			EndIf
		EndIf
	EndIf

	//devera excluir a TY9, pois a mesma esta sendo substituida pela TMJ
	If lRet .And. !lValid
		dbSelectArea( "TY9" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "TY9" ) + cMedico + DtoS( dDtConsVal ) + cHrConsInf )

			RecLock( "TY9", .F. )
				DbDelete()
			MsUnlock( "TY9" )

			//verifica se esta sendo feito o agendamento sobre uma TY9
			//pois devera deletar da TRB
			If Select( cAliasAte ) > 0
				dbSelectArea( cAliasAte )
				dbSetOrder( 4 )
				If dbSeek( cMedico + DtoS( dDtConsVal ) + cHrConsInf )
					RecLock( cAliasAte, .F. )
						( cAliasAte )->( dbDelete() )
					( cAliasAte )->( MsUnLock() )
				EndIf
			EndIf
		EndIf
	EndIf

	//Verifica horarios agendados
	If lRet
		lRet := MDT076INT( cAliasSrc, .F., lButton )//Chama função para verificar possiveis interferencias de horarios
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076TRAN
Função para atualizar shape ao incluir algum registro na transferencia

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 16/05/2016

@param cCodMed	, Caracter	, Código do médico.
@param cFicha	, Caracter	, Código da ficha médica.
@param dDtCons	, Data		, Data da Consulta.
@param cHrCons	, Caracter	, Horário da Consulta.
@param cMat		, Caracter	, Número da Matricula.
@param oHorario	, Objeto	, Objeto do TNGAG
@param cQtHrCons, Caracter	, Quantidade de horas da Consulta.
@param oCalend	, Objeto	, Objeto do MsCalend
@param nIdNDate	, Numerico	, Id da data do calendário
@param nPosNDate, Numerico
@param oPanelShp, Objeto	, Objeto do TPaintPanel

@sample MDT076TRAN( "0000014", "000012" , 25/10/2011, "15:15", "015441", oHorario, "00:10", oCalend , 548 , nPosNDate , oPanelShp )

@return Lógico, Sempre verdadeiro.
/*/
//---------------------------------------------------------------------
Function MDT076TRAN( cCodMed, cFicha, dDtCons, cHrCons, cMat, oHorario, cQtHrCons, oCalend, nIdNDate, nPosNDate, oPanelShp )

	Local nCntShp

	//Atualiza shape
	//Remove informações do shape
	//-----------------------------------------------------------------------------
	cHrSrc 	:= TMJ->TMJ_HRCONS//__cHrCons
	nIdHr 	:= oHorario:GetIdHora( cHrSrc )
	//cFicha	:= AllTrim( oHorario:GetTextRef( cValToChar( nIdHr ) ) )
	cNomPac	:= NGSeek( "TM0", ( cAliasAte )->NUMFIC, 1, "TM0_NOMFIC" )
	cHora 	:= oHorario:GetHoraRef( cValToChar( nIdHr ) )
	fBalaoAjd( nIdHr, cNomPac, cHora, "TMJ", oHorario )

	dbSelectArea( cAliasAte )
	dbSetOrder( 4 )
	If dbSeek( __cMedico + DtoS( __dDtCons ) + __cHrCons )
		RecLock( cAliasAte, .F. )
			( cAliasAte )->CODUSU 	:= cCodMed
			( cAliasAte )->DTCONS 	:= dDtCons
			( cAliasAte )->HRCONS 	:= cHrCons
		( cAliasAte )->( MsUnLock() )
	EndIf

	//Atualiza tela para o Médico que receber o funcionário
	//-----------------------------------------------------------
	aMedicos := {}
	fGetAgenda( cAliasMed, @aMedicos )
	nNewCod := aScan( aMedicos, { | x | x[ 1 ] == __cMedico } ) //Deixa posicionado no médico atual
	//--------------------
	nId		:= Val( SumId( @nId ) )
	ChangeMed( 0, @nId, aMedicos, @nPosMed, oPanelShp, @nIdNMed, , oCalend, , , , , , nNewCod )
	//--------------------

	//necessario chamar a função para recriar os shapes com as informações corretas
	fChangeDay( oCalend, nIdNDate, nPosNDate, oPanelShp, oHorario, cAliasAte, .F., "TMJ" )
	//-----------------------------------------------------------

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076NEW
Função para indicar o que deseja fazer com o horario atual.

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 11/10/2016

@param cAliasSrc, Caracter	, Verifica de qual tabela esta considerando - TMJ ou TY9
@param cHrIniAtu, Caracter	, Horario inicial da consulta (atual)
@param cQntHrAtu, Caracter	, Quantidade de horas da consulta (atual)
@param cTmpCons , Caracter	, Tempo total da consulta (atual)
@param dDtCons	, Data		, Data da consulta (atual)
@param cHrIniCons , Caracter, Horario inicial da consulta selecionada.

@sample MDT076NEW( "TY9" , "20:30", "00:15", "20:45", 10/10/2010 )

@return Lógico, Indica se devera alterar algum horario.
/*/
//---------------------------------------------------------------------
Function MDT076NEW( cAliasSrc, cHrIniAtu, cQntHrAtu, cTmpCons, dDtCons, cHrIniCons )

	Local cText 	:= ""
	Local lInclui 	:= .T.
	Local lRet 		:= .T.

	cText := STR0065 + CRLF //"Horário da consulta atual está interferindo em outra consulta. "
	cText += STR0066 + CRLF //"O que deseja fazer: "
	cText += STR0068 + CRLF //"- Próximo para Duração: Posterga a consulta para o primeiro horário livre encontrado com a mesma quantidade horas da consulta;"
	cText += STR0067 + CRLF //"- Próximo Disponível: Posterga a consulta para o primeiro horário livre encontrado, independente se a duração da consulta é igual ou diferente do horário disponível;"
	cText += STR0069 + CRLF //"- Manter Horário: Mantém o horário informado, reduzindo o tempo de atendimento até o horário conflitante;"
	cText += STR0070 //"- Postergar Todos: Mantém o horário informado no atendimento e os horários que são posteriores serão reagendados automaticamente."
	nRet := Aviso( STR0001, cText, { STR0071, STR0072, STR0073, STR0074, STR0015 } )//"Agenda Médica Mod. 2"###"Próximo para Duração" ###"Próximo Disponível" ###"Manter Horário" ###"Postergar Todos"###"Voltar"

	// 1 - Próximo para Duração
	// 2 - Próximo Disponivel
	// 3 - Manter Horário
	// 4 - Postergar Todos
	// 5 - Voltar

	If nRet == 5
		Return .F.
	Else
		lRet := MDT076ENC( .T., cAliasSrc, cHrIniAtu, cQntHrAtu, cTmpCons, dDtCons, nRet, , cHrIniCons )
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076ATE
Função para realizar encaixe de Atendimento.

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 09/06/2016

@param cMedico	, Caracter	, Código do Médico
@param dDiaAtu	, Data		, Dia do atendimento
@param cHora	, Caracter	, Horário selecionado.
@param cAliasAte, Caracter	, TRB do Atendimento.
@param oHorario	, Objeto	, Objeto do TNGAG
@param oCalend	, Objeto	, Objeto do MsCalend
@param nIdNDate	, Numerico	, Id da data do calendário
@param nPosNDate, Numerico
@param oTPanel	, Objeto	, Objeto do TPaintPanel

@sample MDT076ATE( "000154", 26/03/2005, "16:35", oPanel , cAliasAte, oHorario, oCalend , 84 , nPosNDate, oTPanel )

@return Lógico, Sempre verdadeiro.
/*/
//---------------------------------------------------------------------
Function MDT076ATE( cMedico, dDiaAtu, cHora, cAliasAte, oHorario, oCalend, nIdNDate, nPosNDate, oTPanel )

	Local aNao	:= {}
	Local aSize	:= MsAdvSize( , .F., 430 )
	Local nOpca := 0
	Local nOpcx := 3

	//Atribui valor as variaveis de tela
	dbSelectArea( "TMJ" )
	RegToMemory( "TMJ", .T., , .F. )

	//Atribui valor para memória
	//---------------------------------------
	M->TMJ_CODUSU	:= cMedico
	M->TMJ_NOMUSU	:= Posicione( "TMK", 1, xFilial( "TMK" ) + cMedico, "TMK_NOMUSU" )
	M->TMJ_DTCONS	:= dDiaAtu //STOD( Space(TAMSX3( "TMJ_DTCONS" )[1] ) )
	M->TMJ_HRCONS	:= cHora
	//---------------------------------------

	//Monta a Tela
	Define MsDialog oDlgENC Title STR0075 From aSize[ 7 ], 0 To aSize[ 6 ], aSize[ 5 ] Of oMainWnd Pixel //"Encaixe de Atendimento"

		//Campos que podem ser editados
		aCpos := { "TMJ_NUMFIC", "TMJ_HRCONS", "TMJ_EXAME", "TMJ_MOTIVO", "TMJ_OBSCON" }
		aAdd( aCpos, "TMJ_QTDHRS" )

		//Campos que não vao ser mostrados no browse
		aNao := { "TMJ_MAT", "TMJ_CONVOC", "TMJ_DTPROG", "TMJ_DTATEN", "TMJ_PCMSO", "TMJ_ATEENF", "TMJ_CODENF",;
				 "TMJ_INDENF", "TMJ_DTENFE", "TMJ_HRENFE", "TMJ_DESENF", "TMJ_HRCHGD", "TMJ_HRSAID" }

		aChoice  := NGCAMPNSX3( "TMJ", aNao )

		oPnlPai := TPanel():New( 00, 00, , oDlgENC, , , , , , 0, 0, .F., .F. )
			oPnlPai:Align   := CONTROL_ALIGN_ALLCLIENT
			oEnchoice:= MsMGet():New( "TMJ", , 3, , , , aChoice, { 0, 0, aSize[ 6 ]/2, aSize[ 5 ]/2 }, aCpos, , , , , oPnlPai )

	//Ativacao do Dialog
	ACTIVATE MSDIALOG oDlgENC ON INIT EnchoiceBar(oDlgENC,;
										 	 { || nOpca := 1, IIf( MDT076VLEN( cMedico, dDiaAtu, cHora, M->TMJ_HRCONS, M->TMJ_QTDHRS ), oDlgENC:End(), Nil ) },;//Confirmar
											 { || nOpca := 0, oDlgENC:End() } ) CENTERED //Cancelar

	If nOpca == 1

		//deve incluir na base antes de atualizar tela
		MDT076INC( "TMJ", M->TMJ_HRCONS, M->TMJ_QTDHRS )

		//Atualiza shape
		fChangeDay( oCalend, nIdNDate, nPosNDate, oTPanel, oHorario, cAliasAte, .F., "TMJ" )

		//deverá receber vazio para proxima inclusão nao ficar com os valores da anterior
		cNewHrIni := ""
		cNewQtHour := ""
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076VLEN
Função para validar o encaixe.

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 09/06/2016

@param cMedico	, Caracter	, Código do Médico
@param dDiaAtu	, Data		, Dia do atendimento
@param cHora	, Caracter	, Horário selecionado.
@param cHrAtu	, Caracter	, Horário atual.
@Param cQntHrAtu, Caracter	, Quantidade de horas atual.
@param cAliasAte, Caracter	, TRB do Atendimento.

@sample MDT076VLEN( "00045", 12/11/2001, "12:35", "12:40", "00:10", cAliasAte )

@return Lógico, Indica se devera alterar algum horario.
/*/
//---------------------------------------------------------------------
Function MDT076VLEN( cMedico, dDiaAtu, cHora, cHrAtu, cQntHrAtu, lTransf )

	Local lRet := .T.

	//se campo de quantidade de horas estiver vazio recebe da Agenda
	If Empty( cQntHrAtu )
		cQntHrAtu := fVldQtdHrs( cMedico )
	EndIf

	//Se o atendimento possuir atendimento, ñ será possivel realizar o encaixe
	dbSelectArea( "TMT" )
	dbSetOrder( 2 ) //TMT_FILIAL+TMT_CODUSU+DTOS(TMT_DTCONS)+TMT_HRCONS
	If dbSeek( xFilial( "TMT" ) + cMedico + DTOS( dDiaAtu ) + cHora )
		ShowHelpDlg( STR0003, { STR0122 }, 2,; //"Atenção"###"Não é possível realizar o encaixe neste horário, pois já possui atendimento."
					 { STR0123  }, 2 )         //"Favor selecionar outro horário."
		lRet := .F.
	EndIf

	If lRet

		cHoraFim := MTOH( HTOM( cHrAtu ) + HTOM( cQntHrAtu ) )

		cText := STR0076 + CRLF //"Encaixe de horário. "
		cText += STR0066 + CRLF //"O que deseja fazer: "
		cText += STR0068 + CRLF //"- Próximo para Duração: Posterga a consulta para o primeiro horário livre encontrado com a mesma quantidade horas da consulta;"
		cText += STR0067 + CRLF //"- Próximo Disponível: Posterga a consulta para o primeiro horário livre encontrado, independente se a duração da consulta é igual ou diferente do horário disponível;"
		cText += STR0069 + CRLF //"- Manter Horário: Mantém o horário informado, reduzindo o tempo de atendimento até o horário conflitante;"
		cText += STR0070 //"- Postergar Todos: Mantém o horário informado no atendimento e os horários que são posteriores serão reagendados automaticamente."
		nRet := Aviso( STR0001, cText, { STR0071, STR0072, STR0073, STR0074, STR0015 } ) //"Agenda Médica Mod. 2"###"Próximo para Duração" ###"Próximo Disponível" ###"Manter Horário" ###"Postergar Todos"###"Voltar"

		// 1 - Próximo para Duração
		// 2 - Próximo Disponivel
		// 3 - Manter Horário
		// 4 - Postergar Todos
		// 5 - Voltar

		If nRet == 5
			Return .F.
		Else
			lRet := MDT076ENC( .F., "TMJ", cHrAtu, cQntHrAtu, cHoraFim, dDiaAtu, nRet, lTransf, cHora )
		EndIf

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076ENC
Função para realizar encaixe.

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 11/10/2016

@param lInclusao	, Logico	, Indica se é inclusão(.T.) ou encaixe(.F.) de registro
@param cAliasVal	, Caracter	, Alias posicionado no momento
@param cHoraIni		, Caracter	, Horário inicial da consulta nova.
@Param cQntHr		, Caracter	, Quantidade de horas atual.
@Param cHoraFim		, Caracter	, Horario final da consulta nova.
@param dDiaAtu		, Data		, Dia do atendimento.
@param nBotSel		, Numerico	, Botão selecionado.
		1- Proximo para duração, 2-Proximo Disponivel, 3- Manter Horário, 4-Postergar Todos.
@param lTransf  , Logico	, Indica se é transferencia(.T.).
@param cHora	, Caracter	, Horário selecionado.

@sample MDT076ENC( .T., "TMJ", "08:10", "00:10", "08:20", 11/10/2016, 1 )

@return Lógico, Indica se devera alterar algum horario.
/*/
//---------------------------------------------------------------------
Function MDT076ENC( lInclusao, cAliasVal, cHoraIni, cQntHr, cHoraFim, dDiaAtu, nBotSel, lTransf, cHora )

	Local cAliasENC := GetNextAlias()
	Local lRet := .T.

	Default cHora := "" //Utilizada somente no encaixe
	Default lTransf := .F.

	cTabTMJ := RetSqlName( "TMJ" )
	cTabTY9 := RetSqlName( "TY9" )

	//seleciona todos horarios do dia e verifica a operação para pegar somente os horarios que interferem
	cQuery := " SELECT TMJ.TMJ_CODUSU AS CODUSU, TMJ.TMJ_DTCONS AS DTCONS, TMJ.TMJ_HRCONS AS HRCONS, TMJ.TMJ_QTDHRS AS QTDHRS "
	cQuery += "FROM " + cTabTMJ + " TMJ "
	If lInclusao .And. !IsInCallStack( "MDTA075" )//Inclusão
		cQuery += "WHERE TMJ.TMJ_CODUSU = '"+ cMedico +"' AND TMJ.TMJ_DTCONS = '"+ DTOS( dDiaAtu ) + "' AND TMJ.TMJ_HRCONS > '" + cHoraIni
	Else //Encaixe ou Transferencia
		cQuery += "WHERE TMJ.TMJ_CODUSU = '"+ cMedico +"' AND TMJ.TMJ_DTCONS = '"+ DTOS( dDiaAtu ) + "' AND TMJ.TMJ_HRCONS >= '" + cHora
	EndIf
	cQuery += "' AND "
	cQuery += 		"TMJ.D_E_L_E_T_ <> '*'"

	cQuery += " UNION"

	cQuery += " SELECT TY9.TY9_CODUSU AS CODUSU, TY9.TY9_DTCONS AS DTCONS, TY9.TY9_HRCONS AS HRCONS, TY9.TY9_QTDHRS AS QTDHRS "
	cQuery += "FROM " + cTabTY9 + " TY9 "
	If lInclusao .And. !IsInCallStack( "MDTA075" )//Inclusão
		cQuery += "WHERE TY9.TY9_CODUSU = '"+ cMedico +"' AND TY9.TY9_DTCONS = '"+ DTOS( dDiaAtu ) + "' AND TY9.TY9_HRCONS > '" + cHoraIni
	Else //Encaixe ou Transferencia
		cQuery += "WHERE TY9.TY9_CODUSU = '"+ cMedico +"' AND TY9.TY9_DTCONS = '"+ DTOS( dDiaAtu ) + "' AND TY9.TY9_HRCONS >= '" + cHora
	EndIf
	cQuery += "' AND "
	cQuery += 		"TY9.D_E_L_E_T_ <> '*'"
	cQuery := ChangeQuery( cQuery )
	MPSysOpenQuery( cQuery, cAliasENC )

	If nBotSel == 1 //Próximo para duração
		If lTransf
			lRet := MDT076PDUI( lInclusao, cAliasVal, cHoraIni, cQntHr, cHoraFim, dDiaAtu, cAliasENC, cHora, lTransf )
		Else
			lRet := MDT076PDU( lInclusao, cAliasVal, cHoraIni, cQntHr, cHoraFim, dDiaAtu, cAliasENC, cHora )
		EndIf
	ElseIf nBotSel == 2 //Próximo Disponivel
		If lTransf
			lRet := MDT076PDII( lInclusao, cAliasVal, cHoraIni, cQntHr, cHoraFim, dDiaAtu, cAliasENC, cHora, lTransf )
		Else
			lRet := MDT076PDI( lInclusao, cAliasVal, cHoraIni, cQntHr, cHoraFim, dDiaAtu, cAliasENC )
		EndIf
	ElseIf nBotSel == 3 //Manter Horário
		If lTransf
			lRet := MDT076MTHI( lInclusao, cAliasVal, cHoraIni, cQntHr, cHoraFim, dDiaAtu, cAliasENC, cHora, lTransf )
		Else
			lRet := MDT076MTH( lInclusao, cAliasVal, cHoraIni, cQntHr, cHoraFim, dDiaAtu, cAliasENC, cHora )
		EndIf
	ElseIf nBotSel == 4 //Postergar Todos
		If lTransf
			lRet := MDT076PTTI( lInclusao, cAliasVal, cHoraIni, cQntHr, cHoraFim, dDiaAtu, cAliasENC, cHora, lTransf )
		Else
			lRet := MDT076PTT( lInclusao, cAliasVal, cHoraIni, cQntHr, cHoraFim, dDiaAtu, cAliasENC, cHora )
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076ATU
Função para gravar os valores corretos caso a TMJ for alterada.

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 28/06/2016

@param cMedico	, Caracter	, Código do Médico
@param cNumFic	, Caracter	, Numero da Ficha selecionada
@param dDtCons	, Data		, Data da consulta (atual)
@param cHrCons	, Caracter	, Horário da Consulta.
@Param cNewHr	, Caracter	, Novo horário que vai ser adicionado no horario da consulta

@sample MDT076ATU( "65487", "44422" , 20/10/2013, "18:20", "18:40" )

@return Nulo, Sempre nulo.
/*/
//---------------------------------------------------------------------
Function MDT076ATU( cMedico, cNumFic, dDtCons, cHrCons, cNewHr )

	dbSelectArea( "TMT" )
	dbSetOrder( 2 ) //TMT_FILIAL+TMT_CODUSU+DTOS(TMT_DTCONS)+TMT_HRCONS
	If dbSeek( xFilial( "TMT" ) + cMedico + DTOS( dDtCons ) + cHrCons )
		RecLock( "TMT", .F. )
		TMT->TMT_HRCONS := cNewHr
		Msunlock( "TMT" )
	EndIf
	dbSelectArea( "TM2" )
	dbSetOrder( 1 ) //TM2_FILIAL+TM2_NUMFIC+DTOS(TM2_DTCONS)+TM2_HRCONS+TM2_CODMED
	If dbSeek( xFilial( "TM2" ) + cNumFic + DTOS( dDtCons ) + cHrCons )
		RecLock( "TM2", .F. )
		TM2->TM2_HRCONS := cNewHr
		Msunlock( "TM2" )
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fValidMed
Função para realizar as validações de inclusão e exclusão do médico.

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 28/06/2016

@param nOpca, Numerico, Indica o tipo da operação atual

@sample fValidMed( 3 )

@return Logico, Indica se todas validações estão corretas.
/*/
//---------------------------------------------------------------------
Static Function fValidMed( nOpca )

	If nOpca == 3 .Or. nOpca == 4

		If Empty( M->TMK_CODUSU ) .Or. Empty( M->TMK_NOMUSU ) .Or. Empty( M->TMK_DTINIC ) .Or. Empty( M->TMK_SESMT ) .Or. Empty( M->TMK_INDFUN )
			ShowHelpDlg( STR0003, { STR0061 }, 2, { STR0062 }, 2 ) //"Atenção"###"Possui campos obrigatórios vazios."###"Favor verificar os campos e preencher."
			Return .F.
		ElseIf Empty( M->TMK_CALEND )
			ShowHelpDlg( STR0003, { STR0089 }, 2, { STR0090 }, 2 ) //"Atenção"###"O campo de Calendário está vazio."###"Favor informar um Calendário."
			Return .F.
		ElseIf Empty( M->TMK_QTDHRS )
			ShowHelpDlg( STR0003, { STR0059 }, 2, { STR0060 }, 2 ) //"Atenção"###"O campo de Quantidade Horas está vazio." ###"Favor preencher o campo."
			Return .F.
		EndIf

		If !MDT076HOR( , M->TMK_QTDHRS )
			Return .F.
		EndIf

	Else

		dbSelectArea( "TML" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "TML" ) + cMedico )
			dbSelectArea( "TMJ" )
			dbSetOrder( 1 ) //TMJ_FILIAL+TMJ_CODUSU+DTOS(TMJ_DTCONS)+TMJ_HRCONS
			If dbSeek( xFilial( "TMJ" ) + cMedico )

				ShowHelpDlg( STR0003, { STR0093 }, 3,; //"Atenção"###"Existe Agendamentos cadastrados para este Atendente."
							 { STR0094 }, 3 )          //"Excluir os Agendamentos para permitir excluir o atendente."
				Return .F.
			EndIf
		EndIf
		dbSelectArea( "TMK" )
		dbSetOrder( 1 )
		dbSeek( xFilial( "TMK" ) + cMedico )

	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fBuscVal
Função para realizar a busca do Médico ou ficha médica

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 29/06/2016

@param cCodPesq		, Caracter	, Indica o código para pesquisar
@param oHorario		, Objeto	, Objeto do TNGAG
@param oCalend		, Objeto	, Objeto do MsCalend
@param cAliasAte	, Caracter	, TRB do Atendimento.
@param nIdNDate		, Numerico	, Id da data do calendário
@param nPosNDate	, Numerico
@param aMedicos		, Array		, Array dos Médicos
@param oTPanel		, Objeto	, Objeto do TPaintPanel
@param nIdNMed		, Numerico	, Id do Médico
@param nPosMed		, Numerico	, Posição do Médico
@param nId			, Numerico	, Último ID utilizado

@sample fBuscVal( "22215", oHorario, oCalend, cAliasAte, nIdNDate , nPosNDate, aMedicos, oTPanel, 10 , 5 , 4 )

@return Logico, Indica se todas validações estão corretas.
/*/
//---------------------------------------------------------------------
Static Function fBuscVal( cCodPesq, oHorario, oCalend, cAliasAte, nIdNDate, nPosNDate, aMedicos, oTPanel, nIdNMed, nPosMed, nId )

	If Empty( cCodPesq )
		ShowHelpDlg( STR0003, { STR0095 }, 3,; //"Atenção"###"O campo para informar o código para busca está vazio."
					 { STR0096 }, 3 )          //"Favor informar um código para ser realizado a busca."
		Return .F.
	EndIf

	nNewCod := aScan( aMedicos, { | x | x[ 1 ] == cCodPesq } )
	//--------------------
	nId		:= Val( SumId( @nId ) )
	ChangeMed( 0, @nId, aMedicos, @nPosMed, oTPanel, @nIdNMed, , , , , , nNewCod )

	fChangeDay( oCalend, nIdNDate, nPosNDate, oTPanel, oHorario, cAliasAte )
	//--------------------

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fValidTMK
Função para fazer validação ao informar médico na busca

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 29/06/2016

@param cMedico, Caracter, Código do Médico

@sample fValidTMK( "000045" )

@return Logico, Indica se todas validações estão corretas.
/*/
//---------------------------------------------------------------------
Static Function fValidTMK( cMedico )

	Local dDataTerm := CTOD( "  /  /    " )

	If !Empty( cMedico )

		If !ExistCpo( "TMK", cMedico )
			Return .F.
		EndIf
		dbSelectArea( "TMK" )
		dbSetOrder( 1 )// TMK_FILIAL+TMK_CODUSU
		dbSeek( TML->TML_FILIAL + cMedico )

		dDataTerm := TMK->TMK_DTTERM

		If Empty( dDataTerm ) .Or. dDataTerm > dDataBase
			dbSelectArea( "TML" )
			dbSetOrder( 1 )
			If !dbSeek( xFilial( "TML" ) + cMedico )
				ShowHelpDlg( STR0003, { STR0097 }, 3,; //"Atenção"###"O médico informado não possui agenda."
							{ STR0098 }, 3 )          //"Favor informar um médico que possua agenda médica."
				Return .F.
			EndIf
			Return .T.
		Else
			Help( ' ', 1, STR0003, , STR0145, 2, 0 )//"O médico informado está com a Data de Término preenchida."
			Return .F.
		EndIf
	EndIf
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fVldQtdHrs
Função para retornar a quantidade de horas.

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 30/06/2016

@param cCodMed, Caracter, Código do Médico

@sample fVldQtdHrs( "444875" )

@return Caracter, Quantidade de tempo para consulta.
/*/
//---------------------------------------------------------------------
Static Function fVldQtdHrs( cCodMed )

	dbSelectArea( "TML" )
	dbSetOrder( 1 ) //TML_FILIAL+TML_CODUSU
	If dbSeek( xFilial( "TML" ) + cCodMed )
		cNewQtdHrs := TML->TML_QTDHRS
	EndIf

Return cNewQtdHrs

//---------------------------------------------------------------------
/*/{Protheus.doc} fBalaoAjd
Função para mostrar o balão de ajuda ao posicionar o mouse sobre algum agendamento.

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 01/07/2016

@param nIdHrBal		, Numerico	, Id do shape
@param cDescriBal	, Caracter	, Descrição que vai ser apresentada.
@param cHoraBal		, Caracter	, Horario que vai ser apresentado
@param cAliasBal	, Caracter	, Indica qual alias esta posicionada no momento
@param oHorario		, Objeto	, Objeto do TNGAG

@sample fBalaoAjd( 114, "Nome", "10:10", "TMJ", oHorario )

@return Logico, Sempre verdadeiro.
/*/
//---------------------------------------------------------------------
Static Function fBalaoAjd( nIdHrBal, cDescriBal, cHoraBal, cAliasBal, oHorario )

	Local cTxtHtmlIni := "<b>"
	Local cTxtHtmlFim := "</b>"

	If cAliasBal == "TMJ"
		oHorario:SetToolTipShp( nIdHrBal, cTxtHtmlIni + STR0099 + cTxtHtmlFim + cDescriBal + CRLF + STR0100 + cHoraBal ) //"Paciente: "###"Horário: "
	Else
		oHorario:SetToolTipShp( nIdHrBal, cTxtHtmlIni + STR0101 + cTxtHtmlFim + cDescriBal + CRLF + STR0100 + cHoraBal ) // "Observação: "###"Horário: "
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076HOR()
Função para verificar se horario informado termina em 0 ou 5.

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 11/07/2016

@param cHoraInf	, Caracter, Horario informado
@param cQntHrInf, Caracter, Quantidade de horas informado.

@sample MDT076HOR( "11:20", "00:10" )

@return Logico, Indica se todas validações estão corretas.

Obs: Fontes que utilizam a função
*MDTA076
*MDTA195
*MDTA160
*MDTA075 - Campo TML_QTDHRS
/*/
//---------------------------------------------------------------------
Function MDT076HOR( cHoraInf, cQntHrInf )

	Local lRet	:= .T.

	Default cHoraInf 	:= ""
	Default cQntHrInf 	:= ""

	If !Empty( cHoraInf )
		If ( HTOM( cHoraInf ) % 5 ) != 0
			ShowHelpDlg( STR0003, { STR0102 }, 2,; //"Atenção"###"Horário da consulta inválido."
						 { STR0103 }, 2 )          //"Favor informar um horário válido, sendo necessário terminar em 0 ou 5."
			lRet := .F.
		EndIf
	EndIf
	If !Empty( cQntHrInf )
		If lRet .And. ( HTOM( cQntHrInf ) % 5 ) != 0
			ShowHelpDlg( STR0003, { STR0104 }, 2,; //"Atenção"###"Tempo de consulta inválido."
						 { STR0103 }, 2 )         //"Favor informar um horário válido, sendo necessário terminar em 0 ou 5."
			lRet := .F.
		ElseIf cQntHrInf == "00:00"
			ShowHelpDlg( STR0003, { STR0128 }, 2,; //"Atenção"###"O tempo de consulta não pode estar zerado."
						 { STR0129 }, 2 )          //"Favor informar uma duração."
			lRet := .F.
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076ATEN()
Função para verificar se possui algum agendamento
com atendimento.

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 18/07/2016

@param aAtend	, Array		, Array com os Agendamento
@param cMedico	, Caracter	, Médico posicionado
@param dDiaAtu	, Data		, Dia selecionado para consulta

@sample MDT076ATEN( aAtend, "000147", 23/12/2011 )

@return Logico, Sempre verdadeiro.
/*/
//---------------------------------------------------------------------
Function MDT076ATEN( aAtend, cMedico, dDiaAtu )

	Local nCont := 0

	For nCont := 1 To Len( aAtend )

		dbSelectArea( "TMT" )
		dbSetOrder( 2 ) //TMT_FILIAL+TMT_CODUSU+DTOS(TMT_DTCONS)+TMT_HRCONS
		If dbSeek( xFilial( "TMT" ) + cMedico + DTOS( dDiaAtu ) + aAtend[ nCont, 4 ] )
			Return .F.
		EndIf

	Next nCont

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076DIA()
Função para verificar se o tempo de consulta
vai de um dia até o outro.

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 20/07/2016

@param cHrConsDia	, Caracter	, Horário da consulta
@param cHrQntdDia	, Caracter	, Quantidade de tempo da consulta
@param aAtend		, Array		, Array com os Agendamentos.

@sample MDT076DIA( "16:00", "00:30", aAtend )

@return Logico, Indica se todas validações estão corretas.
/*/
//---------------------------------------------------------------------
Function MDT076DIA( cHrConsDia, cHrQntdDia, aAtend )

	Local nCont	:= 0
	Local lRet	:= .T.
	Local lMsg	:= .F. //Indica se devera apresentar a mensagem

	Default cHrQntdDia := "" //devera deixar recebendo vazio, para ao entrar no MDTA075 nao ocorrer erro
	Default aAtend     := {}

	If Len( aAtend ) > 0

		For nCont := 1 To Len( aAtend )

			cTmpCons := MTOH( HTOM( "23:59" ) - HTOM( aAtend[ nCont, 1 ] ) + 1 )

			//deve somar com a quantidade de horas atual, pois vai ser postergado este tempo
			If cTmpCons < MTOH( HTOM( aAtend[ nCont, 2 ] ) + HTOM( cHrQntdDia ) )
				ShowHelpDlg( STR0003, { STR0105 }, 2,; //"Atenção"###"Possui algum agendamento que vai ter início e término em datas diferentes."
							 { STR0086 }, 2 )          //"Favor alterar o tempo de consulta."
				lRet := .F.
				Exit
			EndIf

		next nCont

	Else
		cTmpCons := MTOH( HTOM( "23:59" ) - HTOM( cHrConsDia ) + 1 )
		If cTmpCons < cHrQntdDia
			ShowHelpDlg( STR0003, { STR0085 }, 2,; //"Atenção"###"Uma consulta não pode começar em um dia e terminar em outro."
						 { STR0086 }, 2 )          //"Favor alterar o tempo de consulta."
			lRet := .F.
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076BLOQ()
Função para verificar se algum atendimento vai ficar fora do turno do médico.

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 27/07/2016

@param cHrConsBlo	, Caracter	, Horário da consulta
@param cQntHrBlo	, Caracter	, Quantidade de tempo para consulta
@param dDtConsBlo	, Data		, Data da consulta
@param aAtendBloq	, Array		, Array com os horarios que vao ser alterados
@param cCalendario	, Caracter	, Calendario do usuário - MDTA075

@sample MDT076BLOQ( "08:15", "00:15", 20/10/2010, aAtendBloq, cCalendario )

@return Logico, Indica se todas validações estão corretas.
/*/
//---------------------------------------------------------------------
Function MDT076BLOQ( cHrConsBlo, cQntHrBlo, dDtConsBlo, aAtendBloq, cCalendario )

	Local aHrTrab	:= {}
	Local cHrIniBlo	:= ""
	Local lMnsgm	:= .T. //indica se informa que horario esta fora da agenda
	Local lRet		:= .T.
	Local lValid	:= .F.
	Local nCont		:= 0

	Default aAtendBloq	:= {}
	Default cCalendario	:= ""

	aHrTrab := NGCALENDAH( cCalendario )

	If Len( aAtendBloq ) > 0

		For nCont := 1 To Len( aAtendBloq )

			cHrIniBlo := MTOH( HTOM( aAtendBloq[ nCont, 1 ] ) + HTOM( cQntHrBlo ) )

			//Valida se o horário é um horário válido para o médico
			If aScan( aHrTrab[Dow( dDtConsBlo ), 2], { | x | aAtendBloq[ nCont, 1 ] >= x[ 1 ] .And. aAtendBloq[ nCont, 1 ] <= x[ 2 ] } ) == 0
				lValid := .T.
			//valida se o horario fim do atendimento esta fora do turno do médico
			ElseIf aScan( aHrTrab[Dow( dDtConsBlo ), 2], { | x | cHrIniBlo >= x[ 1 ] .And. cHrIniBlo <= x[ 2 ] } ) == 0
				lValid := .T.
			EndIf

			//Valida se o horário é um horário válido para o médico
			If lValid
				If !MsgYesNo( STR0106 )//"Ao realizar esta operação vai possuir agendamentos fora da agenda do médico, deseja continuar ?"
					lRet := .F.
					Exit
				EndIf
				Exit
			EndIf

		next nCont

	Else

		lValid := .F.
		cHrIniBlo := MTOH( HTOM( cHrConsBlo ) + HTOM( cQntHrBlo ) )
		//Valida se o horário é um horário válido para o médico
		If aScan( aHrTrab[Dow( dDtConsBlo ), 2], { | x | cHrConsBlo >= x[ 1 ] .And. cHrConsBlo <= x[ 2 ] } ) == 0
			lValid := .T.
		//valida se o horario fim do atendimento esta fora do turno do médico
		ElseIf aScan( aHrTrab[Dow( dDtConsBlo ), 2], { | x | cHrIniBlo >= x[ 1 ] .And. cHrIniBlo <= x[ 2 ] } ) == 0
			lValid := .T.
		EndIf

		If 	lValid
			//se encontrar algum agendamento no horario
			//não vai mostrar mensagem
			dbSelectArea( "TMJ" )
			dbSetOrder( 1 )
			If dbSeek( xFilial( "TMJ" ) + cMedico + DTOS( dDtConsBlo ) + cHrConsBlo )
				lMnsgm := .F.
			EndIf
			dbSelectArea( "TY9" )
			dbSetOrder( 1 )
			If dbSeek( xFilial( "TY9" ) + cMedico + DTOS( dDtConsBlo ) + cHrConsBlo )
				lMnsgm := .F.
			EndIf

			If lMnsgm
				If !MsgYesNo( STR0107 ) //"Este horário está fora da Agenda do Médico, deseja continuar ?"
					lRet := .F.
				EndIf
			EndIf

		EndIf

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076CHG
Valid do campos TMJ_HRCHGD

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 27/07/2016

@param cHoraChg, Caracter, Horário de chegada.

@sample MDT076CHG( "14:00" )

@return Logico, Indica se todas validações estão corretas.
/*/
//---------------------------------------------------------------------
Function MDT076CHG( cHoraChg )

	Local lRet := .T.

	If IsInCallStack( "MDTA076" )
		If dDiaAtu >= dDataBase
			If cHoraChg > Time()
				ShowHelpDlg( STR0003, { STR0108 }, 2,; //"Atenção"###"O horário de chegada não pode ser maior que o horário atual."
							 { STR0109 }, 2 )          //"Favor informar um horário de chegada menor ou igual o horário atual."
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076CONS
Valid do campos TMJ_HRCONS

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 27/07/2016

@param cHoraCons, Caracter, Horário da cosulta.

@sample MDT076CONS( "13:30" )

@return Logico, Indica se todas validações estão corretas.
/*/
//---------------------------------------------------------------------
Function MDT076CONS( cHoraCons )

	Local lRet := .T.

	If IsInCallStack( "MDTA076" )

		dbSelectArea( "TMJ" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "TMJ" ) + cMedico + DTOS( dDiaAtu ) + cHora )
			cQntHrs := TMJ->TMJ_QTDHRS
			If Len( AllTrim( cQntHrs ) ) != 5
				cQntHrs := fVldQtdHrs( cMedico )
			EndIf
		EndIf

		//verifica se horario para inclusao esta fora do permitido
		If cHoraCons < cHora .Or. cHoraCons > MTOH( HTOM( cHora ) + HTOM( cQntHrs ) )
			ShowHelpDlg( STR0003, { STR0110 }, 2,; //"Atenção"###"Horário não disponível."
						 { STR0111 + cHora + STR0047 + MTOH( HTOM( cHora ) + HTOM( cQntHrs ) ) + STR0088 + "."  }, 2 )//"Favor informar um horário entre: " ###" às "###" horas"
			lRet := .F.
		EndIf
	EndIf

	If lRet
		If cHoraCons == "  :  "
			ShowHelpDlg( STR0003, { STR0130 }, 2,; //"Atenção"###"O horário da consulta não pode estar zerado."
						 { STR0131 }, 2 )          //"Favor Informar um horário"
			lRet := .F.
		Else
			//verifica se horário informado termina em 0 ou 5.
			lRet := MDT076HOR( cHoraCons )
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076QTD
Função para incluir, alterar ou excluir a agenda do médico.

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 02/08/2016

@param nOpcX	, Numerico	, Opção a ser executada no momento.
@param aMedicos	, Array		, Array dos Médicos
@param oTPanel	, Objeto	, Objeto do TPaintPanel
@param oHorario	, Objeto	, Objeto do TNGAG
@param oCalend	, Objeto	, Objeto do MsCalend
@param cAliasAte, Caracter	, TRB do Atendimento.
@param nIdNDate	, Numerico	, Id da data do calendário
@param nPosNDate, Numerico
@param cAliasMed, Caracter	, Alias do Médico(TRB).
@param nIdNMed	, Numerico	, Id do Médico
@param nPosMed	, Numerico	, Posição do Médico
@param nId		, Numerico	, Último ID utilizado
@param oDlg		, Objeto	, Objeto do painel principal.

@sample MDT076QTD()

@return Logico, Indica se todas validações estão corretas.
/*/
//---------------------------------------------------------------------
Function MDT076QTD( nOpcX, aMedicos, oTPanel, oHorario, oCalend, cAliasAte, nIdNDate, nPosNDate, cAliasMed, nIdNMed, nPosMed, nId, oDlg )

	Local lAlter := .F.
	Local nOpca := 0

	dbSelectArea( "TML" )
	dbSetOrder( 1 ) //TML_FILIAL+TML_CODUSU
	dbSeek( xFilial( "TML" ) + cMedico )

	If nOpcX == 3 .Or. nOpcX == 4

		If nOpcX == 3
			//Atribui valor as variaveis de tela
			dbSelectArea( "TML" )
			RegToMemory( "TML", .T., , .F. )
		Else
			//Atribui valor as variaveis de tela
			dbSelectArea( "TML" )
			RegToMemory( "TML", .F., , .F. )
			//Atribui valor para memória
			//---------------------------------------
			M->TML_CODUSU	:= cMedico
			M->TML_NOMUSU 	:= Posicione( "TMK", 1, xFilial( "TMK" ) + cMedico, "TMK_NOMUSU" )
			M->TML_DESCRI 	:= Posicione( "SH7", 1, xFilial( "SH7" ) + TML->TML_CALEND, "H7_DESCRI" )
			//---------------------------------------
		EndIf

		//Monta a Tela
		Define MsDialog oDlgTML Title cCadastro From aSize[ 7 ], 0 To aSize[ 6 ], aSize[ 5 ] Of oMainWnd Pixel //"Atendimento Médico"

			//Campos que podem ser editados
			If nOpcX == 3
				aCpos := { "TML_CODUSU", "TML_CALEND", "TML_QTDHRS" }
			Else
				aCpos := { "TML_QTDHRS" }
			EndIf

			//Campos que não vao ser mostrados no browse
			aNao := { "TML_USERGI" }

			aChoice  := NGCAMPNSX3( "TML", aNao )

			oPnlPai := TPanel():New( 00, 00, , oDlgTML, , , , , , 0, 0, .F., .F. )
				oPnlPai:Align   := CONTROL_ALIGN_ALLCLIENT
				oEnchoice:= MsMGet():New( "TML", , nOpcX, , , , aChoice, { 0, 0, aSize[ 6 ]/2, aSize[ 5 ]/2 }, aCpos, , , , , oPnlPai )

		//Ativacao do Dialog
		ACTIVATE MSDIALOG oDlgTML ON INIT EnchoiceBar( oDlgTML,;
													 { || nOpca := 1, IIf( fValidAgen( M->TML_CODUSU, M->TML_QTDHRS, nOpcX, M->TML_CALEND ), oDlgTML:End(), Nil ) },;//Confirmar
													 { || nOpca := 0, oDlgTML:End() } ) CENTERED //Cancelar

		If nOpca == 1
			If nOpcX == 3
				RecLock( "TML", .T. )
			Else
				RecLock( "TML", .F. )
			EndIf
				TML->TML_FILIAL := xFilial( "TML" )
				TML->TML_CODUSU	:= M->TML_CODUSU
				TML->TML_CALEND	:= M->TML_CALEND
				TML->TML_QTDHRS := M->TML_QTDHRS
			Msunlock( "TML" )
		EndIf

	ElseIf nOpcX == 5 //Exclusão
		dbSelectArea( "TMJ" )
		dbSetOrder( 1 )
		If !dbSeek( xFilial( "TMJ" ) + cMedico )
			If NGCAD01( "TML", TML->( RecNo() ), 5 ) != 1
				Return .F.
			EndIf
		Else
			ShowHelpDlg( STR0003, { STR0093 }, 3,; //"Atenção"###"Existe Agendamentos cadastrados para este Atendente."
						 { STR0115 }, 3 )          //"Excluir os Agendamentos para permitir excluir a Agenda."
			Return .F.
		EndIf
	EndIf

	If nOpcX == 3

		INCLUI := .T.

		//Atualiza os Médicos
		aMedicos := {}
		fGetAgenda( cAliasMed, @aMedicos )
		nNewCod := aScan( aMedicos, { | x | x[ 1 ] == TMK->TMK_CODUSU } )
		//--------------------
		nId		:= Val( SumId( @nId ) )
		ChangeMed( 0, @nId, aMedicos, @nPosMed, oTPanel, @nIdNMed, , , , , , nNewCod )
		//--------------------
		fChangeDay( oCalend, nIdNDate, nPosNDate, oTPanel, oHorario, cAliasAte )

	ElseIf nOpcX == 5 //Exclusão do Médico

		dbSelectArea( cAliasMed )
		RecLock( cAliasMed, .F. )
			( cAliasMed )->( dbDelete() )
		( cAliasMed )->( MsUnLock() )

		//Atualiza os Médicos
		aMedicos := {}
		fGetAgenda( cAliasMed, @aMedicos )

		//se excluir o ultimo médico devera sair da rotina
		If Len( aMedicos ) == 0
			MsgAlert( STR0114, STR0003 ) // ""Não possui mais médicos cadastrados.""###"Atenção"
			oDlg:End()
			Return .F.
		EndIf

		//--------------------
		nId		:= Val( SumId( @nId ) )
		ChangeMed( 0, @nId, aMedicos, @nPosMed, oTPanel, @nIdNMed )
		//--------------------
		fChangeDay( oCalend, nIdNDate, nPosNDate, oTPanel, oHorario, cAliasAte )

	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fValidAgen
Função para validar ao incluir,alterar ou excluir uma agenda para o médico.

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 02/08/2016

@param cCodMedAge	, Caracter	, Código do médico da agenda.
@param cQtdHoras	, Caracter	, Tempo para consulta padrão.
@param nOpcX		, Numérico	, Realização da operação desejada.
@param cCalAge		, Caracter	, Calendario informado na agenda.

@sample fValidAgen()

@return Logico, Indica se todas validações estão corretas.
/*/
//---------------------------------------------------------------------
Static Function fValidAgen( cCodMedAge, cQtdHoras, nOpcX, cCalAge )

	Local lRet := .T.

	If nOpcX == 3
		dbSelectArea( "TML" )
		dbSetOrder( 1 ) //TML_FILIAL+TML_CODUSU
		If dbSeek( xFilial( "TML" ) + cCodMedAge )
			ShowHelpDlg( STR0003, { STR0116 }, 2,; //"Atenção"###"Usuário já possui agenda."
						 { STR0117 }, 2 )         //"Favor informar outro usuário."
			lRet := .F.
		EndIf
	EndIf
	If lRet
		If Empty( cCodMedAge )
			ShowHelpDlg( STR0003, { STR0138 }, 2, { STR0060 }, 2 ) //"Atenção"###"O campo de Usuário está vazio."###"Favor preencher o campo."
			lRet := .F.
		EndIf
		If lRet .And. Empty( cCalAge )
			ShowHelpDlg( STR0003, { STR0139 }, 2, { STR0060 }, 2 ) //"Atenção"###"O campo de Calendário está vazio."###"Favor preencher o campo."
			lRet := .F.
		EndIf
		If lRet .And. Len( AllTrim( cQtdHoras ) ) != 5
			ShowHelpDlg( STR0003, { STR0059 }, 2, { STR0060 }, 2 ) //"Atenção"###"O campo de Quantidade Horas está vazio." ###"Favor preencher o campo."
			lRet := .F.
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076VERI
Função para verificar se existe médico.

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 02/08/2016

@sample MDT076VERI()

@return Logico, Indica se todas validações estão corretas.
/*/
//---------------------------------------------------------------------
Function MDT076VERI()

	Local cQuery
	Local cAliQry := GetNextAlias()
	Local dDataAtu := dDataBase

	cQuery := " SELECT COUNT( * ) AS CONT FROM " + RetSqlName( "TMK" ) + " TMK "
	cQuery += " WHERE ( TMK.TMK_DTTERM = ' ' OR TMK.TMK_DTTERM >= " + ValToSql( dDataAtu ) + ') '
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " AND TMK.TMK_FILIAL = " + ValToSql( xFilial( "TMK" ) )

	cQuery := ChangeQuery( cQuery )
	MPSysOpenQuery( cQuery, cAliQry )

	nQtdUsu := ( cAliQry )->CONT
	( cAliQry )->( dbCloseArea() )

	//se não possuir usuário
	If nQtdUsu == 0
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076PDU
Função para o botão 'Próximo Duração'.

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 11/10/2016

@param lInclusao	, Logico	, Indica se é Inclusão(.T.) ou Encaixe(.F.).
@param cAliasVal	, Caracter	, Indica o Alias posicionado no momento TMJ ou TY9.
@param cHoraIni		, Caracter	, Horario inicial da consulta nova.
@param cQntHr		, Caracter	, Quantidade de horas da consulta nova.
@param cHoraFim		, Caracter	, Horario final da consulta nova.
@param dDiaAtu		, Data		, Data da consulta.
@param cAliasENC	, Caracter	, Alias da query do encaixe.

@sample MDT076PDU( .T., "TMJ", "08:10", "00:10", "08:20", 11/10/2016, "TABTEMP001" )

@return Logico, Indica se todas validações estão corretas.
/*/
//---------------------------------------------------------------------
Function MDT076PDU( lInclusao, cAliasVal, cHoraIni, cQntHr, cHoraFim, dDiaAtu, cAliasENC )

	Local aAgendas		:= {}
	Local cPrefix 		:= "M->" + PrefixoCPO( cAliasVal )
	Local cQtdHrsENC	:= "" //Tempo de consulta
	Local cNewHrCons	:= "" //Novo horario da consulta
	Local cHrFim		:= "" //horario final do atendimento
	Local cInterv		:= "" //Indica se o tempo de intervalo é maior que 5 minutos
	Local lRet			:= .T.
	Local lFirst		:= .T. //Indica que é o primeiro registro
	Local lInterv		:= .F. //Indica que possui intervalor entre os agendamentos
	Local nX			:= 0

	dbSelectArea( cAliasENC )
	DbGoTop()
	While ( cAliasENC )->( !Eof() )

		//se campo de quantidade de horas estiver vazio recebe da Agenda
		If Empty( ( cAliasENC )->QTDHRS )
			cQtdHrsENC := fVldQtdHrs( ( cAliasENC )->CODUSU )
		Else
			cQtdHrsENC := ( cAliasENC )->QTDHRS
		EndIf
		cNewHrCons := MTOH( HTOM( ( cAliasENC )->HRCONS ) + HTOM( cQtdHrsENC ) )

		aAdd( aAgendas, { ( cAliasENC )->HRCONS, cQtdHrsENC, cNewHrCons } ) //add no array o proximos horarios

		dbSelectArea( cAliasENC )
		( cAliasENC )->( DbSkip() )
	End

	//verifica se possui horario entre os agendamentos
	For nX := 1 To Len( aAgendas )
		If !lFirst
			 //subtrai o horario final do anterior com o próximo para verificar intervalo entre elas
			cInterv := MTOH( HTOM( aAgendas[nX, 1] ) - HTOM( cHrFim ) )
			If cInterv >= cQntHr //verifica se o intervalor é igual ou superior ao da consulta nova
				lInterv := .T.
				Exit
			EndIf
		EndIf
		cHrFim := aAgendas[nX, 3]
		lFirst := .F.
	Next nX

	//se possui intervalo entre os agendamentos
	If lInterv

		//Novo horario inicial e tempo da consulta
		cNewHrIni := cHrFim
		cNewQtHour := cQntHr

	Else //se não deverá pegar o horario final do ultimo atendimento

		//Verifica se possui o tempo minimo de atendimento no dia para ser possivel incluir - 5 Minutos
		cHour := MTOH( HTOM( cHrFim ) + HTOM( cQntHr ) )
		If cHour <= "24:00"

			//Novo horario inicial e tempo da consulta
			cNewHrIni := cHrFim
			cNewQtHour := cQntHr

		Else //não possui horario disponivel para incluir no dia selecionado
			MsgAlert( STR0140 ) //"Não possui próximo horário para a duração."
			lRet := .F.
		EndIf

	EndIf

	If lRet
		cConsFin := MTOH( HTOM( cNewHrIni ) + HTOM( cNewQtHour ) )
		MsgAlert( STR0087 + cNewHrIni + STR0047 + cConsFin + STR0088 + ".", STR0003 ) //"O horário para à consulta ficou das: " ###" às " ###" horas" ###"Atenção"

		If !Empty( cNewHrIni ) .And. !Empty( cNewQtHour )

			//somente atualizar TRB e memória se for do MDTA076
			If IsInCallStack( "MDTA076" )
				//atualiza os valores da memória
				&( cPrefix + "_HRCONS" ) := cNewHrIni
				&( cPrefix + "_QTDHRS" ) := cNewQtHour

				dbSelectArea( cAliasAte )
				dbSetOrder( 4 ) //CODUSU+DtoS(DTCONS)+HRCONS
				If !dbSeek( cMedico + DtoS( dDiaAtu ) + cNewHrIni )
					RecLock( cAliasAte, .T. )
						( cAliasAte )->CODUSU := cMedico
						( cAliasAte )->DTCONS := dDiaAtu
						( cAliasAte )->HRCONS := cNewHrIni
						If cAliasVal == "TMJ"
							( cAliasAte )->NUMFIC	:= M->TMJ_NUMFIC
							( cAliasAte )->MAT	 	:= M->TMJ_MAT
						EndIf
					( cAliasAte )->( MsUnLock() )
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076PDI
Função para o botão 'Próximo disponivel'.

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 11/10/2016

@param lInclusao	, Logico	, Indica se é Inclusão(.T.) ou Encaixe(.F.).
@param cAliasVal	, Caracter	, Indica o Alias posicionado no momento TMJ ou TY9.
@param cHoraIni		, Caracter	, Horario inicial da consulta nova.
@param cQntHr		, Caracter	, Quantidade de horas da consulta nova.
@param cHoraFim		, Caracter	, Horario final da consulta nova.
@param dDiaAtu		, Data		, Data da consulta.
@param cAliasENC	, Caracter	, Alias da query do encaixe.

@sample MDT076PDI( .T., "TMJ", "08:10", "00:10", "08:20", 11/10/2016, "TABTEMP001" )

@return Logico, Indica se todas validações estão corretas.
/*/
//---------------------------------------------------------------------
Function MDT076PDI( lInclusao, cAliasVal, cHoraIni, cQntHr, cHoraFim, dDiaAtu, cAliasENC )

	Local aAgendas		:= {}
	Local cPrefix 		:= "M->" + PrefixoCPO( cAliasVal )
	Local cQtdHrsENC	:= "" //Tempo de consulta
	Local cNewHrCons	:= "" //Novo horario da consulta
	Local cHrFim		:= "" //horario final do atendimento
	Local cInterv		:= "" //Indica se o tempo de intervalo é maior que 5 minutos
	Local lRet			:= .T.
	Local lFirst		:= .T. //Indica que é o primeiro registro
	Local lInterv		:= .F. //Indica que possui intervalor entre os agendamentos
	Local nX			:= 0

	dbSelectArea( cAliasENC )
	DbGoTop()
	While ( cAliasENC )->( !Eof() )

		//se campo de quantidade de horas estiver vazio recebe da Agenda
		If Empty( ( cAliasENC )->QTDHRS )
			cQtdHrsENC := fVldQtdHrs( ( cAliasENC )->CODUSU )
		Else
			cQtdHrsENC := ( cAliasENC )->QTDHRS
		EndIf
		cNewHrCons := MTOH( HTOM( ( cAliasENC )->HRCONS ) + HTOM( cQtdHrsENC ) )

		aAdd( aAgendas, { ( cAliasENC )->HRCONS, cQtdHrsENC, cNewHrCons  } ) //add no array o proximos horarios

		dbSelectArea( cAliasENC )
		( cAliasENC )->( DbSkip() )
	End

	//verifica se possui horario entre os agendamentos
	For nX := 1 To Len( aAgendas )
		If !lFirst
			 //subtrai o horario final do anterior com o próximo para verificar intervalo entre elas
			cInterv := MTOH( HTOM( aAgendas[nX, 1] ) - HTOM( cHrFim ) )
			If cInterv >= "00:05"
				lInterv := .T.
				Exit
			EndIf
		EndIf
		cHrFim := aAgendas[nX, 3]
		lFirst := .F.
	Next nX

	//se possui intervalo entre os agendamentos
	If lInterv

		//Novo horario inicial da consulta
		cNewHrIni := cHrFim

		//verifica se tempo de atendimento é maior do que o disponivel
		If cQntHr > cInterv
			//recebe o valor disponivel
			cNewQtHour := cInterv
		Else //permanecerá igual
			cNewQtHour := cQntHr
		EndIf

	Else //se não deverá pegar o horario final do ultimo atendimento

		//Verifica se possui o tempo minimo de atendimento no dia para ser possivel incluir - 5 Minutos
		If cHrFim <= "23:55"

			//Novo horario inicial da consulta
			cNewHrIni := cHrFim

			//-----------------------------------------------------------------------
			//Verifica se deverá alterar o tempo de atendimento da consulta
			//se horario final do ultimo atendimento mais a quantidade de tempo da consulta nova é maior que 23:59
			lTermino := MTOH( HTOM( cHrFim ) + HTOM( cQntHr ) ) > "23:59"

			If lTermino //deverá diminuir o tempo de consulta
				cNewQtHour := MTOH( HTOM( "24:00" ) - HTOM( cHrFim ) ) //novo tempo de consulta
			Else //se não o tempo de atendimento permanecerá o mesmo
				cNewQtHour := cQntHr
			EndIf
			//-----------------------------------------------------------------------

		Else //não possui horario disponivel para incluir no dia selecionado
			MsgAlert( STR0121 ) //"Não possui próximo horário disponível."
			lRet := .F.
		EndIf

	EndIf

	If lRet
		cConsFin := MTOH( HTOM( cNewHrIni ) + HTOM( cNewQtHour ) )
		MsgAlert( STR0087 + cNewHrIni + STR0047 + cConsFin + STR0088 + ".", STR0003 )//"O horário para à consulta ficou das: " ###" às " ###" horas" ###"Atenção"

		If !Empty( cNewHrIni ) .And. !Empty( cNewQtHour )

			//somente atualizar TRB e memória se for do MDTA076
			If IsInCallStack( "MDTA076" )
				//atualiza os valores da memória
				&( cPrefix + "_HRCONS" ) := cNewHrIni
				&( cPrefix + "_QTDHRS" ) := cNewQtHour

				dbSelectArea( cAliasAte )
				dbSetOrder( 4 ) //CODUSU+DtoS(DTCONS)+HRCONS
				If !dbSeek( cMedico + DtoS( dDiaAtu ) + cNewHrIni )
					RecLock( cAliasAte, .T. )
						( cAliasAte )->CODUSU := cMedico
						( cAliasAte )->DTCONS := dDiaAtu
						( cAliasAte )->HRCONS := cNewHrIni
						If cAliasVal == "TMJ"
							( cAliasAte )->NUMFIC	:= M->TMJ_NUMFIC
							( cAliasAte )->MAT	 	:= M->TMJ_MAT
						EndIf
					( cAliasAte )->( MsUnLock() )
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076MTH
Função para o botão 'Manter Horário'.

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 11/10/2016

@param lInclusao	, Logico	, Indica se é Inclusão(.T.) ou Encaixe(.F.).
@param cAliasVal	, Caracter	, Indica o Alias posicionado no momento TMJ ou TY9.
@param cHoraIni		, Caracter	, Horario inicial da consulta nova.
@param cQntHr		, Caracter	, Quantidade de horas da consulta nova.
@param cHoraFim		, Caracter	, Horario final da consulta nova.
@param dDiaAtu		, Data		, Data da consulta.
@param cAliasENC	, Caracter	, Alias da query do encaixe.
@param cHora	, Caracter	, Horário selecionado.

@sample MDT076MTH( .T., "TMJ", "08:10", "00:10", "08:20", 11/10/2016, "TABTEMP001", .T., "08:05" )

@return Logico, Indica se todas validações estão corretas.
/*/
//---------------------------------------------------------------------
Function MDT076MTH( lInclusao, cAliasVal, cHoraIni, cQntHr, cHoraFim, dDiaAtu, cAliasENC, cHora )

	Local aAreaTMJ := TMJ->( GetArea() )
	Local aAgendas 	:= {}
	Local cPrefix 	:= "M->" + PrefixoCPO( cAliasVal )
	Local cPrefixTab := cAliasVal + "->" + PrefixoCPO( cAliasVal )
	Local cNewHrCons := ""
	Local lRet 		:= .T.
	Local lAltIni 	:= .F. //Indica que devera ser alterado o horario inicial do selecionado
	Local lAltSel	:= .F. //Variavel para indicar se deverá ser alterado o horario inicial da consulta selecionada

	dbSelectArea( cAliasENC )
	DbGoTop()
	While ( cAliasENC )->( !Eof() )

		//se campo de quantidade de horas estiver vazio recebe da Agenda
		If Empty( ( cAliasENC )->QTDHRS )
			cQtdHrsENC := fVldQtdHrs( ( cAliasENC )->CODUSU )
		Else
			cQtdHrsENC := ( cAliasENC )->QTDHRS
		EndIf
		cNewHrCons := MTOH( HTOM( ( cAliasENC )->HRCONS ) + HTOM( cQtdHrsENC ) )

		aAdd( aAgendas, { ( cAliasENC )->HRCONS, cQtdHrsENC, cNewHrCons  } ) //add no array o proximos horarios
		If lInclusao //Somente o primeiro registro
			Exit
		Else //somente os dois primeiros registros
			If Len( aAgendas ) == 2
				Exit
			EndIf
		EndIf
		dbSelectArea( cAliasENC )
		( cAliasENC )->( DbSkip() )
	End

	//Se horario da consulta nova for igual o horario da consulta selecionada, deverá aumentar a selecionada
	//Se a consulta nova for superior ao selecionada deverá diminuir o tempo de atendimento da selecionada
	If cHoraIni == cHora
		lAltSel := .T.
	EndIf

	If lInclusao

		If IsInCallStack( "MDTA075" )
			dbSelectArea( "TMJ" )
			dbSetOrder( 1 )
			If dbSeek( xFilial( "TMJ" ) + cMedico + DTOS( dDiaAtu ) + aAgendas[1, 1] )
				cNumFic := TMJ->TMJ_NUMFIC
				cHrsConTMJ := TMJ->TMJ_HRCONS
				cQtdHrsTMJ := TMJ->TMJ_QTDHRS
				If lAltSel //o horario da consulta selecionada receberá 5 minutos
					If cQtdHrsTMJ == "00:05"
						ShowHelpDlg( STR0003, { STR0141 }, 2, { STR0064 }, 2 ) //"Atenção"// "Já possui agendamento neste horário." //"Favor informar um horário disponível."
						lRet := .F.
					Else
						cNewHrCons := MTOH( HTOM( cHrsConTMJ ) + 5 )
						cNewQtCons := MTOH( HTOM( cQtdHrsTMJ ) - 5 )
					EndIf
				Else
					cNewHrCons := cHrsConTMJ
					//Verifica se horario inicial da consulta é superior ao horario da selecionada
					If cHoraIni > cNewHrCons
						cNewQtCons := MTOH( HTOM( cHoraIni ) - HTOM( cNewHrCons ) )
					Else
						cNewQtCons := cQtdHrsTMJ
					EndIf
				EndIf

				If lRet
					//----------------------
					//Alterar valor do registro em base
					//----------------------
					//-------------------------------------------------------------------------------------------------
					RecLock( "TMJ", .F. )
						TMJ->TMJ_HRCONS := cNewHrCons
						TMJ->TMJ_QTDHRS := cNewQtCons
					TMJ->( MsUnLock() )
					MDT076ATU( cMedico, cNumFic, dDiaAtu, aAgendas[ 1, 1 ], cNewHrCons )
					//-------------------------------------------------------------------------------------------------

					//----------------------
					//Novos valores que o horário transferido receberá
					//----------------------
					//-------------------------------------------------------------------------------------------------
					If lAltSel //Se horario da consulta nova for igual o horario da consulta selecionada
						cNewHrIni := cHoraIni
						cNewQtHour := MTOH( 5 )
					Else
						//Novo horário inicial e quantidade de horas da consulta transferida
						If cHoraIni < aAgendas[1, 1]
							cNewHrIni := cHoraIni
							cNewQtHour := MTOH( HTOM( cNewHrCons ) - HTOM( cNewHrIni ) )
						Else //Caso o horario inicial da transferida for superior ao da selecionada
							cHrTotTMJ := MTOH( HTOM( cHrsConTMJ ) + HTOM( cQtdHrsTMJ ) )
							//Se horario final da consulta selecionada for maior que horario da consulta selecionada,
							//o tempo de atendimento permanecera igual.
							If cHrTotTMJ > cHoraFim
								cNewHrIni := cHoraIni
								cNewQtHour := cQntHr
							Else
								cNewHrIni := cHoraIni
								cNewQtHour := MTOH( HTOM( cHrTotTMJ ) - HTOM( cNewHrIni ) )
							EndIf
						EndIf
					EndIf
					//-------------------------------------------------------------------------------------------------

				EndIf

			Else
				dbSelectArea( "TY9" )
				dbSetOrder( 1 )
				If dbSeek( xFilial( "TY9" ) + cMedico + DTOS( dDiaAtu ) + aAgendas[1, 1] )
					cHrsConTY9 := TY9->TY9_HRCONS
					cQtdHrsTY9 := TY9->TY9_QTDHRS
					If lAltSel //o horario da consulta selecionada receberá 5 minutos
						If cQtdHrsTY9 == "00:05"
							ShowHelpDlg( STR0003, { STR0141 }, 2, { STR0064 }, 2 ) //"Atenção"//"Já possui agendamento neste horário."//"Favor informar um horário disponível."
							lRet := .F.
						Else
							cNewHrCons := MTOH( HTOM( cHrsConTY9 ) + 5 )
							cNewQtCons := MTOH( HTOM( cQtdHrsTY9 ) - 5 )
						EndIf
					Else
						cNewHrCons := cHrsConTY9
						//Verifica se horario inicial da consulta é superior ao horario da selecionada
						If cHoraIni > cNewHrCons
							cNewQtCons := MTOH( HTOM( cHoraIni ) - HTOM( cNewHrCons ) )
						Else
							cNewQtCons := cQtdHrsTY9
						EndIf
					EndIf

					If lRet
						//----------------------
						//Alterar valor do registro em base
						//----------------------
						//-------------------------------------------------------------------------------------------------
						RecLock( "TY9", .F. )
							TY9->TY9_HRCONS := cNewHrCons
							TY9->TY9_QTDHRS := cNewQtCons
						TY9->( MsUnLock() )
						//-------------------------------------------------------------------------------------------------

						//----------------------
						//Novos valores que o horário transferido receberá
						//----------------------
						//-------------------------------------------------------------------------------------------------
						If lAltSel //Se horario da consulta nova for igual o horario da consulta selecionada
							cNewHrIni := cHoraIni
							cNewQtHour := MTOH( 5 )
						Else
							//Novo horário inicial e quantidade de horas da consulta transferida
							If cHoraIni < aAgendas[1, 1]
								cNewHrIni := cHoraIni
								cNewQtHour := MTOH( HTOM( cNewHrCons ) - HTOM( cNewHrIni ) )
							Else //Caso o horario inicial da transferida for superior ao da selecionada
								cHrTotTY9 := MTOH( HTOM( cHrsConTY9 ) + HTOM( cQtdHrsTY9 ) )
								//Se horario final da consulta selecionada for maior que horario da consulta transferida,
								//o tempo de atendimento permanecera igual.
								If cHrTotTY9 > cHoraFim
									cNewHrIni := cHoraIni
									cNewQtHour := cQntHr
								Else
									cNewHrIni := cHoraIni
									cNewQtHour := MTOH( HTOM( cHrTotTY9 ) - HTOM( cNewHrIni ) )
								EndIf
							EndIf
						EndIf
						//-------------------------------------------------------------------------------------------------

					EndIf

				EndIf

			EndIf
		Else

			//----------------------
			//Novos valores que o horário incluso receberá
			//----------------------
			//-------------------------------------------------------------------------------------------------
			//Novo horário inicial e quantidade de horas da consulta transferida
			If cHoraIni < aAgendas[1, 1]
				cNewHrIni := cHoraIni
				cNewQtHour := MTOH( HTOM( aAgendas[1, 1] ) - HTOM( cNewHrIni ) )
			Else //Caso o horario inicial da consulta for superior ao da selecionada
				cHrTotTMJ := MTOH( HTOM( cHrsConTMJ ) + HTOM( cQtdHrsTMJ ) )
				//Se horario final da consulta selecionada for maior que horario da consulta transferida,
				//o tempo de atendimento permanecera igual.
				If cHrTotTMJ > cHoraFim
					cNewHrIni := cHoraIni
					cNewQtHour := cQntHr
				Else
					cNewHrIni := cHoraIni
					cNewQtHour := MTOH( HTOM( cHrTotTMJ ) - HTOM( cNewHrIni ) )
				EndIf
			EndIf

		EndIf

	Else //Encaixe

		dbSelectArea( "TMJ" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "TMJ" ) + cMedico + DTOS( dDiaAtu ) + aAgendas[1, 1] )
			cNumFic := TMJ->TMJ_NUMFIC
			cHrsConTMJ := TMJ->TMJ_HRCONS
			cQtdHrsTMJ := TMJ->TMJ_QTDHRS

			If lAltSel //o horario da consulta selecionada receberá 5 minutos
				If cQtdHrsTMJ == "00:05"
					ShowHelpDlg( STR0003, { STR0141 }, 2, { STR0064 }, 2 ) //"Atenção"//"Já possui agendamento neste horário."//"Favor informar um horário disponível."
					lRet := .F.
				Else
					cNewHrCons := MTOH( HTOM( cHrsConTMJ ) + 5 )
					cNewQtCons := MTOH( HTOM( cQtdHrsTMJ ) - 5 )
				EndIf
			Else
				cNewHrCons := cHrsConTMJ
				//Verifica se horario inicial da consulta é superior ao horario da selecionada
				If cHoraIni > cNewHrCons
					cNewQtCons := MTOH( HTOM( cHoraIni ) - HTOM( cNewHrCons ) )
				Else
					cNewQtCons := cQtdHrsTMJ
				EndIf
			EndIf

			If lRet
				//----------------------
				//Novos valores que o horário transferido receberá
				//----------------------
				//-------------------------------------------------------------------------------------------------
				If lAltSel //Se horario da consulta nova for igual o horario da consulta selecionada
					cNewHrIni := cHoraIni
					cNewQtHour := MTOH( 5 )
				Else
					//Novo horário inicial e quantidade de horas da consulta transferida
					If cHoraIni < aAgendas[1, 1]
						cNewHrIni := cHoraIni
						cNewQtHour := MTOH( HTOM( cNewHrCons ) - HTOM( cNewHrIni ) )
					Else //Caso o horario inicial da transferida for superior ao da selecionada
						cHrTotTMJ := MTOH( HTOM( cHrsConTMJ ) + HTOM( cQtdHrsTMJ ) )
						//verifica se horario inicial da nova consulta é igual ao horario final da selecionada
						If cHoraIni == cHrTotTMJ
							ShowHelpDlg( STR0003, { STR0142 },; //"Atenção"//"Não é possível informar o horário inicial da consulta igual ao horário final da consulta selecionada."
							 			 2, { STR0143 }, 2 )    //"Favor informar um horário inicial inferior ao informado."
							lRet := .F.
						Else
							//Se horario final da consulta selecionada for maior que horario da consulta transferida,
							//o tempo de atendimento permanecera igual.
							If cHrTotTMJ > cHoraFim
								cNewHrIni := cHoraIni
								cNewQtHour := cQntHr
							Else
								cNewHrIni := cHoraIni
								cNewQtHour := MTOH( HTOM( cHrTotTMJ ) - HTOM( cNewHrIni ) )
							EndIf
						EndIf
					EndIf
				EndIf
				//-------------------------------------------------------------------------------------------------

				If lRet
					//----------------------
					//Alterar valor do registro em base
					//----------------------
					//-------------------------------------------------------------------------------------------------
					RecLock( "TMJ", .F. )
						TMJ->TMJ_HRCONS := cNewHrCons
						TMJ->TMJ_QTDHRS := cNewQtCons
					TMJ->( MsUnLock() )
					MDT076ATU( cMedico, cNumFic, dDiaAtu, aAgendas[ 1, 1 ], cNewHrCons )
					//-------------------------------------------------------------------------------------------------

					//----------------------
					//Alterar valor da TRB dos shapes
					//----------------------
					//-------------------------------------------------------------------------------------------------
					If lAltSel .And. IsInCallStack( "MDTA076" )
						dbSelectArea( cAliasAte )
						dbSetOrder( 4 ) //CODUSU+DtoS(DTCONS)+HRCONS
						If dbSeek( cMedico + DtoS( dDiaAtu ) + cHora ) //se encontrar o valor antigo, devera atualizar
							RecLock( cAliasAte, .F. )
								( cAliasAte )->HRCONS := cNewHrCons
							( cAliasAte )->( MsUnLock() )
						EndIf
					EndIf
					//-------------------------------------------------------------------------------------------------
				EndIf

			EndIf
		EndIf
	EndIf

	If lRet
		If !Empty( cNewHrIni ) .And. !Empty( cNewQtHour )

			cConsFin := MTOH( HTOM( cNewHrIni ) + HTOM( cNewQtHour ) )
			MsgAlert( STR0087 + cNewHrIni + STR0047 + cConsFin + STR0088 + ".", STR0003 )//"O horário para à consulta ficou das: " ###" às " ###" horas" ###"Atenção"

			If IsInCallStack( "MDTA076" )
				dbSelectArea( cAliasAte )
				dbSetOrder( 4 ) //CODUSU+DtoS(DTCONS)+HRCONS
				If !dbSeek( cMedico + DtoS( dDiaAtu ) + cNewHrIni )
					RecLock( cAliasAte, .T. )
					( cAliasAte )->CODUSU := cMedico
					( cAliasAte )->DTCONS := dDiaAtu
					( cAliasAte )->HRCONS := cNewHrIni
					If cAliasVal == "TMJ"
						( cAliasAte )->NUMFIC	:= M->TMJ_NUMFIC
						( cAliasAte )->MAT	 	:= M->TMJ_MAT
					EndIf
					( cAliasAte )->( MsUnLock() )
				EndIf

				//atualiza os valores da memória
				&( cPrefix + "_HRCONS" ) := cNewHrIni
				&( cPrefix + "_QTDHRS" ) := cNewQtHour

			EndIf
		EndIf
	EndIf

	RestArea( aAreaTMJ )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076PTT
Função para o botão 'Postergar Todos'.

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 11/10/2016

@param lInclusao	, Logico	, Indica se é Inclusão(.T.) ou Encaixe(.F.).
@param cAliasVal	, Caracter	, Indica o Alias posicionado no momento TMJ ou TY9.
@param cHoraIni		, Caracter	, Horario inicial da consulta nova.
@param cQntHr		, Caracter	, Quantidade de horas da consulta nova.
@param cHoraFim		, Caracter	, Horario final da consulta nova.
@param dDiaAtu		, Data		, Data da consulta.
@param cAliasENC	, Caracter	, Alias da query do encaixe.

@sample MDT076PTT( .T., "TMJ", "08:10", "00:10", "08:20", 11/10/2016, "TABTEMP001" )

@return Logico, Indica se todas validações estão corretas.
/*/
//---------------------------------------------------------------------
Function MDT076PTT( lInclusao, cAliasVal, cHoraIni, cQntHr, cHoraFim, dDiaAtu, cAliasENC )

	Local aAgendas		:= {}
	Local aHorInt		:= {}
	Local cPrefix 		:= "M->" + PrefixoCPO( cAliasVal )
	Local cQtdHrsENC	:= "" //Tempo de consulta
	Local cNewHrCons	:= "" //Novo horario da consulta
	Local cHrCnsEnc		:= "" //Horario das consultas
	Local lRet			:= .T.
	Local lFirst		:= .T. //Indica que é o primeiro registro
	Local lAltera		:= .F. //Indica que deverá ser alterado o tempo de consulta
	Local nX			:= 0

	dbSelectArea( cAliasENC )
	DbGoTop()
	While ( cAliasENC )->( !Eof() )

		cHrCnsEnc := ( cAliasENC )->HRCONS
		cQtdHrsENC := ( cAliasENC )->QTDHRS
		//se for Encaixe e primeiro registro
		If !lInclusao .And. lFirst
			lFirst := .F.
			//verifica se novo horário é diferente do selecionado
			//se for diferente ñ deverá add no array
			If cHrCnsEnc != cHoraIni
				lAltera := .T.
				dbSelectArea( cAliasENC )
				( cAliasENC )->( DbSkip() )
				Loop
			EndIf
		EndIf

		//Verifica se código de usuario esta preenchido
		If !Empty( ( cAliasENC )->CODUSU )
			//se campo de quantidade de horas estiver vazio recebe da Agenda
			If Empty( ( cAliasENC )->QTDHRS )
				cQtdHrsENC := fVldQtdHrs( ( cAliasENC )->CODUSU )
			Else
				cQtdHrsENC := ( cAliasENC )->QTDHRS
			EndIf
			cNewHrCons := MTOH( HTOM( cHrCnsEnc ) + HTOM( cQtdHrsENC ) )
		Else
			//Joga o ultimo horario do dia para Postergar os horarios
			//corretamente, pois ñ possui horario posterior ao selecionado
			cHrCnsEnc := "23:55"
			cQtdHrsENC := "00:05"
			cNewHrCons := MTOH( HTOM( cHrCnsEnc ) + HTOM( cQtdHrsENC ) )
		EndIf

		aAdd( aAgendas, { cHrCnsEnc, cQtdHrsENC, cNewHrCons  } ) //add no array o proximos horarios

		dbSelectArea( cAliasENC )
		( cAliasENC )->( DbSkip() )
	End

	If lRet
		cOldHor := cHoraIni
		cOldQnt := cQntHr
		cOldTot := MTOH( HTOM( cOldHor ) + HTOM( cOldQnt ) )

		//Add em outro array somente os proximos horarios que interferir
		For nX := 1 To Len( aAgendas )
			//verifica se horario final da consulta esta dentro da proxima
			If aAgendas[ nX, 1 ] < cOldTot
				cOldHor := cOldTot
				cOldQnt := aAgendas[ nX, 2 ]
				cOldTot := MTOH( HTOM( cOldHor ) + HTOM( cOldQnt ) )
				aAdd( aHorInt, { cOldHor, cOldQnt, cOldTot, aAgendas[ nX, 1 ] } )
			Else
				Exit
			EndIf
		Next nX

		//verifica se possui algum agendamento com atendimento
		//vai retornar .F. se possuir Atendimentos
		If !MDT076ATEN( aHorInt, cMedico, dDiaAtu )
			ShowHelpDlg( STR0003, { STR0077 }, 2,; //"Atenção"###"Não é possível postergar os próximos horários, pois possui atendimentos realizados."
						 { STR0078  }, 2 )         //"Favor selecionar outra opção para o horário atual ou alterar o tempo de consulta."
			lRet := .F.
		EndIf

		//verifica se algum horário vai passar das 24:00hrs
		If lRet
			If aScan( aHorInt, { | x | x[ 3 ] > "24:00" } ) > 0
				ShowHelpDlg( STR0003, { STR0105 }, 2,; //"Atenção"###"Possui algum agendamento que vai ter início e término em datas diferentes."
							 { STR0086 }, 2 )          //"Favor alterar o tempo de consulta."
				lRet := .F.
			EndIf
		EndIf

		If lRet

			If !lInclusao .And. lAltera
				dbSelectArea( "TMJ" )
				dbSetOrder( 1 )
				If dbSeek( xFilial( "TMJ" ) + cMedico + DTOS( dDiaAtu ) + cHora )
					RecLock( "TMJ", .F. )
						TMJ->TMJ_QTDHRS := MTOH( HTOM( cHoraIni ) - HTOM( cHora ) )
					Msunlock( "TMJ" )
				EndIf
			EndIf

			//Ordena por ordem decrescente
			//Para ao Postergar Todos não haver conflitos de horário
			ASort( aHorInt, , , { | x, y | x[ 1 ] > y[ 1 ] } )

			//Realiza gravação dos novos valores
			For nX := 1 To Len( aHorInt )
				dbSelectArea( "TMJ" )
				dbSetOrder( 1 )
				If dbSeek( xFilial( "TMJ" ) + cMedico + DTOS( dDiaAtu ) + aHorInt[ nX, 4 ] )
					RecLock( "TMJ", .F. )
						TMJ->TMJ_HRCONS := aHorInt[ nX, 1 ]
					TMJ->( MsUnLock() )
					MDT076ATU( cMedico, TMJ->TMJ_NUMFIC, dDiaAtu, aHorInt[ nX, 4 ], aHorInt[ nX, 1 ] )
				Else
					dbSelectArea( "TY9" )
					dbSetOrder( 1 )
					If dbSeek( xFilial( "TY9" ) + cMedico + DTOS( dDiaAtu ) + aHorInt[ nX, 4 ] )
						RecLock( "TY9", .F. )
							TY9->TY9_HRCONS := aHorInt[ nX, 1 ]
						TY9->( MsUnLock() )
					EndIf
				EndIf

				If IsInCallStack( "MDTA076" )
					//deve atualizar o TRB, para atualizar o shape
					dbSelectArea( cAliasAte )
					dbSetOrder( 4 ) //CODUSU+DtoS(DTCONS)+HRCONS
					If dbSeek( cMedico + DtoS( dDiaAtu ) + aHorInt[ nX, 4 ] ) //se encontrar o valor antigo, devera atualizar
						RecLock( cAliasAte, .F. )
						( cAliasAte )->HRCONS := aHorInt[ nX, 1 ]
						( cAliasAte )->( MsUnLock() )
					EndIf
				EndIf
			Next nX

		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076MTHI
Função para o botão 'Manter Horário' ao Transferir Funcionário e possuir interferencia.

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 11/10/2016

@param lInclusao	, Logico	, Indica se é Inclusão(.T.) ou Encaixe(.F.).
@param cAliasVal	, Caracter	, Indica o Alias posicionado no momento TMJ ou TY9.
@param cHoraIni		, Caracter	, Horario inicial da consulta nova.
@param cQntHr		, Caracter	, Quantidade de horas da consulta nova.
@param cHoraFim		, Caracter	, Horario final da consulta nova.
@param dDiaAtu		, Data		, Data da consulta.
@param cAliasENC	, Caracter	, Alias da query do encaixe.
@param cHora	, Caracter	, Horário selecionado.
@param lTransf  , Logico	, Indica se é transferencia(.T.).

@sample MDT076MTHI( .T., "TMJ", "08:10", "00:10", "08:20", 11/10/2016, "TABTEMP001", .T., "08:05" )

@return Logico, Indica se todas validações estão corretas.
/*/
//---------------------------------------------------------------------
Function MDT076MTHI( lInclusao, cAliasVal, cHoraIni, cQntHr, cHoraFim, dDiaAtu, cAliasENC, cHora, lTransf )

	Local aAreaTMJ := TMJ->( GetArea() )
	Local aAgendas 	:= {}
	Local cPrefix 	:= "M->" + PrefixoCPO( cAliasVal )
	Local cPrefixTab := cAliasVal + "->" + PrefixoCPO( cAliasVal )
	Local cNewHrCons := ""
	Local cAlsQry	:= "" //Alias da Query de Busca da TMJ
	Local cAlsQryTY9	:= "" //Alias da Query de Busca da TY9
	Local lRet 		:= .T.
	Local lAltSel	:= .F. //Variavel para indicar se deverá ser alterado o horario inicial da consulta selecionada
	Local lLockTMJ	:= .F. //Variavel de controle da existência da TMJ

	If IsInCallStack( "MDTA410" )
		Private cAliasMTH := GetNextAlias()
	EndIf

	lAtualTela := .F. //Ao Transferir pelo MDTA410 deverá receber falso para atualizar a tela correto

	dbSelectArea( cAliasENC )
	DbGoTop()
	While ( cAliasENC )->( !Eof() )

		//se campo de quantidade de horas estiver vazio recebe da Agenda
		If Empty( ( cAliasENC )->QTDHRS )
			cQtdHrsENC := fVldQtdHrs( ( cAliasENC )->CODUSU )
		Else
			cQtdHrsENC := ( cAliasENC )->QTDHRS
		EndIf
		cNewHrCons := MTOH( HTOM( ( cAliasENC )->HRCONS ) + HTOM( cQtdHrsENC ) )

		aAdd( aAgendas, { ( cAliasENC )->HRCONS, cQtdHrsENC, cNewHrCons  } ) //add no array o proximos horarios

		Exit //deverá pegar somente o registro selecionado
	End

	//Se horario da consulta nova for igual o horario da consulta selecionada, deverá aumentar a selecionada
	//Se a consulta nova for superior ao selecionada deverá diminuir o tempo de atendimento da selecionada
	If cHoraIni == aAgendas[1, 1]
		lAltSel := .T.
	EndIf

	//Realiza a busca da TMJ por Query pois não posiciona no MDTA410 devido ao browse inicial da TMJ
	If IsInCallStack( "MDTA410" )
		dbSelectArea( "TMJ" )
		cAlsQry := GetNextAlias()
		BeginSql Alias cAlsQry
			SELECT TMJ_CODUSU, TMJ_NUMFIC, TMJ_DTCONS, TMJ_HRCONS, TMJ_QTDHRS, R_E_C_N_O_ FROM %Table:TMJ% TMJ
				WHERE TMJ.%NotDel% AND
				TMJ.TMJ_FILIAL = %xFilial:TMJ% AND
				TMJ.TMJ_CODUSU = %exp:cMedico% AND
				TMJ.TMJ_DTCONS = %exp:dDiaAtu% AND
				TMJ.TMJ_HRCONS = %exp:aAgendas[1, 1]%
		EndSql

		If ValType( ( cAlsQry )->R_E_C_N_O_ ) == "N" .And. ( cAlsQry )->R_E_C_N_O_ > 0
			cNumFic := ( cAlsQry )->TMJ_NUMFIC
			cHrsConTMJ := ( cAlsQry )->TMJ_HRCONS
			cQtdHrsTMJ := ( cAlsQry )->TMJ_QTDHRS

			If lAltSel //o horario da consulta selecionada receberá 5 minutos
				If cQtdHrsTMJ == "00:05"
					ShowHelpDlg( STR0003, { STR0141 }, 2, { STR0064 }, 2 ) //"Atenção"//"Já possui agendamento neste horário."//"Favor informar um horário disponível."
					lRet := .F.
				Else
					cNewHrCons := MTOH( HTOM( cHrsConTMJ ) + 5 )
					cNewQtCons := MTOH( HTOM( cQtdHrsTMJ ) - 5 )
				EndIf
			Else
				cNewHrCons := cHrsConTMJ
				//Verifica se horario inicial da consulta é superior ao horario da selecionada
				If cHoraIni > cNewHrCons
					cNewQtCons := MTOH( HTOM( cHoraIni ) - HTOM( cNewHrCons ) )
				Else
					cNewQtCons := cQtdHrsTMJ
				EndIf
			EndIf

			If lRet
				//----------------------
				//Alterar valor do registro em base
				//----------------------
				//-------------------------------------------------------------------------------------------------
				aAreaAtu := GetArea()
					cQryTMJ := "UPDATE " + RetSqlName( "TMJ" )
					cQryTMJ += " SET TMJ_HRCONS = '" + cNewHrCons + "'," + " TMJ_QTDHRS = '" + cNewQtCons +"'"
					cQryTMJ += " WHERE TMJ_FILIAL = " + ValToSQL( xFilial( "TMJ" ) )
					cQryTMJ += " AND TMJ_CODUSU = '" + cMedico + "'"
					cQryTMJ += " AND TMJ_DTCONS = '" + DtoS( dDiaAtu ) + "'"
					cQryTMJ += " AND TMJ_HRCONS = '" + aAgendas[1, 1] + "'"
					cQryTMJ += " AND D_E_L_E_T_ = ' '"
					TCSQLExec( cQryTMJ )
				RestArea( aAreaAtu )
				MDT076ATU( cMedico, cNumFic, dDiaAtu, aAgendas[ 1, 1 ], cNewHrCons )
				//-------------------------------------------------------------------------------------------------

				//----------------------
				//Novos valores que o horário transferido receberá
				//----------------------
				//-------------------------------------------------------------------------------------------------
				If lAltSel //Se horario da consulta nova for igual o horario da consulta selecionada
					cNewHrIni := cHoraIni
					cNewQtHour := MTOH( 5 )
				Else
					//Novo horário inicial e quantidade de horas da consulta transferida
					If cHoraIni < aAgendas[1, 1]
						cNewHrIni := cHoraIni
						cNewQtHour := MTOH( HTOM( cNewHrCons ) - HTOM( cNewHrIni ) )
					Else //Caso o horario inicial da transferida for superior ao da selecionada
						cHrTotTMJ := MTOH( HTOM( cHrsConTMJ ) + HTOM( cQtdHrsTMJ ) )
						//Se horario final da consulta selecionada for maior que horario da consulta transferida,
						//o tempo de atendimento permanecera igual.
						If cHrTotTMJ > cHoraFim
							cNewHrIni := cHoraIni
							cNewQtHour := cQntHr
						Else
							cNewHrIni := cHoraIni
							cNewQtHour := MTOH( HTOM( cHrTotTMJ ) - HTOM( cNewHrIni ) )
						EndIf
					EndIf
				EndIf
				//-------------------------------------------------------------------------------------------------

			EndIf
		Else //Verifica se esta em conflito com a TY9
			cAlsQryTY9 := GetNextAlias()
			BeginSql Alias cAlsQryTY9
				SELECT TY9_CODUSU, TY9_DTCONS, TY9_HRCONS, TY9_QTDHRS, R_E_C_N_O_ FROM %Table:TY9% TY9
					WHERE TY9.%NotDel% AND
					TY9.TY9_FILIAL = %xFilial:TY9% AND
					TY9.TY9_CODUSU = %exp:cMedico% AND
					TY9.TY9_DTCONS = %exp:dDiaAtu% AND
					TY9.TY9_HRCONS = %exp:aAgendas[1, 1]%
			EndSql

			If ValType( ( cAlsQryTY9 )->R_E_C_N_O_ ) == "N" .And. ( cAlsQryTY9 )->R_E_C_N_O_ > 0
				cHrsConTY9 := ( cAlsQryTY9 )->TY9_HRCONS
				cQtdHrsTY9 := ( cAlsQryTY9 )->TY9_QTDHRS

				//Verifica se o horario inicial da consulta transferida é igual ao inicial da consulta selecionada
				If lAltSel //o horario da consulta selecionada receberá 5 minutos
					If cQtdHrsTY9 == "00:05"
						ShowHelpDlg( STR0003, { STR0144 }, 2, { STR0064 }, 2 ) //"Atenção"//"Já possui Reserva/Bloqueio neste horário." //"Favor informar um horário disponível."
						lRet := .F.
					Else
						cNewHrCons := MTOH( HTOM( cHrsConTY9 ) + 5 )
						cNewQtCons := MTOH( HTOM( cQtdHrsTY9 ) - 5 )
					EndIf
				Else
					cNewHrCons := cHrsConTY9
					//Verifica se horario inicial da consulta é superior ao horario da selecionada
					If cHoraIni > cNewHrCons
						cNewQtCons := MTOH( HTOM( cHoraIni ) - HTOM( cNewHrCons ) )
					Else
						cNewQtCons := cQtdHrsTY9
					EndIf
				EndIf

				If lRet
					//----------------------
					//Alterar valor do registro em base
					//----------------------
					//-------------------------------------------------------------------------------------------------
					aAreaAtu := GetArea()
						cQryTY9 := "UPDATE " + RetSqlName( "TY9" )
						cQryTY9 += " SET TY9_HRCONS = '" + cNewHrCons + "'," + " TY9_QTDHRS = '" + cNewQtCons +"'"
						cQryTY9 += " WHERE TY9_FILIAL = " + ValToSQL( xFilial( "TY9" ) )
						cQryTY9 += " AND TY9_CODUSU = '" + cMedico + "'"
						cQryTY9 += " AND TY9_DTCONS = '" + DtoS( dDiaAtu ) + "'"
						cQryTY9 += " AND TY9_HRCONS = '" + aAgendas[1, 1] + "'"
						cQryTY9 += " AND D_E_L_E_T_ = ' '"
						TCSQLExec( cQryTY9 )
					RestArea( aAreaAtu )
					//-------------------------------------------------------------------------------------------------

					//----------------------
					//Novos valores que o horário transferido receberá
					//----------------------
					//-------------------------------------------------------------------------------------------------
					If lAltSel //Se horario da consulta nova for igual o horario da consulta selecionada
						cNewHrIni := cHoraIni
						cNewQtHour := MTOH( 5 )
					Else
						//Novo horário inicial e quantidade de horas da consulta transferida
						If cHoraIni < aAgendas[1, 1]
							cNewHrIni := cHoraIni
							cNewQtHour := MTOH( HTOM( cNewHrCons ) - HTOM( cNewHrIni ) )
						Else //Caso o horario inicial da transferida for superior ao da selecionada
							cHrTotTY9 := MTOH( HTOM( cHrsConTY9 ) + HTOM( cQtdHrsTY9 ) )
							//Se horario final da consulta selecionada for maior que horario da consulta transferida,
							//o tempo de atendimento permanecera igual.
							If cHrTotTY9 > cHoraFim
								cNewHrIni := cHoraIni
								cNewQtHour := cQntHr
							Else
								cNewHrIni := cHoraIni
								cNewQtHour := MTOH( HTOM( cHrTotTY9 ) - HTOM( cNewHrIni ) )
							EndIf
						EndIf
					EndIf
					//-------------------------------------------------------------------------------------------------

				EndIf
			EndIf
		EndIf
	Else
		dbSelectArea( "TMJ" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "TMJ" ) + cMedico + DTOS( dDiaAtu ) + aAgendas[1, 1] )
			cNumFic := TMJ->TMJ_NUMFIC
			cHrsConTMJ := TMJ->TMJ_HRCONS
			cQtdHrsTMJ := TMJ->TMJ_QTDHRS

			If lAltSel //o horario da consulta selecionada receberá 5 minutos
				If cQtdHrsTMJ == "00:05"
					ShowHelpDlg( STR0003, { STR0141 }, 2, { STR0064  }, 2 ) //"Atenção"//"Já possui agendamento neste horário."//"Favor informar um horário disponível."
					lRet := .F.
				Else
					cNewHrCons := MTOH( HTOM( cHrsConTMJ ) + 5 )
					cNewQtCons := MTOH( HTOM( cQtdHrsTMJ ) - 5 )
				EndIf
			Else
				cNewHrCons := cHrsConTMJ
				//Verifica se horario inicial da consulta é superior ao horario da selecionada
				If cHoraIni > cNewHrCons
					cNewQtCons := MTOH( HTOM( cHoraIni ) - HTOM( cNewHrCons ) )
				Else
					cNewQtCons := cQtdHrsTMJ
				EndIf
			EndIf

			If lRet
				//----------------------
				//Alterar valor do registro em base
				//----------------------
				//-------------------------------------------------------------------------------------------------
				RecLock( "TMJ", .F. )
					TMJ->TMJ_HRCONS := cNewHrCons
					TMJ->TMJ_QTDHRS := cNewQtCons
				TMJ->( MsUnLock() )
				MDT076ATU( cMedico, cNumFic, dDiaAtu, aAgendas[ 1, 1 ], cNewHrCons )
				//-------------------------------------------------------------------------------------------------

				//----------------------
				//Novos valores que o horário transferido receberá
				//----------------------
				//-------------------------------------------------------------------------------------------------
				If lAltSel //Se horario da consulta nova for igual o horario da consulta selecionada
					cNewHrIni := cHoraIni
					cNewQtHour := MTOH( 5 )
				Else
					//Novo horário inicial e quantidade de horas da consulta transferida
					If cHoraIni < aAgendas[1, 1]
						cNewHrIni := cHoraIni
						cNewQtHour := MTOH( HTOM( cNewHrCons ) - HTOM( cNewHrIni ) )
					Else //Caso o horario inicial da transferida for superior ao da selecionada
						cHrTotTMJ := MTOH( HTOM( cHrsConTMJ ) + HTOM( cQtdHrsTMJ ) )
						//Se horario final da consulta selecionada for maior que horario da consulta transferida,
						//o tempo de atendimento permanecera igual.
						If cHrTotTMJ > cHoraFim
							cNewHrIni := cHoraIni
							cNewQtHour := cQntHr
						Else
							cNewHrIni := cHoraIni
							cNewQtHour := MTOH( HTOM( cHrTotTMJ ) - HTOM( cNewHrIni ) )
						EndIf
					EndIf
				EndIf
				//-------------------------------------------------------------------------------------------------

			EndIf
		Else
			dbSelectArea( "TY9" )
			dbSetOrder( 1 )
			If dbSeek( xFilial( "TY9" ) + cMedico + DTOS( dDiaAtu ) + aAgendas[ 1, 1 ] )
				cHrsConTY9 := TY9->TY9_HRCONS
				cQtdHrsTY9 := TY9->TY9_QTDHRS
				//Verifica se o horario inicial da consulta transferida é igual ao inicial da consulta selecionada
				If lAltSel //o horario da consulta selecionada receberá 5 minutos
					If cQtdHrsTY9 == "00:05"
						ShowHelpDlg( STR0003, { STR0144 }, 2, { STR0064 }, 2 ) //"Atenção"//"Já possui Reserva/Bloqueio neste horário."//"Favor informar um horário disponível."
						lRet := .F.
					Else
						cNewHrCons := MTOH( HTOM( cHrsConTY9 ) + 5 )
						cNewQtCons := MTOH( HTOM( cQtdHrsTY9 ) - 5 )
					EndIf
				Else
					cNewHrCons := cHrsConTY9
					//Verifica se horario inicial da consulta é superior ao horario da selecionada
					If cHoraIni > cNewHrCons
						cNewQtCons := MTOH( HTOM( cHoraIni ) - HTOM( cNewHrCons ) )
					Else
						cNewQtCons := cQtdHrsTY9
					EndIf
				EndIf

				If lRet
					//----------------------
					//Alterar valor do registro em base
					//----------------------
					//-------------------------------------------------------------------------------------------------
					RecLock( "TY9", .F. )
						TY9->TY9_HRCONS := cNewHrCons
						TY9->TY9_QTDHRS := cNewQtCons
					TY9->( MsUnLock() )
					//-------------------------------------------------------------------------------------------------

					//----------------------
					//Novos valores que o horário transferido receberá
					//----------------------
					//-------------------------------------------------------------------------------------------------
					If lAltSel //Se horario da consulta nova for igual o horario da consulta selecionada
						cNewHrIni := cHoraIni
						cNewQtHour := MTOH( 5 )
					Else
						//Novo horário inicial e quantidade de horas da consulta transferida
						If cHoraIni < aAgendas[1, 1]
							cNewHrIni := cHoraIni
							cNewQtHour := MTOH( HTOM( cNewHrCons ) - HTOM( cNewHrIni ) )
						Else //Caso o horario inicial da transferida for superior ao da selecionada
							cHrTotTY9 := MTOH( HTOM( cHrsConTY9 ) + HTOM( cQtdHrsTY9 ) )
							//Se horario final da consulta selecionada for maior que horario da consulta transferida,
							//o tempo de atendimento permanecera igual.
							If cHrTotTY9 > cHoraFim
								cNewHrIni := cHoraIni
								cNewQtHour := cQntHr
							Else
								cNewHrIni := cHoraIni
								cNewQtHour := MTOH( HTOM( cHrTotTY9 ) - HTOM( cNewHrIni ) )
							EndIf
						EndIf
					EndIf
					//-------------------------------------------------------------------------------------------------

				EndIf

			EndIf
		EndIf
	EndIf

	//----------------------
	//Deverá alterar o o Horario e a Quantidade de horas da consulta transferida para o TRB ficar correto
	//----------------------
	If !IsInCallStack( "MDTA161" ) //Não devera fazer essas validações pelo MDTA161
		If lRet
			If IsInCallStack( "MDTA410" ) .And. INCLUI
				dbSelectArea( "TMJ" )
				dbSetOrder( 1 )
				If dbSeek( xFilial( "TMJ" ) + cUsuario + DTOS( dDtAgend ) + cHrAgend )
					RecLock( "TMJ", .F. )
						TMJ->TMJ_CODUSU := cMedico
						TMJ->TMJ_DTCONS := dDiaAtu
						TMJ->TMJ_HRCONS := cNewHrIni
						TMJ->TMJ_QTDHRS := cNewQtHour
					TMJ->( MsUnLock() )
				EndIf
			Else
				dbSelectArea( "TMJ" )
				dbSetOrder( 1 )
				If dbSeek( xFilial( "TMJ" ) + __cMedico + DTOS( __dDtCons ) + __cHrCons )
					RecLock( "TMJ", .F. )
						TMJ->TMJ_CODUSU := cMedico
						TMJ->TMJ_DTCONS := dDiaAtu
						TMJ->TMJ_HRCONS := cNewHrIni
						TMJ->TMJ_QTDHRS := cNewQtHour
					TMJ->( MsUnLock() )
				EndIf
			EndIf
		EndIf

		If lRet
			If !Empty( cNewHrIni ) .And. !Empty( cNewQtHour )

				cConsFin := MTOH( HTOM( cNewHrIni ) + HTOM( cNewQtHour ) )
				MsgAlert( STR0087 + cNewHrIni + STR0047 + cConsFin + STR0088 + ".", STR0003 )//"O horário para à consulta ficou das: " ###" às " ###" horas" ###"Atenção"

				If IsInCallStack( "MDTA410" ) .And. INCLUI
					//atualiza os valores da memória
					&( cPrefix + "_HRCONS" ) := cNewHrIni
					&( cPrefix + "_QTDHRS" ) := cNewQtHour
				Else
					If IsInCallStack( "MDTA076" )
						dbSelectArea( cAliasAte )
						dbSetOrder( 4 ) //CODUSU+DtoS(DTCONS)+HRCONS
						If dbSeek( cMedico + DtoS( dDiaAtu ) + cNewHrIni ) //se encontrar o valor novo, devera atualizar
							RecLock( cAliasAte, .F. )
							( cAliasAte )->HRCONS := cNewHrCons
							( cAliasAte )->( MsUnLock() )
						EndIf
						dbSelectArea( cAliasAte )
						dbSetOrder( 4 ) //CODUSU+DtoS(DTCONS)+HRCONS
						If dbSeek( __cMedico + DtoS( __dDtCons ) + __cHrCons ) //se encontrar o valor antigo, devera atualizar
							RecLock( cAliasAte, .F. )
							( cAliasAte )->CODUSU := cMedico
							( cAliasAte )->HRCONS := cNewHrIni
							( cAliasAte )->DTCONS := dDiaAtu
							( cAliasAte )->( MsUnLock() )
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea( aAreaTMJ )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076PDUI
Função para o botão 'Próximo Duração'ao Transferir Funcionário e possuir interferencia.

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 05/12/2016

@param lInclusao	, Logico	, Indica se é Inclusão(.T.) ou Encaixe(.F.).
@param cAliasVal	, Caracter	, Indica o Alias posicionado no momento TMJ ou TY9.
@param cHoraIni		, Caracter	, Horario inicial da consulta nova.
@param cQntHr		, Caracter	, Quantidade de horas da consulta nova.
@param cHoraFim		, Caracter	, Horario final da consulta nova.
@param dDiaAtu		, Data		, Data da consulta.
@param cAliasENC	, Caracter	, Alias da query do encaixe.

@sample MDT076PDU( .T., "TMJ", "08:10", "00:10", "08:20", 11/10/2016, "TABTEMP001" )

@return Logico, Indica se todas validações estão corretas.
/*/
//---------------------------------------------------------------------
Function MDT076PDUI( lInclusao, cAliasVal, cHoraIni, cQntHr, cHoraFim, dDiaAtu, cAliasENC, cHora, lTransf )

	Local aAgendas		:= {}
	Local cPrefix 		:= "M->" + PrefixoCPO( cAliasVal )
	Local cQtdHrsENC	:= "" //Tempo de consulta
	Local cNewHrCons	:= "" //Novo horario da consulta
	Local cHrFim		:= "" //horario final do atendimento
	Local cInterv		:= "" //Indica se o tempo de intervalo é maior que 5 minutos
	Local lRet			:= .T.
	Local lFirst		:= .T. //Indica que é o primeiro registro
	Local lInterv		:= .F. //Indica que possui intervalor entre os agendamentos
	Local nX			:= 0

	dbSelectArea( cAliasENC )
	DbGoTop()
	While ( cAliasENC )->( !Eof() )

		//se campo de quantidade de horas estiver vazio recebe da Agenda
		If Empty( ( cAliasENC )->QTDHRS )
			cQtdHrsENC := fVldQtdHrs( ( cAliasENC )->CODUSU )
		Else
			cQtdHrsENC := ( cAliasENC )->QTDHRS
		EndIf
		cNewHrCons := MTOH( HTOM( ( cAliasENC )->HRCONS ) + HTOM( cQtdHrsENC ) )

		aAdd( aAgendas, { ( cAliasENC )->HRCONS, cQtdHrsENC, cNewHrCons } ) //add no array o proximos horarios

		dbSelectArea( cAliasENC )
		( cAliasENC )->( DbSkip() )
	End

	//verifica se possui horario entre os agendamentos
	For nX := 1 To Len( aAgendas )
		If !lFirst
			 //subtrai o horario final do anterior com o próximo para verificar intervalo entre elas
			cInterv := MTOH( HTOM( aAgendas[nX, 1] ) - HTOM( cHrFim ) )
			If cInterv >= cQntHr //verifica se o intervalor é igual ou superior ao da consulta nova
				lInterv := .T.
				Exit
			EndIf
		EndIf
		cHrFim := aAgendas[nX, 3]
		lFirst := .F.
	Next nX

	//se possui intervalo entre os agendamentos
	If lInterv

		//Novo horario inicial e tempo da consulta
		cNewHrIni := cHrFim
		cNewQtHour := cQntHr

	Else //se não deverá pegar o horario final do ultimo atendimento

		//Verifica se possui o tempo minimo de atendimento no dia para ser possivel incluir - 5 Minutos
		cHour := MTOH( HTOM( cHrFim ) + HTOM( cQntHr ) )
		If cHour <= "24:00"

			//Novo horario inicial e tempo da consulta
			cNewHrIni := cHrFim
			cNewQtHour := cQntHr

		Else //não possui horario disponivel para incluir no dia selecionado
			MsgAlert( STR0140 )
			lRet := .F.
		EndIf

	EndIf
	cConsFin := MTOH( HTOM( cNewHrIni ) + HTOM( cNewQtHour ) )
	MsgAlert( STR0087 + cNewHrIni + STR0047 + cConsFin + STR0088 + ".", STR0003 )//"O horário para à consulta ficou das: " ###" às " ###" horas" ###"Atenção"

	If !IsInCallStack( "MDTA161" )
		If IsInCallStack( "MDTA410" ) .And. INCLUI
			//atualiza os valores da memória
			&( cPrefix + "_HRCONS" ) := cNewHrIni
			&( cPrefix + "_QTDHRS" ) := cNewQtHour
		Else

			dbSelectArea( "TMJ" )
			dbSetOrder( 1 )
			If dbSeek( xFilial( "TMJ" ) + __cMedico + DTOS( __dDtCons ) + __cHrCons )
				RecLock( "TMJ", .F. )
					TMJ->TMJ_CODUSU := cMedico
					TMJ->TMJ_DTCONS := dDiaAtu
					TMJ->TMJ_HRCONS := cNewHrIni
					TMJ->TMJ_QTDHRS := cNewQtHour
				TMJ->( MsUnLock() )
			EndIf

			If IsInCallStack( "MDTA076" )
				//deve atualizar o TRB, para atualizar o shape
				dbSelectArea( cAliasAte )
				dbSetOrder( 4 ) //CODUSU+DtoS(DTCONS)+HRCONS
				If dbSeek( __cMedico + DtoS( __dDtCons ) + __cHrCons ) //se encontrar o valor antigo, devera atualizar
					RecLock( cAliasAte, .F. )
						( cAliasAte )->CODUSU := cMedico
						( cAliasAte )->DTCONS := dDiaAtu
						( cAliasAte )->HRCONS := cNewHrIni
					( cAliasAte )->( MsUnLock() )
				EndIf
			EndIf

			//Deverá receber o novo valor para fazer a gravação correta no MDTA160
			cHrCons := cNewHrIni
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076PDI
Função para o botão 'Próximo disponivel' ao Transferir Funcionário e possuir interferencia.

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 11/10/2016

@param lInclusao	, Logico	, Indica se é Inclusão(.T.) ou Encaixe(.F.).
@param cAliasVal	, Caracter	, Indica o Alias posicionado no momento TMJ ou TY9.
@param cHoraIni		, Caracter	, Horario inicial da consulta nova.
@param cQntHr		, Caracter	, Quantidade de horas da consulta nova.
@param cHoraFim		, Caracter	, Horario final da consulta nova.
@param dDiaAtu		, Data		, Data da consulta.
@param cAliasENC	, Caracter	, Alias da query do encaixe.

@sample MDT076PDI( .T., "TMJ", "08:10", "00:10", "08:20", 11/10/2016, "TABTEMP001" )

@return Logico, Indica se todas validações estão corretas.
/*/
//---------------------------------------------------------------------
Function MDT076PDII( lInclusao, cAliasVal, cHoraIni, cQntHr, cHoraFim, dDiaAtu, cAliasENC )

	Local aAgendas		:= {}
	Local aAreaTMJ 		:= TMJ->( GetArea() )
	Local cPrefix 		:= "M->" + PrefixoCPO( cAliasVal )
	Local cQtdHrsENC	:= "" //Tempo de consulta
	Local cNewHrCons	:= "" //Novo horario da consulta
	Local cHrFim		:= "" //horario final do atendimento
	Local cInterv		:= "" //Indica se o tempo de intervalo é maior que 5 minutos
	Local lRet			:= .T.
	Local lFirst		:= .T. //Indica que é o primeiro registro
	Local lInterv		:= .F. //Indica que possui intervalor entre os agendamentos
	Local nX			:= 0

	dbSelectArea( cAliasENC )
	DbGoTop()
	While ( cAliasENC )->( !Eof() )

		//se campo de quantidade de horas estiver vazio recebe da Agenda
		If Empty( ( cAliasENC )->QTDHRS )
			cQtdHrsENC := fVldQtdHrs( ( cAliasENC )->CODUSU )
		Else
			cQtdHrsENC := ( cAliasENC )->QTDHRS
		EndIf
		cNewHrCons := MTOH( HTOM( ( cAliasENC )->HRCONS ) + HTOM( cQtdHrsENC ) )

		aAdd( aAgendas, { ( cAliasENC )->HRCONS, cQtdHrsENC, cNewHrCons } ) //add no array o proximos horarios

		dbSelectArea( cAliasENC )
		( cAliasENC )->( DbSkip() )
	End

	//verifica se possui horario entre os agendamentos
	For nX := 1 To Len( aAgendas )
		If !lFirst
			 //subtrai o horario final do anterior com o próximo para verificar intervalo entre elas
			cInterv := MTOH( HTOM( aAgendas[nX, 1] ) - HTOM( cHrFim ) )
			If cInterv >= "00:05"
				lInterv := .T.
				Exit
			EndIf
		EndIf
		cHrFim := aAgendas[nX, 3]
		lFirst := .F.
	Next nX

	//se possui intervalo entre os agendamentos
	If lInterv

		//Novo horario inicial da consulta
		cNewHrIni := cHrFim

		//verifica se tempo de atendimento é maior do que o disponivel
		If cQntHr > cInterv
			//recebe o valor disponivel
			cNewQtHour := cInterv
		Else //permanecerá igual
			cNewQtHour := cQntHr
		EndIf

	Else //se não deverá pegar o horario final do ultimo atendimento

		//Verifica se possui o tempo minimo de atendimento no dia para ser possivel incluir - 5 Minutos
		If cHrFim <= "23:55"

			//Novo horario inicial da consulta
			cNewHrIni := cHrFim

			//-----------------------------------------------------------------------
			//Verifica se deverá alterar o tempo de atendimento da consulta
			//se horario final do ultimo atendimento mais a quantidade de tempo da consulta nova é maior que 23:59
			lTermino := MTOH( HTOM( cHrFim ) + HTOM( cQntHr ) ) > "23:59"

			If lTermino //deverá diminuir o tempo de consulta
				cNewQtHour := MTOH( HTOM( "24:00" ) - HTOM( cHrFim ) ) //novo tempo de consulta
			Else //se não o tempo de atendimento permanecerá o mesmo
				cNewQtHour := cQntHr
			EndIf
			//-----------------------------------------------------------------------

		Else //não possui horario disponivel para incluir no dia selecionado
			MsgAlert( STR0121 ) //"Não possui próximo horário disponível."
			lRet := .F.
		EndIf

	EndIf

	cConsFin := MTOH( HTOM( cNewHrIni ) + HTOM( cNewQtHour ) )
	MsgAlert( STR0087 + cNewHrIni + STR0047 + cConsFin + STR0088 + ".", STR0003 )//"O horário para à consulta ficou das: " ###" às " ###" horas" ###"Atenção"

	//----------------------
	//Deverá alterar o valor de Quantidade de horas da consulta transferida
	//----------------------
	If !IsInCallStack( "MDTA161" )
		If IsInCallStack( "MDTA410" ) .And. INCLUI
			//atualiza os valores da memória
			&( cPrefix + "_HRCONS" ) := cNewHrIni
			&( cPrefix + "_QTDHRS" ) := cNewQtHour
		Else
			dbSelectArea( "TMJ" )
			dbSetOrder( 1 )
			If dbSeek( xFilial( "TMJ" ) + __cMedico + DTOS( __dDtCons ) + __cHrCons )
				RecLock( "TMJ", .F. )
					TMJ->TMJ_CODUSU := cMedico
					TMJ->TMJ_DTCONS := dDiaAtu
					TMJ->TMJ_HRCONS := cNewHrIni
					TMJ->TMJ_QTDHRS := cNewQtHour
				TMJ->( MsUnLock() )
			EndIf

			If IsInCallStack( "MDTA076" )
				//deve atualizar o TRB, para atualizar o shape
				dbSelectArea( cAliasAte )
				dbSetOrder( 4 ) //CODUSU+DtoS(DTCONS)+HRCONS
				If dbSeek( __cMedico + DtoS( __dDtCons ) + __cHrCons ) //se encontrar o valor antigo, devera atualizar
					RecLock( cAliasAte, .F. )
						( cAliasAte )->CODUSU := cMedico
						( cAliasAte )->DTCONS := dDiaAtu
						( cAliasAte )->HRCONS := cNewHrIni
					( cAliasAte )->( MsUnLock() )
				EndIf
			EndIf
			//Deverá receber o novo valor para fazer a gravação correta no MDTA160
			cHrCons := cNewHrIni

		EndIf
	EndIf

	RestArea( aAreaTMJ )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076PTTI
Função para o botão 'Postergar Todos' ao Transferir Funcionário e possuir interferencia.

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 11/10/2016

@param lInclusao	, Logico	, Indica se é Inclusão(.T.) ou Encaixe(.F.).
@param cAliasVal	, Caracter	, Indica o Alias posicionado no momento TMJ ou TY9.
@param cHoraIni		, Caracter	, Horario inicial da consulta nova.
@param cQntHr		, Caracter	, Quantidade de horas da consulta nova.
@param cHoraFim		, Caracter	, Horario final da consulta nova.
@param dDiaAtu		, Data		, Data da consulta.
@param cAliasENC	, Caracter	, Alias da query do encaixe.

@sample MDT076PTT( .T., "TMJ", "08:10", "00:10", "08:20", 11/10/2016, "TABTEMP001" )

@return Logico, Indica se todas validações estão corretas.
/*/
//---------------------------------------------------------------------
Function MDT076PTTI( lInclusao, cAliasVal, cHoraIni, cQntHr, cHoraFim, dDiaAtu, cAliasENC, cHora, lTransf  )

	Local aAgendas		:= {}
	Local aHorInt		:= {}
	Local cPrefix 		:= "M->" + PrefixoCPO( cAliasVal )
	Local cQtdHrsENC	:= "" //Tempo de consulta
	Local cNewHrCons	:= "" //Novo horario da consulta
	Local cAlsQry		:= "" //Alias da Query de Busca da TMJ
	Local cAlsQryTY9	:= "" //Alias da Query de Busca da TY9
	Local cAlsQryTMJ	:= "" //Alias da Query para somar Quantidade TMJ
	Local cQryTY9Qt		:= "" //Alias da Query para somar Quantidade TY9
	Local lRet			:= .T.
	Local lFirst		:= .T. //Indica que é o primeiro registro
	Local lAltera		:= .F. //Indica que deverá ser alterado o tempo de consulta
	Local nX			:= 0

	dbSelectArea( cAliasENC )
	DbGoTop()
	While ( cAliasENC )->( !Eof() )

		cHrCnsEnc := ( cAliasENC )->HRCONS
		cQtdHrsENC := ( cAliasENC )->QTDHRS
		//se for Encaixe e primeiro registro
		If !lInclusao .And. lFirst
			lFirst := .F.
			//verifica se novo horário é diferente do selecionado
			//e tambem verifica se horario final da consulta nova é maior que horario inicial da proxima consulta em conflito
			//se for diferente ñ deverá add no array
			If cHrCnsEnc != cHoraIni .And. cHoraIni > cHrCnsEnc
				lAltera := .T.
				dbSelectArea( cAliasENC )
				( cAliasENC )->( DbSkip() )
				Loop
			EndIf
		EndIf

		//Deverá sair do while, pois ñ possui registro posterior
		If !Empty( ( cAliasENC )->CODUSU )
			//se campo de quantidade de horas estiver vazio recebe da Agenda
			If Empty( ( cAliasENC )->QTDHRS )
				cQtdHrsENC := fVldQtdHrs( ( cAliasENC )->CODUSU )
			Else
				cQtdHrsENC := ( cAliasENC )->QTDHRS
			EndIf
			cNewHrCons := MTOH( HTOM( ( cAliasENC )->HRCONS ) + HTOM( cQtdHrsENC ) )
		Else
			//Joga o ultimo horario do dia para Postergar os horarios
			//corretamente, pois ñ possui horario posterior ao selecionado
			cHrCnsEnc := "23:55"
			cQtdHrsENC := "00:05"
			cNewHrCons := MTOH( HTOM( cHrCnsEnc ) + HTOM( cQtdHrsENC ) )
		EndIf

		aAdd( aAgendas, { cHrCnsEnc, cQtdHrsENC, cNewHrCons } ) //add no array o proximos horarios

		dbSelectArea( cAliasENC )
		( cAliasENC )->( DbSkip() )
	End

	If lRet
		cOldHor := cHoraIni
		cOldQnt := cQntHr
		cOldTot := MTOH( HTOM( cOldHor ) + HTOM( cOldQnt ) )

		//Add em outro array somente os proximos horarios que interferir
		For nX := 1 To Len( aAgendas )
			//verifica se horario final da consulta esta dentro da proxima
			If aAgendas[ nX, 1 ] < cOldTot
				cOldHor := cOldTot
				cOldQnt := aAgendas[ nX, 2 ]
				cOldTot := MTOH( HTOM( cOldHor ) + HTOM( cOldQnt ) )
				aAdd( aHorInt, { cOldHor, cOldQnt, cOldTot, aAgendas[ nX, 1 ] } )
			Else
				Exit
			EndIf
		Next nX

		//verifica se possui algum agendamento com atendimento
		//vai retornar .F. se possuir Atendimentos
		If !MDT076ATEN( aHorInt, cMedico, dDiaAtu )
			ShowHelpDlg( STR0003, { STR0077 }, 2,; //"Atenção"###"Não é possível postergar os próximos horários, pois possui atendimentos realizados."
						 { STR0078  }, 2 )         //"Favor selecionar outra opção para o horário atual ou alterar o tempo de consulta."
			lRet := .F.
		EndIf

		//verifica se algum horário vai passar das 24:00hrs
		If lRet
			If aScan( aHorInt, { | x | x[ 3 ] > "24:00" } ) > 0
				ShowHelpDlg( STR0003, { STR0105 }, 2,; //"Atenção"###"Possui algum agendamento que vai ter início e término em datas diferentes."
							 { STR0086 }, 2 )          //"Favor alterar o tempo de consulta."
				lRet := .F.
			EndIf
		EndIf

		If lRet
			//Diminui o tempo de atendimento, caso o horario inicial da nova consulta estiver entre algum horário incluso
			If !lInclusao .And. lAltera
				If IsInCallStack( "MDTA410" )

					cAlsQryTMJ := GetNextAlias()
					BeginSql Alias cAlsQryTMJ
						SELECT TMJ_CODUSU, TMJ_NUMFIC, TMJ_DTCONS, TMJ_HRCONS, TMJ_QTDHRS, R_E_C_N_O_ FROM %Table:TMJ% TMJ
							WHERE TMJ.%NotDel% AND
							TMJ.TMJ_FILIAL = %xFilial:TMJ% AND
							TMJ.TMJ_CODUSU = %exp:cMedico% AND
							TMJ.TMJ_DTCONS = %exp:dDiaAtu% AND
							TMJ.TMJ_HRCONS = %exp:cHora%
					EndSql
					If ValType( ( cAlsQryTMJ )->R_E_C_N_O_ ) == "N" .And. ( cAlsQryTMJ )->R_E_C_N_O_ > 0

						aAreaAtu := GetArea()
							cQry := "UPDATE " + RetSqlName( "TMJ" )
							cQry += " SET TMJ_QTDHRS = '" + MTOH( HTOM( cHoraIni ) - HTOM( cHora ) ) + "'"
							cQry += " WHERE TMJ_FILIAL = " + ValToSQL( xFilial( "TMJ" ) )
							cQry += " AND TMJ_CODUSU = '" + cMedico + "'"
							cQry += " AND TMJ_DTCONS = '" + DtoS( dDiaAtu ) + "'"
							cQry += " AND TMJ_HRCONS = '" + cHora + "'"
							cQry += " AND D_E_L_E_T_ = ' '"

							TCSQLExec( cQry )
						RestArea( aAreaAtu )
					Else //Caso ñ encontrar a TMJ deverá verificar se é TY9
						cQryTY9Qt := GetNextAlias()
						BeginSql Alias cQryTY9Qt
							SELECT TY9_CODUSU, TY9_DTCONS, TY9_HRCONS, TY9_QTDHRS, R_E_C_N_O_ FROM %Table:TY9% TY9
								WHERE TY9.%NotDel% AND
								TY9.TY9_FILIAL = %xFilial:TY9% AND
								TY9.TY9_CODUSU = %exp:cMedico% AND
								TY9.TY9_DTCONS = %exp:dDiaAtu% AND
								TY9.TY9_HRCONS = %exp:cHora%
						EndSql
						If ValType( ( cQryTY9Qt )->R_E_C_N_O_ ) == "N" .And. ( cQryTY9Qt )->R_E_C_N_O_ > 0

							aAreaAtu := GetArea()
								cQry := "UPDATE " + RetSqlName( "TY9" )
								cQry += " SET TY9_QTDHRS = '" + MTOH( HTOM( cHoraIni ) - HTOM( cHora ) ) + "'"
								cQry += " WHERE TY9_FILIAL = " + ValToSQL( xFilial( "TY9" ) )
								cQry += " AND TY9_CODUSU = '" + cMedico + "'"
								cQry += " AND TY9_DTCONS = '" + DtoS( dDiaAtu ) + "'"
								cQry += " AND TY9_HRCONS = '" + cHora + "'"
								cQry += " AND D_E_L_E_T_ = ' '"

								TCSQLExec( cQry )
							RestArea( aAreaAtu )
						EndIf
					EndIf


				Else
					dbSelectArea( "TMJ" )
					dbSetOrder( 1 )
					If dbSeek( xFilial( "TMJ" ) + cMedico + DTOS( dDiaAtu ) + cHora )
						RecLock( "TMJ", .F. )
							TMJ->TMJ_QTDHRS := MTOH( HTOM( cHoraIni ) - HTOM( cHora ) )
						Msunlock( "TMJ" )
					Else
						dbSelectArea( "TY9" )
						dbSetOrder( 1 )
						If dbSeek( xFilial( "TY9" ) + cMedico + DTOS( dDiaAtu ) + cHora )
							RecLock( "TY9", .F. )
								TY9->TY9_QTDHRS := MTOH( HTOM( cHoraIni ) - HTOM( cHora ) )
							Msunlock( "TY9" )
						EndIf
					EndIf
				EndIf
			EndIf

			//Ordena por ordem decrescente
			//Para ao Postergar Todos não haver conflitos de horário
			ASort( aHorInt, , , { | x, y | x[ 1 ] > y[ 1 ] } )

			//Realiza gravação dos novos valores
			For nX := 1 To Len( aHorInt )
				//Realiza a busca da TMJ por Query pois não posiciona no MDTA410 devido ao browse inicial da TMJ
				If IsInCallStack( "MDTA410" )

					cAlsQry := GetNextAlias()
					BeginSql Alias cAlsQry
						SELECT TMJ_CODUSU, TMJ_NUMFIC, TMJ_DTCONS, TMJ_HRCONS, TMJ_QTDHRS, R_E_C_N_O_ FROM %Table:TMJ% TMJ
							WHERE TMJ.%NotDel% AND
							TMJ.TMJ_FILIAL = %xFilial:TMJ% AND
							TMJ.TMJ_CODUSU = %exp:cMedico% AND
							TMJ.TMJ_DTCONS = %exp:dDiaAtu% AND
							TMJ.TMJ_HRCONS = %exp:aHorInt[ nX, 4 ]%
					EndSql
					If ValType( ( cAlsQry )->R_E_C_N_O_ ) == "N" .And. ( cAlsQry )->R_E_C_N_O_ > 0

						aAreaAtu := GetArea()
							cQry := "UPDATE " + RetSqlName( "TMJ" )
							cQry += " SET TMJ_HRCONS = '" + aHorInt[ nX, 1 ] + "'"
							cQry += " WHERE TMJ_FILIAL = " + ValToSQL( xFilial( "TMJ" ) )
							cQry += " AND TMJ_CODUSU = '" + cMedico + "'"
							cQry += " AND TMJ_DTCONS = '" + DtoS( dDiaAtu ) + "'"
							cQry += " AND TMJ_HRCONS = '" + aHorInt[ nX, 4 ] + "'"
							cQry += " AND D_E_L_E_T_ = ' '"

							TCSQLExec( cQry )
							MDT076ATU( cMedico, ( cAlsQry )->TMJ_NUMFIC, dDiaAtu, aHorInt[ nX, 4 ], aHorInt[ nX, 1 ] )
						RestArea( aAreaAtu )
					Else //Caso ñ encontrar a TMJ deverá verificar se é TY9
						cAlsQryTY9 := GetNextAlias()
						BeginSql Alias cAlsQryTY9
							SELECT TY9_CODUSU, TY9_DTCONS, TY9_HRCONS, TY9_QTDHRS, R_E_C_N_O_ FROM %Table:TY9% TY9
								WHERE TY9.%NotDel% AND
								TY9.TY9_FILIAL = %xFilial:TY9% AND
								TY9.TY9_CODUSU = %exp:cMedico% AND
								TY9.TY9_DTCONS = %exp:dDiaAtu% AND
								TY9.TY9_HRCONS = %exp:aHorInt[ nX, 4 ]%
						EndSql
						If ValType( ( cAlsQryTY9 )->R_E_C_N_O_ ) == "N" .And. ( cAlsQryTY9 )->R_E_C_N_O_ > 0

							aAreaAtu := GetArea()
								cQry := "UPDATE " + RetSqlName( "TY9" )
								cQry += " SET TY9_HRCONS = '" + aHorInt[ nX, 1 ] + "'"
								cQry += " WHERE TY9_FILIAL = " + ValToSQL( xFilial( "TY9" ) )
								cQry += " AND TY9_CODUSU = '" + cMedico + "'"
								cQry += " AND TY9_DTCONS = '" + DtoS( dDiaAtu ) + "'"
								cQry += " AND TY9_HRCONS = '" + aHorInt[ nX, 4 ] + "'"
								cQry += " AND D_E_L_E_T_ = ' '"

								TCSQLExec( cQry )
							RestArea( aAreaAtu )
						EndIf
					EndIf

				Else
					dbSelectArea( "TMJ" )
					dbSetOrder( 1 )
					If dbSeek( xFilial( "TMJ" ) + cMedico + DTOS( dDiaAtu ) + aHorInt[ nX, 4 ] )
						RecLock( "TMJ", .F. )
							TMJ->TMJ_HRCONS := aHorInt[ nX, 1 ]
						TMJ->( MsUnLock() )
						MDT076ATU( cMedico, TMJ->TMJ_NUMFIC, dDiaAtu, aHorInt[ nX, 4 ], aHorInt[ nX, 1 ] )
					Else
						dbSelectArea( "TY9" )
						dbSetOrder( 1 )
						If dbSeek( xFilial( "TY9" ) + cMedico + DTOS( dDiaAtu ) + aHorInt[ nX, 4 ] )
							RecLock( "TY9", .F. )
								TY9->TY9_HRCONS := aHorInt[ nX, 1 ]
							TY9->( MsUnLock() )
						EndIf
					EndIf
					If IsInCallStack( "MDTA076" )
						//deve atualizar o TRB, para atualizar o shape
						dbSelectArea( cAliasAte )
						dbSetOrder( 4 ) //CODUSU+DtoS(DTCONS)+HRCONS
						If dbSeek( cMedico + DtoS( dDiaAtu ) + aHorInt[ nX, 4 ] ) //se encontrar o valor antigo, devera atualizar
							RecLock( cAliasAte, .F. )
							( cAliasAte )->HRCONS := aHorInt[ nX, 1 ]
							( cAliasAte )->( MsUnLock() )
						EndIf
					EndIf
				EndIf
			Next nX

		EndIf

		If !IsInCallStack( "MDTA161" )
			//Atualiza o registro selecionado para transferencia
			//Deverá gravar os novos valores na TMJ aqui para quando montar os shapes virem corretos
			dbSelectArea( "TMJ" )
			dbSetOrder( 1 )
			If dbSeek( xFilial( "TMJ" ) + __cMedico + DTOS( __dDtCons ) + __cHrCons )
				RecLock( "TMJ", .F. )
					TMJ->TMJ_CODUSU := cMedico
					TMJ->TMJ_DTCONS := dDiaAtu
					TMJ->TMJ_HRCONS := cHoraIni
					TMJ->TMJ_QTDHRS := cQntHr
				TMJ->( MsUnLock() )
			EndIf
		EndIf

		If IsInCallStack( "MDTA076" )
			dbSelectArea( cAliasAte )
			dbSetOrder( 4 ) //CODUSU+DtoS(DTCONS)+HRCONS
			If dbSeek( __cMedico + DtoS( __dDtCons ) + __cHrCons ) //se encontrar o valor antigo, devera atualizar
				RecLock( cAliasAte, .F. )
				( cAliasAte )->CODUSU := cMedico
				( cAliasAte )->DTCONS := dDiaAtu
				( cAliasAte )->HRCONS := cHoraIni
				( cAliasAte )->( MsUnLock() )
			EndIf
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT076DTMD
Função para verificar se o médico foi encerrado da sua função.

@type function

@source MDTA076.prw

@author Jean Pytter da costa
@since 27/02/2017

@param cCodUsu	, Caracter	, Indica o código do médico.

@sample MDT076DTMD( "00001" )

@return Logico, Indica se o médico está ativo.
/*/
//---------------------------------------------------------------------
Function MDT076DTMD( cCodUsu )

	Local lRet := .T.

	dbSelectArea( "TMK" )
	dbSetOrder( 1 ) //TMK_FILIAL+TMK_CODUSU
	If dbSeek( xFilial( "TMK" ) + cCodUsu )
		If !Empty( TMK->TMK_DTTERM ) .And. TMK->TMK_DTTERM < dDataBase
			ShowHelpDlg( STR0003,;        //"ATENÇÃO"
						 { STR0126 }, 2,; //"Não é possível realizar o agendamento neste usuário porque o usuário não exerce mais esta função na empresa."
						 { STR0127 }, 2 ) //"Favor selecionar outro usuário para realizar o Agendamento."
			lRet := .F.
		EndIf
	EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} A076XBTMK
Função que busca os médicos (TMK) que possuem registros sem data de término.

@type Function
@author Roberta S. Borchardt
@since 31/07/2020

@return  lRet, verdadeiro se encontrar o médico.
/*/
//---------------------------------------------------------------------
Function A076XBTMK()

	Local lRet	    := .F.
	Local dDataTerm := CTOD( "  /  /    " )
	Local aArea := GetArea()

	IF IsInCallStack( 'MDTA076' )
		dbSelectArea( "TMK" )
		dbSetOrder( 1 )// TMK_FILIAL+TMK_CODUSU

		If dbSeek( TML->TML_FILIAL + TML->TML_CODUSU )

			dDataTerm := TMK->TMK_DTTERM

			If Empty( dDataTerm ) .Or. dDataTerm > dDataBase // Verifica se tem data de término
				lRet:= .T.
			Else
				lRet:= .F.
			EndIf
			RestArea( aArea )
		EndIf
	Else // Caso seja chamado pelo MDTA410
		dbSelectArea( "TMK" )
		dbSetOrder( 1 ) // TMK_FILIAL+TMK_CODUSU
		lRet := dbSeek( TML->TML_FILIAL + TML->TML_CODUSU )
	EndIf

Return lRet
