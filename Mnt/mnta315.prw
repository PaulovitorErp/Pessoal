#INCLUDE "mnta315.ch"
#Include "Protheus.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA315
Programa para Distribuicao de Solicitacao de Servico em lote
@author Ricardo Dal Ponte
@since 09/01/2007
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function MNTA315()

	Local aNGBeginPrm := {}

	If MNTAmIIn( 19, 95 )

		aNGBeginPrm := NGBeginPrm()

		//Verifica se o update de facilities foi aplicado
		If FindFunction("MNTUPDFAC") .And. MNTUPDFAC(.F.)
			ShowHelpDlg(STR0046, {STR0047},1,{STR0048}) //"ATENÇÃO" ## "O sistema está utilizando o Módulo Facilities. Desta forma, a distribuição em lote deve ser realizada através da rotina de Distribuição." ## "Será redirecionado para a rotina de Distribuição."
			MNTA296()
			Return .F.
		EndIf

		Private asMenu

		asMenu := NGRIGHTCLICK("MNTA315")

		Private cTRB315 := GetNextAlias()
		Private oTmpTbl1

		Private aVETINR := {}
		Private cPESQUI := ""
		Private aPESQUI := {STR0001,;  //"Solicitação"
							STR0002,;  //"Bem/Localização+Serviço"
							STR0003,;  //"Bem/Localização+Centro Custo+Serviço"
							STR0004,;  //"Bem/Localização+Data Abertura"
							STR0005,;  //"Solicitante+Serviço"
							STR0006,;  //"Solicitante+Centro Custo+Serviço"
							STR0007,;  //"Solicitante+Serviço+Data Abertura"
							STR0008,;  //"Data Abertura+Solicitante"
							STR0009,;  //"Data Abertura+Centro Custo"
							STR0010,;  //"Serviço+Centro Custo"
							STR0011}   //"Serviço+Data Abertura"

		Private aPESQUIF := {"TQB_SOLICI"                             ,;
							"TQB_CODBEM+TQB_NOMSER"                  ,;
							"TQB_CODBEM+TQB_NMCUST+TQB_NOMSER"       ,;
							"TQB_CODBEM+DTOS(TQB_DTABER)"            ,;
							"TQB_NMSOLI+TQB_NOMSER"                  ,;
							"TQB_NMSOLI+TQB_NMCUST+TQB_NOMSER"       ,;
							"TQB_NMSOLI+TQB_NOMSER+DTOS(TQB_DTABER)" ,;
							"DTOS(TQB_DTABER)+TQB_NMSOLI"            ,;
							"DTOS(TQB_DTABER)+TQB_NMCUST"            ,;
							"TQB_NOMSER+TQB_NMCUST"                  ,;
							"TQB_NOMSER+DTOS(TQB_DTABER)"            }

		Private aCpos      := {}
		Private aCampos    := {}
		Private aRotina    := MenuDef()
		Private cInd1TRB
		Private cMarca
		Private cPAlta     := "1"
		Private cPMedia    := "2"
		Private cPBaixa    := "3"
		Private lSH1       := .F.
		Private lALLMARK   := .F.
		Private bFiltraBrw := {|| Nil}

		Private cCadastro := Oemtoansi(STR0012) //"Distribuição de Solicitação de Servico em Lote"
		Private lDigServ  := .T.
		Private lLEABRE   := .F.
		Private lLEFECHA  := .T.
		Private lTEMFACI  := .F.
		Private lSSClassi := .T.
		Private lSSPriori := .T.

		Private aHeader   := {}
		Private cARQUISAI := "XXX"
		Private cPROGRAMA := "MNTA315"
		Private cMarcaEK
		Private cMEMOCHF
		Private cMEMOTEF
		PrivaTe cMEMOTES

		//CRIA ARQUIVO TEMPORARIO
		A315WDET()
		
		/*----------------------------------------+
		| Carrega registros na tabela temporária. |
		+----------------------------------------*/
		MNTA315TRB()

		dbSelectArea(cTRB315)
		dbSetOrder(12)
		dbGoTop()

		cMarcaEK := GetMark()

		MarkBrow( cTRB315, "TQB_MKBROW", , aCpos, , cMarcaEK, 'A315ALLMAR(cTRB315)', , , , 'A315UNIMAR(cTRB315)')

		oTmpTbl1:Delete()

		Set Filter To

		//+---------------------------------------------------+
		//| Devolve variaveis armazenadas (NGRIGHTCLICK)      |
		//+---------------------------------------------------+
		NGRETURNPRM(aNGBEGINPRM)

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA315DIS
Distribuicao da solicitacao de servico
@author Ricardo Dal Ponte
@since 06/12/2006
@version undefined
@param cCADNOV, characters, descricao
@type function
/*/
//---------------------------------------------------------------------
Function MNTA315DIS(cCADNOV)

	Local nContX
	Local nContY
	Local cMsgSS    := ""
	Local cDesc     := ""
	Local lEnvWorkf := .F.
	Local lMNTA3153 	:= ExistBlock("MNTA3153")
	Local aSolici   := {}
	Local aOfusc    := {}
	Local nX        := 0
	Local nSolic    := 0
	Local aDistri   := {}
	Local lRPORel17 := IIf(GetRPORelease() <= '12.1.017', .T., .F.) // Release menor ou igual a 17
	Local oGet1
	// [LGPD] Se as funcionalidades, referentes à LGPD, podem ser utilizadas
	Local lLgpd := FindFunction( 'FWPDCanUse' ) .And. FwPdCanUse( .T. )
	Local lEmail := .F.
	Local lNomExe := .F.

	Private cNMRESP  := Space(40)
	Private cCDSERV  := Space(Len(TQ3->TQ3_CDSERV))
	Private cNMSERV  := Space(Len(TQ3->TQ3_NMSERV))
	Private cCDEXEC  := Space(Len(TQ4->TQ4_CDEXEC))
	Private cNMEXEC  := Space(Len(TQ4->TQ4_NMEXEC))
	Private cDESCSS  := Space(80)
	Private aPRIORI  := {}
	PrivaTe cPriori  := ''
	Private oMenu

	If lLgpd
		// [LGPD] Caso o usuário não possua acesso ao(s) campo(s), deve-se ofuscá-lo(s)
		aOfusc := FwProtectedDataUtil():UsrAccessPDField( __CUSERID, { 'TQ4_EMAIL1', 'TQ4_NMEXEC' } )
		lEmail := Ascan( aOfusc, { |x|  AllTrim(x) == 'TQ4_EMAIL1' } ) == 0
		lNomExe := Ascan( aOfusc, { |x|  AllTrim(x) == 'TQ4_NMEXEC' } ) == 0
	EndIf

	aPRIORI := {STR0013, STR0014, STR0015, ""} //"Alta"###"Media"###"Baixa"###"Sem opção"

	//--inicio--SS 027048 //
	//Na SS 027048 foi solicitado um ponto de entrada para mostrar registros de todas as filiais na distribuição de SS.
	//Porém para distribuir em lote é necessário fazer diversas validações, visto que pode distruibir de filiais diferente.
	//Nesse caso, o a filial logada é jogada para uma filial de bkp.
	cFilAntBkp := cFilAnt
	//---fim----SS 027048 //

	Private cServ     := ""
	Private lPreenche := .T.
	dbSelectArea(cTRB315)
	dbGoTop()
	While !Eof()
		If (cTRB315)->TQB_MKBROW = cMarcaEK

			//--inicio--SS 027048 //
			//Considera para como filial logada a filial do registro da linha da get dados. A variavel cFilAnt influencia no retorno da dos xFilial,
			//por isso é feita essa validação, para sempre validar conforme a filial do registro.
			cFilAnt := (cTRB315)->TQB_FILIAL
			//---fim----SS 027048 //

			dbSelectArea("TQB")
			dbSetOrder (1)
			If dbSeek(xFilial("TQB")+(cTRB315)->TQB_SOLICI)
				If Empty(cServ)
					cServ := TQB->TQB_CDSERV
				EndIf
				If cServ != TQB->TQB_CDSERV
					lPreenche := .F.
				EndIf

				nPos := aSCAN(aSolici,{|x| x[1] == TQB->TQB_CODBEM})
				If nPos > 0
					aAdd(aSolici[nPos],TQB->TQB_SOLICI)
				Else
					aAdd(aSolici,{TQB->TQB_CODBEM,TQB->TQB_SOLICI})
				EndIf
			EndIf
		EndIf
		dbSelectArea(cTRB315)
		dbSkip()
	EndDo

	cFilAnt := cFilAntBkp

	For nContX := 1 To Len(aSolici)
		If Len(aSolici[nContX]) > 2
			For nContY := 2 To Len(aSolici[nContX])
				cMsgSS += "- SS "+aSolici[nContX,nContY]+CHR(13)
			Next nConY
		EndIf

		If !Empty(cMsgSS)
			If !APMSGNOYES(STR0037+CHR(13)+;  //"Foram selecionadas Solicitações de Serviço com duplicidade no Bem/Localização"
			STR0038+"'"+AllTrim(aSolici[nContX,1])+"' "+STR0039+AllTrim(NGRETTITULO('TQB_CDSERV'))+":"+; //"para "##"que serão distribuídas com o mesmo "
			CHR(13)+cMsgSS+CHR(13)+STR0040,STR0041) //"Deseja prosseguir com a distribuição?"##"Duplicidade de S.S."
				Return .F.
			Else
				cMsgSS := ""
			EndIf
		EndIf
	Next nContX

	If lPreenche .And. !Empty(cServ)
		cCDSERV := cServ
		A315EXV(cCDSERV)
	EndIf

	nOPCA := 0
	If Len(cCDEXEC) > 15

		DEFINE MSDIALOG oDLGB TITLE OemToAnsi(STR0012) From 15,20 To 34,109 OF oMainWnd //"Distribuição de Solicitação de Servico em Lote"
		oDLGB:lMaximized := .t.
		oPanel := TPanel():New(0, 0, Nil, oDLGB, Nil, .T., .F., Nil, Nil, 0, 0, .T., .F. )
		oPanel:Align := CONTROL_ALIGN_ALLCLIENT

		@ 0.5,01  SAY OemToAnsi(STR0016) SIZE 6,7 OF oPanel 							//"Supervisor"
		@ 0.4,06  MSGET cNMRESP Picture '@!' SIZE 150,7 When .F. OF oPanel

		@ 1.5,01  SAY OemToAnsi(STR0017) SIZE 6,7 COLOR CLR_HBLUE OF oPanel 			//"Tipo Servico"
		@ 1.4,06  MSGET cCDSERV Picture '@!' SIZE 30,7 F3 "TQ3" OF oPanel Valid If(Empty(cCDSERV),.t.,ExistCpo('TQ3',cCDSERV)) .And. A315EXV(cCDSERV) HASBUTTON
		@ 1.5,19  SAY OemToAnsi(STR0018)SIZE 6,7 OF oPanel  							//"Nome Servico"
		@ 1.4,26  MSGET cNMSERV Picture '@!' SIZE 138,7 When .F. OF oPanel

		@ 2.5,01  SAY OemToAnsi(STR0019) SIZE 6,7 COLOR CLR_HBLUE OF oPanel 			//"Executante"
		@ 2.4,06  MSGET cCDEXEC Picture '@!' SIZE 96,7 F3 "TQ4" OF oPanel Valid If(Empty(cCDEXEC),.t.,ExistCpo('TQ4',cCDEXEC)) .And. A315EXEC(cCDEXEC) HASBUTTON
		@ 2.5,19  SAY OemToAnsi(STR0020) SIZE 6,7 OF oPanel 							//"Nome Executante"
		@ 2.4,26  MSGET oGet1 Var cNMEXEC Picture '@!' SIZE 138,7 When .F. OF oPanel
		If lNomExe
			oGet1:lObfuscate := .T.
			oGet1:bWhen := {|| .F. }
		EndIf

		If X3Obrigat("TQB_PRIORI")
			@ 3.5,01  SAY OemToAnsi(STR0021) SIZE 6,7 COLOR CLR_HBLUE OF oPanel 		//"Prioridade"
		Else
			@ 3.5,01  SAY OemToAnsi(STR0021) SIZE 6,7 COLOR CLR_BLACK OF oPanel 		//"Prioridade"
		EndIf
		@ 3.4,06  MSCOMBOBOX cPRIORI ITEMS aPRIORI SIZE 70,12 OF oPanel

		@ 4.5,01  SAY OemToAnsi(STR0022) SIZE 6,7 OF oPanel 							//"Servico"
		@ 4.4,06  GET cDESCSS MULTILINE SIZE 297,55 OF oPanel

	Else

		DEFINE MSDIALOG oDLGB TITLE OemToAnsi(STR0012) From 15,20 To 34,103 OF oMainWnd //"Distribuição de Solicitação de Servico em Lote"
		oDLGB:lMaximized := .t.
		oPanel := TPanel():New(0, 0, Nil, oDLGB, Nil, .T., .F., Nil, Nil, 0, 0, .T., .F. )
		oPanel:Align := CONTROL_ALIGN_ALLCLIENT

		@ 0.5,01  SAY OemToAnsi(STR0016) SIZE 6,7 OF oPanel  							//"Supervisor"
		@ 0.4,06  MSGET cNMRESP Picture '@!' SIZE 150,7 When .F. OF oPanel

		@ 1.5,01  SAY OemToAnsi(STR0017) SIZE 6,7 COLOR CLR_HBLUE OF oPanel  			//"Tipo Servico"
		@ 1.4,06  MSGET cCDSERV Picture '@!' SIZE 30,7 F3 "TQ3" OF oPanel Valid If(Empty(cCDSERV),.t.,ExistCpo('TQ3',cCDSERV)) .And. A315EXV(cCDSERV) HASBUTTON
		@ 1.5,15  SAY OemToAnsi(STR0018)SIZE 6,7 OF oPanel   							//"Nome Servico"
		@ 1.4,22  MSGET cNMSERV Picture '@!' SIZE 145,7 When .F. OF oPanel

		@ 2.5,01  SAY OemToAnsi(STR0019) SIZE 6,7 COLOR CLR_HBLUE OF oPanel  			//"Executante"
		@ 2.4,06  MSGET cCDEXEC Picture '@!' SIZE 64,7 F3 "TQ4" OF oPanel Valid If(Empty(cCDEXEC),.t.,ExistCpo('TQ4',cCDEXEC)) .And. A315EXEC(cCDEXEC) HASBUTTON
		@ 2.5,15  SAY OemToAnsi(STR0020) SIZE 6,7 OF oPanel  							//"Nome Executante"
		@ 2.4,22  MSGET oGet1 Var cNMEXEC Picture '@!' SIZE 145,7 When .F. OF oPanel
		If lNomExe
			oGet1:lObfuscate := .T.
			oGet1:bWhen := {|| .F. }
		EndIf

		If X3Obrigat("TQB_PRIORI")
			@ 3.5,01  SAY OemToAnsi(STR0021) SIZE 6,7 COLOR CLR_HBLUE OF oPanel  		//"Prioridade"
		Else
			@ 3.5,01  SAY OemToAnsi(STR0021) SIZE 6,7 COLOR CLR_BLACK OF oPanel  		//"Prioridade"
		EndIf
		@ 3.4,06  MSCOMBOBOX cPRIORI ITEMS aPRIORI SIZE 70,12 OF oPanel

		@ 4.5,01  SAY OemToAnsi(STR0022) SIZE 6,7 OF oPanel 		 					//"Servico"
		@ 4.4,06  GET cDESCSS MULTILINE SIZE 272,55 OF oPanel

	EndIf

	NGPOPUP(aSMenu,@oMenu,oPanel)
	oPanel:bRClicked:= { |o,x,y| oMenu:Activate(x,y,oPanel)}

	ACTIVATE MSDIALOG oDLGB ON INIT EnchoiceBar(oDLGB,{||nOPCA:=1,IIf(!A315OKD(aSolici, @aDistri),nOPCA:= 0,oDLGB:End())},{||oDLGB:End()})

	INCLUI   := .F.
	lDigServ := .T.

	If nOPCA = 1
		dbSelectArea(cTRB315)
		dbGoTop()

		While !Eof()
			If (cTRB315)->TQB_MKBROW = cMarcaEK
				dbSelectArea("TQB")
				dbSetOrder (1)

				//--inicio--SS 027048 #
				//Considera para como filial logada a filial do registro da linha da get dados. A variavel cFilAnt influencia no retorno da dos xFilial,
				//por isso é feita essa validação, para sempre validar conforme a filial do registro.
				cFilAnt := (cTRB315)->TQB_FILIAL
				//---fim----SS 027048 #

				If dbSeek(xFilial("TQB")+(cTRB315)->TQB_SOLICI)

					//--inicio--SS 027048 #
					//Caso o cliente esteja utilizando o ponto de entrada, será obrigátorio ter o Executante e o Código de Serviço tanto na filial logada,
					//quanto na filial do registro que ta sendo distribuido.
					If lMNTA3153
						dbSelectArea("TQ3")
						dbSetOrder(1)
						If !dbSeek(xFilial("TQ3") + cCDSERV)
							MsgStop(STR0049 + (cTRB315)->TQB_SOLICI + Chr(13) + Chr(10) + ; // "Não foi possivel fazer a distribuição da seguinte SS: "
							Chr(13) + Chr(13) + STR0050     + Chr(13) + Chr(10) +         ; // "Motivo: O código de serviço, não existe na filial. "
							STR0051 + cCDSERV + STR0052 + xFilial("TQ3"))                   // "Solução: Incluir o código de serviço " + " na filial "
							dbSelectArea(cTRB315)
							dbSkip()
							Loop
						Else
							If !NGSEEKCPO("TQ4",cCDEXEC,1,(cTRB315)->TQB_FILIAL,.F.)
								MsgStop(STR0049   + (cTRB315)->TQB_SOLICI + Chr(13) + Chr(10) + ; // "Não foi possivel fazer a distribuição da seguinte SS: "
								Chr(13) + Chr(13) + STR0053  + Chr(13)    + Chr(10) +           ; // "Motivo: O executante não existe na filial. "
								STR0054 + Alltrim(cCDEXEC)   + STR0052    + xFilial("TQ3"))       // "Solução: Incluir o executante " + " na filial "
								dbSelectArea(cTRB315)
								dbSkip()
								Loop
							EndIf
						EndIf
					EndIf
					//---fim----SS 027048 #

					cDesc := AllTrim(Msmm(TQB->TQB_CODMSS,,,,3))
					cDesc += CRLF+cDESCSS
					//Condição para gravar "branco" (campo não preenchido)
					nPriori := aSCAN(aPRIORI, {|x| x == cPRIORI})
					If nPriori == 4 //O 4 é uma opção que não existe no TQB_PRIORI que fica como "indefinido" na legenda
						cPriori := ""
					Else
						cPriori := Alltrim(Str(aSCAN(aPRIORI, {|x| x == cPRIORI})))
					EndIf

					If lRPORel17
						RecLock("TQB",.F.)

						TQB->TQB_CDSERV := cCDSERV
						TQB->TQB_CDEXEC := cCDEXEC
						TQB->TQB_PRIORI := cPriori
						TQB->TQB_SOLUCA := "D"

						MSMM(TQB->TQB_CODMSS,,,cDesc,1,,,"TQB","TQB_CODMSS")

						TQB->(MsUnLock())
					EndIf

					RecLock(cTRB315,.F.)
					(cTRB315)->( dbDelete() )
					(cTRB315)->(MsUnLock())

					If lRPORel17
						lEnvWorkf := MNTW040((cTRB315)->TQB_SOLICI,cCDEXEC,cCDSERV)//Workflow disparado para o Executante da S.S.
					EndIf
				EndIf
			EndIf

			dbSelectArea(cTRB315)
			dbSkip()
		End

		If !lRPORel17
			// Faz a gravação
			nSolic := Len(aDistri)
			If nSolic > 0
				For nX := 1 To nSolic
					aDistri[nX]:assign() // Método para Distribuição.
				Next nX
			EndIf
		EndIf

	EndIf

	cFilAnt := cFilAntBkp

	If lEnvWorkf
		If lEmail
			MsgInfo(STR0036+".") // "Aviso da Distribuição de S.S. enviado para o executante"
		Else
			MsgInfo(STR0036+": "+AllTrim(NGSEEK("TQ4",cCDEXEC,1,"TQ4_EMAIL1"))+".") //"Aviso da Distribuição de S.S. enviado para o executante"
		EndIf
	EndIf

	dbSelectArea(cTRB315)
	dbGoTop()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} A315EXV
Carrega Responsavel da Solicitacao de Servico
@author Ricardo Dal Ponte
@since 29/01/07
@version undefined
@param cCdServ, characters, descricao
@type function
/*/
//---------------------------------------------------------------------
Function A315EXV(cCdServ)

	Local cRetCdResp := ""
	Local cAlias     := Alias()
	Local cSavOrd    := IndexOrd()
	Local cCodUser   := CriaVar("AN_USER")

	dbSelectArea("TQ3")
	dbSetOrder(1)

	cNMSERV    := ""

	If dbSeek(xFilial("TQ3")+cCdServ)
		cRetCdResp := TQ3->TQ3_CDRESP
		cNMSERV    := TQ3->TQ3_NMSERV
	Endif

	PswOrder(2)

	If PswSeek(cRetCdResp)
		cCodUser := PswRet(1)[1][1]
	EndIf

	dbSelectArea(cAlias)
	dbSetOrder(cSavOrd)

	cNMRESP := Alltrim(SubStr(UsrFullName(cCodUser), 1, 40))

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} A315EXEC
Executante  da Solicitacao de Servico
@author Ricardo Dal Ponte
@since 29/01/07
@version undefined
@param cCDEXEC, characters, descricao
@type function
/*/
//---------------------------------------------------------------------
Function A315EXEC(cCDEXEC)

	dbSelectArea("TQ4")
	dbSetOrder(1)

	cNMEXEC    := ""

	If dbSeek(xFilial("TQ4")+cCDEXEC)
		cNMEXEC := TQ4->TQ4_NMEXEC
	Endif

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} A315OKD
Consistencia final antes da distribuicao
@author Ricardo Dal Ponte
@since 29/01/2007
@version undefined
@type function
@param aSolici, array, array de solicitações para validar.
@param aDistri, array, será adicionado os objetos para distribuição na Classe.
/*/
//---------------------------------------------------------------------
Static Function A315OKD(aSolici, aDistri)

	Local nTamTot := Len(aSolici)
	Local nTam2   := 0
	Local nInd    := 0
	Local nInd2   := 0
	Local oTQB    := Nil // Classe de S.S.

	Local aArea     := GetArea()
	Local aBENS     := {}
	Local lRet      := .T.
	Local nRegTQB   := TQB->(RecNo())
	Local nCont
	Local nQtdD     := 0
	Local lRPORel17 := IIf(GetRPORelease() <= '12.1.017', .T., .F.) // Release menor ou igual a 17

	Default aDistri := {}

	If !lRPORel17

		For nInd := 1 To nTamTot
			nTam2   := Len(aSolici[nInd])
			For nInd2 := 2 To nTam2

				oTQB := MntSR():New()
				// Determina a operação de Alteração.
				oTQB:setOperation(4)

				// Não apresenta mensagens condicionais
				oTQB:setAsk(.F.)

				oTQB:Load( { xFilial("TQB") + aSolici[nInd][nInd2] } )

				// Transfere os valores do Objeto para a Memória.
				oTQB:setValue("TQB_CDSERV", cCDSERV)
				oTQB:setValue("TQB_CDEXEC", cCDEXEC)

				// Define que é o processo de distribuição
				oTQB:setValue( 'TQB_SOLUCA', 'D' ) 

				// Define prioridade da solicitação
				oTQB:setValue( 'TQB_PRIORI', IIf( ( nPriori := aScan( aPriori, { |x| x == cPriori } ) ) == 4, '', AllTrim( Str( nPriori ) ) ) )

				// Concatena observação do processo de distribuição com o já contido na abertura da S.S.
				oTQB:setValue( 'TQB_DESCSS', Trim( MSMM( TQB->TQB_CODMSS, , , , 3 ) ) + CRLF + Trim( cDESCSS ) )

				//Verifica se os registros são válidos para realizar a inclusão
				If !oTQB:valid()
					oTQB:showHelp()
					oTQB:Free()
					lRet := .F.
					exit
				Else
					aAdd(aDistri, oTQB)
				EndIf
			Next nInd2
		Next nInd

	Else

		//Para melhorar a mensagem foram feitas três condições
		If Empty(cCDSERV)
			MsgInfo(STR0055,STR0024) //"Campo Serviço não informado."###"NÃO CONFORMIDADE"
			Return .F.
		ElseIf Empty(cCDEXEC)
			MsgInfo(STR0056,STR0024) //"Campo Executante não informado."###"NÃO CONFORMIDADE"
			Return .F.
		ElseIf (X3Obrigat("TQB_PRIORI") .And. Empty(cPRIORI))
			MsgInfo(STR0057,STR0024) //"Campo Prioridade não informado."###"NÃO CONFORMIDADE"
			Return .F.
		EndIf

		dbSelectArea(cTRB315)
		dbGoTop()
		While !Eof()
			If (cTRB315)->TQB_MKBROW = cMarcaEK
				dbSelectArea("TQB")
				dbSetOrder (1)
				If dbSeek(xFilial("TQB")+(cTRB315)->TQB_SOLICI)
					nPos := aSCAN(aBENS,{|x| x == TQB->TQB_CODBEM})
					If nPos == 0
						aAdd(aBENS,(cTRB315)->TQB_CODBEM)
					EndIf
				EndIf
			EndIf
			dbSelectArea(cTRB315)
			dbSkip()
		EndDo

		For nCont := 1 To Len(aBENS)
			nQtdD := 0
			If lRet
				//ALERTA DUPLICIDADE DE SS (CODBEM+CDSERV)
				dbSelectArea("TQB")
				dbSetOrder(05)
				dbSeek(xFilial("TQB")+aBENS[nCont],.T.)
				While lRet .And. !Eof() .And. TQB->TQB_FILIAL == xFilial("TQB") .And. TQB->TQB_CODBEM == aBENS[nCont]
					If TQB->TQB_CDSERV == cCDSERV .And. TQB->TQB_SOLUCA == "D" //somente distribuidas
						nQtdD++
					EndIf
					dbSkip()
				EndDo
				If nQtdD > 0
					If !APMSGYESNO(STR0042+CHR(13)+; 						   //"Existe pelo menos uma Solicitação de Serviço distribuída"
					STR0043+" '"+AllTrim(aBENS[nCont])+"' "+STR0044+CHR(13)+;  //"para o mesmo bem/localização"##"e serviço desta S.S."
					STR0045,STR0041) 										   //"Deseja confirmar a distribuição?"##"Duplicidade de S.S."
						lRet := .F.
					EndIf
				EndIf
			Else
				Exit
			EndIf
		Next nCont

		TQB->(dbGoTo(nRegTQB))
		RestArea(aArea)

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de menu Funcional
@author Ricardo Dal Ponte
@since 29/11/2006
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aROTINA := {{STR0025,"A315Pq()"     , 0, 1},;  //"Pesquisar"
					  {STR0026,"A315CHASS()"  , 0, 2},;  //"Visualizar"
					  {STR0027,"MNTA315DIS()" , 0, 4}}   //"Distribuir"

	//+---------------------------------------------------------------------+
	//| Parametros do array a Rotina:                                       |
	//|             1. Nome a aparecer no cabecalho                         |
	//|             2. Nome da Rotina associada                             |
	//|             3. Reservado                                            |
	//|             4. Tipo de Transa‡„o a ser efetuada:                    |
	//|             	1 - Pesquisa e Posiciona em um Banco de Dados       |
	//|                 2 - Simplesmente Mostra os Campos                   |
	//|                 3 - Inclui registros no Bancos de Dados             |
	//|                 4 - Altera o registro corrente                      |
	//|                 5 - Remove o registro corrente do Banco de Dados    |
	//|             5. Nivel de acesso                                      |
	//|             6. Habilita Menu Funcional                              |
	//+---------------------------------------------------------------------+

	If ExistBlock("MNTA3151")
		_aRotina := ExecBlock("MNTA3151",.F.,.F.,{aRotina})
		If (ValType(_aRotina) == "A")
			aRotina := ACLONE(_aRotina)
		EndIf
	EndIf

Return(aRotina)

//---------------------------------------------------------------------
/*/{Protheus.doc} A315WDET
Cria Arquivos Temporarios para o detalhamento das SS
@author Ricardo Dal Ponte
@since 25/01/2007
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function A315WDET()

	aCampos := ()

	dbselectArea("TQB")
	dbGoTop()

	aCampos := DbStruct()
	aAdd( aCampos, { 'TQB_MKBROW', 'C', 2 , 0 } )
	aAdd( aCampos, { 'TRB_FILIAL', 'C', 2 , 0 } )
	aAdd( aCampos, { 'TQB_NMTIPO', 'C', 11, 0 } )
	aAdd( aCampos, { 'TQB_NMSOLI', 'C', 20, 0 } )
	aAdd( aCampos, { 'TQB_NOMEBM', 'C', FWTamSX3( 'TQB_NOMBEM' )[1], 0 } )
	aAdd( aCampos, { 'TQB_NMCUST', 'C', FWTamSX3( 'CTT_DESC01' )[1], 0 } )
	aAdd( aCampos, { 'TQB_NOMCTR', 'C', FWTamSX3( 'HB_NOME' )[1]   , 0 } )
	aAdd( aCampos, { 'TQB_NOMLOC', 'C', FWTamSX3( 'TPS_NOME' )[1]  , 0 } )
	aAdd( aCampos, { 'TQB_NOMSER', 'C', FWTamSX3( 'TQ3_NMSERV' )[1], 0 } )
	
	//Intancia classe FWTemporaryTable
	oTmpTbl1:= FWTemporaryTable():New( cTRB315, aCampos )

	oTmpTbl1:AddIndex( "Ind01" , {"TQB_SOLICI"}                            )
	oTmpTbl1:AddIndex( "Ind02" , {"TQB_CODBEM","TQB_NOMSER"}               )
	oTmpTbl1:AddIndex( "Ind03" , {"TQB_CODBEM","TQB_NMCUST","TQB_NOMSER"}  )
	oTmpTbl1:AddIndex( "Ind04" , {"TQB_CODBEM","TQB_DTABER"}               )
	oTmpTbl1:AddIndex( "Ind05" , {"TQB_NMSOLI","TQB_NOMSER"}               )
	oTmpTbl1:AddIndex( "Ind06" , {"TQB_NMSOLI","TQB_NMCUST","TQB_NOMSER"}  )
	oTmpTbl1:AddIndex( "Ind07" , {"TQB_NMSOLI","TQB_NOMSER","TQB_DTABER"}  )
	oTmpTbl1:AddIndex( "Ind08" , {"TQB_DTABER","TQB_NMSOLI"} 			   )
	oTmpTbl1:AddIndex( "Ind19" , {"TQB_DTABER","TQB_NMCUST"} 		   	   )
	oTmpTbl1:AddIndex( "Ind10" , {"TQB_NOMSER","TQB_NMCUST"}			   )
	oTmpTbl1:AddIndex( "Ind11" , {"TQB_NOMSER","TQB_DTABER"}			   )
	oTmpTbl1:AddIndex( "Ind12" , {"TQB_CDSERV","TQB_SOLICI"}			   )

	//Cria a tabela temporaria
	oTmpTbl1:Create()

	aCpos := {}
	aaDD(aCpos,{"TQB_MKBROW", NIL, ""})
	Aadd(aCpos,{"TQB_SOLICI", NIL, NGSEEKDIC("SX3","TQB_SOLICI",2,"X3_TITULO")})
	Aadd(aCpos,{"TQB_NMTIPO", NIL, NGSEEKDIC("SX3","TQB_TIPOSS",2,"X3_TITULO")})
	Aadd(aCpos,{"TQB_CDSERV", NIL, NGSEEKDIC("SX3","TQB_CDSERV",2,"X3_TITULO")})
	Aadd(aCpos,{"TQB_NOMSER", NIL, NGSEEKDIC("SX3","TQB_NMSERV",2,"X3_TITULO")})
	Aadd(aCpos,{"TQB_CODBEM", NIL, NGSEEKDIC("SX3","TQB_CODBEM",2,"X3_TITULO")})
	Aadd(aCpos,{"TQB_NOMEBM", NIL, NGSEEKDIC("SX3","TQB_NOMBEM",2,"X3_TITULO")})
	Aadd(aCpos,{"TQB_NMCUST", NIL, NGSEEKDIC("SX3","TQB_CCUSTO",2,"X3_TITULO")+Space(5)})
	Aadd(aCpos,{"TQB_NOMCTR", NIL, NGSEEKDIC("SX3","TQB_CENTRA",2,"X3_TITULO")})
	Aadd(aCpos,{"TQB_NOMLOC", NIL, NGSEEKDIC("SX3","TQB_LOCALI",2,"X3_TITULO")})
	Aadd(aCpos,{"TQB_DTABER", NIL, NGSEEKDIC("SX3","TQB_DTABER",2,"X3_TITULO")})
	Aadd(aCpos,{"TQB_HOABER", NIL, NGSEEKDIC("SX3","TQB_HOABER",2,"X3_TITULO")})
	Aadd(aCpos,{"TQB_RAMAL" , NIL, NGSEEKDIC("SX3","TQB_RAMAL" ,2,"X3_TITULO")})
	Aadd(aCpos,{"TQB_NMSOLI", NIL, NGSEEKDIC("SX3","TQB_CDSOLI",2,"X3_TITULO")})

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} A315ADET
Popula arquivo temporario
@author Ricardo Dal Ponte
@since 25/01/2007
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function MNTA315TRB()

	Local cWhere  := "%AND TQB.TQB_FILIAL = " + ValToSQL( FWxFilial( 'TQB' ) )
	Local cAlsTQB := GetNextAlias()
	Local cCdSoli := ''
	Local cNmSoli := ''

	/*------------------------------------------------+ 
	| Ponto de Entrada para alterar filtro da filial. |
	+------------------------------------------------*/
	If ExistBlock( 'MNTA3153' )

		cWhere := " AND " + ExecBlock( 'MNTA3153', .F., .F. )

	EndIf

	/*---------------------------------------------+ 
	| Ponto de Entrada para incluir novos filtros. |
	+---------------------------------------------*/
	If ExistBlock( 'MNTA3152' )
		
		cWhere += " AND " + ExecBlock( 'MNTA3152', .F., .F. )
		
	EndIf

	cWhere  += "%"

	cFields := "%"
	cFields += "CASE " 
	cFields += 	"WHEN TQB.TQB_TIPOSS = 'B' THEN " + ValToSQL( STR0029 ) + " "
	cFields += 	"ELSE " + ValToSQL( STR0030 ) + " "
	cFields += "END AS TQB_NMTIPO, "
	cFields += "%"

	BeginSQL Alias cAlsTQB

		COLUMN TQB_DTABER AS DATE

		SELECT
			TQB.TQB_FILIAL,
			TQB.TQB_SOLICI,
			TQB.TQB_TIPOSS,
			TQB.TQB_CODBEM,
			TQB.TQB_CCUSTO,
			TQB.TQB_CENTRA,
			TQB.TQB_LOCALI,
			ISNULL( TPS_NOME, '' ) AS TPS_NOME,
			TQB.TQB_DTABER,
			TQB.TQB_HOABER,
			TQB.TQB_RAMAL ,
			TQB.TQB_CDSERV,
			TQB.TQB_CDSOLI,
			%exp:cFields%
			TQ3.TQ3_NMSERV,
			ISNULL( CTT_DESC01, '' ) AS CTT_DESC01,
			ISNULL( HB_NOME, '' )    AS HB_NOME   ,
			CASE
				WHEN ISNULL( ST9.T9_CODBEM, '' ) = '' THEN TAF.TAF_NOMNIV
				ELSE ST9.T9_NOME 
			END AS TQB_NOMBEM
		FROM
			%table:TQB% TQB
		INNER JOIN
			%table:TQ3% TQ3 ON
				TQ3.TQ3_FILIAL = %xFilial:TQ3%  AND
				TQ3.TQ3_CDSERV = TQB.TQB_CDSERV AND
				TQ3.%NotDel%
		LEFT JOIN
			%table:CTT% CTT ON
				CTT.CTT_FILIAL = %xFilial:CTT%  AND
				CTT.CTT_CUSTO  = TQB.TQB_CCUSTO AND
				CTT.%NotDel%
		LEFT JOIN
			%table:SHB% SHB ON
				SHB.HB_FILIAL = %xFilial:SHB%  AND
				SHB.HB_COD    = TQB.TQB_CENTRA AND
				SHB.%NotDel%
		LEFT JOIN
			%table:TPS% TPS ON
				TPS.TPS_FILIAL = %xFilial:TPS%  AND
				TPS.TPS_CODLOC = TQB.TQB_LOCALI AND
				TPS.%NotDel%
		LEFT JOIN
			%table:TAF% TAF ON
				TAF.TAF_FILIAL = %xFilial:TAF%  AND
				TAF.TAF_CODNIV = TQB.TQB_CODBEM AND
				TAF.TAF_MODMNT = 'X' AND
				TAF.TAF_INDCON = '2' AND
				TAF.%NotDel%
		LEFT JOIN
			%table:ST9% ST9 ON
				ST9.T9_FILIAL = %xFilial:ST9%  AND
				ST9.T9_CODBEM = TQB.TQB_CODBEM AND
				ST9.%NotDel%
		WHERE
			TQB.TQB_SOLUCA = 'A'           AND
			TQB.%NotDel%
			%exp:cWhere%
		ORDER BY
			TQB.TQB_CDSOLI

	EndSQL

	While (cAlsTQB)->( !EoF() )

		If cCdSoli != (cAlsTQB)->TQB_CDSOLI
			
			cCdSoli := (cAlsTQB)->TQB_CDSOLI

			cNmSoli := UsrRetName( (cAlsTQB)->TQB_CDSOLI )

		EndIf

		RecLock( cTRB315,.T. )

			(cTRB315)->TQB_FILIAL := (cAlsTQB)->TQB_FILIAL
			(cTRB315)->TQB_SOLICI := (cAlsTQB)->TQB_SOLICI
			(cTRB315)->TQB_TIPOSS := (cAlsTQB)->TQB_TIPOSS
			(cTRB315)->TQB_NMTIPO := (cAlsTQB)->TQB_NMTIPO
			(cTRB315)->TQB_CODBEM := (cAlsTQB)->TQB_CODBEM
			(cTRB315)->TQB_NOMEBM := (cAlsTQB)->TQB_CODBEM
			(cTRB315)->TQB_NOMEBM := (cAlsTQB)->TQB_NOMBEM
			(cTRB315)->TQB_CCUSTO := (cAlsTQB)->TQB_CCUSTO
			(cTRB315)->TQB_NMCUST := (cAlsTQB)->CTT_DESC01
			(cTRB315)->TQB_CENTRA := (cAlsTQB)->TQB_CENTRA
			(cTRB315)->TQB_NOMCTR := (cAlsTQB)->HB_NOME
			(cTRB315)->TQB_LOCALI := (cAlsTQB)->TQB_LOCALI
			(cTRB315)->TQB_NOMLOC := (cAlsTQB)->TPS_NOME
			(cTRB315)->TQB_DTABER := (cAlsTQB)->TQB_DTABER
			(cTRB315)->TQB_HOABER := (cAlsTQB)->TQB_HOABER
			(cTRB315)->TQB_RAMAL  := (cAlsTQB)->TQB_RAMAL
			(cTRB315)->TQB_CDSERV := (cAlsTQB)->TQB_CDSERV
			(cTRB315)->TQB_NOMSER := (cAlsTQB)->TQ3_NMSERV
			(cTRB315)->TQB_CDSOLI := (cAlsTQB)->TQB_CDSOLI
			(cTRB315)->TQB_NMSOLI := cNmSoli
			
		MsUnLock()

		(cAlsTQB)->( dbSkip() )

	End

	(cAlsTQB)->( dbCloseArea() )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} A315ALLMAR
Marca/Desmarca todos os registros do browse
@author Ricardo Dal Ponte
@since 27/01/07
@version undefined
@param cAlias, characters, descricao
@type function
/*/
//---------------------------------------------------------------------
Function A315ALLMAR(cAlias)

	CursorWait()

	dbSelectArea(cAlias)
	nRecno := &(cAlias)->(Recno())
	dbGoTop()

	While !Eof()
		RecLock(cAlias,.F.)
		If lALLMARK = .T.
			&(cAlias)->(TQB_MKBROW) := "  "
		Else
			&(cAlias)->(TQB_MKBROW) := cMarcaEK
		EndIf
		&(cAlias)->(MsUnLock())
		dbSkip()
	End

	lALLMARK := !lALLMARK
	&(cAlias)->(dbGoto(nRecno))

	CursorArrow()
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} A315UNIMAR
Marca/Desmarca o registro do browse
@author Ricardo Dal Ponte
@since 27/01/07
@version undefined
@param cAlias, characters, descricao
@type function
/*/
//---------------------------------------------------------------------
Function A315UNIMAR(cAlias)

	CursorWait()

	dbSelectArea(cAlias)

	RecLock(cAlias,.F.)
	If &(cAlias)->(TQB_MKBROW) = cMarcaEK
		&(cAlias)->(TQB_MKBROW) := "  "
	Else
		&(cAlias)->(TQB_MKBROW) := cMarcaEK
	Endif
	&(cAlias)->(MsUnLock())

	CursorArrow()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} A315CHASS
Abre a Visualizacao da Solicitacao de Servico
@author Ricardo Dal Ponte
@since 27/01/07
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function A315CHASS()

	Local aNao
	Local nRecnoTRBD
	Local nSOLICI
	Local lFacilities := SuperGetMv("MV_NG1FAC",.F.,"2") == '1'

	dbSelectArea(cTRB315)
	nRecnoTRBD := (cTRB315)->(Recno())
	nSOLICI    := (cTRB315)->TQB_SOLICI

	If Empty(nSOLICI)
		MsgInfo(STR0031,STR0032) //"Nenhuma Solicitação de Serviço foi selecionada para visualização."###"INFORMAÇÃO"
		Return .T.
	EndIf
	aNao	  := {"TQB_OBSATE","TQB_OBSPRA"}
	//Se não utilizar Facilities deverá remover estes campos da tela
	If !lFacilities
		aAdd(aNao, "TQB_LOCALI")
		aAdd(aNao, "TQB_NOMLOC")
	EndIf
	aChoice	  := NGCAMPNSX3("TQB",aNao)

	aRotina   := {{STR0025 ,"AxPesqui",0,1},; //"Pesquisar"
				  {STR0026 ,"NGCAD01" ,0,2}}  //"Visualizar"

	cCadastro := OemtoAnsi(STR0033)           //"Visualização da Solicitação de Serviço"

	CursorWait()

	dbSelectArea("TQB")
	dbSetOrder (1)
	dbSeek(xFilial("TQB")+nSOLICI)

	NGCAD01('TQB',Recno(),2)
	CursorArrow()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} A315Pq
Pesquisas genericas
@author Jorge Queiroz
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function A315Pq()

	Private CFILTRO := Space(60)

	cPESQUI := aPESQUI[1]
	nOPCA   := 0

	DEFINE MSDIALOG oDLGC TITLE OemToAnsi(STR0034) From 10,14 To 20,58 OF oMainWnd //"Distribuição de Solicitação de Servico em Lote - Pesquisa"

	@ 1.6,01  SAY OemToAnsi(STR0025+":") SIZE 6,7 COLOR CLR_BLUE OF oDLGC          //"Pesquisar"
	@ 2.4,01  MSCOMBOBOX cPESQUI ITEMS aPESQUI SIZE 125,12 OF oDLGC
	@ 3.4,01  MSGET cFILTRO Picture '@!' SIZE 160,7 OF oDLGC
	@ 5.4,29.5  Button STR0035 Size 50,12 Action (oDLGC:End()) OF oDLGC           //"&Pesquisar"


	ACTIVATE MSDIALOG oDLGC ON INIT EnchoiceBar(oDLGC,{||nOPCA:=1,oDLGC:End()},{||oDLGC:End()})

	INCLUI := .F.
	lDigServ := .T.
	nPOS := aSCAN(aPESQUI, {|x| x == cPESQUI})

	dbSelectArea(cTRB315)
	dbSetOrder(nPOS)

	dbSeek(Alltrim(cFILTRO),.T.)
	cFILCMP := ""

Return
