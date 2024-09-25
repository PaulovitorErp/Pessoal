#include "Mdta645.ch"
#include "Protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MDTA645  ³ Autor ³ Thiago Olis Machado   ³ Data ³ 03/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Cadastro de Candidatos                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDTA645()
	// Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	Local aNGBEGINPRM := NGBEGINPRM( )
	Local lCipatr := SuperGetMv("MV_NG2NR31",.F.,"2") == "1"

	lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )

	Private cCadastro
	Private aRotina := MenuDef()
	Private lMdtMin := If( SuperGetMv("MV_MDTMIN",.F.,"N") == "S", .t. , .f. )
	Private cAliasCC := "CTT"
	Private cFilCC   := "CTT->CTT_FILIAL"
	Private cCodCC   := "CTT->CTT_CUSTO"
	Private cDesCC   := "CTT->CTT_DESC01"

	Private lCpoTNQ := If(TNQ->(FieldPos("TNQ_FILMAT")) > 0,.t.,.f.)
	Private lCpoTNO := If(TNO->(FieldPos("TNO_FILMAT")) > 0,.t.,.f.)
	Private nIndTNQ := NGRETORDEM("TNQ","TNQ_FILIAL+TNQ_MANDAT+TNQ_FILMAT+TNQ_MAT+DTOS(TNQ_DTSAID)",.t.)
	nIndTNQ := If(nIndTNQ > 0,nIndTNQ,RetIndex("TNQ"))
	Private nIndTNO := NGRETORDEM("TNO","TNO_FILIAL+TNO_MANDAT+TNO_FILMAT+TNO_MAT+DTOS(TNO_DTCAND)",.t.)
	nIndTNO := If(nIndTNO > 0,nIndTNO,RetIndex("TNO"))

	If Alltrim(GETMV("MV_MCONTAB")) != "CTB"
		cAliasCC := "SI3"
		cFilCC   := "SI3->I3_FILIAL"
		cCodCC   := "SI3->I3_CUSTO"
		cDesCC   := "SI3->I3_DESC"
	Endif

	If lSigaMdtps

		cCadastro := OemtoAnsi(STR0012)  //"Clientes"

		DbSelectArea("SA1")
		DbSetOrder(1)

		mBrowse( 6, 1,22,75,"SA1")
	Else

		// Define o cabecalho da tela de atualizacoes
		cCadastro := OemtoAnsi(STR0007) // "Candidatos"
		PRIVATE aCHKDEL := {}, bNGGRAVA

		// aCHKDEL array que verifica a INTEGRIDADE REFERENCIAL na exclu-
		// são do registro.
		//
		// 1 - Chave de pesquisa
		// 2 - Alias de pesquisa
		// 3 - ordem de pesquisa
		aCHKDEL := { {'TNO->TNO_MANDAT+TNO->TNO_MAT'    , "TNQ", 1}}

		//³ Endereca a funcaO de BRoWSE                                  ³
		DbSelectArea("TNO")
		DbSetorder(If(lCpoTNO,nIndTNO,1))
		mBrowse( 6, 1,22,75,"TNO")

		dbSelectArea("SRA")
		Set Filter To
		DbSelectArea("TNQ")
		DbSetorder(1)
		DbSelectArea("TNO")
		DbSetorder(1)

	Endif

	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	NGRETURNPRM(aNGBEGINPRM)

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CHK645MAN ³ Autor ³ Thiago olis Machado   ³ Data ³ 03/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Checa se ja existe registro relacionado                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CHK645MAN(lPasMDT,nTipCad,lCampo)
	Local aArea := GetArea()
	Default nTipCad := 3
	Default lCampo:=.T.

	DbSelectArea("SRA")
	DbSetorder(1)
	dbSeek(xFilial("SRA")+M->TNO_MAT)

	If lSigaMdtps

		If lCampo

			If (SRA->RA_SITFOLH == "D" .Or. !Empty(SRA->RA_DEMISSA))

				If !Empty(M->TNO_MANDAT) .And. !Empty( SRA->RA_DEMISSA ) .And. SRA->RA_DEMISSA < TNN->TNN_DTINIC
					ShowHelpDlg(STR0051,{STR0052},1,{STR0053},2)//"Atenção"##"O funcionário foi demitido antes da data de início do mandato."##"Somente funcionários com data de demissão superior a data de início do mandato pode ser incluso."
					Return .F.
				Else

					If SRA->RA_DEMISSA <= dDataBase

						If!MSGYesNo(STR0050)//"Este funcionário está demitido, deseja inseri-lo como candidato?"
							Return .F.
						EndIf

					EndIf

				Endif

			EndIf

		Endif

		If !EXISTCHAV("TNO",cCliMdtps+M->TNO_MANDAT+M->TNO_FILMAT+M->TNO_MAT,6)  //TNO_FILIAL+TNO_CLIENT+TNO_LOJA+TNO_MANDAT+TNO_FILMAT+TNO_MAT+DTOS(TNO_DTCAND)
			Return .f.
		EndIf

		If lPasMDT

			If !ExCpoMDT("SRA",M->TNO_MAT,,.f.)
				MsgStop(STR0013,STR0014)  //"Matrícula de funcionário não existe."  //"ATENÇÃO"
				Return .f.
			EndIf

			If SubStr(SRA->RA_CC,1,nSizeSA1+nSizeLoj) <> cCliMdtps
				MsgStop(STR0015,STR0014)  //"Matricula não pertence ao cliente."  //"ATENCAO"
				Return .f.
			Endif

		Else

			If !ExCpoMDT("SRA",M->TNO_MAT)
				Return .f.
			EndIf

			If SubStr(SRA->RA_CC,1,nSizeSA1+nSizeLoj) <> cCliMdtps
				MsgStop(STR0015,STR0014)  //"Matricula não pertence ao cliente."  //"ATENCAO"
				Return .f.
			Endif

		Endif

	Else

		If lCampo

			If (SRA->RA_SITFOLH == "D" .Or. !Empty(SRA->RA_DEMISSA))

				If !Empty(M->TNO_MANDAT) .And. !Empty( SRA->RA_DEMISSA ) .And. SRA->RA_DEMISSA < TNN->TNN_DTINIC
					ShowHelpDlg(STR0051,{STR0052},1,{STR0053},2)//"Atenção"##"O funcionário foi demitido antes da data de início do mandato."##"Somente funcionários com data de demissão superior a data de início do mandato pode ser incluso."
					Return .F.

				ElseIf SRA->RA_DEMISSA <= dDataBase

					If !MSGYesNo(STR0050)//"Este funcionário está demitido, deseja inseri-lo como candidato?"
						Return .F.
					EndIf

				Endif

			EndIf

			If lPasMDT

				If !ExCpoMDT("SRA",M->TNO_MAT,,.f.)
					MsgStop(STR0013,STR0014)  //"Matrícula de funcionário não existe."  //"ATENÇÃO"
					Return .f.
				EndIf

			Else

				If !ExCpoMDT("SRA",M->TNO_MAT)
					Return .f.
				EndIf

			Endif

		Endif

		If lCpoTNO

			If nTipCad <> 4 .And. !EXISTCHAV("TNO",M->TNO_MANDAT+M->TNO_FILMAT+M->TNO_MAT,nIndTNO)
				Return .f.
			ElseIf nTipCad == 4 .and. Type("cQ_FILMAT") == "C"

				If M->TNO_FILMAT <> cQ_FILMAT .And. !EXISTCHAV("TNO",M->TNO_MANDAT+M->TNO_FILMAT+M->TNO_MAT,nIndTNO)
					Return .f.
				Endif

			Endif

		ElseIf !EXISTCHAV("TNO",M->TNO_MANDAT+M->TNO_MAT)
			Return .f.
		EndIf

	Endif


	If lMdtMin
		dbSelectArea("SRA")
		dbSetOrder(1)

		If dbSeek(xFilial("SRA")+M->TNO_MAT)
			cSetor   := SRA->RA_CC
			cAreaC   := NGSeek('TLJ', M->TNO_MANDAT + cSetor ,1,'TLJ->TLJ_AREA')
			M->TNO_AREA   := cAreaC
			M->TNO_NOAREA := NGSeek(cAliasCC, cAreaC ,1,cDesCC)
		Endif

	Endif

	RestArea(aArea)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MDT645MAND³ Autor ³ Denis                 ³ Data ³ 03/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Filtra as matriculas de acordo com o CC da CIPA            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDT645MAND(cTNO_MANDAT,l645)
	Local aArea := TNN->(GetArea())
	Local lPrest := .F.

	Default l645 := .T.

	If Type("cCliMdtPs") == "C"
		If !Empty(cCliMdtPs)
			lPrest := .T.
		Endif
	Endif

	If lPrest
		If !EXISTCPO("TNN",cCliMdtps+cTNO_MANDAT,3)
			RestArea(aArea)
			Return .f.
		Endif
	Else
		If !EXISTCPO("TNN",cTNO_MANDAT)
			RestArea(aArea)
			Return .f.
		Endif
	Endif

	If l645 .and. TNN->(FieldPos("TNN_CC")) > 0
		dbSelectArea("TNN")
		dbSetOrder(1)
		If dbSeek( xFilial("TNN") + cTNO_MANDAT ) .and. !Empty(TNN->TNN_CC)
			dbSelectArea("SRA")
			dbSetOrder(1)
			Set Filter To
			Set Filter To RA_FILIAL == xFilial("SRA") .and. RA_CC == TNN->TNN_CC
		Else
			dbSelectArea("SRA")
			Set Filter To
		Endif
	Endif

	RestArea(aArea)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MD645CA   ³ Autor ³ Thiago olis Machado   ³ Data ³ 03/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Checa se ja existe registro relacionado                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MD645CA()
	Local cSeek
	Local cMandato
	Local cFil1Tmp := cFilAnt

	Local dDtEleicao := SToD( "" )

	Local lCipatr := SuperGetMv("MV_NG2NR31",.F.,"2") == "1"

	Private cCodCIPA := TNO->TNO_MANDAT
	Private lMandExt := NGCADICBASE("TNQ_MANEXT","A","TNQ",.F.)

	DbSelectArea("TNO")

	If !MsgYesNo( If( lCipatr, STR0055, STR0008 ) + CHR(13); //"Deseja incluir o candidato na relação de componentes da CIPATR ?" //"Deseja incluir o candidato na relação de componentes da CIPA ?"
				+STR0009+TNO->TNO_MANDAT)  //"Mandato   ->"
		Return .f.
	Endif

	If lSigaMdtps
		cSeek := xFilial("TNQ")+cCliMdtps+TNO->TNO_MANDAT+TNO->TNO_FILMAT+TNO->TNO_MAT
		DbSelectArea("TNQ")
		DbSetorder(6)  //TNQ_FILIAL+TNQ_CLIENT+TNQ_LOJA+TNQ_MANDAT+TNQ_FILMAT+TNQ_MAT+DTOS(TNQ_DTSAID)

		If DbSeek(cSeek)
			Help(" ",1,"JAEXISTINF")
			Return .f.
		Else

			If lMandExt
				cMandato :=	NgSeek("TNN",cCodCIPA,1,"TNN_CODORI")
			EndIf

			RecLock("TNQ",.t.)
			TNQ->TNQ_FILIAL := xFilial("TNQ")
			TNQ->TNQ_MANDAT := If(!Empty(cMandato),cMandato,TNO->TNO_MANDAT)

			If lMandExt
				TNQ->TNQ_MANEXT := If(!Empty(cMandato),cCodCIPA,"")
			EndIf

			TNQ->TNQ_MAT    := TNO->TNO_MAT
			TNQ->TNQ_INDICA := TNO->TNO_INDICA
			TNQ->TNQ_TIPCOM := "1"
			TNQ->TNQ_FILMAT := TNO->TNO_FILMAT
			TNQ->TNQ_CLIENT := TNO->TNO_CLIENT
			TNQ->TNQ_LOJA   := TNO->TNO_LOJA
			MsUnLock("TNQ")

			// Processa Gatilhos apos gravar o candidato como componente da CIPA
			EvalTrigger()

			// Gera estabilidade para componente CIPA
			Altera   := .f.
			Inclui   := .t.
			nTipInd1 := TNO->TNO_INDICA
			nTipInd2 := TNO->TNO_INDICA
			cFil1Tmp := TNO->TNO_FILMAT

			MDT660SRA( , TNO->TNO_MANDAT, TNO->TNO_MAT, cFil1Tmp, "1", , , , .T. )
		EndIf

	Else
		nIndTNQ := NGRETORDEM("TNQ","TNQ_FILIAL+TNQ_MANDAT+TNQ_FILMAT+TNQ_MAT+DTOS(TNQ_DTSAID)",.t.)
		nIndTNQ := If(nIndTNQ > 0,nIndTNQ,RetIndex("TNQ"))

		// Se for mandato extra deverá ser verificado o código de origem, no caso o código do Mandato "Pai"
		If lMandExt
			cMandato :=	NgSeek("TNN",cCodCIPA,1,"TNN_CODORI")
		EndIf

		cMandato := If( !Empty( cMandato ), cMandato, TNO->TNO_MANDAT )
		cSeek := xFilial( "TNQ" ) + cMandato + TNO->TNO_MAT

		If lCpoTNO .and. lCpoTNQ
			cSeek := xFilial("TNQ") + cMandato + TNO->TNO_FILMAT + TNO->TNO_MAT
		EndIf

		DbSelectArea("TNQ")
		DbSetorder(If(lCpoTNO .and. lCpoTNQ,nIndTNQ,1))

		If DbSeek(cSeek)
			Help(" ",1,"JAEXISTINF")
			Return .f.
		Else

			RecLock("TNQ",.t.)
			TNQ->TNQ_FILIAL := xFilial("TNQ")
			TNQ->TNQ_MANDAT := cMandato

			If lMandExt
				TNQ->TNQ_MANEXT := If(!Empty(cMandato),cCodCIPA,"")
			EndIf

			TNQ->TNQ_MAT    := TNO->TNO_MAT
			TNQ->TNQ_INDICA := TNO->TNO_INDICA
			TNQ->TNQ_TIPCOM := "1"

			If lCpoTNO .and. lCpoTNQ
				TNQ->TNQ_FILMAT := TNO->TNO_FILMAT
				cFil1Tmp := TNO->TNO_FILMAT
			Endif

			TNQ->TNQ_DTESTB := fGetEstbAtu( TNQ->TNQ_MANDAT, @dDtEleicao )
			TNQ->TNQ_DTINIC := NGSomaAno( TNQ->TNQ_DTESTB, -2 )
			TNQ->TNQ_DTSAID := TNQ->TNQ_DTESTB

			MsUnLock("TNQ")

			If ExistBlock( "MDTA6451" )
				ExecBlock( "MDTA6451", .F., .F. , { xFilial("TNQ"), cMandato, TNO->TNO_MAT } )
			EndIf

			//Processa Gatilhos apos gravar o candidato como componente da CIPA
			EvalTrigger()

			//Gera estabilidade para componente CIPA
			Altera   := .f.
			Inclui   := .t.
			nTipInd1 := TNO->TNO_INDICA
			nTipInd2 := TNO->TNO_INDICA

			MDT660SRA( , TNO->TNO_MANDAT, TNO->TNO_MAT, cFil1Tmp, "1", , , , .T. )
		EndIf

	Endif

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT645PROC
Inclui, Altera e Exclui os registros da TNQ

@sample	MDT645PROC()

@author	Denis Hyroshi de Souza
@since	10/04/2005

@return .T., Lógico, Sempre verdadeiro
/*/
//---------------------------------------------------------------------
Function MDT645PROC( cAlias, nRecno, nOpcx )

	Local nRet
	Local cFil1Tmp	 := cFilAnt
	Local aArea		 := GetArea()
	Local cOldFil	 := cFilAnt
	Local lCpoFilFun := IIf( NGCADICBASE( "TNO_FILMAT", "A", "TNO", .F. ), .T., .F. )

	//Variáveis de perda de estabilidade
	Local lPerdEstab := TNO->( ColumnPos( "TNO_DTESTB" ) ) > 0 //Caso o dicionário esteja atualizado com os campos da perda da estabilidade
	Local dDtEstbOld := IIf( lPerdEstab, TNO->TNO_DTESTB, SToD( "" ) )
	Local cJustifOld := IIf( lPerdEstab, TNO->TNO_JUSTIF, "" )
	Local cIndicaOld := TNO->TNO_INDICA

	Private aNgButton := {}

	//Caso o dicionário esteja atualizado com os campos de perda da estabilidade da CIPA e seja uma alteração
	If lPerdEstab .And. ( nOpcx == 4 .Or. nOpcx == 2 )
		aAdd( aNgButton, { "DOCUMENT", { || MsDocument( cAlias, nRecno, nOpcx ) }, "Conhecimento", "Conhecimento" } )
	EndIf

	If nOpcx == 3
		bNGGRAVA := { || CHK645MAN( .T., 3, .F. ) .And. MDTTNOVALID( 2 ) }
	Else
		If lCpoTNO
			If !Empty( TNO->TNO_FILMAT )
				cFilAnt := TNO->TNO_FILMAT
			EndIf
		EndIf
		If nOpcx == 4 .And. lCpoTNO
			cQ_FILMAT := TNO->TNO_FILMAT
			bNGGRAVA := { || CHK645MAN( .T., 4, .F. ) .And. MDTTNOVALID( 2 ) }
		EndIf
	EndIf

	nRet := NGCAD01( cAlias, nRecno, nOpcx )

	If lCpoFilFun
		If !Empty( TNO->TNO_FILMAT )
			cFil1Tmp := TNO->TNO_FILMAT
		EndIf
	EndIf

	//Caso a tela de cadastro for confirmada, não for visualização e haver integração com o GPE
	If nRet = 1 .And. nOpcx <> 2 .And. SuperGetMv( "MV_MDTGPE", .F., "N" ) == "S"

		//Ajusta a data de estabilidade nos campos RA_DTVTEST e TNO_DTESTB
		MDT645ESTB( nOpcx, TNO->TNO_MANDAT, cFil1Tmp, TNO->TNO_MAT, lPerdEstab, dDtEstbOld, cJustifOld, cIndicaOld )

	EndIf

	dbSelectArea( "SRA" )
	Set Filter To

	bNGGRAVA := {}
	cFilAnt := cOldFil
	RestArea( aArea )

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MDT645FILF³ Autor ³Denis Hyroshi de Souza ³ Data ³ 10/04/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao do campo TNO_FILMAT                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDT645FILF()
Local aArea    := GetArea()
Local aAreaSM0 := SM0->(GetArea())
Local lRet     := .T.

Dbselectarea("SM0")
IF !Dbseek(cEmpAnt+M->TNO_FILMAT)
	Help(" ",1,"REGNOIS")
	lRet := .F.
Else
	cFilAnt := M->TNO_FILMAT
    dbSelectArea("SRA")
	dbSetOrder(01)
	If !dbSeek(xFilial("SRA",cFilAnt)+ M->TNO_MAT )
		M->TNO_MAT := Space( Len(SRA->RA_MAT) )
		M->TNO_NOME := " "
	Else
		M->TNO_NOME := SRA->RA_NOME
	Endif
EndIF

RestArea(aAreaSM0)
RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o  ³A645DTCAND  ³ Autor ³Anônimo                ³ Data ³??/??/??  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida a data de candidatura                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A645DTCAND()
Local dDtTmp := NGSeek('SRA',M->TNO_MAT,1,'SRA->RA_ADMISSA')
If !Empty(M->TNO_DTCAND) .and. !Empty(M->TNO_MAT) .and. ValType(dDtTmp) == "D"
	If dDtTmp > M->TNO_DTCAND
		MsgStop(STR0016)  //"A data da candidatura não pode ser anterior à data de admissão do funcionário."
		Return .f.
	Endif
Endif
Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MenuDef  ³ Autor ³ Rafael Diogo Richter  ³ Data ³29/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Utilizacao de Menu Funcional.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaMDT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados         ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ F.O  ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )
Local aRotina

If lSigaMdtps
	aRotina := { { STR0001,   "AxPesqui"  , 0 , 1},; //"Pesquisar"
	             { STR0002,   "NGCAD01"   , 0 , 2},; //"Visualizar"
	             { STR0007,   "MDT645CAN" , 0 , 4} } //"Candidatos"
Else
	aRotina :=	{ { STR0001 , "AxPesqui"   , 0 , 1},; //"Pesquisar"
                  { STR0002 , "MDT645PROC" , 0 , 2},; //"Visualizar"
                  { STR0003 , "MDT645PROC" , 0 , 3},; //"Incluir"
                  { STR0004 , "MDT645PROC" , 0 , 4},; //"Alterar"
                  { STR0005 , "MDT645PROC" , 0 , 5, 3},; //"Excluir"
                  { STR0006 , "MD645CA"    , 0 , 5, 3}} //"Componentes"
		aADD( aRotina , { STR0020, "MDT645VOTO" , 0 , 4 } ) //"Analisar Votos"
	lPyme := Iif(Type("__lPyme") <> "U",__lPyme,.F.)
	If !lPyme
 		AAdd( aRotina, { STR0048, "MsDocument", 0, 4 } )  //"Conhecimento"
	EndIf
Endif

Return aRotina
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MDT645CAN³ Autor ³Andre P. Alvarez       ³ Data ³ 17/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta um browse com os candidatos CIPA do cliente.         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDT645CAN()

Local aArea	:= GetArea()
Local oldROTINA := aCLONE(aROTINA)
Local oldCad := cCadastro
Local lMdtMin := If( SuperGetMv("MV_MDTMIN",.F.,"N") == "S", .t. , .f. )
Local aStrTNO
Local nStr

cCliMdtPs := SA1->A1_COD+SA1->A1_LOJA
nSizeSA1 := If((TAMSX3("A1_COD")[1]) < 1,6,(TAMSX3("A1_COD")[1]))
nSizeLoj := If((TAMSX3("A1_LOJA")[1]) < 1,2,(TAMSX3("A1_LOJA")[1]))

aRotina :=	{ { STR0001 , "AxPesqui"   , 0 , 1},; //"Pesquisar"
              { STR0002 , "MDT645PROC" , 0 , 2},; //"Visualizar"
              { STR0003 , "MDT645PROC" , 0 , 3},; //"Incluir"
              { STR0004 , "MDT645PROC" , 0 , 4},; //"Alterar"
              { STR0005 , "MDT645PROC" , 0 , 5, 3},; //"Excluir"
              { STR0006 , "MD645CA"    , 0 , 5, 3}} //"Componentes"

	aADD( aRotina , { STR0020, "MDT645VOTO" , 0 , 4 } ) //"Analisar Votos"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCadastro := OemtoAnsi(STR0007) //"Candidatos"
PRIVATE aCHKDEL := {}, bNGGRAVA

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³aCHKDEL array que verifica a INTEGRIDADE REFERENCIAL na exclu-³
//³s„o do registro.                                              ³
//³                                                              ³
//³1 - Chave de pesquisa                                         ³
//³2 - Alias de pesquisa                                         ³
//³3 - ordem de pesquisa                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCHKDEL := { {'cCliMdtps+TNO->TNO_MANDAT+TNO->TNO_FILMAT+TNO->TNO_MAT', "TNQ", 6}}   //"TNQ_FILIAL+TNQ_CLIENT+TNQ_LOJA+TNQ_MANDAT+TNQ_FILMAT+TNQ_MAT+DTOS(TNQ_DTSAID)"

aCHOICE := {}
aStrTNO := TNO->( dbStruct() )
For nStr := 1 To Len( aStrTNO )
	If !( aStrTNO[ nStr , 1 ] $ "TNO_CLIENT/TNO_LOJA/TNO_FILIAL" )
    	aAdd( aCHOICE, aStrTNO[ nStr , 1 ] )
	Endif
Next nStr
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcaO de BRoWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("TNO")
Set Filter To TNO->(TNO_CLIENT+TNO_LOJA) == cCliMdtps
DbSetorder(6)  //"TNO_FILIAL+TNO_CLIENT+TNO_LOJA+TNO_MANDAT+TNO_FILMAT+TNO_MAT+DTOS(TNO_DTCAND)"
mBrowse( 6, 1,22,75,"TNO")

dbSelectArea("SRA")
Set Filter To
DbSelectArea("TNQ")
DbSetorder(6)  //"TNQ_FILIAL+TNQ_CLIENT+TNQ_LOJA+TNQ_MANDAT+TNQ_FILMAT+TNQ_MAT+DTOS(TNQ_DTSAID)"
DbSelectArea("TNO")
DbSetorder(6)
Set Filter To

aROTINA := aCLONE(oldROTINA)
RestArea(aArea)
cCadastro := oldCad

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MDT645VOTO³ Autor ³ Denis Hyroshi de Souza³ Data ³ 15/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcular votos para empresas do ramo de mineracao           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDT645VOTO()

	Local LVar01:=1,nLinhas:=0,bCampo,cSaveMenuh,nCnt
	Local GetList:={},nSavRec,nX,nPos,cGrp:="",nPos1
	Local nQtdFun := 0
	Local aArea := GetArea()
	Local aAreaTNO := TNO->(GetArea())
	Local oDlg, oGet, i, oPanel
	Local lWhen := .T.
	Local aGrupo := {}
	Local cMandato := ""
	Local nMAT := 0
	Local nFld
	Local aCampos := {}
	Local bCondic := {||.T.}
	Local aExc    := {}
	Local lCipatr := SuperGetMv("MV_NG2NR31",.F.,"2") == "1"
	Local lExistMDTA6541 := ExistBlock( "MDTA6451" )
	Local cFil1Tmp := cFilAnt
	Local cMatFun  := ""
	Local dDtEleicao := SToD( "" )

	nSavRec := RecNo()

	Private lConsCIPA := .t.
	Private nSizeSI3  := If((TAMSX3("I3_CUSTO")[1]) < 1,9,(TAMSX3("I3_CUSTO")[1]))
	Private aCols := {}
	Private cCodCIPA := TNO->TNO_MANDAT
	Private aAreaCipa := {}
	Private nNumTit  := 0
	Private nNumSup  := 0
	Private aSize := MsAdvSize(,.f.,430), aObjects := {}
	Private oMENU
	Private lMandExt := NGCADICBASE("TNQ_MANEXT","A","TNQ",.F.)

	Aadd(aObjects,{050,050,.t.,.t.})
	Aadd(aObjects,{100,100,.t.,.t.})
	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObjects,.t.)

	nOpcx := 2
	nCnt := 0

	//Monta a entrada de dados do arquivo
	Private aTELA[0][0],aGETS[0],aHeader[0],nUsado:=0
	bCampo := {|nCPO| Field(nCPO) }

	aCampos := { "TNO_MAT"  , "TNO_NOME"  , "TNO_VOTOS" , "RA_CC"    , ;
			     "RA_DESCCC", "TM0_NOMFIC", "TM5_NOMFIC", "TNO_FILMAT" }

	aExc := {   { 'TNO_MAT'    , 'X3_TITULO', STR0021 }, ;
				{ 'TNO_NOME'   , 'X3_TITULO', STR0022 }, ;
				{ 'RA_CC'      , 'X3_TITULO', STR0023 }, ;
				{ 'RA_DESCCC'  , 'X3_TITULO', STR0024 }, ;
				{ 'TM0_NOMFIC' , 'X3_TITULO', If(lCipatr, STR0056, STR0025) }, ;
				{ 'TM5_NOMFIC' , 'X3_TITULO', STR0026 }  }

	bCondic := {|| IIf( cCampo == "RA_CC" .Or. cCampo == "RA_DESCCC", lMdtMin, .T. ) }

	//Monta o cabecalho
	aHeader := NGHeadExc( aCampos, .F., .F., .F., aExc, bCondic )

	If lMdtMin
		aCols := BlankGetD(aHeader)
		lWhen := .F.
	Else
		aCols := BlankGetD(aHeader)
	EndIf

		nOpca := 0
		DEFINE MSDIALOG oDlg TITLE STR0027 From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL //"Representantes eleitos pelos empregados"

		oPanel1 := TPanel():New(0, 0, Nil, oDlg, Nil, .T., .F., Nil, Nil,0, 0, .T., .F. )
		oPanel1:Align := CONTROL_ALIGN_ALLCLIENT

		oPanel := TPanel():New(0, 0, Nil, oPanel1, Nil, .T., .F., Nil, Nil,0, 55, .T., .F. )
		oPanel:Align := CONTROL_ALIGN_TOP

		@ 09,008 SAY OemtoAnsi(STR0028) of oPanel Pixel //"Mandato"
		@ 09,035 MSGET cCodCIPA SIZE 30,09 Valid fValidCIPA(@oGet) F3 "TNN" WHEN .T. of oPanel Pixel HASBUTTON
		@ 09,075 SAY OemToAnsi(STR0029) of oPanel Pixel //"Nº Titulares"
		@ 09,110 MSGET nNumTit SIZE 20,09  PICTURE "999" WHEN lWhen of oPanel Pixel
		@ 09,142 SAY OemToAnsi(STR0030) of oPanel Pixel //"Nº Suplentes"
		@ 09,178 MSGET nNumSup SIZE 20,09 PICTURE "999"  WHEN .T. of oPanel Pixel

		@ 38,008 BUTTON STR0031 SIZE 55,12 PIXEL ACTION (fCalcVot(@oGet)) of oPanel //"Calcular Votos"

		dbSelectArea("TNO")

		oGet := MSGetDados():New(0,0,0,0,nOpcx,"AllwaysTrue","AllwaysTrue","",.T.,,,,3000,,,,,oPanel1)
		oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

		NGPOPUP(asMenu,@oMenu)
		oDlg:bRClicked:= { |o,x,y| oMenu:Activate(x,y,oDlg)}

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(Mdt645TOK(),oDlg:End(),nOpca := 0)},{||oDlg:End(),nOpca := 0})

		If nOpcA == 1 .and. lConsCIPA
			//Verifica a posição do campo.
			nMAT := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TNO_MAT"})
			nFilMAT := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TNO_FILMAT"})

			Begin Transaction
				If lMandExt
					cMandato :=	NgSeek("TNN",cCodCIPA,1,"TNN_CODORI")
				EndIf
				For nX := 1 To Len(aCols)

					dbSelectArea("TNQ")
					dbSetorder(3)
					lNewTNQ := !dbSeek(xFilial("TNQ") + cCodCIPA + aCols[nX,nFilMAT] + aCols[nX,1])
					RecLock("TNQ",lNewTNQ)
					TNQ->TNQ_FILIAL := xFilial("TNQ")
					TNQ->TNQ_MANDAT := If(!Empty(cMandato),cMandato,cCodCIPA)
					If lMandExt
						TNQ->TNQ_MANEXT := If( !Empty( cMandato ), cMandato, cCodCIPA )
					EndIf
					TNQ->TNQ_MAT    := aCols[nX,nMAT]
					cMatFun         := TNQ->TNQ_MAT
					If lCpoTNO .and. lCpoTNQ
						TNQ->TNQ_FILMAT := aCols[nX,nFilMAT]
						cFil1Tmp := aCols[nX,nFilMAT]
					Endif
					If lMdtMin
						TNQ->TNQ_INDICA := If( aCols[nX,7] == STR0044 , "1", "2" ) //"EMPRESA"
						TNQ->TNQ_TIPCOM := If( aCols[nX,6] == STR0045 , "1", "2" ) //"TITULAR"
					Else
						TNQ->TNQ_INDICA := If( aCols[nX,5] == STR0044 , "1", "2" ) //"EMPRESA"
						TNQ->TNQ_TIPCOM := If( aCols[nX,4] == STR0045 , "1", "2" ) //"TITULAR"
					EndIf
					TNQ->TNQ_DTESTB := fGetEstbAtu( TNQ->TNQ_MANDAT, @dDtEleicao )
					TNQ->TNQ_DTINIC := NGSomaAno( TNQ->TNQ_DTESTB, -2 )
					TNQ->TNQ_DTSAID := TNQ->TNQ_DTESTB
					TNQ->(MsUnLock())
					If lExistMDTA6541
						ExecBlock( "MDTA6451", .F., .F. , { xFilial("TNQ"), cMandato, aCols[nX,nMAT] } )
					EndIf
					//Adiciona estabilidade
					Altera   := .f.
					Inclui   := .t.
					nTipInd1 := TNQ->TNQ_INDICA
					nTipInd2 := TNQ->TNQ_INDICA
					cTipCand := TNQ->TNQ_TIPCOM

					MDT660SRA( , cCodCIPA, cMatFun, cFil1Tmp, IIf(cTipCand == "1", "1", "2" ), .F., , , .T., )
				Next nX

				//Processa Gatilhos
				EvalTrigger()
			End Transaction
		Endif

	RestArea(aAreaTNO)
	RestArea(aArea)

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fCalcVot ³ Autor ³ Denis Hyroshi de Souza³ Data ³ 15/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica os funcionarios que serao eleitos para CIPA       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fCalcVot(oGet)

	Local nX,nY
	Local aSuplentes := {}
	Local cNaoTemCan := ""
	Local aSVcols := aClone(aCols)
	Local nReg

	dbSelectArea("TNQ")
	dbSetOrder(1)
	dbSeek(xFilial("TNQ")+cCodCIPA)
	While !Eof() .and. xFilial("TNQ")+cCodCIPA == TNQ->TNQ_FILIAL+TNQ->TNQ_MANDAT
		If TNQ->TNQ_INDICA == "2"
			MsgInfo(STR0032+; //"Não será possível calcular a quantidade de votos, pois já existem representantes "
					STR0033,STR0014) //"eleitos pelos empregados."###"Atenção"
			Return .f.
		Endif
		dbSkip()
	End
	If lMandExt
		If nNumSup+nNumTit == 0
			MsgInfo('Precisa ser preenchido o campo "Nº Titulares" ou "Nº Suplentes" para prosseguir.',STR0014)
			Return .F.
	EndIf
	Else
		If nNumSup == 0
			MsgInfo(STR0034,STR0014) //"O campo Nº Suplentes é obrigatório."###"Atenção"
			Return .f.
		ElseIf nNumTit == 0
			MsgInfo("O campo Nº Titulares é obrigatório.",STR0014)
			Return .F.
		Endif
	EndIf

	aCols := {}

	dbSelectArea("TNO")
	dbSetOrder(1)
	dbSeek(xFilial("TNO")+cCodCIPA)
	While !Eof() .and. xFilial("TNO")+cCodCIPA == TNO->TNO_FILIAL+TNO->TNO_MANDAT

		If TNO->TNO_INDICA == "2" .and. TNO->TNO_VOTOS > 0
			dbSelectArea("SRA")
			dbSetOrder(1)
			dbSeek(xFilial("SRA",TNO->TNO_FILMAT)+TNO->TNO_MAT)
			cSetor   := SRA->RA_CC
			If lMdtMin
				cAreaC   := NGSeek('TLJ', cCodCIPA + cSetor ,1,'TLJ->TLJ_AREA')
				nPosCIPA := aScan( aAreaCipa, { |x| x[1] == cAreaC })
				If nPosCIPA > 0
					aAdd( aAreaCipa[nPosCIPA, 3] , {TNO->TNO_MAT, SRA->RA_NOME, TNO->TNO_VOTOS, SRA->RA_ADMISSA } )
					aAdd( aSuplentes , {TNO->TNO_MAT, SRA->RA_NOME, TNO->TNO_VOTOS, SRA->RA_ADMISSA, cAreaC, TNO->TNO_FILMAT } )
				Endif
			Else
				aAdd( aSuplentes , {TNO->TNO_MAT, SRA->RA_NOME, TNO->TNO_VOTOS, SRA->RA_ADMISSA, TNO->TNO_FILMAT} )
			EndIf
		Endif

		dbSelectArea("TNO")
		dbSkip()
	End
	If lMdtMin
		For nX := 1 To Len(aAreaCipa)
			If Len(aAreaCipa[nX,3]) > 0
				cMatEleito := aAreaCipa[nX,3,1,1]
				cNomEleito := aAreaCipa[nX,3,1,2]
				nVomEleito := aAreaCipa[nX,3,1,3]
				dAdmEleito := aAreaCipa[nX,3,1,4]
				For nY := 2 To Len(aAreaCipa[nX,3])
					If aAreaCipa[nX,3,nY,3] > nVomEleito .or. ;
						(aAreaCipa[nX,3,nY,3] == nVomEleito .and. aAreaCipa[nX,3,1,4] > dAdmEleito)

						cMatEleito := aAreaCipa[nX,3,nY,1]
						cNomEleito := aAreaCipa[nX,3,nY,2]
						nVomEleito := aAreaCipa[nX,3,nY,3]
						dAdmEleito := aAreaCipa[nX,3,nY,4]
					Endif
				Next nY

				aAdd( aCols , {	cMatEleito,;
							cNomEleito,;
							nVomEleito,;
							aAreaCipa[nX, 1],;
							NGSeek(cAliasCC, aAreaCipa[nX, 1] ,1,cDesCC),;
							STR0045,STR0046,; //"TITULAR"###"EMPREGADOS"
							aSuplentes[nX,6],;
							.f.;
							})

			Else
				If Empty(cNaoTemCan)
					cNaoTemCan := STR0035 + Chr(13) //"As seguintes áreas não possuem candidatos com votos: "
				Endif
				cNaoTemCan += " - " + NGSeek(cAliasCC, aAreaCipa[nX, 1] ,1,cDesCC) + Chr(13)
			Endif
		Next nX
	EndIf

	aSort(aSuplentes,,,{|x,y| ( x[3] > y[3] ) .or. ( x[3] == y[3] .and. x[4] < y[4] ) })

	If lMdtMin
		//Retira os registros dos titulares já inclusos no acols
		For nReg := 1 to Len(aCols)
			nPOS2 := Ascan( aSuplentes, {|x| x[1] == aCols[ nReg, 1 ] } )
			If nPOS2 > 0
				aDel(aSuplentes,nPOS2)
				aSize(aSuplentes,Len(aSuplentes)-1)
			Endif
		Next nReg

		For nX := 1 To nNumSup
			If nX > 0 .and. nX <= Len(aSuplentes)
				aAdd( aCols , {	aSuplentes[nX,1],;
								aSuplentes[nX,2],;
								aSuplentes[nX,3],;
								aSuplentes[nX,5],;
								NGSeek(cAliasCC, aSuplentes[nX,5] ,1,cDesCC),;
								STR0047,STR0046,; //"SUPLENTE"###"EMPREGADOS"
								aSuplentes[nX,6],;
								.f.;
								})
			Endif
		Next nX
	Else
		For nX := 1 To nNumSup + nNumTit
			If nX > 0 .and. nX <= Len(aSuplentes)
				If nX <= nNumTit
					aAdd( aCols , {	aSuplentes[nX,1],;
					aSuplentes[nX,2],;
					aSuplentes[nX,3],;
					STR0045,STR0046,;//"TITULAR"###"EMPREGADOS"
					aSuplentes[nX,5],;
					.f.;
					})
				Else
					aAdd( aCols , {	aSuplentes[nX,1],;
					aSuplentes[nX,2],;
					aSuplentes[nX,3],;
					STR0047,STR0046,; //"SUPLENTE"###"EMPREGADOS"
					aSuplentes[nX,5],;
					.f.;
					})
				EndIf
			Endif
		Next nX
	EndIf

	If Len(aCols) == 0
		MsgInfo(STR0036,STR0037) //"Nenhum dos candidatos receberam votos."###"Aviso"
		aCols := BlankGetD(aHeader)
	Else
		If !Empty(cNaoTemCan)
			cNaoTemCan += Chr(13) + STR0038 //"Deseja continuar?"
			If !MsgYesNo(cNaoTemCan,STR0014) //"Atenção"
				aCols := aClone(aSVcols)
			Endif
		Endif
	Endif

	n := 1
	oGet:oBrowse:Refresh()

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fValidCIPA³ Autor ³ Denis Hyroshi de Souza³ Data ³ 15/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida codigo da CIPA                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fValidCIPA(oGet)
	Local aAreaXXX := GetArea()
	Local aAreaTLJ := TLJ->(GetArea())
	Local nSizeCli := If((TAMSX3("A1_COD")[1]) < 1,6,(TAMSX3("A1_COD")[1]))
	Local nSizeLoj := If((TAMSX3("A1_LOJA")[1]) < 1,2,(TAMSX3("A1_LOJA")[1]))
	Local nQtdFun  := 0
	Local aGrupo := {}
	Local nMult2500
	Local nResu
	Local nExcedeu, nPos
	Local nTitu, nSuple, cGrp:="", lCnae:= .T.
	Local cMandato
	Local lCipatr := If( SuperGetMv("MV_NG2NR31",.F.,"2") == "1", .T. , .F. )

	Private lMandExt := NGCADICBASE("TNQ_MANEXT","A","TNQ",.F.)

	If lSigaMdtps

		If !ExistCpo("TNN",SA1->(A1_COD+A1_LOJA)+cCodCIPA)
			RestArea(aAreaXXX)
			Return .f.
		Endif

		dbSelectArea("TNQ")
		dbSetOrder(4)  //TNQ_FILIAL+TNQ_CLIENT+TNQ_LOJA+TNQ_MANDAT+TNQ_MAT+DTOS(TNQ_DTSAID)
		dbSeek(xFilial("TNQ")+SA1->(A1_COD+A1_LOJA)+cCodCIPA)
		While !Eof() .and. xFilial("TNQ")+SA1->(A1_COD+A1_LOJA)+cCodCIPA == TNQ->TNQ_FILIAL+TNQ->TNQ_CLIENT+TNQ->TNQ_LOJA+TNQ->TNQ_MANDAT
			If TNQ->TNQ_INDICA == "2"
				If MsgYesNo(STR0039+Chr(13)+; //"Já existem representantes eleitos pelos empregados."
							STR0040,STR0014) //"Deseja apenas visualizar o Quadro de Representantes da CIPA?"###"Atenção"

					aCols := {}
					lConsCIPA := .f.

					dbSelectArea("TNQ")
					dbSetOrder(4)  //TNQ_FILIAL+TNQ_CLIENT+TNQ_LOJA+TNQ_MANDAT+TNQ_MAT+DTOS(TNQ_DTSAID)
					dbSeek(xFilial("TNQ")+SA1->(A1_COD+A1_LOJA)+cCodCIPA)
					While !Eof() .and. xFilial("TNQ")+SA1->(A1_COD+A1_LOJA)+cCodCIPA == TNQ->TNQ_FILIAL+TNQ->TNQ_CLIENT+TNQ->TNQ_LOJA+TNQ->TNQ_MANDAT

						dbSelectArea("SRA")
						dbSetOrder(1)
						dbSeek(xFilial("SRA",TNQ->TNQ_FILMAT)+TNQ->TNQ_MAT)
						dbSelectArea("TNO")
						dbSetOrder(4)  //TNO_FILIAL+TNO_CLIENT+TNO_LOJA+TNO_MANDAT+TNO_MAT+DTOS(TNO_DTCAND)
						dbSeek(xFilial("TNO") + SA1->(A1_COD+A1_LOJA) + cCodCIPA + TNQ->TNQ_MAT)
						cTipCom := If( TNQ->TNQ_TIPCOM == "1", STR0045 , STR0047 ) //"TITULAR"###"SUPLENTE"
						cTipFun := If( TNQ->TNQ_INDICA == "1", STR0044 , STR0046 ) //"EMPRESA"###"EMPREGADOS"
						cAreaC  := NGSeek('TLJ', cCodCIPA + SRA->RA_CC ,1,'TLJ->TLJ_AREA')
						aAdd( aCols , {	TNQ->TNQ_MAT,;
										SRA->RA_NOME,;
										TNO->TNO_VOTOS,;
										cAreaC ,;
										NGSeek(cAliasCC, cAreaC ,1,cDesCC),;
										cTipCom,cTipFun,.f.;
										})

						dbSelectArea("TNQ")
						dbSkip()
					End
					aSort(aCols,,,{|x,y| x[6]+Strzero(x[3],4) > y[6]+Strzero(y[3],4) })
					n := 1
					oGet:oBrowse:Refresh()
					RestArea(aAreaXXX)
					Return .t.
				Else
					RestArea(aAreaXXX)
					Return .f.
				Endif
			Endif
			dbSkip()
		End
		If lMdtMin
			dbSelectArea("TLJ")
			dbSetOrder(1)
			Set Filter To SubStr(TLJ->TLJ_CC,1,nSizeCli+nSizeLoj) == SA1->(A1_COD+A1_LOJA) .AND.;
						xFilial("TLJ") == TLJ->TLJ_FILIAL .and. cCodCIPA == TLJ->TLJ_MANDAT
			dbGoTop()
			While !eof()
				If !Empty(TLJ->TLJ_AREA) .and. !Empty(TLJ->TLJ_CC)
					nPosCIPA := aScan( aAreaCipa, { |x| x[1] == TLJ->TLJ_AREA })
					If nPosCIPA == 0
						aAdd( aAreaCipa , {TLJ->TLJ_AREA ,{TLJ->TLJ_CC} , {} } )
					Else
						aAdd( aAreaCipa[nPosCIPA, 2] , TLJ->TLJ_CC )
					Endif
				Endif
				dbSkip()
			End
		EndIf

		Set Filter To

	Else
	If Empty(SM0->M0_CNAE)
		MsgStop(STR0049,STR0014)
		lCnae := .F.
		Return .T.
	EndIf

		If !ExistCpo("TNN",cCodCIPA)
			RestArea(aAreaXXX)
			Return .f.
		Endif
		If lCnae
			///////////////////////////////////////////////////////////
				// Sugere  Suplentes e Titulares conforme QUADRO I - nr5 //
				///////////////////////////////////////////////////////////
			Dbselectarea("SRA")
			DbSetOrder(1)
			DbSeek(xFilial("SRA"))
			While !eof() .and. xFilial("SRA") == SRA->RA_FILIAL
				If !(SRA->RA_SITFOLH $ "T/D") .And. Empty(SRA->RA_DEMISSA)
					nQtdFun++
				EndIf
				DbSkip()
			End
			Dbselectarea("TOE")
			Dbsetorder(1)
			If Dbseek(xFilial("TOE")+SM0->M0_CNAE)
				cGrp := TOE->TOE_GRUPO
			EndIf
			aGrupo := CriaGrup()
			If nQtdFun > 10000
				nPos1 := aScan ( aGrupo , { |x|	 x[1] == AllTrim(cGrp) .And. nQtdFun >= Val(x[2])}) // ultima coluna
				nPos  := aScan( aGrupo, { |x| x[1] == AllTrim(cGrp) .And. 7000 >= Val(x[2]) .And. 7000 <= Val(x[3])})// para pegar penultima coluna
				//conta para saber quantos grupos de 2500 funcionarios existe
				nExcedeu  := nQtdFun - 10000
				nMult2500 := Int(nExcedeu/2500)
				If (nExcedeu % 2500) > 0
					nMult2500++
				EndIF
				If nPos > 0 .and. nPos1 > 0
					// Valores Ultima Coluna
					nTit :=  Val(aGrupo[nPos1,4])
					nSup :=  Val(aGrupo[nPos1,5])
				// Valores Penultima Coluna
				nTitu  := Val(aGrupo[nPos,4])
				nSuple := Val(aGrupo[nPos,4])
				//Valores Para Sugestao no Browse
					nNumTit  := nTit+(nTitu*nMult2500)
					nNumSup  := nSup+(nSuple*nMult2500)
				EndIf
			Else
				nPos := aScan( aGrupo, { |x| x[1] == AllTrim(cGrp) .And. nQtdFun >= Val(x[2]) .And. nQtdFun <= Val(x[3])})
				If nPos > 0
					nNumTit  := Val(aGrupo[nPos,4])
					nNumSup  := Val(aGrupo[nPos,5])
				EndIf
			EndIf
			//
		EndIf
		cMandOri := ""
		nIndTNQ  := 1
		If lMandExt
			//Se for mandato extraordinario ele nao sugere titulares e suplentes
			dbSelectArea("TNN")
			dbSetOrder(1)
			If dbSeek(xFilial("TNN")+cCodCIPA)
				cMandOri :=	TNN->TNN_CODORI
				nIndTNQ  := 4
				If !Empty(cMandOri)
					nNumTit := 0
					nNumSup := 0
				EndIf
			Endif
		Endif
		cMandSeek := If(!Empty(cMandOri),cMandOri,cCodCIPA)
		dbSelectArea("TNQ")
		dbSetOrder(nIndTNQ)
		dbSeek(xFilial("TNQ")+cCodCIPA)
		While !Eof() .and. xFilial("TNQ")+cMandSeek == TNQ->TNQ_FILIAL+TNQ->TNQ_MANDAT
			If TNQ->TNQ_INDICA == "2"
				oGet:oBrowse:Refresh()
				If MsgYesNo(STR0039+Chr(13)+; //"Já existem representantes eleitos pelos empregados."
							If(lCipatr, STR0057, STR0040), STR0014) //"Deseja apenas visualizar o Quadro de Representantes da CIPATR?" //"Deseja apenas visualizar o Quadro de Representantes da CIPA?"###"Atenção"

					aCols := {}
					lConsCIPA := .f.

					dbSelectArea("TNQ")
					dbSetOrder(1)
					dbSeek(xFilial("TNQ")+cMandSeek)
					While !Eof() .and. xFilial("TNQ")+cMandSeek == TNQ->TNQ_FILIAL+TNQ->TNQ_MANDAT
					If !Empty(cMandOri) .And. If(lMandExt, TNQ->TNQ_MANEXT <> cCodCIPA, .T.)
						dbSelectArea("TNQ")
						dbSkip()
						loop
					EndIf

						dbSelectArea("SRA")
						dbSetOrder(1)
						dbSeek(xFilial("SRA",TNQ->TNQ_FILMAT)+TNQ->TNQ_MAT)
						dbSelectArea("TNO")
						dbSetOrder(1)
						dbSeek(xFilial("TNO") +cMandSeek + TNQ->TNQ_MAT)
						cTipCom := If( TNQ->TNQ_TIPCOM == "1", STR0045 , STR0047 ) //"TITULAR"###"SUPLENTE"
						cTipFun := If( TNQ->TNQ_INDICA == "1", STR0044 , STR0046 ) //"EMPRESA"###"EMPREGADOS"
						If lMdtMin
							cAreaC  := NGSeek('TLJ', cMandSeek + SRA->RA_CC ,1,'TLJ->TLJ_AREA')
						aAdd( aCols , {	TNQ->TNQ_MAT,;
										SRA->RA_NOME,;
										TNO->TNO_VOTOS,;
										cAreaC ,;
										NGSeek(cAliasCC, cAreaC ,1,cDesCC),;
										cTipCom,cTipFun,.f.;
										})
						Else
							aAdd( aCols , {	TNQ->TNQ_MAT,;
											SRA->RA_NOME,;
											TNO->TNO_VOTOS,;
											cTipCom,cTipFun,.f.;
											})
						EndIf
						dbSelectArea("TNQ")
						dbSkip()
					End
					If lMDTMin
					aSort(aCols,,,{|x,y| x[6]+Strzero(x[3],4) > y[6]+Strzero(y[3],4) })
					EndIf
					n := 1
					oGet:oBrowse:Refresh()
					RestArea(aAreaXXX)
					Return .t.
				Else
					oGet:oBrowse:Refresh()
					RestArea(aAreaXXX)
					Return .f.
				Endif
			Endif
			dbSkip()
		End
		If lMDTMin
		dbSelectArea("TLJ")
		dbSetOrder(1)
		dbSeek( xFilial("TLJ") + cCodCIPA )
		While !eof() .and. xFilial("TLJ") == TLJ->TLJ_FILIAL .and. cCodCIPA == TLJ->TLJ_MANDAT
			If !Empty(TLJ->TLJ_AREA) .and. !Empty(TLJ->TLJ_CC)
				nPosCIPA := aScan( aAreaCipa, { |x| x[1] == TLJ->TLJ_AREA })
				If nPosCIPA == 0
					aAdd( aAreaCipa , {TLJ->TLJ_AREA ,{TLJ->TLJ_CC} , {} } )
				Else
					aAdd( aAreaCipa[nPosCIPA, 2] , TLJ->TLJ_CC )
				Endif
			Endif
			dbSkip()
		End
		EndIf
	Endif
	If lMDTMin
	If Len(aAreaCipa) == 0
		MsgInfo(STR0041+; //"Não será possível selecionar este Mandato da CIPA, pois não existem áreas "
				STR0042+; //"cadastradas para dimensionar a quantidade de representantes titulares "
				STR0033,STR0014) //"eleitos pelos empregados."###"Atenção"
	Else
		nNumTit := Len(aAreaCipa)
		lConsCIPA := .t.
	Endif
	EndIf
	///
	RestArea(aAreaTLJ)
	RestArea(aAreaXXX)

Return If (lMdtMin,(Len(aAreaCipa) != 0),.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Mdt645TOK ³ Autor ³ Denis Hyroshi de Souza³ Data ³ 15/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida confirmacao da tela Calcular Votos                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Mdt645TOK()
	Local lRet := .T.
	Local lCipatr := If( SuperGetMv("MV_NG2NR31",.F.,"2") == "1", .T. , .F. )

	If lMdtMin

		If Len(aCols) > 0 .and. lConsCIPA

			If !Empty(aCols[1,1])
				Return MsgYesNo(If(lCipatr,STR0057,STR0043)) //"Deseja confirmar estes candidatos como componentes da CIPATR?" //"Deseja confirmar estes candidatos como componentes da CIPA?"
			Endif

		Endif

	ElseIf !(Len(aCols) > 0 .And. !Empty(aCols[1,1]))
		MsgStop("É preciso ter candidados para confirmar.",STR0014)
		lRet := .F.
	EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CodAreaCIPA Autor ³ Denis Hyroshi de Souza³ Data ³ 15/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Busca codigo da area da CIPA                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CodAreaCIPA(cMatricula,cCodCIPA)
Local aArea := GetArea()
Local cCodigo := Space(9)

dbSelectArea("SRA")
dbSetOrder(1)
If dbSeek(xFilial("SRA")+cMatricula)
	cCodigo := NGSeek('TLJ', cCodCIPA + SRA->RA_CC ,1,'TLJ->TLJ_AREA')
Endif

RestArea(aArea)

Return cCodigo
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³NomAreaCIPA Autor ³ Denis Hyroshi de Souza³ Data ³ 15/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Busca o nome da area da CIPA                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NomAreaCIPA(cMatricula,cCodCIPA)
Local aArea   := GetArea()
Local cCodigo := Space(9)
Local cNome   := Space(20)

Local cAliasCC := "CTT"
Local cDesCC   := "CTT->CTT_DESC01"

If Alltrim(GETMV("MV_MCONTAB")) != "CTB"
	cAliasCC := "SI3"
	cDesCC   := "SI3->I3_DESC"
Endif

dbSelectArea("SRA")
dbSetOrder(1)
If dbSeek(xFilial("SRA")+cMatricula)
	cCodigo := NGSeek('TLJ', cCodCIPA + SRA->RA_CC ,1,'TLJ->TLJ_AREA')
	cNome   := NGSeek(cAliasCC, cCodigo ,1,cDesCC)
Endif

RestArea(aArea)

Return cNome
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MDT645NOM³  Autor ³Andre Perez Alvarez    ³ Data ³ 24/06/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Mostra o nome do funcionario no browse da TNO.              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MDT645NOM()

Local cDesc := ""
Local aArea := GetArea()

cDesc := Posicione("SRA",1,xFilial("SRA",TNO->TNO_FILMAT)+TNO->TNO_MAT,"RA_NOME")

RestArea(aArea)
Return cDesc
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MDT645NOM³  Autor ³Andre Perez Alvarez    ³ Data ³ 24/06/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Mostra o nome do funcionario no browse da TNO.              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function GRPCIPABOX()
Return "C-1=Minerais;C-1a=Minerais';C-2=Alimentos;C-3=Têxteis;C-3a=Têxteis';C-4=Confecção;"+;
"C-5=Calçados e Similares;C-5a=Calçados e Similares';C-6=Madeira;C-7=Papel;C-7a=Papel';C-8=Gráficos;"+;
"C-9=Som & Imagem;C-10=Químicos;C-11=Borracha;C-12=Não Metálicos;C-13=Metálicos;C-14=Equipamentos/Máquinas e Ferramentas;"+;
"C-14a=Equipamentos/Máquinas e Ferramentas';C-15=Explosivos e Armas;C-16=Veículos;C-17=Água e Energia;C-18=Construção;"+;
"C-18a=Construção';C-19=Intermediários do Comércio;C-20=Comércio Atacadista;C-21=Comércio Varejista;"+;
"C-22=Comércio de Produtos Perigosos;C-23=Alojamento e Alimentação;C-24=Transporte;C-24a=Transporte';"+;
"C-24b;Transporte'';C-25=Correio e Telecomunicações;C-26=Seguro;C-27=Administração de Mercados Financeiros;"+;
"C-28=Bancos;C-29=Serviços;C-30=Locação de Mão de Obra e Limpeza;C-31=Ensino;C-32=Pesquisa;C-33=Administração Pública;"+;
"C-34=Saúde;C-35=Outros Serviços;"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MDTA645   ºAutor  ³Pedro Cardoso Furst º Data ³  02/27/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CriaGrup()
	Local aGrupo := {}

	aAdd(aGrupo,{"C-1","0","19","",""})
	aAdd(aGrupo,{"C-1","20","29","1","1"})
	aAdd(aGrupo,{"C-1","30","50","1","1"})
	aAdd(aGrupo,{"C-1","51","80","3","3"})
	aAdd(aGrupo,{"C-1","81","100","3","3"})
	aAdd(aGrupo,{"C-1","101","120","4","3"})
	aAdd(aGrupo,{"C-1","121","140","4","3"})
	aAdd(aGrupo,{"C-1","141","300","4","3"})
	aAdd(aGrupo,{"C-1","301","500","4","3"})
	aAdd(aGrupo,{"C-1","501","1000","6","4"})
	aAdd(aGrupo,{"C-1","1001","2500","9","7"})
	aAdd(aGrupo,{"C-1","2501","5000","12","9"})
	aAdd(aGrupo,{"C-1","5001","10000","15","12"})
	aAdd(aGrupo,{"C-1","10001","","2","2"})

	aAdd(aGrupo,{"C-1a","0","19","",""})
	aAdd(aGrupo,{"C-1a","20","29","1","1"})
	aAdd(aGrupo,{"C-1a","30","50","1","1"})
	aAdd(aGrupo,{"C-1a","51","80","3","3"})
	aAdd(aGrupo,{"C-1a","81","100","3","3"})
	aAdd(aGrupo,{"C-1a","101","120","4","3"})
	aAdd(aGrupo,{"C-1a","121","140","4","3"})
	aAdd(aGrupo,{"C-1a","141","300","4","3"})
	aAdd(aGrupo,{"C-1a","301","500","4","4"})
	aAdd(aGrupo,{"C-1a","501","1000","6","5"})
	aAdd(aGrupo,{"C-1a","1001","2500","9","8"})
	aAdd(aGrupo,{"C-1a","2501","5000","12","9"})
	aAdd(aGrupo,{"C-1a","5001","10000","15","12"})
	aAdd(aGrupo,{"C-1a","10001","","2","2"})

	aAdd(aGrupo,{"C-2","0","19","",""})
	aAdd(aGrupo,{"C-2","20","29","1","1"})
	aAdd(aGrupo,{"C-2","30","50","1","1"})
	aAdd(aGrupo,{"C-2","51","80","2","2"})
	aAdd(aGrupo,{"C-2","81","100","2","2"})
	aAdd(aGrupo,{"C-2","101","120","3","3"})
	aAdd(aGrupo,{"C-2","121","140","4","3"})
	aAdd(aGrupo,{"C-2","141","300","4","4"})
	aAdd(aGrupo,{"C-2","301","500","5","4"})
	aAdd(aGrupo,{"C-2","501","1000","6","5"})
	aAdd(aGrupo,{"C-2","1001","2500","7","6"})
	aAdd(aGrupo,{"C-2","2501","5000","10","7"})
	aAdd(aGrupo,{"C-2","5001","10000","11","9"})
	aAdd(aGrupo,{"C-2","10001","","2","1"})

	aAdd(aGrupo,{"C-3","0","19","",""})
	aAdd(aGrupo,{"C-3","20","29","1","1"})
	aAdd(aGrupo,{"C-3","30","50","1","1"})
	aAdd(aGrupo,{"C-3","51","80","2","2"})
	aAdd(aGrupo,{"C-3","81","100","2","2"})
	aAdd(aGrupo,{"C-3","101","120","3","3"})
	aAdd(aGrupo,{"C-3","121","140","3","3"})
	aAdd(aGrupo,{"C-3","141","300","4","4"})
	aAdd(aGrupo,{"C-3","301","500","5","4"})
	aAdd(aGrupo,{"C-3","501","1000","6","5"})
	aAdd(aGrupo,{"C-3","1001","2500","7","6"})
	aAdd(aGrupo,{"C-3","2501","5000","10","8"})
	aAdd(aGrupo,{"C-3","5001","10000","10","8"})
	aAdd(aGrupo,{"C-3","10001","","2","2"})

	aAdd(aGrupo,{"C-3a","0","19","",""})
	aAdd(aGrupo,{"C-3a","20","29","",""})
	aAdd(aGrupo,{"C-3a","30","50","",""})
	aAdd(aGrupo,{"C-3a","51","80","1","1"})
	aAdd(aGrupo,{"C-3a","81","100","1","1"})
	aAdd(aGrupo,{"C-3a","101","120","2","2"})
	aAdd(aGrupo,{"C-3a","121","140","2","2"})
	aAdd(aGrupo,{"C-3a","141","300","2","2"})
	aAdd(aGrupo,{"C-3a","301","500","3","3"})
	aAdd(aGrupo,{"C-3a","501","1000","3","3"})
	aAdd(aGrupo,{"C-3a","1001","2500","4","3"})
	aAdd(aGrupo,{"C-3a","2501","5000","5","4"})
	aAdd(aGrupo,{"C-3a","5001","10000","6","5"})
	aAdd(aGrupo,{"C-3a","10001","","1","1"})

	aAdd(aGrupo,{"C-4","0","19","",""})
	aAdd(aGrupo,{"C-4","20","29","",""})
	aAdd(aGrupo,{"C-4","30","50","1","1"})
	aAdd(aGrupo,{"C-4","51","80","1","1"})
	aAdd(aGrupo,{"C-4","81","100","1","1"})
	aAdd(aGrupo,{"C-4","101","120","1","1"})
	aAdd(aGrupo,{"C-4","121","140","1","1"})
	aAdd(aGrupo,{"C-4","141","300","2","2"})
	aAdd(aGrupo,{"C-4","301","500","2","2"})
	aAdd(aGrupo,{"C-4","501","1000","2","2"})
	aAdd(aGrupo,{"C-4","1001","2500","3","3"})
	aAdd(aGrupo,{"C-4","2501","5000","5","4"})
	aAdd(aGrupo,{"C-4","5001","10000","6","4"})
	aAdd(aGrupo,{"C-4","10001","","1","1"})

	aAdd(aGrupo,{"C-5","0","19","",""})
	aAdd(aGrupo,{"C-5","20","29","1","1"})
	aAdd(aGrupo,{"C-5","30","50","1","1"})
	aAdd(aGrupo,{"C-5","51","80","2","2"})
	aAdd(aGrupo,{"C-5","81","100","3","3"})
	aAdd(aGrupo,{"C-5","101","120","3","3"})
	aAdd(aGrupo,{"C-5","121","140","4","3"})
	aAdd(aGrupo,{"C-5","141","300","4","4"})
	aAdd(aGrupo,{"C-5","301","500","4","4"})
	aAdd(aGrupo,{"C-5","501","1000","6","5"})
	aAdd(aGrupo,{"C-5","1001","2500","9","7"})
	aAdd(aGrupo,{"C-5","2501","5000","9","7"})
	aAdd(aGrupo,{"C-5","5001","10000","11","9"})
	aAdd(aGrupo,{"C-5","10001","","2","2"})

	aAdd(aGrupo,{"C-5a","0","19","",""})
	aAdd(aGrupo,{"C-5a","20","29","",""})
	aAdd(aGrupo,{"C-5a","30","50","",""})
	aAdd(aGrupo,{"C-5a","51","80","1","1"})
	aAdd(aGrupo,{"C-5a","81","100","1","1"})
	aAdd(aGrupo,{"C-5a","101","120","2","2"})
	aAdd(aGrupo,{"C-5a","121","140","2","2"})
	aAdd(aGrupo,{"C-5a","141","300","2","2"})
	aAdd(aGrupo,{"C-5a","301","500","3","3"})
	aAdd(aGrupo,{"C-5a","501","1000","3","3"})
	aAdd(aGrupo,{"C-5a","1001","2500","4","3"})
	aAdd(aGrupo,{"C-5a","2501","5000","6","4"})
	aAdd(aGrupo,{"C-5a","5001","10000","7","5"})
	aAdd(aGrupo,{"C-5a","10001","","1","1"})

	aAdd(aGrupo,{"C-6","0","19","",""})
	aAdd(aGrupo,{"C-6","20","29","1","1"})
	aAdd(aGrupo,{"C-6","30","50","1","1"})
	aAdd(aGrupo,{"C-6","51","80","2","2"})
	aAdd(aGrupo,{"C-6","81","100","3","3"})
	aAdd(aGrupo,{"C-6","101","120","3","3"})
	aAdd(aGrupo,{"C-6","121","140","4","3"})
	aAdd(aGrupo,{"C-6","141","300","5","4"})
	aAdd(aGrupo,{"C-6","301","500","5","4"})
	aAdd(aGrupo,{"C-6","501","1000","6","4"})
	aAdd(aGrupo,{"C-6","1001","2500","8","6"})
	aAdd(aGrupo,{"C-6","2501","5000","10","8"})
	aAdd(aGrupo,{"C-6","5001","10000","12","10"})
	aAdd(aGrupo,{"C-6","10001","","2","2"})

	aAdd(aGrupo,{"C-7","0","19","",""})
	aAdd(aGrupo,{"C-7","20","29","",""})
	aAdd(aGrupo,{"C-7","30","50","",""})
	aAdd(aGrupo,{"C-7","51","80","1","1"})
	aAdd(aGrupo,{"C-7","81","100","1","1"})
	aAdd(aGrupo,{"C-7","101","120","2","2"})
	aAdd(aGrupo,{"C-7","121","140","2","2"})
	aAdd(aGrupo,{"C-7","141","300","2","2"})
	aAdd(aGrupo,{"C-7","301","500","2","2"})
	aAdd(aGrupo,{"C-7","501","1000","3","3"})
	aAdd(aGrupo,{"C-7","1001","2500","4","3"})
	aAdd(aGrupo,{"C-7","2501","5000","5","4"})
	aAdd(aGrupo,{"C-7","5001","10000","6","4"})
	aAdd(aGrupo,{"C-7","10001","","1","1"})

	aAdd(aGrupo,{"C-7a","0","19","",""})
	aAdd(aGrupo,{"C-7a","20","29","1","1"})
	aAdd(aGrupo,{"C-7a","30","50","1","1"})
	aAdd(aGrupo,{"C-7a","51","80","2","2"})
	aAdd(aGrupo,{"C-7a","81","100","2","2"})
	aAdd(aGrupo,{"C-7a","101","120","3","3"})
	aAdd(aGrupo,{"C-7a","121","140","3","3"})
	aAdd(aGrupo,{"C-7a","141","300","4","3"})
	aAdd(aGrupo,{"C-7a","301","500","5","4"})
	aAdd(aGrupo,{"C-7a","501","1000","6","5"})
	aAdd(aGrupo,{"C-7a","1001","2500","8","7"})
	aAdd(aGrupo,{"C-7a","2501","5000","9","8"})
	aAdd(aGrupo,{"C-7a","5001","10000","10","8"})
	aAdd(aGrupo,{"C-7a","10001","","2","2"})

	aAdd(aGrupo,{"C-8","0","19","",""})
	aAdd(aGrupo,{"C-8","20","29","1","1"})
	aAdd(aGrupo,{"C-8","30","50","1","1"})
	aAdd(aGrupo,{"C-8","51","80","2","2"})
	aAdd(aGrupo,{"C-8","81","100","2","2"})
	aAdd(aGrupo,{"C-8","101","120","3","3"})
	aAdd(aGrupo,{"C-8","121","140","3","3"})
	aAdd(aGrupo,{"C-8","141","300","4","3"})
	aAdd(aGrupo,{"C-8","301","500","5","4"})
	aAdd(aGrupo,{"C-8","501","1000","6","4"})
	aAdd(aGrupo,{"C-8","1001","2500","7","5"})
	aAdd(aGrupo,{"C-8","2501","5000","8","6"})
	aAdd(aGrupo,{"C-8","5001","10000","10","8"})
	aAdd(aGrupo,{"C-8","10001","","1","1"})

	aAdd(aGrupo,{"C-9","0","19","",""})
	aAdd(aGrupo,{"C-9","20","29","",""})
	aAdd(aGrupo,{"C-9","30","50","",""})
	aAdd(aGrupo,{"C-9","51","80","1","1"})
	aAdd(aGrupo,{"C-9","81","100","1","1"})
	aAdd(aGrupo,{"C-9","101","120","1","1"})
	aAdd(aGrupo,{"C-9","121","140","2","2"})
	aAdd(aGrupo,{"C-9","141","300","2","2"})
	aAdd(aGrupo,{"C-9","301","500","2","2"})
	aAdd(aGrupo,{"C-9","501","1000","3","3"})
	aAdd(aGrupo,{"C-9","1001","2500","5","4"})
	aAdd(aGrupo,{"C-9","2501","5000","6","4"})
	aAdd(aGrupo,{"C-9","5001","10000","7","5"})
	aAdd(aGrupo,{"C-9","10001","","1","1"})

	aAdd(aGrupo,{"C-10","0","19","",""})
	aAdd(aGrupo,{"C-10","20","29","1","1"})
	aAdd(aGrupo,{"C-10","30","50","1","1"})
	aAdd(aGrupo,{"C-10","51","80","2","2"})
	aAdd(aGrupo,{"C-10","81","100","2","2"})
	aAdd(aGrupo,{"C-10","101","120","3","3"})
	aAdd(aGrupo,{"C-10","121","140","3","3"})
	aAdd(aGrupo,{"C-10","141","300","4","3"})
	aAdd(aGrupo,{"C-10","301","500","4","4"})
	aAdd(aGrupo,{"C-10","501","1000","5","4"})
	aAdd(aGrupo,{"C-10","1001","2500","8","6"})
	aAdd(aGrupo,{"C-10","2501","5000","9","7"})
	aAdd(aGrupo,{"C-10","5001","10000","10","8"})
	aAdd(aGrupo,{"C-10","10001","","2","2"})

	aAdd(aGrupo,{"C-11","0","19","",""})
	aAdd(aGrupo,{"C-11","20","29","1","1"})
	aAdd(aGrupo,{"C-11","30","50","1","1"})
	aAdd(aGrupo,{"C-11","51","80","2","2"})
	aAdd(aGrupo,{"C-11","81","100","3","3"})
	aAdd(aGrupo,{"C-11","101","120","3","3"})
	aAdd(aGrupo,{"C-11","121","140","4","3"})
	aAdd(aGrupo,{"C-11","141","300","4","3"})
	aAdd(aGrupo,{"C-11","301","500","5","4"})
	aAdd(aGrupo,{"C-11","501","1000","6","4"})
	aAdd(aGrupo,{"C-11","1001","2500","9","7"})
	aAdd(aGrupo,{"C-11","2501","5000","10","8"})
	aAdd(aGrupo,{"C-11","5001","10000","12","10"})
	aAdd(aGrupo,{"C-11","10001","","2","2"})

	aAdd(aGrupo,{"C-12","0","19","",""})
	aAdd(aGrupo,{"C-12","20","29","1","1"})
	aAdd(aGrupo,{"C-12","30","50","1","1"})
	aAdd(aGrupo,{"C-12","51","80","2","2"})
	aAdd(aGrupo,{"C-12","81","100","3","3"})
	aAdd(aGrupo,{"C-12","101","120","3","3"})
	aAdd(aGrupo,{"C-12","121","140","4","3"})
	aAdd(aGrupo,{"C-12","141","300","4","3"})
	aAdd(aGrupo,{"C-12","301","500","5","4"})
	aAdd(aGrupo,{"C-12","501","1000","7","6"})
	aAdd(aGrupo,{"C-12","1001","2500","8","6"})
	aAdd(aGrupo,{"C-12","2501","5000","9","7"})
	aAdd(aGrupo,{"C-12","5001","10000","10","8"})
	aAdd(aGrupo,{"C-12","10001","","2","2"})

	aAdd(aGrupo,{"C-13","0","19","",""})
	aAdd(aGrupo,{"C-13","20","29","1","1"})
	aAdd(aGrupo,{"C-13","30","50","1","1"})
	aAdd(aGrupo,{"C-13","51","80","3","3"})
	aAdd(aGrupo,{"C-13","81","100","3","3"})
	aAdd(aGrupo,{"C-13","101","120","3","3"})
	aAdd(aGrupo,{"C-13","121","140","3","3"})
	aAdd(aGrupo,{"C-13","141","300","4","3"})
	aAdd(aGrupo,{"C-13","301","500","5","4"})
	aAdd(aGrupo,{"C-13","501","1000","6","5"})
	aAdd(aGrupo,{"C-13","1001","2500","9","7"})
	aAdd(aGrupo,{"C-13","2501","5000","11","8"})
	aAdd(aGrupo,{"C-13","5001","10000","13","10"})
	aAdd(aGrupo,{"C-13","10001","","2","2"})

	aAdd(aGrupo,{"C-14","0","19","",""})
	aAdd(aGrupo,{"C-14","20","29","1","1"})
	aAdd(aGrupo,{"C-14","30","50","1","1"})
	aAdd(aGrupo,{"C-14","51","80","2","2"})
	aAdd(aGrupo,{"C-14","81","100","2","2"})
	aAdd(aGrupo,{"C-14","101","120","3","3"})
	aAdd(aGrupo,{"C-14","121","140","4","3"})
	aAdd(aGrupo,{"C-14","141","300","4","4"})
	aAdd(aGrupo,{"C-14","301","500","5","4"})
	aAdd(aGrupo,{"C-14","501","1000","6","5"})
	aAdd(aGrupo,{"C-14","1001","2500","9","7"})
	aAdd(aGrupo,{"C-14","2501","5000","11","9"})
	aAdd(aGrupo,{"C-14","5001","10000","11","9"})
	aAdd(aGrupo,{"C-14","10001","","2","2"})

	aAdd(aGrupo,{"C-14a","0","19","",""})
	aAdd(aGrupo,{"C-14a","20","29","",""})
	aAdd(aGrupo,{"C-14a","30","50","",""})
	aAdd(aGrupo,{"C-14a","51","80","1","1"})
	aAdd(aGrupo,{"C-14a","81","100","1","1"})
	aAdd(aGrupo,{"C-14a","101","120","2","2"})
	aAdd(aGrupo,{"C-14a","121","140","2","2"})
	aAdd(aGrupo,{"C-14a","141","300","2","2"})
	aAdd(aGrupo,{"C-14a","301","500","3","3"})
	aAdd(aGrupo,{"C-14a","501","1000","3","3"})
	aAdd(aGrupo,{"C-14a","1001","2500","4","3"})
	aAdd(aGrupo,{"C-14a","2501","5000","5","4"})
	aAdd(aGrupo,{"C-14a","5001","10000","6","4"})
	aAdd(aGrupo,{"C-14a","10001","","1","1"})

	aAdd(aGrupo,{"C-15","0","19","",""})
	aAdd(aGrupo,{"C-15","20","29","1","1"})
	aAdd(aGrupo,{"C-15","30","50","1","1"})
	aAdd(aGrupo,{"C-15","51","80","3","3"})
	aAdd(aGrupo,{"C-15","81","100","3","3"})
	aAdd(aGrupo,{"C-15","101","120","4","3"})
	aAdd(aGrupo,{"C-15","121","140","4","3"})
	aAdd(aGrupo,{"C-15","141","300","4","3"})
	aAdd(aGrupo,{"C-15","301","500","5","4"})
	aAdd(aGrupo,{"C-15","501","1000","6","4"})
	aAdd(aGrupo,{"C-15","1001","2500","8","6"})
	aAdd(aGrupo,{"C-15","2501","5000","10","8"})
	aAdd(aGrupo,{"C-15","5001","10000","12","10"})
	aAdd(aGrupo,{"C-15","10001","","2","2"})

	aAdd(aGrupo,{"C-16","0","19","",""})
	aAdd(aGrupo,{"C-16","20","29","1","1"})
	aAdd(aGrupo,{"C-16","30","50","1","1"})
	aAdd(aGrupo,{"C-16","51","80","2","2"})
	aAdd(aGrupo,{"C-16","81","100","3","3"})
	aAdd(aGrupo,{"C-16","101","120","3","3"})
	aAdd(aGrupo,{"C-16","121","140","3","3"})
	aAdd(aGrupo,{"C-16","141","300","4","3"})
	aAdd(aGrupo,{"C-16","301","500","5","4"})
	aAdd(aGrupo,{"C-16","501","1000","6","4"})
	aAdd(aGrupo,{"C-16","1001","2500","8","6"})
	aAdd(aGrupo,{"C-16","2501","5000","10","7"})
	aAdd(aGrupo,{"C-16","5001","10000","12","9"})
	aAdd(aGrupo,{"C-16","10001","","2","2"})

	aAdd(aGrupo,{"C-17","0","19","",""})
	aAdd(aGrupo,{"C-17","20","29","1","1"})
	aAdd(aGrupo,{"C-17","30","50","1","1"})
	aAdd(aGrupo,{"C-17","51","80","2","2"})
	aAdd(aGrupo,{"C-17","81","100","2","2"})
	aAdd(aGrupo,{"C-17","101","120","4","3"})
	aAdd(aGrupo,{"C-17","121","140","4","3"})
	aAdd(aGrupo,{"C-17","141","300","4","3"})
	aAdd(aGrupo,{"C-17","301","500","4","4"})
	aAdd(aGrupo,{"C-17","501","1000","6","5"})
	aAdd(aGrupo,{"C-17","1001","2500","8","7"})
	aAdd(aGrupo,{"C-17","2501","5000","10","8"})
	aAdd(aGrupo,{"C-17","5001","10000","12","10"})
	aAdd(aGrupo,{"C-17","10001","","2","2"})

	aAdd(aGrupo,{"C-18","0","19","",""})
	aAdd(aGrupo,{"C-18","20","29","",""})
	aAdd(aGrupo,{"C-18","30","50","",""})
	aAdd(aGrupo,{"C-18","51","80","2","2"})
	aAdd(aGrupo,{"C-18","81","100","2","2"})
	aAdd(aGrupo,{"C-18","101","120","4","3"})
	aAdd(aGrupo,{"C-18","121","140","4","3"})
	aAdd(aGrupo,{"C-18","141","300","4","3"})
	aAdd(aGrupo,{"C-18","301","500","4","4"})
	aAdd(aGrupo,{"C-18","501","1000","6","5"})
	aAdd(aGrupo,{"C-18","1001","2500","8","7"})
	aAdd(aGrupo,{"C-18","2501","5000","10","8"})
	aAdd(aGrupo,{"C-18","5001","10000","12","10"})
	aAdd(aGrupo,{"C-18","10001","","2","2"})

	aAdd(aGrupo,{"C-18a","0","19","",""})
	aAdd(aGrupo,{"C-18a","20","29","",""})
	aAdd(aGrupo,{"C-18a","30","50","",""})
	aAdd(aGrupo,{"C-18a","51","80","3","3"})
	aAdd(aGrupo,{"C-18a","81","100","3","3"})
	aAdd(aGrupo,{"C-18a","101","120","4","3"})
	aAdd(aGrupo,{"C-18a","121","140","4","3"})
	aAdd(aGrupo,{"C-18a","141","300","4","3"})
	aAdd(aGrupo,{"C-18a","301","500","4","4"})
	aAdd(aGrupo,{"C-18a","501","1000","6","5"})
	aAdd(aGrupo,{"C-18a","1001","2500","9","7"})
	aAdd(aGrupo,{"C-18a","2501","5000","12","9"})
	aAdd(aGrupo,{"C-18a","5001","10000","15","12"})
	aAdd(aGrupo,{"C-18a","10001","","2","2"})

	aAdd(aGrupo,{"C-19","0","19","",""})
	aAdd(aGrupo,{"C-19","20","29","",""})
	aAdd(aGrupo,{"C-19","30","50","",""})
	aAdd(aGrupo,{"C-19","51","80","1","1"})
	aAdd(aGrupo,{"C-19","81","100","1","1"})
	aAdd(aGrupo,{"C-19","101","120","2","2"})
	aAdd(aGrupo,{"C-19","121","140","2","2"})
	aAdd(aGrupo,{"C-19","141","300","2","2"})
	aAdd(aGrupo,{"C-19","301","500","3","3"})
	aAdd(aGrupo,{"C-19","501","1000","3","3"})
	aAdd(aGrupo,{"C-19","1001","2500","4","3"})
	aAdd(aGrupo,{"C-19","2501","5000","5","4"})
	aAdd(aGrupo,{"C-19","5001","10000","6","4"})
	aAdd(aGrupo,{"C-19","10001","","1","1"})

	aAdd(aGrupo,{"C-20","0","19","",""})
	aAdd(aGrupo,{"C-20","20","29","",""})
	aAdd(aGrupo,{"C-20","30","50","1","1"})
	aAdd(aGrupo,{"C-20","51","80","1","1"})
	aAdd(aGrupo,{"C-20","81","100","3","3"})
	aAdd(aGrupo,{"C-20","101","120","3","3"})
	aAdd(aGrupo,{"C-20","121","140","3","3"})
	aAdd(aGrupo,{"C-20","141","300","3","3"})
	aAdd(aGrupo,{"C-20","301","500","4","3"})
	aAdd(aGrupo,{"C-20","501","1000","5","4"})
	aAdd(aGrupo,{"C-20","1001","2500","5","4"})
	aAdd(aGrupo,{"C-20","2501","5000","6","5"})
	aAdd(aGrupo,{"C-20","5001","10000","8","6"})
	aAdd(aGrupo,{"C-20","10001","","2","1"})

	aAdd(aGrupo,{"C-21","0","19","",""})
	aAdd(aGrupo,{"C-21","20","29","",""})
	aAdd(aGrupo,{"C-21","30","50","",""})
	aAdd(aGrupo,{"C-21","51","80","1","1"})
	aAdd(aGrupo,{"C-21","81","100","1","1"})
	aAdd(aGrupo,{"C-21","101","120","2","2"})
	aAdd(aGrupo,{"C-21","121","140","2","2"})
	aAdd(aGrupo,{"C-21","141","300","2","2"})
	aAdd(aGrupo,{"C-21","301","500","3","3"})
	aAdd(aGrupo,{"C-21","501","1000","3","3"})
	aAdd(aGrupo,{"C-21","1001","2500","4","3"})
	aAdd(aGrupo,{"C-21","2501","5000","5","4"})
	aAdd(aGrupo,{"C-21","5001","10000","6","5"})
	aAdd(aGrupo,{"C-21","10001","","1","1"})

	aAdd(aGrupo,{"C-22","0","19","",""})
	aAdd(aGrupo,{"C-22","20","29","1","1"})
	aAdd(aGrupo,{"C-22","30","50","1","1"})
	aAdd(aGrupo,{"C-22","51","80","2","2"})
	aAdd(aGrupo,{"C-22","81","100","2","2"})
	aAdd(aGrupo,{"C-22","101","120","3","3"})
	aAdd(aGrupo,{"C-22","121","140","3","3"})
	aAdd(aGrupo,{"C-22","141","300","4","3"})
	aAdd(aGrupo,{"C-22","301","500","4","3"})
	aAdd(aGrupo,{"C-22","501","1000","6","5"})
	aAdd(aGrupo,{"C-22","1001","2500","8","6"})
	aAdd(aGrupo,{"C-22","2501","5000","10","8"})
	aAdd(aGrupo,{"C-22","5001","10000","12","9"})
	aAdd(aGrupo,{"C-22","10001","","2","2"})

	aAdd(aGrupo,{"C-23","0","19","",""})
	aAdd(aGrupo,{"C-23","20","29","",""})
	aAdd(aGrupo,{"C-23","30","50","",""})
	aAdd(aGrupo,{"C-23","51","80","1","1"})
	aAdd(aGrupo,{"C-23","81","100","1","1"})
	aAdd(aGrupo,{"C-23","101","120","2","2"})
	aAdd(aGrupo,{"C-23","121","140","2","2"})
	aAdd(aGrupo,{"C-23","141","300","2","2"})
	aAdd(aGrupo,{"C-23","301","500","2","2"})
	aAdd(aGrupo,{"C-23","501","1000","3","3"})
	aAdd(aGrupo,{"C-23","1001","2500","4","3"})
	aAdd(aGrupo,{"C-23","2501","5000","5","4"})
	aAdd(aGrupo,{"C-23","5001","10000","6","5"})
	aAdd(aGrupo,{"C-23","10001","","1","1"})

	aAdd(aGrupo,{"C-24","0","19","",""})
	aAdd(aGrupo,{"C-24","20","29","1","1"})
	aAdd(aGrupo,{"C-24","30","50","1","1"})
	aAdd(aGrupo,{"C-24","51","80","2","2"})
	aAdd(aGrupo,{"C-24","81","100","2","2"})
	aAdd(aGrupo,{"C-24","101","120","4","3"})
	aAdd(aGrupo,{"C-24","121","140","4","3"})
	aAdd(aGrupo,{"C-24","141","300","4","4"})
	aAdd(aGrupo,{"C-24","301","500","4","4"})
	aAdd(aGrupo,{"C-24","501","1000","6","5"})
	aAdd(aGrupo,{"C-24","1001","2500","8","7"})
	aAdd(aGrupo,{"C-24","2501","5000","10","8"})
	aAdd(aGrupo,{"C-24","5001","10000","12","10"})
	aAdd(aGrupo,{"C-24","10001","","2","2"})

	aAdd(aGrupo,{"C-24a","0","19","",""})
	aAdd(aGrupo,{"C-24a","20","29","",""})
	aAdd(aGrupo,{"C-24a","30","50","",""})
	aAdd(aGrupo,{"C-24a","51","80","1","1"})
	aAdd(aGrupo,{"C-24a","81","100","1","1"})
	aAdd(aGrupo,{"C-24a","101","120","2","2"})
	aAdd(aGrupo,{"C-24a","121","140","2","2"})
	aAdd(aGrupo,{"C-24a","141","300","2","2"})
	aAdd(aGrupo,{"C-24a","301","500","2","2"})
	aAdd(aGrupo,{"C-24a","501","1000","3","3"})
	aAdd(aGrupo,{"C-24a","1001","2500","4","3"})
	aAdd(aGrupo,{"C-24a","2501","5000","5","4"})
	aAdd(aGrupo,{"C-24a","5001","10000","6","4"})
	aAdd(aGrupo,{"C-24a","10001","","1","1"})

	aAdd(aGrupo,{"C-24b","0","19","",""})
	aAdd(aGrupo,{"C-24b","20","29","1","1"})
	aAdd(aGrupo,{"C-24b","30","50","1","1"})
	aAdd(aGrupo,{"C-24b","51","80","3","3"})
	aAdd(aGrupo,{"C-24b","81","100","3","3"})
	aAdd(aGrupo,{"C-24b","101","120","4","3"})
	aAdd(aGrupo,{"C-24b","121","140","4","3"})
	aAdd(aGrupo,{"C-24b","141","300","4","3"})
	aAdd(aGrupo,{"C-24b","301","500","4","3"})
	aAdd(aGrupo,{"C-24b","501","1000","6","4"})
	aAdd(aGrupo,{"C-24b","1001","2500","9","7"})
	aAdd(aGrupo,{"C-24b","2501","5000","12","9"})
	aAdd(aGrupo,{"C-24b","5001","10000","15","12"})
	aAdd(aGrupo,{"C-24b","10001","","2","2"})

	aAdd(aGrupo,{"C-26","0","19","",""})
	aAdd(aGrupo,{"C-26","20","29","",""})
	aAdd(aGrupo,{"C-26","30","50","",""})
	aAdd(aGrupo,{"C-26","51","80","",""})
	aAdd(aGrupo,{"C-26","81","100","",""})
	aAdd(aGrupo,{"C-26","101","120","",""})
	aAdd(aGrupo,{"C-26","121","140","",""})
	aAdd(aGrupo,{"C-26","141","300","",""})
	aAdd(aGrupo,{"C-26","301","500","1","1"})
	aAdd(aGrupo,{"C-26","501","1000","2","2"})
	aAdd(aGrupo,{"C-26","1001","2500","3","3"})
	aAdd(aGrupo,{"C-26","2501","5000","4","3"})
	aAdd(aGrupo,{"C-26","5001","10000","5","4"})
	aAdd(aGrupo,{"C-26","10001","","1","1"})

	aAdd(aGrupo,{"C-27","0","19","",""})
	aAdd(aGrupo,{"C-27","20","29","",""})
	aAdd(aGrupo,{"C-27","30","50","",""})
	aAdd(aGrupo,{"C-27","51","80","",""})
	aAdd(aGrupo,{"C-27","81","100","",""})
	aAdd(aGrupo,{"C-27","101","120","1","1"})
	aAdd(aGrupo,{"C-27","121","140","1","1"})
	aAdd(aGrupo,{"C-27","141","300","2","2"})
	aAdd(aGrupo,{"C-27","301","500","3","3"})
	aAdd(aGrupo,{"C-27","501","1000","4","3"})
	aAdd(aGrupo,{"C-27","1001","2500","5","4"})
	aAdd(aGrupo,{"C-27","2501","5000","6","5"})
	aAdd(aGrupo,{"C-27","5001","10000","6","5"})
	aAdd(aGrupo,{"C-27","10001","","1","1"})

	aAdd(aGrupo,{"C-28","0","19","",""})
	aAdd(aGrupo,{"C-28","20","29","",""})
	aAdd(aGrupo,{"C-28","30","50","",""})
	aAdd(aGrupo,{"C-28","51","80","",""})
	aAdd(aGrupo,{"C-28","81","100","",""})
	aAdd(aGrupo,{"C-28","101","120","1","1"})
	aAdd(aGrupo,{"C-28","121","140","1","1"})
	aAdd(aGrupo,{"C-28","141","300","2","2"})
	aAdd(aGrupo,{"C-28","301","500","3","3"})
	aAdd(aGrupo,{"C-28","501","1000","4","4"})
	aAdd(aGrupo,{"C-28","1001","2500","5","5"})
	aAdd(aGrupo,{"C-28","2501","5000","6","5"})
	aAdd(aGrupo,{"C-28","5001","10000","6","5"})
	aAdd(aGrupo,{"C-28","10001","","1","1"})

	aAdd(aGrupo,{"C-29","0","19","",""})
	aAdd(aGrupo,{"C-29","20","29","",""})
	aAdd(aGrupo,{"C-29","30","50","",""})
	aAdd(aGrupo,{"C-29","51","80","",""})
	aAdd(aGrupo,{"C-29","81","100","",""})
	aAdd(aGrupo,{"C-29","101","120","",""})
	aAdd(aGrupo,{"C-29","121","140","",""})
	aAdd(aGrupo,{"C-29","141","300","",""})
	aAdd(aGrupo,{"C-29","301","500","1","1"})
	aAdd(aGrupo,{"C-29","501","1000","2","2"})
	aAdd(aGrupo,{"C-29","1001","2500","3","3"})
	aAdd(aGrupo,{"C-29","2501","5000","4","3"})
	aAdd(aGrupo,{"C-29","5001","10000","5","4"})
	aAdd(aGrupo,{"C-29","10001","","1","1"})

	aAdd(aGrupo,{"C-30","0","19","",""})
	aAdd(aGrupo,{"C-30","20","29","1","1"})
	aAdd(aGrupo,{"C-30","30","50","1","1"})
	aAdd(aGrupo,{"C-30","51","80","1","1"})
	aAdd(aGrupo,{"C-30","81","100","2","2"})
	aAdd(aGrupo,{"C-30","101","120","4","3"})
	aAdd(aGrupo,{"C-30","121","140","4","3"})
	aAdd(aGrupo,{"C-30","141","300","4","4"})
	aAdd(aGrupo,{"C-30","301","500","5","4"})
	aAdd(aGrupo,{"C-30","501","1000","7","6"})
	aAdd(aGrupo,{"C-30","1001","2500","8","7"})
	aAdd(aGrupo,{"C-30","2501","5000","9","8"})
	aAdd(aGrupo,{"C-30","5001","10000","10","9"})
	aAdd(aGrupo,{"C-30","10001","","2","1"})

	aAdd(aGrupo,{"C-31","0","19","",""})
	aAdd(aGrupo,{"C-31","20","29","",""})
	aAdd(aGrupo,{"C-31","30","50","",""})
	aAdd(aGrupo,{"C-31","51","80","1","1"})
	aAdd(aGrupo,{"C-31","81","100","1","1"})
	aAdd(aGrupo,{"C-31","101","120","2","2"})
	aAdd(aGrupo,{"C-31","121","140","2","2"})
	aAdd(aGrupo,{"C-31","141","300","2","2"})
	aAdd(aGrupo,{"C-31","301","500","3","3"})
	aAdd(aGrupo,{"C-31","501","1000","3","3"})
	aAdd(aGrupo,{"C-31","1001","2500","4","3"})
	aAdd(aGrupo,{"C-31","2501","5000","5","4"})
	aAdd(aGrupo,{"C-31","5001","10000","6","5"})
	aAdd(aGrupo,{"C-31","10001","","1","1"})

	aAdd(aGrupo,{"C-32","0","19","",""})
	aAdd(aGrupo,{"C-32","20","29","",""})
	aAdd(aGrupo,{"C-32","30","50","",""})
	aAdd(aGrupo,{"C-32","51","80","1","1"})
	aAdd(aGrupo,{"C-32","81","100","1","1"})
	aAdd(aGrupo,{"C-32","101","120","2","2"})
	aAdd(aGrupo,{"C-32","121","140","2","2"})
	aAdd(aGrupo,{"C-32","141","300","2","2"})
	aAdd(aGrupo,{"C-32","301","500","3","3"})
	aAdd(aGrupo,{"C-32","501","1000","3","3"})
	aAdd(aGrupo,{"C-32","1001","2500","4","3"})
	aAdd(aGrupo,{"C-32","2501","5000","5","4"})
	aAdd(aGrupo,{"C-32","5001","10000","6","5"})
	aAdd(aGrupo,{"C-32","10001","","1","1"})

	aAdd(aGrupo,{"C-33","0","19","",""})
	aAdd(aGrupo,{"C-33","20","29","",""})
	aAdd(aGrupo,{"C-33","30","50","",""})
	aAdd(aGrupo,{"C-33","51","80","",""})
	aAdd(aGrupo,{"C-33","81","100","",""})
	aAdd(aGrupo,{"C-33","101","120","1","1"})
	aAdd(aGrupo,{"C-33","121","140","1","1"})
	aAdd(aGrupo,{"C-33","141","300","1","1"})
	aAdd(aGrupo,{"C-33","301","500","1","1"})
	aAdd(aGrupo,{"C-33","501","1000","2","2"})
	aAdd(aGrupo,{"C-33","1001","2500","3","3"})
	aAdd(aGrupo,{"C-33","2501","5000","4","3"})
	aAdd(aGrupo,{"C-33","5001","10000","5","4"})
	aAdd(aGrupo,{"C-33","10001","","1","1"})

	aAdd(aGrupo,{"C-34","0","19","",""})
	aAdd(aGrupo,{"C-34","20","29","1","1"})
	aAdd(aGrupo,{"C-34","30","50","1","1"})
	aAdd(aGrupo,{"C-34","51","80","2","2"})
	aAdd(aGrupo,{"C-34","81","100","2","2"})
	aAdd(aGrupo,{"C-34","101","120","4","3"})
	aAdd(aGrupo,{"C-34","121","140","4","3"})
	aAdd(aGrupo,{"C-34","141","300","4","3"})
	aAdd(aGrupo,{"C-34","301","500","4","4"})
	aAdd(aGrupo,{"C-34","501","1000","6","5"})
	aAdd(aGrupo,{"C-34","1001","2500","8","7"})
	aAdd(aGrupo,{"C-34","2501","5000","10","8"})
	aAdd(aGrupo,{"C-34","5001","10000","12","9"})
	aAdd(aGrupo,{"C-34","10001","","2","2"})

	aAdd(aGrupo,{"C-35","0","19","",""})
	aAdd(aGrupo,{"C-35","20","29","",""})
	aAdd(aGrupo,{"C-35","30","50","",""})
	aAdd(aGrupo,{"C-35","51","80","1","1"})
	aAdd(aGrupo,{"C-35","81","100","1","1"})
	aAdd(aGrupo,{"C-35","101","120","2","2"})
	aAdd(aGrupo,{"C-35","121","140","2","2"})
	aAdd(aGrupo,{"C-35","141","300","2","2"})
	aAdd(aGrupo,{"C-35","301","500","2","2"})
	aAdd(aGrupo,{"C-35","501","1000","3","3"})
	aAdd(aGrupo,{"C-35","1001","2500","4","3"})
	aAdd(aGrupo,{"C-35","2501","5000","5","4"})
	aAdd(aGrupo,{"C-35","5001","10000","6","5"})
	aAdd(aGrupo,{"C-35","10001","","1","1"})

Return aGrupo

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT645ESTB
Ajusta a data de estabilidade aos campos RA_DTVTEST e TNO_DTESTB referente a CIPA

@return	Nil, Nulo

@param	nOpcx, Numérico, Operação que está sendo realizada

@sample	MDT645ESTB( 3 )

@author	Luis Fellipy Bett
@since	10/06/2021
/*/
//-------------------------------------------------------------------
Function MDT645ESTB( nOpcx, cMandato, cFilCand, cCandidato, lPerdEstab, dDtEstbOld, cJustifOld, cIndicaOld )

	Local lAltDtEstb := .F.
	Local lAltJustif := .F.
	Local lAltIndica := .F.
	Local dDataEstb	 := SToD( "" )

	//Caso for alteração
	If nOpcx == 4
		//Verifica alteração do campo TNO_INDICA
		lAltIndica := TNO->TNO_INDICA <> cIndicaOld

		//Verificação de alteração dos campos de perda de estabilidade
		If lPerdEstab
			lAltDtEstb := TNO->TNO_DTESTB <> dDtEstbOld
			lAltJustif := TNO->TNO_JUSTIF <> cJustifOld
		EndIf
	EndIf

	If nOpcx == 3 .Or. nOpcx == 5 .Or. ( nOpcx == 4 .And. lAltDtEstb .Or. lAltIndica )
		dDataEstb := MDT645SRA( nOpcx, cMandato, cCandidato, cFilCand, lPerdEstab, lAltDtEstb ) //Cadastra o campo RA_DTVTEST
	EndIf

	//Caso o sistema esteja preparado com os campos de perda da estabilidade
	If lPerdEstab

		//Ajusta a estabilidade da TNO
		If ( nOpcx == 3 .Or. nOpcx == 4 ) .And. !Empty( dDataEstb ) .And. !lAltDtEstb
			MDT645TNO( cMandato, cCandidato, dDataEstb )
		EndIf

		//Pega a data e o usuário que alterou os campos TNO_DTESTB e/ou TNO_JUSTIF
		If lAltDtEstb .Or. lAltJustif
			MDT645USU()
		EndIf

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT645SRA
Ajusta o campo RA_DTVTEST com a data de estabilidade do candidato referente a CIPA

@return	SRA->RA_DTVTEST, Data, Data de estabilidade a ser considerada no campo RA_DTVTEST

@param	nOpcx, Numérico, Operação que está sendo realizada
@param	cMandato, Caracter, Mandato da CIPA
@param	cCandidato, Caracter, Candidato da CIPA
@param	cFilCand, Caracter, Filial do candidato
@param	lPerdEstab, Boolean, Indica se o dicionário está atualizado com os campos da perda da estabilidade
@param	lAltDtEstb, Boolean, Indica se teve alteração manual na data de estabilidade da TNO

@sample	MDT645SRA( 2, "2021 ", "100000", "D MG 01 ", .T. )

@author	Luis Fellipy Bett
@since	07/06/2021
/*/
//-------------------------------------------------------------------
Function MDT645SRA( nOpcx, cMandato, cCandidato, cFilCand, lPerdEstab, lAltDtEstb )

	Local lCipatr	 := SuperGetMv( "MV_NG2NR31", .F., "2" ) == "1"
	Local dDtEleicao := SToD( "" )
	Local dDtEstAtu	 := SToD( "" )
	Local dDtEstNov	 := SToD( "" )
	Local dDtVerMsg	 := SToD( "" )
	Local lEntra	 := .F.

	Default lPerdEstab := .F.
	Default lAltDtEstb := .F.

	//Caso teve alteração manual na data de estabilidade
	If lPerdEstab .And. lAltDtEstb .Or. nOpcx == 5
		dDtEstNov := MDT660GTDT( cCandidato ) //Busca a data de estabilidade vigente da SR8
	EndIf

	dbselectarea( "TNN" )
	dbSetOrder( 1 )
	If dbseek( xFilial( "TNN" ) + cMandato )
		dDtEleicao := TNN->TNN_ELEICA
	EndIf

	//Caso exista uma data definida para a eleição do mandato
	If !Empty( dDtEleicao )

		//Define a data atual de estabilidade como sendo a data de eleição
		dDtEstAtu := dDtEleicao

		//Adiciona a data para verificar se dispara o help
		dDtVerMsg := dDtEstAtu

		//------------------------------------------------------------------------------
		// Colocar essa validação no pós valid do cadastro de candidato e de componente
		//------------------------------------------------------------------------------
		dbSelectArea( "TNQ" )
		dbSetOrder( 2 )
		If dbSeek( xFilial( "TNQ" ) + cCandidato + cMandato )
			If !Empty( TNO->TNO_INDICA ) .And. !Empty( TNQ->TNQ_INDICA ) .And. TNO->TNO_INDICA <> TNQ->TNQ_INDICA
				If MsgYesNo( IIf( lCipatr, STR0059, ; //"Este funcionário é um componente da CIPATR e está com a indicação diferente. Deseja alterar a sua indicação da CIPATR ?"
										STR0054 ) ) //"Este funcionário é um componente da CIPA e está com a indicação diferente. Deseja alterar a sua indicação da CIPA ?"
					RecLock( "TNQ", .F. )
						TNQ->TNQ_INDICA := TNO->TNO_INDICA
					MsUnlock( "TNQ" )

					//Caso for inclusão ou alteração
					If nOpcx == 3 .Or. nOpcx == 4

						If lCipatr
							dDtEstAtu := NGSomaAno( TNN->TNN_DTTERM, 2 ) //Adiciona dois anos de estabilidade
						Else
							dDtEstAtu := NGSomaAno( TNN->TNN_DTTERM, 1 ) //Adiciona um ano de estabilidade
						EndIf

					ElseIf nOpcx == 5

						dDtEstAtu := SRA->RA_DTVTEST

					EndIf
				EndIf
			EndIf
		EndIf

		dbselectarea( "SRA" )
		dbSetOrder( 1 )
		If dbseek( xFilial( "SRA", cFilCand ) + cCandidato )

			//Caso for inclusão ou alteração
			If nOpcx == 3 .Or. nOpcx == 4

				//Caso for alteração manual da data de estabilidade
				If lAltDtEstb
					//Caso não tenha uma data a ser considerada da SR8 ou a data da SR8 for menor que a data inputada manualmente
					If Empty( dDtEstNov ) .Or. dDtEstNov < TNO->TNO_DTESTB
						dDtEstAtu := TNO->TNO_DTESTB
					Else
						dDtEstAtu := dDtEstNov
					EndIf

					lEntra := .T.
				Else
					If !Empty( dDtEstNov ) //Caso for alteração da data de estabilidade, pega a nova data da SR8
						dDtEstAtu := dDtEstNov
					EndIf
				EndIf

				If TNO->TNO_INDICA == "2" .And. ( ( Empty( SRA->RA_DTVTEST ) .Or. SRA->RA_DTVTEST < dDtEstAtu ) .Or. lEntra )

					RecLock( "SRA", .F. )
					SRA->RA_DTVTEST := dDtEstAtu
					SRA->( MsUnlock() )

					If dDtVerMsg == dDtEstAtu
						MsgInfo( STR0011 + DToC( dDtEstAtu ) + "!" ) //"A partir deste momento o Candidato para CIPA terá estabilidade até XX/XX/XXXX!"
					EndIf

					fAddEstRFX( nOpcx, cMandato, cFilCand, cCandidato, dDtEstAtu, dDtEstNov )
				EndIf

			ElseIf nOpcx == 5 //Caso for exclusão

				If SRA->RA_DTVTEST == dDtEstAtu .Or. SRA->RA_DTVTEST == TNO->TNO_DTESTB

					RecLock( "SRA", .F. )

					If !Empty( dDtEstNov )
						SRA->RA_DTVTEST := dDtEstNov
					Else
						SRA->RA_DTVTEST := SToD( "" )
					EndIf

					SRA->( MsUnlock() )

					MsgInfo( STR0068 ) //"A partir deste momento o candidato deixa de ter estabilidade referente a CIPA!"

					fAddEstRFX( nOpcx, cMandato, cFilCand, cCandidato, dDtEstAtu, dDtEstNov, TNO->TNO_DTCAND )
				EndIf

			EndIf
		EndIf
	Else
		If nOpcx == 3 .Or. nOpcx == 4
			Help( ' ', 1, STR0061, , STR0069, 2, 0 ) //"O mandato não possui data de eleição, por isso não foi adicionada estabilidade ao candidato"
		EndIf
	EndIf

Return SRA->RA_DTVTEST

//-------------------------------------------------------------------
/*/{Protheus.doc} fAddEstRFX
Manipula as estabilidades do funcionário na tabela RFX

@return	Nil, Nulo

@param	dDataEstb, Data, Data de estabilidade inputada no campo RA_DTVTEST
@param	cMatricula, Caracter, Matricula do candidato

@sample	fAddEstRFX( 3, 01/01/2021, "100000" )

@author	Luis Fellipy Bett
@since	07/06/2021
/*/
//-------------------------------------------------------------------
Static Function fAddEstRFX( nOpcx, cMandato, cFilCand, cCandidato, dDtEstAtu, dDtEstNov, dDtCandt )

	Local lConsRFX := AliasInDic( "RFX" ) .And. FindFunction( "MDTEstFunc" ) //Variavel de consistencia da RFX
	Local dDtCand  := Posicione( "TNO", 3, xFilial( "TNO" ) + cMandato + cFilCand + cCandidato, "TNO_DTCAND" ) //Data de candidatura do funcionário
	Local dDtAux   := IIf( !Empty( dDtEstNov ), dDtEstNov, dDtEstAtu )
	Local cTiptAux := ""

	If Empty( dDtCand )
		dDtCand := dDtCandt
	EndIf

	//Caso tenha consistência em relação a RFX
	If lConsRFX

		//Caso candidatura seja superior a data de termino da estabilidade, não gera
		If !Empty( dDtCand ) .And. dDtCand <= dDtAux

			//Busca o tipo de estabilidade de acordo com o Tipo do Componente - Busca se da pelo tipo de estabilidade eSocial ( 07 - Candidato da CIPA; )
			If !Empty( cTiptAux := MDTEstFunc( 7 ) )

				dbSelectArea( "RFX" )
				dbSetOrder( 1 ) //RFX_FILIAL+RFX_MAT+DTOS(RFX_DATAI)+RFX_TPESTB

				If nOpcx == 5 //Caso for exclusão do candidato

					If dbSeek( xFilial( "RFX" ) + cCandidato + DToS( dDtCand ) + cTiptAux ) //Caso já tenha a estabilidade, altera apenas a data fim
						RecLock( "RFX", .F. )
							RFX->( dbDelete() )
						RFX->( MsUnLock() )
					EndIf


				ElseIf nOpcx == 3 .Or. nOpcx == 4 //Caso for inclusão ou alteração do candidato

					If dbSeek( xFilial( "RFX" ) + cCandidato + DToS( dDtCand ) + cTiptAux ) //Caso já tenha a estabilidade, altera apenas a data fim
						RecLock( "RFX", .F. )
					Else
						RecLock( "RFX", .T. )
					EndIf

					//Caso inclusão, salva os campos chaves
					RFX->RFX_FILIAL := xFilial( "RFX" ) //Obrigatório
					RFX->RFX_MAT := cCandidato //Obrigatório
					RFX->RFX_DATAI := dDtCand  //Obrigatório
					If RFX->( FieldPos( "RFX_HORAF" ) ) > 0
						RFX->RFX_HORAI := "00:00" //Obrigatório
					EndIf
					RFX->RFX_TPESTB := cTiptAux
					RFX->RFX_DATAF := dDtAux
					If RFX->( FieldPos( "RFX_HORAF" ) ) > 0
						RFX->RFX_HORAF := "23:59"
					EndIf
					RFX->( MsUnLock() )

				EndIf
			EndIf
		EndIf
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT645TNO
Ajusta o campo TNO_DTESTB com a data da estabilidade a ser incluída no campo RA_DTVTEST

@return	Nil, Nulo

@param	cMandato, Caracter, Mandato da CIPA
@param	cMatricula, Caracter, Matricula do candidato
@param	dDataEstb, Data, Data de estabilidade inputada no campo RA_DTVTEST

@sample	MDT645TNO( "2022", "100015", 01/03/2021 )

@author	Luis Fellipy Bett
@since	07/06/2021
/*/
//-------------------------------------------------------------------
Function MDT645TNO( cMandato, cMatricula, dDataEstb )

	//Adiciona a data de estabilidade ao campo TNO_DTESTB
	dbSelectArea( "TNO" )
	dbSetOrder( 1 )
	If dbSeek( xFilial( "TNO" ) + cMandato + cMatricula ) .And. ( Empty( TNO->TNO_DTESTB ) .Or. TNO->TNO_DTESTB < dDataEstb )
		RecLock( "TNO", .F. )
		TNO->TNO_DTESTB := dDataEstb
		TNO->( MsUnlock() )
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT645USU
Atualiza as informações de data e usuário que realizou a última
alteração da estabilidade do candidato

@return	Nil, Nulo

@sample	MDT645USU()

@author	Luis Fellipy Bett
@since	25/05/2021
/*/
//-------------------------------------------------------------------
Function MDT645USU()

	Local dDataAlt := dDataBase
	Local cUserAlt := SubStr( cUserName, 1, 40 )

	RecLock( "TNO", .F. )
		TNO->TNO_DTALT := dDataAlt
		TNO->TNO_USUARI := cUserAlt
	TNO->( MsUnlock() )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTTNOWHEN
X3_WHEN dos campos TNO_DTESTB e TNO_JUSTIF

@return	lRet, Boolean, Indica se o campo estará fechado ou aberto

@param	nCampo, Numérico, Indica o campo a ser validado

@sample	MDTTNOWHEN( 1 )

@author	Luis Fellipy Bett
@since	24/05/2021
/*/
//-------------------------------------------------------------------
Function MDTTNOWHEN( nCampo )

	Local lRet := .F.
	Local lIntegra := SuperGetMv( "MV_MDTGPE", .F., "N" ) == "S"

	//Caso for alteração, exista integração com o GPE, o campo de justificativa estiver vazio
	If ALTERA .And. lIntegra .And. TNO->TNO_INDICA == "2"
		If nCampo == 2 //Caso for When do campo de justificativa
			lRet := TNO->TNO_DTESTB <> M->TNO_DTESTB .Or. !Empty( TNO->TNO_JUSTIF )
		Else
			lRet := .T.
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTTNOVALID
X3_VALID dos campos TNO_DTESTB e TNO_JUSTIF

@return	lRet, Boolean, Indica se o campo está consistente ou não

@param	nCampo, Numérico, Indica o campo a ser validado

@sample	MDTTNOVALID( 1 )

@author	Luis Fellipy Bett
@since	24/05/2021
/*/
//-------------------------------------------------------------------
Function MDTTNOVALID( nCampo )

	Local lRet := .T.

	If nCampo == 1 //Caso for validação do campo TNO_DTESTB
		If !Empty( TNO->TNO_DTESTB ) .And. Empty( M->TNO_DTESTB )
			Help( ' ', 1, STR0061, , STR0062, 2, 0, , , , , , { STR0063 } ) //"Já existe uma data fim de estabilidade, a data não pode ser excluída"##"Favor selecionar uma data para o fim da estabilidade"
			lRet := .F.
		ElseIf M->TNO_DTESTB > TNO->TNO_DTESTB
			Help( ' ', 1, STR0061, , STR0064, 2, 0, , , , , , { STR0065 } ) //"A data fim da estabilidade do funcionário não pode ser maior que a data já preenchida"##"Favor selecionar uma data igual ou anterior a data definida"
			lRet := .F.
		EndIf
	ElseIf nCampo == 2 .And. Altera //Caso for validação do campo TNO_JUSTIF e for alteração
		If ( TNO->TNO_DTESTB <> M->TNO_DTESTB .Or. !Empty( TNO->TNO_JUSTIF ) ) .And. Empty( M->TNO_JUSTIF )
			Help( ' ', 1, STR0061, , STR0066, 2, 0, , , , , , { STR0067 } ) //"O campo de justificativa não pode ficar em branco"##"Favor preencher um conteúdo no campo"
			lRet := .F.
		EndIf
	EndIf

Return lRet
