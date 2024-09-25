#INCLUDE "SGAA495.ch"
#INCLUDE "Protheus.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} SGAA495
Programa para cadastro de Rotas de Pontos de Coleta

@author  Gabriel Augusto Werlich
@since   14/02/2014
@version P11
@return  Nil
/*/
//---------------------------------------------------------------------
Function SGAA495()

	Local aNGBEGINPRM := NGBEGINPRM()

	Private aRotina := MenuDef()

	Private cCadastro := OemtoAnsi(STR0001) //"Rotas de Coleta"

	//Verifica se o UPDSGA38 já foi rodado
	If !NGCADICBASE("TH1_CODROT","A","TH1",.F.)
		If !NGINCOMPDIC("UPDSGA38","TPNBEI")
			Return .F.
		Endif
	EndIf

	dbSelectArea("TH1")
	dbSetOrder(1)
	mBrowse(6, 1, 22, 75, "TH1")

	NGRETURNPRM(aNGBEGINPRM)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SGA495CAD
Programa para cadastro de Rotas de Pontos de Coleta

@author  Gabriel Augusto Werlich
@since   14/02/2014
@version P11
@return  Nil
/*/
//---------------------------------------------------------------------
Function SGA495CAD(cAlias, nRecno, nOpcx)

	Local lOK := .f.
	Local cTitulo := cCadastro  // Titulo da janela

	Local oDlg495, oPanelTop
	Local oPnlPai, oPanelDown, oPanelLeft,oPanelRght
	Local oBtnInc
	Local cGetWhlPt := ""

	Local aColsPC := {}
	Local aHeaderPC := {}

	Local aSize := {}

	Local aDbfPC  := {}
	Local aFldMrk := {}
	Local oTempPC

	Local nTamDepto  := TAMSX3("TDB_DEPTO")[1]
	Local nTamCodigo := TAMSX3("TDB_CODIGO")[1]
	Local nTamDescri := TAMSX3("TDB_DESCRI")[1]

	Private lClickedR := .F.
	Private lClickedL := .F.

	Private lInverte := .F.
	Private cMarca := GetMark()

	aSize := MsAdvSize(,.f.,430)

	Private cTRBXR   := GetNextAlias()
	Private cAliasPC := GetNextAlias()
	
	// Cria tabela temporaria Pontos de Coleta (Right)
	aAdd(aDbfPC,{ "TRB_OK"    , "C", 02, 0 })
	aAdd(aDbfPC,{ "TRB_DEPTO" , "C", nTamDepto,  0 })
	aAdd(aDbfPC,{ "TRB_CODIGO", "C", nTamCodigo, 0 })
	aAdd(aDbfPC,{ "TRB_DESCRI", "C", nTamDescri, 0 })

	oTempPC := FWTemporaryTable():New( cAliasPC, aDbfPC )
	oTempPC:AddIndex( "1", {"TRB_CODIGO"} )
	oTempPC:AddIndex( "2", {"TRB_DESCRI"} )
	oTempPC:AddIndex( "3", {"TRB_OK"} )
	oTempPC:Create()

	aadd(aFldMrk, { RetTitle("TDB_CODIGO"), "TRB_CODIGO", "C", nTamCodigo })
	aadd(aFldMrk, { RetTitle("TDB_DESCRI"), "TRB_DESCRI", "C", nTamDescri })

	Define MsDialog oDlg495 Title OemToAnsi(cTitulo) From aSize[7],0 To aSize[6],aSize[5];
		Style nOr(WS_VISIBLE, WS_MAXIMIZEBOX, WS_POPUP) Of oMainWnd Pixel

	oPnlPai := TPanel():New(0,0,,oDlg495,,,,,,0,0,.F.,.F.)
	oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

	dbSelectArea("TH1")
	RegToMemory("TH1",(nOpcx == 3))

	oPanelTop:= MsMGet():New("TH1",nRecno,nOpcx,,,,,,,,,,,oPnlPai,,,.F.)
	oPanelTop:oBox:Align := CONTROL_ALIGN_TOP

	oPanelDown := TPanel():New(0,0,,oPnlPai,,,,,,0,0,.F.,.F.)
	oPanelDown:Align := CONTROL_ALIGN_ALLCLIENT

	oPanelLeft := TPanel():New(00,00,,oPanelDown,,,,,RGB(67,70,87),12,12,.F.,.F.)
	oPanelLeft:Align := CONTROL_ALIGN_LEFT

	oPanelRght := TPanel():New(0,0,,oPanelDown,,,,,,0,0,.F.,.F.)
	oPanelRght:Align := CONTROL_ALIGN_ALLCLIENT

	aColsPC   := {}
	aHeaderPC := {}

	//Preenche a GetDados com aCols e aHeader
	cGetWhlPt := "TH2->TH2_FILIAL == '" + xFilial("TH2") + "' .AND. TH2->TH2_CODROT = '" + TH1->TH1_CODROT + "'"
	FillGetDados( nOpcx, "TH2", 1, "TH2->TH2_CODROT", {|| }, {|| .T.},{"TH2_CODROT"},,,,;
		{|| NGMontaAcols("TH2", TH1->TH1_CODROT ,cGetWhlPt)},,aHeaderPC,aColsPC)

	If Empty(aColsPC) .Or. nOpcx == 3
	   SGA495INIT(@aHeaderPC, @aColsPC)
	Endif

	//Getdados de pontos de coleta da tabela TH2
	oGet495 := MsNewGetDados():New(0,0,0,0,IIF(!Inclui.And.!Altera,0,GD_INSERT+GD_UPDATE+GD_DELETE),;
		"SGA495LOK()","SGA495LOK()",,,,9999,,,"SG495DelOk()",oPanelRght, aHeaderPC, aColsPC)
	oGet495:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGet495:oBrowse:Refresh()

	oGet495:ForceRefresh()

	If nOpcx == 3 .or. nOpcx == 4
		oBtnInc  := TBtnBmp():NewBar("ng_ico_entrada","ng_ico_entrada",,,,;
			{|| SelectPC(aFldMrk,oTempPC) },,oPanelLeft,,,STR0030,,,,,"") //"Incluir Pontos de Coleta"
		oBtnInc:Align  := CONTROL_ALIGN_TOP

		oBtnDel  := TBtnBmp():NewBar("ng_ico_saida","ng_ico_saida",,,,{|| SGA495DEL()  },,oPanelLeft,,,STR0040,,,,,"") //"Excluir Pontos de Coleta"
		oBtnDel:Align  := CONTROL_ALIGN_TOP
	Endif

	Activate Dialog oDlg495 On Init (EnchoiceBar(oDlg495,{|| lOk:= .T.,If(SGA495VLOK(),oDlg495:End(),lOk := .f.)},{|| lOk := .F., oDlg495:End()})) Centered

	//Se linha estiver Ok, chama a função para gravação das informações
	If lOk
		SGA495GRAV(nOpcx)
	Endif

	oTempPC:Delete()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SGA495LOK
Valida linha da getdados.

@author  Gabriel Augusto Werlich
@since   14/02/2014
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Function SGA495LOK()

	Local nPosCodLoc := GdFieldPos("TH2_CODLOC", oGet495:aHeader)
	Local nPosCodPnt := GdFieldPos("TH2_CODPTO", oGet495:aHeader)
	Local nLine

	If !oGet495:aCols[oGet495:nAt][Len(oGet495:aCols[oGet495:nAt])]

		//Verifica campo obrigatório Localizacao
		If Empty(oGet495:aCols[oGet495:nAt][nPosCodLoc])
			Help(1," ","OBRIGAT2",,oGet495:aHeader[nPosCodLoc][1],3,0)
			Return .F.
		Endif

		//Verifica campo obrigatório Ponto de Coleta
		If Empty(oGet495:aCols[oGet495:nAt][nPosCodPnt])
			Help(1," ","OBRIGAT2",,oGet495:aHeader[nPosCodPnt][1],3,0)
			Return .F.
		Endif

		//Verifica em todas as linhas se já existe a mesma informação
		For nLine := 1 To Len(oGet495:aCols)
			If nLine <> oGet495:nAt .and. !oGet495:aCols[oGet495:nAt][Len(oGet495:aCols[oGet495:nAt])]
				If	!oGet495:aCols[nLine][Len(oGet495:aCols[nLine])] 								.And. ;
					oGet495:aCols[nLine][nPosCodLoc] == oGet495:aCols[oGet495:nAt][nPosCodLoc]	.And. ;
					oGet495:aCols[nLine][nPosCodPnt] == oGet495:aCols[oGet495:nAt][nPosCodPnt]
					Help(" ",1,"JAEXISTINF")
					Return .F.
				Endif
			EndIf
		Next

	Endif

	PutFileInEof("TH2")

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SGA495GRAV
Faz a gravação da parte de cima da tela(tabela:TH1), e a parte de baixo(MsNewGetDados)(tabela:TH2)

@author  Gabriel Augusto Werlich
@since   14/02/2014
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Function SGA495GRAV(nOpcx)

	Local nFieldTH2, cFldOri, cFldDest
	Local lFoundX, nCampo, lFoundY, nLine
	Local nPosCodLoc := GdFieldPos("TH2_CODLOC", oGet495:aHeader)
	Local nPosCodPnt := GdFieldPos("TH2_CODPTO", oGet495:aHeader)
	Local nPosOrdem  := GdFieldPos("TH2_CODORD", oGet495:aHeader)
	Local nPosRecno  := GdFieldPos("TH2_REC_WT", oGet495:aHeader)

	If Inclui .Or. Altera

		dbSelectArea("TH1")
		dbSetOrder(1)
		lFoundX := dbSeek(xFilial("TH1")+M->TH1_CODROT)

		RecLock("TH1",!lFoundX)

		//Grava informações da tabela de Rota
		For nCampo := 1 To TH1->(FCount())
			If "_FILIAL" $ Upper(FieldName(nCampo))
				cFldDest := "xFilial('TH1')"
			Else
				cFldDest := "M->" + FieldName(nCampo)
			EndIf
			cFldOri  := "TH1->" + FieldName(nCampo)
			Replace &(cFldOri) with &(cFldDest)
		Next nCampo

		MsUnlock("TH1")

	ElseIf nOpcx == 5

		//Deleta informações da tabela de Rota
		For nLine := 1 to Len(oGet495:aCols)
			dbSelectArea("TH1")
			dbSetOrder(1)
			If dbSeek(xFilial("TH1")+M->TH1_CODROT)
				RecLock("TH1",.F.)
				dbDelete()
				MsUnlock("TH1")
			Endif
		Next nLine

	Endif

	dbSelectArea('TH1')
	If Inclui .Or. Altera

		dbSelectArea("TH2")
		dbSetOrder(1)
		dbSeek(xFilial("TH2")+M->TH1_CODROT)
		While !Eof() .and. xFilial("TH2")+M->TH1_CODROT == TH2->TH2_FILIAL+TH2->TH2_CODROT

			//Verifica se existe algum registro na GetDados e armazena a o numero da linha na variavel
			nChave := aSCAN( oGet495:aCols, { |x| x[nPosRecno] == TH2->(Recno()) })

			If nChave == 0
				RecLock("TH2",.F.)
				dbDelete()
				MsUnLock("TH2")
			EndIf
			dbSelectArea("TH2")
			dbSkip()
		End

		//Grava informações da tabela de Listagem de Pontos de Coleta
		For nLine := 1 to Len(oGet495:aCols)

			//Se a linha atual não estiver deletada e o campo de localização não estiver vazio
			If !oGet495:aCols[nLine][Len(oGet495:aCols[nLine])] .and. !Empty(oGet495:aCols[nLine][nPosCodLoc])

				dbSelectArea("TH2")
				dbSetOrder(1)
				dbGoTop()

				If (lFoundY := !Empty(oGet495:aCols[nLine][nPosRecno])) //Verifica se o item foi incluido neste processo
					dbGoTo(oGet495:aCols[nLine][nPosRecno])
				EndIf

				RecLock("TH2", !lFoundY)

				//Faz a gravação de todos os registros que estiverem na GetDados, para a tabela de Listagem de Pontos de Coleta
				For nCampo := 1 To TH2->(FCount())
					nFieldTH2 := aSCAN( oGet495:aHeader, { |x| Trim( Upper(x[2]) ) == FieldName(nCampo) })

					If nFieldTH2 > 0
						cFldDest := oGet495:aCols[nLine][nFieldTH2]
						cFldOri := "TH2->" + FieldName(nCampo)
						Replace &cFldOri. with cFldDest
					EndIf
				Next nCampo

				TH2->TH2_FILIAL := xFilial("TH2")
			   	TH2->TH2_CODROT := M->TH1_CODROT

			   	MsUnLock("TH2")
			//Se o código de localização estiver vazio
		   Elseif !Empty(oGet495:aCols[nLine][nPosCodLoc])
				dbSelectArea("TH2")
				dbSetOrder(1)
				If dbSeek(xFilial("TH2")+M->TH1_CODROT+oGet495:aCols[nLine][nPosOrdem]+;
							oGet495:aCols[nLine][nPosCodLoc]+oGet495:aCols[nLine][nPosCodPnt])
					RecLock("TH2",.F.)
					dbDelete()
					MsUnlock("TH2")
				Endif
			EndIf
		Next nLine

	//Se foi exclusão
	ElseIf nOpcx == 5

		//Deleta todos os registros da tabela de Listagem
		For nLine := 1 to Len(oGet495:aCols)
			dbSelectArea("TH2")
			dbSetOrder(1)
			If dbSeek(xFilial("TH2")+M->TH1_CODROT+oGet495:aCols[nLine][nPosOrdem]+;
						oGet495:aCols[nLine][nPosCodLoc]+oGet495:aCols[nLine][nPosCodPnt])
				RecLock("TH2",.F.)
				dbDelete()
				MsUnlock("TH2")
			Endif
		Next nLine

	EndIf

	dbSelectArea('TH2')

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de Menu Funcional.

@author  Gabriel Augusto Werlich
@since   14/02/2014
@version P11
@parameters

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
@return  Array com opcoes da rotina. (aRotina)
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := { { STR0004, "AxPesqui" , 0, 1},;   //"Pesquisar"
	                   { STR0005, "SGA495CAD", 0, 2},;   //"Visualizar"
	                   { STR0006, "SGA495CAD", 0, 3},;   //"Incluir"
	                   { STR0007, "SGA495CAD", 0, 4},;   //"Alterar"
	                   { STR0008, "SGA495CAD", 0, 5, 3} }//"Excluir"

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} SGA495FPTO
Verifica se o Código de Localização(TH2_CODLOC) da MsNewGetDados é
igual ao Código de Localização da tabela TDB->TDB_DEPTO
SXB

@author  Gabriel Augusto Werlich
@since   14/02/2014
@version P11
@return
/*/
//---------------------------------------------------------------------
Function SGA495FPTO()

	Local nPosLoc := GdFieldPos("TH2_CODLOC", oGet495:aHeader)

Return nPosLoc > 0 .And. oGet495:aCols[oGet495:nAt][nPosLoc] == TDB->TDB_DEPTO

//---------------------------------------------------------------------
/*/{Protheus.doc} SGA495WHLC
Se o campo Código de Localização (TH2_CODLOC) não for preenchido
trava o campo do Código de Ponto de Coleta (TH2_CODPTO)

SX3_WHEN
@author  Gabriel Augusto Werlich
@since   14/02/2014
@version P11
@return
/*/
//---------------------------------------------------------------------
Function SGA495WHLC()

	Local nCodLoc	:= GdFieldPos("TH2_CODLOC", oGet495:aHeader)

Return nCodLoc > 0 .And. !Empty(oGet495:aCols[oGet495:nAt][nCodLoc])

//---------------------------------------------------------------------
/*/{Protheus.doc} SGA495VLOK
Validação dos campos da MsNewGetDados (Tudo Ok).

@author  Gabriel Augusto Werlich
@since   14/02/2014
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Function SGA495VLOK()

	If Empty(M->TH1_CODROT)
		ShowHelpDlg(STR0041,{STR0042},2,{STR0045},2) //"Atenção" ; "Não é possivel confirmar a rota" ; ""
		Return .F.
	Endif

	//Verifica se linha está ok
	If !SGA495LOK()
		Return .F.
	EndIf

	//Verifica se existe ao menos uma linha válida para salvar a rota
	If aScan(oGet495:aCols, {|x| !x[Len(x)] } ) == 0
		ShowHelpDlg(STR0041,{STR0042},2,{STR0043},2) //"Atenção" ; "Não é possivel confirmar a rota" ; "Insira ao menos um Ponto de Coleta para confirmar a Rota"
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SGA495VPCL
Validação do campo da MsNewGetDados (TH2_CODPTO), não permite que seja
informado um ponto de coleta que não esteja relacionado à uma localização.
SX3_VALID
@author  Gabriel Augusto Werlich
@since   14/02/2014
@version P11
@return  ExistCpo('TDB',cCodLoc+M->TH2_CODPTO)
/*/
//---------------------------------------------------------------------
Function SGA495VPCL()

	Local nPosLoc := GdFieldPos("TH2_CODLOC", oGet495:aHeader)
	Local cCodLoc

	If nPosLoc == 0
		Return .F.
	Endif

	cCodLoc := oGet495:aCols[oGet495:nAt][nPosLoc]

Return ExistCpo('TDB',cCodLoc+M->TH2_CODPTO)

//---------------------------------------------------------------------
/*/{Protheus.doc} SGA495VLOC
Validação do campo da MsNewGetDados (TH2_CODLOC), não permite que seja
informado uma localização que não exista.
SX3_VALID
@author  Gabriel Augusto Werlich
@since   14/02/2014
@version P11
@return  ExistCpo('TAF','001'+M->TH2_CODLOC,2)
/*/
//---------------------------------------------------------------------
Function SGA495VLOC()
Return ExistCpo('TAF','001'+M->TH2_CODLOC,2)

//---------------------------------------------------------------------
/*/{Protheus.doc} SGA495GTPC
Função para filtrar o código de localização que está na memória de GetDados.
SX7_CHAVE
@author  Gabriel Augusto Werlich
@since   27/02/2014
@version P11
@return  xFilial('TDB')+cCodLoc+M->TH2_CODPTO
/*/
//---------------------------------------------------------------------
Function SGA495GTPC()

	Local nPosLoc := GdFieldPos("TH2_CODLOC", oGet495:aHeader)
	Local cCodLoc
	Local lRet := .T.

	If nPosLoc == 0
		lRet := .F.
	Endif

	cCodLoc := oGet495:aCols[oGet495:nAt][nPosLoc]

Return xFilial('TDB')+cCodLoc+M->TH2_CODPTO

//---------------------------------------------------------------------
/*/{Protheus.doc} SG495SLPC
Cria a tela para incluir pontos de coleta na MsNewGetDados
a função é chamada pelo botão "Incluir Pontos de Coleta".

@param aFldMark, array, campos para montar o markbrowse

@author  Gabriel Augusto Werlich
@since   05/03/2014
@return Nil
/*/
//---------------------------------------------------------------------
Static Function SG495SLPC(aFldMrk,oTempPC)

	Local oDlgPesq, oPnlGeral
	Local oMark, oBrwList, lOk
	Local aColumn := {}
	Local nCol
	Local aTRB	:= {}
	Local cPesquisar := Space( 200 )  

	Local aSize := MsAdvSize(,.f.,430)

	Processa({|| LoadMarkB(cAliasPC, cMarca)},STR0044,STR0044,.T.) //"Processando Pontos de Coleta"

	Define MsDialog oDlgPesq Title STR0031 From aSize[7],0 To aSize[6],aSize[5];
		Style nOr(WS_VISIBLE, WS_MAXIMIZEBOX, WS_POPUP) Of oMainWnd Pixel

		//Define painel principal
		oPnlGeral := TPanel():New(0,0,,oDlgPesq,,,,,,,,.F.,.F.)
		oPnlGeral:Align := CONTROL_ALIGN_ALLCLIENT

		//Panel Esquerdo
		oPnlLeft := TPanel():New(,,,oPnlGeral,,,,,,aSize[5]/4,0, .F., .F. )
		oPnlLeft:Align := CONTROL_ALIGN_LEFT

		dbSelectArea("TAF")
		dbGoTop()

		Aadd(aColumn, {RetTitle("TAF_NIVSUP"), {|| TAF->TAF_NIVSUP}, "C", "@!", 1,;
			TAMSX3("TAF_NIVSUP")[1], 0, .F. })
		Aadd(aColumn, {RetTitle("TAF_CODNIV"), {|| TAF->TAF_CODNIV}, "C", "@!", 1,;
			TAMSX3("TAF_CODNIV")[1], 0, .F. })
		Aadd(aColumn, {RetTitle("TAF_NOMNIV"), {|| TAF->TAF_NOMNIV}, "C", "@!", 1,;
			TAMSX3("TAF_NOMNIV")[1], 0, .F. })

		oBrwList := FWBrowse():New(oPnlLeft)
		oBrwList:SetDataTable(.T.)
		oBrwList:SetAlias("TAF")
		For nCol := 1 To Len(aColumn)
			oBrwList:AddColumn( aColumn[nCol] )
		Next nCol
		oBrwList:SetDescription(STR0034)
		oBrwList:SetSeek()
		oBrwList:Activate()

		oPnlRight := TPanel():New(,,,oPnlGeral,,,,,RGB(87,11,67),aSize[5]/4,0, .F., .F. )
		oPnlRight:Align := CONTROL_ALIGN_RIGHT

		oPanel := TPanel():New( 0, 0, , oPnlRight, , .T., .F., , , 0, 040, .T., .F. )
		oPanel:Align := CONTROL_ALIGN_TOP

		aAdd( aTRB , { "TRB_OK"     , NIL , " "	  , } )
		aAdd( aTRB , { "TRB_CODIGO" , NIL , STR0033, } ) //"Código"
		aAdd( aTRB , { "TRB_DESCRI" , NIL , STR0003, } ) //"Descriçao"

		oPesquisar := TGet():New( 024, 016, { | u | If( PCount() > 0, cPesquisar := u, cPesquisar ) }, oPanel, 180, 010, "", { | | .T. } , ;
										CLR_BLACK, CLR_WHITE, , .F., , .T. /*lPixel*/, , .F., { | | .T. }/*bWhen*/, .F., .F., , .F. /*lReadOnly*/, ;
										.F., "", "cPesquisar", , , , .F. /*lHasButton*/ )

		oBtnPesq := TButton():New( 024 , 200 , "Pesquisar" , oPanel , { | | fPesqTRB( cAliasPC, oMark, cPesquisar ) } , 049 , 012 , , , .F. , .T. , .F. , ;
							, .F., , , .F. )
		
		oMark := MsSelect():New( cAliasPC, "TRB_OK", , aTRB, @lInverte, @cMarca, { 45, 5,  254, 281 }, , , oPnlRight )
				oMark:oBrowse:lHasMark		:= .T.
				oMark:oBrowse:lCanAllMark	:= .T.
				oMark:oBrowse:bAllMark		:= ( {|| fAllMark( oMark, cMarca, cAliasPC, "TRB_OK" ) } ) // Ação ao marcar tudo
				oMark:oBrowse:Align			:= CONTROL_ALIGN_ALLCLIENT

		oBrwList:bChange := {|| LoadPtoC(cAliasPC, oMark)}

	Activate MsDialog oDlgPesq ON INIT EnchoiceBar(oDlgPesq,{||lOk := .T., oDlgPesq:End()  },{||lOk := .F.,oDlgPesq:End()},.f.,) Centered

	dbSelectArea(cAliasPC)
	Set Filter To

	If lOk
		GravaAcols()
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} LoadPtoC
Carrega Pontos de Coleta de acordo com suas respectivas localizações.

@author  Gabriel Augusto Werlich
@since   14/02/2014
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function LoadPtoC(cAliasPC, oMark)

	dbSelectArea(cAliasPC)
	Set Filter To
	Set Filter To TAF->TAF_CODNIV == ((cAliasPC)->TRB_DEPTO)

	dbGoTop()
	oMark:oBrowse:Refresh()
	oMark:oBrowse:Refresh()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} LoadMarkB
Carrega MarkBrowse

@author  Gabriel Augusto Werlich
@since   14/02/2014
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function LoadMarkB(cAliasPC, cMarca)

	ProcRegua(0)

	If !lClickedR

		dbSelectArea("TDB")
		dbSetOrder(1)
		dbSeek(xFilial("TDB"))
		While !Eof() .AND. xFilial("TDB") == TDB->TDB_FILIAL

			IncProc()

			dbSelectArea(cAliasPC)
			dbSetOrder(1)
			RecLock((cAliasPC),.T.)
			(cAliasPC)->TRB_CODIGO := TDB->TDB_CODIGO
			(cAliasPC)->TRB_DESCRI := TDB->TDB_DESCRI
			(cAliasPC)->TRB_DEPTO  := TDB->TDB_DEPTO

			If IsSelected((cAliasPC)->TRB_DEPTO, (cAliasPC)->TRB_CODIGO)
				(cAliasPC)->TRB_OK := cMarca
			EndIf

			(cAliasPC)->(MsUnlock())

			dbSelectArea("TDB")
			dbSkip()
		End

	Else

		dbSelectArea(cAliasPC)
		dbSetOrder(1)
		dbGoTop()
		While !Eof()

			IncProc()

			Reclock(cAliasPC, .F.)
			If IsSelected((cAliasPC)->TRB_DEPTO, (cAliasPC)->TRB_CODIGO)
				(cAliasPC)->TRB_OK := cMarca
			Else
				(cAliasPC)->TRB_OK := Space(2)
			EndIf
				(cAliasPC)->(MsUnlock())
			dbSelectArea(cAliasPC)
			(cAliasPC)->(dbSkip())
		End

	EndIf

	lClickedR := .T.
	oGet495:ForceRefresh()

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} IsSelected
Pesquisa se o ponto de coleta está na getdados
@author  Gabriel Augusto Werlich
@since   14/02/2014
@version P11
@return
/*/
//---------------------------------------------------------------------
Static Function IsSelected(cDepto, cPontoClt)

	Local nPosCodLoc := GdFieldPos("TH2_CODLOC", oGet495:aHeader)
	Local nPosCodPnt := GdFieldPos("TH2_CODPTO", oGet495:aHeader)

	Local nLinha := 0

	If (nPosCodLoc > 0) .And. (nPosCodPnt > 0)
		nLinha := aScan(oGet495:aCols, { |x| x[nPosCodLoc] + x[nPosCodPnt] == cDepto + cPontoClt })
	Endif

Return nLinha > 0 .And. !oGet495:aCols[nLinha][Len(oGet495:aCols[nLinha])]

//---------------------------------------------------------------------
/*/{Protheus.doc} GravaAcols
Os pontos de coleta que foram marcados na tela de pesquisa serão trazidos para MsNewGetDados

@author  Gabriel Augusto Werlich
@since   14/02/2014
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Static Function GravaAcols()

	Local nPosOrdem  := GdFieldPos("TH2_CODORD", oGet495:aHeader)
	Local nPosCodLoc := GdFieldPos("TH2_CODLOC", oGet495:aHeader)
	Local nPosDesLoc := GdFieldPos("TH2_DESLOC", oGet495:aHeader)
	Local nPosCodPnt := GdFieldPos("TH2_CODPTO", oGet495:aHeader)
	Local nPosDesPnt := GdFieldPos("TH2_DESPTO", oGet495:aHeader)
	Local nLinha, cLast, nLin

	//Verifica itens retirados da tabela temporária (Desmarcados)
	For nLin := 1 to Len(oGet495:aCols)
		If !oGet495:aCols[nLin][Len(oGet495:aCols[nLin])]
			dbSelectArea(cAliasPC)
			dbSetOrder(1)
			If dbSeek(oGet495:aCols[nLin][nPosCodLoc]+oGet495:aCols[nLin][nPosCodPnt]) .And. Empty((cAliasPC)->TRB_OK)
				oGet495:nAt := nLin
				oGet495:Execute(oGet495:bDelOk)
				oGet495:aCols[nLin][Len(oGet495:aCols[nLin])] := .T.
			EndIf
		EndIf
	Next

	//Retira linhas deletadas do acols
	While (nRow := aScan(oGet495:aCols, {|x| x[Len(x)] } )) > 0 .Or.(nRow := aScan(oGet495:aCols, {|x| Empty(x[nPosCodLoc]) .Or. Empty(x[nPosCodPnt]) } )) > 0
		aDel(oGet495:aCols, nRow)
		aSize(oGet495:aCols, Len(oGet495:aCols) - 1)
	End

	dbSelectArea(cAliasPC)
	dbSetOrder(3) // Marcados
	dbGoTop()
	//Verifica se a tabela temporaria está em fim de arquivo, e se o campo de OK não está vazio
	While !Eof()
		
		If !Empty((cAliasPC)->TRB_OK)

			//Se não encontrar um registro que não está na tabela temporária, sai do If
			If aScan(oGet495:aCols, { |x| x[nPosCodLoc] + x[nPosCodPnt] == (cAliasPC)->TRB_DEPTO + (cAliasPC)->TRB_CODIGO }) == 0

				cLast  := RetUltOrd()

				aAdd(oGet495:aCols, BlankGetD(oGet495:aHeader)[1])

				nLinha := Len(oGet495:aCols)

				oGet495:aCols[nLinha][nPosCodLoc] := (cAliasPC)->TRB_DEPTO
				oGet495:aCols[nLinha][nPosDesLoc] := NGSeek( "TAF", (cAliasPC)->TRB_DEPTO, 8, "TAF_NOMNIV" )
				oGet495:aCols[nLinha][nPosCodPnt] := (cAliasPC)->TRB_CODIGO
				oGet495:aCols[nLinha][nPosDesPnt] := (cAliasPC)->TRB_DESCRI
				oGet495:aCols[nLinha][nPosOrdem]  :=  Soma1Old(cLast)

			EndIf

		EndIf

		(cAliasPC)->(dbSkip())

	End
	//Se não existir nenhuma linha na GetDados, chama a função SGA495INIT
	If Empty(oGet495:aCols)
		SGA495INIT(oGet495:aHeader, @oGet495:aCols)
	EndIf

	//Posiciona a linha atual sempre para 1
	oGet495:nAt := 1
	oGet495:ForceRefresh()
	oGet495:Refresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SGA495RLOR
Função para incrementar a indexação das linhas da MsNewGetDados
SX3
@author  Gabriel Augusto Werlich
@since   14/02/2014
@version P11
@return  cUltOrd
/*/
//---------------------------------------------------------------------
Function SGA495RLOR()

	Local cUltVal := ""
	Local cUltOrd := ""
	Local nUltOrd

	Private nPosOrdem

	nPosOrdem := GdFieldPos("TH2_CODORD", oGet495:aHeader)
	nUltOrd   := Len(oGet495:aCols) - 1

	If nUltOrd == 0 .Or. oGet495:aCols[nUltOrd][8]
		cUltVal := GetUltOrd()
	Else
		cUltVal := oGet495:aCols[nUltOrd][nPosOrdem]
	EndIf

	cUltVal := Val(cUltVal)
	cUltVal += 1
	cUltOrd := StrZero(cUltVal, 3,0)

Return cUltOrd

//---------------------------------------------------------------------
/*/{Protheus.doc} SG495DelOk
Caso deletar a linha atual, processa as demais linhas para condizer
com o restante.

@author  Gabriel Augusto Werlich
@since   14/02/2014
@version P11
@return  .T.
/*/
//---------------------------------------------------------------------
Function SG495DelOk()

	Local lDelLine
	Local cUltVal  := Space(3)
	Local nLineGet := oGet495:nAt
	Local nLine

	Private nPosOrdem

	If Type("oGet495") <> "O" .Or.  (nPosOrdem := aScan( oGet495:aHeader, {|x| Upper(Trim(x[2])) == "TH2_CODORD" } )) == 0
		Return .F.
	Endif

	lDelLine := !oGet495:aCols[oGet495:nAt][Len(oGet495:aCols[oGet495:nAt])]

	If lDelLine
		nLineGet++
	Endif

	cUltVal := GetUltOrd() // Ultima ordem valida antes da linha atual
	cOrdem  := cUltVal

	For nLine := nLineGet To Len(oGet495:aCols)

		cOrdem := Soma1Old(cUltVal)

		If !oGet495:aCols[nLine][Len(oGet495:aCols[nLine])] .Or. (nLine == oGet495:nAt) // Se nao estiver deletado
			oGet495:aCols[nLine][nPosOrdem] := cOrdem
			cUltVal := cOrdem
		Else
			oGet495:aCols[nLine][nPosOrdem] := cOrdem
		Endif

	Next nLine

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} GetUltOrd
Pesquisa a ordem correta e retorna o valor

@author  Gabriel Augusto Werlich
@since   27/03/2014
@version P11
@return  cOrdem
/*/
//---------------------------------------------------------------------
Static Function GetUltOrd(lLineAt)

	Local cOrdem   := "000"
	Local nLineGet := oGet495:nAt

	Default lLineAt := .F.

	If !lLineAt
		nLineGet--
	Endif

	cOrdem := RetUltOrd(nLineGet)

Return cOrdem

//---------------------------------------------------------------------
/*/{Protheus.doc} SelectPC
Valida se o usuario deseja continuar o processo.

@param aFldMark, array, campos para montar o markbrowse

@author  Gabriel Augusto Werlich
@since   03/04/2014
@return  Nil

/*/
//--------------------------------------------------------------------
Static Function SelectPC(aFldMrk)

	If	(aScan(oGet495:aCols, {|x| x[Len(x)] } ) > 0) .And. !MsgYesNo(STR0037) //"Existem registros deletados que irão desaparecer da lista ao continuar o processo. Deseja continuar?"
		Return
	EndIf

	SG495SLPC(aFldMrk)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SGA495INIT
Inicia o valor da primeira linha da MsNewGetDados com o campo ordem (TH2_CODORD)

@author  Gabriel Augusto Werlich
@since   03/04/2014
@version P11
@return
/*/
//--------------------------------------------------------------------
Function SGA495INIT(aHeaderPC, aColsPC)

	Local nPosOrdem := GdFieldPos("TH2_CODORD", aHeaderPC)

	aColsPC := BlankGetd(aHeaderPC)
	aColsPC[1][nPosOrdem] := "001"

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SGA495VLOR
Valid do campo de Ordem (TH2_CODORD).
Valida se o numero que for digitado na coluna de Ordem é maior que o tamanho total de linhas.

@author  Gabriel Augusto Werlich
@since   03/04/2014
@version P11
@return  .T.
/*/
//--------------------------------------------------------------------
Function SGA495VLOR()

	Local cVal := RetUltOrd()

	M->TH2_CODORD := Padl(Alltrim(M->TH2_CODORD), Len(TH2->TH2_CODORD), "0")

	If M->TH2_CODORD > cVal .Or. M->TH2_CODORD == "000"
		MsgStop(STR0038) // "Não é possível informar a ordem como '000' ou um valor maior que o numero de linhas."
		Return .F.
	EndIf

	SGA495POS()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SGA495POS
Função que permite o usuario alterar a ordem das linhas da getdados

@author  Gabriel Augusto Werlich
@since   03/04/2014
@version P11
@return  Nil
/*/
//--------------------------------------------------------------------
Function SGA495POS()

	Local nPosOrdem  := GdFieldPos("TH2_CODORD", oGet495:aHeader)
	Local nTamOrdem  := TAMSX3("TH2_CODORD")[1]
	Local aLineAtual := {}
	Local aLine      := {}
	Local nStepFor   := 1
	Local nLine
	Local nSubst

	//Verifica qual a linha que possui o mesmo valor da linha atual
	nSubst := aScan(oGet495:aCols, { |x| !x[Len(x)] .And. x[nPosOrdem]  == M->TH2_CODORD })

	If nSubst == oGet495:nAt
		Return
	Endif

	nOrdem := oGet495:aCols[oGet495:nAt][nPosOrdem]

	If nSubst > 0 // Se existir a linha

		If oGet495:nAt < nSubst //De cima para baixo
			nStepFor := -1
		Endif

		aLineAtual            := aClone(oGet495:aCols[oGet495:nAt]) //Clona a linha atual(nAt)
		aLineAtual[nPosOrdem] := oGet495:aCols[nSubst][nPosOrdem]

		For nLine := nSubst To oGet495:nAt Step nStepFor

			aLine := aClone(oGet495:aCols[nLine]) //Armazena linha que sera alterada
			oGet495:aCols[nLine] := aClone(aLineAtual) // Altera a linha para a linha salva anteriormente

			If nLine <> nSubst

				oGet495:aCols[nLine][nPosOrdem] := StrZero(Val(oGet495:aCols[nLine][nPosOrdem]) + nStepFor, nTamOrdem)

				If nLine == oGet495:nAt
					M->TH2_CODORD := oGet495:aCols[nLine][nPosOrdem]
				Endif

			Endif

			aLineAtual := aClone(aLine) // Salva a linha atual com o valor antes da alteração

		Next

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SGA495DEL
Função que deleta a linha posicionada.

@author  Gabriel Augusto Werlich
@since   03/04/2014
@version P11
@return  Nil
/*/
//--------------------------------------------------------------------
Function SGA495DEL()

	Local nPosOrdem := GdFieldPos("TH2_CODORD", oGet495:aHeader)
	Local nLine, nAtual, cLinhaAtual
	Local cDefault := "001"

	//Se a linha não estiver com o código de localização e código de ponto de coleta, não permitira excluir a linha
	If !SGA495VLIN()
			Help(" ",1,"OBRIGAT2")
		Return .F.
	EndIf

	// Armazena informacoes da linha antual
	cLinhaAtual := oGet495:aCols[oGet495:nAt][nPosOrdem]
	lDelRow     := oGet495:aCols[oGet495:nAt][Len(oGet495:aCols[oGet495:nAt])] // Verifica se linha atual esta deletada

	// Deleta linha atual
	aDel(oGet495:aCols, oGet495:nAt)
	aSize(oGet495:aCols, Len(oGet495:aCols) - 1)

	//Se não existir linhas na getdados, não entra no if
	If Len(oGet495:aCols) > 0
		If !lDelRow
			//Reposiciona as linhas
			For nLine := oGet495:nAt to Len(oGet495:aCols)

				If nLine == oGet495:nAt
					oGet495:aCols[nLine][nPosOrdem] := cLinhaAtual
				Else
					nAtual := oGet495:aCols[nLine][nPosOrdem]
					nAtual := Val(nAtual)
					nAtual -= 1
					oGet495:aCols[nLine][nPosOrdem] := StrZero(nAtual,3,0)
				EndIf

			Next
		Endif
	Else
		PutFileInEOF("TH2")
		oGet495:AddLine(.T.)
		oGet495:aCols[1][nPosOrdem] := cDefault
	Endif

	oGet495:Refresh()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SGA495WNOR
When do campo de ordem (TH2_CODORD).
Verifica se todos os campos obrigatorios foram preenchidos.

@author  Gabriel Augusto Werlich
@since   03/04/2014
@version P11
@return  Boolean - .T. Todos os campos estão preenchidos
					 .F. Campo obrigatorio não preenchido
/*/
//--------------------------------------------------------------------
Function SGA495WNOR()
Return SGA495VLIN()

//---------------------------------------------------------------------
/*/{Protheus.doc} RetUltOrd
Retorna ultima ordem não deletada.

@author  Gabriel Augusto Werlich
@since   22/04/2014
@version P11
@return  cUldOrdVal
/*/
//--------------------------------------------------------------------
Static Function RetUltOrd(nIniRow)

	Local nPosOrdem := GdFieldPos("TH2_CODORD", oGet495:aHeader)
	Local cUldOrdVal := "000"
	Local nLine

	Default nIniRow := Len(oGet495:aCols)

	//Faz um for do final para o começo
	For nLine := nIniRow to 1 Step - 1

		If !oGet495:aCols[nLine][Len(oGet495:aCols[nLine])] // Se a linha não estiver deletada
			cUldOrdVal := oGet495:aCols[nLine][nPosOrdem] // Armazena o codigo da ordem
			Exit
		EndIf
	Next

Return cUldOrdVal

//---------------------------------------------------------------------
/*/{Protheus.doc} SGA495VLIN
Retorna ultima ordem não deletada.

@author  Gabriel Augusto Werlich
@since   22/04/2014
@version P11
@return  cUldOrdVal
/*/
//--------------------------------------------------------------------
Static Function SGA495VLIN()

	Local nPosCodLoc := GdFieldPos("TH2_CODLOC", oGet495:aHeader)
	Local nPosCodPnt := GdFieldPos("TH2_CODPTO", oGet495:aHeader)

	//Se a linha atual não estiver com os campos de Localização e Ponto de Coleta preenchidos, retorna falso.
	If Empty(oGet495:aCols[oGet495:nAt][nPosCodLoc]) .And. Empty(oGet495:aCols[oGet495:nAt][nPosCodPnt])
		Return .F.
	EndIf

Return .T.

//----------------------------------------
/*/{Protheus.doc} fAllMark
Ações de marcar/desmarcar tudo

@author Bruno Lobo de Souza
@since 06/10/2021
@param oMark, object, instância do markbrose
@param cMark, string, marca utilizada no campo ok
@param cAliBrw, string, alias da Tabela temporária que será atualizada
/*/
//----------------------------------------
Static Function fAllMark( oMark, cMark, cAliBrw, cFieldOK )

	dbSelectArea( cAliBrw )
	dbGotop()
	While !Eof()
		RecLock( cAliBrw, .F. )

		If Empty( (cAliBrw)->&(cFieldOK) )
			(cAliBrw)->&(cFieldOK) := cMark
		Else
			(cAliBrw)->&(cFieldOK) := "  "
		EndIf

		MsUnLock()

		(cAliBrw)->( dbSkip() )
	EndDo

	(cAliBrw)->(dbGotop())
	
	oMark:oBrowse:Refresh()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fPesqTRB
Funcao de Pesquisar no Mark Browse.

@return lRet, Lógico, .T. caso encontrar o registro

@param cAliasTRB, Caracter, Alias do MarkBrowse ( Obrigatório )
@param oMark, Objeto, Objeto do MarkBrowse ( Obrigatório )
@param cPesquisar, Caracter, Valor digitado no campo de pesquisa ( Obrigatório )

@author	Cauê Girardi Petri
@since	18/02/2022
/*/
//---------------------------------------------------------------------
Static Function fPesqTRB( cAliasTRB, oMark, cPesquisar )

	Local nRecNoAtu := 1 //Variavel para salvar o recno
	Local lRet		:= .T.

	//Posiciona no TRB e salva o recno
	dbSelectArea( cAliasTRB )
	nRecNoAtu := RecNo()

	dbSelectArea( cAliasTRB )
	If dbSeek( AllTrim( Upper( cPesquisar ) ) )
		//Caso exista a pesquisa, posiciona
		oMark:oBrowse:SetFocus()
	Else
		//Caso nao exista, retorna ao primeiro recno e exibe mensagem
		dbGoTo( nRecNoAtu )
		Help( ' ', 1, "Atenção", , "Valor não encontrado", 2, 0, , , , , , { "Favor digitar outro valor para pesquisa" } )
		oPesquisar:SetFocus()
		lRet := .F.
	EndIf

	//Atualiza o MarkBrowse
	oMark:oBrowse:Refresh( .T. )

Return lRet
