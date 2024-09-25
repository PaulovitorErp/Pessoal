#include "Mdta665.ch"
#include "Protheus.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA665
Agenda de Reuniões da CIPA.

@type function

@sample MDTA665()

@return Lógico, Sempre Verdadeiro

@author Thiago Olis Machado
@since 03/05/2001
/*/
//---------------------------------------------------------------------
Function MDTA665

	Local lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .T. , .F. )
	Local lCipatr 	 := If( SuperGetMv("MV_NG2NR31",.F.,"2") == "1", .T. , .F. )
	Local aNGBEGINPRM := NGBEGINPRM() // Armazena variaveis p/ devolucao (NGRIGHTCLICK)

	Private lUPDMDT89 := .F.
	Private cCLIMDTPS,aNgButton:={}
	Private aRotina    := MenuDef()

	lUPDMDT89 := NGCADICBASE("TNS_TIPPAR","D","TNS",.F.) //Verifica se o UPDATE UPDMDT89 foi executado.
	Aadd(aNgButton,{"responsa" ,{|| MDT665PA()},STR0040,STR0041})  //"Adicionar participantes para reunião"//"Adicionar"
	Aadd(aNgButton,{"particip" ,{|| fAddPartic()},STR0048,STR0049})//"Adicionar todos participantes do mandato."##"Todos Partic."

	If lSigaMdtps

		Private cCadastro := OemtoAnsi(STR0009)  //"Clientes"

		dbSelectArea("SA1")
		dbSetOrder(1)
		mBrowse( 6, 1,22,75,"SA1")
	Else

		// Define o cabecalho da tela de atualizacoes
		Private aCHKDEL := {}, bNGGRAVA := {|| MDT665GRAV()}

		cCadastro := OemtoAnsi(If(lCipatr,STR0057,STR0007)) //"Agenda CIPATR" //"Agenda CIPA"

		// aCHKDEL array que verifica a INTEGRIDADE REFERENCIAL na exclu-
		// são do registro.
		//
		// 1 - Chave de pesquisa
		// 2 - Alias de pesquisa
		// 3 - ordem de pesquisa

		//aCHKDEL := { {'TNR->TNR_MANDAT + DTOS(TNR->TNR_DTREUN) + TNR->TNR_HRREUN'    , "TNS", 1}}

		// Endereca a funcaO de BRoWSE
		dbSelectArea("TNR")
		dbSetorder(1)
		mBrowse( 6, 1,22,75,"TNR")

	Endif

	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	NGRETURNPRM(aNGBEGINPRM)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT665GRAV
NC

@type function

@sample MDT665GRAV( 3 )

@return Lógico, Retorna se pode realizar a gravação

@param nOpcx, Numérico, Opção de Manutenção do Browse
@author Anônimo
@since 99/99/9999
/*/
//---------------------------------------------------------------------
Function MDT665GRAV(nOpcx)

	Local cOldAlias := Alias()
	Local lRet := .T.
	Local lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .T. , .F. )
	Local aWFReun := {}
	Local cEmailPart := "", cNomePar := ""
	Local lCipatr := If( SuperGetMv("MV_NG2NR31",.F.,"2") == "1", .T. , .F. )

	If nOpcx == 3

		If lSigaMdtps

			If !EXISTCHAV("TNR",cCliMdtps+M->TNR_MANDAT+DTOS(M->TNR_DTREUN)+M->TNR_HRREUN,2)
				lRet := .F.
			Else
				dbSelectArea("TNN")
				dbSetOrder(1)

				If dbSeek(xFilial("TNN")+cCliMdtps+M->TNR_MANDAT)

					If M->TNR_DTREUN < TNN->TNN_DTINIC .Or. M->TNR_DTREUN > TNN->TNN_DTTERM
						MsgInfo(STR0020 + Chr(13) + Chr(10) + ; //"A Data da Reunião não está no período do Mandato da CIPA."
								If(lCipatr,STR0058,STR0021) + DtoC(TNN->TNN_DTINIC) + STR0022 + DtoC(TNN->TNN_DTTERM) ) //"Período Mandato da CIPATR: " //"Período Mandato da CIPA: " //" a "
						lRet := .F.
					Endif

				Endif

			Endif

		Else

			If !EXISTCHAV("TNR",M->TNR_MANDAT+DTOS(M->TNR_DTREUN)+M->TNR_HRREUN,1)
				lRet := .F.
			Else
				dbSelectArea("TNN")
				dbSetOrder(1)

				If dbSeek(xFilial("TNN")+M->TNR_MANDAT)

					If M->TNR_DTREUN < TNN->TNN_DTINIC .Or. M->TNR_DTREUN > TNN->TNN_DTTERM
						MsgInfo(STR0020 + Chr(13) + Chr(10) + ; //"A Data da Reunião não está no período do Mandato da CIPA."
								If(lCipatr,STR0058,STR0021) + DtoC(TNN->TNN_DTINIC) + STR0022 + DtoC(TNN->TNN_DTTERM) ) //"Período Mandato da CIPATR: " //"Período Mandato da CIPA: " //" a "
						lRet := .F.
					Endif

				Endif

			Endif

		Endif

	EndIf

	If nOpcx == 5

		If Empty(TNR->TNR_DTREAL) .And. ( Empty(TNR->TNR_HRREAL) .Or. Alltrim(TNR->TNR_HRREAL) == ":" )
			dbSelectArea("TNS")
			dbSetOrder(1)

			If dbSeek(xFilial("TNS")+TNR->TNR_MANDAT)

				While !Eof() .And. xFilial("TNS")+TNS->TNS_MANDAT == xFilial("TNR")+TNR->TNR_MANDAT
					dbSelectArea("SRA")
					dbSetOrder(1)

					If dbSeek(xFilial("SRA")+TNS->TNS_MAT) .And. AliasInDic("PE0")

						If !Empty(SRA->RA_EMAIL)
							cEmailPart	:= SRA->RA_EMAIL
							cNomePar	:= SRA->RA_NOME
							dbSelectArea("PE0")
							dbSetOrder(3)

							If dbSeek(xFilial("PE0")+SRA->RA_CC)
								dbSelectArea("SRA")
								dbSetOrder(1)

								If dbSeek(xFilial("SRA")+PE0->PE0_RESP)
									cEmailGest := SRA->RA_EMAIL
								EndIf

							EndIf

							aAdd(aWFReun,{ TNR->TNR_DTREUN, TNR->TNR_HRREUN, TNR->TNR_DURACA, If(TNR->TNR_TIPREU=="1","1=Ordinaria","2=Extraordinaria"), TNR->TNR_ASSUNT, TNR->TNR_LOCAL, cEmailPart, cNomePar, 3, cEmailGest })
						EndIf

					EndIf

					dbSelectArea("TNS")
					RecLock("TNS",.F.)
					DbDelete()
					MsUnLock("TNS")
					dbSkip()
				End

			EndIf

		Else
			MsgStop(STR0045,STR0012) //"Essa reunião não poderá ser excluída, pois já foi realizada."##"Atenção"
			Return .F.
		EndIf

		If ExistBlock("MDTA6652")
			ExecBlock("MDTA6652",.F.,.F.,{.F.,,,aWFReun})
		EndIf

	EndIf

	If !Empty(cOldAlias)
		dbSelectArea(cOldAlias)
	Endif

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MD665PA
Programa de Cadastro de Candidatos

@type function

@sample MD665PA()

@return Lógico, Sempre Verdadeiro

@author Thiago Olis Machado
@since 03/05/2001
/*/
//---------------------------------------------------------------------
Function MD665PA()

	Local aArea		 := GetArea()
	Local lSigaMdtPS := SuperGetMv( "MV_MDTPS", .F., "N" ) == "S"
	Local cFilOld    := cFilAnt

	Private cCadastro := OemtoAnsi(STR0006) //"Participantes"
	Private aCHKDEL   := {}, bNGGRAVA
	Private bChgLiNG
	Private lCpoTNS   := .F.
	Private nIndTNS
	Private cFilA665  := cFilAnt

	cOldAlias := Alias()
	aVARNAO := {}
	aCHOICE := {}

	If lSigaMdtps

		aCHOICE := NGCAMPNSX3( "TNR", {"TNR_CLIENT", "TNR_LOJA", "TNR_FILIAL"} )

		dbSelectArea("TNS")
		dbSetOrder(3)  //TNS_FILIAL+TNS_CLIENT+TNS_LOJA+TNS_MANDAT+DTOS(TNS_DTREUN)+TNS_HRREUN+TNS_MAT
		aGETNAO := { {"TNS_MANDAT" , "M->TNR_MANDAT"},;
					{"TNS_DTREUN" , "M->TNR_DTREUN"},;
					{"TNS_HRREUN" , "M->TNR_HRREUN"},;
					{"TNS_CLIENT" , "SA1->A1_COD"  },;
					{"TNS_LOJA"   , "SA1->A1_LOJA"} }

		cGETWHILE := "TNS_FILIAL == xFilial('TNS') .And. TNS_MANDAT == M->TNR_MANDAT .And. TNS_DTREUN == M->TNR_DTREUN .And. TNS_HRREUN == M->TNR_HRREUN .And. TNS_CLIENT+TNS_LOJA == cCliMdtps"
		cGETMAKE  := "TNR->TNR_CLIENT + TNR->TNR_LOJA + TNR->TNR_MANDAT + DtoS(TNR->TNR_DTREUN) + TNR->TNR_HRREUN"
		cGETKEY   := "TNR->TNR_CLIENT + TNR->TNR_LOJA + TNR->TNR_MANDAT + DtoS(TNR->TNR_DTREUN) + TNR->TNR_HRREUN + M->TNS_MAT"
		cGETALIAS := "TNS"
		cTUDOOK   := "MDT665TOK()"
		cLINOK    := "D665CHK(.T.) .And. PutFileInEof( 'TNS' )"//"AllwaysTrue()"
		lCpoTNS := NGCADICBASE("TNS_FILMAT","A","TNS",.F.)
		nIndTNS := NGRETORDEM("TNS","TNS_FILIAL+TNS_CLIENT+TNS_LOJA+TNS_MANDAT+DTOS(TNS_DTREUN)+TNS_HRREUN+TNS_FILMAT+TNS_MAT",.T.)

		If lCpoTNS .And. nIndTNS > 0
			cGETKEY  := "TNR->TNR_CLIENT + TNR->TNR_LOJA + TNR->TNR_MANDAT + DtoS(TNR->TNR_DTREUN) + TNR->TNR_HRREUN + M->TNS_FILMAT + M->TNS_MAT"
			bChgLiNG := {|| fMDT665CHG() }

			nITP2 := NGRETORDEM("TNS","TNS_FILIAL+TNS_CLIENT+TNS_LOJA+TNS_MANDAT+DTOS(TNS_DTREUN)+TNS_HRREUN+TNS_TIPPAR+TNS_FILMAT+TNS_MAT+TNS_NOMPAR",.T.)

			If nITP2 > 0
				nIndTNS := nITP2
				cGETKEY := "TNR->TNR_CLIENT + TNR->TNR_LOJA + TNR->TNR_MANDAT + DtoS(TNR->TNR_DTREUN) + TNR->TNR_HRREUN + M->TNS_TIPPAR + M->TNS_FILMAT + M->TNS_MAT + M->TNS_NOMPAR"
			Endif

		Endif

		dbSelectArea("TNS")
		dbSetOrder(If(lCpoTNS .And. nIndTNS > 0,nIndTNS,1))

	Else

		aGETNAO := { {"TNS_MANDAT" , "M->TNR_MANDAT"},;
					{"TNS_DTREUN" , "M->TNR_DTREUN"},;
					{"TNS_HRREUN" , "M->TNR_HRREUN"}}

		cGETWHILE := "TNS_FILIAL == xFilial('TNS') .And. TNS_MANDAT == M->TNR_MANDAT .And. TNS_DTREUN == M->TNR_DTREUN .And. TNS_HRREUN == M->TNR_HRREUN"
		cGETMAKE  := "TNR->TNR_MANDAT + DtoS(TNR->TNR_DTREUN) + TNR->TNR_HRREUN"
		cGETKEY   := "TNR->TNR_MANDAT + DtoS(TNR->TNR_DTREUN) + TNR->TNR_HRREUN + M->TNS_MAT"
		cGETALIAS := "TNS"
		cTUDOOK   := "MDT665TOK()"
		cLINOK    := "D665CHK(.T.) .And. PutFileInEof( 'TNS' )"

		lCpoTNS := NGCADICBASE("TNS_FILMAT","A","TNS",.F.)
		nIndTNS := NGRETORDEM("TNS","TNS_FILIAL+TNS_MANDAT+DTOS(TNS_DTREUN)+TNS_HRREUN+TNS_FILMAT+TNS_MAT",.T.)

		If lCpoTNS .And. nIndTNS > 0
			cGETKEY  := "TNR->TNR_MANDAT + DtoS(TNR->TNR_DTREUN) + TNR->TNR_HRREUN + M->TNS_FILMAT + M->TNS_MAT"
			bChgLiNG := {|| fMDT665CHG() }
			nITP2 := NGRETORDEM("TNS","TNS_FILIAL+TNS_MANDAT+DTOS(TNS_DTREUN)+TNS_HRREUN+TNS_TIPPAR+TNS_FILMAT+TNS_MAT+TNS_NOMPAR",.T.)

			If nITP2 > 0
				nIndTNS := nITP2
				cGETKEY := "TNR->TNR_MANDAT + DtoS(TNR->TNR_DTREUN) + TNR->TNR_HRREUN + M->TNS_TIPPAR + M->TNS_FILMAT + M->TNS_MAT + M->TNS_NOMPAR"
			Endif

		Endif

		dbSelectArea("TNS")
		dbSetOrder(If(lCpoTNS .And. nIndTNS > 0,nIndTNS,1))

	Endif

	M->TNS_MANDAT := TNR->TNR_MANDAT
	nRet := NGCAD02( "TNR", Recno(), 4 )

	//Verifica se os componentes da reunião faltaram em 5 das reuniões do mandato e retira a sua estabilidade
	If nRet == 1 .And. TNQ->( ColumnPos( "TNQ_DTESTB" ) ) > 0 //Caso o dicionário esteja atualizado com os campos da perda da estabilidade
		fEstabPart()
	EndIf

	cFilAnt := cFilOld //Retorna para a filial logada
	RestArea( aArea ) //Retorna a área

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} D665CHK
Consiste a existencia de outro codigo na GetDados

@type function

@sample D665CHK()

@return Lógico, Retorna se a linha é valida ou não

@param [lChamLOK], Lógico, Indica se é chamado no TudoOk

@author Thiago Olis Machado
@since 03/05/2001
/*/
//---------------------------------------------------------------------
Function D665CHK(lChamLOK)

	Local xx := 0, npos, lRET := .T.
	Local nX, nPos1, nPos2, nPOS3, nPOS4, lNomLOK
	Local cCodMat, cNomePar
	Default lChamLOK := .F.

	nPOS  := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TNS_MAT"})
	nPOS1 := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TNS_FILMAT"})
	nPOS2 := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TNS_NOMPAR"})
	nPOS3 := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TNS_TIPPAR"})
	nPOS4 := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TNS_PRESEN"})


	cCodMat := If(lChamLOK,aCOLS[n][nPOS],M->TNS_MAT)

	If lChamLOK
		cCodMat := If(lChamLOK,aCOLS[n][nPOS],aCOLS[n][nPOS])//M->TNS_MAT)

		If lCpoTNS .And. nIndTNS > 0

			If Empty(cCodMat) .And. !lUPDMDT89
				ShowHelpDlg(STR0012,	{STR0023},2,{STR0029},1) //Título // Descrição // Lin. Descrição // Solução // Lin. Solução ##"Campo obrigatório não preenchido."##"Informar a matrícula do participante."
				Return .F.
			Endif

			If nPOS > 0

				For nX := 1 to Len(aCOLS)

					If nX <> n .And. !aCOLS[nX][Len(aCOLS[nX])] .And. !aCOLS[n][Len(aCOLS[n])] .And. aCOLS[nX][nPOS] == cCodMat .And. aCOLS[nX][nPOS1] == aCOLS[n][nPOS1] .And. !Empty(cCodMat)
						xx := xx + 1
					Endif

				Next

			Endif

		ElseIf nPOS > 0

			For nX := 1 to Len(aCOLS)

				If nX <> n .And. !aCOLS[nX][Len(aCOLS[nX])] .And. !aCOLS[n][Len(aCOLS[n])] .And. aCOLS[nX][nPOS] == cCodMat .And. !Empty(cCodMat)
					xx := xx + 1
				Endif

			Next

		Endif

		If lUPDMDT89

			If nPOS2 > 0
				cNomePar:= aCOLS[n][nPOS2]

				For nX := 1 to Len(aCOLS)

					If nX <> n .And. !aCOLS[nX][Len(aCOLS[nX])] .And. !aCOLS[n][Len(aCOLS[n])] .And. aCOLS[nX][nPOS2] == cNomePar .And. aCols[nx][nPos3] == "2" .And. aCols[n][nPos3] == "2"
						xx := xx + 1
					Endif

				Next

			Endif

			If !aCOLS[n][Len(aCOLS[n])]

				If Empty(aCOLS[n][nPOS3])
					ShowHelpDlg(STR0012, {STR0023},2,{STR0027},1) //Título // Descrição // Lin. Descrição // Solução // Lin. Solução ##"Campo obrigatório não preenchido."##"Informar tipo do participante."
					Return .F.
				ElseIf Empty(cCodMat) .And. (aCOLS[n][nPOS3]) == "1"
					ShowHelpDlg(STR0012,	{STR0023},2,{STR0029},1) //Título // Descrição // Lin. Descrição // Solução // Lin. Solução ##"Campo obrigatório não preenchido."##"Informar a matrícula do participante."
					Return .F.
				ElseIf Empty(cNomePar) .And. aCOLS[n][nPOS3] == "2"
					ShowHelpDlg(STR0012,	{STR0023},2,{STR0026},1) //Título // Descrição // Lin. Descrição // Solução // Lin. Solução ##"Campo obrigatório não preenchido."
					Return .F.
				ElseIf (aCOLS[n][nPOS3]) == "1" .And. Empty(aCOLS[n][nPOS1])
					ShowHelpDlg(STR0012,	{STR0023},2,{STR0046},1) //Título // Descrição // Lin. Descrição // Solução // Lin. Solução ##"Campo obrigatório não preenchido."##"Informar a filial do participante."
					Return .F.
				Endif

			Endif

		Endif

	Endif

	If xx > 0
		Help(" ",1,"JAEXISTINF")
		lRet := .F.
	ElseIf lChamLOK
		cFilAnt := cFilA665
	Endif

Return lRET

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT665AG
Browse das agendas. Prestador

@type function

@sample MDT665AG()

@return Lógico, Sempre Verdadeiro

@author Andre Perez Alvarez
@since 22/10/2007
/*/
//---------------------------------------------------------------------
Function MDT665AG()

	Local aArea	    := GetArea()
	Local oldROTINA := aCLONE(aROTINA)
	Local oldCad    := cCadastro
	Local lPyme     := Iif(Type("__lPyme") <> "U",__lPyme,.F.)
	Local lCipatr   := If( SuperGetMv("MV_NG2NR31",.F.,"2") == "1", .T. , .F. )

	cCliMdtPs := SA1->A1_COD+SA1->A1_LOJA

	//----------------------------------------------------------------
	//| Define Array contendo as Rotinas a executar do programa      |
	//| ----------- Elementos contidos por dimensao ------------     |
	//| 1. Nome a aparecer no cabecalho                              |
	//| 2. Nome da Rotina associada                                  |
	//| 3. Usado pela rotina                                         |
	//| 4. Tipo de Transa‡„o a ser efetuada                          |
	//|    1 - Pesquisa e Posiciona em um Banco de Dados             |
	//|    2 - Simplesmente Mostra os Campos                         |
	//|    3 - Inclui registros no Banc0s de Dados                   |
	//|    4 - Altera o registro corrente                            |
	//|    5 - Remove o registro corrente do Banco de Dados          |
	//----------------------------------------------------------------
	Private aRotina := MenuDef( .F. )

	// Define o cabecalho da tela de atualizacoes
	Private cCadastro := OemtoAnsi(If(lCipatr,STR0057,STR0007)) //"Agenda CIPATR" //"Agenda CIPA"
	Private aCHKDEL  := {}, bNGGRAVA := {|| MDT665GRAV()}

	//----------------------------------------------------------------
	//|aCHKDEL array que verifica a INTEGRIDADE REFERENCIAL na exclu-|
	//|s„o do registro.                                              |
	//|                                                              |
	//|1 - Chave de pesquisa                                         |
	//|2 - Alias de pesquisa                                         |
	//|3 - ordem de pesquisa                                         |
	//----------------------------------------------------------------
	//aCHKDEL := { {'cCliMdtps + TNR->TNR_MANDAT + DTOS(TNR->TNR_DTREUN) + TNR->TNR_HRREUN', "TNS", 3}}

	aCHOICE := NGCAMPNSX3( "TNR", {"TNR_CLIENT", "TNR_LOJA", "TNR_FILIAL","TNR_DOCTO"} )

	// Endereca a funcaO de BRoWSE
	dbSelectArea("TNR")
	Set Filter To TNR->(TNR_CLIENT+TNR_LOJA) == cCliMdtps
		dbSetorder(1)
		mBrowse( 6, 1,22,75,"TNR")
		dbSelectArea("TNR")
	Set Filter To

	aROTINA := aCLONE(oldROTINA)
	RestArea(aArea)
	cCadastro := oldCad

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT665INC
Inclui, altera e exclui Agendas de Reuniao.

@type function

@sample MDT665INC( 'TNN' , 0 , 3 )

@return Nulo, Sempre Nulo

@param cAlias, Caracter, Alias da Tabela
@param nRecno, Numérico, Registro único do registro
@param nOpcx, Numérico, Tipo de Manutenção do Browse

@author Andre Perez Alvarez
@since 26/12/2008
/*/
//---------------------------------------------------------------------
Function MDT665INC(cAlias,nRecno,nOpcx)

	Local aArea := GetArea()
	Local nX := 0 		// Contador do For
	Local cReunExc := "", nTeste := 0
	Local aWFReun := {}

	If ( TNR->(FieldPos("TNR_DOCTO")) > 0 ) .And. ( TNR->(FieldPos("TNR_DOCFIL")) > 0 )
		Private aNgButton := {}
		Aadd(aNgButton,{"PARAMETROS" ,{||MDT665QDO()},STR0010,STR0011}) // "Relacionar documento" #  "Rel.Doc."
	EndIf

	// Adiciona botoes em aNgButton
	If ExistBlock("MDTA6651")
		aBtn:=ExecBlock("MDTA6651",.F.,.F.)

		If Valtype(aBtn) == "A"

			For nX := 1 To Len(aBtn)

				If Len( aBtn[nX] ) == 4		// Pra garantir que tenha icone, funcao a chamar,e as duas strings
					Aadd(aNgButton, aBtn[nX])
				EndIf

			Next nX

		EndIf

	EndIf

	bNGGRAVA := {|| MDT665GRAV(nOpcx)}

	NGCAD01(cAlias,nRecno,nOpcX)

	If nOpcx != 3
		RestArea(aArea)
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT665QDO
Monta a tela de visualizacao ou relacionamento do documento

@type function

@sample MDT665QDO()

@return Lógico, Retorna se anexou ou não o documento

@author Andre Perez Alvarez
@since 17/12/2008
/*/
//---------------------------------------------------------------------
Function MDT665QDO()

	Local oDlgQdo, oRadio
	Local nRadio := 1, nOpc := 1
	Local lRet := .T., lGrava

	Define MsDialog oDlgQdo From 03.5,6 To 150,320 Title STR0010 Pixel  // "Atencao"
	Define FONT oBold NAME "Courier New" SIZE 0, -13 BOLD
	@ 0, 0 BITMAP oBmp RESNAME "PROJETOAP" oF oDlgQdo SIZE 35,250 NOBORDER WHEN .F. PIXEL

	@ 05,040 Say OemToAnsi(STR0013) Size 117,7 Of oDlgQdo Pixel Font oBold  // "O que deseja fazer ?"

	@ 20,048 Radio oRadio Var nRadio Items STR0014,STR0015,STR0016 3d Size 105,10 Of oDlgQdo Pixel // "Relacionar um documento"#"Visualizar documento relacionado"#"Apagar documento relacionado"

	Define sButton From 055,090 Type 1 Enable Of oDlgQdo Action (lGrava := .T.,oDlgQdo:End())
	Define sButton From 055,120 Type 2 Enable Of oDlgQdo Action (lGrava := .F.,oDlgQdo:End())

	Activate MsDialog oDlgQdo Centered

	If !lGrava
		lRet := .F.
	Else

		If nRadio == 1

			If !MDT665RQDO()
				lRet := .F.
			EndIf

		ElseIf nRadio == 2

			If !MDT665VQDO()
				lRet := .F.
			EndIf

		Else
			M->TNR_DOCTO  := " "
			M->TNR_DOCFIL := " "
		EndIf

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT665RQDO
Relaciona uma agenda aum documento QDO

@type function

@sample MDT665RQDO()

@return Lógico, Sempre falso

@author Andre Perez Alvarez
@since 17/12/2008
/*/
//---------------------------------------------------------------------
Function MDT665RQDO()

	Local lRet := .F.

	lRet := ConPad1( , , , "QDH",,,.F.)

	If lRet
		M->TNR_DOCTO  := QDH->QDH_DOCTO
		M->TNR_DOCFIL := QDH->QDH_FILIAL
	EndIf

Return .F.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT665VQDO
Relaciona uma agenda aum documento QDO

@type function

@sample MDT665VQDO()

@return Lógico, Retorna se conseguiu visualizar o documento

@author Andre Perez Alvarez
@since 17/12/2008
/*/
//---------------------------------------------------------------------
Function MDT665VQDO()

	Local _lRet := .F.

	If !Empty(M->TNR_DOCTO)

		If QDOVIEW( , M->TNR_DOCTO ) //Visualiza documento Word...
			_lRet := .T.
		Endif

	Else
		MsgInfo(STR0017,STR0018)//"Nao existe documento associado a esta agenda."#"NÃO CONFORMIDADE"
	Endif

Return _lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT665FLVL
Valida filial dos campos relacionados a tabela SRA

@type function

@sample MDT665FLVL( 'D MG 01 ' )

@return Lógico, Retorna se filial está correta

@param cTNS_FILMAT, Caracter, Filial para validação

@author Denis
@since 17/12/2008
/*/
//---------------------------------------------------------------------
Function MDT665FLVL(cTNS_FILMAT)

	Local aArea    := GetArea()
	Local aAreaSM0 := SM0->(GetArea())
	Local lRet     := .T.
	Local nPOS     := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TNS_MAT"})
	Local nPOS2

	If lUPDMDT89
		nPOS2	:= aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TNS_NOMPAR"})
	Else
		nPOS2	:= aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TNS_NOME"})
	Endif

	dbSelectArea("SM0")

	IF !dbSeek(cEmpAnt+cTNS_FILMAT)
		Help(" ",1,"REGNOIS")
		lRet := .F.
	Else
		cFilAnt := cTNS_FILMAT
		dbSelectArea("SRA")
		dbSetOrder(01)

		If !dbSeek(xFilial("SRA",cFilAnt)+ aCols[n,nPOS] )
			aCols[n,nPOS] := Space( Len(SRA->RA_MAT) )
			aCols[n,nPOS2] := " "
		Else
			aCols[n,nPOS2] := SRA->RA_NOME
		Endif

	EndIF

	RestArea(aAreaSM0)
	RestArea(aArea)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fMDT665CHG
Funcao executa ao mudar de linha na Getdados

@type function

@sample fMDT665CHG()

@return Lógico, Sempre verdadeiro

@author Denis
@since 17/12/2008
/*/
//---------------------------------------------------------------------
Function fMDT665CHG()

	Local nPOS1 := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TNS_FILMAT"})
	cFilAnt := aCols[n,nPos1]

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT665NOM
Mostra o nome do funcionario no browse da TNS.

@type function

@sample MDT665NOM()

@return Caracter, Nome do Funcionário

@param cFilTmp, Caracter, Filial do Funcionário
@param cMatTmp, Caracter, Matrícula do Funcionário

@author Andre Perez Alvarez
@since 24/06/2008
/*/
//---------------------------------------------------------------------
Function MDT665NOM(cFilTmp,cMatTmp)

	Local cDesc := ""
	Local aArea := GetArea()

	cDesc := Posicione("SRA",1,xFilial("SRA",cFilTmp)+cMatTmp,"RA_NOME")
	RestArea(aArea)

Return cDesc

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT665TOK
Responsável por realizar a validação dos Participantes da Reunião CIPA.
Função utilizada no TUDOOK.

@type function

@source MDTA665.prw

@author Denis Hyroshi de Souza
@since 14/08/2006

@sample MDT665TOK()

@return lRet, Lógico, Retorna verdadeiro caso as informações estejam certas.
/*/
//---------------------------------------------------------------------
Function MDT665TOK()

	Local nX 	  := 0 //Variável de controle
	Local nPresen := aSCAN( aHeader, {|x| AllTrim(Upper(X[2])) == "TNS_PRESEN" }) //Identifica a posição do campo.
	Local lPresen := .F. //Identifica se Funcionário esteve presente na Reunião.
	Local lRet 	  := .T. //Retorno da função.

	Private aWFReun := {}
	Private nColuna := Len(aCols[n])

	ASORT(aCols,,, { |x, y| x[nColuna] .And. !y[nColuna] } )

	If Empty( M->TNR_ATA ) // Verifica se campo ATA está preenchido.

		If !MsgYesNo( STR0031 ) // "Deseja confirmar a Ata Reuniao sem nenhuma informação?"
			lRet := .F.
		EndIf

	EndIf

	If ExistBlock("MDTA6652")
		ExecBlock("MDTA6652",.F.,.F.,{.T.,aCOLS,aHEADER})
	EndIf

	For nX := 1 To Len(aCols)

		If !Empty( aCols[ nX, nPresen ] ) .And. !lPresen
			lPresen := .T.
		EndIf

	Next nX

	If lPresen .And. Empty(M->TNR_DTREAL) .And. lRet //Caso alguma presença foi Preenchida.
		ShowHelpDlg(STR0035,{STR0053},1,{STR0054},2)//"ATENÇÂO"##"O campo 'Compareceu ?' foi informado para algum participante."##"Favor preencher o campo 'Data Real'."
		lRet := .F.
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT665VTNN
Valida campo TNR_MANDAT

@type function

@sample MDT665VTNN()

@return Lógico, Indica se código do Mandato é válido

@author Denis Hyroshi de Souza
@since 29/07/2010
/*/
//---------------------------------------------------------------------
Function MDT665VTNN()

	Local lPrest := .F.

	If Type("cCliMdtPs") == "C" .And. !Empty(cCliMdtPs)
		lPrest := .T.
	Endif

	If lPrest
		Return EXISTCPO("TNN",M->TNR_CLIENT+M->TNR_LOJA+M->TNR_MANDAT,3)
	Else
		Return EXISTCPO("TNN",M->TNR_MANDAT,1)
	Endif

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT665HABL
Validação para habilitar campos.

@type function

@sample MDT665HABL()

@return Lógico, Indica se campo deve ser habilitado

@author Rodrigo Soledade
@since 11/04/2011
/*/
//---------------------------------------------------------------------
Function MDT665HABL()

	Local nPOS1, lRet := .F.

	nPOS1 := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TNS_TIPPAR"})

	If aCols[n,nPos1] == "1"
		lRet := .F.

	Elseif aCols[n,nPos1] == "2"
		lRet := .T.
	Endif

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT665HABT
Bloqueida campo dependendo do Parametro TNS_TIPPAR

@type function

@sample MDT665HABT()

@return Lógico, Indica se campo deve ser bloqueado

@author Rodrigo Soledade
@since 11/04/2011
/*/
//---------------------------------------------------------------------
Function MDT665HABT()

	Local nPOS1, lRet := .F.

	nPOS1 := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TNS_TIPPAR"})
	If aCols[n,nPos1] == "1"
		lRet := .T.

	Elseif aCols[n,nPos1] == "2"
		lRet := .F.
	Endif

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT665LIMP
Limpa campos

@type function

@sample MDT665LIMP()

@return Lógico, Sempre verdadeiro

@author Rodrigo Soledade
@since 14/04/2011
/*/
//---------------------------------------------------------------------
Function MDT665LIMP()

	Local nPOS, nPOS1, nPOS2, nPOS3
	Local nTamFil := FwSizeFilial()

	nPOS 	:= aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TNS_NOMPAR"})
	nPOS1 := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TNS_TIPPAR"})
	nPOS2 := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TNS_FILMAT"})
	nPOS3 := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TNS_MAT"})

	If M->TNS_TIPPAR == "1"  .And. Empty(aCols[n,nPOS3])
		aCols[n,nPOS] := Space(40)
	Elseif M->TNS_TIPPAR == "2" .And. !Empty(aCols[n,nPOS3])
		aCols[n,nPOS] := Space(40)
		aCols[n,nPOS2] := Space(nTamFil)
		aCols[n,nPOS3] := Space(6)
	Elseif M->TNS_TIPPAR == "2"
		aCols[n,nPOS2] := Space(nTamFil)
	Endif

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT665PA
Sugerir participantes reunioes

@type function

@sample MDT665PA()

@return Lógico, Sempre verdadeiro

@author Pedro Cardoso Furst
@since 24/10/2011
/*/
//---------------------------------------------------------------------
Static Function MDT665PA()

	Local aArea := GetArea()
	Local aAreaSRA := SRA->(GetArea())
	Local oDlgF,oFont
	Local oMARK1
	Local oPanel
	Local i
	//Variaveis de controle
	Local nPosMat := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TNS_MAT"})
	Local nPosFil := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TNS_FILMAT"})

	Private oTempTRB
	Private cMarca     := GetMark()
	Private lGrava     := .F.
	Private aVetinr    := {}
	Private cTRB       := GetNextAlias()

	lInverte := .F.
	lQuery := .T.

	aDBF := {}
	aAdd(aDBF,{ "RA_OK"		,	"C" ,02	, 0 })
	aAdd(aDBF,{ "RA_FILIAL"	,	"C" ,TAMSX3("RA_FILIAL")[1]	, 0 })
	aAdd(aDBF,{ "RA_MAT"	,	"C" ,9	, 0 })
	aAdd(aDBF,{ "RA_NOME"	,	"C" ,40	, 0 })
	aAdd(aDBF,{ "RA_SITFOLH",	"C" ,01	, 0 })

	aTRB := {}
	aAdd(aTRB,{ "RA_OK"    ,	NIL," "    ,})
	aAdd(aTRB,{ "RA_FILIAL",	NIL,STR0037,}) //"Filial"
	aAdd(aTRB,{ "RA_MAT",   	NIL,STR0038,}) //"Matricula"
	aAdd(aTRB,{ "RA_NOME",  	NIL,STR0039,}) //"Nome"
	aAdd(aTRB,{ "RA_SITFOLH",	NIL,STR0042,})// "Situação"

	//Cria TRB
	oTempTRB := FWTemporaryTable():New( cTRB, aDBF )
	oTempTRB:AddIndex( "1", {"RA_FILIAL","RA_MAT"} )
	oTempTRB:Create()

	dbSelectArea("SRA")
	dbSetOrder(1)
	dbGoTop()

	While !Eof()
		dbSelectArea(cTRB)
		dbSetOrder(1)

		If !dbSeek(SRA->(RA_FILIAL+RA_MAT)) .And. MDT665FILUS()
			RecLock(cTRB,.T.)
			(cTRB)->RA_OK     	:= If(aScan(aCols,{|x| x[nPosFil]+x[nPosMat] == AllTrim(SRA->(RA_FILIAL+RA_MAT))}) > 0,cMarca,"  ")
			(cTRB)->RA_FILIAL 	:= SRA->RA_FILIAL
			(cTRB)->RA_MAT    	:= SRA->RA_MAT
			(cTRB)->RA_NOME   	:= SRA->RA_NOME
			(cTRB)->RA_SITFOLH	:= SRA->RA_SITFOLH
			(cTRB)->(MsUnLock())
		Endif

		dbSelectArea("SRA")
		dbSkip()
	End

	For i := 1 to len(aCols)
		dbSelectArea(cTRB)
		dbSetOrder(1)

		If dbSeek(aCols[i,nPosFil]+Acols[i,nPosMat])
			RecLock(cTRB,.F.)
			(cTRB)->RA_OK := cMarca
			(cTRB)->(MsUnLock())
		EndIf

	Next i

	dbSelectArea(cTRB)
	Dbgotop()

	If (cTRB)->(Reccount()) <= 0
		oTempTRB:Delete()
		RestArea(aAreaSRA)
		RestArea(aArea)
		lRefresh := .T.
		Msgstop(STR0035,STR0036)  //"ATENÇÃO" //"Não existem funcionários cadastrados."
		Return .T.
	Endif

	nOpt := 2
	DEFINE FONT oFont NAME "Arial" SIZE 0,-12
	DEFINE MSDIALOG oDlgF TITLE OemToAnsi(STR0034) From 10,15 To 42,87 OF oMainWnd    //"Adicionar Participantes"
	@00,00 MSPANEL oPanel SIZE 0,0 of oDlgF
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT

	@ 0.4,1 TO 1.8,34.6 OF oPanel
	@ 11,15 SAY STR0033 SIZE 200,10 of oPanel PIXEL FONT oFont //"Selecione os participantes da reunião."

	oMARK1 := MsSelect():NEW((cTRB),"RA_OK",,aTRB,@lINVERTE,@cMARCA,{30,5,224,281},,,oPanel)
	oMARK1:bMARK := {|| MDT655MK(cMarca,lInverte)}
	oMARK1:oBROWSE:lHASMARK := .T.
	oMARK1:oBROWSE:lCANALLMARK := .T.
	oMARK1:oBROWSE:bALLMARK := {|| MDTA655INV(cMarca) }
	ACTIVATE MSDIALOG oDlgF ON INIT EnchoiceBar(oDlgF,{|| nOpt := 1,oDlgf:End()},{|| nOpt := 2,oDlgf:End()})

	If nOpt == 2
		oTempTRB:Delete()
		RestArea(aAreaSRA)
		RestArea(aArea)
		lRefresh := .T.
		Return .T.
	Endif

	Processa({|lEnd| MDT655CPY()})

	RestArea(aAreaSRA)
	RestArea(aArea)
	lRefresh := .T.

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT655MK
Marcação

@type function

@sample MDT665MK( 'XX' , .F. )

@return Nulo, Sempre nulo

@param cMarca, Caracter, Valor correspondente a marcação
@param lInverte, Lógico, Indica tipo de marcação (inversa ou normal)

@author Pedro Cardoso Furst
@since 25/10/2011
/*/
//---------------------------------------------------------------------
Function MDT655MK(cMarca,lInverte)

	If !Empty((cTRB)->RA_OK) .And. (cTRB)->RA_SITFOLH == "D"

		If !MsgYesNo(STR0043) //"Este funcionário está demitido. Deseja continuar?"
			(cTRB)->RA_OK := " "
		EndIf

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA655INV
Inverte a marcacao do browse

@type function

@sample MDTA665INV( 'XX' )

@return Lógico, Sempre verdadeiro

@param cMarca, Caracter, Valor correspondente a marcação

@author Pedro Cardoso Furst
@since 25/10/2011
/*/
//---------------------------------------------------------------------
Function MDTA655INV(cMarca)

	Local aArea := GetArea()
	Local nDemit := 0

	dbSelectarea(cTRB)
	Dbgotop()

	While !eof()
		RecLock((cTRB),.F.)

		If (cTRB)->RA_SITFOLH == "D" .And. Empty((cTRB)->RA_OK)
			nDemit++
		EndIf

		(cTRB)->RA_OK := IF(RA_OK  == "  ",cMARCA,"  ")
		(cTRB)->(MsUnLock())
		dbSkip()
	End

	Dbgotop()

	If nDemit > 0
		nDemit := 0

		If !MsgYesNo(STR0044) //"Existem alguns funcionários demitidos. Deseja selecioná-los?"
			Dbgotop()

			While !eof()

				If (cTRB)->RA_SITFOLH == "D"
					RecLock((cTRB),.F.)
					(cTRB)->RA_OK := IF(RA_OK  == "  ",cMARCA,"  ")
					(cTRB)->(MsUnLock())
				EndIf

				dbSkip()
			End

		EndIf

	Else

		While !eof()

			If (cTRB)->RA_SITFOLH == "D"
				RecLock((cTRB),.F.)
				(cTRB)->RA_OK := " "
				(cTRB)->(MsUnLock())
			EndIf

			dbSkip()
		End

	EndIf

	RestArea(aArea)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT655CPY
Copia os funcionarios selecionados no markbrowse para o a GetDados

@type function

@sample MDT665CPY()

@return Lógico, Sempre verdadeiro

@author Pedro Cardoso Furst
@since 25/10/2011
/*/
//---------------------------------------------------------------------
Static Function MDT655CPY()

	Local aoldCols := aClone(aCols)
	Local aExt := {}
	Local nX, nY,xx
	Local nFld
	Local xRetVal
	Local cTipSX3
	Local aLine := {}
	nMat := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TNS_MAT"})
	nFil := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TNS_FILMAT"})
	nNom := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TNS_NOMPAR"})
	nTip := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TNS_TIPPAR"})

	If nTip > 0

		For nX := 1 To Len(aCols)

			If aCols[nX][nTip] == "2"
				aAdd(aExt,aCols[nx])
			Endif

		Next nX

	Endif

	aCols := {}
	dbSelectArea(cTRB)
	dbGoTop()

	While !eof()
		lGrava := .T.

		If ( aSCAN(aCOLS,{|x| x[nFil]+x[nMat] == (cTRB)->RA_FILIAL+(cTRB)->RA_MAT } )  > 0 )
			lGrava := .F.
		Endif

		If lGrava .And. !Empty((cTRB)->RA_OK)
			aLine := BlankGetD( aHeader )[1]

			For nFld := 1 To Len( aHeader )

				If AllTrim( aHeader[ nFld , 2 ] ) == 'TNS_MAT'
					aLine[ nFld ] := (cTRB)->RA_MAT
				ElseIf AllTrim( aHeader[ nFld , 2 ] ) == 'TNS_FILMAT'
					aLine[ nFld ] := (cTRB)->RA_FILIAL
				ElseIf AllTrim( aHeader[ nFld , 2 ] ) == 'TNS_NOMPAR'
					aLine[ nFld ] := (cTRB)->RA_NOME
				ElseIf AllTrim( aHeader[ nFld , 2 ] ) == 'TNS_TIPPAR'
					aLine[ nFld ] := '1'
				Else

					If !( "_WT" $ aHeader[ nFld , 2 ] ) //Desconsidera campos de Walkthru
						xRetVal := ""

						If ExistIni( aHeader[ nFld , 2 ] )
							xRetVal := InitPad( Posicione( 'SX3' , 2 , aHeader[ nFld , 2 ] , "X3_RELACAO" ) )
						Else
							cTipSX3 := Posicione( 'SX3' , 2 , aHeader[ nFld , 2 ] , "X3_TIPO" )

							If cTipSX3 == "N"
								xRetVal := 0
							ElseIf cTipSX3 == "D"
								xRetVal := SToD( Space( 8 ) )
							ElseIf cTipSX3 == "L"
								xRetVal := .T.
							Else
								xRetVal := Space( TAMSX3( aHeader[ nFld , 2 ] )[ 2 ] )
							EndIf

						EndIf

						aLine[ nFld ] := xRetVal
					EndIf

				EndIf

			Next nFld

			aAdd( aCols, aLine )
		Endif

		dbSelectarea(cTRB)
		dbSkip()
	End

	If nTip > 0 .And. Len(aExt) > 0

		For nY := 1 To Len(aExt)
			aAdd(aCols,aExt[nY])
		Next nY

	Endif

	If Len(aCOls) > 0
		aSort(aCOls,,,{|x,y| x[nFil]+x[nMat] < y[nFil]+y[nMat]})
	Else
		aCOls := BlankGetD(aHeader)
	Endif

	oTempTRB:Delete()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de Menu Funcional.

@type function

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

@sample MenuDef()

@author Elynton Fellipe Bazzo
@since 20/09/2012
/*/
//---------------------------------------------------------------------
Static Function MenuDef( lSigaMdtPs )

	Default lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .T. , .F. )


	If lSigaMdtps
		aRotina := { { STR0001, "AxPesqui" , 0 , 1},; //"Pesquisar"
					{ STR0002, "MDT665INC", 0 , 2},; //"Visualizar"
					{ STR0008, "MDT665AG" , 0 , 4} } //"Agendas de Reunião"
	Else
		aRotina := { { STR0001 ,"AxPesqui" , 0 , 1},;     //"Pesquisar"
					{ STR0002 ,"MDT665INC", 0 , 2},;     //"Visualizar"
					{ STR0003 ,"MDT665INC", 0 , 3 , 0},; //"Incluir"
					{ STR0004 ,"MDT665INC", 0 , 4 , 0},; //"Alterar"
					{ STR0005 ,"MDT665INC", 0 , 5 , 0},; //"Excluir"
					{ STR0006 ,"MD665PA"  , 0 , 6 , 0} } //"Participantes"

		lPyme := Iif(Type("__lPyme") <> "U",__lPyme,.F.)

		If !lPyme
			AAdd( aRotina, { STR0019, "MsDocument", 0, 4 } )  //"Conhecimento"
		EndIf

	Endif

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT665DTREAL()
Valida Data Real da reunião.

@type function

@sample MDT665DTRE()

@author Rodrigo Soledade
@since 30/08/2013

@return lRet, Lógico, Retorna verdadeiro quando função estiver correta
/*/
//---------------------------------------------------------------------
Function MDT665DTRE()

	Local lRet := .T.

	If (M->TNR_DTREUN > M->TNR_DTREAL .Or. M->TNR_DTREAL > dDatabase) .And. !Empty(M->TNR_DTREAL)
		MsgStop(STR0047)//"A Data Real não pode ser menor que a Data da Reunião ou maior que a data atual."
		lRet := .F.
	EndIf

	If !Empty(M->TNR_HRREAL) .And. !Empty(M->TNR_DTREAL) .And. M->TNR_DTREAL == dDataBase .And. lRet

		If M->TNR_HRREAL > Substr(Time(),1,5)
			lRet := .F.
			ShowHelpDlg(STR0035,{STR0055},1,{STR0056},2)//"A Hora Real está maior que atual."##"Favor informar uma hora menor."
		EndIf

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fAddPartic()
Adicionar todos os participantes do mandato.

@type function

@sample fAddPartic()

@return Lógico, Sempre verdadeiro

@author Jean Pytter da Costa
@since 27/05/2014
/*/
//---------------------------------------------------------------------
Static Function fAddPartic()

	Local nCols
	Local nPosCol
	Local lConfirm 	:= .T.
	Local nOpc 		:= 0
	Local aAlias	:= {}
	Local aDelCols 	:= {}

	Private nPosNom  := GDFieldPos( "TNS_NOMPAR" , aHeader )
	Private nPosCod  := GDFieldPos( "TNS_TIPPAR" , aHeader )
	Private nPosFil  := GDFieldPos( "TNS_FILMAT" , aHeader )
	Private nPosMat  := GDFieldPos( "TNS_MAT"    , aHeader )
	Private aColsAux := {}
	Private aValCps  := { { "TNS_TIPPAR" 	, "TK8_TIPPAR" 		, "'1'" 										} , ;
					      { "TNS_FILMAT" 	, "TK8->TK8_FILRE"	, "TNQ->TNQ_FILMAT" 							} , ;
						  { "TNS_MAT" 	    , "TK8->TK8_MATRE"	, "TNQ->TNQ_MAT"							    } , ;
						  { "TNS_NOMPAR" 	, "TK8->TK8_NOMPAR"	, "NGSEEK('SRA',TNQ->TNQ_MAT,1,'SRA->RA_NOME')" } }
						  //Define os valores que deverão ser considerados na montagem do aCols temporário

	nOpc := Aviso( 	STR0059 , STR0060,; //"Participantes da Reunião" # "Quais participantes você deseja importar? "
					{ STR0064, STR0062 , STR0063, STR0061 }, 2 )//, , , '', .F. ) // "Fechar" # "Comissão" # "Componentes" # "Todos"

	If nOpc <> 1

		If nOpc <> 3 //Comissão Eleitoral
			fProcPart( "TK8" , 2 , "TK8->TK8_FILIAL+TK8->TK8_MANDAT" )
		EndIf

		If nOpc <> 2  //Componentes do Mandato
			fProcPart( "TNQ" , 3 , "TNQ->TNQ_FILIAL+TNQ->TNQ_MANDAT" )
		EndIf

		If Len( aColsAux ) > 0
			lConfirm := MsgYesNo( STR0050 + cValToChar( Len( aColsAux ) ) + ;//"Foi(ram) localizado(s) "
									" (" + AllTrim( Capital( Extenso( Len( aColsAux ) , .T. ) ) ) + ") " + STR0051 )//"componente(s) do mandato que ainda não é(são) participante(s) da reunião. Deseja importar?"
		Else
			MsgInfo( STR0052 )//"Não foram localizados componentes do mandato que ainda não são participantes da reunião."
			lConfirm := .F.
		EndIf

		If lConfirm

			// Percorre o aCols temporário verificando para jogar valores para aCols principal
			If Len( aCols ) == 1 .And. Empty(aCols[ 1 , nPosMat ]) .And. Empty(aCols[ 1 , nPosNom ])
				aCols := aClone( aColsAux )
			Else

				For nPosCol := 1 To Len( aColsAux )
					aAdd( aCols, aClone( aColsAux[ nPosCol ] ) )
				Next nPosCol

				aSort(aCols,,,{|x,y| x[nPosFil]+x[nPosMat] < y[nPosFil]+y[nPosMat]})
			EndIf

			// Atualiza o Objeto para atribuição do novo aCols
			oGet:oBrowse:Refresh()

		EndIf

	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fProcPart()
Procura os participantes da tabela passada como parâmetro

@param cAlias, Caracter, Alias da Tabela em que serão buscados os
participantes da reunião
@param nPosic, Numérico, Posição no array aValCps
@param cKeyPart, Caracter, Chave de Busca na tabela

@author Julia Kondlatsch
@since 25/01/2018
@return Nulo, Sem retorno
/*/
//---------------------------------------------------------------------
Static Function fProcPart( cAlias, nPosic, cKeyPart )

	Local nValores

	// Percorre a(s) tabela(s) para salvar os participantes no aCols temporário
	dbSelectArea(cAlias)
	dbSetOrder(1)

	If dbSeek(xFilial(cAlias) + TNR->TNR_MANDAT )

		While (cAlias)->( !EoF() ) .And. xFilial(cAlias)+TNR->TNR_MANDAT == &(cKeyPart)

			// Se não tiver sido adicionado no aCols auxiliar e no aCols Pricipal
			If aScan( aColsAux, { |x| AllTrim(x[ nPosCod ]) == AllTrim(&(aValCps[ 1 , nPosic ])) .And. ;
									  AllTrim(x[ nPosFil ]) == AllTrim(&(aValCps[ 2 , nPosic ])) .And. ;
								 	  AllTrim(x[ nPosMat ]) == AllTrim(&(aValCps[ 3 , nPosic ])) .And. ;
									  AllTrim(x[ nPosNom ]) == AllTrim(&(aValCps[ 4 , nPosic ])) } ) == 0 .And. ;
				aScan( aCols, { |x| AllTrim(x[ nPosCod ]) == AllTrim(&(aValCps[ 1 , nPosic ])) .And. ;
									AllTrim(x[ nPosFil ]) == AllTrim(&(aValCps[ 2 , nPosic ])) .And. ;
									AllTrim(x[ nPosMat ]) == AllTrim(&(aValCps[ 3 , nPosic ])) .And. ;
									AllTrim(x[ nPosNom ]) == AllTrim(&(aValCps[ 4 , nPosic ]))  } ) == 0

				// Adiciona uma linha em branco de acordo com o cabeçalho padrão, para após alimentar os valores dos campos
				aAdd( aColsAux , BlankGetD(aHeader)[1] )

			    // Percorre todos os valores a serem alimentados no aCols temporário,
			    // jogando estes nas respectivas posições, conforme aCols principal
				For nValores := 1 to Len( aHeader )

					If ( nPosVal := aScan( aValCps , { | x | AllTrim( aHeader[ nValores,  2 ] ) == x[ 1 ] } ) ) > 0
						aColsAux[ Len( aColsAux ) , nValores ] := &( aValCps[ nPosVal , nPosic ] )
					EndIf

				Next nValores

			EndIf

			dbSelectArea(cAlias)
			(cAlias)->(dbSkip())
		EndDo

	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT665FILUS

Filtra as filiais a que o usuário tem acesso na consulta padrão do campo TNS_FILMAT

@sample  MDT665FILUS(.T.)

@author	Luis Fellipy Bett
@since	19/09/2019
@param	[lSXB], Lógico, Indica se a função é chamada pelo SXB do campo TNS_FILMAT
/*/
//-------------------------------------------------------------------
Function MDT665FILUS( lSXB )

	Local lRet		:= .T.
	Local aGroups	:= {}
	Local aValues	:= {}
	Local aBranches	:= {}
	Local cGrpRule	:= ""
	Local nGroup	:= 0
	Local nValue	:= 0

	Default lSXB	:= .F.

	//Verifica se não é administrador
	If !FwIsAdmin()

		If lSXB //Se for chamado pela consulta padrão
			cFilChk := SM0->M0_CODFIL
		Else //Se for chamado pela função de filtro do CheckBox
			cFilChk := SRA->RA_FILIAL
		EndIf

		//Busca informações do usuário logado
		aUsr := PswRet()

		// cGrpRule - Indica a regra de acesso por grupo
		// 1 - Usuário prioriza regras do grupo
		// 2 - Usuário desconsidera regras do grupo
		// 3 - Usuário soma regras do grupo

		cGrpRule := FWUsrGrpRule( aUsr[ 1, 1 ] )

		If cGrpRule <> "1"
			aBranches := aUsr[ 2, 6 ] //recupera as filiais do usuário
		EndIf

		If cGrpRule <> "2"
			aGroups := aUsr[ 1, 10 ]//recupera as filiais do grupo

			For nGroup := 1 to Len( aGroups )
				aValues := FWGrpEmp( aGroups[ nGroup ] )
				For nValue := 1 To Len( aValues )
					If aScan( aBranches, aValues[ nValue ] ) == 0
						aAdd( aBranches, aValues[ nValue ] )
					EndIf
				Next nValue
			Next nGroup
		EndIf

		cFils := ArrTokStr( aBranches ) //Converte array das filiais para string

		If !( cFilChk $ cFils ) //Verifica se o funcionário tem acesso a filial
			lRet := .F.
		EndIf

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fEstabPart
Verifica se o componente faltou em pelo menos 5 reuniões

@sample	fEstabPart()

@author	Luis Fellipy Bett
@since	25/05/2021

@return Nil, Nulo
/*/
//---------------------------------------------------------------------
Static Function fEstabPart()

	Local cMandat	:= TNR->TNR_MANDAT
	Local dDtUltReu := SToD( "" )
	Local aReuOrds	:= {}
	Local aPartsReu	:= {}
	Local nCont		:= 0
	Local nCont2	:= 0
	Local nContFalt	:= 0

	//Busca os participantes da reunião cadastrada
	dbSelectArea( "TNS" )
	dbSetOrder( 1 ) //TNS_FILIAL+TNS_MANDAT+DTOS(TNS_DTREUN)+TNS_HRREUN+TNS_MAT
	If dbSeek( xFilial( "TNS" ) + cMandat + DToS( TNR->TNR_DTREUN ) + TNR->TNR_HRREUN )
		While TNS->( !Eof() ) .And. TNS->TNS_FILIAL == xFilial( "TNS" ) .And. TNS->TNS_MANDAT == cMandat .And. ;
			DToS( TNS->TNS_DTREUN ) == DToS( TNR->TNR_DTREUN ) .And. TNS->TNS_HRREUN == TNR->TNR_HRREUN
			aAdd( aPartsReu, { cMandat, TNS->TNS_FILMAT, TNS->TNS_MAT } ) //Adiciona todos os participantes da reunião para conferência
			TNS->( dbSkip() )
		End
	EndIf

	//Busca todas as reuniões ordinárias do mandato
	dbSelectArea( "TNR" )
	dbSetOrder( 1 ) //TNR_FILIAL+TNR_MANDAT+DTOS(TNR_DTREUN)+TNR_HRREUN
	If dbSeek( xFilial( "TNR" ) + cMandat )
		While TNR->( !Eof() ) .And. TNR->TNR_FILIAL == xFilial( "TNR" ) .And. TNR->TNR_MANDAT == cMandat
			If TNR->TNR_TIPREU == "1" //Caso for reunião ordinária salva no array
				aAdd( aReuOrds, { cMandat, TNR->TNR_DTREUN, TNR->TNR_HRREUN } ) //Adiciona todos os participantes da reunião para conferência
			EndIf
			TNR->( dbSkip() )
		End
	EndIf

	//Verifica todos os funcionários da reunião
	For nCont := 1 To Len( aPartsReu )

		//Verifica se o funcionário faltou em 5 ou mais reuniões
		For nCont2 := 1 To Len( aReuOrds )

			dbSelectArea( "TNS" )
			dbSetOrder( 1 ) //TNS_FILIAL+TNS_MANDAT+DTOS(TNS_DTREUN)+TNS_HRREUN+TNS_MAT
			If dbSeek( xFilial( "TNS" ) + aReuOrds[ nCont2, 1 ] + DToS( aReuOrds[ nCont2, 2 ] ) + aReuOrds[ nCont2, 3 ] + aPartsReu[ nCont, 3 ] )
				If TNS->TNS_PRESEN == "3" //Caso houver uma reunião no mesmo mandato que o funcionário faltou
					nContFalt++ //Incrementa o número de faltas
					If Empty( dDtUltReu ) .Or. TNS->TNS_DTREUN >= dDtUltReu
						dDtUltReu := TNS->TNS_DTREUN //Guarda a data da última reunião
					EndIf
				EndIf
			EndIf

			If nContFalt >= 5 //Caso o componente tenha 5 ou mais faltas
				MDT660ESTB( .T., , aPartsReu[ nCont, 1 ], aPartsReu[ nCont, 2 ], aPartsReu[ nCont, 3 ], dDtUltReu, .T. )
				Exit
			EndIf

		Next nCont2

		//Zera contador e data para validar o próximo funcionário
		nContFalt := 0
		dDtUltReu := SToD( "" )

	Next nCont

Return
