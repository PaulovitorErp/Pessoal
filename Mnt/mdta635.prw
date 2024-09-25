#include "Mdta635.ch"
#include "Protheus.ch"
#include "COLORS.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA635()

Programa de Cadastro do Mandato

@type   function

@author Thiago Olis Machado
@since  03/05/2001

@return Lógico, Sempre .T.
/*/
//---------------------------------------------------------------------
Function MDTA635()

	// Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	Local aNGBEGINPRM := NGBEGINPRM()

	Private lUpdMdt48 := NGCADICBASE("TNN_CODORI","A","TNN",.F.)//Verifica update
	Private aRotina := MenuDef()
	Private cCadastro
	Private cPrograma := "MDTA635"

	Private lSigaMdtPS := SuperGetMv("MV_MDTPS",.F.,"N") == "S"
	Private lUPDMDT35, lTk8Tippar:= .F.
	Private lTipoTNN := .T. // Variavel para Tipo do mandato, padrão ou extraordinario.

	If AMiIn( 35 ) // Somente autorizado para SIGAMDT
		lUPDMDT35 := NGCADICBASE("TNN_VTBRAN","D","TNN",.F.) //Verifica se existe o campo "TNN_VTBRAN" na base.
		lTk8Tippar := NGCADICBASE("TK8_TIPPAR","D","TK8",.F.) //Verifica se existe o campo "TK8_TIPPAR" na base.

		If lSigaMdtps
			cCadastro := OemtoAnsi(STR0031)  //"Clientes"

			DbSelectArea("SA1")
			DbSetOrder(1)

			mBrowse( 6, 1,22,75,"SA1")
		Else

			// Define o cabecalho da tela de atualizacoes
			Private aCHKDEL := {}, bNGGRAVA
			cCadastro := OemtoAnsi(STR0006) //"Mandatos"

			// aCHKDEL array que verifica a INTEGRIDADE REFERENCIAL na exclusão do registro.
			// 1 - Chave de pesquisa
			// 2 - Alias de pesquisa
			// 3 - Ordem de pesquisa

			aCHKDEL := { {'TNN->TNN_MANDAT'    , "TNO", 1},;
						{'TNN->TNN_MANDAT'    , "TNR", 1},;
						{'TNN->TNN_MANDAT'    , "TNV", 1},;
						{'TNN->TNN_MANDAT'    , "TNQ", 1}}

			// Endereca a funcao de BROWSE
			DbSelectArea("TNN")
			If lUpdMdt48 .And. !lSigaMdtPS
				Set Filter To  Empty(TNN->TNN_CODORI)
			EndIf
			DbSetOrder(1)
			mBrowse( 6, 1,22,75,"TNN")

		EndIf
	EndIf

	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	NGRETURNPRM(aNGBEGINPRM)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT635EXC
Funcao de exclusao

@type    function
@author  Denis Hyroshi de Souza
@since
@sample  MDT635EXC( )

@param   cAliasX, Caractere, Alias da tabela
@param   nRecnoX, Caractere, Numero do registro posicionado
@param   nOpcx, Caractere, Opção do menu

@return  Nil, Lógico, Nulo
/*/
//-------------------------------------------------------------------
Function MDT635EXC( cAliasX, nRecnoX, nOpcX )

	Local aArea
	Local cCodMand := TNN->TNN_MANDAT
	Local cFilOld := cFilAnt
	Local nIndTNW
	Local cSeekTNW
	Local cCondTNW
	Local lExtra := .T.

	If lSigaMdtps
		nIndTNW  := 6  //TNW_FILIAL+TNW_CLIENT+TNW_LOJA+TNW_CODIGO+DTOS(TNW_DTINIC)+TNW_HRINIC
		cSeekTNW := xFilial("TNW")+cCliMdtps+cCodMand
		cCondTNW := "TNW->(TNW_FILIAL+TNW_CLIENT+TNW_LOJA+TNW_CODIGO)"
	Else
		nIndTNW  := 4  //TNW_FILIAL+TNW_CODIGO+DTOS(TNW_DTINIC)+TNW_HRINIC
		cSeekTNW := xFilial("TNW")+cCodMand
		cCondTNW := "TNW->(TNW_FILIAL+TNW_CODIGO)"
	Endif

	bNGGRAVA := {|| CHKTA635() }

	//Verifica se o mandato possui um mandato extra relacionado
	aArea := TNN->(getArea())
	dbSelectArea("TNN")
	dbSetOrder(1)
	dbGoTop()

	While TNN->(!EoF()) .And. lExtra
		If TNN->TNN_CODORI == M->TNN_MANDAT
			HELP(" ",1,"ERRO",,STR0070,2,1) //"Exclusão não permitida. Existe um mandato extra vinculado a este mandato."
			lExtra := .F.
		EndIf
		TNN->(dbSkip())
	End

	RestArea(aArea)

	If lExtra
		aArea := GetArea()
		dbSelectArea("TNW")
		dbSetOrder(nIndTNW)
		dbSeek(cSeekTNW)
		While !Eof() .And. cSeekTNW == &cCondTNW
			RecLock("TNW",.F.)
			dbDelete()
			TNW->(MsUnLock())
			dbSkip()
		End
		RestArea(aArea)
	EndIf

	bNGGRAVA := {}
	cFilAnt  := cFilOld

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CHKTA635

Validacao no momento da exclusao

@type    function

@author  Denis Hyroshi de Souza
@since

@return  Lógico, .T. se a exclusão é válida
/*/
//-------------------------------------------------------------------
Function CHKTA635()

	Local lRet := .T.
	Local aArea := GetArea()

	If !Altera .And. !Inclui

		dbSelectArea("TNT")

		If lSigaMdtps

			dbSetOrder(3)  //TNT_FILIAL+TNT_CLIENT+TNT_LOJA+TNT_MANDAT+TNT_ACIDEN+TNT_CODPLA
			If Dbseek(xFilial("TNT")+cCliMdtps+M->TNN_MANDAT)
				lRet := .F.
				cError := AllTrim( X2Nome() ) + " (" + "TNT" + ")"
				HELP(" ",1,"MA10SC",,cError,5,1)
			End

		Else

			Dbsetorder(1)  //TNT_FILIAL+TNT_ACIDEN+TNT_MANDAT+TNT_CODPLA
			Dbseek(xFilial("TNT"))
			While !eof() .And. xFilial("TNT") == TNT->TNT_FILIAL
				If M->TNN_MANDAT == TNT->TNT_MANDAT
					lRet := .F.
					cError := AllTrim( X2Nome() ) + " (" + "TNT" + ")"
					HELP(" ",1,"MA10SC",,cError,5,1)
					Exit
				Endif
				Dbskip()
			End

		Endif

	Endif

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de Menu Funcional.

@type    function

@author  Rafael Diogo Richter
@since   29/11/2006

@sample  MenuDef()

@Obs Parametros do array a Rotina:
		1. Nome a aparecer no cabecalho
		2. Nome da Rotina associada
		3. Reservado
		4. Tipo de Transação a ser efetuada:
			1 - Pesquisa e Posiciona em um Banco de Dados
			2 - Simplesmente Mostra os Campos
			3 - Inclui registros no Bancos de Dados
			4 - Altera o registro corrente
			5 - Remove o registro corrente do Banco de Da
		5. Nivel de acesso
		6. Habilita Menu Funcional

@return  Array, Opções do menu
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local lMdtMin := If( SuperGetMv("MV_MDTMIN",.F.,"N") == "S", .T. , .F. )
	Local lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .T. , .F. )
	Local aRotina
	Local lEleiExt := If(Type("lUpdMdt48") == "L", lUpdMdt48 , .F.)

	If lSigaMdtps
		aRotina := { { STR0001,   "AxPesqui"   , 0 , 1    },;  //"Pesquisar"
					 { STR0002,   "MDTA111TCD" , 0 , 2    },;  //"Visualizar"
					 { STR0006,   "MDT635TNN"  , 0 , 4    } }  //"Mandatos"
	Else
		aRotina :=	{ { STR0001,  "AxPesqui"   , 0 , 1    },;   //"Pesquisar"
					  { STR0002,  "MDTA111TCD" , 0 , 2    },;   //"Visualizar"
					  { STR0003,  "MDTA111TCD" , 0 , 3    },;   //"Incluir"
					  { STR0004,  "MDTA111TCD" , 0 , 4    },;   //"Alterar"
					  { STR0005,  "MDTA111TCD" , 0 , 5, 3 } } //"Excluir"

	If lEleiExt
			AAdd( aRotina, { STR0058 , "Mdt635Ext", 0, 2 } )   //"Eleição extra."
	EndIf
		If lMdtMin
			aADD( aRotina , { STR0032, "MDT635AREA" , 0 , 4 } ) //"Áreas"
		Endif
		lPyme := Iif(Type("__lPyme") <> "U",__lPyme,.F.)
		If !lPyme
			AAdd( aRotina, { STR0037, "MsDocument", 0, 4 } )  //"Conhecimento"
		EndIf
	Endif

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT635TNN
Monta um browse com mandatos do cliente.

@type    function
@author  Andre Perez Alvarez
@since   11/10/2007
@sample  MDT635TNN()
@return  Lógico, Nulo
/*/
//-------------------------------------------------------------------
Function MDT635TNN()

	Local aArea	:= GetArea()
	Local oldROTINA := aCLONE(aROTINA)
	Local oldCad := cCadastro
	Local lMdtMin := If( SuperGetMv("MV_MDTMIN",.F.,"N") == "S", .T. , .F. )
	Local lEleiExt := If(Type("lUpdMdt48") == "L", lUpdMdt48 , .F.)
	Local aStrTNN := TNN->( dbStruct() )
	Local nStr
	cCliMdtPs := SA1->A1_COD+SA1->A1_LOJA

	aRotina :=	{ { STR0001,  "AxPesqui"  , 0 , 1},;    //"Pesquisar"
				{ STR0002,  "MDTA111TCD" , 0 , 2},;    //"Visualizar"
				{ STR0003,  "MDTA111TCD" , 0 , 3},;    //"Incluir"
				{ STR0004,  "MDTA111TCD" , 0 , 4},;    //"Alterar"
				{ STR0005,  "MDTA111TCD" , 0 , 5, 3} } //"Excluir"
	If lEleiExt
		AAdd( aRotina, { STR0058 , "Mdt635Ext", 0, 2 } )   //"Eleição extra."
	EndIf

	If lMdtMin
		aADD( aRotina , { STR0032, "MDT635AREA" , 0 , 4 } ) //"Áreas"
	Endif

	// Define o cabecalho da tela de atualizacoes
	Private cCadastro := OemtoAnsi(STR0006) //"Mandatos"
	Private aCHKDEL := {}, bNGGRAVA

	//aCHKDEL array que verifica a INTEGRIDADE REFERENCIAL na excluão do registro.
	//1 - Chave de pesquisa
	//2 - Alias de pesquisa
	//3 - Ordem de pesquisa

	aCHKDEL := { {'TNN->TNN_CLIENT+TNN->TNN_LOJAC+TNN->TNN_MANDAT'    , "TNO", 3},;
				{'TNN->TNN_CLIENT+TNN->TNN_LOJAC+TNN->TNN_MANDAT'    , "TNR", 2},;
				{'TNN->TNN_CLIENT+TNN->TNN_LOJAC+TNN->TNN_MANDAT'    , "TNV", 2},;
				{'TNN->TNN_CLIENT+TNN->TNN_LOJAC+TNN->TNN_MANDAT'    , "TNQ", 3},;
				{'TNN->TNN_CLIENT+TNN->TNN_LOJAC+TNN->TNN_MANDAT'    , "TNT", 3} }

	aCHOICE := {}

	For nStr := 1 To Len( aStrTNN )
		If !( aStrTNN[ nStr , 1 ] $ "TNN_CLIENT/TNN_LOJA/TNN_CODORI/TNN_FILIAL" )
			aAdd( aCHOICE, aStrTNN[ nStr , 1 ] )
		Endif
	Next nStr

	// Endereca a funcao de BROWSE
	DbSelectArea("TNN")
	If lUpdMdt48
		Set Filter To TNN->(TNN_CLIENT+TNN_LOJAC) == cCliMdtps  .And. Empty(TNN->TNN_CODORI)
	Else
	Set Filter To TNN->(TNN_CLIENT+TNN_LOJAC) == cCliMdtps
	EndIf
	DbSetOrder(1)
	mBrowse( 6, 1,22,75,"TNN")

	DbSelectArea("TNN")
	Set Filter To

	aROTINA := aCLONE(oldROTINA)
	RestArea(aArea)
	cCadastro := oldCad

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT635LOK
Funcao de validacao da Linha

@type    function
@author  Denis Hyroshi de Souza
@since   11/10/2007
@sample  MDT635LOK()

@return  Lógico, Verdadeiro se a linha for válida
/*/
//-------------------------------------------------------------------
Function MDT635LOK()

	Local xx := 0, nX
	Local nPos1 := aScan( aHEADER, { |x| Trim( Upper(x[2]) ) == "TLJ_CC"})
	Local nPos2 := aScan( aHEADER, { |x| Trim( Upper(x[2]) ) == "TLJ_AREA"})

	If acols[n][len(Acols[n])]
		Return .T.
	Endif

	For nX := 1 to Len(aCOLS)
		If nx <> n
			If aCOLS[nX][nPos1] == aCOLS[n][nPos1] .And. ;
				aCOLS[nX][nPos2] == aCOLS[n][nPos2] .And. ;
				!acols[nX][len(Acols[nX])]

				xx++
			Endif
		EndIf
	Next

	If xx > 0
		Help(" ",1,"JAEXISTINF")
		Return .F.
	Endif

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT635TOK

Funcao de validacao da getdados

@type    function

@author  Denis Hyroshi de Souza
@since   11/10/2007

@sample  MDT635TOK()

@return  Lógico, Lógico, Verdadeiro
/*/
//-------------------------------------------------------------------
Function MDT635TOK()
	/*
	Local xx := 0, nX
	Local nPos1 := aScan( aHEADER, { |x| Trim( Upper(x[2]) ) == "TLJ_CC"})
	Local nPos2 := aScan( aHEADER, { |x| Trim( Upper(x[2]) ) == "TLJ_AREA"})

	If acols[n][len(Acols[n])]
		Return .T.
	Endif

	For nX := 1 to Len(aCOLS)
		If !acols[nX][len(Acols[nX])]
			If Empty(aCOLS[nX][nPos1])
				MsgInfo("Campo Centro de Custo é Obrigatório. Linha: "+Alltrim(Str(nX,9)),"Atenção")
				Return .F.
			Endif
			If Empty(aCOLS[nX][nPos2])
				MsgInfo("Campo Área CIPA é Obrigatório. Linha: "+Alltrim(Str(nX,9)),"Atenção")
				Return .F.
			Endif
		Endif
	Next
	*/
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT635AREA

Cadastramento das Areas da CIPA

@type    function

@author  Denis Hyroshi de Souza
@since   11/10/2007

@sample  MDT635AREA()

@return  Nulo, Nulo
/*/
//-------------------------------------------------------------------
Function MDT635AREA()

	Local LVar01  := 1
	Local nLinhas := 0
	Local bCampo
	Local cSaveMenuh
	Local nCnt
	Local GetList :={}
	Local nSavRec
	Local aArea   := GetArea()
	Local oDlg
	Local oGet
	Local i
	Local oPanel
	Local aFields
	Local cField
	Local cUso
	Local cNvlFld
	Local aTField
	Local nFld
	Local oPnlPai
	Local nReg
	Local lCipatr := SuperGetMv("MV_NG2NR31",.F.,"2") == "1"

	Private aCOLS
	Private aSize    := MsAdvSize(,.F.,100), aObjects := {}
	Private cAliasCC := "CTT"
	Private cFilCC   := "CTT->CTT_FILIAL"
	Private cCodCC   := "CTT->CTT_CUSTO"
	Private cDesCC   := "CTT->CTT_DESC01"
	Private aTELA[0][0]
	Private aGETS[0]
	Private aHeader[0]
	Private nUsado   :=0

	nSavRec := RecNo()
	Aadd(aObjects,{10,10,.T.,.T.})
	Aadd(aObjects,{050,050,.T.,.T.})
	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObjects,.T.)

	nOpcx := 4

	If Alltrim(GETMV("MV_MCONTAB")) != "CTB"
		cAliasCC := "SI3"
		cFilCC   := "SI3->I3_FILIAL"
		cCodCC   := "SI3->I3_CUSTO"
		cDesCC   := "SI3->I3_DESC"
	Endif

	//Verifica se existe algum dado no arquivo
	dbSelectArea("TNN")
	dbSetOrder(1)
	For i := 1 TO FCount()
		x   := "M->" + FieldName(i)
		&x. := FieldGet(i)
	Next i

	nCnt := 0

	//Monta a entrada de dados do arquivo
	bCampo := {|nCPO| Field(nCPO) }

	//Monta o cabecalho
	dbSelectArea(cAliasCC)
	dbSetOrder(1)
	dbSeek(xFilial(cAliasCC))
	While !Eof() .And. xFilial(cAliasCC) == &(cFilCC)

		dbSelectArea("TLJ")
		dbSetOrder(1)
		If !dbSeek(xFilial("TLJ") + TNN->TNN_MANDAT + &(cCodCC))
			RecLock("TLJ",.T.)
			TLJ->TLJ_FILIAL := xFilial("TLJ")
			TLJ->TLJ_MANDAT := TNN->TNN_MANDAT
			TLJ->TLJ_CC     := &(cCodCC)
			TLJ->(MsUnLock())
		Endif

		nCnt ++

		dbSelectArea(cAliasCC)
		dbSkip()
	End

	If nCnt == 0
		MsgInfo( If( lCipatr, STR0068, STR0033 ) + ; //"Não será possível cadastrar as áreas que serão representadas na CIPA, "
				STR0034, STR0035) //"pois não existe Centro de Custo cadatrado."###"Atenção"
		RestArea(aArea)
		Return
	Endif

	nIndic  := 1
	cSeek :=  TNN->TNN_MANDAT
	cCond := 'TLJ->TLJ_FILIAL+TLJ->TLJ_MANDAT == "' + xFilial("TLJ") + cSeek + '"'

	FillGetDados( nOpcx, "TLJ", nIndic, cSeek, {||}, {||.T.}, , , , , { | | NGMontaaCols( "TLJ", cSeek, cCond, , nIndic ) } )

	If Len(aCols) > 0

		nPosCCC := aScan( aHeader, { |x| Trim( Upper(x[2]) ) == "TLJ_CC"    })
		nPosCAR := aScan( aHeader, { |x| Trim( Upper(x[2]) ) == "TLJ_AREA"  })
		nPosNCC := aScan( aHeader, { |x| Trim( Upper(x[2]) ) == "TLJ_NOMECC"})
		nPosNAR := aScan( aHeader, { |x| Trim( Upper(x[2]) ) == "TLJ_NOAREA"})

		For nReg := 1 To Len( aCols )

			aCols[ nReg, nPosNCC ] := Posicione( cAliasCC, 1, xFilial(cAliasCC)+aCols[nReg,nPosCCC], cDesCC )

			If !Empty(aCols[nReg,nPosCAR])
				aCols[ nReg, nPosNAR ] := Posicione( cAliasCC, 1, xFilial(cAliasCC)+aCols[nReg,nPosCAR], cDesCC )
			Endif

		Next nReg

	EndIf

	//Tela
	nOpca := 0
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL

		oPnlPai := TPanel():New(0, 0, , oDlg, , .T., .F., , , 0, 0, .T., .F. )
		oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

		@ 020,020 MSPANEL oPanel OF oPnlPai
		oPanel:Align := CONTROL_ALIGN_TOP
		@ 12,08 SAY OemtoAnsi(STR0006) of oPanel Pixel //"Mandato"
		@ 12,35 MSGET TNN->TNN_MANDAT SIZE 20,09 WHEN .F. of oPanel Pixel
		@ 12,72 SAY OemToAnsi(STR0036) of oPanel Pixel //"Descricao"
		@ 12,99 MSGET TNN->TNN_DESCRI SIZE 150,09 WHEN .F. of oPanel Pixel

		dbSelectArea("TLJ")

		oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"MDT635LOK()","MDT635TOK()","",;
									.F.,,,,3000,,,,"AllwaysTrue",oPnlPai)
		oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(oGet:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End(),nOpca := 0},;
				AlignObject(oPnlPai,{oPanel,oGet:oBrowse},1,,{80}))

	If nOpcA == 1
		Begin Transaction
			lGravaOk := MDT635GRAV()
			If lGravaOk
				//Processa Gatilhos
				EvalTrigger()
			EndIf
		End Transaction
	Endif

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT635GRAV
Grava as areas da CIPA para mineradoras

@type    function
@author  Denis Hyroshi de Souza
@since   11/10/2007
@sample  MDT635GRAV()
@return  Lógico, Lógico, Verdadeiro
/*/
//-------------------------------------------------------------------
Function MDT635GRAV()

	Local xInd
	Local nPos1 := aScan( aHEADER, { |x| Trim( Upper(x[2]) ) == "TLJ_CC"})
	Local nPos2 := aScan( aHEADER, { |x| Trim( Upper(x[2]) ) == "TLJ_AREA"})

	For xInd := 1 To Len(aCols)

		dbSelectArea("TLJ")
		dbSetOrder(1)
		lIncTLJ := !dbSeek(xFilial("TLJ") + TNN->TNN_MANDAT + aCols[xInd,nPos1] )

		RecLock("TLJ",lIncTLJ)
		TLJ->TLJ_FILIAL := xFilial("TLJ")
		TLJ->TLJ_MANDAT := TNN->TNN_MANDAT
		TLJ->TLJ_CC     := aCols[xInd,nPos1]
		TLJ->TLJ_AREA   := aCols[xInd,nPos2]
		TLJ->(MsUnLock())

	Next xInd

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT635VLCC
Valida o campo de Centro de Custo

@type    function
@author  Denis Hyroshi de Souza
@since   11/10/2007
@sample  MDT635VLCC( '0001', 1 )

@param   cTLJ_CC, Caractere, Código do centro de custo/Area
@param   nTipoVld, Numérico, Campo que está sendo validadado:
(1) TLJ_CC ou (2) TLJ_AREA

@return  lRet, Lógico, Lógico, Nulo
/*/
//-------------------------------------------------------------------
Function MDT635VLCC( cTLJ_CC, nTipoVld )

	Local aArea := GetArea()

	If Empty(cTLJ_CC)
		If nTipoVld == 1
			nPos1 := aScan( aHEADER, { |x| Trim( Upper(x[2]) ) == "TLJ_NOMECC"})
			aCols[n,nPos1] := Space( Len(aCols[n,nPos1]) )
		Else
			nPos1 := aScan( aHEADER, { |x| Trim( Upper(x[2]) ) == "TLJ_NOAREA"})
			aCols[n,nPos1] := Space( Len(aCols[n,nPos1]) )
		Endif
		Return .T.
	Endif

	lRet := ExistCpo(cAliasCC,cTLJ_CC)

	If lRet
		dbSelectArea(cAliasCC)
		dbSetOrder(1)
		dbSeek(xFilial(cAliasCC)+cTLJ_CC)
		If nTipoVld == 1
			nPos1 := aScan( aHEADER, { |x| Trim( Upper(x[2]) ) == "TLJ_NOMECC"})
			aCols[n,nPos1] := &(cDesCC)
		Else
			nPos1 := aScan( aHEADER, { |x| Trim( Upper(x[2]) ) == "TLJ_NOAREA"})
			aCols[n,nPos1] := &(cDesCC)
		Endif
	Endif

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT635WHFL
When dos campos relacionados a tabela de funcionarios (SRA)

@type    function
@author  Denis Hyroshi de Souza
@since   11/10/2007
@sample  MDT635WHFL(1)
@param   nTipo, Numérico, Campo de onde está sendo chamado o when
@return  Lógico, Lógico, Verdadeiro
/*/
//-------------------------------------------------------------------
Function MDT635WHFL( nTipo )

	Local cVarCpo := Alltrim(ReadVar())
	Local	nFILRE  := aScan( aHEADER, { |x| Trim( Upper(x[2]) ) == "TK8_FILRE"})

	If cVarCpo == "M->TNN_MATRE1"
		If Type("M->TNN_FILRE1") == "C"
			If !Empty(M->TNN_FILRE1)
				cFilAnt := M->TNN_FILRE1
			EndIf
		EndIf
	ElseIf cVarCpo == "M->TNN_MATRE2"
		If Type("M->TNN_FILRE2") == "C"
			If !Empty(M->TNN_FILRE2)
				cFilAnt := M->TNN_FILRE2
			EndIf
		EndIf
	ElseIf cVarCpo == "M->TK8_MATRE"
		If Type("aCols[n][nFILRE]") == "C"
			If !Empty(aCols[n][nFILRE])
				cFilAnt := aCols[n][nFILRE]
			EndIf
		EndIf
	ElseIf cVarCpo == "M->TNN_PRESID"
		If Type("M->TNN_FILPRE") == "C"
			If !Empty(M->TNN_FILPRE)
				cFilAnt := M->TNN_FILPRE
			EndIf
		EndIf
	ElseIf cVarCpo == "M->TNN_SECRET"
		If Type("M->TNN_FILSEC") == "C"
			If !Empty(M->TNN_FILSEC)
				cFilAnt := M->TNN_FILSEC
			EndIf
		EndIf
	ElseIf cVarCpo == "M->TNN_PRESES"
		If Type("M->TNN_FILPSE") == "C"
			If !Empty(M->TNN_FILPSE)
				cFilAnt := M->TNN_FILPSE
			EndIf
		EndIf
	ElseIf cVarCpo == "M->TNN_SECSES"
		If Type("M->TNN_FILSSE") == "C"
			If !Empty(M->TNN_FILSSE)
				cFilAnt := M->TNN_FILSSE
			EndIf
		EndIf
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT635FLVL
Valida filial dos campos relacionados a tabela SRA

@type    function
@author  Denis Hyroshi de Souz
@since   11/10/2007
@sample  MDT635FLVL(1)
@param   nTipo, Numérico, Campo que está sendo validado
@return  lRet, Lógico, Veradeiro se o campo for válido
/*/
//-------------------------------------------------------------------
Function MDT635FLVL(nTipo)

	Local aArea    := GetArea()
	Local aAreaSM0 := SM0->(GetArea())
	Local lRet     := .T.
	Local cFilTmp  := ""

	If nTipo == 1
		cFilTmp := M->TNN_FILRE1
	ElseIf nTipo == 2
		cFilTmp := M->TNN_FILRE2
	ElseIf nTipo == 3
		cFilTmp := M->TNN_FILPRE
	ElseIf nTipo == 4
		cFilTmp := M->TNN_FILSEC
	ElseIf nTipo == 5
		cFilTmp := M->TNN_FILPSE
	ElseIf nTipo == 6
		cFilTmp := M->TNN_FILSSE
	EndIf

	dbSelectArea("SM0")
	IF !dbSeek(cEmpAnt+cFilTmp)
		Help(" ",1,"REGNOIS")
		lRet := .F.
	EndIf

	If lRet
		cMatTmp := " "
		If nTipo == 1
			cMatTmp := "M->TNN_MATRE1"
		ElseIf nTipo == 2
			cMatTmp := "M->TNN_MATRE2"
		ElseIf nTipo == 3
			cMatTmp := "M->TNN_PRESID"
		ElseIf nTipo == 4
			cMatTmp := "M->TNN_SECRET"
		ElseIf nTipo == 5
			cMatTmp := "M->TNN_PRESES"
		ElseIf nTipo == 6
			cMatTmp := "M->TNN_SECSES"
		EndIf

		dbSelectArea("SRA")
		dbSetOrder(01)
		If !dbSeek(xFilial("SRA",cFilTmp)+ &(cMatTmp) )
			If !Empty(cMatTmp)
				&(cMatTmp) := Space( Len(SRA->RA_MAT) )
			EndIf
		EndIf
	EndIf

	RestArea(aAreaSM0)
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT635VMAT
description

@type    function
@author  Denis Hyroshi de Souza
@since   11/10/2007
@sample  MDT635VMAT(1)
@param   nTipo, Numérico, Campo que está sendo validado
@return  lRet, Lógico, Veradeiro se o campo for válido
/*/
//-------------------------------------------------------------------
Function MDT635VMAT( nTipo )

	Local aOldAli  := Alias()
	Local lRet     := .T.
	Local cMatTmp  := ""
	Local cFilTmp  := ""

	If nTipo == 1
		cMatTmp := M->TNN_MATRE1
		cFilTmp := "M->TNN_FILRE1"
	ElseIf nTipo == 2
		cMatTmp := M->TNN_MATRE2
		cFilTmp := "M->TNN_FILRE2"
	ElseIf nTipo == 3
		cMatTmp := M->TNN_PRESID
		cFilTmp := "M->TNN_FILPRE"
	ElseIf nTipo == 4
		cMatTmp := M->TNN_SECRET
		cFilTmp := "M->TNN_FILSEC"
	ElseIf nTipo == 5
		cMatTmp := M->TNN_PRESES
		cFilTmp := "M->TNN_FILPSE"
	ElseIf nTipo == 6
		cMatTmp := M->TNN_SECSES
		cFilTmp := "M->TNN_FILSSE"
	EndIf

	If !Empty(cMatTmp)
		If !ExCpoMDT("SRA",cMatTmp)
			lRet := .F.
		EndIf
	EndIf

	If lRet
		If !Empty(cMatTmp)
			&(cFilTmp) := cFilAnt
			dbSelectArea("SRA")
			dbSetOrder(1)
			dbSeek(xFilial("SRA")+cMatTmp)
			If nTipo ==5
				M->TNN_NOMPRE:=SRA->RA_NOME
			EndIf
			If nTipo ==6
				M->TNN_NOMSEC:=SRA->RA_NOME
			EndIf
		Else
			&(cFilTmp) := Space( Len(SRA->RA_FILIAL) )
		EndIf
	EndIf

	If lRet .And. (nTipo == 1 .Or. nTipo == 2) .And. !Empty(M->TNN_MATRE1) .And. !Empty(M->TNN_MATRE2) .And. ;
		M->TNN_FILRE1 == M->TNN_FILRE2 .And. M->TNN_MATRE1 == M->TNN_MATRE2

		// 'Atenção' # ''O cadastro de Secretário não pode ser igual ao de Secretário Substituto''
		MsgStop( STR0071, STR0035 )
		lRet := .F.

	EndIf

	dbSelectArea(aOldAli)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fA635Grv
Valida gravação
@type    function
@author  Denis Hyroshi de Souza
@since   11/10/2007
@sample  fA635Grv()

@return  Lógico, Verdadeiro se a gravação for válida
/*/
//-------------------------------------------------------------------
Function fA635Grv()

	Local cTmp := Space( Len( SRA->RA_FILIAL ) )

	If lCpFil635
		If !Empty(M->TNN_FILPRE) .And. Empty(M->TNN_PRESID)
			M->TNN_FILPRE := cTmp
		EndIf
		If !Empty(M->TNN_FILSEC) .And. Empty(M->TNN_SECRET)
			M->TNN_FILSEC := cTmp
		EndIf
		If !Empty(M->TNN_FILPSE) .And. Empty(M->TNN_PRESES)
			M->TNN_FILPSE := cTmp
		EndIf
		If !Empty(M->TNN_FILSSE) .And. Empty(M->TNN_SECSES)
			M->TNN_FILSSE := cTmp
		EndIf
	EndIf

	If IsInCallStack('Mdt635Ext')
		If Empty(M->TNN_ELEICA)
			MsgInfo(STR0043)
			Return .F.
		EndIf
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA111TCD
Cria tela de cadastro de Mandatos

@type    function
@author
@since   09/15/2010
@sample  MDTA111TCD( 'TNN', 1, 3 )

@param   cAliasX, Caractere, Alias da tabela
@param   nRecnoX, Caractere, Numero do registro posicionado
@param   nOpcx, Caractere, Opção do menu

@return  nOpca, Numérico, Opção selecionada do menu
/*/
//-------------------------------------------------------------------
Function MDTA111TCD( cAliasX, nRecnoX, nOpcx )

	Local aChoiceF1    := {}, aChoiceF2 := {}, aChoiceF3  := {}
	Local aChoiceF4    := {}, aChoiceFO := {}, aPages     := {}
	Local aNaoF1       := {}, aNaoF2    := {}, aNaoF3     := {}
	Local aNaoF4       := {}, aNaoFO    := {}, aTitles    := {}
	Local oDlg
	Local oFolder
	Local oCodVar
	Local cFilOld      := cFilAnt
	Local lTk8Tippar   := NGCADICBASE("TK8_TIPPAR","D","TK8",.F.) .And. NGRetOrdem( "TK8", "TK8_FILIAL+TK8_TIPPAR+TK8_MANDAT+TK8_FILRE+TK8_MATRE+TK8_NOMPAR" ) > 0 //Verifica se existe o campo "TK8_TIPPAR" na base.
	Local aArea        := GetArea()
	Local nStr
	Local cFolder
	Local aStrTNN      := TNN->( dbStruct() )

	Private aSvATelaF1 := {}
	Private aSvATelaF2 := {}
	Private aSvATelaF3 := {}
	Private aSvATelaF4 := {}
	Private aSvATelaF5 := {}
	Private aTela 	   := {}
	Private aGets 	   := {}
	Private aSVHEADER  := {}
	Private aSVCOLS    := {}
	Private aRotina    := {}
	Private lGETD	   := .T.
	Private lFO		   := .F.
	Private oGET
	Private lInclui    := If((nOpcx == 3),.T.,.F.)
	Private nTIPPAR    := 0
	Private lTipoTNN   := If(Type("lTipoTNN") == "L",lTipoTNN,.T.)

	If nOpcx != 3
		dbSelectArea("TNN")
		dbGoTo(nRecnoX)
	Endif
	nRecno := TNN->(Recno())

	dbSelectArea("TNN")
	dbSetOrder(1)
	RegToMemory("TNN",lInclui)

	For nStr := 1 To Len( aStrTNN )

		cFolder := Posicione("SX3",2,aStrTNN[ nStr , 1 ],"X3_FOLDER")

		If aStrTNN[ nStr , 1 ] == "TNN_CODORI" .And. lTipoTNN
			AADD(aNaoF1,aStrTNN[ nStr , 1 ])
			AADD(aNaoF2,aStrTNN[ nStr , 1 ])
			AADD(aNaoF3,aStrTNN[ nStr , 1 ])
			AADD(aNaoF4,aStrTNN[ nStr , 1 ])
			AADD(aNaoFO,aStrTNN[ nStr , 1 ])
			//DbSkip()
			Loop
		EndIf
		If Val(Alltrim(cFolder)) == 1
			AADD(aNaoF2,aStrTNN[ nStr , 1 ])
			AADD(aNaoF3,aStrTNN[ nStr , 1 ])
			AADD(aNaoF4,aStrTNN[ nStr , 1 ])
			AADD(aNaoFO,aStrTNN[ nStr , 1 ])
		Elseif Val(Alltrim(cFolder)) == 2
			AADD(aNaoF1,aStrTNN[ nStr , 1 ])
			AADD(aNaoF3,aStrTNN[ nStr , 1 ])
			AADD(aNaoF4,aStrTNN[ nStr , 1 ])
			AADD(aNaoFO,aStrTNN[ nStr , 1 ])
		Elseif Val(Alltrim(cFolder)) == 3
			AADD(aNaoF1,aStrTNN[ nStr , 1 ])
			AADD(aNaoF2,aStrTNN[ nStr , 1 ])
			AADD(aNaoF4,aStrTNN[ nStr , 1 ])
			AADD(aNaoFO,aStrTNN[ nStr , 1 ])
		Elseif Val(Alltrim(cFolder)) == 4
			AADD(aNaoF1,aStrTNN[ nStr , 1 ])
			AADD(aNaoF2,aStrTNN[ nStr , 1 ])
			AADD(aNaoF3,aStrTNN[ nStr , 1 ])
			AADD(aNaoFO,aStrTNN[ nStr , 1 ])
		Else
			AADD(aNaoF1,aStrTNN[ nStr , 1 ])
			AADD(aNaoF2,aStrTNN[ nStr , 1 ])
			AADD(aNaoF3,aStrTNN[ nStr , 1 ])
			AADD(aNaoF4,aStrTNN[ nStr , 1 ])
		Endif

	Next nStr

	aChoiceF1 := NGCAMPNSX3("TNN",aNaoF1)
	aChoiceF2 := NGCAMPNSX3("TNN",aNaoF2)
	aChoiceF3 := NGCAMPNSX3("TNN",aNaoF3)
	aChoiceF4 := NGCAMPNSX3("TNN",aNaoF4)
	aChoiceFO := NGCAMPNSX3("TNN",aNaoFO)

	//Retira os campos de usuário, apenas deixa os habilitados
	aAdd( aChoiceF1 , "NOUSER" )
	aAdd( aChoiceF2 , "NOUSER" )
	aAdd( aChoiceF3 , "NOUSER" )
	aAdd( aChoiceF4 , "NOUSER" )
	If Len( aChoiceFO ) > 0
		aAdd( aChoiceFO , "NOUSER" )
	EndIf

	//Tamanho da tela
	Private aAC := {"Titulo 1","Titulo 2"},aCRA:= {"Titulo 3","Titulo 4","Titulo 5"} //"Abandona"###"Confirma"###"Confirma"###"Redigita"###"Abandona"
	Private aHeader[0],Continua,nUsado:=0
	Private aSize := MsAdvSize(,.F.,430), aObjects := {}
	Aadd(aObjects,{200,200,.T.,.F.})
	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObjects,.T.)

	Aadd(aTitles,OemToAnsi(STR0006)) //"Mandato"
	Aadd(aTitles,OemToAnsi(STR0060)) //"Comissão Eleitoral"
	Aadd(aTitles,OemToAnsi(STR0061)) //"Eleição"
	Aadd(aTitles,OemToAnsi(STR0062)) //"Sessão de Instalação e Posse"
	Aadd(aPages,"Header 1")
	Aadd(aPages,"Header 2")
	Aadd(aPages,"Header 3")
	Aadd(aPages,"Header 4")
	If !Empty(aChoiceFO)
	Aadd(aTitles,OemToAnsi("Outros")) //"Outros"
	Aadd(aPages,"Header 5")
	Endif
	nControl := 4

	aRotina := { { STR0001, "AxPesqui", 0, 1 },; //"Pesquisar"
				 { STR0002, "AxVisual", 0, 2 },; //"Visualizar"
				 { STR0003, "AxInclui", 0, 3 },; //"Incluir"
				 { STR0004, "AxAltera", 0, 4 },; //"Alterar"
				 { STR0005, "AxDeleta", 0, 5 } } //"Excluir"


	nOpca:=0
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0063) From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL//"Cadastro de Mandatos"

	// Folders
	oFolder := TFolder():New(1,0,aTitles,aPages,oDlg,,,,.F.,.F.,aSize[3],aSize[4],)
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT
	// Folder 1 - Mandato
	If !Empty(aChoiceF1)
		oFolder:aDialogs[1]:oFont := oDlg:oFont
		oEnc01   := MsMGet():New("TNN",nRecno,nOpcx,,,,aChoiceF1,{13,0,89,500},,,,,,oFolder:aDialogs[1],,,.F.,"aSvATelaF1",.T.)
		oEnc01:oBox:Align := CONTROL_ALIGN_ALLCLIENT
		aSvATelaF1 := aClone(aTela)
		aSvAGetsF1 := aClone(aGets)
	Endif
	If !lTipoTNN
	// Mandato 	M->TNN_MANDAT := cMandatoOri
		M->TNN_DTINIC := cDataini
		M->TNN_DTTERM := cDatafim
		M->TNN_CODORI := cMandatoOri
	//	M->TNN_DESCRI := cTNNDescri
		M->TNN_CC     := cTNNCC
	EndIf
	// Folder 2 - Comissao Eleitoral
	aHeader 	 := {}
	aCols   	 := {}
	aNoFields := {}

	DbSelectArea("TK8")
	DbSeTOrder(1)
	cGetWhlFon := "TK8->TK8_FILIAL == '"+xFilial("TK8")+"' .And. TK8->TK8_MANDAT == '"+TNN->TNN_MANDAT+"'"
	FillGetDados( nOpcx, "TK8", 1, "TNN->TNN_MANDAT", {|| }, {|| .T.},aNoFields,,,,{|| NGMontaAcols("TK8", TNN->TNN_MANDAT,cGetWhlFon)})

	nTK8 := Len(aCols)

	DbSelectArea("TK8")
	dbGoTop()
	Dbgobottom()
	If Empty(aCOLS) .Or. nOpcx == 3
		PutFileInEof("TK8")
	aCOLS := BLANKGETD(aHEADER)
	EndIf
	nTK8FILIAL    := aSCAN(aHEADER,{|x| Trim(Upper(x[2])) == "TK8_FILIAL"})
	nTK8MATRE     := aSCAN(aHEADER,{|x| Trim(Upper(x[2])) == "TK8_MATRE"})
	nTK8NOMRE     := aSCAN(aHEADER,{|x| Trim(Upper(x[2])) == "TK8_NOMRE"})
	nFILRE		  := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TK8_FILRE"})
	aSVHEADER     := aCLONE(aHEADER)
	aSVCOLS   	  := aCLONE(aCOLS)
	n             := Len(aCOLS)
	oGET := MSGETDADOS():New(0,0,135,315,nOpcx,"MDTA635LIN() .And. PutFileInEof( 'TK8' )","AllwaysTrue()","",lGETD,,,,300,,,,,oFOLDER:aDIALOGS[2])
	oGET:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGET:oBROWSE:Default()
	oGET:oBROWSE:REFRESH()

	// Folder 3 - Eleicao
	If !Empty(aChoiceF3)
		aTela := {}
		aGets := {}
		oFolder:aDialogs[3]:oFont := oDlg:oFont
		oEnc03   := MsMGet():New("TNN",nRecno,nOpcx,,,,aChoiceF3,{13,0,89,500},,,,,,oFolder:aDialogs[3],,,.F.,"aSvATelaF3",.T.)
		oEnc03:oBox:Align := CONTROL_ALIGN_ALLCLIENT
		aSvATelaF3 := aClone(aTela)
		aSvAGetsF3 := aClone(aGets)
	Endif

	// Folder 4 - Instalacao e Posse
	If !Empty(aChoiceF4)
		aTela := {}
		aGets := {}
		oFolder:aDialogs[4]:oFont := oDlg:oFont
		oEnc04   := MsMGet():New("TNN",nRecno,nOpcx,,,,aChoiceF4,{13,0,89,500},,,,,,oFolder:aDialogs[4],,,.F.,"aSvATelaF4",.T.)
		oEnc04:oBox:Align := CONTROL_ALIGN_ALLCLIENT
		aSvATelaF4 := aClone(aTela)
		aSvAGetsF4 := aClone(aGets)
	Endif

	// Folder 5 - Outros
	If !Empty(aChoiceFO)
		lFO := .T.
		aTela := {}
		aGets := {}
		oFolder:aDialogs[5]:oFont := oDlg:oFont
		oEnc05   := MsMGet():New("TNN",nRecno,nOpcx,,,,aChoiceFO,{13,0,89,500},,,,,,oFolder:aDialogs[5],,,.F.,"aSvATelaF5",.T.)
		oEnc05:oBox:Align := CONTROL_ALIGN_ALLCLIENT
		aSvATelaFO := aClone(aTela)
		aSvAGetsFO := aClone(aGets)
	Endif
	dbSelectArea("TK8")
	dbGoTop()
	//PutFileInEof("TK8")
	If nOpcx == 5
		Activate MsDialog oDlg On Init EnchoiceBar(oDlg,{||nOpca := 1,If(oGET:TudoOK(),If(!A635DELOK(),nOpca := 0, oDlg:End()),nOpca := 0)},{||oDlg:End()}) CENTERED
	Else
		Activate MsDialog oDlg On Init EnchoiceBar(oDlg,{||nOpca := 1,If(oGET:TudoOK(),If(!A111TUDOOK(),nOpca := 0, oDlg:End()),nOpca := 0)},{||oDlg:End()}) CENTERED
	EndIf

	cFilAnt := cFilOld

	If nOpca == 1
		A635GRAVA( cAliasX, nRecnoX, nOpcx )

		//Esta sendo chamado em 2 locais, pois possui uma validação se a TK8 existe, fazendo que entre em funções diferentes.
		If ExistBlock("MDTA6351")
			ExecBlock("MDTA6351",.F.,.F.)
		Endif

	Endif

	RestArea(aArea)

Return nOpca

//-------------------------------------------------------------------
/*/{Protheus.doc} A635DELOK
Validação da exclusão de registros

@type    function
@author  Rodrigo Soledade
@since   27/05/2011
@sample  A635DELOK()
@return  lRet, Lógico, Verdadeiro se exclusão estiver ok
/*/
//-------------------------------------------------------------------
Function A635DELOK()

	Local nIndTN0  := 1
	Local nIndTNR  := 1
	Local nIndTNV  := 1
	Local nIndTNQ  := 1
	Local cTemp    := ""
	Local lRet     := .T.
	Local aAreaTNN := {}

	If lSigaMdtps
		cTemp := cClimdtps
		nIndTN0 := 4
		nIndTNR := 2
		nIndTNV := 4
		nIndTNQ := 8
	Endif

	//Riscos
	dbSelectArea("TNO")
	dbSetOrder(nIndTN0)
	If dbSeek(xFilial("TNO")+cTemp+M->TNN_MANDAT) .And. lRet
		cError := AllTrim( X2Nome() ) + " (" + "TNO" + ")"
		HELP(" ",1,"NGINTMOD",,cError,5,1)
		lRet := .F.
	Endif

	dbSelectArea("TNR")
	dbSetOrder(nIndTNR)
	If dbSeek(xFilial("TNR")+cTemp+M->TNN_MANDAT) .And. lRet
		cError := AllTrim( X2Nome() ) + " (" + "TNR" + ")"
		HELP(" ",1,"NGINTMOD",,cError,5,1)
		lRet := .F.
	Endif

	dbSelectArea("TNV")
	dbSetOrder(nIndTNV)
	If dbSeek(xFilial("TNV")+cTemp+M->TNN_MANDAT) .And. lRet
		cError := AllTrim( X2Nome() ) + " (" + "TNV" + ")"
		HELP(" ",1,"NGINTMOD",,cError,5,1)
		lRet := .F.
	Endif

	dbSelectArea("TNQ")
	dbSetOrder(nIndTNQ)
	If dbSeek(xFilial("TNQ")+cTemp+M->TNN_MANDAT) .And. lRet
		cError := AllTrim( X2Nome() ) + " (" + "TNQ" + ")"
		HELP(" ",1,"NGINTMOD",,cError,5,1)
		lRet := .F.
	Endif

	//Verifica se o mandato possui um mandato extra relacionado
	aAreaTNN := TNN->(getArea())
	dbSelectArea("TNN")
	dbSetOrder(1)
	dbGoTop()
	While TNN->(!EoF()) .And. lRet
		If TNN->TNN_CODORI == M->TNN_MANDAT
			HELP(" ",1,"ERRO",,STR0070,2,1) //"Exclusão não permitida. Existe um mandato extra vinculado a este mandato."
			lRet := .F.
		EndIf
		TNN->(dbSkip())
	End
	RestArea(aAreaTNN)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A635GRAVA
Retorna aCols e aHeader quando se foca a GETDADOS

@type    function
@author  Hugo Rizzo Pereira
@since   21/09/2010
@sample  A635GRAVA()

@param   cAliasX, Caractere, Alias da tabela
@param   nRecnoX, Caractere, Numero do registro posicionado
@param   nOpcx, Caractere, Opção do menu

@return  Lógico, Sempre Verdadeiro
/*/
//-------------------------------------------------------------------
Function A635GRAVA( cAliasX, nRecnoX, nOpcx )

	Local i, j, ny
	Local aArea		 := GetArea()
	Local nMATRE	 := aSCAN( aHEADER, { |x| AllTrim( Upper( X[2]) ) == "TK8_MATRE"  } )
	Local nFILRE	 := aSCAN( aHEADER, { |x|    Trim( Upper( x[2]) ) == "TK8_FILRE"  } )
	Local nTIPPAR	 := aSCAN( aHEADER, { |x|    Trim( Upper( x[2]) ) == "TK8_TIPPAR" } )
	Local nNOMPAR	 := aSCAN( aHEADER, { |x|    Trim( Upper( x[2]) ) == "TK8_NOMPAR" } )
	Local lTk8Tippar := NGCADICBASE( "TK8_TIPPAR", "D", "TK8", .F. ) .And. ;
						NGRetOrdem( "TK8", "TK8_FILIAL + TK8_TIPPAR + TK8_MANDAT + TK8_FILRE + TK8_MATRE + TK8_NOMPAR" ) > 0 //Verifica se existe o campo "TK8_TIPPAR" na base.

	Private lSigaMdtPS := IIf( SuperGetMv( "MV_MDTPS", .F., "N" ) == "S", .T. , .F. )

	If nOpcx <> 5 .And. nOpcx <> 2

		lInclui := IIf( ( nOpcx == 3 ), .T., .F. )

		DbSelectArea( "TNN" )
		RecLock( "TNN", lInclui )

		For ny := 1 To TNN->( FCount() )

			nx := "M->" + TNN->( FieldName( ny ) )

			If "_FILIAL" $ Upper( nx )
				TNN->TNN_FILIAL := xFilial( "TNN" )
			Else
				TNN->( FieldPut( ny, &nx. ) )
			Endif

		Next ny

		TNN->( MsUnLock() )

		dbSelectArea( "TK8" )
		ASORT( aCols, , , { |x, y| x[Len( aCols[n] )] .And. !y[Len( aCols[n] )] } )

		dbSelectArea( "TK8" )
		If lTk8Tippar
			nInd := IIf( lSigaMdtPS, 5, 3 )
			dbSetOrder( nInd )
		Else
			nInd := IIf( lSigaMdtPS, 3, 1 )
			dbSetOrder( nInd )
		EndIf

		dbSeek( xFilial( "TK8" ) + IIf( lSigaMdtPS, cCliMdtPs, "" ) + TNN->TNN_MANDAT )
		While !Eof() .And. xFilial("TK8") + TNN->TNN_MANDAT == TK8->( TK8_FILIAL + TK8_MANDAT ) .And. ;
			IIf( lSigaMdtPS, cCliMdtPs == TK8->( TK8_CLIENT + TK8_LOJA ), .T. )

			If aScan( aCols, {|x| x[nFILRE] + x[nMATRE] == TK8->( TK8_FILRE + TK8_MATRE )} ) == 0
				RecLock( "TK8", .F. )
				dbDelete()
				MsUnlock( "TK8" )
			Endif
			dbSkip()
		End

		For i := 1 To Len( aCols )
			If !aCols[i][Len( aCols[i] )] //.And. !Empty(aCols[i][nFILRE]) .And. !Empty(aCols[i][nMATRE])

				dbSelectArea( "TK8" )
				If lTk8Tippar
					If lSigaMdtPS
						dbSetOrder( 5 )//"TK8_FILIAL+TK8_CLIENT+TK8_LOJA+TK8_TIPPAR+TK8_MANDAT+TK8_FILRE+TK8_MATRE+TK8_NOMPAR"
						If dbSeek( xFilial( "TK8" ) + cCliMdtPs + aCols[i][nTIPPAR] + TNN->TNN_MANDAT + aCols[i][nFILRE] + aCols[i][nMATRE] + aCols[i][nNOMPAR] )
						RecLock( "TK8", .F. )
					Else
						RecLock( "TK8", .T. )
						Endif
					Else
						dbSetOrder( 3 ) //TK8_FILIAL+TK8_TIPPAR+TK8_MANDAT+TK8_FILRE+TK8_MATRE+TK8_NOMPAR
						If dbSeek( xFilial( "TK8" ) + aCols[i][nTIPPAR] + TNN->TNN_MANDAT + aCols[i][nFILRE] + aCols[i][nMATRE] + aCols[i][nNOMPAR] )
							RecLock( "TK8", .F. )
						Else
							RecLock( "TK8", .T. )
						Endif
					EndIf
				Else
					dbSetOrder( 1 )
					If dbSeek( xFilial( "TK8" ) + TNN->TNN_MANDAT + aCols[i][nFILRE] + aCols[i][nMATRE] )
						RecLock( "TK8", .F. )
					Else
						RecLock( "TK8", .T. )
					Endif
				EndIf

				For j := 1 to FCount()
					If "_FILIAL" $ Upper( FieldName( j ) ) .Or. "_MANDAT" $ Upper( FieldName( j ) ) .Or.;
						"_CLIENT" $ Upper( FieldName( j ) ) .Or. "_LOJA" $ Upper( FieldName( j ) )
						Loop
					Endif
					If ( nPos := aScan( aHeader, {|x| AllTrim( Upper(x[2] )) == AllTrim( Upper( FieldName( j ) ) ) } ) ) > 0
						FieldPut( j, aCols[i][nPos] )
					Endif
				Next j

				If lSigaMdtPS
					TK8->TK8_CLIENT := SA1->A1_COD
					TK8->TK8_LOJA   := SA1->A1_LOJA
				Endif
				TK8->TK8_FILIAL := xFilial( "TK8" )
				TK8->TK8_MANDAT := TNN->TNN_MANDAT
				MsUnlock( "TK8" )

			ElseIf !Empty( aCols[i][nMATRE] ) .And. !Empty( aCols[i][nFILRE] ) .Or. aCols[i][nTIPPAR] == "2"

				dbSelectArea( "TK8" )
				If lTk8Tippar
					If !lSigaMdtPS
						dbSetOrder( 3 )
						If dbSeek( xFilial( "TK8" ) + aCols[i][nTIPPAR] + TNN->TNN_MANDAT + aCols[i][nFILRE] + aCols[i][nMATRE] + aCols[i][nNOMPAR] )
							RecLock( "TK8", .F. )
							dbDelete()
							MsUnlock( "TK8" )
						EndIf
					Else
						dbSetOrder( 5 )
						If dbSeek( xFilial( "TK8" ) + cCliMdtPs + aCols[i][nTIPPAR] + TNN->TNN_MANDAT + aCols[i][nFILRE] + aCols[i][nMATRE] + aCols[i][nNOMPAR] )
							RecLock( "TK8", .F. )
							dbDelete()
							MsUnlock( "TK8" )
						EndIf
					EndIf
				Else
					dbSetOrder( IIf( lSigaMdtPS, 3, 1 ) )
					If dbSeek( xFilial( "TK8" ) + IIf( lSigaMdtPS, cCliMdtPs, "") + TNN->TNN_MANDAT + aCols[i][nFILRE] + aCols[i][nMATRE] )
						RecLock( "TK8", .F. )
						dbDelete()
						MsUnlock( "TK8" )
					Endif
				Endif
			Endif
		Next i

	ElseIf nOpcx == 5

		dbSelectArea( "TNN" )
		RecLock( "TNN", .F. )
		dbDelete()
		TNN->( MsUnLock() )

		dbSelectArea( "TK8" )
		dbSetOrder( IIf( lSigaMdtPS, 3, 1 ) )
		dbSeek( xFilial( "TK8" ) + IIf( lSigaMdtPS, cCliMdtPs, "" ) + TNN->TNN_MANDAT )
		While !Eof() .And. xFilial( "TK8" ) + TNN->TNN_MANDAT == TK8->( TK8_FILIAL + TK8_MANDAT ) .And. ;
			IIf( lSigaMdtPS, cCliMdtPs == TK8->( TK8_CLIENT + TK8_LOJA ), .T. )

			RecLock( "TK8", .F. )
			dbDelete()
			MsUnlock( "TK8" )
			dbSkip()
		End

		MDT635EXC( cAliasX, nRecnoX, nOpcX )
	Endif

	If nOpcx == 3
		MDT635INCE()
	Endif

	RestArea( aArea )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT635VCOD
Valida campo TNN_MANDAT

@type    function
@author  Denis
@since   25/10/2007
@sample  MDT635VCOD()
@return  Lógico, Verdadeiro se o campo for válido
/*/
//-------------------------------------------------------------------
Function MDT635VCOD()

	Local lPrest := .F.

	If Type("cCliMdtPs") == "C"
		If !Empty(cCliMdtPs)
			lPrest := .T.
		Endif
	Endif

	If lPrest
		Return EXISTCHAV("TNN",M->TNN_CLIENT+M->TNN_LOJAC+M->TNN_MANDAT,3)
	Else
		Return EXISTCHAV("TNN",M->TNN_MANDAT)
	Endif

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA635VLF()
Função de validação de campos

@type   function
@param  nField Numeric Campo a ser validado ( 1 - Filial, 2 - Matrícula )
@sample MDTA635VLF( 1 )
@author Denis
@since  25/10/2007

@return Lógico, Verdadeiro se o campo for válido
/*/
//-------------------------------------------------------------------
Function MDTA635VLF( nField )

	Local nPosFil := 0
	Local nPosMat := 0
	Local nPosNom := 0
	Local nPosNo2 := 0

	Default nField := 1

	If nField == 1
		If !SM0->(DbSeek(cEmpAnt+M->TK8_FILRE))
			MsgStop("Este Código de filial não existe.","ATENÇÃO") //"Este código de filial não existe."###"ATENÇÃO"
			Return .F.
		Endif
	ElseIf nField == 2
		If Type( "aCols" ) == "A"
			nPosFil := aScan( aHeader , { | x | AllTrim( Upper( x[ 2 ] ) ) == "TK8_FILRE" } )
			nPosMat := aScan( aHeader , { | x | AllTrim( Upper( x[ 2 ] ) ) == "TK8_MATRE" } )
			nPosNom := aScan( aHeader , { | x | AllTrim( Upper( x[ 2 ] ) ) == "TK8_NOMRE" } )
			nPosNo2 := aScan( aHeader , { | x | AllTrim( Upper( x[ 2 ] ) ) == "TK8_NOMPAR" } )
			dbSelectArea( "SRA" )
			dbSetOrder( 1 )
			dbSeek( xFilial( "SRA" , aCols[ n , nPosFil ] ) + M->TK8_MATRE )
			If nPosNom > 0
				aCols[ n , nPosNom ] := SRA->RA_NOME
			Else
				aCols[ n , nPosNo2 ] := SRA->RA_NOME
			EndIf
			oGet:oBrowse:Refresh()
		EndIf
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT635INCE
Valida se existe Filial

@type    function
@author  Denis
@since   25/10/2007
@sample  MDT635INCE()
@return  Nil, Sempre Nulo
/*/
//-------------------------------------------------------------------
Function MDT635INCE()

	Local nMan
	Local lUltra   := .F.
	Local aDataVal := {}
	Local lCipatr  := SuperGetMv("MV_NG2NR31",.F.,"2") == "1"

	nDiasAntes := SuperGetMv( "MV_CIPADIA", .T., "10" )

	// Nos eventos de resultado e curso, seria incoerente retornar para sexta caso este sejam em um final de semana.
	// Alterado para considerar o proximo dia util para estes eventos.
	aAdd( aDataVal , { If(lCipatr,STR0064,STR0007) , If(lTipoTNN,TNN->TNN_DTINIC-60,TNN->TNN_ELEICA-15 )    ,.T.})
	aAdd( aDataVal , { STR0009 , If(lTipoTNN,TNN->TNN_DTINIC-56,TNN->TNN_ELEICA-13 )                        ,.T.})
	aAdd( aDataVal , { STR0011 , If(lTipoTNN,TNN->TNN_DTINIC-55,TNN->TNN_ELEICA-12 )                        ,.T.})
	aAdd( aDataVal , { STR0012 , If(lTipoTNN,TNN->TNN_DTINIC-51,TNN->TNN_ELEICA-10 )                        ,.T.})
	aAdd( aDataVal , { STR0014 , If(lTipoTNN,TNN->TNN_DTINIC-46,TNN->TNN_ELEICA-8 )                         ,.T.})
	aAdd( aDataVal , { STR0016 , If(lTipoTNN,TNN->TNN_DTINIC-37,TNN->TNN_ELEICA-3 )                         ,.T.})
	aAdd( aDataVal , { STR0018 , If(lTipoTNN,TNN->TNN_DTINIC-31,TNN->TNN_ELEICA )                           ,.F.})
	aAdd( aDataVal , { STR0020 , If( lTipoTNN , TNN->TNN_DTINIC-30 , TNN->TNN_ELEICA+1 )                    ,.T.})
	aAdd( aDataVal , { STR0022 , If( lTipoTNN , TNN->TNN_DTINIC-29 , TNN->TNN_ELEICA+1 )                    ,.T.})
	aAdd( aDataVal , { STR0024 , If( lTipoTNN , TNN->TNN_DTINIC-16 ,TNN->TNN_ELEICA+8  )                    ,.T.})
	aAdd( aDataVal , { STR0025 , DataValida( If( lTipoTNN , TNN->TNN_DTINIC , TNN->TNN_ELEICA+16 ) )        ,.T.})
	aAdd( aDataVal , { STR0027 , DataValida( If( lTipoTNN , TNN->TNN_DTINIC , TNN->TNN_ELEICA+16 ) )        ,.T.})
	aAdd( aDataVal , { If(lCipatr,STR0066,STR0029) , If( lTipoTNN , TNN->TNN_DTINIC+5  ,TNN->TNN_ELEICA+18 ),.T.})
	If !lTipoTNN
		For nMan := 1 To Len(aDataVal)
			If aDataVal[nMan,2] > TNN->TNN_DTTERM
				lUltra := .T.
			EndIf
		Next nMan
		If lUltra
			fDtManExt(@aDataVal,TNN->TNN_DTINIC,TNN->TNN_DTTERM)
		EndIf
	EndIf

	fGRAVA_TNW({"CIPA","   ",; //Usuario / Cod. Sesmt
			aDataVal[1,2],"00:00",TNN->TNN_DTTERM,"23:59",; // DtInicio / HrInicio / DtFim / HrFim
		nDiasAntes,If(lCipatr,STR0064,STR0007),"1",TNN->TNN_MANDAT,; // Dias Antes / Mensagem / Mostra / Codigo //"EDITAL DE CONVOCAÇÃO PARA INSCRIÇÃO NAS ELEIÇÕES CIPA"
		"2",If(lCipatr,STR0065,STR0008)," "}) // Tipo / Des Tipo / User Fim //"EDITAL DE CONVOCACAO PARA INSCRICAO NAS ELEICOES CIPA"

	fGRAVA_TNW({"CIPA","   ",; //Usuario / Cod. Sesmt
		aDataVal[2,2],"00:00",TNN->TNN_DTTERM,"23:59",; // DtInicio / HrInicio / DtFim / HrFim
		nDiasAntes,STR0009,"1",TNN->TNN_MANDAT,; // Dias Antes / Mensagem / Mostra / Codigo //"DESIGNAÇÃO / FORMAÇÃO DA COMISSÃO ELEITORAL"
		"3",STR0010," "}) // Tipo / Des Tipo / User Fim //"DESIGNACAO / FORMACAO DA COMISSAO ELEITORAL"

	fGRAVA_TNW({"CIPA","   ",; //Usuario / Cod. Sesmt
		aDataVal[3,2],"00:00",TNN->TNN_DTTERM,"23:59",; // DtInicio / HrInicio / DtFim / HrFim
		nDiasAntes,STR0011,"1",TNN->TNN_MANDAT,; // Dias Antes / Mensagem / Mostra / Codigo //"ENVIAR AVISO AO SINDICATO SOBRE INICIO DO PROCESSO ELEITORAL"
		"4",STR0011," "}) // Tipo / Des Tipo / User Fim //"ENVIAR AVISO AO SINDICATO SOBRE INICIO DO PROCESSO ELEITORAL"

	fGRAVA_TNW({"CIPA","   ",; //Usuario / Cod. Sesmt
		aDataVal[4,2],"00:00",TNN->TNN_DTTERM,"23:59",; // DtInicio / HrInicio / DtFim / HrFim
		nDiasAntes,STR0012,"1",TNN->TNN_MANDAT,; // Dias Antes / Mensagem / Mostra / Codigo //"INÍCIO INSCRIÇÕES CANDIDATOS"
		"5",STR0013," "}) // Tipo / Des Tipo / User Fim //"INICIO INSCRICOES CANDIDATOS"

	fGRAVA_TNW({"CIPA","   ",; //Usuario / Cod. Sesmt
		aDataVal[5,2],"00:00",TNN->TNN_DTTERM,"23:59",; // DtInicio / HrInicio / DtFim / HrFim
		nDiasAntes,STR0014,"1",TNN->TNN_MANDAT,; // Dias Antes / Mensagem / Mostra / Codigo //"PUBLICAÇÃO EDITAL DE INSCRIÇÃO DE CANDIDATOS"
		"6",STR0015," "}) // Tipo / Des Tipo / User Fim //"PUBLICACAO EDITAL DE INSCRICAO DE CANDIDATOS"

	fGRAVA_TNW({"CIPA","   ",; //Usuario / Cod. Sesmt
		aDataVal[6,2],"00:00",TNN->TNN_DTTERM,"23:59",; // DtInicio / HrInicio / DtFim / HrFim
		nDiasAntes,STR0016,"1",TNN->TNN_MANDAT,; // Dias Antes / Mensagem / Mostra / Codigo //"TÉRMINO INSCRIÇÕES CANDIDATOS"
		"7",STR0017," "}) // Tipo / Des Tipo / User Fim //"TERMINO INSCRICOES CANDIDATOS"

	fGRAVA_TNW({"CIPA","   ",; //Usuario / Cod. Sesmt
		aDataVal[7,2],"00:00",TNN->TNN_DTTERM,"23:59",; // DtInicio / HrInicio / DtFim / HrFim
		nDiasAntes,STR0018,"1",TNN->TNN_MANDAT,; // Dias Antes / Mensagem / Mostra / Codigo //"REALIZAÇÃO DA ELEIÇÃO (VOTAÇÃO)"
		"8",STR0019," "}) // Tipo / Des Tipo / User Fim //"REALIZACAO DA ELEICAO (VOTACAO)"

	fGRAVA_TNW({"CIPA","   ",; //Usuario / Cod. Sesmt
		aDataVal[8,2],"00:00",TNN->TNN_DTTERM,"23:59",; // DtInicio / HrInicio / DtFim / HrFim
		nDiasAntes,STR0020,"1",TNN->TNN_MANDAT,; // Dias Antes / Mensagem / Mostra / Codigo //"RESULTADO DA ELEIÇÃO - ATA DA ELEIÇÃO"
		"9",STR0021," "}) // Tipo / Des Tipo / User Fim //"RESULTADO DA ELEICAO - ATA DA ELEICAO"

	fGRAVA_TNW({"CIPA","   ",; //Usuario / Cod. Sesmt
		aDataVal[9,2],"00:00",TNN->TNN_DTTERM,"23:59",; // DtInicio / HrInicio / DtFim / HrFim
		nDiasAntes,STR0022,"1",TNN->TNN_MANDAT,; // Dias Antes / Mensagem / Mostra / Codigo //"CURSO PARA CIPEIROS (DATA MÍNIMA)"
		"A",STR0023," "}) // Tipo / Des Tipo / User Fim //"CURSO PARA CIPEIROS (DATA MINIMA)"

	fGRAVA_TNW({"CIPA","   ",; //Usuario / Cod. Sesmt
		aDataVal[10,2],"00:00",TNN->TNN_DTTERM,"23:59",; // DtInicio / HrInicio / DtFim / HrFim
		nDiasAntes,STR0024,"1",TNN->TNN_MANDAT,; // Dias Antes / Mensagem / Mostra / Codigo //"COMUNICAR AO SINDICATO DO RESULTADO E DATA POSSE"
		"B",STR0024," "}) // Tipo / Des Tipo / User Fim //"COMUNICAR AO SINDICATO DO RESULTADO E DATA POSSE"

	fGRAVA_TNW({"CIPA","   ",; //Usuario / Cod. Sesmt
		aDataVal[11,2],"00:00",TNN->TNN_DTTERM,"23:59",; // DtInicio / HrInicio / DtFim / HrFim
		nDiasAntes,STR0025,"1",TNN->TNN_MANDAT,; // Dias Antes / Mensagem / Mostra / Codigo //"REALIZAÇÃO DA POSSE - ATA DE POSSE NOVOS MEMBROS"
		"C",STR0026," "}) // Tipo / Des Tipo / User Fim //"REALIZACAO DA POSSE - ATA DE POSSE NOVOS MEMBROS"

	fGRAVA_TNW({"CIPA","   ",; //Usuario / Cod. Sesmt
		aDataVal[12,2],"00:00",TNN->TNN_DTTERM,"23:59",; // DtInicio / HrInicio / DtFim / HrFim
		nDiasAntes,STR0027,"1",TNN->TNN_MANDAT,; // Dias Antes / Mensagem / Mostra / Codigo //"ORGANIZAÇÃO DO CALENDÁRIO REUNIÕES MENSAIS"
		"D",STR0028," "}) // Tipo / Des Tipo / User Fim //"ORGANIZACAO DO CALENDARIO REUNIOES MENSAIS"

	fGRAVA_TNW({"CIPA","   ",; //Usuario / Cod. Sesmt
		aDataVal[13,2],"00:00",TNN->TNN_DTTERM,"23:59",; // DtInicio / HrInicio / DtFim / HrFim
		nDiasAntes,If(lCipatr,STR0066,STR0029),"1",TNN->TNN_MANDAT,; // Dias Antes / Mensagem / Mostra / Codigo //"REGISTRO DA CIPA DA DRT"
		"E",If(lCipatr,STR0066,STR0029)," "}) // Tipo / Des Tipo / User Fim //"REGISTRO DA CIPA DA DRT"

	If lTipoTNN
		fGRAVA_TNW({"CIPA","   ",; //Usuario / Cod. Sesmt
			TNN->TNN_DTTERM-90,"00:00",TNN->TNN_DTTERM,"23:59",; // DtInicio / HrInicio / DtFim / HrFim
			nDiasAntes,If(lCipatr,STR0067,STR0030),"1",TNN->TNN_MANDAT,; // Dias Antes / Mensagem / Mostra / Codigo //"INCLUIR PROXIMO MANDATO CIPA"
			"1",If(lCipatr,STR0067,STR0030)," "})// Tipo / Des Tipo / User Fim //"INCLUIR PROXIMO MANDATO CIPA"
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT635LIMP
 Limpa campos da getdados

@type    function
@author  Rodrigo Soledade
@since   09/09/2011
@sample  sample
@return  Nil, Sempre Nulo
/*/
//-------------------------------------------------------------------
Function MDT635LIMP()

	Local nPOS, nPOS1, nPOS2, nPOS3
	Local nSizeFil := If((TAMSX3("TK8_FILRE")[1]) < 1,8,(TAMSX3("TK8_FILRE")[1]))

	nPOS	:= aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TK8_NOMPAR"})
	nPOS1	:= aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TK8_TIPPAR"})
	nPOS2	:= aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TK8_FILRE"})
	nPOS3	:= aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TK8_MATRE"})

	If M->TK8_TIPPAR == "1"  .And. Empty(aCols[n,nPOS3])//TK8_MATRE
		aCols[n,nPOS] := Space(40)
	Elseif M->TK8_TIPPAR == "2" .And. !Empty(aCols[n,nPOS3])//TK8_MATRE
		aCols[n,nPOS] := Space(40)
		aCols[n,nPOS2] := Space(nSizeFil)
		aCols[n,nPOS3] := Space(6)
	Elseif M->TK8_TIPPAR == "2"
		aCols[n,nPOS] := Space(40)
		aCols[n,nPOS2] := Space(nSizeFil)//"TK8_FILRE"
	Endif

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT635HABL
Valida campo TK8_TIPPAR

@type    function
@author  Rodrigo Soledade
@since   09/09/2011
@sample  MDT635HABL()
@return  lRet, Lógico, Verdadeiro se o campo for válido
/*/
//-------------------------------------------------------------------
Function MDT635HABL()

	Local nPOS1, lRet := .F.

	nPOS1 := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TK8_TIPPAR"})
	If aCols[n,nPos1] == "1"
		lRet := .F.

	Elseif aCols[n,nPos1] == "2"
		lRet := .T.
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MDT635HABT
Bloqueida campo dependendo do Parametro TK8_TIPPAR

@type    function
@author  Rodrigo Soledade
@since   09/09/2011
@sample  MDT635HABT()
@return  lRet, Lógico, Verdadeiro se o campo deve ser bloqueado
/*/
//-------------------------------------------------------------------
Function MDT635HABT()

	Local lRet := .F.
	Local nPOS1 := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TK8_FILRE"})
	Local nPOS2 := aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TK8_TIPPAR"})

	cFilAnt := aCols[n,nPos1]

	If aCols[n,nPos2] == "1"
		lRet := .T.
	Elseif aCols[n,nPos2] == "2"
		lRet := .F.
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA635LIN
Verifica se o conteudo LIMMIN é memor que o LIMAX

@type    function
@author  Hugo Rizzo Pereira
@since   21/09/2010
@sample  MDTA635LIN()

@return  Lógico, Verdadeiro se as verificações forem válidas
/*/
//-------------------------------------------------------------------
Function MDTA635LIN()

	Local nFilRe	:= aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TK8_FILRE"})
	Local nMatRe	:= aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TK8_MATRE"})
	Local nNomePar	:= aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TK8_NOMPAR"})
	Local nTipPar	:= aSCAN( aHEADER, { |x| Trim( Upper(x[2]) ) == "TK8_TIPPAR"})
	Local lTk8Tippar := NGCADICBASE("TK8_TIPPAR","D","TK8",.F.) .And. NGRetOrdem( "TK8", "TK8_FILIAL+TK8_TIPPAR+TK8_MANDAT+TK8_FILRE+TK8_MATRE+TK8_NOMPAR" ) > 0//Verifica se existe o campo "TK8_TIPPAR" na base.
	Local i , nDelet := 0

	If lTk8Tippar
		If aCols[n][nTipPar] == "1"
			If !aCols[n][Len(aCols[n])]
				If Empty(aCols[n][nFilRe])
					HELP(" ",1,"OBRIGAT",,CHR(13)+STR0038+Space(35),3) //"Filial Resp."
					Return .F.
				Endif
				If Empty(aCols[n][nMatRe])
					HELP(" ",1,"OBRIGAT",,CHR(13)+STR0039+Space(35),3) //"Responsável"
					Return .F.
				Endif
			Endif

			For i := 1 to Len(aCols)
				If !aCols[n][Len(aCols[i])]
					If i <> n .And. !aCols[n][Len(aCols[n])] .And. !aCols[i][Len(aCols[i])]
						If aCols[i][nMatRe] == aCols[n][nMatRe] .And. aCols[i][nFilRe] == aCols[n][nFilRe]
							Help(" ",1,"JAEXISTINF")
							Return .F.
						Endif
					Endif
				Endif
			Next i

			If !Empty(aCols[n][nFilRe]) .And. !Empty(aCols[n][nMatRe]) .And. !aCols[n][Len(aCols[n])]
				dbSelectArea("SRA")
				dbSetOrder(01)
				If !dbSeek(xFilial("SRA",aCols[n][nFilRe])+ aCols[n][nMatRe] )
					Help(" ",1,"REGNOIS")
					Return .F.
				Endif
			Endif
		Else
			If aCols[n][nTipPar] == "2" .And. Empty(aCols[n][nNomePar])
				HELP(" ",1,"OBRIGAT",,CHR(13)+STR0040+Space(35),3) //"Nome Partic."
				Return .F.
			Endif
			For i := 1 to Len(aCols)
				If !aCols[n][Len(aCols[i])] .And. !aCols[i][Len(aCols[i])]
					If i <> n .And. !aCols[n][Len(aCols[n])] .And. !aCOLS[i][Len(aCOLS[i])]
						If aCols[i][nNomePar] == aCols[n][nNomePar] .And. !aCOLS[i][Len(aCOLS[i])]
							Help(" ",1,"JAEXISTINF")
							Return .F.
						Endif
					Endif
				Endif
			Next i
		Endif
	Else
		If (!Empty(aCols[n][nFilRe]) .Or. !Empty(aCols[n][nMatRe])) .And. !aCols[n][Len(aCols[n])]
			If Empty(aCols[n][nFilRe]) .Or. Empty(aCols[n][nMatRe])
				HELP(" ",1,"OBRIGAT")
				Return .F.
			Endif
		Endif

		For i := 1 to Len(aCols)
			If !aCols[n][Len(aCols[i])]
				If i <> n .And. !aCols[n][Len(aCols[n])]
					If aCols[i][nMatRe] == aCols[n][nMatRe] .And. aCols[i][nFilRe] == aCols[n][nFilRe]
						Help(" ",1,"JAEXISTINF")
						Return .F.
					Endif
				Endif
			Endif
		Next i

		If !Empty(aCols[n][nFilRe]) .And. !Empty(aCols[n][nMatRe]) .And. !aCols[n][Len(aCols[n])]
			dbSelectArea("SRA")
			dbSetOrder(01)
			If !dbSeek(xFilial("SRA",aCols[n][nFilRe])+ aCols[n][nMatRe] )
				Help(" ",1,"REGNOIS")
				Return .F.
			Endif
		Endif
	EndIf
	For i := 1 to Len(aCols)
		If	!aCols[i][Len(aCols[i])]
			nDelet++
		EndIf
	Next i
	If lTk8Tippar .And. nOpcA == 1
		If (nDelet == 0 .And. !Empty(M->TNN_COMISS)) .Or. (Len(aCols) == 1 .And.  Empty(aCols[n][nTipPar]) .And. !Empty(M->TNN_COMISS))
			MsgInfo(STR0042,STR0035)//"É necessário informar um responsável da comissão eleitoral." ##"Atenção"
			Return .F.
		EndIf
	ElseIf !lTk8Tippar .And. nOpcA == 1
		If (nDelet == 0 .And. !Empty(M->TNN_COMISS)) .Or. (Len(aCols) == 1 .And.  Empty(aCols[n][nMatRe]) .And. !Empty(M->TNN_COMISS))
			MsgInfo(STR0042,STR0035)//"É necessário informar um responsável da comissão eleitoral." ##"Atenção"
			Return .F.
		EndIf
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Mdt635Ext
Browse do Mandato Extraordinário

@type    function
@author  Pedro Cardoso Furst
@since   04/09/2012
@sample  Mdt635Ext()
@return  Lógico, Sempre Verdadeiro
/*/
//-------------------------------------------------------------------
Function Mdt635Ext()

	Local aArea	:= GetArea()
	Local oldROTINA := aCLONE(aROTINA)
	Local oldCad := cCadastro
	Local cFilter := ""

	Private cMandatoOri := TNN->TNN_MANDAT
	Private cDataini    := TNN->TNN_DTINIC
	Private cDatafim    := TNN->TNN_DTTERM
	Private cTNNDescri  := Space(40)
	Private cTNNCC      := TNN->TNN_CC

	aRotina :=	{ { STR0001,  "AxPesqui"   , 0 , 1    },; //"Pesquisar"
				{   STR0002,  "MDTA111TCD" , 0 , 2    },; //"Visualizar"
				{   STR0003,  "MDTA111TCD" , 0 , 3    },; //"Incluir"
				{   STR0004,  "MDTA111TCD" , 0 , 4    },; //"Alterar"
				{   STR0005,  "MDTA111TCD" , 0 , 5, 3 } } //"Excluir"



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define o cabecalho da tela de atualizacoes                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private cCadastro := OemtoAnsi(STR0006) //"Mandatos"
	Private aCHKDEL := {}, bNGGRAVA

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³aCHKDEL array que verifica a INTEGRIDADE REFERENCIAL na exclu-³
	//³s„o do registro.                                              ³
	//³                                                              ³
	//³1 - Chave de pesquisa                                         ³
	//³2 - Alias de pesquisa                                         ³
	//³3 - Ordem de pesquisa                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCHKDEL := { {'TNN->TNN_MANDAT'    , "TNO", 1},;
					{'TNN->TNN_MANDAT'    , "TNR", 1},;
					{'TNN->TNN_MANDAT'    , "TNV", 1},;
					{'TNN->TNN_MANDAT'    , "TNQ", 1}}

	aCHOICE := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("TNN")
	cFilter := DbFilter()
	Set Filter To  TNN->TNN_CODORI == cMandatoOri
	DbSetOrder(1)
	mBrowse( 6, 1,22,75,"TNN")

	DbSelectArea("TNN")
	If !Empty(cFilter)
		Set Filter to &cFilter
	Else
		Set Filter To
	EndIf

	aROTINA := aCLONE(oldROTINA)
	RestArea(aArea)
	cCadastro := oldCad
	lTipoTNN := .T.
	bNGGRAVA := {}

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TNNEXTRAWH
Função que controla o WHEN dos campos quando for Eleição Extraordinária

@type    function
@author  Pedro C. Furst
@since   04/11/2012
@sample  TNNEXTRAWH('')
@param   cWhenOri, Caractere, Condição de when específica
@return  Lógico, Verdadeiro se o campo pode ser modificado
/*/
//-------------------------------------------------------------------
Function TNNEXTRAWH(cWhenOri)
Return If(Type("lTipoTNN") == "L",lTipoTNN, If(Empty(cWhenOri),.T.,&cWhenOri))

//---------------------------------------------------------------------
/*/{Protheus.doc} fDtManExt
Retorna as datas corretas para os eventos.

@type   function
@author Jackson Machado
@since  27/11/2012
@sample fDtManExt({'21/02/11','Posse'},'20/02/11')

@param 	aDatas, Array, Datas a serem corrigidas
@param  dDtInicio, Data, Início do mandato
@param  dDtTermino, Data, Termino do mandato

@return Nil Sempre Nulo
/*/
//---------------------------------------------------------------------
Static Function fDtManExt( aDatas , dDtInicio , dDtTermino )

	Local nRet   := 0
	Local nDatas := 0
	Local nOk    := 0
	Local cVar
	Local oDlg, oPanel
	Local oBtn, oFonte

	nRet := Aviso( UPPER( STR0035 ) , ;//"ATENÇÃO"
					STR0045 , ;//"Uma ou mais datas dos eventos podem ultrapassar a data de termino. Deseja utilizar a data de termino como referência ou informar as datas correspondentes?"
					{ STR0046 , STR0047 };//"Referência"###"Informar"
				)

	If nRet == 2
		DEFINE MSDIALOG oDlg TITLE STR0048 + DTOC( dDtTermino ) From 3 , 0 to 50  +( 25 * ( Len( aDatas ) - 1 ) ) + 40 , 530 PIXEL//"Informe as datas correspondentes. Data de Termino: "
		oDlg:lEscClose := .F.

			oPanel := TPanel():New( , , , oDlg , , , , , , , )
				oPanel:Align := CONTROL_ALIGN_ALLCLIENT

			oFonte := TFont():New( /*cName*/ , /*uPar2*/ , /*nHeight*/ , /*uPar4*/ , .T. , /*uPar6*/ , /*uPar7*/ ,;
				/*uPar8*/ , /*uPar9*/ , /*lUnderline*/ , /*lItalic*/ )
			For nDatas := 1 To Len( aDatas )

				cVar	:= "dData" + cValToChar( nDatas )
				&(cVar)	:= aDatas[ nDatas , 2 ]

				TSay():New( 12 * nDatas , 10  , &( "{|| '"+aDatas[nDatas,1]+"' }" ) , oPanel , , If( aDatas[ nDatas , 2 ] > dDtTermino , oFonte , ) , ;
					.F. , .F. , .F. , .T. , If( aDatas[ nDatas , 2 ] > dDtTermino, CLR_RED , ) , , , )

				TGet():New( ( 12 * nDatas ) - 2 , 210 , &( "{|u| If( PCount() > 0 , "+cVar+" := u , "+cVar+" ) }" ), oPanel , 048 , 008 ,;
					"" , {|| } , , , , , , .T. , "" , , &( "{|| "+cValToChar( aDatas[ nDatas , 3 ] )+" }" ) , .F. , .F. , , .F. , .F. ,;
					"" , cVar , , , , .T. )

			Next nDatas

			oBtn  := SButton():New( ( ( 50 + ( 25 * ( Len( aDatas ) - 1 ) ) + 40 ) / 2 ) - 15 , 235 , 1 , ;
					{|| nOk := 1 , If( fValDatas( aDatas , dDtInicio , dDtTermino ) , oDlg:End() , nOk := 0 ) } , oPanel , .T. , /*cMsg*/ , /*bWhen*/ )

		ACTIVATE MSDIALOG oDlg CENTER

		If nOk == 1
			For nDatas := 1 To Len( aDatas )
				aDatas[ nDatas , 2 ] := &( "dData"+cValToChar( nDatas ) )
			next nDatas
		EndIf
	EndIf

	If nRet <> 2 .Or. nOk <> 1
		If nRet == 2 .And. nOk <> 1
			MsgInfo( STR0049 )//"Como não foram definidas novas datas para os eventos, aqueles que ultrapassarem a data de termino tomaram esta como referência."
		EndIf
		For nDatas := 1 To Len( aDatas )
			If aDatas[ nDatas , 2 ] > dDtTermino
				aDatas[ nDatas , 2 ] := dDtTermino
			EndIf
		Next nDatas
	EndIF

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fValDatas
Valida as datas de evento

@type   function
@author Jackson Machado
@since  27/11/2012
@sample fValDatas({'21/02/11','Posse'},'20/02/11')

@param 	aDatas, Array, Datas a serem corrigidas
@param  dDtInicio, Data, Início do mandato
@param  dDtTermino, Data, Termino do mandato

@return lRet, Lógico, Verdadeiro se as datas forem válidas
/*/
//---------------------------------------------------------------------
Static Function fValDatas( aDatas , dDtInicio , dDtTermino )

	Local nDatas := 0
	Local lRet   := .T.
	Local lMenor := .F.
	Local lMaior := .F.
	Local lEmpty := .F.
	Local lDatas := .F.
	Local aDtVal := {}

	For nDatas := 1 To Len( aDatas )
		If !lDatas
			If Len( aDatas ) >= nDatas+1
				lDatas := &( "dData" + cValToChar( nDatas ) ) > &( "dData" + cValToChar( nDatas + 1 ) )
				If lDatas
					aAdd( aDtVal , { aDatas[ nDatas , 1 ]   , &( "dData" + cValToChar( nDatas ) )     } )
					aAdd( aDtVal , { aDatas[ nDatas+1 , 1 ] , &( "dData" + cValToChar( nDatas + 1 ) ) } )
				EndIf
			EndIf
		EndIf
		If !lEmpty
			lEmpty := Empty(&( "dData" + cValToChar( nDatas ) ) )
		EndIf
		If !lMaior
			lMaior := &( "dData" + cValToChar( nDatas ) ) > dDtTermino
		EndIf
		If !lMenor
			lMenor := &( "dData" + cValToChar( nDatas ) ) < dDtInicio
		EndIf
	Next nDatas

	If lDatas
		ShowHelpDlg( UPPER( STR0035 ) , { STR0050 + AllTrim( aDtVal[ 1 , 1 ] ) + " ("+DTOC( aDtVal[ 1 , 2 ] ) + ") " + STR0051 + ;//"Atenção"###"A data do evento "###"não pode ser superior a data do evento "
			AllTrim( aDtVal[ 2 , 1 ] ) + " ("+DTOC( aDtVal[ 2 , 2 ] ) + ")." } , 2 , { STR0052 + AllTrim( aDtVal[ 1 , 1 ] ) + "." } , 2 )//"Informe uma data menor para o evento "
		lRet := .F.
	EndIf

	If lMaior .And. lRet
		ShowHelpDlg( UPPER( STR0035 ) , { STR0053 } , 2 , { STR0054 + DTOC( dDtTermino ) + "." } , 2 )//"Atenção"###"Uma ou mais datas superam a data de termino do mandato."###"Informe datas inferiores a "
		lRet := .F.
	EndIf

	If lMenor .And. lRet
		ShowHelpDlg( UPPER( STR0035 ) , { STR0055 } , 2 , { STR0056 + DTOC( dDtInicio ) + "." } , 2 )//"Atenção"###"Uma ou mais datas são inferiores a data de início do mandato."###"Informe datas superiores a "
		lRet := .F.
	EndIf

	If lEmpty .And. lRet
		ShowHelpDlg(UPPER(STR0035),{STR0057},2,{STR0044},2)//"Atenção"###"Uma ou mais datas estão em branco."###"Informe todas as datas dos eventos."
		lRet := .F.
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT635Data()
Valida Data Inicio e Data Termino do Mandato.

@type   function
@author Rodrigo Soledade
@sample MDT635Data(.F.)
@since  29/09/2013
@return Lógico, Falso se a data de término for menor que a data de início
/*/
//---------------------------------------------------------------------
Function MDT635Data(lValid)

	If lValid
		If M->TNN_DTINIC > M->TNN_DTTERM .And. !Empty(M->TNN_DTTERM)
			MsgStop("A Data Inicio. não pode ser maior que a Data Termino.")
			Return .F.
		EndIf
	Else
		If M->TNN_DTINIC > M->TNN_DTTERM .And. !Empty(M->TNN_DTTERM)
			MsgStop(STR0059) //"A Data Termino não pode ser menor que a Data Inicio."
			Return .F.
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDT635VSRA()
Valida Visualização da SRA

@type   function
@author Jackson Machado
@since  10/05/2016
@sample MDT635VSRA()
@return lReturn, Lógico, Verdadeiro se usuário pode visualizar
/*/
//---------------------------------------------------------------------
Function MDT635VSRA()

	Local lReturn	:= .T.
	Local lAccess 	:= .F.
	Local nPosFil	:= If( Type( "aHeader" ) == "A" , aScan( aHeader , { | x | AllTrim( Upper( x[ 2 ] ) ) == "TK8_FILRE" } ) , 0 )
	Local aFilAcs	:= FwLoadSM0()
	Local cFilVld 	:= ""
	Local cEmpVld 	:= cEmpAnt
	Local nPosFAcs	:= SM0_USEROK	// Verifica se o usuario possui acesso a filial

	//Verifica se utilização é pela GetDados e que existe a Filial no aHeader
	If nPosFil > 0
		//Localiza o Usuário
		cFilVld := aCols[ n , nPosFil ]
		lAccess := aScan( aFilAcs , { | x | AllTrim( x[ 1 ] ) == cEmpVld .And. AllTrim( x[ 2 ] ) == AllTrim( cFilVld ) .And. x[ nPosFAcs ] } ) > 0

		If lAccess
			AxVisual( "SRA" , SRA->( Recno() ) , 2 )
		Else
			MsgInfo( STR0069 )//"Usuário sem permissão para visualizar registros desta filial."
			lReturn := .F.
		EndIf
	EndIf

Return lReturn
